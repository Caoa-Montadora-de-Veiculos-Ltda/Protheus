#Include "Protheus.ch"
#Include "TopConn.ch"
/*
=====================================================================================
Programa.:              CMVEIC05
Autor....:              Marcelo Carneiro
Data.....:              27/05/2019
Descricao / Objetivo:   Inclusão de Containers
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP EIC004
Obs......:              Chamado pelo PE IDI410MNU
Obs......:              
=====================================================================================
*/
User Function CMVEIC05()

Local cbLine := ''
Local cQuery := ''
Local aRec   := {}
Local bRet   := .F.
Static oDlg                    

Private oBrowseDados                                                     
Private aDados      := {}
Private oOK     	:= LoadBitmap(GetResources(),'LBOK')
Private oNO    		:= LoadBitmap(GetResources(),'LBNO')
Private bMarca 		:= .T.
Private cArmador 	:= ''
  
dbSelectArea('SJD')
SJD->(dbSetOrder(1))  
cQuery += " Select EW5_XCONT    "
cQuery += " from "+RetSQLName("SW7")+" a , "+RetSQLName("EW5")+" b     "
cQuery += " Where a.D_E_L_E_T_ = ' '     "
cQuery += "   AND b.D_E_L_E_T_ = ' '       "
cQuery += "   AND W7_FILIAL    = EW5_FILIAL   "
cQuery += "   AND W7_PO_NUM    = EW5_PO_NUM   "
cQuery += "   AND W7_POSICAO   = EW5_POSICA  "
cQuery += "   AND W7_FORN      = EW5_FORN       "
cQuery += "   AND W7_FORLOJ    = EW5_FORLOJ   "
cQuery += "   AND W7_FILIAL    = '"+SW6->W6_FILIAL+"'"
cQuery += "   AND W7_HAWB      = '"+SW6->W6_HAWB+"'"
cQuery += " GROUP BY EW5_XCONT      "
cQuery += " Order by 1                   "
If Select("QRY_DADOS") > 0
	QRY_DADOS->(dbCloseArea())
EndIf
cQuery  := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY_DADOS",.T.,.F.)
dbSelectArea("QRY_DADOS")
QRY_DADOS->(dbGoTop())
While !QRY_DADOS->(EOF()) 
    IF !Empty(Alltrim(QRY_DADOS->EW5_XCONT))
	    IF SJD->(!dbSeek(SW6->W6_FILIAL+SW6->W6_HAWB+Alltrim(QRY_DADOS->EW5_XCONT)))
		    aRec   := {}
		    AAdd(aRec,.F.)
		    AAdd(aRec,Alltrim(QRY_DADOS->EW5_XCONT))
		    AAdd(aDados,aRec) 
		 EndIF
	EndIF
    QRY_DADOS->(dbSkip())
End
IF Len(aDados) == 0 
    MsgAlert('Não há Containers a Incluir !!!')
    Return
EndIF               

DEFINE MSDIALOG oDlg TITLE "Seleciona Containers" FROM 000, 000  TO 280, 370 COLORS 0, 16777215 PIXEL

	oBrowseDados := TWBrowse():New( 010, 006,110,140,,{'','Containers'},{10,60},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    
	oBrowseDados:SetArray(aDados)
	cbLine := "{||{ IIF(aDados[oBrowseDados:nAt,01],oOK,oNO), aDados[oBrowseDados:nAt,02]  } }"
	oBrowseDados:bLine        := &cbLine
	oBrowseDados:bLDblClick   := {|| aDados[oBrowseDados:nAt][1] := !aDados[oBrowseDados:nAt][1],oBrowseDados:DrawSelect()}
	//oBrowseDados:bHeaderClick := {|oBrw,nCol| MarcaDesmarca(nCol)}
	oBrowseDados:Setfocus()    
	
    
	oButton := TButton():New( 010, 120, "Sair"    ,oDlg,{||oDlg:End()}, 50,11,,,.F.,.T.,.F.,,.F.,,,.F. )      
    oButton := TButton():New( 118, 120, "Incluir" ,oDlg,{||bRet := EIC05_Inclui(),IIF(bRet,oDlg:End(),)}, 50,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	                      //118 022
	
                                                 
ACTIVATE MSDIALOG oDlg CENTERED

Return        
*****************************************************************************************************************
Static Function EIC05_Inclui
Local aParambox	  := {}                 
Local aRet        := {}                                                                                     
Local nI          := 0 
Local aCont       := {}
Local nConta20    := 0
Local nConta40    := 0
Local nConta40HC  := 0
Local nContaOutr  := 0

For nI := 1 To Len(aDados)
    IF aDados[nI][01]
        AAdd(aCont, aDados[nI][02])
    EndIF
Next nI
IF Len(aCont) == 0 
    MsgAlert('Não há Containers Selecionados !!')
    Return .F.
EndIF
cArmador 	:= ''
IF SJD->(dbSeek(SW6->W6_FILIAL+SW6->W6_HAWB))
    cArmador := SW6->W6_ARMADOR
Else 
    cArmador := Space(tamSx3("W6_ARMADOR")[1])
ENDIF

AAdd(aParamBox, {1, "Armador:"      ,cArmador , "@!",""     ,"EIA","EMPTY(cArmador)", 070, .T.	})
AAdd(aParamBox, {1, "Tipo Cont's:"  ,' '                            , "@!","pertence('1234')" ,"C3","", 070, .T.	})
AAdd(aParamBox, {1, "Dt. Entrada:"  ,Ctod("  /  /  ")               , "@!","","","" , 070, .T.	})
AAdd(aParamBox, {1, "Dt.Prev.Devo:" ,Ctod("  /  /  ")               , "@!","","","" , 070, .T.	})
AAdd(aParamBox, {1, "Dt.Devolucao:" ,Ctod("  /  /  ")               , "@!","","","" , 070, .F.	})
//Informações sobre os Containers
IF ParamBox(aParambox, ""	, @aRet, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .T. /*lUserSave*/)
	   IF !EMPTY(cArmador)
	       cArmador 	:= MV_PAR01
	   EndIF
	   SY5->(dbSetOrder(1))
       IF SY5->(!dbSeek(xFilial("SY5")+cArmador))
	      MsgAlert('Armador não encontado !!')
	      Return .F.
	   EndIF
	   For nI:= 1 To Len(aCont)
		    Reclock("SJD",.T.)
			SJD->JD_FILIAL    := SW6->W6_FILIAL
			SJD->JD_HAWB      := SW6->W6_HAWB
			SJD->JD_CONTAIN   := aCont[nI]
			SJD->JD_ARMADOR   := cArmador
			SJD->JD_TIPO_CT   := MV_PAR02
			SJD->JD_DT_ENT    := MV_PAR03
			SJD->JD_DTPREVI   := MV_PAR04
            SJD->JD_DEVOLUC   := MV_PAR05
			SJD->(MsUnlock())
	   Next nI	
       SJD->(dbSeek(SW6->W6_FILIAL+SW6->W6_HAWB))
       While  SJD->(!EOF()) .AND. SJD->JD_FILIAL == SW6->W6_FILIAL .AND. SJD->JD_HAWB ==SW6->W6_HAWB
	        DO CASE
			   CASE SJD->JD_TIPO_CT == '1'
			        nConta20++
			   CASE SJD->JD_TIPO_CT == '2'             
			        nConta40++
			   CASE SJD->JD_TIPO_CT == '3'             
			        nConta40HC++
			   CASE SJD->JD_TIPO_CT == '4'             
			        nContaOutr++
			ENDCASE
           SJD->(dbSKip())
       End
       SW6->(RECLOCK('SW6',.F.))
       SW6->W6_TOT_REC := nConta20 + nConta40 + nConta40HC + nContaOutr
	   SW6->W6_CONTA20 := nConta20
	   SW6->W6_CONTA40 := nConta40
	   SW6->W6_CON40HC := nConta40HC
	   SW6->W6_OUTROS  := nContaOutr     
	   SW6->W6_ARMADOR := cArmador
       SW6->(MSUNLOCK())
	   
	   
	   MsgAlert('Containers cadastrados com Sucesso!!')
	   Return .T.
EndIF

Return .F.
