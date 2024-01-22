#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "FWBROWSE.CH"
#Include "TBIConn.ch" 
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"

Static _oMark     


User Function ZFISF009()
//Local _cFilter   
Local _oFnt10    	:= TFont():New("Courier New",10,0)
//Local _oOk       	:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
//Local _oNo       	:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local _aColumns
Local _aCampos
Local _oSay

Private cPegaXml   := ""  //Obtido dentro da rotina da Danfe.
Private cXMensagem := ""

//Private aRotina	 :=  {}  //Menudef() //Se for criar menus via MenuDef         
//Private _nCopias := 1
Begin Sequence 
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
    //_oMark:SetSemaphore(.T.)     
    _oMark:SetDescription("Selecionar Notas ")  
   	_oMark:SetDoubleClick({||ZFISF09MRK()})
    //Indicador do campo que sofrerá o checklist
    _oMark:SetFieldMark( 'F2_OK' )
    // _oMark:AddMarkColumns( _oOk, _oOk,_oOk)   
    //Cria botão sair caso não esteja previsto  
    _oMark:ForceQuitButton()                  
    //Função para Validar registro selecionado 
    //_oMark:Valid(U_???MRK())
    //_oMark:SetValid({||U_???MRK()})
    //_oMark:SetDoubleClick({||U_???MRK() })
    //_oMark:SetCustomMarkRec({||U_????})
    //_oMark:SetDoubleClick({||U_?????MRK()})   
	//_oMark:SetEditCell ( .T., {||U_?????()} )
    //_oMark:AddMarkColumns({| If(U_????MRK(),_oOk,_oNo) }, {|| Mark(1) }, {|| MarkAll(1) })

    _oMark:SetMenuDef( '' )
    //Montar legenda 
    _oMark:AddLegend( "F2_FIMP==' ' .AND. AllTrim(F2_ESPECIE)=='SPED'"  , "DISABLE" , OemToAnsi("NF não transmitida")  )  
    _oMark:AddLegend( "F2_FIMP=='S'"                                    , "ENABLE"  , OemToAnsi("NF Autorizada")  )  
    _oMark:AddLegend( "F2_FIMP=='T'"                                    , "BR_AZUL" , OemToAnsi("NF Transmitida")  )  
    _oMark:AddLegend( "F2_FIMP=='D'"                                    , "BR_CINZA" , OemToAnsi("NF Uso Denegado")  )  
    _oMark:AddLegend( "F2_FIMP=='N'"                                    , "BR_PRETO" , OemToAnsi("NF nao autorizada")  )  

	
    _oMark:AddButton("Gerar arquivos"  	, { || FwMsgRun(,{ | _oSay | ZFISF09GAQ( @_oSay) }, "Gerando arquivos ", "Aguarde...")  },,,, .F., 2 )  


    // Filtros 
    //_oMark:AddFilter("NF NÃO Autorizada","F2_FIMP==' ' AND AllTrim(F2_ESPECIE)=='SPED'"    ,.T.,.T.)
    //_oMark:AddFilter("NF Autorizada"    ,"Z1_CRATEDA <> ''",.T.,.T.)
    _oMark:SetInvert(.F.)
    // Define se utiliza marcacao exclusiva  
    //_oMark:SetSemaphore(.F.)	 
    //Indica que a marca deve ser considerada invertida Obs.: Utilizada em casos como o de marcação de todos os registros
    //_oMark:SetInvert(.F.)
    //Limpar objeto mark
    //_oMark:SetAllMark( { || _oMark:AllMark() } )

//    _oMark:SetWalkThru(.T.)
    //Ativa
    _oMark:Activate() 
    //Fecha todos os filtros da rotina
//    _oMark:CleanFilter()
End Sequence    
Return Nil


//========================================================
//Validação quando da seleção do registro no objeto mark
//========================================================
Static Function ZFISF09MRK()
Local _lRet := .T.
Local _cMarca := _oMark:Mark()
Begin Sequence               
    //Caso esteja desmarcando não validar
    If !_oMark:IsMark(_cMarca)  
      Break
    Endif
	//Montar validação em relação aos relacionamentos verificar se ja esta selecionado pois outro usuário pode acessar
End Sequence
Return _lRet 



Static Function ZFISF09GAQ( _oSay) 
Local _cMarca   := _oMark:Mark()
Local _cPasta   := "c:\temp\" 
Local cNomeArquivo := ""
Local _cArquivo := ""

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
    Local cDir       := SuperGetMV('MV_RELT',,"\SPOOL\")

    Private cPegaXml   := ""  //Obtido dentro da rotina da Danfe.
    Private cXMensagem := ""

    Begin Sequence


        If  FindFunction("ColUsaColab")
            lUsaColab := ColUsaColab("1")
        EndIf


//        SM0Filial("01001")  //Kert

        //Processar na filial 01001 a nota de saida.
        XSpedDanfe(0/*nTipo*/, 2/*nPar*/, @cNomeArquivo)

        Do  While (++nA < 10)

            Sleep(5000)  //espera pelo pdf

            If  File(cDir + cNomeArquivo + ".pdf")
                Exit
            EndIf
        
        EndDo

        If  !( File(cDir + cNomeArquivo + ".pdf") )
            cMensagem := If(!Empty(cXMensagem), cXMensagem, "Problema para gerar o arquivo pdf! Empresa: " + cEmpresa + " - Codigo: " + cCodigo)
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
STATIC Function XSpedDanfe(nTipo, nPar, cFilePrint)

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
local cDir			:= ""
local lJob			:= .T. //isBlind()
local lDanfeII		:= findfunction("u_PrtNfeSef")
local lDanfeIII		:= findfunction("u_DANFE_P1")
local cMsgVld		:= ""

Default nTipo		:= 0
default nPar		:= 0
default cFilePrint	:= ""

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

		cDir := SuperGetMV('MV_RELT',,"\SPOOL\")
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
