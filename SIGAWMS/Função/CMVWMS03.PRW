#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"           
/*
=====================================================================================
Programa.:              CMVWMS03
Autor....:              Atilio Amarilla
Data.....:              07/05/2019
Descricao / Objetivo:   Integração PROTHEUS - PCP x MES x WMS - Requisição Automática
Doc. Origem:            Contrato - GAP WMS003
Solicitante:            Cliente
Uso......:              CAOA
Obs......:              Requisições para empenhos. Atualização de Local de origem
						Chamado por PE WMSA508LO
=====================================================================================
*/

User Function CMVWMS03()

	Local lPE		:= GetMV("CMV_WMS03A",,.T.)
	Local cRet		:= ParamIXB[1]
	Local cProduto	:= ParamIXB[2]
	Local cArmOri	:= GetMV("CMV_WMS02C",,"")  			// Armazem de Origem
	Local cCpoArm	:= GetMV("CMV_WMS02D",,"B1_XLOCARM")	// Campo Armazem de Origem
	Local cQuery	:= ""

	If lPE
		/*
		If Empty(cArmOri)
			cArmOri	:= GetAdvFVal("SB1",cCpoArm,xFilial("SB1")+cProduto,1,CriaVar(cCpoArm))
		EndIf
		If !Empty(cArmOri)
			cRet	:= cArmOri
		EndIf
		*/
		If Empty(cArmOri)

			cQuery += "SELECT "+cCpoArm+" ARMORI "
			cQuery += "FROM "+RetSQLName("SB1")+" "
			cQuery += "WHERE D_E_L_E_T_ = ' ' "
			cQuery += "	AND B1_FILIAL = '"+xFilial("SB1")+"' "
			cQuery += " AND B1_COD = '"+cProduto+"' "
			
			If Select("WMS03") > 0
				WMS03->(dbCloseArea())
			EndIf
			
			cQuery  := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"WMS03",.T.,.F.)
			
			dbSelectArea("WMS03")
			WMS03->(dbGoTop())
			If WMS03->(!EOF())
				
				If !Empty(WMS03->ARMORI)
					cRet	:= WMS03->ARMORI
				EndIf

			EndIf

		EndIf
		 
	EndIf

	ConOut(FWTimeStamp(1)+"-cRet Ini/Fin "+ParamIXB[1]+"/"+cRet+"-cProduto "+AllTrim(cProduto)+"-cCpoArm "+cCpoArm)

Return cRet