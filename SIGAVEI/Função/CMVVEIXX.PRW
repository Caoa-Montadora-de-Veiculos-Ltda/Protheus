#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} CMVVEIXX()
Processamento de devolução em lote de acordo com arquivo CSV

@author Leonardo Miranda
@since 04/08/2022
@version 1.0
@return NIL
/*/

User Function CMVVEIXX()

Local _mvRet        As Character
Local _cPath        As Character
Local _ctmp         As Character
Local nHandle       As Numeric
Local xBuffer       As Character
Local aNota         As Array
Local aNotas        As Array
Local cInNotas      As Character
Local nPos          As Numeric
Local oSay          As Object

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

_mvRet  := Alltrim(ReadVar())
_ctmp   := GetTempPath()
_oWnd   := GetWndDefault()

_cPath:= TFileDialog( "All Text files (*.csv) ",'Selecao de Arquivo',, _ctmp, .F.,)
If Empty(Alltrim(_cPath))
    MsgInfo("Arquivo não informado!")
    Return Nil
EndIf

nHandle := 0
nHandle := FT_FUse(_cPath)
If nHandle <= 0
    MsgInfo("Erro na abertura do arquivo!")
    Return Nil
Else
    aNotas  := {}
    FT_FGoTop()
    While !FT_FEOF()
        xBuffer  := FT_FReadLn()
        aNota := StrToArray(xBuffer,";")
        Aadd(aNotas,aNota)
        FT_FSKIP()
    End
    FT_FUSE()

    cInNotas := ""    
    For ny := 1 To Len(aNotas)
        aNotas[nY,5] := StrZero(Val(aNotas[nY,05]),9)
        cInNotas     += StrZero(Val(aNotas[nY,05]),9)+If(ny < Len(aNotas),";","")
    Next
    cInNotas := FormatIn(cInNotas, ";")

EndIf

/*********************************************************************************************************************************************/
//Cabeçalho
aCabCampos  := {"F2_FILIAL","D2_NFORI","D2_SERIORI","F2_CHVNFE","F2_DOC","F2_SERIE","F2_EMISSAO","F2_CLIENTE","F2_LOJA","A1_NOME","F2_VALBRUT"}
aCabStru     := {}
For nY := 1 To Len(aCabCampos)
    aTamSx3 := TamSX3(aCabCampos[nY])
    Aadd(aCabStru, {aCabCampos[nY] ,aTamSx3[03] ,aTamSx3[01] ,aTamSx3[02] })
Next

aCabCol := {}
For nY := 02 To Len(aCabStru)
    //Columas Cabeçalho
    cPictAlias := "S"+Left(aCabStru[nY][1],2)
    Aadd(aCabCol,FWBrwColumn():New())
    aCabCol[Len(aCabCol)]:SetData( &("{||"+aCabStru[nY][1]+"}") )
    aCabCol[Len(aCabCol)]:SetTitle(RetTitle(aCabStru[nY][1]))
    aCabCol[Len(aCabCol)]:SetSize(aCabStru[nY][3])
    aCabCol[Len(aCabCol)]:SetDecimal(aCabStru[nY][4])
    aCabCol[Len(aCabCol)]:SetPicture(PesqPict(cPictAlias,aCabStru[nY][1]))
Next nY

oCabTable := FWTemporaryTable():New()
oCabTable:SetFields(aCabStru)
oCabTable:AddIndex("INDEX1", {"F2_FILIAL", "F2_DOC", "F2_SERIE"} )
oCabTable:Create()
cCabAlias := oCabTable:GetAlias()

cCabTable := oCabTable:GetRealName()
cQuery := ""
cQuery += " INSERT INTO "+cCabTable+"                                                                                    "+(Chr(13)+Chr(10))
cQuery += " (F2_FILIAL,F2_DOC,F2_SERIE,F2_EMISSAO,F2_CLIENTE,F2_LOJA,A1_NOME,F2_VALBRUT,F2_CHVNFE,D_E_L_E_T_,R_E_C_N_O_) "+(Chr(13)+Chr(10))
cQuery += " SELECT  SF2.F2_FILIAL                                           F2_FILIAL   ,                                "+(Chr(13)+Chr(10))
cQuery += "         SF2.F2_DOC                                              F2_DOC      ,                                "+(Chr(13)+Chr(10))
cQuery += "         SF2.F2_SERIE                                            F2_SERIE    ,                                "+(Chr(13)+Chr(10))
cQuery += "         SF2.F2_EMISSAO                                          F2_EMISSAO  ,                                "+(Chr(13)+Chr(10))
cQuery += "         SF2.F2_CLIENTE                                          F2_CLIENTE  ,                                "+(Chr(13)+Chr(10))
cQuery += "         SF2.F2_LOJA                                             F2_LOJA     ,                                "+(Chr(13)+Chr(10))
cQuery += "         SA1.A1_NOME                                             A1_NOME     ,                                "+(Chr(13)+Chr(10))
cQuery += "         SF2.F2_VALBRUT                                          F2_VALBRUT  ,                                "+(Chr(13)+Chr(10))
cQuery += "         ' '                                                     F2_CHVNFE   ,                                "+(Chr(13)+Chr(10))
cQuery += "         ' '                                                     D_E_L_E_T_  ,                                "+(Chr(13)+Chr(10))
cQuery += "         ROW_NUMBER() OVER (ORDER BY F2_FILIAL,F2_DOC,F2_SERIE)  R_E_C_N_O_                                   "+(Chr(13)+Chr(10))
cQuery += " FROM "+RetSqlName("SF2")+" SF2                                                                               "+(Chr(13)+Chr(10))
cQuery += "         INNER JOIN                                                                                           "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SA1")+" SA1 ON  SF2.F2_CLIENTE  = SA1.A1_COD                                              "+(Chr(13)+Chr(10))
cQuery += "                                AND SF2.F2_LOJA     = SA1.A1_LOJA                                             "+(Chr(13)+Chr(10))
cQuery += "                                AND SF2.D_E_L_E_T_  = SA1.D_E_L_E_T_                                          "+(Chr(13)+Chr(10))
cQuery += " WHERE   SF2.F2_FILIAL           = '"+xFilial("SF1")+"'                                                       "+(Chr(13)+Chr(10))
cQuery += "     AND SF2.F2_DOC              IN"+cInNotas+"                                                               "+(Chr(13)+Chr(10))
cQuery += "     AND SF2.D_E_L_E_T_          = ' '                                                                        "+(Chr(13)+Chr(10))
cQuery += " ORDER BY SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE                                                               "+(Chr(13)+Chr(10))

nStatus := TCSqlExec(cQuery)
If (nStatus < 0)
    MsgStop("TCSQLError() " + TCSQLError(), "Registros Cabeçalho")
    If Select(cCabAlias) <> 0 ; (cCabAlias)->(DbCloseArea()) ; EndIf
    oCabTable:Delete()
    Return Nil
Else
    (cCabAlias)->(DbGoTop())
    While (cCabAlias)->(!Eof())
        nPos := aScan(aNotas,{|x,Y| x[5] == (cCabAlias)->F2_DOC })
        If nPos <> 0
            (cCabAlias)->(RecLock(cCabAlias,.F.))
            (cCabAlias)->D2_NFORI       := StrZero(Val(aNotas[nPos,1]),9)
            (cCabAlias)->D2_SERIORI     := aNotas[nPos,2]
            (cCabAlias)->F2_CHVNFE      := aNotas[nPos,4]
            (cCabAlias)->(MsUnlock())
        EndIf
        (cCabAlias)->(DbSkip())
    End
EndIf
/*********************************************************************************************************************************************/

/*********************************************************************************************************************************************/
//Itens
aIteCampos  := {"D2_FILIAL","D2_DOC"    ,"D2_SERIE" ,"D2_ITEM"  ,"D2_COD"    ,"B1_DESC","D2_NUMSERI","D2_UM"    ,"D2_QUANT"  ,"D2_PRCVEN",;
                "D2_TOTAL" ,"D2_BASEIPI","D2_IPI"   ,"D2_VALIPI","D2_BASEICM","D2_PICM","D2_VALICM" ,"D2_BRICMS","D2_ALIQSOL","D2_ICMSRET"}
aIteStru     := {}
For nY := 1 To Len(aIteCampos)
    aTamSx3 := TamSX3(aIteCampos[nY])
    Aadd(aIteStru, {aIteCampos[nY] ,aTamSx3[03] ,aTamSx3[01] ,aTamSx3[02] })
Next

aIteCol := {}
For nY := 04 To Len(aIteStru)
    //Columas Itens
    cPictAlias := "S"+Left(aIteStru[nY][1],2)
    Aadd(aIteCol,FWBrwColumn():New())
    aIteCol[Len(aIteCol)]:SetData( &("{||"+aIteStru[nY][1]+"}") )
    aIteCol[Len(aIteCol)]:SetTitle(RetTitle(aIteStru[nY][1]))
    aIteCol[Len(aIteCol)]:SetSize(aIteStru[nY][3])
    aIteCol[Len(aIteCol)]:SetDecimal(aIteStru[nY][4])
    aIteCol[Len(aIteCol)]:SetPicture(PesqPict(cPictAlias,aIteStru[nY][1]))
Next nY

oIteTable := FWTemporaryTable():New()
oIteTable:SetFields(aIteStru)
oIteTable:AddIndex("INDEX1", {"D2_FILIAL", "D2_DOC", "D2_SERIE", "D2_ITEM"} )
oIteTable:Create()
cIteAlias := oIteTable:GetAlias()

cIteTable := oIteTable:GetRealName()
cQuery := ""
cQuery += " INSERT INTO "+cIteTable+"                                                                                  "+(Chr(13)+Chr(10))
cQuery += " (D2_FILIAL ,D2_DOC    ,D2_SERIE ,D2_ITEM  ,D2_COD    ,B1_DESC,D2_NUMSERI,D2_UM    ,D2_QUANT  ,D2_PRCVEN,   "+(Chr(13)+Chr(10))
cQuery += "  D2_TOTAL  ,D2_BASEIPI,D2_IPI   ,D2_VALIPI,D2_BASEICM,D2_PICM,D2_VALICM ,D2_BRICMS,D2_ALIQSOL,D2_ICMSRET,  "+(Chr(13)+Chr(10))
cQuery += "  D_E_L_E_T_,R_E_C_N_O_)                                                                                    "+(Chr(13)+Chr(10))
cQuery += " SELECT  SD2.D2_FILIAL                                                                  AS  D2_FILIAL     , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_DOC                                                                     AS  D2_DOC        , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_SERIE                                                                   AS  D2_SERIE      , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_ITEM                                                                    AS  D2_ITEM       , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_COD                                                                     AS  D2_COD        , "+(Chr(13)+Chr(10))
cQuery += "         SB1.B1_DESC                                                                    AS  B1_DESC       , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_NUMSERI                                                                 AS  D2_NUMSERI    , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_UM                                                                      AS  D2_UM         , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_QUANT                                                                   AS  D2_QUANT      , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_PRCVEN                                                                  AS  D2_PRCVEN     , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_TOTAL                                                                   AS  D2_TOTAL      , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_BASEIPI                                                                 AS  D2_BASEIPI    , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_IPI                                                                     AS  D2_IPI        , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_VALIPI                                                                  AS  D2_VALIPI     , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_BASEICM                                                                 AS  D2_BASEICM    , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_PICM                                                                    AS  D2_PICM       , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_VALICM                                                                  AS  D2_VALICM     , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_BRICMS                                                                  AS  D2_BRICMS     , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_ALIQSOL                                                                 AS  D2_ALIQSOL    , "+(Chr(13)+Chr(10))
cQuery += "         SD2.D2_ICMSRET                                                                 AS  D2_ICMSRET    , "+(Chr(13)+Chr(10))
cQuery += "         ' '                                                                            AS  D_E_L_E_T_    , "+(Chr(13)+Chr(10))
cQuery += "         ROW_NUMBER() OVER (ORDER BY SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_ITEM) AS  R_E_C_N_O_      "+(Chr(13)+Chr(10))
cQuery += " FROM "+RetSqlName("SD2")+" SD2                                                                             "+(Chr(13)+Chr(10))
cQuery += "         INNER JOIN                                                                                         "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SB1")+" SB1 ON  SD2.D2_COD      = SB1.B1_COD                                            "+(Chr(13)+Chr(10))
cQuery += "                                AND SD2.D_E_L_E_T_  = SB1.D_E_L_E_T_                                        "+(Chr(13)+Chr(10))
cQuery += " WHERE   SD2.D2_FILIAL           = '"+xFilial("SD2")+"'                                                     "+(Chr(13)+Chr(10))
cQuery += "     AND SD2.D2_DOC              IN"+cInNotas+"                                                               "+(Chr(13)+Chr(10))
cQuery += "  ORDER BY SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_ITEM"+(Chr(13)+Chr(10))

nStatus := TCSqlExec(cQuery)
If (nStatus < 0)
    MsgStop("TCSQLError() " + TCSQLError(), "Registros Itens")
    If Select(cIteAlias) <> 0 ; (cIteAlias)->(DbCloseArea()) ; EndIf
    oIteTable:Delete()
    Return Nil
EndIf

/*********************************************************************************************************************************************/

aSizeAut  := MsAdvSize(.f.)
oCMVVEIXX := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],"Notas Fiscais para Devolução",,,,128,,,,,.T.)

oTPanel01 := TPanel():New(0,0,"",oCMVVEIXX,NIL,.T.,.F.,NIL,NIL,100,(oCMVVEIXX:nClientHeight/4)-10,.F.,.F.)
oTPanel01:Align := CONTROL_ALIGN_TOP

oTPanel02 := TPanel():New(0,0,"",oCMVVEIXX,NIL,.T.,.F.,NIL,NIL,100,(oCMVVEIXX:nClientHeight/4)-10,.F.,.F.)
oTPanel02:Align := CONTROL_ALIGN_BOTTOM 

oBrwCab := FWMBrowse():New()
oBrwCab:SetAlias(cCabAlias)
oBrwCab:SetOwner(oTPanel01)
oBrwCab:SetDescription("Cabeçalho")
oBrwCab:SetTemporary(.T.)
oBrwCab:SetUseFilter(.F.)
oBrwCab:OptionReport(.F.)
oBrwCab:SetColumns(aCabCol)
oBrwCab:DisableDetails()
oBrwCab:DisableReport()
oBrwCab:AddButton("Devolver Notas"	, { || FWMsgRun(, {|oSay| DevolveDocs(cCabAlias,cIteAlias,oSay) }, "Devolução", "Processando devolulções de notas") },,,, .F., 2 )
oBrwCab:AddButton("Visualiza Nota"  , { || MsgRun('Visualizando Nota'      ,'Consulta' ,{|| ConsultaDoc(cCabAlias          ) }) },,,, .F., 2 )
oBrwCab:Activate()
oBrwCab:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

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
oRelac:AddRelation( oBrwCab , oBrwIte , { { "D2_FILIAL" , "F2_FILIAL" } , { "D2_DOC" , "F2_DOC" } , { "D2_SERIE" , "F2_SERIE" } })
oRelac:Activate()

oCMVVEIXX:Activate()

If Select(cCabAlias) <> 0 ; (cCabAlias)->(DbCloseArea()) ; EndIf
If Select(cIteAlias) <> 0 ; (cIteAlias)->(DbCloseArea()) ; EndIf

oCabTable:Delete()
oIteTable:Delete()

Return Nil

Static Function DevolveDocs(cCabAlias,cIteAlias,oSay)

Local aArea         As Array
Local aCab          As Array
Local aItens        As Array
Local axItem        As Array
Local cMensagem     As Character
Local cBkpFunName   As Character
Local nBkpModulo    As Numeric
Local aBkpARotina   As Array
Local aBkpACols     As Array
Local aBkpAHeader   As Array

Private lMsHelpAuto As Logical
Private lMsErroAuto As Logical

aArea       := GetArea()

(cCabAlias)->(DbGoTop())
While (cCabAlias)->(!Eof())

    oSay:SetText("Processando Nota Fiscal: " + (cCabAlias)->D2_NFORI+"/"+(cCabAlias)->D2_SERIORI+" ...")
    
    SF2->(DbSetOrder(1))
    SF2->(DbSeek(xFilial("SF2")+(cCabAlias)->F2_DOC+(cCabAlias)->F2_SERIE))

    aCab        := {}
    cMensagem   := "DEV REF A NF "+Alltrim(SF2->F2_DOC)+"/"+Alltrim(SF2->F2_SERIE)+" DE "+Dtoc(SF2->F2_EMISSAO)+" SOLICIT : "+__cUserId

	Aadd(aCab,{"VVF_FORPRO"  ,"0"                      ,Nil}) ; Aadd(aCab,{"VVF_OPEMOV"  ,"5"                      ,Nil})
	Aadd(aCab,{"VVF_DATMOV"  ,dDataBase                ,Nil}) ; Aadd(aCab,{"VVF_DATEMI"  ,dDataBase                ,Nil})
    Aadd(aCab,{"VVF_CLIFOR"  ,"C"                      ,Nil}) ; Aadd(aCab,{"VVF_DATFAB"  ,dDataBase                ,Nil})
    Aadd(aCab,{"VVF_CODFOR"  ,SF2->F2_CLIENTE          ,Nil}) ; Aadd(aCab,{"VVF_LOJA"    ,SF2->F2_LOJA             ,Nil})
    Aadd(aCab,{"VVF_FORPAG"  ,SF2->F2_COND             ,Nil}) ; Aadd(aCab,{"VVF_NATURE"	 ,"1190"	               ,Nil})
    Aadd(aCab,{"VVF_NUMNFI"  ,(cCabAlias)->D2_NFORI    ,Nil}) ; Aadd(aCab,{"VVF_SERNFI"  ,(cCabAlias)->D2_SERIORI  ,Nil})
    Aadd(aCab,{"VVF_SITNFI"  ,"1"      		           ,Nil}) ; Aadd(aCab,{"VVF_ESPECI"  ,"SPED"   	               ,Nil})
    Aadd(aCab,{"VVF_ESPEC1"  ,SF2->F2_ESPECI1          ,Nil}) ; Aadd(aCab,{"VVF_VOLUM1"  ,SF2->F2_VOLUME1          ,Nil})
    Aadd(aCab,{"VVF_TIPO"    ,"D"                      ,Nil}) ; Aadd(aCab,{"VVF_MENNOT"  ,cMensagem                ,Nil})
    Aadd(aCab,{"VVF_TIPDOC"  ,"1"                      ,Nil}) ; Aadd(aCab,{"VVF_DEVMER"  ,"N"                      ,Nil})
    Aadd(aCab,{"VVF_MOEDA"   ,1                        ,Nil}) ; Aadd(aCab,{"VVF_TXMODE"  ,1.00                     ,Nil})
    Aadd(aCab,{"VVF_TPFRET"  ,"C"                      ,Nil}) ; Aadd(aCab,{"VVF_CHVNFE"  ,(cCabAlias)->F2_CHVNFE   ,Nil})

    aItens := {}
    SD2->(DbSetOrder(3))
    SD2->(DbSeek(xFilial("SD2")+(cCabAlias)->F2_DOC+(cCabAlias)->F2_SERIE+(cCabAlias)->F2_CLIENTE+(cCabAlias)->F2_LOJA))
    While SD2->(!Eof()) .And. SD2->D2_DOC     == (cCabAlias)->F2_DOC    ;
                        .And. SD2->D2_SERIE   == (cCabAlias)->F2_SERIE  ;
                        .And. SD2->D2_CLIENTE == (cCabAlias)->F2_CLIENTE;
                        .And. SD2->D2_LOJA    == (cCabAlias)->F2_LOJA

		axItem:= {}
		Aadd(axItem,{"VVG_FILIAL"  , SD2->D2_FILIAL  ,Nil}) ; Aadd(axItem,{"VVG_CHASSI"  , SD2->D2_NUMSERI ,Nil})
		Aadd(axItem,{"VVG_CODTES"  , "010"           ,Nil}) ; Aadd(axItem,{"VVG_ESTVEI"  , "0"             ,Nil})
		Aadd(axItem,{"VVG_LOCPAD"  , SD2->D2_LOCAL   ,Nil}) ; Aadd(axItem,{"VVG_SITTRIB" , SD2->D2_CLASFIS ,Nil})
		Aadd(axItem,{"VVG_VALUNI"  , SD2->D2_PRCVEN  ,Nil}) ; Aadd(axItem,{"VVG_VBAIPI"  , SD2->D2_BASEIPI ,Nil})
		Aadd(axItem,{"VVG_ALIIPI"  , SD2->D2_IPI     ,Nil}) ; Aadd(axItem,{"VVG_VALIPI"  , SD2->D2_VALIPI  ,Nil})
		Aadd(axItem,{"VVG_VBAICM"  , SD2->D2_BASEICM ,Nil}) ; Aadd(axItem,{"VVG_ALIICM"  , SD2->D2_PICM    ,Nil})
		Aadd(axItem,{"VVG_ICMCOM"  , SD2->D2_VALICM  ,Nil}) ; Aadd(axItem,{"VVG_VCNVEI"  , SD2->D2_TOTAL   ,Nil})
		Aadd(axItem,{"VVG_NFORI"   , SD2->D2_DOC     ,Nil}) ; Aadd(axItem,{"VVG_SERORI"  , SD2->D2_SERIE   ,Nil})
        Aadd(axItem,{"VVG_ITEORI"  , SD2->D2_ITEM    ,Nil})
	    Aadd(axItem,{"VVG_VBICRT"  , SD2->D2_BRICMS  ,Nil}) ; Aadd(axItem,{"VVG_ICMRET"  , SD2->D2_ICMSRET ,Nil})
        Aadd(aItens,axItem)
    
        SD2->(DbSkip())
    End

	cBkpFunName := FunName()
	nBkpModulo  := nModulo
	SetFunName('VEIXA002')
	nModulo := 11

    If Type("aRotina") == "A" ; aBkpARotina := aClone(aRotina) ; aRotina := {} ; EndIf
    If Type("aCols"  ) == "A" ; aBkpACols   := aClone(aCols  ) ; aCols   := {} ; EndIf
    If Type("aHeader") == "A" ; aBkpAHeader := aClone(aHeader) ; aHeader := {} ; EndIf

	lMsHelpAuto := .T.
	lMsErroAuto := .F.
    aCols       := {}
    aHeader     := {}
    If Len(aCab) <> 0 .And. Len(aItens) <> 0
	    MSExecAuto({ |a,b,c,d,e,f,g,h,i| ;
				    VEIXX000(a   ,b     ,c  ,d ,e   ,f ,g   ,h ,i   )},;
				             aCab,aItens,{} ,3 ,"5" ,  ,.f. ,  ,"1" )
        If lMsErroAuto ; MostraErro() ; EndIf
    ElseIf Len(aCab) == 0
        MsgInfo("Arquivo de cabeçalho não preenchido!")
    ElseIf Len(aItens) == 0
        MsgInfo("Arquivo de itens não preenchido!")
    EndIf

	SetFunName(cBkpFunName)
	nModulo := nBkpModulo

    If Type("aBkpARotina") == "A" .And. Len(aBkpARotina)  <> 0 ; aRotina := aClone(aBkpARotina) ; EndIf
    If Type("aBkpACols"  ) == "A" .And. Len(aBkpACols  )  <> 0 ; aCols   := aClone(aBkpACols  ) ; EndIf
    If Type("aBkpAHeader") == "A" .And. Len(aBkpAHeader)  <> 0 ; aHeader := aClone(aBkpAHeader) ; EndIf

    (cCabAlias)->(DbSkip())
End

oCMVVEIXX:End()

Return Nil

Static Function ConsultaDoc(cCabAlias)

Local aArea        As Array 
Local aSF2Area     As Array 
Local nOpc         As Numeric
Local cAlias       As Character

aArea    := GetArea()
aSF2Area := SF2->(GetArea())
nOpc     := 2
cAlias   := "SF2"

SF2->(DbSetOrder(1))
If SF2->(DbSeek(xFilial("SF2")+(cCabAlias)->F2_DOC+(cCabAlias)->F2_SERIE))
    nReg := SF2->(Recno())
    Mc090Visual(cAlias,nReg,nOpc)
Else
    MsgStop("Nota fiscal: " + (cCabAlias)->F2_DOC+"/"+(cCabAlias)->F2_SERIE, "Consulta Nota")
EndIf

RestArea(aSF2Area)
RestArea(aArea   )

Return Nil