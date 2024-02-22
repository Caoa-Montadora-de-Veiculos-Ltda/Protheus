#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
/*/{Protheus.doc} ZESTF015
Fun��o para alterar o Lote na Entrada do Produto
@author Antonio Carlos Pires de Oliveira
@since 31/01/2024
@version 1.0
 @return Nil, Fun��o n�o tem retorno
 @example
 @obs 
/*/
User Function ZESTF015()
 Local aColunas   := {} //Colunas da Grid.
 Local aSeek      := {}
 Local aFieFilter := {}
 //Cria o objeto de apresenta��o do browse
 Local oBrowse

 //Guarda a �rea atual
 Local aArea     := GetArea()

 //Declara a vari�vel para o t�tulo
 Private cTitulo := "Alterar Lote"
 Private cCadastro := "Dados Lotes AUTO**** "
 //Declara a vari�vel cTabela como private para manter seu valor durante toda execu��o da rotina
 Private cTabela := ""

 //Declara o vetor aLegenda como private para manter seu valor durante toda execu��o da rotina
 Private aLegenda:= {}

 //Declara a vari�vel cTabela como private para manter seu valor durante toda execu��o da rotina
 Private _oSay
 Private cOpcoes := ""
 Private aCampos := {}

 //Rotina
 Private aRotina := MenuDef()
 Private aOldRot := iif(Type("aRotina")<>"U",aRotina,{})

 //Define a vari�vel cTab com um valor Default
 Private cArqTRE
 Default cTab    := "TRE"

 //Define o vetor aLeg com um valor Default
 Default aLeg    := {}

 //Define o vetor aLeg com um valor Default
 Default cOpc    := ""

 //Popular Tabela Tempor�ria
 If !ZEST015C()
     Return Nil
 Endif

    //Adiciona as colunas que ser�o exibidas no FWBrowse
    aColunas := fCriaCols()

    TRE->(DbGoTop())
    
    cTabela := cTab
    cOpcoes := cOpc

    //Cria a tabela utilizada no processo
    ChkFile(cTabela)
    //Irei criar a pesquisa que ser� apresentada na tela
    aAdd(aSeek,{"Prod",{{ ""    ,"C"    ,023    ,000    ,"Produto"    ,"@!"   }} } )
    //Inst�nciando FWMBrowse - Somente com dicion�rio de dados
    oBrowse:= FWMBrowse():New()
	oBrowse:SetTemporary(.T.)
	oBrowse:SetMenuDef('ZESTF015')
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("TRE")
    //Setando a descri��o da rotina
    oBrowse:SetDescription(cTitulo)
	oBrowse:SetFields(aColunas)
    oBrowse:SetUseFilter(.T.) //Habilita a utiliza��o do filtro no Browse
    oBrowse:SetFixedBrowse(.T.)
    oBrowse:SetSeek(.T.,aSeek) //Habilita a utiliza��o da pesquisa de registros no Browse
    oBrowse:SetFilterDefault("") //Indica o filtro padr�o do Browse
    oBrowse:SetFieldFilter(aFieFilter)
    //Adicionar Bot�es
    //oBrowse:AddButton("Altera Lote" , {|| ZEST015A() },'Alterar...', , , .F. , 2 )
    oBrowse:AddButton("Visualizar"   , { || FwMsgRun(,{ | _oSay | ZEST015D(_oSay) }, "Visualizar", "Aguarde...")  },,,, .F., 2 )  
	oBrowse:AddButton("Altera  Lote" , { || FwMsgRun(,{ | _oSay | ZEST015A(_oSay) }, "Alterar",    "Aguarde...")  },,,, .F., 2 )  
    oBrowse:AddButton("Sair" , { || ZEST015B() }, , , , .F. , 2 )  
    
    //Ativa a Browse
    oBrowse:Activate()

    //_cHoraIni := Time()
	//_oSay:SetText("Aguarde preparando informa��es - Hora: "+Time())
	//ProcessMessage()


//Limpar o arquivo tempor�rio
If File(cArqTRE)
    If !Empty(cArqTRE)
        Ferase(cArqTRE+GetDBExtension())
        Ferase(cArqTRE+OrdBagExt())
        TRE->(DbCloseArea())
    Endif
endif

RestArea(aArea)

Return Nil


/*/{Protheus.doc} MenuDef
@author A. Carlos
@since 16/02/24
@version  
@type function  Cria��o do menu MVC  
/*/
Static Function MenuDef()
Local aRot := {}

//Adicionando op��es
 //ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ZESTF015' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
 //ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ZESTF015' OPERATION MODEL_OPERATION_UPDATE ACCESS 0
 //ADD OPTION aRot TITLE "Pesquisar" ACTION 'AxPesqui' OPERATION 1 ACCESS 0
	
Return aRot


/*/{Protheus.doc} ViewDef
@author A. Carlos
@since 16/02/24
@version  
@type function  Cria��o do modelo de dados MVC  
/*/
Static Function ModelDef()
 Local nX     := 0
Local aCampos1:= {}
 Local oModel := Nil
 Local oStTMP := FWFormModelStruct():New()
 
 //Instancia o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
 //oModel := FWModelActive()

 //Cria��o da estrutura de dados utilizada na interface
 oStTMP:AddTable("TRE", {'Filial','Produto','Armazem','Lote'}, "Lote")
 //Adiciona os campos da estrutura
 AAdd( aCampos1, {"Filial"  ,"Filial"  ,"Filial"  , "C", 010,0, Nil, Nil, {}, .F.,  ,.F.,.F.,.F.})
 AAdd( aCampos1, {"Produto" ,"Produto" ,"Produto" , "C", 023,0, Nil, Nil, {}, .F.,  ,.F.,.F.,.F.})
 AAdd( aCampos1, {"Armazem" ,"Armazem" ,"Armazem" , "C", 003,0, Nil, Nil, {}, .F.,  ,.F.,.F.,.F.})
 AAdd( aCampos1, {"Lote"    ,"Lote"    ,"Lote"    , "C", 030,0, Nil, {||.T.}, {}, .F.,  ,.F.,.T.,.F.})
 
   For nX := 1 to Len(aCampos1)
    
        oStTmp:AddField(;
            aCampos1[nX ,1 ],;                                             // [01]  C   Titulo do campo
            aCampos1[nX ,2 ],;                                             // [02]  C   ToolTip do campo
            aCampos1[nX ,3 ],;                                             // [03]  C   Id do Field
            aCampos1[nX ,4 ],;                                             // [04]  C   Tipo do campo
            aCampos1[nX ,5 ],;                                             // [05]  N   Tamanho do campo
            aCampos1[nX ,6 ],;                                             // [06]  N   Decimal do campo
            aCampos1[nX ,7 ],;                                             // [07]  B   Code-block de valida��o do campo
            aCampos1[nX ,8 ],;                                             // [08]  B   Code-block de valida��o When do campo
            aCampos1[nX ,9 ],;                                             // [09]  A   Lista de valores permitido do campo
            aCampos1[nX ,10 ],;                                            // [10]  L   Indica se o campo tem preenchimento obrigat�rio
            aCampos1[nX ,11 ],;                                            // [11]  B   Code-block de inicializacao do campo
            aCampos1[nX ,12 ],;                                            // [12]  L   Indica se trata-se de um campo chave
            aCampos1[nX ,13 ],;                                            // [13]  L   Indica se o campo pode receber valor em uma opera��o de update.
            aCampos1[nX ,14 ])                                             // [14]  L   Indica se o campo � virtual
    Next nX

 oModel := MPFormModel():New("ZEF15MDL",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)

 oModel:AddFields( "FORMTRE", /*cOwner*/, oStTmp, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

 //Seta a descri��o do formul�rio
 oModel:GetModel("FORMTRE"):SetDescription(cTitulo)

 oModel:SetPrimaryKey({'TRE_PROD','TRE_ARM','TRE_LOTE'})
 //oModel:SetPrimaryKey({})

Return oModel


/*/{Protheus.doc} ViewDef
@author A. Carlos
@since 16/02/24
@version  
@type function  Cria��o da vis�o MVC  
/*/
Static Function ViewDef()

 //Local oModel := ModelDef()
 //Local oStru  := FWFormStruct(2, cTabela)
 //Local oView  := Nil

    //Local aStruTMP := TRE->(DbStruct())
    Local oModel   := FWLoadModel("ZESTF015")
    Local oStTMP   := FWFormViewStruct():New()
    Local oView    := Nil
    Local aCampos2 := {}
    Local nX       := 0

AAdd(aCampos2,{"Filial"  ,"01","Filial"   ,"Filial"  ,Nil,"C","@!" ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
AAdd(aCampos2,{"Produto" ,"02","Produto"  ,"Produto" ,Nil,"C","@!" ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
AAdd(aCampos2,{"Armazem" ,"03","Armazem"  ,"Armazem" ,Nil,"C","@!" ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})
AAdd(aCampos2,{"Lote"    ,"04","Lote"     ,"Lote"    ,Nil,"C","@!" ,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil})   
   
   For nX := 1 to Len(aCampos2)
        oStTmp:AddField(;
            aCampos2[nX, 1],;                       // [01]  C   Nome do Campo
            aCampos2[nX, 2],;                       // [02]  C   Ordem
            aCampos2[nX, 3],;                       // [03]  C   Titulo do campo
            aCampos2[nX, 4],;                       // [04]  C   Descricao do campo
            aCampos2[nX, 5],;                       // [05]  A   Array com Help
            aCampos2[nX, 6],;                       // [06]  C   Tipo do campo
            aCampos2[nX, 7],;                       // [07]  C   Picture
            aCampos2[nX, 8],;                       // [08]  B   Bloco de PictTre Var
            aCampos2[nX, 9],;                       // [09]  C   Consulta F3
            aCampos2[nX,10],;                       // [10]  L   Indica se o campo � alteravel
            aCampos2[nX,11],;                       // [11]  C   Pasta do campo
            aCampos2[nX,12],;                       // [12]  C   Agrupamento do campo
            aCampos2[nX,13],;                       // [13]  A   Lista de valores permitido do campo (Combo)
            aCampos2[nX,14],;                       // [14]  N   Tamanho maximo da maior op��o do combo
            aCampos2[nX,15],;                       // [15]  C   Inicializador de Browse
            aCampos2[nX,16],;                       // [16]  L   Indica se o campo � virtual
            aCampos2[nX,17],;                       // [17]  C   Picture Variavel
            aCampos2[nX,18])                        // [18]  L   Indica pulo de linha ap�s o campo
    Next nX

    //Cria a view que ser� o retorno da fun��o e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //Atribui formul�rios para interface
    oView:AddField("VIEW_TRE", oStTMP, "FORMTRE")

    //Cria um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)

    //Adiciona o t�tulo do formul�rio
    oView:EnableTitleView("VIEW_TRE", cTitulo)

    //For�a o fechamento da janela na confirma��o
    oView:SetCloseOnOk({||.T.})

    //Aloca o formul�rio da interface dentro do container
    oView:SetOwnerView("VIEW_TRE","TELA")

Return oView


/*/{Protheus.doc} PrmKeyDef
@author A. Carlos
@since 16/02/24
@version  
@type function  Fun��o para determinar a PrimaryKey da entidade Modelo 
/*/
Static Function PrmKeyDef(cTab)

 //Declara o vetor para o receber a chave prim�ria da tabela
 Local aPrmKey := {}

 //Declara a vari�vel para o FOR
 Local nInd

 //Seta a vari�vel com os campo(s) para composi��o do �ndice da tabela
 aRet := FWSIXUtil():GetAliasIndexes(cTab)

 If Len(aRet) > 0

    For nInd:= 1 To Len(aRet[1])
    
        //Adiciona as informa��es em uma �nica linha do array
        aAdd(aPrmKey,aRet[1][nInd])
    
    Next nInd

 EndIf

Return aPrmKey


/*/{Protheus.doc} ZEST015A
//Visualiza dados e incluir o Lote Destino
@author A. Carlos
@since 16/02/24
@version  
@type function   incluir o Lote Destino   
/*/
Static Function ZEST015A(_oSay)
Local aPergs 	  := {}
Local aRet		  := {}
Local cEndOri     := ALLTRIM(TRE->TRE_LOTE)
Local cEndDes	  := Space(30)

    aAdd(aPergs, {9 ,"Lote Origem: " + cEndOri + " Produto: " + ALLTRIM(TRE->TRE_PROD),200, 40,.T.})  
    aAdd(aPergs, {1 ,"Lote Destino" ,Space( TamSX3('B8_LOTECTL')[1] ) ,"@!" ,"" ,"" ,"" ,60 ,.T. })

    //-- Salva estado dos par�metros porque o parambox ira sobrescrever e isso afeta o browse da rotina
	SaveInter() 

    DbSelectArea("SB8")

	If ParamBox( aPergs ,"" ,@aRet )

		cEndDes	:= AllTrim( aRet[2] )

        D14->( DbSetOrder(3) )
        D14->( DbGoTop() )        
	    IF D14->( DbSeek( xFilial("D14") + TRE->TRE_ARM + TRE->TRE_PROD + 'DCE01          '  ) )

            IF D14->D14_ENDER = 'DCE01' .AND. Empty(D14->D14_IDUNIT) .AND. Substr(D14->D14_LOTECT,1,4) = 'AUTO' 

                RecLock("D14", .F.)
                D14->D14_LOTECT := cEndDes 
                D14->( MsUnLock() ) 

                SB8->(DbGoto(TRE->TRE_B8REG))             
                RecLock("SB8", .F.)
                SB8->B8_LOTECTL := cEndDes 
                SB8->( MsUnLock() ) 

                SD1->( DbSetOrder(11) )
                IF SD1->( DbSeek( xFilial("SD1") + SB8->B8_DOC + SB8->B8_SERIE + SB8->B8_CLIFOR + SB8->B8_LOJA + SB8->B8_PRODUTO + cEndOri ) )
                    RecLock("SD1", .F.)
                    SD1->D1_LOTECTL := cEndDes 
                    SD1->( MsUnLock() )    
                ENDIF

                SD5->( DbSetOrder(2) )
                IF SD5->( DbSeek( xFilial("SD5") + TRE->TRE_PROD + TRE->TRE_ARM + cEndOri ) )
                    RecLock("SD5", .F.)
                    SD5->D5_LOTECTL := cEndDes 
                    SD5->( MsUnLock() )          
                ENDIF

            ELSE
                MSGINFO( "Lote n�o alterado por j� haver endere�amento." , "Aten��o" )
            ENDIF

        ELSE
            MSGINFO( "Entrada n�o localizada na D14. Local: " + TRE->TRE_ARM + " Produto: " + TRE->TRE_PROD,"Aten��o" )
        ENDIF
		
    EndIf

Return Nil


/*/{Protheus.doc} ZEST015B
//Encerramento do Browse
@author A. Carlos
@since 16/02/24
@version  
@type function
/*/
Static Function ZEST015B()

	if Type("aRotina")<>"U"
		aRotina := aOldRot
	EndIf

    CloseBrowse()

	//SB8->(RestArea(aArea))

Return()


/*/{Protheus.doc} ZEST015B
//Encerramento do Browse
@author A. Carlos
@since 16/02/24
@version  
@type function    Filtro do browse da rotina Lote = AUTO e SALDO > 0 
/*/
Static Function ZEST015C()
Local cQuery	:= ""
Local cIndice1  := ""
Local cAliasSQL := GetNextAlias()
Local _lRet     := .T. 

	cQuery  :=  "  SELECT D1_FILIAL,D1_COD,D1_LOCAL,D1_LOTECTL,SB8.R_E_C_N_O_ B8REG" + CRLF
	cQuery  +=  "      FROM " +	RetSqlName("SD1") + " SD1 "            + CRLF
	cQuery  +=  "  JOIN " +	RetSqlName("SB8") + " SB8 "                + CRLF
	cQuery  +=  "      ON SB8.B8_FILIAL = SD1.D1_FILIAL "              + CRLF 
	cQuery  +=  "      AND SB8.B8_LOTECTL = SD1.D1_LOTECTL "           + CRLF 
 	cQuery  +=  "      AND SB8.B8_DOC = SD1.D1_DOC "                   + CRLF
	cQuery  +=  "      AND SB8.B8_SERIE = SD1.D1_SERIE "               + CRLF 
 	cQuery  +=  "      AND SB8.B8_CLIFOR = SD1.D1_FORNECE "            + CRLF   
 	cQuery  +=  "      AND SB8.B8_LOJA = SD1.D1_LOJA "                 + CRLF 
	cQuery  +=  "	   AND SB8.B8_SALDO <> 0 "                         + CRLF 
    cQuery  +=  "	   AND SB8.D_E_L_E_T_  = ' ' "                     + CRLF
	cQuery  +=  "  JOIN " +	RetSqlName("D14") + " D14 "                + CRLF
	cQuery  +=  "      ON D14.D14_FILIAL   = SD1.D1_FILIAL  "          + CRLF
	cQuery  +=  "      AND D14.D14_LOCAL   = SD1.D1_LOCAL   "          + CRLF 
	cQuery  +=  "      AND D14.D14_PRODUT  = SD1.D1_COD     "          + CRLF     
	cQuery  +=  "      AND D14.D14_ENDER   = 'DCE01'        "          + CRLF
	cQuery  +=  "      AND D14.D14_LOTECT  = SD1.D1_LOTECTL "          + CRLF 
	cQuery  +=  "      AND D14.D14_IDUNIT  = ' ' "                     + CRLF
    cQuery  +=  "	   AND D14.D_E_L_E_T_  = ' ' "                     + CRLF
    cQuery  +=  "	WHERE SD1.D_E_L_E_T_   = ' ' "                     + CRLF
    cQuery  +=  "	    AND SD1.D1_FILIAL  =  '"+xFilial('SD1')+"'"    + CRLF
    cQuery  +=  "	    AND SD1.D1_TES <> '   ' "                      + CRLF
    cQuery  +=  "       AND SUBSTR(SD1.D1_LOTECTL,1,4) = 'AUTO' "      + CRLF 
    cQuery  +=  "   ORDER BY D1_FILIAL,D1_COD,D1_LOCAL,D1_LOTECTL"     + CRLF

    cQuery := ChangeQuery(cQuery)

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSQL, .T., .T. )

    DbSelectArea((cAliasSQL))
    (cAliasSQL)->(dbGoTop())

    If (cAliasSQL)->(Eof())
        _lRet := .F.
		MSGINFO( "N�o localizado dados para processamento" , "Aten��o" )
        Return _lRet
    Endif

    If !(cAliasSQL)->(Eof())
       
        //Criar a tabela tempor�ria
        AAdd(aCampos,{"TRE_FILIAL"     ,"C",010,0})
        AAdd(aCampos,{"TRE_PROD"       ,"C",023,0})
        AAdd(aCampos,{"TRE_ARM"        ,"C",003,0})
        AAdd(aCampos,{"TRE_LOTE"       ,"C",030,0})
        AAdd(aCampos,{"TRE_B8REG"      ,"N",010,0})        

        //Se o alias estiver aberto, fechar para evitar erros com alias aberto
        If (Select("TRE") <> 0)
            dbSelectArea("TRE")
            TRE->(dbCloseArea())
        Endif

        cArqTRE  := CriaTrab(aCampos,.T.)
        cIndice1 := Alltrim(CriaTrab(,.F.))
        cIndice1 := Left(cIndice1,5) + Right(cIndice1,2) + "A"
        
        If File(cIndice1+OrdBagExt())
            FErase(cIndice1+OrdBagExt())
        EndIf
                    
        dbUseArea(.T.,,cArqTRE,"TRE",Nil,.F.)
        IndRegua("TRE", cIndice1, "TRE_PROD+TRE_ARM+TRE_LOTE" ,,, "Indice Produto...")
        
        //Fecha todos os �ndices da �rea de trabalho corrente.
        dbClearIndex()

        //Acrescenta uma ou mais ordens de determinado �ndice de ordens ativas da �rea de trabalho.
        dbSetIndex(cIndice1+OrdBagExt())
        
        (cAliasSQL)->(dbGoTop())
        While (cAliasSQL)->(!Eof())
            If RecLock("TRE",.t.)
                TRE->TRE_FILIAL  := (cAliasSQL)->D1_FILIAL 
                TRE->TRE_PROD	 := (cAliasSQL)->D1_COD
                TRE->TRE_ARM     := (cAliasSQL)->D1_LOCAL   
                TRE->TRE_LOTE    := (cAliasSQL)->D1_LOTECTL
                TRE->TRE_B8REG   := (cAliasSQL)->B8REG
                TRE->(MsUnLock())
            Endif
        (cAliasSQL)->(DbSkip())
        EndDo
    Endif

Return _lRet


//Cria colunas na Grid.
Static Function fCriaCols()
    Local nAtual   := 0 
    Local aColunas := {}
    Local aEstrut  := {}
    
    //Adicionando campos que ser�o mostrados na tela
    aAdd(aEstrut, { 'TRE_FILIAL', 'Filial' , 'C', 010, 0,"" })
    aAdd(aEstrut, { 'TRE_PROD'  , 'Produto', 'C', 023, 0,"" })
    aAdd(aEstrut, { 'TRE_ARM'   , 'Local'  , 'C', 003, 0,"" })   
    aAdd(aEstrut, { 'TRE_LOTE'  , 'Lotectl', 'C', 030, 0,"" })
    aColunas    := {}
    For nAtual := 1 To Len(aEstrut)
        Aadd(aColunas,{ aEstrut[nAtual,2],;    //titulo
                        aEstrut[nAtual,1],;    //campo
                        aEstrut[nAtual,3],;    //tipo
                        aEstrut[nAtual,4],;    //tamanho
                        aEstrut[nAtual,5],;    //decimal
                        aEstrut[nAtual,6];     //pict
                          })
    Next                      

Return aColunas   //aColunas


/*/{Protheus.doc} ZEST015D
//Encerramento do Browse
@author A. Carlos
@since 16/02/24
@version  
@type function
/*/
Static Function ZEST015D(_oSay)

    DbSelectArea("SB8")
    SB8->(DbGoto(TRE->TRE_B8REG))    
    AxVisual("SB8",SB8->(Recno()),2)

Return()
