#INCLUDE "TOTVS.CH"
#Include "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} ZPECF011
Serviço de integração Cadastro de Clientes 
Atualização da separação dos orçamentos baixando conforme informaçção recebida
@author 	DAC 
@since 		20/03/2024
@version 	undefined
@param		nao utilizado
@type 		User Function
@client   	CAOA BARUERI
@return   	_aMsg - Array com retorno Json código e ocorrencia
@project 	GAP136  API Cadastro de Cliente
			https://tdn.totvs.com/display/tec/DecodeUTF8
			https://jsonformatter.curiousconcept.com/  VERIFICAR SE JSON ESTA CORRETO
			https://jsonlint.com/?code=   //VALIDAR JSON
            https://jsoneditoronline.org/#left=local.sowavu  //estrutura do json
/*/

User Function ZRESTSA1(_oJson, _cEmpFil, _cResp)
Local _aMsg		:= {}

Private _aRetMsg := ZRESTSA1Msg()   //Carregar tabela com erros
Private _aMsgRet := {}				//carregar msg de errp

Default _cEmpFil	:= ""
Default _cResp		:= ""

Begin Sequence
	Conout("INICIANDO FUNCIONALIDADE ZRESTSA1 em "+DtoC(Date())+" as "+Time())
	_aMsgRet 	:= {}

    If ZRESTSA1PR( @_oJson, _cEmpFil, _cResp )
		U_ZRETMsgJson("ok", "Atualizacao realizada com Sucesso !")
		_aMsg := U_ZSetMsgJson()
	Else
		_aMsg := U_ZSetMsgJson()
	Endif

End Sequence

IF Len(_aMsg) == 0 		//Prevensão forçar o envia da mensagem para o REST
	_aMsg := U_ZSetMsgJson()
EndIf

Conout("TERMINO FUNCIONALIDADE ZRESTSA1 em "+DtoC(Date())+" as "+Time())
Return _aMsg


/*/{Protheus.doc} ZRESTSA1PR
Recebe 		Json CLIENTE PUT 
@author 	DAC
@since 		20/03/2024
@version 	undefined
@param 		oJson
@type 		function
@ Obs		Os paremetros de token, empresa e filial serão enviados no cabeçalho reader Json
/*/
Static Function ZRESTSA1PR( _oJson, _cEmpFil, _cResp )
Local _cEmpresa     := ""
Local _cFilAtu      := ""
Local _lRet			:= .F.
//Local _cRespLib		:= AllTrim( superGetMv( "CAOA_RES03"	, , "00000000"		) )	

Local _nPos
Begin Sequence
	_nPos := At(",", _cEmpFil)
	If _nPos <= 0 
		U_ZRETMsgJson("empresa","nao informada tag empresa")
        Break
    EndIf
	_cEmpresa := SubsTr(_cEmpFil,1,_nPos-1)
	_cFilAtu  := SubsTr(_cEmpFil,_nPos+1)

	If Empty(_cEmpresa)
		U_ZRETMsgJson("empresa","nao informada tag empresa")
        Break
	Endif
	If Empty(_cFilAtu)
		U_ZRETMsgJson("filial","nao informada a filial na tag empresa")
        Break
	Endif
	//Verifica a existencia empresa, para não ficar retornando erro 5, valida se a tabela esta abertar
	If Select("SM0") > 0
		SM0->(DbSetOrder(1))  //M0_CODIGO+M0_CODFIL
		If !SM0->(DbSeek(_cEmpresa+_cFilAtu))
			U_ZRETMsgJson("empresa","Dados da empresa inconsistentes")
        	Break
		Endif
	Endif
    //Tratar abertura da empresa conforme enviado no parametro
	If cEmpAnt <> _cEmpresa .or. cFilAnt <> _cFilAtu
    	RpcClearEnv() 
    	RPCSetType(3) 
    	If !RpcSetEnv(_cEmpresa,_cFilAtu,,,,GetEnvServer(),{ })
			U_ZRETMsgJson("ambiente","Nao foi possivel acessar ambiente")
        	Break
		Endif
	EndIf
	//Valida se esta cadastrado 
	/*
	If !_cResp	$ _cRespLib //.Or. ("_PRD" $ AllTrim(GetEnvServer()) .And. _cResp == STRZero(0,8))
		U_ZRETMsgJson("responsavel","Rensponsavel nao Autorizado")
        Break
	Endif
	*/
	//Verificar se existe cadastro Gornecedor , o Genérico não sendo 
	SA2->(DbSetOrder(3))  //FILIAL + CGC
	// Valida os dados do oJson
	If !SA2->(DbSeek(FWxFilial("SA2")+_cResp))  //.And. _cResp <> STRZero(0,8)  //Deixar passar com tudo zero para validaçoes
		U_ZRETMsgJson("responsavel","Nao Autorizado, Falta Cadastro")
        Break
	Endif 	
	If !ValidOJson(@_oJson,)
		Break
	EndIf
	//processa json
	_lRet := ZRESTSA1GR(_oJson, _cEmpresa, _cFilAtu, _cResp)

End Sequence
Return _lRet


/*/{Protheus.doc} ZRESTSA1GR
Gravar dados do oJson no Cliente
@author DAC - Denilso
@since 
@version undefined
@param 
@type function
/*/
Static Function ZRESTSA1GR(_oJson, _cEmpresa, _cFilAtu, _cResp)
Local _cAliasPesq	:= GetNextAlias()
Local _lRet 		:= .F.
Local _lNovo    	:= .T.
Local _cCodSegmento := AllTrim(SuperGetMV("CMV_JSA101",.F.,"06"))  			//"06 - PADRÃO"  //Código do Segmento Cliente
Local _cConta 		:= AllTrim(SuperGetMV("CMV_JSA102",.F.,"1120101001"))  	//Conta Contabil Padrão
Local _cGrpTrib     := AllTrim(SuperGetMV("CMV_JSA103",.F.,"FID"))  		//Grupo de Tributação Padrão

Local _cLoja
Local _cCnPjCpf
Local _cIERG
Local _cEndereco
Local _cMunicipio
Local _cCodMun
Local _cBloqueio
Local _cCodPais
Local _cCodBancen
Local _cContrib
Local _cReduzido
Local _cTipoCli

Local _oModel
Local _oSA1Mod
Local _aErro
Local _cStatus
Local _nPos
Local _aMsg
Local _aAlterado
Local _cComplemento

DbSelectArea("SA1")

Begin Sequence 
	//Verifica se existe cliente cadastrado
	_cCnPjCpf	:= AllTrim(_oJson:GetJsonText("cnpjcpf"))  

	//Função para retorno de códigos, verificar se existem pais estado e municipio, indiferente do cliente ser ou nao cadastrdos estas informações tem que estar fornecidas corretamente
	If !ZRESTSA1Valida(_oJson, @_cCodMun, @_cMunicipio, @_cCodPais, @_cCodBancen)
		Break
	Endif

	If Empty(_cCnPjCpf)
		U_ZRETMsgJson("cnpjcpf","CNPJ e CPF do Cliente nao informado")
		Break
	Endif

	SA1->(dbSetOrder(3))
    If SA1->( dbSeek( xFilial("SA1")+Padr( AllTrim(_cCnPjCpf), TamSX3("A1_CGC")[1] ) ) ) //Já existe o CNPJ cadastrado, somente altera
		_cCodCli	:= SA1->A1_COD
		_cLoja		:= SA1->A1_LOJA
		_cBloqueio  := SA1->A1_MSBLQL
		_lNovo      := .F.
		_cConta 	:= IIf(Empty(SA1->A1_CONTA),AllTrim(SuperGetMV("CMV_JSA102",.F.,"1120101001")), SA1->A1_CONTA)
		_cGrpTrib   := IIf(Empty(SA1->A1_GRPTRIB),AllTrim(SuperGetMV("CMV_JSA103",.F.,"FID")), SA1->A1_GRPTRIB) 
		_cContrib   := IIf(Empty(SA1->A1_CONTRIB),"1", SA1->A1_CONTRIB)
	Else
		If Select( (_cAliasPesq) ) > 0
			(_cAliasPesq)->(DbCloseArea())
		EndIf

		cQrySA1 := ""
		cQrySA1 += " SELECT TMP.A1_COD, TMP.A1_LOJA FROM ( 											"
		cQrySA1 += " 	SELECT * FROM " +  RetSQLName("SA1") +" SA1 								"
		cQrySA1 += " 	WHERE SA1.A1_FILIAL = '" + FWxFilial('SA1') + "'							"
		cQrySA1 += " 	AND SUBSTR(SA1.A1_CGC,1,8) = '" + Substring(_cCnPjCpf,1,8) + "' 			"
		cQrySA1 += " 	AND SA1.D_E_L_E_T_ = ' ' 													"
		cQrySA1 += " 	ORDER BY SA1.A1_LOJA DESC 													"
		cQrySA1 += " )TMP 																			"
		cQrySA1 += " WHERE ROWNUM = 1 																"

		// Executa a consulta.
		DbUseArea( .T., "TOPCONN", TcGenQry(,,cQrySA1), _cAliasPesq, .T., .T. )

		DbSelectArea((_cAliasPesq))
		(_cAliasPesq)->(dbGoTop())  

		If (_cAliasPesq)->(Eof()) 	
			_cCodCli    := GetSxeNum("SA1","A1_COD")
			_cLoja   	:= StrZero(1,Len(SA1->A1_LOJA))
		Else 
			//SA1->(DbGoto((_cAliasPesq)->NREGSA1))
			_cCodCli	:= (_cAliasPesq)->A1_COD
			_cLoja		:= Soma1((_cAliasPesq)->A1_LOJA)	
			_cBloqueio  := "1"
		Endif

		_cBloqueio  := "1"
		_lNovo      := .T.
		_cContrib   := "1"   //Verificar se é exportação testar quem é contribuinte 

		(_cAliasPesq)->(DbCloseArea())
	EndIf

	_cCnPjCpf	:= AllTrim(_oJson:GetJsonText("cnpjcpf"))  
	_cIERG 		:= AllTrim(_oJson:GetJsonText("ierg"))
	_cEndereco	:= FwNoAccent(Upper(AllTrim(_oJson:GetJsonText("endereco"))))  //+ If(!Empty(_oJson:GetJsonText("endnum")) , ", "+ AllTrim(_oJson:GetJsonText("endnum")),"" )
	_cReduzido 	:= FwNoAccent(Upper(AllTrim(_oJson:GetJsonText("reduzido"))))
	_cTipoCli 	:= Upper(AllTrim(_oJson:GetJsonText("tipocli")))	
	//Caso nao tenha enviado nome reduzido reproduzo o nome
	If Empty(_cReduzido) .Or. _cReduzido == "NULL"
		_cReduzido 	:= FwNoAccent(Substr(Upper(AllTrim(_oJson:GetJsonText("nome"))),1,20))
	Endif
  
	_aAlterado := {}  //indicação de alteração do campo
	_oModel := FWLoadModel("CRMA980") //"MATA030" na antiga MATA030
	_oModel:SetOperation(If(_lNovo,MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE))
	_oModel:Activate()
  
	//Pegando o model dos campos da SA1
	_oSA1Mod:= _oModel:getModel("SA1MASTER") //"MATA030_SA1" na antiga MATA030
	//_oSA1Mod:setValue("A1_COD"		, _cCodCli        									) // Codigo 
	//_oSA1Mod:setValue("A1_LOJA"		, _cLoja     
	If _lNovo
		ZRESTSA1Alterados(	"A1_FILIAL"		, FWxFilial('SA1')									, @_oSA1Mod, @_aAlterado, _lNovo )   // Nome
		ZRESTSA1Alterados(	"A1_COD"		, _cCodCli											, @_oSA1Mod, @_aAlterado, _lNovo )   // Nome
		ZRESTSA1Alterados(	"A1_LOJA"		, _cLoja											, @_oSA1Mod, @_aAlterado, _lNovo )   // Nome
	Endif
	ZRESTSA1Alterados(	"A1_NOME"		, FwNoAccent(Upper(AllTrim(_oJson:GetJsonText("nome"))))	, @_oSA1Mod, @_aAlterado, _lNovo )   // Nome
	ZRESTSA1Alterados(	"A1_NREDUZ" 	, _cReduzido   												, @_oSA1Mod, @_aAlterado, _lNovo )   //  Nome reduz.
	ZRESTSA1Alterados(  "A1_END"	 	, _cEndereco   												, @_oSA1Mod, @_aAlterado, _lNovo )   // Endereco
	ZRESTSA1Alterados(  "A1_BAIRRO" 	, FwNoAccent(Upper(AllTrim(_oJson:GetJsonText("bairro"))))	, @_oSA1Mod, @_aAlterado, _lNovo )   // Bairro
	_cComplemento :=  FwNoAccent(_oJson:GetJsonText("complemento"))
	If Valtype(_cComplemento) == "C" .Or. _cComplemento <>  'null' .Or. !Empty(_cComplemento)
		ZRESTSA1Alterados(  "A1_COMPLEM" 	, FwNoAccent(Upper(AllTrim(_cComplemento)))					, @_oSA1Mod, @_aAlterado, _lNovo )   // Complemento
	Endif
	ZRESTSA1Alterados(  "A1_CEP"		, AllTrim(_oJson:GetJsonText("cep"))        		, @_oSA1Mod, @_aAlterado, _lNovo )   // CEP
	ZRESTSA1Alterados(  "A1_TIPO"		, _cTipoCli    										, @_oSA1Mod, @_aAlterado, _lNovo )   // Tipo 
	ZRESTSA1Alterados(  "A1_EST"		, Upper(AllTrim(_oJson:GetJsonText("estado")))   	, @_oSA1Mod, @_aAlterado, _lNovo )   // Estado
	ZRESTSA1Alterados(  "A1_COD_MUN"	, _cCodMun     										, @_oSA1Mod, @_aAlterado, _lNovo )   // Codigo Municipio
	ZRESTSA1Alterados(  "A1_MUN"		, _cMunicipio    									, @_oSA1Mod, @_aAlterado, _lNovo )   // Municipio
	ZRESTSA1Alterados(  "A1_PAIS"		, _cCodPais    										, @_oSA1Mod, @_aAlterado, _lNovo )   // Pais         
	ZRESTSA1Alterados(  "A1_CODPAIS"	, _cCodBancen        								, @_oSA1Mod, @_aAlterado, _lNovo )   // Código Bacen 
	ZRESTSA1Alterados(  "A1_CGC"		, _cCnPjCpf 										, @_oSA1Mod, @_aAlterado, _lNovo )   // CNPJ/CPF            
	ZRESTSA1Alterados(  "A1_MSBLQL"	 	, _cBloqueio 										, @_oSA1Mod, @_aAlterado, _lNovo )   // Bloqueio Sim / Não   
	ZRESTSA1Alterados(  "A1_CODSEG"	 	, _cCodSegmento 									, @_oSA1Mod, @_aAlterado, _lNovo )   // Segmento            
	If Len(_cCnPjCpf) >= 14 .And. !Empty(_cIERG)
		ZRESTSA1Alterados(  "A1_INSCR"	, _cIERG 											, @_oSA1Mod, @_aAlterado, _lNovo )   // Inscricao Estadual            
	ElseIf !Empty(_cIERG) 
		ZRESTSA1Alterados(  "A1_RG"	 	, _cIERG 											, @_oSA1Mod, @_aAlterado, _lNovo )   // Registro Geral            
	Endif

	If Len(_cCnPjCpf) >= 14 .And. _cTipoCli <> "X"
		ZRESTSA1Alterados(  "A1_PESSOA"	, "J" 												, @_oSA1Mod, @_aAlterado, _lNovo )   // Tipo Pessoa Juridica            
	ElseIf _cTipoCli <> "X"
		ZRESTSA1Alterados(  "A1_PESSOA"	, "F" 												, @_oSA1Mod, @_aAlterado, _lNovo )   // Tipo Pessoa Fisica            
	Else   //POR ENQUANTO COLOCANDO COMO JURIDICA
		ZRESTSA1Alterados(  "A1_PESSOA"	, "J" 												, @_oSA1Mod, @_aAlterado, _lNovo )   // Tipo Pessoa Exterior            
	Endif									
	ZRESTSA1Alterados(  "A1_EMAIL"		, Lower(FwNoAccent(AllTrim(_oJson:GetJsonText("email"))))       		, @_oSA1Mod, @_aAlterado, _lNovo )   // E-Mail       
	ZRESTSA1Alterados(  "A1_DDD"		, AllTrim(_oJson:GetJsonText("ddd"))        		, @_oSA1Mod, @_aAlterado, _lNovo )   // DDD               
	ZRESTSA1Alterados(  "A1_TEL"		, AllTrim(_oJson:GetJsonText("fone"))   			, @_oSA1Mod, @_aAlterado, _lNovo )   // Fone              
	ZRESTSA1Alterados(  "A1_CONTATO"	, FwNoAccent(Upper(AllTrim(_oJson:GetJsonText("contato"))))		, @_oSA1Mod, @_aAlterado, _lNovo )   // Contato           
	ZRESTSA1Alterados(  "A1_CONTA"		,_cConta   											, @_oSA1Mod, @_aAlterado, _lNovo )   // Conta contabil               
	ZRESTSA1Alterados(  "A1_GRPTRIB"	,_cGrpTrib    										, @_oSA1Mod, @_aAlterado, _lNovo )   // Grupo de tributação          
	ZRESTSA1Alterados(  "A1_CONTRIB"	,_cContrib    										, @_oSA1Mod, @_aAlterado, _lNovo )   // Contribuinte Sim Não         
	If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
		ZRESTSA1Alterados(  "A1_XINTEG"		,"X"	        									, @_oSA1Mod, @_aAlterado, _lNovo )   // Registro Integrado S=Integra RgLog;N=Nao Integra RgLog;X=Integrado RgLog                                                                                    
	EndIf
  
	//Se conseguir validar as informações
	_lRet := _oModel:VldData()
	If _lRet 
    	//Tenta realizar o Commit
    	_lRet := _oModel:CommitData()
	Endif	
    If !_lRet

		RollBackSX8()	

		//Busca o Erro do Modelo de Dados
    	_aErro := _oModel:GetErrorMessage()
		/*
    	//Monta o Texto que será mostrado na tela
    	AutoGrLog("Id do formulário de origem:"  + ' [' + AllToChar(_aErro[01]) + ']')
    	AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(_aErro[02]) + ']')
    	AutoGrLog("Id do formulário de erro: "   + ' [' + AllToChar(_aErro[03]) + ']')
    	AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(_aErro[04]) + ']')
    	AutoGrLog("Id do erro: "                 + ' [' + AllToChar(_aErro[05]) + ']')
    	AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(_aErro[06]) + ']')
   		AutoGrLog("Mensagem da solução: "        + ' [' + AllToChar(_aErro[07]) + ']')
    	AutoGrLog("Valor atribuído: "            + ' [' + AllToChar(_aErro[08]) + ']')
    	AutoGrLog("Valor anterior: "             + ' [' + AllToChar(_aErro[09]) + ']')
    	//Mostra a mensagem de Erro
    	//MostraErro()
		*/
		U_ZRETMsgJson("erropad",AllTrim(FwNoAccent( AllToChar(_aErro[06])))+" | "+AllTrim(FwNoAccent( AllToChar(_aErro[04]))))
	Else 
		ConfirmSX8()
	Endif
	//Desativa o modelo de dados
	_oModel:DeActivate()
End Sequence

_aMsg 		:= {}
_aCampos	:= {}
If _lRet 
	_cStatus 	:=	"1"
	_aMsg 		:=  {"Cliente "+If(_lNovo,"Recebido","Alterado")+" com Sucesso"}
	//Indica que alterou campos
	If Len(_aAlterado) > 0 
		_cMsg 	:= "Alteracoes cadastro de Clientes Recponsavel "+_cResp+" em "+DtOC(Date())+" - "+Time()
		_cMsg 	+= CRLF
		For _nPos := 1 To Len(_aAlterado)
			_cMsg += _aAlterado[_nPos] +CRLF
		Next 
		//Adiciono para gravar msgem de alteração
		AAdd(_aCampos,{"Z1_MSGLOG"	, Upper(_cMsg)	})
	Endif 
	//Devido estar retornando como X que é o identificador para RGLOG SIGAPEC
	//Tem que integrar RGLOG
	If RecLock("SA1",.F.)
		If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
			If SA1->A1_XINTEG  <> "X"
				SA1->A1_XINTEG := "X"
			Endif	
		EndIf
		If _lNovo
			SA1->A1_CONTA	:= ""
			SA1->A1_GRPTRIB	:= ""
			SA1->A1_CONTRIB	:= ""
			SA1->A1_MSBLQL	:= "1"	//deixar bloqueado após o recebimento
		Endif
		SA1->(MsUnlock())
	Endif 

Else 
	_cStatus 	:=	"2"
	For _nPos := 1 To Len(_aMsgRet)
		Aadd(_aMsg,_aMsgRet[_nPos,2])
	Next
Endif 

Return _lRet 

//Valida campos enviados no REST
Static Function ZRESTSA1Valida(_oJson, _cCodMun, _cMunicipio, _cCodPais, _cCodBancen)
Local _cAliasPesq   := GetNextAlias()
Local _lRet := .T.
Local _cUf			:= Upper(AllTrim(_oJson:GetJsonText("estado")))
Local _cTipoCli 	:= Upper(AllTrim(_oJson:GetJsonText("tipocli")))
Local _aRetX3 		:= RetSX3Box(GetSX3Cache("A1_TIPO", "X3_CBOX"),,,1)  //trazer opções de tipo de clientes
Local _cEmail 		:= FwNoAccent(Lower(AllTrim(_oJson:GetJsonText("email"))))

Default _cMunicipio	:= ""
Default _cCodBancen	:= ""

Begin Sequence 
	_cCodMun	:= Upper(AllTrim(_oJson:GetJsonText("codmunicipio")))
 	_cCodPais	:= Upper(AllTrim(_oJson:GetJsonText("codpais")))

	//Valido o tipo de Cliente 
	If Ascan(_aRetX3, { |x| x[2] == _cTipoCli }) == 0
		U_ZRETMsgJson("tipocli","Tipo de Cliente "+tipocli+" nao localizado")
		_lRet := .F.
		Break
 	Endif

	//Valida E-mail
	If !Empty(_cEmail)
		If At("@",_cEmail) == 0 .Or. (At(".com",_cEmail) == 0 .And. At(".gov",_cEmail) == 0 ) 
			U_ZRETMsgJson("email","E-mail do cliente  "+_cEmail+" informado esta invalido")
			_lRet := .F.
			Break
		Endif
	Endif

	//Verificar municipio estado e pais
	//1200013
	_cCodMun := SubsTr(_cCodMun,3,5)
	BeginSql Alias _cAliasPesq
		SELECT CC2.R_E_C_N_O_ AS NREGCC2  
		FROM %Table:CC2% CC2
       	WHERE CC2.CC2_FILIAL  	= %XFilial:CC2%
			AND CC2.CC2_CODMUN 	= %Exp:_cCodMun%
			AND CC2.CC2_EST 	= %Exp:_cUf%
		  	AND CC2.%notDel%		  
	EndSql      
	//CC2.CC2_CODMUN
	//			AND CC2.CC2_MUN 	= %Exp:_cMunicipio%
	If ( (_cAliasPesq)->(Eof()) .Or. (_cAliasPesq)->NREGCC2 == 0 ).and. _cTipoCli <> "X"  //para exterior pode estar sem municipio 
		U_ZRETMsgJson("municipio","Municipio codigo "+_cCodMun+" com estado "+_cUf+" nao localizado")
		_lRet := .F.
		Break
	Endif
	CC2->( DbGoto((_cAliasPesq)->NREGCC2 ))
	_cCodMun 	:= CC2->CC2_CODMUN
	_cMunicipio	:= CC2->CC2_MUN //Upper(AllTrim(_oJson:GetJsonText("municipio")))
	
	(_cAliasPesq)->(DbCloseArea())
	BeginSql Alias _cAliasPesq
		SELECT 	SYA.R_E_C_N_O_ AS NREGSYA 
       	FROM %table:SYA% SYA
       	WHERE SYA.YA_FILIAL  	= %XFilial:SYA%
			AND SYA.YA_CODGI 	= %Exp:_cCodPais%
		  	AND SYA.%notDel%		  
	EndSql      
	//SYA.YA_CODGI, SYA.YA_SISEXP,
	If (_cAliasPesq)->(Eof()) .Or. (_cAliasPesq)->NREGSYA == 0
		U_ZRETMsgJson("pais","Codigo do Pais "+_cCodPais+" nao localizado")
		_lRet := .F.
		Break
	Endif
	SYA->( DbGoto((_cAliasPesq)->NREGSYA) )
	_cCodPais 	:= SYA->YA_CODGI
	_cCodBancen	:= "0"+SYA->YA_SISEXP
End Sequence 

If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 

Return _lRet


//Verifica campos alterados no REST caso seja alteração
Static Function ZRESTSA1Alterados( _cCampo, _xConteudo, _oSA1Mod, _aAlterado, _lNovo )
Local _lRet 		:= .T.
Local _cConteudo	:= ""
//Local _nTam 	:= _oSA1Mod:adatamodel[1]  //_oSA1Mod:GetFields()
Begin Sequence 
	_oSA1Mod:setValue(_cCampo	, _xConteudo )              
    //Registro novo não guardar alterações
	If _lNovo
		Break 
	Endif
	//Retiro os espaços quando caracter para não ocorrerem diferenças em relação ao tamanho
	//_oSA1Mod:GetValue(_aField[_nPos,3])
	If ValType(_xConteudo) == "N"
		_xConteudo := AllTrim(Str(_xConteudo))
		_cConteudo := AllTrim(Str(SA1->(FieldGet(FieldPos(_cCampo)))))
	ElseIf ValType(_xConteudo) == "D"
		_xConteudo := AllTrim(DtoC(_xConteudo))
		_cConteudo := AllTrim(DtoC(SA1->(FieldGet(FieldPos(_cCampo)))))
	ElseIf ValType(_xConteudo) == "L"
		If _xConteudo
			_xConteudo := "VERDADEIRO"
		Else	
			_xConteudo := "VERDADEIRO"
		Endif 
		If SA1->(FieldGet(FieldPos(_cCampo)))
			_cConteudo := "VERDADEIRO"
		Else	
			_xConteudo := "FALSO"
		Endif 
	Else 
		_xConteudo := AllTrim(_xConteudo)
		_cConteudo := SA1->(AllTrim(FieldGet(FieldPos(_cCampo))))
	Endif 	 
	If _xConteudo <> _cConteudo
		Aadd(_aAlterado,"REGISTRO "+_cCampo+" ALTERADO ANTES : "+_cConteudo+" ALTERADO PARA : "+_xConteudo) 
	Endif 
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
Local _lRet		:= .T.
Local _aMens 	:= {}
 	//Tem a função de validar os itens obrigatórios neste caso o vabeçalho ZWSRFUN.PRW
	_aMens := U_ZVLDOBRJ(_oJson, _aRetMsg, /*_lItem*/, /*_lTodos*/)
	If Len(_aMens) > 0
	  	_aMsgRet 	:= _aMens
		_lRet		:= .F.	
	Endif
Return _lRet



/*/{Protheus.doc} ZRESTSA1Msg
//Carrega Numero do Erro para retorno
@author DAC
@since 12/11/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/
Static Function ZRESTSA1Msg()
Local _aRet := {}
Begin Sequence
	//			Nr Ret	Tags Json			Item	Obrig	Descrição	
	Aadd(_aRet, {100,	"ok"				, .F.	, .F., 	"Processo realizado com sucesso"})

	Aadd(_aRet, {300,	"empresa"			, .F.	, .F., 	"Empresa nao informada"})
	Aadd(_aRet, {301,	"filial"			, .F.	, .F., 	"Filial nao informada"})
	Aadd(_aRet, {302,	"token"				, .F.	, .F., 	"Token Invalido"})
	Aadd(_aRet, {303,	"ambiente"			, .F.	, .F., 	"Nao foi possivel acessar ambiente"})
	Aadd(_aRet, {304,	"responsavel"		, .F.	, .F., 	"Não Autorizado"})

	Aadd(_aRet, {400,	"cnpjcpf"			, .F.	, .T., 	"CNPJ e OU cpf COM problemas"})
	Aadd(_aRet, {401,	"nome"				, .F.	, .T., 	"Nome do Cliente com problemas"})
	Aadd(_aRet, {402,	"ierg"				, .F.	, .F., 	"Inscricao Estadual e ou R.G. com problemas"})
	Aadd(_aRet, {403,	"cep"				, .F.	, .F., 	"Cep do Cliente com problemas"})
	Aadd(_aRet, {404,	"endereco"			, .F.	, .T., 	"Endereço do Cliente com problemas"})
	Aadd(_aRet, {405,	"municipio"			, .F.	, .F., 	"Municipio do Cliente com problemas"})
	Aadd(_aRet, {406,	"estado"			, .F.	, .F., 	"Estado do Cliente com problemas"})
	Aadd(_aRet, {407,	"pais"				, .F.	, .T., 	"Pais do Cliente com problemas"})
	Aadd(_aRet, {408,	"email"				, .F.	, .F., 	"E-mail do Cliente com problemas"})
	Aadd(_aRet, {409,	"tipocli"			, .F.	, .T., 	"Tipo do Cliente com problemas"})

	Aadd(_aRet, {600,	"erropad"			, .F.	, .T., 	"nao foi possivel atualizar Cliente"})
End Sequence
Return _aRet



/*

{
    "cnpjcpf" : "99999999999999",
    "nome" : "Jose Aparecido da Silva", 
    "reduzido" : "Jose", 
    "ierg" : "999999999999999000",
    "cep" : "00000000",
    "endereco" : "Rua Logradouro",
    "endnum" :  2034,
    "complemento" : "Apto 32",
    "bairro" : "Lagoa",
    "municipio" : "Ribeirao Preto",
    "estado" : "SP",
    "pais" : "Brasil",
    "ddd" : "011",
    "fone" : "9999999999",
    "email" : "joseaparecido@email.com.br",
    "contato" : "Jose Aparecido",
    "tipocli" : "F",
}

*/



/*
=====================================================================================
Programa.:              ZPECAJ01Monitor
@param 					_cStatus   	= Status que será gerado no SZ1 1-OK 2-Divergência 
						_cTab		= Tabela principal que esta sendo gravada na integração
						_cDoc   	= Numero do Documento a ser gravado, ja contém a série 
						_cErro    	= mensagem a ser gravada podendo ser de erro e ou exito 
						_dDataIni	= data inicial da importação 
						_cHsIni 	= hora inicial da importação 
						_cJson    	= Json para importação
						_nErro		= numero de retorno que ocasionou erro e ou exito
Autor....:              CAOA - DAC Denilso 
Data		            14/11/2022
Descricao / Objetivo	Funcionalidade que efetuara a gravação de dados no monitor 
Doc. Origem            	PEC020 - Monitor de Integrações WIS
Solicitante            	CAOA
Uso              		ZWSR012
Obs
@menu       			Nao Informado
@return					_lRet 		- Verdadeiro ou falso
@history 				DAC - 	15/02/2023 
								Implementação de envio de campos a serem gravados para SZ1	
=====================================================================================
*/
Static Function	ZRESTSA1Monitor(_cStatus, _cTab, _cDoc, _cMens, _cErro, _dDataIni, _cHsIni, _nErro, _nReg )	
Local _cUserName := "REST ZRESTSA1"   
Local _aCampos	 := {}  //Adicionar campos a serem gravador na tabela DAC  15/02/2023 

Default _cTab 		:= "SA1"
Default _dDataIni	:= Date()
Default _cHsIni		:= Time()

	//AAdd(_aCampos,{"Z1_NTPINTG"	, "ZRESTSA1" 	})
	U_CAOAGRVM(XFilial(_cTab),;		//Filail
				_cStatus,;				//Status
				"100",;					//Código do Processo  REST IMPORTACAO CLIENTES                          
				/*cCodtpint*/,;			//Código do tipo
				Upper(_cErro),;			//Mensagem de retorno
				_cDoc,;					//Documento
				_dDataIni,;				//Data Inicio
				_cHsIni,;				//Hora Final
				Upper(_cMens),;			//Json
				If(_cStatus=="1", (_cTab)->(Recno()),0),; //Numero do Registro
				_cUserName,;			//Nome do Usuário na inclusão
				_nErro,;				//Retorno código
				_aCampos)				//Campos pré definidos para gravar no SZ1 
Return Nil

