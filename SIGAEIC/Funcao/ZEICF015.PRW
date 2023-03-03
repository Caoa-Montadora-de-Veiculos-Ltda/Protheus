#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

#DEFINE CRLF  Char(13) + Char(10)

/* =====================================================================================
Programa.:              ZEICF015
Autor....:              CAOA - Valter Carvalho
Data.....:              15/12/2020
Descricao / Objetivo:   Gerar as notas fiscais filhas de um processo CKD
Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              EIC - receb. Importacao
===================================================================================== */
User Function ZEICF015(_lParam)

     Local _cEmp         := FWCodEmp()
     Default _lParam     := .F.
     
     If _cEmp == "2010" //Executa o p.e. Anapolis.
          zMontadora()
     Else
          zCaoaSp(_lParam) //Executa o p.e. Barueri
     EndIf

Return(.F.)

/* =====================================================================================
Programa.:              zCaoaSp
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Usado na CaoaSp
===================================================================================== */
Static Function zCaoaSp(lCaixa)

     Local lOk      := .T.
     Local aDoc     := {}
     Local aCont    := {}
     Private cLabel  := "container"
     Private cErr   := ""
     Private cLog   := ""
     Default lCaixa := .F.
     
     if lCaixa 
          lCaixa := .T.
          cLabel := "caixas"
     EndIf
     
     If GetAdvFVal("ZZ8", "ZZ8_TIPO", FwxFilial("ZZ8") + SW6->W6_XTIPIMP, 1, " ") = "000005"
          FWAlertError("Essa função é somente para importação CKD (ZZ8_TIPO <> '000005').", "ZEICF015")
          lOk := .F.
     EndIf

     If Vazio(SW6->W6_TRANS)
          FWAlertError("Falta informar a transportadora nacional, tela de desembaraço, aba de transporte (W6_TRANSP)", "ZEICF015")
          lOk := .F.
     EndIf

     aDoc := U_ZEICF016(SW6->W6_HAWB, "MAE")
     Aeval(aDoc, {|x| Iif( Vazio(x[3]) = .T.,  cErr += Alltrim(x[1]) + "/" + Alltrim(x[2]) + CRLF, " ")} )
     If Vazio(cErr) = .F.
          FWAlertError("Existem notas Mae não classificadas no processo: " + CRLF + cErr, "ZEICF015")
          lOk := .F.
     EndIf

     // verificar se  ja gerou nota de container
     aDoc := U_ZEICF016(SW6->W6_HAWB, "FILHA")
     If Len(aDoc) > 0
          Aeval(aDoc, {|x| cErr += Alltrim(x[2]) + "/" + Alltrim(x[1]) + CRLF  })
          FWAlertError("Já consta geração de notas de " + cLabel + " para esse processo: " + CRLF + cErr, "ZEICF015")
          lOk := .F.
     EndIf

     aCont := ZCSPFS08(lCaixa)
     If Len(aCont) = 0
          FWAlertError("Não existem itens na tabela de itens por container(SZM) para a invoice deste processo." , "ZEICF015")
          lOk := .F.
     EndIf

	If FWCodFil() $ "2010022001" //2020012001"
          If ZCSPFS02() = .F.
               lOk := .F.
          EndIf
     EndIf

     If ZCSPFS01() = .F.
          FWAlertError("Os itens/quantidades registrados na tabela do container estão divergente com os itens/quantidade das notas mãe." , "ZEICF018")
          Return
     EndIf

     If lOk = .F.
          Return
     EndIf

     If FWAlertYesNo("Deseja gerar as notas " + cLabel + " do processo " + Alltrim(SW6->W6_HAWB) + " ?", "ZEICF015") = .F.
          Return
     EndIf

     Processa({|| ZCSPFS03(aCont,lCaixa) }, "ZEICF015 - Montando notas processo " + Alltrim(SW6->W6_HAWB), "Aguarde..." )
Return


/* valida se os itens+quant do container sao os mesmos da nota */
Static function ZCSPFS01()
     Local cQr := getNextAlias()
     Local aD1 := {}
     Local aZM := {}
     Local cErr := ""
     Local cmd := ""
     Local i   := 0
     Local nPos := 0

     cmd := CRLF +  " SELECT D1_COD, SUM(D1_QUANT) as D1_QUANT "
     cmd += CRLF +  " FROM " + RetSqlName("SF1") + " F1"
     cmd += CRLF +  " INNER JOIN " + RetSqlName("SD1") + " D1 ON D1.D_E_L_E_T_ = ' ' AND F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA"
     cmd += CRLF +  " WHERE "
     cmd += CRLF +  "       F1.D_E_L_E_T_ = ' ' "
     cmd += CRLF +  "   AND F1_FILIAL = '" + FwXfilial("SF1") + "' "
     cmd += CRLF +  "   AND F1_HAWB = '"   + SW6->W6_HAWB  + "' "
     cmd += CRLF +  " GROUP BY D1_COD "
     cmd += CRLF +  " ORDER BY D1_COD "

     tcQuery cmd new alias (cQr)

     (cQr)->(DbEval( {|| Aadd(aD1, { (cQr)->D1_COD, (cQr)->D1_QUANT}) }, {|| .T.}))

     (cQr)->(DBCloseArea())

     cmd := CRLF + " SELECT ZM_PROD, sum(ZM_QTDE) AS ZM_QTDE"
     cmd += CRLF + " FROM " + RetSqlName("SZM") + " SZM "
     cmd += CRLF + " WHERE SZM.D_E_L_E_T_ = ' '  "
     cmd += CRLF + " AND SZM.ZM_FILIAL= '" + FwXfilial("SZM") + "' "
     cmd += CRLF + " AND ZM_INVOICE IN ( "
     cmd += CRLF + "    SELECT DISTINCT W8_INVOICE FROM " + RetSqlName('SW8')
     cmd += CRLF + "    WHERE D_E_L_E_T_ = ' ' AND W8_FILIAL = '" + FwxFilial("SW8") + "' "
     cmd += CRLF + "    AND W8_HAWB = '" + SW6->W6_HAWB + "' "
     cmd += CRLF + " ) "
     cmd += CRLF + "GROUP BY ZM_PROD "
     cmd += CRLF + "ORDER BY ZM_PROD "

     tcQuery cmd new alias (cQr)

     (cQr)->(DbEval( {|| Aadd(aZM, { (cQr)->ZM_PROD, (cQr)->ZM_QTDE}) }, {|| .T.}))

     (cQr)->(DBCloseArea())

     For i:= 1 to Len(aD1)
          nPos := aScan(aZM, {|aIt| aIt[1] == aD1[i, 1]})
          If nPos = 0
               cErr += aD1[i, 1] + " Não está na lista do container(SZM)" + CRLF
          Else
               If aZm[nPos, 2] <> aD1[i, 2]
                    cErr += Alltrim(aD1[i, 1]) + " Qt Diverg.NF(SD1) " + cValToChar(aD1[i, 2]) + " e lista do container(SZM): " + cValToChar(aZm[nPos, 2]) + CRLF
               Endif
          EndIf
     Next

     For i:= 1 to Len(aZm)
          nPos := aScan(aD1, {|aIt| aIt[1] == aZm[i, 1]})
          If nPos = 0
               cErr += AllTrim(aZm[i, 1]) + " Item da lista do container(SZM) não esta nos itens da NF (SD1)" + CRLF
          EndIf
     Next

     If Empty(cErr) = .F.
          EecView(cErr, "Validacao Itens NF x itens container")
     EndIf

Return Empty(cErr)

Static Function ZCSPFS02()
     Local cQry := getNextAlias()
     Local cmd  := ""
     Local cErr := ""
     Local lOk  := .T.

     cmd := CRLF + " SELECT ZM_PROD, ZM_QTDE, ZM_CONT, "
     cmd += CRLF + " B1_LOCREC, "
     cmd += CRLF + " B5_ENDENT, B5_SERVENT, B5_CTRWMS "
     cmd += CRLF + " FROM " + RetSqlName("SZM") + " SZM "
     cmd += CRLF + " left JOIN " + RetSqlName("SB1") + " B1 ON B1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '" + FwXfilial("SB1") + "' AND B1_COD = ZM_PROD "
     cmd += CRLF + " left JOIN " + RetSqlName("SB5") + " B5 ON B5.D_E_L_E_T_ = ' ' AND B5_FILIAL = '" + FwXfilial("SB5") + "' AND B5_COD = B1_COD "
     cmd += CRLF + " WHERE SZM.D_E_L_E_T_ = ' '  "
     cmd += CRLF + " AND SZM.ZM_FILIAL= '" + FwXfilial("SZM") + "' "
     cmd += CRLF + " AND (B5_ENDENT IS NULL OR B5_SERVENT IS NULL OR B1_LOCREC IS NULL  OR B5_CTRWMS = '2')
     cmd += CRLF + " AND ZM_INVOICE IN ( "
     cmd += CRLF + "    SELECT DISTINCT W8_INVOICE FROM " + RetSqlName('SW8')
     cmd += CRLF + "    WHERE D_E_L_E_T_ = ' ' AND W8_FILIAL = '" + FwxFilial("SW8") + "' "
     cmd += CRLF + "    AND W8_HAWB = '" + SW6->W6_HAWB + "' "
     cmd += CRLF + " ) "

     TcQuery cmd new alias (cQry)

     (cQry)->(DbEval( {|| cErr += CRLF + "- Produto: " + (cQry)->ZM_PROD}, {|| .T.}))

     (cQry)->(DbCloseArea())

     If Empty(cErr) = .F.
          cErr := "Os seguintes produtos estão com os dados cadastrais do WMS faltantes: " + CRLF + cErr
          EecView(cErr, "Dados cadastrais faltando")
          lOk := .F.
     EndIf


Return lOk


/* inicia o procedimento de gerar as notas */
Static Function ZCSPFS03(aCont,lCaixa)
     Local nIdx          := 1
     Local cNotas        := ""
     Private cLogFile    := GetTempPath() + "ZEICF015_Log_" + Alltrim(SW6->W6_HAWB) + "-" + dtos(date()) + "-" + StrTran(time(), ":", "_") + ".TXT"
     Private aCabec      := {}
     Private aLinha      := {}
     private aNfMae      := ZCSPFS07()
     Private aNfFilha    := {} // {cDoc, aCab, aitb5ens, cSer, cInvoice, cContainer}
     Private lMSErroAuto := .F.
     Private aPesos      := {}
     Private aIRatF      := {}
     Default lCaixa      := .F.

     ProcRegua( Len(aCont) )
     Public cteste := ""
     For nIdx := 1 to Len(aCont)
          If lCaixa
               IncProc("Caixa: " + Alltrim(aCont[nIdx, 2]) ) // {invoice, container}
          else
               IncProc("Container: " + Alltrim(aCont[nIdx, 2]) ) // {invoice, container}
          endif

          ZCSPFS04(aCont[nIdx, 1], aCont[nIdx, 2],lCaixa)
     Next
     memowrite('c:\temp\teste_quant.txt',cteste)
     // efetue o rateio
     ZCSPFS06()

     //remove os impostos dos campos e grava no array
     ZCSPFS11()

     // faz o ajuste fino dos impostos para bater os centavos
     ZCSPFS13()

     ProcRegua( Len(aNfFilha) )
     Begin Transaction

          For nIdx := 1 to Len(aNfFilha)
               IncProc("Inserindo a NF: " + PadL(nIdx, 3, '0') + " de " + PadL(Len(aNfFilha), 3, '0') + " " + aNfFilha[nIdx, 1])
               aCabec := aNfFilha[nIdx, 2]
               aLinha := aNfFilha[nIdx, 3]

               MSExecAuto({|x,y,z| MATA140(x,y)}, aCabec, aLinha)

               If lMSErroAuto
                    cNotas := ""
                    MostraErro()
                    DisarmTransaction()
                    FWAlertError("O Processo foi abortado por problemas na geração das notas", "ZEICF015")
                    exit
               Else
                    cNotas += aNfFilha[nIdx, 4] + "/" + Alltrim(aNfFilha[nIdx, 1]) + Char(13) + Char(10)
               EndIf
          next

     End Transaction


     If Vazio(cNotas) = .F.
          // Atualiza a sw6
          RecLock("SW6", .F.)
          SW6->W6_XDOCFIL := cNotas
          SW6->(MsUnlock())

          MemoWrite( cLogFile, cLog )

          // cNotas := "As seguintes notas foram geradas:" + CRLF + CRLF + cNotas + CRLF + "Log dos impostos foi gravado em : " + CRLF + cLogFile
          cNotas := "As seguintes notas foram geradas:" + CRLF + CRLF + cNotas + CRLF
          EecView(cNotas, "Notas geradas:")
     Else
          FWAlertError("Processo não finalizado corretamente.", "ZEICF015")
     EndIf

Return .F.


/* gera a(s) nota(s) de um container */
Static Function ZCSPFS04(cInvoice, cCont,lCaixa)
     Local cQr      := GetNextAlias()
     Local nMaxQtIt := GetMV("MV_NUMITEN")
     Local aItens   := {}
     Local aIt      := {}
     Local aCab     := {}
     Local aPeso    := {0,0}
     Local aPesoT   := {0,0}
     Local cCmd     := ""
     Local cDoc     := ""
     Local cSer     := ""
     Local cCfo     := ""
     Local nClCod   := 0
     Local nLin     := 0
     Local nRegTot  := 0
     Local nRegAtu  := 0
     Local nVlMerc  := 0
     Local nVicm    := 0
     Local nVipi    := 0
     Local nVDesp   := 0
     Local nVFret   := 0
     Local nVII     := 0
     Local nVPMAJ   := 0
     Local nVCMAJ   := 0
     Local nCusto   := 0
     Local cTesNF   := ""
     //Local cteste   := ""
     Default lCaixa := .F.

     cCfo     := GetAdvFVal("SF4","F4_CF",xFilial("SF4") + cTesNF, 1 ,"")
     cCmd := CRLF + " SELECT  ZM_PROD,"
     cCmd += CRLF + "         ZM_QTDE, "
     cCmd += CRLF + "         ZM_CONT, "
     cCmd += CRLF + "         ZM_CASE, "
     cCmd += CRLF + "         B1_LOCREC,"
     cCmd += CRLF + "         B5_ENDENT,"
     cCmd += CRLF + "         B5_SERVENT,"
     cCmd += CRLF + "         (ZM_PO_SIGA||ZM_POSICAO) AS CHAVE"
     cCmd += CRLF + " FROM " + RetSqlName("SZM") + " SZM"
     cCmd += CRLF + "    LEFT JOIN  " + RetSqlName("SB1") + " B1 "
     cCmd += CRLF + "          ON B1.D_E_L_E_T_ = ' ' "
     cCmd += CRLF + "         AND B1_FILIAL     = '" + FwXfilial("SB1") + "' "
     cCmd += CRLF + "         AND B1_COD        = ZM_PROD "
     cCmd += CRLF + "    LEFT JOIN  " + RetSqlName("SB5") + " B5 "
     cCmd += CRLF + "          ON B5.D_E_L_E_T_ = ' ' "
     cCmd += CRLF + "         AND B5_FILIAL     = '" + FwXfilial("SB5") + "'"
     cCmd += CRLF + "         AND B5_COD        = B1_COD "
     cCmd += CRLF + "    INNER JOIN " + RetSqlName("SD1") + " D1 "
     cCmd += CRLF + "          ON D1.D_E_L_E_T_ = ' ' "
     cCmd += CRLF + "         AND D1_FILIAL     = '" + FwXfilial("SD1") + "' "
     cCmd += CRLF + "         AND D1_COD        = ZM_PROD  "
     cCmd += CRLF + "         AND D1_PEDIDO     = ZM_PO_SIGA "
     cCmd += CRLF + "         AND D1_ITEMPC     = ZM_POSICAO "
     cCmd += CRLF + "         AND D1_CONHEC     = '" + Alltrim(SW6->W6_HAWB) + "' "
     cCmd += CRLF + " WHERE SZM.D_E_L_E_T_ = ' ' "
     cCmd += CRLF + "    AND ZM_FILIAL  =  '" + xFILIAL("SZM") + "'"
     cCmd += CRLF + "    AND ZM_INVOICE =  '" + cInvoice + "' "
     If !lCaixa .OR. EMPTY(cCont) .OR. alltrim(cCont) == "SEM CONTAINER"
          cCmd += CRLF + " AND ZM_CONT    =  '" + cCont + "' "
     else
          cCmd += CRLF + " AND ZM_CASE    =  '" + cCont + "' "
     endif     

     TcQuery cCmd new alias (cQr)

     nRegTot := Contar(cQr,"!Eof()")

     (cQr)->(DbGoTop())

     While (cQr)->(!Eof())
          // pegar a coluna do codigo
          //nClCod := Ascan(aNfMae[1], {|x| x[1] == "D1_COD"})
          nClCod := Ascan(aNfMae[1], {|x| x[1] == "CHAVE"})
          //descobrir a linha do codigo
          //nLin  := Ascan(aNfMae, {|x| x[nClCod, 2] == (cQr)->ZM_PROD})
          nLin  := Ascan(aNfMae, {|x| x[nClCod, 2] == (cQr)->CHAVE})

          aIt := {}
          nRegAtu ++
          aAdd(aIt, {"D1_FILIAL"   , xFilial("SF1")    			                                   ,})
          aAdd(aIt, {"D1_TIPO"     , "N"						                                   ,})
          aAdd(aIt, {"D1_COD"      , (cQr)->ZM_PROD      				            	               ,})
          aAdd(aIt, {"D1_ITEM"     , PadL(Len(aItens) + 1, 4, "0")		                              ,})
          aAdd(aIt, {"D1_UM"       , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_UM"}), 2]   		,})
          aAdd(aIt, {"D1_CC"       , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_CC"}), 2]		,})
          aAdd(aIt, {"D1_LOCAL"    , (cQr)->B1_LOCREC 	                                                  ,".T."})
          aAdd(aIt, {"D1_ENDER"    , (cQr)->B5_ENDENT 	                                                  ,".T."})
          aAdd(aIt, {"D1_QUANT"    , (cQr)->ZM_QTDE 					                              ,})
          aAdd(aIt, {"D1_VUNIT"    , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_VUNIT"}), 2]      ,})
          aAdd(aIt, {"D1_TOTAL"    , (cQr)->ZM_QTDE * aIt[ascan(aIt,{|X| x[1]="D1_VUNIT"}),2]           ,})
          aAdd(aIt, {"D1_TES"      , cTesNF                     				                         ,})
          aAdd(aIt, {"D1_DOC"      , ""					                                             ,})
          aAdd(aIt, {"D1_SERIE"    , ""   	         		    		                                   ,})
          aAdd(aIt, {"D1_FORNECE"  , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_FORNECE"}),2]	,})
          aAdd(aIt, {"D1_LOJA"     , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_LOJA"}),2]		,})
          aAdd(aIt, {"D1_EMISSAO"  , dDataBase                                                           ,})
          aAdd(aIt, {"D1_DTDIGIT"  , dDataBase						                              ,})

          aAdd(aIt, {"D1_XCONT"    , (cQr)->ZM_CONT /*cCont*/                                            ,})
          aAdd(aIt, {"D1_XCASE"    , (cQr)->ZM_CASE                                             ,})

          nVicm  := ZCSPFS10(aNfMae[nLin], "D1_VALICM" ) * (cQr)->ZM_QTDE
          nVipi  := ZCSPFS10(aNfMae[nLin], "D1_VALIPI" ) * (cQr)->ZM_QTDE
          nVDesp := ZCSPFS10(aNfMae[nLin], "D1_DESPESA") * (cQr)->ZM_QTDE
          nVFret := ZCSPFS10(aNfMae[nLin], "D1_VALFRE" ) * (cQr)->ZM_QTDE
          nVPis  := ZCSPFS10(aNfMae[nLin], "D1_VALIMP6") * (cQr)->ZM_QTDE
          nVCof  := ZCSPFS10(aNfMae[nLin], "D1_VALIMP5") * (cQr)->ZM_QTDE
          nVII   := ZCSPFS10(aNfMae[nLin], "D1_II"     ) * (cQr)->ZM_QTDE
          nVCMAJ := ZCSPFS10(aNfMae[nLin], "D1_VALCMAJ") * (cQr)->ZM_QTDE
          nVPMAJ := ZCSPFS10(aNfMae[nLin], "D1_VALPMAJ") * (cQr)->ZM_QTDE
          nCusto := ZCSPFS10(aNfMae[nLin], "D1_CUSTO"  ) * (cQr)->ZM_QTDE
         
          nVDesp:= nVDesp + nVII + (nVCMAJ + nVPMAJ)
          //D1_DESPESA := D1_II + D1_DESPESA + (D1_VALCMAJ + D1_VALPMAJ) 
          //segunda parte
          Aadd(aIt, {"D1_CF"     , ccfo                                                                 ,})
          Aadd(aIt, {"D1_TEC"    , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_TEC"}), 2]         ,})
          Aadd(aIt, {"D1_DESPESA", nVDesp                                                               ,})
          //Aadd(aIt, {"D1_DESPESA", nVicm + nVipi  + nVDesp + nVFret + nVPis + nVCof                     ,})
          aPeso := ZCSPFS12((cQr)->ZM_PROD)
          aPesoT[1] += aPeso[1] * (cQr)->ZM_QTDE
          aPesoT[2] += aPeso[2] * (cQr)->ZM_QTDE

          Aadd(aIt, {"D1_CONTA"  , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_CONTA"}), 2]       ,})
          Aadd(aIt, {"D1_ITEMCTA", aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_ITEMCTA"}), 2]     ,})

          // II
          Aadd(aIt, {"D1_ALIQII" , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_ALIQII"}), 2]      ,})
          Aadd(aIt, {"D1_II"     , nVII                                                                 ,})
          
          //Custo
          Aadd(aIt, {"D1_CUSTO"  , nCusto                                                               ,})
          
          //ipi
          Aadd(aIt, {"D1_BASEIPI", ZCSPFS10(aNfMae[nLin], "D1_BASEIPI") * (cQr)->ZM_QTDE                   ,})
          Aadd(aIt, {"D1_IPI   " , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_IPI"}), 2]         ,})
          Aadd(aIt, {"D1_VALIPI" , nVipi                                                                ,})

          // Pis
          Aadd(aIt, {"D1_BASEPIS", ZCSPFS10(aNfMae[nLin], "D1_BASEPIS") * (cQr)->ZM_QTDE                  ,})
          Aadd(aIt, {"D1_ALQPIS" , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_ALQPIS"}), 2]      ,})
          Aadd(aIt, {"D1_VALIMP6", nVpis                                                                ,})

          // Cofins
          Aadd(aIt, {"D1_BASECOF", ZCSPFS10(aNfMae[nLin], "D1_BASECOF") * (cQr)->ZM_QTDE                  ,})
          Aadd(aIt, {"D1_ALQCOF" , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_ALQCOF"}), 2]      ,})
          Aadd(aIt, {"D1_VALIMP5", nVCof                                                                ,})

          //icm
          Aadd(aIt, {"D1_BASEICM", ZCSPFS10(aNfMae[nLin], "D1_BASEICM") * (cQr)->ZM_QTDE                  ,})
          Aadd(aIt, {"D1_PICM"   , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_PICM"}), 2]        ,})
          Aadd(aIt, {"D1_VALICM" , nVicm                   ,})
          Aadd(aIt, {"D1_XCONHEC",SW6->W6_HAWB    ,"" })
          Aadd(aItens, aclone(aIt))

          If Len(aItens) >= nMaxQtIt .OR. nRegAtu = nRegTot

               aCab := ZCSPFS05(aNfMae, aPesoT, nVlMerc)

               cDoc := aCab[aScan(aCab, {|x| x[1]= "F1_DOC"})  , 2]  // PEGA O DOC E COLoCOA NOS ITENS
               cSer := aCab[aScan(aCab, {|x| x[1]= "F1_SERIE"}), 2]  // PEGA O DOC E COLoCOA NOS ITENS

               Aadd(aNfFilha, {cDoc, aCab, aItens, cSer, cInvoice, cCont})

               aItens  := {}
               aCab    := {}
               nPesoT  := 0
               nVlMerc := 0
          EndIf

          (cQr)->(DbSkip())
     EndDo
     
     (cQr)->(DbCloseArea())

Return


/*retorna o cabecado da nota */
static function ZCSPFS05(aNfMae, aPesoT, nValMerc)
     Local aCab := {}
     Local cSer := aNfMae[1, Ascan(aNfMae[1], {|x| x[1] == "F1_SERIE"}), 2] //AllTrim(EasyGParam("MV_SER_NFE"))
     Local cDoc := NxTSx5Nota(cSer, .T., "1")

     aAdd(aCab,{"F1_FILIAL"	,xFilial("SF1")          ,Nil})
     aAdd(aCab,{"F1_TIPO"	,"N"	                    ,Nil})
     aAdd(aCab,{"F1_FORMUL"	,"S"                     ,Nil})
     aAdd(aCab,{"F1_DOC"		,cDoc                    ,Nil})//_cNota
     aAdd(aCab,{"F1_SERIE"	,cSer                    ,Nil})// coloca no layout
     aAdd(aCab,{"F1_EMISSAO"	,dDataBase               ,Nil})
     aAdd(aCab,{"F1_DTDIGIT"	,dDataBase		   	,Nil})
     aAdd(aCab,{"F1_FORNECE"	,aNfMae[1, Ascan(aNfMae[1], {|x| x[1] == "F1_FORNECE"}), 2]         ,Nil})//cFor
     aAdd(aCab,{"F1_LOJA"	,aNfMae[1, Ascan(aNfMae[1], {|x| x[1] == "F1_LOJA"   }), 2]         ,Nil})//cLoja
     aAdd(aCab,{"F1_ESPECIE"	,aNfMae[1, Ascan(aNfMae[1], {|x| x[1] == "F1_ESPECIE"}), 2]         ,NIL})

     //segunda parte
     Aadd(aCab, {"F1_TRANSP" , SW6->W6_TRANS                                                , })
     Aadd(aCab, {"F1_PLIQUI" , aPesoT[1]                                                    , })
     Aadd(aCab, {"F1_PBRUTO" , aPesoT[2]                                                    , })
     Aadd(aCab, {"F1_VALMERC", nValMerc                                                     , })
     aAdd(aCab, {"F1_TPFRETE"	,aNfMae[1, Ascan(aNfMae[1], {|x| x[1] == "F1_TPFRETE"}), 2]  ,NIL})
     aAdd(aCab, {"F1_XHAWB " ,SW6->W6_HAWB    ,"" })
Return aCab


/* efetua o ajuste dos impostos entre as notas pois os mesmos devem ser os mesmos*/
static function ZCSPFS06()
     Local aItRat   := {}
     Local nPCod    := aNfMae[1, Ascan(aNfMae[1], {|x| x[1] == "D1_COD"}), 2]
     Local cCod     := ""
     Local aImpMae  := { {"D1_II", 0}, {"D1_VALIPI", 0}, {"D1_VALIMP6", 0}, {"D1_VALIMP5", 0}, {"D1_VALICM", 0}  }
     Local aImpFilha:= { {"D1_II", 0}, {"D1_VALIPI", 0}, {"D1_VALIMP6", 0}, {"D1_VALIMP5", 0}, {"D1_VALICM", 0}  }
     Local nDoc, nItem   := 0
     Local nDIf     := 0
     Local i,j,k,a,b   := 0

     ProcRegua( Len(aNfMae) )

     For i:=1 to Len(aNfMae)
          if i % 10 = 0
               IncProc("Rateio dos impostos: " + cValToChar(i) + " de " + cValToChar(Len(aNfMae))  )
          EndIf
          aImpMae  := { {"D1_II", 0}, {"D1_VALIPI", 0}, {"D1_VALIMP6", 0}, {"D1_VALIMP5", 0}, {"D1_VALICM", 0}  }
          aImpFilha:= { {"D1_II", 0}, {"D1_VALIPI", 0}, {"D1_VALIMP6", 0}, {"D1_VALIMP5", 0}, {"D1_VALICM", 0}  }

          nPCod    := Ascan(aNfMae[i], {|x| x[1] == "D1_COD"})
          nDoc     := 0
          nItem    := 0

          cCod   := aNfMae[i, nPCod, 2]

          // se ja foi rateado ou se a linha nao é o cod
          If aScan(aItRat, cCod) > 0 //.OR. aNfMae[i, nPCod, 2] <> cCod
               Loop
          EndIf

          // somar o imposto da nota mae
          For j:= i to Len(aNfMae)
               If Alltrim(aNfMae[j, nPCod, 2]) == Alltrim(cCod)
                    for a := 1 to Len(aImpMae)
                         b := Ascan(aNfMae[j], {|x| x[1] == aImpMae[a,1]})
                         If b > 0
                              aImpMae[a,2] += aNfMae[j,b,2]
                         EndIf
                    next
               EndIf
          Next

          // somar o imposto da nota Filha
          nPCod    := Ascan(aNfFilha[1,3,1], {|x| x[1] == "D1_COD"})
          For j:= 1 to Len(aNfFilha)
               For k:= 1 to Len(aNfFilha[j,3])
                    If Alltrim(aNfFilha[j, 3, k, nPCod, 2]) == Alltrim(cCod)
                         nDoc := j
                         nItem := k

                         For a := 1 to Len(aImpFilha)
                              b:= ascan(aNfFilha[j, 3, k], {|x| x[1] == aImpFilha[a, 1] })
                              If b > 0
                                   aImpFilha[a,2] += aNfFilha[j, 3, k, b, 2]
                              EndIf
                         Next

                    EndIf
               Next
          Next


          // se algum valor está divergindo entao ajusta nA ULTIMA ocorrencia do item
          If nDoc > 0 .AND. nItem > 0
               For j:= 1 to Len(aImpMae)
                    If aImpMae[j,2] = aImpFilha[j,2]
                         Loop
                    EndIf

                    nDIf := aImpMae[j,2] - aImpFilha[j,2]

                    If nDIf > 0
                         aNfFilha[nDoc, 3, nItem, Ascan(aNfFilha[nDoc, 3, nItem], {|x| x[1] == aImpFilha[j, 1] }), 2] += nDIf
                    EndIf
               Next
          Else

          EndIf
          Aadd(aItRat, cCod)

     next
Return



/* monta um array com os dados das notas Mae do processos */
Static function ZCSPFS07()
     Local i
     Local aIt    := {}
     Local aItens := {}
     Local aCp    := {}
     Local cQr    := GetNextAlias()
     Local cCmd    := ""
     
     /*
     cCmd += CRLF + " SELECT * FROM " + RetSQLName("SF1") + " F1 "
     cCmd += CRLF + "  INNER JOIN  " + RetSQLName("SD1") + " D1 "
     cCmd += CRLF + "    ON D1.D_E_L_E_T_ = ' ' AND D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE "
     cCmd += CRLF + "    AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA "
     cCmd += CRLF + " WHERE "
     cCmd += CRLF + "       F1.D_E_L_E_T_ = ' ' "
     cCmd += CRLF + "  AND  F1_FILIAL = '" + xFilial("SF1") + "' "
     cCmd += CRLF + "  AND  F1_HAWB  = '" + SW6->W6_HAWB   + "' "
     cCmd += CRLF + "  ORDER BY F1_DOC, D1_ITEM "
     */
     
     cCmd += CRLF + " SELECT  F1.*, "
     cCmd += CRLF + "         D1.*, "
     cCmd += CRLF + "         W8_INVOICE, "
     cCmd += CRLF + "         W8_PO_NUM, "
     cCmd += CRLF + "         (D1.D1_PEDIDO || D1.D1_ITEMPC) AS CHAVE "
     cCmd += CRLF + "    FROM  " + RetSQLName("SF1") + "  F1  "
     
     cCmd += CRLF + "        INNER JOIN  " + RetSQLName("SD1") + "  D1  "
     cCmd += CRLF + "          ON D1.D_E_L_E_T_ = ' ' "
     cCmd += CRLF + "         AND D1_FILIAL  = F1_FILIAL "
     cCmd += CRLF + "         AND D1_DOC     = F1_DOC "
     cCmd += CRLF + "         AND D1_SERIE   = F1_SERIE  "
     cCmd += CRLF + "         AND D1_FORNECE = F1_FORNECE "
     cCmd += CRLF + "         AND D1_LOJA    = F1_LOJA  "
     
     cCmd += CRLF + "       INNER JOIN " + RetSQLName("SW2") + " W2 "
     cCmd += CRLF + " 		ON  W2_PO_SIGA = D1_PEDIDO  "
     cCmd += CRLF + " 		AND W2_FILIAL = F1_FILIAL "
     cCmd += CRLF + " 		AND W2_FORN   = F1_FORNECE "
     cCmd += CRLF + " 		AND W2_FORLOJ = F1_LOJA "
     cCmd += CRLF + " 		AND W2.D_E_L_E_T_ = '' "
     
     cCmd += CRLF + " 	  INNER JOIN " + RetSQLName("SW8") + " W8  "
     cCmd += CRLF + " 		ON W8_FILIAL      = D1_FILIAL  "
     cCmd += CRLF + " 		AND W8_COD_I      = D1_COD   "
     cCmd += CRLF + " 		AND W8_POSICAO    = D1_ITEMPC "
     cCmd += CRLF + " 		AND W8_PO_NUM     = W2_PO_NUM "
     cCmd += CRLF + " 		AND W8_FORN       = W2_FORN "
     cCmd += CRLF + " 		AND W8_FORLOJ     = W2_FORLOJ "
     cCmd += CRLF + "         AND W8_HAWB       = F1_HAWB "
     cCmd += CRLF + " 		AND W8.D_E_L_E_T_ = ''   "

     cCmd += CRLF + "    WHERE "
     cCmd += CRLF + "              F1.D_E_L_E_T_ = ' '  "
     cCmd += CRLF + "         AND  F1_FILIAL = '" + xFilial("SF1") + "' "
     cCmd += CRLF + "         AND  F1_HAWB  = '" + SW6->W6_HAWB   + "' "
     cCmd += CRLF + "    ORDER BY F1_DOC, D1_ITEM  "

     cCmd := ChangeQuery(cCmd)   

     TcQuery cCmd new alias (cQr)
     //dbUseArea(.T.,"TOPCONN",TcGenQry(,,ccMD),cQr,.T.,.T.)
     aCp := (cQr)->(DbStruct())

     (cQr)->(DbGoTop())
     While !(cQr)->(Eof()) //= .F.
          aIt := {}

          For i:=1 to Len(aCp)
               Aadd(aIt, { (cQr)->(aCp[i,1]), (cQr)->&(aCp[i,1]) })
          Next
          //Aadd(aIt, { "CHAVE", (cQr)->&("CHAVE") })
          Aadd(aItens, aIt)

          (cQr)->(DbSkip())
     EndDo

     (cQr)->(DbCloseArea())

Return aitens


/* retorna os containers do processo  */
Static Function ZCSPFS08(lCaixa)
     Local aRes:= {}
     Local cmd := " "
     Local cQr := GetNextAlias()
     Default lCaixa := .F.

     If !(lCaixa)
          cmd := " SELECT DISTINCT ZM_INVOICE, ZM_CONT "
     Else
          cmd := " SELECT DISTINCT ZM_INVOICE, ZM_CASE as ZM_CONT"
     EndIf
     cmd += CRLF + " FROM " + RetSqlName('SZM')
     cmd += CRLF + " WHERE D_E_L_E_T_ = ' ' AND ZM_FILIAL = '" + xfilial("SZM") + "' "
     cmd += CRLF + " AND ZM_INVOICE IN ( "
     cmd += CRLF + "    SELECT DISTINCT W8_INVOICE FROM " + RetSqlName('SW8')
     cmd += CRLF + "    WHERE D_E_L_E_T_ = ' ' AND W8_FILIAL = '" + cFilAnt + "' "
     cmd += CRLF + "    AND W8_HAWB = '" + SW6->W6_HAWB + "' "
     cmd += CRLF + " ) "
     // cmd += CRLF + " AND ZM_CONT = 'MSMU5977209         ' "

     TcQuery cmd new alias (cQr)
     
     (cQr)->(DbEval({|| Aadd(aRes, { (cQr)->ZM_INVOICE, (cQr)->ZM_CONT }) }, {||.T.}))
     
     (cQr)->(DbCloseArea())
Return aRes


/* Testa se existem notas mae no processo e se foram ou nao classIficadas */
Static Function ZCSPFS09()
     Local aArea := SF1->(getArea())
     Local nRes  := 0
     Local cErr  := ""

     DbSelectArea("SF1")
     DbSetOrder(5) // F1_FILIAL+F1_HAWB+F1_TIPO_NF+F1_DOC+F1_SERIE

     If SF1->(DbSeek(cFilAnt + SW6->W6_HAWB)) = .T.

          While cFilAnt + SW6->W6_HAWB == F1_FILIAL + F1_HAWB
               nRes := SF1->(Recno())
               If Vazio(SF1->F1_STATUS ) = .T.
                    cErr += CRLF + " - Nota não classIficada, Ser/Doc: " + Alltrim(SF1->F1_SERIE) + " / " + SF1->F1_DOC
                    nRes := 0

                    // Exit
               EndIf
               SF1->(DbSkip())
          EndDo
     Else
          cErr += CRLF + "Processo ainda não faturou as notas mãe."
     EndIf

     If Vazio(cErr) = .F.
          FWAlertError("Problemas encontrados" + CRLF + cErr, "ZEICF015")
     EndIf

     RestArea(aArea)

Return cErr


/* Recebe a linha da nota mae e o campo   e divide pela quantidade  */
Static Function ZCSPFS10(aNfMae, cCampo)

     Local xVl :=  aNfMae[Ascan(aNfMae, {|x| x[1] == cCampo }), 2] /  aNfMae[Ascan(aNfMae, {|x| x[1] == "D1_QUANT" }), 2]
     
Return xVl


/* Ajusta os impostos que foram rateados */
Static function ZCSPFS11()
     Local nDoc, nIt, nImp, nPos, nCps :=0
     Local aImps := {}

     cLog := ""

     aImps:={ {"D1_II"     , 0, "D1_ALIQII"               }, ;
          {"D1_VALIPI" , 0, "D1_BASEIPI", "D1_IPI"    }, ;
          {"D1_VALIMP6", 0, "D1_ALQPIS" , "D1_BASEPIS"}, ;
          {"D1_VALIMP5", 0, "D1_ALQCOF" , "D1_BASECOF"}, ;
          {"D1_VALICM" , 0, "D1_PICM"   , "D1_BASEICM"}}


     cLog += "cod;quant;"
     For nImp := 1 to Len(aImps)
          cLog += aImps[nImp, 1] + ";"
     Next
     cLog += CRLF

     For nDoc := 1 to Len(aNfFilha)
          aImps := { {"D1_II"     , 0, "D1_ALIQII"               }, ;
               {"D1_VALIPI" , 0, "D1_BASEIPI", "D1_IPI"    }, ;
               {"D1_VALIMP6", 0, "D1_ALQPIS" , "D1_BASEPIS"}, ;
               {"D1_VALIMP5", 0, "D1_ALQCOF" , "D1_BASECOF"}, ;
               {"D1_VALICM" , 0, "D1_PICM"   , "D1_BASEICM"}}

          cLog += "NF: " + aNfFilha[nDoc, 2, aScan(aNfFilha[nDoc, 2], {|x| x[1] == "F1_DOC"}), 2] + CRLF

          For nIt := 1 to Len(aNfFilha[nDoc, 3])

               cLog += aNfFilha[nDoc, 3, nIt, aScan( aNfFilha[nDoc, 3, nIt], {|x| x[1] = "D1_COD" }), 2]  + ";  "
               cLog += Transform(  aNfFilha[nDoc, 3, nIt, aScan( aNfFilha[nDoc, 3, nIt], {|x| x[1] = "D1_QUANT" }), 2], "@E 999999999.99" ) + "; "

               For nImp := 1 to Len(aImps)
                    nPos := aScan( aNfFilha[nDoc, 3, nIt], {|x| x[1] = aImps[nImp,1] })
                    If nPos > 0

                         cLog +=   Transform(aNfFilha[nDoc, 3, nIt, nPos, 2], "@E 999999999.999999" ) + "; "

                         aImps[nImp,2] +=  aNfFilha[nDoc, 3, nIt, nPos, 2]

                         // apagar na nota os valores dos campos
                         For nCps := 1 To Len(aImps[nImp])
                              If Valtype(aImps[nImp, nCps]) <> "C"
                                   Loop
                              EndIf
                              nPos := aScan( aNfFilha[nDoc, 3, nIt], {|x| x[1] = aImps[nImp, nCps] })
                              If nPos > 0
                                   aNfFilha[nDoc, 3, nIt, nPos, 2] := 0
                              EndIf
                         Next
                    EndIf
               Next
               cLog += CRLF
          Next

          // adicionar ao array dos impostos das filhas
          Aadd(aIRatF, { aNfFilha[nDoc, 1], aImps})
     Next
Return


/* consulta os pesos do produto no processo */
Static Function ZCSPFS12(cCod)
     Local cQr      := GetNextAlias()
     Local cmd      := ""
     Local nPos     := ""
     Local aRes     := {0,0}

     If Len(aPesos) = 0
          cmd += CRLF + " SELECT W7_COD_I, W7_PESO, W8_PESO_BR "
          cmd += CRLF + " FROM " + RetSqlName("SW7") + " W7"
          cmd += CRLF + " LEFT JOIN  " + RetSqlName("SW8")  + " W8"
          cmd += CRLF + " ON W8.D_E_L_E_T_ = ' ' AND W8_FILIAL = W7_FILIAL AND W8_PO_NUM = W7_PO_NUM AND W8_COD_I = W7_COD_I AND W8_HAWB = W7_HAWB "
          cmd += CRLF + " WHERE "
          cmd += CRLF + "     W7.D_E_L_E_T_ = ' ' "
          cmd += CRLF + " AND W7_FILIAL = '" + Xfilial("SW7") + "' "
          cmd += CRLF + " AND W7_HAWB  = '" + SW6->W6_HAWB + "' "
          cmd += CRLF + " ORDER BY W7_COD_I "

          TcQuery cmd new alias (cQr)

          (cQr)->(DbEval({|| Aadd(aPesos, {(cQr)->W7_COD_I, (cQr)->W7_PESO, (cQr)->W8_PESO_BR})}, {|| .T. }))

          (cQr)->(DbCloseArea())
     EndIf

     nPos := Ascan( aPesos, {|x| x[1] = cCod })

     If nPos > 0
          aRes := {aPesos[nPos, 2], aPesos[nPos, 3]}
     EndIf
Return aRes


/* Efetua o acerto dos totais dos impostos */
Static function ZCSPFS13()
     Local aImp   := {"D1_II", "D1_VALIPI", "D1_VALIMP6", "D1_VALIMP5", "D1_VALICM"}
     Local cQr    := GetNextAlias()
     Local aTf    := {"D1_TOTAL", "D1_DESPESA"}
     Local nImpM  := 0
     Local nImpF  := 0
     Local i      := 1
     Local j      := 1
     Local nDoc   := 1
     Local nIt    := 1
     Local cmd    := ""
     Local idxF   := 1
     Local cMsg   := ""

     Local nVlImpMae := 0
     Local nVlImpFil := 0
     Local idImpMae  := 0
     Local idImpFil  := 0

     Local nDif      := 0
     Local cOpRat    := ""
     Local nVlOpr    := 0

     // Fazer o ajuste fino dos totais dos impostos que serao gravados na mensagem F1_XMSGADI
     cLog += CRLF + "Totais dos impostos " + CRLF

     For i:=1 to Len(aImp)
          nVlImpMae := 0
          nVlImpFil := 0

          idImpMae := Ascan(aNfMae[1], {|x| x[1] == aImp[i] })
          For j := 1  to Len(aNfMae)
               nVlImpMae += aNfMae[j, idImpMae, 2]
          Next

          //Obter a soma do imposto nas notas filhas
          idImpFil := Ascan(aIRatF[1,2], {|x| x[1] == aImp[i] })
          For j := 1  to Len(aIRatF)
               nVlImpFil += aIRatF[j, 2, idImpFil, 2]
          Next


          If nVlImpMae <> nVlImpFil
               nDif := (nVlImpMae - nVlImpFil)

               cOpRat := iif( nDif <= 0 , '-', '+')

               nDif := Abs(nDif)

               If nDif > 100
                    nVlOpr := 100
               ElseIf  nDif > 10
                    nVlOpr := 10
               ElseIf  nDif > 1
                    nVlOpr := 1
               ElseIf  nDif > 0.1
                    nVlOpr := 0.1
               ElseIf  nDif >= 0.01
                    nVlOpr := 0.01
               EndIF

               While nDif >= 0.01
                    For j:=1 to Len(aIRatf)
                         if cOpRat == '-' .and. nDif >= 0.01
                              aIRatF[j, 2, idImpFil, 2] -= nVlOpr
                         EndIf

                         if cOpRat == '+' .and. nDif > 0.01
                              aIRatF[j, 2, idImpFil, 2] += nVlOpr
                         Endif

                         nDif -= nVlOpr

                         if nDif < nVlOpr
                              nVlOpr := nVlOpr / 10
                         Endif
                    Next
               EndDo
          EndIf

          //        Obter a soma do imposto nas notas filhas
          nVlImpFil := 0
          idImpFil := Ascan(aIRatF[1,2], {|x| x[1] == aImp[i] })
          For j := 1  to Len(aIRatF)
               nVlImpFil += aIRatF[j, 2, idImpFil, 2]
          Next

          cLog += " -" + aImp[i] + "     Mae: " + CValToChar(nVlImpMae) + CRLF
          cLog += " -" + aImp[i] + "   Filha: " + CValToChar(nVlImpFil) + " apos ajuste" + CRLF
     Next

     //gravar a mensagem dos impostos no campo da observação
     aImp[3] := "D1_VALPIS"   // mudo essa coluna para exibir o nome correto no campo na msg
     aImp[4] := "D1_VALCOF"

     // prcorre as notas filhas para incluir a mensagem dos impostos
     For idxF:= 1 to Len(aNfFilha)
          cMsg := ""

          For i:= 1 to Len(aImp)
               cMsg +=  " - " + Alltrim(FWX3Titulo(aImp[i])) + ": " + Alltrim((Transform( aIRatF[idxF, 2, i, 2], PesqPict("SD1", aImp[i])))) + ", "
          Next

          cMsg := SubStr(cMsg, 1, Len(cMsg)-1 )

          Aadd( aNfFilha[idxF, 2], {"F1_XMSGADI" ,  cMsg, })
     Next

     // Bater os valores de MERCADORIA + ICMS + IPI + PIS + COFINS + DESPESAS mae com  MERCADORIA + DESPESAS filha

     cmd := CRLF + " SELECT sum(F1_VALMERC + F1_VALICM + F1_VALIPI + f1_ii +F1_VALIMP5 + F1_VALIMP6 + f1_despesa) as TOTAL "
     cmd += CRLF + " FROM "  + RetSqlName("SF1")
     cmd += CRLF + " WHERE "
     cmd += CRLF + "     D_E_L_E_T_ = ' ' "
     cmd += CRLF + " AND F1_FILIAL  = '" +  FwXfilial("SF1") + "' "
     cmd += CRLF + " AND F1_HAWB    = '" + SW6->W6_HAWB + "' "

     TcQuery cmd new alias (cQr)

     nImpM := (cQr)->TOTAL

     (cQr)->(DbCloseArea())

     nImpF:= 0
     For nDoc :=1 to Len(aNfFilha)
          For nIt :=1 to Len(aNfFilha[nDoc, 3])
               For idxF :=1 to Len(aTf)
                    nImpF += aNfFilha[nDoc, 3, nIt, aScan( aNfFilha[nDoc, 3, nIt], {|x| x[1] == aTf[idxF] }), 2]
               Next
          Next
     Next

     // atualize o primeiro item da primeira nota com a dif da despesa
     If  nImpM <> nImpF
          //aNfFilha[1, 3, 1, Ascan(aNfFilha[1, 3, 1], {|x| x[1] == "D1_DESPESA" }), 2] += Round(nImpM - nImpF, 2)
     EndIf

Return

/* =====================================================================================
Programa.:              zMontadora
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Usado na Montadora
===================================================================================== */
Static Function zMontadora()

     Local lOk      := .T.
     Local aDoc     := {}
     Local aCont    := {}
     Private cErr   := ""
     Private cLog   := ""

     If GetAdvFVal("ZZ8", "ZZ8_TIPO", FwxFilial("ZZ8") + SW6->W6_XTIPIMP, 1, " ") = "000005"
          FWAlertError("Essa função é somente para importação CKD (ZZ8_TIPO <> '000005').", "ZEICF015")
          lOk := .F.
     EndIf

     If Vazio(SW6->W6_TRANS)
          FWAlertError("Falta informar a transportadora nacional, tela de desembaraço, aba de transporte (W6_TRANSP)", "ZEICF015")
          lOk := .F.
     EndIf

     aDoc := U_ZEICF016(SW6->W6_HAWB, "MAE")
     Aeval(aDoc, {|x| Iif( Vazio(x[3]) = .T.,  cErr += Alltrim(x[1]) + "/" + Alltrim(x[2]) + CRLF, " ")} )
     If Vazio(cErr) = .F.
          FWAlertError("Existem notas Mae não classificadas no processo: " + CRLF + cErr, "ZEICF015")
          lOk := .F.
     EndIf

     // verificar se  ja gerou nota de container
     aDoc := U_ZEICF016(SW6->W6_HAWB, "FILHA")
     If Len(aDoc) > 0
          Aeval(aDoc, {|x| cErr += Alltrim(x[2]) + "/" + Alltrim(x[1]) + CRLF  })
          FWAlertError("Já consta geração de notas de container para esse processo: " + CRLF + cErr, "ZEICF015")
          lOk := .F.
     EndIf

     aCont := ZCMVFS08()
     If Len(aCont) = 0
          FWAlertError("Não existem itens na tabela de itens por container(SZM) para a invoice deste processo." , "ZEICF015")
          lOk := .F.
     EndIf

	If FWCodFil() = "2010022001" 
          If ZCMVFS02() = .F.
               lOk := .F.
          EndIf
     EndIf

     If ZCMVFS01() = .F.
          FWAlertError("Os itens/quantidades registrados na tabela do container estão divergente com os itens/quantidade das notas mãe." , "ZEICF018")
          Return
     EndIf

     If lOk = .F.
          Return
     EndIf

     If FWAlertYesNo("Deseja gerar as notas container do processo " + Alltrim(SW6->W6_HAWB) + " ?", "ZEICF015") = .F.
          Return
     EndIf

     Processa({|| ZCMVFS03(aCont) }, "ZEICF015 - Montando notas processo " + Alltrim(SW6->W6_HAWB), "Aguarde..." )
Return


/* valida se os itens+quant do container sao os mesmos da nota */
Static function ZCMVFS01()
     Local cQr := getNextAlias()
     Local aD1 := {}
     Local aZM := {}
     Local cErr := ""
     Local cmd := ""
     Local i   := 0
     Local nPos := 0

     cmd := CRLF +  " SELECT D1_COD, SUM(D1_QUANT) as D1_QUANT "
     cmd += CRLF +  " FROM " + RetSqlName("SF1") + " F1"
     cmd += CRLF +  " INNER JOIN " + RetSqlName("SD1") + " D1 ON D1.D_E_L_E_T_ = ' ' AND F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA"
     cmd += CRLF +  " WHERE "
     cmd += CRLF +  "       F1.D_E_L_E_T_ = ' ' "
     cmd += CRLF +  "   AND F1_FILIAL = '" + FwXfilial("SF1") + "' "
     cmd += CRLF +  "   AND F1_HAWB = '"   + SW6->W6_HAWB  + "' "
     cmd += CRLF +  " GROUP BY D1_COD "
     cmd += CRLF +  " ORDER BY D1_COD "

     tcQuery cmd new alias (cQr)

     (cQr)->(DbEval( {|| Aadd(aD1, { (cQr)->D1_COD, (cQr)->D1_QUANT}) }, {|| .T.}))

     (cQr)->(DBCloseArea())

     cmd := CRLF + " SELECT ZM_PROD, sum(ZM_QTDE) AS ZM_QTDE"
     cmd += CRLF + " FROM " + RetSqlName("SZM") + " SZM "
     cmd += CRLF + " WHERE SZM.D_E_L_E_T_ = ' '  "
     cmd += CRLF + " AND SZM.ZM_FILIAL= '" + FwXfilial("SZM") + "' "
     cmd += CRLF + " AND ZM_INVOICE IN ( "
     cmd += CRLF + "    SELECT DISTINCT W8_INVOICE FROM " + RetSqlName('SW8')
     cmd += CRLF + "    WHERE D_E_L_E_T_ = ' ' AND W8_FILIAL = '" + FwxFilial("SW8") + "' "
     cmd += CRLF + "    AND W8_HAWB = '" + SW6->W6_HAWB + "' "
     cmd += CRLF + " ) "
     cmd += CRLF + "GROUP BY ZM_PROD "
     cmd += CRLF + "ORDER BY ZM_PROD "

     tcQuery cmd new alias (cQr)

     (cQr)->(DbEval( {|| Aadd(aZM, { (cQr)->ZM_PROD, (cQr)->ZM_QTDE}) }, {|| .T.}))

     (cQr)->(DBCloseArea())

     For i:= 1 to Len(aD1)
          nPos := aScan(aZM, {|aIt| aIt[1] == aD1[i, 1]})
          If nPos = 0
               cErr += aD1[i, 1] + " Não está na lista do container(SZM)" + CRLF
          Else
               If aZm[nPos, 2] <> aD1[i, 2]
                    cErr += Alltrim(aD1[i, 1]) + " Qt Diverg.NF(SD1) " + cValToChar(aD1[i, 2]) + " e lista do container(SZM): " + cValToChar(aZm[nPos, 2]) + CRLF
               Endif
          EndIf
     Next

     For i:= 1 to Len(aZm)
          nPos := aScan(aD1, {|aIt| aIt[1] == aZm[i, 1]})
          If nPos = 0
               cErr += AllTrim(aZm[i, 1]) + " Item da lista do container(SZM) não esta nos itens da NF (SD1)" + CRLF
          EndIf
     Next

     If Empty(cErr) = .F.
          EecView(cErr, "Validacao Itens NF x itens container")
     EndIf

Return Empty(cErr)

Static Function ZCMVFS02()
     Local cQry := getNextAlias()
     Local cmd  := ""
     Local cErr := ""
     Local lOk  := .T.

     cmd := CRLF + " SELECT ZM_PROD, ZM_QTDE, ZM_CONT, "
     cmd += CRLF + " B1_LOCREC, "
     cmd += CRLF + " B5_ENDENT, B5_SERVENT, B5_CTRWMS "
     cmd += CRLF + " FROM " + RetSqlName("SZM") + " SZM "
     cmd += CRLF + " left JOIN " + RetSqlName("SB1") + " B1 ON B1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '" + FwXfilial("SB1") + "' AND B1_COD = ZM_PROD "
     cmd += CRLF + " left JOIN " + RetSqlName("SB5") + " B5 ON B5.D_E_L_E_T_ = ' ' AND B5_FILIAL = '" + FwXfilial("SB5") + "' AND B5_COD = B1_COD "
     cmd += CRLF + " WHERE SZM.D_E_L_E_T_ = ' '  "
     cmd += CRLF + " AND SZM.ZM_FILIAL= '" + FwXfilial("SZM") + "' "
     cmd += CRLF + " AND (B5_ENDENT IS NULL OR B5_SERVENT IS NULL OR B1_LOCREC IS NULL  OR B5_CTRWMS = '2')
     cmd += CRLF + " AND ZM_INVOICE IN ( "
     cmd += CRLF + "    SELECT DISTINCT W8_INVOICE FROM " + RetSqlName('SW8')
     cmd += CRLF + "    WHERE D_E_L_E_T_ = ' ' AND W8_FILIAL = '" + FwxFilial("SW8") + "' "
     cmd += CRLF + "    AND W8_HAWB = '" + SW6->W6_HAWB + "' "
     cmd += CRLF + " ) "

     TcQuery cmd new alias (cQry)

     (cQry)->(DbEval( {|| cErr += CRLF + "- Produto: " + (cQry)->ZM_PROD}, {|| .T.}))

     (cQry)->(DbCloseArea())

     If Empty(cErr) = .F.
          cErr := "Os seguintes produtos estão com os dados cadastrais do WMS faltantes: " + CRLF + cErr
          EecView(cErr, "Dados cadastrais faltando")
          lOk := .F.
     EndIf


Return lOk


/* inicia o procedimento de gerar as notas */
Static Function ZCMVFS03(aCont)
     Local nIdx          := 1
     Local cNotas        := ""
     Local nCount        := 0
     Private cLogFile    := GetTempPath() + "ZEICF015_Log_" + Alltrim(SW6->W6_HAWB) + "-" + dtos(date()) + "-" + StrTran(time(), ":", "_") + ".TXT"
     Private aCabec      := {}
     Private aLinha      := {}
     private aNfMae      := ZCMVFS07()
     Private aNfFilha    := {} // {cDoc, aCab, aitb5ens, cSer, cInvoice, cContainer}
     Private lMSErroAuto := .F.
     Private aPesos      := {}
     Private aIRatF      := {}

     ProcRegua( Len(aCont) )

     For nIdx := 1 to Len(aCont)
          IncProc("Container: " + Alltrim(aCont[nIdx, 2]) ) // {invoice, container}

          ZCMVFS04(aCont[nIdx, 1], aCont[nIdx, 2])
     Next

     // efetue o rateio
     ZCMVFS06()

     //remove os impostos dos campos e grava no array
     ZCMVFS11()

     // faz o ajuste fino dos impostos para bater os centavos
     ZCMVFS13()

     ProcRegua( Len(aNfFilha) )
     //Transação removida porque o MATA140 fara o controle, dessa forma a transação sera realizada nota por nota
     //travando uma quantidade menor de registros por transação
     //Begin Transaction

          For nIdx := 1 to Len(aNfFilha)
               IncProc("Inserindo a NF: " + PadL(nIdx, 3, '0') + " de " + PadL(Len(aNfFilha), 3, '0') + " " + aNfFilha[nIdx, 1])
               aCabec := aNfFilha[nIdx, 2]
               aLinha := aNfFilha[nIdx, 3]
               nCount := 0

               //--Verifica Lock na SB2 antes de acionar a geração da NF
               While U_ZGENLOCK( ,"SB2" ,aNfFilha[nIdx, 7] )
                    nCount++
                    IncProc("Aguardando liberação de registro para seguir com o processamento, tentativa " + cValToChar(nCount) )
                    Sleep(60000) //--Para o processamento por 1 minuto
               EndDo

               MSExecAuto({|x,y,z| MATA140(x,y)}, aCabec, aLinha)

               If lMSErroAuto
                    cNotas := ""
                    MostraErro()
                    //DisarmTransaction()
                    FWAlertError("O Processo foi abortado por problemas na geração das notas", "ZEICF015")
                    exit
               Else
                    cNotas += aNfFilha[nIdx, 4] + "/" + Alltrim(aNfFilha[nIdx, 1]) + Char(13) + Char(10)
               EndIf
          next

     //End Transaction


     If Vazio(cNotas) = .F.
          // Atualiza a sw6
          RecLock("SW6", .F.)
          SW6->W6_XDOCFIL := cNotas
          SW6->(MsUnlock())

          MemoWrite( cLogFile, cLog )

          // cNotas := "As seguintes notas foram geradas:" + CRLF + CRLF + cNotas + CRLF + "Log dos impostos foi gravado em : " + CRLF + cLogFile
          cNotas := "As seguintes notas foram geradas:" + CRLF + CRLF + cNotas + CRLF
          EecView(cNotas, "Notas geradas:")
     Else
          FWAlertError("Processo não finalizado corretamente.", "ZEICF015")
     EndIf

Return .F.


/* gera a(s) nota(s) de um container */
Static Function ZCMVFS04(cInvoice, cCont)
     Local cQr      := GetNextAlias()
     Local nMaxQtIt := GetMV("MV_NUMITEN")
     Local aItens   := {}
     Local aIt      := {}
     Local aCab     := {}
     Local aPeso    := {0,0}
     Local aPesoT   := {0,0}
     Local cCmd     := ""
     Local cDoc     := ""
     Local cSer     := ""
     Local cCfo     := ""
     Local nClCod   := 0
     Local nLin     := 0
     Local nRegTot  := 0
     Local nRegAtu  := 0
     Local nVlMerc  := 0
     Local nVicm    := 0
     Local nVipi    := 0
     Local nVDesp   := 0
     Local nVFret   := 0
     Local cTesNF   := ""
     Local aRecSB2  := {}

     cCfo     := GetAdvFVal("SF4","F4_CF",xFilial("SF4") + cTesNF, 1 ,"")
     cCmd := CRLF + " SELECT ZM_PROD, ZM_QTDE, ZM_CONT, "
     cCmd += CRLF + " B1_LOCREC,"
     cCmd += CRLF + " B5_ENDENT, B5_SERVENT, B2.R_E_C_N_O_ AS RECSB2"
     cCmd += CRLF + " FROM " + RetSqlName("SZM") + " SZM"
     cCmd += CRLF + " LEFT JOIN " + RetSqlName("SB1") + " B1 ON B1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '" + FwXfilial("SB1") + "' AND B1_COD = ZM_PROD"
     cCmd += CRLF + " LEFT JOIN " + RetSqlName("SB5") + " B5 ON B5.D_E_L_E_T_ = ' ' AND B5_FILIAL = '" + FwXfilial("SB5") + "' AND B5_COD = B1_COD"
     cCmd += CRLF + " LEFT JOIN " + RetSqlName("SB2") + " B2 ON B2.D_E_L_E_T_ = ' ' AND B2_FILIAL = '" + FwXfilial("SB2") + "' AND B2_COD = B1_COD AND B2_LOCAL = B1_LOCREC "
     cCmd += CRLF + " WHERE SZM.D_E_L_E_T_ = ' ' "
     cCmd += CRLF + " AND ZM_FILIAL  =  '" + xFILIAL("SZM") + "'"
     cCmd += CRLF + " AND ZM_INVOICE =  '" + cInvoice + "' "
     cCmd += CRLF + " AND ZM_CONT    =  '" + cCont + "' "

     TcQuery cCmd new alias (cQr)

     nRegTot := Contar(cQr,"!Eof()")

     (cQr)->(DbGoTop())

     While (cQr)->(Eof()) = .F.
          // pegar a coluna do codigo
          nClCod := Ascan(aNfMae[1], {|x| x[1] == "D1_COD"})
          //descobrir a linha do codigo
          nLin  := Ascan(aNfMae, {|x| x[nClCod, 2] == (cQr)->ZM_PROD})

          aIt := {}
          nRegAtu ++
          aAdd(aIt, {"D1_FILIAL"   , xFilial("SF1")    			                                   ,})
          aAdd(aIt, {"D1_TIPO"     , "N"						                                   ,})
          aAdd(aIt, {"D1_COD"      , (cQr)->ZM_PROD      				            	               ,})
          aAdd(aIt, {"D1_ITEM"     , PadL(Len(aItens) + 1, 4, "0")		                              ,})
          aAdd(aIt, {"D1_UM"       , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_UM"}), 2]   		,})
          aAdd(aIt, {"D1_CC"       , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_CC"}), 2]		,})
          aAdd(aIt, {"D1_LOCAL"    , (cQr)->B1_LOCREC 	                                                  ,".T."})
          aAdd(aIt, {"D1_ENDER"    , (cQr)->B5_ENDENT 	                                                  ,".T."})
          aAdd(aIt, {"D1_QUANT"    , (cQr)->ZM_QTDE 					                              ,})
          aAdd(aIt, {"D1_VUNIT"    , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_VUNIT"}), 2]      ,})
          aAdd(aIt, {"D1_TOTAL"    , (cQr)->ZM_QTDE * aIt[ascan(aIt,{|X| x[1]="D1_VUNIT"}),2]           ,})
          aAdd(aIt, {"D1_TES"      , cTesNF                     				                         ,})
          aAdd(aIt, {"D1_DOC"      , ""					                                             ,})
          aAdd(aIt, {"D1_SERIE"    , ""   	         		    		                                   ,})
          aAdd(aIt, {"D1_FORNECE"  , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_FORNECE"}),2]	,})
          aAdd(aIt, {"D1_LOJA"     , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_LOJA"}),2]		,})
          aAdd(aIt, {"D1_EMISSAO"  , dDataBase                                                           ,})
          aAdd(aIt, {"D1_DTDIGIT"  , dDataBase						                              ,})

          aAdd(aIt, {"D1_XCONT"    ,  cCont	                                                            ,})

          nVicm := ZCMVFS10(aNfMae[nLin], "D1_VALICM")  * (cQr)->ZM_QTDE
          nVipi := ZCMVFS10(aNfMae[nLin], "D1_VALIPI")  * (cQr)->ZM_QTDE
          nVDesp:= ZCMVFS10(aNfMae[nLin], "D1_DESPESA") * (cQr)->ZM_QTDE
          nVFret:= ZCMVFS10(aNfMae[nLin], "D1_VALFRE")  * (cQr)->ZM_QTDE
          nVPis := ZCMVFS10(aNfMae[nLin], "D1_VALIMP6") * (cQr)->ZM_QTDE
          nVCof := ZCMVFS10(aNfMae[nLin], "D1_VALIMP5") * (cQr)->ZM_QTDE

          //segunda parte
          Aadd(aIt, {"D1_CF"     , ccfo                                                                 ,})
          Aadd(aIt, {"D1_TEC"    , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_TEC"}), 2]         ,})
          Aadd(aIt, {"D1_DESPESA", nVicm + nVipi  + nVDesp + nVFret + nVPis + nVCof                     ,})

          aPeso := ZCMVFS12((cQr)->ZM_PROD)
          aPesoT[1] += aPeso[1] * (cQr)->ZM_QTDE
          aPesoT[2] += aPeso[2] * (cQr)->ZM_QTDE

          Aadd(aIt, {"D1_CONTA"  , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_CONTA"}), 2]       ,})
          Aadd(aIt, {"D1_ITEMCTA", aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_ITEMCTA"}), 2]     ,})

          // II
          Aadd(aIt, {"D1_ALIQII" , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_ALIQII"}), 2]      ,})
          Aadd(aIt, {"D1_II"     , ZCMVFS10(aNfMae[nLin], "D1_II") * (cQr)->ZM_QTDE                        ,})

          //ipi
          Aadd(aIt, {"D1_BASEIPI", ZCMVFS10(aNfMae[nLin], "D1_BASEIPI") * (cQr)->ZM_QTDE                  ,})
          Aadd(aIt, {"D1_IPI   " , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_IPI"}), 2]         ,})
          Aadd(aIt, {"D1_VALIPI" , nVipi                                                                ,})

          // Pis
          Aadd(aIt, {"D1_BASEPIS", ZCMVFS10(aNfMae[nLin], "D1_BASEPIS") * (cQr)->ZM_QTDE                  ,})
          Aadd(aIt, {"D1_ALQPIS" , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_ALQPIS"}), 2]      ,})
          Aadd(aIt, {"D1_VALIMP6", nVpis                                                                ,})

          // Cofins
          Aadd(aIt, {"D1_BASECOF", ZCMVFS10(aNfMae[nLin], "D1_BASECOF") * (cQr)->ZM_QTDE                  ,})
          Aadd(aIt, {"D1_ALQCOF" , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_ALQCOF"}), 2]      ,})
          Aadd(aIt, {"D1_VALIMP5", nVCof                                                                ,})

          //icm
          Aadd(aIt, {"D1_BASEICM", ZCMVFS10(aNfMae[nLin], "D1_BASEICM") * (cQr)->ZM_QTDE                  ,})
          Aadd(aIt, {"D1_PICM"   , aNfMae[nLin, Ascan(aNfMae[nLin], {|x| x[1] == "D1_PICM"}), 2]        ,})
          Aadd(aIt, {"D1_VALICM" , nVicm                   ,})

          Aadd(aItens, aclone(aIt))
          Aadd(aRecSB2, (cQr)->RECSB2 )

          If Len(aItens) >= nMaxQtIt .OR. nRegAtu = nRegTot

               aCab := ZCMVFS05(aNfMae, aPesoT, nVlMerc)

               cDoc := aCab[aScan(aCab, {|x| x[1]= "F1_DOC"})  , 2]  // PEGA O DOC E COLoCOA NOS ITENS
               cSer := aCab[aScan(aCab, {|x| x[1]= "F1_SERIE"}), 2]  // PEGA O DOC E COLoCOA NOS ITENS

               Aadd(aNfFilha, {cDoc, aCab, aItens, cSer, cInvoice, cCont, aRecSB2})

               aItens  := {}
               aCab    := {}
               nPesoT  := 0
               nVlMerc := 0
          EndIf

          (cQr)->(DbSkip())
     EndDo
     (cQr)->(DbCloseArea())

Return


/*retorna o cabecado da nota */
static function ZCMVFS05(aNfMae, aPesoT, nValMerc)
     Local aCab := {}
     Local cSer := AllTrim(EasyGParam("MV_SER_NFE"))
     Local cDoc := NxTSx5Nota(cSer, .T., "1")

     aAdd(aCab,{"F1_FILIAL"	,xFilial("SF1")          ,Nil})
     aAdd(aCab,{"F1_TIPO"	,"N"	                    ,Nil})
     aAdd(aCab,{"F1_FORMUL"	,"S"                     ,Nil})
     aAdd(aCab,{"F1_DOC"		,cDoc                    ,Nil})//_cNota
     aAdd(aCab,{"F1_SERIE"	,cSer                    ,Nil})// coloca no layout
     aAdd(aCab,{"F1_EMISSAO"	,dDataBase               ,Nil})
     aAdd(aCab,{"F1_DTDIGIT"	,dDataBase		   	,Nil})
     aAdd(aCab,{"F1_FORNECE"	,aNfMae[1, Ascan(aNfMae[1], {|x| x[1] == "F1_FORNECE"}), 2]                    ,Nil})//cFor
     aAdd(aCab,{"F1_LOJA"	,aNfMae[1, Ascan(aNfMae[1], {|x| x[1] == "F1_LOJA"}), 2]   	             ,Nil})//cLoja
     aAdd(aCab,{"F1_ESPECIE"	,aNfMae[1, Ascan(aNfMae[1], {|x| x[1] == "F1_ESPECIE"}), 2]         ,NIL})

     //segunda parte
     Aadd(aCab, {"F1_TRANSP" , SW6->W6_TRANS                                                , })
     Aadd(aCab, {"F1_PLIQUI" , aPesoT[1]                                                    , })
     Aadd(aCab, {"F1_PBRUTO" , aPesoT[2]                                                    , })
     Aadd(aCab, {"F1_VALMERC", nValMerc                                                     , })

Return aCab


/* efetua o ajuste dos impostos entre as notas pois os mesmos devem ser os mesmos*/
static function ZCMVFS06()
     Local aItRat   := {}
     Local nPCod    := aNfMae[1, Ascan(aNfMae[1], {|x| x[1] == "D1_COD"}), 2]
     Local cCod     := ""
     Local aImpMae  := { {"D1_II", 0}, {"D1_VALIPI", 0}, {"D1_VALIMP6", 0}, {"D1_VALIMP5", 0}, {"D1_VALICM", 0}  }
     Local aImpFilha:= { {"D1_II", 0}, {"D1_VALIPI", 0}, {"D1_VALIMP6", 0}, {"D1_VALIMP5", 0}, {"D1_VALICM", 0}  }
     Local nDoc, nItem   := 0
     Local nDIf     := 0
     Local i,j,k,a,b   := 0

     ProcRegua( Len(aNfMae) )

     For i:=1 to Len(aNfMae)
          if i % 10 = 0
               IncProc("Rateio dos impostos: " + cValToChar(i) + " de " + cValToChar(Len(aNfMae))  )
          EndIf
          aImpMae  := { {"D1_II", 0}, {"D1_VALIPI", 0}, {"D1_VALIMP6", 0}, {"D1_VALIMP5", 0}, {"D1_VALICM", 0}  }
          aImpFilha:= { {"D1_II", 0}, {"D1_VALIPI", 0}, {"D1_VALIMP6", 0}, {"D1_VALIMP5", 0}, {"D1_VALICM", 0}  }

          nPCod    := Ascan(aNfMae[i], {|x| x[1] == "D1_COD"})
          nDoc     := 0
          nItem    := 0

          cCod   := aNfMae[i, nPCod, 2]

          // se ja foi rateado ou se a linha nao é o cod
          If aScan(aItRat, cCod) > 0 //.OR. aNfMae[i, nPCod, 2] <> cCod
               Loop
          EndIf

          // somar o imposto da nota mae
          For j:= i to Len(aNfMae)
               If Alltrim(aNfMae[j, nPCod, 2]) == Alltrim(cCod)
                    for a := 1 to Len(aImpMae)
                         b := Ascan(aNfMae[j], {|x| x[1] == aImpMae[a,1]})
                         If b > 0
                              aImpMae[a,2] += aNfMae[j,b,2]
                         EndIf
                    next
               EndIf
          Next

          // somar o imposto da nota Filha
          nPCod    := Ascan(aNfFilha[1,3,1], {|x| x[1] == "D1_COD"})
          For j:= 1 to Len(aNfFilha)
               For k:= 1 to Len(aNfFilha[j,3])
                    If Alltrim(aNfFilha[j, 3, k, nPCod, 2]) == Alltrim(cCod)
                         nDoc := j
                         nItem := k

                         For a := 1 to Len(aImpFilha)
                              b:= ascan(aNfFilha[j, 3, k], {|x| x[1] == aImpFilha[a, 1] })
                              If b > 0
                                   aImpFilha[a,2] += aNfFilha[j, 3, k, b, 2]
                              EndIf
                         Next

                    EndIf
               Next
          Next


          // se algum valor está divergindo entao ajusta nA ULTIMA ocorrencia do item
          If nDoc > 0 .AND. nItem > 0
               For j:= 1 to Len(aImpMae)
                    If aImpMae[j,2] = aImpFilha[j,2]
                         Loop
                    EndIf

                    nDIf := aImpMae[j,2] - aImpFilha[j,2]

                    If nDIf > 0
                         aNfFilha[nDoc, 3, nItem, Ascan(aNfFilha[nDoc, 3, nItem], {|x| x[1] == aImpFilha[j, 1] }), 2] += nDIf
                    EndIf
               Next
          Else

          EndIf
          Aadd(aItRat, cCod)

     next
Return



/* monta um array com os dados das notas Mae do processos */
Static function ZCMVFS07()
     Local i
     Local aIt    := {}
     Local aItens := {}
     Local aCp    := {}
     Local cQr    := GetNextAlias()
     Local cCmd    := ""

     cCmd += CRLF + " SELECT * FROM " + RetSQLName("SF1") + " F1 "
     cCmd += CRLF + "  INNER JOIN  " + RetSQLName("SD1") + " D1 "
     cCmd += CRLF + "    ON D1.D_E_L_E_T_ = ' ' AND D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE "
     cCmd += CRLF + "    AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA "
     cCmd += CRLF + " WHERE "
     cCmd += CRLF + "       F1.D_E_L_E_T_ = ' ' "
     cCmd += CRLF + "  AND  F1_FILIAL = '" + xFilial("SF1") + "' "
     cCmd += CRLF + "  AND  F1_HAWB  = '" + SW6->W6_HAWB   + "' "
     cCmd += CRLF + "  ORDER BY F1_DOC, D1_ITEM "

     TcQuery cCmd new alias (cQr)
     aCp := (cQr)->(DbStruct())

     (cQr)->(DbGoTop())
     While (cQr)->(Eof()) = .F.
          aIt := {}

          For i:=1 to Len(aCp)
               Aadd(aIt, { (cQr)->(aCp[i,1]), (cQr)->&(aCp[i,1]) })
          Next

          Aadd(aItens, aIt)

          (cQr)->(DbSkip())
     EndDo

     (cQr)->(DbCloseArea())

Return aitens


/* retorna os containers do processo  */
Static Function ZCMVFS08()
     Local aRes:= {}
     Local cmd := " "
     Local cQr := GetNextAlias()

     cmd := CRLF + " SELECT DISTINCT ZM_INVOICE, ZM_CONT "
     cmd += CRLF + " FROM " + RetSqlName('SZM')
     cmd += CRLF + " WHERE D_E_L_E_T_ = ' ' AND ZM_FILIAL = '" + xfilial("SZM") + "' "
     cmd += CRLF + " AND ZM_INVOICE IN ( "
     cmd += CRLF + "    SELECT DISTINCT W8_INVOICE FROM " + RetSqlName('SW8')
     cmd += CRLF + "    WHERE D_E_L_E_T_ = ' ' AND W8_FILIAL = '" + cFilAnt + "' "
     cmd += CRLF + "    AND W8_HAWB = '" + SW6->W6_HAWB + "' "
     cmd += CRLF + " ) "
     // cmd += CRLF + " AND ZM_CONT = 'MSMU5977209         ' "

     TcQuery cmd new alias (cQr)

     (cQr)->(DbEval({|| Aadd(aRes, { (cQr)->ZM_INVOICE, (cQr)->ZM_CONT }) }, {||.T.}))
     (cQr)->(DbCloseArea())
Return aRes


/* Testa se existem notas mae no processo e se foram ou nao classIficadas */
Static Function ZCMVFS09()
     Local aArea := SF1->(getArea())
     Local nRes  := 0
     Local cErr  := ""

     DbSelectArea("SF1")
     DbSetOrder(5) // F1_FILIAL+F1_HAWB+F1_TIPO_NF+F1_DOC+F1_SERIE

     If SF1->(DbSeek(cFilAnt + SW6->W6_HAWB)) = .T.

          While cFilAnt + SW6->W6_HAWB == F1_FILIAL + F1_HAWB
               nRes := SF1->(Recno())
               If Vazio(SF1->F1_STATUS ) = .T.
                    cErr += CRLF + " - Nota não classIficada, Ser/Doc: " + Alltrim(SF1->F1_SERIE) + " / " + SF1->F1_DOC
                    nRes := 0

                    // Exit
               EndIf
               SF1->(DbSkip())
          EndDo
     Else
          cErr += CRLF + "Processo ainda não faturou as notas mãe."
     EndIf

     If Vazio(cErr) = .F.
          FWAlertError("Problemas encontrados" + CRLF + cErr, "ZEICF015")
     EndIf

     RestArea(aArea)

Return cErr


/* Recebe a linha da nota mae e o campo   e divide pela quantidade  */
Static Function ZCMVFS10(aNfMae, cCampo)

     Local xVl :=  aNfMae[Ascan(aNfMae, {|x| x[1] == cCampo }), 2] /  aNfMae[Ascan(aNfMae, {|x| x[1] == "D1_QUANT" }), 2]

Return xVl


/* Ajusta os impostos que foram rateados */
Static function ZCMVFS11()
     Local nDoc, nIt, nImp, nPos, nCps :=0
     Local aImps := {}

     cLog := ""

     aImps:={ {"D1_II"     , 0, "D1_ALIQII"               }, ;
          {"D1_VALIPI" , 0, "D1_BASEIPI", "D1_IPI"    }, ;
          {"D1_VALIMP6", 0, "D1_ALQPIS" , "D1_BASEPIS"}, ;
          {"D1_VALIMP5", 0, "D1_ALQCOF" , "D1_BASECOF"}, ;
          {"D1_VALICM" , 0, "D1_PICM"   , "D1_BASEICM"}}


     cLog += "cod;quant;"
     For nImp := 1 to Len(aImps)
          cLog += aImps[nImp, 1] + ";"
     Next
     cLog += CRLF

     For nDoc := 1 to Len(aNfFilha)
          aImps := { {"D1_II"     , 0, "D1_ALIQII"               }, ;
               {"D1_VALIPI" , 0, "D1_BASEIPI", "D1_IPI"    }, ;
               {"D1_VALIMP6", 0, "D1_ALQPIS" , "D1_BASEPIS"}, ;
               {"D1_VALIMP5", 0, "D1_ALQCOF" , "D1_BASECOF"}, ;
               {"D1_VALICM" , 0, "D1_PICM"   , "D1_BASEICM"}}

          cLog += "NF: " + aNfFilha[nDoc, 2, aScan(aNfFilha[nDoc, 2], {|x| x[1] == "F1_DOC"}), 2] + CRLF

          For nIt := 1 to Len(aNfFilha[nDoc, 3])

               cLog += aNfFilha[nDoc, 3, nIt, aScan( aNfFilha[nDoc, 3, nIt], {|x| x[1] = "D1_COD" }), 2]  + ";  "
               cLog += Transform(  aNfFilha[nDoc, 3, nIt, aScan( aNfFilha[nDoc, 3, nIt], {|x| x[1] = "D1_QUANT" }), 2], "@E 999999999.99" ) + "; "

               For nImp := 1 to Len(aImps)
                    nPos := aScan( aNfFilha[nDoc, 3, nIt], {|x| x[1] = aImps[nImp,1] })
                    If nPos > 0

                         cLog +=   Transform(aNfFilha[nDoc, 3, nIt, nPos, 2], "@E 999999999.999999" ) + "; "

                         aImps[nImp,2] +=  aNfFilha[nDoc, 3, nIt, nPos, 2]

                         // apagar na nota os valores dos campos
                         For nCps := 1 To Len(aImps[nImp])
                              If Valtype(aImps[nImp, nCps]) <> "C"
                                   Loop
                              EndIf
                              nPos := aScan( aNfFilha[nDoc, 3, nIt], {|x| x[1] = aImps[nImp, nCps] })
                              If nPos > 0
                                   aNfFilha[nDoc, 3, nIt, nPos, 2] := 0
                              EndIf
                         Next
                    EndIf
               Next
               cLog += CRLF
          Next

          // adicionar ao array dos impostos das filhas
          Aadd(aIRatF, { aNfFilha[nDoc, 1], aImps})
     Next
Return


/* consulta os pesos do produto no processo */
Static Function ZCMVFS12(cCod)
     Local cQr      := GetNextAlias()
     Local cmd      := ""
     Local nPos     := ""
     Local aRes     := {0,0}

     If Len(aPesos) = 0
          cmd += CRLF + " SELECT W7_COD_I, W7_PESO, W8_PESO_BR "
          cmd += CRLF + " FROM " + RetSqlName("SW7") + " W7"
          cmd += CRLF + " LEFT JOIN  " + RetSqlName("SW8")  + " W8"
          cmd += CRLF + " ON W8.D_E_L_E_T_ = ' ' AND W8_FILIAL = W7_FILIAL AND W8_PO_NUM = W7_PO_NUM AND W8_COD_I = W7_COD_I AND W8_HAWB = W7_HAWB "
          cmd += CRLF + " WHERE "
          cmd += CRLF + "     W7.D_E_L_E_T_ = ' ' "
          cmd += CRLF + " AND W7_FILIAL = '" + Xfilial("SW7") + "' "
          cmd += CRLF + " AND W7_HAWB  = '" + SW6->W6_HAWB + "' "
          cmd += CRLF + " ORDER BY W7_COD_I "

          TcQuery cmd new alias (cQr)

          (cQr)->(DbEval({|| Aadd(aPesos, {(cQr)->W7_COD_I, (cQr)->W7_PESO, (cQr)->W8_PESO_BR})}, {|| .T. }))

          (cQr)->(DbCloseArea())
     EndIf

     nPos := Ascan( aPesos, {|x| x[1] = cCod })

     If nPos > 0
          aRes := {aPesos[nPos, 2], aPesos[nPos, 3]}
     EndIf
Return aRes


/* Efetua o acerto dos totais dos impostos */
Static function ZCMVFS13()
     Local aImp   := {"D1_II", "D1_VALIPI", "D1_VALIMP6", "D1_VALIMP5", "D1_VALICM"}
     Local cQr    := GetNextAlias()
     Local aTf    := {"D1_TOTAL", "D1_DESPESA"}
     Local nImpM  := 0
     Local nImpF  := 0
     Local i      := 1
     Local j      := 1
     Local nDoc   := 1
     Local nIt    := 1
     Local cmd    := ""
     Local idxF   := 1
     Local cMsg   := ""

     Local nVlImpMae := 0
     Local nVlImpFil := 0
     Local idImpMae  := 0
     Local idImpFil  := 0

     Local nDif      := 0
     Local cOpRat    := ""
     Local nVlOpr    := 0

     // Fazer o ajuste fino dos totais dos impostos que serao gravados na mensagem F1_XMSGADI
     cLog += CRLF + "Totais dos impostos " + CRLF

     For i:=1 to Len(aImp)
          nVlImpMae := 0
          nVlImpFil := 0

          idImpMae := Ascan(aNfMae[1], {|x| x[1] == aImp[i] })
          For j := 1  to Len(aNfMae)
               nVlImpMae += aNfMae[j, idImpMae, 2]
          Next

          //Obter a soma do imposto nas notas filhas
          idImpFil := Ascan(aIRatF[1,2], {|x| x[1] == aImp[i] })
          For j := 1  to Len(aIRatF)
               nVlImpFil += aIRatF[j, 2, idImpFil, 2]
          Next


          If nVlImpMae <> nVlImpFil
               nDif := (nVlImpMae - nVlImpFil)

               cOpRat := iif( nDif <= 0 , '-', '+')

               nDif := Abs(nDif)

               If nDif > 100
                    nVlOpr := 100
               ElseIf  nDif > 10
                    nVlOpr := 10
               ElseIf  nDif > 1
                    nVlOpr := 1
               ElseIf  nDif > 0.1
                    nVlOpr := 0.1
               ElseIf  nDif >= 0.01
                    nVlOpr := 0.01
               EndIF

               While nDif >= 0.01
                    For j:=1 to Len(aIRatf)
                         if cOpRat == '-' .and. nDif >= 0.01
                              aIRatF[j, 2, idImpFil, 2] -= nVlOpr
                         EndIf

                         if cOpRat == '+' .and. nDif > 0.01
                              aIRatF[j, 2, idImpFil, 2] += nVlOpr
                         Endif

                         nDif -= nVlOpr

                         if nDif < nVlOpr
                              nVlOpr := nVlOpr / 10
                         Endif
                    Next
               EndDo
          EndIf

          //        Obter a soma do imposto nas notas filhas
          nVlImpFil := 0
          idImpFil := Ascan(aIRatF[1,2], {|x| x[1] == aImp[i] })
          For j := 1  to Len(aIRatF)
               nVlImpFil += aIRatF[j, 2, idImpFil, 2]
          Next

          cLog += " -" + aImp[i] + "     Mae: " + CValToChar(nVlImpMae) + CRLF
          cLog += " -" + aImp[i] + "   Filha: " + CValToChar(nVlImpFil) + " apos ajuste" + CRLF
     Next

     //gravar a mensagem dos impostos no campo da observação
     aImp[3] := "D1_VALPIS"   // mudo essa coluna para exibir o nome correto no campo na msg
     aImp[4] := "D1_VALCOF"

     // prcorre as notas filhas para incluir a mensagem dos impostos
     For idxF:= 1 to Len(aNfFilha)
          cMsg := ""

          For i:= 1 to Len(aImp)
               cMsg +=  " - " + Alltrim(FWX3Titulo(aImp[i])) + ": " + Alltrim((Transform( aIRatF[idxF, 2, i, 2], PesqPict("SD1", aImp[i])))) + ", "
          Next

          cMsg := SubStr(cMsg, 1, Len(cMsg)-1 )

          Aadd( aNfFilha[idxF, 2], {"F1_XMSGADI" ,  cMsg, })
     Next

     // Bater os valores de MERCADORIA + ICMS + IPI + PIS + COFINS + DESPESAS mae com  MERCADORIA + DESPESAS filha

     cmd := CRLF + " SELECT sum(F1_VALMERC + F1_VALICM + F1_VALIPI + f1_ii +F1_VALIMP5 + F1_VALIMP6 + f1_despesa) as TOTAL "
     cmd += CRLF + " FROM "  + RetSqlName("SF1")
     cmd += CRLF + " WHERE "
     cmd += CRLF + "     D_E_L_E_T_ = ' ' "
     cmd += CRLF + " AND F1_FILIAL  = '" +  FwXfilial("SF1") + "' "
     cmd += CRLF + " AND F1_HAWB    = '" + SW6->W6_HAWB + "' "

     TcQuery cmd new alias (cQr)

     nImpM := (cQr)->TOTAL

     (cQr)->(DbCloseArea())

     nImpF:= 0
     For nDoc :=1 to Len(aNfFilha)
          For nIt :=1 to Len(aNfFilha[nDoc, 3])
               For idxF :=1 to Len(aTf)
                    nImpF += aNfFilha[nDoc, 3, nIt, aScan( aNfFilha[nDoc, 3, nIt], {|x| x[1] == aTf[idxF] }), 2]
               Next
          Next
     Next

     // atualize o primeiro item da primeira nota com a dif da despesa
     If  nImpM <> nImpF
          aNfFilha[1, 3, 1, Ascan(aNfFilha[1, 3, 1], {|x| x[1] == "D1_DESPESA" }), 2] += Round(nImpM - nImpF, 2)
     EndIf

Return


