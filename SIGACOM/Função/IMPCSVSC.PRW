
/*
Programa..: IMPCSVSC.PRW
Objetivo..: GERAR SOLICITACAO DE COMPRAS A PARTIR DA INTEGRACAO DE ARQUIVO .CSV
Autor.....: LUCIANO CAMPOS DE SANTANA
Data/Hora.: 10/08/2021 AS 11:00
Obs.......:
*/
// #INCLUDE "TOTVS.Ch"
#INCLUDE "Protheus.Ch"
// #INCLUDE 'TOPCONN.CH'

// #DEFINE CRLF  CHAR(13) + CHAR(10)

USER FUNCTION IMPCSV()
	LOCAL oDLG,nBTOP,bOK,bCANCEL,aBUTTONS,cOALIAS,cPICTA,cPICTB,cPICTC,cPICTD,cPICTE,cPICTF,cPICTG,cPICTH,cMASK
	Local nModOld := nModulo
	Local cModOld := cModulo
	PRIVATE cTipoImp,cClaImp,cDESCIMP,aTpNmImp,cFORNC1,cLOJAC1,cDESFOR,nQTDKIT,cUNIDREQ,cCODCOMPR,cMVTIPO,cMOEDAYF,nMOEDAC1,cCC,cMSG,cMARCA,lINVERTE,lMSErroAuto,aArqArq,;
		aScInc,oLISTBOX,oOK,oNO,lFIRST,cFILSC1,cSC1SOLIC,cFabr,cFabrLoj,cFILVX5,cxSCDe,cxSCAte

	Private _cEmp  	:= FWCodEmp()
	Private lAtuEst := SuperGetMV('CAOA_C1ES',.F.,.F.) //- PARÂMETRO RESPOSÁVEL POR INDICAR FORÇAR NÃO ATUALIZAR O ESTOQUE DEFAULT .F.
	Private cMaskL  := "*.txt | *.txt"

	//- força o ajuste de execução do módulo
	nModulo := 2
	cModulo := 'COM'

	cOALIAS     := ALIAS()
	nBTOP       := nMOEDAC1 := 0
	bOK         := {|| nBTOP  := 1,IF(FVAL("bOKARQ"),oDLG:END(),nBTOP := 0)}
	bCANCEL     := {|| nBTOP := 0,oDLG:END()}
	aBUTTONS    := {{"LBTIK",{|| FVAL("MARCARQ")},"Marca/Desmarca Todos"}}
	cFILSC1     := XFILIAL("SC1")
	cFILVX5     := xFilial("VX5")
	cSC1SOLIC   := CriaVar("C1_SOLICIT")
	cMask       := "Arquivos CSV" + "(*.CSV)|*.csv|"
	cMARCA      := GETMARK()
	lINVERTE    := .F.
	lMSErroAuto := .F.
	lFirst      := .T.
	aArqArq     := {}
	aScInc      := {}
	oOk         := LoadBitmap(GetResources(), "LBOK")
	oNo         := LoadBitmap(GetResources(), "LBNO")
	cMVTipo   := GETMV("MV_XTIPIMP",,"")
	cPICTA    := AVSX3("ZZ8_CODIGO",6)
	cPICTB    := AVSX3("C1_UNIDREQ",6)
	cPICTC    := AVSX3("C1_CODCOMP",6)
	cPICTD    := AVSX3("C1_QUANT"  ,6)
	cPICTE    := AVSX3("A2_COD"    ,6)
	cPICTF    := AVSX3("A2_LOJA"   ,6)
	CPICTG    := AVSX3("YF_MOEDA"  ,6)
	cPICTH    := AVSX3("C1_MOEDA"  ,6)
	cPICTI    := AVSX3("C1_CC"     ,6)
	cTipoImp  := SPACE(LEN(ZZ8->ZZ8_CODIGO))
	cDESCIMP  := SPACE(LEN(ZZ8->ZZ8_DESC))
	cFORNC1   := SPACE(LEN(ZZ8->ZZ8_FORNEC))
	cLOJAC1   := SPACE(LEN(ZZ8->ZZ8_LOJA))
	cDESFOR   := SPACE(LEN(SA2->A2_NOME))
	nQTDKIT   := 1
	cUNIDREQ  := SPACE(LEN(SC1->C1_UNIDREQ))
	cCODCOMPR := FVAL("BUSCA_COMPRADOR")
	cClaImp   := SPACE(LEN(ZZ8->ZZ8_TIPO))
	aTpNmImp  := ""
	cMOEDAYF  := SPACE(LEN(SYF->YF_MOEDA))
	cCC       := SPACE(LEN(SC1->C1_CC))

	If _cEmp == "2010" //Executa o p.e. somente para Anapolis.
		cMsg	:=	"Os layouts possíveis são:" + Char(13) + Char(10) + Char(13) + Char(10)+;
			"Kit: - 04 campos:" + Char(13) + Char(10)+;
			"Cod Prod, Quant, Vl Und, Proforma" + Char(13) + Char(10) + Char(13) + Char(10)+;
			"Carro - 09 campos:" + Char(13) + Char(10)+;
			"Cod Base, Ano, Modelo, Opcional, Cor Int, Cor Ext, Quant, Vl Und, Proforma" + Char(13) + Char(10)
	Else
		cMsg	:=	"Os layouts possíveis são:" + CRLF + CRLF + ;
			"Kit: - 04 campos:" + CRLF + ;
			"Cod Prod, Quant, Vl Und, Proforma" + CRLF + CRLF + ;
			"Carro - 09 campos:" + CRLF + ;
			"Cod Base, Ano, Modelo, Opcional, Cor Int, Cor Ext, Quant, Vl Und, Proforma" + CRLF + ;
			"Peças Barueri - 07 campos:" + CRLF + ;
			"[01] Código, [02] Descrição, [03] Quantidade, [04] Pç Unitário,[05] Valor Total, [06] Data Receb(dd/mm/aaaa), [07] Núm Pedido Fornecedor"
	EndIf

	cFabr := cFabrLoj := cxSCDe := cxSCAte := ""
	Aadd(aArqArq,{.F.,""})
	DEFINE MSDIALOG oDLG TITLE "Importacao de Arquivos CSV" FROM 0,0 TO 430, 680 OF oMainWnd PIXEL
	@ 040,007 SAY "Tipo Importação" PIXEL OF oDLG
	@ 050,007 MSGET cTipoImp PICTURE cPICTA VALID(FVAL("TIPOIMP")) F3 "ZZ8" SIZE 035,08 PIXEL OF oDLG
	@ 050,046 MSGET cDESCIMP PICTURE WHEN .F. SIZE 115,08  PIXEL OF oDLG

	@ 040,185 SAY "Unid. Requis." PIXEL OF oDLG
	@ 050,185 MSGET cUnidReq PICTURE cPICTB VALID(FVAL("UNIDREQ",cUnidReq))  F3 CpoRetF3("C1_UNIDREQ") SIZE 035,08 PIXEL OF oDLG

	@ 040,230 SAY "Comprador"	PIXEL OF oDLG PIXEL
	@ 050,230 MSGET cCodCompr PICTURE cPICTC VALID(FVAL("CODCOMP",cCodCompr)) F3 "SY1" SIZE 035,08 PIXEL OF oDLG

	@ 040,270 SAY "Quant.Kit" PIXEL OF oDlg
	@ 050,270 MSGET nQtdKIT PICTURE cPICTD VALID(nQtdKIT>0) WHEN xWhenKit(cTipoImp,cMVTipo) SIZE 035,08  PIXEL OF oDLG

	@ 070,007 SAY "Fornecedor" PIXEL OF oDlg
	@ 080,007 MSGET cFornC1 PICTURE cPICTE VALID (FVAL("FORNEC1")) F3 "SA2" SIZE 035,08 PIXEL OF oDlg
	*
	@ 070,046 SAY "Lj" PIXEL OF oDlg
	@ 080,046 MSGET cLojaC1 PICTURE cPICTF VALID (FVAL("LOJAC1")) SIZE 015,08  PIXEL OF oDlg
	*
	@ 070,066 SAY "Nome" PIXEL OF oDlg
	@ 080,066 MSGET cDesFor PICTURE WHEN .F. SIZE 115,08  PIXEL OF oDlg
	*
	@ 070,185 SAY "Moeda" PIXEL OF oDlg
	@ 080,185 MSGET cMoedaYf PICTURE cPICTG VALID (FVAL("MOEDAC1")) F3 "SYF"  SIZE 035,08 PIXEL OF oDlg
	*
	@ 070,230 SAY "Moeda" PIXEL OF oDlg
	@ 080,230 MSGET nMoedaC1 PICTURE cPICTH WHEN .F. SIZE 25,08  PIXEL OF oDlg
	*
	@ 070,275 SAY "Centro Custo" PIXEL OF oDlg
	@ 080,275 MSGET cCC PICTURE cPICTI WHEN .F.  SIZE 40,08  PIXEL OF oDlg
	*
	@ 090,007 SAY "Selecione o arquivo a importar:" PIXEL OF oDLG
	Define SButton FROM 100, 007 Type 14 Action (ApMsgInfo(cMsg, "IMPCSV"),  cFile := cGetFile( cMask, 'Selecione o arquivo a ser importado',1,,.T. ), If( cFile == "", .T., ATULIST()), oListBox:Refresh()  ) Enable Of oDlg Pixel
	*
	@ 110,150 SAY "Lista de arquivos a importar:" PIXEL OF oDLG
	@ 120,007 LISTBOX oListBox Fields,HEADER "","Nome do Arquivo CSV" SIZE 330,90 OF oDlg PIXEL ColSizes 10,320
	oListBox:SetArray(aArqArq)
	oListBox:bLine := {|| { IIf(aArqArq[oListBox:nAt, 1], oOk, oNo),;
		aArqArq[oListBox:nAt][2]}}
	oListBox:BlDblClick := {|| aArqArq[oListBox:nAt, 1] := !aArqArq[oListBox:nAt, 1], oListBox:Refresh()}
	ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS) CENTERED
	If nBTOP == 1
		//GetTrace(1) //hAbilita Tracer
		If _cEmp == "2010" //Executa o p.e. somente para Anapolis.
			Processa( {|| ImpCsv01() }, "Aguarde...","Importação CSV para Sol. Compra",.F.)
		Else
			Processa( {|| ImpCsv02() }, "Aguarde...","Importação CSV para Sol. Compra",.F.)
		EndIf
		//GetTrace(3) //Desabilita Tracer
	Endif

	IF ! EMPTY(cOALIAS)
		DBSELECTAREA(cOALIAS)
	ENDIF
	//- reataura o módulo em uso
	nModulo := nModOld
	cModulo := cModOld

RETURN(NIL)
	*--------------------------------------------------------------------
STATIC FUNCTION FVAL(cP_ACAO,xVar,yVar)
	LOCAL cOALIAS,lRET,aORD,nX,cKSA2
	*
	cOALIAS := ALIAS()
	lRET    := .T.
	cP_ACAO := IF(cP_ACAO==NIL,"",UPPER(cP_ACAO))
	Xvar    := IF(XVAR   ==NIL,.T.,xVAR)
	IF cP_ACAO == "TIPOIMP"
		IF EMPTY(cTipoImp)
			MSGINFO("Nenhum Tipo de Importação selecionado!","Atenção!")
			lRET := .F.
		ELSE
			aORD := {{ZZ8->(INDEXORD()),ZZ8->(RECNO())},{SA2->(INDEXORD()),SA2->(RECNO())}}

			ZZ8->(DBSETORDER(1))
			IF ! ZZ8->(MSSEEK(fwXFILIAL("ZZ8") + cTipoImp))
				MSGINFO("Tipo de importacao Invalido !","Atencao")
				lRET := .F.
			ELSE
				IF xVAR
					cDescImp 	:= ZZ8->ZZ8_DESC
					cFornC1 	:= ZZ8->ZZ8_FORNEC
					cLojaC1 	:= ZZ8->ZZ8_LOJA
					cClaImp   := Alltrim(ZZ8->ZZ8_TIPO)
					SA2->(DBSETORDER(1))
					SA2->(MSSEEK(XFILIAL("SA2")+cFORNC1+cLOJAC1))
					cDesFor 	:= SA2->A2_NOME
					nQtdKIT  	:= 1
				ENDIF
			ENDIF
			ZZ8->(DBSETORDER(aORD[1,1])) ; ZZ8->(DBGOTO(aORD[1,1]))
			SA2->(DBSETORDER(aORD[2,1])) ; SA2->(DBGOTO(aORD[2,1]))
		Endif
	ELSEIF cP_ACAO == "UNIDREQ"
		If Empty(cUnidReq)
			MSGINFO("Unidade Requisitante não foi informada!","Atenção!")
			lRET := .F.
		ELSE
			lRET := A110UnidReq(cUnidReq)
		Endif
	ELSEIF cP_ACAO == "BUSCA_COMPRADOR"
		aORD      := {{SY1->(INDEXORD()),SY1->(RECNO())}}
		cCODCOMPR := SPACE(LEN(SY1->Y1_COD))
		SY1->(DBSETORDER(1))
		IF SY1->(MSSEEK(XFILIAL("SY1")+__cUserID))
			cCODCOMPR := SY1->Y1_COD
		ENDIF
		SY1->(DBSETORDER(aORD[1,1])) ; SY1->(DBGOTO(aORD[1,1]))
		lRET := cCODCOMPR
	ELSEIF cP_ACAO == "CODCOMP"
		IF EMPTY(cCODCOMPR)
			MSGINFO("Codigo do comprador nao informado !","Atencao")
			lRET := .F.
		ELSE
			lRET := A110CodCompr(cCodCompr)
		ENDIF
	ELSEIF cP_ACAO == "FORNEC1"
		aORD := {{SA2->(INDEXORD()),SA2->(RECNO())}}
		If Empty(cFornC1)
			MSGINFO("Nenhum Fornecedor selecionado!","Atenção!")
			lRET := .F.
		Else
			cKSA2 := cFORNC1+IF(!EMPTY(cLOJAC1),cLOJAC1,"")
			SA2->(DBSETORDER(1))
			IF ! (SA2->(MSSEEK(XFILIAL("SA2")+cKSA2)))
				MSGINFO("Fornecedor não cadastrado!","Atenção!")
				lRET := .F.
			ELSE
				cDesFor := SA2->A2_NOME
			ENDIF
		Endif
		SA1->(DBSETORDER(aORD[1,1])) ; SA1->(DBGOTO(aORD[1,1]))
	ELSEIF cP_ACAO == "LOJAC1"
		aORD := {{SA2->(INDEXORD()),SA2->(RECNO())}}
		If Empty(cLOJAC1)
			MSGINFO("Nenhuma loja de Fornecedor selecionada!","Atenção!")
			lRET := .F.
		Else
			cKSA2 := cFORNC1+cLOJAC1
			SA2->(DBSETORDER(1))
			IF ! (SA2->(MSSEEK(XFILIAL("SA2")+cKSA2)))
				MSGINFO("Fornecedor não cadastrado!","Atenção!")
				lRET := .F.
			ELSE
				cDesFor := SA2->A2_NOME
			ENDIF
		Endif
		SA1->(DBSETORDER(aORD[1,1])) ; SA1->(DBGOTO(aORD[1,1]))
	ELSEIF cP_ACAO == "MOEDAC1"
		aORD := {{SYF->(INDEXORD()),SYF->(RECNO())}}
		If Empty(cMoedaYF)
			MSGINFO("Moeda não informada!","Atenção!")
			lRET := .F.
		Else
			SYF->(DBSETORDER(1))
			IF ! (SYF->(MSSEEK(XFILIAL("SYF")+cMOEDAYF)))
				MSGINFO("Moeda não encontrada!","Atenção!")
				lRET := .F.
			ELSE
				nMoedaC1 := SYF->YF_MOEFAT
			ENDIF
			If nMoedaC1==0
				MSGINFO("Moeda não vinculada no SigaEIC!","Atenção!")
				lRET := .F.
			EndIf
		Endif
		SYF->(DBSETORDER(aORD[1,1])) ; SYF->(DBGOTO(aORD[1,1]))
	ELSEIF cP_ACAO  == UPPER("bOKARQ")
		IF ! FVAL("UNIDREQ",cUnidReq) .OR.;
				! FVAL("CODCOMP",cCodCompr) .OR.;
				! FVAL("TIPOIMP",.F.) .OR.;
				! FVAL("MOEDAC1") .OR.;
				! FVAL("FORNEC1")
			*
			lRET := .F.
		ELSE
			lRET := .F.
			For nX:=1 to Len(aArqArq)
				If aArqArq[nX,1]
					lRET := .T.
					EXIT
				Endif
			Next
			IF ! lRET
				MSGINFO("Nenhum arquivo foi selecionado!","Atenção!")
			ENDIF
		EndIf
	ELSEIF AllTrim(cP_ACAO) == "MARCARQ"
		For nX := 1 to Len(aArqArq)
			aArqArq[nX,1] := !aArqArq[nX, 1]
		Next
	ENDIF
	IF ! EMPTY(cOALIAS)
		DBSELECTAREA(cOALIAS)
	ENDIF
RETURN(lRET)
	*--------------------------------------------------------------------
Static Function xWhenKit(cTipoImp,cMVTipo)
	LOCAL cOALIAS,lRET
	*
	cOALIAS := ALIAS()
	lRET    := .F.
	If cClaImp $ cMVTipo
		lRet := .T.
	EndIf
	IF ! EMPTY(cOALIAS)
		DBSELECTAREA(cOALIAS)
	ENDIF
RETURN(lRET)
	*--------------------------------------------------------------------
Static Function AtuList()
	If lFirst
		aArqArq := {}
		lFirst  := .F.
	endif
	Aadd(aArqArq,{.T.,cFile})
	oListBox:SetArray(aArqArq)
	oListBox:bLine := {|| { IIf(aArqArq[oListBox:nAt, 1], oOk, oNo),;
		aArqArq[oListBox:nAt][2]}}
	oListBox:BlDblClick := {|| aArqArq[oListBox:nAt, 1] := !aArqArq[oListBox:nAt, 1], oListBox:Refresh()}
Return nil
	*--------------------------------------------------------------------
Static Function ImpCsv01(oSay)
	LOCAL nX,nA,nB,aCPLN,cSEP,oFile,cARQ,aLINHAS,nCP,aERROS,nCONT,aCAB,aITEM,cNumSc,lVALID,lKIT,cPRODUTO,cAnoFab,cAnoMod,cOpcion,cCorInt,cCorExt,nQuant,nVlUnit
	LOCAL cProforma,cLErro,cQRYA,nTOTAL,nI,nQtdMsg,nTotMsg,cNumIt,aCpImp,cNewSc,cSimb,cTextoE
	Local aRec := {}
	Local nRec := 0
	Local lLock := .F.

	If Vazio(cTipoImp) = .T. .OR. Vazio(cClaImp) = .T.
		ApMsgInfo("Tipo de importacao não informado.", "IMPCSV")
		Return
	endif

	cSep   := ";"
	aERROS := {}
	aRec := {}
	FOR nA := 1 TO LEN(aArqArq)
		aCpLn  := {}
		cARQ   := ALLTRIM(aARQARQ[nA,2])
		If aArqArq[nA,1] = .T. //PROCESSA SOMENTE ARQUIVO MARCADO
			oFile  := FWFileReader():New(cArq)
			If oFile:Open() = .T.
				nCont  := nTOTAL := nQtdMsg := nTotMsg := 0
				cNumIt := cNewSc := ""
				aCab   := {}
				aItem  := {}
				aErros := {}
				cNumSc := GetSX8Num("SC1")
				Aadd( aCab,{"C1_FILIAL"  , cFILSC1              , Nil}) // Filial
				Aadd( aCab,{"C1_NUM"     , cNumSc               , Nil}) // Num. da Solic.Compra
				Aadd( aCab,{"C1_EMISSAO" , dDATABASE            , Nil}) // Data Emissao
				Aadd( aCab,{"C1_TIPO"    , 0                    , Nil}) // Tipo
				Aadd( aCab,{"C1_SOLICIT" , cSC1SOLIC            , Nil}) // Solicitante
				Aadd( aCab,{"C1_UNIDREQ" , cUnidReq             , Nil}) // Unidade Requisitante
				Aadd( aCab,{"C1_CODCOMP" , cCodCompr            , Nil}) // Comprador
				Aadd( aCab,{"C1_XTPIMP"  , cTipoImp             , Nil})  // Class.Import
				Aadd( aCab,{"C1_XCLAIMP" , cClaImp              , Nil})  // Class.Import

				aLinhas := oFile:GetAllLines()
				procregua(LEN(aLINHAS))
				FOR nB := 1 TO LEN(aLINHAS)
					incproc("Processando arquivo " +AllTrim(Str(nA)) +" de " +ALLTRIM(STR(LEN(aARQARQ)))+", item " +AllTrim(Str(nB)) +" de " +ALLTRIM(STR(LEN(aLINHAS))) +".")
					aCPLN := Separa(aLinhas[nB], cSep)
					nCP   := 9
					If Len(aCpLn) < 9
						nCp := 4
					EndIf

					If Len(aCpLn) < nCp .OR. WmsVlStr(aCpLn[nCp]) = .F.
						Aadd(aErros,  {"Arquivo: " + AllTrim(aArqArq[nA,2]) + " invoice contem caracteres especiais na linha " + cValTochar(nB),""})
						Loop
					EndIf

					lValid := .T.
					If LEN(aCPLN) == 4  // Kits
						lKit      := .T.
						cProduto  := aCPLN[1]
						cAnoFab   := cAnoMod := cOpcion := cCorInt := cCorExt  := ""
						nQuant    := Val( StrTran(aCPLN[2],",",".") )
						nVlUnit   := Val( StrTran(aCPLN[3],",",".") )
						cProforma := aCPLN[4]
					ElseIf LEN(aCPLN) == 9
						lKit      := .F.
						nQtdKIT   := 1
						cProduto  := AllTrim(aCPLN[1])+AllTrim(aCPLN[4])+Alltrim(aCPLN[5])+AllTrim(aCPLN[6])
						cAnoFab   := aCPLN[2]
						cAnoMod   := aCPLN[3]
						cOpcion   := aCPLN[4]
						cCorInt   := aCPLN[5]
						cCorExt   := aCPLN[6]
						nQuant    := Val( StrTran(aCPLN[7],",",".") )
						nVlUnit   := Val( StrTran(aCPLN[8],",",".") )
						cProforma := aCPLN[9]
					Else
						lValid   := .F.
						Aadd(aErros,  {"Layout incorreto, verifique a quantidade de campos (4-Kits, 9-Veiculos)",""})
					EndIf
					cLErro   := STRZERO(nCont,5)+" "
					If lValid
						cProduto := Alltrim(STRTRAN(cProduto, "-", "" ))
						cQRYA := "QRYA"
						BEGINSQL ALIAS cQRYA
				    SELECT B1_COD,
					       B1_LOCREC,
					       ISNULL(A5_FABR, ' ') A5_FABR,
						   ISNULL(A5_FALOJA, ' ') A5_FALOJA,
						   ISNULL(VV2_CORINT, ' ') VV2_CORINT
					  FROM %TABLE:SB1% SB1
					 LEFT JOIN %TABLE:SA5% SA5
					        ON SA5.%NOTDEL%
						   AND SA5.A5_FILIAL = %xFilial:SA5%
						   AND SA5.A5_PRODUTO = SB1.B1_COD
					       AND SA5.A5_FORNECE = %Exp:cFornC1%
						   AND SA5.A5_LOJA = %Exp:cLojaC1%
						   AND SA5.A5_FABR <> ' '
						   AND SA5.A5_MSBLQL <> '1'
					 LEFT JOIN %TABLE:VV2% VV2 
					        ON VV2.%NOTDEL%
						   AND VV2.VV2_FILIAL = %xFilial:VV2%
						   AND VV2.VV2_PRODUT = SB1.B1_COD
					 WHERE SB1.%NOTDEL%
					   AND SB1.B1_FILIAL = %xFilial:SB1%
					   AND SB1.B1_COD = %Exp:cProduto%
					   AND SB1.B1_IMPORT = 'S'
						ENDSQL
						IF (cQRYA)->(EOF())
							lValid := .F.
							Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Produto nao cadastrado ou nao esta como importado !",AllTrim(cProduto)})
						ENDIF
						If !Empty((cQRYA)->A5_FABR)
							cFabr	 := (cQRYA)->A5_FABR
							cFabrLoj   := (cQRYA)->A5_FALOJA
						Else
							lValid := .F.
							Aadd(aErros,  {cLErro + AllTrim(cProduto) + " - Nao existe amarracao de fabricante ou o Produto esta Bloqueado . Fornecedor: " + cFornC1 +" - Loja: " + cLojaC1,AllTrim(cProduto)})
						EndIf
						If nQuant <= 0
							lValid := .F.
							Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Quantidade invalida",AllTrim(cProduto)})
						EndIf
						If nVlUnit <= 0
							lValid := .F.
							Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Preco unitario invalido",AllTrim(cProduto)})
						EndIf
						If !lKit
							If lValid
								lVALID := .F.
								Do While ! (cQRYA)->(EOF())
									If AllTrim(cCorInt) == AllTrim((cQRYA)->VV2_CORINT)
										lValid := .T.
										Exit
									EndIf
									(cQRYA)->(dbSkip())
								EndDo
								IF ! lVALID
									Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Modelo de Veiculo nao cadastrado ou "+;
										"cor interna ("+cCORINT+") invalida para este veiculo !",AllTrim(cProduto)})
								ENDIF
							EndIf
							If !Empty(cCorInt)
								VX5->(dbSetOrder(1))
								If ! (VX5->(dbSeek(cFILVX5+"066"+cCorInt)))
									lValid := .F.
									Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Cor interna nao cadastrada: "+AllTrim(cCorInt),AllTrim(cProduto)})
								EndIf
							EndIf
							If !Empty(cCorExt)
								VX5->(dbSetOrder(1))
								If ! (VX5->(dbSeek(cFILVX5+"067"+cCorExt)))
									lValid := .F.
									Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Cor externa nao cadastrada: "+AllTrim(cCorExt),AllTrim(cProduto)})
								EndIf
							EndIf
							If !Empty(cOpcion)
								VX5->(dbSetOrder(1))
								If ! (VX5->(dbSeek(cFILVX5+"068"+cOpcion)))
									lValid := .F.
									Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Opcional nao cadastrado: "+AllTrim(cOpcion),AllTrim(cProduto)})
								EndIf
							EndIf
						EndIf
						//Efetua o MsExecAuto das SC´s.
						If lValid
							IF lKit
								nTotal := 1
								nQTde  := nQuant*nQtdKIT
							Else
								nTotal := nQuant
								nQTde  := 1
							EndIF

							For nI := 1 To nTotal
								nQtdMsg ++
								nTotMsg += nVlUnit
								nCont++
								cNumIt := Strzero(nCont,4)
								aCpImp   := {}
								Aadd( aCpImp, {"C1_FILIAL"  , cFILSC1              		    , Nil}) // Filial
								Aadd( aCpImp, {"C1_ITEM"    , cNumIt                            , NIL})  // Num. do Item
								Aadd( aCpImp, {"C1_FORNECE" , cFornC1                           , NIL})  // Fornecedor
								Aadd( aCpImp, {"C1_LOJA"    , cLojaC1                           , NIL})  // Loja
								Aadd( aCpImp, {"C1_PRODUTO" , (cQRYA)->B1_COD                   , NIL})  // Produto
								Aadd( aCpImp, {"C1_LOCAL"   , (cQRYA)->B1_LOCREC                , NIL})  // Armazem
								Aadd( aCpImp, {"C1_QUANT"   , nQTde                             , NIL})  // Quantidade
								Aadd( aCpImp, {"C1_FABR"    , cFabr                             , NIL})  // Fabricante
								Aadd( aCpImp, {"C1_FABRLOJ" , cFabrLoj                          , NIL})  // Loja
								Aadd( aCpImp, {"C1_XTPIMP"  , Alltrim(cTipoImp)                 , ".T."})  // Tp Import
								Aadd( aCpImp, {"C1_XCLAIMP" , Alltrim(cClaImp)   	              , ".T."})  // Class.Import
								Aadd( aCpImp, {"C1_XVLUNIT" , nVlUnit                           , NIL})  // VlUnd
								Aadd( aCpImp, {"C1_OBS"     , "Sol. importada de arquivo csv."  , NIL})  // Observacao
								Aadd( aCpImp, {"C1_ORIGEM"  , FunName()                         , NIL})  // Rotina Ger.
								Aadd( aCpImp, {"C1_MOEDA"   , nMoedaC1                          , ".T."})  // Moeda
								Aadd( aCpImp, {"C1_CC"      , cCC		                        , NIL})  // Centro de Custo
								Aadd( aCpImp, {"C1_APROV"   , "B"		                        , NIL})  // Centro de Custo
								If !lAtuEst
									Aadd( aCpImp, {"C1_ESTOQUE" , 'N'                           , NIL})  // Indica se havera atualização estoque
								EndIf
								If !EMPTY(cAnoFab)
									Aadd( aCpImp, {"C1_ANOFAB" , cAnoFab                        , NIL}) // Ano Fabricacao
								EndIf
								If !EMPTY(cAnoMod)
									Aadd( aCpImp, {"C1_ANOMOD" , cAnoMod                        , NIL}) // Ano Modelo
								EndIf
								If !EMPTY(cOpcion)
									Aadd( aCpImp, {"C1_OPCION" , cOpcion                        , NIL}) // Opcionais
								EndIf
								If !EMPTY(cCorInt)
									Aadd( aCpImp, {"C1_CORINT" , cCorInt                        , NIL}) // Cor Interna
								EndIf
								If !EMPTY(cCorExt)
									Aadd( aCpImp, {"C1_COREXT" , cCorExt                        , NIL}) // Cor Externa
								EndIf
								If !EMPTY(cProforma)
									Aadd( aCpImp, {"C1_NR_PRO" , cProforma                      , NIL}) //Proforma
								EndIf
								Aadd( aItem, aCpImp)

								// adicionar aos recnos
								// If Vazio(Posicione("SB2", 1, FwXfilial("SB2") + (cQRYA)->B1_COD + (cQRYA)->B1_LOCREC, "SB2->B2_COD") ) = .F.
								// 	nRec := Posicione("SB2", 1, FwXfilial("SB2") + (cQRYA)->B1_COD + (cQRYA)->B1_LOCREC, "SB2->(Recno())")
								// 	If nRec > 0
								// 		Aadd(aRec, nRec)
								// 	EndIf
								// EndIf

							Next nI
						EndIf
						(cQRYA)->(DBCLOSEAREA())
					EndIf
				NEXT
			ELSE
				ApMsgStop("Não foi possível efetuar a leitura do arquivo." + cArq )
				LOOP
			ENDIF
		ELSE
			ApMsgInfo("O arquivo " +  cARQ + " está desmarcado, não será avaliado." , "IMPCSV")
			LOOP
		EndIf
		cNewSc := ""
		If Len(aErros) == 0
			If Len(aItem)>0
				//Barueri
				//Processa({|| lLock := zChkLock(aRec) }, "Aguarde...", "Salvando Solicitação " + cNUMSC + ", " + Alltrim(Str(nB-1)) + " linha(s)" , .F.)
				// if lLock = .T.
				// 	ApMsgInfo("Cancelado pelo usuário", "")
				// 	Return
				// EndIf
				// Begin Transaction
				While .T.

					MsExecAuto({|v,x,y,z| MATA110(v,x,y,z)},aCab,aItem,3,.F.)
					If lMsErroAuto
						MostraErro()
						RollBackSx8()
						Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Inconsistencias na inclusao da solicitacao ",""})
						// DisarmTransaction()
						// BREAK
					Else
						//Utilizado no Relatorio variaveis: cxSCDe e cxSCAte
						If Empty(cxSCDe)
							cxSCDe := cNumSc
						EndIf
						cxSCAte := cNumSc
						fGravaSC1(cNumSc,nMoedaC1,cTipoImp,cClaImp)  //Grava informações na SC1, após a inclusão do MsExecAuto.
						ConfirmSX8()
						Aadd(aScInc,cNumSc)
					EndIf

					// End Transaction
					Exit
				EndDo
			Endif
		Endif
		If Len(aErros) == 0
			If MsgYesNo( "Deseja Imprimir o Relatorio?", "Deseja Imprimir o Relatorio?" )
				U_RELIMPSC()
			Else
				If !Empty(cNumSC)
					cSimb := xSbMoed(nMoedaC1)
					AVISO("SC Gerada Com Sucesso", "SC              : " + cNumSC + CRLF + ;
						"Quant Itens     : " + Alltrim(Str(nQtdMsg)) + CRLF + ;
						"Total           : " + cSimb + " " + TRANSFORM(nTotMsg,PesqPict( "SC1", "C1_XVLUNIT" )) ;
						, {"Fechar"}, 3)
				EndIf
			EndIf
		ElseIf Len(aErros) > 0
			
			aSort(aErros, ,,{|x,y| x[2]<y[2]})
			
			cTextoE := ""
			cTextoE += "Linha Produto"+chr(13)+chr(10)
			cTextoE += "----- -------"+chr(13)+chr(10)
			For nX:=1 to Len(aErros)
				cTextoE += aErros[nX,1]+chr(13)+chr(10)
			Next
			aErros := {}
			Define Font oFont Name "Mono AS" Size 5, 12
			DEFINE MSDIALOG oDlgMemo TITLE "Solicitações não importadas!" FROM 3,0 TO 340,417 OF oMainWnd PIXEL
			@ 5,5 Get oMemo Var cTextoE Memo Size 200, 145 Of oDlgMEMO Pixel
			oMemo:oFont := oFont
			Define SButton From 153, 175 Type  1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action (cFileL := cGetFile(cMaskL, "",,,.F.,,.F.), If(cFileL == "", .T., MemoWrite(cFileL, cTextoE))) Enable Of oDlgMemo Pixel
			ACTIVATE MSDIALOG oDlgMemo CENTERED
		EndIf
	NEXT
RETURN(NIL)
	*--------------------------------------------------------------------
Static Function ImpCsv02(oSay)
	LOCAL nX,nA,nB,aCPLN,cSEP,oFile,cARQ,aLINHAS,aERROS,nCONT,aCAB,aITEM,cNumSc,lVALID,lKIT,cPRODUTO,cAnoFab,cAnoMod,cOpcion,cCorInt,cCorExt,nQuant,nVlUnit
	LOCAL cProforma,cLErro,cQRYA,nTOTAL,nI,nQtdMsg,nTotMsg,cNumIt,aCpImp,cNewSc,cSimb,cTextoE, dDtEntr
	Local aRec := {}
	Local nRec := 0
	Local lLock := .F.

	If Vazio(cTipoImp) = .T. .OR. Vazio(cClaImp) = .T.
		ApMsgInfo("Tipo de importacao não informado.", "IMPCSV")
		Return
	endif

	cSep   := ";"
	aERROS := {}
	aRec := {}
	FOR nA := 1 TO LEN(aArqArq)
		aCpLn  := {}
		cARQ   := ALLTRIM(aARQARQ[nA,2])
		If aArqArq[nA,1] = .T. //PROCESSA SOMENTE ARQUIVO MARCADO
			oFile  := FWFileReader():New(cArq)
			If oFile:Open() = .T.
				nCont  := nTOTAL := nQtdMsg := nTotMsg := 0
				cNumIt := cNewSc := ""
				aCab   := {}
				aItem  := {}
				aErros := {}
				cNumSc := GetSX8Num("SC1")
				Aadd( aCab,{"C1_FILIAL"  , cFILSC1              , Nil}) // Filial
				Aadd( aCab,{"C1_NUM"     , cNumSc               , Nil}) // Num. da Solic.Compra
				Aadd( aCab,{"C1_EMISSAO" , dDATABASE            , Nil}) // Data Emissao
				Aadd( aCab,{"C1_TIPO"    , 0                    , Nil}) // Tipo
				Aadd( aCab,{"C1_SOLICIT" , cSC1SOLIC            , Nil}) // Solicitante
				Aadd( aCab,{"C1_UNIDREQ" , cUnidReq             , Nil}) // Unidade Requisitante
				Aadd( aCab,{"C1_CODCOMP" , cCodCompr            , Nil}) // Comprador
				Aadd( aCab,{"C1_XTPIMP"  , cTipoImp             , Nil})  // Class.Import
				Aadd( aCab,{"C1_XCLAIMP" , cClaImp              , Nil})  // Class.Import

				aLinhas := oFile:GetAllLines()
				procregua(LEN(aLINHAS))
				FOR nB := 1 TO LEN(aLINHAS)

					incproc("Processando arquivo " +AllTrim(Str(nA)) +" de " +ALLTRIM(STR(LEN(aARQARQ)))+", item " +AllTrim(Str(nB)) +" de " +ALLTRIM(STR(LEN(aLINHAS))) +".")
					aCPLN := Separa(aLinhas[nB], cSep)

					lValid := .T.
					If LEN(aCPLN) == 4 .AND. FWCodEmp() == '2001' // Kits
						lKit      := .T.
						cProduto  := aCPLN[1]
						cAnoFab   := cAnoMod := cOpcion := cCorInt := cCorExt  := ""
						nQuant    := Val( StrTran(aCPLN[2],",",".") )
						nVlUnit   := Val( StrTran(aCPLN[3],",",".") )
						cProforma := aCPLN[4]
					ElseIf LEN(aCPLN) == 9 .AND. FWCodEmp() == '2001'
						lKit      := .F.
						nQtdKIT   := 1
						cProduto  := AllTrim(aCPLN[1])+AllTrim(aCPLN[4])+Alltrim(aCPLN[5])+AllTrim(aCPLN[6])
						cAnoFab   := aCPLN[2]
						cAnoMod   := aCPLN[3]
						cOpcion   := aCPLN[4]
						cCorInt   := aCPLN[5]
						cCorExt   := aCPLN[6]
						nQuant    := Val( StrTran(aCPLN[7],",",".") )
						nVlUnit   := Val( StrTran(aCPLN[8],",",".") )
						cProforma := aCPLN[9]
					ElseIf LEN(aCPLN) == 7 .AND. FWCodEmp() == '2020'
						lKit      := .F.
						cProduto  := aCPLN[1]
						nQuant    := Val( StrTran(aCPLN[3],",",".") )
						nVlUnit   := Val( StrTran(aCPLN[4],",",".") )
						dDtEntr   := Ctod(Alltrim(aCPLN[6]))
						cProforma := aCPLN[7]
					Else
						lValid   := .F.
						Aadd(aErros,  {"Layout incorreto na linha " + PadL(nB, 5, "0") + " Verifique a quantidade de campos (4-Kits, 9-Veiculos, 7-Peças)", ""})
						Loop
					EndIf

					If WmsVlStr(cProforma) = .F.
						Aadd(aErros,  {"Arq: " + AllTrim(aArqArq[nA,2]) + ", proforma: " + Alltrim(cProforma) + " contêm caracteres especiais, linha " + cValTochar(nB),""})
						Loop
					EndIf

					cLErro   := STRZERO(nCont,5)+" "
					If lValid
						If FWCodEmp() == '2001'
							cProduto := Alltrim(STRTRAN(cProduto, "-", "" ))
						Endif
						cQRYA := "QRYA"
						BEGINSQL ALIAS cQRYA
							SELECT
								B1_COD,
								B1_LOCREC,
								ISNULL(A5_FABR, '  ') A5_FABR,
								ISNULL(A5_FALOJA,' ') A5_FALOJA,
								ISNULL(VV2_CORINT,' ') VV2_CORINT
							FROM
								%TABLE:SB1% SB1
							LEFT JOIN %TABLE:SA5% SA5
							ON SA5.%NOTDEL%
								AND SA5.A5_FILIAL = %xFilial:SA5%
								AND SA5.A5_PRODUTO = SB1.B1_COD
								AND SA5.A5_FORNECE = %Exp:cFornC1%
								AND SA5.A5_LOJA = %Exp:cLojaC1%
								AND SA5.A5_FABR <> ' '
								AND SA5.A5_MSBLQL <> '1'
							LEFT JOIN %TABLE:VV2% VV2 "
						 ON VV2.%NOTDEL%
							 AND VV2.VV2_FILIAL = %xFilial:VV2%
							 AND VV2.VV2_PRODUT = SB1.B1_COD
							 WHERE SB1.%NOTDEL%
							 AND SB1.B1_FILIAL = %xFilial:SB1%
							 AND SB1.B1_COD = %Exp:cProduto%
							 AND SB1.B1_IMPORT = 'S'"
						ENDSQL
						IF (cQRYA)->(EOF())
							lValid := .F.
							Aadd(aErros,  {cLErro+AllTrim(cProduto) + " - Produto não cadastrado ou nao esta como importado !",AllTrim(cProduto)})
						ENDIF
						If ! Empty((cQRYA)->A5_FABR)
							cFabr	 := (cQRYA)->A5_FABR
							cFabrLoj := (cQRYA)->A5_FALOJA
						Else
							lValid := .F.
							Aadd(aErros,  {cLErro + AllTrim(cProduto) + " - Não existe amarracao de fabricante ou Produto esta Bloqueado. Fornecedor: " + cFornC1 + " - Loja: " + cLojaC1, AllTrim(cProduto) })
						EndIf
						If nQuant <= 0
							lValid := .F.
							Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Quantidade inválida",AllTrim(cProduto)})
						EndIf
						If nVlUnit <= 0
							lValid := .F.
							Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Preço unitário inválido",AllTrim(cProduto)})
						EndIf
						If !lKit
							If lValid
								lVALID := .F.
								Do While ! (cQRYA)->(EOF())
									If AllTrim(cCorInt) == AllTrim((cQRYA)->VV2_CORINT)
										lValid := .T.
										Exit
									EndIf
									(cQRYA)->(dbSkip())
								EndDo
								IF ! lVALID
									Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Modelo de Veiculo nao cadastrado ou cor interna (" + cCORINT + ") invalida para este veiculo !",AllTrim(cProduto)})
								ENDIF
							EndIf
							If !Empty(cCorInt)
								VX5->(dbSetOrder(1))
								If ! (VX5->(dbSeek(cFILVX5+"066"+cCorInt)))
									lValid := .F.
									Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Cor interna nao cadastrada: "+AllTrim(cCorInt),AllTrim(cProduto)})
								EndIf
							EndIf
							If !Empty(cCorExt)
								VX5->(dbSetOrder(1))
								If ! (VX5->(dbSeek(cFILVX5+"067"+cCorExt)))
									lValid := .F.
									Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Cor externa nao cadastrada: "+AllTrim(cCorExt) , AllTrim(cProduto)})
								EndIf
							EndIf
							If !Empty(cOpcion)
								VX5->(dbSetOrder(1))
								If ! (VX5->(dbSeek(cFILVX5+"068"+cOpcion)))
									lValid := .F.
									Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Opcional nao cadastrado: " + AllTrim(cOpcion) , AllTrim(cProduto)})
								EndIf
							EndIf
						EndIf
						//Efetua o MsExecAuto das SC´s.
						If lValid
							IF lKit = .F.
								nTotal := 1
								nQTde  := nQuant*nQtdKIT
							Else
								nTotal := nQuant
								nQTde  := 1
							EndIF

							For nI := 1 To nTotal
								//nQtdMsg ++
								nQtdMsg += nQTde
								//nTotMsg += nVlUnit
								nTotMsg += nQTde * nVlUnit
								nCont++
								cNumIt := Strzero(nCont,4)
								aCpImp   := {}
								Aadd( aCpImp, {"C1_FILIAL"  , cFILSC1              		    , Nil}) // Filial
								Aadd( aCpImp, {"C1_ITEM"    , cNumIt                            , NIL})  // Num. do Item
								Aadd( aCpImp, {"C1_FORNECE" , cFornC1                           , NIL})  // Fornecedor
								Aadd( aCpImp, {"C1_LOJA"    , cLojaC1                           , NIL})  // Loja
								Aadd( aCpImp, {"C1_PRODUTO" , (cQRYA)->B1_COD                   , NIL})  // Produto
								Aadd( aCpImp, {"C1_LOCAL"   , (cQRYA)->B1_LOCREC                , NIL})  // Armazem
								Aadd( aCpImp, {"C1_QUANT"   , nQTde                             , NIL})  // Quantidade
								Aadd( aCpImp, {"C1_FABR"    , cFabr                             , NIL})  // Fabricante
								Aadd( aCpImp, {"C1_FABRLOJ" , cFabrLoj                          , NIL})  // Loja
								Aadd( aCpImp, {"C1_XTPIMP"  , Alltrim(cTipoImp)                 , ".T."})  // Tp Import
								Aadd( aCpImp, {"C1_XCLAIMP" , Alltrim(cClaImp)   	              , ".T."})  // Class.Import
								Aadd( aCpImp, {"C1_XVLUNIT" , nVlUnit                           , NIL})  // VlUnd
								Aadd( aCpImp, {"C1_OBS"     , "Sol. importada de arquivo csv."  , NIL})  // Observacao
								Aadd( aCpImp, {"C1_ORIGEM"  , FunName()                         , NIL})  // Rotina Ger.
								Aadd( aCpImp, {"C1_MOEDA"   , nMoedaC1                          , ".T."})  // Moeda
								Aadd( aCpImp, {"C1_CC"      , cCC		                        , NIL})  // Centro de Custo
								If !lAtuEst 
									Aadd( aCpImp, {"C1_ESTOQUE" , 'N'                           , NIL})  // Indica NÃO havera atualização estoque
								EndIf 
								If !EMPTY(cAnoFab)
									Aadd( aCpImp, {"C1_ANOFAB" , cAnoFab                        , NIL}) // Ano Fabricacao
								EndIf
								If !EMPTY(cAnoMod)
									Aadd( aCpImp, {"C1_ANOMOD" , cAnoMod                        , NIL}) // Ano Modelo
								EndIf
								If !EMPTY(cOpcion)
									Aadd( aCpImp, {"C1_OPCION" , cOpcion                        , NIL}) // Opcionais
								EndIf
								If !EMPTY(cCorInt)
									Aadd( aCpImp, {"C1_CORINT" , cCorInt                        , NIL}) // Cor Interna
								EndIf
								If !EMPTY(cCorExt)
									Aadd( aCpImp, {"C1_COREXT" , cCorExt                        , NIL}) // Cor Externa
								EndIf
								If !EMPTY(cProforma)
									Aadd( aCpImp, {"C1_NR_PRO" , cProforma                      , NIL}) //Proforma
								EndIf

								If !EMPTY(dDtEntr)
									Aadd( aCpImp, {"C1_DATPRF", dDtEntr                         , NIL}) //Proforma
								EndIf

								Aadd( aItem, aCpImp)

								// adicionar aos recnos
							
								If Vazio(Posicione("SB2", 1, FwXfilial("SB2") + (cQRYA)->B1_COD + (cQRYA)->B1_LOCREC, "SB2->B2_COD") ) = .F.
									nRec := Posicione("SB2", 1, FwXfilial("SB2") + (cQRYA)->B1_COD + (cQRYA)->B1_LOCREC, "SB2->(Recno())")
									If nRec > 0
										Aadd(aRec, nRec)
									EndIf
								EndIf

							Next nI
						EndIf
						(cQRYA)->(DBCLOSEAREA())
					EndIf
				NEXT
			ELSE
				ApMsgStop("Não foi possível efetuar a leitura do arquivo." + cArq )
				LOOP
			ENDIF
		ELSE
			ApMsgInfo("O arquivo " +  cARQ + " está desmarcado, não será avaliado." , "IMPCSV")
			LOOP
		EndIf
		cNewSc := ""
		If Len(aErros) == 0
			If Len(aItem)>0
				//Anapolis

				//Processa({|| lLock := zChkLock(aRec) }, "Aguarde...", "Salvando Solicitação " + cNUMSC + ", " + Alltrim(Str(nB-1)) + " linha(s)" , .F.)
				// if lLock = .T.
				// 	ApMsgInfo("Cancelado pelo usuário", "")
				// 	Return
				// EndIf
				// Begin Transaction
				While .T.
					MsExecAuto({|v,x,y,z| MATA110(v,x,y,z)},aCab,aItem,3,.F.)
					If lMsErroAuto
						MostraErro()
						RollBackSx8()
						Aadd(aErros,  { cLErro + AllTrim(cProduto)+" - Inconsistencias na inclusao da solicitacao "," "})
						// DisarmTransaction()
						// BREAK
					Else
						//Utilizado no Relatorio variaveis: cxSCDe e cxSCAte
						If Empty(cxSCDe)
							cxSCDe := cNumSc
						EndIf
						cxSCAte := cNumSc
						fGravaSC1(cNumSc,nMoedaC1,cTipoImp,cClaImp)  //Grava informações na SC1, após a inclusão do MsExecAuto.
						ConfirmSX8()
						Aadd(aScInc,cNumSc)
					EndIf
					Exit
				EndDo
				// End Transaction
			Endif
		Endif
		If Len(aErros) == 0
			If MsgYesNo( "Deseja Imprimir o Relatorio?", "Deseja Imprimir o Relatorio?" )
				U_RELIMPSC()
			Else
				If !Empty(cNumSC)
					cSimb := xSbMoed(nMoedaC1)
					AVISO("SC Gerada Com Sucesso", "SC              : " + cNumSC + CRLF + ;
						"Quant Itens     : " + Alltrim(Str(nQtdMsg)) + CRLF + ;
						"Total           : " + cSimb + " " + TRANSFORM(nTotMsg,"@E 999,999,999.999999") ;
						, {"Fechar"}, 3)
				EndIf
			EndIf
		ElseIf Len(aErros) > 0
			
			aSort(aErros, ,,{|x,y| x[2]<y[2]})

			cTextoE := ""
			cTextoE += "Linha Produto"+chr(13)+chr(10)
			cTextoE += "----- -------"+chr(13)+chr(10)
			
			For nX:=1 to Len(aErros)
				cTextoE += aErros[nX,1]+chr(13)+chr(10)
			Next
			aErros := {}
			Define Font oFont Name "Mono AS" Size 5, 12
			DEFINE MSDIALOG oDlgMemo TITLE "Solicitações não importadas!" FROM 3,0 TO 340,417 OF oMainWnd PIXEL
			@ 5,5 Get oMemo Var cTextoE Memo Size 200, 145 Of oDlgMEMO Pixel
			oMemo:oFont := oFont
			Define SButton From 153, 175 Type  1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action (cFileL := cGetFile(cMaskL, "",,,.F.,,.F.), If(cFileL == "", .T., MemoWrite(cFileL, cTextoE))) Enable Of oDlgMemo Pixel
			ACTIVATE MSDIALOG oDlgMemo CENTERED
		EndIf
	NEXT
RETURN(NIL)
	*--------------------------------------------------------------------
/*/{Protheus.doc} fGravaSC1
Função Auxiliar, utilizda para atualizar algumas informações na SC1 após sua inclusão. Força a atualização de algumas informações.
@author FSW - DWC Consult
@since 01/04/2019
@version 1.0
@param cNum, characters, descricao
@param nMoeda, numeric, descricao
@type function
/*/
Static Function fGravaSC1(cNum,nMoeda,cTipoImp,cClaImp)
	Local cUpd		:= ''

	cUpd := "UPDATE " + RetSQLName("SC1")  + " SC1 "           + CRLF
	cUpd += " SET C1_MOEDA   = "  + Alltrim(Str(nMoeda)) + " " + CRLF
	cUpd += " ,   C1_XTPIMP  = '" + Alltrim(cTipoImp)   + "' " + CRLF
	cUpd += " ,   C1_XCLAIMP = '" + Alltrim(cClaImp)    + "' " + CRLF
	cUpd += " WHERE " 								    + CRLF
	cUpd += " SC1.D_E_L_E_T_ = ' ' AND "                       + CRLF
	cUpd += " SC1.C1_FILIAL = '" + cFILSC1 + "' AND "          + CRLF
	cUpd += " SC1.C1_NUM = '" + cNum + "' "

	If TcSQLExec(cUpd) < 0
		FWAlertError("Erro na rotina fGravaSC1(): " + TcSqlError(), "IMPCSVSC" )
	EndIf
Return
	*--------------------------------------------------------------------
Static Function xSbMoed(nMoed)
	Local cRet := ""
	Local cMVPar := "MV_SIMB" + Alltrim(Str(nMoed))

	cRet := Alltrim(SuperGetMv(cMVPar))
return cRet
	*--------------------------------------------------------------------


/*
   Verificar se Ha locks na tabela de estoque para os produtos
*/
Static Function zChkLock(aRec)
	Local i 		:= 1
	Local j 		:= 1
	Local lLock 	:= .T.
	Local lCont 	:= .T.
	Local nCont 	:=	0

	While lCont = .T.

		nCont++

		For i:=1 to 5

			If lLock = .F.
				Exit
			EndIf

			lLock := u_ZGENLOCK("Lock SB2" ,"SB2" ,aRec)

			if lLock = .T.
				ProcRegua(3)
				For j:=1 to 3 // Foi reduzido de 10  para 3 segundo para a nova tentativa
					IncProc(padL(i, 2, "0") + " Há itens em processamento, nova tentativa em " + padL(3 - j, 2, "0"))
					Sleep (1000)
				Next
			EndIf
		Next

		//Será feita 3 tentativas para verificar se SB2 não esta sendo utilizada
		If nCont < 3
			If lLock = .T.
				lCont := MsgYesNo( "Existem itens com estoque em processamento, deseja tentar novamente? ", "Impcsv" )
			Else
				lCont := .F.
			Endif
		else
			//Após as tentativas o processo será abortado.
			MsgStop("Existem itens com Estoque em processamento." +  CRLF + "Processo será Abortado." + CRLF + " contate o Administrador", "Impcsv")
			lCont := .F.
			lLock := .T.

		EndIf
	EndDo

Return lLock


/*
=====================================================================================
Programa.:              GetTrace
Autor....:              Reinaldo Rabelo
Data.....:              18/01/2024
Descricao / Objetivo:   Gera o arquivo de Log do Trace do DbAccess    
Doc. Origem:            
Solicitante:            SIGAPEC
Uso......:              
Obs......:
=====================================================================================
*/

Static Function GetTrace(nOp,cLog)
   
Local cMessage := ""
Local cArq := "IMPCSVC_" + Dtos(Date()) +"_" + strtran( Time() , ":" )
Local lTrace := .T.
DEFAULT cLog := FunName() 
Default nOp  := 0
  //TcLink()
IF lTrace                                   //Variavel de controle para habilitar o log
	if nOp > 0 .and. nOp < 7 
		Do Case
			Case nOp == 1 
				//Verifica se o SqlReply esta implementado
				if TCSqlReplay(1, @cMessage) == .F.
					conout("Não existe a implementação")
					Return
				endif
			
				// inicia o TCSqlReplay
				cMessage := "\temp\" + cArq + '_' + cLog + "_Trace.log"
				TCSqlReplay(2, @cMessage)
			
				cMessage := ""
				//Verifica se foi iniciado
				if TCSqlReplay(4, @cMessage) == .T.
					conout("TCSqlReplay foi iniciado")
				endif
				// liga o log de rotinas internas para a rotina execurada para  usuario da sessão ativa
				cMessage := "1"
				TCSqlReplay(6, @cMessage)
			
				// altera o valor de call stack para 5
				//cMessage := "5"
				//TCSqlReplay(7, @cMessage)
			
			Case nOp == 3
				// TODO: your code here
				// Finaliza o TCSqlReplay
				TCSqlReplay(3, @cMessage)
					
					
			EndCase 
		else
			Conout("Parametro invalido ")
	EndIf   
EndIf
  //TcUnlink()
   
Return

/*
=====================================================================================
Programa.:              GetLog
Autor....:              Reinaldo Rabelo
Data.....:              18/01/2024
Descricao / Objetivo:   Gera o arquivo de Log do Trace do DbAccess    
Doc. Origem:            
Solicitante:            SIGAPEC
Uso......:              
Obs......:
=====================================================================================
*/


Static Function GetLog(cLog)

Local cArq := "ZPECF013_" + Dtos(Date()) +"_" + strtran( Time() , ":" )
DEFAULT cLog := "" 

IF lTrace            //Variavel de controle para habilitar o log
	MemoWrite("\temp\" + cArq + "_log.Log", cLog)	
EndIf
  
   
Return


