#include "totvs.ch"
#include "protheus.ch"
#include "Topconn.ch"

User Function ZCMV_NFESEFAZ()

	Local aProd   		:= PARAMIXB[1]
	Local cMensCli		:= PARAMIXB[2]
	Local cMensFis		:= PARAMIXB[3]
	Local aDest   		:= PARAMIXB[4]
	Local aNota   		:= PARAMIXB[5]
	Local aInfoItem	:= PARAMIXB[6]
	Local aDupl	  	:= PARAMIXB[7]
	Local aTransp		:= PARAMIXB[8]
	Local aEntrega		:= PARAMIXB[9]
	Local aRetirada	:= PARAMIXB[10]
	Local aVeiculo		:= PARAMIXB[11]
	Local aReboque		:= PARAMIXB[12]
	Local aNfVincRur    := PARAMIXB[13]
	Local aEspVol       := PARAMIXB[14]
	Local aNfVinc       := PARAMIXB[15]
	Local aDetPag       := PARAMIXB[16]
	Local aObsCont      := PARAMIXB[17]

	Local aRetorno		:= {}
	Local I             := 0
	Local G             := 0
	Local aArea         := GetArea()
	Local cCodCli       := " "
	Local cLoja         := " "
	Local cGrupo        := GetMv("MV_GRUVEI")
	Local cGrpPrd       := ""
	Local cItem         := ""
	Local nTamIt        := TamSX3("CD9_ITEM")[1]
	Local aEspVei       := {}
	Local aPedidos      := {}
	Local aTes          := {}
	Local aComb         := {}
	Local cCodM         := ""
	Local cMarca        := ""
	Local cCorInt       := ""
	Local nPosTes       := 0
	Local nPosPed       := 0
	Local lVeic         := .F.
	Local lAlpha        := .F.
	Local T			:= 0
	Local cCondAlp      := SuperGetMv('CMV_CODALF',.F.," ")
	Local nPass         := 0
	Local aAreaSF2,aAreaSA2,aAreaSF1,aAreaSW6,aAreaEIH,aAreaSJF,aAreaSW9,aAreaSWV,aAreaSWD,aAreaSYB,aAreaVV0
	Local cAlias		:= "F1HAWB"
	Local cFilSF1		:= xFilial("SF1")
	Local cFilSYP		:= xFilial("SYP")
	Local aAreaCD9      := {}
	Local aAreaSD2      := {}
	Local aAreaSC6      := {}
	Local aAreaSC5      := {}
	Local aAreaSF4      := {}
	Local aAreaSM4      := {}
	Local aAreaSD1      := {}
	Local aAreaSA1      := {}
	Local aAreaVV1      := {}
	Local aAreaVV2      := {}
	Local cEicMsg1      := SuperGetMv('CMV_EICMS1',.F.,"101/102/")
	Local cEicMsg2      := SuperGetMv('CMV_EICMS2',.F.,"CAOA MONTADORA DE VEICULOS LTDA - ENDERECO: AVENIDA VICINAL ANAPOLIS, FAZENDA BARREIRO DO MEIO, ANAPOLIS-GO CEP: 75132-450 CNPJ: 03.471.344/0007-62 INSC. ESTADUAL: 10.748.091-3")
	Local aChassi		:= {}
	Local cVeiTes		:= SuperGetMv('CMV_VEITS1',.F.,"703/")
	Local cQry          := GetNextAlias()
	Local cCmd		:= ""
	Local aCont         := {}
	Local cContainer    := {}

	ConOut("PE01NFESEFAZ - INICIO - NF: " + aNota[2] + " Serie: " + aNota[1] )

	G := 0

	aadd(aEspVei,{"01","PASSAGEIRO"})
	aadd(aEspVei,{"02","CARGA"})
	aadd(aEspVei,{"03","MISTO"})
	aadd(aEspVei,{"04","CORRIDA"})
	aadd(aEspVei,{"05","TRACAO"})
	aadd(aEspVei,{"06","ESPECIAL"})
	aadd(aEspVei,{"07","COLECAO"})

	/*aadd(aComb,{"01","ALCOOL"})
	aadd(aComb,{"02","GASOLINA"})
	aadd(aComb,{"03","DIESEL"})
	aadd(aComb,{"04","GASOGENIO"})
	aadd(aComb,{"05","GAS METANO"})
	aadd(aComb,{"06","ELETRICO/FONTE INTERNA"})
	aadd(aComb,{"07","ELETRICO/FONTE EXTERNA"})
	aadd(aComb,{"08","GASOL/GAS NATURAL COMBUSTIVEL"})
	aadd(aComb,{"09","ALCOOL/GAS NATURAL COMBUSTIVEL"})
	aadd(aComb,{"10","DIESEL/GAS NATURAL COMBUSTIVEL"})
	aadd(aComb,{"11","VIDE/CAMPO/OBSERVACAO"})
	aadd(aComb,{"12","ALCOOL/GAS NATURAL VEICULAR"})
	aadd(aComb,{"13","GASOLINA/GAS NATURAL VEICULAR"})
	aadd(aComb,{"14","DIESEL/GAS NATURAL VEICULAR"})
	aadd(aComb,{"15","GAS NATURAL VEICULAR"})
	aadd(aComb,{"16","ALCOOL/GASOLINA"})
	aadd(aComb,{"17","ALCOOL/GASOLINA/GAS NATURAL"})
	aadd(aComb,{"18","GASOLINA/ELETRICO/ALCOOL/GAS NATURAL"})*/

	aadd(aComb, {"01"	, "ALCOOL"})
	aadd(aComb, {"02"	, "GASOLINA"})
	aadd(aComb, {"03"	, "DIESEL"})
	aadd(aComb, {"04"	, "GASOGENIO"})
	aadd(aComb, {"05"	, "GAS METANO"})
	aadd(aComb, {"06"	, "ELETRICO/FONTE INTERNA"})
	aadd(aComb, {"07"	, "ELETRICO/FONTE EXTERNA"})
	aadd(aComb, {"08"	, "GASOL/GAS NATURAL COMBUSTIVEL"})
	aadd(aComb, {"09"	, "ALCOOL/GAS NATURAL COMBUSTIVEL"})
	aadd(aComb, {"10"	, "DIESEL/GAS NATURAL COMBUSTIVEL"})
	aadd(aComb, {"11"	, "VIDE/CAMPO/OBSERVACAO"})
	aadd(aComb, {"12"	, "ALCOOL/GAS NATURAL VEICULAR"})
	aadd(aComb, {"13"	, "GASOLINA/GAS NATURAL VEICULAR"})
	aadd(aComb, {"14"	, "DIESEL/GAS NATURAL VEICULAR"})
	aadd(aComb, {"15"	, "GAS NATURAL VEICULAR"})
	aadd(aComb, {"16"	, "ALCOOL/GASOLINA"})
	aadd(aComb, {"17"	, "ALCOOL/GASOLINA/GNV"})
	aadd(aComb, {"18"	, "GASOLINA/ELETRICO"})
	aadd(aComb, {"19"	, "GASOLINA/ALCOOL/ELETRICO"})
	aadd(aComb, {""		, "SEM COMBUSTIVEL"})

	dbSelectArea("SF2")
	aAreaSF2 := GetArea()
	SF2->(DbSetOrder(1))

	dbSelectArea("CD9")
	aAreaCD9 := GetArea()
	CD9->(DbSetOrder(1))

	dbSelectArea("SD2")
	aAreaSD2 := GetArea()
	SD2->(DbSetOrder(3))

	dbSelectArea("SC6")
	aAreaSC6 := GetArea()
	SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	dbSelectArea("SC5")
	aAreaSC5 := GetArea()
	SC5->(DbSetOrder(1))

	dbSelectArea("SF4")
	aAreaSF4 := GetArea()
	SF4->(DbSetOrder(1))

	dbSelectArea("SM4")
	aAreaSM4 := GetArea()
	SM4->(DbSetOrder(1))

	dbSelectArea("SD1")
	aAreaSD1 := GetArea()
	SD1->(DbSetOrder(1))

	dbSelectArea("SA1")
	aAreaSA1 := GetArea()
	SA1->(DbSetOrder(1))

	dbSelectArea("SA2")
	aAreaSA2 := GetArea()
	SA2->(DbSetOrder(1))

	dbSelectArea("VV1")
	aAreaVV1 := GetArea()
	VV1->(DbSetOrder(2)) //Por Chassi

	dbSelectArea("VV2")
	aAreaVV2 := GetArea()
	VV2->(DbSetOrder(1)) 

// NFE Importação
	dbSelectArea("SF1")
	aAreaSF1 := GetArea()
	SF1->(DbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

	dbSelectArea("SW6")
	aAreaSW6 := GetArea()
	SW6->(DbSetOrder(1)) // W6_FILIAL+W6_HAWB

	dbSelectArea("EIH")
	aAreaEIH := GetArea()
	EIH->(DbSetOrder(1)) // EIH_FILIAL+EIH_HAWB+EIH_CODIGO

	dbSelectArea("SJF")
	aAreaSJF := GetArea()
	SJF->(DbSetOrder(1)) // JF_FILIAL+JF_CODIGO

	dbSelectArea("SW9")
	aAreaSW9 := GetArea()
	SW9->(DbSetOrder(3)) // W9_FILIAL+W9_HAWB

	dbSelectArea("SWV")
	aAreaSWV := GetArea()
	SWV->(DbSetOrder(2)) // WV_FILIAL+WV_HAWB+WV_INVOICE+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO

	dbSelectArea("SWD")
	aAreaSWD := GetArea()
	SWD->(DbSetOrder(1)) // WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)

	dbSelectArea("SYB")
	aAreaSYB := GetArea()
	SYB->(DbSetOrder(1)) // YB_FILIAL+YB_DESP

	dbSelectArea("VV0")
	aAreaVV0 := GetArea()
	VV0->(DbSetOrder(4)) // VV0_FILIAL+VV0_NUMNFI+VV0_SERNFI

	If Alltrim(aNota[4]) == "1" .Or. (aNota[5] $ "B/D" .And. Alltrim(aNota[4]) == "0")
		cCodCli       := Posicione("SA1",3,xFilial("SA1")+aDest[1],"A1_COD")
		cLoja         := Posicione("SA1",3,xFilial("SA1")+aDest[1],"A1_LOJA")
	ElseIf aNota[5] $ "N" .And. Alltrim(aNota[4]) == "0" .And. aDest[7] == "99999"
		cCodCli       := Posicione("SA2",3,xFilial("SA2")+aDest[1],"A2_COD")
		cLoja         := Posicione("SA2",3,xFilial("SA2")+aDest[1],"A2_LOJA")
	Endif

//Verifica se é Nota de Veiculo SIGAVEI
	VV0->(Dbgotop())
	If VV0->(DbSeek(xFilial("VV0")+aNota[2]+aNota[1]))
		lVeic := .T.
		If Substr(cCondAlp,1,3) $ VV0->VV0_FORPAG
			lAlpha  := .T.
		Endif
	Else
		IF SD2->(DbSeek(xFilial("SD2")+aNota[2]+aNota[1]+cCodCli+cLoja))
			IF SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)) .And. SC5->C5_XTIPVEN == "01"
				lVeic := .T.
				If Substr(cCondAlp,1,3) $ SC5->C5_CONDPAG
					lAlpha  := .T.
				EndIf
			EndIf
		EndIf
		RestArea(aAreaSD2)
		RestArea(aAreaSC5)		
	Endif

	If aNota[5] == "N" .And. lVeic
		For I:= 1 to Len(aProd)
			cGrpPrd := Posicione("SB1",1,xFilial("SB1")+aProd[I][2],"B1_GRUPO")
			cItem   := Strzero(aProd[I][1],2)
			cCodM   := Posicione("VV2",7,xFilial("VV2")+aProd[I][2],"VV2_CODMAR")
			cMarca  := Posicione("VE1",1,xFilial("VE1")+cCodM,"VE1_DESMAR")
			nPass   := Posicione("VV2",7,xFilial("VV2")+aProd[I][2],"VV2_QTDPAS")


//		Tratativa para colocar os dados abaixo em Informações adicionais do Produto
//      e ser Impresso na DANFE, incluindo espaços na descrição para impressão da Danfe ficar colunado
// 		Deixamos com 35 pois a Variavél na Impressão da DANFE MAXITEMC está com 35

			If cGrpPrd $ cGrupo
				CD9->(Dbgotop())
				If CD9->(DbSeek(xFilial("CD9")+"S"+aNota[1]+aNota[2]+cCodCli+cLoja+cItem+space(nTamIt-2)+aProd[I][2]))
					cAux1 := " Tipo: "+Alltrim(Posicione("VV8",1,xFilial("VV8")+CD9->CD9_TPVEIC,"VV8_DESCRI"))
					cAux2 := " Marca: "+Alltrim(cMarca)
					cAux3 := " Chassi: "+ Alltrim(CD9->CD9_CHASSI)
					cAux4 := " Comb: " + Alltrim(aComb[aScan(aComb,{|x| Alltrim(x[1]) == Alltrim(CD9->CD9_TPCOMB)})][02])
					cAux5 := " Motor: "+Alltrim(CD9->CD9_NMOTOR)
					cAux6 := " Especie: "+Alltrim(aEspVei[aScan(aEspVei,{|x| x[1] == CD9->CD9_ESPVEI})][02])
					cAux6 += " Potência: "+Alltrim(CD9->CD9_POTENC)
					cAux7 := " Cor: "+Alltrim(CD9->CD9_DSCCOR)
					cAux8 := " Renavam: "+Alltrim(CD9->CD9_CODMOD)
					cAux9:= ""  //Ano Modelo
					cAux10:= ""  //DI / Dt DI

					VV1->(Dbgotop())
					If VV1->(DbSeek(xFilial("VV1")+CD9->CD9_CHASSI))
						cAux9+= " Ano/Modelo: "+Alltrim(Substr(VV1->VV1_FABMOD,1,4))+"/"+Alltrim(Substr(VV1->VV1_FABMOD,5,4))
						If !Empty(VV1->VV1_DI)
							cAux10+= " DI: "+Alltrim(VV1->VV1_DI)
							cAux10+= " Dt DI: "+DTOC(VV1->VV1_DTDI)
						EndIf
					Endif

					cAux9+= " Num. Pass: "+Alltrim(Str(nPass))


					aProd[I][25] := cAux1+Space(35-Len(cAux1))+cAux2+Space(35-Len(cAux2))+cAux3+Space(35-Len(cAux3));
						+cAux4+Space(35-Len(cAux4))+cAux5+Space(35-Len(cAux5))+cAux6+Space(35-Len(cAux6))+cAux7+Space(35-Len(cAux7));
						+cAux8+Space(35-Len(cAux8))+cAux9+Space(35-Len(cAux9))//+cAux10+Space(35-Len(cAux10))

					If !Empty(cAux10)
						aProd[I][25] := aProd[I][25] + cAux10+Space(35-Len(cAux10))
					Endif

					If lAlpha
						aProd[I][25] += " "+ Substr(cCondAlp,5,34)
						aProd[I][25] += Substr(cCondAlp,38,35)
						aProd[I][25] += Substr(cCondAlp,72,35)
						aProd[I][25] += Substr(cCondAlp,106,35)
					Endif
				Endif

				cCorInt := Posicione("VV2",7,xFilial("VV2")+aProd[I][2],"VV2_CORINT")
				aadd(aObsCont,{"corInterna",Alltrim(Posicione("VX5",1,xFilial("VX5")+"066"+cCorInt,"VX5_DESCRI"))})
				aadd(aObsCont,{"UserEnvio",cUsername})
				aadd(aObsCont,{"Programa" ,"PROTHEUS"})

				If !Empty(VV0->VV0_OBSMNF)
					//cMsgVV0	:= AllTrim(E_MSMM(VV0->VV0_OBSMNF))
					cMsgVV0	:= AllTrim(MSMM(VV0->VV0_OBSMNF))
					If Empty(cMsgVV0)
						If Select(cAlias) > 0
							dbSelectArea(cAlias)
							(cAlias)->( dbCloseArea() )
						EndIf

						BeginSql Alias cAlias
						SELECT YP_TEXTO
						FROM %table:SYP% SYP
						WHERE SYP.%NotDel%
							AND SYP.YP_FILIAL = %Exp:cFilSYP%
							AND SYP.YP_CHAVE = %Exp:VV0->VV0_OBSMNF%
						ORDER BY YP_CHAVE, YP_SEQ
						EndSql

						While !(cAlias)->( eof() )
							cMsgVV0 += AllTrim((cAlias)->YP_TEXTO)
							(cAlias)->( dbSkip() )
						EndDo
						dbSelectArea(cAlias)
						(cAlias)->( dbCloseArea() )
						cMsgVV0 := AllTrim(cMsgVV0)
					EndIf
					cMsgVV0 := StrTran(cMsgVV0,"\13\10",CHR(13)+CHR(10))
					If !cMsgVV0 $ cMensCli .And. !Empty(cMsgVV0)
						cMensCli += IIF(!Empty(cMensCli)," ","") + cMsgVV0
					EndIf
				EndIf

			Endif

		Next
	Endif


//Busca Mensagem no Pedido notas de saída
	If aNota[5] $"N/B" .And. Alltrim(aNota[4]) == "1"
		SD2->(Dbgotop())
		If SD2->(dbSeek(xFilial("SD2")+aNota[2]+aNota[1]+cCodCli+cLoja))
			While !SD2->(Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)== xFilial("SD2")+aNota[2]+aNota[1]+cCodCli+cLoja

				nPosPed := Ascan(aPedidos,SD2->D2_PEDIDO)  //Ascan(aPedidos,{|x| x[1] == SD2->D2_PEDIDO})
				If nPosPed == 0
					AADD(aPedidos,SD2->D2_PEDIDO)
				Endif

				nPosTes := Ascan(aTes,SD2->D2_TES)  //Ascan(aTes,{|x| x[1] == SD2->D2_TES})
				If nPosTes == 0
					AADD(aTes,SD2->D2_TES)
				Endif

				If SD2->D2_TES $ cVeiTes .And. !lVeic
					If SC6->( dbSeek( xFilial("SC6")+SD2->(D2_PEDIDO+D2_ITEMPV+D2_COD) ) )
						If !Empty(SC6->C6_CHASSI)
							aAdd( aChassi , SC6->C6_CHASSI )
						EndIf
					EndIf
				EndIf

				SD2->(dbSkip())
			Enddo
		Endif
/* 17/01/2020 - Gravação feita em NFESEFAZ.PRW	
	If Len(aPedidos) > 0
		For G:= 1 to Len(aPedidos)
			SC5->(Dbgotop())
			If SC5->(dbSeek(xFilial("SC5")+aPedidos[G]))
				If !Empty(AllTrim(SC5->C5_XMENSER))
					If !AllTrim(SC5->C5_XMENSER) $ cMensCli
						cMensCli += IIF(!Empty(cMensCli)," ","") + AllTrim(SC5->C5_XMENSER) 
					EndIf
				EndIf
			Endif	
		Next 
	Endif
*/	

		If Len(aTes) > 0
			For T:= 1 to Len(aTes)
				SF4->(Dbgotop())
				If SF4->(dbSeek(xFilial("SF4")+aTes[T]))
					If !Empty(SF4->F4_FORMULA)
						SM4->(Dbgotop())
						If SM4->(dbSeek(xFilial("SM4")+SF4->F4_FORMULA))
							cMensFis := Alltrim(cMensFis)+IIF(!Empty(cMensFis)," ","")+SM4->M4_XMSG
						Endif
					Endif
				Endif
			Next
		Endif

		If Len(aChassi) > 0

			For T:= 1 to Len(aChassi)

				If VV1->(DbSeek(xFilial("VV1")+aChassi[T]))
					If VV2->( DbSeek( xFilial("VV2") + VV1->( VV1_CODMAR + VV1_MODVEI + VV1_SEGMOD) ))

						cAux1 := " Tipo: "+Alltrim(Posicione("VV8",1,xFilial("VV8")+VV2->VV2_TIPVEI,"VV8_DESCRI"))
						cAux2 := " Marca: "+Alltrim(Posicione("VE1",1,xFilial("VE1")+VV1->VV1_CODMAR,"VE1_DESMAR"))
						cAux3 := " Chassi: "+ Alltrim(aChassi[T])
						cAux4 := " Comb: "+Alltrim(aComb[aScan(aComb,{|x| x[1] == DeParaComb( VV1->VV1_COMVEI )})][02])
						cAux5 := " Motor: "+Alltrim(VV1->VV1_NUMMOT)
						cAux6 := " Especie: "+Alltrim(aEspVei[aScan(aEspVei,{|x| x[1] == AllTrim( POSICIONE( "VVE", 1, xFilial( "VVE" ) + VV2->VV2_ESPVEI, "VVE_ESPREN") ) })][02])
						cAux7 := " Potência: "+Alltrim(cValToChar( VV2->VV2_POTMOT ))
						cAux8 := " Cor: "+AllTrim( POSICIONE( "VVC", 1, xFilial( "VVC" ) + VV1->VV1_CODMAR + VV1->VV1_CORVEI, "VVC_DESCRI" ) )
						cAux9 := " Renavam: "+Alltrim(VV2->VV2_MODFAB)
						cAux10:= ""  //Ano Modelo
						cAux11:= ""  //DI / Dt DI

						cAux10+= " Ano/Modelo: "+Alltrim(Substr(VV1->VV1_FABMOD,1,4))+"/"+Alltrim(Substr(VV1->VV1_FABMOD,5,4))

						If !Empty(VV1->VV1_DI)
							cAux11+= " DI: "+Alltrim(VV1->VV1_DI)
							cAux11+= " Dt DI: "+DTOC(VV1->VV1_DTDI)
						EndIf

						cAux10+= " Num. Pass: "+Alltrim(Str(VV2->VV2_QTDPAS))

						aProd[T][25] := cAux1+Space(35-Len(cAux1))+cAux2+Space(35-Len(cAux2))+cAux3+Space(35-Len(cAux3));
							+cAux4+Space(35-Len(cAux4))+cAux5+Space(35-Len(cAux5))+cAux6+Space(35-Len(cAux6))+cAux7+Space(35-Len(cAux7));
							+cAux8+Space(35-Len(cAux8))+cAux9+Space(35-Len(cAux9))+cAux10+Space(35-Len(cAux10))

						If !Empty(cAux11)
							aProd[T][25] += cAux11+Space(35-Len(cAux11))
						Endif

					EndIf
				Endif

			Next T
		EndIf

	Endif

	If Len(aEntrega) > 0
		cMensCli := cMensCli +" Nome: "+Alltrim(aEntrega[09])+ " Local Entrega: "+Alltrim(aEntrega[02])+" "+Alltrim(aEntrega[03])+;
			" Bairro: "+Alltrim(aEntrega[05])+" Município: "+Alltrim(aEntrega[07])+" Estado: "+Alltrim(aEntrega[08])
	Endif


// Busca os dados do chassi na Nota de Saída para fazer a entrada com Formulario Próprio SOMENTE NOTAS DE VEICULO
	If aNota[5] $ "B/D" .And. Alltrim(aNota[4]) == "0" //--.And. lVeic

		SD1->(Dbgotop())
		If SD1->(dbSeek(xFilial("SD1")+aNota[2]+aNota[1]+cCodCli+cLoja))
			While !SD1->(Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)==;
					xFilial("SD1")+aNota[2]+aNota[1]+cCodCli+cLoja
				If Alltrim(SD1->D1_GRUPO)== "VEIA"
					cCodM   := Posicione("VV2",7,xFilial("VV2")+SD1->D1_COD,"VV2_CODMAR")
					cMarca  := Posicione("VE1",1,xFilial("VE1")+cCodM,"VE1_DESMAR")
					nPass   := Posicione("VV2",7,xFilial("VV2")+SD1->D1_COD,"VV2_QTDPAS")

					CD9->(Dbgotop())
					If CD9->(DbSeek(xFilial("CD9")+"S"+SD1->D1_SERIORI+SD1->D1_NFORI+cCodCli+cLoja+SD1->D1_ITEMORI+SD1->D1_COD))
						cAux1 := " Tipo: "+Alltrim(Posicione("VV8",1,xFilial("VV8")+CD9->CD9_TPVEIC,"VV8_DESCRI"))
						cAux2 := " Marca: "+Alltrim(cMarca)
						cAux3 := " Chassi: "+ Alltrim(CD9->CD9_CHASSI)
						cAux4 := " Comb: "+Alltrim(aComb[aScan(aComb,{|x| x[1] == CD9->CD9_TPCOMB})][02])
						cAux5 := " Motor: "+Alltrim(CD9->CD9_NMOTOR)
						cAux6 := " Especie: "+Alltrim(aEspVei[aScan(aEspVei,{|x| x[1] == CD9->CD9_ESPVEI})][02])
						cAux7 := " Potência: "+Alltrim(CD9->CD9_POTENC)
						cAux8 := " Cor: "+Alltrim(CD9->CD9_DSCCOR)
						cAux9 := " Renavam: "+Alltrim(CD9->CD9_CODMOD)
						cAux10:= ""  //Ano Modelo
						cAux11:= " Num. Pass: "+Alltrim(Str(nPass))
						cAux12:= ""	 // Numero Di
						cAux13:= ""  // Data DI

						VV1->(Dbgotop())
						If VV1->(DbSeek(xFilial("VV1")+CD9->CD9_CHASSI))
							cAux10:= " Ano/Modelo: "+Alltrim(Substr(VV1->VV1_FABMOD,1,4))+"/"+Alltrim(Substr(VV1->VV1_FABMOD,5,4))
							cAux12:= " DI: "+Alltrim(VV1->VV1_DI)
							cAux13:= " Dt DI: "+DTOC(VV1->VV1_DTDI)
						Endif


						aProd[1][25] := cAux1+Space(35-Len(cAux1))+cAux2+Space(35-Len(cAux2))+cAux3+Space(35-Len(cAux3));
							+cAux4+Space(35-Len(cAux4))+cAux5+Space(35-Len(cAux5))+cAux6+Space(35-Len(cAux6))+cAux7+Space(35-Len(cAux7));
							+cAux8+Space(35-Len(cAux8))+cAux9+Space(35-Len(cAux9));
							+cAux10+Space(35-Len(cAux10))


						If !Empty(cAux11)
							aProd[1][25] := aProd[1][25] + cAux11+Space(35-Len(cAux11))
						Endif
						If !Empty(cAux12)
							aProd[1][25] := aProd[1][25] + cAux12+Space(35-Len(cAux12))
						Endif
						If !Empty(cAux13)
							aProd[1][25] := aProd[1][25] + cAux13+Space(35-Len(cAux13))
						Endif

					Endif
					If !Empty(SD1->D1_NFORI)
						//Quando Entrada
						SF2->(Dbgotop())
						If SF2->(DbSeek(xFilial("SF2")+SD1->D1_NFORI+SD1->D1_SERIORI+cCodCli+cLoja))
							SA1->(dbSetOrder(1))
							SA1->(Dbgotop())
							If SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT))
								cMensCli := cMensCli + Alltrim(SA1->A1_NOME) + " Local Retirada "+Alltrim(SA1->A1_END) + ;
									" Bairro "+Alltrim(SA1->A1_BAIRRO)+ " Município "+Alltrim(SA1->A1_MUN) + ;
									" Estado "+Alltrim(SA1->A1_EST)
							Endif
						Endif
					Endif
				Endif
				SD1->(dbSkip())
			Enddo
		Endif

	Endif

// Monta mensagem específica para importação
//ConOut('aNota[5] $ "N" .And. Alltrim(aNota[4]) == "0" .And. aDest[7] == "99999"')
	If aNota[5] $ "N" .And. Alltrim(aNota[4]) == "0" .And. aDest[7] == "99999" .And. !(cEicMsg2 $ cMensCli)
		ConOut( ' entrou em: aNota[5] $ "N" .And. Alltrim(aNota[4]) == "0" .And. aDest[7] == "99999" .And. !(cEicMsg2 $ cMensCli)')

		If Select(cAlias) > 0
			dbSelectArea(cAlias)
			(cAlias)->( dbCloseArea() )
		EndIf

		BeginSql Alias cAlias
		SELECT SF1.R_E_C_N_O_ F1_RECNO
		FROM %table:SF1% SF1
		WHERE SF1.%NotDel%
			AND SF1.F1_FILIAL = %Exp:cFilSF1%
			AND SF1.F1_DOC = %Exp:aNota[2]%
			AND SF1.F1_SERIE = %Exp:aNota[1]%
			AND SF1.F1_TIPO = 'N'
			AND SF1.F1_FORMUL = 'S'
			AND SF1.F1_HAWB <> '      '
		EndSql

		// SF1 - Notas de Importação
		ConOut("SF1 - Notas de Importação "  + SF1->F1_DOC + " SERIE: " + SF1->F1_SERIE )
		If !Empty( (cAlias)->F1_RECNO )
			SF1->( dbGoTo( (cAlias)->F1_RECNO ) )
			// SW6 - Capa DI
			//ConOut("SW6 - Capa DI")
			If SW6->(DbSeek(xFilial("SW6")+SF1->F1_HAWB))
				While !SW6->(eof()) .And. SW6->(W6_FILIAL+W6_HAWB) == xFilial("SW6")+SF1->F1_HAWB
					// N. DI.:   ; DT. DI.:
					//cMensCli += Alltrim(cMensCli)+IIF(!Empty(cMensCli)," ","") + "N. DI.: " + SW6->W6_DI_NUM
					//cMensCli += " DT. DI.: " + DTOC(SW6->W6_DTREG_D)
					// EIH - Tipo de Embalagem
					//ConOut("EIH - Tipo de Embalagem")
					If EIH->(DbSeek(xFilial("EIH")+SF1->F1_HAWB))
						If SJF->( dbSeek(xFilial("SJF")+EIH->EIH_CODIGO) )
							cMensCli += " EMBALAGEM: " + ALLTRIM(SJF->JF_DESC)
							cMensCli += " QUANTIDADE: " + ALLTRIM(TRANS(EIH->EIH_QTDADE,AVSX3("EIH_QTDADE",6)))
						EndIf
					EndIf
					cMensCli += " PESO BRUTO: " + ALLTRIM(TRANS(SW6->W6_PESO_BR,AVSX3("W6_PESO_BR",6)))
					cMensCli += " PESO LIQUIDO: " + ALLTRIM(TRANS(SW6->W6_PESOL,AVSX3("W6_PESOL",6)))
					If SW6->W6_TIPODOC == "3" .And. !Empty(SW6->W6_IDEMANI)
						cMensCli += " NUMERO DTA: " + ALLTRIM(SW6->W6_IDEMANI)
					EndIf
					If !Empty(SW6->W6_HOUSE)
						cMensCli += " N BL.: " + ALLTRIM(SW6->W6_HOUSE)
					EndIf
					// SW9 - Capa de Invoices
					//ConOut("SW9 - Capa de Invoices")
					If SW9->(DbSeek(xFilial("SW9")+SF1->F1_HAWB))
						cMensCli += " INVOICE: " + ALLTRIM(SW9->W9_INVOICE)
					EndIf

					// Valter Carvalho 19/10/2021
					// Alteração para mostrar somente o container da nota nas inofrmacoes complementares.
					// inicio
					cCmd := CHAR(13) + CHAR(10) + " SELECT DISTINCT D1_XCONT FROM " + RetSqlName("SD1")
					cCmd += CHAR(13) + CHAR(10) + " WHERE "
					cCmd += CHAR(13) + CHAR(10) + "     D_E_L_E_T_= ' ' "
					cCmd += CHAR(13) + CHAR(10) + " AND D1_FILIAL = '" + SF1->F1_FILIAL + "' "
					cCmd += CHAR(13) + CHAR(10) + " AND D1_XCONT <> ' ' "
					cCmd += CHAR(13) + CHAR(10) + " AND D1_SERIE  = '" + SF1->F1_SERIE  + "' "
					cCmd += CHAR(13) + CHAR(10) + " AND D1_DOC    = '" + SF1->F1_DOC    + "' "
					cCmd += CHAR(13) + CHAR(10) + " AND D1_FORNECE= '" + SF1->F1_FORNECE+ "' "
					cCmd += CHAR(13) + CHAR(10) + " AND D1_LOJA   = '" + SF1->F1_LOJA   + "' "

					TcQuery cCmd new Alias (cQry)

					(cQry)->(DbEval({|| Aadd(aCont, Alltrim((cQry)->D1_XCONT)) }, {|| .T.}))

					(cQry)->(DbCloseArea())

					If Len(aCont) > 0
						cCmd := ""
						aEval(aCont, {|it| cCmd +=   it + ", "})

						cCmd := Substr(cCmd, 1, Len(cCmd) -2 )

						cMensCli += " Container(s): " + cCmd + " "

						cCmd := ""
					EndIf
					// Valter Carvalho 19/10/2021
					// Alteração para mostrar somente o container da nota nas inofrmacoes complementares.
					// fim

					// SWD - Despesas Declaração Importação
					//ConOut("SWD - Despesas Declaração Importação")
					If SWD->(DbSeek(xFilial("SWD")+SF1->F1_HAWB))
						While !SWD->(eof()) .And. SWD->(WD_FILIAL+WD_HAWB) == xFilial("SWD")+SF1->F1_HAWB
							If !SWD->WD_DESPESA $ cEicMsg1
								cMensCli += " " + AllTrim(GetAdvFVal("SYB","YB_DESCR",xFilial("SYB")+SWD->WD_DESPESA,1,"")) + ": " + ALLTRIM(TRANS(SWD->WD_VALOR_R,AVSX3("WD_VALOR_R",6)))
							EndIf
							SWD->( dbSkip() )
						EndDo
					EndIf
					If !Empty(SW6->W6_LOCALN)
						cMensCli += " LOCAL DA ENTREGA: " + cEicMsg2 // ALLTRIM(SW6->W6_LOCALN)
					EndIf
					SW6->( dbSkip() )
				EndDo
			EndIf
		Endif

		dbSelectArea(cAlias)
		(cAlias)->( dbCloseArea() )

		// Valter Carvalho 14/06/2021 eic 108
		// Se nota gerada por processo de importação do EIC, inserir as informações de PIS e COFINS
		// inserir mensagen de formulas nas tes
		if !Vazio(SF1->F1_HAWB)
			cCmd := CHAR(13) + CHAR(10) + " SELECT DISTINCT CASE WHEN D1_TES = ' ' THEN D1_TESACLA ELSE D1_TES END AS D1_TES"
			cCmd += CHAR(13) + CHAR(10) + " FROM " + RetSqlName("SD1") + " SD1"
			cCmd += CHAR(13) + CHAR(10) + " WHERE  "
			cCmd += CHAR(13) + CHAR(10) + "      D_E_L_E_T_ = ' ' "
			cCmd += CHAR(13) + CHAR(10) + " AND  D1_FILIAL =  '" + SF1->F1_FILIAL   + "' "
			cCmd += CHAR(13) + CHAR(10) + " AND  D1_DOC =     '" + SF1->F1_DOC      + "' "
			cCmd += CHAR(13) + CHAR(10) + " AND  D1_SERIE =   '" + SF1->F1_SERIE    + "' "
			cCmd += CHAR(13) + CHAR(10) + " AND  D1_FORNECE = '" + SF1->F1_FORNECE  + "' "
			cCmd += CHAR(13) + CHAR(10) + " AND  D1_LOJA =    '" + SF1->F1_LOJA     + "' "

			TcQuery cCmd new alias (cQry)
			While (cQry)->(Eof()) = .F.

				cCmd := Posicione("SF4", 1, FwxFilial("SF4") + (cQry)->D1_TES, "F4_FORMULA")

				cCmd := Posicione("SM4", 1, FwxFilial("SM4") + cCmd, "M4_XMSG")

				cMensFis += Alltrim(cCmd)

				(cQry)->(DbSkip())
			EndDo
			(cQry)->(DbCloseArea())

			// tratar  o PIS eo COFINS
			cMensFis += '; PIS: '    + Alltrim(Transform(SF1->F1_VALIMP6, X3Picture("F1_VALIMP6")))
			cMensFis += '  COFINS: ' + Alltrim(Transform(SF1->F1_VALIMP5, X3Picture("F1_VALIMP5")))

			//Se é importação de CBU, tem que preencher os dados da prod / infAdProd

			cCmd := Posicione("SW6", 1, SF1->F1_FILIAL + SF1->F1_HAWB, "W6_XTIPIMP")

			If Posicione("ZZ8", 1, FwxFilial("ZZ8") + cCmd, "ZZ8_TIPO") = "000005"

				ConOut("SF1 - Notas de Importação "  + SF1->F1_DOC + " SERIE: " + SF1->F1_SERIE + " OBTER DADOS DA TAG INFADICIONAL VEICULO" )

				cCmd :=        " SELECT "
				cCmd += CRLF + "   VE1_DESMAR,"
				cCmd += CRLF + "   VVB_DESCRI,"
				cCmd += CRLF + "   VVB_DESCRI,"
				cCmd += CRLF + "   VV2_QTDPAS,"
				cCmd += CRLF + "   VVC_DESCRI,"
				cCmd += CRLF + "   CD9_TPCOMB,"
				cCmd += CRLF + "   CD9_CHASSI,"
				cCmd += CRLF + "   WN_ANOFAB ,"
				cCmd += CRLF + "   WN_ANOMOD ,"
				cCmd += CRLF + "   CD9_SERIAL,"
				cCmd += CRLF + "   W9_DT_EMIS,"
				cCmd += CRLF + "   WN_INVOICE "
				cCmd += CRLF + "  FROM " + RetSQLName("SD1")
				cCmd += CRLF + "  INNER JOIN " + RetSQLName("CD9") + "  ON CD9010.D_E_L_E_T_ = ' ' AND CD9_FILIAL = D1_FILIAL AND CD9_DOC = D1_DOC"
				cCmd += CRLF + "            AND CD9_SERIE = D1_SERIE AND CD9_CLIFOR = D1_FORNECE AND CD9_LOJA = D1_LOJA"
				cCmd += CRLF + "  LEFT JOIN " + RetSQLName("VV2") + "  ON VV2010.D_E_L_E_T_ = ' ' AND VV2_PRODUT = D1_COD"
				cCmd += CRLF + "  LEFT JOIN " + RetSQLName("VE1") + "  ON VE1010.D_E_L_E_T_ = ' ' AND VE1_CODMAR = VV2_CODMAR"
				cCmd += CRLF + "  LEFT JOIN " + RetSQLName("VVB") + "  ON VVB010.D_E_L_E_T_ = ' ' AND VVB_CATVEI = VV2_CATVEI"
				cCmd += CRLF + "  LEFT JOIN " + RetSQLName("VVC") + "  ON VVC010.D_E_L_E_T_ = ' ' AND VV2_CODMAR = VVC_CODMAR AND VVC_CORVEI = VV2_COREXT"
				cCmd += CRLF + "  LEFT JOIN " + RetSQLName("SWN") + "  ON SWN010.D_E_L_E_T_ = ' ' AND WN_FILIAL  = D1_FILIAL  AND WN_DOC = D1_DOC AND WN_SERIE = D1_SERIE"
				cCmd += CRLF + " 	    AND WN_FORNECE = D1_FORNECE AND WN_LOJA = D1_LOJA AND WN_XVIN = D1_CHASSI "
				cCmd += CRLF + "  LEFT  JOIN " + RetSQLName("SW9") + "  ON SW9010.D_E_L_E_T_ = ' ' AND W9_FILIAL = WN_FILIAL AND W9_INVOICE = WN_INVOICE"
				cCmd += CRLF + "  WHERE "
				cCmd += CRLF + "       SD1010.D_E_L_E_T_ = ' ' "
				cCmd += CRLF + "  AND D1_FILIAL = '" + SF1->F1_FILIAL  + "' "
				cCmd += CRLF + "  AND D1_DOC    = '" + SF1->F1_DOC     + "' "
				cCmd += CRLF + "  AND D1_SERIE  = '" + SF1->F1_SERIE   + "' "
				cCmd += CRLF + "  AND D1_FORNECE= '" + SF1->F1_FORNECE + "' "
				cCmd += CRLF + "  AND D1_LOJA   = '" + SF1->F1_LOJA    + "' "
				cCmd += CRLF + "  AND ROWNUM <= 1 "
				cCmd += CRLF + "  ORDER BY D1_ITEM "

				I := 1
				cQry := GetNextAlias()
				TcQuery cCmd new alias (cQry)
				While (cQry)->(Eof()) = .F.
					ConOut("SF1 - Notas de Importação "  + SF1->F1_DOC + " SERIE: " + SF1->F1_SERIE + " MONTAGEM DA TAG INFADICIONAL VEICULO" )

					aProd[I, 25] := " Renavan: 0000000000"
					aProd[I, 25] += " Marca:" + Alltrim((cQry)->VE1_DESMAR)
					aProd[I, 25] += " Tipo:"  + Alltrim((cQry)->VVB_DESCRI)
					aProd[I, 25] += " Motor:" + Alltrim((cQry)->CD9_SERIAL)
					aProd[I, 25] += " Pass:"  + CvalTochar((cQry)->VV2_QTDPAS)
					aProd[I, 25] += " Combu:" + Alltrim(aComb[aScan(aComb,{|x| x[1] == (cQry)->CD9_TPCOMB})][02])
					aProd[I, 25] += " Cor:"   + Alltrim((cQry)->VVC_DESCRI)
					aProd[I, 25] += " Chassi:"+ Alltrim((cQry)->CD9_CHASSI)
					aProd[I, 25] += " Fab:"   + Substr((cQry)->WN_ANOFAB, 1, 4)
					aProd[I, 25] += " Mod:"   + Substr((cQry)->WN_ANOMOD, 1, 4)
					aProd[I, 25] += " Serie:" + Right(Alltrim((cQry)->CD9_CHASSI), 8)
					aProd[I, 25] += " Di:"    + Alltrim((cQry)->WN_INVOICE)
					aProd[I, 25] += " DtDi:"  + Dtoc(sTod((cQry)->W9_DT_EMIS))

					I++
					(cQry)->(DbSkip())
				EndDo
				(cQry)->(DbCloseArea())
			EndIf
		EndIf
	EndIf


	If Vazio(GetAdvFVal("SF1", "F1_XMSGADI", xFilial("SF1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA , 1, "")) = .F.
		SF1->(DbSetOrder(1))
		SF1->(DbSeek(xFilial("SF1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))

		SD1->(DbSetOrder(1))
		SD1->(DbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))

		cContainer := SD1->D1_XCONT

		cCmd := CRLF + " SELECT DISTINCT F1_SERIE, F1_DOC, ZM_INVOICE, W8_HAWB "
		cCmd += CRLF + " FROM " + RetSqlName("SZM") + " SZM "
		cCmd += CRLF + " LEFT JOIN " + RetSqlName("SW8") + " SW8 ON SW8.D_E_L_E_T_ = ' ' AND W8_INVOICE = ZM_INVOICE "
		cCmd += CRLF + " LEFT JOIN " + RetSqlName("SF1") + " SF1 ON SF1.D_E_L_E_T_ = ' ' AND W8_FILIAL = F1_FILIAL AND W8_FORN = F1_FORNECE AND W8_FORLOJ = F1_LOJA AND F1_HAWB = W8_HAWB "
		cCmd += CRLF + " WHERE "
		cCmd += CRLF + " SZM.D_E_L_E_T_ = ' ' "
		cCmd += CRLF + " AND ZM_CONT = '" + cContainer + "' "
		cCmd += CRLF + " ORDER BY F1_DOC

		TcQuery cCmd new alias (cQry)
		(cQry)->(DbGoTop()) = .F.

		cMensCli += "  Desembarque: " + Alltrim((cQry)->W8_HAWB) + " Container: " + Alltrim(cContainer) + " Impostos recolhidos na(s) Nota(s) fiscal(is) Ser/Doc: "

		While (cQry)->(Eof()) = .F.

			cMensCli += Alltrim((cQry)->F1_SERIE) + "/" + (cQry)->F1_DOC + "  "

			(cQry)->(DbSkip())
		EndDo
		(cQry)->(DbCloseArea())

		cMensCli := SubStr(cMensCli, 1, Len(cMensCli)-2)

		cMensCli += " Valores dos impostos: " + Alltrim(SF1->F1_XMSGADI)

		aDetPag[1,1] := "90" // sem pagamento

		aEspVol := {{                    ;
			"Container"			  ,;
			1         			  ,;
			SF1->F1_PLIQUI			  ,;
			SF1->F1_PBRUTO			  ,;
			SubStr(cContainer, 1,  4)  ,;
			SubStr(cContainer, 5, 10)   ;
			}}

	Endif

	aadd(aRetorno,aProd)
	aadd(aRetorno,cMensCli)
	aadd(aRetorno,cMensFis)
	aadd(aRetorno,aDest)
	aadd(aRetorno,aNota)
	aadd(aRetorno,aInfoItem)
	aadd(aRetorno,aDupl)
	aadd(aRetorno,aTransp)
	aadd(aRetorno,aEntrega)
	aadd(aRetorno,aRetirada)
	aadd(aRetorno,aVeiculo)
	aadd(aRetorno,aReboque)
	aadd(aRetorno,aNfVincRur)
	aadd(aRetorno,aEspVol) // 14
	aadd(aRetorno,aNfVinc)
	aadd(aRetorno,aDetPag)
	aadd(aRetorno,aObsCont)

	RestArea(aAreaSF2)
	RestArea(aAreaCD9)
	RestArea(aAreaSD2)
	RestArea(aAreaSC6)
	RestArea(aAreaSC5)
	RestArea(aAreaSF4)
	RestArea(aAreaSM4)
	RestArea(aAreaSD1)
	RestArea(aAreaSA1)
	RestArea(aAreaSA2)
	RestArea(aAreaVV1)
	RestArea(aAreaVV2)
// Importação
	RestArea(aAreaSF1)
	RestArea(aAreaSW6)
	RestArea(aAreaEIH)
	RestArea(aAreaSJF)
	RestArea(aAreaSW9)
	RestArea(aAreaSWV)
	RestArea(aAreaSWD)
	RestArea(aAreaSYB)
	RestArea(aAreaVV0)

	RestArea(aArea)


	ConOut("PE01NFESEFAZ - INICIO - NF: " + aNota[2] + " Serie: " + aNota[1] )

Return aRetorno

Static Function DeParaComb( cCombVV1 )

	Local cRetorno := ""

	Conout(" ")
	Conout(" DeParaComb ")
	Conout(" ")

	Do Case
	Case cCombVV1 == "0" ; cRetorno := "02" // Gasolina
	Case cCombVV1 == "1" ; cRetorno := "01" // Alcool
	Case cCombVV1 == "2" ; cRetorno := "03" // Diesel
	Case cCombVV1 == "3" ; cRetorno := "15" // Gas Natural
	Case cCombVV1 == "4" ; cRetorno := "16" // Alcool/Gasolina
	Case cCombVV1 == "5" ; cRetorno := "17" // Alcool/Gasolina/GNV
	Case cCombVV1 == "9" ; cRetorno := ""   // Sem Combustivel
	Case cCombVV1 == "A" ; cRetorno := "04" // Gasogenio
	Case cCombVV1 == "B" ; cRetorno := "05" // Gas Metano
	Case cCombVV1 == "C" ; cRetorno := "06" // Eletrico/Fonte Interna
	Case cCombVV1 == "D" ; cRetorno := "07" // Eletrico/Fonte Externa
	Case cCombVV1 == "E" ; cRetorno := "08" // Gasol/Gas Natural Combustivel
	Case cCombVV1 == "F" ; cRetorno := "09" // Alcool/Gas Natural Combustivel
	Case cCombVV1 == "G" ; cRetorno := "10" // Diesel/Gas Natural Combustivel
	Case cCombVV1 == "H" ; cRetorno := "12" // Alcool/Gas Natural Veicular
	Case cCombVV1 == "I" ; cRetorno := "13" // Gasolina/Gas Natural Veicular
	Case cCombVV1 == "J" ; cRetorno := "14" // Diesel/Gas Natural Veicular
	Case cCombVV1 == "K" ; cRetorno := "18" // Gasolina/Eletrico
	Case cCombVV1 == "L" ; cRetorno := "19" // Gasolina/Alcool/Eletrico
	EndCase

Return cRetorno
