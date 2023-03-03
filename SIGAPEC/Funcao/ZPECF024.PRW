#Include "PROTHEUS.CH"
#Include "rwmake.ch"
#Include 'parmtype.ch'
#Include "OFIOC520.CH"
#Include "FWBROWSE.ch"
#Include "Totvs.ch"
#DEFINE MVC_STRUCT_ID        01 // Id do Field
#DEFINE MVC_STRUCT_ORDEM     02 // Ordem
#DEFINE MVC_STRUCT_TITULO    03 // Titulo do campo
#DEFINE MVC_STRUCT_DESCRICAO 04 // Descricao do campo
#DEFINE MVC_STRUCT_TIPO      05 // Tipo do campo
#DEFINE MVC_STRUCT_TAM       06 // Tamanho do campo
#DEFINE MVC_STRUCT_DEC       07 // Decimal do campo
#DEFINE MVC_STRUCT_CBOX      08 // Array	Lista de valores permitido do campo	{}
#DEFINE MVC_STRUCT_OBRIGAT   09 // Indica se o campo tem preenchimento obrigatório
#DEFINE MVC_STRUCT_VIRTUAL   10 // Indica se o campo é virtual
#DEFINE MVC_STRUCT_PICTURE   11 // Picture
#DEFINE MVC_STRUCT_F3        12 // Consulta F3
#DEFINE MVC_STRUCT_ALTER     13 // Indica se o campo é alteravel
#DEFINE MVC_STRUCT_PASTA     14 // Pasta do campo
#DEFINE MVC_STRUCT_AGRP      15 // Agrupamento do campo
#DEFINE MVC_STRUCT_NEWLINE   16 // Pula linha depois do campo

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | ZPECF024   | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta Analitica de Itens                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
User Function ZPECF024(cProduto)  //lNoMBrowse

Local cBkpFilial   := cFilAnt
Local aBkpArea     := SB1->(GetArea())
Local bBlock

//LOCAL oDlg
//LOCAL nOpca       := 0
//Local aPergs 	    := {}
//Local cProduto    := Space(23)
//Local cInvice     := Space(30)
Private cCadastro  := "Análise de Itens"
Private aRotina    := MenuDef()
Default lNoMBrowse := .T.

Private aRetP 	  := {}

   /* aAdd( aPergs ,{1,"Informe o Produto ",cProduto     ,"@!" , ""  , "SB1","", 100,.F. })

    IF Empty(cProduto)
        aAdd( aPergs ,{1,"Informe a Invoice ",cInvice      ,"@!" , ""  , "SW8","", 100,.F. })
    ENDIF

    IF !Empty(cProduto) .OR. !Empty(cProduto)
        aAdd(aParamBox,{ 1, "Dt Embarque ", CtoD(''), "@D", "", "","", 50	,.F.})
    ENDIF

    If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 

        DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi(cCadastro) PIXEL
        @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
        @ 29, 15 SAY OemToAnsi("Esta rotina realiza a análise de ítens") SIZE 268, 8 OF oDlg PIXEL
        @ 38, 15 SAY OemToAnsi("Da Caoa Barueri.") SIZE 268, 8 OF oDlg PIXEL
        @ 48, 15 SAY OemToAnsi("Confirma Geração da Documento?") SIZE 268, 8 OF oDlg PIXEL
        DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
        DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
        ACTIVATE MSDIALOG oDlg CENTER

    Endif*/

//Return()

//
If type("nOpc") == "U"
	nOpc := 2
EndIf
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar o modulo de ( 14 - Oficina ) ou ( 41 - Auto Pecas ) //
///////////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(14,41) .or. !FMX_AMIIn({"OFIXA018","OFIXA012","OFIXA011","ZPECF024","OFIXA120","OFIXC001","MATA297M","OFINJD10"})
	Return
EndIf
//
DbSelectArea("SB1")
//
If lNoMBrowse
	If ( nOpc <> 0 ) .And. !Deleted()
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf
Else
	mBrowse( 6, 1,22,75,"SB1")
EndIf
//
RestArea(aBkpArea)
cFilAnt := cBkpFilial
//
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |OC024Visual | Autor | Andre Luis Almeida    | Data | 14/08/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao |Visualizacao                                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC024Visual(cAlias,nReg,nOpc)

	Local aCpoRegistro := {}

	Local cBkpFilial := cFilAnt
	Local aBkpArea := GetArea()  //sGetArea(,"SB1")
	Local lSBZ := ( SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ" )
	Local nI

	Local nSavnOpc := nOpc
	Local lSavIncl := .f.
	Local lSavAlte := .f.
	Local aNewBot  := {}
	Local cPictQtd := PesqPict("SB2","B2_QATU")
	Local cPictVlr := PesqPict("SB1","B1_PRV1")
	
	Private oSizePrinc
	Private oSizeSup
	Private oSizeFiltro
	Private oSizeDet
	Private oSizeDet1
	Private oSizeDet2

	Private oDlg024
	Private obC024EncFiltro
	Private obC024EncDetalhe
	Private obC024Estq
	Private obC024Deman
	Private obC024Btn
	Private obC024CmpVen
	Private obC024TPrc
	Private obC024ItRel
	Private obC024ItSub
	Private obC024Check

	Private a024FldFiltro  := {}
	Private a024FldDetalhe := {}

	Private oAnt    := LoadBitmap( GetResources() , "metas_baixo_16" )
	Private oNov    := LoadBitmap( GetResources() , "metas_cima_16" )
	Private lMLF    := SB5->(FieldPos("B5_MARPEC")) > 0 .and. SB5->(FieldPos("B5_CODLIN")) > 0 .and. SB5->(FieldPos("B5_CODFAM")) > 0// quando .T. trabalha com Marca / Linha / Familia
	Private lMLFSBZ := SBZ->(FieldPos("BZ_MARPEC")) > 0 .and. SBZ->(FieldPos("BZ_CODLIN")) > 0 .and. SBZ->(FieldPos("BZ_CODFAM")) > 0// quando .T. trabalha com Marca / Linha / Familia

	Private oFiltroC525

	Private aCpoCtm := {}
	Private lVAI_ACEDET := VAI->(ColumnPos('VAI_ACEDET')) > 0
	Private lExibePreco := .F.
	Private _cPC_NUM    := ""
	Private nCtBo       := 0
	Private cQtdbo      := "0"

	dbSelectArea("VAI")
	dbSetOrder(4)
	dbSeek(xFilial("VAI")+__cUserID)

	If Type("INCLUI") != "U"
		lSavIncl := INCLUI
	Endif
	If Type("ALTERA") != "U"
		lSavAlte := ALTERA
	Endif

	///////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Valida se a empresa tem autorizacao para utilizar o modulo de ( 14 - Oficina ) ou ( 41 - Auto Pecas ) //
	///////////////////////////////////////////////////////////////////////////////////////////////////////////
	If !AMIIn(14,41) .or. !FMX_AMIIn({"OFIXA018","OFIXA012","OFIXA011","ZPECF024","OFIXA120","OFIXC001","MATA297M","OFINJD10"})
		Return()
	EndIf

	If ( ExistBlock("OC024ABT") )
		aNewBot := ExecBlock("OC024ABT",.f.,.f.,{aNewBot})
	EndIf

	SB1->(dbGoTo(nReg))

	Static oC024Peca := DMS_Peca():New()
	oC024Peca:SetGrupo(SB1->B1_GRUPO)

    //oC024Peca:SetInvoice(SW8->W8_INVOICE)

	oC024Peca:SetCodigo(SB1->B1_CODITE)

	Pergunte( "OFIOC525" , .f. ,,,,.f.)
	oFiltroC525 := DMS_DataContainer():New({;
					{'DATA_INICIAL',(dDataBase-MV_PAR01) },; // Data Inicial 
					{'DATA_FINAL'  ,dDataBase            },; // Data Final
					{'TIPO_PEDIDO_DESCONSIDERAR',MV_PAR02}; // Tp.Pedido Desconsiderar
	})

	// Calcula Coordenadas dos objetos
	OC024CalcSize()

	DEFINE MSDIALOG oDlg024 TITLE STR0001 OF oMainWnd PIXEL;
		FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

	// Para cada variavel que comeca com C024 existe uma variavel igual, mas comecando com P024 que deve ser utilizada nos parametros
	//
	// [1] - Nome do campo
	// [2] - Nome do campo que sera considerado (pode ser informado quando é utilizado os dados do dicionario - SX3)
	// [3] - Utilizar SX3 ?
	aCampos := { ;
		{ "B1_COD"      , "C024B1COD" , .t. },;
		{ "B1_DESC"     , "" , .t. },;
		{ "C024PARFIL"  , "" , .f. }}

	aCpoRegistro := {}
	OC024AddField(aCampos, @a024FldFiltro, "OC024Field" )
	nPos := aScan(a024FldFiltro,{ |x| x[2] == "C024B1COD" })
	a024FldFiltro[ nPos , 11 ] := "SB1"
	a024FldFiltro[ nPos , 07 ] := { || OC024Valid() }
	a024FldFiltro[ nPos , 13 ] := .f.
	a024FldFiltro[ nPos , 17 ] := .f.
	aEval(a024FldFiltro,{ |x| ;
		&("M->" + x[2]) := &("M->P" + SubStr(x[2],2)) := OC024AtVal(x) ,;
		AADD( aCpoRegistro , x[2] ) })

	obC024EncFiltro := MsmGet():New(,,2 /* Visualizar */,;
		/*aCRA*/,/*cLetras*/,/*cTexto*/,aClone(aCpoRegistro),;
		oSizeFiltro:GetObjectArea("FILTRO"), ;
		aClone(aCpoRegistro), 3 /*nModelo*/,;
		/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg024 , .t. /*lF3*/, .t. /* lMemoria */ , .t. /*lColumn*/,;
		/*caTela*/, .t. /*lNoFolder*/, .F. /*lProperty*/,;
		aClone(a024FldFiltro), /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)

	//obC024EncFiltro:oBox:l3DLook := .f.
	//obC024EncFiltro:oBox:lBorder := .f.

	TButton():New( oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 1, oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") ,;
		STR0041, oDlg024 , { || OC024Atu(.t.) }, oSizeFiltro:GetDimension("BTN_ATUALIZA","XSIZE") , 010,,,.F.,.T.,.F.,,.F.,,,.F. ) // Atualizar

	aCampos := {}
	//AADD( aCampos , { "W8_INVOICE"  , "" , .t. } )
	AADD( aCampos , { "B1_CODITE"   , "" , .t. } )
	AADD( aCampos , { "B1_DESC"     , "" , .t. } )
	if lSBZ .and. lMLFSBZ
		AADD( aCampos , { "BZ_MARPEC"     , "" , .t. } )
		AADD( aCampos , { "BZ_CODLIN"     , "" , .t. } )
		AADD( aCampos , { "BZ_CODFAM"     , "" , .t. } )
	Elseif lMLF
		AADD( aCampos , { "B5_MARPEC"     , "" , .t. } )
		AADD( aCampos , { "B5_CODLIN"     , "" , .t. } )
		AADD( aCampos , { "B5_CODFAM"     , "" , .t. } )
	Else
		AADD( aCampos , { "BM_CODMAR"     , "" , .t. } )
	EndIf
	AADD( aCampos , { "B1_CODBAR"     , "" , .t. } )
	AADD( aCampos , { "B1_FABRIC"     , "" , .t. } )
	AADD( aCampos , { "C024GRUDES"    , "" , .t. } )
	AADD( aCampos , { "C024ORIGEM"    , "" , .t. } )
	AADD( aCampos , { "B1_UM"         , "" , .t. } )
	AADD( aCampos , { "B1_IPI"        , "" , .t. } )
	AADD( aCampos , { "B1_POSIPI"     , "" , .t. } )
	AADD( aCampos , { "C024GRTRIB"    , "" , .t. } )
	AADD( aCampos , { "B1_QE"         , "" , .t. } )
	AADD( aCampos , { "B1_CRICOD"     , "" , .t. } )
	AADD( aCampos , { "B1_DTREFP1"    , "" , .t. } )
	AADD( aCampos , { "C024MSBLQL"    , "" , .t. } )
	AADD( aCampos , { "B1_CODGEN"     , "" , .t. } )

	If ExistBlock("OC024CPO") // Adição de Campos Customizados pelo Cliente	
		aCpoCtm := ExecBlock("OC024CPO",.F.,.F., aCpoCtm)
		For nI := 1 to len(aCpoCtm)
			aadd(aCampos, aCpoCtm[nI])
		Next
	Endif

	aCpoRegistro := {}
	OC024AddField(aCampos, @a024FldDetalhe, "OC024Field" )
	aEval(a024FldDetalhe,{ |x| &("M->" + x[2]) := OC024AtVal(x) , AADD( aCpoRegistro , x[2] ) })

	obC024EncDetalhe := MsmGet():New(,,2 /* Visualizar */,;
		/*aCRA*/,/*cLetras*/,/*cTexto*/,aClone(aCpoRegistro),;
		oSizeSup:GetObjectArea("DETALHE"), ;
		aClone(aCpoRegistro), 3 /*nModelo*/,;
		/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg024 , .f. /*lF3*/, .t. /* lMemoria */ , .f. /*lColumn*/,;
		/*caTela*/, .t. /*lNoFolder*/, .f. /*lProperty*/,;
		aClone(a024FldDetalhe), /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)

	// ------------------- //
	// CRIA BOX - ESTOQUE  //
	// ------------------- //
	TButton():New( oSizeDet1:GetDimension("ESTOQUE","LININI"), oSizeDet1:GetDimension("ESTOQUE","COLINI"), STR0042, oDlg024,; // Estoque
		{ || OC024Exec("OFIOC521") },;
		oSizeDet1:GetDimension("ESTOQUE","XSIZE"), 010,,,.F.,.T.,.F.,,.F.,,,.F. )
	    obC024Estq := TWBrowse():New( ;
		oSizeDet1:GetDimension("ESTOQUE","LININI")+11,;
		oSizeDet1:GetDimension("ESTOQUE","COLINI"),;
		oSizeDet1:GetDimension("ESTOQUE","XSIZE"), ;
		oSizeDet1:GetDimension("ESTOQUE","YSIZE")-11 ,,,,oDlg024,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		obC024Estq:AddColumn( TCColumn():New( STR0004 , { || obC024Estq:aArray[obC024Estq:nAT,1] + " - " + obC024Estq:aArray[obC024Estq:nAT,4] } ,,,,"LEFT"   ,(oSizeDet1:GetDimension("ESTOQUE","XSIZE")*0.35),.F.,.F.,,,,.F.,) ) // "Estoque"
		obC024Estq:AddColumn( TCColumn():New( STR0005 , { || Transform(obC024Estq:aArray[obC024Estq:nAT,2],cPictQtd) } ,,,,"RIGHT"  ,(oSizeDet1:GetDimension("ESTOQUE","XSIZE")*0.30),.F.,.F.,,,,.F.,) ) // "Empresa"
		obC024Estq:AddColumn( TCColumn():New( STR0006 , { || Transform(obC024Estq:aArray[obC024Estq:nAT,3],cPictQtd) } ,,,,"RIGHT"  ,(oSizeDet1:GetDimension("ESTOQUE","XSIZE")*0.30),.F.,.F.,,,,.F.,) ) // "Consol."
		obC024Estq:nAt := 1
		obC024Estq:SetArray({})

	// ------------------- //
	// CRIA BOX - DEMANDA  //
	// ------------------- //
	TButton():New( oSizeDet1:GetDimension("DEMANDA","LININI"), oSizeDet1:GetDimension("DEMANDA","COLINI"), STR0043, oDlg024,; // Demandas
		{ || OC024Exec("OFIOC524") },;
		oSizeDet1:GetDimension("DEMANDA","XSIZE"), 010,,,.F.,.T.,.F.,,.F.,,,.F. )
	obC024Deman := TWBrowse():New( ;
		oSizeDet1:GetDimension("DEMANDA","LININI")+11,;
		oSizeDet1:GetDimension("DEMANDA","COLINI"),;
		oSizeDet1:GetDimension("DEMANDA","XSIZE"), ;
		oSizeDet1:GetDimension("DEMANDA","YSIZE")-11 ,,,,oDlg024,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	obC024Deman:AddColumn( TCColumn():New( STR0007     , { || obC024Deman:aArray[obC024Deman:nAT,2] } ,,,,"LEFT"   ,(oSizeDet1:GetDimension("DEMANDA","XSIZE")*0.35),.F.,.F.,,,,.F.,) ) // "Mês"
	obC024Deman:AddColumn( TCColumn():New( STR0005 , { || Transform(obC024Deman:aArray[obC024Deman:nAT,3],cPictQtd) } ,,,,"RIGHT"  ,(oSizeDet1:GetDimension("DEMANDA","XSIZE")*0.30),.F.,.F.,,,,.F.,) ) // "Empresa"
	obC024Deman:AddColumn( TCColumn():New( STR0006 , { || Transform(obC024Deman:aArray[obC024Deman:nAT,4],cPictQtd) } ,,,,"RIGHT"  ,(oSizeDet1:GetDimension("DEMANDA","XSIZE")*0.30),.F.,.F.,,,,.F.,) ) // "Consol."
	obC024Deman:nAt := 1
	obC024Deman:SetArray({})
	obC024Deman:Refresh()

	// ------------------- //
	// CRIA BOX COM BOTOES //
	// ------------------- //
	obC024Btn := TScrollBox():New( oDlg024 ,;
		oSizeDet1:GetDimension("BOTOES","LININI"),;
		oSizeDet1:GetDimension("BOTOES","COLINI"),;
		oSizeDet1:GetDimension("BOTOES","LINEND")-oSizeDet1:GetDimension("BOTOES","LININI"),;
		oSizeDet1:GetDimension("BOTOES","COLEND")-oSizeDet1:GetDimension("BOTOES","COLINI"),;
		.t. /* lVertical */ , .f. /* lHorizontal */ , .f. /* lBorder */ )
	nLin := 0
	TButton():New( nLin, 02, STR0008 , obC024Btn,{|| OC024Exec("OFIOC150") }, 040, 010,,,.F.,.T.,.F.,,.F.,{ || .t. } /* bWhen */ ,,.F. )
	nLin += 13
	//TButton():New( nLin, 02, STR0009 , obC024Btn,{|| OC024Exec("M_LCPCJD") }, 040, 010,,,.F.,.T.,.F.,,.F.,{ || ExistBlock("M_LCPCJD") } /* bWhen */ ,,.F. ) // Simulação 
	//nLin += 13
	TButton():New( nLin, 02, STR0010 , obC024Btn,{|| OC024Exec("OFIOC525") }, 040, 010,,,.F.,.T.,.F.,,.F.,{ || .t. } /* bWhen */ ,,.F. ) // Pedidos
	nLin += 13
	TButton():New( nLin, 02, STR0011 , obC024Btn,{|| OC024Exec("OFIOC526") }, 040, 010,,,.F.,.T.,.F.,,.F.,{ || .t. } /* bWhen */ ,,.F. ) // Reservas
	nLin += 13
	//TButton():New( nLin, 02, STR0040 , obC024Btn,{|| OC024Exec("OFIOC528") }, 040, 010,,,.F.,.T.,.F.,,.F.,{ || .t. } /* bWhen */ ,,.F. ) // Transferencias
    
	TButton():New( nLin, 02, "B.O." , obC024Btn,{||U_AltModul()}, 040, 010,,,.F.,.T.,.F.,,.F.,{ || .t. } /* bWhen */ ,,.F. ) // BO
	nLin += 13   
	TButton():New( nLin, 02, "Invoices",obC024Btn,{|| U_ZPECF027(SB1->B1_COD) }, 040, 010,,,.F.,.T.,.F.,,.F.,{ || .t. } /* bWhen */ ,,.F. ) // Gerenciamento de Invoices
    nLin += 13
	TButton():New( nLin, 02, "P.O." , obC024Btn,{|| U_ZPECF029(SB1->B1_COD) }, 040, 010,,,.F.,.T.,.F.,,.F.,{ || .t. } /* bWhen */ ,,.F. ) // Gerenciamento de POs

	// ------------------------------------------- //
	// TIKS                                        //
	// ------------------------------------------- //
	nLin := oSizeDet1:GetDimension("TIKS","LININI")
	nCol := oSizeDet1:GetDimension("TIKS","COLINI")
	@ nLin,nCol TO nLin+oSizeDet1:GetDimension("TIKS","YSIZE"),nCol+oSizeDet1:GetDimension("TIKS","XSIZE") LABEL "" OF oDlg024 PIXEL
	nLin += 6
	nCol += 5
	@ nLin , nCol CHECKBOX oChkOriginal VAR OC024TICK("1") PROMPT STR0012  OF oDlg024 SIZE 80, 10 WHEN .f. PIXEL
	nLin += 10
	@ nLin , nCol CHECKBOX oChkDescVend VAR OC024TICK("2") PROMPT STR0013   OF oDlg024 SIZE 80, 10 WHEN .f. PIXEL
	nLin += 10
	@ nLin , nCol CHECKBOX oChkPromocao VAR OC024TICK("3") PROMPT STR0014   OF oDlg024 SIZE 80, 10 WHEN .f. PIXEL
	nLin += 10
	@ nLin , nCol CHECKBOX oChkPedPend  VAR OC024TICK("4") PROMPT STR0015   OF oDlg024 SIZE 80, 10 WHEN .f. PIXEL
	If ( SB1->(FieldPos("B1_REMANE")) <> 0 )
		nLin += 10
	//	@ nLin , nCol CHECKBOX oChkRetorn VAR OC024TICK("5") PROMPT STR0016   OF oDlg024 SIZE 80, 10 WHEN .f. PIXEL
	EndIf

	// ------------------------------------------- //
	// CRIA BOX COM INFORMACOES DE COMPRA E VENDA  //
	// ------------------------------------------- //
	obC024CmpVen := TScrollBox():New( oDlg024 ,;
		oSizeDet1:GetDimension("COMPRA_VENDA","LININI")+1,;
		oSizeDet1:GetDimension("COMPRA_VENDA","COLINI")+1,;
		oSizeDet1:GetDimension("COMPRA_VENDA","LINEND")-oSizeDet1:GetDimension("COMPRA_VENDA","LININI")-2,;
		oSizeDet1:GetDimension("COMPRA_VENDA","COLEND")-oSizeDet1:GetDimension("COMPRA_VENDA","COLINI")-2,;
		.t. /* lVertical */ , .f. /* lHorizontal */ , .f. /* lBorder */ )

	@ oSizeDet1:GetDimension("COMPRA_VENDA","LININI"),oSizeDet1:GetDimension("COMPRA_VENDA","COLINI") TO oSizeDet1:GetDimension("COMPRA_VENDA","LINEND"),oSizeDet1:GetDimension("COMPRA_VENDA","COLEND") LABEL "" OF oDlg024 PIXEL

	nLin := 03
	@ nLin+1 , 03 SAY STR0017 OF obC024CmpVen PIXEL SIZE 200,20
	TGet():New( nLin, 50, { || oC024Peca:GetUltVenda() },obC024CmpVen, 45, 1, "@D",,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"dUltVenda",,,,.T. )
	TButton():New( nLin, 95, STR0018, obC024CmpVen,{ || OC024Exec("OFIOC523") },030, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
	nLin += 13
	@ nLin+1 , 03 SAY STR0019 OF obC024CmpVen PIXEL SIZE 200,20
	TGet():New( nLin, 50, { || SB1->B1_UCOM },obC024CmpVen, 45, 1, "@D",,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"dUltCompra",,,,.T. )
	TButton():New( nLin+07, 95, STR0020, obC024CmpVen,{ || OC024Exec("OFIOC522") },	030, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
	nLin += 13
	@ nLin+1 , 03 SAY STR0021 OF obC024CmpVen PIXEL SIZE 200,20
	TGet():New( nLin, 50, { || oC024Peca:GetUltCompra() },obC024CmpVen, 45, 1, "@D",,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"dUltCompra",,,,.T. )
	nLin += 13
	@ nLin+1 , 03 SAY STR0022 OF obC024CmpVen PIXEL SIZE 100,20
	TGet():New( nLin, 50, { || SB1->(FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")) },obC024CmpVen, 76, 1, "@!",,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"cLocacao",,,, )
	nLin += 13
	@ nLin+1 , 03 SAY STR0015 OF obC024CmpVen PIXEL SIZE 200,20
	TGet():New( nLin, 50, { || oC024Peca:PedCompraPendente(oFiltroC525) },obC024CmpVen, 76, 1, x3Picture("C7_QUANT") ,,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"nQtdPendente",,,,.T. )
    nLin += 13
	@ nLin+1 , 03 SAY "QTDE. BO" OF obC024CmpVen PIXEL SIZE 200,20
	TGet():New( nLin, 50, { || U_XCONTABO() },obC024CmpVen, 76, 1, "@!" ,,, ,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"cQtdbo",,,,.T. )


	// ---------------------------- //
	// CRIA BOX COM TABELA DE PRECO //
	// ---------------------------- //
	lExibePreco := .F.
	If lVAI_ACEDET
		If VAI->VAI_ACEDET <> "0"
			lExibePreco := .T.
		Endif
	Else
		lExibePreco := .T.
	Endif

	If lExibePreco
		@ oSizeDet2:GetDimension("TAB_PRECO","LININI"),;
		oSizeDet2:GetDimension("TAB_PRECO","COLINI") TO oSizeDet2:GetDimension("TAB_PRECO","LININI") + oSizeDet2:GetDimension("TAB_PRECO","YSIZE"),;
		oSizeDet2:GetDimension("TAB_PRECO","COLINI") + oSizeDet2:GetDimension("TAB_PRECO","XSIZE") - 50 LABEL STR0044 OF oDlg024 PIXEL // Preços
		obC024TPrc := TWBrowse():New( ;
			oSizeDet2:GetDimension("TAB_PRECO","LININI")+8,;
			oSizeDet2:GetDimension("TAB_PRECO","COLINI"),;
			oSizeDet2:GetDimension("TAB_PRECO","XSIZE")-50, ;
			oSizeDet2:GetDimension("TAB_PRECO","YSIZE")-8 ,,,,oDlg024,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		obC024TPrc:AddColumn( TCColumn():New( STR0023 , { || obC024TPrc:aArray[obC024TPrc:nAT,1] } ,,,,"LEFT"   ,(oSizeDet2:GetDimension("TAB_PRECO","XSIZE")*0.50),.F.,.F.,,,,.F.,) )
		obC024TPrc:AddColumn( TCColumn():New( STR0024     , { || Transform(obC024TPrc:aArray[obC024TPrc:nAT,2],"@E 999,999,999.99") } ,,,,"RIGHT"  ,(oSizeDet2:GetDimension("TAB_PRECO","XSIZE")*0.10),.F.,.F.,,,,.F.,) )
		obC024TPrc:nAt := 1
		obC024TPrc:SetArray({})
	Endif

	// ------------------------------- //
	// CRIA BOX COM ITENS RELACIONADOS //
	// ------------------------------- //
	@ oSizeDet2:GetDimension("ITENS_REL","LININI"),;
		oSizeDet2:GetDimension("ITENS_REL", "COLINI") - If(lExibePreco, 50, 317) TO oSizeDet2:GetDimension("ITENS_REL", "LININI") + oSizeDet2:GetDimension("ITENS_REL", "YSIZE"),;
		oSizeDet2:GetDimension("ITENS_REL", "COLINI") + oSizeDet2:GetDimension("ITENS_REL","XSIZE") - If(lExibePreco, 25, 160) LABEL STR0045 OF oDlg024 PIXEL // Itens Relacionados
	obC024ItRel := TWBrowse():New(;
		oSizeDet2:GetDimension("ITENS_REL", "LININI") + 8,;
		oSizeDet2:GetDimension("ITENS_REL", "COLINI") - If(lExibePreco, 50, 317),;
		oSizeDet2:GetDimension("ITENS_REL", "XSIZE") + If(lExibePreco, 25, 156),;
		oSizeDet2:GetDimension("ITENS_REL", "YSIZE") - 8,,,,oDlg024,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	obC024ItRel:AddColumn( TCColumn():New( STR0025 , { || obC024ItRel:aArray[obC024ItRel:nAT,1] } ,,,,"LEFT"   ,(oSizeDet2:GetDimension("ITENS_REL","XSIZE")*0.30),.F.,.F.,,,,.F.,) )
	obC024ItRel:AddColumn( TCColumn():New( STR0026 , { || obC024ItRel:aArray[obC024ItRel:nAT,2] } ,,,,"LEFT"   ,(oSizeDet2:GetDimension("ITENS_REL","XSIZE")*0.30),.F.,.F.,,,,.F.,) )
	obC024ItRel:AddColumn( TCColumn():New( STR0027 , { || Transform(obC024ItRel:aArray[obC024ItRel:nAT,3],cPictQtd) } ,,,,"RIGHT"  ,(oSizeDet2:GetDimension("ITENS_REL","XSIZE")*0.15),.F.,.F.,,,,.F.,) )
	obC024ItRel:AddColumn( TCColumn():New( STR0024 , { || Transform(obC024ItRel:aArray[obC024ItRel:nAT,4],cPictVlr) } ,,,,"RIGHT"  ,(oSizeDet2:GetDimension("ITENS_REL","XSIZE")*0.20),.F.,.F.,,,,.F.,) )
	obC024ItRel:nAt := 1
	obC024ItRel:SetArray({})

	// -------------------------------------------- //
	// CRIA BOX COM ITENS SUBSTITUIDOS/SUBSTITUTOS  //
	// -------------------------------------------- //
	@ oSizeDet2:GetDimension("ITENS_SUB", "LININI"),;
		oSizeDet2:GetDimension("ITENS_SUB", "COLINI") - If(lExibePreco, 50, 156) TO oSizeDet2:GetDimension("ITENS_SUB", "LININI") + oSizeDet2:GetDimension("ITENS_SUB", "YSIZE"),;
		oSizeDet2:GetDimension("ITENS_SUB", "COLINI") + oSizeDet2:GetDimension("ITENS_SUB", "XSIZE") - If(lExibePreco, 0, 0) LABEL STR0046 OF oDlg024 PIXEL // Itens Substituidos / Substitutos
	obC024ItSub := TWBrowse():New( ;
		oSizeDet2:GetDimension("ITENS_SUB", "LININI") + 8,;
		oSizeDet2:GetDimension("ITENS_SUB", "COLINI") - If(lExibePreco, 25, 156),;
		oSizeDet2:GetDimension("ITENS_SUB", "XSIZE") + If(lExibePreco, 25, 156),;
		oSizeDet2:GetDimension("ITENS_SUB", "YSIZE") - 8,,,,oDlg024,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	obC024ItSub:AddColumn( TCColumn():New( "" , { || IIf(obC024ItSub:aArray[obC024ItSub:nAT,4]=="A",oAnt,oNov) } ,,,,"LEFT"   ,(oSizeDet2:GetDimension("ITENS_SUB","XSIZE")*0.05),.T.,.F.,,,,.F.,) )
	obC024ItSub:AddColumn( TCColumn():New( STR0025 , { || obC024ItSub:aArray[obC024ItSub:nAT,1] } ,,,,"LEFT"   ,(oSizeDet2:GetDimension("ITENS_SUB","XSIZE")*0.35),.F.,.F.,,,,.F.,) )
	obC024ItSub:AddColumn( TCColumn():New( STR0026 , { || obC024ItSub:aArray[obC024ItSub:nAT,2] } ,,,,"LEFT"   ,(oSizeDet2:GetDimension("ITENS_SUB","XSIZE")*0.30),.F.,.F.,,,,.F.,) )
	obC024ItSub:AddColumn( TCColumn():New( STR0027    , { || Transform(obC024ItSub:aArray[obC024ItSub:nAT,3],cPictQtd) } ,,,,"RIGHT"  ,(oSizeDet2:GetDimension("ITENS_SUB","XSIZE")*0.15),.F.,.F.,,,,.F.,) )
	obC024ItSub:AddColumn( TCColumn():New( STR0024    , { || Transform(obC024ItSub:aArray[obC024ItSub:nAT,5],cPictVlr) } ,,,,"RIGHT"  ,(oSizeDet2:GetDimension("ITENS_SUB","XSIZE")*0.20),.F.,.F.,,,,.F.,) )
	obC024ItSub:nAt := 1
	obC024ItSub:SetArray({})

	// Atualiza Controles ...
	OC024Atu(.f.)

	ACTIVATE MSDIALOG oDlg024          ON INIT  (EnchoiceBar(oDlg024,{||oDlg024:End()},{||oDlg024:End() },, aNewBot))

	RestArea(aBkpArea)  //sRestArea(aBkpArea)
	nOpc    := nSavnOpc

	If Type("INCLUI") != "U"
		INCLUI := lSavIncl
	Endif
	If Type("ALTERA") != "U"
		ALTERA := lSavAlte
	Endif
	cFilAnt := cBkpFilial

Return


/*/{Protheus.doc} ZPECF024
- Alterar o módulo
@author
@since 26/08/2022

@version 1.0
@type function
/*/
User Function AltModul()
Local cFunBkp := FunName()
Local _aArea  := GetArea()
Local aRotAnt := Arotina 

//SetFunName("OFIXA011") 
//OFIXA011(" ",.F.)

U_ZPECF028(C024B1COD)

// retorna ao FunName original
SetFunName(cFunBkp) 

aRotina := aRotAnt

RestArea(_aArea)

Return()



/*/{Protheus.doc} ZPECF024
- Apresentar a quantidade em BO
@author
@since 06/09/2022

@version 1.0
@type function
/*/
User Function XContaBO()
Local cAliasVS3  := GetNextAlias() 
Local cQtdbo     := "0"

IF Empty(C024B1COD)
    Return(cQtdbo)
ENDIF

BeginSql Alias cAliasVS3
	SELECT SUM(VS3.VS3_QTDITE) nCtBo
	FROM %Table:VS1% VS1
	INNER JOIN %Table:VS3% VS3
		ON VS3.VS3_FILIAL = %xFilial:VS3%
		AND VS3.VS3_NUMORC = VS1.VS1_NUMORC
		AND VS3_CODITE = %Exp:C024B1COD%
		AND VS3.%NotDel%
	WHERE VS1.VS1_FILIAL = %xFilial:VS1%
		AND VS1.VS1_STATUS NOT IN ('C','X')
		AND VS1.VS1_XBO = 'S'
		AND VS1.%NotDel%
EndSql

(cAliasVS3)->(DbGoTop())

IF (cAliasVS3)->(!EOF())
	IF Empty((cAliasVS3)->nCtBo)
		cQtdbo := "0"
	ELSE
		cQtdbo := Alltrim(Str((cAliasVS3)->nCtBo))
	endif
ENDIF

If Select((cAliasVS3)) <> 0
	(cAliasVS3)->(DbCloseArea())
	Ferase(cAliasVS3+GetDBExtension())
Endif

Return(cQtdbo)



/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC024Valid | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC024Valid( cReadVar )
	Local lRet := .F.
	Local aAreaB1

	Default cReadVar := ReadVar()

	Do Case
	Case cReadVar == "M->C024B1COD"
		aAreaB1 := SB1->(GetArea())
		SB1->(dbSetOrder(1))
		If (lRet := SB1->(MsSeek(xFilial("SB1")+M->C024B1COD)))
			M->B1_DESC := SB1->B1_DESC
		EndIf
		/*aArea := sGetArea(,"SW8")
		SW8->(dbSetOrder(2))  //Filial+Invoice       //(5)  Filial+AC+Cod_i
		If (lRet := SW8->(MsSeek(xFilial("SW8")+M->C024B1COD)))
			M->W8_INVOICE := SW8->W8_INVOICE
		EndIf
		sRestArea(aArea)
        */
        RestArea(aAreaB1)
	End Case

Return lRet


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC024Valid | Autor | Antonio Carlos        | Data | 27/07/22 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao buscar Invoice                                        |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC024VInv( cReadVar )

	Local lRet := .f.
	Local aArea

	Default cReadVar := ReadVar()

	Do Case
	Case cReadVar == "M->C024B1COD"
		aArea := sGetArea(,"SW8")
		SW8->(dbSetOrder(2))  //Filial+Invoice       //(5)  Filial+AC+Cod_i
		If (lRet := SW8->(MsSeek(xFilial("SW8")+M->C024B1COD)))
			M->W8_DESC := SW8->W8_DESC
		EndIf
		sRestArea(aArea)
	End Case

Return lRet





/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC024TICK  | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC024TICK(cTp)
	Local lRet := .f.
	Local cSQL := ""
	Local oSqlHlp := DMS_SqlHelper():New()
	Do Case
		Case cTp == "1" // Original
			cSQL := "SELECT BM_PROORI FROM "+oSqlHlp:NoLock("SBM")+" WHERE "
			cSQL += "BM_FILIAL='"+xFilial("SBM")+"' AND BM_GRUPO='"+SB1->B1_GRUPO+"' AND SBM.D_E_L_E_T_=' '"
			If FM_SQL(cSQL) == "1" // Original
				lRet := .t.
			EndIf
		Case cTp == "2" // Desconto
			cSQL := "SELECT VEN_PERDES FROM "+oSqlHlp:NoLock("VEN")+" WHERE "
			cSQL += "VEN_FILIAL='"+xFilial("VEN")+"' AND VEN_GRUITE='"+SB1->B1_GRUPO+"' AND VEN_CODITE='"+SB1->B1_CODITE+"' AND "
			cSQL += "VEN_DATINI<='"+dtos(dDataBase)+"' AND VEN_DATFIN>='"+dtos(dDataBase)+"' AND VEN_PERDES>0 AND VEN.D_E_L_E_T_=' '"
			If FM_SQL(cSQL) > 0 // % Desconto
				lRet := .t.
			EndIf
		Case cTp == "3" // Promocao
			cSQL := "SELECT VEN_VALPRO FROM "+oSqlHlp:NoLock("VEN")+" WHERE "
			cSQL += "VEN_FILIAL='"+xFilial("VEN")+"' AND VEN_GRUITE='"+SB1->B1_GRUPO+"' AND VEN_CODITE='"+SB1->B1_CODITE+"' AND "
			cSQL += "VEN_DATINI<='"+dtos(dDataBase)+"' AND VEN_DATFIN>='"+dtos(dDataBase)+"' AND VEN_VALPRO>0 AND VEN.D_E_L_E_T_=' '"
			If FM_SQL(cSQL) > 0 // Promocao
				lRet := .t.
			EndIf
		Case cTp == "4" // Ped.Pendente
			If oC024Peca:PedCompraPendente(oFiltroC525) > 0 // Existe Pedido Pendente
				lRet := .t.
			EndIf
		Case cTp == "5" // Retornavel
			If ( SB1->(FieldPos("B1_REMANE")) <> 0 )
				If SB1->B1_REMANE == "1"
			    	lRet := .t.
				EndIf
			EndIf
	End Case
Return(lRet)


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC024Atu   | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC024Atu(lAtuPar)

	Local nCont
	Local aAuxAtu
	Local aEstoque
	Local aDemanda := {}
	
	Default lAtuPar := .f. // Define se atualiza MsMGet de parametros da Rotina ...

	//
	// Ponto de Entrada será executado sempre que a tela principal for atualizada
	//
	If ExistBlock("OC024ATU")
		ExecBlock("OC024ATU",.f.,.f.,{lAtuPar})
	Endif
	//SetKey (VK_F4,{||RetPosPC()})  //Tecla de Atalho p/ Pesquisa Item no Pedido de Compras F4
	
	If lAtuPar
		If Empty(M->C024PARFIL)
			MsgAlert(STR0028,STR0029)
			Return()
		EndIf
		If Empty(M->C024B1COD)
			MsgAlert(STR0030,STR0029)
			Return()
		EndIf
		// Ajusta Filial ... //
		cFilAnt := M->P024PARFIL := M->C024PARFIL
		For nCont := 1 to Len(a024FldFiltro)
			If Left(a024FldFiltro[nCont,2],4) == "C024"
				&("M->P" + SubStr(a024FldFiltro[nCont,2],2)) := &("M->" + a024FldFiltro[nCont,2])
			EndIf
		Next nCont
	EndIf
	//

	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + M->P024B1COD))

	// Atualiza MsMGet de Detalhe ...
	For nCont := 1 to Len(a024FldDetalhe)
		OC024AtVal(a024FldDetalhe[nCont])
	Next nCont
	obC024EncDetalhe:Refresh()

	oC024Peca:SetGrupo(SB1->B1_GRUPO)
//	oC024Peca:SetInvoive(SW8->W8_INVOICE)

	oC024Peca:SetCodigo(SB1->B1_CODITE)

	// Atualiza Listbox de Estoque ...
	aAuxAtu := oC024Peca:EstqSaldo(,.t.,.t.)
	aEstoque := {}
	For nCont := 1 to Len(aAuxAtu)
		If (nPos := aScan(aEstoque,{ |x| x[1] == aAuxAtu[nCont,2] })) == 0
			AADD(aEstoque , { aAuxAtu[nCont,2] , 0 , 0 , aAuxAtu[nCont,4] } )
			nPos := Len(aEstoque)
		EndIf
		aEstoque[nPos,2] += IIf( aAuxAtu[nCont,1] == cFilAnt , aAuxAtu[nCont,3] , 0 )
		aEstoque[nPos,3] += aAuxAtu[nCont,3]
	Next nCont
	// coleta descricao correta dos Almoxarifados
	For nCont := 1 to LEN(aEstoque)
		nPos := aScan(aAuxAtu, {|f| f[1] == cFilAnt .AND. f[2] == aEstoque[nCont, 1] })
		if nPos > 0
			if ! EMPTY(aAuxAtu[nPos, 4])
				aEstoque[nCont, 4] := aAuxAtu[nPos, 4] // sobrepondo a descricao com a da filial logada
			end
		end
	Next

	obC024Estq:nAt := 1
	obC024Estq:SetArray(aEstoque)
	obC024Estq:Refresh()
	//

	// Atualiza Precos ...
	If lExibePreco
		aPreco := oC024Peca:TabelaPreco()
		obC024TPrc:nAt := 1
		obC024TPrc:SetArray(aPreco)
		obC024TPrc:Refresh()
	Endif
	//

	// Atualiza Itens Relacionados...
	aItRel := {}
	aAuxItRel := oC024Peca:ItensRelacionados()
	aEval(aAuxItRel,{ |x| AADD(aItRel,{ AllTrim(x[1]+" "+x[2]) , AllTrim(x[3]) , x[4] , x[5] } ) })
	obC024ItRel:nAt := 1
	obC024ItRel:SetArray(aItRel)
	obC024ItRel:Refresh()
	//

	// Atualiza Itens Substituidos...
	aItSub := {}
	aAuxItSub := oC024Peca:ItensSubstituidos()
	aEval(aAuxItSub,{ |x| AADD(aItSub,{ AllTrim(x[1]+" "+x[2]) , AllTrim(x[3]) , x[7] , x[8] , x[9] } ) })
	obC024ItSub:nAt := 1
	obC024ItSub:SetArray(aItSub)
	obC024ItSub:Refresh()

	// Demandas
	For nCont := 1 to 12
		AADD( aDemanda , { strzero(nCont,2) , UPPER(FG_CMONTH(stod("2000"+strzero(nCont,2)+"01"))) , 0 , 0 } )
	Next nCont
	aAuxAtu := oC024Peca:GetDemanda(.t.,Str(Year(dDataBase),4),"")
	For nCont := 1 to Len(aAuxAtu)
		nPos := aScan(aDemanda,{ |x| val(x[1]) == val(aAuxAtu[nCont,4]) })
		if nPos == 0
			loop
		EndIf
		nTotDem := aAuxAtu[nCont,5]-aAuxAtu[nCont,6]
		aDemanda[nPos,3] += IIf( aAuxAtu[nCont,1] == cFilAnt , nTotDem , 0 ) // filial logada
		aDemanda[nPos,4] += nTotDem // todas as empresas
	Next nCont
	obC024Deman:nAt := 1
	obC024Deman:SetArray(aDemanda)
	obC024Deman:Refresh()
	//

	obC024CmpVen:Refresh()

    
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC024AtVal | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC024AtVal(aAuxField)

	Local xValue

	Private oSqlHlp := DMS_SqlHelper():New()

	Do Case
	Case aAuxField[2] == "C024PARFIL"
		xValue := FWArrFilAtu()[SM0_CODFIL]
	Case aAuxField[2] == "C024MSBLQL"
		xValue := IIf( SB1->B1_MSBLQL == "1" , "STR0031" , "STR0032")
	Case aAuxField[2] == "C024B1COD"
		xValue := SB1->B1_COD

	Case aAuxField[2] == "BM_CODMAR"
		cSQL := "SELECT SBM.BM_CODMAR"
		cSQL +=  " FROM " + oSqlHlp:NoLock("SBM") + " "
		cSQL += " WHERE SBM.BM_FILIAL = '" + xFilial("SBM") + "'"
		cSQL +=   " AND SBM.BM_GRUPO = '" + SB1->B1_GRUPO + "'"
		cSQL +=   " AND SBM.D_E_L_E_T_ = ' '"
		xValue := FM_SQL(cSQL)

	Case aAuxField[2] $ "B5_MARPEC/BZ_MARPEC/B5_CODLIN/BZ_CODLIN/B5_CODFAM/BZ_CODFAM"
		xValue := FM_SQL(OC024ARQPROD(SB1->B1_COD, aAuxField[2]))
		IF aAuxField[2] == "B5_CODLIN"
			cSQL := "SELECT SX5.X5_DESCRI "
			cSQL +=  " FROM " + oSqlHlp:NoLock("SX5") + " "
			cSQL += " WHERE SX5.X5_FILIAL = '" + xFilial("SX5") + "'"
			cSQL +=   " AND SX5.X5_TABELA = '0A'"
			cSQL +=   " AND SX5.X5_CHAVE = '" + xValue + "'"
			cSQL +=   " AND SX5.D_E_L_E_T_ = ' '"
			xValue += " - " + FM_SQL(cSQL)
		ENDIF
		IF aAuxField[2] == "B5_CODFAM"
			cSQL := "SELECT SX5.X5_DESCRI "
			cSQL +=  " FROM " + oSqlHlp:NoLock("SX5") + " "
			cSQL += " WHERE SX5.X5_FILIAL = '" + xFilial("SX5") + "'"
			cSQL +=   " AND SX5.X5_TABELA = '0B'"
			cSQL +=   " AND SX5.X5_CHAVE = '" + xValue + "'"
			cSQL +=   " AND SX5.D_E_L_E_T_ = ' '"
			xValue += " - " + FM_SQL(cSQL)
		ENDIF

	Case aAuxField[2] == "C024GRUDES"
		cSQL := "SELECT VE5.VE5_DESGRU "
		cSQL +=  " FROM " + oSqlHlp:NoLock("SBM") + " "
		cSQL +=  " JOIN " + oSqlHlp:NoLock("VE5") + " "
		cSQL +=    " ON VE5.VE5_FILIAL = '" + xFilial("VE5") + "' AND VE5.VE5_CODMAR = SBM.BM_CODMAR AND VE5.VE5_GRUDST = '"+SB1->B1_GRUDES+"' AND VE5.D_E_L_E_T_ = ' ' "
		cSQL += " WHERE SBM.BM_FILIAL = '" + xFilial("SBM") + "'"
		cSQL +=   " AND SBM.BM_GRUPO = '" + SB1->B1_GRUPO + "'"
		cSQL +=   " AND SBM.D_E_L_E_T_ = ' '"
		xValue := SB1->B1_GRUDES + "-" + FM_SQL(cSQL)

	Case aAuxField[2] == "C024ORIGEM" .OR. aAuxField[2] == "B1_ORIGEM"
		cSQL := "SELECT SX5.X5_DESCRI "
		cSQL +=  " FROM " + oSqlHlp:NoLock("SX5") + " "
		cSQL += " WHERE SX5.X5_FILIAL = '" + xFilial("SX5") + "'"
		cSQL +=   " AND SX5.X5_TABELA = 'S0'"
		cSQL +=   " AND SX5.X5_CHAVE = '" + SB1->B1_ORIGEM + "'"
		cSQL +=   " AND SX5.D_E_L_E_T_ = ' '"
		xValue := SB1->B1_ORIGEM + " - " + FM_SQL(cSQL)

	Case aAuxField[2] == "C024GRTRIB"
		cSQL := "SELECT SX5.X5_DESCRI "
		cSQL +=  " FROM " + oSqlHlp:NoLock("SX5") + " "
		cSQL += " WHERE SX5.X5_FILIAL = '" + xFilial("SX5") + "'"
		cSQL +=   " AND SX5.X5_TABELA = '21'"
		cSQL +=   " AND SX5.X5_CHAVE = '" + SB1->B1_GRTRIB + "'"
		cSQL +=   " AND SX5.D_E_L_E_T_ = ' '"
		xValue := SB1->B1_GRTRIB + "-" + FM_SQL(cSQL)

	Case Left(aAuxField[2],3) == "B1_"
		If GetSX3Cache(aAuxField[2],"X3_CONTEXT") == "V"
			xValue := criavar(AllTrim(aAuxField[2]))
		Else		 
			xValue := &("SB1->" + AllTrim(aAuxField[2]))
		Endif
	EndCase

	If xValue <> NIL
		&("M->"+aAuxField[2]) := xValue
	EndIf

Return xValue

/*/{Protheus.doc} OC024ARQPROD
Monta query dependendo da tabela de complemento de produto
@author Rubens
@since 16/08/2017
@version undefined
@param cCodProd, characters, descricao
@param cCampo, characters, descricao
@type function
/*/
Static Function OC024ARQPROD(cCodProd, cCampo)

	Local cSQL

	Do Case
	Case Left(cCampo,2) == "B5"
		cSQL := "SELECT SB5." + cCampo
		cSQL +=  " FROM " + oSqlHlp:NoLock("SB5") + " "
		cSQL += " WHERE SB5.B5_FILIAL = '" + xFilial("SB5") + "'"
		cSQL +=   " AND SB5.B5_COD = '" + cCodProd + "'"
		cSQL +=   " AND SB5.D_E_L_E_T_ = ' '"
	Case Left(cCampo,2) == "BZ"
		cSQL := "SELECT SBZ." + cCampo
		cSQL +=  " FROM " + oSqlHlp:NoLock("SBZ") + " "
		cSQL += " WHERE SBZ.BZ_FILIAL = '" + xFilial("SBZ") + "'"
		cSQL +=   " AND SBZ.BZ_COD = '" + cCodProd + "'"
		cSQL +=   " AND SBZ.D_E_L_E_T_ = ' '"
	End

Return cSQL

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao  |OC024AddField | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC024AddField(aCampos, aParField, cNomeFunc)

	Local nCont
	Local aAuxField
    Local nPoscpo, nPoscpo1, nPoscpo2 := 0
	
	aParField := {}
	
	Default cNomeFunc := "OC024Field"

	For nCont := 1 to Len(aCampos)

		If aCampos[nCont,3]
			SX3->(dbSetOrder(2))
			If SX3->(dbSeek(aCampos[nCont,1]))
				AADD( aParField , {;
					X3Titulo(),; // 01 - Título
					IIf( !Empty(aCampos[nCont,2]) , AllTrim(aCampos[nCont,2]) , AllTrim(SX3->X3_CAMPO) ),; // 02 - Campo
					SX3->X3_TIPO,; // 03 - Tipo
					SX3->X3_TAMANHO,; // 04 - Tamanho
					SX3->X3_DECIMAL,; // 05 - Decimal
					SX3->X3_PICTURE,; // 06 - Picture
					"",; // 07 - Valid
					.f.,; // 08 - Obrigat
					1 ,; // 09 - Nivel
					"",; // 10 - Inicializador Padrão
					"",; //SX3->X3_F3,; // 11 - F3
					"",; // 12 - When
					.t.,; // 13 - Visual
					.f.,; // 14 - Chave
					X3CBox(),; // 15 - Box - Opção do combo
					,; // 16 - Folder (vazio por causa do parâmetro MV_ENCHOLD)
					.t.,; // 17 - Não Alterável
					"",; // 18 - PictVar
					"N"}) // 19 - Gatilho
			EndIf
		Else
			aAuxField := &(cNomeFunc + "('" + aCampos[nCont,1] + "')" )

			AADD( aParField , {;
				aAuxField[MVC_STRUCT_TITULO],; // 01 - Título
				AllTrim(aAuxField[MVC_STRUCT_ID]),; // 02 - Campo
				aAuxField[MVC_STRUCT_TIPO],; // 03 - Tipo
			    aAuxField[MVC_STRUCT_TAM],; // 04 - Tamanho
				aAuxField[MVC_STRUCT_DEC],; // 05 - Decimal
				aAuxField[MVC_STRUCT_PICTURE],; // 06 - Picture
				"",; // 07 - Valid
				aAuxField[MVC_STRUCT_OBRIGAT],; // 08 - Obrigat
				1,; // 09 - Nivel
				"",; // 10 - Inicializador Padrão
				aAuxField[MVC_STRUCT_F3],; // 11 - F3
				"",; // 12 - When
				!aAuxField[MVC_STRUCT_ALTER],; // 13 - Visual
				.f.,; // 14 - Chave
				aAuxField[MVC_STRUCT_CBOX],; // 15 - Box - Opção do combo
				,; // 16 - Folder (vazio por causa do parâmetro MV_ENCHOLD)
				!aAuxField[MVC_STRUCT_ALTER],; // 17 - Não Alterável
				"",; // 18 - PictVar
				"N"}) // 19 - Gatilho
		EndIf
	Next nCont
	
	nPoscpo := aScan(aParField,{ |x| x[1] = "Origem" })
	IF nPoscpo <> 0
		aParField[nPoscpo][04] := 20 // 04 - Tamanho  
	ENDIF
	
	nPoscpo1 := aScan(aParField,{ |x| x[1] = "Linha Peça" })
	IF nPoscpo1 <> 0
		aParField[nPoscpo1][04] := 20 // 04 - Tamanho  
	ENDIF

	nPoscpo2 := aScan(aParField,{ |x| x[1] = "Família Peça" })
	IF nPoscpo2 <> 0
		aParField[nPoscpo2][04] := 20 // 04 - Tamanho  
	ENDIF	

Return aParField

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC024Field | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC024Field(cField)

	Local aRetorno := Array(16)

	aRetorno[MVC_STRUCT_ID       ] := cField
	aRetorno[MVC_STRUCT_DEC      ] := 0
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
	aRetorno[MVC_STRUCT_VIRTUAL  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .F.

	Do Case
	Case cField == "C024PARFIL"
		aRetorno[MVC_STRUCT_TITULO   ] := STR0005
		aRetorno[MVC_STRUCT_DESCRICAO] := STR0005
		aRetorno[MVC_STRUCT_TIPO     ] := "C"
		aRetorno[MVC_STRUCT_TAM      ] := FWSizeFilial()
		aRetorno[MVC_STRUCT_CBOX     ] := OC024RetFil()
		aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
		aRetorno[MVC_STRUCT_ALTER    ] := .T.

	Case cField == "C024MSBLQL"
		aRetorno[MVC_STRUCT_TITULO   ] := STR0033
		aRetorno[MVC_STRUCT_DESCRICAO] := STR0033
		aRetorno[MVC_STRUCT_TIPO     ] := "C"
		aRetorno[MVC_STRUCT_TAM      ] := 9

	Case cField == "C024ORIGEM"
		aRetorno[MVC_STRUCT_TITULO   ] := STR0034
		aRetorno[MVC_STRUCT_DESCRICAO] := STR0034
		aRetorno[MVC_STRUCT_TIPO     ] := "C"
		aRetorno[MVC_STRUCT_TAM      ] := 30

	Case cField == "C024GRTRIB"
		aRetorno[MVC_STRUCT_TITULO   ] := STR0035
		aRetorno[MVC_STRUCT_DESCRICAO] := STR0035
		aRetorno[MVC_STRUCT_TIPO     ] := "C"
		aRetorno[MVC_STRUCT_TAM      ] := 20

	Case cField == "C024GRUDES"
		aRetorno[MVC_STRUCT_TITULO   ] := STR0036
		aRetorno[MVC_STRUCT_DESCRICAO] := STR0036
		aRetorno[MVC_STRUCT_TIPO     ] := "C"
		aRetorno[MVC_STRUCT_TAM      ] := 20

	Case cField == "B1_DTREFP1"
		aRetorno[MVC_STRUCT_TITULO   ] := STR0037
		aRetorno[MVC_STRUCT_DESCRICAO] := STR0037

	EndCase

Return aRetorno

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC024Exec  | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC024Exec(cAuxRotina)

	Local aParAutoCab := {}
	Local aArea := GetArea()

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + M->P024B1COD))

	nOpc := 2
	Do Case

		Case cAuxRotina == "OFIOC521"
			AADD( aParAutoCab , { "C521PARFIL" , M->P024PARFIL  } )
			AADD( aParAutoCab , { "C521EMPR2"  , FWFilialName() } )
			OFIOC521(.t.,aParAutoCab)

		Case cAuxRotina == "OFIOC150"
			OFIOC150(SB1->B1_GRUPO,SB1->B1_CODITE)

		Case cAuxRotina == "M_LCPCJD"
			U_M_LCPCJD(SB1->B1_COD)

		Otherwise // OFIOC523/524/524/...
			&(cAuxRotina + "(.t.)")

	EndCase

	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + M->P024B1COD))

	// Atualiza os controles novamente para garantir que as outras telas nao alteraram variaveis privates ...
	OC024Atu()
	//

	RestArea(aArea)

	Return

/*
================================================================================
################################################################################
##+----------+-------------+-------+-----------------------+------+----------+##
##|Funcao    |OC024CalcSize| Autor | Andre Luis Almeida    | Data | 14/08/15 |##
##+----------+-------------+-------+-----------------------+------+----------+##
##|Descricao | Formatacao da tela.                                           |##
##+----------+---------------------------------------------------------------+##
##|Uso       | Oficina                                                       |##
##+----------+---------------------------------------------------------------+##
################################################################################
================================================================================
*/
Static Function OC024CalcSize()

	Local aDialSize := FWGetDialogSize()

	oSizePrinc := FwDefSize():New(.t.)
	oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
	If (aDialSize[3] - 300) > 400
		oSizePrinc:AddObject("SUP" , 100 , 150 , .T. , .F. )
		oSizePrinc:AddObject("BOT" , 100 , 100 , .T. , .T. )
	Else
		oSizePrinc:AddObject("SUP" , 100 , 100 , .T. , .T. )
		oSizePrinc:AddObject("BOT" , 100 , 150 , .T. , .F. )
	EndIf
	//oSizePrinc:lLateral := .t.	// Calcula em colunas
	oSizePrinc:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizePrinc:Process()	// Calcula Coordenadas

	oSizeSup := FWDefSize():New(.f.)
	oSizeSup:aWorkArea := oSizePrinc:GetNextCallArea("SUP")
	oSizeSup:aMargins := { 2 , 2 , 2 , 2 }
	oSizeSup:AddObject("PARTE_FILTRO",100,100,.f.,.t.)
	oSizeSup:AddObject("DETALHE"     ,100,100,.t.,.t.)
	oSizeSup:lLateral := .t.	// Calcula em colunas
	oSizeSup:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizeSup:Process()

	oSizeFiltro := FWDefSize():New(.f.)
	oSizeFiltro:aWorkArea := oSizeSup:GetNextCallArea("PARTE_FILTRO")
	oSizeFiltro:aMargins := { 0 , 0 , 0 , 0 }
	oSizeFiltro:AddObject("FILTRO"       ,100,100,.t.,.t.)
	oSizeFiltro:AddObject("BTN_ATUALIZA" ,100,011,.t.,.f.)
	oSizeFiltro:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizeFiltro:Process()

	oSizeDet := FWDefSize():New(.f.)
	oSizeDet:aWorkArea := oSizePrinc:GetNextCallArea("BOT")
	oSizeDet:aMargins := { 0 , 0 , 0 , 0 }
	oSizeDet:AddObject("L1_L1",100,100,.t.,.t.)
	oSizeDet:AddObject("L1_L2",100,100,.t.,.t.)
	oSizeDet:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizeDet:Process()

	oSizeDet1 := FWDefSize():New(.f.)
	oSizeDet1:aWorkArea := oSizeDet:GetNextCallArea("L1_L1")
	oSizeDet1:aMargins := { 2 , 2 , 2 , 2 }
	oSizeDet1:AddObject("ESTOQUE"       ,010,010,.t.,.t.)
	oSizeDet1:AddObject("DEMANDA"       ,010,010,.t.,.t.)
	oSizeDet1:AddObject("BOTOES"        ,045,010,.f.,.t.)
	oSizeDet1:AddObject("TIKS"     ,055,010,.f.,.t.)
	oSizeDet1:AddObject("COMPRA_VENDA",140,010,.f.,.t.)
	oSizeDet1:lLateral := .t.	// Calcula em colunas
	oSizeDet1:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizeDet1:Process()

	oSizeDet2 := FWDefSize():New(.f.)
	oSizeDet2:aWorkArea := oSizeDet:GetNextCallArea("L1_L2")
	oSizeDet2:aMargins := { 2 , 2 , 2 , 2 }
	oSizeDet2:AddObject("TAB_PRECO" ,033,010,.t.,.t.)
	oSizeDet2:AddObject("ITENS_REL" ,033,010,.t.,.t.)
	oSizeDet2:AddObject("ITENS_SUB" ,033,010,.t.,.t.)
	oSizeDet2:lLateral := .t.	// Calcula em colunas
	oSizeDet2:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizeDet2:Process()

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |OC024RetFil | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC024RetFil(lEmpresa)
	Local aFilAtu    := FWArrFilAtu()
	Local aAuxFilial := FWAllFilial( aFilAtu[SM0_EMPRESA] , aFilAtu[SM0_UNIDNEG] , aFilAtu[SM0_GRPEMP] , .f. )
	//Local aRetorno := {}
	Local cRetorno := ""

	Default lEmpresa := .f.

	aEval(aAuxFilial, { |x| cRetorno += (x + "=" + AllTrim(FWFilialName(, x)) + ";") })
	//aEval(aAuxFilial,{ |x| AADD(aRetorno, (x + "=" + AllTrim(FWFilialName(,x))) ) })

	If lEmpresa .And. Len(aAuxFilial) >= 2
		cRetorno += "TODAS" + ";" // TODAS
	EndIf

	cRetorno := Left(cRetorno, Len(cRetorno) - 1)

	//Return aRetorno
Return cRetorno

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | MenuDef    | Autor | Takahashi             | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Definicao de Menu                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MenuDef()
Local aRecebe
Local aRotina   := {}
//LOCAL cConsulta := SUPERGETMV("MV_VERIORC",.F., "1")

//If FM_PILHA("OFIXC001") .or. cConsulta <> "3" //Alltrim(GetNewPar("MV_VERIORC","1")) <> "3"
	aRotina := {;
		       { STR0002 , "PesqBrw"     , 0 , 1},; // Pesqui"1"sar
		       { STR0003 , "OC024Visual" , 0 , 2} } // Visualizar
//Else
	//aRotina := {;
	//	{ STR0002 , "PesqBrw"     , 0 , 1},; // Pesquisar
	//	{ STR0003 , "OC024Visual" , 0 , 2},; // Visualizar
	//	{ STR0038 , "OFIXC009(1)" , 0 , 1},; // Pesquisa por Aplicacao
	//	{ STR0039 , "OA620"		  , 0 , 2} }   // Visualizar Aplicacao
//	aRotina := {;
//		{ STR0002 , "PesqBrw"     , 0 , 1},; // Pesquisar
//		{ STR0003 , "OC024Visual" , 0 , 2},; // Visualizar
//		{ STR0039 , "OA620"		  , 0 , 2} }   // Visualizar Aplicacao
//EndIf
If ExistBlock("OC024ART")
	aRecebe := ExecBlock("OC024ART",.f.,.f.,{aRotina} )
	If Valtype(aRecebe) == "A"
		aRotina := aClone(aRecebe)
	Endif
Endif

Return aRotina


/*/{Protheus.doc} ZPECF024
@author A.Carlos
@since 18/08/2022
@version 1.0
    @return Nil, Retorno da posição do item no Pedido de Compras
    @example
/*/
Static Function RetPosPC()
Local nLin       := 0
Local nCol       := 0
Local _cItem     := Space(23)
Local aParamBox  := {}
Local aRetPer    := {}
Private _cPC_NUM   := SC7->C7_NUM

   aAdd(aParamBox,{ 1, "Item ", _cItem, "@!", "", "SC7A","", 60,.T.})

   If !ParamBox(aParamBox, " " + SC7->C7_NUM, @aRetPer, , , , , , , , ,.T.)
      Return Nil
   EndIf

   SC7->(dbGoTop())    
    
    While SC7->(!EOF())

      nLin++

     IF Alltrim(aRetPer[1]) = Alltrim(SC7->C7_PRODUTO)

         nCol := 02
          
         Return {nLin, nCol}    // Retorna a primeira ocorrência, se comentado retornará a última ocorrência.
          
     EndIF

     SC7->(DbSkip())

   End

// Se não encontrou retorna {0, 0}
Return {nLin, nCol}


Return()
