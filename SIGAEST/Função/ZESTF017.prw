#Include "PROTHEUS.CH"
#include 'topconn.ch'
#INCLUDE "FWMVCDEF.CH"

/*
=====================================================================================
Programa.:              ZESTF017
Autor....:              Evandro Mariano
Data.....:              08/02/2024
Descricao / Objetivo:   Roda o Refaz Saldo
Doc. Origem:
Solicitante:            Montadora/Peças
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
User Function ZESTF017(_cMestre)

Local lErro := .F.

    If FWAlertYesNo( "Deseja rodar o Refaz Saldo para o mestre: " +AllTrim(_cMestre), 'ZESTF017' )
 
        DbSelectArea( "ZZI" )
        ZZI->( DbSetOrder( 1 ) )
        If ZZI->(DbSeek(xFilial("ZZI")+_cMestre))
            If ZZI->ZZI_STATUS $ "0|1|2|3"  //"0 | Não iniciado" - "1 | Quantidade Zeradas Incluidas - "2 | Contagem Importada"
                Processa( { || lErro := zProcSaldo() }, "Rodando o Refaz Saldo", "Aguarde ...." )
                If lErro == .F.
                    RecLock("ZZI", .F.)
                        ZZI->ZZI_STATUS := '3' //"3 | Refaz Saldo Processado"
                    ZZI->( MsUnlock())

                    FWAlertSuccess("Refaz Saldo processado com sucesso", "ZESTF017")
                Else
                    FWAlertError("Erro ao executar o Refaz Saldo, analise o erro e processe novamente", "ZESTF017")
                EndIf
            Else
                FWAlertError("Permitido Rodar Refaz Saldo somente com o Status 0|1|2|3 ", "ZESTF017")
            EndIf    

        Else         
            FWAlertError("Mestre não encontrado", "ZESTF017")
        EndIf
    EndIf

Return()

/*
=====================================================================================
Programa.:              ZESTF017
Autor....:              Evandro Mariano
Data.....:              08/02/2024
Descricao / Objetivo:   Roda o Refaz Saldo
Doc. Origem:
Solicitante:            Montadora/Peças
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
Static Function zProcSaldo()

Local cLocal    := ZZI->ZZI_LOCAL
Local cProdDe   := Iif(Empty(ZZI->ZZI_PRODUT),Space(23)             , ZZI->ZZI_PRODUT )
Local cProdAte  := Iif(Empty(ZZI->ZZI_PRODUT),Replicate("Z", 23)    , ZZI->ZZI_PRODUT ) 
Local lJob      := .T.
Private lMsErroAuto := .F.
Private cPerg   := PadR ("MTA300", Len (SX1->X1_GRUPO))

SetMVValue( cPerg, "MV_PAR01", cLocal)     //Armazém De
SetMVValue( cPerg, "MV_PAR02", cLocal)     //Armazém Até  
SetMVValue( cPerg, "MV_PAR03", cProdDe)    //Produto De
SetMVValue( cPerg, "MV_PAR04", cProdAte)   //Produto Até

//Executa a operação automática
lMsErroAuto := .F.
MSExecAuto({|x| MATA300(x)}, lJob)
 
//Se houve erro, salva um arquivo dentro da protheus data
If lMsErroAuto
    MostraErro()
EndIf

Return(lMsErroAuto)
