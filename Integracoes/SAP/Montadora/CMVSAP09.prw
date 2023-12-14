#include 'protheus.ch'
#include 'parmtype.ch'
/*
Grava Lancamento Contabil para ser enviado ao SAP
Chamado pelo PE DPCTB102GR
*/
user function CMVSAP09(nOpc)

Local aArea := {GetArea()}
Local cxRot	:= allTrim( superGetMv( "CAOASAP09A"	, , "CTBA102|") )
Local aRet := {}
Local aTab := {}
Local cChave := ""
Local aDadosOri := {}
Local cLoteSap := GetMv("CMV_LCTSAP")
Local lIntSAP := GetMv("CMV_INTSAP",,.T.)
Local lIntSAP09	:= GetMv("CAOASAP09B",,.T.)

// verifica se integracao com SAP estah ativa
If !lIntSAP
	Return()
Endif

// verifica se deve executar este fonte
If !lIntSAP09
	Return()
Endif

// cancelamento de nota de saida e nota de entrada, geram a sz7 por outros pontos de entrada
//If IsInCallStack("MATA520") .or. (IsInCallStack("MATA103") .and. !Inclui  .and. !Altera)
If IsInCallStack("MATA520") .or. ((IsInCallStack("MATA103") .or. IsInCallStack("MATA140")) .and. !Inclui  .and. !Altera) // 15/10/19
  	Return()
Endif 

// lancamento vindos do sap nao devem ir ( retornar ) para o sap
If Alltrim(CT2->CT2_LOTE) == Alltrim(cLoteSap)
  	Return()
Endif 

If UPPER(Alltrim(CT2->CT2_ROTINA)) $ UPPER(cxRot)
	// tratamento para a variaval nOpc
	// rotinas de contabilizacao off-line de nota de entrada e saida
	If Alltrim(CT2->CT2_ROTINA) $ "CTBANFE/CTBANFS"
		If nOpc == 1
			nOpc := 3
		Endif
	Endif

	// rotina de contabilizacao customizada do custo medio
	If FWIsInCallStack("U_CMVCTBCUS") .and. FWIsInCallStack("U_DEPCTBGRV")
		If nOpc == 1
			nOpc := 3
		Endif
	Endif
	
	If ((nOpc == 3 /*.or. nOpc == 4*/) .and. (IsInCallStack("U_DEPCTBGRV") .or. IsInCallStack("U_DPCTB102GR"))) .or. ;
		((nOpc == 5 .or. nOpc == 6) .and. (IsInCallStack("U_ANTCTBGRV") .or. IsInCallStack("U_ANCTB102GR"))) .or. ;
		(nOpc == 3 .and. IsInCallStack("U_ANTCTBGRV"))
        IF nOpc == 3 .and. IsInCallStack("U_ANTCTBGRV")  //posicionar no LP de PVF
            CT2->(DbOrderNickName("CT2ORIGEM"))
		    CT2->(DBSEEK(xFilial("CT2")+"501-"))
        ENDIF
		aRet := U_ZF05GENSAP(nOpc)
		aTab := aClone(aRet[1])
		cChave := aRet[2]
		aDadosOri := aRet[3]
		// necessidade de atualizar a variavel nopc, pois a mesma pode ser alterada de 3 para 6 no caso de exclusao de notas de entrada
		// e saida, no qual a nopc vem como 3 pelo padrao, pois eh a inclusao de um estorno de lancamento, mas nesta rotina eu 
		// altero para 6 para fazer o tratamento correto da exclusao
		nOpc := aRet[4]
		If !Empty(aTab) .and. !Empty(cChave)
			If nOpc == 3 //inclusao
				xIncZA7(aTab,cChave)
			//Elseif nOpc == 4 //Alteração
			//	xAltZA7(aTab,cChave,aDadosOri)
			Elseif nOpc == 5 .or. nOpc == 6 //Estorno
				U_ZF04GENSAP(aTab,cChave,aDadosOri)
			EndIf
		Endif
	Endif
EndIf

aEval(aArea,{|x| RestArea(x)})

return


Static Function xIncZA7(aTab,cChave)
Local aArea			:= GetArea()
Local aAreaCT2		:= CT2->(GetArea())

Local cChvCT2		:= CT2->( CT2_FILIAL + DTOS(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC )//Chave para o Wilhe
//Local cChvSZ7		:= ""
//Local cLote			:= ""
Local nCnt := 1

dbSelectArea("SZ7")

dbSelectArea("CT2")
CT2->(dbSetOrder(1))//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC

If CT2->(dbSeek(cChvCT2))
	//cChvSZ7 := CT2->( DTOS(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC )
	
	For nCnt:=1 To Len(aTab)
		U_ZF11GENSAP(CT2->CT2_FILIAL,; //Filial
		aTab[nCnt]			 ,;	//Tabela
		"1"				 ,;	//Indice Utilizado
		cChave			 ,;	//Chave
		1				 ,;	//Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
		1)					//Operação SAP 1=Inclusao;2=cancelamento
	Next
EndIf

RestArea(aAreaCT2)
RestArea(aArea)

return
