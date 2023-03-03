#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} HISTSC1
Fun��o para apresentar o historico de altera��o nas Solicita��es de Compras.
@author FSW - DWC Consult
@since 22/03/2019
@version 1.0
@type function
/*/
User Function HISTSC1()
	Local cTitulo	:= ""
	Local cChvSC1	:= ""
	Local aMVHist	:= & (SuperGetMV("CAOA_HISTA",,{ .T.,.T.,.T. } ))
	Local oHistAlt	:= Nil
	Local aArea		:= GetArea()
	
	cTitulo := 'Hist�rico de atualiza��es da Solicita��o nr.: ' + SC1->C1_NUM
	cChvSC1 := SC1->C1_FILIAL + SC1->C1_NUM
	
	//Classe responsavel pela apresenta��o.
	oHistAlt := CLASCOMP():New()
	oHistAlt:HistAlteracao(cChvSC1,cTitulo,aMVHist[1],aMVHist[2],aMVHist[3])
	
	RestArea(aArea)
Return