#Include 'Protheus.ch'
 
/*
=====================================================================================
Programa.:              IMPOSMNT
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              15/01/2020
Descricao / Objetivo:   Ponto de Entrada que permite inserir opções no relatórios 
Doc. Origem:            de O.S. a partir das rotinas supracitadas.
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              ACD
Obs......:
=====================================================================================
*/
User Function IMPOSMNT()
 
    Local aArea         := GetArea()
    Local aOptions      := {}
    Local nOpt          := 0
    Local oPnlPai       := Nil
    Local oDlgImp       := Nil
    //Local lVal          := ParamIXB[1]
    //Local cPla          := ParamIXB[2]
    //Local cPla2         := ParamIXB[3]
    Local aMatOs        := ParamIXB[4]
    Private cInQry      := ""
 
    Private nOpRe   := 1

    // MNTA990 - Programação OS
    If AllTrim( FunName() ) $ "MNTA265|MNTA990"
 
        Define MsDialog oDlgImp From 00,00 To 270,600 Title '[ P.E. - IMPOSMNT ] - Impressão da Ordem' Pixel
    
        oPnlPai := TPanel():New(00,00,,oDlgImp,,,,,,320,200,.F.,.F.)
        oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
    
        oGroup1  := TGroup():New( 005, 030, 095, 130, 'Opções', oPnlPai,,,.T.)
    
        aOptions := { 'Completa (CAOA)' }
    
        TRadMenu():New( 015, 035, aOptions, {|u| IIf( PCount() == 0, nOpRe, nOpRe := u )}, oPnlPai,,,,,,,, 60, 10,,,, .T.)
    
        Activate MsDialog oDlgImp On Init EnchoiceBar( oDlgImp, {|| nOpt := 1, oDlgImp:End() }, {|| oDlgImp:End() }) Centered
    
        If nOpt != 0
    
            fValRot( nOpRe, aMatOs )
            //fValRot(aMatOs)
    
        Endif
        RestArea(aArea)
    EndIf
Return
 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} fValRot
Valida chamada de Rotina
 
@author  Eduardo Mussi
@since   26/06/2018
@version P12
@param   lRot265, Lógico, Valida se chamada é feita pela Rotina MNTA265
/*/
//-------------------------------------------------------------------
Static Function fValRot(nOpRe, aMatOs)

    Local nX    := 0
    Default aMatOs := {}

    cInQry  := ""
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
    
Return()
