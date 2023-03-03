#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWMVCDEF.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carga de Veículos VV1                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION VEINCPRD()

Private aRotina  := {}
Private cNomeArq := " "
Private oProcess
Private nOpca    := 0
Private cChaint  := " "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do arquivo texto                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cType := OemToAnsi("Arquivos CSV ") + "(*.CSV) |*.csv|"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Comando para selecionar um arquivo.                          ³
//³ Parametro: GETF_LOCALFLOPPY - Inclui o floppy drive local.   ³
//³            GETF_LOCALHARD - Inclui o Harddisk local.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Do While .T.

cNomeArq := cGetFile(cType, OemToAnsi("Selecione o Arquivo "), 0,, .T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)


If File(cNomeArq)
	nOpca := 1
EndIf

If nOpca == 1
	oProcess := MsNewProcess():New({|lEnd| RunCont()},"Importa Veiculos ")
	oProcess:Activate()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RunCont	   ³ Autor ³ Totvs          		³ Data ³ 19.02.19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CAOA                            						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RunCont()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis do Programa                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea	 := GetArea()
Local aRR        := {}
Local lFirst     := .T.
Local aCposCab   := {}
Local lRet       := .T.
Local cDoc       := ""
Local cSerie     := ""
Local cFornece   := ""
Local cLoja      := ""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se arquivo existe										    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdl := fOpen(cNomeArq)
If nHdl == -1
	MsgAlert("O Arquivo de Nome "+cNomeArq+" nao pode ser Aberto! Verifique os Parâmetros.","Atenção!")
	Return
Endif

FT_FUSE(cNomeArq)
FT_FGOTOP()

oProcess:SetRegua1(FT_FLASTREC())

While !FT_FEOF()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os campos obtendo os valores da linha lida do arquivo texto.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDoc       := " "
	cSerie     := " "
	cFornece   := " "
	cLoja      := " "

	lRet    := .T.
	cBuffer := FT_FREADLN()
	aRR     := {}
	If lFirst
		lFirst := .F.
		FT_FSKIP()
		Loop
	Endif
	aRR  := Separa(cBuffer,";")
	If Len(aRR) < 8
		FT_FSKIP()
		Loop
	Endif

	aCposCab := {}
	aAdd( aCposCab , { 'VV1_CODMAR' , Alltrim(aRR[01])    } )
	aAdd( aCposCab , { 'VV1_CHASSI' , Alltrim(aRR[02])    } )
	aAdd( aCposCab , { 'VV1_MODVEI' , Alltrim(aRR[03])    } )
	aAdd( aCposCab , { 'VV1_SEGMOD' , Alltrim(aRR[04])    } )
	aAdd( aCposCab , { 'VV1_FABMOD' , Alltrim(aRR[05])    } )
	aAdd( aCposCab , { 'VV1_CORVEI' , Alltrim(aRR[06])    } )
	aAdd( aCposCab , { 'VV1_COMVEI' , Alltrim(aRR[07])    } )
	aAdd( aCposCab , { 'VV1_CODORI' , '0'        } )
	aAdd( aCposCab , { 'VV1_PROVEI' , Alltrim(aRR[08])    } )
	aAdd( aCposCab , { 'VV1_ESTVEI' , '0'        } )
	aAdd( aCposCab , { 'VV1_TIPVEI' , '1'		 } )
	aAdd( aCposCab , { 'VV1_CAMBIO' , Alltrim(aRR[09])    } )
	aAdd( aCposCab , { 'VV1_NUMMOT' , Alltrim(aRR[10])    } )
	aAdd( aCposCab , { 'VV1_SERMOT' , Alltrim(aRR[11])    } )
	aAdd( aCposCab , { 'VV1_LOCPAD' , 'VN'       } )
	aAdd( aCposCab , { 'VV1_SITVEI' , '0'        } )
	aAdd( aCposCab , { 'VV1_IMOBI'  , aRR[12]    } )
	aAdd( aCposCab , { 'VV1_DI'     , Alltrim(aRR[13])    } )
	aAdd( aCposCab , { 'VV1_DTDI'   , CTOD(aRR[14])    } )


	If !AxIncVei(aCposCab)
		lRet := .F.
	EndIf


	// -- Cria array com o cabeçalho da Nota Fiscal de Entrada (SF1)
	aCab := {}
	aadd( aCab, { "F1_TIPO"	   , 'N'	           , nil } )
	aadd( aCab, { "F1_FORMUL"  , 'N'               , nil } )
	aadd( aCab, { "F1_DOC"	   , Alltrim(aRR[15])  , nil } )
	aadd( aCab, { "F1_SERIE"   , Alltrim(aRR[16])  , nil } )
	aadd( aCab, { "F1_EMISSAO" , CTOD(aRR[17])     , nil } ) // Tratar Emissao
	aadd( aCab, { "F1_FORNECE" , Alltrim(aRR[18])  , nil } )
	aadd( aCab, { "F1_LOJA"	   , Alltrim(aRR[19])  , nil } )
	aadd( aCab, { "F1_ESPECIE" , 'NFS'             , nil } )
	//aadd( aCab, { "F1_EST"	   , aDados[ nLinCab, nF1_EST ] , nil } )
	//aadd( aCab, { "F1_VALMERC" , aDados[ nLinCab, nF1_VALOR ] , nil } )
	aadd( aCab, { "F1_DESCONT" , 0                 , nil } )
	aadd( aCab, { "F1_SEGURO"  , 0                 , nil } )
	aadd( aCab, { "F1_DESPESA" , 0                 , nil } )
	//aadd( aCab, { "F1_VALBRUT" , aDados[ nLinCab, nF1_VALOR ] , nil } )
	aadd( aCab, { "F1_COND"	   , '001'             , nil } )
	//aadd( aCab, { "F1_NATUREZ" , '1101' , nil } )
	//aadd( aCab, { "F1_CHVNFE"  , aDados[ nLinCab, nF1_CHVNFE ] , nil } )
	aadd( aCab, { "F1_STATUS"  , "A"	           , nil } )

	aTmp   := {}
	aItens := {}
	// -- Cria array com os Itens da NFE (SD1)
	aadd( aTmp, { "D1_COD"	  ,	Alltrim(aRR[20])   , nil } )
	aadd( aTmp, { "D1_QUANT"  ,	1	               , nil } )
	aadd( aTmp, { "D1_VUNIT"  ,	VAL(aRR[21])	   , nil } )
	aadd( aTmp, { "D1_TOTAL"  ,	VAL(aRR[21])	   , nil } )
	aadd( aTmp, { "D1_LOCAL"  ,	'VN'  	           , nil } )
	aadd( aTmp, { "D1_TES"	  ,	'176'	           , nil } )   //TES da NF de Entrada para carga de Veículos
	aadd( aTmp, { "D1_CHASSI" ,	Alltrim(aRR[02])   , nil } )
	aadd( aTmp, { "AUTDELETA" ,	"N"	               , nil } )

	aadd( aItens, aClone( aTmp ) )


	oProcess:IncRegua1("Processando Importação de Veiculos" )

	If lRet
		//Importacao do SD1/SF1
		If !geraNF( aCab, aItens )
			lRet := .F.
		Else
			cDoc       := SF1->F1_DOC
			cSerie     := SF1->F1_SERIE
			cFornece   := SF1->F1_FORNECE
			cLoja      := SF1->F1_LOJA
		EndIf
	Endif

	//Endereçar
	If lRet
		If !xEndProd()
			lRet := .F.
		EndIf
	Endif
	//Importacao do VVF/VVG
	If lRet
		If IncVeiPrd(cDoc,cSerie,cFornece,cLoja)
			lRet := .F.
		EndIf
	Endif

	FT_FSKIP()

EndDo

RestArea(_aArea)
fClose( nHdl )
_cNew := cNomeArq+".old"

FErase(cNomeArq)
FRename(cNomeArq,_cNew)

Return Nil


/*/{Protheus.doc} CAOIntEst
Funcao responsavel por cadastrar o veiculo
@author FSW - DWC Consult
@since 10/02/2019
@version 1.0
@type function
/*/

Static Function AxIncVei(aCpoCAB)
	Local cModelVV1 := 'MODEL_VV1'
	Local nI        := 0
	Local nPos      := 0
	Local lRet      := .T.
	Local aAux	    := {}
	Local aErro		:= {}
	Local oModel	:= Nil
	Local oAux		:= Nil
	Local oStruct	:= Nil

	oModel := FWLoadModel( 'VEIA070' )
	oModel :SetOperation( MODEL_OPERATION_INSERT )
	lRet   := oModel:Activate()

	If lRet
		oAux    := oModel:GetModel( cModelVV1 )
		oStruct := oAux:GetStruct()
		aAux	:= oStruct:GetFields()
		For nI  := 1 To Len( aCpoCAB )
			If  ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoCAB[nI][1] ) } ) ) > 0
				If !oModel:SetValue( cModelVV1, aCpoCAB[nI][1], aCpoCAB[nI][2] )
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf

	If lRet
		If ( lRet := oModel:VldData() )
			lRet := oModel:CommitData()
		EndIf
	EndIf

	If !lRet
		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro   := oModel:GetErrorMessage()

		// A estrutura do vetor com erro é:
		//  [1] Id do formulário de origem
		//  [2] Id do campo de origem
		//  [3] Id do formulário de erro
		//  [4] Id do campo de erro
		//  [5] Id do erro
		//  [6] mensagem do erro
		//  [7] mensagem da solução
		//  [8] Valor atribuido
		//  [9] Valor anterior

		AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
		AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
		AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
		AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
		AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
		AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
		AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
		AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
		AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )

		If (!IsBlind())
			MostraErro() // TELA
		Else
			// EM ESTADO DE JOB
			cError := ""
			cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

			ConOut(PadC("Automatic routine ended with error", 80))
			ConOut("Error: "+ cError)
		EndIf
	Else
		cChaint := oModel:GetValue(cModelVV1,"VV1_CHAINT")
	EndIf

	// Desativamos o Model
	oModel:DeActivate()

Return( lRet )

/*/{Protheus.doc} geraPC
/*/
static function geraNF( aCab, aItens )
	//local   nOpc           := 3		// inclusão
	local   lRet           := .T.
	private lMsErroAuto    := .F.

	begin sequence

		MSExecAuto({|x,y| MATA103(x,y)}, aCab, aItens, 3)

		if lMsErroAuto
			lRet     := .F.

			If (!IsBlind())
				MostraErro() // TELA
			Else
				// EM ESTADO DE JOB
				cError := ""
				cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

				ConOut(PadC("Automatic routine ended with error", 80))
				ConOut("Error: "+ cError)
			EndIf
		else
			cRetExec := "OK "+SF1->F1_DOC
		Endif

	end sequence

	//ErrorBlock(oErro)

return lRet


Static Function xEndProd()

	Local aArea 	:= GetArea()
	local aAreaSF1	:= SF1->(GetArea())
	Local aAreaSDA	:= SDA->(GetArea())
	Local aAreaSDB	:= SDB->(GetArea())

	Local cAlias    := ""
	Local aCabSDA   := {}
	Local aItSDB    := {}
	Local aItensSDB := {}
	Local nCount    := 0
	Local lRet      := .T.
	local cLocal	:= allTrim( superGetMv( "CMV_VE1LOC"	, , "VEICULO NOVO"		) )	// Natureza para Nota fiscal SIGAVEI

	Private lMsErroAuto := .F.

	cAlias := getNextAlias()
	BeginSql Alias cAlias
		SELECT
			SD1.D1_COD,
			SD1.D1_CHASSI ,
			SDA.DA_NUMSEQ,
			SDA.DA_LOCAL,
			SD1.D1_QUANT,
			SDA.DA_SALDO
		FROM
		%TABLE:SD1% SD1
		INNER JOIN %TABLE:SDA% SDA
			ON SDA.DA_FILIAL  = SD1.D1_FILIAL
			AND SDA.DA_DOC    = SD1.D1_DOC
			AND SDA.DA_SERIE  = SD1.D1_SERIE
			AND SDA.DA_CLIFOR = SD1.D1_FORNECE
			AND SDA.DA_LOJA   = SD1.D1_LOJA
			AND SDA.DA_LOCAL  = SD1.D1_LOCAL
			AND SDA.DA_ORIGEM = %EXP:"SD1"%
			AND SDA.DA_SALDO  > %EXP:0%
			AND SDA.%NOTDEL%
		WHERE
			SD1.D1_FILIAL  = %EXP:SF1->F1_FILIAL%
		AND SD1.D1_DOC     = %EXP:SF1->F1_DOC%
		AND SD1.D1_SERIE   = %EXP:SF1->F1_SERIE%
		AND SD1.D1_FORNECE = %EXP:SF1->F1_FORNECE%
		AND SD1.D1_LOJA    = %EXP:SF1->F1_LOJA%
		AND SD1.%NOTDEL%
	EndSQl

	(cAlias)->(dbEval( { || nCount++ } ))
	(cAlias)->(dbGoTop())

	if nCount == 0
		alert("Sem itens disponíveis para o endereçamento!")
	else
		dbSelectArea("SDA")
		SDA->(dbSetOrder(1))

		ProcRegua( nCount )
		processMessage()

		While !(cAlias)->(EOF())
			incProc("Produto: " + allTrim((cAlias)->D1_COD) + " – Sequencial:"  + (cAlias)->DA_NUMSEQ )
			processMessage()

			SDA->(dbGoTop()) // posiciona o cabeçalho
			if SDA->(dbSeek( xfilial("SDA") + (cAlias)->D1_COD + (cAlias)->DA_LOCAL + (cAlias)->DA_NUMSEQ + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ))
				if SDA->DA_SALDO > 0
					lMsErroAuto := .F.

					aCabSDA := {}
					aAdd( aCabSDA, {"DA_PRODUTO" 	,SDA->DA_PRODUTO	, Nil} )
					aAdd( aCabSDA, {"DA_NUMSEQ" 	,SDA->DA_NUMSEQ 	, Nil} )

					aItSDB := {}
					aAdd( aItSDB, {"DB_ITEM" 	, '0001' 				, Nil} )
					aAdd( aItSDB, {"DB_ESTORNO"	, " " 					, Nil} )
					aAdd( aItSDB, {"DB_LOCALIZ"	, cLocal				, Nil} )
					aAdd( aItSDB, {"DB_DATA" 	, dDataBase 			, Nil} )
					aAdd( aItSDB, {"DB_QUANT" 	, SDA->DA_SALDO 		, Nil} )
					aAdd( aItSDB, {"DB_NUMSERI" , (cAlias)->D1_CHASSI 	, Nil} )

					aItensSDB := {}
					aadd( aItensSDB, aitSDB )
					MATA265( aCabSDA, aItensSDB, 3)

					If lMsErroAuto
						lRet := .F.
					Endif


				endif
			endif

			(cAlias)->(dbSkip())
		enddo
	endif
	(cAlias)->(dbCloseArea())

	RestArea(aAreaSDB)
	RestArea(aAreaSDA)
	RestArea(aAreaSF1)
	RestArea(aArea)

Return(lRet)

Static function IncVeiPrd(cDoc,cSerie,cFornece,cLoja)

	Local aArea		:= GetArea()
	Local aAreaSF1	:= SF1->(GetArea())
	Local aAreaSD1	:= SD1->(GetArea())

	//Local aDados := {}

	Local aCab   := {}
	Local axItem := {}
	Local aItens := {}

	Local cBkpFunName := ""
	//Local cChvSF1	  := ""

	Local nBkpModulo  := 0
	//local cNatNf	  := allTrim( superGetMv( "CMV_VE1NAT"	, , "2104"		) )	// Natureza para Nota fiscal SIGAVEI
	//Local lCont		  := .T.
	//Local cChaInt	  := ""

	Private lMsHelpAuto := .t.
	Private lMsErroAuto := .f.

	dbSelectArea("SF1")
	dbSetOrder(1)
	dbSeek(xFilial("SF1")+cDoc+cSerie+cFornece+cLoja)

	aAdd(aCab,{"VVF_CLIFOR"  ,"F"          				,Nil})
	aAdd(aCab,{"VVF_FORPRO"  ,"0"          				,Nil})
	aAdd(aCab,{"VVF_OPEMOV"  ,"0"          				,Nil})
	aAdd(aCab,{"VVF_DATMOV"  ,SF1->F1_DTDIGIT 	        ,Nil})
	aAdd(aCab,{"VVF_DATEMI"  ,SF1->F1_EMISSAO 	        ,Nil})
	aAdd(aCab,{"VVF_CODFOR"  ,SF1->F1_FORNECE   		,Nil})
	aAdd(aCab,{"VVF_LOJA"    ,SF1->F1_LOJA       		,Nil})
	aAdd(aCab,{"VVF_FORPAG"  ,SF1->F1_COND      		,Nil})
	aAdd(aCab,{"VVF_ESPECI"  ,SF1->F1_ESPECIE   		,Nil})
	aAdd(aCab,{"VVF_NUMNFI"  ,SF1->F1_DOC        		,Nil})
	aAdd(aCab,{"VVF_SERNFI"  ,SF1->F1_SERIE      		,Nil})
	aAdd(aCab,{"VVF_NATURE"	 ,"1101"					,Nil})
	aAdd(aCab,{"VVF_CHVNFE"  ,SF1->F1_CHVNFE    		,Nil})
	aAdd(aCab,{"VVF_RECSF1"	 ,SF1->(Recno())    		,Nil})

	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial("SD1")+cDoc+cSerie+cFornece+cLoja)

	aAdd(axItem,{"VVG_FILIAL"  , SD1->D1_FILIAL   , nil})
	aAdd(axItem,{"VVG_CHASSI"  , SD1->D1_CHASSI   , nil})
	aAdd(axItem,{"VVG_CODTES"  , SD1->D1_TES      , nil})
	aAdd(axItem,{"VVG_ESTVEI"  , "0"			  , nil})
	aAdd(axItem,{"VVG_LOCPAD"  , SD1->D1_LOCAL    , nil})
	aAdd(axItem,{"VVG_SITTRIB" , SD1->D1_CLASFIS  , nil})
	aAdd(axItem,{"VVG_VALUNI"  , SD1->D1_VUNIT    , nil})
	aAdd(axItem,{"VVG_VBAIPI"  , SD1->D1_BASEIPI  , nil})
	aAdd(axItem,{"VVG_VBAICM"  , SD1->D1_BASEICM  , nil})
	aAdd(axItem,{"VVG_ICMCOM"  , SD1->D1_VALICM   , nil})
	aAdd(axItem,{"VVG_VCNVEI"  , SD1->D1_TOTAL    , nil})

	AADD(aItens,axItem)

	cBkpFunName := FunName()
	nBkpModulo  := nModulo
	SetFunName('VEIXA001')
	nModulo := 11

	lMsHelpAuto := .T.
	lMsErroAuto := .F.

	aCols := {}

//	If SF1->(dbSeek(cChvSF1))
	MSExecAuto(;
		{ |a,b,c,d,e,f,g,h,i| ;
		VEIXX000(a       ,b         ,c      ,d   ,e      ,f       ,g         ,h          ,i      ) },;
	     aCab,aItens,{}     ,3   ,"0"    ,        ,.f.       ,           ,"3"    )
	SetFunName(cBkpFunName)
	nModulo := nBkpModulo

	If lMsErroAuto
		If (!IsBlind())
			MostraErro() // TELA
		Else
			// EM ESTADO DE JOB
			cError := ""
			cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

			ConOut(PadC("Automatic routine ended with error", 80))
			ConOut("Error: "+ cError)
		EndIf
	EndIf

	RestArea(aAreaSF1)
	RestArea(aAreaSD1)

	RestArea(aArea)

return
