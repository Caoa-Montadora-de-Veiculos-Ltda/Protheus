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
	Local _cEmp		:= FWCodEmp()

	If _cEmp == "2020" //Executa o p.e. Anapolis.
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
