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

    IF Alltrim(Paramixb[2]) = 'FRT_PESO'

        _nQtdG := Paramixb[1]
        nValor := Paramixb[1]

    ENDIF

    IF Alltrim(Paramixb[2]) = 'TRT'

        nValor := (_nQtdG*_MV_PERC)/100   //Buscar o percentualna tabela GV1

        IF nValor < _MV_VLM
            nValor := _MV_VLM
        ENDIF  

    ENDIF

Return(nValor)
