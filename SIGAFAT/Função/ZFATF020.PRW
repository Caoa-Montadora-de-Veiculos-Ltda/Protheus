#Include "Protheus.Ch"
#Include "Mata103.Ch"

/*/{Protheus.doc} ZFATF020
//Devolução de Notas Fiscais
@author Leonardo Miranda
@since 16/02/2023
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, Alias da tabela corrente
@param nReg, numeric, recno do registro
@param nOpcx, numeric, opcao selecionada
@type function
/*/

*****************************************
User Function ZFATF020(cAlias,nReg,nOpcx)
*****************************************

Local oTmpTable
Local aFieldView:= {}
Local aColsMB	:= {}
Local dDataDe	:= stod("")
Local dDataAte	:= stod("")
Local cCliente	:= ""
Local cLoja		:= ""
Local cAliasTRB	:= ""
Local cAliasQRY	:= ""
Local cQuery	:= ""
Local cDocSF2	:= ""
Local lCliente	:= .F.
Local lFilCliFor:= .T.
Local lAllCliFor:= .T.
Local lDocVincul:= .F.
Local lFlagDev	:= SuperGetMv("MV_FLAGDEV",.F.,.F.)
Public lGerPVDev := .F.
Public lBlqNSer  := .F.

Private lLoop	:= .T.
Private lFirst  := .T.

If INCLUI

	cCliente := CriaVar("F2_CLIENTE",.F.)
	cLoja := CriaVar("F2_LOJA",.F.)

	// tela de selecao de filtros
	If A103FRet(@lCliente,@dDataDe,@dDataAte,@lFilCliFor,@lAllCliFor,@lDocVincul,@cCliente,@cLoja)
	
		// define os campos a serem apresentadas no browse
		aFieldView := A103FldBrw(lCliente,lDocVincul)

		//
		// abre uma query com os filtros selecionados
		//

	While lLoop
		lLoop := .F.
		cDocSF2 := ""
		cAliasQRY := A103QryNF(lDocVincul, cCliente, cLoja, dDataDe, dDataAte, lFilCliFor, lAllCliFor, lFlagDev,@cQuery)
		If Empty((cAliasQRY)->F2_DOC) 
			If  lFirst
				Help("",1,"A103NDOCDEV",,STR0513,1,0) //"Não foi encontrado documentos de acordo com filtro informado"
			EndIf	
		Else
			// definir a estrutura da tabela temporia baseada no SX3
			aStrTMP := A103DFldQ(cAliasQRY)

			// definir os indices baseado na tabela principal a query
			aIdxTMP := A103DIdxQ(lCliente, lDocVincul)
			
			// cria a tabela temporaria
			cAliasTRB := A103NewTMP(@oTmpTable,aStrTMP,aIdxTMP)
			If Empty(cAliasTRB)
				Help("",1,"A103NDOCDEV",,STR0513,1,0) //"Não foi encontrado documentos de acordo com filtro informado"
			Else
				// insiro os registros da Query na tabela temporaria

				Processa({|| SqlToTrb(cQuery, aStrTMP, cAliasTRB)})

				// definicao das colunas da markbrowse
				aColsMB := MontColMb(aFieldView,aStrTMP)
			
				// definicao dos indices markbrowse
				aIdxMB := MontIdxMb(aIdxTMP ,aStrTMP)
			
				// por cliente/fornecedor - TBrowse	
				If lCliente
					nOpcao := ZWndBrwMrk( STR0099+" - "+AllTrim(RetTitle("F2_CLIENTE"))+" / "+AllTrim(RetTitle("F1_FORNECE")) ,cAliasTRB ,lCliente ,aIdxMB ,aColsMB ,,lCliente,lDocVincul )
				
				// por documento - MaWndBrowse
				Else
					nOpcao := ZWndBrwMrk( STR0099+" - "+STR0184 ,cAliasTRB ,.T.,aIdxMB ,aColsMB ,,lCliente )
				EndIf

				// executa loop da temporaria e executa as marcadas
				If nOpcao == 1
					(cAliasTRB)->(dbGoTop())
					While (cAliasTRB)->(!Eof())
						If !Empty((cAliasTRB)->TRB_OK)
							dbSelectArea("SF2")
							dbSetOrder(1)
							If dbSeek(xFilial("SF2")+(cAliasTRB)->(F2_DOC+F2_SERIE))
								A103ProcDv("SF2",SF2->(Recno()),nOpcx,lCliente,SF2->F2_CLIENTE,SF2->F2_LOJA,cDocSF2,lFlagDev)
							EndIf
						EndIf
						(cAliasTRB)->(dbSkip())
					End
				ElseIf nOpcao == 2
					(cAliasTRB)->(dbGoTop())
					While (cAliasTRB)->(!Eof())
						If !Empty((cAliasTRB)->TRB_OK)
							cDocSF2 += IIF(Len(cDocSF2)>0,",","")+"'"+(cAliasTRB)->F2_DOC+(cAliasTRB)->F2_SERIE+"'"
						EndIF
						
						(cAliasTRB)->(dbSkip())
					EndDo
					If !Empty(cDocSF2)
						cDocSF2 := "("+SubStr(cDocSF2,1,Len(cDocSF2))+")"
						A103ProcDv(cAlias,,nOpcx,lCliente,cCliente,cLoja,cDocSF2,lFlagDev)
					EndIf

				EndIf
				
				(cAliasQRY)->(dbCloseArea())
				oTmpTable:Delete()
				oTmpTable := NIL
				
			EndIf

		EndIf // Empty(cAliasTRB)
	enddo
	EndIf // A103FRet(...
EndIf // INCLUI
Inclui := !Inclui

Return

/*/{Protheus.doc} MontColMb
//TODO Monta um array com a estrutura necessária para as colunas da markbrowse 
baseada nos campos a serem apresentadas com a estrutura da tabela a ser utilizada.
@author Leonardo Miranda
@since 16/02/2023
@version 1.0
@return ${return}, ${return_description}
@param aFieldView, array, descricao
@param aStrTMP, array, descricao
@type function
/*/
*********************************************
Static Function MontColMb(aFieldView,aStrTMP)
*********************************************

Local nCnt		:= 0
Local nPos		:= 0
Local aColsMB	:= {}

For nCnt := 1 to Len(aFieldView)
	nPos := aScan(aStrTMP,{|x|x[1]==aFieldView[nCnt]})
	If nPos >0
		Aadd( aColsMB, {})
		Aadd( aColsMB[Len(aColsMB)] ,aStrTMP[nPos ,1])
		Aadd( aColsMB[Len(aColsMB)] ,RetTitle(aStrTMP[nPos ,1]))
		Aadd( aColsMB[Len(aColsMB)] ,aStrTMP[nPos ,2])
		Aadd( aColsMB[Len(aColsMB)] ,aStrTMP[nPos ,3])
		Aadd( aColsMB[Len(aColsMB)] ,aStrTMP[nPos ,4])
		Aadd( aColsMB[Len(aColsMB)] ,x3Picture(aStrTMP[nPos ,1]))
	EndIf
Next nCnt

Return(aColsMB)

/*/{Protheus.doc} MontIdxMb
//TODO monta um array com a estrutura necessária para os índices da markbrowse baseada 
nos campos dos índices a serem apresentadas com a estrutura da tabela a ser utilizada.
@author Leonardo Miranda
@since 16/02/2023
@version 1.0
@return ${return}, ${return_description}
@param aIdxTMP, array, descricao
@param aStrTMP, array, descricao
@type function
/*/
******************************************
Static Function MontIdxMb(aIdxTMP,aStrTMP)
*********************************************

Local nCnt		:= 0
Local nCnt1		:= 0
Local nPos		:= 0
Local aIdxMB	:= {}
Local aField	:= {}

For nCnt := 1 to Len(aIdxTMP)
	aAdd( aIdxMB, {})
	aAdd( aIdxMB[Len(aIdxMB)] ,aIdxTMP[nCnt,1]) // composicao do indice com os titulos
	aField := {}
	For nCnt1 := 1 to Len(aIdxTMP[nCnt ,2])
		nPos := aScan(aStrTMP,{|x|x[1]==aIdxTMP[nCnt ,2 ,nCnt1]})
		If nPos >0
			Aadd( aField, {})
			Aadd( aField[Len(aField)] ,"")
			Aadd( aField[Len(aField)] ,aStrTMP[nPos ,2])
			Aadd( aField[Len(aField)] ,aStrTMP[nPos ,3])
			Aadd( aField[Len(aField)] ,aStrTMP[nPos ,4])
			Aadd( aField[Len(aField)] ,RetTitle(aStrTMP[nPos ,1]))
			Aadd( aField[Len(aField)] ,x3Picture(aStrTMP[nPos ,1]))
		EndIf
	Next nCnt1
	Aadd( aIdxMB[Len(aIdxMB)] ,aField)
Next nCnt

Return(aIdxMB)

/*/{Protheus.doc} A103QryNF
//TODO seleciona os registros de acordo com os parâmetros informados na função A103FRet().
@author Leonardo Miranda
@since 16/02/2023
@version 1.0
@return ${return}, ${return_description}
@param lDocVincul, logical, descricao
@param cCliente, characters, descricao
@param cLoja, characters, descricao
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@param lFilCliFor, logical, descricao
@param lAllCliFor, logical, descricao
@type function
/*/
******************************************************************************************************************
Static Function A103QryNF(lDocVincul, cCliente, cLoja, dDataDe, dDataAte, lFilCliFor, lAllCliFor, lFlagDev,cQuery)
******************************************************************************************************************

Local cAliasSF2 := 'SF2'
Local cFieldQry := ""
Local nCnt		:= 0
Local aStruct	:= {}

Default lFlagDev := .F.

cAliasSF2 := GetNextAlias()
If lDocVincul

	cQuery := " SELECT DISTINCT SDH.DH_FILIAL ,SDH.DH_SERIE ,SDH.DH_DOC ,SDH.DH_CLIENTE ,SDH.DH_LOJACLI ,SDH.DH_FORNECE ,SDH.DH_LOJAFOR ,SDH.DH_DTDIGIT ,D2_DOC F2_DOC ,D2_SERIE F2_SERIE "
	cQuery += " FROM " + RetSqlName("SDH") + " SDH "
	cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 ON SD2.D2_FILIAL = '" + xFilial("SD2") + "' "
	cQuery += " AND SD2.D2_NUMSEQ = SDH.DH_IDENTNF "
	cQuery += " AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SDH.DH_FILIAL  = '" + xFilial("SDH") + "' "
	cQuery += 		" AND SDH.DH_OPER = '2' "
	cQuery += 		" AND SDH.DH_TPMOV = '2' "
	If lAllCliFor
		cQuery += 		" AND SDH.DH_CLIENTE = '" + cCliente + "' "
		cQuery += 		" AND SDH.DH_LOJACLI = '" + cLoja    + "' "
	Else
		cQuery += 		" AND SDH.DH_FORNECE = '" + cCliente + "' "
		cQuery += 		" AND SDH.DH_LOJAFOR = '" + cLoja    + "' "
	EndIf
	cQuery += 		" AND SDH.DH_DTDIGIT BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "
	cQuery += 		" AND SDH.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SDH.DH_FILIAL, SDH.DH_DOC, SDH.DH_SERIE "

Else
	aStruct := SF2->(dbStruct())
	For nCnt := 1 To Len(aStruct)
		cFieldQry += IIF(Len(cFieldQry)>0 ," ," ,"")
		cFieldQry += aStruct[nCnt,1] 
	Next nCnt
	
	cQuery := " SELECT " + cFieldQry + " "
	cQuery += " FROM " + RetSqlName("SF2") + " "
	cQuery += " WHERE F2_FILIAL  = '" + xFilial("SF2") + "' "
	If !Empty(cCliente)
		cQuery += 	" AND F2_CLIENTE = '" + cCliente + "' "
		cQuery += 	" AND F2_LOJA = '" + cLoja + "' "
	EndIf
	If !Empty(dDataDe) .And. !Empty(dDataAte)
		cQuery += 	" AND F2_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "
	EndIf
	cQuery += 		" AND F2_EMISSAO <='" + DTOS(dDataBase)+"' "
	cQuery += 		" AND F2_TIPO NOT IN ('D'"
	If !lAllCliFor
		If lFilCliFor
			cQuery += ",'B') "
		Else
			cQuery += ",'N') "
		EndIf
	Else
		cQuery += ") "
	EndIf
	//If lFlagDev
		cQuery += " AND F2_FLAGDEV <> '1' "
	//EndIf
	cQuery += 	" AND D_E_L_E_T_ = ' ' "
EndIf

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.T.,.T.)

aStruct := SF2->(dbStruct())
For nCnt := 1 To Len(aStruct)
	If aStruct[nCnt][2] <> "C"
		TcSetField(cAliasSF2 ,aStruct[nCnt, 1] ,aStruct[nCnt, 2] ,aStruct[nCnt, 3] ,aStruct[nCnt, 4])
	EndIf
Next nX

aStruct := SDH->(dbStruct())
For nCnt := 1 To Len(aStruct)
	If aStruct[nCnt][2] <> "C"
		TcSetField(cAliasSF2 ,aStruct[nCnt, 1] ,aStruct[nCnt, 2] ,aStruct[nCnt, 3] ,aStruct[nCnt, 4])
	EndIf
Next nX

If Select(cAliasSF2)<=0
	cAliasSF2 := ""
EndIf

Return(cAliasSF2)

/*/{Protheus.doc} A103FldBrw
//TODO Define os campos(colunas) que serao apresentados na markbrowse.
@author Leonardo Miranda
@since 16/02/2023
@version 1.0
@return ${return}, ${return_description}
@param lCliente, logical, descricao
@param lDocVincul, logical, descricao
@type function
/*/
***********************************************
Static Function A103FldBrw(lCliente,lDocVincul)
***********************************************

Local aArea		:= {}
Local aFields	:= {}
Local aStruct	:= {} 
Local aStrOrig	:= {}

If lCliente
	If lDocVincul
		aFields := {"DH_DOC", "DH_SERIE"}
	Else
		aFields := {"F2_DOC", "F2_SERIE"}
	EndIf
Else
	If lDocVincul
		aFields := {"DH_SERIE" ,"DH_DOC" ,"DH_CLIENTE" ,"DH_LOJACLI" ,"DH_FORNECE" ,"DH_LOJAFOR" ,"DH_DTDIGIT"}
	Else
		aArea := GetArea()
		DbSelectArea("SX3")
		DbSetOrder(1)
		MsSeek("SF2")
		While !Eof() .And. SX3->X3_ARQUIVO == "SF2"
		    If SX3->X3_BROWSE == "S" 
				Aadd( aFields, Alltrim(SX3->X3_CAMPO) )
			EndIf
			SX3->(DbSkip())
		End
		RestArea(aArea)
	EndIf
EndIf
	
aSize(aStruct,0) 
aStruct := NIL 
aSize(aStrOrig,0)
aStrOrig := NIL 

Return aFields

/*/{Protheus.doc} A103DFldQ
//TODO define a estrutura da tabela temporia baseado na query com os registros selecionados
@author Leonardo Miranda
@since 16/02/2023
@version 1.0
@return ${return}, ${return_description}
@param cAliasTRB, characters, descricao
@type function
/*/
************************************
Static Function A103DFldQ(cAliasTRB)
************************************

Local aStruField:= {}
Local aStruTMP	:= {}
Local nCnt		:= 0

Aadd(aStruTMP,{"TRB_OK","C",01,00})
	
aStruct := (cAliasTRB)->(dbStruct())
For nCnt := 1 To Len(aStruct)
	aStruField := aStruct[nCnt]
	aAdd(aStruTMP, aStruField)
Next nCnt
	
Return(aStruTMP)

/*/{Protheus.doc} A103DIdxQ
//TODO define os indices basesado nas tabelas utilizadas na seleção dos registros 
@author reynaldo
@since 16/02/2023
@version 1.0
@return ${return}, ${return_description}
@param lCliente, logical, descricao
@param lDocVincul, logical, descricao
@type function
/*/
***********************************************
Static Function A103DIdxQ(lCliente, lDocVincul)
***********************************************

Local cAliasTRB := ""
Local nCnt		:= 0
Local nI		:= 1
Local aIdxTMP	:= {}
Local sTMP		:= ""
Local aTMP		:= {}
Local cDescric	:= ""
Local aFwIdx	:= FWFormStruct(1,'SF2'):aindex
Local nPosVgl   := 0
Local cFilds	:= ""

If lCliente
	aIdxTMP := {}
Else
	If lDocVincul
		cAliasTRB := "SDH"
		aTMP := {"DH_FILIAL" ,"DH_SERIE" ,"DH_DOC" ,"DH_CLIENTE" ,"DH_LOJACLI" ,"DH_FORNECE" ,"DH_LOJAFOR" ,"DH_DTDIGIT"}
		For nCnt := 1 to len(aTmp)
			cDescric += RetTitle(aTmp[nCnt])
		Next nCnt
		Aadd(aIdxTMP ,{cDescric ,aTMP})
	Else
		For nI := 1 to len(aFwIdx)
			If Ascan(aFwIdx,{|x| substr(x[3],1,len(alltrim(aFwIdx[ni][3])))== alltrim((aFwIdx[ni][3])).and. x[3] <> aFwIdx[ni][3] }) == 0 // impede inclusão de para indices parcialmente igual.
					sTMP := aFwIdx[ni][3]
					aTMP := StrTokArr(sTMP ,"+")
					cFilds := ""  
				For nCnt := 1 to len(aTMP)
					aTMP[nCnt] := Alltrim(STRTRAN(aTMP[nCnt] ,"DTOS(" ,""))
					aTMP[nCnt] := Alltrim(STRTRAN(aTMP[nCnt] ,")" ,""))
					aTMP[nCnt] := StrTran(aTMP[nCnt], "STR(", "")
					nPosVgl := At(",", aTMP[nCnt])
					If nPosVgl > 0
						aTMP[nCnt] := Substr(aTMP[nCnt], 1, nPosVgl - 1)
					EndIf
				Next nCnt 
						
			    Aadd(aIdxTMP ,{IIF("F2_FILIAL" $ aFwIdx[ni][3],iif(UPPER(STR0520)+"+" $ Upper(StrTran(aFwIdx[ni][4]," ", "")) ,aFwIdx[ni][4],STR0520+" + "+aFwIdx[ni][4]),aFwIdx[ni][4]) ,aTMP})
				
			EndIf
		Next
	EndIf
EndIf

Return(aIdxTMP)

/*/{Protheus.doc} A103NewTMP
//TODO cria a tabela temporaria, conforme parametros informados
@author Leonardo Miranda
@since 16/02/2018
@version 1.0
@return ${return}, ${return_description}
@param oTmpTable, object, descricao
@param aStrTMP, array, descricao
@param aIdxTMP, array, descricao
@type function
/*/
*******************************************************
Static Function A103NewTMP(oTmpTable ,aStrTMP ,aIdxTMP)
*******************************************************

Local cAliasTRB := GetNextAlias()
Local nCnt 		:= 0

// crio a tabela temporaria
oTmpTable := FWTemporaryTable():New(cAliasTRB)
oTmpTable:SetFields( aStrTMP ) 
For nCnt := 1 to Len(aIdxTMP)
	oTmpTable:AddIndex("IDX"+STRZERO(nCnt,2),aIdxTMP[nCnt ,2]) 
Next nCnt
oTmpTable:Create() 

If Select(cAliasTRB) <= 0
	cAliasTRB := ""
EndIf
	
Return(cAliasTRB)

/*/{Protheus.doc} A103FRet
//TODO Filtro para retornar de doctos fiscais.
@author Leonardo Miranda
@since 16/02/2023
@version 1.0
@return ${return}, ${return_description}
@param lCliFor, logical, descricao
@param dDataDe, date, descricao
@param dDataAte, date, descricao
@param lFilCliFor, logical, descricao
@param lAllCliFor, logical, descricao
@param lDocVincul, logical, descricao
@param cCliente, characters, descricao
@param cLoja, characters, descricao
@type function
/*/
***************************************************************************************************
Static Function A103FRet(lCliFor,dDataDe,dDataAte,lFilCliFor,lAllCliFor,lDocVincul,cCliente, cLoja)
***************************************************************************************************

Local oDlgEsp
Local oCliente
Local oDocto
Local oDocVinculo
Local oBlqNSerie
Local lDocto	:= .T.
Local lMotObrig := X3Obrigat("F1_MOTRET")
Local nOpcao	:= 0
Local aSize		:= MsAdvSize(.F.)

Private cCodCli	:= CriaVar("F2_CLIENTE"	,.F.)
Private cLojCli	:= CriaVar("F2_LOJA"	,.F.)
Private cCodFor	:= CriaVar("F1_FORNECE"	,.F.)
Private cLojFor	:= CriaVar("F1_LOJA"	,.F.)
Private cDescRet:= CriaVar("DHI_DESCRI"	,.F.)
Private cMotRet	:= CriaVar("DHI_CODIGO"	,.F.)
Private cHistRet:= CriaVar("F1_HISTRET"	,.F.)
Private oMemoRet:= Nil

DEFAULT lDocVincul := .F.
DEFAULT lGerPVDev  := .F.
DEFAULT lBlqNSer   := .F.

DEFINE MSDIALOG oDlgEsp From aSize[7],0 To aSize[6]/1.5,aSize[5]/2 OF oMainWnd PIXEL TITLE STR0099

@ 06,005 SAY RetTitle("F2_CLIENTE") PIXEL
@ 05,040 MSGET cCodCli PICTURE PesqPict("SF2","F2_CLIENTE") F3 'SA1' SIZE 95,10 OF oDlgEsp PIXEL VALID Vazio() .Or. VldCliFor('SA1',cCodCli)  WHEN Empty(cCodFor) HASBUTTON

@ 06,145 SAY RetTitle("F2_LOJA") PIXEL
@ 05,160 MSGET cLojCli PICTURE PesqPict("SF2","F2_LOJA") SIZE 20,10 OF oDlgEsp PIXEL VALID Vazio() .Or. ExistCpo('SA1',cCodCli+RTrim(cLojCli),1)  WHEN Empty(cLojFor) HASBUTTON

@ 06,190 CHECKBOX oBlqNSerie VAR lBlqNSer PROMPT "Bloqueia Chassi"  SIZE 100,010 ON CLICK( lGerPVDev := .F., oDocVinculo:Refresh()) OF oDlgEsp PIXEL //"Pesquisa por Documento Vinculado"

@ 21,005 SAY RetTitle("F1_FORNECE") PIXEL
@ 20,040 MSGET cCodFor PICTURE PesqPict("SF1","F1_FORNECE") F3 'FOR' SIZE 95, 10 OF oDlgEsp PIXEL VALID Vazio() .Or. VldCliFor('SA2',cCodFor)  WHEN Empty(cCodCli) HASBUTTON

@ 21,145 SAY RetTitle("F1_LOJA") PIXEL
@ 20,160 MSGET cLojFor PICTURE PesqPict("SF1","F1_LOJA") SIZE 20, 10 OF oDlgEsp PIXEL VALID Vazio() .Or. ExistCpo('SA2',cCodFor+RTrim(cLojFor),1) WHEN Empty(cLojCli) HASBUTTON

@ 21,190 CHECKBOX oDocVinculo VAR lGerPVDev PROMPT "Gera Pedido de Venda"  SIZE 100,010 ON CLICK( lBlqNSer := .F., oBlqNSerie:Refresh() ) OF oDlgEsp PIXEL //"Pesquisa por Documento Vinculado"

@ 36,05 SAY STR0181 PIXEL
@ 35,40 MSGET dDataDe PICTURE "@D" SIZE 60, 10 OF oDlgEsp PIXEL HASBUTTON

@ 36,120 SAY STR0182 PIXEL
@ 35,160 MSGET dDataAte PICTURE "@D" SIZE 60, 10 OF oDlgEsp PIXEL HASBUTTON

@ 060,005 TO __DlgHeight(oDlgEsp)-120,__DlgWidth(oDlgEsp)-5 LABEL STR0185 OF oDlgEsp PIXEL // 'Tipo de Selecao'

//-- 'Cliente'
@ 75,010 CHECKBOX oCliente VAR lCliFor PROMPT AllTrim(RetTitle("F2_CLIENTE"))+" / "+AllTrim(RetTitle("F1_FORNECE")) SIZE 100,010 ON CLICK( lDocto := .F., oDocto:Refresh() ) OF oDlgEsp PIXEL
//-- 'Documento'
@ 75,__DlgWidth(oDlgEsp)-60 CHECKBOX oDocto VAR lDocto PROMPT OemToAnsi(STR0184) SIZE 50,010 ON CLICK( lCliFor := .F., oCliente:Refresh() ) OF oDlgEsp PIXEL

@ __DlgHeight(oDlgEsp)-110,005 TO __DlgHeight(oDlgEsp)-025,__DlgWidth(oDlgEsp)-5 LABEL STR0427 OF oDlgEsp PIXEL // 'Motivo do retorno'

@ __DlgHeight(oDlgEsp)-94,010 SAY RetTitle("F1_MOTRET") PIXEL
@ __DlgHeight(oDlgEsp)-95,040 MSGET cMotRet SIZE 95, 10 OF oDlgEsp F3 "DHI" PIXEL VALID;
 (cDescRet:=Posicione("DHI",1,xFilial("DHI")+cMotRet,"DHI_DESCRI"), Vazio() .Or. ExistCpo('DHI',cMotRet,1)) HASBUTTON

@ __DlgHeight(oDlgEsp)-95,145 MSGET cDescRet SIZE __DlgWidth(oDlgEsp)-165, 10 OF oDlgEsp PIXEL VALID Vazio() WHEN .F. HASBUTTON

@ __DlgHeight(oDlgEsp)-70,010 SAY RetTitle("F1_HISTRET") PIXEL
@ __DlgHeight(oDlgEsp)-71,040 GET oMemoRet VAR cHistRet Of oDlgEsp MEMO size __DlgWidth(oDlgEsp)-60,37 pixel 

DEFINE SBUTTON FROM 05,__DlgWidth(oDlgEsp)-35 TYPE 1 OF oDlgEsp ENABLE PIXEL ACTION ;
Eval({||cCliente := IIF(Empty(cCodCli),cCodFor,cCodCli),;
		cLoja    := IIF(Empty(cLojCli),cLojFor,cLojCli),;
		IIF(Empty(cCliente).And.Empty(cLoja),lAllCliFor:=.T.,lAllCliFor:=.F.),;
		IIF(!Empty(cCodCli),lFilCliFor:=.T.,lFilCliFor:=.F.),.t.}).and.;
		If(Iif(!Empty(cMotRet),.T.,Iif(lMotObrig,(MsgAlert(STR0428,"MATA103"),.F.),.T.)) .And.	; //"Informe um código de motivo valido."
			((!Empty(cCliente)     .And.	;
			!Empty(cLoja)		 .And.	;
			!Empty(dDataDe)		 .And.	;
			!Empty(dDataAte)	 .And. 	;
			lCliFor)			 .Or.	;
			lDocto),(MT103SetRet(cMotRet,cHistRet),nOpcao := 1,oDlgEsp:End()),.F.)

DEFINE SBUTTON FROM 20,__DlgWidth(oDlgEsp)-35 TYPE 2 OF oDlgEsp ENABLE PIXEL ACTION (nOpcao := 0,oDlgEsp:End())

ACTIVATE MSDIALOG oDlgEsp CENTERED

Return( nOpcao == 1 )

/*/{Protheus.doc} ZWndBrwMrk
//TODO apresenta uma markbrowse dentro de uma dialog de acordo com os parametros informados.
@author Leonardo Miranda
@since 16/02/2023
@version 1.0
@return ${return}, ${return_description}
@param cTitle, characters, descricao
@param cAliasTRB, characters, descricao
@param lFieldMark, logical, descricao
@param aSeeks, array, descricao
@param aCols, array, descricao
@param aLegends, array, descricao
@param lRetornar, logical, descricao
@param lDocVincul, logical, Documento vinculado
@type function
/*/
**********************************************************************************************************
Static Function ZWndBrwMrk( cTitle, cAliasTRB, lFieldMark, aSeeks, aCols, aLegends, lRetornar, lDocVincul )
**********************************************************************************************************

Local oPanel
Local nCnt 		:= 0
Local aPosPanel := {}
Local aPosDialog:= {}
Local oSize
Local oDlgSelect
Local nOpcao := 0

DEFAULT lFieldMark	:=.F.
DEFAULT	lDocVincul	:= .F.
DEFAULT aSeeks		:= {}
DEFAULT aCols		:= {}
DEFAULT aLegends	:= {}

//Faz o calculo automatico de dimensoes de objetos
oSize := FwDefSize():New(.T.)

oSize:lLateral := .F.
oSize:lProp	:= .T. // Proporcional
	
oSize:AddObject( "BROWSE" ,75 ,100 ,.T. ,.T. ) // Totalmente dimensionavel
		
oSize:Process() // Dispara os calculos		
	
aPosDialog:={oSize:aWindSize[1]*0.75;
			,oSize:aWindSize[2]*0.75;
			,oSize:aWindSize[3]*0.75;
			,oSize:aWindSize[4]*0.75}

aPosPanel := aPosDialog
	 
DEFINE MSDIALOG oDlgSelect TITLE cTitle FROM aPosDialog[1],aPosDialog[2] ;
 			TO aPosDialog[3],aPosDialog[4] ;
 			Of oMainWnd ;
 			PIXEL

oPanel := TPanel():New(aPosPanel[1],aPosPanel[2],'',oDlgSelect,, .T., .T.,, ,aPosPanel[3],aPosPanel[4])
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

//Agora iremos usar a classe FWMarkBrowse
oBrowse:= FWMarkBrowse():New()
    
oBrowse:SetOwner(oPanel)	
oBrowse:SetDescription("") //Titulo da Janela
oBrowse:SetAlias(cAliasTRB) //Indica o alias da tabela que será utilizada no Browse
oBrowse:SetTemporary() //Indica que o Browse utiliza tabela temporária
oBrowse:SetColumns(MBColumn(aCols)) //Adiciona uma coluna no Browse em tempo de execução
    
oBrowse:DisableReport() // Desabilita a impressão das informações disponíveis no Browse
oBrowse:DisableConfig() // Desabilita a utilização do Browse
oBrowse:SetIgnoreARotina(.T.) // Indica que a mbrowse, ira ignorar a variavel private aRotina na construção das opções de menu.
oBrowse:SetMenuDef("") 
oBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
oBrowse:SetAmbiente(.F.) //Habilita a utilização da funcionalidade Ambiente no Browse
 
oBrowse:oBrowse:SetDBFFilter(.F.)
oBrowse:oBrowse:SetUseFilter(.F.) //Habilita a utilização do filtro no Browse
oBrowse:oBrowse:SetFixedBrowse(.T.)
oBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse

If Empty(aSeeks)
  	oBrowse:oBrowse:SetSeek(.F.)
Else
   	oBrowse:oBrowse:SetSeek(.T.,aSeeks) //Habilita a utilização da pesquisa de registros no Browse
EndIf

If lFieldMark
    oBrowse:SetFieldMark("TRB_OK") //Indica o campo que deverá ser atualizado com a marca no registro
    oBrowse:SetAllMark({|| MarkAll(oBrowse) })
EndIf

//Permite adicionar legendas no Browse
For nCnt := 1 to len(aLegends)
    oBrowse:AddLegend(aLegends[nCnt,1],aLegends[nCnt,2],aLegends[nCnt,3])
Next nCnt
    
//Adiciona botoes na janela
If lRetornar
   	oBrowse:AddButton(STR0005 ,{|| IIf(A103RINTER(oBrowse,lDocVincul),(nOpcao := 2 ,lLoop := .T. , oDlgSelect:End()),.F.)} ,NIL ,NIL ,2) // "Retornar"
Else
   	oBrowse:AddButton(STR0387 ,{|| GrvOK(cAliasTRB),lLoop := .T.,lFirst := .F., nOpcao := 1 ,oDlgSelect:End()} ,NIL ,NIL ,2) // "Confirmar"
EndIF
oBrowse:AddButton(STR0515 ,{||  oDlgSelect:End()}  ,NIL ,NIL ,2) // "Sair"
    
//Método de ativação da classe
oBrowse:Activate()
    
oBrowse:oBrowse:SetFocus() //Seta o foco na grade

ACTIVATE MSDIALOG oDlgSelect CENTERED
	
aSize(aSeeks ,0)
aSeeks := NIL
	
aSize(aCols ,0)
aCols := NIL
	
aSize(aLegends ,0)
aLegends := NIL
	
aSize(aPosDialog ,0)
aPosDialog := NIL
	
aSize(aPosPanel ,0)
aPosPanel := NIL	

Return(nOpcao)
	
/*/{Protheus.doc} MBColumn
//TODO Monta as colunas da markBrowse
@author Leonardo Miranda
@since 16/02/2023
@version 1.0
@return ${return}, ${return_description}
@param aCols, array, descricao
@type function
/*/
*******************************
Static Function MBColumn(aCols)
*******************************

Local nCnt		:= 0
Local aColumns	:= {}

For nCnt := 1 To Len(aCols)
	Aadd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||"+aCols[nCnt,1]+"}") )
	aColumns[Len(aColumns)]:SetTitle(aCols[nCnt,2]) 
	aColumns[Len(aColumns)]:SetSize(aCols[nCnt,4]) 
	aColumns[Len(aColumns)]:SetDecimal(aCols[nCnt,5])
Next nCnt 

Return(aColumns)

/*/{Protheus.doc} GrvOK
//TODO Grava X no registro posicionado na tabela temporaria.
@author Leonardo Miranda
@since 16/02/2023
@version 1.0
@return ${return}, ${return_description}
@param cAliasTRB, characters, descricao
@type function
/*/
********************************
Static Function GrvOK(cAliasTRB)
********************************

Local cAliasOld := Alias()

RecLock(cAliasTRB)
(cAliasTRB)->TRB_OK := "X"
MsUnLock()

If !Empty(cAliasOld)
	DbSelectArea(cAliasOld)
EndIf

Return .T.

//----------------------------------------------------
/*/{Protheus.doc} MarkAll
Funcao para inverter todos os registros da MarkBrowse.
		
@return	ExpL	Verdadeiro / Falso
@author	Leonardo Miranda
/*/        
//----------------------------------------------------
***********************************
Static Function MarkAll(oMrkBrowse)
***********************************

Local cAlias := oMrkBrowse:Alias()
	 
While (cAlias)->(!Eof())
	If (!oMrkBrowse:IsMark())
		RecLock((cAlias),.F.)
		(cAlias)->TRB_OK  := oMrkBrowse:Mark()
		(cAlias)->(MsUnLock())
	Else
		RecLock(cAlias,.F.)
		(cAlias)->TRB_OK  := ""
		(cAlias)->(MsUnLock())
	EndIf
	(cAlias)->(DbSkip())
End

oBrowse:Refresh()
oBrowse:SetFilterDefault( "" )

Return( .T. )

/*/{Protheus.doc} A103RINTER
Validação na seleção de documentos se possui o mesmo indicador de presença 
e codigo de intermediador
		
@return	ExpL	Verdadeiro / Falso
@author	Leonardo Miranda
/*/        
*************************************************
Static Function A103RINTER(oMrkBrowse,lDocVincul)
*************************************************

Local lRet		:= .T.
Local lIntermed	:= A103CPOINTER()
Local cAliasRet	:= ""
Local cIndPres	:= ""
Local cCodA1U	:= ""
Local cTitleInd	:= Iif(lIntermed,RetTitle("F1_INDPRES"),"")
Local cTitleA1U	:= Iif(lIntermed,RetTitle("F1_CODA1U"),"")
Local aPedido	:= {}
Local aIndA1U	:= {}

If cPaisLoc == "BRA" .And. lIntermed .And. !lDocVincul
	cAliasRet	:= oMrkBrowse:Alias() 
	
	(cAliasRet)->(DbGotop())
	While (cAliasRet)->(!Eof()) .And. lRet 
		If (oMrkBrowse:IsMark()) 
			aPedido	:= GetAdvFVal("SD2",{"D2_PEDIDO","D2_ITEMPV"},xFilial("SD2") + (cAliasRet)->F2_DOC + (cAliasRet)->F2_SERIE + (cAliasRet)->F2_CLIENTE + (cAliasRet)->F2_LOJA,3 )
			If Len(aPedido) > 0
				aIndA1U := GetAdvFVal("SC5",{"C5_INDPRES","C5_CODA1U"},xFilial("SC5") + aPedido[1] + aPedido[2],1 )
				If Len(aIndA1U) > 0
					If (!Empty(cIndPres) .And. !Empty(aIndA1U[1])) .Or. (!Empty(cCodA1U) .And. !Empty(aIndA1U[2]))
						If cIndPres <> aIndA1U[1] .Or. cCodA1U <> aIndA1U[2]
							Help(" ",1,"A103RPRESA1U",,STR0537 + cTitleInd + STR0538 + cTitleA1U + STR0539,1,0) //"Documento possui " //" e/ou " //" diferente, não sendo possivel vincular no mesmo documento"
							lRet := .F.
						Endif
					Endif 

					If Empty(cIndPres)
						cIndPres := aIndA1U[1]
					Endif
					
					If Empty(cCodA1U)
						cCodA1U := aIndA1U[2]
					Endif
				Endif
			Endif
		Endif
		(cAliasRet)->(DbSkip())
	End

	(cAliasRet)->(DbGotop())
	oMrkBrowse:Refresh()
Endif

Return(lRet)

//--------------------------------------------------------------
/*/{Protheus.doc} VldCliFor
Função para gatilhar o primeiro cliente/fornecedor não bloqueado
		
@return	lRet	Verdadeiro / Falso
@author	Leonardo Miranda
@since 16/02/2023
/*/        
//--------------------------------------------------------------
************************************************
Static Function VldCliFor(cAlsCliFor,cCodCliFor)
************************************************

Local aAreaSA1 := SA1->(GetArea())
Local aAreaSA2 := SA2->(GetArea())
Local lRet 	   := .T.

If cAlsCliFor == 'SA1'
	SA1->(DbSetOrder(1))
	If Empty(cLojCli)
		If SA1->(Dbseek(xFilial("SA1")+cCodCliFor))
			While SA1->(!Eof()) .And. SA1->A1_COD == cCodCliFor
				If SA1->A1_MSBLQL <> "1" 
					cLojCli := SA1->A1_LOJA
					lRet    := .T.
					Exit
				EndIf
				SA1->(DbSkip())
			EndDo
		EndIf
	Else
		If SA1->(Dbseek(xFilial("SA1")+cCodCliFor+cLojCli))
			lRet := RegistroOk("SA1")
		EndIf			
	EndIf
Else
	SA2->(DbSetOrder(1))
	If Empty(cLojFor)
		If SA2->(Dbseek(xFilial("SA2")+cCodCliFor))
			While SA2->(!Eof()) .And. SA2->A2_COD == cCodCliFor
				If SA2->A2_MSBLQL <> "1" 
					cLojFor := SA2->A2_LOJA
					lRet    := .T.
					Exit
				EndIf
				SA2->(DbSkip())
			EndDo
		EndIf
	Else		
		If SA2->(Dbseek(xFilial("SA2")+cCodCliFor+cLojFor))
			lRet := RegistroOk("SA2")
		EndIf		
	EndIf
EndIf

RestArea(aAreaSA1)
RestArea(aAreaSA2)

Return(lRet)
