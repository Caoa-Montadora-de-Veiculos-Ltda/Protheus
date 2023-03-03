#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#include "TOTVS.ch"


/*===================================================================================
Programa.:              ZFATR006
Autor....:              CAOA - Valter Carvalho
Data.....:              26/10/2020
Descricao / Objetivo:   Relatorio de venda de produtos imobilizados
Solicitante:            Evandro Mariano
===================================================================================== */
User Function ZFATR006()
	Local aPergs    := {}
	Local cCliCod   := Space(TamSx3("A1_COD")[1])
	Local cCliLoj   := Space(TamSx3("A1_LOJA")[1])
	Local cDtI      := Space(TamSx3("D2_EMISSAO")[1]) := Date()
	Local cDtF      := Space(TamSx3("D2_EMISSAO")[1]) := Date()

	Private bLjCli    := {|| Iif(Empty(MV_PAR03) = .F., MV_PAR04 := SA1->A1_LOJA, "")}
	Private cQr     := ""
	Private oRep    := Nil
	Private aRt     := {}

	Aadd( aPergs ,{1, "Data De          ", cDtI      , " ", '.T.',   "" ,        ".T.", 80, .T.})
	Aadd( aPergs ,{1, "Data Até         ", cDtF      , " ", '.T.',   "" ,        ".T.", 80, .T.})
	Aadd( aPergs ,{1, "Cod cliente      ", cCliCod   ,"@!", '.T.', "SA1",        ".T.", 50, .F.})
	Aadd( aPergs ,{1, "Loja cliente     ", ccliLoj   ,"@!", '.T.',    "", "Eval(bLjCli)", 30, .F.})
	Aadd(aPergs  ,{3, "Destino", 1 , {"Exporta Excel", "Impressão"}, 90, "", .F.})

	If ParamBox(aPergs, "Parametros: Vendas Ativo Imobilizadoz Fat", aRt, , , , , , , , ,.T.)

		If MV_PAR02 < MV_PAR01
			ApMsgInfo("Data inicial não pode ser maior que a data final.", "ZFATR006")
		EndIf

		FWMsgRun(, {|| zGeraRel() },"", "Obtendo dados, aguarde..." )
		
	EndIf

Return

/*===================================================================================
Programa.:              zGeraRel
Autor....:              CAOA - Valter Carvalho
Data.....:              26/10/2020
Descricao / Objetivo:   Logica da greracao do relatorio
Solicitante:            Evandro Mariano
===================================================================================== */
Static Function zGeraRel()
	Local cmd       := ""

	cQr    := GetNextAlias()

	cmd += CRLF +  " SELECT "
	cmd += CRLF +  "   D2_DOC       "
	cmd += CRLF +  " , D2_SERIE     "
	cmd += CRLF +  " , D2_EMISSAO   "
	cmd += CRLF +  " , C6_CHASSI    "
	cmd += CRLF +  " , D2_COD       "
	cmd += CRLF +  " , B1_DESC      "
	cmd += CRLF +  " , D2_QUANT     "
	cmd += CRLF +  " , D2_TOTAL     "
	cmd += CRLF +  " , D2_CLIENTE || '-' || D2_LOJA as D2_CLIENTE "
	cmd += CRLF +  " , A1_NOME      "
	cmd += CRLF +  " , D2_TES       "
	cmd += CRLF +  " , F4_FINALID   "
	cmd += CRLF +  " , FT_CHVNFE   "
	cmd += CRLF +  " FROM " + RetSqlName("SD2") + " SD2 "

	cmd += CRLF +  " INNER JOIN " + RetSqlName("SC6") + " SC6 ON SD2.D2_FILIAL = SC6.C6_FILIAL AND SD2.D2_PEDIDO = SC6.C6_NUM AND SD2.D2_ITEMPV = SC6.C6_ITEM AND SC6.D_E_L_E_T_ = ' '

	cmd += CRLF +  " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SD2.D2_COD = SB1.B1_COD AND SB1.D_E_L_E_T_ = ' '

	cmd += CRLF +  " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ' '

	cmd += CRLF +  " INNER JOIN " + RetSqlName("SF4") + " SF4 ON SD2.D2_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ = ' '
	
	cmd += CRLF +  " INNER JOIN " + RetSqlName("SFT") + " SFT ON SD2.D2_DOC = SFT.FT_NFISCAL AND SD2.D2_SERIE = SFT.FT_SERIE AND SD2.D2_COD = SFT.FT_PRODUTO AND SFT.D_E_L_E_T_ = ' '

	cmd += CRLF +  " WHERE "
	cmd += CRLF +  "     SD2.D_E_L_E_T_ = ' ' "
	cmd += CRLF +  " AND SD2.D2_TES     IN ('583','703') "
	cmd += CRLF +  " AND SD2.D2_EMISSAO >= '" + Dtos(MV_PAR01) + "'
	cmd += CRLF +  " AND SD2.D2_EMISSAO <= '" + Dtos(MV_PAR02) + "'

	If Empty(MV_PAR03) = .T.
		cmd += CRLF +  " AND SD2.D2_CLIENTE <>  ' ' "
	Else
		cmd += CRLF +  " AND SD2.D2_CLIENTE = '" + MV_PAR03 + "' "
		cmd += CRLF +  " AND SD2.D2_LOJA    = '" + MV_PAR04 + "' "
	EndIf

	TcQuery cmd new alias (cQr)
	If Empty((cQr)->D2_DOC) = .T.
		ApMsgInfo("Nenhum registro selecionado com esses dados", "ZFATR006")
	Else

		If MV_PAR05 = 1
			zExpXlsx()
		Else
			oRep := RptDef()
			oRep:PrintDialog()
		EndIf

	EndIf

	(cQr)->(DbCloseArea())

Return


/*===================================================================================
Programa.:              zExpXlsx
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Monta os array para exportação para Excel
===================================================================================== */
Static Function zExpXlsx()
    Local i       := 1
    Local aTitles := {}
    Local acols   := {}
    Local aIt     := {}
    Local aStru   := (cQr)->(DBStruct())

    Aeval(aStru, {|aCp| Aadd(aTitles, aCp[1] )})

    (cQr)->(DbGoTop())

	While (cQr)->(Eof()) = .F.
        aIt := {}
		For i:=1 to Len(aStru)

			If aStru[i,2] == "D"
                Aadd(aIt,  Iif(Empty((cQr)->&(aStru[i,1])) = .T., "",  Dtoc((cQr)->&(aStru[i,1])) ) )
			Else
                Aadd(aIt, (cQr)->&(aStru[i,1])  )
			Endif
		Next

        Aadd(aCols, aIt)
        (cQr)->(DbSkip())
	Enddo

    u_ZGENEXCEL(aTitles, aCols, "Planilha", "Vendas Ativo Imobilizado")
Return


/*===================================================================================
Programa.:              RptDef
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Prepara o relatorio
===================================================================================== */
Static Function RptDef()
    Local cAlign    := ""
    Local i         := 1
	Local oSection 	:= Nil
    Local cTitulo   := "Vendas Ativo Imobilizado" 
    Local cDescricao:= "Relatório de Vendas Ativo Imobilizado"
    Local aStru   := (cQr)->(DBStruct())

	oRep := TReport():New(cTitulo, cDescricao , "", {|oRep| ReportPrint() }, cDescricao)
	oRep:nFontbody := 8
    oRep:oPage:setPaperSize(10)
	oRep:SetLandscape()
	oRep:SetTotalInLine(.F.)
    oRep:SetDevice(2) // 2 impressora
    oRep:SetEnvironment( 2 ) // 2 client
    oRep:setPreview(.T.)
	oRep:HideParamPage() 
	oRep:SetTotalInLine(.F.)
    //                       oParent,   cTitle, uTable,aOrder, lLoadCells,lLoadOrder, uTotalText, lTotalInLine, lHeaderPage, lHeaderBreak, lPageBreak, lLineBreak, nLeftMargin, lLineStyle, nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage
    oSection:= TRSection():New( oRep, "CABECA",  {cQr},    {},        .F.,       .T.,         "",          .F.,         .F.,          .T.,        .T.,           ,           0,        .F.,         0,      .T.)

    cAlign := Iif(aStru[i,2] == "N", "RIGHT", "LEFT")
      //TRCell():New( <oParent>,       <cName> , <cAlias> , <cTitle> , <cPicture> , <nSize> , <lPixel> , <bBlock> , <cAlign> , <lLineBreak> , <cHeaderAlign> , <lCellBreak> , <nColSpace> , <lAutoSize> , <nClrBack> , <nClrFore> , <lBold> ) 
    TRCell():New(  oSection,       "D2_DOC",       cQr,       "NF",       "@!",        35,        .F.,    {||} ,    "LEFT",           .F.,          "LEFT",              ,            1,          .F. )
    TRCell():New(  oSection,   "D2_EMISSAO",       cQr,  "Emissao",         "",        10,        .F.,    {||} ,    "LEFT",           .F.,          "LEFT",              ,            1,          .F. )
    TRCell():New(  oSection,    "C6_CHASSI",       cQr,   "Chassi",         "",        50,        .F.,    {||} ,    "LEFT",           .F.,          "LEFT",              ,            1,          .F. )
    TRCell():New(  oSection,       "D2_COD",       cQr,      "Cod",         "",        50,        .F.,    {||} ,    "LEFT",           .F.,          "LEFT",              ,            1,          .F. )
    TRCell():New(  oSection,      "B1_DESC",       cQr,"Descricao",         "",       100,        .F.,    {||} ,    "LEFT",           .F.,          "LEFT",              ,            1,          .F. )
    TRCell():New(  oSection,     "D2_QUANT",       cQr,       "Qt",         "",        10,        .F.,    {||} ,   "RIGHT",           .F.,          "RIGHT",              ,            1,          .F. )
    TRCell():New(  oSection,     "D2_TOTAL",       cQr,    "Total",         "",        40,        .F.,    {||} ,   "RIGHT",           .F.,          "RIGHT",              ,            1,          .F. )
    TRCell():New(  oSection,   "D2_CLIENTE",       cQr,  "Cod Cli",         "",        35,        .F.,    {||} ,    "LEFT",           .F.,          "LEFT",              ,            1,          .F. )
    TRCell():New(  oSection,      "A1_NOME",       cQr, "Nome Cliente",     "",        90,        .F.,    {||} ,    "LEFT",           .F.,          "LEFT",              ,            1,          .F. )
    TRCell():New(  oSection,       "D2_TES",       cQr,      "TES",         "",        10,        .F.,    {||} ,    "LEFT",           .F.,          "LEFT",              ,            1,          .F. )
    TRCell():New(  oSection,   "F4_FINALID",       cQr, "Finalid.",         "",        90,        .F.,    {||} ,    "LEFT",           .F.,          "LEFT",              ,            1,          .F. )
	TRCell():New(  oSection,   "FT_CHVNFE",        cQr, "Chave NFE.",       "",        44,        .F.,    {||} ,    "LEFT",           .F.,          "LEFT",              ,            1,          .F. )

    TRFunction():New(oSection:Cell("D2_QUANT"), NIL, "SUM", /* oBreak */,"",           "@E 9999",,.T., .F., .F., oSection,,)
    TRFunction():New(oSection:Cell("D2_TOTAL"), NIL, "SUM", /* oBreak */,"", "@E 999,999,999.99",,.T., .F., .F., oSection,,)

Return oRep   


/*===================================================================================
Programa.:              RptDef
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Monta o relatorio
===================================================================================== */
Static Function ReportPrint(aItens)
    Local oSection  := oRep:Section(1)

    oSection:Init()

    oRep:SetMeter( (cQr)->( LastRec() ) )

    (cQr)->(DbGoTop())

	While (cQr)->(Eof()) = .F.

        oSection:Cell("D2_DOC"):SetValue( Alltrim((cQr)->D2_SERIE) + "/" + (cQr)->D2_DOC )
        oSection:Cell("D2_EMISSAO"):SetValue(  Dtoc(Stod((cQr)->D2_EMISSAO )))
        oSection:Cell("C6_CHASSI"):SetValue((cQr)->C6_CHASSI)
        oSection:Cell("D2_COD"):SetValue((cQr)->D2_COD )
        oSection:Cell("B1_DESC"):SetValue((cQr)->B1_DESC )     
        oSection:Cell("D2_QUANT"):SetValue( Transform((cQr)->D2_QUANT, "@E99") )
        oSection:Cell("D2_TOTAL"):SetValue(  Transform((cQr)->D2_TOTAL, "@E 999,999.99") )
        oSection:Cell("D2_CLIENTE"):SetValue((cQr)->D2_CLIENTE )
        oSection:Cell("A1_NOME"):SetValue((cQr)->A1_NOME )
        oSection:Cell("D2_TES"):SetValue((cQr)->D2_TES )
        oSection:Cell("F4_FINALID"):SetValue((cQr)->F4_FINALID )
		oSection:Cell("FT_CHVNFE"):SetValue((cQr)->FT_CHVNFE )

        oSection:Printline()
        (cQr)->(DbSkip())
        oRep:IncMeter()
	EndDo

	oRep:SkipLine()
    oRep:ThinLine()
    oSection:Finish()

    oRep:EndPage()
    
Return .T.


