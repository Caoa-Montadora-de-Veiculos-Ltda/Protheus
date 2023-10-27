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
Local lRet      := .T.
Local aRet      := {}
Local aParamBox := {}
Local cTitulo   := "Motivos do cancelamento da NF de entrada"  //"Exportação NF Cancelada Protheus -> RGlog"

	If _cEmp == "2020" //Executa o p.e. Franco da Rocha

		aAdd(aParamBox,{2 ,"Muda N.e Série, Valor, TES da NF ?",1,{"Não","Sim"},40,"",.F.})

		If ParamBox(aParamBox,cTitulo,@aRet)
			If MV_PAR01 == 'Sim'
				If  RecLock("SF1",.F.)
					SF1->F1_XCANC := 'S'   //-- X = Integrado RgLog
					SF1->( MsUnLock() )
				EndIf
				If Findfunction("U_ZWSR014")
					U_ZWSR014()
				EndIf
			EndIf
        ENDIF

    ENDIF

Return(lRet)
