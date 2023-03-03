#INCLUDE "PROTHEUS.CH"

/*
==============================================================================================
Programa.:              VX5TPTRA
Autor....:              Sandro Ferreira
Data.....:              08/10/21
Descricao / Objetivo:   tipo de transporte que será utilizado (Rodoviário/Aéreo/Marítimo)
Doc. Origem:
Solicitante:            sigapec
Uso......:              CAOA Montadora de Veiculos
Obs......:              VX5->X5_TABELA  = M5 ( forma de transporte (Rodoviario/Aereo/Maritimo)
===============================================================================================
*/
User Function VX5TPTRA()
    Local lRet    := ""
    Local cTabela := "Z01"
   
    dbSelectArea("VX5")
    If dbSeek(xFilial("VX5")+cTabela)
       While VX5->(!Eof()) .AND. VX5->VX5_FILIAL == XFilial("VX5") .AND. VX5->VX5_Chave == cTabela
            lRet := lRet + ALLTRIM(VX5->VX5_CODIGO) + " = " + Alltrim(VX5_Descri) +";"
            dbSkip()
       Enddo
    Endif
Return( lRet )
