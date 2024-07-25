#Include "PROTHEUS.CH"
#Include "TOTVS.CH"
/*/{Protheus.doc} ZGFEF007
Calcular percentual específico
@author A.Carlos
@since 12/06/2023
@version 1.0
/*/
User Function ZGFEF007()

    Local nValor   := Paramixb[1]
    Local _MV_PERC := SUPERGETMV("CMV_GEN003",.T.,15)
    Local _MV_VLM  := SUPERGETMV("CMV_GEN004",.T.,31.32)
    Local nAux := 0
    IF Alltrim(Paramixb[2]) = 'FRT_PESO'

        _nQtdG := Paramixb[1]
        nValor := Paramixb[1]

    ENDIF

    IF Alltrim(Paramixb[2]) = 'TRT'
          
        nValor := (_nQtdG * _MV_PERC)/100   //Buscar o percentualna tabela GV1 GFEA050
        nAux   := nValor
        _nTRT  += nValor
        _nPasso++
        
        IF _nTRT <= _MV_VLM
            if _nPasso > 1
                nValor := 0
            Else 
                nValor := _MV_VLM
            EndIf
        else
            if  _nDif > 0 .and. (_nDif - _nTRT) < 0 .and. _nPasso > 1
                nValor := nValor - _nDif
            else
                nValor := nValor
            endif
        EndIf
        _nDif -= _nTRT

    ENDIF

Return(nValor)
