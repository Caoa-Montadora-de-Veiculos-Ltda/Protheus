#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 

#Define 0210 1
#Define K001 2
#Define K100 3
#Define K200 4
#Define K210 5
#Define K215 6
#Define K220 7
#Define K230 8
#Define K235 9
#Define K250 10
#Define K255 11
#Define K260 12
#Define K265 13
#Define K270 14
#Define K275 15
#Define K280 16
#Define K300 17
#Define K301 18
#Define K302 19
#Define K990 20
#Define 0200 21
#Define K290 22
#Define K291 23
#Define K292 24

//Variaveis Static para gravar a posição dos layout em cache
static _ALIQ
static _ALIQ_COFINS 
static _ALIQ_ICMS
static _ALIQ_ISS
static _ALIQ_PIS 
static _ANO_COMPE
static _B_ICMS_AU
static _B_IPI_AUX
static _B_ISEN_IC
static _B_ISEN_IP
static _B_OUTR_IC
static _B_OUTR_IP
static _B_ST_ICMS
static _B_TRIB_IC
static _B_TRIB_IP
static _B_TRIB_IS
static _BASEICMSV
static _BASE_ICMS 
static _BASE_II 
static _BASE_IPI 
static _BASE_IR
static _BASE_ISS
static _C_REF_FIS
static _C_REF_MOD
static _C_TRIB_IP
static _C_TRIB_IS
static _CD_RECEIT
static _CD_SERV_L
static _CD_SERVIC
static _CLAS_ITEM 
static _CLASS_DOC
static _CNPJ_COLE
static _CNPJ_ENTR
static _COD_AJUST
static _COD_ALMOX
static _COD_BARRAS 
static _COD_CFO
static _COD_CMEDIDA 
static _COD_CONTA
static _COD_CTRLI
static _COD_CUSTO
static _COD_DARF
static _COD_DOCTO
static _COD_EMPRESA 
static _COD_ENT_S
static _COD_ESTAB 
static _COD_ESTOQ
static _COD_FIS_JUR 
static _COD_INF_A
static _COD_INSUM
static _COD_MEDIDA 
static _COD_MODELO 
static _COD_NALADI 
static _COD_NBM 
static _COD_NCM 
static _COD_OBS_L
static _COD_OBSER
static _COD_OP
static _COD_OPERA
static _COD_PRODUTO 
static _COD_ST_A
static _COD_ST_B
static _COD_UND_PADRAO 
static _CRED_ICMS
static _CUSTO_ITE
static _CUSTO_UNI
static _D_COMP_AJ
static _D_COMPLEM
static _D_LNC_PIS
static _D_NAT_SER
static _DAT_CONSU
static _DAT_DI 
static _DAT_ENTRADA 
static _DAT_EST_F
static _DAT_FIM
static _DAT_FIM_A
static _DAT_INI_A
static _DAT_NF 
static _DAT_PRODU
static _DATA_EMIS
static _DATA_FATO
static _DATA_PRODUTO 
static _DATA_REF
static _DESC_COMP
static _DESCR_DETALHADA 
static _DESCRICAO 
static _DT_FIM
static _DT_FIM_CO
static _DT_FIM_OP
static _DT_FIS_RE
static _DT_FISCAL
static _DT_INI
static _DT_INI_CO
static _DT_INI_OP
static _DT_INVENT
static _DT_MOVTO
static _DT_SAI_RE
static _DT_SAIDA
static _DT_VENCTO
static _DT_X2009
static _DT_X2010
static _DT_X2018
static _EMBALAGEM
static _ESP_TRIBU
static _GRUPO_CON
static _ICMS_ALIQ_VLR 
static _IDENT_FIS
static _IE_COLETA
static _IE_ENTREG
static _IND_APUR_
static _IND_BEM_P
static _IND_CFINCID 
static _IND_CLASSIF_ICMSS 
static _IND_COMPR
static _IND_CONTR
static _SELO_CONTROLE 
static _IND_DEB_C
static _IND_EMBAL
static _IND_FABRIC_ESTAB 
static _IND_FATURA
static _IND_FIS_JUR 
static _IND_FUNRURAL 
static _IND_ICINCID 
static _IND_ICOMP
static _IND_INS_P
static _IND_INSUM
static _IND_LOCAL
static _IND_MAT_S
static _IND_MOT_I
static _IND_NAT_B
static _IND_NAT_F
static _IND_NATFR
static _IND_NFE_D
static _IND_OP_PR
static _IND_PETR_ENERG 
static _IND_PI_CO
static _IND_PIINCID 
static _IND_POS_N
static _IND_PRD_INCENTIV 
static _IND_PRODUTO 
static _IND_REGIDO_SUBST 
static _IND_S_PRO
static _IND_SITUA
static _IND_ST_PR
static _IND_TPCOR
static _IND_TPORD
static _IND_TPSER
static _INSS
static _INSS_PROD
static _IPI_ALIQ_VLR 
static _IRRF
static _ISS
static _MES_COMPE
static _MOV_E_S_R
static _MOVTO_E_S
static _MUNIC_COL
static _MUNIC_DES
static _MUNIC_ENT
static _MUNIC_ORI
static _NAT_ESTOQ
static _NAT_SERV
static _NATUR_OP
static _NORM_DEV
static _NUM_AUTEN
static _NUM_CONTR
static _NUM_DEC_I
static _NUM_DI 
static _NUM_DOCFI
static _NUM_DOCTO
static _NUM_FIN_D
static _NUM_INI_D
static _NUM_ITEM 
static _NUM_NF 
static _NUM_PROCE
static _NUM_REF_D
static _OP_PRODUT
static _ORIGEM 
static _PERC_PERD
static _PERIODO_R
static _PRECO_ITE
static _PRECO_UNI
static _QTD_CORRE
static _QTD_FABR
static _QTD_MAX_U
static _QTD_MOVTO
static _QTD_ORIGE
static _QTD_PRODU
static _QTD_TRANS
static _QTD_UND_COM 
static _QTD_UND_MED 
static _QTD_USADA
static _QUANTIDADE
static _REF_FIS_J
static _REF_SERIE
static _S_COFINS
static _S_PIS
static _SERIE_DOC
static _SERIE_NF 
static _SITUACAO
static _ST_S_COFI
static _ST_S_PIS
static _SUB_PRODU
static _SUBST_PRO
static _T_ICAUX
static _T_ICMS
static _T_IPI
static _T_IPI_AUX
static _T_IR
static _TIPO_DI 
static _TRIBUTO
static _UF_COLETA
static _UF_DESTIN
static _UF_ENTREG
static _UF_ORIG_D
static _V_A_COFIN
static _V_A_CSLL
static _V_A_ICMS
static _V_A_IPI
static _V_A_IR
static _V_A_ISS
static _V_A_PIS
static _V_A_STCOF
static _V_A_STPIS
static _V_ALSTICM
static _V_B_COF_S
static _V_B_COFIN
static _V_B_CSLL
static _V_B_PIS
static _V_B_PIS_S
static _V_COF_RET
static _V_COF_ST
static _V_CONT_IT
static _V_ST_ICMS
static _V_TOT_CUS
static _V_TOT_NOT
static _VIA_TRANS
static _VLR_BRUTO
static _VLR_COFINS 
static _VLR_CSLL
static _VLR_DEDUCAO 
static _VLR_DESCO
static _VLR_DESP_ADUAN 
static _VLR_FRETE 
static _VLR_ICISENTA 
static _VLR_ICMS 
static _VLR_ICOUTRAS 
static _VLR_II 
static _VLR_INF_A
static _VLR_IPI 
static _VLR_IPISENTA 
static _VLR_IPOUTRAS 
static _VLR_IR
static _VLR_IR_RE
static _VLR_ISS
static _VLR_ITEM
static _VLR_NF 
static _VLR_OUTRA
static _VLR_PIS 
static _VLR_PIS_R
static _VLR_PIS_S
static _VLR_PRODUTO 
static _VLR_SEGURO 
static _VLR_SERVI
static _VLR_TOT
static _VLR_TRANS
static _VLR_UNIT
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CMVMSF06 º Autor ³ Jose Roberto       º Data ³  31/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para exportação de Dados - Protheus -> Mastersaf    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico CAOA                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador³  Data   ³ Motivo da Alteracao                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ³         ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

@type		Function
@version	1.0
@autor		DAC Denilso
@since		26/08/2020
@history    DAC Denilso 26/08/2020
			- 	Chamado 422291 DAC 26/08/2020 Problema / Solicitação:Correção na extração SAFX07 e SAFX09 (Acertos Fiscais), documentação em anexo.
				SAFX07 – IND_NAT_BASE_CRED (campo FT_CODBCC) e IND_NAT_FRETE (FT_INDNTFR)
				SAFX09 - IND_NAT_BASE_CRED (campo FT_CODBCC)
			DAC Denilso 26/01/2021
			-	Atualização conforme chamado INC0012933 - Notas de Serviço sem DATA LANC PIS COFINS 
			DAC Denilso 24/02/2021
			- INC0020855 - SAFX52
			  Ajustado campo de retornos valores estava saindo com pontuação
			  Ajustado campos que não estavão sendo enviados 5 campos
			  Alterado geração de TXT para possuir o tamanho conforme layout da integração MasterSaf, isto ajudara também na visualização de um excel
			DAC Denilso 24/02/2021
			- INC0020803 - SAFX113 - ALTERAR IMPOSTOS DE ENTRADA BASEADO NO SD1
			  Ajustado campos CDA->CDA_BASE, ALIQUOTA_ICMS, VLR_ICMS
			Sandro Ferreira 22/02/2022
			- Correção da extração de carga da SAFX49 para as Notas Fiscais de Importação: Faltando Tipo da DI.
			- Correção da extração de carga da SAFX08 para as Notas Fiscais de Importação: Faltando Data DI e Número 
			- ESPFUN - MSAF001 - Data e Numero da Declaração de Importação
			  Incluido os campos W6_MODAL_D , W6_DTREG_D e W6_DI_NUM
			Reinaldo Rabelo 06/01/2023
			- Correção na Extração da SAFX113 valores de ICMS para pegar da Tabela SFT 
			- Correção na Extração da SAFX08  valores de ICMS para pegar da Tabela SFT para pegar o valro correto após manutenção.
			- Manutenção na Static Function ExecQuery separando a geração de cada arquivo MasterSaf em funções separada.
*/

User Function CMVMSF06()

	Local nOpc := 0
	Local aRet := {}
	Local aParamBox := {}

	//*********************************
	// variavel para ativar o Gravar as Consulta em arquivo para investigação
	Private lDbeug := .T.
	//*********************************

	Private cTitulo  := "Exportação Protheus -> MasterSAF"
	Private aSay     := {}
	Private aButton  := {}
	Private dDataIni := cToD("  /  /  ")
	Private dDataFim := cToD("  /  /  ")
	Private cLocDest := ""
	Private cFileOut := ""
	Private cCodFil	 := ""
	Private cCodProd := ""
	Private cProdDe  := ""
	Private cProdAte := ""
	Private lSAFX07  := .F.
	Private lSAFX08  := .F.
	Private lSAFX09  := .F.
	Private lCabec   := .F.
	Private cFilDe   := ""
	Private cFilAte  := ""
	Private lSAFX108 := .F.
	Private lSAFX109 := .F.
	Private lSAFX16  := .F.
	Private lSAFX17  := .F.
	Private lSAFX18  := .F.
	Private aSG1     := {}
	Private lSAFX112 := .F.
	Private lSAFX113 := .F.
	Private lSAFX114 := .F.
	Private lSAFX116 := .F.
	Private lSAFX118 := .F.
	Private lSAFX153 := .F.
	Private lSAFX154 := .F.
	Private lSAFX235 := .F.
	Private lSAFX236 := .F.

	Private cTab       := ""
	Private cCliForDe  := ""
	Private cCliForAte := ""
	Private cDocFisDe  := ""
	Private cDocFisAte := ""

	// variaveis para manipular o txt de erros
	Private cFile      := ""     
	Private nHdlError  := 0
	Private lFirstErro := .T.
	Private lExecuta   := .T.
	Private cErro      := ""
	Private cErroAll   := ""

	//--Variavel que carrega as notas fiscais selecionadas via markbrowse
	Private __cSelNfs := ""

	AAdd( aSay , "Esta Rotina tem como objetivo gerar informações do ERP Protheus " )
	AAdd( aSay , "para o MasterSAF via arquivo TXT conforme documentação técnica " )
	//AAdd( aSay , "Project Charter - XXXXXX")   
	AAdd( aSay , "")
	AAdd( aSay, "Clique para continuar...")

	aAdd( aButton, { 1,.T.,{|| nOpc := 1,FechaBatch()}})
	aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )

	FormBatch( cTitulo, aSay, aButton )

	//Se Clicou no OK segue com processamento - Parambox -> MarkBrowse
	If nOpc == 1

		chkfile("SZR") // verifica se a tabela existe e está OK
		aAdd(aParamBox,{1 ,"Filial Inicial:"             ,Space(TamSX3("FT_FILIAL")[1]),""    ,"","SM0","", 50,.F.}) // Tipo caractere
		aAdd(aParamBox,{1 ,"Filial Final:"               ,Space(TamSX3("FT_FILIAL")[1]),""    ,"","SM0","", 50,.F.}) // Tipo caractere
		aAdd(aParamBox,{1 ,"Data Inicial:"               ,Date()                       ,""    ,"",""   ,"", 50,.T.}) // Tipo caractere
		aAdd(aParamBox,{1 ,"Data Final :"                ,Date()                       ,""    ,"",""   ,"", 50,.T.}) // Tipo caractere
		aAdd(aParamBox,{1 ,"Produto Inicial:"            ,Space(TamSX3("B1_COD")[1])   ,""    ,"","SB1","", 80,.F.}) // Tipo caractere
		aAdd(aParamBox,{1 ,"Produto Final:"              ,Repl("Z",TamSX3("B1_COD")[1]),""    ,"","SB1","", 80,.F.}) // Tipo caractere
		aAdd(aParamBox,{1 ,"Cliente/Fornecedor Inicial:" ,Space(TamSX3("A1_COD")[1])   ,""    ,"",""   ,"", 80,.F.}) // Tipo caractere
		aAdd(aParamBox,{1 ,"Cliente/Fornecedor Final:"   ,Repl("Z",TamSX3("A1_COD")[1]),""    ,"",""   ,"", 80,.F.}) // Tipo caractere
		aAdd(aParamBox,{1 ,"Nota Fiscal Inicial:"        ,Space(TamSX3("F1_DOC")[1])   ,""    ,"",""   ,"", 80,.F.}) // Tipo caractere
		aAdd(aParamBox,{1 ,"Nota Fiscal Final:"          ,Repl("Z",TamSX3("F1_DOC")[1]),""    ,"",""   ,"", 80,.F.}) // Tipo caractere
		aAdd(aParamBox,{1 ,"Local do Arquivo:"           ,"C:\TEMP\"+Space(50)         ,"@S50","","",""   ,100,.T.}) // Tipo caractere
		
		aAdd(aParamBox,{2 ,"Gera com cabeçalho:"         ,1,{"Não","Sim"},40,"",.F.})
		aAdd(aParamBox,{2 ,"Selecionar Notas Fiscais:"   ,1,{"Não","Sim"},40,"",.F.})

		If ParamBox(aParamBox,"Parametros para geração do Arquivo...",@aRet)
			cFilDe     := aRet[1]
			cFilAte    := aRet[2]
			dDataIni   := aRet[3]
			dDataFim   := aRet[4]
			cProdDe    := aRet[5]
			cProdAte   := aRet[6]
			cCliForDe  := aRet[7]
			cCliForAte := aRet[8]
			cDocFisDe  := aRet[9]
			cDocFisAte := aRet[10]
			cLocDest   := alltrim(aRet[11])
			lCabec     := aRet[12]==IIf(ValType(aRet[12])=="N",2,"Sim")
			IF substr(cLocDest,len(cLocDest),1) <> "\"
				cLocDest += "\"
			Endif

			If aRet[13] == IIf( ValType(aRet[13]) == "N", 2, "Sim" )
				zSelNfs()
			EndIf
			
			MontaBrw()
		EndIF
	EndIF

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MontaBrw ³ Autor | JRCARVALHO   			  ³ Data ³ 31/10/18           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta tela com a Lista das Tabelas Para Integração MasterSAF           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico CAOA- Interface MasterSAF                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontaBrw( )          

	Local cArqTmp   := "" 
	Local aCmpTrb	:= {}
	Local aCampos 	:= {}

	Private cMarca 	:= GetMark()   
	Private bMark   := {|| MarcaItem()}
	Private cCadastro := 'Seleção de Tabelas para Exportar' 
	Private aRotina := {} 

	//Alimenta Variaveis MARKBROWSE
	//Menu da tela 
	aRotina := {{ "Exportar"		,"U_MS06ExpTab()" 		, 0, 4},;    
				{ "Marcar Todos" 	,"U_MS06MarcaTudo()" 	, 0, 4},;
				{ "Desmarcar Todos" ,"U_MS06DesmrkTudo()" 	, 0, 4},;
				{ "Inverter Todos" 	,"U_MS06InvertAll()" 	, 0, 4}}          

	//Campos que serão exibidos na tela
	aCampos := { {'_OK' 	,"",'OK'			},;
				{"TABELA" 	,"",'Tabela' 		},; 					
				{"TABDESC"	,"",'Descrição' 	} }
						
	//Campos para criacao do arquivo temporario 
	aCmpTrb := { {"_OK" 	,"C",02,0},;
				{"TABELA"	,"C",08,0},;
				{"TABDESC"	,"C",75,0} }
										
	// cria a tabela temporária
	cArqTmp := Criatrab(,.F.)
	MsCreate(cArqTmp,aCmpTrb,"DBFCDX") 
	// atribui a tabela temporária ao alias TRB
	dbUseArea(.T.,"DBFCDX",cArqTmp,"TRB",.T.,.F.)
	IndRegua("TRB",cArqTMP,"TABELA","","","Selecionado Registros")
	
	// alimenta a tabela temporária
	Montagrid()

	//SINTAXE -> MarkBrow ( [ cAlias ] [ cCampo ] [ cCpo ] [ aCampos ] [ lInverte ] [ cMarca ] [ cCtrlM ] [ uPar8 ] [ cExpIni ] [ cExpFim ] [ cAval ] [ bParBloco ] [ cExprFilTop ] [ uPar14 ] [ aColors ] [ uPar16 ] )
	MarkBrow( 'TRB','_OK',,aCampos,,cMarca,,,,,,,,,,,, )

	DbSelectArea("TRB")
	TRB->(DbCLoseArea())
	MsErase(cArqTmp+GetDBExtension(),,"DBFCDX")   

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Montagrid     ºAutor  ³Jose Roberto   º Data ³  31/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preenche lista da MarkBrowse                               º±±   
±±º          ³ Tabela temporaria para montagem da MarkBrowse              º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico CAOA- Interface MasterSAF                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Montagrid()

	Local cQuery 	:= "" 

	IF Select( "TMP" ) > 0
		dbSelectArea( "TMP" )
		dbCloseArea()
	EndIF

	//RODA QUERY PARA LEVANTAR AS TABELAS DO CADASTRO SZR
	cQuery := "SELECT DISTINCT ZQ_TABELA, ZQ_DESCTB FROM "+RetSqlName("SZQ")+" WHERE D_E_L_E_T_ = ' ' AND ZQ_MSBLQL <> '1' " 

	//MemoWrite("\Query\ItemAgenda.sql",cQuery) 
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),"TMP", .F., .T.) 

	//alimenta tabela temporária 
	TMP->(DbGoTop())
	
	While TMP->(!Eof())

		DbSelectArea("TRB")
		Reclock("TRB",.t.)     
			TRB->_OK	  	:= "  "
			TRB->TABELA		:= TMP->ZQ_TABELA  
			TRB->TABDESC 	:= TMP->ZQ_DESCTB
		MSUNLOCK() 

		dbSelectArea("TMP")
		TMP->(dbSkip())

	EndDo   

return(Nil)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ExpTab        ºAutor  ³Jose Roberto   º Data ³  31/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exporta Tabelas Selecionadas na MarkBrowse                 º±±   
±±º          ³ 												              º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico CAOA- Interface MasterSAF                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MS06ExpTab() 

	Local cTabela 
	Local aTabela   := {}
	Local lContinua := .T.
	Local cMsgFinal := ""

	cErro := ""
	cErroAll := ""

	// Tenta criar o arquivo de Log
	If !MS06Han() 
		Aviso("Erro de criação do arquivo","Não foi possivel criar o arquivo de Log de Erro: "+Alltrim(cFile)+".",{"Fecha"})  
		Return()
	EndIf

	lSAFX07  := .F.
	lSAFX08  := .F.
	lSAFX09  := .F.
	lSAFX108 := .F.
	lSAFX109 := .F.
	lSAFX16  := .F.
	lSAFX17  := .F.
	lSAFX18  := .F.
	lSAFX112 := .F.
	lSAFX113 := .F.
	lSAFX114 := .F.
	lSAFX116 := .F.
	lSAFX118 := .F.
	lSAFX153 := .F.
	lSAFX154 := .F.
	lSAFX235 := .F.
	lSAFX236 := .F.

	// validacao dos arquivos marcados
	DbSelectArea("TRB")
	DbGotop()
	While !TRB->(EOF())
		If IsMark("_OK") 
			aAdd(aTabela,TRB->TABELA)
		Endif	
		TRB->(DBSKIP())
	Enddo

	If aScan(aTabela,"SAFX07") > 0
		lSAFX07 := .T.
	Endif 
	If aScan(aTabela,"SAFX08") > 0
		lSAFX08 := .T.
	Endif 
	If aScan(aTabela,"SAFX09") > 0
		lSAFX09 := .T.
	Endif 
	If aScan(aTabela,"SAFX108") > 0
		lSAFX108 := .T.
	Endif 
	If aScan(aTabela,"SAFX109") > 0
		lSAFX109 := .T.
	Endif 
	If aScan(aTabela,"SAFX16") > 0
		lSAFX16 := .T.
	Endif 
	If aScan(aTabela,"SAFX17") > 0
		lSAFX17 := .T.
	Endif 
	If aScan(aTabela,"SAFX18") > 0
		lSAFX18 := .T.
	Endif 
	If aScan(aTabela,"SAFX112") > 0
		lSAFX112 := .T.
	Endif 
	If aScan(aTabela,"SAFX113") > 0
		lSAFX113 := .T.
	Endif 
	If aScan(aTabela,"SAFX114") > 0
		lSAFX114 := .T.
	Endif 
	If aScan(aTabela,"SAFX116") > 0
		lSAFX116 := .T.
	Endif 
	If aScan(aTabela,"SAFX118") > 0
		lSAFX118 := .T.
	Endif 
	If aScan(aTabela,"SAFX153") > 0
		lSAFX153 := .T.
	Endif 
	If aScan(aTabela,"SAFX154") > 0
		lSAFX154 := .T.
	Endif 
	If aScan(aTabela,"SAFX235") > 0
		lSAFX235 := .T.
	Endif 
	If aScan(aTabela,"SAFX236") > 0
		lSAFX236 := .T.
	Endif 

	If lSAFX07 .and. !(lSAFX08 .or. lSAFX09)
		APMsgAlert("Se for marcado o arquivo 'SAFX07', deve ser marcado também o 'SAFX08' ou 'SAFX09'.")
		lContinua := .F.
	Endif	

	If lContinua
		If !lSAFX07 .and. (lSAFX08 .or. lSAFX09)
			APMsgAlert("Se for marcado o arquivo 'SAFX08' ou 'SAFX09', deve ser marcado também o 'SAFX07'.")
			lContinua := .F.
		Endif
	Endif

	If lContinua
		If lSAFX109 .and. !lSAFX108 
			APMsgAlert("Se for marcado o arquivo 'SAFX109', deve ser marcado também o 'SAFX108'.")
			lContinua := .F.
		Endif
	Endif

	If lContinua
		If (lSAFX16 .and. !(lSAFX17 .or. lSAFX18)) .or. (lSAFX17 .and. !(lSAFX16 .or. lSAFX18)) .or. (lSAFX18 .and. !(lSAFX16 .or. lSAFX17)) 
			APMsgAlert("Se for marcado o arquivo 'SAFX16' ou 'SAFX17' ou 'SAFX18', devem ser marcados os arquivos 'SAFX16','SAFX17' e 'SAFX18'.")
			lContinua := .F.
		Endif
	Endif		

	If lContinua
		If (lSAFX113 .or. lSAFX114 .or. lSAFX116 .or. lSAFX118) .and. !lSAFX112  
			APMsgAlert("Se for marcado o arquivo 'SAFX113' ou 'SAFX114' ou 'SAFX116' ou 'SAFX118', deve ser marcado também o 'SAFX112'.")
			lContinua := .F.
		Endif
	Endif

	If lContinua
		If lSAFX153 .and. (!lSAFX154 .or. !lSAFX235 .or. !lSAFX236)
			APMsgAlert("Se for marcado o arquivo 'SAFX153', devem ser marcados também o 'SAFX154','SAFX235' e 'SAFX236'.")
			lContinua := .F.
		Endif
	Endif

	If lContinua
		If lSAFX235 .and. !lSAFX236 
			APMsgAlert("Se for marcado o arquivo 'SAFX235', deve ser marcado também o 'SAFX236'.")
			lContinua := .F.
		Endif
	Endif
		
	If !lContinua
		Return()
	Endif

	cMsgFinal := ""
		
	DbSelectArea("TRB")
	DbGotop()

	While ! TRB->(EOF())

		If IsMark("_OK") 
			cTabela := TRB->TABELA
			cTab := Alltrim(cTabela)
			//--Se precisar gerar mais de 1 arquivo por dia
			cTime := Time() 			   // Resultado: 10:37:17
			cHour := SubStr( cTime, 1, 2 ) // Resultado: 10
			cMin  := SubStr( cTime, 4, 2 ) // Resultado: 37
			cSecs := SubStr( cTime, 7, 2 ) // Resultado: 17
			
			//SAFXxx_EEE_FF_DDMMAAAA	
			cFileOut := ALLTRIM(cTabela)+"_"+ALLTRIM(cEmpAnt)+ALLTRIM(cFilAnt)+"_"+dtos(DATE()) + "_" + cHour+cMin+cSecs+ ".TXT"
			FWMsgRun(, {|| GeraTXT( @cMsgFinal ) },'Exportação Protheus -> MasterSAF','Gerando arquivo '+alltrim(cTabela)+', aguarde...')
		Endif
		
		DbSelectArea("TRB")
		TRB->(DBSKIP())
	
	Enddo

	APMsgInfo(cMsgFinal)

	// fechamento do arquivo de log
	FClose(nHdlError)

	//If !lContinua .and. !Empty(cErro)
	If !Empty(cErro)
	
		DEFINE MSDIALOG oDlg TITLE "Log de Erros na Exportação" From 0,0 TO 340,550 OF oMainWnd PIXEL
			cShowErr := MemoRead(cFile)
			@ 5,5 GET oMemo Var cShowErr Of oDlg MEMO SIZE 267,145 PIXEL
			oMemo:brClicked := {||AllwaysTrue()}

			DEFINE SBUTTON FROM 153,230 TYPE 01 ACTION oDlg:End() ENABLE OF oDlg PIXEL
			DEFINE SBUTTON FROM 153,200 TYPE 15 ACTION (MS06TelaDet(),oDlg:End()) ENABLE ONSTOP "Visualizar Detalhes" OF oDlg PIXEL        

		ACTIVATE MSDIALOG oDlg CENTER
	
	Endif	

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GeraTXT       ºAutor  ³Jose Roberto   º Data ³  31/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria a query conforme parâmetros no Parambox               º±±   
±±º          ³ 											                  º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 													          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico CAOA- Interface MasterSAF                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                                      

Static Function GeraTXT(cMsgFinal)    

	Local cNomeTab := padr(alltrim(cTab),10," ")      
	local nHandle 
	Local lGerou  := .F.
	Local nStart  := SECONDS()
	Local nStop   := 0

	Private aCab      := {}
	Private aItens    := {}
	Private cAliasTrb := GetNextAlias()
	
	Private c2NomeTab := padr(alltrim(cTab),10," ")      
	Private n2Handle 
	Private c2Buffer  := ""
	Private l2Gerou   := .F.
	Private _EMPMS    := ""
	
	//Cria arquivo de saida -> prepara para gravar TXT
	Private _nLimite := 5000
	Private LDebug 	 := .F.

	nHandle := FCREATE(cLocDest+cFileOut)
	n2Handle:= nHandle//FCREATE(cLocDest+"T"+cFileOut)
	
	If nHandle == -1 //.or. n2Handle == -1
		MSGALERT("Erro ao criar arquivo TXT " + Str(Ferror()))
		Return()
	Endif

	ExecQuery(cTab,@aCab,@aItens)
	//Ajustar o tamanho para seek

	lGerou  := SalvaTXT(aCab,aItens)   

	FClose(nHandle)
	IF lGerou .or. l2Gerou 
		nStop := SECONDS() - nStart

		//MSGINFO("Arquivo gerado com sucesso: "+ALLTRIM(cNomeTab)+".")
		cMsgFinal += "Arquivo gerado com sucesso: " + ALLTRIM(cNomeTab) + "." + CRLF 
		cMsgFinal += "Tempo de geração " + transform(nStop,'@E 99,999.999')+ " Segundos " + CRLF + CRLF
	Else
		//MSGAlert("Não foram gerados dados para este arquivo: "+ALLTRIM(cNomeTab)+".")
		cMsgFinal += "Não foram gerados dados para este arquivo: "+ALLTRIM(cNomeTab)+"."+CRLF
	Endif

Return                         

/*
=======================================================================================
Programa.:              SalvaTXT
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              16/03/2022
Descricao / Objetivo:   Salva as Informações no Arquivo
=======================================================================================
*/

Static Function SalvaTXT(cCab,aItens)    

	Local lGerou := .F.
	Local nCnt   := 0
	Local nCnt1  := 0
	Local _cCampo 

	default aCab   := {}
	default aItens := {}
	
	If lCabec .AND. !l2Gerou
		For nCnt:=1 To Len(aCab)
			c2Buffer := c2Buffer+Alltrim(aCab[nCnt][2])+Chr(9)
		Next
		FWrite(n2Handle, c2Buffer + CRLF)
		cBuffer := ""
	Endif		

	For nCnt:=1 To Len(aItens)
		c2Buffer := ""

		For nCnt1:=1 To Len(aItens[nCnt])-1 // -1 para nao importar o campo de filial
			nTamCmp := aCab[nCnt1][5]	

			If ValType(aItens[nCnt][nCnt1][2]) == "N" 
				
				_cCampo := AllTrim(Str(aItens[nCnt][nCnt1][2]))
				If Len(_cCampo) < nTamCmp
					_cCampo := Space( nTamCmp - Len(_cCampo)) + _cCampo 
				EndIf
			Else
				
				_cCampo := AllTrim(aItens[nCnt][nCnt1][2])
				If Len(_cCampo) < nTamCmp
					_cCampo := _cCampo + Space(nTamCmp - Len(_cCampo))
				EndIf
			Endif
			c2Buffer := c2Buffer+_cCampo+Chr(9)
		Next

		lGerou := .T.
		l2Gerou := lGerou
		FWrite(n2Handle, c2Buffer + CRLF)
	Next
		
Return lGerou   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MarcaItem     ºAutor  ³Jose Roberto   º Data ³  31/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seleciona os itens da MarkBrowse        					  º±±   
±±º          ³ 											                  º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³  											              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico CAOA- Interface MasterSAF                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MarcaItem()
	Local lDesmarc := IsMark("_OK", cMarca, .t.)

	If !lDesmarc
	//Alert('Não Marcou !!!')  

		DbSelectArea("TRB") 
		RecLock("TRB",.F.)
			Replace TRB->_OK With Space(2)
		MsUnlock()	   
	Else
		//Alert('Agora Marcou !!!')  

		DbSelectArea("TRB")
		RecLock("TRB",.F.)
			Replace TRB->_OK With cMarca
		MsUnlock()	

	EndIf

	MarkBRefresh( )		   		// atualiza o browse

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ InvertAll     ºAutor  ³Jose Roberto   º Data ³  31/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inverte seleção de Itens no MarkBrowse                     º±±   
±±º          ³ 											                  º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³  											              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico - CAOA-Interface MasterSaf                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MS06InvertAll()

	Local oObjMark:= getmarkbrow()

	DbSelectArea("TRB")
	TRB->(DbGoTop())
	
	While !TRB->(EOF())
		u_MarcaItem()
		TRB->(DbSkip())
	EndDo

	MarkBRefresh( )	
	oObjMark:oBrowse:Gotop()	// força o posicionamento do browse no primeiro registro

Return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MarcaTudo     ºAutor  ³Jose Roberto   º Data ³  31/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para marcar todos os registros do MarkBrowse        º±±   
±±º          ³ 											                  º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³  												          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico - CAOA-Interface MasterSaf                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MS06MarcaTudo()
                              
	Local oMark := GetMarkBrow()

	DbSelectArea("TRB")
	DbGotop()

	While !Eof()	
		
		IF RecLock( 'TRB', .F. )		
			TRB->_OK := cMarca		
			MsUnLock()	
		EndIf	
		
		TRB->(dbSkip())
	
	Enddo

	MarkBRefresh( )      		// atualiza o browse
	oMark:oBrowse:Gotop()	    // força o posicionamento do browse no primeiro registro

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DesmrkTudo    ºAutor  ³Jose Roberto   º Data ³  31/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para desmarcar todos os registros do MarkBrowse     º±±   
±±º          ³ 											                  º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 													          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico CAOA- Interface MasterSAF                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MS06DesmrkTudo()

	Local oMark := GetMarkBrow()

	DbSelectArea("TRB")
	DbGotop()

	While !Eof()	
		IF RecLock( 'TRB', .F. )		
			TRB->_OK := SPACE(2)		
			MsUnLock()	
		EndIf	
		dbSkip()
	Enddo

	MarkBRefresh( )			// atualiza o browse
	oMark:oBrowse:Gotop()	// força o posicionamento do browse no primeiro registro

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ExecQuery
Montagem do arquivo
@author o
@since 		??/??/????
@param     	_aParam - Com informações paramb do MT110TEL
@return    	Logico
@project    CAOA
@menu       Nao Informado
@version 	1.0
@obs        Chamado pelo Ponto de Entrada MT110TEL
@history    DAC Denilso 26/08/2020
			- 	Chamado 422291 DAC 26/08/2020 Problema / Solicitação:Correção na extração SAFX07 e SAFX09 (Acertos Fiscais), documentação em anexo.
				SAFX07 – IND_NAT_BASE_CRED (campo FT_CODBCC) e IND_NAT_FRETE (FT_INDNTFR)
				SAFX09 - IND_NAT_BASE_CRED (campo FT_CODBCC)
			DAC Denilso 26/01/2021
			-	Atualização conforme chamado INC0012933 - Notas de Serviço sem DATA LANC PIS COFINS 
			-	Atualização conforme chamado INC0013025 - Natureza de Crédito e Natureza de frete – Acertos Fiscais
			-   Analise conforme chamado INC0015132 – Mastersaf SAFX07 e SAFX09 não está extraindo dados de ISS para a TES 193 DAC 27/01/2021
			-   Atualização conforme chamado INC0012950 - Para Notas com CST PIS e COFINS n° 49 (saída) e 70 (Entrada) preencher o campo Data 
				PIS COFINS @
			Reinaldo Rabelo 06/01/2023
			-	Manutenção na Static Function separando a geração de cada arquivo do MasterSaf em Funções separada para facilitar a manuetenção
				e realizado um limpeza do fonte, removendo funções comentadas sem uso.	


/*/
//-------------------------------------------------------------------
Static Function ExecQuery(cTab,aCab,aItens)

	Private cQ := ""
	Private nCnt     := 0
	Private nBaseIcm := 0
	Private nVlrIcms := 0 
	
	Private bCmpZerado  := {|x| IIf(Empty(&(x)),"@",IIf(X3Tipo(Subs(x,At("->",x)+2))=="N",&(x)*(10**TamSZR(cTab)[2]),IIf(X3Tipo(Subs(x,At("->",x)+2))=="D",dTos(&(x)),Subs(&(x),1,TamSZR(cTab)[1]))))}
	Private bCalZerado  := {|x| IIf(Empty(x),"@",x*100)} 
	Private bCal2Zerado := {|x| IIf(Empty(x),0,(x)*(10**TamSZR(cTab)[2]))} 
	Private bCal3Zerado := {|x| IIf(Empty(x),0,(Round(x,TamSZR(cTab)[2]))*(10**TamSZR(cTab)[2]))} 
	Private bCmpZeroEsq := {|x| IIf(Empty(x),"@",Padl(Alltrim(Subs(&(x),1,TamSZR(cTab)[1])),TamSZR(cTab)[1],"0"))}
	
	Private lSA1 := .F.
	Private lSA2 := .F.
	Private lCD5 := .F.
	Private lSB5 := .F.
	Private lFirst := .T.
	Private lContinua := .T.
	// bloco K
	Private cAli0210 := GetNextAlias()
	Private cAliK001 := GetNextAlias()
	Private cAliK100 := GetNextAlias()
	Private cAliK200 := GetNextAlias()
	Private cAliK210 := GetNextAlias()
	Private cAliK215 := GetNextAlias()
	Private cAliK220 := GetNextAlias()
	Private cAliK230 := GetNextAlias()
	Private cAliK235 := GetNextAlias()
	Private cAliK250 := GetNextAlias()
	Private cAliK255 := GetNextAlias()
	Private cAliK260 := GetNextAlias()
	Private cAliK265 := GetNextAlias()
	Private cAliK270 := GetNextAlias()
	Private cAliK275 := GetNextAlias()
	Private cAliK280 := GetNextAlias()
	Private cAliK290 := GetNextAlias()
	Private cAliK291 := GetNextAlias()
	Private cAliK292 := GetNextAlias()
	Private cAliK300 := GetNextAlias()
	Private cAliK301 := GetNextAlias()
	Private cAliK302 := GetNextAlias()
	Private cAliK990 := GetNextAlias()
	Private cAli0200 := GetNextAlias()
	Private aAliasK  := {cAli0210,cAliK001,cAliK100,cAliK200,cAliK210,cAliK215,cAliK220,cAliK230,;
						 cAliK235,cAliK250,cAliK255,cAliK260,cAliK265,cAliK270,cAliK275,cAliK280,;
						 cAliK300,cAliK301,cAliK302,cAliK990,cAli0200,cAliK290,cAliK291,cAliK292}
	Private aAliasKProc := Array(Len(aAliasK))
	// ate aqui bloco k
	Private cTpCorr  := ""
	Private cGrpCont := ""

	// tipo do produto
	Private aTipo	:=	{ {"ME","00"},;
						{"MP","01"},;
						{"EM","02"},;
						{"PP","03"},;
						{"PA","04"},;
						{"SP","05"},;
						{"PI","06"},;
						{"MC","07"},;
						{"AI","08"},;
						{"MO","09"},;
						{"OI","10"} }
	// ate aqui tipo do produto
	Private a112 := {}
	//Local a113 := {}
	Private a114 := {}
	Private a116 := {}
	Private _nAliq
	Private _cCfOP := SuperGetMV( "CMV_FIS004"  ,,"") 
	Private _aCfOP := {}
	Private _nPos
	Private cFilAux := ""
	Private cEStFil := FWSM0Util():GetSM0Data(,,{'M0_ESTENT'})[1,2]
	Private nPosCmpCab := 0
	Private lDebug := .F.

	aCab   := {}
	aItens := {}
	
	DbSelectArea("SA1")
	DbSelectArea("SA2")
	
	If Alltrim(cTab) == "SAFX07"
		fSAFX07()
	Endif
	
	If Alltrim(cTab) == "SAFX08"
		fSAFX08()
	Endif
	
	If Alltrim(cTab) == "SAFX09"
		fSAFX09()
	Endif
	
	If Alltrim(cTab) == "SAFX10"
		fSAFX10()
	Endif
	
	If Alltrim(cTab) == "SAFX16"
		fSAFX16()
	Endif
	
	If Alltrim(cTab) == "SAFX17"
		fSAFX17()
	Endif
	
	If Alltrim(cTab) == "SAFX18"
		fSAFX18()
	Endif
	
	If Alltrim(cTab) == "SAFX49"
		fSAFX49()
	Endif
	
	If Alltrim(cTab) == "SAFX52"
		fSAFX52()
	Endif
	
	If Alltrim(cTab) == "SAFX53"
		fSAFX53()
	Endif
	
	If Alltrim(cTab) == "SAFX108"
		fSAFX108()
	Endif
	
	If Alltrim(cTab) == "SAFX109"
		fSAFX109()
	Endif
	
	If Alltrim(cTab) == "SAFX112"
		fSAFX112()
	Endif
	
	If Alltrim(cTab) == "SAFX113"
		fSAFX113()
	Endif
	
	If Alltrim(cTab) == "SAFX114"
		fSAFX114()
	Endif
	
	If Alltrim(cTab) == "SAFX116"
		fSAFX116()
	Endif
	
	If Alltrim(cTab) == "SAFX118"
		fSAFX118()
	Endif

	If Alltrim(cTab) == "SAFX130"
		fSAFX130()
	Endif

	If Alltrim(cTab) == "SAFX153"
		fSAFX153()
	Endif
	
	If Alltrim(cTab) == "SAFX154"
		fSAFX154()
	Endif

	If Alltrim(cTab) == "SAFX235"
		fSAF235()
	Endif
	
	If Alltrim(cTab) == "SAFX236"
		fSAFX236()
	Endif
	
	If Alltrim(cTab) == "SAFX245"
		fSAFX245()
	Endif

	If Alltrim(cTab) == "SAFX520"
		fSAFX520()
	Endif

	If Alltrim(cTab) == "SAFX2006"
		fSAFX2006()
	Endif
	
	If Alltrim(cTab) == "SAFX2009"
		fSAFX2009()
	Endif

	If Alltrim(cTab) == "SAFX2010"
		fSAFX2010()
	Endif

	If Alltrim(cTab) == "SAFX2013"
		fSAFX2013()
	Endif

	If Alltrim(cTab) == "SAFX2018"
		fSAFX2018()
	Endif

Return(cQ)

/*
=======================================================================================
Programa.:              MontaCab
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function MontaCab(cTab,aCab)

	Local aArea := {GetArea()}

	SZR->(dbSetOrder(1))
	SZR->(dbSeek(xFilial("SZR")+cTab))

	While SZR->(!Eof()) .and. Alltrim(SZR->ZR_TABELA) == cTab
		aAdd(aCab,{cTab,SZR->ZR_CAMPO,SZR->ZR_TIPO,SZR->ZR_ORDEM,SZR->ZR_TAMAN})
		SZR->(dbSkip())
	Enddo             

	// ordena por item
	aSort(aCab,,,{|x,y| x[4] < y[4] })

	aEval(aArea,{|x| RestArea(x)})

Return()

/*
=======================================================================================
Programa.:              PosCabArray
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function PosCabArray(aItens,cCampo)

	Local nPos := 0

	nPos := aScan(aItens[1],{|x| Alltrim(x[1])==Alltrim(cCampo)})

Return(nPos)

/*
=======================================================================================
Programa.:              SZPMSaf
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function SZPMSaf(cCampo,cFil)

	Local aArea     := {GetArea()}
	Local cQ        := ""
	Local cAliasTrb := GetNextAlias()
	Local cRet      := "@"

	cQ := "SELECT "+cCampo+" "
	cQ += "FROM "+RetSqlName("SZP")+" SZP "
	cQ += "WHERE SZP.D_E_L_E_T_ = ' ' "
	cQ += "AND ZP_CODFIL = '"+cFil+"' "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)

	If (cAliasTrb)->(!Eof())
		cRet := (cAliasTrb)->&cCampo
	Endif

	(cAliasTrb)->(dbCloseArea())	

	aEval(aArea,{|x| RestArea(x)})

Return(cRet)
/*
=======================================================================================
Programa.:              MOVTO_E_S
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/

Static Function MOVTO_E_S(cCfo,cForm)

	Local cRet := "@"

	If cCfo < "5" .and. cForm == "S"
		cRet := "4"
	Elseif cCfo < "5" .and. cForm != "S"
		cRet := "1"
	Elseif cCfo >= "5"
		cRet := "9"
	Endif

Return(cRet) 	

/*
=======================================================================================
Programa.:              NORM_DEV
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function NORM_DEV(cTipo)
Return(IIF(cTipo == 'D',"2","1"))	

/*
=======================================================================================
Programa.:              IDENT_FIS_JUR
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function IDENT_FIS_JUR(cCfo,cTipo)
	Local cRet := "@"

	If cCfo < "5" .and. cTipo $ ("D/B")
		cRet := "2"
	Elseif cCfo < "5" .and. !cTipo $ ("D/B")
		cRet := "1"
	Elseif cCfo >= "5" .and. cTipo $ ("D/B")
		cRet := "1"
	Elseif cCfo >= "5" .and. !cTipo $ ("D/B")
		cRet := "2"
	Endif	
   
Return(cRet)

/*
=======================================================================================
Programa.:              PosCliForSF3
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function PosCliForSF3(cCfo,cTipo,cCod,cLoja,lSA1,lSA2,lPosNota,cItem,lValf3)
//Local aArea := {GetArea()}
	Local lRet := .F.
	Local lSF1 := .F.
	Local lSF2 := .F.
	
	Default lValF3 := .T.

	If (cCfo < "5" .and. cTipo $ ("D/B")) .or. (cCfo >= "5" .and. !cTipo $ ("D/B"))
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+cCod+cLoja))
			lSA1 := .T.
		Endif		 
	Elseif (cCfo < "5" .and. !cTipo $ ("D/B")) .or. (cCfo >= "5" .and. cTipo $ ("D/B"))
		SA2->(dbSetOrder(1))
		If SA2->(dbSeek(xFilial("SA2")+cCod+cLoja))
			lSA2 := .T.
		Endif		 
	Endif	

	If cCfo < "5"
		lSF1 := .T.
	Else
		lSF2 := .T.
	Endif
		
	If !lSA1 .and. !lSA2 .and. lValF3
		cErro := cTab+": Não encontrada tabela: SA1/SA2, serie/documento: "+SF3->F3_SERIE+"/"+SF3->F3_NFISCAL+"."
		MS06GrvLog(cErro)
	Else
		lRet := .T.
		IF lValF3 
			If Empty(SF3->F3_DTCANC)// se nota estiver cancelada, nao pesquisa sf1 e sf2, pois estarao deletados
				If lPosNota 
					lRet := PosNotaSF3(lSF1,lSF2,cItem)
				Endif
			Endif
		ENDIF	
	Endif			
	
//aEval(aArea,{|x| RestArea(x)})
   
Return(lRet)
/*
=======================================================================================
Programa.:              COD_MODELO
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/

Static Function COD_MODELO(cEsp)

	Local cRet := "@"
	DO CASE
		CASE cEsp == "NTST"
			cRet := "22"
		CASE cEsp == "NFFS"
			cRet := "01"
		CASE cEsp == "CTE"
			cRet := "57"
		CASE cEsp == "NF"
			cRet := "01"
		CASE cEsp == "SPED"
			cRet := "55"
		CASE cEsp == "RPS"
			cRet := "00" //"01"
		CASE cEsp == "NFS"
			cRet := "00" //"01"
		CASE cEsp == "NFSC"
			cRet := "21"
		CASE cEsp == "NFE"
			cRet := "55"
		CASE !Empty(cEsp)
			cRet := "55"
	ENDCASE	
		
Return(cRet) 	

/*
=======================================================================================
Programa.:              X3Tipo
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/

Static Function X3Tipo(cCampo)
RETURN(GetSx3Cache(cCampo,"X3_TIPO"))

/*
=======================================================================================
Programa.:              MaxAliqIt
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
//MaxAliqIt(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"ALIQISS",.F.,.T.)
=======================================================================================
*/

Static Function MaxAliqIt(cFil,cSerie,cDoc,cCod,cLoja,cCfo,cCampo,lEnt,lSai)

	Local aArea := {GetArea()}
	Local cQ    := ""
	Local cAliasTrb := GetNextAlias()
	Local uRet   := "@"
	Local cAlias := ""

	If cCfo < "5" .and. lEnt
		cAlias := "D1_"
		cQ := "SELECT MAX("+cAlias+cCampo+") * 100 "+cAlias+cCampo+" "
		cQ += "FROM "+RetSqlName("SD1")+" SD1 "
		cQ += "WHERE SD1.D_E_L_E_T_ = ' ' "
		cQ += "AND D1_FILIAL = '"+cFil+"' "
		cQ += "AND D1_SERIE = '"+cSerie+"' "
		cQ += "AND D1_DOC = '"+cDoc+"' "
		cQ += "AND D1_FORNECE = '"+cCod+"' "
		cQ += "AND D1_LOJA = '"+cLoja+"' "
	Elseif lSai
		cAlias := "D2_"
		cQ := "SELECT MAX("+cAlias+cCampo+") * 100 "+cAlias+cCampo+" "
		cQ += "FROM "+RetSqlName("SD2")+" SD2 "
		cQ += "WHERE SD2.D_E_L_E_T_ = ' ' "
		cQ += "AND D2_FILIAL = '"+cFil+"' "
		cQ += "AND D2_SERIE = '"+cSerie+"' "
		cQ += "AND D2_DOC = '"+cDoc+"' "
		cQ += "AND D2_CLIENTE = '"+cCod+"' "
		cQ += "AND D2_LOJA = '"+cLoja+"' "
	Endif

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)

	If (cAliasTrb)->(!Eof())
		uRet := (cAliasTrb)->&(cAlias+cCampo)
	Endif

	(cAliasTrb)->(dbCloseArea())	

	aEval(aArea,{|x| RestArea(x)})

Return(uRet)

/*
=======================================================================================
Programa.:              VlrCD2
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function VlrCD2(cFil,cSerie,cDoc,cCod,cLoja,cCfo,cCampo,lEnt,lSai,cImp,cItem,cProd,cTipoMov)

	Local aArea := {GetArea()}
	Local cQ := ""
	Local cAliasTrb := GetNextAlias()
	Local uRet := "@"

	Default cTipoMov := ""

	cQ := "SELECT SUM("+cCampo+") * 100 "+cCampo+" "
	cQ += "FROM "+RetSqlName("CD2")+" CD2 "
	cQ += "WHERE CD2.D_E_L_E_T_ = ' ' "
	cQ += "AND CD2_FILIAL = '"+cFil+"' "
	If !Empty(cTipoMov)
		cQ += "AND CD2_TPMOV = '"+cTipoMov+"' "
	Endif	
	cQ += "AND CD2_SERIE = '"+cSerie+"' "
	cQ += "AND CD2_DOC = '"+cDoc+"' "
	/*
	If cCfo < "5" .and. lEnt
		cQ += "AND CD2_CODFOR = '"+cCod+"' "
		cQ += "AND CD2_LOJFOR = '"+cLoja+"' "
	Elseif lSai	
		cQ += "AND CD2_CODCLI = '"+cCod+"' "
		cQ += "AND CD2_LOJCLI = '"+cLoja+"' "
	Endif
	*/
	//Alterações DAC

	If ! Empty(cTipoMov) .and. cTipoMov == "E"  //Nota de Entrada
		cQ += "AND CD2_CODFOR = '"+cCod+"' "
		cQ += "AND CD2_LOJFOR = '"+cLoja+"' "
	ElseIf ! Empty(cTipoMov) .and. cTipoMov == "S"  //Nota de Saida
		cQ += "AND CD2_CODCLI = '"+cCod+"' "
		cQ += "AND CD2_LOJCLI = '"+cLoja+"' "
	Else  //caso não tenha a definição do tipo
		cQ += "AND ((CD2_CODFOR = '"+cCod+"' "
		cQ += "AND CD2_LOJFOR = '"+cLoja+"') "
		cQ += "OR (CD2_CODCLI = '"+cCod+"' "
		cQ += "AND CD2_LOJCLI = '"+cLoja+"')) "
	EndIf

	cQ += "AND CD2_IMP = '"+cImp+"' "
	If !Empty(cItem)
		cQ += "AND CD2_ITEM = '"+cItem+"' "
	Endif	
	If !Empty(cProd)
		cQ += "AND CD2_CODPRO = '"+cProd+"' "
	Endif	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	If (cAliasTrb)->(!Eof())
		uRet := (cAliasTrb)->&(cCampo)
	Endif

	(cAliasTrb)->(dbCloseArea())	

	aEval(aArea,{|x| RestArea(x)})

Return(uRet)

/*
=======================================================================================
Programa.:              MontaItens
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function MontaItens(aCab,aItens,cFilConteudo)

	Local nCnt := 0

	aAdd(aItens,Array(Len(aCab)+1))
	For nCnt:=1 To Len(aCab)+1
		// ultimo campo, de filial
		If nCnt == Len(aItens[Len(aItens)])
			aItens[Len(aItens)][nCnt] := {"","","",""}
		Else	
			aItens[Len(aItens)][nCnt] := {aCab[nCnt][2],"@",aCab[nCnt][3],aCab[nCnt][4]} // campo/conteudo/tipo/ordem
		Endif	
	Next	

	// grava campo de filial
	aItens[Len(aItens)][Len(aItens[Len(aItens)])][1] := "FILIAL"
	aItens[Len(aItens)][Len(aItens[Len(aItens)])][2] := cFilConteudo
	aItens[Len(aItens)][Len(aItens[Len(aItens)])][3] := "C"
	aItens[Len(aItens)][Len(aItens[Len(aItens)])][4] := "999999"

Return()				

/*
=======================================================================================
Programa.:              PosNotaSF3
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function PosNotaSF3(lSF1,lSF2,cItem)

	Local aArea := {GetArea()}
	Local lRet  := .F.
	Local cQ    := ""
	Local cAliasTrb := GetNextAlias()

	Default cItem := ""

	If lSF2
		SF2->(dbSetOrder(1))
		If SF2->(dbSeek(SF3->F3_FILIAL+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
			lRet := .T.
			If !Empty(cItem)
				lRet := .F.
				/*
				SD2->(dbSetOrder(3))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					While SD2->(!Eof()) .and. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == ;
					SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
						If Alltrim(cItem) == Alltrim(SD2->D2_ITEM)
							lRet := .T.
							Exit
						Endif
						SD2->(dbSkip())	
					Enddo
				Endif
				*/
				cQ := "SELECT SD2.R_E_C_N_O_ SD2_RECNO "
				cQ += "FROM "+RetSqlName("SD2")+" SD2 "
				cQ += "WHERE SD2.D_E_L_E_T_ = ' ' "
				cQ += "		AND D2_FILIAL  = '" + SF2->F2_FILIAL + "' "
				cQ += "		AND D2_SERIE   = '" + SF2->F2_SERIE  + "' "
				cQ += "		AND D2_DOC     = '" + SF2->F2_DOC    + "' "
				cQ += "		AND D2_CLIENTE = '" + SF2->F2_CLIENTE+ "' "
				cQ += "		AND D2_LOJA    = '" + SF2->F2_LOJA   + "' "
				cQ += "		AND TRIM(D2_ITEM) = '"+Alltrim(cItem)+ "' "

				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)

				If (cAliasTrb)->(!Eof()) .and. !Empty((cAliasTrb)->SD2_RECNO)
					SD2->(dbGoto((cAliasTrb)->SD2_RECNO))
					lRet := .T.
				Endif

				(cAliasTrb)->(dbCloseArea())	
			Endif			
		Endif
	Elseif lSF1		
		SF1->(dbSetOrder(1))
		If SF1->(dbSeek(SF3->F3_FILIAL+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
			lRet := .T.
			If !Empty(cItem)
				lRet := .F.
				/*
				SD1->(dbSetOrder(1))
				If SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
					While SD1->(!Eof()) .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == ;
					SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
						If Alltrim(cItem) == Alltrim(SD1->D1_ITEM)
							lRet := .T.
							Exit
						Endif
						SD1->(dbSkip())	
					Enddo
				Endif
				*/
				cQ := "SELECT SD1.R_E_C_N_O_ SD1_RECNO "
				cQ += "FROM "+RetSqlName("SD1")+" SD1 "
				cQ += "WHERE    SD1.D_E_L_E_T_ = ' ' "
				cQ += "		AND SD1.D1_FILIAL     = '" + SF1->F1_FILIAL  + "' "
				cQ += "		AND SD1.D1_SERIE      = '" + SF1->F1_SERIE   + "' "
				cQ += "		AND SD1.D1_DOC        = '" + SF1->F1_DOC     + "' "
				cQ += "		AND SD1.D1_FORNECE    = '" + SF1->F1_FORNECE + "' "
				cQ += "		AND SD1.D1_LOJA       = '" + SF1->F1_LOJA    + "' "
				cQ += "		AND TRIM(SD1.D1_ITEM) = '" + Alltrim(cItem)  + "' "

				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)

				If (cAliasTrb)->(!Eof()) .and. !Empty((cAliasTrb)->SD1_RECNO)
					SD1->(dbGoto((cAliasTrb)->SD1_RECNO))
					lRet := .T.
				Endif

				(cAliasTrb)->(dbCloseArea())	
			Endif			
		Endif
	Endif	
					
	If !lRet
		cErro := cTab+": Não encontrada tabela: SF1/SF2, serie/documento: "+SF3->F3_SERIE+"/"+SF3->F3_NFISCAL+"."
		MS06GrvLog(cErro)
	Endif

	aEval(aArea,{|x| RestArea(x)})
   
Return(lRet)
/*
=======================================================================================
Programa.:              IND_PRODUTO
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/

Static Function IND_PRODUTO(cAliasSB1)

	Local cRet := "@"
	DO CASE
		CASE (cAliasSB1)->B1_TIPO == "PA"
			cRet := "1"
		CASE (cAliasSB1)->B1_TIPO == "AI"
			cRet := "1" 	
		CASE (cAliasSB1)->B1_TIPO == "MP"
			cRet := "2" 	
		CASE (cAliasSB1)->B1_TIPO == "EM"
			cRet := "3" 	
		CASE (cAliasSB1)->B1_TIPO == "MC"
			cRet := "4" 	
		CASE (cAliasSB1)->B1_TIPO == "PI"
			cRet := "7" 	
		OTHERWISE
			cRet := "5"
	ENDCASE	 	
 
Return(cRet)
 
 /*
=======================================================================================
Programa.:              VlrSD3
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function VlrSD3(cFil,cProd,cOp,cCampo)

	Local aArea := {GetArea()}
	Local cQ    := ""
	Local cAliasTrb := GetNextAlias()
	Local uRet  := "@"

	cQ := "SELECT SUM("+cCampo+") * 100 "+cCampo+" "
	cQ += "FROM "+RetSqlName("SD3")+" SD3 "
	cQ += "WHERE SD3.D_E_L_E_T_ = ' ' "
	cQ += "AND D3_FILIAL = '"+cFil+"' "
	cQ += "AND TRIM(D3_OP) = '"+Alltrim(cOp)+"' "
	cQ += "AND D3_ESTORNO <> 'S' "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)

	If (cAliasTrb)->(!Eof())
		uRet := (cAliasTrb)->&(cCampo)
	Endif

	(cAliasTrb)->(dbCloseArea())	

	aEval(aArea,{|x| RestArea(x)})

Return(uRet)
  
/*
=======================================================================================
Programa.:              PosMovRef
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/ 
Static Function PosMovRef(cCliFor,cLoja,lSA1,lSA2)

	Local lContinua := .T.

	SF3->(dbSetOrder(4))
	If SF3->(!dbSeek(SFT->FT_FILIAL+cCliFor+cLoja+SFT->FT_NFORI+SFT->FT_SERORI))
		lContinua := .F.
	Endif
								
	If lContinua
		lContinua := PosCliForSF3(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA,@lSA1,@lSA2,.T.)
	Else
		cErro := cTab+": Não encontrada tabela REF.: SF3, serie/documento: "+SFT->FT_SERORI+"/"+SFT->FT_NFORI+"."
		MS06GrvLog(cErro)
	Endif					

Return(lContinua)

/*
=======================================================================================
Programa.:              TamSZR
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function TamSZR(cTab)

	Local aArea := {GetArea()}
	Local cQ    := ""
	Local cAliasTrb := GetNextAlias()
	Local aRet := {1,1}

	cQ := "SELECT ZR_DECIMAL,ZR_TAMAN "
	cQ += "FROM "+RetSqlName("SZR")+" SZR "
	cQ += "WHERE SZR.D_E_L_E_T_ = ' ' "
	cQ += "AND ZR_FILIAL = '"+xFilial("SZR")+"' "
	cQ += "AND TRIM(ZR_TABELA) = '"+cTab+"' "
	cQ += "AND TRIM(ZR_CAMPO) = '"+Alltrim(aCab[nPosCmpCab][2])+"' "
	//cQ += "AND ZR_TIPO = 'N' "

	If Select(cAliasTrb) > 0
		(cAliasTrb)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)

	If (cAliasTrb)->(!Eof())
		//If !Empty((cAliasTrb)->ZR_DECIMAL)
			aRet := {(cAliasTrb)->ZR_TAMAN,(cAliasTrb)->ZR_DECIMAL}
		//Endif	
	Endif

	(cAliasTrb)->(dbCloseArea())	

	aEval(aArea,{|x| RestArea(x)})

Return(aRet)

/*
=======================================================================================
Programa.:              BlcKTpCorr
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/

Static Function BlcKTpCorr(cOrigem)

	Local cRet := ""

	If cOrigem == "1" // K230/K235
		cRet := "4"
	Elseif cOrigem == "2" // K250/K255
		cRet := "5"
	Elseif cOrigem == "3" // K210/K215
		cRet := "2"
	Elseif cOrigem == "4" // K260/K265
		cRet := "6"
	Elseif cOrigem == "5" // K220
		cRet := "3"
	Else
		cRet := "1" // ??? K200
	Endif	

Return(cRet)

/*
=======================================================================================
Programa.:              GrpCont
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function GrpCont(cInd)
	Local cRet := ""
	
	DO CASE
		CASE cInd == "0"
			cRet := "1"
		CASE cInd == "1"
			cRet := "2"
		CASE cInd == "2"
			cRet := "3"
	ENDCASE

Return(cRet)

 
/*
=======================================================================================
Programa.:              MS06Han
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   Rotina de criacao do arquivo de log de erros
=======================================================================================
*/
Static Function MS06Han()

	Local lRet := .T.
	Local cDir := "c:\temp"

	// monta o nome do arquivo
	cFile := "Erros_Exportacao_Mastersaf"
	cFile += "_"
	cFile += Str(Year(dDataBase),4)
	cFile += StrZero(Month(dDataBase),2)
	cFile += StrZero(Day(dDataBase),2)
	cFile += "_"
	cFile += StrTran(Time(),":","")
	cFile += ".txt"
	cFile := cDir+"\"+Upper(cFile)

	MakeDir(cDir)
	If File(cFile)
		fErase(cFile)
	Endif	

	// tenta gerar o arquivo
	nHdlError := FCreate(cFile,0)

	// verifica o sucesso da operacao
	If nHdlError == -1
		lRet := .F.
	EndIf

Return(lRet)

/*
=======================================================================================
Programa.:              MS06GrvLog
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   Rotina de gravacao de registros de erro no arquivo de log
=======================================================================================
*/

Static Function MS06GrvLog(cLinha)

	Local cCR := Chr(13)+Chr(10)
	Local cReg := ""

	// grava cabecalho no arquivo .txt
	If lFirstErro
		lFirstErro := .F.

		cReg := "Registros de Inconsistências no Processamento da Exportação do MasterSaf."
		cReg += cCR

		FWrite(nHdlError,cReg)

		// insere uma linha em branco
		cReg := " "
		cReg += cCR
		FWrite(nHdlError,cReg)
	EndIf

	cReg := cLinha
	cReg += cCR

	If !Alltrim(cLinha) $ cErroAll // elimina mensagens em duplicidade
		FWrite(nHdlError,cReg)
	Endif	

Return()

/*
=======================================================================================
Programa.:              MS06TelaDet
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function MS06TelaDet()

	shellExecute( "Open", "C:\Windows\System32\notepad.exe", cFile, "c:\temp\" /*cTempu*/, 1) 
	
Return()
 
/*
=======================================================================================
Programa.:              CmpSZeroEsq
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
// funcao para retirar os zeros a esquerda do codigo
Static Function CmpSZeroEsq(cValor)

	Local nCnt := 0
	Local lIsDigit := .T.

	cValor := Alltrim(cValor)
	If Empty(cValor)
		cValor := "@"
	Endif	

	For nCnt := 1 To Len(cValor)
		If !IsDigit(Subs(cValor,nCnt,1))
			lIsDigit := .F.
			Exit
		Endif
	Next

	If lIsDigit
		cValor := Alltrim(Str(Val(cValor)))
	Endif

Return(cValor)

/*
=======================================================================================
Programa.:              MV_CodRet
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function MV_CodRet(cCodRet)

	Local cRet    := cCodRet
	Local cCodSX6 := GetMv("MV_DCTF000")
	Local cRetNew := ""

	If !Empty(cCodSX6)
		If At(Alltrim(cCodRet),cCodSX6) > 0	
			cRetNew := Subs(cCodSX6,At(Alltrim(cCodRet),cCodSX6)+5,6)
			cRet    := cRetNew
		Endif
	Endif

Return(cRet)

/*
=======================================================================================
Programa.:              CodRetTrib
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function CodRetTrib(cCodRet,cTipo)

	Local cRet := "@"	
	Do CASE
		CASE cCodRet == "2362"	
			cRet := "01"	
		CASE cCodRet == "0473"	
			If cTipo == "1"	
				cRet := "02"	
			Else
				cRet := "31"	
			Endif	
		CASE cCodRet == "0481"	
			If cTipo == "1"	
				cRet := "02"	
			Else
				cRet := "30"	
			Endif	
		CASE cCodRet == "0561"	
			If cTipo == "1"	
				cRet := "02"	
			Else
				cRet := "20"	
			Endif	
		CASE cCodRet == "0588"	
			If cTipo == "1"	
				cRet := "02"	
			Else
				cRet := "21"	
			Endif	
		CASE cCodRet == "1708"	
			If cTipo == "1"	
				cRet := "02"	
			Else
				cRet := "22"	
			Endif	
		CASE cCodRet == "5706"	
			If cTipo == "1"	
				cRet := "02"	
			Else
				cRet := "12"	
			Endif	
		CASE cCodRet == "8045"	
			If cTipo == "1"	
				cRet := "02"	
			Else
				cRet := "41"	
			Endif	
		CASE cCodRet == "2484"	
			If cTipo == "1"	
				cRet := "05"	
			Else
				cRet := "01"	
			Endif	
		CASE cCodRet == "5952"	
			If cTipo == "1"	
				cRet := "31"	
			Else
				cRet := "01"	
			Endif	
		OTHERWISE
			cRet:= '@'
	ENDCASE			

Return(cRet)
/*
=======================================================================================
Programa.:              VLR_IMP
Autor....:              CAOA
Data.....:              18/10/2021
Descricao / Objetivo:   
=======================================================================================
*/
Static Function VLR_IMP(cHawb,cDoc,cSerie,cItem,cProduto)

	Local aRet		:= {"@","@","@"}
	Local cAliasSWN	:= "SWNTRB"

	BeginSql Alias cAliasSWN
		SELECT WN_DESPADU, WN_VALOR, WN_IIVAL
			FROM %Table:SWN% SWN
			WHERE SWN.WN_FILIAL = %xFilial:SWN%
				AND SWN.%NotDel%
				AND SWN.WN_HAWB =%Exp:cHawb%
				AND SWN.WN_DOC =%Exp:cDoc%
				AND SWN.WN_SERIE =%Exp:cSerie%
				AND SWN.WN_ITEM =%Exp:cItem%
				AND SWN.WN_PRODUTO =%Exp:cProduto%
	EndSql
		
	if (cAliasSWN)->(!Eof())
		If !Empty((cAliasSWN)->WN_DESPADU)
			aRet[1] := (cAliasSWN)->WN_DESPADU
		EndIf
		If !Empty((cAliasSWN)->WN_VALOR)
			aRet[2] := (cAliasSWN)->WN_VALOR
		EndIf
		If !Empty((cAliasSWN)->WN_IIVAL)
			aRet[3] := (cAliasSWN)->WN_IIVAL
		EndIf
	endif
		
	(cAliasSWN)->(DBCLOSEAREA())

Return aRet

/*
=======================================================================================
Programa.:              zSelNfs
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/10/2021
Descricao / Objetivo:   Monta markbrowse para seleção de notas fiscais   
Solicitante:			Luanna
Gap:					    
=======================================================================================
*/
Static Function zSelNfs()
    Local oMarkBrw  := Nil
    Local cMark     := GetMark()
	Local cAliasQry	:= GetNextAlias()

    oMarkBrw := FWMarkBrowse():New()
    oMarkBrw:SetDescription("Selecionar Notas Fiscais")
    oMarkBrw:SetAlias("SF3")
    oMarkBrw:SetFieldMark( "F3_OK" )
    oMarkBrw:SetMark( cMark, "SF3", "F3_OK" )
    oMarkBrw:SetMenuDef('')
	oMarkBrw:SetFilterDefault("@"+zFilNf())
    oMarkBrw:DisableReport()
    oMarkBrw:AddButton( "Confirmar", {|| Self:End()} )
    oMarkBrw:Activate()

    BeginSql Alias cAliasQry
        SELECT R_E_C_N_O_ AS RECSF3, F3_NFISCAL
        FROM %Table:SF3% SF3
        WHERE SF3.F3_OK = %Exp:cMark%
        AND SF3.%NotDel%
    EndSql
    
    (cAliasQry)->( DbGoTop() )
    While (cAliasQry)->( !Eof() )

		//--Carrega notas fiscais selecionadas
        If Empty(__cSelNfs)
            __cSelNfs := AllTrim( ( cAliasQry )->F3_NFISCAL )
        Else
            __cSelNfs := __cSelNfs + ";" + AllTrim( ( cAliasQry )->F3_NFISCAL )
        EndIf
        
        //--Limpa marcação
        SF3->( DbGoTo( ( cAliasQry )->RECSF3 ) )
        RecLock("SF3", .F.)
        SF3->F3_OK := ""
        SF3->( MsUnLock() )

        (cAliasQry)->( DbSkip() )

    EndDo

    (cAliasQry)->( DbCloseArea() )
    oMarkBrw:DeActivate()

Return

/*
=======================================================================================
Programa.:              zFilNf
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/10/2021
Descricao / Objetivo:   Filtra notas fiscais
=======================================================================================
*/
Static Function zFilNf()
	Local cFiltro := ""

	cFiltro  +=  "      F3_FILIAL BETWEEN  '" + cFilDe         + "' AND '" + cFilAte        + "' " + CRLF
	cFiltro  +=  "	AND F3_ENTRADA BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' " +CRLF
	cFiltro  +=  "	AND F3_CLIEFOR BETWEEN '" + cCliForDe      + "' AND '" + cCliForAte     + "' " +CRLF
 	cFiltro  +=  "	AND D_E_L_E_T_ = ' ' " + CRLF

Return cFiltro


/*
=======================================================================================
Programa.:              fPosCampo
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              16/03/2022
Descricao / Objetivo:   Criar Cache da posição dos campos 
=======================================================================================
*/
Static Function fPosCampo(aItens)
	_ALIQ				:= PosCabArray( aItens , "ALIQUOTA"               )
	_ALIQ_COFINS		:= PosCabArray( aItens , "ALIQ_COFINS"            )
	_ALIQ_ICMS			:= PosCabArray( aItens , "ALIQUOTA_ICMS"          )
	_ALIQ_ISS			:= PosCabArray( aItens , "ALIQUOTA_ISS"           )
	_ALIQ_PIS 			:= PosCabArray( aItens , "ALIQ_PIS"               )
	_ANO_COMPE			:= PosCabArray( aItens , "ANO_COMPETENCIA"        ) 
	_B_ICMS_AU			:= PosCabArray( aItens , "BASE_ICMS_AUX"          )
	_B_IPI_AUX			:= PosCabArray( aItens , "BASE_IPI_AUX"           )
	_B_ISEN_IC			:= PosCabArray( aItens , "BASE_ISEN_ICMS"         )
	_B_ISEN_IP			:= PosCabArray( aItens , "BASE_ISEN_IPI"          )
	_B_OUTR_IC			:= PosCabArray( aItens , "BASE_OUTR_ICMS"         )
	_B_OUTR_IP			:= PosCabArray( aItens , "BASE_OUTR_IPI"          ) 
	_B_ST_ICMS			:= PosCabArray( aItens , "BASE_SUB_TRIB_ICMS"     )
	_B_TRIB_IC			:= PosCabArray( aItens , "BASE_TRIB_ICMS"         )
	_B_TRIB_IP			:= PosCabArray( aItens , "BASE_TRIB_IPI"          ) 
	_B_TRIB_IS			:= PosCabArray( aItens , "BASE_TRIB_ISS"          )
	_BASEICMSV			:= PosCabArray( aItens , "VLR_BASE_ICMS"          )
	_BASE_ICMS			:= PosCabArray( aItens , "BASE_ICMS"              )
	_BASE_II 			:= PosCabArray( aItens , "BASE_II"                )
	_BASE_IPI 			:= PosCabArray( aItens , "BASE_IPI"               )
	_BASE_IR			:= PosCabArray( aItens , "BASE_IR"                )
	_BASE_ISS			:= PosCabArray( aItens , "BASE_ISS"               )
	_C_REF_FIS			:= PosCabArray( aItens , "COD_FIS_JUR_REF"        )
	_C_REF_MOD			:= PosCabArray( aItens , "COD_MODELO_REF"         )
	_C_TRIB_IP			:= PosCabArray( aItens , "COD_TRIB_IPI"           )
	_C_TRIB_IS			:= PosCabArray( aItens , "COD_TRIB_ISS"           )
	_CD_RECEIT			:= PosCabArray( aItens , "COD_RECEITA"            )
	_CD_SERV_L			:= PosCabArray( aItens , "COD_SERV_LEI_116"       )
	_CD_SERVIC			:= PosCabArray( aItens , "COD_SERVICO"            )
	_CLAS_ITEM 			:= PosCabArray( aItens , "CLAS_ITEM"              )
	_CLASS_DOC			:= PosCabArray( aItens , "COD_CLASS_DOC_FIS"      )
	_CNPJ_COLE			:= PosCabArray( aItens , "CNPJ_COLETA"            )
	_CNPJ_ENTR			:= PosCabArray( aItens , "CNPJ_ENTREGA"           )
	_COD_AJUST			:= PosCabArray( aItens , "COD_AJUSTE_SPED"        )
	_COD_ALMOX			:= PosCabArray( aItens , "COD_ALMOX"              )
	_COD_BARRAS 		:= PosCabArray( aItens , "COD_BARRAS"             )
	_COD_CFO			:= PosCabArray( aItens , "COD_CFO"                )
	_COD_CMEDIDA		:= PosCabArray( aItens , "COD_MEDIDA_COM"         )
	_COD_CONTA			:= PosCabArray( aItens , "COD_CONTA"              )
	_COD_CTRLI			:= PosCabArray( aItens , "COD_CTRL_INT"           )
	_COD_CUSTO			:= PosCabArray( aItens , "COD_CUSTO"              )
	_COD_DARF			:= PosCabArray( aItens , "COD_DARF"               )
	_COD_DOCTO			:= PosCabArray( aItens , "COD_DOCTO"              )
	_COD_EMPRESA 		:= PosCabArray( aItens , "COD_EMPRESA"            )
	_COD_ENT_S			:= PosCabArray( aItens , "COD_ENT_SAIDA"          )
	_COD_ESTAB 			:= PosCabArray( aItens , "COD_ESTAB"              )
	_COD_ESTOQ			:= PosCabArray( aItens , "COD_ESTOQUE"            )
	_COD_FIS_JUR		:= PosCabArray( aItens , "COD_FIS_JUR"            )
	_COD_INF_A			:= PosCabArray( aItens , "COD_INF_ADIC"           )
	_COD_INSUM			:= PosCabArray( aItens , "COD_INSUMO"             )
	_COD_MEDIDA 		:= PosCabArray( aItens , "COD_MEDIDA"             )
	_COD_MODELO 		:= PosCabArray( aItens , "COD_MODELO"             )
	_COD_NALADI 		:= PosCabArray( aItens , "COD_NALADI"             )
	_COD_NBM 			:= PosCabArray( aItens , "COD_NBM"                )
	_COD_NCM 			:= PosCabArray( aItens , "COD_NCM"                )
	_COD_OBS_L			:= PosCabArray( aItens , "COD_OBS_LANCTO_FISCAL"  )
	_COD_OBSER			:= PosCabArray( aItens , "COD_OBSERVACAO"         )
	_COD_OP				:= PosCabArray( aItens , "COD_OP"                 )
	_COD_OPERA			:= PosCabArray( aItens , "COD_OPERACAO"           )
	_COD_PRODUTO		:= PosCabArray( aItens , "COD_PRODUTO"            )
	_COD_ST_A			:= PosCabArray( aItens , "COD_SITUACAO_A"         )
	_COD_ST_B			:= PosCabArray( aItens , "COD_SITUACAO_B"         )
	_COD_UND_PADRAO 	:= PosCabArray( aItens , "COD_UND_PADRAO"         )
	_CRED_ICMS			:= PosCabArray( aItens , "IND_CRED_ICMSS"         )
	_CUSTO_ITE			:= PosCabArray( aItens , "CUSTO_ITEM"             )
	_CUSTO_UNI			:= PosCabArray( aItens , "CUSTO_UNIT"             )
	_D_COMP_AJ			:= PosCabArray( aItens , "DSC_COMP_AJUSTE"        )
	_D_COMPLEM			:= PosCabArray( aItens , "DSC_COMPLEMENTAR"       )
	_D_LNC_PIS			:= PosCabArray( aItens , "DAT_LANC_PIS_COFINS"    )
	_D_NAT_SER			:= PosCabArray( aItens , "DESC_NAT_SERV"          )
	_DAT_CONSU			:= PosCabArray( aItens , "DAT_CONSUMO"            )
	_DAT_DI 			:= PosCabArray( aItens , "DAT_DI"                 )
	_DAT_ENTRADA		:= PosCabArray( aItens , "DAT_ENTRADA"            )
	_DAT_EST_F			:= PosCabArray( aItens , "DAT_ESTQ_FIM"           )
	_DAT_FIM			:= PosCabArray( aItens , "DAT_FIM"                )
	_DAT_FIM_A			:= PosCabArray( aItens , "DAT_FIM_APUR"           )
	_DAT_INI_A			:= PosCabArray( aItens , "DAT_INI_APUR"           )
	_DAT_NF 			:= PosCabArray( aItens , "DAT_NF"                 )
	_DAT_PRODU			:= PosCabArray( aItens , "DAT_PRODUCAO"           )
	_DATA_EMIS			:= PosCabArray( aItens , "DATA_EMISSAO"           )
	_DATA_FATO			:= PosCabArray( aItens , "DATA_FATO_GERADOR"      )
	_DATA_PRODUTO 		:= PosCabArray( aItens , "DATA_PRODUTO"           )
	_DATA_REF			:= PosCabArray( aItens , "DATA_REF"               )
	_DESC_COMP			:= PosCabArray( aItens , "DESCRICAO_COMPL"        )
	_DESCR_DETALHADA	:= PosCabArray( aItens , "DESCR_DETALHADA"        )
	_DESCRICAO 			:= PosCabArray( aItens , "DESCRICAO"              )
	_DT_FIM				:= PosCabArray( aItens , "DATA_FIM"               )
	_DT_FIM_CO			:= PosCabArray( aItens , "DATA_FIM_COMPET"        )
	_DT_FIM_OP			:= PosCabArray( aItens , "DT_FIM_OP"              )
	_DT_FIS_RE			:= PosCabArray( aItens , "DATA_FISCAL_REF"        )
	_DT_FISCAL			:= PosCabArray( aItens , "DATA_FISCAL"            )
	_DT_INI				:= PosCabArray( aItens , "DATA_INI"               )
	_DT_INI_CO			:= PosCabArray( aItens , "DATA_INI_COMPET"        )
	_DT_INI_OP			:= PosCabArray( aItens , "DT_INI_OP"              )
	_DT_INVENT			:= PosCabArray( aItens , "DATA_INVENTARIO"        )
	_DT_MOVTO			:= PosCabArray( aItens , "DATA_MOVTO"             )
	_DT_SAI_RE			:= PosCabArray( aItens , "DATA_SAIDA_REC"         )
	_DT_SAIDA			:= PosCabArray( aItens , "DT_SAIDA"               )
	_DT_VENCTO			:= PosCabArray( aItens , "DATA_VENCTO"            )
	_DT_X2009			:= PosCabArray( aItens , "DATA_X2009"             )
	_DT_X2010			:= PosCabArray( aItens , "DATA_X2010"             )
	_DT_X2018			:= PosCabArray( aItens , "DATA_X2018"             )
	_EMBALAGEM			:= PosCabArray( aItens , "EMBALAGEM"              )
	_ESP_TRIBU			:= PosCabArray( aItens , "ESP_TRIBUTO"            )
	_GRUPO_CON			:= PosCabArray( aItens , "GRUPO_CONTAGEM"         )
	_ICMS_ALIQ_VLR 		:= PosCabArray( aItens , "VLR_ALIQ_ICMS"          )
	_IDENT_FIS			:= PosCabArray( aItens , "IDENT_FIS_JUR"          )
	_IE_COLETA			:= PosCabArray( aItens , "IE_COLETA"              )
	_IE_ENTREG			:= PosCabArray( aItens , "IE_ENTREGA"             )
	_IND_APUR_			:= PosCabArray( aItens , "IND_APUR_CUSTO"         )
	_IND_BEM_P			:= PosCabArray( aItens , "IND_BEM_PATR"           )
	_IND_CFINCID 		:= PosCabArray( aItens , "IND_INCID_COFINS"       )
	_IND_CLASSIF_ICMSS 	:= PosCabArray( aItens , "IND_CLASSIF_ICMSS"      )
	_IND_COMPR			:= PosCabArray( aItens , "IND_COMPRA_VENDA"       )
	_IND_CONTR			:= PosCabArray( aItens , "IND_CONTRATO"           )
	_SELO_CONTROLE 		:= PosCabArray( aItens , "IND_CONTROLE_SELO"      )
	_IND_DEB_C			:= PosCabArray( aItens , "IND_DEB_CRE"            )
	_IND_EMBAL			:= PosCabArray( aItens , "IND_EMBALAGEM"          )
	_IND_FABRIC_ESTAB 	:= PosCabArray( aItens , "IND_FABRIC_ESTAB"       )
	_IND_FATURA			:= PosCabArray( aItens , "IND_FATURA"             )
	_IND_FIS_JUR 		:= PosCabArray( aItens , "IND_FIS_JUR"            )
	_IND_FUNRURAL 		:= PosCabArray( aItens , "IND_FUNRURAL"           )
	_IND_ICINCID 		:= PosCabArray( aItens , "IND_INCID_ICMS_SER"     )
	_IND_ICOMP			:= PosCabArray( aItens , "IND_ICOMPL_LANCTO"      )
	_IND_INS_P			:= PosCabArray( aItens , "IND_PRODUTO_INS"        )
	_IND_INSUM			:= PosCabArray( aItens , "IND_INSUMO"             )
	_IND_LOCAL			:= PosCabArray( aItens , "IND_LOCAL_EXEC_SERV"    )
	_IND_MAT_S			:= PosCabArray( aItens , "IND_MAT_SERV"           )
	_IND_MOT_I			:= PosCabArray( aItens , "IND_MOT_INV"            )
	_IND_NAT_B			:= PosCabArray( aItens , "IND_NAT_BASE_CRED"      )
	_IND_NAT_F			:= PosCabArray( aItens , "IND_NAT_FRETE"          )
	_IND_NATFR			:= PosCabArray( aItens , "IND_NATUREZA_FRETE"     )
	_IND_NFE_D			:= PosCabArray( aItens , "IND_NFE_DENEG_INUT"     )
	_IND_OP_PR			:= PosCabArray( aItens , "IND_PRODUTO_OP"         )
	_IND_PETR_ENERG 	:= PosCabArray( aItens , "IND_PETR_ENERG"         )
	_IND_PI_CO			:= PosCabArray( aItens , "IND_VLR_PIS_COFINS"     )
	_IND_PIINCID 		:= PosCabArray( aItens , "IND_INCID_PIS"          )
	_IND_POS_N			:= PosCabArray( aItens , "IND_POS_NEG"            )
	_IND_PRD_INCENTIV 	:= PosCabArray( aItens , "IND_PRD_INCENTIV"       )
	_IND_PRODUTO 		:= PosCabArray( aItens , "IND_PRODUTO"            )
	_IND_REGIDO_SUBST 	:= PosCabArray( aItens , "IND_REGIDO_SUBST"       )
	_IND_S_PRO			:= PosCabArray( aItens , "IND_PRODUTO_SUB"        )
	_IND_SITUA			:= PosCabArray( aItens , "IND_SITUACAO"           )
	_IND_ST_PR			:= PosCabArray( aItens , "IND_PRODUTO_SUBST"      )
	_IND_TPCOR			:= PosCabArray( aItens , "IND_TP_CORRECAO"        )
	_IND_TPORD			:= PosCabArray( aItens , "IND_TP_ORDEM"           )
	_IND_TPSER			:= PosCabArray( aItens , "IND_TP_SERVICO"         )
	_INSS				:= PosCabArray( aItens , "INSS"                   )
	_INSS_PROD			:= PosCabArray( aItens , "COD_PRODUTO_INS"        )
	_IPI_ALIQ_VLR 		:= PosCabArray( aItens , "VLR_ALIQ_IPI"           )
	_IRRF				:= PosCabArray( aItens , "IRRF"                   )
	_ISS				:= PosCabArray( aItens , "ISS"                    )
	_MES_COMPE			:= PosCabArray( aItens , "MES_COMPETENCIA"        )
	_MOV_E_S_R			:= PosCabArray( aItens , "MOVTO_E_S_REF"          )
	_MOVTO_E_S			:= PosCabArray( aItens , "MOVTO_E_S"              )
	_MUNIC_COL			:= PosCabArray( aItens , "MUNIC_COLETA"           )
	_MUNIC_DES			:= PosCabArray( aItens , "COD_MUNICIPIO_DEST"     )
	_MUNIC_ENT			:= PosCabArray( aItens , "MUNIC_ENTREGA"          )
	_MUNIC_ORI			:= PosCabArray( aItens , "COD_MUNICIPIO_ORIG"     )
	_NAT_ESTOQ			:= PosCabArray( aItens , "COD_NAT_ESTOQUE"        )
	_NAT_SERV			:= PosCabArray( aItens , "COD_NAT_SERV"           )
	_NATUR_OP			:= PosCabArray( aItens , "COD_NATUREZA_OP"        )
	_NORM_DEV			:= PosCabArray( aItens , "NORM_DEV"               )
	_NUM_AUTEN			:= PosCabArray( aItens , "NUM_AUTENTIC_NFE"       )
	_NUM_CONTR			:= PosCabArray( aItens , "NUM_CONTROLE_DOCTO"     )
	_NUM_DEC_I			:= PosCabArray( aItens , "NUM_DEC_IMP_REF"        )
	_NUM_DI 			:= PosCabArray( aItens , "NUM_DI"                 )
	_NUM_DOCFI			:= PosCabArray( aItens , "NUM_DOCFIS"             )
	_NUM_DOCTO			:= PosCabArray( aItens , "NUM_DOCTO"              )
	_NUM_FIN_D			:= PosCabArray( aItens , "NUM_DOCFIS_FIN"         )
	_NUM_INI_D			:= PosCabArray( aItens , "NUM_DOCFIS_INI"         )
	_NUM_ITEM 			:= PosCabArray( aItens , "NUM_ITEM"               )
	_NUM_NF 			:= PosCabArray( aItens , "NUM_NF"                 )
	_NUM_PROCE			:= PosCabArray( aItens , "NUM_PROCESSO"           )
	_NUM_REF_D			:= PosCabArray( aItens , "NUM_DOCFIS_REF"         )
	_OP_PRODUT			:= PosCabArray( aItens , "COD_PRODUTO_OP"         )
	_ORIGEM 			:= PosCabArray( aItens , "ORIGEM"                 )
	_PERC_PERD			:= PosCabArray( aItens , "PERC_PERDA"             )
	_PERIODO_R			:= PosCabArray( aItens , "PERIODO_REF"            )
	_PRECO_ITE			:= PosCabArray( aItens , "PRECO_ITEM"             )
	_PRECO_UNI			:= PosCabArray( aItens , "PRECO_UNIT"             )
	_QTD_CORRE			:= PosCabArray( aItens , "QTD_CORRECAO"           )
	_QTD_FABR			:= PosCabArray( aItens , "QTD_FABR"               )
	_QTD_MAX_U			:= PosCabArray( aItens , "QTD_MAX_UTILIZADA"      )
	_QTD_MOVTO			:= PosCabArray( aItens , "QTD_MOVTO"              )
	_QTD_ORIGE			:= PosCabArray( aItens , "QTD_ORIGEM"             )
	_QTD_PRODU			:= PosCabArray( aItens , "QTD_PRODUZIDO"          )
	_QTD_TRANS			:= PosCabArray( aItens , "QTD_TRANSF"             )
	_QTD_UND_COM		:= PosCabArray( aItens , "QTD_UND_COM"            )
	_QTD_UND_MED		:= PosCabArray( aItens , "QTD_UND_MED"            )
	_QTD_USADA			:= PosCabArray( aItens , "QTD_USADA"              )
	_QUANTIDADE			:= PosCabArray( aItens , "QUANTIDADE"             )
	_REF_FIS_J			:= PosCabArray( aItens , "IND_FIS_JUR_REF"        )
	_REF_SERIE			:= PosCabArray( aItens , "SERIE_DOCFIS_REF"       )
	_S_COFINS			:= PosCabArray( aItens , "COD_SITUACAO_COFINS"    )
	_S_PIS				:= PosCabArray( aItens , "COD_SITUACAO_PIS"       )
	_SERIE_DOC			:= PosCabArray( aItens , "SERIE_DOCFIS"           )
	_SERIE_NF	 		:= PosCabArray( aItens , "SERIE_NF"               )
	_SITUACAO			:= PosCabArray( aItens , "SITUACAO"               )
	_ST_S_COFI			:= PosCabArray( aItens , "COD_SITUACAO_COFINS_ST" )
	_ST_S_PIS			:= PosCabArray( aItens , "COD_SITUACAO_PIS_ST"    )
	_SUB_PRODU			:= PosCabArray( aItens , "COD_PRODUTO_SUB"        )
	_SUBST_PRO			:= PosCabArray( aItens , "COD_PRODUTO_SUBST"      )
	_T_ICAUX			:= PosCabArray( aItens , "TRIB_ICMS_AUX"          )
	_T_ICMS				:= PosCabArray( aItens , "TRIB_ICMS"              )
	_T_IPI				:= PosCabArray( aItens , "TRIB_IPI"               )
	_T_IPI_AUX			:= PosCabArray( aItens , "TRIB_IPI_AUX"           )
	_T_IR				:= PosCabArray( aItens , "TRIB_IR"                )
	_TIPO_DI	 		:= PosCabArray( aItens , "TIPO_DI"                )
	_TRIBUTO			:= PosCabArray( aItens , "COD_TRIBUTO"            )
	_UF_COLETA			:= PosCabArray( aItens , "UF_COLETA"              )
	_UF_DESTIN			:= PosCabArray( aItens , "UF_DESTINO"             )
	_UF_ENTREG			:= PosCabArray( aItens , "UF_ENTREGA"             )
	_UF_ORIG_D			:= PosCabArray( aItens , "UF_ORIG_DEST"           )
	_V_A_COFIN			:= PosCabArray( aItens , "VLR_ALIQ_COFINS"        )
	_V_A_CSLL			:= PosCabArray( aItens , "VLR_ALIQ_CSLL"          )
	_V_A_ICMS			:= PosCabArray( aItens , "VLR_ALIQ_ICMS"          )
	_V_A_IPI			:= PosCabArray( aItens , "VLR_ALIQ_IPI"           )
	_V_A_IR				:= PosCabArray( aItens , "VLR_ALIQ_IR"            )
	_V_A_ISS			:= PosCabArray( aItens , "VLR_ALIQ_ISS"           )
	_V_A_PIS			:= PosCabArray( aItens , "VLR_ALIQ_PIS"           )
	_V_A_STCOF			:= PosCabArray( aItens , "VLR_ALIQ_COFINS_ST"     )
	_V_A_STPIS			:= PosCabArray( aItens , "VLR_ALIQ_PIS_ST"        )
	_V_ALSTICM			:= PosCabArray( aItens , "VLR_ALIQ_SUB_ICMS"      )
	_V_B_COF_S			:= PosCabArray( aItens , "VLR_BASE_COFINS_ST"     )
	_V_B_COFIN			:= PosCabArray( aItens , "VLR_BASE_COFINS"        )
	_V_B_CSLL			:= PosCabArray( aItens , "VLR_BASE_CSLL"          )
	_V_B_PIS			:= PosCabArray( aItens , "VLR_BASE_PIS"           )
	_V_B_PIS_S			:= PosCabArray( aItens , "VLR_BASE_PIS_ST"        )
	_V_COF_RET			:= PosCabArray( aItens , "VLR_COFINS_RETIDO"      )
	_V_COF_ST			:= PosCabArray( aItens , "VLR_COFINS_ST"          )
	_V_CONT_IT			:= PosCabArray( aItens , "VLR_CONTAB_ITEM"        )
	_V_ST_ICMS			:= PosCabArray( aItens , "VLR_SUBST_ICMS"         )
	_V_TOT_CUS			:= PosCabArray( aItens , "VLR_TOT_CUSTO"          )
	_V_TOT_NOT			:= PosCabArray( aItens , "VLR_TOT_NOTA"           )
	_VIA_TRANS			:= PosCabArray( aItens , "VIA_TRANSP"             )
	_VLR_BRUTO			:= PosCabArray( aItens , "VLR_BRUTO"              )
	_VLR_COFINS 		:= PosCabArray( aItens , "VLR_COFINS"             )
	_VLR_CSLL			:= PosCabArray( aItens , "VLR_CSLL"               )
	_VLR_DEDUCAO 		:= PosCabArray( aItens , "VLR_DEDUCAO"            )
	_VLR_DESCO			:= PosCabArray( aItens , "VLR_DESCONTO"           )
	_VLR_DESP_ADUAN 	:= PosCabArray( aItens , "VLR_DESP_ADUAN"         )
	_VLR_FRETE 			:= PosCabArray( aItens , "VLR_FRETE"              )
	_VLR_ICISENTA 		:= PosCabArray( aItens , "VLR_ISENTA_ICMS"        )
	_VLR_ICMS 			:= PosCabArray( aItens , "VLR_ICMS"               )
	_VLR_ICOUTRAS 		:= PosCabArray( aItens , "VLR_OUTRAS_ICMS"        )
	_VLR_II 			:= PosCabArray( aItens , "VLR_II"                 )
	_VLR_INF_A			:= PosCabArray( aItens , "VLR_INF_ADIC"           )
	_VLR_IPI 			:= PosCabArray( aItens , "VLR_IPI"                )
	_VLR_IPISENTA 		:= PosCabArray( aItens , "VLR_ISENTA_IPI"         )
	_VLR_IPOUTRAS 		:= PosCabArray( aItens , "VLR_OUTRAS_IPI"         )
	_VLR_IR				:= PosCabArray( aItens , "VLR_IR"                 )
	_VLR_IR_RE			:= PosCabArray( aItens , "VLR_IR_RETIDO"          )
	_VLR_ISS			:= PosCabArray( aItens , "VLR_ISS"                )
	_VLR_ITEM			:= PosCabArray( aItens , "VLR_ITEM"               )
	_VLR_NF 			:= PosCabArray( aItens , "VLR_NF"                 )
	_VLR_OUTRA			:= PosCabArray( aItens , "VLR_OUTRAS"             )
	_VLR_PIS 			:= PosCabArray( aItens , "VLR_PIS"                )
	_VLR_PIS_R			:= PosCabArray( aItens , "VLR_PIS_RETIDO"         )
	_VLR_PIS_S			:= PosCabArray( aItens , "VLR_PIS_ST"             )
	_VLR_PRODUTO 		:= PosCabArray( aItens , "VLR_PRODUTO"            )
	_VLR_SEGURO 		:= PosCabArray( aItens , "VLR_SEGURO"             )
	_VLR_SERVI			:= PosCabArray( aItens , "VLR_SERVICO"            )
	_VLR_TOT			:= PosCabArray( aItens , "VLR_TOT"                )
	_VLR_TRANS			:= PosCabArray( aItens , "VLR_TRANSF"             )
	_VLR_UNIT			:= PosCabArray( aItens , "VLR_UNIT"               )

RETURN


/*
=======================================================================================
Programa.:              fCmpZerado
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              16/03/2022
Descricao / Objetivo:   Avalia e formata conforme o tipo de campo
=======================================================================================
*/
Static Function fCmpZerado(cCampo)

	Local uRet := "@"
	Default cTab := ""

	If Empty(&(cCampo))
		uRet := "@"
	Elseif X3Tipo(Subs(cCampo,At("->",cCampo)+2))=="N"
		uRet := &(cCampo)*(10**TamSZR(cTab)[2])
	Elseif X3Tipo(Subs(cCampo,At("->",cCampo)+2))=="D"
		uRet := dTos(&(cCampo))
	Else
		uRet := &(cCampo)
	Endif

Return(uRet)	

/*
=======================================================================================
Programa.:              QrySAFX49
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              16/03/2022
Descricao / Objetivo:   Cria Tabela para o Registro SAFX49
=======================================================================================
*/

Static Function QrySAFX49()
	Local cQ := ""

	cQ += CRLF + " SELECT  "
	cQ += CRLF + " 	SD1.D1_FILIAL, "
	cQ += CRLF + " 	SF1.F1_HAWB, "
	cQ += CRLF + " 	SF1.F1_DOC, "
	cQ += CRLF + " 	SF1.F1_SERIE, "
	cQ += CRLF + " 	SF1.F1_FORNECE, "
	cQ += CRLF + " 	SF1.F1_LOJA, "
	cQ += CRLF + " 	SF1.F1_DTDIGIT, "
	cQ += CRLF + " 	SF1.F1_EMISSAO, "
	cQ += CRLF + " 	SD1.D1_TIPO, "
	cQ += CRLF + " 	SF3.F3_DTCANC, "
	cQ += CRLF + " 	SF3.F3_ESPECIE,"
	cQ += CRLF + " 	SD1.D1_COD, "
	cQ += CRLF + " 	SD1.D1_ITEM, "
	cQ += CRLF + " 	SD1.D1_UM, "
	cQ += CRLF + " 	SD1.D1_QUANT, "
	cQ += CRLF + " 	SD1.D1_CF , "
	cQ += CRLF + " 	COALESCE(CD5.CD5_NDI,'') CD5_NDI, "
	cQ += CRLF + " 	COALESCE(CD5.CD5_DTDI,'       ') CD5_DTDI, "
	cQ += CRLF + " 	COALESCE(CD5.CD5_DSPAD,0) CD5_DSPAD, "
	cQ += CRLF + " 	COALESCE(CD5.CD5_VDESDI, 0) CD5_VDESDI, "
	cQ += CRLF + " 	COALESCE(SW6.W6_DI_NUM ,'') W6_DI_NUM, "
	cQ += CRLF + " 	COALESCE(SW6.W6_DTREG_D,'        ') W6_DTREG_D, "
	cQ += CRLF + " 	COALESCE(SW6.W6_DESCONT, 0) W6_DESCONT, "
	cQ += CRLF + " 	COALESCE(SW6.W6_MODAL_D,'') W6_MODAL_D, "
	cQ += CRLF + " 	SFT.FT_BASEICM, "
	cQ += CRLF + " 	SFT.FT_BASEIPI, "
	cQ += CRLF + " 	SFT.FT_ALIQIPI, "
	cQ += CRLF + " 	SFT.FT_ALIQICM, "
	cQ += CRLF + " 	SFT.FT_POSIPI, "
	cQ += CRLF + " 	SFT.FT_ISENIPI, "
	cQ += CRLF + " 	SFT.FT_ISENICM, "
	cQ += CRLF + " 	SFT.FT_OUTRIPI, "
	cQ += CRLF + " 	SFT.FT_OUTRICM, "
	cQ += CRLF + " 	SFT.FT_VALCONT, "
	cQ += CRLF + " 	SFT.FT_VALICM, "
	cQ += CRLF + " 	SFT.FT_VALPIS, "
	cQ += CRLF + " 	SFT.FT_VALCOF, "
	cQ += CRLF + " 	SFT.FT_VALIPI, "
	cQ += CRLF + " 	SFT.FT_TOTAL, "
	cQ += CRLF + " 	SFT.FT_SEGURO, "
	cQ += CRLF + " 	SFT.FT_FRETE, "
	cQ += CRLF + " 	SF1.R_E_C_N_O_ SF1_RECNO, "
	cQ += CRLF + " 	SD1.R_E_C_N_O_ SD1_RECNO, "
	cQ += CRLF + " 	SF3.R_E_C_N_O_ SF3_RECNO, "
	cQ += CRLF + "  SFT.R_E_C_N_O_ SFT_RECNO, "
	cQ += CRLF + " 	COALESCE(CD5.R_E_C_N_O_, 0 ) CD5_RECNO, "
	cQ += CRLF + " 	COALESCE(SW6.R_E_C_N_O_, 0 ) W6_RECNO " + CRLF
	
	cQ += CRLF + " FROM " + RetSqlName("SD1") + "  SD1  " + CRLF
	
	cQ += CRLF + " INNER JOIN " + RetSqlName("SF1") + "  SF1  "
	cQ += CRLF + " 	ON  SF1.F1_FILIAL  = SD1.D1_FILIAL  "
	cQ += CRLF + " 	AND SF1.F1_DOC     = SD1.D1_DOC  "
	cQ += CRLF + " 	AND SF1.F1_SERIE   = SD1.D1_SERIE  "
	cQ += CRLF + " 	AND SF1.F1_FORNECE = SD1.D1_FORNECE  "
	cQ += CRLF + " 	AND SF1.F1_LOJA    = SD1.D1_LOJA  "
	cQ += CRLF + " 	AND SF1.F1_DTDIGIT = SD1.D1_DTDIGIT "
	cQ += CRLF + "  AND SF1.F1_EST     = 'EX'   "
	cQ += CRLF + " 	AND SF1.D_E_L_E_T_ = ' '  " + CRLF
	
	cQ += CRLF + " INNER JOIN " + RetSqlName("SFT") + "  SFT  "
	cQ += CRLF + " 	ON  SFT.FT_FILIAL  = SD1.D1_FILIAL  "
	cQ += CRLF + " 	AND SFT.FT_NFISCAL = SD1.D1_DOC  "
	cQ += CRLF + " 	AND SFT.FT_SERIE   = SD1.D1_SERIE  "
	cQ += CRLF + " 	AND SFT.FT_CLIEFOR = SD1.D1_FORNECE  "
	cQ += CRLF + " 	AND SFT.FT_LOJA    = SD1.D1_LOJA  "
	cQ += CRLF + " 	AND SFT.FT_PRODUTO = SD1.D1_COD  "
	cQ += CRLF + " 	AND SFT.FT_ITEM    = SD1.D1_ITEM  "
	cQ += CRLF + " 	AND SFT.D_E_L_E_T_ = ' '  " + CRLF

	cQ += CRLF + " INNER JOIN " + RetSqlName("SF3") + "  SF3 "
	cQ += CRLF + " 	ON  SF3.F3_FILIAL  = SD1.D1_FILIAL  "
	cQ += CRLF + " 	AND SF3.F3_NFISCAL = SD1.D1_DOC  "
	cQ += CRLF + " 	AND SF3.F3_SERIE   = SD1.D1_SERIE  "
	cQ += CRLF + " 	AND SF3.F3_CLIEFOR = SD1.D1_FORNECE  "
	cQ += CRLF + " 	AND SF3.F3_LOJA    = SD1.D1_LOJA  "
	cQ += CRLF + " 	AND SF3.F3_CFO     = SD1.D1_CF  "
	cQ += CRLF + " 	AND SF3.D_E_L_E_T_ = ' '  " + CRLF

	cQ += CRLF + " LEFT JOIN " + RetSqlName("CD5") + "  CD5  "
	cQ += CRLF + " 	ON  CD5.CD5_FILIAL = SD1.D1_FILIAL  "
	cQ += CRLF + " 	AND CD5.CD5_DOC    = SD1.D1_DOC  "
	cQ += CRLF + " 	AND CD5.CD5_SERIE  = SD1.D1_SERIE  "
	cQ += CRLF + " 	AND CD5.CD5_FORNEC = SD1.D1_FORNECE  "
	cQ += CRLF + " 	AND CD5.CD5_LOJA   = SD1.D1_LOJA "
	cQ += CRLF + " 	AND CD5.CD5_ITEM   = SD1.D1_ITEM "
	cQ += CRLF + " 	AND CD5.D_E_L_E_T_ = ' '  " + CRLF

	cQ += CRLF + " LEFT JOIN " + RetSqlName("SW6") + " SW6  "
	cQ += CRLF + " 	ON  SW6.W6_FILIAL  = SF1.F1_FILIAL  "
	cQ += CRLF + " 	AND SW6.W6_HAWB    = SF1.F1_HAWB  "
	cQ += CRLF + " 	AND SW6.W6_SE_NF   = SF1.F1_SERIE  "
	cQ += CRLF + " 	AND SW6.D_E_L_E_T_ = ' ' " + CRLF

	cQ += CRLF + " WHERE SD1.D1_FILIAL BETWEEN '" + cFilDe         + "' AND '" + cFilAte        + "' "
	cQ += CRLF + " 	AND SD1.D1_DTDIGIT BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' "
	cQ += CRLF + " 	AND SD1.D1_FORNECE BETWEEN '" + cCliForDe      + "' AND '" + cCliForAte     + "' "

	If Empty( __cSelNfs )
		cQ += CRLF + " AND SD1.D1_DOC BETWEEN '" + cDocFisDe + "' AND '" + cDocFisAte + "' "
	Else
		cQ += CRLF +" AND SD1.D1_DOC IN " + FormatIn(__cSelNfs, ";")
	EndIf

	cQ += CRLF + " 	AND SD1.D_E_L_E_T_ = ' '  " 
	cQ += CRLF + " ORDER BY SD1.D1_FILIAL,SD1.D1_DTDIGIT,SF1.F1_DOC, SD1.D1_ITEM  "

	FMontTab(cQ)
	
RETURN
/*
=======================================================================================
Programa.:              FMontTab()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              16/03/2022
Descricao / Objetivo:   
=======================================================================================
*/

Static Function FMontTab(cQuery)
	
	default cQuery := " "

	If Select(cAliasTrb) > 0
		(cAliasTrb)->(DBCLOSEAREA())
	EndIf
	
	if lDebug
		MemoWrite(cLocDest+cTab+".sql",cQuery)
	ENDIF
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTrb,.T.,.F.)
	
Return 

/*
=======================================================================================
Programa.:              fSAFX07()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Arquivo de Notas Fiscais                                    
=======================================================================================
*/

Static Function fSAFX07()

	cQ := CRLF + " SELECT R_E_C_N_O_ SF3_RECNO "
	cQ += CRLF + " 	FROM " + RetSqlName("SF3") + " SF3 "
	cQ += CRLF + " 	WHERE   SF3.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SF3.F3_FILIAL BETWEEN  '" + cFilDe         + "' AND '" + cFilAte        + "' "
	cQ += CRLF + " 		AND SF3.F3_ENTRADA BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' "
	cQ += CRLF + " 		AND SF3.F3_CLIEFOR BETWEEN '" + cCliForDe      + "' AND '" + cCliForAte     + "' "

	If Empty( __cSelNfs )
		cQ += CRLF + " 		AND SF3.F3_NFISCAL BETWEEN '" + cDocFisDe + "' AND '" + cDocFisAte + "' "
	Else
		cQ += CRLF + " 		AND SF3.F3_NFISCAL IN " + FormatIn(__cSelNfs, ";")
	EndIf
	
	If lSAFX08 .and. !lSAFX09
		cQ += CRLF + " 		AND NOT (SF3.F3_TIPO = 'S' OR SF3.F3_ESPECIE = 'RPS' OR (SF3.F3_ESPECIE = 'NFS' AND SF3.F3_CODNFE <> ' ')) "
	Endif		 

	If !lSAFX08 .and. lSAFX09
		cQ += CRLF + " 		AND (SF3.F3_TIPO = 'S' OR SF3.F3_ESPECIE = 'RPS' OR (SF3.F3_ESPECIE = 'NFS' AND SF3.F3_CODNFE <> ' ')) "
	Endif
	
	cQ += CRLF + " ORDER BY SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_NFISCAL "
	
	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			SF3->(dbGoto((cAliasTrb)->SF3_RECNO))
			If SF3->(Recno()) == (cAliasTrb)->SF3_RECNO
				lSA1 := .F.
				lSA2 := .F.
				lContinua := .T.
				
				// posiciona tabelas auxiliares
				lContinua := PosCliForSF3(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA,@lSA1,@lSA2,.T.)

				SFT->(dbSetOrder(1))
				SFT->(dbSeek(xFilial("SFT")+IIf(SF3->F3_CFO>="5","S","E")+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA))

				If lContinua	
					MontaItens(aCab,@aItens,SF3->F3_FILIAL)
								
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"MOVTO_E_S")
					aItens[Len(aItens)][nPosCmpCab][2] := MOVTO_E_S(SF3->F3_CFO,SF3->F3_FORMUL)
					nPosCmpCab:=PosCabArray(aItens,"NORM_DEV")
					aItens[Len(aItens)][nPosCmpCab][2] := NORM_DEV(SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"COD_DOCTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="SPED","NFE",IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="RPS","NFS",Eval(bCmpZerado,"SF3->F3_ESPECIE"))) //Eval(bCmpZerado,"SF3->F3_ESPECIE")
					nPosCmpCab:=PosCabArray(aItens,"IDENT_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := IDENT_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"COD_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := CmpSZeroEsq(IIf(lSA1,Eval(bCmpZerado,"SA1->A1_XCDSAP"),Eval(bCmpZerado,"SA2->A2_XCDSAP"))) //COD_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA)
					nPosCmpCab:=PosCabArray(aItens,"NUM_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := SF3->F3_NFISCAL
					nPosCmpCab:=PosCabArray(aItens,"SERIE_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_SERIE")
					nPosCmpCab:=PosCabArray(aItens,"DATA_EMISSAO")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(SF3->F3_EMISSAO)
					nPosCmpCab:=PosCabArray(aItens,"COD_CLASS_DOC_FIS")
					aItens[Len(aItens)][nPosCmpCab][2] := IIF(SF3->F3_TIPO=="S".Or.AllTrim(SF3->F3_ESPECIE)=="RPS".Or.(AllTrim(SF3->F3_ESPECIE)=="NFS".And.!Empty(SF3->F3_CODNFE)),"2","1")// IIf(SF3->F3_TIPO == "S","2","1")
					nPosCmpCab:=PosCabArray(aItens,"COD_MODELO")
					aItens[Len(aItens)][nPosCmpCab][2] := COD_MODELO(Alltrim(SF3->F3_ESPECIE)) // AModNot(SF3->F3_ESPECIE)
					nPosCmpCab:=PosCabArray(aItens,"COD_NATUREZA_OP")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_NATOPER")
					nPosCmpCab:=PosCabArray(aItens,"DATA_SAIDA_REC")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(SF3->F3_ENTRADA)
					nPosCmpCab:=PosCabArray(aItens,"VLR_PRODUTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Subs(SF3->F3_CFO,1,1)>="5",Eval(bCmpZerado,"SF2->F2_VALMERC"),Eval(bCmpZerado,"SF1->F1_VALMERC")) //VlrCabNota(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"VALMERC",.T.,.T.)
					nPosCmpCab:=PosCabArray(aItens,"VLR_TOT_NOTA")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Subs(SF3->F3_CFO,1,1)>="5",Eval(bCmpZerado,"SF2->F2_VALBRUT"),Eval(bCmpZerado,"SF1->F1_VALBRUT")) //VlrCabNota(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"VALBRUT",.T.,.T.)
					nPosCmpCab:=PosCabArray(aItens,"VLR_FRETE")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Subs(SF3->F3_CFO,1,1)>="5",Eval(bCmpZerado,"SF2->F2_FRETE"),Eval(bCmpZerado,"SF1->F1_FRETE")) //VlrCabNota(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"FRETE",.T.,.T.)
					nPosCmpCab:=PosCabArray(aItens,"VLR_SEGURO")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Subs(SF3->F3_CFO,1,1)>="5",Eval(bCmpZerado,"SF2->F2_SEGURO"),Eval(bCmpZerado,"SF1->F1_SEGURO")) //VlrCabNota(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"SEGURO",.T.,.T.)
					nPosCmpCab:=PosCabArray(aItens,"VLR_OUTRAS")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Subs(SF3->F3_CFO,1,1)>="5","@",Eval(bCmpZerado,"SF1->F1_DESPESA")) //VlrCabNota(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"DESPESA",.T.,.F.)
					nPosCmpCab:=PosCabArray(aItens,"VLR_DESCONTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Subs(SF3->F3_CFO,1,1)>="5",Eval(bCmpZerado,"SF2->F2_DESCONT"),Eval(bCmpZerado,"SF1->F1_DESCONT")) //VlrCabNota(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"DESCONT",.T.,.T.)
					nPosCmpCab:=PosCabArray(aItens,"SITUACAO")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Alltrim(SF3->F3_CODRSEF) == "101","S","N") //IIf(Alltrim(SF3->F3_OBSERV) == "NF CANCELADA" .and. !Empty(SF3->F3_DTCANC),"S","N")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_ALIQICM")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty(SF3->F3_VALICM),Eval(bCmpZerado,"SF2->F2_VALICM"),"@") //Eval(bCmpZerado,"SF3->F3_VALICM")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_IPI")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_ALIQIPI")
					nPosCmpCab:=PosCabArray(aItens,"VLR_IPI")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_VALIPI")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_IR")
					aItens[Len(aItens)][nPosCmpCab][2] := MaxAliqIt(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"ALQIRRF",.F.,.T.)
					nPosCmpCab:=PosCabArray(aItens,"VLR_IR")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Subs(SF3->F3_CFO,1,1)>="5",Eval(bCmpZerado,"SF2->F2_VALIRRF"),"@")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_ISS")
					aItens[Len(aItens)][nPosCmpCab][2] := VlrCD2(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"CD2_ALIQ",.F. ,.F. ,"ISS",SFT->FT_ITEM,SFT->FT_PRODUTO,SFT->FT_TIPOMOV)
					nPosCmpCab:=PosCabArray(aItens,"VLR_ISS")
					aItens[Len(aItens)][nPosCmpCab][2] := VlrCD2(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"CD2_VLTRIB",.F.,.T.,"ISS",SFT->FT_ITEM,SFT->FT_PRODUTO,SFT->FT_TIPOMOV) //IIf(Subs(SF3->F3_CFO,1,1)>="5",Eval(bCmpZerado,"SF2->F2_VALISS"),"@")
					nPosCmpCab:=PosCabArray(aItens,"VLR_SUBST_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := VlrCD2(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"CD2_VLTRIB",.F.,.T.,"SOL",,,)
					nPosCmpCab:=PosCabArray(aItens,"BASE_TRIB_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty(SF3->F3_VALICM),Eval(bCmpZerado,"SF2->F2_BASEICM"),"@") //Eval(bCmpZerado,"SF3->F3_VALCONT")
					nPosCmpCab:=PosCabArray(aItens,"BASE_ISEN_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_ISENICM")
					nPosCmpCab:=PosCabArray(aItens,"BASE_OUTR_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_OUTRICM")
					nPosCmpCab:=PosCabArray(aItens,"BASE_TRIB_IPI")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_BASEIPI")
					nPosCmpCab:=PosCabArray(aItens,"BASE_ISEN_IPI")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_ISENIPI")
					nPosCmpCab:=PosCabArray(aItens,"BASE_OUTR_IPI")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_OUTRIPI")
					nPosCmpCab:=PosCabArray(aItens,"BASE_TRIB_ISS")
					aItens[Len(aItens)][nPosCmpCab][2] := VlrCD2(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"CD2_BC",.F. ,.T. ,"ISS",SFT->FT_ITEM,SFT->FT_PRODUTO,SFT->FT_TIPOMOV) //IIf(Subs(SF3->F3_CFO,1,1)>="5",Eval(bCmpZerado,"SF2->F2_BASEISS"),"@")
					nPosCmpCab:=PosCabArray(aItens,"BASE_SUB_TRIB_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := VlrCD2(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"CD2_BC",.F. ,.T. ,"SOL",SFT->FT_ITEM,SFT->FT_PRODUTO,SFT->FT_TIPOMOV)
					nPosCmpCab:=PosCabArray(aItens,"NUM_CONTROLE_DOCTO")
					aItens[Len(aItens)][nPosCmpCab][2] := SF3->(Recno())
					nPosCmpCab:=PosCabArray(aItens,"IND_CRED_ICMSS")
					aItens[Len(aItens)][nPosCmpCab][2] := "N"
					nPosCmpCab:=PosCabArray(aItens,"IND_FATURA")
					aItens[Len(aItens)][nPosCmpCab][2] := "1"
					nPosCmpCab:=PosCabArray(aItens,"IND_COMPRA_VENDA")
					aItens[Len(aItens)][nPosCmpCab][2] := "VD"
					nPosCmpCab:=PosCabArray(aItens,"NUM_AUTENTIC_NFE")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_CHVNFE")
					nPosCmpCab:=PosCabArray(aItens,"UF_ORIG_DEST")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Subs(SF3->F3_CFO,1,1)>="5","@",Eval(bCmpZerado,"SF1->F1_UFORITR"))
					nPosCmpCab:=PosCabArray(aItens,"UF_DESTINO")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Subs(SF3->F3_CFO,1,1)>="5","@",Eval(bCmpZerado,"SF1->F1_UFDESTR"))
					nPosCmpCab:=PosCabArray(aItens,"COD_MUNICIPIO_ORIG")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Subs(SF3->F3_CFO,1,1)>="5","@",Eval(bCmpZerado,"SF1->F1_MUORITR"))
					nPosCmpCab:=PosCabArray(aItens,"COD_MUNICIPIO_DEST")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Subs(SF3->F3_CFO,1,1)>="5","@",Eval(bCmpZerado,"SF1->F1_MUDESTR"))
					nPosCmpCab:=PosCabArray(aItens,"IND_NFE_DENEG_INUT")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Alltrim(SF3->F3_CODRSEF) $ "205/301/302","1",IIf(Alltrim(SF3->F3_CODRSEF) $ "102","2","@"))

					nPosCmpCab:=PosCabArray(aItens,"IND_NAT_FRETE")
					aItens[Len(aItens)][nPosCmpCab][2] := If(!Empty(SFT->FT_INDNTFR),AllTrim(SFT->FT_INDNTFR),"@") 

					nPosCmpCab:=PosCabArray(aItens,"IND_NAT_BASE_CRED")
					aItens[Len(aItens)][nPosCmpCab][2] := If(!Empty(SFT->FT_CODBCC),AllTrim(SFT->FT_CODBCC),"@") 

					if len(aItens) >= _nLimite  //a cada 1000 linhas é gravado no arquivo para liberar a memória
						SalvaTXT(aCab,aItens)
						aItens := {}
						IF LDebug
							(cAliasTrb)->(dbCloseArea())
							RETURN
						ENDIF
					ENDIF
				Endif
			Endif	
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	

Return 


/*
=======================================================================================
Programa.:              fSAFX08()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Itens Notas Fiscais Mercadorias e Produtos                  
=======================================================================================
*/

Static Function fSAFX08()
	
	cQ := CRLF + " SELECT R_E_C_N_O_ SFT_RECNO "
	cQ += CRLF + " 	FROM " + RetSqlName("SFT") + " SFT "
	cQ += CRLF + " 	WHERE   SFT.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SFT.FT_DTCANC = ' ' "
	cQ += CRLF + " 		AND SFT.FT_FILIAL  BETWEEN '" + cFilDe         + "' AND '" + cFilAte        + "' "
	cQ += CRLF + " 		AND SFT.FT_CLIEFOR BETWEEN '" + cCliForDe      + "' AND '" + cCliForAte     + "' "
	cQ += CRLF + " 		AND SFT.FT_ENTRADA BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' "
	cQ += CRLF + " 		AND NOT (SFT.FT_TIPO = 'S' OR SFT.FT_ESPECIE = 'RPS' OR (SFT.FT_ESPECIE = 'NFS' AND SFT.FT_CODNFE <> ' ')) "

	If Empty( __cSelNfs )
		cQ += CRLF + " 		AND SFT.FT_NFISCAL BETWEEN '" + cDocFisDe + "' AND '" + cDocFisAte + "' "
	Else
		cQ += CRLF + " 		AND SFT.FT_NFISCAL IN " + FormatIn(__cSelNfs, ";")
	EndIf

	cQ += CRLF + " ORDER BY SFT.FT_FILIAL,SFT.FT_ENTRADA,SFT.FT_NFISCAL "

	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
		
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)

	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			SFT->(dbGoto((cAliasTrb)->SFT_RECNO))
			If SFT->(Recno()) == (cAliasTrb)->SFT_RECNO
				lSA1 := .F.
				lSA2 := .F.
				lContinua := .T.
				
				// posiciona tabelas auxiliares
				SB1->(dbSetOrder(1))
				If SB1->(!dbSeek(Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+SFT->FT_PRODUTO))
					cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+"/"+SFT->FT_PRODUTO+", serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"." 
					MS06GrvLog(cErro)
					lContinua := .F.
				Endif	

				If lContinua
					lContinua := .F.
					SF3->(dbSetOrder(1))
					If SF3->(dbSeek(SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA))
						While SF3->(!Eof()) .and. SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == ;
						SF3->F3_FILIAL+dTos(SF3->F3_ENTRADA)+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
							If SFT->FT_CFOP == SF3->F3_CFO
								lContinua := .T.
								Exit
							Endif
							SF3->(dbSkip())
						Enddo
					Endif
				Endif				
							
				If lContinua
					lContinua := PosCliForSF3(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA,@lSA1,@lSA2,.T.,SFT->FT_ITEM)
				Else
					If SB1->(Found())
						cErro := cTab+": Não encontrada tabela: SF3, serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"."
						MS06GrvLog(cErro)
					Endif	
				Endif					

				If lContinua	

					MontaItens(aCab,@aItens,SF3->F3_FILIAL)

					SF1->(dbSetOrder(1))
					SF1->(DbSeek(xFilial("SF1") + SFT->FT_NFISCAL + SFT->FT_SERIE + SFT->FT_CLIEFOR + SFT->FT_LOJA ))

					SW6->(dbSetOrder(1))
					SW6->(DbSeek(xFilial("SW6")+SF1->F1_HAWB))

					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"DATA_FISCAL")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(SF3->F3_ENTRADA)
					nPosCmpCab:=PosCabArray(aItens,"MOVTO_E_S")
					aItens[Len(aItens)][nPosCmpCab][2] := MOVTO_E_S(SF3->F3_CFO,SF3->F3_FORMUL)
					nPosCmpCab:=PosCabArray(aItens,"NORM_DEV")
					aItens[Len(aItens)][nPosCmpCab][2] := NORM_DEV(SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"COD_DOCTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="SPED","NFE",IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="RPS","NFS",Eval(bCmpZerado,"SF3->F3_ESPECIE"))) //Eval(bCmpZerado,"SF3->F3_ESPECIE")
					nPosCmpCab:=PosCabArray(aItens,"IND_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := IDENT_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"COD_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := CmpSZeroEsq(IIf(lSA1,Eval(bCmpZerado,"SA1->A1_XCDSAP"),Eval(bCmpZerado,"SA2->A2_XCDSAP"))) //COD_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA)
					nPosCmpCab:=PosCabArray(aItens,"NUM_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := SF3->F3_NFISCAL
					nPosCmpCab:=PosCabArray(aItens,"SERIE_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_SERIE")
					nPosCmpCab:=PosCabArray(aItens,"IND_BEM_PATR")
					aItens[Len(aItens)][nPosCmpCab][2] := "N"
					nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
					nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_PRODUTO")
					nPosCmpCab:=PosCabArray(aItens,"COD_UND_PADRAO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_UM")
					nPosCmpCab:=PosCabArray(aItens,"NUM_ITEM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ITEM")
					nPosCmpCab:=PosCabArray(aItens,"COD_CFO")
	
					if alltrim(SF3->F3_ESPECIE) == 'CTE' .and. IIf(lSA1,SA1->A1_EST == cEStFil, SA2->A2_EST == cEStFil)
						aItens[Len(aItens)][nPosCmpCab][2] := "1353 "
					else
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_CFOP")
					ENDIF
	
					nPosCmpCab:=PosCabArray(aItens,"COD_NATUREZA_OP")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_NATOPER")
					nPosCmpCab:=PosCabArray(aItens,"QUANTIDADE")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_QUANT")
					nPosCmpCab:=PosCabArray(aItens,"COD_MEDIDA")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_UM")
					nPosCmpCab:=PosCabArray(aItens,"COD_NBM")						
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_POSIPI")
					nPosCmpCab:=PosCabArray(aItens,"VLR_UNIT")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_PRCUNIT")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ITEM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_TOTAL")
					nPosCmpCab:=PosCabArray(aItens,"VLR_DESCONTO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_DESCONT")
					nPosCmpCab:=PosCabArray(aItens,"COD_SITUACAO_A")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_ORIGEM")
					nPosCmpCab:=PosCabArray(aItens,"COD_SITUACAO_B")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf((Empty(SFT->FT_CLASFIS) .or. !Len(Alltrim(SFT->FT_CLASFIS)) == 3),"@",Subs(SFT->FT_CLASFIS,2,2))
					nPosCmpCab:=PosCabArray(aItens,"VLR_FRETE")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_FRETE")
					nPosCmpCab:=PosCabArray(aItens,"VLR_OUTRAS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_OUTRICM")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ALIQICM")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALICM") //IIf(!Empty(SFT->FT_VALICM),IIf(SFT->FT_CFOP>="5",Eval(bCmpZerado,"SD2->D2_VALICM"),Eval(bCmpZerado,"SD1->D1_VALICM")),"@") //Eval(bCmpZerado,"SFT->FT_VALICM")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_IPI")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ALIQIPI")
					nPosCmpCab:=PosCabArray(aItens,"VLR_IPI")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALIPI")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_SUB_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ALIQSOL")
					nPosCmpCab:=PosCabArray(aItens,"VLR_SUBST_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ICMSRET")
					nPosCmpCab:=PosCabArray(aItens,"TRIB_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty(SFT->FT_BASEICM),"1",IIf(Empty(SFT->FT_BASEICM) .and. !Empty(SFT->FT_ISENICM),"2",IIf(Empty(SFT->FT_BASEICM) .and. Empty(SFT->FT_ISENICM) .and. !Empty(SFT->FT_OUTRICM),"3","3")))
					nPosCmpCab:=PosCabArray(aItens,"BASE_ICMS") 
					//aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty(SFT->FT_BASEICM),IIf(SFT->FT_CFOP>="5",Eval(bCmpZerado,"SD2->D2_BASEICM"),Eval(bCmpZerado,"SD1->D1_BASEICM")),IIf(Empty(SFT->FT_BASEICM) .and. !Empty(SFT->FT_ISENICM),Eval(bCmpZerado,"SFT->FT_ISENICM"),IIf(Empty(SFT->FT_BASEICM) .and. Empty(SFT->FT_ISENICM) .and. !Empty(SFT->FT_OUTRICM),Eval(bCmpZerado,"SFT->FT_OUTRICM"),IIf(SFT->FT_CFOP>="5",Eval(bCmpZerado,"SD2->D2_BASEICM"),Eval(bCmpZerado,"SD1->D1_BASEICM"))))) //IIf(!Empty(SFT->FT_BASEICM),Eval(bCmpZerado,"SFT->FT_BASEICM"),IIf(Empty(SFT->FT_BASEICM) .and. !Empty(SFT->FT_ISENICM),Eval(bCmpZerado,"SFT->FT_ISENICM"),IIf(Empty(SFT->FT_BASEICM) .and. Empty(SFT->FT_ISENICM) .and. !Empty(SFT->FT_OUTRICM),Eval(bCmpZerado,"SFT->FT_OUTRICM"),Eval(bCmpZerado,"SFT->FT_BASEICM"))))
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty(SFT->FT_BASEICM),Eval(bCmpZerado,"SFT->FT_BASEICM"),IIf(Empty(SFT->FT_BASEICM) .and. !Empty(SFT->FT_ISENICM),Eval(bCmpZerado,"SFT->FT_ISENICM"),IIf(Empty(SFT->FT_BASEICM) .and. Empty(SFT->FT_ISENICM) .and. !Empty(SFT->FT_OUTRICM),Eval(bCmpZerado,"SFT->FT_OUTRICM"),Eval(bCmpZerado,"SFT->FT_BASEICM"))))
					
					nPosCmpCab:=PosCabArray(aItens,"TRIB_IPI")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty(SFT->FT_BASEIPI),"1",IIf(Empty(SFT->FT_BASEIPI) .and. !Empty(SFT->FT_ISENIPI),"2",IIf(Empty(SFT->FT_BASEIPI) .and. Empty(SFT->FT_ISENIPI) .and. !Empty(SFT->FT_OUTRIPI),"3","3")))
					nPosCmpCab:=PosCabArray(aItens,"BASE_IPI")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty(SFT->FT_BASEIPI),Eval(bCmpZerado,"SFT->FT_BASEIPI"),IIf(Empty(SFT->FT_BASEIPI) .and. !Empty(SFT->FT_ISENIPI),Eval(bCmpZerado,"SFT->FT_ISENIPI"),IIf(Empty(SFT->FT_BASEIPI) .and. Empty(SFT->FT_ISENIPI) .and. !Empty(SFT->FT_OUTRIPI),Eval(bCmpZerado,"SFT->FT_OUTRIPI"),Eval(bCmpZerado,"SFT->FT_BASEIPI"))))
					nPosCmpCab:=PosCabArray(aItens,"BASE_SUB_TRIB_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_BASERET")
					nPosCmpCab:=PosCabArray(aItens,"VLR_CONTAB_ITEM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALCONT")
					nPosCmpCab:=PosCabArray(aItens,"TRIB_ICMS_AUX")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty(SFT->FT_BASEICM) .and. !Empty(SFT->FT_ISENICM),"2",IIf(!Empty(SFT->FT_BASEICM) .and. !Empty(SFT->FT_OUTRICM),"3","@"))
					nPosCmpCab:=PosCabArray(aItens,"BASE_ICMS_AUX")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty(SFT->FT_BASEICM) .and. !Empty(SFT->FT_ISENICM),Eval(bCmpZerado,"SFT->FT_ISENICM"),IIf(!Empty(SFT->FT_BASEICM) .and. !Empty(SFT->FT_OUTRICM),Eval(bCmpZerado,"SFT->FT_OUTRICM"),"@"))
					nPosCmpCab:=PosCabArray(aItens,"TRIB_IPI_AUX")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty(SFT->FT_BASEIPI) .and. !Empty(SFT->FT_ISENIPI),"2",IIf(!Empty(SFT->FT_BASEIPI) .and. !Empty(SFT->FT_OUTRIPI),"3","@"))
					nPosCmpCab:=PosCabArray(aItens,"BASE_IPI_AUX")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty(SFT->FT_BASEIPI) .and. !Empty(SFT->FT_ISENIPI),Eval(bCmpZerado,"SFT->FT_ISENIPI"),IIf(!Empty(SFT->FT_BASEIPI) .and. !Empty(SFT->FT_OUTRIPI),Eval(bCmpZerado,"SFT->FT_OUTRIPI"),"@"))
					nPosCmpCab:=PosCabArray(aItens,"VLR_BASE_COFINS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_BASECOF")
					nPosCmpCab:=PosCabArray(aItens,"VLR_COFINS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALCOF")
					nPosCmpCab:=PosCabArray(aItens,"VLR_BASE_COFINS_ST")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_BASECF3")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_COFINS_ST")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ALIQCF3")
					nPosCmpCab:=PosCabArray(aItens,"VLR_COFINS_ST")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALCF3")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_COFINS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ALIQCOF")
					nPosCmpCab:=PosCabArray(aItens,"COD_SITUACAO_COFINS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_CSTCOF")
	
					If !Empty(SFT->FT_VALCF3) .and. SFT->FT_CSTCOF == "06"
						nPosCmpCab:=PosCabArray(aItens,"COD_SITUACAO_COFINS_ST")
						aItens[Len(aItens)][nPosCmpCab][2] := "05"
					Endif	
	
					nPosCmpCab:=PosCabArray(aItens,"VLR_BASE_PIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_BASEPIS")
					nPosCmpCab:=PosCabArray(aItens,"VLR_PIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALPIS")
					nPosCmpCab:=PosCabArray(aItens,"VLR_BASE_PIS_ST")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_BASEPS3")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_PIS_ST")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ALIQPS3")
					nPosCmpCab:=PosCabArray(aItens,"VLR_PIS_ST")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALPS3")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_PIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ALIQPIS")
					nPosCmpCab:=PosCabArray(aItens,"COD_SITUACAO_PIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_CSTPIS")
	
					If !Empty(SFT->FT_VALPS3) .and. SFT->FT_CSTPIS == "06"
						nPosCmpCab:=PosCabArray(aItens,"COD_SITUACAO_PIS_ST")
						aItens[Len(aItens)][nPosCmpCab][2] := "05"
					Endif
	
					nPosCmpCab:=PosCabArray(aItens,"DAT_LANC_PIS_COFINS")
	
					If SFT->FT_TIPOMOV=="S" .and. AllTrim(SFT->FT_CSTPIS) == "49" .and. AllTrim(SFT->FT_CSTCOF) == "49" 
						aItens[Len(aItens)][nPosCmpCab][2] := "@"
					ElseIf SFT->FT_TIPOMOV=="E" .and. AllTrim(SFT->FT_CSTPIS) == "70" .and. AllTrim(SFT->FT_CSTCOF) == "70"
						aItens[Len(aItens)][nPosCmpCab][2] := "@"
					Else
						aItens[Len(aItens)][nPosCmpCab][2] := If(SFT->FT_TIPOMOV=="E", DtoS(SFT->FT_ENTRADA),DtoS(SFT->FT_EMISSAO))
					EndIf						
	
					nPosCmpCab:=PosCabArray(aItens,"COD_TRIB_IPI")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_CTIPI")
					nPosCmpCab:=PosCabArray(aItens,"COD_CONTA")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_CONTA")
					nPosCmpCab:=PosCabArray(aItens,"DAT_DI")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SW6->W6_DTREG_D")
					nPosCmpCab:=PosCabArray(aItens,"NUM_DEC_IMP_REF")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SW6->W6_DI_NUM")
					nPosCmpCab:=PosCabArray(aItens,"IND_NATUREZA_FRETE")
					aItens[Len(aItens)][nPosCmpCab][2] := If(!Empty(SFT->FT_INDNTFR),AllTrim(SFT->FT_INDNTFR),"@") 
					nPosCmpCab:=PosCabArray(aItens,"IND_NAT_BASE_CRED")
					aItens[Len(aItens)][nPosCmpCab][2] := If(!Empty(SFT->FT_CODBCC),AllTrim(SFT->FT_CODBCC),"@") 
				
					if len(aItens) >= _nLimite  //a cada 1000 linhas é gravado no arquivo para liberar a memória
						SalvaTXT(aCab,aItens)
						aItens := {}
						IF LDebug
							(cAliasTrb)->(dbCloseArea())
							RETURN
						ENDIF
					ENDIF
				Endif	
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	

Return

/*
=======================================================================================
Programa.:              fSAFX09()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Itens Notas Fiscais de Serviços                             
=======================================================================================
*/

Static Function fSAFX09()
	
	cQ := CRLF + " SELECT SFT.R_E_C_N_O_ SFT_RECNO "
	cQ += CRLF + " FROM " + RetSqlName("SFT") + " SFT "
	cQ += CRLF + " 	  WHERE SFT.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SFT.FT_DTCANC  = ' ' "
	cQ += CRLF + " 		AND SFT.FT_FILIAL  BETWEEN '" + cFilDe         + "' AND '" + cFilAte        + "' "
	cQ += CRLF + " 		AND SFT.FT_ENTRADA BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' "
	cQ += CRLF + " 		AND SFT.FT_CLIEFOR BETWEEN '" + cCliForDe      + "' AND '" + cCliForAte     + "' "
	cQ += CRLF + " 		AND (SFT.FT_TIPO = 'S' OR SFT.FT_ESPECIE = 'RPS' OR (SFT.FT_ESPECIE = 'NFS' AND SFT.FT_CODNFE <> ' ')) "

	If Empty( __cSelNfs )
		cQ += CRLF + " 		AND SFT.FT_NFISCAL BETWEEN '" + cDocFisDe + "' AND '" + cDocFisAte + "' "
	Else
		cQ += CRLF + " 		AND SFT.FT_NFISCAL IN " + FormatIn(__cSelNfs, ";")
	EndIf

	cQ += CRLF + " ORDER BY SFT.FT_FILIAL,SFT.FT_ENTRADA,SFT.FT_NFISCAL "
	
	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			SFT->(dbGoto((cAliasTrb)->SFT_RECNO))
			If SFT->(Recno()) == (cAliasTrb)->SFT_RECNO
				lSA1 := .F.
				lSA2 := .F.
				lContinua := .T.
				
				// posiciona tabelas auxiliares
				SB1->(dbSetOrder(1))
				If SB1->(!dbSeek(Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+SFT->FT_PRODUTO))
					lContinua := .F.
					cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+"/"+SFT->FT_PRODUTO+", serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"."
					MS06GrvLog(cErro)
				Endif	

				If lContinua
					lContinua := .F.
					SF3->(dbSetOrder(1))
					If SF3->(dbSeek(SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA))
						While SF3->(!Eof()) .and. SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == ;
						SF3->F3_FILIAL+dTos(SF3->F3_ENTRADA)+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
							If SFT->FT_CFOP == SF3->F3_CFO
								lContinua := .T.
								Exit
							Endif
							SF3->(dbSkip())
						Enddo
					Endif
				Endif				
							
				If lContinua
					lContinua := PosCliForSF3(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA,@lSA1,@lSA2,.T.)
				Else
					If SB1->(Found())
						cErro := cTab+": Não encontrada tabela: SF3, serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"."
						MS06GrvLog(cErro)
					Endif	
				Endif					

				If lContinua	
					MontaItens(aCab,@aItens,SF3->F3_FILIAL)
								
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"DATA_FISCAL")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(SF3->F3_ENTRADA)
					nPosCmpCab:=PosCabArray(aItens,"MOVTO_E_S")
					aItens[Len(aItens)][nPosCmpCab][2] := MOVTO_E_S(SF3->F3_CFO,SF3->F3_FORMUL)
					nPosCmpCab:=PosCabArray(aItens,"NORM_DEV")
					aItens[Len(aItens)][nPosCmpCab][2] := NORM_DEV(SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"COD_DOCTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="SPED","NFE",IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="RPS","NFS",Eval(bCmpZerado,"SF3->F3_ESPECIE"))) //Eval(bCmpZerado,"SF3->F3_ESPECIE")
					nPosCmpCab:=PosCabArray(aItens,"IND_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := IDENT_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"COD_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := CmpSZeroEsq(IIf(lSA1,Eval(bCmpZerado,"SA1->A1_XCDSAP"),Eval(bCmpZerado,"SA2->A2_XCDSAP"))) //COD_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA)
					nPosCmpCab:=PosCabArray(aItens,"NUM_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := SF3->F3_NFISCAL
					nPosCmpCab:=PosCabArray(aItens,"SERIE_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_SERIE")
					nPosCmpCab:=PosCabArray(aItens,"COD_SERVICO")
					aItens[Len(aItens)][nPosCmpCab][2] := Right(Alltrim(SFT->FT_PRODUTO),TamSZR(cTab)[1]) //Eval(bCmpZerado,"SFT->FT_PRODUTO")
					nPosCmpCab:=PosCabArray(aItens,"NUM_ITEM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ITEM")
					nPosCmpCab:=PosCabArray(aItens,"VLR_SERVICO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_PRCUNIT")
					nPosCmpCab:=PosCabArray(aItens,"VLR_TOT")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_TOTAL")
					nPosCmpCab:=PosCabArray(aItens,"COD_CFO")
					//aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_CFOP")
					if alltrim(SF3->F3_ESPECIE) == 'CTE' .and. IIf(lSA1,SA1->A1_EST == cEStFil, SA2->A2_EST == cEStFil)
						aItens[Len(aItens)][nPosCmpCab][2] := "1353 " //fCmpZerado("SFT->FT_CFOP")//*****************//
					else
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_CFOP")//*****************//
					ENDIF
					nPosCmpCab:=PosCabArray(aItens,"COD_NATUREZA_OP")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_NATOPER")
					nPosCmpCab:=PosCabArray(aItens,"QUANTIDADE")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_QUANT")
					nPosCmpCab:=PosCabArray(aItens,"VLR_UNIT")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_PRCUNIT")
					nPosCmpCab:=PosCabArray(aItens,"VLR_DESCONTO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_DESCONT")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_IR")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ALIQIRR")
					nPosCmpCab:=PosCabArray(aItens,"VLR_IR")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALIRR")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_ISS")
					aItens[Len(aItens)][nPosCmpCab][2] := VlrCD2(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"CD2_ALIQ",.F.,.F.,"ISS",SFT->FT_ITEM,SFT->FT_PRODUTO,SFT->FT_TIPOMOV)
					nPosCmpCab:=PosCabArray(aItens,"VLR_ISS")
					aItens[Len(aItens)][nPosCmpCab][2] := VlrCD2(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"CD2_VLTRIB",.F.,.F.,"ISS",SFT->FT_ITEM,SFT->FT_PRODUTO,SFT->FT_TIPOMOV)
					nPosCmpCab:=PosCabArray(aItens,"TRIB_IR")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty(SFT->FT_BASEIRR),"1","@")
					nPosCmpCab:=PosCabArray(aItens,"BASE_IR")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_BASEIRR")
					nPosCmpCab:=PosCabArray(aItens,"BASE_ISS")
					aItens[Len(aItens)][nPosCmpCab][2] := VlrCD2(SF3->F3_FILIAL,SF3->F3_SERIE,SF3->F3_NFISCAL,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO,"CD2_BC",.F. ,.F. ,"ISS",SFT->FT_ITEM,SFT->FT_PRODUTO,SFT->FT_TIPOMOV) //Eval(bCmpZerado,"SFT->FT_BASEICM")
					nPosCmpCab:=PosCabArray(aItens,"VLR_BASE_CSLL")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_BASECSL")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_CSLL")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ALIQCSL")
					nPosCmpCab:=PosCabArray(aItens,"VLR_CSLL")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALCSL")
					nPosCmpCab:=PosCabArray(aItens,"VLR_BASE_PIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_BASEPIS")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_PIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ALIQPIS")
					nPosCmpCab:=PosCabArray(aItens,"VLR_PIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALPIS")
					nPosCmpCab:=PosCabArray(aItens,"VLR_BASE_COFINS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_BASECOF")
					nPosCmpCab:=PosCabArray(aItens,"VLR_ALIQ_COFINS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ALIQCOF")
					nPosCmpCab:=PosCabArray(aItens,"VLR_COFINS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALCOF")
					nPosCmpCab:=PosCabArray(aItens,"COD_TRIB_ISS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_CSTISS")
					nPosCmpCab:=PosCabArray(aItens,"IND_VLR_PIS_COFINS")
					aItens[Len(aItens)][nPosCmpCab][2] := "N"
					nPosCmpCab:=PosCabArray(aItens,"COD_SITUACAO_PIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_CSTPIS")
					nPosCmpCab:=PosCabArray(aItens,"COD_SITUACAO_COFINS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_CSTCOF")
					nPosCmpCab:=PosCabArray(aItens,"IND_LOCAL_EXEC_SERV")
					aItens[Len(aItens)][nPosCmpCab][2] := "0"
					nPosCmpCab:=PosCabArray(aItens,"VLR_COFINS_RETIDO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALCF3")
					nPosCmpCab:=PosCabArray(aItens,"VLR_PIS_RETIDO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALPS3")
					nPosCmpCab:=PosCabArray(aItens,"COD_CONTA")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_CONTA")

					//Conforme Chamado 422291 DAC 26/08/2020
					nPosCmpCab:=PosCabArray(aItens,"IND_NAT_BASE_CRED")
					aItens[Len(aItens)][nPosCmpCab][2] := If(!Empty(SFT->FT_CODBCC),AllTrim(SFT->FT_CODBCC),"@") 

					//Atualização conforme chamado INC0012933 - Notas de Serviço sem DATA LANC PIS COFINS DAC 27/01/2021
					//incluido o campo DAT_LANC_PIS_COFINS o mesmo não existia no programa
					nPosCmpCab:=PosCabArray(aItens,"DAT_LANC_PIS_COFINS")
					aItens[Len(aItens)][nPosCmpCab][2] := If(SFT->FT_TIPOMOV=="E", DtoS(SFT->FT_ENTRADA),DtoS(SFT->FT_EMISSAO))

	
				Endif	
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX10()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Arquivo de Controle de Estoque                              
=======================================================================================
*/

Static Function fSAFX10()
		// notas fiscais
	cQ := CRLF + " SELECT SFT.R_E_C_N_O_ SFT_RECNO "
	cQ += CRLF + " FROM " + RetSqlName("SFT") + " 
	
	cQ += CRLF + " 	INNER JOIN " + RetSqlName("SF4") + " SF4 "
	cQ += CRLF + " 		ON  SF4.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SUBSTR(SF4.F4_FILIAL,1,6) = SUBSTR(SFT.FT_FILIAL,1,6) "
	cQ += CRLF + " 		AND SF4.F4_ESTOQUE = 'S' "
	cQ += CRLF + " 		AND SF4.F4_CODIGO  = SFT.FT_TES "
	
	cQ += CRLF + " 	WHERE   SFT.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SFT.FT_DTCANC  = ' ' "
	cQ += CRLF + " 		AND SFT.FT_QUANT   > 0 "
	cQ += CRLF + " 		AND SFT.FT_FILIAL  BETWEEN '" + cFilDe         + "' AND '" + cFilAte        + "' "
	cQ += CRLF + " 		AND SFT.FT_ENTRADA BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' "
	cQ += CRLF + " 		AND SFT.FT_CLIEFOR BETWEEN '" + cCliForDe      + "' AND '" + cCliForAte     + "' "

	If Empty( __cSelNfs )
		cQ += CRLF + "		AND SFT.FT_NFISCAL BETWEEN '" + cDocFisDe + "' AND '" + cDocFisAte + "' "
	Else
		cQ += CRLF + "		AND SFT.FT_NFISCAL IN " + FormatIn(__cSelNfs, ";") 
	EndIf

	cQ += CRLF + "	ORDER BY SFT.FT_FILIAL,SFT.FT_ENTRADA,SFT.FT_NFISCAL "

		
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			SFT->(dbGoto((cAliasTrb)->SFT_RECNO))
			If SFT->(Recno()) == (cAliasTrb)->SFT_RECNO
				lSA1 := .F.
				lSA2 := .F.
				lContinua := .T.
				
				// posiciona tabelas auxiliares
				SB1->(dbSetOrder(1))
				If SB1->(!dbSeek(Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+SFT->FT_PRODUTO))
					lContinua := .F.
					cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+"/"+SFT->FT_PRODUTO+", serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"."
					MS06GrvLog(cErro)
				Endif	

				If lContinua
					lContinua := .F.
					SF3->(dbSetOrder(1))
					If SF3->(dbSeek(SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA))
						While SF3->(!Eof()) .and. SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == ;
						SF3->F3_FILIAL+dTos(SF3->F3_ENTRADA)+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
							If SFT->FT_CFOP == SF3->F3_CFO
								lContinua := .T.
								Exit
							Endif
							SF3->(dbSkip())
						Enddo
					Endif
				Endif				
							
				If lContinua
					lContinua := PosCliForSF3(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA,@lSA1,@lSA2,.T.)
				Else
					If SB1->(Found())
						cErro := cTab+": Não encontrada tabela: SF3, serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"."
						MS06GrvLog(cErro)
					Endif	
				Endif					

				If lContinua	
					MontaItens(aCab,@aItens,SFT->FT_FILIAL)
								
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"MOVTO_E_S")
					aItens[Len(aItens)][nPosCmpCab][2] := MOVTO_E_S(SF3->F3_CFO,SF3->F3_FORMUL)
					nPosCmpCab:=PosCabArray(aItens,"NORM_DEV")
					aItens[Len(aItens)][nPosCmpCab][2] := NORM_DEV(SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"GRUPO_CONTAGEM")
					aItens[Len(aItens)][nPosCmpCab][2] := "1"
					nPosCmpCab:=PosCabArray(aItens,"COD_DOCTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="SPED","NFE",IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="RPS","NFS",Eval(bCmpZerado,"SF3->F3_ESPECIE"))) //Eval(bCmpZerado,"SF3->F3_ESPECIE")
					nPosCmpCab:=PosCabArray(aItens,"DATA_MOVTO")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(SF3->F3_ENTRADA)
					nPosCmpCab:=PosCabArray(aItens,"NUM_DOCTO")
					aItens[Len(aItens)][nPosCmpCab][2] := SF3->F3_NFISCAL
					nPosCmpCab:=PosCabArray(aItens,"SERIE_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_SERIE")
					nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
					nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_PRODUTO")
					nPosCmpCab:=PosCabArray(aItens,"COD_UND_PADRAO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_UM")
					nPosCmpCab:=PosCabArray(aItens,"COD_ALMOX")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_LOCPAD")
					nPosCmpCab:=PosCabArray(aItens,"COD_CUSTO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_CC")
					nPosCmpCab:=PosCabArray(aItens,"NUM_ITEM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_ITEM")
					nPosCmpCab:=PosCabArray(aItens,"COD_NAT_ESTOQUE")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_TIPO") //COD_NAT_ESTOQUE("SB1")
					nPosCmpCab:=PosCabArray(aItens,"QTD_MOVTO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_QUANT")
					nPosCmpCab:=PosCabArray(aItens,"PRECO_UNIT")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_PRCUNIT")
					nPosCmpCab:=PosCabArray(aItens,"PRECO_ITEM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_TOTAL")
					nPosCmpCab:=PosCabArray(aItens,"CUSTO_UNIT")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCalZerado,SFT->FT_VALCONT/SFT->FT_QUANT)
					nPosCmpCab:=PosCabArray(aItens,"CUSTO_ITEM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALCONT")
					nPosCmpCab:=PosCabArray(aItens,"COD_CFO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_CFO")
					nPosCmpCab:=PosCabArray(aItens,"COD_ENT_SAIDA")
					aItens[Len(aItens)][nPosCmpCab][2] := "3"
					nPosCmpCab:=PosCabArray(aItens,"VLR_IPI")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALIPI")
					nPosCmpCab:=PosCabArray(aItens,"COD_NBM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_POSIPI")
					nPosCmpCab:=PosCabArray(aItens,"IND_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := IDENT_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"COD_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := CmpSZeroEsq(IIf(lSA1,Eval(bCmpZerado,"SA1->A1_XCDSAP"),Eval(bCmpZerado,"SA2->A2_XCDSAP"))) //COD_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA)
					nPosCmpCab:=PosCabArray(aItens,"VLR_ICMS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SFT->FT_VALICM")
				Endif	
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
	
	// movimentos internos
	cQ := CRLF + " SELECT SD3.R_E_C_N_O_ SD3_RECNO "
	cQ += CRLF + "  FROM " + RetSqlName("SD3") + " SD3 "
	cQ += CRLF + "  WHERE   SD3.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SD3.D3_FILIAL  BETWEEN '" + cFilDe         + "' AND '" + cFilAte        + "' "
	cQ += CRLF + " 		AND SD3.D3_EMISSAO BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' "
	cQ += CRLF + " 		AND SD3.D3_ESTORNO <> 'S' "
	cQ += CRLF + " 		AND SD3.D3_QUANT    > 0 "
	cQ += CRLF + " ORDER BY SD3.D3_FILIAL,SD3.D3_EMISSAO,SD3.D3_DOC "

	//MemoWrite(cLocDest+cTab+"_2"+".txt",cQ)
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			SD3->(dbGoto((cAliasTrb)->SD3_RECNO))
			If SD3->(Recno()) == (cAliasTrb)->SD3_RECNO
				lContinua := .T.
				
				// posiciona tabelas auxiliares
				SB1->(dbSetOrder(1))
				If SB1->(!dbSeek(Padr(Subs(SD3->D3_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+SD3->D3_COD))
					lContinua := .F.
					cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(SD3->D3_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+"/"+SD3->D3_COD+", movimento interno: "+SD3->D3_DOC+"." 
					MS06GrvLog(cErro)
				Endif	

				If lContinua	
					MontaItens(aCab,@aItens,SD3->D3_FILIAL)
								
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SD3->D3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SD3->D3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"MOVTO_E_S")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Subs(SD3->D3_CF,1,2) == "DE","1","9")
					nPosCmpCab:=PosCabArray(aItens,"NORM_DEV")
					aItens[Len(aItens)][nPosCmpCab][2] := "1"
					nPosCmpCab:=PosCabArray(aItens,"GRUPO_CONTAGEM")
					aItens[Len(aItens)][nPosCmpCab][2] := "1"
					nPosCmpCab:=PosCabArray(aItens,"COD_DOCTO")
					aItens[Len(aItens)][nPosCmpCab][2] := "INT"
					nPosCmpCab:=PosCabArray(aItens,"DATA_MOVTO")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(SD3->D3_EMISSAO)
					nPosCmpCab:=PosCabArray(aItens,"NUM_DOCTO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SD3->D3_DOC")
					nPosCmpCab:=PosCabArray(aItens,"SERIE_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SD3->D3_CF")
					nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
					nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SD3->D3_COD")
					nPosCmpCab:=PosCabArray(aItens,"COD_UND_PADRAO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SD3->D3_UM")
					nPosCmpCab:=PosCabArray(aItens,"COD_ALMOX")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SD3->D3_LOCAL")
					nPosCmpCab:=PosCabArray(aItens,"COD_CUSTO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SD3->D3_CC")
					nPosCmpCab:=PosCabArray(aItens,"NUM_ITEM")
					aItens[Len(aItens)][nPosCmpCab][2] := "001"
					nPosCmpCab:=PosCabArray(aItens,"COD_NAT_ESTOQUE")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_TIPO") //COD_NAT_ESTOQUE("SB1")
					nPosCmpCab:=PosCabArray(aItens,"QTD_MOVTO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SD3->D3_QUANT")
					nPosCmpCab:=PosCabArray(aItens,"PRECO_UNIT")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCalZerado,IIf(!Empty(SD3->D3_CUSTO1),SD3->D3_CUSTO1/SD3->D3_QUANT,0))
					nPosCmpCab:=PosCabArray(aItens,"PRECO_ITEM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SD3->D3_CUSTO1")
					nPosCmpCab:=PosCabArray(aItens,"CUSTO_UNIT")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCalZerado,IIf(!Empty(SD3->D3_CUSTO1),SD3->D3_CUSTO1/SD3->D3_QUANT,0))
					nPosCmpCab:=PosCabArray(aItens,"CUSTO_ITEM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SD3->D3_CUSTO1")
					nPosCmpCab:=PosCabArray(aItens,"COD_CFO")
					//aItens[Len(aItens)][nPosCmpCab][2] := SFT->FT_CFOP
					nPosCmpCab:=PosCabArray(aItens,"COD_ENT_SAIDA")
					aItens[Len(aItens)][nPosCmpCab][2] := "1"
					nPosCmpCab:=PosCabArray(aItens,"COD_NBM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_POSIPI")
				Endif	
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX16()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Arquivo de Produtos Cuja Produção Utiliza Insumos           
=======================================================================================
*/

Static Function fSAFX16()
		cQ := CRLF + " SELECT SB1.R_E_C_N_O_ SB1_RECNO, SG1.R_E_C_N_O_ SG1_RECNO "
		cQ += CRLF + " FROM " + RetSqlName("SB1") + " SB1 "
		
		cQ += CRLF + " 	INNER JOIN " + RetSqlName("SG1") + " SG1 "
		cQ += CRLF + " 		ON SG1.D_E_L_E_T_ = ' ' "
		cQ += CRLF + " 		AND SG1.SUBSTR(G1_FILIAL,1,6) = SUBSTR(SB1.B1_FILIAL,1,6) "
		cQ += CRLF + " 		AND SG1.G1_COD = B1_COD "
		
		cQ += CRLF + " 	WHERE   SB1.D_E_L_E_T_ = ' ' "
		cQ += CRLF + " 		AND SUBSTR(SB1.B1_FILIAL,1,6) BETWEEN '" + Subs(cFilDe,1,6) + "' AND '" + Subs(cFilAte,1,6) + "' "
		cQ += CRLF + " 		AND SB1.B1_COD BETWEEN '" + cProdDe + "' AND '" + cProdAte + "' "
		cQ += CRLF + " 		AND SB1.B1_TIPO    = 'PA' "
		cQ += CRLF + " 		AND SB1.B1_MSBLQL <> '1' "
		cQ += CRLF + " ORDER BY SB1.B1_FILIAL,SB1.B1_COD "

		If lDebug
			MemoWrite(cLocDest+cTab+".txt",cQ)
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
		
		// monta array com campos do arquivo
		MontaCab(Alltrim(cTab),@aCab)

		If !Empty(aCab)
			While (cAliasTrb)->(!Eof())
					
				SB1->(dbGoto((cAliasTrb)->SB1_RECNO))
				If SB1->(Recno()) == (cAliasTrb)->SB1_RECNO
					lContinua := .T.
					If aScan(aSG1,SB1->B1_COD) == 0
						aAdd(aSG1,SB1->B1_COD)
					Else
						(cAliasTrb)->(dbSkip())
						Loop
					Endif
					
					// posiciona tabelas auxiliares
					SG1->(dbGoto((cAliasTrb)->SG1_RECNO))
					If lContinua	
						MontaItens(aCab,@aItens,SB1->B1_FILIAL)
									
						// comeca gravar campos do layout
						nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
						aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SG1->G1_FILIAL)
						nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
						aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SG1->G1_FILIAL)
						nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
						aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
						nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_COD")
						nPosCmpCab:=PosCabArray(aItens,"DATA_MOVTO")
						aItens[Len(aItens)][nPosCmpCab][2] := dTos(dDataBase)
						nPosCmpCab:=PosCabArray(aItens,"COD_MEDIDA")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_UM")
						nPosCmpCab:=PosCabArray(aItens,"QTD_FABR")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SG1->G1_QUANT")
						nPosCmpCab:=PosCabArray(aItens,"COD_ALMOX")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_LOCPAD")
						nPosCmpCab:=PosCabArray(aItens,"COD_CONTA")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_CONTA")
						nPosCmpCab:=PosCabArray(aItens,"COD_CUSTO")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_CC")
						nPosCmpCab:=PosCabArray(aItens,"DESCRICAO_COMPL")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_DESC")
						nPosCmpCab:=PosCabArray(aItens,"PERC_PERDA")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SG1->G1_PERDA")
					Endif	
				Endif
				(cAliasTrb)->(dbSkip())
			Enddo
		Else
			APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
		Endif
		(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX17()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Arquivo de Insumos Utilizados na Fabricação de Produtos     
=======================================================================================
*/

Static Function fSAFX17()
	Local nCnt := 1	
	lFirst := .T.
	// abre tabela de produtos referente ao componente com outro alias
	ChkFile("SB1",,"SB1COMP")
	
	For nCnt:=1 To Len(aSG1)
		If !lContinua
			Exit
		Endif	
		cQ := CRLF + " SELECT SB1.R_E_C_N_O_ SB1_RECNO, SG1.R_E_C_N_O_ SG1_RECNO "
		cQ += CRLF + " FROM " + RetSqlName("SB1") + " SB1 "
		
		cQ += CRLF + " 	INNER JOIN " + RetSqlName("SG1") + " SG1 "
		cQ += CRLF + " 		ON  SG1.D_E_L_E_T_ = ' ' "
		cQ += CRLF + " 		AND SUBSTR(SG1.G1_FILIAL,1,6) = SUBSTR(SB1.B1_FILIAL,1,6) "
		cQ += CRLF + " 		AND SG1.G1_COD = SB1.B1_COD "
		
		cQ += CRLF + " 	WHERE   SB1.D_E_L_E_T_ = ' ' "
		cQ += CRLF + " 		AND SUBSTR(SB1.B1_FILIAL,1,6) BETWEEN '" + Subs(cFilDe,1,6) + "' AND '" + Subs(cFilAte,1,6) + "' "
		cQ += CRLF + " 		AND SB1.B1_COD BETWEEN '" + cProdDe + "' AND '" + cProdAte + "' "
		//cQ +CRLF + = 		 "AND B1_TIPO <> 'PA' "
		cQ += CRLF + " 		AND SB1.B1_MSBLQL <> '1' "
		cQ += CRLF + " 		AND SG1.G1_COD = '" + aSG1[nCnt] + "' "
		cQ += CRLF + " ORDER BY SG1.G1_FILIAL, SG1.G1_COD, SG1.G1_COMP "
		
		If lDebug
			MemoWrite(cLocDest+cTab+".txt",cQ)
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
		
		If lFirst
			// monta array com campos do arquivo
			MontaCab(Alltrim(cTab),@aCab)
			lFirst := .F.
		Endif	
	
		If !Empty(aCab)
			While (cAliasTrb)->(!Eof())
				SB1->(dbGoto((cAliasTrb)->SB1_RECNO))
				If SB1->(Recno()) == (cAliasTrb)->SB1_RECNO
					lContinua := .T.
					
					// posiciona tabelas auxiliares
					SG1->(dbGoto((cAliasTrb)->SG1_RECNO))
					
					SB1COMP->(dbSetOrder(1))
					If SB1COMP->(!dbSeek(SB1->B1_FILIAL+SG1->G1_COMP))
						lContinua := .F.
						cErro := cTab+": Não encontrado componente: SG1, PRODUTO: "+SG1->G1_COD+", COMPONENTE: "+SG1->G1_COMP+"."
						MS06GrvLog(cErro)
					Endif	
					
					If lContinua	
						MontaItens(aCab,@aItens,SB1->B1_FILIAL)
									
						// comeca gravar campos do layout
						nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
						aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SG1->G1_FILIAL)
						nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
						aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SG1->G1_FILIAL)
						nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
						aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
						nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_COD")
						nPosCmpCab:=PosCabArray(aItens,"DATA_MOVTO")
						aItens[Len(aItens)][nPosCmpCab][2] := dTos(dDataBase)
						nPosCmpCab:=PosCabArray(aItens,"IND_INSUMO")
						aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1COMP")
						nPosCmpCab:=PosCabArray(aItens,"COD_INSUMO")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SG1->G1_COMP")
						nPosCmpCab:=PosCabArray(aItens,"COD_MEDIDA")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1COMP->B1_UM")
						nPosCmpCab:=PosCabArray(aItens,"QTD_USADA")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SG1->G1_QUANT")
						nPosCmpCab:=PosCabArray(aItens,"DESCRICAO_COMPL")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1COMP->B1_DESC")
						nPosCmpCab:=PosCabArray(aItens,"PERC_PERDA")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SG1->G1_PERDA")
						nPosCmpCab:=PosCabArray(aItens,"DAT_FIM")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SG1->G1_FIM")
						nPosCmpCab:=PosCabArray(aItens,"QTD_MAX_UTILIZADA")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SG1->G1_QUANT")
					Endif	
				Endif
				(cAliasTrb)->(dbSkip())
			Enddo
		Else
			APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
			lContinua := .F.
		Endif
		(cAliasTrb)->(dbCloseArea())
	Next
	SB1COMP->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX18()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Arquivo Referente a Embalagem                               
=======================================================================================
*/

Static Function fSAFX18()
	Local nCnt := 0
	lFirst := .T.
	// abre tabela de produtos referente ao componente com outro alias
	ChkFile("SB1",,"SB1COMP")
	
	For nCnt:=1 To Len(aSG1)
		If !lContinua
			Exit
		Endif	
		cQ := CRLF + " SELECT SB1.R_E_C_N_O_ SB1_RECNO, SG1.R_E_C_N_O_ SG1_RECNO "
		cQ += CRLF + " 	FROM " + RetSqlName("SB1") + " SB1 "
		
		cQ += CRLF + " 		INNER JOIN " + RetSqlName("SG1") + " SG1 "
		cQ += CRLF + " 			ON  SG1.D_E_L_E_T_ = ' ' "
		cQ += CRLF + " 			AND SUBSTR(SG1.G1_FILIAL,1,6) = SUBSTR(SB1.B1_FILIAL,1,6) "
		cQ += CRLF + " 			AND SG1.G1_COD = SB1.B1_COD "

		cQ += CRLF + " 	WHERE   SB1.D_E_L_E_T_ = ' ' "
		cQ += CRLF + " 		AND SUBSTR(SB1.B1_FILIAL,1,6) BETWEEN '" + Subs(cFilDe,1,6) + "' AND '" + Subs(cFilAte,1,6) + "' "
		cQ += CRLF + " 		AND SB1.B1_COD BETWEEN '" + cProdDe + "' AND '" + cProdAte + "' "
		cQ += CRLF + " 		AND SB1.B1_MSBLQL <> '1' "
		cQ += CRLF + "		AND SG1.G1_COD     = '" + aSG1[nCnt] + "' "
		cQ += CRLF + " ORDER BY SG1.G1_FILIAL, SG1.G1_COD, SG1.G1_COMP "
		//cQ +CRLF + = "AND B1_TIPO = 'EM' "
	
		If lDebug
			MemoWrite(cLocDest+cTab+".txt",cQ)
		EndIf

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
		
		If lFirst
			// monta array com campos do arquivo
			MontaCab(Alltrim(cTab),@aCab)
			lFirst := .F.
		Endif	
	
		If !Empty(aCab)
			While (cAliasTrb)->(!Eof())
				SB1->(dbGoto((cAliasTrb)->SB1_RECNO))
				If SB1->(Recno()) == (cAliasTrb)->SB1_RECNO
					lContinua := .T.
					
					// posiciona tabelas auxiliares
					SG1->(dbGoto((cAliasTrb)->SG1_RECNO))
					
					SB1COMP->(dbSetOrder(1))
					If SB1COMP->(!dbSeek(SB1->B1_FILIAL+SG1->G1_COMP))
						lContinua := .F.
						cErro := cTab+": Não encontrado componente: SG1, PRODUTO: "+SG1->G1_COD+", COMPONENTE: "+SG1->G1_COMP+"."
						MS06GrvLog(cErro)
					Else
						If SB1COMP->B1_TIPO != 'EM'
							(cAliasTrb)->(dbSkip())
							Loop
						Endif
					Endif	
					
					If lContinua	
						MontaItens(aCab,@aItens,SB1->B1_FILIAL)
									
						// comeca gravar campos do layout
						nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
						aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SG1->G1_FILIAL)
						nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
						aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SG1->G1_FILIAL)
						nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
						aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
						nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_COD")
						nPosCmpCab:=PosCabArray(aItens,"DATA_MOVTO")
						aItens[Len(aItens)][nPosCmpCab][2] := dTos(dDataBase)
						nPosCmpCab:=PosCabArray(aItens,"IND_EMBALAGEM")
						aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1COMP")
						nPosCmpCab:=PosCabArray(aItens,"EMBALAGEM")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SG1->G1_COMP")
						nPosCmpCab:=PosCabArray(aItens,"COD_MEDIDA")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1COMP->B1_UM")
						nPosCmpCab:=PosCabArray(aItens,"QTD_USADA")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SG1->G1_QUANT")
						nPosCmpCab:=PosCabArray(aItens,"DESCRICAO_COMPL")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1COMP->B1_DESC")
						nPosCmpCab:=PosCabArray(aItens,"PERC_PERDA")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SG1->G1_PERDA")
						nPosCmpCab:=PosCabArray(aItens,"DAT_FIM")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SG1->G1_FIM")
						nPosCmpCab:=PosCabArray(aItens,"QTD_MAX_UTILIZADA")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SG1->G1_QUANT")
					Endif	
				Endif
				(cAliasTrb)->(dbSkip())
			Enddo
		Else
			APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
			lContinua := .F.
		Endif
		(cAliasTrb)->(dbCloseArea())	
	Next
	SB1COMP->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX49()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Tabela das Operações de Importação                          
=======================================================================================
*/

Static Function fSAFX49()
	QrySAFX49()
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)
	DBSELECTARE('CD5')
	
	If !Empty(aCab)
	
		While (cAliasTrb)->(!Eof())
			
				lSA1 := .F.
				lSA2 := .F.
				lCD5 := .F.
				lSW6 := .F.
				lContinua := .T.

				If !Empty((cAliasTrb)->CD5_RECNO)
					lCD5 := .T.
				Endif	
				
				If !Empty((cAliasTrb)->W6_RECNO)
					lSW6 := .T.
				Endif	
				
				SB1->(dbSetOrder(1))
				If SB1->(!dbSeek(Padr(Subs((cAliasTrb)->D1_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+(cAliasTrb)->D1_COD))
					lContinua := .F.
					cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs((cAliasTrb)->D1_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+"/"+(cAliasTrb)->D1_COD+", serie/documento: "+(cAliasTrb)->F1_SERIE+"/"+(cAliasTrb)->F1_DOC+"." 
					MS06GrvLog(cErro)
				Endif	
			
				lContinua := PosCliForSF3((cAliasTrb)->D1_CF,(cAliasTrb)->D1_TIPO,(cAliasTrb)->F1_FORNECE,(cAliasTrb)->F1_LOJA,@lSA1,@lSA2,.T.,,.F.)
				
				If lContinua	
					cDescDi := ""
					
					MontaItens(aCab,@aItens,(cAliasTrb)->D1_FILIAL)
					
					If (cAliasTrb)->D1_FILIAL <> cFilAux
						fPosCampo(aItens)
						cFilAux := (cAliasTrb)->D1_FILIAL 
					EndIF
			
					IF !EMPTY((cAliasTrb)->F1_HAWB)
						cDI     := fCmpZerado( cAliasTrb + "->W6_DI_NUM")
						dDtDi   := iif(Empty((cAliasTrb)->W6_DTREG_D) , "@" , (cAliasTrb)->W6_DTREG_D )
						cDescDi := fCmpZerado( cAliasTrb + "->W6_DESCONT")
					ELSEIF !EMPTY((cAliasTrb)->CD5_NDI)
						cDI   := fCmpZerado( cAliasTrb + "->CD5_NDI")
						dDtDi := iif(empty((cAliasTrb)->CD5_DTDI ),"@",(cAliasTrb)->CD5_DTDI)
						cDescDi := fCmpZerado( cAliasTrb + "->CD5_VDESDI")
					ELSE
						cDI     := "@"
						dDtDi   := "@"
						nDescDi := "@"
					ENDIF
					// comeca gravar campos do layout
					nPosCmpCab := _COD_EMPRESA
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",(cAliasTrb)->D1_FILIAL)
					nPosCmpCab := _COD_ESTAB
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",(cAliasTrb)->D1_FILIAL)
					nPosCmpCab := _DAT_DI
					aItens[Len(aItens)][nPosCmpCab][2] := dDtDi	
					nPosCmpCab := _NUM_DI
					aItens[Len(aItens)][nPosCmpCab][2] := cDI 
					nPosCmpCab := _DAT_NF
					aItens[Len(aItens)][nPosCmpCab][2] := (cAliasTrb)->F1_EMISSAO
					nPosCmpCab := _IND_FIS_JUR
					aItens[Len(aItens)][nPosCmpCab][2] := IDENT_FIS_JUR((cAliasTrb)->D1_CF,(cAliasTrb)->D1_TIPO)
					nPosCmpCab := _COD_FIS_JUR
					aItens[Len(aItens)][nPosCmpCab][2] := CmpSZeroEsq(IIf(lSA1,fCmpZerado("SA1->A1_XCDSAP"),fCmpZerado("SA2->A2_XCDSAP"))) //COD_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA)
					nPosCmpCab := _NUM_NF
					aItens[Len(aItens)][nPosCmpCab][2] := (cAliasTrb)->F1_DOC
					nPosCmpCab := _SERIE_NF
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado( cAliasTrb + "->F1_SERIE")
					nPosCmpCab := _IND_PRODUTO
					aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
					nPosCmpCab := _COD_PRODUTO
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->D1_COD")
					nPosCmpCab := _NUM_ITEM
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->D1_ITEM")
					nPosCmpCab := _DAT_ENTRADA
					aItens[Len(aItens)][nPosCmpCab][2] := (cAliasTrb)->F1_DTDIGIT
					nPosCmpCab := _COD_NBM
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_POSIPI")
					nPosCmpCab := _COD_MODELO
					aItens[Len(aItens)][nPosCmpCab][2] := COD_MODELO(Alltrim((cAliasTrb)->F3_ESPECIE))
					nPosCmpCab := _COD_MEDIDA
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->D1_UM")
					nPosCmpCab := _COD_CMEDIDA
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->D1_UM")
					nPosCmpCab := _QTD_UND_MED
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->D1_QUANT")
					nPosCmpCab := _QTD_UND_COM
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->D1_QUANT")
					nPosCmpCab := _VLR_PRODUTO
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_TOTAL")
					nPosCmpCab := _VLR_FRETE
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_FRETE")
					nPosCmpCab := _VLR_SEGURO
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_SEGURO")
					nPosCmpCab := _VLR_FRETE
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_FRETE")
					nPosCmpCab := _VLR_DESP_ADUAN
					If !Empty((cAliasTrb)->F1_HAWB)
						aValImp	:= VLR_IMP((cAliasTrb)->F1_HAWB,(cAliasTrb)->F1_DOC,(cAliasTrb)->F1_SERIE,(cAliasTrb)->D1_ITEM,(cAliasTrb)->D1_COD)
					Else
						aValImp	:= {"@","@","@"}
					EndIf
					
					aItens[Len(aItens)][nPosCmpCab][2] := aValImp[1] 
					nPosCmpCab := _VLR_DEDUCAO
					aItens[Len(aItens)][nPosCmpCab][2] := cDescDi
					nPosCmpCab := _VLR_NF
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_VALCONT")
					nPosCmpCab := _BASE_IPI
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_BASEIPI")
					nPosCmpCab := _IPI_ALIQ_VLR
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_ALIQIPI")
					nPosCmpCab := _VLR_IPI
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_VALIPI")
					nPosCmpCab := _VLR_IPISENTA
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_ISENIPI")
					nPosCmpCab := _VLR_IPOUTRAS
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_OUTRIPI")
					nPosCmpCab := _BASE_ICMS
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_BASEICM")
					nPosCmpCab := _ICMS_ALIQ_VLR
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_ALIQICM")
					nPosCmpCab := _VLR_ICMS
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_VALICM")
					nPosCmpCab := _VLR_ICISENTA
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_ISENICM")
					nPosCmpCab := _VLR_ICOUTRAS
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_OUTRICM")
					nPosCmpCab := _BASE_II
					aItens[Len(aItens)][nPosCmpCab][2] := aValImp[2]
					nPosCmpCab := _VLR_II
					aItens[Len(aItens)][nPosCmpCab][2] := aValImp[3]
					nPosCmpCab := _VLR_PIS
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_VALPIS")
					nPosCmpCab := _VLR_COFINS
					aItens[Len(aItens)][nPosCmpCab][2] := fCmpZerado(cAliasTrb + "->FT_VALCOF")
					nPosCmpCab := _TIPO_DI

					IF (cAliasTrb)->W6_MODAL_D == "1"
						lSW6 := .T.
					ENDIF

					aItens[Len(aItens)][nPosCmpCab][2] := IIf(lSW6,"0","1")

					if len(aItens) >= _nLimite  //a cada 1000 linhas é gravado no arquivo para liberar a memória
						SalvaTXT(aCab,aItens)
						aItens := {}
						IF LDebug
							(cAliasTrb)->(dbCloseArea())
							RETURN
						ENDIF
					ENDIF
				Endif	
			
			(cAliasTrb)->(dbSkip())
		Enddo
				
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX52()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Arquivo de Inventário de Estoque por Produto                
=======================================================================================
*/

Static Function fSAFX52()

	cQ := CRLF + " SELECT SB9.R_E_C_N_O_ SB9_RECNO, SB1.R_E_C_N_O_ SB1_RECNO "
	cQ += CRLF + " FROM " + RetSqlName("SB9") + " SB9 "
	
	cQ += CRLF + " 	INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQ += CRLF + " 		ON  SB1.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SUBSTR(SB1.B1_FILIAL,1,6) = SUBSTR(SB9.B9_FILIAL,1,6) "
	cQ += CRLF + " 		AND SB1.B1_COD   = SB9.B9_COD "
	cQ += CRLF + " 		AND SB1.B1_TIPO <> 'SV' "
	
	cQ += CRLF + " 	WHERE   SB9.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SB9.B9_FILIAL BETWEEN '" + cFilDe         + "' AND '" + cFilAte        + "' "
	cQ += CRLF + " 		AND SB9.B9_DATA   BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' "
	cQ += CRLF + " 		AND SB9.B9_QINI > 0 "
	cQ += CRLF + " 	ORDER BY SB9.B9_FILIAL,SB9.B9_COD "

	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			SB9->(dbGoto((cAliasTrb)->SB9_RECNO))
			If SB9->(Recno()) == (cAliasTrb)->SB9_RECNO
				lContinua := .T.
				// posiciona tabelas auxiliares
				SB1->(dbGoto((cAliasTrb)->SB1_RECNO))
				//INC0020855 - SAFX52 se estiver zerado quantidade e ou valor não enviar
				//Quando a qtde não estiver zerado deve gerar no arquivo para posterior conferencia conforme Luanna 02/03/2021 DAC
				//If SB9->B9_VINI1 == 0 .or. SB9->B9_QINI == 0
				//	lContinua := .F.
				//EndIf
				If lContinua	
					MontaItens(aCab,@aItens,SB9->B9_FILIAL)
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"DATA_INVENTARIO")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(SB9->B9_DATA)
					nPosCmpCab:=PosCabArray(aItens,"GRUPO_CONTAGEM")
					aItens[Len(aItens)][nPosCmpCab][2] := "1"
					nPosCmpCab:=PosCabArray(aItens,"COD_NBM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_POSIPI")
					nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
					nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_COD")
					nPosCmpCab:=PosCabArray(aItens,"COD_UND_PADRAO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_UM")
					nPosCmpCab:=PosCabArray(aItens,"COD_ALMOX")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB9->B9_LOCAL")
					nPosCmpCab:=PosCabArray(aItens,"COD_NAT_ESTOQUE")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_TIPO") //COD_NAT_ESTOQUE("SB1")
					nPosCmpCab:=PosCabArray(aItens,"COD_MEDIDA")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_UM")
					nPosCmpCab:=PosCabArray(aItens,"QUANTIDADE")
					//INC0020855 - SAFX52
					//aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB9->B9_QINI")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCal2Zerado,SB9->B9_QINI)
					nPosCmpCab:=PosCabArray(aItens,"VLR_TOT")
					//INC0020855 - SAFX52
					//aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB9->B9_VINI1")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCal2Zerado,SB9->B9_VINI1)
					nPosCmpCab:=PosCabArray(aItens,"VLR_UNIT")
					//INC0020855 - SAFX52
					//aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCalZerado,IIf(!Empty(SB9->B9_VINI1),SB9->B9_VINI1/SB9->B9_QINI,0))
					aItens[Len(aItens)][nPosCmpCab][2] := Eval( bCal3Zerado,SB9->B9_VINI1/SB9->B9_QINI )
					//INC0020855 - SAFX52
					nPosCmpCab:=PosCabArray(aItens,"COD_CONTA")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_CONTA")
					//INC0020855 - SAFX52
					nPosCmpCab:=PosCabArray(aItens,"IND_DEB_CRE")
					aItens[Len(aItens)][nPosCmpCab][2] := "D"
					//INC0020855 - SAFX52
					nPosCmpCab:=PosCabArray(aItens,"COD_SITUACAO_A")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_ORIGEM")
					//INC0020855 - SAFX52
					nPosCmpCab:=PosCabArray(aItens,"IND_MOT_INV")
					aItens[Len(aItens)][nPosCmpCab][2] := "01"
					//INC0020855 - SAFX52
					nPosCmpCab:=PosCabArray(aItens,"VLR_IR")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCal2Zerado,SB9->B9_VINI1)
				Endif	
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX53()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Arquivo de Controle de Tributos                             
=======================================================================================
*/

Static Function fSAFX53()

	cQ := CRLF + " SELECT SE2.R_E_C_N_O_ SE2_RECNO "
	cQ += CRLF + " FROM "+RetSqlName("SE2")+" SE2 "
	cQ += CRLF + " WHERE SE2.D_E_L_E_T_ = ' ' "
	cQ += CRLF + "	 AND SE2.E2_FILIAL  BETWEEN '" + cFilDe         + "' AND '" + cFilAte        + "' "
	cQ += CRLF + "	 AND SE2.E2_EMIS1   BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' "
	cQ += CRLF + "	 AND SE2.E2_FORNECE BETWEEN '" + cCliForDe      + "' AND '" + cCliForAte     + "' "

	If Empty( __cSelNfs )
		cQ += CRLF + "	 AND SE2.E2_NUM BETWEEN '"+cDocFisDe+"' AND '"+cDocFisAte+"' "
	Else
		cQ += CRLF + "	 AND SE2.E2_NUM IN " + FormatIn(__cSelNfs, ";")
	EndIf

	cQ += CRLF + "	 AND SE2.E2_CODRET  = '17' "
	cQ += CRLF + "	 AND SE2.E2_TIPO    = 'TX' "
	cQ += CRLF + "	 AND SE2.E2_TITPAI <> ' ' "
	cQ += CRLF + "ORDER BY E2_FILIAL,E2_EMIS1,E2_NUM "

	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			SE2->(dbGoto((cAliasTrb)->SE2_RECNO))
			If SE2->(Recno()) == (cAliasTrb)->SE2_RECNO
				//SF3->(dbGoto((cAliasTrb)->SF3_RECNO))
				//If SF3->(Recno()) == (cAliasTrb)->SF3_RECNO

					lContinua := .T.
					
					// posiciona tabelas auxiliares
					SA2->(dbSetOrder(1))
					//If SA2->(!dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
					If SA2->(!dbSeek(xFilial("SA2")+GetAdvFVal("SE2","E2_FORNECE",xFilial("SE2")+SE2->E2_TITPAI,1,"")+GetAdvFVal("SE2","E2_LOJA",xFilial("SE2")+SE2->E2_TITPAI,1,"")))
						lContinua := .F.
						cErro := cTab+": Não encontrado tabela: SA2, filial/fornecedor: "+xFilial("SA2")+"/"+GetAdvFVal("SE2","E2_FORNECE",xFilial("SE2")+SE2->E2_TITPAI,1,"")+GetAdvFVal("SE2","E2_LOJA",xFilial("SE2")+SE2->E2_TITPAI,1,"")+", prefixo/titulo "+SE2->E2_PREFIXO+"/"+SE2->E2_NUM+"." 
						MS06GrvLog(cErro)
					Endif	

					SED->(dbSetOrder(1))
					If SED->(!dbSeek(xFilial("SED")+SE2->E2_NATUREZ))
						lContinua := .F.
						cErro := cTab+": Não encontrado tabela: SED, Natureza: "+SE2->E2_NATUREZ+", prefixo/titulo "+SE2->E2_PREFIXO+"/"+SE2->E2_NUM+"." 
						MS06GrvLog(cErro)
					Endif	

					If lContinua	
						MontaItens(aCab,@aItens,SE2->E2_FILIAL)
									
						// comeca gravar campos do layout
						nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
						aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SE2->E2_FILIAL)
						nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
						aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SE2->E2_FILIAL)
						nPosCmpCab:=PosCabArray(aItens,"DATA_MOVTO")
						aItens[Len(aItens)][nPosCmpCab][2] := dTos(SE2->E2_EMIS1) //dTos(SF3->F3_ENTRADA)
						nPosCmpCab:=PosCabArray(aItens,"IND_FIS_JUR")
						aItens[Len(aItens)][nPosCmpCab][2] := "1"
						nPosCmpCab:=PosCabArray(aItens,"COD_FIS_JUR")
						aItens[Len(aItens)][nPosCmpCab][2] := CmpSZeroEsq(Eval(bCmpZerado,"SA2->A2_XCDSAP"))
						nPosCmpCab:=PosCabArray(aItens,"COD_DOCTO")
						aItens[Len(aItens)][nPosCmpCab][2] := IIf(Alltrim(Posicione("SF1",1,SE2->E2_FILIAL+Subs(SE2->E2_TITPAI,4,9)+Subs(SE2->E2_PREFIXO,1,3)+Subs(SE2->E2_FORNECE,18,6)+Subs(SE2->E2_LOJA,24,2),"F1_ESPECIE"))=="SPED","NFE",IIf(Alltrim(Posicione("SF1",1,SE2->E2_FILIAL+Subs(SE2->E2_TITPAI,4,9)+Subs(SE2->E2_PREFIXO,1,3)+Subs(SE2->E2_FORNECE,18,6)+Subs(SE2->E2_LOJA,24,2),"F1_ESPECIE"))=="RPS","NFS",Posicione("SF1",1,SE2->E2_FILIAL+Subs(SE2->E2_TITPAI,4,9)+Subs(SE2->E2_PREFIXO,1,3)+Subs(SE2->E2_FORNECE,18,6)+Subs(SE2->E2_LOJA,24,2),"F1_ESPECIE"))) // Posicione("SF1",1,SE2->E2_FILIAL+Subs(SE2->E2_TITPAI,4,9)+Subs(SE2->E2_PREFIXO,1,3)+Subs(SE2->E2_FORNECE,18,6)+Subs(SE2->E2_LOJA,24,2),"F1_ESPECIE")   
						nPosCmpCab:=PosCabArray(aItens,"NUM_DOCFIS")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SE2->E2_NUM")
						nPosCmpCab:=PosCabArray(aItens,"SERIE_DOCFIS")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SE2->E2_PREFIXO")
						nPosCmpCab:=PosCabArray(aItens,"COD_OPERACAO")
						aItens[Len(aItens)][nPosCmpCab][2] := "4" // pagamentos ???
						nPosCmpCab:=PosCabArray(aItens,"COD_DARF")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SE2->E2_CODRET")
						nPosCmpCab:=PosCabArray(aItens,"ANO_COMPETENCIA")
						aItens[Len(aItens)][nPosCmpCab][2] := Subs(dTos(SE2->E2_EMIS1),1,4) //Subs(dTos(SF3->F3_ENTRADA),1,4)
						nPosCmpCab:=PosCabArray(aItens,"MES_COMPETENCIA")
						aItens[Len(aItens)][nPosCmpCab][2] := Subs(dTos(SE2->E2_EMIS1),5,2) //Subs(dTos(SF3->F3_ENTRADA),5,2)
						nPosCmpCab:=PosCabArray(aItens,"VLR_BRUTO")
						aItens[Len(aItens)][nPosCmpCab][2] := GetAdvFVal("SE2","E2_VALOR",xFilial("SE2")+SE2->E2_TITPAI,1,0)*(10**TamSZR(cTab)[2])
						nPosCmpCab:=PosCabArray(aItens,"VLR_IR_RETIDO")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SE2->E2_VALOR")
						nPosCmpCab:=PosCabArray(aItens,"ALIQUOTA")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SED->ED_PERCIRF")
						nPosCmpCab:=PosCabArray(aItens,"COD_CTRL_INT")
						aItens[Len(aItens)][nPosCmpCab][2] := IIf(Empty(SE2->E2_TITPAI),"@",CmpSZeroEsq(GetAdvFVal("SE2","E2_XCODSAP",xFilial("SE2")+SE2->E2_TITPAI,1,"@")))
						nPosCmpCab:=PosCabArray(aItens,"COD_TRIBUTO")
						aItens[Len(aItens)][nPosCmpCab][2] := CodRetTrib(Alltrim(SE2->E2_CODRET),"1") //Subs(GetAdvFVal("SX5","X5_DESCRI",xFilial("SX5")+"37"+SE2->E2_CODRET,1,"@"),1,TamSZR(cTab)[1])
						nPosCmpCab:=PosCabArray(aItens,"ESP_TRIBUTO")
						aItens[Len(aItens)][nPosCmpCab][2] := CodRetTrib(Alltrim(SE2->E2_CODRET),"2")
						nPosCmpCab:=PosCabArray(aItens,"COD_RECEITA")
						aItens[Len(aItens)][nPosCmpCab][2] := MV_CodRet(SE2->E2_CODRET) //Eval(bCmpZerado,"SE2->E2_CODRET")
						nPosCmpCab:=PosCabArray(aItens,"DATA_INI_COMPET")
						aItens[Len(aItens)][nPosCmpCab][2] := dTos(FirstDay(SE2->E2_EMIS1)) //dTos(FirstDay(SF3->F3_ENTRADA))
						nPosCmpCab:=PosCabArray(aItens,"DATA_FIM_COMPET")
						aItens[Len(aItens)][nPosCmpCab][2] := dTos(LastDay(SE2->E2_EMIS1)) //dTos(LastDay(SF3->F3_ENTRADA))
						nPosCmpCab:=PosCabArray(aItens,"DATA_FATO_GERADOR")
						aItens[Len(aItens)][nPosCmpCab][2] := dTos(SE2->E2_EMIS1) //dTos(SF3->F3_ENTRADA)
						nPosCmpCab:=PosCabArray(aItens,"DATA_VENCTO")
						aItens[Len(aItens)][nPosCmpCab][2] := dTos(SE2->E2_VENCTO)
					Endif	
				//Endif
			Endif		
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX108()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Ordem de Produção                                           
=======================================================================================
*/

Static Function fSAFX108()
	
	cQ := CRLF + " SELECT DISTINCT C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO ,D3_CUSTO1,C2_EMISSAO,C2_DATPRI,C2_DATPRF,C2_QUANT,C2_QUJE FROM ( "
	cQ += CRLF + "	SELECT  "
	cQ += CRLF + "		(SELECT nvl(SUM(SD3C.D3_CUSTO1),0)*100 D3_CUSTO1  "
	cQ += CRLF + "			FROM  " + RetSqlName( "SD3" ) + " SD3C  "
	cQ += CRLF + "			WHERE   SD3C.D_E_L_E_T_ = ' '  "
	cQ += CRLF + "				AND SD3C.D3_FILIAL  = SC2.C2_FILIAL  "
	cQ += CRLF + "				AND SD3C.D3_OP      = SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN "
	cQ += CRLF + "				AND SD3C.D3_OP      <> ' ' "
	cQ += CRLF + "				AND SD3C.D3_CF      NOT IN  ('PR0','PR1' ) "
	cQ += CRLF + "				AND SD3C.D3_ESTORNO <> 'S' ) as D3_CUSTO1 "
	cQ += CRLF + "		,SC2.*  "
	
	cQ += CRLF + "	FROM " + RetSqlName( "SC2" ) + " SC2
	
	cQ += CRLF + "  	INNER JOIN " + RetSqlName("SD3") + " SD3  "
	cQ += CRLF + "  		ON  SD3.D_E_L_E_T_  = ' '  "
	cQ += CRLF + "  		AND SD3.D3_FILIAL   = SC2.C2_FILIAL  "
	cQ += CRLF + "  		AND TRIM(SD3.D3_OP) = TRIM(SC2.C2_NUM) || TRIM(SC2.C2_ITEM) || TRIM(SC2.C2_SEQUEN) "
	cQ += CRLF + "         	AND SD3.D3_ESTORNO  <> 'S' "
	cQ += CRLF + "         	AND SD3.D3_OP       <> ' '  "
	cQ += CRLF + "  		AND SD3.D3_CF NOT IN  ('PR0','PR1' ) "
	
	cQ += CRLF + "		WHERE   SC2.D_E_L_E_T_ = ' '  "
	cQ += CRLF + "			AND SC2.C2_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
	cQ += CRLF + "			AND SC2.C2_DATPRI >= '" + dTos( dDataIni ) + "' "
	cQ += CRLF + "			AND SC2.C2_DATPRF <= '" + dTos( dDataFim ) + "' "

	cQ += CRLF + ")	ORDER BY C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN "


	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			
			lContinua := .T.
				
			// posiciona tabelas auxiliares
			SB1->(dbSetOrder(1))
			If SB1->(!dbSeek(Padr(Subs( (cAliasTrb)->C2_FILIAL,1,6),TamSX3("B1_FILIAL")[1]) + (cAliasTrb)->C2_PRODUTO))
				lContinua := .F.
				cErro := cTab+": Não encontrado tabela: SB1, filial/produto: " + Padr(Subs( (cAliasTrb)->C2_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+"/" 
				cErro += (cAliasTrb)->C2_PRODUTO + ", OP: "+ (cAliasTrb)->C2_NUM + Alltrim( (cAliasTrb)->C2_ITEM) + Alltrim( (cAliasTrb)->C2_SEQUEN ) + "."
				
				MS06GrvLog(cErro)
			Endif	

			If lContinua	
				MontaItens(aCab,@aItens, (cAliasTrb)->C2_FILIAL)
							
				// comeca gravar campos do layout
				nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
				aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS", (cAliasTrb)->C2_FILIAL)
				nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
				aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS", (cAliasTrb)->C2_FILIAL)
				nPosCmpCab:=PosCabArray(aItens,"PERIODO_REF")
				aItens[Len(aItens)][nPosCmpCab][2] := Substr( (cAliasTrb)->C2_EMISSAO , 5 , 2 ) + Substr( (cAliasTrb)->C2_EMISSAO , 1 , 4 )
				nPosCmpCab:=PosCabArray(aItens,"COD_OP")
				aItens[Len(aItens)][nPosCmpCab][2] := Alltrim( (cAliasTrb)->C2_NUM ) + Alltrim( (cAliasTrb)->C2_ITEM ) + Alltrim( (cAliasTrb)->C2_SEQUEN )
				nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO_OP")
				aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
				nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO_OP")
				aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(cAliasTrb)->C2_PRODUTO")
				nPosCmpCab:=PosCabArray(aItens,"DT_INI_OP")
				aItens[Len(aItens)][nPosCmpCab][2] :=  (cAliasTrb)->C2_DATPRI
				nPosCmpCab:=PosCabArray(aItens,"DT_FIM_OP")
				aItens[Len(aItens)][nPosCmpCab][2] :=  (cAliasTrb)->C2_DATPRF
				nPosCmpCab:=PosCabArray(aItens,"COD_UND_PADRAO")
				aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_UM")
				nPosCmpCab:=PosCabArray(aItens,"QTD_PRODUZIDO")
				aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(cAliasTrb)->C2_QUANT")
				nPosCmpCab:=PosCabArray(aItens,"IND_APUR_CUSTO")
				aItens[Len(aItens)][nPosCmpCab][2] := "N"
				nPosCmpCab:=PosCabArray(aItens,"VLR_TOT_CUSTO")
				aItens[Len(aItens)][nPosCmpCab][2] :=  (cAliasTrb)->D3_CUSTO1 //VlrSD3(SD3->D3_FILIAL,SD3->D3_COD,SD3->D3_OP,"D3_CUSTO1")
				nPosCmpCab:=PosCabArray(aItens,"QTD_TRANSF")
				aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(cAliasTrb)->C2_QUJE")
				nPosCmpCab:=PosCabArray(aItens,"VLR_TRANSF")
				aItens[Len(aItens)][nPosCmpCab][2] :=  (cAliasTrb)->D3_CUSTO1 //VlrSD3(SD3->D3_FILIAL,SD3->D3_COD,SD3->D3_OP,"D3_CUSTO1")
				nPosCmpCab:=PosCabArray(aItens,"IND_TP_ORDEM")
				aItens[Len(aItens)][nPosCmpCab][2] := "1"
				nPosCmpCab:=PosCabArray(aItens,"QTD_ORIGEM")
				aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(cAliasTrb)->C2_QUANT")
			Endif	
			
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX109()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Item da Ordem de Produção                                   
=======================================================================================
*/

Static Function fSAFX109()
	
	cQ := CRLF + " SELECT SD3.R_E_C_N_O_ SD3_RECNO, SC2.R_E_C_N_O_ SC2_RECNO, "
	cQ += CRLF + "     	SD3.D3_FILIAL, "
	cQ += CRLF + "     	SC2.C2_EMISSAO, "
	cQ += CRLF + "     	SC2.C2_NUM, "
	cQ += CRLF + "     	SC2.C2_ITEM, "
	cQ += CRLF + "     	SC2.C2_SEQUEN, "
	cQ += CRLF + "     	SD3.D3_OP, "
	cQ += CRLF + "     	SD3.D3_COD, "
	cQ += CRLF + "     	SD3.D3_EMISSAO, "
	cQ += CRLF + "     	SD3.D3_QUANT, "
	cQ += CRLF + "     	SD3.D3_CUSTO1, "
	cQ += CRLF + "		CAST(SD3.D3_CUSTO1/SD3.D3_QUANT AS DECIMAL( 8,2)) AS CUSTO_UNI,
	cQ += CRLF + " 		SC2.C2_PRODUTO " 
	
	cQ += CRLF + "  FROM " + RetSqlName("SC2") + " SC2  "

	cQ += CRLF + "  	INNER JOIN " + RetSqlName("SD3") + " SD3  "
	cQ += CRLF + "  		ON  SD3.D_E_L_E_T_ = ' '  "
	cQ += CRLF + "  		AND SD3.D3_FILIAL  = SC2.C2_FILIAL  "
	cQ += CRLF + "  		AND TRIM(SD3.D3_OP) = TRIM(SC2.C2_NUM) || TRIM(SC2.C2_ITEM) || TRIM(SC2.C2_SEQUEN) "
	cQ += CRLF + "         	AND SD3.D3_ESTORNO <> 'S' "
	cQ += CRLF + "         	AND SD3.D3_OP      <> ' '  "
	cQ += CRLF + "  		AND SD3.D3_CF NOT IN  ('PR0','PR1' ) "
	
	cQ += CRLF + "  	WHERE SC2.D_E_L_E_T_ = ' '  "
	cQ += CRLF + "  		AND SC2.C2_FILIAL  BETWEEN '" + cFilDe    + "' AND '" + cFilAte  + "' "
	cQ += CRLF + "  		AND SC2.C2_DATPRI  >= '" + dTos(dDataIni) + "'   "
	cQ += CRLF + " 			AND SC2.C2_DATPRF  <= '" + dTos(dDataFim) + "'
	
	cQ += CRLF + "  ORDER BY SC2.C2_FILIAL,SC2.C2_EMISSAO,SC2.C2_NUM ,SD3.D3_COD "
	
	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
		
			lContinua := .T.
			
			SB1->(dbSetOrder(1))
			If SB1->(!dbSeek(Padr(Subs((cAliasTrb)->D3_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+(cAliasTrb)->D3_COD))
				lContinua := .F.
				cErro := cTab + ": Não encontrado tabela: SB1, filial/produto: "
				cErro += Padr( Subs( (cAliasTrb)->D3_FILIAL , 1 , 6 ), TamSX3("B1_FILIAL")[1]) + "/" + (cAliasTrb)->D3_COD+", OP: " + (cAliasTrb)->D3_OP + "." 
				MS06GrvLog(cErro)
			Endif	

			If lContinua	
				MontaItens(aCab,@aItens,(cAliasTrb)->D3_FILIAL)
							
				// comeca gravar campos do layout
				nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
				aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",(cAliasTrb)->D3_FILIAL)
				nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
				aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",(cAliasTrb)->D3_FILIAL)
				nPosCmpCab:=PosCabArray(aItens,"PERIODO_REF")
				aItens[Len(aItens)][nPosCmpCab][2] := Subs( (cAliasTrb)->C2_EMISSAO , 5 , 2 ) + Subs( (cAliasTrb)->C2_EMISSAO , 1 , 4 )
				nPosCmpCab:=PosCabArray(aItens,"COD_OP")
				aItens[Len(aItens)][nPosCmpCab][2] := Alltrim( (cAliasTrb)->C2_NUM ) + Alltrim((cAliasTrb)->C2_ITEM)+Alltrim((cAliasTrb)->C2_SEQUEN)
				nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
				aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
				nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
				aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(cAliasTrb)->D3_COD")
				nPosCmpCab:=PosCabArray(aItens,"DT_SAIDA")
				aItens[Len(aItens)][nPosCmpCab][2] := (cAliasTrb)->D3_EMISSAO
				nPosCmpCab:=PosCabArray(aItens,"COD_UND_PADRAO")
				aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_UM")
				nPosCmpCab:=PosCabArray(aItens,"QTD_PRODUZIDO")
				aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(cAliasTrb)->D3_QUANT")
				nPosCmpCab:=PosCabArray(aItens,"VLR_UNIT")
				aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCalZerado,(cAliasTrb)->CUSTO_UNI )
				nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO_OP")
				aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
				nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO_OP")
				aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(cAliasTrb)->C2_PRODUTO")
				nPosCmpCab:=PosCabArray(aItens,"NUM_ITEM")
				aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(cAliasTrb)->C2_ITEM")
			Endif	
		
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX112()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Observações da Nota Fiscal                                   
=======================================================================================
*/

Static Function fSAFX112()
	
	cQ := CRLF + " SELECT CDT.R_E_C_N_O_ CDT_RECNO,SFT.R_E_C_N_O_ SFT_RECNO "
	cQ += CRLF + " 	FROM " + RetSqlName("CDT") + " CDT "
	cQ += CRLF + " INNER JOIN " + RetSqlName("SFT") + " SFT "
	cQ += CRLF + " 		ON  SFT.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SFT.FT_DTCANC  = ' ' "
	cQ += CRLF + " 		AND SFT.FT_FILIAL  = CDT.CDT_FILIAL "
	cQ += CRLF + " 		AND SFT.FT_NFISCAL = CDT.CDT_DOC "
	cQ += CRLF + " 		AND SFT.FT_SERIE   = CDT.CDT_SERIE "
	cQ += CRLF + " 		AND SFT.FT_CLIEFOR = CDT.CDT_CLIFOR "
	cQ += CRLF + " 		AND SFT.FT_LOJA    = CDT.CDT_LOJA "
	cQ += CRLF + " 		AND SFT.FT_TIPOMOV = CDT.CDT_TPMOV "
	cQ += CRLF + " 		AND SFT.FT_ENTRADA BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' "
	cQ += CRLF + " 		AND SFT.FT_CLIEFOR BETWEEN '" + cCliForDe      + "' AND '" + cCliForAte     + "' "

	If Empty( __cSelNfs )
		cQ += CRLF + " 	AND SFT.FT_NFISCAL BETWEEN '" + cDocFisDe + "' AND '" + cDocFisAte + "' "
	Else
		cQ += CRLF + " 	AND SFT.FT_NFISCAL IN " + FormatIn(__cSelNfs, ";") 
	EndIf

	cQ += CRLF + "	 WHERE  CDT.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND CDT.CDT_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
	cQ += CRLF + " ORDER BY SFT.FT_FILIAL,SFT.FT_ENTRADA,SFT.FT_NFISCAL "
	
	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			CDT->(dbGoto((cAliasTrb)->CDT_RECNO))
			If CDT->(Recno()) == (cAliasTrb)->CDT_RECNO
				lSA1 := .F.
				lSA2 := .F.
				lContinua := .T.
				
				// posiciona tabelas auxiliares
				SFT->(dbGoto((cAliasTrb)->SFT_RECNO))

				CC7->(dbSelectArea(1))
				CC7->(dbSeek(xFilial("CC7")+SFT->FT_TES))
				
				SB1->(dbSetOrder(1))
				If SB1->(!dbSeek(Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+SFT->FT_PRODUTO))
					lContinua := .F.
					cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+"/"+SFT->FT_PRODUTO+", serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"." 
					MS06GrvLog(cErro)
				Endif	

				If lContinua
					lContinua := .F.
					SF3->(dbSetOrder(1))
					If SF3->(dbSeek(SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA))
						While SF3->(!Eof()) .and. SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == ;
						SF3->F3_FILIAL+dTos(SF3->F3_ENTRADA)+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
							If SFT->FT_CFOP == SF3->F3_CFO
								lContinua := .T.
								Exit
							Endif
							SF3->(dbSkip())
						Enddo
					Endif
				Endif				
							
				If lContinua
					lContinua := PosCliForSF3(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA,@lSA1,@lSA2,.T.)
				Else
					If SB1->(Found())
						cErro := cTab+": Não encontrada tabela: SF3, serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"."
						MS06GrvLog(cErro)
					Endif	
				Endif					

				If lContinua	
					// tratamento para nao gerar linhas duplicadas para a mesma nota
					If aScan(a112,;
						{|x| SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == x[1] .and. ;
						IIf((SFT->FT_CFOP < "5" .and. CC7->(Found()) .and. !Empty(CC7->CC7_CODLAN)),"L",IIf(SFT->FT_CFOP >= "5","I","@")) == x[2] }) == 0
						
						aAdd(a112,;
						{SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA,;
						IIf((SFT->FT_CFOP < "5" .and. CC7->(Found()) .and. !Empty(CC7->CC7_CODLAN)),"L",IIf(SFT->FT_CFOP >= "5","I","@"))})

						MontaItens(aCab,@aItens,SF3->F3_FILIAL)
									
						// comeca gravar campos do layout
						nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
						aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SF3->F3_FILIAL)
						nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
						aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SF3->F3_FILIAL)
						nPosCmpCab:=PosCabArray(aItens,"DATA_FISCAL")
						aItens[Len(aItens)][nPosCmpCab][2] := dTos(SF3->F3_ENTRADA)
						nPosCmpCab:=PosCabArray(aItens,"MOVTO_E_S")
						aItens[Len(aItens)][nPosCmpCab][2] := MOVTO_E_S(SF3->F3_CFO,SF3->F3_FORMUL)
						nPosCmpCab:=PosCabArray(aItens,"NORM_DEV")
						aItens[Len(aItens)][nPosCmpCab][2] := NORM_DEV(SF3->F3_TIPO)
						nPosCmpCab:=PosCabArray(aItens,"COD_DOCTO")
						aItens[Len(aItens)][nPosCmpCab][2] := IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="SPED","NFE",IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="RPS","NFS",Eval(bCmpZerado,"SF3->F3_ESPECIE"))) //Eval(bCmpZerado,"SF3->F3_ESPECIE")
						nPosCmpCab:=PosCabArray(aItens,"IND_FIS_JUR")
						aItens[Len(aItens)][nPosCmpCab][2] := IDENT_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO)
						nPosCmpCab:=PosCabArray(aItens,"COD_FIS_JUR")
						aItens[Len(aItens)][nPosCmpCab][2] := CmpSZeroEsq(IIf(lSA1,Eval(bCmpZerado,"SA1->A1_XCDSAP"),Eval(bCmpZerado,"SA2->A2_XCDSAP"))) //COD_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA)
						nPosCmpCab:=PosCabArray(aItens,"NUM_DOCFIS")
						aItens[Len(aItens)][nPosCmpCab][2] := SF3->F3_NFISCAL
						nPosCmpCab:=PosCabArray(aItens,"SERIE_DOCFIS")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_SERIE")
						nPosCmpCab:=PosCabArray(aItens,"COD_OBS_LANCTO_FISCAL")
						// aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CDT->CDT_IFCOMP")
						If CC7->(Found())
							If Alltrim(CC7->CC7_CODLAN) == "GO40000029"
								aItens[Len(aItens)][nPosCmpCab][2] := "ICMIC0"
							ElseIf Alltrim(CC7->CC7_CODLAN) $ "GO40009034|GO40009035"
								aItens[Len(aItens)][nPosCmpCab][2] := "ICMIMP"
							Else
								aItens[Len(aItens)][nPosCmpCab][2] := "@"
							EndIf
						Else
							aItens[Len(aItens)][nPosCmpCab][2] := "@"
						EndIf
						nPosCmpCab:=PosCabArray(aItens,"IND_ICOMPL_LANCTO")
						aItens[Len(aItens)][nPosCmpCab][2] := IIf((SFT->FT_CFOP < "5" .and. CC7->(Found()) .and. !Empty(CC7->CC7_CODLAN)),"L",IIf(SFT->FT_CFOP >= "5","I","@"))
						nPosCmpCab:=PosCabArray(aItens,"DSC_COMPLEMENTAR")
						aItens[Len(aItens)][nPosCmpCab][2] := IIf(Empty(CDT->CDT_IFCOMP),"@",Posicione("CCE",1,xFilial("CCE")+CDT->CDT_IFCOMP,"CCE_DESCR"))
					Endif
				Endif	
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())
Return 

/*
=======================================================================================
Programa.:              fSAFX113()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Ajuste/Outros Valores do Lançamento Fiscal                  
=======================================================================================
*/

Static Function fSAFX113()
	Local _nPos := 0	
	cQ := CRLF + "SELECT CDA.R_E_C_N_O_ CDA_RECNO, SFT.R_E_C_N_O_ SFT_RECNO, NVL(SD1.R_E_C_N_O_,0)  SD1_RECNO "
	cQ += CRLF + "	FROM " + RetSqlName("CDA") + " CDA "
	cQ += CRLF + "	INNER JOIN " + RetSqlName("SFT") + " SFT "
	cQ += CRLF + "		ON  SFT.D_E_L_E_T_  = ' ' "
	cQ += CRLF + "		AND SFT.FT_DTCANC   = ' ' "
	cQ += CRLF + "		AND SFT.FT_FILIAL 	= CDA.CDA_FILIAL "
	cQ += CRLF + "		AND SFT.FT_TIPOMOV 	= CDA.CDA_TPMOVI "
	cQ += CRLF + "		AND SFT.FT_SERIE 	= CDA.CDA_SERIE "
	cQ += CRLF + "		AND SFT.FT_NFISCAL 	= CDA.CDA_NUMERO "
	cQ += CRLF + "		AND SFT.FT_CLIEFOR 	= CDA.CDA_CLIFOR "
	cQ += CRLF + "		AND SFT.FT_LOJA 	= CDA.CDA_LOJA "
	cQ += CRLF + "		AND SFT.FT_ITEM  	= CDA.CDA_NUMITE "
	cQ += CRLF + "		AND SFT.FT_ESPECIE 	= CDA.CDA_ESPECI "
	cQ += CRLF + "		AND SFT.FT_ENTRADA BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' "
	
	_aCfOP := StrTokArr(_cCfOP,";")   //INC0020803 - SAFX113 - Trazer dados somente de uma CFOP - (e-mail 19/04/2021)aplicar a extração apenas para operações Interestaduais com CFOP 2556.
	_cCfOP := ""  	
	
	For _nPos := 1 To Len(_aCfOP)
		If !Empty(_aCfOP[_nPos])
			_cCfOP += ("'"+_aCfOP[_nPos]+"'"+",")
		EndIf
	Next
	
	If !Empty(_cCfOP)
		//RETIRAR A ULTIMA CASA QUE É VIRGULA
		_cCfOP := SubsTr(_cCfOP,1,Len(_cCfOP)-1)
		cQ += CRLF + "	AND FT_CFOP IN ("+_cCfOP+") "
	EndIf
	
	//INC0020803 - SAFX113 - tem que ser tratado pelo CDA
	//cQ += "AND FT_CLIEFOR BETWEEN '"+cCliForDe+"' AND '"+cCliForAte+"' "+CRLF
	//cQ += "AND FT_NFISCAL BETWEEN '"+cDocFisDe+"' AND '"+cDocFisAte+"' "+CRLF
	//INC0020803 - SAFX113
	cQ += CRLF + "	LEFT JOIN " + RetSqlName("SD1") + " SD1 "
	cQ += CRLF + "		ON  SD1.D1_FILIAL  = cda.CDA_FILIAL "
	cQ += CRLF + "		AND SD1.D1_DOC 	   = cda.CDA_NUMERO "
	cQ += CRLF + "		AND SD1.D1_SERIE   = cda.CDA_SERIE "
	cQ += CRLF + "		AND SD1.D1_FORNECE = cda.CDA_CLIFOR "
	cQ += CRLF + "		AND SD1.D1_LOJA    = cda.CDA_LOJA "
	cQ += CRLF + "		AND SD1.D1_ITEM    = cda.CDA_NUMITE "
	cQ += CRLF + " WHERE CDA.D_E_L_E_T_ = ' ' "
	cQ += CRLF + "	AND CDA.CDA_TPMOVI 	= 'E' "
	cQ += CRLF + "	AND CDA.CDA_FILIAL BETWEEN '" + cFilDe    + "' AND '" + cFilAte    + "' "
	cQ += CRLF + "	AND CDA.CDA_CLIFOR BETWEEN '" + cCliForDe + "' AND '" + cCliForAte + "' " //INC0020803 - SAFX113 - Acrescentado

	If Empty( __cSelNfs )
		cQ += CRLF + "	AND CDA.CDA_NUMERO BETWEEN '"+cDocFisDe+"' AND '"+cDocFisAte+"' "
	Else
		cQ += CRLF + "	AND CDA_NUMERO IN " + FormatIn(__cSelNfs, ";")
	EndIf

	cQ += CRLF + "ORDER BY CDA_FILIAL ,FT_ENTRADA, CDA_NUMERO, CDA_SERIE, CDA_NUMITE "
		
	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)
	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			CDA->(dbGoto((cAliasTrb)->CDA_RECNO))
			If CDA->(Recno()) == (cAliasTrb)->CDA_RECNO
				lSA1 := .F.
				lSA2 := .F.
				lContinua := .T.
				
				// posiciona tabelas auxiliares
				SFT->(dbGoto((cAliasTrb)->SFT_RECNO))
				//Se e etreada posicionar SD1
				If CDA->CDA_TPMOVI == "E".and. (cAliasTrb)->SD1_RECNO > 0 
					SD1->(dbGoto((cAliasTrb)->SD1_RECNO))
				EndIf	
				CC7->(dbSelectArea(1))
				CC7->(dbSeek(xFilial("CC7")+SFT->FT_TES))
				
				SB1->(dbSetOrder(1))
				If SB1->(!dbSeek(Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+SFT->FT_PRODUTO))
					lContinua := .F.
					cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+"/"+SFT->FT_PRODUTO+", serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"." 
					MS06GrvLog(cErro)
				Endif	

				If lContinua
					lContinua := .F.
					SF3->(dbSetOrder(1))
					If SF3->(dbSeek(SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA))
						While SF3->(!Eof()) .and. SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == ;
						SF3->F3_FILIAL+dTos(SF3->F3_ENTRADA)+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
							If SFT->FT_CFOP == SF3->F3_CFO
								lContinua := .T.
								Exit
							Endif
							SF3->(dbSkip())
						Enddo
					Endif
				Endif				
							
				If lContinua
					lContinua := PosCliForSF3(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA,@lSA1,@lSA2,.T.)
				Else
					If SB1->(Found())
						cErro := cTab+": Não encontrada tabela: SF3, serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"." 
						MS06GrvLog(cErro)
					Endif	
				Endif					

				If lContinua	
					
					MontaItens(aCab,@aItens,SF3->F3_FILIAL)
								
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"DATA_FISCAL")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(SF3->F3_ENTRADA)
					nPosCmpCab:=PosCabArray(aItens,"MOVTO_E_S")
					aItens[Len(aItens)][nPosCmpCab][2] := MOVTO_E_S(SF3->F3_CFO,SF3->F3_FORMUL)
					nPosCmpCab:=PosCabArray(aItens,"NORM_DEV")
					aItens[Len(aItens)][nPosCmpCab][2] := NORM_DEV(SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"COD_DOCTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="SPED","NFE",IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="RPS","NFS",Eval(bCmpZerado,"SF3->F3_ESPECIE"))) //Eval(bCmpZerado,"SF3->F3_ESPECIE")
					nPosCmpCab:=PosCabArray(aItens,"IND_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := IDENT_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"COD_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := CmpSZeroEsq(IIf(lSA1,Eval(bCmpZerado,"SA1->A1_XCDSAP"),Eval(bCmpZerado,"SA2->A2_XCDSAP"))) //COD_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA)
					nPosCmpCab:=PosCabArray(aItens,"NUM_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := SF3->F3_NFISCAL
					nPosCmpCab:=PosCabArray(aItens,"SERIE_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_SERIE")
					nPosCmpCab:=PosCabArray(aItens,"COD_OBS_LANCTO_FISCAL")
					//aItens[Len(aItens)][nPosCmpCab][2] := IIf((CC7->(Found()) .and. Alltrim(CC7->CC7_CODLAN) == "GO40000029"),"ICMIC0","@") //Eval(bCmpZerado,"CDA->CDA_IFCOMP")
					If CC7->(Found())
						If Alltrim(CC7->CC7_CODLAN) == "GO40000029"
							aItens[Len(aItens)][nPosCmpCab][2] := "ICMIC0"
						ElseIf Alltrim(CC7->CC7_CODLAN) $ "GO40009034|GO40009035"
							aItens[Len(aItens)][nPosCmpCab][2] := "ICMIMP"
						Else
							aItens[Len(aItens)][nPosCmpCab][2] := "@"
						EndIf
					Else
						aItens[Len(aItens)][nPosCmpCab][2] := "@"
					EndIf
					nPosCmpCab:=PosCabArray(aItens,"COD_AJUSTE_SPED")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf((CC7->(Found()) .and. !Empty(CC7->CC7_CODLAN)),Eval(bCmpZerado,"CC7->CC7_CODLAN"),"@") //Eval(bCmpZerado,"CDA->CDA_CODLAN")
					nPosCmpCab:=PosCabArray(aItens,"DSC_COMP_AJUSTE")
					aItens[Len(aItens)][nPosCmpCab][2] := GetAdvFVal("CC6","CC6_DESCR",xFilial("CC6")+CC7->CC7_CODLAN,1,"@") //IIf((CC7->(Found()) .and. Alltrim(CC7->CC7_CODLAN) == "GO40000029"),Eval(bCmpZerado,"CC7->CC7_CODLAN"),"@") //IIf(Empty(CDA->CDA_CODLAN),"@",Posicione("CC6",1,xFilial("CC6")+CDA->CDA_CODLAN,"CC6_DESCR"))
					nPosCmpCab:=PosCabArray(aItens,"NUM_ITEM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CDA->CDA_NUMITE")
					nPosCmpCab:=PosCabArray(aItens,"VLR_BASE_ICMS")
					//INC0020803 - SAFX113 - ALTERAR IMPOSTOS DE ENTRADA BASEADO NO SD1
					//aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CDA->CDA_BASE")
					
					If CDA->CDA_TPMOVI == "E" .and. (cAliasTrb)->SD1_RECNO > 0 
						nBaseIcm := Eval(bCmpZerado,iif(SD1->D1_ALIQSOL > 0 ,"SFT->FT_BASEDES","SFT->FT_BASEICM" ))
						if alltrim(nBaseIcm) == "@"
							nBaseIcm := Eval(bCmpZerado,"CDA->CDA_BASE")
						endif
					ELSE
						nBaseIcm := Eval(bCmpZerado,"CDA->CDA_BASE")
					ENDIF

					aItens[Len(aItens)][nPosCmpCab][2] := nBaseIcm //Eval(bCmpZerado,If(CDA->CDA_TPMOVI == "E" .and. (cAliasTrb)->SD1_RECNO > 0 ,/*"SD1->D1_BASEICM"*/ "SD1->D1_BASEDES","CDA->CDA_BASE"))
					
					nPosCmpCab:=PosCabArray(aItens,"ALIQUOTA_ICMS")
					//INC0020803 - SAFX113 - ALTERAR IMPOSTOS DE ENTRADA BASEADO NO SD1
					//aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CDA->CDA_ALIQ")
					//Caso eteja puxando direto não esta apresentando a aliquota de calculo e sim a aliquota correspondente a TES dando divergencia DAC 18/03/2021
					//aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,If(CDA->CDA_TPMOVI == "E" .and. (cAliasTrb)->SD1_RECNO > 0 ,"SD1->D1_ALIQSOL","CDA->CDA_ALIQ"))
					If CDA->CDA_TPMOVI == "E"  
						If (cAliasTrb)->SD1_RECNO <> 0
							
							if (SD1->D1_ALIQSOL - SD1->D1_PICM) > 0 
								_nAliq := SD1->D1_ALIQSOL - SD1->D1_PICM
							Else
								_nAliq := SD1->D1_PICM
							EndIf
														
						Else
							_nAliq := 0
						EndIf	
					Else
						_nAliq := CDA->CDA_ALIQ
					EndIf	
					aItens[Len(aItens)][nPosCmpCab][2] := Eval( bCal2Zerado,_nAliq ) 
					nPosCmpCab:=PosCabArray(aItens,"VLR_ICMS")
					//INC0020803 - SAFX113 - ALTERAR IMPOSTOS DE ENTRADA BASEADO NO SD1
					//aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CDA->CDA_VALOR")
					
					If CDA->CDA_TPMOVI == "E" .and. (cAliasTrb)->SD1_RECNO > 0 
						nVlrIcms := Eval(bCmpZerado,iif(SD1->D1_ALIQSOL > 0 ,"SFT->FT_ICMSCOM" , "SFT->FT_VALICM"))
						
						if alltrim(nVlrIcms) == "@"
							nVlrIcms := Eval(bCmpZerado,"CDA->CDA_VALOR")
						endif
					else
						nVlrIcms := Eval(bCmpZerado,"CDA->CDA_VALOR")
					endif
										
					aItens[Len(aItens)][nPosCmpCab][2] := nVlrIcms //Eval(bCmpZerado,If(CDA->CDA_TPMOVI == "E" .and. (cAliasTrb)->SD1_RECNO > 0 ,/*"SD1->D1_VALICM"*/"SFT->FT_ICMSCOM","CDA->CDA_VALOR"))

					if len(aItens) >= _nLimite  //a cada 1000 linhas é gravado no arquivo para liberar a memória
						SalvaTXT(aCab,aItens)
						aItens := {}
						IF LDebug
							(cAliasTrb)->(dbCloseArea())
							RETURN
						ENDIF
					ENDIF
				Endif	
				//Endif
			EndIf
				
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX114()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Processos Referenciados                                     
=======================================================================================
*/

Static Function fSAFX114()
	cQ := CRLF + " SELECT CDG.R_E_C_N_O_ CDG_RECNO,SFT.R_E_C_N_O_ SFT_RECNO "
	cQ += CRLF + " FROM "+RetSqlName("CDG")+" CDG "
	cQ += CRLF + " INNER JOIN "+RetSqlName("SFT")+" SFT "
	cQ += CRLF + " 		ON  SFT.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SFT.FT_DTCANC  = ' ' "
	cQ += CRLF + " 		AND SFT.FT_FILIAL  = CDG_FILIAL "
	cQ += CRLF + " 		AND SFT.FT_NFISCAL = CDG_DOC "
	cQ += CRLF + " 		AND SFT.FT_SERIE   = CDG_SERIE "
	cQ += CRLF + " 		AND SFT.FT_CLIEFOR = CDG_CLIFOR "
	cQ += CRLF + " 		AND SFT.FT_LOJA    = CDG_LOJA "
	cQ += CRLF + " 		AND SFT.FT_TIPOMOV = CDG_TPMOV "
	cQ += CRLF + " 		AND SFT.FT_ENTRADA BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' "
	cQ += CRLF + " 		AND SFT.FT_CLIEFOR BETWEEN '" + cCliForDe      + "' AND '" + cCliForAte     + "' "

	If Empty( __cSelNfs )
		cQ += CRLF + " 		AND SFT.FT_NFISCAL BETWEEN '"+cDocFisDe+"' AND '"+cDocFisAte+"' "
	Else
		cQ += CRLF + " 		AND SFT.FT_NFISCAL IN " + FormatIn(__cSelNfs, ";") 
	EndIf

	cQ += CRLF + " WHERE CDG.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND CDG_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
	cQ += CRLF + " ORDER BY SFT.FT_FILIAL,SFT.FT_ENTRADA,SFT.FT_NFISCAL "

	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			CDG->(dbGoto((cAliasTrb)->CDG_RECNO))
			If CDG->(Recno()) == (cAliasTrb)->CDG_RECNO
				lSA1 := .F.
				lSA2 := .F.
				lContinua := .T.
				
				// posiciona tabelas auxiliares
				SFT->(dbGoto((cAliasTrb)->SFT_RECNO))
				
				SB1->(dbSetOrder(1))
				If SB1->(!dbSeek(Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+SFT->FT_PRODUTO))
					lContinua := .F.
					cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+"/"+SFT->FT_PRODUTO+", serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"."
					MS06GrvLog(cErro)
				Endif	

				If lContinua
					lContinua := .F.
					SF3->(dbSetOrder(1))
					If SF3->(dbSeek(SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA))
						While SF3->(!Eof()) .and. SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == ;
						SF3->F3_FILIAL+dTos(SF3->F3_ENTRADA)+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
							If SFT->FT_CFOP == SF3->F3_CFO
								lContinua := .T.
								Exit
							Endif
							SF3->(dbSkip())
						Enddo
					Endif
				Endif				
							
				If lContinua
					lContinua := PosCliForSF3(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA,@lSA1,@lSA2,.T.)
				Else
					If SB1->(Found())
						cErro := cTab+": Não encontrada tabela: SF3, serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"." 
						MS06GrvLog(cErro)
					Endif	
				Endif					

				If lContinua	
					If aScan(a114,;
					{|x| SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == x[1] .and. ;
					CDG->CDG_PROCES == x[2] .and. ;
					CDG->CDG_ITPROC == x[3] }) == 0
					aAdd(a114,;
					{SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA,;
					CDG->CDG_PROCES,;
					CDG->CDG_ITPROC})

					MontaItens(aCab,@aItens,SF3->F3_FILIAL)
								
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"DATA_FISCAL")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(SF3->F3_ENTRADA)
					nPosCmpCab:=PosCabArray(aItens,"MOVTO_E_S")
					aItens[Len(aItens)][nPosCmpCab][2] := MOVTO_E_S(SF3->F3_CFO,SF3->F3_FORMUL)
					nPosCmpCab:=PosCabArray(aItens,"NORM_DEV")
					aItens[Len(aItens)][nPosCmpCab][2] := NORM_DEV(SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"COD_DOCTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="SPED","NFE",IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="RPS","NFS",Eval(bCmpZerado,"SF3->F3_ESPECIE"))) //Eval(bCmpZerado,"SF3->F3_ESPECIE")
					nPosCmpCab:=PosCabArray(aItens,"IND_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := IDENT_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"COD_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := CmpSZeroEsq(IIf(lSA1,Eval(bCmpZerado,"SA1->A1_XCDSAP"),Eval(bCmpZerado,"SA2->A2_XCDSAP"))) //COD_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA)
					nPosCmpCab:=PosCabArray(aItens,"NUM_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := SF3->F3_NFISCAL
					nPosCmpCab:=PosCabArray(aItens,"SERIE_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_SERIE")
					nPosCmpCab:=PosCabArray(aItens,"NUM_PROCESSO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CDG->CDG_PROCES")
					nPosCmpCab:=PosCabArray(aItens,"NUM_ITEM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CDG->CDG_ITPROC")
					Endif
				Endif	
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX116()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Documentos Fiscais Referenciados                            
=======================================================================================
*/

Static Function fSAFX116()

	cQ := CRLF + " SELECT CDD.R_E_C_N_O_ CDD_RECNO,SFT.R_E_C_N_O_ SFT_RECNO "
	cQ += CRLF + " FROM " + RetSqlName("CDD") + " CDD "
	cQ += CRLF + " 	INNER JOIN " + RetSqlName("SFT") + " SFT "
	cQ += CRLF + " 		ON  SFT.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SFT.FT_DTCANC  = ' ' "
	cQ += CRLF + " 		AND SFT.FT_FILIAL  = CDD_FILIAL "
	cQ += CRLF + " 		AND SFT.FT_NFISCAL = CDD_DOC "
	cQ += CRLF + " 		AND SFT.FT_SERIE   = CDD_SERIE "
	cQ += CRLF + " 		AND SFT.FT_CLIEFOR = CDD_CLIFOR "
	cQ += CRLF + " 		AND SFT.FT_LOJA    = CDD_LOJA "
	cQ += CRLF + " 		AND SFT.FT_TIPOMOV = CDD_TPMOV "
	cQ += CRLF + " 		AND SFT.FT_NFORI   = CDD_DOCREF "
	cQ += CRLF + " 		AND SFT.FT_SERORI  = CDD_SERREF "
	cQ += CRLF + " 		AND SFT.FT_ENTRADA BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' "
	cQ += CRLF + " 		AND SFT.FT_CLIEFOR BETWEEN '" + cCliForDe      + "' AND '" + cCliForAte     + "' "

	If Empty( __cSelNfs )
		cQ += CRLF + "AND SFT.FT_NFISCAL BETWEEN '" + cDocFisDe + "' AND '" + cDocFisAte + "' "
	Else
		cQ += CRLF + "AND SFT.FT_NFISCAL IN " + FormatIn(__cSelNfs, ";") 
	EndIf

	cQ += CRLF + " WHERE CDD.D_E_L_E_T_ = ' ' "
	cQ += CRLF + "	AND CDD_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
	cQ += CRLF + "ORDER BY SFT.FT_FILIAL,SFT.FT_ENTRADA,SFT.FT_NFISCAL "

	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			CDD->(dbGoto((cAliasTrb)->CDD_RECNO))
			If CDD->(Recno()) == (cAliasTrb)->CDD_RECNO
				lSA1 := .F.
				lSA2 := .F.
				lContinua := .T.
				aGetAreaRef := {}
				
				// posiciona tabelas auxiliares
				SFT->(dbGoto((cAliasTrb)->SFT_RECNO))

				CC7->(dbSelectArea(1))
				CC7->(dbSeek(xFilial("CC7")+SFT->FT_TES))

				SB1->(dbSetOrder(1))
				If SB1->(!dbSeek(Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+SFT->FT_PRODUTO))
					lContinua := .F.
					cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(SFT->FT_FILIAL,1,6),TamSX3("B1_FILIAL")[1])+"/"+SFT->FT_PRODUTO+", serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"." 
					MS06GrvLog(cErro)
				Endif	

				If lContinua
					lContinua := .F.
					SF3->(dbSetOrder(1))
					If SF3->(dbSeek(SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA))
						While SF3->(!Eof()) .and. SFT->FT_FILIAL+dTos(SFT->FT_ENTRADA)+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == ;
						SF3->F3_FILIAL+dTos(SF3->F3_ENTRADA)+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
							If SFT->FT_CFOP == SF3->F3_CFO
								lContinua := .T.
								Exit
							Endif
							SF3->(dbSkip())
						Enddo
					Endif
				Endif				
							
				If lContinua
					lContinua := PosCliForSF3(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA,@lSA1,@lSA2,.T.)
				Else
					If SB1->(Found())
						cErro := cTab+": Não encontrada tabela: SF3, serie/documento: "+SFT->FT_SERIE+"/"+SFT->FT_NFISCAL+"."
						MS06GrvLog(cErro)
					Endif	
				Endif					

				If lContinua
					If aScan(a116,;
					{|x| SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == x[1] .and. ;
					IIf((CC7->(Found()) .and. !Empty(CC7->CC7_IFCOMP)),GetAdvFVal("CCE","CCE_DESCR",xFilial("CCE")+CC7->CC7_IFCOMP,1,"@"),"@") == x[2] .and. ;
					CDD->CDD_DOCREF == x[3] .and. ;
					CDD->CDD_SERREF == x[4] }) == 0
					aAdd(a116,;
					{SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA,;
					IIf((CC7->(Found()) .and. !Empty(CC7->CC7_IFCOMP)),GetAdvFVal("CCE","CCE_DESCR",xFilial("CCE")+CC7->CC7_IFCOMP,1,"@"),"@"),;
					CDD->CDD_DOCREF,;
					CDD->CDD_SERREF})

					aGetAreaRef := {SA1->(GetArea()),SA2->(GetArea()),SF1->(GetArea()),SF2->(GetArea()),SF3->(GetArea())}
					MontaItens(aCab,@aItens,SF3->F3_FILIAL)
								
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"DATA_FISCAL")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(SF3->F3_ENTRADA)
					nPosCmpCab:=PosCabArray(aItens,"MOVTO_E_S")
					aItens[Len(aItens)][nPosCmpCab][2] := MOVTO_E_S(SF3->F3_CFO,SF3->F3_FORMUL)
					nPosCmpCab:=PosCabArray(aItens,"NORM_DEV")
					aItens[Len(aItens)][nPosCmpCab][2] := NORM_DEV(SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"COD_DOCTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="SPED","NFE",IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="RPS","NFS",Eval(bCmpZerado,"SF3->F3_ESPECIE"))) //Eval(bCmpZerado,"SF3->F3_ESPECIE")
					nPosCmpCab:=PosCabArray(aItens,"IND_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := IDENT_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO)
					nPosCmpCab:=PosCabArray(aItens,"COD_FIS_JUR")
					aItens[Len(aItens)][nPosCmpCab][2] := CmpSZeroEsq(IIf(lSA1,Eval(bCmpZerado,"SA1->A1_XCDSAP"),Eval(bCmpZerado,"SA2->A2_XCDSAP"))) //COD_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA)
					nPosCmpCab:=PosCabArray(aItens,"NUM_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := SF3->F3_NFISCAL
					nPosCmpCab:=PosCabArray(aItens,"SERIE_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_SERIE")
					nPosCmpCab:=PosCabArray(aItens,"COD_OBS_LANCTO_FISCAL")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf((CC7->(Found()) .and. !Empty(CC7->CC7_IFCOMP)),GetAdvFVal("CCE","CCE_DESCR",xFilial("CCE")+CC7->CC7_IFCOMP,1,"@"),"@") //Eval(bCmpZerado,"CDD->CDD_IFCOMP")
					nPosCmpCab:=PosCabArray(aItens,"NUM_DOCFIS_REF")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CDD->CDD_DOCREF")
					nPosCmpCab:=PosCabArray(aItens,"SERIE_DOCFIS_REF")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CDD->CDD_SERREF")
					lContinua := PosMovRef(CDD->CDD_CLIFOR,CDD->CDD_LOJA,@lSA1,@lSA2)
					If lContinua
						nPosCmpCab:=PosCabArray(aItens,"MOVTO_E_S_REF")
						aItens[Len(aItens)][nPosCmpCab][2] := MOVTO_E_S(SF3->F3_CFO,SF3->F3_FORMUL)
						nPosCmpCab:=PosCabArray(aItens,"IND_FIS_JUR_REF")
						aItens[Len(aItens)][nPosCmpCab][2] := IDENT_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO)
						nPosCmpCab:=PosCabArray(aItens,"COD_FIS_JUR_REF")
						aItens[Len(aItens)][nPosCmpCab][2] := CmpSZeroEsq(IIf(lSA1,Eval(bCmpZerado,"SA1->A1_XCDSAP"),Eval(bCmpZerado,"SA2->A2_XCDSAP"))) //COD_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA)
						nPosCmpCab:=PosCabArray(aItens,"DATA_FISCAL_REF")
						aItens[Len(aItens)][nPosCmpCab][2] := dTos(SF3->F3_ENTRADA)
						nPosCmpCab:=PosCabArray(aItens,"COD_MODELO_REF")
						aItens[Len(aItens)][nPosCmpCab][2] := COD_MODELO(Alltrim(SF3->F3_ESPECIE)) // AModNot(SF3->F3_ESPECIE)
					Endif
					// retorna para tabelas do documento correto
					aEval(aGetAreaRef,{|x| RestArea(x)})
					nPosCmpCab:=PosCabArray(aItens,"NUM_AUTENTIC_NFE")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_CHVNFE")
					Endif
				Endif	
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX118()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Local de Coleta                                             
=======================================================================================
*/

Static Function fSAFX118()
	
	cQ := CRLF + " SELECT SF3.R_E_C_N_O_ SF3_RECNO "
	cQ += CRLF + " FROM " + RetSqlName("SF3") + " SF3 "
	cQ += CRLF + " WHERE SF3.D_E_L_E_T_ = ' ' "
	cQ += CRLF + "	 AND SF3.F3_DTCANC  = ' ' "
	cQ += CRLF + "	 AND SF3.F3_ENTRADA BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim) + "' "
	cQ += CRLF + "	 AND SF3.F3_CLIEFOR BETWEEN '" + cCliForDe      + "' AND '" + cCliForAte     + "' "
	cQ += CRLF + "	 AND SF3.F3_FILIAL  BETWEEN '" + cFilDe         + "' AND '" + cFilAte        + "' "
	cQ += CRLF + "	 AND SF3.F3_CFO >= '5' "

	If Empty( __cSelNfs )
		cQ += CRLF + "	 AND F3_NFISCAL BETWEEN '"+cDocFisDe+"' AND '"+cDocFisAte+"' "
	Else
		cQ += CRLF + "	 AND F3_NFISCAL IN " + FormatIn(__cSelNfs, ";")
	EndIf
	cQ += CRLF + "ORDER BY F3_FILIAL,F3_ENTRADA,F3_NFISCAL "

	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			SF3->(dbGoto((cAliasTrb)->SF3_RECNO))
			If SF3->(Recno()) == (cAliasTrb)->SF3_RECNO

				SFT->(dbSelectArea(1))
				SFT->(dbSeek(xFilial("SFT")+IIf(SF3->F3_CFO>="5","S","E")+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA))

				CC7->(dbSelectArea(1))
				CC7->(dbSeek(xFilial("CC7")+SFT->FT_TES))

				CDF->(dbSetOrder(1))
				//If CDF->(dbSeek(xFilial("CDF")+"S"+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
					CDF->(dbSeek(xFilial("CDF")+"S"+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
					lSA1 := .F.
					lSA2 := .F.
					lContinua := .T.
					
					If lContinua
						lContinua := PosCliForSF3(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA,@lSA1,@lSA2,.T.)
					Endif		
						
					If lContinua	
						If (!Empty(SF2->F2_CLIENT) .and. !Empty(SF2->F2_LOJENT)) .and. !SF2->F2_CLIENT+SF2->F2_LOJENT == SF2->F2_CLIENTE+SF2->F2_LOJA
							SA1->(dbSetOrder(1))
							SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT))
						Endif

						MontaItens(aCab,@aItens,SF3->F3_FILIAL)
									
						// comeca gravar campos do layout
						nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
						aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SF3->F3_FILIAL)
						nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
						aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SF3->F3_FILIAL)
						nPosCmpCab:=PosCabArray(aItens,"DATA_FISCAL")
						aItens[Len(aItens)][nPosCmpCab][2] := dTos(SF3->F3_ENTRADA)
						nPosCmpCab:=PosCabArray(aItens,"MOVTO_E_S")
						aItens[Len(aItens)][nPosCmpCab][2] := MOVTO_E_S(SF3->F3_CFO,SF3->F3_FORMUL)
						nPosCmpCab:=PosCabArray(aItens,"NORM_DEV")
						aItens[Len(aItens)][nPosCmpCab][2] := NORM_DEV(SF3->F3_TIPO)
						nPosCmpCab:=PosCabArray(aItens,"COD_DOCTO")
						aItens[Len(aItens)][nPosCmpCab][2] := IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="SPED","NFE",IIf(Alltrim(Eval(bCmpZerado,"SF3->F3_ESPECIE"))=="RPS","NFS",Eval(bCmpZerado,"SF3->F3_ESPECIE"))) //Eval(bCmpZerado,"SF3->F3_ESPECIE")
						nPosCmpCab:=PosCabArray(aItens,"IND_FIS_JUR")
						aItens[Len(aItens)][nPosCmpCab][2] := IDENT_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO)
						nPosCmpCab:=PosCabArray(aItens,"COD_FIS_JUR")
						aItens[Len(aItens)][nPosCmpCab][2] := CmpSZeroEsq(IIf(lSA1,Eval(bCmpZerado,"SA1->A1_XCDSAP"),Eval(bCmpZerado,"SA2->A2_XCDSAP"))) //COD_FIS_JUR(SF3->F3_CFO,SF3->F3_TIPO,SF3->F3_CLIEFOR,SF3->F3_LOJA)
						nPosCmpCab:=PosCabArray(aItens,"NUM_DOCFIS")
						aItens[Len(aItens)][nPosCmpCab][2] := SF3->F3_NFISCAL
						nPosCmpCab:=PosCabArray(aItens,"SERIE_DOCFIS")
						aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_SERIE")
						nPosCmpCab:=PosCabArray(aItens,"COD_OBS_LANCTO_FISCAL")
						aItens[Len(aItens)][nPosCmpCab][2] := IIf((CC7->(Found()) .and. !Empty(CC7->CC7_IFCOMP)),GetAdvFVal("CCE","CCE_DESCR",xFilial("CCE")+CC7->CC7_IFCOMP,1,"@"),"@") //IIf(CDF->(Found()),Eval(bCmpZerado,"CDF->CDF_IFCOMP"),"@")
						nPosCmpCab:=PosCabArray(aItens,"VIA_TRANSP")
						aItens[Len(aItens)][nPosCmpCab][2] := IIf(CDF->(Found()),Eval(bCmpZerado,"CDF->CDF_TPTRAN"),"@")
						nPosCmpCab:=PosCabArray(aItens,"UF_COLETA")
						aItens[Len(aItens)][nPosCmpCab][2] := SA1->A1_EST
						nPosCmpCab:=PosCabArray(aItens,"MUNIC_COLETA")
						aItens[Len(aItens)][nPosCmpCab][2] := SA1->A1_COD_MUN
						nPosCmpCab:=PosCabArray(aItens,"CNPJ_COLETA")
						aItens[Len(aItens)][nPosCmpCab][2] := SA1->A1_CGC
						nPosCmpCab:=PosCabArray(aItens,"IE_COLETA")
						aItens[Len(aItens)][nPosCmpCab][2] := SA1->A1_INSCR
						nPosCmpCab:=PosCabArray(aItens,"UF_ENTREGA")
						aItens[Len(aItens)][nPosCmpCab][2] := SA1->A1_EST
						nPosCmpCab:=PosCabArray(aItens,"MUNIC_ENTREGA")
						aItens[Len(aItens)][nPosCmpCab][2] := SA1->A1_COD_MUN
						nPosCmpCab:=PosCabArray(aItens,"CNPJ_ENTREGA")
						aItens[Len(aItens)][nPosCmpCab][2] := SA1->A1_CGC
						nPosCmpCab:=PosCabArray(aItens,"IE_ENTREGA")
						aItens[Len(aItens)][nPosCmpCab][2] := SA1->A1_INSCR
					Endif	
				//Endif
			Endif		
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX130()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Documentos Fiscais Eletrônicos Denegados ou Inutilizados    
=======================================================================================
*/

Static Function fSAFX130()
	
	cQ := CRLF + " SELECT SF3.R_E_C_N_O_ SF3_RECNO "
	cQ += CRLF + " FROM " + RetSqlName("SF3") + " SF3 "
	cQ += CRLF + " WHERE SF3.D_E_L_E_T_ = ' ' "
	cQ += CRLF + "	AND F3_FILIAL  BETWEEN '" + cFilDe         + "' AND '" + cFilAte       + "' "
	cQ += CRLF + "	AND F3_ENTRADA BETWEEN '" + dTos(dDataIni) + "' AND '" + dTos(dDataFim)+ "' "
	cQ += CRLF + "	AND F3_CLIEFOR BETWEEN '" + cCliForDe      + "' AND '" + cCliForAte    + "' "
	cQ += CRLF + "	AND F3_CODRSEF IN ('110','301','302','303','304','305','306','102') "
	
	If Empty( __cSelNfs )
		cQ += CRLF + "	AND F3_NFISCAL BETWEEN '" + cDocFisDe + "' AND '" + cDocFisAte + "' "
	Else
		cQ += CRLF + "	AND F3_NFISCAL IN " + FormatIn(__cSelNfs, ";") 
	EndIf

	cQ += CRLF + " ORDER BY F3_FILIAL,F3_ENTRADA,F3_NFISCAL "

	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf 
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			SF3->(dbGoto((cAliasTrb)->SF3_RECNO))
			If SF3->(Recno()) == (cAliasTrb)->SF3_RECNO
				lContinua := .T.
				
				// posiciona tabelas auxiliares
				If lContinua	
					MontaItens(aCab,@aItens,SF3->F3_FILIAL)
								
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",SF3->F3_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"MOVTO_E_S")
					aItens[Len(aItens)][nPosCmpCab][2] := MOVTO_E_S(SF3->F3_CFO,SF3->F3_FORMUL)
					nPosCmpCab:=PosCabArray(aItens,"NUM_DOCFIS_INI")
					aItens[Len(aItens)][nPosCmpCab][2] := SF3->F3_NFISCAL
					nPosCmpCab:=PosCabArray(aItens,"NUM_DOCFIS_FIN")
					aItens[Len(aItens)][nPosCmpCab][2] := SF3->F3_NFISCAL
					nPosCmpCab:=PosCabArray(aItens,"SERIE_DOCFIS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_SERIE")
					nPosCmpCab:=PosCabArray(aItens,"DATA_REF")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(SF3->F3_ENTRADA)
					nPosCmpCab:=PosCabArray(aItens,"COD_MODELO")
					aItens[Len(aItens)][nPosCmpCab][2] := COD_MODELO(Alltrim(SF3->F3_ESPECIE)) // AModNot(SF3->F3_ESPECIE)
					nPosCmpCab:=PosCabArray(aItens,"IND_SITUACAO")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(SF3->F3_CODRSEF = "102","2","1")
					nPosCmpCab:=PosCabArray(aItens,"NUM_AUTENTIC_NFE")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SF3->F3_CHVNFE")
				Endif
			Endif	
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX153()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Produção de Terceiros                                       
=======================================================================================
*/

Static Function fSAFX153()
	Local nCnt := 0

	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		AFill(aAliasKProc,.F.)
		aAliasKProc[K250] := .T.
		aAliasKProc[K255] := .T.
		cFilAntSav := cFilAnt
		
		SM0->(GetArea())
		SM0->(dbSetOrder(1))
		SM0->(dbGotop())
		
		While SM0->(!Eof())
			If SM0->M0_CODIGO == FWGrpCompany() .and. SM0->M0_CODFIL >= cFilDe .and. SM0->M0_CODFIL <= cFilAte
				cFilAnt := SM0->M0_CODFIL
				SPDBlocoK(dDataIni,dDataFim,@aAliasK,aAliasKProc,.F.,.F.)
				For nCnt:=1 To Len(aAliasK)
					If !(nCnt == K250 .or. nCnt == K255)
						Loop
					Endif	
					While Select(aAliasK[nCnt])>0 .and. (aAliasK[nCnt])->(!Eof())
						lContinua := .T.
						
						//cTpCorr := BlcKTpCorr((aAliasK[nCnt])->ORIGEM)
						
						SB1->(dbSetOrder(1))
						If SB1->(!dbSeek(Padr(Subs(cFilAnt,1,6),TamSX3("B1_FILIAL")[1])+(aAliasK[nCnt])->COD_ITEM))
							lContinua := .F.
							cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(cFilAnt,1,6),TamSX3("B1_FILIAL")[1])+"/"+(aAliasK[nCnt])->COD_ITEM+", produto Bloco K: "+(aAliasK[nCnt])->COD_ITEM+"." 
							MS06GrvLog(cErro)
						Endif	
							
						If lContinua	
							MontaItens(aCab,@aItens,cFilAnt)
										
							// comeca gravar campos do layout
							nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
							aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",cFilAnt)
							nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
							aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",cFilAnt)
							If "K250" $ (aAliasK[nCnt])
								nPosCmpCab:=PosCabArray(aItens,"DAT_PRODUCAO")
								aItens[Len(aItens)][nPosCmpCab][2] := dTos((aAliasK[nCnt])->DT_PROD)
							Endif	
							nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
							aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
							nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
							aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(aAliasK[nCnt])->COD_ITEM")
							nPosCmpCab:=PosCabArray(aItens,"QUANTIDADE")
							aItens[Len(aItens)][nPosCmpCab][2] := (aAliasK[nCnt])->QTD*(10**6) //Eval(bCmpZerado,"(aAliasK[nCnt])->QTD")
							nPosCmpCab:=PosCabArray(aItens,"COD_MEDIDA")
							aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_UM")
						Endif	
						(aAliasK[nCnt])->(dbSkip())
					Enddo
					If Select(aAliasK[nCnt])>0
						(aAliasK[nCnt])->(dbCloseArea())
					Endif						
				Next
			Endif
			SM0->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
Return 

/*
=======================================================================================
Programa.:              fSAFX154()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Produção de Terceiros - Insumos Consumidos                  
=======================================================================================
*/

Static Function fSAFX154()
	Local nCnt := 0
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		AFill(aAliasKProc,.F.)
		aAliasKProc[K250] := .T.
		aAliasKProc[K255] := .T.
		cFilAntSav := cFilAnt
		
		SM0->(GetArea())
		SM0->(dbSetOrder(1))
		SM0->(dbGotop())
		
		While SM0->(!Eof())
			If SM0->M0_CODIGO == FWGrpCompany() .and. SM0->M0_CODFIL >= cFilDe .and. SM0->M0_CODFIL <= cFilAte
				cFilAnt := SM0->M0_CODFIL
				SPDBlocoK(dDataIni,dDataFim,@aAliasK,aAliasKProc,.F.,.F.)
				For nCnt:=1 To Len(aAliasK)
					If !(nCnt == K250 .or. nCnt == K255)
						Loop
					Endif	
					While Select(aAliasK[nCnt])>0 .and. (aAliasK[nCnt])->(!Eof())
						lContinua := .T.
						
						SB1->(dbSetOrder(1))
						If SB1->(!dbSeek(Padr(Subs(cFilAnt,1,6),TamSX3("B1_FILIAL")[1])+(aAliasK[nCnt])->COD_ITEM))
							lContinua := .F.
							cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(cFilAnt,1,6),TamSX3("B1_FILIAL")[1])+"/"+(aAliasK[nCnt])->COD_ITEM+", produto Bloco K: "+(aAliasK[nCnt])->COD_ITEM+"." 
							MS06GrvLog(cErro)
						Endif	
							
						If lContinua	
							MontaItens(aCab,@aItens,cFilAnt)
										
							// comeca gravar campos do layout
							nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
							aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",cFilAnt)
							nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
							aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",cFilAnt)
							If "K250" $ (aAliasK[nCnt])
								nPosCmpCab:=PosCabArray(aItens,"DAT_PRODUCAO")
								aItens[Len(aItens)][nPosCmpCab][2] := dTos((aAliasK[nCnt])->DT_PROD)
							Endif	
							nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
							aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
							nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
							aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(aAliasK[nCnt])->COD_ITEM")
							If "K255" $ (aAliasK[nCnt])
								nPosCmpCab:=PosCabArray(aItens,"DAT_CONSUMO")
								aItens[Len(aItens)][nPosCmpCab][2] := dTos((aAliasK[nCnt])->DT_CONS)
							Endif	
							nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO_INS")
							aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
							nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO_INS")
							aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(aAliasK[nCnt])->COD_ITEM")
							nPosCmpCab:=PosCabArray(aItens,"QUANTIDADE")
							aItens[Len(aItens)][nPosCmpCab][2] := (aAliasK[nCnt])->QTD*(10**6)
							nPosCmpCab:=PosCabArray(aItens,"COD_MEDIDA")
							aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_UM")
							If "K255" $ (aAliasK[nCnt])
								If !Empty((aAliasK[nCnt])->COD_INS_SU)
									If SB1->(!dbSeek(Padr(Subs(cFilAnt,1,6),TamSX3("B1_FILIAL")[1])+(aAliasK[nCnt])->COD_INS_SU))
										lContinua := .F.
										cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(cFilAnt,1,6),TamSX3("B1_FILIAL")[1])+"/"+(aAliasK[nCnt])->COD_INS_SU+", produto insumo Bloco K: "+(aAliasK[nCnt])->COD_INS_SU+"." 
										MS06GrvLog(cErro)
									Endif
									If lContinua	
										nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO_SUB")
										aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
										nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO_SUB")
										aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(aAliasK[nCnt])->COD_INS_SU")
									Endif
								Endif
							Endif			
						Endif	
						(aAliasK[nCnt])->(dbSkip())
					Enddo
					If Select(aAliasK[nCnt])>0
						(aAliasK[nCnt])->(dbCloseArea())
					Endif						
				Next
			Endif
			SM0->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif

Return 

/*
=======================================================================================
Programa.:              fSAFX235()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Tabela das Correções de Apontamento da EFD - Bloco K.       
=======================================================================================
*/

Static Function fSAFX235()
	Local nCnt := 0
		
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		AFill(aAliasKProc,.F.)
		aAliasKProc[K270] := .T.
		aAliasKProc[K275] := .T.
		aAliasKProc[K280] := .T.
		cFilAntSav := cFilAnt
		SM0->(GetArea())
		SM0->(dbSetOrder(1))
		SM0->(dbGotop())
		
		While SM0->(!Eof())
		
			If SM0->M0_CODIGO == FWGrpCompany() .and. SM0->M0_CODFIL >= cFilDe .and. SM0->M0_CODFIL <= cFilAte
				cFilAnt := SM0->M0_CODFIL
				SPDBlocoK(dDataIni,dDataFim,@aAliasK,aAliasKProc,.F.,.F.)
				For nCnt:=1 To Len(aAliasK)
		
					If !(nCnt == K270 .or. nCnt == K275 .or. nCnt == K280)
						Loop
					Endif	
		
					While Select(aAliasK[nCnt])>0 .and. (aAliasK[nCnt])->(!Eof())
						lContinua := .T.
						
						If "K270" $ (aAliasK[nCnt])
							cTpCorr := BlcKTpCorr((aAliasK[nCnt])->ORIGEM)
						Endif	
						
						SB1->(dbSetOrder(1))
						If SB1->(!dbSeek(Padr(Subs(cFilAnt,1,6),TamSX3("B1_FILIAL")[1])+(aAliasK[nCnt])->COD_ITEM))
							lContinua := .F.
							cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(cFilAnt,1,6),TamSX3("B1_FILIAL")[1])+"/"+(aAliasK[nCnt])->COD_ITEM+", produto Bloco K: "+(aAliasK[nCnt])->COD_ITEM+"." 
							MS06GrvLog(cErro)
						Endif	
							
						If lContinua	
							MontaItens(aCab,@aItens,cFilAnt)
										
							// comeca gravar campos do layout
							nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
							aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",cFilAnt)
							nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
							aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",cFilAnt)
							nPosCmpCab:=PosCabArray(aItens,"PERIODO_REF")
							aItens[Len(aItens)][nPosCmpCab][2] := Subs(dTos(dDataIni),1,6)
							nPosCmpCab:=PosCabArray(aItens,"IND_TP_CORRECAO")
							aItens[Len(aItens)][nPosCmpCab][2] := cTpCorr
							nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
							aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
							nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
							aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(aAliasK[nCnt])->COD_ITEM")
							If "K270" $ (aAliasK[nCnt])
								nPosCmpCab:=PosCabArray(aItens,"DAT_INI_APUR")
								aItens[Len(aItens)][nPosCmpCab][2] := IIf(cTpCorr=="1","@",dTos((aAliasK[nCnt])->DT_INI_AP))
								nPosCmpCab:=PosCabArray(aItens,"DAT_FIM_APUR")
								aItens[Len(aItens)][nPosCmpCab][2] := IIf(cTpCorr=="1","@",dTos((aAliasK[nCnt])->DT_FIN_AP))
							Endif
							If "K270" $ (aAliasK[nCnt]) .or. "K275" $ (aAliasK[nCnt])	
								nPosCmpCab:=PosCabArray(aItens,"COD_OP")
								aItens[Len(aItens)][nPosCmpCab][2] := IIf(cTpCorr$"1/3","@",Eval(bCmpZerado,"(aAliasK[nCnt])->COD_OP_OS"))
							Endif
							If "K280" $ (aAliasK[nCnt])	
								nPosCmpCab:=PosCabArray(aItens,"DAT_ESTQ_FIM")
								aItens[Len(aItens)][nPosCmpCab][2] := IIf(!cTpCorr=="1","@",dTos((aAliasK[nCnt])->DT_EST))
								nPosCmpCab:=PosCabArray(aItens,"GRUPO_CONTAGEM")
								aItens[Len(aItens)][nPosCmpCab][2] := IIf(!cTpCorr=="1","@",(cGrpCont:=GrpCont((aAliasK[nCnt])->IND_EST)))
							Endif	
							nPosCmpCab:=PosCabArray(aItens,"COD_MEDIDA")
							aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_UM")
							nPosCmpCab:=PosCabArray(aItens,"QTD_CORRECAO")
							aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty((aAliasK[nCnt])->QTD_COR_P),(aAliasK[nCnt])->QTD_COR_P*(10**6),(aAliasK[nCnt])->QTD_COR_N*(10**6))
							nPosCmpCab:=PosCabArray(aItens,"IND_POS_NEG")
							aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty((aAliasK[nCnt])->QTD_COR_P),"1","2")
						Endif	
						(aAliasK[nCnt])->(dbSkip())
					Enddo
					If Select(aAliasK[nCnt])>0
						(aAliasK[nCnt])->(dbCloseArea())
					Endif						
				Next
			Endif
			SM0->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
Return 

/*
=======================================================================================
Programa.:              fSAFX236()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Tabela de Itens das Correções de Apontamento da EFD - Bloco 
=======================================================================================
*/

Static Function fSAFX236()
	Local nCnt := 0
		
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		AFill(aAliasKProc,.F.)
		aAliasKProc[K270] := .T.
		aAliasKProc[K275] := .T.
		aAliasKProc[K280] := .T.
		cFilAntSav := cFilAnt
	
		SM0->(GetArea())
		SM0->(dbSetOrder(1))
		SM0->(dbGotop())
	
		While SM0->(!Eof())
	
			If SM0->M0_CODIGO == FWGrpCompany() .and. SM0->M0_CODFIL >= cFilDe .and. SM0->M0_CODFIL <= cFilAte
				cFilAnt := SM0->M0_CODFIL
				SPDBlocoK(dDataIni,dDataFim,@aAliasK,aAliasKProc,.F.,.F.)
	
				For nCnt:=1 To Len(aAliasK)
	
					If !(nCnt == K270 .or. nCnt == K275 .or. nCnt == K280)
						Loop
					Endif	
	
					While Select(aAliasK[nCnt])>0 .and. (aAliasK[nCnt])->(!Eof())
						lContinua := .T.
						
						If "K270" $ (aAliasK[nCnt])
							cTpCorr := BlcKTpCorr((aAliasK[nCnt])->ORIGEM)
						Endif	
						
						SB1->(dbSetOrder(1))
						If SB1->(!dbSeek(Padr(Subs(cFilAnt,1,6),TamSX3("B1_FILIAL")[1])+(aAliasK[nCnt])->COD_ITEM))
							lContinua := .F.
							cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(cFilAnt,1,6),TamSX3("B1_FILIAL")[1])+"/"+(aAliasK[nCnt])->COD_ITEM+", produto Bloco K: "+(aAliasK[nCnt])->COD_ITEM+"." 
							MS06GrvLog(cErro)
						Endif	
							
						If lContinua	
							MontaItens(aCab,@aItens,cFilAnt)
										
							// comeca gravar campos do layout
							nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
							aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",cFilAnt)
							nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
							aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",cFilAnt)
							nPosCmpCab:=PosCabArray(aItens,"PERIODO_REF")
							aItens[Len(aItens)][nPosCmpCab][2] := Subs(dTos(dDataIni),1,6)
							nPosCmpCab:=PosCabArray(aItens,"IND_TP_CORRECAO")
							aItens[Len(aItens)][nPosCmpCab][2] := cTpCorr
							nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
							aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
							nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
							aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(aAliasK[nCnt])->COD_ITEM")
							If "K270" $ (aAliasK[nCnt])
								nPosCmpCab:=PosCabArray(aItens,"DAT_INI_APUR")
								aItens[Len(aItens)][nPosCmpCab][2] := IIf(cTpCorr=="1","@",dTos((aAliasK[nCnt])->DT_INI_AP))
								nPosCmpCab:=PosCabArray(aItens,"DAT_FIM_APUR")
								aItens[Len(aItens)][nPosCmpCab][2] := IIf(cTpCorr=="1","@",dTos((aAliasK[nCnt])->DT_FIN_AP))
							Endif
							If "K270" $ (aAliasK[nCnt]) .or. "K275" $ (aAliasK[nCnt])	
								nPosCmpCab:=PosCabArray(aItens,"COD_OP")
								aItens[Len(aItens)][nPosCmpCab][2] := IIf(cTpCorr$"1/3","@",Eval(bCmpZerado,"(aAliasK[nCnt])->COD_OP_OS"))
							Endif
							If "K280" $ (aAliasK[nCnt])	
								nPosCmpCab:=PosCabArray(aItens,"DAT_ESTQ_FIM")
								aItens[Len(aItens)][nPosCmpCab][2] := IIf(!cTpCorr=="1","@",dTos((aAliasK[nCnt])->DT_EST))
								nPosCmpCab:=PosCabArray(aItens,"GRUPO_CONTAGEM")
								aItens[Len(aItens)][nPosCmpCab][2] := IIf(!cTpCorr=="1","@",(cGrpCont:=GrpCont((aAliasK[nCnt])->IND_EST)))
							Endif	
							nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO_INS")
							aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
							nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO_INS")
							aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(aAliasK[nCnt])->COD_ITEM")
							nPosCmpCab:=PosCabArray(aItens,"COD_MEDIDA")
							aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_UM")
							nPosCmpCab:=PosCabArray(aItens,"QTD_CORRECAO")
							aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty((aAliasK[nCnt])->QTD_COR_P),(aAliasK[nCnt])->QTD_COR_P*(10**6),(aAliasK[nCnt])->QTD_COR_N*(10**6))
							nPosCmpCab:=PosCabArray(aItens,"IND_POS_NEG")
							aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty((aAliasK[nCnt])->QTD_COR_P),"1","2")
							If "K275" $ (aAliasK[nCnt])
								If cTpCorr $ "4/5"
									If SB1->(!dbSeek(Padr(Subs(cFilAnt,1,6),TamSX3("B1_FILIAL")[1])+(aAliasK[nCnt])->COD_INS_SU))
										lContinua := .F.
										cErro := cTab+": Não encontrado tabela: SB1, filial/produto: "+Padr(Subs(cFilAnt,1,6),TamSX3("B1_FILIAL")[1])+"/"+(aAliasK[nCnt])->COD_INS_SU+", produto insumo Bloco K: "+(aAliasK[nCnt])->COD_INS_SU+"." 
										MS06GrvLog(cErro)
									Endif
									If lContinua	
										nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO_SUBST")
										aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
										nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO_SUBST")
										aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"(aAliasK[nCnt])->COD_INS_SU")
									Endif
								Endif
							Endif			
						Endif	
						(aAliasK[nCnt])->(dbSkip())
					Enddo
					If Select(aAliasK[nCnt])>0
						(aAliasK[nCnt])->(dbCloseArea())
					Endif						
				Next
			Endif
			SM0->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
Return 

/*
=======================================================================================
Programa.:              fSAFX245()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Tabela dos Valores Declaratórios do SPED Fiscal (E115/1925) 
=======================================================================================
*/

Static Function fSAFX245()
	cQ := CRLF + " SELECT CDV.R_E_C_N_O_ CDV_RECNO "
	cQ += CRLF + " 	FROM " + RetSqlName("CDV") + " CDV "
	cQ += CRLF + " 	WHERE CDV.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND CDV_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
	cQ += CRLF + " 		AND CDV_PERIOD BETWEEN '" + Subs(dTos(dDataIni),1,6) + "' AND '" + Subs(dTos(dDataFim),1,6) + "' "
	cQ += CRLF + " ORDER BY CDV_FILIAL,CDV_PERIOD,CDV_DOC "

	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			CDV->(dbGoto((cAliasTrb)->CDV_RECNO))
			If CDV->(Recno()) == (cAliasTrb)->CDV_RECNO
				lContinua := .T.
				
				If lContinua	
					MontaItens(aCab,@aItens,CDV->CDV_FILIAL)
								
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",CDV->CDV_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",CDV->CDV_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"DATA_INI")
					aItens[Len(aItens)][nPosCmpCab][2] := CDV->CDV_PERIOD+"01"
					nPosCmpCab:=PosCabArray(aItens,"DATA_FIM")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(LastDay(sTod(CDV->CDV_PERIOD+"01")))
					nPosCmpCab:=PosCabArray(aItens,"COD_INF_ADIC")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CDV->CDV_CODAJU")
					nPosCmpCab:=PosCabArray(aItens,"VLR_INF_ADIC")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CDV->CDV_VALOR")
				Endif	
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX520()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Situação Tributária complementar                            
=======================================================================================
*/

Static Function fSAFX520()
	cQ := CRLF + " SELECT F0M.R_E_C_N_O_ F0M_RECNO, SB1.R_E_C_N_O_ SB1_RECNO "
	cQ += CRLF + " FROM " + RetSqlName("F0M") + " F0M "
	cQ += CRLF + " 	INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQ += CRLF + " 		ON  SB1.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SUBSTR(B1_FILIAL,1,6) = SUBSTR(F0M_FILIAL,1,6) "
	cQ += CRLF + " 		AND B1_COD   = F0M_CODIGO "
	cQ += CRLF + " 		AND B1_TIPO <> 'SV' "
	cQ += CRLF + " WHERE F0M.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 	 AND F0M_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' "
	cQ += CRLF + " 	 AND F0M_DTFECH BETWEEN '"+dTos(dDataIni)+"' AND '"+dTos(dDataFim)+"' "
	cQ += CRLF + " ORDER BY F0M_FILIAL,F0M_DTFECH,F0M_CODIGO "

	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			F0M->(dbGoto((cAliasTrb)->F0M_RECNO))
			If F0M->(Recno()) == (cAliasTrb)->F0M_RECNO
				lContinua := .T.

				// posiciona tabelas auxiliares
				SB1->(dbGoto((cAliasTrb)->SB1_RECNO))

				If lContinua	
					MontaItens(aCab,@aItens,F0M->F0M_FILIAL)
								
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_EMPRESA")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_EMPMS",F0M->F0M_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"COD_ESTAB")
					aItens[Len(aItens)][nPosCmpCab][2] := SZPMSaf("ZP_ESTMS",F0M->F0M_FILIAL)
					nPosCmpCab:=PosCabArray(aItens,"DATA_INVENTARIO")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(F0M->F0M_DTFECH)
					nPosCmpCab:=PosCabArray(aItens,"GRUPO_CONTAGEM")
					aItens[Len(aItens)][nPosCmpCab][2] := (cGrpCont:=GrpCont(F0M->F0M_SITUA))
					nPosCmpCab:=PosCabArray(aItens,"COD_NBM")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_POSIPI")
					nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
					aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
					nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SD1->D1_COD")
					nPosCmpCab:=PosCabArray(aItens,"COD_UND_PADRAO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"F0M->F0M_UM")
					nPosCmpCab:=PosCabArray(aItens,"COD_NAT_ESTOQUE")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_TIPO") //COD_NAT_ESTOQUE("SB1")
					nPosCmpCab:=PosCabArray(aItens,"COD_SITUACAO_A")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"F0M->F0M_CST")
					nPosCmpCab:=PosCabArray(aItens,"COD_SITUACAO_B")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"F0M->F0M_CST")
				Endif	
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX2006()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Tabela de Natureza de Operação                              
=======================================================================================
*/

Static Function fSAFX2006()
	cQ := CRLF + "SELECT CD1.R_E_C_N_O_ CD1_RECNO "
	cQ += CRLF + "FROM " + RetSqlName("CD1") + " CD1 "
	cQ += CRLF + "WHERE CD1.D_E_L_E_T_ = ' ' "
	cQ += CRLF + "ORDER BY CD1_FILIAL,CD1_CODNAT "
	
	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf 
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			CD1->(dbGoto((cAliasTrb)->CD1_RECNO))
			If CD1->(Recno()) == (cAliasTrb)->CD1_RECNO

				lContinua := .T.
					
				If lContinua	
					MontaItens(aCab,@aItens,CD1->CD1_FILIAL)
									
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_NATUREZA_OP")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CD1->CD1_CODNAT")
					//nPosCmpCab:=PosCabArray(aItens,"DATA_X2006")
					//aItens[Len(aItens)][nPosCmpCab][2] := dTos(dDataBase)
					nPosCmpCab:=PosCabArray(aItens,"DESCRICAO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CD1->CD1_DESCR")
					//nPosCmpCab:=PosCabArray(aItens,"ENT_SAI")
					//aItens[Len(aItens)][nPosCmpCab][2] := IIf(SF4->F4_CODIGO < "500","E","S")
				Endif
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
Return 

/*
=======================================================================================
Programa.:              fSAFX2009()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Cadastro de Observações - Ato COTEPE/ICMS 35/05             
=======================================================================================
*/

Static Function fSAFX2009()
	cQ := CRLF + "SELECT CCE.R_E_C_N_O_ CCE_RECNO "
	cQ += CRLF + "FROM " + RetSqlName("CCE") + " CCE "
	cQ += CRLF + "WHERE CCE.D_E_L_E_T_ = ' ' "
	cQ += CRLF + "AND CCE_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
	cQ += CRLF + "ORDER BY CCE_FILIAL,CCE_COD "

	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			CCE->(dbGoto((cAliasTrb)->CCE_RECNO))
			If CCE->(Recno()) == (cAliasTrb)->CCE_RECNO
				lContinua := .T.
				
				If lContinua	
					MontaItens(aCab,@aItens,CCE->CCE_FILIAL)
								
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_OBSERVACAO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CCE->CCE_COD")
					nPosCmpCab:=PosCabArray(aItens,"DATA_X2009")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(dDataBase)
					nPosCmpCab:=PosCabArray(aItens,"DESCRICAO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CCE->CCE_DESCR")
				Endif	
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	

Return 

/*
=======================================================================================
Programa.:              fSAFX2010()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Tabela de Natureza de Estoque                               
=======================================================================================
*/

Static Function fSAFX2010()

	cQ := CRLF + " SELECT SX5.R_E_C_N_O_ SX5_RECNO "
	cQ += CRLF + " FROM " + RetSqlName("SX5") + " SX5 "
	cQ += CRLF + " WHERE    SX5.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SX5.X5_TABELA  = '02' "
	cQ += CRLF + " ORDER BY X5_FILIAL,X5_TABELA,X5_CHAVE "

	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			SX5->(dbGoto((cAliasTrb)->SX5_RECNO))
			If SX5->(Recno()) == (cAliasTrb)->SX5_RECNO
				lContinua := .T.
				
				If lContinua	
					MontaItens(aCab,@aItens,SX5->X5_FILIAL)
								
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_ESTOQUE")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SX5->X5_CHAVE")
					nPosCmpCab:=PosCabArray(aItens,"DATA_X2010")
					aItens[Len(aItens)][nPosCmpCab][2] := dTos(dDataBase)
					nPosCmpCab:=PosCabArray(aItens,"DESCRICAO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SX5->X5_DESCRI")
				Endif	
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
		

Return 

/*
=======================================================================================
Programa.:              fSAFX2013()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Tabela de Produtos                                          
=======================================================================================
*/

Static Function fSAFX2013()
	
	cQ := CRLF + " SELECT SB1.R_E_C_N_O_ SB1_RECNO, NVL(SB5.R_E_C_N_O_,0) SB5_RECNO,nvl(SB5.B5_CEME, '@') as B5_CEME, SB1.* "
	cQ += CRLF + " FROM " + RetSqlName("SB1") + " SB1 "

	cQ += CRLF + " 	LEFT JOIN " + RetSqlName("SB5") + " SB5 "
	cQ += CRLF + " 		ON  SB5.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND B5_FILIAL      = B1_FILIAL "
	cQ += CRLF + " 		AND B5_COD         = B1_COD "

	cQ += CRLF + " WHERE SB1.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 	 AND SUBSTR(B1_FILIAL,1,6) BETWEEN '" + Subs(cFilDe,1,6) + "' AND '" + Subs(cFilAte,1,6) + "' "
	cQ += CRLF + " 	 AND B1_COD BETWEEN '" + cProdDe + "' AND '" + cProdAte + "' "
	cQ += CRLF + " 	 AND B1_MSBLQL <> '1' "
	cQ += CRLF + " 	 AND B1_TIPO   <> 'SV' "

	cQ += CRLF + " ORDER BY B1_FILIAL,B1_COD "

	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			
			MontaItens(aCab,@aItens,(cAliasTrb)->B1_FILIAL)
								
			// comeca gravar campos do layout
			nPosCmpCab:=PosCabArray(aItens,"IND_PRODUTO")
			aItens[Len(aItens)][nPosCmpCab][2] := IND_PRODUTO("SB1")
			nPosCmpCab:=PosCabArray(aItens,"COD_PRODUTO")
			aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado, cAliasTrb + "->B1_COD")
			nPosCmpCab:=PosCabArray(aItens,"DATA_PRODUTO")
			aItens[Len(aItens)][nPosCmpCab][2] := "19000101"
			nPosCmpCab:=PosCabArray(aItens,"DESCRICAO")
			aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado, cAliasTrb + "->B1_DESC")
			nPosCmpCab:=PosCabArray(aItens,"COD_NBM")
			aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,cAliasTrb + "->B1_POSIPI")
			nPosCmpCab:=PosCabArray(aItens,"COD_NCM")
			aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,cAliasTrb + "->B1_POSIPI")
			nPosCmpCab:=PosCabArray(aItens,"COD_NALADI")
			aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,cAliasTrb + "->B1_NALSH")
			nPosCmpCab:=PosCabArray(aItens,"IND_REGIDO_SUBST")
			aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty((cAliasTrb  )->B1_PICMRET),"S","@")
			nPosCmpCab:=PosCabArray(aItens,"IND_CONTROLE_SELO")
			aItens[Len(aItens)][nPosCmpCab][2] := "N"
			nPosCmpCab:=PosCabArray(aItens,"COD_MEDIDA")
			aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado, cAliasTrb + "->B1_UM")
			//nPosCmpCab:=PosCabArray(aItens,"COD_GRUPO_PROD")
			//aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_GRUPO")
			nPosCmpCab:=PosCabArray(aItens,"IND_INCID_ICMS_SER")
			aItens[Len(aItens)][nPosCmpCab][2] := "1"
			nPosCmpCab:=PosCabArray(aItens,"COD_UND_PADRAO")
			aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado, cAliasTrb + "->B1_UM")
			nPosCmpCab:=PosCabArray(aItens,"DESCR_DETALHADA")
			aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,cAliasTrb + "->B5_CEME")
			nPosCmpCab:=PosCabArray(aItens,"IND_FABRIC_ESTAB")
			aItens[Len(aItens)][nPosCmpCab][2] := IIf(((cAliasTrb)->B1_TIPO == "PA" .and. (cAliasTrb)->B1_ORIGEM $ "0/3/4/5/8"),"S","N")
			nPosCmpCab:=PosCabArray(aItens,"IND_CLASSIF_ICMSS")
			aItens[Len(aItens)][nPosCmpCab][2] := "1"
			nPosCmpCab:=PosCabArray(aItens,"ORIGEM")
			aItens[Len(aItens)][nPosCmpCab][2] := IIf((cAliasTrb)->B1_ORIGEM $ "0/3/4/5/8","1","2")
			nPosCmpCab:=PosCabArray(aItens,"IND_INCID_PIS")
			aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty((cAliasTrb)->B1_PPIS),"S","N")
			nPosCmpCab:=PosCabArray(aItens,"ALIQ_PIS")
			aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty( (cAliasTrb)->B1_PPIS),Eval(bCmpZerado, cAliasTrb + "->B1_PPIS"),"@")
			nPosCmpCab:=PosCabArray(aItens,"IND_INCID_COFINS")
			aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty( (cAliasTrb)->B1_PCOFINS),"S","N")
			nPosCmpCab:=PosCabArray(aItens,"ALIQ_COFINS")
			aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty((cAliasTrb)->B1_PCOFINS),Eval(bCmpZerado, cAliasTrb + "->B1_PCOFINS"),"@")
			nPosCmpCab:=PosCabArray(aItens,"IND_FUNRURAL")
			aItens[Len(aItens)][nPosCmpCab][2] := IIf( (cAliasTrb)->B1_CONTSOC=="S","S","N")
			nPosCmpCab:=PosCabArray(aItens,"IND_PETR_ENERG")
			aItens[Len(aItens)][nPosCmpCab][2] := "N" 
			nPosCmpCab:=PosCabArray(aItens,"IND_PRD_INCENTIV")
			aItens[Len(aItens)][nPosCmpCab][2] := IIf(!Empty( (cAliasTrb)->B1_CRDEST),"S","N")
			nPosCmpCab:=PosCabArray(aItens,"CLAS_ITEM")
			aItens[Len(aItens)][nPosCmpCab][2] := IIf((nPos:=aScan(aTipo,{|x| Alltrim(x[1])==Alltrim(SB1->B1_TIPO)}))>0,aTipo[nPos][2],"00") 
			nPosCmpCab:=PosCabArray(aItens,"COD_BARRAS")
			aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado, cAliasTrb + "->B1_CODBAR")
			
			if len(aItens) >= _nLimite  //a cada 1000 linhas é gravado no arquivo para liberar a memória
				SalvaTXT(aCab,aItens)
				aItens := {}
				IF LDebug
					(cAliasTrb)->(dbCloseArea())
					RETURN
				ENDIF
			ENDIF
			
			(cAliasTrb)->(dbSkip())
			
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
	

Return 

/*
=======================================================================================
Programa.:              fSAFX2018()
Autor....:              CAOA -- Reinaldo Rabelo da Silva
Data.....:              04/01/2023
Descricao / Objetivo:   Tabela de Código de Serviços                                
=======================================================================================
*/

Static Function fSAFX2018()
	cQ := CRLF + " SELECT SB1.R_E_C_N_O_ SB1_RECNO "
	cQ += CRLF + " FROM " + RetSqlName("SB1") + " SB1 "
	cQ += CRLF + " WHERE    SB1.D_E_L_E_T_ = ' ' "
	cQ += CRLF + " 		AND SUBSTR(B1_FILIAL,1,6) BETWEEN '" + Subs(cFilDe,1,6) + "' AND '" + Subs(cFilAte,1,6) + "' "
	cQ += CRLF + " 		AND B1_COD BETWEEN '" + cProdDe + "' AND '" + cProdAte + "' "
	cQ += CRLF + " 		AND B1_MSBLQL <> '1' "
	cQ += CRLF + " 		AND B1_TIPO   = 'SV' "
	cQ += CRLF + " ORDER BY B1_FILIAL,B1_COD "

	If lDebug
		MemoWrite(cLocDest+cTab+".txt",cQ)
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQ),cAliasTrb,.T.,.F.)
	
	// monta array com campos do arquivo
	MontaCab(Alltrim(cTab),@aCab)

	If !Empty(aCab)
		While (cAliasTrb)->(!Eof())
			SB1->(dbGoto((cAliasTrb)->SB1_RECNO))
			If SB1->(Recno()) == (cAliasTrb)->SB1_RECNO
				lContinua := .T.
				
				// posiciona tabelas auxiliares
				CCQ->(dbSetOrder(1))
				If !Empty(SB1->B1_CODISS)
					CCQ->(dbSeek(xFilial("CCQ")+SB1->B1_CODISS))
				Endif	
					
				If lContinua	
					MontaItens(aCab,@aItens,SB1->B1_FILIAL)
								
					// comeca gravar campos do layout
					nPosCmpCab:=PosCabArray(aItens,"COD_SERVICO")
					aItens[Len(aItens)][nPosCmpCab][2] := Right(Alltrim(SB1->B1_COD),TamSZR(cTab)[1]) //Eval(bCmpZerado,"SB1->B1_COD")
					nPosCmpCab:=PosCabArray(aItens,"DATA_X2018")
					aItens[Len(aItens)][nPosCmpCab][2] := "19000101" //dTos(dDataBase)
					nPosCmpCab:=PosCabArray(aItens,"DESCRICAO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_DESC")
					nPosCmpCab:=PosCabArray(aItens,"IND_TP_SERVICO")
					aItens[Len(aItens)][nPosCmpCab][2] := "0"
					nPosCmpCab:=PosCabArray(aItens,"DESCRICAO")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_DESC")
					nPosCmpCab:=PosCabArray(aItens,"IND_MAT_SERV")
					aItens[Len(aItens)][nPosCmpCab][2] := "2"
					nPosCmpCab:=PosCabArray(aItens,"IND_CONTRATO")
					aItens[Len(aItens)][nPosCmpCab][2] := "N"
					nPosCmpCab:=PosCabArray(aItens,"COD_NAT_SERV")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_CODISS")
					nPosCmpCab:=PosCabArray(aItens,"DESC_NAT_SERV")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"CCQ->CCQ_DESC")
					nPosCmpCab:=PosCabArray(aItens,"INSS")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(SB1->B1_INSS=="S","S","N")
					nPosCmpCab:=PosCabArray(aItens,"ISS")
					aItens[Len(aItens)][nPosCmpCab][2] := "S"
					nPosCmpCab:=PosCabArray(aItens,"IRRF")
					aItens[Len(aItens)][nPosCmpCab][2] := IIf(SB1->B1_IRRF=="S","S","N")
					nPosCmpCab:=PosCabArray(aItens,"ALIQUOTA_ISS")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_ALIQISS")
					nPosCmpCab:=PosCabArray(aItens,"COD_SERV_LEI_116")
					aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZeroEsq,"SB1->B1_CODISS")
					//nPosCmpCab:=PosCabArray(aItens,"COD_ATIVIDADE")
					//aItens[Len(aItens)][nPosCmpCab][2] := Eval(bCmpZerado,"SB1->B1_CNAE")
				Endif	
			Endif
			(cAliasTrb)->(dbSkip())
		Enddo
	Else
		APMsgAlert(cTab+": Estrutura não cadastrada na tabela 'SZR - CAMPOS TABELA MASTERSAF'.Verifique.")
	Endif
	(cAliasTrb)->(dbCloseArea())	
		

Return


Static Function aJustSXe()
Local cAlias := "TRBSXE"
cQuery := " SELECT Max(GXL_NRIMP) as GXL_NRIMP  FROM " + RetSqlName("GXL") + " "
cQuery += " WHERE D_E_L_E_T_ =' ' 

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.T.,.F.)

_cChaInt 	:= GETSXENUM("GXL","GXL_NRIMP")

While  (cAlias)->(!Eof()) .and. (cAlias)->GXL_NRIMP >= _cChaInt
	ConfirmSX8()
	_cChaInt 	:= GETSXENUM("GXL","GXL_NRIMP")

EndDo
	ConfirmSX8()

(cAlias)->(dbCloseArea())
Return

/*
user Function ZGENQTDQBR()

	
Return .t.

*/
