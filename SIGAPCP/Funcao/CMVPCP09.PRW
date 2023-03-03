#INCLUDE "PROTHEUS.CH"
#include 'parmtype.ch'
#include 'topconn.ch'
#INCLUDE "TBICONN.CH"
/*
=====================================================================================
Programa.:              CMVPCP09
Autor....:              Atilio Amarilla
Data.....:              01/03/2019
Descricao / Objetivo:   Envio de informações adicionais (tags) na integração Totvs-MES
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP TOTVS-MES
Obs......:              Objetivo: Envio de dados adicionais. Chamado por PE PCPADDTAGS
=====================================================================================
*/
User Function CMVPCP09()   

Local cRet := ""
Local cTransac 	:= PARAMIXB[1] // Transação que está sendo trafegada. Ex: Item.
Local cEvent 	:= PARAMIXB[2] // Evento da transação. upsert/delete.
Local cPont 	:= PARAMIXB[3] // Ponteiro para recuperar as informações da transação. Ex: &(cPont+"B1_COD") -> retorna o código do produto.

/*
If UPPER(AllTrim(cTransac)) == "ITEM" //Trafegando a mensagem de Produtos.
	If UPPER(AllTrim(cEvent)) == "UPSERT" //Atualizando ou Incluindo um produto.
		cRet := "<XDESCRIC>" + xEncDesc(&(cPont+"B1_ALERGE2")) + "</XDESCRIC>"
		cRet += "<XALERGMP>" + xEncAlerg(&(cPont+"B1_COD")) + "</XALERGMP>"
	EndIf
ElseIf UPPER(alltrim(cTransac)) == "PRODUCTIONORDER"
*/
If UPPER(alltrim(cTransac)) == "PRODUCTIONORDER"
	If UPPER(AllTrim(cEvent)) == "UPSERT"
		
		cRet += "<XBARCODE>" + &(cPont+"->C2_XBARCOD") + "</XBARCODE>"

	EndIf
EndIF

Return( cRet )
