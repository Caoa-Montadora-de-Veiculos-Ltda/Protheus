#Include 'Protheus.Ch'
#Include 'ParmType.Ch'

User Function CMVCTBCUS()

Private dInicio	:= GetMv("MV_ULMES") + 1
Private _cEmp  	:= FWCodEmp()
	
If Pergunte("CMVCTBCUS",.T.)
	Processa({||xProcCont()},'Contabilização','Contabilização Fechamento Customizado- CAOA')
EndIf
	
Return

Static Function xProcCont()

Local aArea		:= GetArea()
Local cQuery  	:= ""
Local nTotRegs 	:= 0
Local cAliasTRB	:= GetNextAlias()	
Local lBat		:= IsBlind()
Local lExibeLcto:= MV_PAR02 == 1
Local lAglutina	:= MV_PAR03 == 1
	
Local cLoteCTB	:= GetMv("CMV_LOTPAD",,"008840") //Lote Contabil para esse Lançamento
Local cArqCTB	:= ""
Local nTotalLcto:= 0
Local lA330CDEV := ExistBlock("A330CDEV")
local lCTBReq   := .F.
	
Local aCT5		:= {}
Local aAuxFil   := {}

Local c641		:= ''
Local c666		:= ''
Local c668		:= ''
Local c670		:= ''
Local c672		:= ''
Local c678		:= ''
Local c679		:= ''
Local c680		:= ''
Local c681		:= ''
Local c682		:= ''
Local c66R      := ''
	
Local cOrigens 	:= "MATA240/MATA250/MATA260/MATA261/MATA330/MTA460C/MTA520C/CNA200C/MATA685/MATA185"
Local nStatus 	:= 0

Local l641		As Logical
Local l666		As Logical
Local l668		As Logical
Local l670		As Logical
Local l672		As Logical
Local l678		As Logical
Local l679		As Logical
Local l680		As Logical
Local l681		As Logical
Local l682		As Logical
Local l66R      As Logical

CT5->(DbSetOrder(1))
l641 := CT5->(DbSeek(xFilial("CT5")+"641")) 
l666 := CT5->(DbSeek(xFilial("CT5")+"666"))
l668 := CT5->(DbSeek(xFilial("CT5")+"668"))
l670 := CT5->(DbSeek(xFilial("CT5")+"670"))
l672 := CT5->(DbSeek(xFilial("CT5")+"672"))
l678 := CT5->(DbSeek(xFilial("CT5")+"678"))
l679 := CT5->(DbSeek(xFilial("CT5")+"679"))
l680 := CT5->(DbSeek(xFilial("CT5")+"680"))
l681 := CT5->(DbSeek(xFilial("CT5")+"681"))
l682 := CT5->(DbSeek(xFilial("CT5")+"682"))
l66R := CT5->(DbSeek(xFilial("CT5")+"66R"))

//Variáveis utilizadas pelo MATA330. Não apagar.
Private OJouRNeyLog
Private	a330ParamZX	:=Array(21)
Default lOnbOrd		:= .F.
Default lJourney	:= .F.
	
If _cEmp == "2010" //Executa o p.e. somente para Anapolis.
	OJouRNeyLog		:= acJourneyLog():New()
	a330ParamZX[01] := dInicio
	//Variáveis utilizadas pelo MATA330. Não apagar.

	cQuery := ""
	cQuery += " UPDATE " + RetSqlName("SD3")								+(Chr(13)+Chr(10))
	cQuery += " SET D3_DTLANC = ' ' "										+(Chr(13)+Chr(10))
	cQuery += " WHERE D3_FILIAL  =  '" + xFilial("SD3") 			+ "'" 	+(Chr(13)+Chr(10))
	cQuery += "   And D3_EMISSAO >= '" + DTOS(dInicio)  			+ "'"	+(Chr(13)+Chr(10))
	cQuery += "   And D3_EMISSAO <= '" + DTOS(MV_PAR01)				+ "'"	+(Chr(13)+Chr(10))
	cQuery += "   And D3_OP		 <> ' '	"									+(Chr(13)+Chr(10))
	cQuery += "   And D3_SEQCALC <> '" + Criavar("D3_SEQCALC",.F.)	+ "'"	+(Chr(13)+Chr(10))
	cQuery += "   And D3_ESTOrNO <> 'S'"									+(Chr(13)+Chr(10))
	cQuery += "   And D_E_L_E_T_ <> '*'"									+(Chr(13)+Chr(10))
	nStatus := TcSqlExec(cQuery)
	If (nStatus < 0)
		ConOut()
		MsgStop("TCSQLErrOr(): " + TCSQLError(), "Erro Update Banco")
		Return(.T.)
	EndIf
EndIf	

//-------------------------------------------------------------------------------------------------------------------------------
//Tipos de Lancamentos Padronizados - 666,668,678																				|
//-------------------------------------------------------------------------------------------------------------------------------
//| 641 -> Devolucao de Vendas (item Documento Entrada)                                                                         |
//| 666 -> Saida de saldo em estoque (requisicao) para materiais com apropriacao direta                                         |
//| 667 -> Antes de atualizar o custo - Saida de saldo em estoque (requisicao) para materiais com apropriacao direta            |
//| 668 -> Entrada de saldo em estoque (devolucao / producao) para materiais com apropriacao direta                             |
//| 669 -> Antes de atualizar o custo - Entrada de saldo em estoque (devolucao/producao) para materiais com apropriacao direta  |
//| 670 -> Saida de saldo em estoque (requisicao) - movimento Origem                                                            |
//| 672 -> Entrada de saldo em estoque (devolucao) - movimento destino                                                          |
//| 674 -> Saida de saldo em estoque (requisicao) no inventario On-Line                                                         |
//| 676 -> Entrada de saldo em estoque (Devolucao/Producao) no inventario On-Line                                               |
//| 678 -> Venda de mercadOria (item do Documento de Saida)                                                                     |
//| 679 -> Entrada de saldo em estoque (devolucao/producao) para materiais com apropriacao indireta                             |
//| 680 -> Saida de saldo em estoque (requisicao) para materiais com apropriacao indireta                                       |
//| 681 -> Compra / Remessa de terceiros (item Documento Entrada)                                                               |
//| 682 -> RetOrno poder de terceiros (item Documento Entrada)                                                                  |
//-------------------------------------------------------------------------------------------------------------------------------

cQuery := ""	
cQuery += " SELECT 'SD1' 			TRB_ARQ		,										"+(Chr(13)+Chr(10))
cQuery += " 		SD1.R_E_C_N_O_	TRB_RECMOV	,										"+(Chr(13)+Chr(10))
cQuery += " 		SD1.D1_SEQCALC	TRB_SEQCALC 										"+(Chr(13)+Chr(10))
cQuery += " FROM " + RetSqlName("SD1") + " SD1 											"+(Chr(13)+Chr(10))
cQuery += " WHERE	SD1.D1_FILIAL		=  '" + xFilial("SD1")			  + "'			"+(Chr(13)+Chr(10))
cQuery += " 	And SD1.D1_DTDIGIT		>= '" + Dtos(dInicio)			  + "'			"+(Chr(13)+Chr(10))
cQuery += "		And SD1.D1_DTDIGIT		<= '" + Dtos(MV_PAR01) 			  + "'			"+(Chr(13)+Chr(10))
cQuery += "		And SD1.D1_SEQCALC 		<> '" + Criavar("D1_SEQCALC",.F.) + "'			"+(Chr(13)+Chr(10))
cQuery += " 	And SD1.D_E_L_E_T_ 		= ' ' 											"+(Chr(13)+Chr(10))
cQuery += " UNION 																		"+(Chr(13)+Chr(10))
cQuery += " SELECT	'SD3'			TRB_ARQ		,										"+(Chr(13)+Chr(10))
cQuery += " 		SD3.R_E_C_N_O_	TRB_RECMOV	,										"+(Chr(13)+Chr(10))
cQuery += " 		SD3.D3_SEQCALC	TRB_SEQCALC 										"+(Chr(13)+Chr(10))
cQuery += " FROM " + RetSqlName("SD3")+ " SD3 											"+(Chr(13)+Chr(10))
cQuery += " WHERE	SD3.D3_FILIAL 		= '"  + xFilial("SD3")			  + "'			"+(Chr(13)+Chr(10))
cQuery += "		And SD3.D3_EMISSAO 		>= '" + Dtos(dInicio)			  + "'			"+(Chr(13)+Chr(10))
cQuery += "		And SD3.D3_EMISSAO 		<= '" + Dtos(MV_PAR01) 			  + "'			"+(Chr(13)+Chr(10))
cQuery += "		And SD3.D3_SEQCALC 		<> '" + Criavar("D3_SEQCALC",.F.) + "' 			"+(Chr(13)+Chr(10))
cQuery += "		And SD3.D3_ESTOrNO 		<> 'S'											"+(Chr(13)+Chr(10))
If MV_PAR04 == 3
	cQuery += " And SD3.D3_DTLANC  = ' ' 												"+(Chr(13)+Chr(10))
EndIf
If !l668
	cQuery += "	And SD3.D3_CF NOT IN ('PR0','PR1')										"+(Chr(13)+Chr(10))
EndIf
If !l670
	cQuery += "	And SD3.D3_CF NOT IN ('RE4')											"+(Chr(13)+Chr(10))
EndIf
If !l672
	cQuery += "	And SD3.D3_CF NOT IN ('DE4')											"+(Chr(13)+Chr(10))
EndIf
If !l670
	cQuery += "	And SD3.D3_CF NOT IN ('RE7')											"+(Chr(13)+Chr(10))
EndIf
If !l672
	cQuery += "	And SD3.D3_CF NOT IN ('DE7')											"+(Chr(13)+Chr(10))
EndIf
cQuery += "		And SD3.D_E_L_E_T_ 		= ' ' 											"+(Chr(13)+Chr(10))
cQuery += " UNION 																		"+(Chr(13)+Chr(10))
cQuery += " SELECT	'SD2'			TRB_ARQ		,										"+(Chr(13)+Chr(10))
cQuery += "			SD2.R_E_C_N_O_	TRB_RECMOV	,										"+(Chr(13)+Chr(10))
cQuery += "			SD2.D2_SEQCALC	TRB_SEQCALC 										"+(Chr(13)+Chr(10))
cQuery += " FROM " + RetSqlName("SD2")+ " SD2 											"+(Chr(13)+Chr(10))
cQuery += " WHERE 	SD2.D2_FILIAL		= '" + xFilial("SD2") + "'						"+(Chr(13)+Chr(10))
cQuery += " 	And SD2.D2_EMISSAO 		>= '" + Dtos(dInicio) + "'						"+(Chr(13)+Chr(10))
cQuery += "		And SD2.D2_EMISSAO 		<= '" + Dtos(MV_PAR01) + "'						"+(Chr(13)+Chr(10))
cQuery += "		And SD2.D2_SEQCALC 		<> '" + Criavar("D2_SEQCALC",.F.) + "'			"+(Chr(13)+Chr(10))
cQuery += "		And SD2.D_E_L_E_T_ 		= ' '											"+(Chr(13)+Chr(10))
cQuery += " OrDER BY 3 																	"+(Chr(13)+Chr(10))
cQuery := ChangeQuery(cQuery)	

If Select(cAliasTRB) <> 0 ; (cAliasTRB)->(DbCloseArea()) ; EndIf
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTRB, .F., .T.)
DbSelectArea(cAliasTRB)
(cAliasTRB)->(DbGoTop())
	
If MV_PAR04 < 3

	If !lBat
		(cAliasTRB)->(IncProc("Apagando Lancamentos"))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Utiliza reprocessamento contabil            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aAuxFil,cFilAnt)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ApagAndo Lancamentos Contabeis do Periodo   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cA100Apaga(cOrigens,MV_PAR01,.F.)		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reprocessamento Contabil para CA100APAGA()           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aAuxFil)
		A330Reproc(aAuxFil,dInicio,MV_PAR01)
	EndIf	
EndIf

If !lBat
	nTotRegs := Contar(cAliasTRB,"!Eof()")
	ProcRegua(nTotRegs)
EndIf

(cAliasTRB)->(DbGoTop())	
nHeadProv  := HeadProva(cLoteCTB,"CMVCTBCUS",Substr(cUsuario,7,6),@cArqCTB)
While !(cAliasTRB)->(Eof())

	If !lBat
		(cAliasTRB)->(IncProc("Processando ..."))
	EndIf

	If (cAliasTRB)->TRB_ARQ == "SD1"
		DbSelectArea("SD1")
		SD1->(DbGoTo((cAliasTRB)->TRB_RECMOV))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o movimento foi processado pela funcao A330Recalc()  | 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SubStr(D1_SEQCALC,1,Len(DTOS(dInicio))) <> DTOS(dInicio)
			DbSelectArea(cAliasTRB)
			DbSkip()
			Loop
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no SB1 para fOrmulas de lancamento contabil        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SB1")
		SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no SF4 - TES                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SF4")
		SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES))
		DbSelectArea("SD1")
	
		If SF4->F4_PODER3 == "D"
			//-- Gera o lancamento no arquivo de prova
			c682 		:= CtRelation("682")
			nTotalLcto	+= DetProva(nHeadProv,'682',"CMVCTBCUS",cLoteCTB,,,,,@c682,@aCT5,,/*@aFlagCTB*/)
			(cAliasTRB)->(DbSkip())
			Loop
		EndIf
			
		If SD1->D1_TIPO != "D"
			//-- Gera o lancamento no arquivo de prova
			c681		:= CtRelation("681")
			nTotalLcto	+= DetProva(nHeadProv,'681',"CMVCTBCUS",cLoteCTB,,,,,@c681,@aCT5,,/*@aFlagCTB*/)
			(cAliasTRB)->(DbSkip())
			Loop
		Else
			//-- Gera o lancamento no arquivo de prova
			c641		:= CtRelation("641")
			nTotalLcto	+= DetProva(nHeadProv,'641',"CMVCTBCUS",cLoteCTB,,,,,@c641,@aCT5,,/*@aFlagCTB*/)
			(cAliasTRB)->(DbSkip())
			Loop
		EndIf
		
	ElseIf (cAliasTRB)->TRB_ARQ == "SD3"
		DbSelectArea("SD3")
		SD3->(DbGoTo((cAliasTRB)->TRB_RECMOV))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no SB1 para fOrmulas de lancamento contabil        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SB1")
		SB1->(DbSeek(xFilial("SB1") + SD3->D3_COD))
			
		DbSelectArea("SD3")
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o movimento foi processado pela funcao A330Recalc()  | 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SubStr(SD3->D3_SEQCALC,1,Len(DTOS(dInicio))) <> DTOS(dInicio)
			DbSelectArea(cAliasTRB)
			(cAliasTRB)->(DbSkip())
			Loop
		EndIf
		
		//-- Producoes
		If Alltrim(SD3->D3_CF) $ "PR0/PR1"	
			DbSelectArea("SC2")
			SC2->(DbSetOrder(1))
			If SC2->(DbSeek(xFilial("SC2")+SD3->D3_OP)) .And. MV_PAR05 <> 1  // Alterado Carneiro	
				RecLock("SD3",.F.)
				SD3->D3_DTLANC := dDataBase
				SD3->(MsUnlock())
				//-- Gera o lancamento no arquivo de prova
				c668		:= CtRelation("668")
				nTotalLcto	+= DetProva(nHeadProv,'668',"CMVCTBCUS",cLoteCTB,,,,,@c668,@aCT5,,/*@aFlagCTB*/)
				(cAliasTRB)->(DbSkip())
	        	Loop			
	        EndIf
		//-- Transferencias / Requisicao
		ElseIf Alltrim(SD3->D3_CF) == "RE4"	
			//-- Gera o lancamento no arquivo de prova
			c670		:= CtRelation("670")
			nTotalLcto	+= DetProva(nHeadProv,'670',"CMVCTBCUS",cLoteCTB,,,,,@c670,@aCT5,,/*@aFlagCTB*/)
			(cAliasTRB)->(DbSkip())
			Loop
		//-- Transferencias / Devolucao
		ElseIf Alltrim(SD3->D3_CF) == "DE4"	
			//-- Gera o lancamento no arquivo de prova
			c672		:= CtRelation("672")
			nTotalLcto	+= DetProva(nHeadProv,'672',"CMVCTBCUS",cLoteCTB,,,,,@c672,@aCT5,,/*@aFlagCTB*/)
			(cAliasTRB)->(DbSkip())
			Loop
		//-- Transferencias Multiplas / Requisicao
		ElseIf Alltrim(SD3->D3_CF) == "RE7"	
			//-- Gera o lancamento no arquivo de prova
			c670		:= CtRelation("670")
			nTotalLcto	+= DetProva(nHeadProv,'670',"CMVCTBCUS",cLoteCTB,,,,,@c670,@aCT5,,/*@aFlagCTB*/)
			(cAliasTRB)->(DbSkip())
			Loop
		//-- Transferencias Multiplas / Devolucao
		ElseIf Alltrim(SD3->D3_CF) == "DE7"	
			//-- Gera o lancamento no arquivo de prova
			c672		:= CtRelation("672")
			nTotalLcto	+= DetProva(nHeadProv,'672',"CMVCTBCUS",cLoteCTB,,,,,@c672,@aCT5,,/*@aFlagCTB*/)				
			(cAliasTRB)->(DbSkip())
	        Loop
		//-- RE0,1,2,3 e suas DE's respectivas e não tem rateio pOr centro de custo
		ElseIf Alltrim(SD3->D3_CF) != "DE7" .And. Alltrim(D3_CF) != "DE4"  .And. !U_TemRatCC(.T.)
			//-- Gera o lancamento no arquivo de prova
			If SubStr(SD3->D3_CF,3,1) != "2"
				If SD3->D3_TM <= "500"
					RecLock("SD3",.F.)
					SD3->D3_DTLANC := dDataBase
					SD3->(MsUnlock())

					IF	( MV_PAR05 == 1 .And. !Empty(SD3->D3_NUMSA) ) .Or.;
						( MV_PAR05 == 2 .And.  Empty(SD3->D3_NUMSA) ) .Or.;
						( MV_PAR05 == 3 )
						c668		:= CtRelation("668")
						nTotalLcto	+= DetProva(nHeadProv,'668',"CMVCTBCUS",cLoteCTB,,,,,@c668,@aCT5,,/*@aFlagCTB*/)
					EndIF
					(cAliasTRB)->(DbSkip())
					Loop
				Else
					RecLock("SD3",.F.)
					SD3->D3_DTLANC := dDataBase
					SD3->(MsUnlock())
					IF	( MV_PAR05 == 1 .And. !Empty(SD3->D3_NUMSA) ) .Or.;
						( MV_PAR05 == 2 .And.  Empty(SD3->D3_NUMSA) ) .Or.;
						( MV_PAR05 == 3 )
						//-- Gera o lancamento no arquivo de prova
						c666		:= CtRelation("666")
						nTotalLcto	+= DetProva(nHeadProv,'666',"CMVCTBCUS",cLoteCTB,,,,,@c666,@aCT5,,/*@aFlagCTB*/)
					EndIF
					(cAliasTRB)->(DbSkip())
					Loop
				EndIf
			Else
				If SD3->D3_TM <= "500"
					//-- Gera o lancamento no arquivo de prova
					c679		:= CtRelation("679")
					nTotalLcto	+= DetProva(nHeadProv,'679',"CMVCTBCUS",cLoteCTB,,,,,@c679,@aCT5,,/*@aFlagCTB*/)
					(cAliasTRB)->(DbSkip())
					Loop
				Else
					//-- Gera o lancamento no arquivo de prova
					c680		:= CtRelation("680")
					nTotalLcto	+= DetProva(nHeadProv,'680',"CMVCTBCUS",cLoteCTB,,,,,@c680,@aCT5,,/*@aFlagCTB*/)
					(cAliasTRB)->(DbSkip())
					Loop
				EndIf
			EndIf
		//Requisição de armazem com rateio pOr Centro de Custo
		ElseIf !Empty(SD3->D3_NUMSA) .And. !Empty(SD3->D3_ITEMSA) .And. U_TemRatCC(.T.) 

			lCTBReq   := .F.
				
			//Posiciona na tabela SCP
			SCP->(DbSetOrder(1))
			If SCP->(DbSeek(SD3->(D3_FILIAL+D3_NUMSA+D3_ITEMSA)))
				
				//Posiciona na tabela SGS rateio pOr Centro de Custo
				SGS->(DbSetOrder(1))
				SGS->(DbSeek(SCP->(CP_FILIAL + CP_NUM + CP_ITEM),.F.))
	
				While !SGS->(EOF()) .And. SGS->GS_FILIAL  == SCP->CP_FILIAL	; 
									.And. SGS->GS_SOLICIT == SCP->CP_NUM	;
									.And. SGS->GS_ITEMSOL == SCP->CP_ITEM
	
					//-- Gera o lancamento no arquivo de prova                  
					c66R		:= CtRelation("66R")
	    			nTotalLcto	+= DetProva(nHeadProv,'66R',"CMVCTBCUS",cLoteCTB,,,,,@c66R,@aCT5,,/*@aFlagCTB*/)
					lCTBReq		:= .T.
					SGS->(DbSkip())
				End
			EndIf
				
			If lCTBReq   
				RecLock("SD3",.F.)
				SD3->D3_DTLANC := dDataBase
				SD3->(MsUnlock())
			EndIf
				
			(cAliasTRB)->(DbSkip())
			Loop		
		EndIf
	ElseIf (cAliasTRB)->TRB_ARQ == "SD2"
		DbSelectArea("SD2")
		SD2->(DbGoTo((cAliasTRB)->TRB_RECMOV))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o movimento foi processado pela funcao A330Recalc()  | 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SubStr(SD2->D2_SEQCALC,1,Len(DTOS(dInicio))) <> DTOS(dInicio)
			DbSelectArea(cAliasTRB)
			(cAliasTRB)->(DbSkip())
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no SB1 para fOrmulas de lancamento contabil        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SB1")
		SB1->(DbSeek(xFilial("SB1") + SD2->D2_COD))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no SF4 - TES                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SF4")
		SF4->(DbSeek(xFilial("SF4") + SD2->D2_TES))
			
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
		SA1->(DbSeek(xFilial("SA1") + SD2->(D2_CLIENTE + D2_LOJA)))
			
		DbSelectArea("SD2")    
		If SF4->F4_PODER3 <> "D" .And. MV_PAR05 <> 2 //Alterado Carneiro
			If SD2->D2_TIPO != "D"
				//-- Gera o lancamento no arquivo de prova
				c678		:= CtRelation("678")
				nTotalLcto	+= DetProva(nHeadProv,'678',"CMVCTBCUS",cLoteCTB,,,,,@c678,@aCT5,,/*@aFlagCTB*/)
				(cAliasTRB)->(DbSkip())
				Loop
			ElseIf lA330CDEV .And. ExecBlock("A330CDEV",.F.,.F.) .And.;
				SD2->D2_TIPO == "D" .And. SF4->F4_PODER3 <> "R"
				//-- Gera o lancamento no arquivo de prova
				c678		:= CtRelation("678")
				nTotalLcto	+= DetProva(nHeadProv,'678',"CMVCTBCUS",cLoteCTB,,,,,@c678,@aCT5,,/*@aFlagCTB*/)
				(cAliasTRB)->(DbSkip())
				Loop
			EndIf
		EndIf		
	EndIf

	DbSelectArea(cAliasTRB)
	(cAliasTRB)->(DbSkip())
End	

RodaProva(nHeadProv,nTotalLcto)
cA100Incl(cArqCTB,nHeadProv,1,cLoteCTB,lExibeLcto,lAglutina,,dDataBase,,/*@aFlagCTB*/)

If Select(cAliasTRB) <> 0 ; (cAliasTRB)->(DbCloseArea()) ; EndIf
RestArea(aArea)

Return
