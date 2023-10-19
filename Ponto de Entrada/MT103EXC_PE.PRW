#Include 'Protheus.ch'
#Include 'Rwmake.ch'
#Include 'TopConn.ch'
/*/{Protheus.doc} MT103EXC
//Motivo do cancelamento.
@author A.Carlos
@since 17/10/2023
@version 
@type function
/*/
User Function MT103EXC()
Local _cEmp		:= FWCodEmp()
Local _lDevEst  := .F.
Local aRet      := {}
Local aParamBox := {}
Local cTitulo   := "Motivos do cancelamento da NF de entrada"  //"Exportação NF Cancelada Protheus -> RGlog"

	If _cEmp == "2020" //Executa o p.e. Franco da Rocha

		aAdd(aParamBox,{2 ,"Mudança Série, Valor, TES da NF ?"  ,1,{"Não","Sim"},30,"",.F.})

		If ParamBox(aParamBox,"Parametros para integração do documento...",@aRet)
			_lDevEst := aRet[1]==IIf(ValType(aRet[1])=="S",1,"Sim")

			If aRet[1] == IIf( ValType(aRet[1]) == "S", 1, "Sim" )
				If  RecLock("SF1",.F.)
					SF1->F1_XMOTC := "S"    //-- X = Integrado RgLog
					SF1->( MsUnLock() )
				EndIf
			EndIf

		EndIf

		If Findfunction("U_ZWSR014")
			U_ZWSR014()
		EndIf

    ENDIF

Return()
