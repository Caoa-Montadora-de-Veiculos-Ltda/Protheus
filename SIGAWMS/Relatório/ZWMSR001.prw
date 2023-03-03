#Include "Protheus.ch"
#Include "Topconn.ch"
//#INCLUDE "ZWMSR001.CH"
//---------------------------------------------------------------------------
/*/{Protheus.doc} ZWMSR001
Relatorio checagem embarque conferencia 
@author Antonio Oliveira
@since 11/02/2020
@version 2.0
/*/
//---------------------------------------------------------------------------
User Function ZWMSR001()
Local oReport  // objeto que contem o relatorio
Local aAreaDCW := DCW->( GetArea() )
Local aAreaDCX := DCX->( GetArea() )
Local aAreaDCY := DCY->( GetArea() )
Local aAreaDCZ := DCZ->( GetArea() )
Local nOpca    := 1
Local aPergs   := {}
Local dDtIni   := Date()    //MV_PAR01 = DataInicial
Local dDtFim   := Date()    //MV_PAR02 = DataFinal
Private aRetP  := {}

aAdd( aPergs ,{1,"Data de      ",dDtIni      ," ",'.T.'," " ,'.T.',80,.F.})
aAdd( aPergs ,{1,"Data até     ",dDtFim      ," ",'.T.'," " ,'.T.',80,.T.})


If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Impressão Check-Out Conferência") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a impressão de Check-Out de Conferência") SIZE 268, 8 OF oDlg PIXEL
   @ 38, 15 SAY OemToAnsi("Da Caoa Montadora.") SIZE 268, 8 OF oDlg PIXEL
   @ 48, 15 SAY OemToAnsi("Confirma Geração do Documento ? ") SIZE 268, 8 OF oDlg PIXEL
   DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
   DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
   ACTIVATE MSDIALOG oDlg CENTER

   If nOpca == 0
      Return()
   Endif

	oReport := ReportDef()
	oReport:PrintDialog()

	RestArea( aAreaDCW )
	RestArea( aAreaDCX )
	RestArea( aAreaDCY )
	RestArea( aAreaDCZ )

Endif

Return     
//----------------------------------------------------------
// Definições do relatório
//----------------------------------------------------------
Static Function ReportDef()
Local oReport, oSection1
//Local oSection2    
//Local cEmbarq := DCW->DCW_EMBARQ
	oReport:= TReport():New("ZWMSR001",'CHECK-OUT Conferência',"ZWMSR001", {|oReport| ReportPrint(oReport)},'Conferência') // CHECK-OUT conferencia
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	
	//Verifica os parâmetros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.F.)
	
	oSection1 := TRSection():New(oReport,"",{"DCW"}) 

	TRCell():New(oSection1,"DCW_EMBARQ","DCW",'Recebimento','',10)
	TRCell():New(oSection1,"DCW_SITEMB","DCW",'Status','',40)
	
	//oSection2 := TRSection():New(oReport,"",{"DCX"}) 
	TRCell():New(oSection1,"DCX_DOC"   ,"DCX",'Nota','',20)
	TRCell():New(oSection1,"DCX_SERIE" ,"DCX",'Serie','',10)
 	TRCell():New(oSection1,"DCW_DATGER","DCW",'Data','',20)   
	TRCell():New(oSection1,"DCX_FORNEC","DCX",'Fornec','',10)
	TRCell():New(oSection1,"DCX_LOJA"  ,"DCX",'Loja','',10)
    TRCell():New(oSection1,"A2_NOME"   ,"SA2",'Nome','',40)
    TRPosition():New(oSection1,"SA2",1,{|| xFilial("SA2")+DCX->DCX_FORNEC+DCX->DCX_LOJA})	
		
	//oSection3 := TRSection():New(oReport,"",{"DCY","SB1"})
	//TRCell():New(oSection3,"DCY_PRDORI","DCY")
	//TRCell():New(oSection3,"DCY_PROD","DCY")
	//TRCell():New(oSection3,"B1_DESC","SB1")
	//TRCell():New(oSection3,"B1_UM","SB1")
	//TRCell():New(oSection3,"DCY_LOTE","DCY")
	//TRCell():New(oSection3,"DCY_SUBLOT","DCY")
	//TRCell():New(oSection3,"LACUNA1"   ,/*Alias*/, STR0003 ,/*Picture*/, 30  ,/*lPixel*/,{|| "______________________________"}  )  //"Lote"	
	//TRCell():New(oSection3,"DCY_QTORIG","DCY")
	//TRCell():New(oSection3,"DCY_QTCONF","DCY")
	//TRCell():New(oSection3,"NQTDIFERE","DCY",STR0002,,,/*lPixel*/,{ || (DCY->DCY_QTCONF - DCY->DCY_QTORIG) }) // Qt. Diferenca
	//TRCell():New(oSection3,"LACUNA2"   ,/*Alias*/, STR0004  ,/*Picture*/, 30 ,/*lPixel*/,{|| "______________________________"}  )  //"Quantidade"
	//TRPosition():New(oSection3,"SB1",1,{|| xFilial("SB1")+DCY->DCY_PROD})	                        
                               	                                                                                    
	//oSection4 := TRSection():New(oReport,"",{"DCZ","DCD"})
	//TRCell():New(oSection4,"DCZ_OPER"    ,"DCZ")
	//TRCell():New(oSection4,"DCD_NOMFUN"  ,"DCD")                                                 	
	
	//oSection4:BeginQuery()	
	//BeginSql Alias 'QRYDCZ'      	
	//	SELECT DISTINCT DCZ_OPER
	//	  FROM %table:DCZ% DCZ 
	//	 WHERE DCZ.DCZ_FILIAL = %xfilial:DCZ% 
	//	   AND DCZ.DCZ_EMBARQ = %Exp:cEmbarq%
	//	   AND DCZ.%NotDel%
	//	 ORDER BY DCZ.DCZ_OPER
	//EndSql		                                 				
	//oSection4:EndQuery()		                            	
Return(oReport) 
//----------------------------------------------------------
// Impressão do relatório
//----------------------------------------------------------
Static Function ReportPrint(oReport)
Local oSection1  := oReport:Section(1)
Local _cStatus   := ' '
//Local oSection2  := oReport:Section(2)
//Local oSection3  := oReport:Section(3)
//Local oSection4  := oReport:Section(4)

	/*If	MV_PAR01 == 2 .Or. MV_PAR02 == 2 
	    oSection3:SetLineBreak()
	Endif	                            

	If	MV_PAR01 == 2 //Imprimir Lote? Nao
		oSection3:Cell("DCY_LOTE"):Disable()
		oSection3:Cell("DCY_SUBLOT"):Disable()
	Else
		oSection3:Cell("LACUNA1"):Disable()
	EndIf

	If	MV_PAR02 == 2 //Imprimir Quantidades ? Nao
		oSection3:Cell("DCY_QTORIG"):Disable()
		oSection3:Cell("DCY_QTCONF"):Disable()				
		oSection3:Cell("NQTDIFERE"):Disable()	
	Else
		oSection3:Cell("LACUNA2"):Disable()		
	EndIf*/

	oReport:SetMeter(DCW->( LastRec() ))
	// Secção 1
	oSection1:Init()
	//oSection1:PrintLine()
	//oSection1:Finish()
	// Secção 2	            
	//oSection2:Init()

	dbSelectArea('DCW')
	DCW->(dbGoTop())
	DCW->(dbSetOrder(1))
    While !DCW->( Eof() )  
	
	if DCW->DCW_DATGER >= aRetP[1] .AND. DCW->DCW_DATGER <= aRetP[2] 
        dbSelectArea('DCX')
	    DCX->( dbSetOrder(1))
	    DCX->( dbSeek(xFilial('DCX')+DCW->DCW_EMBARQ) )
	    While !DCX->( Eof() ) .And. DCX->DCX_FILIAL+DCX->DCX_EMBARQ == xFilial('DCX')+DCW->DCW_EMBARQ
           If DCW->DCW_SITEMB = '6'
              _cStatus := 'Conferido'
           else
              _cStatus := 'Em Andamento' 
           EndIf

           oSection1:Cell("DCW_EMBARQ"):SetValue(DCW->DCW_EMBARQ)
           oSection1:Cell("DCW_SITEMB"):SetValue(_cStatus)
           oSection1:Cell("DCX_DOC"):SetValue(DCX->DCX_DOC)
           oSection1:Cell("DCX_SERIE"):SetValue(DCX->DCX_SERIE)
           oSection1:Cell("DCW_DATGER"):SetValue(DCW->DCW_DATGER)
           oSection1:Cell("DCX_FORNEC"):SetValue(DCX->DCX_FORNEC)
           oSection1:Cell("DCX_LOJA"):SetValue(DCX->DCX_LOJA)
           oSection1:Cell("A2_NOME"):SetValue(SA2->A2_NOME)
           //DCW_DATGER
		   oSection1:PrintLine()		
		   DCX->(dbSkip() )
	    End
	ENDIF

	DCW->(dbSkip() )
	
	EndDo               
	oSection1:Finish()
	
    // Secção 3	
	/*oSection3:Init()
	dbSelectArea('DCY')
	DCY->( dbSetOrder(2))
	DCY->( dbSeek(xFilial('DCY')+DCW->DCW_EMBARQ) )
	While !DCY->( Eof() ) .And. DCY->DCY_FILIAL+DCY->DCY_EMBARQ == xFilial('DCY')+DCW->DCW_EMBARQ
		If DCY->DCY_PRDORI == DCY->DCY_PROD
			oSection3:Cell("DCY_PRDORI"):SetValue(DCY->DCY_PRDORI)
			oSection3:Cell("DCY_PROD"):SetValue(DCY->DCY_PROD)
		Else
			oSection3:Cell("DCY_PRDORI"):SetValue("")
			oSection3:Cell("DCY_PROD"):SetValue(DCY->DCY_PROD)
		EndIf
		oSection3:PrintLine()
		DCY->( dbSkip() )
	EndDo       
	oSection3:Finish()		
	// Secção 4	         	
	oSection4:Init()
	While  !oReport:Cancel() .And. !('QRYDCZ')->( Eof() )
		oSection4:Cell("DCZ_OPER"):SetValue(('QRYDCZ')->DCZ_OPER)	
		Osection4:Cell("DCD_NOMFUN"):SetValue( Posicione("DCD",1,xFilial("DCD")+('QRYDCZ')->DCZ_OPER,"DCD_NOMFUN"))
		oSection4:PrintLine()
		('QRYDCZ')->( dbSkip() )
	EndDo       
	oSection4:Finish()*/		           
	oReport:IncMeter()
Return