#Include "Protheus.ch"
/*
=====================================================================================
Programa.:              VX002FIN
Autor....:              Evandro Mariano
Data.....:              02/12/2020
Descricao / Objetivo:   Ponto de Entrada executado no final do atendimento Modelo 2
                        para envio da integração AutoWare
Doc. Origem:
Solicitante:            
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/

User Function VX002FIN()	

Local lInt := GetMv("CMV_VEI018",.F.,.T.) 

// Só executa quando é realizado pela Rotina VEIA060 - Pedido de Venda Montadora ( SigaVEI ).
// Dispara a integração do Autoware de forma automática.

If FWIsInCallStack("VEIA060") //Funname() == "VEIXA018"

    If VRJ->VRJ_XINTEG == "X" .And. !Empty( AllTrim( VRJ->VRJ_PEDCOM ) ) .And. lInt

        u_CMVAUT04(VRJ->VRJ_PEDIDO)

    EndIf

EndIf

Return()
