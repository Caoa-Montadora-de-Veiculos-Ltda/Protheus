#INCLUDE "PROTHEUS.CH" 
#include "MSGRAPHI.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "totvs.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#Include "MSMGADD.CH"
/*/{Protheus.doc} ZESTF015
@author A.Carlos
@since 	01/02/2024
@version 1.0
@return 
@obs	
@history    Gera browse p/ alterar lote
@type function
/*/
User Function ZESTF016()
Local cIndice1      := ""
Local lMarcar  	    := .F.
Local aSeek         := {}
Local aFieFilter    := {}
Local aCampos       := {}
Local cQuery		:= ""
Local cAliasSQL		:= GetNextAlias()
Private cUser       := __cUserId
Private oBrowse 	:= Nil
Private cCadastro 	:= "Troca Lote"
Private aParamBox   := {}
Private aRetPer     := ""
Private cAliasSC    := 'TRE'
Private oDlg
Private cArqTRE

    //IF U_ZGENUSER( RetCodUsr() ,"ZESTF015" ,.T.) = .F. 
   	//   RETURN Nil
	//ENDIF

    If Select( (cAliasSQL) ) > 0
    (cAliasSQL)->(DbCloseArea())
    EndIf

    cQuery := " SELECT * FROM " + RetSQLName('SB8') + " B8"
    cQuery += " INNER JOIN " + RetSQLName('D14') + " D14" 
    cQuery += " ON D14.D_E_L_E_T_ = ' ' " 
    cQuery += " AND D14_PRODUT = B8.B8_PRODUTO " 
    cQuery += " AND D14_LOCAL  = B8.B8_LOCAL " 
    cQuery += " AND D14_ENDER  = 'DCE01' "
    cQuery += " AND D14_IDUNIT = ' ' "
    cQuery += " WHERE B8.D_E_L_E_T_ = ' ' " 
    cQuery += " AND B8.B8_SALDO <> 0  "
    cQuery += " AND B8.B8_LOTECTL LIKE 'AUTO%' "
    cQuery += " ORDER BY B8.B8_PRODUTO "

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSQL, .T., .T. )

    DbSelectArea((cAliasSQL))
    (cAliasSQL)->(dbGoTop())

    If !(cAliasSQL)->(Eof())
       
        //Criar a tabela temporária
        AAdd(aCampos,{"TRE_FILIAL"  	,"C",010,0}) 
        AAdd(aCampos,{"TRE_PRODUTO"     ,"C",023,0})
        AAdd(aCampos,{"TRE_ARMAZEM"     ,"C",003,0})
        AAdd(aCampos,{"TRE_LOTE"        ,"C",030,0})

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
        IndRegua("TRE", cIndice1, "TRE_PRODUTO+TRE_ARMAZEM" ,,, "Indice Produto...")
        
        //Fecha todos os índices da área de trabalho corrente.
        dbClearIndex()

        //Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho.
        dbSetIndex(cIndice1+OrdBagExt())
        
        (cAliasSQL)->(dbGoTop())
        While (cAliasSQL)->(!Eof())
            If RecLock("TRE",.t.)

                TRE->TRE_FILIAL     := (cAliasSQL)->FILIAL
                TRE->TRE_PRODUTO	:= (cAliasSQL)->PRODUTO
                TRE->TRE_ARMAZEM    := (cAliasSQL)->ARMAZEM 
                TRE->TRE_LOTE       := (cAliasSQL)->LOTE

                TRE->(MsUnLock())
            Endif
            (cAliasSQL)->(DbSkip())
        EndDo

        (cAliasSQL)->(DbCloseArea())
        TRE->(DbGoTop())
        
        If TRE->(!Eof())
            //Irei criar a pesquisa que será apresentada na tela
            aAdd(aSeek,{"PRODUTO"  ,{{ ""    ,"C"    ,023    ,000    ,"PRODUTO"    ,"@!"   }} } )

            //Campos que irão compor a tela de filtro
            //aAdd(aSeek,{"SC"	        ,{{ ""    ,"C"    ,006    ,000    ,"SOLICITACAO"    ,"@!"   }} } )
            
            oBrowse:= FWMarkBrowse():New()
            oBrowse:SetDescription(cCadastro) //Titulo da Janela
            oBrowse:SetAlias("TRE") //Indica o alias da tabela que será utilizada no Browse
            oBrowse:SetFieldMark("") //Indica o campo que deverá ser atualizado com a marca no registro
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
            //oBrowse:AddLegend("TRE_ST=='N'","GREEN" 	,"Usuários Liberados")
            //oBrowse:AddLegend("TRE_ST=='S'","RED"   	,"Usuários Bloqueados")

            //Adiciona uma coluna no Browse em tempo de execução

            oBrowse:SetColumns(ZESTF015T("TRE_FILIAL"  ,"Filial"  ,01 ,"@!"   ,1,010,0))
            oBrowse:SetColumns(ZESTF015T("TRE_PRODUTO" ,"Produto" ,02 ,"@!"   ,1,020,0))
            oBrowse:SetColumns(ZESTF015T("TRE_ARMAZEM" ,"Armazem" ,03 ,"@!"   ,1,003,0))
            oBrowse:SetColumns(ZESTF015T("TRE_LOTE"    ,"Lote"    ,04 ,"@!"   ,1,040,0))
        
            oBrowse:AddButton("Troca Lote..."	, { || ZESTF015G()},,,, .F., 2 )
            oBrowse:bAllMark := { || ZESTF015I(oBrowse:Mark(),lMarcar := !lMarcar ), oBrowse:Refresh(.T.)  }
            oBrowse:Activate()
            oBrowse:oBrowse:Setfocus() //Seta o foco na grade
        Else
            Return
        EndIf

        //Limpar o arquivo temporário
        If File(cArqTRE)
            If !Empty(cArqTRE)
                Ferase(cArqTRE+GetDBExtension())
                Ferase(cArqTRE+OrdBagExt())
                cArqTRE := ""
                TRE->(DbCloseArea())
            Endif
        endif
    Else
        Alert("Não existem solicitações para o processamento com os parâmetros informados, revise os parâmetros!.")
    EndIf

Return(.T.)    


/*
=====================================================================================
Programa.:              ZESTF015I
Autor....:              A. Oliveira
Data.....:              20/10/2020
Descricao / Objetivo:   Função para marcar/desmarcar todos os registros do grid
Doc. Origem:                  
Solicitante:            
Uso......:              U_ZESTF015
Obs......:
=====================================================================================
*/
Static Function ZESTF015I(cMarca,lMarcar)
Local aAreaINV  := (cAliasSC)->( GetArea() )

dbSelectArea(cAliasSC)
(cAliasSC)->( dbGoTop() )
While !(cAliasSC)->( Eof() )
    RecLock( (cAliasSC), .F. )
    (cAliasSC)->TRE_OK := IIf( lMarcar, cMarca, '  ' )
    MsUnlock()
    (cAliasSC)->( dbSkip() )
EndDo
RestArea( aAreaINV )

Return(.T.)


/*
=====================================================================================
Programa.:              ZESTF015T
Autor....:              A. Oliveira
Data.....:              20/10/2020
Descricao / Objetivo:   Função para criar as colunas do grid
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZESTF015T(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
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


/*
=====================================================================================
Programa.:              ZESTF015G
Autor....:              A. Oliveira
Data.....:              20/10/2020
Descricao / Objetivo:   
Doc. Origem:            
Solicitante:            Compras
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZESTF015G()
Local nJanAltu      := 430      //180
Local nJanLarg      := 650
Local lOk           := .F.
Local cItem         := ""
Local cProduto      := ""
Local cArmazem      := ""
Local aSizeAut      := MsAdvSize(,.F.,400)
Local _aItemB8      := {}

aObjects := {}
AAdd( aObjects, { 0,    41, .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 0,    75, .T., .F. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,;
                       {{10,40,95,140,200,234,268,200,225,260,285,260},;
                        {10,40,111,140,223,268,63},;
                        {5,70,160,205,295},;
                        {6,34,200,215},;
                        {6,34,80,113,160,185},;
                        {6,34,245,268,260},;
                        {10,50,150,190},;
                        {273,130,190},;
                        {8,45,80,103,139,173,200,235,270},;
                        {133,190,144,190,289,293},;
                        {142,293,140},;
                        {9,47,188,148,9,146} } )

TRE->( DbSetOrder(1) )
TRE->( DbGoTop() )
While !TRE->(Eof())

    //cFilial  := TRE->TRE_FILIAL
    cProduto := TRE->TRE_PRODUTO
    cArmazem := TRE->TRE_ARMAZEM
    cLote    := TRE->TRE_LOTE

    aadd(_aFilial,{cItem,Nil})               
    aadd(_aProduto,{cProduto,Nil})               
    aadd(_aArmazem,{cArmazem,Nil}) //14294038888          govbr 23120821
    aadd(_aLote,{cLote,Nil})

    DEFINE MSDIALOG oDlgSCt TITLE cCadastro FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
    
    //@ 016,007 SAY "Filial" OF oDlgSCt PIXEL SIZE 031,006
    //@ 013,060 SAY cFilial  OF oDlgSCt PIXEL SIZE 031,006

    @ 036,007 SAY "Produto" OF oDlgSCt PIXEL SIZE 042,006
    @ 033,060 SAY cProduto  OF oDlgSCt PIXEL SIZE 031,006

    @ 056,007 SAY "Armazem" OF oDlgSCt PIXEL SIZE 031,006
    @ 053,060 SAY cArmazem  OF oDlgSCt PIXEL SIZE 100,006

    @ 076,007 SAY "Lote"  OF oDlgSCt PIXEL SIZE 042,006
    @ 073,060 MSGET cLote OF oDlgSCt PIXEL SIZE 100,006

    @ 170,170  BUTTON oBtnSair PROMPT "Confirmar" SIZE 60, 014 OF oDlgSCt ACTION (lOk := .T. ,oDlgSCt:End()) PIXEL 
    @ 170,240  BUTTON oBtnSair PROMPT "Sair"     SIZE 60, 014 OF oDlgSCt ACTION (lOk := .F. ,oDlgSCt:End()) PIXEL

    ACTIVATE MSDIALOG oDlgSCt CENTERED
    
    IF !Empty(cLote)
        Grv_B8(cLote)
    EndIf

    IF !Empty(cLote)
        _aItemB8 := {}
        //cFilial  := TRE->TRE_FILIAL
        cProduto := TRE->TRE_PRODUTO

        aadd(_aItemB8,{cFilial,Nil})               
        aadd(_aItemB8,{cProduto,Nil})               
        aadd(_aItemB8,{cArmazem,Nil}) 
        aadd(_aItemB8,{cLote,Nil})

        Grv_B8(_aItemB8)
    EndIf
    
    TRE->( dbSkip() )

EndDo

MsgInfo("Processamento realizado com sucesso!!")

Popular_Temp()
TRE->( dbGotop() )
oBrowse:Refresh(.T.) 

Return()



/*
=====================================================================================
Programa.:              Grv_B8
Autor....:              A. Oliveira
Data.....:              20/10/2020
Descricao / Objetivo:   Função para salvar os dados 
Doc. Origem:                  
Solicitante:            
Uso......:              U_ZESTF015
Obs......:
=====================================================================================
*/
Static Function Grv_B8(aItemB8)
Local _nReg    := 0

Begin Transaction
    
    DbSelectArea("SB8")
    SB8->(DbSetOrder(1))
    
    If SB8->(dbSeek(xFilial("SB8")+aItemB8[1]+aItemB8[2]))

        _nReg := SB8->(Recno())
        RecLock("SB8",.F.)
        SB8->B8_lotectl = aItemB8[3] 
        SB8->(MsUnlock())

    EndIf

End Transaction

Return()


/*
=====================================================================================
Programa.:              Popular_Temporaria
Autor....:              A. Oliveira
Data.....:              13/01/2021
Descricao / Objetivo:   Função para Popular tabela Temporaria
Doc. Origem:                  
Solicitante:            
Uso......:              U_ZESTF016
Obs......:
=====================================================================================
*/
Static Function Popular_Temp()
Local cQuery	:= ""
Local cAliasSQL := GetNextAlias()

    cQuery := " SELECT B8_FILIAL , B8_PRODUTO PRODUTO, B8_LOCAL ARMAZEM, B8_LOTECTL LOTE" + CRLF
    cQuery += " FROM " + RetSQLName('SB8') + " B8"                          + CRLF
    cQuery += "     INNER JOIN " + RetSQLName('D14') + " D14    "           + CRLF 
    cQuery += " ON D14.D_E_L_E_T_ = ' '                         "           + CRLF
    cQuery += "    AND D14_PRODUT = B8_PRODUTO                  "           + CRLF 
    cQuery += "    AND D14_LOCAL  = B8_LOCAL                    "           + CRLF
    cQuery += "    AND D14_ENDER  = 'DCE01'                     "           + CRLF
    cQuery += "    AND D14_IDUNIT = ' '                         "           + CRLF
    cQuery += " WHERE B8.B8_FILIAL = '" + FWxFilial('SB8') + "' "           + CRLF
    cQuery += "    AND B8.B8_SALDO <> 0                         "           + CRLF
    cQuery += "    AND B8.B8_LOTECTL LIKE 'AUTO%'               "           + CRLF
    cQuery += " AND B8.D_E_L_E_T_  = ' ' "                                  + CRLF
    cQuery += " ORDER BY 1, 2 "                                             + CRLF
    cQuery := ChangeQuery(cQuery)

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSQL, .T., .T. )

    DbSelectArea((cAliasSQL))
    (cAliasSQL)->(dbGoTop())

    If !Empty(cArqTRE)
       Ferase(cArqTRE+GetDBExtension())
       Ferase(cArqTRE+OrdBagExt())
       cArqTRE := ""
       TRE->(DbCloseArea())
    Endif

    cArqTRE  := CriaTrab(aCampos,.T.)
    cIndice1 := Alltrim(CriaTrab(,.F.))
    cIndice1 := Left(cIndice1,5) + Right(cIndice1,2) + "A"
        
    If File(cIndice1+OrdBagExt())
       FErase(cIndice1+OrdBagExt())
    EndIf
                    
    dbUseArea(.T.,,cArqTRE,"TRE",Nil,.F.)
    IndRegua("TRE", cIndice1, "TRE_PRODUTO+TRE_ARMAZEM" ,,, "Indice Produto...")
        
    //Fecha todos os índices da área de trabalho corrente.
    dbClearIndex()

    //Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho.
    dbSetIndex(cIndice1+OrdBagExt())

    (cAliasSQL)->(dbGoTop())
    While (cAliasSQL)->(!Eof())

            //cFilial  := TRE->TRE_FILIAL
            cProduto := TRE->TRE_PRODUTO
            cArmazem := TRE->TRE_ARMAZEM
            cLote    := TRE->TRE_LOTE

            If RecLock("TRE",.t.)
                TRE->TRE_FILIAL     := (cAliasSQL)->FILIAL
                TRE->TRE_PRODUTO 	:= (cAliasSQL)->PRODUTO
                TRE->TRE_ARMAZEM    := (cAliasSQL)->ARMAZEM 
                TRE->TRE_LOTE       := (cAliasSQL)->LOTE
                TRE->(MsUnLock())
            Endif
        (cAliasSQL)->(DbSkip())
    EndDo
Return(.T.) 
