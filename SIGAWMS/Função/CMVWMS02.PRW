#INCLUDE "PROTHEUS.CH"
/*
=====================================================================================
Programa.:              CMVWMS02
Autor....:              Atilio Amarilla
Data.....:              28/02/2019
Descricao / Objetivo:   Informar local de origem e regra para requisi��o WMSA505
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP WMS003 - Chamado por PE WMS505PR
Obs......:              Objetivo: Retorno de armazem de origem e regra
=====================================================================================
*/
User Function CMVWMS02(aArrayPRD)

	Local lPE		:= GetMV("CMV_WMS02A",,.T.)
	Local cRegra	:= GetMV("CMV_WMS02B",,"3")
	Local cArmOri	:= GetMV("CMV_WMS02C",,"")				// Armazem de Origem
	Local cCpoArm	:= GetMV("CMV_WMS02D",,"B1_XLOCARM")	// Campo Armazem de Origem

	Local aRet		:= Array(8)

	/*/
	Layout do aRet:
	[1]: Marca (l�gico)
	[2]: C�d. Serv. Requisi��o (caractere)
	[3]: Regra WMS (caractere)
	[4]: Armaz�m origem (caractere)
	[5]: Endere�o origem (caractere)
	[6]: Endere�o destino (caractere)
	[7]: Quantidade a solicitar (numerico)
	[8]: Quantidade a solicitar 2a UM (numerico)


	aArrayPRD[1] : Marca
	aArrayPRD[2]: Produto
	aArrayPRD[3]: Descri��o
	aArrayPRD[4]: Lote
	aArrayPRD[5]: Sublote
	aArrayPRD[6]: Servi�o Req.
	aArrayPRD[7]: Regra
	aArrayPRD[8]: Armaz�m origem
	aArrayPRD[9]: Endere�o origem
	aArrayPRD[10]: Armaz�m destino
	aArrayPRD[11]: Endere�o destino
	aArrayPRD[12]: Quantidade sumarizada
	aArrayPRD[13]: Quantidade sumarizada 2a UM
	aArrayPRD[14]: Saldo do produto na produ��o
	aArrayPRD[15]: Saldo do produto na produ��o 2a UM
	aArrayPRD[16]: Qtde a solicitar do produto no WMS
	aArrayPRD[17]: Qtde a solicitar do produto no WMS 2a UM
	aArrayPRD[18]: Saldo
	/*/
	If lPE
		// verifica se Produto � controlado pelo WMS
		If "1" == GetAdvFVal("SB5","B5_CTRWMS",xFilial("SB5")+aArrayPRD[2],1,CriaVar("B5_CTRWMS")) // Controla WMS 1 = Sim 

			If Empty(cArmOri)
				cArmOri	:= GetAdvFVal("SB1",cCpoArm,xFilial("SB1")+aArrayPRD[2],1,CriaVar(cCpoArm))
			EndIf
			
			// Atualiza Array
			aRet[1]	:= .T.
			aRet[3]	:= cRegra // Regra
			aRet[4]	:= cArmOri 
			aRet[7]	:= aArrayPRD[12] // Quantidade sumarizada
			aRet[8]	:= aArrayPRD[13] // Quantidade sumarizada 2a UM
		
		EndIf
	EndIf

Return aRet