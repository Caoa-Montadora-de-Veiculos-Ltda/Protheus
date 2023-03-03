#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "Protheus.ch"
#Include "TbiConn.ch"
#DEFINE DEFAULT_FTP 21
#DEFINE CRLF Chr(13)+Chr(10)

//INTEGRAÇÃO COM O COGNOS - BI
User Function CMCOG05()

	LOCAL lRet
	PRIVATE cString  := "SCR"
	PRIVATE nRecSCR  := 0
	PRIVATE _cQtdReg := " "
	PRIVATE cARQ	 := " "
	PRIVATE cLinha	 := " "	
	PRIVATE cDATA    := DTOS(DDATABASE -1)  //Conf. MIT

	IF !MsgYesNo("Essa rotina ira verificar os movimentos referente a Emissão "+DTOC(DDATABASE -1)+ ".  Deseja continuar ? ")
		Return()
	ENDIF

	Processa({|| CMCOG05a() }) 

	IF FILE("C:\COGNOS\"+cARQ)
		MsgInfo("Processamento realizado com sucesso. ")
	ELSE
		MsgInfo("Arquivo não gerado na pasta!")
		RETURN()
	ENDIF

	//MsgInfo("Processamento realizado com sucesso. ")
Return()

Static Function CMCOG05a()//( aRet )

	// PARAMETROS LOGIN FTP
	//
	// CAOA_CG01 para guardar o usuï¿½rio de comunicaï¿½ï¿½o com FTP
	// CAOA_CG02 para guardar a senha do usuï¿½rio de comunicaï¿½ï¿½o com FTP
	// CAOA_CG03 para guardar a URL de comunicaï¿½ï¿½o com FTP
	//Modelo: Arquivo TXT
	// Periocidade de Envio: 1 x Dia
	//VARIAVEIS PARA MANIPULACAO DO ARQUIVO

	Local cQRY 		    := " "
	Local cQuery 		:= " "
	Local cDirDocs		:= __RelDir
	Local cCrLf			:= Chr(13)+Chr(10)
	Local cArquivo		:= CriaTrab(,.F.)
	Local cPath			:= AllTrim(GetTempPath())
	Local cDirDest		:= " "
	Local cEmpresa      := " "
	Local cDivisao      := " "
	Local cCatelogo     := " "
	Local cModelo       := " "
	Local cAnoMod       := " "
	Local cChassi       := " "
	Local cLocEntr      := " "
	Local cEmpresa      := " "
	Local cDivisao      := " "  //a definir SAP
	Local cLucro        := " "  //venda Novos
	Local cLocEntr      := " "
	Local nPerIRRF      := 1.5
	Local nValIRRF      := 0
	Local cValComis     := 0
	//Local nRet := MakeDir( "\COGNOS" )   //\System\CMCOG05\
	Local nRet := MakeDir( "C:\COGNOS" )   //\System\CMCOG05\
	Local oArqFtp
	local QRY := " "
	cMV_par01 := DTOS(DDATABASE -60)//DTOS(aRet[1])
	cMV_par02 := DTOS(DDATABASE)//DTOS(aRet[2])
	//INICIO DA GRAVACAO DO ARQUIVO

	//CABECALHO DO ARQUIVO
	cLinha 	:= "Operacao;"
	cLinha 	+= "Tipo_Mov;"
	cLinha 	+= "Tipo_Venda;"
	cLinha 	+= "Loc Entrega;"	
	//cLinha 	+= "Categoria;"
	cLinha 	+= "Empresa;"
	cLinha 	+= "Divisao;"
	cLinha 	+= "Loja;"	
	cLinha 	+= "Centro_Lucro;"
	cLinha 	+= "Dat_fat;"
	cLinha 	+= "Dia;"
	cLinha 	+= "Mes;"
	cLinha 	+= "Ano;"
	cLinha 	+= "Num_Nota;"
	cLinha 	+= "Catalogo;"
	cLinha 	+= "Modelo;"
	cLinha 	+= "AnoModelo_AnoFabricacao;"
	cLinha 	+= "Chassis;"
	cLinha 	+= "QTD;"
	cLinha 	+= "Valor_Venda;"
	cLinha 	+= "Perc_Comissao;"
	cLinha 	+= "Valor_Comissao;"
	cLinha 	+= "Perc_IRRF;"
	cLinha 	+= "Valor_IRRF;"
	cLinha 	+= "Valor_Liquido_Comissao;"
	cLinha 	+= CRLF

	IF Select("QRY") <> 0
		DbSelectArea("QRY")
		DbCloseArea()
	Endif
	/*
	cQuery := "SELECT F2_FILIAL, F2_EMISSAO,F2_DOC, C6_CHASSI,D2_COD,D2_QUANT,D2_PRCVEN,D2_TIPO 	" + CRLF
	//cQuery += " ,D2_TIPOMV, D2_TIPOV " + CRLF
	cQuery += "FROM SD2010 SD2 " + CRLF
	cQuery += "JOIN SF2010 SF2 " + CRLF
	cQuery += "ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += "AND D2_DOC   = F2_DOC	 " + CRLF
	cQuery += "AND D2_SERIE = F2_SERIE" + CRLF
	cQuery += "JOIN SC6010 SC6 " + CRLF
	cQuery += "ON  C6_FILIAL = D2_FILIAL" + CRLF
	cQuery += "AND C6_NUM =  D2_PEDIDO" + CRLF
	cQuery += "AND C6_ITEM = D2_ITEMPV " + CRLF

	cQuery += "AND SD2.D_E_L_E_T_=' ' " + CRLF
	cQuery += "AND SF2.D_E_L_E_T_=' '" + CRLF
	cQuery += "AND SC6.D_E_L_E_T_=' '" + CRLF

	cQuery += "AND SD2.D2_EMISSAO BETWEEN  '"+cMV_par01+"'  AND '"+cMV_par02+"' " + CRLF

	cQuery += "UNION	" + CRLF
	cQuery += "SELECT F1_FILIAL,F1_EMISSAO, D1_NFORI ,D1_CHASSI, D1_COD,(D1_QUANT*-1),D1_VUNIT,D1_TIPO	" + CRLF
	//cQuery += " ,D1_TIPOMV, D1_TIPOV " + CRLF
	cQuery += "FROM SD1010 SD1 " + CRLF
	cQuery += "JOIN SF1010 SF1 " + CRLF
	cQuery += "ON D1_FILIAL = F1_FILIAL " + CRLF
	cQuery += "AND D1_DOC   = F1_DOC	 " + CRLF
	cQuery += "AND D1_SERIE = F1_SERIE  " + CRLF
	cQuery += "AND SD1.D_E_L_E_T_=''	 " + CRLF
	cQuery += "JOIN SD2010 SD2 " + CRLF
	cQuery += "ON D1_FILIAL   = D2_FILIAL " + CRLF
	cQuery += "AND D1_NFORI   = D2_DOC	   " + CRLF
	cQuery += "AND D1_SERIORI = D2_SERIE  " + CRLF
	cQuery += "AND D1_COD     = D2_COD	 " + CRLF  
	cQuery += "AND SD1.D_E_L_E_T_=' '" + CRLF	   
	cQuery += "AND SF1.D_E_L_E_T_=' '" + CRLF	   
	cQuery += "AND F1_TIPO='D'    " + CRLF        
	cQuery += "AND SD1.D1_EMISSAO BETWEEN  '"+cMV_par01+"'  AND '"+cMV_par02+"' " + CRLF
	*/



	cQuery := " SELECT F2_FILIAL, F2_EMISSAO,F2_DOC, C6_CHASSI,D2_COD,D2_QUANT,D2_PRCVEN,D2_TIPO,VV2_CATVEI,VV2_MODVEI,VV2_MODFAB,VV1_FABMOD,VV2_CODMAR,VV2_XCOMIS " + CRLF
	cQuery += " FROM "+	RetSqlName("SD2") + " SD2 "
	cQuery += " JOIN "+	RetSqlName("SF2") + " SF2 "
	cQuery += " ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += " AND D2_DOC   = F2_DOC	 " + CRLF
	cQuery += " AND D2_SERIE = F2_SERIE" + CRLF
	cQuery += " JOIN "+	RetSqlName("SC6") + " SC6 "
	cQuery += " ON  C6_FILIAL = D2_FILIAL" + CRLF
	cQuery += " AND C6_NUM =  D2_PEDIDO" + CRLF
	cQuery += " AND C6_ITEM = D2_ITEMPV " + CRLF
	cQuery += " JOIN "+	RetSqlName("VV1") + " VV1 "
	cQuery += " ON SUBSTR(VV1_FILIAL,1,6) = SUBSTR(F2_FILIAL,1,6)" + CRLF
	cQuery += " AND C6_CHASSI = VV1_CHASSI " + CRLF
	cQuery += " JOIN "+	RetSqlName("VV2") + " VV2 "
	cQuery += " ON SUBSTR(VV2_FILIAL,1,6) = SUBSTR(F2_FILIAL,1,6)" + CRLF
	cQuery += " AND VV1_CODMAR = VV2_CODMAR" + CRLF
	cQuery += " AND VV1_MODVEI = VV2_MODVEI" + CRLF
	cQuery += " AND VV1_SEGMOD = VV2_SEGMOD" + CRLF
	cQuery += " AND SD2.D_E_L_E_T_=' ' " + CRLF
	cQuery += " AND SF2.D_E_L_E_T_=' ' " + CRLF
	cQuery += " AND SC6.D_E_L_E_T_=' ' " + CRLF
	cQuery += " AND VV1.D_E_L_E_T_=' ' " + CRLF
	cQuery += " AND VV2.D_E_L_E_T_=' ' " + CRLF
	cQuery += " AND SD2.D2_EMISSAO BETWEEN  '"+cMV_par01+"'  AND '"+cMV_par02+"' " + CRLF
	cQuery += " UNION "	
	cQuery += " SELECT F1_FILIAL,F1_EMISSAO, D1_NFORI ,D1_CHASSI, D1_COD,(D1_QUANT*-1),D1_VUNIT,D1_TIPO,VV2_CATVEI,VV2_MODVEI,VV2_MODFAB, VV1_FABMOD,VV2_CODMAR,VV2_XCOMIS" + CRLF
	cQuery += " FROM "+	RetSqlName("SD1") + " SD1 "
	cQuery += " JOIN "+	RetSqlName("SF1") + " SF1 "
	cQuery += " ON D1_FILIAL = F1_FILIAL " + CRLF
	cQuery += " AND D1_DOC   = F1_DOC	 " + CRLF
	cQuery += " AND D1_SERIE = F1_SERIE  " + CRLF
	cQuery += " AND SD1.D_E_L_E_T_=''	 " + CRLF
	cQuery += " JOIN "+	RetSqlName("SD2") + " SD2 "
	cQuery += " ON D1_FILIAL   = D2_FILIAL " + CRLF
	cQuery += " AND D1_NFORI   = D2_DOC	   " + CRLF
	cQuery += " AND D1_SERIORI = D2_SERIE  " + CRLF
	cQuery += " AND D1_COD     = D2_COD	 " + CRLF
	cQuery += " JOIN "+	RetSqlName("VV1") + " VV1 "
	cQuery += " ON SUBSTR(VV1_FILIAL,1,6) = SUBSTR(F1_FILIAL,1,6) " + CRLF
	cQuery += " AND D1_CHASSI = VV1_CHASSI " + CRLF
	cQuery += " JOIN "+	RetSqlName("VV2") + " VV2 "
	cQuery += " ON SUBSTR(VV2_FILIAL,1,6) = SUBSTR(F1_FILIAL,1,6)" + CRLF
	cQuery += " AND VV1_CODMAR = VV2_CODMAR" + CRLF
	cQuery += " AND VV1_MODVEI = VV2_MODVEI" + CRLF
	cQuery += " AND VV1_SEGMOD = VV2_SEGMOD" + CRLF
	cQuery += " AND SD1.D_E_L_E_T_=' '" + CRLF
	cQuery += " AND SF1.D_E_L_E_T_=' '" + CRLF
	cQuery += " AND F1_TIPO='D'       " + CRLF
	cQuery += " AND SD2.D2_EMISSAO BETWEEN  '"+cMV_par01+"'  AND '"+cMV_par02+"' " + CRLF


	MEMOWRITE("C:\cognos\"+ "qry_ZKESTR01.txt", cQuery )

	Iif(Select("QRY")>0,QRY->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY")

	Do While !QRY->(EOF())	
        nValIRRF := ((((QRY->D2_PRCVEN*QRY->VV2_XCOMIS)/100) * nPerIRRF)/100)
		if QRY->D2_TIPO = "N" // operação devolução ou venda
			cLinha     += "Venda"+";"
		Else
			cLinha     += "Devolução"+";"
		Endif
		cLinha     += "536"  +";" // TIPO MOVIMENTO (A DEFINIR)
		cLinha     += "CONSUMIDOR"  +";" // TIPO VENDA (A DEFINIR)
		// LOCAL DE ENTREGA
		cLinha     += "Grupo Caoa" +";"		// CATEGORIA
		IF QRY->VV2_CODMAR = "001"
			cLinha += "1110"  +";" // EMPRESA 001 - 1110 HYUNDAI
		ELSEIF QRY->VV2_CODMAR = "002"
			cLinha += "1410"  +";" // EMPRESA 002 - 1410 SUBARU
		ELSEIF QRY->VV2_CODMAR = "003"
			cLinha += "1510"  +";" // EMPRESA 003 - 1510 CHERY
		ENDIF
		cLinha     += "    "  +";" // DIVISAO (A DEFINIR)
		cLinha     += "    "  +";" // loja
		cLinha     += "4100" +";" // CENTRO DE LUCRO
		cLinha     += Subs(QRY->F2_EMISSAO,7,2)+"/"+Subs(QRY->F2_EMISSAO,5,2)+"/"+Subs(QRY->F2_EMISSAO,1,4) +";"
		cLinha     += Subs(QRY->F2_EMISSAO,7,2) +";"
		cLinha     += Subs(QRY->F2_EMISSAO,5,2) +";"
		cLinha     += Subs(QRY->F2_EMISSAO,1,4) +";"
		cLinha     += QRY->F2_DOC +";"
		cLinha     += alltrim(QRY->VV2_CATVEI)   +";" //cCatelogo +";"
		cLinha     += alltrim(QRY->VV2_MODVEI)   +";" //cModelo   +";"
		cLinha     += Subs(QRY->VV1_FABMOD,1,4)+"/"+Subs(QRY->VV1_FABMOD,5,4)  +";" //alltrim(QRY->VV1_FABMOD)   +";" //cAnoMod  //ALTERAR   --- 
		cLinha     += cValToChar(QRY->C6_CHASSI) +";" // CHASSI
		cLinha     += cValToChar(QRY->D2_QUANT) +";" //QUANTIDADE
		cLinha     += cValToChar(QRY->D2_PRCVEN) +";" // VALOR VENDA
		cLinha     += cValToChar(QRY->VV2_XCOMIS) +";" // PERCENTUAL COMISSAO VENDA
		cLinha     += cValToChar((QRY->D2_PRCVEN*QRY->VV2_XCOMIS)/100) +";" // VALOR COMISSAO BRUTO
		cLinha     += cValToChar(nPerIRRF) +";" //PERCENTUAL IRRF
		cLinha     += cValToChar(nValIRRF) +";" // VALOR IRRF 
		cLinha     += cValToChar(((QRY->D2_PRCVEN*QRY->VV2_XCOMIS)/100 - nValIRRF)) +";" //VALOR COMISSAO LIQUIDO
		//	cLinha     += cValToChar(cValIRRF) +";"    //Valor da Comissï¿½o * % do IRRF
		//	cLinha     += cValToChar(cValComis) +";"   //Valor da Comissï¿½o(bruto) - valor do IRRF
		cLinha     += CRLF
		QRY->(DBSKIP())
		IncProc()
	Enddo

	//FECHA ARQUIVO
	// CRIA ARQUIVO TEMPORARIO NA SYSTEM
	if nRet != 0
		conout( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
	endif

	cARQ := "COGNOS"+DTOS(dDATABASE)+".TXT"
	//MEMOWRITE("\COGNOS\"+cARQ,cLinha)
	MEMOWRITE("C:\COGNOS\"+cARQ,cLinha)

	// CONEXAO FTP    sera liberado apos as instrucoes
	/*
	&&Conexï¿½o e envio para FTP
	oArqFtp := FtpArq():NewFtpArq()
	If oArqFtp:Connect(SuperGetMV('CAOA_CG03',.F.) , DEFAULT_FTP , SuperGetMV('CAOA_CG01',.F.), SuperGetMV('CAOA_CG02',.F.))
	oArqFtp:Transfer(cARQ ,"\COGNOS\", cDirDest )
	oArqFtp:Disconnect()
	MsgAlert("Arquivo enviado, para verificaï¿½ï¿½o entre no diretï¿½rio")
	Else
	Aviso("Nï¿½o Foi possï¿½vel Gerar o Arquivo, verifique os parametros")
	EndIf
	*/
RETURN()