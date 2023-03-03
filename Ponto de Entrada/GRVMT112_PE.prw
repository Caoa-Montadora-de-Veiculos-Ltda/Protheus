#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} GRVMT112
Função para Gravar informações complementares da SC para SI.
@author FSW - DWC Consult
@since 20/03/2019
@version 1.0
@type function
/*/
User Function GRVMT112()
	Local aTpImp   := {}
	Local cImpTp   := ""
 	Local cImpCla  := ""
 	Local lAchouSA5:= .F.
	Local aAreaSA5	:= SA5->(GetArea())
	Local aAreaSW1	:= SW1->(GetArea())
	Local aAreaSC1	:= SC1->(GetArea())


	SA5->(DbSetOrder(1))
	SA5->(DbSeek(xFilial("SA5") + SC1->(C1_FORNECE + C1_LOJA + C1_PRODUTO)))

	lAchouSA5 := SA5->(A5_FILIAL + A5_FORNECE + A5_LOJA + A5_PRODUTO) = (xFilial("SA5") + SC1->(C1_FORNECE + C1_LOJA) + C1_PRODUTO)

	aTpImp  := zChkTpImp()
	cImpTp  := aTpImp[1]
	cImpCla := aTpImp[2]

	RecLock("SW0",.F.)
		SW0->W0_TIPIMP  := cImpTp
		SW0->W0_XCLAIMP := cImpCla

		SW0->W0_MOEDA	 := xSimbMoe(SC1->C1_MOEDA)
		SW0->W0_NR_PRO  := SC1->C1_NR_PRO

	SW0->(MsUnLock())
	
	RecLock("SW1",.F.)
		SW1->W1_CORINT	:= SC1->C1_CORINT
		SW1->W1_COREXT	:= SC1->C1_COREXT
		SW1->W1_OPCION	:= SC1->C1_OPCION
		SW1->W1_ANOFAB	:= SC1->C1_ANOFAB
		SW1->W1_ANOMOD	:= SC1->C1_ANOMOD
		SW1->W1_PRECO	:= SC1->C1_XVLUNIT

		If lAchouSA5
			SW1->W1_FABR	:= SA5->A5_FABR
			SW1->W1_FABLOJ	:= SA5->A5_FALOJA
		EndIf
	SW1->( MsUnlock() )

	If lAchouSA5
		RecLock("SC1",.F.)
		SC1->C1_FABR		:= SA5->A5_FABR
		SC1->C1_FABRLOJ	:= SA5->A5_FALOJA
		SC1->(MsUnLock())
	EndIf

	RestArea(aAreaSA5)
	RestArea(aAreaSW1)
	RestArea(aAreaSC1)
Return

Static Function xSimbMoe(nMoeda)

	Local aArea 	:= GetArea()
	Local cRet 		:= ""
	Local cAlias 	:= getNextAlias()

	BeginSql Alias cAlias
		SELECT
			SYF.YF_MOEDA
		FROM
			%TABLE:SYF% SYF
		WHERE
				SYF.%NOTDEL%
			AND SYF.YF_FILIAL = %xfilial:SYF%
			AND SYF.YF_MOEFAT = %exp:nMoeda%
	EndSQl

	While !(cAlias)->(EOF())
		cRet := (cAlias)->YF_MOEDA
		If !Empty(cRet)
			Exit
		EndIf
		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())

	RestArea(aArea)

Return cRet

/*
	Efetua checagem com a SC1, se não tiverefetua o preenchimento.
*/
Static Function zChkTpImp()
	Local aC1 	:= SC1->(getArea())
	Local aZZ8 	:= ZZ8->(getArea())
     Local cImpTp 	:= ""
     Local cImpCla	:= ""
     Local aPerg 	:= {} 
     Local aRt   	:= {}     
     Local aPrMV 	:= {MV_PAR01, MV_PAR02, MV_PAR03}
    
	cImpTp  := Posicione("SC1", 1, cFilAnt + SC1->C1_NUM, "C1_XTPIMP" )
	cImpCla := Posicione("SC1", 1, cFilAnt + SC1->C1_NUM, "C1_XCLAIMP" )


	If Vazio(cImpTp) = .F. .and. Vazio(cImpCla) = .F.
		RestArea(aC1)
		Return {cImpTp, cImpCla}
	EndIf		

     Aadd( aPerg, {9, "Não encontrado tipo de importação", 150, 20, .T.})
     Aadd( aPerg, {9, "Informe o tipo de importação", 150, 20, .T.})
     Aadd( aPerg, {1, "Tipo importacao", cImpTp, "@!", '.T.', "ZZ8" , ".T.", 60, .T.,,.T.})

     While Vazio(cImpTp) 
          If ParamBox(aPerg, "Tipo de importação:", aRt) = .T.

               cImpTp := Posicione("ZZ8", 1, FwXFilial("ZZ8") + aRt[3], "ZZ8_CODIGO")
               
               If Vazio(cImpTp) = .T.
                    ApMsgInfo(aRt[3] + " é um de importação inválido.", "MT112FIL_PE")
               EndIf
                   
          EndIF               
     EndDo

     cImpCla := Posicione("ZZ8", 1, FwXFilial("ZZ8") + cImpTp, "ZZ8_TIPO")

	RecLock("SC1", .F.)
	SC1->C1_XTPIMP  := cImpTp
	SC1->C1_XCLAIMP := cImpCla
	SC1->(MsUnlock())

     MV_PAR01 := aPrMV[1]
     MV_PAR02 := aPrMV[2]
     MV_PAR03 := aPrMV[3]

	RestArea(aC1)
	RestArea(aZZ8)

return  {cImpTp, cImpCla}



