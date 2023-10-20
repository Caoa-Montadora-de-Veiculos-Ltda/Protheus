#Include "TopConn.ch"
#DEFINE CRLF  Char(13) + Char(10)

/* =====================================================================================
Programa.:              ZEICF018
Autor....:              CAOA - Valter Carvalho
Data.....:              15/11/2021
Descricao / Objetivo:   Efetua a classificação das notas filhas do EIC

Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              EICDI154, ZEICF015
===================================================================================== */

User Function ZEICF018()
   
   Local _cEmp    := FWCodEmp()
   
   If _cEmp == "2010" //Executa o p.e. Anapolis.
     zMontadora()
   Else
     zCaoaSp() //Executa o p.e. Barueri
   EndIf

Return()

/* =====================================================================================
Programa.:              zMontadora
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Função usada na Montadora
===================================================================================== */
Static Function zMontadora()
    Local cTpImp     := ""
    Local aPergs     := {}
    Local aRetP      := {}
    Private bHawb    := {|| Iif(Vazio(GetAdvFVal("SW6", "W6_HAWB", FwXFilial("SF1") + MV_PAR01, 1, " ")) , ( FWAlertError(Alltrim(MV_PAR01) + " Embarque não existe.", ""), .F.), .T.) }
    Private cTpQuebra:= 0
    Private aOpcQuebra := {"1-Quebra por item (99 itens)", "2-Quebra por container (Mães)", "3-Quebra por chassi (CBU)", "4-Quebra por container (Filhas)"}
    Private cTes     := Space(TamSx3("F4_CODIGO")[1])
    Private cHawb    := Space(TamSx3("W6_HAWB")[1])
    Private nBloqMov := ""
    Private cErr     := ""
    Private nErros   := 0

    Aadd(aPergs, {1, "No Embarque:" , Space(TamSX3("W7_HAWB")[1]) , "", 'Eval(bHawb)', "SW6", "", 100, .F.})
    Aadd(aPergs, {2, "Tipo de quebra: ", 1, aOpcQuebra, 120, ".T.", .T.})

    Pergunte( 'MTA103    ', .F. ) 

    If Vazio(MV_PAR17) = .T.
        FWAlertError("Confirme antes o valor do bloqueio na tela de parâmetros, (F12)", "ZEICF018")
        Return
    EndIF

    nBloqMov := MV_PAR17

    If ParamBox(aPergs, "Dados do embarque:", aRetP, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T., .T.) = .F.
        Return
    EndIf

    If ValType(MV_PAR02) == "N"
        cTpQuebra := "1"
    Else
        cTpQuebra := SubStr(MV_PAR02, 1, 1)
    EndIf

    cHawb     := MV_PAR01

    //cTes      := GetAdvFVal("SW6", "W6_XTESPRO", FwXFilial("SW6") + aRetP[1] , 1,  Space(TamSx3("F4_CODIGO")[1]) )

    If Empty(cTpQuebra) = .T. .OR. Empty(cTes) = .T.
        cTes := GetAdvFVal("SW6", "W6_XTESPRO", FwXFilial("SF1") + MV_PAR01, 1, "")
        If Empty(cTes) = .T.
            zCmvFun04()
        EndIf    
    EndIf

    If cTpQuebra == "2" .AND. nBloqMov = 1
        FWAlertError("Para notas mães quebrando por container, usar o parâmetro 'Bloqueio movimento = NAO (F12)' ", "ZEICF018")
        Return
    EndIf

    If cTpQuebra <> "4"

		cTpImp := GetAdvFVal("SW6", "W6_XTIPIMP", FwXFilial("SW6") + aRetP[1] , 1, " ")
        cTpImp := GetAdvFVal("ZZ8", "ZZ8_TIPO", FwxFilial("ZZ8") + cTpImp, 1, " ")
        
        zCmvFun01()

    Else 
        zCmvFun03()
    EndIf    

    if Vazio(cErr) = .F.
          FWAlertError("Nao foi possivel classificar todas as notas, verifique os erros: " + cErr, "ZEICF018")
    Else
        FWAlertSuccess("Processo finalizado!", "ZEICF018")
    EndIf

Return

/* =====================================================================================
Programa.:              zCmvFun01
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Função usada na Montadora
===================================================================================== */
Static Function zCmvFun01()
    Local lOk       := .T.       
    Local aDocs     := u_ZEICF016(cHawb, "MAE") // {F1_DOC, F1_SERIE, F1_STATUS, F1_FORNECE, F1_LOJA })
    Local aDocPend  := {}
    Local i         := 1
    Private msg     := ""

    If cTpQuebra = "1"

        For i:= 1 to Len(aDocs)
            If nBloqMov = 1 .AND. Vazio(aDocs[i,3]) = .T.
                Aadd(aDocPend, aDocs[i])
           //  ElseIf nBloqMov = 2 .AND. (aDocs[i,3] == "C" .OR.  Empty(aDocs[i,3]) )
            ElseIf nBloqMov = 2 .AND. aDocs[i,3] == "C"
                Aadd(aDocPend, aDocs[i])
            Endif
        Next

    Elseif cTpQuebra = "2"

        For i:= 1 to Len(aDocs)
            If (nBloqMov = 2 .AND. Vazio(aDocs[i,3]) = .T.) 
                Aadd(aDocPend, aDocs[i])
            Endif
        Next

    Elseif cTpQuebra = "3"

        For i:= 1 to Len(aDocs)
            If Empty(aDocs[i,3]) = .T. .OR. aDocs[i,3] = "C"
                Aadd(aDocPend, aDocs[i])
            Endif
        Next

    Endif    

    If Len(aDocPend) = 0
        FWAlertError("Não exitem notas pendentes de classificação nesse processo: " + cHawb, "ZEICF018")
        Return
    EndIf

    msg += CRLF + "Tipo Quebra: " + aOpcQuebra[Val(cTpQuebra)]
    msg += CRLF + "Bloqueio estoque: " + Iif(nBloqMov =1, "Sim", "Não")
    Aeval(aDocPend, {|x| msg += CRLF + Alltrim(x[2]) + " / " + Alltrim(x[1])  })
    If FWAlertYesNo("Deseja classificar as notas do processo: " + Alltrim(cHawb) + " ?" + msg, "ZEICF018") = .F.
        Return
    EndIf          

    If zCmvFun02() = .F.
        Return
    EndIf        

    For i := 1 to Len(aDocPend)
	    FWMsgRun(, {|| lOk := zCmvFun05(aDocPend[i]) },"", "Classificando NF: " + PadL(i, 3, '0') + " de " + PadL(Len(aDocPend), 3, '0') + " " + aDocPend[i, 1] )
        if lOk =  .F.
            cErr += CRLF + " -" + Alltrim(aDocPend[i, 2]) + "/" + Alltrim(aDocPend[i, 1])
            nErros += 1
        EndIf
    Next

Return cErr

/* =====================================================================================
Programa.:              zCmvFun02
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Função usada na Montadora
===================================================================================== */
Static Function  zCmvFun02()
    Local lRes := .T.
    Local aw6 := SW6->(GetArea())

    DbSelectArea("SW6")
    DbSetOrder(1)

    If SW6->(Dbseek(FwXfilial("SW6") + cHawb)) = .T.
        RecLock("SW6", .F.)
            SW6->W6_XQBREIC := cTpQuebra
            SW6->W6_XTESPRO := cTes
        SW6->(MsUnlock())
    Else
        FWAlertError("Não foi possivel efetuar a atualização do cabeçalho do desembarque, (W6_XQBREIC)", "ZEICF018")
        lRes := .F.
    EndIf
    RestArea(aw6)
Return lRes


/* =====================================================================================
Programa.:              zCmvFun03
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Função usada na Montadora
===================================================================================== */
Static Function zCmvFun03()
    Local lOk      := .T.
    Local aDocs     := u_ZEICF016(cHawb, "FILHA") // {F1_DOC, F1_SERIE, F1_STATUS, F1_FORNECE, F1_LOJA })
    Local aDocPend  := {}
    Local i         := 1
    Local cmd       := ""
    //Local aPergs    := {}
    Private msg     := ""

    If Vazio(aDocs) = .T.
        FWAlertError("Processo " + Alltrim(cHawb) + " não gerou notas filhas: " + Alltrim(cHawb), "ZEICF018")
        Return
    EndIf

    For i:= 1 to Len(aDocs)
        If (aDocs[i,3] = " " .AND. nBloqMov = 1) .OR. (aDocs[i,3] = "C" .AND. nBloqMov = 2)
            Aadd(aDocPend, aDocs[i])
        Endif
    Next

    If Len(aDocPend) = 0
        FWAlertError("Não exitem notas filhas para desbloquear nesse processo." + Alltrim(cHawb), "ZEICF018")
        Return
    EndIf

    msg += CRLF + "Tipo Quebra: " + aOpcQuebra[Val(cTpQuebra)]
    msg += CRLF + "Bloqueio estoque: " + Iif(nBloqMov =1, "Sim", "Não")
    Aeval(aDocPend, {|x| msg += CRLF + Alltrim(x[2]) + " / " + Alltrim(x[1])  })
    If FWAlertYesNo("Deseja classificar notas filhas do processo: " + Alltrim(cHawb) + " ?" + msg, "ZEICF018") = .F.
        Return
    EndIf          
    
    nBloqMov := MV_PAR17
    
    if nBloqMov == 1
        zCmvFun04()
    Else
        cTes := " " 
    EndIf
    //cTes := "336"

    For i := 1 to Len(aDocPend)

        If nBloqMov = 2
            // efetua o ajuste do tipo do doc para N novamente
            cmd := CRLF + " UPDATE " + RetSqlName("SF1") + " SET F1_TIPO = 'N' 
            cmd += CRLF + " WHERE D_E_L_E_T_ = ' ' "
            cmd += CRLF + " AND F1_FILIAL  = '" + FwxFilial("SF1") + "' "
            cmd += CRLF + " AND F1_DOC     = '" + aDocPend[i, 1]   + "' "
            cmd += CRLF + " AND F1_SERIE   = '" + aDocPend[i, 2]   + "' "
            cmd += CRLF + " AND F1_FORNECE = '" + aDocPend[i, 4]   + "' "
            cmd += CRLF + " AND F1_LOJA    = '" + aDocPend[i, 5]   + "' "
            TCsqLeXEC(cmd)

            cmd := CRLF + " UPDATE " + RetSqlName("SD1") + " SET D1_TIPO = 'N' 
            cmd += CRLF + " WHERE D_E_L_E_T_ = ' ' "
            cmd += CRLF + " AND D1_FILIAL  = '" + FwxFilial("SD1") + "' "
            cmd += CRLF + " AND D1_DOC     = '" + aDocPend[i, 1]   + "' "
            cmd += CRLF + " AND D1_SERIE   = '" + aDocPend[i, 2]   + "' "
            cmd += CRLF + " AND D1_FORNECE = '" + aDocPend[i, 4]   + "' "
            cmd += CRLF + " AND D1_LOJA    = '" + aDocPend[i, 5]   + "' "
            TCsqLeXEC(cmd)
        Endif            

	    FWMsgRun(, {|| lOk := zCmvFun05(aDocPend[i]) }, "", " Classificar notas filhas: " + PadL(i, 3, '0') + " de " + PadL(Len(aDocPend), 3, '0') + " " + aDocPend[i, 1] )
        if lOk := .F.
            cErr += CRLF + " -" + Alltrim(aDocPend[i, 2]) + "/" + Alltrim(aDocPend[i, 1])
            nErros += 1
        EndIf
    Next

Return 


/* =====================================================================================
Programa.:              zCmvFun04
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Função usada na Montadora
===================================================================================== */
Static Function zCmvFun04()
    Local lOk      := .f.
    Local aPergs   := {}
    Local aRt      := {}
    Private bTes   := {|| Iif(Vazio(Posicione("SF4", 1, Xfilial("SF4") + MV_PAR01, "F4_CODIGO")) , ( FwAlertError(MV_PAR01 + " TES não existe.", "ZEICF018"), .F.), .T.) }

    Aadd(aPergs,  {1, "TES", cTes, "@!", 'Eval(bTes)', "SF4", "", 30, .T.})

    While lOk = .F.
        lOk := ParamBox(aPergs, "Informar a TES a ser usada", aRt)
    EndDo        

    cTes := MV_PAR01

Return 

/* =====================================================================================
Programa.:              zCmvFun05
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Função usada na Montadora
===================================================================================== */
Static Function zCmvFun05(aDocPend)
    Local cDoc      := aDocPend[1]  
    Local cSerie    := aDocPend[2]  
    Local cForn     := aDocPend[4]  
    Local cLoja     := aDocPend[5] 
    Local cmd   := ""
    Local lRes  := .T.
    Local cQr   := GetNextAlias()
    Local aCab  := {}
    Local aLn   := {}
    Local aItens:= {}
    Local aSF1  := SF1->(GetArea())
    Local aRecSB2 := {}
    Local nCount := 0 
    Private lMsErroAuto := .F.

    DbSelectArea("SF1")
    DbSetOrder(1)
    If SF1->(DbSeek(Xfilial("SF1") + cDoc + cSerie + cForn + cLoja)) = .F.
        FWAlertError("Nao consegui posicionar na nota fiscal: " + cDoc + "Serie:" + cSerie, "ZEICF018")
        Return .F.
    EndIf

    cmd := " SELECT SD1.*, SB2.R_E_C_N_O_ AS RECSB2 " 
    cmd += " FROM " + RetSqlName("SD1") + " SD1"
    cmd += " LEFT JOIN " + RetSqlName("SB2") + " SB2 "
    cmd += "    ON B2_FILIAL = '" + FWxFilial("SB2") + "' "
    cmd += "    AND B2_COD = D1_COD "
    cmd += "    AND B2_LOCAL = D1_LOCAL "
    cmd += "    AND SB2.D_E_L_E_T_ = ' ' "
    cmd += " WHERE D1_FILIAL = '" + FWxFilial("SD1") + "' "
    cmd += "      AND D1_DOC = '" + SF1->F1_DOC     + "' "
    cmd += "      AND D1_SERIE = '" + SF1->F1_SERIE   + "' " 
    cmd += "      AND D1_FORNECE = '" + SF1->F1_FORNECE + "' "
    cmd += "      AND D1_LOJA = '" + SF1->F1_LOJA    + "' " 
    cmd += "      AND SD1.D_E_L_E_T_ = ' ' " 
    cmd += " ORDER BY D1_ITEM " 
    
    TcQuery cmd new Alias (cQr)

	Aadd(aCab,{"F1_TIPO"    , SF1->F1_TIPO      , NIL })
	Aadd(aCab,{"F1_FORMUL"  , SF1->F1_FORMUL    , NIL })
	Aadd(aCab,{"F1_DOC"     , SF1->F1_DOC       , NIL })
	Aadd(aCab,{"F1_SERIE"   , SF1->F1_SERIE     , NIL })
	Aadd(aCab,{"F1_EMISSAO" , SF1->F1_EMISSAO   , NIL })
	Aadd(aCab,{"F1_DTDIGIT" , SF1->F1_DTDIGIT   , NIL })
	Aadd(aCab,{"F1_FORNECE" , SF1->F1_FORNECE   , NIL })
	Aadd(aCab,{"F1_LOJA"    , SF1->F1_LOJA      , NIL })
	Aadd(aCab,{"F1_ESPECIE" , SF1->F1_ESPECIE   , NIL })
	Aadd(aCab,{"F1_COND"    , "001"             , NIL })
	Aadd(aCab,{"F1_DESPESA" , SF1->F1_DESPESA   , NIL })
	Aadd(aCab,{"F1_DESCONT" , SF1->F1_DESCONT   , NIL })
	Aadd(aCab,{"F1_FRETE"   , 0                 , NIL })
	Aadd(aCab,{"F1_MOEDA"   , SF1->F1_MOEDA     , NIL })
	Aadd(aCab,{"F1_TXMOEDA" , SF1->F1_TXMOEDA   , NIL })
	Aadd(aCab,{"F1_STATUS"  , SF1->F1_STATUS    , NIL })
	Aadd(aCab,{"F1_XQBREIC" , cTpQuebra         , NIL })

    While (cQr)->(Eof()) = .F.
        aLn := {}
        Aadd(aLn,{"D1_ITEM"  , (cQr)->D1_ITEM   , NIL })
        Aadd(aLn,{"D1_COD"   , (cQr)->D1_COD    , NIL })
        Aadd(aLn,{"D1_UM"    , (cQr)->D1_UM     , NIL })
        
        if cTpQuebra $ "1|2|3" 
            Aadd(aLn,{"D1_PEDIDO" , (cQr)->D1_PEDIDO     , ".T."})
            Aadd(aLn,{"D1_ITEMPC" , (cQr)->D1_ITEMPC     , ".T. "})
        endif            

        Aadd(aLn,{"D1_QUANT" , (cQr)->D1_QUANT  , NIL })
        Aadd(aLn,{"D1_VUNIT" , (cQr)->D1_VUNIT  , NIL })
        Aadd(aLn,{"D1_TOTAL" , (cQr)->D1_TOTAL  , NIL })        
        
        If (nBloqMov = 1 .AND. cTpQuebra $ "1|3|4") .OR. (nBloqMov = 2 .AND. cTpQuebra $ "2|3" )
            if Empty(cTes) 
                cTes := (cQr)->D1_TESACLA
            endif
            Aadd(aLn,{"D1_TES" , cTes           , NIL })

        EndIf    

        If nBloqMov = 2
            Aadd(aLn,{"D1_LOCAL"  , GetAdvFVal("SB1", "B1_LOCREC",  FwXFilial("SB1") + (cQr)->D1_COD, 1, "907")        , NIL })
            Aadd(aLn,{"D1_ENDER"  , GetAdvFVal("SB5", "B5_ENDENT",  FwXFilial("SB5") + (cQr)->D1_COD, 1, "DCE01")      , NIL })
            Aadd(aLn,{"D1_SERVIC" , GetAdvFVal("SB5", "B5_SERVENT", FwXFilial("SB5") + (cQr)->D1_COD, 1, "101")        , NIL })            
        EndIf

        Aadd(aLn,{"D1_TEC"    , (cQr)->D1_TEC       , NIL })
      
        If (cTpQuebra = "4" )
            Aadd(aLn,{"D1_CONHEC" , cHawb           , NIL })
        Else 
            Aadd(aLn,{"D1_CONHEC" , (cQr)->D1_CONHEC    , NIL })
        EndIf

        //If cTpQuebra <> "3"
            Aadd(aLn,{"D1_BASEIPI", (cQr)->D1_BASEIPI   , NIL }) 
            Aadd(aLn,{"D1_IPI"    , (cQr)->D1_IPI       , NIL })
            Aadd(aLn,{"D1_VALIPI" , (cQr)->D1_VALIPI    , NIL })

            Aadd(aLn,{"D1_ALIQII" , (cQr)->D1_ALIQII    , NIL })
            Aadd(aLn,{"D1_II"     , (cQr)->D1_II        , NIL })

            Aadd(aLn,{"D1_BASEICM", (cQr)->D1_BASEICM   , NIL })
            Aadd(aLn,{"D1_PICM"   , (cQr)->D1_PICM      , NIL })
            Aadd(aLn,{"D1_VALICM" , (cQr)->D1_VALICM    , NIL })

            Aadd(aLn,{"D1_BASIMP5", (cQr)->D1_BASIMP5   , NIL })
            Aadd(aLn,{"D1_ALQIMP5", (cQr)->D1_ALQIMP5   , NIL })
            Aadd(aLn,{"D1_VALIMP5", (cQr)->D1_VALIMP5   , NIL })

            Aadd(aLn,{"D1_BASIMP6", (cQr)->D1_BASIMP6   , NIL })
            Aadd(aLn,{"D1_ALQIMP6", (cQr)->D1_ALQIMP6   , NIL })
            Aadd(aLn,{"D1_VALIMP6", (cQr)->D1_VALIMP6   , NIL })

            Aadd(aLn,{"D1_BASEPIS", (cQr)->D1_BASEPIS   , NIL })
            Aadd(aLn,{"D1_ALQPIS" , (cQr)->D1_ALQPIS    , NIL })
            Aadd(aLn,{"D1_VALPIS" , (cQr)->D1_VALPIS    , NIL })
        
            Aadd(aLn,{"D1_BASECOF", (cQr)->D1_BASECOF   , NIL })
            Aadd(aLn,{"D1_ALQCOF" , (cQr)->D1_ALQCOF    , NIL })
            Aadd(aLn,{"D1_VALCOF" , (cQr)->D1_VALCOF    , NIL })
        
            Aadd(aLn,{"D1_ALIQCMP", (cQr)->D1_ALIQCMP   , NIL })
            
            Aadd(aLn,{"D1_ALIQSOL", (cQr)->D1_ALIQSOL   , NIL })
            
            Aadd(aLn,{"D1_BASFECP", (cQr)->D1_BASFECP   , NIL })
        //Else
        If cTpQuebra == "3"
            Aadd(aLn,{"D1_CHASSI", (cQr)->D1_CHASSI     , NIL })
        Endif            
        
        Aadd(aLn,{"D1_CORINT" , (cQr)->D1_CORINT     , NIL })
        Aadd(aLn,{"D1_COREXT" , (cQr)->D1_COREXT     , NIL })
        Aadd(aLn,{"D1_OPCION" , (cQr)->D1_OPCION     , NIL })
        Aadd(aLn,{"D1_XANOFAB", (cQr)->D1_XANOFAB    , NIL })
        Aadd(aLn,{"D1_ANOMOD" , (cQr)->D1_ANOMOD     , NIL })
        
        if (nBloqMov = 2 .AND. cTpQuebra $ "1|4")
            Aadd(aLn,{"D1_TESACLA" , (cQr)->D1_TESACLA , NIL })
        EndIf  

        Aadd(aLn,{"D1_RATEIO" , (cQr)->D1_RATEIO    , NIL })

        Aadd(aLn,{"D1_XCONT"  , (cQr)->D1_XCONT     , NIL })
        Aadd(aLn,{"D1_XCASE"  , (cQr)->D1_XCASE     , NIL })

        Aadd(aItens, aLn)
        Aadd(aRecSB2, (cQr)->RECSB2)

        (cQr)->(DbSkip())
    EndDo

    If Len(aCab) > 0 .AND. Len(aitens) > 0

        //--Verifica Lock na SB2 antes de acionar a geração da NF
        While U_ZGENLOCK( ,"SB2" ,aRecSB2 )
            nCount++
            IncProc("Aguardando liberação de registro para seguir com o processamento, tentativa " + cValToChar(nCount) )
            Sleep(60000) //--Para o processamento por 1 minuto
        EndDo

        lMsErroAuto := .F.
        MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCab, aItens, 4, {}, {})

        If lMsErroAuto
            MostraErro()
            lRes := .F.
        EndIf
    EndIf
    
    RestArea(aSF1)
    (cQr)->(DbCloseArea())

 Return lRes

/* =====================================================================================
Programa.:              zSpFun01
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Função usada em Barueri
===================================================================================== */
Static Function zCaoaSp()

    Local cTpImp     := ""
    Local aPergs     := {}
    Local aRetP      := {}
    Private bHawb    := {|| Iif(Vazio(GetAdvFVal("SW6", "W6_HAWB", FwXFilial("SF1") + MV_PAR01, 1, " ")) , ( FWAlertError(Alltrim(MV_PAR01) + " Embarque não existe.", ""), .F.), .T.) }
    Private cTpQuebra:= 0
    Private aOpcQuebra := {"1-Quebra por item (99 itens)", "2-Quebra por container (Mães)", "3-Quebra por chassi (CBU)", "4-Quebra por container (Filhas)","5-Quebra por Caixa (Mães)","6-Quebra por Caixa (Filhas)"}
    Private cTes     := Space(TamSx3("F4_CODIGO")[1])
    Private cHawb    := Space(TamSx3("W6_HAWB")[1])
    Private nBloqMov := ""
    Private cErr     := ""
    Private nErros   := 0
    Private cTpFrete := "F"

    Aadd(aPergs, {1, "No Embarque:" , Space(TamSX3("W7_HAWB")[1]) , "", 'Eval(bHawb)', "SW6", "", 100, .F.})
    Aadd(aPergs, {2, "Tipo de quebra: ", 1, aOpcQuebra, 120, ".T.", .T.})

    Pergunte( 'MTA103    ', .F. )

    If Vazio(MV_PAR17) = .T.
        FWAlertError("Confirme antes o valor do bloqueio na tela de parâmetros, (F12)", "ZEICF018")
        Return
    EndIF

    nBloqMov := MV_PAR17

    If ParamBox(aPergs, "Dados do embarque:", aRetP, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T., .T.) = .F.
        Return
    EndIf

    If ValType(MV_PAR02) == "N"
        cTpQuebra := "1"
    Else
        cTpQuebra := SubStr(MV_PAR02, 1, 1)
    EndIf

    cHawb     := MV_PAR01

    If cTpQuebra $ "2/5" .AND. nBloqMov = 1
        FWAlertError("Para notas mães quebrando por container, usar o parâmetro 'Bloqueio movimento = NAO (F12)' ", "ZEICF018")
        Return
    EndIf

    If !(cTpQuebra $ "4\6")

        cTpImp := GetAdvFVal("SW6", "W6_XTIPIMP", FwXFilial("SW6") + aRetP[1] , 1, " ")
        cTpImp := GetAdvFVal("ZZ8", "ZZ8_TIPO", FwxFilial("ZZ8") + cTpImp, 1, " ")

        zSpFun01()

    Else
        zSpFun03()
    EndIf

    if Vazio(cErr) = .F.
        FWAlertError("Nao foi possivel classificar todas as notas, verifique os erros: " + cErr, "ZEICF018")
    Else
        FWAlertSuccess("Processo finalizado!", "ZEICF018")
    EndIf

Return

/* =====================================================================================
Programa.:              zSpFun01
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Classificação da Nota Mãe
===================================================================================== */
Static Function zSpFun01()

    Local lOk       := .T.
    Local aDocs     := u_ZEICF016(cHawb, "MAE") // {F1_DOC, F1_SERIE, F1_STATUS, F1_FORNECE, F1_LOJA })
    Local aDocPend  := {}
    Local i         := 1
    Private msg     := ""

    If cTpQuebra = "1"

        For i:= 1 to Len(aDocs)
            If nBloqMov = 1 .AND. Vazio(aDocs[i,3]) = .T.
                Aadd(aDocPend, aDocs[i])
            ElseIf nBloqMov = 2 .AND. aDocs[i,3] == "C"
                Aadd(aDocPend, aDocs[i])
            Endif
        Next

    Elseif cTpQuebra $ "2/5"

        For i:= 1 to Len(aDocs)
            If (nBloqMov = 2 .AND. Vazio(aDocs[i,3]) = .T.)
                Aadd(aDocPend, aDocs[i])
            Endif
        Next

    Elseif cTpQuebra = "3"

        For i:= 1 to Len(aDocs)
            If Empty(aDocs[i,3]) = .T. .OR. aDocs[i,3] = "C"
                Aadd(aDocPend, aDocs[i])
            Endif
        Next

    Endif

    If Len(aDocPend) = 0
        FWAlertError("Não exitem notas pendentes de classificação nesse processo: " + cHawb, "ZEICF018")
        Return
    EndIf

    msg += CRLF + "Tipo Quebra: " + aOpcQuebra[Val(cTpQuebra)]
    msg += CRLF + "Bloqueio estoque: " + Iif(nBloqMov =1, "Sim", "Não")
    Aeval(aDocPend, {|x| msg += CRLF + Alltrim(x[2]) + " / " + Alltrim(x[1])  })
    If FWAlertYesNo("Deseja classificar as notas do processo: " + Alltrim(cHawb) + " ?" + msg, "ZEICF018") = .F.
        Return
    EndIf

    zSpFun04(aDocPend[1])


    // If cTpQuebra <> "3"  //
    //     cTes := "336"
    // EndIf

    If zSpFun02() = .F.
        Return
    EndIf

    For i := 1 to Len(aDocPend)
        FWMsgRun(, {|| lOk := zSpFun05(aDocPend[i]) },"", "Classificando NF: " + PadL(i, 3, '0') + " de " + PadL(Len(aDocPend), 3, '0') + " " + aDocPend[i, 1] )
        if lOk =  .F.
            cErr += CRLF + " -" + Alltrim(aDocPend[i, 2]) + "/" + Alltrim(aDocPend[i, 1])
            nErros += 1
        EndIf
    Next

Return cErr

/* =====================================================================================
Programa.:              zSpFun01
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Grava a SW6
===================================================================================== */
Static Function  zSpFun02()
    Local lRes := .T.
    Local aw6 := SW6->(GetArea())

    DbSelectArea("SW6")
    DbSetOrder(1)

    If SW6->(Dbseek(FwXfilial("SW6") + cHawb)) = .T.
        RecLock("SW6", .F.)
        SW6->W6_XQBREIC := cTpQuebra
        SW6->W6_XTESPRO := cTes
        SW6->(MsUnlock())
    Else
        FWAlertError("Não foi possivel efetuar a atualização do cabeçalho do desembarque, (W6_XQBREIC)", "ZEICF018")
        lRes := .F.
    EndIf
    RestArea(aw6)
Return lRes


/* =====================================================================================
Programa.:              zSpFun01
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Desbloqueio da Nota Filha
===================================================================================== */
Static Function zSpFun03()
    Local lOk      := .T.
    Local aDocs     := u_ZEICF016(cHawb, "FILHA") // {F1_DOC, F1_SERIE, F1_STATUS, F1_FORNECE, F1_LOJA })
    Local aDocPend  := {}
    Local i         := 1
    Local cmd       := ""
    Private msg     := ""

    If Vazio(aDocs) = .T.
        FWAlertError("Processo " + Alltrim(cHawb) + " não gerou notas filhas: " + Alltrim(cHawb), "ZEICF018")
        Return
    EndIf

    For i:= 1 to Len(aDocs)
        If (aDocs[i,3] = " " .AND. nBloqMov = 1) .OR. (aDocs[i,3] = "C" .AND. nBloqMov = 2)
            Aadd(aDocPend, aDocs[i])
        Endif
    Next

    If Len(aDocPend) = 0
        FWAlertError("Não exitem notas filhas para desbloquear nesse processo." + Alltrim(cHawb), "ZEICF018")
        Return
    EndIf

    msg += CRLF + "Tipo Quebra: " + aOpcQuebra[Val(cTpQuebra)]
    msg += CRLF + "Bloqueio estoque: " + Iif(nBloqMov =1, "Sim", "Não")
    Aeval(aDocPend, {|x| msg += CRLF + Alltrim(x[2]) + " / " + Alltrim(x[1])  })
    If FWAlertYesNo("Deseja classificar notas filhas do processo: " + Alltrim(cHawb) + " ?" + msg, "ZEICF018") = .F.
        Return
    EndIf

    //cTes := "336"
    zSpFun04(aDocPend[1])

    For i := 1 to Len(aDocPend)

        If nBloqMov = 2
            // efetua o ajuste do tipo do doc para N novamente
            cmd := CRLF + " UPDATE " + RetSqlName("SF1") + " SET F1_TIPO = 'N'
            cmd += CRLF + " WHERE D_E_L_E_T_ = ' ' "
            cmd += CRLF + " AND F1_FILIAL  = '" + FwxFilial("SF1") + "' "
            cmd += CRLF + " AND F1_DOC     = '" + aDocPend[i, 1]   + "' "
            cmd += CRLF + " AND F1_SERIE   = '" + aDocPend[i, 2]   + "' "
            cmd += CRLF + " AND F1_FORNECE = '" + aDocPend[i, 4]   + "' "
            cmd += CRLF + " AND F1_LOJA    = '" + aDocPend[i, 5]   + "' "
            TCsqLeXEC(cmd)

            cmd := CRLF + " UPDATE " + RetSqlName("SD1") + " SET D1_TIPO = 'N'
            cmd += CRLF + " WHERE D_E_L_E_T_ = ' ' "
            cmd += CRLF + " AND D1_FILIAL  = '" + FwxFilial("SD1") + "' "
            cmd += CRLF + " AND D1_DOC     = '" + aDocPend[i, 1]   + "' "
            cmd += CRLF + " AND D1_SERIE   = '" + aDocPend[i, 2]   + "' "
            cmd += CRLF + " AND D1_FORNECE = '" + aDocPend[i, 4]   + "' "
            cmd += CRLF + " AND D1_LOJA    = '" + aDocPend[i, 5]   + "' "
            TCsqLeXEC(cmd)
        Endif

        FWMsgRun(, {|| lOk := zSpFun05(aDocPend[i]) }, "", " Classificar notas filhas: " + PadL(i, 3, '0') + " de " + PadL(Len(aDocPend), 3, '0') + " " + aDocPend[i, 1] )
        if lOk := .F.
            cErr += CRLF + " -" + Alltrim(aDocPend[i, 2]) + "/" + Alltrim(aDocPend[i, 1])
            nErros += 1
        EndIf
    Next

Return


/* =====================================================================================
Programa.:              zSpFun01
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Função para receber a Tes
===================================================================================== */
Static Function zSpFun04(aDocPD)
    Local cmd      := ""
    Local ctesAcla := ""
    Local lOk      := .f.
    Local aPergs   := {}
    Local aRt      := {}
    Private bTes   := {|| Iif(Vazio(Posicione("SF4", 1, Xfilial("SF4") + MV_PAR01, "F4_CODIGO")) , ( FwAlertError(MV_PAR01 + " TES não existe.", "ZEICF018"), .F.), .T.) }
    Private aTpFret:= {"F-FOB", "C-CIF", "T-Por Conta de Terceiros", "R-Por Conta do Remetente","D-Por Conta do Destinatario","S-Sem Frete"}
   
    // {SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_STATUS, SF1->F1_FORNECE, SF1->F1_LOJA})

    cmd := CRLF + " SELECT D1_TESACLA  FROM " + RetSqlName("SD1")
    cmd += CRLF + " WHERE D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND D1_FILIAL = '" + FwXFilial("SF1") + "' "
    cmd += CRLF + " AND D1_DOC    = '" + aDocPD[1] + "' "
    cmd += CRLF + " AND D1_SERIE  = '" + aDocPD[2] + "' "
    cmd += CRLF + " AND D1_FORNECE= '" + aDocPD[4] + "' "
    cmd += CRLF + " AND D1_LOJA   = '" + aDocPD[5] + "' "
    cmd += CRLF + " AND D1_LOJA   = '" + aDocPD[5] + "' "
    cmd += CRLF + " AND D1_LOJA   = '" + aDocPD[5] + "' "
    cmd += CRLF + " AND D1_TESACLA<> ' ' "
    cmd += CRLF + " AND ROWNUM = 1 "
    ctesAcla := MpSysExecScalar(cmd,"D1_TESACLA")

    If Empty(ctesAcla) = .F.
        cTes := ctesAcla
        return
    EndIF

    Aadd(aPergs, {1, "TES", cTes, "@!", 'Eval(bTes)', "SF4", "", 30, .T.})
    Aadd(aPergs, {2, "Tipo de Frete: ", 1, aTpFret, 80, ".T.", .T.})

    While lOk = .F.
        lOk := ParamBox(aPergs, "Informar a TES e Tipo de Frete a ser usada", aRt)
    EndDo

    cTes := MV_PAR01
    if Type('MV_PAR02') == 'N'
        cTpFrete := aTpFret[MV_PAR02]
    ElseIf Type('MV_PAR02') == 'C'
        cTpFrete := MV_PAR02
    else
        cTpFrete := 'F-FOB'
    EndIf

Return

/* =====================================================================================
Programa.:              zSpFun01
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Classificação da Nota Mãe
===================================================================================== */
Static Function zSpFun05(aDocPend)
    Local cDoc      := aDocPend[1]
    Local cSerie    := aDocPend[2]
    Local cForn     := aDocPend[4]
    Local cLoja     := aDocPend[5]
    Local cmd   := ""
    Local lRes  := .T.
    Local cQr   := GetNextAlias()
    Local aCab  := {}
    Local aLn   := {}
    Local aItens:= {}
    Local aSF1  := SF1->(GetArea())
    Private lMsErroAuto := .F.

    DbSelectArea("SF1")
    DbSetOrder(1)
    If SF1->(DbSeek(Xfilial("SF1") + cDoc + cSerie + cForn + cLoja)) = .F.
        FWAlertError("Nao consegui posicionar na nota fiscal: " + cDoc + "Serie:" + cSerie, "ZEICF018")
        Return .F.
    EndIf

    cmd := " SELECT * "
    cmd += " FROM " + RetSqlName("SD1") + " SD1"
    cmd += " WHERE SD1.D_E_L_E_T_ = ' ' "
    cmd += "      AND D1_FILIAL   = '" + SF1->F1_FILIAL  + "' "
    cmd += "      AND D1_DOC      = '" + SF1->F1_DOC     + "' "
    cmd += "      AND D1_SERIE    = '" + SF1->F1_SERIE   + "' "
    cmd += "      AND D1_FORNECE  = '" + SF1->F1_FORNECE + "' "
    cmd += "      AND D1_LOJA     = '" + SF1->F1_LOJA    + "' "
    cmd += " ORDER BY D1_ITEM "

    TcQuery cmd new Alias (cQr)

    Aadd(aCab,{"F1_TIPO"    , SF1->F1_TIPO        , NIL })
    Aadd(aCab,{"F1_FORMUL"  , SF1->F1_FORMUL      , NIL })
    Aadd(aCab,{"F1_DOC"     , SF1->F1_DOC         , NIL })
    Aadd(aCab,{"F1_SERIE"   , SF1->F1_SERIE       , NIL })
    Aadd(aCab,{"F1_EMISSAO" , SF1->F1_EMISSAO     , NIL })
    Aadd(aCab,{"F1_DTDIGIT" , SF1->F1_DTDIGIT     , NIL })
    Aadd(aCab,{"F1_FORNECE" , SF1->F1_FORNECE     , NIL })
    Aadd(aCab,{"F1_LOJA"    , SF1->F1_LOJA        , NIL })
    Aadd(aCab,{"F1_ESPECIE" , SF1->F1_ESPECIE     , NIL })
    Aadd(aCab,{"F1_COND"    , "001"               , NIL })
    Aadd(aCab,{"F1_DESPESA" , SF1->F1_DESPESA     , NIL })
    Aadd(aCab,{"F1_DESCONT" , SF1->F1_DESCONT     , NIL })
    Aadd(aCab,{"F1_FRETE"   , 0                   , NIL })
    Aadd(aCab,{"F1_MOEDA"   , SF1->F1_MOEDA       , NIL })
    Aadd(aCab,{"F1_TXMOEDA" , SF1->F1_TXMOEDA     , NIL })
    Aadd(aCab,{"F1_STATUS"  , SF1->F1_STATUS      , NIL })
    Aadd(aCab,{"F1_XQBREIC" , cTpQuebra           , NIL })
    Aadd(aCab,{"F1_TPFRETE" , substr(cTpFrete,1,1), NIL })

    While (cQr)->(Eof()) = .F.
        aLn := {}
        Aadd(aLn,{"D1_ITEM"  , (cQr)->D1_ITEM   , NIL })
        Aadd(aLn,{"D1_COD"   , (cQr)->D1_COD    , NIL })
        Aadd(aLn,{"D1_UM"    , (cQr)->D1_UM     , NIL })
        IF alltrim((cQr)->D1_COD) == 'R-204001232AA'
            conout('teste')
        endif
        if cTpQuebra $ "1|2|3|5"
            Aadd(aLn,{"D1_PEDIDO" , (cQr)->D1_PEDIDO     , ".T."})
            Aadd(aLn,{"D1_ITEMPC" , (cQr)->D1_ITEMPC     , ".T. "})
        endif

        Aadd(aLn,{"D1_QUANT" , (cQr)->D1_QUANT  , NIL })
        Aadd(aLn,{"D1_VUNIT" , (cQr)->D1_VUNIT  , NIL })
        Aadd(aLn,{"D1_TOTAL" , (cQr)->D1_TOTAL  , NIL })

        If (nBloqMov = 1 .AND. cTpQuebra $ "1|3|4|6") .OR. (nBloqMov = 2 .AND. cTpQuebra $ "2|3|5" )

            Aadd(aLn,{"D1_TES" , cTes           , NIL })

        EndIf

        If nBloqMov = 2 .AND. cTpQuebra <> "3"
            Aadd(aLn,{"D1_LOCAL"  , GetAdvFVal("SB1", "B1_LOCREC",  FwXFilial("SB1") + (cQr)->D1_COD, 1, "907")        , NIL })
            Aadd(aLn,{"D1_ENDER"  , GetAdvFVal("SB5", "B5_ENDENT",  FwXFilial("SB5") + (cQr)->D1_COD, 1, "DCE01")      , NIL })
            Aadd(aLn,{"D1_SERVIC" , GetAdvFVal("SB5", "B5_SERVENT", FwXFilial("SB5") + (cQr)->D1_COD, 1, "101")        , NIL })
        ElseIf cTpQuebra = "3"
            Aadd(aLn,{"D1_LOCAL"  , GetAdvFVal("SB1", "B1_LOCREC",  FwXFilial("SB1") + (cQr)->D1_COD, 1, "907")        , NIL })
        EndIf

        Aadd(aLn,{"D1_TEC"    , (cQr)->D1_TEC       , NIL })

        If (cTpQuebra = "4|6" )
            Aadd(aLn,{"D1_CONHEC" , cHawb           , NIL })
        Else
            Aadd(aLn,{"D1_CONHEC" , (cQr)->D1_CONHEC    , NIL })
        EndIf

        If cTpQuebra <> "3"
            Aadd(aLn,{"D1_BASEIPI", (cQr)->D1_BASEIPI   , NIL })
            Aadd(aLn,{"D1_IPI"    , (cQr)->D1_IPI       , NIL })
            Aadd(aLn,{"D1_VALIPI" , (cQr)->D1_VALIPI    , NIL })

            Aadd(aLn,{"D1_ALIQII" , (cQr)->D1_ALIQII    , NIL })
            Aadd(aLn,{"D1_II"     , (cQr)->D1_II        , NIL })

            Aadd(aLn,{"D1_BASEICM", (cQr)->D1_BASEICM   , NIL })
            Aadd(aLn,{"D1_PICM"   , (cQr)->D1_PICM      , NIL })
            Aadd(aLn,{"D1_VALICM" , (cQr)->D1_VALICM    , NIL })

            Aadd(aLn,{"D1_BASIMP5", (cQr)->D1_BASIMP5   , NIL })
            Aadd(aLn,{"D1_ALQIMP5", (cQr)->D1_ALQIMP5   , NIL })
            Aadd(aLn,{"D1_VALIMP5", (cQr)->D1_VALIMP5   , NIL })

            Aadd(aLn,{"D1_BASIMP6", (cQr)->D1_BASIMP6   , NIL })
            Aadd(aLn,{"D1_ALQIMP6", (cQr)->D1_ALQIMP6   , NIL })
            Aadd(aLn,{"D1_VALIMP6", (cQr)->D1_VALIMP6   , NIL })

            Aadd(aLn,{"D1_BASEPIS", (cQr)->D1_BASEPIS   , NIL })
            Aadd(aLn,{"D1_ALQPIS" , (cQr)->D1_ALQPIS    , NIL })
            Aadd(aLn,{"D1_VALPIS" , (cQr)->D1_VALPIS    , NIL })

            Aadd(aLn,{"D1_BASECOF", (cQr)->D1_BASECOF   , NIL })
            Aadd(aLn,{"D1_ALQCOF" , (cQr)->D1_ALQCOF    , NIL })
            Aadd(aLn,{"D1_VALCOF" , (cQr)->D1_VALCOF    , NIL })

            Aadd(aLn,{"D1_ALIQCMP", (cQr)->D1_ALIQCMP   , NIL })

            Aadd(aLn,{"D1_ALIQSOL", (cQr)->D1_ALIQSOL   , NIL })

            Aadd(aLn,{"D1_BASFECP", (cQr)->D1_BASFECP   , NIL })
        Else
            Aadd(aLn,{"D1_CHASSI", (cQr)->D1_CHASSI     , NIL })
        Endif

        if (nBloqMov = 2 .AND. cTpQuebra $ "1|4|6")
            Aadd(aLn,{"D1_TESACLA" , (cQr)->D1_TESACLA , NIL })
        EndIf

        Aadd(aLn,{"D1_RATEIO" , (cQr)->D1_RATEIO        , NIL })

        Aadd(aLn,{"D1_XCONT"  , (cQr)->D1_XCONT         , NIL })
        Aadd(aLn,{"D1_XCASE"  , (cQr)->D1_XCASE         , NIL })
        Aadd(aLn,{"D1_XCONHEC", (cQr)->D1_XCONHEC       , NIL })

        Aadd(aItens, aLn)
        (cQr)->(DbSkip())
    EndDo

    If Len(aCab) > 0 .AND. Len(aitens) > 0

        lMsErroAuto := .F.
        MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCab, aItens, 4, {}, {})

        If lMsErroAuto
            MostraErro()
            lRes := .F.
        EndIf
    EndIf

    RestArea(aSF1)
    (cQr)->(DbCloseArea())

Return lRes

