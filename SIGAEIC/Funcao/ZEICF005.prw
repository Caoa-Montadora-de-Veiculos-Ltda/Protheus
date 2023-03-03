#INCLUDE 'PROTHEUS.CH'

/*
=====================================================================================
Programa.:              EICOR100
Autor....:              CAOA - Valter Carvalho
Data.....:              17/03/2020
Descricao / Objetivo:   Efetua ajustes no conteúdo do arquivo Envio de P.O.
Doc. Origem:
Solicitante:            Evandro Mariano
Uso......:              EICPOR01          
=====================================================================================*/
User Function ZEICF005()

    Begin Sequence

        ConOut(" EICPOR01, ZEICF005->" + ParamIxb)

        Do Case

        Case ParamIxb $ "AG4B"
 
            cTexto := Stuff(cTexto, 156, 180, PadR(SA2->A2_MUN, 025,""))
            cTexto := Stuff(cTexto, 030, 054, PadR(SA2->A2_EST, 025,""))

        EndCase

    End Sequence

Return

