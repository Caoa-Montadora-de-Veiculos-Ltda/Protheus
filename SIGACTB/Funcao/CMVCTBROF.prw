#include 'protheus.ch'
#include 'parmtype.ch'
#include 'ctba280.ch'

STATIC __lCusto		:=  CtbMovSaldo("CTT")
STATIC __lItem		:=  CtbMovSaldo("CTD")
STATIC __lClVL		:=  CtbMovSaldo("CTH")
STATIC __lEnt05		:= CTQ->(ColumnPos("CTQ_E05ORI")) > 0
STATIC __lEnt06		:= CTQ->(ColumnPos("CTQ_E06ORI")) > 0
STATIC __lEnt07		:= CTQ->(ColumnPos("CTQ_E07ORI")) > 0
STATIC __lEnt08		:= CTQ->(ColumnPos("CTQ_E08ORI")) > 0
STATIC __lEnt09		:= CTQ->(ColumnPos("CTQ_E09ORI")) > 0

User Function CMVCTBROF()
	
	Local cPerg 		:= "CMVCTBROF"
	Local bProcess		:= {|oSelf| xProcRat(oSelf)}
	Local cCadastro 	:= "Rateio Off-line customizado Caoa"
	Local cDescription	:= STR0002 + " " + STR0003 + " " + STR0004

	//Private oNewProc := Nil

	//oNewProc := tNewProcess():New( Funname(), cCadastro, bProcess, cDescription, cPerg )
	tNewProcess():New( Funname(), cCadastro, bProcess, cDescription, cPerg, /*aInfoCustom*/, /*lPanelAux*/, /*nSizePanelAux*/, /*cDescriAux*/, /*lViewExecute*/ , /*lOneMeter*/.T. )

	//If Pergunte(cPerg)
		//MsgRun("Rateio Off-Line","Processando",{|| xProcRat() })
	//	Processa( {|| xProcRat() }, "Rateio Off-Line", "Processando",.F.)
	//EndIf
Return

Static Function xProcRat(oSelf)
	
	Local cNextAlias 	:= GetNextAlias()
	Local cFilCT2		:= xFilial("CT2")
	Local cFilCTQ		:= xFilial("CTQ")
	
	Local aCab			:= {}
	Local aLinha		:= {}
	Local aItens		:= {}
	Local lFirst		:= .T.
	Local cItem     	:= StrZero(1,tamSX3("CT2_LINHA")[1])
	Local cPrimItem		:= cItem
	Local dDataIni		:= dDataBase 
	Local nSaldo		:= 0
	Local nValorLanc	:= 0
	Local cHist			:= ""
	//Local cIdCV8 := ""
	Local lContinua := .T.
	Local nTotalReg := 0
	Local nMaxLinhas := CtbLinMax(GetMv("MV_NUMLIN"))
	Local nCount := 0
	Local cDoc := Alltrim(MV_PAR04)
	Local lPassou := .F.
	Local cPerg 		:= "CMVCTBROF"
	
	PRIVATE dDataLanc   := mv_par01
	Private aMen := {}

	dDataIni := FirstDay(mv_par01)
	
	dbSelectArea("CTQ")
	
	// grava tabela de log cv8
	//ProcLogIni({},FunName(),,@cIdCV8)
	//ProcLogAtu("INICIO")
	oSelf:Savelog("INICIO")

	oSelf:SetRegua1(1)
	oSelf:IncRegua1("Validando rateio, aguarde...")	

	// valida se lote jah existe	
	CT2->(dbSetOrder(1))
	If CT2->(dbSeek(xFilial("CT2")+dTos(mv_par01)+mv_par02+mv_par03+mv_par04))
		lContinua := .F.
		Help("",1,"Rateio Off-line",,"Lançamento contábil já existente. Exclua o lançamento contábil e executa novamente a rotina.",1,0)
	Endif	

	If lContinua
		lContinua := _CT280RTOK( mv_par06 , mv_par07, oSelf )
	Endif	

	If lContinua
		If Select(cNextAlias) > 0
			(cNextAlias)->(DbClosearea())
		Endif
				
		BeginSql Alias cNextAlias
			SELECT *
			FROM %Table:CTQ% CTQ
			WHERE 		CTQ.CTQ_FILIAL = %Exp:cFilCTQ%
					AND	CTQ.CTQ_RATEIO BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
					AND CTQ.%NotDel%
					AND CTQ_MSBLQL IN ( ' ','2' )
					AND CTQ_STATUS IN ( ' ','1' )
			ORDER BY CTQ.CTQ_FILIAL,CTQ.CTQ_CTORI,CTQ.CTQ_CCORI,CTQ.CTQ_ITORI,CTQ.CTQ_CLORI 
		EndSql		
		Count To nTotalReg

		//ProcRegua(nTotalReg)
		oSelf:SetRegua1(nTotalReg)

		(cNextAlias)->(DbGoTop())
		
		While (cNextAlias)->(!Eof()) .and. lContinua
			aCab := {}
			aLinha := {}
			aItens := {}
			lFirst := .T.
			cItem := StrZero(1,tamSX3("CT2_LINHA")[1])
			cPrimItem := cItem
			nCount := 0
			lPassou := .T.
			
			// recarrega parametros da rotina
			Pergunte(cPerg,.F.)
			
			/*
			// carrega numero do documento disponivel
			While !ProxDoc(mv_par01,mv_par02,mv_par03,@cDoc)//,@CTF_LOCK)
			Enddo
			*/

			While (cNextAlias)->(!Eof()) .and. lContinua .and. nCount <= nMaxlinhas-2
				//Cabeçalho
				If lFirst
					AADD(aCab,{'DDATALANC'	,MV_PAR01			,Nil})
					AADD(aCab,{'CLOTE'		,Alltrim(MV_PAR02)	,Nil})
					AADD(aCab,{'CSUBLOTE'	,Alltrim(MV_PAR03)	,Nil})
					//AADD(aCab,{'CDOC'		,Alltrim(MV_PAR04)	,Nil})
					AADD(aCab,{'CDOC'		,Alltrim(cDoc)		,Nil})
					AADD(aCab,{'CPADRAO'	,''					,Nil})
					AADD(aCab,{'NTOTINF'	,0					,Nil})
					AADD(aCab,{'NTOTINFLOT'	,0					,Nil})
					lFirst := .F.
				EndIf
				
				CTQ->(dbGoTo((cNextAlias)->R_E_C_N_O_))

				//IncProc("Rateando conta: " + Alltrim(CTQ->CTQ_CTORI) + " " + AllTrim(GetAdvFVal("CT1","CT1_DESC01",xFilial("CT1")+CTQ->CTQ_CTORI,1,"")))
				oSelf:IncRegua1("Rateando conta: " + Alltrim(CTQ->CTQ_CTORI) + " " + AllTrim(GetAdvFVal("CT1","CT1_DESC01",xFilial("CT1")+CTQ->CTQ_CTORI,1,"")))
				
				nSaldo := GetSldRat( dDataIni )
				
				If nSaldo <> 0

					nValorLanc := Round( nSaldo * ( CTQ->CTQ_PERCEN / 100 ) , 4)
					
					If (nSaldo < 0 .and. nValorLanc > 0) .or. (nSaldo > 0 .and. nValorLanc < 0)
						nValorLanc *= -1
					EndIf
					
					nValorLanc := Round( nValorLanc ,2 ) // faz o arredondamento para a gravação do lançamento						
					
					cHist := SubStr(xHisPd(Alltrim(MV_PAR05)) + "-" + Alltrim((cNextAlias)->CTQ_CTORI) + "-"  + Alltrim((cNextAlias)->CTQ_CCORI) + "-" + Alltrim((cNextAlias)->CTQ_ITORI) + "-" + Alltrim((cNextAlias)->CTQ_CLORI),1,40)
					
					If nValorLanc < 0
						
						nValorLanc := ABS( nValorLanc )
						
						//Debito		
						If cItem <> cPrimItem
							cItem := Soma1(cItem)
						EndIf
						xAddLine(@aLinha,;
								"1",; //1=Debito 2=Credito
								cFilCT2,;
								cItem,;
								(cNextAlias)->CTQ_CTCPAR,; //Conta contabil
								(cNextAlias)->CTQ_CCCPAR,; //Centro de Custo
								(cNextAlias)->CTQ_ITCPAR,; //item Contabil
								(cNextAlias)->CTQ_CLCPAR,; //Classe de Valor
								MV_PAR05,; 				 //Historico padrao
								cHist,;					 //Historico
								'CMVCTBROF',;				 //Origem
								nValorLanc,oSelf)				 // Valor do lancto
						
						AADD(aItens,aLinha)
						nCount++
						
						//Credito
						cItem := Soma1(cItem)
						xAddLine(@aLinha,;
								"2",; //1=Debito 2=Credito
								cFilCT2,;
								cItem,;
								(cNextAlias)->CTQ_CTPAR ,; //Conta contabil
								(cNextAlias)->CTQ_CCPAR ,; //Centro de Custo
								(cNextAlias)->CTQ_ITPAR ,; //item Contabil
								(cNextAlias)->CTQ_CLPAR ,; //Classe de Valor
								MV_PAR05,; 				 //Historico padrao
								cHist,;					 //Historico
								'CMVCTBROF',;				 //Origem
								nValorLanc,oSelf)				 // Valor do lancto
						
						AADD(aItens,aLinha)
						nCount++
						
					ElseIf nValorLanc > 0 
						
						//Debito		
						If cItem <> cPrimItem
							cItem := Soma1(cItem)
						EndIf
						xAddLine(@aLinha,;
								"1",; //1=Debito 2=Credito
								cFilCT2,;
								cItem,;
								(cNextAlias)->CTQ_CTPAR,; //Conta contabil
								(cNextAlias)->CTQ_CCPAR,; //Centro de Custo
								(cNextAlias)->CTQ_ITPAR,; //item Contabil
								(cNextAlias)->CTQ_CLPAR,; //Classe de Valor
								MV_PAR05,; 				//Historico padrao
								cHist,;					//Historico
								'CMVCTBROF',;				//Origem
								nValorLanc,oSelf)				// Valor do lancto
						
						AADD(aItens,aLinha)
						nCount++
						
						//Credito
						cItem := Soma1(cItem)
						xAddLine(@aLinha,;
								"2",; //1=Debito 2=Credito
								cFilCT2,;
								cItem,;
								(cNextAlias)->CTQ_CTCPAR ,; //Conta contabil
								(cNextAlias)->CTQ_CCCPAR ,; //Centro de Custo
								(cNextAlias)->CTQ_ITCPAR ,; //item Contabil
								(cNextAlias)->CTQ_CLCPAR ,; //Classe de Valor
								MV_PAR05,; 				  //Historico padrao
								cHist,;					  //Historico
								'CMVCTBROF',;				  //Origem
								nValorLanc,oSelf)				  // Valor do lancto
						
						AADD(aItens,aLinha)
						nCount++

					EndIf
				EndIf
				(cNextAlias)->(dbSkip())
			Enddo

			If !Empty(aItens)
				//IncProc("Incluindo lançamento contábil.")
				//oSelf:IncRegua1("Incluindo lançamento contábil.")
				lContinua := xIncCT2(aCab,aItens)
			Endif	
			cDoc := Soma1(cDoc)
		EndDo
	Endif

	/*	
	If !Empty(aItens)
		//IncProc("Incluindo lançamento contábil.")
		oSelf:IncRegua1("Incluindo lançamento contábil.")
		xIncCT2(aCab,aItens)
	Else
		MsgAlert('Não existe itens para gravar para esses parametros')
	EndIf
	*/
	If lPassou .and. lContinua
		MsgAlert('Lançamento(s) incluído(s) com sucesso')
	Elseif lPassou .and. !lContinua
		MsgAlert('Erro na inclusão do(s) Lançamento(s)')
	ElseIf !lPassou
		MsgAlert('Não existe itens para gravar para esses parâmetros')
	Endif	

	//ProcLogAtu("FIM")
	oSelf:Savelog("FIM")
		
Return

Static Function xHisPd(cCod)
	
	Local aArea 	:= GetArea()
	Local aAreaCT8	:= CT8->(GetArea())
	
	Local cRet	:= "RATEIO"
	
	dbSelectArea("CT8")
	CT8->(dbSetOrder(1))//CT8_FILIAL+CT8_HIST
	If CT8->(dbSeek(xFilial("CT8") + cCod))
		While CT8->(!Eof())
			If CT8->CT8_IDENT == "C"
				cRet := Alltrim(CT8->CT8_DESC)
				Exit
			EndIf
			CT8->(dbSkip())
		EndDo
	EndIf
	
	RestArea(aAreaCT8)
	RestArea(aArea)
	
Return cRet

Static Function xAddLine(aLinha,cTipo,cFilCT2,cLinha,cConta,cCC,cItemCtb,cClasse,cHistPad,cHist,cOrigem,nValor,oSelf)

	Local cMen := ""

	CT1->(dbSetOrder(1))
	If CT1->(dbSeek(xFilial("CT1")+cConta))
		If CT1->CT1_CCOBRG == "1" .and. Empty(cCC)
			//cMen := "MENSAGEM: "+ STR0001 + " " + CTQ->CTQ_RATEIO + " Conta: "+Alltrim(cConta)+" Centro Custo obrigatório e não informado " // "Rateio Off-Line" ## 
			cMen := "Conta: "+Alltrim(cConta)+" Centro Custo obrigatório e não informado "
			If aScan(aMen,cMen) == 0
				Aadd(aMen,cMen)
				//ProcLogAtu( "MENSAGEM", cMen , cMen )
				oSelf:Savelog(cMen)
			Endif	
		Endif	

		If CT1->CT1_ITOBRG == "1" .and. Empty(cItemCtb)
			//cMen := "MENSAGEM: "+ STR0001 + " " + CTQ->CTQ_RATEIO + " Conta: "+Alltrim(cConta)+" Item Cont. obrigatório e não informado " // "Rateio Off-Line" ## 
			cMen := "Conta: "+Alltrim(cConta)+" Item Cont. obrigatório e não informado " // "Rateio Off-Line" ## 
			If aScan(aMen,cMen) == 0
				Aadd(aMen,cMen)
				//ProcLogAtu( "MENSAGEM", cMen , cMen )
				oSelf:Savelog(cMen)
			Endif	
		Endif	

		If CT1->CT1_CLOBRG == "1" .and. Empty(cClasse)
			//cMen := "MENSAGEM: "+ STR0001 + " " + CTQ->CTQ_RATEIO + " Conta: "+Alltrim(cConta)+" Classe Valor obrigatória e não informado " // "Rateio Off-Line" ## 
			cMen := "Conta: "+Alltrim(cConta)+" Classe Valor obrigatória e não informado " // "Rateio Off-Line" ## 
			If aScan(aMen,cMen) == 0
				Aadd(aMen,cMen)
				//ProcLogAtu( "MENSAGEM", cMen , cMen )
				oSelf:Savelog(cMen)
			Endif	
		Endif	
	Endif		

		aLinha := {}
	
		AADD(aLinha,{'CT2_FILIAL'	,Alltrim(cFilCT2)					,Nil})
		AADD(aLinha,{'CT2_LINHA'	,cLinha								,Nil})
		AADD(aLinha,{'CT2_DC'		,cTipo								,Nil})//1=Debito 2=Credito
		AADD(aLinha,{'CT2_HP'		,cHistPad							,Nil})
		AADD(aLinha,{'CT2_HIST'		,cHist 								,Nil})
		AADD(aLinha,{'CT2_VALOR'	,nValor								,Nil})			
		AADD(aLinha,{'CT2_ORIGEM'	,cOrigem 							,Nil})

		If cTipo == "1"//Debito
			AADD(aLinha,{'CT2_DEBITO'	,Alltrim(cConta)	,Nil})

			If !Empty(cCC)
				AADD(aLinha,{'CT2_CCD'	,Alltrim(cCC)	,Nil})
			EndIf
			
			If !Empty(cItemCtb)
				AADD(aLinha,{'CT2_ITEMD',Alltrim(cItemCtb)	,Nil})
			EndIf
			
			If !Empty(cClasse)
				AADD(aLinha,{'CT2_CLVLDB',Alltrim(cClasse)	,Nil})
			EndIf
			
		ElseIf cTipo == "2"//Credito
			AADD(aLinha,{'CT2_CREDIT'	,Alltrim(cConta)	,Nil})
			
			If !Empty(cCC)
				AADD(aLinha,{'CT2_CCC'	,Alltrim(cCC)	,Nil})
			EndIf
			
			If !Empty(cItemCtb)
				AADD(aLinha,{'CT2_ITEMC',Alltrim(cItemCtb)	,Nil})
			EndIf
			
			If !Empty(cClasse)
				AADD(aLinha,{'CT2_CLVLCR',Alltrim(cClasse)	,Nil})
			EndIf
			
		EndIf

return

Static Function GetSldRat( dDataIni )
	
	//Local cFilback	:= cFilant
	Local aSaldoAux	:= {}
	Local aEnt		:= {}
	
	local nRet		:= 0
	
	//--------------------------------------------------------------
	// Tratamento para obter o saldo quando há entidades adicionais
	//--------------------------------------------------------------
	If  __lEnt09 .And. !Empty(CTQ->CTQ_E09ORI)
		aEnt := {CTQ->CTQ_CTORI, CTQ->CTQ_CCORI, CTQ->CTQ_ITORI, CTQ->CTQ_CLORI, CTQ->CTQ_E05ORI, CTQ->CTQ_E06ORI, CTQ->CTQ_E07ORI, CTQ->CTQ_E08ORI, CTQ->CTQ_E09ORI}
	ElseIf  __lEnt08 .And. !Empty(CTQ->CTQ_E08ORI)
		aEnt := {CTQ->CTQ_CTORI, CTQ->CTQ_CCORI, CTQ->CTQ_ITORI, CTQ->CTQ_CLORI, CTQ->CTQ_E05ORI, CTQ->CTQ_E06ORI, CTQ->CTQ_E07ORI, CTQ->CTQ_E08ORI}
	ElseIf  __lEnt07 .And. !Empty(CTQ->CTQ_E07ORI)
		aEnt := {CTQ->CTQ_CTORI, CTQ->CTQ_CCORI, CTQ->CTQ_ITORI, CTQ->CTQ_CLORI, CTQ->CTQ_E05ORI, CTQ->CTQ_E06ORI, CTQ->CTQ_E07ORI}
	ElseIf  __lEnt06 .And. !Empty(CTQ->CTQ_E06ORI)
		aEnt := {CTQ->CTQ_CTORI, CTQ->CTQ_CCORI, CTQ->CTQ_ITORI, CTQ->CTQ_CLORI, CTQ->CTQ_E05ORI, CTQ->CTQ_E06ORI}
	ElseIf  __lEnt05 .And. !Empty(CTQ->CTQ_E05ORI)
		aEnt := {CTQ->CTQ_CTORI, CTQ->CTQ_CCORI, CTQ->CTQ_ITORI, CTQ->CTQ_CLORI, CTQ->CTQ_E05ORI}
	EndIf

	//-------------------------------------------------------------
	// Caso tenha entidades adicionais utiliza a função CTBSldCubo
	//-------------------------------------------------------------
	If Len(aEnt) > 4

		If CTQ->CTQ_TIPO = "1" //Movimento Mês
			aSaldoAux := CtbSldCubo(aEnt ,aEnt ,dDataIni ,mv_par01 ,"01" ,mv_par10 , , ,.T.)

			nRet := aSaldoAux[1] - aSaldoAux[6]

		Else  //Saldo Acumulado
			nRet := CtbSldCubo(aEnt ,aEnt ,CToD("//") ,mv_par01 ,"01" ,mv_par10 , , ,.T.)[6]

		EndIf

	ElseIf ! Empty(CTQ->CTQ_CTORI)

		If ! Empty(CTQ->CTQ_CLORI)

			// Saldo da conta/centro de custo/Item/Classe de Valor
			If CTQ->CTQ_TIPO = "1" //Movimento Mês
				nRet := MovClass(CTQ->CTQ_CTORI ,CTQ->CTQ_CCORI ,CTQ->CTQ_ITORI ,CTQ->CTQ_CLORI ,dDataIni ,mv_par01 ,"01" ,mv_par10 , 3)
			Else //Saldo Acumulado
				nRet := SaldoCTI(CTQ->CTQ_CTORI ,CTQ->CTQ_CCORI ,CTQ->CTQ_ITORI ,CTQ->CTQ_CLORI ,mv_par01 ,"01" ,mv_par10)[1]
			Endif

		ElseIf ! Empty(CTQ->CTQ_ITORI)

			// Saldo da conta/centro de custo/Item
			If CTQ->CTQ_TIPO = "1"
				nRet := MovItem(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,CTQ->CTQ_ITORI,dDataIni,mv_par01,"01",mv_par10, 3)
			Else
				nRet := SaldoCT4(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,CTQ->CTQ_ITORI,mv_par01,"01",mv_par10)[1]
			Endif

		ElseIf ! Empty(CTQ->CTQ_CCORI)

			// Saldo da conta/centro de custo
			If CTQ->CTQ_TIPO = "1"
				nRet := MovCusto(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,dDataIni,mv_par01,"01",mv_par10, 3)
			Else
				nRet := SaldoCT3(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,mv_par01,"01",mv_par10)[1]
			Endif

		Else
			// Saldo da conta
			If CTQ->CTQ_TIPO = "1"
				nRet := MovConta(CTQ->CTQ_CTORI,dDataIni,mv_par01,"01",mv_par10, 3)
			Else
				nRet := SaldoCT7(CTQ->CTQ_CTORI,mv_par01,"01",mv_par10)[1]
			Endif
		EndIf

	ElseIf 	!Empty(CTQ->CTQ_CLORI) // classe de valor
		nRet := MovClass(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,CTQ->CTQ_ITORI,CTQ->CTQ_CLORI,dDataIni,mv_par01,"01",mv_par10, If(CTQ->CTQ_TIPO = "1", 3, 4))
		
	ElseIf	!Empty(CTQ->CTQ_ITORI) // Item
		nRet := MovItem(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,CTQ->CTQ_ITORI,dDataIni,mv_par01,"01",mv_par10,If(CTQ->CTQ_TIPO = "1", 3, 4))
		
	ElseIf 	!Empty(CTQ->CTQ_CCORI) // Centro de custo
		nRet := MovCusto(CTQ->CTQ_CTORI,CTQ->CTQ_CCORI,dDataIni,mv_par01,"01",mv_par10, If(CTQ->CTQ_TIPO = "1", 3, 4))

	Endif

	nRet := Round( NoRound( nRet * (CTQ->CTQ_PERBAS / 100) , 4 ) , 4)

Return nRet

STATIC Function xIncCT2(aCabLct,aItemLct)

	Local lRet := .F.

	Private lMsErroAuto     := .F.
	Private lMsHelpAuto     := .T.
	Private CTF_LOCK        := 0
	Private lSubLote         := .T.

	MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCabLct,aItemLct, 3)

	If !lMsErroAuto
		lRet := .T.
		//MsgInfo('Inclusão com sucesso!')
	Else
		//MsgStop('Erro na inclusao!')
		MostraErro()
	EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct280RtOk ºAutor  ³Renato F. Campos    º Data ³  08/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação das entidades do rateio somente para topconn      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _CT280RTOK(cRatIni, cRatFim, oSelf)
Local lRet	  := .T.
Local cAliasE := "TMPENT"
Local cMen := ""

DEFAULT cRatIni := ""
DEFAULT cRatFim := Replicate( "Z" , len( CTQ->CTQ_RATEIO ) )

// verifica se o parametro de validação das entidades está habilitado.
// lembrando que a execução dessa rotina é opcional
//IF ! GetNewPar( "MV_VLENTRT" , .F. )
//	ProcLogAtu( "MENSAGEM","MV_VLENTRT" , STR0019 ) // "Parametro de verificação das entidades está desligado!"
//	RETURN .T.
//ENDIF

// rotina de retorno dos rateios bloqueados
lRet := _GetRtBlqEnt( cAliasE , cRatIni , cRatFim )

IF lRet
	DbSelectArea( cAliasE )
	DbGoTop()
	
	WHILE (cAliasE)->( ! Eof() )
		cMen := ""
		If GetAdvFVal("CT1","CT1_BLOQ",xFilial("CT1")+(cAliasE)->CONTA,1,"") == "1"
			cMen += IIf(!Empty((cAliasE)->CONTA),"Blq Conta: "+Alltrim((cAliasE)->CONTA)+" ","")
		Endif	
		IF __lCusto
			If GetAdvFVal("CTT","CTT_BLOQ",xFilial("CTT")+(cAliasE)->CUSTO,1,"") == "1"
				cMen += IIf(!Empty((cAliasE)->CUSTO),"Blq CCusto: "+Alltrim((cAliasE)->CUSTO)+" ","")
			Endif	
		Endif
		IF __lItem
			If GetAdvFVal("CTD","CTD_BLOQ",xFilial("CTD")+(cAliasE)->ITEM,1,"") == "1"
				cMen += IIf(!Empty((cAliasE)->ITEM),"Blq Item: "+Alltrim((cAliasE)->ITEM)+" ","")
			Endif	
		Endif
		IF __lClVL
			If GetAdvFVal("CTH","CTH_BLOQ",xFilial("CTH")+(cAliasE)->CLVL,1,"") == "1"
				cMen += IIf(!Empty((cAliasE)->CLVL),"Blq CLVL: "+Alltrim((cAliasE)->CLVL)+" ","")
			Endif	
		Endif

		//ProcLogAtu( "MENSAGEM","CT280RTOK" , STR0001 + " " + (cAliasE)->CTQ_RATEIO + STR0020 ) // "Rateio Off-Line" ## " com entidade(s) bloqueada(s)."
		//If aScan(aMen,STR0001 + " " + (cAliasE)->CTQ_RATEIO + STR0020 + cMen) == 0
		If aScan(aMen,cMen) == 0
			Aadd(aMen,cMen)
			//ProcLogAtu( "MENSAGEM", cMen , STR0001 + " " + (cAliasE)->CTQ_RATEIO + STR0020 + cMen ) // "Rateio Off-Line" ## " com entidade(s) bloqueada(s)."
			//ProcLogAtu( "MENSAGEM", cMen , cMen ) // "Rateio Off-Line" ## " com entidade(s) bloqueada(s)."
			//oSelf:Savelog("MENSAGEM: "+ STR0001 + " " + (cAliasE)->CTQ_RATEIO + STR0020 + cMen )
			oSelf:Savelog("MENSAGEM: "+ cMen )
		Endif	

		(cAliasE)->( DbSkip() )
	ENDDO
	
	// verifica se o parametro de bloqueio do rateio está ativo caso encontre algum rateio com entidade bloqueada
	//IF lRet .And. GetNewPar( "MV_BLQRAT" , .F. )
	//	lRet := Ct280BlqRt( cAliasE )
	//ENDIF
ENDIF

// fecha o cursor utilizado pela rotina
If ( Select ( cAliasE ) <> 0 )
	dbSelectArea ( cAliasE )
	dbCloseArea ()
Endif

RETURN lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetRtBlqEntºAutor  ³Renato F. Campos   º Data ³  08/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna um cursor com os rateios bloqueados                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static FUNCTION _GetRtBlqEnt( cAliasRT , cRatIni , cRatFim )
Local cQuery, cFrom, cWhere
Local lMSBLQL := .T.
Local lSTATUS := .T.
Local lret	  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RFC                                                       ³
//³	MONTAGEM DO WHERE                                         ³
//³                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// montagem do from padrão
cFrom  := " FROM " + RetSqlName( "CTQ" ) + " CTQ "

// montagem do where padrão
cWhere := " CTQ_FILIAL = '" + xFilial("CTQ") + "'"

IF ! Empty( cRatIni )
	cWhere += " AND CTQ_RATEIO >= '" + cRatIni + "'"
Endif

IF ! Empty( cRatFim )
	cWhere += " AND CTQ_RATEIO <= '" + cRatFim + "'"
Endif

IF lMSBLQL
	// somente rateios desbloqueados ou sem status de bloqueio
	cWhere += " AND CTQ_MSBLQL IN ( ' ','2' ) "
Endif

IF lSTATUS
	// somente rateios desbloqueados ou sem status de bloqueio
	cWhere += " AND CTQ_STATUS IN ( ' ','1' ) "
Endif

cWhere += " AND D_E_L_E_T_ = ' '"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RFC                                                       ³
//³	MONTAGEM DA QUERY PRINCIPAL                               ³
//³                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cQuery := " SELECT CTQ_RATEIO FROM "
cQuery := " SELECT CTQ_RATEIO, CONTA "

IF __lCusto
	cQuery += ", CUSTO "
Endif
IF __lItem
	cQuery += ", ITEM  "
Endif
IF __lClVL
	cQuery += ", CLVL  "
Endif

cQuery += " FROM "
cQuery += " 		("

// Partidas
cQuery += " SELECT DISTINCT CTQ_RATEIO, CTQ_CTORI AS CONTA"

IF __lCusto
	cQuery += ", CTQ_CCORI AS CUSTO "
Endif
IF __lItem
	cQuery += ", CTQ_ITORI AS ITEM  "
Endif
IF __lClVL
	cQuery += ", CTQ_CLORI AS CLVL  "
Endif

cQuery += "   FROM " + RetSqlName( "CTQ" ) + " CTQ "
cQuery += "  WHERE " + cWhere

cQuery += " UNION "

// Contra-partidas
cQuery += " SELECT DISTINCT CTQ_RATEIO, CTQ_CTPAR AS CONTA"

IF __lCusto
	cQuery += ", CTQ_CCPAR AS CUSTO "
Endif
IF __lItem
	cQuery += ", CTQ_ITPAR AS ITEM  "
Endif
IF __lClVL
	cQuery += ", CTQ_CLPAR AS CLVL  "
Endif

cQuery += "   FROM " + RetSqlName( "CTQ" ) + " CTQ "
cQuery += "  WHERE " + cWhere

cQuery += " UNION "

// itens de contra partida
cQuery += " SELECT DISTINCT CTQ_RATEIO, CTQ_CTCPAR AS CONTA"

IF __lCusto
	cQuery += ", CTQ_CCCPAR AS CUSTO "
Endif
IF __lItem
	cQuery += ", CTQ_ITCPAR AS ITEM  "
Endif
IF __lClVL
	cQuery += ", CTQ_CLCPAR AS CLVL  "
Endif

cQuery += "   FROM " + RetSqlName( "CTQ" ) + " CTQ "
cQuery += "  WHERE " + cWhere

// alias para a tabela
cQuery += " 		) ENT "
cQuery += " WHERE ("

// filtro da conta
cQuery += " 		ENT.CONTA IN ( "
cQuery += "				SELECT CT1.CT1_CONTA	"
cQuery += "			 	  FROM " + RetSqlName( "CT1" ) + " CT1 "
cQuery += "			 	 WHERE CT1.CT1_FILIAL = '" + xFilial("CT1") + "' "
cQuery += "			 	   AND CT1.CT1_BLOQ = '1' "
cQuery += "			 	   AND CT1.D_E_L_E_T_ = ' '"
cQuery += " 	    	 )"

IF __lCusto
	cQuery += " 		OR"
	
	// filtro do custo
	cQuery += " 		ENT.CUSTO IN ( "
	cQuery += "				SELECT CTT.CTT_CUSTO	"
	cQuery += "			 	  FROM " + RetSqlName( "CTT" ) + " CTT "
	cQuery += "			 	 WHERE CTT.CTT_FILIAL = '" + xFilial("CTT") + "' "
	cQuery += "			 	   AND CTT.CTT_BLOQ = '1' "
	cQuery += "			 	   AND CTT.D_E_L_E_T_ = ' '"
	cQuery += " 	    	 )"
Endif

IF __lItem
	cQuery += " 		OR"
	
	// filtro do Item
	cQuery += " 		ENT.ITEM IN ( "
	cQuery += "				SELECT CTD.CTD_ITEM	"
	cQuery += "			 	  FROM " + RetSqlName( "CTD" ) + " CTD "
	cQuery += "			 	 WHERE CTD.CTD_FILIAL = '" + xFilial("CTD") + "' "
	cQuery += "			 	   AND CTD.CTD_BLOQ = '1' "
	cQuery += "			 	   AND CTD.D_E_L_E_T_ = ' '"
	cQuery += " 	    	 )"
Endif

IF __lClVL
	cQuery += " 		OR"
	
	// filtro do Classe de Valor
	cQuery += " 		ENT.CLVL IN ( "
	cQuery += "				SELECT CTH.CTH_CLVL	"
	cQuery += "			 	  FROM " + RetSqlName( "CTH" ) + " CTH "
	cQuery += "			 	 WHERE CTH.CTH_FILIAL = '" + xFilial("CTH") + "' "
	cQuery += "			 	   AND CTH.CTH_BLOQ = '1' "
	cQuery += "			 	   AND CTH.D_E_L_E_T_ = ' '"
	cQuery += " 	    	 )"
Endif

cQuery += "			)"
cQuery += " GROUP BY CTQ_RATEIO, CONTA "
IF __lCusto
	cQuery += ", CUSTO "
Endif
IF __lItem
	cQuery += ", ITEM  "
Endif
IF __lClVL
	cQuery += ", CLVL  "
Endif


cQuery := ChangeQuery( cQuery )

If ( Select ( cAliasRT ) <> 0 )
	dbSelectArea ( cAliasRT )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRT,.T.,.F.)

If ( Select ( cAliasRT ) <= 0 )
	//ProcLogAtu( "ERRO","GETRTBLQENT" , STR0024 ) // "Erro na criação do cursor das entidades bloqueadas."
	lRet := .F.
Endif

RETURN lRet
