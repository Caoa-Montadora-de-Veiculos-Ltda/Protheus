#INCLUDE 'PROTHEUS.CH'

/*
===============================================================================================
Programa.:              a240WMSO
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              22/08/22
Descricao / Objetivo:   Utilizado para passagem de endereço no processo de emprestimo backflush         
===============================================================================================
*/
User Function a240WMSO()
Local aEnder    := {}

    If FWIsInCallStack("U_ZPCPJ002") //--Executa somente se a chamada for do Backflush Caoa
        
        Do Case
            
            Case __cTm == '007'
                aEnder    := "DCE01" //--Doca de entrada

            Case __cTm == '556'
                aEnder    := "DCS01" //--Doca de saida
                
        EndCase
        
    EndIf

Return {aEnder}
