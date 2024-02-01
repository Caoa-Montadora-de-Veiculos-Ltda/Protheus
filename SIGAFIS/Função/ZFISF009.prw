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
Static _lCheckCli 	As logical
Static _lCheckTra    As logical
Static _lCheckAll  	As logical

Static _cNotaDe	 	:= Space(Len(SF2->F2_DOC))
Static _cNotaAte 	:= Space(Len(SF2->F2_DOC))
Static _cCodCli  	:= Space(Len(SF2->F2_CLIENTE))
Static _cLojaCli 	:= Space(Len(SF2->F2_LOJA))
Static _cCNPJCli 	:= Space(Len(SA1->A1_CGC))
Static _cEmailEsp	:= Space(200)

//Static _oOk       	:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
//Static _oNo       	:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO

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
//Local _bProcessa 	:= {||If (ZFISF09Processa(),_oDlgMark:End(),Nil) }
//Local _bFiltro 		:= {||ZFISF009Filtro() }
Local _aArea 		:= GetArea()
Local _aRotina   	:= {}

//Local _nAltura  	:= 180
//Local _nLargura 	:= 650

Local _aColumns
Local _aCampos


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
	_lCheckCli 	:= .F.
 	_lCheckTra  := .F.
	_lCheckAll  := .F.


	@ _nLinha	, _nCol+1 	SAY   OemToAnsi("Nota Fiscal De") SIZE 038,007 		OF _oPanelUp PIXEL
	@ _nLinha+6	, _nCol+1 	MSGET _cNotaDe SIZE 010,007		OF _oPanelUp F3 'SF2' PIXEL WHEN .T. VALID .T.
	@ _nLinha	, _nCol+80 	SAY   OemToAnsi("Nota Fiscal Ate") SIZE 038,007 	OF _oPanelUp PIXEL
	@ _nLinha+6	, _nCol+80	MSGET _cNotaAte SIZE 010,007	OF _oPanelUp F3 'SF2' PIXEL WHEN .T. VALID .T.
   	_oCheckCli := TCheckBox():New(_nLinha, _nCol+500, "Envia e-mail para Clientes", {||_lCheckCli}, _oDlgMark, 100, 210,,,,,,,,.T.)

	_nLinha += 20
	@ _nLinha	, _nCol+1 	SAY   OemToAnsi("Cod. Cliente") SIZE 038,007 	OF _oPanelUp PIXEL
	@ _nLinha+6 , _nCol+1	MSGET _cCodCli SIZE 050,007	OF _oPanelUp  	F3 'SA1'	PIXEL WHEN .T. VALID ZFIS09ClilVld(_cCodCli)
	@ _nLinha	, _nCol+80 	SAY   OemToAnsi("Loja Cliente") SIZE 038,007 	OF _oPanelUp PIXEL
	@ _nLinha+6 , _nCol+80	MSGET _cLojaCli SIZE 050,007	OF _oPanelUp  				PIXEL WHEN .T. VALID ZFIS09ClilVld(_cCodCli, _cLojaCli)
	@ _nLinha	, _nCol+160 SAY   OemToAnsi("CNPJ Cliente") SIZE 038,007 	OF _oPanelUp PIXEL
	@ _nLinha+6 , _nCol+160	MSGET _cCNPJCli SIZE 050,007	OF _oPanelUp  				PIXEL WHEN .T. VALID ZFIS09ClilVld(/*_cCodCli*/, /*_cLojaCli*/, _cCNPJCli)
   	_oCheckTra := TCheckBox():New(_nLinha, _nCol+500, "Envia e-mail para Transportador", {||_lCheckTra}, _oDlgMark, 100, 210,,,,,,,,.T.)

	_nLinha += 20
	@ _nLinha	, _nCol+1 	SAY   OemToAnsi("E-mail Especifico") SIZE 038,007 	OF _oPanelUp PIXEL
	@ _nLinha+6 , _nCol+1	MSGET _cEmailEsp SIZE 350,007	OF _oPanelUp  		PIXEL WHEN .T. VALID ZFIS09VldEmail(_cEmailEsp)
   	_oCheckAll := TCheckBox():New(_nLinha, _nCol+500, "Envia e-mail para Todos", {||_lCheckAll}, _oDlgMark, 100, 210,,,,,,,,.T.)

 	//oCheck1 := TCheckBox():New(_nLinha,_nCol,'Item 1',{||lCheck},_oPanelUp,180,210,,,oFont,,,,,.T.,,,{oCheck1:Refresh()})

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

	//_oMark:AddButton("Envia Docto."		, _bProcessa,,,, .F., 2 )  //Envia  
	//_oMark:AddButton("Sel Parametros"	, _bFiltro 	,,,, .F., 2 )  //Filtra 
    _oMark:AddButton("Envia Docto" 	    , { || FwMsgRun(,{ | _oSay | If(ZFISF09Processa( @_oSay), _oDlgMark:End(),_oMark:Refresh(.T.)) }    , "Processando Arquivo "       , "Aguarde...")  },,,, .F., 2 )  
    _oMark:AddButton("Sel Parametros"   , { || FwMsgRun(,{ | _oSay | ZFISF009Filtro( @_oSay), _oMark:Refresh(.T.) } , "Processando Arquivo "       , "Aguarde...")  },,,, .F., 2 )  

    //_oMark:SetDoubleClick({||ZFISF09MRK()})   
	//Indica o Code-Block executado no clique do header da coluna de marca/desmarca
  	//_lMarcar := .T.
    _oMark:bAllMark := { || MsgInfo("Opção desabilitada", "Atenção")  }
	_oMark:SetInvert(.F.)
	_oMark:SetValid({||ZFISF09MRK()})
	//   (Marca somente linhas que houveram itens selecionados na função 
	//_oMark:SetCustomMarkRec({||ZFISF09MRK()})  


    //Função para Validar registro selecionado 
    //_oMark:SetSemaphore(.T.)     
    // _oMark:AddMarkColumns( _oOk, _oOk,_oOk)   

    //_oMark:Valid(U_???MRK())
    //_oMark:SetValid({||U_???MRK()})
    //_oMark:SetDoubleClick({||U_???MRK() })
    //_oMark:SetCustomMarkRec({||U_????})
    //_oMark:SetDoubleClick({||U_?????MRK()})   
	//_oMark:SetEditCell ( .T., {||U_?????()} )
    //_oMark:AddMarkColumns({| If(ZFISF09MRK(), _oOk, _oNo ) })
    //Montar legenda 
    //BOTOES
	//MARCAR TODOS
	//_oMark:bAllMark := { || SetMarkAll(_oMark:Mark(),_lMarcar := !_lMarcar ), _oMark:Refresh(.T.)  }
	_oMark:Activate()
	ACTIVATE MSDIALOG _oDlgMark CENTERED

//Voltar menu anterior
If Len(_aRotina) > 0
	aRotina := _aRotina
Endif
RestArea(_aArea)

Return Nil


Static Function ZFIS09VldEmail(_cEmail)
Local _lRet := .T.
	If Empty(_cEmail)
		//_lRet := .F. 
	ElseIf 	At("@",_cEmail) == 0
		_lRet := .F.
		MsgInfo("Informar e-mail correto !","Atenção")
	Endif 
Return _lRet		


/*/{Protheus.doc} SetMarkAll
Marca/Desmarca todos os itens da markbrowse
@author Leandro Drumond
@since 16/05/2016
@version 1.0
/*/
/*
Static Function SetMarkAll(_cMarca, _lMarcar )
Local _aAreaMark  := SF2->( GetArea() )
	SF2->( dbGoTop() )
	While SF2->( !Eof() )
		RecLock( "SF2", .F. )
		SF2->F2_OK := IIf( _lMarcar, _cMarca, '  ' )
		SF2->(MsUnLock())
		SF2->( dbSkip() )
	EndDo
	RestArea( _aAreaMark )
Return .T.
*/

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
	_oMark:SetFilterDefault("@"+_cFiltro)
    _oMark:Refresh(.T.)

Return _cFiltro


//========================================================
//Validação quando da seleção do registro no objeto mark
//========================================================
Static Function ZFISF09MRK(_lTodos)
Local _lRet 	:= .T.
Local _cMarca 	:= _oMark:Mark()
//Local _nPosCol  := _oMark:oBrowse:ColPos()

Default _lTodos := .F.  //indica que foi selecionado todos

Begin Sequence               
	If SF2->F2_FIMP <> 'S'
		MsgInfo("Somente selecionar as notas com Status Autorizado", "Atenção")
		_lRet := .F.	
		Break
	Endif 
    //Caso esteja desmarcando não validar
    If _oMark:IsMark(_cMarca)  
      Break
    Endif
	//Montar validação em relação aos relacionamentos verificar se ja esta selecionado pois outro usuário pode acessar
End Sequence
Return _lRet 



Static Function ZFISF09Processa( _oSay) 
Local _cMarca   := _oMark:Mark()
Local _cPasta   := ""
Local _cAlias 	:= GetNextAlias()
Local _lRet 	:= .T.
Local _cType 		:= OemToAnsi("Todos") + "(*.*) |*.*|"

Begin Sequence
    //Define o nome do alias temporário
	BeginSql Alias _cAlias  
        %NoParser%
       	SELECT SF2.R_E_C_N_O_    AS  NREGSF2
		FROM %Table:SF2% SF2
		WHERE SF2.%notDel%
			AND SF2.F2_FILIAL 	= %xFilial:SF2%
            AND SF2.F2_OK 		= %Exp:_cMarca%
    EndSQL
    If  (_cAlias)->(Eof()) .Or. (_cAlias)->NREGSF2 == 0
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

    While (_cAlias)->(!Eof())
		SF2->(DbGoto((_cAlias)->NREGSF2))
        If SF2->F2_OK == _cMarca
            //MProcDanfe(_cPasta, @_cArquivo)
            SF2->(MProcDanfe(_cPasta))
			RecLock( "SF2", .F. )
			SF2->F2_OK := '  ' 
			SF2->(MsUnLock())
        Endif 
		(_cAlias)->(DbSkip()) 
    EndDo
	MsgInfo("Gerado arquivos conforme pasta "+_cPasta+" informada", "Atenção")    
    _oMark:Refresh(.T.)

End Sequence 
If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif  
Return _lRet



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


//-------------------------------------------------------------------
/*/{Protheus.doc} MProcDanfe
Processar a Danfe e enviar e-mail
@author 
@since 
@version 1.0
/*/
//-------------------------------------------------------------------
STATIC Function MProcDanfe( _cPasta )
Local nA         	:= 0
Local cMensagem  	:= ""
Local cDir       	:= "" //SuperGetMV('MV_RELT',,"\SPOOL\")
Local cNomeArquivo  := ""

Private cPegaXml   := ""  //Obtido dentro da rotina da Danfe. tem que existir uma variavel Private nestga função
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
    MemoWrit(_cPasta + cNomeArquivo + ".xml", cPegaXml)
    lRet := __CopyFile(cDir + cNomeArquivo + ".pdf", _cPasta+cNomeArquivo+".pdf",,,.F.)
	If !lRet
		MsgInfo("Não foi possivel copiar arquivo "+cDir + cNomeArquivo + ".pdf !", "Atenção")
		Break 
	Endif
	//Para enviar e-mai tem que estar informado um destes processos
	If 	!Empty(_cEmailEsp) .Or. _lCheckCli 	.Or. _lCheckTra .Or. _lCheckAll  
		ZFIS09Email(_cPasta+cNomeArquivo+".pdf", _cPasta+cNomeArquivo+".xml")
	Endif 
    //MEnviarEMail(cDir + cNomeArquivo + ".pdf", cDir + cNomeArquivo + ".xml", @cMensagem)
End Sequence
Return cMensagem

//Função para preparar envio de e-mail
Static Function ZFIS09Email( _cArqPdf, _cArqXml)
Local _cAssunto		:= ""
Local _cEmails		:= ""
Local _cEMailCopia	:= ""
Local _aAnexos 		:= {}
Local _aMens		:= {}
Local _aErro		:= {}
Local _lRet 		:= .T.
Local _cEmailAcp    := AllTrim(SuperGetMV( "CMV_FIS000" , ,"denilso.carvalho@caoa.com.br" ))
Local _nPos

Default _cArqPdf := ""
Default _cArqXml := ""
"
	_cAssunto := "Envio Danfe e XML Nota Fiscal "+SF2->F2_DOC+ "  SERIE "+ SF2->F2_SERIE 
	//Incluir arquivos
	If !Empty(_cArqPdf)
		Aadd(_aAnexos,_cArqPdf)
	Endif		
	If !Empty(_cArqXml)
		Aadd(_aAnexos,_cArqXml)
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
	If 	_lCheckTra 	.Or. _lCheckAll
		SA4->(DbSeek(FwXFilial("SA4")+SF2->A2_TRANSP))
 		If Empty(SA4->A4_EMAIL) .Or. SA4->(Eof())
			Aadd(_aErro,"Não esta cadastrado e-mail do Transportador codigo "+SF2->A2_TRANSP+ " nota "+SF2->F2_DOC+ " serie "+SF2->F2_SERIE)
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
		_lRet := ZFISF009EM(_aMens, _cAssunto, _cEmails, _cEMailCopia, _aAnexos,  /*_cRotina*/, /*lSchedule*/)
		//ocorreu problemas no envio de Email
		If !_lRet
			Aadd(_aErro,"Ocorreram erros nos envio de e-mails para envio do Cliente codigo "+SF2->F2_CLIENTE+ " Loja "+SF2->F2_LOJA+ " nota "+SF2->F2_DOC+ " serie "+SF2->F2_SERIE)
		Endif 
	Endif 
	//caso ocorra erro tentar enviar para e-mail de acompanhamento 
	If Len(_aErro) > 0
		_lRet = .F.
		_cAssunto := "ZFIS09Email Problemas ocorrido no Envio Danfe e XML Nota Fiscal "+SF2->F2_DOC+ "  SERIE "+ SF2->F2_SERIE 
		Conout(_cAssunto)	
		//acrescento no processo ja gerado os erros a serem enviados
		For _nPos := 1 To Len(_aErro)
			Aadd(_aMens,_aErro[_nPos])
			Conout("Ocorrencia: "+_aErro[_nPos])
		Next	
		_cEmails  		:= _cEmailAcp
		_cEMailCopia	:= AllTrim(_cEmailEsp)
		ZFISF009EM(_aMens, _cAssunto, _cEmails, _cEMailCopia, _aAnexos,  /*_cRotina*/, /*lSchedule*/,/*_lMsgTela*/)
		Conout("Email:"+_cEmails)
		Conout("Email cópia"+_cEMailCopia)
	Endif 
Return _lRet




//-------------------------------------------------------------------
/*/{Protheus.doc} XSpedDanfe
Adaptado para gerar o pdf da Danfe via job.
@author Antonio C Ferreira
@since 24/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
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



/*
=====================================================================================
Programa.:              ZFISF009EM
@param 					_aMens   	= Mensagens de erro 
						_aChave		= Campos relativos a pesquisa com seu conteudo se vazio pesquisara baseado na tabela posicionada
						_cAssunto   = Assunto do e-mail 
						_cEmails    = Destinatário do e-mail 
						_cEMailCopia= Destinatarios em cópia 
						_aAnexos 	= Localização e nome do arquivo anexo 
						_cRotina    = Rotina que chamou o processo
						lSchedule	= Esta rodando em job se verdadeiro não emitira msg em tela
Autor....:              CAOA - DAC Denilso 
Data.....:              10/07/2020
Descricao / Objetivo:   Funcao para processar o envio das notificacoes
Doc. Origem:            GAP COM027
Solicitante:            Compras
Uso......:              ZCOLF001
Obs......:

=====================================================================================
*/
Static Function ZFISF009EM(_aMens, _cAssunto, _cEmails, _cEMailCopia, _aAnexos,  _cRotina, lSchedule, _lMsgTela)
Local _cTexto   		:= ""
Local _cEmailDest 		:= ""
Local _lMsgOK			:= .T.
Local _lMsgErro			:= .F.
Local _cObsMail			:= ""
Local _cReplyTo			:= ""
Local _cCorItem			:= "FFFFFF"
Local _lEnvia			:= .T.
Local _cLogo  			:= "lg_caoa.png"
Local _cCodUsu			:= RetCodUsr()
Local _cNomeUsu 		:= Upper(FwGetUserName(RetCodUsr())) //Retorna o nome completo do usuário  __cUserId
Local _nPos

Default _lSchedule   	:= .T.
Default _cAssunto		:= "Informações importação MES"
Default _cEmails 		:= AllTrim(SuperGetMV("CMV_PCP002",.F.,"evandro.mariano@caoa.com.br;denilso.carvalho@caoa.com.br"))  //E-mail para envio problemas integração TOTVS x MES 
Default _aAnexos		:= {}
Default _aChave			:= {}
Default _cEMailCopia	:= ""
Default _cRotina		:= "ZFISF009"
Default _lMsgTela		:= .F.

_lMsgErro			:= IF( _lSchedule == .F., .T. , .F. )
If Empty(_cEmails)
	_cTexto := "**** Erros referente ao processo de importação MES função ZPCP007 não possui e-mail cadastrado no parâmetro CMV_PCP002****"
	_cTexto += "     Os mesmos serão gravados no log do Sistema conforme informações abaixo" 
	Return .F.
EndIf	



_cEmailDest := _cEmails
_cHtml := ""
_cHtml += "<html>"+ CRLF
_cHtml += "	<head>"+ CRLF
_cHtml += "		<title>Processo de importação MES Informações/Erros</title>"+ CRLF
_cHtml += "	</head>"+ CRLF
_cHtml += "	<body leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>"+ CRLF
_cHtml += "		<table width='100%' height='100%' border='0' cellpadding='0' cellspacing='0'>"+ CRLF
_cHtml += "			<tr>"+ CRLF
_cHtml += "				<th width='1200' height='100%' align='center' valign='top' scope='col'>"+ CRLF
_cHtml += "					<table width='90%' height='50%' border='0' cellpadding='0' cellspacing='0'>"+ CRLF
_cHtml += "						<tr>"+ CRLF
_cHtml += "							<th width='100%' height='100' scope='col'>"+ CRLF
_cHtml += "								<table width='100%' height='60%' border='3' cellpadding='0' cellspacing='0' >"+ CRLF
_cHtml += "									<tr>"+ CRLF
_cHtml += "										<th width='12%' height='0' scope='col'><img src='" + _cLogo + "' width='118' height='40'></th>"+ CRLF
_cHtml += "										<td width='67%' align='center' valign='middle' scope='col'><font face='Arial' size='+1'><b>Envio Danfe / XML</b></font></td>"+ CRLF
_cHtml += "									</tr>"+ CRLF
_cHtml += "								</table>"+ CRLF
_cHtml += "							</th>"+ CRLF
_cHtml += "						</tr>"+ CRLF
_cHtml += "						<tr>"+ CRLF
_cHtml += "							<th width='100' height='100' scope='col'>"+ CRLF
_cHtml += "								<table width='100%' height='100%' border='2' cellpadding='2' cellspacing='1' >"+ CRLF
_cHtml += "									<tr>"+ CRLF
_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>Empresa:	</b></font></td>"+ CRLF
_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>"+AllTrim(FWFilialName(,SM0->M0_CODFIL))+"</font></td>"+ CRLF
_cHtml += "									</tr>"+ CRLF
_cHtml += "									<tr>"+ CRLF
_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>Responsável(is):	</b></font></td>"+ CRLF
_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>" + _cCodUsu+"-"+_cNomeUsu + "</font></td>"+ CRLF
_cHtml += "									</tr>"+ CRLF
_cHtml += "									</tr>"+ CRLF

_cHtml += "								</table>"+ CRLF
_cHtml += "							</th>"+ CRLF
_cHtml += "						</tr>"+ CRLF
_cHtml += "						<tr >"+ CRLF
_cHtml += "							<td height='25' style='padding-top:1em;'>"+ CRLF
_cHtml += "								<table width='100%' height='100%' border='2' cellpadding='2' cellspacing='0' >"+ CRLF
_cHtml += "									<tr bgcolor='#4682B4'>"+ CRLF
_cHtml += "										<th width='10%' height='100%' align='center' valign='middle' scope='col'><font face='Arial' size='2'><b>Histórico		</b></font></th>"+ CRLF
_cHtml += "									</tr>"+ CRLF

ConOut(_cAssunto)
For _nPos := 1 To Len(_aMens)
	_cHtml += "									<tr> <!--while advpl-->"+ CRLF
	_cMsgErro := _aMens[_nPos]
	_cHtml += "						<td width='10%' height='16' align='left'	valign='middle' bgcolor='#"+_cCorItem+"' scope='col'><font size='1' face='Arial'>"+_cMsgErro+"</font></td>"+ CRLF
	_cHtml += "									</tr>"+ CRLF
	ConOut(_aMens[_nPos])
Next
_cHtml +=    "<br/> <br/> <br/> <br/>" 
	
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

If !_lEnvia
	If lSchedule
		ConOut("**** [ ZFISF009EM ] - E-mail não cadastrado para envio - Solicitar apoio do administrador! (Totvs Integração MES) ****"+ CRLF)
	ElseIf _lMsgTela
		ApMsgInfo("E-mail não cadastrado para envio - Solicitar apoio do administrador!! (Totvs Integração MES)","Cadastro")
	Else 
		ConOut("**** [ ZFISF009EM ] - E-mail não cadastrado para envio - Solicitar apoio do administrador! (Totvs Integração MES) ****"+ CRLF)
	EndIf
EndIf

Return .T.


//Menudef
Static Function MenuDef()
Local _aRotina := {} 
Return _aRotina





