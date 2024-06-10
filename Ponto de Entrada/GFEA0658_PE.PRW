#Include "PROTHEUS.CH"
#Include "TOTVS.CH"

/*
==========================================================================
Programa...:    GFEA0658
Autor......:    CAOA - Fagner Barreto
Data.......:    20/05/2022
Descricao..:    Aciona a rotina de seleção de centro de custo por marca, 
quando a chamada for realizada pela rotina GFEA067 - Integrar Doc Frete
==========================================================================
*/
User Function GFEA0658()
	Local cRet      := ""

	If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
        /* A utilização deste PE foi necessaria porque a rotina GFEA067 não aciona o 
        modelo GFEA065 inviabilizando a utilização do PE MVC GFEA065_PE */
        If FWIsInCallStack("GFEA067") 	
            U_ZGFEF005()
        EndIf
    
        /* Este PE altera o centro de custo do CT-e nas integrações, então é obrigatorio
        gravar o retorno mesmo se a chamada não for do GFEA067 */
        cRet  := GW3->GW3_CC 
     EndIf

Return(cRet)
