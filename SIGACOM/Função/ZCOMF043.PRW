#INCLUDE "TOTVS.ch"
#INCLUDE "Protheus.ch"
#INCLUDE 'TOPCONN.ch'
   
/*
Programa..: ZCOMF043.PRW
Objetivo..: Gera solicitações de compras com base em uma planilha no formato .CSV
Autor.....: Sandro Ferreira
Data/Hora.: 03/01/2022  
Obs.......:
*/
   
USER FUNCTION ZCOMF043()
	Local   oDLG
	Local   nBTOP 
	Local   bOK 
	Local   bCANCEL
	Local   aBUTTONS
	Local   cPICTB
	Local   cPICTC
	Local   cPICTD
	Local   cMASK
	Local   _oTpReq 
    Local   cOALIAS  := ALIAS()
	PRIVATE cCODCOMPR
	PRIVATE cMSG
	PRIVATE cMARCA
	PRIVATE lINVERTE
	PRIVATE lMSErroAuto
	PRIVATE aArqArq
	PRIVATE oLISTBOX
	PRIVATE oOK
	PRIVATE oNO
	PRIVATE lFIRST
	PRIVATE cFILSC1
	PRIVATE cSC1SOLIC
	PRIVATE cxSCDe
	PRIVATE cxSCAte
	PRIVATE cProc

	nBTOP       := 0
	bOK         := {|| nBTOP  := 1,IF(FVAL("bOKARQ"),oDLG:END(),nBTOP := 0)}
	bCANCEL     := {|| nBTOP := 0,oDLG:END()}
	aBUTTONS    := {{"LBTIK",{|| FVAL("MARCARQ")},"Marca/Desmarca Todos"}}
	cFILSC1     := XFILIAL("SC1")
	cSC1SOLIC   := CriaVar("C1_SOLICIT")
	cEmail      := CriaVar("C1_XREQMAI")
	cObser      := CriaVar("C1_XOBSREQ")
	cTel        := CriaVar("C1_XREQFON")
	cMask       := "Arquivos CSV" + "(*.CSV)|*.csv|"
	cMARCA      := GETMARK()
	lINVERTE    := .F.
	lMSErroAuto := .F.
	lFirst      := .T.
	aArqArq     := {}
	oOk         := LoadBitmap(GetResources(), "LBOK")
	oNo         := LoadBitmap(GetResources(), "LBNO")
	cPICTB      := AVSX3("C1_UNIDREQ",6)
	cPICTC      := AVSX3("C1_CODCOMP",6)
	cPICTD      := AVSX3("C1_QUANT"  ,6)
	cCODCOMPR   := FVAL("BUSCA_COMPRADOR")
	cProc       := 1
	cMsg        := "O layout possível é:" + Char(13) + Char(10) + Char(13) + Char(10)+;
		           "Item da SC, Produto, Quantidade, Necessidade, Centro de Custo e Observação do Item" + Char(13) + Char(10)
	cxSCDe      := cxSCAte := ""
	cSC1SOLIC   := cUserName
	cRequis     := UsrFullName()
	dDtEmiss    := dDataBase
	cFilEnt     := XFILIAL("SC1")                                                                                                                  
	cTpReq      := ""
    cCont       := 1
	cC1_XTPREQ	:= Space(04)
	aTpReq      := {}

	IF U_ZGENUSER( RetCodUsr() ,"ZCOMF043" ,.T.) = .F. 
   	   RETURN Nil
	ENDIF

    //Número da Próxima solicitação 
    cNumScN    := GetSX8Num("SC1")

    //Monta combo com os Tipos de Requisição
	SX3->(DbSetOrder(2))
	SX3->(DbSeek("C1_XTPREQ"))
	aTpReq := StrTokArr(AllTrim(SX3->X3_CBOX),";")
	cC1_XTPREQ 	:= SubsTr(aTpReq [1],1,at("=",aTpReq [1])-1) 
    
	//Array com as planilhas que serão importadas 
	Aadd(aArqArq,{.F.,""})

	DEFINE MSDIALOG oDLG TITLE "Importacao de Arquivos CSV Para Solicitação de Compras - Protheus" FROM 0,0 TO 600, 680 OF oMainWnd PIXEL

	@ 040,007 SAY   "Numero da S.C."                                                                        PIXEL OF oDlg
	@ 050,007 MSGET cNumSCN   PICTURE "@!" When .F.                                             SIZE 035,08 PIXEL OF oDlg

	@ 040,060 SAY   "Solicitante"                                                                           PIXEL OF oDlg
	@ 050,060 MSGET cSC1SOLIC                                                                   SIZE 070,08 PIXEL OF oDlg

    @ 040,150 SAY   "Data de Emissão"	                                                                    PIXEL OF oDlg 
	@ 050,150 MSGET dDtEmiss  PICTURE "@D"                                                      SIZE 045,08 PIXEL HASBUTTON OF oDlg

	@ 040,220 SAY   "Filial de Entrega"                                                                     PIXEL OF oDlg
	@ 050,220 MSGET cFilEnt PICTURE  VALID(FVAL("FILENT",cFilEnt)) F3 "SM0"                     SIZE 045,08 PIXEL HASBUTTON OF oDlg

	@ 040,280 SAY   "Comprador"	                                                                            PIXEL OF oDlg 
	@ 050,280 MSGET cCodCompr PICTURE cPICTC VALID(FVAL("CODCOMP",cCodCompr)) F3 "_Y1USR"       SIZE 050,08 PIXEL HASBUTTON OF oDlg /*Ref. GAP091-"SY1"*/

	@ 070,007 SAY   "Tipo Req"                                                                              PIXEL OF oDlg
	@ 080,007 MSCOMBOBOX _oTpReq  VAR  cC1_XTPREQ   ITEMS aTpReq                                SIZE 60, 08 PIXEL OF oDlg

	@ 070,070 SAY   "Requisitante"                                                                          PIXEL OF oDlg
	@ 080,070 MSGET cRequis                                                                     SIZE 200,08 PIXEL OF oDlg

	@ 070,280 SAY   "Tel. Requis."                                                                          PIXEL OF oDlg
	@ 080,280 MSGET cTel  picture "@R (99) 9999-99999" VALID (FVAL("TELEFONE",cTel))            SIZE 50,08  PIXEL OF oDlg

	@ 103,007 SAY   "Email"                                                                                 PIXEL OF oDlg
	@ 100,060 MSGET cEmail  VALID (FVAL("EMAIL",cEmail))                                        SIZE 270,08 PIXEL OF oDlg

	@ 120,007 SAY   "Obs. Geral SC"                                                                         PIXEL OF oDlg
	@ 117,060 GET   oMemo Var cObser  MEMO  VALID (FVAL("OBSERV",cObser))                       SIZE 270,40 PIXEL OF oDlg

	@ 160,007 SAY   "Selecione o arquivo a importar:"                                                       PIXEL OF oDlg
	Define SButton  FROM 170, 007 Type 14 Action (ApMsgInfo(cMsg, "ZCOMF043"),  cFile := cGetFile( cMask, 'Selecione o arquivo a ser importado',1, "c:\", .T., GETF_LOCALHARD), If( cFile == "", .T., ATULIST()), oListBox:Refresh()  ) Enable Of oDlg Pixel

	@ 180,150 SAY "Lista de arquivos a importar:"                                                                  PIXEL OF oDlg
	@ 190,007 LISTBOX oListBox Fields,HEADER "","Nome do Arquivo CSV"                                  SIZE 330,80 PIXEL OF oDlg ColSizes 10,320
	
	oListBox:SetArray(aArqArq)
	oListBox:bLine := {|| { IIf(aArqArq[oListBox:nAt, 1], oOk, oNo),;
		aArqArq[oListBox:nAt][2]}}
	oListBox:BlDblClick := {|| aArqArq[oListBox:nAt, 1] := !aArqArq[oListBox:nAt, 1], oListBox:Refresh()}

	ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS) CENTERED
	
	If nBTOP == 1
		Processa( {|| PImpCsv() }, "Aguarde...","Importação CSV para Sol. Compra",.F.)
	else
		RollbackSx8("SC1")	
	Endif

	IF !EMPTY(cOALIAS)
		DBSELECTAREA(cOALIAS)
	ENDIF

RETURN(NIL)
	

//Validação dos campos
STATIC FUNCTION FVAL(cP_ACAO,xVar,yVar)
	Local cOALIAS
	Local lRET
	Local aORD
	Local nX 
	cOALIAS := ALIAS()
	lRET    := .T.
	cP_ACAO := IF(cP_ACAO==NIL,"",UPPER(cP_ACAO))
	Xvar    := IF(XVAR   ==NIL,.T.,xVAR)

	IF cP_ACAO == "TELEFONE"
		If Empty(cTel)
			MSGINFO("Telefone do  Requisitante não foi informado!","Atenção!")
			lRET := .F.
		ELSE
			lRET := .T.
		Endif

	ELSEIF cP_ACAO == "EMAIL"
		If Empty(cEmail)
			MSGINFO("Email do Requisitante não foi informado!","Atenção!")
			lRET := .F.
		ELSE
		    If at("@", cEmail)
			   lRET := .T.
			Else
			   MSGINFO("Email do Requisitante Invalido!","Atenção!")
			   lRET := .F.
			Endif    
		Endif

	ELSEIF cP_ACAO == "OBSERV"
		If Empty(cObser)
			MSGINFO("A observação da Solicitação não foi informada!","Atenção!")
			lRET := .F.
		ELSE
			lRET := .T.
		Endif
	ELSEIF cP_ACAO == "BUSCA_COMPRADOR"
		aORD      := {{SY1->(INDEXORD()),SY1->(RECNO())}}
		cCODCOMPR := SPACE(LEN(SY1->Y1_COD))
		SY1->(DBSETORDER(1))
		IF SY1->(DBSEEK(XFILIAL("SY1")+__cUserID))
			cCODCOMPR := SY1->Y1_COD
		ENDIF
		SY1->(DBSETORDER(aORD[1,1])) ; SY1->(DBGOTO(aORD[1,1]))
		lRET := cCODCOMPR
	ELSEIF cP_ACAO == "CODCOMP"
		IF EMPTY(cCODCOMPR)
			MSGINFO("Código do comprador nao informado!","Atenção!")
			lRET := .F.
		ELSE
			lRET := A110CodCompr(cCodCompr)
		ENDIF
	ELSEIF cP_ACAO == "FILENT"
		If Empty(cFilEnt)
			MSGINFO("Nenhuma Filial de Entrega Selecionada!","Atenção!")
			lRET := .F.
		Endif
	ELSEIF cP_ACAO  == UPPER("bOKARQ")
		IF 	! FVAL("CODCOMP",cCodCompr) .OR.;
				! FVAL("TIPOIMP",.F.) .OR.;
				! FVAL("MOEDAC1") .OR.;
				! FVAL("TELEFONE",cTel) .OR.;
				! FVAL("EMAIL",cEmail) .OR.;
				! FVAL("OBSERV",cObser) .OR.;
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

//Valida os arquivos selecionados
Static Function AtuList()
	Local nIdx := 0
	If lFirst
		aArqArq := {}
		lFirst  := .F.
	endif

	nIdx := Ascan(aArqArq, {|aIt| aIt[2] == cFile} ) 

	If nIdx > 0
		ApMsgInfo("Arquivo " + Char(13) + Char(10) + cFile + Char(13) + Char(10) + "Já foi selecionado, item:" + Str(nIdx), "IMPCSV")
		Return
	EndIf

	Aadd(aArqArq,{.T.,cFile})
	oListBox:SetArray(aArqArq)
	oListBox:bLine := {|| { IIf(aArqArq[oListBox:nAt, 1], oOk, oNo), aArqArq[oListBox:nAt][2]}}
	oListBox:BlDblClick := {|| aArqArq[oListBox:nAt, 1] := !aArqArq[oListBox:nAt, 1], oListBox:Refresh()}
Return nil


//Processa os arquivos selecionados
Static Function PImpCsv()
	LOCAL nX,nA,nB,aCPLN,cSEP,oFile,cARQ,aLINHAS,nCP,aERROS,nCONT,aCAB,aITEM,cNumSc,lVALID,cPRODUTO,nQuant
	LOCAL cLErro,cQRYA,nTOTAL,nQtdMsg,nTotMsg,cNumIt,aCpImp,cNewSc,cTextoE, cQRYB
	Local aRec := {}
	cSep   := ";"
	aERROS := {}
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
				if cProc = 1
				   cNumSc := cNumScN
				   cProc ++
				else
				   cNumSc  :=  GetSX8Num("SC1")
				   cNumScN := cNumSc
    			   cxSCDe := cNumSc
				Endif

				//Prepara cabecalho do execauto Mata110
				Aadd( aCab,{"C1_FILIAL"   , cFILSC1                           , Nil}) // Filial
				Aadd( aCab,{"C1_NUM"      , cNumScN                           , Nil}) // Num. da Solic.Compra
				Aadd( aCab,{"C1_SOLICIT"  , cSC1SOLIC                         , Nil}) // Solicitante
				Aadd( aCab,{"C1_EMISSAO"  , dDATABASE                         , Nil}) // Data Emissao
		 		Aadd( aCab,{"C1_CODCOMP"  , cCodCompr                         , Nil}) // Comprador
		 		Aadd( aCab,{"C1_FILENT"   , cFilEnt                           , Nil}) // Filial de entrega
		 		Aadd( aCab,{"C1_XTPREQ"   , cC1_XTPREQ                        , Nil}) // Tipo de Requisição
		 		Aadd( aCab,{"C1_XREQUIS"  , cRequis                           , Nil}) // Requisitante			 
 				Aadd( aCab,{"C1_XREQFON"  , cTel                              , Nil}) // Telefone do Solicitante			 
		 		Aadd( aCab,{"C1_XREQMAI"  , cEmail                            , Nil}) // Email do Solicitante		 
 				Aadd( aCab,{"C1_XOBSREQ"  , cObser                            , Nil}) // Observação da Solicitação			 

				aLinhas := oFile:GetAllLines()
				procregua(LEN(aLINHAS))
				FOR nB := 1 TO LEN(aLINHAS)
					incproc("Processando arquivo " +AllTrim(Str(nA)) +" de " +ALLTRIM(STR(LEN(aARQARQ)))+", item " +AllTrim(Str(nB)) +" de " +ALLTRIM(STR(LEN(aLINHAS))) +".")
					aCPLN := Separa(aLinhas[nB], cSep)
					nCP   := 9

					If Len(aCpLn) < 9
						nCp := 6
					EndIf

					lValid := .T.
					If LEN(aCPLN) == 6  
						cLinha    := aCPLN[1]
						cProduto  := aCPLN[2]
						nQuant    := Val( StrTran(aCPLN[3],",",".") )
						dNecess   := aCPLN[4]
						cCC       := aCPLN[5]
						cObs      := aCPLN[6]
					Else
						lValid   := .F.
						Aadd(aErros,  {"Layout incorreto, verifique a quantidade de campos (4-Kits, 9-Veiculos)"})
					EndIf
					cLErro   := STRZERO(nCont,5)+" "
					If lValid
						cProduto := Alltrim(STRTRAN(cProduto, "-", "" ))
						cQRYA := "QRYA"
						BEGINSQL ALIAS cQRYA
							SELECT B1_COD
							FROM %TABLE:SB1% SB1
							WHERE SB1.%NOTDEL%
							AND SB1.B1_FILIAL = %xFilial:SB1%
							AND SB1.B1_COD    = %Exp:cProduto%
						ENDSQL
						IF (cQRYA)->(EOF())
							lValid := .F.
							Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Produto não cadastrado."})
						ENDIF
						//Início dos ajustes do GAP009
						If (nQuant <= 0) .or. (nQuant <> NoRound(nQuant, 0))
							lValid := .F.
							Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Não é permitido quantidade quebrada, zerada ou negativa."})
						EndIf
						//Fim dos ajustes do GAP009
						If empty(dNecess) 
							lValid := .F.
							Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Data da Necessidade inválida."})
						EndIf

						cQRYB := "QRYB"
						BEGINSQL ALIAS cQRYB
							SELECT CTT_CUSTO
							FROM %TABLE:CTT% CTT
							WHERE CTT.%NOTDEL%
							AND CTT.CTT_FILIAL = %xFilial:CTT%
							AND CTT.CTT_CUSTO  = %Exp:cCC%
						ENDSQL
						IF (cQRYB)->(EOF())
							lValid := .F.
							Aadd(aErros,  {cLErro+AllTrim(cCC)+" - Centro de Custos não cadastrado."})
						ENDIF



						//Armazena em array para executar o MsExecAuto das SC´s.
						If  lValid
    						aRec := {}
							nQtdMsg ++
							nCont++
							cNumIt := Strzero(nCont,4)
							aCpImp   := {}
 
							Aadd( aCpImp, {"C1_FILIAL"  , cFILSC1              		        , Nil})  // Filial
							Aadd( aCpImp, {"C1_ITEM"    , cNumIt                            , NIL})  // Num. do Item
							Aadd( aCpImp, {"C1_PRODUTO" , (cQRYA)->B1_COD                   , NIL})  // Produto
							Aadd( aCpImp, {"C1_QUANT"   , nQuant                            , NIL})  // Quantidade
							Aadd( aCpImp, {"C1_DATPRF"  , CTOD(dNecess)                     , NIL})  // Data da Necessidade
							Aadd( aCpImp, {"C1_CC"      , (cQRYB)->CTT_CUSTO                , NIL})  // Centro de Custos
							Aadd( aCpImp, {"C1_XOBSITE" , cOBS                              , NIL})  // Centro de Custos

							Aadd( aItem, aCpImp)
						EndIf
						(cQRYA)->(DBCLOSEAREA())
						(cQRYB)->(DBCLOSEAREA())
					EndIf
				NEXT
			ELSE
			    RollBackSx8()
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
				Begin Transaction
                //Executa o ExecAuto	
				MsExecAuto({|v,x,y,z| MATA110(v,x,y,z)},aCab,aItem,3,.F.)

				If lMsErroAuto
					MostraErro()
					RollBackSx8()
					DisarmTransaction()
					Aadd(aErros,  {cLErro+AllTrim(cProduto)+" - Inconsistências na inclusão da solicitção "})
				Else
					//Utilizado no Relatorio variaveis: cxSCDe e cxSCAte
					If Empty(cxSCDe)
						cxSCDe := cNumSc
					EndIf
					cxSCAte := cNumSc    
					ConfirmSX8()
					fGravaSC1(cFilEnt, cNumSc)  //Grava informações complementares na SC1, após a inclusão do MsExecAuto.
				EndIf
				End Transaction
			Endif
			
		Endif
		If Len(aErros) == 0
			If MsgYesNo( "Deseja Imprimir o Relatorio?", "Deseja Imprimir o Relatorio?" )
				U_ZCOMR003()
			Else
				If !Empty(cNumSC)
					AVISO("SC Gerada Com Sucesso", "SC              : " + cNumSC + CRLF + "Quant Itens     : " + Alltrim(Str(nQtdMsg)) )
				EndIf
			EndIf
		ElseIf Len(aErros) > 0
			cTextoE := ""
			cTextoE += "Linha Produto"+chr(13)+chr(10)
			cTextoE += "----- -------"+chr(13)+chr(10)
			For nX:=1 to Len(aErros)
				cTextoE += aErros[nX,1]+chr(13)+chr(10)
			Next
			aErros := {}
			Define Font oFont Name "Mono AS" Size 7, 16
			DEFINE MSDIALOG oDlgMemo TITLE "Solicitações não importadas!" FROM 3,0 TO 340,417 OF oMainWnd PIXEL
			@ 5,5 Get oMemo Var cTextoE Memo Size 200, 145 Of oDlgMEMO Pixel
			oMemo:oFont := oFont
			Define SButton From 153, 175 Type  1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action (cFileL := cGetFile(cMask, ""), If(cFileL == "", .T., MemoWrite(cFileL, cTextoE))) Enable Of oDlgMemo Pixel
			ACTIVATE MSDIALOG oDlgMemo CENTERED
		EndIf
	NEXT
RETURN(NIL)


/*/{Protheus.doc} fGravaSC1
Função Auxiliar, utilizda para atualizar algumas informações na SC1 após sua inclusão. Força a atualização de algumas informações.
@author Sandro Ferreira
@since 04/01/2022
@version 1.0
@param Filial      , characters
@param Solicitação , characters
@type function
/*/
Static Function fGravaSC1(xFil, xSC)
    SC1->(DbSetOrder(1))
    SC1->(DbSeek(xFilial("SC1") + xSC))

	While !SC1->(EOF()) .AND. ( SC1->C1_FILIAL = xFil .and. SC1->C1_NUM = xSC )
 
        RecLock("SC1",.F.)
	   		C1_XTPREQ    := cC1_XTPREQ
			C1_XREQUIS   := cRequis
			C1_XREQFON   := cTel
			C1_XREQMAI   := cEmail
			C1_XOBSREQ   := cObser	
		SC1->(MsUnlock())
        
	    Sc1->( dbSkip() )
	
	End
    SC1->(DbSeek(xFilial("SC1") + xSC))
Return(NIL)

