#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "FWBROWSE.CH"
#Include "TBIConn.ch" 
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "SHELL.CH"

Static _oMark		As Object
Static _oDlgMark	As Object
Static _oCheckCli	As Object
Static _oCheckTra	As Object
Static _oCheckAll	As Object
Static _oCheckPDF	As Object
Static _oCheckXML	As Object
Static _lCheckCli   AS Logical
Static _lCheckTra 	AS Logical
Static _lCheckAll	AS Logical
Static _lCheckPDF	AS Logical
Static _lCheckXML	AS Logical


Static _dDataIni	:= CtoD(Space(08))
Static _dDataFim 	:= CtoD(Space(08))

Static _cNotaDe	 	:= Space(Len(SF2->F2_DOC))
Static _cNotaAte 	:= Space(Len(SF2->F2_DOC))
Static _cCodCli  	:= Space(Len(SF2->F2_CLIENTE))
Static _cLojaCli 	:= Space(Len(SF2->F2_LOJA))
Static _cCNPJCli 	:= Space(Len(SA1->A1_CGC))
Static _cEmailEsp	:= Space(200)
Static _aMsgPrcEmail:= {}

//Static _oOk       	:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
//Static _oNo       	:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO

/*/{Protheus.doc} ZFISF009
Gerar arquivo DANFE e XML
@param  	
@author 	DAC - Denilso
@version  	P12.1.25
@since  	01/02/2024
@return  	NIL
@obs
@project    GAP117.-.Exportacao.da.Danfe.e.XML.individualmente
@history    
/*/
User Function ZFISF009()
Local _cIdCab
Local _cIdGrid
//Local _lMarcar     	:= .F.
Local _oPanelUp
Local _oTela
Local _oPanelDown
Local _oGroup
Local _oFnt10    	:= TFont():New("Courier New",10,0)
Local _aAdvSize		:= {}
Local _aInfoAdvSize	:= {}
Local _aObjSize		:= {}
Local _aObjCoords	:= {}
Local _aArea 		:= GetArea()
Local _aRotina   	:= {}
Local _aColumns
Local _aCampos

	_lCheckCli	:= .F.
	_lCheckTra 	:= .F.
	_lCheckAll	:= .F.
	_lCheckPDF	:= .F.
	_lCheckXML	:= .F.
	_lTodos     := .F.

	DbSelectArea("SF2")
	//_aColsMark:= fMntColsMark()

	If Type("aRotina") == "A"	
 		_aRotina   	:= aRotina
	Endif	
	aRotina := MenuDef()
	//_aAdvSize		:= MsAdvSize( .F.,.F.,370)
	_aAdvSize		:= MsAdvSize( )
	_aInfoAdvSize	:= { _aAdvSize[1] , _aAdvSize[2] , _aAdvSize[3] , _aAdvSize[4] , 5 , 15 }
	aAdd( _aObjCoords , { 000 , 000 , .T. , .T. } )
	_aObjSize		:= MsObjSize( _aInfoAdvSize , _aObjCoords )
	
	Define MsDialog _oDlgMark From _aAdvSize[7],0 to _aAdvSize[6],_aAdvSize[5] Title "Envio Danfe XML Notas de Saida" Pixel  


	// Cria o conteiner onde ser? colocados os paineis
	_oTela     	:= FWFormContainer():New( _oDlgMark )
	_cIdCab	  	:= _oTela:CreateHorizontalBox( 25 )
	_cIdGrid   	:= _oTela:CreateHorizontalBox( 70 )

	_oTela:Activate( _oDlgMark, .F. )

	//Cria os paineis onde serao colocados os browses
	_oPanelUp  	:= _oTela:GeTPanel( _cIdCab )
	_oPanelDown	:= _oTela:GeTPanel( _cIdGrid )
 	
	_nLinha 	:= _aObjSize[1,2]
	_nCol   	:= 70
	_nLinha2 	:= _aObjSize[1,4] //*0.62
	//@ 0 , _aObjSize[1,2]	GROUP _oGroup TO 26,_aObjSize[1,4]*0.62 LABEL OemToAnsi("Filtrar Notas") OF _oPanelUp PIXEL	
	@ 0 , _nLinha	GROUP _oGroup TO _nCol,_nLinha2  LABEL OemToAnsi("Parametros Pesquisa") OF _oPanelUp PIXEL	
	
	_nLinha := _aObjSize[1,1]*0.2
	_nCol   := _aObjSize[1,2] + 10  
	//_oGroup:oFont:= _oFont

	@ _nLinha	, _nCol+1 	SAY   OemToAnsi("Emissão Inicial") SIZE 038,007 		OF _oPanelUp PIXEL
	@ _nLinha+6	, _nCol+1 	MSGET _dDataIni SIZE 040,007	OF _oPanelUp 		PIXEL WHEN .T. VALID .T.
	@ _nLinha	, _nCol+80 	SAY   OemToAnsi("Emissão Final") SIZE 038,007 			OF _oPanelUp PIXEL
	@ _nLinha+6	, _nCol+80	MSGET _dDataFim SIZE 040,007	OF _oPanelUp  		PIXEL WHEN .T. VALID !Empty(_dDataFim) .And. _dDataFim >= _dDataIni
	@ _nLinha	, _nCol+160 SAY   OemToAnsi("Nota Fiscal De") SIZE 038,007 		OF _oPanelUp PIXEL
	@ _nLinha+6	, _nCol+160 MSGET _cNotaDe SIZE 010,007		OF _oPanelUp F3 'SF2' PIXEL WHEN .T. VALID .T.
	@ _nLinha	, _nCol+240 SAY   OemToAnsi("Nota Fiscal Ate") SIZE 038,007 	OF _oPanelUp PIXEL
	@ _nLinha+6	, _nCol+240	MSGET _cNotaAte SIZE 010,007	OF _oPanelUp F3 'SF2' PIXEL WHEN .T. VALID .T.
   	_oCheckCli := TCheckBox():New(_nLinha, _nCol+500, "Envia e-mail para Clientes", /*{||_lCheckCli }*/, _oPanelUp, 100, 210,,,,,,,,.T.,,,)
	//_oCheckCli := TCheckBox():Create( _oDlgMark,{||_lCheckCli},_nLinha, _nCol+500,'Envia e-mail para Clientes',100,210,,,,,,,,.T.,'Envia e-mail para Clientes',,)
	_oCheckCli:bLClicked := {|| _lCheckCli:=!_lCheckCli}
	_nLinha += 20
	@ _nLinha	, _nCol+1 	SAY   OemToAnsi("Cod. Cliente") SIZE 038,007 	OF _oPanelUp PIXEL
	@ _nLinha+6 , _nCol+1	MSGET _cCodCli SIZE 050,007	OF _oPanelUp  	F3 'SA1'	PIXEL WHEN .T. VALID ZFIS09ClilVld(_cCodCli)
	@ _nLinha	, _nCol+80 	SAY   OemToAnsi("Loja Cliente") SIZE 038,007 	OF _oPanelUp PIXEL
	@ _nLinha+6 , _nCol+80	MSGET _cLojaCli SIZE 050,007	OF _oPanelUp  				PIXEL WHEN .T. VALID ZFIS09ClilVld(_cCodCli, _cLojaCli)
	@ _nLinha	, _nCol+160 SAY   OemToAnsi("CNPJ Cliente") SIZE 038,007 	OF _oPanelUp PIXEL
	@ _nLinha+6 , _nCol+160	MSGET _cCNPJCli SIZE 050,007	OF _oPanelUp  				PIXEL WHEN .T. VALID ZFIS09ClilVld(/*_cCodCli*/, /*_cLojaCli*/, _cCNPJCli)

   	_oCheckPDF := TCheckBox():New(_nLinha+6, _nCol+240, "Gerar DANFE",/* {||_lCheckPDF }*/, _oPanelUp, 100, 210,,,,,,,,.T.,,,)
	_oCheckPDF:bLClicked := {|| _lCheckPDF:=!_lCheckPDF}

   	_oCheckXML := TCheckBox():New(_nLinha+6, _nCol+320, "Gerar XML", /*{||_lCheckXML }*/, _oPanelUp, 100, 210,,,,,,,,.T.,,,)
	_oCheckXML:bLClicked := {|| _lCheckXML:=!_lCheckXML}

   	_oCheckTra := TCheckBox():New(_nLinha, _nCol+500, "Envia e-mail para Transportador", /*{||_lCheckTra }*/, _oPanelUp, 100, 210,,,,,,,,.T.,,,)
	_oCheckTra:bLClicked := {|| _lCheckTra:=!_lCheckTra}
	
	_nLinha += 20
	@ _nLinha	, _nCol+1 	SAY   OemToAnsi("E-mail Especifico") SIZE 038,007 	OF _oPanelUp PIXEL
	@ _nLinha+6 , _nCol+1	MSGET _cEmailEsp SIZE 350,007	OF _oPanelUp  		PIXEL WHEN .T. VALID ZFIS09VldEmail(_cEmailEsp)
   	_oCheckAll := TCheckBox():New(_nLinha, _nCol+500, "Envia e-mail para Todos", /*{||_lCheckAll }*/, _oPanelUp, 100, 210,,,,,,,,.T.,,,)
	_oCheckAll:bLClicked := {|| _lCheckAll:=!_lCheckAll}

    //Preparar visualização de colunas   
    _aColumns := {}
    _aCampos  := {}
    Aadd(_aCampos,{"F2_DOC"     , PesqPict("SF2","F2_DOC")}  ) 
    Aadd(_aCampos,{"F2_SERIE"   , PesqPict("SF2","F2_SERIE")} )  
    Aadd(_aCampos,{"F2_CLIENTE" , PesqPict("SF2","F2_CLIENTE")} )  
    Aadd(_aCampos,{"F2_LOJA"    , PesqPict("SF2","F2_LOJA")} )  
    Aadd(_aCampos,{"F2_EMISSAO" , PesqPict("SF2","F2_EMISSAO")} )  
    Aadd(_aCampos,{"F2_EST"     , PesqPict("SF2","F2_EST")} )  
    aEval(_aCampos, { |e| Aadd(_aColumns, { Posicione('SX3', 2, AllTrim(e[1]), 'X3Titulo()'), e[1], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,e[2]} ) } )

	_oMark := FWMarkBrowse():New()
    _oMark:SetAlias( "SF2" )
    _oMark:SetFields(_aColumns)
    _oMark:SetFontBrowse(_oFnt10) 
    _oMark:SetDescription("Selecionar Notas ")  
	//Indica o container onde sera criado o browse
	_oMark:SetOwner(_oPanelDown)
    //Indicador do campo que sofrerá o checklist
    _oMark:SetFieldMark( 'F2_OK' )
    //Cria botão sair caso não esteja previsto  
    _oMark:ForceQuitButton()                  
    _oMark:SetMenuDef( 'ZFISF009' )
    _oMark:AddLegend( "F2_FIMP==' ' .AND. AllTrim(F2_ESPECIE)=='SPED'"  , "DISABLE" , OemToAnsi("NF não transmitida")  )  
    _oMark:AddLegend( "F2_FIMP=='S'"                                    , "ENABLE"  , OemToAnsi("NF Autorizada")  )  
    _oMark:AddLegend( "F2_FIMP=='T'"                                    , "BR_AZUL" , OemToAnsi("NF Transmitida")  )  
    _oMark:AddLegend( "F2_FIMP=='D'"                                    , "BR_CINZA" , OemToAnsi("NF Uso Denegado")  )  
    _oMark:AddLegend( "F2_FIMP=='N'"                                    , "BR_PRETO" , OemToAnsi("NF nao autorizada")  )  
    _oMark:AddButton("Envia Docto" 	    , { || FwMsgRun(,{ | _oSay | If(ZFISF09Processa( @_oSay), _oDlgMark:End(),_oMark:Refresh(.T.)) }    , "Processando Arquivo "       , "Aguarde...")  },,,, .F., 2 )  
    _oMark:AddButton("Sel Parametros"   , { || FwMsgRun(,{ | _oSay | ZFISF009Filtro( @_oSay), _oMark:Refresh(.T.) } , "Processando Arquivo "       , "Aguarde...")  },,,, .F., 2 )  

    //_oMark:bAllMark := { || MsgInfo("Opção desabilitada", "Atenção")  }
	//_oMark:bAllMark := { || SetMarkAll(_oMark:Mark(),_lTodos := !_lTodos ), _oMark:Refresh(.T.)  }
	_oMark:bAllMark := { || FwMsgRun(,{ |_oSay| SetMarkAll( @_oSay, _oMark:Mark(),_lTodos := !_lTodos ) }, "Selecionando Registros", "Aguarde..."), _oMark:Refresh(.T.)  }

	_oMark:DisableReport()
	_oMark:SetInvert(.F.)
	_oMark:SetValid({||ZFISF09MRK()})
    //_oMark:SetDoubleClick({||ZFISF09MRK()})   
	//Indica o Code-Block executado no clique do header da coluna de marca/desmarca
  	//_lMarcar := .T.
	//   (Marca somente linhas que houveram itens selecionados na função 
	//_oMark:SetCustomMarkRec({||ZFISF09MRK()})  
    //Função para Validar registro selecionado 
    //_oMark:SetSemaphore(.T.)     
    //_oMark:Valid(U_???MRK())
    //_oMark:SetValid({||U_???MRK()})
    //_oMark:SetDoubleClick({||U_???MRK() })
    //_oMark:SetCustomMarkRec({||U_????})
    //_oMark:SetDoubleClick({||U_?????MRK()})   
	//_oMark:SetEditCell ( .T., {||U_?????()} )
    //_oMark:AddMarkColumns({| If(ZFISF09MRK(), _oOk, _oNo ) })
	//_oMark:SetAfterMark({|| ZFISF006VL() })
    //Montar legenda 
    //BOTOES
	//MARCAR TODOS
	//_oMark:SetMark( _cMarca, "SF2", "F2_OK" )
	_oMark:Activate()
	//_oMark:oBrowse:SetFocus() //Seta o foco na grade
	ACTIVATE MSDIALOG _oDlgMark CENTERED
	
//Voltar menu anterior
If Len(_aRotina) > 0
	aRotina := _aRotina
Endif
RestArea(_aArea)

Return Nil


/*/{Protheus.doc} ZFISF09MRK
Validação quando da seleção do registro no objeto mark
@author 
@since 
@version 1.0
@Obs
@History
/*/
Static Function ZFISF09MRK(_lTodos)
Local _lRet 	:= .T.
Local _cMarca 	:= _oMark:Mark()
//Local _nPosCol  := _oMark:oBrowse:ColPos()

Default _lTodos := .F.  //indica que foi selecionado todos

Begin Sequence               
	If SF2->F2_FIMP <> 'S'
		If !_lTodos
			MsgInfo("Somente selecionar as notas com Status Autorizado", "Atenção")
		Endif				
		_lRet := .F.
		Break
	Endif 
    //Caso esteja marcando irá desmarcar
    If _oMark:IsMark(_cMarca)  
      Break
    Endif
	//Verificar se existe email caso seja selecionado cliente ou transportador
	If _lCheckCli .Or. _lCheckTra .Or. _lCheckAll
		_lRet := ZFISF09VCTEmail( )
	Endif 
	//Montar validação em relação aos relacionamentos verificar se ja esta selecionado pois outro usuário pode acessar
End Sequence
Return _lRet 

//Marcar Todos
Static Function  SetMarkAll( _oSay, _cMarca, _lMarcar )
Local _nSelLimite 	:= SuperGetMV('CMV_ZFI9RS',,30)  //Controle de registros selecionados permite seleção até a quantidade informada neste parâmetro
Local _nPocessado 	:= 0
Local _nSelecionado	:= 0
	SF2->(DbGotop())
	While SF2->(!Eof())
		_nPocessado ++	
		If SF2->F2_FIMP == 'S' .And. RecLock( "SF2", .F. )
			_nSelecionado ++
			SF2->F2_OK	:= IIf( _lMarcar, _cMarca, '  ' )
			SF2->(MsUnlock())
		Endif
		_oSay:SetText("Registros Lidos: "+StrZero(_nPocessado,6)+" Registros Selecionados: "+ StrZero(_nSelecionado,6))
		ProcessMessage()
		If _nSelLimite < _nSelecionado
			MSGInfo("Limite "+AllTrim(Str(_nSelLimite))+" de Seleção Registros atingido, não selecionara mais registros  !","ATENCAO")
			Exit
		Endif
		SF2->(DbSkip())
	Enddo

Return Nil

/*/{Protheus.doc} ZFISF09Processa
Processa a geração e envio de e-mail caso existam@author 
@since 
@version 1.0
@Obs
@History
/*/
Static Function ZFISF09Processa( _oSay) 
Local _cMarca   := _oMark:Mark()
Local _cPasta   := ""
Local _cAlias 	:= GetNextAlias()
Local _lRet 	:= .T.
Local _cType 	:= OemToAnsi("Todos") + "(*.*) |*.*|"
Local _nSelLimite 	:= SuperGetMV('CMV_ZFI9RS',,30)  //Controle de registros selecionados permite seleção até a quantidade informada neste parâmetro
Local _nPos
Local _nRegSelect

Begin Sequence
	//verificar se foram selecionados os registros para envio
	If !_lCheckPDF .And. !_lCheckXML 
		MSGInfo("Informar se envia DANFE e XML  !","ATENCAO")
		_lRet := .F.
		Break
	Endif
 
    //Define o nome do alias temporário
	BeginSql Alias _cAlias  
        %NoParser%
       	SELECT SF2.R_E_C_N_O_    AS  NREGSF2
		FROM %Table:SF2% SF2
		WHERE SF2.%notDel%
			AND SF2.F2_FILIAL 	= %xFilial:SF2%
            AND SF2.F2_OK 		= %Exp:_cMarca%
		GROUP BY(SF2.R_E_C_N_O_)	
    EndSQL
    If  (_cAlias)->(Eof()) .Or. (_cAlias)->NREGSF2 == 0
		_lRet := .F.
		Break
    Endif

	(_cAlias)->(DbGotop())
	Count To _nRegSelect	
	(_cAlias)->(DbGotop())
	//Não permitir selecionar muitos registros
	If _nSelLimite < _nRegSelect
		MSGInfo("Limite "+AllTrim(Str(_nSelLimite))+" de Seleção Registros atingido, não será gerado processo de envio  !","ATENCAO")
		_lRet := .F.
		Break
	Endif

	//Selecionar pasta para geração
	_cPasta := cGetFile(_cType, OemToAnsi("Selecione a Pasta "), 0,, .T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY,)
	//³ Parametro: GETF_LOCALFLOPPY - Inclui o floppy drive local.   ³
	//³            GETF_LOCALHARD - Inclui o Harddisk local.         ³
	If Empty(_cPasta)
		MSGInfo("Necessário informar uma pasta para a geração do arquivo  !","ATENCAO")
		_lRet := .F.
		Break
	Endif

	_aMsgPrcEmail := {}  //Serão gravados todas as atividades e erros nesta matriz
    While (_cAlias)->(!Eof())
		SF2->(DbGoto((_cAlias)->NREGSF2))
        If SF2->F2_OK == _cMarca
			_oSay:SetText("Processando nota fisca: "+SF2->F2_DOC)
			ProcessMessage()
            //MProcDanfe(_cPasta, @_cArquivo)
            SF2->(MProcDanfe(_cPasta, @_oSay))
			RecLock( "SF2", .F. )
			SF2->F2_OK := '  ' 
			SF2->(MsUnLock())
        Endif 
		(_cAlias)->(DbSkip()) 
    EndDo
	If Len(_aMsgPrcEmail) > 0
		_cMens := "Inconsistências no envio dos e-mails"+ CRLF
		For _nPos := 1 To Len(_aMsgPrcEmail)
			_cMens += _aMsgPrcEmail[_nPos]
		Next
		MsgInfo(_cMens, "Atenção")    
	Endif
	MsgInfo("Gerado arquivos conforme pasta "+_cPasta+" informada", "Atenção")    
    _oMark:Refresh(.T.)

End Sequence 
If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif  
Return _lRet


/*/{Protheus.doc} MProcDanfe
Processar a Danfe e enviar e-mail
@author 
@since 
@version 1.0
@Obs
@History
/*/
STATIC Function MProcDanfe( _cPasta, _oSay )
Local nA         	:= 0
Local cMensagem  	:= ""
Local cDir       	:= "" //SuperGetMV('MV_RELT',,"\SPOOL\")
Local cNomeArquivo  := ""
Local _aEnvia		:= {}
Local _lRet 

Private cPegaXml   := ""  //Obtido dentro da rotina da Danfe (danfeii.prw - PrtNfeSef). tem que existir uma variavel Private nestga função
Private cXMensagem := ""

Begin Sequence
    If  FindFunction("ColUsaColab")
        lUsaColab := ColUsaColab("1")
    EndIf
    //Processar na filial 01001 a nota de saida.
    XSpedDanfe(0/*nTipo*/, 2/*nPar*/, @cNomeArquivo, @cDir, _cPasta)
    If  !File(cDir + cNomeArquivo + ".pdf")
    	Do  While (++nA < 5)
        	Sleep(1000)  //espera pelo pdf
        	If  File(cDir + cNomeArquivo + ".pdf")
            	Exit
        	EndIf
    	EndDo
	Endif
    If  !( File(cDir + cNomeArquivo + ".pdf") )
		MsgInfo(If(!Empty(cXMensagem), cXMensagem, "Problema para gerar o arquivo pdf! "), "Atenção")
		_lRet := .F.
        Break
    EndIf
	//Grava arquivo PDF
	If _lCheckPDF
    	_lRet := __CopyFile(cDir + cNomeArquivo + ".pdf", _cPasta+cNomeArquivo+".pdf",,,.F.)
		If !_lRet
			MsgInfo("Não foi possivel copiar arquivo "+cDir + cNomeArquivo + ".pdf !", "Atenção")
			Break 
		Endif
	Endif 	
	//Grava arquivo XML
	If _lCheckXML 
    	MemoWrit(cDir + cNomeArquivo + ".xml", cPegaXml)
	    _lRet := __CopyFile(cDir + cNomeArquivo + ".xml", _cPasta+cNomeArquivo+".xml",,,.F.)
		If !_lRet
			MsgInfo("Não foi possivel copiar arquivo "+cDir + cNomeArquivo + ".xml !", "Atenção")
			Break 
		Endif
	Endif	
	//Para enviar e-mai tem que estar informado um destes processos
	If 	!Empty(_cEmailEsp) .Or. _lCheckCli 	.Or. _lCheckTra .Or. _lCheckAll  
		_oSay:SetText("Enviando e-mail nota fisca: "+SF2->F2_DOC)
		ProcessMessage()
		If _lCheckPDF
			Aadd(_aEnvia,cDir+cNomeArquivo+".pdf") 
		Endif 
		If _lCheckxmlXML
			Aadd(_aEnvia,cDir+cNomeArquivo+".xml")
		Endif 
		ZFIS09Email(_aEnvia)
	Endif 
    //MEnviarEMail(cDir + cNomeArquivo + ".pdf", cDir + cNomeArquivo + ".xml", @cMensagem)
End Sequence
Return cMensagem


/*/{Protheus.doc} XSpedDanfe
Adaptado para gerar o pdf da Danfe via job.
@author Antonio C Ferreira
@since 24/06/2021
@version 1.0
Obs
History
/*/
STATIC Function XSpedDanfe(nTipo, nPar, cFilePrint, cDir, _cPasta)
Local cIdEnt 		:= ""
Local aIndArq   	:= {}
Local aDevice  		:= {}
Local cSession  	:= GetPrinterSession()
//Local nRet 			:= 0
Local lUsaColab		:= ColUsaColab("1")
local cBarra		:= ""
local nX 			:= 0
local lJob			:= .T. //isBlind()
local lDanfeII		:= findfunction("u_PrtNfeSef")
local lDanfeIII		:= findfunction("u_DANFE_P1")
local cMsgVld		:= ""
Local oDanfe
Local oSetup

Default nTipo		:= 0
Default nPar		:= 0
Default cFilePrint	:= ""
Default cDir 		:= SuperGetMV('MV_RELT',,"\SPOOL\")

Private lNaoPreview := .T.  //Para nao abrir o pdf.
Private oXTemLog    := Nil

	/*
	If findfunction("U_DANFE_V") .and. if(lJob, nPar == 1, .T.)
		nRet := U_Danfe_v()
	Elseif findfunction("U_DANFE_VI") .and. if(lJob, nPar == 2, .T.)// Incluido esta validaþÒo pois o cliente informou que nÒo utiliza o DANFEII
		nRet := U_Danfe_vi()
	EndIf
	*/
	AADD(aDevice,"DISCO") // 1
	AADD(aDevice,"SPOOL") // 2
	AADD(aDevice,"EMAIL") // 3
	AADD(aDevice,"EXCEL") // 4
	AADD(aDevice,"HTML" ) // 5
	AADD(aDevice,"PDF"  ) // 6

	cIdEnt := RetIdEnti(lUsaColab)
	cFilePrint := "DANFE_"+AllTrim(SF2->F2_DOC)+Dtos(MSDate())+StrTran(Time(),":","")
	nLocal       	:= If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
	nOrientation 	:= If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
	cDevice     	:= If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
	nPrintType      := aScan(aDevice,{|x| x == cDevice })
	//+-------------------------------------------+
	//|Ajuste no pergunte NFSIGW                  |
	//+-------------------------------------------+
	//AjustaSX1()

	cBarra := "\"
	if IsSrvUnix()
		cBarra := "/"
	Endif
	If  CTIsReady(,,,lUsaColab)
		dbSelectArea("SF2")
		RetIndex("SF2")
		dbClearFilter()
		//+------------------------------------------------------------------------+
		//|Obtem o codigo da entidade                                              |
		//+------------------------------------------------------------------------+
		If  .T. //nRet >= 20100824
			If Empty(cDir)
				cDir := SuperGetMV('MV_RELT',,"\SPOOL\")
			Endif 

			if !empty(cDir) .and. !ExistDir(cDir)
				aDir := StrTokArr(cDir, cBarra)
				cDir := ""
				for nX := 1 to len(aDir)
					cDir += aDir[nX] + cBarra
					if !ExistDir(cDir)
						MakeDir(cDir)
					endif
				next
			Endif
			If  (nTipo <> 1)
				lAdjustToLegacy := .F. // Inibe legado de resoluþÒo com a TMSPrinter
				oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, cDir /*cPathInServer*/, .T. )
				//cFilePrint := cDir + cFilePrint
				//File2Printer( cFilePrint, "PDF" )
				oDanfe:cPathPDF := cDir

				if  lJob
					oDanfe:SetViewPDF(.F.)
					oDanfe:lInJob := .T.
				endif
				// ----------------------------------------------
				// Cria e exibe tela de Setup Customizavel
				// OBS: Utilizar include "FWPrintSetup.ch"
				// ----------------------------------------------
				//nFlags := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
				nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
				If ( !oDanfe:lInJob )
					oSetup := FWPrintSetup():New(nFlags, "DANFE")
					// ----------------------------------------------
					// Define saida
					// ----------------------------------------------
					oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
					oSetup:SetPropert(PD_ORIENTATION , nOrientation)
					oSetup:SetPropert(PD_DESTINATION , nLocal)
					oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
					oSetup:SetPropert(PD_PAPERSIZE   , 2)

					If ExistBlock( "SPNFESETUP" )
						Execblock( "SPNFESETUP" , .F. , .F. , {oDanfe, oSetup} )
					Endif
				EndIf
				// ----------------------------------------------
				// Pressionado botÒo OK na tela de Setup
				// ----------------------------------------------
				If lJob .or. oSetup:Activate() == PD_OK // PD_OK =1
					//+-------------------------------------------+
					//|Salva os Parametros no Profile             |
					//+-------------------------------------------+
					fwWriteProfString( cSession, "LOCAL"      , if( lJob, "SERVER"		, If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    )), .T. )
					fwWriteProfString( cSession, "PRINTTYPE"  , if( lJob, "PDF"		, If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       )), .T. )
					fwWriteProfString( cSession, "ORIENTATION", if( lJob, "PORTRAIT"	, If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" )), .T. )
					// Configura o objeto de impressÒo com o que foi configurado na interface.
					oDanfe:setCopies( val( if( lJob, "1", oSetup:cQtdCopia )) )
	                //oXTemLog := XTemLog():New("001")
					If  .T. //( lJob .and. nPar == 1 ) .or. ( !lJob .and. oSetup:GetProperty(PD_ORIENTATION) == 1 )
						//+-------------------------------------------+
						//|Danfe Retrato DANFEII.PRW                  |
						//+-------------------------------------------+
						if(lDanfeII, u_PrtNfeSef(cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,cFilePrint , .T./*lIsLoja*/, /*nTipo*/), cMsgVld := "Fonte de impressÒo de DANFE nÒo compilado !")
					ElseIf ( lJob .and. nPar == 2 ) .or. !lJob
						//+-------------------------------------------+
						//|Danfe Paisagem DANFEIII.PRW                |
						//+-------------------------------------------+
						if(lDanfeIII, u_DANFE_P1(cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,/*lIsLoja*/ ), cMsgVld := "Fonte de impressÒo de DANFE nÒo compilado !" )
					EndIf
				Endif
			ElseIf nTipo == 1
				if(lDanfeII, U_PrtNfeSef(cIdEnt ,/*cVal1*/ ,/*cVal2*/ , , , ,/*lIsLoja*/, 1), cMsgVld := "Fonte de impressÒo de DANFE nÒo compilado !")
			EndIf
		Else
			if(lDanfeII, U_PrtNfeSef(cIdEnt ,/*cVal1*/ ,/*cVal2*/ , , , ,/*lIsLoja*/), cMsgVld := "Fonte de impressÒo de DANFE nÒo compilado !")
		EndIf
		if !lJob
			if !empty(cMsgVld)
				Help(NIL, NIL, "RDMAKE", NIL, cMsgVld, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Acesse o portal do cliente baixe os fontes DANFEII.PRW, DANFEIII.PRW e compile em seu ambiente"})
			endif
			Pergunte("NFSIGW",.F.) 
			if  .F. //len(aFilBrw) > 0
				bFiltraBrw := {|| FilBrowse(aFilBrw[1],@aIndArq,@aFilBrw[2])}
				Eval(bFiltraBrw)
			endif
		EndIf
	EndIf

oDanfe := Nil
oSetup := Nil
//Limpa arquivos temporarios .rel da pasta MV_RELT
//SpedCleRelt()
Return .T.


/*/{Protheus.doc} ZFISF009Filtro
Executa Filtro
@since 
@version 1.0
@Obs
@History
/*/
Static Function ZFISF009Filtro(_oSay)
Local _cFiltro := ""

	DbSelectAre("SF2")

	_cFiltro  +=  " 	F2_FILIAL = '"+xFilial('SF2')+"'"
	If ! Empty(_cNotaAte)
		_cFiltro  +=  "	AND F2_DOC BETWEEN '" + _cNotaDe + "' AND '" + _cNotaAte + "' "+ CRLF 
	Endif
	If !Empty(_cCodCli) .And. Empty(_cCNPJCli)
		_cFiltro  +=  "	AND F2_CLIENTE = '" + _cCodCli + "' "+ CRLF 
		If !Empty(_cLojaCli)
			_cFiltro  +=  "	AND F2_LOJA = '" + _cLojaCli + "' "+ CRLF 
		Endif 
	Endif
	If !Empty(_cCNPJCli)
		SA1->(DbSetOrder(3))
		If SA1->(DbSeek(FWxFilial("SA1")+_cCNPJCli))
			_cFiltro  +=  "	AND F2_CLIENTE = '" + SA1->A1_COD + "' AND F2_LOJA = '"+SA1->A1_LOJA+"' "+ CRLF 
		Endif 
	Endif

	If !Empty(_dDataFim)
		_cFiltro  +=  "	AND F2_EMISSAO BETWEEN '" + DtoS(_dDataIni) + "' AND   '"+DtoS(_dDataFim)+"' "+ CRLF 
	Endif

	_oMark:SetFilterDefault("@"+_cFiltro)
    _oMark:Refresh(.T.)

Return _cFiltro



/*/{Protheus.doc} ZFIS09Email
Função para preparar envio de e-mail
@since 
@version 1.0
@Obs
@History
/*/
Static Function ZFIS09Email( _aArqEnvio )
Local _cAssunto		:= ""
Local _cEmails		:= ""
Local _cEMailCopia	:= ""
Local _aAnexos 		:= {}
Local _aMens		:= {}
Local _aErro		:= {}
Local _lRet 		:= .T.
Local _cEmailAcp    := AllTrim(SuperGetMV( "CMV_ZFIS09" , ,"" ))
Local _nPos

Default _cArqPdf := ""
Default _cArqXml := ""
	_cAssunto := "Envio Danfe e XML Nota Fiscal "+SF2->F2_DOC+ "  SERIE "+ SF2->F2_SERIE 
	//Incluir arquivos para envio
	If Len(_aArqEnvio) > 0
		_aAnexos := _aArqEnvio
	Endif

	Aadd( _aMens, "Danfe referente a envio cliente "+SF2->F2_CLIENTE+"-"+SF2->F2_LOJA+ "  "+AllTrim(SA1->A1_NOME) )
	//Verifica se envia e-mail para cliente
	If 	_lCheckCli 	.Or. _lCheckAll
		//Locallizar Cliente
		SA1->(DbSeek(FwXFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		If Empty(SA1->A1_EMAIL) .Or. SA1->(Eof())
			Aadd(_aErro,"Não esta cadastrado Email do Cliente codigo "+SF2->F2_CLIENTE+ " Loja "+SF2->F2_LOJA)
		Else
			_cEmails += AllTrim(SA1->A1_EMAIL) +","
		Endif	 
	Endif
	//Verifica se envia E-mai para Transportador
	If 	!Empty(SF2->F2_TRANSP) .And. (_lCheckTra .Or. _lCheckAll)
		SA4->(DbSetOrder(1))
		SA4->(DbSeek(FwXFilial("SA4")+SF2->F2_TRANSP))
 		If Empty(SA4->A4_EMAIL) .Or. SA4->(Eof())
			Aadd(_aErro,"Não esta cadastrado e-mail do Transportador codigo "+SF2->F2_TRANSP+ " nota "+SF2->F2_DOC+ " serie "+SF2->F2_SERIE)
		Else
			_cEmails += AllTrim(SA4->A4_EMAIL) +"," 
		Endif 	
	Endif
	//Verifica se existem e-mail's informado cliente fornecedor caso não exista ainda sim vai enviar especifico
	If !Empty(_cEmails)
		_cEMailCopia += AllTrim(_cEmailEsp) +","
	Else 
		_cEmails += AllTrim(_cEmailEsp) +","
	Endif 
	//Se não tiver e-mail para enviar 
	If Empty(_cEmails) 
		Aadd(_aErro,"Não foram localizados e-mails para envio do Cliente codigo "+SF2->F2_CLIENTE+ " Loja "+SF2->F2_LOJA+ " nota "+SF2->F2_DOC+ " serie "+SF2->F2_SERIE)
    Else  
		_cEmails := SubsTr(_cEmails,1,Len(_cEmails)-1)
		If !Empty(_cEMailCopia)
			_cEMailCopia := SubsTr(_cEMailCopia,1,Len(_cEMailCopia)-1)
		Endif
		_lRet := ZFISF009EM(SF2->F2_DOC, SF2->F2_SERIE, _aMens, _cAssunto, _cEmails, _cEMailCopia, _aAnexos,  /*_cRotina*/, /*lSchedule*/,/*_lMsgTela*/)
		//ocorreu problemas no envio de Email
		If !_lRet
			Aadd(_aErro,"Ocorreram erros nos envio de e-mails para envio do Cliente codigo "+SF2->F2_CLIENTE+ " Loja "+SF2->F2_LOJA+ " nota "+SF2->F2_DOC+ " serie "+SF2->F2_SERIE)
		Endif 
	Endif 
	//caso ocorra erro tentar enviar para e-mail de acompanhamento 
	If Len(_aErro) > 0 .And. !Empty(_cEmailAcp)
		_lRet = .F.
		_cAssunto := "ZFIS09Email Problemas ocorrido no Envio Danfe e XML Nota Fiscal "+SF2->F2_DOC+ "  SERIE "+ SF2->F2_SERIE 
		Conout(_cAssunto)	
		//acrescento no processo ja gerado os erros a serem enviados
		For _nPos := 1 To Len(_aErro)
			Aadd(_aMens,_aErro[_nPos])
			Aadd(_aMsgPrcEmail,_aErro[_nPos])  //guardar para mostrar no final assim não impedira o processamento das demais notas caso existam
			Conout("Ocorrencia: "+_aErro[_nPos])
		Next	
		_cEmails  		:= _cEmailAcp
		_cEMailCopia	:= AllTrim(_cEmailEsp)
		ZFISF009EM(SF2->F2_DOC, SF2->F2_SERIE, _aMens, _cAssunto, _cEmails, _cEMailCopia, _aAnexos,  /*_cRotina*/, /*lSchedule*/,/*_lMsgTela*/)
		Conout("Email:"+_cEmails)
		Conout("Email cópia"+_cEMailCopia)
	Endif 
Return _lRet



/*
=====================================================================================
Programa.:              ZFISF009EM
@param 					_cNota		= Numero da nota 
						_cSerie		= Serie da nota
						_aMens   	= Mensagens de erro 
						_cAssunto   = Assunto do e-mail 
						_cEmails    = Destinatário do e-mail 
						_cEMailCopia= Destinatarios em cópia 
						_aAnexos 	= Localização e nome do arquivo anexo 
						_cRotina    = Rotina que chamou o processo
						lSchedule	= Esta rodando em job se verdadeiro não emitira msg em tela
Autor....:              CAOA - DAC Denilso 
Data.....:              02/02/2024
Descricao / Objetivo:   Funcao para processar o envio das notificacoes
Obs......:
=====================================================================================
*/
Static Function ZFISF009EM(	_cNota, _cSerie, _aMens, _cAssunto, _cEmails, _cEMailCopia, _aAnexos,  _cRotina, lSchedule, _lMsgTela)
Local _cTexto   		:= ""
Local _cEmailDest 		:= ""
Local _lMsgOK			:= .T.
Local _lMsgErro			:= .F.
Local _cObsMail			:= ""
Local _cReplyTo			:= ""
//Local _cCorItem			:= "FFFFFF"
Local _lEnvia			:= .T.
Local _cLogo  			:= "lg_caoa.png"
//Local _cCodUsu			:= RetCodUsr()
Local _cNomeUsu 		:= Upper(FwGetUserName(RetCodUsr())) //Retorna o nome completo do usuário  __cUserId
//Local _nPos

Default _lSchedule   	:= .T.
Default _cAssunto		:= "Envio arquivos"
Default _cEmails 		:= AllTrim(SuperGetMV("CMV_ZFIS09",.F.,""))  //E-mail para envio problemas integração TOTVS x MES 
Default _aAnexos		:= {}
Default _aChave			:= {}
Default _cEMailCopia	:= ""
Default _cRotina		:= "ZFISF009"
Default _lMsgTela		:= .F.

	_lMsgErro			:= IF( _lSchedule == .F., .T. , .F. )
	If Empty(_cEmails)
		_cTexto := "**** Erros referente ao processo de envio arquivos não possui e-mail cadastrado no parâmetro CMV_ZFIS09****"
		_cTexto += "     Os mesmos serão gravados no log do Sistema conforme informações abaixo: " 
		Aadd(_aMsgPrcEmail, _cTexto)
		Return .F.
	EndIf	
	_cEmailDest := _cEmails
	//Carregar informações corpo e-mail
	_cHtml := ZFISF009HTML( _cLogo, _cNota, _cSerie, _cNomeUsu, _aMens)
	//ConOut(_cAssunto)
	//ConOut(_cAssunto)
	/*
	cMailDestino	- E-mail de Destino
	cMailCopia		- E-mail de cópia
	cAssunto		- Assunto do E-mail
	cHtml			- Corpo do E-mail
	aAnexos			- Anexos que será enviado
	lMsgErro		- .T. Exige msgn na tela - .F. Exibe somente por Conout
	cReplyTo		- Responder para outra pessoa.
	cRotina			- Rotina que está sendo executada.
	cObsMail		- Observação para Gravação do Log.
	*/
	If _lSchedule
		_lEnvia := U_ZGENMAIL(_cEmailDest,_cEMailCopia,_cAssunto,_cHtml,_aAnexos,_lMsgErro,_lMsgOK,_cRotina,_cObsMail,_cReplyTo)
	Else
		MsgRun("Enviando e-mail de notificação. Aguarde!!!","CAOA",{|| _lEnvia := U_ZGENMAIL(_cEmailDest,_cEMailCopia,_cAssunto,_cHtml,_aAnexos,_lMsgErro,_lMsgOK,_cRotina,_cObsMail,_cReplyTo) })
	EndIf

	//lEnvioOK := GPEMail(cAssunto, cCorpo, cPara, aAnexos)
	//lEnvioOK := GPEMail(_cAssunto, _cHtml, _cEmailDest, _aAnexos)

	If !_lEnvia
		If lSchedule
			ConOut("**** [ ZFISF009EM ] - E-mail não cadastrado para envio - Solicitar apoio do administrador! (Totvs Integração MES) ****"+ CRLF)
			Return .F.
		ElseIf _lMsgTela
			ApMsgInfo("E-mail não cadastrado para envio - Solicitar apoio do administrador!! (Totvs Integração MES)","Cadastro")
			Return .F.
		Else 
			ConOut("**** [ ZFISF009EM ] - E-mail não cadastrado para envio - Solicitar apoio do administrador! (Totvs Integração MES) ****"+ CRLF)
			Return .F.
		EndIf
	EndIf
Return .T.


/*/{Protheus.doc} ZFISF009HTML
Prepara HTML para envio de E-mail
@since 
@version 1.0
@Obs
@History
/*/
Static Function ZFISF009HTML( _cLogo, _cNota, _cSerie, _cUserName, _aMens)
Local _cHtml := ""
Local _nPos

	_cHtml += '<!DOCTYPE html>'+ CRLF
    _cHtml += "<head>"+ CRLF
    //_cHtml += "     <img src='img/beneficios.jpg' class='imagembeneficios'>"+ CRLF
	_cHtml += "	<th width='12%' height='0' scope='col'><img src='" + _cLogo + "' width='118' height='40'></th>"+ CRLF
    _cHtml += "    <meta charset='UTF-8'>"+ CRLF
    _cHtml += "    <title>CAOA - Envio arquivo </title>"+ CRLF
    _cHtml += "    <link rel='stylesheet' href='style.css'>"+ CRLF
    _cHtml += "</head>"+ CRLF

    _cHtml += "<body>"+ CRLF
    _cHtml += "    <header>"+ CRLF
    _cHtml += "        <h1 class='titulo-principal'>CAOA - Envio arquivo</h1>"+ CRLF
    _cHtml += "    </header>"+ CRLF
    _cHtml += "    <div class='principal'>"+ CRLF
    _cHtml += "        <h2 class='titulo-centralizado'>Envio DANFE / XML </h2>"+ CRLF
    _cHtml += "        <p>Estamos enviando anexo DANFE e XML referente a nota Fiscal <strong>"+_cNota+" </strong> Serie <strong>"+_cSerie+" </strong>.</p> "+ CRLF
    _cHtml += "        </div>"

	If Len(_aMens) > 0
	    _cHtml += "     <div class='Referencia'>"+ CRLF
    	_cHtml += "     <h3 class='titulo-centralizado'>Referência</h3> "+ CRLF   
    	_cHtml += "     <ul>"+ CRLF
		For _nPos := 1 to Len(_aMens)
    		_cHtml += "         <li class='itens'>"+_aMens[_nPos]+"</li>"+ CRLF
		Next
    	_cHtml += "     </ul>    "+ CRLF
    	_cHtml += "     </div>   "+ CRLF
    Endif
	_cHtml += "        <p id='cuser'><em>Enviado por : <strong>"+_cUserName+"</strong>.</em></p>"+ CRLF
    _cHtml += "</body>"+ CRLF
    _cHtml += "</html>"+ CRLF
	_cHtml +=    "<br/> <br/> <br/> <br/>"+ CRLF 

Return _cHtml



/*/{Protheus.doc} ZFIS09VldEmail
Valida se foi informado e-mail
@since 
@version 1.0
@Obs
@History
/*/
Static Function ZFIS09VldEmail(_cEmail)
Local _lRet := .T.
	If Empty(_cEmail)
		//_lRet := .F. 
	ElseIf 	At("@",_cEmail) == 0 .Or. At(".COM",Upper(_cEmail)) == 0
		_lRet := .F.
		MsgInfo("Informar e-mail correto !","Atenção")
	Endif 
Return _lRet		


//Validação Cliente
Static Function ZFIS09ClilVld(_cCod, _cLoja, _cCnpj)
Local _lRet 	:= .T.
Local _cChave	:= ""
	If ValType(_cCod) == "C" .And. ValType(_cLoja) == "C" .And. !Empty(_cCod)
		SA1->(DbSetOrder(1))
		_cChave := XFilial("SA1")+_cCod+_cLoja		
	ElseIf ValType(_cCnpj) == "C"  .And. !Empty(_cCnpj)
		SA1->(DbSetOrder(3))
		_cChave := XFilial("SA1")+_cCnpj		
	Endif
	If !Empty(_cChave)
		_lRet := SA1->(DbSeek(_cChave))
		If !_lRet
			MsgInfo("Cliente Não localizado !", "Atenção")
		Endif 
	Endif	
Return _lRet 


/*/{Protheus.doc} ZFISF09VCTEmail
Verificar se existe e-mail para clientes e transportadora
@since 
@version 1.0
@Obs
@History
/*/
Static Function ZFISF09VCTEmail( )
Local _lRet 	:= .T.
Local _cCodCli 	:= SF2->F2_CLIENTE 
Local _cLoja	:= SF2->F2_LOJA 
Local _cCodTrans:= SF2->F2_TRANSP

	If _lCheckCli .Or. _lCheckAll
		SA1->(DbSetOrder(1))
		If !SA1->(DbSeek(FWxFilial("SA1")+_cCodCli+_cLoja))
			MsgInfo("Cliente "+_cCodCli+"-"+_cLoja+" não cadastrado !","Atenção")
			_lRet := .F.
		Endif 
		If Empty(SA1->A1_EMAIL) 
			MsgInfo("Não esta cadastrado Email do Cliente codigo "+SF2->F2_CLIENTE+ " Loja "+SF2->F2_LOJA, "Atenção")
			_lRet := .F.
		Endif 
	Endif 

	If !Empty(_cCodTrans) .And. (_lCheckTra .Or. _lCheckAll)
		SA4->(DbSetOrder(1))
		If !SA4->(DbSeek(FwXFilial("SA4")+_cCodTrans))
			MsgInfo("Transportador código "+_cCodTrans+" não cadastrado !","Atenção")
			_lRet := .F.
		Endif 
 		If Empty(SA4->A4_EMAIL) 
			MsgInfo("Não esta cadastrado e-mail do Transportador codigo "+SF2->F2_TRANSP+ " nota "+SF2->F2_DOC+ " serie "+SF2->F2_SERIE, "Atenção" )
			_lRet := .F.
		Endif 
	Endif 
Return _lRet



/*/{Protheus.doc} ZFISF09VCTEmail
Menudef
@since 
@version 1.0
@Obs
@History
/*/
Static Function MenuDef()
Local _aRotina := {} 
Return _aRotina

