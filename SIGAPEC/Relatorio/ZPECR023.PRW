#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

Static oDMSBrwStru
Static oBrwPEC23
Static CLRF := chr(13)+chr(10)

/*/{Protheus.doc} ZPECR023
Consulta de Estoque Protheus X WIS

@author Reinaldo Rabelo
@since 30/03/2023
@version 1.0
@type function
/*/

User Function ZPECR023()

	Local oObjSX1  := FWSX1Util():New()
	Local oIHelper := DMS_InterfaceHelper():New()
	Local oDlgPEC23
	Local oPanBrowse
	//Local oPanDialog
	Local oAuxParam
	
	Private cPerg := "ZPECR023"
	Private cDbLink     := SuperGetMv("CMV_WSR045",.t.,"") //("CMV_PEC031",.t.,"")
	Private lFiltroMarca
	
	if Empty(cDbLink)
		MsgInfo("DbLink não Configurado Parametro CMV_WSR045") //CMV_PEC031")
		Return

	EndIf
	CriaSx1(cPerg) //Cria as Perguntas

	oObjSX1:AddGroup(cPerg)
	oObjSX1:SearchGroup()
	lFiltroMarca := (Len(oObjSX1:GetGroup(cPerg)[2]) >= 7)

	If !Pergunte(cPerg,.t.)
		Return
	EndIf

	U_ZPECRCB_ConfigBrowse(@oDMSBrwStru)
	
	oIHelper:SetOwnerPvt(FunName())

	oDlgPEC23 := oIHelper:CreateDialog("Estoque Protheus X WIS",, .t.)
	oAuxParam := DMS_DataContainer():New()

	oIHelper:SetDialog(oDlgPEC23)
	oPanDialog := oIHelper:CreateTPanel({;
										{"ALINHAMENTO", CONTROL_ALIGN_ALLCLIENT};
										})

	oIHelper:SetDialog(oPanDialog)
	oIHelper:SetOwnerPvt("U_ZPECR023")

	oIHelper:nOpc := 2

	oIHelper:SetDialog(oPanDialog)
	oPanBrowse := oIHelper:CreateTPanel({;
											{"ALINHAMENTO", CONTROL_ALIGN_ALLCLIENT};
										})

	// Cria um Form Browse
	oBrwPEC23 := FWmBrowse():New()

	oDMSBrwStru:SetBrwOwner(oBrwPEC23)

	oBrwPEC23:SetTemporary(.T.)
	//oBrwPEC23:SetUseFilter( .F. ) 
	oBrwPEC23:SetDescription("Estoque Protheus X WIS - Caoa") 

	oBrwPEC23:SetWalkThru(.F.)
	oBrwPEC23:SetAmbiente(.F.)

	oBrwPEC23:SetSeek(.T.,oDMSBrwStru:GetSeek())

	oBrwPEC23:SetFieldFilter(oDMSBrwStru:GetColFilter())

	oBrwPEC23:SetQueryIndex(oDMSBrwStru:GetIndexes())

	oDMSBrwStru:AddBrwColumn()

	oBrwPEC23:SetAlias(oDMSBrwStru:GetAlias())

	oBrwPEC23:SetParam({ || U_ZPECR2PR_Param() })

	oBrwPEC23:DisableDetails()
	oBrwPEC23:SetOwner(oPanBrowse)

	oBrwPEC23:Activate()
	oBrwPEC23:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	ACTIVATE MSDIALOG oDlgPEC23

	oDMSBrwStru:DelTrabTmp()
Return
/*
---------------------------------------------------------------------
Configuração do Browse
---------------------------------------------------------------------
*/
User Function ZPECRCB_ConfigBrowse(oDMSBrwStru)
	Local nX		:= 1
	Local cCampo	:= "B2_QATU"
	Local nTamSX3	:= TamSX3( cCampo )[1]
	Local nDecSX3	:= TamSX3( cCampo )[2]
	Local cTipo		:= TamSX3( cCampo )[3]
	Local cPicture	:= X3Picture( cCampo )
	Local aCampos	:= {}
	
	//Configuração do Grid
	aadd( aCampos , { { 'cIdField','BO_GERAL'  } , { 'cTitulo' , 'BO Geral'          } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','SLDWISBAR' } , { 'cTitulo' , 'SLDWISBAR'         } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','AMZ01'     } , { 'cTitulo' , 'AMZ01'             } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','DIF_BAR'   } , { 'cTitulo' , 'DIF_BAR'           } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','SLDWISFDR' } , { 'cTitulo' , 'SLDWISFDR'         } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','AMZ11'     } , { 'cTitulo' , 'AMZ11'             } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','DIF_FDR'   } , { 'cTitulo' , 'DIF_FDR'           } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','AMZ02'     } , { 'cTitulo' , 'AMZ02'             } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','AMZS_DISP' } , { 'cTitulo' , 'AMZS_DISP'         } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','AMZ61 '    } , { 'cTitulo' , 'AMZ61 '            } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','AMZ65 '    } , { 'cTitulo' , 'AMZ65 '            } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','AMZ80 '    } , { 'cTitulo' , 'AMZ80 '            } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','AMZ90'     } , { 'cTitulo' , 'AMZ90'             } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','AMZS_INDI' } , { 'cTitulo' , 'AMZS_INDISP'       } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	aadd( aCampos , { { 'cIdField','SLD_INT'   } , { 'cTitulo' , 'SLD_ARMAZENAR_INT' } , { 'cTipo' , cTipo },{ 'nTamanho' , nTamSX3 } , { 'nDecimal' , nDecSX3 } , { 'cPicture' , cPicture } } )
	oDMSBrwStru := OFBrowseStruct():New({"SB1"})

	oDMSBrwStru:AddField( "B1_COD"  )
	oDMSBrwStru:AddField( "B1_DESC" )
	
	For nX := 1 to Len(aCampos)
		oDMSBrwStru:AddFieldManual( DMS_DataContainer():New(aCampos[nX]) )
	Next nX

	oDMSBrwStru:AddIndex( "B1_COD"  )
	oDMSBrwStru:AddIndex( "B1_DESC" )

	oDMSBrwStru:AddSeek( { "B1_COD"  } )
	oDMSBrwStru:AddSeek( { "B1_DESC" } )

	oDMSBrwStru:CriaTabTmp()
	oDMSBrwStru:LoadData( ZPEC23QR_Query() )

Return

/*
---------------------------------------------------------------------
Refaz a Consulta e atualiza a Tela
---------------------------------------------------------------------
*/
User Function ZPECR2PR_Param()
	Local lRet := .T.

	If (lRet := Pergunte(cPerg,.T.))

		oDMSBrwStru:LoadData( ZPEC23QR_Query() , .t. )
		oBrwPEC23:Refresh(.T.)

	EndIf

Return .F.

/*
---------------------------------------------------------------------
Consulta 
---------------------------------------------------------------------
*/

Static Function ZPEC23QR_Query()

	Local cQuery := ""
	Local cDeProduto  := MV_PAR01 
	Local cAteProduto := MV_PAR02
	Local nBO         := MV_PAR04
	Local nDiverWis   := MV_PAR05
	
	
	cQuery +=  CLRF + " SELECT  "
	cQuery +=  CLRF + " 	  B1.B1_COD AS B1_COD "
	cQuery +=  CLRF + " 	, B1.B1_DESC AS B1_DESC "
	cQuery +=  CLRF + " 	, NVL( TMPXBO.TOT_BO   , 0 ) AS  BO_GERAL "
	cQuery +=  CLRF + " 	, NVL( TMPWISBAR.SALDO , 0 ) AS SLDWISBAR	"
	cQuery +=  CLRF + " 	, NVL( ( B201.B2_QATU - B201.B2_RESERVA ) , 0 ) AS AMZ01"
	cQuery +=  CLRF + " 	, NVL( TMPWISBAR.SALDO , 0 ) - NVL( ( B201.B2_QATU - B201.B2_RESERVA ) , 0 ) AS DIF_BAR"
	cQuery +=  CLRF + " 	, NVL( TMPWISFDR.SALDO , 0 ) AS SLDWISFDR"
	cQuery +=  CLRF + " 	, NVL( (B211.B2_QATU - B211.B2_RESERVA ) , 0 ) AS AMZ11"
	cQuery +=  CLRF + " 	, NVL( TMPWISFDR.SALDO , 0 ) - NVL( ( B211.B2_QATU - B211.B2_RESERVA ) , 0 ) AS DIF_FDR"
	cQuery +=  CLRF + " 	, NVL( B202.B2_QATU    , 0 ) AS AMZ02"
	cQuery +=  CLRF + " 	, NVL( TMPDSP.TOT_DSP  , 0 ) AS AMZS_DISP"
	cQuery +=  CLRF + " 	, NVL( B261.B2_QATU	   , 0 ) AS AMZ61"
	cQuery +=  CLRF + " 	, NVL( B265.B2_QATU    , 0 ) AS AMZ65"
	cQuery +=  CLRF + " 	, NVL( B280.B2_QATU    , 0 ) AS AMZ80"
	cQuery +=  CLRF + " 	, NVL( B290.B2_QATU    , 0 ) AS AMZ90"
	cQuery +=  CLRF + " 	, NVL( TMPINDSP.TOT_INDSP  , 0 ) AS AMZS_INDI	"
	cQuery +=  CLRF + " 	, NVL( TMPZD1TOT.TOT_SLDIT , 0 ) AS SLD_INT "
	cQuery +=  CLRF + " FROM " + RetSqlName("SB1") + " B1 "
	
	cQuery +=  CLRF + " 	LEFT JOIN (	                                                                                                "
	cQuery +=  CLRF + "					SELECT E.CD_PRODUTO PROD,"
	cQuery +=  CLRF + "						CASE WHEN (SUM(E.QT_ESTOQUE - E.QT_RESERVA_SAIDA)-WISGERAR.QT_A_RES)> 0 THEN "
	cQuery +=  CLRF + "						SUM(E.QT_ESTOQUE - E.QT_RESERVA_SAIDA)-WISGERAR.QT_A_RES ELSE 0 END AS SALDO "
	cQuery +=  CLRF + "					FROM WIS.V_ENDERECO_ESTOQUE@" + cDbLink + " E"
	cQuery +=  CLRF + "					LEFT JOIN (SELECT DETWIS.CD_EMPRESA EMP, DETWIS.CD_PRODUTO PROD, SUM(DETWIS.QT_SEPARAR) QT_A_RES"
	cQuery +=  CLRF + "								FROM  WIS.T_DET_PEDIDO_SAIDA@" + cDbLink + " DETWIS"
	cQuery +=  CLRF + "								INNER JOIN WIS.T_CAB_PEDIDO_SAIDA@" + cDbLink + " CABWIS "
	cQuery +=  CLRF + "								ON DETWIS.NU_PEDIDO = CABWIS.NU_PEDIDO"
	cQuery +=  CLRF + "								WHERE CABWIS.CD_SITUACAO = '64'"
	cQuery +=  CLRF + "								GROUP BY DETWIS.CD_EMPRESA, DETWIS.CD_PRODUTO ) WISGERAR"
	cQuery +=  CLRF + "					ON WISGERAR.EMP = E.CD_EMPRESA"
	cQuery +=  CLRF + "					   AND WISGERAR.PROD = E.CD_PRODUTO"
	cQuery +=  CLRF + "					WHERE ((CD_EMPRESA = '1006' AND SUBSTR(CD_ENDERECO,1,2) NOT BETWEEN '30' AND '39') OR (CD_EMPRESA = '1002' AND SUBSTR(CD_ENDERECO,1,3) NOT BETWEEN '030' AND '039'))"
	cQuery +=  CLRF + "					GROUP BY E.CD_EMPRESA, E.CD_PRODUTO, WISGERAR.QT_A_RES"
	cQuery +=  CLRF + " 			  ) TMPWISBAR                                                                                    "
	cQuery +=  CLRF + " 	ON LTRIM( RTRIM( TMPWISBAR.PROD ) ) = LTRIM(RTRIM( B1.B1_COD ) )"
	
	cQuery +=  CLRF + " 	LEFT JOIN (	                                                                                                "
	cQuery +=  CLRF + "					SELECT E.CD_PRODUTO PROD,"
	cQuery +=  CLRF + "						CASE WHEN (SUM(E.QT_ESTOQUE - E.QT_RESERVA_SAIDA)-WISGERAR.QT_A_RES)> 0 THEN "
	cQuery +=  CLRF + "						SUM(E.QT_ESTOQUE - E.QT_RESERVA_SAIDA)-WISGERAR.QT_A_RES ELSE 0 END AS SALDO "
	cQuery +=  CLRF + "					FROM WIS.V_ENDERECO_ESTOQUE@" + cDbLink + " E"
	cQuery +=  CLRF + "					LEFT JOIN (SELECT DETWIS.CD_EMPRESA EMP, DETWIS.CD_PRODUTO PROD, SUM(DETWIS.QT_SEPARAR) QT_A_RES"
	cQuery +=  CLRF + "								FROM  WIS.T_DET_PEDIDO_SAIDA@" + cDbLink + " DETWIS"
	cQuery +=  CLRF + "								INNER JOIN WIS.T_CAB_PEDIDO_SAIDA@" + cDbLink + " CABWIS "
	cQuery +=  CLRF + "								ON DETWIS.NU_PEDIDO = CABWIS.NU_PEDIDO"
	cQuery +=  CLRF + "								WHERE CABWIS.CD_SITUACAO = '64'"
	cQuery +=  CLRF + "								GROUP BY DETWIS.CD_EMPRESA, DETWIS.CD_PRODUTO ) WISGERAR"

	cQuery +=  CLRF + "					ON WISGERAR.EMP = E.CD_EMPRESA"
	cQuery +=  CLRF + "					   AND WISGERAR.PROD = E.CD_PRODUTO"
	cQuery +=  CLRF + "					WHERE ((CD_EMPRESA = '1006' AND SUBSTR(CD_ENDERECO,1,2) BETWEEN '30' AND '39') OR (CD_EMPRESA = '1002' AND SUBSTR(CD_ENDERECO,1,3) BETWEEN '030' AND '039'))"
	cQuery +=  CLRF + "					GROUP BY E.CD_EMPRESA, E.CD_PRODUTO, WISGERAR.QT_A_RES"
	cQuery +=  CLRF + " 			  ) TMPWISFDR                                                                                    "
	cQuery +=  CLRF + " 		ON LTRIM( RTRIM( TMPWISFDR.PROD ) ) = LTRIM( RTRIM( B1.B1_COD ) )"
	
	cQuery +=  CLRF + " 	LEFT JOIN " + RetSqlName("SB2") + "  B201 "
	cQuery +=  CLRF + " 		ON  B201.B2_FILIAL = '" + xFilial( "SB2" ) + "' "
	cQuery +=  CLRF + " 		AND B201.B2_COD    = B1.B1_COD"
	cQuery +=  CLRF + " 		AND B201.D_E_L_E_T_ = ' '"
	cQuery +=  CLRF + " 		AND B201.B2_LOCAL IN ('01') "
	
	cQuery +=  CLRF + " 	LEFT JOIN " + RetSqlName("SB2") + "  B202 "
	cQuery +=  CLRF + " 		ON  B202.B2_FILIAL  = '" + xFilial( "SB2" ) + "' "
	cQuery +=  CLRF + " 		AND B202.B2_COD     =   B1.B1_COD"
	cQuery +=  CLRF + " 		AND B202.D_E_L_E_T_ = ' '"
	cQuery +=  CLRF + " 		AND B202.B2_LOCAL IN ('02')"
	
	cQuery +=  CLRF + " 	LEFT JOIN " + RetSqlName("SB2") + "  B211 "
	cQuery +=  CLRF + " 		ON  B211.B2_FILIAL  = '" + xFilial( "SB2" ) + "' "
	cQuery +=  CLRF + " 		AND B211.B2_COD     =  B1.B1_COD"
	cQuery +=  CLRF + " 		AND B211.D_E_L_E_T_ = ' ' "
	cQuery +=  CLRF + " 		AND B211.B2_LOCAL IN ('11') "
	
	cQuery +=  CLRF + " 	LEFT JOIN " + RetSqlName("SB2") + " B261 "
	cQuery +=  CLRF + " 		ON  B261.B2_FILIAL = '" + xFilial( "SB2" ) + "' "
	cQuery +=  CLRF + " 		AND B261.B2_COD    =   B1.B1_COD "
	cQuery +=  CLRF + " 		AND B261.D_E_L_E_T_ = ' '	"
	cQuery +=  CLRF + " 		AND B261.B2_LOCAL IN ('61') "
	
	cQuery +=  CLRF + " 	LEFT JOIN " + RetSqlName("SB2") + " B265 "
	cQuery +=  CLRF + " 		ON  B265.B2_FILIAL = '" + xFilial( "SB2" ) + "' "
	cQuery +=  CLRF + " 		AND B265.B2_COD    =   B1.B1_COD "
	cQuery +=  CLRF + " 		AND B265.D_E_L_E_T_ = ' ' "
	cQuery +=  CLRF + " 		AND B265.B2_LOCAL IN ('65') "
	
	cQuery +=  CLRF + " 	LEFT JOIN " + RetSqlName("SB2") + " B280 "
	cQuery +=  CLRF + " 		ON  B280.B2_FILIAL = '" + xFilial( "SB2" ) + "' "
	cQuery +=  CLRF + " 		AND B280.B2_COD    =   B1.B1_COD "
	cQuery +=  CLRF + " 		AND B280.D_E_L_E_T_ = ' '  "
	cQuery +=  CLRF + " 		AND B280.B2_LOCAL IN ('80') "
	
	cQuery +=  CLRF + " 	LEFT JOIN " + RetSqlName("SB2") + " B290 "
	cQuery +=  CLRF + " 		ON  B290.B2_FILIAL = '" + xFilial( "SB2" ) + "' "
	cQuery +=  CLRF + " 		AND B290.B2_COD    =   B1.B1_COD "
	cQuery +=  CLRF + " 		AND B290.D_E_L_E_T_ = ' '	"
	cQuery +=  CLRF + " 		AND B290.B2_LOCAL IN ('90') "

	cQuery +=  CLRF + " 	LEFT JOIN " + RetSqlName("SB2") + " B261 " 
	cQuery +=  CLRF + " 		ON B261.B2_FILIAL = '" + xFilial( "SB2" ) + "' "
	cQuery +=  CLRF + " 		AND B261.B2_COD = B1.B1_COD"
	cQuery +=  CLRF + " 		AND B261.B2_LOCAL IN ('61')"
	cQuery +=  CLRF + " 		AND B261.D_E_L_E_T_ = ' '"	
	
	cQuery +=  CLRF + " 	LEFT JOIN ("
	cQuery +=  CLRF + " 				SELECT B2DSP.B2_FILIAL FILIAL, B2DSP.B2_COD COD, SUM(B2DSP.B2_QATU) TOT_DSP"
	cQuery +=  CLRF + " 				FROM " + RetSqlName("SB2") + "  B2DSP "
	cQuery +=  CLRF + " 				WHERE"
	cQuery +=  CLRF + " 					    B2DSP.B2_LOCAL BETWEEN '01' AND '49' "
	cQuery +=  CLRF + " 					AND B2DSP.D_E_L_E_T_ = ' '"
	cQuery +=  CLRF + " 				GROUP BY B2DSP.B2_FILIAL, B2DSP.B2_COD"
	cQuery +=  CLRF + " 		 ) TMPDSP "
	cQuery +=  CLRF + "			ON  TMPDSP.FILIAL = '" + xFilial( "SB2" ) + "' "
	cQuery +=  CLRF + " 		AND TMPDSP.COD    =   B1.B1_COD"
	
	cQuery +=  CLRF + " 	LEFT JOIN ("
	cQuery +=  CLRF + " 				SELECT B2DSP.B2_COD AS COD, SUM(B2DSP.B2_QATU) AS TOT_INDSP"
	cQuery +=  CLRF + " 				FROM " + RetSqlName("SB2") + "  B2DSP "
	cQuery +=  CLRF + " 				WHERE B2DSP.B2_FILIAL = '" + xFilial( "SB2" ) + "' "
	cQuery +=  CLRF + " 					AND ( "
	cQuery +=  CLRF + " 					B2DSP.B2_LOCAL BETWEEN '50' AND '60' "
	cQuery +=  CLRF + " 					OR B2DSP.B2_LOCAL BETWEEN '62' AND '99' ) "
	cQuery +=  CLRF + " 					AND B2DSP.D_E_L_E_T_ = ' '"
	cQuery +=  CLRF + " 				GROUP BY B2DSP.B2_COD "
	cQuery +=  CLRF + " 		 ) TMPINDSP "
	cQuery +=  CLRF + " 		ON TMPINDSP.COD = B1.B1_COD	"
	
	cQuery +=  CLRF + " 	LEFT JOIN ( "
	cQuery +=  CLRF + " 				SELECT VS3BO.VS3_FILIAL FILIAL, VS3BO.VS3_CODITE AS COD, SUM(VS3BO.VS3_QTDITE) AS TOT_BO "
	cQuery +=  CLRF + " 							FROM " + RetSqlName("VS3") + " VS3BO"
	cQuery +=  CLRF + " 							INNER JOIN " + RetSqlName("VS1") + " VS1BO "
	cQuery +=  CLRF + " 								ON  VS1BO.VS1_FILIAL = VS3BO.VS3_FILIAL "
	cQuery +=  CLRF + " 								AND VS1BO.VS1_NUMORC = VS3BO.VS3_NUMORC "
	cQuery +=  CLRF + " 								AND VS1BO.VS1_XBO    = 'S' "
	cQuery +=  CLRF + " 								AND VS1BO.D_E_L_E_T_ = ' ' "
	cQuery +=  CLRF + " 								AND VS1BO.VS1_STATUS IN ('0','3') "
	cQuery +=  CLRF + " 							WHERE VS3BO.D_E_L_E_T_ = ' ' "
	cQuery +=  CLRF + " 						GROUP BY VS3BO.VS3_FILIAL, VS3BO.VS3_CODITE"
	cQuery +=  CLRF + " 				) TMPXBO"
	cQuery +=  CLRF + " 		ON  TMPXBO.FILIAL = '" + xFilial( "SB2" ) + "' "
	cQuery +=  CLRF + " 		AND TMPXBO.COD    =   B1.B1_COD"
	
	cQuery +=  CLRF + " 	LEFT JOIN ("
	cQuery +=  CLRF + " 				SELECT ZD1.ZD1_FILIAL FILIAL, ZD1.ZD1_COD COD, SUM(ZD1.ZD1_SLDIT) TOT_SLDIT"
	cQuery +=  CLRF + " 						FROM " + RetSqlName("ZD1") + " ZD1 "
	cQuery +=  CLRF + " 						WHERE   ZD1.D_E_L_E_T_ = ' ' "
	cQuery +=  CLRF + " 							AND ZD1.ZD1_SLDIT  > '0' "
	cQuery +=  CLRF + " 						GROUP BY ZD1.ZD1_FILIAL, ZD1.ZD1_COD"
	cQuery +=  CLRF + " 		) TMPZD1TOT"
	cQuery +=  CLRF + " 		ON TMPZD1TOT.FILIAL = '" + xFilial( "SB2" ) + "' "
	cQuery +=  CLRF + " 		AND TMPZD1TOT.COD = B1.B1_COD"
	
	cQuery +=  CLRF + " WHERE   B1.D_E_L_E_T_ = ' ' "
	cQuery +=  CLRF + " 	AND B1.B1_FILIAL = '" + xFilial( "SB1" ) + "' "
	cQuery +=  CLRF + " 	AND B1.B1_COD BETWEEN '" + cDeProduto + "' AND '" + cAteProduto + "' "
	
	//Somente com BO -- SIM
	if nBo == 2 
		cQuery +=  CLRF + " AND TMPXBO.TOT_BO > 0   "
	EndIf
	
	//SOMENTE COM DIVERGENCIA PROTHEUS X WIS -- SIM
	If nDiverWis == 2
		cQuery +=  CLRF + "     AND "
		cQuery +=  CLRF + " 	("
		cQuery +=  CLRF + " 	NVL(TMPWISBAR.SALDO,0) <> NVL((B201.B2_QATU - B201.B2_RESERVA),0)"
		cQuery +=  CLRF + " 	OR NVL(TMPWISFDR.SALDO,0) <> NVL((B211.B2_QATU - B211.B2_RESERVA),0) "
		cQuery +=  CLRF + " 	)"
	EndIf
	
	cQuery +=  CLRF + " ORDER BY NVL(TMPWISBAR.SALDO,0)-NVL((B201.B2_QATU - B201.B2_RESERVA),0) DESC,"
	cQuery +=  CLRF + " 		 NVL(TMPWISFDR.SALDO,0)-NVL((B211.B2_QATU - B211.B2_RESERVA),0) "


Return cQuery
/*
---------------------------------------------------------------------
Chamada do Botão para Gerar a Planilha
---------------------------------------------------------------------
*/
Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina TITLE "Parâmetros"     ACTION 'U_ZPECR2PR_Param' OPERATION 3 ACCESS 0 // 'Parâmetros'
	ADD OPTION aRotina TITLE "Gerar Planilha" ACTION 'U_ZPEC23PO'       OPERATION 2 ACCESS 0 // 'Gerar Planilha'

Return aRotina
/*
---------------------------------------------------------------------
Chamada do Botão para Gerar a Planilha
---------------------------------------------------------------------
*/
User Function ZPEC23PO()
	Processa( {|| U_ZPECR23P_PlanilhaEstoque()  }, "Gerando Planilha...", OemToAnsi("Lendo dados do arquivo..."),.F.)
Return
/*
---------------------------------------------------------------------
Geração da Planilha com os dados da Consulta.
---------------------------------------------------------------------
*/
User Function ZPECR23P_PlanilhaEstoque()

	Local oExcel
	Local oFwExcel
	Local aAuxLinha
	Local nQtdCol
	Local nLoopRec
	Local nPosCol
	Local lTotalizar
	Local cTipo
	Local cSheet := "Estoque Protheus X WIS"
	Local cTable := "Protheus X WIS"
	Local cDir   := alltrim(MV_PAR03)

	If oBrwPEC23:LogicLen() <= 0
		Return .t.
	EndIf

	oFwExcel := FWMSEXCEL():New()
	oFwExcel:AddworkSheet(cSheet)
	oFwExcel:AddTable(cSheet,cTable)

	nQtdCol := Len(oBrwPEC23:aColumns)

	For nPosCol := 1 to nQtdCol

		lTotalizar := .F.
		cTipo      := oBrwPEC23:GetColumn(nPosCol):GetType()

		oFwExcel:AddColumn( ;
						cSheet, ;
						cTable , ;
						oBrwPEC23:GetColumn(nPosCol):GetTitle() , ;
						IIf( cTipo == "N" , 3 , 1 ) , ; // Alinhamento da coluna ( 1-Left,2-Center,3-Right )
						IIf( cTipo == "N" , 2 , 1 ) , ; // Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
						lTotalizar )
	Next nPosCol

	oBrwPEC23:GoTop()
	nUlRec   := oBrwPEC23:LogicLen()
	nCurrRec := oBrwPEC23:At()
	
	ProcRegua(1000)
	nX := 0
	nY := 0
	
	While .T.
		nLoopRec := oBrwPEC23:At()

		aAuxLinha := Array(nQtdCol)
		
		For nPosCol := 1 to nQtdCol
			cIdField := oBrwPEC23:GetColumn(nPosCol):GetID()

			aAuxLinha[nPosCol] := AllTrim(oBrwPEC23:GetColumnData(nPosCol))
	
		Next nPosCol

		oFwExcel:AddRow(cSheet ,cTable,aAuxLinha) // Peças / Peças
		nX++
		nY++
		oBrwPEC23:GoDown()
		IncProc("Lendo Registo " +cValToChar(nX) + " aguade..." )

		If nLoopRec == oBrwPEC23:At()
			Exit
		EndIf

		if nY >=1000
			ProcRegua(1000)
			nY := 0
		endif

	EndDo

	oFwExcel:Activate()

	oFwExcel:GetXMLFile(AllTrim(cDir))
	oFwExcel:DeActivate()

	oBrwPEC23:GoTo( nCurrRec, .T. )

	FreeObj(oFwExcel)

	// Abrindo o excel e abrindo o arquivo xml.
	oExcel := MsExcel():New()           // Abre uma nova conex„o com Excel.
	oExcel:WorkBooks:Open(cDir)         // Abre uma planilha.
	oExcel:SetVisible(.T.)              // Visualiza a planilha.
	oExcel:Destroy()                    // Encerra o processo do gerenciador de tarefas.

Return
/*
//---------------------------------------------------------
Cria Pergunte de Parametros
//----------------------------------------------------------
*/
Static Function CriaSx1(cPerg)
	Local aArea    := GetArea()    				// Salva ambiente atual para posterior restauracao
	Local _sAlias  := Alias()
	Local aRegs    := {}
	Local i,j

	dbSelectArea("SX1")
	dbgotop()
	dbSetOrder(1)  

	cPerg := PADR(cPerg,10)
	
	AAdd(aRegs,{cPerg,"01","De Produto"          ,"","","mv_ch1","C",(TamSX3("B1_COD")[1]),0,0,"G","","MV_PAR01",""   ,"","","","",   "","","","","","","","","","","","","","","","","","","","SB1","",""})
	AAdd(aRegs,{cPerg,"02","Até Produto"         ,"","","mv_ch2","C",(TamSX3("B1_COD")[1]),0,0,"G","","MV_PAR02",""   ,"","","","",   "","","","","","","","","","","","","","","","","","","","SB1","","",""})
	AAdd(aRegs,{cPerg,"03","Salvar em?"          ,"","","mv_ch3","C",                   60,0,0,"G","","MV_PAR03",""   ,"","","","",   "","","","","","","","","","","","","","","","","","","","DIR","",""})
	AAdd(aRegs,{cPerg,"04","Diver.Protheus X WIS","","","mv_ch4","C",                   01,0,0,"C","","MV_PAR04","Não","","","","","Sim","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(aRegs,{cPerg,"05","Somente BO"          ,"","","mv_ch5","C",                   01,0,0,"C","","MV_PAR05","Não","","","","","Sim","","","","","","","","","","","","","","","","","","","","",""})
	
	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg + aRegs[i, 2])
			RecLock("SX1", .T.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j, aRegs[i, j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	DbSelectArea(_sAlias)
	RestArea(aArea)
Return 
