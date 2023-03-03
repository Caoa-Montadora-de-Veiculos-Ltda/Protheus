#include 'protheus.ch'
#include 'parmtype.ch'

user function CMVROTPAD(cChassi)

	Local aDados :={}

	aAdd(aDados,{"VV1_FILIAL"          ,xFilial("VV1")          ,Nil})
	aAdd(aDados,{"VV1_CODMAR"		   ,"HY"   					,Nil})
	aAdd(aDados,{"VV1_CHASSI"		   ,cChassi   				,Nil})
	aAdd(aDados,{"VV1_MODVEI"		   ,"AZE89999GBUH"			,Nil})
	aAdd(aDados,{"VV1_FABMOD"		   ,"20192020"            	,Nil})
	aAdd(aDados,{"VV1_COMVEI"		   ,"4"   					,Nil})
	aAdd(aDados,{"VV1_CODORI"		   ,"0"         			,Nil})
	aAdd(aDados,{"VV1_PROVEI"		   ,"1"   					,Nil})
	aAdd(aDados,{"VV1_ESTVEI"		   ,"0"         			,Nil})
	aAdd(aDados,{"VV1_LOCPAD"		   ,"VN"   					,Nil})
	aAdd(aDados,{"VV1_CORVEI"		   ,"000001"   				,Nil})



	U_xCV1Veic(aDados)

return

User Function xCV1Veic(aDados)

		PRIVATE lMsErroAuto := .F.

		MSExecAuto({|x,y| VEIXA010(x,y)},aDados,3)

		If lMsErroAuto
			lMsErroAuto:= .F.

			If (!IsBlind())
				MostraErro() // TELA
			Else
				// EM ESTADO DE JOB
				cError := ""
				cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

				ConOut(PadC("Automatic routine ended with error", 80))
				ConOut("Error: "+ cError)
			EndIf
		EndIf

return

User Function xCV1NfV(aCab,aItens)

return
