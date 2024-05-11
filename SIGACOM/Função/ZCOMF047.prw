#Include 'Protheus.ch'
/*/{Protheus.doc}  ZCOMF047
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	23/05/2022
@return  	NIL
@obs      Chamado pelo PE MA103OPC  
@project  
@history  Função p/verificar a integração da NF c/ a Autoware
/*/
user function ZCOMF047(cNF,cSerie,cTipo,cFornec,cLoja,lLiga)
Local _oCourierNw	:= TFont():New("Courier New",,,,.F.,,,,.F.,.F.)
Local oOk           := LoadBitmap(GetResources(), "LBOK")
Local oNo           := LoadBitmap(GetResources(), "LBNO")
Local _nLin         := 13
Local cCGC          := ""
Local cQtde         := "" 
Local cItem         := ""
Local cStatus       := ""
Local cConf         := ""
Local cSaldoIte     := ""

Static _oDlg, _oDlg1:= ""

Private n           := 1
Private cCod        := ""
Private cCodPos     := ""
Private _aStruT1    := {}
Private aArqList    := {}
Private oListBox, oListBox1
Private bOK,bCANCEL,aBUTTONS,nBTOP
Private bOK1,bCANCEL1,aBUTTONS1

bOK      := {|| nBTOP  := 1,IF(Movto(cNF,cSerie,cTipo,Alltrim(aArqList[oListBox1:nAt][3])),_oDlg:END(),nBTOP := 0)} 
bCANCEL  := {|| nBTOP  := 0,_oDlg:END()}

aBUTTONS := {{"LBTIK",{},""}}
nBTOP    := 0

bOK1      := {|| nBTOP  := 1,_oDlg1:END()} 
bCANCEL1  := {|| nBTOP  := 0,_oDlg1:END()}

aBUTTONS1:= {{"LBTIK",{},""}}

IF ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB

    // Montagem das Celulas 
    AADD(_aStruT1,{"NOTA"      ,"C",09,0})
    AADD(_aStruT1,{"SERIE"     ,"C",03,0}) 
    AADD(_aStruT1,{"TIPO"      ,"C",01,0})
    AADD(_aStruT1,{"COD"       ,"C",23,0}) 
    AADD(_aStruT1,{"ITEM"      ,"C",04,0})    
    AADD(_aStruT1,{"QUANTIDADE","N",12,2}) 
    AADD(_aStruT1,{"CONFERIDA" ,"N",12,2})
    AADD(_aStruT1,{"SALDOITEM" ,"N",12,2})
    AADD(_aStruT1,{"STATUS"    ,"C",07,0})    
    _cArqTRB   := Criatrab(_aStruT1,.T.)
	_cIndice   := CriaTrab(Nil,.F.)
    _cChaveInd := "NOTA+SERIE+ITEM"

    If Select("TRB1") > 0
		dbSelectArea("TRB1")
		dbCloseArea()
        TCDelFile(_cArqTRB)
	EndIf

    dbCreate( _cArqTRB , _aStruT1 , "TOPCONN" )
	dbUseArea( .T., __LocalDriver, _cArqTRB , "TRB1", .F., .F. )
    dbCreateIndex( _cArqTRB ,_cChaveInd )

    dbSelectArea( "TRB1" )
	dbSetOrder(1)

    IF SF1->F1_TIPO = 'D'
        dbSelectArea("SA1")
        SA1->(dbSetOrder(1))
        SA1->(DBGOTOP())
	    If SA1->(dbSeek(xFilial("SA1")+cFornec+cLoja))  
            cCGC := SA1->A1_CGC
        Else
            cCGC := ""
        EndIf
        dbSelectArea("SA2")
        SA2->(dbSetOrder(3))
        SA2->(DBGOTOP())
	    If SA2->(dbSeek(xFilial("SA2")+cCGC))    
            cFornec := A2_COD
            cLoja   := A2_LOJA
        EndIf
    EndIf      

    dbSelectArea("ZD1")
    ZD1->(dbSetOrder(1))
    ZD1->(DBGOTOP())
	If !ZD1->(dbSeek(xFilial("ZD1")+cNF+cSerie+cFornec+cLoja))  
    	
        MSGINFO( "Não localizado Integração documento !!! " + Alltrim(cNF), "[ZCOMF047] - Atenção" )
		//Break
	
    Else

        While ZD1->(!Eof()) .AND. ZD1->ZD1_DOC = cNF .AND. ZD1->ZD1_SERIE = cSerie .AND. ZD1->ZD1_FORNECE = cFornec .AND. ZD1->ZD1_LOJA = cLoja 
            cItem       := ZD1->ZD1_ITEM                         
            cQtde       := ZD1->ZD1_QUANT
            cCod        := ZD1->ZD1_COD
            cConf       := ZD1->ZD1_QTCONF
            cSaldoIte   := ZD1->ZD1_SLDIT 
            IF ZD1->ZD1_QUANT > ZD1->ZD1_QTCONF
                cStatus := "Parcial"
            ELSE
                cStatus := "Total"
            ENDIF
            dbSelectArea("TRB1")
            //If !dbSeek(cNF)
                RecLock("TRB1",.T.)
                TRB1->NOTA         := cNF
                TRB1->SERIE        := cSerie
                TRB1->TIPO         := cTipo
                TRB1->COD          := cCod
                TRB1->ITEM         := cItem        
                TRB1->QUANTIDADE   := cQtde
                TRB1->CONFERIDA    := cConf
                TRB1->SALDOITEM    := cSaldoIte
                TRB1->STATUS       := cStatus                
                TRB1->( msUnlock() )
      			aAdd(aArqList,{ cNF,;   	//1
                    cSerie,; 				//2
                    cCod,;                  //3
                    Str(cQtde),;			//4
                    Str(cConf),;			//5
                    Str(cSaldoIte),;		//6
                    cStatus,;               //7
                    Alltrim(Str(Len(aArqList)+1))})	//8
            //Endif

            ZD1->( dbSkip() )

        EndDo

    Endif

    DEFINE MSDIALOG _oDlg TITLE "Verificar Integração NF Entrada X AUTOWARE" FROM 000, 000 TO 350, 500 COLORS 0, 16777215 PIXEL  //500, 500

    @ 058,007 LISTBOX oListBox1 Fields,HEADER "Nota Fiscal","Série","Produto","Qtd.Original","Qtd.Conferida","Sld_Item","Status","Reg." SIZE 430,150 OF _oDlg PIXEL ColSizes 10,10,35,37,15,10,10,05
        oListBox1:SetArray(aArqList)
        oListBox1:bLine := {|| { aArqList[oListBox1:nAt][1],; 
                                 aArqList[oListBox1:nAt][2],;
                                 aArqList[oListBox1:nAt][3],;
                                 aArqList[oListBox1:nAt][4],;                                    
                                 aArqList[oListBox1:nAt][5],;
                                 aArqList[oListBox1:nAt][6],;
                                 aArqList[oListBox1:nAt][7],;
                                 aArqList[oListBox1:nAt][8] }}

    ACTIVATE MSDIALOG _oDlg ON INIT ENCHOICEBAR(_oDlg,bOK,bCANCEL,,aBUTTONS) CENTERED 

ENDIF
Return()


/*/{Protheus.doc}  ZCOMF047
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	23/05/2022
@return  	NIL
@obs      Chamado pelo ZCOMF047  
@project  
@history  Função p/verificar a movimentação do produto
/*/
Static Function Movto(cNF,cSerie,cTipo,cCodPos)
Local nPos     := 0
Local cDsMov   := ""
Local _aStruT2 := {}
Local aArqLis1 := {}

// Montagem das Celulas 
    AADD(_aStruT2,{"PROD","C",03,0}) 
    AADD(_aStruT2,{"TM" ,"C",03,0}) 
    AADD(_aStruT2,{"CF" ,"C",03,0})
    AADD(_aStruT2,{"EMISSAO","D",08,0})        
    AADD(_aStruT2,{"QUANT"  ,"N",12,2}) 
    AADD(_aStruT2,{"ARMAZ"  ,"C",03,0}) 

    _cArqTR2  := Criatrab(_aStruT2,.T.)
	_cIndice  := CriaTrab(Nil,.F.)
    _cChaveI2 := "PROD+TM+ARMAZ"

    If Select("TRB2") > 0
		dbSelectArea("TRB2")
		dbCloseArea()
        TCDelFile(_cArqTR2)
	EndIf

    dbCreate( _cArqTR2 , _aStruT2 , "TOPCONN" )
	dbUseArea( .T., __LocalDriver, _cArqTR2 , "TRB2", .F., .F. )
    dbCreateIndex( _cArqTR2 ,_cChaveI2)

    dbSelectArea( "TRB2" )
	dbSetOrder(1)

    dbSelectArea("SD3")
    SD3->(DBGOTOP())
	SD3->(dbSetOrder(3))  //Filial + Código (filial+cod)  

    If !SD3->(dbSeek(xFilial("SD3")+cCodPos))  
            
        MSGINFO( "Não localizado Movi/to Interna produto !!! "+ cCodPos, "[ZCOMF047] - Atenção" )
        Return()
        
    Else

        While SD3->(!Eof()) .AND. Alltrim(SD3->D3_COD) = cCodPos 

            nPos := AT(cNF,SD3->D3_OBSERVA)
            
            IF SD3->D3_TM < "500"
                cDsMov := "Entrada"
            ELSE
                cDsMov := "Saída"
            ENDIF

            //IF nPos = 0
            
                //MSGINFO( "Não localizado Movi/to Interna documento !!! "+ Alltrim(cCod), "[ZCOMF047] - Atenção" )
                //Break
            
            //ELSE
            IF nPos <> 0
                dbSelectArea("TRB2")
                If !dbSeek(cNF+cCodPos)
                    RecLock("TRB2",.T.)
                    TRB2->PROD         := cCodPos
                    TRB2->TM           := SD3->D3_TM
                    TRB2->CF           := SD3->D3_CF
                    TRB2->ARMAZ        := SD3->D3_LOCAL
                    TRB2->EMISSAO      := SD3->D3_EMISSAO        
                    TRB2->QUANT        := SD3->D3_QUANT
                    TRB2->( msUnlock() )
                    aAdd(aArqLis1,{ cCodPos,;            //1
                        SD3->D3_TM,;    	             //2
                        SD3->D3_CF+"  "+cDsMov,;         //3  
                        SD3->D3_LOCAL,;                  //4                 
                        SD3->D3_EMISSAO ,;               //5
                        SD3->D3_QUANT,;			         //6
                        Alltrim(Str(Len(aArqLis1)+1))})  //7
                Endif

            ENDIF

            SD3->( dbSkip() )

        EndDo

       //Se o tamanho for 0, Array é vazio
        If Len(aArqLis1) == 0 .OR. Empty(aArqLis1) 
            MSGINFO( "Não localizado Movi/to Interna dessa NF produto !!! "+ cCodPos, "[ZCOMF047] - Atenção" )
            Return()
        EndIf

        DEFINE MSDIALOG _oDlg1 TITLE "Movimentação Interna x Produto" FROM 000, 000 TO 350, 500 COLORS 0, 16777215 PIXEL  //500, 500
    
        @ 058,007 LISTBOX oListBox Fields,HEADER "Produto","Movi/to","CF","Armazém","Emissão","Qtde.","Reg." SIZE 430,110 OF _oDlg1 PIXEL ColSizes 35,40,10,15,05,05,03
            oListBox:SetArray(aArqLis1)

            oListBox:bLine := {|| { aArqLis1[oListBox:nAt][1],; 
                                    aArqLis1[oListBox:nAt][2],;
                                    aArqLis1[oListBox:nAt][3],;
                                    aArqLis1[oListBox:nAt][4],;                                    
                                    aArqLis1[oListBox:nAt][5],;
                                    aArqLis1[oListBox:nAt][6],;
                                    aArqLis1[oListBox:nAt][7]}}
    
        ACTIVATE MSDIALOG _oDlg1 ON INIT ENCHOICEBAR(_oDlg1,bOK1,bCANCEL1,,aBUTTONS1) CENTERED 
        
    EndIf

fErase(_cArqTRB+".DTC")
fErase(_cChaveInd+OrdBagExt())

fErase(_cArqTR2+".DTC")
fErase(_cChaveI2+OrdBagExt())

Return()
