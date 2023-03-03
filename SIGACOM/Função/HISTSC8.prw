#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} HISTSC8
Fun��o para apresentar o historico de altera��o nas Cota��es.
@author FSW - DWC Consult
@since 21/03/2019
@version 1.0
@type function
/*/
User Function HISTSC8()
	Local cTitulo	:= ""
	Local cChvSC8	:= ""
	Local aMVHist	:= & (SuperGetMV("CAOA_HISTA",,{ .T.,.T.,.T. } ))
	Local oHistAlt	:= Nil
	Local aArea		:= GetArea()
	
	cTitulo := 'Hist�rico de atualiza��es da Cota��o nr.: ' + SC8->C8_NUM
	cChvSC8 := SC8->C8_FILIAL + SC8->C8_NUM
	
	//Classe responsavel pela apresenta��o.
	oHistAlt := CLASCOMP():New()
	oHistAlt:HistAlteracao(cChvSC8,cTitulo,aMVHist[1],aMVHist[2],aMVHist[3])
	
	RestArea(aArea)
Return