#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "Protheus.ch"
#Include "TbiConn.ch"
#DEFINE DEFAULT_FTP 21
#Include 'Protheus.ch'
#Include 'Totvs.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FILEIO.CH"
#DEFINE GD_INSERT	1
#DEFINE GD_DELETE	4
#DEFINE GD_UPDATE	2
#DEFINE c_BR CHR(13)+CHR(10)
#DEFINE CRLF Chr(13)+Chr(10)

user function CMDTS05()

	Local aRet := {}
	Local aParamBox := {}
	//Private aSay := {}
	Private aButton := {}

	aAdd(aParamBox,{1 ,"Emissao de:" ,CToD(""),"@D" ,"","","",50,.F.}) // Tipo data
	aAdd(aParamBox,{1 ,"Emissao Ate:" ,CToD(""),"@D" ,"","","",50,.F.}) // Tipo data

	If ParamBox(aParamBox,"Parâmetros...",@aRet)
		FWMsgRun(, {|| CMDTS05a( aRet ) },'Geração Excel','Gerando excel, aguarde...')

	EndIF
Return

Static Function CMDTS05a( aRet )

	Local cQry  		:=""
	Local cQry1 		:=""
	Local cQuery 		:=""
	Local cQuery1 		:=""
	Local cDirDocs		:= __RelDir
	Local cCrLf			:=Chr(13)+Chr(10)
	Local cArquivo		:=CriaTrab(,.F.)
	Local cPath			:=AllTrim(GetTempPath())
	Local cARQ			:=""
	Local cDirDest		:=""
	Local cMV_par01 := ''
	Local cMV_par02 := ''
	Local cMV_par03 := ''
	Local cSeq		:= "000000"
    Local nSeq      := 0
    Local cSeqA     := "000000"
    Local cSeqB     := "000000"    
	Local oArqFtp
	Local nRet := MakeDir( "C:\CMDTS05" )


	//Atribui conforme o Parambox enviou
	cMV_par01 := DTOS(aRet[1])
	cMV_par02 := DTOS(aRet[2])
	cQuery := ChangeQuery(cQuery)

	//INICIO DA GRAVACAO DO ARQUIVO
	//CABECALHO DO ARQUIVO
	cLinha 	:= "Sequence;"
	cLinha 	+= "Distributor Code;"
	cLinha 	+= "Dealer Code;"
	cLinha 	+= "Transaction Date;"
	cLinha 	+= "VIN;"
	cLinha 	+= "VIN Status 1;"
	cLinha 	+= "VIN Status 2;"
	cLinha 	+= "VIN Status 3;"
	cLinha 	+= "Transaction Type;"
	cLinha 	+= "Change in Wholesale ;"
	cLinha 	+= "Change in Retail sale;"
	cLinha 	+= "Change in Stock (Distributor/Subsidiary Stock);"
	cLinha 	+= "Change in Stock (dealer stock );"
	cLinha 	+= "Type of Retail sale 1;"
	cLinha 	+= "Type of Retail sale 2;"
	cLinha 	+= "Date of Data Creation;"
	cLinha 	+= CRLF

	IF Select("QRY") <> 0
		DbSelectArea("QRY")
		DbCloseArea()
	Endif

	cQuery := " SELECT " + CRLF
	cQuery += " BF_FILIAL, " + CRLF
	cQuery += " BF_PRODUTO,	" + CRLF
	cQuery += " BF_LOCAL, " + CRLF
	cQuery += " BF_QUANT, " + CRLF
	cQuery += " BF_NUMSERI " + CRLF
	cQuery += "	FROM "+	RetSqlName("SBF") + " SBF " + CRLF
	cQuery += "   WHERE BF_FILIAL='"+xFilial("SBF")+"'" + CRLF
	cQuery += " AND D_E_L_E_T_=' '	" + CRLF
	cQuery += " AND BF_NUMSERI <>' '	" + CRLF
	
	TCQUERY cQuery NEW ALIAS "QRY"
	//MEMOWRITE("C:\CMDTS05\"+ "qry_sbf.txt", cQuery )

	IF Select("QRY1") <> 0
		DbSelectArea("QRY1")
		DbCloseArea()
	Endif
	
	cQuery1 := " SELECT " 
	//cQuery1 += " LPAD(to_char(ROW_NUMBER() OVER(ORDER BY C6_CHASSI ASC)),6,'0') AS cSeq, "
	cQuery1 += " C6_CHASSI, "
	cQuery1 += " D2_EMISSAO, "
	cQuery1 += " D2_CLIENTE, "
	cQuery1 += " SA1.A1_TIPO "
	cQuery1 += " FROM "+	RetSqlName("SD2") + " SD2 "
	cQuery1 += " JOIN "+	RetSqlName("SA1") + " SA1 "
	cQuery1 += " ON A1_COD = D2_CLIENTE "
	cQuery1 += " JOIN SC6010 SC6 " + CRLF
	cQuery1 += " ON  C6_FILIAL = D2_FILIAL" + CRLF
	cQuery1 += " AND C6_NUM =  D2_PEDIDO" + CRLF
	cQuery1 += " AND C6_ITEM = D2_ITEMPV " + CRLF
	cQuery1 += " WHERE D2_FILIAL='"+xFilial("SD2")+"'"
	cQuery1 += " AND SD2.D_E_L_E_T_=' ' "
	cQuery1 += " AND SA1.D_E_L_E_T_=' ' "
	cQuery1 += " AND SC6.D_E_L_E_T_=' ' "
	cQuery1 += " AND C6_CHASSI <>' ' "
	cQuery1 += " AND SD2.D2_EMISSAO BETWEEN  '"+cMV_par01+"'  AND '"+cMV_par02+"' "
	TCQUERY cQuery1 NEW ALIAS "QRY1"
	MEMOWRITE("C:\CMDTS05\"+ "qry_sc6sd2.txt", cQuery1 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	procregua(reccount())
	Do While !QRY->(EOF())
		cSeqA := soma1(cSeqA)
		_cSeqA := STRZERO(VAL(cSeqA),6)
			
		cLinha     += _cSeqA +";"+ "B05AC" +";"+"  " +";"+ DTOS(DDATABASE)+";"
		cLinha     += ALLTRIM(QRY->BF_NUMSERI) +";"+ "1"	+";"+ "0"+";"+ "0" +";"
		cLinha     += "A"+";"+ "C"	+";"+ "C"	+";"+ "A" 		+";"
		cLinha     += "C" +";"+ "P"	+";"+ "1"	+";"+ " "		+";"
		cLinha     += CRLF

		//fWrite(nHandle, cLinha  + cCrLf)

		QRY->(DBSKIP())
		//IncProc()
	Enddo

	procregua(reccount())
	Do While !QRY1->(EOF())
		cSeq := soma1(cSeq)
		cSeqB := STRZERO(VAL(cSeq),6)
		cLinha     += cSeqB +";"+ "B05AC" +";"+"  " +";"+ cMV_par01	+";"
		cLinha     += ALLTRIM(QRY1->C6_CHASSI) +";"+ "0"	+";"

		IF QRY1->A1_TIPO = 'R'
			cLinha     += "1"+";"+ "0" +";"
			cLinha     += "A"+";"+ "A"	+";"+ "C"	+";"+ "B" 		+";"
			cLinha     += "A" +";"+ "P"	+";"+ "1"	+";"+ " "		+";"
		ELSE
			cLinha     += "0"+";"+ "1" +";"
			cLinha     += "A"+";"+ "C"	+";"+ "A"	+";"+ "C" 		+";"
			cLinha     += "B" +";"+ "P"	+";"+ "1"	+";"+ " "		+";"
		ENDIF

		//fWrite(nHandle, cLinha  + cCrLf)
		cLinha 	+= CRLF

		QRY1->(DBSKIP())
		IncProc()
	Enddo

	if nRet != 0
		conout( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
	endif

	// CRIA ARQUIVO TEMPORARIO NA SYSTEM
	cARQ := "CMDTS05"+DTOS(dDATABASE)+".CSV"
	MEMOWRITE("C:\CMDTS05\"+cARQ,cLinha)

