#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZGENQTDQBR
Rdmake 	Bloqueia a digitação de quantidade quebrada
@class    	Nao Informado
@from       Nao Informado
@param      nQte = Quantidade recebida, _lMsgn = .T. demostra mensagem .F. não demostra mensagem.
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC - Denilso 
@single		10/08/2020
@version    Nao Informado
@since      Nao Informado  
@return    	_nCusto
@sample     Nao Informado
@obs        
@project    CAOA - Bloqueia a digitação de quantidade quebrada
@menu       Nao Informado
@history    

/*/

User Function ZGENQTDQBR(_cTabela, _cCampo, _lMsg)

Local _aArea 		:= GetArea()
Local _lTabela      := .F.

Default _cTabela    := ""
Default _cCampo     := ""
Default _lMsg       := .F.

    If (M->(&_cCampo)) <> Nil .Or. (M->(&_cCampo)) > 0
        _nQte := M->(&_cCampo)
        _lTabela := .F.
    ElseIf &(_cTabela+"->"+_cCampo) <> Nil .Or. &(_cTabela+"->"+_cCampo) > 0
        _nQte := ((&_cTabela)->(&_cCampo))
        _lTabela := .T.
    Else
        _nQte := 0
    EndIf

    If _nQte <> NoRound(_nQte, 0)
        _nQte := 0
        If _lMsg
	        MsgInfo("Não é permitido informar quantidade quebrada, verifique as casas decimais para esse item.", "[ Quantidade Quebrada - A L E R T A ]")
        EndIf
	EndIf

RestArea(_aArea)

Return(_nQte)
