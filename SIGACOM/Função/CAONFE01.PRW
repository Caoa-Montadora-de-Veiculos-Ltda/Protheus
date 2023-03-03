#include "totvs.ch"
#include "apwizard.ch"

// -- Declaração das variáveis estáticas do programa
Static	nF1_CNPJ    := 3
Static	nF1_DOC	    := 4
Static	nF1_SERIE	:= 5
Static	nF1_EMISSAO := 8
Static	nF1_VALOR   := 10
Static	nF1_CHVNFE  := 18  //Chave NFE

Static	nF1_FORNEC  := 19
Static	nF1_LOJA    := 20
Static	nF1_TES     := 21
Static	nF1_COD     := 22  //Produto informado na tela inicial
Static	nF1_COND    := 23  //Cond.Pagto informado na tela inicial
Static	nF1_EST     := 24  //UF do Fornecedor
Static	nE2_NATUREZ := 25  //Natureza

//Static	nF1_TIPO	 :=	1
//Static	nF1_FORMUL	 :=	2
//Static	nF1_ESPECIE  :=	8
//Static	nF1_EST	     :=	9
//Static	nF1_VALMERC  :=	10
//Static	nF1_DESCONT  :=	11
//Static	nF1_SEGURO	 :=	12
//Static	nF1_DESPESA  :=	13
//Static	nF1_COND	 :=	15
//Static	nD1_COD	     :=	16
//Static	nD1_QUANT	 :=	17
//Static	nD1_VUNIT	 :=	18
//Static	nD1_TOTAL	 :=	19
//Static	nD1_TES	     :=	20

/*/--------------------------------------------------------------------------------------------
CAONFE01
Desenvolver rotina que possibilite importação de dados de uma planilha para o ERP Protheus, criando de uma só vez diversos
notas fiscais de entrada, com diversos itens.

@author Rodrigo Moraes
@since 21/08/2018
@version 1.0
--------------------------------------------------------------------------------------------/*/
User Function CAONFE01()

	local   oWizard
	local   oPanel
	local   oBtn
	static  aFiliais := {}
	private oArquivo
	private cArquivo := space(100)
	private cTitulo  := "Importaçao Nota Fiscal de Entrada"
	private nHdl     := 0
	//private cLOG     := criaTrab(,.F.)+".htm"
	private oTIBrowser
    private oEdit
    private cTES := Space(Len(CriaVar("F4_CODIGO")))
    private cProduto := PadR(Alltrim(SUPERGETMV("MV_XPRODNF", .F., "001")),Len(SB1->B1_COD))
    private cCondPag := PadR(Alltrim(SUPERGETMV("MV_CONDIMP", .F., "001")),Len(SF1->F1_COND))
    private cNaturez := Space(Len(CriaVar("E2_NATUREZ")))
	DEFINE WIZARD oWizard TITLE cTitulo ;
	HEADER "Gerar novas notas fiscais de entrada" ;
	MESSAGE "" ;
	TEXT "Esta rotina irá carregar um arquivo no formato .CSV (separado com ponto-e-vírgula), fazer as devidas consistências e importar as Notas Fiscais de Entrada." ;
	NEXT {||.T.} ;
	FINISH {|| .T. } ;
	PANEL

	CREATE PANEL oWizard ;
	HEADER "Informe o arquivo a ser importado" ;
	MESSAGE "A rotina irá carregar o arquivo, fazer as devidas consistências e gerar as notas fiscais de entrada" ;
	BACK {|| .T. } ;
	NEXT {|| (!empty( cArquivo ) .And. !empty( cTES )) .and. Importa() } ;
	FINISH {|| .T. } ;
	PANEL
	oPanel := oWizard:GetPanel(2)
	@ 15,15 SAY "Arquivo:" SIZE 45,8 PIXEL OF oPanel
	@ 13,40 button oBtn prompt "Selecionar" size 45, 12 action getCSV()  PIXEL OF oPanel
	@ 27,15 MSGET oArquivo Var cArquivo SIZE 240,10 PIXEL OF oPanel when .F.
	@ 43,15 SAY  "TES:"  SIZE 45,8 PIXEL OF oPanel
	@ 41,30 MSGET oTES Var cTES  F3 "SF4" VALID (Vazio() .Or. ExistCpo("SF4")) SIZE 30, 10 OF oPanel PIXEL

	@ 43+16,15 SAY  "Produto:"  SIZE 45,8 PIXEL OF oPanel
	@ 41+16,50 MSGET oProduto Var cProduto F3 "SB1" VALID (!Vazio() .and. ExistCpo("SB1")) SIZE 50, 10 OF oPanel PIXEL
	@ 43+32,15 SAY  "Cond.Pagto:"  SIZE 45,8 PIXEL OF oPanel
	@ 41+32,50 MSGET oCondPag Var cCondPag F3 "SE4" VALID (!Vazio() .and. ExistCpo("SE4")) SIZE 50, 10 OF oPanel PIXEL
	@ 43+48,15 SAY  "Natureza:"  SIZE 45,8 PIXEL OF oPanel
	@ 41+48,50 MSGET oNaturez Var cNaturez F3 "SED" VALID (!Vazio() .and. ExistCpo("SED")) SIZE 50, 10 OF oPanel PIXEL
		
	CREATE PANEL oWizard ;
	HEADER "Finalização" ;
	MESSAGE "Confirmação." ;
	BACK {|| .T. } ;
	NEXT {|| .F. } ;
	FINISH {|| .T. } ;
	PANEL
	oPanel := oWizard:GetPanel(3)

	oEdit := TSimpleEditor():New( 0, 0.5, oPanel, /*larg*/ 290, /*altura*/ 135 )

	ACTIVATE WIZARD oWizard CENTERED

	PutMv("MV_XPRODNF",cProduto)  //Atualiza o SX6
	PutMv("MV_CONDIMP",cCondPag)  //Atualiza o SX6

Return NIL

//--------------------------------------------
Static Function getCSV()
	cArquivo := cGetFile('Arquivo (*.CSV)|*.CSV?' , 'Selecione o arquivo a ser importado',1,'C:\',.T., GETF_LOCALHARD, .T., .T. )
	oArquivo:SetText(cArquivo)
	oArquivo:Refresh()
return nil


//--------------------------------------------
Static Function importa()
Local lRet:=.t.

Processa({|| lRet:=Importa1() },"Validando Arquivo de Importação...","Aguarde...")

Return(lRet)
//-----------------------------------------------------------------------------

Static Function Importa1()
	local   cLinha

	local   nI       := 1
	local   aTemp
	local   cQuebra
	local   lOK
	local   aNFE     := {}
	local   cPath    := GetTempPath()
	Local   aErros   :={}
	Local   cCampoErr:=""
	Local   cDocAnt  :=""
	Local   cSerAnt  :=""
	Local   cForAnt  :=""
	Local   cLojAnt  :=""
	private nLin     := 0
	private lBack    := .T.
	private nOK      := 0
	private nERR     := 0
	private _fornece := ''	
	private _loja	 := ''
	private _est	 := ''
	private cLOG     := criaTrab(,.F.)+".htm"
	private cArqSim  := "c:\temp\caonfe01_ok.csv"
	private cArqNao  := "c:\temp\caonfe01_erros.csv"

	if FT_FUSE( cArquivo ) == -1
		msgAlert("Não foi possível abrir o arquivo "+cArquivo, cTitulo)
		return .F.
	endif

//
	If File(cArqSim)
		fErase(cArqSim)
	EndIf
	If File(cArqNao)
		fErase(cArqNao)
	EndIf
	nHdlSim := fCreate(cArqSim, 0)
	If nHdlSim == -1
		msgAlert( "Problema na criação do arquivo de log1: "+cArqSim, cTitulo)
		return .F.
	Else
		cTXT := "Filial;Número"+CRLF//;Série;Fornecedor;Loja"
		fWrite(nHdlSim, cTXT, Len(cTXT))
	EndIf
	nHdlNao := fCreate(cArqNao, 0)
	If nHdlNao == -1
		msgAlert( "Problema na criação do arquivo de log2: "+cArqNao, cTitulo)
		fClose( nHdlSim )
		return .F.
	Else
		cTXT := "Linha;Erro"+CRLF
		fWrite(nHdlNao, cTXT, Len(cTXT))
	EndIf
//

	nHdl := fCreate(cLOG, 0)
	if nHdl == -1
		msgAlert( "Problema na criação do arquivo de log: "+cLOG, cTitulo)
		fClose( nHdlSim )
		fClose( nHdlNao )
		return .F.
	else
		cTXT := "<html>"
		cTXT += "<head><title>LOG da "+cTitulo+"</title>"
		cTXT += "<style>"

		cTXT += "body, table {"
		cTXT += 	"font-family: verdana, arial;"
		cTXT += 	"font-size: 10px;"
		cTXT += "}"
		cTXT += "</style>"

		cTXT += "</head>"
		cTXT += "<body>"
		cTXT += "<h4>Problemas encontrados:</h4>"
		cTXT += "<table border='0' width='100%'>"
		cTXT += "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><th>Linha</th><th>Inconsistência</th><th>Descrição</th></tr>"
		lBack := !lBack
		fWrite(nHdl, cTXT, Len(cTXT))
	endif

	ProcRegua( FT_FLastRec() )

	while !FT_FEOF()
		IncProc()

		cLinha := FT_FREADLN()
		cLinha := strtran( cLinha, ";", " ; ")
		//aTemp  := strTokArr( Alltrim(cLinha), ";" )
		aTemp  := fTabCampo( Alltrim(cLinha), ";" )  //Traz o array do campo informado
		
		aadd( aTemp, _fornece ) // -- Posicao 19
		aadd( aTemp, _loja ) // -- Posicao 20
		aadd( aTemp, cTES ) // -- Posicao 21
		aadd( aTemp, cProduto ) // -- Posicao 22
		aadd( aTemp, cCondPag ) // -- Posicao 23
		aadd( aTemp, _est ) // -- Posicao 24
		aadd( aTemp, cNaturez ) // -- Posicao 25
		
		nLin++

		if nLin == 1	// pular linha de Título
			FT_FSKIP()
			loop
		endif

		lOk := .T.

		if len( aTemp ) < (18 + 06)  //18=Colunas da planilha + 06=Colunas incluídas no programa
			cTXT := cValTochar(nLin)+";"+"Quantidade de colunas diferente de 18"+CRLF
			fWrite(nHdlNao, cTXT, Len(cTXT))

			lOk := .F.
		endif

		if lOk		// validar dados
			cCampoErr:=""
			If Empty(aTemp[03])  //CNPJ
				cCampoErr+=If(Empty(cCampoErr),"",", ")+"03"
			EndIf
			If Empty(aTemp[04])  //Número
				cCampoErr+=If(Empty(cCampoErr),"",", ")+"04"
			EndIf
			If Empty(aTemp[05])  //Série
				cCampoErr+=If(Empty(cCampoErr),"",", ")+"05"
			EndIf
			If Empty(aTemp[08])  //Dt.Emissão
				cCampoErr+=If(Empty(cCampoErr),"",", ")+"08"
			EndIf
			If Empty(aTemp[10])  //Valor Total
				cCampoErr+=If(Empty(cCampoErr),"",", ")+"10"
			EndIf
			If !Empty(cCampoErr)
				cTXT := cValTochar(nLin)+";"+"Colunas sem informação: "+cCampoErr
				fWrite(nHdlNao, cTXT, Len(cTXT))
	
				lOk := .F.
			EndIf
		EndIf

		if lOk		// validar dados
			lOK := fChkDados( @aTemp )
		endif

		if lOk		// armazenar para incluir por filial
			aadd( aNFE, aClone( aTemp ) )
			nOK++
		else
			nERR++
		endif

		FT_FSKIP()
	end

	FT_FUSE()

//
	If nERR == 0
		aErros:={}
		SF1->(dbSetOrder(1))  //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		For nI:=1 to Len(aNFE)
			cDocAnt:=StrZero( Val(aNFE[nI,nF1_DOC]) , Len(SF1->F1_DOC) )
			cSerAnt:=PadR(aNFE[nI,nF1_SERIE  ],Len(SF1->F1_SERIE  ))
			cForAnt:=PadR(aNFE[nI,nF1_FORNECE],Len(SF1->F1_FORNECE))
			cLojAnt:=PadR(aNFE[nI,nF1_LOJA   ],Len(SF1->F1_LOJA   ))
			If SF1->(dbSeek(xFilial("SF1")+cDocAnt+cSerAnt+cForAnt+cLojAnt))  //Posiciona no SF1
				AAdd(aErros,{cDocAnt,cSerAnt,cForAnt,cLojAnt})  //Já gerado anteriormente
			EndIf
		Next
		If Len(aErros)>0
			cTXT := "Número;Série;Fornecedor;Loja;Erro"+CRLF
			fWrite(nHdlNao, cTXT, Len(cTXT))
			for nI := 1 to len( aErros )
				cTXT := aErros[nI,1]+";"+aErros[nI,2]+";"+aErros[nI,3]+";"+aErros[nI,4]+";"+"Gerada anteriormente"+CRLF
				fWrite(nHdlNao, cTXT, Len(cTXT))
			next
		EndIf
	EndIf
//

	// Faz ordenacao por F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	aSort( aNFE,,, {|a,b| a[nF1_DOC]+a[nF1_SERIE]+a[nF1_FORNECE]+a[nF1_LOJA] < b[nF1_DOC]+b[nF1_SERIE]+b[nF1_FORNECE]+b[nF1_LOJA] } )

	cTXT := "</table><br />"
	cTXT += "<h4>Resumo da Validação de Campos:</h4>"
	cTXT += "<table border='0'  width='50%'>"
	cTXT += "<tr style='background-color: #CCCCCC'><td width='60%'>Itens lidos:</td><td>" + cValToChar(nLin) + "</td></tr>"
	cTXT += "<tr><td>Itens OK:</td><td>" + cValToChar(nOK)  + "</td></tr>"
	cTXT += "<tr style='background-color: #CCCCCC'><td>Itens ERRO:</td><td>"  + cValToChar(nERR) + "</td></tr>"
	If Len(aErros)>0
		cTXT += "<tr style='background-color: #CCCCCC'><td>Itens gerados anteriormente:</td><td>"  + cValToChar(Len(aErros)) + "</td></tr>"
	EndIf
	cTXT += "</table>"
	fWrite(nHdl, cTXT, Len(cTXT))

	Private aRodaThre:={0,0,0}

	if len( aNFE ) > 0 .and. nERR == 0 .and. Len(aErros)==0
		Processa({|| RodaThread( aNFE )},"Incluindo Nota fiscal de entrada...","Aguarde!...")
	endif

	cTXT := "<br />"
	cTXT += "<h4>Resumo da Geração de Notas Fiscais:</h4>"
	cTXT += "<table border='0'  width='50%'>"
	cTXT += "<tr style='background-color: #CCCCCC'><td width='60%'>Itens lidos:</td><td>" + cValToChar(aRodaThre[1]) + "</td></tr>"
	cTXT += "<tr><td>Itens Gerados:</td><td>" + cValToChar(aRodaThre[2])  + "</td></tr>"
	cTXT += "<tr style='background-color: #CCCCCC'><td>Itens com ERRO:</td><td>"  + cValToChar(aRodaThre[3]) + "</td></tr>"
	cTXT += "</table>"
	fWrite(nHdl, cTXT, Len(cTXT))

	cTXT := "</body></html>"
	fWrite(nHdl, cTXT, Len(cTXT))

	fClose( nHdl )
	fClose( nHdlSim )
	fClose( nHdlNao )

	CpyS2T(GetSrvProfString("Startpath","")+ "\"+cLOG, cPath, .T.)
	cUrl := MemoRead(strTran(cPath, "\", "/") + cLog)
	oEdit:Load(cUrl)
	
return .T.

//------------------------------------------
static function fChkDados( aDados )
	local lRet	    := .T.	

	local _cnpj     := AllTrim(aDados[ nF1_CNPJ ])
	local _doc	    := AllTrim(aDados[ nF1_DOC ])
	local _serie    := AllTrim(aDados[ nF1_SERIE ])
	local _emissao  := CTOD( AllTrim(left( aDados[ nF1_EMISSAO],11)))
	local _valor    := AllTrim(aDados[ nF1_VALOR ])
	local cChvNfe   := AllTrim(aDados[ nF1_CHVNFE ])

//
	aEmissao:=fTabCampo(aDados[nF1_EMISSAO],"/")  //Traz o array do campo informado
	If Len(aEmissao)==3
		_Emissao:=StoD( StrZero(Val(aEmissao[3]),4)+StrZero(Val(aEmissao[1]),2)+StrZero(Val(aEmissao[2]),2) )
	EndIf
//
	   
	// Valida Fornecedor
	if ! chkFor( _cnpj )
		return .F.
	endif

	if "," $ _valor .and. "." $ _valor
		_valor := strtran( _valor, ".", "" )
		_valor := strtran( _valor, ",", "." )		
	elseif "," $ _valor
		_valor := strtran( _valor, ",", "." )
	endif
	_valor := val( _valor )

	if _valor <= 0
		cTXT := cValTochar(nLin)+";"+"Valor total deve ser maior que ZERO"+CRLF
		fWrite(nHdlNao, cTXT, Len(cTXT))

		return .F.
	endif

	If Empty(cChvNfe)  //Chave NFE
		cTXT := cValTochar(nLin)+";"+"Favor preencher o campo Chave NFE"+CRLF
		fWrite(nHdlNao, cTXT, Len(cTXT))
		return .F.
	EndIf

	if lRet

		aDados[ nF1_DOC ]	  := _doc
		aDados[ nF1_SERIE ]	  := _serie
		aDados[ nF1_EMISSAO ] := _emissao
		aDados[ nF1_FORNECE ] := _fornece
		aDados[ nF1_LOJA ]	  := _loja
		aDados[ nF1_VALOR ]	  := _valor
		aDados[ nF1_TES ]	  := cTES
		aDados[ nF1_EST ]	  := _est
		aDados[ nF1_CHVNFE ]  := cChvNfe

	endif

return lRet


/*/{Protheus.doc} chkFor
//TODO Faz a validação do cadastro de fornecedor.
@author Rodrigo Moraes
@since 23/11/2018
@version 1.0
@return ${return}, ${lRet}
@param _fornecedor, , Codigo do Fornecedor
@param _loja, , Loja do Fornecedor
@type function
/*/

static function chkFor(_cnpj )
	local lRet  := .T.
	local aArea := getArea()

	SA2->( dbSetOrder(3) )
	
	if !SA2->( dbSeek( xFilial("SA2") + _cnpj ) )
		lRet  := .F.

		cTXT := cValTochar(nLin)+";"+"Fornecedor não encontrado para este CNPJ"+CRLF
		fWrite(nHdlNao, cTXT, Len(cTXT))

	else
		_fornece := SA2->A2_COD
		_loja    := SA2->A2_LOJA
		_est     := SA2->A2_EST
	endif
	
	restArea( aArea )
	
return lRet

/*/{Protheus.doc} RodaThread
//TODO Funcao responsavel por criar as Threads, para tratamento caso seja necessario rodar multifilial.
@author rgm
@since 26/11/2018
@version 1.0
@return ${return}, ${return_description}
@param aNFE, array, descricao
@type function
/*/
static function RodaThread( aNFE )
	
	local   nMaxWait := 120
	local   nI       := 1
	local   cQuebra
	local   aTmp
	local   cNomeJob
	local   aThreads := {}
	local   aProcOK  := {}
	local   aProcERR := {}
	local	nX       := 0
	
	Local lMultThre:=.f.  //Multi-thread

	If lMultThre:=.f.  //Multi-thread
		cNomeJob := CriaTrab( nil, .F. )
	EndIf

	// F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA
	
	ProcRegua(len( aNFE ))

	while nI <= len( aNFE )

		incProc("Importando NFEs ("+cValToChar(nI)+"/"+cValToChar(len(aNFE))+")...")

		cQuebra := aNFE[nI,nF1_DOC] + aNFE[nI,nF1_SERIE] + aNFE[nI,nF1_FORNECE] + aNFE[nI,nF1_LOJA] 

		aTmp  := {}

		// -- Faz quebra por itens da NF, para passar corretamente a ExecAuto, contando que os dados de SF1 e SD1 estão na mesma linha
		while nI <= len( aNFE ) .and. cQuebra == aNFE[nI,nF1_DOC] + aNFE[nI,nF1_SERIE] + aNFE[nI,nF1_FORNECE] + aNFE[nI,nF1_LOJA]

			aadd( aTmp, aClone( aNFE[nI] ) )
			nI++
		end

		If lMultThre  //Multi-thread

			//chama thread, caso futuramente seja executado ulti filial, basta alterar o parametro [2] do StartJOB
			cNomeJob := CriaTrab( nil, .F. ) + "_thread_" + cValtoChar( len(aThreads)+1 )
			PutGlbValue(cNomeJob, "C") 			// atualizamos o Status do Job - C=Chamada; I=Iniciado
		
			aadd( aThreads, {cNomeJob, aClone(aTmp), Time(), Seconds(), 1 } )
		
			StartJob( "U_IMPNFET", GetEnvServer(), .F., { cEmpAnt, xFilial("SF1"), cNomeJob, aClone(aTmp), __cUserID, lMultThre } )		// Inicia Thread

		Else

			xStat := ""  //Variável Private !!

			U_IMPNFET( { cEmpAnt, xFilial("SF1"), cNomeJob, aClone(aTmp), __cUserID, lMultThre } )

			aRodaThre[1]++  //Variável Private !!
			If left(xStat, 2) == "OK"
				aadd( aProcOK , { xFilial("SF1"), substr( xStat, 4) } )		// Filial, NumPD
				aRodaThre[2]++  //Variável Private !!
			Else
				aadd( aProcERR, { xFilial("SF1"), xStat             } )		// Filial, ERRO
				aRodaThre[3]++  //Variável Private !!
			EndIf

		EndIf

	end

	If lMultThre  //Multi-thread
		//	check JOBS
		while len( aThreads ) > 0
			aTemp    := aClone( aThreads )
			aThreads := {}
			for nI := 1 to len( aTemp )
				cNomeJob := aTemp[nI,1]
				xStat    := GetGlbValue( cNomeJob )
	
				if xStat $ "C;I"
					if Seconds() - aTemp[nI,4] > nMaxWait	// se passar de 120 segundos (2 minutos... considero que a Thread caiu
						aTemp[nI,5]++
	
						if aTemp[nI,5] <= 3
							PutGlbValue(cNomeJob, "C") 			// atualizamos o Status do Job - C=Chamada; I=Iniciado
							StartJob( "U_IMPNFET", GetEnvServer(), .F., { cEmpAnt, xFilial("SF1"), cNomeJob, aClone(aTmp), __cUserID } )		// Inicia Thread
							aTemp[nI,4] := Seconds()
							aadd( aThreads, aClone( aTemp[nI] ) )
						else
							aadd( aProcERR, { aTemp[nI,1], "tentou executar 3 e falhou!" } )		// Filial, ERRO
						endif
					else
						aadd( aThreads, aClone( aTemp[nI] ) )
					endif
				else
	
					If left(xStat, 2) == "OK"
						aadd( aProcOK , { xFilial("SF1"), substr( xStat, 4) } )		// Filial, NumPD
					Else
						aadd( aProcERR, { xFilial("SF1"), xStat             } )		// Filial, ERRO
					EndIf
				endif
			next
	
			For nX := 1 To 10
				incProc("Acompanhando threads...("+cValToChar(len(aThreads))+") ativas...("+cValToChar(nX)+")")
				Sleep( 1000 )
			Next
			processMessages()
		end
	EndIf

	aSort( aProcOK ,,, {|a,b|, a[1]+a[2] < b[1]+b[2] })	// ordenar p/ Filial + NumPed
	aSort( aProcERR,,, {|a,b|, a[1] < b[1]           })	// ordenar p/ Filial

	for nI := 1 to len( aProcOK )
		cTXT := aProcOK[nI,1]+";"+aProcOK[nI,2]+CRLF
		fWrite(nHdlSim, cTXT, Len(cTXT))
	next

	for nI := 1 to len( aProcERR )
		cTXT := ""+";"+aProcERR[nI,1]+"/"+aProcERR[nI,2]+CRLF
		fWrite(nHdlNao, cTXT, Len(cTXT))
	next

return nil


/*/{Protheus.doc} IMPNFET
//TODO Funcao responsavel por criar o Cab e Item da NF de entrada.
@author rgm
@since 26/11/2018
@version 1.0
@return ${return}, ${return_description}
@param aDados, array, descricao
@type function
/*/
user function IMPNFET(_aParam)

	local   _cEmp          := _aParam[01]		// cEmpAnt
	local   _cFil          := _aParam[02]		// cFilAnt
	local   cNomeJob       := _aParam[03]		// cNomeJob
	local   aDados	       := _aParam[04]		// aDados
	local   cUsrRun        := _aParam[05]		// usuário que está executando a rotina
	local   lMultThre      := _aParam[06]		// Multi-thread
	
	local   aCab     := {}
	local   aItens   := {}
	local   aTmp     := {}
	local   nLinCab  := 1
	local	nI		 := 0
	
	private cRetExec := ""


	If lMultThre  //Multi-thread
		// -- Inicia ambiente no modo JOB (Thread)
		PutGlbValue(cNomeJob, "I")
		RpcSetType(3)
		RpcSetEnv( _cEmp , _cFil,,, "COM", GetEnvServer() ) 
		__cUserID := cUsrRun
		SetModulo( "SIGACOM", "COM" )
	EndIf
	
	// -- Cria array com o cabeçalho da Nota Fiscal de Entrada (SF1)
	aadd( aCab, { "F1_TIPO"	   , 'N'	, nil } )
	aadd( aCab, { "F1_FORMUL"  , 'N'  , nil } )
	aadd( aCab, { "F1_DOC"	   , aDados[ nLinCab, nF1_DOC ]	    , nil } )
	aadd( aCab, { "F1_SERIE"   , aDados[ nLinCab, nF1_SERIE ]   , nil } )
	aadd( aCab, { "F1_EMISSAO" , aDados[ nLinCab, nF1_EMISSAO ] , nil } )
	aadd( aCab, { "F1_FORNECE" , aDados[ nLinCab, nF1_FORNECE ] , nil } )
	aadd( aCab, { "F1_LOJA"	   , aDados[ nLinCab, nF1_LOJA ]	, nil } )
	aadd( aCab, { "F1_ESPECIE" , 'NFS' , nil } )
	aadd( aCab, { "F1_EST"	   , aDados[ nLinCab, nF1_EST ] , nil } )
	aadd( aCab, { "F1_VALMERC" , aDados[ nLinCab, nF1_VALOR ] , nil } )
	aadd( aCab, { "F1_DESCONT" , 0 , nil } )
	aadd( aCab, { "F1_SEGURO"  , 0  , nil } )
	aadd( aCab, { "F1_DESPESA" , 0 , nil } )
	aadd( aCab, { "F1_VALBRUT" , aDados[ nLinCab, nF1_VALOR ] , nil } )
	aadd( aCab, { "F1_COND"	   , aDados[ nLinCab, nF1_COND ] , nil } )
	aadd( aCab, { "E2_NATUREZ" , aDados[ nLinCab, nE2_NATUREZ] , nil } )
	aadd( aCab, { "F1_CHVNFE"  , aDados[ nLinCab, nF1_CHVNFE ] , nil } )
	aadd( aCab, { "F1_STATUS"  , "A"	   , nil } )

	// -- Cria array com os Itens da NFE (SD1)
	for nI := 1 to len( aDados )
		aTmp := {}

		aadd( aTmp, { "D1_COD"	  ,	aDados[ nLinCab, nF1_COD ] , nil } )
		aadd( aTmp, { "D1_QUANT"  ,	1	, nil } )
		aadd( aTmp, { "D1_VUNIT"  ,	aDados[ nI, nF1_VALOR ]	, nil } )
		aadd( aTmp, { "D1_TOTAL"  ,	aDados[ nI, nF1_VALOR ]	, nil } )
		aadd( aTmp, { "D1_TES"	  ,	aDados[ nI, nF1_TES ]	, nil } )
		aadd( aTmp, { "AUTDELETA" ,	"N"	, nil } )

		aadd( aItens, aClone( aTmp ) )
	next

	geraPC( aCab, aItens )
	
	If lMultThre  //Multi-thread
		PutGlbValue(cNomeJob, cRetExec)
		DelClassIntf()
		RpcClearEnv()
	Else
		xStat:=cRetExec
	EndIf

return nil



/*/{Protheus.doc} geraPC
//TODO Funcao responsavel por executar a ExecAuto do MATA103.
@author rgm
@since 26/11/2018
@version 1.0
@return ${return}, ${return_description}
@param aCab, array, descricao
@param aItens, array, descricao
@type function
/*/
static function geraPC( aCab, aItens )
	local   nOpc           := 3		// inclusão
	local   oErro          := ErrorBlock({|e| FilterErro(e)})
	private lMsErroAuto    := .F.

	begin sequence

		MSExecAuto({|x,y| MATA103(x,y)}, aCab, aItens, 3)

		if lMsErroAuto
			cRetExec := "NF: ["+aCab[3]+"] Serie: ["+aCab[4]+"]"+CRLF+MemoRead(NomeAutoLog())
		else
			cRetExec := "OK "+SF1->F1_DOC
		Endif

	end sequence

	ErrorBlock(oErro)
return nil



/*/{Protheus.doc} FilterErro
//TODO Funcao responsavel por fazer o tratamento do erro proveniente da ExecAuto.
@author rgm
@since 26/11/2018
@version 1.0
@return ${return}, ${return_description}
@param e, , descricao
@type function
/*/
Static Function FilterErro(e)
	if e:gencode > 0
		cRetExec := "Ocorreu erro!"
		Alert("Ocorreu erro!")
		BREAK
	endIf

	varinfo( "e", e )

Return nil
//-----------------------------------------------------------------------------
/* 	Comentando função pois não é permitido alterar a tabela SX6 dessa menira na versão 12.1.27
//-----------------------------------------------------------------------------
Static Function fPutMv(cParam,cConteud)  //Atualiza o SX6
Local aAreaSX6:=SX6->(GetArea())

SX6->(dbSetOrder(1))  //X6_FIL+X6_VAR
If SX6->(!dbSeek(xFilial("SX6")+cParam))  //Posiciona no SX6
	SX6->(dbSeek(Space(Len(X6_FIL))+cParam))  //Posiciona no SX6
EndIf

If SX6->(!Eof())
	If SX6->(RecLock("SX6",.f.))
		SX6->X6_CONTEUD:=cConteud
		SX6->X6_CONTSPA:=cConteud
		SX6->X6_CONTENG:=cConteud
		SX6->(MsUnLock())
	EndIf
EndIf

SX6->(RestArea(aAreaSX6))
Return
*/
//-----------------------------------------------------------------------------

Static Function fTabCampo(cCampo,cSep)  //Traz o array do campo informado
Local nPos,aTabAux:={}

While Len(cCampo)>0
	nPos:=At(cSep,cCampo)
	Do Case
	Case nPos>0 .and. nPos==Len(cCampo)  //Ponto e vírgula na última posição
		AAdd(aTabAux,Subs(cCampo,1,nPos-1))  //Adiciona a penúltima coluna
		AAdd(aTabAux,""                   )  //Adiciona a última coluna em branco
		cCampo:=""
	Case nPos>0
		AAdd(aTabAux,Subs(cCampo,1,nPos-1))
		cCampo:=Subs(cCampo,nPos+1,Len(cCampo)-nPos)
	Otherwise
		AAdd(aTabAux,cCampo)
		cCampo:=""
	EndCase
End

Return(aTabAux)
//-----------------------------------------------------------------------------
