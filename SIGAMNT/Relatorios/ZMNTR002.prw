#include "Protheus.CH"
#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "REPORT.CH"

/*===================================================================================
Programa.:              ZMNTR002
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Relatorio de minimo Max montagem, 19 - Manuten��o de Ativo\MNT103 - Relat�rio Follow Up Sintetico
Solicitante:            Julia Alcantara
===================================================================================== */
User Function ZMNTR002() // u_ZMNTR002()   e  GRAEXCEL
    Local aPergs   := {}
    Local cTipoI := Space(TamSx3("B1_TIPO")[1])
    Local cTipoF := PadR("", TamSx3("B1_TIPO")[1], "Z")
    Local cGrpI  := Space(TamSx3("B1_GRUPO")[1])
    Local cGrpF  := PadR("", TamSx3("B1_GRUPO")[1], "Z")
    Local cLPadI := Space(TamSx3("B1_LOCPAD")[1])
    Local cLPadF := PadR("", TamSx3("B1_LOCPAD")[1], "Z")
    Local cCod   := Space(TamSx3("B1_COD")[1])
    Private oRep := Nil
    Private oTable:= Nil
    Private cTb  := Nil
    Private aRt  := {}

    oTable  := zCriaTb()
    cTb  := oTable:oStruct:cAlias

    //cCod   := "MAN00022"

    Aadd(aPergs, {1, GetSx3Cache("B1_TIPO", "X3_TITULO") + " De: ",  cTipoI, "@!", "", "02", "", 50, .F.	})
    Aadd(aPergs, {1, GetSx3Cache("B1_TIPO", "X3_TITULO") + " Ate:",  cTipoF, "@!", "", "02","", 50, .F.	})
    Aadd(aPergs, {1, GetSx3Cache("B1_GRUPO", "X3_TITULO") + " De: ", cGrpI, "@!", "", "SBM", "", 50, .F.	})
    Aadd(aPergs, {1, GetSx3Cache("B1_GRUPO", "X3_TITULO") + " Ate:", cGrpF, "@!", "", "SBM", "", 50, .F.	})
    Aadd(aPergs, {1, GetSx3Cache("B1_LOCPAD", "X3_TITULO") + " De: ", cLPadI, "@!", "", "NNR", "", 50, .F.	})
    Aadd(aPergs, {1, GetSx3Cache("B1_LOCPAD", "X3_TITULO") + " Ate:", cLPadF, "@!", "", "NNR", "", 50, .F.	})
    Aadd(aPergs, {1, "Cod produto cont�m:", cCod, "@!", "","SB1","", 100, .F.	})
    Aadd(aPergs, {5,"Somente itens com Saldo menor Est.m�nimo? ", .F. , 150, "" , .F.}) //8

    Aadd(aPergs,{3,"Destino",1,{"Exporta Excel","Impress�o"},90, "", .F.})

//    If ParamBox(aPergs, "Relat�rio sint�tico de estoque/compras (Min/M�x)", aRt, {|| .T.},,,,,,, .T., .T.)
    If ParamBox(aPergs, "Relat�rio sint�tico de estoque/compras (Min/M�x)", aRt) = .T.
        zRelfup()
    EndIf

    oTable:Delete()

Return

Static Function zRelfup()
    Local nQtIt := 0

    // Obter os itens da consulta
    FWMsgRun(, {|| zGetQtB1() },"", "Obtendo os itens e saldos..." )
    
    // testar se tem itens
    (cTb)->(DbEval({|| nQtIt+= 1 }, {|| .T.}))
    If nQtIt = 0
        ApMsgInfo("Nenhum produto com esses parametros", "ZMNTR002")
        Return
    EndIf

    // Obter os dados custo solicitacao e pedido
    FWMsgRun(, {|| zListaDados() },"", "Obtendo dados solicita��o e pedido..." )

    //remove os espacos dos codigos    
    FWMsgRun(, {|| zAjCodProd() },"", "Formatando c�digos..." )
  
    If aRt[9] = 1
        zExpXlsx()
    Else
        oRep := RptDef()
        oRep:PrintDialog()
    Endif
Return

/*===================================================================================
Programa.:              zCriaTb
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   remove os espacos em branco dos codigos do relatorio
===================================================================================== */
Static function zAjCodProd()

   (cTb)->(DbGoTop())

    While (cTb)->(Eof()) = .F.

        RecLock(cTb,  .F.)
        (cTb)->B1_COD := Alltrim((cTb)->B1_COD)

        (cTb)->(DbSkip())
    EndDo
   (cTb)->(DbGoTop())
Return



/*===================================================================================
Programa.:              zCriaTb
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Cria a tabela temporaria do relatorio
===================================================================================== */
Static Function zCriaTb()
    Local aFields := {}
    Local oTempTb := Nil

    aadd(aFields,{"B1_COD",  TamSx3("B1_COD")[3],   TamSx3("B1_COD")[1], TamSx3("B1_COD")[2]  })
    aadd(aFields,{"B1_DESC", TamSx3("B1_DESC")[3],                  400,                   0  })
    aadd(aFields,{"B1_EMIN", TamSx3("B1_EMIN")[3], TamSx3("B1_EMIN")[1], TamSx3("B1_EMIN")[2] })
    aadd(aFields,{"B1_EMAX", TamSx3("B1_EMAX")[3], TamSx3("B1_EMAX")[1], TamSx3("B1_EMAX")[2] })
    aadd(aFields,{"B2_QATU", TamSx3("B2_QATU")[3], TamSx3("B2_QATU")[1], TamSx3("B2_QATU")[2] })
    aadd(aFields,{"B2_CM1",  TamSx3("B2_CM1")[3],  TamSx3("B2_CM1")[1],  TamSx3("B2_CM1")[2]  })
    aadd(aFields,{"CM_COM",  TamSx3("C7_PRECO")[3],TamSx3("C7_PRECO")[1],TamSx3("C7_PRECO")[2]})
    aadd(aFields,{"B2_CMT", TamSx3("B2_CM1")[3],   TamSx3("B2_CM1")[1], TamSx3("B2_CM1")[2] })
    aadd(aFields,{"QT_SOL", TamSx3("C1_QUANT")[3], TamSx3("C1_QUANT")[1], TamSx3("C1_QUANT")[2] })
    aadd(aFields,{"QT_PED", TamSx3("C7_QUANT")[3], TamSx3("C7_QUANT")[1], TamSx3("C7_QUANT")[2] })
    aadd(aFields,{"QT_ENT", TamSx3("C7_QUANT")[3], TamSx3("C7_QUANT")[1], TamSx3("C7_QUANT")[2] })
    aadd(aFields,{"ORI"   , "C", 3, 0 })

    oTempTb := FWTemporaryTable():New( GetNextAlias() )
    oTempTb:SetFields( aFields )
    oTempTb:AddIndex("indice1", {"B1_COD"} )
    oTempTb:AddIndex("indice2", {"B1_DESC"} )

    oTempTb:Create()

Return oTempTb


/*===================================================================================
Programa.:              zListaDados
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Obtem os dados de solicitacao e pedido
===================================================================================== */
Static Function zListaDados(aItens)
    Local aAux  := {}

    (cTb)->(DbGoTop())

    While (cTb)->(Eof()) = .F.

        aAux := zGetCusto((cTb)->B1_COD)
        (cTb)->B2_CM1 := aAux[1]  //custo
        (cTb)->ORI    := aAux[2]  //origem custo

        //Obter qt Solicitacoes
        (cTb)->QT_SOL := zGetQtC1((cTb)->B1_COD)

        // Obter qt pedido a fornecedor
        aAux := zGetSc7((cTb)->B1_COD)
        (cTb)->QT_PED := aAux[1]  //pedido
        (cTb)->QT_ENT := aAux[2]  //enregue

        // calcula o custo total, custo x saldo
        (cTb)->B2_CMT := (cTb)->B2_QATU * (cTb)->B2_CM1

        (cTb)->(DbSkip())
    EndDo
Return

/*===================================================================================
Programa.:              zGetSc7
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Obtem a listagem dos produtos
===================================================================================== */
Static Function zGetSc7(cProd)
    Local aRes  := {0, ""}
    Local cAlias:= GetNextAlias()
    Local cmd   := ""

    cmd += CRLF + " SELECT "
    cmd += CRLF + "    SUM(C7_QUANT) AS C7_QUANT , SUM(C7_QUJE) AS C7_QUJE , MAX(C7_PRECO) C7_PRECO "
    cmd += CRLF + " FROM " + RetSqlName("SC7") + " SC7 "
    cmd += CRLF + " WHERE "
    cmd += CRLF + "     D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND C7_PRODUTO =  '" + cProd + "' "
    cmd += CRLF + " AND C7_QUJE <> C7_QUANT "
    cmd += CRLF + " AND C7_RESIDUO = ' ' "
    cmd += CRLF + " AND C7_CONTRA  = ' ' "
    cmd += CRLF + " AND C7_CONAPRO NOT IN ('B', 'R') "

    Tcquery cmd new Alias (cAlias)

    DbSelectArea(cAlias)
	(cAlias)->(DBGOTOP())

	while !(cAlias)->(eof())

        aRes[1] :=  (cAlias)->C7_QUANT
        aRes[2] :=  (cAlias)->C7_QUJE
        aRes[3] :=  (cAlias)->C7_PRECO

    	(cAlias)->(DbSkip())
	EndDo    

    (cAlias)->(DbCloseArea())

Return aRes


/*===================================================================================
Programa.:              zGetCusto
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Obtem a o custo do produto
===================================================================================== */
Static Function zGetCusto(cProd)
    Local aRes  := {0,""}
    Local cAlias:= GetNextAlias()
    Local cmu   := ""

    If Select( cAlias )  > 0
        (cAlias)->(DbCloseArea())
    EndIf

    cmu := "  SELECT B9_CM1 AS CUSTO "
    cmu += "  FROM " + RetSqlName("SB9") + " SB9"
    cmu += "  WHERE D_E_L_E_T_  = ' '"
    cmu += "  AND SB9.B9_FILIAL = '" + FwXFilial("SB9") + "' " 	
    cmu += "  AND SB9.B9_COD    = '" + cProd + "' "
    cmu += "  ORDER BY B9_DATA DESC "

	cmu := ChangeQuery(cmu)

	TCQUERY cmu NEW ALIAS (cALIAS)

	If (cALIAS)->(EOF())
		(cALIAS)->(dbCloseArea())
	Else

        aRes := {CUSTO,"SB9"}

    EndIf

    If Select( cAlias )  > 0
        (cAlias)->(DbCloseArea())
    EndIf

Return aRes


/*===================================================================================
Programa.:              zGetQtB1
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Obtem a listagem dos produtos
===================================================================================== */
Static Function zGetQtB1()
    Local cQr       := GetNextAlias()
    Local cmd       := ""
    Local cAux      := "" 

    cmd += CRLF + " SELECT "
    cmd += CRLF + "   B1_COD, B1_DESC, B1_XDESCL1, B1_EMIN, B1_EMAX, SUM(B2_QATU) AS B2_QATU "
    cmd += CRLF + " FROM " + RetSqlName("SB1") + " SB1"
    cmd += CRLF + " LEFT JOIN " + RetSqlName("SB2") + " SB2"
    cmd += CRLF + " ON SB2.D_E_L_E_T_ = ' ' AND B2_FILIAL = '" + cFilAnt + "' AND B2_COD = B1_COD"
    cmd += CRLF + " WHERE "
    cmd += CRLF + "     SB1.D_E_L_E_T_ = ' '"
    cmd += CRLF + " AND B1_FILIAL = '" + Subst(cFilAnt, 1 , 6) + "' "
    cmd += CRLF + " AND B1_TIPO >= '"   + aRt[1]  + "' AND B1_TIPO <= '"   + aRt[2] + "' "
    cmd += CRLF + " AND B1_GRUPO >= '"  + aRt[3]  + "' AND B1_GRUPO <= '"  + aRt[4] + "' "
    cmd += CRLF + " AND B1_LOCPAD >= '" + aRt[5]  + "' AND B1_LOCPAD <= '" + aRt[6] + "' "
    cmd += CRLF + " AND B1_COD LIKE '" + Alltrim(MV_PAR07) + "%' "
    cmd += CRLF + " GROUP BY B1_COD, B1_DESC, B1_EMIN, B1_EMAX, B1_XDESCL1 "

    If MV_PAR08 = .T.
        cmd += CRLF + " HAVING SUM(B2_QATU) <  B1_EMIN"
    EndIf

    cmd += CRLF + " ORDER BY B1_COD, B1_DESC, B1_XDESCL1   "

    TcQuery cmd new Alias (cQr)

    While (cQr)->(Eof()) = .F.
        RecLock( (cTb), .T. )

        cAux := StrTran(((cQr)->B1_DESC) + " " + Alltrim((cQr)->B1_XDESCL1), ";", " " )
        cAux := StrTran(cAux, ">", " " )
        cAux := StrTran(cAux, "<", " " )
        cAux := StrTran(cAux, "/", " " )
        cAux := StrTran(cAux, "\", " " )
        cAux := StrTran(cAux, "'", " " )
        cAux := StrTran(cAux, '"', " " )
        cAux := StrTran(cAux, char(13), " " )
        cAux := StrTran(cAux, char(10), " " )

        (cTb)->B1_COD   := (cQr)->B1_COD
//        (cTb)->B1_DESC  := ((cQr)->B1_DESC) + " " + Alltrim((cQr)->B1_XDESCL1)
        (cTb)->B1_DESC  := cAux
        (cTb)->B1_EMIN  := (cQr)->B1_EMIN
        (cTb)->B1_EMAX  := (cQr)->B1_EMAX
        (cTb)->B2_QATU  := (cQr)->B2_QATU

        (cTb)->(MsUnlock())

        (cQr)->(DbSkip())
    EndDo

    (cQr)->(DbCloseArea())
Return


/*===================================================================================
Programa.:              zGetQtC1
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Obtem as qua tidades solicitadas
===================================================================================== */
Static Function zGetQtC1(cProd)
    Local cTb   := GetNextAlias()
    Local cmd   := ""
    Local nRes  := 0

    cmd := CRLF + " SELECT SUM(C1_QUANT) as C1_QUANT /* , C1_QUJE , C1_QUANT, C1_RESIDUO, C1_APROV  */ "
    cmd += CRLF + " FROM " + RetSqlName("SC1") + " SC1 "
    cmd += CRLF + " WHERE
    cmd += CRLF + "     D_E_L_E_T_ = ' '  "
    cmd += CRLF + " AND C1_FILIAL = '"+ cFilAnt +"' "
    cmd += CRLF + " AND C1_QUJE <> C1_QUANT "
    cmd += CRLF + " AND C1_RESIDUO <> 'S' "
    cmd += CRLF + " AND C1_APROV NOT IN  ('B', 'R')
    cmd += CRLF + " AND C1_PRODUTO = '" + cProd + "'

    TcQuery cmd new Alias (cTb)

    nRes := (cTb)->C1_QUANT

    (cTb)->(DbCloseArea())

Return nRes


/*===================================================================================
Programa.:              RptDef
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Prepara o relatorio
===================================================================================== */
Static Function RptDef()
    Local lUmaLinha := .F.
	Local oSection 	:= Nil
    Local cTitulo   := "Relat�rio sint�tico de estoque/compras (Min/M�x)" 
    Local cDescricao:= "Rel sint�tico de est/compras comparativo com o est m�nimo/m�ximo (Itens de Manuten��o)"
    Local aStru     := (cTb)->(DbStruct())

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

    oSection:= TRSection():New(oRep, "CABECA", {cTb}, {"Codigo", "Descricao"} , .F., .T.)

    TRCell():New(oSection, aStru[1 ,1], cTb, "Codigo"     , "@!"           ,                  40, , , "LEFT", lUmaLinha)
    TRCell():New(oSection, aStru[2 ,1], cTb, "Descri��o", "@!"           ,                 150, , , "LEFT", !lUmaLinha)
    TRCell():New(oSection, aStru[3 ,1], cTb, "Est Min"    , "@E 999,999.99",                  30, , , "RIGHT", lUmaLinha)
    TRCell():New(oSection, aStru[4 ,1], cTb, "Est Max"    , "@E 999,999.99",                  30, , , "RIGHT", lUmaLinha)
    TRCell():New(oSection, aStru[5 ,1], cTb, "Sld Est Atu", "@E 999,999.99",                  30, , , "RIGHT", lUmaLinha)
    TRCell():New(oSection, aStru[6 ,1], cTb, "Custo Und"  , "@E 999,999.99",                  20, , , "RIGHT", lUmaLinha)
    TRCell():New(oSection, aStru[7 ,1], cTb, "Compra"     , "@E 999,999.99",                  20, , , "RIGHT", lUmaLinha)
    TRCell():New(oSection, aStru[8 ,1], cTb, "Custo Tot"  , "@E 999,999.99",                  30, , , "RIGHT", lUmaLinha)
    TRCell():New(oSection, aStru[9 ,1], cTb, "Qtd solic"  , "@E 999,999.99",                  30, , , "RIGHT", lUmaLinha)
    TRCell():New(oSection, aStru[10,1], cTb, "Qtd Pedid"  , "@E 999,999.99",                  30, , , "RIGHT", lUmaLinha)
    TRCell():New(oSection, aStru[11,1], cTb, "Qtd Entre"  , "@E 999,999.99",                  30, , , "RIGHT", lUmaLinha)
    TRCell():New(oSection, aStru[12,1], cTb, "Orig"       , "@!",                             10, , , "LEFT", lUmaLinha)

Return oRep    


/*===================================================================================
Programa.:              RptDef
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Monta o relatorio
===================================================================================== */
Static Function ReportPrint(aItens)
	Local i         := 0
    Local oSection  := oRep:Section(1)
    Local aStru     := (cTb)->(DbStruct())

    //  MAN00000
    oSection:Init()

    oRep:SetMeter( (cTb)->( LastRec() ) )

    (cTb)->(DbSetorder(oSection:GetOrder()))
    (cTb)->(DbGoTop())

    While (cTb)->(Eof()) = .F.
        For i:=1 to Len(aStru)
            oSection:Cell(aStru[i,1]):SetValue((cTb)->&(aStru[i,1]))
        Next

        oSection:Printline()
        (cTb)->(DbSkip())
        oRep:IncMeter()
    EndDo

	oRep:SkipLine()
    oRep:ThinLine()
    oSection:Finish()

    oRep:EndPage()
    
Return .T.


Static Function zExpXlsx()
    Local i       := 1
    Local aTitles := {}
    Local acols   := {}
    Local aIt     := {}
    Local aStru   := (cTb)->(DbStruct())

    Aadd(aTitles,"Codigo produto")
    Aadd(aTitles,"Descri��o completa")
    Aadd(aTitles,"Est Minimo"  )
    Aadd(aTitles,"Est Maximo"  )
    Aadd(aTitles,"Sld Est Atual")
    Aadd(aTitles,"Custo Unitario")
    Aadd(aTitles,"Compra")
    Aadd(aTitles,"Custo Total")
    Aadd(aTitles,"Qtd solicitado")
    Aadd(aTitles,"Qtd Pedido")
    Aadd(aTitles,"Qtd Entregue")
    Aadd(aTitles,"Origem custo")


    (cTb)->(DbGoTop())

    While (cTb)->(Eof()) = .F.
        aIt := {}
        For i:=1 to Len(aStru)
            Aadd(aIt, (cTb)->&(aStru[i,1])  )
            
            if Empty((cTb)->&(aStru[i,1])) .AND. aStru[i,2] = "N"
                (cTb)->&(aStru[i,1]) := 0
            EndIf

            if Empty((cTb)->&(aStru[i,1])) .AND. aStru[i,2] = "C"
                (cTb)->&(aStru[i,1]) := " "
            EndIf
        Next

        Aadd(aCols, aIt)
        (cTb)->(DbSkip())
    Enddo

    u_ZGENEXCEL(aTitles, aCols, "Planilha", "Relat�rio sint�tico de estoque/compras (Min/M�x)")
Return

