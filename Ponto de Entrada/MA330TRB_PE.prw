#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "apwebsrv.ch"
#include "apwebex.ch"
#define CRLF chr(13) + chr(10)             
/*
==========================================================================================================
Programa.:              MA330TRB
Autor....:              Joni Lima         
Data.....:              06/05/2019 
Descricao / Objetivo:   Altera as movimentacoes na rotina do calculo do custo medio                         
Doc. Origem:            http://tdn.totvs.com/pages/releaseview.action?pageId=6087642, http://tdn.totvs.com/display/public/mp/Ponto+de+Entrada+MA330TRB
Solicitante:            Cliente
Uso......:              CAOA
==========================================================================================================
*/
User Function MA330TRB()

	Local aArea     := GetArea()
	Local aAreaTRB 	:= TRB->(GetArea())
	Local aAreaSD3  := SD3->(GetArea())
	Local _cEmp		:= FWCodEmp()
	
	If _cEmp == "2020" //Executa CaoaSp
		dbSelectArea("SD3")
		
		TRB->(dbSetOrder(4))
		TRB->(dbSeek(xFilial("SD3") + "SD3"))
		
		While !TRB->(EOF()) .And. TRB->TRB_ALIAS == "SD3"
			
			SD3->(dbGoto(TRB->TRB_RECNO))
			
			If !Empty(SD3->D3_OP) 
				RecLock("SD3",.F.)
					SD3->D3_DTLANC := CTOD("  /  /  ")
				SD3->(MsUnLock())
			EndIf
			
			TRB->(dbSkip())
		EndDo
	EndIf

	RestArea(aAreaSD3)
	RestArea(aAreaTRB)
	RestArea(aArea)

Return


