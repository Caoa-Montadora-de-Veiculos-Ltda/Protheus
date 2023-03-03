#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "tcbrowse.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "COLORS.CH"
#DEFINE PULALINHA CHR(13)+CHR(10) 
#Define CLR_AZUL  RGB(058,074,119)         //Cor Azul
/*/{Protheus.doc} User Function ZMONIINT
@param  	
@author 	Antonio Oliveira
@version  	P12.1.33
@since  	08/11/2022
@return  	NIL
@obs        Monitor Integração Protheus
@project    http://
@history    
/*/
User Function ZMONIINT()
	Local aCoors   := FWGetDialogSize( oMainWnd )
	Local nLargura := aCoors[4]
	Local nHeight  := aCoors[3]
	Local nI
	//Local oDlgUpd, oCheckAll
	Local oTFont   := TFont():New('Arial',,10,.T.)

	Private cTitulo   := 'Monitor de Integração'
	Private oVERDE    := LoadBitmap(GetResources(),'BR_VERDE')
	Private oAMARELO  := LoadBitmap(GetResources(),'BR_AMARELO')
	Private oVERMELHO := LoadBitmap(GetResources(),'BR_VERMELHO')
	Private _Filial   := cFilant 
	Private lFilial	  := .F.
	Private nTotal	  := 2000	
	Private aBrowse   := {}
	Private aTabelas  := {}
	Private aAllReg	  := {}
	Private aChecks	  := {}
	Private aTabsFil  := {}
	Private aFiltros  := {}
	Private aStatusN  := {}
	Private lChange   := .F.
	Private aFiltEsp  := {}
	Private oDlgUpd 
	Private oCheckAll

	Default lAutoMacao := .F.

	aAdd(aStatusN , "1=Integrado")
	aAdd(aStatusN , "2=Com Erro")
	aAdd(aStatusN , "3=Aguardando")
	aAdd(aStatusN , "0=Todos")

	u_ZGENLOG( ProcName() ) //Grava log de execução de fontes

    fwMsgRun( , { || srchInteg() }, "Buscando nome Integração", "Aguarde. Selecionando..." )	

	IF !lAutoMacao
		DEFINE DIALOG oDlgUpd TITLE cTitulo FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL //"Gerenciamento de Pendências"

		//-----------------------
		//Painel Lateral esquerdo
		//-----------------------
		oPanelLat := TPanel():New( 01, 01, ,oDlgUpd,oTFont, , , , , 100, (nHeight/2) - 20, .T.,.T. )

		@ 15, 05 CHECKBOX oCheckAll VAR lChange PROMPT "Marcar uma opção por vez" WHEN PIXEL OF oPanelLat SIZE 100,015 MESSAGE "" //"Marca/Desmarca todos"
		oCheckAll:bChange := {|| ChangCheck(lChange),oDlgUpd:Refresh(),oPanelLat:Refresh()}

		For nI := 1 To Len(aTabsFil)
			//Checkbox Filtro
			aAdd(aChecks,ZPEC110C():New(oPanelLat,aTabsFil[nI][3],aTabsFil[nI][2],(nI+1) * 15,05,{|| FiltraInfo()}) )
			aAdd(aFiltEsp,ZPEC110F():New(oPanelLat,aTabsFil[nI][3],aTabsFil[nI][2],(nI+1) * 15,82,{|| FiltraInfo()}) )
		Next
		
		//----------------
		//Painel Principal
		//----------------
		oPanelPrinc := TPanel():New( 01, 100, ,oDlgUpd, , , , , , (nLargura/2)-100, (nHeight/2) - 20, .T.,.T. )
		oPanelPrinc:Refresh()
		oDlgUpd:Refresh()
	ENDIF

	aColunas := {}
	
	//aAdd(aColunas," ")
	aAdd(aColunas,"Status")
	//If FWModeAccess('SZ1',3) == "E" .Or. FWModeAccess('SZ1',2) == "E"  .Or. FWModeAccess('SZ1',1) == "E" 
	//	lFilial := .T.
		aAdd(aColunas,"Filial")
	//EndIf	
		
	aAdd(aColunas,"Cod")
	aAdd(aColunas,"Integracao")
	aAdd(aColunas,"TP.Integracao")
	aAdd(aColunas,"Ds_TPIntegracao")
	aAdd(aColunas,"Descricao Integracao")
	aAdd(aColunas,"Dt_Exec")
	aAdd(aColunas,"Hr_Exec")
	aAdd(aColunas,"Doc/to Orig")
	aAdd(aColunas,"Usuario")
	aAdd(aColunas,"HTTP")
	aAdd(aColunas,"Doc.Rem")
	aAdd(aColunas,"RegSZ1")	

	IF !lAutoMacao
	//Criação do Browse central
  	    oBrowse := TWBrowse():New( 05, 05, (nLargura/2)-110,(((nHeight)-105) * 0.6)-20,,aColunas,,;
                   oPanelPrinc,,,,,,,,,,,,.F.,,.T.,,.F.,,, )    

		//oList := TWBrowse():New( 05, 05, (nLargura/2)-110,(((nHeight)-105) * 0.6)-20,,aColunas,,oPanelPrinc,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			
		lToggleCheckBox := .T.
	
		//@ 06, 06 CHECKBOX oCheckBox VAR lToggleCheckBox PROMPT "" WHEN PIXEL OF oPanelPrinc SIZE 015,015 MESSAGE ""
		//oCheckBox:bChange := {|| MarcaTodos(oList) }

        //IF lChange
		    fwMsgRun( , { || PreencheDados() }, "Buscando dados Integração", "Aguarde. Selecionando..." )	
		//ELSE
		    //ValRegVazio()
        //ENDIF

		IF Len(aBrowse) = 0
            ValRegVazio()
		ENDIF

	    oBrowse:SetArray(aBrowse)
	    oBrowse:bLine := {||{ MudaCor(aBrowse[oBrowse:nAt,01][1]) ,;
    					aBrowse[oBrowse:nAt,01][2],;
    					aBrowse[oBrowse:nAt,01][3],; 
    					aBrowse[oBrowse:nAt,01][4],;
    					aBrowse[oBrowse:nAt,01][5],;
    					aBrowse[oBrowse:nAt,01][6],; 						
    					aBrowse[oBrowse:nAt,01][7],;
    					aBrowse[oBrowse:nAt,01][8],;
    					aBrowse[oBrowse:nAt,01][9],; 						
                        aBrowse[oBrowse:nAt,01][10],;
    					aBrowse[oBrowse:nAt,01][11],;
    					aBrowse[oBrowse:nAt,01][12],;
						aBrowse[oBrowse:nAt,01][13],;
						aBrowse[oBrowse:nAt,01][14]} }

		//Visualiza no duplo click do mouse    
		oBrowse:bLDblClick 	:= {|| VisLinha(aBrowse[oBrowse:nAt,01][14]) }                               
		oBrowse:nrowpos 	:= 1
		/*oList:SetArray(aTabelas)} }
        IF lChange == .F.
		    oList:bLine := {|| rbLine(oList:nAt,Len(aColunas)) }
		ENDIF
		//oList:bChange := {|| AlteraMemo(oList:nAt)}
		oList:bLDblClick := {|| EXPXML(aTabelas[oList:nAt][14])}  //{|| TrocaCheck(oList:nAt)}
        */
		//@ ((((nHeight/2)-5) * 0.6)-8), 05 SAY oAcao VAR "STR0013" + ":" OF oPanelPrinc PIXEL //"Detalhes da Transação"
		//oMemo := tMultiget():new( (((nHeight/2)-5) * 0.6), 05, {|u| If( PCount() == 0, cMemo, cMemo := u )}, oPanelPrinc, (nLargura/2)-110, (((nHeight/2)-5) * 0.4)-20, , , , , , .T., /*13,/*14,{||.T.},/*16,/*17,.T. )

		//-----------------------
		//Painel Inferior
		//-----------------------
		oPanelInf := TPanel():New( (nHeight/2) - 20, 01, ,oDlgUpd, , , , , , (nLargura/2), 19, .T.,.T. )

		@ 05,(nLargura/2)-625 BUTTON oBtnAvanca PROMPT "Atualizar" SIZE 60,12 WHEN (.T.) ACTION (PreencheDados(),FiltraInfo()) OF oPanelInf  PIXEL //"Atualizar"
		@ 05,(nLargura/2)-500 BUTTON oBtnAvanca PROMPT "Sair"      SIZE 60,12 WHEN (.T.) ACTION (oDlgUpd:End()) OF oPanelInf PIXEL //"Sair"
		@ 05,(nLargura/2)-350 BUTTON oBtnAvanca PROMPT "Legenda"   SIZE 60,12 WHEN (.T.) ACTION (LEGEN()) OF oPanelInf PIXEL //"Legenda"
		//@ 05,(nLargura/2)-165 BUTTON oBtnAvanca PROMPT "Mostrar o JSON" SIZE 60,12 WHEN (.T.) ACTION (EXPXML(Alltrim(aTabelas[oBrowse:nAt][14]))) OF oPanelInf  PIXEL //"Sair"
		@ 05,(nLargura/2)-165 BUTTON oBtnAvanca PROMPT "Mostrar o JSON" SIZE 60,12 WHEN (.T.) ACTION (EXPXML()) OF oPanelInf  PIXEL //"Sair"
        
		//@ 281,51 SAY "Duplo Click mostra o JSON" COLOR CLR_RED OF oDlgUpd PIXEL
	
		//ACTIVATE MSDIALOG oDlgUpd CENTERED ON INIT (buscaDados(), oList:Refresh(),/*AlteraMemo(oList:nAt)*/)

		ACTIVATE MSDIALOG oDlgUpd CENTERED ON INIT (buscaDados(), oBrowse:Refresh(),/*AlteraMemo(oList:nAt)*/)
	ENDIF
	
Return Nil


/*/{Protheus.doc} User Function VisualizarLinha
@param  	
@author 	Antonio Oliveira
@version  	P12.1.33
@since  	08/11/2022
@return  	NIL
@obs        Função para Pesquisa de Dados
@project    http://
@history    
/*/
Static Function VisLinha(cRec)
Local cTab        := "SZ1"	
Local _nReg       := Val(cRec)
Private cCadastro := cTitulo

(cTab)->(DbGoto(_nReg))
AxVisual(cTab,(cTab)->(Recno()),2)

Return()


/*/{Protheus.doc} User Function buscaDados
@param  	
@author 	Antonio Oliveira
@version  	P12.1.33
@since  	08/11/2022
@return  	NIL
@obs        Função para Pesquisa de Dados
@project    http://
@history    
/*/
Static Function buscaDados()
	Local oDlgMet

	Private nMeter := 0
	Private oMeter, oSayMtr

	DEFINE MSDIALOG oDlgMet FROM 0,0 TO 5,60 TITLE "Pesquisa" //"Executando consulta"

	oSayMtr := tSay():New(10,10,{||"Pesquisa"/*"Processando, aguarde..."*/},oDlgMet,,,,,,.T.,,,220,20) //"Processando, aguarde..."
	oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlgMet,220,10,,.T.) // cria a régua

	ACTIVATE MSDIALOG oDlgMet CENTERED ON INIT (PreencheDados(), oDlgMet:End())
Return .T.


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcInc

Incrementa a barra de progresso.

@author  A.Carlos
@version P118
@since   08/11/2022
/*/
//-------------------------------------------------------------------------------------------------
Static Function ProcInc()

	If Type("oMeter") != "U"
		nMeter++
		oMeter:Set(nMeter)
		//oSayMtr:SetText("Consultando..." + cValToChar(nMeter) + " de " + cValToChar(oMeter:nTotal) + " ") //"Consultando...  1 de 100 registros "
		oMeter:Refresh()
		//oSayMtr:CtrlRefresh()
		SysRefresh()
	else
	    //oMeter := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlgUpd,220,10,,.T.) 	
	EndIf   
Return


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcTot

Define o valor total da barra de progresso

@param nTotal - Quantidade total da barra de progresso.

@author  A.Carlos
@version P12
@since   08/11/2022
/*/
//-------------------------------------------------------------------------------------------------
Static Function ProcTot(nTotal)
   If Type("oMeter") != "U"
      oMeter:SetTotal(nTotal)
   EndIf
Return


/*/{Protheus.doc} User Function PreencheDados
@param  	
@author 	Antonio Oliveira
@version  	P12.1.33
@since  	08/11/2022
@return  	NIL
@obs        Função para Pesquisa de Dados
@project    http://
@history    
/*/
Static Function PreencheDados()
	Local nI  := 0
	Local cAliasTop := GetNextAlias()    ///"SOFORDER"
	Local cFilName  := AllTrim(FWFilialName(cEmpAnt,cFilAnt))
	Local cFiltro   := ""
	Local lAddVirgu := .F.
	Local _cWhere	:= ""
	Local _aWhere   := {}

	Private nMeter := 0
	Private oMeter, oSayMtr

	aSize(aBrowse , 0)                                       
	aSize(aAllReg , 0)
	aSize(aTabelas, 0)

	For nI := 1 To Len(aChecks)
		lAddVirgu := .F.
		If aChecks[nI]:lValue
			cFiltro := ""
			If !Empty(aFiltEsp[nI]:dDtAte) 
				cFiltro += "SZ1.Z1_DTEXEC <= '" + DtoS(aFiltEsp[nI]:dDtAte) + "' "
			EndIf
			If !Empty(aFiltEsp[nI]:dDtDe)
				If !Empty(cFiltro)
					cFiltro += " AND "
				EndIf
				cFiltro += "SZ1.Z1_DTEXEC >= '" + DtoS(aFiltEsp[nI]:dDtDe) + "' "
			EndIf
			If !Empty(aFiltEsp[nI]:cCodCP) .AND. Substr(aFiltEsp[nI]:cCodCP,1,1) <> '0'
				If !Empty(cFiltro)
					cFiltro += " AND "
				EndIf
				cFiltro += " SZ1.Z1_STATUS = '" + aFiltEsp[nI]:cCodCP + "' "
			EndIf
			If !Empty(aFiltEsp[nI]:cDesc)
				If !Empty(cFiltro)
					cFiltro += " AND "
				EndIf
				cFiltro += " SZ1.Z1_INTEGRA = '" + Substr(aFiltEsp[nI]:cDesc,1,3) + "' "
			EndIf
			If !Empty(cFiltro)
				Aadd(_aWhere, cFiltro)
			EndIf	
		EndIf
	Next nI
	//Ajustar a sentença no sql
	_cWhere := ""
	If Len(_aWhere) > 0
		//quando for maior que um tratar
		//Tem que ter a clausula AND quando somente for um registro
		If Len(_aWhere) > 1 
			_cWhere += " AND ( ( "
		Else
			_cWhere += " AND "	
		EndIf	
		For nI := 1 To Len(_aWhere)
			_cWhere += _aWhere[nI]
			If Len(_aWhere) > 1 
				_cWhere += ")"
				If Len(_aWhere) > nI
					_cWhere += " OR ( "
				EndIf	
			EndIf	
		Next nI
		If Len(_aWhere) > 1
			_cWhere += " ) "
		EndIf	
	EndIf

	_cWhere := "%" + _cWhere + "%"

	BeginSql Alias cAliasTop
        SELECT Z1_FILIAL, SZ1.R_E_C_N_O_ RECNOSZ1,Z1_STATUS,Z1_INTEGRA,Z1_NOMEITG,Z1_TPINTEG,Z1_NTPINTG,Z1_ERRO,Z1_DTEXEC,Z1_HREXEC,Z1_DOCORI,Z1_USUARIO,Z1_HTTP,Z1_DOCRECN
        FROM %Table:SZ1% SZ1 
        WHERE 
			SZ1.%notDel%
			%Exp:_cWhere%
            AND SZ1.Z1_FILIAL = %Exp:_Filial%
	EndSql

	(cAliasTop)->(dbGoTop())

	If (cAliasTop)->(!Eof()) 
	//	(cAliasTop)->(dbGoTop())
		While !(cAliasTop)->(Eof())

			//ProcInc()
		
			////SZ1->(dbGoTo((cAliasTop)->RECNOSZ1))

					aAdd(aTabelas,{})

					//aAdd(aTabelas[Len(aTabelas)], LoadBitmap( GetResources(), "LBOK" ) )

					//If lFilial
					//	aAdd(aTabelas[Len(aTabelas)],AllTrim(SZ1->Z1_FILIAL) + " - " + cFilName )
					//EndIf

					/*Do Case
					Case SZ1->Z1_STATUS == '1'
						aAdd(aTabelas[Len(aTabelas)],"Integrado")//"Integrado com sucesso"
					Case SZ1->Z1_STATUS == '2'
						aAdd(aTabelas[Len(aTabelas)],"Com Erro")//"Com erro"
					Case SZ1->Z1_STATUS == '3'
						aAdd(aTabelas[Len(aTabelas)],"Aguardando")//"Pendente de envio"
					Otherwise
						aAdd(aTabelas[Len(aTabelas)],"")
					End*/

					aAdd(aTabelas[Len(aTabelas)],(cAliasTop)->Z1_STATUS)

					//If lFilial
						aAdd(aTabelas[Len(aTabelas)],AllTrim((cAliasTop)->Z1_FILIAL) + " - " + cFilName )
					//EndIf

					aAdd(aTabelas[Len(aTabelas)],(cAliasTop)->Z1_INTEGRA)
					aAdd(aTabelas[Len(aTabelas)],AllTrim((cAliasTop)->Z1_NOMEITG))
					aAdd(aTabelas[Len(aTabelas)],(cAliasTop)->Z1_TPINTEG)
					aAdd(aTabelas[Len(aTabelas)],AllTrim((cAliasTop)->Z1_NTPINTG))	
					aAdd(aTabelas[Len(aTabelas)],AllTrim((cAliasTop)->Z1_ERRO))
					aAdd(aTabelas[Len(aTabelas)],(cAliasTop)->Z1_DTEXEC)
					aAdd(aTabelas[Len(aTabelas)],(cAliasTop)->Z1_HREXEC)
					aAdd(aTabelas[Len(aTabelas)],AllTrim((cAliasTop)->Z1_DOCORI))
					aAdd(aTabelas[Len(aTabelas)],AllTrim((cAliasTop)->Z1_USUARIO))
					aAdd(aTabelas[Len(aTabelas)],(cAliasTop)->Z1_HTTP)			
					aAdd(aTabelas[Len(aTabelas)],Str((cAliasTop)->Z1_DOCRECN))
					aAdd(aTabelas[Len(aTabelas)],Str((cAliasTop)->RECNOSZ1))	
									
					aAdd(aBrowse , {{(cAliasTop)->Z1_STATUS,;                                       
									AllTrim((cAliasTop)->Z1_FILIAL),;  
									(cAliasTop)->Z1_INTEGRA,;  
									AllTrim((cAliasTop)->Z1_NOMEITG),; 
									(cAliasTop)->Z1_TPINTEG,;
									AllTrim((cAliasTop)->Z1_NTPINTG),; 
									AllTrim((cAliasTop)->Z1_ERRO),;  
									(cAliasTop)->Z1_DTEXEC,;
									(cAliasTop)->Z1_HREXEC,; 
									AllTrim((cAliasTop)->Z1_DOCORI),;  
									AllTrim((cAliasTop)->Z1_USUARIO),;  
									(cAliasTop)->Z1_HTTP,;
									Str((cAliasTop)->Z1_DOCRECN),;
									Str((cAliasTop)->RECNOSZ1)}} ) 
				
			(cAliasTop)->(dbSkip())
		End

    else
		
   	    MSGInfo("Não há dados para esta consulta!!!","ATENÇÃO")

	EndIF

	oDlgUpd:Refresh()
	oPanelLat:Refresh()
	oBrowse:Refresh()

	aAllReg := aClone(aTabelas)

	(cAliasTop)->(dbCloseArea())
	
Return Nil


/*/{Protheus.doc} User Function FiltraInfo
@param  	
@author 	Antonio Oliveira
@version  	P12.1.33
@since  	08/11/2022
@return  	NIL
@obs        Função para Pesquisa de Dados
@project    http://
@history    
/*/
Static Function FiltraInfo()
	Local nI, nJ
	Local aFiltros := {}
	Local aFilEsp  := {}
	Local cCod     := ""
	Default lAutoMacao := .F.
	
	For nI := 1 To Len(aChecks)
		If aChecks[nI]:lValue
			aAdd(aFiltros,aChecks[nI]:cId)
			aAdd(aFilEsp,aFiltEsp[nI])
		EndIf
	Next
	
	aSize(aTabelas,0)
	
	For nI := 1 To Len(aAllReg)
		For nJ := 1 To Len(aFiltros)
			If aAllReg[nI][1] == aFiltros[nJ]   //aAllReg[nI][Len(aColunas)+3] == aFiltros[nJ]
			
					//IF (Empty(aFilEsp[nJ]:dDtDe) .Or. aFilEsp[nJ]:dDtDe <= aAllReg[nI][6]) .And. ;
					//   (Empty(aFilEsp[nJ]:dDtAte) .Or. aFilEsp[nJ]:dDtAte >= aAllReg[nI][6])
						aAdd(aTabelas,aClone(aAllReg[nI]))
					//EndIf

    				cCod := aAllReg[nI][1]

					//IF aFilEsp[nJ]:dDtDe <= aAllReg[nI][5] .And. aFilEsp[nJ]:dDtAte >= aAllReg[nI][5]
						aAdd(aTabelas,aClone(aAllReg[nI]))
					//EndIf

			EndIf
		Next
	Next
	
	ValRegVazio()
	
	IF !lAutoMacao
        oBrowse:Refresh()
	ENDIF
	
Return Nil


/*/{Protheus.doc} User Function rbLine
@param  	
@author 	Antonio Oliveira
@version  	P12.1.33
@since  	08/11/2022
@return  	NIL
@obs        Função para Pesquisa de 
Dados no array do Browse
@project    http://
@history    
/*/
Static Function rbLine(nAt,nColunas)
Local aRet := {}

	oBrowse:SetArray(aBrowse)
	Browse:bLine := {||{ MudaCor(aBrowse[oBrowse:nAt,01]) ,;
    					aBrowse[oBrowse:nAt,02],;
    					aBrowse[oBrowse:nAt,03],;
    					aBrowse[oBrowse:nAt,04],; 
    					aBrowse[oBrowse:nAt,05],;
    					aBrowse[oBrowse:nAt,06],;
    					aBrowse[oBrowse:nAt,07],; 						
    					aBrowse[oBrowse:nAt,08],;
    					aBrowse[oBrowse:nAt,09],;
    					aBrowse[oBrowse:nAt,10],; 						
                        aBrowse[oBrowse:nAt,11],;
    					aBrowse[oBrowse:nAt,12],;
    					aBrowse[oBrowse:nAt,13],;
						aBrowse[oBrowse:nAt,14]} }

Return aRet


/*/{Protheus.doc} User Function MudaCor
@param  	
@author 	Antonio Oliveira
@version  	P12.1.33
@since  	08/11/2022
@return  	NIL
@obs        Função para cor da legenda do browse
@project    http://
@history    
/*/
Static Function MudaCor(cOp)

	do case
		case cOp = '1'
			return oVERDE
		case cOp = '2'
			oBrowse:lUseDefaultColors := .F. 
  
			// Muda a cor da linha do browser 
			oBrowse:SetBlkBackColor({|| IIf(cOp = '2', CLR_HMAGENTA , Nil )})

			oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		    return oVERMELHO
		case cOp = '3'
			return oAMARELO
	Endcase

Return oVERMELHO


/*/{Protheus.doc} User Function LEGEN
@param  	
@author 	Antonio Oliveira
@version  	P12.1.33
@since  	08/11/2022
@return  	NIL
@obs        Função para apresentar a legenda do browse
@project    http://
@history    
/*/
Static Function LEGEN()
Local aLegenda := {}

    aAdd( aLegenda, { "BR_VERDE"    , "1=Integrado" })
    aAdd( aLegenda, { "BR_VERMELHO" , "2=Com Erro"  })
    aAdd( aLegenda, { "BR_AMARELO"  , "3=Aguardando"})

    BrwLegenda( cTitulo, "Legenda", aLegenda )

Return Nil


/*/{Protheus.doc} User Function ValRegVazio
@param  	
@author 	Antonio Oliveira
@version  	P12.1.33
@since  	08/11/2022
@return  	NIL
@obs        Função para cor da legenda do browse
@project    http://
@history    
/*/
Static Function ValRegVazio()
	Local nI

	If Len(aTabelas) == 0
		aAdd(aTabelas,{})
		
		For nI := 1 To Len(aColunas)
			aAdd(aTabelas[1],"")
		Next
		
		//Colunas que não aparecerão no Grid
		For nI := 1 To 7
			aAdd(aTabelas[1],"")
		Next
	EndIf
Return


//---------------------------------------------------------
// Classe construtura de checkbox dinamico
//---------------------------------------------------------
Class ZPEC110C
	//Método construtor da classe
	Method New(oDlg,cId,cDesc,nPosAlt,nPosLar,bChange) Constructor
	
	//Propriedades
	Data lValue
	Data oCheckBox
	Data cId
EndClass
//---------------------------------------------------------
Method New(oDlg,cId,cDesc,nPosAlt,nPosLar,bChange) Class ZPEC110C
	Default bChange := {|| }
	Self:cId := cId

	Self:lValue := .F.
	@ nPosAlt, nPosLar CHECKBOX Self:oCheckBox VAR Self:lValue PROMPT cDesc WHEN PIXEL OF oDlg SIZE 100,015 MESSAGE ""
	Self:oCheckBox:bChange := bChange

	//@ nPosAlt, nPosLar + 8 SAY oAcao VAR cDesc OF oDlg PIXEL

Return Self


//---------------------------------------------------------
// Classe construtura dos filtros especificos dinamicos
Class ZPEC110F
	//Método construtor da classe
	Method New(oDlg,cId,cDesc,nPosAlt,nPosLar,bOk) Constructor
	
	//Propriedades
	Data cId
	Data cDesc
	Data bOk
	Data oDlgFil
	Data dDtDe
	Data dDtAte
	Data cCodCP
	Data lOk
	Data lPend
	Data lError
	Data oCheckBox1
	Data oCheckBox2
	Data oCheckBox3
	Data cProg

	//Métodos
	Method Dialog()
EndClass


//---------------------------------------------------------
Method New(oDlg,cId,cDesc,nPosAlt,nPosLar,bOk) Class ZPEC110F
	Local oBtn

	Self:cId 	:= cId
	Self:cDesc 	:= cDesc
	Self:bOk 	:= bOk
	Self:dDtDe  := Date()  //SToD("20000101")
	Self:dDtAte := Date()  //SToD("29990101")
	Self:cCodCP := Space(01)
	Self:lOk 	:= .T.
	Self:lPend 	:= .T.
	Self:lError := .T.
	Self:cProg 	:= Space(255)

	@ nPosAlt-2,nPosLar BUTTON oBtn PROMPT "..."  SIZE 12,10 WHEN (.T.) ACTION (Self:Dialog()) OF oDlg PIXEL
	
Return Self


//---------------------------------------------------------
Method Dialog() Class ZPEC110F
	Local cIntegr 	:= Self:cId
	Local _lRet		:= .F.
	Local _nPos 
	//Verificar se esta marcado caso não, não fazer nada DAC
	For _nPos := 1 To Len(aChecks)
		If aChecks[_nPos]:cId == cIntegr  
			If aChecks[_nPos]:lValue
				_lRet := .T.
			Endif
			Exit	
		EndIf
	Next
	If !_lRet
		MSGInfo("Opção não esta marcada para pesquisa !!!","ATENÇÃO") 
		Return Nil
	Endif

	DEFINE DIALOG Self:oDlgFil TITLE Self:cDesc FROM 0,0 TO 250,500 PIXEL

	//Faixa data +3
	@ 10, 09 SAY oAcao VAR "Data" OF Self:oDlgFil PIXEL //"Data Envio"
	
	@ 22, 09 SAY oAcao VAR "De" + ":" OF Self:oDlgFil PIXEL //"De:"
	TGet():New(018,025,{|u| If(PCount()==0,Self:dDtDe,Self:dDtDe:=u)}  ,Self:oDlgFil,060,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"Self:dDtDe",,,,.T.  )
	
	@ 22, 85 SAY oAcao VAR "Até" + ":" OF Self:oDlgFil PIXEL //"Até:"
	TGet():New(018,100,{|u| If(PCount()==0,Self:dDtAte,Self:dDtAte:=u)},Self:oDlgFil,060,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"Self:dDtAte",,,,.T.  )

	//Checkbox Status +3
	//@ 35, 09 SAY oAcao VAR "Integração" + ":" OF Self:oDlgFil PIXEL //"Status:"

	//@ 43, 09 CHECKBOX Self:oCheckBox1 VAR Self:lOk    PROMPT "STR0018" /*"Integrado com sucesso"*/ WHEN PIXEL OF Self:oDlgFil SIZE 070,015 MESSAGE ""
	//@ 43, 009 + 8 SAY oAcao VAR STR0018 OF Self:oDlgFil PIXEL //"Integrado com sucesso"

	//@ 43, 90 CHECKBOX Self:oCheckBox2 VAR Self:lPend  PROMPT "STR0019" /*"Pendente de envio"*/ WHEN PIXEL OF Self:oDlgFil SIZE 070,015 MESSAGE ""
	//@ 43, 090 + 8 SAY oAcao VAR STR0019 OF Self:oDlgFil PIXEL //"Pendente de envio"

	//@ 43, 170 CHECKBOX Self:oCheckBox3 VAR Self:lError PROMPT "STR0020" /*"Pendente com erro"*/ WHEN PIXEL OF Self:oDlgFil SIZE 070,015 MESSAGE ""
	//@ 43, 170 + 8 SAY oAcao VAR STR0020 OF Self:oDlgFil PIXEL //"Pendente com erro"

	//If Self:cId == "SZ1"
	//	cIntegr := "SZ1"
	//EndIf

	@ 38, 09 SAY oAcao VAR "Status" + ":" OF Self:oDlgFil PIXEL //"Registro Específico:"
    @ 38, 39 MSCOMBOBOX Self:cCodCP ITEMS aStatusN SIZE 120,010 OF Self:oDlgFil PIXEL COLORS 0, 16777215

	//Botão Confirmar
	@ 83, 30 BUTTON oBtn PROMPT "Confirmar" SIZE 60,12 WHEN (.T.) ACTION {||PreencheDados(),Self:oDlgFil:End()} OF Self:oDlgFil PIXEL //"Replicar"
	//Botão Cancelar
	@ 083, 160 BUTTON oBtn PROMPT "Cancelar" SIZE 60,12 WHEN (.T.) ACTION {||Self:oDlgFil:End()} OF Self:oDlgFil PIXEL //"Cancelar"

	ACTIVATE MSDIALOG Self:oDlgFil CENTERED

Return Nil


Static Function Replicar(Obj)
	Local nI

	For nI := 1 To Len(aFiltEsp)
		
		aFiltEsp[nI]:dDtDe  := Obj:dDtDe
		aFiltEsp[nI]:dDtAte := Obj:dDtAte
		aFiltEsp[nI]:lOk    := Obj:lOk
		aFiltEsp[nI]:lPend  := Obj:lPend
		aFiltEsp[nI]:lError := Obj:lError
		
	Next
	
Return Nil


/*/{Protheus.doc} User Function ChangCheck
@param  	
@author 	Antonio Oliveira
@version  	P12.1.33
@since  	08/11/2022
@return  	NIL
@obs        Função para Marcar Desmarcar
@project    http://
@history    
/*/
Static Function ChangCheck(lTipo)
	//lTipo: .T. = Marcar todos, .F. = Desmarcar todos
	Local nI := 0
	
	For nI := 1 To Len(aChecks)
		aChecks[nI]:lValue := lTipo
	Next
	//PreencheDados()
	FiltraInfo()
	oDlgUpd:Refresh()
	oPanelLat:Refresh()
	oBrowse:Refresh()
Return Nil


/*/{Protheus.doc} User Function srchInteg
@param  	
@author 	Antonio Oliveira
@version  	P12.1.33
@since  	08/11/2022
@return  	NIL
@obs        Função para selecionar integrações 
@project    http://
@history    
/*/
Static function srchInteg()
	local cAliasSZ2	:= getNextAlias()

	BeginSql Alias cAliasSZ2
        SELECT Z2_FILIAL, SZ2.R_E_C_N_O_ RECNOSZ2, Z2_CODIGO CODIGO, Z2_NOME NOME
        FROM %Table:SZ2% SZ2 
        WHERE 
			SZ2.%notDel%
            AND SZ2.Z2_FILIAL = %xFilial:SZ2%
	EndSql

	( cAliasSZ2 )->(dbGoTop())

	WHILE !( cAliasSZ2 )->( EOF() )
	    aadd( aTabsFil , { "SZ1",Alltrim((cAliasSZ2)->CODIGO) + "-" + Substr(Alltrim((cAliasSZ2)->NOME),1,20), Alltrim((cAliasSZ2)->CODIGO)})
	    aadd( aAllreg  , { "SZ1",Alltrim((cAliasSZ2)->CODIGO) + "-" + Substr(Alltrim((cAliasSZ2)->NOME),1,20), Alltrim((cAliasSZ2)->CODIGO) })
	    ( cAliasSZ2 )->( DBSkip() )
	End

	( cAliasSZ2 )->( DBCloseArea() )

return()


/*/{Protheus.doc} ZPECF031 
@param  	
@author 	Antonio Oliveira
@version  	P12.1.33
@since  	04/11/2022
@return  	NIL
@obs        Função Atualiza o painel principal. Não efetua nenhum recálculo de valores.
@project   
@history    
/*/
Static Function Atualizar() 
	oBrowse:Refresh()
Return


/*/{Protheus.doc} ZPECF031 
@param  	
@author 	Antonio Oliveira
@version  	P12.1.33
@since  	04/11/2022
@return  	NIL
@obs        Função para apresentar JSON
@project   
@history    
/*/
Static Function EXPXML()
//Local aDialSize := FWGetDialogSize()
//Local _cQ       := ''
//Local cAliasQry := GetNextAlias()
Local cJSON   	:= ''
Local _nRecno 	:= 0
Local _nPosCPo	:= 14
Local _nPos
Local oDlg1
Local oMGet1

/*	_cQ := " SELECT dbms_lob.substr(Z1_JSON,900,1) AS cJS, SZ1.R_E_C_N_O_ RECNO "
	_cQ += " FROM " + RetSQLname("SZ1") +  " SZ1" 
	_cQ += " 	WHERE " 
	_cQ += "       SZ1.D_E_L_E_T_ = ' '"
	_cQ += "       AND SZ1.R_E_C_N_O_ = '" + RECNOSZ1 + "'"

	dbUseArea( .T., "TOPCONN", TCGenQry(,,_cQ),cAliasQry, .T., .T. ) 

	dbSelectArea(cAliasQry)
    dBGotop()

	If (cAliasQry)->(!Eof()) .and. !Empty((cAliasQry)->RECNO)

		Do While !(cAliasQry)->( Eof() )

			cJSON := (cAliasQry)->cJS
			(cAliasQry)->( DbSkip() )
		
		EndDo

    ENDIF
*/
//Validar se existe os dados 
//If Type("aTabelas") <> "A" .And. Len(aTabelas) <= 0
//	Return Nil
//EndIf
//Tenho que validar assim pois a tabela pode estar preenchida com zeros
//If Len(aTabelas[1]) < 14  .Or. Empty(aTabelas[1,3])  .Or.  Type("oBrowse") <> "O"   //esta posiçao é o nome da integração 
If Type("oBrowse") <> "O"   //esta posiçao é o nome da integração 
	MSGInfo("Para consulta do Json posicionar no registro a ser consultado no Browse !!!"+PULALINHA+"Clique no botão Atualizar !","ATENÇÃO") 
	Return Nil
Endif
If Len(oBrowse:AARRAY) == 0
	MSGInfo("Não existe dados no browse para esta consulta !!!"+PULALINHA+"Clique no botão Atualizar !","ATENÇÃO") 
	Return Nil
EndIf
_nPos 	:= oBrowse:nAt
If _nPos == 0
	MSGInfo("Não localizado dados para esta consulta !!!"+PULALINHA+"Clique no botão Atualizar !","ATENÇÃO") 
	Return Nil
Endif
_nRecno	:= Val(oBrowse:AARRAY[_nPos][1][_nPosCPo])  //Val(Alltrim(aTabelas[_nPos,14]))
If _nRecno <= 0
	MSGInfo("Não há dados referente a importação para esta consulta !!!"+PULALINHA+"Clique no botão Atualizar !","ATENÇÃO") 
	Return Nil
EndIf	
SZ1->(dbGoto(_nRecno))
cJSON  := SZ1->Z1_JSON
oDlg1  := MSDialog():New( 075,297,575,759,"Json ",,,.F.,,,,,,.T.,,,.T. )
oMGet1 := TMultiGet():New( 004,004,{|u| If(PCount()>0,cJSON:=u,cJSON)},oDlg1,216,232,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
oDlg1:Activate(,,,.T.)
//retornar a primeira coluna
oBrowse:nrowpos := 1
oBrowse:Refresh()
Return Nil
