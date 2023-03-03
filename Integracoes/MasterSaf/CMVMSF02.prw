#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CMVMSF02 � Autor � Jose Roberto       � Data �  31/10/18   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina para exporta��o de Dados - Protheus -> Mastersaf    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico CAOA                                            ���
�������������������������������������������������������������������������͹��
���       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                ���
�������������������������������������������������������������������������͹��
���Programador�  Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������͹��
���           �         �                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function CMVMSF02

Local nOpc := 0
Local aRet := {}
//Local aCombo := {"Excel","TXT"}
Local aParamBox := {}

Private cTitulo := "Exporta��o Protheus -> MasterSAF"
Private aSay := {}
Private aButton := {}
Private dDataIni := cToD("  /  /  ")
Private dDataFim := cToD("  /  /  ")
Private cLocDest := ""
Private cFileOut := ""
Private cCodFil	 := ""
Private cCodProd := ""

AAdd( aSay , "Esta Rotina tem como objetivo gerar informa��es do ERP Protheus " )
AAdd( aSay , "para o MasterSAF via arquivo TXT conforme documenta��o t�cnica " )
//AAdd( aSay , "Project Charter - XXXXXX")
AAdd( aSay , "")
AAdd( aSay, "Clique para continuar...")

aAdd( aButton, { 1,.T.,{|| nOpc := 1,FechaBatch()}})
aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cTitulo, aSay, aButton )

//Se Clicou no OK segue com processamento - Parambox -> MarkBrowse
If nOpc == 1
	chkfile("SZR") // verifica se a tabela existe e est� OK
	aAdd(aParamBox,{1 ,"Filial :" ,cFilant,"","","","",50,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Data Inicial:" ,Date(),"","","","",50,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Data Final :" ,Date(),"","","","",50,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Produto :" ,SPACE(15),"","","","",80,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Local do Arquivo:" ,Space(65),"@S50","","","",100,.T.}) // Tipo caractere

	If ParamBox(aParamBox,"Parametros para gera��o do Arquivo...",@aRet)
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
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Programa  � MontaBrw � Autor | JRCARVALHO   			  � Data � 31/10/18           ���
�������������������������������������������������������������������������������������Ĵ��
���Descri��o � Monta tela com a Lista das Tabelas Para Integra��o MasterSAF           ���
�������������������������������������������������������������������������������������͹��
���Parametros�                                                                        ���
�������������������������������������������������������������������������������������͹��
���Uso       � Especifico CAOA- Interface MasterSAF                              ���
�������������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/

User Function MontaBrw( )

Local cArqTmp   := Criatrab(,.F.)
//Local linverte 	:= .F.
Local aCmpTrb	:= {}
Local aCampos 	:= {}

private oTempTable := FWTemporaryTable():New( "TRB" )

Private cMarca 	:= GetMark()
Private bMark   := {|| MarcaItem()}
Private cCadastro := 'Sele��o de Tabelas para Exportar'
Private aRotina := {}

//Alimenta Variaveis MARKBROWSE
//Menu da tela
aRotina := {{ "Exportar"		,"U_ExpTab()" 		, 0, 4},;
 			{ "Marcar Todos" 	,"U_MarcaTudo()" 	, 0, 4},;
    		{ "Desmarcar Todos" ,"U_DesmrkTudo()" 	, 0, 4},;
      		{ "Inverter Todos" 	,"U_InvertAll()" 	, 0, 4}}

//Campos que ser�o exibidos na tela
aCampos := { {'_OK' 	,"",'OK'			},;
			{"TABELA" 	,"",'Tabela' 		},;
            {"TABDESC"	,"",'Descri��o' 	} }

//Campos para criacao do arquivo temporario
aCmpTrb := { {"_OK" 	,"C",02,0},;
			{"TABELA"	,"C",08,0},;
			{"TABDESC"	,"C",75,0} }

oTemptable:SetFields( aCmpTrb )

oTempTable:AddIndex("01", {"TABELA"} )

oTempTable:Create()

// alimenta a tabela tempor�ria
Montagrid()

MarkBrow( 'TRB','_OK',,aCampos,,cMarca,,,,,,,,,,,, )

TRB->( DBCloseArea() )

oTempTable:Delete()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Montagrid     �Autor  �Jose Roberto   � Data �  31/10/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Preenche lista da MarkBrowse                               ���
���          � Tabela temporaria para montagem da MarkBrowse              ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico CAOA- Interface MasterSAF                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Montagrid()

Local cQuery 	:= ''

//Cria��o do insert into
cQuery := "INSERT INTO " + oTempTable:GetRealName()
cQuery += " ( _OK , TABELA , TABDESC ) "
//RODA QUERY PARA LEVANTAR AS TABELAS DO CADASTRO SZR
cQuery += "SELECT DISTINCT '  ' OK , ZQ_TABELA, ZQ_DESCTB FROM "+RetSqlName("SZQ")+" WHERE D_E_L_E_T_ = ' ' AND ZQ_MSBLQL <> '1' "

//Envia o insert into para o banco de dados, portanto toda a c�pia � feita pelo banco de dados, com grande performance!
if TCSqlExec(cQuery) < 0
    ConOut("O comando SQL gerou erro:", TCSqlError())
endif

return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ExpTab        �Autor  �Jose Roberto   � Data �  31/10/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Exporta Tabelas Selecionadas na MarkBrowse                 ���
���          � 												              ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico CAOA- Interface MasterSAF                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		FWMsgRun(, {|| GeraTXT( cTabela ) },'Exporta��o Protheus -> MasterSAF','Gerando arquivo '+alltrim(cTabela)+', aguarde...')
	Endif

	DbSelectArea("TRB")
	TRB->(DBSKIP())
Enddo

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GeraTXT       �Autor  �Jose Roberto   � Data �  31/10/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria a query conforme par�metros no Parambox               ���
���          � 											                  ���
�������������������������������������������������������������������������͹��
���Parametros� 													          ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico CAOA- Interface MasterSAF                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//verifica se existe amarra��o com a View
If Empty(cViewSQL1) .and. Empty(cViewSQL2) .and. Empty(cViewSQL3) .and. Empty(cViewSQL4)
	MsgAlert('N�o existem VIEWS relacionadas a esta tabela - O Arquivo n�o pode ser gerado', "A T E N � � O")
	Return
Else
	//verifica se a view existe no banco
	cQuery := ""
	//verifica se a query est� aberta
	IF Select( "CONFVW" ) > 0
		dbSelectArea( "CONFVW" )
		dbCloseArea()
	EndIF

	cString := ALLTRIM(cViewSQL1)
   	cQuery  := "SELECT * FROM ALL_OBJECTS WHERE OWNER = 'ABDHDU_PROT' AND OBJECT_TYPE = 'VIEW' AND OBJECT_NAME = '"+cString+"' "
 	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "CONFVW", .F., .T.)
	If CONFVW->(eof())
		MsgAlert("A View "+cString+" n�o existe no Banco de Dados. - O Arquivo "+upper(alltrim(cTab))+" n�o pode ser gerado", "A T E N � � O")
		Return
	Endif
Endif

//Trata filtros nas queries - Alguns arquivos MSAF podem ser filtrados por data e outros por produto
DO Case
	Case upper(alltrim(cTab)) == "SAFX07" 	//Arquivo de Notas Fiscais
		cFiltro := " WHERE DATA_SAIDA_REC BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX08"	//Itens Notas Fiscais Mercadorias e Produtos
		cFiltro := " WHERE DATA_FISCAL BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX09"	//Itens Notas Fiscais de Servi�os
		cFiltro := " WHERE DATA_FISCAL BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX10" 	//Arquivo de Controle de Estoque
		cFiltro := " WHERE DATA_MOVTO BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX108"	//Ordem de Produ��o
		cFiltro := " WHERE DT_INI_OP >= '"+dTos(mv_par02)+"' AND DT_FIM_OP <= '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX109"	//Item da Ordem de Produ��o
		cFiltro := " WHERE DT_SAIDA BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX112"	//Observa��es da Nota Fiscal
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX113"	//Ajuste/Outros Valores do Lan�amento Fiscal
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX116"	//Documentos Fiscais Referenciados
		cFiltro := " WHERE DATA_FISCAL BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX118"	//Local de Coleta
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX16" 	//Arquivo de Produtos Cuja Produ��o Utiliza Insumos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX17" 	//Arquivo de Insumos Utilizados na Fabrica��o de Produtos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX18" 	//Arquivo Referente a Embalagem
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2006"	//Tabela de Natureza de Opera��o
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2009"	//Cadastro de Observa��es - Ato COTEPE/ICMS 35/05
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2010"	//Tabela de Natureza de Estoque
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2013"	//Tabela de Produtos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX2018"	//Tabela de C�digo de Servi�os
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX49" 	//Tabela das Opera��es de Importa��o
		cFiltro := " WHERE DAT_ENTRADA BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX52" 	//Arquivo de Invent�rio de Estoque por Produto
		cFiltro := " WHERE DATA_INVENTARIO BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX53" 	//Arquivo de Controle de Tributos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX153"	//Produ��o de Terceiros
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX154"	//Produ��o de Terceiros � Insumos Consumidos
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX235"	//Tabela das Corre��es de Apontamento da EFD - Bloco K.
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX236"	//Tabela de Itens das Corre��es de Apontamento da EFD - Bloco K
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX114"	//Processos Referenciados
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX130"	//Documentos Fiscais Eletr�nicos Denegados ou Inutilizados
		cFiltro := " WHERE DATA_REF BETWEEN '"+dTos(mv_par02)+"' AND '"+dTos(mv_par03)+"' "
	Case upper(alltrim(cTab)) == "SAFX245"	//Tabela dos Valores Declarat�rios do SPED Fiscal (E115/1925)
		cFiltro := ""
	Case upper(alltrim(cTab)) == "SAFX520"	//Situa��o Tribut�ria complementar
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

//verifica se a query est� aberta
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
		MsgAlert('A query n�o retornou registros, por favor verifique os par�metros informados.', "A T E N � � O")
	EndIF
Endif

FClose(nHandle)
IF lGerou
	MSGINFO("Arquivo "+ALLTRIM(cNomeTab)+" gerado com sucesso!!!")
Else
	MSGINFO("N�o foram gerados dados para este arquivo!!")
Endif

//fecha arquivos temporarios
IF Select( "TMPSQL" ) > 0
	dbSelectArea( "TMPSQL" )
	dbCloseArea()
EndIF

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MarcaItem     �Autor  �Jose Roberto   � Data �  31/10/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Seleciona os itens da MarkBrowse        					  ���
���          � 											                  ���
�������������������������������������������������������������������������͹��
���Parametros�  											              ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico CAOA- Interface MasterSAF                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MarcaItem()
//ocal oObj2Mark := getmarkbrow()
Local lDesmarc := IsMark("_OK", cMarca, .t.)

If !lDesmarc
   //Alert('N�o Marcou !!!')

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � InvertAll     �Autor  �Jose Roberto   � Data �  31/10/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Inverte sele��o de Itens no MarkBrowse                     ���
���          � 											                  ���
�������������������������������������������������������������������������͹��
���Parametros�  											              ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico - CAOA-Interface MasterSaf                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
oObjMark:oBrowse:Gotop()	// for�a o posicionamento do browse no primeiro registro

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MarcaTudo     �Autor  �Jose Roberto   � Data �  31/10/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para marcar todos os registros do MarkBrowse        ���
���          � 											                  ���
�������������������������������������������������������������������������͹��
���Parametros�  												          ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico - CAOA-Interface MasterSaf                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
oMark:oBrowse:Gotop()	    // for�a o posicionamento do browse no primeiro registro

return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � DesmrkTudo    �Autor  �Jose Roberto   � Data �  31/10/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para desmarcar todos os registros do MarkBrowse     ���
���          � 											                  ���
�������������������������������������������������������������������������͹��
���Parametros� 													          ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico CAOA- Interface MasterSAF                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
oMark:oBrowse:Gotop()	// for�a o posicionamento do browse no primeiro registro

Return

