#Include "PROTHEUS.CH"
#Include "TOTVS.CH"

/*
==========================================================================
Programa...:    GFEA0658
Autor......:    CAOA - Fagner Barreto
Data.......:    20/05/2022
Descricao..:    Aciona a rotina de sele��o de centro de custo por marca, 
quando a chamada for realizada pela rotina GFEA067 - Integrar Doc Frete
==========================================================================
*/
User Function GFEA0658()
	Local cRet      := ""
	Local _cEmp		:= FWCodEmp()

	If _cEmp == "2020" //Executa o p.e. Anapolis.
        /* A utiliza��o deste PE foi necessaria porque a rotina GFEA067 n�o aciona o 
        modelo GFEA065 inviabilizando a utiliza��o do PE MVC GFEA065_PE */
        If FWIsInCallStack("GFEA067") 	
            U_ZGFEF005()
        EndIf
    
        /* Este PE altera o centro de custo do CT-e nas integra��es, ent�o � obrigatorio
        gravar o retorno mesmo se a chamada n�o for do GFEA067 */
        cRet  := GW3->GW3_CC 
     EndIf

Return(cRet)
