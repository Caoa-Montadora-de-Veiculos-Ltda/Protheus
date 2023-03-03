#Include "RWMAKE.CH"
#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
/*
=============================================================================
Programa............:CMVFIS001
Autor...............:Rafael Garcia 
Data................:06/02/2018
Descrição/Objeto....:RELATÓRIO DE GNRE VS NF’S - GAP FIS014
Uso.................:Caoa
=============================================================================
*/ 
User Function CMVFIS001()
	Private oReport
	Private oSection1    
	Private aParambox := {}  
	Private nTtlVC    := 0
	Private nTtlIC    := 0

	AAdd(aParamBox, {1, "Emissão de"		, CToD(Space(8)),, ,,	, 070	, .T.	})
	AAdd(aParamBox, {1, "Emissão até"		, CToD(Space(8)),, ,,	, 070	, .T.	})

	IF ParamBox(aParambox, "Relatorio GNRE X NF"	,, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .T. /*lUserSave*/)
		oReport := ReportDef()  
		oReport:PrintDialog()
	endif
Return  

//--------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Description: Define estrutura do relatório                                                      
@param 
@return 
@author  
/*/
//--------------------------------------------------------------

Static Function ReportDef()

	SET DATE FORMAT TO "dd/mm/yyyy"
	SET CENTURY ON
	SET DATE BRITISH

	//######################
	//##Cria Objeto TReport#
	//######################
	oReport := TReport():New("CMVFIS001","Relatório GNRE X NF",PADR("CMVFIS001",10),{|oReport| PrintReport(oReport)},"Relatorio GNRE X NF")
	oReport:lParamPage := .F.   
	oReport:SetLandscape(.T.)
	//oReport:SetPortrait(.T.)

	//###############
	//#Define Sessao1#
	//###############
	oSection1:= TRSection():New(oReport,"Estado","")
	TRCell():New(oSection1,"Periodo"	    ,	,"",,50)

	TRCell():New(oSection1,"UF"	     		,	,"",,20)


	oSection2 := TRSection():New(oReport,"Notas",{"TRBB"})
	oSection2 :SetReadOnly()
	TRCell():New(oSection2,"Tipo"  		,	   ,"Tipo"    	     	,	,8)
	TRCell():New(oSection2,"Doc"   		,"TRBB","Numero da NF"	 	,	,TamSX3("F3_NFISCAL")[1]) 
	TRCell():New(oSection2,"Serie" 	    ,"TRBB","Série"      	 	,   ,TamSX3("F3_SERIE")[1]) 
	TRCell():New(oSection2,"Guia" 	    ,"TRBB","Guia"      	 	,   ,TamSX3("F6_NUMERO")[1])	
	TRCell():New(oSection2,"ESTADO"     ,"TRBB","UF"         	 	,   ,TamSX3("F3_ESTADO")[1]) 	
	TRCell():New(oSection2,"Fornece"    ,      ,"Cliente/Fornecedor",	,TamSX3("F3_CLIEFOR")[1]+TamSX3("F3_LOJA")[1])
	TRCell():New(oSection2,"Nome"       ,      ,"Nome"       		,	,TamSX3("A2_NOME")[1])
	TRCell():New(oSection2,"Valor"      ,"TRBB","Valor Bruto NF"    ,"@E 99,999,999,999.99"	,TamSX3("F3_VALCONT")[1]) 
	TRCell():New(oSection2,"ValICM"     ,"TRBB","Valor Tot. ICMS ST","@E 99,999,999,999.99"	,TamSX3("F3_ICMSRET")[1]) 	

	oSection3:= TRSection():New(oReport,"TOTAL","")
	TRCell():New(oSection3,"Tot_Cred"	,	   ,"Total Credito"					,"@E 99,999,999,999.99" ,20)
	TRCell():New(oSection3,"Tot_deb"	,	   ,"Total Debito "					,"@E 99,999,999,999.99" ,20)
	
	oSection4:= TRSection():New(oReport,"TOTAL","")
	TRCell():New(oSection4,"Tot_Cred"	,	   ,"Total Geral"					,"@E 99,999,999,999.99" ,20)
	TRCell():New(oSection4,"Tot_deb"	,	   ,"Total Geral"					,"@E 99,999,999,999.99" ,20)
	
	//oSection5:= TRSection():New(oReport,"TOTAL Geral","")
	//TRCell():New(oSection5,"Tot_Cred"	,	   ,"Total Geral"					,"@E 99,999,999,999.99" ,20)
	//TRCell():New(oSection5,"Tot_deb"	,	   ,"Total Geral"					,"@E 99,999,999,999.99" ,20)

Return oReport 


//--------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Description: Impressão do relatório
@param 
@return 
@author  
@since 
/*/
//--------------------------------------------------------------

Static Function PrintReport(oReport)
	local cQuery := " "
	local cEst   := " "
	local cCli   := " "
	local lPasso := .T.	
	LOCAL nTotalC    := 0
	LOCAL nTotalD    := 0
	LOCAL nTotalGC   := 0
	LOCAL nTotalGD   := 0
		
	cQuery := "	SELECT DISTINCT SF3.F3_ESTADO AS ESTADO,SF3.F3_CFO,SF3.F3_NFISCAL as DOC,SF3.F3_SERIE AS SERIE,SF3.F3_TIPO,"
	cQuery += " SF3.F3_CLIEFOR AS CLI,SF3.F3_LOJA AS LOJA,SF3.F3_VALCONT AS VALOR,SF3.F3_ICMSRET AS VALICM,SF6.F6_NUMERO AS GUIA "
	cQuery += " FROM "+RETSQLNAME("SF3")+" SF3 "
	cQuery += " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON "
	cQuery += " SA1.A1_COD = SF3.F3_CLIEFOR AND "
	cQuery += " SA1.A1_LOJA = SF3.F3_LOJA "
	cQuery += " INNER JOIN "+RETSQLNAME("SF6")+" SF6 ON "
	cQuery += " SF3.F3_FILIAL = SF6.F6_FILIAL AND SF6.F6_DOC = SF3.F3_NFISCAL AND SF6.F6_SERIE = SF3.F3_SERIE"
	cQuery += " AND SF3.F3_FILIAL = SF6.F6_FILIAL AND SF6.F6_DOC = SF3.F3_NFISCAL AND SF6.F6_SERIE = SF3.F3_SERIE AND "
	cQuery += " F6_CLIFOR = F3_CLIEFOR AND F6_LOJA = F3_LOJA AND "
	cQuery += " SF3.F3_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND SF3.F3_DTCANC=' ' and SF3.D_E_L_E_T_ = ' ' AND SF3.F3_FILIAL='"+XFILIAL("SF3")+"'"
	cQuery += " AND SF3.F3_ICMSRET>0   AND  SF3.F3_CREDST = ' ' AND SA1.A1_INSCR<>'ISENTO'"
	cQuery += " ORDER BY SF3.F3_ESTADO, SF3.F3_TIPO, CLI, LOJA, DOC, SERIE "

	TCQUERY cQuery NEW ALIAS "TRBB"	 
	dbSelectArea("TRBB")
	TRBB->(dbGoTop())
	
	While TRBB->(!EOF())
		cEst:=TRBB->ESTADO
		nTotalC    := 0
		nTotalD    := 0  
		oReport:Section(1):Init()    
		oReport:SetMeter(TRBB->(RecCount()))
		//oReport:Section(1):Cell("UF"   ):SetBlock({|| 'UF: '+ TRBB->ESTADO })
		oReport:Section(1):Cell("Periodo"   ):SetBlock({|| 'ICMS ST - Periodo '+DTOC(MV_PAR01)+' ate '+DTOC(MV_PAR02)  })

		oReport:Section(1):PrintLine()   
		oReport:Section(1):Finish() 

		oReport:Section(2):Init()             

		While TRBB->(!EOF()) .and. cEst==TRBB->ESTADO

			if oReport:Cancel()
				Exit
			Endif 
			oReport:IncMeter()
            IF cCli <> TRBB->CLI .AND. !lPasso
		       lPasso := .F.
		       oReport:Section(2):Finish() 
		       oReport:Section(3):Init()    
		       oReport:Section(3):Cell("Tot_cred"):SetBlock({||nTtlVC })
		       oReport:Section(3):Cell("Tot_deb" ):SetBlock({||nTtlIC})

		       oReport:Section(3):PrintLine()   
		       oReport:Section(3):Finish() 

		       //oReport:Section(4):Init()    
		       //oReport:Section(4):Cell("Tot_cred"):SetBlock({||nTtlVC })
		       //oReport:Section(4):Cell("Tot_deb" ):SetBlock({||nTtlIC})

		       //oReport:Section(4):PrintLine()   
		       //oReport:Section(4):Finish() 

               cCli   := TRBB->CLI
               nTtlVC := nTtlVC
               nTtlIC := nTtlIC                 
            ELSE
               cCli   := TRBB->CLI
               nTtlVC := nTtlVC + TRBB->VALOR
               nTtlIC := nTtlIC + TRBB->VALICM                
            ENDIF

		    oReport:Section(2):Init()
			oReport:IncMeter()
			 
			oReport:Section(2):Cell("FORNECE"):SetBlock({||TRBB->CLI+'-'+TRBB->LOJA})                                                
			IF VAL (TRBB->F3_CFO) > 5000
				oReport:Section(2):Cell("TIPO"):SetBlock({|| "SAIDA"}) 
				oReport:Section(2):Cell("NOME"):SetBlock({|| POSICIONE("SA1",1,XFILIAL("SA1")+TRBB->CLI+TRBB->LOJA,"A1_NOME")})  
			ELSE 
				oReport:Section(2):Cell("TIPO"):SetBlock({|| "ENTRADA"})  
				oReport:Section(2):Cell("NOME"):SetBlock({|| POSICIONE("SA2",1,XFILIAL("SA2")+TRBB->CLI+TRBB->LOJA,"A2_NOME")}) 
			ENDIF	
			
			IF VAL(TRBB->F3_CFO) > 5000
				nTotalD += TRBB->VALICM
			ELSE
				nTotalC	+= TRBB->VALICM
			ENDIF	

			oReport:Section(2):PrintLine()   
			TRBB->(DBSKIP())        
		end	

        nTotalGC := nTotalGC + nTotalC
        nTotalGD := nTotalGD + nTotalD

		oReport:Section(2):Finish() 
		oReport:Section(3):Init()    
		oReport:Section(3):Cell("Tot_cred"  ):SetBlock({||nTotalC })
		oReport:Section(3):Cell("Tot_deb"   ):SetBlock({||nTotalD})

		oReport:Section(3):PrintLine()   
		oReport:Section(3):Finish() 
	End 
	
	oReport:Section(3):Finish() 
	oReport:Section(4):Init()    
	oReport:Section(4):Cell("Tot_cred"  ):SetBlock({||nTotalGC })
	oReport:Section(4):Cell("Tot_deb"   ):SetBlock({||nTotalGD})

	oReport:Section(4):PrintLine()   
	oReport:Section(4):Finish() 
	
	TRBB->(DbCloseArea())  

Return  