#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*
=======================================================================================
Programa.:              ZWMSF015
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Rotina de inclusão dos saldos dos unitizadores para inventario   
=======================================================================================
*/
User Function ZWMSF015()
    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZZL")
    oBrowse:SetMenuDef("ZWMSF015")
    oBrowse:SetDescription("Unitizadores inventario CAOA")
    oBrowse:Activate()

Return

/*
=====================================================================================
Programa.:              MenuDef
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Menu
=====================================================================================
*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet TITLE 'Incluir'     ACTION zSelCSV()  OPERATION MODEL_OPERATION_INSERT  ACCESS 0
    ADD OPTION aRet TITLE 'Visualizar'  ACTION 'VIEWDEF.ZWMSF015'               OPERATION MODEL_OPERATION_VIEW    ACCESS 0
    ADD OPTION aRet TITLE 'Alterar'     ACTION 'VIEWDEF.ZWMSF015'               OPERATION MODEL_OPERATION_UPDATE  ACCESS 0
    ADD OPTION aRet TITLE 'Excluir'     ACTION 'VIEWDEF.ZWMSF015'               OPERATION MODEL_OPERATION_DELETE  ACCESS 0

Return aRet

/*
=====================================================================================
Programa.:              ModelDef
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Model       
=====================================================================================
*/
Static Function ModelDef()
    Local oModel    := Nil
    Local oStruZZI  := FWFormStruct(1, "ZZL")

    oModel := MPFormModel():New("WMSF015MDL",/*bPre*/, /*{|oModel| zVldIncZZI(oModel) }*/,/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("ZZLMASTER",/*cOwner*/,oStruZZI)

    oModel:SetDescription("Unitizadores inventario Caoa")
    oModel:GetModel("ZZLMASTER"):SetDescription("Unitizadores inventario Caoa")
    oModel:SetPrimaryKey({})

Return oModel

/*
=====================================================================================
Programa.:              ViewDef
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   View  
=====================================================================================
*/
Static Function ViewDef()
    Local oModel        := ModelDef()
    Local oStruZZI      := FWFormStruct(2, "ZZL")
    Local oView         := Nil

    //-- Cria View e seta o modelo de dados
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //-- Add cabeçalho
	oView:AddField('VIEW_CAB',oStruZZI,'ZZLMASTER')

    //-- Define os títulos do cabeçalho
    oView:EnableTitleView('VIEW_CAB', "Unitizadores inventario Caoa") 

    //-- Seta o dimensionamento de tamanho
    oView:CreateHorizontalBox('ZZL_DADOS',100)

    //--Amarra a view com as box
    oView:SetOwnerView('VIEW_CAB','ZZL_DADOS')

Return oView

/*
=====================================================================================
Programa.:              zSelCSV
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Abre tela de seleção do arquivo CSV     
=====================================================================================
*/
Static Function zSelCSV()
    Local cTitulo1  := "Selecione o arquivo para Carga "
    Local cExtens   := "Arquivo CSV | *.CSV"
    Local cMainPath := "C:\"
    Local cFileOpen := ""

    If U_ZGENUSER( RetCodUsr() ,"ZWMSF015" ,.T.)
    
        cFileOpen := cGetFile(cExtens,cTitulo1,,cMainPath,.T.)
        If File(cFileOpen)
            Processa({|| zImpCSV(cFileOpen) }, "[ZWMSF015] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." ) 
        Endif

    EndIf

Return

/*
=====================================================================================
Programa.:              zImpCSV
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Processamento do arquivo CSV e commit dos dados           
=====================================================================================
*/
Static Function zImpCSV(cFileOpen)
    Local cLinha        := ""
    Local cSeparador	:= ";"
    Local aDados 		:= {}
    Local nCont         := 0

    FT_FUSE(cFileOpen)
    FT_FGOTOP()
    FT_FSKIP()

    ProcRegua( FT_FLASTREC() )

    ZZL->( DbSetOrder(1) )

    Begin Transaction

        While !FT_FEOF()

            nCont++

            cLinha := FT_FREADLN()
                
            aDados := Separa(cLinha,cSeparador)

            // Incrementa a mensagem na régua.
            IncProc("Efetuando a gravação dos registros!")

            If !( ZZL->( DbSeek( FWxFilial('ZZL') + PadR( aDados[1], TamSX3("ZZL_IDUNIT")[1] ) +  PadR( aDados[2], TamSX3("ZZL_PRODUT")[1] ) ) ) )

                RecLock("ZZL", .T.)
                ZZL->ZZL_FILIAL := FWxFilial("ZZL")
                ZZL->ZZL_IDUNIT := PadR( aDados[1], TamSX3("ZZL_IDUNIT")[1] )
                ZZL->ZZL_PRODUT := PadR( aDados[2], TamSX3("ZZL_PRODUT")[1] ) 
                ZZL->ZZL_QTCONT := Val( aDados[3] )
                ZZL->ZZL_DATA   := dDataBase
                ZZL->ZZL_USER   := RetCodUsr()
                ZZL->( MsUnLock() )

            EndIf

            FT_FSKIP(1)
            
        END

    End Transaction

    //--Fecha arquivo
    FT_FUSE()

Return
