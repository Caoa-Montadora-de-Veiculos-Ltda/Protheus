#include 'TOTVS.CH'
#include 'protheus.ch'
#include 'topconn.ch'

/*/{Protheus.doc} ADVPLPRTETI
(long_description)
@author danielbraga
@since 07/09/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/

#DEFINE IMP_DIRETO_PORTA "1"
#DEFINE IMP_SPOOL "2"
#DEFINE IMP_MS_DOS "3"

class ADVPLPRTETI 
	data cCode as String

	method ADVPLPRTETI() constructor
	method print()
	method formatValue(cField,xVal)
	method getExpression()
	method executeExpression(cEtiqueta)
	method loadParameter(cQuery)
	method loadPergunte(cPerg) 
	method loadFields(cEtiqueta)
	method printDirectPort(cModelo,cPorta, cEtiqueta,nQtdCpoia)
	method printMsDos(cEtiqueta,cPorta)
	method printSpool(cCodigo)
	method dialogCopy()
	
	method getCode() 
	method setCode(xValue) 

endclass

/*/{Protheus.doc} new
Metodo construtor
@author danielbraga
@since 07/09/2016 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method ADVPLPRTETI() class ADVPLPRTETI
	::cCode := ""
return

method getCode()  class ADVPLPRTETI
return ::cCode

method setCode(xValue) class ADVPLPRTETI
	::cCode := xValue
return 
method getExpression(cString) class ADVPLPRTETI
	
	
	local nPos    := 0
	local aExp    := {}
	local cExp    := ""
	local nRest   := 0
	local nI      := 0
	local nCont   := 0
	default cString := ""
	
	for nI := 1 to Len(cString)
		
		if SUBSTR(cString,nI,1) == "#"
			nCont +=1
			nRest := nCont  % 2
			
			if nRest != 0
				nPos := nI
			else 
				cExp := substr(cString,nPos+1,(nI-nPos)-1)
				aadd(aExp,cExp)
				nCont:=0
			endIf
		endIf
	    
	next nI
return aExp

method executeExpression(cEtiqueta) class ADVPLPRTETI
	
	local aExp := ::getExpression(cEtiqueta)
	local nI   := 0 
	local cExp := ""
	
	for nI := 1 to len(aExp)
	  IF substr(aExp[nI],1,5) = "#Exp:"
	    //#exp:u_funcao()#
	
		cExp := STRTOKARR(aExp[nI],":")[2]   	
		
		cEtiqueta := strTran(cEtiqueta,"#"+aExp[nI]+"#" , ::formatValue( &(cExp) ) )
	  EndIf
	next nI  

return cEtiqueta

method loadParameter(cQuery) class ADVPLPRTETI
	
	local cParam := "" 
	local nX     := 0
	
	if !Empty(cQuery)
		for nX := 1 to 30 
			cParam :=  iif( nX > 9 , "MV_PAR"+cValToChar(nX) , "MV_PAR0"+cValToChar(nX))
			cQuery := strTran(cQuery,"#"+cParam+"#" , &(cParam) )
			next nX
    else
    	 Help( ,, 'Help',, 'Informe a query no cadastro de etiqueta! ', 1, 0 )
    endIf

return cQuery

method loadPergunte(cPerg)  class ADVPLPRTETI

	&& Perguntas
	if ( findFunction(cPerg) == .f. )
		return  pergunte(allTrim(cPerg),.t.)
	else	
		return  eval(cPerg)
	endIf

return .f.

method loadFields(cEtiqueta) class ADVPLPRTETI

	local nI := 0 
	local cFieldName := ""
	local xValue     := ""
	
	// Percorre Variáveis
	if !empty(cEtiqueta)
		for nI:=  1 to (cAlias)->(FCount())
		
			&& Substituição das Variáveis
			cFieldName := (cAlias)->(fieldName(nI))
			xValue     := ::formatValue( (cAlias)->(fieldGet(nI)) )
			cEtiqueta  := strTran(cEtiqueta,cFieldName,allTrim(xValue))
		
		next nI
	else 
		 Help( ,, 'Help',, 'Informe a etiqueta no cadastro de etiqueta! ', 1, 0 )
	endIf	

return  cEtiqueta

method printDirectPort(cModelo,cPorta, cEtiqueta,nQtdCpoia) class ADVPLPRTETI
	
	default cModelo    := ""
	default cPorta     := ""
	default cEtiqueta  := ""
	default nQtdCpoia  := 1
	
	MSCBPRINTER(allTrim(cModelo),allTrim(cPorta),,,.F.,,,,,,.T.)
	MSCBCHKSTATUS(.T.)
	MSCBBEGIN(1,6)
	MSCBWRITE(cEtiqueta)
	MSCBEND()
	MSCBCLOSEPRINTER()

return 

method printMsDos(cEtiqueta,cPorta,nQtdCpoia) class ADVPLPRTETI
	
	
	default cEtiqueta 	:= ""
	default cPorta 		:= ""
	default nQtdCpoia 	:= 1
	
	memowrite("c:\totvs\etiqueta_.prn",cEtiqueta)
	//WinExec("print c:\totvs\etiqueta.prn "+allTrim(cPorta))
					
    MsgAlert("Etiqueta gerada. C:\TOTVS\etiqueta_.prn")
return 


method printSpool(cCodigo,nQtdCpoia) class ADVPLPRTETI

	local lRet := .f.
	
	default cCodigo := ""
	default nQtdCpoia := 1
	
	lRet := CB5SetImp(cCodigo,.F.,Nil,Nil,Nil)
	
	if lRet
		MSCBBEGIN(nQtdCpoia,6)
		MSCBWRITE(cEtiqueta)
		MSCBEND()
		MSCBCLOSEPRINTER()
	else
		Help( ,, 'Help',, 'Fila do Spool não encontrado ! ', 1, 0 )
	endIf

return 


method dialogCopy(nCopias) class ADVPLPRTETI 

	local oSize      := " "
	local oDlgEnt    := nil
		
	private lOk      := .t.
	
	default  nCopias := 1

    oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 20, .T., .T. ) // Adiciona enchoice
	
	oSize:SetWindowSize({000, 000, 180, 420})
	
	oSize:lLateral   := .F.  // Calculo vertical	
	oSize:Process()          //executa os calculos
	
	DEFINE MSDIALOG oDlgEnt TITLE "Cópias" ;
							FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
							  TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
							     COLORS 0, 16777215 PIXEL
	oDlgEnt:lEscClose := .F.
	
	@ 47,50  Say "Nr. Cópias" Of oDlgEnt COLOR CLR_BLACK Pixel               //"Data Entrega: "
	@ 45,95  MSGET nCopias SIZE 55,11 Picture "@E 999" Of oDlgEnt When .T.   Pixel hasbutton 
   	  
	ACTIVATE MSDIALOG oDlgEnt ON INIT EnchoiceBar(oDlgEnt,{|| oDlgEnt:End()},{|| lOk := .f. ,oDlgEnt:End() },,) CENTERED 

return lOK //lCancela


method print() class ADVPLPRTETI
	
	local cCode 		:= ::getCode()
	local cPerg  		:= ""
	local lContinua 	:= .f.
	local cQuery		:= ""
	local cPorta		:= ""
	local cParam		:= ""
	local cModelo		:= ""
	local nDir			:= 0
	local nQtdCpoia		:= 1
	local lCancela      := .f.
	local cCodFila      :=""
	local lImp			:= .t.
	
	private  cAlias		:= getNextAlias()
	
	dbSelectArea("ZA1")
	ZA1->(dbSetOrder(1))
	if ZA1->(dbSeek(xFilial("ZA1") + cCode))
		
		cPerg 		:= ZA1->ZA1_PERGUN
		cQuery 		:= ZA1->ZA1_QUERY
		cEtiqueta 	:= ZA1->ZA1_ETIQUE
		cPorta    	:= ZA1->ZA1_PORTA
		cModelo		:= ZA1->ZA1_MODELO
		cTipoImp    := ZA1->ZA1_TPIMP
		cCodFila    := ZA1->ZA1_FILA
		cInfQtd		:= ZA1->ZA1_IFETDC
		
		&& Diretórios
		If !ExistDir("C:\totvs")
			nDir := MakeDir("C:\totvs")
		Else
			nDir := 0
			Conout( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
		Endif
					
		&& Perguntas
		lContinua := ::loadPergunte(cPerg)
		
		if lContinua 
		    
		    cQuery := ::loadParameter(cQuery)
		    
			tcQuery cQuery new Alias (cAlias)
			
			if  (cAlias)->(!EOF())
				if cInfQtd == 1
					lImp := ::dialogCopy(@nQtdCpoia)
				endIf
				if lImp
			
					 While (cAlias)->(!Eof())
					
						// Recarrega Etiqueta com as Variáveis
						cEtiqueta 	:= ZA1->ZA1_ETIQUE
					
						// Percorre Variáveis
						cEtiqueta :=  ::loadFields(cEtiqueta)
						
						//Executa expresssos
						cEtiqueta := ::executeExpression(cEtiqueta)
						if cTipoImp == IMP_DIRETO_PORTA
							::printDirectPort(cModelo,cPorta, cEtiqueta,nil)
						elseIf cTipoImp == IMP_SPOOL
							::printSpool(cCodFila,nQtdCpoia)
						else 
							::printMsDos(cEtiqueta,cPorta,nQtdCpoia)
                            

						endIf	
						
					 (cAlias)->(dbSkip())								
					 EndDo
				else 
				 	Help( ,, 'Help',, 'Impressão cancela  ! ', 1, 0 )
				endIf 
				
			else 
				Help( ,, 'Help',, 'Não há Informações para Impressão! ', 1, 0 )
			endIf		

			&& Fecha Área
			(cAlias)->(dbCloseArea())
		else 
			Help( ,, 'Help',, 'Pergunte ou parambox não existe! ', 1, 0 )	
		endIf

		
	else 
	   Help( ,, 'Help',, 'Template impressão não encontrado! ', 1, 0 )
	endIf
	
return 

method formatValue(xVal) class ADVPLPRTETI
	
	local xValue := nil
	
	if valType(xVal) == "D"
		xValue := dtoc(sToD(xVal))
	elseif valType(xVal)  == "N"
		xValue := cValToChar(xVal)
	else 
		xValue :=  xVal
	endIf	

return xValue

static  Function InfoSX3(cCampo)
	Local	aAliasSX3	:=	SX3->(GetArea())
	Local	aRetorno	:=	{0,0,""}

	SX3->(DbSetOrder(2))
	SX3->(DbSeek(cCampo))

	If SX3->(Found())
		aRetorno[1] := SX3->X3_TAMANHO
		aRetorno[2] := SX3->X3_DECIMAL
		aRetorno[3] := SX3->X3_TIPO
	EndIf

	RestArea(aAliasSX3)

Return(aRetorno)

User Function PrtTmpl(cCodigo)
	
	local oObj := ADVPLPRTETI():ADVPLPRTETI()
	
	oObj:setCode(cCodigo)
	oObj:print()
	
return


user function buscaTexto()
	
	local oSize := ""
	local oDlgEnt := nil
	local nCopias := 1
	private lCancela := .f.

    oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 20, .T., .T. ) // Adiciona enchoice
	
	oSize:SetWindowSize({000, 000, 180, 420})
	
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos
	
	DEFINE MSDIALOG oDlgEnt TITLE "Cópias" ;
							FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
							TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
							COLORS 0, 16777215 PIXEL
	oDlgEnt:lEscClose := .F.
	

	@ 47,50  Say "Nr. Cópias" Of oDlgEnt COLOR CLR_BLACK Pixel //"Data Entrega: "
	@ 45,95  MSGET nCopias SIZE 55,11 Picture "@E 999" Of oDlgEnt When .T.   Pixel hasbutton 
   	  


	ACTIVATE MSDIALOG oDlgEnt ON INIT EnchoiceBar(oDlgEnt,{|| oDlgEnt:End()},{|| lCancela := .t. ,oDlgEnt:End() },,) CENTERED  //"Deseja cancelar esse processo?"
return 
