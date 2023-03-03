#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FONT.CH"  
#INCLUDE 'TOTVS.CH'                                        
/*
=====================================================================================
Programa.:              ZPECR003 - RELATORIO REEMISSÃO ORÇAMENTO
Autor....:              Antonio Carlos        
Data.....:              27/09/2021                                                                                                            
Descricao / Objetivo:   Relatório REEMISSÃO ORÇAMENTO                     
Doc. Origem:            SIGAPE - 
Solicitante:            CAOA BARUERI
Uso......:              CAOA
Obs......:              Relatório de REEMISSÃO ORÇAMENTO
=====================================================================================
*/
User Function ZPECR003()
Private titulo      := "Relatorio de REEMISSÃO ORÇAMENTO"
Private cDesc1      := "Relatorio de REEMISSÃO ORÇAMENTO"
Private cDesc2      := ""
Private cDesc3      := ""
Private Cabec1      := " "
Private Cabec2      := ""
Private cQry        := ""
Private cString     := "VS3"
Private wnrel       := "ZPECR003"
Private nomeprog    := "ZPECR003"
Private cArqTmp     := ""
Private nLastKey    := 0
Private aDadosR     := {}
Private cMvpar	    := ""
Private tamanho     := "G"
Private lAbortPrint := .F.
Private _lTemDados  := .T.
Private lFirst 		:= .T.
Private oReport
Private oSection1
Private _nTQTD      := 0
Private _nTPCU      := 0
Private _nTPCT      := 0
Private _cNComp     := SPACE(06) 
//Private _cPerg      := "ZPECR003"
Private mv_par01    := dDataBase
Private mv_par02    := dDataBase
Private mv_par03    := " "
Private mv_par04    := " "
Private mv_par05    := " "
Private mv_par06    := " "

IF FWCodEmp() <> '2020' 
   RETURN Nil
ENDIF

IF FWFilial() <> '2001'
   RETURN Nil
ENDIF

//ValidPerg(_cPerg)

//if !Pergunte(_cPerg,.T.)
//	Return
//endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if Select("TRBOR") > 0
	TRBOR->(DBCLOSEAREA())
Endif                                                  
cQry  := " SELECT VS1_FILIAL , VS1_CLIFAT , VS1_LOJA , VS1_NCLIFT , VS1_NUMORC , VS1_DATORC , VS1_CODVEN , VS1_DATVAL , VS1_FORPAG , " +CHR(10) 
cQry  += " VS1_TRANSP , VS1_DESACE , VS1_VALFRE , VS3_XITSUB , VS3_CODITE , VS3_QTDITE , VS3_VALPEC , VS3_VALDES , VS3_VALTOT , VS3_LOCAL , VS1_XPICKI, " +CHR(10)   
cQry  += " A1_END , A1_MUN , A1_EST , A1_TEL , A1_CGC , A1_CEP , B1_DESC , A3_COD , A3_NOME , E4_DESCRI, VS1_NUMNFI, VS1_SERNFI, VS1_VTOTNF, VS1_XPVAW, " +CHR(10) 
cQry  += " CASE "
cQry  += "		WHEN (VS1_STATUS = '0' AND VS1_XBO = ' ') THEN 'EM ANALISE'"
cQry  += "		WHEN (VS1_STATUS = '3')					  THEN 'BLOQUEADO POR CRÉDITO'"
cQry  += "		WHEN (VS1_STATUS = '0' AND VS1_XBO = 'S') THEN 'B.O.'"
cQry  += "		WHEN (VS1_STATUS IN ('X'))				  THEN 'FATURADO'"	
cQry  += "		WHEN (VS1_STATUS IN ('4','F'))			  THEN 'SEPARAÇÃO'"
cQry  += "		WHEN (VS1_STATUS = 'C')					  THEN 'CANCELADO'"
cQry  += " END AS STATUS_ITEM "
cQry  += " FROM " + RetSqlName("VS1")    + " VS1 " +Chr(10) 
cQry  += " LEFT JOIN "+RetSqlName("VS3") + " VS3 " +CHR(10)
cQry  += " ON VS1.VS1_FILIAL = VS3.VS3_FILIAL  "   +CHR(10)
cQry  += " AND VS1.VS1_NUMORC = VS3.VS3_NUMORC "   +CHR(10)
cQry  += " AND VS3.D_E_L_E_T_= ' ' "               +CHR(10)
cQry  += " LEFT JOIN "+RetSqlName("SA1") + " SA1 " +CHR(10)
cQry  += " ON VS1.VS1_CLIFAT = SA1.A1_COD "        +CHR(10)
cQry  += " AND VS1.VS1_LOJA = SA1.A1_LOJA "        +CHR(10)
cQry  += " AND SA1.D_E_L_E_T_= ' ' "               +CHR(10)
cQry  += " LEFT JOIN "+RetSqlName("SB1") + " SB1 " +CHR(10)                                           
cQry  += "        ON VS3.VS3_CODITE = SB1.B1_COD "       +CHR(10)
cQry  += " AND SB1.D_E_L_E_T_= ' ' "               +CHR(10) 
cQry  += " LEFT JOIN "+RetSqlName("SA3") + " SA3 " +CHR(10)                                           
cQry  += " ON SA3.A3_COD = VS1.VS1_CODVEN "        +CHR(10)
cQry  += " AND SA3.D_E_L_E_T_= ' ' "               +CHR(10) 
cQry  += " LEFT JOIN "+RetSqlName("SA4") + " SA4 " +CHR(10) 
cQry  += " ON SA4.A4_COD = VS1.VS1_TRANSP "        +CHR(10)                                          
cQry  += " AND SA4.D_E_L_E_T_= ' ' "               +CHR(10) 
cQry  += " LEFT JOIN "+RetSqlName("SE4") + " SE4 " +CHR(10) 
cQry  += " ON SE4.E4_CODIGO = VS1.VS1_FORPAG "     +CHR(10)                                          
cQry  += " AND SE4.D_E_L_E_T_= ' ' "               +CHR(10) 
cQry  +=  "WHERE "                                 +CHR(10) 
cQry  += " VS1.D_E_L_E_T_= ' ' "                   +CHR(10) 
cQry  += " AND VS1.VS1_FILIAL = '" + xFilial("VS1") + "'" +CHR(10)   
cQry  += " AND VS1.VS1_NUMORC = '" + VS1_NUMORC + "'"     +CHR(10)
cQry  := ChangeQuery(cQry)

MemoWrite("C:\TEMP\ZPECR003.SQL",cQry) 
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"TRBOR",.F.,.t.)
Processa({|| ImpRel()},,"Imprimindo...")
TRBOR->(dbCloseArea())
Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPREL    ºAutor  ³ A.Carlos     o     º Data ³  27/09/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio de REEMISSÃO ORÇAMENTO                    		          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Caoa   	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpRel()
Private oFontC1:= TFont():New( "Arial",16,16,,.F.,,,,.T.,.F. )
Private oFont1:= TFont():New( "Arial",12,12,,.F.,,,,.T.,.F. )
//Private oFont1:= TFont():New( "Arial",15,15,,.F.,,,,.T.,.F. )
Private oFontN:= TFont():New( "Arial",19,19,,.T.,,,,.T.,.F. )
Private oFontL:= TFont():New( "Arial",13,13,,.F.,,,,.T.,.F. )
//Private oFont3:= TFont():New( "Arial",8,8,,.F.,,,,.T.,.F. )
Private oFont3:= TFont():New( "Arial",10,10,,.F.,,,,.T.,.F. )
Private oFont4:= TFont():New( "Arial",12,12,,.T.,,,,.T.,.F. )
Private oFont5:= TFont():New( "Arial",18,18,,.T.,,,,.T.,.F. )
Private oFont6:= TFont():New( "Arial",22,22,,.T.,,,,.T.,.F. )
Private oFont7:= TFont():New( "Arial",14,14,,.T.,,,,.T.,.F. )
Private oFont8:= TFont():New( "Arial",16,16,,.T.,,,,.T.,.F. )
Private _dEntrega:= ""
Private _nSaldo  := 0
Private _nPag    := 0
Private _nTotPg  := 3

Private oPrn
Private _nLin:=150

oPrn:=FWMSPrinter():New(alltrim(TRBOR->VS1_NUMORC),6,,,.T.,) //imprime direto em PDF e inibi a tela de setup
//oPrn:SetPortrait()
//oPrn:SetLandScape()
oPrn:StartPage()

TRBOR->(DBGOTOP())
IF TRBOR->(EOF())
	Aviso("Aviso","Não há dados a serem impressos  !!!",{"Ok"})
   Return
ENDIF

//_nPag++
//CabecMarf(_nPag,_nPag,"P")

ImpItens("P")

If  _nLin > 2300
	oPrn:EndPage()
	oPrn:StartPage()
	_nLin := 0200
EndIf

//oPrn:EndPage()
//oPrn:End()
oPrn:Preview()

Return        


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CabecMarf ºAutor  ³ A.Carlos           º Data ³  27/09/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cabeçalho do relatório 		             		          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CAOA 	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CabecMarf(_nPag,_nTotpg,_cTipo)
	cGrpCompany	:= AllTrim(FWGrpCompany())
	cCodEmpGrp	:= AllTrim(FWCodEmp())
	cUnitGrp	:= AllTrim(FWUnitBusiness())
	cFilGrp		:= AllTrim(FWFilial())

/*	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf

	cLogoD := GetSrvProfString("Startpath","") + "CAOA" + cDescLogo + ".BMP"
*/
//	If !File(cLogoD)
		//cLogoD	:= GetSrvProfString("Startpath","") + "CAOA" + cEmpAnt + ".BMP"
        cLogoD	:= GetSrvProfString("Startpath","") + "LGMID" + ".PNG"
		If !File(cLogoD)
			lMv_Logod := .F.
		EndIf
//	EndIf
	//oPrn:SayBitmap(_nLin,0150,cLogoD,095,096)
	//oPrn:SayBitmap(_nLin,0100,cLogoD,150,096)
   
	oPrn:SayBitmap(_nLin,0100,cLogoD,400,140)
	oPrn:Say( _nLin, 2000,'Data Emissão:  '+ALLTRIM(STR(Day(Date())))+"/"+Substr(MesExtenso(Month(Date())),1,3)+"/"+ALLTRIM(STR(Year(Date()))) , oFont3 )
	_nLin+=050
	oPrn:Say( _nLin, 2000,'Pag: '+Alltrim(Str(_nPag)) , oFont3 )
    _nLin+=050  

	dbSelectArea("SM0")
	dbSetOrder(1)
	If dbSeek(cEmpAnt + TRBOR->VS1_FILIAL)
//	   oPrn:Say( _nLin, 0500,"Empresa: "+SM0->M0_CODIGO+"  -  "+SM0->M0_NOMECOM, oFontN )	
//	   _cMesEmi := Substr(MesExtenso(Month(StoD(TRBPC->EMISSAO))),1,3) //CMonth(StoD(TRBPC->EMISSAO))
	   _nLin+=050                        
       oPrn:Line (_nLin,000,_nLin,2800)
	   _nLin+=075  
	   oPrn:Say( _nLin, 0100,"Empresa: "+SM0->M0_CODIGO+"  -  "+SM0->M0_NOMECOM, oFont3 )     
	   oPrn:Say( _nLin, 1200,'Reemissão do Orçamento: '+ALLTRIM(TRBOR->VS1_NUMORC), oFontN )   
	   _nLin+=050                        
       oPrn:Line (_nLin,000,_nLin,2800)
	   _nLin+=050       
	   //oPrn:Say( _nLin, 0500,'Num. NF: '+ALLTRIM(TRBOR->DB2_DOC)+"       Série: "+ALLTRIM(TRBOR->DB2_SERIE) , oFontC1 )		   
	   //_nLin+=050    	   
	   //oPrn:Say( _nLin, 0500,'Data Emissão: '+STR(Day(Date()))+"/"+STR(Month(Date()))+"/"+STR(Year(Date())) , oFont3 )
       //oPrn:Say( _nLin, 1500,'Data Recebto: '+Substr(TRBOR->DB1_ENTREG,7,2)+"/"+Substr(TRBOR->DB1_ENTREG,5,2)+"/"+Substr(TRBOR->DB1_ENTREG,1,4) , oFontC1 ) 		    
	   //oPrn:Say( _nLin, 2000,'Pag: '+Alltrim(Str(_nPag)) , oFontC1 )
	   //_nLin+=050        
		   
	   oPrn:Say( _nLin, 0100,'Data: '    +Substr(TRBOR->VS1_DATORC,7,2)+"/"+Substr(TRBOR->VS1_DATORC,5,2)+"/"+Substr(TRBOR->VS1_DATORC,1,4) , oFontC1 ) 		    
	   oPrn:Say( _nLin, 0450,'Ped.WEB: '    + TRBOR->VS1_XPVAW  , oFontC1 )	   
	   oPrn:Say( _nLin, 0900,'Picking: '    + TRBOR->VS1_XPICKI  , oFontC1 )
	   oPrn:Say( _nLin, 1300,'Nota Fiscal: '+ TRBOR->VS1_NUMNFI  , oFontC1 )
	   oPrn:Say( _nLin, 1800,'Serie: '      + TRBOR->VS1_SERNFI  , oFontC1 ) 
       oPrn:Say( _nLin, 2000,'Status: '	 + TRBOR->STATUS_ITEM , oFontC1 ) 
	   oPrn:Say( _nLin, 2500,'Vendedor: '+ TRBOR->A3_COD + ' ' + TRBOR->A3_NOME , oFontC1 )
	   _nLin+=050 
	   oPrn:Say( _nLin, 0100,"Cliente: "  + TRBOR->VS1_CLIFATT+'  '+TRBOR->VS1_NCLIFT, oFont3 )			
	   oPrn:Say( _nLin, 1200,"CNPJ: "     + TRBOR->A1_CGC , oFont3 )
	   oPrn:Say( _nLin, 2000,"Telefone: " + TRBOR->A1_TEL , oFont3 ) 
	   _nLin+=050 		       
	   oPrn:Say( _nLin, 0100,"Endereço: " + TRBOR->A1_END , oFont3 )
	   oPrn:Say( _nLin, 1200,"Cidade: "   + TRBOR->A1_MUN , oFont3 )			
	   oPrn:Say( _nLin, 2000,"UF: "       + TRBOR->A1_EST , oFont3 )
	   oPrn:Say( _nLin, 2100,"CEP: "      + TRBOR->A1_CEP , oFont3 )
	   _nLin+=050
       oPrn:Line (_nLin,000,_nLin,2800)
	   _nLin+=050       
   	   oPrn:Say( _nLin, 0100,"Cod.Solicitado", oFont3 ) 	   
   	   oPrn:Say( _nLin, 0350,"Código"        , oFont3 ) 	   
   	   oPrn:Say( _nLin, 0600,"Descrição"     , oFont3 ) 	   
   	   oPrn:Say( _nLin, 1490,"Local"         , oFont3 ) 	   
   	   oPrn:Say( _nLin, 1570,"Quantidade"    , oFont3 ) 	   
   	   oPrn:Say( _nLin, 1800,"Val.Unitário"  , oFont3 ) 	   
   	   oPrn:Say( _nLin, 2000,"Desconto"      , oFont3 ) 	   
   	   oPrn:Say( _nLin, 2260,"Total"         , oFont3 ) 	   
	   _nLin+=050
	   //oPrn:Say( _nLin, 0100,"Especificação do Item " , oFont3 )
	   //_nLin+=050
	   //oPrn:Say( _nLin, 0100,"Tipo Item  (Sped Fiscal)          Observação " , oFont3 )
	   //_nLin+=050                          
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpItens  ºAutor  ³ A.Carlos           º Data ³  27/09/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime Itens			o 		             		          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Caoa                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpItens(_cTipo)
Local _cDoc     :=  ""
Local _cDesc1   :=  ""
Local _cDesc2   :=  ""
Local _nTotal   :=  ""
Local _nValpec  :=  ""
Local _nDesace  :=  ""
Local _nSubpec  :=  ""
Local _nDesc    :=  ""
Local _nQtde    :=  ""
Local _nSubttl  :=  0
Local _nVlTpec  :=  0
Local _nVezes   :=  0

/*oPrn:Box(_nLin,100,_nLin+1300,2799)
oPrn:Line(_nLin,250,_nLin+1300,250) //Sequencia
oPrn:Line(_nLin,440,_nLin+1300,440) //OC
oPrn:Line(_nLin,540,_nLin+1300,540) //Ped Comp
oPrn:Line(_nLin,740,_nLin+1300,740) //Solic
oPrn:Line(_nLin,1490,_nLin+1300,1490) //Cod Item
oPrn:Line(_nLin,1490,_nLin+1300,1490) //Un
oPrn:Line(_nLin,1790,_nLin+1300,1790) //Entrega
oPrn:Line(_nLin,1990,_nLin+1300,1990) //Fabricante
oPrn:Line(_nLin,2290,_nLin+1300,2290) //Marca
oPrn:Line(_nLin,2590,_nLin+1300,2590) //Qtd.Rec
*/

TRBOR->(dbGotop())
While TRBOR->(!EOF())
        
        _cDesc1 := SubStr(AllTrim(TRBOR->B1_DESC),01,55)
		_cDesc2 := SubStr(AllTrim(TRBOR->B1_DESC),56,55)

		IF _cDoc   <>  ALLTRIM(TRBOR->VS1_NUMORC) .OR. _nLin > 2300
    	   _cDoc   :=  ALLTRIM(TRBOR->VS1_NUMORC)
           _nLin   :=  0200
           _nVezes++  
           IF _nVezes > 1
              oPrn:EndPage()
              oPrn:StartPage()
           ENDIF
           _nPag++
           CabecMarf(_nPag,_nPag,"P")
        ENDIF

        _nSubttl  +=  TRBOR->VS3_QTDITE
		_nVlTpec  :=  TRBOR->VS3_QTDITE * TRBOR->VS3_VALPEC
        _nSubpec  :=  Transform(_nSubttl, "@E 99,999,999.99")
        _nTotal   :=  Transform(_nVlTpec, "@E 99,999,999.99")
        _nValpec  :=  Transform(TRBOR->VS3_VALPEC, "@E 99,999,999.99")
        _nDesc    :=  Transform(TRBOR->VS3_VALDES, "@E 99,999,999.99") 
		_nQtde    :=  Transform(TRBOR->VS3_QTDITE, "@E 999,999.99") 
        
		oPrn:Say( _nLin, 0100,TRBOR->VS3_XITSUB, oFont3 ) 
		oPrn:Say( _nLin, 0350,TRBOR->VS3_CODITE, oFont3 ) 
		oPrn:Say( _nLin, 0600,_cDesc1 , oFont3 )
		oPrn:Say( _nLin, 1520,TRBOR->VS3_LOCAL , oFont3 ) 
		oPrn:Say( _nLin, 1610,_nQtde  , oFont3 ) 
		oPrn:Say( _nLin, 1800,_nValpec, oFont3 ) 
		oPrn:Say( _nLin, 2000,_nDesc  , oFont3 )
		oPrn:Say( _nLin, 2200,_nTotal , oFont3 ) 
		_nLin+=050
	
		If !Empty(_cDesc2)
			oPrn:Say( _nLin, 0600,_cDesc1 , oFont3 )
			_nLin+=050
		EndIf
		_nSubpec  :=  Transform(TRBOR->VS1_VTOTNF, "@E 99,999,999.99")
		_nDesace  :=  Transform(TRBOR->VS1_DESACE, "@E 99,999,999.99")
		/*
		_nLin+=100
  		oPrn:Say( _nLin, 0815,"Sub Total Peças"   , oFont3 )	
        oPrn:Say( _nLin, 1100,_nSubpec, oFont3 )
		_nLin+=100
	    oPrn:Say( _nLin, 0200,"Observações:"      , oFont3 )
		_nLin+=50
		oPrn:Say( _nLin, 0200,"****  Totais  ****", oFont3 )
		_nLin+=50
  		oPrn:Say( _nLin, 0200,"Peças: "           , oFont3 )
		_nLin+=50
		oPrn:Say( _nLin, 0200,"Serviços: "        , oFont3 )
        _nLin+=50
		oPrn:Say( _nLin, 0200,"Frete: "           , oFont3 )
        _nLin+=50
		oPrn:Say( _nLin, 0200,"Desp.Aces.: "      , oFont3 )
		_nLin+=50
		oPrn:Say( _nLin, 0200,"Orçamento: "        , oFont3 )  
        oPrn:Say( _nLin, 0335,TRBOR->VS1_NUMORC    , oFont3 )
        oPrn:Say( _nLin, 0700,"Cond. Pgto.: "      , oFont3 )
		oPrn:Say( _nLin, 0840,TRBOR->VS1_FORPAG    , oFont3 )		 
		oPrn:Say( _nLin, 0940,TRBOR->E4_DESCRI     , oFont3 )	    
		_nLin+=100
		oPrn:Say( _nLin, 0100,"Autorizo(amos) o faturamento deste orçamento. " , oFont3 )
        _nLin+=50
        oPrn:Say( _nLin, 0100,"Local:                          ,   Data:       /       /        " , oFont3 )
	    _nLin+=050  
		oPrn:Say( _nLin, 1000,"Carimbo "           , oFont3 )		
	    _nLin+=150  
		oPrn:Say( _nLin, 1400,"Ass. Conferência: " , oFont3 )	
	    _nLin+=100                        
        oPrn:Line (_nLin,100,_nLin,2800)
	    _nLin+=050*/    
	TRBOR->(DBSKIP())
Enddo

		_nLin+=50
  		oPrn:Say( _nLin, 1850,"Total Peças"   , oFont3 )	
        oPrn:Say( _nLin, 2200,_nSubpec, oFont3 )
		_nLin+=100
		oPrn:Say( _nLin, 0200,"Este Orçamento faz parte do Picking acima e pode possuir outros Códigos de Produtos agrupados."      , oFont3 )
		//oPrn:Say( _nLin, 0200,"Desp.Aces.: "      , oFont3 )
		//oPrn:Say( _nLin, 2200,_nDesace, oFont3 )
		_nLin+=50
		/*oPrn:Say( _nLin, 0200,"Orçamento: "        , oFont3 )  
        oPrn:Say( _nLin, 0335,TRBOR->VS1_NUMORC    , oFont3 )
        oPrn:Say( _nLin, 0700,"Cond. Pgto.: "      , oFont3 )
		oPrn:Say( _nLin, 0840,TRBOR->VS1_FORPAG    , oFont3 )		 
		oPrn:Say( _nLin, 0940,TRBOR->E4_DESCRI     , oFont3 )	    
		_nLin+=100*/



Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Eugenio Arcanjo     º Data ³  30/11/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria as perguntas do programa no dicionario de perguntas    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg( _cPerg )
	Local _nLaco := 0
	Local aArea  := GetArea()
	Local aPerg  := {}

	aAdd(aPerg,{_cPerg,"01","Emissão De ?","mv_ch1","E",08,0,1,"G","","mv_par01","","","","","","","","","","","","","","","  ",})
	aAdd(aPerg,{_cPerg,"02","Emissão Até ?","mv_ch2","D",08,0,1,"G","","mv_par02","","","","","","","","","","","","","","","  ",})
	aAdd(aPerg,{_cPerg,"03","Transportadora De ?","mv_ch3","C",06,0,1,"G","","mv_par03","","","","","","","","","","","","","","","  ",})
	aAdd(aPerg,{_cPerg,"04","Transportadora Até ?","mv_ch4","C",06,0,1,"G","","mv_par04","","","","","","","","","","","","","","","  ",})
	aAdd(aPerg,{_cPerg,"05","Aviso Recebimento De ?","mv_ch5","C",06,0,1,"G","","mv_par05","","","","","","","","","","","","","","","  ",})
	aAdd(aPerg,{_cPerg,"06","Aviso Recebimento Até ?","mv_ch6","C",06,0,1,"G","","mv_par06","","","","","","","","","","","","","","","  ",})
		
	DbSelectArea("SX1")	
    DbSetOrder(1)                            
	For _nLaco:=1 to LEN(aPerg)                                   
		If !dbSeek(PADR(aPerg[_nLaco,1],10)+aPerg[_nLaco,2])
	    	RecLock("SX1",.T.)
				SX1->X1_Grupo     := aPerg[_nLaco,01]
				SX1->X1_Ordem     := aPerg[_nLaco,02]
				SX1->X1_Pergunt   := aPerg[_nLaco,03]
				SX1->X1_PerSpa    := aPerg[_nLaco,03]
				SX1->X1_PerEng    := aPerg[_nLaco,03]				
				SX1->X1_Variavl   := aPerg[_nLaco,04]
				SX1->X1_Tipo      := aPerg[_nLaco,05]
				SX1->X1_Tamanho   := aPerg[_nLaco,06]
				SX1->X1_Decimal   := aPerg[_nLaco,07]
				SX1->X1_Presel    := aPerg[_nLaco,08]
				SX1->X1_Gsc       := aPerg[_nLaco,09]
				SX1->X1_Valid     := aPerg[_nLaco,10]
				SX1->X1_Var01     := aPerg[_nLaco,11]
				SX1->X1_Def01     := aPerg[_nLaco,12]
				SX1->X1_Cnt01     := aPerg[_nLaco,13]
				SX1->X1_Var02     := aPerg[_nLaco,14]
				SX1->X1_Def02     := aPerg[_nLaco,15]
				SX1->X1_Cnt02     := aPerg[_nLaco,16]
				SX1->X1_Var03     := aPerg[_nLaco,17]
				SX1->X1_Def03     := aPerg[_nLaco,18]
				SX1->X1_Cnt03     := aPerg[_nLaco,19]
				SX1->X1_Var04     := aPerg[_nLaco,20]
				SX1->X1_Def04     := aPerg[_nLaco,21]
				SX1->X1_Cnt04     := aPerg[_nLaco,22]
				SX1->X1_Var05     := aPerg[_nLaco,23]
				SX1->X1_Def05     := aPerg[_nLaco,24]
				SX1->X1_Cnt05     := aPerg[_nLaco,25]
				SX1->X1_F3        := aPerg[_nLaco,26]
			MsUnLock()
		EndIf
	Next
	RestArea( aArea )
Return
