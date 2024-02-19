#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
/*/{Protheus.doc} ZESTF015
Função para alterar o Lote na Entrada do Produto
@author Antonio Carlos Pires de Oliveira
@since 31/01/2024
@version 1.0
 @return Nil, Função não tem retorno
 @example
 @obs 
/*/
User Function ZESTF015() 

 //Cria o objeto de apresentação do browse
 Local oBrowse

 //Guarda a área atual
 Local aArea     := GetArea()

 //Guarda função de chamada anterior
 Local cFunBkp   := FunName()

 //Declara a variável para o título
 Local cTitulo   := ""

 //Declara a variável para o FOR
 Local nLeg

 //Declara a variável cTabela como private para manter seu valor durante toda execução da rotina
 Private cTabela := ""

 //Declara o vetor aLegenda como private para manter seu valor durante toda execução da rotina
 Private aLegenda:= {}

 //Declara a variável cTabela como private para manter seu valor durante toda execução da rotina
 Private cOpcoes := ""
 Private aCampos := {}

 //Rotina
 Private aRotina := MenuDef()
 Private aOldRot := iif(Type("aRotina")<>"U",aRotina,{})

 //Define a variável cTab com um valor Default
 Private cArqTRE
 Default cTab    := "TRE"

 //Define o vetor aLeg com um valor Default
 Default aLeg    := {}

 //Define o vetor aLeg com um valor Default
 Default cOpc    := "4"

 //Popular Tabela Temporária
 ZEST015C()

 (cAliasSQL)->(DbCloseArea())
 TRE->(DbGoTop())
    
 If TRE->(!Eof())

    //Atribui valor a variável cTabela
    cTabela := cTab

    //Atribui valor ao vetor aLegenda
    aLegenda:= aLeg

    //Atribui valor a variável cOpcoes
    cOpcoes := cOpc

    //Seta a função atual
    SetFunName("GenToCad")

    //Cria a tabela utilizada no processo
    ChkFile(cTabela)

    //Força posicionamento na tabela no arquivo SX2
    //PosSx2(cTabela)

    //Define o título da tabela baseado no arquivo SX2
    cTitulo:= Capital(FwSX2Util():GetX2Name(cTabela, .T.))

    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse:= FWMBrowse():New()

    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias(cTabela)

    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Adicionar Botões
    oBrowse:AddButton("Altera Lote" , {|| ZEST015A() },'Alterar...', , , .F. , 2 )
    oBrowse:AddButton("Sair" , { || ZEST015B() }, , , , .F. , 2 )  

    //Legendas
    If Len(aLeg) > 0
    
        For nLeg:= 1 To Len(aLeg)
        
            //Vetor aLeg: aAdd(aLeg{Regra_Legenda,Cor_Legenda,Texto_Legenda})
            oBrowse:AddLegend( aLeg[nLeg,1], aLeg[nLeg,2], aLeg[nLeg,3] )
        
        Next nLeg
    
    EndIf

    //Ativa a Browse
    oBrowse:Activate()

Else
    Return
EndIf

//Limpar o arquivo temporário
If File(cArqTRE)
    If !Empty(cArqTRE)
        Ferase(cArqTRE+GetDBExtension())
        Ferase(cArqTRE+OrdBagExt())
        cArqTRE := " "
        TRE->(DbCloseArea())
    Endif
endif

 //Seta a função de chamada anterior
 SetFunName(cFunBkp)

 RestArea(aArea)

Return Nil


/*/{Protheus.doc} MenuDef
@author A. Carlos
@since 16/02/24
@version  
@type function  Criação do menu MVC  
/*/
Static Function MenuDef()

Local aRot := {}

//Adicionando opções
If Empty(cOpcoes)
 
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.GenToCad' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2

Else
 
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.GenToCad' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
 
EndIf

Return aRot


/*/{Protheus.doc} ViewDef
@author A. Carlos
@since 16/02/24
@version  
@type function  Criação do modelo de dados MVC  
/*/
Static Function ModelDef()

 //Cria o objeto do modelo de dados
 Local oModel := Nil

 //Cria a estrutura de dados utilizada na interface
 Local oStru  := FWFormStruct(1, cTabela)

 //Declara a variável para o verificação de índice único
 Local lIndUnq:= .F.

 //Declara a variável para o receber a chave primária caso a tabela não tenha índice único
 Local aPrmKey:= {}

 //Declara a variável para o título
 Local cTitulo:= ""

 //Declara o Array para verificar se existe índice único para a tabela
 Local aX2Unico := FwSX2Util():GetSX2data(cTabela, {"X2_UNICO"})

 //Verifica se existe índice único para o a tabela
 lIndUnq:= IIF(!Vazio(aX2Unico[1][2]),.T.,.F.)

 //Define o título da tela com base no SX2
 cTitulo:= Capital(FwSX2Util():GetX2Name(cTabela, .T.))

 //Instancia o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
 oModel := MPFormModel():New("Gen"+cTabela,/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)

 oModel:SetPrimaryKey({'B8_FILIAL','B8_PRODUTO','B8_LOCAL','B8_LOTECTL','B8_NUMLOTE'})

 //Atribui formulários para o modelo
 oModel:AddFields("FORM"+cTabela,/*cOwner*/,oStru)

 If !lIndUnq
 
    //Determina a PrimaryKey da entidade Modelo
    aPrmKey:= PrmKeyDef(cTabela)
    
    //Seta a chave primária da rotina
    oModel:SetPrimaryKey(aPrmKey)
 
 EndIf

 //Adiciona a descrição ao modelo
 oModel:SetDescription(cTitulo)

 //Seta a descrição do formulário
 oModel:GetModel("FORM"+cTabela):SetDescription(cTitulo)

Return oModel


/*/{Protheus.doc} ViewDef
@author A. Carlos
@since 16/02/24
@version  
@type function  Criação da visão MVC  
/*/
Static Function ViewDef()

 //Cria o objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
 Local oModel := FWLoadModel("GenToCad")

 //Cria a estrutura de dados utilizada na interface do cadastro de Autor
 Local oStru := FWFormStruct(2, cTabela)

 //Cria o objeto oView como nulo
 Local oView := Nil

 //Declaração de variável para o título
 Local cTitulo := " "

 //Força posicionamento na tabela no arquivo SX2
 //PosSx2(cTabela)

 //Define o título da tela com base no SX2
 //cTitulo:= Capital(AllTrim(FwSX2Util():GetSX2data(cTabela, {"X2_NOME"})))
 cTitulo:= Capital(FwSX2Util():GetX2Name(cTabela, .T.))

    //Cria a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //Atribui formulários para interface
    oView:AddField("VIEW_"+cTabela, oStru, "FORM"+cTabela)

    //Cria um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)

    //Adiciona o título do formulário
    oView:EnableTitleView("VIEW_"+cTabela, cTitulo)

    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})

    //Aloca o formulário da interface dentro do container
    oView:SetOwnerView("VIEW_"+cTabela,"TELA")

Return oView


/*/{Protheus.doc} PrmKeyDef
@author A. Carlos
@since 16/02/24
@version  
@type function  Função para determinar a PrimaryKey da entidade Modelo 
/*/
Static Function PrmKeyDef(cTab)

 //Declara o vetor para o receber a chave primária da tabela
 Local aPrmKey := {}

 //Declara a variável para o FOR
 Local nInd

 //Seta a variável com os campo(s) para composição do índice da tabela
 aRet := FWSIXUtil():GetAliasIndexes(cTab)

 If Len(aRet) > 0

    For nInd:= 1 To Len(aRet[1])
    
        //Adiciona as informações em uma única linha do array
        aAdd(aPrmKey,aRet[1][nInd])
    
    Next nInd

 EndIf

Return aPrmKey


Static Function ZEST015A()

MSGINFO( "Rotina Alter Lote.", "Atenção" )

Return()


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

	cQuery  :=  "  SELECT * FROM ABDHDU_PROT.SD1010 SD1 "   + CRLF
	cQuery  +=  "  INNER JOIN SB8010 SB8 "                  + CRLF
	cQuery  +=  "      ON B8_FILIAL = '"+xFilial('SB8')+"'" + CRLF 
 	cQuery  +=  "      AND SB8.B8_DOC = SD1.D1_DOC "        + CRLF
	cQuery  +=  "      AND SB8.B8_SERIE = SD1.D1_SERIE "    + CRLF   
	cQuery  +=  "      AND SB8.B8_LOTECTL LIKE 'AUTO%' "    + CRLF 
	cQuery  +=  "	    AND B8_SALDO <> 0 "                 + CRLF 
    cQuery  +=  "	    AND B8.D_E_L_E_T_ = ' ' "           + CRLF
    cQuery  +=  "	WHERE SD1.D1_TES <> '   ' "             + CRLF
    cQuery  +=  "	    AND SD1.D_E_L_E_T_ = ' ' "          + CRLF

    cQuery := ChangeQuery(cQuery)

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSQL, .T., .T. )

    DbSelectArea((cAliasSQL))
    (cAliasSQL)->(dbGoTop())

    If !(cAliasSQL)->(Eof())
       
        //Criar a tabela temporária
        AAdd(aCampos,{"TRE_FILIAL"     ,"C",010,0})
        AAdd(aCampos,{"TRE_PROD"       ,"C",023,0})
        AAdd(aCampos,{"TRE_ARMAZEM"    ,"C",002,0})
        AAdd(aCampos,{"TRE_LOTE"       ,"C",030,0})

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
        IndRegua("TRE", cIndice1, "TRE_PROD" ,,, "Indice Produto...")
        
        //Fecha todos os índices da área de trabalho corrente.
        dbClearIndex()

        //Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho.
        dbSetIndex(cIndice1+OrdBagExt())
        
        (cAliasSQL)->(dbGoTop())
        While (cAliasSQL)->(!Eof())
            If RecLock("TRE",.t.)
                TRE->TRE_FILIAL  := (cAliasSQL)->B8_FILIAL 
                TRE->TRE_PROD	 := (cAliasSQL)->B8_PRODUTO
                TRE->TRE_ARMAZEM := (cAliasSQL)->B8_LOCAL   
                TRE->TRE_LOTE    := (cAliasSQL)->B8_LOTECTL
                TRE->(MsUnLock())
            Endif
        (cAliasSQL)->(DbSkip())
        EndDo
    Endif

    If !Empty(cArqTRE)
       Ferase(cArqTRE+GetDBExtension())
       Ferase(cArqTRE+OrdBagExt())
       cArqTRE := " "
       TRE->(DbCloseArea())
    Endif

Return cQuery
