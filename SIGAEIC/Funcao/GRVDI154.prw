#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} GRVDI154
Função para gravar as informações especificas da CAOA na NF de Entrada.
@author FSW - DWC Consult
@since 21/03/2019
@version 1.0
@type function
/*/
User Function GRVDI154()
	Local cAliSD1	:= GetNextAlias()
	Local aArea     := GetArea()
	Local aAreaSF1	:= SF1->(GetArea())
	Local aAreaSD1	:= SD1->(GetArea())
	Local aAreaSWN	:= SWN->(GetArea())
	Local aAreaZZ8	:= ZZ8->(GetArea())
	//Local cChassi	:= ""
	Local lVeic		:= .F.
	Local cQuery    as character
	Local aBind     as array

	aBind := {}

	SF1->(DbSetOrder(5)) //F1_FILIAL+F1_HAWB+F1_TIPO_NF+F1_DOC+F1_SERIE
	SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	SWN->(dbSetOrder(3)) //WN_FILIAL+WN_HAWB+WN_TIPO_NF
	ZZ8->(dbSetOrder(1)) //ZZ8_FILIAL + ZZ8_CODIGO

	//----- SF1 CABEC. NF DE ENTRADA -----//
	//Atualiza com as Inf. da SW6.		  //
	If SF1->(DbSeek(xFilial("SF1") + SW6->W6_HAWB))
		RecLock("SF1",.F.)
		SF1->F1_TIPIMP  := SW6->W6_XTIPIMP
		SF1->F1_XCLAIMP := SW6->W6_XCLAIMP
		SF1->(MsUnlock())
	EndIf

	If ZZ8->(dbSeek(xFilial("ZZ8") + SW6->W6_XTIPIMP)) .and.  AllTrim(ZZ8->ZZ8_TIPO) $ "000005"
		lVeic := .T.
	EndIf

	//----- SD1 ITENS NF DE ENTRADA -----//
	//Atualiza com as Inf. do PC - SC7.	 //
	cQuery := "SELECT "
	cQuery += " D.R_E_C_N_O_ AS RECSD1,"
	cQuery += " C7_CORINT AS CORINT,"
	cQuery += " C7_COREXT AS COREXT,"
	cQuery += " C7_OPCION AS OPCION,"
	cQuery += " C7_ANOFAB AS ANOFAB,"
	cQuery += " C7_ANOMOD AS ANOMOD"
	
	//Removido, pois já esta contemplado no fonte EICDI154 
	//If lVeic
	//	cQuery += ", SWN.WN_XVIN CHASSI"
	//Else
		cQuery += ", '"+Space(Len(SWN->WN_XVIN))+"' CHASSI "
	//EndIf
	
	cQuery += " FROM "+RetSqlName("SD1")+" D "
	cQuery += " INNER JOIN "+RetSqlName("SC7")+" C "
	cQuery += " ON C.C7_FILIAL   = D.D1_FILIAL "
	cQuery += " AND C.C7_NUM     = D.D1_PEDIDO "
	cQuery += " AND C.C7_ITEM    = D.D1_ITEMPC"
	cQuery += " AND C.D_E_L_E_T_ = ?"//- 1
	
	//Removido, pois já esta contemplado no fonte EICDI154 
	/*
	If lVeic
		cQuery += " LEFT JOIN "+RetSqlName("SWN")+" SWN "
		cQuery += " ON SWN.WN_FILIAL   = ?"//-2
		cQuery += " AND SWN.WN_HAWB    = D.D1_CONHEC "
		cQuery += " AND SWN.WN_TIPO_NF = D.D1_TIPO_NF"
		cQuery += " AND SWN.D_E_L_E_T_ = ?"//-3
	EndIf
	*/
	cQuery += " WHERE D.D1_FILIAL = ?"//- 4
	cQuery += " AND D.D1_CONHEC   = ?"//- 5
	cQuery += " AND D.D_E_L_E_T_  = ?"//- 6

	AADD(aBind,Space(1))
	
	//Removido, pois já esta contemplado no fonte EICDI154 
	/*
	If lVeic
		AADD(aBind,xFilial("SWN"))
		AADD(aBind,Space(1))
	EndIf
	*/
	
	AADD(aBind,xFilial('SD1'))
	AADD(aBind,SW6->W6_HAWB)
	AADD(aBind,Space(1))
	
	//Para veiculas CBU não há necessidade de alterar a SD1 Removido, pois já esta contemplado no fonte EICDI154 
	if !lVeic 
		DbUseArea(.T., "TOPCONN", TCGenQry2(Nil, Nil, cQuery, aBind), cAliSD1, .F., .T.)

		While !(cAliSD1)->(EOF())
			SD1->(DbGoTo((cAliSD1)->RECSD1))
	
			RecLock("SD1",.F.)
			SD1->D1_CORINT	:= (cAliSD1)->CORINT
			SD1->D1_COREXT	:= (cAliSD1)->COREXT
			SD1->D1_OPCION	:= (cAliSD1)->OPCION
			SD1->D1_ANOFAB	:= RIGHT((cAliSD1)->ANOFAB,2)
			SD1->D1_XANOFAB	:= (cAliSD1)->ANOFAB
			SD1->D1_ANOMOD	:= (cAliSD1)->ANOMOD
			SD1->D1_CHASSI  := (cAliSD1)->CHASSI

			SD1->(MsUnLock())

			(cAliSD1)->(DbSkip())
		EndDo
		(cAliSD1)->(DbCloseArea())	
	ENDIF
	

	RestArea(aAreaZZ8)
	RestArea(aAreaSWN)
	RestArea(aAreaSD1)
	RestArea(aAreaSF1)
	RestArea(aArea)

	aSize(aAreaZZ8,0)
	aSize(aAreaSWN,0)
	aSize(aAreaSD1,0)
	aSize(aAreaSF1,0)
	aSize(aArea,0)
	aSize(aBind,0)
	
	aBind 	 := Nil
	aAreaSWN := nil 
	aAreaZZ8 := nil 
	aAreaSD1 := nil 
	aAreaSF1 := nil 
	aArea    := nil 

Return
