#include "protheus.ch"
#include "topconn.ch"
#include "fwbrowse.ch"
#include 'fwmvcdef.ch'

#DEFINE CRLF chr(13) + chr(10)
/*
=====================================================================================
Programa.:              ZCOMF049
Autor....:              A.Carlos
Data.....:              01/01/2022
Descricao / Objetivo:   Consulta SLA-SC
Doc. Origem:            
Solicitante:            Projeto
Obs......:              
=====================================================================================
*/
User Function ZCOMF049()
Local aSeek         := {}
Local aFieFilter    := {}
Local aRet		    := {}
Local aParambox	    := {}

private aArea       := SC1->(GetArea())
private aRotina     := MenuDef()
private aOldRot     := iif(Type("aRotina")<>"U",aRotina,{})
private cCadastro   := "SLA - Solicitação de Compras - CAOA"
private oFWLayer	:= nil
private oDadosBrw	:= nil
private oDespesBrw	:= nil
private oHistorBrw	:= nil
Private bSair       := .F.
Private oGetMemo       
Private cErroInt    := ''
private cPend       := ''
Private oDetBrow
Private aExcel      := {}
Private aExcel2     := {}
Private aErros      := {}

Private aDados	    := {}
Private aItens      := {}
Private aDetalhes   := {}
Private aButtons    := {{"Exporta Excel"   , {|| GeraExcel(1,aExcel)}, "Exporta Excel","Exporta Excel",{|| .T.}}} 
Private dDtAlt      := ctod("  /  /  ")

//Usuario = solicitante, cadastrado na tabela - DbSeek( xFilial("SZX") + cUser + UPPER(Alltrim(cRotina)) ), para não acessar
/*IF U_ZGENUSER( RetCodUsr() ,"ZCOMF049" ,.T.) = .F. 
	RETURN Nil
ENDIF*/

SC1->(dbSetOrder(1))

AAdd( aParamBox,{1,"Solicitação Inicial"         ,Space(tamSx3("C1_NUM")[1]),"@!",,"SC1",,050,.F.})
AAdd( aParamBox,{1,"Solicitação Final  "         ,Space(tamSx3("C1_NUM")[1]),"@!",,"SC1",,050,.F.})
AAdd( aParamBox,{1,"Pedido Inicial"    	         ,Space(tamSx3("C1_PEDIDO")[1]),"@!",,"SC1",,050,.F.})
AAdd( aParamBox,{1,"Pedido Final  "    	         ,Space(tamSx3("C1_PEDIDO")[1]),"@!",,"SC1",,050,.F.})
AAdd( aParamBox,{1,"Centro Custo Inicial"        ,Space(tamSx3("C1_CC")[1]),"@!",,"SC1",,050,.F.})
AAdd( aParamBox,{1,"Centro Custo Final  "        ,Space(tamSx3("C1_CC")[1]),"@!",,"SC1",,050,.F.})
AAdd( aParamBox,{1,"Comprador Inicial"    	     ,Space(tamSx3("C1_CODCOMP")[1]),"@!",,"SC1",,050,.F.})
AAdd( aParamBox,{1,"Comprador Final  "    	     ,Space(tamSx3("C1_CODCOMP")[1]),"@!",,"SC1",,050,.F.})
//AAdd( aParambox,{1,"Data Liberação Inicial"  	 ,Ctod(""),"","","","",050,.F.})
//AAdd( aParambox,{1,"Data Liberação Final"	     ,Ctod(""),"","","","",050,.F.})
//AAdd( aParambox,{1,"Data Pedido Inicial"    	 ,Ctod(""),"","","","",050,.F.})
//AAdd( aParambox,{1,"Data Pedido Final"	         ,Ctod(""),"","","","",050,.F.})
AAdd( aParambox,{1,"Data Solicitação Inicial"  	 ,Ctod(""),"","","","",050,.F.})  //C1_EMISSAO
AAdd( aParambox,{1,"Data Solicitação Final"	     ,Ctod(""),"","","","",050,.F.})  //C1_EMISSAO
AAdd( aParambox,{1,"Tipo Solicitação Inicial"  	 ,Space(tamSx3("C1_XTPREQ")[1]),"@!",,"SC1",,050,.F.})
AAdd( aParambox,{1,"Tipo Solicitação Final"	     ,Space(tamSx3("C1_XTPREQ")[1]),"@!",,"SC1",,050,.F.})
//AAdd( aParambox,{3,"Somente SC não Processada ?" , "S" , { "Sim" , "Nao" },010,"",.T.})

If ParamBox(aParambox, "Filtro SLA - SC"	, @aRet, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .T. /*lUserSave*/)
	
	fwMsgRun(, { || Proc_Dados() }		, "Filtro SLA - SC", "Aguarde.... Selecionando registros..." )
	
	TRB->(DbGoTop())
	If TRB->(Eof())
		MsgAlert('Não há dados para consulta !!')
		Return
	Else
		//Irei criar a pesquisa que será apresentada na tela
		aAdd(aSeek,{"SC",{{ "" , "C" , 006 , 000 , "SOLICITACAO", "@!" }} } )
		//Campos que irão compor a tela de filtro
        Aadd(aFieFilter,{"TR_SC"	 ,"Solicitacao","C"    ,006    ,000    ,"@!"   })
		
		oBrowse:= FWMarkBrowse():New()
		oBrowse:SetDescription(cCadastro) //Titulo da Janela
		oBrowse:SetAlias("TRB") //Indica o alias da tabela que será utilizada no Browse
		//oBrowse:SetFieldMark("TR_OK") //Indica o campo que deverá ser atualizado com a marca no registro
		oBrowse:oBrowse:SetDBFFilter(.T.)
		oBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
		oBrowse:oBrowse:SetFixedBrowse(.T.)
		oBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
		oBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
		oBrowse:SetTemporary(.T.) //Indica que o Browse utiliza tabela temporária
		oBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
		oBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
		oBrowse:oBrowse:SetFieldFilter(aFieFilter)
		oBrowse:DisableDetails()

		//Permite adicionar legendas no Browse
		oBrowse:AddLegend("TR_ST=='I'" , "Pink"    , "Solicitacao Importado")
		oBrowse:AddLegend("TR_ST=='R'" , "Yellow"  , "Aguardando compras/Pedido eliminado")
		oBrowse:AddLegend("TR_ST=='S'" , "GREEN"   , "Solicitacao Pendente")

		//Adiciona uma coluna no Browse em tempo de execução
		//oBrowse:SetColumns(ZCOMF049T("TR_ST"          ," "           ,01 ,"@!"   ,0,001,0))		
		oBrowse:SetColumns(ZCOMF049T("TR_SC"          ,"Solicitação" ,01 ,"@!"   ,0,006,0))
		oBrowse:SetColumns(ZCOMF049T("TR_ITEM"	      ,"Item"		 ,02 ,"@!"   ,1,004,0))
		oBrowse:SetColumns(ZCOMF049T("TR_PRODUTO"     ,"Produto"     ,03 ,"@!"   ,1,023,0))
		oBrowse:SetColumns(ZCOMF049T("TR_DESCR"       ,"Descrição"   ,04 ,"@!"   ,1,015,0))
		oBrowse:SetColumns(ZCOMF049T("TR_EMISSAO"     ,"Emissão"     ,05 ,"D"    ,1,008,0))
		oBrowse:SetColumns(ZCOMF049T("TR_PEDIDO"      ,"Pedido"      ,06 ,"@!"   ,1,006,0))		
		oBrowse:SetColumns(ZCOMF049T("TR_TIPOSC"      ,"Tipo"        ,07 ,"@!"   ,1,004,0))
		oBrowse:SetColumns(ZCOMF049T("TR_DTUALT"      ,"Ult_Atual"   ,09 ,"D!"   ,1,008,0))
		oBrowse:SetColumns(ZCOMF049T("TR_VENCSLA"     ,"Venc.SLA"    ,10 ,"D!"   ,1,008,0))		
		oBrowse:SetColumns(ZCOMF049T("TR_DIASCOR"     ,"Dias_Cor"    ,11 ,"@!"   ,1,004,0))
		oBrowse:SetColumns(ZCOMF049T("TR_COMPRA"      ,"Compra"      ,12 ,"@!"   ,1,006,0))
		oBrowse:SetColumns(ZCOMF049T("TR_NCOMPRA"     ,"Nome"        ,13 ,"@!"   ,1,030,0))		
		oBrowse:SetColumns(ZCOMF049T("TR_SOLICIT"     ,"Solicitante" ,14 ,"@!"   ,1,015,0))
		oBrowse:SetColumns(ZCOMF049T("TR_STATUS"      ,"Status"      ,15 ,"@!"   ,1,060,0))
		
		oBrowse:AddButton("Sair" , { || ZCOMF049S()},,,, .F., 2 )
		//oBrowse:AddButton("Alterar Comprador..."	, { || ZCOMF049C()},,,, .F., 2 )
					
		oBrowse:Activate()
		oBrowse:oBrowse:Setfocus() //Seta o foco na grade
		
        //Limpar o arquivo temporário


		SC1->(RestArea(aArea))

		if Type("aRotina")<>"U"
			aRotina := aOldRot
		EndIf

    EndIf

		//enchoiceBar(oDlgPCP, bOk , bClose,, aButtons)
	//ACTIVATE MSDIALOG oDlgPCP CENTER

Endif
	
Return


**********************************************************************************************************************
Static Function Atualiza

cErroInt := aDados[oDadosBrw:nAt,12]
oGetMemo:Refresh() 

aDetalhes := aDados[oDadosBrw:nAt,12] 
oDetBrow:setArray(aDetalhes)
oDetBrow:Refresh()
oDetBrow:goTop()

Return


**********************************************************************************************************************
Static Function Proc_Dados()
Local cQuery      := ''
Local cStatus     := ""
Local cNro        := ""
Local cRej        := ""
Local nTipo       := 0
Local cTabela 
Local aCampos     := {}
Local cArqTrb
Local cIndice1    := ""
//Local dVenc       := STOD("  /  /    ")

//Criar a tabela temporária
AAdd(aCampos,{"TR_ST"  	       ,"C",001,0}) //Este campo será usado para legenda
AAdd(aCampos,{"TR_SC"  	       ,"C",006,0}) 
AAdd(aCampos,{"TR_ITEM"        ,"C",004,0})
AAdd(aCampos,{"TR_PRODUTO"     ,"C",023,0})
AAdd(aCampos,{"TR_DESCR"       ,"C",025,0})
AAdd(aCampos,{"TR_EMISSAO"     ,"D",008,0})
AAdd(aCampos,{"TR_TIPOSC"      ,"C",004,0})
AAdd(aCampos,{"TR_DTUALT"      ,"D",008,0})
AAdd(aCampos,{"TR_VENCSLA"     ,"D",008,0})
AAdd(aCampos,{"TR_DIASCOR"     ,"N",005,0})
AAdd(aCampos,{"TR_SOLICIT"     ,"C",020,0})
AAdd(aCampos,{"TR_PEDIDO"      ,"C",006,0})
AAdd(aCampos,{"TR_COMPRA"      ,"C",006,0})
AAdd(aCampos,{"TR_NCOMPRA"     ,"C",030,0})
AAdd(aCampos,{"TR_Status"      ,"C",050,0})	

//Se o alias estiver aberto, fechar para evitar erros com alias aberto
If (Select("TRB") <> 0)
	dbSelectArea("TRB")
	TRB->(dbCloseArea())
Endif

cArqTrb  := CriaTrab(aCampos,.T.)
cIndice1 := Alltrim(CriaTrab(,.F.))
cIndice1 := Left(cIndice1,5) + Right(cIndice1,2) + "A"

If File(cIndice1+OrdBagExt())
	FErase(cIndice1+OrdBagExt())
EndIf
			
dbUseArea(.T.,,cArqTrb,"TRB",Nil,.F.)
IndRegua("TRB", cIndice1, "TR_SC+TR_ITEM" ,,, "Indice Produto...")

//Fecha todos os índices da área de trabalho corrente.
dbClearIndex()

//Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho.
dbSetIndex(cIndice1+OrdBagExt())

//Geração de dados via query
aExcel := {}
cQuery := " SELECT C1_NUM,C1_ITEM,C1_PRODUTO,C1_DESCRI,C1_XTPREQ,C1_CODCOMP,C1_XNUMCTP,C1_XCPARCE,C1_PEDIDO,C1_SOLICIT,C1_EMISSAO,C1_CC,SY1.Y1_NOME,ZA4.ZA4_UTEIS,ZA4.ZA4_CORRID CORRID"
cQuery += " , C1_QUJE , C1_COTACAO , C1_APROV , C1_RESIDUO , C1_IMPORT "
cQuery += " FROM "+ RetSQLname("SC1") + " a"
cQuery += " LEFT JOIN " + RetSQLName('ZA4') + " ZA4 "              
cQuery += "     ON  ZA4.ZA4_FILIAL = '" + xFilial("SC1") + "'"
cQuery += "     AND ZA4.ZA4_TPDOC = a.C1_XTPREQ            "
cQuery += "     AND ZA4.D_E_L_E_T_ = ' '                   "
cQuery += "     AND ZA4.ZA4_PROCES = 'CS'                  "
cQuery += " LEFT JOIN " + RetSQLName('SY1') + " SY1 "              
cQuery += "     ON  SUBSTR(a.C1_FILIAL,1,6) = SUBSTR(SY1.Y1_FILIAL,1,6) " 
cQuery += "     AND a.C1_CODCOMP = SY1.Y1_COD              "
cQuery += "     AND SY1.D_E_L_E_T_ = ' '                   "

/*cQuery += " LEFT JOIN " + RetSQLName('SCR') + " SCR "              
cQuery += "     ON  a.C1_FILIAL = SCR.CR_FILIAL            " 
cQuery += "     AND a.C1_PEDIDO = SCR.CR_NUM               "
cQuery += "     AND SCR.CR_TIPO = 'PC'                     "
cQuery += "     AND SCR.CR_STATUS = '06'                   "
cQuery += "     AND SCR.D_E_L_E_T_ = ' '                   "*/

cQuery += " WHERE a.D_E_L_E_T_ = ' ' "
cQuery += "     AND a.C1_APROV <> 'B' "
cQuery += "     AND a.C1_APROV <> 'R' "
cQuery += "     AND a.C1_RESIDUO <> 'S' "

cQuery += IIF(Empty(MV_PAR01),"","  AND C1_NUM >= '"     + MV_PAR01 + "'")
cQuery += IIF(Empty(MV_PAR02),"","  AND C1_NUM <= '"     + MV_PAR02 + "'")
cQuery += IIF(Empty(MV_PAR03),"","  AND C1_PEDIDO >= '"  + MV_PAR03 + "'")
cQuery += IIF(Empty(MV_PAR04),"","  AND C1_PEDIDO <= '"  + MV_PAR04 + "'")
cQuery += IIF(Empty(MV_PAR05),"","  AND C1_CC >= '"      + MV_PAR05 + "'")
cQuery += IIF(Empty(MV_PAR06),"","  AND C1_CC <= '"      + MV_PAR06 + "'")
cQuery += IIF(Empty(MV_PAR07),"","  AND C1_CODCOMP >= '" + MV_PAR07 + "'")
cQuery += IIF(Empty(MV_PAR08),"","  AND C1_CODCOMP <= '" + MV_PAR08 + "'")
cQuery += IIF(Empty(MV_PAR09),"","  AND C1_EMISSAO >= '" + DTOS(MV_PAR09)+"' ")
cQuery += IIF(Empty(MV_PAR10),"","  AND C1_EMISSAO <= '" + DTOS(MV_PAR10)+"' ")
cQuery += IIF(Empty(MV_PAR11),"","  AND C1_XTPREQ >= '"  + MV_PAR11 + "'")
cQuery += IIF(Empty(MV_PAR12),"","  AND C1_XTPREQ <= '"  + MV_PAR12 + "'")
//cQuery += IIF(MV_PAR13==1," AND C1_STATUS = '1' ","")
cQuery += " ORDER BY a.R_E_C_N_O_ desc "

If Select("QRY_SSC") > 0
	QRY_SSC->(dbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY_SSC",.T.,.T.)
dbSelectArea("QRY_SSC")

QRY_SSC->(dbGoTop())

While QRY_SSC->(!Eof())

	cTabela := GetNextAlias()
	dDtAlt  := ctod("  /  /  ")   
	cQry    := " "        
	cQry    := "   SELECT MAX(ZH_DATAI) DATAI           "
	cQry    +=	"        FROM " + RetSQLName("SZH")   + " SZH "
	cQry    +=	" 		    WHERE 	SZH.ZH_FILIAL 	  = '" + xFilial("SZH") + "'"
	cQry    +=	" 			    AND SZH.ZH_ORIGEM     = 'SC' "
	cQry    +=	" 			    AND SZH.ZH_OPER       = 'I'  "
	cQry    +=	" 			    AND SZH.ZH_DOCTO      = '" + QRY_SSC->C1_NUM  + "'"
	cQry    +=	" 		        AND SZH.D_E_L_E_T_  = ' ' "
	cQry    := ChangeQuery(cQry)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cTabela,.T.,.T.)

	If Select(cTabela) > 0
		dDtAlt := (cTabela)->DATAI
	EndIf
	(cTabela)->(DbCloseArea())

	IF !Empty(QRY_SSC->C1_PEDIDO)
		SCR->(dbSetOrder(1))   //FILIAL+TIPO+NUM
		IF SCR->(dbSeek(xFilial("SCR")+"PC"+QRY_SSC->C1_PEDIDO))
			IF SCR->CR_STATUS <> "06"
			    dbSelectArea("QRY_SSC")
				QRY_SSC->(dbSkip())
				LOOP
			ELSE
			    cRej := "S"
			ENDIF
		ENDIF
	ENDIF

	cStatus := ""
	cNro    := ""
	nTipo   := 0

	dDtAlt := SUBSTR(dDtAlt,7,2) + '/' + SUBSTR(dDtAlt,5,2) + '/' + SUBSTR(dDtAlt,1,4) 

	If QRY_SSC->C1_XCPARCE = "S"   .and. Empty(QRY_SSC->C1_XNUMCTP)
		cStatus := "Aguardando Compras"
		nTipo   := 1
	EndIf
	If QRY_SSC->C1_XCPARCE <> "S"  .and. Empty(QRY_SSC->C1_PEDIDO) 
		cStatus := "Aguardando Compras"
		nTipo   := 1
	Endif
	If QRY_SSC->C1_XCPARCE <> "S"  .and. !Empty(QRY_SSC->C1_PEDIDO) .AND. cRej = "S"
		cStatus := "Aguardando compras/Pedido eliminado."
		cNro    := QRY_SSC->C1_PEDIDO
		nTipo   := 2
        cPend   := 'R'
	Endif
	If QRY_SSC->C1_XCPARCE = "S"   .and. !Empty(QRY_SSC->C1_XNUMCTP)
		cStatus := "Contrato de Parceria Criado."
		cNro   := QRY_SSC->C1_XNUMCTP
		nTipo  := 3 
	EndIf

    IF (QRY_SSC->C1_QUJE == 0 .AND. QRY_SSC->C1_COTACAO == SPACE(LEN(QRY_SSC->C1_COTACAO)) .AND. QRY_SSC->C1_APROV $ " ,L" .AND. EMPTY(QRY_SSC->C1_RESIDUO))
        cPend := 'S'
    ENDIF

	IF QRY_SSC->C1_IMPORT = 'S'
        cPend := 'I'
	ENDIF

	/*Do CASE
        Case QRY_SSC->C1_XTPREQ = "ZNOR"
            dVenc := ctod(dDtAlt) + QRY_SSC->CORRID
        Case QRY_SSC->C1_XTPREQ = "ZRES"
            dVenc := ctod(dDtAlt) + QRY_SSC->CORRID
        Case QRY_SSC->C1_XTPREQ = "ZPRI"
            dVenc := ctod(dDtAlt) + QRY_SSC->CORRID
        Case QRY_SSC->C1_XTPREQ = "ZCHE"
            dVenc := ctod(dDtAlt) + QRY_SSC->CORRID
        Case QRY_SSC->C1_XTPREQ = "ZRCO"
            dVenc := ctod(dDtAlt) + QRY_SSC->CORRID
        Case QRY_SSC->C1_XTPREQ = "ZIMP"
            dVenc := ctod(dDtAlt) + QRY_SSC->CORRID			
    ENDCASE*/

    If RecLock("TRB",.t.)
		TRB->TR_ST          := cPend	
		TRB->TR_SC          := QRY_SSC->C1_NUM
		TRB->TR_ITEM 	    := QRY_SSC->C1_ITEM
		TRB->TR_PRODUTO     := QRY_SSC->C1_PRODUTO 
		TRB->TR_DESCR       := QRY_SSC->C1_DESCRI
		TRB->TR_EMISSAO     := STOD(QRY_SSC->C1_EMISSAO)
		TRB->TR_SOLICIT     := QRY_SSC->C1_SOLICIT
		TRB->TR_TIPOSC      := QRY_SSC->C1_XTPREQ
		TRB->TR_DTUALT      := ctod(dDtAlt)
		TRB->TR_VENCSLA     := ctod(dDtAlt) + QRY_SSC->CORRID 
		TRB->TR_DIASCOR     := QRY_SSC->CORRID
		TRB->TR_PEDIDO      := cNro
		TRB->TR_COMPRA      := QRY_SSC->C1_CODCOMP
		TRB->TR_NCOMPRA     := QRY_SSC->Y1_NOME		
		TRB->TR_Status		:= cStatus
		TRB->(MsUnLock())
    Endif

    	/*oDadosBrw:addColumn({"SC"			    , { || aDados[oDadosBrw:nAt,01] }, "C", "@!", 1, 10,, .F.})
		oDadosBrw:addColumn({"Item"		        , { || aDados[oDadosBrw:nAt,02] }, "C", "@!", 1, 10,, .F.})
		oDadosBrw:addColumn({"Descrição"	    , { || aDados[oDadosBrw:nAt,03] }, "C", "@!", 1, 10,, .F.})
		oDadosBrw:addColumn({"SLA"			    , { || aDados[oDadosBrw:nAt,04] }, "C", "@!", 1, 20,, .F.})
		oDadosBrw:addColumn({"Status"			, { || aDados[oDadosBrw:nAt,05] }, "C", "@!", 1, 05,, .F.})
		oDadosBrw:addColumn({"Tipo_SC"			, { || aDados[oDadosBrw:nAt,06] }, "C", "@!", 1, 10,, .F.})
		oDadosBrw:addColumn({"Data_Ult_Alt" 	, { || aDados[oDadosBrw:nAt,07] }, "D", "@!", 1, 10,, .F.})
		oDadosBrw:addColumn({"Vencto_SLA"		, { || aDados[oDadosBrw:nAt,08] }, "C", "@!", 1, 10,, .F.})
		oDadosBrw:addColumn({"Dias C."			, { || aDados[oDadosBrw:nAt,09] }, "C", "@!", 1, 10,, .F.})
		oDadosBrw:addColumn({"Status_SC"		, { || aDados[oDadosBrw:nAt,10] }, "C", "@!", 1, 05,, .F.})
		oDadosBrw:addColumn({"Pedido"  			, { || aDados[oDadosBrw:nAt,11] }, "C", "@!", 1, 20,, .F.})
		oDadosBrw:addColumn({"Comprador"  		, { || aDados[oDadosBrw:nAt,12] }, "C", "@!", 1, 20,, .F.})*/
    dbSelectArea("QRY_SSC")
	QRY_SSC->(dbSkip())
End

Return


***************************************************************************************************************
Static Function GeraExcel(nTipo,aPlanilha)            
Private aAuxZZ  := {}

aAuxZZ := aClone(aPlanilha) 

Gera_ArqExcel(nTipo,aPlanilha)

IF nTipo == 1
    aExcel := aClone(aAuxZZ)
ElseIF nTipo == 2
    aExcel2 := aClone(aAuxZZ)
ElseIF nTipo == 3
    aErros := aClone(aAuxZZ)
EndIF

Return


**********************************************************************************************************************************
Static Function Gera_ArqExcel(nTipo,aPlanilha)

Local aCabDados   := {}
Local oFWMsExcel 
Local nI          := 0
Local cArquivo    :='c:\temp\'

If !ApOleClient("MSExcel")
	MsgAlert("Microsoft Excel não instalado!")
	Return
EndIf         

MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",{||DlgToExcel({ {"ARRAY", 'SLA-SC', aCabDados, aPlanilha} }) })                                          

oFWMsExcel := FWMSExcel():New()
oFWMsExcel:AddworkSheet("SLA-SC") 
oFWMsExcel:AddTable("SLA-SC","Registros")
   
For nI:= 1 To Len(aPlanilha)
	oFWMsExcel:AddRow("SLA-SC","Registros",aPlanilha[nI])
Next nI

oFWMsExcel:Activate()
oFWMsExcel:GetXMLFile(cArquivo)
oExcel := MsExcel():New()             
oExcel:WorkBooks:Open(cArquivo)     
oExcel:SetVisible(.T.)                 
oExcel:Destroy()        
       
Return()


/*
=====================================================================================
Programa.:              ZCOMF008T
Autor....:              A. Oliveira
Data.....:              27/01/2020
Descricao / Objetivo:   Função para criar as colunas do grid
Doc. Origem:            COM101 - Nota Fiscal RGLog
Solicitante:            Logistica
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZCOMF049T(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
Local aColumn
Local bData      := {||}
Default nAlign   := 1
Default nSize    := 20
Default nDecimal := 0
Default nArrData := 0  
        
If nArrData > 0
    bData := &("{||" + cCampo +"}")   //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
EndIf
    
/* Array da coluna
[n][01] Título da coluna
[n][02] Code-Block de carga dos dados
[n][03] Tipo de dados
[n][04] Máscara
[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
[n][06] Tamanho
[n][07] Decimal
[n][08] Indica se permite a edição
[n][09] Code-Block de validação da coluna após a edição
[n][10] Indica se exibe imagem
[n][11] Code-Block de execução do duplo clique
[n][12] Variável a ser utilizada na edição (ReadVar)
[n][13] Code-Block de execução do clique no header
[n][14] Indica se a coluna está deletada
[n][15] Indica se a coluna será exibida nos detalhes do Browse
[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
*/
aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return {aColumn}


/*/{Protheus.doc} ZCOMF049
//Definição do menu - aRotina
@author A. Carlos
@since 16/09/20
@version  
@type function
/*/
Static Function MenuDef()
Local aRotina := {}

	aAdd(aRotina,{'Sair' , 'Encerrar()' , 0 , 4 , 0 , NIL})
	//AAdd(aRotina,{"&Pesquisar", "U_JAxPesqui()", 0, 3})
	//aAdd(aRotina,{'Desmarcar','U_Desmarc' ,0,4,0,NIL})
   
Return aRotina


/*/{Protheus.doc} ZCOMF049
//Encerramento do Browse
@author A. Carlos
@since 16/09/20
@version  
@type function
/*/
Static Function ZCOMF049S()

	if Type("aRotina")<>"U"
		aRotina := aOldRot
	EndIf

    CloseBrowse()

	SC1->(RestArea(aArea))

Return()
