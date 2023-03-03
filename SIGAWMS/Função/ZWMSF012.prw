#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*
=====================================================================================
Programa.:              ZWMSF012
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              25/09/2020
Descricao / Objetivo:   Browse para importação e visualização dos registros
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
User Function ZWMSF012()
    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZZH")
    oBrowse:SetDescription("Importar Codigo de Barra Chery")
    oBrowse:SetMenuDef("ZWMSF012")
    oBrowse:Activate()

Return

/*
=====================================================================================
Programa.:              MenuDef
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              25/09/2020
Descricao / Objetivo:   Menu
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet TITLE 'Visualizar'      ACTION 'VIEWDEF.ZWMSF012'   OPERATION MODEL_OPERATION_VIEW      ACCESS 0
    ADD OPTION aRet TITLE 'Importar CSV'    ACTION 'U_ZWMS012A()'       OPERATION MODEL_OPERATION_INSERT    ACCESS 0

Return aRet

/*
=====================================================================================
Programa.:              ModelDef
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              25/09/2020
Descricao / Objetivo:   Modelo de dados
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function ModelDef()
    Local oModel    := Nil
    Local oStruSZN  := FWFormStruct(1, "ZZH")

    oModel := MPFormModel():New("WMSF012MDL",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("ZZHMASTER",/*cOwner*/,oStruSZN)

    oModel:SetDescription("Importar CSV")
    oModel:GetModel("ZZHMASTER"):SetDescription("Importar CSV")
    oModel:SetPrimaryKey({})

Return oModel

/*
=====================================================================================
Programa.:              ViewDef
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              25/09/2020
Descricao / Objetivo:   View
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function ViewDef()
    Local oModel        := ModelDef()
    Local oStruSZN      := FWFormStruct(2, "ZZH")
    Local oView         := Nil

    //-- Cria View e seta o modelo de dados
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //-- Add cabeçalho
	oView:AddField('VIEW_CAB',oStruSZN,'ZZHMASTER')

    //-- Define os títulos do cabeçalho
    oView:EnableTitleView('VIEW_CAB', "Importar CSV") 

    //-- Seta o dimensionamento de tamanho
    oView:CreateHorizontalBox('ZZH_DADOS',100)

    //--Amarra a view com as box
    oView:SetOwnerView('VIEW_CAB','ZZH_DADOS')

Return oView

/*
=====================================================================================
Programa.:              ZWMS012A
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              25/09/2020
Descricao / Objetivo:   Seleção do arquivo CSV
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
User Function ZWMS012A()
    Local cTitulo1  := "Selecione o arquivo para Carga "
    Local cExtens   := "Arquivo CSV | *.CSV"
    Local cMainPath := "C:\"
    Local cFileOpen := ""

    If U_ZGENUSER( RetCodUsr() ,"ZWMS012A" ,.T.)
    
        cFileOpen := cGetFile(cExtens,cTitulo1,,cMainPath,.T.)
        If File(cFileOpen)
            Processa({|| ZWMS012B(cFileOpen) }, "[ZWMS012A] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." ) 
        Endif

    EndIf

Return

/*
=====================================================================================
Programa.:              ZWMS012B
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              25/09/2020
Descricao / Objetivo:   Processamento do arquivo CSV e commit dos dados
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function ZWMS012B(cFileOpen)
    Local cLinha        := ""
    Local cSeparador	:= ";"  // Separador do arquivo 
    Local aDados 		:= {}   // Array dos dados da linha do laco
    Local aDadosLi      := {}	
    Local nI            := 0
    Local cProduto      := ""
    Local cArqLog       := SubStr(AllTrim(cFileOpen),1,At(".csv",cFileOpen))+"_log_"+StrTran(AllTrim(Time()),":","")+"_.csv"
    Local cLog          := ""
    Local aLinhas       := {}

    SB1->( DbSetOrder(1) ) //--B1_FILIAL+B1_COD
    ZZH->( DbSetOrder(1) ) //--ZZH_FILIAL+ZZH_CODBID+ZZH_CODBOX+ZZH_PRODUT+ZZH_QTD

    FT_FUSE(cFileOpen)
    FT_FGOTOP()
    FT_FSKIP()
        
    While !FT_FEOF()
            
        cLinha := FT_FREADLN()

        //--Verifico se ha registro duplicado no arquivo CSV
        If aScan(aLinhas,cLinha) > 0
            GrvLog(cArqLog, "Registro " + cLinha + " duplicado no arquivo csv.")
            MsgAlert("Falha na importação dos registros, por favor, consulte arquivo de log!")
            Return
        Endif

        //--Gravo a linha para verificar se ha registro duplicado no arquivo CSV
        aAdd( aLinhas, cLinha )
                        
        aDados := Separa(cLinha,cSeparador)
        aAdd(aDadosLi, aDados)

        FT_FSKIP(1)
        
    END

    FT_FUSE()

    ProcRegua( Len(aDadosLi) )

    Begin Transaction

        For nI := 1 To Len(aDadosLi)

            // Incrementa a mensagem na régua.
            IncProc("Efetuando a gravação dos registros!")

            cProduto := StrTran(AllTrim(aDadosLi[nI][6]),"-","")

            If SB1->( DbSeek( FwXFilial("SB1") + Padr(cProduto, TamSX3("B1_COD")[1]) ) )

                If ZZH->( DbSeek( FwXFilial("ZZH") +;
                        PadR(aDadosLi[nI][2]    ,TamSX3("ZZH_CODBID")[1])   +;
                        PadR(aDadosLi[nI][5]    ,TamSX3("ZZH_CODBOX")[1])   +;
                        PadR(cProduto           ,TamSX3("ZZH_PRODUT")[1])   +;
                        PadR(aDadosLi[nI][7]    ,TamSX3("ZZH_QTD")[1]) ) )

                    cLog := "Registro Cod. Bar. Unit: " + aDadosLi[nI][2] +;
                            " Cod. Bar. Box: " + aDadosLi[nI][5] +;
                            " Produto: " + cProduto +;
                            " Qtd: " + aDadosLi[nI][7] +;
                            " ja existe no sistema!"
                    GrvLog(cArqLog, cLog)
                Else
                    //-- Gravação dos dados	
                    RecLock("ZZH",.T.)
                        ZZH->ZZH_FILIAL :=  FwXFilial()
                        ZZH->ZZH_CONTAI :=  aDadosLi[nI][1]
                        ZZH->ZZH_CODBID :=  aDadosLi[nI][2]
                        ZZH->ZZH_IDUNIT :=  aDadosLi[nI][3]
                        ZZH->ZZH_BOX    :=  aDadosLi[nI][4] 
                        ZZH->ZZH_CODBOX :=  aDadosLi[nI][5]
                        ZZH->ZZH_PRODUT :=  cProduto
                        ZZH->ZZH_QTD    :=  Val(aDadosLi[nI][7]) 
                        ZZH->ZZH_RANGE	:=  SB1->B1_XRANGE
                        ZZH->ZZH_DESPRD :=  SB1->B1_DESC
                        ZZH->ZZH_DATA   :=  dDataBase
                        ZZH->ZZH_HORA   :=  Time()
                        ZZH->ZZH_USRIMP :=  cUserName
                    ZZH->( MsUnLock() )	

                EndIf

            Else
                cLog := "Produto " + cProduto + " não foi localizado no Protheus!"
                GrvLog(cArqLog, cLog)
            EndIf

        Next

        If !Empty(cLog)
            MsgAlert("Falha na importação dos registros, por favor, consulte arquivo de log!")
            Disarmtransaction()
        EndIf

    End Transaction

Return

/*
=====================================================================================
Programa.:              GrvLog
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              25/09/2020
Descricao / Objetivo:   Gravação de log de erro
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function GrvLog( cArq , cLog )
    Local nHandle 	    := 0
    Local cDrive		:= ""
    Local cDir			:= ""
    Local cNomeArq		:= ""
    Local cExt			:= ""

    cArq := StrTran(Alltrim(cArq)," ","")

    If !File( cArq )

        // -- Tratamento para diretorios
        
        SplitPath( cArq , @cDrive, @cDir, @cNomeArq, @cExt )
        MontaDir(cDir)

        nHandle := FCreate( cArq )
        FClose( nHandle )	

    Endif

    If File( cArq )

        nHandle := FOpen( cArq, 2 )
        FSeek ( nHandle, 0, 2 )			// Posiciona no final do arquivo.
        
        FWrite( nHandle, cLog + CRLF, Len(cLog) + 2 )
        
        FClose( nHandle )
        
    EndIf

Return Nil
