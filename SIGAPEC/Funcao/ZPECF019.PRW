#Include 'Protheus.ch'
#Include 'TopConn.ch'
#include "rwmake.ch"
#include "TOTVS.ch"
/*/{Protheus.doc} ZPECF019
@param  	
@author 	CAOA - A.Carlos
@version  	P12.1.23
@since  	11/05/2022
@return  	NIL
@obs        Chamado pelo PE VFATECLI 
@project
@history    Mostrar saldo de crédito do cliente FP.   
/*/	
User Function ZPECF019()

Local nSaldo        := 0
Local _aRetLc       := 0
Local _cMsg         := ""
Private cCodcli     := SA1->A1_COD
Private cTipoCred   := SA1->A1_XTPCRED

    IF SA1->A1_XLC > 0 
        _aRetLc := U_ZFATF014(cCodcli,cTipoCred) //Verifica saldo usado
        
		//1=Credito Disponivel;2=Falta de Saldo;3=Titulos Em Atraso;4=Credito Vencido;5=Bloqueado                                         
		If _aRetLc[01] == "2"
			_cMsg := "Cliente não possui limite de crédito disponível Status [2]"  + chr(13) + chr(10)
		ElseIf _aRetLc[01] == "3"
			_cMsg := "Cliente possui algum titulo com mais de 3 dias em atraso Status[3]" + chr(13) + chr(10)
		ElseIf _aRetLc[01] == "4"
			_cMsg := "Cliente possui limite de crédito vencido Status[4]" + chr(13) + chr(10)
		ElseIf _aRetLc[01] == "5"
			_cMsg :=  "Cliente possui limite de crédito bloqueado Status[5]" + chr(13) + chr(10)
		EndIf
        nSaldo := SA1->A1_XFPSAL
    
        IF nSaldo > 0
            MsgInfo(_cMsg + "Cliente possui Saldo disponível: R$ " + Alltrim(Transform(nSaldo,"@E 999,999,999.99")) , "Atenção!")
        ENDIF
    ENDIF
    /*IF SA1->A1_LC > 0
        nLCDis := U_ZPECF020(cCodcli)
        MsgInfo("Cliente possui Saldo LC disponível: R$ " + Alltrim(Transform(nLCDis,"@E 999,999,999.99")) , "Atenção!")
    ENDIF*/ 

Return()
