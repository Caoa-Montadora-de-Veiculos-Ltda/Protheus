#Include "Protheus.Ch"
#Include "Totvs.Ch"
#include 'parmtype.ch'
#include "TBICONN.CH"
#include 'TOPCONN.CH'


#Define CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} ZFATF010.PRW
Função de Consulta do Faturamento - CAOA
@author Sandro Ferreira
@since 13/04/2021
@version 1.0
@type function
/*/
User Function ZFATF010(_aParam)
Local _lJob := If( IsBlind(),.T.,.F.)
Local _lAbre		:= .F.
Local _lRet
Local _nPos   
Local _cEmpresa	
Local _cFilial 

Begin Sequence
    If _lJob
		ConOut("*************************************************************************************************************************"	+ CRLF)
		ConOut("----------- [ ZFATF010 ] - Inicio da funcionalidade "													                	+ CRLF)
		ConOut("*************************************************************************************************************************"	+ CRLF)
	EndIf

	//sendo job testar parametros
	If _lJob
		If ValType(_aParam) == "A"
			//VarInfo("Valores dos parametros recebidos pela rotina ZFATF010",_aParam)
			_cEmpresa 	:=  _aParam[1]
			_cFilial 	:=  _aParam[2]
			CONOUT("INICIANDO EMPRESA " + _cEmpresa)
			CONOUT("INICIANDO FILIAL "  + _cFilial)
			RpcClearEnv()
			RpcSetType(3)
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "FAT"
			_lAbre		:= .T.
		ElseIf Type("cFilAnt") <> "C"
			_cEmpresa	:=	"01"
			_cFilial	:=  "2010022001"
			CONOUT("INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("INICIANDO FILIAL "+_cFilial)
			RpcClearEnv()
			RpcSetType(3)
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "FAT"
			_lAbre		:= .T.
		EndIf
	EndIF
	CONOUT("INICIADA EMPRESA " + cEmpAnt)
	CONOUT("INICIADA FILIAL "  + cFilAnt)

    ConOut("*************************************************************************************************************************"	+ CRLF)
	ConOut("----------- [ ZFATF010 ] - VERIFICANDO SE JA EXISTE PROCESSAMENTO DO JOB  "														+ CRLF)
	ConOut("*************************************************************************************************************************"	+ CRLF)

	If !LockByName("ZFATF010",.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 1000 ) // Para o processamento por 1 segundo
			If LockByName("ZFATF010",.T.,.T.)
				_lRet := .T.
			EndIf
		Next	

		If !_lRet
			If !_lJob
				MsgInfo("Já existe um processamento em execução rotina ZFATF010, aguarde!")
			Else
				CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFATF010] Já existe um processamento em execução, aguarde!")
				ConOut("*************************************************************************************************************************"	+ CRLF)
				ConOut("----------- [ ZFATF010 ] - Já existe um processamento em execução rotina ZFATF010 "														+ CRLF)
				ConOut("*************************************************************************************************************************"	+ CRLF)
			EndIf
			Break
		EndIf
	EndIf
    If !_lJob
		FWMsgRun(,{|| ZFATF010PRC(_lJob) },,"Realizando a consulta do faturamento, aguarde...")
	Else
		CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFATF010] Iniciado processamento da consulta do faturamento ")
		ZFATF010PRC(_lJob)
	Endif
	UnLockByName("ZFATF010",.T.,.T.)
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFATF010] Finalizado processamento da consulta de estoque")


End Sequence

//Caso abriu o processo empresa e filial tem que fechar
If  _lAbre	
	Reset Environment
Endif

Return Nil


/*/{Protheus.doc} ZFATF010PRC
Função para consulta do Faturamento e envia por email, destinatários no parametro: CMV_FAT002 E CMV_FAT003.
@author Sandro Ferreira 
@since 13/04/2021
@version 1.0
@type function
/*/
Static Function ZFATF010PRC(_lJob)

    Default _lJob       := .F.
	Private cCadastro	:= "Consulta o Faturamento"
	
	//Função para consultar e carregar os dados da consulta.
	CarregaDados2()
	
Return
 
/*/{Protheus.doc} CarDados
Função para carregar as informações da Consulta do Faturamento.
@author FSW - DWC Consult
@since 24/02/2019
@version 1.0
@type function
/*/  
Static Function CarregaDados2()
    Local _cPasta    := SuperGetMV( "CMV_FAT004" ,,"\temp\")  //Local de armazenamento do arquivo
	Local cFaturamento   := GetNextAlias()
	Local cQuery	 := ""
	Local cArquivo	 := _cPasta + 'Faturamento.xml'
	Local _cMail     := "" 
    Local _cMail1    := SuperGetMV( "CMV_FAT002" ,,"sandro.ferreira@caoa.com.br") //Destinatarios do email
	Local _cMail2    := SuperGetMV( "CMV_FAT003" ,,"sandro.ferreira@caoa.com.br") //Destinatarios do email
    Local _cAssu     := "Posição do Faturamento referente ao dia:   " +  dtoc(date())
    Local _cRot      := "ZFATF010" 
   	Local aAnexos    := {}
    Local cHtml      := ""
	Local cObsMail	 := ""
    Local cReplyTo   := ""
	Local nAux       := 0
    Local cMailCC    := ""
    Local lMsgErro 	 := .T.
	Local aColunas   := {}
	//Local aDetalhes  := {}
	Local lMsgOK 	 := .F.
	//Local cSituacao  := ""  
	Local cPesq1     := "D21"
	Local cPesq2     := "YELLOW"
	Local cPesq3     := "HYUNDAI CAOA DO BRAS"
	Local cPesq4     := "YELLOW"
	Local cPesq5     := "HY21"
	Local cRetPesq1  := 0
	Local cRetPesq2  := 0
	Local cRetPesq3  := 0
	Local cRetPesq4  := 0
	Local cRetPesq5  := 0
	Local dData1     := DtoS(FirstDate(dDataBase)) 
	Local dData2     := DtoS(dDataBase - 1)
	Local oFWMsExcel

    if day(dDatabase) == 01
	   dData1 := DtoS(FirstDate(monthsub(dDataBase,1)))
	endif
	
    //Criar Colunas da Planilha
	aAdd(aColunas, "Num. Pedido")
	aAdd(aColunas, "Ped. Compra")
	aAdd(aColunas, "Data Digita.")
	aAdd(aColunas, "Tipo Venda")
	aAdd(aColunas, "Chassi")
	aAdd(aColunas, "Modelo")
	aAdd(aColunas, "Descr.Mod.")
	aAdd(aColunas, "Opcional")
	aAdd(aColunas, "Descr.Opcional")
	aAdd(aColunas, "Cor Externa")
	aAdd(aColunas, "Descr. Cor Externa")
	aAdd(aColunas, "Cor interna")
	aAdd(aColunas, "Descr. Cor interna")
	aAdd(aColunas, "Ano Fabr/Mod")
	aAdd(aColunas, "Serie NF")
	aAdd(aColunas, "Numero NF")
	aAdd(aColunas, "DT Emissao")
	aAdd(aColunas, "Chave NFe")
	aAdd(aColunas, "Vlr Tabela")
	aAdd(aColunas, "Vl Total Vda")
	aAdd(aColunas, "Vendedor")
	aAdd(aColunas, "Nome do Vendedor")
	aAdd(aColunas, "Cliente")
	aAdd(aColunas, "Loja")
	aAdd(aColunas, "CNPJ/CPF")
	aAdd(aColunas, "Nome")
	aAdd(aColunas, "N Fantasia")
	aAdd(aColunas, "Municipio")
	aAdd(aColunas, "Estado")

	_cMail  := _cMail1 
    cMailCC := _cMail2 

	cHtml := "Bom dia. <br>"
	cHtml += "<br>"
	cHtml += "Em anexo a posição do Faturamento referente ao dia: " + dtoc(date()) + "<br>"
	//cHtml += "<br>"
	//cHtml += "Qualquer dúvida favor procurar por: Lucas Carvalho <br>"
	//cHtml += "<br>"
	//cHtml += "Email:  t-lucas.carvalho@caoa.com.br <br>"
	//cHtml += "<br>"
	//cHtml += "Telefone:  55 (11) 5538-1146 <br>"
	//cHtml += "<br>"
	//cHtml += "Celular:   55 (11) 99100-3000 <br>"

	If Select(cFaturamento) > 0
		(cFaturamento)->(DbCloseArea())
	EndIf

	cQuery := " SELECT " 
	cQuery += 		" VRJ_PEDIDO, VRJ_PEDCOM, VRJ_DATDIG" 
	cQuery += 		", COALESCE( VV3_DESCRI , ' ' ) VV3_DESCRI" 
	cQuery += 		", VRK_CHASSI, VRK_MODVEI, VRK_CODMAR " 
	cQuery += 		", VV2_DESMOD" 
	cQuery += 		", VRK_OPCION, COALESCE( RTRIM( VX5OPC.VX5_DESCRI ) , ' ' ) DESCOPCION"
	cQuery += 		", VRK_COREXT, COALESCE( RTRIM( VX5EXT.VX5_DESCRI ) , ' ' ) DESCCOREXT "
	cQuery += 		", VRK_CORINT, COALESCE( RTRIM( VX5INT.VX5_DESCRI ) , ' ' ) DESCCORINT "
	cQuery +=       ", SUBSTR(VRK_FABMOD, 1, 4) ||'/'||SUBSTR(VRK_FABMOD, 5, 4) FABMOD     "
	cQuery += 		", F2_SERIE, F2_DOC "
	cQuery +=       " , SUBSTR(F2_EMISSAO,7,2)||'/'||SUBSTR(F2_EMISSAO,5,2)||'/'||SUBSTR(F2_EMISSAO,1,4) EMISSAO"
	cQuery +=       " , F2_CHVNFE" 
	cQuery += 		", VRK_VALTAB, VRK_VALVDA" 
	cQuery += 		", VRJ_CODVEN" 
	cQuery += 		", COALESCE( A3_NOME , ' ' ) A3_NOME" 
	cQuery += 		", VRJ_CODCLI, VRJ_LOJA, A1_CGC, A1_NOME, A1_NREDUZ" 
	cQuery += 		", CC2_MUN" 
	cQuery += 		", A1_EST" 
	cQuery += 		", VRJ_CLIRET, VRJ_LOJRET" 
	cQuery += 	" FROM " + RetSQLName("VRJ") + " VRJ " 
	cQuery +=		" JOIN " + RetSQLName("VRK") + " VRK" 
	cQuery +=				"  ON VRK.VRK_FILIAL = '" + FWxFilial("VRK") + "'" 
	cQuery +=				" AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO" 
	cQuery +=				" AND VRK.D_E_L_E_T_ = ' '" 
	cQuery +=		" JOIN " + RetSQLName("VV9") + " VV9" 
	cQuery +=				"  ON VV9.VV9_FILIAL = '" + FWxFilial("VV9") + "'" 
	cQuery +=				" AND VV9.VV9_NUMATE = VRK.VRK_NUMTRA" 
	cQuery +=				" AND VV9.D_E_L_E_T_ = ' '" 
	cQuery +=				" AND VV9.VV9_STATUS IN ('F','T') " 
	cQuery +=		" JOIN " + RetSQLName("VV0") + " VV0" 
	cQuery +=				"  ON VV0.VV0_FILIAL = '" + FWxFilial("VV0") + "'" 
	cQuery +=				" AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE" 
	cQuery +=				" AND VV0.D_E_L_E_T_ = ' '" 
	cQuery +=				" AND VV0.VV0_OPEMOV = '0' " 
	cQuery +=				" AND VV0.VV0_SITNFI = '1' " 
	cQuery +=		" JOIN " + RetSQLName("SF2") + " F2 " 
	cQuery +=				"  ON F2.F2_FILIAL = '" + FWxFilial("SF2") + "'" 
	cQuery +=				" AND F2.F2_DOC = VV0.VV0_NUMNFI" 
	cQuery +=				" AND F2.F2_SERIE = VV0.VV0_SERNFI" 
	cQuery +=				" AND F2.F2_CLIENTE = VV0.VV0_CODCLI" 
	cQuery +=				" AND F2.F2_LOJA = VV0.VV0_LOJA" 
	cQuery +=				" AND F2.D_E_L_E_T_ = ' '" 
	cQuery +=		" JOIN " + RetSQLName("SA1") + " A1" 
	cQuery +=				"  ON A1.A1_FILIAL = '" + FWxFilial("SA1") + "'" 
	cQuery +=				" AND A1.A1_COD = VRJ.VRJ_CODCLI" 
	cQuery +=				" AND A1.A1_LOJA = VRJ.VRJ_LOJA" 
	cQuery +=				" AND A1.D_E_L_E_T_ = ' '" 
	cQuery +=		" LEFT JOIN " + RetSQLName("SA3") + " A3" 
	cQuery +=				"  ON A3.A3_FILIAL = '" + FWxFilial("SA3") + "'" 
	cQuery +=				" AND A3.A3_COD = VRJ.VRJ_CODVEN" 
	cQuery +=				" AND A3.D_E_L_E_T_ = ' '" 
	cQuery +=		" LEFT JOIN " + RetSQLName("CC2") + " CC2" 
	cQuery +=				"  ON CC2.CC2_FILIAL = '" + FWxFilial("CC2") + "'" 
	cQuery +=				" AND CC2.CC2_EST = A1.A1_EST" 
	cQuery +=				" AND CC2.CC2_CODMUN = A1.A1_COD_MUN" 
	cQuery +=				" AND CC2.D_E_L_E_T_ = ' '" 
	cQuery +=		" JOIN " + RetSQLName("VV2") + " VV2" 
	cQuery +=				"  ON VV2.VV2_FILIAL = '" + FWxFilial("VV2") + "'" 
	cQuery +=				" AND VV2.VV2_CODMAR = VRK.VRK_CODMAR" 
	cQuery +=				" AND VV2.VV2_MODVEI = VRK.VRK_MODVEI" 
	cQuery +=				" AND VV2.VV2_SEGMOD = VRK.VRK_SEGMOD" 
	cQuery +=				" AND VV2.D_E_L_E_T_ = ' '" 
	cQuery +=		" LEFT JOIN " + RetSqlName("VX5") + " VX5INT ON VX5INT.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5INT.VX5_CHAVE = '066' AND VX5INT.VX5_CODIGO = VV2.VV2_CORINT AND VX5INT.D_E_L_E_T_ = ' ' " 
	cQuery +=		" LEFT JOIN " + RetSqlName("VX5") + " VX5EXT ON VX5EXT.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5EXT.VX5_CHAVE = '067' AND VX5EXT.VX5_CODIGO = VV2.VV2_COREXT AND VX5EXT.D_E_L_E_T_ = ' ' " 
	cQuery +=		" LEFT JOIN " + RetSqlName("VX5") + " VX5OPC ON VX5OPC.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5OPC.VX5_CHAVE = '068' AND VX5OPC.VX5_CODIGO = VV2.VV2_OPCION AND VX5OPC.D_E_L_E_T_ = ' ' " 
	cQuery +=		" LEFT JOIN " + RetSQLName("VV3") + " VV3" 
	cQuery +=				"  ON VV3.VV3_FILIAL = '" + FWxFilial("VV3") + "'" 
	cQuery +=				" AND VV3.VV3_TIPVEN = VRJ.VRJ_TIPVEN" 
	cQuery +=				" AND VV3.D_E_L_E_T_ = ' '" 
	cQuery +=	" WHERE VRJ.VRJ_FILIAL = '" + FWxFilial("VRJ") + "'" 
	cQuery +=	  " AND VRJ.VRJ_STATUS <> 'C'" 
	cQuery +=	  " AND VRJ.D_E_L_E_T_ = ' '" 
	cQuery +=	  " AND VRK.VRK_CANCEL IN (' ','0')"
	cQuery += " AND F2.F2_EMISSAO BETWEEN '" + dData1 + "' AND '" + dData2 +"'" 
	cQuery += " ORDER BY VRJ.VRJ_PEDIDO "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cFaturamento,.F.,.T.)

 
	If Select(cFaturamento) > 0
        //Criando o objeto que irá gerar o conteúdo do Excel
	    oFWMsExcel := FWMSExcel():New()

	    //Criando a Aba - Posição de Faturamento
	    oFWMsExcel:AddworkSheet("Chery")
		oFWMsExcel:AddworkSheet("Chery (Rede)")
        oFWMsExcel:AddworkSheet("Chery (D21)")
        oFWMsExcel:AddworkSheet("HY")
        oFWMsExcel:AddworkSheet("HY (REDE)")
        oFWMsExcel:AddworkSheet("HY (CAOA)")
 
 	    //Criando a Tabela
	    oFWMsExcel:AddTable("Chery"        ,"Chery")
        For nAux := 1 To Len(aColunas)
            oFWMsExcel:AddColumn("Chery","Chery", aColunas[nAux], 1, 1)
        Next

 		(cFaturamento)->(DbGoTop())
		While !(cFaturamento)->(EOF())
            IF (cFaturamento)->VRK_CODMAR == 'CHE'
			   oFWMsExcel:AddRow("Chery","Chery",{;
			             (cFaturamento)->VRJ_PEDIDO  ,;
						 (cFaturamento)->VRJ_PEDCOM  ,;
						 (cFaturamento)->VRJ_DATDIG  ,;
						 (cFaturamento)->VV3_DESCRI  ,;
						 (cFaturamento)->VRK_CHASSI  ,;
					     (cFaturamento)->VRK_MODVEI  ,;         
						 (cFaturamento)->VV2_DESMOD  ,;
						 (cFaturamento)->VRK_OPCION  ,;
						 (cFaturamento)->DESCOPCION  ,;
						 (cFaturamento)->VRK_COREXT  ,;
						 (cFaturamento)->DESCCOREXT  ,;
						 (cFaturamento)->VRK_CORINT  ,;
						 (cFaturamento)->DESCCORINT  ,;
						 (cFaturamento)->FABMOD  ,;
						 (cFaturamento)->F2_SERIE    ,;
						 (cFaturamento)->F2_DOC      ,;
						 (cFaturamento)->EMISSAO  ,;
						 (cFaturamento)->F2_CHVNFE 	 ,;
						 (cFaturamento)->VRK_VALTAB  ,;
						 (cFaturamento)->VRK_VALVDA  ,;
						 (cFaturamento)->VRJ_CODVEN  ,;
						 (cFaturamento)->A3_NOME     ,;
						 (cFaturamento)->VRJ_CODCLI  ,;
						 (cFaturamento)->VRJ_LOJA    ,;
						 (cFaturamento)->A1_CGC      ,;
						 (cFaturamento)->A1_NOME     ,;
						 (cFaturamento)->A1_NREDUZ   ,;
						 (cFaturamento)->CC2_MUN     ,;
						 (cFaturamento)->A1_EST     })    
			EndIF
			(cFaturamento)->(DbSkip()) 
		EndDo

        oFWMsExcel:AddTable("Chery (Rede)" ,"Chery (Rede)")
		For nAux := 1 To Len(aColunas)
            oFWMsExcel:AddColumn("Chery (Rede)","Chery (Rede)", aColunas[nAux], 1, 1)
        Next
 		(cFaturamento)->(DbGoTop())
		While !(cFaturamento)->(EOF())
		    cRetPesq1 := (AT(cPesq1,(cFaturamento)->A1_NREDUZ))
			cRetPesq2 := (AT(cPesq2,(cFaturamento)->A1_NREDUZ))
			cRetPesq4 := (AT(cPesq4,(cFaturamento)->A1_NOME))
            IF (cFaturamento)->VRK_CODMAR == 'CHE' .and. (cRetPesq1 = 0 .and. cRetPesq2 = 0 .and. cRetPesq4 = 0)
            	oFWMsExcel:AddRow("Chery (Rede)","Chery (Rede)",{;
			             (cFaturamento)->VRJ_PEDIDO  ,;
						 (cFaturamento)->VRJ_PEDCOM  ,;
						 (cFaturamento)->VRJ_DATDIG  ,;
						 (cFaturamento)->VV3_DESCRI  ,;
						 (cFaturamento)->VRK_CHASSI  ,;
					     (cFaturamento)->VRK_MODVEI  ,;         
						 (cFaturamento)->VV2_DESMOD  ,;
						 (cFaturamento)->VRK_OPCION  ,;
						 (cFaturamento)->DESCOPCION  ,;
						 (cFaturamento)->VRK_COREXT  ,;
						 (cFaturamento)->DESCCOREXT  ,;
						 (cFaturamento)->VRK_CORINT  ,;
						 (cFaturamento)->DESCCORINT  ,;
						 (cFaturamento)->FABMOD  ,;
						 (cFaturamento)->F2_SERIE    ,;
						 (cFaturamento)->F2_DOC      ,;
						 (cFaturamento)->EMISSAO  ,;
						 (cFaturamento)->F2_CHVNFE 	 ,;
						 (cFaturamento)->VRK_VALTAB  ,;
						 (cFaturamento)->VRK_VALVDA  ,;
						 (cFaturamento)->VRJ_CODVEN  ,;
						 (cFaturamento)->A3_NOME     ,;
						 (cFaturamento)->VRJ_CODCLI  ,;
						 (cFaturamento)->VRJ_LOJA    ,;
						 (cFaturamento)->A1_CGC      ,;
						 (cFaturamento)->A1_NOME     ,;
						 (cFaturamento)->A1_NREDUZ   ,;
						 (cFaturamento)->CC2_MUN     ,;
						 (cFaturamento)->A1_EST     })
			EndIF

			(cFaturamento)->(DbSkip()) 
		EndDo

		oFWMsExcel:AddTable("Chery (D21)"  ,"Chery (D21)")
        For nAux := 1 To Len(aColunas)
            oFWMsExcel:AddColumn("Chery (D21)","Chery (D21)", aColunas[nAux], 1, 1)
        Next
		(cFaturamento)->(DbGoTop())
		While !(cFaturamento)->(EOF())
		    cRetPesq1 := (AT(cPesq1,(cFaturamento)->A1_NREDUZ))
			cRetPesq2 := (AT(cPesq2,(cFaturamento)->A1_NREDUZ))
			cRetPesq4 := (AT(cPesq4,(cFaturamento)->A1_NOME))
			IF (cFaturamento)->VRK_CODMAR == 'CHE' .and. (cRetPesq1 > 0 .or. cRetPesq2 > 0 .or. cRetPesq4 > 0)
            	oFWMsExcel:AddRow("Chery (D21)","Chery (D21)",{;
			             (cFaturamento)->VRJ_PEDIDO  ,;
						 (cFaturamento)->VRJ_PEDCOM  ,;
						 (cFaturamento)->VRJ_DATDIG  ,;
						 (cFaturamento)->VV3_DESCRI  ,;
						 (cFaturamento)->VRK_CHASSI  ,;
					     (cFaturamento)->VRK_MODVEI  ,;         
						 (cFaturamento)->VV2_DESMOD  ,;
						 (cFaturamento)->VRK_OPCION  ,;
						 (cFaturamento)->DESCOPCION  ,;
						 (cFaturamento)->VRK_COREXT  ,;
						 (cFaturamento)->DESCCOREXT  ,;
						 (cFaturamento)->VRK_CORINT  ,;
						 (cFaturamento)->DESCCORINT  ,;
						 (cFaturamento)->FABMOD  ,;
						 (cFaturamento)->F2_SERIE    ,;
						 (cFaturamento)->F2_DOC      ,;
						 (cFaturamento)->EMISSAO  ,;
						 (cFaturamento)->F2_CHVNFE 	 ,;
						 (cFaturamento)->VRK_VALTAB  ,;
						 (cFaturamento)->VRK_VALVDA  ,;
						 (cFaturamento)->VRJ_CODVEN  ,;
						 (cFaturamento)->A3_NOME     ,;
						 (cFaturamento)->VRJ_CODCLI  ,;
						 (cFaturamento)->VRJ_LOJA    ,;
						 (cFaturamento)->A1_CGC      ,;
						 (cFaturamento)->A1_NOME     ,;
						 'YELLOW MOUNTAIN DIST'      ,;
						 (cFaturamento)->CC2_MUN     ,;
						 (cFaturamento)->A1_EST     })
			EndIF

			(cFaturamento)->(DbSkip()) 
		EndDo


		oFWMsExcel:AddTable("HY"           ,"HY")
		For nAux := 1 To Len(aColunas)
            oFWMsExcel:AddColumn("HY","HY", aColunas[nAux], 1, 1)
        Next
		(cFaturamento)->(DbGoTop())
		While !(cFaturamento)->(EOF())
		    IF (cFaturamento)->VRK_CODMAR == 'HYU'
            	oFWMsExcel:AddRow("HY","HY",{;
			             (cFaturamento)->VRJ_PEDIDO  ,;
						 (cFaturamento)->VRJ_PEDCOM  ,;
						 (cFaturamento)->VRJ_DATDIG  ,;
						 (cFaturamento)->VV3_DESCRI  ,;
						 (cFaturamento)->VRK_CHASSI  ,;
					     (cFaturamento)->VRK_MODVEI  ,;         
						 (cFaturamento)->VV2_DESMOD  ,;
						 (cFaturamento)->VRK_OPCION  ,;
						 (cFaturamento)->DESCOPCION  ,;
						 (cFaturamento)->VRK_COREXT  ,;
						 (cFaturamento)->DESCCOREXT  ,;
						 (cFaturamento)->VRK_CORINT  ,;
						 (cFaturamento)->DESCCORINT  ,;
						 (cFaturamento)->FABMOD  ,;
						 (cFaturamento)->F2_SERIE    ,;
						 (cFaturamento)->F2_DOC      ,;
						 (cFaturamento)->EMISSAO  ,;
						 (cFaturamento)->F2_CHVNFE 	 ,;
						 (cFaturamento)->VRK_VALTAB  ,;
						 (cFaturamento)->VRK_VALVDA  ,;
						 (cFaturamento)->VRJ_CODVEN  ,;
						 (cFaturamento)->A3_NOME     ,;
						 (cFaturamento)->VRJ_CODCLI  ,;
						 (cFaturamento)->VRJ_LOJA    ,;
						 (cFaturamento)->A1_CGC      ,;
						 (cFaturamento)->A1_NOME     ,;
						 (cFaturamento)->A1_NREDUZ   ,;
						 (cFaturamento)->CC2_MUN     ,;
						 (cFaturamento)->A1_EST     })
			Endif

			(cFaturamento)->(DbSkip()) 
		EndDo


		oFWMsExcel:AddTable("HY (REDE)"    ,"HY (REDE)")
        For nAux := 1 To Len(aColunas)
            oFWMsExcel:AddColumn("HY (REDE)","HY (REDE)", aColunas[nAux], 1, 1)
        Next
		(cFaturamento)->(DbGoTop())
		While !(cFaturamento)->(EOF())
			cRetPesq3 := (AT(cPesq3,(cFaturamento)->A1_NREDUZ))  //"HYUNDAI CAOA DO BRAS"
			cRetPesq5 := (AT(cPesq5,(cFaturamento)->A1_NREDUZ))  //HY21
			IF (cFaturamento)->VRK_CODMAR == 'HYU' .and. cRetPesq3 = 0 .and. cRetPesq5 = 0
        	    oFWMsExcel:AddRow("HY (REDE)","HY (REDE)",{;
			             (cFaturamento)->VRJ_PEDIDO  ,;
						 (cFaturamento)->VRJ_PEDCOM  ,;
						 (cFaturamento)->VRJ_DATDIG  ,;
						 (cFaturamento)->VV3_DESCRI  ,;
						 (cFaturamento)->VRK_CHASSI  ,;
					     (cFaturamento)->VRK_MODVEI  ,;         
						 (cFaturamento)->VV2_DESMOD  ,;
						 (cFaturamento)->VRK_OPCION  ,;
						 (cFaturamento)->DESCOPCION  ,;
						 (cFaturamento)->VRK_COREXT  ,;
						 (cFaturamento)->DESCCOREXT  ,;
						 (cFaturamento)->VRK_CORINT  ,;
						 (cFaturamento)->DESCCORINT  ,;
						 (cFaturamento)->FABMOD  ,;
						 (cFaturamento)->F2_SERIE    ,;
						 (cFaturamento)->F2_DOC      ,;
						 (cFaturamento)->EMISSAO  ,;
						 (cFaturamento)->F2_CHVNFE 	 ,;
						 (cFaturamento)->VRK_VALTAB  ,;
						 (cFaturamento)->VRK_VALVDA  ,;
						 (cFaturamento)->VRJ_CODVEN  ,;
						 (cFaturamento)->A3_NOME     ,;
						 (cFaturamento)->VRJ_CODCLI  ,;
						 (cFaturamento)->VRJ_LOJA    ,;
						 (cFaturamento)->A1_CGC      ,;
						 (cFaturamento)->A1_NOME     ,;
						 (cFaturamento)->A1_NREDUZ   ,;
						 (cFaturamento)->CC2_MUN     ,;
						 (cFaturamento)->A1_EST     })
			Endif

			(cFaturamento)->(DbSkip()) 
		EndDo

		oFWMsExcel:AddTable("HY (CAOA)"    ,"HY (CAOA)")
        For nAux := 1 To Len(aColunas)
            oFWMsExcel:AddColumn("HY (CAOA)","HY (CAOA)", aColunas[nAux], 1, 1)
        Next
		(cFaturamento)->(DbGoTop())
		While !(cFaturamento)->(EOF())
		    cRetPesq3 := (AT(cPesq3,(cFaturamento)->A1_NREDUZ))  //"HYUNDAI CAOA DO BRAS"
			cRetPesq5 := (AT(cPesq5,(cFaturamento)->A1_NREDUZ))  //HY21
			IF (cFaturamento)->VRK_CODMAR == 'HYU' .and. ( cRetPesq3 > 0  .or. cRetPesq5 > 0 )
            	oFWMsExcel:AddRow("HY (CAOA)","HY (CAOA)",{;
			             (cFaturamento)->VRJ_PEDIDO  ,;
						 (cFaturamento)->VRJ_PEDCOM  ,;
						 (cFaturamento)->VRJ_DATDIG  ,;
						 (cFaturamento)->VV3_DESCRI  ,;
						 (cFaturamento)->VRK_CHASSI  ,;
					     (cFaturamento)->VRK_MODVEI  ,;         
						 (cFaturamento)->VV2_DESMOD  ,;
						 (cFaturamento)->VRK_OPCION  ,;
						 (cFaturamento)->DESCOPCION  ,;
						 (cFaturamento)->VRK_COREXT  ,;
						 (cFaturamento)->DESCCOREXT  ,;
						 (cFaturamento)->VRK_CORINT  ,;
						 (cFaturamento)->DESCCORINT  ,;
						 (cFaturamento)->FABMOD  ,;
						 (cFaturamento)->F2_SERIE    ,;
						 (cFaturamento)->F2_DOC      ,;
						 (cFaturamento)->EMISSAO  ,;
						 (cFaturamento)->F2_CHVNFE 	 ,;
						 (cFaturamento)->VRK_VALTAB  ,;
						 (cFaturamento)->VRK_VALVDA  ,;
						 (cFaturamento)->VRJ_CODVEN  ,;
						 (cFaturamento)->A3_NOME     ,;
						 (cFaturamento)->VRJ_CODCLI  ,;
						 (cFaturamento)->VRJ_LOJA    ,;
						 (cFaturamento)->A1_CGC      ,;
						 (cFaturamento)->A1_NOME     ,;
						 'HYUNDAI CAOA DO BRAS'      ,;
						 (cFaturamento)->CC2_MUN     ,;
						 (cFaturamento)->A1_EST     })
			Endif

			(cFaturamento)->(DbSkip()) 
		EndDo
	
		  
        //Ativando o arquivo e gerando o xml
	    oFWMsExcel:Activate()
	    oFWMsExcel:GetXMLFile(cArquivo)

	    //Retorna vazio somente se não tiver saldos na VV1.
	    If  Select(cFaturamento) > 0
           	//-- REGISTRO DE HISTORICO (TABELA SZU)
	        cObsMail := "ENVIO DA POSIÇÃO DE FATURAMENTO DE:   " + dtoc(date())
               	
            //-- Inclui Planilha gerada como anexo
	        Aadd(aAnexos, cArquivo)

	        //   	  (cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,Rotina ,	Observação	, cReplyTo	)
            U_ZGENMAIL(	_cMail      ,cMailCC    , _cAssu    ,cHtml      ,aAnexos    ,lMsgErro  ,lMsgOK	    , _cRot ,     cObsMail  , cReplyTo )                
	    EndIf
	EndIf

	If Select(cFaturamento) > 0
		(cFaturamento)->(DbCloseArea())
	EndIf

Return
