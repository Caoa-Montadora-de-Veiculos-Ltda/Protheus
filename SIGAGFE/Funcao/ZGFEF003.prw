#INCLUDE "PROTHEUS.CH"

/*
==============================================================================================
Programa.:              ZGFEF003
Autor....:              Sandro Ferreira
Data.....:              09/09/21
Descricao / Objetivo:   tipo de transporte que será utilizado (Rodoviário/Aéreo/Marítimo)
Doc. Origem:
Solicitante:            sigapec
Uso......:              CAOA Montadora de Veiculos
Obs......:              VX5->X5_TABELA  = M5 ( forma de transporte (Rodoviario/Aereo/Maritimo)
                        Alterado de PE OA011FIM para User Function ZGFEF003 porque o PE não era 
                        chamado ao faturar - Fagner 17/03/2022
===============================================================================================
*/
User Function ZGFEF003()
    Local aArea     := GetArea()
    Local aAreaGW1  := GW1->( GetArea() )

    //Verifica se o Orçamento está faturado
    If !Empty(VS1->VS1_NUMNFI) .AND. !Empty(VS1->VS1_SERNFI) .AND. VS1->VS1_STATUS = "X"

        //Verifica se criou documento de carga
        GW1->( dbSetOrder(11) )
        If GW1->( dbSeek(xFilial("GW1")+VS1->VS1_SERNFI + VS1->VS1_NUMNFI) )
            //Grava o campo forma de transporte (Rodoviario/Aereo/Maritimo)
            If  RecLock("GW1", .F.)
                GW1->GW1_XTPTRA := VS1->VS1_XTPTRA
                GW1->( MsUnLock() )
            EndIf
        Endif

    Endif	

    RestArea(aAreaGW1)
    RestArea(aArea)
    
Return
