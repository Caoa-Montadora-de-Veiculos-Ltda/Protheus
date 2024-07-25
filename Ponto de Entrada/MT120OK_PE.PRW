#include "protheus.ch"
#include "parmtype.ch"
#include 'Fwmvcdef.CH'
/*/{Protheus.doc} MT120OK_PE    (MATA122 - AE Chamando a Trilha de segurança)
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	13/10/2020
@return  	NIL
@obs        Ponto de entrada do MATA120
@project
@history    Salvar dados adicionais em PC
            DAC-Denilso  
			20/02/2020 - Ajustado a chamada da funcionalidade não é necessário validar variavel publica
			10/03/2020 - Incluida nova funcionalidade para gerar histórico
*/
User Function MT120OK()

   Local _cEmp    := FWCodEmp()
   Local _lRet	   := .T.
   Local aArea	   := GetArea()

   If _cEmp == "2010" //Executa o p.e. Anapolis.
      _lRet := zMontadora()
   Else
      _lRet := zCaoaSp() //Executa o p.e. CaoaSp
   EndIf

   RestArea(aArea)

Return(_lRet)

/*
==============================================================================================
Programa.:              zMontadora
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada Montadora
===============================================================================================
*/
Static Function zMontadora()

Local _lRet       := .T.
Local  _nOpc      := If(INCLUI,3, ;
					 IF(ALTERA,4, ;
					 5) )
Local _aEmpFil   := {cEmpAnt,cFilAnt}
Local _cFun      := Alltrim(Funname())
Local _aHeadAux  := aClone(aHeader)
Local _aColsAux  := aClone(aCols)
Local _lJobStart := .T.
Local _cNum      := cA120Num
Local _cUsuario  := RETCODUSR()
Local _cMotivo 	 := space(255)

Begin Sequence

	// ** ************************************************************ ** //
    // **  VALIDAR CAMPOS, INFORMACOES ADICIONAIS (Enchoise / MsmGet)  ** //
    // ** ************************************************************ ** //
	If FindFunction("U_ZCOMF015")
		//_lRet := U_ZCOMF015( "PC" /*Doc*/,_nOpc, /*indica se devve mostrar somente a tela*/)
		If INCLUI
			_cMotivo := "Inclusão"
		else
			U_TelMotivo(@_cMotivo)
		Endif
		StartJob("U_ZCOMF015",GetEnvServer(),.F.,"PC",_nOpc,,_cNum,_aHeadAux,_aColsAux,_lJobStart,_aEmpFil,_cFun,INCLUI,ALTERA,_cUsuario,_cMotivo )
	EndIf

	//--Validação somente no PC
	If IsInCallStack("MATA121")

		ZA4->( dbSetOrder(3) )
		IF !EMPTY(cC7_XTPRE2) 
			If !( ZA4->( dbSeek( FWxFilial("ZA4") + "SC" + cC7_XTPRE2  + "PC" + cC7_XTPREQ   )    )   )
				MSGINFO("NÃo existe Amarração para essa Solicitação de Compras X Pedido de Compras!","Atenção!")
				_lRet := .F.
				Return _lRet
			Endif
		ENDIF

		IF EMPTY(cC7_XTPREQ) 
			MSGINFO("O Pedido de Compras não pode ser gravado com o campo Tipo de Documento em Branco!","Atenção!")
			_lRet := .F.
			Return _lRet
		Endif

		//--Validações do campo e-mail do PC
		If FindFunction("U_ZCOMF029")
			_lRet := U_ZCF29PCVD()
		EndIf
	EndIf
End Sequence

Return _lRet

/*
==============================================================================================
Programa.:              zCaoaSp
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada CaoaSp
===============================================================================================
*/
Static Function zCaoaSp()
Local _lRet       := .T.
Local  _nOpc      := If(INCLUI,3, ;
					 IF(ALTERA,4, ;
					 5) )
Local _aEmpFil   := {cEmpAnt,cFilAnt}
Local _cFun      := Alltrim(Funname())
Local _aHeadAux  := aClone(aHeader)
Local _aColsAux  := aClone(aCols)
Local _lJobStart := .T.
Local _cNum      := cA120Num
Local _cUsuario   := RETCODUSR()
Local _cMotivo 	:= space(255)

Begin Sequence
	// ** ************************************************************ ** //
    // **  VALIDAR CAMPOS, INFORMACOES ADICIONAIS (Enchoise / MsmGet)  ** //
    // ** ************************************************************ ** //
	If FindFunction("U_ZCOMF015")
		//_lRet := U_ZCOMF015( "PC" /*Doc*/,_nOpc, /*indica se devve mostrar somente a tela*/)
		If INCLUI
			_cMotivo := "Inclusão"
		else
			U_TelMotivo(@_cMotivo)
		Endif
		StartJob("U_ZCOMF015",GetEnvServer(),.F.,"PC",_nOpc,,_cNum,_aHeadAux,_aColsAux,_lJobStart,_aEmpFil,_cFun,INCLUI,ALTERA,_cUsuario,_cMotivo )
	EndIf

	//--Validação somente no PC
	If IsInCallStack("MATA121")
		//--Validações do campo e-mail do PC
		If FindFunction("U_ZCOMF029")
			_lRet := U_ZCF29PCVD()
		EndIf
	EndIf
End Sequence
Return _lRet
