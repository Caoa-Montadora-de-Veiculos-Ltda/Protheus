#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#define CRLF chr(13) + chr(10)

/*/{Protheus.doc} ZPECF010
Serviço de integração  Autoware recebimento de Pedidos Peças
Inclusão peças de veículos enviados pela Autoware - Chamada REST ZWSR005
@author 	DAC 
@since 		23/07/2021
@version 	undefined
@param		Não utilizado
@type 		User Function
@client   	CAOA BARUERI
@return   	_aMsg - Array com retorno Json código e ocorrencia
@project 	Interfaces_PortalV3_v2 x Protheus v2
@Obs 		Implementado MIT044-Customização para MVA Barueri  V3.0(GAP-FAT005)
Z	-Customizado
PEC	- Modulo
F 	- Função
011 - Sequencial
/*/

/*  Acessos/suporte
			https://tdn.totvs.com/display/tec/DecodeUTF8
			https://jsonformatter.curiousconcept.com/  VERIFICAR SE JSON ESTA CORRETO
			https://jsonlint.com/?code=   //VALIDAR JSON
            https://jsoneditoronline.org/#left=local.sowavu  //estrutura do json
			http://abdhdu-des-protheus.totvscloud.com.br:45487/rest_des02/ZPECF010
			https://abdhdu-des-protheus.totvscloud.com.br:45022/rest/ZPECF010
			https://abdhdu-des-protheus.totvscloud.com.br:45022/rest/ZPECF010
*/
User Function ZPECF010(_oJson)
Local _aMsg		:= {}

Begin Sequence
	Private _aRetMsg := ZPEC10AMsg()   	//Carregar tabela com erros
	Private _aMsgRet := {}				//carregar msg de errp

    If ZPECF010PR( @_oJson )
		U_ZRETMsgJson("ok", "Atualização realizada com Sucesso !")
	Endif
	_aMsg := U_ZSetMsgJson()

End Sequence
Return _aMsg


/*/{Protheus.doc} ZPECF010PR
Recebe 		Json Autoware POST 
@author 	DAC
@since 		23/07/2021
@version 	undefined
@param 		oJson
@type 		function
@ Obs		Os paremetros de token, empresa e filial serão enviados no cabeçalho reader Json
/*/
Static Function ZPECF010PR( _oJson )
Local _cEmpresa     := Space(02)
Local _cFilAtu      := Space(04)
Local _cToken       := Space(08)
Local _lRet			:= .T.
Local _lGrvJson  	:= SuperGetMV( "CMV_PEC025"  ,,.T.)  	    //Cód Usuario

Local _cPedido

Begin Sequence
    _cEmpresa     := AllTrim(_oJson:GetJsonText("cEmpresa"))
    _cFilAtu      := _oJson:GetJsonText("cFilAtu")
    _cToken       := AllTrim(_oJson:GetJsonText("cToken"))
    If Empty ( _cEmpresa )
		U_ZRETMsgJson("cEmpresa", "Campo cEmpresa: Empresa nao pode ser branco, favor verificar !")
		_lRet := .F.
        Break
    EndIf
    If Empty ( _cFilAtu )
		U_ZRETMsgJson("cFilAtu", "Campo cFilAtual: Filial nao pode ser branco, favor verificar !")
		_lRet := .F.
        Break
 	EndIf

	
	If "_PRD" $ AllTrim(GetEnvServer()) //CASO SEJA PRD, ENVIAR TOKER REFERENTE A PRD.
		If Empty ( _cToken ) .or. AllTrim(_cToken) <> "AUTOWAREXTOTVS"
			 U_ZRETMsgJson("cToken", "Aplicação Web não está autorizada a acessar os serviços Protheus (Token Failed) !")
			_lRet := .F.
         	Break
 		EndIf
	Else
		If Empty ( _cToken ) .or. AllTrim(_cToken) <> "HOM_AUTOWAREXTOTVS"
			 U_ZRETMsgJson("cToken", "Aplicação Web não está autorizada a acessar os serviços Protheus (Token Failed) !")
			_lRet := .F.
         	Break
 		EndIf
	EndIf
	//Necessario montar esta validação devido o código da filial vir sem espacos e no tenantid também tem que colocar como espaco
	//caso não seja feito ira disposicionar a filial/empresa no SM0 não funcionando corretamente a função XFilial
	If Len(_cFilAtu) < Len(SM0->M0_CODFIL)
		_cFilAtu := _cFilAtu+Space(Len(SM0->M0_CODFIL)-Len(_cFilAtu))
		//_cFilAtu := '2020012001'
	EndIf
    //Tratar abertura da empresa conforme enviado no parametro
	If cEmpAnt <> _cEmpresa .or. cFilAnt <> _cFilAtu
    	RpcClearEnv() 
    	RPCSetType(3) 
    	RpcSetEnv(_cEmpresa, _cFilAtu,,,,GetEnvServer(),{ })
	//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO 'FAT' FUNNAME 'MATA120'
	//abre a tabela posicionada no indice
	EndIf

	VS1->(DbSetOrder(01))  //VS1_FILIAL+VS1_NUMORC                                                                                                                                                                                                                                   
	VS3->(DbSetOrder(01))  //VS3_FILIAL+VS3_NUMORC                                                                                                                                                                                                                                   
	SA1->(DbSetOrder(03))  //A1_FILIAL+A1_CGC                                                                                                                                                                                                                                   

	// Valida os dados do oJson

	If !ValidOJson(_oJson,"I")
		_lRet := .F.
		Break
	EndIf	
	// Realiza a gravação na tabela ZCA
	If !GravaVS1(_oJson,"I")
		_lRet := .F.
		Break
	EndIf

	//Gravar Json enviado
	//Guardo numero pedido para utilizar na gravação do json	
	_cPedido := AllTrim(_oJson:GetJsonText("cdPedido"))
	If _lGrvJson
  		XGRJSONVS1( _cPedido, _oJson ) 
	EndIf
End Sequence
Return _lRet


/*/{Protheus.doc} ValidOJson
Valida os dados do oJson
@author DAC - Denilso
@since 
@version undefined
@param nCode, numeric, descricao
@param cMsg, characters, descricao
@type function
/*/
Static Function ValidOJson(_oJson, _cTipo)
Local _lRet			:= .T.
Local _cCnpjCpf 	:= Space(Len(SA1->A1_CGC))
Local _cPedido		:= Space(Len(VS1->VS1_XPVAW))
Local _cAlias 		:= GetNextAlias()
Local _xCampo
Local _nTam
Local _nPos
Local _cCodProd
Local _nPerc

Begin Sequence

	If !ZPEC10Obri(_oJson)  //Tem a função de validar os itens obrigatórios neste caso o Cabeçalho
		_lRet := .F.
		Break
	EndIf	
	VS1->(DbSetOrder(4))  //VS1_FILIAL+VS1_CLIFAT+VS1_LOJA
	// numero do pedido
	_cPedido := AllTrim(_oJson:GetJsonText("cdPedido"))
	// Cnpj/Cpf
	_cCnpjCpf := AllTrim(_oJson:GetJsonText("cnpj"))
	BeginSql Alias _cAlias
		SELECT 	VS1.R_E_C_N_O_ NREGVS1,
				SA1.R_E_C_N_O_ NREGSA1
       	FROM %table:VS1% VS1
		JOIN %table:SA1% SA1 
			ON  SA1.A1_FILIAL = %XFilial:SA1%
			AND SA1.A1_CGC		= %Exp:_cCnpjCpf%
		  	AND SA1.%notDel%		  
       	WHERE VS1.VS1_FILIAL  	= %XFilial:VS1%
			AND VS1.VS1_CLIFAT  = SA1.A1_COD
			AND VS1.VS1_LOJA  	= SA1.A1_LOJA
			AND VS1.VS1_XPVAW  = %Exp:_cPedido%
		  	AND VS1.%notDel%		  
	EndSql      
	If (_cAlias)->(!Eof()) 	.and. _cTipo == "I"
		U_ZRETMsgJson("existeorc","Pedido "+_cPedido+" para o cliente com Cnpj e ou Cpf "+_cCnpjCpf+" ja enviado , o mesmo não pode ser incluído !")
		_lRet := .F.
		Break
	ElseIf (_cAlias)->(Eof()) 	.and. _cTipo == "A"
		U_ZRETMsgJson("nexisteorc","Pedido "+_cPedido+" para o cliente com Cnpj e ou Cpf "+_cCnpjCpf+" não cadastrado, não será possicel alterado !")
		_lRet := .F.
		Break
	Endif   
	//Validar condição de Pgto
	_xCampo := _oJson:GetJsonText("cdCondicaoPagamento")   
	SE4->(DbSetOrder(1))
	If !SE4->(DbSeek(XFilial("SE4")+_xCampo))
		U_ZRETMsgJson("cdCondicaoPagamento","Condição de pagamento "+_xCampo+" não existe no cadastro !")
		_lRet := .F.
		Break
	EndIf
	
	//Validar tipo de Pedido
	_xCampo := AllTrim(_oJson:GetJsonText("cdTipoPedido"))
	If !PesqTipoX5("Z00", _xCampo)
		U_ZRETMsgJson("cdTipoPedido","Tipo de Pedido "+_xCampo+" não existe no cadastro !")
		_lRet := .F.
		Break
	EndIf

	//Validar tipo de transportes
	_xCampo := AllTrim(_oJson:GetJsonText("cdTipoTransporte"))
	If !PesqTipoX5("Z01", _xCampo)
		U_ZRETMsgJson("cdTipoTransporte","Tipo de Transporte "+_xCampo+" não existe no cadastro !")
		_lRet := .F.
		Break
	EndIf

	/*If !(_xCampo $ '001-002')
		U_ZRETMsgJson("cdTipoTransporte","Tipo de Transporte "+_xCampo+" não existe no cadastro !")
		_lRet := .F.
		Break
	EndIf*/

	//Validar código da Trasportadora
	_xCampo := AllTrim(_oJson:GetJsonText("cdTransportadora"))
	If !Empty(_xCampo)
		SA4->(DbSetOrder(3))  //Filial+CGC
		If !SA4->(DbSeek(XFilial("SA4")+_xCampo))
			U_ZRETMsgJson("cdTransporte","CNPJ de Transportadora "+_xCampo+" não existe no cadastro !")
			_lRet := .F.
			Break
		EndIf	
	EndIf
	//validar marca
	_xCampo := Upper(AllTrim(_oJson:GetJsonText("cdMarca")))
	If !Empty(_xCampo)
		VE1->(DbSetOrder(1))   //Filial+CodMar
		If !VE1->(DbSeek(XFilial("VE1")+_xCampo))
			U_ZRETMsgJson("cdMarca","Código de Marca "+_xCampo+" não existe no cadastro !")
			_lRet := .F.
			Break
		EndIf
	EndIf
	//cdfrete código tipo de pgto frete
	//C=CIF;F=FOB;T=Por Conta Terceiro;R=Por Conta Remetente;D=Por Conta Destinatario;S=Sem Frete	
	_xCampo := Upper(AllTrim(_oJson:GetJsonText("cdFrete")))
	If !Empty(_xCampo )
		If !_xCampo $ "C|F|T|R|D|S"
			U_ZRETMsgJson("cdFrete","Código Tipo de Frete "+_xCampo+" não existe no cadastro !")
			_lRet := .F.
			Break
		EndIf
	EndIf
	//Validação de itens
	_nTam 	:= Len(_oJson["itens"])
	If ValType(_nTam) <> "N" .or. _nTam == 0
		U_ZRETMsgJson("noItensOrc","Não foram enviados itens no orçamento !")
		_lRet := .F.
		Break
	EndIf
	//função de validar os itens obrigatórios 
	For _nPos := 1 To _nTam
		If !ZPEC10Obri(_oJson["itens"][_nPos],.T.)  
			_lRet := .F.
			Break
		EndIf	
	Next _nPos
	SB1->( DbSetOrder(1))
	For _nPos := 1 To _nTam
		_cCodProd := AllTrim(_oJson["itens"][_nPos]:GetJsonText("cdPeca"))
		//Em Barueri esta utilizando R-
		If SubsTr(_cCodProd,1,2) <> "R-"
			_cCodProd := "R-"+_cCodProd
		EndIf
		If Len(_cCodProd) < Len(SB1->B1_COD)
			_cCodProd := _cCodProd+Space(Len(SB1->B1_COD)-Len(_cCodProd))
		EndIf	
		If !SB1->( DbSeek(XFilial("SB1")+_cCodProd) )
			U_ZRETMsgJson("cdPeca","Código da peça "+AllTrim(_cCodProd)+" não cadastrado  !")
			_lRet := .F.
			Break  //abortar direto para manter numeração de erro senão pode existir mais de um erro e ai o retorno será 999 DAC 14/02/2022
		EndIf
		_nPerc := Val(_oJson["itens"][_nPos]:GetJsonText("perDes"))		
		If _nPerc < 0 .or. _nPerc >= 100
			U_ZRETMsgJson("vlDesconto","Código da peça "+AllTrim(_cCodProd)+" possui desconto "+AllTrim(Str(_nPerc))+" % invalido !")
			_lRet := .F.
			Break  //abortar direto para manter numeração de erro senão pode existir mais de um erro e ai o retorno será 999 DAC 14/02/2022
		Endif		
//		If !_lRet
//			Break
//		EndIf	
	Next _nPos
End Sequence
VS1->(DbSetOrder(1))  //VS1_FILIAL+VS1_NUMORC 
If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif  
Return _lRet

//Função para validar e retornar se localizou código na VX5 de acordo com as chaves
Static Function PesqTipoX5(_cChave, _xValor)
Local _cAliasPesq   := GetNextAlias()      
Local _lRet			:= .T.
Begin Sequence
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT 	VX5.VX5_CHAVE,
				VX5.VX5_CODIGO,
				VX5.VX5_DESCRI
		FROM  %Table:VX5% VX5 
		WHERE 	VX5.VX5_FILIAL 	=  %xFilial:VX5% 
			AND VX5.VX5_CHAVE 	=  %Exp:_cChave%
			AND VX5.VX5_CODIGO	=  %Exp:_xValor%
           	AND VX5.%notDel%
	EndSql
	If (_cAliasPesq)->(Eof()) 
		_lRet := .F.
		Break
	EndIf
End Sequence
Return _lRet


	

/*/{Protheus.doc} GravaVS1
Realiza a gravação na tabela VS1 VS3 Orçamento
@author Denilso Almeida Carvalho
@since 18/10/2021
@version undefined
@param nCode, numeric, descricao
@param cMsg, characters, descricao
@type function
/*/
Static Function GravaVS1(_oJson, _cTipo )
Local _lRet			:= .F.
Local _cCnpjCpf		:= Space(014)
Local _cMarca		:= Upper(AllTrim(_oJson:GetJsonText("cdMarca")))
Local _cCodVend    	:= AllTrim(SuperGetMV( "CMV_WSR003"  ,,"000569"))  	//parametro codigo vendedor
Local _cTipoVenda  	:= AllTrim(SuperGetMV( "CMV_WSR004"  ,,"1"))  		//parametro Tipo de Venda
//Local _nTpCliente 	:= Val(AllTrim(_oJson:GetJsonText("cdTpCliente")))
Local _cTipoPed     := AllTrim(_oJson:GetJsonText("cdTipoPedido"))
Local _cTipoOrc		:= AllTrim(Posicione("VX5", 1, XFilial("VX5") + "Z02" + PadR( AllTrim(_cTipoPed), TamSX3("VX5_CODIGO")[1] ), "VX5_DESCRI")) //Tipo do Orçamento (Venda/Transferencia/Remessa)
Local _cTpCliente   := ""
Local _cCenCus		:= ""
Local _cNatureza  	:= ""
Local _cFormula		:= ""
Local _cUsuario    	:= AllTrim(SuperGetMV( "CMV_WSR014"  ,,""))  	    //Cód Usuario
Local _cCnpjTransf  := AllTrim(SuperGetMV( "CMV_WSR019"  ,,"03471344"))	//Raiz CNPJ de transferencia
Local _nPercDesc	:= 0
Local _nPercAcres	:= 0
Local _cOrcNovo		:= ""
Local _cTipoOper  	:= ""
Local _nPos
Local _dData
Local _cData
Local _nTam
Local _cHora
Local _nSeq
Local _cCodTes
Local _cNumOrc
Local _cTransp
Local _cCodTransp
Local _nValTotIt
Local _cSitTrib
Local _nValorUnit
//Local _nPRC_TAB := 0

Begin Sequence
	If Empty(_cUsuario)
		U_ZRETMsgJson("usuario","Não informado Usuário Autoware, verificar com Administrador do Sistema !")
		Break
	EndIf

	//posicionar o cliente
    //grava Pedido
	SA1->(DbSetOrder(3))
	_cCnpjCpf := AllTrim(_oJson:GetJsonText("cnpj"))
	If !SA1->(DbSeek(XFilial("SA1")+_cCnpjCpf))
		U_ZRETMsgJson("noksa1","Não localizado CNPJ/CPF Cliente "+_cCnpjCpf+", verificar !")
		Break
	Else
		_cTpCliente := SA1->A1_XTIPO
	EndIf
	//Conforme e-mail victor a transportadora é por CNPJ DAC 08/02/2022
	_cTransp := AllTrim(_oJson:GetJsonText("cdTransportadora"))
	If !Empty(_cTransp)
		SA4->(DbSetOrder(3))
		If !SA4->(DbSeek(XFilial("SA4")+_cTransp))
			U_ZRETMsgJson("cdTransporte","Não localizado CNPJ/CPF da Transportadora "+_cTransp+", verificar !")
			Break
		EndIf
		_cCodTransp := SA4->A4_COD
	Else
		_cCodTransp := Space(06)
	EndIf

	INCLUI := .T.
	ALTERA := .F.
	EXCLUI := .F.

	If  _cTipoPed == AllTrim(SuperGetMV( "CMV_WSR039"  ,,"011")) .Or.;
		_cTIpoPed == AllTrim(SuperGetMV( "CMV_WSR027"  ,,"013"))
 
		If AllTrim(_cMarca) == "HYU"
			_cCenCus := SUPERGETMV("CMV_WSR036" ,, "53020509MA")
		ElseIf AllTrim(_cMarca) == "CHE"
			_cCenCus := SUPERGETMV("CMV_WSR037" ,, "53290509MA")
		ElseIf AllTrim(_cMarca) == "SBR"
			_cCenCus := SUPERGETMV("CMV_WSR038" ,, "53110509MA")
		EndIf
	EndIf

	If Substring(SA1->A1_CGC,1,8) == _cCnpjTransf //'03471344'
		_cNatureza := AllTrim(SuperGetMV( "CMV_WSR005"  ,,"1201"))
	ElseIf _cTpCliente == "Z" //_nTpCliente == 1
		_cNatureza := AllTrim(SuperGetMV( "CMV_WSR005"  ,,"1201"))
	Else
		If  AllTrim(_oJson:GetJsonText("cdCondicaoPagamento")) == "005"
			_cNatureza := AllTrim(SuperGetMV( "CMV_WSR028"  ,,"1203"))
		Else
			_cNatureza := AllTrim(SuperGetMV( "CMV_WSR035"  ,,"1202"))
		EndIf
	EndIf

	//********************************************************************************************
	//	Devido a Necessidade de gravar a Formula na VS1, e segue a mesma regra da VS3
	//	
	//********************************************************************************************
	
	//1a - Regra - Prioridade Transferencia
	If Substring(SA1->A1_CGC,1,8) == _cCnpjTransf //'03471344'
		_cFormula := AllTrim(GetNewPar("MV_FMLTRAN","000005"))   		//indica formula de Transferencia
	Else
		If _cTipoOrc == "REMESSA"
			_cFormula := AllTrim(GetNewPar("MV_FMLTRAN","000005"))   		//indica formula de Transferencia
		Else
			_cFormula := AllTrim(GetNewPar("MV_FMLPECA","000001"))   		//indica formula padrão
		EndIf
	EndIf

	//DAC - colocada esta validação pois estão cadastrando formula com aspas no parametro
	If Subs(_cFormula,1,1)== '"'
		_cFormula :=  Subs(_cFormula,2,Len(_cFormula)-2)
	EndIf
	
	//********************************************************************************************************

	_cNumOrc 	:= GetSXENum("VS1","VS1_NUMORC")
	//Implementado controle de numeração para não deixar duplicar DAC 15/07/2022
	//caso volte a mesma numeração esta correto caso seja diferente é que a sequencia é maior
	_cOrcNovo	:= U_XVERNUMeracao("VS1", "VS1_NUMORC", _cNumOrc )
	If AllTrim(_cOrcNovo) <> AllTrim(_cNumOrc)
		U_ZRETMsgJson("cdPedidoCAOA","Problemas com numeração de docto CAOA, comunicar o ADM Sistemas CAOA !")
		Break  //alinhado com Zé é um erro de comunicação conforme visto com Victor o mesmo solicitou somente para mudar o numero de retorno de 202 para 610 05/09/2022
	Endif

	Begin Transaction
		RecLock("VS1",.T.)
		VS1->VS1_FILIAL := xFilial("VS1")
		VS1->VS1_NUMORC := _cNumOrc
		VS1->VS1_TIPORC := "1" // =Pedido de Orcamento
		VS1->VS1_CLIFAT := SA1->A1_COD
		VS1->VS1_LOJA   := SA1->A1_LOJA
		VS1->VS1_NCLIFT := SA1->A1_NOME
		VS1->VS1_TIPCLI := SA1->A1_TIPO
		VS1->VS1_TPATEN := "1" // Externo
		VS1->VS1_PEDSTA := "0" // Aberto
		VS1->VS1_FORMUL := _cFormula
		//VS1->VS1_DATORC := CriaVar("VS1_DATORC")
		VS1->VS1_DATVAL := CriaVar("VS1_DATVAL")
		VS1->VS1_DATALT := CriaVar("VS1_DATALT")
		VS1->VS1_CODVEN := _cCodVend
		VS1->VS1_STATUS := "0"
		VS1->VS1_RESERV := "0"
		VS1->VS1_STARES := "3"
		VS1->VS1_GERFIN := "1"
		VS1->VS1_NOROUT := "1"
		VS1->VS1_ALTORC := "1"
		VS1->VS1_CFNF   := "1"
		VS1->VS1_RESFRE := CriaVar("VS1_RESFRE")
		VS1->VS1_OPORTU := "0" // 0=Nao / 1=Sim
		VS1->VS1_XPVAW 	:=  AllTrim(_oJson:GetJsonText("cdPedido"))	
		VS1->VS1_XSPVAW := "0"	//0=EM ANALISE;1=ATENDIDO PARCIAL;2=ATENDIDO TOTAL;3=FATURADO/PARCIAL;4=FATURADO/TOTAL;5=NAO ATENDIDO;6=CANCELADO
		VS1->VS1_XCHASS :=  AllTrim(_oJson:GetJsonText("chassi"))	
		VS1->VS1_XNUMOS :=	AllTrim(_oJson:GetJsonText("os"))	
		VS1->VS1_CODVEN := _cCodVend
		VS1->VS1_XTPPED := AllTrim(_oJson:GetJsonText("cdTipoPedido"))		
		VS1->VS1_TRANSP := _cCodTransp   //AllTrim(_oJson:GetJsonText("cdTransportadora"))	 //"000002"  
		VS1->VS1_PGTFRE := AllTrim(_oJson:GetJsonText("cdFrete"))	
		//(De/Para Autoware) cdTipoTransporte 
		VS1->VS1_XTPTRA := AllTrim(_oJson:GetJsonText("cdTipoTransporte"))		
		VS1->VS1_FORPAG := _oJson:GetJsonText("cdCondicaoPagamento")			
		VS1->VS1_TIPVEN := _cTipoVenda	
		VS1->VS1_NATURE	:= _cNatureza
		VS1->VS1_OBSCON := Upper(AllTrim(_oJson:GetJsonText("comentario")))
		If VS1->VS1_XTPPED == AllTrim(SuperGetMV( "CMV_WSR047"  ,,"016"))	//Msg para NF Mudança FDR
			VS1->VS1_MENNOT := Upper(AllTrim(_oJson:GetJsonText("comentario")))
		Endif
		//(De/Para Autoware) cdMarca Marca
		VS1->VS1_CODMAR := ""
		VS1->VS1_XMARCA := _cMarca	
		VS1->VS1_XDTIMP := Date()
		VS1->VS1_XHSIMP := Time()
		VS1->VS1_XUSIMP := _cUsuario //RetCodUsr() 
		VS1->VS1_ESPEC1	:= "VOLUME"//CriaVar("VS1_ESPEC1")
		VS1->VS1_TIPCLI := SA1->A1_TIPO
		_nPercDesc		:= zPercDesc(Upper(AllTrim(_oJson:GetJsonText("cdMarca"))), AllTrim(_oJson:GetJsonText("cdTipoPedido")), SA1->A1_COD, SA1->A1_LOJA )
		VS1->VS1_PERDES := _nPercDesc
		_nPercAcres		:= zPercAcres(Upper(AllTrim(_oJson:GetJsonText("cdMarca"))), AllTrim(_oJson:GetJsonText("cdTipoPedido")), SA1->A1_COD, SA1->A1_LOJA )
		VS1->VS1_XPORAC := _nPercAcres
		VS1->VS1_XDESMB := VS1->VS1_NUMORC
		VS1->VS1_XINTEG := "S"

		VS1->VS1_ICMCAL	:= CriaVar("VS1_ICMCAL")
		VS1->VS1_ICMRET	:= CriaVar("VS1_ICMRET")
		VS1->VS1_VALCOF := CriaVar("VS1_VALCOF")
		VS1->VS1_VALDES := CriaVar("VS1_VALDES")
		VS1->VS1_VALIPI	:= CriaVar("VS1_VALIPI")
		VS1->VS1_VALISS	:= CriaVar("VS1_VALISS")
		VS1->VS1_VALPIS	:= CriaVar("VS1_VALPIS")
		VS1->VS1_DIFAL  := CriaVar("VS1_DIFAL") 
		VS1->VS1_VLBRNF := CriaVar("VS1_VLBRNF")  
		VS1->VS1_DESACE := CriaVar("VS1_DESACE")
		VS1->VS1_VALSEG := CriaVar("VS1_VALSEG")
		VS1->VS1_VALFRE := CriaVar("VS1_VALFRE")
		VS1->VS1_TRFRES := CriaVar("VS1_TRFRES")
		VS1->VS1_INDPRE := CriaVar("VS1_INDPRE")
		VS1->VS1_RESLOG := CriaVar("VS1_RESLOG")
		VS1->VS1_VPERDI := CriaVar("VS1_VPERDI")

		//VS1->VS1_VTOTNF := Val(_oJson:GetJsonText("vlTotal")) //CriaVar("VS1_VTOTNF")
		//DAC 16/03/2022
		//Montado ajuste para data e hora não estão enviando data da OS somente do pedido
		/*
		
		// A data de priorização que deve ser considerada é somente a Data do Pedido.
		// Definido pela Rosangela / Evandro / Jose Carlos - 05/05/2022
		_cData			:= _oJson:GetJsonText("dtAberturaOS")
		If Empty(_cData)
			_cData			:= _oJson:GetJsonText("dtPedido")
		EndIf*/

		//Evandro Mariano: Trata a Data de Abertura da OS
		_cData	:= _oJson:GetJsonText("dtAberturaOS")
		If !Empty(_cData)
			//   "dtAberturaOS":"2018-05-02T10:06:00-03:00",
			_dData := StoD(	substr(_cData,1,4)+;
							substr(_cData,6,2)+;
							substr(_cData,09,2) )	
		
			VS1->VS1_XDATOS := _dData
         	//VS1->VS1_XHOROS := Val(_cHora)
		EndIf			
		//Evandro Mariano: Trata a Data de Abertura do Pedido.
		// Grava data no campo VS1_DATORC que será usado para priorização.
		_cHora	:= "" 
		_cData	:= _oJson:GetJsonText("dtPedido")
		If !Empty(_cData)
			//   "dtAberturaOS":"2018-05-02T10:06:00-03:00",
			_dData := StoD(	substr(_cData,1,4)+;
							substr(_cData,6,2)+;
							substr(_cData,09,2) )	
			_cHora := 	substr(_cData,12,2)+":"+;
				  		substr(_cData,15,2) 
			//VS1->VS1_XDATOS := _dData	
			//VS1->VS1_XHOROS := _cHora
        	
			//JC deve vir o horário que o pedido foi confirmado na WEB   //CriaVar("VS1_HORORC")
			_cHora 			:= SubsTr(_cHora,1,2)+SubsTr(_cHora,4,2)  //a hora é gravada como numerico
			VS1->VS1_DATORC := _dData
         	VS1->VS1_HORORC := Val(_cHora) //AllTrim(Substr(_oJson:GetJsonText("dtPedido"),12,14))
		EndIf			
		// Centro de Custos
		VS1->VS1_CENCUS := _cCenCus
		VS1->(MsUnLock())
		VS1->(ConfirmSx8())

		//Busca o Tipo de Operação de acordo com as regras de prioridade.
// 11/11/22 - mudou mais pra baixo pq tem que pegar o grupo trib do produto--
		_cTipoOper := U_zTpOper( SA1->A1_COD, SA1->A1_LOJA, AllTrim(_oJson:GetJsonText("cdTipoPedido"))	)	

		/*
		********************************************************************************************
		Devido a Necessidade de gravar a Formula na VS1, foi movido para antes de Gravar na VS1
		********************************************************************************************
		//1a - Regra - Prioridade Transferencia
		If Substring(SA1->A1_CGC,1,8) == _cCnpjTransf //'03471344'
			_cFormula := AllTrim(GetNewPar("MV_FMLTRAN","000005"))   		//indica formula de Transferencia
		Else
			_cFormula := AllTrim(GetNewPar("MV_FMLPECA","000001"))   		//indica formula padrão
		EndIf

			//DAC - colocada esta validação pois estão cadastrando formula com aspas no parametro
		If Subs(_cFormula,1,1)== '"'
			_cFormula :=  Subs(_cFormula,2,Len(_cFormula)-2)
		EndIf
		*/
		//Grava os itens
		_nSeq := 0
		_nTam 	:= Len(_oJson["itens"])
		For _nPos := 1 To _nTam
			_nSeq ++
			_cCodProd := AllTrim(_oJson["itens"][_nPos]:GetJsonText("cdPeca"))
			//_cTipoOper := U_zTpOper( SA1->A1_COD, SA1->A1_LOJA, AllTrim(_oJson:GetJsonText("cdTipoPedido")),_cCodProd	)	
			//Em Barueri esta utilizando R-
			If SubsTr(_cCodProd,1,2) <> "R-"
				_cCodProd := "R-"+_cCodProd
			EndIf
			SB1->( DbSetOrder(1))
			SB1->( DbSeek(XFilial("SB1")+_cCodProd) )
			_cSitTrib 	:= ""
			_cCodTes 	:= FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
			If Empty(_cCodTes)
				_cCodTes := MaTesInt(2,_cTipoOper,VS1->VS1_CLIFAT,VS1->VS1_LOJA,"C",_cCodProd,/*"VS3_CODTES"*/)
				//para não gerar erro na integração DAC 15/02/2022
				//mesmo com a validação o precesso aborta  DAC 23/02/2022
				If Valtype(_cCodTes) <> "C"
					_cCodTes := ""
				EndIf
			EndIf 
			//DAC 16/03/2022
			//Implementado conforme MIT044-Customização para MVA Barueri  V3.0(GAP-FAT005) 
			//_cCodTesMVA := Iif(Findfunction("U_ZFISF008"),U_ZFISF008(),"")  //TES com InCidencia MVA
			//If !Empty(_cCodTesMVA) 
				//_cCodTes := _cCodTesMVA
			//EndIf 
			//localizar sittrib
			SF4->( DbSetOrder(1) )		//F4_FILIAL + F4_CODIGO
			If !Empty(_cCodTes) .and. SF4->( DbSeek(xFilial("SF4") + _cCodTes) )
				_cSitTrib := SubsTr(SB1->B1_ORIGEM,1,1)+SubsTr(SF4->F4_SITTRIB,1,2)
			EndIf

			Reclock("VS3",.T.)
			VS3->VS3_FILIAL := xFilial("VS3")
			VS3->VS3_NUMORC := VS1->VS1_NUMORC
			VS3->VS3_SEQUEN := strzero(_nSeq,3)
			VS3->VS3_GRUITE := SB1->B1_GRUPO
			VS3->VS3_CODITE := _cCodProd //SB1->B1_CODITE
			VS3->VS3_QTDITE := Val(_oJson["itens"][_nPos]:GetJsonText("quantidade"))
			//Centro de Custos
			VS3->VS3_CENCUS := _cCenCus
			//VS3->VS3_QTDPED := VS3->VS3_QTDITE 
			VS3->VS3_QTDINI := VS3->VS3_QTDITE
			VS3->VS3_CODTES := _cCodTes
			VS3->VS3_SITTRI := _cSitTrib
			VS3->VS3_LOCAL 	:= SB1->B1_LOCPAD
			VS3->VS3_FORMUL := _cFormula
			VS3->VS3_XITSUB := VS3->VS3_CODITE   //manter o numero do original conforme JC - DAC 27/05/2022
			//VS3->VS3_PERDES := Val(_oJson["itens"][_nPos]:GetJsonText("perDes"))
			VS3->VS3_PERDES := _nPercDesc
	
			//CONFORME ALINHADO COM ZÉ SERA UTILIZADO PARA VALOR UNITARIO O DA TABELA DA1
			_nValorUnit	:= U_XOFUNVTB(VS1->VS1_CLIFAT, VS1->VS1_LOJA, VS3->VS3_CODITE)
			VS3->VS3_VALPEC := _nValorUnit //_nPRC_TAB    //Val(_oJson["itens"][_nPos]:GetJsonText("vlPeca"))
			VS3->VS3_OPER	:= _cTipoOper	//Réplica @José Carlos: Porém, será necessário que execute o gatilho e preencha a TES correta vinculada à operação.
			_nValTotIt		:= VS3->VS3_VALPEC * VS3->VS3_QTDITE  //Round((_nPRC_TAB * VS3->VS3_QTDITE),2)        //Round((VS3->VS3_VALPEC * VS3->VS3_QTDITE),2)
			VS3->VS3_VALDES := _nValTotIt * (VS3->VS3_PERDES/100)  
			_nvaldes 		:=  _nValTotIt * (VS3->VS3_PERDES/100)
			//VS3->VS3_VALTOT := _nValTotIt - VS3->VS3_VALDES //VS3->VS3_VALPEC * VS3->VS3_QTDITE
			//acrescentado 25/03/2021 DAC
			//VS3->VS3_VALLIQ := VS3->VS3_VALTOT / VS3->VS3_QTDITE
			//peça faz parte de kit
			
			VS3->VS3_PECKIT := "0"   //---DAC VERIFICAR COMO LOCALIZAR A INFORMAÇÃO SE A PEÇA PERTENCE A UM KIT, A MESMA NA AGLUTINAÇÃO PODERA SER GRAVADA COMO PERTENCE [0=Não;1=Mandatório;2=Correlato] 
			VS3->VS3_RESERV := "0"   //entrando não esta reservado
			VS3->VS3_IMPRES := "0"  
			VS3->VS3_PROMOC := "0" 
			//VS3->VS3_QTDPED := VS3->VS3_QTDPED - VS3->VS3_QTDITE
			VS3->VS3_VALTOT := (VS3->VS3_VALPEC*VS3->VS3_QTDITE) - VS3->VS3_VALDES
			_nTotLiq 		:= Round(((VS3->VS3_VALPEC*VS3->VS3_QTDITE) - _nvaldes )/VS3->VS3_QTDITE,TamSx3("VS3_VALLIQ")[2])
			VS3->VS3_VALLIQ := _nTotLiq //VS3->VS3_VALTOT / VS3->VS3_QTDITE

			VS3->VS3_CODSIT := CriaVar("VS3_CODSIT")
			VS3->(MsUnLock())
		Next _nPos
		//grava impostos
		//Disarmtransaction()  //---DAC temporario para não gravar
		//OX001RECALC(nOpc)  //caso chamada esta função tera que recarregar todo o processo com variaveis e objetos
		_lRet := .T.
	End Transaction
	If !_lRet
		U_ZRETMsgJson("noGrava","Problemas com a gravação de dados em relação aos campos verificar com Administrador !")
		Break
	Else
		//substituido DAC 06/10/2022
		StartJob("U_XFUNIPOSTO",GetEnvServer(),.F.,_cNumOrc, cEmpAnt, cFilAnt, /*_lJob*/)
		//U_ORCCALFIS(/*_cNumOrc*/)
	EndIf
End Sequence
Return _lRet

/*/{Protheus.doc} zPercDesc
//Busca o percentual de Desconto.
@author Evandro Mariano
@since 06/05/2022
@version undefined
@param _aMsg, array, descrição
@type function
/*/
Static Function zPercDesc(_cMarcaOrc,_cTipoPed,_cCliente,_cLoja)

Local _nRet				:= 0
Local _aTpDesc			:= Separa(AllTrim(SuperGetMV( "CMV_WSR029"  ,,"005|5")),";" )
Local _cMarcaDesc		:= AllTrim(SuperGetMV( "CMV_WSR030"  ,,"CHE"))
Local _nX				:= 0
Local _cTipoOrc			:= AllTrim(Posicione("VX5", 1, XFilial("VX5") + "Z02" + PadR( AllTrim(_cTipoPed), TamSX3("VX5_CODIGO")[1] ), "VX5_DESCRI")) //Tipo do Orçamento (Venda/Transferencia/Remessa)
Local _cCnpjTransf  	:= AllTrim(SuperGetMV( "CMV_WSR019"  ,,"03471344"))	//Raiz CNPJ de transferencia
Local _cBxInter 		:= AllTrim(SuperGetMV( "CMV_WSR027"  ,,"013"))		//Código Baixa Interna
Local _cZFVenda			:= AllTrim(SuperGetMV( "CMV_WSR021"  ,,"AC|93;AP|92;AM|93;RO|93;RR|93"))	//Zona Franca - Venda
If _cTipoOrc == "VENDA"
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(XFilial("SA1") + _cCliente + _cLoja ))
		//1a - Regra - Prioridade Transferencia
		If !(Substring(SA1->A1_CGC,1,8) == _cCnpjTransf) //'03471344'
			If !(SA1->A1_EST) $ _cZFVenda
				If !(_cTipoPed == _cBxInter) //"013"
					If _cMarcaOrc $ _cMarcaDesc
						If _cTipoPed $ AllTrim(SuperGetMV( "CMV_WSR029"  ,,"005|5;"))
							For _nX := 1 To Len(_aTpDesc)
								If _cTipoPed $ _aTpDesc[_nX]
									_nRet := Val(Substr(_aTpDesc[_nX],At( "|", _aTpDesc[_nX] ) + 1 , 3 ))
								EndIf
							Next _nX
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return(_nRet)

/*/{Protheus.doc} zPercAcres
//Busca o percentual de Acrescimo.
@author Evandro Mariano
@since 06/05/2022
@version undefined
@param _aMsg, array, descrição
@type function
/*/
Static Function zPercAcres(_cMarcaOrc,_cTipoPed,_cCliente,_cLoja)

Local _nRet			:= 0
Local _aTpAcres		:= Separa(AllTrim(SuperGetMV( "CMV_WSR031"  ,,"003|5")),";" )
Local _cMarcaAcres	:= AllTrim(SuperGetMV( "CMV_WSR032"  ,,"CHE"))
Local _nX			:= 0
Local _cTipoOrc		:= AllTrim(Posicione("VX5", 1, XFilial("VX5") + "Z02" + PadR( AllTrim(_cTipoPed), TamSX3("VX5_CODIGO")[1] ), "VX5_DESCRI")) //Tipo do Orçamento (Venda/Transferencia/Remessa)
Local _cCnpjTransf  := AllTrim(SuperGetMV( "CMV_WSR019"  ,,"03471344"))	//Raiz CNPJ de transferencia
Local _cBxInter 	:= AllTrim(SuperGetMV( "CMV_WSR027"  ,,"013"))		//Código Baixa Interna
Local _cZFVenda		:= AllTrim(SuperGetMV( "CMV_WSR021"  ,,"AC|93;AP|92;AM|93;RO|93;RR|93"))	//Zona Franca - Venda
	
If _cTipoOrc == "VENDA"
		
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(XFilial("SA1") + _cCliente + _cLoja ))
		//1a - Regra - Prioridade Transferencia
		If !(Substring(SA1->A1_CGC,1,8) == _cCnpjTransf) //'03471344'
			If !(SA1->A1_EST) $ _cZFVenda
				If !(_cTipoPed == _cBxInter) //"013"
					If _cMarcaOrc $ _cMarcaAcres
						If _cTipoPed $ AllTrim(SuperGetMV( "CMV_WSR031"  ,,"003|5;"))
							For _nX := 1 To Len(_aTpAcres)
								If _cTipoPed $ _aTpAcres[_nX]
									_nRet := Val(Substr(_aTpAcres[_nX],At( "|", _aTpAcres[_nX] ) + 1 , 3 ))
								EndIf
							Next _nX
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return(_nRet)



/*/{Protheus.doc} ZPEC10Obri
//Verifica informações de campos obrigatórios 
@author DAC
@since 12/11/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/

Static Function ZPEC10Obri(_oJson, _lItem, _lTodos)
Local _lRet 	:= .T.
Local _xVar
Local _nPos
Local _cMsgRet
Local _nRet

Default _lItem 	:= .F.  //identifica se lera item ou cabeçalho
Default _lTodos	:= .F.	//determina se retornara todos os erros obrigatórios e ou somente o primeiro erro com obrigatório

Begin Sequence
	For _nPos := 1 To Len(_aRetMsg)
		//Caso seja obrigatório devo verificar se item ou cabeçalho  
		If _aRetMsg[_nPos,4] .And. ;
			((!_lItem .And. !_aRetMsg[_nPos,3]) .Or. (_lItem .And. _aRetMsg[_nPos,3]))  
			//armazeno em uma variavel para validar
			_xVar := _oJson:GetJsonText(_aRetMsg[_nPos,2])
			If ValType(_xVar) == "N" .and. _xVar == 0
				_lRet := .F.
			ElseIf ValType(_xVar) == "L" .and. Empty(_xVar) 
				_lRet := .F.
			ElseIf Empty(_xVar)
				_lRet := .F.
			EndIf
		EndIf
		If !_lRet
			_nRet := _aRetMsg[_nPos,1] 
			_cMsgRet := "Tag "+ _aRetMsg[_nPos,2]+" não esta preenchido !"	
			If Len(_aRetMsg[_nPos]) >= 5 .and. ValType(_aRetMsg[_nPos,5]) == "C" .and. !Empty(_aRetMsg[_nPos,5])
				_cMsgRet += " Ref. : "+_aRetMsg[_nPos,5]+" !" 
			EndIf
			Aadd(_aMsgRet, {_nRet,_cMsgRet})
			If !_lTodos  //verifica se lera todos os obrigatórios
				Break
			EndIF
		EndIf
	Next 			
End Sequence
Return _lRet



/*/{Protheus.doc} U_ZRETMsgJson
//Retorna Numero do Erro 
@author DAC
@since 12/11/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/
Static Function U_ZRETMsgJson(_cRefMsg, _cMsgRet)
Local _nRet := 999
Local _nPos

Default _cMsgRet := ""

Begin Sequence
  	_nPos := Ascan(_aRetMsg,{|x| x[2] == _cRefMsg})
	If _nPos > 0 
		_nRet := _aRetMsg[_nPos,1]
	EndIf	
	If Empty(_cMsgRet) .and. Len(_aRetMsg[_nPos]) >= 5 .and. ValType(_aRetMsg[_nPos,5]) == "C"
		_cMsgRet := _aRetMsg[_nPos,5]+" !"
	Endif	
	Aadd(_aMsgRet, {_nRet,_cMsgRet})
End Sequence
Return _nRet

/*/{Protheus.doc} ZPEC10AMsg
//Carrega Numero do Erro para retorno
@author DAC
@since 12/11/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/
Static Function ZPEC10AMsg()
Local _aRet := {}
Begin Sequence

/*
* Exemplo: 
Erros no formato 4XX (Erros relativos a autenticação)
                                400, Empresa inválida
401, Filial inválida
402, Token inválido
403, TenantId inválido
                Erros no formato 5XX (Erros relativos ao cadastro)
500, Cliente não cadastrado
501, Usuário não cadastrado
                Erros no formato 6XX (Erros relativos ao pedido)
600, Código do pedido
601, CNPJ/CPF inválido
602, Data do pedido
603, Valor total do orçamento
604, Código da peça
605, Quantidade da peca
606, Valor da peça
607, Valor total do item 
608, Orçamento já cadastrado
609, Orçamento não cadastrado
610, Não gravou (problemas contatar Adm)
                Erros no formato 7XX (Erros relativos as tabelas de de/para)
701, Marca não cadastrada
702, Tipo de pedido não cadastrado
703, Condição de pgto. não cadastrado
704, Tipo de transportadora não cadastrado
705, Tipo de frete não cadastrado

*/
	//			Nr Ret	Tags Json				Item	Obrig	Descrição	
	Aadd(_aRet, {100,	"ok"					, .F.	, .F., 	"Processo realizado com sucesso"})
	Aadd(_aRet, {200,	"existeorc"				, .F.	, .F., 	"Orçamento ja cadastrado, o mesmo ja foi enviado !"})
	Aadd(_aRet, {201,	"nexisteorc"			, .F.	, .F., 	"Orçamento não cadastrado, não será possivel alteração do mesmo !"})

	Aadd(_aRet, {300,	"noksa1"				, .F.	, .F., 	"Cliente não cadastrado"})
	Aadd(_aRet, {301,	"usuario"				, .F.	, .F., 	"Usuário não cadastrado"})

	Aadd(_aRet, {400,	"cEmpresa"				, .F.	, .T., 	"Empresa"})
	Aadd(_aRet, {401,	"cFilAtu"				, .F.	, .T., 	"Filial"})
	Aadd(_aRet, {402,	"cToken"				, .F.	, .T., 	"Token"})
	
	Aadd(_aRet, {600,	"cdPedido"				, .F.	, .T., 	"Pedido"})
	Aadd(_aRet, {601,	"cnpj"					, .F.	, .T., 	"CNPJ/CPF"})
	Aadd(_aRet, {602,	"dtPedido"				, .F.	, .T., 	"Data do pedido"})
	Aadd(_aRet, {603,	"vlTotal"				, .F.	, .T., 	"Valor total do orçamento"})
	Aadd(_aRet, {604,	"cdPeca"				, .T.	, .T., 	"Código da peça não cadastrado"})
	Aadd(_aRet, {605,	"quantidade"			, .T.	, .T., 	"Quantidade da peca não informada"})
	Aadd(_aRet, {606,	"vlPeca"				, .T.	, .T., 	"Valor da peça não informado"})
	Aadd(_aRet, {607,	"vlTotal"				, .T.	, .T., 	"Valor Total do item não informado"})
	Aadd(_aRet, {608,	"noGrava"				, .F.	, .F., 	"Não gravou"})
	Aadd(_aRet, {609,	"noItensOrc"			, .T.	, .F., 	"Não forão enviados itens do orçamento"})
	Aadd(_aRet, {610,	"cdPedidoCAOA"			, .F.	, .F., 	"Problemas com numeração CAOA, comunicar o ADM Sistemas CAOA !"})
	Aadd(_aRet, {611,	"vlDesconto"			, .F.	, .F., 	"Valor desconto não é valido !"})


	Aadd(_aRet, {701,	"cdMarca"				, .F.	, .F., 	"Não existe marca"})
	Aadd(_aRet, {702,	"cdTipoPedido"			, .F.	, .T., 	"Tipo deo pedido"})
	Aadd(_aRet, {703,	"cdCondicaoPagamento"	, .F.	, .T., 	"Condição de pgto"})
	Aadd(_aRet, {704,	"cdTransporte"			, .F.	, .F., 	"Transportadora não cadastrada"})
	Aadd(_aRet, {705,	"cdFrete"				, .F.	, .T., 	"Tipo de frete não Cadastrado"})
	Aadd(_aRet, {706,	"cdTipoTransporte"		, .F.	, .T., 	"Tipo de Transportadora não cadastrada"})
End Sequence
Return _aRet

/*---------------------------------------------------------------------------------------
{Protheus.doc} XGRJSONVS1
Funcionalidade responsavel pela gravação de erros caso exista
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC - Denilso Almeida Carvalho 20/03/2017
@version    Nao Informado
@since      Nao Informado  
@return    	Nil
@sample     Nao Informado
@obs        
@project    
@menu       Nao Informado
@history    
//MakeDir( < cPath >, [ uParam2 ], [ lChangeCase ] 
---------------------------------------------------------------------------------------*/
Static Function XGRJSONVS1(_cPedido, _oJson, _lJob ) 
Local _lRet 	:= .T.
Local _cMsg		:= ""
local _cDir     := AllTrim(SuperGetMV( "CMV_PEC026"  ,,"\autoware\importa\orc" ))       //processamento
Local _cDirDocs := MsDocPath()
Local _cExtenc	:= ".json"
Local _cRef		:= "AWRORC"
Local _nPos
Local _nHd1
Local _cArqAW

//Local _cPath 	 := AllTrim(GetTempPath())  //define o diretório na maquina cliente onde será gravado o arq excell "C:\Users\DAC\AppData\Local\Temp\"

Default _lJob	:= .T.

Begin Sequence  
	If SubsTr(_cDir,1,1) <> "\"
		_cDir := "\"+_cDir	
	Endif
	If SubsTr(_cDir,Len(_cDir),1) <> "\"
		_cDir := _cDir+"\"	
	Endif

	If !U_XVALIDPasta( {_cDirDocs+_cDir}, _lJob )
		_cMsg := "ZPECF010 [XGRJSONVS1] - Não foi possivel criar pasta "+_cDirOri+" e nem recriar a mesmapara Json para o Pedido "+_cPedido
		Break
	Endif	
	_cDirOri := _cDirDocs+_cDir
	If !ExistDir( _cDirOri )
		_cMsg := "ZPECF010 [XGRJSONVS1] - Não foi possivel criar pasta "+_cDirOri+" para Json para o Pedido "+_cPedido
		Break
	EndIf 
	_cArqAW := _cPedido+_cRef+DtOS(Date())+SubsTr(Time(),1,2)+SubsTr(Time(),4,2)
	If File(_cDirOri+_cArqAW)
		_lRet := .F.
		//Caso exista o arquivo nomeio gravar a data com os segundos
		For _nPos := 1 To 50
			_cArqAW :=  _cPedido+_cRef+DtOS(Date())+SubsTr(Time(),1,2)+SubsTr(Time(),4,2)+SubsTr(Time(),8,2)
			If !File(_cDirOri+_cArqAW)
				_lRet := .T.
				exit
			Endif
		Next
	Endif
	If !_lRet 
		_cMsg := "ZPECF010 [XGRJSONVS1] - Não foi possivel criar arquivo "+_cDirOri+_cArqAW+" para Json para o Pedido "+_cPedido
		Conout(_cMsg)
		Break
	EndIf
	//Se for para gravar arquivo
	_cArqAW := _cArqAW+_cExtenc
	_nHd1 := FCreate(_cDirOri+_cArqAW )	                            
 	If _nHd1 == -1              
 		_cMsg := "ZPECF010 [XGRJSONVS1] - Nao foi possivel criar o arquivo de Log para arquivo "+_cDirOri+_cArqAW+". Verifique com ADM Sistema!"
		Conout(_cMsg)
  		Break
	Endif
   	//Se pGravou arquivo popular o mesmo
	_cJson 	:= _oJson:toJSON()
	_cJson 	:= EncodeUTF8( _cJson )
	If !FGravaTxt( _cJson, _nHd1 )
		_cMsg := "ZPECF010 [XGRJSONVS1] - Não foi possivel gravar o arquivo Json para o Pedido "+_cPedido
		Conout(_cMsg)
	Endif
	Fclose(_nHd1)  //fecha o arquivo
End Sequence
Return _cMsg

//=========================================
//grava o TXT
Static Function fGravaTxt( _cLin, _nHdl )
//=========================================
_cLin += CRLF
If fWrite(_nHdl, _cLin, Len(_cLin)) != Len(_cLin)
	Return .f.
Endif
Return .T.


/*/{Protheus.doc} U_ZRETMsgJson
//Retorna Numero do Erro 
@author DAC
@since 14/07/2022
@version undefined
@param 		_aDir = Matriz com o nome das pastas ex {"import\empresa\pedido"}
			_lJob = Indica se esta processando em job e ou poderá mostrar msg na tela defaulf .T.
@type function
/*/
Static Function XVERPasta(_aDir,_lJob)
Local _aPasta   := {}                    
Local _nPos     
Local _nTam
Local _nCount
Local _cVar
Local _lRet  	:= .F. 

Default _lJob 	:= .T.

Begin Sequence
    If Len(_aDir) == 0               
    	If _lJob
    		Conout("[XVERPasta] Não existe pasta informadas nos parâmetros verificar")
		Else
			Aviso("ATENCAO","Não existe pasta informadas nos parâmetros verificar [XVERPasta] !",{"Sair"})
		Endif
		Break
    Endif
	For _nPos 	:= 1 To Len(_aDir) 
		_cArq 	:= _aDir[_nPos] 
	  	_nTam 	:= Len(_cArq)
	  	_cVar 	:= ""  
	  	_aPasta := {}
		For _nCount := 1 To Len(_cArq)
		   If SubsTr(_cArq,_nCount,1) == "\" .and. !Empty(_cVar)
				Aadd(_aPasta,_cVar)        
				_cVar := ""
				Loop
		   Endif
		   _cVar +=	SubsTr(_cArq,_nCount,1)
		Next	
		Aadd(_aPasta,_cVar) 
		If Len(_aPasta) == 0                                                     
			If _lJob
				Conout("[XVERPasta] Não existe pasta informadas nos parâmetros verificar !")
    		Else
				Aviso("ATENCAO","Não existe pasta informadas nos parâmetros verificar [XVERPasta] !",{"Sair"})
			Endif
			Break
		Endif       
		_cVar := ""
		For _nCount := 1 To Len(_aPasta)
			If Empty(_aPasta[_nCount])
				Loop			
			Endif
			If _nCount <> Len(_aPasta)
				_cVar += ( _aPasta[_nCount] + "\" )
			Else
				_cVar += (_aPasta[_nCount])							
			Endif 		
			If !ExistDir( _cVar )
				If MakeDir( _cVar ) != 0                                       
					If _lJob                                                     
						Conout("[XVERPasta] Não foi possivel cria a pasta "+_cVar)
					Else						
						Aviso("ATENCAO","Não foi possivel cria a pasta "+_cVar +" [XVERPasta] !",{"Sair"})
					Endif
					Break
				Endif				
			Endif
		Next
	Next
	_lRet := .T.
End Begin
Return _lRet							



/* DOCUMENTO

{
  "cFilAtu": "2020012001",
  "cEmpresa": "02",
  "cToken": "HOM_AUTOWAREXTOTVS",
  "cdPedido": "50000431",
  "cnpj": "03471344000177",
  "os": "",
  "dtPedido": "2022-09-09T15:33:24-03:00",
  "cdTipoPedido": "003",
  "cdTransportadora": "10213051001399",
  "cdFrete": "C",
  "cdCondicaoPagamento": "025",
  "cdTipoTransporte": "002",
  "comentario": "Pedido 50000425. Empresa 000814/01 - CAOA MONTADORA DE VEICULOS LTDA CNPJ: 03471344000177",
  "cdMarca": "CHE",
  "cdTpCliente": 1,
  "vlTotal": 1360.04,
  "itens": [
    {
      "cdPeca": "480-1012010",
      "quantidade": 2,
      "vlPeca": 23.03,
      "vlTotal": 46.06
    },
    {
      "cdPeca": "481H-1002041",
      "quantidade": 2,
      "vlPeca": 2.8,
      "vlTotal": 5.6
    },
    {
      "cdPeca": "A11-2803551",
      "quantidade": 2,
      "vlPeca": 7.26,
      "vlTotal": 14.52
    },
    {
      "cdPeca": "B14-2803911",
      "quantidade": 2,
      "vlPeca": 9.74,
      "vlTotal": 19.48
    },
    {
      "cdPeca": "F4J16-3707010",
      "quantidade": 2,
      "vlPeca": 28.17,
      "vlTotal": 56.34
    },
    {
      "cdPeca": "FQ146D0620F31E",
      "quantidade": 2,
      "vlPeca": 4.95,
      "vlTotal": 9.9
    },
    {
      "cdPeca": "FQ2B24819F38",
      "quantidade": 2,
      "vlPeca": 7.25,
      "vlTotal": 14.5
    },
    {
      "cdPeca": "J28-7900017",
      "quantidade": 2,
      "vlPeca": 247.27,
      "vlTotal": 494.54
    },
    {
      "cdPeca": "J68-2803012",
      "quantidade": 2,
      "vlPeca": 7.86,
      "vlTotal": 15.72
    },
    {
      "cdPeca": "Q140B0615F38L",
      "quantidade": 2,
      "vlPeca": 4.95,
      "vlTotal": 9.9
    },
    {
      "cdPeca": "S11-1117110",
      "quantidade": 2,
      "vlPeca": 22.52,
      "vlTotal": 45.04
    },
    {
      "cdPeca": "T15-1109111",
      "quantidade": 2,
      "vlPeca": 88.76,
      "vlTotal": 177.52
    },
    {
      "cdPeca": "T21-8402225",
      "quantidade": 2,
      "vlPeca": 7.18,
      "vlTotal": 14.36
    },
    {
      "cdPeca": "802000021AA",
      "quantidade": 2,
      "vlPeca": 116.75,
      "vlTotal": 233.5
    },
    {
      "cdPeca": "BT15-4421011",
      "quantidade": 2,
      "vlPeca": 68.33,
      "vlTotal": 136.66
    },
    {
      "cdPeca": "025CHA-1506531",
      "quantidade": 2,
      "vlPeca": 9.95,
      "vlTotal": 19.9
    },
    {
      "cdPeca": "B31314T8000",
      "quantidade": 2,
      "vlPeca": 23.25,
      "vlTotal": 46.5
    }
  ]
}
*/
