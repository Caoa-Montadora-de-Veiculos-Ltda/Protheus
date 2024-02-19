#Include "PROTHEUS.CH"
#include 'topconn.ch'
#INCLUDE "FWMVCDEF.CH"

/*
=====================================================================================
Programa.:              ZESTF016
Autor....:              Evandro Mariano
Data.....:              08/02/2024
Descricao / Objetivo:   Gera Zerado do SB7 por inventario
Doc. Origem:
Solicitante:            Montadora/Peças
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
User Function ZESTF016(_cMestre)

    If FWAlertYesNo( "Deseja incluir contagem zerada para o mestre: " +AllTrim(_cMestre), 'ZESTF017' )

        DbSelectArea( "ZZI" )
        ZZI->( DbSetOrder( 1 ) )
        If ZZI->(DbSeek(xFilial("ZZI")+_cMestre))
            If ZZI->ZZI_STATUS $ "0|1|2" 
                Processa( { || zGeraSB7() }, "Incluindo contagem zerada", "Aguarde ...." )
                FWAlertSuccess("Quantidade Zerada incluida com Sucesso", "ZESTF016")
            Else
                FWAlertError("Permitido incluir contagem somente com o Status 0|1|2", "ZESTF016")
            EndIf    

        Else         
            FWAlertError("Mestre não encontrado", "ZESTF016")
        EndIf
    EndIf
Return


/*
=====================================================================================
Programa.:              zGeraSB7
Autor....:              Evandro Mariano
Data.....:              08/02/2024
Descricao / Objetivo:   Gera Zerado do SB7 por inventario
Doc. Origem:
Solicitante:            Montadora/Peças
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
Static Function zGeraSB7()
    Local cQrySB2		:= ""
    Local cAliasSB2		:= GetNextAlias()
    Local _nAtual       := 0
    Local _nTotal       := 0
    Local cErro         := "########## Erros ##########" + CRLF
      
    If Select( (cAliasSB2) ) > 0
        (cAliasSB2)->(DbCloseArea())
    EndIf

    cQrySB2 := " "
    cQrySB2 += " SELECT B2_COD, B2_LOCAL "                      + CRLF
    cQrySB2 += " FROM " + RetSQLName('SB2') + " "               + CRLF
    cQrySB2 += " WHERE D_E_L_E_T_ = ' ' "                       + CRLF
    cQrySB2 += " AND B2_LOCAL = '" + ZZI->ZZI_LOCAL + "' "      + CRLF
    If !Empty(ZZI->ZZI_PRODUT)
        cQrySB2 += " AND B2_COD = '" + ZZI->ZZI_PRODUT + "' "   + CRLF
    EndIf
    cQrySB2 += " ORDER BY B2_COD "                              + CRLF

    // Executa a consulta.
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQrySB2), cAliasSB2, .T., .T. )

    //Conta quantos registros existem, e seta no tamanho da régua
    Count To _nTotal
    ProcRegua(_nTotal)

    DbSelectArea((cAliasSB2))
    (cAliasSB2)->(dbGoTop())
    While !(cAliasSB2)->(Eof())
    
        _nAtual++
        IncProc("Incluindo: " + cValToChar(_nAtual) + " de " + cValToChar(_nTotal) + "...")
        
        SB1->(dbSetOrder(1))
        If SB1->(dbSeek(xFilial("SB1")+Padr( AllTrim((cAliasSB2)->B2_COD), TamSX3("B1_COD")[1] )))

            If SB1->B1_MSBLQL == "2" //Não pode estar bloqueado

                SB7->(dbSetOrder(3))
	            If !(SB7->(dbSeek(xFilial("SB7")+Padr( ZZI->ZZI_MESTRE, TamSX3("B7_DOC")[1] ) + Padr( (cAliasSB2)->B2_COD, TamSX3("B7_COD")[1] ) + Padr( (cAliasSB2)->B2_LOCAL, TamSX3("B7_LOCAL")[1] ))))

                    RecLock("SB7", .T.)
                        SB7->B7_FILIAL  := xFilial("SB7") 
                        SB7->B7_COD     := (cAliasSB2)->B2_COD
                        SB7->B7_LOCAL   := (cAliasSB2)->B2_LOCAL
                        SB7->B7_TIPO    := SB1->B1_TIPO
                        SB7->B7_DOC     := ZZI->ZZI_MESTRE
                        SB7->B7_QUANT   := 0
                        SB7->B7_DATA    := ZZI->ZZI_DATA
                        //SB7->B7_LOTECTL := Padr( aDados[04], TamSX3("B7_LOTECTL")[1] )
                        //SB7->B7_NUMLOTE := Padr( aDados[05], TamSX3("B7_NUMLOTE")[1] )
                        //SB7->B7_LOCALIZ := Padr( aDados[06], TamSX3("B7_LOCALIZ")[1] )
                        //SB7->B7_NUMSERI := Padr( aDados[07], TamSX3("B7_NUMSERI")[1] )
                        SB7->B7_CONTAGE := "001"
                        SB7->B7_STATUS  := "1"
                        SB7->B7_ORIGEM  := "MATA270"
                    SB7->(MsUnlock())
                Else
                    cErro += CRLF + "Produto: " + AllTrim((cAliasSB2)->B2_COD)+ " já possui contagem, não pode gerar zerado."
                EndIf
            Else
                cErro += CRLF + "Produto: " + AllTrim((cAliasSB2)->B2_COD)+ " esta bloqueado no Cadastro de Produto."
            EndIf
        Else
            cErro += CRLF + "Produto: " + AllTrim((cAliasSB2)->B2_COD)+ " não esta cadastrado."
        EndIf
    
        (cAliasSB2)->(DbSkip())
    EndDo
    (cAliasSB2)->(DbCloseArea())

    RecLock("ZZI", .F.)
        ZZI->ZZI_STATUS := '1' //"1 | Quantidade Zeradas Incluidas"
    ZZI->( MsUnlock() )

    EecView("CAOA | Geração do Zerado" + CRLF + cErro, "ZESTF016")

Return() 
