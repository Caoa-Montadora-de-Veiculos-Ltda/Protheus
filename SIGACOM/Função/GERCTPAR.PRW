#include "totvs.ch"

// este c√≥digo estava no programa MTA110MNU.PRW - desmembrado por Cristiam Rossi em 28/02/2019
// incluÌdo campo C3_XDESC aArqXist[nPosXis,06   - 09/10/20 A.Carlos	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////     Fun√ß√£o de gera√ß√£o de contratos de parceria para Solicita√ß√µes em Aberto     /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function GERCPAR()

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
		zFMontadora()
    Else
        //Retorna os valores padrıes quando Barueri
        zCaoaSp()
    EndIf

Return()

Static Function zFMontadora()

Local oDLG, oListBox, oDLG1, oListBox1, oDLG2
Local cQuery := ""
Local _oMemo := " "
Local bOK,bCANCEL,aBUTTONS,nBTOP
Local bOK1,bCANCEL1,nBTOP1
Local bOK2,bCANCEL2,nBTOP2

Local oOk := LoadBitmap(GetResources(), "LBOK")
Local oNo := LoadBitmap(GetResources(), "LBNO")
Local cNumCon := ""
Local nQtdTot:=0  //Quantidade Total da SC
Local cFilAAA:=""
Local cNumAnt:=""
Local cForAnt:=""
Local cLojAnt:=""
Local aArqXist := {}  //Array com todos os itens da SC
Local nPosXis  :=0
Local nItem    :=0
Local I, J     :=0
Local cC3_XTPREQ := SPACE(04)
Local cC3_XTPRE2 := SPACE(04)

Private cFornC3 := SPACE(TamSX3("C3_FORNECE")[1])
Private cLojaC3 := SPACE(TamSX3("C3_LOJA")[1])
Private cDesFor := ""

Private cCondC3 := SPACE(TamSX3("C3_COND")[1])

Private cDesCon := ""

Private dDINIC3 := dDATABASE
Private dDFINC3 := Ctod("  /  /    ")
Private nPreco  := 1
				    

Private cMARCA 
Private lINVERTE
Private lMSErroAuto := .F.
Private aArqList := {}
Private aArqCont := {}

Private cPerg    := "CAOACOM01"

Public cObsCP	 := ""

ValidPerg()
iF !Pergunte(cPerg,.T.)
	Return 
Endif

cMARCA   := GETMARK()
lINVERTE := .F.
bOK      := {|| nBTOP  := 1,IF(FVAL("bOK"),oDLG:END(),nBTOP := 0)}
bCANCEL  := {|| nBTOP  := 0,oDLG:END()}
bOK1     := {|| nBTOP1 := 1,IF(FVAL("bOK1"),oDLG1:END(),nBTOP1 := 0)}
bCANCEL1 := {|| nBTOP1 := 0,oDLG1:END()}
bOK2     := {|| nBTOP2 := 1,IF(FVAL("bOK2"),oDLG2:END(),nBTOP2 := 0)}
bCANCEL2 := {|| nBTOP2 := 0,oDLG2:END()}

aBUTTONS := {{"LBTIK",{|| FVAL("MARCA")},"Marca/Desmarca Todos"}}
nBTOP    := 0
nBTOP1   := 0
nBTOP2   := 0



If (Select("TRBSC1") <> 0 )
	dbSelectArea("TRBSC1")
	dbCloseArea()
Endif
	
cQuery := " SELECT C1_FILIAL,C1_NUM,C1_EMISSAO,C1_FORNECE,C1_LOJA,C1_PRODUTO,C1_DESCRI,C1_CONDPAG,C1_FILENT,C1_QUANT,C1_QUJE,"
cQuery += " C1_XDESCL1,C1_XDESCL2,SC1.R_E_C_N_O_ C1_RECNO, C1_UM,"
cQuery += " UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C1_XOBSREQ, 2000, 1)) AS C1_XOBSREQ, "
cQuery += " UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C1_XOBSITE, 2000, 1)) AS C1_XOBSITE "
cQuery += " FROM "+RetSQLName("SC1")+" SC1 WHERE C1_FILIAL='"+xFilial("SC1")+"' "
cQuery += " AND D_E_L_E_T_<>'*' AND C1_QUJE<C1_QUANT AND C1_RESIDUO<>'S' AND C1_COTACAO='' "
cQuery += " AND C1_FORNECE BETWEEN '"+mv_par01+"' AND '"+MV_PAR02+"' "
cQuery += " AND C1_PRODUTO BETWEEN '"+mv_par03+"' AND '"+MV_PAR04+"' "
cQuery += " AND C1_FILENT  BETWEEN '"+mv_par09+"' AND '"+MV_PAR10+"' "
cQuery += " AND C1_CONDPAG BETWEEN '"+mv_par07+"' AND '"+MV_PAR08+"' "
cQuery += " AND C1_EMISSAO BETWEEN '"+DTOS(mv_par05)+"' AND '"+DTOS(MV_PAR06)+"' "
cQuery += " ORDER BY C1_FILIAL,C1_NUM,C1_FORNECE,C1_LOJA"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBSC1",.T.,.T.)

DBSelectArea("TRBSC1")
DBGoTop()
If TRBSC1->(!Eof())
	Do While TRBSC1->(!Eof())
		aAdd(aArqList,{.F.,; 																			//1
						TRBSC1->C1_NUM,; 																//2
						DTOC(STOD(TRBSC1->C1_EMISSAO)),; 												//3
						Posicione("SA2",1,xFilial("SA2")+TRBSC1->C1_FORNECE+TRBSC1->C1_LOJA,"A2_NOME"),;//4
						TRBSC1->C1_PRODUTO,;															//5
						TRBSC1->C1_DESCRI,;																//6
						TRBSC1->C1_CONDPAG,;															//7
						TRBSC1->C1_FILENT,;																//8
						TRBSC1->C1_FORNECE+TRBSC1->C1_LOJA,;											//9
						TRBSC1->C1_QUANT-TRBSC1->C1_QUJE,;												//10
						TRBSC1->C1_XDESCL1,;															//11
						TRBSC1->C1_XDESCL2,;															//12
                        TRBSC1->C1_XOBSREQ,;															//13
						TRBSC1->C1_XOBSITE,;															//14
						Len(aArqList)+1,;                                                               //15
						TRBSC1->C1_UM})															     	//16

///////////////////////////////////////////////////////////////////////////////
		nQtdTot:=0  //Quantidade Total da SC
		cFilAAA:=TRBSC1->C1_FILIAL
		cNumAnt:=TRBSC1->C1_NUM
		cForAnt:=TRBSC1->C1_FORNECE
		cLojAnt:=TRBSC1->C1_LOJA
		While TRBSC1->(!Eof() .and. C1_FILIAL+C1_NUM+C1_FORNECE+C1_LOJA==cFilAAA+cNumAnt+cForAnt+cLojAnt)

			aAdd(aArqXist,{.F.,; 																		//1
						TRBSC1->C1_NUM,; 																//2
						DTOC(STOD(TRBSC1->C1_EMISSAO)),; 												//3
						Posicione("SA2",1,xFilial("SA2")+TRBSC1->C1_FORNECE+TRBSC1->C1_LOJA,"A2_NOME"),;//4
						TRBSC1->C1_PRODUTO,;															//5
						TRBSC1->C1_DESCRI,;																//6
						TRBSC1->C1_CONDPAG,;															//7
						TRBSC1->C1_FILENT,;																//8
						TRBSC1->C1_FORNECE+TRBSC1->C1_LOJA,;											//9
						TRBSC1->C1_QUANT-TRBSC1->C1_QUJE,;												//10
						TRBSC1->C1_XDESCL1,;															//11
						TRBSC1->C1_XDESCL2,;															//12
                        TRBSC1->C1_XOBSREQ,;															//13
						TRBSC1->C1_XOBSITE,;															//14
						Len(aArqList),;																	//15
						TRBSC1->C1_RECNO,;                                                              //16
						TRBSC1->C1_UM})											    					//17

			nQtdTot+=TRBSC1->( C1_QUANT - C1_QUJE )
			TRBSC1->(DBSkip())
		End
		aArqList[Len(aArqList),10]:=nQtdTot  //Quantidade Total da SC
///////////////////////////////////////////////////////////////////////////////

	Enddo

Else
	MSGINFO("Nenhuma SolicitaÁ„o de Compra encontrada!","AtenÁ„o!")
	Return
Endif



DEFINE MSDIALOG oDLG TITLE "GeraÁ„o de Contrato de Parceria" FROM 0,0 TO 350,680 OF oMainWnd PIXEL 

   @ 036,007 SAY "Lista de SolicitaÁıes em Aberto:" PIXEL OF oDLG
   @ 047,007 LISTBOX oListBox Fields,HEADER "","Num. SC","Emiss„o","Fornecedor","Cad.Prod.","DescriÁ„o","C.Pagto.","Filial Entrega" SIZE 330,120 OF oDlg PIXEL ColSizes 10,30,30,50,35,70,30,35
     oListBox:SetArray(aArqList)
     oListBox:bLine := {|| { IIf(aArqList[oListBox:nAt, 1], oOk, oNo),;
						     aArqList[oListBox:nAt][2],; 
						     aArqList[oListBox:nAt][3],;
						     aArqList[oListBox:nAt][4],;
					         aArqList[oListBox:nAt][5],;
					         aArqList[oListBox:nAt][6],;
					         aArqList[oListBox:nAt][7],;
					         aArqList[oListBox:nAt][8]}}
	 oListBox:BlDblClick := {|| aArqList[oListBox:nAt, 1] := !aArqList[oListBox:nAt, 1], oListBox:Refresh()}
ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS) CENTERED     

IF nBTOP == 1


		BEGIN TRANSACTION
		For i:=1 to Len(aArqList)
			If aArqList[i,1]
				
				
				aCab   := {}
				aItens := {}
				aLinha := {}
				cFornC3 := SPACE(TamSX3("C3_FORNECE")[1])
				cLojaC3 := SPACE(TamSX3("C3_LOJA")[1])
				cCondC3 := SPACE(TamSX3("C3_COND")[1])
				dDINIC3 := dDATABASE
				dDFINC3 := Ctod("  /  /    ")
				cObsCP  := ""
				nPreco  := 1				
				
				
				dbSelectArea("SC3")
				dbSetOrder(5)
				If .f.//dbSeek(xFilial("SC3")+aArqList[i,5]+aArqList[i,9])
					
					cNumCon := SC3->C3_NUM
					RecLock("SC3",.F.)
					SC3->C3_QUANT += aArqList[i,10]
					MsUnlock()

					dbSelectArea("SC1")
					dbSetOrder(1)
					If dbSeek(xFilial("SC1")+aArqList[i,2])
						RecLock("SC1",.F.)
						SC1->C1_RESIDUO := "S"
						SC1->C1_XCPARCE := "S"
						SC1->C1_XNUMCTP := cNumCon
						MsUnlock()
					Endif	

					
				Else
		
					IF MSGYESNO("Contrato de Parceria n„o encontrado para a SC "+aArqList[i,2]+"!"+CHR(13)+;
								"Deseja amarrar a um Contrato j· existente?"+CHR(13)+;
								"Caso seja selecionada a opÁ„o 'N„o', ser· gerado um novo Contrato!","AtenÁ„o!")


						dbSelectArea("SC3")
						dbSetOrder(3)
						If dbSeek(xFilial("SC3")+aArqList[i,5])
							
							Do While SC3->(!Eof()) .AND. SC3->C3_FILIAL==xFilial("SC3") .AND. AllTrim(SC3->C3_PRODUTO)==AllTrim(aArqList[i,5])
								aAdd(aArqCont,{.F., SC3->C3_NUM, DTOC(SC3->C3_EMISSAO), Posicione("SA2",1,xFilial("SA2")+SC3->C3_FORNECE+SC3->C3_LOJA,"A2_NOME"),;
												SC3->C3_COND, SC3->C3_FILENT} )
								SC3->(DBSkip())
							Enddo
						

							DEFINE MSDIALOG oDLG1 TITLE "SeleÁ„o de Contrato de Parceria" FROM 0,0 TO 350,680 OF oMainWnd PIXEL 
							
							   @ 036,007 SAY "Lista de Contratos Encontrados:" PIXEL OF oDLG1
							   @ 046,007 SAY "SolicitaÁıes de Compra: "+aArqList[i,2] PIXEL OF oDLG1
							   @ 046,107 SAY "Produto: "+AllTrim(aArqList[i,5])+"-"+aArqList[i,6] PIXEL OF oDLG1
							   @ 058,007 LISTBOX oListBox1 Fields,HEADER "","Num. Contrato","Emiss„o","Fornecedor","C.Pagto.","Filial Entrega" SIZE 330,110 OF oDlg1 PIXEL ColSizes 10,50,35,85,35,35
							     oListBox1:SetArray(aArqCont)
							     oListBox1:bLine := {|| { IIf(aArqCont[oListBox1:nAt, 1], oOk, oNo),;
													     aArqCont[oListBox1:nAt][2],; 
													     aArqCont[oListBox1:nAt][3],;
													     aArqCont[oListBox1:nAt][4],;
												         aArqCont[oListBox1:nAt][5],;
												         aArqCont[oListBox1:nAt][6] }}
								 oListBox1:BlDblClick := {|| aArqCont[oListBox1:nAt, 1] := !aArqCont[oListBox1:nAt, 1], oListBox1:Refresh()}
							ACTIVATE MSDIALOG oDLG1 ON INIT ENCHOICEBAR(oDLG1,bOK1,bCANCEL1,,) CENTERED     

							IF nBTOP1 == 1	

								For j:=1 to Len(aArqCont)
									If aArqCont[j,1]
								
										dbSelectArea("SC3")
										dbSetOrder(1)
										If dbSeek(xFilial("SC3")+aArqCont[j,2])
											RecLock("SC3",.F.)
											SC3->C3_QUANT += aArqList[i,10]
											MsUnlock()
										Endif
			
										dbSelectArea("SC1")
										dbSetOrder(1)
										If dbSeek(xFilial("SC1")+aArqList[i,2])
											RecLock("SC1",.F.)
											SC1->C1_RESIDUO := "S"
											SC1->C1_XCPARCE := "S"
											SC1->C1_XNUMCTP := aArqCont[j,2]
											MsUnlock()
										Endif
									Endif
								Next
								
							Endif
						Else
							MSGINFO("Nenhum Contrato de Parceria encontrado para o produto: "+aArqList[i,5]+"!","AtenÁ„o!")
						Endif
	
					Else
						dbSelectArea("SC1")
						dbSetOrder(1)
						If dbSeek(xFilial("SC1")+aArqList[i,2])
                           cC3_XTPREQ :=SC1->C1_XTPREQ
						   cC3_XTPRE2 :=SC1->C1_XTPREQ
						Endif
						DEFINE MSDIALOG oDLG2 TITLE "GravaÁ„o de Novo Contrato de Parceria" FROM 0,0 TO 320,550 OF oMainWnd PIXEL 
					    @ 037,010 SAY "Fornecedor" PIXEL OF oDLG2
					    @ 047,010 MSGET cFornC3 PICTURE PesqPict("SA2","A2_COD") VALID (FVAL("FORNECE")) F3 "SA2" WHEN .T. SIZE 035,08  PIXEL OF oDLG2   
					    @ 047,050 MSGET cLojaC3 PICTURE WHEN .F. SIZE 015,08  PIXEL OF oDLG2   
					    @ 047,070 MSGET cDesFor PICTURE WHEN .F. SIZE 115,08  PIXEL OF oDLG2   

					    @ 059,010 SAY "Cond. Pagto" PIXEL OF oDLG2
					    @ 068,010 MSGET cCondC3 PICTURE PesqPict("SC3","C3_COND") VALID (FVAL("CONDPAGTO")) F3 "SE4" WHEN .T. SIZE 015,08  PIXEL OF oDLG2   

					    @ 059,070 SAY "Tipo de Documento" PIXEL OF oDLG2
                        @ 068,070 MSGET  cC3_XTPREQ  PICTURE "@!" Valid  u_FVALTPO("CP",cC3_XTPREQ, cC3_XTPRE2)  F3 "ZA4"   SIZE 80, 08  WHEN .T.  PIXEL Of oDLG2   


					    @ 082,010 SAY "Data Inicial" PIXEL OF oDLG2
					    @ 091,010 MSGET dDINIC3 PICTURE PesqPict("SC3","C3_DATPRI")  WHEN .T. SIZE 045,08  PIXEL OF oDLG2   
					    @ 082,070 SAY "Data Final" PIXEL OF oDLG2
					    @ 091,070 MSGET dDFINC3 PICTURE PesqPict("SC3","C3_DATPRF") VALID (FVAL("dDFINC3",dDInic3,dDFinc3))  WHEN .T. SIZE 045,08  PIXEL OF oDLG2   
					    
						@ 105,010 SAY "Obs. Geral Contrao Parceria" PIXEL OF oDLG2
					    @ 114,010 GET _oMemo VAR cObsCP MEMO SIZE 260, 23 WHEN .T. VALID !Empty(cObsCP)  PIXEL OF oDLG2   

						
						
						ACTIVATE MSDIALOG oDLG2 ON INIT ENCHOICEBAR(oDLG2,bOK2,bCANCEL2,,) CENTERED     

						IF nBTOP2 == 1	
							
							cNumCon := GetSxeNum("SC3","C3_NUM")
							aadd(aCab,{"C3_FILIAL"  , xFilial("SC3") , NIL})
							aadd(aCab,{"C3_NUM"		, cNumCon		 , NIL})
							aadd(aCab,{"C3_EMISSAO" , dDataBase			  })
							aadd(aCab,{"C3_FORNECE" , cFornC3        , NIL})
							aadd(aCab,{"C3_LOJA"    , cLojaC3		 , NIL})
							aadd(aCab,{"C3_COND"    , cCondC3        , NIL})
							aadd(aCab,{"C3_MOEDA"   ,1   			 , NIL})
							aadd(aCab,{"C3_XOBSCOP" ,cObsCP			 , NIL})	    
							aadd(aCab,{"C3_XTPCON"  ,cC3_XTPREQ		 , NIL})	        

							nItem:=0
							For nPosXis:=1 to Len(aArqXist)  //Array com todos os itens da SC
								If aArqXist[nPosXis,15]==aArqList[i,15]
									nItem++
									aLinha := {}
									aadd(aLinha,{"C3_FILIAL" , xFilial("SC3")					, Nil})	
									aadd(aLinha,{"C3_ITEM"   , StrZero(nItem,len(SC3->C3_ITEM)) , Nil})  	
									aadd(aLinha,{"C3_PRODUTO", aArqXist[nPosXis,05]				, Nil})	
									aadd(aLinha,{"C3_QUANT"  , aArqXist[nPosXis,10]				, Nil})	
									aadd(aLinha,{"C3_PRECO"	 , nPreco    						, Nil})	
									aadd(aLinha,{"C3_TOTAL"	 , aArqXist[nPosXis,10]*nPreco		, Nil})			
									aadd(aLinha,{"C3_DATPRI" , dDINIC3							, Nil})	
									aadd(aLinha,{"C3_DATPRF" , dDFINC3							, Nil})	
									aadd(aLinha,{"C3_LOCAL"  , GetAdvFVal("SB1","B1_LOCREC",xFilial("SB1")+aArqXist[nPosXis,05],1,"")						, Nil})	
									aadd(aLinha,{"C3_XDESC"  , aArqXist[nPosXis,06]				, Nil})	
									aadd(aLinha,{"C3_XDESCL1", aArqXist[nPosXis,11]				, Nil})	
									aadd(aLinha,{"C3_XDESCL2", aArqXist[nPosXis,12]				, Nil})	
                                    aadd(aLinha,{"C3_XOBSCOP", aArqXist[nPosXis,13]				, Nil})
									aadd(aLinha,{"C3_XOBSITE", aArqXist[nPosXis,14]				, Nil})
									aadd(aLinha,{"C3_XTPCON" , cC3_XTPREQ		                , NIL})
									aadd(aLinha,{"C3_UM"     , aArqXist[nPosXis,17]				, Nil})
									aadd(aItens,aLinha) 	  
								EndIf
							Next
							
							MSExecAuto( {|x,y,z| mata125(x,y,z)},aCab,aItens,3) 
							If lMsErroAuto 
								MostraErro()
							    DisarmTransaction()
							Else 
								ConfirmSX8()
								For nPosXis:=1 to Len(aArqXist)  //Array com todos os itens da SC
									If aArqXist[nPosXis,15]==aArqList[i,15]
										SC1->(dbGoTo(aArqXist[nPosXis,16]))  //Posiciona no SC1
										If SC1->( RecLock("SC1",.F.) )
											SC1->C1_RESIDUO := "S"
											SC1->C1_XCPARCE := "S"
											SC1->C1_XNUMCTP := cNumCon
											SC1->(MsUnlock())
										Endif
									Endif
								Next
								
									MSGINFO("Contrato de Parceria gerado: "+AllTrim(cNumCon)+"!","AtenÁ„o!")
							EndIf
						Endif

					Endif
				Endif
			
			
			Endif
		Next
		END TRANSACTION
Endif

Return ()

Static Function FVAL(cP_ACAO,xVar,yVar)
Local nCont := 0
Local nX 


If AllTrim(cP_ACAO)=="bOK"
	For nX:=1 to Len(aArqList)
		If aArqList[nX,1]
			Return .T.
		Endif
	Next 
	
    MSGINFO("Nenhuma SolicitaÁ„o de Compra foi selecionada!","AtenÁ„o!")
	Return .F.

ElseIf AllTrim(cP_ACAO)=="bOK1"

	For nX:=1 to Len(aArqCont)
		If aArqCont[nX,1]
			nCont++
		Endif
	Next 
	
	If nCont==0
		MSGINFO("Nenhum Contrato de Parceria foi selecionado!","AtenÁ„o!")
		Return .F.
	ElseIf nCont>1
		MSGINFO("Permitida seleÁ„o de apenas um Contrato!","AtenÁ„o!")
		Return .F.
	Endif
	
ElseIf AllTrim(cP_ACAO)=="FORNECE"

	If Empty(cFornC3) .AND. Empty(cLojaC3)
		MSGINFO("Nenhum Fornecedor selecionado!","AtenÁ„o!")
		Return .F.
	Else
		cLojaC3:="01"
		cDesFor := Posicione("SA2",1,xFilial("SA2")+cFornC3+cLojaC3,"A2_NOME")
		cCondC3 := Posicione("SA2",1,xFilial("SA2")+cFornC3+cLojaC3,"A2_COND")
//		cDesCon := Posicione("SA2",1,xFilial("SA2")+cFornC3+cLojaC3,"A2_NOME")
	Endif

ElseIf AllTrim(cP_ACAO)=="FORNEC1"

	If Empty(cFornC1) .AND. Empty(cLojaC1)
		MSGINFO("Nenhum Fornecedor selecionado!","AtenÁ„o!")
		Return .F.
	Else
		cLojaC1:="01"
		cDesFor := Posicione("SA2",1,xFilial("SA2")+cFornC1+cLojaC1,"A2_NOME")
		If Empty(cDesFor)
			MSGINFO("Fornecedor n„o cadastrado!","AtenÁ„o!")
			Return .F.
		EndIf
	Endif

ElseIf AllTrim(cP_ACAO)=="MOEDAC1"

	If Empty(cMoedaYF)
		MSGINFO("Moeda n„o informada!","AtenÁ„o!")
		Return .F.
	Else
		nMoedaC1 := Posicione("SYF",1,xFilial("SYF")+cMoedaYF,"YF_MOEFAT")
		If SYF->(Eof())
			MSGINFO("Moeda n„o encontrada!","AtenÁ„o!")
			Return .F.
		EndIf
		If nMoedaC1==0
			MSGINFO("Moeda n„o vinculada no SigaEIC!","AtenÁ„o!")
			Return .F.
		EndIf
	Endif
	
ElseIf AllTrim(cP_ACAO)=="TIPOIMP"
	
	If Empty(cTipoImp) 
		MSGINFO("Nenhum Tipo de ImportaÁ„o selecionado!","AtenÁ„o!")
		Return .F.
	Else
		cDescImp := Posicione("ZZ8",1,xFilial("ZZ8")+cTipoImp,"ZZ8_DESC")
		nQtdKIT  := 1
	Endif
	
ElseIf AllTrim(cP_ACAO)=="PRECO"

	If nPreco==0 
		MSGINFO("PreÁo do produto deve ser informado!","AtenÁ„o!")
		Return .F.
	Endif

ElseIf AllTrim(cP_ACAO)=="CONDPAGTO"

	If Empty(cCondC3) 
		MSGINFO("Nenhuma CondiÁ„o de Pagamento selecionada!","AtenÁ„o!")
		Return .F.
	Endif
	
ElseIf AllTrim(cP_ACAO)=="MARCA"

	For nX:=1 to Len(aArqList)
		aArqList[nX,1] := !aArqList[nX, 1]
	Next

ElseIf AllTrim(cP_ACAO)=="MARCARQ"

	For nX:=1 to Len(aArqArq)
		aArqArq[nX,1] := !aArqArq[nX, 1]
	Next
EndIf


If cP_ACAO=="UNIDREQ" .OR. cP_ACAO=="bOKARQ"

	If Empty(cUnidReq) 
		MSGINFO("Unidade Requisitante n„o foi informada!","AtenÁ„o!")
		Return .F.
	Endif
EndIf

If cP_ACAO=="CODCOMP" .OR. cP_ACAO=="bOKARQ"

	If Empty(cCodCompr) 
		MSGINFO("Comprador n„o foi informado!","AtenÁ„o!")
		Return .F.
	Endif
EndIf

If cP_ACAO=="bOKARQ"
	For nX:=1 to Len(aArqArq)
		If aArqArq[nX,1]
			Return .T.
		Endif
	Next 
	
    MSGINFO("Nenhum arquivo foi selecionado!","AtenÁ„o!")
	Return .F.
Endif

If cP_ACAO=="dDFINC3"
	If xVar>yVar
		MsgInfo(OemToAnsi("Intervalo de datas inv·lido!"),"AtenÁ„o!")
		Return(.f.)
	EndIf
EndIf

Return .T.



Static Function ValidPerg
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg  :=  PADR(cPerg,   IIf(Alltrim(cVersao) == "MP8.11",6,10))
AADD(aRegs, {cPerg,"01","Fornecedor de     ","","","mv_ch1","C",(TamSX3("A2_COD")[1]  ) ,0,0,"G","","mv_par01",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","SA2","","",""})
AADD(aRegs, {cPerg,"02","Fornecedor Ate    ","","","mv_ch2","C",(TamSX3("A2_COD")[1]  ) ,0,0,"G","","mv_par02",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","SA2","","",""})
AADD(aRegs, {cPerg,"03","Produto de        ","","","mv_ch3","C",(TamSX3("B1_COD")[1]  ) ,0,0,"G","","mv_par03",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","SB1","","",""})
AADD(aRegs, {cPerg,"04","Produto Ate       ","","","mv_ch4","C",(TamSX3("B1_COD")[1]  ) ,0,0,"G","","mv_par04",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","SB1","","",""})
AADD(aRegs, {cPerg,"05","Emissao de        ","","","mv_ch5","D",08                      ,0,0,"G","","mv_par05",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","   ","","",""})
AADD(aRegs, {cPerg,"06","Emissao Ate       ","","","mv_ch6","D",08                      ,0,0,"G","","mv_par06",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","   ","","",""})
AADD(aRegs, {cPerg,"07","Cond.Pagto. de    ","","","mv_ch7","C",(TamSX3("C3_COND")[1])  ,0,0,"G","","mv_par07",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","SE4","","",""})
AADD(aRegs, {cPerg,"08","Cond.Pagto. Ate   ","","","mv_ch8","C",(TamSX3("C3_COND")[1])  ,0,0,"G","","mv_par08",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","SE4","","",""})
AADD(aRegs, {cPerg,"09","Filial Entrega de ","","","mv_ch9","C",(TamSX3("C3_FILENT")[1]),0,0,"G","","mv_par09",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","   ","","",""})
AADD(aRegs, {cPerg,"10","Filial Entrega Ate","","","mv_cha","C",(TamSX3("C3_FILENT")[1]),0,0,"G","","mv_par10",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","   ","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

Return


Static Function zCaoaSp()
Local oDLG, oListBox, oDLG1, oListBox1, oDLG2
Local cQuery := ""
Local _oMemo := " "
Local bOK,bCANCEL,aBUTTONS,nBTOP
Local bOK1,bCANCEL1,nBTOP1
Local bOK2,bCANCEL2,nBTOP2

Local oOk := LoadBitmap(GetResources(), "LBOK")
Local oNo := LoadBitmap(GetResources(), "LBNO")
Local cNumCon := ""
Local nQtdTot:=0  //Quantidade Total da SC
Local cFilAAA:=""
Local cNumAnt:=""
Local cForAnt:=""
Local cLojAnt:=""
Local aArqXist := {}  //Array com todos os itens da SC
Local nPosXis  :=0
Local nItem    :=0
Local I, J     :=0

Private cFornC3 := SPACE(TamSX3("C3_FORNECE")[1])
Private cLojaC3 := SPACE(TamSX3("C3_LOJA")[1])
Private cDesFor := ""

Private cCondC3 := SPACE(TamSX3("C3_COND")[1])

Private cDesCon := ""

Private dDINIC3 := dDATABASE
Private dDFINC3 := Ctod("  /  /    ")
Private nPreco  := 1
				    

Private cMARCA 
Private lINVERTE
Private lMSErroAuto := .F.
Private aArqList := {}
Private aArqCont := {}

Private cPerg    := "CAOACOM01"

Public cObsCP	 := ""

ValidPerg2()
iF !Pergunte(cPerg,.T.)
	Return 
Endif

cMARCA   := GETMARK()
lINVERTE := .F.
bOK      := {|| nBTOP  := 1,IF(FVAL2("bOK"),oDLG:END(),nBTOP := 0)}
bCANCEL  := {|| nBTOP  := 0,oDLG:END()}
bOK1     := {|| nBTOP1 := 1,IF(FVAL2("bOK1"),oDLG1:END(),nBTOP1 := 0)}
bCANCEL1 := {|| nBTOP1 := 0,oDLG1:END()}
bOK2     := {|| nBTOP2 := 1,IF(FVAL2("bOK2"),oDLG2:END(),nBTOP2 := 0)}
bCANCEL2 := {|| nBTOP2 := 0,oDLG2:END()}

aBUTTONS := {{"LBTIK",{|| FVAL2("MARCA")},"Marca/Desmarca Todos"}}
nBTOP    := 0
nBTOP1   := 0
nBTOP2   := 0



If (Select("TRBSC1") <> 0 )
	dbSelectArea("TRBSC1")
	dbCloseArea()
Endif
	
cQuery := " SELECT C1_FILIAL,C1_NUM,C1_EMISSAO,C1_FORNECE,C1_LOJA,C1_PRODUTO,C1_DESCRI,C1_CONDPAG,C1_FILENT,C1_QUANT,C1_QUJE,"
cQuery += " C1_XDESCL1,C1_XDESCL2,SC1.R_E_C_N_O_ C1_RECNO,"
cQuery += " UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C1_XOBSREQ, 2000, 1)) AS C1_XOBSREQ, "
cQuery += " UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C1_XOBSITE, 2000, 1)) AS C1_XOBSITE "
cQuery += " FROM "+RetSQLName("SC1")+" SC1 WHERE C1_FILIAL='"+xFilial("SC1")+"' "
cQuery += " AND D_E_L_E_T_<>'*' AND C1_QUJE<C1_QUANT AND C1_RESIDUO<>'S' AND C1_COTACAO='' "
cQuery += " AND C1_FORNECE BETWEEN '"+mv_par01+"' AND '"+MV_PAR02+"' "
cQuery += " AND C1_PRODUTO BETWEEN '"+mv_par03+"' AND '"+MV_PAR04+"' "
cQuery += " AND C1_FILENT  BETWEEN '"+mv_par09+"' AND '"+MV_PAR10+"' "
cQuery += " AND C1_CONDPAG BETWEEN '"+mv_par07+"' AND '"+MV_PAR08+"' "
cQuery += " AND C1_EMISSAO BETWEEN '"+DTOS(mv_par05)+"' AND '"+DTOS(MV_PAR06)+"' "
cQuery += " ORDER BY C1_FILIAL,C1_NUM,C1_FORNECE,C1_LOJA"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBSC1",.T.,.T.)

DBSelectArea("TRBSC1")
DBGoTop()
If TRBSC1->(!Eof())
	Do While TRBSC1->(!Eof())
		aAdd(aArqList,{.F.,; 																			//1
						TRBSC1->C1_NUM,; 																//2
						DTOC(STOD(TRBSC1->C1_EMISSAO)),; 												//3
						Posicione("SA2",1,xFilial("SA2")+TRBSC1->C1_FORNECE+TRBSC1->C1_LOJA,"A2_NOME"),;//4
						TRBSC1->C1_PRODUTO,;															//5
						TRBSC1->C1_DESCRI,;																//6
						TRBSC1->C1_CONDPAG,;															//7
						TRBSC1->C1_FILENT,;																//8
						TRBSC1->C1_FORNECE+TRBSC1->C1_LOJA,;											//9
						TRBSC1->C1_QUANT-TRBSC1->C1_QUJE,;												//10
						TRBSC1->C1_XDESCL1,;															//11
						TRBSC1->C1_XDESCL2,;															//12
                        TRBSC1->C1_XOBSREQ,;															//13
						TRBSC1->C1_XOBSITE,;															//14
						Len(aArqList)+1})																//15

///////////////////////////////////////////////////////////////////////////////
		nQtdTot:=0  //Quantidade Total da SC
		cFilAAA:=TRBSC1->C1_FILIAL
		cNumAnt:=TRBSC1->C1_NUM
		cForAnt:=TRBSC1->C1_FORNECE
		cLojAnt:=TRBSC1->C1_LOJA
		While TRBSC1->(!Eof() .and. C1_FILIAL+C1_NUM+C1_FORNECE+C1_LOJA==cFilAAA+cNumAnt+cForAnt+cLojAnt)

			aAdd(aArqXist,{.F.,; 																		//1
						TRBSC1->C1_NUM,; 																//2
						DTOC(STOD(TRBSC1->C1_EMISSAO)),; 												//3
						Posicione("SA2",1,xFilial("SA2")+TRBSC1->C1_FORNECE+TRBSC1->C1_LOJA,"A2_NOME"),;//4
						TRBSC1->C1_PRODUTO,;															//5
						TRBSC1->C1_DESCRI,;																//6
						TRBSC1->C1_CONDPAG,;															//7
						TRBSC1->C1_FILENT,;																//8
						TRBSC1->C1_FORNECE+TRBSC1->C1_LOJA,;											//9
						TRBSC1->C1_QUANT-TRBSC1->C1_QUJE,;												//10
						TRBSC1->C1_XDESCL1,;															//11
						TRBSC1->C1_XDESCL2,;															//12
                        TRBSC1->C1_XOBSREQ,;															//13
						TRBSC1->C1_XOBSITE,;															//14
						Len(aArqList),;																	//15
						TRBSC1->C1_RECNO})																//16

			nQtdTot+=TRBSC1->( C1_QUANT - C1_QUJE )
			TRBSC1->(DBSkip())
		End
		aArqList[Len(aArqList),10]:=nQtdTot  //Quantidade Total da SC
///////////////////////////////////////////////////////////////////////////////

	Enddo

Else
	MSGINFO("Nenhuma SolicitaÁ„o de Compra encontrada!","AtenÁ„o!")
	Return
Endif



DEFINE MSDIALOG oDLG TITLE "GeraÁ„o de Contrato de Parceria" FROM 0,0 TO 350,680 OF oMainWnd PIXEL 

   @ 036,007 SAY "Lista de SolicitaÁıes em Aberto:" PIXEL OF oDLG
   @ 047,007 LISTBOX oListBox Fields,HEADER "","Num. SC","Emiss„o","Fornecedor","Cad.Prod.","DescriÁ„o","C.Pagto.","Filial Entrega" SIZE 330,120 OF oDlg PIXEL ColSizes 10,30,30,50,35,70,30,35
     oListBox:SetArray(aArqList)
     oListBox:bLine := {|| { IIf(aArqList[oListBox:nAt, 1], oOk, oNo),;
						     aArqList[oListBox:nAt][2],; 
						     aArqList[oListBox:nAt][3],;
						     aArqList[oListBox:nAt][4],;
					         aArqList[oListBox:nAt][5],;
					         aArqList[oListBox:nAt][6],;
					         aArqList[oListBox:nAt][7],;
					         aArqList[oListBox:nAt][8]}}
	 oListBox:BlDblClick := {|| aArqList[oListBox:nAt, 1] := !aArqList[oListBox:nAt, 1], oListBox:Refresh()}
ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS) CENTERED     

IF nBTOP == 1


		BEGIN TRANSACTION
		For i:=1 to Len(aArqList)
			If aArqList[i,1]
				
				
				aCab   := {}
				aItens := {}
				aLinha := {}
				cFornC3 := SPACE(TamSX3("C3_FORNECE")[1])
				cLojaC3 := SPACE(TamSX3("C3_LOJA")[1])
				cCondC3 := SPACE(TamSX3("C3_COND")[1])
				dDINIC3 := dDATABASE
				dDFINC3 := Ctod("  /  /    ")
				cObsCP  := ""
				nPreco  := 1				
				
				
				dbSelectArea("SC3")
				dbSetOrder(5)
				If .f.//dbSeek(xFilial("SC3")+aArqList[i,5]+aArqList[i,9])
					
					cNumCon := SC3->C3_NUM
					RecLock("SC3",.F.)
					SC3->C3_QUANT += aArqList[i,10]
					MsUnlock()

					dbSelectArea("SC1")
					dbSetOrder(1)
					If dbSeek(xFilial("SC1")+aArqList[i,2])
						RecLock("SC1",.F.)
						SC1->C1_RESIDUO := "S"
						SC1->C1_XCPARCE := "S"
						SC1->C1_XNUMCTP := cNumCon
						MsUnlock()
					Endif	

					
				Else
		
					IF MSGYESNO("Contrato de Parceria n„o encontrado para a SC "+aArqList[i,2]+"!"+CHR(13)+;
								"Deseja amarrar a um Contrato j· existente?"+CHR(13)+;
								"Caso seja selecionada a opÁ„o 'N„o', ser· gerado um novo Contrato!","AtenÁ„o!")


						dbSelectArea("SC3")
						dbSetOrder(3)
						If dbSeek(xFilial("SC3")+aArqList[i,5])
							
							Do While SC3->(!Eof()) .AND. SC3->C3_FILIAL==xFilial("SC3") .AND. AllTrim(SC3->C3_PRODUTO)==AllTrim(aArqList[i,5])
								aAdd(aArqCont,{.F., SC3->C3_NUM, DTOC(SC3->C3_EMISSAO), Posicione("SA2",1,xFilial("SA2")+SC3->C3_FORNECE+SC3->C3_LOJA,"A2_NOME"),;
												SC3->C3_COND, SC3->C3_FILENT} )
								SC3->(DBSkip())
							Enddo
						

							DEFINE MSDIALOG oDLG1 TITLE "SeleÁ„o de Contrato de Parceria" FROM 0,0 TO 350,680 OF oMainWnd PIXEL 
							
							   @ 036,007 SAY "Lista de Contratos Encontrados:" PIXEL OF oDLG1
							   @ 046,007 SAY "SolicitaÁıes de Compra: "+aArqList[i,2] PIXEL OF oDLG1
							   @ 046,107 SAY "Produto: "+AllTrim(aArqList[i,5])+"-"+aArqList[i,6] PIXEL OF oDLG1
							   @ 058,007 LISTBOX oListBox1 Fields,HEADER "","Num. Contrato","Emiss„o","Fornecedor","C.Pagto.","Filial Entrega" SIZE 330,110 OF oDlg1 PIXEL ColSizes 10,50,35,85,35,35
							     oListBox1:SetArray(aArqCont)
							     oListBox1:bLine := {|| { IIf(aArqCont[oListBox1:nAt, 1], oOk, oNo),;
													     aArqCont[oListBox1:nAt][2],; 
													     aArqCont[oListBox1:nAt][3],;
													     aArqCont[oListBox1:nAt][4],;
												         aArqCont[oListBox1:nAt][5],;
												         aArqCont[oListBox1:nAt][6] }}
								 oListBox1:BlDblClick := {|| aArqCont[oListBox1:nAt, 1] := !aArqCont[oListBox1:nAt, 1], oListBox1:Refresh()}
							ACTIVATE MSDIALOG oDLG1 ON INIT ENCHOICEBAR(oDLG1,bOK1,bCANCEL1,,) CENTERED     

							IF nBTOP1 == 1	

								For j:=1 to Len(aArqCont)
									If aArqCont[j,1]
								
										dbSelectArea("SC3")
										dbSetOrder(1)
										If dbSeek(xFilial("SC3")+aArqCont[j,2])
											RecLock("SC3",.F.)
											SC3->C3_QUANT += aArqList[i,10]
											MsUnlock()
										Endif
			
										dbSelectArea("SC1")
										dbSetOrder(1)
										If dbSeek(xFilial("SC1")+aArqList[i,2])
											RecLock("SC1",.F.)
											SC1->C1_RESIDUO := "S"
											SC1->C1_XCPARCE := "S"
											SC1->C1_XNUMCTP := aArqCont[j,2]
											MsUnlock()
										Endif
									Endif
								Next
								
							Endif
						Else
							MSGINFO("Nenhum Contrato de Parceria encontrado para o produto: "+aArqList[i,5]+"!","AtenÁ„o!")
						Endif
	
					Else

						DEFINE MSDIALOG oDLG2 TITLE "GravaÁ„o de Novo Contrato de Parceria" FROM 0,0 TO 320,550 OF oMainWnd PIXEL 
					    @ 037,010 SAY "Fornecedor" PIXEL OF oDLG2
					    @ 047,010 MSGET cFornC3 PICTURE PesqPict("SA2","A2_COD") VALID (FVAL2("FORNECE")) F3 "SA2" WHEN .T. SIZE 035,08  PIXEL OF oDLG2   
					    @ 047,050 MSGET cLojaC3 PICTURE WHEN .F. SIZE 015,08  PIXEL OF oDLG2   
					    @ 047,070 MSGET cDesFor PICTURE WHEN .F. SIZE 115,08  PIXEL OF oDLG2   

					    @ 059,010 SAY "Cond. Pagto" PIXEL OF oDLG2
					    @ 068,010 MSGET cCondC3 PICTURE PesqPict("SC3","C3_COND") VALID (FVAL2("CONDPAGTO")) F3 "SE4" WHEN .T. SIZE 015,08  PIXEL OF oDLG2   

					    @ 082,010 SAY "Data Inicial" PIXEL OF oDLG2
					    @ 091,010 MSGET dDINIC3 PICTURE PesqPict("SC3","C3_DATPRI")  WHEN .T. SIZE 045,08  PIXEL OF oDLG2   
					    @ 082,070 SAY "Data Final" PIXEL OF oDLG2
					    @ 091,070 MSGET dDFINC3 PICTURE PesqPict("SC3","C3_DATPRF") VALID (FVAL2("dDFINC3",dDInic3,dDFinc3))  WHEN .T. SIZE 045,08  PIXEL OF oDLG2   
					    
						@ 105,010 SAY "Obs. Geral Contrao Parceria" PIXEL OF oDLG2
					    @ 114,010 GET _oMemo VAR cObsCP MEMO SIZE 260, 23 WHEN .T. VALID !Empty(cObsCP)  PIXEL OF oDLG2   

						
						
						ACTIVATE MSDIALOG oDLG2 ON INIT ENCHOICEBAR(oDLG2,bOK2,bCANCEL2,,) CENTERED     

						IF nBTOP2 == 1	
							
							cNumCon := GetSxeNum("SC3","C3_NUM")
							aadd(aCab,{"C3_FILIAL"  , xFilial("SC3") , NIL})
							aadd(aCab,{"C3_NUM"		, cNumCon		 , NIL})
							aadd(aCab,{"C3_EMISSAO" , dDataBase			  })
							aadd(aCab,{"C3_FORNECE" , cFornC3        , NIL})
							aadd(aCab,{"C3_LOJA"    , cLojaC3		 , NIL})
							aadd(aCab,{"C3_COND"    , cCondC3        , NIL})
							aadd(aCab,{"C3_MOEDA"   , 1 			 , NIL})
							aadd(aCab,{"C3_XOBSCOP" ,cObsCP			 , NIL})	        

							nItem:=0
							For nPosXis:=1 to Len(aArqXist)  //Array com todos os itens da SC
								If aArqXist[nPosXis,15]==aArqList[i,15]
									nItem++
									aLinha := {}
									aadd(aLinha,{"C3_FILIAL" , xFilial("SC3")					, Nil})	
									aadd(aLinha,{"C3_ITEM"   , StrZero(nItem,len(SC3->C3_ITEM)) , Nil})  	
									aadd(aLinha,{"C3_PRODUTO", aArqXist[nPosXis,05]				, Nil})	
									aadd(aLinha,{"C3_QUANT"  , aArqXist[nPosXis,10]				, Nil})	
									aadd(aLinha,{"C3_PRECO"	 , nPreco    						, Nil})	
									aadd(aLinha,{"C3_TOTAL"	 , aArqXist[nPosXis,10]*nPreco		, Nil})			
									aadd(aLinha,{"C3_DATPRI" , dDINIC3							, Nil})	
									aadd(aLinha,{"C3_DATPRF" , dDFINC3							, Nil})	
									aadd(aLinha,{"C3_LOCAL"  , GetAdvFVal("SB1","B1_LOCREC",xFilial("SB1")+aArqXist[nPosXis,05],1,"")						, Nil})	
									aadd(aLinha,{"C3_XDESC"  , aArqXist[nPosXis,06]				, Nil})	
									aadd(aLinha,{"C3_XDESCL1", aArqXist[nPosXis,11]				, Nil})	
									aadd(aLinha,{"C3_XDESCL2", aArqXist[nPosXis,12]				, Nil})	
                                    aadd(aLinha,{"C3_XOBSCOP", aArqXist[nPosXis,13]				, Nil})
									aadd(aLinha,{"C3_XOBSITE", aArqXist[nPosXis,14]				, Nil})
									aadd(aItens,aLinha) 	  
								EndIf
							Next
							
							MSExecAuto( {|x,y,z| mata125(x,y,z)},aCab,aItens,3) 
							If lMsErroAuto 
								MostraErro()
							    DisarmTransaction()
							Else 
								ConfirmSX8()
								For nPosXis:=1 to Len(aArqXist)  //Array com todos os itens da SC
									If aArqXist[nPosXis,15]==aArqList[i,15]
										SC1->(dbGoTo(aArqXist[nPosXis,16]))  //Posiciona no SC1
										If SC1->( RecLock("SC1",.F.) )
											SC1->C1_RESIDUO := "S"
											SC1->C1_XCPARCE := "S"
											SC1->C1_XNUMCTP := cNumCon
											SC1->(MsUnlock())
										Endif
									Endif
								Next
								
									MSGINFO("Contrato de Parceria gerado: "+AllTrim(cNumCon)+"!","AtenÁ„o!")
							EndIf
						Endif

					Endif
				Endif
			
			
			Endif
		Next
		END TRANSACTION
Endif

Return





Static Function FVAL2(cP_ACAO,xVar,yVar)
Local nCont := 0
Local nX 


If AllTrim(cP_ACAO)=="bOK"
	For nX:=1 to Len(aArqList)
		If aArqList[nX,1]
			Return .T.
		Endif
	Next 
	
    MSGINFO("Nenhuma SolicitaÁ„o de Compra foi selecionada!","AtenÁ„o!")
	Return .F.

ElseIf AllTrim(cP_ACAO)=="bOK1"

	For nX:=1 to Len(aArqCont)
		If aArqCont[nX,1]
			nCont++
		Endif
	Next 
	
	If nCont==0
		MSGINFO("Nenhum Contrato de Parceria foi selecionado!","AtenÁ„o!")
		Return .F.
	ElseIf nCont>1
		MSGINFO("Permitida seleÁ„o de apenas um Contrato!","AtenÁ„o!")
		Return .F.
	Endif
	
ElseIf AllTrim(cP_ACAO)=="FORNECE"

	If Empty(cFornC3) .AND. Empty(cLojaC3)
		MSGINFO("Nenhum Fornecedor selecionado!","AtenÁ„o!")
		Return .F.
	Else
		cLojaC3:="01"
		cDesFor := Posicione("SA2",1,xFilial("SA2")+cFornC3+cLojaC3,"A2_NOME")
		cCondC3 := Posicione("SA2",1,xFilial("SA2")+cFornC3+cLojaC3,"A2_COND")
//		cDesCon := Posicione("SA2",1,xFilial("SA2")+cFornC3+cLojaC3,"A2_NOME")
	Endif

ElseIf AllTrim(cP_ACAO)=="FORNEC1"

	If Empty(cFornC1) .AND. Empty(cLojaC1)
		MSGINFO("Nenhum Fornecedor selecionado!","AtenÁ„o!")
		Return .F.
	Else
		cLojaC1:="01"
		cDesFor := Posicione("SA2",1,xFilial("SA2")+cFornC1+cLojaC1,"A2_NOME")
		If Empty(cDesFor)
			MSGINFO("Fornecedor n„o cadastrado!","AtenÁ„o!")
			Return .F.
		EndIf
	Endif

ElseIf AllTrim(cP_ACAO)=="MOEDAC1"

	If Empty(cMoedaYF)
		MSGINFO("Moeda n„o informada!","AtenÁ„o!")
		Return .F.
	Else
		nMoedaC1 := Posicione("SYF",1,xFilial("SYF")+cMoedaYF,"YF_MOEFAT")
		If SYF->(Eof())
			MSGINFO("Moeda n„o encontrada!","AtenÁ„o!")
			Return .F.
		EndIf
		If nMoedaC1==0
			MSGINFO("Moeda n„o vinculada no SigaEIC!","AtenÁ„o!")
			Return .F.
		EndIf
	Endif
	
ElseIf AllTrim(cP_ACAO)=="TIPOIMP"
	
	If Empty(cTipoImp) 
		MSGINFO("Nenhum Tipo de ImportaÁ„o selecionado!","AtenÁ„o!")
		Return .F.
	Else
		cDescImp := Posicione("ZZ8",1,xFilial("ZZ8")+cTipoImp,"ZZ8_DESC")
		nQtdKIT  := 1
	Endif
	
ElseIf AllTrim(cP_ACAO)=="PRECO"

	If nPreco==0 
		MSGINFO("PreÁo do produto deve ser informado!","AtenÁ„o!")
		Return .F.
	Endif

ElseIf AllTrim(cP_ACAO)=="CONDPAGTO"

	If Empty(cCondC3) 
		MSGINFO("Nenhuma CondiÁ„o de Pagamento selecionada!","AtenÁ„o!")
		Return .F.
	Endif
	
ElseIf AllTrim(cP_ACAO)=="MARCA"

	For nX:=1 to Len(aArqList)
		aArqList[nX,1] := !aArqList[nX, 1]
	Next

ElseIf AllTrim(cP_ACAO)=="MARCARQ"

	For nX:=1 to Len(aArqArq)
		aArqArq[nX,1] := !aArqArq[nX, 1]
	Next
EndIf


If cP_ACAO=="UNIDREQ" .OR. cP_ACAO=="bOKARQ"

	If Empty(cUnidReq) 
		MSGINFO("Unidade Requisitante n„o foi informada!","AtenÁ„o!")
		Return .F.
	Endif
EndIf

If cP_ACAO=="CODCOMP" .OR. cP_ACAO=="bOKARQ"

	If Empty(cCodCompr) 
		MSGINFO("Comprador n„o foi informado!","AtenÁ„o!")
		Return .F.
	Endif
EndIf

If cP_ACAO=="bOKARQ"
	For nX:=1 to Len(aArqArq)
		If aArqArq[nX,1]
			Return .T.
		Endif
	Next 
	
    MSGINFO("Nenhum arquivo foi selecionado!","AtenÁ„o!")
	Return .F.
Endif

If cP_ACAO=="dDFINC3"
	If xVar>yVar
		MsgInfo(OemToAnsi("Intervalo de datas inv·lido!"),"AtenÁ„o!")
		Return(.f.)
	EndIf
EndIf

Return .T.



Static Function ValidPerg2
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg  :=  PADR(cPerg,   IIf(Alltrim(cVersao) == "MP8.11",6,10))
AADD(aRegs, {cPerg,"01","Fornecedor de     ","","","mv_ch1","C",(TamSX3("A2_COD")[1]),0,0,"G","","mv_par01",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","SA2","","",""})
AADD(aRegs, {cPerg,"02","Fornecedor Ate    ","","","mv_ch2","C",(TamSX3("A2_COD")[1]),0,0,"G","","mv_par02",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","SA2","","",""})
AADD(aRegs, {cPerg,"03","Produto de        ","","","mv_ch3","C",(TamSX3("B1_COD")[1]),0,0,"G","","mv_par03",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","SB1","","",""})
AADD(aRegs, {cPerg,"04","Produto Ate       ","","","mv_ch4","C",(TamSX3("B1_COD")[1]),0,0,"G","","mv_par04",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","SB1","","",""})
AADD(aRegs, {cPerg,"05","Emissao de        ","","","mv_ch5","D",08                   ,0,0,"G","","mv_par05",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","   ","","",""})
AADD(aRegs, {cPerg,"06","Emissao Ate       ","","","mv_ch6","D",08                   ,0,0,"G","","mv_par06",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","   ","","",""})
AADD(aRegs, {cPerg,"07","Cond.Pagto. de    ","","","mv_ch7","C",(TamSX3("C3_COND")[1])  ,0,0,"G","","mv_par07",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","SE4","","",""})
AADD(aRegs, {cPerg,"08","Cond.Pagto. Ate ","","","mv_ch8","C",(TamSX3("C3_COND")[1])  ,0,0,"G","","mv_par08",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","SE4","","",""})
AADD(aRegs, {cPerg,"09","Filial Entrega de ","","","mv_ch9","C",(TamSX3("C3_FILENT")[1]),0,0,"G","","mv_par09",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","   ","","",""})
AADD(aRegs, {cPerg,"10","Filial Entrega Ate","","","mv_cha","C",(TamSX3("C3_FILENT")[1]),0,0,"G","","mv_par10",""         ,""         ,"","","",""          ,""          ,"","","",""          ,""          ,"","","",""        ,""        ,"","","",""       ,""        ,"","","   ","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

Return
