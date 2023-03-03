#INCLUDE 'PROTHEUS.CH'

/*
=====================================================================================
Programa.:              ZMNTF003
Autor....:              CAOA - Valter Carvalho
Data.....:              22/07/2020
Descricao / Objetivo:   Preencher o campo Descri��o e mantenedores ao mover a manuten��o das O.S. programadas. 
Doc. Origem:
Solicitante:            Julia Alcantara
Uso......:              mnta990.prx
===================================================================================== */

User Function ZMNTF003(cTbOsProg)

    Local aRet As Array
    Local nPos As Numeric
    Local cTB2 aS Character
    
    nPos  := 0
    cTB2  := cTbOsProg  //Carrega vari�veis de Entrada e Sa�da
    aRet  := {}

    // tratamento para se nao houver nenhuma ordem a programar
    If Type("aDscOrd") == "U" .OR. Type("aMntOrd") == "U"
        u_ZMNTF001()
    EndIf

    // parte da descri��o da O.S
    nPos := Ascan( aDscOrd, {|aIt| aIt[1] == (cTB2)->ORDEM} )
    If nPos > 0
        aadd(aRet, {"COMPDESC",aDscOrd[nPos, 2]})
    EndIf

    // mantenedores
    nPos := Ascan( aMntOrd, {|aIt| aIt[1] == (cTB2)->ORDEM} )
    If nPos > 0
        aadd(aRet, {"COMPMANU",aMntOrd[nPos, 2]})
    EndIf

Return(aRet)
