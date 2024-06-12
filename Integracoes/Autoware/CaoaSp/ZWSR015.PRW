#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Define CRLF  CHAR(13) + CHAR(10)

/*/{Protheus.doc} ZWSR015
Serviço de integração  Autoware 
Envio do XML da NF para Autoware
@author 	   DAC 
@since 		13/05/2022
@version 	undefined
@param		Não utilizado
@return     lRet			, caracter, JSON com tabelas.
@type       class
@client   	CAOA BARUERI
@project 	Interfaces_PortalV3_v2 x Protheus v2
Z  -Customizado
WS - Modulo
R  - resT OU W WebServer
010- Sequencial
/*/
WSRESTFUL ZWSR015 DESCRIPTION "Integração Autoware XML - NF" FORMAT APPLICATION_JSON 
   WSDATA empresa 		As String
	WSDATA filial 		As String
	WSDATA token    	As String
	WSDATA cnpj 		As String
	WSDATA doc        	As String
	WSDATA serie   		As String

	WSMETHOD POST ; 
	        DESCRIPTION "XML de NF enviada por Autoware";
	        WSSYNTAX "/ZWSR015"
END WSRESTFUL

WSMETHOD POST;
WSRECEIVE empresa, filial, token, cnpj, doc, serie;
WSSERVICE ZWSR015

Local oJsonRet 	  := JsonObject():New()
Local cJSON 	  := Self:GetContent()     // –> Pega a string do JSON
Local oParseJSON  := Nil
Local _cUsuario   := ""
Local _cSenha     := ""

Private aAuto	  := {}
Private _aRet	  := {}
Private _cDoc     := ""
Private _cSerie   := ""
Private _cCNPJ    := ""
Private _cToken   := ""
Private cXmlNf    := ""

    Conout("ZWSR015 - integraçao XML de NF Autoware POST - Inicio "+DtoC(date())+" "+Time())
    ::SetContentType('application/json')

    // –> Deserializa a string JSON
	FWJsonDeserialize(cJson, @oParseJSON)
    If Empty(oParseJSON:cdEmpresa) .Or. Empty(oParseJSON:cdFilial)
 		cErro := "Necessario informar os parametros empresa e filial, por favor, verifique!"
		SetRestFault(400, cErro)
		Return .T.
	EndIf

	//-- Tratar abertura da empresa conforme enviado no parametro
	If cEmpAnt <> AllTrim(oParseJSON:cdEmpresa) .or. cFilAnt <> AllTrim(oParseJSON:cdFilial)
    	RpcClearEnv() 
    	RPCSetType(3) 
        //RpcSetEnv(_cEmpresa, cxFilial,,,,GetEnvServer(),{ })
    	RpcSetEnv(AllTrim(oParseJSON:cdEmpresa),AllTrim(oParseJSON:cdFilial),,,,GetEnvServer(),{ })
	EndIf

    _cDoc     := oParseJSON:cdDocumento
    _cSerie   := oParseJSON:cdSerie
    _cCNPJ    := oParseJSON:cdCNPJ
    _cToken   := oParseJSON:Token
    _cUsuario := oParseJSON:usuario
    _cSenha   := oParseJSON:senha

	If Empty(_cUsuario) .or. AllTrim(_cUsuario) <> "caoa.totvs"
        oJsonRet['errorCode']	:= 400
        oJsonRet['errors']		:= 'Usuario não está autorizado a acessar os serviços Protheus!'
        ::SetResponse( oJsonRet:ToJson() )
        Break
	EndIf

    If Empty(_cSenha) .or. AllTrim(_cSenha) <> "CAgka2694X*"
        oJsonRet['errorCode']	:= 400
        oJsonRet['errors']		:= 'Senha invalida!'
        ::SetResponse( oJsonRet:ToJson() )
        Break
 	EndIf

    If Empty(_cToken) .or. AllTrim(_cToken) <> "AUTOWAREXTOTVS"
        oJsonRet['errorCode']	:= 400
        oJsonRet['errors']		:= 'Aplicação Web não está autorizada a acessar os serviços Protheus (Token Failed) !'
        ::SetResponse( oJsonRet:ToJson() )
        Break
 	EndIf

    If Empty(_cDoc) .or. Empty(_cSerie) 
        oJsonRet['errorCode']	:= 400
        oJsonRet['errors']		:= 'Documento ou Série não preenchidos !'
        ::SetResponse( oJsonRet:ToJson() )
        Break
 	EndIf

    If Empty(_cCNPJ) 
        oJsonRet['errorCode']	:= 400
        oJsonRet['errors']		:= 'CNPJ não preenchido !'
        ::SetResponse( oJsonRet:ToJson() )
        Break
 	EndIf

    If ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Franco da Rocha | Caoa
        If _cCNPJ <> '03471344000509' //CNPJ Caoa | Franco da Rocha
            oJsonRet['errorCode']	:= 400
            oJsonRet['errors']		:= 'CNPJ não pertencente a Caoa | Franco da Rocha !'
            ::SetResponse( oJsonRet:ToJson() )
            Break
 	    EndIf
    ElseIf ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) //Empresa Franco da Rocha | HMB Hyundai
        If _cCNPJ <> '10394422000657' //CNPJ HMB | Franco da Rocha
            oJsonRet['errorCode']	:= 400
            oJsonRet['errors']		:= 'CNPJ não pertencente a HMB | Franco da Rocha !'
            ::SetResponse( oJsonRet:ToJson() )
            Break
 	    EndIf
    EndIf

    _aRet := ValidOJson(cJson, _cDoc, _cSerie)     

    IF !Empty(cXmlNf)

        oJsonRet['xml']	:= cXmlNf
        oJsonRet['errorCode']	:= 200
        oJsonRet['Message'] 	:= "XML de NF recebida com sucesso!"

        ::SetResponse( oJsonRet:ToJson() )
    Else
        oJsonRet['errorCode']	:= 400
        oJsonRet['errors']		:= 'Não foi possivel gerar o  XML !'
        ::SetResponse( oJsonRet:ToJson() )
    EndIF

	//Erro no programa
  	/*If Len(_aRet) == 0 
		//SetRestFault(999,"Problemas em relação ao retorno Rest, verificar com administrador !")
      
        oJsonRet := JsonObject():new()
        oJsonRet['errorCode']      := 999
        oJsonRet['errorMessage']   := "Problemas em relação ao retorno Rest, verificar com administrador !"

        ::SetResponse( oJsonRet:ToJson() )
            
        Break
	EndIf*/

    Conout("ZWSR015 - integraçao XML de NF Autoware POST - Final "+DtoC(date())+" "+Time())

Return .T.


/*/{Protheus.doc} ValidOJson
Valida os dados do oJson
@author DAC - Denilso
@since 
@version undefined
@param _cDoc, _cSerie, _cCNPJ 
@param cMsg, characters, descricao
@type function
/*/
Static Function ValidOJson(cJson, _cDoc, _cSerie)
Local qryNF     := ' '
Local _cQuery   := ' '
Local _lHmb     := AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1"

    qryNF := GetNextAlias()

    //While ( Select(qryNF) <> 0 )
    //    dbSelectArea(qryNF)
    //    (qryNF)->(dbCloseArea())
    //    qryNF := GetNextAlias()
    //EndDo

	_cQuery := "SELECT F2.*, F2.R_E_C_N_O_ RECF2, VS1_FILIAL, VS1_NUMNFI, VS1_SERNFI, VS1_CLIFAT, VS1_LOJA, VS1_XTPPED, VS1_NUMPED,A1_CGC" + CRLF
	_cQuery += "FROM "+ RetSQLname("SF2") +" F2," + RetSQLname("VS1") +" VS1 " + CRLF    
	_cQuery += "INNER JOIN "+ RetSQLname("SA1") +" A1 "
    _cQuery += " ON VS1.VS1_CLIFAT  = A1.A1_COD "
    _cQuery += " AND VS1.VS1_LOJA   = A1.A1_LOJA"
    _cQuery += " AND A1.D_E_L_E_T_  =   ' '     "
	_cQuery += "WHERE VS1.D_E_L_E_T_  = ' '     "                  + CRLF
    _cQuery += "   AND VS1.VS1_FILIAL = '" + xfilial("VS1") + "'"  + CRLF
	_cQuery += "   AND VS1.VS1_NUMNFI = '" + _cDoc          + "'"  + CRLF
	_cQuery += "   AND VS1.VS1_SERNFI = '" + _cSerie        + "'"  + CRLF
	_cQuery += "   AND F2.F2_CLIENTE  = VS1.VS1_CLIFAT   "         + CRLF
	_cQuery += "   AND F2.F2_LOJA     = VS1.VS1_LOJA     "         + CRLF
    _cQuery += "   AND F2.F2_DOC      = VS1.VS1_NUMNFI   "         + CRLF
    _cQuery += "   AND F2.F2_SERIE    = VS1.VS1_SERNFI   "         + CRLF
	_cQuery += "   AND F2_CHVNFE      <> ' '       "               + CRLF
	_cQuery += "   AND F2_FIMP        = 'S'        "               + CRLF
 	_cQuery += "   AND F2.D_E_L_E_T_ = ' '         "               + CRLF 
	_cQuery += "  ORDER BY F2.F2_EMISSAO desc      "               + CRLF
	_cQuery := ChangeQuery(_cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),qryNF,.T.,.T.)

    While (qryNF)->(!EOF())

		cFilAnt := (qryNF)->F2_FILIAL
 
        IF UsaColaboracao("1")
            cXmlNf:= XML_COL((qryNF)->RECF2)
        Else
            If _lHmb
                cXmlNf := MProcDanfe( _oSay )
            Else      
                cXmlNf := fConsXml((qryNF)->F2_DOC, (qryNF)->F2_SERIE, (qryNF)->F2_EMISSAO, (qryNF)->A1_CGC)
            Endif
        EndIF

        //U_CAOA_MONITOR( cFilant  ,cRet,'001','004',cErro, Alltrim(qryNF->F2_DOC+qryNF->F2_SERIE) ,'0',cSoap ,qryNF->RECF2)
        (qryNF)->(dbSkip())

	EndDo

    If Select(qryNF) <> 0
	    (qryNF)->(DbCloseArea())
	    Ferase(qryNF+GetDBExtension())
    Endif 

Return(cXmlNf)


**********************************************************************************************************
Static Function XML_COL(RECF2)
Local _cQCol := ' '
Local cqxml  := GetNextAlias()
   
    SF2->(dbGoto(RECF2))					

    _cQCol := "SELECT CKOCOL.R_E_C_N_O_ RECCKO " + CRLF 
    _cQCol += "FROM "+ RetSQLname("CKOCOL") + " CKOCOL " + CRLF 
    _cQCol += "    INNER JOIN " + RetSQLname("CKQ") + " CKQ "         + CRLF 
    _cQCol += "        ON CKQ.CKQ_FILIAL  = '" + SF2->F2_FILIAL + "'" + CRLF   
    _cQCol += "		   AND CKQ.CKQ_NUMERO = '" + SF2->F2_DOC    + "'" + CRLF          
    _cQCol += "		   AND RTRIM(LTRIM(CKQ.CKQ_SERIE,'0')) = '" + RTRIM(LTRIM(SF2->F2_SERIE)) + "'"  + CRLF
    _cQCol += "		   AND CKQ.CKQ_TP_MOV = '1'   "    + CRLF
    _cQCol += "		   AND CKQ.CKQ_CODEDI = '170' "    + CRLF
    _cQCol += "		   AND CKQ.CKQ_STATUS = '2'   "    + CRLF 
    _cQCol += "		   AND CKQ.D_E_L_E_T_ = ' '   "    + CRLF
    _cQCol += "WHERE "  + CRLF
    _cQCol += "		CKOCOL.CKO_FILIAL = '" + xFilial("CKOCOL")  + "'" + CRLF
    _cQCol += "		AND CKOCOL.CKO_ARQUIV = CKQ.CKQ_ARQUIV "    + CRLF
    _cQCol += "		AND CKOCOL.CKO_STATUS = CKQ.CKQ_STATUS "    + CRLF 
    _cQCol += "		AND CKOCOL.D_E_L_E_T_ = ' ' "               + CRLF

    _cQCol := ChangeQuery(_cQCol)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQCol),cqxml,.T.,.T.)
    dbSelectArea(cqxml)

    CKO->(dbSetOrder(1))
    CKO->(dbGoTo((cqxml)->RECCKO))         //ir p/ o registro da CKQ  27

    cXMLnf := AllTrim(CKO->CKO_XMLRET)   //Carregar XML

    If Empty(cXMLnf)
        cXMLnf := AllTrim(CKO->CKO_XMLENV)   //Carregar XML
    EndIf

    If Select(cqxml) <> 0
        (cqxml)->(DbCloseArea())
        Ferase(cqxml+GetDBExtension())
    Endif 

Return(cXMLnf)


/////////////////////////====================

/*/{Protheus.doc} MProcDanfe
Processar a Danfe e enviar e-mail
@author 
@since 
@version 1.0
@Obs
@History
/*/
Static Function MProcDanfe( _oSay )
Local nA         	:= 0
//Local cMensagem  	:= ""
Local cDir       	:= SuperGetMV('MV_RELT',,"\SPOOL\")
Local cNomeArquivo  := ""
//Local _aEnvia		:= {}
Local _lRet 

Private cPegaXml   := ""  //Obtido dentro da rotina da Danfe (danfeii.prw - PrtNfeSef). tem que existir uma variavel Private nestga função
Private cXMensagem := ""

Begin Sequence
    If  FindFunction("ColUsaColab")
        lUsaColab := ColUsaColab("1")
    EndIf
    //
    XSpedDanfe(0/*nTipo*/, 2/*nPar*/, @cNomeArquivo, @cDir)
    If  !File(cDir + cNomeArquivo + ".pdf")
    	Do  While (++nA < 5)
        	Sleep(1000)  //espera pelo pdf
        	If  File(cDir + cNomeArquivo + ".pdf")
            	Exit
        	EndIf
    	EndDo
	Endif
    If  !( File(cDir + cNomeArquivo + ".pdf") )
		_cMens := If(!Empty(cXMensagem), cXMensagem, "Problemas para gerar o arquivo "+cNomeArquivo+" na pasta "+cDir+" ref. a NF/SERIE  "+SF2-F2_DOC+"/"+SF2->F2_SERIE+ " ! ")
		_lRet := .F.
        Break
    EndIf

End Sequence
Return cPegaXml



/*/{Protheus.doc} XSpedDanfe
Adaptado para gerar o pdf da Danfe via job.
@author Antonio C Ferreira
@since 24/06/2021
@version 1.0
Obs
History
/*/
STATIC Function XSpedDanfe(nTipo, nPar, cFilePrint, cDir, _cPasta)
Local cIdEnt 		:= ""
Local aIndArq   	:= {}
Local aDevice  		:= {}
Local cSession  	:= GetPrinterSession()
//Local nRet 			:= 0
Local lUsaColab		:= ColUsaColab("1")
local cBarra		:= ""
local nX 			:= 0
local lJob			:= .T. //isBlind()
local lDanfeII		:= findfunction("u_PrtNfeSef")
local lDanfeIII		:= findfunction("u_DANFE_P1")
local cMsgVld		:= ""
Local oDanfe
Local oSetup

Default nTipo		:= 0
Default nPar		:= 0
Default cFilePrint	:= ""
Default cDir 		:= SuperGetMV('MV_RELT',,"\SPOOL\")

Private lNaoPreview := .T.  //Para nao abrir o pdf.
Private oXTemLog    := Nil

	/*
	If findfunction("U_DANFE_V") .and. if(lJob, nPar == 1, .T.)
		nRet := U_Danfe_v()
	Elseif findfunction("U_DANFE_VI") .and. if(lJob, nPar == 2, .T.)// Incluido esta validaþÒo pois o cliente informou que nÒo utiliza o DANFEII
		nRet := U_Danfe_vi()
	EndIf
	*/
	AADD(aDevice,"DISCO") // 1
	AADD(aDevice,"SPOOL") // 2
	AADD(aDevice,"EMAIL") // 3
	AADD(aDevice,"EXCEL") // 4
	AADD(aDevice,"HTML" ) // 5
	AADD(aDevice,"PDF"  ) // 6

	cIdEnt := RetIdEnti(lUsaColab)
	cFilePrint := "DANFE_"+AllTrim(SF2->F2_DOC)+Dtos(MSDate())+StrTran(Time(),":","")
	nLocal       	:= If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
	nOrientation 	:= If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
	cDevice     	:= If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
	nPrintType      := aScan(aDevice,{|x| x == cDevice })
	//+-------------------------------------------+
	//|Ajuste no pergunte NFSIGW                  |
	//+-------------------------------------------+
	//AjustaSX1()

	cBarra := "\"
	if IsSrvUnix()
		cBarra := "/"
	Endif
	If  CTIsReady(,,,lUsaColab)
		dbSelectArea("SF2")
		RetIndex("SF2")
		dbClearFilter()
		//+------------------------------------------------------------------------+
		//|Obtem o codigo da entidade                                              |
		//+------------------------------------------------------------------------+
		If  .T. //nRet >= 20100824
			If Empty(cDir)
				cDir := SuperGetMV('MV_RELT',,"\SPOOL\")
			Endif 

			if !empty(cDir) .and. !ExistDir(cDir)
				aDir := StrTokArr(cDir, cBarra)
				cDir := ""
				for nX := 1 to len(aDir)
					cDir += aDir[nX] + cBarra
					if !ExistDir(cDir)
						MakeDir(cDir)
					endif
				next
			Endif
			If  (nTipo <> 1)
				lAdjustToLegacy := .F. // Inibe legado de resoluþÒo com a TMSPrinter
				oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, cDir /*cPathInServer*/, .T. )
				//cFilePrint := cDir + cFilePrint
				//File2Printer( cFilePrint, "PDF" )
				oDanfe:cPathPDF := cDir

				if  lJob
					oDanfe:SetViewPDF(.F.)
					oDanfe:lInJob := .T.
				endif
				// ----------------------------------------------
				// Cria e exibe tela de Setup Customizavel
				// OBS: Utilizar include "FWPrintSetup.ch"
				// ----------------------------------------------
				//nFlags := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
				nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
				If ( !oDanfe:lInJob )
					oSetup := FWPrintSetup():New(nFlags, "DANFE")
					// ----------------------------------------------
					// Define saida
					// ----------------------------------------------
					oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
					oSetup:SetPropert(PD_ORIENTATION , nOrientation)
					oSetup:SetPropert(PD_DESTINATION , nLocal)
					oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
					oSetup:SetPropert(PD_PAPERSIZE   , 2)

					If ExistBlock( "SPNFESETUP" )
						Execblock( "SPNFESETUP" , .F. , .F. , {oDanfe, oSetup} )
					Endif
				EndIf
				// ----------------------------------------------
				// Pressionado botÒo OK na tela de Setup
				// ----------------------------------------------
				If lJob .or. oSetup:Activate() == PD_OK // PD_OK =1
					//+-------------------------------------------+
					//|Salva os Parametros no Profile             |
					//+-------------------------------------------+
					fwWriteProfString( cSession, "LOCAL"      , if( lJob, "SERVER"		, If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    )), .T. )
					fwWriteProfString( cSession, "PRINTTYPE"  , if( lJob, "PDF"		, If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       )), .T. )
					fwWriteProfString( cSession, "ORIENTATION", if( lJob, "PORTRAIT"	, If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" )), .T. )
					// Configura o objeto de impressÒo com o que foi configurado na interface.
					oDanfe:setCopies( val( if( lJob, "1", oSetup:cQtdCopia )) )
	                //oXTemLog := XTemLog():New("001")
					If  .T. //( lJob .and. nPar == 1 ) .or. ( !lJob .and. oSetup:GetProperty(PD_ORIENTATION) == 1 )
						//+-------------------------------------------+
						//|Danfe Retrato DANFEII.PRW                  |
						//+-------------------------------------------+
						if(lDanfeII, u_PrtNfeSef(cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,cFilePrint , .T./*lIsLoja*/, /*nTipo*/), cMsgVld := "Fonte de impressÒo de DANFE nÒo compilado !")
					ElseIf ( lJob .and. nPar == 2 ) .or. !lJob
						//+-------------------------------------------+
						//|Danfe Paisagem DANFEIII.PRW                |
						//+-------------------------------------------+
						if(lDanfeIII, u_DANFE_P1(cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,/*lIsLoja*/ ), cMsgVld := "Fonte de impressÒo de DANFE nÒo compilado !" )
					EndIf
				Endif
			ElseIf nTipo == 1
				if(lDanfeII, U_PrtNfeSef(cIdEnt ,/*cVal1*/ ,/*cVal2*/ , , , ,/*lIsLoja*/, 1), cMsgVld := "Fonte de impressÒo de DANFE nÒo compilado !")
			EndIf
		Else
			if(lDanfeII, U_PrtNfeSef(cIdEnt ,/*cVal1*/ ,/*cVal2*/ , , , ,/*lIsLoja*/), cMsgVld := "Fonte de impressÒo de DANFE nÒo compilado !")
		EndIf
		if !lJob
			if !empty(cMsgVld)
				Help(NIL, NIL, "RDMAKE", NIL, cMsgVld, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Acesse o portal do cliente baixe os fontes DANFEII.PRW, DANFEIII.PRW e compile em seu ambiente"})
			endif
			Pergunte("NFSIGW",.F.) 
			if  .F. //len(aFilBrw) > 0
				bFiltraBrw := {|| FilBrowse(aFilBrw[1],@aIndArq,@aFilBrw[2])}
				Eval(bFiltraBrw)
			endif
		EndIf
	EndIf
oDanfe := Nil
oSetup := Nil
//Limpa arquivos temporarios .rel da pasta MV_RELT
//SpedCleRelt()
Return .T.



//Modelo do JSon
/*
{
"usuario": "caoa.totvs",/
"senha": "CAgka2694X*",
"Token":"AUTOWAREXTOTVS",
"cdEmpresa":"02",
"cdCNPJ":"13007583000124",
"cdDocumento":"000000001",
"cdSerie":"7  "
}
*/
