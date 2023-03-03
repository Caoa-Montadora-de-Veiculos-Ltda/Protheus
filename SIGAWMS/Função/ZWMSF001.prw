#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"

/*
=====================================================================================
Programa.:              ZWMSF001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              01/10/2019
Descricao / Objetivo:   Monitor de envio de unitizadores RGLog
Doc. Origem:
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
User function ZWMSF001()

    Local cTitulo		:= "Monitor Transferência - Envio"
    //Local nSeconds      := SuperGetMV("CMV_WMS002", .F., 5 ) // Tempo em Segundos para Refresh da tela (Default = 5 segundos)
    Private oBrowse		:= Nil
    Private cArqTrab	:= "TMPSQL01"
    Private aColumns	:= {}
    Private cPerg       := Padr("ZWMSF001",Len(SX1->X1_GRUPO))
    Private cLocal      := Space(03)

	If !Pergunte(cPerg,.T.)
        Return()
    Else
        cLocal := Mv_Par01
	EndIf
    
    Processa( {|| zMontaTRB()},"Atualizando informações do Browse...")
    
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cArqTrab)
    oBrowse:SetDescription(cTitulo)
    oBrowse:SetMenuDef("")
    oBrowse:AddButton("Filtrar" , { || BtFiltrar()      }   , ,1 )
    oBrowse:AddButton("Refresh" , { || BtRefresh()      }   , ,2 )
    oBrowse:AddButton("Cancelar", { || CloseBrowse()    }   , ,6 )
    oBrowse:SetColumns(aColumns)
    //oBrowse:SetTimer({ || BtRefresh() }, Iif( nSeconds<=0, 5000, nSeconds ) * 1000 )
    oBrowse:Activate()

Return

/*
=====================================================================================
Programa.:              BtRefresh
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              01/10/2019
Descricao / Objetivo:   Botão de Refresh
Doc. Origem:
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function BtRefresh()

Processa( {|| zMontaTRB()},"Atualizando informações do Browse...")

oBrowse:Refresh(.F.)
oBrowse:GoTo(1)

Return()

/*
=====================================================================================
Programa.:              BtFiltrar
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              12/11/2019
Descricao / Objetivo:   Botão de Filtrar
Doc. Origem:
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function BtFiltrar()

cLocal := Space(03)

If !Pergunte(cPerg,.T.)
    Return()
Else
    cLocal := Mv_Par01
EndIf

Processa( {|| zMontaTRB()},"Atualizando informações do Browse...")

oBrowse:Refresh(.F.)
oBrowse:GoTo(1)

Return()

/*
=====================================================================================
Programa.:              zMontaTRB
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              01/10/2019
Descricao / Objetivo:   Monta Query e TRB
Doc. Origem:
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function zMontaTRB()

    Local aStru         := {}
    Local cTabSql       := GetNextAlias()
    Local cTabUni       := GetNextAlias()
    Local oTrbTmp       := Nil
    Local cQry01		:= ""
    Local cQry02		:= ""
    Local nX			:= 0

    //==============================================================================================================
    // Estrutura dos campos que serão usados para montar o Browse
    //==============================================================================================================    
    AAdd(aStru,{    "UNITIZ"    ,"C"    ,013    ,0  ,"Unitizador"       })
    AAdd(aStru,{    "ARM_ORI"   ,"C"    ,003    ,0  ,"Arm.Orig."        })
    AAdd(aStru,{    "END_ORI"   ,"C"    ,015    ,0  ,"Endereço Origem"  })
    AAdd(aStru,{    "ARM_DES"   ,"C"    ,003    ,0  ,"Arm.Dest"         })
    AAdd(aStru,{    "END_DES"   ,"C"    ,015    ,0  ,"Endereço Destino" })
    AAdd(aStru,{    "PRODUTO"   ,"C"    ,015    ,0  ,"Produto"          })
        
    //==============================================================================================================
    // Define as colunas da Browse de acordo com a estrutura
    //==============================================================================================================    
    For nX := 1 To Len(aStru)
        AAdd(   aColumns,FWBrwColumn():New())
                aColumns[nX]:SetData( &("{||"+aStru[nX][1]+"}") )
                aColumns[nX]:SetTitle(aStru[nX][5])
                aColumns[nX]:SetType(aStru[nX][2])
                aColumns[nX]:SetSize(aStru[nX][3])
                aColumns[nX]:SetDecimal(aStru[nX][4])
                aColumns[nX]:SetPicture("@!")
    Next nX

    If Select((cArqTrab)) > 0
        (cArqTrab)->(DbCloseArea())
    EndIf
        
    If oTrbTmp <> Nil
        oTrbTmp:Delete()
        oTrbTmp	:= Nil
    EndIf

    //Cria o Objeto do FwTemporaryTable
    oTrbTmp := FwTemporaryTable():New(cArqTrab)

    //Cria a estrutura do alias temporario
    oTrbTmp:SetFields(aStru)

    //Adiciona o indicie na tabela temporaria
    oTrbTmp:AddIndex("1",{"ARM_DES"})

    //Criando a Tabela Temporaria
    oTrbTmp:Create()    
        
    //=============================================================================================================
    // Monta a query com os 03 endereços vazios por estoque que possuem estoque do tipo pulmão
    //==============================================================================================================
    If Select((cTabSql)) > 0
        (cTabSql)->(DbCloseArea())
    EndIf

    //=============================================================================================================
    // DC3 - Sequencia de abastecimento
    //==============================================================================================================
    cQry01 := ""
    cQry01 += " SELECT * FROM "                                                                                                      + CRLF
	cQry01 += "      ( "                                                                                                             + CRLF
    cQry01 += "      	SELECT  DC3_FILIAL, DC3_LOCAL, DC3_TPESTR, DC3_CODPRO, DC3_XPEPUL, DC3_CODNOR, DC2_LASTRO, DC2_CAMADA, "     + CRLF
	cQry01 += "      			( DC2_CAMADA * DC2_LASTRO ) AS QTDNORMA, "                                                           + CRLF
	cQry01 += "      			SUM(D14_QTDEST) AS D14_QTDEST, "                                                                     + CRLF
	cQry01 += "      			SUM(D14_QTDEPR) AS D14_QTDEPR, "                                                                     + CRLF
	cQry01 += "      			SUM(D14_QTDSPR) AS D14_QTDSPR, "                                                                     + CRLF
	cQry01 += "      			( ( SUM(D14_QTDEST)  +   SUM(D14_QTDEPR)  ) - SUM(D14_QTDSPR) ) AS ESTOQUE "                         + CRLF
    cQry01 += "      	FROM "+ RetSqlName("DC3") +" DC3 "                                                                           + CRLF
    //=============================================================================================================
    // DC8 - verifica se é um endereço fisico igual a pulmão
    //==============================================================================================================
	cQry01 += "      		INNER JOIN "+ RetSqlName("DC8") +" DC8 "                                                                 + CRLF
	cQry01 += "      			ON DC3.DC3_FILIAL = DC8.DC8_FILIAL "                                                                 + CRLF
	cQry01 += "      			AND DC3.DC3_TPESTR = DC8.DC8_CODEST "                                                                + CRLF
	cQry01 += "      			AND DC8.DC8_TPESTR = '1' "                                                                           + CRLF
    cQry01 += "      			AND DC8.D_E_L_E_T_ = ' ' "                                                                           + CRLF
    //=============================================================================================================
    // D14 - Busca saldo do produto.
    //==============================================================================================================
	cQry01 += "      		INNER JOIN "+ RetSqlName("D14") +" D14 "                                                                 + CRLF
	cQry01 += "      			ON DC3.DC3_FILIAL = D14.D14_FILIAL "                                                                 + CRLF
	cQry01 += "      			AND DC3.DC3_CODPRO = D14.D14_PRODUT "                                                                + CRLF
	cQry01 += "      			AND DC3.DC3_LOCAL = D14.D14_LOCAL "                                                                  + CRLF
	cQry01 += "      			AND DC3.DC3_TPESTR = D14.D14_ESTFIS "                                                                + CRLF
    cQry01 += "      			AND D14.D_E_L_E_T_ = ' ' "                                                                           + CRLF
    //=============================================================================================================
    // DC3 - Verifica e busca a norma e valores para realizar a conta.
    //=============================================================================================================
	cQry01 += "      		INNER JOIN "+ RetSqlName("DC2") +" DC2 "                                                                 + CRLF
	cQry01 += "      			ON DC3.DC3_FILIAL = DC2.DC2_FILIAL "                                                                 + CRLF
	cQry01 += "      			AND DC3.DC3_CODNOR = DC2.DC2_CODNOR "                                                                + CRLF
	cQry01 += "      			AND DC2.D_E_L_E_T_ = ' ' "                                                                           + CRLF
    cQry01 += "      	WHERE DC3.D_E_L_E_T_ = ' ' "                                                                                 + CRLF
    //=============================================================================================================
    // Filtra os somente a seq que tem % preenchida.
    //==============================================================================================================
	cQry01 += "      	AND DC3.DC3_FILIAL = '" + xFilial("DC3") + "' "                                                              + CRLF
    cQry01 += "      	AND DC3.DC3_XPEPUL > 0 "                                                                                     + CRLF
    cQry01 += "      	AND DC3.DC3_LOCAL = '" + cLocal + "' "                                                                       + CRLF
    cQry01 += "      	GROUP BY DC3_FILIAL, DC3_LOCAL, DC3_TPESTR, DC3_CODPRO, DC3_XPEPUL, DC3_CODNOR, DC2_LASTRO, DC2_CAMADA "     + CRLF
    cQry01 += "      ) TABSQL "                                                                                                      + CRLF
    //=============================================================================================================
    // Mostra somente os itens que estão com a % de reposição.
    //==============================================================================================================
    cQry01 += " WHERE TABSQL.ESTOQUE <= ( ( TABSQL.DC3_XPEPUL * TABSQL.QTDNORMA ) / 100 ) "                                          + CRLF

    cQry01  := ChangeQuery(cQry01)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry01),cTabSql,.T.,.T.)

    //==============================================================================================================
    // Alimenta a tabela temporária de acordo com a consulta SQL
    //==============================================================================================================    
    DbSelectArea((cTabSql))
    (cTabSql)->(dbGoTop())
    While !(cTabSql)->(Eof())

        If Select((cTabUni)) > 0
            (cTabUni)->(DbCloseArea())
        EndIf

        //==============================================================================================================
        // Busca um unitizador na RGLog de acordo com o Fifo... (Unitizador mais antigo.)
        //==============================================================================================================    
        cQry02 := ""
        cQry02 += " SELECT TB.D14_IDUNIT, TB.D14_ENDER FROM "                                               + CRLF
        cQry02 += "     ( "                                                                                 + CRLF
        cQry02 += "         SELECT D14_IDUNIT, D14_ENDER FROM "+ RetSqlName("D14") +" TMPD14 "              + CRLF
        cQry02 += "         WHERE TMPD14.D_E_L_E_T_ = ' ' "                                                 + CRLF
        cQry02 += "         AND TMPD14.D14_FILIAL  = '" + (cTabSql)->DC3_FILIAL + "' "                      + CRLF
        cQry02 += "         AND TMPD14.D14_LOCAL = '" + SuperGetMv("CMV_WMS001",.F.,"907") + "' "           + CRLF
        cQry02 += "         AND TMPD14.D14_PRODUT = '" + (cTabSql)->DC3_CODPRO + "' "                       + CRLF  
        cQry02 += "         ORDER BY TMPD14.D14_IDUNIT "                                                    + CRLF
        cQry02 += "     )TB "                                                                               + CRLF
        cQry02 += " WHERE ROWNUM = 1 "                                                                      + CRLF
        
        cQry02  := ChangeQuery(cQry02)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry02),cTabUni,.T.,.T.)

        DbSelectArea((cTabUni))
        (cTabUni)->(dbGoTop())
    
        (cArqTrab)->(RecLock(cArqTrab,.T.))
        If Empty((cTabUni)->D14_IDUNIT)    
            (cArqTrab)->UNITIZ  := "NÃO LOCALIZADO"
            (cArqTrab)->END_ORI := ""
        Else
            (cArqTrab)->UNITIZ  := (cTabUni)->D14_IDUNIT
            (cArqTrab)->END_ORI := (cTabUni)->D14_ENDER
        EndIf
        (cArqTrab)->ARM_ORI := SuperGetMv("CMV_WMS001",.F.,"907") // Armazém de origem (RgLog)
        (cArqTrab)->ARM_DES := cLocal
        (cArqTrab)->END_DES := SuperGetMv("CMV_WMS003",.F.,"DCE_TRANSITO") // Endereço de destino padrão para os armazéns
        (cArqTrab)->PRODUTO := (cTabSql)->DC3_CODPRO
        (cArqTrab)->(MsUnLock())

        (cTabSql)->(dbSkip())
        (cTabUni)->(DbCloseArea())
    EndDo
    (cTabSql)->(dbCloseArea())

Return()