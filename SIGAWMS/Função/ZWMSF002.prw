#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"

/*
=====================================================================================
Programa.:              ZWMSF002
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              13/11/2019
Descricao / Objetivo:   Monitor de Recebimento d0 unitizadores RGLog
Doc. Origem:
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
User function ZWMSF002()

    Local cTitulo		:= "Monitor Transferência - Recebimento"
    //Local nSeconds      := SuperGetMV("CMV_WMS002", .F., 5 ) // Tempo em Segundos para Refresh da tela (Default = 5 segundos)
    Private oBrowse		:= Nil
    Private cArqTrab	:= "TMPSQL01"
    Private aColumns	:= {}
    Private cPerg       := Padr("ZWMSF002",Len(SX1->X1_GRUPO))
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
    Local oTrbTmp       := Nil
    Local cQry01		:= ""
    Local nX			:= 0

    //==============================================================================================================
    // Estrutura dos campos que serão usados para montar o Browse
    //==============================================================================================================    
    AAdd(aStru,{    "UNITIZ"        ,"C"    ,013    ,0  ,"Unitizador"       })
    AAdd(aStru,{    "ARMAZ"         ,"C"    ,003    ,0  ,"Armazém"          })
    AAdd(aStru,{    "ENDER"         ,"C"    ,015    ,0  ,"Endereço"         })
    AAdd(aStru,{    "PRODUTO"       ,"C"    ,015    ,0  ,"Produto"          })
       
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
    oTrbTmp:AddIndex("1",{"ARMAZ"})

    //Criando a Tabela Temporaria
    oTrbTmp:Create()    
        
    //=============================================================================================================
    // Monta a query com os 03 endereços vazios por estoque que possuem estoque do tipo pulmão
    //==============================================================================================================
    If Select((cTabSql)) > 0
        (cTabSql)->(DbCloseArea())
    EndIf

     
    cQry01 := ""
    cQry01 += " SELECT D14_IDUNIT, D14_ENDER, D14_LOCAL, D14_PRODUT  FROM "+ RetSqlName("D14") +" D14 "         + CRLF
    cQry01 += " WHERE D14.D_E_L_E_T_ = ' ' "                                                                    + CRLF
    cQry01 += " AND D14.D14_FILIAL  = '" + xFilial("D14") + "' "                                               + CRLF
    cQry01 += " AND D14.D14_LOCAL = '" + cLocal + "' "                                                          + CRLF
    cQry01 += " AND D14.D14_ENDER = '" + SuperGetMv("CMV_WMS003",.F.,"DCE_TRANSITO") + "' "                     + CRLF  
    cQry01 += " ORDER BY D14.D14_IDUNIT "                                                                       + CRLF
   
    cQry01  := ChangeQuery(cQry01)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry01),cTabSql,.T.,.T.)

    //==============================================================================================================
    // Alimenta a tabela temporária de acordo com a consulta SQL
    //==============================================================================================================    
    DbSelectArea((cTabSql))
    (cTabSql)->(dbGoTop())
    While !(cTabSql)->(Eof())
    
        (cArqTrab)->(RecLock(cArqTrab,.T.))
        (cArqTrab)->UNITIZ  := (cTabSql)->D14_IDUNIT
        (cArqTrab)->ARMAZ   := (cTabSql)->D14_LOCAL
        (cArqTrab)->ENDER   := (cTabSql)->D14_ENDER
        (cArqTrab)->PRODUTO := (cTabSql)->D14_PRODUT
        (cArqTrab)->(MsUnLock())

        (cTabSql)->(dbSkip())
    EndDo
    (cTabSql)->(dbCloseArea())

Return()