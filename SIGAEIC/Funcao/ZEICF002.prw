#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

#DEFINE CRLF Char(13) + Char(10)

/* =====================================================================================
Programa.:              ZEICF002
Autor....:              CAOA - Valter Carvalho
Data.....:              06/08/2020
Descricao / Objetivo:   Manipulação da Integração dos arquivos SIGAEIC recebimento
Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              IN100CLI_PE
Obs......:
===================================================================================== */

User Function ZEICF002()
    Local cParamIXB := Iif(ValType(ParamIXB) == "A", cParamIXB:= ParamIXB[1], cParamIXB:= ParamIXB)
    
    Local cNmFunc   := Iif( Type("cFuncao") == "C", cFuncao, " ")

    Begin Sequence

        ConOut(" ZEICF002 ->" + cParamIXB )

        Do Case

        Case  cNmFunc == "FE" .AND. (cParamIXB == "VALFE") // roda a pos a quebra de lote

        zTrataMsgSer()

        zAjCpTb()

        Case  cNmFunc == "FE" .AND. (cParamIXB == "FIMAPPEND")
 
            FWMsgRun(, {|| Refaz_NF() }, "", "Lendo o arquivo da de nota fiscal...")

        Case cParamIXB == "GRVFE"    // ultimo p.e. antes do execauto da nota fiscal

            GRVFE()

        Case cNmFunc == "FE" .AND. cParamIXB == "POS_GRVFEFIM"

            FWMsgRun(, {|| Aj_BsIcmSwn() }, "", "Ajuste Rateio ICMS...")  // Ajuste SWN a psrtir da SWN

            FWMsgRun(, {|| Aj_Swn() }, "", "Ajuste Itens da NF de Importacao...")  // Ajuste SWN a psrtir da SWV

            FWMsgRun(, {|| Aj_Sd1Sf1() }, "", "Ajuste Itens da NF...")  

        Case cNmFunc == "FE" .AND. cParamIXB == "FIM"  // mostra uma popup com os numeros das notas

            If nResumoCer > 0 .and. nResumoErr = 0
                GetNfHawb()
            EndIf

        Case cParamIXB == "DH"  // ajuste do layout para receber o arquivo despesas

            aEstruDef[ascan(aEstruDef, {|cCp| Alltrim(cCp[1]) == "NDHHOUSE"}),  3]  := 30

        Case  cNmFunc == "DE" .AND. (cParamIXB == "FIMAPPEND" .OR. cParamIXB == "ABRIR" )    // ajuste do RECEBIMENTO de despesas

           Aj_ArqDesp()

        EndCase

    End Sequence

Return

/*=====================================================================================
Programa.:              Refaz_NF
Autor....:              CAOA - Valter Carvalho
Data.....:              01/04/2020
Descricao / Objetivo:   Recria as tabelas de nota fiscal de despachante na integração do despachante
Doc. Origem:
Solicitante:            
===================================================================================== */
Static Function Refaz_NF()

    // regarrega a tabela de capa da nota
    Refaz_Tb("FE", "Int_FE", "Int_FE", {"NFEHAWB","NFEPO_NUM"}, {"NFENOTA+NFESERIE","NFEINT_OK+NFENOTA+NFESERIE", "NFENOTA+NFESERIE+NFEPO_NUM"} )

    CarregarTb("Int_FE", "1")

    Refaz_Tb("FD", "INT_FD", "Int_FD", {"NFDCOD_I","NFDHAWB","NFDFATURA","NFDPO_NUM"}, {"NFDNOTA+NFDSERIE"})

    CarregarTb("Int_FD", "2")
    
    Aj_Int_Fe_Fd()

    if 1=2
        ValCpNF()  // validar se tem campo nao preenchido
    EndIf
Return


/*=====================================================================================
Programa.:              Aj_ArqDesp
Autor....:              CAOA - Valter Carvalho
Data.....:              01/04/2020
Descricao / Objetivo:   Recria as tabelas de despesas na integração do despachante
Doc. Origem:
Solicitante:            
===================================================================================== */
Static Function Aj_ArqDesp()
    Refaz_Tb("DE", "INT_DE",     "NDE" + cRegNPA, {"NDEHOUSE"}, {"NDEHOUSE+NDETIPOREG"})

    Refaz_Tb("DH", "Int_DspHe",  "NDH" + cRegNPA, { "NDHHOUSE"}, { "NDHHOUSE" , "NDHINT_OK+NDHHOUSE" }   ) //DI

    CarregarTb( "Int_DspHe", "DI")

    Refaz_Tb("TX", "Int_DspTx",  "NTX" + cRegNPA, {"NTXHOUSE"}, {"NTXHOUSE+NTXMOEDA"})  //TX

    CarregarTb( "Int_DspTx", "TX")

    Refaz_Tb("DD", "Int_DspDe",  "NDD" + cRegNPA, {"NDDHOUSE"}, {"NDDHOUSE"})  //DE

    CarregarTb( "Int_DspDe", "DE")

    ValCpDesp() 
    
Return


/*=====================================================================================
Programa.:              Refaz_Tb
Autor....:              CAOA - Valter Carvalho
Data.....:              15/03/2020
Descricao / Objetivo:   Procedimento para recriar tabelas na rotina de integração do arquivo
Solicitante:            
Campos:                 cCdFun  = String com o codigo da estrutura que vaiser recuperada da funcao In100DefEstru()
                        cAlias  = Alias da tabela que é usada no processo pelo EIC
                        cTb     = nome do indice da tabela
                        aCampos = campos que devem ser mudados para o tamanho de 30 caracteres
                        aIndex  = Arraya com os indices que deve ser criados 
===================================================================================== */
Static Function Refaz_Tb(cCodFun, cAlias, cTb, aCampos, aIndex)
    Local i         := 0
    Local lDel      := .F.
    Local cNmTb     := (cAlias)->(DbInfo(10))   // nome da tabela

    If Select(cAlias) >0
        (cAlias)->(DbCloseArea())
    EndIf

    lDel := TCDelFile( cNmTb )

    aEstruDef := {}
    In100DefEstru(cCodFun) // seta no aEstruDef a estrutura dos campos
    
    for i:=1 to len(aCampos)  //efetue ajustes no tamanho das colunas
        aEstruDef[ascan(aEstruDef, {|cCp| Alltrim(cCp[1]) == aCampos[i] }),  3]  := 30
    Next

    //Recriar e abrir tabela
    MsCreate(cNmTb, aEstruDef, "TOPCONN")

    DbUseArea(.T., "TOPCONN", cNmTb, cAlias, .F.)

    ZIN100Ind( {{cAlias, cNmTb , aIndex }}   )
Return


/* =====================================================================================
Programa.:              CarregarTb
Autor....:              CAOA - Valter Carvalho
Data.....:              14/01/2020
Descricao / Objetivo:   Fonte que efetua a leitura do arquivo de texto da nota fiscal que foi recebida do despachante.
Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
===================================================================================== */
Static Function CarregarTb(cAlias, cTpReg, aAjustCp)
    Local aDados    := {}
    Local xValor    := ""
    Local nColi     := 1
    Local cLin      := ""
    Local cFile     := "\comex\intdespachante\recebidos\" + Alltrim(cFileeicei100)
    Local i         := 1

    (cAlias)->(DbGotop())

    If FT_FUse(cFile) < 0
        cFile := StrTran(cFile, ".txt", ".old")

        If FT_FUse(cFile) < 0
            MsgStop("Nao consegui ler o arquivo de texto do despachante", "IN100CLI")
            Return
        EndIf
    EndIf

    While FT_FEof() = .F.
        cLin := FT_FReadLn()

        //If cTpReg <> Substr(cLin, 1, 1) // verifica se é cabeça (1) ou item (2)
        If cTpReg <> Substr(cLin, 1, Len(cTpReg)) // verifica se é cabeça (1) ou item (2)
            FT_FSKIP()
            Loop
        EndIf

        Aadd( aDados, cLin)    

        RecLock((cAlias), .T. )

        nColi := 1

        // private aEstruDef =  é a strutura da tabela usada atualmente.
        For i:=1 to Len(aEstruDef)

            xValor := Substr(cLin, nColi, aEstruDef[i, 3])

            // ajuste arquivo de despesas , fixar adiantamento como "N"
            If Alltrim(aEstruDef[i, 1]) == "NDDADIANTA"
                xValor := "N"
            EndIf

            If aEstruDef[i,2] = "C"   // colcoar os valores na tabela
                (cAlias)->&(Alltrim(aEstruDef[i, 1])) := xValor
            ElseIf aEstruDef[i,2] = "N"
                (cAlias)->&(Alltrim(aEstruDef[i, 1])) := Val(xValor)
            ElseIf aEstruDef[i,2] = "D"
                (cAlias)->&(Alltrim(aEstruDef[i, 1])) := Stod(xValor)
            EndIf
            nColi := nColi + aEstruDef[i, 3]
        Next

        (cAlias)->(MsUnlock())
        FT_FSKIP()
    EndDo
    (cAlias)->(DbGotop())
    FT_FUSE()

Return


/*====================================================================================
Programa.:              Aj_Int_Fe_Fd
Autor....:              CAOA - Valter Carvalho
Data.....:              14/01/2020
Descricao / Objetivo:   Efetua ajustes no arquivo recebido pel despachance em relação a impostos
Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
===================================================================================== */
Static Function Aj_Int_Fe_Fd()
    Local nNota     := ""
    Local cPrd      := ""
    Local nVlIpi    := 0
    Local nVlIpiBs  := 0
    Local nVlIcm    := 0

    Public aTaxas  := {} // memoriza as taxas dos itens que estavam no arquivo

    Int_FD->(DbGoTop())

    nNota := INT_FD->NFDNOTA

    While Int_FD->(Eof()) = .F.

        RecLock("int_FD", .F. )

        // ajuste o codigo do produto
        cPrd :=  Int_FD->NFDCOD_I

        Int_FD->NFDCOD_I :=  PadR(Posicione("SA5", 5, Xfilial("SA5") + cPrd, "A5_PRODUTO" ), Len(cPrd), " ")  

        //pegue as taxas para posterior ajuste
        If Ascan( aTaxas, {|aIt| aIt[1] == Int_FD->NFDCOD_I }) = 0
            Aadd(aTaxas, {AllTrim(Int_FD->NFDCOD_I), Val(Int_FD->NFDIPITX), Int_FD->NFDIPITX, INT_FD->NFDICMSTX, Int_FD->NFDIITX})
        EndIf    

        // Ajusta ICMS
        Int_FD->NFDICMS := zCalcVl("NFDICMS", {Int_FD->NFDBASEICM}, Int_FD->NFDICMSTX )
        nVlIcm += val(Int_FD->NFDICMS)

        //ajuste de II
        //Int_FD->NFDII := zCalcVl("NFDII", Int_FD->NFDVALOR, Int_FD->NFDIITX )

        // Ajusta IPI
        // ajustado em 10/05/2021 valter
        //Int_FD->NFDIPI := zCalcVl("NFDIPI", {INT_FD->NFDFOBRS, INT_FD->NFDFRETE, INT_FD->NFDSEGURO, IF(lMV_GRCPNFE, INT_FD->NFDDESPADU, "0"), Int_FD->NFDII}, Int_FD->NFDIPITX )
        Int_FD->NFDIPI := zCalcVl("NFDIPI", {INT_FD->NFDVALOR, Int_FD->NFDII}, Int_FD->NFDIPITX )
        
        nVlIpi += Val(Int_FD->NFDIPI)
        
        // Valor da BaseIPI
        nVlIpiBs +=  Val(Int_FD->NFDIPI)

        // ajusta as despesa 

        int_FD->(MsUnlock())

        Int_FD->(DbSkip())
        
        If INT_FD->NFDNOTA <> nNota
                
            nNota := INT_FD->NFDNOTA

            RecLock("Int_FE", .F. )

            Int_FE->NFEESPECIE  := "NFU"

            Int_FE->NFEIPI      :=  PadL( CvalToChar(nVlIpi), Len( Int_FE->NFEIPI), " ")

            Int_FE->NFEBASEIPI  :=  PadL( CvalToChar(nVlIpiBs), Len( Int_FE->NFEIPI), " ")

            Int_FE->(MsUnlock())

        EndIf

    EndDo

    Int_FD->(DbGoTop())

    Int_FE->(DbGoTop())
Return


 Static Function zCalcVl(cCampo, aBase, cTaxa)
    Local nBase  := 0
    Local xValor := 0
    Local nTx    := Val(cTaxa)

    aEval(aBase, {|cIt| nBase += Val(cIt)})

    xValor := Round(nBase * (nTx /100), 2)

    xValor := PadL( xValor, Len(Int_FD->&(cCampo)), "0")
Return xValor


/*=====================================================================================
Programa.:              ZIN100Ind
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              14/01/2020
Descricao / Objetivo:   Recria o indice da Tabela
Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              
Obs......:
===================================================================================== */
Static Function ZIN100Ind( aInd )
    Local cSeqInd    := "0"
    Local lRet       := .T.
    Local lExistInd  := .F.
    Local i,j

    For i:=1 to Len( aInd )
        cSeqInd    := "0"
        //Limpa os índices da tabela
        (aInd[i][1])->(DBClearIndex())
        For j:=1 To Len(aInd[i][3])
            lExistInd :=  MsFile( aInd[i][2] , aInd[i][2] + cSeqInd, "TOPCONN")
            If !lExistInd
                
               Index on &(aInd[i][3][j]) to &( aInd[i][2] + cSeqInd )
            
            EndIf

            DbSetIndex(aInd[i][2] + cSeqInd)
            cSeqInd := Soma1(cSeqInd)
        Next j
    Next i

Return lRet

/*====================================================================================
Programa.:              Aj_BsIcmSwn()
Autor....:              CAOA - Valter Carvalho
Data.....:              07/07/2020
Descricao / Objetivo:   Efetua o ajuste da base de ICMS da D1 para  WN apos a insercção da nota
Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
=====================================================================================   */
Static Function Aj_BsIcmSwn()
    Local cmd    := ""
    Local cQr    := GetNextAlias()
    Local nBase  := 0
    Local nVlIcm := 0

    cmd += CRLF + " SELECT WN_FILIAL, WN_DOC, WN_SERIE, WN_FORNECE, WN_LOJA, WN_PRODUTO, WN_ITEM, R_E_C_N_O_ AS RECNO "
    cmd += CRLF + " FROM " + RetSqlName("SWN")
    cmd += CRLF + " WHERE "
    cmd += CRLF + "     D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND WN_HAWB = '" + SW6->W6_HAWB + "' "
    cmd += CRLF + " ORDER BY WN_FILIAL, WN_DOC, WN_SERIE, WN_FORNECE, WN_LOJA, WN_ITEM "
    
    TcQuery cmd new Alias (cQr)

    While (cQr)->(eof()) = .F.
        nBase   := Posicione("SD1", 1, (cQr)->WN_FILIAL + (cQr)->WN_DOC + (cQr)->WN_SERIE + (cQr)->WN_FORNECE + (cQr)->WN_LOJA + (cQr)->WN_PRODUTO, "D1_BASEICM" )    
        nVlIcm  := Posicione("SD1", 1, (cQr)->WN_FILIAL + (cQr)->WN_DOC + (cQr)->WN_SERIE + (cQr)->WN_FORNECE + (cQr)->WN_LOJA + (cQr)->WN_PRODUTO, "D1_VALICM" )    

        cmd := CRLF + " UPDATE " + RetSqlName("SWN")   
        cmd += CRLF + "  SET WN_BASEICM = " + cValToChar(nBase)
        cmd += CRLF + " ,    WN_VALICM = "  + cValToChar(nVlIcm)
        cmd += CRLF + " ,    WN_VL_ICM = "  + cValToChar(nVlIcm)
        cmd += CRLF + " WHERE "
        cmd += CRLF + " R_E_C_N_O_ = " + CvalToChar((cQr)->RECNO)

        TCSqlExec(cmd)

        (cQr)->(DbSkip())
    EndDo

    (cQr)->(DbCloseArea())
Return


/*=====================================================================================
Programa.:              AjSwn()
Autor....:              CAOA - Valter Carvalho
Data.....:              07/07/2020
Descricao / Objetivo:   Efetua o ajuste de campos da tabela SWN a partir da SWV
Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              
Obs......:
=====================================================================================   */
Static Function Aj_Swn()
    Local cChave    := ""
    Local cErr      := ""
    Local aAreaW8   := SW8->(GetArea())
    Local nRecno    := 0
    Local cAliasWV  := getNextAlias()
    Local cAliasWN  := getNextAlias()
    Local cmd       := ""

    cmd += CRLF + " SELECT "
    cmd += CRLF + "   WV_HAWB, WV_INVOICE, WV_PO_NUM, WV_XLOTE, WV_XVIN, WV_COD_I, WV_QTDE, WV_LOTE, WV_XCASE, WV_QTDE "
    cmd += CRLF + " , WV_XCONT, WV_XCORIN, WV_XCOREX, WV_XOPC, WV_XANOFB, WV_XANOMD, WV_XMOTOR, WV_XSERMO, WV_POSICAO, WV_PGI_NUM "
    cmd += CRLF + " FROM " + RetSqlName("SWV")
    cmd += CRLF + " WHERE
    cmd += CRLF + "     D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND WV_FILIAL = '" + cFilAnt + "'  "
    cmd += CRLF + " AND WV_HAWB = '" +  Int_FE->NFEHAWB + "' "
    cmd += CRLF + " ORDER BY WV_COD_I, WV_XCASE"

    SW8->(dbSetOrder(6)) //W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM

    TcQuery cmd new Alias (cAliasWV)

    (cAliasWV)->(DbGoTop())

    while (cAliasWV)->(Eof()) = .F.

        If SW8->(DbSeek(xFilial("SW8") + (cAliasWV)->WV_HAWB + (cAliasWV)->WV_INVOICE +(cAliasWV)->WV_PO_NUM + (cAliasWV)->WV_POSICAO + (cAliasWV)->WV_PGI_NUM) )
            cChave := SW8->W8_XCHAVE
        EndIf

        //pegue o recno da swn
        cmd := ""
        cmd += CRLF + " SELECT R_E_C_N_O_ AS RECNO"
        cmd += CRLF + " FROM " + RetSqlName("SWN")
        cmd += CRLF + " WHERE "
        cmd += CRLF + "     ROWNUM     = 1  "
        cmd += CRLF + " AND D_E_L_E_T_ = ' ' "
        cmd += CRLF + " AND WN_FILIAL  = '" + cFilAnt +  "'  "
        cmd += CRLF + " AND WN_HAWB    = '" + (cAliasWV)->WV_HAWB + "' "
        cmd += CRLF + " AND WN_PRODUTO = '" + (cAliasWV)->WV_COD_I + "' "
        cmd += CRLF + " AND WN_XLOTE   = ' ' "

        TcQuery cmd new Alias (cAliasWN)
        nRecno := (cAliasWN)->RECNO

        If nRecno = 0
            cErr += CRLF + " Produto:" + (cAliasWV)->WV_HAWB + " Prd: " + (cAliasWV)->WV_COD_I 
        Else
            cmd := ""
            cmd += CRLF + " UPDATE " + RetSqlName("SWN")
            cmd += CRLF + " SET "
            cmd += CRLF + "    WN_XCHAVE  = '" + cChave                 + "' "    
            cmd += CRLF + " ,  WN_XCONT   = '" + (cAliasWV)->WV_XCONT   + "' "
            cmd += CRLF + " ,  WN_XVIN    = '" + (cAliasWV)->WV_XVIN    + "' "
            cmd += CRLF + " ,  WN_XLOTE   = '" + Alltrim((cAliasWV)->WV_LOTE) + Alltrim((cAliasWV)->WV_XCASE) + "' "
            cmd += CRLF + " ,  WN_CORINT  = '" + (cAliasWV)->WV_XCORIN  + "' "        
            cmd += CRLF + " ,  WN_COREXT  = '" + (cAliasWV)->WV_XCOREX  + "' "        
            cmd += CRLF + " ,  WN_OPCION  = '" + (cAliasWV)->WV_XOPC    + "' "        
            cmd += CRLF + " ,  WN_ANOFAB  = '" + (cAliasWV)->WV_XANOFB  + "' "        
            cmd += CRLF + " ,  WN_ANOMOD  = '" + (cAliasWV)->WV_XANOMD  + "' "        
            cmd += CRLF + " ,  WN_XMOTOR  = '" + (cAliasWV)->WV_XMOTOR  + "' "        
            cmd += CRLF + " ,  WN_XSERMO  = '" + (cAliasWV)->WV_XSERMO  + "' "        

            cmd += CRLF + " WHERE R_E_C_N_O_ = " + CvalToChar(nRecno)

            If TCSqlExec( cmd ) < 0
                Alert("Erro ao executar a atualização do swn " + TCSQLError())
            EndIf

        EndIf

        (cAliasWN)->(DbCloseArea())

        (cAliasWV)->(DbSkip())

    EndDo

    (cAliasWV)->(DbCloseArea()) 
    SW8->(RestArea(aAreaW8))
Return


/*====================================================================================
Programa.:              AjSd1()
Autor....:              CAOA - Valter Carvalho
Data.....:              07/07/2020
Descricao / Objetivo:   Efetua o ajuste de campos da tabela 
                        SF1 a partir da SWN na entrada nota integracao
Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
=====================================================================================   */
Static Function Aj_Sd1Sf1()
    Local aDocs     := {}
    Local cErr      := ""
    Local cAliasWN  := GetNextAlias()
    Local cmd       := ""

    cmd += CRLF + " SELECT "
    cmd += CRLF + " WN_DOC, WN_SERIE, WN_FORNECE, WN_LOJA, WN_PRODUTO, WN_LINHA, WN_XCONT, WN_XVIN, "
    cmd += CRLF + " WN_CORINT, WN_COREXT, WN_OPCION, WN_ANOFAB, WN_ANOMOD, WN_FRETE
    cmd += CRLF + " FROM " + RetSqlName("SWN") + " SWN "
    
    cmd += CRLF + " INNER JOIN " + RetSqlName("SF1") + " SF1 ON SF1.D_E_L_E_T_ = ' ' AND F1_FILIAL = WN_FILIAL AND F1_DOC = WN_DOC AND F1_SERIE = WN_SERIE " 

    cmd += CRLF + " WHERE "
    cmd += CRLF + "     SWN.D_E_L_E_T_ = ' ' "      
    cmd += CRLF + " AND WN_FILIAL = '" + cFilAnt         + "' "
    cmd += CRLF + " AND WN_HAWB    = '" + Int_FE->NFEHAWB + "' "       
    cmd += CRLF + " ORDER BY WN_DOC, WN_LINHA "     

    TcQuery cmd new alias (cAliasWN)
    (cAliasWN)->(DbGoTop())

    DbSelectArea("SD1")
    DbSetOrder(1)

    While (cAliasWN)->(Eof()) = .F.

        If Ascan(aDocs, Alltrim((cAliasWN)->WN_SERIE) + "/" + Alltrim((cAliasWN)->WN_DOC) ) = 0
            Aadd(aDocs, Alltrim((cAliasWN)->WN_SERIE) + "/" + Alltrim((cAliasWN)->WN_DOC) )
        EndIf

        If SD1->(DbSeek(Xfilial("SD1") + (cAliasWN)->WN_DOC + (cAliasWN)->WN_SERIE + (cAliasWN)->WN_FORNECE + (cAliasWN)->WN_LOJA + (cAliasWN)->WN_PRODUTO + StrZero((cAliasWN)->WN_LINHA, 4)))
            RecLock("SD1",.F.)

            SD1->D1_XCONT  := (cAliasWN)->WN_XCONT	
            SD1->D1_CHASSI := (cAliasWN)->WN_XVIN
            SD1->D1_SERVIC := Posicione("SB5", 1, Xfilial("SB5") + (cAliasWN)->WN_PRODUTO, "B5_SERVENT")
            SD1->D1_ENDER  := Posicione("SB5", 1, Xfilial("SB5") + (cAliasWN)->WN_PRODUTO, "B5_ENDENT")
            SD1->D1_STSERV := "1"  // Nao concluido

            SD1->D1_CORINT  := (cAliasWN)->WN_CORINT
            SD1->D1_COREXT  := (cAliasWN)->WN_COREXT
            SD1->D1_OPCION  := (cAliasWN)->WN_OPCION
            SD1->D1_ANOMOD  := (cAliasWN)->WN_ANOMOD
            SD1->D1_ANOFAB  := (cAliasWN)->WN_ANOFAB

            (cAliasWN)->(MsUnlock())
        Else
            cErr += "- Nf:" + (cAliasWN)->WN_DOC + " Prd:" + (cAliasWN)->WN_PRODUTO 
        EndIf
        (cAliasWN)->(DbSkip())
    EndDo

    SD1->(DbCloseArea())
    (cAliasWN)->(DbCloseArea())

    cmd := ""
    aEval(aDocs, {|cIt| cmd+= cIt + CRLF} )

Return


/*=====================================================================================
Programa.:              RefazInt_FD
Autor....:              CAOA - Valter Carvalho
Data.....:              14/01/2020
Descricao / Objetivo:   Efetua o preenchimento do campo de Armazem no processamento da nota fiscal de entrada.
Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
===================================================================================== */
Static Function GRVFE()
    Local nVlBase       := 0
    Local nTRatDesp     := 0
    Local nTRatImp      := 0
    Local nTotPeso      := 0
    Local nTorProd      := 0 
    Local nPerc         := 0     
    Local i             := 1
    Local cmd           := ""
    Local cAliasDsp     := GetNextAlias()
    Local nD1_BASEIPI   := Ascan(aItens[1], {|aIt| aIt[1] == "D1_BASEIPI"})
    Local nD1_TOTAL     := Ascan(aItens[1], {|aIt| aIt[1] == "D1_TOTAL"})
    Local nD1_PESO      := Ascan(aItens[1], {|aIt| aIt[1] == "D1_PESO"})
    Local nD1_QUANT     := Ascan(aItens[1], {|aIt| aIt[1] == "D1_QUANT"})
    Local nD1_BASEICM   := Ascan(aItens[1], {|aIt| aIt[1] == "D1_BASEICM"})
    Local nBICM2        := 0  
    Local nBIPI2        := 0 
    Local nD1_VALICM    := Ascan(aItens[1], {|aIt| aIt[1] == "D1_VALICM"})
    Local nD1_PICM      := Ascan(aItens[1], {|aIt| aIt[1] == "D1_PICM"})
    
    Local nvUnit        := Ascan(aItens[1], {|aIt| aIt[1] == "D1_VUNIT"})
    Local nvII          := Ascan(aItens[1], {|aIt| aIt[1] == "D1_II"})

    // pegar peso e valor total dos itens
    For i:= 1 to Len(aItens)
        nTorProd  +=  aItens[i, nD1_TOTAL, 2]
        nTotPeso  +=  aItens[i, nD1_PESO,  2] * aItens[i, nD1_QUANT,  2]
    Next

    For i:= 1 to Len(aItens[1])
        // o campo D1_BASEICMS tem duas vezes no array gerado pelo sistema, nao me pergunte o motivo, mas preciso atualizar ambos campos
        Iif( aItens[1, i, 1] = "D1_BASEICM", nBICM2 := i, "")
        
        // o campo D1_BASEIPI tem duas vezes no array gerado pelo sistema, nao me pergunte o motivo, mas preciso atualizar ambos campos
        Iif( aItens[1, i, 1] = "D1_BASEIPI", nBIPI2 := i, "")
    Next

    For i:=1 to Len(aItens)
         aItens[i, nD1_BASEICM, 2] := 0
         aItens[i, nBICM2, 2]   := 0
    Next

    // Efetue o rateio das despesas
    cmd += Char(13) + Char(10) + " SELECT YB_DESP, YB_DESCR, YB_RATPESO, WD_VALOR_R /*, YB_BASEIMP, YB_BASEICM */ " //, SWD010.* 
    cmd += Char(13) + Char(10) + " FROM " + RetSqlName("SWD") + " SWD "
    cmd += Char(13) + Char(10) + " INNER JOIN " + RetSqlName("SYB") + " SYB "
    cmd += Char(13) + Char(10) + " ON  SYB.D_E_L_E_T_ = ' ' AND YB_DESP = WD_DESPESA "
    cmd += Char(13) + Char(10) + " AND YB_BASEICM = '1' 
    cmd += Char(13) + Char(10) + " AND YB_BASEIMP in ('2', ' ') " 
    cmd += Char(13) + Char(10) + " AND YB_ICMS_GO = '1' "
    cmd += Char(13) + Char(10) + " WHERE "
    cmd += Char(13) + Char(10) + " SWD.D_E_L_E_T_ = ' '  "
    cmd += Char(13) + Char(10) + " AND WD_HAWB = '" + SW6->W6_HAWB + "' " 
    cmd += Char(13) + Char(10) + " ORDER BY YB_DESP "
    TcQuery cmd new alias (cAliasDsp)

   nTRatDesp := 0
   (cAliasDsp)->(DbGoTop())
    While (cAliasDsp)->(Eof()) = .F.

        For i:=1 to Len(aItens)

            If (cAliasDsp)->YB_RATPESO = "2" .OR. Empty((cAliasDsp)->YB_RATPESO) = .T.     //Efetua Rateio pelo peso    
                nPerc := aItens[i, nD1_TOTAL, 2] / nTorProd

                nTRatDesp += (cAliasDsp)->WD_VALOR_R * nPerc

                aItens[i, nD1_BASEICM, 2] += ((cAliasDsp)->WD_VALOR_R * nPerc) 

            Else // efetua rateio pelo Valor
                nPerc := (aItens[i, nD1_PESO, 2] * aItens[i, nD1_QUANT, 2]) / nTotPeso

                nTRatDesp += (cAliasDsp)->WD_VALOR_R * nPerc

                aItens[i, nD1_BASEICM, 2] += ( (cAliasDsp)->WD_VALOR_R * nPerc) 

            EndIf
        Next    

        (cAliasDsp)->(DbSkip())
    EndDo
    
    (cAliasDsp)->(DbCloseArea())

    // Adicione na base de icms os valores FOB, Frete, despesas aduaneiras, II, PIS e COFINS			
    INT_FD->(DbGoTop())
    
    nTRatImp := 0
 
    For i:= 1 to Len(aItens)
        nVlBase := 0

        nVlBase := Val(INT_FD->(NFDFOBRS)) + Val(INT_FD->(NFDFRETE))  + Val(INT_FD->(NFDDESPADU)) + ;
                   Val(INT_FD->(NFDII))    + Val(INT_FD->(NFDVLRPIS)) + Val(INT_FD->(NFDVLRCOF))  + Val(INT_FD->(NFDIPI)) 

        nVlBase += aItens[i,  nD1_BASEICM, 2 ]

        nVlBase := nVlBase / ( 1 - (aItens[i,  nD1_PICM, 2 ] / 100 ) )

        aItens[i,  nD1_BASEICM, 2 ] := nVlBase

        aItens[i,  nD1_VALICM, 2 ] := nVlBase *  (aItens[i,  nD1_PICM, 2 ] / 100 )

        // atualiza o segundo campo de D1_BASEICM no array do aitens
        if nBICM2 > 0
            aItens[i,  nBICM2, 2 ] := aItens[i,  nD1_BASEICM, 2]
        EndIf

        nTRatImp += nVlBase

        // efetue o ajuste do campo de base de IPI
        // aItens[i,  nD1_BASEIPI, 2 ] := Val(INT_FD->(NFDIPI)) / (Val(INT_FD->(NFDIPITX)) / 100)
        aItens[i,  nD1_BASEIPI, 2 ] := Val(INT_FD->NFDVALOR) + Val(Int_FD->NFDII)

        if nBIPI2 > 0
            aItens[i,  nBIPI2, 2 ] := aItens[i,  nD1_BASEIPI, 2]
        EndIf

        // efetue o ajuste do valor unitario adicionado o valor do II para unidade
        aItens[i, nvUnit, 2 ] :=  aItens[i, nvUnit, 2 ] + ( aItens[i, nvII, 2 ] / aItens[i, nD1_QUANT, 2 ] )

        // ajuste o valor total item  vlunit * quant
        aItens[i, nD1_TOTAL, 2 ] := aItens[i, nvUnit, 2 ] * aItens[i, nD1_QUANT, 2 ]  

        INT_FD->(DbSkip())
    Next

Return 


/*====================================================================================
Programa.:              GetNfHawb()
Autor....:              CAOA - Valter Carvalho
Data.....:              07/07/2020
Descricao / Objetivo:   Mostra para o usuario as notas geradas
Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
=====================================================================================   */
Static Function GetNfHawb()
    Local cAliasWN  := GetNextAlias()
    Local cmd       := ""

    cmd += CRLF + " SELECT DISTINCT"
    cmd += CRLF + " WN_DOC, WN_SERIE"
    cmd += CRLF + " FROM " + RetSqlName("SWN") + " SWN "
   
    cmd += CRLF + " INNER JOIN " + RetSqlName("SF1") + " SF1 ON SF1.D_E_L_E_T_ = ' ' AND F1_FILIAL = WN_FILIAL AND F1_DOC = WN_DOC AND F1_SERIE = WN_SERIE " 

    cmd += CRLF + " WHERE "
    cmd += CRLF + "     SWN.D_E_L_E_T_ = ' ' "      
    cmd += CRLF + " AND WN_FILIAL = '"  + cFilAnt         + "' "
    cmd += CRLF + " AND WN_HAWB    = '" + Int_FE->NFEHAWB + "' "       
    cmd += CRLF + " ORDER BY WN_DOC " 

    TcQuery cmd new alias (cAliasWN)

    cmd := ""
    (cAliasWn)->(DbEval( {|| cmd += "Serie: " + Alltrim((cAliasWN)->WN_SERIE) + " Número: " + Alltrim((cAliasWN)->WN_DOC) + CRLF}, {||.T.} ))
    
    (cAliasWn)->(DbCloseArea())

    EecView("*** NOTAS GERADAS NA INTEGRAÇÃO ***" + CHAR(13) + CHAR(10) + cmd , "(GetNfHawb) Nota(s) gerada(s): ")

Return


/*=====================================================================================
Programa.:              ValCpDesp
Autor....:              CAOA - Valter Carvalho
Data.....:              14/08/2020
Descricao / Objetivo:   Validação da tabela temporaria que efetua a leitura do arquivo de despesas
                        Também faz uma varredura nos campos da not de entrada e informa se ha algum campo em branco
Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
===================================================================================== */
Static Function ValCpDesp()
    Local bExp      := nil
    Local cErr      := ""
    Local cAux      := ""

    // validar a capa das despesas
    bExp := 'cErr += " - Capa das despesa, campo " + aCp[i, 2] + ": [" + aCp[i,3] + "] não preenchido, Tipo:" + aCp[i, 4] + " Colunas:" + aCp[i, 11] + "-" + aCp[i, 12] + " campo interno:" +  aStru[i, 1] + char(13) + char(10) + char(13) + char(10)'                           

    cAux := ValTb("Int_DspHe", bExp)
    If Empty(cAux) = .F.
        cErr += "***  ERROS ENCONTRADOS NA CAPA ARQ DESPESAS ***" + Char(13) + Char(10) + cAux + Char(13) + Char(10)
    EndIf

    // Validar os itens da despesa
    cAux := ""

    bExp := 'cErr += " - Item Despesa "+ cValToChar(i) + ", campo " + aCp[i, 2] + ": [" + aCp[i,3] + "] não preenchido, Tipo:" + aCp[i, 4] + " Colunas:" + aCp[i, 11] + "-" + aCp[i, 12] + " campo interno:" +  aStru[i, 1] + char(13) + char(10) + char(13) + char(10)'

    cAux := ValTb("Int_DspDe", bExp)
    If Empty(cAux) = .F.
        cErr += "***  ERROS ENCONTRADOS NOS ITENS ARQ DESPESAS ***" + Char(13) + Char(10) + cAux + Char(13) + Char(10)
    EndIf

    // Validar TAXA
    cAux := ""

    bExp := 'cErr += " - Taxas, campo " + aCp[i, 2] + ": [" + aCp[i,3] + "] não preenchido, Tipo:" + aCp[i, 4] + " Colunas:" + aCp[i, 11] + "-" + aCp[i, 12] + " campo interno:" +  aStru[i, 1] + char(13) + char(10) + char(13) + char(10)'

    cAux := ValTb("Int_DspTx", bExp)
    If Empty(cAux) = .F.
        cErr += "***  ERROS ENCONTRADOS NAS TAXAS, ARQ DESPESAS ***" + Char(13) + Char(10) + cAux + Char(13) + Char(10)
    EndIf

    If Empty(cErr) = .F.
        EecView(cErr, "Problemas encontrados na leitura do arquivo:")
    EndIf

Return Empty(cErr)


/*=====================================================================================
Programa.:              ValTb
Autor....:              CAOA - Valter Carvalho
Data.....:              14/08/2020
Descricao / Objetivo:   Efetua a validação da tabela passada por parametro
                        Também faz uma varredura nos campos da not de entrada e informa se ha algum campo em branco
Uso:                    funcao statica ValCpNF()
===================================================================================== */
Static Function ValTb(cAlias, bExpErr)
    Local cErr  := "" 
    Local aCp   := {}
    Local aStru := {}
    Local i     := 1
    Local xValor:= nil

    // verificar os itens da nota
    aCp     := getArrCp(cAlias)
    aStru   := (cAlias)->(DbStruct())

    (cAlias)->(DbGoTop())
    While (cAlias)->(Eof()) = .F.

        For i:= 1 to Len(aCp)

            If Empty(aCp[i,1]) = .T. // campo nao Obrigatório
                Loop
            EndIf

            xValor := (cAlias)->&(aStru[i, 1])

            If aCp[i, 4] = "N" .AND. ValType(xValor) = "C"
                xValor := Val(xValor)
            EndIf

            If Empty( xValor )
                &(bExpErr)
            EndIf
        Next
        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbGoTop())
Return cErr


/*=====================================================================================
Programa.:              getArrCp
Autor....:              CAOA - Valter Carvalho
Data.....:              14/01/2020
Descricao / Objetivo:   Retorna a lista dos campos das tabelas de integração                      
Doc. Origem:
Solicitante:            
===================================================================================== */
Static Function getArrCp(cNmTb)
    Local aRes := {}

    If cNmTb = "Int_FD"
        Aadd(aRes, { "x", '01', 'Tipo', 'A', '1', 'Fixo', '1', '-', '001 – 001', '"2" / Itens', '1', '1' })
        Aadd(aRes, { "x", '02', 'Código da Empresa', 'N', '2', 'Fixo', '2', '-', '002 – 003', 'Fixo "01"', '2', '3' })
        Aadd(aRes, { "x", '03', 'Código da Filial', 'N', '2', 'Fixo', '2', '-', '004 – 005', 'Fixo "01"', '4', '5' })
        Aadd(aRes, { "x", '04', 'Número da Nota', 'N', '9', 'Itens nota - d1_doc', '9', '-', '006 – 014', '', '6', '14' })
        Aadd(aRes, { " ", '05', 'Número do Lançamento', 'N', '6', 'Não usado', '6', '-', '015 – 020', '', '15', '20' })
        Aadd(aRes, { "x", '06', 'Classificação Fiscal', 'N', '10', 'B1_POSIPI', '10', '-', '021 – 030', '', '21', '30' })
        Aadd(aRes, { "x", '07', 'Código do Produto', 'A', '20', 'Amarracao Produto x Fornecedor- A5_CODPRF', '30', '-', '031 – 050', '', '31', '60' })
        Aadd(aRes, { " ", '08', 'Código - Trib. - ICMS', 'N', '1', 'Não usado', '1', '-', '051 – 051', 'Nota 2', '61', '61' })
        Aadd(aRes, { " ", '09', 'Código - Trib. - IPI', 'N', '1', 'Não usado', '1', '-', '052 – 052', 'Nota 2', '62', '62' })
        Aadd(aRes, { " ", '10', 'Número do Item', 'N', '2', 'Não usado', '2', '-', '053 – 054', '', '63', '64' })
        Aadd(aRes, { "x", '11', 'Quantidade', 'N', '11', 'Itens nota - d1_quant', '11', '4', '055 – 065', 'Nota 7', '65', '75' })
        Aadd(aRes, { " ", '12', 'Unidade', 'A', '3', 'Unidades medida- Cod - sah_cod', '3', '-', '066 – 068', '', '76', '78' })
        Aadd(aRes, { "x", '13', 'Vlr. – IPI', 'N', '15', 'Itens nota - d1_valipi', '15', '2', '069 – 083', 'Nota 7', '79', '93' })
        Aadd(aRes, { "x", '14', 'Valor Mercadoria (CIF+II)', 'N', '15', 'Itens nota - d1_valor', '15', '2', '084 – 098', 'Nota 7', '94', '108' })
        Aadd(aRes, { " ", '15', 'Flag de Entrada', 'A', '1', 'Itens Nota - d1_total', '1', '-', '099 – 099', 'Fixo "I"', '109', '109' })
        Aadd(aRes, { " ", '16', 'Quantidade do Recebimento', 'N', '11', 'Itens Nota -  d1_quant', '11', '4', '100 – 110', 'Nota 2', '110', '120' })
        Aadd(aRes, { "x", '17', 'Descrição do Produto', 'A', '150', 'Não usado', '150', '-', '111 – 260', '', '121', '270' })
        Aadd(aRes, { "x", '18', 'Valor Fob R$', 'N', '15', '', '15', '2', '261 – 275', 'Nota 7', '271', '285' })
        Aadd(aRes, { "x", '19', 'Valor Frete R$', 'N', '15', '', '15', '2', '276 – 290', 'Nota 7', '286', '300' })
        Aadd(aRes, { " ", '20', 'Valor do Seguro R$', 'N', '15', '', '15', '2', '291 – 305', 'Nota 7', '301', '315' })
        Aadd(aRes, { "x", '21', 'Valor II R$', 'N', '15', '', '15', '2', '306 – 320', 'Nota 7', '316', '330' })
        Aadd(aRes, { "x", '22', 'Alíquota IPI', 'N', '5', '', '5', '2', '321 – 325', 'Nota 7', '331', '335' })
        Aadd(aRes, { "x", '23', 'Valor Despesas', 'N', '15', '', '15', '2', '326 – 340', 'Nota 7', '336', '350' })
        Aadd(aRes, { "x", '24', 'Nro Processo no Easy', 'A', '17', '', '30', '-', '341 – 357', '', '351', '380' })
        Aadd(aRes, { " ", '25', 'Numero da EX da NCM', 'A', '3', '', '3', '-', '358 – 360', '', '381', '383' })
        Aadd(aRes, { "x", '26', 'Numero da Invoice', 'A', '15', '', '30', '-', '361 – 375', '', '384', '413' })
        Aadd(aRes, { "x", '27', 'Valor do ICMS a recolher', 'N', '15', '', '15', '2', '376 – 390', 'Nota 7', '414', '428' })
        Aadd(aRes, { "x", '28', 'Peso Liquido do item', 'N', '11', '', '11', '4', '391 – 401', 'Nota 7', '429', '439' })
        Aadd(aRes, { "x", '29', 'Item do Pedido de Compra', 'C', '4', '', '4', '-', '402 – 405', 'Nota 6', '440', '443' })
        Aadd(aRes, { "x", '30', 'Alíquota de II', 'N', '5', '', '5', '2', '406 – 410', 'Nota 7', '444', '448' })
        Aadd(aRes, { "x", '31', 'Numero do pedido', 'C', '17', '', '30', '-', '411 – 427', '', '449', '478' })
        Aadd(aRes, { "x", '32', 'Nro do Pedido de Licenciamento', 'C', '10', '', '10', '-', '428 – 437', '', '479', '488' })
        Aadd(aRes, { "x", '33', 'Série da Nota Fiscal', 'C', '3', '', '3', '-', '438 – 440', '', '489', '491' })
        Aadd(aRes, { "x", '34', 'Base de ICMS ( por item)', 'N', '15', '', '15', '2', '441 – 455', 'Nota  7', '492', '506' })
        Aadd(aRes, { "x", '35', 'Valor FOB na moeda de Origem', 'N', '15', '', '15', '7', '456 – 470', 'Nota 7', '507', '521' })
        Aadd(aRes, { "x", '36', 'Alíquota do PIS', 'N', '6', '', '6', '2', '471 – 476', 'Nota 7', '522', '527' })
        Aadd(aRes, { " ", '37', 'Valor por quantidade do PIS', 'N', '9', '', '9', '2', '477 – 485', '', '528', '536' })
        Aadd(aRes, { "x", '38', 'Base de calculo do PIS', 'N', '15', '', '15', '2', '486 – 500', 'Nota 7', '537', '551' })
        Aadd(aRes, { "x", '39', 'Valor do PIS', 'N', '15', '', '15', '2', '501 – 515', 'Nota 7', '552', '566' })
        Aadd(aRes, { "x", '40', 'Alíquota do COFINS', 'N', '6', '', '6', '2', '516 – 521', 'Nota 7', '567', '572' })
        Aadd(aRes, { " ", '41', 'Valor por quantidade do COFINS', 'N', '9', '', '9', '2', '522 – 530', 'Nota 7', '573', '581' })
        Aadd(aRes, { "x", '42', 'Base de calculo do COFINS', 'N', '15', '', '15', '2', '531 – 545', 'Nota 7', '582', '596' })
        Aadd(aRes, { "x", '43', 'Valor do COFINS', 'N', '15', '', '15', '2', '546 – 560', 'Nota 7', '597', '611' })
        Aadd(aRes, { "x", '44', 'Número da adição', 'C', '3', '', '3', '-', '561 – 563', '', '612', '614' })
        Aadd(aRes, { "x", '45', 'Sequencia do item da adição', 'C', '3', '', '3', '-', '564 – 566', '', '615', '617' })
        Aadd(aRes, { " ", '46', 'Valor do desconto', 'N', '15', '', '15', '2', '567 – 581', 'Nota 7', '618', '632' })
        Aadd(aRes, { " ", '47', 'Valor do IOF', 'N', '15', '', '15', '2', '582 – 596', 'Nota 7', '633', '647' })
        Aadd(aRes, { "x", '48', 'Despesas Aduaneiras', 'N', '15', '', '15', '2', '597 – 611', 'Nota 7', '648', '662' })
        Aadd(aRes, { " ", '49', 'Alíquota específica do IPI', 'N', '15', '', '15', '4', '612 – 626', 'Nota 7', '663', '677' })
        Aadd(aRes, { " ", '50', 'Qtde total - IPI', 'N', '11', '', '11', '4', '627 – 637', 'Nota 7', '678', '688' })
        Aadd(aRes, { " ", '51', 'Qtde total - PIS', 'N', '11', '', '11', '4', '638 – 648', 'Nota 7', '689', '699' })
        Aadd(aRes, { " ", '52', 'Qtde total - COFINS', 'N', '11', '', '11', '4', '649 – 659', 'Nota 7', '700', '710' })
        Aadd(aRes, { " ", '53', 'Lote', 'C', '10', '', '10', '0', '660 – 669', '', '711', '720' })
        Aadd(aRes, { " ", '54', 'Validade', 'D', '8', '', '8', '0', '670 - 677', '', '721', '728' })
        Aadd(aRes, { "x", '55', 'Alíquota de ICMS do Item', 'N', '5', '', '5', '2', '678 – 682', 'Nota 7', '729', '733' })
        Aadd(aRes, { " ", '56', 'Alíquota de Majoração de COFINS', 'N', '6', '', '6', '2', '683 – 688', '', '734', '739' })
        Aadd(aRes, { " ", '57', 'Percentual Diferimento de ICMS', 'N', '8', '', '8', '4', 'F1689 – 696', '', '740', '747' })
        Aadd(aRes, { " ", '58', 'Código da LI', 'C', '10', '', '10', '-', '697 – 706 ', '', '748', '757' })
        Aadd(aRes, { " ", '59', 'Código da LI Substitutiva', 'C', '10', '', '10', '-', '707 – 716', '', '758', '767' })
   
    ElseIf cNmTb = "Int_FE"
        Aadd(aRes, { "x", '01', 'Tipo', 'A', '1', 'Fixo ', '1', '-', '001 - 001', '"1" / Capa', '1', '1' })
        Aadd(aRes, { "x", '02', 'Código da Empresa', 'N', '2', 'Fixo ', '2', '-', '002 - 003', 'Fixo "01"', '2', '3' })
        Aadd(aRes, { "x", '03', 'Código da Filial', 'N', '2', 'Fixo ', '2', '-', '004 - 005', 'Fixo "01"', '4', '5' })
        Aadd(aRes, { "x", '04', 'Número da Nota', 'N', '9', 'Nota fiscal - f1_doc', '9', '-', '006 – 014', '', '6', '14' })
        Aadd(aRes, { " ", '05', 'Filler', 'A', '6', 'Vazio', '6', '-', '015 – 020', '', '15', '20' })
        Aadd(aRes, { "x", '06', 'Aliq. ICMS', 'N', '7', '', '7', '2', '021 – 027', 'Nota 7', '21', '27' })
        Aadd(aRes, { "x", '07', 'CFOP', 'N', '6', '', '6', '-', '028 – 033', 'Nota 8', '28', '33' })
        Aadd(aRes, { " ", '08', 'CFP', 'A', '5', '', '5', '-', '034 – 038', 'Nota 2', '34', '38' })
        Aadd(aRes, { " ", '09', 'CGC - Emitente', 'N', '14', 'A2_CGC', '14', '-', '039 – 052', '', '39', '52' })
        Aadd(aRes, { " ", '10', 'Código do IPI', 'A', '3', 'Vazio', '3', '-', '053 – 055', 'Nota 2', '53', '55' })
        Aadd(aRes, { "x", '11', 'Número do processo', 'A', '17', 'Purchase order - No p.O. - w2_po_num', '30', '-', '056 – 072', '', '56', '85' })
        Aadd(aRes, { "x", '12', 'Quantidade de Itens', 'N', '2', 'Calculado', '2', '-', '073 – 074', '', '86', '87' })
        Aadd(aRes, { " ", '13', 'Data de Referência', 'N', '6', 'Não usado', '6', '-', '075 – 080', 'Nota 3', '88', '93' })
        Aadd(aRes, { "x", '14', 'Data de Emissão', 'N', '8', 'Nota fiscal - f1_emissao', '8', '-', '081 – 088', 'Nota 5', '94', '101' })
        Aadd(aRes, { " ", '15', 'Data de Entrada', 'N', '8', 'Nota fiscal - f1_dtdigit', '8', '-', '089 – 096', 'Nota 5', '102', '109' })
        Aadd(aRes, { " ", '16', 'Filler', 'A', '6', 'não usado', '6', '-', '097 – 102', '', '110', '115' })
        Aadd(aRes, { " ", '17', 'Data de Registro DI', 'N', '8', 'Purchase order - Data P.O. - w2_po_dt', '8', '-', '103 – 110', '', '116', '123' })
        Aadd(aRes, { " ", '18', 'Filler', 'A', '2', 'Vazio', '2', '-', '111 – 112', '', '124', '125' })
        Aadd(aRes, { " ", '19', 'Entrada / Saída', 'A', '1', 'Fixo ', '1', '-', '113 – 113', 'Fixo "E"', '126', '126' })
        Aadd(aRes, { "x", '20', 'Espécie', 'A', '3', 'Fixo ', '3', '-', '114 – 116', '', '127', '129' })
        Aadd(aRes, { " ", '21', 'Flag Cancelada', 'A', '1', 'Não usada', '1', '-', '117 – 117', 'Nota 2', '130', '130' })
        Aadd(aRes, { " ", '22', 'Filler', 'A', '1', 'Vazio', '1', '-', '118 – 118', '', '131', '131' })
        Aadd(aRes, { " ", '23', 'Flag Entrada', 'A', '1', 'Vazio', '1', '-', '119 – 119', 'Fixo "I"', '132', '132' })
        Aadd(aRes, { "x", '24', 'Número da DI', 'A', '10', 'Vazio', '10', '-', '120 – 129', '', '133', '142' })
        Aadd(aRes, { "x", '25', 'Série', 'A', '3', 'Vazio', '3', '-', '130 – 132', '', '143', '145' })
        Aadd(aRes, { " ", '26', 'Código de Sit. Tributária', 'A', '2', 'Vazio', '2', '-', '133 – 134', '', '146', '147' })
        Aadd(aRes, { " ", '27', 'Situação Tributária - E', 'A', '5', 'Vazio', '5', '-', '135 – 139', 'Nota 2', '148', '152' })
        Aadd(aRes, { " ", '28', 'Situação Tributária - F', 'A', '5', 'Vazio', '5', '-', '140 – 144', 'Nota 2', '153', '157' })
        Aadd(aRes, { " ", '29', 'UF do Emitente', 'A', '2', 'Uf da filial', '2', '-', '145 – 146', '', '158', '159' })
        Aadd(aRes, { " ", '30', 'Via de Transporte', 'A', '1', 'Não usado', '1', '-', '147 – 147', 'Nota 4', '160', '160' })
        Aadd(aRes, { " ", '31', 'Valor do Frete', 'N', '15', 'Não usado', '15', '2', '148 – 162', 'Nota 7', '161', '175' })
        Aadd(aRes, { "x", '32', 'Valor do ICMS', 'N', '15', 'Não usado', '15', '2', '163 – 177', 'Nota 7', '176', '190' })
        Aadd(aRes, { "x", '33', 'Valor da Base do ICMS', 'N', '15', 'Não usado', '15', '2', '178 – 192', 'Nota 7', '191', '205' })
        Aadd(aRes, { " ", '34', 'Código do Importador', 'A', '4', 'Não usado', '4', '-', '193 – 196', '', '206', '209' })
        Aadd(aRes, { " ", '35', 'Código do Transportador', 'A', '20', 'Não usado', '20', '-', '197 – 216', '', '210', '229' })
        Aadd(aRes, { " ", '36', 'Valor do Seguro', 'N', '15', 'Não usado', '15', '2', '217 – 231', 'Nota 7', '230', '244' })
        Aadd(aRes, { "x", '37', 'Valor do IPI', 'N', '15', 'Não usado', '15', '2', '232 – 246', 'Nota 7', '245', '259' })
        Aadd(aRes, { "x", '38', 'Valor Total da Mercadoria', 'N', '15', 'Nota Fiscal - Valor mercadoria - f1_valmerc', '15', '2', '247 – 261', 'Nota 7', '260', '274' })
        Aadd(aRes, { "x", '39', 'Valor Total da Nota', 'N', '15', 'Nota Fiscal - Valor bruto - f1_valbrut', '15', '2', '262 – 276', 'Nota 7', '275', '289' })
        Aadd(aRes, { "x", '40', 'Valor Base do IPI', 'N', '15', 'Não usado', '15', '2', '277 – 291', 'Nota 7', '290', '304' })
        Aadd(aRes, { " ", '41', 'Filler', 'A', '2', 'Não usado', '2', '-', '292 – 293', '', '305', '306' })
        Aadd(aRes, { " ", '42', 'Código do Exportador', 'A', '4', 'Não usado', '4', '-', '294 – 297', '', '307', '310' })
        Aadd(aRes, { " ", '43', 'Nome do Exportador', 'A', '60', 'Não usado', '60', '-', '298 – 357', '', '311', '370' })
        Aadd(aRes, { " ", '44', 'Numero do PO', 'A', '17', 'Não usado', '30', '-', '358 – 374', '', '371', '400' })
        Aadd(aRes, { " ", '45', 'Perc. Redução de Base de ICMS', 'N', '6', '', '6', '2', '375 – 380', 'Nota 7', '401', '406' })
    
    ElseIf cNmTb = "Int_DspHe"
        Aadd(aRes, {'x', '01' , 'TIPO REGISTRO'   , 'C' , '2'  , '2'  ,                        'Tipo registro' , '0' , '001-002' , '' , '1' , '2' }) 
        Aadd(aRes, {'x', '02' , 'NR. DO PROCESSO' , 'C' , '18' , '30' , 'Embarque - Ref. Despach - w6_ref_des' , '0' , '003-020' , '' , '3' , '32' }) 
        Aadd(aRes, {'x', '03' , 'DATA DE CHEGADA' , 'C' , '8' , '8' , '' , '0' , '021-028' , '3' , '33' , '40' }) 
        Aadd(aRes, {' ', '04' , 'DATA DE RECEBIMENTO DE DOCUMENTOS' , 'C' , '8' , '8' , 'Vazio' , '0' , '029-036' , '' , '41' , '48' }) 
        Aadd(aRes, {'x', '05' , 'CÓDIGO DO DESPACHANTE' , 'C' , '3' , '3' , 'Embarque - Cod despach - w6_desp' , '0' , '037-039' , '2' , '49' , '51' }) 
        Aadd(aRes, {' ', '06' , 'CÓDIGO DO AGENTE' , 'C' , '3' , '3' , 'Vazio' , '0' , '040-042' , '2' , '52' , '54' }) // retirei em 20201029
        Aadd(aRes, {'x', '07' , 'DATA DE PAGAMENTOS DE IMPOSTOS' , 'C' , '8' , '8' , '' , '0' , '043-050' , '3' , '55' , '62' }) 
        Aadd(aRes, {'x', '08' , 'NÚMERO DE REGISTRO D.I.' , 'N' , '10' , '10' , '' , '0' , '051-060' , '' , '63' , '72' }) 
        Aadd(aRes, {'x', '09' , 'TAXA DE MERCADORIA' , 'N' , '15' , '15' , '' , '8' , '061-075' , '' , '73' , '87' }) 
        Aadd(aRes, {'x', '10' , 'DATA DO DESEMBARAÇO' , 'C' , '8' , '8' , '' , '' , '076-083' , '3' , '88' , '95' }) 
        Aadd(aRes, {'x', '11' , 'MOEDA DO FRETE' , 'C' , '3' , '3' , '' , '0' , '084-086' , '4' , '96' , '98' }) 
        Aadd(aRes, {' ', '12' , 'VALOR DO FRETE NA MOEDA' , 'N' , '15' , '15' , '' , '2' , '087-101' , '' , '99' , '113' }) 
        Aadd(aRes, {'x', '13' , 'TAXA DO FRETE' , 'N' , '15' , '15' , '' , '8' , '102-116' , '' , '114' , '128' }) 
        Aadd(aRes, {' ', '14' , 'VALOR DO SEGURO NA MOEDA' , 'N' , '15' , '15' , '' , '2' , '117-131' , '' , '129' , '143' }) 
        Aadd(aRes, {' ', '15' , 'MOEDA DO SEGURO' , 'C' , '3' , '3' , '' , '0' , '132-134' , '4' , '144' , '146' }) 
        Aadd(aRes, {' ', '16' , 'TAXA DO SEGURO' , 'N' , '15' , '15' , '' , '8' , '135-149' , '' , '147' , '161' }) 
        Aadd(aRes, {'x', '17' , 'TAXA DO DOLAR DA D.I.' , 'N' , '15' , '15' , '' , '8' , '150-164' , '' , '162' , '176' }) 
        Aadd(aRes, {'x', '18' , 'REFERÊNCIA DO DESPACHANTE' , 'C' , '15' , '15' , '' , '0' , '165-179' , '1' , '177' , '191' }) 
        Aadd(aRes, {' ', '19' , 'NÚMERO DE MASTER' , 'C' , '18' , '18' , '' , '0' , '180-197' , '' , '192' , '209' }) 
        Aadd(aRes, {'x', '20' , 'TIPO DA DECLARAÇÃO' , 'N' , '2' , '2' , '' , '0' , '198-199' , '4' , '210' , '211' }) 
        Aadd(aRes, {'x', '21' , 'URF DESPACHOS' , 'N' , '7' , '7' , '' , '0' , '200-206' , '4' , '212' , '218' }) 
        Aadd(aRes, {'x', '22' , 'URF ENTRADA' , 'N' , '7' , '7' , '' , '0' , '207-213' , '4' , '219' , '225' }) 
        Aadd(aRes, {'x', '23' , 'RECINTO ALFANDEGADO' , 'C' , '7' , '7' , '' , '0' , '214-220' , '4' , '226' , '232' }) 
        Aadd(aRes, {'x', '24' , 'MODALIDADE DESPACHO' , 'C' , '1' , '1' , '' , '0' , '221-221' , '' , '233' , '233' }) 
        Aadd(aRes, {'x', '25' , 'TIPO DO CONHECIMENTO' , 'C' , '2' , '2' , '' , '0' , '222-223' , '4' , '234' , '235' }) 
        Aadd(aRes, {'x', '26' , 'TIPO DO DOCUMENTO' , 'C' , '2' , '2' , '' , '0' , '224-225' , '4' , '236' , '237' }) 
        Aadd(aRes, {'x', '27' , 'UTILIZAÇÃO' , 'C' , '1' , '1' , '' , '0' , '226-226' , '4' , '238' , '238' }) 
        Aadd(aRes, {'x', '28' , 'NÚMERO DA IDENTIFICAÇÃO' , 'C' , '15' , '15' , '' , '0' , '227-241' , '' , '239' , '253' }) 
        Aadd(aRes, {'x', '29' , 'PESO BRUTO' , 'N' , '15' , '15' , '' , '4' , '242-256' , '' , '254' , '268' }) 
        Aadd(aRes, {'x', '30' , 'TOTAL FOB NA MOEDA' , 'N' , '15' , '15' , '' , '2' , '257-271' , '' , '269' , '283' }) 
        Aadd(aRes, {' ', '31' , 'NR. DA FATURA DE SERVIÇOS' , 'C' , '6' , '6' , '' , '0' , '272-277' , '' , '284' , '289' }) 
        Aadd(aRes, {' ', '32' , 'NR. DA NOTA FISCAL DE ENTRADA' , 'C' , '20' , '20' , '' , '0' , '278-297' , '' , '290' , '309' }) 
        Aadd(aRes, {' ', '33' , 'DATA DA NOTA FISCAL DE ENTRADA' , 'C' , '8' , '8' , '' , '0' , '298-305' , '3' , '310' , '317' }) 
        Aadd(aRes, {' ', '34' , 'VL TOTAL DA NOTA FISCAL ENTRADA' , 'N' , '15' , '15' , '' , '2' , '306-320' , '' , '318' , '332' }) 
        Aadd(aRes, {' ', '35' , 'DATA DE ENTREGA DA MERCADORIA' , 'C' , '8' , '8' , '' , '0' , '321-328' , '3' , '333' , '340' }) 
        Aadd(aRes, {'x', '36' , 'DATA DO REGISTRO DA DI' , 'D' , '8' , '8' , '' , '0' , '329-336' , '' , '341' , '348' }) 
        Aadd(aRes, {'x', '37' , 'VALOR DO FRETE COLLECTED' , 'N' , '15' , '15' , '' , '2' , '337-351' , '' , '349' , '363' }) 
        Aadd(aRes, {' ', '38' , 'VALOR FRETE TERRITORIO NACIONAL' , 'N' , '15' , '15' , '' , '2' , '352-366' , '' , '364' , '378' }) 
        Aadd(aRes, {' ', '39' , 'OBSERVAÇÕES' , 'C' , '250' , '250' , '' , '0' , '367-616' , '' , '379' , '628' }) 
        Aadd(aRes, {'x', '40' , 'LOCAL DO DESEMBARAÇO' , 'C' , '30' , '30' , '' , '0' , '617-646' , '' , '629' , '658' }) 
        Aadd(aRes, {'x', '41' , 'UF DO DESEMBARAÇO' , 'C' , '2' , '2' , '' , '0' , '647-648' , '' , '659' , '660' }) 

    ElseIf cNmTb = "Int_DspDe"
        Aadd(aRes, {'x', '1' , 'TIPO DO REGISTRO' , 'C' , '2' , 'Fixo' , '2' , '0' , '1' , '“DE.”' , '1' , '2' }) 
        Aadd(aRes, {'x', '2' , 'NR. DO PROCESSO' , 'C' , '18' , 'Embarque - Ref. Despach - w6_ref_des' , '30' , '0' , '3' , '1' , '3' , '32' }) 
        Aadd(aRes, {'x', '3' , 'DATA DO PAGAMENTO' , 'C' , '8' , 'Contas a pagar - E2_VENCTO' , '8' , '0' , '21' , '3' , '33' , '40' }) 
        Aadd(aRes, {'x', '4' , 'CÓDIGO DA DESPESA' , 'N' , '3' , 'despesa - yb_desp' , '3' , '0' , '29' , '2' , '41' , '43' }) 
        Aadd(aRes, {'x', '5' , 'VALOR DA DESPESA' , 'N' , '17' , 'contas a pagar - e2_valor' , '17' , '2' , '32' , '' , '44' , '60' }) 
        Aadd(aRes, {' ', '6' , 'EFETIVO OU PREVISTO' , 'C' , '1' , 'Fixo ' , '1' , '' , '49' , '5' , '61' , '61' }) 
        Aadd(aRes, {'x', '7' , 'DESPESA PAGA PELO DESPACHANTE OU IMPORTADOR' , 'C' , '1' , 'Fixo' , '1' , '' , '50' , '6' , '62' , '62' }) 
        Aadd(aRes, {'x', '8' , 'ADIANTAMENTO (S/N)' , 'C' , '1' , 'Fixo' , '1' , '' , '51' , '' , '63' , '63' }) 
        Aadd(aRes, {' ', '9' , 'FILLER' , 'C' , '277' , 'Vazio' , '277' , '0' , '52' , '' , '64' , '340' }) 

    ElseIf cNmTb = "Int_DspTx"
        Aadd(aRes, {'x', '1' , 'Tipo do Registro' , 'C' , '2' , '2' , '' , '0' , '001-002' , '' , '1' , '2' }) 
        Aadd(aRes, {'x', '2' , 'Numero do processo' , 'C' , '18' , '30' , '' , '0' , '003-020' , '' , '3' , '32' }) 
        Aadd(aRes, {'x', '3' , 'Moeda' , 'C' , '3' , '3' , '' , '0' , '021-020' , '' , '33' , '35' }) 
        Aadd(aRes, {'x', '4' , 'Taxa da moeda' , 'N' , '15' , '15' , '' , '8' , '024-038' , '' , '36' , '50' }) 
    EndIf

Return aRes

/*====================================================================================
Programa.:              zAjCpTb
Autor....:              CAOA - Valter Carvalho
Data.....:              14/01/2020
Descricao / Objetivo:   Efetua o ajuste das taxas no arquivo do despachante
Doc. Origem:
Solicitante:            
===================================================================================== */
Static Function zAjCpTb()
    Local nRecnoFD:=Int_FD->(RECNO())
    Local nId := 1

    Int_FD->(DbGoTop())
    While  Int_FD->(Eof()) = .F.
        RecLock("Int_FD", .F.)

        nId  := Ascan( aTaxas, {|aIt| aIt[1] == Alltrim(Int_FD->NFDCOD_I) })

        Int_FD->NFDIPITX  :=  aTaxas[nId, 3]
        Int_FD->NFDICMSTX :=  aTaxas[nId, 4]
        Int_FD->NFDIITX   :=  aTaxas[nId, 5]

        Int_FD->(MsUnlock())
        
        Int_FD->(DbSkip())
    EndDo

    Int_FD->(DBGOTO(nRecnoFD))
Return

/*====================================================================================
Programa.:              zs
Autor....:              CAOA - Valter Carvalho
Data.....:              14/01/2020
Descricao / Objetivo:   funcao auxiliar para pegar o somatorio de uma coluna
Doc. Origem:
Solicitante:            
=====================================================================================
Static function zs(ccampo)
    Local j,i := 1
    local nRes := 0
    
    For i:= 1 to Len(aItens)
        for j:= 1 to Len(aItens[i])
            If aItens[i, j, 1] = ccampo
                nRes += aItens[i, j, 2]
            EndIf
        Next
    Next
Return nRes

 */


Static Function zTrataMsgSer()
/*     Local cMsg := "Serie não cadastrada (tabela 01-SX5)"

    If cMsg == Alltrim(StrTran(cErro, char(13) + char(10), ""))
        cErro := Nil
    EndIf */
Return
