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
/*/{Protheus.doc} ZCOMF033
@author A.Carlos
@since 	30/10/2020
@version 1.0
@return 
@obs	
@history    Gera browse p/ reverter recusa da SC1
@type function
/*/
User Function ZCOMF033()
Local cIndice1      := ""
Local lMarcar  	    := .F.
Local aSeek         := {}
Local aFieFilter    := {}
Local cQuery		:= ""
Local cAliasSQL		:= GetNextAlias()
Local cFun          := ""
Local cDrive        := "C:\"
Local cDiretorio    := "Users\antonio.poliveira\Documents\Desenvolvimento\Tabelas\"
Private cUser       := __cUserId
Private oBrowse 	:= Nil
Private cCadastro 	:= "Estorno de Recusa de Solicitação de Compras"
Private aParamBox   := {}
Private aRetPer     := ""
Private cAliasSC    := 'TRE'
Private oDlg
Private cPar1       := ""
Private cPar2       := ""
Private cPar4       := ""
Private cArqTRE
Private aCampos       := {}

    //Usuario = solicitante, cadastrado na tabela - DbSeek( xFilial("SZX") + cUser + UPPER(Alltrim(cRotina)) ), para não acessar
    IF U_ZGENUSER( RetCodUsr() ,"ZCOMF033" ,.T.) = .F. 
   	   RETURN Nil
	ENDIF


    If Select( (cAliasSQL) ) > 0
    (cAliasSQL)->(DbCloseArea())
    EndIf

    IF FWIsInCallStack("MATA110")

        cQuery := " SELECT C1_NUM SC, C1_ITEM ITEM, C1_PRODUTO PROD, C1_DESCRI DESCR,C1_EMISSAO EMIS,C1_SOLICIT SOLIC" + CRLF
        cQuery += " FROM " + RetSQLName('SC1') + " C1"                          + CRLF
        cQuery += " WHERE C1.C1_FILIAL = '" + FWxFilial('SC1') + "' "           + CRLF
        cQuery += " AND C1.C1_NUM = '" + SC1->C1_NUM  + "'"    + CRLF
        cQuery += " AND C1.C1_APROV = 'R'   "  

    ELSE

        aAdd(aParamBox,{ 1, "Solicitação de " , Space(6), "!@", "", "SC1","", 25,.F.})
        aAdd(aParamBox,{ 1, "Solicitação até ", "ZZZZZZ", "!@", "", "SC1","", 25,.F.})
        aAdd(aParamBox,{ 1, "Tipo Documdento ", Space(6), "!@", "", ""   ,"", 25,.F.})
        aAdd(aParamBox,{ 1, "Produto "        , Space(23),"!@", "", "SB1","", 50,.F.})
        aAdd(aParamBox,{ 1, "Solicitante "    , Space(6), "!@", "", ""   ,"", 25,.F.})   //Codigo do usuario

        If !ParamBox(aParamBox, "Parâmetros", @aRetPer )
            Return Nil
        EndIf

        cQuery := " SELECT C1_NUM SC, C1_ITEM ITEM, C1_PRODUTO PROD, C1_DESCRI DESCR,C1_EMISSAO EMIS,C1_SOLICIT SOLIC" + CRLF
        cQuery += " FROM " + RetSQLName('SC1') + " C1"                          + CRLF
        cQuery += " WHERE C1.C1_FILIAL = '" + FWxFilial('SC1') + "' "           + CRLF
        cQuery += " AND C1.C1_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "   + CRLF
        cQuery += " AND C1.C1_APROV = 'R'   "                                  + CRLF
            
        IF MV_PAR04 <> ' ' 
            cQuery += " AND C1.C1_PRODUTO = '" + MV_PAR04 + "' "                + CRLF
        Endif
        cPar1 := MV_PAR01
        cPar2 := MV_PAR02
        cPar4 := MV_PAR04

    ENDIF

    cQuery += " AND C1.D_E_L_E_T_  = ' ' "                                  + CRLF
    cQuery += " ORDER BY 1, 2 "                                             + CRLF
    cQuery := ChangeQuery(cQuery)

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSQL, .T., .T. )

    DbSelectArea((cAliasSQL))
    (cAliasSQL)->(dbGoTop())

    If !(cAliasSQL)->(Eof())
       
        //Criar a tabela temporária
        AAdd(aCampos,{"TRE_OK"  	    ,"C",002,0}) //Este campo será usado para marcar/desmarcar
        AAdd(aCampos,{"TRE_SC"          ,"C",006,0})
        AAdd(aCampos,{"TRE_ITEM"        ,"C",004,0})
        AAdd(aCampos,{"TRE_PROD"        ,"C",023,0})
        AAdd(aCampos,{"TRE_DESCR"       ,"C",040,0})
        AAdd(aCampos,{"TRE_EMIS"        ,"D",008,0})
        AAdd(aCampos,{"TRE_SOLIC"       ,"C",025,0})

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
        IndRegua("TRE", cIndice1, "TRE_SC+TRE_ITEM" ,,, "Indice Produto...")
        
        //Fecha todos os índices da área de trabalho corrente.
        dbClearIndex()

        //Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho.
        dbSetIndex(cIndice1+OrdBagExt())
        
        (cAliasSQL)->(dbGoTop())
        While (cAliasSQL)->(!Eof())
            If RecLock("TRE",.t.)
                TRE->TRE_OK          := "  "
                TRE->TRE_SC          := (cAliasSQL)->SC
                TRE->TRE_ITEM 	     := (cAliasSQL)->ITEM
                TRE->TRE_PROD        := (cAliasSQL)->PROD 
                TRE->TRE_DESCR       := (cAliasSQL)->DESCR
                TRE->TRE_EMIS        := STOD((cAliasSQL)->EMIS)
                TRE->TRE_SOLIC       := (cAliasSQL)->SOLIC
                TRE->(MsUnLock())
            Endif
        (cAliasSQL)->(DbSkip())
        EndDo

        (cAliasSQL)->(DbCloseArea())
        TRE->(DbGoTop())
        
        If TRE->(!Eof())
            //Irei criar a pesquisa que será apresentada na tela
            aAdd(aSeek,{"SC"	        ,{{ ""    ,"C"    ,006    ,000    ,"SOLICITACAO"    ,"@!"   }} } )

            //Campos que irão compor a tela de filtro
            //aAdd(aSeek,{"SC"	        ,{{ ""    ,"C"    ,006    ,000    ,"SOLICITACAO"    ,"@!"   }} } )
            
            oBrowse:= FWMarkBrowse():New()
            oBrowse:SetDescription(cCadastro) //Titulo da Janela
            oBrowse:SetAlias("TRE") //Indica o alias da tabela que será utilizada no Browse
            oBrowse:SetFieldMark("TRE_OK") //Indica o campo que deverá ser atualizado com a marca no registro
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
            oBrowse:SetColumns(ZCOMF033T("TRE_SC"       ,"Solicitação" ,02 ,"@!"   ,0,006,0))
            oBrowse:SetColumns(ZCOMF033T("TRE_ITEM"	    ,"Item"		 ,03 ,"@!"   ,1,004,0))
            oBrowse:SetColumns(ZCOMF033T("TRE_PROD"     ,"Produto"     ,04 ,"@!"   ,1,006,0))
            oBrowse:SetColumns(ZCOMF033T("TRE_DESCR"    ,"Descrição"   ,05 ,"@!"   ,1,040,0))
            oBrowse:SetColumns(ZCOMF033T("TRE_EMIS"     ,"Emissão"     ,06 ,"D"    ,1,008,0))
            oBrowse:SetColumns(ZCOMF033T("TRE_SOLIC"    ,"Solicitante" ,07 ,"@!"   ,1,025,0))
        
            oBrowse:AddButton("Estorna Item..."	, { || ZCOMF033G()},,,, .F., 2 )
            oBrowse:bAllMark := { || ZCOMF033I(oBrowse:Mark(),lMarcar := !lMarcar ), oBrowse:Refresh(.T.)  }
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
Programa.:              ZCOMF033I
Autor....:              A. Oliveira
Data.....:              20/10/2020
Descricao / Objetivo:   Função para marcar/desmarcar todos os registros do grid
Doc. Origem:                  
Solicitante:            Compras
Uso......:              U_ZCOMF033
Obs......:
=====================================================================================
*/
Static Function ZCOMF033I(cMarca,lMarcar)
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
Programa.:              ZCOMF033T
Autor....:              A. Oliveira
Data.....:              20/10/2020
Descricao / Objetivo:   Função para criar as colunas do grid
Doc. Origem:            
Solicitante:            Compras
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZCOMF033T(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
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
Programa.:              ZCOMF033G
Autor....:              A. Oliveira
Data.....:              20/10/2020
Descricao / Objetivo:   Estornar recusa de SC
Doc. Origem:            
Solicitante:            Compras
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZCOMF033G()
Local nJanAltu      := 430      //180
Local nJanLarg      := 650
Local lOk           := .F.
Local cNum          := ""
Local cItem         := ""
Local cProduto      := ""
Local cDesc         := ""
Local dEmis         := STOD("")
Local cSolic        := ""
Local cObs          := ""
Local cMotivo       := ""
Local aSizeAut      := MsAdvSize(,.F.,400)
Local _aItemSC      := {}

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

    If !Empty(TRE->TRE_OK) //Se diferente de vazio, é porque foi marcado
        
        IF TRE->TRE_SC <> cNum 
        
            cNum := TRE->TRE_SC
            
            RecLock( (cAliasSC), .F. )
            (cAliasSC)->TRE_OK := '  '
            MsUnlock()
            
            cItem    := TRE->TRE_ITEM
            cProduto := TRE->TRE_PROD
            cDesc    := TRE->TRE_DESCR
            dEmis    := TRE->TRE_EMIS
            cSolic   := TRE->TRE_SOLIC
            cMotivo  := ""
            cObs     := ""    
            aadd(_aItemSC,{cItem,Nil})               
            aadd(_aItemSC,{cProduto,Nil})               
            aadd(_aItemSC,{1,Nil}) 
            aadd(_aItemSC,{" ",Nil})

            DEFINE MSDIALOG oDlgSCt TITLE cCadastro FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
            
            @ 016,007 SAY "N.Solitação" OF oDlgSCt PIXEL SIZE 031,006
            @ 013,060 MSGET cNum PICTURE PesqPict('SC1','C1_NUM') When .F. OF oDlgSCt PIXEL SIZE 031,006
        
            @ 036,007 SAY "Item" OF oDlgSCt PIXEL SIZE 042,006
            @ 033,060 MSGET cItem PICTURE PesqPict('SC1','C1_ITEM') When .F. OF oDlgSCt PIXEL SIZE 031,006
        
            @ 056,007 SAY "Produto" OF oDlgSCt PIXEL SIZE 031,006
            @ 053,060 MSGET cProduto PICTURE PesqPict('SC1','C1_PRODUTO') When .F. OF oDlgSCt PIXEL SIZE 100,006
        
            @ 076,007 SAY "Descrição" OF oDlgSCt PIXEL SIZE 042,006
            @ 073,060 MSGET cDesc PICTURE PesqPict('SC1','C1_DESCRI') When .F. OF oDlgSCt PIXEL SIZE 100,006
        
            @ 096,007 SAY "Emissão" OF oDlgSCt PIXEL SIZE 050,006
            @ 093,060 MSGET dEmis PICTURE PesqPict('SC1','C1_EMISSAO') When .F. OF oDlgSCt PIXEL SIZE 040,006
        
            @ 116,007 SAY "Solicitante" OF oDlgSCt PIXEL SIZE 036,006
            @ 113,060 MSGET cSolic PICTURE PesqPict('SC1','C1_SOLICIT') When .F. OF oDlgSCt PIXEL SIZE 050,006
        
            @ 136,007 SAY "Observação" OF oDlgSCt PIXEL SIZE 050,006
            @ 133,0060 GET OObs VAR cObs MEMO when .T.  SIZE 240,026 PIXEL OF ODLG 

            @ 170,170  BUTTON oBtnSair PROMPT "Confirmar" SIZE 60, 014 OF oDlgSCt ACTION (lOk := .T. ,oDlgSCt:End()) PIXEL 
            @ 170,240   BUTTON oBtnSair PROMPT "Sair"      SIZE 60, 014 OF oDlgSCt ACTION (lOk := .F. ,oDlgSCt:End()) PIXEL

            ACTIVATE MSDIALOG oDlgSCt CENTERED
            
            IF lOk .AND. !Empty(cObs)
               Grv_SC(cObs,cMotivo,cNum,cItem,_aItemSC)
            EndIf

        Else

            IF lOk .AND. !Empty(cObs)
               _aItemSC := {}
               cItem    := TRE->TRE_ITEM
               cProduto := TRE->TRE_PROD

               aadd(_aItemSC,{cItem,Nil})               
               aadd(_aItemSC,{cProduto,Nil})               
               aadd(_aItemSC,{1,Nil}) 
               aadd(_aItemSC,{" ",Nil})

               Grv_SC(cObs,cMotivo,cNum,cItem,_aItemSC)
            EndIf
        
        ENDIF

    ENDIF

    TRE->( dbSkip() )

EndDo
If lOk
   MsgInfo("Processamento realizado com sucesso!!")
Endif
Popular_Temp()
TRE->( dbGotop() )
oBrowse:Refresh(.T.) 

Return()



/*
=====================================================================================
Programa.:              Grv_SC
Autor....:              A. Oliveira
Data.....:              20/10/2020
Descricao / Objetivo:   Função para salvar os dados na SC
Doc. Origem:                  
Solicitante:            Compras
Uso......:              U_ZCOMF033
Obs......:
=====================================================================================
*/
Static Function Grv_SC(cObs,cMotivo,cNum,cItem,_aItemSC)
Local _nReg    := 0
Local _cAssu   := "Estorno Recusa Item SC"

Begin Transaction
    
    DbSelectArea("SC1")
    SC1->(DbSetOrder(1))
    
    If SC1->(dbSeek(xFilial("SC1")+cNum+cItem))

        _nReg := SC1->(Recno())
        //_cMail:= SC1->C1_XREQMAI
        RecLock("SC1",.F.)
        SC1->C1_XOBSMRE = cObs 
        SC1->C1_XMOTR   := ' '
        SC1->C1_APROV   := 'L'  //B=BLOQUEADA E L=LIBERADA 
        SC1->(MsUnlock())

        //CriaSCR(_aItemSC,cNum)
        
    EndIf

//Gravar dados para auditoria
    RecLock( "SZH",.T.) 
        SZH->ZH_FILIAL  := XFilial("SZH")
        SZH->ZH_ORIGEM  := "SC"
        SZH->ZH_DOCTO   := cNum
        SZH->ZH_ITEM    := _aItemSC[1][1]  
        SZH->ZH_REVISAO := "001"
        SZH->ZH_OPER    := "A"
        SZH->ZH_CAMPO   :=  "C1_XMOTR" 
        SZH->ZH_INFOANT :=  ""
        SZH->ZH_INFATUA :=  cObs
        SZH->ZH_MOTIVO  := _cAssu
        SZH->ZH_NUMREG  := _nReg
        SZH->ZH_CODUSU  := RETCODUSR() 
        SZH->ZH_DATAI   := Date()
        SZH->ZH_HORAI   := Time()
    SZH->(MsUnlocK())

End Transaction

Return()



//************************************
Static Function CriaSCR(_aItemSC,cNum)
Local AreaAtual := GetArea()
Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local nOpc   := 4
Private lMsHelpAuto := .T.
PRIVATE lMsErroAuto := .F.
                                       
aadd(aCabec,{"C1_NUM"    ,cNum})          
aadd(aCabec,{"C1_SOLICIT",UsrFullName(RetCodUsr())})          
aadd(aCabec,{"C1_EMISSAO",dDataBase})          

aLinha := {}               
aadd(aLinha,{"C1_ITEM"   ,_aItemSC[1,1],Nil})               
aadd(aLinha,{"C1_PRODUTO",_aItemSC[2,1],Nil})               
aadd(aLinha,{"C1_QUANT"  ,_aItemSC[3,1],Nil})               
aadd(aLinha,{"C1_XMOTR"  ,_aItemSC[4,1],Nil})
aadd(aItens,aLinha)          

MSExecAuto({|v,x,y,z| mata110(v,x,y,z)},aCabec,aItens,nOpc,.F.) //Alteração       

If lMsErroAuto                
    MostraErro()        
Else
    RecLock("SC1",.F.)
    SC1->C1_QUANT := _aItemSC[3,1]
    SC1->C1_XMOTR := _aItemSC[4,1]
    SC1->(MsUnLock())               
EndIf     

RestArea(AreaAtual)

Return(.T.)    


/*
=====================================================================================
Programa.:              Popular_Temporaria
Autor....:              A. Oliveira
Data.....:              13/01/2021
Descricao / Objetivo:   Função para Popular tabela Temporaria
Doc. Origem:                  
Solicitante:            Compras
Uso......:              U_ZCOMF032
Obs......:
=====================================================================================
*/
Static Function Popular_Temp()
Local cQuery	:= ""
Local cAliasSQL := GetNextAlias()
IF FWIsInCallStack("MATA110")
    cQuery := " SELECT C1_NUM SC, C1_ITEM ITEM, C1_PRODUTO PROD, C1_DESCRI DESCR,C1_EMISSAO EMIS,C1_SOLICIT SOLIC" + CRLF
    cQuery += " FROM " + RetSQLName('SC1') + " C1"                          + CRLF
    cQuery += " WHERE C1.C1_FILIAL = '" + FWxFilial('SC1') + "' "           + CRLF
    cQuery += " AND C1.C1_NUM = '" + SC1->C1_NUM  + "'"    + CRLF
    cQuery += " AND C1.C1_APROV = 'R'   "  
ELSE
    cQuery := " SELECT C1_NUM SC, C1_ITEM ITEM, C1_PRODUTO PROD, C1_DESCRI DESCR,C1_EMISSAO EMIS,C1_SOLICIT SOLIC" + CRLF
    cQuery += " FROM " + RetSQLName('SC1') + " C1"                          + CRLF
    cQuery += " WHERE C1.C1_FILIAL = '" + FWxFilial('SC1') + "' "           + CRLF
    cQuery += " AND C1.C1_NUM BETWEEN '"+ cPar1 +"' AND '"+cPar2+"' "   + CRLF
    cQuery += " AND C1.C1_APROV = 'R'   "                                  + CRLF
         
    IF cPar4 <> ' ' 
        cQuery += " AND C1.C1_PRODUTO = '" + cPar4 + "' "                + CRLF
    Endif
ENDIF
    cQuery += " AND C1.D_E_L_E_T_  = ' ' "                                  + CRLF
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
    IndRegua("TRE", cIndice1, "TRE_SC+TRE_ITEM" ,,, "Indice Produto...")
        
    //Fecha todos os índices da área de trabalho corrente.
    dbClearIndex()

    //Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho.
    dbSetIndex(cIndice1+OrdBagExt())

    (cAliasSQL)->(dbGoTop())
    While (cAliasSQL)->(!Eof())
            If RecLock("TRE",.t.)
                TRE->TRE_OK          := "  "
                TRE->TRE_SC          := (cAliasSQL)->SC
                TRE->TRE_ITEM 	     := (cAliasSQL)->ITEM
                TRE->TRE_PROD        := (cAliasSQL)->PROD 
                TRE->TRE_DESCR       := (cAliasSQL)->DESCR
                TRE->TRE_EMIS        := STOD((cAliasSQL)->EMIS)
                TRE->TRE_SOLIC       := (cAliasSQL)->SOLIC
                TRE->(MsUnLock())
            Endif
        (cAliasSQL)->(DbSkip())
    EndDo
Return(.T.) 
