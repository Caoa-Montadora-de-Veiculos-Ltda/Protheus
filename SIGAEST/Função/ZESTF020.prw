#Include "PROTHEUS.CH"
#include 'topconn.ch'
#INCLUDE "FWMVCDEF.CH"

/*
=====================================================================================
Programa.:              ZESTF020
Autor....:              Evandro Mariano
Data.....:              Importação Contagem
Doc. Origem:
Solicitante:            Montadora/Peças
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
User Function ZESTF020(cFileOpen,_cMestre)

    DbSelectArea( "ZZI" )
    ZZI->( DbSetOrder( 1 ) )
    If ZZI->(DbSeek(xFilial("ZZI")+_cMestre))
        If ZZI->ZZI_STATUS $ "0|1|2|3" 
            Processa( { || zProcCSV(cFileOpen) }, "Realizando a importação da planilha de inventario", "Aguarde ...." )
            FWAlertSuccess("Importação Feita com sucesso", "ZESTF020")
        Else
            FWAlertError("Permitido Importação da contahem somente com o Status 0|1|2|3 ", "ZESTF020")
        EndIf    

    Else         
        FWAlertError("Mestre não encontrado", "ZESTF020")
    EndIf

Return

/*
=====================================================================================
Programa.:              zProcImportacao
Autor....:              Evandro Mariano
Data.....:              Importação Contagem
Doc. Origem:
Solicitante:            Montadora/Peças
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
Static Function zProcCSV(cFileOpen)

    Local cLinha        := ""
    Local cSeparador	:= ";"
    Local aDados 		:= {}
    Local lGravou       := .F.
    Local cErro         := "########## Erros ##########" + CRLF    

    FT_FUSE(cFileOpen)
    FT_FGOTOP()
    FT_FSKIP()

    DbSelectArea( "SB1" )
    DbSelectArea( "SB7" )

    ProcRegua( FT_FLASTREC() )

        While !FT_FEOF()

            cLinha := FT_FREADLN()
                            
            aDados := Separa(cLinha,cSeparador)

            // Incrementa a mensagem na régua.
            IncProc("Efetuando a gravação dos registros!")

            SB1->(dbSetOrder(1))
	        If SB1->(dbSeek(xFilial("SB1")+Padr( aDados[1], TamSX3("B1_COD")[1] )))

                If SB1->B1_MSBLQL == "2" //Não pode estar bloqueado

                    SB7->(dbSetOrder(3))
                    If !(SB7->(dbSeek(xFilial("SB7")+Padr( ZZI->ZZI_MESTRE, TamSX3("B7_DOC")[1] ) + Padr( aDados[1], TamSX3("B7_COD")[1] ) + Padr( ZZI->ZZI_LOCAL, TamSX3("B7_LOCAL")[1] ))))

                        RecLock("SB7", .T.)
                            SB7->B7_FILIAL  := xFilial("SB7") 
                            SB7->B7_COD     := Padr( aDados[01], TamSX3("B7_COD")[1] )
                            SB7->B7_LOCAL   := ZZI->ZZI_LOCAL
                            SB7->B7_TIPO    := SB1->B1_TIPO
                            SB7->B7_DOC     := ZZI->ZZI_MESTRE
                            SB7->B7_QUANT   := Val(StrTran(aDados[02],",","."))
                            SB7->B7_DATA    :=ZZI->ZZI_DATA
                            //SB7->B7_LOTECTL := Padr( aDados[04], TamSX3("B7_LOTECTL")[1] )
                            //SB7->B7_NUMLOTE := Padr( aDados[05], TamSX3("B7_NUMLOTE")[1] )
                            //SB7->B7_LOCALIZ := Padr( aDados[06], TamSX3("B7_LOCALIZ")[1] )
                            //SB7->B7_NUMSERI := Padr( aDados[07], TamSX3("B7_NUMSERI")[1] )
                            SB7->B7_CONTAGE := "001"
                            SB7->B7_STATUS  := "1"
                            SB7->B7_ORIGEM  := "MATA270"
                        SB7->(MsUnlock())

                        lGravou := .T.
                    Else
                        RecLock("SB7", .F.)
                            SB7->B7_QUANT   := Val(StrTran(aDados[02],",","."))
                            SB7->B7_CONTAGE := StrZero( Val( SB7->B7_CONTAGE ) + 1 , 3)
                        SB7->(MsUnlock())
                        
                        lGravou := .T.
                    EndIf
                Else
                    cErro += CRLF + "Produto: " + AllTrim(aDados[01])+ " esta bloqueado no Cadastro de Produto."
                EndIf
            Else
                 cErro += CRLF + "Produto: " + AllTrim(AllTrim(aDados[01]))+ " não esta cadastrado."
            EndIf
                       
            FT_FSKIP(1)
        
        END

    //--Fecha arquivo
    FT_FUSE()

    If lGravou
        RecLock("ZZI", .F.)
            ZZI->ZZI_STATUS := '2' //"2 | Contagem Importada"
        ZZI->( MsUnlock() )
    EndIf

    EecView("CAOA | Importação Contagem" + CRLF + cErro, "ZESTF020")
Return
