#Include "Protheus.Ch"
#Include "Totvs.Ch"
#include 'parmtype.ch'
#include "TBICONN.CH"
#include 'TOPCONN.CH'

#Define CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} ZCOMR006.PRW
Relatório de SLA - CAOA
@author Sandro Ferreira
@since 17/06/2022
@version 1.0
@type function
/*/
User Function ZCOMR006()

    Local oReport,  oSection
    Private cPerg   := PadR ("ZCOMR006X", Len (SX1->X1_GRUPO))
    Private cAliasTMP := GetNextAlias()

    CriSx1()


    oReport:= TReport():New("ZCOMR006",;
                            "Consulta SLA",;
                            cPerg,;
                            {|oReport|  ReportPrint(oReport)},;
                            "Este relatorio efetua a impressão das S.L.A dos Pedidos de Compras.")
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
    oReport:HideHeader()      //--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter()      //--Define que não será impresso o rodapé padrão da página
    oReport:SetDevice(4)      //--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetPreview(.T.)   //--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2) //--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
 	oReport:SetLandscape()

	//Verifica os parâmetros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.F.)
	
	oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTMP}) 

    TRCell():New( oSection  ,"C1_NUM"            ,cAliasTMP  ,"Nro. S.C."	            )  
    TRCell():New( oSection  ,"C1_ITEM"           ,cAliasTMP  ,"Item da S.C."	        )  
    TRCell():New( oSection  ,"C1_DESCRI"         ,cAliasTMP  ,"Descr. Item"	            )       
    TRCell():New( oSection  ,"C1_CC"             ,cAliasTMP  ,"C.C."	    	        )
    TRCell():New( oSection  ,"CTT_DESC01"        ,cAliasTMP  ,"NOME C.C."	            )
    TRCell():New( oSection  ,"C1_CODCOMP"        ,cAliasTMP  ,"Comprador"               )
    TRCell():New( oSection  ,"Y1_NOME"           ,cAliasTMP  ,"Nome Comprador"	        )
    TRCell():New( oSection  ,"C1_XTPREQ"         ,cAliasTMP  ,"Tipo da S.C."	    	)
    TRCell():New( oSection  ,"ZA4_UTEIS"         ,cAliasTMP  ,"DIAS UTEIS"	            )
    TRCell():New( oSection  ,"ZA4_CORRID"        ,cAliasTMP  ,"DIAS CORRIDOS"	    	)
    TRCell():New( oSection  ,"Data de Emissao"   ,cAliasTMP  ,"Data de Emissão"         )
    TRCell():New( oSection  ,"Data de Alteração" ,cAliasTMP  ,"Data da Última Alteração"         )
    TRCell():New( oSection  ,"Inicio da SLA"     ,cAliasTMP  ,"Inicio da SLA"           )
    TRCell():New( oSection  ,"Vencimento da SLA" ,cAliasTMP  ,"Vencimento da SLA"       )
    TRCell():New( oSection  ,"C1_PEDIDO"         ,cAliasTMP  ,"Nro. Pedido/Contrato"    )
    TRCell():New( oSection  ,"C1_OBS"            ,cAliasTMP  ,"Descrição do Status"     )
        
    oReport:PrintDialog()

Return

//----------------------------------------------------------
Static Function  ReportPrint(oReport)
    Local oSection     := oReport:Section(1)
    Local cStatus      := ""
    Local cNro         := ""
    Local dDtAlt       := ctod("  /  /  ")     
    Local cQry         := ""
    Local cTabela   

    //Monta Tmp
    TmpPedido()

	oReport:SetMeter( Contar(cAliasTMP,"!Eof()") )
	// Secção 1
	oSection:Init()

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()
        cStatus := ""
        cNro    := ""
        nTipo   := 0

        If (cAliasTMP)->C1_XCPARCE = "S"   .and. Empty((cAliasTMP)->C1_XNUMCTP)
           cStatus := "Contrato de Parceria, Aguardando Compras"
           nTipo   := 1
        EndIf
        If (cAliasTMP)->C1_XCPARCE <> "S"  .and. Empty((cAliasTMP)->C1_PEDIDO) 
            cStatus := "Pedido de Compras, Aguardando Compras"
            nTipo   := 1
        Endif
        If (cAliasTMP)->C1_XCPARCE <> "S"  .and. !Empty((cAliasTMP)->C1_PEDIDO) 
           cStatus := "Pedido de Compras Criado, Aguardando Cotação."
           cNro    := (cAliasTMP)->C1_PEDIDO
           nTipo   := 2
        Endif
        If (cAliasTMP)->C1_XCPARCE = "S"   .and. !Empty((cAliasTMP)->C1_XNUMCTP)
           cStatus := "Contrato de Parceria Criado, Aguardando Cotação."
            cNro   := (cAliasTMP)->C1_XNUMCTP
            nTipo  := 3 
        EndIf
        
        If  nTipo = mv_par03
            
            
            cTabela := GetNextAlias()
            dDtAlt  := ctod("  /  /  ")   
            cQry    := " "        
            cQry    := "   SELECT MAX(ZH_DATAI) DATAI                     "
            cQry    +=	"        FROM " + RetSQLName("SZH")      + " SZH "
            cQry    +=	" 		    WHERE 	SZH.ZH_FILIAL 	  = '" + xFilial("SZH") + "'"
            cQry    +=	" 			    AND SZH.ZH_ORIGEM     = 'SC' "
            cQry    +=	" 			    AND SZH.ZH_OPER       = 'A' "
            cQry    +=	" 			    AND SZH.ZH_DOCTO      = '" + (cAliasTMP)->C1_NUM  + "'"
            cQry    +=	" 		        AND SZH.D_E_L_E_T_  = ' ' "
            cQry    := ChangeQuery(cQry)
            DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cTabela,.T.,.T.)

            If Select(cTabela) > 0
               dDtAlt := (cTabela)->DATAI
            EndIf
            (cTabela)->(DbCloseArea())
            
            
            // Incrementa a mensagem na régua.
            oReport:IncMeter()
            
            oSection:Cell( 01 ):SetValue(           (cAliasTMP)->C1_NUM                          )    
            oSection:Cell( 02 ):SetValue(           (cAliasTMP)->C1_ITEM                         )    
            oSection:Cell( 03 ):SetValue(           (cAliasTMP)->C1_DESCRI                       )    
            oSection:Cell( 04 ):SetValue(           (cAliasTMP)->C1_CC                           )   
            oSection:Cell( 05 ):SetValue(  Alltrim( (cAliasTMP)->CTT_DESC01   )                  ) 
            oSection:Cell( 06 ):SetValue(  Alltrim( (cAliasTMP)->C1_CODCOMP   )                  )
            oSection:Cell( 07 ):SetValue(  Alltrim( (cAliasTMP)->Y1_NOME      )  )  
            
            oSection:Cell( 08 ):SetValue(  Alltrim( (cAliasTMP)->C1_XTPREQ    )                  )   
            oSection:Cell( 09 ):SetValue(  		    (cAliasTMP)->ZA4_UTEIS                       )  
            oSection:Cell( 10 ):SetValue(  	        (cAliasTMP)->ZA4_CORRID                      )   
          
                          
            oSection:Cell( 11 ):SetValue(  Alltrim( (cAliasTMP)->EMISSAO      )                  ) 
 
            If empty(dDtAlt)
               oSection:Cell( 12 ):SetValue(  Alltrim( dDtAlt )                  ) 
               oSection:Cell( 13 ):SetValue(  (cAliasTMP)->EMISSAO                        ) 
               oSection:Cell( 14 ):SetValue(  CTOD((cAliasTMP)->EMISSAO)  + (cAliasTMP)->ZA4_CORRID ) 
               
            else
               dDtAlt := SUBSTR(dDtAlt,7,2) + '/' + SUBSTR(dDtAlt,5,2) + '/' + SUBSTR(dDtAlt,1,4) 
               oSection:Cell( 12 ):SetValue(  Alltrim( dDtAlt )                  ) 
               oSection:Cell( 13 ):SetValue(  Alltrim( dDtAlt  )                ) 
               oSection:Cell( 14 ):SetValue(   ctod(dDtAlt) + (cAliasTMP)->ZA4_CORRID ) 
                 
            Endif       
            oSection:Cell( 15 ):SetValue(  Alltrim( cNro   )                                     ) 
            oSection:Cell( 16 ):SetValue(  Alltrim( cStatus  )                                   )

            oSection:PrintLine()	
        Endif

	    (cAliasTMP)->(dbSkip() )
	
	EndDo               
	oSection:Finish()	           

Return

Static Function TmpPedido()
    Local cQuery    	:= ""
	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf
    cQuery := " "
	cQuery := " SELECT  SC1.C1_NUM       ,						    	            "
	cQuery += "         SC1.C1_ITEM      ,					                        "
	cQuery += "         SC1.C1_XTPREQ    , 							                "	
	cQuery += "         SC1.C1_DESCRI    , 							                "
	cQuery += "         SC1.C1_CC        ,				    			            "
	cQuery += "         CTT.CTT_DESC01   ,				    	    	            "
	cQuery += "         SC1.C1_CODCOMP   , 							                " 
	cQuery += "         SC1.C1_XCPARCE   , 							                " 
    cQuery += "         SC1.C1_OBS       , 							                " 
    cQuery += "         SC1.C1_XNUMCTP   , 							                " 
	cQuery += "         SY1.Y1_NOME      , 							                " 
	cQuery += "         SC1.C1_PEDIDO    , 							                " 
	cQuery += "         ZA4.ZA4_UTEIS    , 							                " 
	cQuery += "         ZA4.ZA4_CORRID   , 							                " 
    cQuery += "  SUBSTR(SC1.C1_EMISSAO,7,2)||'/'||SUBSTR(SC1.C1_EMISSAO,5,2)||'/'||SUBSTR(SC1.C1_EMISSAO,1,4) EMISSAO  "
	cQuery += " FROM " + RetSQLName('SC1') + " SC1 " 
    cQuery += " LEFT JOIN " + RetSQLName('CTT') + " CTT "              
    cQuery += "     ON CTT.CTT_FILIAL =   '2010'"	
    cQuery += "     AND CTT.CTT_CUSTO = SC1.C1_CC                  "
    cQuery += "     AND CTT.D_E_L_E_T_ = ' '                       "
    cQuery += " LEFT JOIN " + RetSQLName('SY1') + " SY1 "              
    cQuery += "     ON SY1.Y1_FILIAL =   '201002'"	
    cQuery += "     AND SY1.Y1_COD = SC1.C1_CODCOMP                "
    cQuery += "     AND SY1.D_E_L_E_T_ = ' '                       "
    cQuery += " LEFT JOIN " + RetSQLName('ZA4') + " ZA4 "              
    cQuery += "     ON  ZA4.ZA4_FILIAL =   '" + xFilial("SC1") + "'"
    cQuery += "     AND ZA4.ZA4_TPDOC = SC1.C1_XTPREQ              "
    cQuery += "     AND ZA4.D_E_L_E_T_ = ' '                       "
	cQuery += "     AND ZA4.ZA4_PROCES = 'CS'                      "
	cQuery += " WHERE SC1.D_E_L_E_T_ = ' '									                        "
	cQuery += " AND SC1.C1_FILIAL     =	'" + xFilial("SC1") + "'"
    cQuery += " AND SC1.C1_EMISSAO BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "' "	
	cQuery += " ORDER BY SC1.C1_NUM, SC1.C1_ITEM	" 
    cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return


/*/{Protheus.doc} CriaSx1
//TODO Cria grupo de perguntas, caso não exista.

@author 	Sandro Ferreira
@since 		05/07/2021
@version 	P12
@type 		function
/*/
Static Function CriSx1()

	Local aAreaAnt 	:= GetArea()
	Local aAreaSX1 	:= SX1->(GetArea())
	Local nY 		:= 0
	Local nJ 		:= 0
	Local aReg 		:= {}
	
	aAdd(aReg,{cPerg,"01","De Data Emissão ","mv_ch1","D", 30,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aReg,{cPerg,"02","Até Data Emissão","mv_ch2","D", 30,0,0,"G","(mv_par02>=mv_par01)","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aReg,{cPerg,"03","Escolha o Status","mv_ch3","N", 30,0,0,"N","","mv_par03","Aguard. Compras","","","Pedido Criado","","","Contrato Criado","","","","","","","",""})
	aAdd(aReg,{"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_CNT01","X1_VAR02","X1_DEF02","X1_CNT02","X1_VAR03","X1_DEF03","X1_CNT03","X1_VAR04","X1_DEF04","X1_CNT04","X1_VAR05","X1_DEF05","X1_CNT05","X1_F3","X1_PYME","X1_GRPSXG","X1_HELP","X1_PICTURE"})
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	For ny := 1 To Len(aReg) - 1
		If !DbSeek( PadR( aReg[ny,1], 10) + aReg[ny,2])
			RecLock("SX1", .T.)
			For nJ := 1 To Len(aReg[ny])
				FieldPut( FieldPos( aReg[Len( aReg)][nJ] ), aReg[ny,nJ] )
			Next nJ
			MsUnlock()
		EndIf
	Next ny	
	
	RestArea(aAreaSX1)
	RestArea(aAreaAnt)

Return


