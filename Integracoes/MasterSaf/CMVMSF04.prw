#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "XMLXFUN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  CMVMSF04   ºAutor  ³JRCarvalho          º Data ³  13/11/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importação de XML NFS - BAse para Geração da SAFX112       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Projeto CAOA                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CMVMSF04()

/*
Definição de tabelas 
SPED001 Coluna CNPJ - contem o CNPJ do emitente / COluna ID_Ent contem o ID da empresa emitente;
SPED050 COLUNA ID_ENT / NFE_ID (numero da Serie + nota) /  STATUS = 6 e o STATUSCANC = 0
SZS010 - TABELA DE APOIO SAFX112
oNfe := XmlParser(aXML[nX][2],"_",@cAviso,@cErro) -> MONTA OBJETO oNfe com o XML da nota
aXml := GetXML(cIdEnt,aNotas,@cModalidade)
GetIdEnt() -> busca codgo da entidade
*/

//Local cMsg 		:= ""
Local cQuery 	:= ""
//Local cModaldade:= ""
//Local cNextCod	:= "000000"
Local aXml 		:= {}
Local aNotas 	:= {}
Local oNfe		:= NIL  
Local cError   	:= ""
Local cWarning 	:= ""
//Local oXml     	:= NIL 

Private cIdEnt 	:= ""   

//monta query para buscar as NFs que precsam gerar a Mensagem 
cQuery := "SELECT * FROM "+RetSQLName("SF3")+"SF3 WHERE SF3.D_E_L_E_T_ = ' ' SF3.F3_DTCANC = ' ' AND (SF3.F3_SERIE || SF3.F3_NFISCAL) NOT IN "
cQuery += "(SEECT SZS.SZ_NUMNF||SZS.SZ_SERNF FROM SZS010 SZS WHERE SZS.D_E_L_E_T_ = ' ' )"

MemoWrite("C:\TEMP\GERA_SZS010.sql",cQuery) 
dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),"TMP", .F., .T.) 
DbSelectArea("TMP")
TMP->(DbGotop())
If TMP->(EOF())
	MSGINFO('Não Existem dados para SAFX112', 'ATENÇÂO')
	RETURN
Else
	//processa os dados
	Do While !TMP->(EOF())
		//limpa conteudo das vaiáveis
		aXml 	:= {}
		aNotas 	:= {}
		//alimenta aNotas
		If (SubStr(TMP->F3_CFO,1,1)>="5" .Or. TMP->F3_FORMUL=="S") //.And. aScan(aNotas,{|x| x[4]+x[5]+x[6]+x[7]==TMP->F3_SERIE+TMP->F3_NFISCAL+TMP->F3_CLIEFOR+TMP->F3_LOJA})==0
			aadd(aNotas,{})
			aadd(Atail(aNotas),.F.)
			aadd(Atail(aNotas),IIF(TMP->F3_CFO<"5","E","S"))
			aadd(Atail(aNotas),TMP->F3_ENTRADA)
			aadd(Atail(aNotas),TMP->F3_SERIE)
			aadd(Atail(aNotas),TMP->F3_NFISCAL)
			aadd(Atail(aNotas),TMP->F3_CLIEFOR)
			aadd(Atail(aNotas),TMP->F3_LOJA)
		EndIf
		//identifica o IdEnt para acesso ao SPED
		cIdEnt := GetIdEnt()
		//Alimenta aXml
		aXml   := GetXML(cIdEnt,aNotas,@cModalidade)
		// MONTA OBJETO oNfe com o XML da nota
		oNfe := XmlParser(aXML[1][2],"_",@cWarning,@cError) 
		If Empty(cWarning) .And. Empty(cError)
			PROCESSA({|| GravaDados( oNfe)})
		Else
			MSGALERT("XML da NF não encontrado Impossível Prosseguir","ATENÇÃO!!")		
		EndIf
		TMP->(DbSkip())
	EndDo
	
Endif

// Copia arquivos do remote local para o servidor, compactando antes de transmitir
//CpyT2S( cPathCli+cFile, cPathSrv )

Return


//-----------------------------
// Rotina de Gravação Tabela Auxiliar
//-----------------------------
Static Function GravaDados( oNfe)

Local cCodSafx
	
cCodSafx := GetSXENum("SZS","ZS_CODSFX")

Dbselectarea("SZS")
Reclock("SZS",.T.)

SZS->ZS_FILIAL := xFilial("SZS")
SZS->ZS_IDENT  := cIdEnt
SZS->ZS_NUMNF  := oNfe:_NFE:_INFNFE:_IDE:_xNumDoc:TEXT
SZS->ZS_SERNF  := oNfe:_NFE:_INFNFE:_IDE:_xSerDoc:TEXT
SZS->ZS_MSG    := oNfe:_NFE:_INFNFE:_IDE:_xInfNfe:TEXT
SZS->ZS_CODSFX := cCodSafx

Msunlock()
ConfirmSx8()

//fGeralog("Falha na Gravação da NF " + cNumNf + " - " +cSerNf, cArqlog)

Return


//-----------------------------------------------------------------------
/* Busca XML da Nota Fiscal
@param  cID ID da nota que sera retornado

@return aRetorno   Array com os dados da nota
*/
//-----------------------------------------------------------------------


Static Function GetXML(cIdEnt,aIdNFe,cModalidade)  

Local aRetorno		:= {}
Local aDados		:= {}

Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local cModel		:= "55"


Local nZ			:= 0
Local nCount		:= 0

Local oWS

If Empty(cModalidade)    

	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nModalidade:= 0
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWS:cModelo    := cModel 
	If oWS:CFGModalidade()
		cModalidade    := SubStr(oWS:cCfgModalidadeResult,1,1)
	Else
		cModalidade    := ""
	EndIf  
	
EndIf  
         
oWs := nil

For nZ := 1 To len(aIdNfe) 

    nCount++

	aDados := executeRetorna( aIdNfe[nZ], cIdEnt, .F. )
	
	if ( nCount == 10 )
		delClassIntF()
		nCount := 0
	endif
	
	aAdd(aRetorno,aDados)
	
Next nZ

Return(aRetorno)

//-----------------------------------------------------------------------
/*/{Protheus.doc} executeRetorna
Executa o retorna de notas

@author Henrique Brugugnoli
@since 17/01/2013
@version 1.0 

@param  cID ID da nota que sera retornado

@return aRetorno   Array com os dados da nota
/*/
//-----------------------------------------------------------------------
static function executeRetorna( aNfe, cIdEnt, lUsacolab )

//Local aExecute		:= {}  
//Local aFalta		:= {}
//Local aResposta		:= {}
Local aRetorno		:= {}
//Local aDados		:= {} 
Local aIdNfe		:= {}

Local cAviso		:= "" 
Local cDHRecbto		:= ""
Local cDtHrRec		:= ""
Local cDtHrRec1		:= ""
Local cErro			:= "" 
Local cModTrans		:= ""
Local cProtDPEC		:= ""
Local cProtocolo	:= ""
Local cRetDPEC		:= ""
Local cRetorno		:= ""
Local cCodRetNFE	:= ""
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
//Local cModel		:= "55"

Local dDtRecib		:= CToD("")

//Local lFlag			:= .T.

Local nDtHrRec1		:= 0
//Local nL			:= 0
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 1
//Local nCount		:= 0
//Local nLenNFe
//Local nLenWS

Local oWS

Private oDHRecbto
Private oNFeRet
Private oDoc

default lUsacolab	:= .F.

aAdd(aIdNfe,aNfe)

oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN        := "TOTVS"
oWS:cID_ENT           := cIdEnt
oWS:nDIASPARAEXCLUSAO := 0
oWS:_URL 			  := AllTrim(cURL)+"/NFeSBRA.apw"
oWS:oWSNFEID          := NFESBRA_NFES2():New()
oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()  

aadd(aRetorno,{"","",aIdNfe[nZ][4]+aIdNfe[nZ][5],"","","",CToD(""),"",""})

aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nZ][4]+aIdNfe[nZ][5]

If oWS:RETORNANOTASNX()
	If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
		For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
			cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
			cProtocolo      := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO								
			cDHRecbto  		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT
			oNFeRet			:= XmlParser(cRetorno,"_",@cAviso,@cErro)
			cModTrans		  := IIf(Type("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT") <> "U",IIf (!Empty("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT"),oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT,1),1)
			If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:OWSDPEC)=="O"
				cRetDPEC        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CXML
				cProtDPEC       := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CPROTOCOLO
			EndIf
			
			//Tratamento para gravar a hora da transmissao da NFe
			If !Empty(cProtocolo)
				oDHRecbto		:= XmlParser(cDHRecbto,"","","")
				cDtHrRec		:= IIf(Type("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
				nDtHrRec1		:= RAT("T",cDtHrRec)
				
				If nDtHrRec1 <> 0
					cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
					dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
				EndIf
				
				AtuSF2Hora(cDtHrRec1,aIdNFe[nZ][5]+aIdNFe[nZ][4]+aIdNFe[nZ][6]+aIdNFe[nZ][7])
				
			EndIf

			nY := aScan(aIdNfe,{|x| x[4]+x[5] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[4]+x[5]))})

			oWS:cIdInicial    := aIdNfe[nZ][4]+aIdNfe[nZ][5]
			oWS:cIdFinal      := aIdNfe[nZ][4]+aIdNfe[nZ][5]
			If oWS:MONITORFAIXA()
				cCodRetNFE := oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE[1]:CCODRETNFE
			EndIf

			If nY > 0
				aRetorno[nY][1] := cProtocolo
				aRetorno[nY][2] := cRetorno
				aRetorno[nY][4] := cRetDPEC
				aRetorno[nY][5] := cProtDPEC
				aRetorno[nY][6] := cDtHrRec1
				aRetorno[nY][7] := dDtRecib
				aRetorno[nY][8] := cModTrans
				aRetorno[nY][9] := cCodRetNFE
				
				//aadd(aResposta,aIdNfe[nY])
			EndIf
			cRetDPEC := ""
			cProtDPEC:= ""
		Next nX
	EndIf
Else
	Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
EndIf 
oWS       := Nil
oDHRecbto := Nil
oNFeRet   := Nil

return aRetorno[len(aRetorno)]


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GetIdEnt  ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem o codigo da entidade apos enviar o post para o Totvs  ³±±
±±³          ³Service                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo da entidade no Totvs Services                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetIdEnt()

Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
Local lUsaGesEmp := IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
Local lEnvCodEmp := GetNewPar("MV_ENVCDGE",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo da entidade                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWS := WsSPEDAdm():New()
oWS:cUSERTOKEN := "TOTVS"
	
oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
oWS:oWSEMPRESA:cFANTASIA   := IIF(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
oWS:oWSEMPRESA:cCOD_PAIS   := "1058" //brasil
oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
oWS:oWSEMPRESA:cCEP_CP     := Nil
oWS:oWSEMPRESA:cCP         := Nil
oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cINDSITESP  := ""
oWS:oWSEMPRESA:cID_MATRIZ  := ""

If lUsaGesEmp .And. lEnvCodEmp
	oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
EndIf
oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
If ExecWSRet(oWs,"ADMEMPRESAS")
	cIdEnt  := oWs:cADMEMPRESASRESULT
Else
	Aviso("NFS-e",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{'OK'},3)
EndIf

RestArea(aArea)
Return(cIdEnt)


// -----------------------------------------
// Rotina de Gerar Log
//------------------------------------------
/*
Static Function fGeraLog(cTexto,cArqLog)

// cTexto: Texto a ser incluido no arquivo
// cArqLog: Caminho+Nome do arquivo

Local nHdl    := 0
Local cArq    := cArqLog
If File(cArq) //Verifica se o arquivo existe
	nHdl := FOpen(cArq, 2) //Abre se existir
Else
	nHdl := FCreate(cArq) // Cria se nao existir
Endif

if nHdl > 0
	cTexto := cTexto + chr(13) + chr(10) // inclui fim de linha na string
	FSeek(nHdl,0,2)
	FWrite(nHdl, cTexto) // Inclui a linha que foi passada como parametro
	FClose(nHdl) 		 // Fecha o arquivo.
else
	ConOut("******************************************")
	ConOut("Base - Nao foi possivel criar arquivo " + cArq)
	ConOut("******************************************")
	ConOut("Base - Impossible create on " + cArq)
endif

Return(NIL)*/
