#Include 'Protheus.ch'
#Include 'TopConn.ch'
/*/{Protheus.doc} ZFATF015
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	13/04/2022
@return  	NIL
@obs        Usado após a gravação da NF p/salvar dados adicionais 
@project
@history    Chamado pelo PE OX004DNF
/*/
User Function ZFATF015()
Local _cModal := ""
Local _cTped  := ""

    _cTped  := X3CBOXDESC('VS1_TIPORC', VS1->VS1_TIPORC)                                                                                       
    _cModal := POSICIONE("VX5",1,XFILIAL("VX5")+"Z01"+VS1->VS1_XTPTRA,"VX5_DESCRI") 

	//-- Atualiza C5_MENNOTA do pedido de venda posicionado inicialmente
	//If lAtuSC5 .And. SC5->( MsSeek( xFilial("SC5") + cNumPed )   ) 

        RecLock( "SC5" , .F. )
        aAdd(aCabPV,{"C5_MENNOTA",Alltrim(_cTped) + ' ' + Alltrim(_cModal) ,Nil})
        MsUnLock()	

	//EndIf

Return()
