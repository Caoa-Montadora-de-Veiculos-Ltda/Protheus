#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCMVMSF02 บ Autor ณ Jose Roberto       บ Data ณ  31/10/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para exporta็ใo de Dados - Protheus -> Mastersaf    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico CAOA                                            บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                บฑฑ
ฑฑฬอออออออออออัอออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramadorณ  Data   ณ Motivo da Alteracao                             บฑฑ
ฑฑฬอออออออออออุอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ณ         ณ                                                 บฑฑ
ฑฑศอออออออออออฯอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function CMVMSF02

Local nOpc := 0
Local aRet := {}
//Local aCombo := {"Excel","TXT"}
Local aParamBox := {}

Private cTitulo := "Exporta็ใo Protheus -> MasterSAF"
Private aSay := {}
Private aButton := {}
Private dDataIni := cToD("  /  /  ")
Private dDataFim := cToD("  /  /  ")
Private cLocDest := ""
Private cFileOut := ""
Private cCodFil	 := ""
Private cCodProd := ""

AAdd( aSay , "Esta Rotina tem como objetivo gerar informa็๕es do ERP Protheus " )
AAdd( aSay , "para o MasterSAF via arquivo TXT conforme documenta็ใo t้cnica " )
//AAdd( aSay , "Project Charter - XXXXXX")
AAdd( aSay , "")
AAdd( aSay, "Clique para continuar...")

aAdd( aButton, { 1,.T.,{|| nOpc := 1,FechaBatch()}})
aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cTitulo, aSay, aButton )

//Se Clicou no OK segue com processamento - Parambox -> MarkBrowse
If nOpc == 1
	chkfile("SZR") // verifica se a tabela existe e estแ OK
	aAdd(aParamBox,{1 ,"Filial :" ,cFilant,"","","","",50,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Data Inicial:" ,Date(),"","","","",50,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Data Final :" ,Date(),"","","","",50,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Produto :" ,SPACE(15),"","","","",80,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Local do Arquivo:" ,Space(65),"@S50","","","",100,.T.}) // Tipo caractere

	If ParamBox(aParamBox,"Parametros para gera็ใo do Arquivo...",@aRet)
	    dDataIni := aRet[2]
	    dDataFim := aRet[3]
	    cLocDest := alltrim(aRet[5])
	    IF substr(cLocDest,len(cLocDest),1) <> "\"
	    	cLocDest += "\"
	    Endif
		U_MontaBrw()
	EndIF
EndIF

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ MontaBrw ณ Autor | JRCARVALHO   			  ณ Data ณ 31/10/18           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Monta tela com a Lista das Tabelas Para Integra็ใo MasterSAF           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico CAOA- Interface MasterSAF                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MontaBrw( )

Local cArqTmp   := Criatrab(,.F.)
//Local linverte 	:= .F.
Local aCmpTrb	:= {}
Local aCampos 	:= {}

private oTempTable := FWTemporaryTable():New( "TRB" )

Private cMarca 	:= GetMark()
Private bMark   := {|| MarcaItem()}
Private cCadastro := 'Sele็ใo de Tabelas para Exportar'
Private aRotina := {}

//Alimenta Variaveis MARKBROWSE
//Menu da tela
aRotina := {{ "Exportar"		,"U_ExpTab()" 		, 0, 4},;
 			{ "Marcar Todos" 	,"U_MarcaTudo()" 	, 0, 4},;
    		{ "Desmarcar Todos" ,"U_DesmrkTudo()" 	, 0, 4},;
      		{ "Inverter Todos" 	,"U_InvertAll()" 	, 0, 4}}

//Campos que serใo exibidos na tela
aCampos := { {'_OK' 	,"",'OK'			},;
			{"TABELA" 	,"",'Tabela' 		},;
            {"TABDESC"	,"",'Descri็ใo' 	} }

//Campos para criacao do arquivo temporario
aCmpTrb := { {"_OK" 	,"C",02,0},;
			{"TABELA"	,"C",08,0},;
			{"TABDESC"	,"C",75,0} }

oTemptable:SetFields( aCmpTrb )

oTempTable:AddIndex("01", {"TABELA"} )

oTempTable:Create()

// alimenta a tabela temporแria
Montagrid()

MarkBrow( 'TRB','_OK',,aCampos,,cMarca,,,,,,,,,,,, )

TRB->( DBCloseArea() )

oTempTable:Delete()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Montagrid     บAutor  ณJose Roberto   บ Data ณ  31/10/18   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche lista da MarkBrowse                               บฑฑ
ฑฑบ          ณ Tabela temporaria para montagem da MarkBrowse              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico CAOA- Interface MasterSAF                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Montagrid()

Local cQuery 	:= ''

//Cria็ใo do insert into
cQuery := "INSERT INTO " + oTempTable:GetRealName()
cQuery += " ( _OK , TABELA , TABDESC ) "
//RODA QUERY PARA LEVANTAR AS TABELAS DO CADASTRO SZR
cQuery += "SELECT DISTINCT '  ' OK , ZQ_TABELA, ZQ_DESCTB FROM "+RetSqlName("SZQ")+" WHERE D_E_L_E_T_ = ' ' AND ZQ_MSBLQL <> '1' "

//Envia o insert into para o banco de dados, portanto toda a c๓pia ้ feita pelo banco de dados, com grande performance!
if TCSqlExec(cQuery) < 0
    ConOut("O comando SQL gerou erro:", TCSqlError())
endif

return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ExpTab        บAutor  ณJose Roberto   บ Data ณ  31/10/18   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Tabelas Selecionadas na MarkBrowse                 บฑฑ
ฑฑบ          ณ 												              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico CAOA- Interface MasterSAF                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ExpTab()

Local cTabela

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
		FWMsgRun(, {|| GeraTXT( cTabela ) },'Exporta็ใo Protheus -> MasterSAF','Gerando arquivo '+alltrim(cTabela)+', aguarde...')
	Endif

	DbSelectArea("TRB")
	TRB->(DBSKIP())
Enddo

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GeraTXT       บAutor  ณJose Roberto   บ Data ณ  31/10/18   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria a query conforme parโmetros no Parambox               บฑฑ
ฑฑบ          ณ 											                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 													          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico CAOA- Interface MasterSAF                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GeraTXT( cTab )

Local cQuery := ''
Local cCamposQry := ''
Local cNomeTab := padr(alltrim(cTab),10," ")
//Local aStruTXT := {}
//Local cArqTXT  := ''
Local cString  := ''
local nHandle
//Local nCount := 0
Local cBuffer := ''
Local nTotCampos := 0
Local cViewSQL1	:= ""
Local cViewSQL2	:= ""
Local cViewSQL3	:= ""
Local cViewSQL4	:= ""
Local cFiltro	:= ""
Local lGerou  := .F.
Local x	:= 0


//posiciona na SZQ - e Pega o Nome da View
DbSelectArea("SZQ")
DbSetOrder(1)
DBSeek(xFilial("SZQ")+cTab)
cViewSQL1 := ALLTRIM(SZQ->ZQ_NMVW01)

//verifica se existe amarra็ใo com a View
If Empty(cViewSQL1) .and. Empty(cViewSQL2) .and. Empty(cViewSQL3) .and. Empty(cViewSQL4)
	MsgAlert('Nใo existem VIEWS relacionadas a esta tabela - O Arquivo nใo pode ser gerado', "A T E N ว ร O")
	Return
Else
	//verifica se a view existe no banco
	cQuery := ""
	//verifica se a query estแ aberta
	IF Select( "CONFVW" ) > 0
		dbSelectArea( "CONFVW" )
		dbCloseArea()
	EndIF

	cString := ALLTRIM(cViewSQL1)
   	cQuery  := "SELECT * FROM ALL_OBJECTS WHERE OWNER = 'ABDHDU_PROT' AND OBJECT_TYPE = 'VIEW' AND OBJECT_NAME = '"+cString+"' "
 	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "CONFVW", .F., .T.)
	If CONFVW->(eof())
		MsgAlert("A View "+cString+" nใo existe no Banco de Dados. - O Arquivo "+upper(alltrim(cTab))+" nใo pode ser gerado", "A T E N ว ร O")
		Return
	Endif
Endif

//Trata filtros nas queries - Alguns arquivos MSAF podem ser filtrados por data e outros por produto
DO Case
	Case upper(alltrim(cTab)) == "SAFX07" 	//Arquivo de Notas Fiscais
		cFiltro := " WHERE DATA_SAIDA_REC BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX08"	//Itens Notas Fiscais Mercadorias e Produtos
		cFiltro := " WHERE DATA_FISCAL BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX09"	//Itens Notas Fiscais de Servi็os
		cFiltro := " WHERE DATA_FISCAL BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX10" 	//Arquivo de Controle de Estoque
		cFiltro := " WHERE DATA_MOVTO BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX108"	//Ordem de Produ็ใo
		cFiltro := " WHERE DT_INI_OP >= '"+dTos(mv_par02)+"' AND DT_FIM_OP <= '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX109"	//Item da Ordem de Produ็ใo
		cFiltro := " WHERE DT_SAIDA BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX112"	//Observa็๕es da Nota Fiscal
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX113"	//Ajuste/Outros Valores do Lan็amento Fiscal
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX116"	//Documentos Fiscais Referenciados
		cFiltro := " WHERE DATA_FISCAL BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX118"	//Local de Coleta
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX16" 	//Arquivo de Produtos Cuja Produ็ใo Utiliza Insumos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX17" 	//Arquivo de Insumos Utilizados na Fabrica็ใo de Produtos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX18" 	//Arquivo Referente a Embalagem
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2006"	//Tabela de Natureza de Opera็ใo
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2009"	//Cadastro de Observa็๕es - Ato COTEPE/ICMS 35/05
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2010"	//Tabela de Natureza de Estoque
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2013"	//Tabela de Produtos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2018"	//Tabela de C๓digo de Servi็os
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX49" 	//Tabela das Opera็๕es de Importa็ใo
		cFiltro := " WHERE DAT_ENTRADA BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX52" 	//Arquivo de Inventแrio de Estoque por Produto
		cFiltro := " WHERE DATA_INVENTARIO BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX53" 	//Arquivo de Controle de Tributos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX153"	//Produ็ใo de Terceiros
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX154"	//Produ็ใo de Terceiros – Insumos Consumidos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX235"	//Tabela das Corre็๕es de Apontamento da EFD - Bloco K.
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX236"	//Tabela de Itens das Corre็๕es de Apontamento da EFD - Bloco K
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX114"	//Processos Referenciados
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX130"	//Documentos Fiscais Eletr๔nicos Denegados ou Inutilizados
		cFiltro := " WHERE DATA_REF BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX245"	//Tabela dos Valores Declarat๓rios do SPED Fiscal (E115/1925)
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX520"	//Situa็ใo Tributแria complementar
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

//Cria arquivo de saida -> prepara para gravar TXT
nHandle := FCREATE(cLocDest+cFileOut)
If nHandle = -1
	MSGALERT("Erro ao criar arquivo TXT " + Str(Ferror()))
    Return()
Endif

//verifica se a query estแ aberta
IF Select( "TMPSQL" ) > 0
	dbSelectArea( "TMPSQL" )
	dbCloseArea()
EndIF

//Gera query com os dados para exportar
cQuery := ""
cQuery := "SELECT "+cCamposQry+" FROM "+cViewSQL1

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
	        cBuffer := ''
	        TMPSQL->(DbSkip())
	        lGerou := .T.
		Enddo
	Else
		MsgAlert('A query nใo retornou registros, por favor verifique os parโmetros informados.', "A T E N ว ร O")
	EndIF
Endif

FClose(nHandle)
IF lGerou
	MSGINFO("Arquivo "+ALLTRIM(cNomeTab)+" gerado com sucesso!!!")
Else
	MSGINFO("Nใo foram gerados dados para este arquivo!!")
Endif

//fecha arquivos temporarios
IF Select( "TMPSQL" ) > 0
	dbSelectArea( "TMPSQL" )
	dbCloseArea()
EndIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MarcaItem     บAutor  ณJose Roberto   บ Data ณ  31/10/18   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona os itens da MarkBrowse        					  บฑฑ
ฑฑบ          ณ 											                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ  											              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico CAOA- Interface MasterSAF                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MarcaItem()
//ocal oObj2Mark := getmarkbrow()
Local lDesmarc := IsMark("_OK", cMarca, .t.)

If !lDesmarc
   //Alert('Nใo Marcou !!!')

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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ InvertAll     บAutor  ณJose Roberto   บ Data ณ  31/10/18   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inverte sele็ใo de Itens no MarkBrowse                     บฑฑ
ฑฑบ          ณ 											                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ  											              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - CAOA-Interface MasterSaf                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function InvertAll()

Local oObjMark:= getmarkbrow()

DbSelectArea("TRB")
TRB->(DbGoTop())
While !TRB->(EOF())
   u_MarcaItem()
   TRB->(DbSkip())
End

MarkBRefresh( )
oObjMark:oBrowse:Gotop()	// for็a o posicionamento do browse no primeiro registro

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MarcaTudo     บAutor  ณJose Roberto   บ Data ณ  31/10/18   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para marcar todos os registros do MarkBrowse        บฑฑ
ฑฑบ          ณ 											                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ  												          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - CAOA-Interface MasterSaf                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MarcaTudo()

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
oMark:oBrowse:Gotop()	    // for็a o posicionamento do browse no primeiro registro

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DesmrkTudo    บAutor  ณJose Roberto   บ Data ณ  31/10/18   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para desmarcar todos os registros do MarkBrowse     บฑฑ
ฑฑบ          ณ 											                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 													          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico CAOA- Interface MasterSAF                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DesmrkTudo()

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
oMark:oBrowse:Gotop()	// for็a o posicionamento do browse no primeiro registro

Return

