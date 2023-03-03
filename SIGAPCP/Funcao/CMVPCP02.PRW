#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwbrowse.ch"
#include 'fwmvcdef.ch'

/*
=====================================================================================
Programa.:              CMVPCP02
Autor....:              Atilio Amarilla
Data.....:              01/11/2018
Descricao / Objetivo:   Cadastro de Amarração Barcode x OP
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP PCP003
Obs......:              
=====================================================================================
*/
User function CMVPCP02()
	local oBrowse       

	Private cSeqBody	:= SuperGetMV("CMV_PCP05A",,"005") // C2_SEQUEN para
	Private cSeqPaint	:= Tira1(cSeqBody)

	Private cRotBody	:= SuperGetMV("CMV_PCP05G",,"30")				// Roteiros (C2_ROTEIRO) da linha Body
	Private cRotPaint	:= SuperGetMV("CMV_PCP05H",,"20")				// Roteiros (C2_ROTEIRO) da linha Paint


	dbSelectArea("SC2")

	dbSelectArea("SD3")

	dbSelectArea("ZZD")

	// Layout Inicial
	/*
	ZZ3_FILIAL	C 10
	ZZ3_BARCOCE	C 06
	ZZ3_OP		C 06 (C2_NUM)
	ZZ3_OP_ORIG	C 06 (C2_NUM)
	ZZ3_VIN		C 20 (D3_NUMSERI)
	*/

	//Cria um Browse Simples instanciando o FWMBrowse
	oBrowse := FWMBrowse():New()
	//Define um alias para o Browse
	oBrowse:SetAlias('ZZ3')
	//Adiciona uma descrição para o Browse
	oBrowse:SetDescription('Cadastro de Amarração Barcode x OP')

	//oBrowse:disableReport()

	//Ativa o Browse
	oBrowse:Activate()

return nil

//-------------------------------------------------------------------
static function MenuDef()

	local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.CMVPCP02'	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'		ACTION 'VIEWDEF.CMVPCP02'	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Troca de OP'  ACTION 'VIEWDEF.CMVPCP02'	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    	ACTION 'VIEWDEF.CMVPCP02'	OPERATION 5 ACCESS 0

return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZZ3 := FWFormStruct( 1, 'ZZ3', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('PCP02MDL', /*bPreValidacao*/, { |oMdl| PCP02POS( oMdl ) }/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'ZZ3MASTER', /*cOwner*/, oStruZZ3, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Cadastro de Amarração Barcode x OP' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'ZZ3MASTER' ):SetDescription( 'Cadastro de Amarração Barcode x OP' )

	oModel:SetPrimaryKey({})

	oModel:SetVldActivate({ |oMdl| PCP02PRE( oMdl ) })

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'CMVPCP02' )
	// Cria a estrutura a ser usada na View
	Local oStruSZ4 := FWFormStruct( 2, 'ZZ3' )
	Local oView  

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados serÃ¡ utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZZ3', oStruSZ4, 'ZZ3MASTER' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZZ3', 'TELA' )
Return oView

//-------------------------------------------------------------------

/*/{Protheus.doc} zGeraExcel
Gera planilha excel
@param  	aColunas -> Colunas da planilha
aItens -> Itens/Dados da planilha
cArqExc -> Nome arquivo a ser criado
cPatSrv -> Pasta do server para criação da planilha
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

Static Function zGeraExc(aColunas,aItens,cArqExc,cPatSrv,cPatLoc,cTitulo)

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
	//Local bValid         := {|| Iif(ApOleClient("MsExcel"),.T.,(MsgAlert("MsExcel não instalado"),)) }
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
		//		 MsgInfo( "Arquivo " + cArq + " gerado com sucesso no diretório " + cPath )
		If ApOleClient("MsExcel")

			If !"X:" $ AllTrim(cPatLoc)
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( cPatLoc + cArqExc )
				oExcelApp:SetVisible(.T.)              // Abre excel automaticamente .T. // Não .F.
				//		  oExcel:Destroy()                       // exclui Excel.exe do processo no gerenciador de tarefas
			EndIf
		Else
			Aviso("zGeraExc","MsExcel não instalado"+CRLF+"Planilha "+cArqExc+" copiado para pasta "+cPatLoc+".",{'Ok'})
		EndIf
	else
		Aviso("zGeraExc","Planilha "+cArqExc+" não copiado para pasta "+cPatLoc+"."+CRLF+"Verifique suas permissões.",{'Ok'})
	endif
	//   Endif

Return
//-------------------------------------------------------------------
Static Function PCP02POS( oModel )
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.
	Local aArea			:= { GetArea() }
	Local aAreaZZ3		:= GetArea()
	Local cBarCod, cNumOrd
	Local aOP			:= {}
	
	Local lInclui		:= INCLUI
	Local lAltera		:= ALTERA
	//Local lEclui		:= EXCLUI

	If nOperation == MODEL_OPERATION_INSERT

		cNumOrd	:= oModel:GetValue( 'ZZ3MASTER', 'ZZ3_OP' )
		cBarCod	:= oModel:GetValue( 'ZZ3MASTER', 'ZZ3_BARCOD' )
		
		
		aAdd( aOP , { cNumOrd , cBarCod } )

		INCLUI	:= .F.
		ALTERA	:= .T.
		//EXCLUI	:= .F.

		Processa( {|| CMVPCP0201(aOP) },'Gravando Barcode na OP','Aguarde...',.F. )
		

	ElseIf nOperation == MODEL_OPERATION_DELETE

		cNumOrd	:= oModel:GetValue( 'ZZ3MASTER', 'ZZ3_OP' )
		cBarCod	:= Space(TamSX3("ZZ3_BARCOD")[1])

		aAdd( aOP , { cNumOrd , cBarCod } )

		INCLUI	:= .F.
		ALTERA	:= .T.
		//EXCLUI	:= .T.

		Processa( {|| CMVPCP0201(aOP) },'Excluindo Barcode na OP','Aguarde...',.F. )

	ElseIf nOperation == MODEL_OPERATION_UPDATE

		cOrdOri	:= ZZ3->ZZ3_OP
		cPrdOri	:= ZZ3->ZZ3_PRODUT
		cDesOri	:= ZZ3->ZZ3_DESC
		cNumOrd := M->ZZ3_OP


		aAdd( aArea, ZZ3->( GetArea() ))
		
		ZZ3->( dbSetOrder(3) ) // ZZ3_FILIAL+ZZ3_OP
		If ZZ3->( dbSeek( xFilial("ZZ3")+cNumOrd ) )
			RecLock("ZZ3",.F.)
			ZZ3->ZZ3_OP		:= cOrdOri
			ZZ3->ZZ3_PRODUT	:= cPrdOri
			ZZ3->ZZ3_DESC	:= cDesOri  
			ZZ3->( msUnlock() ) 
		Else
			Help( ,, 'HELP',, 'Não foi localizado BarCode associado à OP '+cNumOrd , 1 , 0 )
			lRet		:= .F.
		EndIf 


		If lRet

			aAdd( aOP , { ZZ3->ZZ3_OP	, ZZ3->ZZ3_BARCOD } )
			
			aAdd( aOP , { M->ZZ3_OP 	, M->ZZ3_BARCOD } )
	
			Processa( {|| CMVPCP0201(aOP) },'Gravando Barcode na OP','Aguarde...',.F. )

			/*
			aAdd( aArea, SC2->( GetArea() ))
			If SC2->( dbSeek( xFilial("SC2")+ZZ3->ZZ3_OP ) )
				While SC2->( !eof() ) .And. SC2->( C2_FILIAL+C2_NUM ) == xFilial("SC2")+ ZZ3->ZZ3_OP
					// FwFldGet( 'ZZC_LINHA' )
					RecLock("SC2",.F.)
					SC2->C2_XBARCOD	:= ZZ3->ZZ3_BARCOD
					SC2->( msUnlock() )

					SC2->( dbSkip() )
				EndDo
			EndIf
			If SC2->( dbSeek( xFilial("SC2")+M->ZZ3_OP ) )
				While SC2->( !eof() ) .And. SC2->( C2_FILIAL+C2_NUM ) == xFilial("SC2")+ M->ZZ3_OP
					// FwFldGet( 'ZZC_LINHA' )
					RecLock("SC2",.F.)
					SC2->C2_XBARCOD	:= M->ZZ3_BARCOD
					SC2->( msUnlock() )

					SC2->( dbSkip() )
				EndDo
			EndIf
			*/
		EndIf
	EndIf

	For i := Len( aArea ) to 1 Step -1
		RestArea( aArea[ i ] )
	Next i

	INCLUI	:= lInclui
	ALTERA	:= lAltera
	//EXCLUI	:= lExclui

Return lRet
//-------------------------------------------------------------------
Static Function PCP02PRE( oModel )
	Local nOperation := oModel:GetOperation()
	Local lRet       := .T.
	Local cAlias	:= "PCP003" // GetNextAlias()

	If nOperation == MODEL_OPERATION_DELETE

		If SD3->( dbSeek( xFilial("SD3")+ZZ3->ZZ3_OP ) )
			While lRet .And. SD3->( !eof() ) .And. SD3->( D3_FILIAL+Subs(D3_OP,1,6) ) == xFilial("SD3")+ ZZ3->ZZ3_OP

				If Empty(SD3->D3_ESTORNO)

					Help( ,, 'HELP',, 'OP não pode ser excluída!'+CRLF+'Existe movimentação associada à OP.' , 1 , 0 )
					lRet := .F.

				EndIf

				SD3->( dbSkip() )
			EndDo
		EndIf

	ElseIf nOperation == MODEL_OPERATION_UPDATE

		BeginSql Alias cAlias

			SELECT SC2.C2_SEQUEN

			FROM %table:SC2% SC2

			WHERE SC2.%NotDel%
				AND SC2.C2_FILIAL = %xFilial:SC2%
				AND SC2.C2_NUM = %Exp:ZZ3->ZZ3_OP%
				AND SC2.C2_ITEM = '01'
				AND SC2.C2_ROTEIRO = %Exp:cRotPaint%
			ORDER BY 1 DESC

		EndSql

		If Empty( (cAlias)->C2_SEQUEN )

			Help( ,, 'HELP',, 'OP '+ZZ3->ZZ3_OP+' não foi localizada sequencia referente ao Paint!' , 1 , 0 )
			lRet := .F.

		ElseIf ZZD->( dbSeek( xFilial("ZZD") + ZZ3->ZZ3_BARCOD + ZZ3->ZZ3_OP + "01" + (cAlias)->C2_SEQUEN ) )

			Help( ,, 'HELP',, 'OP '+ZZ3->ZZ3_OP+' não pode ser selecionada!'+CRLF+'Existe apontamento posterior ao Body.' , 1 , 0 )
			lRet := .F.

		Else
			
			dbSelectArea(cAlias)
			dbCloseArea()
			
			BeginSql Alias cAlias
	
				SELECT SC2.C2_SEQUEN
	
				FROM %table:SC2% SC2
	
				WHERE SC2.%NotDel%
					AND SC2.C2_FILIAL = %xFilial:SC2%
					AND SC2.C2_NUM = %Exp:ZZ3->ZZ3_OP%
					AND SC2.C2_ITEM = '01'
					AND SC2.C2_ROTEIRO = %Exp:cRotBody%
				ORDER BY 1 
	
			EndSql

			If Empty( (cAlias)->C2_SEQUEN )
	
				Help( ,, 'HELP',, 'OP '+ZZ3->ZZ3_OP+' não pode ser selecionada!'+CRLF+'Não foi localizada sequencia referente ao Body!' , 1 , 0 )
				lRet := .F.
	
			ElseIf SC2->( dbSeek( xFilial("SC2") + ZZ3->ZZ3_OP + "01" + (cAlias)->C2_SEQUEN ) )

				If SC2->C2_QUJE == 0
	
					Help( ,, 'HELP',, 'OP '+ZZ3->ZZ3_OP+' não pode ser selecionada!'+CRLF+'Não existe backflush do Body.' , 1 , 0 )
					lRet := .F.
	
				EndIf

			EndIf

		EndIf

		dbSelectArea(cAlias)
		dbCloseArea()

	EndIf

Return lRet
//-------------------------------------------------------------------
User Function CMVPP02A(cOP,cItem,cSequen,cBarCod,cQtde,cRoteiro)

	Local lRet		:= .F.
	Local cAlias	:= "PCP003" // GetNextAlias()
	Local aArea		:= GetArea()

	//Local cSeqBody	:= SuperGetMV("CMV_PCP05A",,"005") // C2_SEQUEN para
	//Local cSeqPaint	:= Tira1(cSeqBody)

	Private cRotBody	:= SuperGetMV("CMV_PCP05G",,"30")				// Roteiros (C2_ROTEIRO) da linha Body
	Private cRotPaint	:= SuperGetMV("CMV_PCP05H",,"20")				// Roteiros (C2_ROTEIRO) da linha Paint


	If cItem+cSequen == "01001" .And. cQtde == 0 .And. !Empty(cRoteiro)

		If INCLUI .And. Empty(cBarCod)


/*
			// 27/05/2019 - Atilio - Altersção de critério para seleção de sequencia de OP da linha Body. Busca pelo roteiro
			BeginSql Alias cAlias

				SELECT SC2B.C2_NUM, SC2B.C2_QUJE

				FROM %table:SC2% SC2

				INNER JOIN %table:SC2% SC2B ON SC2B.%NotDel%
					AND SC2B.C2_FILIAL = %xFilial:SC2%
					AND SC2B.C2_NUM = %Exp:cOP%
					AND SC2B.C2_ITEM = '01'
					AND SC2B.C2_SEQUEN = %Exp:SuperGetMV("CMV_PCP05A",,"005")%
					AND SC2B.C2_ROTEIRO <> '  ' 
					AND SC2B.C2_XBARCOD = '      '

				WHERE SC2.%NotDel%
					AND SC2.C2_FILIAL = %xFilial:SC2%
					AND SC2.C2_NUM = %Exp:cOP%
					AND SC2.C2_ITEM = '01'
					AND SC2.C2_SEQUEN = '001'
					AND SC2.C2_QUJE = 0
					AND SC2.C2_XTIPO = '1'
					AND SC2.C2_ROTEIRO <> '  ' 
					AND SC2.C2_XBARCOD = '      '

			EndSql
*/

			BeginSql Alias cAlias

				SELECT SC2B.C2_NUM, SC2B.C2_QUJE

				FROM %table:SC2% SC2

				INNER JOIN %table:SC2% SC2B ON SC2B.%NotDel%
					AND SC2B.C2_FILIAL = %xFilial:SC2%
					AND SC2B.C2_NUM = %Exp:cOP%
					AND SC2B.C2_ITEM = '01'
					AND SC2B.C2_QUJE = 0
					AND SC2B.C2_ROTEIRO = %Exp:cRotBody% 
					AND SC2B.C2_XBARCOD = '      '

				WHERE SC2.%NotDel%
					AND SC2.C2_FILIAL = %xFilial:SC2%
					AND SC2.C2_NUM = %Exp:cOP%
					AND SC2.C2_ITEM = '01'
					AND SC2.C2_SEQUEN = '001'
					AND SC2.C2_QUJE = 0
					AND SC2.C2_XTIPO = '1'
					AND SC2.C2_ROTEIRO <> '  ' 
					AND SC2.C2_XBARCOD = '      '

			EndSql

			If !Empty((cAlias)->C2_NUM) .And. (cAlias)->C2_QUJE = 0
				lRet		:= .T.
			EndIf

			dbSelectArea(cAlias)
			(cAlias)->( dbCloseArea() )

		ElseIf ALTERA .And. !Empty(cBarCod) // Troca de OP (Pintura - Roteiro PS)

/*
			// 27/05/2019 - Atilio - Altersção de critério para seleção de sequencia de OP da linha Body. Busca pelo roteiro
			BeginSql Alias cAlias

				SELECT ZZD_OP, SC2B.C2_NUM, SC2B.C2_QUJE

				FROM %table:SC2% SC2

				INNER JOIN %table:SC2% SC2B ON SC2B.%NotDel%
					AND SC2B.C2_FILIAL = %xFilial:SC2%
					AND SC2B.C2_NUM = %Exp:cOP%
					AND SC2B.C2_ITEM = '01'
					AND SC2B.C2_SEQUEN = %Exp:SuperGetMV("CMV_PCP05A",,"005")%
					AND SC2B.C2_ROTEIRO <> '  ' 
					AND SC2B.C2_XBARCOD NOT IN ('      ',%Exp:ZZ3->ZZ3_BARCOD%)

				LEFT JOIN %table:ZZD% ZZD ON ZZD.%NotDel%
					AND ZZD.ZZD_FILIAL = %xFilial:ZZD%
					AND SUBSTRING(ZZD.ZZD_OP,1,6) = %Exp:cOP%
					AND SUBSTRING(ZZD.ZZD_OP,7,2) = '01'
					AND SUBSTRING(ZZD.ZZD_OP,9,3) <> %Exp:SuperGetMV("CMV_PCP05A",,"005")%

				WHERE SC2.%NotDel%
					AND SC2.C2_FILIAL = %xFilial:SC2%
					AND SC2.C2_NUM = %Exp:cOP%
					AND SC2.C2_ITEM = '01'
					AND SC2.C2_SEQUEN = '001'
					AND SC2.C2_QUJE = 0
					AND SC2.C2_XTIPO = '1'
					AND SC2.C2_ROTEIRO <> '  ' 
					AND SC2.C2_XBARCOD NOT IN  ('      ',%Exp:ZZ3->ZZ3_BARCOD%)
				ORDER BY 1 DESC

			EndSql
*/

			BeginSql Alias cAlias

				SELECT ZZD_OP, SC2B.C2_NUM, SC2B.C2_QUJE

				FROM %table:SC2% SC2

				INNER JOIN %table:SC2% SC2B ON SC2B.%NotDel%
					AND SC2B.C2_FILIAL = %xFilial:SC2%
					AND SC2B.C2_NUM = %Exp:cOP%
					AND SC2B.C2_ITEM = '01'
					AND SC2B.C2_ROTEIRO = %Exp:cRotBody% 
					AND SC2B.C2_XBARCOD NOT IN ('      ',%Exp:ZZ3->ZZ3_BARCOD%)

				LEFT JOIN %table:ZZD% ZZD ON ZZD.%NotDel%
					AND ZZD.ZZD_FILIAL = %xFilial:ZZD%
					AND SUBSTRING(ZZD.ZZD_OP,1,6) = %Exp:cOP%
					AND SUBSTRING(ZZD.ZZD_OP,7,2) = '01'
					AND SUBSTRING(ZZD.ZZD_OP,9,3) <> SC2B.C2_SEQUEN

				WHERE SC2.%NotDel%
					AND SC2.C2_FILIAL = %xFilial:SC2%
					AND SC2.C2_NUM = %Exp:cOP%
					AND SC2.C2_ITEM = '01'
					AND SC2.C2_SEQUEN = '001'
					AND SC2.C2_QUJE = 0
					AND SC2.C2_XTIPO = '1'
					AND SC2.C2_ROTEIRO <> '  ' 
					AND SC2.C2_XBARCOD NOT IN  ('      ',%Exp:ZZ3->ZZ3_BARCOD%)
				ORDER BY 1 DESC

			EndSql

			//aQuery := getLastQuery()
			//cQueryEmb1 := aQuery[2]		// obtem a query do embebed
			//MemoWrite( "C:\TEMP\" + FunName() + "-" + DTOS(DATE()) + "-" + StrTran(Time(),":") +".TXT",cQueryEmb1)

			If Empty((cAlias)->ZZD_OP) .And. !Empty((cAlias)->C2_NUM) .And. (cAlias)->C2_QUJE > 0
				lRet		:= .T.
			EndIf

			dbSelectArea(cAlias)
			(cAlias)->( dbCloseArea() )

		EndIf

		RestArea(aArea)
	EndIf

Return lRet
//-------------------------------------------------------------------
User Function CMVPP02B(cOP)

	Local lRet	:= .T.
	Local aArea		:= {GetArea()}

	//Local cSeqBody	:= SuperGetMV("CMV_PCP05A",,"005") // C2_SEQUEN para
	//Local cSeqPaint	:= Tira1(cSeqBody)

	Local cAlias	:= "PCP006"

	Private cRotBody	:= SuperGetMV("CMV_PCP05G",,"30")				// Roteiros (C2_ROTEIRO) da linha Body
	Private cRotPaint	:= SuperGetMV("CMV_PCP05H",,"20")				// Roteiros (C2_ROTEIRO) da linha Paint


	If INCLUI
		If ExistChav("ZZ3",M->ZZ3_OP,3).And.ExistCpo("SC2",M->ZZ3_OP+"01001")
			aAdd( aArea, SC2->( GetArea() ))
			SC2->( dbSeek(xFilial("SC2") + M->ZZ3_OP+"01001") )
			If SC2->C2_XTIPO <> "1"
				Help( ,, 'HELP',, 'Tipo da OP diferente de Manufatura!' , 1 , 0 )
				lRet := .F.
			ElseIf !Empty( SC2->C2_XBARCOD )
				Help( ,, 'HELP',, 'OP já está associada ao BarCode '+SC2->C2_XBARCOD , 1 , 0 )
				lRet := .F.
			ElseIf !Empty( SC2->C2_QUJE )
				Help( ,, 'HELP',, 'OP já possui apontamento!' , 1 , 0 )
				lRet := .F.
			ElseIf !Empty( SC2->C2_DATRF )
				Help( ,, 'HELP',, 'OP encerrada!' , 1 , 0 )
				lRet := .F.
			ElseIf Empty( SC2->C2_ROTEIRO )
				Help( ,, 'HELP',, 'OP não possui roteiro cadastrado!' , 1 , 0 )
				lRet := .F.
			Else

				BeginSql Alias cAlias
	
					SELECT SC2B.C2_NUM, SC2B.C2_QUJE
	
					FROM %table:SC2% SC2
	
					INNER JOIN %table:SC2% SC2B ON SC2B.%NotDel%
						AND SC2B.C2_FILIAL = %xFilial:SC2%
						AND SC2B.C2_NUM = %Exp:cOP%
						AND SC2B.C2_ITEM = '01'
						AND SC2B.C2_ROTEIRO = %Exp:cRotBody% 
						AND SC2B.C2_XBARCOD = '      '
	
					WHERE SC2.%NotDel%
						AND SC2.C2_FILIAL = %xFilial:SC2%
						AND SC2.C2_NUM = %Exp:cOP%
						AND SC2.C2_ITEM = '01'
						AND SC2.C2_SEQUEN = '001'
						AND SC2.C2_QUJE = 0
						AND SC2.C2_XTIPO = '1'
						AND SC2.C2_ROTEIRO <> '  ' 
						AND SC2.C2_XBARCOD = '      '
	
				EndSql
	
				If Empty((cAlias)->C2_NUM)
					Help( ,, 'HELP',, 'OP não pode ser selecionada!'+CRLF+CRLF+'Sequencia da OP referente a Body não localizada!' , 1 , 0 )
					lRet		:= .F.
				ElseIf(cAlias)->C2_QUJE > 0
					Help( ,, 'HELP',, 'OP já possui apontamento para Body!' , 1 , 0 )
					lRet		:= .F.
				EndIf
	
				dbSelectArea(cAlias)
				(cAlias)->( dbCloseArea() )

				If lRet
					BeginSql Alias cAlias
	
						SELECT SUM(SC2.C2_QUJE) C2_QUJE
	
						FROM %table:SC2% SC2
	
						WHERE SC2.%NotDel%
							AND SC2.C2_FILIAL = %xFilial:SC2%
							AND SC2.C2_NUM = %Exp:cOP%
							AND SC2.C2_ITEM = '01'
	
					EndSql
	
					If (cAlias)->C2_QUJE > 0
						Help( ,, 'HELP',, 'OP já possui apontamento!' , 1 , 0 )
						lRet		:= .F.
					EndIf
	
					dbSelectArea(cAlias)
					(cAlias)->( dbCloseArea() )
				EndIf
			EndIf 
		Else
			lRet	:= .F.
		EndIf
	ElseIf ALTERA
		If ExistCpo("SC2",M->ZZ3_OP+"01001")
			aAdd( aArea, SC2->( GetArea() ))
			SC2->( dbSeek(xFilial("SC2") + M->ZZ3_OP+"01001") )
			If SC2->C2_XTIPO <> "1"
				Help( ,, 'HELP',, 'Tipo da OP diferente de Manufatura!' , 1 , 0 )
				lRet := .F.
			ElseIf Empty( SC2->C2_XBARCOD )
				Help( ,, 'HELP',, 'OP não está associada a BarCode!' , 1 , 0 )
				lRet := .F.
			ElseIf !Empty( SC2->C2_QUJE )
				Help( ,, 'HELP',, 'OP já possui apontamento!' , 1 , 0 )
				lRet := .F.
			ElseIf !Empty( SC2->C2_DATRF )
				Help( ,, 'HELP',, 'OP encerrada!' , 1 , 0 )
				lRet := .F.
			ElseIf Empty( SC2->C2_ROTEIRO )
				Help( ,, 'HELP',, 'OP não possui roteiro cadastrado!' , 1 , 0 )
				lRet := .F.
			Else
/*
				BeginSql Alias cAlias

					SELECT ZZD_OP, SC2B.C2_NUM, SC2B.C2_QUJE

					FROM %table:SC2% SC2

					INNER JOIN %table:SC2% SC2B ON SC2B.%NotDel%
						AND SC2B.C2_FILIAL = %xFilial:SC2%
						AND SC2B.C2_NUM = %Exp:cOP%
						AND SC2B.C2_ITEM = '01'
						AND SC2B.C2_ROTEIRO = %Exp:cRotPaint% 
						AND SC2B.C2_XBARCOD NOT IN ('      ',%Exp:ZZ3->ZZ3_BARCOD%)

					LEFT JOIN %table:ZZD% ZZD ON ZZD.%NotDel%
						AND ZZD.ZZD_FILIAL = %xFilial:ZZD%
						AND SUBSTRING(ZZD.ZZD_OP,1,6) = %Exp:cOP%
						AND SUBSTRING(ZZD.ZZD_OP,7,2) = '01'
						AND SUBSTRING(ZZD.ZZD_OP,9,3) <> SC2B.C2_SEQUEN

					WHERE SC2.%NotDel%
						AND SC2.C2_FILIAL = %xFilial:SC2%
						AND SC2.C2_NUM = %Exp:cOP%
						AND SC2.C2_ITEM = '01'
						AND SC2.C2_SEQUEN = '001'
						AND SC2.C2_QUJE = 0
						AND SC2.C2_XTIPO = '1'
						AND SC2.C2_ROTEIRO <> '  ' 
						AND SC2.C2_XBARCOD NOT IN  ('      ',%Exp:ZZ3->ZZ3_BARCOD%)
					ORDER BY 1 DESC

				EndSql
*/
				BeginSql Alias cAlias

					SELECT ZZD_OP, SC2.C2_NUM, SC2.C2_QUJE

					FROM %table:SC2% SC2

					LEFT JOIN %table:ZZD% ZZD ON ZZD.%NotDel%
						AND ZZD.ZZD_FILIAL = %xFilial:ZZD%
						AND SUBSTRING(ZZD.ZZD_OP,1,6) = %Exp:cOP%
						AND SUBSTRING(ZZD.ZZD_OP,7,2) = '01'
						AND SUBSTRING(ZZD.ZZD_OP,9,3) = SC2.C2_SEQUEN

					WHERE SC2.%NotDel%
						AND SC2.C2_FILIAL = %xFilial:SC2%
						AND SC2.C2_NUM = %Exp:cOP%
						AND SC2.C2_ITEM = '01'
						AND SC2.C2_ROTEIRO = %Exp:cRotPaint% 
						AND SC2.C2_XTIPO = '1'
						AND SC2.C2_XBARCOD NOT IN  ('      ',%Exp:ZZ3->ZZ3_BARCOD%)
					ORDER BY 1 DESC

				EndSql

				aQuery := getLastQuery()
				cQueryEmb1 := aQuery[2]		// obtem a query do embebed
				MemoWrite( "C:\TEMP\" + FunName() + "-" + DTOS(DATE()) + "-" + StrTran(Time(),":") +".TXT",cQueryEmb1)

				If !Empty((cAlias)->ZZD_OP) .Or. Empty((cAlias)->C2_NUM) .Or. (cAlias)->C2_QUJE <> 0
					Help( ,, 'HELP',, 'OP não pode ser selacionada!'+CRLF+CRLF+'Verifique se existe backflush do Body ou apontamento de operação posterior' , 1 , 0 )
					lRet		:= .F.
				EndIf

				dbSelectArea(cAlias)
				(cAlias)->( dbCloseArea() )
			EndIf 
		Else
			lRet	:= .F.
		EndIf
	EndIf

	For i := Len( aArea ) to 1 Step -1
		RestArea( aArea[ i ] )
	Next i

Return lRet
//-------------------------------------------------------------------
Static Function CMVPCP0201( aOP )

	Local cFunName	:= FunName()
	Local lIntgMES	:= PCPIntgPPI()
	Local aArea		:= { GetArea() }
	Local i			:= 0
	Local aRotAuto	:= {}

	private lMsHelpAuto     := .T.
	private lMsErroAuto     := .F.
	private lAutoErrNoFile  := .T. // Precisa estar como .T. para GetAutoGRLog() retornar o array com erros



	aAdd( aArea, SC2->( GetArea() ))
	SC2->( dbSetOrder(1) )
	SG2->( dbSetOrder(1) )
	
	aIntegPPI := {}

	For i := 1 To Len( aOP )

		cNumOrd	:= aOP[i][1]
		cBarCod	:= aOP[i][2]
	
		If SC2->( dbSeek( xFilial("SC2")+ cNumOrd ) )
	
			While SC2->( !eof() ) .And. SC2->( C2_FILIAL+C2_NUM ) == xFilial("SC2")+cNumOrd

				If Empty(SC2->C2_QUJE) .And. SC2->C2_XBARCOD <> cBarCod // Somente OPs sem apontamento
/*
					aRotAuto	:= {}
					//-- Monta array para utilizacao da Rotina Automatica
					aAdd( aRotAuto  ,	{	"C2_FILIAL"		,	SC2->C2_FILIAL	,NIL} )
					aAdd( aRotAuto  ,	{	"C2_NUM"		,	SC2->C2_NUM		,NIL} )
					aAdd( aRotAuto  ,	{	"C2_ITEM"		,	SC2->C2_ITEM	,NIL} )
					aAdd( aRotAuto  ,	{	"C2_SEQUEN"		,	SC2->C2_SEQUEN	,NIL} )
					aAdd( aRotAuto  ,	{	"C2_ITEMGRD"	,	SC2->C2_ITEMGRD	,NIL} )
					aAdd( aRotAuto  ,	{	"INDEX"			,	1				,NIL} )
					aAdd( aRotAuto  ,	{	"C2_XBARCOD"	,	cBarCod			,NIL} )

					lMsErroAuto     := .F.

					// Chamada da rotina automatica
					MsExecAuto({|x,y| MATA650(x,y)},aRotAuto,3)
					
					// Mostra Erro na geracao de Rotinas automaticas
					If lMsErroAuto
						MostraErro()
					EndIf
*/
					SG2->( dbSeek( xFilial("SG2") + SC2->C2_ROTEIRO + SC2->C2_PRODUTO ) )

					RecLock("SC2",.F.)
					SC2->C2_XBARCOD	:= cBarCod
					If SC2->C2_XTIPO <> "1"
						SC2->C2_XTIPO	:= "1"
					EndIf
					SC2->( msUnlock() )
	
					If lIntgMES
	
						If cFunName <> "MATA650"
							SetFunName("MATA650")
						EndIf
	
						mata650PPI(,,.T.,.T.)
	
						If cFunName <> "MATA650"
							SetFunName(cFunName)
						EndIf
	
					EndIf
	
				EndIf
	
				SC2->( dbSkip() )
			EndDo
	
		EndIf
	
	Next i

	If Len(aIntegPPI) > 0
		cMsg := "Atenção! Ocorreram erros na integração com o PCFactory. Erro: " + CHR(10)
		For ni := 1 To Len(aIntegPPI)
			cMsg += "OP: " + AllTrim(aIntegPPI[ni,1]) + " - " + AllTrim(aIntegPPI[ni,2]) + CHR(10) //
		Next ni
		Aviso("Erro",cMsg,{"Ok"},3)
	EndIf

	
	For i := Len( aArea ) to 1 Step -1
		RestArea( aArea[ i ] )
	Next i

Return
//-------------------------------------------------------------------