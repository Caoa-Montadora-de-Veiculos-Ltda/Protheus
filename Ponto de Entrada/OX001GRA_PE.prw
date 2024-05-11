#include "Protheus.ch"
#include "TOTVS.ch"

/*/{Protheus.doc} OX001GRA
@param  	
@author 	DAC
@version  	
@since      19/02/2024 	
@return  	NIL
@obs        Ponto de entrada REFERENTE A GRAVAÇÃO vs1
@project    GAP125  Adicionar campos na observação de aglutinação
@history    
*/
User Function OX001GRA()
Local _cEmp    := FWCodEmp()

    If _cEmp == "2010" //Anapolis.
        Return .T.
    ElseIf M->VS1_STATUS == "0" .And. ALTERA
        OX001GRAObs()  //Verificar se existem alterações e preparar para gravação na OBS

    Endif
Return .t.


/*/{Protheus.doc} OX001GRAObs
@param  	
@author 	DAC
@version  	
@since      19/02/2024 	
@return  	NIL
@obs        Verificar se existem alterações e preparar para gravação na OBS
@project    GAP125  Adicionar campos na observação de aglutinação
@history    Verificar se existem alterações e preparar para gravação na OBS
            por gentileza, acrescentar no campo Obs Aglutina, as informações de alteração dos campos abaixo:
*/
Static Function OX001GRAObs()  
Local _cObs     := ""
Local _aAvalia  := {}
Local _nPos
Local _nPosCpo
Local _cVar1
Local _cVar2
Local _cAlias 
    //Caso não tenha o campo de obsrvação
    If VS1->(FieldPos("VS1_OBSAGL")) <= 0
        Return Nil
    Endif 
    //Campos a serem avaliados
    Aadd(_aAvalia,{"VS1","VS1_XTPPED"})
    Aadd(_aAvalia,{"VS1","VS1_XTPTRA"})
    Aadd(_aAvalia,{"VS1","VS1_FORPAG"})
    Aadd(_aAvalia,{"VS1","VS1_PERPEC"})
    Aadd(_aAvalia,{"VS1","VS1_PERDES"})
    Aadd(_aAvalia,{"VS1","VS1_NATURE"})
    Aadd(_aAvalia,{"VS1","VS1_TRANSP"})
    Aadd(_aAvalia,{"VS1","VS1_VALFRE"})
    Aadd(_aAvalia,{"VS1","VS1_PGTFRE"})

    For _nPos := 1 To Len(_aAvalia)
        _cAlias     := _aAvalia[_nPos,1]
        _nPosCpo    := (_cAlias)->(FieldPos(_aAvalia[_nPos,2]))
        If _nPosCpo > 0
            If (_cAlias)->(FieldGet(_nPosCpo)) <> &(M->(_aAvalia[_nPos,2]))
                _cVar1 := (_cAlias)->(FieldGet(_nPosCpo))
                _cVar2 := &(M->(_aAvalia[_nPos,2]))
                If ValType(_cVar1) == "N"
                    _cVar1 := AllTrim(Str(_cVar1))
                    _cVar2 := AllTrim(Str(_cVar2))
                ElseIf ValType(_cVar1) == "D"
                    _cVar1 := DtoC(_cVar1)
                    _cVar2 := DtoC(_cVar2)
                ElseIf ValType(_cVar1) == "L"
                    _cVar1 := If(_cVar1,"Verdeiro","Falso")
                    _cVar2 := If(_cVar2,"Verdeiro","Falso")
                Else
                    _cVar1 := AllTrim(_cVar1)
                    _cVar2 := AllTrim(_cVar2)
                Endif
                _cObs += "CAMPO "+RetTitle(_aAvalia[_nPos,2])+ " ALTERADO DE "+_cVar1+ " PARA "+_cVar2  + CRLF
            Endif
        Endif
    Next
    If Len(_cObs) > 0
        //Gravar data alteração e Uusuário
        _cObs += "ALTERADO USUARIO : "+Upper(AllTrim(UsrRetName(RetCodUsr())))+" EM "+DtoC(Date())+" AS "+SubsTr(Time(),1,5)+ CRLF
        M->VS1_OBSAGL := _cObs +CRLF+ M->VS1_OBSAGL
    Endif
Return Nil 


