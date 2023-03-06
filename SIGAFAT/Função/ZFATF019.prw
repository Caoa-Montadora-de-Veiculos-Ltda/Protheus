#Include 'Protheus.Ch'
#Include 'RwMake.Ch'
#Include 'Font.Ch'
#Include 'Colors.Ch'
#Include "TopConn.Ch"
#Include "TbiConn.CH"
Static cMarca 	 := GetMark()

/*/{Protheus.doc} ZFATF019
Portal Comercial

@author Leonardo Miranda
@since 03/03/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

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
oBtn01 := TButton():New( 020,016,"Faturamento Atacado"   ,oGrp01,{|| FWMsgRun(, {|oSay| fLibPed(oSay) }, "Faturamento", "Processando pedidos")  },068,032,,,,.T.,,"",,,,.F. )
oBtn03 := TButton():New( 020,094,"Cancelar Notas Fiscais",oGrp01,{|| fCanNotas()}                                                                ,068,032,,,,.T.,,"",,,,.F. )
oBtn04 := TButton():New( 020,171,"Devolver Notas Fiscais",oGrp01,{|| fDevNotas()}                                                                ,068,032,,,,.T.,,"",,,,.F. )
oBtn04 := TButton():New( 020,248,"Transmiss„o de Notas"  ,oGrp01,{|| SPEDNFe()}                                                                  ,068,032,,,,.T.,,"",,,,.F. )
//oBtn04 := TButton():New( 020,325,"Incluir Pedido Venda"  ,oGrp01,{|| fVisuPed("SC5",aRotina,3,Nil,Nil,Nil)}                                      ,068,032,,,,.T.,,"",,,,.F. )
oBtn04 := TButton():New( 020,325,"Pedidos Venda"         ,oGrp01,{|| MATA410()}                                                                  ,068,032,,,,.T.,,"",,,,.F. )

oDlg01:Activate(,,,.T.)

Return(Nil)

*****************************
Static Function fLibPed(oSay)
*****************************

Local bRet          As Logical
Local aRet          As Array
Local cQryAlias     As Character
Local nLinha        As Numeric
Local nColuna       As Numeric

Local oFWL          As Object
Local oPnlWnd1      As Object
Local oPnlWnd2      As Object
Local oSize1        As Object
Local oSize2        As Object
Local aCabStru      As Array
Local aCabCol       As Array
Local cCabTable     As Character
Local aCords        As Array
Local cTipCpo       As Character

Local oBrwIte       As Object
Local aIteCampos    As Array
Local aIteStru      As Array
Local aIteCol       As Array
Local oIteTable     As Object
Local cIteTable     As Character

Local aTamSx3       As Array
Local nY            As Numeric
Local cPictAlias    As Character
Local cQuery        As Character
Local nStatus       As Numeric
Local aValidCmp     As Array

Private oPnlWnd1      As Object
Private oPnlWnd2      As Object
Private aParamBox   As Array
Private oModel      As Object
Private cCabAlias   As Character
Private cIteAlias   As Character
Private oNwFat001   As Object
Private oBrwCab     As Object
Private oCabTable   As Object
Private aCabCampos  As Object

bRet        := .F.
aRet        := {}
aParamBox   := {}
aRotina     := {}
aCords      := FWGetDialogSize( oMainWnd )
nColuna     := 1
nLinha      := 1

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

bRet := ParamBox(aParambox, "Parametros para seleÁ„o dos dados"	, @aRet, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .T. /*lUserSave*/)
If !bRet
    ApMsgStop("Rotina cancelada!", "Pedidos TÌtulo")
    Return(.F.)
EndIf

/*********************************************************************************************************************************************/
//CabeÁalho
aCabCampos  := {"C6_OK"     ,"CC_STATUS" ,"C6_FILIAL" ,"C6_NUM"    ,"C6_PEDCLI" ,"C5_EMISSAO","C5_CLIENTE","C5_LOJACLI",;
                "A1_NOME"   ,"C5_CONDPAG","C5_NATUREZ","C5_XMENSER","C6_ITEM"   ,"C6_PRODUTO","B1_DESC"   ,"C6_LOCAL"  ,;
                "C6_CHASSI" ,"C6_NUMSERI","C6_LOCALIZ","C6_XCODMAR","C6_XDESMAR","C6_XGRPMOD","C6_XDGRMOD","C6_XMODVEI",;
                "C6_XDESMOD","C6_XSEGMOD","C6_XDESSEG","C6_XFABMOD","C6_XCORINT","C6_XCOREXT","C6_QTDVEN" ,"C6_PRCVEN" ,;
                "C6_VALOR"  ,"C6_OPER"   ,"C6_TES"    ,"C6_XVLRVDA","C6_PRUNIT" ,"C6_XPRCTAB","C6_XVLRPRD","C6_XVLRMVT",;
                "C6_XBASST" ,"C9_SEQUEN" ,"C9_NFISCAL","C9_SERIENF","C5_XTIPVEN"}
aValidCmp   := {{"C5_CONDPAG","{ || fVldCampo(cCabAlias,oSay,cCabTable,oCabTable)}"},;
                {"C5_NATUREZ","{ || fVldCampo(cCabAlias,oSay,cCabTable,oCabTable)}"},;
                {"C5_XMENSER","{ || fVldCampo(cCabAlias,oSay,cCabTable,oCabTable)}"},;
                {"C6_NUMSERI","{ || fVldCampo(cCabAlias,oSay,cCabTable,oCabTable)}"},;
                {"C6_OPER"   ,"{ || fVldCampo(cCabAlias,oSay,cCabTable,oCabTable)}"},;
                {"C6_TES"    ,"{ || fVldCampo(cCabAlias,oSay,cCabTable,oCabTable)}"},;
                {"C6_LOCALIZ","{ || fVldCampo(cCabAlias,oSay,cCabTable,oCabTable)}"},;
                {"C6_XVLRPRD","{ || fVldCampo(cCabAlias,oSay,cCabTable,oCabTable)}"}} 

aCabStru    := {}
For nY := 1 To Len(aCabCampos)
    aTamSx3 := TamSX3(aCabCampos[nY])
    Aadd(aCabStru, {aCabCampos[nY] ,aTamSx3[03] ,aTamSx3[01] ,aTamSx3[02] })
Next

aCabCol := {}
For nY := 02 To Len(aCabStru)
    //Columas CabeÁalho
    If !aCabStru[nY][1] $ "C6_FILIAL|CC_STATUS|C9_SEQUEN|C9_NFISCAL|C9_SERIENF|C6_PRUNIT|C6_XGRPMOD|C6_XDGRMOD|C6_XCORINT|C6_XCOREXT|C5_XTIPVEN|C6_NUMSERI|C5_XMENSER"
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
            aCabStru[nY][1] $ "C5_CONDPAG|C5_NATUREZ|C5_XMENSER|C6_NUMSERI|C6_LOCALIZ|C6_TES|C6_XVLRPRD|C6_OPER"
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
oCabTable:AddIndex("INDEX1", {"C6_FILIAL", "C5_CLIENTE", "C5_LOJACLI", "C6_PRODUTO"} )
oCabTable:Create()
cCabAlias := oCabTable:GetAlias()

cCabTable := oCabTable:GetRealName()
cQuery := ""
cQuery += " INSERT INTO "+cCabTable+"                                                                                    "+(Chr(13)+Chr(10))
cQuery += " ("
For nY := 1 To Len(aCabCampos)
    If Upper(Alltrim(aCabCampos[nY])) <> "C9_SEQUEN"  .And.;
       Upper(Alltrim(aCabCampos[nY])) <> "C9_NFISCAL" .And.;
       Upper(Alltrim(aCabCampos[nY])) <> "C9_SERIENF" .And.;
       Upper(Alltrim(aCabCampos[nY])) <> "C5_XMENSER"
       cQuery += aCabCampos[nY]+","
    EndIf
Next
cQuery += " D_E_L_E_T_,R_E_C_N_O_)                                                                                       "+(Chr(13)+Chr(10))
cQuery += " SELECT '  ' C6_OK    ,                                                                                       "+(Chr(13)+Chr(10))
cQuery += " ' '         C6_STATUS,                                                                                       "+(Chr(13)+Chr(10))
For nY := 1 To Len(aCabCampos)
    If  Upper(Alltrim(aCabCampos[nY])) <> "C6_OK"      .And.;
        Upper(Alltrim(aCabCampos[nY])) <> "CC_STATUS"  .And.;
        Upper(Alltrim(aCabCampos[nY])) <> "C9_SEQUEN"  .And.;
        Upper(Alltrim(aCabCampos[nY])) <> "C9_NFISCAL" .And.;
        Upper(Alltrim(aCabCampos[nY])) <> "C9_SERIENF" .And.;
        Upper(Alltrim(aCabCampos[nY])) <> "C5_XMENSER"
        If Left(aCabCampos[nY],3) == "C6_" ; cQryAlias := "SC6." ; EndIf
        If Left(aCabCampos[nY],3) == "C5_" ; cQryAlias := "SC5." ; EndIf
        If Left(aCabCampos[nY],3) == "A1_" ; cQryAlias := "SA1." ; EndIf
        If Left(aCabCampos[nY],3) == "B1_" ; cQryAlias := "SB1." ; EndIf
        If Left(aCabCampos[nY],3) == "F4_" ; cQryAlias := "SF4." ; EndIf
        cQuery += " "+(cQryAlias+aCabCampos[nY])+",                                                                       "+(Chr(13)+Chr(10))"
    EndIf
Next
cQuery += "        ' '                                                                                      D_E_L_E_T_  , "+(Chr(13)+Chr(10))
cQuery += "        ROW_NUMBER() OVER (ORDER BY SC6.C6_FILIAL,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC6.C6_PRODUTO)  R_E_C_N_O_    "+(Chr(13)+Chr(10))
cQuery += " FROM "+RetSqlName("SC6")+" SC6                                                                                "+(Chr(13)+Chr(10))
cQuery += "      INNER JOIN                                                                                               "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SC5")+" SC5 ON   SC6.C6_FILIAL   = SC5.C5_FILIAL                                           "+(Chr(13)+Chr(10))
cQuery += "                                 AND SC6.C6_NUM      = SC5.C5_NUM                                              "+(Chr(13)+Chr(10))
cQuery += "                                 AND SC6.D_E_L_E_T_  = SC5.D_E_L_E_T_                                          "+(Chr(13)+Chr(10))
cQuery += "      INNER JOIN                                                                                               "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SA1")+" SA1 ON   SC5.C5_CLIENTE  = SA1.A1_COD                                              "+(Chr(13)+Chr(10))
cQuery += "                                 AND SC5.C5_LOJACLI  = SA1.A1_LOJA                                             "+(Chr(13)+Chr(10))
cQuery += "                                 AND SC5.D_E_L_E_T_  = SA1.D_E_L_E_T_                                          "+(Chr(13)+Chr(10))
cQuery += "      INNER JOIN                                                                                               "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SB1")+" SB1 ON   SC6.C6_PRODUTO  = SB1.B1_COD                                              "+(Chr(13)+Chr(10))
cQuery += "                                 AND SC6.D_E_L_E_T_  = SB1.D_E_L_E_T_                                          "+(Chr(13)+Chr(10))
cQuery += "      INNER JOIN                                                                                               "+(Chr(13)+Chr(10))
cQuery += "      "+RetSqlName("SF4")+" SF4 ON   SC6.C6_TES      = SF4.F4_CODIGO                                           "+(Chr(13)+Chr(10))
cQuery += "                                 AND SC6.D_E_L_E_T_  = SF4.D_E_L_E_T_                                          "+(Chr(13)+Chr(10))
cQuery += " WHERE   SC6.C6_FILIAL           = '"+xFilial("SC6")+"'                                                        "+(Chr(13)+Chr(10))
cQuery += "     AND SC5.C5_TIPO             = 'N'                                                                         "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_QTDVEN           > SC6.C6_QTDENT                                                               "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_NOTA             = ' '                                                                         "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_BLQ              = ' '                                                                         "+(Chr(13)+Chr(10))
cQuery += "     AND SC5.C5_CLIENTE          >= '"+aRet[01]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC5.C5_CLIENTE          <= '"+aRet[03]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC5.C5_LOJACLI          >= '"+aRet[02]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC5.C5_LOJACLI          <= '"+aRet[04]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_PRODUTO          >= '"+aRet[05]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_PRODUTO          <= '"+aRet[06]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_PEDCLI           >= '"+aRet[08]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_PEDCLI           <= '"+aRet[09]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XCODMAR          >= '"+aRet[10]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XCODMAR          <= '"+aRet[11]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XGRPMOD          >= '"+aRet[12]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XGRPMOD          <= '"+aRet[13]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XMODVEI          >= '"+aRet[14]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XMODVEI          <= '"+aRet[15]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XSEGMOD          >= '"+aRet[16]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XSEGMOD          <= '"+aRet[17]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XFABMOD          >= '"+aRet[18]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XFABMOD          <= '"+aRet[19]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XCORINT          >= '"+aRet[20]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XCORINT          <= '"+aRet[21]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XCOREXT          >= '"+aRet[22]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SC6.C6_XCOREXT          <= '"+aRet[23]+"'                                                             "+(Chr(13)+Chr(10))
cQuery += "     AND SB1.B1_GRUPO            = 'VEIA'                                                                      "+(Chr(13)+Chr(10))
cQuery += "     AND SF4.F4_DUPLIC           = 'S'                                                                         "+(Chr(13)+Chr(10))
cQuery += " 	AND SC6.D_E_L_E_T_			= ' '                                                                         "+(Chr(13)+Chr(10))
cQuery += " ORDER BY SC6.C6_FILIAL,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC6.C6_PRODUTO                                           "+(Chr(13)+Chr(10))
nStatus := TCSqlExec(cQuery)

(cCabAlias)->(DbGoTop())
If (nStatus < 0)
    MsgStop("TCSQLError() " + TCSQLError(), "Registros CabeÁalho")
    If Select(cCabAlias) <> 0 ; (cCabAlias)->(DbCloseArea()) ; EndIf
    oCabTable:Delete()
    Return Nil
ElseIf (cCabAlias)->(Eof())
    MsgStop(OemToAnsi("N„o foram encontrados registros para endereÁar!"),OemToAnsi("AtenÁ„o"))   
    Return(Nil)
EndIf

fAtuPeds(cCabAlias,oSay,cCabTable,oCabTable,"")

/*********************************************************************************************************************************************/
DEFINE DIALOG oNwFat001 TITLE "Faturamento Atacado" FROM aCords[ 1 ], aCords[ 2 ] TO (aCords[3]*nLinha), (aCords[ 4 ]*nColuna) PIXEL
oNwFat001:lEscClose := .F.

// Instancia o layer
oFWL := FWLayer():New()
// Inicia o Layer
oFWL:Init( oNwFat001, .F. )
// Cria uma linha unica para o Layer
oFWL:AddLine( 'TOTAL', 90 , .F.)

// Cria colunas
oFWL:AddCollumn( 'DIR', 100, .F., 'TOTAL' )
	
oFWL:AddWindow( 'DIR' , 'Wnd1', "Pedidos de Venda"       ,  80, .F., .T.,, 'TOTAL' )
oFWL:AddWindow( 'DIR' , 'Wnd2', "Totais para faturamento",  20, .F., .T.,, 'TOTAL' )

oPnlWnd1:= oFWL:getWinPanel( 'DIR', 'Wnd1', 'TOTAL' )
oPnlWnd2:= oFWL:getWinPanel( 'DIR', 'Wnd2', 'TOTAL' )

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
                                                                       "Faturamento", "Processando geraÁ„o de notas"), oNwFat001:End() }, ;
{ || oNwFat001:End() },,{{"BMPINCLUIR",{|| MsgRun('Visualizando Pedido','Consulta' ,{|| fVisuPed(cCabAlias,aRotina,2,oSay,cCabTable,oCabTable) })},"Consulta" },;
                         {"BMPINCLUIR",{|| MsgRun('Inclus„o Pedido'    ,'Inclus„o' ,{|| fVisuPed(cCabAlias,aRotina,3,oSay,cCabTable,oCabTable) })},"Inclus„o"},;
                         {"BMPALTERAR",{|| MsgRun('AlteraÁ„o Pedido'   ,'AlteraÁ„o',{|| fVisuPed(cCabAlias,aRotina,4,oSay,cCabTable,oCabTable) })},"AlteraÁ„o"},;
                         {"BMPEXCLUIR",{|| MsgRun('Exclus„o Pedido'    ,'Exclus„o' ,{|| fVisuPed(cCabAlias,aRotina,5,oSay,cCabTable,oCabTable) })},"Exclus„o" },;
                         {"BMPEXCLUIR",{|| MsgRun('Boleto'             ,'Boleto'   ,{|| Boleto(cCabAlias)                                      })},"Boleto"   }},,,,,.F.) CENTERED

If Select(cCabAlias) <> 0 ; (cCabAlias)->(DbCloseArea()) ; EndIf
If Select(cIteAlias) <> 0 ; (cIteAlias)->(DbCloseArea()) ; EndIf

oCabTable:Delete()
//oIteTable:Delete()

Return Nil

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

*************************************************************
Static Function fVldCampo(cCabAlias,oSay,cCabTable,oCabTable)
*************************************************************

Local   lRetorno  As Logical
Local   cConteudo As Character
Local   cCampo    As Character
Local   cAliPed   As Character
Local   cVar      As Character

Local   cSeek     As Character
Local   bWhile    As Array
Local   cQuery    As Character
Local   bCond     As Array
Local   bAction1  As Array
Local   bAction2  As Array
Local   aNoFields As Array
Local   aArea     As Array
Local   aSC5Area  As Array
Local   aSC6Area  As Array
Local   cArqQry   As Array

Local   cCodMar   As Character
Local   cModVei   As Character
Local   cSegMod   As Character
Local   nValTab   As Numeric
Local   nValPre   As Numeric
Local   cRetTES   As Character

Private N         As Numeric
Private aHeader	  As Array
Private oGrade    As Object
Private Altera    As Logical
Private Inclui    As Logiscal

cConteudo := &( ReadVar())
cCampo    := ReadVar()

If Upper(Alltrim(cCampo)) == "C5_CONDPAG"
    SE4->(DbSetOrder(1)) ; lRetorno := SE4->(DbSeek(xFilial("SE4")+cConteudo                                                                      ))
ElseIf Upper(Alltrim(cCampo)) == "C5_NATUREZ"
    SED->(DbSetOrder(1)) ; lRetorno := SED->(DbSeek(xFilial("SED")+cConteudo                                                                      ))
ElseIf Upper(Alltrim(cCampo)) == "C6_OPER"
    lRetorno := ExistCpo("SX5","DJ"+cConteudo)
    If lRetorno
        cRetTES := ""
        cRetTES := MaTesInt(2,cConteudo, (cCabAlias)->C5_CLIENTE, (cCabAlias)->C5_LOJACLI,"C", (cCabAlias)->C6_PRODUTO)
        If Empty(Alltrim(cRetTES))
            Help("",1,"N„o foi encontrado TES para o tipo de operaÁ„o informado.",,"Pedido n„o ser· alterado.",1,0)
            lRetorno := .F.
        Else
            (cCabAlias)->(RecLock(cCabAlias),.F.)
            (cCabAlias)->C6_OPER := cConteudo
            (cCabAlias)->C6_TES  := cRetTES
            (cCabAlias)->(MsUnLock())
        EndIf
    EndIf
ElseIf Upper(Alltrim(cCampo)) == "C6_TES"
    SF4->(DbSetOrder(1)) ; lRetorno := SF4->(DbSeek(xFilial("SF4")+cConteudo                                                                      ))    
ElseIf Upper(Alltrim(cCampo)) == "C6_NUMSERI"
    SBF->(DbSetOrder(1)) ; lRetorno := SBF->(DbSeek(xFilial("SBF")+(cCabAlias)->C6_LOCAL+(cCabAlias)->C6_LOCALIZ+(cCabAlias)->C6_PRODUTO+cConteudo))
    If lRetorno .And. SaldoSBF(.F.,"SBF",.F.,.F.,.F.) <= 0
        Help(" ",1,"SALDOLOCLZ")
        lRetorno := .F.
    EndIf
ElseIf Upper(Alltrim(cCampo)) == "C6_XVLRPRD"
    cCodMar := (cCabAlias)->C6_XCODMAR
    cModVei := (cCabAlias)->C6_XMODVEI
    cSegMod := (cCabAlias)->C6_XSEGMOD
    nValTab := (cCabAlias)->C6_XPRCTAB
    nValPre := &( ReadVar())

    VlrPret(cCodMar, cModVei, cSegMod, nValTab, nValPre,cCabAlias)
    lRetorno := .T.
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
                        {"C6_QTDLIB",NIL,NIL},;
                        {"C6_QTDENT",NIL,NIL},;
                        {"C6_ITEM"	,NIL,NIL},;
                        {"C6_OPC"	,NIL,NIL},;
                        {"C6_BLQ"	,NIL,NIL},;
                        {"C6_NUMOP" ,NIL,NIL},;
                        {"C6_ITEMOP",NIL,NIL},;
                        {"C6_UNSVEN",NIL, {{"C6_QTDVEN",{|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),0,aCols[nLinha][nColuna],1) }}} };
                        })
    SC5->(DbSetOrder(1))
    SC5->(DbSeek(xFilial("SC5")+(cCabAlias)->C6_NUM))
    RegToMemory( "SC5", .F., .F. )

    DbSelectArea("SC6")
    DbSetOrder(1)
    cQuery := "SELECT * "
    cQuery += "FROM "+RetSqlName("SC6")+" SC6 "
    cQuery += "WHERE SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
    cQuery += "SC6.C6_NUM   ='"+(cCabAlias)->C6_NUM +"' AND "
    cQuery += "SC6.C6_ITEM  ='"+(cCabAlias)->C6_ITEM+"' AND "
    cQuery += "SC6.D_E_L_E_T_ = ' ' "
    cQuery += "ORDER BY "+SqlOrder(SC6->(IndexKey()))

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

Return(lRetorno)

*************************************************************************
Static Function fVisuPed(cCabAlias,aRotina,nOpc,oSay,cCabTable,oCabTable)
*************************************************************************

Local aArea       As Array
Local aRotina2    As Array
Local aRotina3    As Array
Local lRetorno    As Logical
Local nRecno      As numeric
Local nY          As numeric
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
cCadastro := "AtualizaÁ„o de Pedidos de Venda"
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
			{OemToAnsi("Prep.Doc.SaÌda"  ),"Ma410PvNfs"	                                                      ,0,2,0 ,NIL},;//"Prep.Doc.SaÌda"
			{OemToAnsi("Tracker Cont·bil"),"CTBC662"                                                          ,0,7,0 ,Nil},;//"Tracker Cont·bil"
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
            cQuery += " INSERT INTO "+cCabTable+"                                                                                    "+(Chr(13)+Chr(10))
            cQuery += " ("
            For nY := 1 To Len(aCabCampos)
                If Upper(Alltrim(aCabCampos[nY])) <> "C9_SEQUEN"  .And.;
                Upper(Alltrim(aCabCampos[nY])) <> "C9_NFISCAL" .And.;
                Upper(Alltrim(aCabCampos[nY])) <> "C9_SERIENF" .And.;
                Upper(Alltrim(aCabCampos[nY])) <> "C5_XMENSER"
                cQuery += aCabCampos[nY]+","
                EndIf
            Next
            cQuery += " D_E_L_E_T_,R_E_C_N_O_)                                                                                       "+(Chr(13)+Chr(10))
            cQuery += " SELECT '  ' C6_OK    ,                                                                                       "+(Chr(13)+Chr(10))
            cQuery += " ' '         C6_STATUS,                                                                                       "+(Chr(13)+Chr(10))
            For nY := 1 To Len(aCabCampos)
                If  Upper(Alltrim(aCabCampos[nY])) <> "C6_OK"      .And.;
                    Upper(Alltrim(aCabCampos[nY])) <> "CC_STATUS"  .And.;
                    Upper(Alltrim(aCabCampos[nY])) <> "C9_SEQUEN"  .And.;
                    Upper(Alltrim(aCabCampos[nY])) <> "C9_NFISCAL" .And.;
                    Upper(Alltrim(aCabCampos[nY])) <> "C9_SERIENF" .And.;
                    Upper(Alltrim(aCabCampos[nY])) <> "C5_XMENSER"
                    If Left(aCabCampos[nY],3) == "C6_" ; cQryAlias := "SC6." ; EndIf
                    If Left(aCabCampos[nY],3) == "C5_" ; cQryAlias := "SC5." ; EndIf
                    If Left(aCabCampos[nY],3) == "A1_" ; cQryAlias := "SA1." ; EndIf
                    If Left(aCabCampos[nY],3) == "B1_" ; cQryAlias := "SB1." ; EndIf
                    If Left(aCabCampos[nY],3) == "F4_" ; cQryAlias := "SF4." ; EndIf
                    cQuery += " "+(cQryAlias+aCabCampos[nY])+",                                                                       "+(Chr(13)+Chr(10))"
                EndIf
            Next
            cQuery += "        ' '                                                                                      D_E_L_E_T_  , "+(Chr(13)+Chr(10))
            cQuery += "        ROW_NUMBER() OVER (ORDER BY SC6.C6_FILIAL,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC6.C6_PRODUTO)  R_E_C_N_O_    "+(Chr(13)+Chr(10))
            cQuery += " FROM "+RetSqlName("SC6")+" SC6                                                                                "+(Chr(13)+Chr(10))
            cQuery += "      INNER JOIN                                                                                               "+(Chr(13)+Chr(10))
            cQuery += "      "+RetSqlName("SC5")+" SC5 ON   SC6.C6_FILIAL   = SC5.C5_FILIAL                                           "+(Chr(13)+Chr(10))
            cQuery += "                                 AND SC6.C6_NUM      = SC5.C5_NUM                                              "+(Chr(13)+Chr(10))
            cQuery += "                                 AND SC6.D_E_L_E_T_  = SC5.D_E_L_E_T_                                          "+(Chr(13)+Chr(10))
            cQuery += "      INNER JOIN                                                                                               "+(Chr(13)+Chr(10))
            cQuery += "      "+RetSqlName("SA1")+" SA1 ON   SC5.C5_CLIENTE  = SA1.A1_COD                                              "+(Chr(13)+Chr(10))
            cQuery += "                                 AND SC5.C5_LOJACLI  = SA1.A1_LOJA                                             "+(Chr(13)+Chr(10))
            cQuery += "                                 AND SC5.D_E_L_E_T_  = SA1.D_E_L_E_T_                                          "+(Chr(13)+Chr(10))
            cQuery += "      INNER JOIN                                                                                               "+(Chr(13)+Chr(10))
            cQuery += "      "+RetSqlName("SB1")+" SB1 ON   SC6.C6_PRODUTO  = SB1.B1_COD                                              "+(Chr(13)+Chr(10))
            cQuery += "                                 AND SC6.D_E_L_E_T_  = SB1.D_E_L_E_T_                                          "+(Chr(13)+Chr(10))
            cQuery += "      INNER JOIN                                                                                               "+(Chr(13)+Chr(10))
            cQuery += "      "+RetSqlName("SF4")+" SF4 ON   SC6.C6_TES      = SF4.F4_CODIGO                                           "+(Chr(13)+Chr(10))
            cQuery += "                                 AND SC6.D_E_L_E_T_  = SF4.D_E_L_E_T_                                          "+(Chr(13)+Chr(10))
            cQuery += " WHERE   SC6.C6_FILIAL           = '"+xFilial("SC6")+"'                                                        "+(Chr(13)+Chr(10))
            cQuery += "     AND SC5.C5_NUM              = '"+SC5->C5_NUM   +"'                                                        "+(Chr(13)+Chr(10))
            cQuery += "     AND SC5.C5_TIPO             = 'N'                                                                         "+(Chr(13)+Chr(10))
            cQuery += "     AND SC6.C6_QTDVEN           > SC6.C6_QTDENT                                                               "+(Chr(13)+Chr(10))
            cQuery += "     AND SC6.C6_NOTA             = ' '                                                                         "+(Chr(13)+Chr(10))
            cQuery += "     AND SC6.C6_BLQ              = ' '                                                                         "+(Chr(13)+Chr(10))
            cQuery += "     AND SB1.B1_GRUPO            = 'VEIA'                                                                      "+(Chr(13)+Chr(10))
            cQuery += "     AND SF4.F4_DUPLIC           = 'S'                                                                         "+(Chr(13)+Chr(10))
            cQuery += " 	AND SC6.D_E_L_E_T_			= ' '                                                                         "+(Chr(13)+Chr(10))
            cQuery += " ORDER BY SC6.C6_FILIAL,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC6.C6_PRODUTO                                           "+(Chr(13)+Chr(10))
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
        If FWAlertYesNo("O pedido est· liberado para faturamento. Deseja continuar?", "Exclus„o de Pedido")
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
                Aadd(aLinha,{"LINPOS"    ,"C6_ITEM"              ,SC6->C6_ITEM});Aadd(aLinha,{"AUTDELETA" ,"N"                    ,Nil         })
                Aadd(aLinha,{"C6_PRODUTO",SC6->C6_PRODUTO        ,Nil         });Aadd(aLinha,{"C6_QTDVEN" ,SC6->C6_QTDVEN         ,Nil         })
                Aadd(aLinha,{"C6_PRCVEN" ,SC6->C6_PRCVEN         ,Nil         });Aadd(aLinha,{"C6_VALOR"  ,SC6->C6_VALOR          ,Nil         })
                Aadd(aLinha,{"C6_PRUNIT" ,SC6->C6_PRUNIT         ,Nil         });Aadd(aLinha,{"C6_TES"    ,SC6->C6_TES            ,Nil         })
                Aadd(aLinha,{"C6_QTDLIB" ,0                      ,Nil         });Aadd(aLinha,{"C6_CHASSI" ,CriaVar("C6_CHASSI" )  ,Nil         })
                Aadd(aLinha,{"C6_LOCALIZ",CriaVar("C6_LOCALIZ")  ,Nil         });Aadd(aLinha,{"C6_NUMSERI",CriaVar("C6_NUMSERI")  ,Nil         })
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
                    (cCabAlias)->(RecLock(cCabAlias,.F.))
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

****************************************************************************
Static Function fAtuPeds(cCabAlias,oSay,cCabTable,oCabTable,cNumPed,cChassi)
****************************************************************************

Local aArea         As Array
Local cQuery        As Character
Local cTmpAlias     As Character
Local aCampos       As Array
Local nY            As Numeric
Local aCabPed       As Array
Local aItePed       As Array
Local aLinha        As Array
Local n_RecnoSc6    As Numeric
Local nQtdLib       As Numeric
Local lLibPed       As Logical
Local nStatus       As Numeric
Local nRecno        As Numeric
Local cTrbAlias     As Character
Local cNumSerie     As Character
Local lRetorno      As Logical
Local cConteudo     As Character
Local nPosicao      As Numeric

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

    cNumSerie := ""
    SC5->(DbSetOrder(1))        
    SC5->(DbSeek(xFilial("SC5")+(cCabAlias)->C6_NUM))
    
    SC6->(DbSetOrder(1))        
    SC6->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))
    If !Empty(Alltrim(cNumPed))
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
            Next

            SC6->(DbSetOrder(1))        
            SC6->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))

            aItePed := {}
            aLinha  := {}

            Aadd(aLinha,{"LINPOS"    ,"C6_ITEM"              ,SC6->C6_ITEM});Aadd(aLinha,{"AUTDELETA" ,"N"                    ,Nil         })
            Aadd(aLinha,{"C6_PRODUTO",SC6->C6_PRODUTO        ,Nil         });Aadd(aLinha,{"C6_QTDVEN" ,SC6->C6_QTDVEN         ,Nil         })
            Aadd(aLinha,{"C6_PRCVEN" ,(cCabAlias)->C6_PRCVEN ,Nil         });Aadd(aLinha,{"C6_VALOR"  ,(cCabAlias)->C6_VALOR  ,Nil         })
            Aadd(aLinha,{"C6_PRUNIT" ,SC6->C6_PRUNIT         ,Nil         });Aadd(aLinha,{"C6_OPER"   ,(cCabAlias)->C6_OPER   ,Nil         })
            Aadd(aLinha,{"C6_TES"    ,(cCabAlias)->C6_TES    ,Nil         });Aadd(aLinha,{"C6_QTDLIB" ,0                      ,Nil         })
            Aadd(aLinha,{"C6_CHASSI" ,CriaVar("C6_CHASSI" )  ,Nil         });Aadd(aLinha,{"C6_LOCALIZ",CriaVar("C6_LOCALIZ")  ,Nil         })
            Aadd(aLinha,{"C6_NUMSERI",CriaVar("C6_NUMSERI")  ,Nil         });Aadd(aLinha,{"C6_XVLRMVT",(cCabAlias)->C6_XVLRMVT,Nil         })
            Aadd(aLinha,{"C6_XVLRVDA",(cCabAlias)->C6_XVLRVDA,Nil         });Aadd(aLinha,{"C6_XVLRPRD",(cCabAlias)->C6_XVLRVDA,Nil         })
            Aadd(aItePed, aLinha)
            
            lMsHelpAuto := .T.
            lMsErroAuto := .F.
            MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabPed, aItePed, nOPc, .F.)
            If lMsErroAuto
                MostraErro()
                lRetorno := .F.
                //DisarmTransaction()
            Else
                DBCommitAll()
            EndIf
        //End Transaction
    Else
        (cCabAlias)->(RecLock(cCabAlias,.F.))
        (cCabAlias)->C5_XMENSER := If(!Empty(Alltrim(SC5->C5_XMENSER)),SC5->C5_XMENSER,Space(8000))
        (cCabAlias)->(MsUnLock())        
    EndIf

    If !Empty(Alltrim(SC6->C6_NUMSERI)) .And.;
       !Empty(Alltrim(SC6->C6_CHASSI )) .And.;
       !Empty(Alltrim(SC6->C6_LOCALIZ))
        SDC->(DbSetOrder(3))
        If SDC->(DbSeek(xFilial("SDC")+SC6->C6_PRODUTO+SC6->C6_LOCAL+SC6->C6_LOTECTL+SC6->C6_NUMLOTE+SC6->C6_LOCALIZ+SC6->C6_NUMSERI+"SC6"))
            (cCabAlias)->(RecLock(cCabAlias,.F.))
            (cCabAlias)->C9_SEQUEN  := SDC->DC_SEQ
            (cCabAlias)->(MsUnLock())
        EndIf

        (cCabAlias)->(DbSkip())
        Loop
    EndIf
 
    cQuery := ""
    cQuery += " SELECT A.*                                                                  "+(Chr(13)+Chr(10))
    cQuery += " FROM (                                                                      "+(Chr(13)+Chr(10))
    cQuery += " SELECT                                                                      "+(Chr(13)+Chr(10))
    For nY := 1 To Len(aCampos)
        cQuery += aCampos[nY]+"                                                             "+(Chr(13)+Chr(10))  
    Next
    cQuery += "         (SELECT MAX(SDB.DB_NUMSEQ)                                          "+(Chr(13)+Chr(10))
    cQuery += "          FROM "+RetSqlName("SDB")+" SDB                                     "+(Chr(13)+Chr(10))
    cQuery += "          WHERE  SDB.DB_FILIAL       = '"+xFilial("SDB")+"'                  "+(Chr(13)+Chr(10))
    cQuery += "             AND SDB.DB_ESTORNO      = ' '                                   "+(Chr(13)+Chr(10))
    cQuery += "             AND SDB.DB_ATUEST       = 'S'                                   "+(Chr(13)+Chr(10))
    cQuery += "             AND SDB.DB_LOCAL        = SBF.BF_LOCAL                          "+(Chr(13)+Chr(10))
    cQuery += "             AND SDB.DB_LOCALIZ      = SBF.BF_LOCALIZ                        "+(Chr(13)+Chr(10))
    cQuery += "             AND SDB.DB_NUMSERI      = SBF.BF_NUMSERI                        "+(Chr(13)+Chr(10))
    cQuery += "             AND SDB.DB_PRODUTO      = SBF.BF_PRODUTO                        "+(Chr(13)+Chr(10))
    cQuery += "             AND SDB.D_E_L_E_T_      = ' ') DB_NUMSEQ                        "+(Chr(13)+Chr(10))
    cQuery += " FROM "+RetSqlName("VV1")+" VV1                                              "+(Chr(13)+Chr(10))
    cQuery += "         INNER JOIN                                                          "+(Chr(13)+Chr(10))
    cQuery += "      "+RetSqlName("SBF")+" SBF ON '"+xFilial("SBF")+"'  = SBF.BF_FILIAL     "+(Chr(13)+Chr(10))
    cQuery += "                                 AND VV1.VV1_CHASSI      = SBF.BF_NUMSERI    "+(Chr(13)+Chr(10))
    cQuery += "                                 AND VV1.D_E_L_E_T_      = SBF.D_E_L_E_T_    "+(Chr(13)+Chr(10))
    cQuery += " WHERE   VV1.VV1_FILIAL      = '"+xFilial("VV1")+"'                          "+(Chr(13)+Chr(10))
    cQuery += "     AND VV1.VV1_SITVEI      = '0'                                           "+(Chr(13)+Chr(10))
    cQuery += "     AND SBF.BF_QUANT        > 0                                             "+(Chr(13)+Chr(10))
    cQuery += "     AND SBF.BF_EMPENHO      = 0                                             "+(Chr(13)+Chr(10))
    cQuery += "     AND SBF.BF_PRODUTO      = '"+(cCabAlias)->C6_PRODUTO+"'                 "+(Chr(13)+Chr(10))
    cQuery += "     AND SBF.BF_LOCAL        = '"+(cCabAlias)->C6_LOCAL  +"'                 "+(Chr(13)+Chr(10))
    If !Empty(Alltrim(cNumSerie))
        cQuery += " AND SBF.BF_NUMSERI      = '"+cNumSerie              +"'                 "+(Chr(13)+Chr(10))
    EndIf
    cQuery += "     AND VV1.D_E_L_E_T_      = ' ') A                                        "+(Chr(13)+Chr(10))
    cQuery += " ORDER BY A.VV1_FILIAL,A.BF_PRODUTO,A.DB_NUMSEQ,A.VV1_CHASSI                 "+(Chr(13)+Chr(10))
    
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
                cQuery += " SELECT  VV1.VV1_FILIAL          AS FILIAL       ,                               "+(Chr(13)+Chr(10))
                cQuery += "         VV1.VV1_CHASSI          AS CHASSI       ,                               "+(Chr(13)+Chr(10))
                cQuery += "         VV1.VV1_CHAINT          AS CHASSIINT    ,                               "+(Chr(13)+Chr(10))
                cQuery += "         VV1.VV1_MODVEI          AS MODVEI       ,                               "+(Chr(13)+Chr(10))
                cQuery += "         TRIM(VV2.VV2_DESMOD)    AS DESCMOD      ,                               "+(Chr(13)+Chr(10))
                cQuery += "         VV1.VV1_CODMAR          AS MARCA        ,                               "+(Chr(13)+Chr(10))
                cQuery += "         TRIM(VE1.VE1_DESMAR)    AS DESCMAR      ,                               "+(Chr(13)+Chr(10))
                cQuery += "         VV1.VV1_SEGMOD          AS SEGMOD       ,                               "+(Chr(13)+Chr(10))
                cQuery += "         TRIM(VVX.VVX_DESSEG)    AS DESCSEG      ,                               "+(Chr(13)+Chr(10))
                cQuery += "         VV1.VV1_FABMOD          AS FABMOD       ,                               "+(Chr(13)+Chr(10))
                cQuery += "         VV2.VV2_COREXT          AS COREXT       ,                               "+(Chr(13)+Chr(10))
                cQuery += "         TRIM(VX1.VX5_DESCRI)    AS DESCEXT      ,                               "+(Chr(13)+Chr(10))
                cQuery += "         VV2.VV2_CORINT          AS CORINT       ,                               "+(Chr(13)+Chr(10))
                cQuery += "         TRIM(VX2.VX5_DESCRI)    AS DESCINT                                      "+(Chr(13)+Chr(10))
                cQuery += " FROM    "+RetSqlName("VV1")+" VV1                                               "+(Chr(13)+Chr(10))
                cQuery += "         INNER JOIN                                                              "+(Chr(13)+Chr(10))
                cQuery += "         "+RetSqlName("VV2")+" VV2  ON   '"+xFilial("VV2")+"' = VV2.VV2_FILIAL   "+(Chr(13)+Chr(10))
                cQuery += "                                     AND VV1.VV1_CODMAR       = VV2.VV2_CODMAR   "+(Chr(13)+Chr(10))
                cQuery += "                                     AND VV1.VV1_MODVEI       = VV2.VV2_MODVEI   "+(Chr(13)+Chr(10))
                cQuery += "                                     AND VV1.VV1_SEGMOD       = VV2.VV2_SEGMOD   "+(Chr(13)+Chr(10))
                cQuery += "                                     AND VV1.D_E_L_E_T_       = VV2.D_E_L_E_T_   "+(Chr(13)+Chr(10))
                cQuery += "         LEFT JOIN                                                               "+(Chr(13)+Chr(10))
                cQuery += "         "+RetSqlName("VX5")+" VX1 ON    '"+xFilial("VX5")+"' = VX1.VX5_FILIAL   "+(Chr(13)+Chr(10))
                cQuery += "                                     AND '067'                = VX1.VX5_CHAVE    "+(Chr(13)+Chr(10))
                cQuery += "                                     AND VV2.VV2_COREXT       = VX1.VX5_CODIGO   "+(Chr(13)+Chr(10))
                cQuery += "                                     AND VV1.D_E_L_E_T_       = VX1.D_E_L_E_T_   "+(Chr(13)+Chr(10))
                cQuery += "         LEFT JOIN                                                               "+(Chr(13)+Chr(10))
                cQuery += "         "+RetSqlName("VX5")+" VX2 ON    '"+xFilial("VX5")+"' = VX2.VX5_FILIAL   "+(Chr(13)+Chr(10))
                cQuery += "                                     AND '066'                = VX2.VX5_CHAVE    "+(Chr(13)+Chr(10))
                cQuery += "                                     AND VV2.VV2_CORINT       = VX2.VX5_CODIGO   "+(Chr(13)+Chr(10))
                cQuery += "                                     AND VV1.D_E_L_E_T_       = VX2.D_E_L_E_T_   "+(Chr(13)+Chr(10))
                cQuery += "         LEFT JOIN                                                               "+(Chr(13)+Chr(10))
                cQuery += "         "+RetSqlName("VE1")+" VE1  ON  '"+xFilial("VE1")+"'  = VE1.VE1_FILIAL   "+(Chr(13)+Chr(10))
                cQuery += "                                    AND VV1.VV1_CODMAR        = VE1.VE1_CODMAR   "+(Chr(13)+Chr(10))
                cQuery += "                                    AND VV1.D_E_L_E_T_        = VE1.D_E_L_E_T_   "+(Chr(13)+Chr(10))
                cQuery += "         LEFT JOIN                                                               "+(Chr(13)+Chr(10))
                cQuery += "         "+RetSqlName("VVX")+" VVX  ON  '"+xFilial("VVX")+"'  = VVX.VVX_FILIAL   "+(Chr(13)+Chr(10))
                cQuery += "                                    AND VV1.VV1_CODMAR        = VVX.VVX_CODMAR   "+(Chr(13)+Chr(10))
                cQuery += "                                    AND VV1_SEGMOD            = VVX.VVX_SEGMOD   "+(Chr(13)+Chr(10))
                cQuery += "                                    AND VV1.D_E_L_E_T_        = VVX.D_E_L_E_T_   "+(Chr(13)+Chr(10))
                cQuery += " WHERE   VV1.VV1_FILIAL          = '"+xFilial("VV1")+"'                          "+(Chr(13)+Chr(10))
                cQuery += "     AND VV1.VV1_CHASSI          = '"+Alltrim((cTmpAlias)->VV1_CHASSI)+"'        "+(Chr(13)+Chr(10))
                cQuery += "     AND VV1.D_E_L_E_T_          = ' '                                           "+(Chr(13)+Chr(10))
                If Select(cTrbAlias) <> 0 ; (cTrbAlias)->(DbCloseArea()) ; EndIf
                DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTrbAlias, .F., .T. )

                lLibPed  := .T.
                (cCabAlias)->(RecLock(cCabAlias,.F.))
                If Empty(Alltrim(SC9->C9_BLCRED)) .And.;
                   Empty(Alltrim(SC9->C9_BLEST )) .And.;
                   Empty(Alltrim(SC9->C9_BLWMS ))
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
            
                (cCabAlias)->C6_CHASSI  := (cTmpAlias)->VV1_CHASSI ; (cCabAlias)->C6_NUMSERI := (cTmpAlias)->VV1_CHASSI
                (cCabAlias)->C6_LOCALIZ := (cTmpAlias)->BF_LOCALIZ ; (cCabAlias)->C9_SEQUEN  := SC9->C9_SEQUEN
		        (cCabAlias)->C6_XCODMAR	:= (cTrbAlias)->MARCA      ; (cCabAlias)->C6_XDESMAR := (cTrbAlias)->DESCMAR 
                (cCabAlias)->C6_XCORINT	:= (cTrbAlias)->CORINT     ; (cCabAlias)->C6_XCOREXT := (cTrbAlias)->COREXT 
                (cCabAlias)->C6_XMODVEI := (cTrbAlias)->MODVEI     ; (cCabAlias)->C6_XDESMOD := (cTrbAlias)->DESCMOD
		        (cCabAlias)->C6_XSEGMOD	:= (cTrbAlias)->SEGMOD     ; (cCabAlias)->C6_XDESSEG := (cTrbAlias)->DESCSEG
                (cCabAlias)->C6_XFABMOD	:= (cTrbAlias)->FABMOD     ; (cCabAlias)->C6_XGRPMOD := ""
                (cCabAlias)->C6_XDGRMOD := ""                      ; (cCabAlias)->C9_NFISCAL := CriaVar("C9_NFISCAL")
                (cCabAlias)->C9_SERIENF := CriaVar("C9_SERIENF")
                (cCabAlias)->(MsUnLock())

                SC6->(RecLock("SC6",.F.))
		        SC6->C6_XCODMAR	:= (cTrbAlias)->MARCA   ; SC6->C6_XDESMAR	:= (cTrbAlias)->DESCMAR ; SC6->C6_XCORINT	:= (cTrbAlias)->CORINT
                SC6->C6_XCOREXT	:= (cTrbAlias)->COREXT  ; SC6->C6_XMODVEI	:= (cTrbAlias)->MODVEI  ; SC6->C6_XDESMOD	:= (cTrbAlias)->DESCMOD
		        SC6->C6_XSEGMOD	:= (cTrbAlias)->SEGMOD  ; SC6->C6_XDESSEG	:= (cTrbAlias)->DESCSEG ; SC6->C6_XFABMOD	:= (cTrbAlias)->FABMOD
                SC6->C6_XGRPMOD	:= ""                   ; SC6->C6_XDGRMOD	:= ""
                SC6->(MsUnLock())

                SC9->(RecLock("SC9",.F.))
                SC9->C9_XCODMAR := (cTrbAlias)->MARCA   ; SC9->C9_XMODVEI := (cTrbAlias)->MODVEI ; SC9->C9_XSEGMOD := (cTrbAlias)->SEGMOD
                SC9->C9_XFABMOD := (cTrbAlias)->FABMOD  ; SC9->C9_XCORINT := (cTrbAlias)->CORINT ; SC9->C9_XCOREXT := (cTrbAlias)->COREXT
                SC9->C9_XGRPMOD := ""
                SC6->(MsUnLock())

                DBCommitAll()
            Else
                //DisarmTransaction()
            EndIf
        //End Transaction
    EndIf

    If !lLibPed
        SC6->(RecLock("SC6",.F.))
        SC6->C6_LOTECTL := CriaVar("C6_LOTECTL") ; SC6->C6_DTVALID  := CriaVar("C6_DTVALID") ; SC6->C6_NUMSERI  := CriaVar("C6_NUMSERI")
        SC6->C6_CHASSI  := CriaVar("C6_CHASSI" ) ; SC6->C6_LOCALIZ  := CriaVar("C6_LOCALIZ") ; SC6->C6_XCODMAR  := CriaVar("C6_XCODMAR")
		SC6->C6_XDESMAR	:= CriaVar("C6_XDESMAR") ; SC6->C6_XGRPMOD  := CriaVar("C6_XGRPMOD") ; SC6->C6_XDGRMOD  := CriaVar("C6_XDGRMOD")
		SC6->C6_XMODVEI	:= CriaVar("C6_XMODVEI") ; SC6->C6_XDESMOD	:= CriaVar("C6_XDESMOD") ; SC6->C6_XSEGMOD	:= CriaVar("C6_XSEGMOD")
		SC6->C6_XDESSEG	:= CriaVar("C6_XDESSEG") ; SC6->C6_XFABMOD	:= CriaVar("C6_XFABMOD") ; SC6->C6_XCORINT	:= CriaVar("C6_XCORINT")
		SC6->C6_XCOREXT	:= CriaVar("C6_XCOREXT")
        SC6->(MsUnLock())

        (cCabAlias)->(RecLock(cCabAlias,.F.))
        (cCabAlias)->C6_CHASSI  := CriaVar("C6_CHASSI" )
        (cCabAlias)->C6_NUMSERI := CriaVar("C6_NUMSERI")
        (cCabAlias)->C6_LOCALIZ := CriaVar("C6_LOCALIZ")
        (cCabAlias)->(MsUnLock())
         DBCommitAll()
    EndIf

    (cCabAlias)->(DbSkip())
End

SC6->(DbSetOrder(1))
(cCabAlias)->(DbGoTop())
While (cCabAlias)->(!Eof())
    nRecno := (cCabAlias)->(Recno())    
    If Empty(Alltrim((cCabAlias)->C6_CHASSI)) .Or. Empty(Alltrim((cCabAlias)->C6_NUMSERI))        
        SC6->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))
        SC6->(RecLock("SC6",.F.))
        SC6->C6_LOTECTL := CriaVar("C6_LOTECTL") ; SC6->C6_DTVALID  := CriaVar("C6_DTVALID") ; SC6->C6_NUMSERI  := CriaVar("C6_NUMSERI")
        SC6->C6_CHASSI  := CriaVar("C6_CHASSI" ) ; SC6->C6_LOCALIZ  := CriaVar("C6_LOCALIZ") ; SC6->C6_XCODMAR  := CriaVar("C6_XCODMAR")
		SC6->C6_XDESMAR	:= CriaVar("C6_XDESMAR") ; SC6->C6_XGRPMOD  := CriaVar("C6_XGRPMOD") ; SC6->C6_XDGRMOD  := CriaVar("C6_XDGRMOD")
		SC6->C6_XMODVEI	:= CriaVar("C6_XMODVEI") ; SC6->C6_XDESMOD	:= CriaVar("C6_XDESMOD") ; SC6->C6_XSEGMOD	:= CriaVar("C6_XSEGMOD")
		SC6->C6_XDESSEG	:= CriaVar("C6_XDESSEG") ; SC6->C6_XFABMOD	:= CriaVar("C6_XFABMOD") ; SC6->C6_XCORINT	:= CriaVar("C6_XCORINT")
		SC6->C6_XCOREXT	:= CriaVar("C6_XCOREXT")
        SC6->(MsUnLock())

        (cCabAlias)->(RecLock(cCabAlias,.F.))
        (cCabAlias)->(DBDelete())
        (cCabAlias)->(MsUnLock())
    EndIf

    (cCabAlias)->(DbGoTo(nRecno))
    (cCabAlias)->(DbSkip())
End

If !Empty(Alltrim(cNumPed))
    (cCabAlias)->(DBClearFilter())
EndIf

If ValType(oBrwCab) <> "U"
    nAt     := oBrwCab:nAt
    nLinPos := nAt
    oBrwCab:GoTop(.T.)
    oBrwCab:LineRefresh(nAt)
    oBrwCab:GoTop(.T.)
    oBrwCab:Refresh()
    /*
	oBrwCab:GoTo(nAt)
	oBrwCab:LineRefresh() //sÛ refaz a linha
    oBrwCab:GoTop(.T.)
    oBrwCab:UpdateBrowse() //reconstroi tudo	
    oBrwCab:Refresh()
    oBrwCab:GoTo(nAt)
    oBrwCab:Refresh()
    oNwFat001:Refresh()
    */
EndIf
TcRefresh(oCabTable:GetTableNameForQuery())

(cCabAlias)->(DbGoTop())

Return()

*************************************************************
Static Function fGeraDocs(cCabAlias,cIteAlias,oSay,cIteTable)
*************************************************************

Local   aTmpPVl     As Array
Local   aPVlNFs     As Array
Local   lUsaNewKey  As Logical
Local   lContinua   As Logical
Local   cSerieId    As Character
Local   aDadosDoc   As Array

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

lContinua := Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS"),,,,@cSerieId,dDataBase ) // O parametro cSerieId deve ser passado para funcao Sx5NumNota afim de tratar a existencia ou nao do mesmo numero na funcao VldSx5Num do MATXFUNA.PRX
(cCabAlias)->(DbGotop())
While (cCabAlias)->(!Eof()) .And. lContinua

    oSay:SetText("Faturando pedido: " + (cCabAlias)->C6_NUM+" ...")

    If !Empty(Alltrim((cCabAlias)->C6_OK))
        SC5->(DbSetOrder(RetOrder("SC5","C5_FILIAL+C5_NUM"                    )))
        If SC5->(DbSeek(xFilial("SC5")+(cCabAlias)->C6_NUM))
            SC6->(DbSetOrder(RetOrder("SC6","C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO" )))
            If SC6->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM))
                SC9->(DbSetOrder(1))
                If SC9->(DbSeek(xFilial("SC6")+(cCabAlias)->C6_NUM+(cCabAlias)->C6_ITEM+(cCabAlias)->C9_SEQUEN)) .And. ;
                    Empty(Alltrim(SC9->C9_BLEST  ))                                                              .And. ;
                    Empty(Alltrim(SC9->C9_BLCRED ))                                                              .And. ;
                    Empty(Alltrim(SC9->C9_NFISCAL))

                    SB1->(DbSetOrder(1)) ; SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO              ))
                    SB2->(DbSetOrder(2)) ; SB2->(DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL))
                    SE4->(DbSetOrder(1)) ; SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG              ))
                    SF4->(DbSetOrder(1)) ; SF4->(DbSeek(xFilial("SF4")+(cCabAlias)->C6_TES          ))
                    
                    aTmpPVl   := {}
	                aPVlNFs   := {}
                  //lContinua := Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS"),,,,@cSerieId,dDataBase ) // O parametro cSerieId deve ser passado para funcao Sx5NumNota afim de tratar a existencia ou nao do mesmo numero na funcao VldSx5Num do MATXFUNA.PRX
                    cNotaSer  := Criavar("F2_DOC"  )

                    If !lContinua
                        Return()
                    EndIf

            	    Aadd( aTmpPVl , SC9->C9_PEDIDO  ) ; Aadd( aTmpPVl , SC9->C9_ITEM    ) ; Aadd( aTmpPVl , SC9->C9_SEQUEN  )
	                Aadd( aTmpPVl , SC9->C9_QTDLIB  ) ; Aadd( aTmpPVl , SC9->C9_PRCVEN  ) ; Aadd( aTmpPVl , SC9->C9_PRODUTO )
	                Aadd( aTmpPVl , SF4->F4_ISS=="S") ; Aadd( aTmpPVl , SC9->(RecNo())  ) ; Aadd( aTmpPVl , SC5->(Recno())  )
	                Aadd( aTmpPVl , SC6->(Recno())  ) ; Aadd( aTmpPVl , SE4->(Recno())  ) ; Aadd( aTmpPVl , SB1->(Recno())  )
	                Aadd( aTmpPVl , SB2->(Recno())  ) ; Aadd( aTmpPVl , SF4->(Recno())  ) ; Aadd( aTmpPVl , SC9->C9_LOCAL   )
	                Aadd( aTmpPVl , 1               ) ; Aadd( aTmpPVl , SC9->C9_QTDLIB2 )
		
	                Aadd( aPVlNFs, aClone(aTmpPVl))
	                ******************************
	                *'Gera nota fiscal de saÌda.'*
	                ******************************
	                cNotaSer  := MAPVLNFS(aPVlNFs,cSerie,.F.,.F.,.F.,.F.,.F.,1,0,.T.,.F.,,,)
                    
                    SF2->(DbSetOrder(1))
					If SF2->(DbSeek(xFilial("SF2")+cNotaSer+cSerie))
                        SA1->(DbSetOrder(1))
                        SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
                        Aadd(aDadosDoc,{SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_EMISSAO,SF2->F2_CLIENTE,SF2->F2_LOJA,SA1->A1_NOME,SF2->F2_VALBRUT,SF2->F2_VALMERC})
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
    (cCabAlias)->(DbSkip())
End

If Len(aDadosDoc) <> 0
    NotaDados(aDadosDoc)
EndIf

Return(Nil)

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

@ aSizeAut[2],aSizeAut[1] LISTBOX oListDocs FIELDS HEADER "Serie","Numero","Data Emiss„o","Cliente","Loja","Nome"/*,"Valor Bruto","Valor Produtos"*/  SIZE aSizeAut[3],aSizeAut[4]-21.5 PIXEL OF oGerNota

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

***************************
Static Function fCanNotas()
***************************

Mata521A()

Return(Nil)

***************************
Static Function fDevNotas()
***************************

Private INCLUI := .T.
Private ALTERA := .F.

U_ZFATF020("SF1",1,3)

Return(Nil)

//------------------------------------------------------------------------------------
/*/{Protheus.doc} FMark
Executa a gravaÁ„o do retorno da Consulta EspecÌfica.
@Param		oBrowse	- Objeto da Browse
			cReadVar	- Campo de retorno da Consulta EspecÌfica
			cChave		- Campo(s) a serem gravados no retorno da Consulta EspecÌfica
			lMult		- Indica se a tela permiÁ„o selec de m˙ltiplos registros
@Version	1.0
/*/
//------------------------------------------------------------------------------------
******************************
Static function FMark(oBrowse)
******************************

Local cAlias	:=	oBrowse:Alias()
Local cMark	    :=	cMarca //oBrowse:Mark()

If RecLock( cAlias, .F. )
    ( cAlias )->C6_OK := Iif( ( cAlias )->C6_OK == cMark, "  ", cMark )
	( cAlias )->( MsUnlock() )
EndIf  

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} FMarkAll
Inverte a indicaÁ„o de seleÁ„o de todos registros do Browse.
@Param		oBrowse	->	Objeto contendo campo de seleÁ„o
@Return	Nil
/*/
//---------------------------------------------------------------------
***********************************
Static Function FMarkAll( oBrowse )
***********************************

Local cAlias	as character
Local cMark	    as character
Local nRecno	as numeric

cAlias	:=	oBrowse:Alias()
cMark	:=	cMarca //oBrowse:Mark()
nRecno	:=	( cAlias )->( Recno() )

( cAlias )->( DBGoTop() )
While ( cAlias )->( !Eof() )
	If RecLock( cAlias, .F. )
		( cAlias )->C6_OK := Iif( alltrim(( cAlias )->C6_OK) == cMark, "  ", cMark )
		( cAlias )->( MsUnlock() ) 
	EndIf
	( cAlias )->( DBSkip() )
End

( cAlias )->( DBGoTo( nRecno ) )
oBrowse:Refresh()

Return()

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
	Alert("N„o Existe Titulo para esse Pedido ")
EndIf

RestArea(aAreaSE1)
RestArea(aAreaVRJ)
RestArea(aArea)

Return

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
    
cQry := " SELECT *                                                                                      "+(Chr(13)+Chr(10))
cQry += " FROM "+RetSQLName("VRJ") + " VRJ                                                              "+(Chr(13)+Chr(10))
cQry += " WHERE VRJ.VRJ_FILIAL  = '"+xFilial("VRJ")+"'                                                  "+(Chr(13)+Chr(10))
cQry += " AND   VRJ.VRJ_STATUS  = 'A'                                                                   "+(Chr(13)+Chr(10))
cQry += " AND   VRJ_DATDIG      >= '"  + DTOS(MV_PAR01) + "' AND VRJ_DATDIG <= '"  + DTOS(MV_PAR02) + "'"+(Chr(13)+Chr(10))
cQry += " AND   VRJ.D_E_L_E_T_  = ' '                                                                   "+(Chr(13)+Chr(10))
cQry := ChangeQuery(cQry)

If Select(cQtPed) > 0 ; (cQtPed)->(DbCloseArea()) ; EndIf
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cQtPed,.T.,.T.)                  
If Select(cQtPed) > 0 ; Count To nTotal           ; EndIf

cQuery := " SELECT  C6_FILIAL                                                      FILIAL  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_PEDCLI                                                      PEDCOM  ,             "+(Chr(13)+Chr(10))
cQuery += "         C5_CONDPAG                                                     FORPAG  ,             "+(Chr(13)+Chr(10))
cQuery += "         C5_CLIENTE                                                     CODCLI  ,             "+(Chr(13)+Chr(10))
cQuery += "         C5_LOJACLI                                                     LOJA    ,             "+(Chr(13)+Chr(10))
cQuery += "         VRJ_DATDIG                                                     DATDIG  ,             "+(Chr(13)+Chr(10))
cQuery += "         C5_NATUREZ                                                     NATURE  ,             "+(Chr(13)+Chr(10))
cQuery += "         VRJ_STATUS                                                     STATUS  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_NUM                                                         PEDIDO  ,             "+(Chr(13)+Chr(10))
cQuery += "         UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C5_XMENSER, 2000, 1)) OBSPED  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_ITEM                                                        ITEPED  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_XMODVEI                                                     MODVEI  ,             "+(Chr(13)+Chr(10))
cQuery += "         SC6.R_E_C_N_O_                                                 RECNO   ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_OPER                                                        OPER    ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_XSEGMOD                                                     SEGMOD  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_XFABMOD                                                     FABMOD  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_XCOREXT                                                     COREXT  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_XCORINT                                                     CORINT  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_CHASSI                                                      CHASSI  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_XCODMAR                                                     CODMAR  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_XPRCTAB                                                     VALTAB  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_TES                                                         TES     ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_XVLRVDA                                                     VALVDA  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_XVLRPRD                                                     VALPRE  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_PRCVEN                                                      VALMOV  ,             "+(Chr(13)+Chr(10))
cQuery += "         C6_XBASST                                                      XBASST                "+(Chr(13)+Chr(10))
cQuery += " FROM "+RetSQLName("SC5")      + " SC5                                                        "+(Chr(13)+Chr(10))
cQuery += " INNER JOIN                                                                                   "+(Chr(13)+Chr(10))
cQuery += "      "+RetSQLName("SC6")      + " SC6   ON  SC5.C5_FILIAL  = SC6.C6_FILIAL                   "+(Chr(13)+Chr(10))
cQuery += "                                         AND SC5.C5_NUM     = SC6.C6_NUM                      "+(Chr(13)+Chr(10))
cQuery += "                                         AND SC5.D_E_L_E_T_ = SC6.D_E_L_E_T_                  "+(Chr(13)+Chr(10))
cQuery += " WHERE  SC6.C6_FILIAL  = '"+xFilial("SC6")+"'                                                 "+(Chr(13)+Chr(10))
cQuery += " AND    SC6.C6_QTDEMP  = 0                                                                    "+(Chr(13)+Chr(10))
cQuery += " AND    SC6.C6_NOTA    = ' '                                                                  "+(Chr(13)+Chr(10))
cQuery += " AND    SC6.C6_QTDENT < SC6.C6_QTDVEN                                                         "+(Chr(13)+Chr(10))
cQuery += " AND    SC6.C6_BLQ    IN(' ','N')                                                             "+(Chr(13)+Chr(10))
cQuery += " AND    SC6.C6_ENTREG >= '" + Dtos(MV_PAR01) + "' AND SC6.C6_ENTREG <= '" + Dtos(MV_PAR02) +"'"+(Chr(13)+Chr(10))
cQuery += " AND    SC5.D_E_L_E_T_ = ' '                                                                  "+(Chr(13)+Chr(10))
cQuery += " ORDER BY SC6.C6_NUM,SC6.C6_ITEM                                                              "+(Chr(13)+Chr(10))
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
    
            //Busca preÁo da tabela
            nPrec     := (cPedidos)->VALTAB
            _nXBasst  := (cPedidos)->XBASST
            nPrec     := BuscaTab( (cPedidos)->FILIAL , (cPedidos)->CODMAR , (cPedidos)->MODVEI , (cPedidos)->SEGMOD , (cPedidos)->FABMOD ) 
            _nXBasst  := BuscaSt( (cPedidos)->FILIAL  , (cPedidos)->CODMAR , (cPedidos)->MODVEI , (cPedidos)->SEGMOD , (cPedidos)->FABMOD ) 

            Aadd(aDados,{  (cPedidos)->FILIAL , (cPedidos)->PEDIDO , (cPedidos)->ITEPED , nPrec, nPrec, _nXBasst, (cPedidos)->TES , (cPedidos)->OPER })

            (cPedidos)->(DbSkip())
        End

        If !AtualPed( aDados )
            MsgInfo("Pedidos  " + cPed +  "  N„o Atualizado!", "Atualiza PreÁo Tabela")
            MsgInfo(cErro)
            cErro := " "
        EndIf

        If !AtuXBAS( aDados )
            MsgInfo("Pedidos  " + cPed +  "  N„o Atualizado!", "Atualiza PreÁo Tabela")
            MsgInfo(cErro)
            cErro := " "
        EndIf
    End

    (cPedidos)->(DbCloseArea())
    MsgInfo("Pedidos  Atualizados com Sucesso!", "Atualiza PreÁo Tabela") 
Else
    lRet := .F. 
    MsgAlert("N„o Existem Pedidos em Abertos para Atualizar!", "Atualiza PreÁo Tabela")
EndIf

Return lRet

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
    
oModel:SetOperation( 4 )  //Alteraùùo
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
                cErro +=  "Id do formulùrio de origem:" + ' [' + AllToChar( aErro[1]  ) + ']'+CRLF 
                cErro +=  "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']'+CRLF
                cErro +=  "Id do formulùrio de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']'+CRLF
                cErro +=  "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']'+CRLF
                cErro +=  "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']'+CRLF
                cErro +=  "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']'+CRLF
                cErro +=  "Mensagem da soluùùo:       " + ' [' + AllToChar( aErro[7]  ) + ']'+CRLF
                cErro +=  "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']'+CRLF
                cErro +=  "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']'+CRLF
                cErro += "Filial: " + aCampos[i][1] + " PEDIDO: " + aCampos[i][2] + " ITEM " + aCampos[i][3]  + CRLF
            Endif
            oModel:DeActivate()
        Else
            Conout( "Nùo encontrados as linhas do Pedido: " + "Filial: " + aCampos[i][1] + " Pedido: " + aCampos[i][2] + " Item " + aCampos[i][3] )
            lRet := .F.
        EndIf
    EndIf
Next

Return lRet

/* =====================================================================================
Funùùo...:              fBuscPed
Autor....:              CAOA - Sandro Ferreira
Data.....:              11/02/2022
Descricao / Objetivo:   Atualiza os Pedidos Selecionados -  Automatica Preùo de Venda
===================================================================================== */
Static Function AtuXBAS( aCampos )

Local i          := 1
Local lRet       := .T.
Local oModel     := FWLoadModel( 'VEIA060' )           //Modelo
Local oModelVRK  := oModel:GetModel( "MODEL_VRK" )    //SubModelo

ProcRegua(Len(aCampos))

DbSelectArea("VRK")
VRK->(DbSetOrder(1))
    
oModel:SetOperation( 4 )  //Alteraùùo
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
                cErro +=  "Id do formulùrio de origem:" + ' [' + AllToChar( aErro[1]  ) + ']'+CRLF 
                cErro +=  "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']'+CRLF
                cErro +=  "Id do formulùrio de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']'+CRLF
                cErro +=  "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']'+CRLF
                cErro +=  "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']'+CRLF
                cErro +=  "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']'+CRLF
                cErro +=  "Mensagem da soluùùo:       " + ' [' + AllToChar( aErro[7]  ) + ']'+CRLF
                cErro +=  "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']'+CRLF
                cErro +=  "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']'+CRLF
                cErro += "Filial: " + aCampos[i][1] + " PEDIDO: " + aCampos[i][2] + " ITEM " + aCampos[i][3]  + CRLF
            Endif
            oModel:DeActivate()
        Else
            Conout( "Nùo encontrados as linhas do Pedido: " + "Filial: " + aCampos[i][1] + " Pedido: " + aCampos[i][2] + " Item " + aCampos[i][3] )
            lRet := .F.
        EndIf
    EndIf
Next

Return lRet

/* =====================================================================================
Funùùo...:              BuscaTab
Autor....:              CAOA - Sandro Ferreira
Data.....:              11/02/2022
Descricao / Objetivo:   Busca os preùos da tabela de Preùo de Venda
===================================================================================== */
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


/* =====================================================================================
Funùùo...:              BuscaSt
Autor....:              CAOA - Sandro Ferreira
Data.....:              11/02/2022
Descricao / Objetivo:   Busca os preùos da tabela de Preùo de Venda
===================================================================================== */
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


/*/{Protheus.doc} CriaSx1
//TODO Cria grupo de perguntas, caso nùo exista.

@author 	Sandro Ferreira
@since 		05/07/2021
@version 	P12
@type 		function
/*/
Static Function Criaperg()

	Local aAreaAnt 	:= GetArea()
	Local aAreaSX1 	:= SX1->(GetArea())
	Local nY 		:= 0
	Local nJ 		:= 0
	Local aReg 		:= {}
	
	aAdd(aReg,{cPerg,"01","Da Data de Digitaùùo      ","mv_ch1","D", 30,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SW9_1"})
	aAdd(aReg,{cPerg,"02","Atù Data de Digitaùùo     ","mv_ch2","D", 30,0,0,"G","(mv_par02>=mv_par01)","mv_par02","","","","","","","","","","","","","","","SW9_1"})


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

******************************************************************************
Static Function VlrPret(cCodMar, cModVei, cSegMod, nValTab, nValPre,cCabAlias)
******************************************************************************

Local cForm121 As Character

cForm121 := GetNewPar("MV_MIL0121","") //U_CMVVEI01()

// Se o usuario zerar o valore pretendido, volta o valor de tabela...
If nValPre == 0
	nValMovimento := nValTab
Else
	If Empty(cForm121)
		nValMovimento := nValPre
	Else
		nValMovimento := nValPre

		nValorPre := nValPre // Valor utilizada na formula...
		nValorMov := CalcRev(nValorPre,cCabAlias)

		If nValorMov <> nValPre
			nValMovimento := nValorMov
		EndIf
	EndIf
EndIf

//Return(nValMovimento)
Return(.T.)

********************************************
Static Function CalcRev(nValorPre,cCabAlias)
********************************************

Local nVlrRet	:= nValorPre      //Valor Total vindo da tabela de preùo
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
Local nPercZFre	:= 0.01 // Tratar Parùmetro
Local nVlrDesFr	:= 0
Local nVlrUnit	:= 0
Local aArea		:= {SA1->(GetArea()),GetArea()}	
Local aAreaSF4	:= {}
Local nPerComs	:= 0
Local nValComs	:= 0
Local cTESTSD	:= SuperGetMV("CMV_TESTSD",.F.,"")
Local aExcecao	:= {}
Local cGrupo1	:= GetMv("MV_XVEI011",,"000003"	) // grupo que nao pode ter a variavel nAux3 calculada no calculo reverso. OBS: se precisar incluir mais grupos, criar outros parametros, nùo inserir o grupo neste mesmo parametro, para evitar cruzamento de logicas entre grupos X marcas, deixando o cruzamento exponencial e errado
Local cMarca1	:= GetMv("MV_XVEI012",,"HYU"	) // marca que nao pode ter a variavel nAux3 calculada no calculo reverso. OBS: se precisar incluir mais marcas, criar outros parametros, nùo inserir a marca neste mesmo parametro, para evitar cruzamento de logicas entre grupos X marcas, deixando o cruzamento exponencial e errado
Local cGrupo2	:= GetMv("MV_XVEI014",,"000003"	) // venda de caminhao HD80, base icms st deve estar zerada
Local cMarca2	:= GetMv("MV_XVEI015",,"HYU"	) // venda de caminhao HD80, base icms st deve estar zerada
Local lPassa	:= .T.
Local oModel	:= FWModelActive()
Local nY		:= 1

//Variùveis para cùlculo do Zona Franca
Local nVlrNormal	:= 0	//Preùo de venda normal
Local nBSICMSST		:= 0	//Base do ICMS ST - conferir com a tabela
Local nAlqIcms		:= 0	//Aliquota de ICMS OP
Local nAlqIcmsST	:= 0	//Aliquota de ICMS ST
Local nVlrIcms		:= 0	//Valor ICMS
Local nAlqPCC		:= 0	//Aliquota de Pis+Cofins ST
Local nRedPCC		:= 0	//Reduùùo Pis / Cofins
Local nRedIcms		:= 0	//Reduùùo base ICMS
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
Local nPrecoZF		:= 0	//Preùo de venda Zona Franca

// venda para consumidor final dentro do mesmo estado, nùo tem ST
If (cCabAlias)->C5_XTIPVEN $ "04"
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+(cCabAlias)->C5_CLIENTE+(cCabAlias)->C5_LOJACLI))
		If Alltrim(GetMv("MV_ESTADO"))  == Alltrim(SA1->A1_EST) .And. ;
           Alltrim(GetMv("MV_ESTADO"))  == "GO"                 .And. ;
           SA1->A1_TIPO                 == "F"                  .And. ;
           Alltrim(SA1->A1_GRPTRIB)     == "VDD"
			lPassa := .F.
		Endif
	Endif		
Endif

// Tratativa Venda Direta
If (cCabAlias)->C5_XTIPVEN  $ "02/03/04/06"
	If !(Alltrim((cCabAlias)->C6_XCODMAR) $ Alltrim(cMarca2) .And. Alltrim((cCabAlias)->C6_XGRPMOD) $ Alltrim(cGrupo2))
		If lPassa
			FWFldPut("VRK_XBASST", FWFldGet("VRK_VALPRE"))
			ConOut("            Recalculando item fiscal - " + cValToChar(FWFldGet("ITEMFISCAL") ) )
			MaFisRecal("",FWFldGet("ITEMFISCAL"))
		Endif	
	Endif	
EndIf

//Venda PCD/Taxi nùo tem reverso.
If (cCabAlias)->C5_XTIPVEN  $ "02/03/05"
	aEval(aArea,{|x| RestArea(x)})
	Return nVlrRet
Endif

SA1->(DbSetOrder(1)) ; SA1->(DbSeek(xFilial("SA1")+(cCabAlias)->C5_CLIENTE+(cCabAlias)->C5_LOJACLI))
SB1->(DbSetOrder(1)) ; SB1->(DbSeek(xFilial("SB1")+(cCabAlias)->C6_PRODUTO                        ))
SF4->(DbSetOrder(1)) ; SF4->(DbSeek(xFilial("SF4")+(cCabAlias)->C6_TES                            ))
MaFisIni((cCabAlias)->C5_CLIENTE, (cCabAlias)->C5_LOJACLI, 'C', 'N', SA1->A1_TIPO, MaFisRelImp("VA060", {"VRJ","VRK"}) )
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

//Venda Direta convùnio 51/00
If (cCabAlias)->C5_XTIPVEN  $ "04"

	Default cCoadMr := (cCabAlias)->C6_XCODMAR
	Default cModVei := (cCabAlias)->C6_XMODVEI
	Default cSegMod := (cCabAlias)->C6_XSEGMOD
	Default nValTab := (cCabAlias)->C6_XPRCTAB
	Default nValPre := (cCabAlias)->C6_XVLRPRD

	MaFisLoad("IT_PRODUTO"  , SB1->B1_COD           , nY) ; MaFisLoad("IT_QUANT"    , 1           , nY)
	MaFisLoad("IT_TES"      , (cCabAlias)->C6_TES	, nY) ; MaFisLoad("IT_PRCUNI"   , nValorPre   , nY)
	MaFisLoad("IT_VALMERC"  , nValorPre             , nY) ; MaFisEndLoad(nY,1)
	MaFisRecal("",nY)
	aExcecao := MaExcecao(nY)

	nAlqIPI   := MaFisRet(nY,"IT_ALIQIPI")/100  			//Aliquota de IPI ja em Percentual  
	nAlqOpIcm := MaFisRet(nY,"IT_ALIQICM")/100  			//Aliquota de ICMS OP em Percentual
	nPerComs  := FatComis(MaFisRet(nY,"IT_PRODUTO"))/100	//Percentual de comissao conforme modelo do veùculo
    
	If !(MaFisRet(nY,"IT_TES") $ cTESTSD)	//-- TES de faturamento p/ veùculo test drive (nùo tem comissùo)
		nValComs := ROUND(nVlrRet * nPerComs,2)
		//oModel:SetValue('MODEL_VRK','VRK_XVLCOM',nValComs)			//Forùa atualizaùùo da tela
		//oModel:SetValue('MODEL_VRK','VRK_XPECOM',nPerComs*100)		//Forùa atualizaùùo da tela
	EndIf
	
	//oModel:SetValue('MODEL_VRK','VRK_VALVDA',nVlrRet)		//Forùa atualizaùùo da tela
	nVlrUnit  := ROUND((nVlrRet - nValComs)/(1+nAlqIPI),2) 
	
	//oModel:SetValue('MODEL_VRK','VRK_XBASIP',nVlrUnit)		//Forùa atualizaùùo da tela
	nVlrUnit  +=  nValComs
	
	//oModel:SetValue('MODEL_VRK','VRK_VALMOV',nVlrUnit) 		//Forùa atualizaùùo da tela
	nVlrRet   := nVlrUnit 
	
	MaFisRecal("",nY)  //Recalcula tudo com a tela atualizada
	
	aEval(aArea,{|x| RestArea(x)})
	
	Return nVlrRet
EndIf

lSuframa := MaFisRet(N,"NF_SUFRAMA")

If !lSuframa 
	/******************************************************************
	**Venda Atacado nùo Suframa Planilha de Referencia para       *****
	**chegar no calculo Unitùrio - Calculadora Concessionaria.xls *****
	*******************************************************************/

	SB1->(DbSetOrder(1)) ; SB1->(DbSeek(xFilial("SB1")+(cCabAlias)->C6_PRODUTO  ))
    SF4->(DbSetOrder(1)) ; SF4->(DbSeek(xFilial("SF4")+(cCabAlias)->C6_TES      ))
	
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
	MaFisLoad("IT_PRODUTO"  , SB1->B1_COD         , nY) ; MaFisLoad("IT_QUANT"    , 1           , nY)
	MaFisLoad("IT_TES"      , (cCabAlias)->C6_TES , nY) ; MaFisLoad("IT_PRCUNI"   , nValorPre   , nY)
	MaFisLoad("IT_VALMERC"  , nValorPre           , nY) ; MaFisEndLoad(nY,1)
	MaFisRecal("",nY)
	aExcecao := MaExcecao(nY)

	nAlqIPI  := MaFisRet(nY,"IT_ALIQIPI")/100  		//Aliquota de IPI ja em Percentual  
	nAlqIcmSt:= MaFisRet(nY,"IT_ALIQSOL")/100  		//Aliquota de ICMS ST ja em Percentual
	nAlqOpIcm:= MaFisRet(nY,"IT_ALIQICM")/100  		//Aliquota de ICMS OP em Percentual 
  //nBaseSt  := MaFisRet(nY,"IT_BASESOL")      		// Base de ST Fixa, que estù no produto. (Usado o Conceito de ICMS Pauta)
    nBaseSt  := (cCabAlias)->C6_XBASST      		// Base de ST Fixa, que estù no produto. (Usado o Conceito de ICMS Pauta)

	cTes     := MaFisRet(nY,"IT_TES")          		// Tes para buscar a reduùùo de Base de ICMS Pois nùo encontrei na MaFisRet
	nAliqStPi:= MaFisRet(nY,"IT_ALIQPS3")/100  		// Aliquota de Pis    ST em Percentual
	nAliqStCo:= MaFisRet(nY,"IT_ALIQCF3")/100  		// Aliquota de Cofins ST em Percentual
    nAlqBIcms:= MaFisRet(nY,"IT_PREDIC")      		// Reduùùo de Base de ICMS
    
	nVlIcmDev := nBaseSt*nAlqIcmSt					// Valor do ICMS devido (Necessùrio para o calculo Reverso)
	nVlrDesFr := 0									// Valor de Desconto de Frete, somente ZF e fixo de 1% sobre preùo total de Venda
	nAux1     := nVlrRet-nVlrDesfr - nVlIcmDev		// Variavel Auxiliar para calculo do Valor Unitùrio             
	nAux2     := 1+nAlqIPI							// Variavel Auxiliar para calculo do Valor Unitùrio 
	nAux3     := ((nAlqBIcms/100)*nAlqOpIcm)		// Variavel Auxiliar para calculo do Valor Unitùrio
	
	// grupo e marca de produtos que nao devem ter esta variavel incrementada ao calculo
	If FatNAux3(MaFisRet(nY,"IT_PRODUTO"),cGrupo1,cMarca1)
		nAux3 := 0
	Endif	
	
	nVlrUnit  := nAux1/(nAux2-nAux3)
	nVlrRet   := nVlrUnit
    (cCabAlias)->(RecLock(cCabAlias),.F.)
    (cCabAlias)->C6_XVLRPRD := Round(nVlrRet,2)
    (cCabAlias)->C6_XVLRMVT := Round(nVlrRet,2)
    (cCabAlias)->C6_XVLRVDA := nValorPre
    (cCabAlias)->C6_PRCVEN  := Round(nVlrRet,2) 
    (cCabAlias)->C6_VALOR   := Round(nVlrRet,2) 
    (cCabAlias)->(MsUnLock())
Else
	******************************************************************
	** Programa de Calculo Reverso Baseado na Planilha de Calculo    *
	** Preùos de Venda CAOA x Revenda  - Zona Franca  de Manaus      *
	******************************************************************

	cTes := MaFisRet(nY,"IT_TES") 
	SF4->(DbSetOrder(1))
    SF4->(DbSeek(xFilial("SF4")+cTes))

	MaFisClear()
	SB1->(DbSetOrder(1)) ; SB1->(DbSeek(xFilial("SB1")+(cCabAlias)->C6_PRODUTO  ))
    SF4->(DbSetOrder(1)) ; SF4->(DbSeek(xFilial("SF4")+(cCabAlias)->C6_TES      ))

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
	MaFisLoad("IT_PRODUTO"  , SB1->B1_COD , nY) ; MaFisLoad("IT_QUANT"    , 1           , nY)
	MaFisLoad("IT_TES"      , cTes	      , nY) ; MaFisLoad("IT_PRCUNI"   , nValorPre   , nY)
	MaFisLoad("IT_VALMERC"  , nValorPre   , nY) 
	MaFisEndLoad(nY,1) ; MaFisRecal("",nY)
	aExcecao := MaExcecao(nY)
	
	aAreaSF4 := GetArea()
	SF4->(DbSetOrder(1))
	If SF4->(DbSeek( xFilial("SF4")+cTes))		
		nRedBPist := SF4->F4_BASEPIS						// Reduùùo da Base de Pis
		nRedBCoSt := SF4->F4_BASECOF						// Reduùùo da Base de Cofins 
		// verifica se tem excecao fiscal e pega de lah quando tiver
		If Len(MaFisRet(nY,"IT_EXCECAO")) > 0
			aExcecao := MaFisRet(nY,"IT_EXCECAO")
			If !Empty(aExcecao[18])
				nRedBPist := aExcecao[18]					// Reduùùo da Base de Pis
			Endif	
			If !Empty(aExcecao[19])
				nRedBCoSt := aExcecao[19]					// Reduùùo da Base de Cofins 
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
	nRedPCC		:= 0																//Reduùùo Pis / Cofins
	nRedIcms	:= MaFisRet(nY,"IT_PREDIC")											//Reduùùo base ICMS
	nAlqIpi		:= MaFisRet(nY,"IT_ALIQIPI")											//Aliquota de IPI
	nAlqIpiZF	:= 0																//Aliquota de IPI Zona Franca
	nVlrDescFr	:= Round((nVlrNormal * nPercZFre),0)								//Desconto frete 1% ZF 
	
	nVlrFator1	:= ((1+(nAlqIpi /100))/100)											//Calculo do Fator 1
	nVlrFator2	:= (   (nRedIcms/100 )/100) /*((1-(nRedIcms/100))/100)*/			//Calculo do Fator 2
	nvlrFator3  := (nVlrFator1 -nVlrFator2 * ((nAlqIcms /100)))/100					//Calculo do Fator 3 

	nVlrUnit	:= ((((nVlrNormal - nVlrDescFr)-nVlrIcms) / nVlrFator3)/10000)		//Valor unitùrio normal
	nDIcmsZF	:= 0																//Desconto do ICMS Normal Zona Franca
	nDIpiZF		:= (nVlrUnit * nAlqIpiZF)											//Desconto do IPI Zona Franca

	nVlrFator1	:= (nVlrUnit * (1 - (nRedPCC/100)))									//Calculo do Fator 1
	nVlrFator2  := (nVlrUnit * (nRedIcms/100)) * (nAlqIcms/100)						//Calculo do Fator 2
	nVlrFator3  := (nVlrFator1 - nVlrFator2) 										//Calculo do Fator 3
	nDPccZF		:= (nVlrFator3 * (nAlqPCC /100))									//Desconto do PIS / COFINS Zona Franca
	nVlrAbtTrb	:= (nDIcmsZF + nDIpiZF + nDPccZF)									//Abatimentos tributos ZF

	nVlrPCCST	:= 0																//PIS/COFINS ST
	nPrecoZF	:= (nVlrNormal - nVlrDescFr - nVlrAbtTrb + nVlrPCCST)				//Preùo de venda Zona Franca
	nVlrRet		:= Round((nPrecoZF- (nBSICMSST*(nAlqIcmsST/100))) / ;
	                     (((100+nAlqIpi)-((nRedIcms/100)*nAlqIcms))/100),2)			//Valor unitùrio final Zona Franca

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

Static Function FatComis(cProd)

Local aArea := {VV2->(GetArea()),GetArea()}	
Local nRet := 0

VV2->(dbSetOrder(7))
If VV2->(dbSeek(xFilial("VV2")+cProd))
	nRet := VV2->VV2_XCOMIS
Endif

aEval(aArea,{|x| RestArea(x)})

Return(nRet)

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

//-------------------------------------------------------------------
static function VVPLastSeq(cCodMar,cModVei,cSegMod,cFabMod)
local cQuery as char
local cSeq as char
local cAlias as char

//Guarda a workarea corrente
cAlias := Alias()

//Gera um alias aleatùrio somente para abrir a query
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

//Fecha a query, boa prùtica, tudo que vocù abriu, vocù fecha... E tambùm existem limites de workareas abertas no Protheus
(cQuery)->(DBCloseArea())

//Retorna a workarea corrente, protegido, pois um dbselectarea com valor vazio gera exceùùo
if !Empty(cAlias)
    DBSelectArea(cAlias)
endif

return cSeq

