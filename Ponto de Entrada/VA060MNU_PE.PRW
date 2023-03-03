#include "totvs.ch"
/*
=====================================================================================
Programa.:              VA060MNU
Autor....:              Joni Lima
Data.....:              23/07/2019
Descricao / Objetivo:   PE cria botão na tela de pedidos do SIGAVEI
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP Boleto
Obs......:
=====================================================================================
*/ 
User Function VA060MNU()

	Local aRet := {}

	If FindFunction("U_RF01B062")
		aAdd(aRet,{"Boleto","U_xGBolVei",	0, 4 })
	EndIF

	// Só executa quando é realizado pela Rotina VEIA060 - Pedido de Venda Montadora ( SigaVEI ).
	// Dispara a integração do Autoware de forma automática.
	If FindFunction("U_ZVEIF003")
		aAdd(aRet,  {"Envio Autoware","U_ZVEIF003()",	0, 4 })
	EndIf

	If ExistFunc("U_tstZonaFranca")
		Aadd( aRet, { "Teste Zona Franca de Manaus", "U_tstZonaFranca", 0, 2, 0,,, })
	EndIf
	
	If FindFunction("U_ZVEIF004")
	   aAdd(aRet,   {"Atualizar Preços Tabela","U_ZVEIF004()",	0, 4 })
    Endif

Return aRet

User Function xGBolVei()

	Local aArea		:= GetArea()
	Local aAreaVRJ	:= VRJ->(GetArea())
	Local aAreaSE1	:= SE1->(GetArea())
	Local cPerg		:= "CMVBOLVEI"

	ValidPerg(cPerg)

	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->(dbSeek(xFilial("SE1") + "PVM" + VRJ->VRJ_PEDIDO))
		If Pergunte(cPerg)
			U_RF01B062(/*xBanco*/MV_PAR02,/*xAgencia*/MV_PAR03,/*xConta*/MV_PAR04,/*xSubCt*/MV_PAR01,/*lSetup*/,/*cNotIni*/,/*cNotFim*/,/*cSerie*/,SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM))
		EndIf
	else
		Alert("Não Existe Titulo para esse Pedido ")
	EndIf
	//RF01B062

	RestArea(aAreaSE1)
	RestArea(aAreaVRJ)
	RestArea(aArea)

Return

Static Function ValidPerg(cPerg)

	Local _sAlias := Alias()
	Local aRegs   := {}
	Local i,j

	dbSelectArea("SX1")
	dbSetOrder(1)

	cPerg := PADR(cPerg,10)
	aAdd(aRegs,{cPerg,"01","SubConta       ?","","","mv_ch1","C",3,0,1,"G" ,"","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Banco          ?","","","mv_ch2","C",3,0,1,"G" ,"","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","","",""})
	aAdd(aRegs,{cPerg,"03","Agencia        ?","","","mv_ch3","C",5,0,1,"G" ,"","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Conta          ?","","","mv_ch4","C",10,0,1,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	//aAdd(aRegs,{cPerg,"20","Env.E-mail     ?","","","mv_chk","N",1,0,2,"C","","MV_PAR20","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)


Return()
