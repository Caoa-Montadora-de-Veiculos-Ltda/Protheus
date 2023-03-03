#Include "Protheus.Ch"
#Include "Totvs.Ch"

/*/{Protheus.doc} PROCINVT
Função de Processamento via MsExecAuto do Inventário Importado - CAOA
@author FSW - DWC Consult
@since 06/02/2019
@version 1.0
@param lEnd, logical, descricao
@param cAliTmp, characters, descricao
@type function
/*/
User Function PROCINVT(lEnd,cAliTmp)
	Local cQuery	:= ""
	Local cError	:= ""
	Local cTmpTab	:= "QRYTMP"
	Local Cr		:= 0
	Local nRegQry	:= 0
	Local aInvent	:= {}
	Local aAutoErro	:= {}
	
	Private nHdl			:= 0
	Private lMsHelpAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.
	
	//Seleciona os dados na Tabela Temporaria para processamento via MsExecAuto.
	cQuery := "SELECT * FROM " + cAliTmp
	MPSysOpenQuery( cQuery, cTmpTab )
	Count To nRegQry
	
	oProcess:SetRegua1(0)
	
	//Abre o Alias da Query.
	DbSelectArea(cTmpTab)
	(cTmpTab)->(DbGoTop())

	oProcess:IncRegua1('Executando Inventário')
	
	oProcess:SetRegua2(nRegQry)

	While !(cTmpTab)->(EOF())
		
		oProcess:IncRegua2('Documento de Inventário: ' + (cTmpTab)->TMP_B7DOC)
		
		aInvent := 	{;
					{"B7_FILIAL",	(cTmpTab)->TMP_B7FIL,		Nil},;
					{"B7_COD",		(cTmpTab)->TMP_B7COD,		Nil},;
					{"B7_LOCAL",	(cTmpTab)->TMP_B7ARM,		Nil},;
					{"B7_DOC",		(cTmpTab)->TMP_B7DOC,		Nil},;
					{"B7_DATA",		STod((cTmpTab)->TMP_B7DAT),	Nil},;
					{"B7_QUANT",	(cTmpTab)->TMP_B7QT1,		Nil},;
					{"B7_QTSEGUM",	(cTmpTab)->TMP_B7QT2,		Nil},;
					{"B7_LOTECTL",	(cTmpTab)->TMP_B7LOT,		Nil},;
					{"B7_NUMLOTE",	(cTmpTab)->TMP_B7SBL,		Nil},;
					{"B7_DTVALID",	SToD((cTmpTab)->TMP_B7DTL),	Nil},;
					{"B7_LOCALIZ",	(cTmpTab)->TMP_B7LOC,		Nil},;
					{"B7_NUMSERI",	(cTmpTab)->TMP_B7NUM,		Nil},;
					{"B7_TPESTR",	(cTmpTab)->TMP_B7EST,		Nil},;
					{"B7_CONTAGE",	(cTmpTab)->TMP_B7CON,		Nil},;
					{"B7_ORIGEM",	"INVCAOA",					Nil} }

		//Efetua a Gravação
		Begin Transaction
			lMsErroAuto := .F.

			MsExecAuto({|x,y,z| Mata270(x,y,z)}, aInvent , .F. , 3)

			If lMsErroAuto
				//Captura o LOG para gerar um arquivo Texto.
				aAutoErro := GETAUTOGRLOG()
				cError := ""
				For Cr := 1 To Len(aAutoErro)
					cError += AllTrim(aAutoErro[Cr]) + CRLF
				Next
				cError += "-----------------------------------------------" + CRLF + CRLF

				//Função para Gravar o LOG
				nHdl := LOGINV(cError)
			EndIf
		End Transaction

		(cTmpTab)->(DbSkip())
	EndDo

Return

/*/{Protheus.doc} LOGINV
Função Auxiliar para gravação do LOG de erro do MsExecAuto.
@author FSW - DWC Consult
@since 06/02/2019
@version 1.0
@param cLOG, characters, descricao
@type function
/*/
Static Function LOGINV(cLOG)
	Local cDir		:= "C:\INVENTARIO_CAOA\"
	Local cPath		:= "C:\INVENTARIO_CAOA\LOG_Importacao_de_Inventario_" + StrTran(DTOC(Date()),'/','-') + "_" + StrTran(TIME(),':','_') + ".txt"
	Local nFile		:= 0
	Local nOpcFile	:= GETF_LOCALHARD+GETF_RETDIRECTORY+GETF_NETWORKDRIVE

	//Verifica se Existe a Pasta da Log Inventário CAOA.
	//Caso não exista e não consiga cria-lá, solicita a pasta para salvar o TXT.
	If !ExistDir(cDir)
		nFile := MakeDir(cDir)
		If nFile < 0
			cPath := AllTrim(cGetFile("*.*","Local para Salvar",,,.F.,nOpcFile,.F.,))
			cPath := cPath + "LOG_Importacao_de_Inventario_" + StrTran(DTOC(Date()),'/','-') + "_" + StrTran(TIME(),':','_') + ".txt"
		EndIf
	EndIf

	cLOG := "["+Time()+"]" + " - Erro importação." + CRLF + cLOG

	If File(cPath)
		nHdl := FOpen(cPath,0)
	Else
		nHdl := FCreate(cPath)
	EndIf

	FSeek( nHdl,0,2 )
	FWrite( nHdl,cLOG )
	FClose( nHdl )
Return( nHdl )