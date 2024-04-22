#Include 'Rwmake.ch'
#Include 'TopConn.ch'

#DEFINE cFONT   '<b><font size="3" color="blue"><b>'
#DEFINE cALERT  '<b><font size="3" color="red"><b>'
#DEFINE cNOFONT '</b></font></b></u>'

/*/{Protheus.doc} ZCOMF052
@author A.Carlos
@since 	27/04/2023
@version 1.0
@return ${return}, ${return_description}
@obs	
@history    Chamado pelo PE MT100AG_PE
@type function
/*/
User Function ZCOMF052()
	Local lRet := .T.
	Local i, k := 0

	FOR	i := 1 To Len(aCols)

		IF acols[i,len(acols[i])] = .T.
            k = k+1
		ELSEIF acols[i,len(acols[i])] = .F.
			aCols[I][1] := StrZero(k,4)
		ENDIF

	Next i

Return lRet

