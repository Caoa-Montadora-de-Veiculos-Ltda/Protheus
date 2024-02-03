#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
Static cTitulo := "Troca Lote"
 
/*/{Protheus.doc} 
Função usada para alteração de lote de entrada 
@author CAOA - A.Carlos
@since 31/01/2024
/*/
 
User Function ZESTF015()
    Local aArea   := GetArea()
    Local oBrowse
     
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("SB8")
    oBrowse:SetDescription(cTitulo)
     
    oBrowse:AddButton("Altera Lote" , { || ZESTF15A()},,,, .F., 2 )

    oBrowse:DisableDetails()
    oBrowse:SetAmbiente(.F.)
    oBrowse:SetWalkThru(.F.)
    oBrowse:SetFixedBrowse(.T.)
    oBrowse:SetFilterDefault("@"+FilCabec(SB8->B8_PRODUTO, SB8->B8_LOCAL))

    oBrowse:DisableReport()    
    oBrowse:Activate()
     
    RestArea(aArea)
Return Nil


/*
=====================================================================================
Programa.:              ZESTF15A
Autor....:              A. Oliveira
Data.....:              31/01/2024
Descricao / Objetivo:   Alterar o lote do produto
Doc. Origem:            
Solicitante:            Compras
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZESTF15A()
Local nJanAltu := 230      
Local nJanLarg := 450
Local cLoteDes := SPACE(30)

Private aRadio      := {}
Private _aObsQ      := {}
Private _aArea   := GetArea()

//SB8->( DbSetOrder(1) )
//SB8->( DbGoTop() )

While !SB8->(Eof())

    IF SB8->B8_SALDO = 0 .OR. Substr(SB8->B8_LOTECTL,1,4) <> 'AUTO'
        MsgInfo("Produto fora da regra. "+STR(SB8->B8_SALDO) + " - " + Substr(SB8->B8_LOTECTL,1,4),"Atenção")
        //SB8->( dbSkip() )
        LOOP
    else
        D14->(DbSetOrder(3))  //FILIAL+LOCAL+PRODUT+ENDER
		If D14->(DbSeek(XFilial("D14") + SB8->B8_LOCAL + SB8->B8_PRODUTO))
            IF D14->D14_ENDER <> 'DCE01' .OR. D14->D14_IDUNIT <> ' '
                MsgInfo("Produto fora da regra. " + D14->D14_ENDER  + " - " + STR(D14->D14_IDUNIT),"Atenção")
                //SB8->( dbSkip() )
                LOOP
            ENDIF
		EndIf
    ENDIF   
	_cDescProd := AllTrim(SB1->B1_DESC)

    //Criando a janela
    DEFINE MSDIALOG oDlgSCt TITLE "Alteração do Lote de Produto" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
    
    @ 036,063 SAY "Código do Produto"           OF oDlgSCt PIXEL SIZE 100,010
    @ 033,133 SAY SB8->B8_Produto               OF oDlgSCt PIXEL SIZE 031,006

    @ 056,063 SAY "Lte Destino"                 OF oDlgSCt PIXEL SIZE 100,010
    @ 053,133 msGet cLoteDes                      OF oDlgSCt PIXEL SIZE 031,006
                            
    @ 090, 030  BUTTON oBtnSair PROMPT "Confirmar" SIZE 60, 014 OF oDlgSCt ACTION (lOk := .T.,oDlgSCt:End()) PIXEL 
    @ 090, 140  BUTTON oBtnSair PROMPT "Sair"      SIZE 60, 014 OF oDlgSCt ACTION (lOk := .F.,oDlgSCt:End()) PIXEL

    ACTIVATE MSDIALOG oDlgSCt CENTERED
    
    IF Empty(cLoteDes) 
        ApMsgInfo("Codigo do Lote Destino em branco, A alteração não foi efetivada!!!","[ ZESTF015 ] - Cancelado") 
    EndIf

    IF !Empty(cLoteDes) 
        RecLock("SB8", .F.)
        SB8->B8_LOTEDES := cLoteDes 
        SB8->( MsUnLock() )
    EndIf

    SB8->( dbSkip() )

EndDo

Popular_Temporaria()
TRB->( dbGotop() )
oBrowse:Refresh(.T.) 
Return()



/*
=======================================================================================
Programa.:              FilCabec
Autor....:              CAOA - A.Carlos
Data.....:              31/01/2024
Descricao / Objetivo:   Filtro do browse da rotina gerenciar inventario       
=======================================================================================
*/
Static Function FilCabec(cProduto, cLocal)
	Local cFiltro := ""

	cFiltro  +=  "  B8_FILIAL = '"+xFilial('SB8')+"'" + CRLF 
	cFiltro  +=  "	AND B8_LOTECTL LIKE 'AUTO%' '" + CRLF 
	cFiltro  +=  "	AND B8_SALDO <> 0 " + CRLF 
    cFiltro  +=  "	AND B8.D_E_L_E_T_ = ' ' " + CRLF

Return cFiltro

 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: CAOA - A.Carlos                                              |
 | Data:  31/01/2024                                                   |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ZESTF015' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    //ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMVC01Leg'     OPERATION 6                      ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ZESTF015' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar' ACTION 'VIEWDEF.ZESTF015' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ZESTF015' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: CAOA - A.Carlos                                              |
 | Data:  31/01/2024                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
    Local oModel := Nil
	Local cCampo1 := "B8_FILIAL|B8_QTDORI|B8_PRODUTO|B8_LOCAL|B8_DATA|B8_DTVALID|B8_QTDORI|B8_SALDO|B8_EMPENHO"
    Local cCampo2 := "B8_ORIGLAN|B8_LOTEFOR|B8_CHAVE|B8_NUMLOTE|B8_QEMPPRE|B8_QACLASS|B8_SALDO2|B8_QTDORI2|B8_EMPNH2|B8_QTDORI|B8_QEPRE2"
    Local cCampo3 := "B8_QACLAS2|B8_DOC|B8_SERIE|B8_CLIFOR|B8_LOJA|B8_POTENCI|B8_PRCLOT|B8_ITEM|B8_ORIGEM|B8_NUMDESP|B8_DFABRIC|B8_SDOC"

    Local oStSB8 := FWFormStruct(1, "SB8")
     
    oModel := MPFormModel():New("ZESTF015",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("FORMSB8",/*cOwner*/,oStSB8)
    oModel:SetPrimaryKey({'B8_FILIAL','B8_PRODUTO','B8_LOCAL','B8_LOTECTL','B8_NUMLOTE'})
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
    oModel:GetModel("FORMSB8"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel

 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: CAOA - A.Carlos                                              |
 | Data:  31/01/2024                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    Local oModel := FWLoadModel("ZESTF015")
    Local oStSB8 := FWFormStruct(2, "SB8", ) //{ |cCampo| cCampo $ 'SB8_PRODUTO|SB8_LOTECTL|'})  
    Local oView  := Nil
    Local aCampos:= {}
    Local nX     := 1

    aAdd(aCampos, {"Produto" ,"01" ,"Produto"     ,"Produto"       ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Local"   ,"02" ,"Armazem"     ,"Armazem"       ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })
    aAdd(aCampos, {"Lotectl" ,"03" ,"Lote_Origem" ,"Lote_Origem"   ,Nil ,"C"  ,"@!"              ,Nil ,Nil ,.F. ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil })

    For nX := 1 to Len(aCampos)
        oStSB8:AddField(;
                    aCampos[nX, 01],;              // [01]  C   Nome do Campo
                    aCampos[nX, 02],;              // [02]  C   Ordem
                    aCampos[nX, 03],;              // [03]  C   Titulo do campo
                    aCampos[nX, 04],;              // [04]  C   Descricao do campo
                    aCampos[nX, 05],;              // [05]  A   Array com Help
                    aCampos[nX, 06],;              // [06]  C   Tipo do campo
                    aCampos[nX, 07],;              // [07]  C   Picture
                    aCampos[nX, 08],;              // [08]  B   Bloco de PictTre Var
                    aCampos[nX, 09],;              // [09]  C   Consulta F3
                    aCampos[nX, 10],;             // [10]  L   Indica se o campo é alteravel
                    aCampos[nX, 11],;             // [11]  C   Pasta do campo
                    aCampos[nX, 12],;             // [12]  C   Agrupamento do campo
                    aCampos[nX, 13],;             // [13]  A   Lista de valores permitido do campo (Combo)
                    aCampos[nX, 14],;             // [14]  N   Tamanho maximo da maior opção do combo
                    aCampos[nX, 15],;             // [15]  C   Inicializador de Browse
                    aCampos[nX, 16],;             // [16]  L   Indica se o campo é virtual
                    aCampos[nX, 17],;             // [17]  C   Picture Variavel
                    aCampos[nX, 18])              // [18]  L   Indica pulo de linha após o campo
    Next nX

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_SB8", oStSB8, "FORMSB8")
    oView:CreateHorizontalBox("TROCA LOTE",100)
    oView:EnableTitleView('VIEW_SB8', 'Dados do Produto' )  
    oView:SetCloseOnOk({||.T.})
    oView:SetOwnerView("VIEW_SB8","TROCA LOTE")
Return oView
