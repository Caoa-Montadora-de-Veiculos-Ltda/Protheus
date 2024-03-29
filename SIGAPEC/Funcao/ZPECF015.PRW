#include "totvs.ch"
#include "protheus.ch"

/*
=====================================================================================
Programa.:              ZPECF015
Autor....:              CAOA - Fagner Barreto
Data.....:              21/02/2021
Descricao / Objetivo:   Chamada via schedule das rotinas de integra��o de produto,
                        cliente e fornecedor para a RGLOG
=====================================================================================
*/
User function ZPECF015()

Conout("ZPECF015 - Schedule de envio de cadastros para RGLOG - Inicio "+DtoC(date())+" "+Time())

//--Chamada de integra��o de fornecedores
U_ZWSR014()

//--Chamada de integra��o de clientes
U_ZWSR006("C")

//--Chamada de integra��o de Produtos
U_ZWSR004()

Conout("ZPECF015 - Schedule de envio de cadastros para RGLOG - Final "+DtoC(date())+" "+Time())

Return

/*
=====================================================================================
Programa.:              Scheddef
Autor....:              CAOA - Fagner Barreto
Data.....:              16/02/2021
Descricao / Objetivo:   Fun��o padr�o para habilitar perguntes e inicializar
                        empresa diretamente pela rotina de schedule
=====================================================================================
*/
Static Function Scheddef()
    Local aParam
    Local aOrd   := {}

    aParam := { "P",;
                "PARAMDEF",; //Usado quando n�o ha pergunte
                "",;
                aOrd,;
              }

Return aParam
