/*/{Protheus.doc} 
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        PE p/ validar N.Série e Localização de veículo em estoque
@project
@history
/*/
#Include "TOTVS.ch"
#Include "RWMAKE.ch"
#Include "Topconn.ch"

User Function VX001APV()

	Local nPos := 1
	Local nPosChassi := aScan(aItePV[1], { |x| x[1] == "C6_CHASSI" })

	//aScan(aItePV, { |x,y| x[3] == "C6_DESCRI" })
	
	IF SF4->F4_ESTOQUE = 'S'     //TES controla Estoque 

		For nPos := 1 to Len(aItePV)

			AADD( aItePV[nPos] 	, 	{"C6_NUMSERI", aItePV[nPos,nPosChassi,2] , NIL } )
			AADD( aItePV[nPos] 	, 	{"C6_LOCALIZ", 'VEICULO NOVO' , NIL } )
			
		Next nPos

    ENDIF

Return
