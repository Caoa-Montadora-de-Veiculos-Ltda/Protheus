#include "protheus.ch"
#include "parmtype.ch"
#include 'Fwmvcdef.CH'
/*/{Protheus.doc} MT120OK_PE    (MATA122 - AE Chamando a Trilha de seguran�a)
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	13/10/2020
@return  	NIL
@obs        Ponto de entrada do MATA120
@project
@history    Salvar dados adicionais em PC
            DAC-Denilso  
			20/02/2020 - Ajustado a chamada da funcionalidade n�o � necess�rio validar variavel publica
			10/03/2020 - Incluida nova funcionalidade para gerar hist�rico
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

Begin Sequence

	// ** ************************************************************ ** //
    // **  VALIDAR CAMPOS, INFORMACOES ADICIONAIS (Enchoise / MsmGet)  ** //
    // ** ************************************************************ ** //
	If FindFunction("U_ZCOMF015")
		_lRet := U_ZCOMF015( "PC" /*Doc*/,_nOpc, /*indica se devve mostrar somente a tela*/)
	EndIf

	//--Valida��o somente no PC
	If IsInCallStack("MATA121")

		ZA4->( dbSetOrder(3) )
		IF !EMPTY(cC7_XTPRE2) 
			If !( ZA4->( dbSeek( FWxFilial("ZA4") + "SC" + cC7_XTPRE2  + "PC" + cC7_XTPREQ   )    )   )
				MSGINFO("N�o existe Amarra��o para essa Solicita��o de Compras X Pedido de Compras!","Aten��o!")
				_lRet := .F.
				Return _lRet
			Endif
		ENDIF

		IF EMPTY(cC7_XTPREQ) 
			MSGINFO("O Pedido de Compras n�o pode ser gravado com o campo Tipo de Documento em Branco!","Aten��o!")
			_lRet := .F.
			Return _lRet
		Endif

		//--Valida��es do campo e-mail do PC
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

Begin Sequence
	// ** ************************************************************ ** //
    // **  VALIDAR CAMPOS, INFORMACOES ADICIONAIS (Enchoise / MsmGet)  ** //
    // ** ************************************************************ ** //
	If FindFunction("U_ZCOMF015")
		_lRet := U_ZCOMF015( "PC" /*Doc*/,_nOpc, /*indica se devve mostrar somente a tela*/)
	EndIf

	//--Valida��o somente no PC
	If IsInCallStack("MATA121")
		//--Valida��es do campo e-mail do PC
		If FindFunction("U_ZCOMF029")
			_lRet := U_ZCF29PCVD()
		EndIf
	EndIf
End Sequence
Return _lRet
