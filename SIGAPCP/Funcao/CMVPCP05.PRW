#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwbrowse.ch"
#include 'fwmvcdef.ch'

/*
=====================================================================================
Programa.:              CMVPCP05
Autor....:              Atilio Amarilla
Data.....:              01/11/2018
Descricao / Objetivo:   Cadastro de Apontamento - BarCode
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP PCP003
Obs......:
=====================================================================================
*/
User function CMVPCP05(cBarCod)
	local nI			:= 0

	Private oBrowse

	Private cSeqBody	:= SuperGetMV("CMV_PCP05A",,"005")				// C2_SEQUEN para\\
	Private cTipMov		:= SuperGetMV("CMV_PCP05B",,"100")				// TM produção
	Private cEndOk		:= SuperGetMV("CMV_PCP05C",,"A0101          ")	// Endereço Ok (Pintura)
	Private cEndNOk		:= SuperGetMV("CMV_PCP05D",,"CPD01          ")	// Endereço NOk (Pintura)
	Private cSeqRot		:= SuperGetMV("CMV_PCP05E",,"30/20/01/")		// Sequencia de roteiros (C2_ROTEIRO) para apontamentos
	Private cPreRot		:= SuperGetMV("CMV_PCP05F",,"01=10/")			// Roteiro (C2_ROTEIRO) predecessor para validação de apontamentos
	Private cRotBody	:= SuperGetMV("CMV_PCP05G",,"30")				// Roteiros (C2_ROTEIRO) da linha Body
	Private cRotPaint	:= SuperGetMV("CMV_PCP05H",,"20")				// Roteiros (C2_ROTEIRO) da linha Paint
	Private cEndVei		:= SuperGetMV("CMV_PCP05I",,"VEICULO NOVO   ")	// Endereço Ok (Pintura)
	Private aSeqRot		:= Separa(cSeqRot,"/")
	Private cOrdRot	:= ""

	Private aPreRot		:= Separa(cPreRot,"/")

	cSeqRot	:= ""
	For nI := 1 To Len(aSeqRot)
		If !Empty(aSeqRot[nI])
			cSeqRot += IIF(Empty(cSeqRot),"",",") + "'" + aSeqRot[nI] + "'"
			cOrdRot += " WHEN SC2.C2_ROTEIRO = '"+aSeqRot[nI]+"' THEN "+AllTrim(Str(nI))
		EndIf
	Next nI
	cSeqRot := "%("+cSeqRot+")%"
	cOrdRot := "%"+cOrdRot+"%"

	For nI := 1 To Len(aPreRot)
		If !Empty(aPreRot[nI])
			aPreRot[nI] := Separa(aPreRot[nI],"=")
		EndIf
	Next nI


	dbSelectArea("SC2")

	dbSelectArea("SD3")

	dbSelectArea("SD4")

	dbSelectArea("SG2")

	dbSelectArea("SH6")

	dbSelectArea("VV1")

	dbSelectArea("VV2")

	dbSelectArea("ZZ1")

	// Layout Inicial
	/*
	ZZD_FILIAL	C 10
	ZZD_BARCOD	C 06
	ZZD_OP		C 06 (C2_NUM)
	ZZD_OPORIG	C 06 (C2_NUM)
	ZZD_VIN		C 20 (D3_NUMSERI)
	*/

	//Cria um Browse Simples instanciando o FWMBrowse
	oBrowse := FWMBrowse():New()
	//Define um alias para o Browse
	oBrowse:SetAlias('ZZD')
	//Adiciona uma descrição para o Browse
	oBrowse:SetDescription('Apontamento BarCode')

	// Definição da legenda
	oBrowse:AddLegend( "ZZD_BACKFL=='1'.AND.Empty(ZZD_DATAFI)"	, "YELLOW"	, "Backflush - Apontamento Inicial"	)
	oBrowse:AddLegend( "ZZD_BACKFL=='1'.AND.!Empty(ZZD_DATAFI).And.ZZD_INTEGR<>'1'"	, "ORANGE"	, "Backflush - Apontamento Final - Integração pendente"		)
	oBrowse:AddLegend( "ZZD_BACKFL=='1'.AND.!Empty(ZZD_DATAFI).And.ZZD_INTEGR=='1'"	, "GREEN"	, "Backflush - Integrado"		)
	oBrowse:AddLegend( "ZZD_BACKFL<>'1'.AND.Empty(ZZD_DATAFI)"	, "BLUE"	, "Operação - Iniciada")
	oBrowse:AddLegend( "ZZD_BACKFL<>'1'.AND.!Empty(ZZD_DATAFI)"	, "RED"		, "Operação - Encerrada")

	//oBrowse:disableReport()

	//Ativa o Browse
	oBrowse:Activate()

return nil

//-------------------------------------------------------------------
static function MenuDef()

	local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.CMVPCP05'	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Apontamento'	ACTION 'U_CMVPP05A()'		OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'BackFlush'	ACTION 'U_CMVPP05C()'		OPERATION 4 ACCESS 0
	//ADD OPTION aRotina TITLE 'Estorno Backflush'	ACTION 'U_CMVPP05D()'	OPERATION 5 ACCESS 0

	//ADD OPTION aRotina TITLE 'Incluir'		ACTION 'VIEWDEF.CMVPCP05'	OPERATION 3 ACCESS 0
	//ADD OPTION aRotina TITLE 'Alterar'    	ACTION 'VIEWDEF.CMVPCP05'	OPERATION 4 ACCESS 0
	//ADD OPTION aRotina TITLE 'Excluir'    	ACTION 'VIEWDEF.CMVPCP05'	OPERATION 5 ACCESS 0

return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZZD := FWFormStruct( 1, 'ZZD', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('PCP05MDL', /*bPreValidacao*/, /*{ |oMdl| PCP02POS( oMdl ) }*//*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'ZZDMASTER', /*cOwner*/, oStruZZD, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Apontamento BarCode' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'ZZDMASTER' ):SetDescription( 'Apontamento BarCode' )

	oModel:SetPrimaryKey({})

	// oModel:SetVldActivate({ |oMdl| PCP05PRE( oMdl ) })

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'CMVPCP05' )
	// Cria a estrutura a ser usada na View
	Local oStruZZD := FWFormStruct( 2, 'ZZD' )
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados serÃ¡ utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZZD', oStruZZD, 'ZZDMASTER' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZZD', 'TELA' )
Return oView

//-------------------------------------------------------------------
User Function CMVPP05A()// oModel )

	//Local nOperation := oModel:GetOperation()
	Local lRet		:= .T.
	Local lParam	:= .T.

	Local aPergs	:= {}


	Local aArea		:= {GetArea()}
	Local i

	Private aRet		:= {}
	Private cBarCod	:= Space(TamSX3("ZZ3_VIN")[1])
	Private aRecno	:= {0,0,0,0} // {ZZD,}
	Private cNumOrd	:= ""


	/*
	1 - MsGet
	[2] : Descrição
	[3] : String contendo o inicializador do campo
	[4] : String contendo a Picture do campo
	[5] : String contendo a validação
	[6] : Consulta F3
	[7] : String contendo a validação When
	[8] : Tamanho do MsGet
	[9] : Flag .T./.F. Parâmetro Obrigatório ?
	*/
	aAdd( aPergs ,{1,"BarCode          : ",Space(TamSX3("ZZ3_VIN")[1]),"@!",'U_CMVPP05B()'	,""	,'.T.',60,.T.})

	While lParam

		//cBarCod	:= Space(TamSX3("ZZ3_VIN")[1])

		//oBrowse:Refresh()

		dbSelectArea("ZZD")

		If !ParamBox(aPergs ,"Parametros Apontamento - BarCode",aRet,/*bOk*/,/*aButtons*/,/*lCentered*/,/*nPosx*/,/*nPosy*/, /*oDlgWizard*/, /*cLoad*/,.F./*lCanSave*/,.F./*lUserSave*/)
			Aviso("Apontamento - BarCode","Leitura BarCode/VIN terminada!",{'Ok'})
			lParam	:= .F.
			Return
		EndIf

		If aRecno[1] > 0 // Apontamento Final Pendente - UPDATE em ZZD

			ZZD->( dbGoTo( aRecno[1] ) )
//			aAdd( aArea , SC2->(GetArea()) )
			SC2->( dbSeek( xFilial("SC2") + ZZD->ZZD_OP ) )
//			aAdd( aArea , SB1->(GetArea()) )
			SB1->( dbSeek( xFilial("SB1") + SC2->C2_PRODUTO ) )

			// Atualiza Data/Hora Final
			cAviso	:= "Verificação OKNOK"+CRLF+CRLF+"Confirme status do item produzido."+CRLF+"Operação: "+AllTrim(ZZD->ZZD_DESCRI)
			//cAviso	+= AllTrim(GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+ZZD->ZZD_PRODUT,1,""))
			aCampos := {}
			aAdd( aCampos, { 'ZZD_DATAFI'	, Date() } )
			aAdd( aCampos, { 'ZZD_HORAFI'	, Subs(Time(),1,5) } )
			If ZZD->ZZD_BACKFL == "1" // .And. cSeqBody == Subs(ZZD->ZZD_OP,9,3)
				If Subs(ZZD->ZZD_OP,9,3) <> "001"
					nAviso := AVISO(	"Apontamento - BarCode"	,; //<cTítulo>
										cAviso					,; //<cTexto>
										{ "OK", "NOK"}			,;//<aBotões>
										1  ) //<nTamanho>
				Else
					nAviso := 1
				EndIf
				aAdd( aCampos, { 'ZZD_OKNOK'	, If(nAviso==1,"1","2") } )
			ElseIf ZZD->ZZD_BACKFL <> "1"
				aAdd( aCampos, { 'ZZD_INTEGR'	, "2" } )
			EndIf

			lRet	:= Aponta( 4 , "ZZD" , aCampos )
			If lRet .And. ZZD->ZZD_BACKFL == "1"
				U_CMVPP05C()
			EndIf

		ElseIf aRecno[2]>0

//			aAdd( aArea , SC2->(GetArea()) )
			SC2->( dbGoTo( aRecno[2] ) )
//			aAdd( aArea , SG2->(GetArea()) )
			SG2->( dbGoTo( aRecno[3] ) )
//			aAdd( aArea , SB1->(GetArea()) )
			SB1->( dbSetOrder(1) )
			SB1->( dbSeek( xFilial("SB1") + SC2->C2_PRODUTO ) )

			// Atualiza Data/Hora Final
			aCampos := {}
			aAdd( aCampos, { 'ZZD_BARCOD'	, cBarCod } )
			aAdd( aCampos, { 'ZZD_OP'		, SC2->(C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD) } )
			aAdd( aCampos, { 'ZZD_PRODUT'	, SC2->C2_PRODUTO } )
			aAdd( aCampos, { 'ZZD_ROTEIR'	, SC2->C2_ROTEIRO } )
			aAdd( aCampos, { 'ZZD_OPERAC'	, SG2->G2_OPERAC } )
			aAdd( aCampos, { 'ZZD_DESCRI'	, SG2->G2_DESCRI } )
			aAdd( aCampos, { 'ZZD_RECURS'	, SG2->G2_RECURSO } )
			aAdd( aCampos, { 'ZZD_FERRAM'	, SG2->G2_FERRAM } )
			aAdd( aCampos, { 'ZZD_DATAIN'	, Date() } )
			aAdd( aCampos, { 'ZZD_HORAIN'	, Subs(Time(),1,5) } )
			if aRecno[4] == 1
				aAdd( aCampos, { 'ZZD_BACKFL'	, '1' } )
			Else
				aAdd( aCampos, { 'ZZD_BACKFL'	, '2' } )
			EndIf

			Aponta( 3 , "ZZD" , aCampos )

		EndIf
/*
		For i := Len( aArea ) to 1 Step -1
			RestArea( aArea[ i ] )
		Next i
*/
	EndDo


Return lRet
//-------------------------------------------------------------------
Static Function PCP05PRE( oModel )
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.
	Local cAliasTRB		:= "CMVPCP05"
	Local aArea			:= GetArea()

/*
	If nOperation == MODEL_OPERATION_INSERT

		// Verifica operação com pendência de apontamento final
		BeginSql Alias cAliasTRB

			SELECT ( R_E_C_N_O_ ) ZZD_RECNO

			FROM %table:ZZD% ZZD

			WHERE ZZD.%NotDel%
				AND ZZD_FILIAL = %xFilial:ZZD%
				AND ZZD_BARCODE = %Exp:ZZ3->ZZ3_BARCODE%
				AND ZZD_BACKFL = '1'
				AND ZZD_DATAFI <> '        '
				AND ZZD_INTEGR <> '1'

		EndSql

		If !Empty( (cAliasTRB)->ZZD_RECNO )

			Help( ,, 'HELP',, 'Apontamento inválido!'+CRLF+CRLF+'Existe backflush pendente de integração para OP '+ZZ3->ZZ3_OP , 1 , 0 )
			lRet := .F.

		EndIf

		dbSelectArea(cAliasTRB)
		dbCloseArea()

		RestArea( aArea )


	ElseIf nOperation == MODEL_OPERATION_UPDATE // Backflush
*/
	If nOperation == MODEL_OPERATION_UPDATE // Backflush

		If ZZD->ZZD_BACKFL <> '1'

			Help( ,, 'HELP',, 'Operação inválida!'+CRLF+CRLF+'Selecione registro de backflush!' , 1 , 0 )
			lRet := .F.

		ElseIf Empty( ZZ3->ZZ3_VIN ) .And. Subs(ZZD->ZZD_OP,9,3) == "001"

			Help( ,, 'HELP',, 'Não existe VIN cadastrado para backflush!'+CRLF+CRLF+'Atualize integração BarCode x VIN!' , 1 , 0 )
			lRet := .F.

		ElseIf Subs(ZZD->ZZD_OP,9,3) == "001"

			SC2->( dbSetOrder(1) )
			SC2->( dbSeek( xFilial("SC2")+ZZD->ZZD_OP ) )
			M->C2_XFABMOD	:= SC2->C2_XFABMOD

			If (LEN(Alltrim(SC2->C2_XFABMOD)) < 8 )//.or. EMPTY(SC2->C2_XCOMBU) .or. EMPTY(SC2->C2_XACABAM))

				//Help( ,, 'HELP',, "Os campos FABR/MODELO - COMBUSTIVEL - COR INTERNA  precisam ser preenchidos para este tipo de OP " , 1 , 0 )
				Help( ,, 'HELP',, "O campo ANO FABR/MODELO deve ser preenchido para este tipo de OP " , 1 , 0 )
				lRet := .F.

			ElseIf !FG_ANOMOD("C2_XFABMOD")

				Help( ,, 'HELP',, "ANO FABR/MODELO inválido!" , 1 , 0 )
				lRet := .F.

			Else
				ZZ1->( dbSetOrder(1) ) // ZZ1_FILIAL + ZZ1_VIN
				If ZZ1->( dbSeek( xFilial("ZZ1")+ZZ3->ZZ3_VIN ) )
					If EMPTY(ZZ1->ZZ1_MOTOR) .or. EMPTY(ZZ1->ZZ1_SERMOT)
						Help( ,, 'HELP',, "Os campos CODIGO MMOTOR e SERIAL MOTOR devem ser preenchidos no cadastro do VIN "+ZZ3->ZZ3_VIN , 1 , 0 )
						lRet := .F.
					EndIf
				Else
					Help( ,, 'HELP',, 'Não existe VIN cadastrado na tabela de VINs (ZZ1)!'+CRLF+CRLF+'Atualize integração BarCode x VIN!' , 1 , 0 )
					lRet := .F.
				EndIf

			EndIf

		EndIf

	ElseIf nOperation == MODEL_OPERATION_DELETE // Estorno BackFlush

		If ZZD->ZZD_BACKFL <> '1'

			Help( ,, 'HELP',, 'Operação inválida!'+CRLF+CRLF+'Selecione registro de backflush!"' , 1 , 0 )
			lRet := .F.

		Else
			// Verifica operação com pendência de apontamento final
			BeginSql Alias cAliasTRB

				SELECT ( R_E_C_N_O_ ) ZZD_RECNO

				FROM %table:ZZD% ZZD

				WHERE ZZD.%NotDel%
					AND ZZD_FILIAL = %xFilial:ZZD%
					AND ZZD_BARCODE = %Exp:ZZ3->ZZ3_BARCODE%
					AND R_E_C_N_O > %Exp:ZZD->(Recno())%

			EndSql

			If !Empty( (cAliasTRB)->ZZD_RECNO )

				Help( ,, 'HELP',, 'Backflush - Estorno'+CRLF+CRLF+'Backflush não pode ser estornado.'+CRLF+CRLF+'Existe apontamento de operação posterior ao backflush da OP '+ZZD->ZZD_OP , 1 , 0 )
				lRet := .F.

			Else

				SC2->( dbSetOrder(1) )
				If SC2->(dbSeek( xFilial("SC2")+ZZD->ZZD_OP ))
					If SC2->C2_QUJE
						Help( ,, 'HELP',, 'Backflush - Estorno!'+CRLF+'OP sem backflush integrado '+ZZD->ZZD_OP , 1 , 0 )
						lRet := .F.

						If ZZD->ZZD_INTEGR	== "1"

							// Atualiza Campos de Integração
							aCampos := {}
							aAdd( aCampos, { 'ZZD_INTEGR'	, "2"		} )
							aAdd( aCampos, { 'ZZD_DTINT'	, CTOD("")	} )
							aAdd( aCampos, { 'ZZD_HRINT'	, Space(5)	} )

							Aponta( 4 , "ZZD" , aCampos )
/*
							Reclock("ZZD",.F.)
							ZZD->ZZD_INTEGR	:= "2"
							ZZD->ZZD_DTINT	:= CTOD("")
							ZZD->ZZD_HRINT	:= ""
							ZZD->( msUnlock() )
*/
						EndIf

					EndIf
				Else
					Help( ,, 'HELP',, 'Backflush - Estorno!'+CRLF+'OP não localizada '+ZZD->ZZD_OP , 1 , 0 )
					lRet := .F.
				EndIf

			EndIf

			dbSelectArea(cAliasTRB)
			dbCloseArea()

			RestArea( aArea )
		EndIf

		/*
		If SD3->( dbSeek( xFilial("SD3")+ZZ3->ZZ3_OP ) )
			While lRet .And. SD3->( !eof() ) .And. SD3->( D3_FILIAL+Subs(D3_OP,1,6) ) == xFilial("SD3")+ ZZ3->ZZ3_OP

				If Empty(SD3->D3_ESTORNO)

					Help( ,, 'HELP',, 'OP não pode ser excluída!'+CRLF+'Existe movimentação associada à OP.' , 1 , 0 )
					lRet := .F.

				EndIf

				SC2->( dbSkip() )
			EndDo
		EndIf
		*/

	EndIf

Return lRet
//-------------------------------------------------------------------
User Function CMVPP05B()
	local nI		:= 0

	Local lRet		:= .T.
	Local cAlias	:= "ACD003" // GetNextAlias()
	Local aArea		:= GetArea()
	Local cNumOrd	:= ""


	cBarCod	:= MV_PAR01
	aRecno	:= {0,0,0,0}

	If Empty(cBarCod)

		lRet := .F.

	//ElseIf !( Len(AllTrim(cBarCod)) == 6 .Or. Len(AllTrim(cBarCod)) == 17 )

	//	Help( ,, 'HELP',, 'Código Inválido!'+CRLF+CRLF+'Efetue leitura de BarCode ou VIN.' , 1 , 0 )
	//	lRet := .F.

	Else

		dbSelectArea("ZZ3")
		If Len(AllTrim(cBarCod)) <= 6
			cBarCod	:= Subs(cBarCod,1,6)
			dbSetOrder(1)
		Else
			dbSetOrder(4)
		EndIf

		If !ZZ3->( dbSeek( xFilial("ZZ3") + cBarCod ) )

			Help( ,, 'HELP',, 'Código Inválido!'+CRLF+CRLF+'Não existe OP associada a esse código.' , 1 , 0 )
			lRet := .F.

		Else

			cBarCod	:= ZZ3->ZZ3_BARCOD

			// Verifica operação com pendência de apontamento final
			BeginSql Alias cAlias

				SELECT R_E_C_N_O_ ZZD_RECNO, ZZD_OP, ZZD_DATAFI, ZZD_BACKFL, ZZD_INTEGR

				FROM %table:ZZD% ZZD

				WHERE ZZD.%NotDel%
					AND ZZD_FILIAL = %xFilial:ZZD%
					AND ZZD_BARCOD = %Exp:cBarCod%
					AND (ZZD_DATAFI = '        ' OR (ZZD_BACKFL = '1' AND ZZD_INTEGR <> '1'))

			EndSql

			aQuery := getLastQuery()
			cQueryEmb1 := aQuery[2]		// obtem a query do embebed
			//MemoWrite( "C:\TEMP\" + FunName() + "-ZZD-" + DTOS(DATE()) + "-" + StrTran(Time(),":") +".TXT",cQueryEmb1)

			If !Empty((cAlias)->ZZD_OP)

				SC2->( dbSetOrder(1) )
				SC2->( dbSeek( xFilial("SC2")+ZZD->ZZD_OP ) )
				M->C2_XFABMOD	:= SC2->C2_XFABMOD

				If Empty( ZZ3->ZZ3_VIN ) .And. Subs((cAlias)->ZZD_OP,9,3) == "001"

					Help( ,, 'HELP',, 'Não existe VIN cadastrado para backflush!'+CRLF+CRLF+'Atualize integração BarCode x VIN!"' , 1 , 0 )
					lRet := .F.

				ElseIf Subs((cAlias)->ZZD_OP,9,3) == "001" .And. (LEN(Alltrim(SC2->C2_XFABMOD)) < 8 ) // .or. EMPTY(SC2->C2_XCOMBU) .or. EMPTY(SC2->C2_XACABAM))

					//Help( ,, 'HELP',, "Os campos FABR/MODELO - COMBUSTIVEL - COR INTERNA  precisam ser preenchidos para este tipo de OP " , 1 , 0 )
					Help( ,, 'HELP',, "O campo ANO FABR/MODELO deve ser preenchido para este tipo de OP " , 1 , 0 )
					lRet := .F.

				ElseIf Subs((cAlias)->ZZD_OP,9,3) == "001" .And. !FG_ANOMOD("C2_XFABMOD")

					Help( ,, 'HELP',, "ANO FABR/MODELO inválido!" , 1 , 0 )
					lRet := .F.

				ElseIf !Empty((cAlias)->ZZD_DATAFI) .And. (cAlias)->ZZD_BACKFL == '1' .And. (cAlias)->ZZD_INTEGR <> '1'

					Help( ,, 'HELP',, 'Apontamento inválido!'+CRLF+CRLF+'Existe backflush pendente de integração para OP '+ZZ3->ZZ3_OP , 1 , 0 )
					lRet := .F.

				Else

					If Subs((cAlias)->ZZD_OP,9,3) == "001"
						ZZ1->( dbSetOrder(1) ) // ZZ1_FILIAL + ZZ1_VIN
						If ZZ1->( dbSeek( xFilial("ZZ1")+ZZ3->ZZ3_VIN ) )
							If EMPTY(ZZ1->ZZ1_MOTOR) .or. EMPTY(ZZ1->ZZ1_SERMOT)
								Help( ,, 'HELP',, "Os campos CODIGO MMOTOR e SERIAL MOTOR devem ser preenchidos no cadastro do VIN "+ZZ3->ZZ3_VIN , 1 , 0 )
								lRet := .F.
							EndIf
						Else
							Help( ,, 'HELP',, 'Não existe VIN cadastrado na tabela de VINs (ZZ1)!'+CRLF+CRLF+'Atualize integração BarCode x VIN!' , 1 , 0 )
							lRet := .F.
						EndIf
					EndIf


					If lRet
						cNumOrd		:= (cAlias)->ZZD_OP
						aRecno[1]	:= (cAlias)->ZZD_RECNO
					EndIf

				EndIf

			Else


				dbSelectArea(cAlias)
				(cAlias)->( dbCloseArea() )

				BeginSql Alias cAlias

					SELECT C2_ROTEIRO, C2_SEQUEN, C2_NUM || C2_ITEM || C2_SEQUEN || C2_ITEMGRD C2_OP, SC2.R_E_C_N_O_ C2_RECNO, SG2.R_E_C_N_O_ G2_RECNO

					FROM %table:SC2% SC2

					INNER JOIN %table:SG2% SG2 ON SG2.%NotDel%
						AND G2_FILIAL = C2_FILIAL
						AND G2_CODIGO = C2_ROTEIRO
						AND G2_PRODUTO = C2_PRODUTO

					LEFT JOIN %table:ZZD% ZZD ON ZZD.%NotDel%
						AND ZZD_FILIAL = C2_FILIAL
						AND ZZD_OP = C2_NUM || C2_ITEM || C2_SEQUEN || C2_ITEMGRD
						AND ZZD_PRODUT = C2_PRODUTO
						AND ZZD_ROTEIR = C2_ROTEIRO
						AND ZZD_OPERAC = G2_OPERAC
						AND ZZD_RECURS = G2_RECURSO
						AND ZZD_FERRAM = G2_FERRAM

					WHERE SC2.%NotDel%
						AND C2_FILIAL = %xFilial:SC2%
						AND C2_NUM = %Exp:ZZ3->ZZ3_OP%
						AND C2_QUJE = 0
						AND C2_XTIPO = '1'
						AND C2_ROTEIRO IN %Exp:cSeqRot%
						AND ZZD_OP IS NULL
					ORDER BY CASE
							%Exp:cOrdRot%
							END, C2_SEQUEN DESC, G2_OPERAC, G2_RECURSO, G2_FERRAM

				EndSql

				aQuery := getLastQuery()
				cQueryEmb1 := aQuery[2]		// obtem a query do embebed
				MemoWrite( "C:\TEMP\" + FunName() + "-SC2-" + DTOS(DATE()) + "-" + StrTran(Time(),":") +".TXT",cQueryEmb1)

				If Empty((cAlias)->C2_SEQUEN)

					Help( ,, 'HELP',, 'Código Inválido!'+CRLF+CRLF+'Não existe apontamento pendente para OP '+ZZ3->ZZ3_OP , 1 , 0 )
					lRet		:= .F.

				Else

					cNumOrd		:= (cAlias)->C2_OP
					cCodRot		:= (cAlias)->C2_ROTEIRO
					aRecno[2]	:= (cAlias)->C2_RECNO
					aRecno[3]	:= (cAlias)->G2_RECNO

					// Validação de Operações/Roteiros predecessores
					cPreRot := ""
					For nI := 1 To Len(aPreRot)
						If !Empty(aPreRot[nI])
							If aPreRot[nI][1] == (cAlias)->C2_ROTEIRO
								cPreRot += IIF(Empty(cPreRot),"",",") + "'" + aPreRot[nI][2] + "'"
							EndIf
						EndIf
					Next nI


					//If cSeqBody == (cAlias)->C2_SEQUEN

						cSequen := (cAlias)->C2_SEQUEN
						(cAlias)->( dbSkip() )
						If (cAlias)->( eof() ) .Or. cSequen	<> (cAlias)->C2_SEQUEN
							aRecno[4] := 1
						EndIf
						(cAlias)->( dbSkip(-1) )
					//EndIf


					If !Empty(cPreRot)
						cPreRot := "%("+cPreRot+")%"

						dbSelectArea(cAlias)
						(cAlias)->( dbCloseArea() )

						BeginSql Alias cAlias

							SELECT *

							FROM %table:SC2% SC2

							WHERE SC2.%NotDel%
								AND C2_FILIAL = %xFilial:SC2%
								AND C2_NUM = %Exp:ZZ3->ZZ3_OP%
								AND C2_QUJE = 0
								AND C2_ROTEIRO IN %Exp:cPreRot%
							ORDER BY C2_SEQUEN DESC

						EndSql

						aQuery := getLastQuery()
						cQueryEmb1 := aQuery[2]		// obtem a query do embebed
						MemoWrite( "C:\TEMP\" + FunName() + "-SC2-PRE-" + DTOS(DATE()) + "-" + StrTran(Time(),":") +".TXT",cQueryEmb1)

						If !Empty((cAlias)->C2_SEQUEN)

							Help( ,, 'HELP',, 'Código Inválido!'+CRLF+CRLF+'Existe apontamento predecessor pendente (roteiro ' +(cAlias)->C2_ROTEIRO+ ') ao apontamento do roteiro '+cCodRot+' para OP '+ZZ3->ZZ3_OP , 1 , 0 )
							lRet		:= .F.

						EndIf

					EndIf

				EndIf

			EndIf

			dbSelectArea(cAlias)
			(cAlias)->( dbCloseArea() )

			RestArea(aArea)

		EndIf

	EndIf

Return lRet
//-------------------------------------------------------------------
Static Function Aponta( nOper, cMaster, aCpoMaster  )

	Local  oModel, oAux, oStruct
	Local  nI        := 0
	Local  nJ        := 0
	Local  nPos      := 0
	Local  lRet      := .T.
	Local  aAux	     := {}
	Local  aC  	     := {}
	Local  aH        := {}
	Local  nItErro   := 0
	Local  lAux      := .T.

	dbSelectArea( cMaster )
	dbSetOrder( 1 )

	// Aqui ocorre o instanciamento do modelo de dados (Model)
	// Neste exemplo instanciamos o modelo de dados do fonte COMP011_MVC
	// que é a rotina de manutenção de musicas
	oModel := FWLoadModel( 'CMVPCP05' )

	// Temos que definir qual a operação deseja: 3 - Inclusão / 4 - Alteração / 5 - Exclusão
	If nOper	== 3
		oModel:SetOperation( MODEL_OPERATION_INSERT )
	ElseIf nOper	== 4
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
	Endif

	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	// Se o Modelo nao puder ser ativado, talvez por uma regra de ativacao
	// o retorno sera .F.
	lRet := oModel:Activate()

	If lRet
		// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
		oAux    := oModel:GetModel( cMaster + 'MASTER' )

		// Obtemos a estrutura de dados do cabeçalho
		oStruct := oAux:GetStruct()
		aAux	:= oStruct:GetFields()

		If lRet
			For nI := 1 To Len( aCpoMaster )
				// Verifica se os campos passados existem na estrutura do cabeçalho
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoMaster[nI][1] ) } ) ) > 0

					// È feita a atribuicao do dado aos campo do Model do cabeçalho
					If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )
						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRet    := .F.
						Exit
					EndIf
				EndIf
			Next
		EndIf


		If lRet
			// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
			// neste momento os dados não são gravados, são somente validados.
			If ( lRet := oModel:VldData() )
				// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
				lRet := oModel:CommitData()
			EndIf
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

		If nItErro > 0
			AutoGrLog( "Erro no Item:              " + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' )
		EndIf

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

	// Desativamos o Model
	oModel:DeActivate()

Return lRet
//-------------------------------------------------------------------
User Function CMVPP05C()

If ZZD->ZZD_INTEGR <> "1"
	Processa( {|| CMVPCP0501() },'Integrando backflush','Aguarde...',.F. )
Else
	MsgStop( "Registro não pode ser integrado!", "Backflush" )
EndIf

Return
//-------------------------------------------------------------------
Static Function CMVPCP0501()
	local nI			:= 0

	Local aRotAuto		:= {}
	Local aArea			:= {GetArea()}
	Local lData			:= .F.
	Local lRet			:= .T.
	Local nRecZZD		:= ZZD->( Recno() )
	Local cOriName		:= FunName()

	Private lMsErroAuto := .F.

	If ZZD->ZZD_BACKFL <> "1"

		MsgStop("Registro não se refere a backflush!")

		Return

	EndIf

	If dDataBase <> ZZD->ZZD_DATAFI
		dDataori	:= dDataBase
		lData		:= .T.
		dDataBase	:= ZZD->ZZD_DATAFI
	EndIf

	dbSelectArea("ZZ3")
	aAdd( aArea, ZZ3->( GetArea() ))
	dbSetOrder(1)
	If !ZZ3->( dbSeek( xFilial("ZZ3")+ZZD->ZZD_BARCOD ) )
		MsgStop("Amarração BarCode x OP não localizada!")
		lRet		:= .F.
	EndIf

	If lRet
		dbSelectArea("SC2")
		aAdd( aArea, SC2->( GetArea() ))
		dbSetOrder(1)
		If !SC2->( dbSeek( xFilial("SC2")+ZZD->ZZD_OP ) )
			MsgStop("OP "+Alltrim(ZZD->ZZD_OP)+" não localizada!")
			lRet		:= .F.
		ElseIf SC2->C2_QUJE > 0

			MsgStop("OP "+Alltrim(ZZD->ZZD_OP)+" já teve apontadamento!")
			lRet		:= .F.

			If ZZD->ZZD_INTEGR <> "1"

				// Atualiza Campos de Integração
				aCampos := {}
				aAdd( aCampos, { 'ZZD_INTEGR'	, "1"		} )
				aAdd( aCampos, { 'ZZD_DTINT'	, Date()	} )
				aAdd( aCampos, { 'ZZD_HRINT'	, Subs(Time(),1,5)	} )

				Aponta( 4 , "ZZD" , aCampos )

			EndIf

		EndIf

		If lRet
			aAdd( aArea, SB1->( GetArea() ))
			dbSelectArea("SB1")
			dbSetOrder(1)
			If !SB1->( dbSeek( xFilial("SB1")+SC2->C2_PRODUTO ) )
				MsgStop("Produto "+Alltrim(SC2->C2_PRODUTO)+" não localizado!")
				lRet		:= .F.
			EndIf

			If lRet
				aAdd( aArea, SB2->( GetArea() ))
				dbSelectArea("SB2")
				dbSetOrder(1)
				If !SB2->( dbSeek( xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD ) )
					CriaSB2(SB1->B1_COD,SB1->B1_LOCPAD)
				EndIf

				cNumDoc := CMVPCP0502(ZZD->ZZD_BARCOD+Subs(ZZD->ZZD_OP,11,1))
				cCodPro := SB1->B1_COD

				//-- Monta array para utilizacao da Rotina Automatica
				aAdd( aRotAuto  ,	{"D3_FILIAL"	, cFilAnt						,NIL} )
				aAdd( aRotAuto ,	{"D3_TM"		, cTipMov						,NIL} )
				aAdd( aRotAuto  ,	{"D3_OP"		, ZZD->ZZD_OP					,NIL} )
				aAdd( aRotAuto ,	{"D3_DOC"		, cNumDoc						,NIL} )
				/*
				aAdd( aRotAuto ,	{"D3_COD"		, SB1->B1_COD					,NIL} )
				aAdd( aRotAuto ,	{"D3_QUANT"		, SC2->C2_QUANT					,NIL} )
				aAdd( aRotAuto ,	{"D3_LOCAL"		, SB1->B1_LOCPAD				,NIL} )
				aAdd( aRotAuto ,	{"D3_DOC"		, "180521001"					,NIL} )
				aAdd( aRotAuto ,	{"D3_PARCTOT"	, "T"							,NIL} )
				aAdd( aRotAuto ,	{"D3_EMISSAO"	, Date()						,NIL} )
				*/
				aAdd( aRotAuto ,	{"D3_PARCTOT"	, "T"							,NIL} )
				aAdd( aRotAuto ,	{"D3_XBARCOD"	, ZZ3->ZZ3_BARCOD				,NIL} )
				aAdd( aRotAuto ,	{"D3_XVIN"		, ZZ3->ZZ3_VIN					,NIL} )
				If SB1->B1_RASTRO == "L" .And. GetMV("MV_RASTRO") == "S"
					aAdd( aRotAuto , 	{"D3_LOTECTL"	, ZZD->ZZD_BARCOD				,NIL} )
					aAdd( aRotAuto ,	{"D3_DTVALID"	, CTOD("31/12/9999")			,NIL} )
				EndIf
				// Definicao de Indice - Exemplo:
				//				{"INDEX"		,1					,NIL} }

				lMsErroAuto := .F.


				// Chamada da rotina automatica
				MsExecAuto({|x,y| MATA250(x,y)},aRotAuto,3)

				// Verifica se erro é da MATA250 ou INCVEIC
				If Subs(ZZD->ZZD_OP,9,3) == "001" .And. lMsErroAuto

					//Verifica se existe registro de produção (indice 2: D3_FILIAL+D3_DOC+D3_COD)
					If ZZD->ZZD_OP == GetAdvFVal("SD3","D3_OP",xFilial("SD3")+cNumDoc+cCodPro,2,"")
						//Verifica se existe registro de produção (indice 2: D3_FILIAL+D3_DOC+D3_COD)
						If Empty(GetAdvFVal("VV1","VV1_CHAINT",xFilial("VV1")+ZZ3->ZZ3_VIN,2,""))

							Aviso("Backflush - Integração","Backflush integrado sem inclusão de veículo nem endereçamento!"+CRLF+CRLF+"Realize o cadastramento do veículo e endereçamento.")

							If (!IsBlind())
								MostraErro() // TELA
							Else
								// EM ESTADO DE JOB
								cError := ""
								cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

								ConOut(PadC("Automatic routine ended with error", 80))
								ConOut("Error: "+ cError)
							EndIf

							// Atualiza Campos de Integração
							aCampos := {}
							aAdd( aCampos, { 'ZZD_INTEGR'	, "1"		} )
							aAdd( aCampos, { 'ZZD_DTINT'	, Date()	} )
							aAdd( aCampos, { 'ZZD_HRINT'	, Subs(Time(),1,5)	} )

							Aponta( 4 , "ZZD" , aCampos )

							ZZ3->( dbSeek( xFilial("ZZ3")+ZZD->ZZD_BARCOD ) )

						Else
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
					Else
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

				// Mostra Erro na geracao de Rotinas automaticas
				ElseIf lMsErroAuto
					//MsgStop("MostraErro()")
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
					// Atualiza Campos de Integração
					aCampos := {}
					aAdd( aCampos, { 'ZZD_INTEGR'	, "1"		} )
					aAdd( aCampos, { 'ZZD_DTINT'	, Date()	} )
					aAdd( aCampos, { 'ZZD_HRINT'	, Subs(Time(),1,5)	} )

					Aponta( 4 , "ZZD" , aCampos )

					ZZ3->( dbSeek( xFilial("ZZ3")+ZZD->ZZD_BARCOD ) )

					//ZZD->( dbGoTo(nRecZZD) )
					SB1->( dbSeek( xFilial("SB1")+ZZD->ZZD_PRODUT ) )
					If SD3->D3_COD <> ZZD->ZZD_PRODUT
						SD3->( dbSetOrder(2) ) // D3_FILIAL+D3_DOC+D3_COD
						SD3->( dbSeek( xFilial("SD3") + SD3->D3_DOC + ZZD->ZZD_PRODUT ) )
					EndIf

					If !Empty( ZZD->ZZD_OKNOK ) .And. SB1->B1_LOCALIZ == "S" .And. GetMV("MV_LOCALIZ") == "S"

						//MsgStop("SD3->D3_COD "+SD3->D3_COD)
						__aCabec := {}
						aAdd( __aCabec , {"DA_FILIAL"	, cFilAnt			, Nil}	)
						aAdd( __aCabec , {"DA_PRODUTO"	, SB1->B1_COD		, Nil}	)
						aAdd( __aCabec , {"DA_LOCAL"	, SB1->B1_LOCPAD		, Nil}	)
						aAdd( __aCabec , {"DA_NUMSEQ"	, SD3->D3_NUMSEQ	, Nil}	)
						aAdd( __aCabec , {"DA_DOC"		, SD3->D3_DOC		, Nil}	)
						//aAdd( __aCabec , {"DA_ORIGEM"	, "SD3"				, Nil}	)
						aAdd( __aCabec , {"INDEX"		, 1					, NIL}	)

						__aItens :=	{}

						//DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_LOTECTL+DB_NUMLOTE+DB_NUMSERI+DB_LOCALIZ+DB_NUMSEQ
						aAdd( __aItens , {"DB_ITEM"		, "0001"				, Nil}	)
						aAdd( __aItens , {"DB_PRODUTO"	, SD3->D3_COD			, Nil}	)
						aAdd( __aItens , {"DB_LOCAL"	, SD3->D3_LOCAL			, Nil}	)
						aAdd( __aItens , {"DB_LOTECTL"	, SD3->D3_LOTECTL		, Nil}	)
						aAdd( __aItens , {"DB_NUMLOTE"	, SD3->D3_NUMLOTE		, Nil}	)
						If SC2->C2_SEQUEN == "001"
							aAdd( __aItens , {"DB_NUMSERI"	, ZZ3->ZZ3_VIN		, Nil}	)
						EndIf
						If ZZD->ZZD_OKNOK = '1'
							If SC2->C2_SEQUEN == "001"
								aAdd( __aItens , {"DB_LOCALIZ"	, cEndVei				, Nil}	)
							Else
								aAdd( __aItens , {"DB_LOCALIZ"	, cEndOk				, Nil}	)
							EndIf
						Else
							aAdd( __aItens , {"DB_LOCALIZ"	, cEndNOk				, Nil}	)
						EndIf
						aAdd( __aItens , {"DB_NUMSEQ"	, SD3->D3_NUMSEQ		, Nil}	)
						aAdd( __aItens , {"DB_DATA"		, SD3->D3_EMISSAO		, Nil}	)
						aAdd( __aItens , {"DB_QUANT"	, SD3->D3_QUANT			, Nil}	)

						__aItens	:= { __aItens }

						lMsErroAuto := .F.

						MsExecAuto({|x,y,z| Mata265(x,y,z)},__aCabec,__aItens,3)

						If lMsErroAuto

							Aviso("Backflush - Integração","Backflush integrado sem endereçamento!"+CRLF+CRLF+"Realize o endereçamento antes de prosseguir no apontamento deste BarCode (OP)")

							If (!IsBlind())
								MostraErro() // TELA
							Else
								// EM ESTADO DE JOB
								cError := ""
								cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

								ConOut(PadC("Automatic routine ended with error", 80))
								ConOut("Error: "+ cError)
							EndIf

						ElseIf Subs(SD3->D3_OP,9,3) <> "001"

							cOrdEmp := Stuff( SD3->D3_OP , 9 , 3 , Tira1(Subs(SD3->D3_OP,9,3)) )

							//MsgStop("Mata265")
							// Atualização de Empenho

							//SD4->( dbSetOrder(4) ) // D4_FILIAL+D4_OPORIG+D4_LOTECTL+D4_NUMLOTE
							SD4->( dbSetOrder(2) ) // D4_FILIAL+D4_OP+D4_COD+D4_LOCAL

							//If SD4->( dbSeek( xFilial("SD4") + ZZD->(ZZD_OP) + CriaVar("D4_LOTECTL") + CriaVar("D4_NUMLOTE") ) )
							If SD4->( dbSeek( xFilial("SD4") + cOrdEmp + SD3->(D3_COD+D3_LOCAL) ) )

								If SD4->D4_LOTECTL <> SD3->D3_LOTECTL

									//-- Monta array para utilizacao da Rotina Automatica
									aRotAuto	:= {}
									aAdd( aRotAuto  ,	{"D4_FILIAL"	, cFilAnt						,NIL} )
									aAdd( aRotAuto  ,	{"D4_OP"		, cOrdEmp						,NIL} )
									aAdd( aRotAuto ,	{"D4_COD"		, SD3->D3_COD					,NIL} )
									aAdd( aRotAuto  ,	{"D4_LOCAL"		, SD3->D3_LOCAL					,NIL} )
									aAdd( aRotAuto ,	{"INDEX"		, 2								,NIL} )
									aAdd( aRotAuto ,	{"D4_LOTECTL"	, SD3->D3_LOTECTL				,NIL} )
									//aAdd( aRotAuto ,	{"D4_DTVALID"	, SD3->D3_DTVALID				,NIL} )


									// Definicao de Indice - Exemplo:
									//				{"INDEX"		,1					,NIL} }

									lMsErroAuto := .F.
									// Chamada da rotina automatica
									MsExecAuto({|x,y| MATA380(x,y)},aRotAuto,4)

									// Mostra Erro na geracao de Rotinas automaticas
									If lMsErroAuto
										Aviso("Backflush - Integração","Backflush integrado sem atualização de empenho!"+CRLF+CRLF+"Verifique o motivo dessa inconsistência.")

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

								EndIf

							EndIf


						EndIf



					EndIf

					// Integração SIGAVEI
					/*
					If Subs(ZZD->ZZD_OP,9,3) == "001"

						If Empty( GetAdvFVal("VV1","VV1_CHAINT",xFilial("VV1")+SD3->D3_XVIN,2,"") )

							MsgStop( "A250ETRAN IN" )
							// Executa P.E. apos gravacao total dos movimentos
							If ExistBlock("A250ETRAN")
								MsgStop( "A250ETRAN EXEC" )
								ExecBlock("A250ETRAN",.F.,.F.)
							EndIf
							MsgStop( "A250ETRAN OUT" )
						Else
							MsgStop( "VV1 EXISTENTE" )
						EndIf
					EndIf
					*/
				EndIf

				lMsErroAuto := .F.

			EndIf
		EndIf
	EndIf

	For nI := Len( aArea ) to 1 Step -1
		RestArea( aArea[ nI ] )
	Next nI

	If lData
		dDataBase	:= dDataori
	EndIf



Return
//-------------------------------------------------------------------
Static Function CMVPCP0502(cBarCod)

	Local cRet	:= ""
	Local cAliasTRB	:= "CMVPCP05"
	Local aArea	:= GetArea()

	// Verifica operação com pendência de apontamento final
	BeginSql Alias cAliasTRB

		SELECT MAX( D3_DOC ) D3_DOC

		FROM %table:SD3% SD3

		WHERE SD3.%NotDel%
			AND D3_FILIAL = %xFilial:SD3%
			AND SUBSTRING(D3_DOC,1,7) = %Exp:cBarCod%

	EndSql

	If !Empty( (cAliasTRB)->D3_DOC )
		cSeq := Soma1( Subs( (cAliasTRB)->D3_DOC , 8 , 2 ) )
		cRet	:=  cBarCod + cSeq
	Else
		cSeq	:= "01"
		cRet	:=  cBarCod + cSeq
	EndIf

	dbSelectArea(cAliasTRB)
	dbCloseArea()

	RestArea( aArea )

Return( cRet )
//-------------------------------------------------------------------
User Function CMVPP05D()

If ZZD->ZZD_BACKFL == "1"
	Processa( {|| CMVPCP0503() },'Estorno de Integração Backflush','Aguarde...',.F. )
Else
	MsgStop( "Selecione registro de backflush!", "Backflush" )
EndIf

Return
//-------------------------------------------------------------------
Static Function CMVPCP0503()
	local nI		:= 0
	Local aRotAuto	:= {}
	Local aArea		:= {GetArea()}
	Local lData		:= .F.
	Local lRet		:= .T.
	Local nRecZZD	:= ZZD->( Recno() )

	Private lMsErroAuto := .F.

	If dDataBase <> ZZD->ZZD_DATAFI
		dDataori	:= dDataBase
		lData		:= .T.
		dDataBase	:= ZZD->ZZD_DATAFI
	EndIf

	dbSelectArea("ZZ3")
	aAdd( aArea, ZZ3->( GetArea() ))
	dbSetOrder(1)
	If !ZZ3->( dbSeek( xFilial("ZZ3")+ZZD->ZZD_BARCOD ) )
		MsgStop("Amarração BarCode x OP não localizada!")
		lRet		:= .F.
	EndIf

	If lRet
		dbSelectArea("SC2")
		aAdd( aArea, SC2->( GetArea() ))
		dbSetOrder(1)
		If !SC2->( dbSeek( xFilial("SC2")+ZZD->ZZD_OP ) )
			MsgStop("OP "+Alltrim(ZZD->ZZD_OP)+" não localizada!")
			lRet		:= .F.

			If ZZD->ZZD_INTEGR	== "1"
				/*
				Reclock("ZZD",.F.)
				ZZD->ZZD_INTEGR	:= "2"
				ZZD->ZZD_DTINT	:= CTOD("")
				ZZD->ZZD_HRINT	:= ""
				ZZD->( msUnlock() )
				*/
				// Atualiza Campos de Integração
				aCampos := {}
				aAdd( aCampos, { 'ZZD_INTEGR'	, "2"		} )
				aAdd( aCampos, { 'ZZD_DTINT'	, CTOD("")	} )
				aAdd( aCampos, { 'ZZD_HRINT'	, Space(5)	} )

				Aponta( 4 , "ZZD" , aCampos )

			EndIf

		ElseIf SC2->C2_QUJE == 0
			Help( ,, 'HELP',, 'Backflush - Estorno!'+CRLF+'OP sem backflush integrado '+ZZD->ZZD_OP , 1 , 0 )
			lRet := .F.

			If ZZD->ZZD_INTEGR	== "1"
				/*
				Reclock("ZZD",.F.)
				ZZD->ZZD_INTEGR	:= "2"
				ZZD->ZZD_DTINT	:= CTOD("")
				ZZD->ZZD_HRINT	:= ""
				ZZD->( msUnlock() )
				*/
				// Atualiza Campos de Integração
				aCampos := {}
				aAdd( aCampos, { 'ZZD_INTEGR'	, "2"		} )
				aAdd( aCampos, { 'ZZD_DTINT'	, CTOD("")	} )
				aAdd( aCampos, { 'ZZD_HRINT'	, Space(5)	} )

				Aponta( 4 , "ZZD" , aCampos )

			EndIf
		EndIf

		If lRet
			aAdd( aArea, SB1->( GetArea() ))
			dbSelectArea("SB1")
			dbSetOrder(1)
			If !SB1->( dbSeek( xFilial("SB1")+SC2->C2_PRODUTO ) )
				MsgStop("Produto "+Alltrim(SC2->C2_PRODUTO)+" não localizado!")
				lRet		:= .F.
			EndIf

			If lRet

				// Verifica operação com pendência de apontamento final
				BeginSql Alias cAliasTRB

					SELECT D3_NUMSEQ, D3_DOC

					FROM %table:SD3% SD3

					WHERE SD3.%NotDel%
						AND D3_FILIAL = %xFilial:SD3%
						AND D3_OP = %Exp:ZZD->ZZD_OP%
						AND D3_TM = %Exp:cTipMov%
						AND D3_ESTORNO = ' '

				EndSql

				If Empty( (cAliasTRB)->D3_NUMSEQ )

					Help( ,, 'HELP',, 'Backflush - Estorno'+CRLF+CRLF+'Registro de apontamendo de produção não localizado em SD3 para OP '+ZZD->ZZD_OP , 1 , 0 )
					lRet := .F.

				Else


					//-- Monta array para utilizacao da Rotina Automatica
					aAdd( aRotAuto  ,	{"D3_FILIAL"	, cFilAnt						,NIL} )
					aAdd( aRotAuto ,	{"D3_DOC"		, (cAliasTRB)->D3_DOC			,NIL} )
					aAdd( aRotAuto  ,	{"D3_NUMSEQ"	, (cAliasTRB)->D3_NUMSEQ		,NIL} )
					aAdd( aRotAuto ,	{"INDEX"		, 8								,NIL} )

					lMsErroAuto := .F.
					// Chamada da rotina automatica
					MsExecAuto({|x,y| MATA250(x,y)},aRotAuto,5)

					// Mostra Erro na geracao de Rotinas automaticas
					If lMsErroAuto
						//MsgStop("MostraErro()")
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
						/*
						Reclock("ZZD",.F.)
						ZZD->ZZD_INTEGR	:= "2"
						ZZD->ZZD_DTINT	:= CTOD("")
						ZZD->ZZD_HRINT	:= ""
						ZZD->( msUnlock() )
						*/
						// Atualiza Campos de Integração
						aCampos := {}
						aAdd( aCampos, { 'ZZD_INTEGR'	, "2"		} )
						aAdd( aCampos, { 'ZZD_DTINT'	, CTOD("")	} )
						aAdd( aCampos, { 'ZZD_HRINT'	, Space(5)	} )

						Aponta( 4 , "ZZD" , aCampos )


					EndIf

				EndIf

				lMsErroAuto := .F.

			EndIf
		EndIf
	EndIf


	For nI := Len( aArea ) to 1 Step -1
		RestArea( aArea[ nI ] )
	Next nI

	If lData
		dDataBase	:= dDataori
	EndIf

Return
//-------------------------------------------------------------------
