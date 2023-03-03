/* =====================================================================================
Programa.:              IN100CLI
Autor....:              CAOA - Valter Carvalho
Data.....:              14/01/2020
Descricao / Objetivo:   P.E. de Manipulação da Integração dos arquivos SIGAEIC recebimento
Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              EICIN100  
Obs......:
===================================================================================== */

User Function IN100CLI()

    If FindFunction("U_ZEICF002")
        U_ZEICF002()
    Endif

Return
