#INCLUDE "protheus.ch"

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
/*/{Protheus.doc} UPGAP014

Função de update de dicionários para compatibilização

@author UPDATE gerado automaticamente
@since  26/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPGAP014( cEmpAmb, cFilAmb )
Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça"
Local   cDesc4    := "um BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para"
Local   cDesc5    := "que caso ocorram eventuais falhas, esse backup possa ser restaurado."
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

	If GetVersao(.F.) < "12" .OR. ( FindFunction( "MPDicInDB" ) .AND. !MPDicInDB() )
		cMsg := "Este update NÃO PODE ser executado neste Ambiente." + CRLF + CRLF + ;
				"Os arquivos de dicionários se encontram em formato ISAM" + " (" + GetDbExtension() + ") " + "Os arquivos de dicionários se encontram em formato ISAM" + " " + ;
				"para atualizar apenas ambientes com dicionários no Banco de Dados."

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
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização realizada.", "UPGAP014" )
				Else
					MsgStop( "Atualização não realizada.", "UPGAP014" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização realizada." )
				Else
					Final( "Atualização não realizada." )
				EndIf
			EndIf

		Else
			Final( "Atualização não realizada." )

		EndIf

	Else
		Final( "Atualização não realizada." )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc

Função de processamento da gravação dos arquivos

@author UPDATE gerado automaticamente
@since  26/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
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
			// Atualiza o dicionário SX7
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX7()

			//------------------------------------
			// Atualiza o dicionário SXA
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de pastas" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXA()

			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuHlp()

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

@author UPDATE gerado automaticamente
@since  26/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
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
// Tabela SZO
//
aAdd( aSX2, { ;
	'SZO'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'SZO'+cEmpr																, ; //X2_ARQUIVO
	'CURVA ABC CAOA'														, ; //X2_NOME
	' CURVA ABC CAOA'														, ; //X2_NOMESPA
	'ABC CAOA CURVE'														, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
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

	oProcess:IncRegua2( "Atualizando Arquivos (SX2) ..." )

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

@author UPDATE gerado automaticamente
@since  26/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
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
// Campos Tabela SB1
//

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'FA'																	, ; //X3_ORDEM
	'B1_XDTINC'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Inc Prod'															, ; //X3_TITULO
	'Dt Inc Prod'															, ; //X3_TITSPA
	'Dt Inc Prod'															, ; //X3_TITENG
	'Data Inclusao do Produto'												, ; //X3_DESCRIC
	'Data Inclusao do Produto'												, ; //X3_DESCSPA
	'Data Inclusao do Produto'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'DDATABASE'																, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'F3'																	, ; //X3_ORDEM
	'B1_XDTULT'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt.Ult.Atual'															, ; //X3_TITULO
	'Dt.Ult.Atual'															, ; //X3_TITSPA
	'Dt.Ult.Atual'															, ; //X3_TITENG
	'Dt.Ult.Atualizacao'													, ; //X3_DESCRIC
	'Dt.Ult.Atualizacao'													, ; //X3_DESCSPA
	'Dt.Ult.Atualizacao'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'FB'																	, ; //X3_ORDEM
	'B1_XVENLEG'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Ultim Ven'															, ; //X3_TITULO
	'Dt Ultim Ven'															, ; //X3_TITSPA
	'Dt Ultim Ven'															, ; //X3_TITENG
	'Data da ultima Venda Lega'												, ; //X3_DESCRIC
	'Data da ultima Venda Lega'												, ; //X3_DESCSPA
	'Data da ultima Venda Lega'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'FC'																	, ; //X3_ORDEM
	'B1_X1CLEG'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'1a Comp. Leg'															, ; //X3_TITULO
	'1a Comp. Leg'															, ; //X3_TITSPA
	'1a Comp. Leg'															, ; //X3_TITENG
	'1a Compra Legado'														, ; //X3_DESCRIC
	'1a Compra Legado'														, ; //X3_DESCSPA
	'1a Compra Legado'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'FD'																	, ; //X3_ORDEM
	'B1_XUCLEG'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ult Comp Leg'															, ; //X3_TITULO
	'Ult Comp Leg'															, ; //X3_TITSPA
	'Ult Comp Leg'															, ; //X3_TITENG
	'Ultima Compra Legado'													, ; //X3_DESCRIC
	'Ultima Compra Legado'													, ; //X3_DESCSPA
	'Ultima Compra Legado'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'FE'																	, ; //X3_ORDEM
	'B1_X1VLEG'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'1a Venda Leg'															, ; //X3_TITULO
	'1a Venda Leg'															, ; //X3_TITSPA
	'1a Venda Leg'															, ; //X3_TITENG
	'1a Venda Legado'														, ; //X3_DESCRIC
	'1a Venda Legado'														, ; //X3_DESCSPA
	'1a Venda Legado'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'FF'																	, ; //X3_ORDEM
	'B1_XUVLEG'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ult Ven. Leg'															, ; //X3_TITULO
	'Ult Ven. Leg'															, ; //X3_TITSPA
	'Ult Ven. Leg'															, ; //X3_TITENG
	'Ultima Venda Legado'													, ; //X3_DESCRIC
	'Ultima Venda Legado'													, ; //X3_DESCSPA
	'Ultima Venda Legado'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SZO
//
aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZO_FILIAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'XXXXXX X'																, ; //X3_RESERV
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
	'SZO'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZO_COD'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	23																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod Produto'															, ; //X3_TITULO
	'Cod Produto'															, ; //X3_TITSPA
	'Cod Produto'															, ; //X3_TITENG
	'Cod Produto'															, ; //X3_DESCRIC
	'Cod Produto'															, ; //X3_DESCSPA
	'Cod Produto'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SB1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZO_DESCPRD'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc Produto'															, ; //X3_TITULO
	'Desc Produto'															, ; //X3_TITSPA
	'Desc Produto'															, ; //X3_TITENG
	'Descricao Produto'														, ; //X3_DESCRIC
	'Descricao Produto'														, ; //X3_DESCSPA
	'Descricao Produto'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'POSICIONE("SB1",1,XFILIAL("SB1")+SZO->ZO_COD,"B1_DESC")'				, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'if(!Inclui,Posicione("SB1",1,xFilial("SB1")+SZO->ZO_COD,"B1_DESC"),"")'	, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZO_MARCA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Marca'																	, ; //X3_TITULO
	'Marca'																	, ; //X3_TITSPA
	'Marca'																	, ; //X3_TITENG
	'Marca'																	, ; //X3_DESCRIC
	'Marca'																	, ; //X3_DESCSPA
	'Marca'																	, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZO_CURVQTD'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Curva Qtde'															, ; //X3_TITULO
	'Curva Qtde'															, ; //X3_TITSPA
	'Curva Qtde'															, ; //X3_TITENG
	'Curva Quandidade'														, ; //X3_DESCRIC
	'Curva Quandidade'														, ; //X3_DESCSPA
	'Curva Quandidade'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZO_CURVCUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Curva Custo'															, ; //X3_TITULO
	'Curva Custo'															, ; //X3_TITSPA
	'Curva Custo'															, ; //X3_TITENG
	'Curva Custo'															, ; //X3_DESCRIC
	'Curva Custo'															, ; //X3_DESCSPA
	'Curva Custo'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZO_SALDOES'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	13																		, ; //X3_TAMANHO
	3																		, ; //X3_DECIMAL
	'Sld Estoque'															, ; //X3_TITULO
	'Sld Estoque'															, ; //X3_TITSPA
	'Sld Estoque'															, ; //X3_TITENG
	'Saldo em Estoque'														, ; //X3_DESCRIC
	'Saldo em Estoque'														, ; //X3_DESCSPA
	'Saldo em Estoque'														, ; //X3_DESCENG
	'@E 999,999,999.999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZO_CUSTUNI'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Custo Unitar'															, ; //X3_TITULO
	'Custo Unitar'															, ; //X3_TITSPA
	'Custo Unitar'															, ; //X3_TITENG
	'Custo Unitario'														, ; //X3_DESCRIC
	'Custo Unitario'														, ; //X3_DESCSPA
	'Custo Unitario'														, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZO_CUSTTOT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Custo Total'															, ; //X3_TITULO
	'Custo Total'															, ; //X3_TITSPA
	'Custo Total'															, ; //X3_TITENG
	'Custo Total'															, ; //X3_DESCRIC
	'Custo Total'															, ; //X3_DESCSPA
	'Custo Total'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZO_DTPRDCA'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Cad. Prd'															, ; //X3_TITULO
	'Dt Cad. Prd'															, ; //X3_TITSPA
	'Dt Cad. Prd'															, ; //X3_TITENG
	'Data do cadastro Produto'												, ; //X3_DESCRIC
	'Data do cadastro Produto'												, ; //X3_DESCSPA
	'Data do cadastro Produto'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZO_MESINCL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Meses Cad'																, ; //X3_TITULO
	'Meses Cad'																, ; //X3_TITSPA
	'Meses Cad'																, ; //X3_TITENG
	'Meses da inclusao'														, ; //X3_DESCRIC
	'Meses da inclusao'														, ; //X3_DESCSPA
	'Meses da inclusao'														, ; //X3_DESCENG
	'@E 9999'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZO_DTPRCMP'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt_Prim.CMP'															, ; //X3_TITULO
	'Dt_Prim.CMP'															, ; //X3_TITSPA
	'Dt_Prim.CMP'															, ; //X3_TITENG
	'Data Primeira Compra'													, ; //X3_DESCRIC
	'Data Primeira Compra'													, ; //X3_DESCSPA
	'Data Primeira Compra'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZO_MESPCMP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Meses P.Comp'															, ; //X3_TITULO
	'Meses P.Comp'															, ; //X3_TITSPA
	'Meses P.Comp'															, ; //X3_TITENG
	'Meses ref primeira Compra'												, ; //X3_DESCRIC
	'Meses ref primeira Compra'												, ; //X3_DESCSPA
	'Meses ref primeira Compra'												, ; //X3_DESCENG
	'@E 9999'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'ZO_DTULCMP'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Ult Compr'															, ; //X3_TITULO
	'Dt Ult Compr'															, ; //X3_TITSPA
	'Dt Ult Compr'															, ; //X3_TITENG
	'Data da ultima Compra'													, ; //X3_DESCRIC
	'Data da ultima Compra'													, ; //X3_DESCSPA
	'Data da ultima Compra'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'ZO_MESUCMP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Meses U.Comp'															, ; //X3_TITULO
	'Meses U.Comp'															, ; //X3_TITSPA
	'Meses U.Comp'															, ; //X3_TITENG
	'Meses ref ultima Compra'												, ; //X3_DESCRIC
	'Meses ref ultima Compra'												, ; //X3_DESCSPA
	'Meses ref ultima Compra'												, ; //X3_DESCENG
	'@E 9999'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'ZO_DTPRVND'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Pri Ven'															, ; //X3_TITULO
	'Data Pri Ven'															, ; //X3_TITSPA
	'Data Pri Ven'															, ; //X3_TITENG
	'Data Primeira Venda'													, ; //X3_DESCRIC
	'Data Primeira Venda'													, ; //X3_DESCSPA
	'Data Primeira Venda'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'ZO_MESPVEN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Meses P.Vend'															, ; //X3_TITULO
	'Meses P.Vend'															, ; //X3_TITSPA
	'Meses P.Vend'															, ; //X3_TITENG
	'Meses ref Primeira Venda'												, ; //X3_DESCRIC
	'Meses ref Primeira Venda'												, ; //X3_DESCSPA
	'Meses ref Primeira Venda'												, ; //X3_DESCENG
	'@E 9999'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'18'																	, ; //X3_ORDEM
	'ZO_DTULVND'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Ult Venda'															, ; //X3_TITULO
	'Dt Ult Venda'															, ; //X3_TITSPA
	'Dt Ult Venda'															, ; //X3_TITENG
	'Data Ultima Venda'														, ; //X3_DESCRIC
	'Data Ultima Venda'														, ; //X3_DESCSPA
	'Data Ultima Venda'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'ZO_MESUVEN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Meses U.Vend'															, ; //X3_TITULO
	'Meses U.Vend'															, ; //X3_TITSPA
	'Meses U.Vend'															, ; //X3_TITENG
	'Meses ref a ultima Venda'												, ; //X3_DESCRIC
	'Meses ref a ultima Venda'												, ; //X3_DESCSPA
	'Meses ref a ultima Venda'												, ; //X3_DESCENG
	'@E 9999'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'20'																	, ; //X3_ORDEM
	'ZO_TOTVEND'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	13																		, ; //X3_TAMANHO
	3																		, ; //X3_DECIMAL
	'Qtd Tot Vend'															, ; //X3_TITULO
	'Qtd Tot Vend'															, ; //X3_TITSPA
	'Qtd Tot Vend'															, ; //X3_TITENG
	'Qtd Tota Venda Curva'													, ; //X3_DESCRIC
	'Qtd Tota Venda Curva'													, ; //X3_DESCSPA
	'Qtd Tota Venda Curva'													, ; //X3_DESCENG
	'@E 999,999,999.999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'21'																	, ; //X3_ORDEM
	'ZO_MEDIADE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	13																		, ; //X3_TAMANHO
	3																		, ; //X3_DECIMAL
	'Media Venda'															, ; //X3_TITULO
	'Media Venca'															, ; //X3_TITSPA
	'Media Venca'															, ; //X3_TITENG
	'Media Venca ultimos meses'												, ; //X3_DESCRIC
	'Media Venca ultimos meses'												, ; //X3_DESCSPA
	'Media Venca ultimos meses'												, ; //X3_DESCENG
	'@E 999,999,999.999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'22'																	, ; //X3_ORDEM
	'ZO_MOS'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	13																		, ; //X3_TAMANHO
	3																		, ; //X3_DECIMAL
	'MOS'																	, ; //X3_TITULO
	'MOS'																	, ; //X3_TITSPA
	'MOS'																	, ; //X3_TITENG
	'MOS'																	, ; //X3_DESCRIC
	'MOS'																	, ; //X3_DESCSPA
	'MOS'																	, ; //X3_DESCENG
	'@E 999,999,999.999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'23'																	, ; //X3_ORDEM
	'ZO_EXQTDE'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	13																		, ; //X3_TAMANHO
	3																		, ; //X3_DECIMAL
	'Excesso Qtde'															, ; //X3_TITULO
	'Excesso Qtde'															, ; //X3_TITSPA
	'Excesso Qtde'															, ; //X3_TITENG
	'Excesso Qtde'															, ; //X3_DESCRIC
	'Excesso Qtde'															, ; //X3_DESCSPA
	'Excesso Qtde'															, ; //X3_DESCENG
	'@E 999,999,999.999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'24'																	, ; //X3_ORDEM
	'ZO_EXCUSTO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Excesso Cust'															, ; //X3_TITULO
	'Excesso Cust'															, ; //X3_TITSPA
	'Excesso Cust'															, ; //X3_TITENG
	'Excesso Custo'															, ; //X3_DESCRIC
	'Excesso Custo'															, ; //X3_DESCSPA
	'Excesso Custo'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'25'																	, ; //X3_ORDEM
	'ZO_PONTOS'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pontos Curva'															, ; //X3_TITULO
	'Pontos Curva'															, ; //X3_TITSPA
	'Pontos Curva'															, ; //X3_TITENG
	'Qtde de Pontos Curva ABC'												, ; //X3_DESCRIC
	'Qtde de Pontos Curva ABC'												, ; //X3_DESCSPA
	'Qtde de Pontos Curva ABC'												, ; //X3_DESCENG
	'@E 9999'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'26'																	, ; //X3_ORDEM
	'ZO_DTBASEC'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Base de Calc'															, ; //X3_TITULO
	'Base de Calc'															, ; //X3_TITSPA
	'Base de Calc'															, ; //X3_TITENG
	'Base de Calculo'														, ; //X3_DESCRIC
	'Base de Calculo'														, ; //X3_DESCSPA
	'Base de Calculo'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'27'																	, ; //X3_ORDEM
	'ZO_CODUSU'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod Usuario'															, ; //X3_TITULO
	'Cod Usuario'															, ; //X3_TITSPA
	'Cod Usuario'															, ; //X3_TITENG
	'Cod Usuario'															, ; //X3_DESCRIC
	'Cod Usuario'															, ; //X3_DESCSPA
	'Cod Usuario'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'RETCODUSR()'															, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'28'																	, ; //X3_ORDEM
	'ZO_DTCALC'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Calc Real'															, ; //X3_TITULO
	'Dt Calc Real'															, ; //X3_TITSPA
	'Dt Calc Real'															, ; //X3_TITENG
	'Data Calculo realizado'												, ; //X3_DESCRIC
	'Data Calculo realizado'												, ; //X3_DESCSPA
	'Data Calculo realizado'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'DATE()'																, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'29'																	, ; //X3_ORDEM
	'ZO_HSCALC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hs Calc Real'															, ; //X3_TITULO
	'Hs Calc Real'															, ; //X3_TITSPA
	'Hs Calc Real'															, ; //X3_TITENG
	'Hora realizado calculo'												, ; //X3_DESCRIC
	'Hora realizado calculo'												, ; //X3_DESCSPA
	'Hora realizado calculo'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZO'																	, ; //X3_ARQUIVO
	'30'																	, ; //X3_ORDEM
	'ZO_NOMEUSU'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Usuario'															, ; //X3_TITULO
	'Nome Usuario'															, ; //X3_TITSPA
	'Nome Usuario'															, ; //X3_TITENG
	'Nome Usuario curva ABC'												, ; //X3_DESCRIC
	'Nome Usuario curva ABC'												, ; //X3_DESCSPA
	'Nome Usuario curva ABC'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
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
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
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

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3) ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX

Função de processamento da gravação do SIX - Indices

@author UPDATE gerado automaticamente
@since  26/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
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
// Tabela SZO
//
aAdd( aSIX, { ;
	'SZO'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZO_FILIAL+ZO_COD'														, ; //CHAVE
	'Cod Produto'															, ; //DESCRICAO
	'Cod Produto'															, ; //DESCSPA
	'Cod Produto'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'SZO01'																	, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SZO'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZO_FILIAL+ZO_CURVQTD'													, ; //CHAVE
	'Curva Qtde'															, ; //DESCRICAO
	'Curva Qtde'															, ; //DESCSPA
	'Curva Qtde'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'SZO02'																	, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SZO'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'ZO_FILIAL+ZO_CURVCUS'													, ; //CHAVE
	'Curva Custo'															, ; //DESCRICAO
	'Curva Custo'															, ; //DESCSPA
	'Curva Custo'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'SZO03'																	, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

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

	oProcess:IncRegua2( "Atualizando índices ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6

Função de processamento da gravação do SX6 - Parâmetros

@author UPDATE gerado automaticamente
@since  26/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
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
	'CAOAAJU012'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tes de Faturamento Zona Franca'										, ; //X6_DESCRIC
	'Tes de Faturamento Zona Franca'										, ; //X6_DSCSPA
	'Tes de Faturamento Zona Franca'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'714|721|709|718'														, ; //X6_CONTEUD
	'714|721|709|718'														, ; //X6_CONTSPA
	'714|721|709|718'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOAAJU013'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'300'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOADSCLI'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informar os clientes que possuem ZFM'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"000184"'																, ; //X6_CONTEUD
	'"000184"'																, ; //X6_CONTSPA
	'"000184"'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOADSPRO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Produtos tratamento ZFM.'												, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"HEH76B857DA10AESWAS|HEH76B857DA10BESWAS"'								, ; //X6_CONTEUD
	'"HEH76B857DA10AESWAS|HEH76B857DA10BESWAS"'								, ; //X6_CONTSPA
	'"HEH76B857DA10AESWAS|HEH76B857DA10BESWAS"'								, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOAFTMNEX'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipos de orcamento (VS1_XTPPED) que terao excecao'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	' a regra (003=Emergencial)'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'002,003'																, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOAFTMNOR'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Valor numerico minimo para faturamento'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	'1000'																	, ; //X6_CONTSPA
	'1000'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOAFTMNUS'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'IDs dos usuarios que terao excecao a regra'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000637,000790,000625,000626'											, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	'000637'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOAORESTP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Lps de devolucao - integracao SAP'										, ; //X6_DESCRIC
	'Lps de devolucao - integracao SAP'										, ; //X6_DSCSPA
	'Lps de devolucao - integracao SAP'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'650-004/650-005/650-072/650-073'										, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP01A'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Url do WS CAOA Cadastro de Fornecedores'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://10.120.40.141:53400/dir/wsdl?p=ic/9f324344323d391792946bbd98bd4139'	, ; //X6_CONTEUD
	'http://10.120.40.141:53400/dir/wsdl?p=ic/9f324344323d391792946bbd98bd4139'	, ; //X6_CONTSPA
	'http://10.120.40.141:53400/dir/wsdl?p=ic/9f324344323d391792946bbd98bd4139'	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP01C'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Quantidade de dias para reenviar registros com'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'status de Erro no SAP.'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'7'																		, ; //X6_CONTSPA
	'7'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP02A'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Url do WS CAOA Cadastro de Clientes'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://10.120.40.141:53400/dir/wsdl?p=ic/97d120e0442d33278268b0eccac3643c'	, ; //X6_CONTEUD
	'http://10.120.40.141:53400/dir/wsdl?p=ic/97d120e0442d33278268b0eccac3643c'	, ; //X6_CONTSPA
	'http://10.120.40.141:53400/dir/wsdl?p=ic/97d120e0442d33278268b0eccac3643c'	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP03A'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Url do WS CAOA Cadastro de Contas a Pagar'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://10.120.40.141:53400/dir/wsdl?p=ic/7e57f79630be3849a4ebcfa108259ed4'	, ; //X6_CONTEUD
	'http://10.120.40.141:53400/dir/wsdl?p=ic/7e57f79630be3849a4ebcfa108259ed4'	, ; //X6_CONTSPA
	'http://10.120.40.141:53400/dir/wsdl?p=ic/7e57f79630be3849a4ebcfa108259ed4'	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP03D'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Url do WS CAOA Cadastro de Contas a Pagar - Frete/'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'GNRE'																	, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://10.120.40.141:53400/dir/wsdl?p=ic/913e3fad55e73c668da03847cc77174a'	, ; //X6_CONTEUD
	'http://10.120.40.141:53400/dir/wsdl?p=ic/913e3fad55e73c668da03847cc77174a'	, ; //X6_CONTSPA
	'http://10.120.40.141:53400/dir/wsdl?p=ic/913e3fad55e73c668da03847cc77174a'	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP08A'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Url do WS CAOA Lancamento Contabil'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://10.120.40.141:53400/dir/wsdl?p=ic/7cd73db8a3283b5cbbbf1fe55d2f205c'	, ; //X6_CONTEUD
	'http://10.120.40.141:53400/dir/wsdl?p=ic/7cd73db8a3283b5cbbbf1fe55d2f205c'	, ; //X6_CONTSPA
	'http://10.120.40.141:53400/dir/wsdl?p=ic/7cd73db8a3283b5cbbbf1fe55d2f205c'	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP09A'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Rotinas dos Lançamentos contabeis que serão'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'enviados para o SAP'													, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'CTBA102|MATA330|CTBANFE|CTBANFS|CTBA500|FINA350|CTBA280|MATA103|MATA460|FINA370|GFEA065|MATA250|MATA240|MATA241|FINA050|CMVCTBCUS', ; //X6_CONTEUD
	'CTBA102|MATA330|CTBANFE|CTBANFS|CTBA500|FINA350|CTBA280|MATA103|MATA460|FINA370|GFEA065|MATA250|MATA240|MATA241|FINA050|CMVCTBCUS', ; //X6_CONTSPA
	'CTBA102|MATA330|CTBANFE|CTBANFS|CTBA500|FINA350|CTBA280|MATA103|MATA460|FINA370|GFEA065|MATA250|MATA240|MATA241|FINA050|CMVCTBCUS', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP12A'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Url do WS CAOA Cadastro de Contas a Receber'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://10.120.40.141:53400/dir/wsdl?p=ic/67105a33fc843b8b843c892dae69f375'	, ; //X6_CONTEUD
	'http://10.120.40.141:53400/dir/wsdl?p=ic/67105a33fc843b8b843c892dae69f375'	, ; //X6_CONTSPA
	'http://10.120.40.141:53400/dir/wsdl?p=ic/67105a33fc843b8b843c892dae69f375'	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP18A'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Desabilita inclusao/copia manual de lancamento con'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'tabil.'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP18B'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Desabilita manutencao em lancamento contabil com'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'origem no SAP.'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP18C'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Desabilita manutencao em lancamento contabil ja'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'enviado ao SAP.'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP18E'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Rotinas que podem ser excluidas via lancamento con'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'tabil. Integracao com SAP.'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'008840|003200'															, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP19A'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Origem dos titulos a considerar para os titulos do'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'financeiro, na integracao com SAP.'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SIGAESS/SIGAEIC/SIGAEFF/FINA050/'										, ; //X6_CONTEUD
	'SIGAESS/SIGAEIC/SIGAEFF/FINA050/'										, ; //X6_CONTSPA
	'SIGAESS/SIGAEIC/SIGAEFF/FINA050/'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP19B'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipos de titulos a considerar para os titulos do'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'EIC, na integracao com SAP.'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'NF/INV/TX/DP/PA/BOL/'													, ; //X6_CONTEUD
	'NF/INV/TX/DP/PA/BOL/'													, ; //X6_CONTSPA
	'NF/INV/TX/DP/PA/BOL/'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP19C'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Naturezas para considerar para os titulos tipo TX'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'na integracao com SAP.'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2305/2104/2105/'														, ; //X6_CONTEUD
	'2305/2104/2105/'														, ; //X6_CONTSPA
	'2305/2104/2105/'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOASAP251'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Senha para processamento da reintegração SAP'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SAP'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_DIATR'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Dias de atraso para bloqueio dos titulos'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'em aberto na rotina de analise de limite de credit'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Utilizado somente via JOB'												, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_FLO01'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condição de Pagamento Floor Plan'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'006'																	, ; //X6_CONTEUD
	'006'																	, ; //X6_CONTSPA
	'006'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_FLO02'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Numeracao da programacao Floorplan'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'130361'																, ; //X6_CONTEUD
	'130361'																, ; //X6_CONTSPA
	'130361'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_FLO03'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Numeracao envio Faturamento - Floorplan'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'001134'																, ; //X6_CONTEUD
	'001134'																, ; //X6_CONTSPA
	'001134'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_HISTA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'HISTORICO DE ALTERACAO - SEGUINDO A LOGIDA DE'							, ; //X6_DESCRIC
	'HISTORICO DE ALTERACAO - SEGUINDO A LOGIDA DE'							, ; //X6_DSCSPA
	'HISTORICO DE ALTERACAO - SEGUINDO A LOGIDA DE'							, ; //X6_DSCENG
	'INCLUSAO,ALTERACAO,EXCLUSAO  {.T.,.T.,.F.}'							, ; //X6_DESC1
	'INCLUSAO,ALTERACAO,EXCLUSAO  {.T.,.T.,.F.}'							, ; //X6_DSCSPA1
	'INCLUSAO,ALTERACAO,EXCLUSAO  {.F.,.T.,.F.}'							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'{.F.,.T.,.F.}'															, ; //X6_CONTEUD
	'{.T.,.T.,.F.}'															, ; //X6_CONTSPA
	'{.T.,.T.,.F.}'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_MXTHR'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Numero maximo de Threads para ser utilizada'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'na rotina de calculo de limite de credito'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'50'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_STALM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Status que sao avaliados na rotina de l'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'limite de credito CAOA - Utilizado somente via JOB'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'01;02;03;'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_STBLQ'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo do Status de Bloqueado para ser'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'atualizado no cadastro do cliente'										, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'via rotina de analise de credito CAOA.'								, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'02'																	, ; //X6_CONTEUD
	'02'																	, ; //X6_CONTSPA
	'02'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_STLIB'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo do Status de Liberado para ser atualizado'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'no cadastro do cliente, via rotina de analise de'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'credito CAOA'															, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	'01'																	, ; //X6_CONTSPA
	'01'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_STUSR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Lista de usuarios (ID) permitidos para selecao de'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'qualquer valor do campo "Status" (A1_XSTATUS) no'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'cadastro de Cliente.'													, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000009|000034|000095|000154|000157|000158|000126|000244'				, ; //X6_CONTEUD
	'000009|000034|000095|000154|000157|000158|000126|000244'				, ; //X6_CONTSPA
	'000009|000034|000095|000154|000157|000158|000126|000244'				, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_TPLIM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipos de Operação para analise do crédito - CAOA'						, ; //X6_DESCRIC
	'Tipos de Operação para analise do crédito - CAOA'						, ; //X6_DSCSPA
	'Tipos de Operação para analise do crédito - CAOA'						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_VEI01'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Ambiente SERPRO'														, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'PR'																	, ; //X6_CONTEUD
	'PR'																	, ; //X6_CONTSPA
	'PR'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_WS001'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Envio de Chassi AutoWare'												, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Envio de Chassi AutoWare'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Envio de Chassi AutoWare'												, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://10.120.41.106/servicos/v2/chassi.asmx?WSDL'						, ; //X6_CONTEUD
	'http://10.120.41.106/servicos/v2/chassi.asmx?WSDL'						, ; //X6_CONTSPA
	'http://10.120.41.106/servicos/v2/chassi.asmx?WSDL'						, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_WS003'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Status do Pedido AutoWare'												, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Status do Pedido AutoWare'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Status do Pedido AutoWare'												, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://10.120.41.106/Servicos/v2/PedidoVeiculo.asmx?WSDL'				, ; //X6_CONTEUD
	'http://10.120.41.106/Servicos/v2/PedidoVeiculo.asmx?WSDL'				, ; //X6_CONTSPA
	'http://10.120.41.106/Servicos/v2/PedidoVeiculo.asmx?WSDL'				, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CAOA_WS004'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Nota Fiscal AutoWare'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://10.120.41.106/Servicos/v2/NotaFiscal.asmx?WSDL'					, ; //X6_CONTEUD
	'http://10.120.41.106/Servicos/v2/NotaFiscal.asmx?WSDL'					, ; //X6_CONTSPA
	'http://10.120.41.106/Servicos/v2/NotaFiscal.asmx?WSDL'					, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_CFG001'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Paramentros SduLogin'													, ; //X6_DESCRIC
	'Paramentros SduLogin'													, ; //X6_DSCSPA
	'Paramentros SduLogin'													, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"000095*000009"'														, ; //X6_CONTEUD
	'"000095*000009"'														, ; //X6_CONTSPA
	'"000095*000009"'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_CODALF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condicao de pagamento e texto impresso'								, ; //X6_DESCRIC
	'Condicao de pagamento e texto impresso'								, ; //X6_DSCSPA
	'Condicao de pagamento e texto impresso'								, ; //X6_DSCENG
	'na NF banco alfa na venda de veiculo'									, ; //X6_DESC1
	'na NF banco alfa na venda de veiculo'									, ; //X6_DSCSPA1
	'na NF banco alfa na venda de veiculo'									, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'005-VEICULO VENDIDO COM ALIENACAO FIDUCIARIA A FAVOR DE FINANCEIRA ALFA SA CRED FINANC E INVESTIMENTO.     CNPJ 17.167.412/0001-13', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_COL002'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigos EDI que serao considerados pela rotina'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ZCOMF016'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'109/214'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_COL003'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigos de erro que serao desconsiderados pela'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'rotina ZCOMF016'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'COM005/COM006/COM019'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_EIC01A'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define o diretorio de integração dos arquivos de'						, ; //X6_DESCRIC
	'Define o diretorio de integração dos arquivos de'						, ; //X6_DSCSPA
	'Define o diretorio de integração dos arquivos de'						, ; //X6_DSCENG
	'invoice antecipada.'													, ; //X6_DESC1
	'invoice antecipada.'													, ; //X6_DSCSPA1
	'invoice antecipada.'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'c:\_nicolas\invoice_1.csv'												, ; //X6_CONTEUD
	'c:\_nicolas\invoice_1.csv'												, ; //X6_CONTSPA
	'c:\_nicolas\invoice_1.csv'												, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_EIC01B'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Filiais habilitadas para uso de rotina'								, ; //X6_DESCRIC
	'Filiais habilitadas para uso de rotina'								, ; //X6_DSCSPA
	'Filiais habilitadas para uso de rotina'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2010022001|2020012001'													, ; //X6_CONTEUD
	'2010022001/'															, ; //X6_CONTSPA
	'2010022001/'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_EICAC1'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que possuem acesso ao EIC'									, ; //X6_DESCRIC
	'Usuarios que possuem acesso ao EIC'									, ; //X6_DSCSPA
	'Usuarios que possuem acesso ao EIC'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"000037|000039|000041|000088|000097|000164|000172|000178|000186|000288|000296|000306|000347|000449|000265|000649|000650"', ; //X6_CONTEUD
	'"000037|000039|000041|000088|000097|000164|000172|000178|000186|000288|000296|000306|000347|000449|000265|000649|000650"', ; //X6_CONTSPA
	'"000037|000039|000041|000088|000097|000164|000172|000178|000186|000288|000296|000306|000347|000449|000265|000649|000650"', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_EST001'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Pasta onde deve ser colocado o arquivo de importac'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ao XML, CSV'															, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'Y:\01. TRANSPORTE\04- TRANSPORTE\Importacao\Arquivo_importa\'			, ; //X6_CONTEUD
	'Y:\01. TRANSPORTE\04- TRANSPORTE\Importacao\Arquivo_importa\'			, ; //X6_CONTSPA
	'Y:\01. TRANSPORTE\04- TRANSPORTE\Importacao\Arquivo_importa\'			, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_EST002'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Almoxarifado para entrada de recebimento (SINC)'						, ; //X6_DESCRIC
	'Almoxarifado para entrada de recebimento (SINC)'						, ; //X6_DSCSPA
	'Almoxarifado para entrada de recebimento (SINC)'						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'907'																	, ; //X6_CONTEUD
	'907'																	, ; //X6_CONTSPA
	'907'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_EST003'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condicao Pagamento no recebimemnto (SINC)'								, ; //X6_DESCRIC
	'Condicao Pagamento no recebimemnto (SINC)'								, ; //X6_DSCSPA
	'Condicao Pagamento no recebimemnto (SINC)'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'003'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_FAT001'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Indica se processa JOB de Limite de Credito'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ZFATJ001'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_FAT002'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo para serem informados os email´s que receber'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ao a planilha de consulta do Faturamento'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	't-lucas.carvalho@caoa.com.br; victor.gabriel@caoamontadora.com.br;'	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_FAT003'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo para serem informados os email´s que receber'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ao a planilha de consulta do Faturamento'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'marciel.perez@caoamontadora.com.br; rodrigo.mendes@caoamontadora.com.br; bruno.santana@caoa.com.br; lidyane.almeida@caoamontadora.com.br; marcia.rodrigues@caoamontadora.com.br; aparecida.kirihara@caoa.com.br; cleiton.junior@caoa.com.br;', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_FAT004'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Caminho aonde a planilha de consulta de Faturament'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'o sera gravada'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	' \Cons_Faturamento\'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_FAT007'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condicao de pagamento CAOA para validacao de Limit'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_FAT008'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Processa validacao do cancelamento para exclusao'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_FAT011'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Cond.Pgto do Foolrplan p/ gerar parcela 1'								, ; //X6_DESCRIC
	'Cond.Pgto do Foolrplan p/ gerar parcela 1'								, ; //X6_DSCSPA
	'Cond.Pgto do Foolrplan p/ gerar parcela 1'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'005'																	, ; //X6_CONTEUD
	'005'																	, ; //X6_CONTSPA
	'005'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_FIS004'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'SAFX113 - Difal Diferencial de aliquota Goias'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'parametro de CFOP'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2556;2557'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_GFE001'															, ; //X6_VAR
	'D'																		, ; //X6_TIPO
	'Data Inicio'															, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_IMP01B'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Numero de Transacoes x Thread'											, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'10'																	, ; //X6_CONTSPA
	'10'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_IMP01C'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Numero Maximo de Threads'												, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
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
	'CMV_IMP01G'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Numero de Slaves disponiveis para processar Thread'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
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
	'CMV_LCTSAP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Lote Para lançamentos contábeis vindos do SAP'							, ; //X6_DESCRIC
	'Lote Para lançamentos contábeis vindos do SAP'							, ; //X6_DSCSPA
	'Lote Para lançamentos contábeis vindos do SAP'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'009900'																, ; //X6_CONTEUD
	'009900'																, ; //X6_CONTSPA
	'009900'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_MNTAC1'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que possuem acesso ao MNT'									, ; //X6_DESCRIC
	'Usuarios que possuem acesso ao MNT'									, ; //X6_DSCSPA
	'Usuarios que possuem acesso ao MNT'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"000018|000021|000025|000026|000027|000098|000102|000103|000104|000105|000111|000117|000118|000119|000120|000122|000124|000181|000266|000279|000281|000311|000502|000503|000747|000781|000782|000783|000784"', ; //X6_CONTEUD
	'"000018|000021|000025|000026|000027|000098|000102|000103|000104|000105|000111|000117|000118|000119|000120|000122|000124|000181|000266|000279|000281|000311|000502|000503|000747|000781|000782|000783|000784"', ; //X6_CONTSPA
	'"000018|000021|000025|000026|000027|000098|000102|000103|000104|000105|000111|000117|000118|000119|000120|000122|000124|000181|000266|000279|000281|000311|000502|000503|000747|000781|000782|000783|000784"', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_MNTPT1'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Acesso ao Portal MNT'													, ; //X6_DESCRIC
	'Acesso ao Portal MNT'													, ; //X6_DSCSPA
	'Acesso ao Portal MNT'													, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"000478|000479|000480|000481|000482|000483|000485|000486|000487|000488|000489|000490|000491|000492|000493|000494|000551|000552"', ; //X6_CONTEUD
	'"000478|000479|000480|000481|000482|000483|000485|000486|000487|000488|000489|000490|000491|000492|000493|000494|000551|000552"', ; //X6_CONTSPA
	'"000478|000479|000480|000481|000482|000483|000485|000486|000487|000488|000489|000490|000491|000492|000493|000494|000551|000552"', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_OPINSP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indicar a Operação Insenta do Protocolo'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'81|10|11'																, ; //X6_CONTEUD
	'81|10|11'																, ; //X6_CONTSPA
	'81|10|11'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PCP001'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Parametro para habilitar/desabilitar funcionalidad'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ZPCPF007 responsavel por atualizacao movimntacao i'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'T'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PCP002'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'E-mail para envio problemas integracao TOTVS x MES'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'rodrigo.nunes@caoamontadora.com.br;gabriella.rosa@caoamontadora.com.br;leoncio.rodrigues@caoamontadora.com.br;nata.milhomem@caoamontadora.com.br', ; //X6_CONTEUD
	'rodrigo.nunes@caoamontadora.com.br;gabriella.rosa@caoamontadora.com.br;leoncio.rodrigues@caoamontadora.com.br;nata.milhomem@caoamontadora.com.br', ; //X6_CONTSPA
	'rodrigo.nunes@caoamontadora.com.br;gabriella.rosa@caoamontadora.com.br;leoncio.rodrigues@caoamontadora.com.br;nata.milhomem@caoamontadora.com.br', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PCP003'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Local padrao para veiculos novos'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'VN'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PCP004'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Grupo de produtos padrao para veiculos novos'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'VEIA'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PCP005'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilitar/desabilitar funcionalidade de verificaca'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'integracao MES x Protheus ZPCPF009'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PCP006'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita botao reprocessar do Backflush'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PCP007'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita e Inicializa o Job do BackFlush CAOA'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PCP05A'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Sequencia (C2_SEQUEN) da OP referente ao Body'							, ; //X6_DESCRIC
	'Sequencia (C2_SEQUEN) da OP referente ao Body'							, ; //X6_DSCSPA
	'Sequencia (C2_SEQUEN) da OP referente ao Body'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'004'																	, ; //X6_CONTEUD
	'004'																	, ; //X6_CONTSPA
	'004'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PCP05B'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Código de Tipo de Movimento (TM) de Produção'							, ; //X6_DESCRIC
	'Código de Tipo de Movimento (TM) de Produção'							, ; //X6_DSCSPA
	'Tipo de Movimento (TM) de Produção'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'100'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PCP05D'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Endereçamento OKNOK - Endereço NOK'									, ; //X6_DESCRIC
	'Endereçamento OKNOK - Endereço NOK'									, ; //X6_DSCSPA
	'Endereçamento OKNOK - Endereço NOK'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'98010101'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC002'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Moeda: 1 - Reais'														, ; //X6_DESCRIC
	'Moeda: 1 - Reais'														, ; //X6_DSCSPA
	'Moeda: 1 - Reais'														, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
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
	'CMV_PEC003'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo Operacao:  4 - Todos'												, ; //X6_DESCRIC
	'Tipo Operacao:  4 - Todos'												, ; //X6_DSCSPA
	'Tipo Operacao:  4 - Todos'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'4'																		, ; //X6_CONTEUD
	'4'																		, ; //X6_CONTSPA
	'4'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC004'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo Preco:  1 - Preco de Venda'										, ; //X6_DESCRIC
	'Tipo Preco:  1 - Preco de Venda'										, ; //X6_DSCSPA
	'Tipo Preco:  1 - Preco de Venda'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
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
	'CMV_PEC005'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Valor numerico minimo para faturamento'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	'1000'																	, ; //X6_CONTSPA
	'1000'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC006'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipos de orcamento (VS1_XTPPED) que terao excecao'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	' a regra (003=Emergencial)'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'002,003'																, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC007'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'IDs dos usuarios que terao excecao a regra'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000637,000790,000625,000626'											, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	'000637'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC008'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Pasta onde deve ser colocado o arquivo de importac'					, ; //X6_DESCRIC
	'Pasta onde deve ser colocado o arquivo de importac'					, ; //X6_DSCSPA
	'Pasta onde deve ser colocado o arquivo de importac'					, ; //X6_DSCENG
	'ao da tabela de preços'												, ; //X6_DESC1
	'ao da tabela de preços'												, ; //X6_DSCSPA1
	'ao da tabela de preços'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'C:\Temp\'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC014'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Quantidades de dias para retroagir nos parametros'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'RGLOG - Romaneio'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC015'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro para guardar a key de comunicacao com a'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'RGLOG - Romaneio'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://www.rgtracking.com.br'											, ; //X6_CONTEUD
	'http://www.rgtracking.com.br'											, ; //X6_CONTSPA
	'http://www.rgtracking.com.br'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC016'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro para guardar URL de comunicacao'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'RGLOG - Romaneio'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'/rglog/edi/MinhasColetasJson.php?formato=json&op=3736&filtro=coleta&dataI=25/05/2022&dataF=25/05/2022&aut=N&st=D', ; //X6_CONTEUD
	'/rglog/edi/MinhasColetasJson.php?formato=json&op=3736&filtro=coleta&dataI=25/05/2022&dataF=25/05/2022&aut=N&st=D', ; //X6_CONTSPA
	'/rglog/edi/MinhasColetasJson.php?formato=json&op=3736&filtro=coleta&dataI=25/05/2022&dataF=25/05/2022&aut=N&st=D', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC017'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'ID de usuario bloqueado para o Meufatura'								, ; //X6_DESCRIC
	'ID de usuario bloqueado para o Meufatura'								, ; //X6_DSCSPA
	'ID de usuario bloqueado para o Meufatura'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000831,000832,000833,000834,000835,000836,000838'						, ; //X6_CONTEUD
	'000831,000832,000833,000834,000835,000836,000838'						, ; //X6_CONTSPA
	'000831,000832,000833,000834,000835,000836,000838'						, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC018'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'ID de Condicao de Pagamento FORPLAN'									, ; //X6_DESCRIC
	'ID de Condicao de Pagamento FORPLAN'									, ; //X6_DSCSPA
	'ID de Condicao de Pagamento FORPLAN'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'005'																	, ; //X6_CONTEUD
	'005'																	, ; //X6_CONTSPA
	'005'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC019'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazem de recebimento Barueri'										, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'80'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC020'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazem Disponivel para Venda Barueri'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC021'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Link para captura de Json para geracao automatica'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'de romaneio com filtro por chave do CTE'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'/rglog/edi/MinhasColetasJson.php?formato=json&op=3736&filtro=chave&valor=35220510213051001399570010005184801005184809', ; //X6_CONTEUD
	'/rglog/edi/MinhasColetasJson.php?formato=json&op=3736&filtro=chave&valor=35220510213051001399570010005184801005184809', ; //X6_CONTSPA
	'/rglog/edi/MinhasColetasJson.php?formato=json&op=3736&filtro=chave&valor=35220510213051001399570010005184801005184809', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC022'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Desconsidera validação se possue item Substituto'						, ; //X6_DESCRIC
	'Desconsidera validação se possue item Substituto'						, ; //X6_DSCSPA
	'Desconsidera validação se possue item Substituto'						, ; //X6_DSCENG
	'de acordo com a Marca no processo da Onda'								, ; //X6_DESC1
	'de acordo com a Marca no processo da Onda'								, ; //X6_DSCSPA1
	'de acordo com a Marca no processo da Onda'								, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SBR;HYU;CHE'															, ; //X6_CONTEUD
	'SBR;HYU;CHE'															, ; //X6_CONTSPA
	'SBR;HYU;CHE'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC023'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita o Bloqueio do Faturamento por Marca'							, ; //X6_DESCRIC
	'Habilita o Bloqueio do Faturamento por Marca'							, ; //X6_DSCSPA
	'Habilita o Bloqueio do Faturamento por Marca'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC024'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Consulta Saldo WIS na Onda'											, ; //X6_DESCRIC
	'Consulta Saldo WIS na Onda'											, ; //X6_DSCSPA
	'Consulta Saldo WIS na Onda'											, ; //X6_DSCENG
	'Consulta Saldo WIS na Onda'											, ; //X6_DESC1
	'Consulta Saldo WIS na Onda'											, ; //X6_DSCSPA1
	'Consulta Saldo WIS na Onda'											, ; //X6_DSCENG1
	'Consulta Saldo WIS na Onda'											, ; //X6_DESC2
	'Consulta Saldo WIS na Onda'											, ; //X6_DSCSPA2
	'Consulta Saldo WIS na Onda'											, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC025'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Parametro para indicar se gravara copia do Json Au'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	' Autoware no diretorio DIRDOCS'										, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC026'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro para indicar pasta onde  gravara copia'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'do Json Autoware no diretorio DIRDOCS'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\autoware\importa\orc'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC028'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazem de Reserva Tecnica na conf receb Pecas'						, ; //X6_DESCRIC
	'Armazem de Reserva Tecnica na conf receb Pecas'						, ; //X6_DSCSPA
	'Armazem de Reserva Tecnica na conf receb Pecas'						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'02'																	, ; //X6_CONTEUD
	'02'																	, ; //X6_CONTSPA
	'02'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC031'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Endereco de conexao WIS SIGAPEC'										, ; //X6_DESCRIC
	'Endereco de conexao WIS SIGAPEC'										, ; //X6_DSCSPA
	'Endereco de conexao WIS SIGAPEC'										, ; //X6_DSCENG
	'Endereco de conexao WIS SIGAPEC'										, ; //X6_DESC1
	'Endereco de conexao WIS SIGAPEC'										, ; //X6_DSCSPA1
	'Endereco de conexao WIS SIGAPEC'										, ; //X6_DSCENG1
	'Endereco de conexao WIS SIGAPEC'										, ; //X6_DESC2
	'Endereco de conexao WIS SIGAPEC'										, ; //X6_DSCSPA2
	'Endereco de conexao WIS SIGAPEC'										, ; //X6_DSCENG2
	'WIS.V_ENDERECO_ESTOQUE@DBLINK_WISHML'									, ; //X6_CONTEUD
	'WIS.V_ENDERECO_ESTOQUE@DBLINK_WISHML'									, ; //X6_CONTSPA
	'WIS.V_ENDERECO_ESTOQUE@DBLINK_WISHML'									, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC039'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condicao de Pagamento a qual liberara sem avaliaca'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'do Limite de Credito'													, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Separar as variaveis por ; (ponto e virgula)'							, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'999'																	, ; //X6_CONTEUD
	'999'																	, ; //X6_CONTSPA
	'999'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC040'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Permitir habilitar ou nao a funcionalidade para'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'considerar pedidos integrados e nao reservados no'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'WIS'																	, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC041'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Permitir habilitar ou nao a funcionalidade para'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'para considerar a Localizacao Fisica da peca na'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'RgLog'																	, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC042'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Qtde de dias para retroceder Estatistica de Vendas'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	' ex pediodo 365 dias igual a um ano'									, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'365'																	, ; //X6_CONTEUD
	'365'																	, ; //X6_CONTSPA
	'365'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC043'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TPLink para Wis Armazenagem'											, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'WIS.RV_HIST_ARMAZENADO@DBLINK_WISPROD'									, ; //X6_CONTEUD
	'WIS.RV_HIST_ARMAZENADO@DBLINK_WISPROD'									, ; //X6_CONTSPA
	'WIS.RV_HIST_ARMAZENADO@DBLINK_WISPROD'									, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC045'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Executar faturamento automatico função ZPECF011'						, ; //X6_DESCRIC
	'Executar faturamento automatico função ZPECF011'						, ; //X6_DSCSPA
	'Executar faturamento automatico função ZPECF011'						, ; //X6_DSCENG
	'(rec Picking RGLOG)'													, ; //X6_DESC1
	'(rec Picking RGLOG)'													, ; //X6_DSCSPA1
	'(rec Picking RGLOG)'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'F'																		, ; //X6_CONTEUD
	'F'																		, ; //X6_CONTSPA
	'F'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_PEC046'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TPLink para Wis Pedido de Saida Cabeçalho'								, ; //X6_DESCRIC
	'TPLink para Wis Pedido de Saida Cabeçalho'								, ; //X6_DSCSPA
	'TPLink para Wis Pedido de Saida Cabeçalho'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'WIS.T_CAB_PEDIDO_SAIDA@DBLINK_WISHML'									, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_SAP001'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'ID da Empresa p/ integração financeira SAP'							, ; //X6_DESCRIC
	'ID da Empresa p/ integração financeira SAP'							, ; //X6_DSCSPA
	'ID da Empresa p/ integração financeira SAP'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2010'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_SAP002'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'ID da Filial p/ integração financeira SAP'								, ; //X6_DESCRIC
	'ID da Filial p/ integração financeira SAP'								, ; //X6_DSCSPA
	'ID da Filial p/ integração financeira SAP'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2005'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VE1NAT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Natureza para Nota fiscal SIGAVEI'										, ; //X6_DESCRIC
	'Natureza para Nota fiscal SIGAVEI'										, ; //X6_DSCSPA
	'Natureza para Nota fiscal SIGAVEI'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1101'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI001'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'SubConta - Geracao do Boleto'											, ; //X6_DESCRIC
	'SubConta - Geracao do Boleto'											, ; //X6_DSCSPA
	'SubConta - Geracao do Boleto'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'001'																	, ; //X6_CONTEUD
	'001'																	, ; //X6_CONTSPA
	'001'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI002'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Banco - Geracao do Boleto'												, ; //X6_DESCRIC
	'Banco - Geracao do Boleto'												, ; //X6_DSCSPA
	'Banco - Geracao do Boleto'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'237'																	, ; //X6_CONTEUD
	'237'																	, ; //X6_CONTSPA
	'237'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI003'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Agencia - Geracao do Boleto'											, ; //X6_DESCRIC
	'Agencia - Geracao do Boleto'											, ; //X6_DSCSPA
	'Agencia - Geracao do Boleto'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2372'																	, ; //X6_CONTEUD
	'2372'																	, ; //X6_CONTSPA
	'2372'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI004'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Conta - Geracao do Boleto'												, ; //X6_DESCRIC
	'Conta - Geracao do Boleto'												, ; //X6_DSCSPA
	'Conta - Geracao do Boleto'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'103476'																, ; //X6_CONTEUD
	'103476'																, ; //X6_CONTSPA
	'103476'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI005'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigos de natureza financeira considerados pela'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'rotina ZFATR005.'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1101'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI006'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Status dos pedidos de vendas considerados pela'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'rotina ZFATR005.'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'F'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI007'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Formas de pagamento consideradas pela rotina'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ZFATR005.'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'005'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI010'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Quantidade de dias para a validade do bloqueio que'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'esta sendo efetuado na funcao ZVEIF001'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3500'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI011'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Proprietario Atual para inclusao cadastro de Veicu'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'los'																	, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000373'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI012'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Loja do Proprietario Atual'											, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI013'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tes de Faturamento da HD80'											, ; //X6_DESCRIC
	'Tes de Faturamento da HD80'											, ; //X6_DSCSPA
	'Tes de Faturamento da HD80'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"745|747"'																, ; //X6_CONTEUD
	'"745|747"'																, ; //X6_CONTSPA
	'"745|747"'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI014'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo para serem informados os email´s que receber'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ao a planilha de consulta de estoque'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'marciel.perez@caoamontadora.com.br; rodrigo.mendes@caoamontadora.com.br; osvando.moura@caoamontadora.com.br; wagson.morais@caoamontadora.com.br; victor.gabriel@caoamontadora.com.br; t-lucas.carvalho@caoa.com.br; bruno.santana@caoa.com.br;', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI015'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Caminho aonde a planilha de consulta de estoque se'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ra gravada'															, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	' \Cons_Estoque\'														, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI016'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo para serem informados os email´s que receber'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ao a planilha de consulta de estoque'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'namesio.junior@caoamontadora.com.br; heuvescio.vilella@caoamontadora.com.br; leandro.oliveira@caoamontadora.com.br; paulo.santos@caoamontadora.com.br;', ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEI017'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Campo para serem informados os email´s que receber'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'ao a planilha de consulta de estoque'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEIAC1'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que possuem acesso ao VEI'									, ; //X6_DESCRIC
	'Usuarios que possuem acesso ao VEI'									, ; //X6_DSCSPA
	'Usuarios que possuem acesso ao VEI'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"000053|000062|000063|000084|000097|000109|000110|000153|000161|000165|000167|000207|000208|000211|000218|000236|000237|000251|000355|000447|000500|000510|000531|000610|000618|000656|000703|000778"', ; //X6_CONTEUD
	'"000053|000062|000063|000084|000097|000109|000110|000153|000161|000165|000167|000207|000208|000211|000218|000236|000237|000251|000355|000447|000500|000510|000531|000610|000618|000656|000703|000778"', ; //X6_CONTSPA
	'"000053|000062|000063|000084|000097|000109|000110|000153|000161|000165|000167|000207|000208|000211|000218|000236|000237|000251|000355|000447|000500|000510|000531|000610|000618|000656|000703|000778"', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_VEITS1'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informar TES imobilização do Veiculo'									, ; //X6_DESCRIC
	'Informar TES imobilização do Veiculo'									, ; //X6_DSCSPA
	'Informar TES imobilização do Veiculo'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'282|525|582|583|703|739'												, ; //X6_CONTEUD
	'282|525|582|583|703|739'												, ; //X6_CONTSPA
	'282|525|582|583|703|739'												, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS001'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazem de Origem - Rotina de Envio (RgLog)'							, ; //X6_DESCRIC
	'Armazem de Origem - Rotina de Envio (RgLog)'							, ; //X6_DSCSPA
	'Armazem de Origem - Rotina de Envio (RgLog)'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'907'																	, ; //X6_CONTEUD
	'907'																	, ; //X6_CONTSPA
	'907'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS002'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Tempo em Segundos para Refresh da tela ZWMSF001'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'(Default = 10 segundos)'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'5'																		, ; //X6_CONTEUD
	'5'																		, ; //X6_CONTSPA
	'5'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS003'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Endereco das docas de recebimento dos armazens'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'alimentados pela RG LOG'												, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'DCE_TRANSITO'															, ; //X6_CONTEUD
	'DCE_TRANSITO'															, ; //X6_CONTSPA
	'DCE_TRANSITO'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS004'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita/desabilita o processamento manual da'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'rotina ZWMSF003.'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS005'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Quantidade de threads que serao abertas pelo Job'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	' da rotina ZWMSF003'													, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS006'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Quantidade de segundos que o job devera aguardar'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'para iniciar a transferencia.'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'5000'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS007'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'URL Base integracao com o sistema de analises'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'SM'																	, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'http://172.16.33.168:56105/webitf'										, ; //X6_CONTEUD
	'http://172.16.33.168:56105/webitf'										, ; //X6_CONTSPA
	'http://172.16.33.168:56105/webitf'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS008'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'lista de e-mails notificados em caso de falha da'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'job'																	, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'separar por ";"'														, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'Julia.alcantara@caoa.montadora.com.br;valter.carvalho@caoa.com.br'		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS009'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazem de destino usado no processo de montagem'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'de unitizador de itens de importacao'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'907'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS010'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Endereco de destino usado no processo de montagem'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'de unitizador de itens de importacao'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'BRGLPATIO32'															, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS011'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilitar/desabilitar passagem de armazem e'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'endereco de destino na montagem de unitizador'							, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS012'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilitar/desabilitar schedule de montagem de'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'unitizador'															, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS013'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'data e hora da ultima consulta aos analisados no'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'endpoint do SM'														, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'01/10/2020 08:00:00'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS014'															, ; //X6_VAR
	'D'																		, ; //X6_TIPO
	'Data do ultimo envio da lista de produtos+lote com'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'data de vencimento D+3 ( produtos com vencimento i'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'minente)'																, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'01/10/2020'															, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS015'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'string de autenticacao  do endpoint SM'								, ; //X6_DESCRIC
	'system:itf2019'														, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Obs: essa senha e encodada no programa postman'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'usando o protocolo oauth'												, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'c3lzdGVtMjppdGYyMDE5'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS016'															, ; //X6_VAR
	'D'																		, ; //X6_TIPO
	'Data Base para envio da lista de produtos que venc'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'imento D+30 (produtos que vencerao em 30 dias)'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'01/11/2020'															, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS017'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilitar/desabilitar a validacao de lock de'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'registro na rotina WMSV095'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WMS018'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'IDs dos usuarios com permissao para realizar a'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'limpeza da fila do WmsCaoa'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000016/000177'															, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR001'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Url RG LOG Integração separaçao de pedidos'							, ; //X6_DESCRIC
	'Url RG LOG Integração separaçao de pedidos'							, ; //X6_DSCSPA
	'Url RG LOG Integração separaçao de pedidos'							, ; //X6_DSCENG
	'Url RG LOG Integração separaçao de pedidos'							, ; //X6_DESC1
	'Url RG LOG Integração separaçao de pedidos'							, ; //X6_DSCSPA1
	'Url RG LOG Integração separaçao de pedidos'							, ; //X6_DSCENG1
	'Url RG LOG Integração separaçao de pedidos'							, ; //X6_DESC2
	'Url RG LOG Integração separaçao de pedidos'							, ; //X6_DSCSPA2
	'Url RG LOG Integração separaçao de pedidos'							, ; //X6_DSCENG2
	'wmsapi.rgtracking.com.br:8080/interfacewis/entrada/pedido/'			, ; //X6_CONTEUD
	'wmsapi.rgtracking.com.br:8080/interfacewis/entrada/pedido/'			, ; //X6_CONTSPA
	'wmsapi.rgtracking.com.br:8080/interfacewis/entrada/pedido/'			, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR003'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro codigo vendedor importação Autoware'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000569'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR004'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro Tipo de Venda importação Autoware'							, ; //X6_DESCRIC
	'Parametro Tipo de Venda importação Autoware'							, ; //X6_DSCSPA
	'Parametro Tipo de Venda importação Autoware'							, ; //X6_DSCENG
	'Parametro Tipo de Venda importação Autoware'							, ; //X6_DESC1
	'Parametro Tipo de Venda importação Autoware'							, ; //X6_DSCSPA1
	'Parametro Tipo de Venda importação Autoware'							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR005'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro Natureza Rede Caoa'											, ; //X6_DESCRIC
	'Parametro Natureza Rede Caoa'											, ; //X6_DSCSPA
	'Parametro Natureza Rede Caoa'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1201'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR006'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro Tipo operação importação Autoware'							, ; //X6_DESCRIC
	'Parametro Tipo operação importação Autoware'							, ; //X6_DSCSPA
	'Parametro Tipo operação importação Autoware'							, ; //X6_DSCENG
	'Parametro Tipo operação importação Autoware'							, ; //X6_DESC1
	'Parametro Tipo operação importação Autoware'							, ; //X6_DSCSPA1
	'Parametro Tipo operação importação Autoware'							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'90'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR007'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'URL RgLog para Produtos'												, ; //X6_DESCRIC
	'URL RgLog para Produtos'												, ; //X6_DSCSPA
	'URL RgLog para Produtos'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'wmsapi.rgtracking.com.br:8080/interfacewis/entrada/produto/'			, ; //X6_CONTEUD
	'wmsapi.rgtracking.com.br:8080/interfacewis/entrada/produto/'			, ; //X6_CONTSPA
	'wmsapi.rgtracking.com.br:8080/interfacewis/entrada/produto/'			, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR008'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Path da URL de Fornecedores'											, ; //X6_DESCRIC
	'Path da URL de Fornecedores'											, ; //X6_DSCSPA
	'Path da URL de Fornecedores'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'interfacewis/entrada/fornecedor'										, ; //X6_CONTEUD
	'interfacewis/entrada/fornecedor'										, ; //X6_CONTSPA
	'interfacewis/entrada/fornecedor'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR009'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuario para acesso a URL da RgLog'									, ; //X6_DESCRIC
	'Usuario para acesso a URL da RgLog'									, ; //X6_DSCSPA
	'Usuario para acesso a URL da RgLog'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'caoa.totvs'															, ; //X6_CONTEUD
	'caoa.totvs'															, ; //X6_CONTSPA
	'caoa.totvs'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR010'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Senha encodada no Postman com o tipo Basic'							, ; //X6_DESCRIC
	'Senha encodada no Postman com o tipo Basic'							, ; //X6_DSCSPA
	'Senha encodada no Postman com o tipo Basic'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'CAgka2694X*'															, ; //X6_CONTEUD
	'CAgka2694X*'															, ; //X6_CONTSPA
	'CAgka2694X*'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR011'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'URL RgLog para Clientes/Fornecedores'									, ; //X6_DESCRIC
	'URL RgLog para Clientes/Fornecedores'									, ; //X6_DSCSPA
	'URL RgLog para Clientes/Fornecedores'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'wmsapi.rgtracking.com.br:8080/'										, ; //X6_CONTEUD
	'wmsapi.rgtracking.com.br:8080/'										, ; //X6_CONTSPA
	'wmsapi.rgtracking.com.br:8080/'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR012'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Path da URL de Clientes'												, ; //X6_DESCRIC
	'Path da URL de Clientes'												, ; //X6_DSCSPA
	'Path da URL de Clientes'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'interfacewis/entrada/cliente'											, ; //X6_CONTEUD
	'interfacewis/entrada/cliente'											, ; //X6_CONTSPA
	'interfacewis/entrada/cliente'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR013'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'endereco de e-mail que segue o erro da integrcao'						, ; //X6_DESCRIC
	'endereco de e-mail que segue o erro da integrcao'						, ; //X6_DSCSPA
	'endereco de e-mail que segue o erro da integrcao'						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'jose.dearaujo@totvspartners.com.br'									, ; //X6_CONTEUD
	'jose.dearaujo@totvspartners.com.br'									, ; //X6_CONTSPA
	'jose.dearaujo@totvspartners.com.br'									, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR015'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuário Importação RG LOG'												, ; //X6_DESCRIC
	'Usuário Importação RG LOG'												, ; //X6_DSCSPA
	'Usuário Importação RG LOG'												, ; //X6_DSCENG
	'Usuário Importação RG LOG'												, ; //X6_DESC1
	'Usuário Importação RG LOG'												, ; //X6_DSCSPA1
	'Usuário Importação RG LOG'												, ; //X6_DSCENG1
	'Usuário Importação RG LOG'												, ; //X6_DESC2
	'Usuário Importação RG LOG'												, ; //X6_DSCSPA2
	'Usuário Importação RG LOG'												, ; //X6_DSCENG2
	'RG LOG'																, ; //X6_CONTEUD
	'interfacewis/entrada/pedido'											, ; //X6_CONTSPA
	'interfacewis/entrada/pedido'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR016'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuario para acesso a URL da RgLog Doc Ent'							, ; //X6_DESCRIC
	'Usuario para acesso a URL da RgLog Doc Ent'							, ; //X6_DSCSPA
	'Usuario para acesso a URL da RgLog Doc Ent'							, ; //X6_DSCENG
	'Usuario para acesso a URL da RgLog Doc Ent'							, ; //X6_DESC1
	'Usuario para acesso a URL da RgLog Doc Ent'							, ; //X6_DSCSPA1
	'Usuario para acesso a URL da RgLog Doc Ent'							, ; //X6_DSCENG1
	'Usuario para acesso a URL da RgLog Doc Ent'							, ; //X6_DESC2
	'Usuario para acesso a URL da RgLog Doc Ent'							, ; //X6_DSCSPA2
	'Usuario para acesso a URL da RgLog Doc Ent'							, ; //X6_DSCENG2
	'caoa.totvs'															, ; //X6_CONTEUD
	'caoa.totvs'															, ; //X6_CONTSPA
	'caoa.totvs'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR017'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Senha encodada no Postman com o tipo Basic Doc Ent'					, ; //X6_DESCRIC
	'Senha encodada no Postman com o tipo Basic Doc Ent'					, ; //X6_DSCSPA
	'Senha encodada no Postman com o tipo Basic Doc Ent'					, ; //X6_DSCENG
	'Senha encodada no Postman com o tipo Basic Doc Ent'					, ; //X6_DESC1
	'Senha encodada no Postman com o tipo Basic Doc Ent'					, ; //X6_DSCSPA1
	'Senha encodada no Postman com o tipo Basic Doc Ent'					, ; //X6_DSCENG1
	'Senha encodada no Postman com o tipo Basic Doc Ent'					, ; //X6_DESC2
	'Senha encodada no Postman com o tipo Basic Doc Ent'					, ; //X6_DSCSPA2
	'Senha encodada no Postman com o tipo Basic Doc Ent'					, ; //X6_DSCENG2
	'CAgka2694X*'															, ; //X6_CONTEUD
	'CAgka2694X*'															, ; //X6_CONTSPA
	'CAgka2694X*'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR018'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Path Url RG LOG Integração de NF de Entrada'							, ; //X6_DESCRIC
	'Path Url RG LOG Integração de NF de Entrada'							, ; //X6_DSCSPA
	'Path Url RG LOG Integração de NF de Entrada'							, ; //X6_DSCENG
	'Path Url RG LOG Integração de NF de Entrada'							, ; //X6_DESC1
	'Path Url RG LOG Integração de NF de Entrada'							, ; //X6_DSCSPA1
	'Path Url RG LOG Integração de NF de Entrada'							, ; //X6_DSCENG1
	'Path Url RG LOG Integração de NF de Entrada'							, ; //X6_DESC2
	'Path Url RG LOG Integração de NF de Entrada'							, ; //X6_DSCSPA2
	'Path Url RG LOG Integração de NF de Entrada'							, ; //X6_DSCENG2
	'interfacewis/entrada/recebimento'										, ; //X6_CONTEUD
	'interfacewis/entrada/recebimento'										, ; //X6_CONTSPA
	'interfacewis/entrada/recebimento'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR019'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Raiz do CNPJ Caoa'														, ; //X6_DESCRIC
	'Raiz do CNPJ Caoa'														, ; //X6_DSCSPA
	'Raiz do CNPJ Caoa'														, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'03471344'																, ; //X6_CONTEUD
	'03471344'																, ; //X6_CONTSPA
	'03471344'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR020'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Transf Mesmo Grupo - Tp Oper'											, ; //X6_DESCRIC
	'Transf Mesmo Grupo - Tp Oper'											, ; //X6_DSCSPA
	'Transf Mesmo Grupo - Tp Oper'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'81'																	, ; //X6_CONTEUD
	'81'																	, ; //X6_CONTSPA
	'81'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR021'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Zona Franca - Venda'													, ; //X6_DESCRIC
	'Zona Franca - Venda'													, ; //X6_DSCSPA
	'Zona Franca - Venda'													, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'ZF|93;ZD|92'															, ; //X6_CONTEUD
	'ZF|93;ZD|92'															, ; //X6_CONTSPA
	'ZF|93;ZD|92'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR022'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Baixa Scrap - Tp Oper.'												, ; //X6_DESCRIC
	'Baixa Scrap - Tp Oper.'												, ; //X6_DSCSPA
	'Baixa Scrap - Tp Oper.'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'59'																	, ; //X6_CONTEUD
	'59'																	, ; //X6_CONTSPA
	'59'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR023'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Venda Geral - Tp Oper.'												, ; //X6_DESCRIC
	'Venda Geral - Tp Oper.'												, ; //X6_DSCSPA
	'Venda Geral - Tp Oper.'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'90'																	, ; //X6_CONTEUD
	'90'																	, ; //X6_CONTSPA
	'90'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR024'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Zona Franca - Remessa'													, ; //X6_DESCRIC
	'Zona Franca - Remessa'													, ; //X6_DSCSPA
	'Zona Franca - Remessa'													, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'ZF|77;ZD|78'															, ; //X6_CONTEUD
	'ZF|77;ZD|78'															, ; //X6_CONTSPA
	'ZF|77;ZD|78'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR025'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Remessa Geral - Tp Oper.'												, ; //X6_DESCRIC
	'Remessa Geral - Tp Oper.'												, ; //X6_DSCSPA
	'Remessa Geral - Tp Oper.'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'77'																	, ; //X6_CONTEUD
	'77'																	, ; //X6_CONTSPA
	'77'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR026'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Transferencial Geral - Tp Oper.'										, ; //X6_DESCRIC
	'Transferencial Geral - Tp Oper.'										, ; //X6_DSCSPA
	'Transferencial Geral - Tp Oper.'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'81'																	, ; //X6_CONTEUD
	'81'																	, ; //X6_CONTSPA
	'81'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR027'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Cod Baixa Interna - Scrap'												, ; //X6_DESCRIC
	'Cod Baixa Interna - Scrap'												, ; //X6_DSCSPA
	'Cod Baixa Interna - Scrap'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'013'																	, ; //X6_CONTEUD
	'013'																	, ; //X6_CONTSPA
	'013'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR028'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro Natureza Receita Floor Plan'									, ; //X6_DESCRIC
	'Paramentro Natureza Receita Floor Plan'								, ; //X6_DSCSPA
	'Paramentro Natureza Receita Floor Plan'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1203'																	, ; //X6_CONTEUD
	'1202'																	, ; //X6_CONTSPA
	'1202'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR029'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Pedido | % De Desconto'										, ; //X6_DESCRIC
	'Tipo de Pedido | % De Desconto'										, ; //X6_DSCSPA
	'Tipo de Pedido | % De Desconto'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'005|5;017|2.5'															, ; //X6_CONTEUD
	'005|5;017|2.5'															, ; //X6_CONTSPA
	'005|5;017|2.5'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR030'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Marca que permite Desconto Orçamento'									, ; //X6_DESCRIC
	'Marca que permite Desconto Orçamento'									, ; //X6_DSCSPA
	'Marca que permite Desconto Orçamento'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'CHE|'																	, ; //X6_CONTEUD
	'CHE|'																	, ; //X6_CONTSPA
	'CHE|'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR031'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Pedido | % De Acrescimo'										, ; //X6_DESCRIC
	'Tipo de Pedido | % De Acrescimo'										, ; //X6_DSCSPA
	'Tipo de Pedido | % De Acrescimo'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'003|5;'																, ; //X6_CONTEUD
	'003|5;'																, ; //X6_CONTSPA
	'003|5;'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR032'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Marca que permite Acrescimo Orçamento'									, ; //X6_DESCRIC
	'Marca que permite Acrescimo Orçamento'									, ; //X6_DSCSPA
	'Marca que permite Acrescimo Orçamento'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'CHE|'																	, ; //X6_CONTEUD
	'CHE|'																	, ; //X6_CONTSPA
	'CHE|'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR033'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Informar os Estados que pertencem a ZF'								, ; //X6_DESCRIC
	'Informar os Estados que pertencem a ZF'								, ; //X6_DSCSPA
	'Informar os Estados que pertencem a ZF'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'AC|AM|AP|RO|RR'														, ; //X6_CONTEUD
	'AC|AM|AP|RO|RR'														, ; //X6_CONTSPA
	'AC|AM|AP|RO|RR'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR034'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Envia Doc. de Entrada para RgLog ?'									, ; //X6_DESCRIC
	'Envia Doc. de Entrada para RgLog ?'									, ; //X6_DSCSPA
	'Envia Doc. de Entrada para RgLog ?'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	'S'																		, ; //X6_CONTSPA
	'S'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR035'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro Rede Atacado'												, ; //X6_DESCRIC
	'Parametro Rede Atacado'												, ; //X6_DSCSPA
	'Parametro Rede Atacado'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1202'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR036'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Centro de Custo Hyundai'												, ; //X6_DESCRIC
	'Centro de Custo Hyundai'												, ; //X6_DSCSPA
	'Centro de Custo Hyundai'												, ; //X6_DSCENG
	'Centro de Custo Hyundai'												, ; //X6_DESC1
	'Centro de Custo Hyundai'												, ; //X6_DSCSPA1
	'Centro de Custo Hyundai'												, ; //X6_DSCENG1
	'Centro de Custo Hyundai'												, ; //X6_DESC2
	'Centro de Custo Hyundai'												, ; //X6_DSCSPA2
	'Centro de Custo Hyundai'												, ; //X6_DSCENG2
	'53020509MA'															, ; //X6_CONTEUD
	'53020509MA'															, ; //X6_CONTSPA
	'53020509MA'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR037'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Centro de Custo Chery'													, ; //X6_DESCRIC
	'Centro de Custo Chery'													, ; //X6_DSCSPA
	'Centro de Custo Chery'													, ; //X6_DSCENG
	'Centro de Custo Chery'													, ; //X6_DESC1
	'Centro de Custo Chery'													, ; //X6_DSCSPA1
	'Centro de Custo Chery'													, ; //X6_DSCENG1
	'Centro de Custo Chery'													, ; //X6_DESC2
	'Centro de Custo Chery'													, ; //X6_DSCSPA2
	'Centro de Custo Chery'													, ; //X6_DSCENG2
	'53290509MA'															, ; //X6_CONTEUD
	'53290509MA'															, ; //X6_CONTSPA
	'53290509MA'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR038'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Centro de Custo Subaru'												, ; //X6_DESCRIC
	'Centro de Custo Subaru'												, ; //X6_DSCSPA
	'Centro de Custo Subaru'												, ; //X6_DSCENG
	'Centro de Custo Subaru'												, ; //X6_DESC1
	'Centro de Custo Subaru'												, ; //X6_DSCSPA1
	'Centro de Custo Subaru'												, ; //X6_DSCENG1
	'Centro de Custo Subaru'												, ; //X6_DESC2
	'Centro de Custo Subaru'												, ; //X6_DSCSPA2
	'Centro de Custo Subaru'												, ; //X6_DSCENG2
	'53110509MA'															, ; //X6_CONTEUD
	'53110509MA'															, ; //X6_CONTSPA
	'53110509MA'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR039'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tp.Pedido Baixa Interna Uso/Consumo'									, ; //X6_DESCRIC
	'Tp.Pedido Baixa Interna Uso/Consumo'									, ; //X6_DSCSPA
	'Tp.Pedido Baixa Interna Uso/Consumo'									, ; //X6_DSCENG
	'Tp.Pedido Baixa Interna Uso/Consumo'									, ; //X6_DESC1
	'Tp.Pedido Baixa Interna Uso/Consumo'									, ; //X6_DSCSPA1
	'Tp.Pedido Baixa Interna Uso/Consumo'									, ; //X6_DSCENG1
	'Tp.Pedido Baixa Interna Uso/Consumo'									, ; //X6_DESC2
	'Tp.Pedido Baixa Interna Uso/Consumo'									, ; //X6_DSCSPA2
	'Tp.Pedido Baixa Interna Uso/Consumo'									, ; //X6_DSCENG2
	'011'																	, ; //X6_CONTEUD
	'011'																	, ; //X6_CONTSPA
	'011'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR040'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tp.Pedido Transf.Uso/Consumo'											, ; //X6_DESCRIC
	'Tp.Pedido Transf.Uso/Consumo'											, ; //X6_DSCSPA
	'Tp.Pedido Transf.Uso/Consumo'											, ; //X6_DSCENG
	'Tp.Pedido Transf.Uso/Consumo'											, ; //X6_DESC1
	'Tp.Pedido Transf.Uso/Consumo'											, ; //X6_DSCSPA1
	'Tp.Pedido Transf.Uso/Consumo'											, ; //X6_DSCENG1
	'Tp.Pedido Transf.Uso/Consumo'											, ; //X6_DESC2
	'Tp.Pedido Transf.Uso/Consumo'											, ; //X6_DSCSPA2
	'Tp.Pedido Transf.Uso/Consumo'											, ; //X6_DSCENG2
	'014'																	, ; //X6_CONTEUD
	'014'																	, ; //X6_CONTSPA
	'014'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR041'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tp.Operacao Venda Uso/Consumo'											, ; //X6_DESCRIC
	'Tp.Operacao Venda Uso/Consumo'											, ; //X6_DSCSPA
	'Tp.Operacao Venda Uso/Consumo'											, ; //X6_DSCENG
	'Tp.Operacao Venda Uso/Consumo'											, ; //X6_DESC1
	'Tp.Operacao Venda Uso/Consumo'											, ; //X6_DSCSPA1
	'Tp.Operacao Venda Uso/Consumo'											, ; //X6_DSCENG1
	'Tp.Operacao Venda Uso/Consumo'											, ; //X6_DESC2
	'Tp.Operacao Venda Uso/Consumo'											, ; //X6_DSCSPA2
	'Tp.Operacao Venda Uso/Consumo'											, ; //X6_DSCENG2
	'90'																	, ; //X6_CONTEUD
	'90'																	, ; //X6_CONTSPA
	'90'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR042'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tp.Operacao Venda Uso/Consumo ZFM'										, ; //X6_DESCRIC
	'Tp.Operacao Venda Uso/Consumo ZFM'										, ; //X6_DSCSPA
	'Tp.Operacao Venda Uso/Consumo ZFM'										, ; //X6_DSCENG
	'Tp.Operacao Venda Uso/Consumo ZFM'										, ; //X6_DESC1
	'Tp.Operacao Venda Uso/Consumo ZFM'										, ; //X6_DSCSPA1
	'Tp.Operacao Venda Uso/Consumo ZFM'										, ; //X6_DSCENG1
	'Tp.Operacao Venda Uso/Consumo ZFM'										, ; //X6_DESC2
	'Tp.Operacao Venda Uso/Consumo ZFM'										, ; //X6_DSCSPA2
	'Tp.Operacao Venda Uso/Consumo ZFM'										, ; //X6_DSCENG2
	'ZF|93;ZD|92'															, ; //X6_CONTEUD
	'ZF|93;ZD|92'															, ; //X6_CONTSPA
	'ZF|93;ZD|92'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR043'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tp.Oper.Baixa Interna Uso Consumo'										, ; //X6_DESCRIC
	'Tp.Oper.Baixa Interna Uso Consumo'										, ; //X6_DSCSPA
	'Tp.Oper.Baixa Interna Uso Consumo'										, ; //X6_DSCENG
	'Tp.Oper.Baixa Interna Uso Consumo'										, ; //X6_DESC1
	'Tp.Oper.Baixa Interna Uso Consumo'										, ; //X6_DSCSPA1
	'Tp.Oper.Baixa Interna Uso Consumo'										, ; //X6_DSCENG1
	'Tp.Oper.Baixa Interna Uso Consumo'										, ; //X6_DESC2
	'Tp.Oper.Baixa Interna Uso Consumo'										, ; //X6_DSCSPA2
	'Tp.Oper.Baixa Interna Uso Consumo'										, ; //X6_DSCENG2
	'75'																	, ; //X6_CONTEUD
	'75'																	, ; //X6_CONTSPA
	'75'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR044'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tp.Operacao Transf.Uso/Consumo'										, ; //X6_DESCRIC
	'Tp.Operacao Transf.Uso/Consumo'										, ; //X6_DSCSPA
	'Tp.Operacao Transf.Uso/Consumo'										, ; //X6_DSCENG
	'Tp.Operacao Transf.Uso/Consumo'										, ; //X6_DESC1
	'Tp.Operacao Transf.Uso/Consumo'										, ; //X6_DSCSPA1
	'Tp.Operacao Transf.Uso/Consumo'										, ; //X6_DSCENG1
	'Tp.Operacao Transf.Uso/Consumo'										, ; //X6_DESC2
	'Tp.Operacao Transf.Uso/Consumo'										, ; //X6_DSCSPA2
	'Tp.Operacao Transf.Uso/Consumo'										, ; //X6_DSCENG2
	'98'																	, ; //X6_CONTEUD
	'98'																	, ; //X6_CONTSPA
	'98'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR045'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Dblink WIS'															, ; //X6_DESCRIC
	'Dblink WIS'															, ; //X6_DSCSPA
	'Dblink WIS'															, ; //X6_DSCENG
	'Dblink WIS'															, ; //X6_DESC1
	'Dblink WIS'															, ; //X6_DSCSPA1
	'Dblink WIS'															, ; //X6_DSCENG1
	'Dblink WIS'															, ; //X6_DESC2
	'Dblink WIS'															, ; //X6_DSCSPA2
	'Dblink WIS'															, ; //X6_DSCENG2
	'DBLINK_WISPROD'														, ; //X6_CONTEUD
	'DBLINK_WISPROD'														, ; //X6_CONTSPA
	'DBLINK_WISPROD'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR046'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tp.Pedido Remessa Armazenagem'											, ; //X6_DESCRIC
	'Tp.Pedido Remessa Armazenagem'											, ; //X6_DSCSPA
	'Tp.Pedido Remessa Armazenagem'											, ; //X6_DSCENG
	'Tp.Pedido Remessa Armazenagem'											, ; //X6_DESC1
	'Tp.Pedido Remessa Armazenagem'											, ; //X6_DSCSPA1
	'Tp.Pedido Remessa Armazenagem'											, ; //X6_DSCENG1
	'Tp.Pedido Remessa Armazenagem'											, ; //X6_DESC2
	'Tp.Pedido Remessa Armazenagem'											, ; //X6_DSCSPA2
	'Tp.Pedido Remessa Armazenagem'											, ; //X6_DSCENG2
	'015'																	, ; //X6_CONTEUD
	'015'																	, ; //X6_CONTSPA
	'015'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR047'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tp.Pedido Mudanca Endereco FDR'										, ; //X6_DESCRIC
	'Tp.Pedido Mudanca Endereco FDR'										, ; //X6_DSCSPA
	'Tp.Pedido Mudanca Endereco FDR'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'016'																	, ; //X6_CONTEUD
	'016'																	, ; //X6_CONTSPA
	'016'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR048'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tp.Operacao Remessa Armazenagem'										, ; //X6_DESCRIC
	'Tp.Operacao Remessa Armazenagem'										, ; //X6_DSCSPA
	'Tp.Operacao Remessa Armazenagem'										, ; //X6_DSCENG
	'Tp.Operacao Remessa Armazenagem'										, ; //X6_DESC1
	'Tp.Operacao Remessa Armazenagem'										, ; //X6_DSCSPA1
	'Tp.Operacao Remessa Armazenagem'										, ; //X6_DSCENG1
	'Tp.Operacao Remessa Armazenagem'										, ; //X6_DESC2
	'Tp.Operacao Remessa Armazenagem'										, ; //X6_DSCSPA2
	'Tp.Operacao Remessa Armazenagem'										, ; //X6_DSCENG2
	'52'																	, ; //X6_CONTEUD
	'52'																	, ; //X6_CONTSPA
	'52'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR049'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tp.Operacao Mudanca FDR'												, ; //X6_DESCRIC
	'Tp.Operacao Mudanca FDR'												, ; //X6_DSCSPA
	'Tp.Operacao Mudanca FDR'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'79'																	, ; //X6_CONTEUD
	'79'																	, ; //X6_CONTSPA
	'79'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_WSR050'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipos de Pedido que Tag "Observacao" sao gravados'						, ; //X6_DESCRIC
	'Tipos de Pedido que Tag "Observacao" sao gravados'						, ; //X6_DSCSPA
	'Tipos de Pedido que Tag "Observacao" sao gravados'						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'016;007'																, ; //X6_CONTEUD
	'016;007'																, ; //X6_CONTSPA
	'016;007'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'CMV_XMLTRG'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Diretorio para importacao de xml triangulacao'							, ; //X6_DESCRIC
	'Diretorio para importacao de xml triangulacao'							, ; //X6_DSCSPA
	'Diretorio para importacao de xml triangulacao'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'EDI\XMLTRIANG\'														, ; //X6_CONTEUD
	'EDI\XMLTRIANG\'														, ; //X6_CONTSPA
	'EDI\XMLTRIANG\'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'EP_BUILDVR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'EngPro Internarl Usage'												, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'721f5cea061356a2f605567564d9667c'										, ; //X6_CONTEUD
	'721f5cea061356a2f605567564d9667c'										, ; //X6_CONTSPA
	'721f5cea061356a2f605567564d9667c'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_PAREND'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'ENDERECO DE DOCA'														, ; //X6_DESCRIC
	'ENDERECO DE DOCA'														, ; //X6_DSCSPA
	'ENDERECO DE DOCA'														, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'DE001'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_XFLUIG1'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuario FLUIG'															, ; //X6_DESCRIC
	'Usuario FLUIG'															, ; //X6_DSCSPA
	'Usuario FLUIG'															, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'admin'																	, ; //X6_CONTEUD
	'admin'																	, ; //X6_CONTSPA
	'admin'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_XFLUIG2'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Senha FLUIG'															, ; //X6_DESCRIC
	'Senha FLUIG'															, ; //X6_DSCSPA
	'Senha FLUIG'															, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'Caoat99#ch'															, ; //X6_CONTEUD
	'Caoat99#ch'															, ; //X6_CONTSPA
	'Caoat99#ch'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_XFLUIG3'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'ID do usuario FLUIG'													, ; //X6_DESCRIC
	'ID do usuario FLUIG'													, ; //X6_DSCSPA
	'ID do usuario FLUIG'													, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'admin'																	, ; //X6_CONTEUD
	'admin'																	, ; //X6_CONTSPA
	'admin'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_XFLUIG4'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Empresa FLUIG'															, ; //X6_DESCRIC
	'Empresa FLUIG'															, ; //X6_DSCSPA
	'Empresa FLUIG'															, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
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
	'ES_XFLUIG5'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'URL FLUIG'																, ; //X6_DESCRIC
	'URL FLUIG'																, ; //X6_DSCSPA
	'URL FLUIG'																, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'https://caoatst.fluig.cloudtotvs.com.br/webdesk/ECMWorkflowEngineService?wsdl', ; //X6_CONTEUD
	'https://caoatst.fluig.cloudtotvs.com.br/webdesk/ECMWorkflowEngineService?wsdl', ; //X6_CONTSPA
	'https://caoatst.fluig.cloudtotvs.com.br/webdesk/ECMWorkflowEngineService?wsdl', ; //X6_CONTENG
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

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_A330SB2'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'.F. - O MATA330 utiliza a tabela SB2 para o'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'processamento ou .T. utiliza a tabela TR2 para o'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'processamento e, ao termino, grava na SB2.'							, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_ATUFORN'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Parametro atualizacao do Fornecedor no Doc. de Ent'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'rada quando gerar financeiro.'											, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_CENT10'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DESCRIC
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCSPA
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCENG
	'Valores na moeda 10'													, ; //X6_DESC1
	'Valores na moeda 10'													, ; //X6_DSCSPA1
	'Valores na moeda 10'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_CENT11'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DESCRIC
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCSPA
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCENG
	'Valores na moeda 11'													, ; //X6_DESC1
	'Valores na moeda 11'													, ; //X6_DSCSPA1
	'Valores na moeda 11'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_CENT12'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DESCRIC
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCSPA
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCENG
	'Valores na moeda 12'													, ; //X6_DESC1
	'Valores na moeda 12'													, ; //X6_DSCSPA1
	'Valores na moeda 12'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_CENT6'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DESCRIC
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCSPA
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCENG
	'Valores na moeda 6'													, ; //X6_DESC1
	'Valores na moeda 6'													, ; //X6_DSCSPA1
	'Valores na moeda 6'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_CENT7'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DESCRIC
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCSPA
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCENG
	'Valores na moeda 7'													, ; //X6_DESC1
	'Valores na moeda 7'													, ; //X6_DSCSPA1
	'Valores na moeda 7'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_CENT8'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DESCRIC
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCSPA
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCENG
	'Valores na moeda 8'													, ; //X6_DESC1
	'Valores na moeda 8'													, ; //X6_DSCSPA1
	'Valores na moeda 8'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_CENT9'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DESCRIC
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCSPA
	'Numero de casas decimais utilizadas para impressao'					, ; //X6_DSCENG
	'Valores na moeda 9'													, ; //X6_DESC1
	'Valores na moeda 9'													, ; //X6_DSCSPA1
	'Valores na moeda 9'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_EANCALC'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Define se o digito verifcador do codigo de barras'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'sera calculado. .T. = Sim; .F. = Nao'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'F'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_FMLPECA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo Formula Pecas'													, ; //X6_DESCRIC
	'Codigo Formula Pecas'													, ; //X6_DSCSPA
	'Codigo Formula Pecas'													, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000002'																, ; //X6_CONTEUD
	'000002'																, ; //X6_CONTSPA
	'000002'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_FMLTRAN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo Formula Transferencia'											, ; //X6_DESCRIC
	'Codigo Formula Transferencia'											, ; //X6_DSCSPA
	'Codigo Formula Transferencia'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000005'																, ; //X6_CONTEUD
	'000005'																, ; //X6_CONTSPA
	'000005'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_FOMENGO'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Indica se o contribuinte esta, ou nao, enquadrado'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'como beneficiario do programa Produzir'								, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_GFELPR'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Habilita a geracao de Log antes da integracao com'						, ; //X6_DESCRIC
	'Habilita a geracao de Log antes da integracao com'						, ; //X6_DSCSPA
	'Habilita a geracao de Log antes da integracao com'						, ; //X6_DSCENG
	'o ERP Protheus?'														, ; //X6_DESC1
	'o ERP Protheus?'														, ; //X6_DSCSPA1
	'o ERP Protheus?'														, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MIL0099'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Permite informar TES em movimentacoes de veiculos?'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Se aplica nas rotinas VEIXA002/VEIXA004/VEIXA006/'						, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'VEIXA007/VEIXA012/VEIXA016/VEIXA017.Ex:S=Sim;N=Nao'					, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	'S'																		, ; //X6_CONTSPA
	'S'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MIL0152'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Tamanho do Chassi Reduzido'											, ; //X6_DESCRIC
	'Tamaño del chasis reducido'											, ; //X6_DSCSPA
	'Size of Reduced Chassis'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'8'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MOEDA10'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Titulo da Moeda 10'													, ; //X6_DESCRIC
	'Titulo da Moeda 10'													, ; //X6_DSCSPA
	'Titulo da Moeda 10'													, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'COROA DINAMARQUESA-DKK'												, ; //X6_CONTEUD
	'WON-KRW'																, ; //X6_CONTSPA
	'WON-KRW'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MOEDA11'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Titulo da Moeda 11'													, ; //X6_DESCRIC
	'Titulo da Moeda 11'													, ; //X6_DSCSPA
	'Titulo da Moeda 11'													, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'WON-KRW'																, ; //X6_CONTEUD
	'COROA SUECA-SEK'														, ; //X6_CONTSPA
	'COROA SUECA-SEK'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MOEDA12'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Titulo da Moeda 12'													, ; //X6_DESCRIC
	'Titulo da Moeda 12'													, ; //X6_DSCSPA
	'Titulo da Moeda 12'													, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'COROA SUECA-SEK'														, ; //X6_CONTEUD
	'YUAN CHINÊS'															, ; //X6_CONTSPA
	'YUAN CHINÊS'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MOEDA6'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Titulo da Moeda 6'														, ; //X6_DESCRIC
	'Titulo da Moeda 6'														, ; //X6_DSCSPA
	'Titulo da Moeda 6'														, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'DOLAR CANADENCE-CAD'													, ; //X6_CONTEUD
	'DOLAR CANADENCE-CAD'													, ; //X6_CONTSPA
	'DOLAR CANADENCE-CAD'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MOEDA7'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Titulo da Moeda 7'														, ; //X6_DESCRIC
	'Titulo da Moeda 7'														, ; //X6_DSCSPA
	'Titulo da Moeda 7'														, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'YUAN CHINES'															, ; //X6_CONTEUD
	'EURO-EUR'																, ; //X6_CONTSPA
	'EURO-EUR'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MOEDA8'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Titulo da Moeda 8'														, ; //X6_DESCRIC
	'Titulo da Moeda 8'														, ; //X6_DSCSPA
	'Titulo da Moeda 8'														, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'LIBRA-GBP ESTERLINA'													, ; //X6_CONTEUD
	'LIBRA-GBP ESTERLINA'													, ; //X6_CONTSPA
	'LIBRA-GBP ESTERLINA'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MOEDA9'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Titulo da Moeda 9'														, ; //X6_DESCRIC
	'Titulo da Moeda 9'														, ; //X6_DSCSPA
	'Titulo da Moeda 9'														, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'FRANCO SUICO-CHF'														, ; //X6_CONTEUD
	'FRANCO SUICO-CHF'														, ; //X6_CONTSPA
	'FRANCO SUICO-CHF'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_QINOBFM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Quando o instrumento não for obrigatório'								, ; //X6_DESCRIC
	'Cuando el instrumento no sea obligatorio'								, ; //X6_DSCSPA
	'When instrument if not required'										, ; //X6_DSCENG
	'e o ensaio possuir famílias vinculadas'								, ; //X6_DESC1
	'y el ensayo tenga grupos vinculados'									, ; //X6_DSCSPA1
	'and rehearse has families linked'										, ; //X6_DSCENG1
	'1=Valida Instr;2=Não Val;3=Valida no Laudo do Labo'					, ; //X6_DESC2
	'1=Valida Instr;2=No Val;3=Valida en Laudo de Labor'					, ; //X6_DSCSPA2
	'1=Validat Instr;2=Not Val;3=Validat in Lab Report'						, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELSERV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Nome do Servidor de Envio de E-mail utilizado nos'						, ; //X6_DESCRIC
	'Nombre de Servidor de Envio de E-mail utilizado en'					, ; //X6_DSCSPA
	'E-mail Sending Server Name used in'									, ; //X6_DSCENG
	'relatorios'															, ; //X6_DESC1
	'los informes.'															, ; //X6_DSCSPA1
	'reports.'																, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'smtp.caoa.com.br:587'													, ; //X6_CONTEUD
	'smtp.caoa.com.br:587'													, ; //X6_CONTSPA
	'smtp.caoa.com.br:587'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_SIMB10'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Simbolo utilizado pela moeda 10 no sistema'							, ; //X6_DESCRIC
	'Simbolo utilizado pela moeda 10 no sistema'							, ; //X6_DSCSPA
	'Simbolo utilizado pela moeda 10 no sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'DKK'																	, ; //X6_CONTEUD
	'DKK'																	, ; //X6_CONTSPA
	'DKK'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_SIMB11'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Simbolo utilizazdo na moeda 11 do sistema'								, ; //X6_DESCRIC
	'Simbolo utilizazdo na moeda 11 do sistema'								, ; //X6_DSCSPA
	'Simbolo utilizazdo na moeda 11 do sistema'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'KRW'																	, ; //X6_CONTEUD
	'SEK'																	, ; //X6_CONTSPA
	'SEK'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_SIMB12'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Simbolo utilizado pela moeda 12 no sistema'							, ; //X6_DESCRIC
	'Simbolo utilizado pela moeda 12 no sistema'							, ; //X6_DSCSPA
	'Simbolo utilizado pela moeda 12 no sistema'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SEK'																	, ; //X6_CONTEUD
	'YUAN'																	, ; //X6_CONTSPA
	'YUAN'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_SIMB6'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Simbolo utilizado pela moeda 6 no sistema'								, ; //X6_DESCRIC
	'Simbolo utilizado pela moeda 6 no sistema'								, ; //X6_DSCSPA
	'Simbolo utilizado pela moeda 6 no sistema'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'CAD'																	, ; //X6_CONTEUD
	'DKK'																	, ; //X6_CONTSPA
	'DKK'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_SIMB7'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Simbolo utilizado pela moeda 7 no sistema'								, ; //X6_DESCRIC
	'Simbolo utilizado pela moeda 7 no sistema'								, ; //X6_DSCSPA
	'Simbolo utilizado pela moeda 7 no sistema'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'CNY'																	, ; //X6_CONTEUD
	'EUR'																	, ; //X6_CONTSPA
	'EUR'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_SIMB8'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Simbolo utilizado pela moeda 8 no sistema'								, ; //X6_DESCRIC
	'Simbolo utilizado pela moeda 8 no sistema'								, ; //X6_DSCSPA
	'Simbolo utilizado pela moeda 8 no sistema'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'GBP'																	, ; //X6_CONTEUD
	'GBP'																	, ; //X6_CONTSPA
	'GBP'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_SIMB9'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Simbolo utilizado pela moeda 9 no sistema'								, ; //X6_DESCRIC
	'Simbolo utilizado pela moeda 9 no sistema'								, ; //X6_DSCSPA
	'Simbolo utilizado pela moeda 9 no sistema'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'CHF'																	, ; //X6_CONTEUD
	'JPY'																	, ; //X6_CONTSPA
	'JPY'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_SUBTRI2'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Numero de Inscricao Estadual do contribuiente em'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'outro estado quando houver substituicao tributaria'					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RS9000017667/SC257806989'												, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_TPAGCOM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Mensagem para o tipo de pagamento 99 - Compras'						, ; //X6_DESCRIC
	'Mensaje para el tipo de pago 99 - Compras'								, ; //X6_DSCSPA
	'Message for payment type 99 - Purchases'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"Negociacao Futura"'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_UFSTISE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	''																		, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SP!BA'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XCODTES'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tes usada na integracao apontamento sigavei'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'001'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XFORPAG'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condicao pagamento usada na integracao apontamento'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'sigavei'																, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'001'																	, ; //X6_CONTEUD
	'001'																	, ; //X6_CONTSPA
	'001'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XMLCFND'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica os CFOPS de retorno de Beneficiamento'							, ; //X6_DESCRIC
	'Indica CFOP de devolución de mejora'									, ; //X6_DSCSPA
	'Enter CFOPs of Processing return'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'quando o parâmetro MV_PCNFE = .T.'										, ; //X6_DESC2
	'cuando el parámetro MV_PCNFE = .T.'									, ; //X6_DSCSPA2
	'when parameter MV_PCNFE = .T.'											, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XMLCFNO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	"Identifica os CFOP's de retorno de Beneficiamento"						, ; //X6_DESCRIC
	'Identifica CFOP de devolución de mejora'								, ; //X6_DSCSPA
	'Identify CFOPs of Processing return'									, ; //X6_DSCENG
	'para entrada com tipo N = Normal no documento.'						, ; //X6_DESC1
	'para entrada con tipo N = Normal en el documento.'						, ; //X6_DSCSPA1
	'for inflow with type N = Normal in document.'							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'6901*6902*5902*5901'													, ; //X6_CONTEUD
	'6901*6902*5902*5901'													, ; //X6_CONTSPA
	'6901*6902*5902*5901'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XVEIZF'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tratamento ZF Cliente com excessao PisCofins ST'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"001042"'																, ; //X6_CONTEUD
	'"001042"'																, ; //X6_CONTSPA
	'"001042"'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XVLDSB2'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Valida se Vlr Unitario diferente de zero'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ZB_GEN0001'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita a gravacao do log dos Fontes'									, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ZCD_FAT001'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie usada para Faturamento Hyundai'									, ; //X6_DESCRIC
	'Serie usada para Faturamento Hyundai'									, ; //X6_DSCSPA
	'Serie usada para Faturamento Hyundai'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'7'																		, ; //X6_CONTEUD
	'"7"'																	, ; //X6_CONTSPA
	'"7"'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ZCD_FAT002'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie usada para faturar Chery'										, ; //X6_DESCRIC
	'Serie usada para faturar Chery'										, ; //X6_DSCSPA
	'Serie usada para faturar Chery'										, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'9'																		, ; //X6_CONTEUD
	'"9"'																	, ; //X6_CONTSPA
	'"9"'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ZCD_FAT003'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie usada para Faturamento Subaru'									, ; //X6_DESCRIC
	'Serie usada para Faturamento Subaru'									, ; //X6_DSCSPA
	'Serie usada para Faturamento Subaru'									, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'10'																	, ; //X6_CONTEUD
	'"10"'																	, ; //X6_CONTSPA
	'"10"'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ZCD_FAT004'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie para nota fiscal Normal - Anhanguera'							, ; //X6_DESCRIC
	'Serie para nota fiscal Normal - Anhanguera'							, ; //X6_DSCSPA
	'Serie para nota fiscal Normal - Anhanguera'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
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
	'ZCD_FAT005'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie nota fiscal de Servico - Anhanguera'								, ; //X6_DESCRIC
	'Serie nota fiscal de Servico - Anhanguera'								, ; //X6_DSCSPA
	'Serie nota fiscal de Servico - Anhanguera'								, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	'"0"'																	, ; //X6_CONTSPA
	'"0"'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ZCD_FAT006'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie Nota Normal (Raposo)'											, ; //X6_DESCRIC
	'Serie Nota Normal (Raposo)'											, ; //X6_DSCSPA
	'Serie Nota Normal (Raposo)'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'6'																		, ; //X6_CONTEUD
	'6'																		, ; //X6_CONTSPA
	'6'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ZCD_FAT007'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie Nota Servico (Raposo)'											, ; //X6_DESCRIC
	'Serie Nota Servico (Raposo)'											, ; //X6_DSCSPA
	'Serie Nota Servico (Raposo)'											, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	'S'																		, ; //X6_CONTSPA
	'S'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ZCD_FAT008'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie Nota Normal (SCS)'												, ; //X6_DESCRIC
	'Serie Nota Normal (SCS)'												, ; //X6_DSCSPA
	'Serie Nota Normal (SCS)'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'5'																		, ; //X6_CONTEUD
	'"5"'																	, ; //X6_CONTSPA
	'"5"'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ZCD_FAT009'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie Nota Servico (SCS)'												, ; //X6_DESCRIC
	'Serie Nota Servico (SCS)'												, ; //X6_DSCSPA
	'Serie Nota Servico (SCS)'												, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	'"0"'																	, ; //X6_CONTSPA
	'"0"'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'2010022001'															, ; //X6_FIL
	'MV_BASDEGO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define UFs que terão calculo da base'									, ; //X6_DESCRIC
	'Define Estados que tendrán cálculo de base'							, ; //X6_DSCSPA
	'Defines states with destination calculation base'						, ; //X6_DSCENG
	'do destino em operações de entrada para'								, ; //X6_DESC1
	'del destino en operaciones de entrada para'							, ; //X6_DSCSPA1
	'in inbound operations for'												, ; //X6_DSCENG1
	'contribuinte sem Subtrair ICMS'										, ; //X6_DESC2
	'contribuyente sin sustraer ICMS'										, ; //X6_DSCSPA2
	'the taxpayer without deducting ICMS'									, ; //X6_DSCENG2
	'GO'																	, ; //X6_CONTEUD
	'GO'																	, ; //X6_CONTSPA
	'GO'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'2010022001'															, ; //X6_FIL
	'MV_BASDENT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define UFs que terão calculo da base'									, ; //X6_DESCRIC
	'Define UF que con cálculo de la base'									, ; //X6_DSCSPA
	'It defines the states to have calc basis'								, ; //X6_DSCENG
	'do destino em operações de Difal'										, ; //X6_DESC1
	'del destino en operaciones Difal'										, ; //X6_DSCSPA1
	'of target in Difal operations'											, ; //X6_DSCENG1
	'de entrada para contribuinte do ICMS'									, ; //X6_DESC2
	'de entrada para contribuyente del ICMS'								, ; //X6_DSCSPA2
	'of inflow for ICMS payer'												, ; //X6_DSCENG2
	'GO'																	, ; //X6_CONTEUD
	'GO'																	, ; //X6_CONTSPA
	'GO'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'2010022001'															, ; //X6_FIL
	'MV_CMPALIQ'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Define se calculo de ICMS Complementar'								, ; //X6_DESCRIC
	'Define si cálculo de ICMS Complementario'								, ; //X6_DSCSPA
	'Defines whether Complementary ICMS is calculated'						, ; //X6_DSCENG
	'sera calculado entre diferença entre as'								, ; //X6_DESC1
	'se calculará entre diferencia entre las'								, ; //X6_DSCSPA1
	'between difference between the'										, ; //X6_DSCENG1
	'Aliquotas complementar e ICMS interestaduais'							, ; //X6_DESC2
	'Alícuotas complementarias e ICMS interestatales'						, ; //X6_DSCSPA2
	'Complementary rates and Interstate ICMS'								, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'2010022001'															, ; //X6_FIL
	'MV_UFSTALQ'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define se cálculo de ICMS ST com base dupla'							, ; //X6_DESCRIC
	'Define si cálculo de ICMS ST con base dupla'							, ; //X6_DSCSPA
	'Define if calculation of ICMS ST with double base'						, ; //X6_DSCENG
	'será calculado entre diferença entre as'								, ; //X6_DESC1
	'se calculará la diferencia entre las'									, ; //X6_DSCSPA1
	'will be calculated with difference between'							, ; //X6_DSCENG1
	'Alíquotas ST e ICMS interestaduais'									, ; //X6_DESC2
	'Alícuotas ST e ICMS interestatales'									, ; //X6_DSCSPA2
	'interstate IS and ICMS rates.'											, ; //X6_DSCENG2
	'GO'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'2020012001'															, ; //X6_FIL
	'CMV_EST004'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazem FDR Rec Mudanca'												, ; //X6_DESCRIC
	'Armazem FDR Rec Mudanca'												, ; //X6_DSCSPA
	'Armazem FDR Rec Mudanca'												, ; //X6_DSCENG
	'Armazem FDR Rec Mudanca'												, ; //X6_DESC1
	'Armazem FDR Rec Mudanca'												, ; //X6_DSCSPA1
	'Armazem FDR Rec Mudanca'												, ; //X6_DSCENG1
	'Armazem FDR Rec Mudanca'												, ; //X6_DESC2
	'Armazem FDR Rec Mudanca'												, ; //X6_DSCSPA2
	'Armazem FDR Rec Mudanca'												, ; //X6_DSCENG2
	'90'																	, ; //X6_CONTEUD
	'90'																	, ; //X6_CONTSPA
	'90'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'2020012001'															, ; //X6_FIL
	'CMV_EST005'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazem Rec Mudanca pelo Mod.05 Faturamento'							, ; //X6_DESCRIC
	'Armazem Rec Mudanca pelo Mod.05 Faturamento'							, ; //X6_DSCSPA
	'Armazem Rec Mudanca pelo Mod.05 Faturamento'							, ; //X6_DSCENG
	'Armazem Rec Mudanca pelo Mod.05 Faturamento'							, ; //X6_DESC1
	'Armazem Rec Mudanca pelo Mod.05 Faturamento'							, ; //X6_DSCSPA1
	'Armazem Rec Mudanca pelo Mod.05 Faturamento'							, ; //X6_DSCENG1
	'Armazem Rec Mudanca pelo Mod.05 Faturamento'							, ; //X6_DESC2
	'Armazem Rec Mudanca pelo Mod.05 Faturamento'							, ; //X6_DSCSPA2
	'Armazem Rec Mudanca pelo Mod.05 Faturamento'							, ; //X6_DSCENG2
	'11'																	, ; //X6_CONTEUD
	'11'																	, ; //X6_CONTSPA
	'11'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'2020012001'															, ; //X6_FIL
	'CMV_FAT012'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Parametro para ligar a transferencia automatica NF'					, ; //X6_DESCRIC
	'Parametro para ligar a transferencia automatica NF'					, ; //X6_DSCSPA
	'Parametro para ligar a transferencia automatica NF'					, ; //X6_DSCENG
	'Parametro para ligar a transferencia automatica NF'					, ; //X6_DESC1
	'Parametro para ligar a transferencia automatica NF'					, ; //X6_DSCSPA1
	'Parametro para ligar a transferencia automatica NF'					, ; //X6_DSCENG1
	'Parametro para ligar a transferencia automatica NF'					, ; //X6_DESC2
	'Parametro para ligar a transferencia automatica NF'					, ; //X6_DSCSPA2
	'Parametro para ligar a transferencia automatica NF'					, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'2020012001'															, ; //X6_FIL
	'CMV_FAT013'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES utilizada nos pedidos de mudanca'									, ; //X6_DESCRIC
	'TES utilizada nos pedidos de mudanca'									, ; //X6_DSCSPA
	'TES utilizada nos pedidos de mudanca'									, ; //X6_DSCENG
	'TES utilizada nos pedidos de mudanca'									, ; //X6_DESC1
	'TES utilizada nos pedidos de mudanca'									, ; //X6_DSCSPA1
	'TES utilizada nos pedidos de mudanca'									, ; //X6_DSCENG1
	'TES utilizada nos pedidos de mudanca'									, ; //X6_DESC2
	'TES utilizada nos pedidos de mudanca'									, ; //X6_DSCSPA2
	'TES utilizada nos pedidos de mudanca'									, ; //X6_DSCENG2
	'777'																	, ; //X6_CONTEUD
	'777'																	, ; //X6_CONTSPA
	'777'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'2020012001'															, ; //X6_FIL
	'CMV_PEC032'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Avalia limite de credito por orcamento na Onda'						, ; //X6_DESCRIC
	'Avalia limite de credito por orcamento na Onda'						, ; //X6_DSCSPA
	'Avalia limite de credito por orcamento na Onda'						, ; //X6_DSCENG
	'Avalia limite de credito por orcamento na Onda'						, ; //X6_DESC1
	'Avalia limite de credito por orcamento na Onda'						, ; //X6_DSCSPA1
	'Avalia limite de credito por orcamento na Onda'						, ; //X6_DSCENG1
	'Avalia limite de credito por orcamento na Onda'						, ; //X6_DESC2
	'Avalia limite de credito por orcamento na Onda'						, ; //X6_DSCSPA2
	'Avalia limite de credito por orcamento na Onda'						, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'2020012001'															, ; //X6_FIL
	'CMV_PEC033'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Avalia limite de credito por itens orcamento Onda'						, ; //X6_DESCRIC
	'Avalia limite de credito por itens orcamento Onda'						, ; //X6_DSCSPA
	'Avalia limite de credito por itens orcamento Onda'						, ; //X6_DSCENG
	'Avalia limite de credito por itens orcamento Onda'						, ; //X6_DESC1
	'Avalia limite de credito por itens orcamento Onda'						, ; //X6_DSCSPA1
	'Avalia limite de credito por itens orcamento Onda'						, ; //X6_DSCENG1
	'Avalia limite de credito por itens orcamento Onda'						, ; //X6_DESC2
	'Avalia limite de credito por itens orcamento Onda'						, ; //X6_DSCSPA2
	'Avalia limite de credito por itens orcamento Onda'						, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'2020012001'															, ; //X6_FIL
	'CMV_PEC035'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'SIGAPEC Percentual de valor BO a considerar LimCre'					, ; //X6_DESCRIC
	'SIGAPEC Percentual de valor BO a considerar LimCre'					, ; //X6_DSCSPA
	'SIGAPEC Percentual de valor BO a considerar LimCre'					, ; //X6_DSCENG
	'SIGAPEC Percentual de valor BO a considerar LimCre'					, ; //X6_DESC1
	'SIGAPEC Percentual de valor BO a considerar LimCre'					, ; //X6_DSCSPA1
	'SIGAPEC Percentual de valor BO a considerar LimCre'					, ; //X6_DSCENG1
	'SIGAPEC Percentual de valor BO a considerar LimCre'					, ; //X6_DESC2
	'SIGAPEC Percentual de valor BO a considerar LimCre'					, ; //X6_DSCSPA2
	'SIGAPEC Percentual de valor BO a considerar LimCre'					, ; //X6_DSCENG2
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
	'2020012001'															, ; //X6_FIL
	'CMV_PEC036'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazem de Franco da Roha, para onda em Barueri'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'Armazem de Franco da Roha, para onda em Barueri'						, ; //X6_DESC1
	'Quando informado verificara saldo neste armazem'						, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Armazem de Franco da Roha, para onda em Barueri'						, ; //X6_DESC2
	'Utilizara este armazem Franco da rocha na Onda'						, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'11'																	, ; //X6_CONTEUD
	'11'																	, ; //X6_CONTSPA
	'11'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'2020012001'															, ; //X6_FIL
	'CMV_PEC037'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES utilizada entrada mudanca FDR'										, ; //X6_DESCRIC
	'TES utilizada entrada mudanca FDR'										, ; //X6_DSCSPA
	'TES utilizada entrada mudanca FDR'										, ; //X6_DSCENG
	'TES utilizada entrada mudanca FDR'										, ; //X6_DESC1
	'TES utilizada entrada mudanca FDR'										, ; //X6_DSCSPA1
	'TES utilizada entrada mudanca FDR'										, ; //X6_DSCENG1
	'TES utilizada entrada mudanca FDR'										, ; //X6_DESC2
	'TES utilizada entrada mudanca FDR'										, ; //X6_DSCSPA2
	'TES utilizada entrada mudanca FDR'										, ; //X6_DSCENG2
	'348'																	, ; //X6_CONTEUD
	'348'																	, ; //X6_CONTSPA
	'348'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'2020012001'															, ; //X6_FIL
	'CMV_PEC038'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Pedido transferencia para FDR'									, ; //X6_DESCRIC
	'Tipo de Pedido transferencia para FDR'									, ; //X6_DSCSPA
	'Tipo de Pedido transferencia para FDR'									, ; //X6_DSCENG
	'Tipo de Pedido transferencia para FDR'									, ; //X6_DESC1
	'Tipo de Pedido transferencia para FDR'									, ; //X6_DSCSPA1
	'Tipo de Pedido transferencia para FDR'									, ; //X6_DSCENG1
	'Tipo de Pedido transferencia para FDR'									, ; //X6_DESC2
	'Tipo de Pedido transferencia para FDR'									, ; //X6_DSCSPA2
	'Tipo de Pedido transferencia para FDR'									, ; //X6_DSCENG2
	'016'																	, ; //X6_CONTEUD
	'016'																	, ; //X6_CONTSPA
	'016'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

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

	oProcess:IncRegua2( "Atualizando Arquivos (SX6) ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX7

Função de processamento da gravação do SX7 - Gatilhos

@author UPDATE gerado automaticamente
@since  26/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX7()
Local aEstrut   := {}
Local aAreaSX3  := SX3->( GetArea() )
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX7" + CRLF )

aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
             "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

//
// Campo B1_COD
//
aAdd( aSX7, { ;
	'B1_COD'																, ; //X7_CAMPO
	'501'																	, ; //X7_SEQUENC
	'M->B1_COD'																, ; //X7_REGRA
	'B1_CODITE'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'B1_COD'																, ; //X7_CAMPO
	'502'																	, ; //X7_SEQUENC
	"'S'"																	, ; //X7_REGRA
	'B1_XINTEG'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo B1_EX_NCM
//
aAdd( aSX7, { ;
	'B1_EX_NCM'																, ; //X7_CAMPO
	'502'																	, ; //X7_SEQUENC
	'SYD->YD_PER_IPI'														, ; //X7_REGRA
	'B1_IPI'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SYD'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFILIAL("SYD")+M->B1_POSIPI+M->B1_EX_NCM'								, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo B1_POSIPI
//
aAdd( aSX7, { ;
	'B1_POSIPI'																, ; //X7_CAMPO
	'503'																	, ; //X7_SEQUENC
	"POSICIONE('SYD',1,xFilial('SYD')+SYD->YD_TEC,'YD_PER_IPI')"			, ; //X7_REGRA
	'B1_IPI'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'B1_POSIPI'																, ; //X7_CAMPO
	'504'																	, ; //X7_SEQUENC
	"POSICIONE('SYD',1,xFilial('SYD')+SYD->YD_TEC,'YD_XCEST')"				, ; //X7_REGRA
	'B1_CEST'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'B1_POSIPI'																, ; //X7_CAMPO
	'505'																	, ; //X7_SEQUENC
	'SYD->YD_PER_IPI'														, ; //X7_REGRA
	'B1_IPI'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SYD'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFILIAL("SYD")+M->B1_POSIPI'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		AutoGrLog( "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )

		RecLock( "SX7", .T. )
		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		If SX3->( dbSeek( SX7->X7_CAMPO ) )
			RecLock( "SX3", .F. )
			SX3->X3_TRIGGER := "S"
			MsUnLock()
		EndIf

	EndIf
	oProcess:IncRegua2( "Atualizando Arquivos (SX7) ..." )

Next nI

RestArea( aAreaSX3 )

AutoGrLog( CRLF + "Final da Atualização" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXA

Função de processamento da gravação do SXA - Pastas

@author UPDATE gerado automaticamente
@since  26/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXA()
Local aEstrut   := {}
Local aSXA      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nPosAgr   := 0
Local lAlterou  := .F.

AutoGrLog( "Ínicio da Atualização" + " SXA" + CRLF )

aEstrut := { "XA_ALIAS"  , "XA_ORDEM"  , "XA_DESCRIC", "XA_DESCSPA", "XA_DESCENG", "XA_AGRUP"  , "XA_TIPO"   , ;
             "XA_PROPRI" }


//
// Tabela SB1
//
aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'9'																		, ; //XA_ORDEM
	'Logistica'																, ; //XA_DESCRIC
	'Logistica'																, ; //XA_DESCSPA
	'Logistica'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

nPosAgr := aScan( aEstrut, { |x| AllTrim( x ) == "XA_AGRUP" } )

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXA ) )

dbSelectArea( "SXA" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXA )

	If SXA->( dbSeek( aSXA[nI][1] + aSXA[nI][2] ) )

		lAlterou := .F.

		While !SXA->( EOF() ).AND.  SXA->( XA_ALIAS + XA_ORDEM ) == aSXA[nI][1] + aSXA[nI][2]

			If SXA->XA_AGRUP == aSXA[nI][nPosAgr]
				RecLock( "SXA", .F. )
				For nJ := 1 To Len( aSXA[nI] )
					If FieldPos( aEstrut[nJ] ) > 0 .AND. Alltrim(AllToChar(SXA->( FieldGet( nJ ) ))) <> Alltrim(AllToChar(aSXA[nI][nJ]))
						FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
						lAlterou := .T.
					EndIf
				Next nJ
				dbCommit()
				MsUnLock()
			EndIf

			SXA->( dbSkip() )

		End

		If lAlterou
			AutoGrLog( "Foi alterada a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )
		EndIf

	Else

		RecLock( "SXA", .T. )
		For nJ := 1 To Len( aSXA[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

		AutoGrLog( "Foi incluída a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )

	EndIf

oProcess:IncRegua2( "Atualizando Arquivos (SXA) ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXA" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp

Função de processamento da gravação dos Helps de Campos

@author UPDATE gerado automaticamente
@since  26/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
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
// Helps Tabela SB1
//
aHlpPor := {}
aAdd( aHlpPor, 'Caso esteje = 1,   é feito o  bloqueio' )
aAdd( aHlpPor, 'de estoque do lote do produto que usa' )
aAdd( aHlpPor, 'WMS  através de integração com o' )
aAdd( aHlpPor, 'sistemade analise do CPEE' )

aHlpEng := {}
aAdd( aHlpEng, 'Caso esteje = 1,   é feito o  bloqueio' )
aAdd( aHlpEng, 'de estoque do lote do produto que usa' )
aAdd( aHlpEng, 'WMS  através de integração com o' )
aAdd( aHlpEng, 'sistemade analise do CPEE' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Caso esteje = 1,   é feito o  bloqueio' )
aAdd( aHlpSpa, 'de estoque do lote do produto que usa' )
aAdd( aHlpSpa, 'WMS  através de integração com o' )
aAdd( aHlpSpa, 'sistemade analise do CPEE' )

PutSX1Help( "PB1_YCPEE  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_YCPEE" )

aHlpPor := {}
aAdd( aHlpPor, 'Indica a disposicao da quantiade no' )
aAdd( aHlpPor, 'unitizador. usado no PE.CBRETEAN()' )

aHlpEng := {}
aAdd( aHlpEng, 'Indica a disposicao da quantiade no' )
aAdd( aHlpEng, 'unitizador. usado no PE.CBRETEAN()' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Indica a disposicao da quantiade no' )
aAdd( aHlpSpa, 'unitizador. usado no PE.CBRETEAN()' )

PutSX1Help( "PB1_XQTUNIT", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XQTUNIT" )

aHlpPor := {}
aAdd( aHlpPor, 'Indica o sufixo do unitizador que será' )
aAdd( aHlpPor, 'usado para o produto. Usado na tela' )
aAdd( aHlpPor, 'CBRETEAN' )

aHlpEng := {}
aAdd( aHlpEng, 'Indica o sufixo do unitizador que será' )
aAdd( aHlpEng, 'usado para o produto. Usado na tela' )
aAdd( aHlpEng, 'CBRETEAN' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Indica o sufixo do unitizador que será' )
aAdd( aHlpSpa, 'usado para o produto. Usado na tela' )
aAdd( aHlpSpa, 'CBRETEAN' )

PutSX1Help( "PB1_XIDUNIT", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XIDUNIT" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo p/ marcar a linha do browse a' )
aAdd( aHlpPor, 'alterar o Grupo de Tributação.' )

aHlpEng := {}
aAdd( aHlpEng, 'Campo p/ marcar a linha do browse a' )
aAdd( aHlpEng, 'alterar o Grupo de Tributação.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Campo p/ marcar a linha do browse a' )
aAdd( aHlpSpa, 'alterar o Grupo de Tributação.' )

PutSX1Help( "PB1_XMARB  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XMARB" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo p/ salvar um log de alteração do' )
aAdd( aHlpPor, 'grupo tributação.' )

aHlpEng := {}
aAdd( aHlpEng, 'Campo p/ salvar um log de alteração do' )
aAdd( aHlpEng, 'grupo tributação.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Campo p/ salvar um log de alteração do' )
aAdd( aHlpSpa, 'grupo tributação.' )

PutSX1Help( "PB1_XLOG   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XLOG" )

aHlpPor := {}
aAdd( aHlpPor, 'B1_XPCPSEQ' )

aHlpEng := {}
aAdd( aHlpEng, 'B1_XPCPSEQ' )

aHlpSpa := {}
aAdd( aHlpSpa, 'B1_XPCPSEQ' )

PutSX1Help( "PB1_XPCPSEQ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XPCPSEQ" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor item FOB.' )

aHlpEng := {}
aAdd( aHlpEng, 'Valor item FOB.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Valor item FOB.' )

PutSX1Help( "PB1_XPRCFOB", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XPRCFOB" )

aHlpPor := {}
aAdd( aHlpPor, 'Moeda usada no custo FOB.' )

aHlpEng := {}
aAdd( aHlpEng, 'Moeda usada no custo FOB.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Moeda usada no custo FOB.' )

PutSX1Help( "PB1_XMOEFOB", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XMOEFOB" )

aHlpPor := {}
aAdd( aHlpPor, 'Audito Importacao automatica de produto' )

aHlpEng := {}
aAdd( aHlpEng, 'Audito Importacao automatica de produto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Audito Importacao automatica de produto' )

PutSX1Help( "PB1_XAUDIT ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XAUDIT" )

aHlpPor := {}
aAdd( aHlpPor, 'Res Tecnica' )

aHlpEng := {}
aAdd( aHlpEng, 'Res Tecnica' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Res Tecnica' )

PutSX1Help( "PB1_XRESTEC", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XRESTEC" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo Descontinuado S/N' )

aHlpEng := {}
aAdd( aHlpEng, 'Campo Descontinuado S/N' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Campo Descontinuado S/N' )

PutSX1Help( "PB1_XDESCO ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XDESCO" )

aHlpPor := {}
aAdd( aHlpPor, 'Data de Descontinuacao' )

aHlpEng := {}
aAdd( aHlpEng, 'Data de Descontinuacao' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data de Descontinuacao' )

PutSX1Help( "PB1_XDATADE", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XDATADE" )

//
// Helps Tabela SZO
//
aHlpPor := {}
aAdd( aHlpPor, 'Quantidade de meses que foi incluído o' )
aAdd( aHlpPor, 'Pedido' )

aHlpEng := {}
aAdd( aHlpEng, 'Quantidade de meses que foi incluído o' )
aAdd( aHlpEng, 'Pedido' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Quantidade de meses que foi incluído o' )
aAdd( aHlpSpa, 'Pedido' )

PutSX1Help( "PZO_MESINCL", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZO_MESINCL" )

aHlpPor := {}
aAdd( aHlpPor, 'Data da Primeira compra' )

aHlpEng := {}
aAdd( aHlpEng, 'Data da Primeira compra' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data da Primeira compra' )

PutSX1Help( "PZO_DTPRCMP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZO_DTPRCMP" )

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade de meses referente a' )
aAdd( aHlpPor, 'primeiracompra realizada' )

aHlpEng := {}
aAdd( aHlpEng, 'Quantidade de meses referente a' )
aAdd( aHlpEng, 'primeiracompra realizada' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Quantidade de meses referente a' )
aAdd( aHlpSpa, 'primeiracompra realizada' )

PutSX1Help( "PZO_MESPCMP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZO_MESPCMP" )

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade de meses referente a ultima' )
aAdd( aHlpPor, 'compra' )

aHlpEng := {}
aAdd( aHlpEng, 'Quantidade de meses referente a ultima' )
aAdd( aHlpEng, 'compra' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Quantidade de meses referente a ultima' )
aAdd( aHlpSpa, 'compra' )

PutSX1Help( "PZO_MESUCMP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZO_MESUCMP" )

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade de meses da primeira venda' )

aHlpEng := {}
aAdd( aHlpEng, 'Quantidade de meses da primeira venda' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Quantidade de meses da primeira venda' )

PutSX1Help( "PZO_MESPVEN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZO_MESPVEN" )

aHlpPor := {}
aAdd( aHlpPor, 'Data em que foi realizada a ultima venda' )

aHlpEng := {}
aAdd( aHlpEng, 'Data em que foi realizada a ultima venda' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data em que foi realizada a ultima venda' )

PutSX1Help( "PZO_DTULVND", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZO_DTULVND" )

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade de meses referente a ultima' )
aAdd( aHlpPor, 'venda realizada' )

aHlpEng := {}
aAdd( aHlpEng, 'Quantidade de meses referente a ultima' )
aAdd( aHlpEng, 'venda realizada' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Quantidade de meses referente a ultima' )
aAdd( aHlpSpa, 'venda realizada' )

PutSX1Help( "PZO_MESUVEN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZO_MESUVEN" )

aHlpPor := {}
aAdd( aHlpPor, 'Excesso Custo' )

aHlpEng := {}
aAdd( aHlpEng, 'Excesso Custo' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Excesso Custo' )

PutSX1Help( "PZO_EXCUSTO", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZO_EXCUSTO" )

aHlpPor := {}
aAdd( aHlpPor, 'Pontuação gerada na Curva ABC referente' )
aAdd( aHlpPor, 'a movimentação do Produto por período' )
aAdd( aHlpPor, 'nageração do calculo CURVA ABC' )

aHlpEng := {}
aAdd( aHlpEng, 'Pontuação gerada na Curva ABC referente' )
aAdd( aHlpEng, 'a movimentação do Produto por período' )
aAdd( aHlpEng, 'nageração do calculo CURVA ABC' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Pontuação gerada na Curva ABC referente' )
aAdd( aHlpSpa, 'a movimentação do Produto por período' )
aAdd( aHlpSpa, 'nageração do calculo CURVA ABC' )

PutSX1Help( "PZO_PONTOS ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZO_PONTOS" )

AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

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

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPGAP014" ) ) ) ;
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

@author UPDATE gerado automaticamente
@since  26/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0( lShared )
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

@author UPDATE gerado automaticamente
@since  26/10/2023
@obs    Gerado por EXPORDIC - V.7.5.3.3 EFS / Upd. V.5.4.1 EFS
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
