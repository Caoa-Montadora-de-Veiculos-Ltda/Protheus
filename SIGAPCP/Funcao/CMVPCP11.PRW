#include 'protheus.ch'
#include 'parmtype.ch'
/*
=====================================================================================
Programa.:              CMVPCP11
Autor....:              Atilio Amarilla
Data.....:              05/03/2019
Descricao / Objetivo:   Integração PROTHEUS - PCP x MES
Doc. Origem:            Contrato - GAP PCP004
Solicitante:            Cliente CAOA
Uso......:              Marfrig
Obs......:              Integração de informações de produção (MES). PE MATI681INT
=====================================================================================
*/
User Function CMVPCP11(oXml)

	Local aRet	:= {}

	Local aArea	:= GetArea() //ParamIXB

    aAdd(aRet, .T.) // Irá executar a rotina padrão
    aAdd(aRet, .T.) // XML importado com sucesso
    aAdd(aRet, " ") // Como não houve erro, o terceiro parâmetro deve estar em branco.

	//Variável oXml é de escopo PRIVATE, definida nos fontes padrão.
	
	//Exemplo buscando tag reportquantity. Indica Tipo de Informação: 1 - VIN ; 2 - ITEM DE SEGURANÇA ; 3 - PBS
	//If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_reportquantity:Text") != "U" .And. ;
	//   !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_reportquantity:Text)

	If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfWasteAppointments:_WasteAppointment:_WasteCode:Text") != "U" .And. ;
	   !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfWasteAppointments:_WasteAppointment:_WasteCode:Text)


		aRet[1] := .F.
	   
		cTipInf := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_reportquantity:Text
		cTipInf := AllTrim(Str(Val(cTipInf)))
		
		If cTipInf $ "12345"
			cNumOrd	:= oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text
			cNumOrd	:=	Stuff( Space(TamSX3("D3_OP")[1]) , 1 , Len(cNumOrd) , cNumOrd )

			// Busca BarCode
			dbSelectArea("ZZ3")
			dbSetOrder(3)
			If ZZ3->( dbSeek( xFilial("ZZ3")+Subs(cNumOrd,1,6) ) )
			Else
				aRet[2]	:= .F.
				aRet[3]	:= "[ERRO] BARCODE NAO LOCALIZADO"
			EndIf

			If aRet[2]
				If cTipInf $ "24"
					cCodPro	:= 	oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text
					cCodPro	:=	Stuff( Space(TamSX3("D3_COD")[1]) , 1 , Len(cCodPro) , cCodPro )

					dbSelectArea("SB1")

					If !SB1->( dbSeek( xFilial("SB1")+cCodPro ) )
						aRet[2]	:= .F.
						aRet[3]	:= "[ERRO] PRODUTO "+AllTrim(cCodPro)+" INVALIDO"
					ElseIf SB1->B1_MSBLQL == '1'
						aRet[2]	:= .F.
						aRet[3]	:= "[ERRO] PRODUTO "+AllTrim(cCodPro)+" BLOQUEADO (B1_MSBLQL)"
					EndIf
				Else
					cCodPro	:=	Space(TamSX3("D3_COD")[1])
				EndIf
			EndIf

			If aRet[2]
				cNumSer	:= 	oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_DocumentCode:Text
	
				dbSelectArea("ZZG")
				
				ConOut("RecLock ZZG")
				ConOut(RecLock("ZZG",.T.))
				ZZG->ZZG_FILIAL	:=	xFilial("ZZG")
				ZZG->ZZG_DOC	:=	GetSXENum("ZZG","ZZG_DOC")
				ConfirmSX8()
				ZZG->ZZG_BARCOD	:=	ZZ3->ZZ3_BARCOD
				ZZG->ZZG_TPINFO	:=	cTipInf
				ZZG->ZZG_PRODUT	:=	cCodPro
				If cTipInf == "3"
					ZZG->ZZG_INFORM	:=	StrZero(Val(cNumSer),3)
				Else
					ZZG->ZZG_INFORM	:=	cNumSer
				EndIf
				ZZG->ZZG_TSINCL	:=	FWTimeStamp(1)
	
				ZZG->( msUnlock() )
				aRet[2]	:= .F.
				aRet[3]	:= "[ZZG] REGISTRO GRAVADO. TP.INFO/BARCODE "+cTipInf+"/"+ZZ3->ZZ3_BARCOD
			EndIf
		
			RestArea( aArea )
		Else
			aRet[2]	:= .F.
			aRet[3]	:= "[ERRO] TIPO DE INFORMACAO "+cTipInf+" INVALIDO"
		EndIF

	EndIf


return aRet
