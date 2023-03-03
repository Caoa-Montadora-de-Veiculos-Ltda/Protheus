#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
Static __lIntPFS  	:= SuperGetMv("MV_JURXFIN",.T., .F.) .And. AliasInDic("OHV")

/*/{Protheus.doc} ZESTF009()
Processamento de endereçamento em massa

@author Leonardo Miranda
@since 30/09/2022
@version 1.0
@return NIL
/*/

************************
User Function ZESTF009()
************************

Local aRet          As Array
Local aParamBox     As Array
Local cEndereco     As Character
Local cSerieDe      As Character
Local cSerieAte     As Character
Local cNotaDe       As Character
Local cNotaAte      As Character
Local dDataDe       As Date
Local dDataAte      As Date
Local aBkpARotina   As Array
Local oSay          As Object

If Type("aRotina") == "A" ; aBkpARotina := aClone(aRotina) ; aRotina := {} ; EndIf

cEndereco     := CriaVar('DB_LOCALIZ')
cSerieDe      := CriaVar('F1_SERIE'  )
cSerieAte     := CriaVar('F1_SERIE'  )
cNotaDe       := CriaVar('F1_DOC'    )
cNotaAte      := CriaVar('F1_DOC'    )
dDataDe       := CriaVar('F1_DTDIGIT')
dDataAte      := CriaVar('F1_DTDIGIT')
aRet          := {}
aParamBox     := {}

Aadd(aParamBox, {1, "Endereço:"      , cEndereco  , ""                            , ""            , "SBE"      , "" , 060, .T.})
Aadd(aParamBox, {1, "Serie De:"      , cSerieDe   , ""                            , ""            , ""         , "" , 040, .F.})
Aadd(aParamBox, {1, "Serie Ate:"     , cSerieAte  , ""                            , ""            , ""         , "" , 040, .T.})
Aadd(aParamBox, {1, "Nota De:"       , cNotaDe    , ""                            , ""            , ""         , "" , 060, .F.})
Aadd(aParamBox, {1, "Nota Ate:"      , cNotaAte   , ""                            , ""            , ""         , "" , 060, .T.})
Aadd(aParamBox, {1, "Data Ent. De:"  , dDataDe    , PesqPict("SF1","F1_DTDIGIT")  , ""            , ""         , "" , 060, .F.})
Aadd(aParamBox, {1, "Data Ent. Ate:" , dDataAte   , PesqPict("SF1","F1_DTDIGIT")  , ""            , ""         , "" , 060, .T.})
If ParamBox(aParamBox,"Preencha os Parametros para Endereçamento...",@aRet)
    If Empty(aRet[01])
		MsgStop(OemToAnsi("É obrigatório informar o endereço"),OemToAnsi("Atenção"))
		Return(Nil)
    Else
        cEndereco     := aRet[01]
        cSerieDe      := aRet[02]
        cSerieAte     := aRet[03]
        cNotaDe       := aRet[04]
        cNotaAte      := aRet[05]
        dDataDe       := aRet[06]
        dDataAte      := aRet[07]
        FWMsgRun(, {|oSay| ZProcEnd(aRet[01],aRet[02],aRet[03],aRet[04],aRet[05],aRet[06],aRet[07]) },;
                    "Endereçamento", "Selecionando Registros...")
    EndIf
EndIf
If Type("aBkpARotina") == "A" .And. Len(aBkpARotina)  <> 0 ; aRotina := aClone(aBkpARotina) ; EndIf

Return(Nil)

****************************************************************************************
Static Function ZProcEnd(cEndereco,cSerieDe,cSerieAte,cNotaDe,cNotaAte,dDataDe,dDataAte)
****************************************************************************************

Local oBrwCab       As Object
Local aCabCampos    As Array
Local aCabStru      As Array
Local aCabCol       As Array
Local oCabTable     As Object
Local cCabTable     As Character

Local oBrwIte       As Object
Local aIteCampos    As Array
Local aIteStru      As Array
Local aIteCol       As Array
Local oIteTable     As Object
Local cIteTable     As Character

Local aTamSx3       As Array
Local aSizeAut      As Array
Local nY            As Numeric
Local cPictAlias    As Character
Local cQuery        As Character
Local nStatus       As Numeric

Private oModel      As Object
Private cCabAlias   As Character
Private cIteAlias   As Character
Private oCMVVEIXX   As Object
Private oTPanel01   As Object
Private oTPanel02   As Object


/*********************************************************************************************************************************************/
//Cabeçalho
aCabCampos  := {"F1_OK","F1_FILIAL","F1_TIPO","F1_DOC","F1_SERIE","F1_CHVNFE","F1_EMISSAO","F1_FORNECE","F1_LOJA","A2_NOME","F1_VALBRUT"}
aCabStru     := {}
For nY := 1 To Len(aCabCampos)
    aTamSx3 := TamSX3(aCabCampos[nY])
    Aadd(aCabStru, {aCabCampos[nY] ,aTamSx3[03] ,aTamSx3[01] ,aTamSx3[02] })
Next

aCabCol := {}
For nY := 02 To Len(aCabStru)
    //Columas Cabeçalho
    If !aCabStru[nY][1] $ "F1_FILIAL"
        cPictAlias := "S"+Left(aCabStru[nY][1],2)
        Aadd(aCabCol,FWBrwColumn():New())
        aCabCol[Len(aCabCol)]:SetData( &("{||"+aCabStru[nY][1]+"}") )
        aCabCol[Len(aCabCol)]:SetTitle(RetTitle(aCabStru[nY][1]))
        aCabCol[Len(aCabCol)]:SetSize(aCabStru[nY][3])
        aCabCol[Len(aCabCol)]:SetDecimal(aCabStru[nY][4])
        aCabCol[Len(aCabCol)]:SetPicture(PesqPict(cPictAlias,aCabStru[nY][1]))
    EndIf
Next nY

oCabTable := FWTemporaryTable():New()
oCabTable:SetFields(aCabStru)
oCabTable:AddIndex("INDEX1", {"F1_FILIAL", "F1_DOC", "F1_SERIE", "F1_FORNECE", "F1_LOJA"} )
oCabTable:Create()
cCabAlias := oCabTable:GetAlias()

cCabTable := oCabTable:GetRealName()
cQuery := ""
cQuery += " INSERT INTO "+cCabTable+"                                                                                                   "+(Chr(13)+Chr(10))
cQuery += " (F1_OK,F1_FILIAL,F1_TIPO,F1_DOC,F1_SERIE,F1_CHVNFE,F1_EMISSAO,F1_FORNECE,F1_LOJA,A2_NOME,F1_VALBRUT,D_E_L_E_T_,R_E_C_N_O_)  "+(Chr(13)+Chr(10))
cQuery += " SELECT B.F1_OK       ,                                                                                                      "+(Chr(13)+Chr(10))
cQuery += "        B.F1_FILIAL   ,                                                                                                      "+(Chr(13)+Chr(10))
cQuery += "        B.F1_TIPO     ,                                                                                                      "+(Chr(13)+Chr(10))
cQuery += "        B.F1_DOC      ,                                                                                                      "+(Chr(13)+Chr(10))
cQuery += "        B.F1_SERIE    ,                                                                                                      "+(Chr(13)+Chr(10))
cQuery += "        B.F1_CHVNFE   ,                                                                                                      "+(Chr(13)+Chr(10))
cQuery += "        B.F1_EMISSAO  ,                                                                                                      "+(Chr(13)+Chr(10))
cQuery += "        B.F1_FORNECE  ,                                                                                                      "+(Chr(13)+Chr(10))
cQuery += "        B.F1_LOJA     ,                                                                                                      "+(Chr(13)+Chr(10))
cQuery += "        B.A2_NOME     ,                                                                                                      "+(Chr(13)+Chr(10))
cQuery += "        B.F1_VALBRUT  ,                                                                                                      "+(Chr(13)+Chr(10))
cQuery += "        ' '                                                     D_E_L_E_T_  ,                                                "+(Chr(13)+Chr(10))
cQuery += "        ROW_NUMBER() OVER (ORDER BY F1_FILIAL,F1_DOC,F1_SERIE)  R_E_C_N_O_                                                   "+(Chr(13)+Chr(10))
cQuery += " FROM (                                                                                                                      "+(Chr(13)+Chr(10))
cQuery += " SELECT  SF1.F1_OK                                                           F1_OK       ,                                   "+(Chr(13)+Chr(10))
cQuery += "         SF1.F1_FILIAL                                                       F1_FILIAL   ,                                   "+(Chr(13)+Chr(10))
cQuery += "         SF1.F1_TIPO                                                         F1_TIPO     ,                                   "+(Chr(13)+Chr(10))
cQuery += "         SF1.F1_DOC                                                          F1_DOC      ,                                   "+(Chr(13)+Chr(10))
cQuery += "         SF1.F1_SERIE                                                        F1_SERIE    ,                                   "+(Chr(13)+Chr(10))
cQuery += "         SF1.F1_CHVNFE                                                       F1_CHVNFE   ,                                   "+(Chr(13)+Chr(10))
cQuery += "         SF1.F1_EMISSAO                                                      F1_EMISSAO  ,                                   "+(Chr(13)+Chr(10))
cQuery += "         SF1.F1_FORNECE                                                      F1_FORNECE  ,                                   "+(Chr(13)+Chr(10))
cQuery += "         SF1.F1_LOJA                                                         F1_LOJA     ,                                   "+(Chr(13)+Chr(10))
cQuery += "         CASE WHEN SF1.F1_TIPO = 'N' THEN SA2.A2_NOME ELSE SA1.A1_NOME END   A2_NOME     ,                                   "+(Chr(13)+Chr(10))
cQuery += "         SF1.F1_VALBRUT                                                      F1_VALBRUT                                      "+(Chr(13)+Chr(10))
cQuery += " FROM "+RetSqlName("SF1")+" SF1                                                                                              "+(Chr(13)+Chr(10))
cQuery += "      LEFT JOIN                                                                                                              "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SA2")+" SA2 ON  SF1.F1_FORNECE  = SA2.A2_COD                                                             "+(Chr(13)+Chr(10))
cQuery += "                                AND SF1.F1_LOJA     = SA2.A2_LOJA                                                            "+(Chr(13)+Chr(10))
cQuery += "                                AND SF1.D_E_L_E_T_  = SA2.D_E_L_E_T_                                                         "+(Chr(13)+Chr(10))
cQuery += "      LEFT JOIN                                                                                                              "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SA1")+" SA1 ON  SF1.F1_FORNECE  = SA1.A1_COD                                                             "+(Chr(13)+Chr(10))
cQuery += "                                AND SF1.F1_LOJA     = SA1.A1_LOJA                                                            "+(Chr(13)+Chr(10))
cQuery += "                                AND SF1.D_E_L_E_T_  = SA1.D_E_L_E_T_                                                         "+(Chr(13)+Chr(10))
cQuery += " WHERE   SF1.F1_FILIAL           = '"+xFilial("SF1")+"'                                                                      "+(Chr(13)+Chr(10))
cQuery += "     AND SF1.F1_DOC              BETWEEN '"+cNotaDe      +"' AND '"+cNotaAte      +"'                                        "+(Chr(13)+Chr(10))
cQuery += "     AND SF1.F1_SERIE            BETWEEN '"+cSerieDe     +"' AND '"+cSerieAte     +"'                                        "+(Chr(13)+Chr(10))
cQuery += "     AND SF1.F1_DTDIGIT          BETWEEN '"+Dtos(dDataDe)+"' AND '"+Dtos(dDataAte)+"'                                        "+(Chr(13)+Chr(10))
cQuery += "     AND SF1.D_E_L_E_T_          = ' '                                                                                       "+(Chr(13)+Chr(10))
cQuery += "    AND (SELECT SD1.D1_CHASSI                                                                                                "+(Chr(13)+Chr(10))
cQuery += "         FROM "+RetSqlName("SD1")+" SD1                                                                                      "+(Chr(13)+Chr(10))
cQuery += "              INNER JOIN                                                                                                     "+(Chr(13)+Chr(10))
cQuery += "              "+RetSqlName("SDA")+" SDA ON  SD1.D1_FILIAL   = SDA.DA_FILIAL                                                  "+(Chr(13)+Chr(10))
cQuery += "                                        AND SD1.D1_NUMSEQ   = SDA.DA_NUMSEQ                                                  "+(Chr(13)+Chr(10))
cQuery += "                                        AND SD1.D_E_L_E_T_  = SDA.D_E_L_E_T_                                                 "+(Chr(13)+Chr(10))
cQuery += "         WHERE  SD1.D1_FILIAL   = SF1.F1_FILIAL                                                                              "+(Chr(13)+Chr(10))
cQuery += "            AND SD1.D1_DOC      = SF1.F1_DOC                                                                                 "+(Chr(13)+Chr(10))
cQuery += "            AND SD1.D1_SERIE    = SF1.F1_SERIE                                                                               "+(Chr(13)+Chr(10))
cQuery += "            AND SD1.D1_FORNECE  = SF1.F1_FORNECE                                                                             "+(Chr(13)+Chr(10))
cQuery += "            AND SD1.D1_LOJA     = SF1.F1_LOJA                                                                                "+(Chr(13)+Chr(10))
cQuery += "            AND SD1.D1_CHASSI   <> ' '                                                                                       "+(Chr(13)+Chr(10))
cQuery += "            AND SD1.D_E_L_E_T_  = SF1.D_E_L_E_T_                                                                             "+(Chr(13)+Chr(10))
cQuery += "            AND SDA.DA_SALDO    > 0) <> ' '                                                                                  "+(Chr(13)+Chr(10))
cQuery += "                                                                                                                             "+(Chr(13)+Chr(10))
cQuery += " UNION ALL                                                                                                                   "+(Chr(13)+Chr(10))
cQuery += "                                                                                                                             "+(Chr(13)+Chr(10))
cQuery += " SELECT A.*                                                                                                                  "+(Chr(13)+Chr(10))
cQuery += " FROM (                                                                                                                      "+(Chr(13)+Chr(10))
cQuery += " SELECT '  '               OK                   ,                                                                            "+(Chr(13)+Chr(10))
cQuery += "        SDA.DA_FILIAL      DA_FILIAL            ,                                                                            "+(Chr(13)+Chr(10))
cQuery += "        'C'                D2_TIPO              ,                                                                            "+(Chr(13)+Chr(10))
cQuery += "        SDA.DA_DOC         DA_DOC               ,                                                                            "+(Chr(13)+Chr(10))
cQuery += "        SDA.DA_SERIE       DA_SERIE             ,                                                                            "+(Chr(13)+Chr(10))
cQuery += "        SF2.F2_CHVNFE      F2_CHVNFE            ,                                                                            "+(Chr(13)+Chr(10))
cQuery += "        SD2.D2_EMISSAO     D2_EMISSAO           ,                                                                            "+(Chr(13)+Chr(10))
cQuery += "        SDA.DA_CLIFOR      DA_CLIFOR            ,                                                                            "+(Chr(13)+Chr(10))
cQuery += "        SDA.DA_LOJA        DA_LOJA              ,                                                                            "+(Chr(13)+Chr(10))
cQuery += "        SA1.A1_NOME        A1_NOME              ,                                                                            "+(Chr(13)+Chr(10))
cQuery += "        SUM(SD2.D2_TOTAL)  D2_TOTAL                                                                                          "+(Chr(13)+Chr(10))
cQuery += " FROM "+RetSqlName("SDA")+" SDA                                                                                              "+(Chr(13)+Chr(10))
cQuery += "      INNER JOIN                                                                                                             "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SD2")+" SD2 ON SDA.DA_FILIAL   = SD2.D2_FILIAL                                                           "+(Chr(13)+Chr(10))
cQuery += "                               AND SDA.DA_NUMSEQ   = SD2.D2_NUMSEQ                                                           "+(Chr(13)+Chr(10))
cQuery += "      INNER JOIN                                                                                                             "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SF2")+" SF2 ON SD2.D2_FILIAL   = SF2.F2_FILIAL                                                           "+(Chr(13)+Chr(10))
cQuery += "                               AND SD2.D2_DOC      = SF2.F2_DOC                                                              "+(Chr(13)+Chr(10))
cQuery += "                               AND SD2.D2_SERIE    = SF2.F2_SERIE                                                            "+(Chr(13)+Chr(10))
cQuery += "                               AND SD2.D_E_L_E_T_  = SF2.D_E_L_E_T_                                                          "+(Chr(13)+Chr(10))
cQuery += "      INNER JOIN                                                                                                             "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SA1")+" SA1 ON SD2.D2_CLIENTE  = SA1.A1_COD                                                              "+(Chr(13)+Chr(10))
cQuery += "                               AND SD2.D2_LOJA     = SA1.A1_LOJA                                                             "+(Chr(13)+Chr(10))
cQuery += "                               AND SDA.D_E_L_E_T_  = SA1.D_E_L_E_T_                                                          "+(Chr(13)+Chr(10))
cQuery += " WHERE SDA.DA_ORIGEM = 'SD2'                                                                                                 "+(Chr(13)+Chr(10))
cQuery += "  AND SDA.DA_SALDO   > 0                                                                                                     "+(Chr(13)+Chr(10))
cQuery += "  AND SDA.D_E_L_E_T_ = ' '                                                                                                   "+(Chr(13)+Chr(10))
cQuery += "  AND SD2.D2_NUMSERI <> ' '                                                                                                  "+(Chr(13)+Chr(10))
cQuery += "  AND SD2.D_E_L_E_T_ = '*'                                                                                                   "+(Chr(13)+Chr(10))
cQuery += " GROUP BY '  ' ,SDA.DA_FILIAL,'C',SDA.DA_DOC,SDA.DA_SERIE,SF2.F2_CHVNFE,SD2.D2_EMISSAO,                                      "+(Chr(13)+Chr(10))
cQuery += "          SDA.DA_CLIFOR,SDA.DA_LOJA,SA1.A1_NOME) A) B                                                                        "+(Chr(13)+Chr(10))
cQuery += " ORDER BY B.F1_FILIAL,B.F1_TIPO,B.F1_SERIE,B.F1_DOC                                                                          "+(Chr(13)+Chr(10))
nStatus := TCSqlExec(cQuery)

(cCabAlias)->(DbGoTop())
If (nStatus < 0)
    MsgStop("TCSQLError() " + TCSQLError(), "Registros Cabeçalho")
    If Select(cCabAlias) <> 0 ; (cCabAlias)->(DbCloseArea()) ; EndIf
    oCabTable:Delete()
    Return Nil
ElseIf (cCabAlias)->(Eof())
    MsgStop(OemToAnsi("Não foram encontrados registros para endereçar!"),OemToAnsi("Atenção"))   
    Return(Nil)
EndIf
/*********************************************************************************************************************************************/

/*********************************************************************************************************************************************/
//Itens
aIteCampos  := {"D1_FILIAL","D1_DOC","D1_SERIE","D1_FORNECE","D1_LOJA","D1_ITEM","D1_COD","B1_DESC","D1_UM","D1_QUANT","D1_VUNIT",;
                "D1_CHASSI","D1_NUMSEQ","D1_LOCAL"}
aIteStru     := {}
For nY := 1 To Len(aIteCampos)
    aTamSx3 := TamSX3(aIteCampos[nY])
    Aadd(aIteStru, {aIteCampos[nY] ,aTamSx3[03] ,aTamSx3[01] ,aTamSx3[02] })
Next

aIteCol := {}
For nY := 04 To Len(aIteStru)
    //Columas Itens
    If !aIteStru[nY][1] $ "D1_FORNECE|D1_LOJA|D1_NUMSEQ|D1_LOCAL"
        cPictAlias := "S"+Left(aIteStru[nY][1],2)
        Aadd(aIteCol,FWBrwColumn():New())
        aIteCol[Len(aIteCol)]:SetData( &("{||"+aIteStru[nY][1]+"}") )
        aIteCol[Len(aIteCol)]:SetTitle(RetTitle(aIteStru[nY][1]))
        aIteCol[Len(aIteCol)]:SetSize(aIteStru[nY][3])
        aIteCol[Len(aIteCol)]:SetDecimal(aIteStru[nY][4])
        aIteCol[Len(aIteCol)]:SetPicture(PesqPict(cPictAlias,aIteStru[nY][1]))
    EndIf
Next nY

oIteTable := FWTemporaryTable():New()
oIteTable:SetFields(aIteStru)
oIteTable:AddIndex("INDEX1", {"D1_FILIAL", "D1_DOC", "D1_SERIE", "D1_ITEM"} )
oIteTable:Create()
cIteAlias := oIteTable:GetAlias()

cIteTable := oIteTable:GetRealName()
cQuery := ""
cQuery += " INSERT INTO "+cIteTable+"                                                                "+(Chr(13)+Chr(10))
cQuery += " (D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_ITEM,D1_COD,B1_DESC,D1_UM,D1_QUANT,     "
cQuery += "  D1_VUNIT,D1_CHASSI,D1_NUMSEQ,D1_LOCAL,D_E_L_E_T_,R_E_C_N_O_)                            "+(Chr(13)+Chr(10))
cQuery += "  SELECT  SD1.D1_FILIAL     AS  D1_FILIAL  ,                                              "+(Chr(13)+Chr(10))
cQuery += "          SD1.D1_DOC        AS  D1_DOC     ,                                              "+(Chr(13)+Chr(10))
cQuery += "          SD1.D1_SERIE      AS  D1_SERIE   ,                                              "+(Chr(13)+Chr(10))
cQuery += "          SD1.D1_FORNECE    AS  D1_FORNECE ,                                              "+(Chr(13)+Chr(10))
cQuery += "          SD1.D1_LOJA       AS  D1_LOJA    ,                                              "+(Chr(13)+Chr(10))
cQuery += "          SD1.D1_ITEM       AS  D1_ITEM    ,                                              "+(Chr(13)+Chr(10))
cQuery += "          SD1.D1_COD        AS  D1_COD     ,                                              "+(Chr(13)+Chr(10))
cQuery += "          SD1.B1_DESC       AS  B1_DESC    ,                                              "+(Chr(13)+Chr(10))
cQuery += "          SD1.D1_UM         AS  D1_UM      ,                                              "+(Chr(13)+Chr(10))
cQuery += "          SD1.D1_QUANT      AS  D1_QUANT   ,                                              "+(Chr(13)+Chr(10))
cQuery += "          SD1.D1_VUNIT      AS  D1_VUNIT   ,                                              "+(Chr(13)+Chr(10))
cQuery += "          SD1.D1_CHASSI     AS  D1_CHASSI  ,                                              "+(Chr(13)+Chr(10))
cQuery += "          SD1.D1_NUMSEQ     AS  D1_NUMSEQ  ,                                              "+(Chr(13)+Chr(10))
cQuery += "          SD1.D1_LOCAL      AS  D1_LOCAL   ,                                              "+(Chr(13)+Chr(10))
cQuery += "          ' '               AS  D_E_L_E_T_ ,                                              "+(Chr(13)+Chr(10))
cQuery += "          ROW_NUMBER() OVER (ORDER BY SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE)  R_E_C_N_O_  "+(Chr(13)+Chr(10))
cQuery += " FROM (                                                                                   "+(Chr(13)+Chr(10))
cQuery += " SELECT  SD1.D1_FILIAL     AS  D1_FILIAL  ,                                               "+(Chr(13)+Chr(10))
cQuery += "         SD1.D1_DOC        AS  D1_DOC     ,                                               "+(Chr(13)+Chr(10))
cQuery += "         SD1.D1_SERIE      AS  D1_SERIE   ,                                               "+(Chr(13)+Chr(10))
cQuery += "         SD1.D1_FORNECE    AS  D1_FORNECE ,                                               "+(Chr(13)+Chr(10))
cQuery += "         SD1.D1_LOJA       AS  D1_LOJA    ,                                               "+(Chr(13)+Chr(10))
cQuery += "         SD1.D1_ITEM       AS  D1_ITEM    ,                                               "+(Chr(13)+Chr(10))
cQuery += "         SD1.D1_COD        AS  D1_COD     ,                                               "+(Chr(13)+Chr(10))
cQuery += "         SB1.B1_DESC       AS  B1_DESC    ,                                               "+(Chr(13)+Chr(10))
cQuery += "         SD1.D1_UM         AS  D1_UM      ,                                               "+(Chr(13)+Chr(10))
cQuery += "         SD1.D1_QUANT      AS  D1_QUANT   ,                                               "+(Chr(13)+Chr(10))
cQuery += "         SD1.D1_VUNIT      AS  D1_VUNIT   ,                                               "+(Chr(13)+Chr(10))
cQuery += "         SD1.D1_CHASSI     AS  D1_CHASSI  ,                                               "+(Chr(13)+Chr(10))
cQuery += "         SD1.D1_NUMSEQ     AS  D1_NUMSEQ  ,                                               "+(Chr(13)+Chr(10))
cQuery += "         SD1.D1_LOCAL      AS  D1_LOCAL                                                   "+(Chr(13)+Chr(10))
cQuery += " FROM "+RetSqlName("SD1")+" SD1                                                           "+(Chr(13)+Chr(10))
cQuery += "      INNER JOIN                                                                          "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SB1")+" SB1  ON  SD1.D1_COD      = SB1.B1_COD                         "+(Chr(13)+Chr(10))
cQuery += "                                 AND SD1.D_E_L_E_T_  = SB1.D_E_L_E_T_                     "+(Chr(13)+Chr(10))
cQuery += "      INNER JOIN                                                                          "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SDA")+" SDA  ON  SD1.D1_FILIAL   = SDA.DA_FILIAL                      "+(Chr(13)+Chr(10))
cQuery += "                                 AND SD1.D1_NUMSEQ   = SDA.DA_NUMSEQ                      "+(Chr(13)+Chr(10))
cQuery += "                                 AND SD1.D_E_L_E_T_  = SDA.D_E_L_E_T_                     "+(Chr(13)+Chr(10))
cQuery += " WHERE   SD1.D1_FILIAL           = '"+xFilial("SD1")+"'                                   "+(Chr(13)+Chr(10))
cQuery += "     AND SD1.D1_DOC              BETWEEN '"+cNotaDe      +"' AND '"+cNotaAte      +"'     "+(Chr(13)+Chr(10))
cQuery += "     AND SD1.D1_SERIE            BETWEEN '"+cSerieDe     +"' AND '"+cSerieAte     +"'     "+(Chr(13)+Chr(10))
cQuery += "     AND SD1.D1_DTDIGIT          BETWEEN '"+Dtos(dDataDe)+"' AND '"+Dtos(dDataAte)+"'     "+(Chr(13)+Chr(10))
cQuery += "     AND SD1.D_E_L_E_T_          = ' '                                                    "+(Chr(13)+Chr(10))
cQuery += "     AND SDA.DA_SALDO            > 0                                                      "+(Chr(13)+Chr(10))
cQuery += "                                                                                          "+(Chr(13)+Chr(10))
cQuery += " UNION ALL                                                                                "+(Chr(13)+Chr(10))
cQuery += "                                                                                          "+(Chr(13)+Chr(10))
cQuery += " SELECT SDA.DA_FILIAL      AS DA_FILIAL   ,                                               "+(Chr(13)+Chr(10))
cQuery += "        SDA.DA_DOC         AS DA_DOC      ,                                               "+(Chr(13)+Chr(10))
cQuery += "        SDA.DA_SERIE       AS DA_SERIE    ,                                               "+(Chr(13)+Chr(10))
cQuery += "        SD2.D2_CLIENTE     AS D2_CLIENTE  ,                                               "+(Chr(13)+Chr(10))
cQuery += "        SD2.D2_LOJA        AS D2_LOJA     ,                                               "+(Chr(13)+Chr(10))
cQuery += "        SD2.D2_ITEM        AS D2_ITEM     ,                                               "+(Chr(13)+Chr(10))
cQuery += "        SD2.D2_COD         AS D2_COD      ,                                               "+(Chr(13)+Chr(10))
cQuery += "        SB1.B1_DESC        AS B2_DESC     ,                                               "+(Chr(13)+Chr(10))
cQuery += "        SD2.D2_UM          AS D2_UM       ,                                               "+(Chr(13)+Chr(10))
cQuery += "        SD2.D2_QUANT       AS D2_QUANT    ,                                               "+(Chr(13)+Chr(10))
cQuery += "        SD2.D2_PRCVEN      AS D2_PRCVEN   ,                                               "+(Chr(13)+Chr(10))
cQuery += "        SD2.D2_NUMSERI     AS D2_NUMSERI  ,                                               "+(Chr(13)+Chr(10))
cQuery += "        SDA.DA_NUMSEQ      AS DA_NUMSEQ   ,                                               "+(Chr(13)+Chr(10))
cQuery += "        SD2.D2_LOCAL       AS D2_LOCAL                                                    "+(Chr(13)+Chr(10))
cQuery += " FROM "+RetSqlName("SDA")+" SDA                                                           "+(Chr(13)+Chr(10))                                                                                                        
cQuery += "      INNER JOIN                                                                          "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SD2")+" SD2 ON SDA.DA_FILIAL   = SD2.D2_FILIAL                        "+(Chr(13)+Chr(10))
cQuery += "                               AND SDA.DA_NUMSEQ   = SD2.D2_NUMSEQ                        "+(Chr(13)+Chr(10))
cQuery += "      INNER JOIN                                                                          "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SF2")+" SF2 ON SD2.D2_FILIAL   = SF2.F2_FILIAL                        "+(Chr(13)+Chr(10))
cQuery += "                               AND SD2.D2_DOC      = SF2.F2_DOC                           "+(Chr(13)+Chr(10))
cQuery += "                               AND SD2.D2_SERIE    = SF2.F2_SERIE                         "+(Chr(13)+Chr(10))
cQuery += "                               AND SD2.D_E_L_E_T_  = SF2.D_E_L_E_T_                       "+(Chr(13)+Chr(10))
cQuery += "      INNER JOIN                                                                          "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SB1")+" SB1 ON SD2.D2_COD      = SB1.B1_COD                           "+(Chr(13)+Chr(10))
cQuery += "                               AND SDA.D_E_L_E_T_  = SB1.D_E_L_E_T_                       "+(Chr(13)+Chr(10))
cQuery += "      INNER JOIN                                                                          "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SA1")+" SA1 ON SD2.D2_CLIENTE  = SA1.A1_COD                           "+(Chr(13)+Chr(10))
cQuery += "                               AND SD2.D2_LOJA     = SA1.A1_LOJA                          "+(Chr(13)+Chr(10))
cQuery += "                               AND SDA.D_E_L_E_T_  = SA1.D_E_L_E_T_                       "+(Chr(13)+Chr(10))
cQuery += " WHERE SDA.DA_ORIGEM = 'SD2'                                                              "+(Chr(13)+Chr(10))
cQuery += "  AND SDA.DA_SALDO > 0                                                                    "+(Chr(13)+Chr(10))
cQuery += "  AND SDA.D_E_L_E_T_ = ' '                                                                "+(Chr(13)+Chr(10))
cQuery += "  AND SD2.D2_NUMSERI <> ' '                                                               "+(Chr(13)+Chr(10))
cQuery += "  AND SD2.D_E_L_E_T_ = '*') SD1                                                           "+(Chr(13)+Chr(10))

nStatus := TCSqlExec(cQuery)
If (nStatus < 0)
    MsgStop("TCSQLError() " + TCSQLError(), "Registros Itens")
    If Select(cIteAlias) <> 0 ; (cIteAlias)->(DbCloseArea()) ; EndIf
    oIteTable:Delete()
    Return Nil
EndIf
/*********************************************************************************************************************************************/

/*********************************************************************************************************************************************/
aSizeAut  := MsAdvSize(.f.)
oCMVVEIXX := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],"Notas Fiscais para Endereçamento",,,,128,,,,,.T.)

oTPanel01 := TPanel():New(0,0,"",oCMVVEIXX,NIL,.T.,.F.,NIL,NIL,100,(oCMVVEIXX:nClientHeight/4)-10,.F.,.F.)
oTPanel01:Align := CONTROL_ALIGN_TOP

oTPanel02 := TPanel():New(0,0,"",oCMVVEIXX,NIL,.T.,.F.,NIL,NIL,100,(oCMVVEIXX:nClientHeight/4)-10,.F.,.F.)
oTPanel02:Align := CONTROL_ALIGN_BOTTOM 

oBrwCab := FWMarkBrowse():New()
oBrwCab:SetAlias(cCabAlias)
oBrwCab:SetOwner(oTPanel01)
oBrwCab:SetDescription("Cabeçalho")
oBrwCab:SetCustomMarkRec( { || FMark( oBrwCab ) } )   
oBrwCab:SetAllMark( { || FMarkAll( oBrwCab ) } )	
oBrwCab:SetFieldMark("F1_OK")
oBrwCab:SetTemporary(.T.)
oBrwCab:SetUseFilter(.F.)
oBrwCab:AddLegend( "F1_TIPO == 'N' ", "GREEN", "Entradas"          )
oBrwCab:AddLegend( "F1_TIPO == 'C' ", "RED"  , "Saidas Canceladas" )
oBrwCab:SetColumns(aCabCol)
oBrwCab:DisableDetails()
oBrwCab:DisableReport()
oBrwCab:AddButton("Endereçar Notas"	, { || FWMsgRun(, {|oSay| EnderDocs(cCabAlias,cIteAlias,oSay,cEndereco,cIteTable) }, "Endereçamento", "Processando endereçamento de notas") },,,, .F., 2 )
oBrwCab:AddButton("Visualiza Nota"  , { || MsgRun('Visualizando Nota'      ,'Consulta' ,{|| ConsultaDoc(cCabAlias,aRotina) }) },,,, .F., 2 )
oBrwCab:Activate()
//aDel(oBrwCab:oBrowse:aButtons, 1)
//aSize(oBrwCab:oBrowse:aButtons, Len(oBrwCab:oBrowse:aButtons)-1)
oBrwCab:Refresh()

oBrwIte := FWMBrowse():New()
oBrwIte:SetAlias(cIteAlias)
oBrwIte:SetOwner(oTPanel02)
oBrwIte:SetDescription("Itens")
oBrwIte:SetMenuDef('')
oBrwIte:SetTemporary(.T.)
oBrwIte:SetUseFilter(.F.)
oBrwIte:OptionReport(.F.)
oBrwIte:SetColumns(aIteCol)
oBrwIte:DisableDetails()
oBrwIte:DisableReport()
oBrwIte:Activate()
oBrwIte:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oRelac:= FWBrwRelation():New()
oRelac:AddRelation( oBrwCab , oBrwIte , {{"D1_FILIAL" , "F1_FILIAL" } ,; 
                                         {"D1_DOC"    , "F1_DOC"    } ,;
                                         {"D1_SERIE"  , "F1_SERIE"  } ,;
                                         {"D1_FORNECE", "F1_FORNECE"} ,;
                                         {"D1_LOJA"   , "F1_LOJA"   }})
oRelac:Activate()

oCMVVEIXX:Activate()

If Select(cCabAlias) <> 0 ; (cCabAlias)->(DbCloseArea()) ; EndIf
If Select(cIteAlias) <> 0 ; (cIteAlias)->(DbCloseArea()) ; EndIf

oCabTable:Delete()
oIteTable:Delete()

Return Nil

***********************************************************************
Static Function EnderDocs(cCabAlias,cIteAlias,oSay,cEndereco,cIteTable)
***********************************************************************

Local aArea         As Array
Local aCab          As Array
Local aItens        As Array
Local axItem        As Array
Local aBkpARotina   As Array
Local aBkpACols     As Array
Local aBkpAHeader   As Array
Local cTmpAlias     As Character
Local cQuery        As Character

Private lMsHelpAuto As Logical
Private lMsErroAuto As Logical

cTmpAlias   := GetNextAlias()
aArea       := GetArea()

(cCabAlias)->(DbGoTop())
While (cCabAlias)->(!Eof())

    If Empty(Alltrim((cCabAlias)->F1_OK)) 
        (cCabAlias)->(DbSkip()) 
        Loop
    EndIf
    oSay:SetText("Endereçando Nota Fiscal: " + (cCabAlias)->F1_DOC+"/"+(cCabAlias)->F1_SERIE+" ...")

    If !Empty(Alltrim((cCabAlias)->F1_OK)) .And. (cCabAlias)->F1_TIPO == "N"

        SF1->(DbSetOrder(1))
        SF1->(DbSeek(xFilial("SF1")+(cCabAlias)->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)))

        SD1->(DbSetOrder(1))
        SD1->(DbSeek(xFilial("SD1")+(cCabAlias)->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

        While SD1->(!Eof()) .And. SD1->D1_DOC     == (cCabAlias)->F1_DOC    ;
                            .And. SD1->D1_SERIE   == (cCabAlias)->F1_SERIE  ;
                            .And. SD1->D1_FORNECE == (cCabAlias)->F1_FORNECE;
                            .And. SD1->D1_LOJA    == (cCabAlias)->F1_LOJA

            /*
            If Type("aRotina") == "A" ; aBkpARotina := aClone(aRotina) ; aRotina := {} ; EndIf
            If Type("aCols"  ) == "A" ; aBkpACols   := aClone(aCols  ) ; aCols   := {} ; EndIf
            If Type("aHeader") == "A" ; aBkpAHeader := aClone(aHeader) ; aHeader := {} ; EndIf
            */

            //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
            SDA->(DbSetOrder(1))
            If SDA->(DbSeek(xFilial("SDA")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))

                aItens := {}
                aCab   := {{"DA_PRODUTO" ,SD1->D1_COD    ,Nil},;
                           {"DA_NUMSEQ"  ,SD1->D1_NUMSEQ ,Nil}}
    
                axItem := {{"DB_ITEM"    ,"0001"         ,Nil},;
                           {"DB_ESTORNO" ," "            ,Nil},;
                           {"DB_LOCALIZ" ,cEndereco      ,Nil},;
                           {"DB_DATA"    ,dDataBase      ,Nil},;
                           {"DB_NUMSERI" ,SD1->D1_CHASSI ,Nil},;
                           {"DB_QUANT"   ,1              ,Nil}}
                Aadd(aItens,axItem)
    
                lMsErroAuto := .F.
                MATA265( aCab, aItens, 3)
                If lMsErroAuto ; MostraErro() ; EndIf

            EndIf
            SD1->(DbSkip())
        End
    ElseIf !Empty(Alltrim((cCabAlias)->F1_OK))

        cQuery := ""
        cQuery += " SELECT *                                             "+(Chr(13)+Chr(10))
        cQuery += " FROM  "+cIteTable+" SD1                              "+(Chr(13)+Chr(10))
        cQuery += " WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")         +"' "+(Chr(13)+Chr(10))
        cQuery += "   AND SD1.D1_DOC     = '"+(cCabAlias)->F1_DOC    +"' "+(Chr(13)+Chr(10))
        cQuery += "   AND SD1.D1_SERIE   = '"+(cCabAlias)->F1_SERIE  +"' "+(Chr(13)+Chr(10))
        cQuery += "   AND SD1.D1_FORNECE = '"+(cCabAlias)->F1_FORNECE+"' "+(Chr(13)+Chr(10))
        cQuery += "   AND SD1.D1_LOJA    = '"+(cCabAlias)->F1_LOJA   +"' "+(Chr(13)+Chr(10))

        If Select(cTmpAlias) <> 0 ; (cTmpAlias)->(DbCloseArea()) ; EndIf
        DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTmpAlias, .F., .T. )
        While (cTmpAlias)->(!Eof())

            //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
            SDA->(DbSetOrder(1))
            If SDA->(DbSeek(xFilial("SDA")+(cTmpAlias)->D1_COD    +(cTmpAlias)->D1_LOCAL  +;
                                           (cTmpAlias)->D1_NUMSEQ +(cTmpAlias)->D1_DOC    +;
                                           (cTmpAlias)->D1_SERIE  +(cTmpAlias)->D1_FORNECE+;
                                           (cTmpAlias)->D1_LOJA))        
                aItens := {}
                aCab   := {{"DA_PRODUTO" ,(cTmpAlias)->D1_COD    ,Nil},;
                           {"DA_NUMSEQ"  ,(cTmpAlias)->D1_NUMSEQ ,Nil}}
    
                axItem := {{"DB_ITEM"    ,"0001"                 ,Nil},;
                           {"DB_ESTORNO" ," "                    ,Nil},;
                           {"DB_LOCALIZ" ,cEndereco              ,Nil},;
                           {"DB_DATA"    ,dDataBase              ,Nil},;
                           {"DB_NUMSERI" ,(cTmpAlias)->D1_CHASSI ,Nil},;
                           {"DB_QUANT"   ,1                      ,Nil}}
                Aadd(aItens,axItem)
    
                lMsErroAuto := .F.
                MATA265( aCab, aItens, 3)
                If lMsErroAuto ; MostraErro() ; EndIf
            EndIf
            (cTmpAlias)->(DbSkip())
        End
        
    EndIf

    (cCabAlias)->(DbSkip())

End
oCMVVEIXX:End()

Return Nil

*************************************************
Static Function ConsultaDoc(cCabAlias,aRotBackup)
*************************************************

Local aArea        As Array 
Local aSF1Area     As Array 
Local nOpc         As Numeric
Local cAlias       As Character
Local lWhenGet     As Logical
Local lEstNfClass  As Logical

Local aRotina3  := {{"Visualizar","NfeDocVin",0,2,0,nil},;
					{"Alterar"   ,"NfeDocVin",0,4,0,nil},;
					{"Excluir"   ,"NFeDocVin",0,5,0,nil}}

Local aRotina4  := {{"Documento de Entrada","NfeDocCob",0,4,0,nil},;
					{"Documento de Saida"  ,"NfsDocCob",0,4,0,nil}}

Local aRotina2  := {{"Vincular" ,aRotina3,0,4,0,nil},;
					{"Cobertura",aRotina4,0,4,0,nil}}

//DSERTSS1-177 - submenu
Local aRotina5  := {{"Confirmação da Operação","A103Manif",0,2,0,nil},;
					{" Ciência da Operação"   ,"A103Manif",0,2,0,nil}}

Local aRotComFut := {{"Desfazimento", "A103XDesfaz", 0, 6, 0, nil}}

Local lGspInUseM := If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local lPyme      := Iif(Type("__lPyme") <> "U",__lPyme,.F.)

Private aRotDES	:=	{{	"Parametros"		,'A103DESARC(1)',0,17,0,Nil },;
					 {	"Ev. Desacordo"		,'A103DESARC(2)',0,15,0,Nil },;
					 {	"Monitor Desacordo"	,'A103DESARC(3)',0,16,0,Nil }} 


If Type("aRotina") != "A" ; aRotina := {} ; EndIf
//Inicializa aRotina para ERP/CRM ou SIGAGSP
Aadd(aRotina,{OemToAnsi("Pesquisar"  ), "AxPesqui"   , 0 , 1, 0, .F.})
Aadd(aRotina,{OemToAnsi("Visualizar" ), "A103NFiscal", 0 , 2, 0, nil})
Aadd(aRotina,{OemToAnsi("Incluir"    ), "A103NFiscal", 0 , 3, 0, nil})
Aadd(aRotina,{OemToAnsi("Classificar"), "A103NFiscal", 0 , 4, 0, nil})
Aadd(aRotina,{OemToAnsi("Excluir"    ), "A103NFiscal", 3 , 5, 0, nil})

If __lIntPFS .And. FindFunction("JAnxM103")
    Aadd(aRotina,{OemToAnsi('Anexos'), "JAnxM103", 0 , 2, 0, nil})
EndIf

If !lGspInUseM
	Aadd(aRotina,{OemToAnsi("Imprimir"), "A103Impri"  , 0 , 4, 0, nil})
	Aadd(aRotina,{OemToAnsi("Imprimir"), "A103Devol"  , 0 , 3, 0, .F.})
Endif

Aadd(aRotina,{OemToAnsi("Tracker Contábil"), "CTBC662"    , 0 , 7 , 0, .F.})
Aadd(aRotina,{OemToAnsi("Ev. Desacordo"   ), aRotDES      , 0 , 15, 0, .F.})
Aadd(aRotina,{OemToAnsi("Legenda"         ), "A103Legenda", 0 , 2 , 0, .F.})
Aadd(aRotina,{"Conhecimento"               ,"MsDocument"  , 0 , 4 , 0, nil})

If !lPyme
	//Inclusao da rotina do documento vinculado
	Aadd(aRotina,{"Doc.Vinculado"   , aRotina2, 0, 4, 0, nil})
EndIf

//Retorno do saldo contido no Armazem de Transito
Aadd(aRotina,{OemToAnsi("Transito"), 'A103RetTrf' , 0 , 3, 0, nil})

//Chamada do Rastreio de Contratos Fornecedores
Aadd(aRotina,{OemToAnsi("Rastr.Contrato"), "A103Contr", 0 , 2, 0, nil})

// Compra com entrega futura.
Aadd(aRotina, {"Entrega futura", aRotComFut, 0, 2, 0, nil})

//Manifestação do Destinatario
If FindFunction("MDeMata103")
	Aadd(aRotina,{OemToAnsi("Manifestar"), aRotina5, 0 , 2, 0, nil})
Endif

aArea       := GetArea()
aSF1Area    := SF1->(GetArea())
nOpc        := 2
cAlias      := "SF1"
lWhenGet    := .F.
lEstNfClass := .F.

If SF1->F1_TIPO == "N"
    SF1->(DbSetOrder(1))
    If SF1->(DbSeek(xFilial("SF1")+(cCabAlias)->F1_DOC+(cCabAlias)->F1_SERIE+(cCabAlias)->F1_FORNECE+(cCabAlias)->F1_LOJA+(cCabAlias)->F1_TIPO))
        nReg := SF1->(Recno())
        A103NFiscal(cAlias,nReg,nOpc,lWhenGet,lEstNfClass)
    Else
        MsgStop("Nota fiscal: " + (cCabAlias)->F1_DOC+"/"+(cCabAlias)->F1_SERIE, "Documento não encontrado")
    EndIf
Else
    MsgStop("Não é possível visulizar nota fiscal cancelada.")   
EndIf

If Type("aRotBackup") == "A" .And. Len(aRotBackup)  <> 0 ; aRotina := aClone(aRotBackup) ; EndIf

RestArea(aSF1Area)
RestArea(aArea   )

Return Nil


//---------------------------------------------------------------------
/*/{Protheus.doc} FMark

Executa a gravação do retorno da Consulta Específica.

@Param		oBrowse	- Objeto da Browse
			cReadVar	- Campo de retorno da Consulta Específica
			cChave		- Campo(s) a serem gravados no retorno da Consulta Específica
			lMult		- Indica se a tela permição selec de múltiplos registros

@Since		26/09/2022
@Version	1.0
/*/
//---------------------------------------------------------------------

Static function FMark(oBrowse)
Local cAlias	:=	oBrowse:Alias()
Local cMark	    :=	oBrowse:Mark()

If RecLock( cAlias, .F. )
    ( cAlias )->F1_OK := Iif( ( cAlias )->F1_OK == cMark, "  ", cMark )
	( cAlias )->( MsUnlock() )
EndIf  

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} FMarkAll

Inverte a indicação de seleção de todos registros do Browse.

@Param		oBrowse	->	Objeto contendo campo de seleção

@Return	Nil

/*/
//---------------------------------------------------------------------
Static Function FMarkAll( oBrowse )

Local cAlias	as character
Local cMark	    as character
Local nRecno	as numeric

cAlias	:=	oBrowse:Alias()
cMark	:=	oBrowse:Mark()
nRecno	:=	( cAlias )->( Recno() )

( cAlias )->( DBGoTop() )
While ( cAlias )->( !Eof() )

	If RecLock( cAlias, .F. )
		( cAlias )->F1_OK := Iif( alltrim(( cAlias )->F1_OK) == cMark, "  ", cMark )
		( cAlias )->( MsUnlock() ) 
	EndIf

	( cAlias )->( DBSkip() )
End

( cAlias )->( DBGoTo( nRecno ) )

oBrowse:Refresh()

Return()
