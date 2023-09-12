#Include 'FWMVCDef.ch'
#Include "rwmake.Ch"
#Include "TBICONN.CH"
#Include "FWBROWSE.CH"   
#Include "PROTHEUS.CH"
#Include "totvs.ch"
 
/*/{Protheus.doc} zTmpCad
Exemplo de Modelo 1 com tabela temporária
@author A.Carlos
@since 02/08/2022
@version 1.0
    @return Nil, Função não tem retorno
    @example
/*/

Static _lZPECF030

User Function ZPECF027(_cProduto)
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
    Local cInvice      := Space(30)
    
    Private lRet       := .T.
    Private aRetP 	   := {}
    Private cAliasTmp  := "TMP"
    Private cTitulo	   := "Gerenciamento de Invoices"
    Private aRotina    := MenuDef() 

    IF FWCodEmp() <> '2020' //Verificar Empresa Barueri
	    RETURN Nil
	ENDIF

	IF FWFilial() <> '2001' //Verificar Filial Barueri
	    RETURN Nil
	ENDIF

   _lZPECF030 := FWIsInCallStack("U_ZPECF030")   //PEC044 

    IF Empty(_cProduto)    
        aAdd( aPergs ,{1,"Informe o Produto ",cProd     ,"@!" , ""  , "SB1","", 100,.F. })

        IF Empty(cProd)
            aAdd( aPergs ,{1,"Informe a Invoice ",cInvice      ,"@!" , ""  , "SW8","", 100,.F. })
        ENDIF

        IF !Empty(cProd) .OR. !Empty(cProd)
            aAdd(aParamBox,{ 1, "Dt Embarque ", CtoD(''), "@D", "", "","", 50	,.F.})
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

	//--Monta temporaria
	zTmpInv()

    IF lRet = .T.

        //FWExecView (cTitulo, "ZPECF027", MODEL_OPERATION_VIEW ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ , /*cOperatId*/ ,/*cToolBar*/,/*oModelAct*/)

        //Irei criar a pesquisa que será apresentada na tela
        aAdd(aSeek,{"Item"	    ,{{ ""  ,"C"    ,023    ,000    ,"Item"    ,"@!"   }} } )
        aAdd(aSeek,{"Invoice"	,{{ ""  ,"C"    ,010    ,000    ,"Invoice" ,"@!"   }} } )
    
        //Campos que irão compor a tela de filtro
        Aadd(aFieFilter,{   "TR_DOC"	    ,"Documento"   ,"C" ,009    ,000    ,"@!" } )
        Aadd(aFieFilter,{   "TR_FORNECE"	,"Fornecedor"  ,"C" ,006    ,000    ,"@!" } )

        oBrowse := FWMBrowse():New()
        oBrowse:SetMenuDef('ZPECF027')
        oBrowse:SetAlias(cAliasTmp)
        oBrowse:SetDescription(cTitulo)
        //oBrowse:SetAmbiente(.T.)
        oBrowse:SetTemporary()
        //oBrowse:SetTemporary(.T.)
        oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
        oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
        oBrowse:AddLegend( "STATUS=='01'", "BR_BRANCO"           , "Aguardando Li e Embarque"    )  
        oBrowse:AddLegend( "STATUS=='02'", "BR_PRETO"            , "Aguardando Embarque"         ) 
        oBrowse:AddLegend( "STATUS=='03'", "BR_AMARELO"          , "Embarcado"                   ) 
        oBrowse:AddLegend( "STATUS=='04'", "BR_AZUL"             , "Aguardando pres. Carga"      )
        oBrowse:AddLegend( "STATUS=='05'", "BR_PINK"             , "Porto Ag. Parametrizacao"    )
        //oBrowse:AddLegend( "STATUS=='06'", "BR_BR_VERMELHO_CLARO", "Registro Ag. Parametrizacao" )   
        oBrowse:AddLegend( "STATUS=='06'", "BROWN"               , "Registro Ag. Parametrizacao" )   
        oBrowse:AddLegend( "STATUS=='07'", "BR_VERMELHO"         , "Canal Vermelho"              )   
        oBrowse:AddLegend( "STATUS=='08'", "BR_VERDE"            , "Canal Verde"                 ) 
        oBrowse:AddLegend( "STATUS=='09'", "BR_LARANJA"          , "Nacionalizada"               )
        oBrowse:AddLegend( "STATUS=='10'", "BR_AZUL_CLARO"       , "NF Emitida"                  )
        oBrowse:AddLegend( "STATUS=='11'", "BR_CINZA"            , "Entregue"                    )
        //oBrowse:AddLegend( "STATUS=='X'" , "BR_VERDE_ESCURO" , "X" )        

        //oBrowse:DisableReport()
        oBrowse:DisableDetails()
        If ! _lZPECF030  //se foi ou não chamado pelo Consultas ZPECF30 PEC044
            aAdd(afields, {"Status"      ,"Status","C"    ,002 ,0 ,"@!" })
            aAdd(afields, {"Filial"      ,"Filial","C"    ,010 ,0 ,"@!" })
            aAdd(afields, {"Invoice"   	 ,"Invoice","C"   ,030 ,0 ,"@!" })
            aAdd(afields, {"Item"        ,"Item","C"      ,023 ,0 ,"@!" })
            aAdd(afields, {"Descricao"   ,"Descricao","C" ,060 ,0 ,"@!" })
            aAdd(afields, {"Pedido" 	 ,"Pedido","C"    ,030 ,0 ,"@!" })
            aAdd(afields, {"Processo"    ,"Processo","C"  ,030 ,0 ,"@!" })
            aAdd(afields, {"Caixa"	     ,"Caixa","C"     ,010 ,0 ,"@!" })
            aAdd(afields, {"Data_Inv"    ,"Data_Inv","D"  ,008 ,0 ,"@D" })
            aAdd(afields, {"Prev_Cheg"	 ,"Prev_Cheg","D" ,008 ,0 ,"@D" })
        Else
            //aAdd(afields, {"Filial"         ,"Filial"       ,"C" ,010 ,0 ,"@!" })
            aAdd(afields, {"Invoice"   	    ,"Invoice"      ,"C" ,030 ,0 ,"@!" })
            aAdd(afields, {"Data_Inv"       ,"Data_Inv"     ,"D" ,008 ,0 ,"@D" })
            aAdd(afields, {"Pedido Compras" ,"PedCMP"       ,"C" ,030 ,0 ,"@!" })
            aAdd(afields, {"Item"           ,"Item"         ,"C" ,023 ,0 ,"@!" })
            aAdd(afields, {"Descricao"      ,"Descricao"    ,"C" ,060 ,0 ,"@!" })
            aAdd(afields, {"Qtd"            ,"Qtd"          ,"N" ,010 ,2 ,"@E 9,999,999.99" }) 
            aAdd(afields, {"Vl_Unit"        ,"Vl_Unit"      ,"N" ,014 ,2 ,"@E 99,999,999,999.99" })
            aAdd(afields, {"Vl_Total"       ,"Vl_Total"     ,"N" ,014 ,2 ,"@E 99,999,999,999.99" })
            aAdd(afields, {"Status"         ,"Status"       ,"C" ,002 ,0 ,"@!" })
            aAdd(afields, {"Nota"	        ,"Nota"         ,"C" ,009 ,0 ,"@!" })
            aAdd(afields, {"Serie"          ,"Serie"        ,"C" ,003 ,0 ,"@!" })
            aAdd(afields, {"Navio"	        ,"Navio"        ,"C" ,040 ,0 ,"@!" })
            aAdd(afields, {"Container"      ,"Container"    ,"C" ,020 ,0 ,"@!" })
            aAdd(afields, {"Caixa"	        ,"Caixa"        ,"C" ,010 ,0 ,"@!" })
            aAdd(afields, {"P.O." 	        ,"Pedido"       ,"C" ,030 ,0 ,"@!" })
            aAdd(afields, {"B_L"	        ,"B_L"          ,"C" ,020 ,0 ,"@!" })
            aAdd(afields, {"Prev. Chegada"	,"Prev_Cheg"    ,"D" ,008 ,0 ,"@D" })
            aAdd(afields, {"Dt Recebto"     ,"Data_Rec"     ,"D" ,008 ,0 ,"@D" })
            aAdd(afields, {"Processo"       ,"Processo"     ,"C" ,030 ,0 ,"@!" })

            oBrowse:AddButton("Visualiza P.O."		, { || FWMsgRun(, {|oSay| ZPCF027LPO(_cProduto) }, "Visualizar P.O."	, "Visualizar P.O.") },,,, .F., 2 )
            SB1->(DbSetOrder(1))
            SB1->(DbSeek(FwXFilial("SB1")+_cProduto))
            cTitulo := "Invoice - Produto "+AllTrim(_cProduto)+AllTrim(SB1->B1_DESC)
            oBrowse:SetDescription(cTitulo)

        Endif                
        //aAdd(afields, {"Descricao"  ,"Descricao","C" ,060 ,0 ,"@!" })
        //aAdd(afields, {"Qtd"    	  ,"Qtd","N"       ,010 ,2 ,"@E 9999999,99" }) 
        //aAdd(afields, {"Vl_Unit"    ,"Vl_Unit" ,"N"  ,014 ,2 ,"@E 99999999999,99" })
        //aAdd(afields, {"Vl_Total"   ,"Vl_Total","N"  ,014 ,2 ,"@E 99999999999,99" })
        //aAdd(afields, {"Nota"	      ,"Nota","C"      ,009 ,0 ,"@!" })
        //aAdd(afields, {"Serie"	  ,"Serie","C"     ,003 ,0 ,"@!" })
        //aAdd(afields, {"Navio"	  ,"Navio","C"     ,040 ,0 ,"@!" })
        //aAdd(afields, {"Container"  ,"Container","C" ,020 ,0 ,"@!" })
        //aAdd(afields, {"Caixa"	  ,"Caixa","C"     ,010 ,0 ,"@!" })
        //aAdd(afields, {"Proforma"   ,"Proforma" ,"C" ,030 ,0 ,"@!" })
        //aAdd(afields, {"B_L"	      ,"B_L","C"       ,020 ,0 ,"@!" })
        //aAdd(afields, {"Rec_Cont"   ,"Rec_Cont","D"  ,008 ,0 ,"@D" })
        //aAdd(afields, {"RECORD"	  ,"RECORD","C"    ,010 ,0 ,"@E 9999999999" })
        //aAdd(afields, {"MsgErro"	  ,"MsgErro","C"   ,240 ,0 ,"@!" })   

        //DAC PEC044 22/06/2023
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
Data.....:              02/08/2022
Descricao / Objetivo:   Monta temporaria invoices     
=====================================================================================
*/
Static Function zTmpInv(lJob)
    Local _cQuery    	:= ""
    Local _cQueNF    	:= ""
    Local _cQueMA    	:= ""
	Local aCampos       := {}
	Local oTempInv	    := Nil
	Local cMsgErro		:= ""
    Local cNFMae        := ""
    Local cNFFilha      := ""
    Local cSerFilha     := ""
    Local nQtdFilha     := 0
    Local _xDescTp      := ""
    Local _xDsStatus    := ""   
    Local _nPos01       := 0
    Local _cAliasInv    := GetNextAlias()
    Local _cAliasNF     := GetNextAlias()
    Local _cAliasMA     := GetNextAlias()
    
    Default lJob		:= .F.	


    If Select( _cAliasInv ) > 0
		( _cAliasInv )->( DbCloseArea() )
	EndIf

	_cQuery := CRLF + " "
	_cQuery += CRLF + " SELECT TMP.STATUS,TMP.FILIAL,TMP.PROCESSO,TMP.PEDIDO,TMP.INVOICE,TMP.DATA_INV,TMP.ITEM,TMP.DESCRICAO,TMP.DESC_DI,TMP.QTD,TMP.VL_UNIT, "
	_cQuery += CRLF + " TMP.VL_TOTAL,TMP.NOTA,TMP.SERIE,TMP.NAVIO,TMP.CONTAINER,TMP.CAIXA,TMP.PROFORMA,TMP.B_L,TMP.PREV_CHEG,TMP.TPPedido,TMP.REC_CONT,TMP.RECORD "
	_cQuery += CRLF + " FROM ( "
	_cQuery += CRLF + "     SELECT "
	_cQuery += CRLF + "     NVL(SZM.R_E_C_N_O_,0)  AS SZM_REC  "
    _cQuery += CRLF + "     , CASE   "
	_cQuery += CRLF + "     WHEN SW8.W8_FLUXO = '1' AND SWP.WP_REGIST = ' ' AND SW6.W6_DT_EMB = ' '                                           THEN '01'  "
	_cQuery += CRLF + "     WHEN SW6.W6_DT_EMB  = ' '                                                                                         THEN '02'  "
	_cQuery += CRLF + "     WHEN SW6.W6_DT_EMB != ' '                                                                                         THEN      "
	_cQuery += CRLF + "       CASE "
	_cQuery += CRLF + " 	     WHEN SW6.W6_CHEG = ' '                                                                                        THEN '03' "
	_cQuery += CRLF + " 	     WHEN SW6.W6_CHEG != ' ' AND SW6.W6_PRCARGA = ' '                                                              THEN '04' "
	_cQuery += CRLF + "          WHEN SW6.W6_CHEG != ' ' AND SW6.W6_DEST = 'SSZ' AND SW6.W6_CANAL = ' '                                        THEN '05' " 
	_cQuery += CRLF + "          WHEN SW6.W6_CHEG != ' ' AND SW6.W6_DEST != 'SSZ' AND SW6.W6_PRCARGA != ' ' AND SW6.W6_CANAL = ' '             THEN '06' "
	_cQuery += CRLF + "          WHEN SW6.W6_CHEG != ' ' AND SW6.W6_CANAL = '1'                                                                                 THEN '07' "
	_cQuery += CRLF + "          WHEN SW6.W6_CHEG != ' ' AND SW6.W6_CANAL = '3' AND SW6.W6_DT_DESE = ' '                                                        THEN '08' "
    _cQuery += CRLF + "          WHEN SW6.W6_CHEG != ' ' AND SW6.W6_CANAL = '3' AND SW6.W6_DT_DESE != ' ' AND SW6.W6_DT_NF = ' '                                THEN '09' "
    _cQuery += CRLF + "          WHEN SW6.W6_CHEG != ' ' AND SW6.W6_CANAL = '3' AND SW6.W6_DT_DESE != ' ' AND SW6.W6_DT_NF != ' ' AND SW6.W6_DT_ENTR = ' '      THEN '10' "
    _cQuery += CRLF + "          WHEN SW6.W6_CHEG != ' ' AND SW6.W6_CANAL = '3' AND SW6.W6_DT_DESE != ' ' AND SW6.W6_DT_NF != ' ' AND SW6.W6_DT_ENTR != ' '     THEN '11' "
    _cQuery += CRLF + "       END    "
    //_cQuery +CRLF + = "ELSE          "
    //_cQuery +CRLF + = "   'X'        "
    _cQuery += CRLF + "     END AS STATUS "
	_cQuery += CRLF + "     , SW8.W8_FILIAL     AS FILIAL"
    _cQuery += CRLF + "     , SW8.W8_HAWB       AS PROCESSO " 
	_cQuery += CRLF + "     , SW8.W8_PO_NUM     AS PEDIDO "
	_cQuery += CRLF + "     , SW8.W8_COD_I      AS ITEM "
	_cQuery += CRLF + "     , SB1.B1_DESC       AS DESCRICAO "
	_cQuery += CRLF + "     , SW8.W8_INVOICE    AS INVOICE "
	_cQuery += CRLF + "     , SW9.W9_DT_EMIS    AS DATA_INV "
	_cQuery += CRLF + "     , SW8.W8_DESC_DI    AS DESC_DI "    
	_cQuery += CRLF + "     , SW8.W8_QTDE       AS QTD "
//    _cQuery += CRLF + " SZM.ZM_QTDE AS QTQ, "
	_cQuery += CRLF + "     , SW8.W8_PRECO      AS VL_UNIT "
	_cQuery += CRLF + "     , (SW8.W8_QTDE * SW8.W8_PRECO) AS VL_TOTAL " 
    _cQuery += CRLF + "     , SF1.F1_DOC        AS NOTA "
    _cQuery += CRLF + "     , SF1.F1_SERIE      AS SERIE "
//_cQuery += CRLF + "     , SWN.WN_DOC        AS NOTA "
//_cQuery += CRLF + "     , SWN.WN_SERIE AS SERIE "

	_cQuery += CRLF + "     , SZM.ZM_NAVIO AS NAVIO "
	_cQuery += CRLF + "     , SZM.ZM_CONT AS CONTAINER "  
	_cQuery += CRLF + "     , SZM.ZM_CASE AS CAIXA "
	_cQuery += CRLF + "     , SW8.W8_PO_NUM AS PROFORMA "  
	_cQuery += CRLF + "     , SZM.ZM_BL AS B_L "  
	_cQuery += CRLF + "     , SW6.W6_DT_ETA AS PREV_CHEG "  
	_cQuery += CRLF + "     , SW6.W6_DT_ENTR AS REC_CONT " 
	_cQuery += CRLF + "     , SW6.W6_XTIPIMP AS TPPEDIDO "     
	_cQuery += CRLF + "     , SW8.R_E_C_N_O_ AS RECORD    "
	_cQuery += CRLF + " FROM  " + RetSqlName("SW9") + " SW9 "
	
    _cQuery += CRLF + "   LEFT JOIN " + RetSqlName("SW8") + " SW8 "	
	_cQuery += CRLF + " 	    ON SW8.W8_FILIAL    = '" + xFilial('SW8') + "'"
    _cQuery += CRLF + "        AND SW8.W8_INVOICE 	= SW9.W9_INVOICE "
	_cQuery += CRLF + "	       AND SW8.W8_HAWB    	= SW9.W9_HAWB "
    _cQuery += CRLF + "        AND SW8.D_E_L_E_T_   = ' ' " 

	_cQuery += CRLF + "   LEFT JOIN " + RetSqlName("SW6") + " SW6 "		 
	_cQuery += CRLF + "	 	    ON SW6.W6_FILIAL 	= '" + xFilial('SW6') + "'"
	_cQuery += CRLF + "	 	   AND SW6.W6_HAWB  	= SW9.W9_HAWB " 
    _cQuery += CRLF + "        AND SW6.D_E_L_E_T_   = ' ' " 

    _cQuery += CRLF + "   LEFT JOIN " + RetSqlName("SZM") + " SZM "		
	_cQuery += CRLF + "	 	    ON SZM.ZM_FILIAL 	= '" + xFilial('SZM') + "'"
	_cQuery += CRLF + "	 	   AND SZM.ZM_INVOICE 	= SW8.W8_INVOICE " 
	_cQuery += CRLF + "	 	   AND SZM.ZM_PROD    	= SW8.W8_COD_I "
	_cQuery += CRLF + "	 	   AND SZM.ZM_PO_NUM  	= SW8.W8_PO_NUM "
	_cQuery += CRLF + "	 	   AND SZM.ZM_POSICAO 	= SW8.W8_POSICAO "
	//_cQuery += CRLF + "	 	   AND SZM.ZM_CASE 	    = SW8.W8_XCASE "
	_cQuery += CRLF + "	 	   AND SZM.R_E_C_N_O_   > 0 
	_cQuery += CRLF + "        AND SZM.D_E_L_E_T_   = ' ' " 

    _cQuery += CRLF + "   LEFT JOIN " + RetSqlName("SWP") + " SWP "		
	_cQuery += CRLF + "	 	     ON SWP.WP_FILIAL 	= '" + xFilial('SWP') + "'"
	_cQuery += CRLF + "	        AND SWP.WP_PGI_NUM 	= SW8.W8_PGI_NUM " 
	_cQuery += CRLF + "	        AND SWP.WP_SEQ_LI  	= SW8.W8_SEQ_LI "  
    _cQuery += CRLF + "         AND SWP.D_E_L_E_T_  = ' ' " 
		
  /*_cQuery += CRLF + " 	LEFT JOIN " + RetSqlName("SWN") + " SWN "
	_cQuery += CRLF + " 	     ON SWN.WN_FILIAL   = SW8.W8_FILIAL "
	_cQuery += CRLF + " 	    AND SWN.WN_HAWB     = SW8.W8_HAWB "
	_cQuery += CRLF + " 	    AND SWN.WN_INVOICE  = SW8.W8_INVOICE "
	_cQuery += CRLF + " 	    AND SWN.WN_PRODUTO  = SW8.W8_COD_I "
    _cQuery += CRLF + " 	    AND SWN.WN_ITEM     = SW8.W8_POSICAO "
	_cQuery += CRLF + " 	    AND SWN.D_E_L_E_T_  = ' ' " */

    _cQuery += CRLF + "   LEFT JOIN " + RetSqlName("SF1") + " SF1 "	
	_cQuery += CRLF + "			 ON SF1.F1_FILIAL 	= '" + xFilial('SF1') + "'"
	_cQuery += CRLF + "			AND ((SF1.F1_HAWB 	= SW9.W9_HAWB) " 
	_cQuery += CRLF + "			 OR (SF1.F1_XHAWB 	= SW9.W9_HAWB)) " 
    _cQuery += CRLF + "         AND SF1.D_E_L_E_T_  = ' ' "  	

    _cQuery += CRLF + "   LEFT JOIN " + RetSqlName("SD1") + " SD1 "	            
	_cQuery += CRLF + "			 ON SD1.D1_FILIAL 	= '" + xFilial('SD1') + "'"
    _cQuery += CRLF + "     	AND ((SD1.D1_CONHEC = SW8.W8_HAWB) " 
	_cQuery += CRLF + "			 OR (SD1.D1_XCONHEC = SW8.W8_HAWB)) " 
	_cQuery += CRLF + "			AND SD1.D1_FORNECE 	= SW8.W8_FORN " 
	_cQuery += CRLF + "			AND SD1.D1_LOJA 	= SW8.W8_FORLOJ " 
	_cQuery += CRLF + "			AND SD1.D1_COD 		= SW8.W8_COD_I " 
	_cQuery += CRLF + "			AND SD1.D1_DOC 		= SF1.F1_DOC " 
	_cQuery += CRLF + "			AND SD1.D1_SERIE 	= SF1.F1_SERIE " 
    _cQuery += CRLF + "         AND SD1.D_E_L_E_T_  = ' ' "   

    _cQuery += CRLF + "   LEFT JOIN " + RetSqlName("SB1") + " SB1 "
    _cQuery += CRLF + "			 ON SB1.B1_FILIAL 	= '" + xFilial('SB1') + "'"	              
	_cQuery += CRLF + "	 	    AND SB1.B1_COD   	= SW8.W8_COD_I " 
	_cQuery += CRLF + "         AND SB1.D_E_L_E_T_  = ' ' "

	_cQuery += CRLF + "   WHERE "   
    _cQuery += CRLF + "			 SW9.W9_FILIAL 	= '" + xFilial('SW9') + "'"

    _cQuery += CRLF + "         AND SZM.R_E_C_N_O_  > 0 " 
	_cQuery += CRLF + "	        AND (SF1.F1_HAWB 	!= ' ' OR SF1.F1_XHAWB != ' ') "
	_cQuery += CRLF + "	        AND SF1.F1_DOC 	    = SD1.D1_DOC " 
	_cQuery += CRLF + "	        AND SF1.F1_SERIE	= SD1.D1_SERIE "

    IF !Empty(aRetP[01]) 
        _cQuery += CRLF + "    AND  SW8.W8_COD_I   = '" + aRetP[01] + "'" 
    ENDIF
    //IF !Empty(aRetP[01]) .AND. !Empty(aRetP[02])  
    //    _cQuery += " AND "
    //ENDIF
    IF !Empty(aRetP[02]) 
        _cQuery += CRLF + "    AND SW8.W8_INVOICE = '" + aRetP[02] + "'"
    ENDIF

    _cQuery += CRLF + "         AND SW9.D_E_L_E_T_ = ' ' "
    _cQuery += CRLF + "     ) TMP "
    _cQuery += CRLF + "     GROUP BY (TMP.STATUS,TMP.FILIAL,TMP.PROCESSO,TMP.PEDIDO,TMP.INVOICE,TMP.DATA_INV,TMP.ITEM,TMP.Descricao,TMP.Desc_DI,TMP.Qtd "
    _cQuery += CRLF + "     ,TMP.Vl_unit,TMP.Vl_Total,TMP.NOTA,TMP.SERIE,TMP.NAVIO,TMP.Container,TMP.Caixa"
    _cQuery += CRLF + "     ,TMP.Proforma,TMP.B_L,TMP.Prev_cheg,TMP.Rec_cont,TMP.TpPedido,TMP.RECORD) "
    _cQuery += CRLF + "     ORDER BY PROCESSO, PEDIDO, INVOICE, ITEM "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAliasInv, .T., .T. )

	(_cAliasInv)->(DbGoTop())
	IF (_cAliasInv)->(!EOF())
		SW8->( dbGoto( (_cAliasInv)->RECORD ))     // posiciona o registro
		_lExist := .T.
    ELSE
        lRet := .F.
        MsgInfo("Invoice ou Item não encontrado! ", "[ ZPECF027 ] - Aviso" )
		Return(lRet)
    EndIf

	DbSelectArea(_cAliasInv)
	(_cAliasInv)->(dbGoTop())

	If (_cAliasInv)->(!Eof())

		//Se o alias estiver aberto, fechar para evitar erros com alias aberto
		If (Select(cAliasTmp) <> 0)
			dbSelectArea(cAliasTmp)
			(cAliasTmp)->(dbCloseArea())
		EndIf

		oTempInv := FWTemporaryTable():New(cAliasTmp)

		aAdd(aCampos, {"Status"     ,"C"    ,002    ,0  })
		aAdd(aCampos, {"DsStatus"   ,"C"    ,030    ,0  })        
        aAdd(aCampos, {"Filial"     ,"C"    ,010    ,0  })
		aAdd(aCampos, {"Invoice"   	,"C"    ,030    ,0  })
		aAdd(aCampos, {"Pedido" 	,"C"    ,030    ,0  })
		aAdd(aCampos, {"Processo"   ,"C"    ,030    ,0  })
		aAdd(aCampos, {"Data_Inv"   ,"D"    ,008    ,0  })
        //aAdd(aCampos, {"Desc_DI"    ,"C"    ,010    ,0  })     
        aAdd(aCampos, {"Item"       ,"C"    ,023    ,0  })
        aAdd(aCampos, {"Descricao"  ,"C"    ,060    ,0  })
		aAdd(aCampos, {"Qtd"    	,"N"    ,010    ,2  }) 
		aAdd(aCampos, {"Vl_Unit"   	,"N"    ,014    ,2  })
		aAdd(aCampos, {"Vl_Total"   ,"N"    ,014    ,2  })
        aAdd(aCampos, {"Nota"	    ,"C"    ,240    ,0  })
        aAdd(aCampos, {"Serie"	    ,"C"    ,003    ,0  })
        aAdd(aCampos, {"Navio"	    ,"C"    ,040    ,0  })
        aAdd(aCampos, {"Container"  ,"C"    ,020    ,0  })
        aAdd(aCampos, {"Caixa"	    ,"C"    ,015    ,0  })
        aAdd(aCampos, {"Proforma"   ,"C"    ,030    ,0  })
        aAdd(aCampos, {"B_L"	    ,"C"    ,020    ,0  })
        aAdd(aCampos, {"Prev_Cheg"	,"D"    ,008    ,0  })
        aAdd(aCampos, {"Data_Rec"	,"D"    ,008    ,0  })
        aAdd(aCampos, {"Tp_Pedido"  ,"C"    ,030    ,0  })        
       // aAdd(aCampos, {"RECORD"	    ,"C"    ,010    ,0  })
	    aAdd(aCampos, {"MsgErro"	,"C"    ,240    ,0  })  
        aAdd(aCampos, {"Notas_F"	,"C"    ,240    ,0  })
        aAdd(aCampos, {"Serie_F"    ,"C"    ,003    ,0  })
        aAdd(aCampos, {"Qtd_F"    	,"N"    ,010    ,2  }) 

        aAdd(aCampos, {"PedCMP"     ,"C"    ,030    ,0  })
        aAdd(aCampos, {"Rec_Cont"   ,"D"    ,008    ,0  })

        


		oTempInv:SetFields( aCampos )
		oTempInv:AddIndex( "01", { "Item"    } )
		oTempInv:AddIndex( "02", { "Invoice" } )
		oTempInv:Create()

		(_cAliasInv)->(dbGoTop())
		
        _cQueNF := " "
	    _cQueNF := " Select "
        _cQueNF += " SD1.D1_DOC FILHAS,SD1.D1_SERIE SERIE_F,SD1.D1_XCONHEC CONHEC,SD1.D1_QUANT QTDE_F,SD1.D1_XCASE XCASE, " 
        _cQueNF += " SW8.W8_HAWB AS PROCESSO, SW8.W8_PO_NUM AS PEDIDO, SW8.W8_INVOICE AS INVOICE,SW8.W8_COD_I AS ITEM ,SD1.D1_EMISSAO NF_EMISSAO"
        _cQueNF += " FROM " + RetSqlName("SW8") + " SW8 "
        _cQueNF += " LEFT JOIN " + RetSqlName("SD1") + " SD1 "
        _cQueNF += " ON SD1.D1_FILIAL     = SW8.W8_FILIAL    " 
        _cQueNF += " AND SD1.D1_COD       = SW8.W8_COD_I     " 
        _cQueNF += " AND SD1.D1_XCONHEC   = SW8.W8_HAWB      " 
        _cQueNF += " AND SD1.D_E_L_E_T_   = ' '              "
        _cQueNF += " WHERE SW8.D_E_L_E_T_ = ' ' AND SW8.W8_FILIAL = '" + xFilial('SW8') + "'"
    
        IF !Empty(aRetP[01]) 
            _cQueNF += "    AND  SW8.W8_COD_I   = '" + aRetP[01] + "'" 
        ENDIF

        IF !Empty(aRetP[02]) 
            _cQueNF += "    AND SW8.W8_INVOICE = '" + aRetP[02] + "'"
        ENDIF

        dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQueNF ), _cAliasNF, .T., .T. )
                
        //Se o alias estiver aberto, fechar para evitar erros com alias aberto
		//If (Select(_cAliasNF) <> 0)
		//	dbSelectArea(_cAliasNF)
		//	(_cAliasNF)->(dbCloseArea())
		//EndIf

        _cQueMA := " "
	    _cQueMA := " Select "
        _cQueMA += " SD1.D1_DOC NFMAE,SD1.D1_SERIE SERIE_M,SD1.D1_XCONHEC CONHEC,SD1.D1_XCASE CAIXA,SD1.D1_COD PRODUTO " 
        _cQueMA += " FROM " + RetSqlName("SD1") + " SD1 "
        _cQueMA += " WHERE SD1.D1_FILIAL = '" + xFilial('SD1') + "'"
        _cQueMA += "     AND SD1.D_E_L_E_T_ = ' ' 
        _cQueMA += "     AND SD1.D1_CONHEC  = '" + (_cAliasInv)->PROCESSO + "'" 
        _cQueMA += "     AND SD1.D1_COD     = '" + (_cAliasInv)->ITEM     + "'" 
     
        dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQueMA ), _cAliasMA, .T., .T. )
                
        //Se o alias estiver aberto, fechar para evitar erros com alias aberto
		//If (Select(_cAliasNF) <> 0)
		//	dbSelectArea(_cAliasNF)
		//	(_cAliasNF)->(dbCloseArea())
		//EndIf
            
        While (_cAliasInv)->(!Eof())
            cNFMae := " "

            (_cAliasMA)->(DbGoTop())

            WHILE (_cAliasMA)->(!EOF())
                    
                cNFMae += (_cAliasMA)->NFMAE
                cNFMae += "/"
                cNFMae += (_cAliasMA)->SERIE_M

                (_cAliasMA)->(DbSkip())

            EndDo
            
            cNFFilha   := " "
            cSerFilha  := " "
            nQtdFilha  := 0
            (_cAliasNF)->(DbGoTop())
            WHILE (_cAliasNF)->(!EOF())
                
                If Alltrim((_cAliasNF)->XCASE) == Alltrim((_cAliasInv)->Caixa)
                    
                    _nPos01 := AT((_cAliasNF)->FILHAS,cNFFilha)

                    IF _nPos01 = 0 
                        cNFFilha  += (_cAliasNF)->FILHAS
                        cNFFilha  += "/"
                        cSerFilha += (_cAliasNF)->SERIE_F
                        nQtdFilha += (_cAliasNF)->QTDE_F
                    ENDIF

                EndIf
                (_cAliasNF)->(DbSkip())
            End

            _xDescTp := POSICIONE("ZZ8",1, FWXFILIAL("ZZ8") + (_cAliasInv)->TpPedido, "ZZ8_DESC")

            DO CASE

                CASE (_cAliasInv)->STATUS = '01'
                    _xDsStatus := "Aguardando Li e Embarque"
                CASE (_cAliasInv)->STATUS = '02'
                    _xDsStatus := "Aguardando Embarque"
                CASE (_cAliasInv)->STATUS = '03'
                    _xDsStatus := "Embarcado"
                CASE (_cAliasInv)->STATUS = '04'
                    _xDsStatus := "Aguardando pres. Carga"
                CASE (_cAliasInv)->STATUS = '05'
                    _xDsStatus := "Porto Ag. Parametrizacao"
                CASE (_cAliasInv)->STATUS = '06'
                    _xDsStatus := "Registro Ag. Parametrizacao"
                CASE (_cAliasInv)->STATUS = '07'
                    _xDsStatus := "Canal Vermelho" 
                CASE (_cAliasInv)->STATUS = '08'
                    _xDsStatus := "Canal Verde"
                CASE (_cAliasInv)->STATUS = '09'
                    _xDsStatus := "Nacionalizada"
                CASE (_cAliasInv)->STATUS = '10'
                    _xDsStatus := "NF Emitida"
                CASE (_cAliasInv)->STATUS = '11'
                    _xDsStatus := "Entregue"
            ENDCASE

    		If RecLock(cAliasTmp,.T.)
                (cAliasTmp)->Status      := (_cAliasInv)->Status 
                (cAliasTmp)->DsStatus    := _xDsStatus          
                (cAliasTmp)->Filial      := (_cAliasInv)->Filial
                (cAliasTmp)->Invoice     := (_cAliasInv)->Invoice
                (cAliasTmp)->Pedido      := (_cAliasInv)->Pedido
                (cAliasTmp)->Processo    := (_cAliasInv)->Processo
                (cAliasTmp)->Data_Inv    := Stod((_cAliasInv)->Data_Inv)
                //(cAliasTmp)->Desc_DI   := (_cAliasInv)->Desc_DI
                (cAliasTmp)->Item        := (_cAliasInv)->Item 
                (cAliasTmp)->Descricao   := (_cAliasInv)->Descricao
                (cAliasTmp)->Qtd         := (_cAliasInv)->Qtd
                (cAliasTmp)->Vl_Unit     := (_cAliasInv)->Vl_Unit
                (cAliasTmp)->Vl_Total    := (_cAliasInv)->Vl_Total
                (cAliasTmp)->Nota        := (_cAliasInv)->Nota
                (cAliasTmp)->Serie       := (_cAliasInv)->Serie
                (cAliasTmp)->Navio       := (_cAliasInv)->Navio
                (cAliasTmp)->Container   := (_cAliasInv)->Container
                (cAliasTmp)->Caixa       := (_cAliasInv)->Caixa
                (cAliasTmp)->Proforma    := (_cAliasInv)->Proforma
                (cAliasTmp)->B_L         := (_cAliasInv)->B_L
                (cAliasTmp)->Prev_Cheg   := Stod((_cAliasInv)->Prev_Cheg)
                (cAliasTmp)->Tp_Pedido   := _xDescTp
                (cAliasTmp)->Rec_Cont    := Stod((_cAliasInv)->Rec_Cont)
                (cAliasTmp)->Notas_F     := cNFFilha
                (cAliasTmp)->Serie_F     := cSerFilha
                (cAliasTmp)->Qtd_F       := nQtdFilha               
                //(cAliasTmp)->RECORD    := Str((_cAliasInv)->RECORD)
                (cAliasTmp)->MsgErro     := cMsgErro
                (cAliasTmp)->PedCMP      := AllTrim((_cAliasInv)->Invoice)
                If (_cAliasInv)->STATUS = '11'
                    (cAliasTmp)->Data_Rec    :=  StoD((_cAliasNF)->NF_EMISSAO)

                Endif     
				(cAliasTmp)->(MsUnLock())
			EndIf

    		(_cAliasInv)->(DbSkip())
		
        EndDo

		(_cAliasInv)->(DbCloseArea())
	
	else
        
    EndIf

Return(lRet)

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
Local aRot := {} 

    //Adicionando opções
    ADD OPTION aRot TITLE 'Consulta Tela' ACTION 'VIEWDEF.ZPECF027' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    //ADD OPTION aRot TITLE "Legenda" ACTION "U_LEGEN()" OPERATION 9 ACCESS 0
    //ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zTmpCad' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    //ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zTmpCad' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    //ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zTmpCad' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot

 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
    Local oStTMP  := FWFormModelStruct():New()         //Criação da estrutura de dados utilizada na interface
    Local aCampos := {}
    Local nX      := 0
    
    oStTMP:AddTable(cAliasTmp, {'Filial'   ,'Invoice' ,'Pedido', 'Processo', 'Data_Inv', 'Item' ,'Descricao','Qtd','Vl_Unit'  ,;
                                'Vl_Total' ,'Nota'    ,'Serie'  ,'Navio'   ,'Container','Caixa'  ,'Proforma' ,'B_L','Prev_Cheg',;
                                'Tp_Pedido','Rec_Cont','MsgErro','Notas_F' ,'Serie_F'  ,'Ds_Status'},;
                        "Temporaria")

    AAdd( aCampos, {"Status"      ,"Status"      ,"Status"   , "C", 002,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Status   ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Ds_Status"   ,"DsStatus"    ,"DsStatus" , "C", 030,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->DsStatus ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Filial"      ,"Filial"      ,"Filial"   , "C", 010,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Filial   ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Invoice"     ,"Invoice"     ,"Invoice"  , "C", 030,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Invoice  ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"MsgErro"     ,"MsgErro"     ,"MsgErro"  , "C", 240,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->MsgErro  ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Rec_Cont"    ,"Rec_Cont"    ,"Rec_Cont" , "D", 008,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Rec_Cont ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Prev_Cheg"   ,"Prev_Cheg"   ,"Prev_Cheg", "D", 008,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Prev_Cheg,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Tipo_Pedido" ,"Tp_Pedido"   ,"Tp_Pedido", "C", 030,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Tp_Pedido,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"B_L"         ,"B_L"         ,"B_L"      , "C", 020,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->B_L      ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Proforma"    ,"Proforma"    ,"Proforma" , "C", 030,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Proforma ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Caixa"       ,"Caixa"       ,"Caixa"    , "C", 015,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Caixa    ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Container"   ,"Container"   ,"Container", "C", 020,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Container,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Navio"       ,"Navio"       ,"Navio"    , "C", 040,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Navio    ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Serie"       ,"Serie"       ,"Serie"    , "C", 003,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Serie    ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Nota"        ,"Nota"        ,"Nota"     , "C", 009,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Nota     ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Vl_Total"    ,"Vl_Total"    ,"Vl_Total" , "N", 014,2, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Vl_Total ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Vl_Unit"     ,"Vl_Unit"     ,"Vl_Unit"  , "N", 014,2, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Vl_Unit  ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Qtd"         ,"Qtd"         ,"Qtd"      , TamSx3('D1_QUANT')[3], TamSx3('D1_QUANT')[1],TamSx3('D1_QUANT')[2], Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Qtd      ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Descricao"   ,"Descricao"   ,"Descricao", "C", 060,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Descricao,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Item"        ,"Item"        ,"Item"     , "C", 023,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Item     ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Data_Inv"    ,"Data_Inv"    ,"Data_Inv" , "D", 008,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Data_Inv ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Pedido"      ,"Pedido"      ,"Pedido"   , "C", 030,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Pedido   ,'')" ,.T.,.F.,.F.})
    AAdd( aCampos, {"Processo"    ,"Processo"    ,"Processo" , "C", 030,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Processo ,'')" ,.F.,.F.,.F.})
    AAdd( aCampos, {"NotasFilhas" ,"NotasFilhas" ,"Notas_F"  , "C", 100,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Notas_F  ,'')" ,.F.,.F.,.F.})
    AAdd( aCampos, {"SeriesFilhas","SeriesFilhas","Serie_F"  , "C", 003,0, Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Serie_F  ,'')" ,.F.,.F.,.F.})
    AAdd( aCampos, {"Qtd Filhas"  ,"Qtd Filhas"  ,"Qtd_F"    , TamSx3('D1_QUANT')[3], TamSx3('D1_QUANT')[1],TamSx3('D1_QUANT')[2], Nil, Nil, {}, .F.,  "Iif(!INCLUI," + cAliasTmp + "->Qtd_F    ,'')" ,.F.,.F.,.F.})
    //oStTmp:Create()
     
    //Adiciona os campos da estrutura
    For nX := 1 to Len(aCampos)
    
        oStTmp:AddField(;
                        aCampos[nX ,1 ],;                                             // [01]  C   Titulo do campo
                        aCampos[nX ,2 ],;                                             // [02]  C   ToolTip do campo
                        aCampos[nX ,3 ],;                                             // [03]  C   Id do Field
                        aCampos[nX ,4 ],;                                             // [04]  C   Tipo do campo
                        aCampos[nX ,5 ],;                                             // [05]  N   Tamanho do campo
                        aCampos[nX ,6 ],;                                             // [06]  N   Decimal do campo
                        aCampos[nX ,7 ],;                                             // [07]  B   Code-block de validação do campo
                        aCampos[nX ,8 ],;                                             // [08]  B   Code-block de validação When do campo
                        aCampos[nX ,9 ],;                                             // [09]  A   Lista de valores permitido do campo
                        aCampos[nX ,10 ],;                                            // [10]  L   Indica se o campo tem preenchimento obrigatório
                        FwBuildFeature( STRUCT_FEATURE_INIPAD, aCampos[nX ,11 ] ),;   // [11]  B   Code-block de inicializacao do campo
                        aCampos[nX ,12 ],;                                            // [12]  L   Indica se trata-se de um campo chave
                        aCampos[nX ,13 ],;                                            // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                        aCampos[nX ,14 ])                                             // [14]  L   Indica se o campo é virtual
    Next nX
           
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("zTmpCadM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMTMP",/*cOwner*/,oStTMP)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'INVOICE'})
     
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
    Local oModel   := FWLoadModel("ZPECF027")
    Local oStTMP   := FWFormViewStruct():New()
    Local oView    := Nil
    Local aCampos  := {}
    Local nX       := 0
    
    AAdd(aCampos,{"Invoice"  ,"01","Invoice"     ,"Invoice"    ,Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Data_Inv" ,"02","Data_Invoice","Data_Inv"   ,Nil,"D","@D"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Pedido"   ,"03","Pedido"      ,"Pedido"     ,Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Prev_Cheg","04","Prev_Cheg"   ,"Prev_Cheg"  ,Nil,"D","@D"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Tp_Pedido","05","Tipo_Pedido" ,"Tipo_Pedido",Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Processo" ,"06","Processo"    ,"Processo"   ,Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Item"     ,"07","Item"        ,"Item"       ,Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Descricao","08","Descricao"   ,"Descricao"  ,Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Qtd"      ,"09","Qtd"         ,"Qtd"        ,Nil,"N","@E 99,999,999.99" ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Nota"     ,"10","Nota"        ,"Nota"       ,Nil,"N","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Serie"    ,"11","Serie"       ,"Serie"      ,Nil,"N","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Navio"    ,"12","Navio"       ,"Navio"      ,Nil,"N","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Container","13","Container"   ,"Container"  ,Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Caixa"    ,"14","Caixa"       ,"Caixa"      ,Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Vl_Unit"  ,"15","Vl_Unit"     ,"Vl_Unit"    ,Nil,"N","@E 999,999,999.99",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Vl_Total" ,"16","Vl_Total"    ,"Vl_Total"   ,Nil,"N","@E 999,999,999.99",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"B_L"      ,"18","B_L"         ,"B_L"        ,Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Proforma" ,"17","Proforma"    ,"Proforma"   ,Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Rec_Cont" ,"19","Rec_Cont"    ,"Rec_Cont"   ,Nil,"D","@D"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Status"   ,"20","Status"      ,"Status"     ,Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"DsStatus" ,"21","DsStatus"    ,"DsStatus"   ,Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Notas_F"  ,"22","Notas_Filhas","Notas_F"    ,Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Serie_F"  ,"23","Serie_Filhas","Serie_F"    ,Nil,"C","@!"               ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
    AAdd(aCampos,{"Qtd_F"    ,"24","Qtd Filhas"  ,"Qtd_F"      ,Nil,"N","@E 99,999,999.99" ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
   
    //Adicionando campos da estrutura
    
    For nX:= 1 to Len(aCampos)
        oStTmp:AddField(;
            aCampos[nX, 1],;                       // [01]  C   Nome do Campo
            aCampos[nX, 2],;                       // [02]  C   Ordem
            aCampos[nX, 3],;                       // [03]  C   Titulo do campo
            aCampos[nX, 4],;                       // [04]  C   Descricao do campo
            aCampos[nX, 5],;                       // [05]  A   Array com Help
            aCampos[nX, 6],;                       // [06]  C   Tipo do campo
            aCampos[nX, 7],;                       // [07]  C   Picture
            aCampos[nX, 8],;                       // [08]  B   Bloco de PictTre Var
            aCampos[nX, 9],;                       // [09]  C   Consulta F3
            aCampos[nX,10],;                       // [10]  L   Indica se o campo é alteravel
            aCampos[nX,11],;                       // [11]  C   Pasta do campo
            aCampos[nX,12],;                       // [12]  C   Agrupamento do campo
            aCampos[nX,13],;                       // [13]  A   Lista de valores permitido do campo (Combo)
            aCampos[nX,14],;                       // [14]  N   Tamanho maximo da maior opção do combo
            aCampos[nX,15],;                       // [15]  C   Inicializador de Browse
            aCampos[nX,16],;                       // [16]  L   Indica se o campo é virtual
            aCampos[nX,17],;                       // [17]  C   Picture Variavel
            aCampos[nX,18])                        // [18]  L   Indica pulo de linha após o campo
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


//mostrar P.O.
//DAC - Denilso 22/06/2023
Static Function ZPCF027LPO(_cProduto)
/* mesmo declarando não funciona da ero na montagem 
Local _cAliasPesq 	:= GetNextAlias()
Local _cPO          := (cAliasTmp)->PEDIDO
Local _cAlias       := "SW2"
Local _nOpc         := 2 
Local _nReg         := 0

//AOM - 14/04/2011 - Flag para verificar se Operação Especial está habilitada
Private cSim            := "N"
Private lForeCast := (AllTrim(EasyGParam("MV_FORECAS"))$cSim)
Private lOperacaoEsp    := AvFlags("OPERACAO_ESPECIAL") .And. !lPOAuto
Private lRegTriPO       := SW3->(FieldPos("W3_GRUPORT")) # 0 .AND. SIX->(dbSeek("EIJ2"))
PRIVATE cProg           := "PO" 
Private cDESC_PO:= EasyGParam("MV_DESC_PO",,"I") // JVR - 05/01/10 - Inserido seleção da descrição por parametro."I/P/GI"
PRIVATE nLenFabr:=AVSX3("A2_COD",3) //SO.:0026 OS.: 0243/02 FCD
PRIVATE nLenForn:=AVSX3("A2_COD",3) //SO.:0026 OS.: 0243/02 FCD
PRIVATE nLenCli :=AVSX3("A1_COD",3) //SO.:0026 OS.: 0243/02 FCD
PRIVATE nLenCC  :=AVSX3("W0__CC",3) //SO.:0026 OS.: 0243/02 FCD
PRIVATE nLenSi  :=AVSX3("W0__NUM",3)//SO.:0026 OS.: 0243/02 FCD
PRIVATE nLenOK  :=AVSX3("W2_OK",3)  //SO.:0026 OS.: 0243/02 FCD
PRIVATE cArqRdmake:= "EICPONEC"
PRIVATE cArqNestle:= "PONESTLE"
PRIVATE lSeal  := EasyEntryPoint("IC193PO1"), cSay1, cSay2
PRIVATE lHunter:= EasyEntryPoint("IC010PO1")//AWR 09/11/1999
PRIVATE lNec   := EasyEntryPoint(cArqRdmake)
PRIVATE lNestle:= EasyEntryPoint(cArqNestle)
PRIVATE lNobel := EasyEntryPoint("IC163PO1")
PRIVATE lRdMake:= EasyEntryPoint("EICPPO02")
PRIVATE cPrice := 0, aGetsNaciona
PRIVATE lLibQt := GETNEWPAR("MV_LIBQTEM", .F.) //PARA ACEITAR SALDO DE QTDE. NEGATIVO (THISSEN)
Private lSolic:=.T., aFornSW1 := {}  // EOS - OS 486/02 Inclusao de SI de referencia
Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
Private _PictQtde := ALLTRIM(X3Picture("W3_QTDE")), _PictPrTot := ALLTRIM(X3Picture("W2_FOB_TOT"))
//lFilDa:=EasyGParam("MV_FIL_DA")
SX3->(DBSETORDER(2))
PRIVATE lCancelaSaldo    :=EasyGParam("MV_CANSALD") $ cSim
PRIVATE lExiste_Midia    :=EasyGParam("MV_SOFTWAR") $ cSim
SX3->(DBSETORDER(1))
If(!(cDesc_PO $ "I/P/GI"), cDESC_PO := "I",)

Private lCpoCtCust := (EasyGParam("MV_EASY")$cSim) .And. SW3->(FIELDPOS("W3_CTCUSTO")) > 0 // NCF - 22/06/2010 - Flag do campo de Centro de Custo

Private lPesoBruto := SW3->(FieldPos("W3_PESO_BR")) > 0 .And. SW5->(FieldPos("W5_PESO_BR")) > 0 .And. SW7->(FieldPos("W7_PESO_BR")) > 0 .And.;
                      SW8->(FieldPos("W8_PESO_BR")) > 0 .And. EasyGParam("MV_EIC0014",,.F.) //FSM - 02/09/2011 - Campo de peso bruto unitario

Private aCorrespWork := {} //AOM - 07/04/2011 - Array para manipular as work no objeto de Operações Especiais


Private lPedNac := cProg == "PN" // GFP - 26/03/2014

Private oUpdAtu //BAK - 22/08/11
Private oBufferUM:= tHashMap():New() //bufferização da busca pela unidade de medida
Private cCadastro := "P.O. "+_cPO
INCLUI := .F.
EXCLUI := .F.
ALTERA := .F.
//U_ZPECF029(_cProduto)
//return nil

Begin Sequence
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT ISNULL(SW2.R_E_C_N_O_,0) NREGSW2
		FROM  %Table:SW2% SW2
		WHERE   SW2.W2_FILIAL 	= %XFilial:SW2%
			AND SW2.W2_PO_NUM  	= %Exp:_cPO%
			AND SW2.%notDel%
	EndSQL
    //AND SW3.W3_COD_I    = %Exp:_cProduto%
//            AND SW3.W3_SEQ      = '1'                                                                  "+LBreak
	(_cAliasPesq)->(DbGotop())	
	If (_cAliasPesq)->(Eof()) .Or. (_cAliasPesq)->NREGSW2 == 0
        MSGINFO( "P.O. Não encontrada !", "Atenção" )
		Break
	EndIf
    _nReg := (_cAliasPesq)->NREGSW2
	SW2->(DbGoto((_cAliasPesq)->NREGSW2))
    //Dados para chamar tela PO
    
    PO400Visua(_cAlias,_nReg,_nOpc)
End Sequence
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
 */   
    //PEC044 - necessário implementar PEs EICPPO01_PE e IPO400MNU_PE
    EICPO400(,,,2)

Return Nil



/*
User Function EICPO400()
Local cFiltro
Local cParam	:= If(Type("ParamIxb") = "A",ParamIxb[1],If(Type("ParamIxb") = "C",ParamIxb,""))
 	If cParam == "FILTRA_SI" .AND. FunName() = "EICEI100"
        cFiltro := "W2_FILIAL='"+xFilial("SW2")+"' .And.  AllTrim(SW2.W2_PO_NUM) = '"+AllTrim((cAliasTmp)->PEDIDO)+"'"
        SET FILTER TO &cFiltro        
     EndIf
Return Nil 
*/
