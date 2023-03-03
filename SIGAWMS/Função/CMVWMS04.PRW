#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "WMSA490.CH"          
/*
=====================================================================================
Programa.:              CMVWMS04
Autor....:              Atilio Amarilla
Data.....:              07/05/2019
Descricao / Objetivo:   Integração PROTHEUS - PCP x MES x WMS - Requisição Automática
Doc. Origem:            Contrato - GAP WMS003
Solicitante:            Cliente
Uso......:              CAOA
Obs......:              Requisições para empenhos. Atualização de Local de origem
						Chamado por PE WMSA508LO
=====================================================================================
*/

User Function CMVWMS04()
Local cArquivo := Space(100)
Local nHdlArq
Local cAliasTmp
Local aCampos := {}
Local aDiver := {}
Local aDadosArq := {}
Local oReport
//Local bErroRec :=  .T.
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)

	If !IntWMS()
		MsgInfo(STR0042,STR0003) // O módulo de WMS não está ativo (MV_INTWMS). // Atenção
		Return
	EndIf
	// Validar se data de fechamento < data atual
	If SuperGetMv("MV_ULMES",.F.,"14990101") < dDataBase
		MsgInfo(STR0048,STR0003) // "Efetue o fechamento do mês, importação dos saldos iniciais deve ocorrer na mesma data do fechamento!" // Atenção
		Return
	EndIf
	Msginfo(WmsFmtMsg(STR0036,{{"[VAR01]",Iif(!lWmsNew,"(SB9, SBJ, SBK)","(SB9, SBJ, D13, D14, D15)")}})) // Esse programa tem como objetivo realizar a distribuição nas tabelas de Saldos Iniciais (SB9, SBJ, SBK). Após essa execução é necessário executar a rotina de acerto Saldo Atual.
	Do While .T.
		cArquivo := cGetFile(STR0037+"|*.TxT|", OemToAnsi(OemToAnsi(STR0038)),,,.T. ) // Arquivo Texto (*.txt) // Selecione o Arquivo de Saldos Iniciais
		
		If !Empty(cArquivo) .And. WMSA490VAR(@cArquivo,@nHdlArq)
			Exit
		ElseIf Empty(cArquivo)
			Exit
		EndIf
	EndDo
	If !Empty(cArquivo)
		// Criação dos campos da tabela temporaria
		// Leitura do arquivo texto
		Processa({|| ProcRegua(0), Processa({|| WMSA490TAB(@cAliasTmp,@aCampos) } , STR0028, STR0029,.F.) , WMSA490ARQ(cArquivo,@aDiver,@aDadosArq) }, STR0028, STR0029,.F.) // Aguarde... // Lendo o Arquivo...
		If Len(aDadosArq) > 0
			Processa({|| ProcRegua(0) , WMSA490PRC(aDadosArq) }, STR0028, STR0033,.F.) // Aguarde... // Gerando os Saldos Iniciais...
			If !lWmsNew
				Msginfo(STR0039) // Após a execução dessa rotina deverá ser rodado o programa de acerto de saldo, Miscelânia > Acertos > Saldo Atual.
			Else
				Msginfo(STR0047) // Após a execução dessa rotina deverá ser rodado o programa de acerto de saldo, Miscelânia > Processamentos > Refaz Saldos.
			EndIf
		EndIf	
		If Len(aDiver) > 0
			Processa({|| ProcRegua(0) , Processa({|| cAliasTmp := MntCargDad(cAliasTmp,aDiver,aCampos) } , STR0028, STR0030,.F.) , oReport:= WMSA490REL(aDiver,cAliasTmp) , oReport:PrintDialog() }, STR0028, STR0030,.F.) // Aguarde... // Gerando Relatório de Divergências...
		EndIF
		delTabTmp(cAliasTmp)
	EndIf
Return Nil
//------------------------------------
/*/{Protheus.doc} WMSA490VAR
Validacao do arquivo
@author Felipe Machado de Oliveira 
@version P12
@Since 21/02/14
@obs Valida o arquivo se o mesmo existe no diretorio informado 
/*/
//------------------------------------
Static Function WMSA490VAR(cArquivo,nHdlArq)
Local bErroRec :=  .T.
	
	If Upper(SubStr(AllTrim(cArquivo),Len(AllTrim(cArquivo))-3,Len(AllTrim(cArquivo)))) != ".TXT"
		cArquivo := Upper(AllTrim(cArquivo))+".TXT"
	Else
		cArquivo := AllTrim(cArquivo)
	EndIf
	If !FILE(cArquivo)
		Help(,,STR0003,,STR0004,1,0) // Atencao // Arquivo não existe para o diretorio informado
	   bErroRec :=  .F.
	Else
	   nHdlArq := FOPEN(cArquivo,0)
	   FSEEK(nHdlArq,0,2)
	EndIf
Return .T.
//------------------------------------
/*/{Protheus.doc} WMSA490TAB
Criação da tabela temporaria
@author Felipe Machado de Oliveira 
@version P12
@Since 21/02/14
@obs Criação da tabela temporaria para armazenar os dados do relatorio
/*/
//------------------------------------
Static Function WMSA490TAB(cAliasTmp,aCampos)
	
	Aadd(aCampos,{"INDREC","N",10,0})
	Aadd(aCampos,{"DIVER","C",100,0})
	Aadd(aCampos,{"CONTE","C",100,0})
	
	cAliasTmp := CriaTabTmp(aCampos,{"INDREC"},cAliasTmp)
Return Nil
//------------------------------------
/*/{Protheus.doc} WMSA490ARQ
Leitura e validação do arquivo
@author Felipe Machado de Oliveira 
@version P12
@Since 21/02/14
@obs Leitura e validaçao do conteudo do arquivo
/*/
//------------------------------------
Static Function WMSA490ARQ(cArquivo,aDiver,aDadosArq)
Local lRet      := .T.
Local nRecno    := 0
Local aLinha    := {}
Local cLinha    := ""
Local cAliasQry := Nil
Local cEmpresa  := ""
Local cEmpAntc  := ""
Local cFilantc  := ""
Local cEstFis   := ""
Local cTipUni   := ""
Local cLinhaAux := ""
Local cFilArq   := ""
Local cLocal    := ""
Local cProduto  := ""
Local cEndereco := ""
Local cLote     := ""
Local cSubLote  := ""
Local nTotRec   := 0
Local nNorma    := 0
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local nQatu     := 0
Local dDatValid := CtoD("  /  /    ")
Local cNumSerie := ""
Local nCusUni   := 0
Local cPrdOri   := ""
Local lRastro   := SuperGetMv("MV_RASTRO",.F.,"N") == "S"
Local oMntUniItem := Nil
Local cFilAtual   := cFilAnt
Local cEmpAtual   := cEmpAnt
Local bErroRec    := .F.
Local cArqFinal   := ''
	
	FT_FUse(cArquivo)
	FT_FGoTop()
	
	If lRet
		aDiver := {}
		Do While (!FT_FEOF())
			cLinha := FT_FReadLn()
			lRet     := .T.
			bErroRec := .T.
			nRecno++
			
			If !Empty(cLinha)
				cLinhaAux := StrTran(cLinha,";")
				If (Len(cLinhaAux) != (Len(cLinha) - 11)) .And. (Len(cLinhaAux) != (Len(cLinha) - 12))
					bErroRec := .F.
					MsgAlert(STR0040+AllTrim(Str(nRecno)),STR0003) // Arquivo inconsistente! Existem informações a menos ou a mais na linha:  // Atenção
				EndIf
			EndIf
			
			If lRet .And. !Empty(cLinha)
				cEstFis   := ""
				cTipUni   := ""
				aLinha    := Separa(cLinha,';')
				cEmpresa  := PadR(aLinha[1],Len(FWGrpCompany()))  //PadR(aLinha[1],TamSx3("B9_FILIAL")[1])  // Filial
				cFilArq   := PadR(aLinha[2],TamSx3("B9_FILIAL")[1])  // Filial
				cLocal    := PadR(aLinha[3],TamSx3("B9_LOCAL")[1])   // Armazem
				cProduto  := PadR(aLinha[4],TamSx3("B9_COD")[1])     // Codigo do produto
				nQatu     := Val(aLinha[5])                          // Quantidade
				cEndereco := PadR(aLinha[6],TamSx3("BK_LOCALIZ")[1]) // Endereço
				cLote     := PadR(aLinha[7],TamSx3("BJ_LOTECTL")[1]) // Lote
				cSubLote  := PadR(aLinha[8],TamSx3("BJ_NUMLOTE")[1]) // Sub-Lote
				dDatValid := aLinha[9]                               // Data de Validade
				cNumSerie := PadR(aLinha[10],TamSx3("BK_NUMSERI")[1]) // Numero de serie
				cPrdOri   := PadR(aLinha[11],TamSx3("D11_PRODUT")[1])// Produto Origem
				nCusUni   := aLinha[12]                              // Custo
				cIdUnit   := PadR(aLinha[13],TamSx3("D14_IDUNIT")[1])// Identificador Unitizador
				
				If Empty(cEmpresa)
					aAdd(aDiver,{nRecno,"Empresa não informada",cEmpresa}) // Empresa não informada.
					bErroRec :=  .F.
				EndIf
				
				If Empty(cFilArq)
					aAdd(aDiver,{nRecno,STR0032,cFilArq}) // Filial não informada.
					bErroRec :=  .F.
				Else
					If WMSA490VFL(cFilArq,cEmpresa)
						aAdd(aDiver,{nRecno,STR0005,cFilArq}) // Filial não encontrada.
						bErroRec :=  .F.
					EndIf
				EndIf
				//validação para logar no sistema com empresa e filial para atualiza o xFilial.
				If (cEmpAntc == " ") .OR. (cEmpAntc <> cEmpresa) .OR. (cFilArq == " ") .OR. (cFilantc <> cFilarq)
					RpcSetEnv(cEmpresa,cFilArq, , ,"WMS", )
				Endif
				cEmpAntc := cEmpresa
				cFilantc := cFilarq
				
				If Empty(cLocal)
					aAdd(aDiver,{nRecno,STR0006,cLocal}) // Armazém não informado.
					bErroRec :=  .F.
				Else
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT 1
						FROM %Table:NNR% NNR
						WHERE NNR.NNR_FILIAL = %xFilial:NNR%
						AND NNR.NNR_CODIGO = %Exp:cLocal%
						AND NNR.%NotDel%
					EndSql
					If (cAliasQry)->(Eof())
						aAdd(aDiver,{nRecno,STR0007,cLocal}) // Armazém não cadastrado no NNR.
						bErroRec :=  .F.
					EndIf
					(cAliasQry)->(dbCloseArea())
				EndIf
				If Empty(cProduto)
					aAdd(aDiver,{nRecno,STR0008,cProduto}) // Produto não informado.
					bErroRec :=  .F.
				Else
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT SB1.B1_COD,
								SB1.B1_RASTRO
						FROM %Table:SB1% SB1
						WHERE SB1.B1_FILIAL = %xFilial:SB1%
						AND SB1.B1_COD = %Exp:cProduto%
						AND SB1.%NotDel%
					EndSql
					If (cAliasQry)->(Eof())
						aAdd(aDiver,{nRecno,STR0009,cProduto}) // Produto não cadastrado no SB1.
						bErroRec :=  .F.
					Else
						If !IntWMS((cAliasQry)->B1_COD)
							aAdd(aDiver,{nRecno,STR0010,cEndereco}) // Produto sem controle WMS.
							bErroRec :=  .F.
						EndIf
						If !Empty(cLote) .And. !(cAliasQry)->B1_RASTRO $ "LS"
							aAdd(aDiver,{nRecno,STR0013,cLote}) // Produto sem controle de lote
							bErroRec :=  .F.
						EndIf
						If (cAliasQry)->B1_RASTRO == "L" .And. Empty(cLote)
							aAdd(aDiver,{nRecno,STR0034,cLote}) // Lote não informado.
							bErroRec :=  .F.
						EndIf
						If (cAliasQry)->B1_RASTRO == "S" .And. (Empty(cLote) .Or. Empty(cSubLote))
							aAdd(aDiver,{nRecno,STR0035,cLote+";"+cSubLote}) // Lote e Sub-Lote devem ser informados.
							bErroRec :=  .F.
						EndIf
						If !Empty(cLote) .And. !lRastro
							aAdd(aDiver,{nRecno,STR0014,"N"}) // O parametro MV_RASTRO nao esta correto
							bErroRec :=  .F.
						EndIf
					EndIf
					(cAliasQry)->(dbCloseArea())
				Endif
				If Empty(cEndereco)
					aAdd(aDiver,{nRecno,STR0019,cEndereco}) // Endereço não informado.
					bErroRec :=  .F.
				Else
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT SBE.BE_ESTFIS
						FROM %Table:SBE% SBE
						WHERE SBE.BE_FILIAL = %xFilial:SBE%
						AND SBE.BE_LOCAL = %Exp:cLocal%
						AND SBE.BE_LOCALIZ = %Exp:cEndereco%
						AND SBE.%NotDel%
					EndSql
					If (cAliasQry)->(!Eof())
						cEstFis := (cAliasQry)->BE_ESTFIS
					Else
						aAdd(aDiver,{nRecno,STR0020,cEndereco}) // Endereço não cadastrado na SBE.
						bErroRec :=  .F.
					EndIf
					(cAliasQry)->(dbCloseArea())
				Endif
				If nQatu == 0
					aAdd(aDiver,{nRecno,STR0017,"0"}) // Quantidade deve ser maior que zero.
					bErroRec :=  .F.
				Else
					nNorma := DLQtdNorma(cProduto,cLocal,cEstFis,,,cEndereco,,)
					If nQatu > nNorma
						aAdd(aDiver,{nRecno, STR0041 + AllTrim(Str(nNorma)) ,AllTrim(str(nQatu))}) // Quantidade maior que a norma do endereço. Norma:
						bErroRec :=  .F.
					EndIf
				Endif
				If !Empty(cLote) .And. Empty(dDatValid)
					aAdd(aDiver,{nRecno,STR0018,dDatValid}) // Data de validade não informada.
					bErroRec :=  .F.
				EndIf
				cAliasQry := GetNextAlias()
				If lWmsNew
					BeginSql Alias cAliasQry
						SELECT COUNT(*) AS TOTRECNO
						FROM %Table:D14% D14
						WHERE D14.D14_FILIAL = %xFilial:D14%
						AND D14.D14_LOCAL = %Exp:cLocal%
						AND D14.D14_PRODUT = %Exp:cProduto%
						AND D14.D14_ENDER = %Exp:cEndereco%
						AND D14.D14_QTDEST >= 0
						AND D14.%NotDel%
					EndSql
				Else
					BeginSql Alias cAliasQry
						SELECT COUNT(*) AS TOTRECNO
						FROM %Table:SBF% SBF
						WHERE SBF.BF_FILIAL = %xFilial:SBF%
						AND SBF.BF_LOCAL = %Exp:cLocal%
						AND SBF.BF_PRODUTO = %Exp:cProduto%
						AND SBF.BF_LOCALIZ = %Exp:cEndereco%
						AND SBF.BF_QUANT >= 0
						AND SBF.%NotDel%
					EndSql
				EndIf
				If (cAliasQry)->(!Eof())
					nTotRec := (cAliasQry)->TOTRECNO
					If nTotRec > 0
						aAdd(aDiver,{nRecno,WmsFmtMsg(STR0023,{{"[VAR01]",IIf(!lWmsNew,"SBF","D14")}}),cEndereco}) // Ja existe saldo por endereco [VAR01].
						bErroRec :=  .F.     
					Endif
				EndIf
				(cAliasQry)->(dbCloseArea())
				
				If lWmsNew
					If Empty(cPrdOri)
						aAdd(aDiver,{nRecno,STR0043,cPrdOri}) // Produto Origem não informado.
						bErroRec :=  .F.
					Else
						If cPrdOri != cProduto
							cAliasQry := GetNextAlias()
							BeginSql Alias cAliasQry
								SELECT 1
								FROM %Table:D11% D11
								WHERE D11.D11_FILIAL = %xFilial:SBE%
								AND D11.D11_PRDORI = %Exp:cPrdOri%
								AND D11.%NotDel%
							EndSql
							If (cAliasQry)->(Eof())
								aAdd(aDiver,{nRecno,STR0044,cPrdOri}) // Produto Origem não cadastrado no D11.
								bErroRec :=  .F.
							Else
								(cAliasQry)->(dbCloseArea())
								cAliasQry := GetNextAlias()
								BeginSql Alias cAliasQry
									SELECT 1
									FROM %Table:D11% D11
									WHERE D11.D11_FILIAL = %xFilial:D11%
									AND D11.D11_PRDORI = %Exp:cPrdOri%
									AND D11.D11_PRDCMP = %Exp:cProduto%
									AND D11.%NotDel%
								EndSql
								If (cAliasQry)->(Eof())
									aAdd(aDiver,{nRecno,WmsFmtMsg(STR0045,{{"[VAR01]",cProduto}}),cPrdOri}) // Produto Origem não é origem do produto [VAR01].
									bErroRec :=  .F.
								EndIf
								(cAliasQry)->(dbCloseArea())
							EndIf
						Else
							cAliasQry := GetNextAlias()
							BeginSql Alias cAliasQry
								SELECT 1
								FROM %Table:D11% D11
								WHERE D11.D11_FILIAL = %xFilial:D11%
								AND D11.D11_PRODUT = %Exp:cProduto%
								AND D11.%NotDel%
							EndSql
							If (cAliasQry)->(!Eof())
								aAdd(aDiver,{nRecno,WmsFmtMsg(STR0046,{{"[VAR01]",cProduto}}),cProduto}) // "Produto [VAR01] possui estrutura, informe os seus componentes."								                              
								bErroRec :=  .F.
							EndIf
							(cAliasQry)->(dbCloseArea())
						EndIf
					Endif
					//Se utiliza o WMS novo validar o unitizador
					If !Empty(cIdUnit)
						If oMntUniItem == Nil
							oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
						Else
							oMntUniItem:ClearData()
						EndIf
						If !WmsEndUnit(cLocal,cEndereco)
							aAdd(aDiver,{nRecno,WmsFmtMsg("Produto [VAR01] possui estrutura, informe os seus componentes.",{{"[VAR01]",cLocal}}),cEndereco}) // "Produto [VAR01] possui estrutura, informe os seus componentes."
							bErroRec :=  .F.
						EndIf
						oMntUniItem:oUnitiz:SetIdUnit(cIdUnit)
						oMntUniItem:oUnitiz:SetArmazem(cLocal)
						oMntUniItem:oUnitiz:SetEnder(cEndereco)
						oMntUniItem:oUnitiz:oEtiqUnit:LoadData()
						oMntUniItem:SetUsaD0Q(.F.)
						If Empty(oMntUniItem:oUnitiz:oTipUnit:GetTipUni())
							oMntUniItem:oUnitiz:oTipUnit:FindPadrao()
						EndIf
						cTipUni := oMntUniItem:oUnitiz:oTipUnit:GetTipUni()
						If !oMntUniItem:VldIdUnit(5,@cTipUni,.F.)
							aAdd(aDiver,{nRecno,AllTrim(oMntUniItem:GetErro()),cIdUnit}) // "Erro de validação de unitizador"
							bErroRec :=  .F.
						EndIf
					Endif
				EndIf
				If !bErroRec
				     cArqFinal   += cLinha + CRLF
				Else
					// Ajusta lote e sublote
					//Incluso nesta parte do programa o comando DBSelectArea para nao correr problemas na funcao Rastro do programa SIGACUSA
					DbSelectArea("SB1")
					If !Rastro(cProduto)
						cLote     := Space(TamSx3("D15_LOTECT")[1])
						dDatValid := CtoD("  /  /    ")
						If !Rastro(cProduto,"S")
							cSubLote  := Space(TamSx3("D15_NUMLOT")[1])
						EndIf
					Else
						cNumSerie := Space(TamSx3("D15_NUMSER")[1])
						dDatValid := CtoD(dDatValid)
					EndIf
				
					aAdd(aDadosArq, {cEmpresa,;      // [01] Empresa
										cFilArq,;    // [02] Filia de referência do Protheus
										cLocal,;     // [03] Almoxarifado
										cProduto,;   // [04] Codigo do Produto
										nQatu,;      // [05] Quantidade
										cEndereco,;  // [06] Endereco Armazenado
										cLote,;      // [07] Lote
										cSubLote,;   // [08] Sub-Lote
										dDatValid,;  // [09] Validade do Lote
										cNumSerie,;  // [10] Numero de serie
										cPrdOri,;    // [11] Produto Origem
										nCusUni,;    // [12] Custo unitario do produto
										cIdUnit,;    // [13] Identificador do unitizador
										cTipUni})    // [14] Identificador do unitizador
				EndIf
			EndIf
			FT_FSkip()
		EndDo
	EndIf
	//Apos finalizar a importação logar no sistema novamente com a empresa que acessou o programa
	If (cEmpresa == " ") .OR. (cEmpresa <> cEmpAtual) .OR. (cFilArq == " ") .OR. (cFilAtual <> cFilarq)
		RpcSetEnv(cEmpAtual,cFilAtual, , ,"WMS", )
	Endif
	FT_FUse()
	MemoWrite("c:\temp\WMS_COMPL.txt",cArqFinal)
Return lRet
//------------------------------------
/*/{Protheus.doc} WMSA490VFL()
Validação da Filial
@author Felipe Machado de Oliveira 
@version P12
@Since 21/02/14
@obs Realiza a validação da Filial informada no arquivo
/*/
//------------------------------------
Static Function WMSA490VFL(cFil,cEmpresa)
Local aAreaSM0
Local bErroRec :=  .T.
	
	dbSelectArea("SM0")
	aAreaSM0 := SM0->( GetArea() )
	SM0->( dbSetOrder(1) )
	SM0->( dbSeek(cEmpresa) )
	Do While SM0->( !EOF() ) .And. (AllTrim(SM0->M0_CODIGO) == AllTrim(cEmpresa))
		If !SM0->( Deleted() )
			If AllTrim(cFil) == AllTrim(SM0->M0_CODFIL)
				bErroRec :=  .F.
			EndIf
		EndIf
		SM0->( dbSkip() )
	EndDo
	RestArea(aAreaSM0)
Return bErroRec
//------------------------------------
/*/{Protheus.doc} WMSA490REL()
Geração do relatório com as divergências
@author Felipe Machado de Oliveira 
@version P12
@Since 21/02/14
@obs Realiza um relatório com base nos dados da tabela temporária
/*/
//------------------------------------
Static Function WMSA490REL(aDiver,cAliasTmp)
Local cTitle := OemToAnsi(STR0024) // Divergências Carga Inicial
Local oReport
Local oSection
	// Criacao do componente de impressao
	oReport := TReport():New('WMSA490',cTitle,,{|oReport| ReportPrint(oReport,cAliasTmp)},cTitle)
	oSection := TRSection():New(oReport,STR0025,{cAliasTmp},) // Divergência
	
	TRCell():New(oSection,"INDREC",cAliasTmp,STR0026) // Linha
	TRCell():New(oSection,"DIVER",cAliasTmp,STR0031)  // Mensagem
	TRCell():New(oSection,"CONTE",cAliasTmp,STR0027)  // Conteudo
Return oReport
//------------------------------------
/*/{Protheus.doc} ReportPrint()
Impressão do relatório
@author Felipe Machado de Oliveira 
@version P12
@Since 21/02/14
@obs Impressão do relatório
/*/
//------------------------------------
Static Function ReportPrint(oReport,cAliasTmp)
Local oSection1 := oReport:Section(1)
	
	MakeSqlExpr(oReport:GetParam())
	
	oReport:SetMeter((cAliasTmp)->(RecCount()))
	dbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbSetOrder(1))
	(cAliasTmp)->(dbGoTop())
	
	oSection1:Init()
	oSection1:Cell("INDREC"):SetSize(4)
	oSection1:Cell("DIVER"):SetSize(60)
	oSection1:Cell("CONTE"):SetSize(20)
	
	Do While !oReport:Cancel() .And. !(cAliasTmp)->(Eof())
		oSection1:Cell("INDREC"):Show()
		oSection1:Cell("DIVER"):Show()
		oSection1:Cell("CONTE"):Show()
	
		oSection1:PrintLine()
		oReport:SkipLine()
		
		(cAliasTmp)->(dbSkip())
	EndDo
	oSection1:Finish()
Return Nil
//------------------------------------
/*/{Protheus.doc} ReportPrint()
Processamento dos dados
@author Felipe Machado de Oliveira 
@version P12
@Since 21/02/14
@obs Realiza a carga dos saldos nas tabelas envolvidas
/*/
//------------------------------------
Static Function WMSA490PRC(aDadosArq)
Local lWmsNew    := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local oMovEstEnd := IIf(lWmsNew,WMSDTCMovimentosEstoqueEndereco():New(),Nil)
Local oEstEnder  := IIf(lWmsNew,WMSDTCEstoqueEndereco():New(),Nil)
Local lProcess   := .F.
Local nI         := 0
Local cEmpresa   := ""
Local cFilArq    := ""
Local cLocal     := ""
Local cProduto   := ""
Local cIdUnit    := ""
Local cTipUni    := ""
Local nQatu      := 0
Local cEndereco  := ""
Local cLote      := ""
Local cSubLote   := ""
Local dDatValid  := CtoD("  /  /    ")
Local cNumSerie  := ""
Local nCusUni    := 0
Local cPrdOri    := ""
Local cAliasQry  := Nil
Local dData      := DTOS(dDataBase)

	Begin Transaction
		For nI := 1 To Len(aDadosArq)
			cEmpresa  := aDadosArq[nI][1]  // Filia de referência do Protheus
			cFilArq   := aDadosArq[nI][2]  // Filia de referência do Protheus
			cLocal    := aDadosArq[nI][3]  // Almoxarifado
			cProduto  := aDadosArq[nI][4]  // Codigo do Produto
			nQatu     := aDadosArq[nI][5]  // Quantidade
			cEndereco := aDadosArq[nI][6]  // Endereco Armazenado
			cLote     := aDadosArq[nI][7]  // Lote
			cSubLote  := aDadosArq[nI][8]  // Sub-Lote
			dDatValid := aDadosArq[nI][9]  // Data de Validade
			cNumSerie := aDadosArq[nI][10]  // Numero de serie
			cPrdOri   := aDadosArq[nI][11] // Produto Origem
			nCusUni   := aDadosArq[nI][12] // Custo unitario do produto
			cIdUnit   := aDadosArq[nI][13] // Identificador do unitizador
			cTipUni   := aDadosArq[nI][14] // Tipo do unitizador
			// Processo
			If !lWmsNew
				// Se o produto tiver controle de endereçamento , gerar um registro
				// na tabela de Saldos Iniciais por Endereco (SBK), 
				// verificar a chave: BK_FILIAL+BK_COD+BK_LOCAL+BK_LOTECTL+BK_NUMLOTE+ BK_LOCALIZ+BK_NUMSERI+DTOS(BK_DATA), 
				// quando ja existir, devera somente incrementar os campos de quantidade:
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT SBK.R_E_C_N_O_ RECNOSBK
					FROM %Table:SBK% SBK
					WHERE SBK.BK_FILIAL = %xFilial:SBK%
					AND SBK.BK_COD = %Exp:cProduto%
					AND SBK.BK_LOCAL = %Exp:cLocal%
					AND SBK.BK_LOTECTL = %Exp:cLote%
					AND SBK.BK_NUMLOTE = %Exp:cSubLote%
					AND SBK.BK_LOCALIZ = %Exp:cEndereco%
					AND SBK.BK_NUMSERI = %Exp:cNumSerie%
					AND SBK.%NotDel%
				EndSql
				If (cAliasQry)->(!Eof())
					SBK->(dbGoTo((cAliasQry)->RECNOSBK))
					RecLock("SBK",.F.)
					SBK->BK_QINI	+= nQatu
					SBK->BK_QISEGUM	+= ConvUM(cProduto,nQatu,0,2)
					SBK->(MsUnLock())
				Else
					RecLock("SBK",.T.)
					SBK->BK_FILIAL	:= xFilial('SBK')
					SBK->BK_COD		:= cProduto
					SBK->BK_LOCAL	:= cLocal
					SBK->BK_DATA	:= dDataBase
					SBK->BK_LOTECTL	:= cLote
					SBK->BK_NUMLOTE	:= cSubLote
					SBK->BK_LOCALIZ	:= cEndereco
					SBK->BK_NUMSERI	:= cNumSerie
					SBK->BK_QINI	:= nQatu
					SBK->BK_QISEGUM	:= ConvUM(cProduto,nQatu,0,2)
					SBK->(MsUnLock())
				EndIf
				(cAliasQry)->(dbCloseArea())
			Else
				// Considera a tabela de saldos iniciais D15 quando o novo wms está ativo
				// Carrega dados para Estoque por Endereço
				oEstEnder:oEndereco:SetArmazem(cLocal)
				oEstEnder:oEndereco:SetEnder(cEndereco)
				oEstEnder:oProdLote:SetArmazem(cLocal)   // Armazem
				oEstEnder:oProdLote:SetPrdOri(cPrdOri)   // Produto Origem
				oEstEnder:oProdLote:SetProduto(cProduto) // Componente
				oEstEnder:oProdLote:SetLoteCtl(cLote)    // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote(cSubLote) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumSer(cNumSerie) // Numero de serie
				oEstEnder:SetIdUnit(cIdUnit)
				oEstEnder:SetTipUni(cTipUni)
				oEstEnder:oProdLote:SetDtValid(dDatValid)
				oEstEnder:SetQuant(QtdComp(nQatu))
				// Seta o bloco de código para informações do documento
				oEstEnder:SetBlkDoc({|oMovEstEnd|})
				// Realiza Entrada Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('499',.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
				lProcess := .T.
			EndIf	
		Next nI
		If lWmsNew
			// Apenas quando é novo WMS, ajusta o array aDadosArq transformando os produtos 
			// filhos no produto pai para atualização do SB9 e SBJ.
			RefazArray(@aDadosArq)
		EndIf
		
		For nI := 1 To Len(aDadosArq)
			cEmpresa  := aDadosArq[nI][1]  // Empresa do Protheus
			cFilArq   := aDadosArq[nI][2]  // Filia de referência do Protheus
			cLocal    := aDadosArq[nI][3]  // Almoxarifado
			cProduto  := aDadosArq[nI][4]  // Codigo do Produto
			nQatu     := aDadosArq[nI][5]  // Quantidade
			cEndereco := aDadosArq[nI][6]  // Endereco Armazenado
			cLote     := aDadosArq[nI][7]  // Lote
			cSubLote  := aDadosArq[nI][8]  // Sub-Lote
			dDatValid := aDadosArq[nI][9]  // Data de Validade
			cNumSerie := aDadosArq[nI][10] // Numero de serie
			cPrdOri   := aDadosArq[nI][11] // Produto Origem
			nCusUni   := aDadosArq[nI][12] // Custo unitario do produto
			cIdUnit   := aDadosArq[nI][13] // Identificador do unitizador
			cTipUni   := aDadosArq[nI][14] // Identificador do unitizador
			// Para cada linha de dados gerar um registro na tabela de Saldos Iniciais (SB9), 
			// verificar a chave: B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA), quando ja existir,
			// devera somente incrementar os campos de quantidade e custo:
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT SB9.R_E_C_N_O_ RECNOSB9
				FROM %Table:SB9% SB9
				WHERE SB9.B9_FILIAL = %xFilial:SB9%
				AND SB9.B9_COD = %Exp:cProduto%
				AND SB9.B9_LOCAL = %Exp:cLocal%
				AND SB9.B9_DATA = %Exp:dData%
				AND SB9.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				SB9->(dbGoTo((cAliasQry)->RECNOSB9))
				RecLock("SB9",.F.)
				SB9->B9_QINI     += nQatu
				SB9->B9_QISEGUM  += ConvUM(cProduto,nQatu,0,2)
				SB9->B9_VINI1    := (Val(nCusUni) * SB9->B9_QINI)
				SB9->B9_CM1      := Val(nCusUni)
				SB9->(MsUnLock())
			Else
				RecLock("SB9",.T.)
				SB9->B9_FILIAL    := xFilial('SB9') 
				SB9->B9_COD       := cProduto
				SB9->B9_LOCAL     := cLocal
				SB9->B9_DATA      := dDataBase
				SB9->B9_QINI      := nQatu
				SB9->B9_QISEGUM   := ConvUM(cProduto,nQatu,0,2)
				SB9->B9_VINI1     := (Val(nCusUni) * nQatu)
				SB9->B9_CM1       := Val(nCusUni)
				SB9->(MsUnLock())
			EndIf
			(cAliasQry)->(dbCloseArea())
			// Se o produto tiver controle de rastreabilidade (usar a funcao RASTRO(cProduto)),
			// gerar um registro na tabela de Saldos por Lote (SBJ),
			// verificar a chave: BJ_FILIAL+BJ_COD+BJ_LOCAL+BJ_LOTECTL+BJ_NUMLOTE+DTOS(BJ_DATA),
			// quando ja existir, devera somente incrementar os campos de quantidade:
			If Rastro(cProduto)
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT SBJ.R_E_C_N_O_ RECNOSBJ
					FROM %Table:SBJ% SBJ
					WHERE SBJ.BJ_FILIAL = %xFilial:SBJ%
					AND SBJ.BJ_COD = %Exp:cProduto%
					AND SBJ.BJ_LOCAL = %Exp:cLocal%
					AND SBJ.BJ_LOTECTL = %Exp:cLote%
					AND SBJ.BJ_NUMLOTE = %Exp:cSubLote%
					AND SBJ.BJ_DATA = %Exp:dData%
					AND SBJ.%NotDel%
				EndSql
				If (cAliasQry)->(!Eof())
					SBK->(dbGoTo((cAliasQry)->RECNOSBJ))
					RecLock("SBJ",.F.)
					SBJ->BJ_QINI    += nQatu
					SBJ->BJ_QISEGUM	+= ConvUM(cProduto,nQatu,0,2)
					SBJ->(MsUnLock())
				Else
					RecLock("SBJ",.T.)
					SBJ->BJ_FILIAL	:= xFilial('SBJ') 
					SBJ->BJ_COD		:= cProduto
					SBJ->BJ_LOCAL	:= cLocal
					SBJ->BJ_DATA	:= dDataBase
					SBJ->BJ_LOTECTL	:= cLote
					SBJ->BJ_NUMLOTE	:= cSubLote
					SBJ->BJ_DTVALID	:= dDatValid
					SBJ->BJ_QINI	:= nQatu
					SBJ->BJ_QISEGUM	:= ConvUM(cProduto,nQatu,0,2)
					SBJ->(MsUnLock())
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
		Next nI
		If lProcess .And. lWmsNew
			oMovEstEnd:SetUlMes(dDataBase-1)
			oMovEstEnd:SetDatFech(dDataBase)
			oMovEstEnd:WmsFechto()
		EndIf
	End Transaction
Return Nil

Static Function RefazArray(aDadosArq)
Local oProdComp  := WMSDTCProdutoComponente():New()
Local nI         := 0
Local cEmpresa   := ""
Local cFilArq    := ""
Local cLocal     := ""
Local cProduto   := ""
Local cIdUnit    := ""
Local nQatu      := 0
Local cEndereco  := ""
Local cLote      := ""
Local cSubLote   := ""
Local dDatValid  := CtoD("  /  /    ")
Local cNumSerie  := ""
Local nCusUni    := 0
Local cPrdOri    := ""
Local nQtdMult   := 0
Local nPos       := 0
	
	For nI := 1 To Len(aDadosArq)
		cEmpresa  := aDadosArq[nI][1]  // Empresa do Protheus
		cFilArq   := aDadosArq[nI][2]  // Filia de referência do Protheus
		cLocal    := aDadosArq[nI][3]  // Almoxarifado
		cProduto  := aDadosArq[nI][4]  // Codigo do Produto
		nQatu     := aDadosArq[nI][5]  // Quantidade
		cEndereco := aDadosArq[nI][6]  // Endereco Armazenado
		cLote     := aDadosArq[nI][7]  // Lote
		cSubLote  := aDadosArq[nI][8]  // Sub-Lote
		dDatValid := aDadosArq[nI][9]  // Data de Validade
		cNumSerie := aDadosArq[nI][10]  // Numero de serie
		cPrdOri   := aDadosArq[nI][11] // Produto Origem
		nCusUni   := aDadosArq[nI][12] // Custo unitario do produto
		cIdUnit   := aDadosArq[nI][13] // Identificador do unitizador
		cTipUni   := aDadosArq[nI][14] // Identificador do unitizador
		// Caso produto seja diferente do produto origem
		If cProduto != cPrdOri
			oProdComp:SetPrdCmp(cProduto)
			If oProdComp:LoadData(2)
				nQtdMult := oProdComp:GetQtMult()
				nQatu := (nQatu / nQtdMult)				
				nPos := aScan(aDadosArq,{|x| cFilArq+cLocal+cPrdOri+cPrdOri+cLote+cSubLote+cNumSerie == x[2]+x[3]+x[4]+x[11]+x[7]+x[8]+x[10]})
				If nPos > 0
					// Considera o menor saldo do produto filho para definir o saldo do pai
					If aDadosArq[nPos][5] > nQatu
						aDadosArq[nPos][5] := nQatu
					EndIf
					// Soma o custo do filho para definir o custo do pai
					aDadosArq[nPos][12] := cValToChar(val(aDadosArq[nPos][12])+ Val(nCusUni))
				Else
					// Cria o produto pai no arquivo aDadosArq
					aAdd(aDadosArq,{cEmpresa,cFilArq,cLocal,cPrdOri,nQatu,""/*cEndereco*/,cLote,cSubLote,dDatValid,cNumSerie,cPrdOri,nCusUni,cIdUnit,cTipUni})
				EndIf				
				// Apaga o produto filho do array aDadosArq
				aDel(aDadosArq, nI)
				aSize(aDadosArq,Len(aDadosArq)-1)
				nI--
			EndIf
		EndIf
		If nI == Len(aDadosArq)
			Exit
		EndIf
	Next nI
Return
