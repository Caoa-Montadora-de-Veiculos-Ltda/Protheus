#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} INVCAOA
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  10/02/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function INVCAOA( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   cMsg      := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk

	If FindFunction( "MPDicInDB" ) .AND. MPDicInDB()
		cMsg := "Este update NÃO PODE ser executado neste Ambiente." + CRLF + CRLF + ;
				"Os arquivos de dicionários se encontram no Banco de Dados e este update está preparado " + ;
				"para atualizar apenas ambientes com dicionários no formato ISAM (.dbf ou .dtc)."

		If lAuto
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( cMsg )
			ConOut( DToC(Date()) + "|" + Time() + cMsg )
		Else
			MsgInfo( cMsg )
		EndIf

		Return NIL
	EndIf

	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else

		If !FWAuthAdmin()
			Final( "Atualização não Realizada." )
		EndIf

		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "INVCAOA" )
				Else
					MsgStop( "Atualização não Realizada.", "INVCAOA" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Realizada." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			Final( "Atualização não Realizada." )

		EndIf

	Else
		Final( "Atualização não Realizada." )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  10/02/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX6()

			//------------------------------------
			// Atualiza o dicionário SX1
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de perguntas" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX1()

			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuHlp()
			FSAtuHlpX1()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2
Função de processamento da gravação do SX2 - Arquivos

@author TOTVS Protheus
@since  10/02/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cCpoUpd   := "X2_ROTINA /X2_UNICO  /X2_DISPLAY/X2_SYSOBJ /X2_USROBJ /X2_POSLGT /"
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
             "X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
             "X2_POSLGT" , "X2_CLOB"   , "X2_AUTREC" , "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela ZA0
//
aAdd( aSX2, { ;
	'ZA0'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZA0'+cEmpr																, ; //X2_ARQUIVO
	'MOVIMENTOS DE INVENTARIO'												, ; //X2_NOME
	'MOVIMENTOS DE INVENTARIO'												, ; //X2_NOMESPA
	'MOVIMENTOS DE INVENTARIO'												, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'2'																		, ; //X2_POSLGT
	'2'																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			RecLock( "SX2", .F. )
			SX2->X2_UNICO := aSX2[nI][12]
			MsUnlock()

			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
			EndIf

			AutoGrLog( "Foi alterada a chave única da tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .F. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If PadR( aEstrut[nJ], 10 ) $ cCpoUpd
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf

			EndIf
		Next nJ
		MsUnLock()

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  10/02/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )


//
// Campos Tabela ZA0
//
aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZA0_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZA0_TM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'TM'																	, ; //X3_TITULO
	'TM'																	, ; //X3_TITSPA
	'TM'																	, ; //X3_TITENG
	'Tipo de Movimento'														, ; //X3_DESCRIC
	'Tipo de Movimento'														, ; //X3_DESCSPA
	'Tipo de Movimento'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZA0_COD'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Produto'															, ; //X3_TITULO
	'Cod. Produto'															, ; //X3_TITSPA
	'Cod. Produto'															, ; //X3_TITENG
	'Codigo do Produto'														, ; //X3_DESCRIC
	'Codigo do Produto'														, ; //X3_DESCSPA
	'Codigo do Produto'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZA0_UM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Unidade'																, ; //X3_TITULO
	'Unidade'																, ; //X3_TITSPA
	'Unidade'																, ; //X3_TITENG
	'Unidade de Medida'														, ; //X3_DESCRIC
	'Unidade de Medida'														, ; //X3_DESCSPA
	'Unidade de Medida'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZA0_QUANT'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Quantidade'															, ; //X3_TITULO
	'Cantidad'																, ; //X3_TITSPA
	'Amount'																, ; //X3_TITENG
	'Quantidade do Movimento'												, ; //X3_DESCRIC
	'Cantidad del Movimiento'												, ; //X3_DESCSPA
	'Transaction Amt'														, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZA0_LOCAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Armazem'																, ; //X3_TITULO
	'Deposito'																, ; //X3_TITSPA
	'Warehouse'																, ; //X3_TITENG
	'Codigo do Armazem'														, ; //X3_DESCRIC
	'Deposito'																, ; //X3_DESCSPA
	'Warehouse'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZA0_DOC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Documento'																, ; //X3_TITULO
	'Documento'																, ; //X3_TITSPA
	'Document'																, ; //X3_TITENG
	'Numero do Documento'													, ; //X3_DESCRIC
	'Numero del Documento'													, ; //X3_DESCSPA
	'Document Number'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZA0_DOCB7'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Documento B7'															, ; //X3_TITULO
	'Documento B7'															, ; //X3_TITSPA
	'Documento B7'															, ; //X3_TITENG
	'Documento da SB7'														, ; //X3_DESCRIC
	'Documento da SB7'														, ; //X3_DESCSPA
	'Documento da SB7'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZA0_EMISSA'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'DT Emissao'															, ; //X3_TITULO
	'Fch Emision'															, ; //X3_TITSPA
	'Issue Date'															, ; //X3_TITENG
	'Data de Emissao'														, ; //X3_DESCRIC
	'Fecha de Emisi¾n'														, ; //X3_DESCSPA
	'Issue Date'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZA0_CUSTO1'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Custo'																	, ; //X3_TITULO
	'Costo'																	, ; //X3_TITSPA
	'Cost'																	, ; //X3_TITENG
	'Custo'																	, ; //X3_DESCRIC
	'Costo'																	, ; //X3_DESCSPA
	'Cost'																	, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZA0_CC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Centro Custo'															, ; //X3_TITULO
	'Centro Costo'															, ; //X3_TITSPA
	'Cost Center'															, ; //X3_TITENG
	'Centro de Custo'														, ; //X3_DESCRIC
	'Centro de Costo'														, ; //X3_DESCSPA
	'Cost Center'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZA0_NUMSEQ'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sequencial'															, ; //X3_TITULO
	'Secuencia'																, ; //X3_TITSPA
	'Sequential'															, ; //X3_TITENG
	'Numeracao sequencial'													, ; //X3_DESCRIC
	'Numeraci¾n Secuencial'													, ; //X3_DESCSPA
	'Sequential Number'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZA0_TIPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo'																	, ; //X3_TITULO
	'Tipo'																	, ; //X3_TITSPA
	'Type'																	, ; //X3_TITENG
	'Tipo do material'														, ; //X3_DESCRIC
	'Tipo del Material'														, ; //X3_DESCSPA
	'Type of Material'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'ZA0_LOTE'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lote'																	, ; //X3_TITULO
	'Lote'																	, ; //X3_TITSPA
	'Lot'																	, ; //X3_TITENG
	'Lote'																	, ; //X3_DESCRIC
	'Lote'																	, ; //X3_DESCSPA
	'Lot'																	, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'ZA0_SBLOTE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sub-Lote'																, ; //X3_TITULO
	'Sublote'																, ; //X3_TITSPA
	'Sublot'																, ; //X3_TITENG
	'Sub-Lote'																, ; //X3_DESCRIC
	'Numero del Sublote'													, ; //X3_DESCSPA
	'Sublot'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'ZA0_DTVALI'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Valid. Lote'															, ; //X3_TITULO
	'Vald.Lote'																, ; //X3_TITSPA
	'Lot Validity'															, ; //X3_TITENG
	'Validade do Lote inform.'												, ; //X3_DESCRIC
	'Validez del Lote Infor'												, ; //X3_DESCSPA
	'Informed Lot Validity'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'ZA0_ENDERE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Endereco'																, ; //X3_TITULO
	'Direccion'																, ; //X3_TITSPA
	'Address'																, ; //X3_TITENG
	'Endereco'																, ; //X3_DESCRIC
	'Direccion'																, ; //X3_DESCSPA
	'Address'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'18'																	, ; //X3_ORDEM
	'ZA0_NUMSER'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Num de Serie'															, ; //X3_TITULO
	'Nº de Serie'															, ; //X3_TITSPA
	'Serial No.'															, ; //X3_TITENG
	'Num de Serie do Produto'												, ; //X3_DESCRIC
	'Nº de Serie del Producto'												, ; //X3_DESCSPA
	'Product Series Numb'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'ZA0_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Geracao'															, ; //X3_TITULO
	'Data Geracao'															, ; //X3_TITSPA
	'Data Geracao'															, ; //X3_TITENG
	'Data Geracao Ped \ Nota'												, ; //X3_DESCRIC
	'Data Geracao Ped \ Nota'												, ; //X3_DESCSPA
	'Data Geracao Ped \ Nota'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'20'																	, ; //X3_ORDEM
	'ZA0_PEDIDO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pedido Venda'															, ; //X3_TITULO
	'Pedido Venda'															, ; //X3_TITSPA
	'Pedido Venda'															, ; //X3_TITENG
	'Pedido de Venda'														, ; //X3_DESCRIC
	'Pedido de Venda'														, ; //X3_DESCSPA
	'Pedido de Venda'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'21'																	, ; //X3_ORDEM
	'ZA0_NOTA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nota Fiscal'															, ; //X3_TITULO
	'Nota Fiscal'															, ; //X3_TITSPA
	'Nota Fiscal'															, ; //X3_TITENG
	'Nota Fiscal de Saida'													, ; //X3_DESCRIC
	'Nota Fiscal de Saida'													, ; //X3_DESCSPA
	'Nota Fiscal de Saida'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'22'																	, ; //X3_ORDEM
	'ZA0_SERIE'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Serie'																	, ; //X3_TITULO
	'Serie'																	, ; //X3_TITSPA
	'Serie'																	, ; //X3_TITENG
	'Serie'																	, ; //X3_DESCRIC
	'Serie'																	, ; //X3_DESCSPA
	'Serie'																	, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZA0'																	, ; //X3_ARQUIVO
	'23'																	, ; //X3_ORDEM
	'ZA0_STATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status Proc.'															, ; //X3_TITULO
	'Status Proc.'															, ; //X3_TITSPA
	'Status Proc.'															, ; //X3_TITENG
	'Status do Processamento'												, ; //X3_DESCRIC
	'Status do Processamento'												, ; //X3_DESCSPA
	'Status do Processamento'												, ; //X3_DESCENG
	'9'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"1"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Pendente;2=Processado'												, ; //X3_CBOX
	'1=Pendente;2=Processado'												, ; //X3_CBOXSPA
	'1=Pendente;2=Processado'												, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'2'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME


//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo] )

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  10/02/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela ZA0
//
aAdd( aSIX, { ;
	'ZA0'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZA0_FILIAL+ZA0_TM+ZA0_LOCAL+ZA0_COD'									, ; //CHAVE
	'TM+Armazem+Cod. Produto'												, ; //DESCRICAO
	'TM+Deposito+Cod. Produto'												, ; //DESCSPA
	'TM+Deposito+Cod. Produto'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf

	oProcess:IncRegua2( "Atualizando índices..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6
Função de processamento da gravação do SX6 - Parâmetros

@author TOTVS Protheus
@since  10/02/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

AutoGrLog( "Ínicio da Atualização" + " SX6" + CRLF )

aEstrut := { "X6_FIL"    , "X6_VAR"    , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , ;
             "X6_DSCSPA1", "X6_DSCENG1", "X6_DESC2"  , "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", ;
             "X6_CONTENG", "X6_PROPRI" , "X6_VALID"  , "X6_INIT"   , "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" , ;
             "X6_PYME"   }

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CA_INVSERI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie de Nota Fiscal utilizada para gerar os doc´s'					, ; //X6_DESCRIC
	'Serie de Nota Fiscal utilizada para gerar os doc´s'					, ; //X6_DSCSPA
	'Serie de Nota Fiscal utilizada para gerar os doc´s'					, ; //X6_DSCENG
	'de entrada para os invetários que derem ganhos'						, ; //X6_DESC1
	'de entrada para os invetários que derem ganhos'						, ; //X6_DSCSPA1
	'de entrada para os invetários que derem ganhos'						, ; //X6_DSCENG1
	'utilizado na CAOA.'													, ; //X6_DESC2
	'utilizado na CAOA.'													, ; //X6_DSCSPA2
	'utilizado na CAOA.'													, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_GCTCOT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo Contrato para cotacao'											, ; //X6_DESCRIC
	'Tipo Contrato para cotizacion'											, ; //X6_DSCSPA
	'Contract type for quotation'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'001'																	, ; //X6_CONTEUD
	'001'																	, ; //X6_CONTSPA
	'001'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'001'																	, ; //X6_DEFPOR
	'001'																	, ; //X6_DEFSPA
	'001'																	, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		AutoGrLog( "Foi incluído o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX1
Função de processamento da gravação do SX1 - Perguntas

@author TOTVS Protheus
@since  10/02/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX1()
Local aEstrut   := {}
Local aSX1      := {}
Local aStruDic  := SX1->( dbStruct() )
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTam1     := Len( SX1->X1_GRUPO )
Local nTam2     := Len( SX1->X1_ORDEM )

AutoGrLog( "Ínicio da Atualização " + cAlias + CRLF )

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }

//
// Perguntas INVZA0
//

aAdd( aSX1, { ;
	'INVZA0'																, ; //X1_GRUPO
	'01'																	, ; //X1_ORDEM
	'Documento de Inventário De?'											, ; //X1_PERGUNT
	'Documento de Inventário De?'											, ; //X1_PERSPA
	'Documento de Inventário De?'											, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	9																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR01'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	'@!'																	, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'INVZA0'																, ; //X1_GRUPO
	'02'																	, ; //X1_ORDEM
	'Documento de Inventário Ate?'											, ; //X1_PERGUNT
	'Documento de Inventário Ate?'											, ; //X1_PERSPA
	'Documento de Inventário Ate?'											, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	9																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR02'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	'@!'																	, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'INVZA0'																, ; //X1_GRUPO
	'03'																	, ; //X1_ORDEM
	'Data do Inventário De?'												, ; //X1_PERGUNT
	'Data do Inventário De?'												, ; //X1_PERSPA
	'Data do Inventário De?'												, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR03'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'INVZA0'																, ; //X1_GRUPO
	'04'																	, ; //X1_ORDEM
	'Data do Inventário Ate?'												, ; //X1_PERGUNT
	'Data do Inventário Ate?'												, ; //X1_PERSPA
	'Data do Inventário Ate?'												, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR04'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'INVZA0'																, ; //X1_GRUPO
	'05'																	, ; //X1_ORDEM
	'Cond Pagamento?'														, ; //X1_PERGUNT
	'Cond Pagamento?'														, ; //X1_PERSPA
	'Cond Pagamento?'														, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	3																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR05'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SE4'																	, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'INVZA0'																, ; //X1_GRUPO
	'06'																	, ; //X1_ORDEM
	'TES para Pedido de Venda?'												, ; //X1_PERGUNT
	'TES para Pedido de Venda?'												, ; //X1_PERSPA
	'TES para Pedido de Venda?'												, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	3																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR06'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SF4'																	, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'INVZA0'																, ; //X1_GRUPO
	'07'																	, ; //X1_ORDEM
	'Fornecedor para Pré-Nota?'												, ; //X1_PERGUNT
	'Fornecedor para Pré-Nota?'												, ; //X1_PERSPA
	'Fornecedor para Pré-Nota?'												, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	6																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR07'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SA2'																	, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'INVZA0'																, ; //X1_GRUPO
	'08'																	, ; //X1_ORDEM
	'Loja Fornecedor p/ Pré-Nota?'											, ; //X1_PERGUNT
	'Loja Fornecedor p/ Pré-Nota?'											, ; //X1_PERSPA
	'Loja Fornecedor p/ Pré-Nota?'											, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	2																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR08'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'INVZA0'																, ; //X1_GRUPO
	'09'																	, ; //X1_ORDEM
	'Data para Emissão da Pré-Nota?'										, ; //X1_PERGUNT
	'Data para Emissão da Pré-Nota?'										, ; //X1_PERSPA
	'Data para Emissão da Pré-Nota?'										, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR09'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'INVZA0'																, ; //X1_GRUPO
	'10'																	, ; //X1_ORDEM
	'Cliente para Pedido de Venda?'											, ; //X1_PERGUNT
	'Cliente para Pedido de Venda?'											, ; //X1_PERSPA
	'Cliente para Pedido de Venda?'											, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	6																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR10'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SA1'																	, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'INVZA0'																, ; //X1_GRUPO
	'11'																	, ; //X1_ORDEM
	'Loja Cliente p/ Ped Venda?'											, ; //X1_PERGUNT
	'Loja Cliente p/ Ped Venda?'											, ; //X1_PERSPA
	'Loja Cliente p/ Ped Venda?'											, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	2																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR11'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'INVZA0'																, ; //X1_GRUPO
	'12'																	, ; //X1_ORDEM
	'Natureza Fin. p/ Ped Venda?'											, ; //X1_PERGUNT
	'Natureza Fin. p/ Ped Venda?'											, ; //X1_PERSPA
	'Natureza Fin. p/ Ped Venda?'											, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	10																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR12'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SED'																	, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL


//
// Atualizando dicionário
//

nPosPerg:= aScan( aEstrut, "X1_GRUPO"   )
nPosOrd := aScan( aEstrut, "X1_ORDEM"   )
nPosTam := aScan( aEstrut, "X1_TAMANHO" )
nPosSXG := aScan( aEstrut, "X1_GRPSXG"  )

oProcess:SetRegua2( Len( aSX1 ) )

dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX1 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX1[nI][nPosSXG]  )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX1[nI][nPosSXG] ) )
			If aSX1[nI][nPosTam] <> SXG->XG_SIZE
				aSX1[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho da pergunta " + aSX1[nI][nPosPerg] + " / " + aSX1[nI][nPosOrd] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				"   por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	oProcess:IncRegua2( "Atualizando perguntas..." )

	If !SX1->( dbSeek( PadR( aSX1[nI][nPosPerg], nTam1 ) + PadR( aSX1[nI][nPosOrd], nTam2 ) ) )
		AutoGrLog( "Pergunta Criada. Grupo/Ordem " + aSX1[nI][nPosPerg] + "/" + aSX1[nI][nPosOrd] )
		RecLock( "SX1", .T. )
	Else
		AutoGrLog( "Pergunta Alterada. Grupo/Ordem " + aSX1[nI][nPosPerg] + "/" + aSX1[nI][nPosOrd] )
		RecLock( "SX1", .F. )
	EndIf

	For nJ := 1 To Len( aSX1[nI] )
		If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
			SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aSX1[nI][nJ] ) )
		EndIf
	Next nJ

	MsUnLock()

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX1" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp
Função de processamento da gravação dos Helps de Campos

@author TOTVS Protheus
@since  10/02/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela ZA0
//
aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Movimento - CAOA' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_TM    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_TM" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo do Produto - CAOA.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_COD   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_COD" )

aHlpPor := {}
aAdd( aHlpPor, 'Unidade de Medida - CAOA' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_UM    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_UM" )

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade do Movimento - CAOA' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_QUANT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_QUANT" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo do Armazem - CAOA' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_LOCAL ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_LOCAL" )

aHlpPor := {}
aAdd( aHlpPor, 'Numero do Documento - CAOA' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_DOC   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_DOC" )

aHlpPor := {}
aAdd( aHlpPor, 'Documento da SB7 (Digitação de' )
aAdd( aHlpPor, 'Inventário) - CAOA' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_DOCB7 ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_DOCB7" )

aHlpPor := {}
aAdd( aHlpPor, 'Data de Emissao - CAOA' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_EMISSA", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_EMISSA" )

aHlpPor := {}
aAdd( aHlpPor, 'Custo - CAOA' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_CUSTO1", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_CUSTO1" )

aHlpPor := {}
aAdd( aHlpPor, 'Centro de Custo - CAOA' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_CC    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_CC" )

aHlpPor := {}
aAdd( aHlpPor, 'Numeracao sequencial - CAOA' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_NUMSEQ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_NUMSEQ" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo do material - CAOA' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_TIPO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_TIPO" )

aHlpPor := {}
aAdd( aHlpPor, 'Lote - CAOA.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_LOTE  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_LOTE" )

aHlpPor := {}
aAdd( aHlpPor, 'Sub-Lote - CAOA.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_SBLOTE", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_SBLOTE" )

aHlpPor := {}
aAdd( aHlpPor, 'Validade do Lote informado - CAOA.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_DTVALI", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_DTVALI" )

aHlpPor := {}
aAdd( aHlpPor, 'Endereco - CAOA.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_ENDERE", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_ENDERE" )

aHlpPor := {}
aAdd( aHlpPor, 'Num de Serie do Produto - CAOA.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_NUMSER", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_NUMSER" )

aHlpPor := {}
aAdd( aHlpPor, 'Data Geracao Pedido de Venda \ Nota' )
aAdd( aHlpPor, 'Fiscal de Saída.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_DATA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_DATA" )

aHlpPor := {}
aAdd( aHlpPor, 'Pedido de Venda - CAOA' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_PEDIDO", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_PEDIDO" )

aHlpPor := {}
aAdd( aHlpPor, 'Nota Fiscal de Saida - CAOA.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_NOTA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_NOTA" )

aHlpPor := {}
aAdd( aHlpPor, 'Serie - CAOA' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_SERIE ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_SERIE" )

aHlpPor := {}
aAdd( aHlpPor, 'Status do Processamento dos Documentos' )
aAdd( aHlpPor, 'pós Efetivação do Inventário - CAOA.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZA0_STATUS", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "ZA0_STATUS" )

AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlpX1
Função de processamento da gravação dos Helps de Perguntas

@author TOTVS Protheus
@since  10/02/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlpX1()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Perguntas" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Perguntas ..." )

//
// Helps Perguntas INVZA0
//
AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Perguntas" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "INVCAOA" ) ) ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  10/02/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0

If FindFunction( "OpenSM0Excl" )
	For nLoop := 1 To 20
		If OpenSM0Excl(,.F.)
			lOpen := .T.
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
Else
	For nLoop := 1 To 20
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
EndIf

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  10/02/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
