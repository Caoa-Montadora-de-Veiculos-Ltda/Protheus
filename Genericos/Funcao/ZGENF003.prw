#include "tryexception.ch"

#Define CRLF  CHAR(13) + CHAR(10)

User Function ZGENF003(cGrp, cUsr )
	Local nDest    := 0
	Local oRep	   := Nil
	Local i        := 1
	Local cAux     := ""
	Local xIdRel   := 0
	Local oXmlSai  := Nil
	Local cNo		:= "COMMAND"
	Local aRel     := {}
	Local aParmE   := {}
	Local aParmS   := {}
	Private lLayoutNv := .F.
	Private aOxml  := {}
	Private aFiles := {}
	Private aRels  := {}

	If Len(GetApoInfo("zgenf004.PRW")) = 0
		ApMsgInfo("Nao achei compilada a funcao XMLSQL")
		Return "Nao achei compilada a funcao XMLSQL"
	EndIf

	If FindFunction("u_ZGENEXCEL") = .F.
		ApMsgInfo("Nao achei compilada a funcao u_ZGENEXCEL")
		Return "Nao achei compilada a funcao u_ZGENEXCEL"
	EndIf

	// carregar os relatórios
	FWMsgRun(, {|| zGetMenus(cUsr, cGrp) },"", "Obtendo configurações..." )

	if Len(aRels) <= 0
		ApMsgInfo("Nenhuma consulta associada para seu usuário ou grupo.", "cReports")
		Return
	EndIf

	// Escolher o relatório
	xIdRel := zGetParambox({"Selecione o relatório", { {2, "Informe a consulta:", 1, aRels, 100, "", .T.} }}, nDest )

	if Len(xIdRel) = 0
		Return "Cancelado"
	Else
		xIdRel := xIdRel[1]
	EndIf

	// setar para 2 para aparecer o destino
	nDest := 1

	// Get o Id do relatório
	xIdRel := aScan( aRels, xIdRel)

	aParmE  := zGetParRel(xIdRel)

	aParmS  := zGetParambox(aParmE, @nDest)

	If Len(aParmS) = 0
		Return "Cancelado"
	EndIf

	If lLayoutNv = .T.
		cNo := "CSQL"
		For i:= 1 to Len(aParmE)
			aParmS[i] :=  {aParmS[i],  Alltrim(aParmE[2,i, Len(aParmE[2,i])])  }
		Next
	Endif

	oXmlSai := XmlSql():new(aFiles[xIdRel])

	FWMsgRun(, {|| aRel := oXmlSai:GetArray(cNo, aParmS, lLayoutNv) }, "", "Obtendo Dados..." )

	If Len(aRel[2]) > 0

		if nDest = 1
			u_ZGENEXCEL(aRel[1], aRel[2], zNo(aOxml[xIdRel]:_xml:_name:text), zNo(aOxml[xIdRel]:_xml:_name:text) )
		Else
			oRep := RptDef(zNo(aOxml[xIdRel]:_xml:_name:text), zNo(aOxml[xIdRel]:_xml:_name:text), aRel )
			oRep:PrintDialog()
		EndIf
	Else

		For i:=1 to Len(aParmE[2]) -1
			If lLayoutNv = .F.
				cAux += "- " + AllTrim(aParmE[2, i, 2]) + " <font color=red>" + aParmS[i] + "</font>" + CRLF
			Else
				cAux += "- " + AllTrim(aParmE[2, i, 2]) + " <font color=red>" + aParmS[i,1] + "</font>" + CRLF
			EndIf
		Next

		FWAlertError("Sem resultados para essa consulta, com esses parâmetros" + CRLF + cAux, "" )
	EndIf

Return


Static Function zGetParRel(nIdRel)
	Local oXml   := aOxml[nIdRel]
	Local cName  := ""
	Local aPar   := {}
	Local aItPar := {}
	Local i      := 1

	cName :=  zNo(oXml:_xml:_name:Text)

	If XmlChildEx(oXml:_xml, "_CSQL") <> Nil
		lLayoutNv := .T.
	Endif

	If XmlChildEx(oXml:_xml, "_PARAM") <> Nil
		aItPar :={}
		If ValType(oXml:_xml:_param) == "O"
			aItPar := zGeraPar(oXml:_xml:_param, 1)
			If Len(aItPar) > 0
				Aadd(aPar, aItPar)
			EndIf
		Else
			For i:= 1 to Len(oXml:_xml:_param)
				aItPar := zGeraPar(oXml:_xml:_param[i], i)
				If Len(aItPar) > 0
					Aadd(aPar, aItPar)
				EndIf
			Next
		EndIf
	EndIf

Return {cName, aPar}


Static Function zGeraPar(oNo, nParam)
	Local aRes := {}
	// artigo no blackTDN com a espeficicação do PARAMBOX
	// http://www.blacktdn.com.br/2012/05/para-quem-precisar-desenvolver-uma.html#ixzz6cNTQowGF
	If oNo:_nTipo:text == "1"
		Aadd(aRes, 1)                                   //  [1]-Tipo 1 msget
		Aadd(aRes, zNo(oNo:_cDescricao:text) )          //  [2]-Descricao
		Aadd(aRes, &(zNo(oNo:_bRelacao:text))   )       //  [3]-String contendo o inicializador do campo
		Aadd(aRes, zNo(oNo:_cPicture:text)   )          //  [4]-String contendo a Picture do campo
		Aadd(aRes, zNo(oNo:_cValid:text)     )          //  [5]-String contendo a validacao
		Aadd(aRes, zNo(oNo:_cF3:text)        )          //  [6]-Consulta F3
		Aadd(aRes, zNo(oNo:_bWhen:text)      )          //  [7]-String contendo a validacao When
		Aadd(aRes, Val(zNo(oNo:_nTamanho:text)) )     //  [8]-Tamanho do MsGet
		Aadd(aRes, Iif(zNo(oNo:_lObrigatorio:text) $ ".T.", .T., .F.)  )    //  [9]-Flag .T./.F. Parametro Obrigatorio ?

	ElseIf oNo:_nTipo:text == "2"
		Aadd(aRes, 2)                                       // Tipo 2 -> Combo
		Aadd(aRes, zNo(oNo:_cDescricao:text) )              // [2]-Descricao
		Aadd(aRes, Val(zNo(oNo:_nOpcInicial:text)) )        // [3]-Numerico contendo a opcao inicial do combo
		Aadd(aRes, StrTokArr(zNo(oNo:_aOpcoes:text), ";") ) // [4]-Array contendo as opcoes do Combo
		Aadd(aRes, Val(zNo(oNo:_nTamanho:text)) )           // [5]-Tamanho do Combo
		Aadd(aRes, zNo(oNo:_cValid:text))                   // [6]-Validacao
		Aadd(aRes, Iif(zNo(oNo:_lObrigatorio:text) $ ".T.", .T., .F.)  )     //[7]-Flag .T./.F. Parametro Obrigatorio ?

	ElseIf oNo:_nTipo:text == "3"
		Aadd(aRes, 3)                                       // Tipo 3 -> Radio
		Aadd(aRes, zNo(oNo:_cDescricao:text))				// [2]-Descricao
		Aadd(aRes, Val(zNo(oNo:_nOpcInicial:text)))			// [3]-Numerico contendo a opcao inicial do Radio
		Aadd(aRes, StrTokArr(zNo(oNo:_aOpcoes:text), ";"))	// [4]-Array contendo as opcoes do Radio
		Aadd(aRes, Val(zNo(oNo:_nTamanho:text)))			// [5]-Tamanho do Radio
		Aadd(aRes, zNo(oNo:_cValid:text))					// [6]-Validacao
		Aadd(aRes, Iif(zNo(oNo:_lObrigatorio:text) $ ".T.", .T., .F.)  )//           [7]-Flag .T./.F. Parametro Obrigatorio ?

	ElseIf oNo:_nTipo:text == "4"
		Aadd(aRes, 4)										// Tipo 4 -> Say + CheckBox
		Aadd(aRes, zNo(oNo:_cDescricao:text))				// [2]-Descricao
		Aadd(aRes, Iif( ".T." $ zNo(oNo:_lOpcInicial:text), .T., .F.)) // [3]-Indicador Logico contendo o inicial do Check
		Aadd(aRes, zNo(oNo:_cTexto:text))				     // [4]-Texto do CheckBox
		Aadd(aRes, Val(zNo(oNo:_nTamanho:text)))			// [5]-Tamanho do Radio
		Aadd(aRes, zNo(oNo:_cValid:text))					// [6]-Validacao
		Aadd(aRes, Iif(zNo(oNo:_lObrigatorio:text) $ ".T.", .T., .F.)  )//           [7]-Flag .T./.F. Parametro Obrigatorio ?

	ElseIf oNo:_nTipo:text == "5"
		Aadd(aRes, 5)										// Tipo 5 -> Somente CheckBox
		Aadd(aRes, zNo(oNo:_cDescricao:text))				// [2]-Descricao
		Aadd(aRes, Iif(zNo(oNo:_lOpcInicial:text) $ ".T.", .T., .F.)) // [3]-Indicador Logico contendo o inicial do Check
		Aadd(aRes, Val(zNo(oNo:_nTamanho:text)))			// [4]-Tamanho do Radio
		Aadd(aRes, zNo(oNo:_cValid:text))					// [5]-Validacao
		Aadd(aRes, Iif(zNo(oNo:_lObrigatorio:text) $ ".T.", .T., .F.)  )//           [6]-Flag .T./.F. Parametro Obrigatorio ?

	ElseIf oNo:_nTipo:text == "6"
		Aadd(aRes, 6)										// Tipo 6 -> File
		Aadd(aRes, zNo(oNo:_cDescricao:text))				// [2]-Descricao
		Aadd(aRes, &(zNo(oNo:_bRelacao:text))   )       	// [3]-String contendo o inicializador do campo
		Aadd(aRes, zNo(oNo:_cPicture:text)   )     			// [4]-String contendo a Picture do campo
		Aadd(aRes, zNo(oNo:_cValid:text)   )     			// [5]-String contendo a Valid
		Aadd(aRes, &(zNo(oNo:_bWhen:text)))					// [6]-String contendo a validacao When
		Aadd(aRes, Val(zNo(oNo:_nTamanho:text)))			// [7]-Tamanho do MsGet
		Aadd(aRes, Iif(zNo(oNo:_lObrigatorio:text) $ ".T.", .T., .F.)  )// [8]-Flag .T./.F. Parametro Obrigatorio ?
		Aadd(aRes, zNo(oNo:_cTipoArq:text))					// [9]-Texto contendo os tipos de arquivo, exemplo: "Arquivos .CSV |*.CSV"
		Aadd(aRes, zNo(oNo:_cDirInicio:text))				// [10]-Diretorio inicial do cGetFile
		Aadd(aRes, Val(zNo(oNo:_cTpVisao:text)))				// [11]-Número relativo a visualização, podendo ser por diretório ou por arquivo (0,1,2,4,8,16,32,64,128)

	ElseIf oNo:_nTipo:text == "9"
		Aadd(aRes, 9)										// Tipo 9 -> Somente mensagem
		Aadd(aRes, zNo(oNo:_cDescricao:text))				// [2]-Descricao
		Aadd(aRes, Val(zNo(oNo:_nLargula:text)))			// [3]-Largula
		Aadd(aRes, Val(zNo(oNo:_nAltura:text)))				// [4]-Altura
		Aadd(aRes, Iif(zNo(oNo:_lVerdana:text) $ ".T.", .T., .F.)  ) //  [5]-Logico .f. = verdana .t.=arial
	EndIf

	If lLayoutNv = .T.
		If XmlChildEx(oNo, "_CSQLPARAM")  <> NIL
			Aadd(aRes, oNo:_cSqlParam:text )
		Else
			FWAlertError("Falta a chave <cSqlParam> no parâmetro " + CValToChar(nParam), "")
			Aadd(aRes, ":xczxczxczczxczzc" )
		EndIf
	Endif

Return aRes

Static Function zGetParambox(aPar, nDest)
	Local aParm     := aPar[2]
	Local cTitulo   := Alltrim(aPar[1]) + " -"
	Local aRt		:= {}
	Local bOk       := {||.T.}
	Local aButtons  := {}
	Local lCentreed := .T.
	Local nPosX 	:= 0
	Local nPosY 	:= 0
	Local oDlgWz    := Nil
	Local cLoad     := ""
	Local lCanSave  := .F.
	Local lUserSave := .F.
	Local aResp     := {}
	Local i         := 1

	If nDest > 0
		Aadd(aParm, {3, "Destino", nDest, {"Exporta Excel", "Impressão"}, 90, "", .F.})
	EndIf

	If ParamBox(aParm, cTitulo, @aRt, bOk, aButtons, lCentreed, nPosX, nPosY, oDlgWz, cLoad, lCanSave, lUserSave)
		aResp := aRt
	Else
		Return  {}
	EndIf

	// Corrija o campo quando é parambox
	For i:= 1 To Len(aResp) - nDest

		If aParm[i, 1] = 2  // tipo COMBO
			//If Type("MV_PAR" + PadL(1, 2, "0")) == "N"
			If ValType(aRt[i]) == "N"
				aResp[i] := aParm[i, 4, 1 ]
			EndIf
		EndIf

		If aParm[i, 1] = 3  // TIPO RADIO
			aResp[i] := aParm[i, 4, aResp[i] ]
		EndIf

		//  SE for Data faz DTos()
		If ValType(aResp[i]) == "D"
			aResp[i] := Dtos( aResp[i] )
		EndIf

		If ValType(aRt[i]) == "L"  // Campo Logico
			aResp[i] := Iif( aResp[i] = .T. ,  ".T.", ".F.")
		EndIf

		aResp[i] := Alltrim(aResp[i])
	Next

	If nDest > 0
		nDest := aResp[Len(aResp)]
	EndIf

Return aResp

Static Function zCheckAcesso(cDir, cArq, cUsr, cGrp)
	Local cUser  	:= Iif( Empty(cUsr) = .F., cUsr, RetCodUsr() )
	Local cGroup 	:= Iif( Empty(cGrp)= .F., cGrp, Iif( Len(UsrRetGrp(cUser)) >0,  UsrRetGrp(cUser)[1], "") )
	Local cReplace := ""
	Local cErros 	:= ""
	Local cAvisos 	:= ""

	TRY EXCEPTION
		oXml := XmlParser(MemoRead(cDir + cArq), cReplace, @cErros, @cAvisos)

		If File(cDir + cArq) = .F.
			cErros := "Arquivo " + cDir + cArq + " não existe."
		EndIf

		if (cErros <> "") .or. (cAvisos <> "")
			cRes := "Houve problema ao carregar o Xml do arquivo " + cArq + CRLF + "Erros : " + cErros + CRLF + "Avisos: " + cAvisos
			ApMsgInfo(cRes, "cReports")
			oXml := .F.
		EndIf

		If (cUser $ zNo(oXml:_xml:_users:Text)) = .T. .OR. (cGroup $ zNo(oXml:_xml:_groups:text) ) = .T.
			Aadd(aRels, zNo(oXml:_xml:_name:Text))
			Aadd(aOxml, oXml)
			Aadd(aFiles, cArq)
		EndIf
	CATCH EXCEPTION USING oError
		ApMsgInfo( ProcName() + " " + Str(ProcLine()) + " " + oError:Description, FunName() )
		Conout( ProcName() + " " + Str(ProcLine()) + " " + oError:Description )
	END TRY

Return

Static Function zNo(cNo)
	cNo := Strtran(cNo, char(13), "") //CR
	cNo := Strtran(cNo, char(10), "") //LF
	cNo := Strtran(cNo, char(09), "") //TAB
	cNo := Alltrim(cNo)
Return cNo

Static Function zGetMenus(cUsr, cGrp)
	Local cDir      := "\_XmlSql\"
	Local i			:= 1
	Local aNomesArq	:= {}
	Local aTamanhos := {}
	Local aDatas	:= {}
	Local aHoras	:= {}
	Local aAtributos:= {}
	Local lChangeCase:= .T.

	ADir(cDir + "*.xml", @aNomesArq, @aTamanhos, @aDatas, @aHoras, @aAtributos, @lChangeCase )

	For i:= 1 to Len(aNomesArq)
		zCheckAcesso(cDir, aNomesArq[i], cUsr, cGrp)
	Next

Return

Static Function RptDef(cTitulo, cDescricao, aRel)
	Local cAlign    := ""
	Local i         := 1
	Local lUmaLinha := .F.
	Local oSection 	:= Nil
	Local aStru     := aRel[3]
	Local aTit      := aRel[1]

	oRep := TReport():New(cTitulo, cDescricao , "", {|oRep| ReportPrint(oRep, aRel) }, cDescricao)
	oRep:cFontBody	:= 'Courier New'
	oRep:nFontbody 		:= 9
	oRep:oPage:setPaperSize(10)
	oRep:SetLandscape()
	oRep:SetTotalInLine(.F.)
	oRep:SetDevice(2) // 2 impressora
	oRep:SetEnvironment( 2 ) // 2 client
	oRep:setPreview(.T.)
	oRep:HideParamPage()
	oRep:SetTotalInLine(.F.)
//                           oParent,   cTitle, uTable,	aOrder, lLoadCells,lLoadOrder, uTotalText, lTotalInLine, lHeaderPage, lHeaderBreak, lPageBreak, lLineBreak, nLeftMargin, lLineStyle, nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage
	oSection:= TRSection():New( oRep, "CABECA",     "",     {},        .F.,       .F.,         "",          .F.,         .F.,          .f.,        .T.,           ,           0,        .F.,         0,      .T.)

	For i:=1 to Len(aStru)
		cAlign := Iif(aStru[i,2] == "N", "RIGHT", "LEFT")

		TRCell():New(oSection, aStru[i ,1], "", aTit[i], GetSx3Cache(aStru[i,1], "X3_PICTURE"),  aStru[i, 3] , , , cAlign, lUmaLinha)
	Next
Return oRep



/*===================================================================================
Programa.:              RptDef
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Monta o relatorio
===================================================================================== */
Static Function ReportPrint(oRep, aRel)
	Local i,j       := 0
    Local oSection  := oRep:Section(1)
    Local aStru     := aRel[3]
	Local aDados	:= aRel[2]

    oSection:Init()

    oRep:SetMeter( Len(aDados))

	For i:=1 to Len(aDados)
        
		For j:=1 to Len(aStru)
        	oSection:Cell(aStru[j,1]):SetValue( aDados[i, j])
		Next

        oSection:Printline()
        oRep:IncMeter()
    	
		oRep:ThinLine()
	Next

	oRep:SkipLine()
    oSection:Finish()

    oRep:EndPage()
    
Return .T.

