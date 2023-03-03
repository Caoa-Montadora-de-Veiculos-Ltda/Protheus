#include 'protheus.ch'
#include 'parmtype.ch'
/*
=====================================================================================
Programa.:              CMVPCP13
Autor....:              Atilio Amarilla
Data.....:              05/09/2019
Descricao / Objetivo:   Apontamento BarCode. Verifica saldo do empenho nos endereços
Doc. Origem:            Contrato - GAP ACD003
Solicitante:            Cliente CAOA
Uso......:              Marfrig
Obs......:              Objetivo: Recalcular saldo quando negativo. PE_MT250SAL
=====================================================================================
*/
User Function CMVPCP13(aSaldo)

	//Local aArea	:= GetArea()
	Local nI
	Local nSaldo	:= 0

	//MsgStop("CMVPCP13(aSaldo)")

	For nI := 1 to Len(aSaldo)
	
		If aSaldo[nI][4] < 0 .And. Localiza(aSaldo[nI][1],.T.)
			//MsgStop("nI "+AllTrim(Str(nI)))
			//WmsSldD14(aArraySD4[i,w,4],cEndCheck,aArraySD4[i,w,3],"",aArraySD4[i,w,9],aArraySD4[i,w,10],.F./*lBaixaEmp*/,.T./*lProducao*/) - nQuantBxSD4 - nQtdUsada
			nSaldo	:= WmsSldD14(	aSaldo[nI][2]/*cArmazem*/	,;
									""/*cEndereco*/				,;
									aSaldo[nI][1]/*cProduto*/	,;
									""/*cNumSerie*/				,;
									""/*cLoteCtl*/				,;
									""/*cNumLote*/				,;
									.F./*lBaixaEmp*/			,;
									.T./*lProducao*/			,;
									/*cIdUnitiz*/				)
			If nSaldo > 0
				aSaldo[nI][4] := nSaldo 
			EndIf
		
		EndIf
	
	Next nI
	
	//RestArea( aArea )

Return aSaldo
