#Include 'Protheus.Ch'
#Include 'RwMake.Ch'
#Include 'Font.Ch'
#Include 'Colors.Ch'
#Include "TopConn.Ch"
#Include "TbiConn.CH"

Static cMarca 	 := GetMark()
Static CrLf      := (Chr(13)+Chr(10))
Static lDebug    :=  .F.
/*
=======================================================================================
Programa.:              ZFATF019 
Autor....:              Leonardo Miranda
Data.....:              03/03/2022
Descricao / Objetivo:   Portal Comercial   
=======================================================================================
*/

************************
User Function ZFATF019()
************************

Private oSay    As Object
Private oDlg01  As Dialog
Private oGrp01  As Dialog
Private oBtn01  As Dialog
Private oBtn03  As Dialog
Private oBtn04  As Dialog
Private aRotina As Array

aRotina:= {}
oDlg01 := MSDialog():New( 080,0-4,639,1274,"Portal Comercial",,,.F.,,,,,,.T.,,,.T. )
oGrp01 := TGroup():New( 008,008,268,628,"",oDlg01,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn01 := TButton():New( 020,016,"Faturamento Atacado"   ,oGrp01,{|| FWMsgRun(, {|oSay| fLibPed( oSay )  }, "Faturamento"  , "Processando pedidos"     )} ,068,032,,,,.T.,,"",,,,.F. )
oBtn03 := TButton():New( 020,094,"Cancelar Notas Fiscais",oGrp01,{|| FWMsgRun(, {|oSay| fCanNotas( oSay )}, "Cancelando NF", "Processando Cancelamento")} ,068,032,,,,.T.,,"",,,,.F. )
oBtn04 := TButton():New( 020,171,"Devolver Notas Fiscais",oGrp01,{|| fDevNotas()}                                                                         ,068,032,,,,.T.,,"",,,,.F. )
oBtn04 := TButton():New( 020,248,"Transmissão de Notas"  ,oGrp01,{|| SPEDNFe()}                                                                           ,068,032,,,,.T.,,"",,,,.F. )
//oBtn04 := TButton():New( 020,325,"Incluir Pedido Venda"  ,oGrp01,{|| fVisuPed("SC5",aRotina,3,Nil,Nil,Nil)}                                               ,068,032,,,,.T.,,"",,,,.F. )
oBtn04 := TButton():New( 020,325,"Pedidos Venda"         ,oGrp01,{|| MATA410()}                                                                           ,068,032,,,,.T.,,"",,,,.F. )

oDlg01:Activate(,,,.T.)

Return(Nil)

/*
=======================================================================================
Programa.:              
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

*****************************
Static Function fLibPed(oSay)
*****************************

Local bRet          As Logical
Local lOk           As Logical
Local aRet          As Array
Local cQryAlias     As Character
Local nLinha        As Numeric
Local nColuna       As Numeric

Local oFWL          As Object
Local oSize1        As Object
Local oSize2        As Object
Local cCabTable     As Character
Local cTipCpo       As Character
Local cIteTable     As Character
Local cOrderTab     As Character
Local aCabStru      As Array
Local aCabCol       As Array
Local aCords        As Array

Local cPictAlias    As Character
Local cQuery        As Character
Local nY            As Numeric
Local nStatus       As Numeric
Local aTamSx3       As Array
Local aValidCmp     As Array

Private cCabAlias   As Character
Private cIteAlias   As Character
Private aParamBox   As Array
Private aBrwCli     As Array
Private aBrwPrd     As Array
Private aBrwTot     As Array
Private aHeaderAux  As Array
Private aCols       As Array

Private oNwFat001   As Object
Private oPnlWnd1    As Object
Private oPnlWnd2    As Object
Private oPnlWnd3    As Object
Private oPnlWnd4    As Object
Private oModel      As Object
Private oBrwCab     As Object
Private oCabTable   As Object
Private oTBrwsCli   As Object
Private oTBrwsPrd   As Object
Private oTBrwsTot   As Object
Private aCabCampos  As Array
Private aCamBkp     As Array
Private bRefresh := {||.t.} //Bloco de Codigo para previnir erro de Gatilho nas chamadas das rotina padrão do sistema 
//u_ZVEIF001()
//u_ZFATR004()

bRet        := .F.
lOk         := .T.
aRet        := {}
aParamBox   := {}
aRotina     := {}
aCords      := FWGetDialogSize( oMainWnd )
nColuna     := 1
nLinha      := 1
aCamBkp     := {}

Aadd(aParamBox, {1, "Cliente De"          ,Space(TamSx3("C5_CLIENTE")[01]), "@!",,"SA1",, 050	, .F.	})
Aadd(aParamBox, {1, "Loja De"             ,Space(TamSx3("C5_LOJACLI")[01]), "@!",,     ,, 020	, .F.	})
Aadd(aParamBox, {1, "Cliente Ate"         ,Space(TamSx3("C5_CLIENTE")[01]), "@!",,"SA1",, 050	, .F.	})
Aadd(aParamBox, {1, "Loja Ate"            ,Space(TamSx3("C5_LOJACLI")[01]), "@!",,     ,, 020	, .F.	})
Aadd(aParamBox, {1, "Produto De"          ,Space(TamSx3("C6_PRODUTO")[01]), "@!",,"SB1",, 090	, .F.	})
Aadd(aParamBox, {1, "Produto Ate"         ,Space(TamSx3("C6_PRODUTO")[01]), "@!",,"SB1",, 090	, .F.	})
Aadd(aParamBox, {1, "Tipo de Cliente"     ,Space(TamSx3("C5_CLIENTE")[01]), "@!",,     ,, 020	, .F.	})
Aadd(aParamBox, {1, "Pedido Autoware De"  ,Space(TamSx3("C6_PEDCLI" )[01]), "@!",,     ,, 050	, .F.	})
Aadd(aParamBox, {1, "Pedido Autoware Ate" ,Space(TamSx3("C6_PEDCLI" )[01]), "@!",,     ,, 050	, .F.	})
Aadd(aParamBox, {1, "Marca De"            ,Space(TamSx3("C6_XCODMAR")[01]), "@!",,"VE1",, 040	, .F.	})
Aadd(aParamBox, {1, "Marca Ate"           ,Space(TamSx3("C6_XCODMAR")[01]), "@!",,"VE1",, 040	, .F.	})
Aadd(aParamBox, {1, "Grupo do Modelo De"  ,Space(TamSx3("C6_XGRPMOD")[01]), "@!",,"VVR",, 040	, .F.	})
Aadd(aParamBox, {1, "Grupo do Modelo Ate" ,Space(TamSx3("C6_XGRPMOD")[01]), "@!",,"VVR",, 040	, .F.	})
Aadd(aParamBox, {1, "Modelo De"           ,Space(TamSx3("C6_XMODVEI")[01]), "@!",,"VV2",, 040	, .F.	})
Aadd(aParamBox, {1, "Modelo Ate"          ,Space(TamSx3("C6_XMODVEI")[01]), "@!",,"VV2",, 040	, .F.	})
Aadd(aParamBox, {1, "Segmento De"         ,Space(TamSx3("C6_XSEGMOD")[01]), "@!",,     ,, 040	, .F.	})
Aadd(aParamBox, {1, "Segmento Ate"        ,Space(TamSx3("C6_XSEGMOD")[01]), "@!",,     ,, 040	, .F.	})
Aadd(aParamBox, {1, "Ano Fabr/Modelo De"  ,Space(TamSx3("C6_XFABMOD")[01]), "@!",,     ,, 050	, .F.	})
Aadd(aParamBox, {1, "Ano Fabr/Modelo Ate" ,Space(TamSx3("C6_XFABMOD")[01]), "@!",,     ,, 050	, .F.	})
Aadd(aParamBox, {1, "Cor Interna De"      ,Space(TamSx3("C6_XCORINT")[01]), "@!",,     ,, 040	, .F.	})
Aadd(aParamBox, {1, "Cor Interna Ate"     ,Space(TamSx3("C6_XCORINT")[01]), "@!",,     ,, 040	, .F.	})
Aadd(aParamBox, {1, "Cor Externa De"      ,Space(TamSx3("C6_XCOREXT")[01]), "@!",,     ,, 040	, .F.	})
Aadd(aParamBox, {1, "Cor Externa Ate"     ,Space(TamSx3("C6_XCOREXT")[01]), "@!",,     ,, 040	, .F.	})

bRet := ParamBox(aParambox, "Parametros para seleção dos dados"	, @aRet, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .T. /*lUserSave*/)
If !bRet
    ApMsgStop("Rotina cancelada!", "Pedidos Título")
    Return(.F.)
EndIf

/*********************************************************************************************************************************************/
//Cabeçalho
aCabCampos  := {"C6_OK"     ,"CC_STATUS" ,"C6_FILIAL" ,"C6_NUM"    ,"C6_PEDCLI" ,"C5_EMISSAO","C5_CLIENTE","C5_LOJACLI",;
                "A1_NOME"   ,"C5_CONDPAG","C5_NATUREZ","C5_XMENSER","C6_ITEM"   ,"C6_PRODUTO","B1_DESC"   ,"C6_LOCAL"  ,;
                "C6_CHASSI" ,"C6_NUMSERI","C6_LOCALIZ","C6_XCODMAR","C6_XDESMAR","C6_XGRPMOD","C6_XDGRMOD","C6_XMODVEI",;
                "C6_XDESMOD","C6_XSEGMOD","C6_XDESSEG","C6_XFABMOD","C6_XCORINT","C6_XCOREXT","C6_QTDVEN" ,"C6_PRCVEN" ,;
                "C6_VALOR"  ,"C6_OPER"   ,"C6_TES"    ,"C6_XVLRVDA","C6_PRUNIT" ,"C6_XPRCTAB","C6_XVLRPRD","C6_XVLRMVT",;
                "C6_XBASST" ,"C9_SEQUEN" ,"C9_NFISCAL","C9_SERIENF","C5_XTIPVEN","VRJ_PEDIDO","VRJ_STATUS"}

aValidCmp   := {{ "C5_CONDPAG" , "{ || fVldCampo( cCabAlias , oSay , cCabTable , oCabTable)}" },;
                { "C5_NATUREZ" , "{ || fVldCampo( cCabAlias , oSay , cCabTable , oCabTable)}" },;
                { "C5_XMENSER" , "{ || fVldCampo( cCabAlias , oSay , cCabTable , oCabTable)}" },;
                { "C6_NUMSERI" , "{ || fVldCampo( cCabAlias , oSay , cCabTable , oCabTable)}" },;
                { "C6_OPER"    , "{ || fVldCampo( cCabAlias , oSay , cCabTable , oCabTable)}" },;
                { "C6_TES"     , "{ || fVldCampo( cCabAlias , oSay , cCabTable , oCabTable)}" },;
                { "C6_LOCALIZ" , "{ || fVldCampo( cCabAlias , oSay , cCabTable , oCabTable)}" },;
                { "C6_XVLRPRD" , "{ || fVldCampo( cCabAlias , oSay , cCabTable , oCabTable)}" },; 
                { "C6_XVLRMVT" , "{ || fVldCampo( cCabAlias , oSay , cCabTable , oCabTable)}" }} 

aCabStru    := {}

For nY := 1 To Len(aCabCampos)
    aTamSx3 := TamSX3(aCabCampos[nY])
    Aadd(aCabStru, {aCabCampos[nY] ,aTamSx3[03] ,aTamSx3[01] ,aTamSx3[02] })
Next nY

Aadd(aCabStru, {"LUPD"  ,"C" ,1 ,0 })
Aadd(aCabStru, {"LINHA" ,"N" ,5 ,0 })
aCabCol := {}

For nY := 02 To Len(aCabStru)

    //Columas Cabeçalho
    If !aCabStru[nY][1] $ "C6_FILIAL|CC_STATUS|C9_SEQUEN|C9_NFISCAL|C9_SERIENF|C6_PRUNIT|C6_XGRPMOD|C6_XDGRMOD|C6_XCORINT|C6_XCOREXT|C5_XTIPVEN|C6_NUMSERI|C5_XMENSER|VRJ_PEDIDO|VRJ_STATUS|LUPD|LINHA"

        cTipCpo    := GetSx3Cache(aCabStru[nY][1], "X3_TIPO" )
        cPictAlias := "S"+Left(aCabStru[nY][1],2)
        
        Aadd(aCabCol,FWBrwColumn():New())
        
        aCabCol[Len(aCabCol)]:SetData( &("{||"+aCabStru[nY][1]+"}") )
        aCabCol[Len(aCabCol)]:SetTitle(RetTitle(aCabStru[nY][1]))
        aCabCol[Len(aCabCol)]:SetSize(aCabStru[nY][3])
        aCabCol[Len(aCabCol)]:SetAlign( IIf( cTipCpo == "N", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT ) )
        aCabCol[Len(aCabCol)]:SetDecimal(aCabStru[nY][4])
        aCabCol[Len(aCabCol)]:SetPicture(PesqPict(cPictAlias,aCabStru[nY][1]))

        If "C6_NUM"   <> Substr(Alltrim(aCabStru[nY][1]),1,Len(Alltrim(aCabStru[nY][1]))) .And. ;
           "C6_LOCAL" <> Substr(Alltrim(aCabStru[nY][1]),1,Len(Alltrim(aCabStru[nY][1]))) .And. ;
            aCabStru[nY][1] $ "C5_CONDPAG|C5_NATUREZ|C5_XMENSER|C6_NUMSERI|C6_LOCALIZ|C6_TES|C6_XVLRPRD|C6_OPER|C6_XVLRMVT"

            If Substr(Alltrim(aCabStru[nY][1]),1,Len(Alltrim(aCabStru[nY][1]))) <> "C6_NUMSERI"
                aCabCol[Len(aCabCol)]:SetEdit(.T.)
            Endif

            aCabCol[Len(aCabCol)]:SetReadVar(aCabStru[nY][1])
            aCabCol[Len(aCabCol)]:SetValid((&(aValidCmp[aScan(aValidCmp,{|x| Alltrim(x[1]) == aCabStru[nY][1] }),2])))

        EndIf
    EndIf
Next nY

oCabTable := FWTemporaryTable():New()
oCabTable:SetFields(aCabStru)
oCabTable:AddIndex("INDEX1", {"C6_FILIAL","C6_PEDCLI","C6_ITEM","C5_CLIENTE", "C5_LOJACLI", "C6_PRODUTO"} )
oCabTable:Create()

aHeaderAux := aClone(oCabTable:oStruct:aFields)

cCabAlias := oCabTable:GetAlias()

cCabTable := oCabTable:GetRealName()
cOrderTab := "SC6.C6_FILIAL,SC6.C6_PEDCLI,SC6.C6_ITEM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC6.C6_PRODUTO"
cQuery := ""
cQuery += " INSERT INTO " + cCabTable + " "
cQuery += CrLf + " ("

For nY := 1 To Len(aCabCampos)

    If Upper(Alltrim(aCabCampos[nY])) <> "C9_SEQUEN"  .And. Upper(Alltrim(aCabCampos[nY])) <> "C9_NFISCAL" .And.;
       Upper(Alltrim(aCabCampos[nY])) <> "C9_SERIENF" .And. Upper(Alltrim(aCabCampos[nY])) <> "C5_XMENSER"
    
       cQuery += aCabCampos[nY]+","
    
    EndIf

Next nY

cQuery += CrLf + " LUPD,LINHA,D_E_L_E_T_,R_E_C_N_O_) "
cQuery += CrLf + " SELECT '  ' C6_OK    , "
cQuery += CrLf + " ' '         C6_STATUS, "

For nY := 1 To Len(aCabCampos)

    If  Upper(Alltrim(aCabCampos[nY])) <> "C6_OK"      .And. Upper(Alltrim(aCabCampos[nY])) <> "CC_STATUS"  .And.;
        Upper(Alltrim(aCabCampos[nY])) <> "C9_SEQUEN"  .And. Upper(Alltrim(aCabCampos[nY])) <> "C9_NFISCAL" .And.;
        Upper(Alltrim(aCabCampos[nY])) <> "C9_SERIENF" .And. Upper(Alltrim(aCabCampos[nY])) <> "C5_XMENSER" .And.;
        Upper(Alltrim(aCabCampos[nY])) <> "VRJ_STATUS" .And. Upper(Alltrim(aCabCampos[nY])) <> "LUPD"

        If Left(aCabCampos[nY],3) == "C6_" ; cQryAlias := "SC6." ; EndIf
        If Left(aCabCampos[nY],3) == "C5_" ; cQryAlias := "SC5." ; EndIf
        If Left(aCabCampos[nY],3) == "A1_" ; cQryAlias := "SA1." ; EndIf
        If Left(aCabCampos[nY],3) == "B1_" ; cQryAlias := "SB1." ; EndIf
        If Left(aCabCampos[nY],3) == "F4_" ; cQryAlias := "SF4." ; EndIf
        If Left(aCabCampos[nY],3) == "VRJ" ; cQryAlias := "VRJ." ; EndIf
        
        cQuery += CrLf + " " + (cQryAlias+aCabCampos[nY]) + ", "

    EndIf

Next nY
//cQuery += CrLf + "      VRJ.VRJ_PEDIDO, 
cQuery += CrLf + " 	      VRJ.VRJ_STATUS as VRJ_STATUS  ,'F' as LUPD , "
cQuery += CrLf + "        ROW_NUMBER() OVER (ORDER BY " + cOrderTab + " )  LINHA, "
cQuery += CrLf + "        ' ' as  D_E_L_E_T_  , "
cQuery += CrLf + "        ROW_NUMBER() OVER (ORDER BY " + cOrderTab + " )  R_E_C_N_O_ "
cQuery += CrLf + " FROM " + RetSqlName("SC6") + " SC6 "

cQuery += CrLf + "      INNER JOIN " + RetSqlName("SC5") + " SC5 
cQuery += CrLf + "              ON  SC5.C5_FILIAL  = '" + xFilial("SC5") + "' "
cQuery += CrLf + "              AND SC5.C5_NUM     = SC6.C6_NUM "
cQuery += CrLf + "              AND SC5.C5_CLIENTE = SC6.C6_CLI "
cQuery += CrLf + "              AND SC5.C5_LOJACLI = SC6.C6_LOJA "
cQuery += CrLf + "              AND SC5.D_E_L_E_T_ = ' ' "

cQuery += CrLf + "       INNER JOIN " + RetSqlName("VRJ") + " VRJ "
cQuery += CrLf + "              ON  VRJ.VRJ_FILIAL = '" + xFilial("VRJ") + "' "
cQuery += CrLf + "              AND VRJ.VRJ_PEDCOM = SC6.C6_PEDCLI "
cQuery += CrLf + "              AND VRJ.VRJ_STATUS in ('A','F') "
cQuery += CrLf + "              AND VRJ.D_E_L_E_T_ = ' ' "

cQuery += CrLf + "      INNER JOIN " + RetSqlName("VRK") + " VRK "
cQuery += CrLf + "              ON  VRK.VRK_FILIAL = '" + xFilial("VRK") + "' "
cQuery += CrLf + "              AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO "
cQuery += CrLf + "              AND VRK.VRK_ITEPED = LPad(SC6.C6_ITEM,3,'0') "
cQuery += CrLf + "              AND VRK.VRK_ITETRA = ' ' "
cQuery += CrLf + "              AND VRK.D_E_L_E_T_ = ' ' "

cQuery += CrLf + "      INNER JOIN " + RetSqlName("SA1") + " SA1 "
cQuery += CrLf + "              ON  SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "
cQuery += CrLf + "              AND SA1.A1_COD     = SC6.C6_CLI "
cQuery += CrLf + "              AND SA1.A1_LOJA    = SC6.C6_LOJA "
cQuery += CrLf + "              AND SA1.D_E_L_E_T_ = ' ' "

cQuery += CrLf + "      INNER JOIN " + RetSqlName("SB1") + " SB1 "
cQuery += CrLf + "              ON  SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
cQuery += CrLf + "              AND SB1.B1_COD     = SC6.C6_PRODUTO "
cQuery += CrLf + "              AND SB1.B1_GRUPO   = 'VEIA' "
cQuery += CrLf + "              AND SB1.D_E_L_E_T_ = ' ' "

cQuery += CrLf + "      INNER JOIN " + RetSqlName("SF4") + " SF4 "
cQuery += CrLf + "              ON  SF4.F4_FILIAL  =  '" + xFilial("SF4") + "' "
cQuery += CrLf + "              AND SF4.F4_CODIGO  = SC6.C6_TES "
cQuery += CrLf + "              AND SF4.F4_DUPLIC  = 'S' "
cQuery += CrLf + "              AND SF4.D_E_L_E_T_ = ' ' "

cQuery += CrLf + " WHERE   SC6.C6_FILIAL    = '" + xFilial("SC6") + "' "
cQuery += CrLf + "     AND SC6.C6_CLI       BETWEEN '" + aRet[01] + "' AND '" + aRet[03] + "' "
cQuery += CrLf + "     AND SC6.C6_LOJA      BETWEEN '" + aRet[02] + "' AND '" + aRet[04] + "' "
cQuery += CrLf + "     AND SC6.C6_PRODUTO   BETWEEN '" + aRet[05] + "' AND '" + aRet[06] + "' "
cQuery += CrLf + "     AND SC6.C6_PEDCLI    BETWEEN '" + aRet[08] + "' AND '" + aRet[09] + "' "
cQuery += CrLf + "     AND SC6.C6_XCODMAR   BETWEEN '" + aRet[10] + "' AND '" + aRet[11] + "' "
cQuery += CrLf + "     AND SC6.C6_XGRPMOD   BETWEEN '" + aRet[12] + "' AND '" + aRet[13] + "' "
cQuery += CrLf + "     AND SC6.C6_XMODVEI   BETWEEN '" + aRet[14] + "' AND '" + aRet[15] + "' "
cQuery += CrLf + "     AND SC6.C6_XSEGMOD   BETWEEN '" + aRet[16] + "' AND '" + aRet[17] + "' "
cQuery += CrLf + "     AND SC6.C6_XFABMOD   BETWEEN '" + aRet[18] + "' AND '" + aRet[19] + "' "
cQuery += CrLf + "     AND SC6.C6_XCORINT   BETWEEN '" + aRet[20] + "' AND '" + aRet[21] + "' "
cQuery += CrLf + "     AND SC6.C6_XCOREXT   BETWEEN '" + aRet[22] + "' AND '" + aRet[23] + "' "
cQuery += CrLf + "     AND SC6.C6_QTDVEN    > SC6.C6_QTDENT "
cQuery += CrLf + "     AND SC5.C5_TIPO      = 'N' "
cQuery += CrLf + "     AND SC6.C6_PEDCLI    <> ' ' "
cQuery += CrLf + "     AND SC6.C6_NOTA      = '" + Space(9) + "' "
cQuery += CrLf + "     AND SC6.C6_BLQ       = ' ' "
cQuery += CrLf + " 	   AND SC6.D_E_L_E_T_   = ' ' "
cQuery += CrLf + " ORDER BY " + cOrderTab 

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

fAtuPeds(cCabAlias,oSay,cCabTable,oCabTable,"")
fTabBackup(aCabStru)
/*********************************************************************************************************************************************/
DEFINE DIALOG oNwFat001 TITLE "Faturamento Atacado" FROM aCords[ 1 ], aCords[ 2 ] TO (aCords[3]*nLinha), (aCords[ 4 ]*nColuna) PIXEL

    oNwFat001:lEscClose := .F.

    // Instancia o layer
    oFWL := FWLayer():New()
    // Inicia o Layer
    oFWL:Init( oNwFat001, .F. )
    // Cria uma linha unica para o Layer
    oFWL:AddLine( 'TOTAL' , 70 , .F.)
    oFWL:AddLine( 'TOTAIS', 20 , .F.)

    // Cria colunas
    oFWL:AddCollumn( 'DIR' , 100, .F., 'TOTAL'  )
    oFWL:AddCollumn( 'DIR2', 040, .F., 'TOTAIS' )
    oFWL:AddCollumn( 'DIR3', 040, .F., 'TOTAIS' )
    oFWL:AddCollumn( 'DIR4', 020, .F., 'TOTAIS' )

    oFWL:AddWindow( 'DIR' , 'Wnd1', "Pedidos de Venda"   ,  090, .F., .T.,, 'TOTAL' )
    oFWL:AddWindow( 'DIR2', 'Wnd2', "Totais Por Cliente" ,  190, .F., .T.,, 'TOTAIS' )
    oFWL:AddWindow( 'DIR3', 'Wnd3', "Totais Por Produto" ,  190, .F., .T.,, 'TOTAIS' )
    oFWL:AddWindow( 'DIR4', 'Wnd4', "Total Geral"        ,  190, .F., .T.,, 'TOTAIS' )

    oPnlWnd1:= oFWL:getWinPanel( 'DIR' , 'Wnd1', 'TOTAL'  )
    oPnlWnd2:= oFWL:getWinPanel( 'DIR2', 'Wnd2', 'TOTAIS' )
    oPnlWnd3:= oFWL:getWinPanel( 'DIR3', 'Wnd3', 'TOTAIS' )
    oPnlWnd4:= oFWL:getWinPanel( 'DIR4', 'Wnd4', 'TOTAIS' )

    aBrwCli   := {}
    oTBrwsCli := TSBrowse():New(01,01,275,050,oPnlWnd2,,16,,1)    
    oTBrwsCli:AddColumn( TCColumn():New('Cliente' ,,,{|| },{|| }) )    
    oTBrwsCli:AddColumn( TCColumn():New('Nome'    ,,,{|| },{|| }) )    
    oTBrwsCli:AddColumn( TCColumn():New('Valor'   ,,,{|| },{|| }) )    
    oTBrwsCli:SetArray(aBrwCli) 

    aBrwPrd   := {}
    oTBrwsPrd := TSBrowse():New(01,01,275,050,oPnlWnd3,,16,,1)    
    oTBrwsPrd:AddColumn( TCColumn():New('Produto'  ,,,{|| },{|| }) )    
    oTBrwsPrd:AddColumn( TCColumn():New('Descrição',,,{|| },{|| }) )    
    oTBrwsPrd:AddColumn( TCColumn():New('Valor'    ,,,{|| },{|| }) )    
    oTBrwsPrd:SetArray(aBrwPrd) 

    aBrwTot   := {}
    oTBrwsTot := TSBrowse():New(01,01,275,050,oPnlWnd4,,16,,1)    
    oTBrwsTot:AddColumn( TCColumn():New('Valor'    ,,,{|| },{|| }) )    
    oTBrwsTot:SetArray(aBrwTot) 

    //- Recupera coordenadas da area superior da linha e coluna a direita do container
    oSize1 := FWDefSize():New(.F.)
    oSize1:AddObject('SUPER',100,100,.T.,.T.)
    oSize1:SetWindowSize({0,0,oPnlWnd1:NHEIGHT,oPnlWnd1:NWIDTH})
    oSize1:lProp     := .T.
    oSize1:aMargins := {0,0,0,0}
    oSize1:Process()

    //- Recupera coordenadas da area superior da linha e coluna a direita do container
    oSize2 := FWDefSize():New(.F.)
    oSize2:AddObject('SUPER',100,100,.T.,.T.)
    oSize2:SetWindowSize({0,0,oPnlWnd2:NHEIGHT,oPnlWnd2:NWIDTH})
    oSize2:lProp     := .T.
    oSize2:aMargins := {0,0,0,0}
    oSize2:Process()

    /*
    @001, 005 Say STR0026	 SIZE 80, 07 	Of oPnlWnd2 Pixel   //"Pedidos Kg"
    @009, 05 MSGET oGetPedKg  VAR nPedKg    PICTURE "@E 999,999,999.99" When .F. SIZE 60, 10	Of oPnlWnd2 Pixel
    @001, 080 Say STR0027	 SIZE 80, 07 	Of oPnlWnd2 Pixel //"Pedidos Vol."
    @009, 080 MSGET oGetPedVol  VAR nPedVol PICTURE PesqPict("SB5", "B5_ALTURLC") When .F. SIZE 60, 10	Of oPnlWnd2 Pixel

    @001, 160 Say STR0028	 SIZE 80, 07 	Of oPnlWnd2 Pixel //"Qtd Veiculos"
    @009, 160 MSGET oGetQtdV  VAR nQtdVei   When .F. SIZE 60, 10	Of oPnlWnd2 Pixel
    @001, 240 Say STR0029	 SIZE 80, 07 	Of oPnlWnd2 Pixel    //"Capacid Kg"
    @009, 240 MSGET oGetTKg  VAR nTotalKg   PICTURE "@E 999,999,999.99" When .F. SIZE 60, 10	Of oPnlWnd2 Pixel
    @001, 320 Say STR0030	 SIZE 80, 07 	Of oPnlWnd2 Pixel    //"Capacid Vol"
    @009, 320 MSGET oGetTVol  VAR nTotalVol PICTURE PesqPict("DA3", "DA3_VOLMAX") When .F. SIZE 60, 10	Of oPnlWnd2 Pixel
    */

    oBrwCab := fwBrowse():New()
    oBrwCab:SetOwner(oPnlWnd1)
    oBrwCab:SetDataTable(.T.)
    oBrwCab:DisableConfig()
    oBrwCab:DisableReport()
    oBrwCab:SetAlias(cCabAlias)
    oBrwCab:SetLocate() 
    oBrwCab:AddMarkColumns({|| IIF(!Empty((cCabAlias)->C6_OK), "LBOK", "LBNO")}, {|| FMark( oBrwCab )}, {|| FMarkAll( oBrwCab )}) //Code-Block Header Click
    oBrwCab:SetColumns(aCabCol)
    oBrwCab:SetEditCell( .T. , { || .T. } )
    
    oBrwCab:aColumns[07]:XF3 := 'SE4' //ok
    oBrwCab:aColumns[08]:XF3 := 'SED' //ok
    oBrwCab:aColumns[25]:XF3 := 'DJ'  //ok
    oBrwCab:aColumns[26]:XF3 := 'SF4' //ok

    oBrwCab:Activate()
    oBrwCab:Refresh()

    //oNwFat001:Activate()
ACTIVATE DIALOG oNwFat001 ON INIT EnchoiceBar(oNwFat001, { || FWMsgRun(, {|oSay| fGeraDocs(cCabAlias,cIteAlias,oSay,cIteTable) },;
                                                                       "Faturamento", "Processando geração de notas"),lOk := .T. ,oNwFat001:End() }, ;
{ || lOk := .F.,oNwFat001:End() },,{{"BMPINCLUIR",{|| MsgRun('Visualizando Pedido','Consulta' ,{|| fVisuPed(cCabAlias,aRotina,2,oSay,cCabTable,oCabTable) })},"Consulta" },;
                         {"BMPINCLUIR",{|| MsgRun('Inclusão Pedido'    ,'Inclusão' ,{|| fVisuPed(cCabAlias,aRotina,3,oSay,cCabTable,oCabTable) })},"Inclusão" },;
                         {"BMPALTERAR",{|| MsgRun('Alteração Pedido'   ,'Alteração',{|| fVisuPed(cCabAlias,aRotina,4,oSay,cCabTable,oCabTable) })},"Alteração"},;
                         {"BMPEXCLUIR",{|| MsgRun('Exclusão Pedido'    ,'Exclusão' ,{|| fVisuPed(cCabAlias,aRotina,5,oSay,cCabTable,oCabTable) })},"Exclusão" },;
                         {"BMPEXCLUIR",{|| MsgRun('Boleto'             ,'Boleto'   ,{|| Boleto(cCabAlias)                                      })},"Boleto"   }},,,,,.F.) CENTERED


MsgRun('Estornando Empenhos','Processo' ,{|| fAtuEmp(oSay,cCabAlias,cIteAlias,lOk) })

If Select(cCabAlias) <> 0 ; (cCabAlias)->(DbCloseArea()) ; EndIf
If Select(cIteAlias) <> 0 ; (cIteAlias)->(DbCloseArea()) ; EndIf

oCabTable:Delete(oSay,cCabAlias,cIteAlias)

Return Nil

/*
=======================================================================================
Programa.:            fAtuEmp  
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

*************************************************
Static Function fAtuEmp(oSay,cCabAlias,cIteAlias,lOk)
*************************************************

Local aCabPed   As Array
Local nY        As Numeric
Local cCampo    As Character
Local nPosicao  As Numeric
Local cConteudo As Character
Local aItePed   As Array
Local aLinha    As Array
Local cQuery    As Character
Local cCamPed   As Caracter
Local nStatus   As Numeric
Local nOpc      As Numercic
Local nLinha    As Numeric
Local nPosLin   As Numeric
Local nPosPrcV  As Numeric
Local nPosValor As Numeric
Local nPosOper  As Numeric
Local nPosTes   As Numeric
Local nPosMvt   As Numeric 
Local nPosVda   As Numeric 

Default lOk := .T.

cCamPed := "C5_NUM|C5_TIPO|C5_CLIENTE|C5_LOJACLI|C5_LOJAENT|C5_CONDPAG"

nOPc  := 4
(cCabAlias)->(DbGoTop())

if !lOk
    nLinha    := ascan(aHeaderAux,{|x| x[1] == "LINHA"     })
    nPosPrcV  := ascan(aHeaderAux,{|x| x[1] == "C6_PRCVEN" })
    nPosValor := ascan(aHeaderAux,{|x| x[1] == "C6_VALOR"  })
    nPosOper  := ascan(aHeaderAux,{|x| x[1] == "C6_OPER"   })
    nPosTes   := ascan(aHeaderAux,{|x| x[1] == "C6_TES"    })
    nPosMvt   := aScan(aHeaderAux,{|x| x[1] == "C6_XVLRMVT"})
    nPosVda   := aScan(aHeaderAux,{|x| x[1] == "C6_XVLRVDA"})
EndIf

While (cCabAlias)->(!Eof())

    oSay:SetText("Estornoando Empenho pedido: " + (cCabAlias)->C6_NUM+" ...") 
    
    SD2->(DbSetOrder(8))
    
    If !SD2->(DbSeek(xFilial("SD2")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))  
        
        SC5->(DbSetOrder(1))        
        SC5->(DbSeek(xFilial("SC5")+(cCabAlias)->C6_NUM))
    
        //SC6->(DbSetOrder(1))        
        //SC6->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))
 
        //SC5->(DbSetOrder(1))        
        //SC5->(DbSeek(xFilial("SC5")+(cCabAlias)->C6_NUM))
        aCabPed := {}
    
        For nY := 1 To SC5->(FCount())
            cCampo   := SC5->(FieldName(nY))
            nPosicao := (cCabAlias)->(FieldPos(cCampo))
            
            if cCampo $ cCamPed

                If nPosicao <> 0
                    cConteudo := (cCabAlias)->(FieldGet(nPosicao))
                Else
                    cConteudo := &("SC5->"+cCampo)
                EndIf

                Aadd(aCabPed, {cCampo,cConteudo, Nil})

            EndIF
            
        Next nY

        SC6->(DbSetOrder(1))        
        SC6->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))

        SBF->(DbSetOrder(1))
        SBF->(DbSeek(xFilial("SBF")+(cCabAlias)->C6_LOCAL+(cCabAlias)->C6_LOCALIZ+(cCabAlias)->C6_PRODUTO+(cCabAlias)->C6_NUMSERI))

        aItePed := {}
        aLinha  := {}
       
        if lOk
            Aadd( aLinha , { "LINPOS"     , "C6_ITEM"               , SC6->C6_ITEM } )
            Aadd( aLinha , { "AUTDELETA"  , "N"                     , Nil          } )
            Aadd( aLinha , { "C6_PRODUTO" , SC6->C6_PRODUTO         , Nil          } )
            Aadd( aLinha , { "C6_QTDVEN"  , SC6->C6_QTDVEN          , Nil          } )
            Aadd( aLinha , { "C6_PRCVEN"  , (cCabAlias)->C6_PRCVEN  , Nil          } )
            Aadd( aLinha , { "C6_VALOR"   , (cCabAlias)->C6_VALOR   , Nil          } )
            Aadd( aLinha , { "C6_PRUNIT"  , SC6->C6_PRUNIT          , Nil          } )
            Aadd( aLinha , { "C6_OPER"    , (cCabAlias)->C6_OPER    , Nil          } )
            Aadd( aLinha , { "C6_TES"     , (cCabAlias)->C6_TES     , Nil          } )
            Aadd( aLinha , { "C6_QTDLIB"  , 0                       , Nil          } )
            Aadd( aLinha , { "C6_CHASSI"  , CriaVar("C6_CHASSI" )   , Nil          } )
            Aadd( aLinha , { "C6_LOCALIZ" , CriaVar("C6_LOCALIZ")   , Nil          } )
            Aadd( aLinha , { "C6_NUMSERI" , CriaVar("C6_NUMSERI")   , Nil          } )
            Aadd( aLinha , { "C6_XVLRMVT" , (cCabAlias)->C6_XVLRMVT , Nil          } )
            Aadd( aLinha , { "C6_XVLRVDA" , (cCabAlias)->C6_XVLRVDA , Nil          } )
            Aadd( aLinha , { "C6_XVLRPRD" , (cCabAlias)->C6_XVLRVDA , Nil          } )
        else
            nPosLin := ascan(aCamBkp,{|x| x[nLinha] == (cCabAlias)->(RECNO())})
                      
            Aadd( aLinha , { "LINPOS"     , "C6_ITEM"                 , SC6->C6_ITEM } )
            Aadd( aLinha , { "AUTDELETA"  , "N"                       , Nil          } )
            Aadd( aLinha , { "C6_PRODUTO" , SC6->C6_PRODUTO           , Nil          } )
            Aadd( aLinha , { "C6_QTDVEN"  , SC6->C6_QTDVEN            , Nil          } )
            Aadd( aLinha , { "C6_PRCVEN"  , aCamBkp[nPosLin,nPosPrcV] , Nil          } )
            Aadd( aLinha , { "C6_VALOR"   , aCamBkp[nPosLin,nPosValor], Nil          } )
            Aadd( aLinha , { "C6_PRUNIT"  , SC6->C6_PRUNIT            , Nil          } )
            Aadd( aLinha , { "C6_OPER"    , aCamBkp[nPosLin,nPosOper] , Nil          } )
            Aadd( aLinha , { "C6_TES"     , aCamBkp[nPosLin,nPosTES]  , Nil          } )
            Aadd( aLinha , { "C6_QTDLIB"  , 0                         , Nil          } )
            Aadd( aLinha , { "C6_CHASSI"  , CriaVar("C6_CHASSI" )     , Nil          } )
            Aadd( aLinha , { "C6_LOCALIZ" , CriaVar("C6_LOCALIZ")     , Nil          } )
            Aadd( aLinha , { "C6_NUMSERI" , CriaVar("C6_NUMSERI")     , Nil          } )
            Aadd( aLinha , { "C6_XVLRMVT" , aCamBkp[nPosLin,nPosMvt]  , Nil          } )
            Aadd( aLinha , { "C6_XVLRVDA" , aCamBkp[nPosLin,nPosVda]  , Nil          } )
            Aadd( aLinha , { "C6_XVLRPRD" , aCamBkp[nPosLin,nPosVda]  , Nil          } )
        EndIf
        Aadd(aItePed, aLinha)

        lMsHelpAuto := .T.
        lMsErroAuto := .F.
        
        MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabPed, aItePed, nOPc, .F.)//Estorno
        
        If lMsErroAuto
            MostraErro()
        Else
            SC6->(DbSetOrder(1))        
            SC6->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))
            /* 
            SC6->(RecLock("SC6",.F.))
            SC6->C6_C6_LOCALIZ := CriaVar("C6_LOCALIZ")
            SC6->C6_CHASSI     := CriaVar("C6_CHASSI" )
            SC6->C6_C6_NUMSERI := CriaVar("C6_NUMSERI")
            SC6->(MsUnLock())
            */
            //Limpa os Campos de Chassi, NumSerie e Localização no Estorno do Pedido
            cQuery := " UPDATE " + RetSqlName("SC6")
            cQuery += " SET C6_LOCALIZ = '" + Criavar("C6_LOCALIZ") + "' "
            cQuery += "    ,C6_CHASSI  = '" + Criavar("C6_CHASSI" ) + "' "
            cQuery += "    ,C6_NUMSERI = '" + Criavar("C6_NUMSERI") + "' "
            cQuery += " WHERE  C6_NUM      = '" + (cCabAlias)->C6_NUM + "' "
            cQuery += "    AND C6_NOTA     = '        ' "
            cQuery += "    AND C6_SERIE    = '   ' "
            cQuery += "    AND D_E_L_E_T_  = ' ' "
            /*nStatus := TCSqlExec(cQuery)
            
            If (nStatus < 0)
                MsgStop("TCSQLError() " + TCSQLError(), "Atualizacao Empenho SC6")
            EndIf
            */
            If (cCabAlias)->VRJ_STATUS $ "A|F"
        
                SDC->(DbSetOrder(3))
        
                If !SDC->(DbSeek(xFilial("SDC")+SC6->C6_PRODUTO+SC6->C6_LOCAL+SC6->C6_LOTECTL+SC6->C6_NUMLOTE+SC6->C6_LOCALIZ+SC6->C6_NUMSERI+"SC6"))
        
                    cQuery := ""
                    cQuery += CrLf + " UPDATE " + RetSqlName("VRK") + " VRK "                                                                           
                    cQuery += CrLf + " SET VRK.VRK_CHASSI = '" + CriaVar("C6_CHASSI" ) + "'  "
                    cQuery += CrLf + "      WHERE   VRK.VRK_FILIAL = '" + xFilial("VRK") + "' "
                    cQuery += CrLf + "          AND VRK.VRK_NUMTRA = '  ' 
                    cQuery += CrLf + "          AND VRK.VRK_ITETRA = ' ' "
                    cQuery += CrLf + "          AND VRK.VRK_PEDIDO||VRK.VRK_ITEPED = (SELECT VRK1.VRK_PEDIDO||VRK1.VRK_ITEPED "
                    cQuery += CrLf + "                               FROM " + RetSqlName("VRJ") + " VRJ "
                    cQuery += CrLf + "                               INNER JOIN "
                    cQuery += CrLf + "                               "+RetSqlName("VRK")+" VRK1 ON VRK1.VRK_FILIAL = '" + xFilial("VRK") + "' "
                    cQuery += CrLf + "                                                         AND VRK1.VRK_PEDIDO = VRJ.VRJ_PEDIDO   "
                    cQuery += CrLf + "                                                         AND VRK1.D_E_L_E_T_ = ' ' "
                    cQuery += CrLf + "                               WHERE VRJ.VRJ_FILIAL  = '" + xFilial("VRJ")                        + "' "
                    cQuery += CrLf + "                                 AND VRJ.VRJ_CODCLI  = '" + SC5->C5_CLIENTE                       + "' "
                    cQuery += CrLf + "                                 AND VRJ.VRJ_LOJA    = '" + SC5->C5_LOJACLI                       + "' "
                    cQuery += CrLf + "                                 AND VRJ.VRJ_PEDCOM  = '" + SC6->C6_PEDCLI                        + "' "
                    cQuery += CrLf + "                                 AND VRK1.VRK_ITEPED = '" + StrZero(Val(Alltrim(SC6->C6_ITEM)),3) + "' "
                    cQuery += CrLf + "                                 AND VRJ.D_E_L_E_T_  = ' ')                                          "
                    nStatus := TCSqlExec(cQuery)

                    If (nStatus < 0)
                        MsgStop("TCSQLError() " + TCSQLError(), "Atualizacao Empenho VRK")
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
    (cCabAlias)->(DbSkip())
EndDo

Return(.T.)

/*
=======================================================================================
Programa.:             fConsNSeri 
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

**************************************************************
Static Function fConsNSeri(cCabAlias,cCabTable,oCabTable,oSay)
**************************************************************

Local   cChassi   As Character

A440Stok(NIL,"A410")

cChassi := GdFieldGet("C6_NUMSERI",1)

If Len(aCols) <> 0 .And. (cChassi <> (cCabAlias)->C6_NUMSERI .Or. cChassi<> (cCabAlias)->C6_CHASSI) .And. !Empty(Alltrim(cChassi))
    fAtuPeds(cCabAlias,oSay,cCabTable,oCabTable,SC5->C5_NUM,cChassi)
EndIf

Return(.T.)

/*
=======================================================================================
Programa.:            fVldCampo  
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

*************************************************************
Static Function fVldCampo(cCabAlias,oSay,cCabTable,oCabTable)
*************************************************************
Local bAction1
Local bAction2
Local bWhile
Local bCond

Local lRetorno  As Logical

Local cAliPed   As Character
Local cArqQry   As Character
Local cCampo    As Character
Local cCodMar   As Character
Local cConteudo As Character
Local cModVei   As Character
Local cQuery    As Character
Local cRetTES   As Character
Local cSeek     As Character
Local cSegMod   As Character
Local cVar      As Character

Local nValPre   As Numeric
Local nValTab   As Numeric
Local nValMov   As Numeric
Local nX        As Numeric

Local aArea     As Array
Local aSC5Area  As Array
Local aSC6Area  As Array
Local aNoFields As Array

Private N         As Numeric
Private aHeader	  As Array
Private oGrade    As Object
Private Altera    As Logical
Private Inclui    As Logical

cConteudo := &( ReadVar())
cCampo    := ReadVar()
lRetorno := .t.

    RecLock( cCabAlias,.F. )
    (cCabAlias)->LUPD := "T" 
    (cCabAlias)->(MsUnLock())


If Upper(Alltrim(cCampo)) == "C5_CONDPAG"

    SE4->(DbSetOrder(1)) ; lRetorno := SE4->( DbSeek( xFilial("SE4") + cConteudo ) )

ElseIf Upper(Alltrim(cCampo)) == "C5_NATUREZ"

    SED->(DbSetOrder(1)) ; lRetorno := SED->( DbSeek( xFilial("SED") + cConteudo ) )

/*ElseIf Upper(Alltrim(cCampo)) == "C6_OPER"

    aHeader := {}
    aHeader := aClone(aHeaderAux)
    aCols   := {{}}

    For nX := 1 to Len(aHeader)
        aadd(aCols[1],(cCabAlias)->&(aHeader[nX,1]) )
    Next nX

    aadd(aCols[1],.T. )
    N := 1
    lRetorno := ExistCpo("SX5","DJ"+cConteudo)

    If lRetorno
        cRetTES := ""
        cRetTES := MaTesInt(2,cConteudo, (cCabAlias)->C5_CLIENTE, (cCabAlias)->C5_LOJACLI,"C", (cCabAlias)->C6_PRODUTO)
        
        If Empty(Alltrim(cRetTES))
            Help("",1,"Não foi encontrado TES para o tipo de operação informado.",,"Pedido não será alterado.",1,0)
            lRetorno := .F.
        Else
            (cCabAlias)->(RecLock(cCabAlias),.F.)
            (cCabAlias)->C6_OPER := cConteudo
            (cCabAlias)->C6_TES  := cRetTES
            (cCabAlias)->(MsUnLock())
        EndIf

    EndIf
*/
//ElseIf Upper(Alltrim(cCampo)) == "C6_TES"

//    SF4->(DbSetOrder(1)) ; lRetorno := SF4->(DbSeek(xFilial("SF4")+cConteudo))

ElseIf Upper(Alltrim(cCampo)) == "C6_NUMSERI"

    SBF->(DbSetOrder(1))
    
    lRetorno := SBF->(DbSeek(xFilial("SBF") + (cCabAlias)->C6_LOCAL + (cCabAlias)->C6_LOCALIZ + (cCabAlias)->C6_PRODUTO + cConteudo))

    If lRetorno .And. SaldoSBF(.F.,"SBF",.F.,.F.,.F.) <= 0
        Help(" ",1,"SALDOLOCLZ")
        lRetorno := .F.
    EndIf

ElseIf Upper(Alltrim(cCampo)) $ "C6_XVLRPRD|C6_TES|C6_XVLRMVT|C6_OPER"

    aHeader := {}
    aHeader := aClone(aHeaderAux)
    aCols   := {{}}

    For nX := 1 to Len(aHeader)
        aadd(aCols[1],(cCabAlias)->&(aHeader[nX,1]) )
    Next nX

    aadd(aCols[1],.T. )
    N := 1
    
    If Upper(Alltrim(cCampo)) == "C6_OPER"
    
        lRetorno := ExistCpo("SX5","DJ"+cConteudo)

        If lRetorno
            cRetTES := ""
            cRetTES := MaTesInt(2,cConteudo, (cCabAlias)->C5_CLIENTE, (cCabAlias)->C5_LOJACLI,"C", (cCabAlias)->C6_PRODUTO)
            
            If Empty(Alltrim(cRetTES))
                Help("",1,"Não foi encontrado TES para o tipo de operação informado.",,"Pedido não será alterado.",1,0)
                lRetorno := .F.
            Else
                (cCabAlias)->(RecLock(cCabAlias),.F.)
                (cCabAlias)->C6_OPER := cConteudo
                (cCabAlias)->C6_TES  := cRetTES
                (cCabAlias)->(MsUnLock())
            EndIf

        EndIf
    else
        lRetorno := .t.
    EndIf
    
    if lRetorno
        if Upper(Alltrim(cCampo)) $ "C6_TES|C6_OPER"
            SF4->(DbSetOrder(1))
            if Upper(Alltrim(cCampo)) $ "C6_OPER"  
                if !SF4->(DbSeek(xFilial("SF4") + (cCabAlias)->C6_TES))
                    lRetorno := .F.
                Else 
                    lRetorno := .T.
                endif
            Elseif !SF4->(DbSeek(xFilial("SF4")+cConteudo))
                lRetorno := .F.
            else
                lRetorno := .T.
            endIf
                    
            If lRetorno
                nValPre :=  (cCabAlias)->C6_XPRCTAB
                reclock(cCabAlias,.f.)
                    (cCabAlias)->C6_XVLRPRD := (cCabAlias)->C6_XPRCTAB
                (cCabAlias)->(MsUnlock())
            EndIf
        Else
            nValPre := iif(ReadVar() == "C6_XVLRPRD" , &( ReadVar()), (cCabAlias)->C6_XVLRPRD )
        EndIf
    EndIf
    
    if lRetorno
    
        cCodMar := (cCabAlias)->C6_XCODMAR
        cModVei := (cCabAlias)->C6_XMODVEI
        cSegMod := (cCabAlias)->C6_XSEGMOD
        nValTab := (cCabAlias)->C6_XPRCTAB
        nValMov := iif(ReadVar() == "C6_XVLRMVT" , &( ReadVar()), (cCabAlias)->C6_XVLRMVT )
        lCalMov := ReadVar() == "C6_XVLRMVT"
        if !lCalMov 
            VlrPret(cCodMar, cModVei, cSegMod, nValTab, nValPre,nValMov,cCabAlias,lCalMov)
        Else
            AtuMOv(nValMov)
        endif
    
        lRetorno := .T.
    
    endif 

ElseIf Upper(Alltrim(cCampo)) == "C6_LOCALIZ"

    SC5->(DbSetOrder(1)) ; SC5->(DbSeek(xFilial("SC5")+(cCabAlias)->C6_NUM                     ))
    SC6->(DbSetOrder(1)) ; SC6->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))

    aArea     := GetArea()
    aSC5Area  := SC5->(GetArea())
    aSC6Area  := SC6->(GetArea())
    aHeader	  := {}
    aCols	  := {}
    cSeek     := xFilial("SC6")+SC5->C5_NUM
    bWhile    := {|| C6_FILIAL+C6_NUM }
    cQuery    := ""
    bCond     := {|| .T. }
    bAction1  := {|| .T. }
    bAction2  := {|| .T. }
    aNoFields := {"C6_NUM","C6_QTDEMP","C6_QTDENT","C6_QTDEMP2","C6_QTDENT2"}		// Campos que nao devem entrar no aHeader e aCols
    cArqQry   := "SC6"
    Altera    := .T.
    Inclui    := .F.
    N         := 1

    oGrade	  := MsMatGrade():New('oGrade',,"C6_QTDVEN",,"a410GValid()",;
                        {{VK_F4,{|| A440Saldo(.T.,oGrade:aColsAux[oGrade:nPosLinO][aScan(oGrade:aHeadAux,{|x| AllTrim(x[2])=="C6_LOCAL"})])}} },;
                        {{"C6_QTDVEN",.T., {{"C6_UNSVEN",{|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),aCols[nLinha][nColuna],0,2) } }} },;
                         {"C6_QTDLIB" , NIL , NIL },;
                         {"C6_QTDENT" , NIL , NIL },;
                         {"C6_ITEM"	  , NIL , NIL },;
                         {"C6_OPC"	  , NIL , NIL },;
                         {"C6_BLQ"	  , NIL , NIL },;
                         {"C6_NUMOP"  , NIL , NIL },;
                         {"C6_ITEMOP" , NIL , NIL },;
                         {"C6_UNSVEN" , NIL , {{"C6_QTDVEN",{|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),0,aCols[nLinha][nColuna],1) }}} };
                        })
    SC5->(DbSetOrder(1))
    SC5->(DbSeek(xFilial("SC5")+(cCabAlias)->C6_NUM))
    RegToMemory( "SC5", .F., .F. )

    DbSelectArea("SC6")
    DbSetOrder(1)

    cQuery := CrLf + " SELECT * "
    cQuery += CrLf + " FROM " + RetSqlName("SC6") + " SC6 "
    cQuery += CrLf + " WHERE SC6.C6_FILIAL  = '" + xFilial("SC6")       + "' AND "
    cQuery += CrLf + "       SC6.C6_NUM     = '" + (cCabAlias)->C6_NUM  + "' AND "
    cQuery += CrLf + "       SC6.C6_ITEM    = '" + (cCabAlias)->C6_ITEM + "' AND "
    cQuery += CrLf + "       SC6.D_E_L_E_T_ = ' ' "
    cQuery += CrLf + " ORDER BY " + SqlOrder(SC6->(IndexKey()))

    DbSelectArea("SC6")
    //DbCloseArea()
    FillGetDados(4,"SC6",1,cSeek,bWhile,{{bCond,bAction1,bAction2}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,/*bMontCols*/,.F.,/*aHeaderAux*/,/*aColsAux*/,{|| AfterCols(cArqQry) },/*bBeforeCols*/,/*bAfterHeader*/,"SC6")

    lRetorno := .t. //VldLocaliz( "A440" )  

    If !lRetorno
        Help(" ",1,"SALDOLOCLZ")
        lRetorno := .F.
    Else
        fConsNSeri(cCabAlias,cCabTable,oCabTable,oSay)
    EndIf

ElseIf Upper(Alltrim(cCampo)) == "C5_XMENSER"

    lRetorno := .T.

EndIf

If lRetorno .And. Upper(Alltrim(cCampo)) != "C6_LOCALIZ"

    //Begin Transaction 
        SC5->(DbSetOrder(1))
        SC5->(DbSeek(xFilial("SC5")+(cCabAlias)->C6_NUM))

        (cCabAlias)->(RecLock(cCabAlias),.F.)
        &("(cCabAlias)->"+cCampo) := cConteudo 
        (cCabAlias)->(MsUnLock())

        If !Empty(Alltrim((cCabAlias)->C6_NUMSERI))
            fAtuPeds(cCabAlias,oSay,cCabTable,oCabTable,SC5->C5_NUM,(cCabAlias)->C6_NUMSERI)
        EndIf
    //End Transaction 

ElseIf Upper(Alltrim(cCampo)) != "C6_LOCALIZ"

    If Upper(Alltrim(cCampo)) != "C6_OPER"
        Help("",1,"RECNOIS")
    EndIf

    SC5->(DbSetOrder(1)) ; SC5->(DbSeek(xFilial("SC6")+(cCabALias)->C6_NUM+(cCabAlias)->C6_ITEM))
    SC5->(DbSetOrder(1)) ; SC6->(DbSeek(xFilial("SC6")+(cCabALias)->C6_NUM                     ))
    
    cVar    := ReadVar()
    cAliPed := "S"+Left(cVar,2)
    cVar    := cVar+" := "+cAliPed+"->"+cCampo
    &(cVar)
    cVar    := ("(cCabAlias)->"+cCampo+":= "+cAliPed+"->"+cCampo)
    &(cVar)

EndIf

if lRetorno 

    RecLock( cCabAlias,.F. )
        (cCabAlias)->LUPD := "F" 
    (cCabAlias)->(MsUnLock())

EndIf

Return(lRetorno)

/*
=======================================================================================
Programa.:              fVisuPed
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

*************************************************************************
Static Function fVisuPed(cCabAlias,aRotina,nOpc,oSay,cCabTable,oCabTable)
*************************************************************************

Local lRetorno    As Logical
Local nRecno      As numeric
Local nY          As numeric
Local aArea       As Array
Local aRotina2    As Array
Local aRotina3    As Array
Local aCabPed     As Array
Local aItePed     As Array
Local aLinha      As Array
Local cCampo      As Character
Local cQuery      As Character

Private cCadastro   As Character
Private Inclui      As Logical
Private	Altera      As Logical
Private lMsHelpAuto As Logical
Private lMsErroAuto As Logical
Private l410Auto    As Logical

nRecno    := (cCabAlias)->(Recno())
lRetorno  := .F.
cCadastro := "Atualização de Pedidos de Venda"
aRotina2  := {{"Incluir","A410Barra",0,3},;//"Incluir"
			  {"Alterar","A410Barra",0,4}} //"Alterar"

aRotina3  := {{OemToAnsi("Deleta" ),"A410Deleta",0,5,21,NIL},;//"Deleta"
			  {OemToAnsi("Residuo"),"Ma410Resid",0,2,0,NIL }} //"Residuo"

aRotina := {{OemToAnsi("Pesquisar"       ),"AxPesqui"		                                                  ,0,1,0 ,.F.},;//"Pesquisar"
			{OemToAnsi("Visual"          ),"A410Visual"	                                                      ,0,2,0 ,NIL},;//"Visual"
			{OemToAnsi("Incluir"         ),"A410Inclui"	                                                      ,0,3,0 ,NIL},;//"Incluir"
			{OemToAnsi("Alterar"         ),"A410Altera"	                                                      ,0,4,20,NIL},;//"Alterar"
			{OemToAnsi("Excluir"         ),IIf((Type("l410Auto") <> "U" .And. l410Auto),"A410Deleta",aRotina3),0,5,0 ,NIL},;//"Excluir"
			{OemToAnsi("Cod.barra"       ),aRotina2 		                                                  ,0,3,0 ,NIL},;//"Cod.barra"
			{OemToAnsi("Copia"           ),"a410PCopia('SC5',SC5->(RecNo()),4)"	                              ,0,6,0 ,NIL},;//"Copia"
			{OemToAnsi("Dev. Compras"    ),"A410Devol('SC5',SC5->(RecNo()),4)" 	                              ,0,3,0 ,.F.},;//"Dev. Compras"
			{OemToAnsi("Prep.Doc.Saída"  ),"Ma410PvNfs"	                                                      ,0,2,0 ,NIL},;//"Prep.Doc.Saída"
			{OemToAnsi("Tracker Contábil"),"CTBC662"                                                          ,0,7,0 ,Nil},;//"Tracker Contábil"
			{OemToAnsi("Legenda"         ),"A410Legend"	                                                      ,0,1,0 ,.F.}} //"Legenda"

aArea := GetArea()
SC5->(DbSetOrder(1))

If cCabAlias == "SC5" .Or. SC5->(DbSeek(xFilial("SC5")+(cCabAlias)->C6_NUM))

    If nOpc == 2

        Inclui := .F. ;Altera := .F.
        A410Visual("SC5",SC5->(Recno()),nOpc)

    ElseIf nOpc == 3

        lRetorno := A410Inclui("SC5",SC5->(Recno()),nOpc)

        If lRetorno .And. cCabAlias <> "SC5"
            cQuery := ""
            cQuery += " INSERT INTO " + cCabTable + " "
            cQuery += CrLf + " ("

            For nY := 1 To Len(aCabCampos)
                If  Upper(Alltrim(aCabCampos[nY])) <> "C9_SEQUEN"  .And. Upper(Alltrim(aCabCampos[nY])) <> "C9_NFISCAL" .And.;
                    Upper(Alltrim(aCabCampos[nY])) <> "C9_SERIENF" .And. Upper(Alltrim(aCabCampos[nY])) <> "C5_XMENSER"
                    
                    cQuery += aCabCampos[nY]+","
                
                EndIf
            Next nY

            cQuery += CrLf + " D_E_L_E_T_,R_E_C_N_O_) "
            cQuery += CrLf + " SELECT '  ' C6_OK    , "
            cQuery += CrLf + " ' '         C6_STATUS, "
            
            For nY := 1 To Len(aCabCampos)
            
                If  Upper(Alltrim(aCabCampos[nY])) <> "C6_OK"      .And. Upper(Alltrim(aCabCampos[nY])) <> "CC_STATUS"  .And.;
                    Upper(Alltrim(aCabCampos[nY])) <> "C9_SEQUEN"  .And. Upper(Alltrim(aCabCampos[nY])) <> "C9_NFISCAL" .And.;
                    Upper(Alltrim(aCabCampos[nY])) <> "C9_SERIENF" .And. Upper(Alltrim(aCabCampos[nY])) <> "C5_XMENSER"
            
                    If Left(aCabCampos[nY],3) == "C6_" ; cQryAlias := "SC6." ; EndIf
                    If Left(aCabCampos[nY],3) == "C5_" ; cQryAlias := "SC5." ; EndIf
                    If Left(aCabCampos[nY],3) == "A1_" ; cQryAlias := "SA1." ; EndIf
                    If Left(aCabCampos[nY],3) == "B1_" ; cQryAlias := "SB1." ; EndIf
                    If Left(aCabCampos[nY],3) == "F4_" ; cQryAlias := "SF4." ; EndIf
            
                    cQuery +=  CrLf + " " + (cQryAlias+aCabCampos[nY])+", "
            
                EndIf
            
            Next
            
            cQuery += CrLf + "        ' ' AS D_E_L_E_T_  , "
            cQuery += CrLf + "        ROW_NUMBER() OVER (ORDER BY SC6.C6_FILIAL,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC6.C6_PRODUTO)  R_E_C_N_O_  "
            cQuery += CrLf + " FROM "+RetSqlName("SC6")+" SC6 "
            
            cQuery += CrLf + "      INNER JOIN " + RetSqlName("SC5") + " SC5 "
            cQuery += CrLf + "              ON  SC6.C6_FILIAL   = SC5.C5_FILIAL "
            cQuery += CrLf + "              AND SC6.C6_NUM      = SC5.C5_NUM "
            cQuery += CrLf + "              AND SC6.D_E_L_E_T_  = SC5.D_E_L_E_T_ "
            
            cQuery += CrLf + "      INNER JOIN " + RetSqlName("SA1") + " SA1 
            cQuery += CrLf + "              ON  SC5.C5_CLIENTE  = SA1.A1_COD "
            cQuery += CrLf + "              AND SC5.C5_LOJACLI  = SA1.A1_LOJA "
            cQuery += CrLf + "              AND SC5.D_E_L_E_T_  = SA1.D_E_L_E_T_ "
            
            cQuery += CrLf + "      INNER JOIN " + RetSqlName("SB1") + " SB1 
            cQuery += CrLf + "              ON  SC6.C6_PRODUTO  = SB1.B1_COD "
            cQuery += CrLf + "              AND SC6.D_E_L_E_T_  = SB1.D_E_L_E_T_ "
            
            cQuery += CrLf + "      INNER JOIN " + RetSqlName("SF4") + " SF4 "
            cQuery += CrLf + "              ON  SC6.C6_TES      = SF4.F4_CODIGO "
            cQuery += CrLf + "              AND SC6.D_E_L_E_T_  = SF4.D_E_L_E_T_ "
            
            cQuery += CrLf + " WHERE   SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "
            cQuery += CrLf + "     AND SC5.C5_NUM     = '" + SC5->C5_NUM    + "' "
            cQuery += CrLf + "     AND SC5.C5_TIPO    = 'N' "
            cQuery += CrLf + "     AND SC6.C6_QTDVEN  > SC6.C6_QTDENT "
            cQuery += CrLf + "     AND SC6.C6_NOTA    = ' ' "
            cQuery += CrLf + "     AND SC6.C6_BLQ     = ' ' "
            cQuery += CrLf + "     AND SB1.B1_GRUPO   = 'VEIA' "
            cQuery += CrLf + "     AND SF4.F4_DUPLIC  = 'S' "
            cQuery += CrLf + " 	   AND SC6.D_E_L_E_T_ = ' ' "
            cQuery += CrLf + " ORDER BY SC6.C6_FILIAL,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC6.C6_PRODUTO "
            
            nStatus := TCSqlExec(cQuery)
            fAtuPeds(cCabAlias,oSay,cCabTable,oCabTable,SC5->C5_NUM)

        EndIf

    ElseIf nOpc == 4
        
        Inclui := .F. ;Altera := .T.
        SC6->(DbSetOrder(1))
        SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
        lRetorno := A410Altera("SC5",SC5->(Recno()),nOpc)
        
        If lRetorno 
            fAtuPeds(cCabAlias,oSay,cCabTable,oCabTable,SC5->C5_NUM,SC6->C6_NUMSERI)
        EndIf
    
    ElseIf nOpc == 5
    
        If FWAlertYesNo("O pedido está liberado para faturamento. Deseja continuar?", "Exclusão de Pedido")
            //Begin Transaction
                aCabPed := {}

                For nY := 1 To SC5->(FCount())
                    cCampo  := SC5->(FieldName(nY))
                    Aadd(aCabPed, {cCampo,&("SC5->"+cCampo), Nil})
                Next

                SC6->(DbSetOrder(1))        
                SC6->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))

                l410Auto := .T.
                aItePed  := {}
                aLinha   := {}

                Aadd( aLinha , { "LINPOS"     , "C6_ITEM"              , SC6->C6_ITEM } )
                Aadd( aLinha , { "AUTDELETA"  , "N"                    , Nil          } )
                Aadd( aLinha , { "C6_PRODUTO" , SC6->C6_PRODUTO        , Nil          } )
                Aadd( aLinha , { "C6_QTDVEN"  , SC6->C6_QTDVEN         , Nil          } )
                Aadd( aLinha , { "C6_PRCVEN"  , SC6->C6_PRCVEN         , Nil          } )
                Aadd( aLinha , { "C6_VALOR"   , SC6->C6_VALOR          , Nil          } )
                Aadd( aLinha , { "C6_PRUNIT"  , SC6->C6_PRUNIT         , Nil          } )
                Aadd( aLinha , { "C6_TES"     , SC6->C6_TES            , Nil          } )
                Aadd( aLinha , { "C6_QTDLIB"  , 0                      , Nil          } )
                Aadd( aLinha , { "C6_CHASSI"  , CriaVar("C6_CHASSI" )  , Nil          } )
                Aadd( aLinha , { "C6_LOCALIZ" , CriaVar("C6_LOCALIZ")  , Nil          } )
                Aadd( aLinha , { "C6_NUMSERI" , CriaVar("C6_NUMSERI")  , Nil          } )
                Aadd(aItePed, aLinha)

                MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabPed, aItePed, 4 , .F.)

                If lMsErroAuto
                    MostraErro()
                    //DisarmTransaction()
                    Return()
                EndIf

                l410Auto := .F.
                A410Deleta("SC5",SC5->(Recno()),nOpc)

                SC5->(DbSetOrder(1))
                SC5->(DbGoTop())

                If !SC5->(DbSeek(xFilial("SC5")+(cCabAlias)->C6_NUM))
                  
                    (cCabAlias)->(DbGoTo(nRecno))
                    
                    RecLock(cCabAlias,.F.)
                        (cCabAlias)->(DbDelete())
                    (cCabAlias)->(MsUnLock())
                    
                    (cCabAlias)->(DbGoTop())
                    
                    DBCommitAll()
                Else
                    //DisarmTransaction()
                EndIf
            //End Transaction 
        EndIf
    EndIf
EndIf

RestArea(aArea)

Return()
/*
=======================================================================================
Programa.:            fAtuPeds  
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/
****************************************************************************
Static Function fAtuPeds(cCabAlias,oSay,cCabTable,oCabTable,cNumPed,cChassi)
****************************************************************************

Local cQuery        As Character
Local cTmpAlias     As Character
Local cConteudo     As Character
Local cTrbAlias     As Character
Local cNumSerie     As Character
Local aCampos       As Array
Local aCabPed       As Array
Local aItePed       As Array
Local aLinha        As Array
Local aArea         As Array
Local nY            As Numeric
Local n_RecnoSc6    As Numeric
Local nQtdLib       As Numeric
Local nPosicao      As Numeric
Local nStatus       As Numeric
Local nRecno        As Numeric
Local lLibPed       As Logical
Local lRetorno      As Logical

Private lMsHelpAuto As Logical
Private lMsErroAuto As Logical

Private lLiber   As Logical
Private lParcial As Logical
Private lTrans   As Logical
Private lCredito As Logical
Private lEstoque As Logical
Private lAvCred  As Logical
Private lAvEst   As Logical
Private lItLib   As Logical
Public  nLinPos  As Numeric

aCampos     := {"VV1.VV1_FILIAL,","SBF.BF_PRODUTO,","VV1.VV1_CHASSI,","VV1.VV1_CODMAR,","VV1.VV1_MODVEI,","VV1.VV1_SEGMOD,",;
                "VV1.VV1_FABMOD,","VV1.VV1_CORVEI,","SBF.BF_LOCAL,"  ,"SBF.BF_LOCALIZ,","SBF.BF_QUANT,"}

cTmpAlias   := GetNextAlias()
cTrbAlias   := GetNextAlias()
cQuery      := ""
aArea       := GetArea()
nY          := 1
nOPc        := 4
lRetorno    := .T.

If !Empty(Alltrim(cNumPed))
    (cCabAlias)->(DbSetFilter( { || C6_NUM == cNumPed }, 'C6_NUM == "'+cNumPed+'"' ) )
EndIf

(cCabAlias)->(DbGoTop())

While (cCabAlias)->(!Eof())
    
    oSay:SetText("Preparando pedido: " + (cCabAlias)->C6_NUM+" ...")
    if (cCabAlias)->LUPD <> "T"
    cNumSerie := ""
    SC5->(DbSetOrder(1))        
    SC5->(DbSeek(xFilial("SC5")+(cCabAlias)->C6_NUM))
    
    SC6->(DbSetOrder(1))        
    SC6->(DbSeek(xFilial("SC6") + (cCabAlias)->C6_NUM + (cCabAlias)->C6_ITEM))

    If !Empty(Alltrim(cNumPed)) .and. (cCabAlias)->LUPD == "T"
        //Begin Transaction
            cNumSerie := If(ValType(cChassi) <> "U" , cChassi, SC6->C6_CHASSI)

            SC5->(DbSetOrder(1))        
            SC5->(DbSeek(xFilial("SC5")+(cCabAlias)->C6_NUM))
            aCabPed := {}

            For nY := 1 To SC5->(FCount())
                cCampo   := SC5->(FieldName(nY))
                nPosicao := (cCabAlias)->(FieldPos(cCampo))

                If nPosicao <> 0
                    cConteudo := (cCabAlias)->(FieldGet(nPosicao))
                Else
                    cConteudo := &("SC5->"+cCampo)
                EndIf

                Aadd(aCabPed, {cCampo,cConteudo, Nil})

            Next nY

            SC6->(DbSetOrder(1))        
            SC6->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))

            aItePed := {}
            aLinha  := {}

            Aadd( aLinha , { "LINPOS"     , "C6_ITEM"               , SC6->C6_ITEM } )
            Aadd( aLinha , { "AUTDELETA"  , "N"                     , Nil          } )
            Aadd( aLinha , { "C6_PRODUTO" , SC6->C6_PRODUTO         , Nil          } )
            Aadd( aLinha , { "C6_QTDVEN"  , SC6->C6_QTDVEN          , Nil          } )
            Aadd( aLinha , { "C6_PRCVEN"  , (cCabAlias)->C6_PRCVEN  , Nil          } )
            Aadd( aLinha , { "C6_VALOR"   , (cCabAlias)->C6_VALOR   , Nil          } )
            Aadd( aLinha , { "C6_PRUNIT"  , SC6->C6_PRUNIT          , Nil          } )
            Aadd( aLinha , { "C6_OPER"    , (cCabAlias)->C6_OPER    , Nil          } )
            Aadd( aLinha , { "C6_TES"     , (cCabAlias)->C6_TES     , Nil          } )
            Aadd( aLinha , { "C6_QTDLIB"  , SC6->C6_QTDVEN          , Nil          } )
            Aadd( aLinha , { "C6_CHASSI"  , (cCabAlias)->C6_CHASSI  , Nil          } )
            Aadd( aLinha , { "C6_LOCALIZ" , (cCabAlias)->C6_LOCALIZ , Nil          } )
            Aadd( aLinha , { "C6_NUMSERI" , (cCabAlias)->C6_NUMSERI , Nil          } )
            Aadd( aLinha , { "C6_XVLRMVT" , (cCabAlias)->C6_XVLRMVT , Nil          } )
            Aadd( aLinha , { "C6_XVLRVDA" , (cCabAlias)->C6_XVLRVDA , Nil          } )
            Aadd( aLinha , { "C6_XVLRPRD" , (cCabAlias)->C6_XVLRVDA , Nil          } )
            Aadd(aItePed, aLinha)
            
            lMsHelpAuto := .T.
            lMsErroAuto := .F.
            
            MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabPed, aItePed, nOPc, .F.) // Atu campo
            
            If lMsErroAuto
                MostraErro()
                lRetorno := .F.
                //DisarmTransaction()
            Else
                RecLock(cCabAlias,.F.)
                (cCabAlias)->LUPD := "F"
                (cCabAlias)->(MsUnLock())
                DBCommitAll()
            EndIf
        //End Transaction
    Else
        
        RecLock(cCabAlias,.F.)
        (cCabAlias)->C5_XMENSER := If(!Empty(Alltrim(SC5->C5_XMENSER)),SC5->C5_XMENSER,Space(8000))
        (cCabAlias)->(MsUnLock())        
    
    EndIf

    If !Empty(Alltrim(SC6->C6_NUMSERI)) .And. !Empty(Alltrim(SC6->C6_CHASSI )) .And.  !Empty(Alltrim(SC6->C6_LOCALIZ))
    
        SDC->(DbSetOrder(3))
    
        If SDC->(DbSeek(xFilial("SDC")+SC6->C6_PRODUTO+SC6->C6_LOCAL+SC6->C6_LOTECTL+SC6->C6_NUMLOTE+SC6->C6_LOCALIZ+SC6->C6_NUMSERI+"SC6"))
            (cCabAlias)->(RecLock(cCabAlias,.F.))
            (cCabAlias)->C9_SEQUEN  := SDC->DC_SEQ
            (cCabAlias)->(MsUnLock())
        EndIf

        cQuery := ""
        cQuery += CrLf + " UPDATE "+RetSqlName("VRK")                                                                           
        cQuery += CrLf + " SET VRK_CHASSI = '"+SC6->C6_NUMSERI+"' "
        cQuery += CrLf + " WHERE VRK_FILIAL = '"+xFilial("VRK")+"' "
        cQuery += CrLf + " AND VRK_PEDIDO||VRK_ITEPED = (SELECT VRK.VRK_PEDIDO||VRK.VRK_ITEPED "
        cQuery += CrLf + "                               FROM "+RetSqlName("VRJ")+" VRJ "
        cQuery += CrLf + "                               INNER JOIN  " + RetSqlName("VRK") + " VRK " 
        cQuery += CrLf + "                                      ON  VRK.VRK_FILIAL = '"+xFilial("VRK")+"' "
        cQuery += CrLf + "                                      AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO "
        cQuery += CrLf + "                                      AND VRK.D_E_L_E_T_ = VRJ.D_E_L_E_T_ "
        cQuery += CrLf + "                                      AND VRK.VRK_ITEPED  = '" + StrZero(Val(Alltrim(SC6->C6_ITEM)),3)  +"' "
        
        cQuery += CrLf + "                               WHERE VRJ.VRJ_FILIAL  = '" + xFilial("VRJ") + "' "
        cQuery += CrLf + "                                 AND VRJ.VRJ_CODCLI  = '" + SC5->C5_CLIENTE + "' "
        cQuery += CrLf + "                                 AND VRJ.VRJ_LOJA    = '" + SC5->C5_LOJACLI + "' "
        cQuery += CrLf + "                                 AND VRJ.VRJ_PEDCOM  = '" + SC6->C6_PEDCLI  + "' "
        cQuery += CrLf + "                                 AND VRJ.D_E_L_E_T_  = ' ') "
        nStatus := TCSqlExec(cQuery)

        If (nStatus < 0)
            MsgStop("TCSQLError() " + TCSQLError(), "Atualizacao Chasi VRK")
        EndIf

        (cCabAlias)->(DbSkip())
        Loop
    
    EndIf
 
    cQuery := ""
    cQuery += CrLf + " SELECT A.* "
    cQuery += CrLf + "  FROM (  "
    cQuery += CrLf + "      SELECT "
    
    For nY := 1 To Len(aCampos)
        cQuery += CrLf + aCampos[nY]
    Next
    
    cQuery += CrLf + "         (SELECT MAX(SDB.DB_NUMSEQ) "
    cQuery += CrLf + "          FROM " + RetSqlName("SDB") + " SDB"
    cQuery += CrLf + "          WHERE  SDB.DB_FILIAL       = '"+xFilial("SDB")+"'"
    cQuery += CrLf + "             AND SDB.DB_ESTORNO      = ' '"
    cQuery += CrLf + "             AND SDB.DB_ATUEST       = 'S'"
    cQuery += CrLf + "             AND SDB.DB_LOCAL        = SBF.BF_LOCAL"
    cQuery += CrLf + "             AND SDB.DB_LOCALIZ      = SBF.BF_LOCALIZ"
    cQuery += CrLf + "             AND SDB.DB_NUMSERI      = SBF.BF_NUMSERI"
    cQuery += CrLf + "             AND SDB.DB_PRODUTO      = SBF.BF_PRODUTO"
    cQuery += CrLf + "             AND SDB.D_E_L_E_T_      = ' ') DB_NUMSEQ,"

    cQuery += CrLf + "             NVL((SELECT VB0_DATDES FROM " + RetSqlName("VB0") + "  VB0 "
    cQuery += CrLf + "                  WHERE VB0.VB0_DATBLO||VB0.VB0_HORBLO =( "
    cQuery += CrLf + "                                                     SELECT max(VB0A.VB0_DATBLO||VB0A.VB0_HORBLO) as DATBLOQ "
    cQuery += CrLf + "                                                     FROM " + RetSqlName("VB0") + "  VB0A "
    cQuery += CrLf + "                                                        WHERE VB0A.VB0_FILIAL = VB0.VB0_FILIAL "
    cQuery += CrLf + "                                                          AND VB0A.vb0_chaint = VB0.VB0_CHAINT "
    cQuery += CrLf + "                                                          AND VB0A.D_E_L_E_T_ = ' ') "
    cQuery += CrLf + "                 AND VB0.VB0_FILIAL = '" + xFilial("VB0") + "' "
    cQuery += CrLf + "                 AND VB0.VB0_CHAINT = VV1.VV1_CHAINT "
    cQuery += CrLf + "                 AND VB0.D_E_L_E_T_ = ' '),'99999999') AS VB0_DATDES "

    cQuery += CrLf + " FROM " + RetSqlName("VV1") + " VV1 "
    
    cQuery += CrLf + "      INNER JOIN " + RetSqlName("SBF") + " SBF "
    cQuery += CrLf + "          ON  SBF.BF_FILIAL  = '" + xFilial("SBF") + "'"
    cQuery += CrLf + "          AND SBF.BF_NUMSERI = VV1.VV1_CHASSI "
    cQuery += CrLf + "          AND SBF.D_E_L_E_T_ = VV1.D_E_L_E_T_ "
    cQuery += CrLf + "          AND SBF.BF_QUANT   > 0 "
    cQuery += CrLf + "          AND SBF.BF_EMPENHO = 0 "
    cQuery += CrLf + "          AND SBF.BF_PRODUTO = '" + (cCabAlias)->C6_PRODUTO + "' "
    cQuery += CrLf + "          AND SBF.BF_LOCAL   = '" + (cCabAlias)->C6_LOCAL   + "' "
    
    If !Empty(Alltrim(cNumSerie))
        cQuery += CrLf + " AND SBF.BF_NUMSERI      = '" + cNumSerie + "' "
    EndIf
        
    cQuery += CrLf + " WHERE   VV1.VV1_FILIAL      = '" + xFilial("VV1") + "' "
    cQuery += CrLf + "     AND VV1.VV1_SITVEI      = '0' "
    cQuery += CrLf + "     AND VV1.VV1_IMOBI       = '0' "
    cQuery += CrLf + "     AND VV1.D_E_L_E_T_      = ' ') A "
    cQuery += CrLf + "     WHERE A.VB0_DATDES > '        ' "
    cQuery += CrLf + " ORDER BY A.VV1_FILIAL,A.BF_PRODUTO,A.DB_NUMSEQ,A.VV1_CHASSI "
    
    If Select(cTmpAlias) <> 0 ; (cTmpAlias)->(DbCloseArea()) ; EndIf
    
    DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTmpAlias, .F., .T. )

    If (cTmpAlias)->(!Eof())

        /*/
        ****************************************
        * Define Variaveis usados pelo MATA440 *
        ****************************************
        /*/
        lLiber   := .T.
        lParcial := .T.
        lTrans   := .F.
        lCredito := .T.
        lEstoque := .T.
        lAvCred  := .T.
        lAvEst   := .T.
        lItLib   := .T.
        lLibPed  := .F.

        //Begin Transaction 
            /*/
            ************************************************
            * Posiciona registros para efetuar a liberacao *
            ************************************************
            /*/
            SC6->(DbSetOrder(1))        
            SC6->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))
            
            SC6->(RecLock("SC6",.F.))
                SC6->C6_QTDLIB  := 1
                SC6->C6_LOTECTL := CriaVar("C6_LOTECTL")
                SC6->C6_DTVALID := CriaVar("C6_DTVALID")
                SC6->C6_NUMSERI := Alltrim((cTmpAlias)->VV1_CHASSI)
                SC6->C6_CHASSI  := Alltrim((cTmpAlias)->VV1_CHASSI)
                SC6->C6_LOCALIZ := Alltrim((cTmpAlias)->BF_LOCALIZ)
            SC6->(MsUnLock())
            
            n_RecnoSc6 := SC6->(Recno())

            SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))

            /*/
            *******************************
            * Efetua a Liberacao por item *
            *******************************
            /*/
            nQtdLib   := SC6->C6_QTDLIB
            nQtdLib   := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,lAvCred,lAvEst,lLiber,lTrans)

            SDC->(DbSetOrder(1))
            SDC->(DbGoTop())
            If SDC->(DbSeek(xFilial("SDC")+(cCabAlias)->C6_PRODUTO;
                                          +(cCabAlias)->C6_LOCAL  ;
                                          +"SC6"                  ;
                                          +(cCabAlias)->C6_NUM    ;
                                          +(cCabAlias)->C6_ITEM   ;
                                          +SC9->C9_SEQUEN         ;
                                          +CriaVar("DC_LOTECTL")  ;
                                          +CriaVar("DC_NUMLOTE")  ;
                                          +(cTmpAlias)->BF_LOCALIZ;
                                          +(cTmpAlias)->VV1_CHASSI))
    
                cQuery := ""
                cQuery += CrLf + " SELECT  VV1.VV1_FILIAL          AS FILIAL   , "
                cQuery += CrLf + "         VV1.VV1_CHASSI          AS CHASSI   , "
                cQuery += CrLf + "         VV1.VV1_CHAINT          AS CHASSIINT, "
                cQuery += CrLf + "         VV1.VV1_MODVEI          AS MODVEI   , "
                cQuery += CrLf + "         TRIM(VV2.VV2_DESMOD)    AS DESCMOD  , "
                cQuery += CrLf + "         VV1.VV1_CODMAR          AS MARCA    , "
                cQuery += CrLf + "         TRIM(VE1.VE1_DESMAR)    AS DESCMAR  , "
                cQuery += CrLf + "         VV1.VV1_SEGMOD          AS SEGMOD   , "
                cQuery += CrLf + "         TRIM(VVX.VVX_DESSEG)    AS DESCSEG  , "
                cQuery += CrLf + "         VV1.VV1_FABMOD          AS FABMOD   , "
                cQuery += CrLf + "         VV2.VV2_COREXT          AS COREXT   , "
                cQuery += CrLf + "         TRIM(VX1.VX5_DESCRI)    AS DESCEXT  , "
                cQuery += CrLf + "         VV2.VV2_CORINT          AS CORINT   , "
                cQuery += CrLf + "         TRIM(VX2.VX5_DESCRI)    AS DESCINT    "
                cQuery += CrLf + " FROM    "+RetSqlName("VV1")+" VV1 "
                
                cQuery += CrLf + "         INNER JOIN " + RetSqlName("VV2") + " VV2  "
                cQuery += CrLf + "              ON  VV2.VV2_FILIAL  = '" + xFilial("VV2") + "' "
                cQuery += CrLf + "              AND VV2.VV2_CODMAR  = VV1.VV1_CODMAR   "
                cQuery += CrLf + "              AND VV2.VV2_MODVEI  = VV1.VV1_MODVEI   "
                cQuery += CrLf + "              AND VV2.VV2_SEGMOD  = VV1.VV1_SEGMOD   "
                cQuery += CrLf + "              AND VV2.D_E_L_E_T_  = ' ' "
                
                cQuery += CrLf + "         LEFT JOIN " + RetSqlName("VX5") + " VX1 "
                cQuery += CrLf + "              ON  VX1.VX5_FILIAL  = '" + xFilial("VX5") + "' "
                cQuery += CrLf + "              AND VX1.VX5_CHAVE   = '067'   "
                cQuery += CrLf + "              AND VX1.VX5_CODIGO  = VV2.VV2_COREXT "
                cQuery += CrLf + "              AND VX1.D_E_L_E_T_  = ' ' "
                
                cQuery += CrLf + "         LEFT JOIN " + RetSqlName("VX5") + " VX2 "
                cQuery += CrLf + "              ON  VX2.VX5_FILIAL  = '" + xFilial("VX5") + "' "
                cQuery += CrLf + "              AND VX2.VX5_CHAVE   = '066' "
                cQuery += CrLf + "              AND VX2.VX5_CODIGO  = VV2.VV2_CORINT "
                cQuery += CrLf + "              AND VX2.D_E_L_E_T_  =  ' '   "
                
                cQuery += CrLf + "         LEFT JOIN " + RetSqlName("VE1") + " VE1  "
                cQuery += CrLf + "              ON  VE1.VE1_FILIAL  = '" + xFilial("VE1") + "'  "
                cQuery += CrLf + "              AND VE1.VE1_CODMAR  = VV1.VV1_CODMAR   "
                cQuery += CrLf + "              AND VE1.D_E_L_E_T_  = ' ' "
                
                cQuery += CrLf + "         LEFT JOIN " + RetSqlName("VVX") + " VVX  "
                cQuery += CrLf + "              ON  VVX.VVX_FILIAL  = '" + xFilial("VVX") + "' "
                cQuery += CrLf + "              AND VVX.VVX_CODMAR  = VV1.VV1_CODMAR "
                cQuery += CrLf + "              AND VVX.VVX_SEGMOD  = VV1.VV1_SEGMOD "
                cQuery += CrLf + "              AND VVX.D_E_L_E_T_  = ' ' "
                
                cQuery += CrLf + " WHERE   VV1.VV1_FILIAL = '" + xFilial("VV1") + "' "
                cQuery += CrLf + "     AND VV1.VV1_CHASSI = '" + Alltrim((cTmpAlias)->VV1_CHASSI) + "'   "
                cQuery += CrLf + "     AND VV1.D_E_L_E_T_ = ' ' "
                
                If Select(cTrbAlias) <> 0 ; (cTrbAlias)->(DbCloseArea()) ; EndIf
                DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTrbAlias, .F., .T. )

                lLibPed  := .T.
                (cCabAlias)->(RecLock(cCabAlias,.F.))
    
                    If Empty(Alltrim(SC9->C9_BLCRED)) .And. Empty(Alltrim(SC9->C9_BLEST )) .And. Empty(Alltrim(SC9->C9_BLWMS ))
        
                    (cCabAlias)->CC_STATUS  := "1"
        
                    ElseIf SC9->C9_BLCRED == "01" ; (cCabAlias)->CC_STATUS  := "2"
                    ElseIf SC9->C9_BLCRED == "04" ; (cCabAlias)->CC_STATUS  := "3"
                    ElseIf SC9->C9_BLCRED == "05" ; (cCabAlias)->CC_STATUS  := "4"
                    ElseIf SC9->C9_BLCRED == "06" ; (cCabAlias)->CC_STATUS  := "5"
                    ElseIf SC9->C9_BLCRED == "09" ; (cCabAlias)->CC_STATUS  := "6"
                    ElseIf SC9->C9_BLEST  == "02" ; (cCabAlias)->CC_STATUS  := "7"
                    ElseIf SC9->C9_BLEST  == "03" ; (cCabAlias)->CC_STATUS  := "8"
                    ElseIf SC9->C9_BLWMS  == "01" ; (cCabAlias)->CC_STATUS  := "9"
                    ElseIf SC9->C9_BLWMS  == "02" ; (cCabAlias)->CC_STATUS  := "A"
                    ElseIf SC9->C9_BLWMS  == "03" ; (cCabAlias)->CC_STATUS  := "B"
                    ElseIf SC9->C9_BLWMS  == "05" ; (cCabAlias)->CC_STATUS  := "C"
                    ElseIf SC9->C9_BLWMS  == "06" ; (cCabAlias)->CC_STATUS  := "D"
                    ElseIf SC9->C9_BLWMS  == "07" ; (cCabAlias)->CC_STATUS  := "E"
                    EndIf
                
                    (cCabAlias)->C6_CHASSI  := (cTmpAlias)->VV1_CHASSI 
                    (cCabAlias)->C6_NUMSERI := (cTmpAlias)->VV1_CHASSI
                    (cCabAlias)->C6_LOCALIZ := (cTmpAlias)->BF_LOCALIZ 
                    (cCabAlias)->C9_SEQUEN  := SC9->C9_SEQUEN
                    (cCabAlias)->C6_XCODMAR	:= (cTrbAlias)->MARCA      
                    (cCabAlias)->C6_XDESMAR := (cTrbAlias)->DESCMAR 
                    (cCabAlias)->C6_XCORINT	:= (cTrbAlias)->CORINT     
                    (cCabAlias)->C6_XCOREXT := (cTrbAlias)->COREXT 
                    (cCabAlias)->C6_XMODVEI := (cTrbAlias)->MODVEI     
                    (cCabAlias)->C6_XDESMOD := (cTrbAlias)->DESCMOD
                    (cCabAlias)->C6_XSEGMOD	:= (cTrbAlias)->SEGMOD     
                    (cCabAlias)->C6_XDESSEG := (cTrbAlias)->DESCSEG
                    (cCabAlias)->C6_XFABMOD	:= (cTrbAlias)->FABMOD     
                    (cCabAlias)->C6_XGRPMOD := ""
                    (cCabAlias)->C6_XDGRMOD := ""                      
                    (cCabAlias)->C9_NFISCAL := CriaVar("C9_NFISCAL")
                    (cCabAlias)->C9_SERIENF := CriaVar("C9_SERIENF")
                (cCabAlias)->(MsUnLock())

                SC6->(RecLock("SC6",.F.))
                    SC6->C6_XCODMAR	:= (cTrbAlias)->MARCA  
                    SC6->C6_XDESMAR	:= (cTrbAlias)->DESCMAR
                    SC6->C6_XCORINT	:= (cTrbAlias)->CORINT
                    SC6->C6_XCOREXT	:= (cTrbAlias)->COREXT 
                    SC6->C6_XMODVEI	:= (cTrbAlias)->MODVEI
                    SC6->C6_XDESMOD	:= (cTrbAlias)->DESCMOD
                    SC6->C6_XSEGMOD	:= (cTrbAlias)->SEGMOD 
                    SC6->C6_XDESSEG	:= (cTrbAlias)->DESCSEG
                    SC6->C6_XFABMOD	:= (cTrbAlias)->FABMOD
                    SC6->C6_XGRPMOD	:= ""
                    SC6->C6_XDGRMOD	:= ""
                SC6->(MsUnLock())

                SC9->(RecLock("SC9",.F.))
                    SC9->C9_XCODMAR := (cTrbAlias)->MARCA 
                    SC9->C9_XMODVEI := (cTrbAlias)->MODVEI
                    SC9->C9_XSEGMOD := (cTrbAlias)->SEGMOD
                    SC9->C9_XFABMOD := (cTrbAlias)->FABMOD
                    SC9->C9_XCORINT := (cTrbAlias)->CORINT
                    SC9->C9_XCOREXT := (cTrbAlias)->COREXT
                    SC9->C9_XGRPMOD := ""
                SC9->(MsUnLock())

                cQuery := "" 
                cQuery +=  CrLf +  " UPDATE " + RetSqlName("VRK")
                cQuery +=  CrLf +  " SET VRK_CHASSI = '"+(cTmpAlias)->VV1_CHASSI+"' "
                cQuery +=  CrLf +  " WHERE VRK_FILIAL = '"+xFilial("VRK")+"' "
                cQuery +=  CrLf +  " AND VRK_PEDIDO||VRK_ITEPED = (SELECT VRK.VRK_PEDIDO||VRK.VRK_ITEPED "
                cQuery +=  CrLf +  "                               FROM "+RetSqlName("VRJ")+" VRJ "
                cQuery +=  CrLf +  "                               INNER JOIN " + RetSqlName("VRK") + " VRK"
                cQuery +=  CrLf +  "                                    ON  VRK.VRK_FILIAL = '" + xFilial("VRK") + "' "
                cQuery +=  CrLf +  "                                    AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO "
                cQuery +=  CrLf +  "                                    AND VRK.D_E_L_E_T_ = VRJ.D_E_L_E_T_ "
                cQuery +=  CrLf +  "                               WHERE VRJ.VRJ_FILIAL  = '" + xFilial("VRJ")  + "' "
                cQuery +=  CrLf +  "                                 AND VRJ.VRJ_CODCLI  = '" + SC5->C5_CLIENTE + "' "
                cQuery +=  CrLf +  "                                 AND VRJ.VRJ_LOJA    = '" + SC5->C5_LOJACLI + "' "
                cQuery +=  CrLf +  "                                 AND VRJ.VRJ_PEDCOM  = '" + SC6->C6_PEDCLI  + "' "
                cQuery +=  CrLf +  "                                 AND VRK.VRK_ITEPED  = '" + StrZero(Val(Alltrim(SC6->C6_ITEM)),3) + "' "
                cQuery +=  CrLf +  "                                 AND VRJ.D_E_L_E_T_  = ' ') "
                nStatus := TCSqlExec(cQuery)

                If (nStatus < 0)
                    MsgStop("TCSQLError() " + TCSQLError(), "Atualizacao Chassi VRK")
                EndIf

                DBCommitAll()
            Else
                //DisarmTransaction()
            EndIf
        //End Transaction
    EndIf

    If !lLibPed
    
        SC6->(RecLock("SC6",.F.))
            SC6->C6_LOTECTL := CriaVar("C6_LOTECTL")
            SC6->C6_DTVALID := CriaVar("C6_DTVALID")
            SC6->C6_NUMSERI := CriaVar("C6_NUMSERI")
            SC6->C6_CHASSI  := CriaVar("C6_CHASSI" )
            SC6->C6_LOCALIZ := CriaVar("C6_LOCALIZ")
            SC6->C6_XCODMAR := CriaVar("C6_XCODMAR")
            SC6->C6_XDESMAR	:= CriaVar("C6_XDESMAR")
            SC6->C6_XGRPMOD := CriaVar("C6_XGRPMOD")
            SC6->C6_XDGRMOD := CriaVar("C6_XDGRMOD")
            SC6->C6_XMODVEI	:= CriaVar("C6_XMODVEI")
            SC6->C6_XDESMOD	:= CriaVar("C6_XDESMOD")
            SC6->C6_XSEGMOD	:= CriaVar("C6_XSEGMOD")
            SC6->C6_XDESSEG	:= CriaVar("C6_XDESSEG")
            SC6->C6_XFABMOD	:= CriaVar("C6_XFABMOD")
            SC6->C6_XCORINT	:= CriaVar("C6_XCORINT")
            SC6->C6_XCOREXT	:= CriaVar("C6_XCOREXT")
        SC6->(MsUnLock())

        (cCabAlias)->(RecLock(cCabAlias,.F.))
            (cCabAlias)->C6_CHASSI  := CriaVar("C6_CHASSI" )
            (cCabAlias)->C6_NUMSERI := CriaVar("C6_NUMSERI")
            (cCabAlias)->C6_LOCALIZ := CriaVar("C6_LOCALIZ")
        (cCabAlias)->(MsUnLock())
    
        DBCommitAll()
    
    EndIf
    EndIf
    (cCabAlias)->(DbSkip())
EndDo

SC6->(DbSetOrder(1))
(cCabAlias)->(DbGoTop())

While (cCabAlias)->(!Eof())
    nRecno := (cCabAlias)->(Recno())    

    If Empty(Alltrim((cCabAlias)->C6_CHASSI)) .Or. Empty(Alltrim((cCabAlias)->C6_NUMSERI))        
        
        SC6->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))
        SC6->(RecLock("SC6",.F.))
            SC6->C6_LOTECTL := CriaVar("C6_LOTECTL") 
            SC6->C6_DTVALID := CriaVar("C6_DTVALID") 
            SC6->C6_NUMSERI := CriaVar("C6_NUMSERI")
            SC6->C6_CHASSI  := CriaVar("C6_CHASSI" ) 
            SC6->C6_LOCALIZ := CriaVar("C6_LOCALIZ") 
            SC6->C6_XCODMAR := CriaVar("C6_XCODMAR")
            SC6->C6_XDESMAR	:= CriaVar("C6_XDESMAR")
            SC6->C6_XGRPMOD := CriaVar("C6_XGRPMOD")
            SC6->C6_XDGRMOD := CriaVar("C6_XDGRMOD")
            SC6->C6_XMODVEI	:= CriaVar("C6_XMODVEI") 
            SC6->C6_XDESMOD	:= CriaVar("C6_XDESMOD")
            SC6->C6_XSEGMOD	:= CriaVar("C6_XSEGMOD")
            SC6->C6_XDESSEG	:= CriaVar("C6_XDESSEG") 
            SC6->C6_XFABMOD	:= CriaVar("C6_XFABMOD")
            SC6->C6_XCORINT	:= CriaVar("C6_XCORINT")
            SC6->C6_XCOREXT	:= CriaVar("C6_XCOREXT")
        SC6->(MsUnLock())

        (cCabAlias)->(RecLock(cCabAlias,.F.))
        (cCabAlias)->(DBDelete())
        (cCabAlias)->(MsUnLock())
    
    EndIf

    (cCabAlias)->(DbGoTo(nRecno))
    (cCabAlias)->(DbSkip())
EndDo

If !Empty(Alltrim(cNumPed))
    (cCabAlias)->(DBClearFilter())
EndIf

TcRefresh(oCabTable:GetTableNameForQuery())

If ValType(oBrwCab) <> "U"
    nAt     := oBrwCab:nAt
    nLinPos := nAt
    oBrwCab:GoTop(.T.)
    oBrwCab:LineRefresh(nAt)
    //oBrwCab:GoTop(.T.)
    oBrwCab:GoTo(nAt)
    oBrwCab:Refresh()
    /*
	oBrwCab:GoTo(nAt)
	oBrwCab:LineRefresh() //só refaz a linha
    oBrwCab:GoTop(.T.)
    oBrwCab:UpdateBrowse() //reconstroi tudo	
    oBrwCab:Refresh()
    oBrwCab:GoTo(nAt)
    oBrwCab:Refresh()
    oNwFat001:Refresh()
    */

EndIf


//(cCabAlias)->(DbGoTop())

Return()

/*
=======================================================================================
Programa.:           fGeraDocs   
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

*************************************************************
Static Function fGeraDocs(cCabAlias,cIteAlias,oSay,cIteTable)
*************************************************************

Local   aTmpPVl     As Array
Local   aPVlNFs     As Array
Local   lUsaNewKey  As Logical
Local   lContinua   As Logical
Local   cSerieId    As Character
Local   aDadosDoc   As Array
Local   nStatus     As Numeric 

Private cSerie      As Character
Private cNotaSer    As Character

aDadosDoc  := {}
lUsaNewKey := GetSX3Cache("F2_SERIE","X3_TAMANHO") == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso
cSerieId   := IIf( lUsaNewKey , SerieNfId("SF2",4,"F2_SERIE",dDataBase,A460Especie(cSerie),cSerie) , cSerie )

Dbselectarea("SC6") ; SC6->(DbSetOrder(RetOrder("SC6","C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO" )))
Dbselectarea("SC5") ; SC5->(DbSetOrder(RetOrder("SC5","C5_FILIAL+C5_NUM"                    )))
Dbselectarea("SC9") ; SC9->(DbSetOrder(1))
Dbselectarea("SF4") ; SF4->(DbSetOrder(1))
Dbselectarea("SE4") ; SE4->(DbSetOrder(1))
Dbselectarea("SB1") ; SB1->(DbSetOrder(1)) 
Dbselectarea("SB2") ; SB2->(DbSetOrder(1))

lContinua := .F.
(cCabAlias)->(DbGotop())
While (cCabAlias)->(!Eof()) 
    
    If !Empty(Alltrim((cCabAlias)->C6_OK))
        lContinua := .T.
        Exit
    EndIf

    (cCabAlias)->(DbSkip())
EndDo

If !lContinua
    Return(.T.)
EndIf

lContinua := Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS"),,,,@cSerieId,dDataBase ) // O parametro cSerieId deve ser passado para funcao Sx5NumNota afim de tratar a existencia ou nao do mesmo numero na funcao VldSx5Num do MATXFUNA.PRX

(cCabAlias)->(DbGotop())
While (cCabAlias)->(!Eof()) .And. lContinua

    oSay:SetText("Faturando pedido: " + (cCabAlias)->C6_NUM+" ...")

    If !Empty(Alltrim((cCabAlias)->C6_OK))
        SC5->( DbSetOrder( RetOrder( "SC5","C5_FILIAL+C5_NUM" ) ) )
        
        If SC5->(DbSeek(xFilial("SC5")+(cCabAlias)->C6_NUM))
            SC6->(DbSetOrder(RetOrder("SC6","C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO" )))
            
            If SC6->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))
                SC9->(DbSetOrder(1))
            
                If SC9->( DbSeek( xFilial("SC6") + (cCabAlias)->C6_NUM + (cCabAlias)->C6_ITEM + (cCabAlias)->C9_SEQUEN ) ) .And. ;
                    Empty(Alltrim(SC9->C9_BLEST  )) .And. Empty(Alltrim(SC9->C9_BLCRED )) .And. Empty(Alltrim(SC9->C9_NFISCAL))

                    SB1->(DbSetOrder(1)) ; SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO              ))
                    SB2->(DbSetOrder(2)) ; SB2->(DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL))
                    SE4->(DbSetOrder(1)) ; SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG              ))
                    SF4->(DbSetOrder(1)) ; SF4->(DbSeek(xFilial("SF4")+(cCabAlias)->C6_TES          ))
                    
                    aTmpPVl   := {}
	                aPVlNFs   := {}
                  //lContinua := Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS"),,,,@cSerieId,dDataBase ) // O parametro cSerieId deve ser passado para funcao Sx5NumNota afim de tratar a existencia ou nao do mesmo numero na funcao VldSx5Num do MATXFUNA.PRX
                    cNotaSer  := Criavar("F2_DOC"  )

                    /*If !lContinua
                        Return()
                    EndIf*/

            	    Aadd( aTmpPVl , SC9->C9_PEDIDO  )
                    Aadd( aTmpPVl , SC9->C9_ITEM    )
                    Aadd( aTmpPVl , SC9->C9_SEQUEN  )
	                Aadd( aTmpPVl , SC9->C9_QTDLIB  )
                    Aadd( aTmpPVl , SC9->C9_PRCVEN  )
                    Aadd( aTmpPVl , SC9->C9_PRODUTO )
	                Aadd( aTmpPVl , SF4->F4_ISS=="S")
                    Aadd( aTmpPVl , SC9->(RecNo())  )
                    Aadd( aTmpPVl , SC5->(Recno())  )
	                Aadd( aTmpPVl , SC6->(Recno())  )
                    Aadd( aTmpPVl , SE4->(Recno())  )
                    Aadd( aTmpPVl , SB1->(Recno())  )
	                Aadd( aTmpPVl , SB2->(Recno())  )
                    Aadd( aTmpPVl , SF4->(Recno())  )
                    Aadd( aTmpPVl , SC9->C9_LOCAL   )
	                Aadd( aTmpPVl , 1               )
                    Aadd( aTmpPVl , SC9->C9_QTDLIB2 )
		
	                Aadd( aPVlNFs, aClone(aTmpPVl))
	                /*
                    *****************************
	                *'Gera nota fiscal de saída.'*
	                *****************************
                    */
	                cNotaSer  := MAPVLNFS(aPVlNFs,cSerie,.F.,.F.,.T.,.F.,.F.,1,0,.T.,.F.,,,)
                    
                    SF2->(DbSetOrder(1))
					If SF2->(DbSeek(xFilial("SF2")+cNotaSer+cSerie))
                        SA1->(DbSetOrder(1))
                        SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
                        Aadd(aDadosDoc,{SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_EMISSAO,SF2->F2_CLIENTE,SF2->F2_LOJA,SA1->A1_NOME,SF2->F2_VALBRUT,SF2->F2_VALMERC})

                        SD2->(DbSetOrder(3))
                        SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
                        While SD2->(!Eof()) .And. SD2->D2_DOC     == SF2->F2_DOC     .And. SD2->D2_SERIE == SF2->F2_SERIE   ;
                                            .And. SD2->D2_CLIENTE == SF2->F2_CLIENTE .And. SD2->D2_LOJA  == SF2->F2_LOJA
                            SDB->(DbSetOrder(1))
                            
                            If SDB->(DbSeek(xFilial("SDB")+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ))
                                VV1->(DbSetOrder(2))
                                
                                If VV1->(DbSeek(xFilial("VV1")+SDB->DB_NUMSERI))
                                    VV1->(RecLock("VV1",.F.))
                                    VV1->VV1_SITVEI := "1"
                                    VV1->VV1_ULTMOV := "S"
                                    VV1->(MsUnLock())

                                    U_VM011DNF() //Gera a Tabela CD9
                                    If !Empty(Alltrim((cCabAlias)->C6_PEDCLI))
                                        cQuery := ""
                                        cQuery += " UPDATE "+RetSqlName("VRJ")
                                        cQuery += " SET VRJ_STATUS = 'F' , "
                                        cQuery += "     VRJ_XINTEG = ' ' "
                                        cQuery += " WHERE  VRJ_FILIAL = '" + xFilial("VRJ")         + "'" 
                                        cQuery += "    AND VRJ_PEDCOM = '" + (cCabAlias)->C6_PEDCLI + "'"
                                        cQuery += "    AND D_E_L_E_T_ = ' '"
                                        nStatus := TCSqlExec(cQuery)

                                        If (nStatus < 0)
                                            MsgStop("TCSQLError() " + TCSQLError(), "Erro atualizacao VRJ")                                    
                                        EndIf
                           
                                        cQuery := "  UPDATE " + RetSqlName("VRK") + " VRK "
                                        cQuery += "     SET VRK.VRK_ITETRA = '01', "
                                        cQuery += "         VRK.VRK_NUMTRA = 'F" + SD2->D2_DOC + "' "
                                        cQuery += " WHERE   VRK.VRK_CHASSI = '"  + SDB->DB_NUMSERI + "' "
                                        cQuery += "     AND VRK.VRK_ITETRA = ' ' "
                                        cQuery += "     AND VRK.VRK_PEDIDO = (SELECT VRJ.VRJ_PEDIDO "
                                        cQuery += "                             FROM " + RetSqlName("VRJ") + " VRJ "
                                        cQuery += "                             WHERE  VRJ.VRJ_PEDCOM = '" + (cCabAlias)->C6_PEDCLI + "')"
                                        nStatus := TCSqlExec(cQuery)

                                        If (nStatus < 0)
                                            MsgStop("TCSQLError() " + TCSQLError(), "Erro atualizacao VRK")                                    
                                        EndIf
                                        //U_CMVAUT04((cCabAlias)->VRJ_PEDIDO)
                                    EndIf
                                EndIf
                            EndIf
                            SD2->(DbSkip())
                        EndDo
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
    (cCabAlias)->(DbSkip())
EndDo

If Len(aDadosDoc) <> 0
    NotaDados(aDadosDoc)
EndIf

if lContinua
    StartJob("U_CMVAUT04", GetEnvServer(), .F.)//, cEmpAnt, cFilAnt)
endif

Return(Nil)

/*
=======================================================================================
Programa.:             NotaDados 
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

************************************
Static Function NotaDados(aDadosDoc)
************************************

Local   aObjects  As Array
Local   aInfo     As Array
Local   aSizeAut  As Array
Local   aPosObj   As Array
Local   aButtons  As Array
Private oGerNota  As Object

aObjects  := {}
aInfo     := {}
aSizeAut  := MsAdvSize()
aPosObj   := {}
aButtons  := {}

Aadd( aObjects, { 50, 40, .T., .T., .T. } )
Aadd( aObjects, { 60, 70, .T., .T. ,.T.} )

aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, , .T. )
   
//Monta o dialog Principal
oGerNota:= MSDIALOG():Create()
oGerNota:cName      := "oGerNota"
oGerNota:cCaption   := "Notas Fiscais Geradas"
oGerNota:nLeft      := aSizeAut[7]
oGerNota:nTop       := aSizeAut[1]
oGerNota:nWidth     := aSizeAut[5]
oGerNota:nHeight    := aSizeAut[6]+25
oGerNota:lShowHint  := .F.
oGerNota:lCentered  := .T.
oGerNota:bInit      := {|| EnchoiceBar(oGerNota,{||oGerNota:End()},{||oGerNota:End()},,aButtons,,,.F.,.F.,.F.,.F.,.F.,.F. ) }

InstObj(@oGerNota,aDadosDoc)

Return

/*
=======================================================================================
Programa.:              InstObj
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

*******************************************
Static Function InstObj(oGerNota,aDadosDoc)
*******************************************

Local   aSizeAut    As Array
Private aListDocs   As Array
Private lMarkAll    As Logical
Private oListDocs   As Object
Default oGerNota    := Nil

aSizeAut    := MsAdvSize()
aListDocs   := {}
lMarkAll    := .T.

fwfreeobj(oListDocs)
oListDocs := Nil

@ aSizeAut[2],aSizeAut[1] LISTBOX oListDocs FIELDS HEADER "Serie","Numero","Data Emissão","Cliente","Loja","Nome"/*,"Valor Bruto","Valor Produtos"*/  SIZE aSizeAut[3],aSizeAut[4]-21.5 PIXEL OF oGerNota

oListDocs:SetArray( aDadosDoc )
oListDocs:bLine := {||{aDadosDoc[oListDocs:nAt,1],;
                       aDadosDoc[oListDocs:nAt,2],;
                       aDadosDoc[oListDocs:nAt,3],;
                       aDadosDoc[oListDocs:nAt,4],;
                       aDadosDoc[oListDocs:nAt,5],;
                       aDadosDoc[oListDocs:nAt,6]}}/*,;
                       aDadosDoc[oListDocs:nAt,7],;
                       aDadosDoc[oListDocs:nAt,8]}}*/

oGerNota:Activate() //Exibe a dialog ao usuario

Return

/*
=======================================================================================
Programa.:              fCanNotas
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

Static Function fCanNotas(oSay)

Mata521A()
Estor(oSay)

Return(Nil)

/*
=======================================================================================
Programa.:              fDevNotas
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

***************************
Static Function fDevNotas()
***************************

Private INCLUI := .T.
Private ALTERA := .F.

Return U_ZFATF020("SF1",1,3)

/*
=======================================================================================
Programa.:             FMark 
Autor....:              
Data.....:              
Descricao / Objetivo: Executa a gravação do retorno da Consulta Específica.

@Param...:	oBrowse     - Objeto da Browse
			cReadVar	- Campo de retorno da Consulta Específica
			cChave		- Campo(s) a serem gravados no retorno da Consulta Específica
			lMult		- Indica se a tela permição selec de múltiplos registros

=======================================================================================
*/

******************************
Static function FMark(oBrowse)
******************************

Local cAlias	:=	oBrowse:Alias()
Local cMark	    :=	cMarca //oBrowse:Mark()
Local nRecno    := 0
Local nPos      := 0

nRecno := (cAlias)->(Recno()) 
If RecLock(cAlias, .F. )
    (cAlias)->C6_OK := Iif( (cAlias)->C6_OK == cMark, "  ", cMark )
	(cAlias)->(MsUnlock())
EndIf  

aBrwCli := {}
aBrwPrd := {}
aBrwTot := {}

(cAlias)->(DbGoTop())
While (cAlias)->(!Eof())
    If !Empty((cAlias)->C6_OK)
        nPos := aScan(aBrwCli,{|x| x[1] == (cAlias)->C5_CLIENTE+(cAlias)->C5_LOJACLI})
        If nPos <> 0
            aBrwCli[nPos,03] := Transform(Val(StrTran(StrTran(alltrim(aBrwCli[nPos,03]),".",""),",","."))+(cAlias)->C6_XVLRVDA,"@E 99,999,999.99")
            
        Else
            Aadd(aBrwCli,{(cAlias)->C5_CLIENTE+(cAlias)->C5_LOJACLI,(cAlias)->A1_NOME,Transform((cAlias)->C6_XVLRVDA,"@E 99,999,999.99")})
        EndIf

        nPos := aScan(aBrwPrd,{|x| x[1] == (cAlias)->C6_PRODUTO})
        If nPos <> 0
            aBrwPrd[nPos,03] := Transform(Val(StrTran(StrTran(alltrim(aBrwPrd[nPos,03]),".",""),",","."))+(cAlias)->C6_XVLRVDA,"@E 99,999,999.99")            
        Else
            Aadd(aBrwPrd,{(cAlias)->C6_PRODUTO,(cAlias)->B1_DESC,Transform((cAlias)->C6_XVLRVDA,"@E 99,999,999.99")})
        EndIf

        If Len(aBrwTot) == 0
            Aadd(aBrwTot,{Transform((cAlias)->C6_XVLRVDA,"@E 99,999,999.99")})
        Else
            aBrwTot[01,01] := Transform(Val(StrTran(StrTran(alltrim(aBrwTot[01,01]),".",""),",","."))+(cAlias)->C6_XVLRVDA,"@E 99,999,999.99")            
        EndIf

    EndIf
    (cAlias)->(DbSkip())
EndDo

(cAlias)->(DbGoTo(nRecno))
oTBrwsCli:SetArray(aBrwCli) 
//oTBrwsCli:Refresh()

oTBrwsPrd:SetArray(aBrwPrd)
//oTBrwsPrd:Refresh()

oTBrwsTot:SetArray(aBrwTot)
//oTBrwsTot:Refresh()

//fResFat()
//oBrowse:Refresh()
//oDlg01:Refresh()

Return 

/*
=======================================================================================
Programa.:              FMarkAll
Autor....:              
Data.....:              
Descricao / Objetivo:  Inverte a indicação de seleção de todos registros do Browse.
@Param...:		       oBrowse	->	Objeto contendo campo de seleção
=======================================================================================
*/
***********************************
Static Function FMarkAll( oBrowse )
***********************************

Local cAlias	as character
Local cMark	    as character
Local nRecno	as numeric

cAlias	:=	oBrowse:Alias()
cMark	:=	cMarca //oBrowse:Mark()
nRecno	:=	( cAlias )->( Recno() )
aBrwCli := {}
aBrwPrd := {}
aBrwTot := {}

( cAlias )->( DBGoTop() )
While ( cAlias )->( !Eof() )
	
    If RecLock( cAlias, .F. )
		( cAlias )->C6_OK := Iif( alltrim(( cAlias )->C6_OK) == cMark, "  ", cMark )
		( cAlias )->( MsUnlock() ) 
	EndIf

    If !Empty((cAlias)->C6_OK)
        nPos := aScan(aBrwCli,{|x| x[1] == (cAlias)->C5_CLIENTE+(cAlias)->C5_LOJACLI})
        If nPos <> 0
            aBrwCli[nPos,03] := Transform(Val(StrTran(StrTran(alltrim(aBrwCli[nPos,03]),".",""),",","."))+(cAlias)->C6_XVLRVDA,"@E 99,999,999.99")
            
        Else
            Aadd(aBrwCli,{(cAlias)->C5_CLIENTE+(cAlias)->C5_LOJACLI,(cAlias)->A1_NOME,Transform((cAlias)->C6_XVLRVDA,"@E 99,999,999.99")})
        EndIf

        nPos := aScan(aBrwPrd,{|x| x[1] == (cAlias)->C6_PRODUTO})
        
        If nPos <> 0
            aBrwPrd[nPos,03] := Transform(Val(StrTran(StrTran(alltrim(aBrwPrd[nPos,03]),".",""),",","."))+(cAlias)->C6_XVLRVDA,"@E 99,999,999.99")            
        Else
            Aadd(aBrwPrd,{(cAlias)->C6_PRODUTO,(cAlias)->B1_DESC,Transform((cAlias)->C6_XVLRVDA,"@E 99,999,999.99")})
        EndIf

        If Len(aBrwTot) == 0
            Aadd(aBrwPrd,{Transform((cAlias)->C6_XVLRVDA,"@E 99,999,999.99")})
        Else
            aBrwTot[01,03] := Transform(Val(StrTran(StrTran(alltrim(aBrwPrd[01,01]),".",""),",","."))+(cAlias)->C6_XVLRVDA,"@E 99,999,999.99")            
        EndIf

    EndIf
	( cAlias )->( DBSkip() )
End

( cAlias )->( DBGoTo( nRecno ) )

oTBrwsCli:SetArray(aBrwCli) 
//oTBrwsCli:Refresh()

oTBrwsPrd:SetArray(aBrwPrd)
//oTBrwsPrd:Refresh()

oTBrwsTot:SetArray(aBrwPrd)
//oTBrwsTot:Refresh()

//fResFat()
//oBrowse:Refresh()
//oDlg01:Refresh()

Return()

/*
=======================================================================================
Programa.:             fResFat 
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

*************************
Static Function fResFat()
*************************

Local   aObjects  As Array
Local   aInfo     As Array
Local   aSizeAut  As Array
Local   aPosObj   As Array
Local   aButtons  As Array

Private aListDocs As Array
Private lMarkAll  As Logical
Public  oResFat   As Object

aObjects  := {}
aInfo     := {}
aSizeAut  := MsAdvSize()
aPosObj   := {}
aButtons  := {}

Aadd( aObjects, { 50, 40, .T., .T., .T. } )
Aadd( aObjects, { 60, 70, .T., .T. ,.T.} )

aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, , .T. )
   
aDadosDoc := {{"000001","01","CARLOS LEOANRDO FERREIRA DE MIRANDA","100.000.000,00"}}
fwfreeobj(oResFat)
oResFat := Nil

@ aSizeAut[2],aSizeAut[1] LISTBOX oResFat FIELDS HEADER "Cliente","Loja","Nome","Valor"  SIZE aSizeAut[3],aSizeAut[4]-21.5 PIXEL OF oPnlWnd2

oResFat:SetArray( aDadosDoc )
/*
oResFat:bLine := {||{aDadosDoc[oResFat:nAt,1],;
                     aDadosDoc[oResFat:nAt,2],;
                     aDadosDoc[oResFat:nAt,3],;
                     aDadosDoc[oResFat:nAt,4]}}
*/
Return

/*
=======================================================================================
Programa.:             Boleto 
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

*********************************
Static Function Boleto(cCabAlias)
*********************************

Local aArea		:= GetArea()
Local aAreaVRJ	:= VRJ->(GetArea())
Local aAreaSE1	:= SE1->(GetArea())
Local cPerg		:= "CMVBOLVEI"

ValidPerg(cPerg)

DbSelectArea("SE1")
SE1->(DbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

If SE1->(DbSeek(xFilial("SE1") + "PVM" + (cCabAlias)->C6_NUM))

	If Pergunte(cPerg)
		U_RF01B062(/*xBanco*/MV_PAR02,/*xAgencia*/MV_PAR03,/*xConta*/MV_PAR04,/*xSubCt*/MV_PAR01,/*lSetup*/,/*cNotIni*/,/*cNotFim*/,/*cSerie*/,SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM))
	EndIf

Else
	Alert("Não Existe Titulo para esse Pedido ")
EndIf

RestArea(aAreaSE1)
RestArea(aAreaVRJ)
RestArea(aArea)

Return

/*
=======================================================================================
Programa.:              ValidPerg
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

********************************
Static Function ValidPerg(cPerg)
********************************

Local _sAlias := Alias()
Local aRegs   := {}
Local i,j

DbSelectArea("SX1")
DbSetOrder(1)

cPerg := PADR(cPerg,10)
Aadd(aRegs,{cPerg,"01","SubConta       ?","","","mv_ch1","C",3,0,1,"G" ,"","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"02","Banco          ?","","","mv_ch2","C",3,0,1,"G" ,"","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","","",""})
Aadd(aRegs,{cPerg,"03","Agencia        ?","","","mv_ch3","C",5,0,1,"G" ,"","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"04","Conta          ?","","","mv_ch4","C",10,0,1,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 To Len(aRegs)
	If !DbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 To FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			EndIf
		Next
		MsUnlock()
	Endif
Next

DbSelectArea(_sAlias)

Return()

/*
=======================================================================================
Programa.:              AtuTbPrc
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

**************************
Static Function AtuTbPrc()
**************************

Private cPerg     := "ZVEIF004"

// Cria as perguntas em SX1
Criaperg()
	
// Monta tela de paramentos para usuario, se cancelar sair
If !Pergunte(cPerg,.T.)
   Return
End    
    
MsAguarde({|| fBuscPed()}, "Aguarde...", "Selecionando os Pedidos em Abertos...")

Return(.T.)

/*
=======================================================================================
Programa.:              fBuscPed
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

**************************
Static Function fBuscPed()
**************************

Local cQuery     := ""
Local cQry       := ""
Local lRet       := .T.
Local nTotal     := 0
Local nAtual     := 0
Local aDados     := {}
Local cPedidos   := GetNextAlias()
Local cQtPed     := GetNextAlias()
Private cErro    := ""
    
cQry := CrLf + " SELECT * "
cQry += CrLf + " FROM "+RetSQLName("VRJ") + " VRJ "
cQry += CrLf + "    WHERE   VRJ.VRJ_FILIAL  = '" + xFilial("VRJ") + "' "
cQry += CrLf + "        AND VRJ.VRJ_STATUS  = 'A' "
cQry += CrLf + "        AND VRJ_DATDIG      >= '"  + DTOS(MV_PAR01) + "' AND VRJ_DATDIG <= '"  + DTOS(MV_PAR02) + "'"
cQry += CrLf + "        AND VRJ.D_E_L_E_T_  = ' ' "

cQry := ChangeQuery(cQry)

If Select(cQtPed) > 0 ; (cQtPed)->(DbCloseArea()) ; EndIf
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cQtPed,.T.,.T.)                  
If Select(cQtPed) > 0 ; Count To nTotal           ; EndIf

cQuery :=  CrLf + " SELECT  C6_FILIAL       FILIAL  ,"
cQuery +=  CrLf + "         C6_PEDCLI       PEDCOM  ,"
cQuery +=  CrLf + "         C5_CONDPAG      FORPAG  ,"
cQuery +=  CrLf + "         C5_CLIENTE      CODCLI  ,"
cQuery +=  CrLf + "         C5_LOJACLI      LOJA    ,"
cQuery +=  CrLf + "         VRJ_DATDIG      DATDIG  ,"
cQuery +=  CrLf + "         C5_NATUREZ      NATURE  ,"
cQuery +=  CrLf + "         VRJ_STATUS      STATUS  ,"
cQuery +=  CrLf + "         C6_NUM          PEDIDO  ,"
cQuery +=  CrLf + "         C6_ITEM         ITEPED  ,"
cQuery +=  CrLf + "         C6_XMODVEI      MODVEI  ,"
cQuery +=  CrLf + "         SC6.R_E_C_N_O_  RECNO   ,"
cQuery +=  CrLf + "         C6_OPER         OPER    ,"
cQuery +=  CrLf + "         C6_XSEGMOD      SEGMOD  ,"
cQuery +=  CrLf + "         C6_XFABMOD      FABMOD  ,"
cQuery +=  CrLf + "         C6_XCOREXT      COREXT  ,"
cQuery +=  CrLf + "         C6_XCORINT      CORINT  ,"
cQuery +=  CrLf + "         C6_CHASSI       CHASSI  ,"
cQuery +=  CrLf + "         C6_XCODMAR      CODMAR  ,"
cQuery +=  CrLf + "         C6_XPRCTAB      VALTAB  ,"
cQuery +=  CrLf + "         C6_TES          TES     ,"
cQuery +=  CrLf + "         C6_XVLRVDA      VALVDA  ,"
cQuery +=  CrLf + "         C6_XVLRPRD      VALPRE  ,"
cQuery +=  CrLf + "         C6_PRCVEN       VALMOV  ,"
cQuery +=  CrLf + "         C6_XBASST       XBASST  ,"
cQuery +=  CrLf + "         UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C5_XMENSER, 2000, 1)) OBSPED  "
cQuery +=  CrLf + " FROM " + RetSQLName("SC6") + " SC6 "

cQuery +=  CrLf + "     INNER JOIN " + RetSQLName("SC5") + " SC5 "
cQuery +=  CrLf + "         ON  SC5.C5_FILIAL  = SC6.C6_FILIAL "
cQuery +=  CrLf + "         AND SC5.C5_NUM     = SC6.C6_NUM    "
cQuery +=  CrLf + "         AND SC5.D_E_L_E_T_ = ' ' "

cQuery +=  CrLf + " WHERE  SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "
cQuery +=  CrLf + "     AND SC6.C6_QTDEMP  = 0             "
cQuery +=  CrLf + "     AND SC6.C6_NOTA    = ' '           "
cQuery +=  CrLf + "     AND SC6.C6_QTDENT < SC6.C6_QTDVEN  "
cQuery +=  CrLf + "     AND SC6.C6_BLQ    IN(' ','N')      "
cQuery +=  CrLf + "     AND SC6.C6_ENTREG BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "'"
cQuery +=  CrLf + "     AND SC6.D_E_L_E_T_ = ' ' "
cQuery +=  CrLf + " ORDER BY SC6.C6_NUM,SC6.C6_ITEM "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cPedidos,.T.,.T.)
If Select(cPedidos) > 0

    ProcRegua(nTotal)
    (cPedidos)->(DbGoTop())

    While !(cPedidos)->(EOF())
        aDados  := {}
        cPed    := (cPedidos)->PEDIDO
        nAtual  ++

        While !(cPedidos)->(Eof()) .And. (cPedidos)->PEDIDO == cPed
            MsProcTxt("Atualizando Pedidos: " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "  Pedido:" + cPed  )
    
            //Busca preço da tabela
            nPrec     := (cPedidos)->VALTAB
            _nXBasst  := (cPedidos)->XBASST
            nPrec     := BuscaTab( (cPedidos)->FILIAL , (cPedidos)->CODMAR , (cPedidos)->MODVEI , (cPedidos)->SEGMOD , (cPedidos)->FABMOD ) 
            _nXBasst  := BuscaSt( (cPedidos)->FILIAL  , (cPedidos)->CODMAR , (cPedidos)->MODVEI , (cPedidos)->SEGMOD , (cPedidos)->FABMOD ) 

            Aadd(aDados,{  (cPedidos)->FILIAL , (cPedidos)->PEDIDO , (cPedidos)->ITEPED , nPrec, nPrec, _nXBasst, (cPedidos)->TES , (cPedidos)->OPER })

            (cPedidos)->(DbSkip())
        EndDo

        If !AtualPed( aDados )
            MsgInfo("Pedidos  " + cPed +  "  Não Atualizado!", "Atualiza Preço Tabela")
            MsgInfo(cErro)
            cErro := " "
        EndIf

        If !AtuXBAS( aDados )
            MsgInfo("Pedidos  " + cPed +  "  Não Atualizado!", "Atualiza Preço Tabela")
            MsgInfo(cErro)
            cErro := " "
        EndIf
    EndDo

    (cPedidos)->(DbCloseArea())
    MsgInfo("Pedidos  Atualizados com Sucesso!", "Atualiza Preço Tabela") 
Else
    lRet := .F. 
    MsgAlert("Não Existem Pedidos em Abertos para Atualizar!", "Atualiza Preço Tabela")
EndIf

Return lRet

/*
=======================================================================================
Programa.:             AtualPed 
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

*********************************
Static Function AtualPed(aCampos)
*********************************

Local i          := 1
Local lRet       := .T.
Local oModel     := FWLoadModel( 'VEIA060' )           //Modelo
Local oModelVRK  := oModel:GetModel( "MODEL_VRK" )    //SubModelo

ProcRegua(Len(aCampos))

DbSelectArea("VRK")
VRK->(DbSetOrder(1))
    
oModel:SetOperation( 4 )  //Alteração

For i:=1 to Len(aCampos)

    dbSelectArea( 'VRJ' )
    VRJ->( dbSetOrder(1) )
    
    If VRJ->( dbSeek( aCampos[i][1] + ALLTRIM(aCampos[i][2] ) ))
       oModel:Activate()
    
       If ( oModelVRK:SeekLine({{"VRK_FILIAL", aCampos[i][1]}, {"VRK_PEDIDO", ALLTRIM(aCampos[i][2])}, {"VRK_ITEPED", aCampos[i][3]} })  .And. !oModelVRK:IsDeleted() )	
            If !( oModel:SetValue("MODEL_VRK", "VRK_VALTAB"  , (aCampos[I][4] ) ) ) 
                lRet := .F.
                Exit
            EndIf
    
            If !( oModel:SetValue("MODEL_VRK", "VRK_VALPRE"  , (aCampos[I][5] ) ) ) 
                lRet := .F.
                Exit
            EndIf
    
            If !( oModel:SetValue("MODEL_VRK", "VRK_XBASST"  , (aCampos[I][6] ) ) ) 
                lRet := .F.
                Exit
            EndIf
    
            If !( oModel:SetValue("MODEL_VRK", "VRK_CODTES"  , (aCampos[I][7] ) ) ) 
                lRet := .F.
                Exit
            EndIf
    
            If !( oModel:SetValue("MODEL_VRK", "VRK_OPER"  , (aCampos[I][8] ) ) ) 
                lRet := .F.
                Exit
            EndIf
    
            If lRet
                If ( lRet := oModel:VldData() )
                    oModel:CommitData()
                EndIf
            EndIf
    
            If !lRet
                aErro := oModel:GetErrorMessage()
                cErro +=  "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']'+CRLF 
                cErro +=  "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']'+CRLF
                cErro +=  "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']'+CRLF
                cErro +=  "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']'+CRLF
                cErro +=  "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']'+CRLF
                cErro +=  "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']'+CRLF
                cErro +=  "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']'+CRLF
                cErro +=  "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']'+CRLF
                cErro +=  "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']'+CRLF
                cErro += "Filial: " + aCampos[i][1] + " PEDIDO: " + aCampos[i][2] + " ITEM " + aCampos[i][3]  + CRLF
            Endif
            oModel:DeActivate()
        Else
            Conout( "não encontrados as linhas do Pedido: " + "Filial: " + aCampos[i][1] + " Pedido: " + aCampos[i][2] + " Item " + aCampos[i][3] )
            lRet := .F.
        EndIf
    EndIf
Next i

Return lRet

/*
=====================================================================================
Programa.:              AtuXBAS
Autor....:              CAOA - Sandro Ferreira
Data.....:              11/02/2022
Descricao / Objetivo:   Atualiza os Pedidos Selecionados -  Automatica preço de Venda
===================================================================================== 
*/

Static Function AtuXBAS( aCampos )

Local i          := 1
Local lRet       := .T.
Local oModel     := FWLoadModel( 'VEIA060' )           //Modelo
Local oModelVRK  := oModel:GetModel( "MODEL_VRK" )    //SubModelo

ProcRegua(Len(aCampos))

DbSelectArea("VRK")
VRK->(DbSetOrder(1))
    
oModel:SetOperation( 4 )  //Alteração
For i:=1 to Len(aCampos)
    dbSelectArea( 'VRJ' )
    VRJ->( dbSetOrder(1) )

    If VRJ->( dbSeek( aCampos[i][1] + ALLTRIM(aCampos[i][2] ) ))
       oModel:Activate()
       If ( oModelVRK:SeekLine({{"VRK_FILIAL", aCampos[i][1]}, {"VRK_PEDIDO", ALLTRIM(aCampos[i][2])}, {"VRK_ITEPED", aCampos[i][3]} })  .And. !oModelVRK:IsDeleted() )	

           If !( oModel:SetValue("MODEL_VRK", "VRK_XBASST"  , (aCampos[I][6] ) ) ) 
               lRet := .F.
                Exit
            EndIf
            If lRet
                If ( lRet := oModel:VldData() )
                    oModel:CommitData()
                EndIf
            EndIf
            If !lRet
                aErro := oModel:GetErrorMessage()
                cErro +=  "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']'+CRLF 
                cErro +=  "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']'+CRLF
                cErro +=  "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']'+CRLF
                cErro +=  "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']'+CRLF
                cErro +=  "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']'+CRLF
                cErro +=  "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']'+CRLF
                cErro +=  "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']'+CRLF
                cErro +=  "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']'+CRLF
                cErro +=  "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']'+CRLF
                cErro += "Filial: " + aCampos[i][1] + " PEDIDO: " + aCampos[i][2] + " ITEM " + aCampos[i][3]  + CRLF
            Endif
            oModel:DeActivate()
        Else
            Conout( "não encontrados as linhas do Pedido: " + "Filial: " + aCampos[i][1] + " Pedido: " + aCampos[i][2] + " Item " + aCampos[i][3] )
            lRet := .F.
        EndIf
    EndIf
Next

Return lRet

/* 
=====================================================================================
Função...:              BuscaTab
Autor....:              CAOA - Sandro Ferreira
Data.....:              11/02/2022
Descricao / Objetivo:   Busca os preços da tabela de preço de Venda
===================================================================================== 
*/

Static Function BuscaTab( _cFilial, _cCodMar, _cModVei, _cSegMod, _cFabMod )

Local _nPrecoab  := 0
Local cQry       := ""
Local cTabela    := GetNextAlias()

cQry := "   SELECT VVP_VALTAB VALTAB                      "
cQry +=	"        FROM " + RetSQLName("VVP")      + " VVP "
cQry +=	" 		    WHERE 	VVP.VVP_FILIAL 	  = '" + xFilial("VVP") + "'"
cQry +=	" 			    AND VVP.VVP_CODMAR    = '" + _cCodMar + "'"
cQry +=	" 			    AND VVP.VVP_MODVEI    = '" + _cModVei + "'"
cQry +=	" 			    AND VVP.VVP_SEGMOD    = '" + _cSegMod + "'"
cQry +=	"               AND VVP.VVP_FABMOD  = '"   + _cFabMod + "'"
cQry +=	" 		        AND VVP.D_E_L_E_T_  = ' ' "
cQry +=	"               AND VVP.VVP_DATPRC = (  SELECT MAX(VVPB.VVP_DATPRC)  "
cQry +=	"                                        FROM " + RetSQLName("VVP")      + " VVPB "
cQry +=	"                                         WHERE  VVPB.VVP_FILIAL = VVP.VVP_FILIAL "
cQry +=	" 			                               AND VVPB.VVP_CODMAR   = VVP.VVP_CODMAR "
cQry +=	" 			                               AND VVPB.VVP_MODVEI   = VVP.VVP_MODVEI "
cQry +=	" 			                               AND VVPB.VVP_SEGMOD   = VVP.VVP_SEGMOD "
cQry +=	"                                          AND VVPB.VVP_FABMOD   = VVP.VVP_FABMOD "
cQry +=	"                                          AND VVPB.D_E_L_E_T_   = ' ' ) "
cQry := ChangeQuery(cQry)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cTabela,.T.,.T.)

If Select(cTabela) > 0
   _nPrecoab := (cTabela)->VALTAB
	(cTabela)->(DbCloseArea())
EndIf

Return _nPrecoab

/* 
=====================================================================================
Função...:              BuscaSt
Autor....:              CAOA - Sandro Ferreira
Data.....:              11/02/2022
Descricao / Objetivo:   Busca os preços da tabela de preço de Venda
===================================================================================== 
*/

Static Function BuscaSt( _cFilial, _cCodMar, _cModVei, _cSegMod, _cFabMod )

Local _nXBasst      := 0
Local cQry          := ""
Local cTabela       := GetNextAlias()

cQry := "   SELECT VVP_BASEST BASEST                      "
cQry +=	"        FROM " + RetSQLName("VVP")      + " VVP "
cQry +=	" 		    WHERE 	VVP.VVP_FILIAL 	  = '" + xFilial("VVP") + "'"
cQry +=	" 			    AND VVP.VVP_CODMAR    = '" + _cCodMar + "'"
cQry +=	" 			    AND VVP.VVP_MODVEI    = '" + _cModVei + "'"
cQry +=	" 			    AND VVP.VVP_SEGMOD    = '" + _cSegMod + "'"
cQry +=	"               AND VVP.VVP_FABMOD  = '"   + _cFabMod + "'"
cQry +=	" 		        AND VVP.D_E_L_E_T_  = ' ' "
cQry +=	"               AND VVP.VVP_DATPRC = (  SELECT MAX(VVPB.VVP_DATPRC)  "
cQry +=	"                                        FROM " + RetSQLName("VVP")      + " VVPB "
cQry +=	"                                         WHERE  VVPB.VVP_FILIAL = VVP.VVP_FILIAL "
cQry +=	" 			                               AND VVPB.VVP_CODMAR   = VVP.VVP_CODMAR "
cQry +=	" 			                               AND VVPB.VVP_MODVEI   = VVP.VVP_MODVEI "
cQry +=	" 			                               AND VVPB.VVP_SEGMOD   = VVP.VVP_SEGMOD "
cQry +=	"                                          AND VVPB.VVP_FABMOD   = VVP.VVP_FABMOD "
cQry +=	"                                          AND VVPB.D_E_L_E_T_   = ' ' ) "
cQry := ChangeQuery(cQry)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cTabela,.T.,.T.)

If Select(cTabela) > 0
   _nXBasst := (cTabela)->BASEST
	(cTabela)->(DbCloseArea())
EndIf

Return _nXBasst

/*
=======================================================================================
Programa.:             Criaperg 
Autor....:              
Data.....:              
Descricao / Objetivo:   Cria grupo de perguntas, caso não exista.
=======================================================================================
*/

Static Function Criaperg()

	Local aAreaAnt 	:= GetArea()
	Local aAreaSX1 	:= SX1->(GetArea())
	Local nY 		:= 0
	Local nJ 		:= 0
	Local aReg 		:= {}
	
	aAdd(aReg,{cPerg,"01","Da Data de Digitação      ","mv_ch1","D", 30,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SW9_1"})
	aAdd(aReg,{cPerg,"02","Até Data de Digitação     ","mv_ch2","D", 30,0,0,"G","(mv_par02>=mv_par01)","mv_par02","","","","","","","","","","","","","","","SW9_1"})

	aAdd(aReg,{"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_CNT01","X1_VAR02","X1_DEF02","X1_CNT02","X1_VAR03","X1_DEF03","X1_CNT03","X1_VAR04","X1_DEF04","X1_CNT04","X1_VAR05","X1_DEF05","X1_CNT05","X1_F3","X1_PYME","X1_GRPSXG","X1_HELP","X1_PICTURE"})
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	For ny := 1 To Len(aReg) - 1
		If !DbSeek( PadR( aReg[ny,1], 10) + aReg[ny,2])
			RecLock("SX1", .T.)
			For nJ := 1 To Len(aReg[ny])
				FieldPut( FieldPos( aReg[Len( aReg)][nJ] ), aReg[ny,nJ] )
			Next nJ
			MsUnlock()
		EndIf
	Next ny	
	
	RestArea(aAreaSX1)
	RestArea(aAreaAnt)

Return

/*
=======================================================================================
Programa.:            VlrPret  
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

******************************************************************************
Static Function VlrPret(cCodMar, cModVei, cSegMod, nValTab, nValPre,nValMov,cCabAlias,lCalMov)
******************************************************************************

Local cForm121 As Character
Default lCalMNov := .F.

cForm121 := GetNewPar("MV_MIL0121","") //U_CMVVEI01()

// Se o usuario zerar o valore pretendido, volta o valor de tabela...
If nValPre == 0
	nValMovimento := iif( lCalMov,nValMov,nValTab)
Else
	If Empty(cForm121)
		nValMovimento := iif( lCalMov,nValMov,nValPre)//nValPre
	Else
		nValMovimento := iif( lCalMov,nValMov,nValPre)//nValPre

		nValorPre := iif( lCalMov,nValMov,nValPre)//nValPre // Valor utilizada na formula...
		nValorMov := CalcRev(nValorPre,cCabAlias)

		If nValorMov <> nValPre
			nValMovimento := nValorMov
		EndIf
	EndIf
EndIf

//Return(nValMovimento)
Return(.T.)

/*
=======================================================================================
Programa.:            CalcRev  
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

********************************************
Static Function CalcRev(nValorPre,cCabAlias)
********************************************

Local nVlrRet	:= nValorPre      //Valor Total vindo da tabela de preço
Local nAlqIPI	:= 0
Local nAlqIcmSt	:= 0
Local nAlqOpIcm	:= 0
Local nBaseSt	:= 0 
Local nAlqBIcms	:= 0
Local cTes		:= ""    
Local nVlIcmDev	:= 0
Local nAliqStPi	:= 0
Local nAliqStCo	:= 0
Local nRedBPist	:= 0
Local nRedBCoSt	:= 0
Local nAux1		:= 0
Local nAux2		:= 0
Local nAux3		:= 0
Local lSuframa	:= .F.
Local nPercZFre	:= 0.01 // Tratar Parâmetro
Local nVlrDesFr	:= 0
Local nVlrUnit	:= 0
Local aArea		:= {SA1->(GetArea()),GetArea()}	
Local aAreaSF4	:= {}
Local nPerComs	:= 0
Local nValComs	:= 0
Local cTESTSD	:= SuperGetMV("CMV_TESTSD",.F.,"")
Local aExcecao	:= {}
Local cGrupo1	:= GetMv("MV_XVEI011",,"000003"	) // grupo que nao pode ter a variavel nAux3 calculada no calculo reverso. OBS: se precisar incluir mais grupos, criar outros parametros, não inserir o grupo neste mesmo parametro, para evitar cruzamento de logicas entre grupos X marcas, deixando o cruzamento exponencial e errado
Local cMarca1	:= GetMv("MV_XVEI012",,"HYU"	) // marca que nao pode ter a variavel nAux3 calculada no calculo reverso. OBS: se precisar incluir mais marcas, criar outros parametros, não inserir a marca neste mesmo parametro, para evitar cruzamento de logicas entre grupos X marcas, deixando o cruzamento exponencial e errado
Local cGrupo2	:= GetMv("MV_XVEI014",,"000003"	) // venda de caminhao HD80, base icms st deve estar zerada
Local cMarca2	:= GetMv("MV_XVEI015",,"HYU"	) // venda de caminhao HD80, base icms st deve estar zerada
Local lPassa	:= .T.
//Local oModel	:= FWModelActive()
Local nY		:= 1

//Variáveis para cálculo do Zona Franca
Local nVlrNormal	:= 0	//preço de venda normal
Local nBSICMSST		:= 0	//Base do ICMS ST - conferir com a tabela
Local nAlqIcms		:= 0	//Aliquota de ICMS OP
Local nAlqIcmsST	:= 0	//Aliquota de ICMS ST
Local nVlrIcms		:= 0	//Valor ICMS
Local nAlqPCC		:= 0	//Aliquota de Pis+Cofins ST
Local nRedPCC		:= 0	//ReduçãoPis / Cofins
Local nRedIcms		:= 0	//Reduçãobase ICMS
Local nAlqIpiZF		:= 0	//Aliquota de IPI Zona Franca
Local nVlrDescFr	:= 0	//Desconto frete 1% ZF 	
Local nVlrFator1	:= 0	//Calculo do Fator 1
Local nVlrFator2	:= 0	//Calculo do Fator 2
Local nvlrFator3	:= 0	//Calculo do Fator 3 
Local nDIcmsZF		:= 0	//Desconto do ICMS Normal Zona Franca
Local nDIpiZF		:= 0 	//Desconto do IPI Zona Franca
Local nDPccZF		:= 0	//Desconto do PIS / COFINS Zona Franca
Local nVlrAbtTrb	:= 0	//Abatimentos tributos ZF
Local nVlrPCCST		:= 0	//PIS/COFINS ST
Local nPrecoZF		:= 0	//preço de venda Zona Franca

// venda para consumidor final dentro do mesmo estado, não tem ST
If (cCabAlias)->C5_XTIPVEN $ "04"
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+(cCabAlias)->C5_CLIENTE+(cCabAlias)->C5_LOJACLI))
		If Alltrim(GetMv("MV_ESTADO"))  == Alltrim(SA1->A1_EST) .And. Alltrim(GetMv("MV_ESTADO"))  == "GO" ;
          .And. SA1->A1_TIPO            == "F"                  .And. Alltrim(SA1->A1_GRPTRIB)     == "VDD"
			lPassa := .F.
		Endif
	Endif		
Endif

// Tratativa Venda Direta
If (cCabAlias)->C5_XTIPVEN  $ "02/03/04/06"
	If !(Alltrim((cCabAlias)->C6_XCODMAR) $ Alltrim(cMarca2) .And. Alltrim((cCabAlias)->C6_XGRPMOD) $ Alltrim(cGrupo2))
		If lPassa
			RecLock(cCabAlias,.f.) //FWFldPut("VRK_XBASST", FWFldGet("VRK_VALPRE"))
            (cCabAlias)->C6_XBASST := (cCabAlias)->C6_XVLRVDA
            (cCabAlias)->(MsUnlock())
			//ConOut("            Recalculando item fiscal - " + cValToChar(FWFldGet("ITEMFISCAL") ) )
			//("",n)//FWFldGet("ITEMFISCAL"))
		Endif	
	Endif	
EndIf

//Venda PCD/Taxi não tem reverso.
If (cCabAlias)->C5_XTIPVEN  $ "02/03/05"
	aEval(aArea,{|x| RestArea(x)})
	Return nVlrRet
Endif

SA1->(DbSetOrder(1)) ; SA1->(DbSeek(xFilial("SA1")+(cCabAlias)->C5_CLIENTE+(cCabAlias)->C5_LOJACLI))
SB1->(DbSetOrder(1)) ; SB1->(DbSeek(xFilial("SB1")+(cCabAlias)->C6_PRODUTO                        ))
SF4->(DbSetOrder(1)) ; SF4->(DbSeek(xFilial("SF4")+(cCabAlias)->C6_TES                            ))

MaFisIni((cCabAlias)->C5_CLIENTE, (cCabAlias)->C5_LOJACLI, 'C', 'N', SA1->A1_TIPO,  MaFisRelImp("MATA460", {"SF2","SD2"}))//MaFisRelImp("VA060", {"VRJ","VRK"}) )
MaFisClear()

MaFisIniLoad(nY								,;
			{ SB1->B1_COD					,; // IT_PRODUTO
 	 		(cCabAlias)->C6_TES				,; // IT_TES
	 		Space(TamSX3("D1_CODISS")[1])	,; // IT_VALISS - Valor do ISS do item sem aplicar o arredondamento
	 		1								,; // IT_QUANT - Quantidade do Item
	 		""								,; // IT_NFORI - Numero da NF Original
	 		""								,; // IT_SERORI - Serie da NF Original
	 		SB1->(RecNo()) 					,; // IT_RECNOSB1
	 		SF4->(RecNo()) 					,; // IT_RECNOSF4
	 		0 })        					   //IT_RECORI
MaFisTes((cCabAlias)->C6_TES,SF4->(RecNo()),nY)

//Venda Direta convênio 51/00
If (cCabAlias)->C5_XTIPVEN  $ "04"
	Default cCoadMr := (cCabAlias)->C6_XCODMAR
	Default cModVei := (cCabAlias)->C6_XMODVEI
	Default cSegMod := (cCabAlias)->C6_XSEGMOD
	Default nValTab := (cCabAlias)->C6_XPRCTAB
	Default nValPre := (cCabAlias)->C6_XVLRPRD
    Default nValMov := (cCabAlias)->C6_XVLRMVT

	MaFisLoad("IT_PRODUTO"  , SB1->B1_COD        , nY)
    MaFisLoad("IT_QUANT"    , 1                  , nY)
	MaFisLoad("IT_TES"      , (cCabAlias)->C6_TES, nY)
    MaFisLoad("IT_PRCUNI"   , nValorPre          , nY)
	MaFisLoad("IT_VALMERC"  , nValorPre          , nY)
    MaFisEndLoad(nY,1)
	MaFisRecal("",nY)
	
    aExcecao := MaExcecao(nY)
    u_RelImp()
	
    nAlqIPI   := MaFisRet(nY,"IT_ALIQIPI")/100  			//Aliquota de IPI ja em Percentual  
	nAlqOpIcm := MaFisRet(nY,"IT_ALIQICM")/100  			//Aliquota de ICMS OP em Percentual
	nPerComs  := FatComis(MaFisRet(nY,"IT_PRODUTO"))/100	//Percentual de comissao conforme modelo do veículo
    
	If !(MaFisRet(nY,"IT_TES") $ cTESTSD)	//-- TES de faturamento p/ veículo test drive (não tem comissão)
		nValComs := ROUND(nVlrRet * nPerComs,2)
	EndIf
	
	nVlrUnit  := ROUND((nVlrRet - nValComs)/(1+nAlqIPI),2) 
	nVlrUnit  +=  nValComs
	nVlrRet   := nVlrUnit 
	
	MaFisRecal("",nY)  //Recalcula tudo com a tela atualizada
	
	aEval(aArea,{|x| RestArea(x)})
	
	Return nVlrRet
EndIf

lSuframa := MaFisRet(N,"NF_SUFRAMA")

If !lSuframa 
	/******************************************************************
	**Venda Atacado não Suframa Planilha de Referencia para       *****
	**chegar no calculo Unitário- Calculadora Concessionaria.xls *****
	*******************************************************************/

	SB1->(DbSetOrder(1)) 
    SB1->(DbSeek(xFilial("SB1")+(cCabAlias)->C6_PRODUTO  ))
    SF4->(DbSetOrder(1))
    SF4->(DbSeek(xFilial("SF4")+(cCabAlias)->C6_TES      ))
	
    MaFisClear()
	MaFisIniLoad(nY								,;
				{ SB1->B1_COD					,; // IT_PRODUTO
		 		(cCabAlias)->C6_TES 			,; // IT_TES
		 		Space(TamSX3("D1_CODISS")[1])	,; // IT_VALISS - Valor do ISS do item sem aplicar o arredondamento
		 		1								,; // IT_QUANT - Quantidade do Item
		 		""								,; // IT_NFORI - Numero da NF Original
		 		""								,; // IT_SERORI - Serie da NF Original
		 		SB1->(RecNo()) 					,; // IT_RECNOSB1
		 		SF4->(RecNo()) 					,; // IT_RECNOSF4
		 		0 })        					   //IT_RECORI

	MaFisTes((cCabAlias)->C6_TES ,SF4->(RecNo()),nY)
	
    MaFisLoad("IT_PRODUTO"  , SB1->B1_COD         , nY) 
    MaFisLoad("IT_QUANT"    , 1                   , nY)
	MaFisLoad("IT_TES"      , (cCabAlias)->C6_TES , nY) 
    MaFisLoad("IT_PRCUNI"   , nValorPre           , nY)
	MaFisLoad("IT_VALMERC"  , nValorPre           , nY)
    
    MaFisEndLoad(nY,1)
	MaFisRecal("",nY)
	
    aExcecao := MaExcecao(nY)
    u_RelImp()	
	
    nAlqIPI  := MaFisRet(nY,"IT_ALIQIPI")/100  		//Aliquota de IPI ja em Percentual  
	nAlqIcmSt:= MaFisRet(nY,"IT_ALIQSOL")/100  		//Aliquota de ICMS ST ja em Percentual
	nAlqOpIcm:= MaFisRet(nY,"IT_ALIQICM")/100  		//Aliquota de ICMS OP em Percentual 
    nBaseSt  := MaFisRet(nY,"IT_BASESOL")      		// Base de ST Fixa, que está no produto. (Usado o Conceito de ICMS Pauta)
    //nBaseSt  := (cCabAlias)->C6_XBASST      		// Base de ST Fixa, que está no produto. (Usado o Conceito de ICMS Pauta)
	cTes     := MaFisRet(nY,"IT_TES"    )          		// Tes para buscar a Reduçãode Base de ICMS Pois não encontrei na MaFisRet
	nAliqStPi:= MaFisRet(nY,"IT_ALIQPS3")/100  		// Aliquota de Pis    ST em Percentual
	nAliqStCo:= MaFisRet(nY,"IT_ALIQCF3")/100  		// Aliquota de Cofins ST em Percentual
    nAlqBIcms:= MaFisRet(nY,"IT_PREDIC" )      		// Reduçãode Base de ICMS
    
	nVlIcmDev := nBaseSt*nAlqIcmSt					// Valor do ICMS devido (Necessário para o calculo Reverso)
	nVlrDesFr := 0									// Valor de Desconto de Frete, somente ZF e fixo de 1% sobre preço total de Venda
	nAux1     := nVlrRet-nVlrDesfr - nVlIcmDev		// Variavel Auxiliar para calculo do Valor Unitário            
	nAux2     := 1+nAlqIPI							// Variavel Auxiliar para calculo do Valor Unitário
	nAux3     := ((nAlqBIcms/100)*nAlqOpIcm)		// Variavel Auxiliar para calculo do Valor Unitário
	
	// grupo e marca de produtos que nao devem ter esta variavel incrementada ao calculo
	If FatNAux3(MaFisRet(nY,"IT_PRODUTO"),cGrupo1,cMarca1)
		nAux3 := 0
	Endif	
	
	nVlrUnit  := nAux1/(nAux2-nAux3)
	nVlrRet   := nVlrUnit
   
    (cCabAlias)->(RecLock(cCabAlias),.F.)
        (cCabAlias)->C6_XVLRVDA := (cCabAlias)->C6_XVLRPRD//nValorPre
        (cCabAlias)->C6_PRCVEN  := Round(nVlrRet,2) 
        (cCabAlias)->C6_XVLRPRD := iif(Readvar()$ "C6_TES|C6_OPER",(cCabAlias)->C6_XVLRPRD , Round(nVlrRet,2))//Round(nVlrRet,2)
        (cCabAlias)->C6_XVLRMVT := Round(nVlrRet,2)
        (cCabAlias)->C6_VALOR   := Round(nVlrRet,2)
        //(cCabAlias)->B6_XBASST 
    (cCabAlias)->(MsUnLock())
Else
	******************************************************************
	** Programa de Calculo Reverso Baseado na Planilha de Calculo    *
	** preços de Venda CAOA x Revenda  - Zona Franca  de Manaus      *
	******************************************************************

	cTes := MaFisRet(nY,"IT_TES") 
	SF4->(DbSetOrder(1))
    SF4->(DbSeek(xFilial("SF4")+cTes))

	MaFisClear()
	SB1->(DbSetOrder(1)) 
    SB1->(DbSeek(xFilial("SB1")+(cCabAlias)->C6_PRODUTO  ))
    SF4->(DbSetOrder(1))
    SF4->(DbSeek(xFilial("SF4")+(cCabAlias)->C6_TES      ))

	MaFisIniLoad(nY								,;
				{ SB1->B1_COD					,; // IT_PRODUTO
		 		cTes							,; // IT_TES
		 		Space(TamSX3("D1_CODISS")[1])	,; // IT_VALISS - Valor do ISS do item sem aplicar o arredondamento
		 		1								,; // IT_QUANT - Quantidade do Item
		 		""								,; // IT_NFORI - Numero da NF Original
		 		""								,; // IT_SERORI - Serie da NF Original
		 		SB1->(RecNo()) 					,; // IT_RECNOSB1
		 		SF4->(RecNo()) 					,; // IT_RECNOSF4
		 		0 })        					   //IT_RECORI

	MaFisTes(cTes,SF4->(RecNo()),nY)
	
    MaFisLoad("IT_PRODUTO"  , SB1->B1_COD , nY)
    MaFisLoad("IT_QUANT"    , 1           , nY)
	MaFisLoad("IT_TES"      , cTes	      , nY)
    MaFisLoad("IT_PRCUNI"   , nValorPre   , nY)
	MaFisLoad("IT_VALMERC"  , nValorPre   , nY) 
	
    MaFisEndLoad(nY,1) 
    
    MaFisRecal("",nY)
	
    aExcecao := MaExcecao(nY)
	u_RelImp()	
	
    aAreaSF4 := GetArea()
	SF4->(DbSetOrder(1))
	
    If SF4->(DbSeek( xFilial("SF4")+cTes))		
		nRedBPist := SF4->F4_BASEPIS						// Reduçãoda Base de Pis
		nRedBCoSt := SF4->F4_BASECOF						// Reduçãoda Base de Cofins 
		// verifica se tem excecao fiscal e pega de lah quando tiver
		If Len(MaFisRet(nY,"IT_EXCECAO")) > 0
			aExcecao := MaFisRet(nY,"IT_EXCECAO")
			If !Empty(aExcecao[18])
				nRedBPist := aExcecao[18]					// Reduçãoda Base de Pis
			Endif	
			If !Empty(aExcecao[19])
				nRedBCoSt := aExcecao[19]					// Reduçãoda Base de Cofins 
			Endif	
		Endif	
	Endif
	
    RestArea(aAreaSF4)

	VVPLastSeq((cCabAlias)->C6_XCODMAR,(cCabAlias)->C6_XMODVEI,(cCabAlias)->C6_XSEGMOD,(cCabAlias)->C6_XFABMOD)
	nVlrNormal	:= VVP->VVP_VALTAB
	nBSICMSST	:= VVP->VVP_BASEST
	nAlqIcms	:= MaFisRet(N,"IT_ALIQICM")											//Aliquota de ICMS OP
	nAlqIcmsST	:= MaFisRet(N,"IT_ALIQSOL")											//Aliquota de ICMS ST
	nVlrIcms	:= (VVP->VVP_BASEST * (nAlqIcmsST/100))								//Valor ICMS
	
    If MaFisRet(nY,"IT_ALIQPS3") <> 0 .And. MaFisRet(nY,"IT_ALIQCF3") <> 0
		nAlqPCC	:= (MaFisRet(nY,"IT_ALIQPS3") + MaFisRet(nY,"IT_ALIQCF3"))			//Aliquota de Pis+Cofins ST
	Else
		nAlqPCC	:= (aExcecao[12]+aExcecao[13])										//Aliquota de Pis+Cofins ST
	EndIf
	
    nRedPCC		:= 0																//ReduçãoPis / Cofins
	nRedIcms	:= MaFisRet(nY,"IT_PREDIC")											//Reduçãobase ICMS
	nAlqIpi		:= MaFisRet(nY,"IT_ALIQIPI")											//Aliquota de IPI
	nAlqIpiZF	:= 0																//Aliquota de IPI Zona Franca
	nVlrDescFr	:= Round((nVlrNormal * nPercZFre),0)								//Desconto frete 1% ZF 
	
	nVlrFator1	:= ((1+(nAlqIpi /100))/100)											//Calculo do Fator 1
	nVlrFator2	:= (   (nRedIcms/100 )/100) /*((1-(nRedIcms/100))/100)*/			//Calculo do Fator 2
	nvlrFator3  := (nVlrFator1 -nVlrFator2 * ((nAlqIcms /100)))/100					//Calculo do Fator 3 

	nVlrUnit	:= ((((nVlrNormal - nVlrDescFr)-nVlrIcms) / nVlrFator3)/10000)		//Valor Unitárionormal
	nDIcmsZF	:= 0																//Desconto do ICMS Normal Zona Franca
	nDIpiZF		:= (nVlrUnit * nAlqIpiZF)											//Desconto do IPI Zona Franca

	nVlrFator1	:= (nVlrUnit * (1 - (nRedPCC/100)))									//Calculo do Fator 1
	nVlrFator2  := (nVlrUnit * (nRedIcms/100)) * (nAlqIcms/100)						//Calculo do Fator 2
	nVlrFator3  := (nVlrFator1 - nVlrFator2) 										//Calculo do Fator 3
	nDPccZF		:= (nVlrFator3 * (nAlqPCC /100))									//Desconto do PIS / COFINS Zona Franca
	nVlrAbtTrb	:= (nDIcmsZF + nDIpiZF + nDPccZF)									//Abatimentos tributos ZF

	nVlrPCCST	:= 0																//PIS/COFINS ST
	nPrecoZF	:= (nVlrNormal - nVlrDescFr - nVlrAbtTrb + nVlrPCCST)				//preço de venda Zona Franca
	nVlrRet		:= Round((nPrecoZF- (nBSICMSST*(nAlqIcmsST/100))) / ;
	                     (((100+nAlqIpi)-((nRedIcms/100)*nAlqIcms))/100),2)			//Valor Unitáriofinal Zona Franca

    (cCabAlias)->(RecLock(cCabAlias),.F.)
        (cCabAlias)->C6_XVLRPRD := Round(nVlrRet,2)
        (cCabAlias)->C6_XVLRMVT := Round(nVlrRet,2)
        (cCabAlias)->C6_XVLRVDA := nValorPre
        (cCabAlias)->C6_PRCVEN  := Round(nVlrRet,2) 
        (cCabAlias)->C6_VALOR   := Round(nVlrRet,2) 
    (cCabAlias)->(MsUnLock())

Endif

aEval(aArea,{|x| RestArea(x)})

Return Round(nVlrRet,2)
//Return(.T.)

/*
=======================================================================================
Programa.:              FatComis
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

Static Function FatComis(cProd)

Local aArea := {VV2->(GetArea()),GetArea()}	
Local nRet := 0

VV2->(dbSetOrder(7))
If VV2->(dbSeek(xFilial("VV2")+cProd))
	nRet := VV2->VV2_XCOMIS
Endif

aEval(aArea,{|x| RestArea(x)})

Return(nRet)

/*
=======================================================================================
Programa.:            FatNAux3  
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

Static Function FatNAux3(cProd,cGrupo1,cMarca1)

Local aArea := {VV2->(GetArea()),GetArea()}	
Local lRet := .F.

VV2->(dbSetOrder(7))
If VV2->(dbSeek(xFilial("VV2")+cProd))
	If Alltrim(VV2->VV2_GRUMOD) $ Alltrim(cGrupo1) .and. Alltrim(VV2->VV2_CODMAR) $ Alltrim(cMarca1)
		lRet := .T.
	Endif	
Endif

aEval(aArea,{|x| RestArea(x)})

Return(lRet)

/*
=======================================================================================
Programa.:            Vei01IcmZF  
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

Static Function Vei01IcmZF(cProd,cGrupo,cMarca)

Local aArea := {VV2->(GetArea()),GetArea()}	
Local lRet := .F.

VV2->(dbSetOrder(7))
If VV2->(dbSeek(xFilial("VV2")+cProd))
	If Alltrim(VV2->VV2_GRUMOD) $ Alltrim(cGrupo) .and. Alltrim(VV2->VV2_CODMAR) == Alltrim(cMarca)
		lRet := .T.
	Endif	
Endif

aEval(aArea,{|x| RestArea(x)})

Return(lRet)

/*
=======================================================================================
Programa.:             VVPLastSeq 
Autor....:              
Data.....:              
Descricao / Objetivo:   
=======================================================================================
*/

static function VVPLastSeq(cCodMar,cModVei,cSegMod,cFabMod)
local cQuery as char
local cSeq   as char
local cAlias as char

//Guarda a workarea corrente
cAlias := Alias()

//Gera um alias aleatório somente para abrir a query
cQuery := GetNextAlias()

//Cria a query
BeginSql Alias cQuery
    SELECT VVP_BASEST,VVP_DATPRC
    FROM %Table:VVP% VVP
    WHERE
    VVP.%NotDel%
    AND VVP_FILIAL = %Exp:xFilial("VVP")%
	AND VVP.VVP_CODMAR = %exp:cCodMar%
	AND VVP.VVP_MODVEI = %exp:cModVei%
	AND VVP.VVP_SEGMOD =  %exp:cSegMod%
	AND VVP_DATPRC = 
	(
		SELECT MAX(VVP_DATPRC) VVP_DATPRC
		FROM %Table:VVP% VVP1
		WHERE
		VVP1.%NotDel%
		AND VVP1.VVP_FILIAL = VVP.VVP_FILIAL
		AND VVP1.VVP_CODMAR = VVP.VVP_CODMAR
		AND VVP1.VVP_MODVEI = VVP.VVP_MODVEI
		AND VVP1.VVP_SEGMOD = VVP.VVP_SEGMOD
		AND VVP1.VVP_FABMOD = %exp:cFabMod%
		
	)
    GROUP BY VVP_BASEST,VVP_DATPRC
	ORDER BY VVP_BASEST,VVP_DATPRC
    EndSql

//Se existir registro, retorna o mesmo
if !(cQuery)->(Eof())
    cSeq := (cQuery)->VVP_BASEST
else
    cSeq := ""
endif

dbSelectArea("VVP")
VVP->(dbSetOrder(1))
VVP->(dbSeek(xFilial("VVP")+VV2->VV2_CODMAR+VV2->VV2_MODVEI+VV2->VV2_SEGMOD+(cQuery)->VVP_DATPRC))

//Fecha a query, boa prática, tudo que você abriu, você fecha... E também existem limites de workareas abertas no Protheus
(cQuery)->(DBCloseArea())

//Retorna a workarea corrente, protegido, pois um dbselectarea com valor vazio gera exceção
if !Empty(cAlias)
    DBSelectArea(cAlias)
endif

return cSeq

/*
=======================================================================================
Programa.:             fPedZero 
Autor....:             Reinaldo Rabelo 
Data.....:              
Descricao / Objetivo:  Verifico se tem itens pendentes no pedido 
=======================================================================================
*/

User Function fPedZero(cPed)
Local cQuery := ""
Local lRet := .F.
Local cTabela := GetNextAlias()

cQuery += "  Select    SUM(TOTAL) as TOTAL, "
cQuery += "            SUM(TFAT)  as TFAT, "
cQuery += "            SUM(TPED)  as TPED "
cQuery += "  From ( "
cQuery += "          SELECT 1 as TOTAL , "
cQuery += "             CASE WHEN VRK.VRK_ITETRA <> ' ' THEN 1 ELSE 0 END as TFAT, "
cQuery += "             CASE WHEN VRK.VRK_ITETRA =  ' ' THEN 1 ELSE 0 END as TPED "
cQuery += "           FROM " + RetSqlName("VRK") + " VRK  "
cQuery += "           WHERE  "
cQuery += "               VRK.VRK_PEDIDO = (SELECT VRJ.VRJ_PEDIDO FROM " + RetSqlName("VRJ") + " VRJ WHERE  VRJ.VRJ_PEDCOM = '" + cPed + "') "
cQuery += " ) "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTabela,.T.,.T.)

If (cTabela)->(!EOF())
    lRet := (cTabela)->TFAT == 0
endIf

If Select(cTabela) > 0
    (cTabela)->(DbCloseArea())
endif

Return lRet

/*
=======================================================================================
Programa.:             Estor 
Autor....:             Reinaldo Rabelo 
Data.....:              
Descricao / Objetivo:  Realiza o estorno do chassi após a exclusão da NF 
=======================================================================================
*/

Static Function Estor(oSay)
Local cQuery  :=  ""
Local cTabela := GetNextAlias()
Local lRet    := .F. 

cQuery += CrLf + " SELECT  '  ' C6_OK    , "
cQuery += CrLf + "        ' '   C6_STATUS,  "
cQuery += CrLf + "        SC6.C6_FILIAL,  "
cQuery += CrLf + "        SC6.C6_NUM,  "
cQuery += CrLf + "        SC6.C6_PEDCLI,  "
cQuery += CrLf + "        SC5.C5_EMISSAO,  "
cQuery += CrLf + "        SC5.C5_CLIENTE,  "
cQuery += CrLf + "        SC5.C5_LOJACLI,  "
cQuery += CrLf + "        SA1.A1_NOME,  "
cQuery += CrLf + "        SC5.C5_CONDPAG,  "
cQuery += CrLf + "        SC5.C5_NATUREZ,  "
cQuery += CrLf + "        SC6.C6_ITEM,  "
cQuery += CrLf + "        SC6.C6_PRODUTO,  "
cQuery += CrLf + "        SB1.B1_DESC,  "
cQuery += CrLf + "        SC6.C6_LOCAL,  "
cQuery += CrLf + "        SC6.C6_CHASSI, "
cQuery += CrLf + "        VRK.VRK_CHASSI,  "
cQuery += CrLf + "        SC6.C6_NUMSERI,  "
cQuery += CrLf + "        SC6.C6_LOCALIZ,  "
cQuery += CrLf + "        SC6.C6_XCODMAR,  "
cQuery += CrLf + "        SC6.C6_XDESMAR,  "
cQuery += CrLf + "        SC6.C6_XGRPMOD,  "
cQuery += CrLf + "        SC6.C6_XDGRMOD,  "
cQuery += CrLf + "        SC6.C6_XMODVEI,  "
cQuery += CrLf + "        SC6.C6_XDESMOD,  "
cQuery += CrLf + "        SC6.C6_XSEGMOD,  "
cQuery += CrLf + "        SC6.C6_XDESSEG,  "
cQuery += CrLf + "        SC6.C6_XFABMOD,  "
cQuery += CrLf + "        SC6.C6_XCORINT,  "
cQuery += CrLf + "        SC6.C6_XCOREXT,  "
cQuery += CrLf + "        SC6.C6_QTDVEN,  "
cQuery += CrLf + "        SC6.C6_PRCVEN,  "
cQuery += CrLf + "        SC6.C6_VALOR,  "
cQuery += CrLf + "        SC6.C6_OPER,  "
cQuery += CrLf + "        SC6.C6_TES,  "
cQuery += CrLf + "        SC6.C6_XVLRVDA,  "
cQuery += CrLf + "        SC6.C6_PRUNIT,  "
cQuery += CrLf + "        SC6.C6_XPRCTAB,  "
cQuery += CrLf + "        SC6.C6_XVLRPRD,  "
cQuery += CrLf + "        SC6.C6_XVLRMVT,  "
cQuery += CrLf + "        SC6.C6_XBASST,  "
cQuery += CrLf + "        SC5.C5_XTIPVEN,
cQuery += CrLf +"         VRJ.VRJ_PEDIDO, "
cQuery += CrLf +"         'F'  as lupd, "
cQuery += CrLf + " 	      VRJ.VRJ_STATUS as VRJ_STATUS  ,  "
cQuery += CrLf + "        ' ' as  D_E_L_E_T_  ,  "
cQuery += CrLf + "        ROW_NUMBER() OVER (ORDER BY SC6.C6_FILIAL,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC6.C6_PRODUTO)  R_E_C_N_O_  "
cQuery += CrLf + " FROM " + RetSqlName("SC6") + " SC6  "

cQuery += CrLf + "      INNER JOIN " + RetSqlName("SC5") + " SC5  "
cQuery += CrLf + "              ON  SC5.C5_FILIAL  = '" + xFilial("SC5") + "'  "
cQuery += CrLf + "              AND SC5.C5_NUM     = SC6.C6_NUM  "
cQuery += CrLf + "              AND SC5.C5_CLIENTE = SC6.C6_CLI  "
cQuery += CrLf + "              AND SC5.C5_LOJACLI = SC6.C6_LOJA  "
cQuery += CrLf + "              AND SC5.D_E_L_E_T_ = ' '  "

cQuery += CrLf + "       INNER JOIN " + RetSqlName("VRJ") + " VRJ  "
cQuery += CrLf + "              ON  VRJ.VRJ_FILIAL = '" + xFilial("VRJ") + "'  "
cQuery += CrLf + "              AND VRJ.VRJ_PEDCOM = SC6.C6_PEDCLI  "
cQuery += CrLf + "              AND VRJ.VRJ_STATUS in ('A','F')  "
cQuery += CrLf + "              AND VRJ.D_E_L_E_T_ = ' '  "

cQuery += CrLf + "      INNER JOIN " + RetSqlName("VRK") + " VRK  "
cQuery += CrLf + "              ON  VRK.VRK_FILIAL = '" + xFilial("VRK") + "'  "
cQuery += CrLf + "              AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO     "
cQuery += CrLf + "              AND VRK.VRK_ITEPED = LPad(SC6.C6_ITEM,3,'0') "
cQuery += CrLf + "              AND VRK.VRK_NUMTRA = ' ' "
cQuery += CrLf + "              AND VRK.D_E_L_E_T_ = ' '  "

cQuery += CrLf + "      INNER JOIN " + RetSqlName("SA1") + " SA1  "
cQuery += CrLf + "              ON  SA1.A1_FILIAL  = '" + xFilial("SA1") + "'  "
cQuery += CrLf + "              AND SA1.A1_COD     = SC6.C6_CLI  "
cQuery += CrLf + "              AND SA1.A1_LOJA    = SC6.C6_LOJA  "
cQuery += CrLf + "              AND SA1.D_E_L_E_T_ = ' '  "

cQuery += CrLf + "      INNER JOIN " + RetSqlName("SB1") + " SB1  "
cQuery += CrLf + "              ON  SB1.B1_FILIAL  = '" + xFilial("SB1") + "'  "
cQuery += CrLf + "              AND SB1.B1_COD     = SC6.C6_PRODUTO  "
cQuery += CrLf + "              AND SB1.B1_GRUPO   = 'VEIA'  "
cQuery += CrLf + "              AND SB1.D_E_L_E_T_ = ' '  "

cQuery += CrLf + "      INNER JOIN " + RetSqlName("SF4") + " SF4  "
cQuery += CrLf + "              ON  SF4.F4_FILIAL  =  '" + xFilial("SF4") + "'  "
cQuery += CrLf + "              AND SF4.F4_CODIGO  = SC6.C6_TES  "
cQuery += CrLf + "              AND SF4.F4_DUPLIC  = 'S'  "
cQuery += CrLf + "              AND SF4.D_E_L_E_T_ = ' '  "

cQuery += CrLf + " WHERE   SC6.C6_FILIAL    =  '" + xFilial("SC6") + "'  "
cQuery += CrLf + "     AND SC5.C5_TIPO      =  'N' "
cQuery += CrLf + "     AND SC6.C6_PEDCLI    <> ' ' "
cQuery += CrLf + "     AND SC6.C6_NOTA      =  ' ' "
cQuery += CrLf + "     AND SC6.C6_BLQ       =  ' ' "
cQuery += CrLf + "     AND SC6.D_E_L_E_T_   =  ' ' "
cQuery += CrLf + "     AND SC6.C6_CHASSI    <> ' ' "
cQuery += CrLf + " ORDER BY SC6.C6_FILIAL,SC6.C6_PEDCLI,SC6.C6_ITEM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC6.C6_PRODUTO "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTabela,.T.,.T.)

While (cTabela)->(!EOF())
    
    if Empty((cTabela)->VRK_CHASSI)

        fLimpaChassi(cTabela) // Limpa campo de Chassi da Tabela SC6, pois a casos do chassi ser estornado e ficar não apagar o campo C6_CHASSI
        lRet := .T.
    EndIf

    (cTabela)->(DbSkip())
EndDo

if lRet
    lRet := Estor(oSay) 
endif

if !lRet
    fAtuEmp(oSay,cTabela,nil)
endif

If Select(cTabela) > 0
    (cTabela)->(DbCloseArea())
endif


Return lRet
/*
=======================================================================================
Programa.:             fLimpaChassi 
Autor....:             Reinaldo Rabelo 
Data.....:              
Descricao / Objetivo:  Limpa o campo de Chassi da SC6  
=======================================================================================
*/

Static Function fLimpaChassi(cTabela)
Local cQuery := ""

cQuery := " UPDATE " + RetSqlName("SC6")
cQuery += " SET C6_LOCALIZ = '" + Criavar("C6_LOCALIZ") + "' "
cQuery += "    ,C6_CHASSI  = '" + Criavar("C6_CHASSI" ) + "' "
cQuery += "    ,C6_NUMSERI = '" + Criavar("C6_NUMSERI") + "' "
cQuery += " WHERE  C6_FILIAL   = '" + xFilial("SC6") + "' "
cQuery += "    AND C6_NUM      = '" + (cTabela)->C6_NUM + "' "
cQuery += "    AND C6_CHASSI   = '" + (cTabela)->C6_CHASSI + "' "
cQuery += "    AND C6_ITEM     = '" + (cTabela)->C6_ITEM   + "' "
cQuery += "    AND C6_CLI      = '" + (cTabela)->C5_CLIENTE + "' "
cQuery += "    AND C6_LOJA     = '" + (cTabela)->C5_LOJACLI + "' "
cQuery += "    AND D_E_L_E_T_  = ' ' "
nStatus := TCSqlExec(cQuery)
            
If (nStatus < 0)
    MsgStop("TCSQLError() " + TCSQLError(), "Atualizacao Empenho SC6")
EndIf

Return
//***********************************************************************
Static Function AtuMOv(nValorPre)

Local nVlrRet	:= nValorPre      //Valor Total vindo da tabela de preço
Local aArea		:= {SA1->(GetArea()),GetArea()}	
Local aExcecao	:= {}
Local cTESTSD	:= SuperGetMV("CMV_TESTSD",.F.,"")
Local cGrupo2	:= GetMv("MV_XVEI014",,"000003"	) // venda de caminhao HD80, base icms st deve estar zerada
Local cMarca2	:= GetMv("MV_XVEI015",,"HYU"	) // venda de caminhao HD80, base icms st deve estar zerada
Local lPassa	:= .T.
//Local oModel	:= FWModelActive()
Local nY		:= 1

Default cCoadMr := (cCabAlias)->C6_XCODMAR
Default cModVei := (cCabAlias)->C6_XMODVEI
Default cSegMod := (cCabAlias)->C6_XSEGMOD
Default nValTab := (cCabAlias)->C6_XPRCTAB
Default nValPre := (cCabAlias)->C6_XVLRPRD
Default nValMov := (cCabAlias)->C6_XVLRMVT

// venda para consumidor final dentro do mesmo estado, não tem ST
If (cCabAlias)->C5_XTIPVEN $ "04"
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+(cCabAlias)->C5_CLIENTE+(cCabAlias)->C5_LOJACLI))
		If Alltrim(GetMv("MV_ESTADO"))  == Alltrim(SA1->A1_EST) .And. Alltrim(GetMv("MV_ESTADO"))  == "GO" .And. ;
           SA1->A1_TIPO                 == "F"                  .And. Alltrim(SA1->A1_GRPTRIB)     == "VDD"
	
    		lPassa := .F.
	
    	Endif
	Endif		
Endif

// Tratativa Venda Direta
If (cCabAlias)->C5_XTIPVEN  $ "02/03/04/06"
	If !(Alltrim((cCabAlias)->C6_XCODMAR) $ Alltrim(cMarca2) .And. Alltrim((cCabAlias)->C6_XGRPMOD) $ Alltrim(cGrupo2))
		If lPassa
			
            RecLock(cCabAlias,.f.) //FWFldPut("VRK_XBASST", FWFldGet("VRK_VALPRE"))
            (cCabAlias)->C6_XBASST := (cCabAlias)->C6_XVLRVDA
            (cCabAlias)->(MsUnlock())
			
            //ConOut("            Recalculando item fiscal - " + cValToChar(FWFldGet("ITEMFISCAL") ) )
			//("",n)//FWFldGet("ITEMFISCAL"))
		Endif	
	Endif	
EndIf

//Venda PCD/Taxi não tem reverso.
If (cCabAlias)->C5_XTIPVEN  $ "02/03/05"
	aEval(aArea,{|x| RestArea(x)})
	Return nVlrRet
Endif

SA1->(DbSetOrder(1)) ; SA1->(DbSeek(xFilial("SA1")+(cCabAlias)->C5_CLIENTE+(cCabAlias)->C5_LOJACLI))
SB1->(DbSetOrder(1)) ; SB1->(DbSeek(xFilial("SB1")+(cCabAlias)->C6_PRODUTO                        ))
SF4->(DbSetOrder(1)) ; SF4->(DbSeek(xFilial("SF4")+(cCabAlias)->C6_TES                            ))
//MaFisIni((cCabAlias)->C5_CLIENTE, (cCabAlias)->C5_LOJACLI, 'C', 'N', SA1->A1_TIPO, MaFisRelImp("MATA460", {"SF2","SD2"})) //MaFisRelImp("VA060", {"VRJ","VRK"}) )
MaFisIni((cCabAlias)->C5_CLIENTE,;							// 01- Codigo Cliente/Fornecedor
		 (cCabAlias)->C5_LOJACLI,;							// 02- Loja do Cliente/Fornecedor
			 "C",;											// 03- C: Cliente / F: Fornecedor
			 "N",;											// 04- Tipo da NF
			 SA1->A1_TIPO,;									// 05- Tipo do Cliente/Fornecedor
			 MaFisRelImp("MTR700",{"SC5","SC6"}),;			// 06- Relacao de Impostos que suportados no arquivo
			 ,;												// 07- Tipo de complemento
			 ,;												// 08- Permite incluir impostos no rodape (.T./.F.)
			 "SB1",;										// 09- Alias do cadastro de Produtos - ("SBI" para Front Loja)
			 "MTR700")	


MaFisClear()

MaFisAdd(SB1->B1_COD,;
        (cCabAlias)->C6_TES,;
        1,;
        nValorPre,;
        0,;
        "",;
        "",,;
        0,0,0,0,;
        nValorPre ;
        ,0)

	aExcecao := MaExcecao(nY)

    u_RelImp()	

	nAlqIPI   := MaFisRet(nY,"IT_ALIQIPI")/100  			//Aliquota de IPI ja em Percentual  
	nAlqOpIcm := MaFisRet(nY,"IT_ALIQICM")/100  			//Aliquota de ICMS OP em Percentual
	nPerComs  := FatComis(MaFisRet(nY,"IT_PRODUTO"))/100	//Percentual de comissao conforme modelo do veículo
    
	If !(MaFisRet(nY,"IT_TES") $ cTESTSD)	//-- TES de faturamento p/ veículo test drive (não tem comissão)
		nValComs := ROUND(nVlrRet * nPerComs,2)
	EndIf
	
	//nVlrUnit  := ROUND((nVlrRet + nValComs)*(1+nAlqIPI),2) 
	/*
	nVlrUnit  +=  nValComs
	
	nVlrRet   := nVlrUnit 
*/	
	MaFisRecal("",nY)  //Recalcula tudo com a tela atualizada
	u_RelImp()	
	
    (cCabAlias)->(RecLock(cCabAlias),.F.)
        //(cCabAlias)->C6_XVLRPRD := MaFisRet(nY,"IT_VALMERC")
        (cCabAlias)->C6_XVLRMVT := MaFisRet(nY,"IT_VALMERC")
        (cCabAlias)->C6_XVLRVDA := MaFisRet(nY,"IT_TOTAL") //nVlrUnit //
        (cCabAlias)->C6_PRCVEN  := MaFisRet(nY,"IT_VALMERC")
        (cCabAlias)->C6_VALOR   := MaFisRet(nY,"IT_VALMERC") //MaFisRet(nY,"IT_TOTAL")
    (cCabAlias)->(MsUnLock())

aEval(aArea,{|x| RestArea(x)})

Return 

Static Function AtuLinhaAtual()
	Local nItemFiscal
	Local nPosAtu
	
	nItemFiscal := oModelVRK:GetValue("ITEMFISCAL")

	For nPosAtu := 1 to Len(aVRK_RelImp)
		oModelVRK:LoadValue(aVRK_RelImp[nPosAtu][2] , MaFisRet(nItemFiscal,aVRK_RelImp[nPosAtu][3]), .t.)
	Next nPosAtu

Return


Static Function fImp(x)

DEFAULT x := 1

	aadd(aImp , {"PRODUTO"         ,MaFisRet(x,"IT_PRODUTO" )})
	aadd(aImp , {"TES"             ,MaFisRet(x,"IT_TES"     )})
	aadd(aImp , {"VALOR MERCADORIA",MaFisRet(x,"IT_VALMERC" )})		//62 Valor da Mercadoria
    aadd(aImp , {"UF DSTINO"       ,MaFisRet(,"NF_UFDEST"   )})               //UF do Destinatario
    aadd(aImp , {"UF ORIGEM"       ,MaFisRet(,"NF_UFORIGEM" )})            //UF de Origem
    
    aadd(aImp , {"ICM",;							//03 ICMS
	            MaFisRet(x,"IT_BASEICM"),;		//04 Base do ICMS
	            MaFisRet(x,"IT_ALIQICM"),;		//05 Aliquota do ICMS
	            MaFisRet(x,"IT_VALICM")	})		//06 Valor do ICMS
	aadd(aImp, {"IPI",;							//07 IPI
	            MaFisRet(x,"IT_BASEIPI"),;		//08 Base do IPI
	            MaFisRet(x,"IT_ALIQIPI"),;		//09 Aliquota do IPI
	            MaFisRet(x,"IT_VALIPI")})		//10 Valor do IPI
	aadd(aImp , {"PIS",;							//11 PIS/PASEP
	            MaFisRet(x,"IT_BASEPIS"),;		//12 Base do PIS
	            MaFisRet(x,"IT_ALIQPIS"),;		//13 Aliquota do PIS
	            MaFisRet(x,"IT_VALPIS")})			//14 Valor do PIS
	aadd(aImp , {"COF",;							//15 COFINS
	            MaFisRet(x,"IT_BASECOF"),;		//16 Base do COFINS
	            MaFisRet(x,"IT_ALIQCOF"),;		//17 Aliquota COFINS
	            MaFisRet(x,"IT_VALCOF")	})		//18 Valor do COFINS
	aadd(aImp , {"ISS",;							//19 ISS
	            MaFisRet(x,"IT_BASEISS"),;		//20 Base do ISS
	            MaFisRet(x,"IT_ALIQISS"),;		//21 Aliquota ISS
	            MaFisRet(x,"IT_VALISS")	})		//22 Valor do ISS
	aadd(aImp , {"IRR",;							//23 IRRF
	            MaFisRet(x,"IT_BASEIRR"),;		//24 Base do IRRF
	            MaFisRet(x,"IT_ALIQIRR"),;		//25 Aliquota IRRF
	            MaFisRet(x,"IT_VALIRR")	})		//26 Valor do IRRF
	aadd(aImp , {"INS",;							//27 INSS
	            MaFisRet(x,"IT_BASEINS"),;		//28 Base do INSS
	            MaFisRet(x,"IT_ALIQINS"),;		//29 Aliquota INSS
	            MaFisRet(x,"IT_VALINS")	})		//30 Valor do INSS
	aadd(aImp , {"CSL",;							//31 CSLL
	            MaFisRet(x,"IT_BASECSL"),;		//32 Base do CSLL
	            MaFisRet(x,"IT_ALIQCSL"),;		//33 Aliquota CSLL
	            MaFisRet(x,"IT_VALCSL")	})		//34 Valor do CSLL
	aadd(aImp , {"PS2",;							//35 PIS/Pasep - Via Apuração
	            MaFisRet(x,"IT_BASEPS2"),;		//36 Base do PS2 (PIS/Pasep - Via Apuração)
	            MaFisRet(x,"IT_ALIQPS2"),;		//37 Aliquota PS2 (PIS/Pasep - Via Apuração)
	            MaFisRet(x,"IT_VALPS2")	})		//38 Valor do PS2 (PIS/Pasep - Via Apuração)
	aadd(aImp , {"CF2",;							//39 COFINS - Via Apuração
	            MaFisRet(x,"IT_BASECF2"),;		//40 Base do CF2 (COFINS - Via Apuração)
	            MaFisRet(x,"IT_ALIQCF2"),;		//41 Aliquota CF2 (COFINS - Via Apuração)
	            MaFisRet(x,"IT_VALCF2")	})		//42 Valor do CF2 (COFINS - Via Apuração)
	aadd(aImp , {"ICC",;							//43 ICMS Complementar
	            MaFisRet(x,"IT_ALIQCMP"),;		//44 Base do ICMS Complementar
	            MaFisRet(x,"IT_ALIQCMP"),;		//45 Aliquota do ICMS Complementar
	            MaFisRet(x,"IT_VALCMP")})			//46 Valor do do ICMS Complementar
	aadd(aImp , {"ICA",;							//47 ICMS ref. Frete Autonomo
	            MaFisRet(x,"IT_BASEICA"),;		//48 Base do ICMS ref. Frete Autonomo
	            0,;								//49 Aliquota do ICMS ref. Frete Autonomo
	            MaFisRet(x,"IT_VALICA")})			//50 Valor do ICMS ref. Frete Autonomo
	aadd(aImp , {"TST",;							//51 ICMS ref. Frete Autonomo ST
	            MaFisRet(x,"IT_BASETST"),;		//52 Base do ICMS ref. Frete Autonomo ST
	            MaFisRet(x,"IT_ALIQTST"),;		//53 Aliquota do ICMS ref. Frete Autonomo ST
	            MaFisRet(x,"IT_VALTST")	})		//54 Valor do ICMS ref. Frete Autonomo ST
	aadd(aImp , {"ICMS-ST",;
                MaFisRet(x,"IT_BASESOL"),;		//55 Base do ICMS ST
	            MaFisRet(x,"IT_ALIQSOL"),;		//56 Aliquota do ICMS ST
	            MaFisRet(x,"IT_VALSOL")})			//57 Valor do ICMS ST
	aadd(aImp , {"DESCONTO", MaFisRet(x,"IT_DESCONTO")})		//58 Valor do Desconto
	aadd(aImp , {"FRETE"   , MaFisRet(x,"IT_FRETE"   )})			//59 Valor do Frete
	aadd(aImp , {"SEGURO"  , MaFisRet(x,"IT_SEGURO"  )})			//60 Valor do Seguro
	aadd(aImp , {"DESPESA" , MaFisRet(x,"IT_DESPESA" )})		//61 Valor das Despesas
	aadd(aImp , {"TOTAL"   , MaFisRet(x,"IT_TOTAL"   )})		//61 Valor das Despesas
/*	aadd(aImp , MaFisRet(1,"IT_DESCZF")		//Valor de Desconto da Zona Franca de Manaus
	aadd(aImp , MaFisRet(1,"IT_BASESOL")	//Base do ICMS Solidario
	aadd(aImp , MaFisRet(1,"IT_ALIQSOL")	//Aliquota do ICMS Solidario
	aadd(aImp , MaFisRet(1,"IT_MARGEM")		//Margem de lucro para calculo da Base do ICMS Sol.*/
	


RETURN

User Function RelImp()
Local nY := 1
Local cTexto := ""
Private aImp := {}

if !lDebug
    RETURN
EndIf

fImp()

For nY := 1 to len(aImp)
    if Len(aImp[nY]) == 2
        cTexto += PadR(aImp[nY,1],16,".")+":"
        if Valtype(aImp[nY,2]) == 'N'
            cTexto += Transform(aImp[nY,2],"@E 999,999,999.99")
        else
            cTexto += aImp[nY,2]
        endif
    elseif Len(aImp[nY]) == 4
        cTexto += PadR(aImp[nY,1],16,".")+":"
        cTexto += Transform(aImp[nY,2],"@E 999,999,999.99")+"|"
        cTexto += Transform(aImp[nY,3],"@E 999.99")+"|"
        cTexto += Transform(aImp[nY,4],"@E 999,999,999.99")
    EndIf
    cTexto += CrLf
Next nY

//FWAlertInfo(cTexto, "Impostos")
u_zMsgLog(cTexto, "Impostos", 1, .f.)

Return


User Function zMsgLog(cMsg, cTitulo, nTipo, lEdit)
    Local lRetMens := .F.
    Local oDlgMens
    Local oBtnOk, cTxtConf := ""
    Local oBtnCnc, cTxtCancel := ""
    Local oBtnSlv
    Local oFntTxt := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
    Local oMsg
    //Local nIni:=1
    //Local nFim:=50    
    Default cMsg    := "..."
    Default cTitulo := "zMsgLog"
    Default nTipo   := 1 // 1=Ok; 2= Confirmar e Cancelar
    Default lEdit   := .F.
     
    //Definindo os textos dos botões
    If(nTipo == 1)
        cTxtConf:='&Ok'
    Else
        cTxtConf:='&Confirmar'
        cTxtCancel:='C&ancelar'
    EndIf
 
    //Criando a janela centralizada com os botões
    DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 600, 500 COLORS 0, 16777215 PIXEL
        //Get com o Log
        @ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 300, 200 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
        If !lEdit
            oMsg:lReadOnly := .T.
        EndIf
         
        //Se for Tipo 1, cria somente o botão OK
        If (nTipo==1)
            @ 210, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
         
        //Senão, cria os botões OK e Cancelar
        ElseIf(nTipo==2)
            @ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
            @ 137, 144 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
        EndIf
         
        //Botão de Salvar em Txt
        @ 210, 004 BUTTON oBtnSlv PROMPT "&Salvar em .txt" SIZE 051, 019 ACTION (fSalvArq(cMsg, cTitulo)) OF oDlgMens PIXEL
    ACTIVATE MSDIALOG oDlgMens CENTERED
 
Return lRetMens
 
/*-----------------------------------------------*
 | Função: fSalvArq                              |
 | Descr.: Função para gerar um arquivo texto    |
 *-----------------------------------------------*/
 
Static Function fSalvArq(cMsg, cTitulo)
    Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
    Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
    Local lOk      := .T.
    Local cTexto   := ""
     
    //Pegando o caminho do arquivo
    cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)
 
    //Se o nome não estiver em branco    
    If !Empty(cFileNom)
        //Teste de existência do diretório
        If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
            Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
            Return
        EndIf
         
        //Montando a mensagem
        cTexto := "Função   - "+ FunName()       + CRLF
        cTexto += "Usuário  - "+ cUserName       + CRLF
        cTexto += "Data     - "+ dToC(dDataBase) + CRLF
        cTexto += "Hora     - "+ Time()          + CRLF
        cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg + cQuebra
         
        //Testando se o arquivo já existe
        If File(cFileNom)
            lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
        EndIf
         
        If lOk
            MemoWrite(cFileNom, cTexto)
            MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
        EndIf
    EndIf
Return


// ======================================================================= //
User Function BASSTPortal()
// ======================================================================= //

Local cVRKCODMAR := (cCabAlias)->C6_XCODMAR
Local cVRKMODVEI := (cCabAlias)->C6_XMODVEI
Local cVRKSEGMOD := (cCabAlias)->C6_XSEGMOD
Local cVRKFABMOD := (cCabAlias)->C6_XFABMOD
Local cVRKGRUMOD := (cCabAlias)->C6_XGRPMOD
Local nBaseST    := 0
Local cGrupo     := GetMV("MV_XVEI014",,"000003") 	// Venda de caminhao HD80, base icms st deve estar zerada
Local cMarca     := GetMV("MV_XVEI015",,"HYU") 		// Venda de caminhao HD80, base icms st deve estar zerada
Local cQuery     := ""

If (Alltrim(cVRKCODMAR) $ Alltrim(cMarca) .And. Alltrim(cVRKGRUMOD) $ Alltrim(cGrupo))
	Return nBaseST
EndIf 

If (cCabAlias)->C5_XTIPVEN $ "02/03/04/06"
	nBaseST := (cCabAlias)->C6_XVLRPRD //FWFldGet("VRK_VALPRE")
	If nBaseST == 0
		nBaseST := (cCabAlias)->C6_XPRCTAB// FWFldGet("VRK_VALTAB")
	EndIf
	If (cCabAlias)->C5_XTIPVEN $ "05/06" 			/// ALTERADO
		nBaseST := 0
	EndIf
ElseIf (cCabAlias)->C5_XTIPVEN $ "01"
	cQuery := ;
	          " SELECT   VVP.VVP_BASEST "                              + ; 
	          " FROM     " + RetSqlName("VVP") + " VVP "               + ; 
	          " WHERE    VVP.VVP_FILIAL  = '" + xFilial("VVP")  + "'"  + ;
	          "   AND    VVP.VVP_CODMAR  = '" + cVRKCODMAR      + "' " + ;
	          "   AND    VVP.VVP_MODVEI  = '" + cVRKMODVEI      + "' " + ;
	          "   AND    VVP.VVP_SEGMOD  = '" + cVRKSEGMOD      + "' " + ;
	          "   AND    VVP.VVP_FABMOD  = '" + cVRKFABMOD      + "' " + ;
	          "   AND    VVP.VVP_DATPRC <= '" + dtos(dDataBase) + "'"  + ;
	          "   AND    VVP.D_E_L_E_T_=' ' " +;
	          " ORDER BY VVP.VVP_DATPRC DESC"
	nBaseST := FM_SQL(cQuery)
EndIf


Return nBaseST


Static Function fTabBackup(aCabStru)
Local nX := 0
Local aLinha as Array

(cCabAlias)->(DbGotop())

While (cCabAlias)->(!Eof())
    aLinha := {}
    For nX := 1 to Len(aCabStru)
        aadd(aLinha ,(cCabAlias)->&(aCabStru[nX,1]))

    Next nX

    aadd(aCamBkp,aLinha)
    (cCabAlias)->(DbSkip())

EndDo

(cCabAlias)->(DbGotop())

Return 


/*
/*
// -------------------------------------------------------------------
// Campos utilizados para retorno dos impostos calculado Cabecalho
// -------------------------------------------------------------------
NF_TIPONF               //Tipo : N , I , C , P
NF_OPERNF               //E-Entrada | S – Saida
NF_CLIFOR               //C-Cliente | F – Fornecedor
NF_TPCLIFOR             //Tipo do destinatario R,F,S,X
NF_LINSCR               //Indica se o destino possui inscricao estadual
NF_GRPCLI               //Grupo de Tributacao
NF_UFDEST               //UF do Destinatario
NF_UFORIGEM             //UF de Origem
NF_DESCONTO             //Valor Total do Deconto
NF_FRETE                //Valor Total do Frete
NF_DESPESA              //Valor Total das Despesas Acessorias
NF_SEGURO               //Valor Total do Seguro
NF_AUTONOMO             //Valor Total do Frete Autonomo
NF_ICMS                 //Array contendo os valores de ICMS
NF_BASEICM              //Valor da Base de ICMS
NF_VALICM               //Valor do ICMS Normal
NF_BASESOL              //Base do ICMS Solidario
NF_VALSOL               //Valor do ICMS Solidario
NF_BICMORI              //Base do ICMS Original
NF_VALCMP               //Valor do Icms Complementar
NF_BASEICA              //Base do ICMS sobre o Frete Autonomo
NF_VALICA               //Valor do ICMS sobre o Frete Autonomo
NF_IPI                  //Array contendo os valores de IPI
NF_BASEIPI              //Valor da Base do IPI
NF_VALIPI               //Valor do IPI
NF_BIPIORI              //Valor da Base Original do IPI
NF_TOTAL                //Valor Total da NF
NF_VALMERC              //Total de Mercadorias
NF_FUNRURAL             //Valor Total do FunRural
NF_CODCLIFOR            //Codigo do Cliente/Fornecedor
NF_LOJA                 //Loja do Cliente/Fornecedor
NF_LIVRO                //Array contendo o Demonstrativo Fiscal
NF_ISS                  //Array contendo os Valores de ISS
NF_BASEISS              //Base de Calculo do ISS
NF_VALISS               //Valor do ISS
NF_IR                   //Array contendo os valores do Imposto de renda
NF_BASEIRR              //Base do Imposto de Renda do item
NF_VALIRR               //Valor do IR do item
NF_INSS                 //Array contendo os valores de INSS
NF_BASEINS              //Base de calculo do INSS
NF_VALINS               //Valor do INSS do item
NF_NATUREZA             //Codigo da natureza a ser gravado nos titulos do ?Financeiro.
NF_VALEMB               //Valor da Embalagem
NF_RESERV1              //Array contendo as Bases de Impostos ( ?Argentina,Chile,Etc)
NF_RESERV2              //Array contendo os valores de Impostos ( ?Argentina,Chile,Etc)
NF_IMPOSTOS             //Array contendo todos os impostos calculados na banks with coinstar Coinstar Money Transfer, BURKINA FASO, BOBO DIOULASSO funcao ?Fiscal com quebra por impostos+aliquotas
IMP_COD                 //Codigo do imposto no ArrayNF_IMPOSTOS
IMP_DESC                //Descricao do imposto no Array NF_IMPOSTOS
IMP_BASE                //Base de Calculo do Imposto no Array NF_IMPOSTOS
IMP_ALIQ                //Aliquota de calculo do imposto
IMP_VAL                 //Valor do Imposto no Array NF_IMPOSTOS
IMP_NOME                //Nome de referencia aos Impostos do cabecalho
NF_BASEDUP              //Base de calculo das duplicatas geradas no financeiro
NF_RELIMP               //Array contendo a relacao de impostos que podem ser ?alterados
NF_IMPOSTOS2            //Array contendo todos os impostos calculados na funcao ?Fiscal com quebras por impostos
NF_DESCZF               //Valor Total do desconto da Zona Franca
NF_SUFRAMA              // Indica se o Cliente pertence a SUFRAMA
NF_BASEIMP              //Array contendo as Bases de Impostos Variaveis
NF_BASEIV1              //Base de Impostos Variaveis 1
NF_BASEIV2              //Base de Impostos Variaveis 2
NF_BASEIV3              //Base de Impostos Variaveis 3
NF_BASEIV4              //Base de Impostos Variaveis 4
NF_BASEIV5              //Base de Impostos Variaveis 5
NF_BASEIV6              //Base de Impostos Variaveis 6
NF_BASEIV7              //Base de Impostos Variaveis 7
NF_BASEIV8              //Base de Impostos Variaveis 8
NF_BASEIV9              //Base de Impostos Variaveis 9
NF_VALIMP               //Array contendo os valores de Impostos ?Agentina/Chile/Etc.
NF_VALIV1               //Valor do Imposto Variavel 1
NF_VALIV2               //Valor do Imposto Variavel 2
NF_VALIV3               //Valor do Imposto Variavel 3
NF_VALIV4               //Valor do Imposto Variavel 4
NF_VALIV5               //Valor do Imposto Variavel 5
NF_VALIV6               //Valor do Imposto Variavel 6
NF_VALIV7               //Valor do Imposto Variavel 7
NF_VALIV8               //Valor do Imposto Variavel 8
NF_VALIV9               //Valor do Imposto Variavel 96
NF_TPCOMP               //Tipo de complemento – F Frete , D Despesa Imp.
NF_INSIMP               //Flag de Controle : Indica se podera inserir Impostos ?no Rodape.
NF_PESO                 //Peso Total das mercadorias da NF
NF_ICMFRETE             //Valor do ICMS relativo ao frete
NF_BSFRETE              //Base do ICMS relativo ao frete
NF_BASECOF              //Base de calculo do COFINS
NF_VALCOF               //Valor do COFINS
NF_BASECSL              //Base de calculo do CSLL
NF_VALCSL               //Valor do CSLL
NF_BASEPIS              //Base de calculo do PIS
NF_VALPIS               //Valor do PIS
NF_ROTINA               //Nome da rotina que esta utilizando a funcao
NF_AUXACUM              //Campo auxiliar para acumulacao no calculo de impostos
NF_ALIQIR               //Aliquota de IRF do Cliente
NF_VNAGREG              //Valor da Mercadoria nao agregada.

*/
/*
// -------------------------------------------------------------------
// Campos utilizados para retorno dos impostos calculado
// -------------------------------------------------------------------
IT_GRPTRIB				//Grupo de Tributacao
IT_EXCECAO				//Array da EXCECAO Fiscal
IT_ALIQICM				//Aliquota de ICMS
IT_ICMS					//Array contendo os valores de ICMS
IT_BASEICM				//Valor da Base de ICMS
IT_VALICM				//Valor do ICMS Normal
IT_BASESOL				//Base do ICMS Solidario
IT_ALIQSOL				//Aliquota do ICMS Solidario
IT_VALSOL				//Valor do ICMS Solidario
IT_MARGEM				//Margem de lucro para calculo da Base do ICMS Sol.
IT_BICMORI				//Valor original da Base de ICMS
IT_ALIQCMP				//Aliquota para calculo do ICMS Complementar
IT_VALCMP				//Valor do ICMS Complementar do item
IT_BASEICA				//Base do ICMS sobre o frete autonomo
IT_VALICA				//Valor do ICMS sobre o frete autonomo
IT_DEDICM				//Valor do ICMS a ser deduzido
IT_VLCSOL				//Valor do ICMS Solidario calculado sem o credito aplicado
IT_PAUTIC				//Valor da Pauta do ICMS Proprio
IT_PAUTST				//Valor da Pauta do ICMS-ST
IT_PREDIC				//%Redução da Base do ICMS
IT_PREDST				//%Redução da Base do ICMS-ST
IT_MVACMP				//Margem do complementar
IT_PREDCMP				//%Redução da Base do ICMS-CMP
IT_ALIQIPI				//Aliquota de IPI
IT_IPI					//Array contendo os valores de IPI
IT_BASEIPI				//Valor da Base do IPI
IT_VALIPI				//Valor do IPI
IT_BIPIORI				//Valor da Base Original do IPI
IT_PREDIPI				//%Redução da Base do IPI
IT_PAUTIPI				//Valor da Pauta do IPI
IT_NFORI				//Numero da NF Original
IT_SERORI				//Serie da NF Original
IT_RECORI				//RecNo da NF Original (SD1/SD2)
IT_DESCONTO				//Valor do Desconto
IT_FRETE				//Valor do Frete
IT_DESPESA				//Valor das Despesas Acessorias
IT_SEGURO				//Valor do Seguro
IT_AUTONOMO				//Valor do Frete Autonomo
IT_VALMERC				//Valor da mercadoria
IT_PRODUTO				//Codigo do Produto
IT_TES					//Codigo da TES
IT_TOTAL				//Valor Total do Item
IT_CF					//Codigo Fiscal de Operacao
IT_FUNRURAL				//Aliquota para calculo do Funrural
IT_PERFUN				//Valor do Funrural do item
IT_DELETED				//Flag de controle para itens deletados
IT_LIVRO				//Array contendo o Demonstrativo Fiscal do Item
IT_ISS					//Array contendo os valores de ISS
IT_ALIQISS				//Aliquota de ISS do item
IT_BASEISS				//Base de Calculo do ISS
IT_VALISS				//Valor do ISS do item
IT_CODISS				//Codigo do ISS
IT_CALCISS				//Flag de controle para calculo do ISS
IT_RATEIOISS			//Flag de controle para calculo do ISS
IT_CFPS					//Codigo Fiscal de Prestacao de Servico
IT_PREDISS				//Redução da base de calculo do ISS
IT_VALISORI				//Valor do ISS do item sem aplicar o arredondamento
IT_IR					//Array contendo os valores do Imposto de renda
IT_BASEIRR				//Base do Imposto de Renda do item
IT_REDIR				//Percentual de Reducao da Base de calculo do IR
IT_ALIQIRR				//Aliquota de Calculo do IR do Item
IT_VALIRR				//Valor do IR do Item
IT_INSS					//Array contendo os valores de INSS
IT_BASEINS				//Base de calculo do INSS
IT_REDINSS				//Percentual de Reducao da Base de Calculo do INSS
IT_ALIQINS				//Aliquota de Calculo do INSS
IT_VALINS				//Valor do INSS
IT_ACINSS				//Acumulo INSS
IT_VALEMB				//Valor da embalagem
IT_BASEIMP				//Array contendo as Bases de Impostos Variaveis
IT_BASEIV1				//Base de Impostos Variaveis 1
IT_BASEIV2				//Base de Impostos Variaveis 2
IT_BASEIV3				//Base de Impostos Variaveis 3
IT_BASEIV4				//Base de Impostos Variaveis 4
IT_BASEIV5				//Base de Impostos Variaveis 5
IT_BASEIV6				//Base de Impostos Variaveis 6
IT_BASEIV7				//Base de Impostos Variaveis 7
IT_BASEIV8				//Base de Impostos Variaveis 8
IT_BASEIV9				//Base de Impostos Variaveis 9
IT_ALIQIMP				//Array contendo as Aliquotas de Impostos Variaveis
IT_ALIQIV1				//Aliquota de Impostos Variaveis 1
IT_ALIQIV2				//Aliquota de Impostos Variaveis 2
IT_ALIQIV3				//Aliquota de Impostos Variaveis 3
IT_ALIQIV4				//Aliquota de Impostos Variaveis 4
IT_ALIQIV5				//Aliquota de Impostos Variaveis 5
IT_ALIQIV6				//Aliquota de Impostos Variaveis 6
IT_ALIQIV7				//Aliquota de Impostos Variaveis 7
IT_ALIQIV8				//Aliquota de Impostos Variaveis 8
IT_ALIQIV9				//Aliquota de Impostos Variaveis 9
IT_VALIMP				//Array contendo os valores de Impostos Agentina/Chile/Etc.
IT_VALIV1				//Valor do Imposto Variavel 1
IT_VALIV2				//Valor do Imposto Variavel 2
IT_VALIV3				//Valor do Imposto Variavel 3
IT_VALIV4				//Valor do Imposto Variavel 4
IT_VALIV5				//Valor do Imposto Variavel 5
IT_VALIV6				//Valor do Imposto Variavel 6
IT_VALIV7				//Valor do Imposto Variavel 7
IT_VALIV8				//Valor do Imposto Variavel 8
IT_VALIV9				//Valor do Imposto Variavel 9
IT_BASEDUP				//Base das duplicatas geradas no financeiro
IT_DESCZF				//Valor do desconto da Zona Franca do item
IT_DESCIV				//Array contendo a descricao dos Impostos Variaveis
IT_DESCIV1				//Array contendo a Descricao dos IV 1
IT_DESCIV2				//Array contendo a Descricao dos IV 2
IT_DESCIV3				//Array contendo a Descricao dos IV 3
IT_DESCIV4				//Array contendo a Descricao dos IV 4
IT_DESCIV5				//Array contendo a Descricao dos IV 5
IT_DESCIV6				//Array contendo a Descricao dos IV 6
IT_DESCIV7				//Array contendo a Descricao dos IV 7
IT_DESCIV8				//Array contendo a Descricao dos IV 8
IT_DESCIV9				//Array contendo a Descricao dos IV 9
IT_QUANT				//Quantidade do Item
IT_PRCUNI				//Preco Unitario do Item
IT_VIPIBICM				//Valor do IPI Incidente na Base de ICMS
IT_PESO					//Peso da mercadoria do item
IT_ICMFRETE				//Valor do ICMS Relativo ao Frete
IT_BSFRETE				//Base do ICMS Relativo ao Frete
IT_BASECOF				//Base de calculo do COFINS
IT_ALIQCOF				//Aliquota de calculo do COFINS
IT_VALCOF				//Valor do COFINS
IT_BASECSL				//Base de calculo do CSLL
IT_ALIQCSL				//Aliquota de calculo do CSLL
IT_VALCSL				//Valor do CSLL
IT_BASEPIS				//Base de calculo do PIS
IT_ALIQPIS				//Aliquota de calculo do PIS
IT_VALPIS				//Valor do PIS
IT_RECNOSB1				//RecNo do SB1
IT_RECNOSF4				//RecNo do SF4
IT_VNAGREG				//Valor da Mercadoria nao agregada.
IT_TIPONF				//Tipo da nota fiscal
IT_REMITO				//Remito
IT_BASEPS2				//Base de calculo do PIS 2
IT_ALIQPS2				//Aliquota de calculo do PIS 2
IT_VALPS2				//Valor do PIS 2
IT_BASECF2				//Base de calculo do COFINS 2
IT_ALIQCF2				//Aliquota de calculo do COFINS 2
IT_VALCF2				//Valor do COFINS 2
IT_ABVLINSS				//Abatimento da base do INSS em valor 
IT_ABVLISS				//Abatimento da base do ISS em valor 
IT_REDISS				//Percentual de reducao de base do ISS ( opcional, utilizar normalmente TS_BASEISS ) 
IT_ICMSDIF				//Valor do ICMS diferido
IT_DESCZFPIS			//Desconto do PIS
IT_DESCZFCOF			//Desconto do Cofins
IT_BASEAFRMM			//Base de calculo do AFRMM ( Item )
IT_ALIQAFRMM			//Aliquota de calculo do AFRMM ( Item )
IT_VALAFRMM				//Valor do AFRMM ( Item )
IT_PIS252				//Decreto 252 de 15/06/2005 - PIS no item para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
IT_COF252				//Decreto 252 de 15/06/2005 - COFINS no item para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
IT_CRDZFM				//Credito Presumido - Zona Franca de Manaus
IT_CNAE					//Codigo da Atividade Economica da Prestacao de Servicos
IT_ITEM					//Numero Item
IT_SEST					//Array contendo os valores do SEST
IT_BASESES				//Base de calculo do SEST
IT_ALIQSES				//Aliquota de calculo do SEST
IT_VALSES				//Valor do INSS
IT_BASEPS3				//Base de calculo do PIS Subst. Tributaria
IT_ALIQPS3				//Aliquota de calculo do PIS Subst. Tributaria
IT_VALPS3				//Valor do PIS Subst. Tributaria
IT_BASECF3				//Base de calculo da COFINS Subst. Tributaria
IT_ALIQCF3				//Aliquota de calculo da COFINS Subst. Tributaria
IT_VALCF3				//Valor da COFINS Subst. Tributaria
IT_VLR_FRT				//Valor do Frete de Pauta
IT_BASEFET				//Base do Fethab   
IT_ALIQFET				//Aliquota do Fethab
IT_VALFET				//Valor do Fethab   
IT_ABSCINS				//Abatimento do Valor do INSS em Valor - SubContratada
IT_SPED					//SPED
IT_ABMATISS				//Abatimento da base do ISS em valor referente a material utilizado 
IT_RGESPST				//Indica se a operacao, mesmo sem calculo de ICMS ST, faz parte do Regime Especial de Substituicao Tributaria
IT_PRFDSUL				//Percentual de UFERMS para o calculo do Fundersul - Mato Grosso do Sul
IT_UFERMS				//Valor da UFERMS para o calculo do Fundersul - Mato Grosso do Sul
IT_VALFDS				//Valor do Fundersul - Mato Grosso do Sul
IT_ESTCRED				//Valor do Estorno de Credito/Debito
IT_CODIF				//Codigo de autorizacao CODIF - Combustiveis
IT_BASETST				//Base do ICMS de transporte Substituicao Tributaria
IT_ALIQTST				//Aliquota do ICMS de transporte Substituicao Tributaria
IT_VALTST				//Valor do ICMS de transporte Substituicao Tributaria
IT_CRPRSIM				//Valor Crédito Presumido Simples Nacional - SC, nas aquisições de fornecedores que se enquadram no simples
IT_VALANTI				//Valor Antecipacao ICMS                       
IT_DESNTRB				//Despesas Acessorias nao tributadas - Portugal
IT_TARA					//Tara - despesas com embalagem do transporte - Portugal
IT_PROVENT				//Provincia de entrega
IT_VALFECP				//Valor do FECP
IT_VFECPST				//Valor do FECP ST
IT_ALIQFECP				//Aliquota FECP
IT_CRPRESC				//Credito Presumido SC 
IT_DESCPRO				//Valor do desconto total proporcionalizado
IT_ANFORI2				//IVA Ajustado
IT_UFORI				//UF Original da Nota de Entrada para o calculo do IVA Ajustado( Opcional )
IT_ALQORI				//Aliquota Original da Nota de Entrada para o calculo do IVA Ajustado ( Opcional )
IT_PROPOR				//Quantidade proporcional na venda para o calculo do IVA Ajustado( Opcional )
IT_ALQPROR				//Aliquota proporcional na venda para o calculo do IVA Ajustado( Opcional )
IT_ANFII				//Array contendo os valores do Imposto de Importação
IT_ALIQII				//Aliquota do Imposto de Importação
IT_VALII				//Valor do Imposto de Importação (Digitado direto na Nota Fiscal)
IT_PAUTPIS				//Valor da Pauta do PIS
IT_PAUTCOF				//Valor da Pauta do Cofins
IT_ALIQDIF				//Aliquota interna do estado para calculo do Diferencial de aliquota do Simples Nacional
IT_CLASFIS				//Valor do Imposto de Importação (Digitado direto na Nota Fiscal)
IT_VLRISC				//Valor do imposto ISC (Localizado Peru) por unidade  "PER"
IT_CRPREPE				//Credito Presumido - Art. 6 Decreto  n28.247
IT_CRPREMG				//Credito Presumido MG 
IT_SLDDEP				//Valor de desconto de depedendente fornecedor
*/
