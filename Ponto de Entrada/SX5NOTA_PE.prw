#Include 'Protheus.ch'

/*/{Protheus.doc} User Function SX5NOTA
    (Ponto de entrada para filtrar a serie da nota fiscal.)
    @type Function
    @author Evandro Mariano
    @since 09/03/2022
/*/
User Function SX5NOTA(param_name)
    
Local _cChave   := Paramixb[3] //Chave da Tabela na SX5
Local _lRet     := .F.
Local _cSerie01 := Alltrim(SuperGetmv("ZCD_FAT001",.F.,"")) //Serie HYU (Barueri)
Local _cSerie02 := Alltrim(SuperGetmv("ZCD_FAT002",.F.,"")) //Serie Che (Barueri)
Local _cSerie03 := Alltrim(SuperGetmv("ZCD_FAT003",.F.,"")) //Serie SBR (Barueri)
Local _cSerie04 := Alltrim(SuperGetmv("ZCD_FAT004",.F.,"")) //Serie Nota Normal (Anhanguera)
Local _cSerie06 := Alltrim(SuperGetmv("ZCD_FAT006",.F.,"")) //Serie Nota Normal (Raposo)
Local _cSerie08 := Alltrim(SuperGetmv("ZCD_FAT008",.F.,"")) //Serie Nota Normal (SCS)


If ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Franco da Rocha | Caoa
    If AllTrim(FWFilial()) == "2001" //Barueri CD
        If FunName() $ "ZPECF013" //Filtrar somente quando for o MeuFatura
            If VS1->VS1_XMARCA $ "HYU"
                If Alltrim(_cChave) == AllTrim(_cSerie01)
                    _lRet := .T.
                EndIf
            ElseIf VS1->VS1_XMARCA $ "CHE"
                If Alltrim(_cChave) == AllTrim(_cSerie02)
                    _lRet := .T.
                EndIf
            ElseIf VS1->VS1_XMARCA $ "SBR"
                If Alltrim(_cChave) == AllTrim(_cSerie03)
                    _lRet  := .T.
                EndIf
            Endif
        Else
            _lRet  := .T.
        EndIf
    ElseIf AllTrim(FWFilial()) == "2010" //Anhanguera
        If Alltrim(_cChave) == AllTrim(_cSerie04)
            _lRet := .T.
        EndIf
    ElseIf AllTrim(FWFilial()) == "2020" //Raposo
        If Alltrim(_cChave) == AllTrim(_cSerie06)
            _lRet := .T.
        EndIf
    ElseIf AllTrim(FWFilial()) == "2030" //São Caetano do Sul
        If Alltrim(_cChave) == AllTrim(_cSerie08)
            _lRet := .T.
        EndIf
    Else
        _lRet := .T.
    EndIf
Else
    _lRet := .T.
EndIf
 
Return(_lRet)
