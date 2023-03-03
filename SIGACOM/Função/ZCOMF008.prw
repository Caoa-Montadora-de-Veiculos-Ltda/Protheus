#Include "PROTHEUS.CH"
#include 'topconn.ch'
#INCLUDE "FWMVCDEF.CH"

/*
=====================================================================================
Programa.:              ZCOMF008
Autor....:              A. Oliveira
Data.....:              27/01/2020
Descricao / Objetivo:   Remessa para RGLOG
Doc. Origem:            COM101 - Nota Fiscal p/ RGLog da movimenta��o diaria
Solicitante:            Logistica
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
//Parametros: 06
//Condicao       CMV_COM011, 025
//Transportadora CMV_COM012, 000002
//Natureza       CMV_COM014, 2101
//TesNfs         CMV_COM010, 566
//CliNfs         CMV_COM008, 000001/01
//LjaNfs         CMV_COM008, 000001/01
//LocOri         CMV_COM009, 180   -  Armazem de Origem
//LocDes         CMV_COM013, 181   -  C�digo local RGLog 
User Function ZCOMF008()

//Declarar vari�veis locais
Local aCampos       := {}
Local cArqTrb
Local cIndice1      := ""
Local lMarcar  	    := .F.
Local aSeek         := {}
Local aFieFilter    := {}
Local cLocDes       := SuperGetMv("CMV_COM013",.F.,"181") //000002    -  C�digo local RGLog  
Local cQuery		:= ""
Local cAliasSQL		:= GetNextAlias()
//Declarar vari�veis privadas
Private oBrowse 	:= Nil
Private cCadastro 	:= "PVs para Notas Fiscais para Retorno RGLog"
Private aParamBox   := {}
Private aRetPer     := ""
Private cAliasINV   := 'TRB'

//aAdd(aParamBox,{ 1, "Filial"     , Space(2), "@!", "", "","", 25	,.T.})
//aAdd(aParamBox,{ 1, "Serie"      , Space(3), "@!", "", "","", 25	,.T.})
aAdd(aParamBox,{ 1, "Emissao ", CtoD(''), "@D", "", "","", 50	,.T.})

If !ParamBox(aParamBox, "Par�metros", @aRetPer )
	Return Nil
EndIf

    If Select( (cAliasSQL) ) > 0
        (cAliasSQL)->(DbCloseArea())
    EndIf

    //cQuery += " AND SD3.D3_CF       = 'RE1' "                                                        + CRLF
    //cQuery += " AND SD3.XPROCNF     = ' ' "                                                          + CRLF
    //, R_E_C_N_O_ REGISTRO
    //cQuery += " GROUP BY SD3.D3_COD, SD3.D3_LOCAL "                                                    + CRLF
    cQuery := " SELECT D3_COD COD, D3_LOCAL ZLOCAL, SUM(D3_QUANT) QTDE, D3_DOC DOC"                    + CRLF
    cQuery += " FROM " + RetSQLName('SD3') + " SD3"                                                    + CRLF
    cQuery += " WHERE SD3.D3_FILIAL = '" + FWxFilial('SD3') + "' "                                     + CRLF
    cQuery += " AND SD3.D3_LOCAL    = '" + cLocDes + "' "                                              + CRLF
    cQuery += " AND SD3.D3_EMISSAO  = '" + Dtos(aRetper[1]) + "' "                                     + CRLF   
    cQuery += " AND SD3.D3_ESTORNO <> 'S' "                                                            + CRLF
    cQuery += " AND SD3.D3_XPEDIDO  = ' ' "                                                            + CRLF
    cQuery += " AND SD3.D_E_L_E_T_  = ' ' "                                                            + CRLF
    cQuery += " GROUP BY SD3.D3_COD, SD3.D3_LOCAL, SD3.D3_DOC "                                        + CRLF
    cQuery += " ORDER BY SD3.D3_COD, SD3.D3_LOCAL, SD3.D3_DOC "                                        + CRLF
    cQuery := ChangeQuery(cQuery)

    // Executa a consulta.
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSQL, .T., .T. )

    DbSelectArea((cAliasSQL))
    (cAliasSQL)->(dbGoTop())
    If !(cAliasSQL)->(Eof())
        
        //Criar a tabela tempor�ria
        AAdd(aCampos,{"TR_OK"  	    ,"C",002,0}) //Este campo ser� usado para marcar/desmarcar
        AAdd(aCampos,{"TR_COD" 	    ,"C",023,0})
        AAdd(aCampos,{"TR_LOCAL"    ,"C",003,0})
        AAdd(aCampos,{"TR_QTDE"     ,"N",020,4})
        AAdd(aCampos,{"TR_DOC"      ,"C",009,0})
        //AAdd(aCampos,{"TR_NFSAIDA"  ,"C",013,0})

        //Se o alias estiver aberto, fechar para evitar erros com alias aberto
        If (Select("TRB") <> 0)
            dbSelectArea("TRB")
            TRB->(dbCloseArea())
        Endif

        //A fun��o CriaTrab() retorna o nome de um arquivo de trabalho que ainda n�o existe e dependendo dos par�metros passados, pode criar um novo arquivo de trabalho.
        cArqTrb  := CriaTrab(aCampos,.T.)

        //Criar indices
        cIndice1 := Alltrim(CriaTrab(,.F.))
        
        cIndice1 := Left(cIndice1,5) + Right(cIndice1,2) + "A"
        
        //Se indice existir excluir
        If File(cIndice1+OrdBagExt())
            FErase(cIndice1+OrdBagExt())
        EndIf
                    
        //A fun��o dbUseArea abre uma tabela de dados na �rea de trabalho atual ou na primeira �rea de trabalho dispon�vel
        dbUseArea(.T.,,cArqTrb,"TRB",Nil,.F.)

        //A fun��o IndRegua cria um �ndice tempor�rio para o alias especificado, podendo ou n�o ter um filtro
        IndRegua("TRB", cIndice1, "TR_COD"	    ,,, "Indice Produto...")
        
        //Fecha todos os �ndices da �rea de trabalho corrente.
        dbClearIndex()

        //Acrescenta uma ou mais ordens de determinado �ndice de ordens ativas da �rea de trabalho.
        dbSetIndex(cIndice1+OrdBagExt())
        
        //Popular tabela tempor�ria, irei colocar apenas um unico registro
        (cAliasSQL)->(dbGoTop())
        While (cAliasSQL)->(!Eof())
            If RecLock("TRB",.t.)
                TRB->TR_OK          := "  "
                TRB->TR_COD         := (cAliasSQL)->COD
                TRB->TR_LOCAL 	    := (cAliasSQL)->ZLOCAL
                TRB->TR_QTDE        := (cAliasSQL)->QTDE 
                TRB->TR_DOC         := (cAliasSQL)->DOC 
                //TRB->TR_CUSTO       := (cAliasSQL)->CUSTO
                //TRB->TR_NFSAIDA     := (cAliasSQL)->NFSAIDA   //"999999999/1   "
                TRB->(MsUnLock())
            Endif
        (cAliasSQL)->(DbSkip())
        EndDo
        (cAliasSQL)->(DbCloseArea())
            
        TRB->(DbGoTop())
        If TRB->(!Eof())
            
            //Irei criar a pesquisa que ser� apresentada na tela
            aAdd(aSeek,{"Doc"	        ,{{ ""    ,"C"    ,023    ,000    ,"Produto"    ,"@!"   }} } )
                    
            //Campos que ir�o compor a tela de filtro
            Aadd(aFieFilter,{"TR_COD"	,"Produto","C"    ,023    ,000    ,"@!"   })
            
            //Agora iremos usar a classe FWMarkBrowse
            oBrowse:= FWMarkBrowse():New()
            oBrowse:SetDescription(cCadastro) //Titulo da Janela
            oBrowse:SetAlias("TRB") //Indica o alias da tabela que ser� utilizada no Browse
            oBrowse:SetFieldMark("TR_OK") //Indica o campo que dever� ser atualizado com a marca no registro
            oBrowse:oBrowse:SetDBFFilter(.T.)
            oBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utiliza��o do filtro no Browse
            oBrowse:oBrowse:SetFixedBrowse(.T.)
            oBrowse:SetWalkThru(.F.) //Habilita a utiliza��o da funcionalidade Walk-Thru no Browse
            oBrowse:SetAmbiente(.T.) //Habilita a utiliza��o da funcionalidade Ambiente no Browse
            oBrowse:SetTemporary() //Indica que o Browse utiliza tabela tempor�ria
            oBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utiliza��o da pesquisa de registros no Browse
            oBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padr�o do Browse
            oBrowse:oBrowse:SetFieldFilter(aFieFilter)
            oBrowse:DisableDetails()

            //Permite adicionar legendas no Browse
            //oBrowse:AddLegend("TR_ST=='N'","GREEN" 	,"Usu�rios Liberados")
            //oBrowse:AddLegend("TR_ST=='S'","RED"   	,"Usu�rios Bloqueados")

            //Adiciona uma coluna no Browse em tempo de execu��o
            oBrowse:SetColumns(ZCOMF008T("TR_COD"	    ,"Produto"              ,02 ,"@!"   ,0,023,0))
            oBrowse:SetColumns(ZCOMF008T("TR_LOCAL"	    ,"Local"		        ,03 ,"@!"   ,1,003,0))
            oBrowse:SetColumns(ZCOMF008T("TR_QTDE"      ,"Quantidade Acumulada" ,04 ,       ,1,020,0))
            //oBrowse:SetColumns(ZCOMF008T("TR_NFSAIDA"   ,"Nota Fiscal de Saida" ,08 ,"@!"   ,1,013,0))
        
            //Adiciona botoes na janela
            oBrowse:AddButton("Gerar PV..."	, { || ZCOMF008G()},,,, .F., 2 )
                    
            //Indica o Code-Block executado no clique do header da coluna de marca/desmarca
            oBrowse:bAllMark := { || ZCOMF008I(oBrowse:Mark(),lMarcar := !lMarcar ), oBrowse:Refresh(.T.)  }

            //M�todo de ativa��o da classe
            oBrowse:Activate()
            
            oBrowse:oBrowse:Setfocus() //Seta o foco na grade
        Else
            Return
        EndIf

        //Limpar o arquivo tempor�rio
        If !Empty(cArqTrb)
            Ferase(cArqTrb+GetDBExtension())
            Ferase(cArqTrb+OrdBagExt())
            cArqTrb := ""
            TRB->(DbCloseArea())
        Endif
    Else
        Alert("N�o existem movimentos de estoque para processamento com os par�metros informados, revise os par�metros!.")
    EndIf

Return(.T.)    


/*
=====================================================================================
Programa.:              ZCOMF008I
Autor....:              A. Oliveira
Data.....:              27/01/2020
Descricao / Objetivo:   Fun��o para marcar/desmarcar todos os registros do grid
Doc. Origem:            COM101 - Nota Fiscal RGLog
Solicitante:            Logistica
Uso......:              U_ZCOMF008
Obs......:
=====================================================================================
*/
Static Function ZCOMF008I(cMarca,lMarcar)
Local aAreaINV  := (cAliasINV)->( GetArea() )

dbSelectArea(cAliasINV)
(cAliasINV)->( dbGoTop() )
While !(cAliasINV)->( Eof() )
    RecLock( (cAliasINV), .F. )
    (cAliasINV)->TR_OK := IIf( lMarcar, cMarca, '  ' )
    MsUnlock()
    (cAliasINV)->( dbSkip() )
EndDo
RestArea( aAreaINV )

Return(.T.)


/*
=====================================================================================
Programa.:              ZCOMF008T
Autor....:              A. Oliveira
Data.....:              27/01/2020
Descricao / Objetivo:   Fun��o para criar as colunas do grid
Doc. Origem:            COM101 - Nota Fiscal RGLog
Solicitante:            Logistica
Uso......:              U_ZCOMF008
Obs......:
=====================================================================================
*/
Static Function ZCOMF008T(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
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
[n][01] T�tulo da coluna
[n][02] Code-Block de carga dos dados
[n][03] Tipo de dados
[n][04] M�scara
[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
[n][06] Tamanho
[n][07] Decimal
[n][08] Indica se permite a edi��o
[n][09] Code-Block de valida��o da coluna ap�s a edi��o
[n][10] Indica se exibe imagem
[n][11] Code-Block de execu��o do duplo clique
[n][12] Vari�vel a ser utilizada na edi��o (ReadVar)
[n][13] Code-Block de execu��o do clique no header
[n][14] Indica se a coluna est� deletada
[n][15] Indica se a coluna ser� exibida nos detalhes do Browse
[n][16] Op��es de carga dos dados (Ex: 1=Sim, 2=N�o)
*/
aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return {aColumn}


/*
=====================================================================================
Programa.:              ZCOMF008G
Autor....:              A. Oliveira
Data.....:              27/01/2020
Descricao / Objetivo:   Gera Pedido de Vendas e Notas Fiscais
Doc. Origem:            COM101 - Nota Fiscal RGLog
Solicitante:            Logistica
Uso......:              U_ZCOMF008
Obs......:
=====================================================================================
*/

Static Function ZCOMF008G()
Local nOpr          := 3  // N�MERO DA OPERA��O (INCLUS�O)
Local aHeader       := {} // INFORMA��ES DO CABE�ALHO
Local aLine         := {} // INFORMA��ES DA LINHA
Local aItems        := {} // CONJUNTO DE LINHAS
Local aTrbLid       := {} // CONJUNTO DE LINHAS
Local cCod          := ""
Local cItem         := ""
Local cPed          := ""   
Local nT            := 0
Local nY            := 0
Private cCond       := SuperGetMv("CMV_COM011",.F.,"025")   
Private cTransp     := SuperGetMv("CMV_COM012",.F.,"000002")
Private cNaturez    := SuperGetMv("CMV_COM014",.F.,"2101")
Private cTesNfs     := SuperGetMv("CMV_COM010",.F.,"566")
Private cCliNfs     := Substring(SuperGetMv("CMV_COM008",.F.,"000001/01"),01,06)
Private cLjaNfs     := Substring(SuperGetMv("CMV_COM008",.F.,"000001/01"),08,02)
Private cPedido     := Space(06)

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

//SA1 - Cadastro de Clientes
DbSelectArea("SA1")
SA1->(dbSetOrder(1)) 

//SC5 - Cabe�alho do PV
dbSelectArea("SC5")
SC5->(DbSetOrder(1))

//SC6 - Itens do PV
dbSelectArea("SC6")
SC6->(DbSetOrder(1))

//SF4 - TES
dbSelectArea("SF4")
SF4->(DbSetOrder(1))

//SE4 - COND. PAGAMENTO
DbSelectArea("SE4")
SE4->(DbSetOrder(1))

//SB1 - Cadastro de Produto
dbSelectArea("SB1")
SB1->(DbSetOrder(1))

//SB2 - Saldos em Estoque
dbSelectArea("SB2")
SB2->(DbSetOrder(1))

//SC9 - Libera��es de Pedidos
dbSelectArea("SC9")
SC9->(DbSetOrder(1))

Begin Transaction
//Tabela temporaria.
TRB->( DbSetOrder(1) )
TRB->( DbGoTop() )
While !TRB->(Eof())

    If !Empty(TRB->TR_OK) //Se diferente de vazio, � porque foi marcado
        
        IF TRB->TR_COD <> cCod 
           cCod   := TRB->TR_COD
        ENDIF

        RecLock( (cAliasINV), .F. )
        (cAliasINV)->TR_OK := '  '
        MsUnlock()

        SB2->(DbSetOrder(1))
        If !SB2->(DbSeek(xFilial("SB2")+TRB->TR_COD+TRB->TR_LOCAL))
            MsgInfo( "Codigo n�o encontrado nos saldos (Fisico/Financeiro)! ", "[ ZCOMF008 ] - Aviso" )
            Exit
        ELSE

            AAdd(aTrbLid, {TRB->TR_COD, 0.00, TRB->TR_QTDE, SB2->B2_CM1, TRB->TR_QTDE * SB2->B2_CM1, cTesNfs, TRB->TR_DOC})

        ENDIF

    ENDIF

    TRB->( dbSkip() )

EndDo


        //If Empty(TRB->TR_NFSAIDA)
            
            SF4->(DbSetOrder(1))

            If SF4->(dbSeek( xFilial("SF4") + cTesNfs ))

                SA1->(dbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
                If SA1->(DbSeek( xFilial("SA1") + cCliNfs + cLjaNfs ))

                    SE4->(DbSetOrder(1))
                    If SE4->(DbSeek(xFilial("SE4")+cCond))

                       //SB2->(DbSetOrder(1))
                       //If SB2->(DbSeek(xFilial("SB2")+TRB->TR_COD+TRB->TR_LOCAL))

                            If Empty(aHeader)
                                cPed := GetSxeNum("SC5","C5_NUM")

	                            RollBackSx8()

                                // DADOS DO CABE�ALHO
                                AAdd(aHeader, {"C5_NUM"   	    , cPed               ,Nil}) // N� do Pedido
                                AAdd(aHeader, {"C5_TIPO"        , "N"               , NIL})
                                AAdd(aHeader, {"C5_CLIENTE"     , cCliNfs           , NIL})
                                AAdd(aHeader, {"C5_LOJACLI"     , cLjaNfs           , NIL})
                                AAdd(aHeader, {"C5_LOJAENT"     , cLjaNfs           , NIL})
                                AAdd(aHeader, {"C5_CONDPAG"     , cCond             , NIL})
                                AAdd(aHeader, {"C5_TRANSP"      , cTransp           , NIL})
                                AAdd(aHeader, {"C5_NATUREZ"     , cNaturez          , NIL})
                                AAdd(aHeader, {"C5_TPFRETE"     , "R"               , NIL})
                            EndIf
                            
                            //nConta++

FOR nT := 1 to Len(aTrbLid) 
aLine:={}                      
                          	cItem := PadL( AllTrim( STR(nT) ) , TamSX3( "C6_ITEM")[1],"0")

                            // DADOS DOS ITENS
                            AAdd(aLine, {"C6_ITEM"          , cItem         , NIL})
                            AAdd(aLine, {"C6_PRODUTO"       , aTrbLid[nT][1], NIL})
                            AAdd(aLine, {"C6_QTDLIB"        , aTrbLid[nT][2], NIL})
                            AAdd(aLine, {"C6_QTDVEN"        , aTrbLid[nT][3], NIL})
                            AAdd(aLine, {"C6_PRCVEN"        , aTrbLid[nT][4], NIL})
                            AAdd(aLine, {"C6_VALOR"         , aTrbLid[nT][5], NIL})
                            AAdd(aLine, {"C6_TES"           , aTrbLid[nT][6], NIL})

                            AAdd(aItems, aLine)
Next

                        //Else
                        //   MsgInfo( "Codigo n�o encontrado nos saldos (Fisico/Financeiro)! ", "[ ZCOMF008 ] - Aviso" )
                        //ENDIF
                    Else
                        MsgInfo( "Cond. de Pagamento n�o encontrado! Usar uma Cond. Pagamento que esteja cadastrada no sistema.", "[ ZCOMF008 ] - Aviso" )
                    EndIf
                Else
                    MsgInfo( "Cliente n�o encontrado, utilizar um Cliente que exista no cadastro!", "[ ZCOMF008 ] - Aviso" )
                EndIf
            Else
                MsgInfo( "TES n�o encontrada, utilizar uma TES que exista no cadastro!", "[ ZCOMF008 ] - Aviso" )
            EndIf
        //EndIf    
    //Endif


//    TRB->( dbSkip() )

//EndDo

// Verifica se gerou array com os pedidos de venda
If !Empty(aHeader) .And. !Empty(aItems)

    MsExecAuto({|x, y, z| MATA410(x, y, z)}, aHeader, aItems, nOpr)

    // VALIDA��O DE ERRO
    If (lMsErroAuto)
        MostraErro()
    Else
        //cPedido := SC5->C5_NUM
        //Processa({|| ZNfSaida(cPedido)}	,"Gerando Nota Fiscal..." )
        FOR nY := 1 TO LEN(aTrbLid)
            SD3->(dbSetOrder(2)) // D3_FILIAL+D3_DOC+D3_COD
            SD3->(DbSeek( xFilial("SD3") + aTrbLid[nY][7] + aTrbLid[nY][1]))
            RecLock( "SD3", .F. )
            SD3->D3_XPEDIDO := SC6->C6_NUM
            MsUnlock()
        NEXT
        MsgInfo( "Pedido criado com sucesso. ", "[ ZCOMF008 ] - Aviso" )
    EndIf
    
Else
    MsgInfo( "N�o foi possivel gerar os pedidos de venda, realizar novo processamento.", "[ ZCOMF008 ] - Aviso" )
EndIf

End Transaction

oBrowse:Refresh(.T.) 

Return()


/*
=====================================================================================
Programa.:              ZNfSaida
Autor....:              A. Oliveira
Data.....:              27/01/2020
Descricao / Objetivo:   Gera Notas Fiscais
Doc. Origem:            COM101 - Nota Fiscal RGLog
Solicitante:            Logistica
Uso......:              U_ZCOMF008
Obs......:
=====================================================================================
*/
/*
Static Function ZNfSaida(cPedido)

//Declara��o de Variaveis
Local aPvlNfs	:= {}
Local lRet      := .T.

//Montagem do Array para execu��o
SC9->(DbSetOrder(1))
If SC9->(DbSeek( xFilial("SC9") + AvKey(cPedido,"C9_PEDIDO") ) )

	While SC9->(!Eof()) .And. SC9->C9_PEDIDO == AvKey(cPedido,"C9_PEDIDO")
			
		//Posicionamento das tabelas

		//SC5
        SC5->(DbSetOrder(1))
		If SC5->(DbSeek( xFilial("SC5") + AvKey(cPedido,"C5_NUM") ) )
            
            //SC6
            SC6->(DbSetOrder(1))
            If SC6->(DbSeek( xFilial("SC6") + AvKey(cPedido,"C6_NUM") + AvKey(SC9->C9_ITEM,"C6_ITEM") ) )
        
                //SF4
                SF4->(DbSetOrder(1))
                If SF4->(DbSeek( xFilial("SF4") + AvKey(SC6->C6_TES,"F4_CODIGO") ) )

                    //SE4
                    SE4->(DbSetOrder(1))
			        If SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))

                        //SB2
                        SB2->(DbSetOrder(1))
			            If SB2->(DbSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL)))  //FILIAL+PRODUTO+LOCAL
                    
                            //SB1
                            SB1->(DbSetOrder(1))
                            If SB1->(DbSeek( xFilial("SB1") + AvKey(SC9->C9_PRODUTO,"B1_COD") ) )
                                
                                //Bloqueio de Estoque
                                If Empty(SC9->C9_BLEST) 
                                    
                                    //Bloqueio de Cr�dito
                                    If Empty(SC9->C9_BLCRED)
                                        
                                        //Montagem do array com os itens a serem faturados
                                        Aadd(aPvlNfs,{ 	    SC9->C9_PEDIDO      ,;
                                                            SC9->C9_ITEM        ,;
                                                            SC9->C9_SEQUEN      ,;
                                                            SC9->C9_QTDLIB      ,;
                                                            SC6->C6_PRCVEN      ,;
                                                            SC9->C9_PRODUTO     ,;
                                                            SF4->F4_ISS=="S"    ,;
                                                            SC9->(RecNo())      ,;
                                                            SC5->(RecNo())      ,;
                                                            SC6->(RecNo())      ,;
                                                            SE4->(RecNo())      ,;
                                                            SB1->(RecNo())      ,;
                                                            SB2->(RecNo())      ,;
                                                            SF4->(RecNo())      ,;
                                                            SB2->B2_LOCAL       ,;
                                                            SC9->C9_QTDLIB2     })
                                    Else
                                        lRet := .F.
                                        MsgInfo( "Produto com bloqueio de Cr�dito!" + CRLF + CRLF + "Produto: " + cProduto + " ser� ignorado para gera��o da Nota Fiscal", "[ ZCOMF008 ] - Aviso" )
                                    EndIf
                                Else
                                    lRet := .F.
                                    MsgInfo( "Produto com bloqueio de Estoque!" + CRLF + CRLF + "Produto: " + cProduto + " ser� ignorado para gera��o da Nota Fiscal", "[ ZCOMF008 ] - Aviso" )
                                EndIf
                            EndIf
                        EndIf
                    EndIf
                EndIf           
            Else
                lRet := .F.
                MsgInfo( "Item do Pedido de Vendas n�o encontrado! Item ser� desconsiderado para gera��o.", "[ ZCOMF008 ] - Aviso" )
            EndIf
        Else
            lRet := .F.
            MsgInfo( "Cabe�alho do Pedido de Vendas n�o encontrado! Processar novamente a Nota Fiscal", "[ ZCOMF008 ] - Aviso" )    			
        EndIf
		SC9->(DbSkip())
    EndDo
Else
    lRet := .F.
    MsgInfo( "Pedido de Venda n�o encontrado!", "[ ZCOMF008 ] - Aviso" )
EndIf

//Fechamento das Tabelas
SC9->(DbCloseArea())
SC5->(DbCloseArea())
SC6->(DbCloseArea())
SF4->(DbCloseArea())
SB1->(DbCloseArea())

//Conf. regra do Sr. Antonio Marcio a partir da libera��o ser� manual
//Gera��o da Nota Fiscal
/*If lRet .And. !Empty(aPvlNfs)

    //Parametro CMV_COM007 para definir qual a serie para faturamento automatico sa�das
    cSerie  := SuperGetMv("CMV_COM007",.F.,"1  ") 
    cNota 	:= MaPvlNfs(aPvlNfs,cSerie, .F., .F., .F., .F., .F., 0, 0, .T., .F.)

    If !Empty(cNota)
        DbSelectArea("SF2")
        SF2->(DbSetOrder(1))
        If SF2->(DbSeek(xFilial("SF2") + Doc + Serie + Fornecedor + Loja ))
            MsgInfo( "Gravando....", "[ ZCOMF008 ] - Aviso" )
        EndIf
    Else 
        lRet := .F.
        MsgInfo( "N�o foi poss�vel gerar a nota fiscal, processe novamente a Nota Fiscal", "[ ZCOMF008 ] - Aviso" )
    EndIf
Else
    lRet := .F.
    MsgInfo( "N�o foi poss�vel gerar a nota fiscal, Pedido de Vendas n�o criado!", "[ ZCOMF008 ] - Aviso" )
EndIf

Return(lRet)
*/