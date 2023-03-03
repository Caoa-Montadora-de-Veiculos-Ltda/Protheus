#Include "TOTVS.ch"

User Function MT120ISC()

	Local _cEmp		:= FWCodEmp()
	Local aArea		:= GetArea()

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		zMontadora()
	Else
		zCaoaSp()
	EndIf

	RestArea(aArea)

Return(NIL)

/*
==============================================================================================
Programa.:              zMontadora
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada Montadora
===============================================================================================
*/
Static Function zMontadora()

   Local nDescL1 := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "C7_XDESCL1"})

   
   aCols[N,nDescL1] := SC1->C1_XDESCL1

   If nTipoPed = 2

      aCols[n][gdFieldPos("C7_TES")]    := SC3->C3_XTES
      aCols[n][gdFieldPos("C7_XTPPED")] := SC3->C3_XTPCON
      cC7_XTPREQ                        := SC3->C3_XTPCON

   else
      
      aCols[n][gdFieldPos("C7_XTPPED")] := SC1->C1_XTPREQ
      cC7_XTPREQ                        := SC1->C1_XTPREQ
      cC7_XTPRE2                        := SC1->C1_XTPREQ

   Endif

Return ()


/*
==============================================================================================
Programa.:              zCaoaSp
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada CaoaSp
===============================================================================================
*/
Static Function zCaoaSp()

   Local nDescL1 := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "C7_XDESCL1"})

   aCols[N,nDescL1] := SC1->C1_XDESCL1

   If nTipoPed = 2

      aCols[n][gdFieldPos("C7_TES")] := SC3->C3_XTES

   Endif

//Alert("Ponto de Entrada MT120ISC - Executado")

Return ()
