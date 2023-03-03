#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} HISTSC8
Fun��o para apresentar o historico de altera��o nos Contratos.
@author FSW - DWC Consult
@since 21/03/2019
@version 1.0
@type function
/*/
User Function HISTSC3()
	Local cTitulo	:= ""
	Local cChvSC3	:= ""
	Local aMVHist	:= & (SuperGetMV("CAOA_HISTA",,{ .T.,.T.,.T. } ))
	Local oHistAlt	:= Nil
	Local aArea		:= GetArea()
	
	cTitulo := 'Hist�rico de atualiza��es da Contrato nr.: ' + SC3->C3_NUM
	cChvSC3 := SC3->C3_FILIAL + SC3->C3_NUM
	
	//Classe responsavel pela apresenta��o.
	oHistAlt := CLASCOMP():New()
	oHistAlt:HistAlteracao(cChvSC3,cTitulo,aMVHist[1],aMVHist[2],aMVHist[3])
	
	RestArea(aArea)
Return