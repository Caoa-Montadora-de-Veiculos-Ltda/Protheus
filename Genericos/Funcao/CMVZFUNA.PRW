#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
=====================================================================================
Programa.:              CMVZFUNA
Autor....:              Atilio Amarilla
Data.....:              28/02/2016
Descricao / Objetivo:   Fun��es gen�ricas
Doc. Origem:            Contrato - SHAPE
Solicitante:            Cliente
Uso......:              CAOA
Obs......:              Biblioteca de fun��es gen�ricas
=====================================================================================
zMakeDir( cPath , cTitulo )
- Cria��o de pastas usando MakeDir a partir de caminho completo (path)
=====================================================================================
zGeraExce(aColunas,aItens,cArqExc,cPatSrv,cPatLoc,cTitulo)
- Gera planilha excel
=====================================================================================
zLerTxt(cArqTxt)
- Ler arquivo txt e retornar conteudo do arquivo
=====================================================================================
zMontaView(cSql,cAliasTRB)
Executa query (select) e retorna n�mero de registros da tabela de trabalho
=====================================================================================
Controle de Threads

zCriaThreads()
- Cria Arquivo Tempor�rio para controle de threads

zSobeThreads(nNumThr)
- Verifica se nova thread pode ser aberta

zBaixaThreads(cArqThr)
- Informar fim do processamento da thread

=====================================================================================

*/

User Function CMVZFUNA()

Return
/*/{Protheus.doc} zMakeDir
Cria��o de pastas usando MakeDir a partir de caminho completo (path)
@param  	cPath -> Caminho completo a ser criado/verificado, pastas locais ou do server
cTitulo -> Titulo para uso em Aviso()
@author 	Atilio Amarilla
@version  	P11.8
@since  	02/03/2015
@return  	lRet-> Sucesso (.T.) ou Falha (.F.)
@obs
@project	Banco de Horas
@history	Acerto de rotinas IN12 e PP04. Uso de produto alternativo nos Kits
/*/

User Function zMakeDir( cPath , cTitulo )

	Local cAux := ""
	Local aAux, nI
	Local lRet := .T.
	Local aPath	:= StrToKArr(cPath,"\")

	If cTitulo == NIL
		cTitulo := "zMakeDir"
	EndIf

	For nI := 1 To Len( aPath )
		If nI == 1 .And. At(":",aPath[nI]) > 0
			aAux := Directory(aPath[nI]+"\*.*","D")
			cAux	:= aPath[nI]+"\"
			If Len( aAux ) == 0
				Aviso(cTitulo,"Verifique se nome de disco/pasta "+cAux+" � v�lido!",{'Ok'})
				lRet := .F.
				Exit
			EndIf
		ElseIf nI == 1 .And. Subs(cPath,1,2) == "\\"
			aAux := Directory("\\"+aPath[nI]+"*.*","D")
			cAux	:= "\\"+aPath[nI]+"\"
			/*
			If Len( aAux ) == 0
				Aviso(cTitulo,"Verifique se o endere�o do servidor "+cAux+" � v�lido!",{'Ok'})
				lRet := .F.
				Exit
			EndIf
			*/
		Else
			If nI == 1
				cAux := "\"
			EndIf
			aAux := Directory(cAux+aPath[nI],"D")
			cAux += aPath[nI]+"\"
			If aScan(aAux,{|aAux|alltrim(aAux[1]) == aPath[nI] }) == 0
				If MakeDir( cAux ) > 0
					Aviso(cTitulo,"Verifique se nome de disco/pasta "+cAux+" � v�lido!",{'Ok'})
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf
	Next nI

Return lRet

/*/{Protheus.doc} zGeraExcel
Gera planilha excel
@param  	aColunas -> Colunas da planilha
aItens -> Itens/Dados da planilha
cArqExc -> Nome arquivo a ser criado
cPatSrv -> Pasta do server para cria��o da planilha
cPatLoc -> Pasta local para copiar planilha
cTitulo -> Titulo da planilha
@author 	Atilio Amarilla
@version  	P11.8
@since  	02/03/2015
@return  	NIL
@obs
@project
@history
/*/

User Function zGeraExcel(aColunas,aItens,cArqExc,cPatSrv,cPatLoc,cTitulo)

	Local oExcel         := FWMSEXCEL():New()
	Local aLinha         := {}
	Local cWorkSheet     := cTitulo
	Local cTable         := cTitulo

	Local cLinhaXML      :=""
	Local nHXML
	Local cColXML        :=""

	Local oSay1
	Local oButtonOK
	Local oButtonCancela
	Local cTpSald

	local 	_lAll1       := .F.
	local 	_oOk         := LoadBitmap( GetResources(), "LBOK")
	local 	_oNo 	     := LoadBitmap( GetResources(), "LBNO")
	//Local bValid         := {|| Iif(ApOleClient("MsExcel"),.T.,(MsgAlert("MsExcel n�o instalado"),)) }
	Local nX, nY

	cPatSrv	:= IIF(cPatSrv==NIL,"",cPatSrv)
	cPatLoc	:= IIF(cPatLoc==NIL,"",cPatLoc) // GetTempPath()

	If !Empty(cPatSrv)
		If !FWMakeDir( cPatSrv , .T. )
			cPatSrv := ""
		EndIf
	EndIf

	If !Empty(cPatLoc)
		If !FWMakeDir( cPatLoc , .T. )
			cPatLoc := GetTempPath()
		EndIf
	Else
		cPatLoc := GetTempPath()
	EndIf


	//Cria Planilha
	oExcel:AddworkSheet(cWorkSheet)
	//Cria Tabela
	oExcel:AddTable (cWorkSheet,cTable)

	//Adiciona Colunas
	For nX := 1 to Len( aColunas )
		oExcel:AddColumn(cWorkSheet,cTable,aColunas[nX]		,1,1)
	Next nX

	For nX	:= 1 to Len( aItens )
		aLinha	:= {}
		For nY	:= 1 to Len( aItens[nx] )
			aAdd( aLinha , aItens[nX,nY] )
		Next nY
		oExcel:AddRow(cWorkSheet,cTable,aLinha)
	Next nX

	//%%%%%%%%%%%%%%%%%%   TODOS A ESTRUTURA MONTADA %%%%%%%%%%%%%%%%%%%%%%%%%
	//Ativa a planilha e deixa pronta para gerar arquivo.
	oExcel:Activate()

	oExcel:GetXMLFile(cPatSrv+cArqExc)

	If CpyS2T(cPatSrv+cArqExc,cPatLoc)
		//		 MsgInfo( "Arquivo " + cArq + " gerado com sucesso no diret�rio " + cPath )
		If ApOleClient("MsExcel")

			If !"X:" $ AllTrim(cPatLoc)
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( cPatLoc + cArqExc )
				oExcelApp:SetVisible(.T.)              // Abre excel automaticamente .T. // N�o .F.
			//		  oExcel:Destroy()                       // exclui Excel.exe do processo no gerenciador de tarefas
			EndIf
		Else
			Aviso("zGeraExcel","MsExcel n�o instalado"+CRLF+"Planilha "+cArqExc+" copiado para pasta "+cPatLoc+".",{'Ok'})
		EndIf
	else
		Aviso("zGeraExcel","Planilha "+cArqExc+" n�o copiado para pasta "+cPatLoc+"."+CRLF+"Verifique suas permiss�es.",{'Ok'})
	endif
	//   Endif

Return

/*/{Protheus.doc} zLerTxt
Ler arquivo txt e retornar conteudo do arquivo
@param  	cArqTxt -> Path + Nome do Arquivo
@author 	Atilio Amarilla
@version  	P11.8
@since  	10/03/2017
@return  	cRet -> Conte�do do arquivo lido
@obs
@project	Banco de Horas
@history	Acerto de rotinas IN12 e PP04. Uso de produto alternativo nos Kits
/*/
User Function zLerTxt(cArqTxt)

	Local cRet := ""
	Local nHandle

	If !File( cArqTxt )
		cRet += "Arquivo Log n�o localizado: "+cArqTxt
	Else
		If nHandle := FT_FUSE(cArqTxt) > 0
			While !FT_FEOF()
				cRet += Ft_Freadln()

				FT_FSkip()
			EndDo

			FT_FUse()
		Else
			cRet += "N�o foi poss�vel abrir arquivo: "+cArqTxt
		EndIf

	EndIf

Return cRet

/*/{Protheus.doc} zMontaView
Executa query (select) e retorna n�mero de registros da tabela de trabalho
@param  	cSql -> Express�o da query
cAlaisTRB -> Alias do arquivo de trabalho
@author 	Atilio Amarilla
@version  	P11.8
@since  	10/03/2017
@return  	nCnt -> Quantidade de registros selecionados
@obs
@project	Banco de Horas
@history	Acerto de rotinas IN12 e PP04. Uso de produto alternativo nos Kits
/*/
User Function zMontaView( cSql, cAliasTRB )

	Local nCnt := 0
	Local cSql := ChangeQuery( cSql )

	If Select(cAliasTRB) > 0           // Verificar se o Alias ja esta aberto.
		DbSelectArea(cAliasTRB)        // Se estiver, devera ser fechado.
		(cAliasTRB)->( DbCloseArea() )
	EndIf

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), cAliasTRB, .T., .F. )
	DbSelectArea(cAliasTRB)
	DbGoTop()

	DbEval( {|| nCnt++ })              // Conta quantos sao os registros retornados pelo Select.

	DbSelectArea(cAliasTRB)
	DbGoTop()

Return( nCnt )

/*/{Protheus.doc} zNumThread
Retorna n�mero de threads abertas
@param  	cFunName -> Fun��es a considerar na contagem de threads
@author 	Atilio Amarilla
@version  	P12
@since  	03/04/2017
@return  	lRet -> nQtdThread (n�mero de threads ativas)
@obs
@project	Banco de Horas
@history	Acerto de rotinas IN12 e PP04. Uso de produto alternativo nos Kits
/*/
User Function zNumThread(cFunName,cSubObs,lJob)

	Local nQtdThread	:= 0
	Local aThreads		:= GetUserInfoArray()
	Local _nQ			:= 0
	Local nLenThreads	:= Len(aThreads)

	// Vari�vel permite 2o. crit�rio de sele��o, substring do campo observa��o GetUserInfoArray()[11]
	DEFAULT cSubObs	:= ""

	default lJob	:= .F.

	If Empty( cFunName )
		nQtdThread := nLenThreads
	Else
		For _nQ := 1 To nLenThreads
			if !lJob
				If Upper(AllTrim(aThreads[_nQ,5])) $ cFunName .And. IIf(!Empty(cSubObs),cSubObs$aThreads[_nQ,11],.T.)
					nQtdThread++
				EndIf
			elseif lJob
				If cFunName $ Upper(AllTrim(aThreads[_nQ,11])) .And. IIf(!Empty(cSubObs),cSubObs$aThreads[_nQ,11],.T.)
					nQtdThread++
				EndIf
			endif
		Next _nQ
	EndIf

Return nQtdThread

/*/{Protheus.doc} zMonThread
Monitoramneto de Threads. Retorna informa��es de threads abertas.
@param  	cFunName -> Fun��es a considerar na contagem de threads
@author 	Atilio Amarilla
@version  	P12
@since  	03/04/2017
@return  	aRet ->	nQtdThread (n�mero de threads ativas)
					nMemThread (quantidade de mem�ria consumida pela aplica��o appserver)
@obs
@project	Banco de Horas
@history	Acerto de rotinas IN12 e PP04. Uso de produto alternativo nos Kits
/*/
User Function zMonThread(cFunName,cSubObs)

	Local nQtdThread	:= 0
	Local nMonThread	:= 0
	Local aThreads		:= GetUserInfoArray()
	Local _nQ			:= 0
	Local nLenThreads	:= Len(aThreads)

	// Vari�vel permite 2o. crit�rio de sele��o, substring do campo observa��o GetUserInfoArray()[11]
	DEFAULT cFunName	:= ""
	DEFAULT cSubObs		:= ""

	If Empty( cFunName ) .And. Empty( cSubObs )
		nQtdThread := nLenThreads
		For _nQ := 1 To nLenThreads
			If aThreads[_nQ,12] > 0
				nMonThread += aThreads[_nQ,12]
			EndIf
		Next _nQ
	Else
		For _nQ := 1 To nLenThreads
			If IIf(!Empty(cFunName),Upper(AllTrim(aThreads[_nQ,5])),.T.) $ cFunName .And. IIf(!Empty(cSubObs),cSubObs$aThreads[_nQ,11],.T.)
				nQtdThread++
			EndIf
			If aThreads[_nQ,12] > 0
				nMonThread += aThreads[_nQ,12]
			EndIf
		Next _nQ
	EndIf

Return( { nQtdThread , nMonThread } )

/*/{Protheus.doc} zGravaLog
Grava��o de arquivo texto (LOG)
@param  	cLogFile -> Nome do Arquivo (Path + Nome)
@param  	cMsg -> Conte�do a gravar no arquivo
@author 	Atilio Amarilla
@version  	P12
@since  	05/04/2017
@return  	NIL
@obs
@project	Banco de Horas
@history	Acerto de rotinas IN12 e PP04. Uso de produto alternativo nos Kits
/*/
User Function zGravaLog(cLogFile,cMsg)

	If !File(cLogFile)
		nH := FCreate(cLogFile)
	Else
		nH := FOpen(cLogFile,1)
	EndIf

	FSeek(nH,0,2)
	FWrite(nH,cMsg+CRLF,Len(cMsg)+2)
	FClose(nH)

Return
