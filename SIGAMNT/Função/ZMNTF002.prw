#Include 'TopConn.ch'

/*
=====================================================================================
Programa.:              ZMNTF002
Autor....:              CAOA - Valter Carvalho
Data.....:              22/07/2020
Descricao / Objetivo:   Criar as coluns personalizadas da tela de programação de o.s. 
Doc. Origem:
Solicitante:            Julia Alcantara
Uso......:              mnta990.prx
===================================================================================== */
User Function ZMNTF002(ParamIXB)
    Local nPosDesc  := 0
    Local aTrb1     := {}
    Local aDbf1     := {}
    Local aTrb2     := {}
    Local aDbf2     := {}
    Local aCpoCompl := ParamIXB[5]
    Local nLenCp    := 100

    // adicionar o campo na  GRID1
    nPosDesc :=  Ascan(ParamIXB[1], {|aIt| aIt[1] == "DESCRIC"}) + 1

    aTrb1 := aClone(ParamIXB[1])

    Asize(aTrb1, Len(aTrb1) + 2)

    Ains(aTrb1, nPosDesc)
    Ains(aTrb1, nPosDesc + 1)

    aTrb1[nPosDesc]     := {"COMPDESC", nil, "Descrição da manutenção"  , nil}
    aTrb1[nPosDesc+1]   := {"COMPMANU", nil, "Mantenedor"               , nil}


    // adicionar o campo na TABELA1
    nPosDesc :=  Ascan(ParamIXB[2], {|aIt| aIt[1] == "DESCRIC"}) + 1

    aDbf1 := Aclone(ParamIXB[2])

    Asize(aDbf1, Len(aDbf1) + 2)

    Ains(aDbf1, nPosDesc)
    Ains(aDbf1, nPosDesc + 1)

    aDbf1[nPosDesc]     := {"COMPDESC", "C", 100, 0}
    aDbf1[nPosDesc + 1] := {"COMPMANU", "C", nLenCp, 0}



    // adicionar o campo na  GRID2
    nPosDesc :=  Ascan(ParamIXB[3], {|aIt| aIt[1] == "DESCRIC"}) + 1

    aTrb2 := aClone(ParamIXB[3])

    Asize(aTrb2, Len(aTrb2) + 2)

    Ains(aTrb2, nPosDesc)
    Ains(aTrb2, nPosDesc + 1)

    aTrb2[nPosDesc]      := {"COMPDESC", nil, "Descrição da manutenção" , nil}
    aTrb2[nPosDesc + 1 ] := {"COMPMANU", nil, "Mantenedor"              , nil}



    // adicionar o campo na TABELA2
    nPosDesc :=  Ascan(ParamIXB[4], {|aIt| aIt[1] == "DESCRIC"}) + 1

    aDbf2 := Aclone(ParamIXB[4])

    Asize(aDbf2, Len(aDbf2) + 2)

    Ains(aDbf2, nPosDesc)
    Ains(aDbf2, nPosDesc + 1)

    aDbf2[nPosDesc]     := {"COMPDESC", "C", 100, 0}
    aDbf2[nPosDesc + 1] := {"COMPMANU", "C", nLenCp, 0}


    //efetue a limpeza das vaiaveis publicas da descrição da ordem e dos mantenedores
    if Type("aDscOrd") == "A"  // descricao da ordem
        If Len(aDscOrd) <> 0
            aDscOrd := {}
        EndIf
    EndIf
    if Type("aMntOrd") == "A" // lista dos mantenedores
        If Len(aMntOrd) <> 0
            aMntOrd := {}
        EndIf
    EndIf
    
Return {aTrb1, aTrb2, aDbf1, aDbf2, aCpoCompl}





