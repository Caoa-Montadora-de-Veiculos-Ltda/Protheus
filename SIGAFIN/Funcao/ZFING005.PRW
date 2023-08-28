#include "Protheus.ch"
#include 'parmtype.ch'
#include 'TOPCONN.CH'
#include "TBICONN.CH"
/*/{Protheus.doc} ZFING005
	Função p/ gatilhar a LOJA no Título RA
	@type 		function
	@author 	CAOA - A.Carlos
	@since 		04/07/2023
	@version 	1.0
	@return 	M->E1_LOJA
	@history 	
/*/
User Function ZFING005()

    Local _aArea := GetArea()
	Local _cEmp  := FWCodEmp()

    Private M->E1_LOJA    := ''

	If _cEmp == "2010" .AND. IsInCallStack("MATA410") .AND. INCLUI .AND. M->E1_PREFIXO = 'PVF' //.AND. SE4->E4_TIPO = '9'  //.AND. SE4->E4_CTRADT = '1'  //Executa o p.e. Anapolis.
         
        DBSELECTAREA('ZZM')	// Cadastro PV
        ZZM->(DbSetOrder(1))
        DbSeek(xFilial("ZZM")+ALLTRIM(M->E1_NUM))
        M->E1_LOJA     := ZZM->ZZM_LOJA
		M->E1_XFORMA   := SE4->E4_XFORMA

	EndIf

    RestArea(_aArea)

Return(M->E1_LOJA)
