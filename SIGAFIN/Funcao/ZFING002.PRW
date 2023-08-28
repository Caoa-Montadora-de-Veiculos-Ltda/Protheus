#include "Protheus.ch"
#include 'parmtype.ch'
#include 'TOPCONN.CH'
#include "TBICONN.CH"
/*/{Protheus.doc} ZFING002
	Função p/ gatilhar o Tipo no Título RA
	@type 		function
	@author 	CAOA - A.Carlos
	@since 		04/07/2023
	@version 	1.0
	@return 	M->E1_TIPO
	@history 	
/*/
User Function ZFING002()

    Local _aArea := GetArea()
	Local _cEmp  := FWCodEmp()

    Private M->E1_TIPO  := ' '
    Private nMoedAdt    := 1
    Private cBancoAdt   := '237'
    Private cAgenciaAdt := '2372 '
    Private cNumCon     := '103476'

	If _cEmp == "2010" .AND. IsInCallStack("MATA410") .AND. INCLUI .AND. M->E1_PREFIXO = 'PVF' //.AND. SE4->E4_TIPO = '9'   //.AND. SE4->E4_CTRADT = '1'  //Executa o p.e. Anapolis.
         
        M->E1_TIPO := 'RA '

        FA040TIPO()

	EndIf

    RestArea(_aArea)

Return(M->E1_TIPO)
