#INCLUDE "PROTHEUS.CH"

#DEFINE	UNITZ	1
#DEFINE	ARMAZ	2
#DEFINE	ENDER	3
#DEFINE	PRDORI	4
#DEFINE	CODPRO	5
#DEFINE	LOTECT	6
#DEFINE	NUMLOT	7
#DEFINE	QUANT	8
#DEFINE	DOCTO	9
#DEFINE	SERIE	10
#DEFINE	CLIFOR	11
#DEFINE	LOJA	12
#DEFINE	SERVIC	13
#DEFINE	NUMSEQ	14

/*
================================================================================
Programa.:              ZWMSF004
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Recebimento automatico no Wms de itens de importação     
================================================================================
*/
User Function ZWMSF004()
	Local lJobAtivo	:= GetNewPar( "CMV_WMS012", .F. )
	
	If IsBlind()
		Conout( "Chamada Job ZWMSF004 | " + Time() )
		If lJobAtivo
			cTmpInv	:= "TMP"

			//--Monta temporaria
			zTmpInv(.T.)

			If ( Select(cTmpInv) <> 0 )

				cTmpMnt	:= "TMP_MNT"
				(cTmpInv)->( DbGoTop() )
				While (cTmpInv)->( !Eof() )
					
					ProcUnit(.T.)

					(cTmpInv)->( DbSkip() )
				EndDo

			EndIf
		EndIf

	Else
		If Pergunte('ZWMSF004',.T.)
			FWMsgRun( ,{|| TelaInv() } ,"Carregando invoices..." ,"Por favor aguarde...")
		EndIf
	EndIf

Return

/*
=================================================================================
Programa.:              TelaInv
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Monta tela com invoices que contenham unitizadores
						pendentes de montagem no WMS           
=================================================================================
*/
Static Function TelaInv()
    Local aSeek         := {}
    Local afields       := {}
    Local aFieFilter    := {}

	Private oBrowse 	:= Nil
	Private cTmpInv		:= "TMP"
	Private cTmpMnt		:= "TMP_MNT"

	//--Monta temporaria
	zTmpInv()

	If Select( cTmpInv ) > 0

		(cTmpInv)->(DbGoTop())
		If (cTmpInv)->(!Eof())
			
			//Criação da pesquisa apresentada no browse
			aAdd(aSeek  ,{"Processo" 		,{{ ""  ,"C"    ,TamSX3("W9_HAWB")[1]		,0  ,"Processo" ,"@!"   }},1 } )
			aAdd(aSeek  ,{"Invoice" 		,{{ ""  ,"C"    ,TamSX3("W9_INVOICE")[1]   	,0  ,"Invoice" 	,"@!"   }},2 } )

			aAdd(aFieFilter    ,{"Invoice"    	,"Invoice"			,"C"  ,TamSX3("W9_INVOICE")[1]  ,0 ,"@!" })
			aAdd(aFieFilter    ,{"Dt_Emis"  	,"Dt_Emis"          ,"D"  ,TamSX3("W9_DT_EMIS")[1]  ,0 ,"@!" })
			aAdd(aFieFilter    ,{"Processo"  	,"Processo"         ,"C"  ,TamSX3("W9_HAWB")[1]     ,0 ,"@!" })
			aAdd(aFieFilter    ,{"House" 		,"House"			,"C"  ,TamSX3("W6_HOUSE")[1]  	,0 ,"@!" })
			aAdd(aFieFilter    ,{"Fornecedor"   ,"Fornecedor"		,"C"  ,TamSX3("W9_FORN")[1]    	,0 ,"@!" })
			aAdd(aFieFilter    ,{"Loja"  		,"Loja"				,"C"  ,TamSX3("W9_FORLOJ")[1]  	,0 ,"@!" })
			aAdd(aFieFilter    ,{"Nom_For" 		,"Nom_For"			,"C"  ,TamSX3("W9_NOM_FOR")[1]  ,0 ,"@!" })

			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias(cTmpInv)
			oBrowse:SetMenuDef("")
			oBrowse:SetDescription("Caoa - Montagem de unitizador")
			oBrowse:AddButton("Endereçar"	,{ || FWMsgRun( ,{|| TelaUnit(3), zAtuBrw() } ,"Carregando unitizadores..." ,"Por favor aguarde...")	})
			oBrowse:AddButton("Visualizar"	,{ || FWMsgRun( ,{|| TelaUnit(2) } ,"Carregando unitizadores..." ,"Por favor aguarde...")	})
			oBrowse:AddButton("Relatorio de Conferencia", { || zRelF016()	})
			oBrowse:AddButton("Gerar Demanda de Unitizacao", { || zGeraD0Q(), zAtuBrw()	})
			oBrowse:AddLegend("!Empty( (cTmpInv)->MsgErro )"		,"RED"   	,"Erro na unitizacao")
			oBrowse:AddLegend("(cTmpInv)->( Qtd - QtdUni ) <> 0"	,"YELLOW"   ,"Pendente")
			oBrowse:AddLegend("(cTmpInv)->( Qtd - QtdUni ) == 0"	,"GREEN"   	,"Finalizado")
            oBrowse:SetAmbiente(.T.)
            oBrowse:SetTemporary()
            oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
            oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
            oBrowse:SetFieldFilter(aFieFilter)
            oBrowse:DisableReport()
            oBrowse:DisableDetails()

			aAdd(afields    ,{"Filial"    		,"Filial"		,"C"  ,030	,0 ,"@!" })
			aAdd(afields    ,{"% Classificação" ,"Percentual"	,"C"  ,004	,0 ,"@!" })
			aAdd(afields    ,{"Invoice"			,"Invoice"		,"C"  ,030	,0 ,"@!" })
			aAdd(afields    ,{"Dt Emissao"  	,"Dt_Emis"		,"D"  ,008	,0 ,"@!" })
			aAdd(afields    ,{"Processo"		,"Processo"		,"C"  ,030	,0 ,"@!" })
			aAdd(afields    ,{"House"			,"House"		,"C"  ,018	,0 ,"@!" })
			aAdd(afields    ,{"Fornecedor"		,"Fornecedor"	,"C"  ,006	,0 ,"@!" })
			aAdd(afields    ,{"Loja"			,"Loja"			,"C"  ,002	,0 ,"@!" })
			aAdd(afields    ,{"Nome Fornecedor"	,"Nom_For"		,"C"  ,020	,0 ,"@!" })

			oBrowse:SetFields(afields) 

			oBrowse:Activate()

		EndIf
		
		(cTmpInv)->(DbCloseArea())

	Else
		MsgAlert("Não foram encontrados registros para os parametros informados!")
    EndIf
  
    If ( Select(cTmpMnt) <> 0 )
        dbSelectArea(cTmpMnt)
        (cTmpMnt)->(dbCloseArea())
    EndIf

Return

/*
========================================================================================
Programa.:              TelaUnit
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:  	Tela de visualização e processamento da montagem de unitizadores    
========================================================================================
*/
Static Function TelaUnit(nOpc)
    Local aSeek         := {}
    Local afields       := {}
    Local aFieFilter    := {}
	Local lJobAtivo		:= GetNewPar( "CMV_WMS012", .F. )
	Local aCoors 		:= FWGetDialogSize( oMainWnd )
	Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseLeft, oBrowseRight, oRelacZA4, oRelacZA5

	Default nOpc := 3

	Private aColsUnit 	:= {}
	Private oDlg, oBrowseUp
	
	If (cTmpInv)->(Qtd-QtdUni) == 0 .And. nOpc == 3
		MsgAlert("Este registro esta finalizado, selecione um registro pendente para montagem de unitizador!")
		Return
	EndIf 	

	If (cTmpInv)->Percentual <> "100%" .And. nOpc == 3
		MsgAlert("Só é possivel a montagem de unitizador, quando a invoice estiver 100% classificada!")
		Return
	EndIf

	If lJobAtivo .And. nOpc == 3
		MsgAlert("Este botão esta desabilitado porque o processamento via Job esta ativo, " + CRLF +;
				 "solicite ao administrador do sistema a parada do Job para habilitar o processamento" )
		Return
	EndIf

	Define MsDialog oDlg Title 'Montagem de unitizadores' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	//-- Cria o conteiner onde serão colocados os browses	
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg, .F., .T. )

	//-- Define Painel Superior
	oFWLayer:AddLine( 'UP', 50, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
	
	//-- Define Painel inferior
	oFWLayer:AddLine( 'DOWN', 50, .F. )
	oFWLayer:AddCollumn( 'LEFT' , 50, .T., 'DOWN' )
	oFWLayer:AddCollumn( 'RIGHT', 50, .T., 'DOWN' )
	oPanelLeft	:= oFWLayer:GetColPanel( 'LEFT' , 'DOWN' )
	oPanelRight := oFWLayer:GetColPanel( 'RIGHT', 'DOWN' )

	//--Monta temporaria
	zTmpMnt()

	If (Select(cTmpMnt) <> 0)
		
		(cTmpMnt)->(DbGoTop())
		If (cTmpMnt)->(!Eof())

			//Criação da pesquisa apresentada no browse
			aAdd(aSeek  ,{"Invoice" 		,{{ ""  ,"C"    ,TamSX3("WN_INVOICE")[1]        ,0  ,"Invoice" 		,"@!"   }},1 } )
			aAdd(aSeek  ,{"Container" 		,{{ ""  ,"C"    ,TamSX3("WN_XCONT")[1]        	,0  ,"Container" 	,"@!"   }},2 } )
			aAdd(aSeek  ,{"Unitizador" 		,{{ ""  ,"C"    ,TamSX3("WN_XLOTE")[1]        	,0  ,"Unitizador" 	,"@!"   }},3 } )

			aAdd(aFieFilter    ,{"Filial"		,"Filial"			,"C"  ,TamSX3("WN_FILIAL")[1]  	,0 ,"@!" })
			aAdd(aFieFilter    ,{"Invoice"    	,"Invoice"			,"C"  ,TamSX3("WN_INVOICE")[1]  ,0 ,"@!" })
			aAdd(aFieFilter    ,{"Container"  	,"Container"        ,"C"  ,TamSX3("WN_XCONT")[1]  	,0 ,"@!" })
			aAdd(aFieFilter    ,{"Unitizador"  	,"Unitizador"       ,"C"  ,TamSX3("WN_XLOTE")[1]    ,0 ,"@!" })

			oBrowseUp := FWMBrowse():New()
			oBrowseUp:SetOwner( oPanelUp )
			oBrowseUp:SetAlias(cTmpMnt)
			oBrowseUp:SetMenuDef("")
			oBrowseUp:SetDescription("Containers")
			oBrowseUp:SetFixedBrowse(.T.)
			oBrowseUp:AddLegend("!Empty( (cTmpMnt)->MsgErro )"			,"RED"   	,"Erro na unitizacao")
			oBrowseUp:AddLegend("(cTmpMnt)->( Qtd - QtdUnitiz ) <> 0"	,"YELLOW"   ,"Pendente")
			oBrowseUp:AddLegend("(cTmpMnt)->( Qtd - QtdUnitiz ) == 0"	,"GREEN"   	,"Finalizado")
			If nOpc == 3
				oBrowseUp:AddButton("Executar"		, { || Processa({|| ProcUnit() ,zForceAtu() }	,"Montagem dos unitizadores..."	)})
			EndIf
			oBrowseUp:AddButton("Visualizar Itens"	,;
								{ || FWMsgRun( ,{|| RetItens((cTmpMnt)->Invoice, (cTmpMnt)->Container, (cTmpMnt)->Unitizador) } ,;
								"Carregando itens..." ,"Por favor aguarde..." )	} )
			oBrowseUp:AddButton("Fechar"			, { || oDlg:End() })
			oBrowseUp:SetAmbiente(.T.)
			oBrowseUp:SetTemporary()
			oBrowseUp:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
			oBrowseUp:SetFilterDefault("") //Indica o filtro padrão do Browse
			oBrowseUp:SetFieldFilter(aFieFilter)
			oBrowseUp:SetProfileID( '1' )
			oBrowseUp:DisableReport()
			oBrowseUp:DisableDetails()

			aAdd(afields    ,{"Filial"    			,"Filial"		,"C"  ,010	,0 ,"@!" })
			aAdd(afields    ,{"Invoice"    			,"Invoice"		,"C"  ,030	,0 ,"@!" })
			aAdd(afields    ,{"Container"   		,"Container"	,"C"  ,020	,0 ,"@!" })
			aAdd(afields    ,{"Unitizador"  		,"Unitizador"	,"C"  ,040	,0 ,"@!" })
			aAdd(afields    ,{"Qtd por Unitz"		,"Qtd"			,"N"  ,013	,0 ,	 })
			aAdd(afields    ,{"Qtd Classificada"	,"QtdClas"		,"N"  ,013	,0 ,	 })
			aAdd(afields    ,{"Qtd Unitizada"		,"QtdUnitiz"	,"N"  ,012	,0 ,	 })

			oBrowseUp:SetFields(afields)
			
			oBrowseUp:Activate()

		EndIf

	EndIf

	//-- Lado Esquerdo
	oBrowseLeft:= FWMBrowse():New()
	oBrowseLeft:SetOwner( oPanelLeft )
	oBrowseLeft:SetDescription("Unitizadores") // 
	oBrowseLeft:SetMenuDef( '' )
	oBrowseLeft:DisableReport()
	oBrowseLeft:DisableDetails()
	oBrowseLeft:SetAlias('D0R')
	oBrowseLeft:SetProfileID( '2' )
	oBrowseLeft:Activate()

	// Lado Direito
	oBrowseRight:= FWMBrowse():New()
	oBrowseRight:SetOwner( oPanelRight )
	oBrowseRight:SetDescription("Itens do Unitizador")
	oBrowseRight:SetMenuDef( '' )
	oBrowseRight:DisableReport()
	oBrowseRight:DisableDetails()
	oBrowseRight:SetAlias('D0S')
	oBrowseRight:SetProfileID( '3' )
	oBrowseRight:Activate()
	
	//-- Relacionamento entre os Paineis
	oRelacZA4:= FWBrwRelation():New()
	oRelacZA4:AddRelation( oBrowseUp , oBrowseLeft , 	{;
														{"D0R_FILIAL", 'xFilial("D0R")'},;
														{"D0R_IDUNIT","(cTmpMnt)->Unitizador"};
														}	)
	oRelacZA4:Activate()

	oRelacZA5:= FWBrwRelation():New()
	oRelacZA5:AddRelation( oBrowseLeft, oBrowseRight, 	{;
														{"D0S_FILIAL",'xFilial("D0S")'},;
														{"D0S_IDUNIT","D0R_IDUNIT"};
														}	)
	oRelacZA5:Activate()

	Activate MsDialog oDlg Center

Return

/*
========================================================================================
Programa.:              ProcUnit
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Processamento dos itens do browse para montagem dos unitizadores       
========================================================================================
*/
Static Function ProcUnit(lJob)
	Local aItens 	:= {}
	Local aUnitz	:= {}
	Local cUpdate	:= ""
	Local bError
	Local oError
	Local aPergs 	:= {}
	Local aRet		:= {}

	Private	cArmDes	:= ""
	Private cEndDes	:= ""
	Private __cErro	:= ""
	Private lErro	:= .F.

	Default lJob	:= .F.

    aAdd(aPergs, {1 ,"Armazem Destino"  ,"907"								,""	  ,"" ,"" ,"" ,0  ,.T. })
    aAdd(aPergs, {1 ,"Endereço Destino" ,Space( TamSX3('BE_LOCALIZ')[1] )	,"@!" ,"" ,"" ,"" ,60 ,.T. })

	//-- Salva estado dos parâmetros porque o parambox ira sobrescrever e isso afeta o browse da rotina
	SaveInter() 

	If ParamBox( aPergs ,"Parametros de execução" ,@aRet )

		cArmDes	:= AllTrim( aRet[1] ) 
		cEndDes	:= AllTrim( aRet[2] )

		//--Monta temporaria e remove itens finalizados
		zTmpMnt(.T.)

		If ( Select(cTmpMnt) <> 0 )
		
			If !lJob
				//-- Seta o tamanho da régua
				ProcRegua( (cTmpMnt)->( RecCount() ) )
			EndIf

			(cTmpMnt)->(DbGoTop())
			While (cTmpMnt)->(!Eof())

				//-- Verifica se o unitizador ja foi processado
				If !( aScan( aUnitz , (cTmpMnt)->Unitizador ) > 0 )

					If (cTmpMnt)->Qtd <> (cTmpMnt)->QtdUnitiz
						
						//-- Guarda unitizador para validar se ja foi processado
						Aadd( aUnitz, (cTmpMnt)->Unitizador )

						aItens 	:= CargaUnit( (cTmpMnt)->Invoice, (cTmpMnt)->Container, (cTmpMnt)->Unitizador )

						//--Faço a limpeza do erro para novo processamento
						cUpdate :=  " UPDATE " + RetSqlName("SWN")              	+ CRLF
						cUpdate	+=  " SET WN_XLOGERR = ''"         					+ CRLF
						cUpdate +=  " WHERE WN_FILIAL = '" + FWxFilial("SWN") + "'"	+ CRLF    
						cUpdate +=  " AND WN_XLOTE = '" + aItens[1][UNITZ] + "'"    + CRLF
						cUpdate +=  " AND D_E_L_E_T_ = ' ' "                        + CRLF

						If TcSqlExec(cUpdate) < 0
							Help( ,, "Caoa",, TcSqlError() , 1, 0)
						EndIf

						bError := ErrorBlock( { |oError| GrvErro( oError ) } )
						Begin Sequence
							
							If Len( aItens ) > 0
								
								If !lJob
									//-- Incrementa a mensagem na régua.
									IncProc("Processando a montagem do unitizador: " + AllTrim(aItens[1][UNITZ]) )
								EndIf

								If !( MontaUnit(aItens) )
									
									//--Tratamento pra evitar erro na função utl_raw.cast_to_raw que suporta no maximo 2000 caracteres
									If Len( __cErro ) > 2000
										__cErro := SubStr(__cErro, 1, 2000)
									EndIf

									//--Grava log de erro
									cUpdate :=  " UPDATE " + RetSqlName("SWN")              				+ CRLF
									cUpdate	+=  " SET WN_XLOGERR = utl_raw.cast_to_raw('" + __cErro + "') "	+ CRLF
									cUpdate +=  " WHERE WN_FILIAL = '" + FWxFilial("SWN") + "'"				+ CRLF    
									cUpdate +=  " AND WN_XLOTE = '" + aItens[1][UNITZ] + "'"     			+ CRLF
									cUpdate +=  " AND D_E_L_E_T_ = ' ' "                        			+ CRLF

									If TcSqlExec(cUpdate) < 0
										Help( ,, "Caoa",, TcSqlError() , 1, 0)
									EndIf
								EndIf

							EndIf

						Recover

							If !Empty(__cErro)
								
								//--Tratamento pra evitar erro na função utl_raw.cast_to_raw que suporta no maximo 2000 caracteres
								If Len( __cErro ) > 2000
									__cErro := SubStr(__cErro, 1, 2000)
								EndIf

								//--Grava log de erro
								cUpdate :=  " UPDATE " + RetSqlName("SWN")              				+ CRLF
								cUpdate	+=  " SET WN_XLOGERR = utl_raw.cast_to_raw('" + __cErro + "') "	+ CRLF
								cUpdate +=  " WHERE WN_FILIAL = '" + FWxFilial("SWN") + "'"				+ CRLF    
								cUpdate +=  " AND WN_XLOTE = '" + aItens[1][UNITZ] + "'"     			+ CRLF
								cUpdate +=  " AND D_E_L_E_T_ = ' ' "                        			+ CRLF

								If TcSqlExec(cUpdate) < 0
									Help( ,, "Caoa",, TcSqlError() , 1, 0)
								EndIf
							EndIf

						End Sequence

						//Restaurando bloco de erro do sistema
						ErrorBlock(bError)
							
					EndIf

				EndIf

				(cTmpMnt)->( DbSkip() )

			EndDo

		Else
			If !lJob
				MsgAlert("Não ha registros disponiveis para processamento, todos os registros estão finalizados!")
			EndIf	
		EndIf

	EndIf

	RestInter() //-- Restaura estado dos parâmetros

Return

/*
=====================================================================================
Programa.:              MontaUnit
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Montagem dos unitizadores         
=====================================================================================
*/
Static Function MontaUnit(aItens)
	Local cArmazem  := aItens[1][ARMAZ]
	Local cEndereco := aItens[1][ENDER]
	Local lRet      := .T.
	Local cOrigem   := "SD1"	//-- A origem sempre é a NF de entrada
	Local cTipUni	:= "000002" //-- Tipo de unitizador CASE, sempre usado neste processo

	Private oMntUniItem 	:= ZWMSF008():New()

	oMntUniItem:ClearData()
	oMntUniItem:oUnitiz:SetOrigem(cOrigem)
	oMntUniItem:oUnitiz:SetArmazem(cArmazem)
	oMntUniItem:oUnitiz:SetEnder(cEndereco)

	oMntUniItem:SetIdUnit("")

	// Limpa o serviço para permitir montar unitizadores diferentes com serviços diferentes
	oMntUniItem:oUnitiz:SetServico("")

	If Empty(oMntUniItem:oUnitiz:oTipUnit:GetTipUni())
		oMntUniItem:oUnitiz:oTipUnit:FindPadrao()
	EndIf

	oMntUniItem:oUnitiz:SetStatus("1") // Em Montagem
	oMntUniItem:oUnitiz:SetTipUni(cTipUni)
	oMntUniItem:oUnitiz:SetDatIni(dDataBase)
	oMntUniItem:oUnitiz:SetHorIni(Time())
	oMntUniItem:oUnitiz:SetDatFim(StoD(""))
	oMntUniItem:oUnitiz:SetHorFim("")

	WMSCTPENDU() // Cria as temporárias - FORA DA TRANSAÇÃO
	WMSCTPRGCV() // Cria tabela temporária - Convocação

	Begin Transaction

		If lRet :=	VldArmazem(cArmazem)

			If lRet :=	VldEndOrig(cArmazem,cEndereco)
					
				If lRet :=	VldIdUnit(aItens[1][UNITZ],cTipUni,.F.)

					//--Automatiza a montagem dos unitizadores
					lRet := GerUniAuto(aItens)

				EndIf

			EndIf

		EndIf

		If !lRet .Or. lErro
			DisarmTransaction()
		EndIf

	End Transaction

	WMSDTPRGCV() // Destroy tabela temporária - convocação
	WMSDTPENDU() // Destroy as temporárias - FORA DA TRANSAÇÃO
	oMntUniItem:Destroy()

	If lErro
		//--Retorna ao ponto de recover
		BREAK
	EndIf

Return lRet

/*
=====================================================================================
Programa.:              VldArmazem
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Valida armazem          
=====================================================================================
*/
Static Function VldArmazem(cArmazem)
	Local lRet      := .T.
	Local cAliasQry := Nil

	If Empty(cArmazem)
		Return .F.
	EndIf

	cAliasQry:= GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT NNR.NNR_AMZUNI
		FROM %Table:NNR% NNR
		WHERE NNR.NNR_FILIAL = %xFilial:NNR%
		AND NNR.NNR_CODIGO = %Exp:cArmazem%
		AND NNR.%NotDel%
	EndSql

	If (cAliasQry)->(Eof())
		__cErro := "Armazem inválido!"
		lRet := .F.
	Else
		If (cAliasQry)->NNR_AMZUNI == "2"
			__cErro := "Armazem nao controla unitizacao!"
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*
=====================================================================================
Programa.:              VldEndOrig
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Valida endereço de origem      
=====================================================================================
*/
Static Function VldEndOrig(cArmazem,cEndereco)
	Local lRet      := .T.
	Local aAreaAnt  := {}
	Local cEstFis   := ""
	Local cAliasQry := Nil

	If Empty(cEndereco)
		Return .F.
	EndIf

	aAreaAnt := GetArea()
	If Empty(cEstFis := Posicione("SBE",1,xFilial("SBE")+cArmazem+cEndereco,"BE_ESTFIS")) // BE_FILIAL+BE_LOCAL+BE_LOCALIZ
		__cErro := "Endereço inválido!"
		lRet := .F.
	EndIf

	If lRet
		cAliasQry:= GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT 1
			FROM %Table:D0Q% D0Q
			WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
			AND D0Q.D0Q_LOCAL = %Exp:cArmazem%
			AND D0Q.D0Q_ENDER = %Exp:cEndereco%
			AND D0Q.D0Q_ORIGEM = %Exp:oMntUniItem:oUnitiz:GetOrigem()%
			// Deve existir demanda com status 'Pendente' ou 'Em Andamento'
			AND ( D0Q.D0Q_STATUS IN ('1','2')
				// Ou então existir demanda 'Finalizada' que possua Unitizador sem Ordem se Serviço gerada (status '2=Aguard. Ender'),
				// para deixar entrar na montagem e realizar algum estorno ou gerar a Ordem se Serviço.
				OR ( D0Q.D0Q_STATUS = '3' 
					AND EXISTS (SELECT 1 
								FROM %Table:D0S% D0S
								WHERE D0S.D0S_FILIAL = %xFilial:D0S%
								AND D0S.D0S_IDD0Q = D0Q.D0Q_ID
								AND EXISTS (SELECT 1 
											FROM %Table:D0R% D0R
											WHERE D0R.D0R_FILIAL = %xFilial:D0R%
											AND D0R.D0R_IDUNIT = D0S.D0S_IDUNIT
											AND D0R.D0R_STATUS = '2'
											AND D0R.%NotDel% )
								AND D0S.%NotDel% )))
			AND D0Q.%NotDel%
		EndSql
		
		If (cAliasQry)->(Eof())
			__cErro := " Não existe Demanda de Unitização 'Pendente' ou 'Em Andamento' para o armazám " + cArmazem + " e endereço " + cEndereco
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	RestArea(aAreaAnt)
Return lRet

/*
=====================================================================================
Programa.:              VldIdUnit
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Valida unitizador           
=====================================================================================
*/
Static Function VldIdUnit(cUnitiz,cTipUni,lEstorno)
	Local lRet 		:= .T.

	// Se não existe, gera etiqueta automaticamente
	D0Y->(DbSetOrder(1))
	If !D0Y->(DbSeek(xFilial("D0Y")+cUnitiz))
		WmsGerUnit(.F.,.F.,.F.,cUnitiz,cTipUni)
	EndIf

	oMntUniItem:SetIdUnit(cUnitiz)
	If !(lRet := oMntUniItem:VldIdUnit(1,@cTipUni,lEstorno))
		oMntUniItem:SetIdUnit("")
		If !Empty(oMntUniItem:GetErro())
			__cErro := "Unitizador: " + cUnitiz + CRLF + oMntUniItem:GetErro()
		EndIf
	EndIf

Return lRet

/*
=====================================================================================
Programa.:              GerUniAuto
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Gera montagem automatica dos unitizadores         
=====================================================================================
*/
Static Function GerUniAuto( __aItsUni )
	Local nX        := 0
	Local lRet      := .T.
	
	Default __aItsUni	:= {}                  

	If ValType(__aItsUni) == "A" .And. Len(__aItsUni) > 0
		// Processando
		For nX := 1 To Len(__aItsUni)
			// Atribui as informações retornadas no objeto e efetiva no unitizador
			oMntUniItem:SetPrdOri(__aItsUni[nX,PRDORI])
			oMntUniItem:SetProduto(__aItsUni[nX,CODPRO])
			oMntUniItem:SetLoteCtl(__aItsUni[nX,LOTECT])
			oMntUniItem:SetNumLote(__aItsUni[nX,NUMLOT])
			oMntUniItem:SetQuant(__aItsUni[nX,QUANT])
			oMntUniItem:SetNumSeq(__aItsUni[nX,NUMSEQ])
			If !oMntUniItem:zMntUnit()
				__cErro := oMntUniItem:GetErro()
				lRet := .F.
				Exit
			EndIf
		Next nX

	EndIf

	//--Valida se não existe OS para esse unitizador
	If oMntUniItem:oUnitiz:GetStatus() == "3"
		__cErro := "A OS deste unitizador já foi gerada."
		lRet := .F.
	EndIf

	//--Geração da ordem de serviço
	If lRet
		lRet := GeraOrdSer(__aItsUni[1][UNITZ])
	EndIf

	//-- Se deu certo a geração da ordem de serviço limpa o unitizador
	If lRet
		oMntUniItem:SetIdUnit("")
		oMntUniItem:oUnitiz:SetStatus("3")
	EndIf

Return lRet

/*
=======================================================================================
Programa.:              RetCompl
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Retorna informações complementares para a tela de visualização
						das invoices          
=======================================================================================
*/
Static Function RetCompl( cProcesso, cInvoice, cForn, cLoja, nQtd, nQtdUni, cPerc )
	Local aArea	:= GetArea()
	Local cQry 	:= ""
	Local cTMP 	:= GetNextAlias()

	Default cProcesso	:=	""
	Default cInvoice	:=	""
	Default cForn		:=	""
	Default cLoja		:=	""
	Default nQtd		:=	""
	Default nQtdUni		:=	""
	Default cPerc		:=	""

	If Select( cTMP ) > 0
		( cTMP )->( DbCloseArea() )
	EndIf

	cQry  :=  " SELECT SWN.WN_INVOICE, SUM(WN_QUANT) AS QTD, SUM(D0Q_QUANT) AS QTDCLAS, SUM(D0Q_QTDUNI) AS QTDUNIT " + CRLF
	cQry  +=  " FROM " + RetSQLName( "SWN" ) + " SWN " + CRLF
	cQry  +=  " LEFT JOIN " + RetSQLName( "SD1" ) + " SD1 " + CRLF
 	cQry  +=  "		ON SD1.D1_FILIAL = '" + FWxFilial("SD1") + "' " + CRLF
	cQry  +=  "		AND SD1.D1_DOC = SWN.WN_DOC " + CRLF
 	cQry  +=  "		AND SD1.D1_SERIE = SWN.WN_SERIE " + CRLF
 	cQry  +=  "		AND SD1.D1_FORNECE = SWN.WN_FORNECE " + CRLF
 	cQry  +=  "		AND SD1.D1_LOJA = SWN.WN_LOJA " + CRLF
 	cQry  +=  "		AND SD1.D1_COD = SWN.WN_PRODUTO " + CRLF
 	cQry  +=  "		AND SD1.D1_ITEM = LPAD(SWN.WN_LINHA, 4, '0') " + CRLF
 	cQry  +=  "		AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQry  +=  " LEFT JOIN " + RetSQLName( "D0Q" ) + " D0Q " + CRLF
 	cQry  +=  " 	ON D0Q.D0Q_FILIAL = '" + FWxFilial("D0Q") + "' " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_DOCTO = SD1.D1_DOC " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_SERIE = SD1.D1_SERIE " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_CLIFOR = SD1.D1_FORNECE " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_LOJA = SD1.D1_LOJA " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_CODPRO = SD1.D1_COD " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_NUMSEQ = SD1.D1_NUMSEQ " + CRLF
 	cQry  +=  "		AND D0Q.D_E_L_E_T_ = ' ' " + CRLF
	cQry  +=  " WHERE SWN.WN_FILIAL = '" + FWxFilial("SWN") + "' " + CRLF
	cQry  +=  "		AND SWN.WN_HAWB = '" + cProcesso + "' " + CRLF 
	cQry  +=  "		AND SWN.WN_INVOICE = '" + cInvoice + "' " + CRLF 
	cQry  +=  "		AND SWN.WN_FORNECE = '" + cForn + "' " + CRLF 
	cQry  +=  "		AND SWN.WN_LOJA = '" + cLoja + "' " + CRLF 
 	cQry  +=  "		AND SWN.D_E_L_E_T_ = ' ' " + CRLF
	cQry  +=  " GROUP BY SWN.WN_FILIAL, SWN.WN_INVOICE " + CRLF

	cQry	:= ChangeQuery( cQry )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTMP, .T., .T. )

	DbSelectArea(cTMP)
	If (cTMP)->(!Eof())
		cPerc := cValToChar( Round( (cTMP)->( ( QTDCLAS / QTD ) * 100 ) ,2 ) ) + "%"
		nQtd 	:= (cTMP)->(QTD)
		nQtdUni := (cTMP)->(QTDUNIT)
	EndIf

	(cTMP)->( DbCloseArea() )
	RestArea(aArea)

Return

/*
=======================================================================================
Programa.:              RetItens
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Tela para visualização dos itens do unitizador           
=======================================================================================
*/
Static Function RetItens(cInvoice, cCont, cUnit)
	Local aArea			:= GetArea()
	Local aCoors 		:= FWGetDialogSize( oMainWnd )
	Local aCpoEnch		:= {"WN_XLOGERR", "NOUSER"}	//campos que serão mostrados na enchoice
	Local oDlgItens, oFWLayer, oDlgLayCab

	Define MsDialog oDlgItens Title 'Itens do unitizador' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		
	//-- Cria o conteiner
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgItens, .F.)

	//-- Define Painel Superior
	oFWLayer:AddLine( 'UP', 50, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
	
	//-- Define Painel inferior
	oFWLayer:AddLine( 'DOWN', 50, .F. )
	oFWLayer:AddCollumn( "INF" , 100, .T., 'DOWN' )
	oFWLayer:AddWindow( "INF",  "MSG_ERRO",  "Mensagem de erro", 100, .F., .F.,, "DOWN")

	oBrwItens := FWMBrowse():New()
	oBrwItens:SetOwner( oPanelUp )
	oBrwItens:SetAlias("SWN")
	oBrwItens:SetDescription("Itens do unitizador") // "Montagem de Unitizadores"
	oBrwItens:DisableDetails()
	oBrwItens:SetAmbiente(.F.)
	oBrwItens:SetWalkThru(.F.)
	oBrwItens:SetFixedBrowse(.T.)
	oBrwItens:SetFilterDefault("@"+FilUnit(cInvoice, cCont, cUnit))
	oBrwItens:AddButton("Fechar"	, { || oDlgItens:End()	})
	//oBrwItens:DisableReport()
	oBrwItens:SetProfileID('SWN')
	oBrwItens:Activate()

	oDlgLayCab	:= oFWLayer:GetWinPanel("INF", "MSG_ERRO", "DOWN")
	oMaster := MsMGet():New("SWN",SWN->(Recno()),2,,,,aCpoEnch,{0,0,122.5,50},,3,,,,oDlgLayCab,,,,,.T./*lNoFolder*/)

	Activate MsDialog oDlgItens Center

	RestArea(aArea)

Return

/*
=======================================================================================
Programa.:              FilUnit
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Filtra itens do unitizador       
=======================================================================================
*/
Static Function FilUnit(cInvoice, cCont, cUnit)
	Local cFiltro := ""

	cFiltro  +=  " WN_FILIAL = '"+xFilial('SWN')+"'"
	cFiltro  +=  "	AND WN_INVOICE = '" + cInvoice + "' " + CRLF 
	cFiltro  +=  "	AND WN_XCONT = '" + cCont + "' " + CRLF 
	cFiltro  +=  "	AND WN_XLOTE = '" + cUnit + "' " + CRLF 
 	cFiltro  +=  "	AND D_E_L_E_T_ = ' ' " + CRLF

Return cFiltro

/*
=======================================================================================
Programa.:              CargaUnit
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Carrega itens do unitizador com demanda de unitização          
=======================================================================================
*/
Static Function CargaUnit( cInvoice, cCont, cUnit )
	Local aArea			:= GetArea()
	Local cAliasUnit 	:= GetNextAlias()
	Local aItens		:= {}

	Default cInvoice	:= ""
	Default cCont		:= ""
	Default cUnit		:= ""

	If Select( cAliasUnit ) > 0
		( cAliasUnit )->( DbCloseArea() )
	EndIf

	cQry  :=  " SELECT D0Q.D0Q_SERVIC, D0Q.D0Q_LOCAL, D0Q.D0Q_ENDER, D0Q.D0Q_PRDORI, " + CRLF
	cQry  +=  " D0Q.D0Q_CODPRO, D0Q.D0Q_LOTECT, D0Q.D0Q_NUMLOT, D0Q.D0Q_QUANT, D0Q.D0Q_NUMSEQ, " + CRLF
	cQry  +=  " D0Q.D0Q_DOCTO, D0Q.D0Q_SERIE, D0Q.D0Q_CLIFOR, D0Q.D0Q_LOJA " + CRLF
	cQry  +=  " FROM " + RetSQLName( "SWN" ) + " SWN " + CRLF
	cQry  +=  " INNER JOIN " + RetSQLName( "SD1" ) + " SD1 " + CRLF
 	cQry  +=  "		ON SD1.D1_FILIAL = '" + FWxFilial("SD1") + "' " + CRLF
	cQry  +=  "		AND SD1.D1_DOC = SWN.WN_DOC " + CRLF
 	cQry  +=  "		AND SD1.D1_SERIE = SWN.WN_SERIE " + CRLF
 	cQry  +=  "		AND SD1.D1_FORNECE = SWN.WN_FORNECE " + CRLF
 	cQry  +=  "		AND SD1.D1_LOJA = SWN.WN_LOJA " + CRLF
 	cQry  +=  "		AND SD1.D1_COD = SWN.WN_PRODUTO " + CRLF
 	cQry  +=  "		AND SD1.D1_ITEM = LPAD(SWN.WN_LINHA, 4, '0') " + CRLF
 	cQry  +=  "		AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQry  +=  " INNER JOIN " + RetSQLName( "D0Q" ) + " D0Q " + CRLF
 	cQry  +=  " 	ON D0Q.D0Q_FILIAL = '" + FWxFilial("D0Q") + "' " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_DOCTO = SD1.D1_DOC " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_SERIE = SD1.D1_SERIE " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_CLIFOR = SD1.D1_FORNECE " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_LOJA = SD1.D1_LOJA " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_CODPRO = SD1.D1_COD " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_NUMSEQ = SD1.D1_NUMSEQ " + CRLF
	cQry  +=  " 	AND D0Q.D0Q_QTDUNI = 0 " + CRLF 
 	cQry  +=  "		AND D0Q.D_E_L_E_T_ = ' ' " + CRLF
	cQry  +=  " WHERE SWN.WN_FILIAL = '" + FWxFilial("SWN") + "' " + CRLF
	cQry  +=  "		AND SWN.WN_INVOICE = '" + cInvoice + "' " + CRLF 
	//cQry  +=  "		AND SWN.WN_XCONT = '" + cCont + "' " + CRLF 
	cQry  +=  "		AND SWN.WN_XLOTE = '" + cUnit + "' " + CRLF 
 	cQry  +=  "		AND SWN.D_E_L_E_T_ = ' ' " + CRLF
	cQry  +=  " ORDER BY SWN.R_E_C_N_O_ " + CRLF 

	cQry	:= ChangeQuery( cQry )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasUnit, .T., .T. )

	While ( cAliasUnit )->( !EOF() )

		Aadd( aItens, { cUnit,;
					 	( cAliasUnit )->D0Q_LOCAL,;
						( cAliasUnit )->D0Q_ENDER,;
						( cAliasUnit )->D0Q_PRDORI,;
						( cAliasUnit )->D0Q_CODPRO,;
						( cAliasUnit )->D0Q_LOTECT,;
						( cAliasUnit )->D0Q_NUMLOT,;
						( cAliasUnit )->D0Q_QUANT,;
						( cAliasUnit )->D0Q_DOCTO,;
						( cAliasUnit )->D0Q_SERIE,;
						( cAliasUnit )->D0Q_CLIFOR,;
						( cAliasUnit )->D0Q_LOJA,;
						( cAliasUnit )->D0Q_SERVIC,;
						( cAliasUnit )->D0Q_NUMSEQ } )

		( cAliasUnit )->( DbSkip() )

	EndDo

	( cAliasUnit )->( dbCloseArea() )
	RestArea( aArea )

Return aItens

/*
=====================================================================================
Programa.:              RetErro
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Retorna mensagem de erro gravada         
=====================================================================================
*/
Static Function RetErro( cInvoice, cCont, cUnit )
	Local aArea		:= GetArea()
	Local cQry 		:= ""
	Local cTMPMsg 	:= GetNextAlias()
	Local cErro		:= ""

	Default cInvoice	:=	""
	Default cCont		:=	""
	Default cUnit		:=	""

	If Select( cTMPMsg ) > 0
		( cTMPMsg )->( DbCloseArea() )
	EndIf

	cQry  :=  " SELECT utl_raw.cast_to_varchar2(dbms_lob.substr(SWN.WN_XLOGERR)) AS MSGERRO " + CRLF
	cQry  +=  " FROM " + RetSQLName( "SWN" ) + " SWN " + CRLF
	cQry  +=  " WHERE SWN.WN_FILIAL = '" + FWxFilial("SWN") + "' " + CRLF
	cQry  +=  "		AND SWN.WN_INVOICE = '" + cInvoice + "' " + CRLF
	
	If !Empty(cCont)
		cQry  +=  "		AND SWN.WN_XCONT = '" + cCont + "' " + CRLF 
	EndIf

	If !Empty(cUnit)
		cQry  +=  "		AND SWN.WN_XLOTE = '" + cUnit + "' " + CRLF 
	EndIf

	cQry  +=  "		AND SWN.WN_XLOGERR IS NOT NULL " + CRLF
 	cQry  +=  "		AND SWN.D_E_L_E_T_ = ' ' " + CRLF
	cQry  +=  "	ORDER BY SWN.R_E_C_N_O_ " + CRLF

	cQry	:= ChangeQuery( cQry )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTMPMsg, .T., .T. )

	DbSelectArea(cTMPMsg)
	If (cTMPMsg)->(!Eof())
		cErro := (cTMPMsg)->MSGERRO
	EndIf

	(cTMPMsg)->( DbCloseArea() )
	RestArea(aArea)

Return cErro

/*
=====================================================================================
Programa.:              GeraOrdSer
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Gera ordem de serviço        
=====================================================================================
*/
Static Function GeraOrdSer(cUnitiz)
	Local lRet       := .T.
	Local aAreaAnt   := GetArea()
	Local oOrdServ   := WMSDTCOrdemServicoCreate():New()
	Local cAliasQry  := Nil
	Local lSetEndDes := GetNewPar( "CMV_WMS011", .F. )
	//Local cArmDes	 := GetNewPar( "CMV_WMS009", "907" )
	//Local cEndDes	 := GetNewPar( "CMV_WMS010", "BRGLPATIO02" )

	Default cUnitiz	 := ""

	//--Função para alimentar a variavel static __oOrdServ usada no fonte WMSXFUNA
	WmsOrdSer(oOrdServ)

	// Busca as informações da Ordem de Serviço do primeiro documento da demanda
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D0Q.D0Q_SERVIC,
				D0Q.D0Q_DOCTO,
				D0Q.D0Q_SERIE,
				D0Q.D0Q_CLIFOR,
				D0Q.D0Q_LOJA,
				D0Q.D0Q_NUMSEQ,
				D0Q.D0Q_LOCAL,
				D0Q.D0Q_ORIGEM,
				D0Q.D0Q_ENDER,
				D0Q.D0Q_CODPRO,
				D0Q.D0Q_LOTECT,
				D0Q.D0Q_NUMLOT
		FROM       %Table:D0S% D0S
		INNER JOIN %Table:D0Q% D0Q
		ON D0Q.D0Q_FILIAL = %xFilial:D0Q%
		AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
		AND D0Q.%NotDel%
		INNER JOIN %Table:D0R% D0R
		ON D0R.D0R_FILIAL = %xFilial:D0R%
		AND D0R.D0R_IDUNIT = D0S.D0S_IDUNIT
		AND D0R.D0R_STATUS IN ('1','2') // Para garantir que não irá gerar duplicado
		AND D0R.%NotDel%
		WHERE D0S.D0S_FILIAL = %xFilial:D0S%
		AND D0S.D0S_IDUNIT = %Exp:cUnitiz%
		AND D0S.%NotDel%
	EndSql

	If (cAliasQry)->(!Eof())
		// Atribui endereco origem
		oOrdServ:oOrdEndOri:SetArmazem((cAliasQry)->D0Q_LOCAL)
		oOrdServ:oOrdEndOri:SetEnder((cAliasQry)->D0Q_ENDER)

		If lSetEndDes
			// Atribui endereco destino
			oOrdServ:oOrdEndDes:SetArmazem(cArmDes)
			oOrdServ:oOrdEndDes:SetEnder(cEndDes)

		EndIf

		oOrdServ:SetOrigem("D0R")
		oOrdServ:SetServico((cAliasQry)->D0Q_SERVIC)
		oOrdServ:SetDocto((cAliasQry)->D0Q_DOCTO)
		oOrdServ:SetSerie((cAliasQry)->D0Q_SERIE)
		oOrdServ:SetCliFor((cAliasQry)->D0Q_CLIFOR)
		oOrdServ:SetLoja((cAliasQry)->D0Q_LOJA)
		oOrdServ:SetNumSeq((cAliasQry)->D0Q_NUMSEQ)

		If lSetEndDes
			oOrdServ:SetUniDes(cUnitiz)
		EndIf

		oOrdServ:SetIdUnit(cUnitiz)
		oOrdServ:SetQuant(1)

		// Realiza a criação da ordem de serviço como origem D0R
		If lRet
			If !oOrdServ:CreateDCF()
				__cErro	:= oOrdServ:GetErro()
				lRet := .F.
			EndIf
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())

	// Efetua a execução automática quando serviço configurado 
	If lRet
		lRet := FinOrdSer( oOrdServ:GetIdDCF() )
	EndIf

	RestArea(aAreaAnt)
Return lRet

/*
=====================================================================================
Programa.:              FinOrdSer
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Finaliza ordem de serviço          
=====================================================================================
*/
Static Function FinOrdSer( cIDdcf )
	Local aAreaSB1	:= SB1->( GetArea() )
	Local lRet      := .T.
	Local cAliasD12 := Nil
	Local oMoviServ	:= WMSBCCMovimentoServico():New()
	
	// Efetua a execução automática do serviço
	lRet := ExeAutServ(cIDdcf)

	If lRet
		cAliasD12 := GetNextAlias()
		BeginSql Alias cAliasD12
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = %Exp:cIDdcf%	//oOrdServ:GetIdDCF()
			AND D12.%NotDel%
		EndSql
		Do While lRet .And. (cAliasD12)->(!Eof())
			oMoviServ:GoToD12((cAliasD12)->RECNOD12)
			// Finaliza movimento
			oMoviServ:SetQtdLid(oMoviServ:nQtdMovto)
			oMoviServ:dDtGeracao := dDataBase	//oOrdServ:GetData()
			oMoviServ:cHrGeracao := Time() 		//oOrdServ:GetHora()
			oMoviServ:dDtInicio  := dDataBase 	//oOrdServ:GetData()
			oMoviServ:cHrInicio  := Time() 		//oOrdServ:GetHora()
			// Atualiza o D12 para finalizado
			oMoviServ:SetStatus("1")
			oMoviServ:SetDataFim(dDataBase)
			oMoviServ:SetHoraFim(Time())
			oMoviServ:SetRecHum(IIF(Type("__cCodUser") == "C", __cCodUser, RetCodUsr()))
			If oMoviServ:GetAtuEst()== "1"
				lRet := oMoviServ:RecEnter()
			EndIf
			If lRet
				oMoviServ:UpdateD12()
			EndIf
			(cAliasD12)->(dbSkip())
		EndDo
		(cAliasD12)->(dbCloseArea())
		
		If !lRet
			__cErro := oMoviServ:GetErro()
		EndIf

	EndIf

	RestArea(aAreaSB1)
	oMoviServ:Destroy()
Return lRet

/*
=====================================================================================
Programa.:              ExeAutServ
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Executa automaticamente a ordem de serviço   
=====================================================================================
*/
Static Function ExeAutServ( cIDdcf )
	Local lRet       := .T.
	Local lContinua  := .T.
	Local oOrdSerRev := Nil
	Local oOrdSerExe := Nil
	Local oRegraConv := Nil
	Local cListIdDcf := ""
	//Local nX         := 0
	Local lExAuSpCp  := SuperGetMV("MV_WMSEASC",.F.,.F.)

	// Integração com o WMS
	// Verifica as Ordens de servico geradas para execução automatica
	oOrdSerExe := ZWMSF009():New()
	oRegraConv := ZWMSF010():New()
	oOrdSerExe:SetArrLib(oRegraConv:GetArrLib())
	cListIdDcf := ""
	//For nX := 1 To Len(aLibDCF)
	oOrdSerExe:SetIdDCF(cIDdcf) //aLibDCF[nX]
	If oOrdSerExe:LoadData()
		If (lContinua := oOrdSerExe:zExecDCF()) .And. oOrdSerExe:oServico:ChkSepara() .And. oOrdSerExe:GetOrigem() == "SC9"
			// Monta lista de ordem de serviço executada
			cListIdDcf += "'" + cIDdcf + "'," //aLibDCF[nX]
		EndIf
	EndIf
	If !lContinua
		lRet := .F.
		//Exit
	EndIf
	//Next nX

	If lRet
		If !Empty(oRegraConv:GetArrLib())
			oRegraConv:zLawExec()
		EndIf
	EndIf

	// Verifica se há mensagem de inconsistência e o parâmetro de execução automática de separação completa
	If !Empty(oOrdSerExe:aWmsAviso) .And. lExAuSpCp .And. !Empty(cListIdDcf)
		// Ajusta lista de ordem de serviço executada
		cListIdDcf := SubsTr(cListIdDcf,1,Len(cListIdDcf)-1)
		oOrdSerRev := WMSDTCOrdemServicoReverse():New()
		oOrdSerRev:RevPedAut(cListIdDcf)
	EndIf

	//-- Grava Erro
	If !lRet
		__cErro	:=	oOrdSerExe:GetErro()
	EndIf

Return lRet

/*
=====================================================================================
Programa.:              GrvErro
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Grava erro gerado por controle de exceção        
=====================================================================================
*/
Static Function GrvErro( oError )
	__cErro := oError:ERRORSTACK
	
	If !Empty(__cErro)
		//--Seta variavel de erro para execução do break
		lErro := .T.
	EndIf

Return

/*
=====================================================================================
Programa.:              zTmpInv
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Monta temporaria invoices      
=====================================================================================
*/
Static Function zTmpInv(lJob)
   	Local cAliasTmp 	:= GetNextAlias()
    Local cQuery    	:= ""
	Local aCampos       := {}
	Local oTempTable    := Nil
	Local nQtd 			:= 0
	Local nQtdUni		:= 0
	Local cPerc			:= ""
	Local cMsgErro		:= ""

	Default lJob		:= .F.	

	If Select( cAliasTmp ) > 0
		( cAliasTmp )->( DbCloseArea() )
	EndIf

	cQuery  :=  " SELECT W9_FILIAL, W9_INVOICE, W9_DT_EMIS, W9_HAWB, W9_FORN, W9_FORLOJ, W9_NOM_FOR, W6_HOUSE " + CRLF
	cQuery  +=  " FROM " + RetSQLName( "SW9" ) + " SW9 " + CRLF
	cQuery  +=  " INNER JOIN " + RetSQLName( "SW8" ) + " SW8 " + CRLF
	cQuery  +=  " 	ON SW8.W8_FILIAL = '" + FWxFilial("SW8") + "' " + CRLF
	cQuery  +=  " 	AND SW8.W8_HAWB = SW9.W9_HAWB " + CRLF
	cQuery  +=  " 	AND SW8.W8_INVOICE = SW9.W9_INVOICE " + CRLF
	cQuery  +=  " 	AND SW8.W8_FORN = SW9.W9_FORN " + CRLF
	cQuery  +=  " 	AND SW8.W8_FORLOJ = SW9.W9_FORLOJ " + CRLF
	cQuery  +=  " 	AND SW8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery  +=  " INNER JOIN " + RetSQLName( "SWN" ) + " SWN " + CRLF
	cQuery  +=  " 	ON SWN.WN_FILIAL = '" + FWxFilial("SW8") + "' " + CRLF
	cQuery  +=  " 	AND SWN.WN_HAWB = SW9.W9_HAWB " + CRLF
	cQuery  +=  " 	AND SWN.WN_INVOICE = SW9.W9_INVOICE " + CRLF
	cQuery  +=  " 	AND SWN.WN_FORNECE = SW9.W9_FORN " + CRLF
	cQuery  +=  " 	AND SWN.WN_LOJA = SW9.W9_FORLOJ " + CRLF
	cQuery  +=  " 	AND SWN.D_E_L_E_T_ = ' ' " + CRLF
	cQuery  +=  " INNER JOIN " + RetSQLName( "SB5" ) + " SB5 " + CRLF
	cQuery  +=  " 	ON SB5.B5_FILIAL = '" + FWxFilial("SB5") + "' " + CRLF
	cQuery  +=  " 	AND SB5.B5_COD = SW8.W8_COD_I " + CRLF
	cQuery  +=  " 	AND SB5.B5_CTRWMS = '1' " + CRLF //--Somente itens que tem controle WMS
	cQuery  +=  " 	AND SB5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery  +=  " INNER JOIN " + RetSQLName( "SW6" ) + " SW6 " + CRLF
	cQuery  +=  " 	ON SW6.W6_FILIAL = '" + FWxFilial("SW6") + "' " + CRLF
	cQuery  +=  " 	AND SW6.W6_HAWB = SW9.W9_HAWB " + CRLF
	cQuery  +=  " 	AND SW6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery  +=  " WHERE SW9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery  +=  " 	AND SW9.W9_HAWB	BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
	cQuery  += 	" 	AND SW9.W9_INVOICE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + CRLF
	cQuery  += 	" 	AND SW9.W9_FORN BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CRLF
	cQuery  += 	" 	AND SW9.W9_FORLOJ BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " + CRLF
	//--Remove Hyundai porque o processamento ocorre somente na rotina ZWMSF016
	cQuery += "		AND SW9.W9_FORN <> '003033' " + CRLF
	cQuery  +=  " GROUP BY W9_FILIAL, W9_INVOICE, W9_DT_EMIS, W9_HAWB, W9_FORN, W9_FORLOJ, W9_NOM_FOR, W6_HOUSE " + CRLF
	cQuery  +=  " ORDER BY W9_HAWB, W9_INVOICE " + CRLF

	cQuery	:= ChangeQuery( cQuery )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .T. )

	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbGoTop())

	If !(cAliasTmp)->(Eof())

		//Se o alias estiver aberto, fechar para evitar erros com alias aberto
		If (Select(cTmpInv) <> 0)
			dbSelectArea(cTmpInv)
			(cTmpInv)->(dbCloseArea())
		EndIf

		oTempTable := FWTemporaryTable():New(cTmpInv)

		aAdd(aCampos, {"Filial"     ,"C"    ,040    ,0  })
		aAdd(aCampos, {"Percentual" ,"C"    ,008    ,0  })
		aAdd(aCampos, {"Invoice"   	,"C"    ,030    ,0  })
		aAdd(aCampos, {"Dt_Emis"    ,"D"    ,008    ,0  })
		aAdd(aCampos, {"Processo"   ,"C"    ,030    ,0  })
		aAdd(aCampos, {"House"   	,"C"    ,018    ,0  })
		aAdd(aCampos, {"Fornecedor" ,"C"    ,006    ,0  })
		aAdd(aCampos, {"Loja"       ,"C"    ,002    ,0  })
		aAdd(aCampos, {"Nom_For"    ,"C"    ,020    ,0  }) 
		aAdd(aCampos, {"Qtd"    	,"N"    ,010    ,0  }) 
		aAdd(aCampos, {"QtdUni"    	,"N"    ,010    ,0  })
		aAdd(aCampos, {"MsgErro"	,"C"    ,240    ,0  })   

		oTempTable:SetFields( aCampos )
		oTempTable:AddIndex( "01", { "Processo" } )
		oTempTable:AddIndex( "02", { "Invoice" } )
		oTempTable:Create()

		(cAliasTmp)->(dbGoTop())
		While (cAliasTmp)->(!Eof())
			nQtd 	:= 0
			nQtdUni	:= 0
			cPerc	:= ""
			
			//--Retorna dados complementares
			RetCompl( (cAliasTmp)->W9_HAWB, (cAliasTmp)->W9_INVOICE, (cAliasTmp)->W9_FORN, (cAliasTmp)->W9_FORLOJ, @nQtd, @nQtdUni, @cPerc )

			cMsgErro := RetErro( (cAliasTmp)->W9_INVOICE )

			If lJob
				If cPerc == "100%" .And. ( (nQtd - nQtdUni) > 0 )
					If RecLock(cTmpInv,.T.)
						(cTmpInv)->Filial		:= AllTrim( (cAliasTmp)->W9_FILIAL ) + "-" + FWFilialName()
						(cTmpInv)->Percentual	:= cPerc
						(cTmpInv)->Invoice		:= AllTrim( (cAliasTmp)->W9_INVOICE )	
						(cTmpInv)->Dt_Emis		:= StoD( (cAliasTmp)->W9_DT_EMIS )  
						(cTmpInv)->Processo		:= AllTrim( (cAliasTmp)->W9_HAWB ) 
						(cTmpInv)->House		:= AllTrim( (cAliasTmp)->W6_HOUSE ) 
						(cTmpInv)->Fornecedor	:= AllTrim( (cAliasTmp)->W9_FORN )
						(cTmpInv)->Loja			:= AllTrim( (cAliasTmp)->W9_FORLOJ )
						(cTmpInv)->Nom_For		:= AllTrim( (cAliasTmp)->W9_NOM_FOR )
						(cTmpInv)->Qtd			:= nQtd
						(cTmpInv)->QtdUni		:= nQtdUni
						(cTmpInv)->MsgErro		:= cMsgErro
						(cTmpInv)->(MsUnLock())
					EndIf
				EndIf
			Else 
				If RecLock(cTmpInv,.T.)
					(cTmpInv)->Filial		:= AllTrim( (cAliasTmp)->W9_FILIAL ) + "-" + FWFilialName()
					(cTmpInv)->Percentual	:= cPerc
					(cTmpInv)->Invoice		:= AllTrim( (cAliasTmp)->W9_INVOICE )	
					(cTmpInv)->Dt_Emis		:= StoD( (cAliasTmp)->W9_DT_EMIS )  
					(cTmpInv)->Processo		:= AllTrim( (cAliasTmp)->W9_HAWB ) 
					(cTmpInv)->House		:= AllTrim( (cAliasTmp)->W6_HOUSE ) 
					(cTmpInv)->Fornecedor	:= AllTrim( (cAliasTmp)->W9_FORN )
					(cTmpInv)->Loja			:= AllTrim( (cAliasTmp)->W9_FORLOJ )
					(cTmpInv)->Nom_For		:= AllTrim( (cAliasTmp)->W9_NOM_FOR )
					(cTmpInv)->Qtd			:= nQtd
					(cTmpInv)->QtdUni		:= nQtdUni
					(cTmpInv)->MsgErro		:= cMsgErro
					(cTmpInv)->(MsUnLock())
				EndIf
			EndIf
		(cAliasTmp)->(DbSkip())
		EndDo
		(cAliasTmp)->(DbCloseArea())
	
	EndIf

Return

/*
=====================================================================================
Programa.:              zTmpMnt
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Monta temporaria monitor        
=====================================================================================
*/
Static Function zTmpMnt(lRemovFin)
	Local cQry   		:= ""
	Local cAliasTmp 	:= GetNextAlias()
	Local aCampos       := {}
	Local oTempTable    := Nil
	Local cMsgErro		:= ""

	Default lRemovFin	:= .F.

	If Select( cAliasTmp ) > 0
		( cAliasTmp )->( DbCloseArea() )
	EndIf

	cQry  :=  " SELECT SWN.WN_FILIAL, SWN.WN_INVOICE, SWN.WN_XCONT, SWN.WN_XLOTE, " + CRLF
	cQry  +=  " SUM(WN_QUANT) AS QTD, SUM(D0Q_QUANT) AS QTDCLAS, SUM(D0Q_QTDUNI) AS QTDUNIT " + CRLF
	cQry  +=  " FROM " + RetSQLName( "SWN" ) + " SWN " + CRLF
	cQry  +=  " LEFT JOIN " + RetSQLName( "SD1" ) + " SD1 " + CRLF
 	cQry  +=  "		ON SD1.D1_FILIAL = '" + FWxFilial("SD1") + "' " + CRLF
	cQry  +=  "		AND SD1.D1_DOC = SWN.WN_DOC " + CRLF
 	cQry  +=  "		AND SD1.D1_SERIE = SWN.WN_SERIE " + CRLF
 	cQry  +=  "		AND SD1.D1_FORNECE = SWN.WN_FORNECE " + CRLF
 	cQry  +=  "		AND SD1.D1_LOJA = SWN.WN_LOJA " + CRLF
 	cQry  +=  "		AND SD1.D1_COD = SWN.WN_PRODUTO " + CRLF
 	cQry  +=  "		AND SD1.D1_ITEM = LPAD(SWN.WN_LINHA, 4, '0') " + CRLF
 	cQry  +=  "		AND SD1.D_E_L_E_T_ = ' ' " + CRLF
 	cQry  +=  " LEFT JOIN " + RetSQLName( "D0Q" ) + " D0Q " + CRLF
 	cQry  +=  " 	ON D0Q.D0Q_FILIAL = '" + FWxFilial("D0Q") + "' " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_DOCTO = SD1.D1_DOC " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_SERIE = SD1.D1_SERIE " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_CLIFOR = SD1.D1_FORNECE " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_LOJA = SD1.D1_LOJA " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_CODPRO = SD1.D1_COD " + CRLF
 	cQry  +=  " 	AND D0Q.D0Q_NUMSEQ = SD1.D1_NUMSEQ " + CRLF
 	cQry  +=  "		AND D0Q.D_E_L_E_T_ = ' ' " + CRLF
	cQry  +=  " WHERE SWN.WN_FILIAL = '" + FWxFilial("SWN") + "' " + CRLF
	cQry  +=  "		AND SWN.WN_HAWB = '" + (cTmpInv)->Processo + "' " + CRLF 
	cQry  +=  "		AND SWN.WN_INVOICE = '" + (cTmpInv)->Invoice + "' " + CRLF 
	cQry  +=  "		AND SWN.WN_FORNECE = '" + (cTmpInv)->Fornecedor + "' " + CRLF 
	cQry  +=  "		AND SWN.WN_LOJA = '" + (cTmpInv)->Loja + "' " + CRLF 
 	cQry  +=  "		AND SWN.D_E_L_E_T_ = ' ' " + CRLF
	cQry  +=  " GROUP BY SWN.WN_FILIAL, SWN.WN_INVOICE, SWN.WN_XCONT, SWN.WN_XLOTE " + CRLF
	cQry  +=  " ORDER BY SWN.WN_FILIAL, SWN.WN_INVOICE, SWN.WN_XCONT, SWN.WN_XLOTE " + CRLF

	cQry	:= ChangeQuery( cQry )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTmp, .T., .T. )

	DbSelectArea(cAliasTmp)
	If (cAliasTmp)->(!Eof())

		//Se o alias estiver aberto, fechar para evitar erros com alias aberto
		If (Select(cTmpMnt) <> 0)
			dbSelectArea(cTmpMnt)
			(cTmpMnt)->(dbCloseArea())
		EndIf

		oTempTable := FWTemporaryTable():New(cTmpMnt)

		aAdd(aCampos, {"Filial"     	,"C"    ,010    ,0  })
		aAdd(aCampos, {"Invoice"  		,"C"    ,030    ,0  })
		aAdd(aCampos, {"Container"  	,"C"    ,020    ,0  })
		aAdd(aCampos, {"Unitizador" 	,"C"    ,040    ,0  })
		aAdd(aCampos, {"Qtd" 			,"N"    ,013    ,0  })
		aAdd(aCampos, {"QtdClas"		,"N"    ,013    ,0  })
		aAdd(aCampos, {"QtdUnitiz"		,"N"    ,012    ,0  })
		aAdd(aCampos, {"MsgErro"		,"C"    ,240    ,0  })

		oTempTable:SetFields( aCampos )
		oTempTable:AddIndex("01", { "Invoice" } )
		oTempTable:AddIndex("02", { "Container" } )
		oTempTable:AddIndex("03", { "Unitizador" } )
		oTempTable:Create()

		(cAliasTmp)->(dbGoTop())
		While (cAliasTmp)->(!Eof())

			cMsgErro := RetErro( (cAliasTmp)->WN_INVOICE, (cAliasTmp)->WN_XCONT, (cAliasTmp)->WN_XLOTE )
			
			//--Remove registros finalizados
			If lRemovFin
				If ( ( (cAliasTmp)->QTD - (cAliasTmp)->QTDUNIT ) > 0 )
					If RecLock(cTmpMnt,.T.)
						(cTmpMnt)->Filial		:= AllTrim( (cAliasTmp)->WN_FILIAL )
						(cTmpMnt)->Invoice      := AllTrim( (cAliasTmp)->WN_INVOICE )
						(cTmpMnt)->Container 	:= AllTrim( (cAliasTmp)->WN_XCONT )
						(cTmpMnt)->Unitizador 	:= AllTrim( (cAliasTmp)->WN_XLOTE )		
						(cTmpMnt)->Qtd 			:= (cAliasTmp)->QTD
						(cTmpMnt)->QtdClas		:= (cAliasTmp)->QTDCLAS		
						(cTmpMnt)->QtdUnitiz	:= (cAliasTmp)->QTDUNIT
						(cTmpMnt)->MsgErro		:= cMsgErro
						(cTmpMnt)->(MsUnLock())
					EndIf
				EndIf
			Else
				If RecLock(cTmpMnt,.T.)
					(cTmpMnt)->Filial		:= AllTrim( (cAliasTmp)->WN_FILIAL )
					(cTmpMnt)->Invoice      := AllTrim( (cAliasTmp)->WN_INVOICE )
					(cTmpMnt)->Container 	:= AllTrim( (cAliasTmp)->WN_XCONT )
					(cTmpMnt)->Unitizador 	:= AllTrim( (cAliasTmp)->WN_XLOTE )		
					(cTmpMnt)->Qtd 			:= (cAliasTmp)->QTD
					(cTmpMnt)->QtdClas		:= (cAliasTmp)->QTDCLAS		
					(cTmpMnt)->QtdUnitiz	:= (cAliasTmp)->QTDUNIT
					(cTmpMnt)->MsgErro		:= cMsgErro
					(cTmpMnt)->(MsUnLock())
				EndIf
			EndIf

		(cAliasTmp)->(DbSkip())
		EndDo
		(cAliasTmp)->(DbCloseArea())

	EndIf	

Return

/*
=====================================================================================
Programa.:              zAtuBrw
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Atualiza browse            
=====================================================================================
*/
Static Function zAtuBrw()
	Local nPos := oBrowse:At()

	FWMsgRun( ,{|| zTmpInv() } ,"Atualizando informações do browse..." ,"Por favor aguarde...")
	oBrowse:Refresh(.F.)
	oBrowse:GoTo(nPos)

Return

/*
=====================================================================================
Programa.:              zForceAtu
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Força atualização do browse         
=====================================================================================
*/
Static Function zForceAtu()
	/*Foi necessario fechar a dialog e reabrir o browse porque ao usar o método refresh 
	ocorria o seguinte error.log: variable does not exist B1_DESC on { || B1_DESC }(FWBROWSE.PRW).
	O error.log só era apresentado quando havia finalização do serviço, com o método RecEnter()*/

	//-- Força a atualização do browse
	oDlg:End()
	FWMsgRun( ,{|| TelaUnit(3) } ,"Atualizando informações do browse..." ,"Por favor aguarde...")

Return

/*
=====================================================================================
Programa.:              zRelF016
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              05/02/2021
Descricao / Objetivo:   Relatorio de conferencia das contagens do inventario  
=====================================================================================
*/
Static Function zRelF016()
    Private oReport, oSection
    Private cAliasTMP := GetNextAlias()

	ReportDef()
	oReport:PrintDialog()

	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

Return

/*
=====================================================================================
Programa.:              ReportDef
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              05/02/2021
Descricao / Objetivo:   Definição da estrutura do relatorio
=====================================================================================
*/
Static Function ReportDef()

	oReport:= TReport():New("zRelF016",;
                            "Relatorio de Conferencia",;
                            "ZWMSF004",;
                            {|oReport|  ReportPrint(oReport)},;
                            "Relatorio para conferencia do enderaçamento dos unitizadores.")
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
    oReport:HideHeader() //--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter() //--Define que não será impresso o rodapé padrão da página
    oReport:SetDevice(4) //--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetPreview(.T.) //--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2) //--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
    //oReport:SetEdit(.T.) 
	
	//Verifica os parâmetros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.F.)
	
	oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTMP}) 
    
    TRCell():New( oSection  ,"WN_HAWB"  	,cAliasTMP  ,"Processo"    			)
    TRCell():New( oSection  ,"WN_INVOICE"  	,cAliasTMP  ,"Invoice"	    		)
    TRCell():New( oSection  ,"WN_XLOTE" 	,cAliasTMP  ,"Unitizador"    		)	
    TRCell():New( oSection  ,"D0R_LOCAL"   	,cAliasTMP  ,"Arm. Orig."		    )
    TRCell():New( oSection  ,"D0R_ENDER" 	,cAliasTMP  ,"End. Orig."			)
    TRCell():New( oSection  ,"QTDNF"    	,cAliasTMP  ,"Qtde. NF"				)
    TRCell():New( oSection  ,"D14_LOCAL" 	,cAliasTMP  ,"Arm. Dest."			)
    TRCell():New( oSection  ,"D14_ENDER" 	,cAliasTMP  ,"End. Dest."			)
    TRCell():New( oSection  ,"QTDPRD"  		,cAliasTMP  ,"Qtde. Endereçada."	)
	TRCell():New( oSection  ,"WN_XCONT"  	,cAliasTMP  ,"Container"			)
	//TRCell():New( oSection  ,"WN_LOTE"  	,cAliasTMP  ,"Lote"					)
	//TRCell():New( oSection  ,"WN_CASE"  	,cAliasTMP  ,"Case"					)

Return

/*
=====================================================================================
Programa.:              ReportPrint
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              05/02/2021
Descricao / Objetivo:   Preenche colunas do relatorio
=====================================================================================
*/
Static Function  ReportPrint(oReport)

    //Monta Tmp
    zTmpRel()

	oReport:SetMeter( Contar(cAliasTMP,"!Eof()") )
	oSection:Init()

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()

        // Incrementa a mensagem na régua.
        oReport:IncMeter()
      
        oSection:Cell( "WN_HAWB"  	):SetValue( Alltrim( (cAliasTMP)->WN_HAWB ) 	) //--Processo
        oSection:Cell( "WN_INVOICE"	):SetValue( Alltrim( (cAliasTMP)->WN_INVOICE ) 	) //--Invoice
        oSection:Cell( "WN_XLOTE" 	):SetValue( Alltrim( (cAliasTMP)->WN_XLOTE ) 	) //--Unitizador
        oSection:Cell( "D0R_LOCAL"	):SetValue( Alltrim( (cAliasTMP)->D0R_LOCAL ) 	) //--Arm. Orig.
        oSection:Cell( "D0R_ENDER" 	):SetValue( Alltrim( (cAliasTMP)->D0R_ENDER ) 	) //--End. Orig.
		oSection:Cell( "QTDNF"  	):SetValue( (cAliasTMP)->QTDNF 					) //--Qtde. NF
        oSection:Cell( "D14_LOCAL"	):SetValue( Alltrim( (cAliasTMP)->D14_LOCAL ) 	) //--Arm. Dest.
        oSection:Cell( "D14_ENDER" 	):SetValue( Alltrim( (cAliasTMP)->D14_ENDER ) 	) //--End. Dest.
        oSection:Cell( "QTDPRD" 	):SetValue( (cAliasTMP)->QTDPRD 				) //--Qtde. Endereçada.
		oSection:Cell( "WN_XCONT" 	):SetValue( Alltrim( (cAliasTMP)->WN_XCONT ) 	) //--Container
		//oSection:Cell( "WN_LOTE" 	):SetValue( Alltrim( (cAliasTMP)->WN_LOTE ) 	) //--Lote
		//oSection:Cell( "WN_CASE" 	):SetValue( Alltrim( (cAliasTMP)->WN_CASE ) 	) //--Case

        oSection:PrintLine()	

	    (cAliasTMP)->(dbSkip() )
	
	EndDo               
	oSection:Finish()	           

Return

/*
=====================================================================================
Programa.:              zTmpRel
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              05/02/2021
Descricao / Objetivo:   Retorna registros para montagem do relatorio
=====================================================================================
*/
Static Function zTmpRel()
    Local cQuery    	:= ""
    
	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

	cQuery := " SELECT SWNTMP.WN_HAWB, SWNTMP.WN_INVOICE, SWNTMP.WN_XLOTE, D0R.D0R_LOCAL, "			+ CRLF
	cQuery += "	D0R.D0R_ENDER, D14.D14_LOCAL, D14.D14_ENDER, SUM( D14.D14_QTDEST ) AS QTDPRD, "		+ CRLF
	cQuery += "	SWNTMP.QTDNF, SWNTMP.WN_XCONT "														+ CRLF
	cQuery += "	FROM ( SELECT SWN.WN_HAWB, SWN.WN_INVOICE, SWN.WN_XLOTE,  "							+ CRLF 
  	cQuery += "	SUM( SWN.WN_QUANT ) AS QTDNF, SWN.WN_XCONT "										+ CRLF
 	cQuery += "	FROM " + RetSQLName( 'SWN' ) + " SWN "		 										+ CRLF
	cQuery += "	WHERE SWN.WN_FILIAL = '" + FWxFilial('SWN') + "' "	 								+ CRLF
    cQuery += "		AND SWN.WN_HAWB BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " 			+ CRLF
    cQuery += "		AND SWN.WN_INVOICE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " 			+ CRLF
    cQuery += "		AND SWN.WN_FORNECE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " 			+ CRLF
    cQuery += "		AND SWN.WN_LOJA BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " 			+ CRLF
	//--Remove Hyundai porque o processamento ocorre somente na rotina ZWMSF016
	cQuery += "		AND SWN.WN_FORNECE <> '003033' "	 											+ CRLF
  	cQuery += "  	AND SWN.D_E_L_E_T_ = ' ' " 														+ CRLF
 	cQuery += "	GROUP BY SWN.WN_HAWB, SWN.WN_INVOICE, SWN.WN_XLOTE, " 								+ CRLF
	cQuery += " SWN.WN_XCONT ) SWNTMP " 															+ CRLF
  	cQuery += " LEFT JOIN " + RetSQLName( 'D14' ) + " D14 "		 									+ CRLF
	cQuery += " 	ON D14.D14_FILIAL = '" + FWxFilial('D14') + "' "	 							+ CRLF
	cQuery += "		AND D14.D14_IDUNIT = SWNTMP.WN_XLOTE "	 										+ CRLF
	cQuery += "		AND D14.D_E_L_E_T_ = ' ' "	 													+ CRLF
	cQuery += "	LEFT JOIN " + RetSQLName( 'D0R' ) + " D0R "		 									+ CRLF
	cQuery += " 	ON D0R.D0R_FILIAL = '" + FWxFilial('D0R') + "' "	 							+ CRLF
 	cQuery += "		AND D0R.D0R_IDUNIT = SWNTMP.WN_XLOTE "	 										+ CRLF
	cQuery += "	GROUP BY D14.D14_LOCAL, D14.D14_ENDER, D0R.D0R_LOCAL, D0R.D0R_ENDER, "	 			+ CRLF
	cQuery += "	SWNTMP.WN_XCONT, SWNTMP.WN_HAWB, SWNTMP.WN_INVOICE, "								+ CRLF
	cQuery += "	SWNTMP.WN_XLOTE, SWNTMP.QTDNF "	 													+ CRLF
	cQuery += "	ORDER BY SWNTMP.WN_HAWB, SWNTMP.WN_INVOICE, SWNTMP.WN_XCONT, SWNTMP.WN_XLOTE "		+ CRLF

    cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return


/*
=========================================================================================
Programa.:              zGeraD0Q
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              20/11/2021
Descricao / Objetivo:   Rotina usada como paliativo para geração de demanda de unitização
devido ao erro de TES vazia na SD1 após classificação da nota
=========================================================================================
*/
Static Function zGeraD0Q()
	Local aPergs	:= {}
	Local aRet		:= {}
	Local cQuery    := ""
	Local cAliasSD1 := ""
	Local oDmdUnit	:= Nil
	Local lRet		:= .T.
	Local cUpdate	:= ""

	If U_ZGENUSER( RetCodUsr() ,"zGeraD0Q" ,.T.)

		//-- Salva estado dos parâmetros porque o parambox ira sobrescrever e isso afeta o browse da rotina
		SaveInter() 

		aAdd(aPergs, {1 ,"Nota Fiscal"	,Space(TamSX3("D1_DOC")[1])		,""	,"" ,"" ,"" ,30	,.T. })
		aAdd(aPergs, {1 ,"Serie"		,Space(TamSX3("D1_SERIE")[1])	,""	,"" ,"" ,"" ,10 ,.T. })
		aAdd(aPergs, {1 ,"Fornecedor"	,Space(TamSX3("D1_FORNECE")[1])	,"" ,"" ,"" ,"" ,20 ,.T. })
		aAdd(aPergs, {1 ,"Loja"			,Space(TamSX3("D1_LOJA")[1])	,"" ,"" ,"" ,"" ,10	,.T. })

		If ParamBox( aPergs ,"Parametros de execução" ,@aRet )

			cQuery := " SELECT SD1.D1_NUMSEQ"
			cQuery +=   " FROM "+RetSqlName('SD1')+" SD1"
			cQuery +=  " INNER JOIN "+RetSqlName('NNR')+ " NNR"
			cQuery +=     " ON NNR.NNR_FILIAL = '"+xFilial('NNR')+"'"
			cQuery +=    " AND NNR.NNR_CODIGO = SD1.D1_LOCAL"
			cQuery +=    " AND NNR.NNR_AMZUNI = '1'"
			cQuery +=    " AND NNR.D_E_L_E_T_ = ' '"
			cQuery +=  " WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"'"
			cQuery +=    " AND SD1.D1_DOC    = '"+ AllTrim( aRet[1] ) +"'"
			cQuery +=    " AND SD1.D1_SERIE  = '"+ AllTrim( aRet[2] ) +"'"
			cQuery +=    " AND SD1.D1_FORNECE = '"+ AllTrim( aRet[3] ) +"'"
			cQuery +=    " AND SD1.D1_LOJA   = '"+ AllTrim( aRet[4] ) +"'"
			cQuery +=    " AND SD1.D1_TES = ' '"
			cQuery +=    " AND SD1.D1_IDDCF = ' '"
			cQuery +=    " AND SD1.D1_QUANT  > 0"
			cQuery +=    " AND SD1.D1_OP     = ' '"
			cQuery +=    " AND SD1.D_E_L_E_T_= ' '"
			cQuery := ChangeQuery(cQuery)
			
			cAliasSD1 := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD1,.F.,.T.)
			
			If (cAliasSD1)->(!EoF())
				oDmdUnit := WMSDTCDemandaUnitizacaoCreate():New()
				While (cAliasSD1)->(!EoF())
					oDmdUnit:SetNumSeq((cAliasSD1)->D1_NUMSEQ)
					oDmdUnit:SetOrigem('SD1')
					//oDmdUnit:SetGeraSld(.F.)
					lRet := oDmdUnit:CreateD0Q()
					If !lRet 
						Alert(oDmdUnit:GetErro()) //"Erro na geração da demanda de unitização."
						Exit
					EndIF
					(cAliasSD1)->(dbSkip())
				EndDo
			EndIf
			
			(cAliasSD1)->(dbCloseArea())

			//--Preenchimento da TES para os casos em que ocorre falha na classificação
			cUpdate :=  " UPDATE " + RetSqlName("SD1")              	+ CRLF
			cUpdate	+=  " SET D1_TES = '314' "         					+ CRLF
			cUpdate +=  " WHERE D1_FILIAL = '" + FWxFilial("SD1") + "'"	+ CRLF    
			cUpdate +=	" AND D1_DOC    = '"+ AllTrim( aRet[1] ) +"'"	+ CRLF
			cUpdate +=	" AND D1_SERIE  = '"+ AllTrim( aRet[2] ) +"'"	+ CRLF
			cUpdate +=	" AND D1_FORNECE = '"+ AllTrim( aRet[3] ) +"'"	+ CRLF
			cUpdate +=	" AND D1_LOJA   = '"+ AllTrim( aRet[4] ) +"'"	+ CRLF
			cUpdate +=  " AND D1_TES = ' ' "                       		+ CRLF
			cUpdate +=  " AND D_E_L_E_T_ = ' ' "                      	+ CRLF

			If TcSqlExec(cUpdate) < 0
				Help( ,, "Caoa",, TcSqlError() , 1, 0)
			EndIf

		EndIf

		RestInter() //-- Restaura estado dos parâmetros

	EndIf

Return lRet
