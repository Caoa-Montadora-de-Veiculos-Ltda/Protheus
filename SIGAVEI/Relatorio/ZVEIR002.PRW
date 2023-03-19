#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

Static oDMSBrwStru
Static oBrwZVEI2
Static CLRF := chr(13)+chr(10)

/*/{Protheus.doc} ZVEIR002
Consulta de Faturamento por Tipo

@author Reinaldo Rabelo
@since 05/12/2022
@version 1.0
@type function
/*/

User Function ZVEIR002()

	Local oObjSX1  := FWSX1Util():New()
	Local oIHelper := DMS_InterfaceHelper():New()

	Local oVC063Dlg
	Local oPanBrowse
	Local oPanDialog
	Local oAuxParam

	Private lFiltroMarca
	
	oObjSX1:AddGroup("ZVEIR002")
	oObjSX1:SearchGroup()
	lFiltroMarca := (Len(oObjSX1:GetGroup("ZVEIR002")[2]) >= 7)

	If ! Pergunte("VEIC063",.t.)
		Return
	EndIf

	U_ZVEIR2CB_ConfigBrowse(@oDMSBrwStru)
	
	oIHelper:SetOwnerPvt(FunName())

	oVC063Dlg := oIHelper:CreateDialog("Faturamento por tipo",, .t.)
	oAuxParam := DMS_DataContainer():New()

	oIHelper:SetDialog(oVC063Dlg)
	oPanDialog := oIHelper:CreateTPanel({;
										{"ALINHAMENTO", CONTROL_ALIGN_ALLCLIENT};
										})

	oIHelper:SetDialog(oPanDialog)
	oIHelper:SetOwnerPvt("U_ZVEIR002")

	oIHelper:nOpc := 2

	oIHelper:AddMGetTipo( {;
							{ 'X3_TIPO'    , 'N' },;
							{ 'X3_TAMANHO' , TamSX3('VRJ_VALTOT')[1] },;
							{ 'X3_DECIMAL' , TamSX3('VRJ_VALTOT')[1] },;
							{ 'X3_CAMPO'   , "TOTPERIODO" },;
							{ 'X3_TITULO'  , 'Valor Total'},;
							{ 'X3_PICTURE' , '@E 99,999,999,999.99' } ;
						})
			//&(oAuxParam:GetValue('CAMPO')) := oAuxParam:GetValue("VALOR")

	oIHelper:CreateMSMGet(.F., {;
								{"VISUALIZA"  , .t.               },;
								{"YSIZE", 30},;
								{"COLUNA", .t.},;
								{"ALINHAMENTO", CONTROL_ALIGN_BOTTOM};
							})

	oIHelper:SetDialog(oPanDialog)
	oPanBrowse := oIHelper:CreateTPanel({;
											{"ALINHAMENTO", CONTROL_ALIGN_ALLCLIENT};
										})

	// Cria um Form Browse
	oBrwZVEI2 := FWmBrowse():New()

	oDMSBrwStru:SetBrwOwner(oBrwZVEI2)

	oBrwZVEI2:SetTemporary(.T.)
	//oBrwZVEI2:SetUseFilter( .F. ) 
	oBrwZVEI2:SetDescription("Faturamento por Tipo - Caoa") // Faturamento por Tipo

	oBrwZVEI2:SetWalkThru(.F.)
	oBrwZVEI2:SetAmbiente(.F.)

	oBrwZVEI2:SetSeek(.T.,oDMSBrwStru:GetSeek())

	oBrwZVEI2:SetFieldFilter(oDMSBrwStru:GetColFilter())

	oBrwZVEI2:SetQueryIndex(oDMSBrwStru:GetIndexes())

	oDMSBrwStru:AddBrwColumn()

	oBrwZVEI2:SetAlias(oDMSBrwStru:GetAlias())

	oBrwZVEI2:SetParam({ || U_ZVEIR2PR_Param() })


	oBrwZVEI2:DisableDetails()
	oBrwZVEI2:SetOwner(oPanBrowse)

	oBrwZVEI2:Activate()
	oBrwZVEI2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ZVEIR2TT_Total()

	ACTIVATE MSDIALOG oVC063Dlg

	oDMSBrwStru:DelTrabTmp()
Return

User Function ZVEIR2CB_ConfigBrowse(oDMSBrwStru)

	Local nTamSX3 := TamSX3("VX5_DESCRI")[1]

	oDMSBrwStru := OFBrowseStruct():New({"CC2", "SA1", "SA3", "SF2", "SDB", "VRJ", "VRK", "VV0", "VV2", "VV3", "VV9","SE4","VV0","SD2"})

	oDMSBrwStru:AddField( "VRJ_PEDIDO" )
	oDMSBrwStru:AddField( "VRJ_PEDCOM" )
	oDMSBrwStru:AddField( "D2_PEDIDO"  )
	oDMSBrwStru:AddField( "VV0_NUMTRA" )
	oDMSBrwStru:AddField( "VRJ_DATDIG" )
	oDMSBrwStru:AddField( "VV3_DESCRI" ,"Tipo Venda" )
	oDMSBrwStru:AddField( "VRK_CHASSI" )
	oDMSBrwStru:AddField( "VRK_MODVEI" )
	oDMSBrwStru:AddField( "VV2_DESMOD" )
	oDMSBrwStru:AddField( "VRK_OPCION" )
	oDMSBrwStru:AddFieldManual( DMS_DataContainer():New({;
															{ 'cIdField' , 'DESCOPCION'      },;
															{ 'cTitulo'  , 'Descr. Opcional' },; 
															{ 'cTipo'    , 'C'               },;
															{ 'nTamanho' , nTamSX3           },;
															{ 'nDecimal' , 0                 },;
															{ 'cPicture' , '@!'              } ;
														} ) )
	oDMSBrwStru:AddField( "VRK_COREXT" )
	oDMSBrwStru:AddFieldManual( DMS_DataContainer():New({;
															{ 'cIdField' , 'DESCCOREXT'        },;
															{ 'cTitulo'  , 'Descr. Cor Externa'},;
															{ 'cTipo'    , 'C'                 },;
															{ 'nTamanho' , nTamSX3             },;
															{ 'nDecimal' , 0                   },;
															{ 'cPicture' , '@!'                } ;
														} ) )
	oDMSBrwStru:AddField( "VRK_CORINT" )
	oDMSBrwStru:AddFieldManual( DMS_DataContainer():New({;
															{ 'cIdField' , 'DESCCORINT'        },;
															{ 'cTitulo'  , 'Descr. Cor Interna'},; // 'Descr. Cor Interna'
															{ 'cTipo'    , 'C'                 },;
															{ 'nTamanho' , nTamSX3             },;
															{ 'nDecimal' , 0                   },;
															{ 'cPicture' , '@!'                } ;
														} ) )
	oDMSBrwStru:AddField( "VRK_FABMOD" )
	oDMSBrwStru:AddField( "F2_SERIE"   , "Série NF" ) // "Série NF"
	oDMSBrwStru:AddField( "F2_DOC"     , "Número NF") // "Número NF"
	oDMSBrwStru:AddField( "F2_EMISSAO" )
	oDMSBrwStru:AddField( "F2_CHVNFE"  )
	oDMSBrwStru:AddField( "VRK_VALTAB" )
	oDMSBrwStru:AddField( "VRK_VALVDA" )
	oDMSBrwStru:AddField( "VRJ_CODVEN" )
	oDMSBrwStru:AddField( "A3_NOME"    , "Nome do Vendedor")
	oDMSBrwStru:AddField( "VRJ_CODCLI" )
	oDMSBrwStru:AddField( "VRJ_LOJA"   )
	oDMSBrwStru:AddFieldManual( DMS_DataContainer():New({;
															{ 'cIdField' , 'A1_CGC'          },;
															{ 'cTitulo' , RetTitle("A1_CGC") },;
															{ 'cTipo' , 'C'                  },;
															{ 'nTamanho' , 14                },;
															{ 'nDecimal' , 0                 },;
															{ 'cPicture' , { || IIF(Len(Alltrim((oBrwZVEI2:GetAlias())->A1_CGC)) == 11 , "@R 999.999.999-99","@R 99.999.999/9999-99") } } ;
														} ) )
	oDMSBrwStru:AddField( "A1_NOME"    )
	oDMSBrwStru:AddField( "A1_NREDUZ"  )
	oDMSBrwStru:AddField( "CC2_MUN"    )
	oDMSBrwStru:AddField( "A1_EST"     )

	oDMSBrwStru:AddField( "VRJ_CLIRET" )
	oDMSBrwStru:AddField( "VRJ_LOJRET" )

	oDMSBrwStru:AddField( "VRJ_FORPAG" )
	oDMSBrwStru:AddField( "E4_DESCRI" ,"Descr.Forma de Pagamento" )

	oDMSBrwStru:AddIndex( "VRJ_PEDIDO" )
	oDMSBrwStru:AddIndex( "VRJ_PEDCOM" )
	oDMSBrwStru:AddIndex( "VRJ_CODCLI+VRJ_LOJA" )
	oDMSBrwStru:AddIndex( "VRK_CHASSI" )

	oDMSBrwStru:AddSeek( { "VRJ_PEDIDO" } )
	oDMSBrwStru:AddSeek( { "VRK_CHASSI" } )
	oDMSBrwStru:AddSeek( { "VRJ_CODCLI" , "VRJ_LOJA"} )

	oDMSBrwStru:CriaTabTmp()
	oDMSBrwStru:LoadData( ZVEIR2QR_Query() )

Return


User Function ZVEIR2PR_Param()

	Local lRet := .T.

	If (lRet := Pergunte('VEIC063',.T.))

		oDMSBrwStru:LoadData( ZVEIR2QR_Query() , .t. )
		oBrwZVEI2:Refresh(.T.)

	EndIf

Return .f.

Static Function ZVEIR2TT_Total()
	Local cQuery := "SELECT SUM(VRK_VALVDA) TOTAL FROM " + oDMSBrwStru:GetRealName()
	M->TOTPERIODO := FM_SQL(cQuery)
Return

Static Function ZVEIR2QR_Query()

	Local cQuery := ""
	Local _MV_PAR01 
	Local _MV_PAR02
	Local _MV_PAR03
	Local _MV_PAR04
	Local _MV_PAR05
	Local _MV_PAR06
	Local _MV_PAR07
/*
	cQuery := ;
		"SELECT 'SIGAVEI' as Origem ," +(Chr(13)+Chr(10))+(Chr(13)+Chr(10))+;
			" VRJ_PEDIDO, VRJ_PEDCOM, VRJ_DATDIG" +(Chr(13)+Chr(10))+(Chr(13)+Chr(10))+;
			", COALESCE( VV3_DESCRI , ' ' ) VV3_DESCRI" +(Chr(13)+Chr(10))+(Chr(13)+Chr(10))+;
			", VRK_CHASSI, VRK_MODVEI "+(Chr(13)+Chr(10))+(Chr(13)+Chr(10))+;
			", VV2_DESMOD" +(Chr(13)+Chr(10))+;
			", VRK_OPCION, COALESCE( RTRIM( VX5OPC.VX5_DESCRI ) , ' ' ) DESCOPCION"+(Chr(13)+Chr(10))+;
			", VRK_COREXT, COALESCE( RTRIM( VX5EXT.VX5_DESCRI ) , ' ' ) DESCCOREXT "+(Chr(13)+Chr(10))+;
			", VRK_CORINT, COALESCE( RTRIM( VX5INT.VX5_DESCRI ) , ' ' ) DESCCORINT "+(Chr(13)+Chr(10))+;
			", VRK_FABMOD" +(Chr(13)+Chr(10))+;
			", F2_SERIE, F2_DOC, F2_EMISSAO, F2_CHVNFE" +(Chr(13)+Chr(10))+;
			", VRK_VALTAB, VRK_VALVDA" +(Chr(13)+Chr(10))+;
			", VRJ_CODVEN" +(Chr(13)+Chr(10))+;
			", COALESCE( A3_NOME , ' ' ) A3_NOME" +(Chr(13)+Chr(10))+;
			", VRJ_CODCLI, VRJ_LOJA, A1_CGC, A1_NOME, A1_NREDUZ" +(Chr(13)+Chr(10))+;
			", CC2_MUN" +(Chr(13)+Chr(10))+;
			", A1_EST" +(Chr(13)+Chr(10))+;
			", VRJ_CLIRET, VRJ_LOJRET" +(Chr(13)+Chr(10))+;
			", VRJ_FORPAG,E4_DESCRI " +(Chr(13)+Chr(10))+;
		" FROM " + RetSQLName("VRJ") + " VRJ " +(Chr(13)+Chr(10))+;
			" JOIN " + RetSQLName("VRK") + " VRK" +(Chr(13)+Chr(10))+;
					"  ON VRK.VRK_FILIAL = '" + FWxFilial("VRK") + "'" +(Chr(13)+Chr(10))+;
					" AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO" +(Chr(13)+Chr(10))+;
					" AND VRK.D_E_L_E_T_ = ' '" +(Chr(13)+Chr(10))+;
			" JOIN " + RetSQLName("VV9") + " VV9" +(Chr(13)+Chr(10))+;
					"  ON VV9.VV9_FILIAL = '" + FWxFilial("VV9") + "'" +(Chr(13)+Chr(10))+;
					" AND VV9.VV9_NUMATE = VRK.VRK_NUMTRA" +(Chr(13)+Chr(10))+;
					" AND VV9.D_E_L_E_T_ = ' '" +(Chr(13)+Chr(10))+;
					" AND VV9.VV9_STATUS IN ('F','T') " +(Chr(13)+Chr(10))+;
			" JOIN " + RetSQLName("VV0") + " VV0" +(Chr(13)+Chr(10))+;
					"  ON VV0.VV0_FILIAL = '" + FWxFilial("VV0") + "'" +(Chr(13)+Chr(10))+;
					" AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE" +(Chr(13)+Chr(10))+;
					" AND VV0.D_E_L_E_T_ = ' '" +(Chr(13)+Chr(10))+;
					" AND VV0.VV0_OPEMOV = '0' " +(Chr(13)+Chr(10))+;
					" AND VV0.VV0_SITNFI = '1' " +(Chr(13)+Chr(10))+;
			" JOIN " + RetSQLName("SF2") + " F2 " +(Chr(13)+Chr(10))+;
					"  ON F2.F2_FILIAL = '" + FWxFilial("SF2") + "'" +(Chr(13)+Chr(10))+;
					" AND F2.F2_DOC = VV0.VV0_NUMNFI" +(Chr(13)+Chr(10))+;
					" AND F2.F2_SERIE = VV0.VV0_SERNFI" +(Chr(13)+Chr(10))+;
					" AND F2.F2_CLIENTE = VV0.VV0_CODCLI" +(Chr(13)+Chr(10))+;
					" AND F2.F2_LOJA = VV0.VV0_LOJA" +(Chr(13)+Chr(10))+;
					" AND F2.D_E_L_E_T_ = ' '" +(Chr(13)+Chr(10))+;
			" JOIN " + RetSQLName("SA1") + " A1" +(Chr(13)+Chr(10))+;
					"  ON A1.A1_FILIAL = '" + FWxFilial("SA1") + "'" +(Chr(13)+Chr(10))+;
					" AND A1.A1_COD = VRJ.VRJ_CODCLI" +(Chr(13)+Chr(10))+;
					" AND A1.A1_LOJA = VRJ.VRJ_LOJA" +(Chr(13)+Chr(10))+;
					" AND A1.D_E_L_E_T_ = ' '" +(Chr(13)+Chr(10))+;
			" LEFT JOIN " + RetSQLName("SA3") + " A3" +(Chr(13)+Chr(10))+;
					"  ON A3.A3_FILIAL = '" + FWxFilial("SA3") + "'" +(Chr(13)+Chr(10))+;
					" AND A3.A3_COD = VRJ.VRJ_CODVEN" +(Chr(13)+Chr(10))+;
					" AND A3.D_E_L_E_T_ = ' '" +(Chr(13)+Chr(10))+;
			" LEFT JOIN " + RetSQLName("CC2") + " CC2" +(Chr(13)+Chr(10))+;
					"  ON CC2.CC2_FILIAL = '" + FWxFilial("CC2") + "'" +(Chr(13)+Chr(10))+;
					" AND CC2.CC2_EST = A1.A1_EST" +(Chr(13)+Chr(10))+;
					" AND CC2.CC2_CODMUN = A1.A1_COD_MUN" +(Chr(13)+Chr(10))+;
					" AND CC2.D_E_L_E_T_ = ' '" +(Chr(13)+Chr(10))+;
			" JOIN " + RetSQLName("VV2") + " VV2" +(Chr(13)+Chr(10))+;
					"  ON VV2.VV2_FILIAL = '" + FWxFilial("VV2") + "'" +(Chr(13)+Chr(10))+;
					" AND VV2.VV2_CODMAR = VRK.VRK_CODMAR" +(Chr(13)+Chr(10))+;
					" AND VV2.VV2_MODVEI = VRK.VRK_MODVEI" +(Chr(13)+Chr(10))+;
					" AND VV2.VV2_SEGMOD = VRK.VRK_SEGMOD" +(Chr(13)+Chr(10))+;
					" AND VV2.D_E_L_E_T_ = ' '" +(Chr(13)+Chr(10))+;
			" LEFT JOIN " + RetSqlName("VX5") + " VX5INT ON VX5INT.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5INT.VX5_CHAVE = '066' AND VX5INT.VX5_CODIGO = VV2.VV2_CORINT AND VX5INT.D_E_L_E_T_ = ' ' " +(Chr(13)+Chr(10))+;
			" LEFT JOIN " + RetSqlName("VX5") + " VX5EXT ON VX5EXT.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5EXT.VX5_CHAVE = '067' AND VX5EXT.VX5_CODIGO = VV2.VV2_COREXT AND VX5EXT.D_E_L_E_T_ = ' ' " +(Chr(13)+Chr(10))+;
			" LEFT JOIN " + RetSqlName("VX5") + " VX5OPC ON VX5OPC.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5OPC.VX5_CHAVE = '068' AND VX5OPC.VX5_CODIGO = VV2.VV2_OPCION AND VX5OPC.D_E_L_E_T_ = ' ' " +(Chr(13)+Chr(10))+;
			" LEFT JOIN " + RetSQLName("VV3") + " VV3" +(Chr(13)+Chr(10))+;
					"  ON VV3.VV3_FILIAL = '" + FWxFilial("VV3") + "'" +(Chr(13)+Chr(10))+;
					" AND VV3.VV3_TIPVEN = VRJ.VRJ_TIPVEN" +(Chr(13)+Chr(10))+;
					" AND VV3.D_E_L_E_T_ = ' '" +(Chr(13)+Chr(10))+;
			" LEFT JOIN " + RetSqlName("SE4") + " SE4 ON SE4.E4_FILIAL = '" + xFilial("SE4") + "' AND SE4.E4_CODIGO = VRJ.VRJ_FORPAG AND SE4.D_E_L_E_T_ = ' ' " +(Chr(13)+Chr(10))+;
		" WHERE VRJ.VRJ_FILIAL = '" + FWxFilial("VRJ") + "'" +(Chr(13)+Chr(10))+;
		  " AND VRJ.VRJ_STATUS <> 'C'" +(Chr(13)+Chr(10))+;
		  " AND VRJ.D_E_L_E_T_ = ' '" +(Chr(13)+Chr(10))+;
		  " AND VRK.VRK_CANCEL IN (' ','0')"
*/
cQuery := ;
		"SELECT  " + CLRF + ;
		"              VRJ_PEDIDO " + CLRF + ;
		"            , VRJ_PEDCOM " + CLRF + ;
		"            , D2_PEDIDO " + CLRF + ;
		"            , VV0.VV0_NUMTRA " + CLRF + ;
		"            , VRJ_DATDIG " + CLRF + ;
		"            , COALESCE( VV3_DESCRI , ' ' ) VV3_DESCRI " + CLRF + ;
		"            , VRK_CHASSI " + CLRF + ;
		"            , VRK_MODVEI  " + CLRF + ;
		"            , VV2_DESMOD " + CLRF + ;
		"            , VRK_OPCION, COALESCE( RTRIM( VX5OPC.VX5_DESCRI ) , ' ' ) DESCOPCION " + CLRF + ;
		"            , VRK_COREXT, COALESCE( RTRIM( VX5EXT.VX5_DESCRI ) , ' ' ) DESCCOREXT  " + CLRF + ;
		"            , VRK_CORINT, COALESCE( RTRIM( VX5INT.VX5_DESCRI ) , ' ' ) DESCCORINT  " + CLRF + ;
		"            , VRK_FABMOD " + CLRF + ;
		"            , F2_SERIE " + CLRF + ;
		"            , F2_DOC " + CLRF + ;
		"            , F2_EMISSAO " + CLRF + ;
		"            , F2_CHVNFE " + CLRF + ;
		"            , VRK_VALTAB " + CLRF + ;
		"            , VRK_VALVDA " + CLRF + ;
		"            , VRJ_CODVEN " + CLRF + ;
		"            , COALESCE( A3_NOME , ' ' ) A3_NOME " + CLRF + ;
		"            , VRJ_CODCLI " + CLRF + ;
		"            , VRJ_LOJA " + CLRF + ;
		"            , A1.A1_CGC " + CLRF + ;
		"            , A1.A1_NOME " + CLRF + ;
		"            , A1.A1_NREDUZ " + CLRF + ;
		"            , CC2_MUN " + CLRF + ;
		"            , A1_EST " + CLRF + ;
		"            , VRJ_CLIRET, VRJ_LOJRET " + CLRF + ;
		"            , VRJ_FORPAG,E4_DESCRI  " + CLRF + ;
		" FROM " + RetSQLName("VRJ") + " VRJ  " + CLRF + ;
		"      " + CLRF + ;
		"     INNER JOIN " + RetSQLName("VRK") + " VRK " + CLRF + ;
		"         ON  VRK.VRK_FILIAL = '" + xFilial("VRK") + "' " + CLRF + ;
		"         AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO " + CLRF + ;
		"         AND VRK.D_E_L_E_T_ = ' ' " + CLRF + ;
		"           " + CLRF + ;
		"     LEFT JOIN " + RetSQLName("VV9") + " VV9 " + CLRF + ;
		"         ON  VV9.VV9_FILIAL = '" + xFilial("VV9") + "' " + CLRF + ;
		"         AND VV9.VV9_NUMATE = VRK.VRK_NUMTRA " + CLRF + ;
		"         AND VV9.D_E_L_E_T_ = ' ' " + CLRF + ;
		"         AND VV9.VV9_STATUS IN ('F','T')  " + CLRF + ;
		"      " + CLRF + ;
		"     LEFT JOIN " + RetSQLName("VV0") + " VV0 " + CLRF + ;
		"         ON  VV0.VV0_FILIAL = '" + xFilial("VV0") + "' " + CLRF + ;
		"         AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE " + CLRF + ;
		"         AND VV0.D_E_L_E_T_ = ' ' " + CLRF + ;
		"         AND VV0.VV0_OPEMOV = '0'  " + CLRF + ;
		"         AND VV0.VV0_SITNFI = '1'  " + CLRF + ;
		"      " + CLRF + ;
		"     LEFT JOIN " + RetSQLName("SF2") + " F2  " + CLRF + ;
		"         ON  F2.F2_FILIAL  = '" + xFilial("SF2") + "' " + CLRF + ;
		"         AND F2.F2_DOC     = VV0.VV0_NUMNFI " + CLRF + ;
		"         AND F2.F2_SERIE   = VV0.VV0_SERNFI " + CLRF + ;
		"         AND F2.F2_CLIENTE = VV0.VV0_CODCLI " + CLRF + ;
		"         AND F2.F2_LOJA    = VV0.VV0_LOJA " + CLRF + ;
		"         AND F2.D_E_L_E_T_ = ' ' " + CLRF + ;
		"      " + CLRF + ;
		"     INNER JOIN " + RetSQLName("SD2") + " SD2 " + CLRF + ;
		"         ON  SD2.D2_FILIAL = '" + xFilial("SD2") + "' " + CLRF + ;
		"         AND SD2.D2_DOC     = F2.F2_DOC " + CLRF + ;
		"         AND SD2.D2_SERIE   = F2.F2_SERIE " + CLRF + ;
		"         AND SD2.D2_CLIENTE = F2.F2_CLIENTE " + CLRF + ;
		"         AND SD2.D2_LOJA    = F2.F2_LOJA " + CLRF + ;
		"         AND SD2.D_E_L_E_T_ = ' ' " + CLRF + ;
		"      " + CLRF + ;
		"     LEFT JOIN " + RetSQLName("SA1") + " A1 " + CLRF + ;
		"         ON  A1.A1_FILIAL  = '" + xFilial("SA1") + "' " + CLRF + ;
		"         AND A1.A1_COD     = VRJ.VRJ_CODCLI " + CLRF + ;
		"         AND A1.A1_LOJA    = VRJ.VRJ_LOJA " + CLRF + ;
		"         AND A1.D_E_L_E_T_ = ' ' " + CLRF + ;
		"      " + CLRF + ;
		"     LEFT JOIN " + RetSQLName("SA3") + " A3 " + CLRF + ;
		"         ON  A3.A3_FILIAL  = '" + xFilial("SA3") + "' " + CLRF + ;
		"         AND A3.A3_COD     = VRJ.VRJ_CODVEN " + CLRF + ;
		"         AND A3.D_E_L_E_T_ = ' ' " + CLRF + ;
		"      " + CLRF + ;
		"     LEFT JOIN " + RetSQLName("CC2") + " CC2 " + CLRF + ;
		"         ON  CC2.CC2_FILIAL = '" + xFilial("CC2") + "' " + CLRF + ;
		"         AND CC2.CC2_EST    = A1.A1_EST " + CLRF + ;
		"         AND CC2.CC2_CODMUN = A1.A1_COD_MUN " + CLRF + ;
		"         AND CC2.D_E_L_E_T_ = ' ' " + CLRF + ;
		"      " + CLRF + ;
		"     JOIN " + RetSQLName("VV2") + " VV2 " + CLRF + ;
		"         ON  VV2.VV2_FILIAL = '" + xFilial("VV2") + "' " + CLRF + ;
		"         AND VV2.VV2_CODMAR = VRK.VRK_CODMAR " + CLRF + ;
		"         AND VV2.VV2_MODVEI = VRK.VRK_MODVEI " + CLRF + ;
		"         AND VV2.VV2_SEGMOD = VRK.VRK_SEGMOD " + CLRF + ;
		"         AND VV2.D_E_L_E_T_ = ' ' " + CLRF + ;
		"          " + CLRF + ;
		"     LEFT JOIN " + RetSQLName("SE4") + " SE4    ON     SE4.E4_FILIAL = '" + xFilial("SE4") + "' AND SE4.E4_CODIGO = VRJ.VRJ_FORPAG AND SE4.D_E_L_E_T_ = ' ' " + CLRF + ;
		"     LEFT JOIN " + RetSQLName("VX5") + " VX5INT ON VX5INT.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5INT.VX5_CHAVE = '066' AND VX5INT.VX5_CODIGO = VV2.VV2_CORINT AND VX5INT.D_E_L_E_T_ = ' '  " + CLRF + ;
		"     LEFT JOIN " + RetSQLName("VX5") + " VX5EXT ON VX5EXT.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5EXT.VX5_CHAVE = '067' AND VX5EXT.VX5_CODIGO = VV2.VV2_COREXT AND VX5EXT.D_E_L_E_T_ = ' '  " + CLRF + ;
		"     LEFT JOIN " + RetSQLName("VX5") + " VX5OPC ON VX5OPC.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5OPC.VX5_CHAVE = '068' AND VX5OPC.VX5_CODIGO = VV2.VV2_OPCION AND VX5OPC.D_E_L_E_T_ = ' '  " + CLRF + ;
		"     LEFT JOIN " + RetSQLName("VV3") + " VV3 " + CLRF + ;
		"         ON  VV3.VV3_FILIAL = '" + xFilial("VV3") + "' " + CLRF + ;
		"         AND VV3.VV3_TIPVEN = VRJ.VRJ_TIPVEN " + CLRF + ;
		"         AND VV3.D_E_L_E_T_ = ' ' " + CLRF + ;
		"       " + CLRF + ;
		"    WHERE VRJ.VRJ_FILIAL = '" + xFilial("VRJ") + "' " + CLRF + ;
		"         AND VRJ.VRJ_STATUS <> 'C' " + CLRF + ;
		"         AND VRJ.D_E_L_E_T_ = ' ' " + CLRF + ;
		"         AND VRK.VRK_CANCEL IN (' ','0')  " + CLRF 


	_MV_PAR01 := MV_PAR01 ; _MV_PAR02 := MV_PAR02 ; _MV_PAR03 := MV_PAR03 ; _MV_PAR04 := MV_PAR04
	_MV_PAR05 := MV_PAR05 ; _MV_PAR06 := MV_PAR06 ; _MV_PAR07 := MV_PAR07

	If !Empty(_MV_PAR01) .AND. !EMPty(_MV_PAR02)
		cQuery += " AND F2.F2_EMISSAO BETWEEN '" + DtoS(_MV_PAR01) + "' AND '" + DtoS(_MV_PAR02) + "' "
	EndIf

	If !Empty(_MV_PAR03)
		cQuery += " AND VRJ.VRJ_CODCLI = '" + _MV_PAR03 + "'"
		If !Empty(MV_PAR04)
			cQuery += " AND VRJ.VRJ_LOJA = '" + _MV_PAR04 + "'"
		EndIf
	EndIf

	If !Empty(_MV_PAR05)
		cQuery += " AND VRJ.VRJ_CODVEN = '" + _MV_PAR05 + "'"
	EndIf

	If !Empty(_MV_PAR06)
		cQuery += " AND VRJ.VRJ_TIPVEN = '" + _MV_PAR06 + "'"
	EndIf

	If lFiltroMarca .and. !Empty(_MV_PAR07)
		cQuery += " AND VRK.VRK_CODMAR = '" + _MV_PAR07 + "' "
	EndIf

	If ( ExistBlock("VC063QRY") )
		cQuery := ExecBlock("VC063QRY",.f.,.f.,{cQuery})
	EndIf
//---------------------------------------------------------------------------------------------------------------------------------------
//Venda de Ativo não precisa neste relatorio
/*
cQuery += "  UNION ALL " + CLRF +;
	" select * from ( " + CLRF + ;
	"     SELECT  " + CLRF + ;
	"         COALESCE( VRK.VRK_PEDIDO , ' ' ) AS VRJ_PEDIDO " + CLRF + ;
	"         ,SC6.C6_PEDCLI  AS VRJ_PEDCOM, " + CLRF + ;
	"         ,SD2.D2_PEDIDO, " + CLRF + ;
	"         ,COALESCE(VV0.VV0_NUMTRA,' ') " + CLRF + ;
	"         ,SC6.C6_ENTREG " + CLRF + ;
	"         ,COALESCE( VV3_DESCRI , ' ' ) VV3_DESCRI " + CLRF + ;
	"         ,SD2.D2_NUMSERI " + CLRF + ;
	"         ,VV1.VV1_MODVEI " + CLRF + ;
	"         ,VV2.VV2_DESMOD " + CLRF + ;
	"         ,VV2.VV2_OPCION " + CLRF + ;
	"         ,COALESCE( RTRIM( VX5OPC.VX5_DESCRI ) , ' ' ) DESCOPCION " + CLRF + ;
	"         ,VV2.VV2_COREXT " + CLRF + ;
	"         ,COALESCE( RTRIM( VX5EXT.VX5_DESCRI ) , ' ' ) DESCCOREXT " + CLRF + ;
	"         ,VV2.VV2_CORINT " + CLRF + ;
	"         ,COALESCE( RTRIM( VX5INT.VX5_DESCRI ) , ' ' ) DESCCORINT " + CLRF + ;
	"         ,VV1.VV1_FABMOD " + CLRF + ;
	"         ,SF2.F2_SERIE " + CLRF + ;
	"         ,SF2.F2_DOC " + CLRF + ;
	"         ,SF2.F2_EMISSAO " + CLRF + ;
	"         ,SF2.F2_CHVNFE " + CLRF + ;
	"         ,SC6.C6_XPRCTAB " + CLRF + ;
	"         ,SC6.C6_XVLRVDA " + CLRF + ;
	"         ,SC5.C5_VEND1 " + CLRF + ;
	"         ,COALESCE( SA3.A3_NOME , ' ' ) A3_NOME " + CLRF + ;
	"         ,SD2.D2_CLIENTE " + CLRF + ;
	"         ,SD2.D2_LOJA " + CLRF + ;
	"         ,SA1.A1_CGC " + CLRF + ;
	"         ,SA1.A1_NOME " + CLRF + ;
	"         ,SA1.A1_NREDUZ " + CLRF + ;
	"         ,CC2.CC2_MUN " + CLRF + ;
	"         ,SA1.A1_EST " + CLRF + ;
	"         ,SF2.F2_CLIRET " + CLRF + ;
	"         ,SF2.F2_LOJARET " + CLRF + ;
	"         ,SF2.F2_COND " + CLRF + ;
	"         ,SE4.E4_DESCRI " + CLRF + ;
	"     FROM  " + RetSQLName("SD2") + " SD2 " + CLRF + ;
	"     INNER JOIN " + RetSQLName("SF2") + " SF2  " + CLRF + ;
	"         ON  SF2.F2_FILIAL = '" + xFilial("SF2") + "' " + CLRF + ;
	"         AND SF2.F2_DOC     = SD2.D2_DOC " + CLRF + ;
	"         AND SF2.F2_SERIE   = SD2.D2_SERIE   " + CLRF + ;
	"         AND SF2.D_E_L_E_T_ = ' ' " + CLRF + ;
	"     INNER JOIN " + RetSQLName("SC5") + " SC5   " + CLRF + ;
	"         ON  SC5.C5_FILIAL  = '" + xFilial("SC5") + "' " + CLRF + ;
	"         AND SC5.C5_NUM     = SD2.D2_PEDIDO " + CLRF + ;
	"         AND SC5.D_E_L_E_T_ = ' ' " + CLRF + ;
	"     INNER JOIN " + RetSQLName("SC6") + " SC6   " + CLRF + ;
	" 	 	  ON  SC6.C6_FILIAL  = '" + xFilial("SC6") + "' " + CLRF + ;
	"         AND SC6.C6_NUM     = SD2.D2_PEDIDO " + CLRF + ;
	"         AND SC6.C6_ITEM    = SD2.D2_ITEMPV" + CLRF + ;
	"         AND SC6.D_E_L_E_T_ = ' ' " + CLRF + ;
	"     INNER JOIN " + RetSQLName("SA1") + " SA1 " + CLRF + ;
	" 	      ON  SA1.A1_FILIAL  = '" + xFilial("SA1") + "' " + CLRF + ;
	"         AND SA1.A1_COD     = SD2.D2_CLIENTE " + CLRF + ;
	"         AND SA1.A1_LOJA    = SD2.D2_LOJA " + CLRF + ;
	"         AND SA1.D_E_L_E_T_ = ' ' " + CLRF + ;
	"     LEFT JOIN " + RetSQLName("CC2") + " CC2   " + CLRF + ;
	"         ON  CC2.CC2_FILIAL  = '" + xFilial("CC2") + "' " + CLRF + ;
	"         AND CC2.CC2_EST     = SA1.A1_EST  " + CLRF + ;
	"         AND CC2.CC2_CODMUN  = SA1.A1_COD_MUN  " + CLRF + ;
	"         AND CC2.D_E_L_E_T_  = ' ' " + CLRF + ;
	"     LEFT JOIN " + RetSQLName("VV0") + " VV0 " + CLRF + ;
	"         ON  VV0.VV0_FILIAL = '" + xFilial("VV0") + "' " + CLRF + ;
	"         AND VV0.VV0_NUMNFI = SF2.F2_DOC " + CLRF + ;
	"         AND VV0.VV0_SERNFI = SF2.F2_SERIE " + CLRF + ;
	"         AND VV0.VV0_CODCLI = SF2.F2_CLIENTE " + CLRF + ;
	"         AND VV0.VV0_LOJA   = SF2.F2_LOJA  " + CLRF + ;
	"         AND VV0.D_E_L_E_T_ = ' ' " + CLRF + ;
	"     LEFT JOIN " + RetSQLName("VV1") + "  VV1  " + CLRF + ;
	" 	  	  ON  VV1.VV1_FILIAL = '" + xFilial("VV1") + "' " + CLRF + ;
	"         AND VV1.VV1_CHASSI = SD2.D2_NUMSERI " + CLRF + ;
	"         AND VV1.D_E_L_E_T_ = ' ' " + CLRF + ;
	"     LEFT JOIN " + RetSQLName("VV2") + " VV2   " + CLRF + ;
	"         ON  VV2.VV2_FILIAL  = '" + xFilial("VV2") + "' " + CLRF + ;
	"         AND VV2.VV2_CODMAR  = VV1.VV1_CODMAR   " + CLRF + ;
	"         AND VV2.VV2_MODVEI  = VV1.VV1_MODVEI  " + CLRF + ;
	"         AND VV2.VV2_SEGMOD  = VV1.VV1_SEGMOD  " + CLRF + ;
	"         AND VV2.D_E_L_E_T_  = ' ' " + CLRF + ;
	"     LEFT JOIN " + RetSQLName("VRK") + " VRK " + CLRF + ;
	"         ON  VRK.VRK_FILIAL  = '" + xFilial("VRK") + "' " + CLRF + ;
	"         AND VRK.VRK_NUMTRA = VV0.VV0_NUMTRA " + CLRF + ;
	"         AND VRK.D_E_L_E_T_ = ' ' " + CLRF + ;
	"     LEFT JOIN " + RetSQLName("VV3") + " VV3    ON    VV3.VV3_FILIAL = '" + xFilial("VV3") + "' AND    VV3.VV3_TIPVEN = SC5.C5_XTIPVEN AND    VV3.D_E_L_E_T_ = ' ' " + CLRF + ;
	"     LEFT JOIN " + RetSQLName("SE4") + " SE4    ON    SE4.E4_FILIAL  = '" + xFilial("SE4") + "' AND    SE4.E4_CODIGO  = SF2.F2_COND    AND    SE4.D_E_L_E_T_ = ' ' " + CLRF + ;
	"     LEFT JOIN " + RetSQLName("SA3") + " SA3    ON    SA3.A3_FILIAL  = '" + xFilial("SA3") + "' AND    SA3.A3_COD     = SC5.C5_VEND1   AND    SA3.D_E_L_E_T_ = ' ' " + CLRF + ;
	"     LEFT JOIN " + RetSQLName("VX5") + " VX5INT ON VX5INT.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5INT.VX5_CODIGO = VV2.VV2_CORINT AND VX5INT.D_E_L_E_T_ = ' ' AND VX5INT.VX5_CHAVE  = '066'  " + CLRF + ;
	"     LEFT JOIN " + RetSQLName("VX5") + " VX5EXT ON VX5EXT.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5EXT.VX5_CODIGO = VV2.VV2_COREXT AND VX5EXT.D_E_L_E_T_ = ' ' AND VX5EXT.VX5_CHAVE  = '067'  " + CLRF + ;
	"     LEFT JOIN " + RetSQLName("VX5") + " VX5OPC ON VX5OPC.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5OPC.VX5_CODIGO = VV2.VV2_OPCION AND VX5OPC.D_E_L_E_T_ = ' ' AND VX5OPC.VX5_CHAVE  = '068'  " + CLRF + ;
	"     WHERE   SD2.D2_FILIAL  = '" + xFilial("SD2") + "' " + CLRF + ;
	"         AND SD2.D_E_L_E_T_ = ' '   " + CLRF + ;
	"         AND SD2.D2_NUMSERI <> ' ' " + CLRF + ;
	"     )  trb  " + CLRF + ;
	" WHERE VRJ_PEDIDO = ' ' " 
	

	If !Empty(_MV_PAR01) .AND. !EMPty(_MV_PAR02)
		cQuery += " AND F2.F2_EMISSAO BETWEEN '" + DtoS(_MV_PAR01) + "' AND '" + DtoS(_MV_PAR02) + "' "
	EndIf

	If !Empty(_MV_PAR03)
		cQuery += " AND SD2.D2_CLIENTE = '" + _MV_PAR03 + "'"
		If !Empty(MV_PAR04)
			cQuery += " AND SD2.D2_LOJA = '" + _MV_PAR04 + "'"
		EndIf
	EndIf

	If !Empty(_MV_PAR05)
		cQuery += " AND SC5.C5_VEND1 = '" + _MV_PAR05 + "'"
	EndIf

	If !Empty(_MV_PAR06)
		cQuery += " AND SC5.C5_XTIPVEN = '" + _MV_PAR06 + "'"
	EndIf

	If lFiltroMarca .and. !Empty(_MV_PAR07)
		cQuery += " AND SC6.C6_XCODMAR = '" + _MV_PAR07 + "'"
	EndIf

	If ( ExistBlock("VC063QRY") )
		cQuery := ExecBlock("VC063QRY",.f.,.f.,{cQuery})
	EndIf
*/


Return cQuery

Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina TITLE "Parâmetros"     ACTION 'U_ZVEIR2PR_Param' OPERATION 3 ACCESS 0 // 'Parâmetros'
	ADD OPTION aRotina TITLE "Gerar Planilha" ACTION 'U_ZVEIR2PO'       OPERATION 2 ACCESS 0 // 'Gerar Planilha'

Return aRotina

User Function ZVEIR2PO()
	Processa( {|| U_ZVEIR2PE_PlanilhaEstoque()  }, "Gerando Planilha...", OemToAnsi("Lendo dados do arquivo..."),.F.)
Return

User Function ZVEIR2PE_PlanilhaEstoque()

	Local oExcel
	Local aAuxLinha
	Local nQtdCol
	Local nLoopRec
	Local nPosCol
	Local lTotalizar
	Local cTipo
	Local cSheet := "Faturamento"
	Local cTable := "Fatureamento - Caoa"
	If oBrwZVEI2:LogicLen() <= 0
		Return .t.
	EndIf

	Pergunte("VEIC063IMP",.t.)

	oExcel := FWMSEXCEL():New()
	oExcel:AddworkSheet(cSheet)
	oExcel:AddTable(cSheet,cTable)

	nQtdCol := Len(oBrwZVEI2:aColumns)

	For nPosCol := 1 to nQtdCol

		lTotalizar := (oBrwZVEI2:GetColumn(nPosCol):GetID() $ "VRK_VALVDA")
		cTipo      := oBrwZVEI2:GetColumn(nPosCol):GetType()

		oExcel:AddColumn( ;
						cSheet, ;
						cTable , ;
						oBrwZVEI2:GetColumn(nPosCol):GetTitle() , ;
						IIf( cTipo == "N" , 3 , 1 ) , ; // Alinhamento da coluna ( 1-Left,2-Center,3-Right )
						IIf( oBrwZVEI2:GetColumn(nPosCol):GetID() $ "VRK_VALVDA/VRK_VALTAB" , 2 , ( IIf(cTipo == "N" , 2 , 1 ) ) ) , ; // Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
						lTotalizar )
	Next nPosCol

	oBrwZVEI2:GoTop()
	nUlRec := oBrwZVEI2:LogicLen()
	nCurrRec := oBrwZVEI2:At()
	ProcRegua(1000)
	nX := 0
	nY := 0
	While .T.
		nLoopRec := oBrwZVEI2:At()

		aAuxLinha := Array(nQtdCol)
		
		For nPosCol := 1 to nQtdCol
			cIdField := oBrwZVEI2:GetColumn(nPosCol):GetID()

			Do Case
				Case cIdField $ "VRK_VALVDA/VRK_VALTAB"
					aAuxLinha[nPosCol] := val(strtran(strtran(oBrwZVEI2:GetColumnData(nPosCol),".",""),",","."))
				Otherwise
					aAuxLinha[nPosCol] := AllTrim(oBrwZVEI2:GetColumnData(nPosCol))
			End Case

		Next nPosCol

		oExcel:AddRow(cSheet ,cTable,aAuxLinha) // Peças / Peças
		nX++
		nY++
		oBrwZVEI2:GoDown()
		IncProc("Lendo Registo " +cValToChar(nX) + " aguade..." )
		If nLoopRec == oBrwZVEI2:At()
			Exit
		EndIf
		if nY >=1000
			ProcRegua(1000)
			nY := 0
		endif
	EndDo

	oExcel:Activate()

	oExcel:GetXMLFile(AllTrim(MV_PAR01))
	oExcel:DeActivate()

	oBrwZVEI2:GoTo( nCurrRec, .T. )

	MsgInfo("Arquivo Gerado")

Return
