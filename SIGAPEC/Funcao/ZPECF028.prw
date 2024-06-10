#Include 'FWMVCDef.ch'
#Include "rwmake.Ch"
#Include "TBICONN.CH"
#Include "FWBROWSE.CH"   
#Include "PROTHEUS.CH"
#Include "totvs.ch"
 
/*/{Protheus.doc} zTmpCadBO
Exemplo de Modelo 1 com tabela temporária
@author A.Carlos
@since 16/09/2022
@version 1.0
    @return Nil, Função não tem retorno Gerenciamento de BOs
    @example
/*/
 
User Function ZPECF028(_cProduto)
    Local aArea        := GetArea()
    Local cFunBkp      := FunName()
    Local oBrowse
    Local oDlg
    Local nOpca        := 0
    Local aSeek        := {}
    Local aFieFilter   := {}
    Local aPergs 	   := {}
    Local cProd        := Space(23)
    Local cBO          := Space(20)

    
    Private nOrder     As Numeric   //Order
    Private lRet       := .T.
    Private aRetP 	   := {}
    Private afields    := {}
    Private cAliasTmp  := "TMP"
    Private cTitulo	   := "Gerenciamento de BOs"
    Private aRotina    := MenuDef() 

    IF !( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
	    RETURN Nil
	ENDIF

    IF Empty(_cProduto)    
        aAdd( aPergs ,{1,"Informe o Produto ",cProd     ,"@!" , ""  , "SB1","", 100,.F. })

        IF Empty(cProd)
            aAdd( aPergs ,{1,"Informe Pedido Web ",cBO  ,"@!" , ""  , "SW8","", 100,.F. })
        ENDIF

        If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 

            DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi(cTitulo) PIXEL
            @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
            @ 29, 15 SAY OemToAnsi("Esta rotina realiza a análise de ítens") SIZE 268, 8 OF oDlg PIXEL
            @ 38, 15 SAY OemToAnsi("Da Caoa Barueri.") SIZE 268, 8 OF oDlg PIXEL
            @ 48, 15 SAY OemToAnsi("Confirma Geração da Documento?") SIZE 268, 8 OF oDlg PIXEL
            DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
            DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
            ACTIVATE MSDIALOG oDlg CENTER

        Endif

    ELSE

        Aadd(aRetP,_cProduto)
        Aadd(aRetP,Space(10))

    ENDIF

    If type("nOpc") == "U"
        nOpc := 2
    EndIf

    If Len(aRetP) == 0
        Return Nil
    ENDIF
    //oPanel:= tPanel():New(01,01,"Teste",oDlg024,oTFont,.T.,,CLR_YELLOW,CLR_BLUE,100,100)
	//--Monta temporaria
	zTmpInv()

    IF lRet = .T.

        //FWExecView (cTitulo, "ZPECF028", MODEL_OPERATION_VIEW ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ , /*cOperatId*/ ,/*cToolBar*/,/*oModelAct*/)
        //Irei criar a pesquisa que será apresentada na tela
        aAdd(aSeek,{"Item"	    ,{{ ""  ,"C"    ,023    ,000    ,"Item"    ,"@!"   }} } )
        aAdd(aSeek,{"Ped_Web"	,{{ ""  ,"C"    ,008    ,000    ,"BO"      ,"@!"   }} } )
    
        //Campos que irão compor a tela de filtro
        Aadd(aFieFilter,{   "TR_ITEM"	    ,"Produto"   ,"C" ,008    ,000    ,"@!" } )
        //Aadd(aFieFilter,{   "TR_FORNECE"	,"Fornecedor"  ,"C" ,006    ,000    ,"@!" } )

        oBrowse := FWMBrowse():New()
        oBrowse:SetMenuDef('ZPECF028')
        oBrowse:SetAlias(cAliasTmp)
        oBrowse:SetDescription(cTitulo)
        //oBrowse:SetAmbiente(.T.)
        oBrowse:SetTemporary()
        oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
        oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse  Bloqueio Crédito
        oBrowse:AddLegend( "STATUS=='Z'"   , "BR_AZUL"     , "Separação e Conferência"          )  
        oBrowse:AddLegend( "STATUS=='0'"   , "BR_VERDE"    , "Orçamento Digitado"               ) 
        oBrowse:AddLegend( "STATUS=='3'"   , "BR_BRANCO"   , "Avaliação de Crédito"             ) 
        oBrowse:AddLegend( "STATUS=='5'"   , "BR_MARROM"   , "Aguardando Lib.Diverg."           ) 
        oBrowse:AddLegend( "STATUS $ 'RT'" , "BR_CINZA"    , "Aguardando Reserva/Transferência" ) 
        oBrowse:AddLegend( "STATUS=='F'"   , "BR_AMARELO"  , "Liberado p/ Faturamento"          ) 
        oBrowse:AddLegend( "STATUS=='X'"   , "BR_PRETO"    , "Faturado"                         )
        oBrowse:AddLegend( "STATUS=='C'"   , "BR_VERMELHO" , "Cancelado"                        )
 
        oBrowse:DisableReport(.F.)
        oBrowse:DisableDetails()

        aAdd(afields, {"Status"             ,"Status"    ,"C"  ,001 ,0 ,"@!" })
    	aAdd(afields, {"Desc.Status"        ,"DsStatus"  ,"C"  ,030 ,0 ,"@!" }) 
        aAdd(afields, {"Filial"             ,"Filial"    ,"C"  ,010 ,0 ,"@!" }) 
        aAdd(afields, {"Emissao"            ,"Emissao"   ,"D"  ,010 ,0 ,"@D" })
        aAdd(afields, {"Marca"              ,"Marca"     ,"C"  ,003 ,0 ,"@!" })        
        aAdd(afields, {"Item"               ,"Item"      ,"C"  ,023 ,0 ,"@!" })
        aAdd(afields, {"Descricao"          ,"Descricao" ,"C"  ,060 ,0 ,"@!" })

        //aAdd(afields, {"Item Alternativo"   ,"Item_Simil" ,"C"  ,023 ,0 ,"@!" })
        //aAdd(afields, {"Descrição"          ,"Desc_Simil" ,"C"  ,060 ,0 ,"@!" })
        
        aAdd(afields, {"Pedido Web"         ,"Ped_Web"    ,"C"  ,020 ,0 ,"@!" })
        aAdd(afields, {"Qtde.Pedido Web"    ,"Total_Ped"  ,"N"  ,010 ,2 ,"@E 9,999,999.99" })
        aAdd(afields, {"Qtde.Atendida"      ,"Qtde_Atend" ,"N"  ,010 ,2 ,"@E 9,999,999.99" })
        aAdd(afields, {"Qtde.B.O"           ,"Qtde_Ped"   ,"N"  ,010 ,2 ,"@E 9,999,999.99" })
        
        //aAdd(afields, {"Qtde.Solicitada"    ,"Qtde_Inici" ,"N"  ,010 ,2 ,"@E 9,999,999.99" })
        //aAdd(afields, {"QTDE_TOTAL_CON","Emissao"     ,"N"  ,010 ,2 ,"@E 9,999,999.99" })        
        aAdd(afields, {"Cliente"            ,"Cliente"     ,"C"  ,006 ,0 ,"@!" })
        aAdd(afields, {"Loja"               ,"Loja"        ,"C"  ,002 ,0 ,"@!" })
        aAdd(afields, {"Cnpj"   	        ,"Cnpj"        ,"C"  ,014 ,0 ,"@!" })        
        aAdd(afields, {"Nome"	            ,"Nome"        ,"C"  ,020 ,0 ,"@!" })
        aAdd(afields, {"UF"   	            ,"UF"          ,"C"  ,002 ,0 ,"@!" }) 
        aAdd(afields, {"Cond.Pagamento"     ,"Cond_Pag"    ,"C"  ,015 ,0 ,"@!" }) 
        aAdd(afields, {"Transp"             ,"Transp"      ,"C"  ,020 ,0 ,"@!" })               

        oBrowse:SetFields(afields) 

        oBrowse:Activate()

    ENDIF

    SetFunName(cFunBkp)
    RestArea(aArea)
Return Nil
 

 /*
=====================================================================================
Programa.:              zTmpInv
Autor....:              CAOA - A. Carlos
Data.....:              16/09/2022
Descricao / Objetivo:   Monta temporaria invoices     
=====================================================================================
*/
Static Function zTmpInv(lJob)
    Local _cQ           := " "
    Local _xDsStatus    := " "
	Local aCampos       := {}
	Local oTempInv	    := Nil
    Local _cAliasBO     := GetNextAlias()
    Local _cDel         := Space(1)
	Default lJob		:= .F.	

    If Select( _cAliasBO ) > 0
		( _cAliasBO )->( DbCloseArea() )
	EndIf

    _cQ := " "
        
    _cQ += CRLF + "  SELECT  TMP.FILIAL "
    _cQ += CRLF + "        ,TMP.STATUS "
    _cQ += CRLF + "        ,TMP.EMISSAO "
    _cQ += CRLF + "        ,TMP.MARCA "
    _cQ += CRLF + "        ,TMP.ITEM "
    _cQ += CRLF + "        ,TMP.DESCRICAO "
    _cQ += CRLF + "        ,TMP.ITEM_SIMILAR "
    _cQ += CRLF + "        ,TMP.PED_WEB "
    _cQ += CRLF + "        ,SUM(TMP.QTDE_PED) AS QTDE_PED "
    _cQ += CRLF + "        ,TMP.QTDE_ATEND "
    _cQ += CRLF + "        ,SUM(TMP.QTDE_INICIAL) AS QTDE_INICIAL "
    _cQ += CRLF + "        ,(SUM(TMP.QTDE_PED)+TMP.QTDE_ATEND) AS TOTAL_PED "
    //_cQ += CRLF + "        ,TMP.QTDE_TOTAL_CON "
    _cQ += CRLF + "        ,TMP.CLIENTE "
    _cQ += CRLF + "        ,TMP.LOJA "
    _cQ += CRLF + "        ,TMP.CNPJ "
    _cQ += CRLF + "        ,TMP.NOME "
    _cQ += CRLF + "        ,TMP.UF "
    _cQ += CRLF + "        ,TMP.COND_PGTO "
    _cQ += CRLF + "        ,TMP.TRANSP "

    //_cQ += CRLF + "        --,TMP.ORCAMENTO "
    //_cQ += CRLF + "        --,TMP.ORC_ORIG "
    //_cQ += CRLF + "        --,TMP.AGLU "
    //_cQ += CRLF + "        --,TMP.PEDIDO "
    //_cQ += CRLF + "        --,TMP.DATA_ORC "
    //_cQ += CRLF + "        --,TMP.DIAS "
    //_cQ += CRLF + "        --,TMP.RECEBIMENTO "

    _cQ += CRLF + "    FROM (     "
    _cQ += CRLF + "        SELECT "
    _cQ += CRLF + "            VS1.VS1_FILIAL AS FILIAL "
    _cQ += CRLF + "            ,VS1.VS1_STATUS AS STATUS "
    _cQ += CRLF + "            ,VS1.VS1_DATORC AS EMISSAO "
    _cQ += CRLF + "            ,VS1.VS1_XMARCA AS MARCA "
    _cQ += CRLF + "            ,VS3.VS3_XITSUB AS ITEM "
    _cQ += CRLF + "            ,SB1.B1_DESC    AS DESCRICAO "
    _cQ += CRLF + "            ,VS3.VS3_CODITE AS ITEM_SIMILAR "
    _cQ += CRLF + "            ,VS1.VS1_XPVAW  AS PED_WEB "
    _cQ += CRLF + "            ,VS1.VS1_XDESMB AS ORC_ORIG "
    _cQ += CRLF + "            ,VS1.VS1_XAGLU  AS AGLU "
    _cQ += CRLF + "            ,VS1.VS1_NUMORC AS ORCAMENTO "

    _cQ += CRLF + "            ,(SELECT SUBSTR(VX5_DESCRI,1,20) "
    _cQ += CRLF + "                    FROM " + RetSQLname("VX5") + " VX5 "
    _cQ += CRLF + "                        WHERE VX5.VX5_CHAVE = 'Z00' "
    _cQ += CRLF + "                            AND VX5.VX5_CODIGO =  VS1.VS1_XTPPED "
    _cQ += CRLF + "                            AND VX5.D_E_L_E_T_ = '" + _cDel + "') AS PEDIDO "

    _cQ += CRLF + "            ,(SELECT SUBSTR(VX5_DESCRI, 1, 20) "
    _cQ += CRLF + "                    FROM " + RetSQLname("VX5") + " VX5T "
    _cQ += CRLF + "                        WHERE VX5T.VX5_CHAVE = 'Z01' "
    _cQ += CRLF + "                            AND VX5T.VX5_CODIGO = VS1.VS1_XTPTRA "
    _cQ += CRLF + "                            AND VX5T.D_E_L_E_T_ = '" + _cDel + "') AS TRANSP "

    _cQ += CRLF + "            ,SA1.A1_COD     AS CLIENTE "
    _cQ += CRLF + "            ,SA1.A1_LOJA    AS LOJA "
    _cQ += CRLF + "            ,SA1.A1_CGC     AS CNPJ "
    _cQ += CRLF + "            ,SA1.A1_NREDUZ  AS NOME "
    _cQ += CRLF + "            ,SA1.A1_EST     AS UF "
    _cQ += CRLF + "            ,VS1.VS1_XDTIMP AS DATA_ORC "
    _cQ += CRLF + "            ,SE4.E4_DESCRI  AS COND_PGTO "
    _cQ += CRLF + "            ,TO_CHAR((ROUND(SYSDATE)-TO_DATE(VS1.VS1_XDTIMP,'YYYYMMDD')),'999') AS DIAS "
    _cQ += CRLF + "            ,VS3.VS3_QTDITE AS QTDE_PED "
    _cQ += CRLF + "            ,VS3.VS3_QTDINI AS QTDE_INICIAL "
    //_cQ += CRLF + "            ,VS3.VS3_QTDCON AS QTDE_TOTAL_CON "

    _cQ += CRLF + "            ,COALESCE((SELECT SUM(VS3ATE.VS3_QTDITE) AS QTDE_ATEND  "
    _cQ += CRLF + "                     FROM " + RetSQLname("VS3") + " VS3ATE "
    _cQ += CRLF + "                          INNER JOIN " + RetSQLname("VS1") + " VS1ATE              "
    _cQ += CRLF + "                                ON  VS1ATE.VS1_FILIAL  = VS3ATE.VS3_FILIAL  "
    _cQ += CRLF + "                                AND VS1ATE.VS1_NUMORC  = VS3ATE.VS3_NUMORC "
    _cQ += CRLF + "                                AND VS1ATE.VS1_STATUS NOT IN ('0','2','3','C')  "
    _cQ += CRLF + "                                AND VS1ATE.D_E_L_E_T_  = '" + _cDel + "'  "
    _cQ += CRLF + "                        WHERE    VS3ATE.D_E_L_E_T_ = '" + _cDel + "'  "
    _cQ += CRLF + "                             AND VS1ATE.VS1_XDESMB = VS1.VS1_XDESMB  "
    _cQ += CRLF + "                             AND VS3ATE.VS3_XITSUB = VS3.VS3_XITSUB  "
    _cQ += CRLF + "                        ),0) AS QTDE_TOTAL "

    _cQ += CRLF + "            ,COALESCE((SELECT SUM(VS3AT.VS3_QTDCON) AS QTDE_CON  "
    _cQ += CRLF + "                        FROM " + RetSQLname("VS3") + " VS3AT "
    _cQ += CRLF + "                            INNER JOIN " + RetSQLname("VS1") + " VS1AT              "
    _cQ += CRLF + "                                ON  VS1AT.VS1_FILIAL  = VS3AT.VS3_FILIAL  "
    _cQ += CRLF + "                                AND VS1AT.VS1_NUMORC  = VS3AT.VS3_NUMORC "
    _cQ += CRLF + "                                AND VS1AT.VS1_STATUS NOT IN ('0','2','3','C')  "
    _cQ += CRLF + "                                AND VS1AT.D_E_L_E_T_   = '" + _cDel + "'  "
    _cQ += CRLF + "                        WHERE  VS3AT.D_E_L_E_T_ = '" + _cDel + "'  "
    _cQ += CRLF + "                           AND VS1AT.VS1_XPVAW  = VS1.VS1_XPVAW  "
    _cQ += CRLF + "                           AND VS3AT.VS3_XITSUB = VS3.VS3_XITSUB "
    _cQ += CRLF + "                        ),0) AS QTDE_ATEND  "

    _cQ += CRLF + "            ,SB2.B2_QATU    AS ESTOQUE "

    _cQ += CRLF + "            ,(SELECT B2_QATU FROM " + RetSQLname("SB2") + " B2 WHERE   B2.B2_FILIAL  = VS3.VS3_FILIAL "
    _cQ += CRLF + "                            AND B2.B2_COD     = VS3.VS3_XITSUB "
    _cQ += CRLF + "                            AND B2.B2_LOCAL   = '80' "
    _cQ += CRLF + "                            AND B2.D_E_L_E_T_ = '" + _cDel + "') AS RECEBIMENTO "
    _cQ += CRLF + "                FROM " + RetSQLname("VS3") + " VS3 "

    _cQ += CRLF + "                    INNER JOIN " + RetSQLname("VS1") + " VS1 "
    _cQ += CRLF + "                         ON VS1.VS1_FILIAL = VS3.VS3_FILIAL "
    _cQ += CRLF + "                        AND VS1.VS1_NUMORC = VS3.VS3_NUMORC "
    _cQ += CRLF + "                        AND VS1.VS1_XDTIMP <> ' ' "
    _cQ += CRLF + "                        AND VS1.D_E_L_E_T_ = '" + _cDel + "' "

    _cQ += CRLF + "                    INNER JOIN " + RetSQLname("SA1") + " SA1 "
    _cQ += CRLF + "                         ON SA1.A1_FILIAL  = '" + xFilial("SA1")  + "' "
    _cQ += CRLF + "                        AND SA1.A1_COD     = VS1.VS1_CLIFAT "
    _cQ += CRLF + "                        AND SA1.A1_LOJA    = VS1.VS1_LOJA "
    _cQ += CRLF + "                        AND SA1.D_E_L_E_T_ = '" + _cDel + "' "

    _cQ += CRLF + "                    INNER JOIN " + RetSQLname("SB1") + " SB1 "
    _cQ += CRLF + "                         ON SB1.B1_FILIAL  = '" + xFilial("SB1")  + "' "
    _cQ += CRLF + "                        AND SB1.B1_COD     = VS3.VS3_XITSUB "
    _cQ += CRLF + "                        AND SB1.D_E_L_E_T_ = '" + _cDel + "' "

    _cQ += CRLF + "                    LEFT JOIN " + RetSQLname("SB2") + " SB2 "
    _cQ += CRLF + "                         ON SB2.B2_FILIAL  = VS3.VS3_FILIAL "
    _cQ += CRLF + "                        AND SB2.B2_COD     = VS3.VS3_XITSUB "
    _cQ += CRLF + "                        AND SB2.B2_LOCAL   = '01' "
    _cQ += CRLF + "                        AND SB2.D_E_L_E_T_ = '" + _cDel + "' "

    _cQ += CRLF + "                    LEFT JOIN " + RetSQLname("SE4") + " SE4 "
    _cQ += CRLF + "                         ON SE4.E4_FILIAL  =  '          ' "
    _cQ += CRLF + "                        AND SE4.E4_CODIGO  = VS1.VS1_FORPAG "
    _cQ += CRLF + "                        AND SE4.D_E_L_E_T_ = '" + _cDel + "' "

    _cQ += CRLF + "                    WHERE "
    _cQ += CRLF + "                            VS3.VS3_FILIAL = '" + xFilial("SV3")  + "' "
    _cQ += CRLF + "                        AND VS1.VS1_XBO = 'S' "
    _cQ += CRLF + "                        AND VS1.VS1_STATUS IN ('0','3') "
    
    IF aRetP[01] <> "   "
        //_cQ += CRLF + "    AND (VS3.VS3_CODITE = '" + aRetP[01] + "'  OR   VS3.VS3_XITSUB = '" + aRetP[01] + "')"
        _cQ += CRLF + "    AND   VS3.VS3_XITSUB = '" + aRetP[01] + "'"
    ENDIF

    IF aRetP[02] <> "   "
        _cQ +=  CRLF + "    AND VS1.VS1_XPVAWC = '" + aRetP[02] + "'"
    ENDIF

    _cQ += CRLF + "                        AND VS3.D_E_L_E_T_ = '" + _cDel + "' "

    _cQ += CRLF + "                ORDER BY VS1.VS1_XPVAW "

    _cQ += CRLF + "            ) TMP "

    _cQ += CRLF + "            Group by "

    _cQ += CRLF + "             TMP.FILIAL "
    _cQ += CRLF + "            ,TMP.STATUS "
    _cQ += CRLF + "            ,TMP.EMISSAO "
    _cQ += CRLF + "            ,TMP.MARCA "
    _cQ += CRLF + "            ,TMP.ITEM "
    _cQ += CRLF + "            ,TMP.DESCRICAO "
    _cQ += CRLF + "            ,TMP.ITEM_SIMILAR "
    _cQ += CRLF + "            ,TMP.PED_WEB "
    _cQ += CRLF + "            ,TMP.CNPJ "
    _cQ += CRLF + "            ,TMP.NOME "
    _cQ += CRLF + "            ,TMP.UF "
    _cQ += CRLF + "            ,TMP.COND_PGTO "
    _cQ += CRLF + "            ,TMP.QTDE_ATEND "
    _cQ += CRLF + "            ,TMP.QTDE_TOTAL "
    //_cQ += CRLF + "            ,TMP.QTDE_TOTAL_CON "
    _cQ += CRLF + "            ,TMP.TRANSP "
    _cQ += CRLF + "            ,TMP.RECEBIMENTO "
    _cQ += CRLF + "            ,TMP.CLIENTE "
    _cQ += CRLF + "            ,TMP.LOJA "
    
    _cQ += CRLF + "        ORDER BY PED_WEB "  
    
    dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQ),_cAliasBO, .T., .T. ) 

    nOrder := 01

	(_cAliasBO)->(DbGoTop())
	IF (_cAliasBO)->(!EOF())
		//VS1->( dbGoto( (_cAliasBO)->RECVS1ATE ))     // posiciona o registro
		_lExist := .T.
    ELSE
        lRet := .F.
        MsgInfo("Item ou BO não encontrado! ", "[ ZPECF028 ] - Aviso" )
		Return(lRet)
    EndIf

		//Se o alias estiver aberto, fechar para evitar erros com alias aberto
		If (Select(cAliasTmp) <> 0)
			dbSelectArea(cAliasTmp)
			(cAliasTmp)->(dbCloseArea())
		EndIf

		oTempInv := FWTemporaryTable():New(cAliasTmp)
    	
        aAdd(aCampos, {"Status"         ,"C"  ,001 ,0  })
        aAdd(aCampos, {"DsStatus"       ,"C"  ,030 ,0  })
        aAdd(aCampos, {"Filial"         ,"C"  ,010 ,0  })
        aAdd(aCampos, {"Marca"          ,"C"  ,003 ,0  })
        aAdd(aCampos, {"Emissao"        ,"D"  ,010 ,0  })
        aAdd(aCampos, {"Item"           ,"C"  ,023 ,0  })
        aAdd(aCampos, {"Descricao"      ,"C"  ,060 ,0  })
        //aAdd(aCampos, {"Item_Simil"     ,"C"  ,023 ,0  })
        //aAdd(aCampos, {"Desc_Simil"     ,"C"  ,060 ,0  })
        aAdd(aCampos, {"Ped_Web"        ,"C"  ,020 ,0  })
        aAdd(aCampos, {"Qtde_Ped"       ,"N"  ,010 ,2  })
        aAdd(aCampos, {"Qtde_Atend"     ,"N"  ,010 ,2  })
        //aAdd(aCampos, {"Qtde_Inici"     ,"N"  ,010 ,2  })
        aAdd(aCampos, {"Total_Ped" 	    ,"N"  ,010 ,2  })
        aAdd(aCampos, {"Cliente"        ,"C"  ,006 ,0  })
        aAdd(aCampos, {"Loja"           ,"C"  ,002 ,0  })
        aAdd(aCampos, {"Cnpj"   	    ,"C"  ,014 ,0  })
        aAdd(aCampos, {"Nome"	        ,"C"  ,020 ,0  })
        aAdd(aCampos, {"UF"   	        ,"C"  ,002 ,0  })
        aAdd(aCampos, {"Cond_Pag"       ,"C"  ,015 ,0  })
        aAdd(aCampos, {"Transp"         ,"C"  ,020 ,0  })

		oTempInv:SetFields( aCampos )
		oTempInv:AddIndex( "01", { "Item"    } )
		oTempInv:AddIndex( "02", { "Ped_Web" } )
		oTempInv:Create()

	While (_cAliasBO)->(!Eof())

        Do CASE
            CASE (_cAliasBO)->STATUS=='Z'
                _xDsStatus := "Separação e Conferência"
            CASE (_cAliasBO)->STATUS=='0'
                _xDsStatus := "Orçamento Digitado"
            CASE (_cAliasBO)->STATUS=='3'
                _xDsStatus := "Avaliação de Crédito"
            CASE (_cAliasBO)->STATUS=='5'
                _xDsStatus := "Aguardando Lib.Diverg."
            CASE (_cAliasBO)->STATUS $ 'RT'
                _xDsStatus := "Aguardando Reserva/Transferência"
            CASE (_cAliasBO)->STATUS=='F'
                _xDsStatus := "Liberado p/ Faturamento"
            CASE (_cAliasBO)->STATUS=='X'
                _xDsStatus := "Faturado"
            CASE (_cAliasBO)->STATUS=='C'
                _xDsStatus := "Cancelado"
        ENDCASE        

        If RecLock(cAliasTmp,.T.)
            (cAliasTmp)->Status     := (_cAliasBO)->Status
            (cAliasTmp)->DsStatus   := _xDsStatus
            (cAliasTmp)->Filial     := (_cAliasBO)->Filial
            (cAliasTmp)->Emissao    := Stod((_cAliasBO)->Emissao)
            (cAliasTmp)->Marca      := (_cAliasBO)->Marca

            //if alltrim(aRetP[01]) <> alltrim((_cAliasBO)->Item_Simil)
                (cAliasTmp)->Item       := (_cAliasBO)->Item
                (cAliasTmp)->Descricao  := (_cAliasBO)->Descricao
            //    (cAliasTmp)->Item_Simil := (_cAliasBO)->Item_Simil
            //    (cAliasTmp)->Desc_Simil := posicione('SB1',1,SubStr((_cAliasBO)->Filial,1,6)+SPACE(4)+(_cAliasBO)->ITEM_SIMIL,'B1_DESC')
            //Else
            //    (cAliasTmp)->Item       := (_cAliasBO)->Item_Simil
            //    (cAliasTmp)->Descricao  := posicione('SB1',1,SubStr((_cAliasBO)->Filial,1,6)+SPACE(4)+(_cAliasBO)->ITEM_SIMIL,'B1_DESC')
            //    (cAliasTmp)->Item_Simil := (_cAliasBO)->Item
            //    (cAliasTmp)->Desc_Simil := (_cAliasBO)->Descricao
            //EndIf

            (cAliasTmp)->Ped_Web    := (_cAliasBO)->Ped_Web
            (cAliasTmp)->Qtde_Ped   := (_cAliasBO)->Qtde_Ped
            (cAliasTmp)->Qtde_Atend := (_cAliasBO)->Qtde_Atend
            //(cAliasTmp)->Qtde_Inici := (_cAliasBO)->Qtde_Inici
            (cAliasTmp)->Total_Ped  := (_cAliasBO)->Total_Ped
            (cAliasTmp)->Cliente    := (_cAliasBO)->Cliente
            (cAliasTmp)->Loja       := (_cAliasBO)->Loja
            (cAliasTmp)->Cnpj       := (_cAliasBO)->Cnpj
            (cAliasTmp)->Nome       := (_cAliasBO)->Nome
            (cAliasTmp)->UF         := (_cAliasBO)->UF
            (cAliasTmp)->Cond_Pag   := (_cAliasBO)->Cond_Pgto
            (cAliasTmp)->Transp     := (_cAliasBO)->Transp
                        
                      
            (cAliasTmp)->(MsUnLock())
        EndIf

        nOrder ++

        (_cAliasBO)->(DbSkip())
    
    EndDo

    (_cAliasBO)->(DbCloseArea())

    Return(lRet)

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
Local aRot := {} 

    //Adicionando opções
    ADD OPTION aRot TITLE 'Consulta Tela' ACTION 'VIEWDEF.ZPECF028' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Exportar'      ACTION 'U_ZXMLGEM()'      OPERATION 9                      ACCESS 0 //OPERATION 4
    //ADD OPTION aRot TITLE "Legenda" ACTION "U_LEGEN()" OPERATION 9 ACCESS 0
    //ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zTmpCadBO' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    //ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zTmpCadBO' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    //ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zTmpCadBO' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot

 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
    Local aCampos := {}
    Local nX := 1
    Local aCab := {}
    //Criação da estrutura de dados utilizada na interface
    Local oStTMP := FWFormModelStruct():New()
       aCab := {    "Status"    ,"DsStatus"  ,"Filial"   ,"Marca"  ,"Emissao","Item","Descricao",; //"Item_Simil","Desc_Simil","Qtde_Inici",;
                    "Ped_Web","Qtde_Ped",;
                    "Qtde_Atend","Total_Ped","Cliente","Loja"   ,"Cnpj","Nome"     ,"UF"        ,"Cond_Pag"  ,"Transp" }

        aAdd(aCampos, {"Status"     ,"Status"     ,"Status"      ,"C"  ,001 ,0 ,NIl ,Nil ,{} ,.F. ,"Status"     , .T. , .F. , .F.  })
        aAdd(aCampos, {"DsStatus"   ,"DsStatus"   ,"DsStatus"    ,"C"  ,030 ,0 ,NIl ,Nil ,{} ,.F. ,"DsStatus"   , .T. , .F. , .F.  })
        aAdd(aCampos, {"Filial"     ,"Filial"     ,"Filial"      ,"C"  ,010 ,0 ,NIl ,Nil ,{} ,.F. ,"Filial"     , .T. , .F. , .F.  })
        aAdd(aCampos, {"Ped_Web"    ,"Ped_Web"    ,"Ped_Web"     ,"C"  ,020 ,0 ,NIl ,Nil ,{} ,.F. ,"Ped_Web"    , .T. , .F. , .F.  })
        aAdd(aCampos, {"Marca"      ,"Marca"      ,"Marca"       ,"C"  ,003 ,0 ,NIl ,Nil ,{} ,.F. ,"Marca"      , .T. , .F. , .F.  })
        aAdd(aCampos, {"Item"       ,"Item"       ,"Item"        ,"C"  ,023 ,0 ,NIl ,Nil ,{} ,.F. ,"Item"       , .T. , .F. , .F.  })
        aAdd(aCampos, {"Descricao"  ,"Descricao"  ,"Descricao"   ,"C"  ,060 ,0 ,NIl ,Nil ,{} ,.F. ,"Descricao"  , .T. , .F. , .F.  })
        //aAdd(aCampos, {"Item_Simil" ,"Item_Simil" ,"Item_Simil"  ,"C"  ,023 ,0 ,NIl ,Nil ,{} ,.F. ,"Item_Simil" , .T. , .F. , .F.  })
        //aAdd(aCampos, {"Desc_Simil" ,"Desc_Simil" ,"Desc_Simil"  ,"C"  ,060 ,0 ,NIl ,Nil ,{} ,.F. ,"Desc_Simil" , .T. , .F. , .F.  })
        aAdd(aCampos, {"Qtde.Pedido Web"  ,"Total_Ped"  ,"Total_Ped"   ,"N"  ,010 ,2 ,NIl ,Nil ,{} ,.F. ,"Total_Ped"  , .T. , .F. , .F.  })
        aAdd(aCampos, {"Qtde.Atendida"    ,"Qtde_Atend" ,"Qtde_Atend"  ,"N"  ,010 ,2 ,NIl ,Nil ,{} ,.F. ,"Qtde_Atend" , .T. , .F. , .F.  })
        aAdd(aCampos, {"Qtde.B.O"         ,"Qtde_Ped"   ,"Qtde_Ped"    ,"N"  ,010 ,2 ,NIl ,Nil ,{} ,.F. ,"Qtde_Ped"   , .T. , .F. , .F.  })
        //aAdd(aCampos, {"Qtde_Inici" ,"Qtde_Inici" ,"Qtde_Inici"  ,"N"  ,010 ,2 ,NIl ,Nil ,{} ,.F. ,"Qtde_Inici" , .T. , .F. , .F.  })
        aAdd(aCampos, {"Emissao"    ,"Emissao"    ,"Emissao"     ,"D"  ,010 ,0 ,NIl ,Nil ,{} ,.F. ,"Emissao"    , .T. , .F. , .F.  })
        aAdd(aCampos, {"Cliente"    ,"Cliente"    ,"Cliente"     ,"C"  ,006 ,0 ,NIl ,Nil ,{} ,.F. ,"Cliente"    , .T. , .F. , .F.  })
        aAdd(aCampos, {"Loja"       ,"Loja"       ,"Loja"        ,"C"  ,002 ,0 ,NIl ,Nil ,{} ,.F. ,"Loja"       , .T. , .F. , .F.  })
        aAdd(aCampos, {"Cnpj"       ,"Cnpj"       ,"Cnpj"        ,"C"  ,014 ,0 ,NIl ,Nil ,{} ,.F. ,"Cnpj"       , .T. , .F. , .F.  })
        aAdd(aCampos, {"Nome"       ,"Nome"       ,"Nome"        ,"C"  ,020 ,0 ,NIl ,Nil ,{} ,.F. ,"Nome"       , .T. , .F. , .F.  })
        aAdd(aCampos, {"UF"         ,"UF"         ,"UF"          ,"C"  ,002 ,0 ,NIl ,Nil ,{} ,.F. ,"UF"         , .T. , .F. , .F.  })
        aAdd(aCampos, {"Cond_Pag"   ,"Cond_Pag"   ,"Cond_Pag"    ,"C"  ,015 ,0 ,NIl ,Nil ,{} ,.F. ,"Cond_Pag"   , .T. , .F. , .F.  })
        aAdd(aCampos, {"Transp"     ,"Transp"     ,"Transp"      ,"C"  ,020 ,0 ,NIl ,Nil ,{} ,.F. ,"Transp"     , .T. , .F. , .F.  })

    oStTMP:AddTable(cAliasTmp, aCab , "Temporaria")

    //Adiciona os campos da estrutura
    For nX := 1 to Len(aCampos)
        oStTmp:AddField(;
                        aCampos[nX , 1 ],;                                                                                    // [01]  C   Titulo do campo
                        aCampos[nX , 2 ],;                                                                                    // [02]  C   ToolTip do campo
                        aCampos[nX , 3 ],;                                                                                    // [03]  C   Id do Field
                        aCampos[nX , 4 ],;                                                                                    // [04]  C   Tipo do campo
                        aCampos[nX , 5 ],;                                                                                    // [05]  N   Tamanho do campo
                        aCampos[nX , 6 ],;                                                                                    // [06]  N   Decimal do campo
                        aCampos[nX , 7 ],;                                                                                    // [07]  B   Code-block de validação do campo
                        aCampos[nX , 8 ],;                                                                                    // [08]  B   Code-block de validação When do campo
                        aCampos[nX , 9 ],;                                                                                    // [09]  A   Lista de valores permitido do campo
                        aCampos[nX ,10 ],;                                                                                    // [10]  L   Indica se o campo tem preenchimento obrigatório
                        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->" + aCampos[nX ,11 ] + ",'')" ),;  // [11]  B   Code-block de inicializacao do campo
                        aCampos[nX , 12 ],;                                                                                   // [12]  L   Indica se trata-se de um campo chave
                        aCampos[nX , 13 ],;                                                                                   // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                        aCampos[nX , 14 ])                                                                                    // [14]  L   Indica se o campo é virtual
    Next nX
            
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("zTmpCadBOM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMTMP",/*cOwner*/,oStTMP)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'Item'})
     
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
    Local oModel   := FWLoadModel("ZPECF028")
    Local oStTMP   := FWFormViewStruct():New()
    Local oView    := Nil
    Local aCampos  := {}
    Local nX := 1

    aAdd(aCampos, {"Status"     ,"01" ,"Status"            ,"Status"            ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"DsStatus"   ,"02" ,"Desc.tatus"        ,"Desc.Status"       ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Filial"     ,"03" ,"Filial"            ,"Filial"            ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Ped_Web"    ,"04" ,"Pedido Web"        ,"Pedido Web"        ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Marca"      ,"05" ,"Marca"             ,"Marca"             ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Item"       ,"06" ,"Item"              ,"Item"              ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Descricao"  ,"07" ,"Descricao"         ,"Descricao"         ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    //aAdd(aCampos, {"Item_Simil" ,"08" ,"Item Alternatrivo" ,"ItemAlternativo"   ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    //aAdd(aCampos, {"Desc_Simil" ,"09" ,"Descrição"         ,"Descrição"         ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Total_Ped"  ,"08" ,"Qtde.Pedido Web"   ,"Qtde.Pedido Web"   ,Nil ,"N"  ,"@E 9,999,999.99" ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Qtde_Atend" ,"09" ,"Qtde.Atendida"     ,"Qtde.Atendida"     ,Nil ,"N"  ,"@E 9,999,999.99" ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Qtde_Ped"   ,"10" ,"Qtde.B.O"          ,"Qtde.B.O."         ,Nil ,"N"  ,"@E 9,999,999.99" ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    //aAdd(aCampos, {"Qtde_Inici" ,"13" ,"Qtde.Inicial"      ,"Qtde.Inicial"      ,Nil ,"N"  ,"@E 9,999,999.99" ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Emissao"    ,"11" ,"Emissao"           ,"Emissao"           ,Nil ,"D"  ,"@D"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Cliente"    ,"12" ,"Cliente"           ,"Cliente"           ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Loja"       ,"13" ,"Loja"              ,"Loja"              ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Cnpj"       ,"14" ,"Cnpj"              ,"Cnpj"              ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Nome"       ,"15" ,"Nome"              ,"Nome"              ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"UF"         ,"16" ,"UF"                ,"UF"                ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Cond_Pag"   ,"17" ,"Cond.Pagamento"    ,"Cond.Pagamento"    ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Transp"     ,"18" ,"Transp"            ,"Transp"            ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })


    For nX := 1 to Len(aCampos)
        oStTmp:AddField(;
                    aCampos[nX, 01],;              // [01]  C   Nome do Campo
                    aCampos[nX, 02],;              // [02]  C   Ordem
                    aCampos[nX, 03],;              // [03]  C   Titulo do campo
                    aCampos[nX, 04],;              // [04]  C   Descricao do campo
                    aCampos[nX, 05],;              // [05]  A   Array com Help
                    aCampos[nX, 06],;              // [06]  C   Tipo do campo
                    aCampos[nX, 07],;              // [07]  C   Picture
                    aCampos[nX, 08],;              // [08]  B   Bloco de PictTre Var
                    aCampos[nX, 09],;              // [09]  C   Consulta F3
                    aCampos[nX, 10],;             // [10]  L   Indica se o campo é alteravel
                    aCampos[nX, 11],;             // [11]  C   Pasta do campo
                    aCampos[nX, 12],;             // [12]  C   Agrupamento do campo
                    aCampos[nX, 13],;             // [13]  A   Lista de valores permitido do campo (Combo)
                    aCampos[nX, 14],;             // [14]  N   Tamanho maximo da maior opção do combo
                    aCampos[nX, 15],;             // [15]  C   Inicializador de Browse
                    aCampos[nX, 16],;             // [16]  L   Indica se o campo é virtual
                    aCampos[nX, 17],;             // [17]  C   Picture Variavel
                    aCampos[nX, 18])              // [18]  L   Indica pulo de linha após o campo
    Next nX

    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_TMP", oStTMP, "FORMTMP")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_TMP', 'Dados - '+cTitulo )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_TMP","TELA")
Return oView



User Function ZXMLGEM()
Local cMascara := ""
Local cTitulo  := "Exportação de Arquivo"
Local nMascpad := 1
Local cDirIni  := "C:\"
Local lSalvar  := .F.
Local lArvore  := .F.

Private Destino := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOR( GETF_LOCALHARD, GETF_RETDIRECTORY,GETF_NETWORKDRIVE ), lArvore)
    
    if !Empty(Destino) 
	    Processa({|| U_ZXMLF028() }, "[ZXMLF028]", "Montando a planilha" )
	endif	

Return


User Function ZXMLF028()

	Local cFile		 := "BO" + ".xml"
	Local oExcelApp  := NIL
	Local oFWMsExcel := NIL
	Local i          := 1
    Local aCols      := {}
    Local cPlanilha  := "Produtos em BO"
    Local cTabela    := "Produtos"
	Local aTotal     := {}
    cFile := cPlanilha
	cFile += " - " + StrTran(Dtoc(Date()),'/','_', 1)
	cFile += " - " + StrTran(Time(),':','_', 1)
	cFile += ".xml"

	cDestino := GetTempPath()

	oFWMsExcel := FWMsExcelEx():New()

	oFWMsExcel:AddWorkSheet(cPlanilha)
	oFWMsExcel:AddTable(cPlanilha,cTabela)
    	
	For i := 1 To Len(afields)
		nAlign  := 1 // 1 - LEFT
		nFormat := 1 // 1 - GENERAL
		
        If afields[i,3] == "D"
			nAlign  := 2 // 2 - CENTER
			nFormat := 4 // 4 - DATE
			aadd(aTotal,"")
            
		ElseIf afields[i,3] == "N"
			nAlign  := 3 // 3 - RIGHT
			nFormat := 2 // 2 - NUMBER // 3 - MONEY
            aadd(aTotal,0)
		else
            aadd(aTotal,"")
        EndIf

		oFWMsExcel:AddColumn(cPlanilha,cTabela,aFields[i,1],nAlign,nFormat,.F.)
	Next i

	ProcRegua(Len(afields) +1)

    DbSelectArea(cAliasTmp)
    (cAliasTmp)->(DbGotop())
   
    While !(cAliasTmp)->(Eof())
        
        aCols:= {}
        
        For i := 1 To Len(afields)
            IncProc('Gerando Relatório da Consulta... linha: ' + StrZero(i,5) + " de " + StrZero(Len(afields),5) )
            If afields[i,3] == "D"
			    aadd(aCols ,Dtoc((cAliasTmp)->&(afields[i,2])))			//AEval(aCols,{|aItem| aItem[i] := Iif(Empty(aItem[i]),"",DtoC(aItem[i])) })
                
            else
                aadd(aCols,(cAliasTmp)->&(afields[i,2]))
                if afields[i,3] == "N"
                    aTotal[i] += (cAliasTmp)->&(afields[i,2])
                elseIf i == 8
                    aTotal[i] := "Totais"
                EndIf
            EndIf
        Next i
       
		oFWMsExcel:AddRow(cPlanilha,cTabela,aCols)
        (cAliasTmp)->(DbSkip())
    EndDo
	oFWMsExcel:AddRow(cPlanilha,cTabela,aTotal)
    IncProc("Abrindo arquivo gerado...")

	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cDestino + cFile)
	oFWMsExcel:DeActivate()
	FreeObj(oFWMsExcel)

	// ABRIR ARQUIVO GERADO
	If ApOleClient("MsExcel")
		// Abre o Arquivo direto no Excel
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cDestino + cFile )
		oExcelApp:SetVisible(.T.)
		oExcelApp:Destroy()
	Else
		MsgInfo("Não foi possivel abrir o relatório automaticamente. Abra diretamente o arquivo salvo no diretório indicado.","CAOA")
	EndIf

Return
