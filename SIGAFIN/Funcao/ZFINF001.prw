#Include "Protheus.CH"
#Include "TOTVS.CH"

// #DEFINE VW_SEC_HEAD   1
#DEFINE VW_SEC_MIDDLE 1 //2
#DEFINE VW_SEC_FOOTER 2 //3

/*
=====================================================================================
Programa.:              ZFIN001
Autor....:              CAOA - Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Consulta Limite de Crédito Cliente
Doc. Origem:            
Solicitante:            
Uso......:              Montadora
Obs......:
=====================================================================================
*/
User Function ZFINF001()
	Local cPerg := "CONSCLI"
	Local aArea	:= GetArea()

	If Pergunte(cPerg,.T.)
		MsgRun("Consultando Cliente. Aguarde..." , "CAOA" , {|| CursorWait() , ConsCliWnd() , CursorArrow() } )
	EndIf

	RestArea(aArea)
Return

/*/{Protheus.doc} ConsCliWnd
	Função para montagem da Tela de Consulta.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult; denis.galvani - Denis A. Galvani
	@since 		24/02/2019
	@version 	2.0
	// @param 		param_name, param_type	, param_description
	@return 	NIL			, Nulo *(nenhum)*
	@history 	14/08/2020	, denis.galvani, Correção na exportação para arquivo, formato XML.\n Valor de *Texto numérico* para *Números*. Permite operação pelo editor de planilhas sem fórmulas para conversão (de texto em número).
	@history 	14/08/2020	, denis.galvani, Melhoria e correção de títulos *(aTitles)* e tamanhos de colunas *(aSizes)*.
	@history 	14/08/2020	, denis.galvani, Novas colunas *"Tp. Operação"* e *"Pedido"*.
	@history 	14/08/2020	, denis.galvani, Formatação da grid de dados *(máscara, alinhamento e tamanho)*
	@history 	14/08/2020	, denis.galvani, Melhor apresentação de totalizadores *(máscaras, alinhamento e condicional de cores de texto)*
	@history 	14/08/2020	, denis.galvani, Nome da função refatorada para melhor semântica. Nome e sintaxe antiga: *`Con01()`*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	@history 	26/08/2020	, denis.galvani, Ajustes na passagem de parâmetros (ordem) aos métodos da classe
	/*/
Static Function ConsCliWnd()
	LOCAL lPixels    := .T.
	LOCAL cPicture   := "@!"
	LOCAL cPictValor := GetSx3Cache("E1_SALDO","X3_PICTURE") // E1_SALDO =>> X3_PICTURE == "@E 9,999,999,999,999.99"
	LOCAL nSayWidth  := 070
	LOCAL nSayHeight := 007
	// LOCAL lHtml      := .F.
	LOCAL nTxtAlgHor := 0   // 0 - LEFT ; 1 - RIGHT  ; 2 - CENTER ; 3 - JUSTIFIED
	// LOCAL nTxtAlgVer := NIL

	LOCAL aTitles 	 := {}
	LOCAL aCols      := {}
	LOCAL aSize		 := {}

	LOCAL cCadastro	:= "Consulta de Clientes - CAOA"
	LOCAL oRed		:= LoadBitmap(GetResources(),'BR_VERMELHO')
	LOCAL oYellow	:= LoadBitmap(GetResources(),'BR_AMARELO')
	LOCAL oGreen	:= LoadBitmap(GetResources(),'BR_VERDE')
	LOCAL oBmp		:= NIL
	LOCAL oBmp1		:= NIL
	LOCAL oDlg		:= NIL
	LOCAL oGetDados	:= NIL

	// Totalizadores
	PRIVATE cStDescri  := ""
	PRIVATE nStLibCor  := CLR_BLUE
	PRIVATE nTotal     := 0
	PRIVATE nTotAbto   := 0
	PRIVATE nTotEnca   := 0
	PRIVATE nTotDocs   := 0
	PRIVATE nLimCred   := 0
	PRIVATE nTotCons   := 0
	PRIVATE nSaldo     := 0

	// TITULO COLUNA NO BROWSE E PARA ARQUIVO EXPORTADO (XML / EXCEL)
	aTitles := { ''				 ,;
				'Filial'         ,;
				'Código / Loja'  ,;
				'Razão Social'   ,;
				'CNPJ / CPF'     ,;
				'Prefixo'        ,;
				'Título'         ,;
				'Parcela'        ,;
				'Tipo'           ,;
				'Nosso Número'   ,;
				'Banco'          ,;
				'Cobrança'       ,;
				'Emissão'        ,;
				'Vencto real'    /* Vencimento [E1_VENCTO] // Vencto real [E1_VENCREA] */,;
				'Vlr. Título'    ,;
				'Dt. Baixa'      ,;
				'Vlr. Líquido'   ,;
				'Juros'          ,;
				'Vlr. Aberto'    ,;
				'Pedido'         ,;
				'Tp. Operação'   }

	// LARGURA DAS COLUNAS NO BROWSE
	aSize     := Array( Len(aTitles) )
	// aSize[01] := 013	// Legenda
	// aSize[02] := 060	// Filial
	aSize[03] := 040	// Código / Loja
	aSize[04] := 150	// Razão Social
	// aSize[05] := 050	// CNPJ / CPF
	// aSize[06] := 030	// Prefixo
	// aSize[07] := 040	// Título
	// aSize[08] := 030	// Parcela
	// aSize[09] := 030	// Tipo
	// aSize[10] := 050	// Nosso Numero
	// aSize[11] := 030	// Banco
	// aSize[12] := 030	// Cobrança
	// aSize[13] := 050	// Emissão
	// aSize[14] := 050	// Vencimento [E1_VENCTO] // Vencto real [E1_VENCREA]
	// aSize[15] := 070	// Vlr. Título
	// aSize[16] := 050	// Dt Baixa
	// aSize[17] := 070	// Vlr. Líquido
	// aSize[18] := 070	// Juros
	// aSize[19] := 070	// Vlr. Aberto
	// aSize[20] := 030	// Pedido
	// aSize[21] := 060	// Tp. Operação

	// Função para consultar \ carregar os dados da consulta
	aCols := CarDados()

	// Retorna vazio somente se não tiver títulos na SE1, ou, o cliente \ grupo de cliente não tenha limite de crédito
	If Len(aCols) = 0
		MsgInfo("Não há dados a serem consultados.","CAOA")
		Return
	EndIf

	// DIMENSIONAR COMPONENTES DE TELA
	aSizeAut := MsAdvSize()
	aObjects := {}

	AAdd( aObjects, { 100, 200 , .T., .F. } ) // GRID / BROWSE
	AAdd( aObjects, { 100, 100 , .T., .T. } ) // RODAPE / TOTALIZADORES

	aInfo    := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }

	// CALCULAR DIMENSOES / POSICOES
	aPosObj1 := MsObjSize( aInfo, aObjects)

	Define Font oBold Name "Arial" Size 0,-12 BOLD

	// JANELA PRINCIPAL DE DADOS
	Define MsDialog oDlg Title cCadastro From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] Of oDlg Pixel

	// GRID DE DADOS
	oGetDados := TWBrowse():New(aPosObj1[VW_SEC_MIDDLE,2],003,aPosObj1[VW_SEC_MIDDLE,4],aPosObj1[VW_SEC_MIDDLE,3],,/*aTitles*/,/*aSize*/,oDlg,,,,,,,,,,,,,/*cAliTit*/,.T.,,,,,)

	// MATRIZ DE DADOS
	oGetDados:SetArray(aCols)

	// LEGENDA
	bDataLeg  := {|| Iif(aCols[oGetDados:nAt,1] =='BX',oRed,Iif(aCols[oGetDados:nAt,1] == 'PB',oYellow,oGreen)) }
	oGetDados:AddColumn(TCColumn():New(aTitles[01], bDataLeg                      ,                          ,,, "CENTER" , /* aSize[01] */ ,.T.,.F.,,{|| .F. },,.F., ) )

	// GRID - COLUNAS DA CONSULTA
	oGetDados:AddColumn(TCColumn():New(aTitles[02], {|| aCols[oGetDados:nAt,02] } , "@!"                     ,,, "LEFT"   , /* aSize[02] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[03], {|| aCols[oGetDados:nAt,03] } , "@!"                     ,,, "LEFT"   ,    aSize[03]    ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[04], {|| aCols[oGetDados:nAt,04] } , "@!"                     ,,, "LEFT"   ,    aSize[04]    ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[05], {|| aCols[oGetDados:nAt,05] } , PesqPict("SA1","A1_CGC") ,,, "LEFT"   , /* aSize[05] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[06], {|| aCols[oGetDados:nAt,06] } , "@!"                     ,,, "LEFT"   , /* aSize[06] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[07], {|| aCols[oGetDados:nAt,07] } , "@!"                     ,,, "LEFT"   , /* aSize[07] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[08], {|| aCols[oGetDados:nAt,08] } , "@!"                     ,,, "LEFT"   , /* aSize[08] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[09], {|| aCols[oGetDados:nAt,09] } , "@!"                     ,,, "LEFT"   , /* aSize[09] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[10], {|| aCols[oGetDados:nAt,10] } , "@!"                     ,,, "LEFT"   , /* aSize[10] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[11], {|| aCols[oGetDados:nAt,11] } , "@!"                     ,,, "LEFT"   , /* aSize[11] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[12], {|| aCols[oGetDados:nAt,12] } , "@!"                     ,,, "LEFT"   , /* aSize[12] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[13], {|| aCols[oGetDados:nAt,13] } ,                          ,,, "CENTER" , /* aSize[13] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[14], {|| aCols[oGetDados:nAt,14] } ,                          ,,, "CENTER" , /* aSize[14] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[15], {|| aCols[oGetDados:nAt,15] } , cPictValor               ,,, "RIGHT"  , /* aSize[15] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[16], {|| aCols[oGetDados:nAt,16] } ,                          ,,, "CENTER" , /* aSize[16] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[17], {|| aCols[oGetDados:nAt,17] } , cPictValor               ,,, "RIGHT"  , /* aSize[17] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[18], {|| aCols[oGetDados:nAt,18] } , cPictValor               ,,, "RIGHT"  , /* aSize[18] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[19], {|| aCols[oGetDados:nAt,19] } , cPictValor               ,,, "RIGHT"  , /* aSize[19] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[20], {|| aCols[oGetDados:nAt,20] } , "@!"                     ,,, "CENTER" , /* aSize[20] */ ,.F.,.F.,,{|| .F. },,.F., ) )
	oGetDados:AddColumn(TCColumn():New(aTitles[21], {|| aCols[oGetDados:nAt,21] } , "@!"                     ,,, "LEFT"   , /* aSize[21] */ ,.F.,.F.,,{|| .F. },,.F., ) )

	oGetDados:SetFocus()
	oGetDados:Refresh()

	// TOTALIZADORES
	// lPixels    := .T.
	// cPicture   := NIL
	// nSayWidth  := 070
	// nSayHeight := 007
	// lHtml      := .F.
	// nTxtAlgHor := 0   // 0 - LEFT ; 1 - RIGHT  ; 2 - CENTER ; 3 - JUSTIFIED
	// nTxtAlgVer := NIL // 0 - TOP  ; 1 - BOTTOM ; 2 - MIDDLE

	// PRIMEIRA COLUNA
	/*
	TSay():New( [ nRow ], [ nCol ], [ bText ], [ oWnd ], [ cPicture ], [ oFont ], [ uParam7 ], [ uParam8 ], [ uParam9 ], [ lPixels ], [ nClrText ], [ nClrBack ], [ nWidth ], [ nHeight ], [ uParam15 ], [ uParam16 ], [ uParam17 ], [ uParam18 ], [ uParam19 ], [ lHTML ], [ nTxtAlgHor ], [ nTxtAlgVer ] )
	*/
	bText      := {|| "Quantidade" }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 03,005,bText,oDlg, ,oBold,,,,lPixels, ,, nSayWidth,nSayHeight )
	cPicture   := "@E 999,999,999"
	bText      := {|| nTotal }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 03,105,bText,oDlg,cPicture,oBold,,,,lPixels,CLR_BLUE,, nSayWidth,nSayHeight ,,,,,, , 1 )

	bText      := {|| "Total Doc's em Aberto:" }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 18,005,bText,oDlg, ,oBold,,,,lPixels, ,, nSayWidth,nSayHeight )
	bText      := {|| nTotAbto }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 18,105,bText,oDlg,cPictValor,oBold,,,,lPixels,CLR_BLUE,, nSayWidth,nSayHeight ,,,,,, , 1 )

	bText      := {|| "Total de Encargos:" }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 33,005,bText,oDlg, ,oBold,,,,lPixels, ,, nSayWidth,nSayHeight )
	bText      := {|| nTotEnca }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 33,105,bText,oDlg,cPictValor,oBold,,,,lPixels,CLR_BLUE,, nSayWidth,nSayHeight ,,,,,, , 1 )

	bText      := {|| "Total Doc's + Encargos:" }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 48,005,bText,oDlg, ,oBold,,,,lPixels, ,, nSayWidth,nSayHeight )
	bText      := {|| nTotDocs }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 48,105,bText,oDlg,cPictValor,oBold,,,,lPixels,CLR_BLUE,, nSayWidth,nSayHeight ,,,,,, , 1 )


	// SEGUNDA COLUNA
	bText      := {|| "Limite de Crédito:" }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 18,205,bText,oDlg, ,oBold,,,,lPixels, ,, nSayWidth,nSayHeight )
	bText      := {|| nLimCred }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 18,275,bText,oDlg,cPictValor,oBold,,,,lPixels,CLR_BLUE,, nSayWidth,nSayHeight ,,,,,, , 1 )

	bText      := {|| "Valor Consumido:" }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 33,205,bText,oDlg, ,oBold,,,,lPixels, ,, nSayWidth,nSayHeight )
	bText      := {|| nTotCons }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 33,275,bText,oDlg,cPictValor,oBold,,,,lPixels,CLR_BLUE,, nSayWidth,nSayHeight ,,,,,, , 1 )

	bText      := {|| "Saldo:" }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 48,205,bText,oDlg, ,oBold,,,,lPixels, ,, nSayWidth,nSayHeight )
	bText      := {|| nSaldo }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 48,275,bText,oDlg,cPictValor,oBold,,,,lPixels,Iif(nSaldo<0,CLR_RED,CLR_BLUE),, nSayWidth,nSayHeight ,,,,,, , 1 )


	// TERCEIRA COLUNA
	bText      := {|| "Status:" }
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 18,360,bText,oDlg, ,oBold,,,,lPixels, ,, nSayWidth,nSayHeight )
	bText      := {|| cStDescri }
	nTxtAlgHor := NIL   // 0 - LEFT ; 1 - RIGHT  ; 2 - CENTER ; 3 - JUSTIFIED
	cPicture   := "@!"
	nSayWidth  := 120
	TSay():New(aPosObj1[VW_SEC_FOOTER,1] + 18,385,bText,oDlg,cPicture,oBold,,,,lPixels,nStLibCor,, nSayWidth,nSayHeight )


	// QUARTA COLUNA - LEGENDAS
	@ aPosObj1[VW_SEC_FOOTER,1] + 18,515 BITMAP oBmp  RESNAME "BR_VERDE" 				SIZE 16,16 NOBORDER OF oDlg PIXEL
	@ aPosObj1[VW_SEC_FOOTER,1] + 18,525 SAY 'Título em Aberto'							SIZE 070,07 OF oDlg PIXEL FONT oBold

	@ aPosObj1[VW_SEC_FOOTER,1] + 33,515 BITMAP oBmp1 RESNAME "DISABLE" 				SIZE 16,16 NOBORDER OF oDlg PIXEL
	@ aPosObj1[VW_SEC_FOOTER,1] + 33,525 SAY 'Título Baixado'							SIZE 070,07 OF oDlg PIXEL FONT oBold

	@ aPosObj1[VW_SEC_FOOTER,1] + 48,515 BITMAP oBmp1 RESNAME "BR_AMARELO" 				SIZE 16,16 NOBORDER OF oDlg PIXEL
	@ aPosObj1[VW_SEC_FOOTER,1] + 48,525 SAY 'Título Parcialmente Baixado'				SIZE 070,07 OF oDlg PIXEL FONT oBold

	// QUINTA COLUNA - BOTOES
	TButton():New(aPosObj1[VW_SEC_FOOTER,3]-36,aPosObj1[VW_SEC_FOOTER,4]-53,"&Excel",oDlg,{|| Processa({|| 	U_GraExcel( aTitles, aCols, "Planilha", "Consulta de Clientes - CAOA")},'CAOA','Gerando Relatório. Aguarde...') },50,15,,oBold,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(aPosObj1[VW_SEC_FOOTER,3]-18,aPosObj1[VW_SEC_FOOTER,4]-53,"&Sair" ,oDlg,{|| oDlg:End() },50,15,,oBold,.F.,.T.,.F.,,.F.,,,.F. )

	oDlg:lCentered := .T.

	oDlg:Activate()

Return

/*/{Protheus.doc} CarDados
	Função para carregar as informações da Consulta do Cliente.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult; denis.galvani - Denis A. Galvani
	@since 		24/02/2019
	@version 	2.0
	@param 		cCodCli		, character , Código do Cliente - campo `A1_COD´. *DEFAULT* `MV_PAR01`
	@param 		cLojCli		, character , Loja do Cliente - campo `A1_LOJA` inicial. *DEFAULT* `MV_PAR02`
	// @param 		cLojCliAte	, character , Loja do Cliente - campo `A1_LOJA` final. *DEFAULT* `MV_PAR03`
	@return 	array, Dados consultados e tratados
	@history 	04/02/2020	, denis.galvani, Novo parâmetro, *cLojCliAte*.
	@history 	04/02/2020	, denis.galvani, Retorno de dados, formato *aCols*.
	@history 	09/03/2020	, denis.galvani, Terceiro parâmetro, *cLojCliAte*, descontinuado e removido.
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	@history 	26/08/2020	, denis.galvani, Ajustes na passagem de parâmetros (ordem) aos métodos da classe
	/*/
Static Function CarDados(cCodCli,cLojCli)//,cLojCliAte)
	Local cAliTit	 := GetNextAlias()
	Local cQuery	 := ""
	Local cRaizCNPJ	 := ""
	Local cTipOper	 := ""
	Local cOperCrd	 := ""
	Local lCliLoj	 := .F.
	Local nValOpCr	 := 0
	Local nValRaNCC	 := 0
	Local oClasCrd	 := Nil

	LOCAL aCols      := {}
	LOCAL cTpLim     := GetMv("CAOA_TPLIM")
	LOCAL nTamTpLim  := Iif(Len(cTpLim) > 1, Len(cTpLim) -1, 02)
	LOCAL cMvStLib   := PadR(GetMv("CAOA_STLIB",.F.,"01"),TamSx3("A1_XSTATUS")[1])

	DEFAULT cCodCli	   := MV_PAR01
	DEFAULT cLojCli	   := MV_PAR02
	// DEFAULT cLojCliAte := MV_PAR03

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + cCodCli + cLojCli))

	DbSelectArea("SZB")
	SZB->(DbSetOrder(1)) //ZB_FILIAL+ZB_COD+ZB_DESCR
	SZB->(DbSeek(xFilial("SZB") + SA1->A1_XSTATUS))

	cStDescri := AllTrim(SZB->ZB_DESCR)
	If SA1->A1_XSTATUS == cMvStLib
		nStLibCor  := CLR_BLUE
	Else
		nStLibCor  := CLR_RED
	EndIf

	// SA1 - CLIENTE - DESCONSIDERA GRUPO DE EMPRESAS (A1_XDESGRP) - MESMA RAIZ CNPJ (A1_CGC)
	// 1 - SIM
	// 2 - NAO ou VAZIO (NAO PREENCHIDO)
	If SA1->A1_XDESGRP == '1'
		lCliLoj    := .T. // 1 - SIM - Desconsidera Grupo
		cCodCli    := SA1->A1_COD
		cLojCli	   := SA1->A1_LOJA
		// cLojCliAte := MV_PAR03
	Else
		lCliLoj := .F. // 2 - NAO ou VAZIO - Considera Grupo de Empresas do Cliente indicado
		cRaizCNPJ := SubsTr(SA1->A1_CGC,1,8)
	EndIf

	If Select(cAliTit) > 0
		(cAliTit)->(DbCloseArea())
	EndIf
	cQuery := "SELECT "
	cQuery += "  CASE WHEN E1_SALDO = 0 THEN 'BX' "
	cQuery += "       WHEN E1_SALDO = E1_VALOR THEN 'NB' "
	cQuery += "       ELSE 'PB' END AS TIPO_BAIXA, "
	cQuery += "  E1_FILIAL, "
	cQuery += "  E1_CLIENTE || ' / ' || E1_LOJA AS CODIGLOJA, "
	cQuery += "  A1_NOME, "
	cQuery += "  A1_CGC, "
	cQuery += "  E1_PREFIXO, "
	cQuery += "  E1_NUM, "
	cQuery += "  E1_PARCELA, "
	cQuery += "  E1_TIPO, "
	cQuery += "  E1_NUMBCO, "
	cQuery += "  E1_PORTADO, "
	cQuery += "  E1_SITUACA, "
	cQuery += "  E1_EMISSAO, "
	cQuery += "  E1_VENCREA, "
	cQuery += "  E1_VALOR, "
	cQuery += "  E1_BAIXA, "
	cQuery += "  E1_VALLIQ, "
	cQuery += "  E1_VALJUR, "
	cQuery += "  E1_SALDO, "
	cQuery += "  E1_PEDIDO, "
	// cQuery += "  '  ' AS CAOA_TPLIM " // LISTA DE VALORES ATRAVES DA FUNCAO FCon02
	/*
	 * "AGRUPAR VÁRIAS LINHAS EM APENAS UMA (ORACLE)"
 	 * URL: http://selectspessoais.blogspot.com/2014/08/como-agrupar-varias-linhas-em-apenas.html
	 *
	 * LISTAGG - Presente nos bancos 11g a partir do release 2
	 *  - Separador de strings
	 *  - Indicação do sepador
	 *  - Indicação de ordenação
	 *
	 * XMLELEMENT & XMLAGG - Semelhante a LISTAGG
	 *  - Criar XML através da função XMLELEMENT
	 *  - Extrair texto (campo) do XML e agrupar valores com XMLAGG
	 */
	cQuery += "	 ( SELECT 
	cQuery += "      LISTAGG(C6_XOPER,';') WITHIN GROUP(ORDER BY C6_XOPER DESC) 
	// cQuery += "      RTRIM(XMLAGG(XMLELEMENT(e,C6_XOPER,';').extract('//text()')),';') 
	cQuery += "    FROM ( SELECT C6_XOPER FROM " + RetSqlName("SC6")
	cQuery += "           WHERE 
	cQuery += "             D_E_L_E_T_ = ' ' "
	cQuery += "             AND C6_NUM = E.E1_PEDIDO "
	cQuery += "             AND C6_XOPER IN " + StrTran( FormatIn( cTpLim , ";") , "','')" , "')" ) // REMOVER ULTIMO ITEM VAZIO ==>> "54;91;" == "('54','91')"
	cQuery += "           GROUP BY 
	cQuery += "             C6_XOPER 
	cQuery += "         )
  	cQuery += "  ) AS CAOA_TPLIM 
	cQuery += "FROM " + RetSqlName("SE1") + " E "
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " A ON A.D_E_L_E_T_ = ' ' AND A.A1_COD = E.E1_CLIENTE AND A.A1_LOJA = E.E1_LOJA "
	cQuery += "WHERE "
	cQuery += "  E.D_E_L_E_T_ = ' ' "
	If !lCliLoj
		cQuery += "  AND SUBSTRING(A.A1_CGC,1,8) = '" + cRaizCNPJ + "' "
		cQuery += "  AND A.A1_XDESGRP <> '1' "
	Else
		cQuery += "  AND A.A1_COD = '" + cCodCli + "' "
		cQuery += "  AND A.A1_LOJA = '" + cLojCli + "' "
		// cQuery += "  AND A.A1_LOJA BETWEEN '" + cLojCli + "' AND '" + cLojCliAte + "' "
	EndIf
	cQuery += "ORDER BY "
	cQuery += "  E1_FILIAL,E1_VENCREA DESC,A1_CGC "

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliTit,.F.,.T.)

	TCSetField( cAliTit, "E1_EMISSAO", "D", 8, 0 )
	TCSetField( cAliTit, "E1_VENCREA", "D", 8, 0 )
	TCSetField( cAliTit, "E1_BAIXA"  , "D", 8, 0 )

	Count To nTotal

	If nTotal > 0
		// Limpa o Array
		aSize(aCols,0)

		(cAliTit)->(DbGoTop())

		While !(cAliTit)->(EOF())

			// Totalizadores da Tela - SEM BAIXA (ABERTO OU PARCIALMENTE)
			If (cAliTit)->TIPO_BAIXA != "BX"
				nTotAbto += (cAliTit)->E1_SALDO
				// Totalizar Encargos - TITULO VENCIDO 
				If (cAliTit)->E1_VENCREA < dDataBase
					nTotEnca += (cAliTit)->E1_VALJUR
				EndIf
			EndIf
			// LISTA DE "Tp. Operação"
			// cTipOper := FCon02( (cAliTit)->E1_FILIAL,(cAliTit)->E1_PEDIDO,(cAliTit)->E1_NUM,(cAliTit)->E1_TIPO )
			// -- LISTAGEM OBTIDA VIA FUNCOES SQL ORACLE 11g - LISTAGG, OU, XMLELEMNT & XMLAGG
			cTipOper := PadR( (cAliTit)->CAOA_TPLIM , nTamTpLim) // 12 // 6 TIPOS COM 2 CARACTERES MAIS 6 SEPARADORES (;)

			AAdd(aCols,{ (cAliTit)->TIPO_BAIXA,;
						 (cAliTit)->E1_FILIAL  + " - " + AllTrim(FWFilialName(cEmpAnt,(cAliTit)->E1_FILIAL,1)) ,;
						 (cAliTit)->CODIGLOJA  ,;
						 (cAliTit)->A1_NOME    ,;
						 (cAliTit)->A1_CGC     ,;
						 (cAliTit)->E1_PREFIXO ,;
						 (cAliTit)->E1_NUM     ,;
						 (cAliTit)->E1_PARCELA ,;
						 (cAliTit)->E1_TIPO    ,;
						 (cAliTit)->E1_NUMBCO  ,;
						 (cAliTit)->E1_PORTADO ,;
						 (cAliTit)->E1_SITUACA ,;
						 (cAliTit)->E1_EMISSAO , /* DToC(SToD((cAliTit)->E1_EMISSAO)) */							;
						 (cAliTit)->E1_VENCREA , /* DToC(SToD((cAliTit)->E1_VENCREA)) */							;
						 (cAliTit)->E1_VALOR   , /* Transform(ABS((cAliTit)->E1_VALOR),"@E 999,999,999,999.99") */	;
						 (cAliTit)->E1_BAIXA   , /* DToC(SToD((cAliTit)->E1_BAIXA  )) */							;
						 (cAliTit)->E1_VALLIQ  , /* Transform((cAliTit)->E1_VALLIQ,"@E 999,999,999,999.99") */		;
						 (cAliTit)->E1_VALJUR  , /* Transform((cAliTit)->E1_VALJUR,"@E 999,999,999,999.99") */		;
						 (cAliTit)->E1_SALDO   , /* Transform(ABS((cAliTit)->E1_SALDO),"@E 999,999,999,999.99") */	;
						 (cAliTit)->E1_PEDIDO  ,;
						 /* (cAliTit)->CAOA_TPLIM */ cTipOper } )

			//  Adiciona as Operações de Crédito conforme títulos consultados
			If !Empty( cTipOper ) .AND. !( ";" $ cTipOper ) .AND. !( AllTrim(cTipOper) $ cOperCrd )
				cOperCrd := Iif(!Empty(cOperCrd),";","") + cTipOper
			ElseIf ( ";" $ cTipOper ) .AND. !( AllTrim(cTipOper) $ cOperCrd )
				// LISTAGEM DE "Tp. Operação" (C6_XOPER) == PARAM CAOA_TPLIM
				AScan( StrTokArr( cTipOper ,";") ,{|c6_xOper| IIF( !(c6_xOper $ cOperCrd) , cOperCrd += IIF(!Empty(cOperCrd),";","") + c6_xOper ,) })
			EndIf

			(cAliTit)->(DbSkip())
		EndDo

		// (cAliTit)->(DbGoTop())

		// Totalizadores da Tela
		nTotDocs := nTotAbto + nTotEnca

		// Estancio a Classe CLASCRED - Especifica CAOA
		oClasCrd := CLASCRED():New()

		// nLimCred := oClasCrd:LimiteCredito(cRaizCNPJ,lCliLoj,cCodCli,cLojCli,MV_PAR03,MV_PAR04) /* 6º e 7º params. == Cli.Até e Loj.Até // Params./funcionalidade removida */
		// nLimCred := oClasCrd:LimiteCredito(cRaizCNPJ,lCliLoj,cCodCli,cLojCli)
		nLimCred := oClasCrd:LimiteCredito(lCliLoj,cRaizCNPJ,cCodCli,cLojCli) // VERSAO 2.0

		// Methodo para retornar o valor dos títulos em aberto, cruzando com as operações de limite de crédito no PV - CAOA
		// nValOpCr := oClasCrd:SaldoTitAberto(cRaizCNPJ,cOperCrd,lCliLoj,cCodCli,cLojCli)
		nValOpCr := oClasCrd:SaldoTitAberto(cOperCrd,lCliLoj,cRaizCNPJ,cCodCli,cLojCli) // VERSAO 2.0

		// Methodo para retornar o valor dos RA's e NCC's dos clientes - CAOA
		nValRaNCC := oClasCrd:SaldoTitRANCC(cRaizCNPJ,lCliLoj,cCodCli,cLojCli)

		// VALOR CONSUMIDO - NÃO AMORTIZADO. NÃO DEBITAR TOTAL EM DEVOLUÇÃO (NCC) E ANTECIPAÇÃO (RA)
		// nTotCons := nValOpCr - nValRaNCC
		nTotCons := nValOpCr

		nSaldo	 := nLimCred - nTotCons
	Else
		// Estancio a Classe CLASCRED - Especifica CAOA
		oClasCrd := CLASCRED():New()
		// nLimCred := oClasCrd:LimiteCredito(cRaizCNPJ,lCliLoj,cCodCli,cLojCli,MV_PAR03,MV_PAR04)
		// nLimCred := oClasCrd:LimiteCredito(cRaizCNPJ,lCliLoj,cCodCli,cLojCli)
		nLimCred := oClasCrd:LimiteCredito(lCliLoj,cRaizCNPJ,cCodCli,cLojCli) // VERSAO 2.0
		nSaldo	 := nLimCred

		// Apresenta a tela de consulta, caso o cliente ou Grupo de Cliente tenha crédito, porém não tem títulos
		If nLimCred > 0

			AAdd(aCols , { 	Space(     02        ),;
							Space(TamSx3("E1_FILIAL" )[1] + 03 + Len(AllTrim(FWFilialName(cEmpAnt,cFilAnt,1))) ),              ;
							Space(TamSx3("A1_COD"    )[1] + 03 + TamSx3("A1_LOJA")[1]                          ),              ;
							Space(TamSx3("A1_NOME"   )[1]),;
							Space(TamSx3("A1_CGC"    )[1]),;
							Space(TamSx3("E1_PREFIXO")[1]),;
							Space(TamSx3("E1_NUM"    )[1]),;
							Space(TamSx3("E1_PARCELA")[1]),;
							Space(TamSx3("E1_TIPO"   )[1]),;
							Space(TamSx3("E1_NUMBCO" )[1]),;
							Space(TamSx3("E1_PORTADO")[1]),;
							Space(TamSx3("E1_SITUACA")[1]),;
							Space(TamSx3("E1_EMISSAO")[1]), /* DToC(SToD((cAliTit)->E1_EMISSAO)) */			                	;
							Space(TamSx3("E1_VENCREA")[1]), /* DToC(SToD((cAliTit)->E1_VENCREA)) */			                	;
							000000000000000000000000000000, /* Transform(ABS((cAliTit)->E1_VALOR),"@E 999,999,999,999.99") */	;
							Space(TamSx3("E1_BAIXA"  )[1]), /* DToC(SToD((cAliTit)->E1_BAIXA  )) */								;
							000000000000000000000000000000, /* Transform((cAliTit)->E1_VALLIQ,"@E 999,999,999,999.99") */		;
							000000000000000000000000000000, /* Transform((cAliTit)->E1_VALJUR,"@E 999,999,999,999.99") */		;
							000000000000000000000000000000, /* Transform(ABS((cAliTit)->E1_SALDO),"@E 999,999,999,999.99") */	;
							Space(TamSX3("E1_PEDIDO" )[1]),;
							Space(        02         )   })

		EndIf
	EndIf

	(cAliTit)->(DbCloseArea())
Return( aCols )
