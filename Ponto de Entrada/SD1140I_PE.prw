#Include "Totvs.ch"
#Include "Protheus.ch"

/*
=======================================================================================
Programa.:              SD1140I
Autor....:              TOTVS - Reinaldo Rabelo da Silva
Data.....:              07/12/23
Descricao / Objetivo:   Ponto de Entrada após a Inclusão da SD1 na Pré-Nota de Entrada
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=======================================================================================
*/

User Function SD1140I()

If Findfunction("U_fValiNUmSeq")
    U_fValiNUmSeq()
EndIf

Return nil

/*
=======================================================================================
Programa.:              fValiNUmSeq
Autor....:              TOTVS - Reinaldo Rabelo da Silva
Data.....:              07/12/23
Descricao / Objetivo:   Rotina Para prevenir a Duplicação da D1_NUMSEQ
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:              Chamado pelos Pontos de Entradas SD1140I e SD1100I
=======================================================================================
*/

User Function fValiNUmSeq()

Local aArea := GetArea()
Local aAreaSD1 := SD1->(GetArea())
Local aAreaD0Q := D0Q->(GetArea())

if Type('cValNumSeq') <> "C"
    Public cValNumSeq := ""
EndIF

//Verifica se existe Numero de Sequencia Dulpicado
If SD1->D1_NUMSEQ $ cValNumSeq
    //Caso existe Duplicado pega um numero novo para o registro
    SD1->D1_NUMSEQ := ProxNum()
    
    DBSELECTAREA('D0Q')
    DbSetOrder(1)
    
    //Verifico se existe Demanda do Unitizador para acertar o NUMSEQ também
    If D0Q->(DBSEEK(XfILIAL('D0Q') + SD1->D1_SERVIC + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA ))
                
        While D0Q->(!EOF()) .and. ;
            SD1->D1_FILIAL  == D0Q->D0Q_FILIAL .AND. SD1->D1_SERVIC == D0Q->D0Q_SERVIC .AND.;
            SD1->D1_DOC     == D0Q->D0Q_DOCTO  .AND. SD1->D1_SERIE  == D0Q->D0Q_SERIE  .AND. ;
            SD1->D1_FORNECE == D0Q->D0Q_CLIFOR .AND. SD1->D1_LOJA   == D0Q->D0Q_LOJA
            
            //Atualiza a D0Q_NUMSEQ a Tabela de Demanda com o D1_NUMSEQ atualizado
            If D0Q->D0Q_ID == SD1->D1_IDDCF
                D0Q->D0Q_NUMSEQ := SD1->D1_NUMSEQ
                EXIT
            EndIf
        
            D0Q->(DbSkip())
        EndDo

        RestArea(aAreaD0Q)
    EndIf

EndIf

//Guardo os NUMSEQ utilizado para validar o Proximo NUMSEQ.
cValNumSeq += SD1->D1_NUMSEQ + "|"

RestArea(aAreaSD1)
RestArea(aArea)

Return
