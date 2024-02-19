#include 'protheus.ch'

/*
=====================================================================================
Programa.:              ZESTF015
Autor....:              Evandro Mariano
Data.....:              08/02/2024
Descricao / Objetivo:   Gerenciamento Inventario.
Doc. Origem:
Solicitante:            Montadora/Peças
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
User Function ZESTF015(_cMestre, _cLocal, _dData, _cProduto) 

    Local cTitulo1  := "Selecione o arquivo para Carga "
    Local cExtens   := "Arquivo CSV | *.CSV"
    Local cMainPath := "C:\"
    Local cFileOpen := ""
    Local aPergs    := {}
    Local _aCombo   := {"Gerar Contagem Zerada","Importar Contagem (SB7)","Rodar Refaz Saldo","Limpar Empenho/Reserva","Bloquear Estoque","Rodar Acerto de Inventario","Desbloquear Estoque"}    
    Private aRetP   := {}

    aAdd(aPergs,    {2, "Gestão Inventario | Caoa Pecas" , "SIM"  , _aCombo    ,     100, ".T.", .F.})
        
    If ParamBox(aPergs, "Gestão Inventario | Caoa Pecas", aRetP, , , , , , , , ,.T.) 
        
            If aRetP[1] == "Gerar Contagem Zerada"
                
                u_ZESTF016(_cMestre)
            
            ElseIf aRetP[1] == "Importar Contagem (SB7)"
    
                If FWAlertYesNo( "Deseja importar a contagem para o mestre: " +AllTrim(_cMestre), 'ZESTF015' )
                    cFileOpen := cGetFile(cExtens,cTitulo1,0,cMainPath,.T.,,.F.)
                    If File(cFileOpen)
                        u_ZESTF020(cFileOpen,_cMestre)
                    ENDIF
                EndIf

            ElseIf aRetP[1] == "Rodar Refaz Saldo"
    
                u_ZESTF017(_cMestre)
            
            ElseIf aRetP[1] == "Limpar Empenho/Reserva"
    
                 u_ZESTF018(_cMestre)
                                
            ElseIf aRetP[1] == "Bloquear Estoque"
    
                u_ZESTF019(_cMestre, "1")

            ElseIf aRetP[1] == "Rodar Acerto de Inventario"
    
                Processa( { || MATA340() }, "Acerto de inventario", "Aguarde .... Realizando o acerto de inventário...." )
                ApMsgInfo("Acerto de Estoque Finalizado!")

            ElseIf aRetP[1] == "Desbloquear Estoque"
    
                u_ZESTF019(_cMestre, "2")

            EndIf
    EndIf
Return()
