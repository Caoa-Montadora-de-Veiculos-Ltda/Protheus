#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CMVMSF05 ∫ Autor ≥ Jose Roberto       ∫ Data ≥  31/10/18   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Rotina para exportaÁ„o de Dados - Protheus -> Mastersaf    ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico CAOA                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Programador≥  Data   ≥ Motivo da Alteracao                             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫           ≥         ≥                                                 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function CMVMSF05

Local nOpc := 0
Local aRet := {}
//Local aCombo := {"Excel","TXT"}
Local aParamBox := {}

Private cTitulo := "ExportaÁ„o Protheus -> MasterSAF"
Private aSay := {}
Private aButton := {}
Private dDataIni := cToD("  /  /  ")
Private dDataFim := cToD("  /  /  ")
Private cLocDest := ""
Private cFileOut := ""
Private cCodFil	 := ""
Private cCodProd := ""
Private cProdDe := ""
Private cProdAte := ""
Private lSAFX07 := .F.
Private lSAFX08 := .F.
Private lSAFX09 := .F.

AAdd( aSay , "Esta Rotina tem como objetivo gerar informaÁıes do ERP Protheus " )
AAdd( aSay , "para o MasterSAF via arquivo TXT conforme documentaÁ„o tÈcnica " )
//AAdd( aSay , "Project Charter - XXXXXX")
AAdd( aSay , "")
AAdd( aSay, "Clique para continuar...")

aAdd( aButton, { 1,.T.,{|| nOpc := 1,FechaBatch()}})
aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cTitulo, aSay, aButton )

//Se Clicou no OK segue com processamento - Parambox -> MarkBrowse
If nOpc == 1
	chkfile("SZR") // verifica se a tabela existe e est· OK
	aAdd(aParamBox,{1 ,"Filial :" ,cFilant,"","","","",50,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Data Inicial:" ,Date(),"","","","",50,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Data Final :" ,Date(),"","","","",50,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Produto Inicial:" ,SPACE(15),"","","SB1","",80,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Produto Final:" ,SPACE(15),"","","SB1","",80,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Local do Arquivo:" ,"C:\TEMP\"+Space(50),"@S50","","","",100,.T.}) // Tipo caractere

	If ParamBox(aParamBox,"Parametros para geraÁ„o do Arquivo...",@aRet)
	    dDataIni := aRet[2]
	    dDataFim := aRet[3]
	    cProdDe := aRet[4]
	    cProdAte := aRet[5]
	    cLocDest := alltrim(aRet[6])
	    IF substr(cLocDest,len(cLocDest),1) <> "\"
	    	cLocDest += "\"
	    Endif
		MontaBrw()
	EndIF
EndIF

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ MontaBrw ≥ Autor | JRCARVALHO   			  ≥ Data ≥ 31/10/18           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Monta tela com a Lista das Tabelas Para IntegraÁ„o MasterSAF           ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥                                                                        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico CAOA- Interface MasterSAF                              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function MontaBrw( )

Local cArqTmp   := ""
//Local linverte 	:= .F.
Local aCmpTrb	:= {}
Local aCampos 	:= {}
//Local _aCores	:= {}

private oTempTable := FWTemporaryTable():New( "TRB" )

Private cMarca 	:= GetMark()
Private bMark   := {|| MarcaItem()}
Private cCadastro := 'SeleÁ„o de Tabelas para Exportar'
Private aRotina := {}

//Alimenta Variaveis MARKBROWSE
//Menu da tela
aRotina := {{ "Exportar"		,"U_MS05ExpTab()" 		, 0, 4},;
 			{ "Marcar Todos" 	,"U_MS05MarcaTudo()" 	, 0, 4},;
    		{ "Desmarcar Todos" ,"U_MS05DesmrkTudo()" 	, 0, 4},;
      		{ "Inverter Todos" 	,"U_MS05InvertAll()" 	, 0, 4}}

//Campos que ser„o exibidos na tela
aCampos := { {'_OK' 	,"",'OK'			},;
			{"TABELA" 	,"",'Tabela' 		},;
            {"TABDESC"	,"",'DescriÁ„o' 	} }

//Campos para criacao do arquivo temporario
aCmpTrb := { {"_OK" 	,"C",02,0},;
			{"TABELA"	,"C",08,0},;
			{"TABDESC"	,"C",75,0} }

oTemptable:SetFields( aCmpTrb )

oTempTable:AddIndex("01", {"TABELA"} )

oTempTable:Create()

// alimenta a tabela tempor·ria
Montagrid()

MarkBrow( 'TRB','_OK',,aCampos,,cMarca,,,,,,,,,,,, )

TRB->( DBCloseArea() )

oTempTable:Delete()

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ Montagrid     ∫Autor  ≥Jose Roberto   ∫ Data ≥  31/10/18   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Preenche lista da MarkBrowse                               ∫±±
±±∫          ≥ Tabela temporaria para montagem da MarkBrowse              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico CAOA- Interface MasterSAF                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function Montagrid()
Local cQuery 	:= ''

//CriaÁ„o do insert into
cQuery := "INSERT INTO " + oTempTable:GetRealName()
cQuery += " ( _OK , TABELA , TABDESC ) "
//RODA QUERY PARA LEVANTAR AS TABELAS DO CADASTRO SZR
cQuery += "SELECT DISTINCT '  ' OK , ZQ_TABELA, ZQ_DESCTB FROM "+RetSqlName("SZQ")+" WHERE D_E_L_E_T_ = ' ' AND ZQ_MSBLQL <> '1' "

//Envia o insert into para o banco de dados, portanto toda a cÛpia È feita pelo banco de dados, com grande performance!
if TCSqlExec(cQuery) < 0
    ConOut("O comando SQL gerou erro:", TCSqlError())
endif

return(Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ ExpTab        ∫Autor  ≥Jose Roberto   ∫ Data ≥  31/10/18   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Exporta Tabelas Selecionadas na MarkBrowse                 ∫±±
±±∫          ≥ 												              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico CAOA- Interface MasterSAF                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function MS05ExpTab()

Local cTabela
Local aTabela := {}
//Local nCnt := 0
Local lContinua := .T.

lSAFX07 := .F.
lSAFX08 := .F.
lSAFX09 := .F.

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

If lSAFX07 .and. !(lSAFX08 .or. lSAFX09)
	APMsgAlert("Se for marcado o arquivo 'SAFX07', deve ser marcado tambÈm o 'SAFX08' ou 'SAFX09'.")
	lContinua := .F.
Endif

If !lSAFX07 .and. (lSAFX08 .or. lSAFX09)
	APMsgAlert("Se for marcado o arquivo 'SAFX08' ou 'SAFX09', deve ser marcado tambÈm o 'SAFX07'.")
	lContinua := .F.
Endif

If !lContinua
	Return()
Endif

DbSelectArea("TRB")
DbGotop()
While ! TRB->(EOF())

	If IsMark("_OK")
		cTabela := TRB->TABELA
	    //--Se precisar gerar mais de 1 arquivo por dia
	    cTime := Time() 			   // Resultado: 10:37:17
	  	cHour := SubStr( cTime, 1, 2 ) // Resultado: 10
	  	cMin  := SubStr( cTime, 4, 2 ) // Resultado: 37
	  	cSecs := SubStr( cTime, 7, 2 ) // Resultado: 17

	  	//SAFXxx_EEE_FF_DDMMAAAA
		cFileOut := ALLTRIM(cTabela)+"_"+ALLTRIM(cEmpAnt)+ALLTRIM(cFilAnt)+"_"+dtos(DATE()) + "_" + cHour+cMin+cSecs+ ".TXT"
		FWMsgRun(, {|| GeraTXT( cTabela ) },'ExportaÁ„o Protheus -> MasterSAF','Gerando arquivo '+alltrim(cTabela)+', aguarde...')
	Endif

	DbSelectArea("TRB")
	TRB->(DBSKIP())
Enddo

Return(.T.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ GeraTXT       ∫Autor  ≥Jose Roberto   ∫ Data ≥  31/10/18   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Cria a query conforme par‚metros no Parambox               ∫±±
±±∫          ≥ 											                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥ 													          ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico CAOA- Interface MasterSAF                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function GeraTXT( cTab )

Local cQuery := ""
Local cCamposQry := ""
Local cNomeTab := padr(alltrim(cTab),10," ")
//Local aStruTXT := {}
//Local cArqTXT  := ""
//Local cString  := ""
local nHandle
//Local nCount := 0
Local cBuffer := ""
Local nTotCampos := 0
//Local cViewSQL1	:= ""
//Local cViewSQL2	:= ""
//Local cViewSQL3	:= ""
//Local cViewSQL4	:= ""
Local cFiltro	:= ""
Local lGerou  := .F.
Local x	:= 0

/*
//posiciona na SZQ - e Pega o Nome da View
DbSelectArea("SZQ")
DbSetOrder(1)
DBSeek(xFilial("SZQ")+cTab)
cViewSQL1 := ALLTRIM(SZQ->ZQ_NMVW01)

//verifica se existe amarraÁ„o com a View
If Empty(cViewSQL1) .and. Empty(cViewSQL2) .and. Empty(cViewSQL3) .and. Empty(cViewSQL4)
	MsgAlert('N„o existem VIEWS relacionadas a esta tabela - O Arquivo n„o pode ser gerado', "A T E N « √ O")
	Return
Else
	//verifica se a view existe no banco
	cQuery := ""
	//verifica se a query est· aberta
	IF Select( "CONFVW" ) > 0
		dbSelectArea( "CONFVW" )
		dbCloseArea()
	EndIF

	cString := ALLTRIM(cViewSQL1)
   	cQuery  := "SELECT * FROM ALL_OBJECTS WHERE OWNER = 'ABDHDU_PROT' AND OBJECT_TYPE = 'VIEW' AND OBJECT_NAME = '"+cString+"' "
 	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "CONFVW", .F., .T.)
	If CONFVW->(eof())
		MsgAlert("A View "+cString+" n„o existe no Banco de Dados. - O Arquivo "+upper(alltrim(cTab))+" n„o pode ser gerado", "A T E N « √ O")
		Return
	Endif
Endif

//Trata filtros nas queries - Alguns arquivos MSAF podem ser filtrados por data e outros por produto
DO Case
	Case upper(alltrim(cTab)) == "SAFX07" 	//Arquivo de Notas Fiscais
		cFiltro := " WHERE DATA_SAIDA_REC BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX08"	//Itens Notas Fiscais Mercadorias e Produtos
		cFiltro := " WHERE DATA_FISCAL BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX09"	//Itens Notas Fiscais de ServiÁos
		cFiltro := " WHERE DATA_FISCAL BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX10" 	//Arquivo de Controle de Estoque
		cFiltro := " WHERE DATA_MOVTO BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX108"	//Ordem de ProduÁ„o
		cFiltro := " WHERE DT_INI_OP >= '"+dTos(mv_par02)+"' AND DT_FIM_OP <= '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX109"	//Item da Ordem de ProduÁ„o
		cFiltro := " WHERE DT_SAIDA BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX112"	//ObservaÁıes da Nota Fiscal
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX113"	//Ajuste/Outros Valores do LanÁamento Fiscal
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX116"	//Documentos Fiscais Referenciados
		cFiltro := " WHERE DATA_FISCAL BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX118"	//Local de Coleta
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX16" 	//Arquivo de Produtos Cuja ProduÁ„o Utiliza Insumos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX17" 	//Arquivo de Insumos Utilizados na FabricaÁ„o de Produtos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX18" 	//Arquivo Referente a Embalagem
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2006"	//Tabela de Natureza de OperaÁ„o
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2009"	//Cadastro de ObservaÁıes - Ato COTEPE/ICMS 35/05
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2010"	//Tabela de Natureza de Estoque
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2013"	//Tabela de Produtos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2018"	//Tabela de CÛdigo de ServiÁos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX49" 	//Tabela das OperaÁıes de ImportaÁ„o
		cFiltro := " WHERE DAT_ENTRADA BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX52" 	//Arquivo de Invent·rio de Estoque por Produto
		cFiltro := " WHERE DATA_INVENTARIO BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX53" 	//Arquivo de Controle de Tributos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX153"	//ProduÁ„o de Terceiros
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX154"	//ProduÁ„o de Terceiros ñ Insumos Consumidos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX235"	//Tabela das CorreÁıes de Apontamento da EFD - Bloco K.
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX236"	//Tabela de Itens das CorreÁıes de Apontamento da EFD - Bloco K
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX114"	//Processos Referenciados
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX130"	//Documentos Fiscais EletrÙnicos Denegados ou Inutilizados
		cFiltro := " WHERE DATA_REF BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX245"	//Tabela dos Valores DeclaratÛrios do SPED Fiscal (E115/1925)
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX520"	//SituaÁ„o Tribut·ria complementar
		cFiltro := ""
	OtherWise
		cFiltro := ""
EndCase

//Monta query com estrutura para saida TXT
DbSelectArea("SZR")
DbSetOrder(1)
DbSeek(Xfilial("SZR")+cNomeTab)
While !SZR->(EOF()) .and. SZR->ZR_TABELA == cNomeTab
   cCamposQry := cCamposQry + Alltrim(SZR->ZR_CAMPO) + " as " + "CMP"+alltrim(SZR->ZR_ORDEM)+", "
   nTotCampos ++
   SZR->(DbSkip())
Enddo

//Ajusta variavel cCamposQRY - Remove "," no final da string
cCamposQry := substr(cCamposQry,1,Len(alltrim(cCamposQry))-1)
*/
//Cria arquivo de saida -> prepara para gravar TXT
nHandle := FCREATE(cLocDest+cFileOut)
If nHandle = -1
	MSGALERT("Erro ao criar arquivo TXT " + Str(Ferror()))
    Return()
Endif

//verifica se a query est· aberta
IF Select( "TMPSQL" ) > 0
	dbSelectArea( "TMPSQL" )
	dbCloseArea()
EndIF

//Gera query com os dados para exportar
//cQuery := ""
//cQuery := "SELECT "+cCamposQry+" FROM "+cViewSQL1
cQuery := ExecQuery(cTab)

//Monta query com estrutura para saida TXT
DbSelectArea("SZR")
DbSetOrder(1)
DbSeek(Xfilial("SZR")+cNomeTab)
While !SZR->(EOF()) .and. SZR->ZR_TABELA == cNomeTab
	// OBS: eh necessario trocar o nome original dos campos, pois alguns campos tem os 10 primeiros digitos iguais
	// e quando eh criado o temporario estes campos ficam todos com o mesmo nome, sendo entao gravado o conteudo sempre
	// do ultimo campo em todos os campos que ficaram com os 10 primeiros digitos iguais.
   	cCamposQry := cCamposQry + Alltrim(SZR->ZR_CAMPO) + " as " + "CMP"+alltrim(SZR->ZR_ORDEM)+", "
   	//cCamposQry := cCamposQry + Alltrim(SZR->ZR_CAMPO) + ", "
   	nTotCampos ++
   	SZR->(DbSkip())
Enddo

//Ajusta variavel cCamposQRY - Remove "," no final da string
cCamposQry := substr(cCamposQry,1,Len(alltrim(cCamposQry))-1)
cQuery := "SELECT "+cCamposQry+" FROM ("+cQuery+") "

MemoWrite( cLocDest+cTab+".txt", CQUERY )

If !empty(cQuery)

	IF !Empty(cFiltro)
		cQuery += cFiltro
	Endif

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPSQL", .F., .T.)
	IF !(TMPSQL)->(Eof())  // cLocDest+cFileOut
		(TMPSQL)->(DbGotop())
		While !eof()
    	    For x := 1 to TMPSQL->(FCOUNT())
	       	 	cNomeCampo := Alltrim(field(X))
	        	If Valtype(&cNomeCampo) == "N"
	         		cBuffer := cBuffer + alltrim(str(&cNomeCampo))
	         	Else
	         		cBuffer := cBuffer + alltrim(&cNomeCampo)
	         	Endif
	         	cBuffer := cBuffer + chr(9)  //adiciona um TAB
	        Next x
	        FWrite(nHandle, cBuffer + CRLF)
	        cBuffer := ""
	        TMPSQL->(DbSkip())
	        lGerou := .T.
		Enddo
	Else
		MsgAlert('A query n„o retornou registros, por favor verifique os par‚metros informados.', "A T E N « √ O")
	EndIF
Endif

FClose(nHandle)
IF lGerou
	MSGINFO("Arquivo "+ALLTRIM(cNomeTab)+" gerado com sucesso!!!")
Else
	MSGINFO("N„o foram gerados dados para este arquivo!!")
Endif

//fecha arquivos temporarios
IF Select( "TMPSQL" ) > 0
	dbSelectArea( "TMPSQL" )
	dbCloseArea()
EndIF

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ MarcaItem     ∫Autor  ≥Jose Roberto   ∫ Data ≥  31/10/18   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Seleciona os itens da MarkBrowse        					  ∫±±
±±∫          ≥ 											                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥  											              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico CAOA- Interface MasterSAF                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MarcaItem()
//Local oObj2Mark := getmarkbrow()
Local lDesmarc := IsMark("_OK", cMarca, .t.)

If !lDesmarc
   //Alert('N„o Marcou !!!')

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
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ InvertAll     ∫Autor  ≥Jose Roberto   ∫ Data ≥  31/10/18   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Inverte seleÁ„o de Itens no MarkBrowse                     ∫±±
±±∫          ≥ 											                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥  											              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - CAOA-Interface MasterSaf                 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function MS05InvertAll()

Local oObjMark:= getmarkbrow()

DbSelectArea("TRB")
TRB->(DbGoTop())
While !TRB->(EOF())
   u_MarcaItem()
   TRB->(DbSkip())
End

MarkBRefresh( )
oObjMark:oBrowse:Gotop()	// forÁa o posicionamento do browse no primeiro registro

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ MarcaTudo     ∫Autor  ≥Jose Roberto   ∫ Data ≥  31/10/18   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ FunÁ„o para marcar todos os registros do MarkBrowse        ∫±±
±±∫          ≥ 											                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥  												          ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - CAOA-Interface MasterSaf                 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function MS05MarcaTudo()

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
oMark:oBrowse:Gotop()	    // forÁa o posicionamento do browse no primeiro registro

return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ DesmrkTudo    ∫Autor  ≥Jose Roberto   ∫ Data ≥  31/10/18   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ FunÁ„o para desmarcar todos os registros do MarkBrowse     ∫±±
±±∫          ≥ 											                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥ 													          ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico CAOA- Interface MasterSAF                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function MS05DesmrkTudo()

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
oMark:oBrowse:Gotop()	// forÁa o posicionamento do browse no primeiro registro

Return

Static Function ExecQuery(cTab)

Local cQ := ""

If Alltrim(cTab) == "SAFX07"
	cQ := "SELECT DISTINCT "+CRLF
	cQ += "TRIM(SZP.ZP_EMPMS) COD_EMPRESA, "+CRLF
	cQ += "TRIM(SZP.ZP_ESTMS) COD_ESTAB, "+CRLF
	cQ += "CASE WHEN (F3_CFO < '5' AND SF3.F3_FORMUL = 'S') THEN  '4' "+CRLF
	cQ += "  WHEN (F3_CFO < '5' AND SF3.F3_FORMUL <> 'S') THEN '1' "+CRLF
	cQ += "	 WHEN (F3_CFO >= '5') THEN '9' "+CRLF
	cQ += "END MOVTO_E_S, "+CRLF
	cQ += "CASE WHEN SF3.F3_TIPO = 'D' THEN '2' ELSE '1' END NORM_DEV, "+CRLF
	cQ += "NVL(TRIM(SF3.F3_ESPECIE),'@') COD_DOCTO, "+CRLF
	cQ += "'5' IDENT_FIS_JUR, "+CRLF //VER CODIGO NA TABELA SAFX04
	cQ += "CASE WHEN (F3_CFO < '5' AND SF3.F3_TIPO IN ('D','B')) "+CRLF
	cQ += "        THEN (SELECT DECODE(TRIM(SA1.A1_XCDSAP), '','@',SA1.A1_XCDSAP) FROM SA1010 SA1 WHERE SA1.A1_COD = SF3.F3_CLIEFOR AND SA1.A1_LOJA = SF3.F3_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (F3_CFO < '5' AND SF3.F3_TIPO NOT IN ('D','B')) "+CRLF
	cQ += "        THEN (SELECT DECODE(TRIM(SA2.A2_XCDSAP), '','@',SA2.A2_XCDSAP) FROM SA2010 SA2 WHERE SA2.A2_COD = SF3.F3_CLIEFOR AND SA2.A2_LOJA = SF3.F3_LOJA AND SA2.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (F3_CFO >= '5' AND F3_TIPO IN ('D','B')) "+CRLF
	cQ += "		 	THEN (SELECT DECODE(TRIM(SA2.A2_XCDSAP), '','@',SA2.A2_XCDSAP) FROM SA2010 SA2 WHERE SA2.A2_COD = SF3.F3_CLIEFOR AND SA2.A2_LOJA = SF3.F3_LOJA AND SA2.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (F3_CFO >= '5' AND F3_TIPO NOT IN ('D','B')) "+CRLF
	cQ += "			THEN (SELECT DECODE(TRIM(SA1.A1_XCDSAP), '','@',SA1.A1_XCDSAP) FROM SA1010 SA1 WHERE SA1.A1_COD = SF3.F3_CLIEFOR AND SA1.A1_LOJA = SF3.F3_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 ELSE '@' "+CRLF
	cQ += "END COD_FIS_JUR, "+CRLF
	cQ += "SF3.F3_NFISCAL NUM_DOCFIS, "+CRLF
	cQ += "NVL(TRIM(SF3.F3_SERIE),'@') SERIE_DOCFIS, "+CRLF
	cQ += "'@' SUB_SERIE_DOCFIS, "+CRLF
	cQ += "SF3.F3_EMISSAO DATA_EMISSAO, "+CRLF
	cQ += "'1' COD_CLASS_DOC_FIS, "+CRLF
	cQ += "CASE SF3.F3_ESPECIE "+CRLF
	cQ += "WHEN 'NTST' THEN '22' "+CRLF
	cQ += "  WHEN 'NFFS' THEN '01' "+CRLF
	cQ += "  WHEN 'CTE'  THEN '57' "+CRLF
	cQ += "  WHEN 'NF'   THEN '01' "+CRLF
	cQ += "  WHEN 'SPED' THEN '55' "+CRLF
	cQ += "  WHEN 'RPS'  THEN '01' "+CRLF
	cQ += "  WHEN 'NFS'  THEN '01' "+CRLF
	cQ += "  WHEN 'NFSC' THEN '21' "+CRLF
	cQ += "  ELSE '55' END COD_MODELO, "+CRLF
	cQ += "'@' COD_CFO, "+CRLF
	cQ += "'@' COD_NATUREZA_OP, "+CRLF //SAFX2006 - SF4->F4_NATOPER de Para Sinc
	cQ += "'@' NUM_DOCFIS_REF, "+CRLF
	cQ += "'@' SERIE_DOCFIS_REF, "+CRLF
	cQ += "'@' S_SER_DOCFIS_REF, "+CRLF
	cQ += "'@' NUM_DEC_IMP_REF, "+CRLF
	cQ += "SF3.F3_ENTRADA DATA_SAIDA_REC, "+CRLF
	cQ += "'@' INSC_ESTAD_SUBSTIT, "+CRLF
	cQ += "CASE "+CRLF
	cQ += " WHEN F3_CFO < '5' THEN NVL((SELECT TO_CHAR(SF1.F1_VALMERC * 100) FROM SF1010 SF1 WHERE SF1.F1_FILIAL = SF3.F3_FILIAL AND SF1.F1_DOC = SF3.F3_NFISCAL AND SF1.F1_SERIE = SF3.F3_SERIE AND SF1.F1_FORNECE = SF3.F3_CLIEFOR AND SF1.F1_LOJA = SF3.F3_LOJA AND SF1.D_E_L_E_T_ = ' ') ,'@') "+CRLF
	cQ += "	WHEN F3_CFO >= '5' THEN NVL((SELECT TO_CHAR(SF2.F2_VALMERC * 100) FROM SF2010 SF2 WHERE SF2.F2_FILIAL = SF3.F3_FILIAL AND SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_SERIE = SF3.F3_SERIE AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR AND SF2.F2_LOJA = SF3.F3_LOJA AND SF2.D_E_L_E_T_ = ' ') ,'@') "+CRLF
	cQ += "END VLR_PRODUTO, "+CRLF
	cQ += "CASE "+CRLF
	cQ += "	WHEN F3_CFO < '5' THEN NVL((SELECT TO_CHAR(SF1.F1_VALBRUT * 100) FROM SF1010 SF1 WHERE SF1.F1_FILIAL = SF3.F3_FILIAL AND SF1.F1_DOC = SF3.F3_NFISCAL AND SF1.F1_SERIE = SF3.F3_SERIE AND SF1.F1_FORNECE = SF3.F3_CLIEFOR AND SF1.F1_LOJA = SF3.F3_LOJA AND SF1.D_E_L_E_T_ = ' ') ,'@') "+CRLF
	cQ += "	WHEN F3_CFO >= '5' THEN NVL((SELECT TO_CHAR(SF2.F2_VALBRUT * 100) FROM SF2010 SF2 WHERE SF2.F2_FILIAL = SF3.F3_FILIAL AND SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_SERIE = SF3.F3_SERIE AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR AND SF2.F2_LOJA = SF3.F3_LOJA AND SF2.D_E_L_E_T_ = ' ') ,'@') "+CRLF
	cQ += "END VLR_TOT_NOTA, "+CRLF
	cQ += "CASE "+CRLF
	cQ += "	WHEN F3_CFO < '5' THEN NVL((SELECT TO_CHAR(SF1.F1_FRETE * 100) FROM SF1010 SF1 WHERE SF1.F1_FILIAL = SF3.F3_FILIAL AND SF1.F1_DOC = SF3.F3_NFISCAL AND SF1.F1_SERIE = SF3.F3_SERIE AND SF1.F1_FORNECE = SF3.F3_CLIEFOR AND SF1.F1_LOJA = SF3.F3_LOJA AND SF1.D_E_L_E_T_ = ' ') ,'@') "+CRLF
	cQ += "	WHEN F3_CFO >= '5' THEN NVL((SELECT TO_CHAR(SF2.F2_FRETE * 100) FROM SF2010 SF2 WHERE SF2.F2_FILIAL = SF3.F3_FILIAL AND SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_SERIE = SF3.F3_SERIE AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR AND SF2.F2_LOJA = SF3.F3_LOJA AND SF2.D_E_L_E_T_ = ' ') ,'@') "+CRLF
	cQ += "END VLR_FRETE, "+CRLF
	cQ += "CASE "+CRLF
	cQ += "	WHEN F3_CFO < '5' THEN NVL((SELECT TO_CHAR(SF1.F1_SEGURO * 100) FROM SF1010 SF1 WHERE SF1.F1_FILIAL = SF3.F3_FILIAL AND SF1.F1_DOC = SF3.F3_NFISCAL AND SF1.F1_SERIE = SF3.F3_SERIE AND SF1.F1_FORNECE = SF3.F3_CLIEFOR AND SF1.F1_LOJA = SF3.F3_LOJA AND SF1.D_E_L_E_T_ = ' ') ,'@') "+CRLF
	cQ += "	WHEN F3_CFO >= '5' THEN NVL((SELECT TO_CHAR(SF2.F2_SEGURO * 100) FROM SF2010 SF2 WHERE SF2.F2_FILIAL = SF3.F3_FILIAL AND SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_SERIE = SF3.F3_SERIE AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR AND SF2.F2_LOJA = SF3.F3_LOJA AND SF2.D_E_L_E_T_ = ' ') ,'@') "+CRLF
	cQ += "END VLR_SEGURO, "+CRLF
	cQ += "CASE "+CRLF
	cQ += "	WHEN F3_CFO < '5' THEN NVL((SELECT TO_CHAR(SF1.F1_DESPESA * 100) FROM SF1010 SF1 WHERE SF1.F1_FILIAL = SF3.F3_FILIAL AND SF1.F1_DOC = SF3.F3_NFISCAL AND SF1.F1_SERIE = SF3.F3_SERIE AND SF1.F1_FORNECE = SF3.F3_CLIEFOR AND SF1.F1_LOJA = SF3.F3_LOJA AND SF1.D_E_L_E_T_ = ' ') ,'@') "+CRLF
	cQ += "	ELSE '@' "+CRLF
	cQ += "END VLR_OUTRAS, "+CRLF
	cQ += "'@' VLR_BASE_DIF_FRETE, "+CRLF
	cQ += "CASE "+CRLF
	cQ += "	WHEN F3_CFO < '5' THEN NVL((SELECT TO_CHAR(SF1.F1_DESCONT * 100) FROM SF1010 SF1 WHERE SF1.F1_FILIAL = SF3.F3_FILIAL AND SF1.F1_DOC = SF3.F3_NFISCAL AND SF1.F1_SERIE = SF3.F3_SERIE AND SF1.F1_FORNECE = SF3.F3_CLIEFOR AND SF1.F1_LOJA = SF3.F3_LOJA AND SF1.D_E_L_E_T_ = ' ') ,'@') "+CRLF
	cQ += "	WHEN F3_CFO >= '5' THEN NVL((SELECT TO_CHAR(SF2.F2_DESCONT * 100) FROM SF2010 SF2 WHERE SF2.F2_FILIAL = SF3.F3_FILIAL AND SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_SERIE = SF3.F3_SERIE AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR AND SF2.F2_LOJA = SF3.F3_LOJA AND SF2.D_E_L_E_T_ = ' ') ,'@') "+CRLF
	cQ += "END VLR_DESCONTO, "+CRLF
	cQ += "'@' CONTRIB_FINAL, "+CRLF
	cQ += "CASE WHEN SF3.F3_OBSERV = 'NF CANCELADA' AND SF3.F3_DTCANC <> ' ' THEN 'S' ELSE 'N' END SITUACAO, "+CRLF
	cQ += "'@' COD_INDICE, "+CRLF
	cQ += "'@' VLR_NOTA_CONV, "+CRLF
	cQ += "'@' COD_CONTA, "+CRLF
	cQ += "DECODE( SF3.F3_ALIQICM, 0, '@', TO_CHAR(SF3.F3_ALIQICM * 100)) VLR_ALIQ_ICMS, "+CRLF
	cQ += "DECODE( SF3.F3_VALICM , 0, '@', TO_CHAR(SF3.F3_VALICM * 100))  VLR_ICMS, "+CRLF
	cQ += "'@' DIF_ALIQ_ICMS, "+CRLF
	cQ += "'@' OBS_ICMS, "+CRLF
	cQ += "'@' COD_APUR_ICMS, "+CRLF
	cQ += "DECODE( SF3.F3_ALIQIPI, 0, '@', TO_CHAR(SF3.F3_ALIQIPI * 100)) VLR_ALIQ_IPI, "+CRLF
	cQ += "DECODE( SF3.F3_VALIPI , 0, '@', TO_CHAR(SF3.F3_VALIPI * 100)) VLR_IPI, "+CRLF
	cQ += "'@' OBS_IPI, "+CRLF
	cQ += "'@' COD_APUR_IPI, "+CRLF
	cQ += "CASE "+CRLF
	cQ += "	WHEN F3_CFO >= '5' THEN NVL((SELECT TO_CHAR(MAX(SD2.D2_ALQIRRF) * 100) FROM SD2010 SD2 WHERE SD2.D2_FILIAL = SF3.F3_FILIAL AND SD2.D2_DOC = SF3.F3_NFISCAL AND SD2.D2_SERIE = SF3.F3_SERIE AND SD2.D_E_L_E_T_ = ' '), '@') "+CRLF
	cQ += "	ELSE '@' "+CRLF
	cQ += "END VLR_ALIQ_IR, "+CRLF
	cQ += "CASE "+CRLF
	cQ += "WHEN F3_CFO >= '5' THEN NVL((SELECT TO_CHAR(SF2.F2_VALIRRF * 100) FROM SF2010 SF2 WHERE SF2.F2_FILIAL = SF3.F3_FILIAL AND SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_SERIE = SF3.F3_SERIE AND SF2.D_E_L_E_T_ = ' '), '@') "+CRLF
	cQ += "	ELSE '@' "+CRLF
	cQ += "END VLR_IR, "+CRLF
	cQ += "(SELECT TO_CHAR(MAX(D2_ALIQISS) * 100) FROM SD2010 SD2 WHERE SD2.D2_FILIAL = SF3.F3_FILIAL AND SD2.D2_DOC = SF3.F3_NFISCAL AND SD2.D2_SERIE = SF3.F3_SERIE AND SD2.D2_CLIENTE = SF3.F3_CLIEFOR AND SD2.D_E_L_E_T_ = ' ') VLR_ALIQ_ISS, "+CRLF
	cQ += "CASE "+CRLF
	cQ += "	WHEN F3_CFO >= '5' THEN NVL((SELECT TO_CHAR(SF2.F2_VALISS * 100) FROM SF2010 SF2 WHERE SF2.F2_FILIAL = SF3.F3_FILIAL AND SF2.F2_DOC = SF3.F3_NFISCAL AND SF2.F2_SERIE = SF3.F3_SERIE AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR AND SF2.D_E_L_E_T_ = ' '), '@') "+CRLF
	cQ += "	ELSE '@' "+CRLF
	cQ += "END VLR_ISS, "+CRLF
	cQ += "'@' VLR_ALIQ_SUB_ICMS, "+CRLF
	cQ += "NVL(SOL.CD2_VLTRIB * 100,'0') VLR_SUBST_ICMS, "+CRLF
	cQ += "'@' OBS_SUBST_ICMS, "+CRLF
	cQ += "'@' COD_APUR_SUB_ICMS, "+CRLF
	cQ += "SF3.F3_VALCONT * 100 BASE_TRIB_ICMS, "+CRLF
	cQ += "SF3.F3_ISENICM * 100 BASE_ISEN_ICMS, "+CRLF
	cQ += "SF3.F3_OUTRICM * 100 BASE_OUTR_ICMS, "+CRLF
	cQ += "'@' BASE_REDU_ICMS, "+CRLF
	cQ += "SF3.F3_BASEIPI * 100 BASE_TRIB_IPI, "+CRLF
	cQ += "SF3.F3_ISENIPI * 100 BASE_ISEN_IPI, "+CRLF
	cQ += "SF3.F3_OUTRIPI * 100 BASE_OUTR_IPI, "+CRLF
	cQ += "'@' BASE_REDU_IPI, "+CRLF
	cQ += "'@' BASE_TRIB_IR, "+CRLF //(SF2.F2_BASEIRR * 100)
	cQ += "'@' BASE_ISEN_IR, "+CRLF
	cQ += "'@' BASE_TRIB_ISS, "+CRLF //(SF2.F2_BASEISS * 100)
	cQ += "'@' BASE_ISEN_ISS, "+CRLF
	cQ += "'@' BASE_REAL_TERC_ISS, "+CRLF
	cQ += "NVL(SOL.CD2_BC,'0') * 100 BASE_SUB_TRIB_ICMS, "+CRLF
	cQ += "'@' NUM_MAQ_REG, "+CRLF
	cQ += "'@' NUM_CUPON_FISC, "+CRLF
	cQ += "'@' IND_MODELO_CUPOM, "+CRLF
	cQ += "'@' VLR_CONTAB_COMPL, "+CRLF
	cQ += "SF3.R_E_C_N_O_ NUM_CONTROLE_DOCTO, "+CRLF
	cQ += "'@' VLR_ALIQ_DESTINO, "+CRLF
	cQ += "'@' IND_NF_ESPECIAL, "+CRLF
	cQ += "'@' IND_TP_FRETE, "+CRLF
	cQ += "'@' COD_MUNICIPIO, "+CRLF
	cQ += "'@' IND_TRANSF_CRED, "+CRLF
	cQ += "'@' DAT_DI, "+CRLF
	cQ += "'@' VLR_TOM_SERVICO, "+CRLF
	cQ += "'@' DAT_ESCR_EXTEMP, "+CRLF
	cQ += "'@' COD_TRIB_INT, "+CRLF
	cQ += "'@' COD_REGIAO, "+CRLF
	cQ += "'@' DAT_AUTENTIC, "+CRLF //N√O PRECISA … APENAS PARA AMAZONAS
	cQ += "'@' COD_CANAL_DISTRIB, "+CRLF
	cQ += "'N' IND_CRED_ICMSS, "+CRLF //QUANDO FOR CREDITO DE ICMS_ST
	cQ += "'@' VLR_ICMS_NDESTAC, "+CRLF
	cQ += "'@' VLR_IPI_NDESTAC, "+CRLF
	cQ += "'@' VLR_BASE_INSS, "+CRLF
	cQ += "'@' VLR_ALIQ_INSS, "+CRLF
	cQ += "'@' VLR_INSS_RETIDO, "+CRLF
	cQ += "'@' VLR_MAT_APLIC_ISS, "+CRLF
	cQ += "'@' VLR_SUBEMPR_ISS, "+CRLF
	cQ += "'@' IND_MUNIC_ISS, "+CRLF
	cQ += "'@' IND_CLASSE_OP_ISS, "+CRLF
	cQ += "'@' VLR_OUTROS1, "+CRLF
	cQ += "'@' DAT_FATO_GERADOR, "+CRLF
	cQ += "'@' DAT_CANCELAMENTO, "+CRLF
	cQ += "'@' NUM_PAGINA, "+CRLF
	cQ += "'@' NUM_LIVRO, "+CRLF
	cQ += "'@' NRO_AIDF_NF, "+CRLF
	cQ += "'@' DAT_VALID_DOC_AIDF, "+CRLF
	cQ += "'1' IND_FATURA, "+CRLF
	cQ += "'@' COD_QUITACAO, "+CRLF
	cQ += "'@' NUM_SELO_CONT_ICMS, "+CRLF
	cQ += "SF3.F3_BASIMP6 * 100 VLR_BASE_PIS, "+CRLF
	cQ += "SF3.F3_VALIMP6 * 100 VLR_PIS, "+CRLF
	cQ += "SF3.F3_BASIMP5 * 100 VLR_BASE_COFINS, "+CRLF
	cQ += "SF3.F3_VALIMP5 * 100 VLR_COFINS, "+CRLF
	cQ += "'@' BASE_ICMS_ORIGDEST, "+CRLF
	cQ += "'@' VLR_ICMS_ORIGDEST, "+CRLF
	cQ += "'@' ALIQ_ICMS_ORIGDEST, "+CRLF
	cQ += "'@' VLR_DESC_CONDIC, "+CRLF
	cQ += "'@' VLR_BASE_ISE_ICMSS, "+CRLF
	cQ += "'@' VLR_BASE_OUT_ICMSS, "+CRLF
	cQ += "'@' VLR_RED_BASE_ICMSS, "+CRLF
	cQ += "'@' PERC_RED_BASE_ICMS, "+CRLF
	cQ += "'@' IND_FISJUR_CPDIR, "+CRLF
	cQ += "'@' COD_FISJUR_CPDIR, "+CRLF
	cQ += "'@' IND_MEDIDAJUDICIAL, "+CRLF
	cQ += "'@' UF_ORIG_DEST, "+CRLF
	cQ += "'VD' IND_COMPRA_VENDA, "+CRLF
	cQ += "'@' COD_TP_DISP_SEG, "+CRLF
	cQ += "'@' NUM_CTR_DISP, "+CRLF
	cQ += "'@' NUM_FIM_DOCTO, "+CRLF
	cQ += "'@' UF_DESTINO, "+CRLF
	cQ += "'@' SERIE_CTR_DISP, "+CRLF
	cQ += "'@' SUB_SERIE_CTR_DISP, "+CRLF
	cQ += "'@' IND_SITUACAO_ESP, "+CRLF
	cQ += "'@' INSC_ESTADUAL, "+CRLF
	cQ += "'@' COD_PAGTO_INSS, "+CRLF
	cQ += "'@' DAT_INTERN_AM, "+CRLF
	cQ += "'@' IND_FISJUR_LSG, "+CRLF
	cQ += "'@' COD_FISJUR_LSG, "+CRLF
	cQ += "'@' COMPROV_EXP, "+CRLF
	cQ += "'@' NUM_FINAL_CRT_DISP, "+CRLF
	cQ += "'@' NUM_ALVARA, "+CRLF
	cQ += "'@' NOTIFICA_SEFAZ, "+CRLF
	cQ += "'@' INTERNA_SUFRAMA, "+CRLF
	cQ += "'@' COD_AMPARO, "+CRLF
	cQ += "' ' IND_NOTA_SERVICO, "+CRLF
	cQ += "'@' COD_MOTIVO, "+CRLF
	cQ += "'@' UF_AMPARO_LEGAL, "+CRLF
	cQ += "'@' OBS_COMPL_MOTIVO, "+CRLF
	cQ += "'@' IND_TP_RET, "+CRLF
	cQ += "'@' IND_TP_TOMADOR, "+CRLF
	cQ += "'@' COD_ANTEC_ST, "+CRLF
	cQ += "'@' CNPJ_ARMAZ_ORIG, "+CRLF
	cQ += "'@' UF_ARMAZ_ORIG, "+CRLF
	cQ += "'@' INS_EST_ARMAZ_ORIG, "+CRLF
	cQ += "'@' CNPJ_ARMAZ_DEST, "+CRLF
	cQ += "'@' UF_ARMAZ_DEST, "+CRLF
	cQ += "'@' INS_EST_ARMAZ_DEST, "+CRLF
	cQ += "'@' OBS_INF_ADIC_NF, "+CRLF
	cQ += "'@' VLR_BASE_INSS_2, "+CRLF
	cQ += "'@' VLR_ALIQ_INSS_2, "+CRLF
	cQ += "'@' VLR_INSS_RETIDO_2, "+CRLF
	cQ += "'@' COD_PAGTO_INSS_2, "+CRLF
	cQ += "'@' VLR_BASE_PIS_ST, "+CRLF
	cQ += "'@' VLR_ALIQ_PIS_ST, "+CRLF
	cQ += "'@' VLR_PIS_ST, "+CRLF
	cQ += "'@' VLR_BASE_COFINS_ST, "+CRLF
	cQ += "'@' VLR_ALIQ_COFINS_ST, "+CRLF
	cQ += "'@' VLR_COFINS_ST, "+CRLF
	cQ += "'@' VLR_BASE_CSLL, "+CRLF
	cQ += "'@' VLR_ALIQ_CSLL, "+CRLF
	cQ += "'@' VLR_CSLL, "+CRLF
	cQ += "'@' VLR_ALIQ_PIS, "+CRLF
	cQ += "'@' VLR_ALIQ_COFINS, "+CRLF
	cQ += "'@' BASE_ICMSS_SUBSTITUIDO, "+CRLF //SOMENTE COMPRAS
	cQ += "'@' VLR_ICMSS_SUBSTITUIDO, "+CRLF //SOMENTE COMPRAS
	cQ += "'@' IND_SITUACAO_ESP_ST, "+CRLF
	cQ += "'@' VLR_ICMSS_NDESTAC, "+CRLF
	cQ += "'@' IND_DOCTO_REC, "+CRLF
	cQ += "'@' DAT_PGTO_GNRE_DARJ, "+CRLF
	cQ += "'@' COD_CEI, "+CRLF
	cQ += "'@' VLR_JUROS_INSS, "+CRLF
	cQ += "'@' VLR_MULTA_INSS, "+CRLF
	cQ += "'@' DT_PAGTO_NF, "+CRLF
	cQ += "'@' HORA_SAIDA, "+CRLF
	cQ += "'@' COD_SIT_DOCFIS, "+CRLF
	cQ += "'@' COD_OBSERVACAO, "+CRLF
	cQ += "'@' COD_SITUACAO_A, "+CRLF
	cQ += "'@' COD_SITUACAO_B, "+CRLF
	cQ += "'@' NUM_CONT_REDUC, "+CRLF
	cQ += "'@' COD_MUNICIPIO_ORIG, "+CRLF
	cQ += "'@' COD_MUNICIPIO_DEST, "+CRLF
	cQ += "'@' COD_CFPS, "+CRLF
	cQ += "'@' NUM_LANCAMENTO, "+CRLF
	cQ += "'@' VLR_MAT_PROP, "+CRLF
	cQ += "'@' VLR_MAT_TERC, "+CRLF
	cQ += "'@' VLR_BASE_ISS_RETIDO, "+CRLF
	cQ += "'@' VLR_ISS_RETIDO, "+CRLF
	cQ += "'@' VLR_DEDUCAO_ISS, "+CRLF
	cQ += "'@' COD_MUNIC_ARMAZ_ORIG, "+CRLF
	cQ += "'@' INS_MUNIC_ARMAZ_ORIG, "+CRLF
	cQ += "'@' COD_MUNIC_ARMAZ_DEST, "+CRLF
	cQ += "'@' INS_MUNIC_ARMAZ_DEST, "+CRLF
	cQ += "'@' COD_CLASSE_CONSUMO, "+CRLF
	cQ += "'@' IND_ESPECIF_RECEITA, "+CRLF
	cQ += "'@' NUM_CONTRATO, "+CRLF
	cQ += "'@' COD_AREA_TERMINAL, "+CRLF
	cQ += "'@' COD_TP_UTIL, "+CRLF
	cQ += "'@' GRUPO_TENSAO, "+CRLF
	cQ += "'@' DATA_CONSUMO_INI, "+CRLF
	cQ += "'@' DATA_CONSUMO_FIM, "+CRLF
	cQ += "'@' DATA_CONSUMO_LEIT, "+CRLF
	cQ += "'@' QTD_CONTRATADA_PONTA, "+CRLF
	cQ += "'@' QTD_CONTRATADA_FPONTA, "+CRLF
	cQ += "'@' QTD_CONSUMO_TOTAL, "+CRLF
	cQ += "'@' UF_CONSUMO, "+CRLF
	cQ += "'@' COD_MUNIC_CONSUMO, "+CRLF
	cQ += "'@' COD_OPER_ESP_ST, "+CRLF
	cQ += "'@' ATO_NORMATIVO, "+CRLF
	cQ += "'@' NUM_ATO_NORMATIVO, "+CRLF
	cQ += "'@' ANO_ATO_NORMATIVO, "+CRLF
	cQ += "'@' CAPITULACAO_NORMA, "+CRLF
	cQ += "'@' VLR_OUTRAS_ENTID, "+CRLF
	cQ += "'@' VLR_TERCEIROS, "+CRLF
	cQ += "'@' IND_TP_COMPL_ICMS, "+CRLF
	cQ += "'@' VLR_BASE_CIDE, "+CRLF
	cQ += "'@' VLR_ALIQ_CIDE, "+CRLF
	cQ += "'@' VLR_CIDE, "+CRLF
	cQ += "'@' COD_VERIFIC_NFE, "+CRLF
	cQ += "'@' COD_TP_RPS_NFE, "+CRLF
	cQ += "'@' NUM_RPS_NFE, "+CRLF
	cQ += "'@' SERIE_RPS_NFE, "+CRLF
	cQ += "'@' DAT_EMISSAO_RPS_NFE, "+CRLF
	cQ += "'@' DSC_SERVICO_NFE, "+CRLF
	cQ += "DECODE( TRIM(SF3.F3_CHVNFE), '', '@',SF3.F3_CHVNFE) NUM_AUTENTIC_NFE, "+CRLF
	cQ += "'@' NUM_DV_NFE, "+CRLF
	cQ += "'@' MODELO_NF_DMS, "+CRLF
	cQ += "'@' COD_MODELO_COTEPE, "+CRLF
	cQ += "'@' VLR_COMISSAO, "+CRLF
	cQ += "'@' IND_NFE_DENEG_INUT, "+CRLF
	cQ += "'@' IND_NF_REG_ESPECIAL, "+CRLF
	cQ += "'@' VLR_ABAT_NTRIBUTADO, "+CRLF
	cQ += "'@' VLR_OUTROS_ICMS, "+CRLF
	cQ += "'@' HORA_EMISSAO, "+CRLF
	cQ += "'@' OBS_DADOS_FATURA, "+CRLF
	cQ += "'@' IND_FIS_CONCES, "+CRLF
	cQ += "'@' COD_FIS_CONCES, "+CRLF
	cQ += "'@' COD_AUTENTIC, "+CRLF
	cQ += "'@' IND_PORT_CAT44, "+CRLF
	cQ += "'@' VLR_BASE_INSS_RURAL, "+CRLF
	cQ += "'@' VLR_ALIQ_INSS_RURAL, "+CRLF
	cQ += "'@' VLR_INSS_RURAL, "+CRLF
	cQ += "'@' COD_CLASSE_CONSUMO_SEF_PE, "+CRLF
	cQ += "'@' VLR_PIS_RETIDO, "+CRLF
	cQ += "'@' VLR_COFINS_RETIDO, "+CRLF
	cQ += "'@' DAT_LANC_PIS_COFINS, "+CRLF
	cQ += "'@' IND_PIS_COFINS_EXTEMP, "+CRLF
	cQ += "'@' COD_SIT_PIS, "+CRLF
	cQ += "'@' COD_SIT_COFINS, "+CRLF
	cQ += "'@' IND_NAT_FRETE, "+CRLF
	cQ += "'@' COD_NAT_REC, "+CRLF
	cQ += "'@' IND_VENDA_CANC, "+CRLF
	cQ += "'@' IND_NAT_BASE_CRED, "+CRLF
	cQ += "'@' IND_NF_CONTINGENCIA , "+CRLF
	cQ += "'@' VLR_ACRESCIMO, "+CRLF
	cQ += "'@' VLR_ANTECIP_TRIB , "+CRLF
	cQ += "'@' IND_IPI_NDESTAC_DF, "+CRLF
	cQ += "'@' DSC_RESERVADO1, "+CRLF
	cQ += "'@' DSC_RESERVADO2, "+CRLF
	cQ += "'@' DSC_RESERVADO3, "+CRLF
	cQ += "'@' NUM_NFTS, "+CRLF
	cQ += "'@' IND_NF_VENDA_TERCEIROS, "+CRLF
	cQ += "'@' DSC_RESERVADO4, "+CRLF
	cQ += "'@' DSC_RESERVADO5, "+CRLF
	cQ += "'@' DSC_RESERVADO6, "+CRLF
	cQ += "'@' DSC_RESERVADO7, "+CRLF
	cQ += "'@' DSC_RESERVADO8, "+CRLF
	cQ += "'@' IDENTIF_DOCFIS, "+CRLF
	cQ += "'@' COD_SISTEMA_ORIG, "+CRLF
	cQ += "'@' COD_SCP, "+CRLF
	cQ += "'@' IND_PREST_SERV, "+CRLF
	cQ += "'@' IND_TIPO_PROC, "+CRLF
	cQ += "'@' NUM_PROC_JUR, "+CRLF
	cQ += "'@' IND_DEC_PROC, "+CRLF
	cQ += "'@' IND_TIPO_AQUIS, "+CRLF
	cQ += "'@' VLR_DESC_GILRAT, "+CRLF
	cQ += "'@' VLR_DESC_SENAR, "+CRLF
	cQ += "'@' CNPJ_SUBEMPREITEIRO, "+CRLF
	cQ += "'@' CNPJ_CPF_PROPRIETARIO_CNO, "+CRLF
	cQ += "'@' VLR_RET_SUBEMPREITADO, "+CRLF
	cQ += "'@' NUM_DOCFIS_SERV, "+CRLF
	cQ += "'@' VLR_FCP_UF_DEST, "+CRLF
	cQ += "'@' VLR_ICMS_UF_DEST, "+CRLF
	cQ += "'@' VLR_ICMS_UF_ORIG, "+CRLF
	cQ += "'@' VLR_CONTRIB_PREV, "+CRLF
	cQ += "'@' VLR_GILRAT, "+CRLF
	cQ += "'@' VLR_CONTRIB_SENAR, "+CRLF
	cQ += "'@' CPF_CNPJ, "+CRLF
	cQ += "'@' NUM_CERTIF_QUAL, "+CRLF
	cQ += "'@' OBS_REINF, "+CRLF
	cQ += "'@' VLR_TOT_ADIC, "+CRLF
	cQ += "'@' VLR_RET_SERV, "+CRLF
	cQ += "'@' VLR_SERV_15, "+CRLF
	cQ += "'@' VLR_SERV_20, "+CRLF
	cQ += "'@' VLR_SERV_25 "+CRLF
	cQ += "FROM SF3010 SF3 "+CRLF
	cQ += "LEFT OUTER JOIN SZP010 SZP ON SZP.ZP_CODFIL = SF3.F3_FILIAL AND SZP.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "LEFT OUTER JOIN CD2010 SOL ON SOL.CD2_IMP = 'SOL' AND SOL.CD2_FILIAL = SF3.F3_FILIAL "+CRLF
	cQ += "      AND SOL.CD2_DOC = SF3.F3_NFISCAL AND SOL.CD2_SERIE = SF3.F3_SERIE AND SOL.CD2_CODCLI = SF3.F3_CLIEFOR "+CRLF
	cQ += "      AND SOL.CD2_LOJCLI = SF3.F3_LOJA AND SOL.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "WHERE SF3.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "AND F3_ENTRADA BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "+CRLF
	cQ += "AND F3_DTCANC = ' ' "+CRLF
	If lSAFX08 .and. !lSAFX09
		cQ += "AND F3_TIPO <> 'S' "+CRLF
	Endif
	If !lSAFX08 .and. lSAFX09
		cQ += "AND F3_TIPO = 'S' "+CRLF
	Endif
	cQ += "ORDER BY F3_ENTRADA,F3_NFISCAL "+CRLF
Endif

If Alltrim(cTab) == "SAFX08"
	cQ := "Select DISTINCT "+CRLF
	cQ += "TRIM(SZP.ZP_EMPMS) COD_EMPRESA, "+CRLF
	cQ += "TRIM(SZP.ZP_ESTMS) COD_ESTAB, "+CRLF
	cQ += "SFT.FT_ENTRADA DATA_FISCAL, "+CRLF
	cQ += "CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SF3.F3_FORMUL = 'S') THEN  '4' "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'E' AND SF3.F3_FORMUL <> 'S') THEN '1' "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S') THEN '9' "+CRLF
	cQ += "END MOVTO_E_S, "+CRLF
	cQ += "CASE WHEN SF3.F3_TIPO = 'D' THEN '2' ELSE '1' END NORM_DEV, "+CRLF
	cQ += "NVL(TRIM(SF3.F3_ESPECIE),'@') COD_DOCTO, "+CRLF
	cQ += "'5' IND_FIS_JUR, "+CRLF //VER CODIGO NA TABELA SAFX04
	cQ += "CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SF3.F3_TIPO IN ('D','B')) "+CRLF
	cQ += "        THEN (SELECT DECODE(TRIM(SA1.A1_XCDSAP), '','@',SA1.A1_XCDSAP) FROM SA1010 SA1 WHERE SA1.A1_COD = SF3.F3_CLIEFOR AND SA1.A1_LOJA = SF3.F3_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'E' AND SF3.F3_TIPO NOT IN ('D','B')) "+CRLF
	cQ += "        THEN (SELECT DECODE(TRIM(SA2.A2_XCDSAP), '','@',SA2.A2_XCDSAP) FROM SA2010 SA2 WHERE SA2.A2_COD = SF3.F3_CLIEFOR AND SA2.A2_LOJA = SF3.F3_LOJA AND SA2.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S' AND F3_TIPO IN ('D','B')) "+CRLF
	cQ += "		 	THEN (SELECT DECODE(TRIM(SA2.A2_XCDSAP), '','@',SA2.A2_XCDSAP) FROM SA2010 SA2 WHERE SA2.A2_COD = SF3.F3_CLIEFOR AND SA2.A2_LOJA = SF3.F3_LOJA AND SA2.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S' AND F3_TIPO NOT IN ('D','B')) "+CRLF
	cQ += "			THEN (SELECT DECODE(TRIM(SA1.A1_XCDSAP), '','@',SA1.A1_XCDSAP) FROM SA1010 SA1 WHERE SA1.A1_COD = SF3.F3_CLIEFOR AND SA1.A1_LOJA = SF3.F3_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 ELSE '@' "+CRLF
	cQ += "END COD_FIS_JUR, "+CRLF
	cQ += "FT_NFISCAL NUM_DOCFIS, "+CRLF
	cQ += "NVL(TRIM(FT_SERIE),'@') SERIE_DOCFIS, "+CRLF
	cQ += "'@' SUB_SERIE_DOCFIS, "+CRLF
	cQ += "'N' IND_BEM_PATR, "+CRLF
	cQ += "CASE SB1.B1_TIPO WHEN 'PA' THEN '1' "+CRLF
	cQ += "   WHEN 'AI' THEN '1' "+CRLF
	cQ += "   WHEN 'MP' THEN '2' "+CRLF
	cQ += "   WHEN 'ME' THEN '3' "+CRLF
	cQ += "   WHEN 'MC' THEN '4' "+CRLF
	cQ += "   WHEN 'PI' THEN '7' "+CRLF
	cQ += "   ELSE '5' END IND_PRODUTO, "+CRLF
	cQ += "trim(SFT.FT_PRODUTO) COD_PRODUTO, "+CRLF
	cQ += "'@' COD_BEM, "+CRLF
	cQ += "'@' COD_INC_BEM, "+CRLF
	cQ += "SB1.B1_UM COD_UND_PADRAO, "+CRLF
	cQ += "SFT.FT_ITEM NUM_ITEM, "+CRLF
	cQ += "SB1.B1_LOCPAD COD_ALMOX, "+CRLF
	cQ += "CASE WHEN SB1.B1_CC = ' ' THEN '@' ELSE trim(SB1.B1_CC) END COD_CUSTO, "+CRLF
	cQ += "'@' DESCRICAO_COMPL, "+CRLF
	cQ += "TRIM(SFT.FT_CFOP) COD_CFO, "+CRLF
	cQ += "'@' COD_NATUREZA_OP, "+CRLF //BUSCAR DO CAMPO SF4 "
	cQ += "(SFT.FT_QUANT * 100 ) QUANTIDADE, "+CRLF
	cQ += "SB1.B1_UM COD_MEDIDA, "+CRLF
	cQ += "CASE SB1.B1_POSIPI WHEN '00000000' THEN '@' "+CRLF
	cQ += "     WHEN ' ' THEN '@' ELSE SB1.B1_POSIPI END COD_NBM, "+CRLF
	cQ += "(round(SFT.FT_PRCUNIT,4) * 100) VLR_UNIT, "+CRLF
	cQ += "(SFT.FT_TOTAL * 100) VLR_ITEM, "+CRLF
	cQ += "(SFT.FT_DESCONT * 100) VLR_DESCONTO, "+CRLF
	cQ += "SB1.B1_ORIGEM COD_SITUACAO_A, "+CRLF
	cQ += "SFT.FT_CLASFIS COD_SITUACAO_B, "+CRLF
	cQ += "'@' COD_FEDERAL, "+CRLF
	cQ += "'@' IND_IPI_INCLUSO, "+CRLF
	cQ += "'@' NUM_ROMANEIO, "+CRLF
	cQ += "'@' DATA_ROMANEIO, "+CRLF
	cQ += "'@' PESO_LIQUIDO, "+CRLF
	cQ += "'@' COD_INDICE, "+CRLF
	cQ += "'@' VLR_ITEM_CONVER, "+CRLF
	cQ += "SFT.FT_FRETE * 100 VLR_FRETE, "+CRLF
	cQ += "'@' VLR_SEGURO, "+CRLF
	cQ += "(SFT.FT_OUTRICM * 100) VLR_OUTRAS, "+CRLF
	cQ += "(SFT.FT_ALIQICM * 100) VLR_ALIQ_ICMS, "+CRLF
	cQ += "(SFT.FT_VALICM *100) VLR_ICMS, "+CRLF
	cQ += "'@' DIF_ALIQ_ICMS, "+CRLF
	cQ += "'@' OBS_ICMS, "+CRLF
	cQ += "'@' COD_APUR_ICMS, "+CRLF
	cQ += "(SFT.FT_ALIQIPI * 100) VLR_ALIQ_IPI, "+CRLF
	cQ += "(SFT.FT_VALIPI * 100) VLR_IPI, "+CRLF
	cQ += "'@' OBS_IPI, "+CRLF
	cQ += "'@' COD_APUR_IPI, "+CRLF
	cQ += "(SFT.FT_ALIQSOL * 100) VLR_ALIQ_SUB_ICMS, "+CRLF
	cQ += "(SFT.FT_ICMSRET * 100) VLR_SUBST_ICMS, "+CRLF
	cQ += "'@' OBS_SUBST_ICMS, "+CRLF
	cQ += "'@' COD_APUR_SUB_ICMS, "+CRLF
	cQ += "CASE WHEN (SFT.FT_BASEICM > 0 ) THEN '1' "+CRLF
	cQ += "     WHEN (SFT.FT_BASEICM = 0 AND SFT.FT_ISENICM > 0 ) THEN '2' "+CRLF
	cQ += "     WHEN (SFT.FT_BASEICM = 0 AND SFT.FT_ISENICM = 0 AND SFT.FT_OUTRICM > 0 ) THEN '3' "+CRLF
	cQ += "     ELSE '3' END TRIB_ICMS, "+CRLF //VER NO CADASTRO DE TES
	cQ += "CASE WHEN (SFT.FT_BASEICM > 0 ) THEN (SFT.FT_BASEICM *100) "+CRLF
	cQ += "     WHEN (SFT.FT_BASEICM = 0 AND SFT.FT_ISENICM > 0 ) THEN (SFT.FT_ISENICM * 100) "+CRLF
	cQ += "     WHEN (SFT.FT_BASEICM = 0 AND SFT.FT_ISENICM = 0 AND SFT.FT_OUTRICM > 0 ) THEN (SFT.FT_OUTRICM * 100) "+CRLF
	cQ += "     ELSE (SFT.FT_BASEICM * 100) END BASE_ICMS, "+CRLF
	cQ += "'@' BASE_REDU_ICMS, "+CRLF
	cQ += "CASE WHEN (SFT.FT_BASEIPI > 0) THEN '1' "+CRLF
	cQ += "     WHEN (SFT.FT_BASEIPI = 0 AND SFT.FT_ISENIPI > 0 ) THEN '2' "+CRLF
	cQ += "     WHEN (SFT.FT_BASEIPI = 0 AND SFT.FT_ISENIPI = 0 AND SFT.FT_OUTRIPI > 0 ) THEN '3' "+CRLF
	cQ += "     ELSE '3' END TRIB_IPI, "+CRLF
	cQ += "CASE WHEN (SFT.FT_BASEIPI > 0 ) THEN (SFT.FT_BASEIPI *100 ) "+CRLF
	cQ += "     WHEN (SFT.FT_BASEIPI = 0 AND SFT.FT_ISENIPI > 0 ) THEN (SFT.FT_ISENIPI * 100) "+CRLF
	cQ += "     WHEN (SFT.FT_BASEIPI = 0 AND SFT.FT_ISENIPI = 0 AND SFT.FT_OUTRIPI > 0 ) THEN (SFT.FT_OUTRIPI * 100) "+CRLF
	cQ += "     ELSE (SFT.FT_BASEIPI *100) END BASE_IPI, "+CRLF
	cQ += "'@' BASE_REDU_IPI, "+CRLF
	cQ += "(SFT.FT_BASERET * 100) BASE_SUB_TRIB_ICMS, "+CRLF
	cQ += "'@' VLR_CONTAB_COMPL, "+CRLF
	cQ += "'@' VLR_ALIQ_DESTINO, "+CRLF
	cQ += "(SFT.FT_VALCONT * 100) VLR_CONTAB_ITEM, "+CRLF
	cQ += "'@' COD_OBS_VCONT_COMP, "+CRLF
	cQ += "'@' COD_OBS_VCONT_ITEM, "+CRLF
	cQ += "'@' VLR_OUTROS_ICMS, "+CRLF
	cQ += "'@' VLR_OUTROS_IPI, "+CRLF
	cQ += "'@' VLR_OUTROS1, "+CRLF
	cQ += "'@' NUM_ATO_CONCES, "+CRLF
	cQ += "'@' DAT_EMBARQUE, "+CRLF
	cQ += "'@' NUM_REG_EXP, "+CRLF
	cQ += "'@' NUM_DESP_EXP, "+CRLF
	cQ += "'@' VLR_TOM_SERVICO, "+CRLF
	cQ += "'@' VLR_DESP_MOEDA_EXP, "+CRLF
	cQ += "'@' COD_MOEDA_NEGOC, "+CRLF
	cQ += "'@' COD_PAIS_DEST_ORIG, "+CRLF
	cQ += "'@' IND_CRED_ICMSS, "+CRLF
	cQ += "'@' COD_TRIB_INT, "+CRLF
	cQ += "'@' VLR_ICMS_NDESTAC, "+CRLF
	cQ += "'@' VLR_IPI_NDESTAC, "+CRLF
	cQ += "CASE WHEN (SFT.FT_BASEICM > 0 AND SFT.FT_ISENICM > 0 ) THEN '2' "+CRLF
	cQ += "     WHEN (SFT.FT_BASEICM > 0 AND SFT.FT_OUTRICM > 0 ) THEN '3' "+CRLF
	cQ += "     ELSE '@' END TRIB_ICMS_AUX, "+CRLF
	cQ += "CASE WHEN (SFT.FT_BASEICM > 0 AND SFT.FT_ISENICM > 0 ) THEN (SFT.FT_ISENICM * 100) "+CRLF
	cQ += "     WHEN (SFT.FT_BASEICM > 0 AND SFT.FT_OUTRICM > 0 ) THEN (SFT.FT_OUTRICM * 100) "+CRLF
	cQ += "     ELSE 0 END BASE_ICMS_AUX, "+CRLF
	cQ += "CASE WHEN (SFT.FT_BASEIPI > 0 AND SFT.FT_ISENIPI > 0 ) THEN '2' "+CRLF
	cQ += "     WHEN (SFT.FT_BASEIPI > 0 AND SFT.FT_OUTRIPI > 0 ) THEN '3' "+CRLF
	cQ += "     ELSE '@' END TRIB_IPI_AUX, "+CRLF
	cQ += "CASE WHEN (SFT.FT_BASEIPI > 0 AND SFT.FT_ISENIPI > 0 ) THEN (SFT.FT_ISENIPI * 100) "+CRLF
	cQ += "     WHEN (SFT.FT_BASEIPI > 0 AND SFT.FT_OUTRIPI > 0 ) THEN (SFT.FT_OUTRIPI * 100) "+CRLF
	cQ += "     ELSE 0 END BASE_IPI_AUX, "+CRLF
	cQ += "'@' VLR_BASE_PIS, "+CRLF
	cQ += "'@' VLR_PIS, "+CRLF
	cQ += "'@' VLR_BASE_COFINS, "+CRLF
	cQ += "'@' VLR_COFINS, "+CRLF
	cQ += "'@' BASE_ICMS_ORIGDEST, "+CRLF
	cQ += "'@' VLR_ICMS_ORIGDEST, "+CRLF
	cQ += "'@' ALIQ_ICMS_ORIGDEST, "+CRLF
	cQ += "'@' VLR_DESC_CONDIC, "+CRLF
	cQ += "'@' TRIB_ICMSS, "+CRLF
	cQ += "'@' BASE_REDU_ICMSS, "+CRLF
	cQ += "'@' VLR_CUSTO_TRANSF, "+CRLF
	cQ += "'@' PERC_RED_BASE_ICMS, "+CRLF
	cQ += "'@' QTD_EMBARCADA, "+CRLF
	cQ += "'@' DAT_REGISTRO_EXP, "+CRLF
	cQ += "'@' DAT_DESPACHO, "+CRLF
	cQ += "'@' DAT_AVERBACAO, "+CRLF
	cQ += "'@' DAT_DI, "+CRLF
	cQ += "'@' NUM_DEC_IMP_REF, "+CRLF
	cQ += "'@' DSC_MOT_OCOR, "+CRLF
	cQ += "'@' COD_CONTA, "+CRLF
	cQ += "'@' VLR_BASE_ICMS_ORIG, "+CRLF
	cQ += "'@' VLR_TRIB_ICMS_ORIG, "+CRLF
	cQ += "'@' VLR_BASE_ICMS_DEST, "+CRLF
	cQ += "'@' VLR_TRIB_ICMS_DEST, "+CRLF
	cQ += "'@' VLR_PERC_PRES_ICMS, "+CRLF
	cQ += "'@' VLR_PRECO_BASE_ST, "+CRLF
	cQ += "'@' COD_OPER_OIL, "+CRLF
	cQ += "'@' COD_DCR, "+CRLF
	cQ += "'@' COD_PROJETO, "+CRLF
	cQ += "'@' IND_MOV_FIS, "+CRLF
	cQ += "'@' CHASSI, "+CRLF
	cQ += "'@' NUM_DOCFIS_REF, "+CRLF
	cQ += "'@' SERIE_DOCFIS_REF, "+CRLF
	cQ += "'@' SSERIE_DOCFIS_REF, "+CRLF
	cQ += "'@' VLR_BASE_PIS_ST, "+CRLF
	cQ += "'@' VLR_ALIQ_PIS_ST, "+CRLF
	cQ += "'@' VLR_PIS_ST, "+CRLF
	cQ += "'@' VLR_BASE_COFINS_ST, "+CRLF
	cQ += "'@' VLR_ALIQ_COFINS_ST, "+CRLF
	cQ += "'@' VLR_COFINS_ST, "+CRLF
	cQ += "'@' VLR_BASE_CSLL, "+CRLF
	cQ += "'@' VLR_ALIQ_CSLL, "+CRLF
	cQ += "'@' VLR_CSLL, "+CRLF
	cQ += "'@' VLR_ALIQ_PIS, "+CRLF
	cQ += "'@' VLR_ALIQ_COFINS, "+CRLF
	cQ += "'@' IND_FORNEC_ICMSS, "+CRLF
	cQ += "'@' IND_SITUACAO_ESP_ST, "+CRLF
	cQ += "'@' VLR_ICMSS_NDESTAC, "+CRLF
	cQ += "'@' IND_DOCTO_REC, "+CRLF
	cQ += "'@' DAT_PGTO_GNRE_DARJ, "+CRLF
	cQ += "'@' VLR_CUSTO_UNIT, "+CRLF
	cQ += "'@' QUANTIDADE_CONV, "+CRLF
	cQ += "'@' VLR_FECP_ICMS, "+CRLF
	cQ += "'@' VLR_FECP_DIFALIQ, "+CRLF
	cQ += "'@' VLR_FECP_ICMS_ST, "+CRLF
	cQ += "'@' VLR_FECP_FONTE, "+CRLF
	cQ += "'@' TRIB_ICMSS_AUX2, "+CRLF
	cQ += "'@' BASE_ICMSS_AUX2, "+CRLF
	cQ += "'@' VLR_BASE_ICMSS_N_ESCRIT, "+CRLF
	cQ += "'@' VLR_ICMSS_N_ESCRIT, "+CRLF
	cQ += "'@' COD_TRIB_IPI, "+CRLF
	cQ += "'@' LOTE_MEDICAMENTO, "+CRLF
	cQ += "'@' VALID_MEDICAMENTO, "+CRLF
	cQ += "'@' IND_BASE_MEDICAMENTO, "+CRLF
	cQ += "'@' VLR_PRECO_MEDICAMENTO, "+CRLF
	cQ += "'@' IND_TIPO_ARMA, "+CRLF
	cQ += "'@' NUM_SERIE_ARMA, "+CRLF
	cQ += "'@' NUM_CANO_ARMA, "+CRLF
	cQ += "'@' DSC_ARMA, "+CRLF
	cQ += "'@' COD_OBSERVACAO, "+CRLF
	cQ += "'@' COD_EX_NCM, "+CRLF
	cQ += "'@' COD_EX_IMP, "+CRLF
	cQ += "'@' CNPJ_OPERADORA, "+CRLF
	cQ += "'@' CPF_OPERADORA, "+CRLF
	cQ += "'@' UF_OPERADORA, "+CRLF
	cQ += "'@' INS_EST_OPERADORA, "+CRLF
	cQ += "'@' IND_ESPECIF_RECEITA, "+CRLF
	cQ += "'@' COD_CLASS_ITEM, "+CRLF
	cQ += "'@' VLR_TERCEIROS, "+CRLF
	cQ += "'@' VLR_PRECO_SUGER, "+CRLF
	cQ += "'@' VLR_BASE_CIDE, "+CRLF
	cQ += "'@' VLR_ALIQ_CIDE, "+CRLF
	cQ += "'@' VLR_CIDE, "+CRLF
	cQ += "'@' COD_OPER_ESP_ST, "+CRLF
	cQ += "'@' VLR_COMISSAO, "+CRLF
	cQ += "'@' VLR_ICMS_FRETE, "+CRLF
	cQ += "'@' VLR_DIFAL_FRETE, "+CRLF
	cQ += "'@' IND_VLR_PIS_COFINS, "+CRLF
	cQ += "'@' COD_ENQUAD_IPI, "+CRLF
	cQ += "'@' COD_SITUACAO_PIS, "+CRLF
	cQ += "'@' QTD_BASE_PIS, "+CRLF
	cQ += "'@' VLR_ALIQ_PIS_R, "+CRLF
	cQ += "'@' COD_SITUACAO_COFINS, "+CRLF
	cQ += "'@' QTD_BASE_COFINS, "+CRLF
	cQ += "'@' VLR_ALIQ_COFINS_R, "+CRLF
	cQ += "'@' ITEM_PORT_TARE, "+CRLF
	cQ += "'@' VLR_FUNRURAL, "+CRLF
	cQ += "'@' IND_TP_PROD_MEDIC, "+CRLF
	cQ += "'@' VLR_CUSTO_DCA, "+CRLF
	cQ += "'@' COD_TP_LANCTO, "+CRLF
	cQ += "'@' VLR_PERC_CRED_OUT, "+CRLF
	cQ += "'@' VLR_CRED_OUT, "+CRLF
	cQ += "'@' VLR_ICMS_DCA, "+CRLF
	cQ += "'@' VLR_PIS_EXP, "+CRLF
	cQ += "'@' VLR_PIS_TRIB, "+CRLF
	cQ += "'@' VLR_PIS_N_TRIB, "+CRLF
	cQ += "'@' VLR_COFINS_EXP, "+CRLF
	cQ += "'@' VLR_COFINS_TRIB, "+CRLF
	cQ += "'@' VLR_COFINS_N_TRIB, "+CRLF
	cQ += "'@' COD_ENQ_LEGAL, "+CRLF
	cQ += "'@' DAT_LANC_PIS_COFINS, "+CRLF
	cQ += "'@' IND_PIS_COFINS_EXTEMP, "+CRLF
	cQ += "'@' IND_NATUREZA_FRETE, "+CRLF
	cQ += "'@' COD_NAT_REC, "+CRLF
	cQ += "'@' IND_NAT_BASE_CRED, "+CRLF
	cQ += "'@' VLR_ACRESCIMO , "+CRLF
	cQ += "'@' IND_IPI_NDESTAC_DF, "+CRLF
	cQ += "'@' DSC_RESERVADO1, "+CRLF
	cQ += "'@' DSC_RESERVADO2, "+CRLF
	cQ += "'@' DSC_RESERVADO3, "+CRLF
	cQ += "'@' COD_TRIB_PROD, "+CRLF
	cQ += "'@' DSC_RESERVADO4, "+CRLF
	cQ += "'@' DSC_RESERVADO5, "+CRLF
	cQ += "'@' DSC_RESERVADO6, "+CRLF
	cQ += "'@' DSC_RESERVADO7, "+CRLF
	cQ += "'@' DSC_RESERVADO8, "+CRLF
	cQ += "'@' INDICE_PROD_ACAB, "+CRLF
	cQ += "'@' VLR_BASE_DIA_AM, "+CRLF
	cQ += "'@' VLR_ALIQ_DIA_AM, "+CRLF
	cQ += "'@' VLR_ICMS_DIA_AM, "+CRLF
	cQ += "'@' VLR_ADUANEIRO, "+CRLF
	cQ += "'@' COD_SITUACAO_PIS_ST, "+CRLF
	cQ += "'@' COD_SITUACAO_COFINS_ST, "+CRLF
	cQ += "'@' VLR_ALIQ_DCIP, "+CRLF
	cQ += "'@' NUM_LI, "+CRLF
	cQ += "'@' VLR_FCP_UF_DEST, "+CRLF
	cQ += "'@' VLR_ICMS_UF_DEST, "+CRLF
	cQ += "'@' VLR_ICMS_UF_ORIG, "+CRLF
	cQ += "'@' VLR_DIF_DUB, "+CRLF
	cQ += "'@' VLR_ICMS_NAO_DEST, "+CRLF
	cQ += "'@' VLR_BASE_ICMS_NAO_DEST, "+CRLF
	cQ += "'@' VLR_ALIQ_ICMS_NAO_DEST, "+CRLF
	cQ += "'@' IND_MOTIVO_RES, "+CRLF
	cQ += "'@' NUM_DOCFIS_RET, "+CRLF
	cQ += "'@' SERIE_DOCFIS_RET, "+CRLF
	cQ += "'@' NUM_AUTENTIC_NFE_RET, "+CRLF
	cQ += "'@' NUM_ITEM_RET, "+CRLF
	cQ += "'@' IND_FIS_JUR_RET, "+CRLF
	cQ += "'@' COD_FIS_JUR_RET, "+CRLF
	cQ += "'@' IND_TP_DOC_ARREC, "+CRLF
	cQ += "'@' NUM_DOC_ARREC, "+CRLF
	cQ += "'@' COD_CFO_DCIP, "+CRLF
	cQ += "'@' VLR_BASE_INSS, "+CRLF
	cQ += "'@' VLR_INSS_RETIDO, "+CRLF
	cQ += "'@' VLR_TOT_ADIC, "+CRLF
	cQ += "'@' VLR_N_RET_PRINC, "+CRLF
	cQ += "'@' VLR_N_RET_ADIC, "+CRLF
	cQ += "'@' VLR_ALIQ_INSS, "+CRLF
	cQ += "'@' VLR_RET_SERV, "+CRLF
	cQ += "'@' VLR_SERV_15, "+CRLF
	cQ += "'@' VLR_SERV_20, "+CRLF
	cQ += "'@' VLR_SERV_25, "+CRLF
	cQ += "'@' IND_TP_PROC_ADJ_PRINC, "+CRLF
	cQ += "'@' NUM_PROC_ADJ_PRINC, "+CRLF
	cQ += "'@' COD_SUSP_PRINC, "+CRLF
	cQ += "'@' IND_TP_PROC_ADJ_ADIC, "+CRLF
	cQ += "'@' NUM_PROC_ADJ_ADIC, "+CRLF
	cQ += "'@' COD_SUSP_ADIC "+CRLF
	cQ += "FROM SFT010 SFT "+CRLF
	cQ += "INNER JOIN SB1010 SB1 ON B1_COD = FT_PRODUTO AND SB1.D_E_L_E_T_ = ' ' AND SUBSTR(FT_FILIAL,1,6) = TRIM(B1_FILIAL) "+CRLF
	cQ += "INNER JOIN SF4010 SF4 ON SF4.F4_CODIGO = SFT.FT_TES AND SF4.D_E_L_E_T_ = ' ' AND SUBSTR(FT_FILIAL,1,6) = TRIM(F4_FILIAL) "+CRLF
	cQ += "INNER JOIN SF3010 SF3 ON SF3.F3_FILIAL = SFT.FT_FILIAL AND  SF3.F3_NFISCAL = SFT.FT_NFISCAL AND SF3.F3_SERIE = SFT.FT_SERIE "+CRLF
	cQ += "           AND SF3.F3_CLIEFOR = SFT.FT_CLIEFOR AND SF3.F3_LOJA = SFT.FT_LOJA AND F3_TIPO <> 'S' AND F3_DTCANC = ' ' AND SF3.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "LEFT OUTER JOIN SZP010 SZP ON SZP.ZP_CODFIL = SF3.F3_FILIAL AND SZP.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "WHERE SFT.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "AND FT_TIPO <> 'S' "+CRLF
	cQ += "AND FT_ENTRADA BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "+CRLF
	cQ += "ORDER BY FT_ENTRADA,FT_NFISCAL "+CRLF
Endif

If Alltrim(cTab) == "SAFX09"
	cQ := "SELECT DISTINCT "+CRLF
	cQ += "TRIM(SZP.ZP_EMPMS) COD_EMPRESA, "+CRLF
	cQ += "TRIM(SZP.ZP_ESTMS) COD_ESTAB, "+CRLF
	cQ += "SFT.FT_ENTRADA DATA_FISCAL, "+CRLF
	cQ += "CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SF3.F3_FORMUL = 'S') THEN  '4' "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'E' AND SF3.F3_FORMUL <> 'S') THEN '1' "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S') THEN '9' "+CRLF
	cQ += "END MOVTO_E_S, "+CRLF
	cQ += "CASE WHEN SF3.F3_TIPO = 'D' THEN '2' ELSE '1' END NORM_DEV, "+CRLF
	cQ += "NVL(TRIM(SF3.F3_ESPECIE),'@') COD_DOCTO, "+CRLF
	cQ += "'5' IND_FIS_JUR, "+CRLF //VER CODIGO NA TABELA SAFX04
	cQ += "CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SF3.F3_TIPO IN ('D','B')) "+CRLF
	cQ += "        THEN (SELECT DECODE(TRIM(SA1.A1_XCDSAP), '','@',SA1.A1_XCDSAP) FROM SA1010 SA1 WHERE SA1.A1_COD = SF3.F3_CLIEFOR AND SA1.A1_LOJA = SF3.F3_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'E' AND SF3.F3_TIPO NOT IN ('D','B')) "+CRLF
	cQ += "        THEN (SELECT DECODE(TRIM(SA2.A2_XCDSAP), '','@',SA2.A2_XCDSAP) FROM SA2010 SA2 WHERE SA2.A2_COD = SF3.F3_CLIEFOR AND SA2.A2_LOJA = SF3.F3_LOJA AND SA2.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S' AND F3_TIPO IN ('D','B')) "+CRLF
	cQ += "		 	THEN (SELECT DECODE(TRIM(SA2.A2_XCDSAP), '','@',SA2.A2_XCDSAP) FROM SA2010 SA2 WHERE SA2.A2_COD = SF3.F3_CLIEFOR AND SA2.A2_LOJA = SF3.F3_LOJA AND SA2.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S' AND F3_TIPO NOT IN ('D','B')) "+CRLF
	cQ += "			THEN (SELECT DECODE(TRIM(SA1.A1_XCDSAP), '','@',SA1.A1_XCDSAP) FROM SA1010 SA1 WHERE SA1.A1_COD = SF3.F3_CLIEFOR AND SA1.A1_LOJA = SF3.F3_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 ELSE '@' "+CRLF
	cQ += "END COD_FIS_JUR, "+CRLF
	cQ += "SFT.FT_NFISCAL NUM_DOCFIS, "+CRLF
	cQ += "NVL(TRIM(SFT.FT_SERIE),'@') SERIE_DOCFIS, "+CRLF
	cQ += "'@' SUB_SERIE_DOCFIS, "+CRLF
	cQ += "trim(SFT.FT_PRODUTO) COD_SERVICO, "+CRLF
	cQ += "SFT.FT_ITEM NUM_ITEM, "+CRLF
	cQ += "(round(SFT.FT_PRCUNIT,4) * 100) VLR_SERVICO, "+CRLF
	cQ += "(SFT.FT_TOTAL * 100) VLR_TOT, "+CRLF
	cQ += "'@' DESCRICAO_COMPL, "+CRLF
	cQ += "TRIM(SFT.FT_CFOP) COD_CFO, "+CRLF
	cQ += "'@' COD_NATUREZA_OP, "+CRLF
	cQ += "(SFT.FT_QUANT * 100 ) QUANTIDADE, "+CRLF
	cQ += "ROUND(SFT.FT_PRCUNIT,2) * 100 VLR_UNIT, "+CRLF
	cQ += "(SFT.FT_DESCONT * 100) VLR_DESCONTO, "+CRLF
	cQ += "'@' CONTRATO, "+CRLF
	cQ += "'@' COD_INDICE, "+CRLF
	cQ += "'@' VLR_SERVICO_CONV, "+CRLF
	cQ += "'@' VLR_ALIQ_ICMS, "+CRLF
	cQ += "'@' VLR_ICMS, "+CRLF
	cQ += "'@' DIF_ALIQ_ICMS, "+CRLF
	cQ += "'@' OBS_ICMS, "+CRLF
	cQ += "'@' COD_APUR_ICMS, "+CRLF
	cQ += "CASE WHEN SFT.FT_BASEIRR > 0 THEN (SFT.FT_ALIQIRR * 100) ELSE 0 END VLR_ALIQ_IR, "+CRLF
	cQ += "CASE WHEN SFT.FT_BASEIRR > 0 THEN (SFT.FT_VALIRR * 100) ELSE 0 END VLR_IR, "+CRLF
	cQ += "CASE WHEN ISS.CD2_ALIQ > 0 THEN (ISS.CD2_ALIQ * 100) ELSE 0 END VLR_ALIQ_ISS, "+CRLF
	cQ += "CASE WHEN ISS.CD2_ALIQ > 0 THEN (ISS.CD2_VLTRIB * 100) ELSE 0 END VLR_ISS, "+CRLF
	cQ += "'@' TRIB_ICMS, "+CRLF
	cQ += "'@' BASE_ICMS, "+CRLF
	cQ += "CASE WHEN SFT.FT_BASEIRR > 0 THEN '1' ELSE '@' END TRIB_IR, "+CRLF
	cQ += "(SFT.FT_BASEIRR * 100) BASE_IR, "+CRLF
	cQ += "'@' TRIB_ISS, "+CRLF //CASE WHEN SD1.D1_BASEISS > 0 THEN '1' ELSE '@' END TRIB_ISS,
	cQ += "'@' BASE_ISS, "+CRLF //(SD1.D1_BASEISS * 100) BASE_ISS,
	cQ += "'@' IND_PRODUTO, "+CRLF
	cQ += "'@' COD_PRODUTO, "+CRLF
	cQ += "'@' COMPL_ISENCAO, "+CRLF
	cQ += "(SFT.FT_BASECSL*100) VLR_BASE_CSLL, "+CRLF
	cQ += "(SFT.FT_ALIQCSL*100) VLR_ALIQ_CSLL, "+CRLF
	cQ += "(SFT.FT_VALCSL*100) VLR_CSLL, "+CRLF
	cQ += "(SFT.FT_BASIMP6*100) VLR_BASE_PIS, "+CRLF
	cQ += "(SFT.FT_ALQIMP6*100) VLR_ALIQ_PIS, "+CRLF
	cQ += "(SFT.FT_VALIMP6*100) VLR_PIS, "+CRLF
	cQ += "(SFT.FT_BASIMP5*100) VLR_BASE_COFINS, "+CRLF
	cQ += "(SFT.FT_ALQIMP5*100) VLR_ALIQ_COFINS, "+CRLF
	cQ += "(SFT.FT_VALIMP5*100) VLR_COFINS, "+CRLF
	cQ += "'@' COD_CONTA, "+CRLF
	cQ += "'@' COD_OBSERVACAO, "+CRLF
	cQ += "F3_CSTISS COD_TRIB_ISS, "+CRLF
	cQ += "'@' VLR_MAT_PROP, "+CRLF
	cQ += "'@' VLR_MAT_TERC, "+CRLF
	cQ += "'@' VLR_BASE_ISS_RETIDO, "+CRLF //(SD1.D1_BASEISS * 100) VLR_BASE_ISS_RETIDO
	cQ += "'@' VLR_ISS_RETIDO, "+CRLF //(SD1.D1_VALISS * 100) VLR_ISS_RETIDO
	cQ += "'@' VLR_DEDUCAO_ISS, "+CRLF
	cQ += "'@' VLR_SUBEMPR_ISS, "+CRLF
	cQ += "'@' COD_CFPS, "+CRLF //(F4_CFPS)
	cQ += "'@' VLR_OUT_DESP, "+CRLF
	cQ += "'@' VLR_BASE_CIDE, "+CRLF
	cQ += "'@' VLR_ALIQ_CIDE, "+CRLF
	cQ += "'@' VLR_CIDE, "+CRLF
	cQ += "'@' VLR_COMISSAO, "+CRLF
	cQ += "'N' IND_VLR_PIS_COFINS, "+CRLF
	cQ += "'01' COD_SITUACAO_PIS, "+CRLF
	cQ += "'01' COD_SITUACAO_COFINS, "+CRLF
	cQ += "'@' VLR_PIS_EXP, "+CRLF
	cQ += "'@' VLR_PIS_TRIB, "+CRLF
	cQ += "'@' VLR_PIS_N_TRIB, "+CRLF
	cQ += "'@' VLR_COFINS_EXP, "+CRLF
	cQ += "'@' VLR_COFINS_TRIB, "+CRLF
	cQ += "'@' VLR_COFINS_N_TRIB, "+CRLF
	cQ += "'@' VLR_BASE_INSS, "+CRLF
	cQ += "'@' VLR_INSS_RETIDO, "+CRLF
	cQ += "'@' VLR_ALIQ_INSS, "+CRLF
	cQ += "'@' VLR_PIS_RETIDO, "+CRLF
	cQ += "'@' VLR_COFINS_RETIDO, "+CRLF
	cQ += "'@' DAT_LANC_PIS_COFINS, "+CRLF
	cQ += "'@' IND_PIS_COFINS_EXTEMP, "+CRLF
	cQ += "'0' IND_LOCAL_EXEC_SERV, "+CRLF
	cQ += "'@' COD_CUSTO, "+CRLF
	cQ += "'@' COD_NAT_REC, "+CRLF
	cQ += "'@' IND_NAT_BASE_CRED, "+CRLF
	cQ += "'@' VLR_ACRESCIMO , "+CRLF
	cQ += "'@' DSC_RESERVADO1, "+CRLF
	cQ += "'@' DSC_RESERVADO2, "+CRLF
	cQ += "'@' DSC_RESERVADO3, "+CRLF
	cQ += "'@' COD_NBS, "+CRLF
	cQ += "'@' VLR_TOT_ADIC, "+CRLF
	cQ += "'@' VLR_TOT_RET, "+CRLF
	cQ += "'@' VLR_DEDUCAO_NF, "+CRLF
	cQ += "'@' VLR_RET_NF, "+CRLF
	cQ += "'@' VLR_RET_SERV, "+CRLF
	cQ += "'@' VLR_ALIQ_ISS_RETIDO, "+CRLF
	cQ += "'@' COD_SIT_TRIB_ISS, "+CRLF
	cQ += "'@' VLR_N_RET_PRINC, "+CRLF
	cQ += "'@' VLR_N_RET_ADIC, "+CRLF
	cQ += "'@' VLR_DED_ALIM, "+CRLF
	cQ += "'@' VLR_DED_TRANS, "+CRLF
	cQ += "'@' IND_TP_PROC_ADJ_PRINC, "+CRLF
	cQ += "'@' NUM_PROC_ADJ_PRINC, "+CRLF
	cQ += "'@' COD_SUSP_PRINC, "+CRLF
	cQ += "'@' IND_TP_PROC_ADJ_ADIC, "+CRLF
	cQ += "'@' NUM_PROC_ADJ_ADIC, "+CRLF
	cQ += "'@' COD_SUSP_ADIC, "+CRLF
	cQ += "'@' VLR_SERV_15, "+CRLF
	cQ += "'@' VLR_SERV_20, "+CRLF
	cQ += "'@' VLR_SERV_25 "+CRLF
	cQ += "FROM SFT010 SFT "+CRLF
	cQ += "INNER JOIN SF3010 SF3 ON SF3.F3_FILIAL = SFT.FT_FILIAL AND  SF3.F3_NFISCAL = SFT.FT_NFISCAL AND SF3.F3_SERIE = SFT.FT_SERIE "+CRLF
	cQ += "           AND SF3.F3_CLIEFOR = SFT.FT_CLIEFOR AND SF3.F3_LOJA = SFT.FT_LOJA AND F3_TIPO = 'S' AND F3_DTCANC = ' ' AND SF3.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "LEFT OUTER JOIN SZP010 SZP ON SZP.ZP_CODFIL = SFT.FT_FILIAL AND SZP.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "INNER JOIN CD2010 ISS ON ISS.CD2_IMP = 'ISS' AND ISS.CD2_FILIAL = SFT.FT_FILIAL "+CRLF
	cQ += "      AND ISS.CD2_DOC = SFT.FT_NFISCAL AND ISS.CD2_SERIE = SFT.FT_SERIE AND ISS.CD2_TPMOV = SFT.FT_TIPOMOV "+CRLF
	cQ += "	     AND ISS.CD2_ITEM = SFT.FT_ITEM AND ISS.CD2_CODPRO = SFT.FT_PRODUTO AND ISS.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "WHERE SFT.FT_TIPO = 'S' AND SFT.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "AND FT_ENTRADA BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "+CRLF
	cQ += "ORDER BY FT_ENTRADA,FT_NFISCAL "+CRLF
Endif

If Alltrim(cTab) == "SAFX10"
	cQ := "SELECT DISTINCT "+CRLF
	cQ += "TRIM(SZP.ZP_EMPMS) COD_EMPRESA, "+CRLF
	cQ += "TRIM(SZP.ZP_ESTMS) COD_ESTAB, "+CRLF
	cQ += "CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_FORMUL = 'S') THEN  '4' "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_FORMUL <> 'S') THEN '1' "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S') THEN '9' "+CRLF
	cQ += "END MOVTO_E_S, "+CRLF
	cQ += "CASE WHEN SFT.FT_TIPO IN ('D','B') THEN '2' ELSE '1' END NORM_DEV, "+CRLF
	cQ += "'1' GRUPO_CONTAGEM, "+CRLF
	cQ += "NVL(TRIM(SFT.FT_ESPECIE),'@') COD_DOCTO, "+CRLF
	cQ += "SFT.FT_ENTRADA DATA_MOVTO, "+CRLF
	cQ += "SFT.FT_NFISCAL NUM_DOCTO, "+CRLF
	cQ += "NVL(TRIM(SFT.FT_SERIE),'@') SERIE_DOCFIS, "+CRLF
	cQ += "'@' SUB_SERIE_DOCFIS, "+CRLF
	cQ += "CASE SB1.B1_TIPO WHEN 'PA' THEN '1' "+CRLF
	cQ += "   WHEN 'AI' THEN '1' "+CRLF
	cQ += "   WHEN 'MP' THEN '2' "+CRLF
	cQ += "   WHEN 'ME' THEN '3' "+CRLF
	cQ += "   WHEN 'MC' THEN '4' "+CRLF
	cQ += "   WHEN 'PI' THEN '7' "+CRLF
	cQ += "   ELSE '5' END IND_PRODUTO, "+CRLF
	cQ += "trim(SFT.FT_PRODUTO) COD_PRODUTO, "+CRLF
	cQ += "SB1.B1_UM COD_UND_PADRAO, "+CRLF
	cQ += "SB1.B1_LOCPAD COD_ALMOX, "+CRLF
	cQ += "CASE WHEN SB1.B1_CC = ' ' THEN '@' ELSE trim(SB1.B1_CC) END COD_CUSTO, "+CRLF
	cQ += "SFT.FT_ITEM NUM_ITEM, "+CRLF
	cQ += "SB1.B1_LOCPAD COD_NAT_ESTOQUE, "+CRLF
	cQ += "'@' CONTRATO, "+CRLF
	cQ += "'@' SERIE_ITEM, "+CRLF
	cQ += "(SFT.FT_QUANT * 100 ) QTD_MOVTO, "+CRLF
	cQ += "(round(SFT.FT_PRCUNIT,4) * 100) PRECO_UNIT, "+CRLF
	cQ += "(SFT.FT_TOTAL * 100)  PRECO_ITEM, "+CRLF
	cQ += "(round(SFT.FT_VALCONT / SFT.FT_QUANT,4) * 100) CUSTO_UNIT, "+CRLF
	cQ += "(round(SFT.FT_VALCONT,2) * 100) CUSTO_ITEM, "+CRLF
	cQ += "'@' COD_CONTA_CRED, "+CRLF
	cQ += "'@' COD_CONTA_DEBITO, "+CRLF
	cQ += "'@' COD_OPERACAO, "+CRLF
	cQ += "TRIM(SFT.FT_CFOP) COD_CFO, "+CRLF
	cQ += "'3' COD_ENT_SAIDA, "+CRLF
	cQ += "TO_CHAR(SFT.FT_VALIPI * 100) VLR_IPI, "+CRLF
	cQ += "'@' OBS_ESTOQUE, "+CRLF
	cQ += "'@' DATA_ESCRITA_FIS, "+CRLF
	cQ += "'@' COD_MEDIDA, "+CRLF
	cQ += "CASE WHEN SB1.B1_POSIPI = '00000000' THEN '@' "+CRLF
	cQ += "     WHEN trim(SB1.B1_POSIPI) = '' THEN '@' "+CRLF
	cQ += "	 ELSE SB1.B1_POSIPI END COD_NBM, "+CRLF
	cQ += "'@' IND_INSUMO, "+CRLF
	cQ += "'@' COD_LEGENDA, "+CRLF
	cQ += "'@' NUM_ORDEM, "+CRLF
	cQ += "'@' NUM_DOCFIS_OFIC, "+CRLF
	cQ += "'@' SERIE_DOCFIS_OFIC, "+CRLF
	cQ += "'@' S_SERIE_DOCFIS_OFIC, "+CRLF
	cQ += "'5' IND_FIS_JUR, "+CRLF
	cQ += "CASE WHEN (SFT.FT_TIPOMOV = 'E' AND FT_TIPO IN ('D','B')) "+CRLF
	cQ += "        THEN (SELECT DECODE(TRIM(SA1.A1_XCDSAP), '','@',SA1.A1_XCDSAP) FROM SA1010 SA1 WHERE SA1.A1_COD = FT_CLIEFOR AND SA1.A1_LOJA = FT_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'E' AND FT_TIPO NOT IN ('D','B')) "+CRLF
	cQ += "        THEN (SELECT DECODE(TRIM(SA2.A2_XCDSAP), '','@',SA2.A2_XCDSAP) FROM SA2010 SA2 WHERE SA2.A2_COD = FT_CLIEFOR AND SA2.A2_LOJA = FT_LOJA AND SA2.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S' AND FT_TIPO IN ('D','B')) "+CRLF
	cQ += "		 	THEN (SELECT DECODE(TRIM(SA2.A2_XCDSAP), '','@',SA2.A2_XCDSAP) FROM SA2010 SA2 WHERE SA2.A2_COD = FT_CLIEFOR AND SA2.A2_LOJA = FT_LOJA AND SA2.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S' AND FT_TIPO NOT IN ('D','B')) "+CRLF
	cQ += "			THEN (SELECT DECODE(TRIM(SA1.A1_XCDSAP), '','@',SA1.A1_XCDSAP) FROM SA1010 SA1 WHERE SA1.A1_COD = FT_CLIEFOR AND SA1.A1_LOJA = FT_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 ELSE '@' "+CRLF
	cQ += "END COD_FIS_JUR, "+CRLF
	cQ += "'@' IND_TP_MOVTO, "+CRLF
	cQ += "'@' INSC_ESTADUAL, "+CRLF
	cQ += "'@' IND_PRODUTO_RASTRO, "+CRLF
	cQ += "'@' COD_PRODUTO_RASTRO, "+CRLF
	cQ += "TO_CHAR(SFT.FT_VALICM * 100) VLR_ICMS, "+CRLF
	cQ += "'@' DATA_DISP, "+CRLF
	cQ += "'@' IND_DOC_OPER, "+CRLF
	cQ += "'@' IND_TP_DOC_INTERNO, "+CRLF
	cQ += "'@' IND_REDESIGNACAO, "+CRLF
	cQ += "'@' IND_PRODUTO_ORI, "+CRLF
	cQ += "'@' COD_PRODUTO_ORI, "+CRLF
	cQ += "'@' VLR_CUSTO_DCA, "+CRLF
	cQ += "'@' VLR_OUT_TRIB_NCUMUL, "+CRLF
	cQ += "'@' COD_TP_LANCTO, "+CRLF
	cQ += "'@' VLR_ICMS_DCA, "+CRLF
	cQ += "'@' COD_DIF_PRODUCAO, "+CRLF
	cQ += "'@' DSC_FINALIDADE, "+CRLF
	cQ += "'@' COD_TIPO_MOV_EST, "+CRLF
	cQ += "'@' COD_MEDIDA_ORI, "+CRLF
	cQ += "'@' COD_NIVEL_PRODUTO, "+CRLF
	cQ += "'@' QTD_INSUMO "+CRLF
	cQ += "FROM SFT010 SFT "+CRLF
	cQ += "INNER JOIN SF4010 SF4 ON SF4.F4_CODIGO = SFT.FT_TES AND SF4.F4_ESTOQUE = 'S' AND SUBSTR(FT_FILIAL,1,6) = TRIM(F4_FILIAL) AND SF4.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "INNER JOIN SB1010 SB1 ON TRIM(SB1.B1_FILIAL) = SUBSTR(FT_FILIAL,1,6) AND SB1.B1_COD = SFT.FT_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "LEFT OUTER JOIN SZP010 SZP ON SZP.ZP_CODFIL = SFT.FT_FILIAL AND SZP.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "WHERE SFT.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "AND FT_ENTRADA BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "+CRLF
	cQ += "AND FT_QUANT > 0 "+CRLF
	cQ += "AND FT_DTCANC = ' ' "+CRLF

	cQ += "UNION ALL "+CRLF

	cQ += "SELECT DISTINCT "+CRLF
	cQ += "TRIM(SZP.ZP_EMPMS) COD_EMPRESA, "+CRLF
	cQ += "TRIM(SZP.ZP_ESTMS) COD_ESTAB,"+CRLF
	cQ += "CASE WHEN SUBSTR(D3_CF,1,2) = 'DE' THEN '1' ELSE '9' END MOVTO_E_S, "+CRLF
	cQ += "'1' NORM_DEV, "+CRLF
	cQ += "'1' GRUPO_CONTAGEM, "+CRLF
	cQ += "'INT' COD_DOCTO, "+CRLF
	cQ += "SD3.D3_EMISSAO DATA_MOVTO, "+CRLF
	cQ += "NVL(SD3.D3_DOC,'@') NUM_DOCTO, "+CRLF
	cQ += "NVL(SD3.D3_CF,'@') SERIE_DOCFIS, "+CRLF
	cQ += "'@' SUB_SERIE_DOCFIS, "+CRLF
	cQ += "CASE SD3.D3_TIPO WHEN 'PA' THEN '1' "+CRLF
	cQ += "   WHEN 'AI' THEN '1' "+CRLF
	cQ += "   WHEN 'MP' THEN '2' "+CRLF
	cQ += "   WHEN 'ME' THEN '3' "+CRLF
	cQ += "   WHEN 'MC' THEN '4' "+CRLF
	cQ += "   WHEN 'PI' THEN '7' "+CRLF
	cQ += "   ELSE '5' END IND_PRODUTO, "+CRLF
	cQ += "trim(SD3.D3_COD) COD_PRODUTO, "+CRLF
	cQ += "SD3.D3_UM COD_UND_PADRAO, "+CRLF
	cQ += "SD3.D3_LOCAL COD_ALMOX, "+CRLF
	cQ += "CASE WHEN SD3.D3_CC = ' ' THEN '@' ELSE trim(SD3.D3_CC) END COD_CUSTO, "+CRLF
	cQ += "'001' NUM_ITEM, "+CRLF
	cQ += "SD3.D3_LOCAL COD_NAT_ESTOQUE, "+CRLF
	cQ += "'@' CONTRATO, "+CRLF
	cQ += "'@' SERIE_ITEM, "+CRLF
	cQ += "(SD3.D3_QUANT * 100 ) QTD_MOVTO, "+CRLF
	cQ += "(ROUND(SD3.D3_CUSTO1 / SD3.D3_QUANT,4) * 100) PRECO_UNIT, "+CRLF
	cQ += "(SD3.D3_CUSTO1 * 100)  PRECO_ITEM, "+CRLF
	cQ += "(round(SD3.D3_CUSTO1 / SD3.D3_QUANT,4) * 100) CUSTO_UNIT, "+CRLF
	cQ += "(round(SD3.D3_CUSTO1,2) * 100) CUSTO_ITEM, "+CRLF
	cQ += "'@' COD_CONTA_CRED, "+CRLF
	cQ += "'@' COD_CONTA_DEBITO, "+CRLF
	cQ += "'@' COD_OPERACAO, "+CRLF
	cQ += "'@' COD_CFO, "+CRLF
	cQ += "'1' COD_ENT_SAIDA, "+CRLF
	cQ += "'@' VLR_IPI, "+CRLF
	cQ += "'@' OBS_ESTOQUE, "+CRLF
	cQ += "'@' DATA_ESCRITA_FIS, "+CRLF
	cQ += "'@' COD_MEDIDA, "+CRLF
	cQ += "CASE SB1.B1_POSIPI WHEN '00000000' THEN '@' "+CRLF
	cQ += "     WHEN ' ' THEN '@' ELSE SB1.B1_POSIPI END COD_NBM, "+CRLF
	cQ += "'@' IND_INSUMO, "+CRLF
	cQ += "'@' COD_LEGENDA, "+CRLF
	cQ += "'@' NUM_ORDEM, "+CRLF
	cQ += "'@' NUM_DOCFIS_OFIC, "+CRLF
	cQ += "'@' SERIE_DOCFIS_OFIC, "+CRLF
	cQ += "'@' S_SERIE_DOCFIS_OFIC, "+CRLF
	cQ += "'@' IND_FIS_JUR, "+CRLF
	cQ += "'@' COD_FIS_JUR, "+CRLF
	cQ += "'@' IND_TP_MOVTO, "+CRLF
	cQ += "'@' INSC_ESTADUAL, "+CRLF
	cQ += "'@' IND_PRODUTO_RASTRO, "+CRLF
	cQ += "'@' COD_PRODUTO_RASTRO, "+CRLF
	cQ += "'@' VLR_ICMS, "+CRLF
	cQ += "'@' DATA_DISP, "+CRLF
	cQ += "'@' IND_DOC_OPER, "+CRLF
	cQ += "'@' IND_TP_DOC_INTERNO, "+CRLF
	cQ += "'@' IND_REDESIGNACAO, "+CRLF
	cQ += "'@' IND_PRODUTO_ORI, "+CRLF
	cQ += "'@' COD_PRODUTO_ORI, "+CRLF
	cQ += "'@' VLR_CUSTO_DCA, "+CRLF
	cQ += "'@' VLR_OUT_TRIB_NCUMUL, "+CRLF
	cQ += "'@' COD_TP_LANCTO, "+CRLF
	cQ += "'@' VLR_ICMS_DCA, "+CRLF
	cQ += "'@' COD_DIF_PRODUCAO, "+CRLF
	cQ += "'@' DSC_FINALIDADE, "+CRLF
	cQ += "'@' COD_TIPO_MOV_EST, "+CRLF
	cQ += "'@' COD_MEDIDA_ORI, "+CRLF
	cQ += "'@' COD_NIVEL_PRODUTO, "+CRLF
	cQ += "'@' QTD_INSUMO "+CRLF
	cQ += "From SD3010 SD3 "+CRLF
	cQ += "INNER JOIN SB1010 SB1 ON TRIM(SB1.B1_FILIAL) = SUBSTR(SD3.D3_FILIAL,1,6) AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "LEFT OUTER JOIN SZP010 SZP ON SZP.ZP_CODFIL = SD3.D3_FILIAL AND SZP.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "WHERE SD3.D3_QUANT > 0 AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO <> 'S' "+CRLF
	cQ += "AND D3_EMISSAO BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "+CRLF
	cQ += "ORDER BY DATA_MOVTO,NUM_DOCTO "+CRLF
Endif

If Alltrim(cTab) == "SAFX49"
	cQ := "SELECT DISTINCT "+CRLF
	cQ += "TRIM(SZP.ZP_EMPMS) COD_EMPRESA, "+CRLF
	cQ += "TRIM(SZP.ZP_ESTMS) COD_ESTAB, "+CRLF
	cQ += "NVL(CD5.CD5_DTDI,'@') DAT_DI, "+CRLF
	cQ += "NVL(CD5.CD5_NDI,'@') NUM_DI, "+CRLF
	cQ += "SF1.F1_DTDIGIT DAT_NF, "+CRLF
	cQ += "'5' IND_FIS_JUR, "+CRLF
	cQ += "CASE WHEN (FT_TIPOMOV = 'E' AND FT_TIPO IN ('D','B')) "+CRLF
	cQ += "        THEN (SELECT DECODE(TRIM(SA1.A1_XCDSAP), '','@',SA1.A1_XCDSAP) FROM SA1010 SA1 WHERE SA1.A1_COD = FT_CLIEFOR AND SA1.A1_LOJA = FT_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'E' AND FT_TIPO NOT IN ('D','B')) "+CRLF
	cQ += "        THEN (SELECT DECODE(TRIM(SA2.A2_XCDSAP), '','@',SA2.A2_XCDSAP) FROM SA2010 SA2 WHERE SA2.A2_COD = FT_CLIEFOR AND SA2.A2_LOJA = FT_LOJA AND SA2.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S' AND FT_TIPO IN ('D','B')) "+CRLF
	cQ += "		 	THEN (SELECT DECODE(TRIM(SA2.A2_XCDSAP), '','@',SA2.A2_XCDSAP) FROM SA2010 SA2 WHERE SA2.A2_COD = FT_CLIEFOR AND SA2.A2_LOJA = FT_LOJA AND SA2.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S' AND FT_TIPO NOT IN ('D','B')) "+CRLF
	cQ += "			THEN (SELECT DECODE(TRIM(SA1.A1_XCDSAP), '','@',SA1.A1_XCDSAP) FROM SA1010 SA1 WHERE SA1.A1_COD = FT_CLIEFOR AND SA1.A1_LOJA = FT_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 ELSE '@' "+CRLF
	cQ += "END COD_FIS_JUR, "+CRLF
	cQ += "SF1.F1_DOC NUM_NF, "+CRLF
	cQ += "NVL(TRIM(SF1.F1_SERIE),'@') SERIE_NF, "+CRLF
	cQ += "'@' SUB_SERIE_NF, "+CRLF
	cQ += "CASE SD1.D1_TP WHEN 'PA' THEN '1' "+CRLF
	cQ += "   WHEN 'AI' THEN '1' "+CRLF
	cQ += "   WHEN 'ME' THEN '3' "+CRLF
	cQ += "   WHEN 'MC' THEN '4' "+CRLF
	cQ += "   ELSE '5' END IND_PRODUTO, "+CRLF
	cQ += "trim(SD1.D1_COD) COD_PRODUTO, "+CRLF
	cQ += "SD1.D1_ITEM NUM_ITEM, "+CRLF
	cQ += "SF1.F1_DTDIGIT DAT_ENTRADA, "+CRLF
	cQ += "CASE SFT.FT_POSIPI "+CRLF
	cQ += "    WHEN '00000000' THEN '@' "+CRLF
	cQ += "    WHEN ' ' THEN '@' "+CRLF
	cQ += "    ELSE SFT.FT_POSIPI END COD_NBM, "+CRLF
	cQ += "'@' COD_EX, "+CRLF
	cQ += "CASE SF1.F1_ESPECIE "+CRLF
	cQ += "    WHEN 'NTST' THEN '22' "+CRLF
	cQ += "    WHEN 'NFFS' THEN '01' "+CRLF
	cQ += "    WHEN 'CTE'  THEN '57' "+CRLF
	cQ += "    WHEN 'NF'   THEN '01' "+CRLF
	cQ += "    WHEN 'SPED' THEN '55' "+CRLF
	cQ += "    WHEN 'RPS'  THEN '01' "+CRLF
	cQ += "    WHEN 'NFS'  THEN '01' "+CRLF
	cQ += "    WHEN 'NFSC' THEN '21' "+CRLF
	cQ += "    ELSE '55' END COD_MODELO, "+CRLF
	cQ += "SD1.D1_UM COD_MEDIDA, "+CRLF
	cQ += "SD1.D1_UM COD_MEDIDA_COM, "+CRLF
	cQ += "'@' AG_ATO_CONCES, "+CRLF
	cQ += "'@' ANO_ATO_CONCES, "+CRLF
	cQ += "'@' NUM_ATO_CONCES, "+CRLF
	cQ += "'@' DIG_ATO_CONCES, "+CRLF
	cQ += "'@' PESO_BRUTO, "+CRLF
	cQ += "'@' PESO_LIQUIDO, "+CRLF
	cQ += "'@' VLR_UNIT, "+CRLF
	cQ += "SD1.D1_QUANT * 100 QTD_UND_MED, "+CRLF
	cQ += "SD1.D1_QUANT * 100 QTD_UND_COM, "+CRLF
	cQ += "SFT.FT_TOTAL * 100 VLR_PRODUTO, "+CRLF
	cQ += "SFT.FT_FRETE * 100 VLR_FRETE, "+CRLF
	cQ += "SFT.FT_SEGURO * 100 VLR_SEGURO, "+CRLF
	cQ += "NVL(TO_CHAR(CD5.CD5_DSPAD * 100),'@') VLR_DESP_ADUAN, "+CRLF
	cQ += "'@' VLR_DESP_ACRESC, "+CRLF
	cQ += "NVL(TO_CHAR(CD5.CD5_VDESDI * 100),'@') VLR_DEDUCAO, "+CRLF
	cQ += "SFT.FT_VALCONT * 100 VLR_NF, "+CRLF
	cQ += "SFT.FT_BASEIPI * 100 BASE_IPI, "+CRLF
	cQ += "SFT.FT_ALIQIPI * 100 VLR_ALIQ_IPI, "+CRLF
	cQ += "SFT.FT_VALIPI * 100 VLR_IPI, "+CRLF
	cQ += "SFT.FT_ISENIPI * 100 VLR_ISENTA_IPI, "+CRLF
	cQ += "SFT.FT_OUTRIPI * 100 VLR_OUTRAS_IPI, "+CRLF
	cQ += "SFT.FT_BASEICM * 100 BASE_ICMS, "+CRLF
	cQ += "SFT.FT_ALIQICM * 100 VLR_ALIQ_ICMS, "+CRLF
	cQ += "SFT.FT_VALICM * 100 VLR_ICMS, "+CRLF
	cQ += "SFT.FT_ISENICM * 100 VLR_ISENTA_ICMS, "+CRLF
	cQ += "SFT.FT_OUTRICM * 100 VLR_OUTRAS_ICMS, "+CRLF
	cQ += "NVL(TO_CHAR(CD5.CD5_BCIMP),'@') BASE_II, "+CRLF
	cQ += "'@' VLR_ALIQ_II, "+CRLF
	cQ += "NVL(TO_CHAR(CD5.CD5_VLRII * 100),'@') VLR_II, "+CRLF
	cQ += "'@' PAIS_ORIG, "+CRLF
	cQ += "'@' MOEDA_ORIG, "+CRLF
	cQ += "'@' VLR_LIQ_MERC, "+CRLF
	cQ += "'@' VLR_MERC_DOLAR, "+CRLF
	cQ += "'@' VLR_MERC_MOEDA, "+CRLF
	cQ += "'@' OBS, "+CRLF
	cQ += "'@' IND_TP_OP, "+CRLF
	cQ += "'@' IND_PRD_SER_DIR, "+CRLF
	cQ += "'@' IND_AJUSTE_EFET, "+CRLF
	cQ += "'@' IND_MET_AJUSTE, "+CRLF
	cQ += "'@' VLR_AJUSTE, "+CRLF
	cQ += "'@' IND_COND_PES, "+CRLF
	cQ += "'@' MOEDA_OP_FRETE, "+CRLF
	cQ += "'@' VLR_FRETE_MOEDA, "+CRLF
	cQ += "'@' MOEDA_OP_SEGURO, "+CRLF
	cQ += "'@' VLR_SEGURO_MOEDA, "+CRLF
	cQ += "'@' VLR_UNIT_REAL, "+CRLF
	cQ += "'@' COD_FORN_ORIG, "+CRLF
	cQ += "SFT.FT_VALPIS * 100 VLR_PIS, "+CRLF
	cQ += "SFT.FT_VALCOF * 100 VLR_COFINS, "+CRLF
	cQ += "'@' VLR_IOF, "+CRLF
	cQ += "'@' VLR_ADUAN_SEM_ICMS, "+CRLF
	cQ += "'@' DAT_DESEMBARACO, "+CRLF
	cQ += "'@' TIPO_DI, "+CRLF
	cQ += "'@' COD_SCP "+CRLF
	cQ += "FROM SF1010 SF1 "+CRLF
	cQ += "INNER JOIN SZP010 SZP ON SZP.ZP_CODFIL = SF1.F1_FILIAL AND SZP.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "INNER JOIN SD1010 SD1 ON SD1.D1_FILIAL = SF1.F1_FILIAL AND SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_SERIE = SF1.F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND D1_DTDIGIT = F1_DTDIGIT AND SD1.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "INNER JOIN SFT010 SFT ON SFT.FT_FILIAL = SD1.D1_FILIAL AND SFT.FT_NFISCAL = SD1.D1_DOC AND SFT.FT_SERIE = SD1.D1_SERIE AND SFT.FT_CLIEFOR = SD1.D1_FORNECE AND SFT.FT_LOJA = SD1.D1_LOJA "+CRLF
	cQ += "           AND SFT.FT_PRODUTO = SD1.D1_COD AND SFT.FT_ITEM = SD1.D1_ITEM AND SFT.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "LEFT JOIN CD5010 CD5 ON CD5_FILIAL = SF1.F1_FILIAL AND CD5.CD5_DOC = SF1.F1_DOC AND CD5.CD5_SERIE = SF1.F1_SERIE "+CRLF
	cQ += "           AND CD5.CD5_FORNEC = SF1.F1_FORNECE AND CD5_LOJA = F1_LOJA AND CD5.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "WHERE SF1.F1_EST = 'EX' AND SF1.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "AND F1_DTDIGIT BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "+CRLF
	cQ += "ORDER BY F1_DTDIGIT,F1_DOC "+CRLF
Endif

If Alltrim(cTab) == "SAFX52"
	cQ := "SELECT DISTINCT "+CRLF
	cQ += "'001' COD_EMPRESA, "+CRLF
	cQ += "'0001' COD_ESTAB, "+CRLF
	cQ += "SB9.B9_DATA DATA_INVENTARIO, "+CRLF
	cQ += "'1' GRUPO_CONTAGEM, "+CRLF //VER TRATAMENTO CORRETO VIA FUN«√O SALDO PORDER TERCEITO - SB6
	cQ += "CASE SB1.B1_POSIPI WHEN '00000000' THEN '@' ELSE SB1.B1_POSIPI END COD_NBM, "+CRLF
	cQ += "CASE SB1.B1_TIPO WHEN 'PA' THEN '1' "+CRLF
	cQ += "   WHEN 'AI' THEN '1' "+CRLF
	cQ += "   WHEN 'ME' THEN '3' "+CRLF
	cQ += "   WHEN 'MC' THEN '4' "+CRLF
	cQ += "   ELSE '5' END IND_PRODUTO, "+CRLF
	cQ += "(SB1.B1_FILIAL || trim(SB1.B1_COD)) COD_PRODUTO, "+CRLF
	cQ += "SB1.B1_UM COD_UND_PADRAO, "+CRLF
	cQ += "SB9.B9_LOCAL COD_ALMOX, "+CRLF
	cQ += "'@' COD_CUSTO, "+CRLF
	cQ += "SB9.B9_LOCAL COD_NAT_ESTOQUE, "+CRLF
	cQ += "SB1.B1_UM COD_MEDIDA, "+CRLF
	cQ += "SB9.B9_QINI * 100 QUANTIDADE, "+CRLF
	cQ += "SB9.B9_VINI1 * 100 VLR_TOT, "+CRLF
	cQ += "ROUND((SB9.B9_VINI1 / SB9.B9_QINI),4) * 100 VLR_UNIT, "+CRLF
	cQ += "'@' OBSERVACAO, "+CRLF
	cQ += "'@' VLR_ICMS, "+CRLF
	cQ += "'@' COD_CONTA, "+CRLF
	cQ += "'@' IND_DEB_CRE, "+CRLF
	cQ += "'@' DESCRICAO_RIPI, "+CRLF
	cQ += "'@' VLR_ICMS_MEDIO, "+CRLF
	cQ += "'@' VLR_ICMSS_MEDIO, "+CRLF
	cQ += "'@' INSC_ESTADUAL, "+CRLF
	cQ += "'@' IND_FIS_JUR, "+CRLF
	cQ += "'@' COD_FIS_JUR, "+CRLF
	cQ += "'@' VLR_BASE_ICMS, "+CRLF
	cQ += "'@' VLR_BASE_ISENTO, "+CRLF
	cQ += "'@' VLR_BASE_OUTRAS, "+CRLF
	cQ += "'@' VLR_BASE_ICMSS, "+CRLF
	cQ += "'@' COD_OBSERVACAO, "+CRLF
	cQ += "'@' VLR_CUSTO_DCA, "+CRLF
	cQ += "'@' IND_PRODUTO_RASTRO, "+CRLF
	cQ += "'@' COD_PRODUTO_RASTRO, "+CRLF
	cQ += "'@' VLR_IPI, "+CRLF
	cQ += "'@' VLR_PIS, "+CRLF
	cQ += "'@' VLR_COFINS, "+CRLF
	cQ += "'@' VLR_TRIB_NC, "+CRLF
	cQ += "'@' COD_SITUACAO_A, "+CRLF
	cQ += "'@' COD_SITUACAO_B, "+CRLF
	cQ += "'@' IND_MOT_INV, "+CRLF
	cQ += "'@' IND_SIT_TRIB, "+CRLF
	cQ += "'@' VLR_IR "+CRLF
	cQ += "FROM SB9010 SB9 "+CRLF
	cQ += "INNER JOIN SB1010 SB1 ON SB1.B1_COD = SB9.B9_COD AND SUBSTR(SB1.B1_FILIAL,1,6) = SUBSTR(SB9.B9_FILIAL,1,6) AND SB1.D_E_L_E_T_ = ' ' AND B1_TIPO <> 'SE' "+CRLF
	cQ += "WHERE SB9.D_E_L_E_T_ = ' ' AND SB9.B9_QINI > 0 "+CRLF
	cQ += "AND B9_DATA BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "+CRLF
	cQ += "ORDER BY COD_PRODUTO "+CRLF
Endif

If Alltrim(cTab) == "SAFX108"
	cQ := "SELECT DISTINCT "+CRLF
	cQ += "TRIM(SZP.ZP_EMPMS) COD_EMPRESA, "+CRLF
	cQ += "TRIM(SZP.ZP_ESTMS) COD_ESTAB, "+CRLF
	cQ += "(SUBSTR(SC2.C2_EMISSAO,5,2) || SUBSTR(SC2.C2_EMISSAO,1,4)) PERIODO_REF, "+CRLF
	cQ += "(TRIM(SC2.C2_NUM) || TRIM(SC2.C2_ITEM) || TRIM(SC2.C2_SEQUEN)) COD_OP, "+CRLF
	cQ += "CASE SB1.B1_TIPO WHEN 'PA' THEN '1' "+CRLF
	cQ += "   WHEN 'AI' THEN '1' "+CRLF
	cQ += "   WHEN 'MP' THEN '2' "+CRLF
	cQ += "   WHEN 'ME' THEN '3' "+CRLF
	cQ += "   WHEN 'MC' THEN '4' "+CRLF
	cQ += "   WHEN 'PI' THEN '7' "+CRLF
	cQ += "   ELSE '5' END IND_PRODUTO_OP, "+CRLF
	cQ += "TRIM(SC2.C2_PRODUTO) COD_PRODUTO_OP, "+CRLF
	cQ += "SC2.C2_DATPRI DT_INI_OP, "+CRLF
	cQ += "SC2.C2_DATPRF DT_FIM_OP, "+CRLF
	cQ += "SC2.C2_UM COD_UND_PADRAO, "+CRLF
	cQ += "SC2.C2_QUANT * 100 QTD_PRODUZIDO, "+CRLF
	cQ += "'N' IND_APUR_CUSTO, "+CRLF
	cQ += "(SELECT SUM(SD3.D3_CUSTO1) * 100 FROM SD3010 SD3 "+CRLF
	cQ += "           WHERE SD3.D3_FILIAL = SC2.C2_FILIAL AND TRIM(SD3.D3_OP) = (TRIM(SC2.C2_NUM) || TRIM(SC2.C2_ITEM) || TRIM(SC2.C2_SEQUEN)) AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ') VLR_TOT_CUSTO, "+CRLF
	cQ += "SC2.C2_QUJE * 100 QTD_TRANSF, "+CRLF
	cQ += "(SELECT SUM(SD3.D3_CUSTO1) * 100 FROM SD3010 SD3 "+CRLF
	cQ += "           WHERE SD3.D3_FILIAL = SC2.C2_FILIAL AND TRIM(SD3.D3_OP) = (TRIM(SC2.C2_NUM) || TRIM(SC2.C2_ITEM) || TRIM(SC2.C2_SEQUEN)) AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ') VLR_TRANSF, "+CRLF
	cQ += "'@' COD_DIF_PRODUCAO, "+CRLF
	cQ += "'@' VLR_CUSTO_DCA, "+CRLF //vER SE EXISTE nf DE BENEFICIAMENTO PARA PRODU«√O
	cQ += "'@' VLR_ICMS_DCA, "+CRLF //VER SE EXISTE NF DE BENEFICCIAMENTO PARA PRODU«√O
	cQ += "'@' COD_PROCESSO_PRODUCAO, "+CRLF //?? n√O ENTENDI
	cQ += "'@' INSC_ESTADUAL, "+CRLF //iNFORMAR SOMENTE QUANDO FOR AM
	cQ += "'@' DSC_RESERVADO1, "+CRLF
	cQ += "'@' DSC_RESERVADO2, "+CRLF
	cQ += "'@' DSC_RESERVADO3, "+CRLF
	cQ += "'@' DSC_RESERVADO4, "+CRLF
	cQ += "'@' DSC_RESERVADO5, "+CRLF
	cQ += "'@' DSC_RESERVADO6, "+CRLF
	cQ += "'@' DSC_RESERVADO7, "+CRLF
	cQ += "'@' DSC_RESERVADO8, "+CRLF
	cQ += "'1' IND_TP_ORDEM, "+CRLF //ver se existe OP para reparo TIPO 3
	cQ += "SC2.C2_QUANT * 100 QTD_ORIGEM, "+CRLF
	cQ += "'@' DT_SAIDA_ESTQ, "+CRLF
	cQ += "'@' QTD_SAIDA_ESTQ, "+CRLF
	cQ += "'@' DT_RET_ESTQ, "+CRLF
	cQ += "'@' QTD_RET_ESTQ "+CRLF
	cQ += "FROM SC2010 SC2 "+CRLF
	cQ += "INNER JOIN SB1010 SB1 ON TRIM(SB1.B1_FILIAL) = SUBSTR(SC2.C2_FILIAL,1,6) AND SB1.B1_COD = SC2.C2_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "LEFT OUTER JOIN SZP010 SZP ON SZP.ZP_CODFIL = SC2.C2_FILIAL AND SZP.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "WHERE SC2.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "AND C2_DATPRI >= '"+dTos(mv_par02)+"' AND C2_DATPRF <= '"+dTos(mv_par03)+"' "+CRLF
	cQ += "ORDER BY (TRIM(SC2.C2_NUM) || TRIM(SC2.C2_ITEM) || TRIM(SC2.C2_SEQUEN)) "+CRLF
Endif

If Alltrim(cTab) == "SAFX109"
	cQ := "SELECT DISTINCT "+CRLF
	cQ += "'001' COD_EMPRESA, "+CRLF
	cQ += "'0001' COD_ESTAB, "+CRLF
	cQ += "SUBSTR(SC2.C2_EMISSAO,5,2) || SUBSTR(SC2.C2_EMISSAO,1,4) PERIODO_REF, "+CRLF
	cQ += "(TRIM(SC2.C2_NUM) || TRIM(SC2.C2_ITEM) || TRIM(SC2.C2_SEQUEN)) COD_OP, "+CRLF
	cQ += "'@' NUM_ITEM, "+CRLF
	cQ += "CASE SB1.B1_TIPO WHEN 'PA' THEN '1' "+CRLF
	cQ += "   WHEN 'AI' THEN '1' "+CRLF
	cQ += "   WHEN 'MP' THEN '2' "+CRLF
	cQ += "   WHEN 'ME' THEN '3' "+CRLF
	cQ += "   WHEN 'MC' THEN '4' "+CRLF
	cQ += "   WHEN 'PI' THEN '7' "+CRLF
	cQ += "   ELSE '5' END IND_PRODUTO, "+CRLF
	cQ += "SD3.D3_COD COD_PRODUTO, "+CRLF
	cQ += "SD3.D3_EMISSAO DT_SAIDA, "+CRLF
	cQ += "SD3.D3_UM COD_UND_PADRAO, "+CRLF
	cQ += "SD3.D3_QUANT * 100 QTD_PRODUZIDO, "+CRLF
	cQ += "round((SD3.D3_CUSTO1 / SD3.D3_QUANT),2) * 100 VLR_UNIT, "+CRLF
	cQ += "'@' COD_DIF_PRODUCAO, "+CRLF
	cQ += "CASE SB1.B1_TIPO WHEN 'PA' THEN '1' "+CRLF
	cQ += "   WHEN 'AI' THEN '1' "+CRLF
	cQ += "   WHEN 'MP' THEN '2' "+CRLF
	cQ += "   WHEN 'ME' THEN '3' "+CRLF
	cQ += "   WHEN 'MC' THEN '4' "+CRLF
	cQ += "   WHEN 'PI' THEN '7' "+CRLF
	cQ += "   ELSE '5' END IND_PRODUTO_OP, "+CRLF
	cQ += "SC2.C2_PRODUTO COD_PRODUTO_OP, "+CRLF
	cQ += "'@' VLR_CUSTO_DCA, "+CRLF // VERIFICAR SE EXISTE BENEFICIAMENTO
	cQ += "'@' VLR_ICMS_DCA, "+CRLF // VERIFICAR SE EXISTE BENEFICIAMENTO
	cQ += "'@' COD_FASE_PRODUCAO, "+CRLF //n√O USADO
	cQ += "'@' IND_INSUMO_SUBST, "+CRLF
	cQ += "'@' COD_INSUMO_SUBST, "+CRLF
	cQ += "'@' DSC_RESERVADO1, "+CRLF
	cQ += "'@' DSC_RESERVADO2, "+CRLF
	cQ += "'@' DSC_RESERVADO3, "+CRLF
	cQ += "'@' DSC_RESERVADO4, "+CRLF
	cQ += "'@' DSC_RESERVADO5, "+CRLF
	cQ += "'@' DSC_RESERVADO6, "+CRLF
	cQ += "'@' DSC_RESERVADO7, "+CRLF
	cQ += "'@' DSC_RESERVADO8, "+CRLF
	cQ += "'@' QTD_DESTINO, "+CRLF
	cQ += "'@' QTD_REPROC, "+CRLF
	cQ += "'@' QTD_RETORNADA "+CRLF
	cQ += "FROM SD3010 SD3 "+CRLF
	cQ += "INNER JOIN SC2010 SC2 ON SC2.C2_FILIAL = SD3.D3_FILIAL AND (TRIM(SC2.C2_NUM) || TRIM(SC2.C2_ITEM) || TRIM(SC2.C2_SEQUEN)) = TRIM(SD3.D3_OP) AND SC2.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "INNER JOIN SB1010 SB1 ON TRIM(SB1.B1_FILIAL) = SUBSTR(SC2.C2_FILIAL,1,6) AND SB1.B1_COD = SC2.C2_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "WHERE SD3.D3_OP <> ' ' AND SD3.D3_CF <> 'PR0' AND SD3.D3_CF <> 'PR1' AND SD3.D3_ESTORNO = ' ' AND SD3.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "AND D3_EMISSAO BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "+CRLF
	cQ += "ORDER BY D3_EMISSAO,D3_COD "+CRLF
Endif

If Alltrim(cTab) == "SAFX116"
	cQ := "SELECT DISTINCT "+CRLF
	cQ += "TRIM(SZP.ZP_EMPMS) COD_EMPRESA, "+CRLF
	cQ += "TRIM(SZP.ZP_ESTMS) COD_ESTAB, "+CRLF
	cQ += "SF3.F3_ENTRADA DATA_FISCAL, "+CRLF
	cQ += "CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SF3.F3_FORMUL = 'S') THEN  '4' "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'E' AND SF3.F3_FORMUL <> 'S') THEN '1' "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S') THEN '9' "+CRLF
	cQ += "END MOVTO_E_S, "+CRLF
	cQ += "CASE WHEN SF3.F3_TIPO = 'D' THEN '2' ELSE '1' END NORM_DEV, "+CRLF
	cQ += "NVL(TRIM(SF3.F3_ESPECIE),'@') COD_DOCTO, "+CRLF
	cQ += "'5' IND_FIS_JUR, "+CRLF
	cQ += "CASE WHEN (FT_TIPOMOV = 'E' AND FT_TIPO IN ('D','B')) "+CRLF
	cQ += "        THEN (SELECT DECODE(TRIM(SA1.A1_XCDSAP), '','@',SA1.A1_XCDSAP) FROM SA1010 SA1 WHERE SA1.A1_COD = FT_CLIEFOR AND SA1.A1_LOJA = FT_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'E' AND FT_TIPO NOT IN ('D','B')) "+CRLF
	cQ += "        THEN (SELECT DECODE(TRIM(SA2.A2_XCDSAP), '','@',SA2.A2_XCDSAP) FROM SA2010 SA2 WHERE SA2.A2_COD = FT_CLIEFOR AND SA2.A2_LOJA = FT_LOJA AND SA2.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S' AND FT_TIPO IN ('D','B')) "+CRLF
	cQ += "		 	THEN (SELECT DECODE(TRIM(SA2.A2_XCDSAP), '','@',SA2.A2_XCDSAP) FROM SA2010 SA2 WHERE SA2.A2_COD = FT_CLIEFOR AND SA2.A2_LOJA = FT_LOJA AND SA2.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S' AND FT_TIPO NOT IN ('D','B')) "+CRLF
	cQ += "			THEN (SELECT DECODE(TRIM(SA1.A1_XCDSAP), '','@',SA1.A1_XCDSAP) FROM SA1010 SA1 WHERE SA1.A1_COD = FT_CLIEFOR AND SA1.A1_LOJA = FT_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CRLF
	cQ += "	 ELSE '@' "+CRLF
	cQ += "END COD_FIS_JUR, "+CRLF
	cQ += "SF3.F3_NFISCAL NUM_DOCFIS, "+CRLF
	cQ += "NVL(TRIM(SF3.F3_SERIE),'@') SERIE_DOCFIS, "+CRLF
	cQ += "'@' SUB_SERIE_DOCFIS, "+CRLF
	cQ += "'@' COD_OBS_LANCTO_FISCAL, "+CRLF
	cQ += "NVL(SFT.FT_NFORI,'@') NUM_DOCFIS_REF, "+CRLF
	cQ += "NVL(SFT.FT_SERORI,'@') SERIE_DOCFIS_REF, "+CRLF
	cQ += "'@' SUB_SERIE_DOCFIS_REF, "+CRLF
	cQ += "'@' MOVTO_E_S_REF, "+CRLF
	cQ += "'@' IND_FIS_JUR_REF, "+CRLF
	cQ += "'@' COD_FIS_JUR_REF, "+CRLF
	cQ += "'@' DATA_FISCAL_REF, "+CRLF
	cQ += "'@' COD_MODELO_REF, "+CRLF
	cQ += "DECODE( TRIM(SF3.F3_CHVNFE), '', '@',SF3.F3_CHVNFE) NUM_AUTENTIC_NFE "+CRLF
	cQ += "FROM SF3010 SF3 "+CRLF
	cQ += "LEFT OUTER JOIN SZP010 SZP ON SZP.ZP_CODFIL = SF3.F3_FILIAL AND SZP.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "INNER JOIN SFT010 SFT ON SFT.FT_FILIAL = SF3.F3_FILIAL AND SFT.FT_NFISCAL = SF3.F3_NFISCAL AND SFT.FT_SERIE = SF3.F3_SERIE "+CRLF
	cQ += "           AND SFT.FT_CLIEFOR = SF3.F3_CLIEFOR AND SFT.FT_LOJA = SF3.F3_LOJA AND SFT.FT_IDENTF3 = SF3.F3_IDENTFT AND SFT.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "WHERE SF3.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "AND F3_ENTRADA BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "+CRLF
	cQ += "ORDER BY F3_ENTRADA,F3_NFISCAL "+CRLF
Endif

If Alltrim(cTab) == "SAFX130"
	cQ := "SELECT DISTINCT "+CRLF
	cQ += "TRIM(SZP.ZP_EMPMS) COD_EMPRESA, "+CRLF
	cQ += "TRIM(SZP.ZP_ESTMS) COD_ESTAB, "+CRLF
	cQ += "CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SF3.F3_FORMUL = 'S' AND SF3.F3_TIPO IN ('D','B')) THEN  '4' "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'E' AND SF3.F3_FORMUL <> 'S') THEN '9' "+CRLF
	cQ += "	 WHEN (SFT.FT_TIPOMOV = 'S') THEN '9' END MOVTO_E_S, "+CRLF
	cQ += "SF3.F3_NFISCAL NUM_DOCFIS_INI, "+CRLF
	cQ += "SF3.F3_NFISCAL NUM_DOCFIS_FIN, "+CRLF
	cQ += "NVL(TRIM(SF3.F3_SERIE),'@') SERIE_DOCFIS, "+CRLF
	cQ += "'@' SUB_SERIE_DOCFIS, "+CRLF
	cQ += "SF3.F3_ENTRADA DATA_REF, "+CRLF
	cQ += "CASE WHEN SF3.F3_ESPECIE = 'NTST' THEN '22' "+CRLF
	cQ += "  WHEN SF3.F3_ESPECIE = 'NFFS' THEN '01' "+CRLF
	cQ += "  WHEN SF3.F3_ESPECIE = 'CTE'  THEN '57' "+CRLF
	cQ += "  WHEN SF3.F3_ESPECIE = 'NF'   THEN '01' "+CRLF
	cQ += "  WHEN SF3.F3_ESPECIE = 'SPED' THEN '55' "+CRLF
	cQ += "  WHEN SF3.F3_ESPECIE = 'RPS'  THEN '01' "+CRLF
	cQ += "  WHEN SF3.F3_ESPECIE = 'NFS'  THEN '01' "+CRLF
	cQ += "  WHEN SF3.F3_ESPECIE = 'NFSC' THEN '21' "+CRLF
	cQ += "  ELSE '55' END COD_MODELO, "+CRLF
	cQ += "CASE WHEN SF3.F3_CODRSEF = '102' THEN '2' ELSE '1' END IND_SITUACAO, "+CRLF
	cQ += "'@' INSC_ESTADUAL, "+CRLF
	cQ += "DECODE( TRIM(SF3.F3_CHVNFE), '', '@',SF3.F3_CHVNFE) NUM_AUTENTIC_NFE, "+CRLF
	cQ += "'@' COD_SCP "+CRLF
	cQ += "FROM SF3010 SF3 "+CRLF
	cQ += "INNER JOIN SFT010 SFT ON SFT.FT_FILIAL = SF3.F3_FILIAL AND SFT.FT_NFISCAL = SF3.F3_NFISCAL AND SFT.FT_SERIE = SF3.F3_SERIE "+CRLF
	cQ += "           AND SFT.FT_CLIEFOR = SF3.F3_CLIEFOR AND SFT.FT_LOJA = SF3.F3_LOJA AND  SFT.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "LEFT OUTER JOIN SZP010 SZP ON SZP.ZP_CODFIL = SF3.F3_FILIAL AND SZP.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "WHERE SF3.F3_CODRSEF IN ('110','301','302','303','304','305','306','102') AND SF3.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "AND F3_ENTRADA BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "+CRLF
	cQ += "ORDER BY F3_ENTRADA,F3_NFISCAL "+CRLF
Endif

If Alltrim(cTab) == "SAFX2006"
	cQ := "SELECT DISTINCT "+CRLF
	cQ += "SF4.F4_CODIGO COD_NATUREZA_OP, "+CRLF
	cQ += "(SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') DATA_X2006 FROM DUAL) AS DATA_X2006 , "+CRLF
	cQ += "SF4.F4_TEXTO DESCRICAO, "+CRLF
	cQ += "CASE WHEN SF4.F4_CODIGO < '500' THEN 'E' ELSE 'S' END ENT_SAI, "+CRLF
	cQ += "'@' IND_FIS_JUR, "+CRLF
	cQ += "'@' COD_NATUREZA_OP_SPED "+CRLF
	cQ += "FROM SF4010 SF4 "+CRLF
	cQ += "WHERE D_E_L_E_T_ = ' ' "+CRLF
	cQ += "ORDER BY F4_CODIGO "+CRLF
Endif

If Alltrim(cTab) == "SAFX2013"
	cQ := "SELECT DISTINCT "+CRLF
	cQ += "CASE WHEN SB1.B1_TIPO = 'PA' THEN '1' "+CRLF
	cQ += "   WHEN SB1.B1_TIPO = 'AI' THEN '1' "+CRLF
	cQ += "   WHEN SB1.B1_TIPO = 'MP' THEN '2' "+CRLF
	cQ += "   WHEN SB1.B1_TIPO = 'ME' THEN '3' "+CRLF
	cQ += "   WHEN SB1.B1_TIPO = 'MC' THEN '4' "+CRLF
	cQ += "   WHEN SB1.B1_TIPO = 'PI' THEN '7' "+CRLF
	cQ += "   ELSE '5' END IND_PRODUTO, "+CRLF
	cQ += "SB1.B1_COD COD_PRODUTO, "+CRLF
	cQ += "'@' DATA_PRODUTO, "+CRLF
	cQ += "SB1.B1_DESC DESCRICAO, "+CRLF
	cQ += "SB1.B1_POSIPI COD_NBM, "+CRLF
	cQ += "SB1.B1_POSIPI COD_NCM, "+CRLF
	cQ += "SB1.B1_NALSH COD_NALADI, "+CRLF
	cQ += "CASE WHEN SB1.B1_PICMRET > 0 THEN 'S' ELSE '@' END IND_REGIDO_SUBST, "+CRLF
	cQ += "'N' IND_CONTROLE_SELO, "+CRLF
	cQ += "'@' GRUPO_SELO, "+CRLF
	cQ += "'@' SUB_GRUPO_SELO, "+CRLF
	cQ += "'@' COR_SELO, "+CRLF
	cQ += "'@' SERIE_SELO, "+CRLF
	cQ += "SB1.B1_UM COD_MEDIDA, "+CRLF
	cQ += "SB1.B1_GRUPO COD_GRUPO_PROD, "+CRLF
	cQ += "'@' COD_GRP_INCENT, "+CRLF
	cQ += "'@' COD_GRUPO_ST, "+CRLF
	cQ += "SB1.B1_CONTA COD_CONTA, "+CRLF
	cQ += "'@' IND_INCID_ICMS_SER, "+CRLF
	cQ += "SB1.B1_UM COD_UND_PADRAO, "+CRLF
	cQ += "'@' VLR_PESO_UNIT_KG, "+CRLF
	cQ += "NVL(SB5.B5_CEME,'@') DESCR_DETALHADA, "+CRLF
	cQ += "'@' IND_FABRIC_ESTAB, "+CRLF
	cQ += "'@' FATOR_CONVERSAO, "+CRLF
	cQ += "'@' IND_CLASSIF_ICMSS, "+CRLF
	cQ += "'@' DSC_MODELO, "+CRLF
	cQ += "'@' ORIGEM, "+CRLF
	cQ += "'@' COD_GRP_PROD, "+CRLF
	cQ += "CASE WHEN SB1.B1_PPIS > 0 THEN 'S' ELSE 'N' END IND_INCID_PIS, "+CRLF
	cQ += "CASE WHEN SB1.B1_PPIS > 0 THEN TO_CHAR(SB1.B1_PPIS * 100) ELSE '@' END ALIQ_PIS, "+CRLF
	cQ += "CASE WHEN SB1.B1_PCOFINS > 0 THEN 'S' ELSE 'N' END IND_INCID_COFINS, "+CRLF
	cQ += "CASE WHEN SB1.B1_PCOFINS > 0 THEN TO_CHAR(SB1.B1_PCOFINS * 100) ELSE '@' END ALIQ_COFINS, "+CRLF
	cQ += "CASE WHEN SB1.B1_CONTSOC <> ' ' THEN 'S' ELSE 'N' END IND_FUNRURAL, "+CRLF
	cQ += "'@' IND_PETR_ENERG, "+CRLF
	cQ += "CASE WHEN SB1.B1_CRDEST > 0 THEN 'S' ELSE 'N' END IND_PRD_INCENTIV, "+CRLF
	cQ += "'@' IND_ICMS_DIFERIDO, "+CRLF
	cQ += "'@' CAPAC_VOLUM, "+CRLF
	cQ += "'@' ESPECIE_DNF, "+CRLF
	cQ += "'@' CLAS_ITEM, "+CRLF
	cQ += "CASE WHEN TRIM(SB1.B1_CODBAR) <> '' THEN SB1.B1_CODBAR ELSE '@' END COD_BARRAS, "+CRLF
	cQ += "'@' COD_ANP, "+CRLF
	cQ += "'@' IND_ANT_PROD, "+CRLF
	cQ += "'@' COD_ANT_ITEM, "+CRLF
	cQ += "'@' DAT_ALT_CODIGO, "+CRLF
	cQ += "'@' CLAS_ENQUAD_IPI, "+CRLF
	cQ += "'@' MATERIAL_RESULT_PERDA, "+CRLF
	cQ += "'@' DSC_FINALIDADE, "+CRLF
	cQ += "'@' QTD_CAP_MAX_ARMAZ, "+CRLF
	cQ += "'@' IND_ATIVO_SAICS, "+CRLF
	cQ += "'@' IND_TAB_INCIDENCIA, "+CRLF
	cQ += "'@' COD_GRUPO, "+CRLF
	cQ += "'@' MARCA_COMERCIAL, "+CRLF
	cQ += "'@' IND_CARAC_PRODUTO , "+CRLF
	cQ += "'@' COD_CEST "+CRLF
	cQ += "FROM SB1010 SB1 "+CRLF
	cQ += "LEFT OUTER JOIN SB5010 SB5 ON SB5.B5_FILIAL = SB1.B1_FILIAL AND SB5.B5_COD = SB1.B1_COD AND SB5.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "WHERE SB1.D_E_L_E_T_ = ' ' "+CRLF
	cQ += "AND B1_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' "+CRLF
	cQ += "ORDER BY B1_COD "+CRLF
Endif

Return(cQ)
