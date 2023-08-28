#include "Protheus.ch"
#include 'parmtype.ch'
#include 'TOPCONN.CH'
#include "TBICONN.CH"
/*/{Protheus.doc} ZFING001
	Função p/ gatilhar a parcela no Título RA
	@type 		function
	@author 	CAOA - A.Carlos
	@since 		04/07/2023
	@version 	1.0
	@return 	M->E1_PARCELA
	@history 	
/*/
User Function ZFING001()

    Local _aArea := GetArea()
	Local _cEmp  := FWCodEmp()

    Private M->E1_PARCELA := ' '

	If _cEmp == "2010" .AND. IsInCallStack("MATA410") .AND. INCLUI .AND. M->E1_PREFIXO = 'PVF' //.AND. SE4->E4_TIPO = '9'  //.AND. SE4->E4_CTRADT = '1' //Executa o p.e. Anapolis.
         
        M->E1_PARCELA := '1'

	EndIf

    RestArea(_aArea)

Return(M->E1_PARCELA)
