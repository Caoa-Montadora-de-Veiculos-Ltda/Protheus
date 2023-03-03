#Include 'TOPCONN.CH'
#Define CRLF CHAR(13) + CHAR(10)


/*=====================================================================================
Programa.:              ZEICF003
Autor....:              CAOA - Valter Carvalho
Data.....:              17/08/2020
Descricao / Objetivo:   Le uma planilha  e ajusta os dados Efetua ajustes no conteúdo das tabelas W3, W5, E W8
Solicitante:            Evandro Mariano
Uso......:              EICOR100          
===================================================================================== */
User Function  ZEICF003()
    Local aPergs    := {}
    Local aRetP     := {}
    Private bHawb   := {|| Iif(Vazio(Posicione("SW6", 1, Xfilial("SW6") + MV_PAR02, "W6_HAWB")) , ( MsgInfo(MV_PAR02 + " Hawb não existe.", ""), .F.), .T.) }
    Private aCampos := SetCampos()
    Private lUsuAlto:= .F.

    MostraMsg()

    aAdd(aPergs, {6, "Arquivo", Space(1024), "", "", "", 90, .F., "Planilha Excel|*.xlsx|Arquivo Excel 2003|*.xls", Strtran(GetTempPath(), "\AppData\Local\Temp\", "")})
    Aadd(aPergs, {1, "No Embarque:", Space(TamSX3("W7_HAWB")[1]) ,   "",   'Eval(bHawb)', "SW6", "", 90, .F.})

    lUsuAlto := u_zgenuser( RetCodUsr() ,"ZEICF003", .F.)
    If lUsuAlto = .T.
        Aadd(aPergs, {5, "Ajusta NCM ? ", .F., 90, "", .F.})
    Else
        Aadd( aPergs, {9, "Sem acesso p/ NCM (zgenuser)", 100, 20, .T.})
    EndIf

    Aadd(aPergs, {5, "Ajusta peso ?", .F., 90, "", .F.})

    Aadd(aPergs, {5, "Serie motor (se houver)?", .F., 90, .T., .F.})

    If 1 = 2
        Aadd(aPergs, {5, "Ajusta descricao ? ", .F., 90, "", .F.})
    Else
        // Aadd( aPergs, {9, "Sem acesso p/ descricao (zgenuser)", 100, 20, .T.})
        Aadd( aPergs, {9, ".", 100, 20, .T.})
    EndIf

    If ParamBox(aPergs, "Dados do embarque:", aRetP, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T., .T.) = .T.
    	Processa({|| zAtualizar() }, "[ZEICF003]", "Processando planilha" )
    EndIf

Return

/*=====================================================================================
Programa.:              MostraMsg
Autor....:              CAOA - Valter Carvalho
Data.....:              17/08/2020
Descricao / Objetivo:   Mensagem de orientação sobre a rotina
Solicitante:            Evandro Mariano
Uso......:              
===================================================================================== */
Static Function MostraMsg()
    Local cMsg := ""
    cMsg += CRLF + "  Essa rotina efetua atualização dos itens do embarque." + CRLF
    cMsg += CRLF + "  Para a correta importação, deve-se observar o seguinte:"
    cMsg += CRLF + " - O arquivo deve ser tipo XLSX ou XLS"
    cMsg += CRLF + " - A planilha lida será a PRIMEIRA da pasta"
    cMsg += CRLF + ' - Remover Quebra de linha, virgula, ponto e virgula e aspas simples/duplas '
    cMsg += CRLF + '   dos campos que têm informacao em texto (descricao, ncm, ex-ncm)                       
    cMsg += CRLF + ' - Remover das quantidades o separador de 1000'
    cMsg += CRLF + ' - Remover dos NCM pontos '
    cMsg += CRLF + ' - O campo peso total deve estar com 5 casas decimais.'
    cMsg += CRLF + " - O cabecalho deve estar na 1º linha e os itens iniciam na 2º linha"
    cMsg += CRLF + " - As colunas do cabecalho não podem ter nomes repetidos"
    cMsg += CRLF + " - Deixe nenhuma planilha oculta"
    cMsg += CRLF + " - Ordem dos campos: SEG, COD.P, COD.S,DESC.PORT, UNID DE MEDIDA,NCM, QUANT, PESO LIQ UN, PESO LIQ. TOTAL"

    ApMsgInfo(cMsg, FunName())
Return

/*===================================================================================
Programa.:              MostraMsg
Autor....:              CAOA - Valter Carvalho
Data.....:              17/08/2020
Descricao / Objetivo:   Efetua a logica do programa
Solicitante:            Evandro Mariano
Uso......:              
===================================================================================== */
Static Function zAtualizar()
    Local cAux      := ""
    Local nPosPrd   := 0
    Local i         := 1
    Local cW7Forn   := ""
    Local cW7Loj    := ""
    Local cW7Pgi    := ""
    lOCAL cW7Cc     := ""
    Local cw7Po     := ""
    Local cW7Si     := ""
    Local cHawb     := MV_PAR02
    Local cCodProd  := ""
    Local aIt       := u_XlsxToArr(Alltrim(MV_PAR01), "1")
    Local cPesq     := ""
    Local aNCM      := {"",""}
    Local aPesoU    := {"",""}
    Local aPesoT    := {"",""}
    Local aDscCp    := {"",""}
    Local aDesc     := {"",""}
    Local aAux      := {}
    Local aPrd      := GetItHawb(cHawb)  // produtos do embarque
    Local aCps      := ""
    Local nLinIni   := 2
    Local aRecW5    := {{"",-1}}
    Local aRecW7    := {{"",-1}}
    Local aRecW8    := {{"",-1}}
    Private aErr    := {}

    ProcRegua(Len(aIt))

    If Empty(aIt)
        ApMsgInfo("Importação cancelada ou arquivo vazio", FunName())
        Return
    EndIf

    For i:= nLinIni to Len(aIt)

        // cada linha tem que ter 9 colunas
        If Len(aIt[i]) < 9
            Loop
        Endif

        If Empty(Upper(aIt[i, GetCp("codp")]))
            Loop
        EndIf    

        nPosPrd := aScan(aAux, {|aIta|  aIta[1] == Upper(aIt[i, GetCp("codp")])})

    Next

    DbSelectArea("SW7")
    DbSetOrder(1)

    DbSelectArea("SB1")
    DbSetOrder(1)

    For i:= nLinIni to Len(aIt)

        IncProc( cValToChar(i) + " de " + cValToChar(Len(aIt))  )

        If Len(aIt[i]) <  aCampos[Len(aCampos), 3]
            Aadd(aErr, " - Linha " + cValToChar(i) + " ERRO, quant campos linha: " + cValToChar(Len(aIt[i])) + " esperado " + cValToChar(aCampos[Len(aCampos), 3]) )
            Loop
        EndIf

        // Pegar o codigo do Forn e o numero Pgi
        If SW7->(DbSeek( Xfilial("SW7") + cHawb))
            cW7Forn := SW7->W7_FORN
            cW7Loj  := SW7->W7_FORLOJ
            cW7Pgi  := SW7->W7_PGI_NUM
            cW7Cc   := SW7->W7_CC
            cW7Po   := SW7->W7_PO_NUM
            cW7Si   := SW7->W7_SI_NUM
        Else
            Aadd(aErr, " - Linha " + cValToChar(i) + ", Erro: Hawb não encontrado: " + cHawb)
            Loop
        EndIf

        // PEGAR O CODIGO DO PRODUTO
        If Empty(aIt[i, GetCp("codp")]) = .T.
            Loop
        EndIf
        cCodProd :=  (Posicione("SA5", 14, Xfilial("SA5") + cW7Forn + cW7Loj + Upper(aIt[i, GetCp("codp")]), "A5_PRODUTO"))
        If Empty(cCodProd) = .T.
            Aadd(aErr, " - Linha " + cValToChar(i) + ", ERRO: Produto x Fornecedor está incoerente: " + aIt[i, GetCp("codp")]   )
            Loop
        EndIf

        If Empty(Posicione("SYD",1, Xfilial("SYD") + xSohNum(aIt[i, GetCp("ncm")]), "YD_TEC") ) = .T.
            Aadd(aErr, " Linha " + cValToChar(i) + " AVISO: NCM não existe no cadastro NCM: " + aIt[i, GetCp("ncm")]   )
        EndIf

        If Val(aIt[i, GetCp("Tpeso")]) = 0
            Aadd(aErr, " - Linha " + cValToChar(i) + " Erro: Peso do produto zerado ")
            Loop
        EndIf

        // Remover do array dos produtos faltantes
        nPosPrd := aScan(aPrd, cCodProd)
        If  (nPosPrd > 0) .AND. nPosPrd <= Len(aPrd)
            Adel(aPrd, aScan(aPrd, cCodProd))
            Asize(aPrd,  Len(aPrd)-1)
        EndIf

        aNCM[1] := "" 
        If ValType(MV_PAR03) == "L" 
            If MV_PAR03 = .T.
                aNCM[1] := Alltrim(aIt[i, GetCp("ncm")])
            EndIf                
        EndIf

        If MV_PAR04 = .T. 
            aPesoT[1] := Val(aIt[i, GetCp("Tpeso")])
            aPesoT[1] := NoRound(aPesoT[1], 5)

            aPesoU[1] := aPesoT[1] / Val(aIt[i, GetCp("qt")])
        EndIf    

        // pegar descricao complementar - numero de serie -
        If ( MV_PAR05 = .T.)
            aDscCp[1] := Alltrim(aIt[i, GetCp("cdsComp")])
        Else
            aDscCp[1] := ""
        EndIf    

        // SW5
        aPesoU[2]   := "W5_PESO"
        aCps        := {aPesoU}
        zAtuW578(i, "SW5", cHawb, cCodProd, aCps, Upper(aIt[i, GetCp("codp")]), @aRecW5)

        // SW7
        aPesoU[2]   := "W7_PESO"
        aDscCp[2]   := "W7_XDSCOMP"
        aCps        := {aPesoU, aDscCp}
        zAtuW578(i, "SW7", cHawb, cCodProd, aCps, Upper(aIt[i, GetCp("codp")]), @aRecW7)

        // SW8
        aPesoU[2]    := "W8_PESO_BR"
        aCps        := {aPesoU}
        zAtuW578(i, "SW8", cHawb, cCodProd, aCps, Upper(aIt[i, GetCp("codp")]), @aRecW8)

        // atualize o peso , rateando
        If MV_PAR04 = .T. 
            cAux := zRatPeso( cHawb, cW7Pgi, cW7Cc, cW7Si, cCodProd, aPesoT, Val(aIt[i, GetCp("qt")]) )
            If Vazio(cAux) = .F.
                Aadd(aErr, " - Linha " + cValToChar(i) + cAux)
            EndIf
        EndIf            

        If ValType(MV_PAR06) == "L" 
            If MV_PAR06 = .T.
                aDesc[1] := aIt[i, GetCp("desc")]
                aDesc[1] := Strtran(aDesc[1], char(13), " ")
                aDesc[1] := Strtran(aDesc[1], char(10), " ")

                If SB1->(DbSeek(Xfilial("SB1") + cCodProd)) = .T.
                    Msmm(,TamSx3("B1_VM_GI")[1],, aDesc[1], 1, 100, .T.,"SB1","B1_DESC_GI")  //descrição Li
                Else
                    Aadd(aErr, " - Linha " + cValToChar(i) + " Erro: Nao achei o produto no cadastro de produto SB1")
                EndIf            
            EndIf
        EndIf            

    Next

    // Os produtos que sobraram no array aPrd nao estão na planilha
    Aeval( aPrd, {|cPrd| Aadd(aErr, " - Erro: Produto do embarque não consta na planilha: " + Alltrim(cPrd) + " Descrição:" + Posicione("SB1", 1, Xfilial("SB1") + cPrd, "B1_DESC") )})

    If Len(aErr) > 0
        cPesq := "Validacao do processo: " + cHawb + CHAR(13) + CHAR(10)
        cPesq += "Arquivo:" + Alltrim(MV_PAR01)  + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
        
        Aeval(aErr, {|x|  cPesq += x + CHAR(13) + CHAR(10)   } )
        
        EecView(cPesq, "Problemas encontrados na rotina:")
    Else
        ApMsgInfo("Não foram encontradas ocorrências na importação dos dados da planilha." + CRLF + "Arquivo:" + Alltrim(MV_PAR01) , FunName())
    EndIf

Return

/*
Ratear os pesos dos produtos na W7
*/
Static Function zRatPeso(cHawb, cW7Pgi, cW7Cc, cW7Si, cCod, aPsT, nQtTot)
    Local cTb      := GetNextAlias()
    Local cmd      := ""
    Local nResiduo := aPsT[1]
   
    cmd += CRLF + " SELECT R_E_C_N_O_ AS RECNO FROM  " + RetSqlName("SW7")
    cmd += CRLF + " WHERE "
    cmd += CRLF + "      D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND W7_FILIAL = '" + Xfilial("SW7") + "' "    
    cmd += CRLF + " AND W7_HAWB  = '" + cHawb + "' "
    cmd += CRLF + " AND W7_COD_I = '" + cCod  + "' " 

    TcQuery cmd new alias (cTb)

    DbSelectArea("SW7")
    SW7->(DbSetOrder(1))

    If Vazio((cTb)->RECNO) = .T.
        (cTb)->(DbCloseArea())
        Return " - Nao encontrado o item na SW7 para ratear o peso " + cCod
    EndIf

    While (cTb)->(Eof()) = .F.
        SW7->(DbGoTo((cTb)->RECNO))

        RecLock("SW7", .F. )

        SW7->W7_XPESOD :=  NoRound(SW7->W7_QTDE * SW7->W7_PESO, 5)

        SW7->(MsUnLock())

        nRecNo := SW7->(RecNo())
        nResiduo := nResiduo - SW7->W7_XPESOD

        (cTb)->(DbSkip())
    EndDo 

    // aplicar o residuo do rateio
    If nResiduo > 0
        RecLock("SW7", .F. )
        SW7->W7_XPESOD :=  SW7->W7_XPESOD + nResiduo
        SW7->(MsUnLock())
    EndIF

    (cTb)->(DbCloseArea())

Return ""


/*=====================================================================================
Programa.:              MostraMsg
Autor....:              CAOA - Valter Carvalho
Data.....:              17/08/2020
Descricao / Objetivo:   Atualiza as tabelas
Solicitante:            Evandro Mariano
Uso......:              
===================================================================================== */
Static Function zAtuW578(i, cTb, cHawb, cProd, aCps, cProdPlan, aRecWx)
    Local idx   := 1
    Local j     := 1
    Local cAux  := Substr(cTb, 3, 1)
    Local cmd   := ""
    Local aRecNo:= {}
    Local cQr   := GetNextAlias() 
    Local cCampo := ""
    Local xValor := Nil

    cmd += CRLF + " SELECT R_E_C_N_O_ AS RECNO "
    cmd += CRLF + " FROM " + RetSqlName(cTb) 
    cmd += CRLF + " WHERE 
    cmd += CRLF + "     D_E_L_E_T_ = ' ' 
    cmd += CRLF + " AND W" + cAux + "_FILIAL  = '" + cFilAnt  + "' "
    cmd += CRLF + " AND W" + cAux + "_HAWB    = '" + cHawb    + "' "
    cmd += CRLF + " AND W" + cAux + "_COD_I   = '" + cProd    + "' "
    cmd += CRLF + " AND ROWNUM <= 1"
    cmd += CRLF + " AND R_E_C_N_O_ NOT IN (" + zGetRecno(cProd, aRecWx) + ")"

    TcQuery cmd new alias (cQr)

    (cQr)->(DbEval( {|| Aadd(aRecNo, (cQr)->RECNO), Aadd(aRecWx, { cProd, (cQr)->RECNO} ) }, {|| .T. } ))        

    If Len(aRecNo) = 0
        (cQr)->(DbCloseArea())
        Aadd(aErr, " - Linha " + cValToChar(i) + " - Erro: Produto " + Alltrim(cProdPlan) + "(" + Alltrim(cProd) + ") não encontrado na Tabela " + cTb + "-" + Posicione("SX2", 1, cTb, "X2_NOME" ) )
        Return
    EndIf

    For idx := 1 to Len(aRecNo)

        For j:=1 to Len(aCps)
            
            if Empty(aCps[j, 1]) = .T.
                Loop
            EndIf
            cCampo := aCps[j, 2]
            xValor := aCps[j, 1]


            If TamSx3(cCampo)[3] == "N"
                xValor := cValToChar(aCps[j,1])
            Else     
                xValor := " '" + aCps[j,1] + "' "
            EndIf

            cmd := " UPDATE " + RetSqlname(cTb) + " SET " + cCampo + " = " + xValor
            cmd += " WHERE R_E_C_N_O_ = " + cValToChar(aRecno[idx])

            if TCSqlExec( cmd ) < 0 
                Alert("Erro de execucao:" + TCSQLError() )
            EndIf                
        Next
    Next

    (cQr)->(DbCloseArea())
Return

/*=====================================================================================
Programa.:              MostraMsg
Autor....:              CAOA - Valter Carvalho
Data.....:              17/08/2020
Descricao / Objetivo:   Inicia  o array acampos
Solicitante:            Evandro Mariano
Uso......:              
===================================================================================== */
Static Function SetCampos()
    Local aRes := {}
    Aadd(aRes, {"codp",   "Fornecedor",      02})
    Aadd(aRes, {"desc",   "Loja forn",       04})
    Aadd(aRes, {"ncm",    "NCM",             06})
    Aadd(aRes, {"qt",     "Quantidade",      07})
    Aadd(aRes, {"Upeso",  "Peso unitario)",  08})
    Aadd(aRes, {"Tpeso",  "Peso unitario)",  09})
    Aadd(aRes, {"cdsComp","numero deserie)", 22})
Return aRes


/*=====================================================================================
Programa.:              GetCp
Autor....:              CAOA - Valter Carvalho
Data.....:              17/08/2020
Descricao / Objetivo:   Retorna o id do array 
Solicitante:            Evandro Mariano
Uso......:              
===================================================================================== */
Static Function GetCp(cCampo)
    Local oVal  := Nil
    Local oHash := Nil

    oHash := AToHM( aCampos )

    HMGet(oHash, cCampo, oVal)
Return oVal[1,3]


/*=====================================================================================
Programa.:              GetItHawb
Autor....:              CAOA - Valter Carvalho
Data.....:              17/08/2020
Descricao / Objetivo:   Retorna a lista de itens do embarque
Solicitante:            Evandro Mariano
Uso......:              
===================================================================================== */
Static Function GetItHawb(cHawb)
    Local aRes := {}
    DbSelectArea("SW7")
    DbSetOrder(1)

    SW7->(DbSeek(Xfilial("SW7") + cHawb ))
    While Xfilial("SW7") + W7_HAWB == Xfilial("SW7") + cHawb
        Aadd(aRes, SW7->W7_COD_I)
        SW7->(DbSkip())
    EndDo
    SW7->(DbCloseArea())
Return aRes


Static Function xSohNum(cValor)
    Local cNums := "0123456789"
    Local i     := 1
    Local cRes  := ""
    
    For i:=1 to Len(cValor)
        If (Substr(cValor,i,1) $ cNums) = .T.
            cRes += Substr(cValor,i,1)
        EndIf
    Next
Return cRes

Static Function zGetRecno(cCod, aRecno)
    Local i := 0
    Private cRes := ""

    For I := 1 to Len(aRecno)
        if aRecno[i,1] ==  "" .or. aRecno[i,1] == cCod
            cRes += cValToChar(aRecno[i, 2]) + ","
        EndIf
    next

    cRes := Substr(cRes, 1, Len(cRes)-1 )

Return cRes


/* 
Sub RemoveCarriageReturns()
    Dim MyRange As Range
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
 
   For Each MyRange In Selection


        MyRange = Replace(MyRange, Chr(10), " ")

        MyRange = Replace(MyRange, Chr(13), " ")

        ' aspas duplas
        MyRange = Replace(MyRange, Chr(34), " ")

        ' aspas simples
        MyRange = Replace(MyRange, Chr(39), " ")

        ' virgula
        MyRange = Replace(MyRange, ",", " ")

        ' ponto e virgula
        MyRange = Replace(MyRange, ";", " ")
    Next
 
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
End Sub
 */
