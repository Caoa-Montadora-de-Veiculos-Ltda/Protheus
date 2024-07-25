#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*---------------------------------------------------------------------------------------
{Protheus.doc} MT120FIM
Rdmake responsável pelas atualizações quando da gravação final do Pedido de Compras 
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC - Denilso Almeida Carvalho 
@version    Nao Informado
@since      20/02/2020  
@return    	
@sample     Nao Informado
@obs        
@project    
@menu       Nao Informado
@history    DAC - 01/02/2010 
			Retirada chamada U_ZCOMF003 a mesma serra utilizada no PE TOK
			Incluida chamada U_ZCOMF015 para que na inclusão seja solicitado o Histórico
---------------------------------------------------------------------------------------*/

User Function MT120FIM 
Local _nOpc    	:= PARAMIXB[1]
Local _nOpcA   	:= PARAMIXB[3]   
Local _lRet		:= .T.
Local _aEmpFil   := {cEmpAnt,cFilAnt}
Local _cFun      := Alltrim(Funname())
Local _aHeadAux  := aClone(aHeader)
Local _aColsAux  := aClone(aCols)
Local _lJobStart := .T.
Local _cNum      := cA120Num
Local _cUsuario  := RETCODUSR()
Local _cMotivo 	 := space(255)

Begin Sequence                                             
	// _nOpcA <> 1   //indica se foi confirmado
	If _lRet  .and. FindFunction("U_ZCOMF015") .and. _nOpc == 5 .and. _nOpcA == 1
		//_lRet := U_ZCOMF015( "PC" /*DoC*/, _nOpc /*Novo Registro inclusao*/, /*indica se devve mostrar somente a tela*/,/*indica que esta sendo copiado*/)
		If INCLUI
			_cMotivo := "Inclusão"
		else
			U_TelMotivo(@_cMotivo)
		Endif
		StartJob("U_ZCOMF015",GetEnvServer(),.F.,"PC",_nOpc,,_cNum,_aHeadAux,_aColsAux,_lJobStart,_aEmpFil,_cFun,INCLUI,ALTERA,_cUsuario,_cMotivo )
	Endif
	
	//--Realiza gravação no campo C7_XFORMAI dos e-mails informados no PC
	If FindFunction("U_ZCOMF029") .and. ( _nOpc == 3 .Or. _nOpc == 4 ) .and. _nOpcA == 1
		_lRet := U_ZCF029PCGR()
	Endif
End Sequence
Return _lRet


