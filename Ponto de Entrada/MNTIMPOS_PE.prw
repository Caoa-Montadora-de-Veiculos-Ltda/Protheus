#Include 'Protheus.ch'
 
/*
=====================================================================================
Programa.:              MNTIMPOS
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              09/01/2020
Descricao / Objetivo:   Ponto de Entrada que permite inserir op��es no relat�rios 
Doc. Origem:            de O.S. a partir das rotinas supracitadas.
Solicitante:            CAOA - Montadora - An�polis
Uso......:              ACD
Obs......:
=====================================================================================
*/
User Function MNTIMPOS()
 
    Local aOptions      := {}
    Local nOpt          := 0
    Local oPnlPai       := Nil
    Local oDlgImp       := Nil
    Local lRot265       := cPrograma == 'MNTA265'
    Private cOrdemPE    := ""
    Private cInQry      := ""
 
    Private nOpRe   := 1

    // MNTA990 - Programa��o OS
    If AllTrim( FunName() ) $ "MNTA291|MNTA400|MNTA420|MNTA435|MNTA902"
 
        Define MsDialog oDlgImp From 00,00 To 270,600 Title '[ P.E. - MNTIMPOS ] - Impress�o da Ordem' Pixel
    
        oPnlPai := TPanel():New(00,00,,oDlgImp,,,,,,320,200,.F.,.F.)
        oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
    
        oGroup1  := TGroup():New( 005, 030, 095, 130, 'Op��es', oPnlPai,,,.T.)
    
        aOptions := { 'Completa (CAOA)' }
    
        TRadMenu():New( 015, 035, aOptions, {|u| IIf( PCount() == 0, nOpRe, nOpRe := u )}, oPnlPai,,,,,,,, 60, 10,,,, .T.)
    
        Activate MsDialog oDlgImp On Init EnchoiceBar( oDlgImp, {|| nOpt := 1, oDlgImp:End() }, {|| oDlgImp:End() }) Centered
    
        If nOpt != 0
    
            fValRot(lRot265)
    
        Endif
    EndIf
Return
 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} fValRot
Valida chamada de Rotina
 
@author  Eduardo Mussi
@since   26/06/2018
@version P12
@param   lRot265, L�gico, Valida se chamada � feita pela Rotina MNTA265
/*/
//-------------------------------------------------------------------
Static Function fValRot(lRot265)

    Local nX
    
    If lRot265

        cInQry  := ""
        aMatOs    := PARAMIXB[6]
        For nX := 1 To Len(aMatOs)
            If Empty(cInQry)
                cInQry := "'"+aMatOs[nX, 2]+"'"
            Else
                cInQry += ",'"+aMatOs[nX, 2]+"'"
            EndIf
        Next nX
        If !Empty(cInQry)
            U_ZMNTR001()
        EndIf
    Else
        
        // Executa fun��o de impress�o selecionada
        cOrdemPE := PARAMIXB[2]
        U_ZMNTR001() // Op��o Usu�rio
            
    EndIf
 
Return()