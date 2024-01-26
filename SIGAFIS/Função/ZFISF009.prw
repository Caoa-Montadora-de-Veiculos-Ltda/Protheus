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
Local _lMarcar     	:= .F.
Local _oPanelUp
Local _oTela
Local _oPanelDown
Local _oGroup
Local _oFnt10    	:= TFont():New("Courier New",10,0)
Local _aAdvSize		:= {}
Local _aInfoAdvSize	:= {}
Local _aObjSize		:= {}
Local _aObjCoords	:= {}
Local _bProcessa 	:= {||If (ZFISF09Processa(),_oDlgMark:End(),Nil) }
Local _bFiltro 		:= {||ZFISF009Filtro() }
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
	lCheck := .F.


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
	@ _nLinha+6 , _nCol+1	MSGET _cEmailEsp SIZE 350,007	OF _oPanelUp  		PIXEL WHEN .T. VALID ZFIS09EmailVld(_cEmailEsp)
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

	_oMark:AddButton("Envia Docto."		, _bProcessa,,,, .F., 2 )  //Envia  
	_oMark:AddButton("Sel Parametros"	, _bFiltro 	,,,, .F., 2 )  //Filtra 

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
	_oMark:bAllMark := { || SetMarkAll(_oMark:Mark(),_lMarcar := !_lMarcar ), _oMark:Refresh(.T.)  }
	_oMark:Activate()
	ACTIVATE MSDIALOG _oDlgMark CENTERED

//Voltar menu anterior
If Len(_aRotina) > 0
	aRotina := _aRotina
Endif
RestArea(_aArea)

Return Nil


Static Function ZFIS09EmailVld(_cEmail)
Local _lRet := .T.
	If Empty(_cEmail)
		//_lRet := .F. 
	ElseIf 	At("@",_cEmail) == 0
		_lRet := .F.
		MsgInfo("Informar e-mail correto !")
	Endif 
Return _lRet		


/*/{Protheus.doc} SetMarkAll
Marca/Desmarca todos os itens da markbrowse
@author Leandro Drumond
@since 16/05/2016
@version 1.0
/*/
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


Static Function ZFISF009Filtro()
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
Static Function ZFISF09MRK()
Local _lRet := .T.
Local _cMarca := _oMark:Mark()
Begin Sequence               
    //Caso esteja desmarcando não validar
    If !_oMark:IsMark(_cMarca)  
		_lRet := .F.	
      Break
    Endif
	If SF2->F2_FIMP <> 'S'
		MsgInfo("Somente selecionar as notas com Status Autorizado")
		_lRet := .F.	
		Break
	Endif 
	//Montar validação em relação aos relacionamentos verificar se ja esta selecionado pois outro usuário pode acessar
End Sequence
Return _lRet 



Static Function ZFISF09Processa( _oSay) 
Local _cMarca   := _oMark:Mark()
Local _cPasta   := "c:\temp\" 
Local cNomeArquivo := ""
//Local _cArquivo := ""

    //SF2->(DbGotop())
    //While SF2->(!Eof())
        If _oMark:IsMark(_cMarca)
            //MProcDanfe(_cPasta, @_cArquivo)
            SF2->(MProcDanfe(cNomeArquivo,_cPasta))
            _oMark:refresh()
        Endif 
    //    SF2->(DbSkip()) 
    //EndDo    
Return .t.


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
			MsgInfo("Cliente Não localizado !")
		Endif 
	Endif	
Return _lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} MProcDanfe
Processar a Danfe e enviar e-mail
@author Antonio C Ferreira
@since 17/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
STATIC Function MProcDanfe(cNomeArquivo, _cPasta)

    Local aArea      := GetArea()
    Local nA         := 0
	Local cMensagem  := ""
    Local cDir       := "" //SuperGetMV('MV_RELT',,"\SPOOL\")

    Private cPegaXml   := ""  //Obtido dentro da rotina da Danfe.
    Private cXMensagem := ""

    Begin Sequence


        If  FindFunction("ColUsaColab")
            lUsaColab := ColUsaColab("1")
        EndIf


//        SM0Filial("01001")  //Kert

        //Processar na filial 01001 a nota de saida.
        XSpedDanfe(0/*nTipo*/, 2/*nPar*/, @cNomeArquivo, @cDir, _cPasta)

        Do  While (++nA < 5)

            Sleep(1000)  //espera pelo pdf

            If  File(cDir + cNomeArquivo + ".pdf")
                Exit
            EndIf
        
        EndDo

        If  !( File(cDir + cNomeArquivo + ".pdf") )
            cMensagem := If(!Empty(cXMensagem), cXMensagem, "Problema para gerar o arquivo pdf! ")
            Break
        EndIf

        MemoWrit(_cPasta + cNomeArquivo + ".xml", cPegaXml)
        lRet := __CopyFile(cDir + cNomeArquivo + ".pdf", _cPasta+cNomeArquivo+".pdf",,,.F.)
        //MEnviarEMail(cDir + cNomeArquivo + ".pdf", cDir + cNomeArquivo + ".xml", @cMensagem)

    End Sequence


    RestArea(aArea)

Return cMensagem


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
Local oDanfe
Local oSetup
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
endif

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
		endif

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



Static Function MenuDef()
Local _aRotina := {} 
Return _aRotina
