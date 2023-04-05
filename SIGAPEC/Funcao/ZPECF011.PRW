#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#define CRLF chr(13) + chr(10)

Static _aRetMsg := ZPEC11AMsg()   	//Carregar tabela com erros
Static _aMsgRet := {}				//carregar msg de errp

/*/{Protheus.doc} ZPECF011
Serviço de integração RECEBIMENTO SEPARAÇÃO DE PEDIDOS rg log
Atualização da separação dos orçamentos baixando conforme informaçção recebida
@author 	DAC 
@since 		17/12/2021
@version 	undefined
@param		Não utilizado
@type 		User Function
@client   	CAOA BARUERI
@return   	_aMsg - Array com retorno Json código e ocorrencia
@project 	Interfaces_PortalV3_v2 x Protheus v2
			https://tdn.totvs.com/display/tec/DecodeUTF8
			https://jsonformatter.curiousconcept.com/  VERIFICAR SE JSON ESTA CORRETO
			https://jsonlint.com/?code=   //VALIDAR JSON
            https://jsoneditoronline.org/#left=local.sowavu  //estrutura do json
Z	-Customizado
PEC	- Modulo
F 	- Função
011 - Sequencial
/*/


User Function ZPECF011(_oJson)
Local _aMsg		:= {}

Begin Sequence
	Conout("INICIANDO FUNCIONALIDADE ZPECF011 em "+DtoC(Date())+" as "+Time())
	_aMsgRet 	:= {}
    If ZPECF011PR( @_oJson )
		ZPEC11RMsg("ok", "Atualização realizada com Sucesso !")
		_aMsg := SetMsgRet()
	Else
		_aMsg := SetMsgRet()
	Endif
End Sequence

IF Len(_aMsg) == 0 		//Prevensão forçar o envia da mensagem para o REST
	_aMsg := SetMsgRet()
EndIf

Conout("TERMINO FUNCIONALIDADE ZPECF011 em "+DtoC(Date())+" as "+Time())
Return _aMsg


/*/{Protheus.doc} ZPECF011PR
Recebe 		Json RG LOG PUT 
@author 	DAC
@since 		23/07/2021
@version 	undefined
@param 		oJson
@type 		function
@ Obs		Os paremetros de token, empresa e filial serão enviados no cabeçalho reader Json
/*/
Static Function ZPECF011PR( _oJson )
Local _cEmpresa     := "02"
Local _cFilAtu      := "2020012001"
Local _lRet			:= .T.
Local _aRegVS1		:= {}
Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local _nPos
Local _cPedido
Begin Sequence
	_cUsuario	  := AllTrim(_oJson:GetJsonText("usuario"))
	_cSenha		  := AllTrim(_oJson:GetJsonText("senha"))	 	 
    If Empty ( _cEmpresa )
		ZPEC11RMsg("_cEmpresa", "Campo cEmpresa: Empresa nao pode ser branco, favor verificar !")
		_lRet := .F.
        Break
    EndIf
    If Empty ( _cFilAtu )
		ZPEC11RMsg("_cFilAtu", "Campo cFilAtual: Filial nao pode ser branco, favor verificar !")
		_lRet := .F.
        Break
 	EndIf
    If Empty ( _cUsuario ) .or. AllTrim(_cUsuario) <> "RGLOG.REST"
 		ZPEC11RMsg("_cUsuario", "Aplicação Web não está autorizada a acessar os serviços Protheus (_cUsuario Failed) !")
		_lRet := .F.
         Break
 	EndIf
    If Empty ( _cSenha ) .or. AllTrim(_cSenha) <> "CaOa!RgLogRest@2021"
 		ZPEC11RMsg("_cSenha", "Aplicação Web não está autorizada a acessar os serviços Protheus (_cUsuario Failed) !")
		_lRet := .F.
         Break
 	EndIf
    //Tratar abertura da empresa conforme enviado no parametro
	If cEmpAnt <> _cEmpresa .or. cFilAnt <> _cFilAtu
    	RpcClearEnv() 
    	RPCSetType(3) 
    	RpcSetEnv(_cEmpresa,_cFilAtu,,,,GetEnvServer(),{ })
	EndIf

	// Valida os dados do oJson
	If !ValidOJson(@_oJson,"A")
		_lRet := .F.
		Break
	EndIf	
	// Realiza a gravação na tabela ZK
	Begin Transaction
		If !ZPEC11GPIK(@_oJson,"I", @_aRegVS1)
			_lRet := .F.
			Disarmtransaction()
		EndIf
	End Transaction
End Sequence
//NO CASO DE ERRO E TENHA PROCESSADO ALGUM ORÇAMENTO IRA RETORNAR OS PROBLEMAS ENCONTRADOS
If !_lRet .and. Len(_aRegVS1) > 0
	//neste caso deverei gravar as informações dos erros em todos os orçamentos que confiveram erro
	_cPedido 	:= AllTrim(_oJson["nu_pedidoorigem"][1]:GetJsonText("nu_pedido")) //"00000510"
	_cObs		:= "RETORNO DE SEPARAÇÃO RG LOG APRESENTOU PROBLEMAS REFERENTE PICKING "+_cPedido+" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5)+ CRLF		
	For _nPos := 1 To Len(_aMsgRet)
		_cObs += _aMsgRet[_nPos,2]
	Next
	_cJson 	:= _oJson:toJSON()
	_cJson 	:= EncodeUTF8( _cJson )
	//Gravar em todos os orçamentos
	For _nPos := 1 To Len(_aRegVS1)
		VS1->(DbGoto(_aRegVS1[_nPos]))
		VS1->(RecLock("VS1",.F.))
		VS1->VS1_OBSAGL	:= Upper(_cObs) +CRLF+ VS1->VS1_OBSAGL
		//Garantir que deixara os orçamentos com a fase anterior que é de conferência DAC 29/06/2022
		If VS1->VS1_STATUS <> _cFaseConf
			VS1->VS1_STATUS := _cFaseConf  //volto a fase anterior
		Endif	
		//mesmo não passando o carregamentp gravo o json para que possa ser verificado DAC 30/06/2022
		If SZK->(FieldPos("ZK_XJSREC")) > 0
			SZK->ZK_XJSREC := _cJson
		EndIf	
		If SZK->(FieldPos("ZK_XJSSTRE")) > 0
			SZK->ZK_XJSSTRE := "3" //1=RECEBIDO;2=NAO RECEBIDO;3=INCONSISTENCIA                                                                                      
		EndIf
		VS1->(MsUnLock())
	Next
EndIf

Return _lRet



/*/{Protheus.doc} ZPEC11GPIK
Realiza a atualização do piking recebido pela RG LOG
@author Denilso Almeida Carvalho
@since 18/10/2021
@version undefined
@param nCode, numeric, descricao
@param cMsg, characters, descricao
@type function
@history    DAC - 23/06/2022 - Refeita a funcionalidade para gravar  e ajustar carregamento  
@Obs
				Case VM5->VM5_STATUS == "1"
					cStatConf := STR0049 // Pendente
				Case VM5->VM5_STATUS == "2"
					cStatConf := STR0050 // Parcial
				Case VM5->VM5_STATUS == "3"
					cStatConf := STR0051 // Finalizada
				Case VM5->VM5_STATUS == "4"
					cStatConf := STR0052 // Aprovada
				Case VM5->VM5_STATUS == "5"
					cStatConf := STR0053 // Reprovada

/*/
Static Function ZPEC11GPIK(_oJson, _cTipo, _aRegVS1 )
Local _lRet			:= .T.
Local _cAlias 		:= GetNextAlias()
Local _cPedido		:= ""
Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local _cFaseFat		:= "F"
Local _cObs

Begin Sequence
	//_nPos := _oJson["nu_pedidoorigem"][1]:GetJsonText("nu_pedido")
	// numero do pedido
	DbSelectArea("SZK")
	_cPedido 	:= AllTrim(_oJson["nu_pedidoorigem"][1]:GetJsonText("nu_pedido")) //"00000510"
	If !ZPEC11LPIK( _cPedido ) 
		ZPEC11RMsg("nu_pedido","Pedido "+_cPedido+" ja consta no cadastro Picking como recebido, não sera processado !")
		_lRet	:= .F.
		Break
	EndIf

	BeginSql Alias _cAlias
		SELECT 	VS1.R_E_C_N_O_ NREGVS1
       	FROM %table:VS1% VS1
       	WHERE VS1.VS1_FILIAL  	= %XFilial:VS1%
			AND VS1.VS1_XPICKI 	= %Exp:_cPedido%
		  	AND VS1.%notDel%		  
	EndSql      
	If (_cAlias)->(Eof()) 	
		ZPEC11RMsg("nexistepick","Pedido "+_cPedido+" não localizou itens !")
		_lRet	:= .F.
		Break
	Endif   
	//DAC Selecionar processo VS5 e VS6 de carregamento e efetuar baixa

	While (_cAlias)->(!Eof())
		Aadd(_aRegVS1, (_cAlias)->NREGVS1)
		//Não existe carregamento no Protheus
		VS1->(DbGoto((_cAlias)->NREGVS1))
		//MESMO COM FASE DE CONFERÊNCIA NÃO GRAVOU NO PICKING SZK DAC 08/06/2022
		If VS1->VS1_STATUS  <> _cFaseConf
			ZPEC11RMsg("nostatusorc","Item do Pedido "+_cPedido+" correspondente a numeração "+VS1->VS1_NUMORC+" com fase "+VS1->VS1_STATUS+", diferente de Separação, não sera processado !")
			_lRet	:= .F.
			Break
		EndIf
		//SE NÃO TIVER PASSAR PARA PROXIMO REGISTRO
		_lRet := ZPEC11Separa(VS1->VS1_NUMORC, _cPedido)
		//Gravo dados necessário para o VS1 orçamento
		If ! _lRet
			Exit
		Else
			//Atualiza TES Inteligente
			If !(U_ZPECREGFI(_cPedido)) //cZK_XPICKI _cPedido
				_cObs		:= 	"ERRO NA ATUALIZAÇÃO TES INTELIGENTE NO PICKING "+_cPedido+" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5)+ CRLF
			EndIf
		
			VS1->(RecLock("VS1",.F.))
			If Empty(_cObs)
				_cObs	:= "RETORNO DE SEPARAÇÃO REALIZADO COM SUCESSO REFERENTE PICKING "+_cPedido+" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5)+ CRLF
			Else
				_cObs	+= "RETORNO DE SEPARAÇÃO REALIZADO COM SUCESSO REFERENTE PICKING "+_cPedido+" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5)+ CRLF
			Endif
			_cObs 	+= "Gravado a conferência (VM5) para os itens de separação  corretamente no recebimento do REST !"+ CRLF
			VS1->VS1_STATUS := _cFaseFat
			VS1->VS1_OBSAGL	:= Upper(_cObs) +CRLF+ VS1->VS1_OBSAGL
			VS1->(MsUnLock())
		EndIf
		(_cAlias)->(DbSkip())
	EndDo
	//efetua a gravação da tabela para controle de picking obtenção de pesos e medidas para a nota
	If _lRet .and. !U_ZPEC11GSZK(_oJson, /*_lGravaIni*/, /*_cPicking*/, /*_cObsMenNF*/, /*_cMarca*/, _lRet)
		ZPEC11RMsg("noGrava","Problemas com a gravação de dados em relação aos campos verificar com Administrador !")
		_lRet := .F.
		//Break
	EndIf
End Sequence
If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif  
Return _lRet



/*/{Protheus.doc} ZPEC11Separa
Recebe 		Verifica se os registros de separação estão informado e se estão de acordo com o VS3, finalizar carregamento VS3 e VM5 
@author 	DAC
@since 		23/06/2022
@version 	undefined
@param 		oJson
@type 		function
@ Obs		Os paremetros de token, empresa e filial serão enviados no cabeçalho reader Json
@history    DAC - 23/06/2022 - Modificada a forma de gravar informações sobre o recebimento VM5, VM6 e VM2 verificando se existe e criando novo processo  
/*/
Static Function ZPEC11Separa( _cNumOrc, _cPedido )
Local _lRet			:= .T.
Local _cAliasPesq	:= GetNextAlias()
Local _cNroConf		:= ""

Begin Sequence
	//Verifica se foi gravado o numero de conferência
	_cNroConf := OX0020071_ExisteConferencia( _cNumOrc  )
	If !Empty(_cNroConf)
		If !U_XAPAVM5VM6Carregamento(_cNumOrc)	
			ZPEC11RMsg("nosepara", "Pedido "+_cPedido+" não foi possivel atualizar carregamento no Protheus, não sera processado !")
			_lRet := .F.
			Break
		EndIf	
	EndIf
	_cNroConf := ""
	_cNroConf := VS1->(OX0020041_GravaRegistroConferencia( _cNumOrc ))
	If Empty(_cNroConf)
		ZPEC11RMsg("nosepara", "Pedido "+_cPedido+" não foi possivel atualizar carregamento no Protheus, não sera processado !")
		_lRet := .F.
		Break
	EndIf

	BeginSql Alias _cAliasPesq
		SELECT 	  VM5.VM5_NUMORC
				, VM5.VM5_CODIGO 
				, VS3.VS3_CODITE 
				, VM6.VM6_COD 
				, VM6.VM6_SEQUEN
				, VS3.VS3_SEQUEN
				, VM6.VM6_QTORIG 
				, VM6.VM6_QTCONF
				, VS3.VS3_QTDITE
				, VM5.VM5_STATUS
				, VS3.VS3_SQCONF
				, VS3.R_E_C_N_O_ NREGVS3
				, VM5.R_E_C_N_O_ NREGVM5  
				, VM6.R_E_C_N_O_ NREGVM6  
		FROM %table:VS3% VS3
		LEFT JOIN %table:VM5% VM5
			ON 	VM5.VM5_FILIAL 	= %XFilial:VM5%
			AND	VM5.VM5_NUMORC 	= VS3.VS3_NUMORC
			AND VM5.%notDel% 
		LEFT JOIN %table:VM6% VM6
			ON 	VM6.VM6_FILIAL 	= %XFilial:VM6%
			AND	VM6.VM6_CODVM5 	= VM5.VM5_CODIGO 
			AND VM6.VM6_COD		= VS3.VS3_CODITE
			AND TO_NUMBER(VM6.VM6_SEQUEN) = TO_NUMBER(VS3.VS3_SEQUEN)
			AND VM6.%notDel% 
		WHERE 	VS3.VS3_FILIAL = %XFilial:VS3%
			AND	VS3.VS3_NUMORC = %Exp:_cNumOrc%  
			AND VS3.VS3_SEQUEN <> ' '
			AND VS3.VS3_QTDITE > 0
			AND VS3.%notDel% 
		ORDER BY VS3.VS3_SEQUEN
	EndSql      
	
	//Caso existam registros preenchidos não é a carga inicial e não pode receber da RG
	If (_cAliasPesq)->(Eof()) 
		ZPEC11RMsg("noitens","Não localizado itens referente ao carregmento para o pedido "+_cPedido)
		_lRet := .F.
		Break
	EndIf
	//Localizando os registros validar de acordo com o Retorno
	(_cAliasPesq)->(DbGoTop())
	//Verifica o Status do Carregamento
	//Garanto que não vai estar sem o carregamento
	If (_cAliasPesq)->NREGVM5 == 0
		ZPEC11RMsg("nosepara", "Pedido "+_cPedido+" não possui carregamento no Protheus, não sera processado !")
		_lRet := .F.
		Break
	EndIf

	VM5->(DbGoto( (_cAliasPesq)->NREGVM5 ))
	If VM5->VM5_STATUS <> "1"
		ZPEC11RMsg("nostatusconf","Pedido "+_cPedido+" com status "+VM5->VM5_STATUS+" divergente no carregamento Protheus para item ref "+_cNumOrc+", nao sera processado !")
		_lRet := .F.
		Break
	EndIf
	While (_cAliasPesq)->(!Eof())
		_nRegVM6		:= (_cAliasPesq)->NREGVM6	
		VM6->(DbGoto(_nRegVM6))
		VM5->(OX0020141_GravaQtdConferida( _nRegVM6 , VM6->VM6_QTORIG, "0", (_cAliasPesq)->NREGVS3 ))
		(_cAliasPesq)->(DbSkip())
	EndDo
	//Após a Gravação Verificar se existe divergência
	//VM5->(DbGoto((_cAliasPesq)->NREGVM5))
	VM5->(OX0020131_VerificaDivergencias( VM5->VM5_CODIGO ))
	If VM5->VM5_DIVERG == "1"
		ZPEC11RMsg("divergencia","Pedido "+_cPedido+" com divergencia na separação, não sera processado !")
		_lRet := .F.
		Break
	EndIf
	VM5->(OX0020061_StatusConferencia( VM5->VM5_CODIGO , "3" ) )   //Altera Status
	If VM5->VM5_DIVERG == "0" // NAO tem Divergencia - Aprova Automaticamente
		If VM5->(OX0020161_LiberaItensConferidos( "0" ))
			VM5->(OX0020121_GravaConbar( VM5->VM5_NUMORC ))
			VM5->(OX0020061_StatusConferencia( VM5->VM5_CODIGO , "4" ))
		Else
			ZPEC11RMsg("liberacao","Pedido "+_cPedido+" não foi possivel fazer liberação na separação, não sera processado !")
			_lRet := .F.
			Break
		EndIf	
	EndIf
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet



/*/{Protheus.doc} ZPEC11LPIK
Recebe 		Verificar se ja existe picking processado na tabela SZK
@author 	DAC
@since 		23/06/2022
@version 	undefined
@param 		oJson
@type 		function
@ Obs		Os paremetros de token, empresa e filial serão enviados no cabeçalho reader Json
@history      
/*/
Static Function ZPEC11LPIK(_cPicking )
Local _lRet			:= .T.
Local _cAliasPesq	:= GetNextAlias()
//Begin Sequence
	BeginSql Alias _cAliasPesq
		SELECT 	SZK.R_E_C_N_O_ NREGSZK
       	FROM %table:SZK% SZK
      	WHERE SZK.ZK_FILIAL  	= %XFilial:SZK%
			AND SZK.ZK_XPICKI 	= %Exp:_cPicking%
			AND SZK.ZK_STREG	<> ' '
		  	AND SZK.%notDel%		  
	EndSql      
	//Caso existam registros preenchidos não é a carga inicial e não pode receber da RG
	If (_cAliasPesq)->(!Eof()) .or. (_cAliasPesq)->NREGSZK > 0
		_lRet	:= .F.
		//Break
		Return _lRet
	Endif
//End Sequence	
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 

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
Begin Sequence

	If !ZPEC11Obri(_oJson)  //Tem a função de validar os itens obrigatórios neste caso o vabeçalho
		_lRet := .F.
		Break
	EndIf	
End Sequence
Return _lRet



/*/{Protheus.doc} ZPEC11Obri
//Verifica informações de campos obrigatórios 
@author DAC
@since 12/11/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/
Static Function ZPEC11Obri(_oJson, _lItem, _lTodos)
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


/*/{Protheus.doc} ZPEC11RMsg
//Retorna Numero do Erro 
@author DAC
@since 12/11/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/
Static Function ZPEC11RMsg(_cRefMsg, _cMsgRet)
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
	Conout("ZWSR009 - [ZPECF011] "+_cMsgRet)
End Sequence
Return _nRet

/*/{Protheus.doc} ZPEC11AMsg
//Carrega Numero do Erro para retorno
@author DAC
@since 12/11/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/
Static Function ZPEC11AMsg()
Local _aRet := {}
Begin Sequence
	//			Nr Ret	Tags Json				Item	Obrig	Descrição	
	Aadd(_aRet, {100,	"ok"					, .F.	, .F., 	"Processo realizado com sucesso"})

	Aadd(_aRet, {400,	"usuario"				, .F.	, .T., 	"Usuario"})
	Aadd(_aRet, {401,	"senha"					, .F.	, .T., 	"Senha"})

	Aadd(_aRet, {600,	"nu_pedido"				, .T.	, .T., 	"Numero do pedido"})
	Aadd(_aRet, {601,	"cd_situacao"			, .T.	, .T., 	"Código da situação do pedido"})
	Aadd(_aRet, {602,	"vol_barcode"			, .T.	, .F., 	"Código de barras volume"})
	Aadd(_aRet, {603,	"vol_sequencia"			, .T.	, .T., 	"Volume x de y"})
	Aadd(_aRet, {604,	"vol_comprimento"		, .T.	, .T., 	"Comprimento do volume"})
	Aadd(_aRet, {605,	"vol_largura"			, .T.	, .T., 	"Largura do volume"})
	Aadd(_aRet, {606,	"vol_altura"			, .T.	, .T., 	"Altura do volume"})
	Aadd(_aRet, {607,	"vol_peso_liquido"		, .T.	, .T., 	"Peso liquido do volume"})
	Aadd(_aRet, {608,	"ps_volume"				, .T.	, .T., 	"Peso bruto do volume"})
	Aadd(_aRet, {609,	"vl_cubagem"			, .T.	, .T., 	"Valor da cubagem do volume"})
	Aadd(_aRet, {610,	"nu_serie_produto"		, .T.	, .F., 	"Número de série"})
	Aadd(_aRet, {611,	"ds_observacao"			, .T.	, .F., 	"Obs conferente"})
	Aadd(_aRet, {612,	"nexistepick"			, .F.	, .F., 	"Não localizado numero de Pedido"})
	Aadd(_aRet, {613,	"nostatusconf"			, .F.	, .F., 	"Status Separação invalido para conferência"})
	Aadd(_aRet, {614,	"nostatusorc"			, .F.	, .F., 	"Status Separação invalido para pedido"})
	Aadd(_aRet, {615,	"divergencia"			, .F.	, .F., 	"Divergencia na separação"})
	Aadd(_aRet, {616,	"liberacao"				, .F.	, .F., 	"Problemas com liberação na separação"})
	Aadd(_aRet, {617,	"nosepara"				, .F.	, .F., 	"Não possui carregamento no Protheus"})
	Aadd(_aRet, {618,	"noitens"				, .F.	, .F., 	"Não localizado itens para carregamento no Protheus"})

End Sequence
Return _aRet


/*
nu_pedido_origem		Número do pedido
cd_situacao				Código da situação do pedido
vol_barcode				Código de barras volume
vol_sequencia			Volume x de y
vol_comprimento			Comprimento do volume
vol_largura				Largura do volume
vol_altura				Altura do volume
vol_peso_liquido		Peso liquido do volume
ps_volume				Peso bruto do volume 
vl_cubagem				Valor da cubagem do volume
nu_serie_produto		Número de série
ds_obs_conferente		Obs conferente 
*/


/*/{Protheus.doc} SetMsgRet
Seta mensagem retorno de msg do rest
@author DAC
@since 01/05/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/
Static function SetMsgRet() 
Local _nMsg  := 999
Local _cMsg  := ""
Local _nPos

Begin Sequence
	If Len(_aMsgRet) == 0  //caso não venha com nenhuma msg
		_nMsg	:= 999
		_cMsg	:= "problemas na identificaçao do erro, não processado !"
	ElseIf	Len(_aMsgRet) > 1 //caso seja mais de uma msg enviar os erros aglupados nas msgs
		_nMsg	:= 999
		_cMsg	:= ""
		For _nPos := 1 To Len(_aMsgRet)
			_cMsg += StrZero(_aMsgRet[_nPos,1],3)+ " " +_aMsgRet[_nPos,2]
			_cMsg +=  " - " //CRLF
		Next	
	Else
		_nMsg  := _aMsgRet[1,1]
		_cMsg  := _aMsgRet[1,2]
	Endif
End Sequence
Return {_nMsg,EncodeUtf8(_cMsg)}
//Return {"Code":_nMsg,"detailedMessage": "","message":EncodeUtf8(_cMsg)}




/*
{ "usuario": "RGLOG.REST",
	"senha": "CaOa!RgLogRest@2021*",
	"nu_pedidoorigem": [{
		"nu_pedido": "00000510",
		"cd_situacao": "001",
		"vol_barcode": null,
		"vol_sequencia": 1.00,
		"vol_qtde_total": 3.00,
		"vol_comprimento": 0.55,
		"vol_largura": 0.60,
		"vol_altura": 1.175,
		"vol_pesoliquido": 109.80,
		"ps_volume": 116.325,
		"vl_cubagem": 0.388,
		"nu_serie_produto": "SQRE4T15BBBMD00925",
		"ds_observacao": "pedido separado "
	}]
}
*/



