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

/*/{Protheus.doc} ZCOMF032
@author A.Carlos
@since 	20/10/2020
@version 1.0
@return 
@obs	 
@history    Gera browse p/ recusa da SC1
@type function
/*/
User Function ZCOMF032()
Private aCampos     := {}
Private cArqTrb
Private cIndice1    := ""
Private lMarcar  	:= .F.
Private aSeek       := {}
Private aFieFilter  := {}
Private cQuery		:= ""
Private cAliasSQL	:= GetNextAlias()
Private oBrowse 	:= Nil
Private cCadastro 	:= "Recusa de Solicitação de Compras"
Private aParamBox   := {}
Private aRetPer     := ""
Private cAliasSC    := 'TRB'
Private oDlg
Private nPasso      := 0
Private lRet        := .T.
Private _cNomeUs    := cUserName
Private _cCodUs     := __cUserId
Private _Vez        := 1
Private _DesMot     := ""
Private _cMail      := ""
Private _cAssu      := "Recusa de Solicitação de Compras " 
Private _cRot       := "ZCOMF032" 

    //Usuario = solicitante, cadastrado na tabela - DbSeek( xFilial("SZX") + cUser + UPPER(Alltrim(cRotina)) ), para não acessar
    IF U_ZGENUSER( RetCodUsr() ,"ZCOMF032" ,.T.) = .F. 
   	   RETURN Nil
	ENDIF

    If Select( (cAliasSQL) ) > 0
       (cAliasSQL)->(DbCloseArea())
    EndIf

    IF FWIsInCallStack("MATA110")

        cQuery := " SELECT C1_NUM SC, C1_ITEM ITEM, C1_PRODUTO PRODUTO, C1_DESCRI DESCR,C1_EMISSAO EMISSAO,C1_SOLICIT SOLICIT" + CRLF
        cQuery += " FROM " + RetSQLName('SC1') + " C1"                          + CRLF
        cQuery += " WHERE C1.C1_FILIAL = '" + FWxFilial('SC1') + "' "           + CRLF
        cQuery += " AND C1.C1_NUM = '" + SC1->C1_NUM  + "'"                     + CRLF
        cQuery += " AND C1.C1_APROV <> 'R' "                                    + CRLF

    ELSE

        aAdd(aParamBox,{ 1, "Solicitação de " , Space(6), "!@", "", "SC1","", 25,.F.})
        aAdd(aParamBox,{ 1, "Solicitação até ", "ZZZZZZ", "!@", "", "SC1","", 25,.F.})
        aAdd(aParamBox,{ 1, "Tipo Documento  ", Space(6), "!@", "", ""   ,"", 25,.F.})
        aAdd(aParamBox,{ 1, "Produto "        , Space(23),"!@", "", "SB1","", 50,.F.})
        aAdd(aParamBox,{ 1, "Solicitante "    , Space(6), "!@", "", "SAI","", 25,.F.})   //Codigo do usuario

        If !ParamBox(aParamBox, "Parâmetros", @aRetPer )
            Return Nil
        EndIf

        cQuery := " SELECT C1_NUM SC, C1_ITEM ITEM, C1_PRODUTO PRODUTO, C1_DESCRI DESCR,C1_EMISSAO EMISSAO,C1_SOLICIT SOLICIT" + CRLF
        cQuery += " FROM " + RetSQLName('SC1') + " C1"                          + CRLF
        cQuery += " WHERE C1.C1_FILIAL = '" + FWxFilial('SC1') + "' "           + CRLF
        cQuery += " AND C1.C1_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "   + CRLF
        cQuery += " AND C1.C1_APROV <> 'R' "                                  + CRLF
        IF MV_PAR04 <> ' ' 
            cQuery += " AND C1.C1_PRODUTO = '" + MV_PAR04 + "' "                + CRLF
        Endif
        IF MV_PAR05 <> ' '
            cQuery += " AND C1.C1_USER = '" + MV_PAR05 + "' "                   + CRLF
        Endif

    ENDIF

    cQuery += " AND C1.D_E_L_E_T_  = ' ' "                                  + CRLF
    cQuery += " ORDER BY 1, 2 "                                             + CRLF

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSQL, .T., .T. )

    DbSelectArea((cAliasSQL))
    (cAliasSQL)->(dbGoTop())
    If !(cAliasSQL)->(Eof())
       
        //Criar a tabela temporária
        AAdd(aCampos,{"TR_OK"  	       ,"C",002,0}) //Este campo será usado para marcar/desmarcar
        AAdd(aCampos,{"TR_SC"          ,"C",006,0})
        AAdd(aCampos,{"TR_ITEM"        ,"C",004,0})
        AAdd(aCampos,{"TR_PRODUTO"     ,"C",023,0})
        AAdd(aCampos,{"TR_DESCR"       ,"C",040,0})
        AAdd(aCampos,{"TR_EMISSAO"     ,"D",008,0})
        AAdd(aCampos,{"TR_SOLICIT"     ,"C",025,0})

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
        
        (cAliasSQL)->(dbGoTop())
        While (cAliasSQL)->(!Eof())
            If RecLock("TRB",.t.)
                TRB->TR_OK          := "  "
                TRB->TR_SC          := (cAliasSQL)->SC
                TRB->TR_ITEM 	    := (cAliasSQL)->ITEM
                TRB->TR_PRODUTO     := (cAliasSQL)->PRODUTO 
                TRB->TR_DESCR       := (cAliasSQL)->DESCR
                TRB->TR_EMISSAO     := STOD((cAliasSQL)->EMISSAO)
                TRB->TR_SOLICIT     := (cAliasSQL)->SOLICIT
                TRB->(MsUnLock())
            Endif
            (cAliasSQL)->(DbSkip())
        EndDo

        (cAliasSQL)->(DbCloseArea())
        TRB->(DbGoTop())
        
        If TRB->(!Eof())
            //Irei criar a pesquisa que será apresentada na tela
            aAdd(aSeek,{"SC"	        ,{{ ""    ,"C"    ,006    ,000    ,"SOLICITACAO"    ,"@!"   }} } )
            
            oBrowse:= FWMarkBrowse():New()
            oBrowse:SetDescription(cCadastro) //Titulo da Janela
            oBrowse:SetAlias("TRB") //Indica o alias da tabela que será utilizada no Browse
            oBrowse:SetFieldMark("TR_OK") //Indica o campo que deverá ser atualizado com a marca no registro
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
            //oBrowse:AddLegend("TR_ST=='N'","GREEN" 	,"Usuários Liberados")
            //oBrowse:AddLegend("TR_ST=='S'","RED"   	,"Usuários Bloqueados")

            //Adiciona uma coluna no Browse em tempo de execução
            oBrowse:SetColumns(ZCOMF032T("TR_SC"          ,"Solicitação" ,02 ,"@!"   ,0,006,0))
            oBrowse:SetColumns(ZCOMF032T("TR_ITEM"	      ,"Item"		 ,03 ,"@!"   ,1,004,0))
            oBrowse:SetColumns(ZCOMF032T("TR_PRODUTO"     ,"Produto"     ,04 ,"@!"   ,1,006,0))
            oBrowse:SetColumns(ZCOMF032T("TR_DESCR"       ,"Descrição"   ,05 ,"@!"   ,1,040,0))
            oBrowse:SetColumns(ZCOMF032T("TR_EMISSAO"     ,"Emissão"     ,06 ,"D"    ,1,008,0))
            oBrowse:SetColumns(ZCOMF032T("TR_SOLICIT"     ,"Solicitante" ,07 ,"@!"   ,1,025,0))
          
            oBrowse:AddButton("Recusar Item..."	        , { || ZCOMF032G()},,,, .F., 2 )
            oBrowse:AddButton("Alterar Comprador..."	, { || ZCOMF032C()},,,, .F., 2 )
                     
            oBrowse:bAllMark := { || ZCOMF032I(oBrowse:Mark(),lMarcar := !lMarcar ), oBrowse:Refresh(.T.)  }
            oBrowse:Activate()
            oBrowse:oBrowse:Setfocus() //Seta o foco na grade
            
        Else
            Return
        EndIf

        //Limpar o arquivo temporário
        If File(cArqTrb)
           If !Empty(cArqTrb)
              Ferase(cArqTrb+GetDBExtension())
              Ferase(cArqTrb+OrdBagExt())
              cArqTrb := ""
              TRB->(DbCloseArea())
           Endif
        endif
    Else
        Alert("Não existem solicitações para o processamento com os parâmetros informados, revise os parâmetros!.")
    EndIf

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
Static Function Popular_Temporaria()
Local cQuery	:= ""
Local cAliasSQL := GetNextAlias()
IF FWIsInCallStack("MATA110")
   cQuery := " SELECT C1_NUM SC, C1_ITEM ITEM, C1_PRODUTO PRODUTO, C1_DESCRI DESCR,C1_EMISSAO EMISSAO,C1_SOLICIT SOLICIT" + CRLF
   cQuery += " FROM " + RetSQLName('SC1') + " C1"                          + CRLF
   cQuery += " WHERE C1.C1_FILIAL = '" + FWxFilial('SC1') + "' "           + CRLF
   cQuery += " AND C1.C1_NUM = '" + SC1->C1_NUM  + "'"                     + CRLF
   cQuery += " AND C1.C1_APROV <> 'R' "                                    + CRLF
ELSE
    cQuery := " SELECT C1_NUM SC, C1_ITEM ITEM, C1_PRODUTO PRODUTO, C1_DESCRI DESCR,C1_EMISSAO EMISSAO,C1_SOLICIT SOLICIT" + CRLF
    cQuery += " FROM " + RetSQLName('SC1') + " C1"                          + CRLF
    cQuery += " WHERE C1.C1_FILIAL = '" + FWxFilial('SC1') + "' "           + CRLF
    cQuery += " AND C1.C1_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "   + CRLF
    cQuery += " AND C1.C1_APROV <> 'R' "                                  + CRLF
    IF MV_PAR04 <> ' ' 
        cQuery += " AND C1.C1_PRODUTO = '" + MV_PAR04 + "' "                + CRLF
    Endif
    IF MV_PAR05 <> ' '
        cQuery += " AND C1.C1_USER = '" + MV_PAR05 + "' "                   + CRLF
    Endif
ENDIF
cQuery += " AND C1.D_E_L_E_T_  = ' ' "                                  + CRLF
cQuery += " ORDER BY 1, 2 "                                             + CRLF
cQuery := ChangeQuery(cQuery)

DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSQL, .T., .T. )

DbSelectArea((cAliasSQL))
(cAliasSQL)->(dbGoTop())

If !Empty(cArqTrb)
    Ferase(cArqTrb+GetDBExtension())
    Ferase(cArqTrb+OrdBagExt())
    cArqTrb := ""
    TRB->(DbCloseArea())
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
      

While (cAliasSQL)->(!Eof())
    If RecLock("TRB",.t.)
        TRB->TR_OK       :=  "  "
        TRB->TR_SC       :=  (cAliasSQL)->SC
        TRB->TR_ITEM 	 :=  (cAliasSQL)->ITEM
        TRB->TR_PRODUTO  :=  (cAliasSQL)->PRODUTO 
        TRB->TR_DESCR    :=  (cAliasSQL)->DESCR
        TRB->TR_EMISSAO  :=  STOD((cAliasSQL)->EMISSAO)
        TRB->TR_SOLICIT  :=  (cAliasSQL)->SOLICIT
        TRB->(MsUnLock())
    Endif
    (cAliasSQL)->(DbSkip())
EndDo

Return(.T.) 


/*
=====================================================================================
Programa.:              ZCOMF032I
Autor....:              A. Oliveira
Data.....:              20/10/2020
Descricao / Objetivo:   Função para marcar/desmarcar todos os registros do grid
Doc. Origem:                  
Solicitante:            Compras
Uso......:              U_ZCOMF032
Obs......:
=====================================================================================
*/
Static Function ZCOMF032I(cMarca,lMarcar)
Local aAreaINV  := (cAliasSC)->( GetArea() )

dbSelectArea(cAliasSC)
(cAliasSC)->( dbGoTop() )
While !(cAliasSC)->( Eof() )
    RecLock( (cAliasSC), .F. )
    (cAliasSC)->TR_OK := IIf( lMarcar, cMarca, '  ' )
    MsUnlock()
    (cAliasSC)->( dbSkip() )
EndDo
RestArea( aAreaINV )

Return(.T.)


/*
=====================================================================================
Programa.:              ZCOMF032T
Autor....:              A. Oliveira
Data.....:              20/10/2020
Descricao / Objetivo:   Função para criar as colunas do grid
Doc. Origem:            
Solicitante:            Compras
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZCOMF032T(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
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
Programa.:              ZCOMF032G
Autor....:              A. Oliveira
Data.....:              20/10/2020
Descricao / Objetivo:   Bloqueia SC
Doc. Origem:            
Solicitante:            Compras
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZCOMF032G()
Local nJanAltu := 430      
Local nJanLarg := 650
Local lOk           := .F.
Local cNum          := ""
Local cItem         := ""
Local cProduto      := ""
Local cDesc         := ""
Local dEmis         := STOD("")
Local cSolic        := ""
Local cObs          := ""
Local OObs          
Local cMotivo       := ""
Local aMotivo       := {}
Local oMotivo   
Local y 
Local aSizeAut      := MsAdvSize(,.F.,400)
Private aRadio      := {}
Private _aObsQ      := {}
Private cEnvMail      := {}
Private _aArea   := GetArea()
Private cMail         := .F.

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

    aAdd(aRadio,      "Cod Servico Incorreto")
    aAdd(aRadio,      "Contrato Gerado"      )
    aAdd(aRadio,      "Pedido Gerado"        )
    aAdd(aRadio,      "Requisicao Incorreta" )
    aAdd(aRadio,      "Detalhar o Item"      )

//Busca Listbox dos tipos de motivos das Recusas das SC
SX5->(DbSetOrder(1))
SX5->(DbSeek(xFilial("SX5") + "SA"))
IF SX5->X5_TABELA == "SA" 
    While !SX5->(EOF()) .AND. SX5->X5_TABELA == "SA"
        AADD(aMotivo, ALLTRIM(SX5->X5_CHAVE) + " - " + Alltrim(SX5->X5_DESCRI) )
        SX5->( dbSkip() )
    End
Else
    Alert("Tabela de Motivos SA, não encontrada na SX5!")
Endif    

TRB->( DbSetOrder(1) )
TRB->( DbGoTop() )
While !TRB->(Eof())

    If !Empty(TRB->TR_OK) //Se diferente de vazio, é porque foi marcado
        
        IF TRB->TR_SC <> cNum 
        
            cNum := TRB->TR_SC
       
            RecLock( (cAliasSC), .F. )
            (cAliasSC)->TR_OK := '  '
            MsUnlock()
            
            cItem    := TRB->TR_ITEM
            cProduto := TRB->TR_PRODUTO
            cDesc    := TRB->TR_DESCR
            dEmis    := TRB->TR_EMISSAO
            cSolic   := TRB->TR_SOLICIT
            cMotivo  := ""
            cObs     := "Recusado por: " + _cCodUs + " - " + _cNomeUs + " Data: " + DTOC(Date()) + " Hora: " + Time()

            //Criando a janela
            DEFINE MSDIALOG oDlgSCt TITLE "Recusa Solicitação" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
            
            @ 016,007 SAY "N.Solitação" OF oDlgSCt PIXEL SIZE 031,006
            @ 013,060 MSGET cNum PICTURE PesqPict('SC1','C1_NUM') When .F. OF oDlgSCt PIXEL SIZE 031,006
        
            @ 036,007 SAY "Item" OF oDlgSCt PIXEL SIZE 042,006
            @ 033,060 MSGET cItem PICTURE PesqPict('SC1','C1_ITEM') When .F. OF oDlgSCt PIXEL SIZE 031,006

            @ 056,007 SAY "Produto" OF oDlgSCt PIXEL SIZE 031,006
            @ 053,060 MSGET cProduto PICTURE PesqPict('SC1','C1_PRODUTO') When .F. OF oDlgSCt PIXEL SIZE 100,006
        
            @ 076,007 SAY "Descrição" OF oDlgSCt PIXEL SIZE 042,006
            @ 073,060 MSGET cDesc PICTURE PesqPict('SC1','C1_DESCRI') When .F. OF oDlgSCt PIXEL SIZE 130,006

            @ 096,007 SAY "Emissão" OF oDlgSCt PIXEL SIZE 050,006
            @ 093,060 MSGET dEmis PICTURE PesqPict('SC1','C1_EMISSAO') When .F. OF oDlgSCt PIXEL SIZE 040,006
            
            @ 116,007 SAY "Solicitante" OF oDlgSCt PIXEL SIZE 036,006
            @ 113,060 MSGET cSolic PICTURE PesqPict('SC1','C1_SOLICIT') When .F. OF oDlgSCt PIXEL SIZE 050,006

            @ 136,007 SAY "Motivo" OF oDlgSCt PIXEL SIZE 050,006
            @ 133,060 MSCOMBOBOX oMotivo VAR cMotivo ITEMS aMotivo SIZE 200,006 PIXEL OF oDlgSCt 

            @ 156,007 SAY "Observação" OF oDlgSCt PIXEL SIZE 050,006     
	        @ 153,060 GET OObs VAR cObs MEMO SIZE 240,026 Valid !Empty(cObs) .and. Len(AllTrim(cObs)) >= 06 when .T. PIXEL OF ODLG 
                                   
            @ 190, 170  BUTTON oBtnSair PROMPT "Confirmar" SIZE 60, 014 OF oDlgSCt ACTION (lOk := .T.,oDlgSCt:End()) PIXEL 
            @ 190, 240  BUTTON oBtnSair PROMPT "Sair"      SIZE 60, 014 OF oDlgSCt ACTION (lOk := .F.,oDlgSCt:End()) PIXEL

            ACTIVATE MSDIALOG oDlgSCt CENTERED
            
            _DesMot := cMotivo

             IF lOk  .AND. !Empty(cObs) 
               Grv_SC(cObs,cMotivo,cNum,cItem)
               cMail := .T.
             EndIf
    
        Else
    
            cItem := TRB->TR_ITEM
            IF lOk .AND. lRet = .T. .AND. !Empty(cObs) 
               Grv_SC(cObs,cMotivo,cNum,cItem)
               cMail := .T.
            EndIf
    
        ENDIF

    ENDIF

    TRB->( dbSkip() )

EndDo

IF lOk 
   MsgInfo("Processamento realizado com sucesso!!")
ENDIF

//Envia e-mail
If cMail
    For i := 1 to len(CENVMAIL)

        cObs := ""
        _cMail  := cEnvMail[i][1]
        _cAssu  := cEnvMail[i][2]
        cNum    := cEnvMail[i][4]
        _DesMot := "  -  Motivo: "+ cEnvMail[i][5]
        _cRot   := cEnvMail[i][7]
        x       := i
        y       := i
        cSC     := CENVMAIL[y][4] 

        //Aglutina email
        while y <= len(CENVMAIL)
            If CENVMAIL[y][4] = cSC
                cObs +=  Chr(13) + Chr(10) + cEnvMail[y][6]
                y++
                i++
            else
                i--
                exit
            ENDIF   
        end

        //Dispara o email
        U_ZGENMAIL(	_cMail    ,	, _cAssu, _cAssu+"  -  "+cNum+"  -  Motivo: "+ _DesMot + " - " + cObs, , ,	, , _cRot, , ) 

    Next i
Endif

Popular_Temporaria()
TRB->( dbGotop() )
oBrowse:Refresh(.T.) 
Return()



/*
=====================================================================================
Programa.:              Validar
Autor....:              A. Oliveira
Data.....:              30/10/2020
Descricao / Objetivo:   Função para validar campos do dialog
Doc. Origem:                  
Solicitante:            Compras
Uso......:              U_ZCOMF032
Obs......:
=====================================================================================
*/
User Function Validar(cObs)
//fora de uso
nPasso++

    IF Empty(cObs) .AND. nPasso > 1 
       lRet := .T.
       nPasso := 0
       MsgInfo("Recusa não realizada por falta do preenchimento da Observação.")
    Endif

Return lRet

/*
=====================================================================================
Programa.:              Grv_SC
Autor....:              A. Oliveira
Data.....:              20/10/2020
Descricao / Objetivo:   Função para salvar os dados na SC
Doc. Origem:                  
Solicitante:            Compras
Uso......:              U_ZCOMF032
Obs......:
=====================================================================================
*/ 
Static Function Grv_SC(cObs,cMotivo,cNum,cItem,aParam)
Local _nReg    := 0
                        
Begin Transaction

    DbSelectArea("SC1")
    SC1->(DbSetOrder(1))
    
    If SC1->(dbSeek(xFilial("SC1")+cNum+cItem))
        _nReg := SC1->(Recno())
        _cMail:= Alltrim(SC1->C1_XREQMAI)
        RecLock("SC1",.F.)
        SC1->C1_XOBSMRE := cObs + " Motivo: " + cMotivo 
        SC1->C1_XMOTR   := cMotivo
        SC1->C1_APROV   := 'R'
        SC1->(MsUnlock())
        AADD(_aObsQ,{cItem, SC1->C1_PRODUTO, SC1->C1_DESCRI})
        if _Vez = 1
            cObs +=  Chr(13) + Chr(10) + "<br/> Item: " + cItem + " " + SC1->C1_PRODUTO  + " " +  SC1->C1_DESCRI
        else
            cObs =  "<br/> Item: " + cItem + " " + SC1->C1_PRODUTO  + " " +  SC1->C1_DESCRI
        Endif
        _Vez ++
        aadd(cEnvMail,{_cMail , _cAssu , _cAssu , cNum ,  _DesMot ,  cObs,  _cRot , cItem, SC1->C1_PRODUTO, SC1->C1_DESCRI})
    EndIf

    //Gravar dados para auditoria
    RecLock( "SZH",.T.) 
        SZH->ZH_FILIAL  := XFilial("SZH")
        SZH->ZH_ORIGEM  := "SC"
        SZH->ZH_DOCTO   := cNum
        SZH->ZH_ITEM    := cItem  
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

//FOR _nX := 1 TO  LEN(_aObsQ) 
//    cObs +=  Chr(13) + Chr(10) + " Item: " + _aObsQ[_nX][1] + " " + _aObsQ[_nX][2] + " " + _aObsQ[_nX][3]
//Next _nX

//U_ZGENMAIL(	_cMail,	, _cAssu, _cAssu+"  -  "+cNum+"  -  Motivo: "+ _DesMot + " - " + cObs, , ,	, , _cRot, , )  
Return()



/*/{Protheus.doc} ZCOMF020
//Encerramento do Browse
@author A. Carlos
@since 08/10/21
@version  
@type function
/*/
User Function Finalizar()

	if Type("aRotina")<>"U"
		aRotina := aOldRot
	EndIf

    oBrowse:Refresh(.T.)

	RestArea(_aArea)

Return(Nil)



/*
=====================================================================================
Programa.:              ZCOMF032G
Autor....:              A. Oliveira
Data.....:              20/10/2020
Descricao / Objetivo:   Bloqueia SC
Doc. Origem:            
Solicitante:            Compras
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZCOMF032C()
Local nJanAltu := 230      
Local nJanLarg := 450
Local cComprad := SPACE(03)
Local lOk           := .F.
Local cNum          := ""
Private aRadio      := {}
Private _aObsQ      := {}
Private _aArea   := GetArea()

TRB->( DbSetOrder(1) )
TRB->( DbGoTop() )
While !TRB->(Eof())

    If !Empty(TRB->TR_OK) //Se diferente de vazio, é porque foi marcado
        
        IF TRB->TR_SC <> cNum 
        
            cNum := TRB->TR_SC
       
            RecLock( (cAliasSC), .F. )
            (cAliasSC)->TR_OK := '  '
            MsUnlock()
            
            //Criando a janela
            DEFINE MSDIALOG oDlgSCt TITLE "Alteração do Grupo de Comprador" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
            
            
            @ 036,063 SAY "Código do Comprador"          OF oDlgSCt PIXEL SIZE 100,010
            @ 033,133 MSGET cComprad  When .T. F3 "SY1" OF oDlgSCt PIXEL SIZE 031,006

                                   
            @ 090, 030  BUTTON oBtnSair PROMPT "Confirmar" SIZE 60, 014 OF oDlgSCt ACTION (lOk := .T.,oDlgSCt:End()) PIXEL 
            @ 090, 140  BUTTON oBtnSair PROMPT "Sair"      SIZE 60, 014 OF oDlgSCt ACTION (lOk := .F.,oDlgSCt:End()) PIXEL

            ACTIVATE MSDIALOG oDlgSCt CENTERED
            
            IF lOk  .AND. Empty(cComprad) 
               ApMsgInfo("Codigo do comprador em branco, A alteração não foi efetivada!!!","[ ZCOMF032 ] - Cancelado") 
            EndIf

            IF lOk  .AND. !Empty(cComprad) 
               Grv_Comp(cNum,cComprad)
            EndIf

            IF !lOk 
               EXIT 
            EndIf
     
        ENDIF

    ENDIF

    TRB->( dbSkip() )

EndDo

Popular_Temporaria()
TRB->( dbGotop() )
oBrowse:Refresh(.T.) 
Return()


/*
=====================================================================================
Programa.:              Grv_Comp
Autor....:              Sandro Ferreira
Data.....:              22/04/2022
Descricao / Objetivo:   Função para salvar os dados na SC
Doc. Origem:                  
Solicitante:            Compras
Uso......:              U_ZCOMF032
Obs......:
=====================================================================================
*/ 
Static Function Grv_Comp( cNum, cComp )
Local cImp := .T.
                       
Begin Transaction

    DbSelectArea("SC1")
    SC1->(DbSetOrder(1))
    
    If SC1->(dbSeek(xFilial("SC1")+cNum))

		While  SC1->(!Eof()) .And.  SC1->C1_NUM == cNUM 
            IF SC1->C1_IMPORT = "S" .OR. SC1->C1_QUANT > SC1->C1_QUJE
               RecLock("SC1",.F.)
               SC1->C1_CODCOMP   := cComp
               SC1->(MsUnlock())
            ELSE
               cImp := .F.   
            ENDIF   
            SC1->(dbSkip())
		EndDo

        IF cImp = .F.
           MsgInfo("Alteração não Realizada, valido apenas para Solicitações de Compras em aberto ou de produtos Importados!")
        ELSE
           MsgInfo("Alteração Realizada com Sucesso!")
        ENDIF
        
    EndIf

End Transaction

Return()
