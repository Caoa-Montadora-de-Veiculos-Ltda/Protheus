#INCLUDE "PROTHEUS.CH"
Static __cProcess := ""

/*
================================================================================
Programa.:              ZWMSF016
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              15/01/2021
Descricao / Objetivo:   Recebimento automatico no Wms de itens de importação           
================================================================================
*/
User Function ZWMSF016()
	Local lJobAtivo	:= GetNewPar( "CMV_WMS012", .F. )
	
	If IsBlind()
		Conout( "Chamada Job ZWMSF016 | " + Time() )
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

			//--Temporariamente esta rotina sera utilizada somente para HYUNDAI
			//MV_PAR05 := '003033' 
			//MV_PAR06 := '003033'

			FWMsgRun( ,{|| TelaInv() } ,"Carregando invoices..." ,"Por favor aguarde...")
		EndIf
	EndIf

Return

/*
=================================================================================
Programa.:              TelaInv
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              15/01/2021
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
            aAdd(aSeek  ,{"BL" 				,{{ ""  ,"C"    ,TamSX3("ZM_BL")[1]		    ,0  ,"BL" 		,"@!"   }},1 } )
            aAdd(aSeek  ,{"Invoice" 		,{{ ""  ,"C"    ,TamSX3("ZM_INVOICE")[1]   	,0  ,"Invoice" 	,"@!"   }},2 } )

            aAdd(aFieFilter    ,{"Invoice"    	,"Invoice"			,"C"  ,TamSX3("ZM_INVOICE")[1]  ,0 ,"@!" })
            aAdd(aFieFilter    ,{"BL"  			,"BL"         		,"C"  ,TamSX3("ZM_BL")[1]       ,0 ,"@!" })
            aAdd(aFieFilter    ,{"Fornecedor"   ,"Fornecedor"		,"C"  ,TamSX3("ZM_FORNEC")[1]   ,0 ,"@!" })
            aAdd(aFieFilter    ,{"Loja"  		,"Loja"				,"C"  ,TamSX3("ZM_LOJA")[1]  	,0 ,"@!" })

            oBrowse := FWMBrowse():New()
            oBrowse:SetAlias(cTmpInv)
            oBrowse:SetMenuDef("")
            oBrowse:SetDescription("Montagem de unitizador")
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
            aAdd(afields    ,{"BL"				,"BL"			,"C"  ,030	,0 ,"@!" })
            aAdd(afields    ,{"Fornecedor"		,"Fornecedor"	,"C"  ,006	,0 ,"@!" })
            aAdd(afields    ,{"Loja"			,"Loja"			,"C"  ,002	,0 ,"@!" })
            aAdd(afields    ,{"Processo"		,"Processo"		,"C"  ,030	,0 ,"@!" })			

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
Data.....:              15/01/2021
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

	If AllTrim( (cTmpInv)->Percentual ) <> "100%" .And. nOpc == 3
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
			aAdd(aSeek  ,{"Invoice" 		,{{ ""  ,"C"    ,TamSX3("ZM_INVOICE")[1]        ,0  ,"Invoice" 		,"@!"   }},1 } )
			aAdd(aSeek  ,{"Container" 		,{{ ""  ,"C"    ,TamSX3("ZM_CONT")[1]        	,0  ,"Container" 	,"@!"   }},2 } )
			aAdd(aSeek  ,{"Unitizador" 		,{{ ""  ,"C"    ,TamSX3("ZM_UNIT")[1]        	,0  ,"Unitizador" 	,"@!"   }},3 } )

			aAdd(aFieFilter    ,{"Filial"		,"Filial"			,"C"  ,TamSX3("ZM_FILIAL")[1]  	,0 ,"@!" })
			aAdd(aFieFilter    ,{"Invoice"    	,"Invoice"			,"C"  ,TamSX3("ZM_INVOICE")[1]  ,0 ,"@!" })
			aAdd(aFieFilter    ,{"Container"  	,"Container"        ,"C"  ,TamSX3("ZM_CONT")[1]  	,0 ,"@!" })
			aAdd(aFieFilter    ,{"Unitizador"  	,"Unitizador"       ,"C"  ,TamSX3("ZM_UNIT")[1]    ,0 ,"@!" })

			oBrowseUp := FWMBrowse():New()
			oBrowseUp:SetOwner( oPanelUp )
			oBrowseUp:SetAlias(cTmpMnt)
			oBrowseUp:SetMenuDef("")
			oBrowseUp:SetDescription("Containers")
			oBrowseUp:SetFixedBrowse(.T.)
			oBrowseUp:AddLegend("!Empty( (cTmpMnt)->MsgErro )"	,"RED"   	,"Erro na unitizacao")
			oBrowseUp:AddLegend("(cTmpMnt)->Finalizado == .F."	,"YELLOW"   ,"Pendente") 	//Tive de colocar == .F. pois do contrario não funcionava?????
			oBrowseUp:AddLegend("(cTmpMnt)->Finalizado == .T."	,"GREEN"   	,"Finalizado") 	//Tive de colocar == .T. pois do contrario não funcionava?????
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
			aAdd(afields    ,{"Serie"        		,"Serie"		,"N"  ,003	,0 ,"@!" })

			oBrowseUp:SetFields(afields)
			
			oBrowseUp:Activate()

		EndIf

	EndIf

	//-- Lado Esquerdo
	oBrowseLeft:= FWMBrowse():New()
	oBrowseLeft:SetOwner( oPanelLeft )
	oBrowseLeft:SetDescription("Unitizadores")
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
Data.....:              15/01/2021
Descricao / Objetivo:   Processamento dos itens do browse para montagem dos unitizadores      
========================================================================================
*/
Static Function ProcUnit(lJob)
	Local cUpdate		:= ""
	Local bError
	Local oError
	Local aPergs 		:= {}
	Local aRet			:= {}
	Local nCount		:= 0
	Local aCampos		:= {}
	Local oTempUnit    	:= Nil
	Local nLocks		:= 0

	Private	cArmDes		:= ""
	Private cEndDes		:= ""
	Private __cErro		:= ""
	Private lErro		:= .F.
	Private cTmpUnit 	:= "TMP_UNIT"
	Private cRealName	:= ""
	Private __aRecSB2	:= {}

	Default lJob	:= .F.
	
	if Select('TMP') > 0
		__cProcess := TMP->PROCESSO
	EndIf
    
	aAdd(aPergs, {1 ,"Armazem Destino"  ,"907"								,""	  ,"" ,"" ,"" ,0  ,.T. })
    aAdd(aPergs, {1 ,"Endereço Destino" ,Space( TamSX3('BE_LOCALIZ')[1] )	,"@!" ,"" ,"" ,"" ,60 ,.T. })

	//-- Salva estado dos parâmetros porque o parambox ira sobrescrever e isso afeta o browse da rotina
	SaveInter() 

	If ParamBox( aPergs ,"Parametros de execução" ,@aRet )

		cArmDes	:= AllTrim( aRet[1] ) 
		cEndDes	:= AllTrim( aRet[2] )
		
		If !lJob
			//-- Seta o tamanho da régua
			ProcRegua( (cTmpMnt)->( RecCount() ) )
		EndIf

		//Se o alias estiver aberto, fechar para evitar erros com alias aberto
		If (Select(cTmpUnit) <> 0)
			dbSelectArea(cTmpUnit)
			(cTmpUnit)->(dbCloseArea())
		EndIf

		oTempUnit := FWTemporaryTable():New(cTmpUnit)

		aAdd(aCampos, {"unitizador"    	,"C"    ,TamSX3("D0R_IDUNIT")[1]	,0  })
		aAdd(aCampos, {"armazem"  		,"C"    ,TamSX3("D0Q_LOCAL")[1]	   	,0  })
		aAdd(aCampos, {"localiz"		,"C"    ,TamSX3("D0Q_ENDER")[1]    	,0  })
		aAdd(aCampos, {"prdori" 		,"C"    ,TamSX3("D0Q_PRDORI")[1]    ,0  })
		aAdd(aCampos, {"codpro" 		,"C"    ,TamSX3("D0Q_CODPRO")[1]    ,0  })
		aAdd(aCampos, {"lotect"			,"C"    ,TamSX3("D0Q_LOTECT")[1]    ,0  })
		aAdd(aCampos, {"numlot"			,"C"    ,TamSX3("D0Q_NUMLOT")[1]    ,0  })
		aAdd(aCampos, {"qtdunitz"		,"N"    ,TamSX3("ZM_QTDE")[1]    	,0  })
		aAdd(aCampos, {"docto"			,"C"    ,TamSX3("D0Q_DOCTO")[1]    	,0  })
		aAdd(aCampos, {"serie"			,"C"    ,TamSX3("D0Q_SERIE")[1]    	,0  })
		aAdd(aCampos, {"clifor"			,"C"    ,TamSX3("D0Q_CLIFOR")[1]    ,0  })
		aAdd(aCampos, {"loja"			,"C"    ,TamSX3("D0Q_LOJA")[1]    	,0  })
		aAdd(aCampos, {"servic"			,"C"    ,TamSX3("D0Q_SERVIC")[1]    ,0  })
		aAdd(aCampos, {"numseq"			,"C"    ,TamSX3("D0Q_NUMSEQ")[1]    ,0  })

		oTempUnit:SetFields( aCampos )
		oTempUnit:AddIndex("01", { "unitizador", "codpro" } )
		oTempUnit:Create()

		cRealName := '%' + oTempUnit:GetRealName() + '%'

		(cTmpMnt)->(DbGoTop())
		While (cTmpMnt)->(!Eof())

			//-- Verifica se o unitizador ja foi processado
			If !RetD0R( (cTmpMnt)->Unitizador )

				//--Incrementa se houver unitizador para montagem
				nCount++

				CargaUnit( (cTmpMnt)->Invoice, (cTmpMnt)->Container, (cTmpMnt)->Unitizador )

				//--Faço a limpeza do erro para novo processamento
				cUpdate :=  " UPDATE " + RetSqlName("SZM")              	+ CRLF
				cUpdate	+=  " SET ZM_LOGERR = ''"         					+ CRLF
				cUpdate +=  " WHERE ZM_FILIAL = '" + FWxFilial("SZM") + "'"	+ CRLF    
				cUpdate +=  " AND ZM_UNIT = '" + (cTmpMnt)->Unitizador + "'"     + CRLF
				cUpdate +=  " AND D_E_L_E_T_ = ' ' "                        + CRLF

				If TcSqlExec(cUpdate) < 0
					Help( ,, "Caoa",, TcSqlError() , 1, 0)
				EndIf

				nLocks := 0
				//--Verifica Lock na SB2 antes de acionar a geração do unitizador
				While U_ZGENLOCK( ,"SB2" ,__aRecSB2 )
					nLocks++
					IncProc("Aguardando liberação de registro para seguir com o processamento , tentativa " + cValToChar(nLocks) )
					Sleep(60000) //--Para o processamento por 1 minuto
				EndDo

				__aRecSB2 := {} //--Limpa recnos para o proximo unitizador

				bError := ErrorBlock( { |oError| GrvErro( oError ) } )
				Begin Sequence
					
					(cTmpUnit)->( DbGoTop() )
					If (cTmpUnit)->( !Eof() )
						
						If !lJob
							//-- Incrementa a mensagem na régua.
							IncProc("Processando a montagem do unitizador: " + AllTrim((cTmpMnt)->Unitizador) )
						EndIf

						If !( MontaUnit((cTmpUnit)->armazem, (cTmpUnit)->localiz) )
							
							//--Tratamento pra evitar erro na função utl_raw.cast_to_raw que suporta no maximo 2000 caracteres
							If Len( __cErro ) > 2000
								__cErro := SubStr(__cErro, 1, 2000)
							EndIf

							//--Grava log de erro
							cUpdate :=  " UPDATE " + RetSqlName("SZM")              				+ CRLF
							cUpdate	+=  " SET ZM_LOGERR = utl_raw.cast_to_raw('" + __cErro + "') "	+ CRLF
							cUpdate +=  " WHERE ZM_FILIAL = '" + FWxFilial("SZM") + "'"				+ CRLF    
							cUpdate +=  " AND ZM_UNIT = '" + (cTmpMnt)->Unitizador + "'"     		+ CRLF
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
						cUpdate :=  " UPDATE " + RetSqlName("SZM")              				+ CRLF
						cUpdate	+=  " SET ZM_LOGERR = utl_raw.cast_to_raw( '" + __cErro + "') "	+ CRLF
						cUpdate +=  " WHERE ZM_FILIAL = '" + FWxFilial("SZM") + "'"				+ CRLF    
						cUpdate +=  " AND ZM_UNIT = '" + (cTmpMnt)->Unitizador + "'"     		+ CRLF
						cUpdate +=  " AND D_E_L_E_T_ = ' ' "                        			+ CRLF

						If TcSqlExec(cUpdate) < 0
							Help( ,, "Caoa",, TcSqlError() , 1, 0)
						EndIf
					EndIf

				End Sequence

				//Restaurando bloco de erro do sistema
				ErrorBlock(bError)

			EndIf

			//--Faço a limpeza dos dados do unitizador para o novo processamento
			If TcSqlExec(" DELETE FROM " + oTempUnit:GetRealName()) < 0
				Help( ,, "Caoa",, TcSqlError() , 1, 0)
			EndIf

			(cTmpMnt)->( DbSkip() )

		EndDo

		If nCount == 0
			If !lJob
				MsgAlert("Não ha registros disponiveis para processamento, todos os registros estão finalizados!")
			EndIf	
		EndIf

	EndIf

	RestInter() //-- Restaura estado dos parâmetros

	If ( Select(cTmpUnit) <> 0 )
        dbSelectArea(cTmpUnit)
        (cTmpUnit)->(dbCloseArea())
    EndIf

Return

/*
=====================================================================================
Programa.:              MontaUnit
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              15/01/2021
Descricao / Objetivo:   Montagem dos unitizadores      
=====================================================================================
*/
Static Function MontaUnit(cArmazem, cEndereco)
	Local lRet      := .T.
	Local cOrigem   := "SD1"	//-- A origem sempre é a NF de entrada
	Local cTipUni	:= "000002" //-- Tipo de unitizador CASE, sempre usado neste processo

	Private oMntUniItem 	:= ZWMSF008():New()

	Default cArmazem  := ""
	Default cEndereco := ""

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
					
				If lRet :=	VldIdUnit((cTmpMnt)->Unitizador,cTipUni,.F.)

					//--Automatiza a montagem dos unitizadores
					If lRet := GerUniAuto()

						lRet := zVldMont((cTmpMnt)->Unitizador,(cTmpMnt)->Invoice)

					EndIf

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
Data.....:              15/01/2021
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
    //Fechar Alias Tmp
    (cAliasQry)->(dbCloseArea())
Return lRet

/*
=====================================================================================
Programa.:              VldEndOrig
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              15/01/2021
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
			__cErro := " Não existe Demanda de Unitização 'Pendente' ou 'Em Andamento' para o armazem " + cArmazem + " e endereço " + cEndereco
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
Data.....:              15/01/2021
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
Data.....:              15/01/2021
Descricao / Objetivo:   Gera montagem automatica dos unitizadores   
=====================================================================================
*/
Static Function GerUniAuto()
	Local lRet      := .T.
	
	(cTmpUnit)->( DbGoTop() )
	While (cTmpUnit)->( !Eof() )
		// Atribui as informações retornadas no objeto e efetiva no unitizador
		oMntUniItem:SetPrdOri((cTmpUnit)->prdori)
		oMntUniItem:SetProduto((cTmpUnit)->codpro)
		oMntUniItem:SetLoteCtl((cTmpUnit)->lotect)
		oMntUniItem:SetNumLote((cTmpUnit)->numlot)
		oMntUniItem:SetQuant((cTmpUnit)->qtdunitz)
		oMntUniItem:SetNumSeq((cTmpUnit)->numseq)
		If !oMntUniItem:zMntUnit()
			__cErro := oMntUniItem:GetErro()
			IF Empty(__cErro)
				__cErro := "Erro na Montagem do Unitizador"
				__cErro += 	CRLF + "prdori:"  + (cTmpUnit)->prdori
				__cErro += 	CRLF + "codpro:"  + (cTmpUnit)->codpro
				__cErro += 	CRLF + "lotect"   + (cTmpUnit)->lotect
				__cErro += 	CRLF + "numlot"   + (cTmpUnit)->numlot
				__cErro += 	CRLF + "qtdunitz" + STR((cTmpUnit)->qtdunitz)
				__cErro += 	CRLF + "numseq"   + (cTmpUnit)->numseq
			EndIf
			lRet := .F.
			Exit
		EndIf

		(cTmpUnit)->( DbSkip() )
	EndDo

	//--Valida se não existe OS para esse unitizador
	If oMntUniItem:oUnitiz:GetStatus() == "3"
		__cErro := "A OS deste unitizador já foi gerada."
		lRet := .F.
	EndIf

	//--Geração da ordem de serviço
	If lRet
		lRet := GeraOrdSer((cTmpMnt)->Unitizador)
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
Data.....:              15/01/2021
Descricao / Objetivo:   Retorna informações complementares para a tela de visualização
						das invoices          
=======================================================================================
*/
Static Function RetCompl( cBL, cInvoice, cForn, cLoja, nQtd, nQtdUni, cPerc )
	Local aArea		:= 	GetArea()
	Local cQry 		:= 	""
	Local cTMP 		:= 	GetNextAlias()
	Local nQtdClas	:=	0

	Default cBL	:=	""
	Default cInvoice	:=	""
	Default cForn		:=	""
	Default cLoja		:=	""
	Default nQtd		:=	""
	Default nQtdUni		:=	""
	Default cPerc		:=	""

	If Select( cTMP ) > 0
		( cTMP )->( DbCloseArea() )
	EndIf

	cQry  :=  " SELECT SZM.ZM_FORNEC, SZM.ZM_LOJA, SUM(ZM_QTDE) AS QTD " + CRLF
	cQry  +=  " FROM " + RetSQLName( "SZM" ) + " SZM " + CRLF
	cQry  +=  " WHERE   SZM.ZM_FILIAL  = '" + FWxFilial("SZM") + "' " + CRLF
	cQry  +=  "		AND SZM.ZM_BL      = '" + cBL + "' " + CRLF 
	cQry  +=  "		AND SZM.ZM_INVOICE = '" + cInvoice + "' " + CRLF 
	cQry  +=  "		AND SZM.ZM_FORNEC  = '" + cForn + "' " + CRLF 
	cQry  +=  "		AND SZM.ZM_LOJA    = '" + cLoja + "' " + CRLF 
 	cQry  +=  "		AND SZM.D_E_L_E_T_ = ' ' " + CRLF
	cQry  +=  " GROUP BY SZM.ZM_FORNEC, SZM.ZM_LOJA " + CRLF

	cQry	:= ChangeQuery( cQry )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTMP, .T., .T. )

	DbSelectArea(cTMP)
	If (cTMP)->( !Eof() )

		nQtd := (cTMP)->QTD
		
		RetD0Q( @nQtdUni, @nQtdClas)

		cPerc := cValToChar( Round( nQtdClas / nQtd * 100, 2 ) ) + "%"
	EndIf

	(cTMP)->( DbCloseArea() )
	RestArea(aArea)

Return

/*
=======================================================================================
Programa.:              RetItens
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              15/01/2021
Descricao / Objetivo:   Tela para visualização dos itens do unitizador       
=======================================================================================
*/
Static Function RetItens(cInvoice, cCont, cUnit)
	Local aArea			:= GetArea()
	Local aCoors 		:= FWGetDialogSize( oMainWnd )
	Local aCpoEnch		:= {"ZM_LOGERR", "NOUSER"}	//campos que serão mostrados na enchoice
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
	oBrwItens:SetAlias("SZM")
	oBrwItens:SetDescription("Itens do unitizador") // "Montagem de Unitizadores"
	oBrwItens:DisableDetails()
	oBrwItens:SetAmbiente(.F.)
	oBrwItens:SetWalkThru(.F.)
	oBrwItens:SetFixedBrowse(.T.)
	oBrwItens:SetFilterDefault("@"+FilUnit(cInvoice, cCont, cUnit))
	oBrwItens:AddButton("Fechar"	, { || oDlgItens:End()	})
	//oBrwItens:DisableReport()
	oBrwItens:SetProfileID('SZM')
	oBrwItens:Activate()

	oDlgLayCab	:= oFWLayer:GetWinPanel("INF", "MSG_ERRO", "DOWN")
	oMaster := MsMGet():New("SZM",SZM->(Recno()),2,,,,aCpoEnch,{0,0,122.5,50},,3,,,,oDlgLayCab,,,,,.T./*lNoFolder*/)

	Activate MsDialog oDlgItens Center

	RestArea(aArea)

Return

/*
=======================================================================================
Programa.:              FilUnit
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              15/01/2021
Descricao / Objetivo:   Filtra itens do unitizador
=======================================================================================
*/
Static Function FilUnit(cInvoice, cCont, cUnit)
	Local cFiltro := ""

	cFiltro  +=  " ZM_FILIAL = '"+xFilial('SZM')+"'"
	cFiltro  +=  "	AND ZM_INVOICE = '" + cInvoice + "' " + CRLF 
	cFiltro  +=  "	AND ZM_CONT = '" + cCont + "' " + CRLF 
	cFiltro  +=  "	AND ZM_UNIT = '" + cUnit + "' " + CRLF 
 	cFiltro  +=  "	AND D_E_L_E_T_ = ' ' " + CRLF

Return cFiltro

/*
=======================================================================================
Programa.:              CargaUnit
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              15/01/2021
Descricao / Objetivo:   Carrega itens do unitizador com demanda de unitização        
=======================================================================================
*/
Static Function CargaUnit( cInvoice, cCont, cUnit )
	Local aArea			:= GetArea()
	Local cAliasUnit 	:= GetNextAlias()
	Local cAliasD0Q 	:= GetNextAlias()
	Local cNumSeq		:= ""
	Local cAliasQry		:= ""
	Local lAchouD0Q		:= .F.
	Local cArmOrig		:= ""
	Local lQtdExata		:= .F.
	Local nTentativa    := 1
	Local nX            := 0
	Local nCount        := 0

	Default cInvoice	:= ""
	Default cCont		:= ""
	Default cUnit		:= ""

	If Select( cAliasUnit ) > 0
		( cAliasUnit )->( DbCloseArea() )
	EndIf

	If Select( cAliasD0Q ) > 0
		( cAliasUnit )->( DbCloseArea() )
	EndIf

	cQry  :=  " SELECT SZM.ZM_PROD, SZM.ZM_QTDE,SZM.ZM_CASE,SZM.ZM_SERIE " + CRLF
	cQry  +=  " FROM " + RetSQLName( "SZM" ) + " SZM " + CRLF 
	cQry  +=  " WHERE   SZM.ZM_FILIAL  = '" + FWxFilial("SZM") + "' " + CRLF
	cQry  +=  "		AND SZM.ZM_INVOICE = '" + cInvoice + "' " + CRLF 
	//cQry  +=  "	AND SZM.ZM_CONT    = '" + cCont + "' " + CRLF 
	cQry  +=  "		AND SZM.ZM_UNIT    = '" + cUnit + "' " + CRLF 
 	cQry  +=  "		AND SZM.D_E_L_E_T_ = ' ' " + CRLF
	cQry  +=  " ORDER BY SZM.ZM_PROD, SZM.ZM_QTDE " + CRLF 

	cQry	:= ChangeQuery( cQry )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasUnit, .T., .T. )

	If ( cAliasUnit )->( !EOF() )

		While ( cAliasUnit )->( !EOF() )

			For nTentativa := 1 to 2

				if Select(cAliasD0Q) > 0
					DbSelectArea(cAliasD0Q) 
					( cAliasD0Q )->( dbCloseArea() )
				EndIf

				cQry := CRLF + " SELECT D0Q.D0Q_SERVIC, D0Q.D0Q_LOCAL, D0Q.D0Q_ENDER, D0Q.D0Q_PRDORI, "
				cQry += CRLF + " D0Q.D0Q_CODPRO, D0Q.D0Q_LOTECT, D0Q.D0Q_NUMLOT, D0Q.D0Q_QUANT, D0Q.D0Q_NUMSEQ, "
				cQry += CRLF + " D0Q.D0Q_DOCTO, D0Q.D0Q_SERIE, D0Q.D0Q_CLIFOR, D0Q.D0Q_LOJA,D0Q_ID "
				cQry += CRLF + " FROM " + RetSQLName( "SD1" ) + " SD1 "

				cQry += CRLF + " JOIN " + RetSQLName( "D0Q" ) + " D0Q "
				cQry += CRLF + "		ON  D0Q.D0Q_FILIAL = '" + FWxFilial("D0Q") + "' "
				cQry += CRLF + "		AND D0Q.D0Q_DOCTO  = SD1.D1_DOC "
				cQry += CRLF + "		AND D0Q.D0Q_SERIE  = SD1.D1_SERIE "
				cQry += CRLF + "		AND D0Q.D0Q_CLIFOR = SD1.D1_FORNECE "
				cQry += CRLF + "		AND D0Q.D0Q_LOJA   = SD1.D1_LOJA "
				cQry += CRLF + "		AND D0Q.D0Q_CODPRO = SD1.D1_COD "
				cQry += CRLF + "		AND D0Q.D0Q_NUMSEQ = SD1.D1_NUMSEQ "
				cQry += CRLF + "		AND D0Q.D0Q_QUANT  > D0Q.D0Q_QTDUNI " //--Remove itens consumidos por outro unitizador
				cQry += CRLF + "		AND D0Q.D_E_L_E_T_ = ' ' "
				
				if nTentativa == 1
					cQry += CRLF + " 	AND D0Q.D0Q_QUANT >= '" + cValToChar( ( cAliasUnit )->ZM_QTDE ) + "' "
				else
					cQry += CRLF + " 	AND D0Q.D0Q_QUANT < '" + cValToChar( ( cAliasUnit )->ZM_QTDE ) + "' "
				endif

				cQry += CRLF + " WHERE    SD1.D1_FILIAL = '" + FWxFilial("SD1") + "' "
				cQry += CRLF + "		AND SD1.D1_CONHEC = '" + __cProcess + "' "
				cQry += CRLF + "	 	AND SD1.D1_COD    = '" + ( cAliasUnit )->ZM_PROD + "' "
				cQry += CRLF + " 		AND SD1.D1_XCASE  = '" + ( cAliasUnit )->ZM_CASE + "' "
				//--Remove demandas consumidas, validação necessaria por conta do cenario de produtos iguais em um mesmo unitizador
				If !Empty( cNumSeq )
					//cQry += CRLF + "		AND SD1.D1_NUMSEQ NOT IN " + FormatIn(cNumSeq, ";") 
					cQry += CRLF + "		AND D0Q.D0Q_ID NOT IN " + FormatIn(cNumSeq, ";") 
				EndIf

				cQry += CRLF + "		AND SD1.D_E_L_E_T_ = ' ' "
				cQry += CRLF + " ORDER BY D0Q.D0Q_QUANT "

				cQry	:= ChangeQuery( cQry )

				DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasD0Q, .T., .T. )
				DbSelectArea( cAliasD0Q )
				
				if  ( cAliasD0Q )->(!EOF()) .and. nTentativa == 1
					
					Exit
				EndIf
			Next nTentativa
			
			If ( cAliasD0Q )->( !EOF() )

				If !lAchouD0Q //--Usado para gravar apenas uma vez o armazem por ser é igual para todos os itens do processo
					cArmOrig := ( cAliasD0Q )->D0Q_LOCAL //--Usado para avaliação de lock no armazem de origem
					lAchouD0Q := .T.
				EndIf

				nX        := 0
				nQuant    := 0
				lQtdExata := .F.

				While ( cAliasD0Q )->( !EOF() )
					nX++
					
					if nTentativa > 1
						nQuant += ( cAliasD0Q )->D0Q_QUANT
					else
						nQuant := ( cAliasD0Q )->D0Q_QUANT
					EndIf
					
					//--Busca por quantidade exatamente igual ao item para priorizar o consumo total da demanda
					If ( cAliasUnit )->ZM_QTDE == nQuant
						lQtdExata := .T.
						Exit
					EndIf
					
					( cAliasD0Q )->( DbSkip() )
				
				EndDo

				//--Se não encontrou qtd exata, volta ponteiro para o inicio do arquivo
				If !lQtdExata .or.  nTentativa > 1
					( cAliasD0Q )->( DbGoTop() )
				EndIF
				
				nCount := 1
				
				While ( cAliasD0Q )->( !EOF() ) .and. nCount <= nX
					
					nCount++
					
					If RecLock(cTmpUnit,.T.)
						(cTmpUnit)->unitizador	:= cUnit
						(cTmpUnit)->armazem		:= ( cAliasD0Q )->D0Q_LOCAL
						(cTmpUnit)->localiz		:= ( cAliasD0Q )->D0Q_ENDER
						(cTmpUnit)->prdori		:= ( cAliasD0Q )->D0Q_PRDORI
						(cTmpUnit)->codpro		:= ( cAliasD0Q )->D0Q_CODPRO
						(cTmpUnit)->lotect		:= ( cAliasD0Q )->D0Q_LOTECT
						(cTmpUnit)->numlot		:= ( cAliasD0Q )->D0Q_NUMLOT
						(cTmpUnit)->qtdunitz	:= ( cAliasD0Q )->D0Q_QUANT //( cAliasUnit)->ZM_QTDE
						(cTmpUnit)->docto		:= ( cAliasD0Q )->D0Q_DOCTO
						(cTmpUnit)->serie		:= ( cAliasD0Q )->D0Q_SERIE
						(cTmpUnit)->clifor		:= ( cAliasD0Q )->D0Q_CLIFOR
						(cTmpUnit)->loja		:= ( cAliasD0Q )->D0Q_LOJA
						(cTmpUnit)->servic		:= ( cAliasD0Q )->D0Q_SERVIC
						(cTmpUnit)->numseq		:= ( cAliasD0Q )->D0Q_NUMSEQ
						(cTmpUnit)->(MsUnLock())
					EndIf
					
					( cAliasD0Q )->(DbSkip())
				
				EndDo
				//--Verifica se a demanda de um produto foi totalmente consumida	
				
				( cAliasD0Q )->( DbGoTop() )
				
				While ( cAliasD0Q )->(!Eof())
				
					cAliasQry:= GetNextAlias()

					BeginSql Alias cAliasQry
						SELECT qtdunitz as TOTUNIT
						FROM %Exp:cRealName% TMPUNIT
						WHERE TMPUNIT.unitizador = %Exp:cUnit%
						AND TMPUNIT.codpro = %Exp:( cAliasD0Q )->D0Q_CODPRO%
						AND TMPUNIT.numseq = %Exp:( cAliasD0Q )->D0Q_NUMSEQ%
					EndSql

					If (cAliasQry)->TOTUNIT == ( cAliasD0Q )->D0Q_QUANT
						//--Guarda Numseq para avaliação de demandas ja consumidas
						If Empty(cNumSeq)
							cNumSeq := AllTrim( ( cAliasD0Q )->D0Q_ID )//cNumSeq := AllTrim( ( cAliasD0Q )->D0Q_NUMSEQ )
						Else
							cNumSeq := cNumSeq + ";" + AllTrim( ( cAliasD0Q )->D0Q_ID )//cNumSeq := cNumSeq + ";" + AllTrim( ( cAliasD0Q )->D0Q_NUMSEQ )
						EndIf

					EndIf

					(cAliasQry)->( DbCloseArea() )
					( cAliasD0Q )->(DbSkip())
				EndDo

			EndIf

			( cAliasD0Q )->( dbCloseArea() )

			( cAliasUnit )->( DbSkip() )

		EndDo

	EndIf
	( cAliasUnit )->( dbCloseArea() )

	If lAchouD0Q
		
		//--Retorna recnos da SB2 para avaliação de lock
		cAliasQry := GetNextAlias()
		cQry  :=  CRLF + " SELECT SB2.R_E_C_N_O_ AS RECSB2"
		cQry  +=  CRLF + " 	FROM " + RetSQLName( "SZM" ) + " SZM "
		cQry  +=  CRLF + " 	JOIN " + RetSQLName( "SB2" ) + " SB2 "
		cQry  +=  CRLF + "		ON  SB2.B2_FILIAL  = '" + FWxFilial("SB2") + "' "
		cQry  +=  CRLF + "		AND SB2.B2_COD     = SZM.ZM_PROD "
		cQry  +=  CRLF + "		AND SB2.D_E_L_E_T_ = ' ' "
		cQry  +=  CRLF + "		AND ( SB2.B2_LOCAL = '" + cArmDes + "' OR SB2.B2_LOCAL = '" + cArmOrig + "' ) "
		cQry  +=  CRLF + " WHERE SZM.ZM_FILIAL = '" + FWxFilial("SZM") + "' "
		cQry  +=  CRLF + "		AND SZM.ZM_INVOICE = '" + cInvoice + "' "
		//cQry  +=  "		AND SZM.ZM_CONT = '" + cCont + "' "
		cQry  +=  CRLF + "		AND SZM.ZM_UNIT    = '" + cUnit + "' "
 		cQry  +=  CRLF + "		AND SZM.D_E_L_E_T_ = ' ' "
		cQry  +=  CRLF + "	GROUP BY SB2.R_E_C_N_O_ "

		cQry	:= ChangeQuery( cQry )

		DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasQry, .T., .T. )

		(cAliasQry)->( DbGoTop() )
		While (cAliasQry)->( !EOF() )
			//--Adiciona recnos da SB2 para avaliação de lock
			Aadd( __aRecSB2, (cAliasQry)->RECSB2)

			(cAliasQry)->( DbSkip() )
		EndDo

		(cAliasQry)->( DbCloseArea() )

	EndIf
	
	RestArea( aArea )

Return

/*
=====================================================================================
Programa.:              RetErro
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              15/01/2021
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

	cQry  :=  " SELECT utl_raw.cast_to_varchar2(dbms_lob.substr(SZM.ZM_LOGERR)) AS MSGERRO " + CRLF
	cQry  +=  " FROM " + RetSQLName( "SZM" ) + " SZM " + CRLF
	cQry  +=  " WHERE SZM.ZM_FILIAL = '" + FWxFilial("SZM") + "' " + CRLF
	cQry  +=  "		AND SZM.ZM_INVOICE = '" + cInvoice + "' " + CRLF
	
	If !Empty(cCont)
		cQry  +=  "		AND SZM.ZM_CONT = '" + cCont + "' " + CRLF 
	EndIf

	If !Empty(cUnit)
		cQry  +=  "		AND SZM.ZM_UNIT = '" + cUnit + "' " + CRLF 
	EndIf

	cQry  +=  "		AND SZM.ZM_LOGERR IS NOT NULL " + CRLF
 	cQry  +=  "		AND SZM.D_E_L_E_T_ = ' ' " + CRLF
	cQry  +=  "	ORDER BY SZM.R_E_C_N_O_ " + CRLF

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
Data.....:              15/01/2021
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
			ON  D0Q.D0Q_FILIAL = %xFilial:D0Q%
			AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
			AND D0Q.%NotDel%
		INNER JOIN %Table:D0R% D0R
			ON  D0R.D0R_FILIAL = %xFilial:D0R%
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
Data.....:              15/01/2021
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

				If oMoviServ:oMovServic:ChkRecebi(); // Endereçamento, Cross Docking
					.Or. oMoviServ:oMovServic:ChkTransf() // Transferencia // Desfragmentação(Transferencia)
					lRet := oMoviServ:RecEnter()
				ElseIf oMoviServ:oMovServic:ChkSepara(); // Apanhe
					.Or. oMoviServ:oMovServic:ChkReabast() // (Re)Abastecimento
					lRet := oMoviServ:RecExit()
				EndIf
			
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
Data.....:              15/01/2021
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
Data.....:              15/01/2021
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
Data.....:              15/01/2021
Descricao / Objetivo:   Monta temporaria invoices     
=====================================================================================
*/
Static Function zTmpInv(lJob)
   	Local cAliasTmp 	:= GetNextAlias()
    Local cQuery    	:= ""
	Local aCampos       := {}
	Local oTempInv	    := Nil
	Local nQtd 			:= 0
	Local nQtdUni		:= 0
	Local cPerc			:= ""
	Local cMsgErro		:= ""

	Default lJob		:= .F.	

	If Select( cAliasTmp ) > 0
		( cAliasTmp )->( DbCloseArea() )
	EndIf

	IF !Empty(MV_PAR02) .AND. MV_PAR09 <> "CKD" .and. MV_PAR10 <> "CKD"

		cQuery  :=  "  SELECT ZM_FILIAL, ZM_INVOICE, ZM_BL, ZM_FORNEC, ZM_LOJA, W9_HAWB " + CRLF 
		cQuery  +=  "  FROM " + RetSQLName( "SW9" ) + " SW9 " + CRLF
		cQuery  +=  "  INNER JOIN " + RetSQLName( "SZM" ) + " SZM " + CRLF
		cQuery  +=  "  	ON SZM.ZM_FILIAL = '" + FWxFilial("SZM") + "' " + CRLF
		cQuery  +=  "	AND SZM.ZM_INVOICE = SW9.W9_INVOICE " + CRLF
		cQuery  +=  "  	AND SZM.ZM_FORNEC = SW9.W9_FORN " + CRLF
		cQuery  +=  "  	AND SZM.ZM_LOJA = SW9.W9_FORLOJ " + CRLF
		cQuery  +=  "	AND SZM.D_E_L_E_T_ = ' ' " + CRLF
		cQuery  +=  "  	AND SZM.ZM_SERIE = '"+ space(3) + "' " + CRLF
		cQuery  +=  "  INNER JOIN " + RetSQLName( "SB5" ) + " SB5 " + CRLF
		cQuery  +=  "  	ON SB5.B5_FILIAL = '" + FWxFilial("SB5") + "' " + CRLF
		cQuery  +=  "  	AND SB5.B5_COD = SZM.ZM_PROD " + CRLF
		cQuery  +=  "	AND SB5.B5_CTRWMS = '1'  " + CRLF
		cQuery  +=  "	AND SB5.D_E_L_E_T_ = ' ' " + CRLF
		cQuery  +=  "  WHERE SW9.W9_FILIAL = '" + FWxFilial("SW9") + "' " + CRLF
		cQuery  +=  " 	AND SW9.W9_HAWB	BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
		cQuery  += 	" 	AND SW9.W9_INVOICE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + CRLF
		cQuery  += 	" 	AND SW9.W9_FORN BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CRLF
		cQuery  += 	" 	AND SW9.W9_FORLOJ BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " + CRLF  
		cQuery  +=  "  	AND SW9.D_E_L_E_T_ = ' ' " + CRLF
		cQuery  +=  "  GROUP BY ZM_FILIAL, ZM_INVOICE, ZM_BL, ZM_FORNEC, ZM_LOJA, W9_HAWB " + CRLF
		cQuery  +=  "  ORDER BY ZM_BL, ZM_INVOICE " + CRLF
		
	ELSE

		cQuery  :=  "  SELECT ZM_FILIAL, ZM_INVOICE, ZM_BL, ZM_FORNEC, ZM_LOJA, ZM_XPROC AS W9_HAWB" + CRLF 
		cQuery  +=  "  FROM " + RetSQLName( "SZM" ) + " SZM " + CRLF
		cQuery  +=  "  INNER JOIN " + RetSQLName( "SB5" ) + " SB5 " + CRLF
		cQuery  +=  "  	ON SB5.B5_FILIAL = '" + FWxFilial("SB5") + "' " + CRLF
		cQuery  +=  "  	AND SB5.B5_COD = SZM.ZM_PROD " + CRLF
		cQuery  +=  "	AND SB5.B5_CTRWMS = '1'  " + CRLF
		cQuery  +=  "	AND SB5.D_E_L_E_T_ = ' ' " + CRLF
		cQuery  +=  "  WHERE SZM.ZM_FILIAL = '" + FWxFilial("SZM") + "' " + CRLF
		cQuery  +=  "	AND SZM.ZM_XPROC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF	
		cQuery  +=  "	AND SZM.ZM_INVOICE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + CRLF
		cQuery  +=  "  	AND SZM.ZM_FORNEC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CRLF
		cQuery  +=  "  	AND SZM.ZM_LOJA BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " + CRLF
		cQuery  +=  "  	AND SZM.ZM_SERIE >= '" + iif( MV_PAR09 == "CKD" , MV_PAR09 , space(3) ) + "' " + CRLF
		cQuery  +=  "   AND SZM.ZM_SERIE <= '" + iif( MV_PAR10 == "CKD" , MV_PAR10 , space(3) ) + "' " + CRLF
		cQuery  +=  "	AND SZM.D_E_L_E_T_ = ' ' " + CRLF
		cQuery  +=  "  GROUP BY ZM_FILIAL, ZM_INVOICE, ZM_BL, ZM_FORNEC, ZM_LOJA, ZM_XPROC " + CRLF

	ENDIF

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

		oTempInv := FWTemporaryTable():New(cTmpInv)

		aAdd(aCampos, {"Filial"     ,"C"    ,040    ,0  })
		aAdd(aCampos, {"Percentual" ,"C"    ,008    ,0  })
		aAdd(aCampos, {"Invoice"   	,"C"    ,030    ,0  })
		aAdd(aCampos, {"BL"   		,"C"    ,030    ,0  })
		aAdd(aCampos, {"Fornecedor" ,"C"    ,006    ,0  })
		aAdd(aCampos, {"Loja"       ,"C"    ,002    ,0  })
		aAdd(aCampos, {"Qtd"    	,"N"    ,010    ,0  }) 
		aAdd(aCampos, {"QtdUni"    	,"N"    ,010    ,0  })
		aAdd(aCampos, {"Processo"  	,"C"    ,030    ,0  })		
		aAdd(aCampos, {"MsgErro"	,"C"    ,240    ,0  })   

		oTempInv:SetFields( aCampos )
		oTempInv:AddIndex( "01", { "BL" } )
		oTempInv:AddIndex( "02", { "Invoice" } )
		oTempInv:Create()

		(cAliasTmp)->(dbGoTop())
		While (cAliasTmp)->(!Eof())
			__cProcess	:= (cAliasTmp)->W9_HAWB
			nQtd 		:= 0
			nQtdUni		:= 0
			cPerc		:= ""
			
			//--Retorna dados complementares
			RetCompl( (cAliasTmp)->ZM_BL, (cAliasTmp)->ZM_INVOICE, (cAliasTmp)->ZM_FORNEC, (cAliasTmp)->ZM_LOJA, @nQtd, @nQtdUni, @cPerc )

			cMsgErro := RetErro( (cAliasTmp)->ZM_INVOICE )

			If lJob
				If cPerc == "100%" .And. ( (nQtd - nQtdUni) > 0 )
					If RecLock(cTmpInv,.T.)
						(cTmpInv)->Filial		:= AllTrim( (cAliasTmp)->ZM_FILIAL ) + "-" + FWFilialName()
						(cTmpInv)->Percentual	:= cPerc
						(cTmpInv)->Invoice		:= (cAliasTmp)->ZM_INVOICE
						(cTmpInv)->BL			:= (cAliasTmp)->ZM_BL
						(cTmpInv)->Fornecedor	:= (cAliasTmp)->ZM_FORNEC
						(cTmpInv)->Loja			:= (cAliasTmp)->ZM_LOJA 
						(cTmpInv)->Qtd			:= nQtd
						(cTmpInv)->QtdUni		:= nQtdUni
						(cTmpInv)->Processo		:= (cAliasTmp)->W9_HAWB
						(cTmpInv)->MsgErro		:= cMsgErro
						(cTmpInv)->(MsUnLock())
					EndIf
				EndIf
			Else 
				If RecLock(cTmpInv,.T.)
					(cTmpInv)->Filial		:= AllTrim( (cAliasTmp)->ZM_FILIAL ) + "-" + FWFilialName()
					(cTmpInv)->Percentual	:= cPerc
					(cTmpInv)->Invoice		:= (cAliasTmp)->ZM_INVOICE
					(cTmpInv)->BL			:= (cAliasTmp)->ZM_BL
					(cTmpInv)->Fornecedor	:= (cAliasTmp)->ZM_FORNEC
					(cTmpInv)->Loja			:= (cAliasTmp)->ZM_LOJA
					(cTmpInv)->Qtd			:= nQtd
					(cTmpInv)->QtdUni		:= nQtdUni
					(cTmpInv)->Processo		:= (cAliasTmp)->W9_HAWB
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
Data.....:              15/01/2021
Descricao / Objetivo:   Monta temporaria monitor          
=====================================================================================
*/
Static Function zTmpMnt()
	Local cQry   		:= ""
	Local cAliasTmp 	:= GetNextAlias()
	Local aCampos       := {}
	Local oTempMnt	    := Nil
	Local cMsgErro		:= ""

	If Select( cAliasTmp ) > 0
		( cAliasTmp )->( DbCloseArea() )
	EndIf

	cQry  :=  " SELECT SZM.ZM_FILIAL, SZM.ZM_INVOICE, SZM.ZM_CONT, SZM.ZM_UNIT, " + CRLF
    cQry  +=  "  SUM(ZM_QTDE) AS QTD ,SZM.ZM_SERIE" + CRLF
	cQry  +=  " FROM " + RetSQLName( "SZM" ) + " SZM " + CRLF
 	cQry  +=  " WHERE SZM.ZM_FILIAL = '" + FWxFilial("SZM") + "' " + CRLF
	cQry  +=  "		AND SZM.ZM_BL = '" + (cTmpInv)->BL + "' " + CRLF 
	cQry  +=  "		AND SZM.ZM_INVOICE = '" + (cTmpInv)->Invoice + "' " + CRLF 
	cQry  +=  "		AND SZM.ZM_FORNEC = '" + (cTmpInv)->Fornecedor + "' " + CRLF 
	cQry  +=  "		AND SZM.ZM_LOJA = '" + (cTmpInv)->Loja + "' " + CRLF 
	cQry  +=  "		AND SZM.D_E_L_E_T_ = ' ' " + CRLF
 	cQry  +=  " GROUP BY SZM.ZM_FILIAL, SZM.ZM_INVOICE, SZM.ZM_CONT, SZM.ZM_UNIT,SZM.ZM_SERIE " + CRLF
	cQry  +=  " ORDER BY SZM.ZM_FILIAL, SZM.ZM_INVOICE, SZM.ZM_CONT, SZM.ZM_UNIT " + CRLF

	cQry	:= ChangeQuery( cQry )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTmp, .T., .T. )
	If (Select(cTmpMnt) <> 0)
		dbSelectArea(cTmpMnt)
		(cTmpMnt)->(dbCloseArea())
	EndIf

	oTempMnt := FWTemporaryTable():New(cTmpMnt)

	aAdd(aCampos, {"Filial"     	,"C"    ,010    ,0  })
	aAdd(aCampos, {"Invoice"  		,"C"    ,030    ,0  })
	aAdd(aCampos, {"Container"  	,"C"    ,020    ,0  })
	aAdd(aCampos, {"Unitizador" 	,"C"    ,040    ,0  })
	aAdd(aCampos, {"Qtd" 			,"N"    ,013    ,0  })
	aAdd(aCampos, {"Serie" 			,"C"    ,003    ,0  })
	aAdd(aCampos, {"Finalizado"		,"L"    ,001    ,0  })
	aAdd(aCampos, {"MsgErro"		,"C"    ,240    ,0  })

	oTempMnt:SetFields( aCampos )
	oTempMnt:AddIndex("01", { "Invoice" } )
	oTempMnt:AddIndex("02", { "Container" } )
	oTempMnt:AddIndex("03", { "Unitizador" } )
	oTempMnt:Create()

	DbSelectArea(cAliasTmp)
	If (cAliasTmp)->(!Eof())

		//Se o alias estiver aberto, fechar para evitar erros com alias aberto
		
		(cAliasTmp)->(dbGoTop())
		While (cAliasTmp)->(!Eof())

			cMsgErro := RetErro( (cAliasTmp)->ZM_INVOICE, (cAliasTmp)->ZM_CONT, (cAliasTmp)->ZM_UNIT )

			If RecLock(cTmpMnt,.T.)
				(cTmpMnt)->Filial		:= AllTrim( (cAliasTmp)->ZM_FILIAL )
				(cTmpMnt)->Invoice      := AllTrim( (cAliasTmp)->ZM_INVOICE )
				(cTmpMnt)->Container 	:= AllTrim( (cAliasTmp)->ZM_CONT )
				(cTmpMnt)->Unitizador 	:= AllTrim( (cAliasTmp)->ZM_UNIT )		
				(cTmpMnt)->Qtd 			:= (cAliasTmp)->QTD
				(cTmpMnt)->Serie 			:= (cAliasTmp)->ZM_SERIE
				(cTmpMnt)->Finalizado	:= RetD0R( (cAliasTmp)->ZM_UNIT )
				(cTmpMnt)->MsgErro		:= cMsgErro
				(cTmpMnt)->(MsUnLock())
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
Data.....:              15/01/2021
Descricao / Objetivo:   Atualiza Browse         
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
Data.....:              15/01/2021
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
	oReport:HideParamPage()                // Desabilita a impressao da pagina de parametros.
    oReport:HideHeader()                   //--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter()                   //--Define que não será impresso o rodapé padrão da página
    oReport:SetDevice(4)                   //--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetPreview(.T.)                //--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2)              //--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
    //oReport:SetEdit(.T.) 
	
	//Verifica os parâmetros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.F.)
	
	oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTMP}) 
    
    TRCell():New( oSection  ,"ZM_BL"  		,cAliasTMP  ,"BL"       			)
    TRCell():New( oSection  ,"ZM_INVOICE"  	,cAliasTMP  ,"Invoice"	    		)
    TRCell():New( oSection  ,"ZM_UNIT" 		,cAliasTMP  ,"Unitizador"    		)	
    TRCell():New( oSection  ,"D0R_LOCAL"   	,cAliasTMP  ,"Arm. Orig."		    )
    TRCell():New( oSection  ,"D0R_ENDER" 	,cAliasTMP  ,"End. Orig."			)
    TRCell():New( oSection  ,"QTDNF"    	,cAliasTMP  ,"Qtde. NF"				)
    TRCell():New( oSection  ,"D14_LOCAL" 	,cAliasTMP  ,"Arm. Dest."			)
    TRCell():New( oSection  ,"D14_ENDER" 	,cAliasTMP  ,"End. Dest."			)
    TRCell():New( oSection  ,"QTDPRD"  		,cAliasTMP  ,"Qtde. Endereçada."	)
	TRCell():New( oSection  ,"ZM_CONT"  	,cAliasTMP  ,"Container"			)
	TRCell():New( oSection  ,"ZM_LOTE"  	,cAliasTMP  ,"Lote"					)
	TRCell():New( oSection  ,"ZM_CASE"  	,cAliasTMP  ,"Case"					)

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
      
        oSection:Cell( "ZM_BL"  	):SetValue( Alltrim( (cAliasTMP)->ZM_BL ) 		) //--BL
        oSection:Cell( "ZM_INVOICE"	):SetValue( Alltrim( (cAliasTMP)->ZM_INVOICE ) 	) //--Invoice
        oSection:Cell( "ZM_UNIT" 	):SetValue( Alltrim( (cAliasTMP)->ZM_UNIT ) 	) //--Unitizador
        oSection:Cell( "D0R_LOCAL"	):SetValue( Alltrim( (cAliasTMP)->D0R_LOCAL ) 	) //--Arm. Orig.
        oSection:Cell( "D0R_ENDER" 	):SetValue( Alltrim( (cAliasTMP)->D0R_ENDER ) 	) //--End. Orig.
		oSection:Cell( "QTDNF"  	):SetValue( (cAliasTMP)->QTDNF 					) //--Qtde. NF
        oSection:Cell( "D14_LOCAL"	):SetValue( Alltrim( (cAliasTMP)->D14_LOCAL ) 	) //--Arm. Dest.
        oSection:Cell( "D14_ENDER" 	):SetValue( Alltrim( (cAliasTMP)->D14_ENDER ) 	) //--End. Dest.
        oSection:Cell( "QTDPRD" 	):SetValue( (cAliasTMP)->QTDPRD 				) //--Qtde. Endereçada.
		oSection:Cell( "ZM_CONT" 	):SetValue( Alltrim( (cAliasTMP)->ZM_CONT ) 	) //--Container
		oSection:Cell( "ZM_LOTE" 	):SetValue( Alltrim( (cAliasTMP)->ZM_LOTE ) 	) //--Lote
		oSection:Cell( "ZM_CASE" 	):SetValue( Alltrim( (cAliasTMP)->ZM_CASE ) 	) //--Case

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

	cQuery := " SELECT SZMTMP.ZM_BL, SZMTMP.ZM_INVOICE, SZMTMP.ZM_UNIT, D0R.D0R_LOCAL, "			+ CRLF
	cQuery += " D0R.D0R_ENDER, D14.D14_LOCAL, D14.D14_ENDER, SUM( D14.D14_QTDEST ) AS QTDPRD, "		+ CRLF
	cQuery += " SZMTMP.QTDNF, SZMTMP.ZM_LOTE, SZMTMP.ZM_CASE, SZMTMP.ZM_CONT "						+ CRLF
	cQuery += " FROM ( SELECT SZM.ZM_BL, SZM.ZM_INVOICE, SZM.ZM_UNIT,  "							+ CRLF 
  	cQuery += " SUM( SZM.ZM_QTDE ) AS QTDNF, SZM.ZM_LOTE, SZM.ZM_CASE, SZM.ZM_CONT "				+ CRLF
 	cQuery += " FROM " + RetSQLName( 'SZM' ) + " SZM "		 										+ CRLF
	cQuery += "	WHERE SZM.ZM_FILIAL = '" + FWxFilial('SZM') + "' "	 								+ CRLF
    cQuery += "  	AND SZM.ZM_BL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " 				+ CRLF
    cQuery += "  	AND SZM.ZM_INVOICE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " 			+ CRLF
    cQuery += "  	AND SZM.ZM_FORNEC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " 			+ CRLF
    cQuery += "  	AND SZM.ZM_LOJA BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " 			+ CRLF
  	cQuery += "  	AND SZM.D_E_L_E_T_ = ' ' " 														+ CRLF
 	cQuery += "	GROUP BY SZM.ZM_BL, SZM.ZM_INVOICE, SZM.ZM_UNIT, SZM.ZM_LOTE, SZM.ZM_CASE, " 		+ CRLF
	cQuery += " SZM.ZM_CONT ) SZMTMP " 																+ CRLF
  	cQuery += " LEFT JOIN " + RetSQLName( 'D14' ) + " D14 "		 									+ CRLF
	cQuery += " 	ON D14.D14_FILIAL = '" + FWxFilial('D14') + "' "	 							+ CRLF
	cQuery += "		AND D14.D14_IDUNIT = SZMTMP.ZM_UNIT "	 										+ CRLF
	cQuery += "		AND D14.D_E_L_E_T_ = ' ' "	 													+ CRLF
	cQuery += "	LEFT JOIN " + RetSQLName( 'D0R' ) + " D0R "		 									+ CRLF
	cQuery += " 	ON D0R.D0R_FILIAL = '" + FWxFilial('D0R') + "' "	 							+ CRLF
 	cQuery += "		AND D0R.D0R_IDUNIT = SZMTMP.ZM_UNIT "	 										+ CRLF
	cQuery += "	GROUP BY D14.D14_LOCAL, D14.D14_ENDER, D0R.D0R_LOCAL, D0R.D0R_ENDER, "	 			+ CRLF
	cQuery += "	SZMTMP.ZM_LOTE, SZMTMP.ZM_CASE, SZMTMP.ZM_CONT, SZMTMP.ZM_BL, SZMTMP.ZM_INVOICE, "	+ CRLF
	cQuery += "	SZMTMP.ZM_UNIT, SZMTMP.QTDNF "	 													+ CRLF
	cQuery += "	ORDER BY SZMTMP.ZM_BL, SZMTMP.ZM_INVOICE, SZMTMP.ZM_CONT, SZMTMP.ZM_UNIT "			+ CRLF

    cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return

/*
=====================================================================================
Programa.:              RetD0Q
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              06/10/2021
Descricao / Objetivo:   Retorna quantidade classificada e quantidade unitizada
=====================================================================================
*/
Static Function RetD0Q( nQtdUni, nQtdClas )
	Local cQry 			:= 	""
	Local cTMPD0Q 		:= 	GetNextAlias()

	Default nQtdUni		:=	0
	Default nQtdClas	:=	0

	If Select( cTMPD0Q ) > 0
		( cTMPD0Q )->( DbCloseArea() )
	EndIf

	cQry  :=  " SELECT SUM(D0Q_QUANT) AS QTDCLAS, SUM(D0Q_QTDUNI) AS QTDUNIT  " + CRLF
	cQry  +=  " 	FROM " + RetSQLName( "SD1" ) + " SD1 " + CRLF
	
	cQry  +=  " LEFT JOIN " + RetSQLName( "D0Q" ) + " D0Q " + CRLF
	cQry  +=  "		ON  D0Q.D0Q_FILIAL = '" + FWxFilial("D0Q") + "' " + CRLF
	cQry  +=  "		AND D0Q.D0Q_DOCTO  = SD1.D1_DOC " + CRLF
 	cQry  +=  "		AND D0Q.D0Q_SERIE  = SD1.D1_SERIE " + CRLF
 	cQry  +=  "		AND D0Q.D0Q_CLIFOR = SD1.D1_FORNECE " + CRLF
 	cQry  +=  "		AND D0Q.D0Q_LOJA   = SD1.D1_LOJA " + CRLF
	cQry  +=  "		AND D0Q.D0Q_CODPRO = SD1.D1_COD " + CRLF
    cQry  +=  "		AND D0Q.D0Q_NUMSEQ = SD1.D1_NUMSEQ " + CRLF
	cQry  +=  "		AND D0Q.D0Q_ID     = SD1.D1_IDDCF " + CRLF
 	cQry  +=  "		AND D0Q.D_E_L_E_T_ = ' ' " + CRLF
	
	cQry  +=  " WHERE  SD1.D1_FILIAL = '" + FWxFilial("SD1") + "' " + CRLF 
	cQry  +=  "	   AND SD1.D1_CONHEC = '" + __cProcess + "' " + CRLF 

	If !Empty(MV_PAR09)
		cQry  +=  "		AND SD1.D1_SERIE = '" + MV_PAR09 + "'" + CRLF   
	EndIf

 	cQry  +=  "		AND SD1.D_E_L_E_T_ = ' ' " + CRLF

	cQry	:= ChangeQuery( cQry )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTMPD0Q, .T., .T. )

	DbSelectArea(cTMPD0Q)
	If (cTMPD0Q)->( !Eof() )

		nQtdUni 	:= (cTMPD0Q)->(QTDUNIT)
		nQtdClas	:= (cTMPD0Q)->(QTDCLAS)

	EndIf

	(cTMPD0Q)->( DbCloseArea() )

Return

/*
=====================================================================================
Programa.:              RetD0R
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              06/10/2021
Descricao / Objetivo:   Busca por unitizador com montagem finalizada
=====================================================================================
*/
Static Function RetD0R( cIdUnit )
	Local lRet      := .F.
	Local cAliasQry := Nil

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D0R.D0R_IDUNIT
		FROM %Table:D0R% D0R
		WHERE D0R.D0R_FILIAL = %xFilial:D0R%
		AND D0R.D0R_IDUNIT = %Exp:cIdUnit%
		AND D0R.%NotDel%
	EndSql

	If (cAliasQry)->( !Eof() )
		lRet := .T.
	EndIf

	(cAliasQry)->( DbCloseArea() )

Return lRet

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

/*
=========================================================================================
Programa.:              zVldMont
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/01/2022
Descricao / Objetivo:   Confirma se todos os itens foram incluidos no unitizador
=========================================================================================
*/
Static Function zVldMont(cIdUnit,cInvoice)
	Local nQtdD14 := 0
	Local nQtdSZM := 0
	Local cAliasQry := Nil
	Local eol       := CHR(13)+Chr(10)  //Por Algum Motivo o CRLF encontrasse nulo neste trecho

    cAliasQry := GetNextAlias()
    BeginSql Alias cAliasQry
        SELECT SUM(D14.D14_QTDEST) QTDD14
        FROM %Table:D14% D14
        WHERE D14.D14_FILIAL = %xFilial:D14%
        AND D14.D14_IDUNIT = %Exp:cIdUnit%
        AND D14.%NotDel%
    EndSql

    If (cAliasQry)->( !Eof() )
        nQtdD14  := (cAliasQry)->QTDD14
    EndIf

    (cAliasQry)->( DbCloseArea() )

	cAliasQry := GetNextAlias()
    BeginSql Alias cAliasQry
        SELECT SUM(SZM.ZM_QTDE) QTDSZM
        FROM %Table:SZM% SZM
        WHERE SZM.ZM_FILIAL = %xFilial:SZM%
        AND SZM.ZM_UNIT = %Exp:cIdUnit%
		AND SZM.ZM_INVOICE = %Exp:cInvoice%
        AND SZM.%NotDel%
    EndSql

    If (cAliasQry)->( !Eof() )
        nQtdSZM  := (cAliasQry)->QTDSZM
    EndIf

    (cAliasQry)->( DbCloseArea() )
	
	if nQtdD14 <> nQtdSZM
		cErro := "Erro de Transferencia do Unitizador " + cIdUnit + " "	
		cErro += eol + "Quantidade SZM.......:" + Transform(nQtdSZM , "@E 999,999.999")
		cErro += eol + "Quantidade D14 ......:" + Transform(nQtdD14 , "@E 999,999.999")
		cErro += eol + "Diferenca SZM - D14..:" + Transform(nQtdSZM - nQtdD14 , "@E 999,999.999")
		cErro += eol + "Transferencia do Unitizador sera cancelada
		Conout(cErro)
		MsgAlert("Divergencia de Saldo do do Unitizador " + cIdUnit + " ") 
		zPegMont(cIdUnit, cInvoice)
	EndIf

Return nQtdD14 == nQtdSZM

/*
=========================================================================================
Programa.:              zVldMont
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/01/2022
Descricao / Objetivo:   Confirma se todos os itens foram incluidos no unitizador
=========================================================================================
*/
Static Function zPegMont(cIdUnit,cInvoice)
	//Local nQtdD14  := 0
	//Local nQtdSZM  := 0
	Local cAliasQry := Nil
	Local cMemo     := ""
	Local eol       := CHR(13)+Chr(10)  //Por Algum Motivo o CRLF encontrasse nulo neste trecho

    cAliasQry := GetNextAlias()
    BeginSql Alias cAliasQry
        SELECT D14.D14_PRODUT,D14.D14_QTDEST QTDD14
        FROM %Table:D14% D14
        WHERE D14.D14_FILIAL = %xFilial:D14%
        AND D14.D14_IDUNIT = %Exp:cIdUnit%
        AND D14.%NotDel%
    EndSql

    While (cAliasQry)->( !Eof() )
        cMemo += Alltrim((cAliasQry)->D14_PRODUT) + ";" + alltrim( Transform((cAliasQry)->QTDD14 , "@E 999,999.99") ) + eol
		(cAliasQry)->(DbSkip())
    EndDo
	MemoWrite("\Data\D14_" + alltrim(cIdUnit) + ".csv",cMemo)
    (cAliasQry)->( DbCloseArea() )

	cAliasQry := GetNextAlias()
    BeginSql Alias cAliasQry
        SELECT SZM.ZM_PROD ,SZM.ZM_QTDE QTDSZM
        FROM %Table:SZM% SZM
        WHERE SZM.ZM_FILIAL = %xFilial:SZM%
        AND SZM.ZM_UNIT = %Exp:cIdUnit%
		AND SZM.ZM_INVOICE = %Exp:cInvoice%
        AND SZM.%NotDel%
    EndSql

   	cMemo := ""
    
	While (cAliasQry)->( !Eof() )
        cMemo += Alltrim((cAliasQry)->ZM_PROD) + ";" + alltrim( Transform((cAliasQry)->QTDSZM , "@E 999,999.99") )+eol
		(cAliasQry)->(DbSkip())
    EndDo
    
	MemoWrite("\Data\SZM_" + alltrim(cIdUnit) + ".csv",cMemo)
	(cAliasQry)->( DbCloseArea() )

Return 
