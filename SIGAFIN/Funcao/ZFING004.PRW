#include "Protheus.ch"
#include 'parmtype.ch'
#include 'TOPCONN.CH'
#include "TBICONN.CH"
/*/{Protheus.doc} ZFING004
	Função p/ gatilhar o CLIENTE no Título RA
	@type 		function
	@author 	CAOA - A.Carlos
	@since 		04/07/2023
	@version 	1.0
	@return 	M->E1_CLIENTE
	@history 	
/*/
User Function ZFING004()

    Local _aArea := GetArea()
	Local _cEmp  := FWCodEmp()

    Private M->E1_CLIENTE := ' '

	If _cEmp == "2010" .AND. IsInCallStack("MATA410") .AND. INCLUI .AND. M->E1_PREFIXO = 'PVF' //.AND. SE4->E4_TIPO = '9'   //.AND. SE4->E4_CTRADT = '1'  //Executa o p.e. Anapolis.

        DBSELECTAREA('ZZM')	// Cadastro PV
        ZZM->(DbSetOrder(1))
        DbSeek(xFilial("ZZM")+ALLTRIM(M->E1_NUM))
        M->E1_CLIENTE  := ZZM->ZZM_CLIENTE

        DBSELECTAREA('SA1')	// Cadastro Cliente
        SA1->(DbSetOrder(1))
        DbSeek(xFilial("SA1")+ZZM->ZZM_CLIENTE+ZZM->ZZM_LOJA)
        M->E1_NOMCLI   := SA1->A1_NOME

	EndIf

    RestArea(_aArea)

Return(M->E1_CLIENTE)
