#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} HISTSC7
Fun��o para apresentar o historico de altera��o no Pedido de Compras.
@author FSW - DWC Consult
@since 21/03/2019
@version 1.0
@type function
/*/
User Function HISTSC7()
	Local cTitulo	:= ""
	Local cChvSC7	:= ""
	Local aMVHist	:= & (SuperGetMV("CAOA_HISTA",,{ .T.,.T.,.T. } ))
	Local oHistAlt	:= Nil
	Local aArea		:= GetArea()
	
	cTitulo := 'Hist�rico de atualiza��es do Pedido nr.: ' + SC7->C7_NUM
	cChvSC7 := SC7->C7_FILIAL + SC7->C7_NUM
	
	//Classe responsavel pela apresenta��o.
	oHistAlt := CLASCOMP():New()
	oHistAlt:HistAlteracao(cChvSC7,cTitulo,aMVHist[1],aMVHist[2],aMVHist[3])
	
	RestArea(aArea)
Return