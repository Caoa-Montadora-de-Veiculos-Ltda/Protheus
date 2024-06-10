#Include 'FWMVCDef.ch'
#Include "rwmake.Ch"
#Include "TBICONN.CH"
#Include "FWBROWSE.CH"   
#Include "PROTHEUS.CH"
#Include "totvs.ch"
#Define LBreak (Chr(13)+Chr(10))

/*/{Protheus.doc} zTmpCadPO
Exemplo de Modelo 1 com tabela temporária
@author A.Carlos
@since 16/09/2022
@version 1.0
    @return Nil, Função não tem retorno Gerenciamento de POs
    @example
/*/
 
User Function ZPECF029(_cProduto)

Local aArea        := GetArea()
Local oBrowse
Local cFunBkp      := FunName()
Local afields      := {}
Local oDlg
Local nOpca        := 0
Local aSeek        := {}
Local aFieFilter   := {}
Local aPergs 	   := {}
Local cProd        := Space(23)
Local cPO          := Space(20)

Private lRet       := .T.
Private aRetP 	   := {}
Private cAliasTmp  := "TMP"
Private cTitulo	   := "Gerenciamento de POs"
Private aRotina    := MenuDef() 

If !( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
	Return Nil
EndIf

IF Empty(_cProduto)    
    Aadd( aPergs ,{1,"Informe o Produto ",cProd     ,"@!" , ""  , "SB1","", 100,.F. })

    If Empty(cProd)
        Aadd( aPergs ,{1,"Informe P.O. ",cPO  ,"@!" , ""  , "SW2","", 100,.F. })
    EndIf

    If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 
        DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi(cTitulo) PIXEL
        @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
        @ 29, 15 SAY OemToAnsi("Esta rotina realiza a análise de ítens" ) SIZE 268, 8 OF oDlg PIXEL
        @ 38, 15 SAY OemToAnsi("Da Caoa Barueri."                       ) SIZE 268, 8 OF oDlg PIXEL
        @ 48, 15 SAY OemToAnsi("Confirma Geração da Documento?"         ) SIZE 268, 8 OF oDlg PIXEL
        DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
        DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION  oDlg:End()           ENABLE OF oDlg
        ACTIVATE MSDIALOG oDlg CENTER
    EndIf
Else
    Aadd(aRetP,_cProduto)
    Aadd(aRetP,Space(10))
EndIf

If Type("nOpc") == "U"
    nOpc := 2
EndIf

If Len(aRetP) == 0
    Return Nil
EndIf

//--Monta temporaria
ZTmpInv()

If lRet = .T.
    //Irei criar a pesquisa que será apresentada na tela
    Aadd(aSeek,{"Item"	,{{ ""  ,"C"    ,023    ,000    ,"Item"    ,"@!"   }} })
    Aadd(aSeek,{"PO"	,{{ ""  ,"C"    ,030    ,000    ,"PO"      ,"@!"   }} })
    
    //Campos que irão compor a tela de filtro
    Aadd(aFieFilter,{   "ITEM"	    ,"Produto"   ,"C" ,008    ,000    ,"@!" } )

    oBrowse := FWMBrowse():New()
    oBrowse:SetMenuDef('ZPECF029')
    oBrowse:SetAlias(cAliasTmp)
    oBrowse:SetDescription(cTitulo)
    oBrowse:SetTemporary()
    oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
    oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
    oBrowse:AddLegend( "Left(STATUS,1)=='1'" , "BR_BRANCO"      , "Aguardando Embarque"              )
    oBrowse:AddLegend( "Left(STATUS,1)=='2'" , "BR_CINZA"       , "Embarcado com previsão de chegada")
    oBrowse:AddLegend( "Left(STATUS,1)=='3'" , "BR_VERDE"       , "Recebido Total"                   )
    oBrowse:AddLegend( "Left(STATUS,1)=='4'" , "BR_VERMELHO"    , "Não recebido"                     )
    oBrowse:AddLegend( "Left(STATUS,1)=='5'" , "BR_MARROM"      , "Recebido parcial na qtde "        )
    oBrowse:DisableDetails()

    Aadd(afields, {"Status"       ,"Status"    ,"C"  ,050 ,0 ,"@!" })
    Aadd(afields, {"Filial"       ,"Filial"    ,"C"  ,010 ,0 ,"@!" })
    Aadd(afields, {"Processo"     ,"Processo"  ,"C"  ,030 ,0 ,"@!" }) 
    Aadd(afields, {"Emissao"      ,"Emissao"   ,"D"  ,008 ,0 ,"@D" })                 
    Aadd(afields, {"Item"         ,"Item"      ,"C"  ,023 ,0 ,"@!" })
    Aadd(afields, {"Descricao"    ,"Descricao" ,"C"  ,040 ,0 ,"@!" })
    Aadd(afields, {"Qtde_Ped"     ,"Qtde_Ped"  ,"N"  ,010 ,2 ,"@!" })
    Aadd(afields, {"Transp"   	  ,"Transp"    ,"C"  ,015 ,0 ,"@!" })        
    Aadd(afields, {"Fornecedor"	  ,"Fornecedor","C"  ,006 ,0 ,"@!" })
    Aadd(afields, {"Loja"   	  ,"Loja"      ,"C"  ,002 ,0 ,"@!" }) 
    Aadd(afields, {"Nome"   	  ,"Nome"      ,"C"  ,020 ,0 ,"@!" }) 
    Aadd(afields, {"CNPJ"   	  ,"CNPJ"      ,"C"  ,014 ,0 ,"@!" })
    Aadd(afields, {"UF"   	      ,"UF"        ,"C"  ,002 ,0 ,"@!" })
    Aadd(afields, {"Dt_Imp"       ,"Dt_Imp"    ,"D"  ,008 ,0 ,"@D" })
    Aadd(afields, {"Saldo"        ,"Saldo"     ,"N"  ,010 ,2 ,"@!" })
    Aadd(afields, {"Quantidade"   ,"Quantidade","N"  ,010 ,2 ,"@!" })
    Aadd(afields, {"QtdConf"      ,"QtdConf"   ,"N"  ,010 ,2 ,"@!" })

    oBrowse:SetFields(afields) 
    oBrowse:Activate()

EndIf

SetFunName(cFunBkp)
RestArea(aArea)

Return Nil
 
 /*
=====================================================================================
Programa.:              ZTmpInv
Autor....:              CAOA - A. Carlos
Data.....:              16/09/2022
Descricao / Objetivo:   Monta temporaria invoices     
=====================================================================================
*/
Static Function ZTmpInv(lJob)

Local _cQ           := " "
Local aCampos       := {}
Local oTempInv	    := Nil
Local _cAliasPO     := GetNextAlias()
Local aStatus       := {}
Default lJob		:= .F.	

_cQ := " "
_cQ += " SELECT TMP.FILIAL      ,                                                                       "+LBreak
_cQ += "        TMP.PROCESSO    ,                                                                       "+LBreak
_cQ += "        TMP.EMISSAO     ,                                                                       "+LBreak
_cQ += "        TMP.DT_IMP      ,                                                                       "+LBreak
_cQ += "        TMP.TRANSP      ,                                                                       "+LBreak
_cQ += "        TMP.ITEM        ,                                                                       "+LBreak
_cQ += "        TMP.QTDE_PED    ,                                                                       "+LBreak
_cQ += "        TMP.DESCRICAO   ,                                                                       "+LBreak
_cQ += "        TMP.FORNEC      ,                                                                       "+LBreak
_cQ += "        TMP.LOJA        ,                                                                       "+LBreak
_cQ += "        TMP.NOME        ,                                                                       "+LBreak
_cQ += "        TMP.CNPJ        ,                                                                       "+LBreak
_cQ += "        TMP.UF          ,                                                                       "+LBreak
_cQ += "        TMP.NOTA        ,                                                                       "+LBreak
_cQ += "        TMP.SERIE                                                                               "+LBreak
_cQ += " FROM (                                                                                         "+LBreak
_cQ += "   SELECT    SW2.W2_FILIAL   FILIAL      ,                                                      "+LBreak
_cQ += "             SW2.W2_PO_NUM   PROCESSO    ,                                                      "+LBreak
_cQ += "             SW2.W2_PO_DT    EMISSAO     ,                                                      "+LBreak
_cQ += "             SW2.W2_DT_IMP   DT_IMP      ,                                                      "+LBreak
_cQ += "             SW3.W3_COD_I    ITEM        ,                                                      "+LBreak
_cQ += "             SW2.W2_FORN     FORNEC      ,                                                      "+LBreak
_cQ += "             SW2.W2_FORLOJ   LOJA        ,                                                      "+LBreak
_cQ += "             SA2.A2_NREDUZ   NOME        ,                                                      "+LBreak
_cQ += "             SA2.A2_CGC      CNPJ        ,                                                      "+LBreak
_cQ += "             SA2.A2_EST      UF          ,                                                      "+LBreak
_cQ += "             SD1.D1_QUANT    QTDE_PED    ,                                                      "+LBreak
_cQ += "             SB1.B1_DESC     DESCRICAO   ,                                                      "+LBreak
_cQ += "             SD1.D1_DOC      NOTA        ,                                                      "+LBreak
_cQ += "             SD1.D1_SERIE    SERIE       ,                                                      "+LBreak
_cQ += "             (SELECT SUBSTR(SYQ.YQ_DESCR, 1, 20)                                                "+LBreak
_cQ += "              FROM "+RetSqlName("SYQ")+" SYQ                                                    "+LBreak
_cQ += "              WHERE  SYQ.YQ_FILIAL   = '"+xFilial("SYQ")+"'                                     "+LBreak
_cQ += "                 AND SYQ.YQ_VIA      = SW2.W2_TIPO_EM) AS TRANSP                                "+LBreak
_cQ += " FROM "+RetSqlName("SW2")+" SW2                                                                 "+LBreak
_cQ += "      INNER JOIN                                                                                "+LBreak
_cQ += "      "+RetSqlName("SW3")+" SW3 ON   SW2.W2_FILIAL              = SW3.W3_FILIAL                 "+LBreak
_cQ += "                                 AND SW2.W2_PO_NUM              = SW3.W3_PO_NUM                 "+LBreak
_cQ += "                                 AND SW2.D_E_L_E_T_             = SW3.D_E_L_E_T_                "+LBreak
_cQ += "      INNER JOIN                                                                                "+LBreak
_cQ += "      "+RetSqlName("SB1")+" SB1 ON  SUBSTR(SW2.W2_FILIAL,1,6)   = SUBSTR(SB1.B1_FILIAL,1,6)     "+LBreak
_cQ += "                                AND SW3.W3_COD_I                = SB1.B1_COD                    "+LBreak
_cQ += "                                AND SW2.D_E_L_E_T_              = SB1.D_E_L_E_T_                "+LBreak
_cQ += "      INNER JOIN                                                                                "+LBreak
_cQ += "      "+RetSqlName("SA2")+" SA2 ON  '"+xFilial("SA2")+"'        = SA2.A2_FILIAL                 "+LBreak
_cQ += "                                AND SW2.W2_FORN                 = SA2.A2_COD                    "+LBreak
_cQ += "                                AND SW2.W2_FORLOJ               = SA2.A2_LOJA                   "+LBreak
_cQ += "                                AND SW2.D_E_L_E_T_              = SA2.D_E_L_E_T_                "+LBreak
_cQ += "      INNER JOIN                                                                                "+LBreak
_cQ += " 	  "+RetSqlName("SW5")+" SW5 ON  '"+xFilial("SW5")+"'        = SW5.W5_FILIAL                 "+LBreak
_cQ += "                                AND SW3.W3_COD_I                = SW5.W5_COD_I                  "+LBreak
_cQ += "                                AND SW3.W3_FORN                 = SW5.W5_FORN                   "+LBreak
_cQ += "                                AND SW3.W3_FORLOJ               = SW5.W5_FORLOJ                 "+LBreak
_cQ += "                                AND SW3.W3_POSICAO              = SW5.W5_POSICAO                "+LBreak
_cQ += "                                AND SW3.W3_PO_NUM               = SW5.W5_PO_NUM                 "+LBreak
_cQ += " 				                AND SW3.W3_PGI_NUM              = SW5.W5_PGI_NUM                "+LBreak
_cQ += " 				                AND SW3.W3_SEQ                  = SW5.W5_SEQ                    "+LBreak
_cQ += "                                AND SW3.D_E_L_E_T_              = SW5.D_E_L_E_T_                "+LBreak
_cQ += "      INNER JOIN                                                                                "+LBreak
_cQ += "      "+RetSqlName("SZM")+" SZM ON   '"+xFilial("SZM")+"'       = SZM.ZM_FILIAL                 "+LBreak
_cQ += "                                AND  SW5.W5_COD_I               = SZM.ZM_PROD                   "+LBreak
_cQ += "                                AND  SW5.W5_FORN                = SZM.ZM_FORNEC                 "+LBreak
_cQ += "                                AND  SW5.W5_FORLOJ              = SZM.ZM_LOJA                   "+LBreak
_cQ += "                                AND  SW5.W5_POSICAO             = SZM.ZM_POSICAO                "+LBreak
_cQ += "                                AND  SW5.W5_PO_NUM              = SZM.ZM_PO_NUM                 "+LBreak
_cQ += "                                AND  SW5.D_E_L_E_T_             = SZM.D_E_L_E_T_                "+LBreak
_cQ += "      INNER JOIN                                                                                "+LBreak
_cQ += "      "+RetSqlName("SD1")+" SD1 ON   '"+xFilial("SD1")+"'       = SD1.D1_FILIAL                 "+LBreak
_cQ += "                                AND  SZM.ZM_PROD                = SD1.D1_COD                    "+LBreak
_cQ += "                                AND  SZM.ZM_FORNEC              = SD1.D1_FORNECE                "+LBreak
_cQ += "                                AND  SZM.ZM_LOJA                = SD1.D1_LOJA                   "+LBreak
_cQ += "                                AND  SW5.W5_HAWB                = SD1.D1_XCONHEC                "+LBreak
_cQ += "                                AND  SZM.ZM_CONT                = SD1.D1_XCONT                  "+LBreak
_cQ += "                                AND  SZM.ZM_CASE                = SD1.D1_XCASE                  "+LBreak
_cQ += "                                AND  SW5.D_E_L_E_T_             = SD1.D_E_L_E_T_                "+LBreak
_cQ += "  WHERE  SW2.W2_FILIAL   = '2020012001'                                                         "+LBreak
If aRetP[01] <> "   "
   _cQ += " AND SW3.W3_COD_I    = '" + aRetP[01] + "'                                                   "+LBreak
EndIf

If aRetP[02] <> "   "
   _cQ += "  AND SW2.W2_PO_NUM   = '" + aRetP[02] + "'                                                  "+LBreak
EndIf
_cQ += " 	 AND SW3.W3_SEQ      = '1'                                                                  "+LBreak
_cQ += "     AND SW2.D_E_L_E_T_  = ' '                                                                  "+LBreak
_cQ += " ORDER BY 02,05 ) TMP                                                                           "+LBreak

If Select(_cAliasPO) > 0 ; (_cAliasPO)->( DbCloseArea() ) ; EndIf
DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQ),_cAliasPO, .T., .T. ) 
(_cAliasPO)->(DbGoTop())
If (_cAliasPO)->(!Eof())
	_lExist := .T.
Else
    lRet := .F.
    MsgInfo("Item ou PO não encontrado! ", "[ ZPECF029 ] - Aviso" )
	Return(lRet)
EndIf

//Se o alias estiver aberto, fechar para evitar erros com alias aberto
If (Select(cAliasTmp) <> 0)
	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbCloseArea())
EndIf

oTempInv := FWTemporaryTable():New(cAliasTmp)

Aadd(aCampos, {"Status"       ,"C"    ,050    ,0  })
Aadd(aCampos, {"Filial"       ,"C"    ,010    ,0  }) 
Aadd(aCampos, {"Processo"     ,"C"    ,030    ,0  }) 
Aadd(aCampos, {"Item"         ,"C"    ,023    ,0  })
Aadd(aCampos, {"Descricao"    ,"C"    ,040    ,0  })
Aadd(aCampos, {"Qtde_Ped"     ,"N"    ,010    ,2  })
Aadd(aCampos, {"Emissao"      ,"D"    ,008    ,0  })
Aadd(aCampos, {"Transp"       ,"C"    ,015    ,0  })        
Aadd(aCampos, {"Fornecedor"   ,"C"    ,006    ,0  })
Aadd(aCampos, {"Loja" 	      ,"C"    ,002    ,0  })
Aadd(aCampos, {"Nome"         ,"C"    ,020    ,0  })
Aadd(aCampos, {"CNPJ"         ,"C"    ,014    ,0  })
Aadd(aCampos, {"UF"           ,"C"    ,002    ,0  })
Aadd(aCampos, {"DT_IMP"       ,"D"    ,008    ,0  })        
Aadd(aCampos, {"Saldo"        ,"N"    ,010    ,2  })
Aadd(aCampos, {"Quantidade"   ,"N"    ,010    ,2  })
Aadd(aCampos, {"QtdConf"      ,"N"    ,010    ,2  })
oTempInv:SetFields( aCampos )
oTempInv:AddIndex( "01", { "Processo" } )
oTempInv:AddIndex( "02", { "Item" } )
oTempInv:Create()

While (_cAliasPO)->(!Eof())

    If RecLock(cAliasTmp,.T.)
        aStatus := FStatus(_cAliasPO)
        (cAliasTmp)->Status     := aStatus[01]
        (cAliasTmp)->Filial     := (_cAliasPO)->Filial
        (cAliasTmp)->Processo   := (_cAliasPO)->Processo
        (cAliasTmp)->Item       := (_cAliasPO)->Item 
        (cAliasTmp)->Descricao  := (_cAliasPO)->Descricao
        (cAliasTmp)->Qtde_Ped   := (_cAliasPO)->Qtde_Ped
        (cAliasTmp)->Emissao    := Stod((_cAliasPO)->Emissao)
        (cAliasTmp)->Transp     := (_cAliasPO)->Transp            
        (cAliasTmp)->Fornecedor := (_cAliasPO)->Fornec
        (cAliasTmp)->Loja       := (_cAliasPO)->Loja   
        (cAliasTmp)->Nome       := (_cAliasPO)->Nome
        (cAliasTmp)->CNPJ       := (_cAliasPO)->CNPJ
        (cAliasTmp)->UF         := (_cAliasPO)->UF 
        (cAliasTmp)->DT_IMP     := Stod((_cAliasPO)->DT_IMP)
        (cAliasTmp)->Saldo      := aStatus[02]
        (cAliasTmp)->Quantidade := aStatus[03]
        (cAliasTmp)->QtdConf    := aStatus[04]
        (cAliasTmp)->(MsUnLock())
    EndIf

    (_cAliasPO)->(DbSkip())
End

(_cAliasPO)->(DbCloseArea())

Return(lRet)

Static Function FStatus(_cAliasPO)

Local aArea     As Array
Local cQuery    As Character
Local cAlias1   As Character
Local cAlias2   As Character
Local cRetorno  As Character
Local aRetorno  As Array

cRetorno := ""
aArea    := GetArea()
cAlias1  := GetNextAlias()
cAlias2  := GetNextAlias()

cQuery := """
cQuery +=" SELECT  W5.W5_HAWB            W5_HAWB     ,                          "+LBreak
cQuery +="         NVL(W6.W6_DT_EMB,' ') W6_DT_EMB   ,                          "+LBreak
cQuery +="         NVL(W6.W6_DT_ETA,' ') W6_DT_ETA                              "+LBreak
cQuery +=" FROM "+RetSqlName("SW5")+" W5                                        "+LBreak
cQuery +="      LEFT JOIN                                                       "+LBreak
cQuery +="      "+RetSqlName("SW6")+" W6 ON '"+xFilial("SW5")+"' = W6.W6_FILIAL "+LBreak
cQuery +="                              AND W5.W5_HAWB           = W6.W6_HAWB   "+LBreak
cQuery +="                              AND W5.D_E_L_E_T_        = W6.D_E_L_E_T_"+LBreak
cQuery +=" WHERE    W5.W5_FILIAL    = '"+xFilial("SW5")       +"'               "+LBreak
cQuery +="      AND W5.W5_PO_NUM    = '"+(_cAliasPO)->Processo+"'               "+LBreak
cQuery +="      AND W5.W5_COD_I     = '"+(_cAliasPO)->Item    +"'               "+LBreak
cQuery +="      AND W5.W5_FORN      = '"+(_cAliasPO)->Fornec  +"'               "+LBreak
cQuery +="      AND W5.W5_FORLOJ    = '"+(_cAliasPO)->Loja    +"'               "+LBreak
cQuery +="      AND W5.W5_SEQ       = '1'                                       "+LBreak
cQuery +="      AND W5.D_E_L_E_T_   = ' '                                       "+LBreak

If Select(cAlias1) > 0 ; (cAlias1)->( DbCloseArea() ) ; EndIf
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAlias1, .T., .T. ) 

(cAlias1)->(DbGoTop())
If (cAlias1)->(Eof())
    cRetorno := "0 - Não encontrado SW5"
ElseIf (cAlias1)->(!Eof()) .And.  Empty(Alltrim((cAlias1)->W6_DT_EMB)) 
    cRetorno := "1 - Aguardando Embarque"
ElseIf (cAlias1)->(!Eof()) .And. !Empty(Alltrim((cAlias1)->W6_DT_EMB)) 
    cRetorno := "2 - Embarcado com previsão de chegada: "+Dtoc(Stod((cAlias1)->W6_DT_ETA))
EndIf

IF (cAlias1)->(!Eof())
    cQuery := ""
    cQuery += " SELECT DISTINCT ZD1.*                                                        "+LBreak
    cquery += " FROM "+RetSqlName("SW5")+" SW5                                               "+LBreak
    cQuery += " INNER JOIN                                                                   "+LBreak
    cQuery += "      "+RetSqlName("SZM")+ " SZM ON '"+xFilial("SZM")+"'  = SZM.ZM_FILIAL     "+LBreak
    cQuery += "                                AND  SW5.W5_COD_I         = SZM.ZM_PROD       "+LBreak
    cQuery += "                                AND  SW5.W5_FORN          = SZM.ZM_FORNEC     "+LBreak
    cQuery += "                                AND  SW5.W5_FORLOJ        = SZM.ZM_LOJA       "+LBreak
    cQuery += "                                AND  SW5.W5_POSICAO       = SZM.ZM_POSICAO    "+LBreak
    cQuery += "                                AND  SW5.W5_PO_NUM        = SZM.ZM_PO_NUM     "+LBreak
    cQuery += "                                AND  SW5.D_E_L_E_T_       = SZM.D_E_L_E_T_    "+LBreak
    cQuery += " INNER JOIN                                                                   "+LBreak
    cQuery += "      "+RetSqlName("SD1")+ " SD1 ON '"+xFilial("SD1")+"' = SD1.D1_FILIAL      "+LBreak
    cQuery += "                                AND  SZM.ZM_PROD         = SD1.D1_COD         "+LBreak
    cQuery += "                                AND  SZM.ZM_FORNEC       = SD1.D1_FORNECE     "+LBreak
    cQuery += "                                AND  SZM.ZM_LOJA         = SD1.D1_LOJA        "+LBreak
    cQuery += "                                AND  SW5.W5_HAWB         = SD1.D1_XCONHEC     "+LBreak
    cQuery += "                                AND  SZM.ZM_CONT         = SD1.D1_XCONT       "+LBreak
    cQuery += "                                AND  SZM.ZM_CASE         = SD1.D1_XCASE       "+LBreak
    cQuery += "                                AND  SW5.D_E_L_E_T_      = SD1.D_E_L_E_T_     "+LBreak
    cQuery += " INNER JOIN                                                                   "+LBreak
    cQuery += "      "+RetSqlName("ZD1")+ " ZD1 ON '"+xFilial("ZD1")+"' = ZD1.ZD1_FILIAL     "+LBreak
    cQuery += "                                AND  SD1.D1_DOC          = ZD1.ZD1_DOC        "+LBreak
    cQuery += "                                AND  SD1.D1_SERIE        = ZD1.ZD1_SERIE      "+LBreak
    cQuery += "                                AND  SD1.D1_FORNECE      = ZD1.ZD1_FORNEC     "+LBreak
    cQuery += "                                AND  SD1.D1_LOJA         = ZD1.ZD1_LOJA       "+LBreak
    cQuery += "                                AND  SD1.D1_COD          = ZD1.ZD1_COD        "+LBreak
    cQuery += "                                AND  SD1.D1_XCASE        = ZD1.ZD1_XCASE      "+LBreak
    cQuery += "                                AND  SW5.D_E_L_E_T_      = ZD1.D_E_L_E_T_     "+LBreak
    cQuery +=" WHERE    SW5.W5_FILIAL    = '"+xFilial("SW5")       +"'                       "+LBreak
    cQuery +="      AND SW5.W5_PO_NUM    = '"+(_cAliasPO)->Processo+"'                       "+LBreak
    cQuery +="      AND SW5.W5_COD_I     = '"+(_cAliasPO)->Item    +"'                       "+LBreak
    cQuery +="      AND SW5.W5_FORN      = '"+(_cAliasPO)->Fornec  +"'                       "+LBreak
    cQuery +="      AND SW5.W5_FORLOJ    = '"+(_cAliasPO)->Loja    +"'                       "+LBreak
    cQuery +="      AND ZD1.ZD1_DOC      = '"+(_cAliasPO)->Nota    +"'                       "+LBreak
    cQuery +="      AND ZD1.ZD1_SERIE    = '"+(_cAliasPO)->Serie   +"'                       "+LBreak     
    cQuery +="      AND SW5.D_E_L_E_T_   = ' '                                               "+LBreak

    If Select(cAlias2) > 0 ; (cAlias2)->(DbCloseArea()) ; EndIf
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAlias2, .T., .T. )

    (cAlias2)->(DbGoTop())
    If (cAlias2)->(!Eof())
        If (cAlias2)->ZD1_SLDIT == 0
            cRetorno := "3 - Recebido Total"
        ElseIf (cAlias2)->ZD1_QTCONF == 0
            cRetorno := "4 - Não recebido"
        ElseIf (cAlias2)->ZD1_SLDIT > 0 .And. (cAlias2)->ZD1_SLDIT < (cAlias2)->ZD1_QUANT
            cRetorno := "5 - Recebido parcial na qtde: "+Transform(ZD1_QTCONF,"@E 999,999,999.99")
        EndIf 
    EndIf
EndIf

aRetorno := {}

Aadd(aRetorno,cRetorno )
If Select(cAlias2) <> 0
    Aadd(aRetorno,If((cAlias2)->(!Eof()),(cAlias2)->ZD1_SLDIT ,0))
    Aadd(aRetorno,If((cAlias2)->(!Eof()),(cAlias2)->ZD1_QUANT ,0))
    Aadd(aRetorno,If((cAlias2)->(!Eof()),(cAlias2)->ZD1_QTCONF,0))
Else
    Aadd(aRetorno,0)
    Aadd(aRetorno,0)
    Aadd(aRetorno,0)
EndIf
If Select(cAlias1) > 0 ; (cAlias1)->( DbCloseArea() ) ; EndIf
If Select(cAlias2) > 0 ; (cAlias2)->( DbCloseArea() ) ; EndIf

RestArea(aArea)

Return(aRetorno)

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
Static Function MenuDef()

Local aRot := {} 

//Adicionando opções
ADD OPTION aRot TITLE 'Consulta Tela' ACTION 'VIEWDEF.ZPECF029' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
 
Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
 Static Function ModelDef()
 
//Criação do objeto do modelo de dados
Local oModel := Nil
     
//Criação da estrutura de dados utilizada na interface
Local oStTMP := FWFormModelStruct():New()

oStTMP:AddTable(cAliasTmp, { 'Filial'      ,'Processo'   ,'Emissao' ,'Item' ,'Descricao' ,'Qtd_Pedido'  ,;
                             'CNPJ'        ,'Fornecedor' ,'Loja'    ,'Nome' ,'UF'        ,'Data_Import'},;
                             'Temporaria')

//Adiciona os campos da estrutura
oStTmp:AddField(;
    "Ds_Status",;                                                                       // [01]  C   Titulo do campo
    "DsStatus",;                                                                        // [02]  C   ToolTip do campo
    "DsStatus",;                                                                        // [03]  C   Id do Field
    "C",;                                                                               // [04]  C   Tipo do campo
    30,;                                                                                // [05]  N   Tamanho do campo
    0,;                                                                                 // [06]  N   Decimal do campo
    Nil,;                                                                               // [07]  B   Code-block de validação do campo
    Nil,;                                                                               // [08]  B   Code-block de validação When do campo
    {},;                                                                                // [09]  A   Lista de valores permitido do campo
    .F.,;                                                                               // [10]  L   Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->DsStatus,'')" ),;// [11]  B   Code-block de inicializacao do campo
    .T.,;                                                                               // [12]  L   Indica se trata-se de um campo chave
    .F.,;                                                                               // [13]  L   Indica se o campo pode receber valor em uma operação de update.
    .F.)

oStTmp:AddField(;
    "Filial",;                                                                          // [01] C Titulo do campo
    "Filial",;                                                                          // [02] C ToolTip do campo
    "Filial",;                                                                          // [03] C Id do Field
    "C",;                                                                               // [04] C Tipo do campo
    10,;                                                                                // [05] N Tamanho do campo
    0,;                                                                                 // [06] N Decimal do campo
    Nil,;                                                                               // [07] B Code-block de validação do campo
    Nil,;                                                                               // [08] B Code-block de validação When do campo
    {},;                                                                                // [09] A Lista de valores permitido do campo
    .F.,;                                                                               // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->Filial,'')" ),;  // [11] B Code-block de inicializacao do campo
    .T.,;                                                                               // [12] L Indica se trata-se de um campo chave
    .F.,;                                                                               // [13] L Indica se o campo pode receber valor em uma operação de update.
    .F.)

oStTmp:AddField(;
    "Processo",;                                                                        // [01] C Titulo do campo
    "Processo",;                                                                        // [02] C ToolTip do campo
    "Processo",;                                                                        // [03] C Id do Field
    "C",;                                                                               // [04] C Tipo do campo
    30,;                                                                                // [05] N Tamanho do campo
    0,;                                                                                 // [06] N Decimal do campo
    Nil,;                                                                               // [07] B Code-block de validação do campo
    Nil,;                                                                               // [08] B Code-block de validação When do campo
    {},;                                                                                // [09] A Lista de valores permitido do campo
    .F.,;                                                                               // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->Processo,'')" ),;// [11] B Code-block de inicializacao do campo
    .T.,;                                                                               // [12] L Indica se trata-se de um campo chave
    .F.,;                                                                               // [13] L Indica se o campo pode receber valor em uma operação de update.
    .F.)                                                                                // [14] L Indica se o campo é virtual

oStTmp:AddField(;
    "Item",;                                                                            // [01] C Titulo do campo
    "Item",;                                                                            // [02] C ToolTip do campo
    "Item",;                                                                            // [03] C Id do Field
    "C",;                                                                               // [04] C Tipo do campo
    23,;                                                                                // [05] N Tamanho do campo
    0,;                                                                                 // [06] N Decimal do campo
    Nil,;                                                                               // [07] B Code-block de validação do campo
    Nil,;                                                                               // [08] B Code-block de validação When do campo
    {},;                                                                                // [09] A Lista de valores permitido do campo
    .F.,;                                                                               // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->Item,'')" ),;    // [11] B Code-block de inicializacao do campo
    .T.,;                                                                               // [12] L Indica se trata-se de um campo chave
    .F.,;                                                                               // [13] L Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                            // [14] L Indica se o campo é virtual

oStTmp:AddField(;
    "Descricao",;                                                                        // [01] C Titulo do campo
    "Descricao",;                                                                        // [02] C ToolTip do campo
    "Descricao",;                                                                        // [03] C Id do Field
    "C",;                                                                                // [04] C Tipo do campo
    40,;                                                                                 // [05] N Tamanho do campo
    0,;                                                                                  // [06] N Decimal do campo
    Nil,;                                                                                // [07] B Code-block de validação do campo
    Nil,;                                                                                // [08] B Code-block de validação When do campo
    {},;                                                                                 // [09] A Lista de valores permitido do campo
    .F.,;                                                                                // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->Descricao,'')" ),;// [11] B Code-block de inicializacao do campo
    .T.,;                                                                                // [12] L Indica se trata-se de um campo chave
    .F.,;                                                                                // [13] L Indica se o campo pode receber valor em uma operação de update.
    .F.)                                                                                 // [14] L Indica se o campo é virtual

oStTmp:AddField(;
    "Qtde_Pedida",;                                                                     // [01] C Titulo do campo
    "Qtde_Ped",;                                                                        // [02] C ToolTip do campo
    "Qtde_Ped",;                                                                        // [03] C Id do Field
    "N",;                                                                               // [04] C Tipo do campo
    10,;                                                                                // [05] N Tamanho do campo
    2,;                                                                                 // [06] N Decimal do campo
    Nil,;                                                                               // [07] B Code-block de validação do campo
    Nil,;                                                                               // [08] B Code-block de validação When do campo
    {},;                                                                                // [09] A Lista de valores permitido do campo
    .F.,;                                                                               // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->Qtde_Ped,'')" ),;// [11] B Code-block de inicializacao do campo
    .T.,;                                                                               // [12] L Indica se trata-se de um campo chave
    .F.,;                                                                               // [13] L Indica se o campo pode receber valor em uma operação de update.
    .F.)                                                                                // [14] L Indica se o campo é virtual
    
oStTmp:AddField(;
    "Emissao",;                                                                         // [01] C Titulo do campo
    "Emissao",;                                                                         // [02] C ToolTip do campo
    "Emissao",;                                                                         // [03] C Id do Field
    "D",;                                                                               // [04] C Tipo do campo
    08,;                                                                                // [05] N Tamanho do campo
    0,;                                                                                 // [06] N Decimal do campo
    Nil,;                                                                               // [07] B Code-block de validação do campo
    Nil,;                                                                               // [08] B Code-block de validação When do campo
    {},;                                                                                // [09] A Lista de valores permitido do campo
    .F.,;                                                                               // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->Emissao,'')" ),; // [11] B Code-block de inicializacao do campo
    .T.,;                                                                               // [12] L Indica se trata-se de um campo chave
    .F.,;                                                                               // [13] L Indica se o campo pode receber valor em uma operação de update.
    .F.)                                                                                // [14] L Indica se o campo é virtual
    
oStTmp:AddField(;
    "Via Transporte",;                                                                  // [01] C Titulo do campo
    "Transp",;                                                                          // [02] C ToolTip do campo
    "Transp",;                                                                          // [03] C Id do Field
    "C",;                                                                               // [04] C Tipo do campo
    15,;                                                                                // [05] N Tamanho do campo
    0,;                                                                                 // [06] N Decimal do campo
    Nil,;                                                                               // [07] B Code-block de validação do campo
    Nil,;                                                                               // [08] B Code-block de validação When do campo
    {},;                                                                                // [09] A Lista de valores permitido do campo
    .F.,;                                                                               // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->Transp,'')" ),;  // [11] B Code-block de inicializacao do campo
    .T.,;                                                                               // [12] L Indica se trata-se de um campo chave
    .F.,;                                                                               // [13] L Indica se o campo pode receber valor em uma operação de update.
    .F.)                                                                                // [14] L Indica se o campo é virtual

oStTmp:AddField(;
    "Fornecedor",;                                                                        // [01] C Titulo do campo
    "Fornecedor",;                                                                        // [02] C ToolTip do campo
    "Fornecedor",;                                                                        // [03] C Id do Field
    "C",;                                                                                 // [04] C Tipo do campo
    06,;                                                                                  // [05] N Tamanho do campo
    0,;                                                                                   // [06] N Decimal do campo
    Nil,;                                                                                 // [07] B Code-block de validação do campo
    Nil,;                                                                                 // [08] B Code-block de validação When do campo
    {},;                                                                                  // [09] A Lista de valores permitido do campo
    .F.,;                                                                                 // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->Fornecedor,'')" ),;// [11] B Code-block de inicializacao do campo
    .T.,;                                                                                 // [12] L Indica se trata-se de um campo chave
    .F.,;                                                                                 // [13] L Indica se o campo pode receber valor em uma operação de update.
    .F.)                                                                                  // [14] L Indica se o campo é virtual
    
oStTmp:AddField(;
    "Loja",;                                                                              // [01] C Titulo do campo
    "Loja",;                                                                              // [02] C ToolTip do campo
    "Loja",;                                                                              // [03] C Id do Field
    "C",;                                                                                 // [04] C Tipo do campo
    02,;                                                                                  // [05] N Tamanho do campo
    0,;                                                                                   // [06] N Decimal do campo
    Nil,;                                                                                 // [07] B Code-block de validação do campo
    Nil,;                                                                                 // [08] B Code-block de validação When do campo
    {},;                                                                                  // [09] A Lista de valores permitido do campo
    .F.,;                                                                                 // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->Loja,'')" ),;      // [11] B Code-block de inicializacao do campo
    .T.,;                                                                                 // [12] L Indica se trata-se de um campo chave
    .F.,;                                                                                 // [13] L Indica se o campo pode receber valor em uma operação de update.
    .F.)                                                                                  // [14] L Indica se o campo é virtual
    
oStTmp:AddField(;
    "Nome",;                                                                              // [01] C Titulo do campo
    "Nome",;                                                                              // [02] C ToolTip do campo
    "Nome",;                                                                              // [03] C Id do Field
    "C",;                                                                                 // [04] C Tipo do campo
    20,;                                                                                  // [05] N Tamanho do campo
    0,;                                                                                   // [06] N Decimal do campo
    Nil,;                                                                                 // [07] B Code-block de validação do campo
    Nil,;                                                                                 // [08] B Code-block de validação When do campo
    {},;                                                                                  // [09] A Lista de valores permitido do campo
    .F.,;                                                                                 // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->Nome,'')" ),;      // [11] B Code-block de inicializacao do campo
    .T.,;                                                                                 // [12] L Indica se trata-se de um campo chave
    .F.,;                                                                                 // [13] L Indica se o campo pode receber valor em uma operação de update.
    .F.) 
    
oStTmp:AddField(;
    "CNPJ",;                                                                              // [01] C Titulo do campo
    "CNPJ",;                                                                              // [02] C ToolTip do campo
    "CNPJ",;                                                                              // [03] C Id do Field
    "C",;                                                                                 // [04] C Tipo do campo
    14,;                                                                                  // [05] N Tamanho do campo
    0,;                                                                                   // [06] N Decimal do campo
    Nil,;                                                                                 // [07] B Code-block de validação do campo
    Nil,;                                                                                 // [08] B Code-block de validação When do campo
    {},;                                                                                  // [09] A Lista de valores permitido do campo
    .F.,;                                                                                 // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->CNPJ,'')" ),;      // [11] B Code-block de inicializacao do campo
    .T.,;                                                                                 // [12] L Indica se trata-se de um campo chave
    .F.,;                                                                                 // [13] L Indica se o campo pode receber valor em uma operação de update.
    .F.)           
    
oStTmp:AddField(;
    "UF",;                                                                                // [01] C Titulo do campo
    "UF",;                                                                                // [02] C ToolTip do campo
    "UF",;                                                                                // [03] C Id do Field
    "C",;                                                                                 // [04] C Tipo do campo
    02,;                                                                                  // [05] N Tamanho do campo
    0,;                                                                                   // [06] N Decimal do campo
    Nil,;                                                                                 // [07] B Code-block de validação do campo
    Nil,;                                                                                 // [08] B Code-block de validação When do campo
    {},;                                                                                  // [09] A Lista de valores permitido do campo
    .F.,;                                                                                 // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->UF,'')" ),;        // [11] B Code-block de inicializacao do campo
    .T.,;                                                                                 // [12] L Indica se trata-se de um campo chave
    .F.,;                                                                                 // [13] L Indica se o campo pode receber valor em uma operação de update.
        .F.)     
    
oStTmp:AddField(;
    "DT_IMP",;                                                                            // [01] C Titulo do campo
    "DT_IMP",;                                                                            // [02] C ToolTip do campo
    "DT_IMP",;                                                                            // [03] C Id do Field
    "D",;                                                                                 // [04] C Tipo do campo
    08,;                                                                                  // [05] N Tamanho do campo
    0,;                                                                                   // [06] N Decimal do campo
    Nil,;                                                                                 // [07] B Code-block de validação do campo
    Nil,;                                                                                 // [08] B Code-block de validação When do campo
    {},;                                                                                  // [09] A Lista de valores permitido do campo
    .F.,;                                                                                 // [10] L Indica se o campo tem preenchimento obrigatório
    FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->DT_IMP,'')" ),;    // [11] B Code-block de inicializacao do campo
    .T.,;                                                                                 // [12] L Indica se trata-se de um campo chave
    .F.,;                                                                                 // [13] L Indica se o campo pode receber valor em uma operação de update.
    .F.)
        
//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
oModel := MPFormModel():New("zTmpCadPO",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
//Atribuindo formulários para o modelo
oModel:AddFields("FORMTMP",/*cOwner*/,oStTMP)
     
//Setando a chave primária da rotina
oModel:SetPrimaryKey({'Processo'})
     
//Adicionando descrição ao modelo
oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
//Setando a descrição do formulário
oModel:GetModel("FORMTMP"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/ 
Static Function ViewDef()

//Local aStruTMP := (cAliasTmp)->(DbStruct())
Local oModel   := FWLoadModel("ZPECF029")
Local oStTMP   := FWFormViewStruct():New()
Local oView    := Nil
 
//Adicionando campos da estrutura
oStTmp:AddField(;
    "Processo",;        // [01] C Nome do Campo
    "01",;              // [02] C Ordem
    "Processo",;        // [03] C Titulo do campo
    "Processo",;        // [04] C Descricao do campo
    Nil,;               // [05] A Array com Help
    "C",;               // [06] C Tipo do campo
    "@!",;              // [07] C Picture
    Nil,;               // [08] B Bloco de PictTre Var
    Nil,;               // [09] C Consulta F3
    .F.,;               // [10] L Indica se o campo é alteravel
    Nil,;               // [11] C Pasta do campo
    Nil,;               // [12] C Agrupamento do campo
    Nil,;               // [13] A Lista de valores permitido do campo (ComPO)
    Nil,;               // [14] N Tamanho maximo da maior opção do comPO
    Nil,;               // [15] C Inicializador de Browse
    Nil,;               // [16] L Indica se o campo é virtual
    Nil,;               // [17] C Picture Variavel
    Nil)                // [18] L Indica pulo de linha após o campo
    
oStTmp:AddField(;
    "Item",;            // [01] C Nome do Campo
    "02",;              // [02] C Ordem
    "Item",;            // [03] C Titulo do campo
    "Item",;            // [04] C Descricao do campo
    Nil,;               // [05] A Array com Help
    "C",;               // [06] C Tipo do campo
    "@!",;              // [07] C Picture
    Nil,;               // [08] B Bloco de PictTre Var
    Nil,;               // [09] C Consulta F3
    .F.,;               // [10] L Indica se o campo é alteravel
    Nil,;               // [11] C Pasta do campo
    Nil,;               // [12] C Agrupamento do campo
    Nil,;               // [13] A Lista de valores permitido do campo (ComPO)
    Nil,;               // [14] N Tamanho maximo da maior opção do comPO
    Nil,;               // [15] C Inicializador de Browse
    Nil,;               // [16] L Indica se o campo é virtual
    Nil,;               // [17] C Picture Variavel
    Nil)                // [18] L Indica pulo de linha após o campo

oStTmp:AddField(;
    "Descricao",;       // [01] C Nome do Campo
    "03",;              // [02] C Ordem
    "Descricao",;       // [03] C Titulo do campo
    "Descricao",;       // [04] C Descricao do campo
    Nil,;               // [05] A Array com Help
    "C",;               // [06] C Tipo do campo
    "@!",;              // [07] C Picture
    Nil,;               // [08] B Bloco de PictTre Var
    Nil,;               // [09] C Consulta F3
    .F.,;               // [10] L Indica se o campo é alteravel
    Nil,;               // [11] C Pasta do campo
    Nil,;               // [12] C Agrupamento do campo
    Nil,;               // [13] A Lista de valores permitido do campo (ComPO)
    Nil,;               // [14] N Tamanho maximo da maior opção do comPO
    Nil,;               // [15] C Inicializador de Browse
    Nil,;               // [16] L Indica se o campo é virtual
    Nil,;               // [17] C Picture Variavel
    Nil)                // [18] L Indica pulo de linha após o campo

oStTmp:AddField(;
    "Qtde_Ped",;        // [01] C Nome do Campo
    "04",;              // [02] C Ordem
    "Qtd_Pedida",;      // [03] C Titulo do campo
    "Qtd",;             // [04] C Descricao do campo
    Nil,;               // [05] A Array com Help
    "N",;               // [06] C Tipo do campo
    "@E 9999999.99",;   // [07] C Picture
    Nil,;               // [08] B Bloco de PictTre Var
    Nil,;               // [09] C Consulta F3
    .F.,;               // [10] L Indica se o campo é alteravel
    Nil,;               // [11] C Pasta do campo
    Nil,;               // [12] C Agrupamento do campo
    Nil,;               // [13] A Lista de valores permitido do campo (ComPO)
    Nil,;               // [14] N Tamanho maximo da maior opção do comPO
    Nil,;               // [15] C Inicializador de Browse
    Nil,;               // [16] L Indica se o campo é virtual
    Nil,;               // [17] C Picture Variavel
    Nil)                // [18] L Indica pulo de linha após o campo 
    
oStTmp:AddField(;
    "Emissao",;         // [01] C Nome do Campo
    "05",;              // [02] C Ordem
    "Emissao",;         // [03] C Titulo do campo
    "Emissao",;         // [04] C Descricao do campo
    Nil,;               // [05] A Array com Help
    "D",;               // [06] C Tipo do campo
    "@D",;              // [07] C Picture
    Nil,;               // [08] B Bloco de PictTre Var
    Nil,;               // [09] C Consulta F3
    .F.,;               // [10] L Indica se o campo é alteravel
    Nil,;               // [11] C Pasta do campo
    Nil,;               // [12] C Agrupamento do campo
    Nil,;               // [13] A Lista de valores permitido do campo (ComPO)
    Nil,;               // [14] N Tamanho maximo da maior opção do comPO
    Nil,;               // [15] C Inicializador de Browse
    Nil,;               // [16] L Indica se o campo é virtual
    Nil,;               // [17] C Picture Variavel
    Nil)                // [18] L Indica pulo de linha após o campo

oStTmp:AddField(;
    "Transp",;          // [01] C Nome do Campo
    "06",;              // [02] C Ordem
    "Via Transporte",;  // [03] C Titulo do campo
    "Transp",;          // [04] C Descricao do campo
    Nil,;               // [05] A Array com Help
    "C",;               // [06] C Tipo do campo
    "@!",;              // [07] C Picture
    Nil,;               // [08] B Bloco de PictTre Var
    Nil,;               // [09] C Consulta F3
    .F.,;               // [10] L Indica se o campo é alteravel
    Nil,;               // [11] C Pasta do campo
    Nil,;               // [12] C Agrupamento do campo
    Nil,;               // [13] A Lista de valores permitido do campo (ComPO)
    Nil,;               // [14] N Tamanho maximo da maior opção do comPO
    Nil,;               // [15] C Inicializador de Browse
    Nil,;               // [16] L Indica se o campo é virtual
    Nil,;               // [17] C Picture Variavel
    Nil)                // [18] L Indica pulo de linha após o campo 

oStTmp:AddField(;
    "Fornecedor",;      // [01] C Nome do Campo
    "08",;              // [02] C Ordem
    "Fornecedor",;      // [03] C Titulo do campo
    "Fornecedor",;      // [04] C Descricao do campo
    Nil,;               // [05] A Array com Help
    "C",;               // [06] C Tipo do campo
    "@!",;              // [07] C Picture
    Nil,;               // [08] B Bloco de PictTre Var
    Nil,;               // [09] C Consulta F3
    .F.,;               // [10] L Indica se o campo é alteravel
    Nil,;               // [11] C Pasta do campo
    Nil,;               // [12] C Agrupamento do campo
    Nil,;               // [13] A Lista de valores permitido do campo (ComPO)
    Nil,;               // [14] N Tamanho maximo da maior opção do comPO
    Nil,;               // [15] C Inicializador de Browse
    Nil,;               // [16] L Indica se o campo é virtual
    Nil,;               // [17] C Picture Variavel
    Nil)                // [18] L Indica pulo de linha após o campo

oStTmp:AddField(;
    "Loja",;            // [01] C Nome do Campo
    "09",;              // [02] C Ordem
    "Loja",;            // [03] C Titulo do campo
    "Loja",;            // [04] C Descricao do campo
    Nil,;               // [05] A Array com Help
    "C",;               // [06] C Tipo do campo
    "@!",;              // [07] C Picture
    Nil,;               // [08] B Bloco de PictTre Var
    Nil,;               // [09] C Consulta F3
    .F.,;               // [10] L Indica se o campo é alteravel
    Nil,;               // [11] C Pasta do campo
    Nil,;               // [12] C Agrupamento do campo
    Nil,;               // [13] A Lista de valores permitido do campo (ComPO)
    Nil,;               // [14] N Tamanho maximo da maior opção do comPO
    Nil,;               // [15] C Inicializador de Browse
    Nil,;               // [16] L Indica se o campo é virtual
    Nil,;               // [17] C Picture Variavel
    Nil)                // [18] L Indica pulo de linha após o campo

oStTmp:AddField(;
    "UF",;              // [01] C Nome do Campo
    "10",;              // [02] C Ordem
    "UF",;              // [03] C Titulo do campo
    "UF",;              // [04] C Descricao do campo
    Nil,;               // [05] A Array com Help
    "C",;               // [06] C Tipo do campo
    "@!",;              // [07] C Picture
    Nil,;               // [08] B Bloco de PictTre Var
    Nil,;               // [09] C Consulta F3
    .F.,;               // [10] L Indica se o campo é alteravel
    Nil,;               // [11] C Pasta do campo
    Nil,;               // [12] C Agrupamento do campo
    Nil,;               // [13] A Lista de valores permitido do campo (ComPO)
    Nil,;               // [14] N Tamanho maximo da maior opção do comPO
    Nil,;               // [15] C Inicializador de Browse
    Nil,;               // [16] L Indica se o campo é virtual
    Nil,;               // [17] C Picture Variavel
    Nil)                // [18] L Indica pulo de linha após o campo
    
oStTmp:AddField(;
    "Nome",;            // [01] C Nome do Campo
    "11",;              // [02] C Ordem
    "Nome",;            // [03] C Titulo do campo
    "Nome",;            // [04] C Descricao do campo
    Nil,;               // [05] A Array com Help
    "C",;               // [06] C Tipo do campo
    "@!",;              // [07] C Picture
    Nil,;               // [08] B Bloco de PictTre Var
    Nil,;               // [09] C Consulta F3
    .F.,;               // [10] L Indica se o campo é alteravel
    Nil,;               // [11] C Pasta do campo
    Nil,;               // [12] C Agrupamento do campo
    Nil,;               // [13] A Lista de valores permitido do campo (ComPO)
    Nil,;               // [14] N Tamanho maximo da maior opção do comPO
    Nil,;               // [15] C Inicializador de Browse
    Nil,;               // [16] L Indica se o campo é virtual
    Nil,;               // [17] C Picture Variavel
    Nil)                // [18] L Indica pulo de linha após o campo
    
oStTmp:AddField(;
    "CNPJ",;            // [01] C Nome do Campo
    "12",;              // [02] C Ordem
    "CNPJ",;            // [03] C Titulo do campo
    "CNPJ",;            // [04] C Descricao do campo
    Nil,;               // [05] A Array com Help
    "C",;               // [06] C Tipo do campo
    "@!",;              // [07] C Picture
    Nil,;               // [08] B Bloco de PictTre Var
    Nil,;               // [09] C Consulta F3
    .F.,;               // [10] L Indica se o campo é alteravel
    Nil,;               // [11] C Pasta do campo
    Nil,;               // [12] C Agrupamento do campo
    Nil,;               // [13] A Lista de valores permitido do campo (ComPO)
    Nil,;               // [14] N Tamanho maximo da maior opção do comPO
    Nil,;               // [15] C Inicializador de Browse
    Nil,;               // [16] L Indica se o campo é virtual
    Nil,;               // [17] C Picture Variavel
    Nil)                // [18] L Indica pulo de linha após o campo

oStTmp:AddField(;
    "DT_IMP",;          // [01] C Nome do Campo
    "13",;              // [02] C Ordem
    "DT_IMP",;          // [03] C Titulo do campo
    "DT_IMP",;          // [04] C Descricao do campo
    Nil,;               // [05] A Array com Help
    "D",;               // [06] C Tipo do campo
    "@D",;              // [07] C Picture
    Nil,;               // [08] B Bloco de PictTre Var
    Nil,;               // [09] C Consulta F3
    .F.,;               // [10] L Indica se o campo é alteravel
    Nil,;               // [11] C Pasta do campo
    Nil,;               // [12] C Agrupamento do campo
    Nil,;               // [13] A Lista de valores permitido do campo (ComPO)
    Nil,;               // [14] N Tamanho maximo da maior opção do comPO
    Nil,;               // [15] C Inicializador de Browse
    Nil,;               // [16] L Indica se o campo é virtual
    Nil,;               // [17] C Picture Variavel
    Nil)                // [18] L Indica pulo de linha após o campo
    
//Criando a view que será o retorno da função e setando o modelo da rotina
oView := FWFormView():New()
oView:SetModel(oModel)
     
//Atribuindo formulários para interface
oView:AddField("VIEW_TMP", oStTMP, "FORMTMP")
     
//Criando um container com nome tela com 100%
oView:CreateHorizontalPOx("TELA",100)
     
//Colocando título do formulário
oView:EnableTitleView('VIEW_TMP', 'Dados - '+cTitulo )  
     
//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})
     
//O formulário da interface será colocado dentro do container
oView:SetOwnerView("VIEW_TMP","TELA")

Return oView
