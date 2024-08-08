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
Local _cRespLib		:= AllTrim( superGetMv( "CAOA_RES03"	, , ""		) )	

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
Local _lRet 		:= .T.
Local _lNovo    	:= .T.
Local _cTipoOper	:= AllTrim(_oJson:GetJsonText("tpoperacao"))

Local _aCabSC5 		AS Array	
Local _aItens  		AS Array	
Local _aLinha 		AS Array
Local _aError		AS Array
Local _aCampos		AS Array

Local _nOper 		AS Numeric
Local _nTam			AS Numeric
Local _nValTab		AS Numeric
Local _nReg			AS Numeric
Local _nError		AS Numeric

Local _cNumPed		AS Character
Local _cOper 		AS Character 
Local _CodTes		AS Character
Local _cCodProd		AS Character
Local _cItem 		AS Character
Local _cPedido 		AS Character	
Local _cFabMod		AS Character
Local _cCodMar 		AS Character 
Local _cModVei 		AS Character
Local _cSegMod 		AS Character
Local _cGrupoMod 	AS Character
Local _cCorInterna	AS Character
Local _cCorExterna	AS Character
Local _cError 		AS Character
Local _cMsg			AS Character
Local _cHsIni		AS Character

lOCAL _dDataIni 	AS Date

Begin Sequence 
	_cHsIni		:= SubsTr(Time(),1,5)
	_dDataIni	:= Date()
	If _cTipoOper == "1"	//inclui
		_lNovo := .T.
		_nOper := 3
	ElseIf _cTipoOper == "2"  //Altera
		_lNovo := .F.
		_nOper := 4
	ElseIf _cTipoOper == "3"  //Exclui
		_nOper := 5
	Endif

	//Função para retorno de códigos, verificar se existem pais estado e municipio, indiferente do cliente ser ou nao cadastrdos estas informações tem que estar fornecidas corretamente
	If !ZRESTVVNValida(_oJson)
		Break
	Endif
  
	_aAlterado 	:= {}  //indicação de alteração do campo
	_aCabSC5	:= {}
	_nOper		:= 3   //operação inclusão

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

	//processar os itens
	_nTam 		:= Len(_oJson["itens"])
	For _nPos := 1 To _nTam
		_aLinha		:= {}
		_cItem		:= AllTrim(_oJson["itens"][_nPos]:GetJsonText("nritem"))
		_cFabMod	:= AllTrim(_oJson["itens"][_nPos]:GetJsonText("anomodelo"))+AllTrim(_oJson["itens"][_nPos]:GetJsonText("anofabricacao"))
		_cCodMar 	:= AllTrim(_oJson["itens"][_nPos]:GetJsonText("cdmarca"))
		_cModVei 	:= AllTrim(_oJson["itens"][_nPos]:GetJsonText("cdmodvei"))
		_cSegMod 	:= AllTrim(_oJson["itens"][_nPos]:GetJsonText("cdsegmod"))
		_cGrupoMod 	:= AllTrim(_oJson["itens"][_nPos]:GetJsonText("cdgrupomod"))
		_cCorInterna:= AllTrim(_oJson["itens"][_nPos]:GetJsonText("cdcorinterna"))
		_cCorExterna:= AllTrim(_oJson["itens"][_nPos]:GetJsonText("cdcorexterna"))

	    _cCodProd 	:= _cModVei + _cSegMod	//montagem do codigo produto
		_nValTab 	:= ZRESTPRVPTabela( _cCodMar, _cModVei, _cSegMod, _cFabMod)  //tabela de veiculo
		//_cItem 		:= Soma1(_cItem)  utilizara item enviado pelo criente
		_aLinha 	:= {}

 		If ! ZRESTPRVRVeiculo(_cCodProd, _cCodMar, _cModVei, _cSegMod _cItem)
			_lRet := .F. 
			Exit
		Endif
		
		If Empty(_oJson["itens"][_nPos]:GetJsonText("cdoperacao"))
			_cOper := _oJson["itens"][_nPos]:GetJsonText("cdoperacao")
		Endif	
		//valida Operação
		If ZRESTPRVOper(@_cOper, @_cCodTes, _cItem, _cCodProd)
			_lRet := .F. 
			Exit 
		Endif
		If _lNovo
			ZRESTPRVAlterados(	"C6_FILIAL"		, FWxFilial('SC6')						, @_aLinha,	@_aAlterado, _lNovo )   
			ZRESTPRVAlterados(	"C6_NUM"		, _cNumPed								, @_aLinha, @_aAlterado, _lNovo )   
		Endif
		ZRESTPRVAlterados("SC6", "C6_ITEM"		, _oJson["itens"][_nPos]:GetJsonText("nritem")			, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_PRODUTO"	, _cCodProd												, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_QTDVEN"	, _oJson["itens"][_nPos]:GetJsonText("qtdeitem")		, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_PRCVEN"	, _oJson["itens"][_nPos]:GetJsonText("valorunitario")	, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_VALOR"		, _oJson["itens"][_nPos]:GetJsonText("valorunitario")	, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_PRUNIT"	, _oJson["itens"][_nPos]:GetJsonText("valorunitario")	, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_OPER"		, _cOper												, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_TES"		, _CodTes												, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_PEDCLI"	, _cPedido												, @_aLinha,	@_aAlterado, _lNovo )   
        //Verificar como validar estes campos    
		ZRESTPRVAlterados("SC6", "C6_CHASSI"	, CriaVar("C6_CHASSI" )									, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_LOCALIZ"	, CriaVar("C6_LOCALIZ")									, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_QTDLIB"	, CriaVar("C6_NUMSERI")									, @_aLinha,	@_aAlterado, _lNovo )   

		ZRESTPRVAlterados("SC6", "C6_XCODMAR"	, _cCodMar												, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_XMODVEI"	, _cModVei												, @_aLinha,	@_aAlterado, _lNovo )   

		ZRESTPRVAlterados("SC6", "C6_XDESMAR"	, 														, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_XCORINT"	, _cCorInterna											, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_XCOREXT"	, _cCorExterna											, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_XDESMOD"	, VV2->VV2_DESMOD										, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_XSEGMOD"	, _cSegMod												, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_XDESSEG"	, VVX->VVX_DESSEG  										, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_XFABMOD"	, _cFabMod												, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_XGRPMOD"	, _cGrupoMod											, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_XPRCTAB"	, _nValTab												, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_XVLRPRD"	, _nValTab												, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_XVLRMVT"	, 														, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_XVLRVDA"	, 														, @_aLinha,	@_aAlterado, _lNovo )   
		ZRESTPRVAlterados("SC6", "C6_XBASST"	, VVP->VVP_BASEST										, @_aLinha,	@_aAlterado, _lNovo )   

		If SC6->(FieldPos("C6_XOPCION"))
			ZRESTPRVAlterados("SC6", "C6_XOPCION"	, _oJson["itens"][_nPos]:GetJsonText("cdopcional")	, @_aLinha,	@_aAlterado, _lNovo )   
		Endif
       	Aadd( _aItens , _aLinha )
	Next
	If ! _lRet
		Break 
	Endif 	
	If Len(_aCabSC5) == 0 .Or. Len(_aItens) == 0 
		U_ZRETMsgJson("erropad","Nao foi possivel carregar parametos dos campos para o Pedido "+_cPedido+" !")
		_lRet := .F. 
		Break
	Endif	
	//Private lMsHelpAuto 	:= .T.  // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
	Private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
	Private lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog
	MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabPed, aItePed, _nOpc , .F.)

	If lMsErroAuto
		_cError := "Erro Padrao Pedido "+ _cPedido + CRLF
		// se estiver em debug, pega o log inteiro do erro para uma analise mais detalhada
		_aError := GetAutoGRLog()
		For _nPos := 1 To Len(_aError)
			If !Empty((AllTrim(_aError[_nPos])))  	
				_cError	+= 	AllTrim(_aError[_nPos]) + CRLF
			EndIf		
		Next _nPos			
		U_ZRETMsgJson("erropad",_cError)
		_lRet := .F. 
		RollBackSX8()	
		Break
	ElseIf _nopc == 3 
		ConfirmSX8()
	Endif
End Sequence

_aCampos	:= {}
_nReg 		:= If(_lRet,SC5->(RECNO()),0 ) 
_cMsg		:= ""
_nError		:= 0
If _lRet 
	_cStatus 	:=	"1"
	_cMsg 		:=  "Pedido "+_cPedido+If(_lNovo," Incluído"," Alterado")+" com Sucesso"+CRLF
	//Indica que alterou campos
	If Len(_aAlterado) > 0 
		_cMsg 	:= "Alteracoes cadastro de Clientes Responsavel "+_cResp+" em "+DtOC(Date())+" - "+Time()
		_cMsg 	+= CRLF
		For _nPos := 1 To Len(_aAlterado)
			_cMsg += _aAlterado[_nPos] +CRLF
		Next 
	Endif 
Else 
	_cStatus 	:=	"2"
	_cMsg 		:=  "Pedido "+_cPedido+If(_lNovo," para Inclusao"," Alteracao")+" com inconsistencia"+CRLF
	For _nPos := 1 To Len(_aMsgRet)
		_cMsg += _aMsgRet[_nPos,2]+CRLF
		If _nError == 0
			_nError := _aMsgRet[_nPos,1]
		Endif	
	Next
	_cMsg 		:=  "Pedido "+_cPediro+If(_lNovo," Incluído"," Alterado")+" com Sucesso"
Endif 
//Adiciono para gravar msgem de alteração
AAdd(_aCampos,{"Z1_MSGLOG"	, Upper(_cMsg)	})

//ZRESTPRVMonitor(_cStatus, "_cTab", _cDoc, _cMens, _cErro, _dDataIni, _cHsIni, _nErro, _nReg )
//ZRESTPRVMonitor(_cStatus, SC5, _cPedido, _cMsg, _cError, _dDataIni, _cHsIni, _nError, _nReg )


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

//localizar tabela de Veiculo
Static Function ZRESTPRVPTabela( _cCodMar, _cModVei, _cSegMod, _cFabMod)
Local _cAliasTab   := GetNextAlias()
Local _nValTab := 0
  	BeginSql Alias _cAliasTab
   		SELECT 	VVP.R_E_C_N_O_ NREGVVP
				,VVP.VVP_VALTAB
				.VVP.VVP_DATPRC
				,VVP.VVP_BASEST
   		FROM %Table:VVP% VVP
   		WHERE 	VVP.VVP_FILIAL = %xFilial:VVP%
			AND VVP.VVP_CODMAR = %Exp:_cCodMar%
			AND VVP.VVP_MODVEI = %Exp:_cModVei%
			AND VVP.VVP_SEGMOD = %Exp:_cSegMod%
			AND VVP.VVP_FABMOD = %Exp:_cFabMod%
			AND VVP.%NotDel%			
	      	AND VVP.VVP_DATPRC = (  SELECT MAX(VVPB.VVP_DATPRC)  "
	      	                         FROM %Table:VVP% VVPB 
	      	                          WHERE VVPB.VVP_FILIAL = VVP.VVP_FILIAL 
		     	                    	AND VVPB.VVP_CODMAR	= VVP.VVP_CODMAR 
		     	                        AND VVPB.VVP_MODVEI	= VVP.VVP_MODVEI 
		     	                        AND VVPB.VVP_SEGMOD	= VVP.VVP_SEGMOD 
	      	                           	AND VVPB.VVP_FABMOD	= VVP.VVP_FABMOD 
                              			AND VVPB.%NotDel% ) 
   	EndSql

	If (_cAliasTab)->(!Eof())
		VVP->((_cAliasTab)->NREGVVP)
		_nValTab := (_cAliasTab)->VVP_VALTAB
	Endif 
If Select((_cAliasTab)) <> 0
	(_cAliasTab)->(DbCloseArea())
	Ferase(_cAliasTab+GetDBExtension())
Endif 
Return _nValTab


//localizar relacionamento veicuo
Static Function ZRESTPRVRVeiculo(_cCodProd, _cCodMar, _cModVei, _cSegMod _cItem)
Local _cAliasPesq   := GetNextAlias()
Local _lRet			:= .F.		
Begin Sequence 

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
		Break 
	Endif 
	SB1->(DbGoto((_cAliasPesq)->NREGSB1))
	(_cAliasPesq)->(DbCloseArea())
	//localizar marca
	BeginSql Alias _cAliasPesq
		SELECT 	VV2.R_E_C_N_O_ AS NREGVV2
		FROM 	%Table:VV2% VV2
        WHERE 	VV2.%notDel% 
			AND VV2.VV2_FILIAL = %XFilial:VV2%
			AND VV2.VV2_CODMAR = %Exp:_cCodMar%
			AND VV2.VV2_MODVEI = %Exp:_cModVei%
			AND VV2.VV2_SEGMOD = %Exp:_cSegMod%
	EndSql      
	If (_cAliasPesq)->(Eof()) .And. (_cAliasPesq)->NREGVV2
		U_ZRETMsgJson("cdmodvei","Modelo de Veiculo não encontrado na tabela de Modelos para o item"+_cItem+" !")
		Break
	Endif
	VV2->(DbGoto((_cAliasPesq)->NREGVV2))
	(_cAliasPesq)->(DbCloseArea())
	//Localizar Veiculo
	BeginSql Alias _cAliasPesq
		SELECT 	VE1.R_E_C_N_O_ AS NREGVE1
		FROM 	%Table:VE1% VE1
        WHERE 	VE1.%notDel% 
			AND VE1.VE1_FILIAL = %XFilial:VE1%
			AND VE1.VE1_CODMAR = %Exp:_cCodMar%
	EndSql      
	If (_cAliasPesq)->(Eof()) .And. (_cAliasPesq)->NREGVE1
		U_ZRETMsgJson("cdmodvei","Veiculo não encontrado na tabela de vEÍCULOS para o item"+_cItem+" !")
		Break
	Endif
	(_cAliasPesq)->(DbCloseArea())
	//Localizar Descrição
	BeginSql Alias _cAliasPesq
		SELECT 	VVX.R_E_C_N_O_ AS NREGVVX
		FROM 	%Table:VE1% VE1
        WHERE 	VVX.%notDel% 
			AND VVX.VVX_FILIAL = %XFilial:VVX%
			AND VVX.VVX_CODMAR = %Exp:_cCodMar%
			AND VVX.VVX_SEGMOD = %Exp:_cSegMod%
	EndSql      
	If (_cAliasPesq)->(Eof()) .And. (_cAliasPesq)->NREGVVX
		U_ZRETMsgJson("cdmodvei","Tabela de descrição modelo não localizada não encontrado na tabela de vEÍCULOS para o item"+_cItem+" !")
		Break
	Endif
	_lRet := .T.
Endif 
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet 	


//localizar o tipo de operação
Static Function ZRESTPRVOper(_cOper, _cCodTes, _cItem, _cCodProd )
//Local _cAliasPesq   := GetNextAlias()
//Local _cTab 		:= "DJ"
Local _lRet			:= .T.
Local _cTesPar 		:= AllTrim(SuperGetMV("CAOA_AUT1C", ,'501'))
Local _cOper1  		:= AllTrim(SuperGetMV("CAOA_AUT1A", ,'92')
Local _cOper2 		:= AllTrim(SuperGetMV("CAOA_AUT1B", ,'93')
Local _cOperIni 	:= _cOper

	//Caso  tenha sido informado operação
	If !Empty(_cOper)
    	_cCodTes := MaTesInt(2, _cOper, SA1->A1_COD, SA1->A1_LOJA, "C", _cCodProd, "C6_TES") 
	Endif 
	//não localizou cod da TES com operação enviada REST
	If Empty(_cCodTes) .And. !Empty(_cOper1)
		_cOper 		:= _cOper1
    	_cCodTes 	:= MaTesInt(2, _cOper, SA1->A1_COD, SA1->A1_LOJA, "C", _cCodProd, "C6_TES") 
	Endif 
	//não localizou cod da TES com operação 1 pre definaida tentar com operação 2 pre definida
	If Empty(_cCodTes) .And. !Empty(_cOper2)
		_cOper 		:= _cOper2
    	_cCodTes 	:= MaTesInt(2, _cOper, SA1->A1_COD, SA1->A1_LOJA, "C", _cCodProd, "C6_TES") 
	Endif		
	//caso não localize ainda tenho a TES do parâmetro
	If Empty(_cCodTes) .And. !Empty(_cTesPar)
		_cCodTes 	: _cTesPar 
	Endif
	//Se continuar em branco problemas com TES
	If Empty(_cCodTes) .Or. Empty(_cOperIni)
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
@author 	DAC - Denilso
@since 
@version 	undefined
@param 		_oJson, _cTipo
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
Carrega Numero do Erro para retorno
@author 	DAC
@since 		
@version 	undefined
@param 
@type 		function
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
Static Function	ZRESTPRVMonitor(_cStatus, _cTab, _cDoc, _cMens, _cErro, _dDataIni, _cHsIni, _nErro, _nReg )	
Local _cUserName := "REST PEDIDO"   
Local _aCampos	 := {}  //Adicionar campos a serem gravador na tabela DAC  15/02/2023 

Default _cTab 		:= "SC5"
Default _dDataIni	:= Date()
Default _cHsIni		:= Time()

	//AAdd(_aCampos,{"Z1_NTPINTG"	, "ZRESTSA1" 	})
	U_CAOAGRVM(XFilial(_cTab),;		//Filail
				_cStatus,;				//Status
				"200",;					//Código do Processo  REST IMPORTACAO CLIENTES                          
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







/////////////////////////////////////////
//vERIFICAR SE UTILIZA DAC***

/*
=======================================================================================
Programa.:            VlrPret  
Autor....:              
Data.....:              
Descricao / Objetivo: Calcula o Valor Pretendido
=======================================================================================
*/

Static Function ZRESTPRCVPret(_cCodMar, _cModVei, _cSegMod, _nValTab, _nValPre, _nValMov,cCabAlias,lCalMov)
Local _cForm121 As Character

Default _lCalMNov := .F.

	_cForm121 := GetNewPar("MV_MIL0121","") //U_CMVVEI01()

	// Se o usuario zerar o valore pretendido, volta o valor de tabela...
	If nValPre == 0
		_nValMovimento := iif( _lCalMov, _nValMov, _nValTab)
	Else
		If Empty(_cForm121)
			_nValMovimento := iif( _lCalMov, _nValMov, _nValPre)//nValPre
		Else
			_nValMovimento 	:= iif( _lCalMov, _nValMov, _nValPre)//nValPre
			_nValorPre 		:= iif( _lCalMov, _nValMov, _nValPre)//nValPre // Valor utilizada na formula...
			_nValorMov 		:= CalcRev(_nValorPre, _cCabAlias)  //verificar funcionalidade

			If _nValorMov <> _nValPre
				_nValMovimento := _nValorMov
			EndIf
		EndIf
	EndIf
Return .T.



/* localização operação
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
		Aadd(_aMsgErro,"Nao localizado regra para a operacao "+_cOper+" referente ao item "+_cItem+" !") 
		_lRet .F.
	Else 
		SX5->(DbGoto((_cAliasPesq)->NREGSX5))

*/
