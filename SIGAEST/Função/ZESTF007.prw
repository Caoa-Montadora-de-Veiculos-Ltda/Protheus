#Include "Protheus.Ch"
#Include "Totvs.Ch"
#include 'parmtype.ch'
#include "TBICONN.CH"
#include 'TOPCONN.CH'


#Define CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} ZESTF007.PRW
Função de Consulta de Estoque - CAOA
@author Sandro Ferreira
@since 13/04/2021
@version 1.0
@type function
/*/
User Function ZESTF007(_aParam)
Local _lJob := If( IsBlind(),.T.,.F.)
Local _lAbre		:= .F.
Local _lRet
Local _nPos   
Local _cEmpresa	
Local _cFilial 
Local aPergs    := {}
Private aRetP   := {}
Private	lGeraExcel := .F.


	If !_lJob
		aAdd(aPergs,    {2, "Tipo de Geração:"                , "EXCEL"      , {"EXCEL", "E-MAIL"}    ,     100, ".T.", .F.})

		If ParamBox(aPergs, "Posição Estoque Veiculos.", aRetP, , , , , , , , ,.T.) 

			If aRetP[1] == "EXCEL"
				lGeraExcel := .T.
			EndIf

		EndIf

	EndIf

    If _lJob
		ConOut("*************************************************************************************************************************"	+ CRLF)
		ConOut("----------- [ ZESTF007 ] - Inicio da funcionalidade "													                	+ CRLF)
		ConOut("*************************************************************************************************************************"	+ CRLF)
	EndIf

	//sendo job testar parametros
	If _lJob
		If ValType(_aParam) == "A"
			//VarInfo("Valores dos parametros recebidos pela rotina ZESTF007",_aParam)
			_cEmpresa 	:=  _aParam[1]
			_cFilial 	:=  _aParam[2]
			CONOUT("INICIANDO EMPRESA " + _cEmpresa)
			CONOUT("INICIANDO FILIAL "  + _cFilial)
			RpcClearEnv()
			RpcSetType(3)
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "EST"
			_lAbre		:= .T.
		ElseIf Type("cFilAnt") <> "C"
			_cEmpresa	:=	"01"
			_cFilial	:=  "2010022001"
			CONOUT("INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("INICIANDO FILIAL "+_cFilial)
			RpcClearEnv()
			RpcSetType(3)
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "EST"
			_lAbre		:= .T.
		EndIf
	EndIF
	CONOUT("INICIADA EMPRESA " + cEmpAnt)
	CONOUT("INICIADA FILIAL "  + cFilAnt)

    ConOut("*************************************************************************************************************************"	+ CRLF)
	ConOut("----------- [ ZESTF007 ] - VERIFICANDO SE JA EXISTE PROCESSAMENTO DO JOB  "														+ CRLF)
	ConOut("*************************************************************************************************************************"	+ CRLF)

	If !LockByName("ZESTF007",.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 1000 ) // Para o processamento por 1 segundo
			If LockByName("ZESTF007",.T.,.T.)
				_lRet := .T.
			EndIf
		Next	

		If !_lRet
			If !_lJob
				MsgInfo("Já existe um processamento em execução rotina ZESTF007, aguarde!")
			Else
				CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZESTF007] Já existe um processamento em execução, aguarde!")
				ConOut("*************************************************************************************************************************"	+ CRLF)
				ConOut("----------- [ ZESTF007 ] - Já existe um processamento em execução rotina ZESTF007 "														+ CRLF)
				ConOut("*************************************************************************************************************************"	+ CRLF)
			EndIf
			Break
		EndIf
	EndIf
    If !_lJob
		FWMsgRun(,{|| ZESTF007PRC(_lJob) },,"Realizando a consulta do estoque, aguarde...")
	Else
		CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZESTF007] Iniciado processamento da consulta de estoque ")
		ZESTF007PRC(_lJob)
	Endif
	UnLockByName("ZESTF007",.T.,.T.)
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZESTF007] Finalizado processamento da consulta de estoque")




//Caso abriu o processo empresa e filial tem que fechar
If  _lAbre	
	Reset Environment
Endif

Return Nil


/*/{Protheus.doc} ZESTF007PRC
Função para consulta de estoque dos produtos acabados e envia por email, destinatários no parametro: CMV_VEI014.
@author Sandro Ferreira 
@since 13/04/2021
@version 1.0
@type function
/*/
Static Function ZESTF007PRC(_lJob)

    Default _lJob       := .F.
	Private cCadastro	:= "Consulta o Estoque dos Produtos Acabados"
	
	//Função para consultar e carregar os dados da consulta.
	CarregaDados()
	
Return
 
/*/{Protheus.doc} CarDados
Função para carregar as informações da Consulta do Cliente.
@author FSW - DWC Consult
@since 24/02/2019
@version 1.0
@type function
/*/  
Static Function CarregaDados()
    Local _cPasta    := SuperGetMV( "CMV_VEI015" ,,"\temp\")  //Local de armazenamento do arquivo
	Local cEstoque   := GetNextAlias()
	Local cQuery	 := ""
	Local cArquivo	 := ""
	Local _cMail     := "" 
    Local _cMail1    := SuperGetMV( "CMV_VEI014" ,,"sandro.ferreira@caoa.com.br") //Destinatarios do email
	Local _cMail2    := SuperGetMV( "CMV_VEI016" ,,"sandro.ferreira@caoa.com.br") //Destinatarios do email
	Local _cMail3    := SuperGetMV( "CMV_VEI017" ,,"sandro.ferreira@caoa.com.br") //Destinatarios do email
    Local _cAssu     := "Posição de Estoque referente ao dia:   " +  dtoc(date())
    Local _cRot      := "ZESTF007" 
   	Local aAnexos    := {}
    Local cHtml      := ""
	Local cObsMail	 := ""
    Local cReplyTo   := ""
    Local cMailCC    := ""
    Local lMsgErro 	 := .T.
	Local lMsgOK 	 := .F.
	Local cSituacao  := ""  
	Local oFWMsExcel
	Local oExcel

	If lGeraExcel
		cArquivo	:= GetTempPath()+'estoqueveiculos_'+SUBSTRING(dtoc(date()),1,2)+SUBSTRING(dtoc(date()),4,2)+SUBSTRING(dtoc(date()),9,2)+'_'+SUBSTRING(time(),1,2) +SUBSTRING(time(),4,2) +SUBSTRING(time(),7,2)+'.xml'
	Else
		cArquivo	 := _cPasta + 'Estoque.xml'
	EndIf

	_cMail  := _cMail1 
    cMailCC := _cMail2 + _cMail3

	cHtml := "Bom dia. <br>"
	cHtml += "<br>"
	cHtml += "Em anexo a posição de estoque referente ao dia: " + dtoc(date()) + "<br>"
	cHtml += "<br>"

	If Select(cEstoque) > 0
		(cEstoque)->(DbCloseArea())
	EndIf

	cQuery := " SELECT  VV1.VV1_CODMAR      ,						    	            "
	cQuery += "         VV1.VV1_CHAINT      ,					                        "
	cQuery += "         VV1.VV1_CHASSI      , 							                "	
	cQuery += "         SB1.B1_COD          , 							                "
	cQuery += "         RTRIM(VV2_DESMOD)  DESCR ,							            "
	cQuery += "         VV1.VV1_MODVEI      , 							                " 
	cQuery += "         VV1.VV1_SEGMOD      ,							                 "
	cQuery += "         VV1.VV1_CHARED      ,							                "
	cQuery += "         SUBSTR(VV1_FABMOD, 1, 4) ||'/'||SUBSTR(VV1_FABMOD, 5, 4) FABMOD ,        "
	cQuery += "         VV1.VV1_DTHEMI      , 					                        "
  	cQuery += "     CASE 											                    "
	cQuery += "         WHEN VV1.VV1_CODMAR = 'CHE' THEN 'CHERY'		                "
	cQuery += "         WHEN VV1.VV1_CODMAR = 'HYU' THEN 'HYUNDAI'		                "
	cQuery += "         WHEN VV1.VV1_CODMAR = 'SBR' THEN 'SUBARU'		                "
	cQuery += "         WHEN VV1.VV1_CODMAR = 'OUT' THEN 'OUTROS'		                "  
	cQuery += "         ELSE										                                "
	cQuery += "             'NAO ENCONTRADO'								                        "
	cQuery += "         END AS DESMAR             , 							                    "
	cQuery += "     CASE 											                                "
	cQuery += "             WHEN VV1.VV1_SITVEI = '0' THEN '0=ESTOQUE'				                " 
	cQuery += "             WHEN VV1.VV1_SITVEI = '1' THEN '1=VENDIDO'				                "
	cQuery += "             WHEN VV1.VV1_SITVEI = '2' THEN '2=EM TRANSITO'			                "
	cQuery += "             WHEN VV1.VV1_SITVEI = '3' THEN '3=REMESSA'				                "
	cQuery += "             WHEN VV1.VV1_SITVEI = '4' THEN '4=CONSIGNADO'		                	"
	cQuery += "             WHEN VV1.VV1_SITVEI = '5' THEN '5=TRANSFERIDO'			                "
	cQuery += "             WHEN VV1.VV1_SITVEI = '6' THEN '6=RESERVADO'			                "
	cQuery += "             WHEN VV1.VV1_SITVEI = '7' THEN '7=PROGRESSO'			                "
	cQuery += "             WHEN VV1.VV1_SITVEI = '8' THEN '8=PEDIDO'				                "
	cQuery += "         ELSE										                                "
	cQuery += "             'X=NAO ENCONTRADO'								                        " 
	cQuery += "         END AS SITUACAO             ,                                               " 
	cQuery += "          CASE  WHEN EXISTS (  SELECT VRKCONS.VRK_PEDIDO FROM "  + RetSQLName("VRK") + " VRKCONS " 
   	cQuery += "                              JOIN "  + RetSQLName("VRJ") + " VRJCONS   "
	cQuery += "                                      ON VRJCONS.VRJ_FILIAL = VRKCONS.VRK_FILIAL    " 
	cQuery += "                                      AND VRJCONS.VRJ_PEDIDO = VRKCONS.VRK_PEDIDO  "
	cQuery += "                                      AND ( VRJCONS.VRJ_STATUS NOT IN ('C', 'R', 'F') OR ( VRJCONS.VRJ_STATUS = 'F' AND VRKCONS.VRK_NUMTRA = ' ' ) )  "
	cQuery += "                                      AND VRJCONS.D_E_L_E_T_ = ' '  "
	cQuery += "                                  WHERE VRKCONS.VRK_FILIAL = '2010022001' "  
 	cQuery += "                                 AND VRKCONS.VRK_CHAINT = VV1.VV1_CHAINT  "
	cQuery += "                                  AND VRKCONS.VRK_CANCEL IN ('0',' ')     "
 	cQuery += "                                 AND VRKCONS.D_E_L_E_T_ = ' ' )  THEN 1   "
 	cQuery += "                 ELSE 0  END AS PEDMONT,                                  "
	cQuery += "  	         CASE  WHEN EXISTS ( SELECT VVA.R_E_C_N_O_  FROM ABDHDU_PROT.VVA010 VVA  "
	cQuery += "                                  JOIN "  + RetSQLName("VV0") + " VV0 "
	cQuery += "                                      ON VV0.VV0_FILIAL = VVA.VVA_FILIAL " 
	cQuery += "                                      AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA "
	cQuery += "                                      AND VV0.D_E_L_E_T_ = ' ' "
	cQuery += "                                  JOIN "  + RetSQLName("VV9") + " VV9 "
	cQuery += "                                      ON VV9.VV9_FILIAL = VVA.VVA_FILIAL " 
	cQuery += "                                      AND VV9.VV9_NUMATE = VVA.VVA_NUMTRA "
	cQuery += "                                      AND VV9.D_E_L_E_T_ = ' '  "
	cQuery += "                              WHERE VVA.VVA_FILIAL = '2010022001'  "  
	cQuery += "                              AND VVA.VVA_CHAINT = VV1.VV1_CHAINT  "
	cQuery += "                              AND VVA.D_E_L_E_T_ = ' ' "
	cQuery += "                              AND VV9.VV9_STATUS NOT IN ('C','F','T','R','D') ) THEN 1 "  
	cQuery += "              ELSE 0  END AS ATEND, "
	cQuery += "      CASE  WHEN EXISTS ( SELECT VB0.R_E_C_N_O_  FROM "  + RetSQLName("VB0") + " VB0 "
	cQuery += "                                      WHERE "   
	cQuery += "                                      VB0.VB0_CHAINT = VV1.VV1_CHAINT "
	cQuery += "                                      AND VB0.VB0_DATDES = ' '  "
	cQuery += "                                      AND ( VB0.VB0_DATVAL > TO_CHAR(SYSDATE,'YYYYMMDD')  OR ( VB0.VB0_DATVAL = TO_CHAR(SYSDATE,'YYYYMMDD')  AND TO_CHAR(VB0.VB0_HORVAL,'HH24') > TO_CHAR(SYSDATE, 'HH24') )) "
	cQuery += "                                      AND VB0.D_E_L_E_T_ = ' ' )  THEN 1  "
	cQuery += "                  ELSE 0  "
	cQuery += "                  END AS BLOQ, "
    cQuery += "         VV2.VV2_OPCION             , 							                "
	cQuery += "     	RTRIM(VX5DOPC.VX5_DESCRI) AS DESCOP,                                     "
	cQuery += "     	RTRIM(VX5EXT.VX5_DESCRI) AS COREXT,                                     "
	cQuery += "     	VV2.VV2_COREXT ,                                               "
	cQuery += "     	RTRIM(VX5EXT.VX5_DESCRI) AS COREXT,                                     "
    cQuery += "     	VV2.VV2_CORINT ,                                               "
    cQuery += "     	RTRIM(VX5INT.VX5_DESCRI) AS CORINT,                                     "
	cQuery += "         CASE 										                                "
	cQuery += "             WHEN VV1.VV1_IMOBI = '0' THEN 'Não Imobilizado'					                "
	cQuery += "             WHEN VV1.VV1_IMOBI = '1' THEN 'Imobilizado'					                "
	cQuery += "         ELSE										                                "
	cQuery += "             'X=NAO ENCONTRADO'								                        "
	cQuery += "         END AS IMOBILIZADO,								                            "
    cQuery += "    CASE 																			"
    cQuery += "        WHEN VV1.VV1_COMVEI = '0' THEN 'GASOLINA' 									"
    cQuery += "        WHEN VV1.VV1_COMVEI = '1' THEN 'ALCOOL' 										"
    cQuery += "        WHEN VV1.VV1_COMVEI = '2' THEN 'DIESEL' 										"
    cQuery += "        WHEN VV1.VV1_COMVEI = '3' THEN 'GAS NATURAL VEICULAR' 						"
    cQuery += "        WHEN VV1.VV1_COMVEI = '4' THEN 'ALCOOL/GASOLINA' 							"
    cQuery += "        WHEN VV1.VV1_COMVEI = '5' THEN 'AlCOOL/GASOLINA/GNV'							"
    cQuery += "        WHEN VV1.VV1_COMVEI = '9' THEN 'SEM COMBUSTIVEL'								"
    cQuery += "        WHEN VV1.VV1_COMVEI = 'A' THEN 'GASOGENICO'									"
    cQuery += "        WHEN VV1.VV1_COMVEI = 'B' THEN 'GAS METANO'									"
    cQuery += "        WHEN VV1.VV1_COMVEI = 'C' THEN 'ELETRICO/FONTE INTERNA'						"
    cQuery += "        WHEN VV1.VV1_COMVEI = 'D' THEN 'ELETRICO/FONTE EXTERNA'						"
    cQuery += "        WHEN VV1.VV1_COMVEI = 'E' THEN 'GAS/GAS NATURAL COMBUSTIVEL'					"
    cQuery += "        WHEN VV1.VV1_COMVEI = 'F' THEN 'ALCOOL/GAS NATURAL COMBUSTIVEL'				"
    cQuery += "        WHEN VV1.VV1_COMVEI = 'G' THEN 'DIESEL/GAS NATURAL COMBUSTIVEL'				"
    cQuery += "        WHEN VV1.VV1_COMVEI = 'H' THEN 'ALCOOL/GAS NATURAL VEICULAR'					"
    cQuery += "        WHEN VV1.VV1_COMVEI = 'I' THEN 'GASOLINA/GAS NATURAL VEICULAR'				"
    cQuery += "        WHEN VV1.VV1_COMVEI = 'J' THEN 'DIESEL/GAS NATURAL VEICULAR'					"
    cQuery += "        WHEN VV1.VV1_COMVEI = 'K' THEN 'GASOLINA/ELETRICO'							"
    cQuery += "        ELSE 'SEM COMBUSTIVEL' 														"
    cQuery += "    END AS COMBUSTIVEL, 																"
    cQuery += "        ( SELECT COALESCE( TRUNC(SYSDATE - TO_DATE(VVF_DATMOV, 'YYYYMMDD'), 0), 0 ) DIAESTQ  "
    cQuery += "            FROM (  SELECT * FROM ( SELECT VVF_DATMOV, '20' || SUBSTR(VVF_DTHEMI, 7, 2) || '-' || SUBSTR(VVF_DTHEMI, 4, 2) || '-' || SUBSTR(VVF_DTHEMI, 1, 2) || ' ' || SUBSTR(VVF_DTHEMI, 10, 8) "
    cQuery += "                FROM "  + RetSQLName("VVF") + " VVF " 
    cQuery += "                    INNER JOIN " + RetSQLName("VVG") + " VVG" 
    cQuery += "                    ON VVG.VVG_FILIAL = VVF.VVF_FILIAL  "
    cQuery += "                    AND VVG.VVG_TRACPA = VVF.VVF_TRACPA  "
    cQuery += "                        AND VVG.D_E_L_E_T_ = ' ' "
    cQuery += "                    WHERE VVG.VVG_CHAINT = VV1.VV1_CHAINT " 
    cQuery += "                    AND VVF.VVF_SITNFI <> '0'  "
    cQuery += "                    AND VVF.VVF_OPEMOV = '0' "
    cQuery += "                    AND VVF.D_E_L_E_T_ = ' ' ORDER BY 2 DESC ) WHERE ROWNUM <= 1) ) DIAESTQ, "
    cQuery += "        COALESCE( ( SELECT LISTAGG (VRKLST.VRK_PEDIDO, '/') WITHIN GROUP ( ORDER BY VRKLST.VRK_PEDIDO ) COLPEDIDO  "
    cQuery += "        FROM " + RetSQLName("VRK") + " VRKLST  "
    cQuery += "            JOIN  " + RetSQLName("VRJ") + " VRJLST "   
    cQuery += "                ON VRJLST.VRJ_FILIAL = VRKLST.VRK_FILIAL  "  
    cQuery += "                AND VRJLST.VRJ_PEDIDO = VRKLST.VRK_PEDIDO  "
    cQuery += "                AND ( VRJLST.VRJ_STATUS NOT IN ('C', 'R', 'F') OR ( VRJLST.VRJ_STATUS = 'F' AND VRKLST.VRK_NUMTRA = ' ' ) )  "  
    cQuery += "                AND VRJLST.D_E_L_E_T_ = ' '  "
    cQuery += "        WHERE VRKLST.VRK_FILIAL = '2010022001' "  
    cQuery += "        AND VRKLST.VRK_CHAINT = VV1.VV1_CHAINT "
    cQuery += "        AND VRKLST.VRK_CANCEL IN ('0',' ')  "
    cQuery += "        AND VRKLST.D_E_L_E_T_ = ' '  ), '         ') COLPEDIDO, "
    cQuery += "          COALESCE( ( SELECT LISTAGG (VVA.VVA_NUMTRA, '/') WITHIN GROUP ( ORDER BY	VVA.VVA_NUMTRA	) COLATEND "
    cQuery += "          FROM " + RetSQLName("VVA") + " VVA  "     
    cQuery += "              JOIN " + RetSQLName("VV9") + " VV9  "  
    cQuery += "                 ON VV9.VV9_FILIAL = VVA.VVA_FILIAL   " 
    cQuery += "                  AND VV9.VV9_NUMATE = VVA.VVA_NUMTRA  "
    cQuery += "                  AND VV9.D_E_L_E_T_ = ' '   "
    cQuery += "          WHERE VVA.VVA_FILIAL = '2010022001' "  
    cQuery += "          AND VVA.VVA_CHAINT = VV1.VV1_CHAINT  "
    cQuery += "          AND VVA.D_E_L_E_T_ = ' ' "
    cQuery += "          AND VV9.VV9_STATUS NOT IN ('C','F','T','R','D')  ), '          ') COLATEND , "
	cQuery += "         NVL( (  SELECT * FROM   ( SELECT SUBSTR(VB0.VB0_DATBLO,7,2)||SUBSTR(VB0.VB0_DATBLO,5,2)||SUBSTR(VB0.VB0_DATBLO,1,4) FROM VB0010 VB0	"
	cQuery += "                                     WHERE VB0.D_E_L_E_T_ = ' '	        			"
 	cQuery += "                                     AND VB0.VB0_CHAINT = VV1.VV1_CHAINT	    		"
	cQuery += "                                     ORDER BY VB0.VB0_DATBLO DESC 			    	"
	cQuery += "                                 )								                    "
	cQuery += "                 WHERE ROWNUM = 1 								                    "
	cQuery += "         ),'') BLOQUEIO,							                                "
	cQuery += "          NVL( (  SELECT * FROM  ( SELECT SUBSTR(VB0.VB0_DATDES,7,2)||SUBSTR(VB0.VB0_DATDES,5,2)||SUBSTR(VB0.VB0_DATDES,1,4) FROM VB0010 VB0 "
	cQuery += "                                     WHERE VB0.D_E_L_E_T_ = ' '				        "
 	cQuery += "                                     AND VB0.VB0_CHAINT = VV1.VV1_CHAINT			    "
	cQuery += "                                     ORDER BY VB0.VB0_DATBLO DESC 				    "
	cQuery += "                                 )								                    "
	cQuery += "                 WHERE ROWNUM = 1 								                    "
	cQuery += "         ),'') DESBLOQUEIO,							                            "
 	cQuery += "          NVL( (  SELECT * FROM  ( SELECT VV2.VV2_CORINT FROM VV2010 VV2 "
	cQuery += "                                     WHERE VV2.D_E_L_E_T_ = ' '				        "
    cQuery += "                                     AND VV2.VV2_FILIAL = '2010022001' "
	cQuery += "                                     AND VV2.VV2_CODMAR = VV1.VV1_CODMAR	    	    "
	cQuery += "                                     AND VV2.VV2_MODVEI = VV1.VV1_MODVEI	    	    "
	cQuery += "                                     AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD	    	    "
	cQuery += "                                 )								                    "
	cQuery += "                 WHERE ROWNUM = 1 					 			                    "
	cQuery += "         ),'---') CORINT,	                    		                            "
	cQuery += "          NVL( (  SELECT * FROM  ( SELECT VV2.VV2_COREXT FROM VV2010 VV2 "
	cQuery += "                                     WHERE VV2.D_E_L_E_T_ = ' '				        "
    cQuery += "                                     AND VV2.VV2_FILIAL = '2010022001' "
	cQuery += "                                     AND VV2.VV2_CODMAR = VV1.VV1_CODMAR	    	    "
	cQuery += "                                     AND VV2.VV2_MODVEI = VV1.VV1_MODVEI	    	    "
	cQuery += "                                     AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD	    	    "
	cQuery += "                                 )		 						                    "
	cQuery += "                 WHERE ROWNUM = 1 								                    "
	cQuery += "         ),'---') COREXT							                            "
	cQuery += " FROM " + RetSQLName('VV1') + " VV1 " 
	cQuery += " INNER JOIN " + RetSQLName('SB1') + " SB1 "
	cQuery += "         ON RTRIM(VV1_MODVEI) || RTRIM(VV1_SEGMOD) = RTRIM(SB1.B1_COD)			    "
	cQuery += "         AND SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '201002    ' "		
    cQuery += " LEFT JOIN " + RetSQLName('VV2') + " VV2 "              
    cQuery += "     ON VV2.VV2_FILIAL =   '2010022001' "	
    cQuery += "     AND VV2.VV2_CODMAR = VV1.VV1_CODMAR                    "
    cQuery += "     AND VV2.VV2_MODVEI = VV1.VV1_MODVEI                    "
    cQuery += "     AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD                    "
    cQuery += "     AND VV2.D_E_L_E_T_ = ' '                               "
    cQuery += " LEFT JOIN " + RetSQLName('VX5') + " VX5DOPC "
    cQuery += "    ON VX5DOPC.VX5_FILIAL =  '          ' "	
    cQuery += "    AND VX5DOPC.VX5_CHAVE = '068'                              "
    cQuery += "    AND VX5DOPC.VX5_CODIGO = VV2.VV2_OPCION                        "
	cQuery += "    AND VX5DOPC.D_E_L_E_T_ = ' '                                   "
    cQuery += " LEFT JOIN " + RetSQLName('VX5') + " VX5EXT "
    cQuery += "   ON VX5EXT.VX5_FILIAL =  '          ' "	
    cQuery += "   AND VX5EXT.VX5_CHAVE = '067'                                   "
    cQuery += "   AND VX5EXT.VX5_CODIGO = VV2.VV2_COREXT                         "
    cQuery += "   AND VX5EXT.D_E_L_E_T_ = ' '                                    "
    cQuery += " LEFT JOIN " + RetSQLName('VX5') + " VX5INT "
    cQuery += "   ON VX5EXT.VX5_FILIAL =  '          ' "		
    cQuery += "    AND VX5INT.VX5_CHAVE = '066'                              "
    cQuery += "    AND VX5INT.VX5_CODIGO = VV2.VV2_CORINT                        "
	cQuery += "    AND VX5INT.D_E_L_E_T_ = ' '                                   "
	cQuery += " WHERE VV1.D_E_L_E_T_ = ' '									                        "
	cQuery += " AND VV1_FILIAL     =	'201002    ' "	
	cQuery += " AND (( VV1.VV1_SITVEI = '0' AND VV1.VV1_TRACPA <> ' ' ) OR VV1.VV1_SITVEI IN ('2','8') )		" 
	cQuery += " ORDER BY DIAESTQ	DESC	" 

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cEstoque,.F.,.T.)
 
	If Select(cEstoque) > 0
        //Criando o objeto que irá gerar o conteúdo do Excel
	    oFWMsExcel := FWMSExcel():New()

	    //Criando a Aba - Posição de estoque
	    oFWMsExcel:AddworkSheet("Planilha Estoque")
 
 	    //Criando a Tabela
	    oFWMsExcel:AddTable("Planilha Estoque" ,"Estoque")
	    oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Marca"              ,1)
	    oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Descrição"    	   ,1)
	    oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Mod Veiculo"        ,1)	
        oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Descr. Mod."        ,1)
        oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Segmento"           ,1)
        oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Opcionais"          ,1)
		oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Descr. Opcional"    ,1)
		oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Cor Externa"        ,1)
		oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Descr. Cor Externa" ,1)
        oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Cor Interna"        ,1)
		oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Descr. Cor Interna" ,1)
        oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Chassi"             ,1)
	    oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Chassi Int"         ,1)
        oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Ano Fabr/Mod"       ,1)
		oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Combustivel"        ,1)
		oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Chassi Reduz"       ,1)
	    oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Imobilizado"        ,1)
		oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Situação"           ,1)
	    oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Pedido Relacion."   ,1) 
        oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Atend. Relacion."   ,1)  
	    oFWMsExcel:AddColumn("Planilha Estoque","Estoque","Dias de Estoque"    ,1) 

 		(cEstoque)->(DbGoTop())
		While !(cEstoque)->(EOF())

			cSituacao    := "DISPONÍVEL"

			If (cEstoque)->BLOQ    = 1
			   cSituacao := "BLOQUEADO"
			Endif

			If (cEstoque)->PEDMONT = 1
			   cSituacao := "REL. PEDIDO"
			Endif
			
			If (cEstoque)->ATEND   = 1
			   cSituacao := "REL. ATENDIMENTO"
			Endif

            oFWMsExcel:AddRow("Planilha Estoque","Estoque",{;
			             (cEstoque)->VV1_CODMAR  ,;
						 (cEstoque)->DESMAR      ,;
						 (cEstoque)->VV1_MODVEI  ,;
						 (cEstoque)->DESCR       ,;
						 (cEstoque)->VV1_SEGMOD  ,;
					     (cEstoque)->VV2_OPCION  ,;         
						 (cEstoque)->DESCOP      ,;
						 (cEstoque)->VV2_COREXT  ,;
						 (cEstoque)->COREXT      ,;
						 (cEstoque)->VV2_CORINT  ,;
						 (cEstoque)->CORINT      ,;
						 (cEstoque)->VV1_CHASSI  ,;
						 (cEstoque)->VV1_CHAINT  ,;
						 (cEstoque)->FABMOD  ,;
						 (cEstoque)->COMBUSTIVEL ,;
						 (cEstoque)->VV1_CHARED  ,;
						 (cEstoque)->IMOBILIZADO ,;
						 cSituacao   			 ,;
						 (cEstoque)->COLPEDIDO   ,;
						 (cEstoque)->COLATEND    ,;
						 (cEstoque)->DIAESTQ     })
			(cEstoque)->(DbSkip()) 
		EndDo
		
        //Ativando o arquivo e gerando o xml
	    oFWMsExcel:Activate()
	    oFWMsExcel:GetXMLFile(cArquivo)

		If lGeraExcel
		
			//Abrindo o excel e abrindo o arquivo xml
			oExcel := MsExcel():New() 			    //Abre uma nova conexão com Excel
			oExcel:WorkBooks:Open(cArquivo) 	    //Abre uma planilha
			oExcel:SetVisible(.T.) 				    //Visualiza a planilha
			oExcel:Destroy()						//Encerra o processo do gerenciador de tarefas


		Elseif Select(cEstoque) > 0

           	//-- REGISTRO DE HISTORICO (TABELA SZU)
	        cObsMail := "ENVIO DA POSIÇÃO DE ESTOQUE DE:   " + dtoc(date())
               	
            //-- Inclui Planilha gerada como anexo
	        Aadd(aAnexos, cArquivo)

	        //   	  (cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,Rotina ,	Observação	, cReplyTo	)
            U_ZGENMAIL(	_cMail      ,cMailCC    , _cAssu    ,cHtml      ,aAnexos    ,lMsgErro  ,lMsgOK	    , _cRot ,     cObsMail  , cReplyTo )                
	    
		EndIf
	EndIf

	If Select(cEstoque) > 0
		(cEstoque)->(DbCloseArea())
	EndIf

Return
