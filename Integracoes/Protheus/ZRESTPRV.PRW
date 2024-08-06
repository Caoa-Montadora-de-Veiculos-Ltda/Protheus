#INCLUDE "TOTVS.CH"
#Include "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

Static  _aAlterado 

/*/{Protheus.doc} ZRESTPRV
Serviço de integração faturamento para Previsãove Pedido 
Atualização da separação dos orçamentos baixando conforme informaçção recebida
@author 	DAC 
@since 		30/07/2024
@version 	undefined
@param		nao utilizado
@type 		User Function
@client   	CAOA 
@return   	_aMsg - Array com retorno Json código e ocorrencia
@project 	
			https://tdn.totvs.com/display/tec/DecodeUTF8
			https://jsonformatter.curiousconcept.com/  VERIFICAR SE JSON ESTA CORRETO
			https://jsonlint.com/?code=   //VALIDAR JSON
            https://jsoneditoronline.org/#left=local.sowavu  //estrutura do json
/*/

User Function ZRESTPRV(_oJson, _cEmpFil, _cResp)
Local _aMsg		:= {}

Private _aRetMsg := ZRESTPRVMsg()   //Carregar tabela com erros
Private _aMsgRet := {}				//carregar msg de errp

Default _cEmpFil	:= ""
Default _cResp		:= ""

Begin Sequence
	Conout("INICIANDO FUNCIONALIDADE ZRESTSA1 em "+DtoC(Date())+" as "+Time())
	_aMsgRet 	:= {}

    If ZRESTPRVPR( @_oJson, _cEmpFil, _cResp )
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


/*/{Protheus.doc} ZRESTPRVPR
Recebe 		Json CLIENTE PUT 
@author 	DAC
@since 		20/03/2024
@version 	undefined
@param 		oJson
@type 		function
@ Obs		Os paremetros de token, empresa e filial serão enviados no cabeçalho reader Json
/*/
Static Function ZRESTPRVPR( _oJson, _cEmpFil, _cResp )
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
	//Verificar se existe cadastro fornecedor , o Genérico não sendo 
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
	_lRet := ZRESTPRVGR(_oJson, _cEmpresa, _cFilAtu, _cResp)

End Sequence
Return _lRet


/*/{Protheus.doc} ZRESTPRVGR
Gravar dados do oJson no Cliente
@author DAC - Denilso
@since 
@version undefined
@param 
@type function
/*/
Static Function ZRESTPRVGR(_oJson, _cEmpresa, _cFilAtu, _cResp)
Local _cAliasPesq	:= GetNextAlias()
Local _lRet 		:= .F.
Local _lNovo    	:= .T.
Local _cTipoOper	:= AllTrim(_oJson:GetJsonText("tpoperacao"))
Local _cNumPed		:= ""
Local _aCabSC5      := {}
Local _cOper 		:= "92"   //VENDA VEICULO
Local _CodTes		:= "501"

Local _cCodProd
Local _aMsgErro 
Local _cItem 
Local _aCabSC5 		
Local _aItens  		
Local _cPedido 		
Local _aLinha 
Local _nTam
Local _cFabMod

Begin Sequence 
	If _cTipoOper <> "1"
		_lNovo := .F.
	Endif

	//Função para retorno de códigos, verificar se existem pais estado e municipio, indiferente do cliente ser ou nao cadastrdos estas informações tem que estar fornecidas corretamente
	If !ZRESTVVNValida(_oJson)
		Break
	Endif
  
	_aAlterado 	:= {}  //indicação de alteração do campo
	_aCabSC5	:= {}
	If _lNovo
		_cNumPed := GetSxeNum("SC5","C5_NUM")
		ZRESTPRVAlterados(	"C5_FILIAL"		, FWxFilial('SC5')						, @_aCabSC5, @_aAlterado, _lNovo )   // Nome
		ZRESTPRVAlterados(	"C5_NUM"		, _cNumPed								, @_aCabSC5, @_aAlterado, _lNovo )   // Nome
	Else 
		_cNumPed := SC5->C5_NUM	
	Endif

	_aCabSC5	:= {}
	_aItens 	:= {}
	_cPedido 	:= AllTrim(_oJson:GetJsonText("pedidovei"))

	ZRESTPRVAlterados( "SC5"	,"C5_CLIENTE"	, SA1->A1_COD								, @_aCabSC5, @_aAlterado, _lNovo )   // Nome
	ZRESTPRVAlterados( "SC5"	,"C5_LOJACLI"	, SA1->A1_LOJA								, @_aCabSC5, @_aAlterado, _lNovo )   // Nome
	ZRESTPRVAlterados( "SC5"	,"C5_CLIENT"	, SA1->A1_COD								, @_aCabSC5, @_aAlterado, _lNovo )   // Nome
	ZRESTPRVAlterados( "SC5"	,"C5_LOJAENT"	, SA1->A1_LOJA								, @_aCabSC5, @_aAlterado, _lNovo )   // Nome
	ZRESTPRVAlterados( "SC5"	,"C5_EMISSAO"	, StoD(_oJson:GetJsonText("dataemissao"))	, @_aCabSC5, @_aAlterado, _lNovo )   // Tipo 
	ZRESTPRVAlterados( "SC5"	,"C5_CONDPAG"	, _oJson:GetJsonText("cdcondpgto")    		, @_aCabSC5, @_aAlterado, _lNovo )   // Tipo 
	ZRESTPRVAlterados( "SC5"	,"C5_NATUREZ"	, _oJson:GetJsonText("cdnatureza")   		, @_aCabSC5, @_aAlterado, _lNovo )   // Endereco
	ZRESTPRVAlterados( "SC5"	,"C5_TIPLIB"	, "1"   									, @_aCabSC5, @_aAlterado, _lNovo )   // Endereco
	ZRESTPRVAlterados( "SC5"	,"C5_MOEDA"		, 1   										, @_aCabSC5, @_aAlterado, _lNovo )   // Endereco
	ZRESTPRVAlterados( "SC5"	,"C5_TIPOCLI"	, SA1->A1_TIPO   							, @_aCabSC5, @_aAlterado, _lNovo )   // Endereco
	ZRESTPRVAlterados( "SC5"	,"C5_TPFRETE"	, _oJson:GetJsonText("tpfrete")   			, @_aCabSC5, @_aAlterado, _lNovo )   // Endereco
	ZRESTPRVAlterados( "SC5"	,"C5_TRANSP" 	, SA4->A4_COD   							, @_aCabSC5, @_aAlterado, _lNovo )   //  Nome reduz.
	ZRESTPRVAlterados( "SC5"	,"C5_XTIPVEN" 	, _oJson:GetJsonText("tpvenda")   			, @_aCabSC5, @_aAlterado, _lNovo )   //  Nome reduz.

	_nTam 		:= Len(_oJson["itens"])

	For _nPos := 1 To _nTam
		_aLinha		:= {}
        _cCodProd 	:= AllTrim(_oJson["itens"][_nPos]:GetJsonText("cdmodvei")) + ;
					   AllTrim(_oJson["itens"][_nPos]:GetJsonText("cdsegmod"))
		_cItem		:= AllTrim(_oJson["itens"][_nPos]:GetJsonText("nritem"))
		_cFabMod	:= AllTrim(_oJson["itens"][_nPos]:GetJsonText("anomodelo"))+AllTrim(_oJson["itens"][_nPos]:GetJsonText("anofabricacao"))


                VV2->(DbSetOrder(1))
                VV2->(DbSeek(xFilial("VV2")+(cTmpAlias)->VRK_CODMAR+(cTmpAlias)->VRK_MODVEI+(cTmpAlias)->VRK_SEGMOD))

		If ZRESTPRVSB1(_cCodProd, _cItem, @_aMsgErro)
			Exit
		Endif
		
		If Empty(_oJson["itens"][_nPos]:GetJsonText("cdoperacao"))
			_cOper := _oJson["itens"][_nPos]:GetJsonText("cdoperacao")
		Endif	
		//valida Operação
		If ZRESTPRVOper(@_cOper, @_cCodTes, _cItem, _cCodProd, @_aMsgErro)
			Exit 
		Endif
		_aLinha := {}
		If _lNovo
			ZRESTPRVAlterados(	"C6_FILIAL"		, FWxFilial('SC6')						, @_aLinha,	@_aAlterado, _lNovo )   // Nome
			ZRESTPRVAlterados(	"C6_NUM"		, _cNumPed								, @_aLinha, @_aAlterado, _lNovo )   // Nome
		Endif
		ZRESTPRVAlterados("SC6", "C6_ITEM"		, _oJson["itens"][_nPos]:GetJsonText("nritem")			, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_PRODUTO"	, _cCodProd												, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_QTDVEN"	, _oJson["itens"][_nPos]:GetJsonText("qtdeitem")		, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_PRCVEN"	, _oJson["itens"][_nPos]:GetJsonText("valorunitario")	, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_VALOR"		, _oJson["itens"][_nPos]:GetJsonText("valorunitario")	, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_PRUNIT"	, _oJson["itens"][_nPos]:GetJsonText("valorunitario")	, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_OPER"		, _cOper												, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_TES"		, _CodTes												, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_PEDCLI"	, _cPedido												, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
        //Verificar como validar estes campos    
		ZRESTPRVAlterados("SC6", "C6_CHASSI"	, CriaVar("C6_CHASSI" )									, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_LOCALIZ"	, CriaVar("C6_LOCALIZ")									, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_QTDLIB"	, CriaVar("C6_NUMSERI")									, @_aLinha,	@_aAlterado, _lNovo )   // Endereco

		ZRESTPRVAlterados("SC6", "C6_XCODMAR"	, _oJson["itens"][_nPos]:GetJsonText("cdmarca")				, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XDESMAR"	, _oJson["itens"][_nPos]:GetJsonText("")				, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XCORINT"	, _oJson["itens"][_nPos]:GetJsonText("cdcorinterna")				, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XCOREXT"	, _oJson["itens"][_nPos]:GetJsonText("cdcorexterna")				, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XMODVEI"	, _oJson["itens"][_nPos]:GetJsonText("cdmodvei")				, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XDESMOD"	, VV2->VV2_DESMOD										, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XSEGMOD"	, _oJson["itens"][_nPos]:GetJsonText("cdsegmod")				, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XDESSEG"	, VVX->VVX_DESSEG  										, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XFABMOD"	, _cFabMod											, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XGRPMOD"	, _oJson["itens"][_nPos]:GetJsonText("")				, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XPRCTAB"	, _oJson["itens"][_nPos]:GetJsonText("")				, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XVLRPRD"	, _oJson["itens"][_nPos]:GetJsonText("")				, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XVLRMVT"	, _oJson["itens"][_nPos]:GetJsonText("")				, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XVLRVDA"	, _oJson["itens"][_nPos]:GetJsonText("")				, @_aLinha,	@_aAlterado, _lNovo )   // Endereco
		ZRESTPRVAlterados("SC6", "C6_XBASST"	, _oJson["itens"][_nPos]:GetJsonText("")				, @_aLinha,	@_aAlterado, _lNovo )   // Endereco

                Aadd( aLinha, { "C6_XDESSEG",       , Nil } )
                Aadd( aLinha, { "", (cTmpAlias)->VRK_FABMOD , Nil } )
                Aadd( aLinha, { "", ""                      , Nil } )
                Aadd( aLinha, { "", (cTmpAlias)->VRK_VALTAB , Nil } )
                Aadd( aLinha, { "", (cTmpAlias)->VRK_VALPRE , Nil } )
                Aadd( aLinha, { "", (cTmpAlias)->VRK_VALMOV , Nil } )
                Aadd( aLinha, { "", (cTmpAlias)->VRK_VALVDA , Nil } )
                Aadd( aLinha, { "C6_XBASST",  (cTmpAlias)->VRK_XBASST , Nil } )
                Aadd( aItePed ,  aLinha )



			_cItem 		:= Soma1(_cItem)


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
			If FieldPos("A1_XINTEG") > 0 .And. SA1->A1_XINTEG  <> "X"
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
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet 

//Valida campos enviados no REST
Static Function ZRESTVVNValida(_oJson)
Local _cAliasPesq   := GetNextAlias()
Local _lRet 		:= .F.
Local _cPedido		:= AllTrim(_oJson:GetJsonText("pedidovei"))
Local _cTipoOper	:= AllTrim(_oJson:GetJsonText("tpoperacao"))
Local _cCnPjCpf		:= AllTrim(_oJson:GetJsonText("cnpjcpf"))  
Local _dTEmissao	:= StoD(_oJson:GetJsonText("dataemissao"))
Local _cCondpgto	:= AllTrim(_oJson:GetJsonText("cdcondpgto"))
Local _cNatureza 	:= AllTrim(_oJson:GetJsonText("cdnatureza")) 	
Local _cTipoVenda 	:= AllTrim(_oJson:GetJsonText("tpvenda"))
Local _cTipoFrete 	:= AllTrim(_oJson:GetJsonText("tpfrete"))
Local _cTransp 		:= AllTrim(_oJson:GetJsonText("cnpjtransp"))
Local _cSelect		:= ""

Default _cMunicipio	:= ""
Default _cCodBancen	:= ""

Begin Sequence 

	//Verificar Tipo de Operação 
	_cTipoOper	:= AllTrim(_oJson:GetJsonText("tpoperacao"))
	If !_cTipoOper $ "1_2_3"
		U_ZRETMsgJson("tpoperacao","Tipo de operacao invalida !")
		Break
	Endif  
	//não permitir data de emissão com mais de 1 ano atras
	If _dTEmissao < Date()-365
		U_ZRETMsgJson("dataemissao","Data de emissao do Pedido invalida !")
		Break
	Endif

	If !Empty(_cTipoFrete) .And. _cTipoFrete $ "C_F_T_R_D_S"
		U_ZRETMsgJson("tpfrete","Data de emissao do Pedido invalida !")
		Break
	Endif 

	If !Empty(_cCondpgto)
		_cSelect  := ", ( SELECT SE4.R_E_C_N_O_ FROM "+RetSqlName("SE4")+" SE4 " + CRLF
		_cSelect  += "   WHERE  SE4.E4_FILIAL = '"+FwxFilial("SE4")+"' "  + CRLF
		_cSelect  += "   	AND SE4.E4_COD = '"+_cCondpgto+"' "  + CRLF
		_cSelect  += "	) AS NREGSE4
	Else 
		_cSelect  := ", 0 AS NREGSE4 "	+ CRLF
	Endif 	

	If !Empty(cnpjtransp) 
		_cSelect  := ", ( SELECT SA4.R_E_C_N_O_ FROM "+RetSqlName("SA4")+" SA4 " + CRLF
		_cSelect  += "   WHERE  SA4.A4_FILIAL = '"+FwxFilial("SA4")+"' "  + CRLF
		_cSelect  += "   	AND SA4.A4_CGC = '"+cnpjtransp+"' "  + CRLF
		_cSelect  += "	) AS NREGSA4
	Else 
		_cSelect  := ", 0 AS NREGSA4 "	+ CRLF
	Endif 

	_cSelect := "%"+_cSelect"%"

	BeginSql Alias _cAliasPesq
		SELECT 	 SC5.R_E_C_N_O_ AS NREGSC5
				,SED.R_E_C_N_O_ AS NREGSED
				,VV3.R_E_C_N_O_ AS NREGVV3
				,SC6.R_E_C_N_O_ AS NREGSC6 
				,SA1.R_E_C_N_O_ AS NREGSA1
				_cSelect
		FROM %Table:SC5% SC5
		LEFT JOIN %Table:SC6% SC6
			ON  SC6.%notDel% 
			AND SC6.C6_FILIAL 	= %XFilial:SC6%
			AND SC6.C6_NUM 		= SC5.C5_NUM
		LEFT JOIN %Table:SA1% SA1
			ON  SA1.%notDel% 
			AND SA1.A1_FILIAL 	= %XFilial:SA1%
			AND SA1.A1_CGC		= %Exp:_cCnPjCpf%
		LEFT JOIN %Table:SED% SED
			ON  SED.%notDel% 
			AND SED.ED_FILIAL 	= %XFilial:SED%
			AND SED.ED_CODIGO	= %Exp:_cNatureza%
		LEFT JOIN %Table:VV3% VV3
			ON  VV3.%notDel% 
			AND VV3.VV3_FILIAL 	= %XFilial:VV3%
			AND VV3.VV3_TIPVEN	= %Exp:_cTipoVenda%
       	WHERE SC5.%notDel% 
			AND SC5.C5_FILIAL  	= %XFilial:SC5%
			AND SC5.C5_NUM 		= %Exp:_cPedido%
	EndSql      
	//operação incluir
	If (_cAliasPesq)->(Eof()) .And. _cTipoOper <> "I"
		U_ZRETMsgJson("pedido","Pedido "+_cPedido+" nao localizado !")
		Break
	Endif
	If  (_cAliasPesq)->NREGSC5 == 0 .And. _cTipoOper <> "I"
		U_ZRETMsgJson("pedido","Pedido "+_cPedido+"  nao localizado !")
		Break
	Endif
	//operação alterar
	If (_cAliasPesq)->(!Eof()) .And. _cTipoOper == "I"
		U_ZRETMsgJson("pedido","Pedido "+_cPedido+" ja cadastrado !")
		Break
	Endif
	//rEPOSICIONAR sc5
	If (_cAliasPesq)->(!Eof())
		SC5->(DbGoto((_cAliasPesq)->NREGSC5))
	Endif 
	If  (_cAliasPesq)->NREGSED == 0
		U_ZRETMsgJson("cdnatureza","Natureza "+_cNatureza+" nao localizada !")
		Break
	Else 
		SED->(DbGoto((_cAliasPesq)->NREGSED))
	Endif
	If  (_cAliasPesq)->NREGVV3 == 0
		U_ZRETMsgJson("tpvenda","Natureza "+_cTipoVenda+" nao localizado !")
		Break
	Else 
		VV3->(DbGoto((_cAliasPesq)->NREGVV3))
	Endif
	If  (_cAliasPesq)->NREGSA1 == 0
		U_ZRETMsgJson("cnpjcpf","Cliente com CNPJ/CPF "+cnpjcpf+" nao localizado !")
		Break
	Else 
		SA1->(DbGoto((_cAliasPesq)->NREGSA1))
	Endif 
	_lRet := .T.
End Sequence 

If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet


//localizar Produto
Static Function ZRESTPRVSB1(_cCodProd, _cItem)
Local _cAliasPesq   := GetNextAlias()
Local _lRet			:= .T.
	BeginSql Alias _cAliasPesq
		SELECT 	 SB1.R_E_C_N_O_ AS NREGSB1 
		FROM %Table:SB1% SB1
       	WHERE SB1.%notDel% 
			AND SB1.B1_FILIAL  	= %XFilial:SB1%
			AND SB1.B1_COD 		= %Exp:_cCodProd%
	EndSql      
	//operação incluir
	If (_cAliasPesq)->(Eof()) .Or. (_cAliasPesq)->NREGSB1 == 0
		U_ZRETMsgJson("produto","Produto "+_cCodProd+" para o item "+_cItem+" nao localizado !")
		_lRet := .F.
	Endif 
	If _lRet
		SB1->(DbGoto((_cAliasPesq)->NREGSB1))
	Endif
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet 	



//localizar o tipo de operação
Static Function ZRESTPRVOper(_cOper, _cCodTes, _cItem, _cCodProd )
Local _cAliasPesq   := GetNextAlias()
Local _lRet			:= .T.
Local _cTab 		:= "DJ"
Local _cTesPar 		:= AllTrim(SuperGetMV("CAOA_AUT1C", ,'501'))
Local _cOper1  		:= AllTrim(SuperGetMV("CAOA_AUT1A", ,'92')
Local _cOper2 		:= AllTrim(SuperGetMV("CAOA_AUT1B", ,'93')

	BeginSql Alias _cAliasPesq
		SELECT 	 SX5.R_E_C_N_O_ AS NREGSX5
		FROM %Table:SX5% SX5
       	WHERE SX5.%notDel% 
			AND SX5.X5_FILIAL  	= %XFilial:SX5%
			AND SX5.X5_TABELA 	= %Exp:_cTab%
			AND SX5.X5_CHAVE	= %Exp:_cOper%
	EndSql      
	//operação incluir
	If (_cAliasPesq)->(Eof()) .Or. (_cAliasPesq)->NREGSX5 == 0
		Aadd(_aMsgErro,"Codigo da operacao "+_cOper+" para o item "+_cItem+" nao localizado !") 
		_lRet := .F.
	Endif 
	If _lRet
		SX5->(DbGoto((_cAliasPesq)->NREGSX5))
	Endif
	//Caso  tenha sido informado operação
	If !Empty(_cOper)
    	_cCodTes := MaTesInt(2, _cOper, SA1->A1_COD, SA1->A1_LOJA, "C", _cCodProd, "C6_TES") 
	Endif 
	//não localizou cod da TES
	If Empty(_cCodTes)
		_cOper 		:= _cOper1
    	_cCodTes 	:= MaTesInt(2, _cOper, SA1->A1_COD, SA1->A1_LOJA, "C", _cCodProd, "C6_TES") 
	Endif 
	//não localizou cod da TES
	If Empty(_cCodTes)
		_cOper 		:= _cOper2
    	_cCodTes 	:= MaTesInt(2, _cOper, SA1->A1_COD, SA1->A1_LOJA, "C", _cCodProd, "C6_TES") 
	Endif		
	//Se continuar em branco problemas com TES
	If Empty(_cCodTes)
		U_ZRETMsgJson("cdoperacao","Nao localizado regra para a operacao referente ao item "+_cItem+" !")
		_lRet := .F.
	Endif

If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet 	





//Verifica campos alterados no REST caso seja alteração

Static Function ZRESTPRVAlterados( _cTab, _cCampo, _xConteudo, _aAuto, _aAlterado, _lNovo )
Local _lRet 		:= .T.
Local _cConteudo	:= ""
//Local _nTam 	:= _oSA1Mod:adatamodel[1]  //_oSA1Mod:GetFields()
Begin Sequence 
    //Registro novo não guardar alterações
	Aadd( _aAuto, { _cCampo    , _xConteudo , Nil } )
	If _lNovo
		Break 
	Endif
	//verifica se existe campo
	If (_cTab)->(FieldPos(_cCampo)) == 0
		U_ZRETMsgJson("erropad","Campo "+_cCampo+" nao localizado na validacao alterados !")
		_lRet := .F. 
		Break
	Endif 
	_cConteudo := (_cTab)->(FieldGet(FieldPos(_cCampo)))
	If ValType(_xConteudo) == "N"
		_xConteudo := AllTrim(Str(_xConteudo))
		_cConteudo := AllTrim(Str(_cConteudo))
	ElseIf ValType(_xConteudo) == "D"
		_xConteudo := AllTrim(DtoC(_xConteudo))
		_cConteudo := AllTrim(DtoC(_cConteudo))
	ElseIf ValType(_xConteudo) == "L"
		If _xConteudo
			_xConteudo := "VERDADEIRO"
		Else	
			_xConteudo := "VERDADEIRO"
		Endif 
		If _cConteudo
			_cConteudo := "VERDADEIRO"
		Else	
			_xConteudo := "FALSO"
		Endif 
	Else 
		_xConteudo := AllTrim(_xConteudo)
		_cConteudo := AllTrim(_cConteudo)
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



/*/{Protheus.doc} ZRESTPRVMsg
//Carrega Numero do Erro para retorno
@author DAC
@since 12/11/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/
Static Function ZRESTPRVMsg()
Local _aRet := {}
Begin Sequence
	//			Nr Ret	Tags Json			Item	Obrig	Descrição	
	Aadd(_aRet, {100,	"ok"				, .F.	, .F., 	"Processo realizado com sucesso"})

	Aadd(_aRet, {300,	"empresa"			, .F.	, .F., 	"Empresa nao informada"})
	Aadd(_aRet, {301,	"filial"			, .F.	, .F., 	"Filial nao informada"})
	Aadd(_aRet, {302,	"token"				, .F.	, .F., 	"Token Invalido"})
	Aadd(_aRet, {303,	"ambiente"			, .F.	, .F., 	"Nao foi possivel acessar ambiente"})
	Aadd(_aRet, {304,	"responsavel"		, .F.	, .F., 	"Não Autorizado"})

	Aadd(_aRet, {400,	"cnpjcpf"			, .F.	, .T., 	"Problemas encontrados referente ao CNPJ e ou CPF do Cliente"})
	Aadd(_aRet, {401,	"pedidovei"			, .F.	, .T., 	"Problemas encontrados no numero de Pedido"})
	Aadd(_aRet, {402,	"tpoperacao"		, .F.	, .T., 	"Problemas encontrados no tipo de operação"})
	Aadd(_aRet, {403,	"dataemissao"		, .F.	, .T., 	"Problemas encontrados com data de emissao"})
	Aadd(_aRet, {404,	"cdcondpgto"		, .F.	, .T., 	"Problemas encontrados na condição Pgto"})
	Aadd(_aRet, {405,	"cdnatureza"		, .F.	, .T., 	"Problemas encontrados com Natureza"})
	Aadd(_aRet, {406,	"tpvenda"			, .F.	, .T., 	"Problemas encontrados com Tipo de Venda"})
	Aadd(_aRet, {407,	"tpfrete"			, .F.	, .T., 	"Problemas encontrados no tipo de Frete"})
	Aadd(_aRet, {408,	"cdtransporte"		, .F.	, .F., 	"Problemas encontrados com a Transportadora"})

	Aadd(_aRet, {450,	"nritem"			, .T.	, .T., 	"Problemas com numeração sequencial do item"})
	Aadd(_aRet, {451,	"cdmarca"			, .T.	, .T., 	"Problemas com a Marca Veiculo"})
	Aadd(_aRet, {452,	"cdgrupomod"		, .T.	, .T., 	"Problemas com Grupo Modelo Veículo "})
	Aadd(_aRet, {453,	"cdmodvei"			, .T.	, .T., 	"Problemas com Modelo Veículo"})
	Aadd(_aRet, {454,	"cdsegmod"			, .T.	, .T., 	"Problemas com Segmento Modelo do Veículo"})
	Aadd(_aRet, {455,	"anomodelo"			, .T.	, .T., 	"Problemas com Ano Modelo do Veículo"})
	Aadd(_aRet, {456,	"anofabricacao"		, .T.	, .T., 	"Problemas com o Ano de Fabricação do Veículo"})
	Aadd(_aRet, {457,	"cdcorexterna"		, .T.	, .T., 	"Problemas com ao Cor Externa Veiculo"})
	Aadd(_aRet, {458,	"cdcorinterna"		, .T.	, .T., 	"Problemas com ao Cor Interna Veiculo"})
	Aadd(_aRet, {459,	"cdopcional"		, .T.	, .F., 	"Problemas com Opcional Veículo"})
	Aadd(_aRet, {460,	"produto"			, .T.	, .T., 	"Problemas com Produto"})
	Aadd(_aRet, {461,	"qtdeitem"			, .T.	, .T., 	"Problemas com quantidade de item"})
	Aadd(_aRet, {462,	"valorunitario"		, .T.	, .F., 	"Problemas com valor unitario"})
	Aadd(_aRet, {463,	"cdoperacao"		, .T.	, .F., 	"Problemas com codigo operacao no item"})

	Aadd(_aRet, {500,	"conexao"			, .F.	, .T., 	"Problemas relativo a conexão"})

	Aadd(_aRet, {600,	"erropad"			, .F.	, .T., 	"Problemas com erros no Padrão"})
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

