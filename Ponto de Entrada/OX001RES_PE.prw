#include "protheus.ch"
#include "tbiconn.ch"

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} CRIASDBD
Ponto de Entrada para calculo da reserva função OX001RESITE desvio para calcular reserva.
@type User Function
@author DAC Denilso 
@since 19/08/2022
@version 
/*/
//+----------------------------------------------------------------------------------------

User Function OX001RES
Local _aArea        := GetArea()
Local _aRegVS3      := {}
Local _cDocto       := ""
//Local _cArmazem     := "01"
Local _lTela        := .F.
Local _cNumOrc      
Local _lReserva     
Local _cOrigem     
Local _cDestino    

Begin Sequence
    If Type("_aReservaCAOA") <> "A" .or. Len(_aReservaCAOA) == 0
        Break
    EndIf    
    If Len(_aReservaCAOA) > 0
        _cNumOrc    := _aReservaCAOA[1]
        _lReserva   := _aReservaCAOA[2]
        If Len(_aReservaCAOA) > 2
            _aRegVS3 := _aReservaCAOA[3]
        Endif 
        If Len(_aReservaCAOA) > 3
            _cOrigem := _aReservaCAOA[4]
        Endif 
        If Len(_aReservaCAOA) > 4
            _cDestino := _aReservaCAOA[5]
        Endif 
        If Len(_aReservaCAOA) > 5
            _lTela := _aReservaCAOA[6]
        Endif 
    /*
    //Caso não seja enviado a matriz com dados para a reserva deverá ser realizado validações para verificar o tipo de reserva, isto se deve pelo motivo do PE não tr parâmetros    
    //pode ser avalidado realizar todas as reservas por aqui caso não tenha sido chamado pela validação CAOA  poderá utilizar o else mas tem que estar posicionado no VS1
    Else
        _cNumOrc        := VS1->VS1_NUMORC
        If VS1->VS1_STARES  == "3"  //Não reservado
            _lReserva   := .T.  //inclui reserva
            _cOrigem    := _cArmazem
            _cDestino     := AllTrim(GETMV("MV_RESITE"))
        ElseIf VS1->VS1_STARES  == "1"  //Reservado    
            _lReserva   := .F.  //Retira reserva
            _cOrigem    := AllTrim(GETMV("MV_RESITE"))
            _cDestino   := _cArmazem
        ElseIf VS1->VS1_STARES  == "2"  //PARCIAL    
            Break
            //Inicialmente deixar fazer o processo antigo
        EndIf
    */    
    EndIf
  
    _cDocto := U_XRESCAOAPEC(_cNumOrc, _lReserva, _aRegVS3, _cOrigem, _cDestino, _lTela )
    _aReservaCAOA := Nil
End Sequence
RestArea(_aArea)
Return _cDocto
