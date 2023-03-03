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
#DEFINE GD_INSERT	1_PAIS
#DEFINE GD_DELETE	4
#DEFINE GD_UPDATE	2
#DEFINE CRLF Chr(13)+Chr(10)

user function CMDTM05()

	Local aRet := {}
	Local aParamBox := {}

    Private cNomeSis:= "PROTHEUS_Montadora"

	aAdd(aParamBox,{1 ,"Emissao de:" ,CToD(""),"@D" ,"","","",50,.F.}) // Tipo data
	aAdd(aParamBox,{1 ,"Emissao Ate:" ,CToD(""),"@D" ,"","","",50,.F.}) // Tipo data

	If ParamBox(aParamBox,"Parâmetros...",@aRet)
		FWMsgRun(, {|| CMDTM05a( aRet ) },'Geração Excel','Gerando excel, aguarde...')

	EndIF
Return

Static Function CMDTM05a( aRet )

	Local cQuery 		:= " "
	Local cQuery1 		:= " "
	Local cARQ			:= " "
	Local cARQ1			:= " "
	Local cARQ2			:= " "
	Local cARQ3			:= " "
	Local cFlgEmit      := " "
	Local cTpVenda      := " "
    Local cChTroca      := space(15)
    Local cKMTroca      := space(06)   
    Local cDtCad        := SPACE(19)
    Local cDtAtu        := SPACE(19)
    Local cDtVend       := SPACE(19)    
    Local cDtEmis       := SPACE(19)
    Local cDtEntr       := SPACE(19)
	Local cMV_par01     := ' '
	Local cMV_par02     := ' '
	Local cCNPJAR       := ' '
	Local cNacional     := ' '
	Local cEmplaca      := ' '  //Definir onde pegar data emplacaamento
	Local cOCN          := ' '
	Local oArqFtp
	Local nRet  := MakeDir( "C:\CMDTM05" )
	Local nRet1 := MakeDir( "C:\CMDTM06" )
	Local nRet2 := MakeDir( "C:\CMDTM07" )
	Local nRet3 := MakeDir( "C:\CMDTM08" )

	//Atribui conforme o Parambox enviou
	cMV_par01 := DTOS(aRet[1])
	cMV_par02 := DTOS(aRet[2])

	////////////////////////    PESSOA_PROTHEUS_Montadora.txt   ///////////////////////

	//CABECALHO DO ARQUIVO

	cLinha     := "NomeSistema|Cpf_cnpj|Rg|Nome|EnderecoPrincipal|NumeroPrincipal|ComplementoPrincipal|CEPPrincipal|BairroPrincipal|"
	cLinha     += "CidadePrincipal|EstadoPrincipal|TelefoneFixo|TelefoneCelular|Email|EstadoCivil|"
	cLinha     += "Nacionalidade|Nascimento|Sexo|DataCadastro|TipoCliente|DataAtualiza|flgFuncionario|"
	cLinha     += "NomeContato|TelefoneContato"
	cLinha 	   += CRLF

	//INICIO DA GRAVACAO DO ARQUIVO

	IF Select("QRY") <> 0
		DbSelectArea("QRY")
		DbCloseArea()
	Endif

	cQuery := " SELECT " + CRLF
	cQuery += " A1_CGC, "+ CRLF
	cQuery += " A1_RG,  "+ CRLF	
	cQuery += " A1_PFISICA, "+ CRLF
	cQuery += " A1_NOME, "+ CRLF
	cQuery += " A1_END, "+ CRLF
	cQuery += " A1_XNUMEND, "+ CRLF
	cQuery += " A1_COMPLEM, "+ CRLF
	cQuery += " A1_CEP, "+ CRLF
	cQuery += " A1_BAIRRO, "+ CRLF
	cQuery += " A1_MUN, "+ CRLF
	cQuery += " A1_EST, "+ CRLF
	cQuery += " A1_TEL, "+ CRLF
	cQuery += " A1_TELEX, "+ CRLF
	cQuery += " A1_EMAIL, "+ CRLF
	cQuery += " A1_XCIVIL, "+ CRLF
	cQuery += " A1_TIPO, "+ CRLF
	cQuery += " A1_DTNASC, "+ CRLF
	cQuery += " A1_XSEXO, "+ CRLF
	cQuery += " A1_DTCAD, "+ CRLF
	cQuery += " A1_HRCAD, "+ CRLF	
	cQuery += " A1_PESSOA, "+ CRLF
	cQuery += " A1_XDTATU, "+ CRLF	
	cQuery += " A1_XHRATU, "+ CRLF
	cQuery += " A1_XFGLFUN, "+ CRLF
	cQuery += " A1_CONTATO, "+ CRLF
	cQuery += " A1_PAIS, "+ CRLF	
	cQuery += " A1_XCEL, "+ CRLF	
	cQuery += " A1_TEL "+ CRLF
	cQuery += "	FROM "+	RetSqlName("SD2") + " SD2 "+ CRLF
	cQuery += " JOIN "+	RetSqlName("SA1") + " SA1 "+ CRLF
	cQuery += " ON A1_COD = D2_CLIENTE "+ CRLF
	cQuery += " AND SD2.D2_EMISSAO BETWEEN  '"+cMV_par01+"'  AND '"+cMV_par02+"' "+ CRLF
	cQuery += " AND SD2.D_E_L_E_T_=' ' "+ CRLF
	cQuery += " AND SA1.D_E_L_E_T_=' ' "+ CRLF

	TCQUERY cQuery NEW ALIAS "QRY"
	//MEMOWRITE("C:\CMDTM05\"+ "cQuery.txt", cQuery )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//+'"|"'+ ALLTRIM(QRY->A1_PFISICA)
	procregua(reccount())
	Do While !QRY->(EOF())
		IF QRY->A1_PAIS = "105" 
           cNacional := "BRASILEIRA" 
        ELSE
           cNacional := "ESTRANGEIRA"     
        ENDIF

        IF !EMPTY(QRY->A1_DTCAD)
           cDtCad := ALLTRIM(SUBSTR(QRY->A1_DTCAD,1,4))+'-'+ALLTRIM(SUBSTR(QRY->A1_DTCAD,5,2))+'-'+ALLTRIM(SUBSTR(QRY->A1_DTCAD,7,2)) +' '+ ALLTRIM(QRY->A1_HRCAD) 
        ELSE
           cDtCad := SPACE(19)
        ENDIF
        
        IF !EMPTY(QRY->A1_XDTATU)
           cDtAtu := ALLTRIM(SUBSTR(QRY->A1_XDTATU,1,4))+'-'+ALLTRIM(SUBSTR(QRY->A1_XDTATU,5,2))+'-'+ALLTRIM(SUBSTR(QRY->A1_XDTATU,7,2)) +' '+ ALLTRIM(QRY->A1_XHRATU) 
        ELSE
           cDtAtu := SPACE(19)
        ENDIF
        
		cLinha     += '"'+ALLTRIM(cNomeSis) +'"|"'+ ALLTRIM(QRY->A1_CGC) +'"|"'+ ALLTRIM(QRY->A1_RG)  +'"|"'+ ALLTRIM(QRY->A1_NOME) +'"|"'+ ALLTRIM(QRY->A1_END) +'"|"'+ ALLTRIM(QRY->A1_XNUMEND) +'"|"'+ ALLTRIM(QRY->A1_COMPLEM) +'"|"'+ ALLTRIM(QRY->A1_CEP) +'"|"'+ ALLTRIM(QRY->A1_BAIRRO) +'"|"'+ ALLTRIM(QRY->A1_MUN) +'"|"'
		cLinha     += ALLTRIM(QRY->A1_EST) +'"|"'+ ALLTRIM(QRY->A1_TEL) +'"|"'+ ALLTRIM(QRY->A1_XCEL) +'"|"'+ ALLTRIM(QRY->A1_EMAIL) +'"|"'+ ALLTRIM(QRY->A1_XCIVIL) +'"|"'+ cNacional +'"|"'+ ALLTRIM(QRY->A1_DTNASC) +'"|"'+ ALLTRIM(QRY->A1_XSEXO) +'"|'
		cLinha     += cDtCad +'|"'+ ALLTRIM(QRY->A1_PESSOA) +'"|"'+ cDtAtu +' '+ ALLTRIM(QRY->A1_XHRATU) +'"|"'+ ALLTRIM(QRY->A1_XFGLFUN) +'"|"'+ ALLTRIM(QRY->A1_CONTATO) +'"|"'+ ALLTRIM(QRY->A1_TEL) +'"'
		cLinha 	   += CRLF

		QRY->(DBSKIP())
		IncProc()
	Enddo

	//FECHA ARQUIVO
	//fClose(nHandle)

	if nRet != 0
		conout( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
	endif

	// CRIA ARQUIVO TEMPORARIO NA SYSTEM
	cARQ := "PESSOA_PROTHEUS_Montadora.TXT"
	MEMOWRITE("C:\CMDTM05\"+cARQ,cLinha)

	////////////////////VEICULO_PROTHEUS_Montadora.txt///////////////////////// VEICULO_PROTHEUS_Montadora.txt

	//CABECALHO DO ARQUIVO
	cLinha1     := "NomeSistema" +"|"+ "Chassi" +"|"+"Descricao" +"|"+ "Modelo"	+"|"
	cLinha1     += "Marca" +"|"+ "Grupo" +"|"+ "Placa" +"|"+"AnoFabricacao" +"|"+ "AnoModelo"+"|"
	cLinha1     += "Cor" +"|"+ "Renavam" +"|"+"TipoCombustivel" +"|"+ "QtdLugares"+"|"
	cLinha1     += "Potencia" +"|"+ "TipoVeiculo" +"|"+"Transmissao" +"|"+ "DataEmplacamento"+"|"
	cLinha1     += "OCN" 
	cLinha1 	   += CRLF

	IF Select("QRY1") <> 0
		DbSelectArea("QRY1")
		DbCloseArea()
	Endif

	cQuery1 := " SELECT 	 "+ CRLF
	cQuery1 += " BF_NUMSERI, "+ CRLF
	cQuery1 += " B1_DESC,    "+ CRLF
	cQuery1 += " VV1_MODVEI, "+ CRLF
	cQuery1 += " VV1_CODMAR, "+ CRLF
	cQuery1 += " VV1_PLAVEI, "+ CRLF
	cQuery1 += " VV1_FABMOD, "+ CRLF
	cQuery1 += " VV1_CORVEI, "+ CRLF
	cQuery1 += " VV1_COMVEI, "+ CRLF
	cQuery1 += " VV2_QTDPAS, "+ CRLF
	cQuery1 += " VV2_GRUMOD, "+ CRLF	
	cQuery1 += " VV1_POTMOT, "+ CRLF
	cQuery1 += " VV1_TIPVEI, "+ CRLF
	cQuery1 += " VV1_TIPCAM,  "+ CRLF
	cQuery1 += " VV1_RENAVA  "+ CRLF	
	cQuery1 += " FROM "+	RetSqlName("SBF") + " SBF "+ CRLF
	cQuery1 += " LEFT JOIN "+	RetSqlName("VV1") + " VV1 "+ CRLF
	cQuery1 += " ON VV1_CHASSI = BF_NUMSERI "+ CRLF
	cQuery1 += " AND VV1_FILIAL = BF_FILIAL "+ CRLF
	cQuery1 += " LEFT JOIN "+	RetSqlName("SB1") + " SB1 "+ CRLF
	cQuery1 += " ON VV1_CORVEI = SUBSTR(B1_COD,1,6) "+ CRLF
	cQuery1 += " AND VV1_FILIAL = B1_FILIAL "+ CRLF
	cQuery1 += " LEFT JOIN "+	RetSqlName("VV2") + " VV2 "+ CRLF
	//cQuery1 += " ON SUBSTR(VV2_FILIAL,1,6) = SUBSTR(BF_FILIAL,1,6)" + CRLF
	cQuery1 += " ON VV2_FILIAL  = BF_FILIAL"  + CRLF
	cQuery1 += " AND VV1_CODMAR = VV2_CODMAR" + CRLF
	cQuery1 += " AND VV1_MODVEI = VV2_MODVEI" + CRLF
	cQuery1 += " AND VV1_SEGMOD = VV2_SEGMOD" + CRLF

	cQuery1 += " AND SBF.D_E_L_E_T_=' ' "+ CRLF
	cQuery1 += " AND VV1.D_E_L_E_T_=' ' "+ CRLF

	TCQUERY cQuery1 NEW ALIAS "QRY1"
	MEMOWRITE("C:\CMDTM06\"+ "cQuery1.txt", cQuery1 )


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	procregua(reccount())
	Do While !QRY1->(EOF())
		//"|"+ QRY->VV1_DESMAR +
		cLinha1     += '"'+ALLTRIM(cNomeSis) +'"|"'+ ALLTRIM(QRY1->BF_NUMSERI) +'"|"'+ ALLTRIM(QRY1->B1_DESC) +'"|"'+ ALLTRIM(QRY1->VV1_MODVEI) +'"|"'+ ALLTRIM(QRY1->VV1_CODMAR) +'"|"'+ ALLTRIM(VV2_GRUMOD) +'"|"'+ ALLTRIM(QRY1->VV1_PLAVEI) +'"|"'
		cLinha1     += SUBSTR(QRY1->VV1_FABMOD,1,4) +'"|"'+ SUBSTR(QRY1->VV1_FABMOD,5,4) +'"|"'+ ALLTRIM(QRY1->VV1_CORVEI) +'"|"' + ALLTRIM(QRY1->VV1_RENAVA) +'"|"'
		cLinha1     += ALLTRIM(QRY1->VV1_COMVEI) +'"|"'+ ALLTRIM(QRY1->VV2_QTDPAS) +'"|"'+ ALLTRIM(QRY1->VV1_POTMOT) +'"|"'+ ALLTRIM(QRY1->VV1_TIPVEI) +'"|"'
		cLinha1 	+= ALLTRIM(QRY1->VV1_TIPCAM) +'"|'+ cEmplaca +'|"'+ cOCN +'"'		
		cLinha1 	+= CRLF

		QRY1->(DBSKIP())
		IncProc()
	Enddo


	//FECHA ARQUIVO
	if nRet1 != 0
		conout( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
	endif

	// CRIA ARQUIVO TEMPORARIO NA SYSTEM
	cARQ1 := "VEICULO_PROTHEUS_Montadora.TXT"
	MEMOWRITE("C:\CMDTM06\"+cARQ1,cLinha1)

	//////////////////////////VENDA_PROTHEUS_Montadora.txt///////////////////////////////////VENDA_PROTHEUS_Montadora.txt

	//CABECALHO DO ARQUIVO
	cLinha2     := "NomeSistema" +"|"+ "cpf_cnpj_Cliente" +"|"+ "cpf_Arrendatario" +"|"+ "Chassi" +"|"+"DataVenda" +"|"+ "DataEmissaoNF"	+"|"
	cLinha2     += "Valor" +"|"+ "FormaPgto" +"|"+"Proposta" +"|"+ "StatusProposta"	+"|"
	cLinha2     += "NF" +"|"+ "LojaOrigem" +"|"+"LojaVenda" +"|"+ "CpfVendedor"	+"|"
	cLinha2     += "Vendedor" +"|"+ "StatusVenda" +"|"+"StatusNF" +"|"+ "FlagTestDrive"	+"|"
	cLinha2     += "Qtde Parcela" +"|"+ "TipoVenda" +"|"+"Chassi_Troca" +"|"+ "KmChassiTroca"	+"|"
	cLinha2     += "DataEntrega" 
	cLinha2 	+= CRLF

	IF Select("QRY2") <> 0
		DbSelectArea("QRY2")
		DbCloseArea()
	Endif

	cQuery2 := " SELECT "    + CRLF
	cQuery2 += " A1_CGC,"    + CRLF
	cQuery2 += " A1_XTIPO,"  + CRLF	
	cQuery2 += " D2_NUMSERI,"+ CRLF
	cQuery2 += " C5_EMISSAO,"+ CRLF
	cQuery2 += " F2_EMISSAO,"+ CRLF
	cQuery2 += " F2_HORA,"   + CRLF	
	cQuery2 += " F2_VALBRUT,"+ CRLF
	cQuery2 += " E4_DESCRI," + CRLF
	cQuery2 += " C5_NUM,"    + CRLF
	cQuery2 += " C5_XHREMIS,"+ CRLF
	cQuery2 += " F2_DOC,"    + CRLF
	cQuery2 += " A3_CGC,"    + CRLF
	cQuery2 += " A3_NOME,"   + CRLF
	cQuery2 += " E4_CODIGO," + CRLF
	cQuery2 += " F2_DTENTR," + CRLF
	cQuery2 += " VV1_ESTVEI,"+ CRLF	
	cQuery2 += " VV1_CHASSI,"+ CRLF	
	cQuery2 += " VV1_XTDRIV" + CRLF	
	cQuery2 += " FROM "+	    RetSqlName("SC5") + " SC5 " + CRLF
	cQuery2 += " LEFT JOIN "+	RetSqlName("SC6") + " SC6 " + CRLF
	cQuery2 += " ON C6_FILIAL = C5_FILIAL AND C5_NUM = C6_NUM" + CRLF	
	cQuery2 += " LEFT JOIN "+	RetSqlName("SD2") + " SD2 " + CRLF
	cQuery2 += " ON D2_FILIAL = C5_FILIAL AND C5_NOTA = D2_DOC AND D2_SERIE = C5_SERIE" + CRLF
	cQuery2 += " LEFT JOIN "+	RetSqlName("SF2") + " SF2 " + CRLF
	cQuery2 += " ON F2_FILIAL = C5_FILIAL AND C5_NOTA = F2_DOC AND C5_SERIE = F2_SERIE " + CRLF
	cQuery2 += " LEFT JOIN "+	RetSqlName("SE4") + " SE4 " + CRLF
	cQuery2 += " ON E4_FILIAL = C5_FILIAL AND C5_CONDPAG = E4_CODIGO" + CRLF
	cQuery2 += " LEFT JOIN "+	RetSqlName("SA3") + " SA3 " + CRLF
	cQuery2 += " ON A3_FILIAL = C5_FILIAL AND A3_COD = C5_VEND1" + CRLF
	cQuery2 += " LEFT JOIN "+	RetSqlName("SA1") + " SA1 " + CRLF
	cQuery2 += " ON A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE" + CRLF
	cQuery2 += " LEFT JOIN "+	RetSqlName("VV1") + " VV1 " + CRLF
	cQuery2 += " ON VV1_CHASSI = C6_CHASSI  "+ CRLF
	cQuery2 += " AND VV1_FILIAL = C5_FILIAL "+ CRLF
	cQuery2 += " AND SD2.D_E_L_E_T_=' ' " + CRLF
	cQuery2 += " AND SF2.D_E_L_E_T_=' ' " + CRLF
	cQuery2 += " AND SE4.D_E_L_E_T_=' ' " + CRLF
	cQuery2 += " AND SA3.D_E_L_E_T_=' ' " + CRLF
	cQuery2 += " AND SA1.D_E_L_E_T_=' ' " + CRLF
	cQuery2 += " AND SC5.D_E_L_E_T_=' ' " + CRLF	
	cQuery2 += " AND SC6.D_E_L_E_T_=' ' " + CRLF	
	cQuery2 += " AND VV1.D_E_L_E_T_=' ' " + CRLF
	
	TCQUERY cQuery2 NEW ALIAS "QRY2"
	//MEMOWRITE("C:\CMDTM07\"+ "cQuery2.txt", cQuery2 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	procregua(reccount())
	Do While !QRY2->(EOF())
	    IF QRY2->VV1_XTDRIV = "0"
	       cFlgEmit := "SIM"
        ELSE	       
	       cFlgEmit := "NAO"
	    ENDIF	
	    
	    IF QRY2->A1_XTIPO = "R"	    
	       cTpVenda := "REDE"
	    ELSEIF QRY2->A1_XTIPO = "Z"	    
	       cTpVenda := "GRUPO CAOA"	       
	    ELSEIF QRY2->A1_XTIPO = "F"	    
	       cTpVenda := "CONSUMIDOR FINAL"	       
	    ELSEIF QRY2->A1_XTIPO = "P"	    
	       cTpVenda := "PNE"
	    ENDIF

       IF !EMPTY(QRY2->C5_EMISSAO)
           cDtVen := ALLTRIM(SUBSTR(QRY2->C5_EMISSAO,1,4))+'-'+ALLTRIM(SUBSTR(QRY2->C5_EMISSAO,5,2))+'-'+ALLTRIM(SUBSTR(QRY2->C5_EMISSAO,7,2)) +' '+ ALLTRIM(QRY2->C5_XHREMIS) 
        ELSE
           cDtVen := SPACE(19)
        ENDIF
 
        IF !EMPTY(QRY2->F2_EMISSAO)
           cDtEmis := ALLTRIM(SUBSTR(QRY2->F2_EMISSAO,1,4))+'-'+ALLTRIM(SUBSTR(QRY2->F2_EMISSAO,5,2))+'-'+ALLTRIM(SUBSTR(QRY2->F2_EMISSAO,7,2)) +' '+ ALLTRIM(QRY2->F2_HORA)+":00" 
        ELSE
           cDtEmis := SPACE(19)
        ENDIF
        
        IF !EMPTY(QRY2->F2_DTENTR)
           cDtEntr := ALLTRIM(SUBSTR(QRY2->F2_DTENTR,1,4))+'-'+ALLTRIM(SUBSTR(QRY2->F2_DTENTR,5,2))+'-'+ALLTRIM(SUBSTR(QRY2->F2_DTENTR,7,2)) +' '+ ALLTRIM(QRY2->F2_HORA)+":00" 
        ELSE
           cDtEntr := SPACE(19)
        ENDIF
        
	    	
		cLinha2     += '"'+ ALLTRIM(cNomeSis)  +'"|"'
		cLinha2     += ALLTRIM(QRY2->A1_CGC)     +'"|"'
		cLinha2     += cCNPJAR +'"|"'		
		cLinha2     += ALLTRIM(QRY2->VV1_CHASSI) +'"|'
		cLinha2     += cDtVen+'|'
		cLinha2     += cDtEmis+'|"'
		cLinha2     += ALLTRIM(cValToChar(QRY2->F2_VALBRUT))   +'"|"'
		cLinha2     += ALLTRIM(QRY2->E4_DESCRI) +'"|"'
		cLinha2     += ALLTRIM(QRY2->C5_NUM)    +'"|"'
		cLinha2     += "EMITIDA"                +'"|"'		
		cLinha2     += ALLTRIM(QRY2->F2_DOC)    +'"|"'
		cLinha2     += "GRUPO CAOA"	            +'"|"'
		cLinha2     += "LOJA VENDEDOR"          +'"|"'	//LOJA VENDEDOR	
		cLinha2     += ALLTRIM(QRY2->A3_CGC)    +'"|"'
		cLinha2     += ALLTRIM(QRY2->A3_NOME)   +'"|"'
		cLinha2     += ALLTRIM(QRY2->VV1_ESTVEI)+'"|"'		
		cLinha2     += "EMITIDA"                +'"|"'
		cLinha2     += cFlgEmit                 +'"|"'
		cLinha2     += ALLTRIM(QRY2->E4_CODIGO) +'"|"'   //Qtde parcelas
		cLinha2     += cTpVenda                 +'"|"'
		cLinha2     += cChTroca                 +'"|"'
		cLinha2     += cKMTroca                 +'"|'
		cLinha2     += cDtEntr
		cLinha2 	+= CRLF

		QRY2->(DBSKIP())
		IncProc()
	Enddo

	if nRet2 != 0
		conout( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
	endif


	// CRIA ARQUIVO TEMPORARIO NA SYSTEM
	cARQ2 := "VENDA_PROTHEUS_Montadora.TXT"
	MEMOWRITE("C:\CMDTM07\"+cARQ2,cLinha2)

	/////////////////CANCELA_VENDA_PROTHEUS_Montadora.txt////////////////////////////CANCELA_VENDA_PROTHEUS_Montadora.txt

	//CABECALHO DO ARQUIVO
	cLinha3     := "NomeSistema" +"|"+ "cpf_cnpj_Cliente" +"|"+ "Chassi" +"|"+ "DataVenda" +"|"+ "DataEmissaoNF" +"|"
	cLinha3     += "DataCancelamento" +"|"+ "NF" 
	cLinha3 	+= CRLF

	IF Select("QRY3") <> 0
		DbSelectArea("QRY3")
		DbCloseArea()
	Endif

	cQuery3 := " SELECT A1_CGC, "+ CRLF
	cQuery3 += " C6_CHASSI,  " + CRLF
	cQuery3 += " C5_EMISSAO, " + CRLF
	cQuery3 += " C5_XHREMIS, " + CRLF
	cQuery3 += " FT_EMISSAO, " + CRLF
	cQuery3 += " FT_DTCANC,  " + CRLF
	cQuery3 += " FT_NFISCAL  " + CRLF
	cQuery3 += " FROM "+	RetSqlName("SFT") + " SFT "+ CRLF
	cQuery3 += " JOIN "+	RetSqlName("SA1") + " SA1 "+ CRLF
	cQuery3 += " ON FT_CLIEFOR = A1_COD"+ CRLF
	cQuery3 += " JOIN "+	RetSqlName("SD2") + " SD2 "+ CRLF
	cQuery3 += " ON D2_FILIAL= FT_FILIAL"+ CRLF
	cQuery3 += " AND D2_DOC = FT_NFISCAL"+ CRLF+ CRLF
	cQuery3 += " AND D2_SERIE = FT_SERIE"+ CRLF
	cQuery3 += " AND D2_ITEM = FT_ITEM"+ CRLF
	cQuery3 += " JOIN "+	RetSqlName("SC5") + " SC5 "+ CRLF
	cQuery3 += " ON C5_FILIAL = FT_FILIAL"+ CRLF
	cQuery3 += " AND C5_NUM = D2_PEDIDO"+ CRLF
	cQuery3 += " JOIN "+	RetSqlName("SC6") + " SC6 "
	cQuery3 += " ON  C6_FILIAL = D2_FILIAL" + CRLF
	cQuery3 += " AND C6_NUM =  D2_PEDIDO" + CRLF
	cQuery3 += " AND C6_ITEM = D2_ITEMPV " + CRLF
	cQuery3 += " AND SFT.D_E_L_E_T_=' '"+ CRLF
	cQuery3 += " AND SA1.D_E_L_E_T_=' '"+ CRLF
	cQuery3 += " AND SC5.D_E_L_E_T_=' '"+ CRLF
	cQuery3 += " AND SC6.D_E_L_E_T_=' '"+ CRLF
	cQuery3 += " AND SD2.D_E_L_E_T_='*'"+ CRLF
	cQuery3 += " AND FT_DTCANC BETWEEN  '"+cMV_par01+"'  AND '"+cMV_par02+"' "+ CRLF

	TCQUERY cQuery3 NEW ALIAS "QRY3"
	//MEMOWRITE("C:\CMDTM08\"+ "cQuery3.txt", cQuery3 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	procregua(reccount())
	Do While !QRY3->(EOF())
       IF !EMPTY(QRY3->C5_EMISSAO)
           cDtVen := ALLTRIM(SUBSTR(QRY3->C5_EMISSAO,1,4))+'-'+ALLTRIM(SUBSTR(QRY3->C5_EMISSAO,5,2))+'-'+ALLTRIM(SUBSTR(QRY3->C5_EMISSAO,7,2)) +' '+ ALLTRIM(QRY3->C5_XHREMIS) 
        ELSE
           cDtVen := SPACE(19)
        ENDIF
 /*
        IF !EMPTY(QRY3->FT_EMISSAO)
           cDtEmis := ALLTRIM(SUBSTR(QRY2->FT_EMISSAO,1,4))+'-'+ALLTRIM(SUBSTR(QRY2->FT_EMISSAO,5,2))+'-'+ALLTRIM(SUBSTR(QRY2->FT_EMISSAO,7,2)) +' '+ ALLTRIM(QRY2->FT_HREMIS)+":00" 
        ELSE
           cDtEmis := SPACE(19)
        ENDIF
        
        IF !EMPTY(QRY3->FT_DTCANC)
           cDtEntr := ALLTRIM(SUBSTR(QRY2->FT_DTCANC,1,4))+'-'+ALLTRIM(SUBSTR(QRY2->FT_DTCANC,5,2))+'-'+ALLTRIM(SUBSTR(QRY2->FT_DTCANC,7,2)) +' '+ ALLTRIM(QRY2->FT_HRCAN)+":00" 
        ELSE
           cDtEntr := SPACE(19)
        ENDIF
*/

		cLinha3     += '"'+ ALLTRIM(cNomeSis)   +'"|"' 
		cLinha3     += ALLTRIM(QRY3->A1_CGC)      +'"|"'
		cLinha3     += ALLTRIM(QRY3->C6_CHASSI)   +'"|'
		cLinha3     += cDtVen  +'|"'
		cLinha3     += ALLTRIM(QRY3->FT_EMISSAO)  +'"|"'
		cLinha3     += ALLTRIM(SUBSTR(QRY3->FT_DTCANC,1,4))+ALLTRIM(SUBSTR(QRY3->FT_DTCANC,5,2))+ALLTRIM(SUBSTR(QRY3->FT_DTCANC,7,2))+"00:00:00"+'"|"'   //ALLTRIM(QRY3->FT_DTCANC)   +'"|"'
		cLinha3     += ALLTRIM(QRY3->FT_NFISCAL)  +'"'
		cLinha3 	+= CRLF
		QRY3->(DBSKIP())
		IncProc()
	Enddo

	if nRet3 != 0
		conout( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
	endif

	// CRIA ARQUIVO TEMPORARIO NA SYSTEM
	cARQ3 := "CANCELA_VENDA_PROTHEUS_Montadora.TXT"
	//MEMOWRITE("\CMDTM08\"+cARQ,cLinha3)
	MEMOWRITE("C:\CMDTM08\"+cARQ3,cLinha3)
	/*
	// CONEXAO FTP
	&&Conexão e envio para FTP
	oArqFtp := FtpArq():NewFtpArq()

	//A DEFINIR FORMA DE LOGIN NO FTP
	If oArqFtp:Connect(SuperGetMV('CAOA_CG03',.F.) , DEFAULT_FTP , SuperGetMV('CAOA_CG01',.F.), SuperGetMV('CAOA_CG02',.F.))
	oArqFtp:Transfer(cARQ ,"\System\CMDTM05\", cDirDest )
	oArqFtp:Disconnect()

	MsgAlert("Arquivo enviado, para verificação entre no diretório")
	Else
	Aviso("Não Foi possível Gerar o Arquivo, verifique os parametros")
	EndIf
	*/
Return
