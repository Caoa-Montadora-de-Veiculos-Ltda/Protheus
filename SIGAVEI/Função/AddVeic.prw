#include "totvs.ch"
#INCLUDE "FWMVCDEF.CH"

User Function AddVeic()

	Local aCposCab := {}
	Local lRet     := .T.

	Local aParParamBox := {}
	Local aRetParamBox := {}
	
	AADD( aParParamBox , { 1 , RetTitle("VV1_CHASSI") , Space(TamSX3("VV1_CHASSI")[1]) , "" , "" , "" , "" , 40 , .T. } )
	AADD( aParParamBox , { 1 , RetTitle("VV1_MODVEI") , "GBZ5                          " , "" , "" , "" , "" , 40 , .T. } )
	AADD( aParParamBox , { 1 , RetTitle("VV1_SEGMOD") , "7J20K42S  " , "" , "" , "" , "" , 40 , .T. } )

	If ! ParamBox(aParParamBox,"Adicionar Veiculo",@aRetParamBox,,,,,,,, .f., .f.)
		Return
	EndIf

	INCLUI := .T.

	If Empty(aRetParamBox[1])
		cSQL := "SELECT COUNT(*) " +;
			" FROM " + RetSQLName("VV1") + " VV1 " +;
			" WHERE VV1.VV1_FILIAL = '" + xFilial("VV1") + "'" + ;
			" AND VV1.VV1_CHASSI LIKE 'CHASSI_MVC_EXECAUTO_%'" + ;
			" AND VV1.D_E_L_E_T_ = ' ' "

		cChassi := 'CHASSI_MVC_EXECAUTO_' + StrZero(FM_SQL(cSQL) + 1, 3)
	Else
		cChassi := aRetParamBox[1]
	EndIf

	aAdd( aCposCab , { 'VV1_CODMAR' , 'HYU'           } )
	aAdd( aCposCab , { 'VV1_CHASSI' , cChassi         } )
	aAdd( aCposCab , { 'VV1_MODVEI' , aRetParamBox[2] } )
	aAdd( aCposCab , { 'VV1_SEGMOD' , aRetParamBox[3] } )
	aAdd( aCposCab , { 'VV1_FABMOD' , '20192019'      } )
	aAdd( aCposCab , { 'VV1_CORVEI' , '1K    '        } )
	aAdd( aCposCab , { 'VV1_COMVEI' , '4'             } )
	aAdd( aCposCab , { 'VV1_ESTVEI' , '0'             } )
	aAdd( aCposCab , { 'VV1_LOCPAD' , 'VN'            } )

	If !Import(aCposCab)
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
Static Function Import(aCpoCAB)
	Local  oModel, oAux, oStruct
	Local  nI        := 0
	Local  nPos      := 0
	Local  lRet      := .T.
	Local  aAux	     := {}
	Local  cModelVV1	  := 'MODEL_VV1'

	oModel := FWLoadModel( 'VEIA070' )
	oModel:SetOperation( MODEL_OPERATION_INSERT )
	lRet := oModel:Activate()

	If lRet
		oAux    := oModel:GetModel( cModelVV1 )
		oStruct := oAux:GetStruct()
		aAux	:= oStruct:GetFields()
		For nI := 1 To Len( aCpoCAB )
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoCAB[nI][1] ) } ) ) > 0
				If !oModel:SetValue( cModelVV1, aCpoCAB[nI][1], aCpoCAB[nI][2] )
					lRet    := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf

	If lRet
		If ( lRet := oModel:VldData() )
			lRet := oModel:CommitData()
		EndIf
	EndIf

	If !lRet

		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro   := oModel:GetErrorMessage()

		// A estrutura do vetor com erro é:
		//  [1] Id do formulário de origem
		//  [2] Id do campo de origem
		//  [3] Id do formulário de erro
		//  [4] Id do campo de erro
		//  [5] Id do erro
		//  [6] mensagem do erro
		//  [7] mensagem da solução
		//  [8] Valor atribuido
		//  [9] Valor anterior

		AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
		AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
		AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
		AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
		AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
		AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
		AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
		AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
		AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )

		If (!IsBlind()) // COM INTERFACE GRÁFICA
			MostraErro() //TELA
		EndIf
	EndIf

	// Desativamos o Model
	oModel:DeActivate()

Return lRet
