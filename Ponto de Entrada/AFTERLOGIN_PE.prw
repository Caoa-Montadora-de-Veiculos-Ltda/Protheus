#include "protheus.ch"

/*
=====================================================================================
Programa.: AfterLogin
Autor....: CAOA - Evandro A Mariano dos Santos
Data.....: 20/08/19
Descricao / Objetivo: Ponto de Entrada para adicionar relatorio personalizado.
                        da Ordem de Serviço.
Doc. Origem:
Solicitante: Compras
Uso......: Caoa Montadora de Veiculos
Obs......:
=====================================================================================
*/
 
User Function AfterLogin()

//Local cId	        := ParamIXB[1]
//Local cNome         := ParamIXB[2]

	If !( IsBlind() ) //interface com o usuário

        /*If FwCodEmp() == "2020" //GRUPO BARUERI

            If ( "_PRD" $ AllTrim(GetEnvServer()) .And. !( "SP" $ AllTrim(GetEnvServer()) ) )

                Final("Grupo Barueri acessar o ambiente ABDHDU_PRD_CAOASP")

            EndIf
            
        ElseIf FwCodEmp() == "2010" //GRUPO MONTADORA

            If ( "_PRD" $ AllTrim(GetEnvServer()) .And. "SP" $ AllTrim(GetEnvServer()) ) 
                
                Final("Grupo Montadora acessar o ambiente ABDHDU_PRD")

            EndIf

        EndIf*/
        
        SetKey( K_SH_F2, {|| u_ZCFGF002() } )
        SetKey( K_SH_F3, {|| u_ZCFGF005() } )
            
    EndIf
     
Return()
