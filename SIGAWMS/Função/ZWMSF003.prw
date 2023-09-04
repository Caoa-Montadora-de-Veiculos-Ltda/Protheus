#include "protheus.ch"
#include "fwmvcdef.ch"
#include "WMSA225.CH"

#DEFINE WMSA22501 "WMSA22501"
#DEFINE WMSA22502 "WMSA22502"
#DEFINE WMSA22503 "WMSA22503"
#DEFINE WMSA22504 "WMSA22504"
#DEFINE WMSA22505 "WMSA22505"
#DEFINE WMSA22506 "WMSA22506"
#DEFINE WMSA22507 "WMSA22507"
#DEFINE WMSA22508 "WMSA22508"
#DEFINE WMSA22509 "WMSA22509"
#DEFINE WMSA22510 "WMSA22510"
#DEFINE WMSA22511 "WMSA22511"
#DEFINE WMSA22512 "WMSA22512"
#DEFINE WMSA22513 "WMSA22513"
#DEFINE WMSA22514 "WMSA22514"
#DEFINE WMSA22515 "WMSA22515"
#DEFINE WMSA22516 "WMSA22516"
#DEFINE WMSA22517 "WMSA22517"
#DEFINE WMSA22518 "WMSA22518"
#DEFINE WMSA22519 "WMSA22519"
#DEFINE WMSA22520 "WMSA22520"
#DEFINE WMSA22521 "WMSA22521"
#DEFINE WMSA22522 "WMSA22522"
#DEFINE WMSA22523 "WMSA22523"

Static lPermTrfBlq 	:= .F.
Static oOrdServ   	:= Nil
Static oEtiqUnit  	:= Nil
Static oMovimento 	:= Nil
Static oModelDCF  	:= Nil
Static oModelSel  	:= Nil

/*
=====================================================================================
Programa.:              ZWMSF003
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/03/20
Descricao / Objetivo:   Realiza transferencias entre endereços Wms
Doc. Origem:            
Solicitante:            
=====================================================================================
*/

User Function ZWMSF003() 
	Local aPergs   	:= {}
    Local aCombo    := {"Todas O.S.","O.S. com Erro", "O.S. Não Executada", "O.S. Finalizada", "O.S. em processamento"}
	Local aRet      := {}

	Private oBrowse
	Private cCadastro := "Visualização" // título da tela 

	Conout("ZWMSF003 | Inicio | " + Time() )

	If IsBlind()
		//--Chamada da execução das transferencais via job
		ZWMSProces( .T. )
	Else
		If U_ZGENUSER( RetCodUsr() ,"ZWMSF003" ,.T.)
			aAdd(aPergs, {2 ,"Seleção do tipo da O.S." ,1,aCombo ,70 ,"" ,.F. })

			If ParamBox( aPergs ,"Parametros" ,@aRet )
				oBrowse := FWMBrowse():New()
				oBrowse:SetAlias("SZJ")
				oBrowse:SetMenuDef("")
				oBrowse:SetDescription("Monitor de tranferências WMS CAOA")
				oBrowse:AddLegend("AllTrim(SZJ->ZJ_STATUS) == 'E' "	,"BLACK"   ,"O.S. com Erro"        ) // O.S. com Erro
				oBrowse:AddLegend("Empty(ZJ_STATUS)"				,"GREEN"   ,"O.S. Não Executada"   ) // O.S. Não Executada
				oBrowse:AddLegend("AllTrim(SZJ->ZJ_STATUS) == 'F' "	,"RED"     ,"O.S. Finalizada"      ) // O.S. Finalizada
				oBrowse:AddLegend("AllTrim(SZJ->ZJ_STATUS) == 'X' "	,"YELLOW"  ,"O.S. em processamento") // O.S. em processamento
				oBrowse:SetSeek()
				oBrowse:DisableReport() //Desabilita a impressão das informações disponíveis no Browse
				oBrowse:AddButton("Processar"							, { || ZWMSProc()                      } , , , , .F. , 1 )
				oBrowse:AddButton("Voltar a fila Todas O.S. com Erro"	, { || ZWMSReproc()                    } , , , , .F. , 2 )
				oBrowse:AddButton("Deletar O.S. com Erro"				, { || ZWMSDelete()                    } , , , , .F. , 3 )
				oBrowse:AddButton("Visualizar"							, { || AxVisual("SZJ",SZJ->(Recno()),2)} , , , , .F. , 4 )
				oBrowse:AddButton("Limpar Fila"							, { || zLimpFila()                     } , , , , .F. , 5 )
				oBrowse:AddButton("Importa Arquivo CSV"             	, { || u_ZWMSF019()                    } , , , , .F. , 6 )

				If alltrim( aRet[ 1 ] ) == alltrim( aCombo[ 2 ] ) //--Com erro
    				oBrowse:SetFilterDefault( "AllTrim(SZJ->ZJ_STATUS) == 'E'" )
				ElseIf Alltrim( aRet[ 1 ] ) == Alltrim( aCombo[ 3 ] ) //--Não executadaGAP054
					oBrowse:SetFilterDefault( "Empty(ZJ_STATUS)" )	
				ElseIf Alltrim( aRet[ 1 ] ) == Alltrim( aCombo[ 4 ] ) //--Finalizada
					oBrowse:SetFilterDefault( "AllTrim(SZJ->ZJ_STATUS) == 'F'" )
				ElseIf Alltrim( aRet[ 1 ] ) == Alltrim( aCombo[ 5 ] ) //--Em processamento
					oBrowse:SetFilterDefault( "AllTrim(SZJ->ZJ_STATUS) == 'X'" )
				EndIf

				oBrowse:Activate()
			EndIf
		EndIf
	EndIf

	Conout("ZWMSF003 | Fim | " + Time() )
 
Return

/*
=====================================================================================
Programa.:              ZWMSProc
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/03/20
Descricao / Objetivo:   Processa os registros pendentes
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function ZWMSProc()

	//--Valida o bloqueio de processamento manual
	If GetNewPar( "CMV_WMS004", .F. )
		Processa({|| ZWMSProces()}	,"Consultando as transferencias..."	)
	Else
		MsgAlert( "Esta rotina esta bloqueada para processamento manual." + CRLF +;
				  "Por favor, solicite o desbloqueio ao administrador do sistema.",;
				  "Rotina bloqueada!" )
	EndIf

	oBrowse:Refresh()
	oBrowse:GoTop()

Return

/*
=====================================================================================
Programa.:              ZWMSDelete
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/03/20
Descricao / Objetivo:   Deleta os registros com erro
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function ZWMSDelete()
	Local cAliasQry		:= GetNextAlias()
	Local cQuery 		:= ""

	cQuery	:= CRLF +  " SELECT "
	cQuery 	+= CRLF +  "	SZJ.R_E_C_N_O_ AS RECNO "
	cQuery 	+= CRLF +  " FROM " + RetSQLName("SZJ") + " SZJ "
	cQuery 	+= CRLF +  " WHERE ZJ_FILIAL = '" + FWxFilial("SZJ") + "' "
	cQuery	+= CRLF +  "	AND SZJ.ZJ_STATUS = 'E' " 
	cQuery	+= CRLF +  "	AND SZJ.ZJ_LOCORI = '" + SZJ->ZJ_LOCORI + "' " 
	cQuery	+= CRLF +  "	AND SZJ.ZJ_ENDORI = '" + SZJ->ZJ_ENDORI + "' " 
	cQuery	+= CRLF +  "	AND SZJ.ZJ_IDUNIT = '" + SZJ->ZJ_IDUNIT + "' " 
	cQuery	+= CRLF +  "	AND SZJ.ZJ_LOCDEST = '" + SZJ->ZJ_LOCDEST + "' " 
	cQuery	+= CRLF +  "	AND SZJ.ZJ_IDUDEST = '" + SZJ->ZJ_IDUDEST + "' " 
	cQuery	+= CRLF +  "	AND SZJ.ZJ_ENDDEST = '" + SZJ->ZJ_ENDDEST + "' " 
	cQuery 	+= CRLF +  " 	AND SZJ.D_E_L_E_T_ = ' ' " 

	cQuery	:= ChangeQuery( cQuery )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T. )

	DbSelectArea( cAliasQry )
	If (cAliasQry)->(!EOF())
		
		While (cAliasQry)->(!EOF())
			SZJ->( DbGoTo( (cAliasQry)->RECNO) )
			
			RecLock('SZJ', .F. )
				SZJ->( DbDelete() )
			SZJ->( MsUnlock() )
			
			(cAliasQry)->( DbSkip())
		EndDo

	Else
		MsgAlert( "Só é permitida a exclusão de registros com erro!",;
				   "Monitor de tranferências WMS CAOA")
	EndIf

	oBrowse:Refresh()
	oBrowse:GoTop()

Return

/*
=====================================================================================
Programa.:              ZWMSProces
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/03/20
Descricao / Objetivo:   Consulta tabela do coletor e carrega os dados para gravação
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function ZWMSProces( lJob )
	Local aExAutSel	   	:= {}
	Local aExAutUni	   	:= {}
	Local cAliasQry		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cIDLock		:= ""

	Private __nRecno 	:= 0
	Private __cCodUser	:= ""
	Private __cMsgErro	:= "" 

	Default lJob		:= .F.

	Conout("ZWMSProces | Inicio | " + Time() )

	Conout("ZWMSProces | SMO Antes da abertura | " + Time() )

	If lJob
		RpcSetType(3)
		RpcSetEnv( '01', '2010022001' )
		Conout("ZWMSProces | Abre empresa, execucao via Job | " + Time() )
		//RpcClearEnv()
		//Return
	EndIf

	Conout("ZWMSProces | SMO após abertura | " + Time() )

	Conout("ZWMSProces | Antes da query | " + Time() )

	lPermTrfBlq := SuperGetMv("MV_WMSTRBL",.F.,.F.)

	SZJ->( DbSetOrder(1) ) 
	D14->( DbSetOrder(5) )
	D0Y->( DbSetOrder(1) ) //-- D0Y_FILIAL+D0Y_IDUNIT

	cQuery := CRLF + " SELECT "
	cQuery += CRLF + "	SZJ.ZJ_STATUS, "
	cQuery += CRLF + "	SZJ.ZJ_PRODUTO, "
	cQuery += CRLF + "	SZJ.ZJ_IDUNIT, "
	cQuery += CRLF + "	SZJ.ZJ_LOCORI, "
	cQuery += CRLF + "	SZJ.ZJ_ENDORI, "
	cQuery += CRLF + "	SZJ.ZJ_ENDDEST, "
	cQuery += CRLF + "	SZJ.ZJ_QTDE, "
	cQuery += CRLF + "	SZJ.ZJ_LOCDEST, "
	cQuery += CRLF + "	SZJ.ZJ_IDUDEST, "
	cQuery += CRLF + "	SZJ.ZJ_USR, "
	cQuery += CRLF + "	SZJ.R_E_C_N_O_ AS RECNO "
	cQuery += CRLF + " FROM " + RetSQLName("SZJ") + " SZJ "
	cQuery += CRLF + " WHERE ZJ_FILIAL = '" + FWxFilial("SZJ") + "' "
	cQuery += CRLF + "	AND SZJ.ZJ_STATUS = '"+Space(1)+"' "
	cQuery += CRLF + "	AND SZJ.D_E_L_E_T_ = ' ' "
	cQuery += CRLF + " ORDER BY SZJ.ZJ_PRODUTO,SZJ.R_E_C_N_O_ " 

	cQuery	:= ChangeQuery( cQuery )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T. )

	Conout("ZWMSProces | Após query | " + Time() )

	DbSelectArea( cAliasQry )
	(cAliasQry)->( DbGoTop() )
	
	If !lJob
		ProcRegua( (cAliasQry)->( RecCount() ) )
	EndIf

	If (cAliasQry)->(!Eof())
		
		Conout("ZWMSProces | Query não é fim de arquivo | " + Time() )

		Do While (cAliasQry)->(!Eof())

			Conout("ZWMSProces | Inicio While de gravação | " + Time() )

			__nRecno 	:= (cAliasQry)->RECNO
			__cCodUser	:= (cAliasQry)->ZJ_USR
			aExAutSel 	:= {}
			aExAutUni 	:= {}

			//--Seta o tipo da transferencia como unitizador
			MV_PAR09 := 2

			SZJ->( DbGoTo( __nRecno ) )
			cIDLock := "SZJ" + cValToChar(__nRecno)
			If LockByName(cIDLock, .T., .T.) .And. Empty(SZJ->ZJ_STATUS)

				Conout("ZWMSProces | Após lockbyname | " + Time() )
				Conout("ZWMSProces | Após lockbyname | " + "Unitizador: " + (cAliasQry)->ZJ_IDUNIT + " | " + Time() )

				/*Se houver execução em andamento para os produtos contidos no unitizador atual
				pula para o proximo unitizador para evitar lock de tabela*/
				If VldExec() 
					UnLockByName(cIDLock, .T., .T.)
					(cAliasQry)->(DbSkip())
					Conout("ZWMSProces | Caiu no valid VldExec vai para o proximo registro | " + Time() )
					Loop
				EndIf

				Conout("ZWMSProces | Passou pelo valid VldExec | " + Time() )

				//--Grava a hora inicial do processamento
				RecLock('SZJ', .F. )
					SZJ->ZJ_HORAINI	:= Time()
					SZJ->ZJ_USRPROC	:= IIF( lJob, "JOB", cUserName )
					SZJ->ZJ_STATUS	:= "X"
				SZJ->( MsUnlock() )

				Conout("ZWMSProces | Gravou status SZJ | " + Time() )

				/*Se houver execução em andamento com a mesma hora inicial pula o registro para evitar lock*/
				If VldHrIni()
					UnLockByName(cIDLock, .T., .T.)
					RecLock('SZJ', .F. )
						SZJ->ZJ_HORAINI	:= ""
						SZJ->ZJ_USRPROC	:= ""
						SZJ->ZJ_STATUS	:= ""
					SZJ->( MsUnlock() )
					(cAliasQry)->(DbSkip())
					Conout("ZWMSProces | Caiu no valid VldHrIni | " + Time() )
					Loop
				EndIf

				If !lJob
					// Incrementa a mensagem na régua.
					IncProc("Gerando as transferencias. Unitizador: " + (cAliasQry)->ZJ_IDUNIT )
				EndIf

				aAdd( aExAutUni	, PadR((cAliasQry)->ZJ_IDUNIT	, TamSX3("D14_IDUNIT")[1]) )
				aAdd( aExAutUni	, PadR((cAliasQry)->ZJ_LOCORI	, TamSX3("D14_LOCAL")[1]) )
				aAdd( aExAutUni	, PadR((cAliasQry)->ZJ_ENDORI	, TamSX3("D14_ENDER")[1]) )

				aAdd( aExAutSel	, { 'IDUNIT'	, PadR((cAliasQry)->ZJ_IDUNIT	, TamSX3("D14_IDUNIT")[1]) 	,Nil } )
				aAdd( aExAutSel	, { 'QUANT' 	, (cAliasQry)->ZJ_QTDE 	 									,Nil } )
				aAdd( aExAutSel	, { 'SERVIC' 	, '203' /*Código de transferencia*/							,Nil } )
				aAdd( aExAutSel	, { 'LOCAL' 	, PadR((cAliasQry)->ZJ_LOCORI	, TamSX3("D14_LOCAL")[1])  	,Nil } )
				aAdd( aExAutSel	, { 'ENDER' 	, PadR((cAliasQry)->ZJ_ENDORI	, TamSX3("D14_ENDER")[1])  	,Nil } )
				aAdd( aExAutSel	, { 'LOCDES' 	, PadR((cAliasQry)->ZJ_LOCDEST	, TamSX3("DCF_LOCDES")[1]) 	,Nil } )
				aAdd( aExAutSel	, { 'ENDDES' 	, PadR((cAliasQry)->ZJ_ENDDEST	, TamSX3("DCF_ENDDES")[1]) 	,Nil } )
				aAdd( aExAutSel	, { 'UNIDES' 	, PadR((cAliasQry)->ZJ_IDUDEST	, TamSX3("DCF_UNIDES")[1]) 	,Nil } )

				//--Verifica se o tipo de unitizador esta preenchido
				If D0Y->( DbSeek( FWxFilial("D0Y") + PadR( (cAliasQry)->ZJ_IDUNIT, TamSX3("D0Y_IDUNIT")[1] ) ) )
					If Empty(D0Y->D0Y_TIPUNI)
						__cMsgErro := "Unitizador " + AllTrim( (cAliasQry)->ZJ_IDUNIT ) + " não possui tipo definido na tabela D0Y."

						SZJ->( DbGoTo( __nRecno ) )
						RecLock('SZJ', .F. )
							SZJ->ZJ_MSGERRO := IIF( Empty( __cMsgErro ), "Não gravou erro linha 307", __cMsgErro )
							SZJ->ZJ_STATUS := 'E'
						SZJ->( MsUnlock() )
					Else
						aAdd( aExAutSel	, { 'CODUNI' , D0Y->D0Y_TIPUNI  , Nil } )
						
						If GrvMdlUnit( aExAutUni, aExAutSel )
							SZJ->( DbGoTo( __nRecno ) )
							RecLock('SZJ', .F. )
								SZJ->ZJ_STATUS 	:= 'F'
								SZJ->ZJ_MSGERRO := " "
								SZJ->ZJ_DOCTO	:= oOrdServ:GetDocto()
								SZJ->ZJ_HORAFIM	:= Time()
								SZJ->ZJ_DTFIM	:= dDataBase
							SZJ->( MsUnlock() )
						EndIf

					EndIf
					
				Else

					__cMsgErro := "Unitizador " + AllTrim( (cAliasQry)->ZJ_IDUNIT ) + " não cadastrado na tabela D0Y."

					SZJ->( DbGoTo( __nRecno ) )
					RecLock('SZJ', .F. )
						SZJ->ZJ_MSGERRO := IIF( Empty( __cMsgErro ), "Não gravou erro linha 352", __cMsgErro )
						SZJ->ZJ_STATUS := 'E'
					SZJ->( MsUnlock() )

				EndIf

				If ValType( oOrdServ ) <> "U"
					oOrdServ:Destroy()
				EndIf

				//--Se for job faço a saida do while para que a proxima thread consuma o proximo registro da fila
				/*If lJob
					UnLockByName(cIDLock, .T., .T.)
					Exit
				EndIf*/

				UnLockByName(cIDLock, .T., .T.)

			EndIf

			(cAliasQry)->(DbSkip())

		EndDo

		Conout("ZWMSProces | Fim do While de gravação | " + Time() )
	Else
		If !lJob
			MsgAlert("Não foram encontradas O.S. pendentes de execução!",;
					 "Monitor de tranferências WMS CAOA")
		EndIf	
	EndIf

	(cAliasQry)->(dbCloseArea())

	If lJob
		RpcClearEnv()
	EndIf

	Conout("ZWMSProces | Fim | " + Time() )

Return

/*
=====================================================================================
Programa.:              ModelDef
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/03/20
Descricao / Objetivo:   Modelo de dados
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function ModelDef()
	Local oModel
	Local oStrDCF    := FWFormStruct(1,'DCF')
	Local oStructTab := FWFormModelStruct():New()
	Local oStrUnit   := FWFormModelStruct():New()
	Local oStrPrdUni := FWFormModelStruct():New()
	Local oStrSel    := FWFormModelStruct():New()
	Local aColsSX3   := {}
	Local cDocto     := ""

	If MV_PAR09 == 1

		oModel := MPFormModel():New('CAOAWMS',,{|oModel| ZWMSValid(oModel) },{|oModel| ZWMSCommit(oModel) })
		oModel:AddFields('DCFMASTER',,oStrDCF)
		oModel:SetDescription(STR0001) // Tranferência WMS
		oModel:GetModel('DCFMASTER'):SetDescription(STR0001) // Tranferência WMS

		oStrDCF:SetProperty('*' ,MODEL_FIELD_OBRIGAT,.F.)
		oStrDCF:SetProperty('DCF_DOCTO',MODEL_FIELD_INIT,{|| cDocto := GetSX8Num("DCF","DCF_DOCTO"),Iif(__lSX8,ConfirmSX8(),Nil),cDocto })

		// Monta Struct
		oStructTab:AddTable('SELECAO', {'CODPRO'},'Selecao')
		oStructTab:AddIndex(1,'1','CODPRO',STR0023,'','',.T.) // Produto

		buscarSX3("B1_COD"      ,,aColsSX ) ; oStructTab:AddField(aColsSX3[1],STR0012,'CODPRO' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // cTitulo ,cTooltip,cIdField,cTipo,nTamanho,nDecimal,bValid,bWhen,aValues,lObrigat,bInit,lKey,lNoUpd,lVirtual,cValid // Código do Produto
		buscarSX3("DCF_QUANT"   ,,aColsSX3) ; oStructTab:AddField(aColsSX3[1],STR0013,'QUANT'  ,'N',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) // Quantidade
		buscarSX3("B5_SERVINT"  ,,aColsSX3) ; oStructTab:AddField(aColsSX3[1],STR0014,'SERVIC' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) // Serviço de Transferência
		buscarSX3("DCF_LOCDES"  ,,aColsSX3) ; oStructTab:AddField(aColsSX3[1],STR0015,'LOCDES' ,'C',aColsSX3[3],aColsSX3[4],{|A,B,C,D,E| ValidField(A,B,C,D,E,.F.) },{||.T.},Nil,.F.,,.F.,.T.,.F.) // Armazém Destino
		buscarSX3("DCF_ENDDES"  ,,aColsSX3) ; oStructTab:AddField(aColsSX3[1],STR0016,'ENDDES' ,'C',aColsSX3[3],aColsSX3[4],{|A,B,C,D,E| ValidField(A,B,C,D,E,.F.) },{||.T.},Nil,.F.,,.F.,.T.,.F.) // Endereço Destino
		buscarSX3("D14_LOCAL"   ,,aColsSX3) ; oStructTab:AddField(aColsSX3[1],STR0017,'LOCAL'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Armazém Origem
		buscarSX3("D14_ENDER"   ,,aColsSX3) ; oStructTab:AddField(aColsSX3[1],STR0016,'ENDER'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Endereço Origem
		buscarSX3("D14_LOTECTL" ,,aColsSX3) ; oStructTab:AddField(aColsSX3[1],STR0019,'LOTECTL','C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Lote
		buscarSX3("D14_NUMLOTE" ,,aColsSX3) ; oStructTab:AddField(aColsSX3[1],STR0020,'NUMLOTE','C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Sub-Lote
		buscarSX3("D14_DTVALD"  ,,aColsSX3) ; oStructTab:AddField(aColsSX3[1],STR0052,'DTVALD' ,'D',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Data Validade
		buscarSX3("D14_PRDORI"  ,,aColsSX3) ; oStructTab:AddField(aColsSX3[1],STR0021,'PRDORI' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Produto Origem
		buscarSX3("D14_NUMSER"  ,,aColsSX3) ; oStructTab:AddField(aColsSX3[1],STR0022,'NUMSER' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Número de Serie
		
		If WmsX212118("D0Y")
			buscarSX3("D14_IDUNIT",,aColsSX3) ;  oStructTab:AddField(aColsSX3[1],STR0039,"IDUNIT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Unitizador
			buscarSX3("DCF_UNIDES",,aColsSX3) ;  oStructTab:AddField(aColsSX3[1],STR0040,"UNIDES" ,"C",aColsSX3[3],aColsSX3[4],Nil,{|A,B,C,D,E| WhenField(A,B,C,D,E) },Nil,.F.,,.F.,.F.,.F.) // Unitizador Destino
			buscarSX3("D14_CODUNI",,aColsSX3) ;  oStructTab:AddField(aColsSX3[1],STR0042,"CODUNI" ,"C",aColsSX3[3],aColsSX3[4],Nil,{|A,B,C,D,E| WhenField(A,B,C,D,E) },Nil,.F.,,.F.,.F.,.F.) // Tipo Unitizador
		EndIf

		oModel:AddGrid('SELECAO','DCFMASTER',oStructTab)
		oModel:GetModel('SELECAO'):SetOnlyQuery(.T.)
		oModel:GetModel('SELECAO'):SetOptional(.T.)
		oModel:GetModel('SELECAO'):SetNoInsertLine(.T.)
		oModel:GetModel('SELECAO'):SetNoDeleteLine(.T.)
	Else
		oModel := MPFormModel():New("CAOA225A",,{|oModel| ZWMSValid(oModel) },{|oModel| ZWMSCommit(oModel) })
		oModel:AddFields("DCFMASTER",,oStrDCF)
		oModel:SetDescription(STR0001) // Tranferência WMS
		oModel:GetModel("DCFMASTER"):SetDescription(STR0001) // Tranferência WMS

		oStrDCF:SetProperty("*" ,MODEL_FIELD_OBRIGAT,.F.)
		oStrUnit:SetProperty("*" ,MODEL_FIELD_OBRIGAT,.F.)
		oStrPrdUni:SetProperty("*" ,MODEL_FIELD_OBRIGAT,.F.)
		oStrDCF:SetProperty("DCF_DOCTO",MODEL_FIELD_INIT,{|| cDocto := GetSX8Num("DCF","DCF_DOCTO"),Iif(__lSX8,ConfirmSX8(),Nil),cDocto })

		// Monta Struct dos unitizadores no estoque
		oStrUnit:AddTable("UNITIZ", {"IDUNIT"},STR0035) // Unitizador Estoque
		oStrUnit:AddIndex(1,"1","IDUNIT",STR0002,"","",.T.)

		buscarSX3("D14_OK"    ,,aColsSX3) ; oStrUnit:AddField(aColsSX3[1],""     ,"OK"     ,"L",aColsSX3[3],aColsSX3[4],{|A,B,C,D| SetAfter(A,B,C,D,oModel)},{||.T.},Nil,.F.,,.F.,.F.,.F.) // cTitulo ,cTooltip,cIdField,cTipo,nTamanho,nDecimal,bValid,bWhen,aValues,lObrigat,bInit,lKey,lNoUpd,lVirtual,cValid // Unitizador
		buscarSX3("D14_IDUNIT",,aColsSX3) ; oStrUnit:AddField(aColsSX3[1],STR0002,"IDUNIT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Unitizador
		buscarSX3("D14_CODUNI",,aColsSX3) ; oStrUnit:AddField(aColsSX3[1],STR0003,"CODUNI" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Tipo Unitizador
		buscarSX3("D14_LOCAL" ,,aColsSX3) ; oStrUnit:AddField(aColsSX3[1],STR0004,"LOCAL"  ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Armazém
		buscarSX3("D14_ENDER" ,,aColsSX3) ; oStrUnit:AddField(aColsSX3[1],STR0005,"ENDER"  ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Endereço
		buscarSX3("D14_ESTFIS",,aColsSX3) ; oStrUnit:AddField(aColsSX3[1],STR0006,"ESTFIS" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Estrutura Física
		buscarSX3("D14_PRIOR" ,,aColsSX3) ; oStrUnit:AddField(aColsSX3[1],STR0007,"PRIOR"  ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Prioridade

		oModel:AddGrid("UNITIZ","DCFMASTER",oStrUnit)
		oModel:GetModel('UNITIZ'):SetOptional(.T.)
		oModel:GetModel('UNITIZ'):SetOnlyQuery(.T.)
		oModel:GetModel("UNITIZ"):SetNoInsertLine(.T.)
		oModel:GetModel("UNITIZ"):SetNoDeleteLine(.T.)

		// Monta Struct dos produtos do unitizador
		oStrPrdUni:AddTable("PRDUNI", {"PRODUT+LOTECT+NUMLOT+PRDORI"},STR0036) // Produtos Unitizador
		oStrPrdUni:AddIndex(1,"1","IDUNIT",STR0002,"","",.T.)

		buscarSX3("D14_IDUNIT",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0002,"IDUNIT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Unitizador
		buscarSX3("D14_FILIAL",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0008,"FILIAL" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Filial do Sistema
		buscarSX3("D14_PRODUT",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0009,"PRODUT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Produto
		buscarSX3("D14_LOTECT",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0010,"LOTECT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Lote
		buscarSX3("D14_NUMLOT",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0011,"NUMLOT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Sub-Lote
		buscarSX3("D14_DTVALD",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0012,"DTVALD" ,"D",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Data de Validade
		buscarSX3("D14_DTFABR",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0013,"DTFABR" ,"D",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Data de Fabricação
		buscarSX3("D14_QTDEST",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0014,"QTDEST" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade em Estoque
		buscarSX3("D14_QTDES2",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0015,"QTDES2" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Qt Estoque 2 UM
		buscarSX3("D14_QTDEPR",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0016,"QTDEPR" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Entrada Prevista
		buscarSX3("D14_QTDEP2",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0017,"QTDEP2" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Ent. Prev. 2UM
		buscarSX3("D14_QTDSPR",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0018,"QTDSPR" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Saída Prevista
		buscarSX3("D14_QTDSP2",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0019,"QTDSP2" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Saída Prev 2UM
		buscarSX3("D14_QTDEMP",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0020,"QTDEMP" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Empenho
		buscarSX3("D14_QTDEM2",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0021,"QTDEM2" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Empenho 2UM
		buscarSX3("D14_QTDBLQ",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0022,"QTDBLQ" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Bloqueada
		buscarSX3("D14_QTDBL2",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0023,"QTDBL2" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Bloqueada 2UM
		buscarSX3("D14_QTDPEM",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0024,"QTDPEM" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Quantidade Empenho Prevista
		buscarSX3("D14_QTDPE2",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0025,"QTDPE2" ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Qtd Empenho Previsto 2UM
		buscarSX3("D14_PRDORI",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0026,"PRDORI" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Produto Origem
		buscarSX3("D14_CODVOL",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0027,"CODVOL" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Código do Volume
		buscarSX3("D14_IDVOLU",,aColsSX3); oStrPrdUni:AddField(aColsSX3[1],STR0028,"IDVOLU" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Identificador Volume

		oModel:AddGrid("PRDUNI","UNITIZ",oStrPrdUni)
		oModel:SetRelation("PRDUNI",{{"IDUNIT","IDUNIT"}})
		oModel:GetModel('PRDUNI'):SetOptional(.T.)
		oModel:GetModel('PRDUNI'):SetOnlyQuery(.T.)
		oModel:GetModel("PRDUNI"):SetNoInsertLine(.T.)
		oModel:GetModel("PRDUNI"):SetNoUpdateLine(.T.)
		oModel:GetModel("PRDUNI"):SetNoDeleteLine(.T.)

		// Monta Struct das multiplas DCFs
		oStrSel:AddTable("SELECAO", {"IDUNIT"},STR0037) // Unitizadores selecionados
		oStrSel:AddIndex(1,"1","IDUNIT",STR0002,"","",.T.)

		buscarSX3("D14_IDUNIT",,aColsSX3) ; oStrSel:AddField(aColsSX3[1],STR0002,"IDUNIT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // cTitulo ,cTooltip,cIdField,cTipo,nTamanho,nDecimal,bValid,bWhen,aValues,lObrigat,bInit,lKey,lNoUpd,lVirtual,cValid // Unitizador
		buscarSX3("DCF_QUANT" ,,aColsSX3) ; oStrSel:AddField(aColsSX3[1],STR0029,"QUANT"  ,"N",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Quantidade
		buscarSX3("B5_SERVINT",,aColsSX3) ; oStrSel:AddField(aColsSX3[1],STR0030,"SERVIC" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) // Serviço de Transferência
		buscarSX3("D14_LOCAL" ,,aColsSX3) ; oStrSel:AddField(aColsSX3[1],STR0031,"LOCAL"  ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) // Armazém Origem
		buscarSX3("D14_ENDER" ,,aColsSX3) ; oStrSel:AddField(aColsSX3[1],STR0032,"ENDER"  ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) // Endereço Destino
		buscarSX3("DCF_LOCDES",,aColsSX3) ; oStrSel:AddField(aColsSX3[1],STR0033,"LOCDES" ,"C",aColsSX3[3],aColsSX3[4],{|A,B,C,D,E| ValidField(A,B,C,D,E) },{||.T.},Nil,.F.,,.F.,.T.,.F.) // Armazém Destino
		buscarSX3("DCF_ENDDES",,aColsSX3) ; oStrSel:AddField(aColsSX3[1],STR0034,"ENDDES" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) // Endereço Destino
		buscarSX3("DCF_UNIDES",,aColsSX3) ; oStrSel:AddField(aColsSX3[1],STR0039,"UNIDES" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Unitizador
		buscarSX3("D14_CODUNI",,aColsSX3) ; oStrSel:AddField(aColsSX3[1],STR0041,"CODUNI" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Tipo Unitizador

		oModel:AddGrid("SELECAO","DCFMASTER",oStrSel)
		oModel:GetModel("SELECAO"):SetOnlyQuery(.T.)
		oModel:GetModel("SELECAO"):SetOptional(.T.)
		oModel:GetModel("SELECAO"):SetNoInsertLine(.T.)
		oModel:GetModel("SELECAO"):SetNoDeleteLine(.T.)

	EndIf

Return oModel

/*
=====================================================================================
Programa.:              GrvMdlUnit
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/03/20
Descricao / Objetivo:   Grava modelo de dados para transferencia de unitizador
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function GrvMdlUnit(aExAutUni, aExAutSel)
	Local oModel, oAux, oStruct
	Local nY			:= 0
	Local lRet			:= .T.
	Local aAux 			:= {}
	Local nPos			:= 0
	Local cAliasQry 	:= ""
	Local cWhere    	:= ""
	Local lFirst		:= .T.
	Local aError		:= {}
	Local aRecSB2		:= {}
	Local aSB2Des		:= {}
	Local aRecD14		:= {}
	Local aD14Des		:= {}
	Local aSBEOri		:= {}
	Local aSBEDes		:= {}
	Local bError
	Local oError
	
	Private __cErro		:= ""
	Private __aRecnos	:= {}
	Private lErro		:= .F.

	Conout("GrvMdlUnit | Inicio | " + Time() )

	// Cria as temporárias - FORA DA TRANSAÇÃO
	WMSCTPENDU() 
	WMSCTPRGCV()

	oModel 	:= ModelDef() //FWLoadModel( "CAOA225A" ) 
	oModel:SetOperation(3)
	oModel:Activate()

	oModel:GetModel("UNITIZ"):SetNoInsertLine(.F.)
	oModel:GetModel("UNITIZ"):SetNoDeleteLine(.F.)
	oModel:GetModel("UNITIZ"):ClearData()
	oModel:GetModel("UNITIZ"):InitLine()
	oModel:GetModel("UNITIZ"):GoLine(1)
		
	cWhere := "%"
	If lPermTrfBlq
		cWhere += " AND (D14.D14_QTDEST - (D14.D14_QTDSPR+D14.D14_QTDEMP)) > 0"
	Else
		cWhere += " AND (D14.D14_QTDEST - (D14.D14_QTDSPR+D14.D14_QTDEMP+D14.D14_QTDBLQ)) > 0"
	EndIf
	cWhere += "%"

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT  D14.D14_IDUNIT,
				D14.D14_CODUNI,
				D14.D14_LOCAL,
				D14.D14_ENDER,
				D14.D14_ESTFIS,
				D14.D14_PRIOR
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_IDUNIT = %Exp:aExAutUni[1]%
		AND D14.D14_LOCAL = %Exp:aExAutUni[2]%
		AND D14.D14_ENDER = %Exp:aExAutUni[3]%
		AND D14.D14_IDUNIT <> ' '
		AND D14.%NotDel%
		AND EXISTS (SELECT 1 
					FROM %Table:NNR% NNR
					WHERE NNR.NNR_FILIAL = %xFilial:NNR%
					AND NNR.NNR_CODIGO = D14.D14_LOCAL
					AND NNR.NNR_AMZUNI = '1'
					AND NNR.%NotDel% )
		%Exp:cWhere%
		GROUP BY D14.D14_IDUNIT,
					D14.D14_CODUNI,
					D14.D14_LOCAL,
					D14.D14_ENDER,
					D14.D14_ESTFIS,
					D14.D14_PRIOR
		ORDER BY D14.D14_IDUNIT
	EndSql
	Do While (cAliasQry)->(!Eof())
		If !Empty(oModel:GetModel("UNITIZ"):GetValue("IDUNIT", oModel:GetModel("UNITIZ"):Length()))
			oModel:GetModel("UNITIZ"):AddLine()
			oModel:GetModel("UNITIZ"):GoLine(oModel:GetModel("UNITIZ"):Length())
		EndIf

		oModel:GetModel("UNITIZ"):LoadValue("OK",    .F. )
		oModel:GetModel("UNITIZ"):LoadValue("IDUNIT",(cAliasQry)->D14_IDUNIT )
		oModel:GetModel("UNITIZ"):LoadValue("CODUNI",(cAliasQry)->D14_CODUNI )
		oModel:GetModel("UNITIZ"):LoadValue("LOCAL" ,(cAliasQry)->D14_LOCAL )
		oModel:GetModel("UNITIZ"):LoadValue("ENDER" ,(cAliasQry)->D14_ENDER )
		oModel:GetModel("UNITIZ"):LoadValue("ESTFIS",(cAliasQry)->D14_ESTFIS )
		oModel:GetModel("UNITIZ"):LoadValue("PRIOR" ,(cAliasQry)->D14_PRIOR )

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	oModel:GetModel("UNITIZ"):SetNoInsertLine(.T.)
	oModel:GetModel("UNITIZ"):SetNoDeleteLine(.T.)
	oModel:GetModel("UNITIZ"):GoLine(1)
	
	cAliasQry := ""

	oModel:GetModel("PRDUNI"):SetNoInsertLine(.F.)
	oModel:GetModel("PRDUNI"):SetNoUpDateLine(.F.)
	oModel:GetModel("PRDUNI"):SetNoDeleteLine(.F.)
	oModel:GetModel("PRDUNI"):ClearData()
	oModel:GetModel("PRDUNI"):InitLine()
	oModel:GetModel("PRDUNI"):GoLine(1)

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D14.D14_IDUNIT,
				D14.D14_FILIAL,
				D14.D14_PRODUT,
				D14.D14_LOTECT,
				D14.D14_NUMLOT,
				D14.D14_DTVALD,
				D14.D14_DTFABR,
				D14.D14_QTDEST,
				D14.D14_QTDES2,
				D14.D14_QTDEPR,
				D14.D14_QTDEP2,
				D14.D14_QTDSPR,
				D14.D14_QTDSP2,
				D14.D14_QTDEMP,
				D14.D14_QTDEM2,
				D14.D14_QTDBLQ,
				D14.D14_QTDBL2,
				D14.D14_QTDPEM,
				D14.D14_QTDPE2,
				D14.D14_PRDORI,
				D14.D14_CODVOL,
				D14.D14_IDVOLU,
				D14.D14_LOCAL,
				D14.R_E_C_N_O_ AS RECD14,
				D14.D14_ENDER,
				D14.D14_ESTFIS
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_IDUNIT = %Exp:oModel:GetModel("UNITIZ"):GetValue("IDUNIT")%
		AND D14.D14_IDUNIT <> ' '
		AND D14.%NotDel%
		ORDER BY D14.D14_IDUNIT,D14.D14_PRODUT,D14.D14_LOCAL
	EndSql

	Do While (cAliasQry)->(!Eof())
	
		If !Empty(oModel:GetModel("PRDUNI"):GetValue("IDUNIT", oModel:GetModel("PRDUNI"):Length()))
			oModel:GetModel("PRDUNI"):AddLine()
			oModel:GetModel("PRDUNI"):GoLine(oModel:GetModel("PRDUNI"):Length())
		EndIf
	
		oModel:GetModel("PRDUNI"):LoadValue("IDUNIT",(cAliasQry)->D14_IDUNIT)
		oModel:GetModel("PRDUNI"):LoadValue("FILIAL",(cAliasQry)->D14_FILIAL)
		oModel:GetModel("PRDUNI"):LoadValue("PRODUT",(cAliasQry)->D14_PRODUT)
		oModel:GetModel("PRDUNI"):LoadValue("LOTECT",(cAliasQry)->D14_LOTECT)
		oModel:GetModel("PRDUNI"):LoadValue("NUMLOT",(cAliasQry)->D14_NUMLOT)
		oModel:GetModel("PRDUNI"):LoadValue("DTVALD",IIF(ValType((cAliasQry)->D14_DTVALD) == "C", StoD((cAliasQry)->D14_DTVALD), (cAliasQry)->D14_DTVALD))
		oModel:GetModel("PRDUNI"):LoadValue("DTFABR",StoD((cAliasQry)->D14_DTFABR))
		oModel:GetModel("PRDUNI"):LoadValue("QTDEST",(cAliasQry)->D14_QTDEST)
		oModel:GetModel("PRDUNI"):LoadValue("QTDES2",(cAliasQry)->D14_QTDES2)
		oModel:GetModel("PRDUNI"):LoadValue("QTDEPR",(cAliasQry)->D14_QTDEPR)
		oModel:GetModel("PRDUNI"):LoadValue("QTDEP2",(cAliasQry)->D14_QTDEP2)
		oModel:GetModel("PRDUNI"):LoadValue("QTDSPR",(cAliasQry)->D14_QTDSPR)
		oModel:GetModel("PRDUNI"):LoadValue("QTDSP2",(cAliasQry)->D14_QTDSP2)
		oModel:GetModel("PRDUNI"):LoadValue("QTDEMP",(cAliasQry)->D14_QTDEMP)
		oModel:GetModel("PRDUNI"):LoadValue("QTDEM2",(cAliasQry)->D14_QTDEM2)
		oModel:GetModel("PRDUNI"):LoadValue("QTDBLQ",(cAliasQry)->D14_QTDBLQ)
		oModel:GetModel("PRDUNI"):LoadValue("QTDBL2",(cAliasQry)->D14_QTDBL2)
		oModel:GetModel("PRDUNI"):LoadValue("QTDPEM",(cAliasQry)->D14_QTDPEM)
		oModel:GetModel("PRDUNI"):LoadValue("QTDPE2",(cAliasQry)->D14_QTDPE2)
		oModel:GetModel("PRDUNI"):LoadValue("PRDORI",(cAliasQry)->D14_PRDORI)
		oModel:GetModel("PRDUNI"):LoadValue("CODVOL",(cAliasQry)->D14_CODVOL)
		oModel:GetModel("PRDUNI"):LoadValue("IDVOLU",(cAliasQry)->D14_IDVOLU)

		//-- Pega recno da SB2 para avaliar lock de registro na origem
		AAdd( aRecSB2, RetSB2( (cAliasQry)->(D14_PRODUT), (cAliasQry)->D14_LOCAL ) )

		//-- Pega recno da SB2 para avaliar lock de registro no destino
		AAdd( aSB2Des, RetSB2( (cAliasQry)->(D14_PRODUT), aExAutSel[6][2] ) )

		//-- Pega recno da D14 para avaliar lock de registro na origem
		AAdd( aRecD14, (cAliasQry)->RECD14 )

		//-- Pega recno da D14 para avaliar lock de registro no destino
		AAdd( aD14Des, RetD14Des( (cAliasQry)->(D14_PRODUT), aExAutSel[6][2], aExAutSel[7][2] ) )

		//--Pego o recno somente do primeiro registro, porque os demais são iguais
		If lFirst

			lFirst := .F.

			//-- Pega recno da SBE para avaliar lock de registro na origem
			AAdd( aSBEOri, RetSBE( (cAliasQry)->D14_LOCAL, (cAliasQry)->D14_ENDER, (cAliasQry)->D14_ESTFIS ) )

			//-- Pega recno da SBE para avaliar lock de registro no destino
			AAdd( aSBEDes, RetSBEDes( aExAutSel[6][2], aExAutSel[7][2] ) )

		EndIf

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	Aadd( __aRecnos, { "SB2", aRecSB2 } )
	Aadd( __aRecnos, { "SB2", aSB2Des } )
	Aadd( __aRecnos, { "D14", aRecD14 } )
	Aadd( __aRecnos, { "D14", aD14Des } )
	Aadd( __aRecnos, { "SBE", aSBEOri } )
	Aadd( __aRecnos, { "SBE", aSBEDes } )

	oModel:GetModel("PRDUNI"):SetNoInsertLine(.T.)
	oModel:GetModel("PRDUNI"):SetNoUpDateLine(.T.)
	oModel:GetModel("PRDUNI"):SetNoDeleteLine(.T.)
	oModel:GetModel("PRDUNI"):GoLine(1)

	oAux 	:= oModel:GetModel( 'SELECAO' )
	oStruct := oAux:GetStruct()
	aAux 	:= oStruct:GetFields()

	// Validando campos
	For nY := 1 To Len( aExAutSel )
		If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aExAutSel[nY][1] ) } ) ) > 0
			If !( oModel:LoadValue( 'SELECAO', aExAutSel[nY][1],aExAutSel[nY][2] ) )
				__cMsgErro := "Erro no campo: " + AllTrim( aExAutSel[nY][1] )
				lRet       := .F.
				Exit
			EndIf
		EndIf
	Next

	If lRet 
	
		bError := ErrorBlock( { |oError| GrvErro( oError ) } )
		Begin Sequence

			If ( lRet := oModel:VldData() )

				If !( lRet := oModel:CommitData() )

					aError	:= oModel:GetErrorMessage()

					/*Se identificado lock de registro, não gravo erro e apenas
					retorno False e faço a limpeza da flag de processamento
					para devolver o unitizador a fila.
					Desvio necessario pois o lock no commit estava causando lentidão*/
					If SubStr( aError[6], 1, 4) != "Lock"
						SZJ->( DbGoTo( __nRecno ) )
						RecLock('SZJ', .F. )
							SZJ->ZJ_MSGERRO := IIF( Empty( aError[6] ), "Não gravou erro linha 715", aError[6] )
							SZJ->ZJ_STATUS := 'E'
						SZJ->( MsUnlock() )
					Else
						SZJ->( DbGoTo( __nRecno ) )
						RecLock('SZJ', .F. )
							SZJ->ZJ_MSGERRO := IIF( Empty( aError[6] ), "Não gravou erro linha 721", aError[6] )
							SZJ->ZJ_STATUS := ' '
						SZJ->( MsUnlock() )
					EndIf

				EndIf

			Else 

				If !Empty(__cMsgErro)
					
					SZJ->( DbGoTo( __nRecno ) )
					RecLock('SZJ', .F. )
						SZJ->ZJ_MSGERRO := IIF( Empty( __cMsgErro ), "Não gravou erro linha 734", __cMsgErro )
						SZJ->ZJ_STATUS := 'E'
					SZJ->( MsUnlock() )

				Else

					aError	:= oModel:GetErrorMessage()
					SZJ->( DbGoTo( __nRecno ) )
					RecLock('SZJ', .F. )
						SZJ->ZJ_MSGERRO := IIF( Empty( aError[6] ), "Não gravou erro linha 743", aError[6] )
						SZJ->ZJ_STATUS := 'E'
					SZJ->( MsUnlock() )

				EndIf
			EndIf

		Recover

			//Realiza a gravação do erro
			If !Empty(__cErro)
				lRet := .F.

				SZJ->( DbGoTo( __nRecno ) )
				RecLock('SZJ', .F. )
					SZJ->ZJ_MSGERRO := IIF( Empty( __cErro ), "Não gravou erro linha 757", __cErro )
					SZJ->ZJ_STATUS := 'E'
				SZJ->( MsUnlock() )
			EndIf
			
		End Sequence

		//Restaurando bloco de erro do sistema
		ErrorBlock(bError)

	Else

		SZJ->( DbGoTo( __nRecno ) )
		RecLock('SZJ', .F. )
			SZJ->ZJ_MSGERRO := IIF( Empty( __cMsgErro ), "Não gravou erro linha 770", __cMsgErro )
			SZJ->ZJ_STATUS := 'E'
		SZJ->( MsUnlock() )

	EndIf

	// Desativamos o Model
	oModel:DeActivate()

	// Destroi as temporárias - FORA DA TRANSAÇÃO
	WMSDTPRGCV()
	WMSDTPENDU()

	Conout("GrvMdlUnit | Fim | " + Time() )

Return lRet

/*
=====================================================================================
Programa.:              ZWMSValid
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/03/20
Descricao / Objetivo:   Validações do modelo de dados
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function ZWMSValid(oModel)
	local lRet       := .T.
	Local lRetPE     := .T.
	Local nI         := 0
	Local oModelDCF  := oModel:GetModel("DCFMASTER")
	Local oModelSel  := oModel:GetModel("SELECAO")
	Local aUniDes    := {}
	Local cIdUnit    := ""
	Local cEndDes    := ""
	Local cCabAviso  := ""
	Local cAliasQry  := Nil
	Local nPos       := 0
	Local nLinha     := 0
	Local lUnitOri   := .F.
	Local lUnitDes   := .F.
	Local lTransfPrd := .F. //-- Somente Unitizador
	
	Conout("ZWMSValid | Inicio | " + Time() )

    WmsMsgExibe(.F.) // Exibe a mensagem do WmsMessage

	If MV_PAR09 == 1 // Produto
		lTransfPrd := .T.
	ElseIf MV_PAR09 == 2 // Unitizador
		lTransfPrd := .F.
	EndIf

	If	ExistBlock("WMS225VL")
		lRetPE := ExecBlock("WMS225VL",.F.,.F.,{oModel})
		lRet := If(ValType(lRetPE)=="L",lRetPE,.T.)
	EndIf

	If lRet .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
		// Instancia os objetos para utilizá-los na validação
		oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
		oTipUnit    := WMSDTCUnitizadorArmazenagem():New()
		oTransf     := WMSBCCTransferencia():New()
		// O modelo principal precisa sofrer alguma alteração.
		oModelDCF:LoadValue("DCF_SERVIC",oModelSel:GetValue("SERVIC",1))

		For nI := 1 To oModelSel:Length()
			oModelSel:GoLine(nI)
			If oModelSel:IsDeleted(nI)
				Loop
			EndIf

			lUnitOri  := WmsArmUnit(oModelSel:GetValue("LOCAL",nI))
			lUnitDes  := WmsArmUnit(oModelSel:GetValue("LOCDES",nI))
			cCabAviso := WmsFmtMsg(STR0048,{{"[VAR01]",oModelDCF:GetValue("DCF_DOCTO")},{"[VAR02]",Iif(lTransfPrd,STR0023,STR0039)},{"[VAR03]",oModelSel:GetValue(Iif(lTransfPrd,"CODPRO","IDUNIT"),nI)}}) // "SIGAWMS - OS [VAR01] - [VAR02]: [VAR03]"
			lRet      := .T.
			// Inicializa os objetos
			oTransf:oMovEndOri:ClearData()
			oTransf:oMovEndDes:ClearData()
			oTransf:oMovPrdLot:ClearData()

			// Seta o serviço
			oTransf:oMovServic:SetServico(oModelSel:GetValue("SERVIC",nI))
			// Informações do endereço origem
			oTransf:oMovEndOri:SetArmazem(oModelSel:GetValue("LOCAL",nI))
			oTransf:oMovEndOri:SetEnder(oModelSel:GetValue("ENDER",nI))
			oTransf:oMovEndOri:LoadData()
			// Informações do unitizador origem
			If lUnitOri
				oTransf:SetIdUnit(oModelSel:GetValue("IDUNIT",nI))
			Else
				oTransf:SetIdUnit("")
			EndIf

			// Informações do endereço destino
			oTransf:oMovEndDes:SetArmazem(oModelSel:GetValue("LOCDES",nI))
			oTransf:oMovEndDes:SetEnder(oModelSel:GetValue("ENDDES",nI))
			oTransf:oMovEndDes:LoadData()
			// Informações do unitizador destino
			If lUnitDes
				oTransf:SetUniDes(oModelSel:GetValue("UNIDES",nI))
				oTransf:SetTipUni(oModelSel:GetValue("CODUNI",nI))
			Else
				oTransf:SetUniDes("")
				oTransf:SetTipUni("")
			EndIf

			If !lTransfPrd .And. !(oTransf:oMovEndOri:GetArmazem() == oTransf:oMovEndDes:GetArmazem()) .And. lUnitOri .And. !lUnitDes
				// Busca todos os produtos do unitizador
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT D14.D14_LOCAL,
							D14.D14_PRODUT,
							D14.D14_PRDORI,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_DTVALD,
							D14.D14_NUMSER,
							D14.D14_QTDEST,
							D14.D14_QTDES2
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_IDUNIT = %Exp:oTransf:GetIdUnit()%
					AND D14.%NotDel%
					ORDER BY D14.D14_PRODUT,D14.D14_LOCAL
				EndSql
				Do While lRet .And. (cAliasQry)->(!Eof())
					// Seta a informação do produto do unitizador
					oTransf:oMovPrdLot:SetArmazem((cAliasQry)->D14_LOCAL)
					oTransf:oMovPrdLot:SetProduto((cAliasQry)->D14_PRODUT)
					oTransf:oMovPrdLot:SetPrdOri((cAliasQry)->D14_PRDORI)
					oTransf:oMovPrdLot:SetLoteCtl((cAliasQry)->D14_LOTECT)
					oTransf:oMovPrdLot:SetNumLote((cAliasQry)->D14_NUMLOT)
					oTransf:oMovPrdLot:SetDtValid(IIF(ValType((cAliasQry)->D14_DTVALD) == "C", StoD((cAliasQry)->D14_DTVALD), (cAliasQry)->D14_DTVALD))
					oTransf:oMovPrdLot:SetNumSer((cAliasQry)->D14_NUMSER)
					oTransf:oMovPrdLot:LoadData()
					oTransf:SetQuant((cAliasQry)->D14_QTDEST)
					// Validação do produto
					lRet := VldMdlData(oModelSel,@aUniDes,nI,cCabAviso,lUnitOri,lUnitDes,.T./*lProduto*/)

					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
			Else
				If lTransfPrd
					// Seta a informação do produto que está no modelo
					oTransf:oMovPrdLot:SetArmazem(oModelSel:GetValue("LOCAL"))
					oTransf:oMovPrdLot:SetProduto(oModelSel:GetValue("CODPRO"))
					oTransf:oMovPrdLot:SetPrdOri(oModelSel:GetValue("PRDORI"))
					oTransf:oMovPrdLot:SetLoteCtl(oModelSel:GetValue("LOTECTL"))
					oTransf:oMovPrdLot:SetNumLote(oModelSel:GetValue("NUMLOTE"))
					oTransf:oMovPrdLot:SetDtValid(oModelSel:GetValue("DTVALD"))
					oTransf:oMovPrdLot:LoadData()
				EndIf
				oTransf:SetQuant(oModelSel:GetValue('QUANT'))
				// Validação do produto
				lRet := VldMdlData(oModelSel,@aUniDes,nI,cCabAviso,lUnitOri,lUnitDes,lTransfPrd)
			EndIf
		Next nI

		// Array com os unitizadores destinos para validação da grid para não deixar informar
		// o mesmo unitizador em várias linhas com endereços diferentes ou em branco
		If Len(aUniDes) > 1
			lRet := .T.
			While lRet .And. Len(aUniDes) > 0
				For nI := 1 To Len(aUniDes)
					cIdUnit := aUniDes[nI][1]
					cEndDes := aUniDes[nI][2]
					nLinha  := aUniDes[nI][3]
					// Apaga o unitizador do array
					aDel(aUniDes,nI)
					aSize(aUniDes,Len(aUniDes)-1)

					If Len(aUniDes) == 0
						Exit
					EndIf
					// Analisa se existe o mesmo unitizador no array
					If (nPos := aScan(aUniDes,{|x| x[1] == cIdUnit})) > 0
						// Caso exista o mesmo unitizador em endereços diferentes ou com endereços em branco
						If !(cEndDes == aUniDes[nPos][2]) .Or. (Empty(cEndDes) .And. Empty(aUniDes[nPos][2]))
							aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22519 + " - " + WmsFmtMsg(STR0044,{{"[VAR01]",oModelSel:GetValue("UNIDES",nLinha)},{"[VAR02]",oModelSel:GetValue("CODPRO",nLinha)}}) + " - " + STR0045) // "Unitizador [VAR01] em endereços diferentes informado para o produto [VAR02]."##"Informe outro unitizador ou transfira o unitizador completo."
							lRet := .F.
							Exit
						EndIf
					EndIf
					Exit
				Next nI
			EndDo
		EndIf

		// Mensagem de aviso dos erros do formulário
		If Len(oTransf:oOrdServ:aWmsAviso) > 0

			__cMsgErro := oTransf:oOrdServ:aWmsAviso[1]

			oModel:SetErrorMessage(oModelSel:GetId(),oModelSel:GetId(),,,"SIGAWMS",STR0051,"") // "Existem informações inválidos no formulário!"
			lRet := .F.
		EndIf

		// Destroy objetos
		oTransf:Destroy()
		oTipUnit:Destroy()
		oMntUniItem:Destroy()
	EndIf

	Conout("ZWMSValid | Fim | " + Time() )

Return lRet

/*
=====================================================================================
Programa.:              VldMdlData
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/03/20
Descricao / Objetivo:   Complemento de validações do modelo de dados
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function VldMdlData(oModelSel,aUniDes,nLinha,cCabAviso,lUnitOri,lUnitDes,lProduto)
	Local lRet := .T.

	Conout("VldMdlData | Inicio | " + Time() )

	If oTransf:GetIdUnit() == oTransf:GetUniDes()
		If oTransf:oMovEndOri:GetArmazem()+oTransf:oMovEndOri:GetEnder() == oTransf:oMovEndDes:GetArmazem()+oTransf:oMovEndDes:GetEnder()
			aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22518 + " - " + WmsFmtMsg(STR0043,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "Endereço origem igual ao destino para o [VAR01] [VAR02]."
			Return .F.
		EndIf
	EndIf

	If lProduto
		If QtdComp(oTransf:GetQuant()) <= 0
			aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22501 + " - " + WmsFmtMsg(STR0026,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()}})) // Informe quantidade maior que zero para o produto [VAR01].
			Return .F.
		EndIf

		If !(oTransf:oMovPrdLot:GetProduto() == oTransf:oMovPrdLot:GetPrdOri())
			If !(oTransf:oMovEndOri:GetArmazem() == oTransf:oMovEndDes:GetArmazem())
				aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22514 + " - " + WmsFmtMsg(STR0037,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()}}) + " - " + STR0038) // "Não é permitido tranferir o produto [VAR01] entre armazéns diferentes, pois possui estrutura."###"Realize a desmontagem do produto com estrutura (WMSA510)."
				Return .F.
			EndIf
		EndIf

		If lUnitDes
			// Valida se deve ou não informar o unitizador destino
			If Empty(oTransf:oMovEndDes:GetEnder())
				If Empty(oTransf:GetUniDes())
					lRet := .F.
				EndIf
			Else
				If Empty(oTransf:GetUniDes()) .And. !( cValtoChar(oTransf:oMovEndDes:GetTipoEst()) $ "2|7|8" )
					lRet := .F.
				EndIf
			EndIf

			If !lRet
				aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22504 + " - " + WmsFmtMsg(STR0041,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()}})) // "Unitizador destino não informado para o produto [VAR01]."
				Return .F.
			EndIf

			If !Empty(oTransf:GetUniDes())
				// Valida se o unitizador possui caractere especial
				If !WmsVlStr(oTransf:GetUniDes())
					aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22520 + " - " + WmsFmtMsg(STR0049,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "Unitizador destino contém caracteres inválidos para o [VAR01] [VAR02]"
					Return .F.
				EndIf

				// Valida se existe etiqueta do unitizador
				oMntUniItem:oUnitiz:SetIdUnit(oTransf:GetUniDes())
				If !oMntUniItem:VldIdUnit(4)
					// Valida a existencia do código do unitizador
					aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22522 + " - " + oMntUniItem:GetErro())
					Return .F.
				EndIf
				// Validações apenas se o unitizador destino estiver preenchido
				If lUnitOri

					//-- O trecho abaixo foi comentado pois apresentou o erro
/*GAP*/				//-- InterFunctionCall: cannot find function VLDENDUNI in AppMap on VLDMDLDATA(ZWMSF003.PRW) 19/05/2020 14:01:07 line : 1006
					/*
					// Valida se está movimentando um unitizador parcial e deixando em outro endereço com o mesmo unitizador,
					// pois não é permitido o mesmo unitizador em dois endereços ou armazéns diferentes.
					If !VldEndUni()
						aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22517 + " - " + WmsFmtMsg(STR0044,{{"[VAR01]",oTransf:GetUniDes()},{"[VAR02]",oTransf:oMovPrdLot:GetProduto()}}) + " - " + STR0045) // "Unitizador [VAR01] em endereços diferentes informado para o produto [VAR02]."##"Informe outro unitizador ou transfira o unitizador completo."
						Return .F.
					EndIf*/
				EndIf

				If lRet
					If Empty(oTransf:GetTipUni())
						aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22512 + " - " + WmsFmtMsg(STR0046,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()}})) // "Não foi informado o tipo do unitizador para o produto [VAR01]."
						Return .F.
					Else
						oTipUnit:SetTipUni(oTransf:GetTipUni())
						If oTipUnit:LoadData() //Verifica unitizadores mistos
							If !oTipUnit:CanUniMis() .And. oMntUniItem:oUnitiz:IsMultPrd(oTransf:oMovPrdLot:GetProduto(),,.T.)
								aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22523 + " - " + WmsFmtMsg(STR0053,{{"[VAR01]",oTipUnit:GetTipUni()}})) // "Tipo de unitizador [VAR01] não permite montagem de unitizador misto."
								Return .F.
							EndIf
						Else
							aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22516 + " - " + WmsFmtMsg(STR0047,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()}})) // "Tipo do unitizador não cadastrado para o produto [VAR01]."
							Return .F.
						EndIf
					EndIf
				EndIf
				// Adiciona os endereços destinos informados para validar se foi informado endereços diferetes para o mesmo unitizador destino
				aAdd(aUniDes,{oTransf:GetUniDes(),oTransf:oMovEndDes:GetEnder(),nLinha})
			Else
				// Limpa o Tipo do Unitizador para não gravar indevidamente quando o campo unitizador destino estiver vazio
				oModelSel:LoadValue("CODUNI","",nLinha)
			EndIf
		EndIf
	EndIf

	If Empty(oTransf:oMovServic:GetServico())
		aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22502 + " - " + WmsFmtMsg(STR0027,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "É obrigatório informar um serviço de transferência para o [VAR01] [VAR02]."
		Return .F.
	EndIf

	If oTransf:oMovServic:LoadData()
		If !oTransf:oMovServic:ChkTransf()
			aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22503 + " - " + WmsFmtMsg(STR0028,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "Serviço informado deve ser de transferência para o [VAR01] [VAR02]."
			Return .F.
		EndIf
	Else
		aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22505 + " - " + WmsFmtMsg(STR0029,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "Serviço informado para o [VAR01] [VAR02] não existe no cadastro DC5 (Serviço x Tarefa)."
		Return .F.
	EndIf

	If Empty(oTransf:oMovEndDes:GetArmazem())
		aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22507 + " - " + WmsFmtMsg(STR0030,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "É obrigatório informar o armazém destino para o [VAR01] [VAR02]."
		Return .F.
	Else
		If Empty( Posicione("NNR",1,xFilial("NNR")+oTransf:oMovEndDes:GetArmazem(),"NNR_CODIGO") )
			aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22508 + " - " + WmsFmtMsg(STR0031,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "Armazém destino informado para o [VAR01] [VAR02] não existe no cadastro NNR (Locais de Estoque)."
			Return .F.
		EndIf
	EndIf

	If oTransf:oMovEndOri:GetArmazem() != oTransf:oMovEndDes:GetArmazem()
		If Empty(oTransf:oMovEndDes:GetEnder())
			aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22509 + " - " + WmsFmtMsg(STR0032,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "É obrigatório informar o endereço destino para o [VAR01] [VAR02]."
			Return .F.
		Else
			If Empty( Posicione("SBE",1,xFilial("SBE")+oTransf:oMovEndDes:GetArmazem()+oTransf:oMovEndDes:GetEnder(),"BE_LOCALIZ") )
				aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22510 + " - " + WmsFmtMsg(STR0033,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "Endereço destino informado para o [VAR01] [VAR02] não existe no cadastro SBE (Endereços)."
				Return .F.
			EndIf
		EndIf
	EndIf

	// Verificação do endereço origem
	If !oTransf:ChkEndOri(,,,lPermTrfBlq)
		aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22511 + " - " + oTransf:GetErro()) // Erro ChkEndOri
		Return .F.
	EndIf

	// Verificação do endereço destino
	If !Empty(oTransf:oMovEndDes:GetEnder())
		If !oTransf:ChkEndDes()
			aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22513 + " - " + oTransf:GetErro()) // Erro ChkEndDes
			Return .F.
		EndIf
	EndIf

	Conout("VldMdlData | Fim | " + Time() )

Return lRet

/*
=====================================================================================
Programa.:              ZWMSCommit
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/03/20
Descricao / Objetivo:   Gravação do modelo de dados
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function ZWMSCommit(oModel)
    Local lRet      	:= .T.
    Local nI        	:= 0
	Local nY			:= 0
    Local cAliasQry		:= Nil
    Local lTransfPrd 	:= .F. //-- Somente Unitizador
	Local cMsgLock		:= ""
	
	Conout("ZWMSCommit | INICIO | " + Time() )

	WmsMsgExibe(.F.) // Exibe a mensagem do WmsMessage

	If MV_PAR09 == 1 // Produto
		lTransfPrd := .T.
	ElseIf MV_PAR09 == 2 // Unitizador
		lTransfPrd := .F.
	EndIf

	For nY := 1 To Len(__aRecnos)
		//--Valida lock de tabela
		If U_ZGENLOCK(@cMsgLock, __aRecnos[nY][1], __aRecnos[nY][2])
			oModel:SetErrorMessage( , , oModel:GetId() , "", "", cMsgLock, "", "", "")
			Conout("ZWMSCommit | FIM | " + Time() )
			Return .F.
		EndIf
	Next

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oMovimento := WMSBCCTransferencia():New()
		oOrdServ   := WMSDTCOrdemServicoCreate():New()
		oEtiqUnit  := WMSDTCEtiquetaUnitizador():New()
		oModelDCF  := oModel:GetModel("DCFMASTER")
		oModelSel  := oModel:GetModel("SELECAO")
		//--Função para alimentar a variavel static __oOrdServ usada no fonte WMSXFUNA
		WmsOrdSer(oOrdServ)
		Begin Transaction
			For nI := 1 To oModelSel:Length()
				If oModelSel:IsDeleted(nI)
					Loop
				EndIf
				oModelSel:GoLine(nI)
				// Criação do serviço com origem DCF quando o armazém destino é o mesmo
				If lTransfPrd
					// Atribui produto/Lote/Sublote
					oOrdServ:oProdLote:SetArmazem(oModelSel:GetValue("LOCAL"))
					oOrdServ:oProdLote:SetProduto(oModelSel:GetValue("CODPRO"))
					oOrdServ:oProdLote:SetPrdOri(oModelSel:GetValue("PRDORI"))
					oOrdServ:oProdLote:SetLoteCtl(oModelSel:GetValue("LOTECTL"))
					oOrdServ:oProdLote:SetNumLote(oModelSel:GetValue("NUMLOTE"))
					oOrdServ:oProdLote:SetDtValid(oModelSel:GetValue("DTVALD"))
					oOrdServ:oProdLote:LoadData()
					oOrdServ:oProdLote:SetNumSer("")
				EndIf
				// Atribui endereco origem
				oOrdServ:oOrdEndOri:SetArmazem(oModelSel:GetValue("LOCAL"))
				oOrdServ:oOrdEndOri:SetEnder(oModelSel:GetValue("ENDER"))
				// Atribui endereco destino
				oOrdServ:oOrdEndDes:SetArmazem(oModelSel:GetValue("LOCDES"))
				oOrdServ:oOrdEndDes:SetEnder(oModelSel:GetValue("ENDDES"))
				// Atribui quantidade
				oOrdServ:SetQuant(oModelSel:GetValue("QUANT"))
				oOrdServ:SetOrigem(oModelDCF:GetValue("DCF_ORIGEM"))
				oOrdServ:SetDocto(oModelDCF:GetValue("DCF_DOCTO"))
				// Atribui servico
				oOrdServ:oServico:SetServico(oModelSel:GetValue("SERVIC"))
				oOrdServ:oServico:LoadData()
				// Criação do serviço com origem DH1 quando o armazém é diferente
				If !(oModelSel:GetValue("LOCAL") == oModelSel:GetValue("LOCDES"))
					// Muda a origem do serviço para DH1
					oOrdServ:SetOrigem("DH1")
					If lTransfPrd
						// Gera a DH1 com base nas informações do objeto e incrementa B2_RESERVA
						lRet := WmsGeraDH1("WMSA225")
					Else
						// Criação do serviço com origem DH1 quando o armazém é diferente para cada produto do unitizador
						cAliasQry := GetNextAlias()
						BeginSql Alias cAliasQry
							SELECT D14.D14_LOCAL,
									D14.D14_PRODUT,
									D14.D14_PRDORI,
									D14.D14_LOTECT,
									D14.D14_NUMLOT,
									D14.D14_DTVALD,
									D14.D14_NUMSER,
									D14.D14_QTDEST,
									D14.D14_QTDES2
							FROM %Table:D14% D14
							WHERE D14.D14_FILIAL = %xFilial:D14%
							AND D14.D14_IDUNIT = %Exp:oModelSel:GetValue("IDUNIT")%
							AND D14.%NotDel%
							ORDER BY D14.D14_PRODUT,D14.D14_LOCAL
						EndSql

						Do While lRet .And. (cAliasQry)->(!Eof())
							// Atribui id dcf
							oOrdServ:SetIdDCF(WMSProxSeq('MV_DOCSEQ','DCF_ID'))
							//Informa que a classe não deve gerar um novo Id DCF
							oOrdServ:GeraNovoId(.F.)
							// Seta as informações do produto do unitizador
							oOrdServ:oProdLote:SetArmazem((cAliasQry)->D14_LOCAL)
							oOrdServ:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)
							oOrdServ:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)
							oOrdServ:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)
							oOrdServ:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)
							oOrdServ:oProdLote:SetDtValid(IIF(ValType((cAliasQry)->D14_DTVALD) == "C", StoD((cAliasQry)->D14_DTVALD), (cAliasQry)->D14_DTVALD))
							oOrdServ:oProdLote:SetNumSer((cAliasQry)->D14_NUMSER)
							oOrdServ:oProdLote:LoadData()
							oOrdServ:SetQuant((cAliasQry)->D14_QTDEST)

							// Gera a DH1 com base nas informações do objeto e incrementa B2_RESERVA
							If (lRet := WmsGeraDH1("WMSA225"))

								// Atribui os valores e cria a ordem de serviço por produto
								lRet := GeraOrdSer(oModel,.T./*lProduto*/)

							EndIf
		
							(cAliasQry)->(dbSkip())
						EndDo
						(cAliasQry)->(dbCloseArea())
					EndIf
				EndIf
				//Remove bloqueio de saldos
				If lRet .And. lPermTrfBlq
					If lTransfPrd
						lRet := WMSRemBloq(oModelSel:GetValue("PRDORI"),;
										oModelSel:GetValue("CODPRO"),;
										oModelSel:GetValue("LOTECTL"),;
										oModelSel:GetValue("NUMLOTE"),;
										oModelSel:GetValue("LOCAL"),;
										oModelSel:GetValue("ENDER"),;
										oModelSel:GetValue("IDUNIT"),;
										oModelSel:GetValue("QUANT"),;
										oOrdServ:GetIdDCF(),;
										oOrdServ:GetDocto(),;
										oModel)
					Else
						lRet := WMSRemBlUn(oModelSel:GetValue("IDUNIT"),oOrdServ:GetIdDCF(),oOrdServ:GetDocto(),oModel)
					EndIf
				EndIf
				If lRet .And. (oModelSel:GetValue("LOCAL") == oModelSel:GetValue("LOCDES") .Or. lTransfPrd) 
					// Atribui id dcf
					oOrdServ:SetIdDCF(WMSProxSeq('MV_DOCSEQ','DCF_ID'))
					//Informa que a classe não deve gerar um novo Id DCF
					oOrdServ:GeraNovoId(.F.)
					// Atribui os valores e cria a ordem de serviço
					lRet := GeraOrdSer(oModel,lTransfPrd)
				EndIf		
				If !lRet
					Exit
				EndIf
			Next nI

			If !lRet .Or. lErro
				Disarmtransaction()
			EndIf

		End Transaction

		If Type("__cDocto") == "C"
			__cDocto := oOrdServ:GetDocto()
		EndIf	

		// Destroy objetos
		oMovimento:Destroy()
		oEtiqUnit:Destroy()

	ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
		Begin Transaction
			oOrdServ := WMSDTCOrdemServicoDelete():New()
			If oOrdServ:GoToDCF(DCF->(Recno()))
				If oOrdServ:CanDelete()
					oOrdServ:DeleteDCF()
				Else
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
			//Se foi transferida quantidade bloqueada, refaz o bloqueio
			If lRet
				lRet := RefBloq(DCF->DCF_ID,DCF->DCF_DOCTO,oModel)
			EndIf
			If !lRet
				oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", oOrdServ:GetErro(), "", "", "")
			EndIf
			If !lRet .Or. lErro
				Disarmtransaction()
			EndIf
		End Transaction
	EndIf

	If lErro 
		//--Retorna ao ponto de recover
		BREAK
	EndIf

	Conout("ZWMSCommit | Fim | " + Time() )

Return lRet

/*
=====================================================================================
Programa.:              GeraOrdSer
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/03/20
Descricao / Objetivo:   Gera ordem de serviço
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function GeraOrdSer(oModel,lProduto)
    Local lRet := .T.
	// Atribui informações do unitizador
	oOrdServ:SetIdUnit(oModelSel:GetValue("IDUNIT"))
	If WmsArmUnit(oOrdServ:oOrdEndDes:GetArmazem())
		oOrdServ:oOrdEndDes:LoadData()
		If !( cValtoChar(oOrdServ:oOrdEndDes:GetTipoEst()) $ "2|7|8" )
			oOrdServ:SetUniDes(oModelSel:GetValue("UNIDES"))
			oOrdServ:SetTipUni(oModelSel:GetValue("CODUNI"))
			
			// Atualiza dados da etiqueta do unitizador
			oEtiqUnit:SetIdUnit(oModelSel:GetValue("UNIDES"))
			If oEtiqUnit:LoadData()
				If !oEtiqUnit:GetIsUsed()
					oEtiqUnit:SetUsado("1")
					oEtiqUnit:SetTipUni(oModelSel:GetValue("CODUNI"))
					oEtiqUnit:UpdateD0Y()
				EndIf
			EndIf
		EndIf
	Else
		Conout("Não setou o coduni na etiqueta linha 1352")
		oOrdServ:SetUniDes("")
		oOrdServ:SetTipUni("")
	EndIf
	// Endereco Origem
	oMovimento:SetIdUnit(oOrdServ:GetIdUnit())
	oMovimento:oMovEndOri:SetArmazem(oOrdServ:oOrdEndOri:GetArmazem())
	oMovimento:oMovEndOri:SetEnder(oOrdServ:oOrdEndOri:GetEnder())
	// Endereco Destino
	oMovimento:SetUniDes(oOrdServ:GetUniDes())
	oMovimento:SetTipUni(oOrdServ:GetTipUni())
	oMovimento:oMovEndDes:SetArmazem(oOrdServ:oOrdEndDes:GetArmazem())
	oMovimento:oMovEndDes:SetEnder(oOrdServ:oOrdEndDes:GetEnder())
	If lProduto
		// Produto/Lote
		oMovimento:oMovPrdLot:SetArmazem(oOrdServ:oProdLote:GetArmazem())
		oMovimento:oMovPrdLot:SetPrdOri(oOrdServ:oProdLote:GetPrdOri())
		oMovimento:oMovPrdLot:SetProduto(oOrdServ:oProdLote:GetProduto())
		oMovimento:oMovPrdLot:SetLoteCtl(oOrdServ:oProdLote:GetLoteCtl())
		oMovimento:oMovPrdLot:SetNumLote(oOrdServ:oProdLote:GetNumLote())
		oMovimento:oMovPrdLot:SetNumSer(oOrdServ:oProdLote:GetNumSer())
		oMovimento:oMovPrdLot:LoadData()
	EndIf
	oMovimento:oMovServic:SetServico(oOrdServ:oServico:GetServico())
	oMovimento:oOrdServ:SetDocto(oOrdServ:GetDocto())
	oMovimento:SetQuant(oOrdServ:GetQuant())
	If !oMovimento:ChkEndOri()
		oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", oMovimento:GetErro(), "", "", "")
		lRet := .F.
	EndIf
	If lRet .And. !Empty(oOrdServ:oOrdEndDes:GetEnder())
		If !oMovimento:ChkEndDes()
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", oMovimento:GetErro(), "", "", "")
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If !oOrdServ:CreateDCF()
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", oOrdServ:GetErro(), "", "", "")
			lRet := .F.
		EndIf
	EndIf

	If lRet
		//--Finaliza ordem de serviço automaticamente
		If !FinOrdSer(oModel)
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*
=====================================================================================
Programa.:              FinOrdSer
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              19/03/20
Descricao / Objetivo:   Finaliza ordem de serviço
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function FinOrdSer(oModel)
	Local lRet      := .T.
	Local cAliasD12 := Nil
	Local oMoviServ	:= WMSBCCMovimentoServico():New()
	
	// Efetua a execução automática quando serviço configurado 
	//lRet := WmsExeServ(.F.,.T.) //Função wms padrão
	lRet := ExeAutServ( oModel, oOrdServ:GetIdDCF() )

	If lRet
		cAliasD12 := GetNextAlias()
		BeginSql Alias cAliasD12
			SELECT D12.R_E_C_N_O_ RECNOD12,D12.D12_PRODUT
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = %Exp:oOrdServ:GetIdDCF()%
			AND D12.%NotDel%
			ORDER BY D12.D12_PRODUT
		EndSql
		Do While lRet .And. (cAliasD12)->(!Eof())
			oMoviServ:GoToD12((cAliasD12)->RECNOD12)
			// Finaliza movimento
			oMoviServ:SetQtdLid(oMoviServ:nQtdMovto)
			oMoviServ:dDtGeracao := oOrdServ:GetData()
			oMoviServ:cHrGeracao := oOrdServ:GetHora()
			oMoviServ:dDtInicio  := oOrdServ:GetData()
			oMoviServ:cHrInicio  := oOrdServ:GetHora()
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
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", oMoviServ:GetErro(), "", "", "")
		EndIf

	EndIf

	oMoviServ:Destroy()
Return lRet


/*
=====================================================================================
Programa.:              ExeAutServ
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/07/2020
Descricao / Objetivo:   Executa automaticamente a ordem de serviço
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function ExeAutServ( oModel, cIDdcf )
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
	oOrdSerExe := ZWMSF009():New() 	//WMSDTCOrdemServicoExecute():New()
	oRegraConv := ZWMSF010():New()	//WMSBCCRegraConvocacao():New()
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

	//--Grava erro no modelo de dados
	If !lRet
		oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", oOrdSerExe:GetErro(), "", "", "")
	EndIf

Return lRet

/*
=====================================================================================
Programa.:              ZWMSReproc
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/03/20
Descricao / Objetivo:   Limpa os campos de erro para retorno do registro a fila
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function ZWMSReproc()
	Local cAliasQry		:= GetNextAlias()
	Local cQuery 		:= ""

	Private __nRecno 	:= 0

	SZJ->( DbSetOrder(1) ) 
	D14->( DbSetOrder(5) )

	cQuery	:= " SELECT " + CRLF
	cQuery 	+= "	SZJ.ZJ_STATUS, " + CRLF
	cQuery 	+= "	SZJ.ZJ_PRODUTO, " + CRLF
	cQuery 	+= "	SZJ.ZJ_IDUNIT, " + CRLF
	cQuery 	+= "	SZJ.ZJ_LOCORI, " + CRLF
	cQuery 	+= "	SZJ.ZJ_ENDORI, " + CRLF
	cQuery 	+= "	SZJ.ZJ_ENDDEST, " + CRLF
	cQuery 	+= "	SZJ.ZJ_QTDE, " + CRLF				
	cQuery 	+= "	SZJ.ZJ_LOCDEST, " + CRLF
	cQuery 	+= "	SZJ.ZJ_IDUDEST, " + CRLF
	cQuery 	+= "	SZJ.ZJ_USR, " + CRLF
	cQuery 	+= "	SZJ.R_E_C_N_O_ AS RECNO " + CRLF
	cQuery 	+= " FROM " + RetSQLName("SZJ") + " SZJ " + CRLF
	cQuery 	+= " WHERE ZJ_FILIAL = '" + FWxFilial("SZJ") + "' " + CRLF
	cQuery	+= "	AND SZJ.ZJ_STATUS = 'E' " +  CRLF
	cQuery 	+= " 	AND SZJ.D_E_L_E_T_ = ' ' " +  CRLF	
	
	/*cQuery	+= "	AND SZJ.ZJ_LOCORI = '" + SZJ->ZJ_LOCORI + "' " +  CRLF
	cQuery	+= "	AND SZJ.ZJ_ENDORI = '" + SZJ->ZJ_ENDORI + "' " +  CRLF
	cQuery	+= "	AND SZJ.ZJ_IDUNIT = '" + SZJ->ZJ_IDUNIT + "' " +  CRLF
	cQuery	+= "	AND SZJ.ZJ_LOCDEST = '" + SZJ->ZJ_LOCDEST + "' " +  CRLF
	cQuery	+= "	AND SZJ.ZJ_IDUDEST = '" + SZJ->ZJ_IDUDEST + "' " +  CRLF
	cQuery	+= "	AND SZJ.ZJ_ENDDEST = '" + SZJ->ZJ_ENDDEST + "' " +  CRLF*/
	
	cQuery 	+= " ORDER BY SZJ.ZJ_PRODUTO"+  CRLF
	cQuery	:= ChangeQuery( cQuery )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T. )

	DbSelectArea( cAliasQry )
	(cAliasQry)->( DbGoTop() )
	
	ProcRegua( (cAliasQry)->( RecCount() ) )

	If (cAliasQry)->(!Eof())

		Do While (cAliasQry)->(!Eof())

			__nRecno 	:= (cAliasQry)->RECNO

			// Incrementa a mensagem na régua.
			IncProc("Voltando registro para fila de processamento. Unitizador: " + (cAliasQry)->ZJ_IDUNIT )

			SZJ->( DbGoTo( __nRecno ) )
			RecLock('SZJ', .F. )
				SZJ->ZJ_STATUS 	:= " "
				SZJ->ZJ_MSGERRO := " "
			SZJ->( MsUnlock() )

			(cAliasQry)->(DbSkip())

		EndDo
	Else
		MsgAlert("O.S. com erro não encontrada, certifique-se da existencia de O.S. com erro para reprocessamento!",;
					"Monitor de tranferências WMS CAOA")
	EndIf

	(cAliasQry)->(dbCloseArea())

	oBrowse:Refresh()
	oBrowse:GoTop()

Return

/*
=====================================================================================
Programa.:              RetSB2
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              28/04/20
Descricao / Objetivo:   Retorna RECNO do produto na tabela SB2
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function RetSB2(cCodProd, cArmazem)
	Local __nRecno	:= 0

	SB2->( DbSetOrder(1) )
	If SB2->( DbSeek( FWxFilial("SB2");
					+ Padr( cCodProd, TamSX3("B2_COD")[1] );
					+ Padr( cArmazem, TamSX3("B2_LOCAL")[1] ) ) )
		__nRecno := SB2->( Recno() )
	EndIf                                                                   

Return __nRecno

/*
=====================================================================================
Programa.:              RetD14Des
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              28/04/20
Descricao / Objetivo:   Retorna RECNO do produto na tabela D14 endereço de destino
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function RetD14Des(cCodProd, cArmDes, cEndDes)
	Local __nRecno	:= 0

	D14->( DbSetOrder(3) ) //--D14_FILIAL+D14_LOCAL+D14_PRODUT+D14_ENDER+D14_LOTECT+D14_NUMLOT+D14_NUMSER+D14_IDUNIT  
	If D14->( DbSeek( FWxFilial("D14");
					+ PadR( cArmDes , TamSX3("D14_LOCAL")[1] );
					+ PadR( cCodProd, TamSX3("D14_PRODUT")[1] );
					+ PadR( cEndDes , TamSX3("D14_ENDER")[1] ) ) )
		__nRecno := D14->( Recno() )
	EndIf                                                                         

Return __nRecno

/*
=====================================================================================
Programa.:              RetSBE
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              28/04/20
Descricao / Objetivo:   Retorna RECNO do endereço de origem
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function RetSBE(cArmDes, cEndDes, cEstFis)
	Local __nRecno	:= 0

	SBE->( DbSetOrder(1) ) //--BE_FILIAL+BE_LOCAL+BE_LOCALIZ+BE_ESTFIS
	If SBE->( MSSeek( FWxFilial("SBE");
					+ PadR( cArmDes, TamSX3("BE_LOCAL")[1] );
					+ PadR( cEndDes, TamSX3("BE_LOCALIZ")[1] );
					+ PadR( cEstFis, TamSX3("BE_ESTFIS")[1] ) ) )
		__nRecno := SBE->( Recno() )
	EndIf                                                                         

Return __nRecno

/*
=====================================================================================
Programa.:              RetSBEDes
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              28/04/20
Descricao / Objetivo:   Retorna RECNO do endereço de destino
Doc. Origem:            
Solicitante:            

=====================================================================================
*/
Static Function RetSBEDes(cArmDes, cEndDes)
	Local __nRecno	:= 0

	SBE->( DbSetOrder(1) ) //--BE_FILIAL+BE_LOCAL+BE_LOCALIZ+BE_ESTFIS
	If SBE->( MSSeek( FWxFilial("SBE");
					+ PadR( cArmDes, TamSX3("BE_LOCAL")[1] );
					+ PadR( cEndDes, TamSX3("BE_LOCALIZ")[1] ) ) )
		__nRecno := SBE->( Recno() )
	EndIf                                                                         

Return __nRecno

/*
===========================================================================================
Programa.:              VldExec
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              27/07/20
Descricao / Objetivo:   Valida execuções em andamento para o mesmo armazem e produto
Doc. Origem:            
Solicitante:            
===========================================================================================
*/
Static Function VldExec()
	Local aArea		:= GetArea()
	Local cAliasQry := GetNextAlias()
	Local cQuery 	:= ""
	Local lRet		:= .F.

	Conout("VldExec | antes da query | " + Time() )

	//-- Localiza execuções em andamento para o produto
	cQuery := " SELECT D14.D14_PRODUT " + CRLF
	cQuery += " FROM " + RetSQLName('SZJ') + " SZJ " + CRLF
	cQuery += " INNER JOIN " + RetSQLName('D14') + " D14 " + CRLF
	cQuery += "		ON D14.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "  	AND D14.D14_IDUNIT = SZJ.ZJ_IDUNIT " + CRLF
	cQuery += "  	AND D14.D14_IDUNIT <> '" + SZJ->ZJ_IDUNIT+ "' " +  CRLF
	cQuery += " WHERE SZJ.ZJ_STATUS = 'X' " +  CRLF
	cQuery += "  	AND SZJ.D_E_L_E_T_ = ' ' " +  CRLF
	cQuery += " GROUP BY D14.D14_PRODUT " +  CRLF
	cQuery += " INTERSECT " +  CRLF
	cQuery += " SELECT D14B.D14_PRODUT " + CRLF
	cQuery += " FROM " + RetSQLName('SZJ') + " SZJB " + CRLF
	cQuery += " INNER JOIN " + RetSQLName('D14') + " D14B " + CRLF
	cQuery += "		ON D14B.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "  	AND D14B.D14_IDUNIT = SZJB.ZJ_IDUNIT " + CRLF
	cQuery += " WHERE SZJB.ZJ_IDUNIT = '" + SZJ->ZJ_IDUNIT+ "' " +  CRLF
	cQuery += " 	AND SZJB.D_E_L_E_T_ = ' ' " +  CRLF
	cQuery += " GROUP BY D14B.D14_PRODUT " +  CRLF

	//Conout(cQuery)

	cQuery	:= ChangeQuery( cQuery )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T. )

	//Conout("VldExec | depois da query | " + Time() )

	DbSelectArea( cAliasQry )
	(cAliasQry)->( DbGoTop() )

	lRet := (cAliasQry)->(!Eof())

	(cAliasQry)->(DbCloseArea() )
	RestArea(aArea)
Return lRet

/*
===========================================================================================
Programa.:              VldHrIni
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              28/07/20
Descricao / Objetivo:   Valida hora inicio do processamento para impedir lock de registro
Doc. Origem:            
Solicitante:            
===========================================================================================
*/
Static Function VldHrIni()
	Local aArea		:= GetArea()
	Local cAliasQry := GetNextAlias()
	Local cQuery 	:= ""
	Local lRet		:= .F.

	//Conout("VldHrIni | inicio | " + Time() )

	cQuery := " SELECT ZJ_HORAINI " + CRLF
	cQuery += " FROM " + RetSQLName('SZJ') + " SZJ " + CRLF
	cQuery += " WHERE SZJ.D_E_L_E_T_ = ' ' " + CRLF
 	cQuery += " 	AND SZJ.ZJ_HORAINI = '" + SZJ->ZJ_HORAINI + "' " +  CRLF
 	cQuery += "  	AND SZJ.ZJ_IDUNIT <> '" + SZJ->ZJ_IDUNIT + "' " +  CRLF
	cQuery += "  	AND SZJ.ZJ_STATUS = 'X' " +  CRLF

	cQuery	:= ChangeQuery( cQuery )

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T. )

	DbSelectArea( cAliasQry )
	(cAliasQry)->( DbGoTop() )

	lRet := (cAliasQry)->(!Eof())

	(cAliasQry)->(DbCloseArea() )

	//Conout("VldHrIni | Fim | " + Time() )

	RestArea(aArea)
Return lRet
/*
=====================================================================================
Programa.:              GrvErro
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              29/04/20
Descricao / Objetivo:   Grava erro gerado por controle de exceção
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function GrvErro( oError )
	__cErro := oError:ERRORSTACK
	
	If !Empty(__cErro)
		//--Seta variavel de erro para execução do break
		//--Não foi possivel executar o break neste ponto
		//--Porque se executar o break dentro de um begin transaction
		//--a rotina sai da transação sem realizar o disarm
		lErro := .T.
	EndIf

Return

/*
=====================================================================================
Programa.:              ZWMS3Job
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              18/03/20
Descricao / Objetivo:   Cria job com intervalo entre as threads
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
User Function ZWMS3Job()
	Local nI 		:= 0
	Local nThreads	:= 0
	Local nSeg		:= 0

	Conout("ZWMS3Job | Inicio | " + Time() )

	Conout("ZWMS3Job | SMO Antes da abertura | " + Time() )
	
	RpcSetType(3)
	RpcSetEnv( '01', '2010022001' )

	Conout("ZWMS3Job | SMO após abertura | " + Time() )

	nThreads	:= GetNewPar( "CMV_WMS005", 3 )
	nSeg		:= GetNewPar( "CMV_WMS006", 5000 )

	/*Atrasa a criação de threads em 5 segundos para evitar que sejam executadas
	ao mesmo tempo, o que interfere na validação de lock de tabela*/
	For nI := 1 To nThreads
		Conout("ZWMS3Job | Dentro do For, antes do sleep | " + Time() )
		Sleep(nSeg) //-- Espera 5 Segundos para iniciar a transferencia
		Conout("ZWMS3Job | Dentro do For, após o sleep e antes da transferencia | " + Time() )
		StartJob( "u_ZWMSF003", GetEnvServer(), .F.)
		Conout("ZWMS3Job | Dentro do For, após a transferencia | " + Time() )
	Next

	Conout("ZWMS3Job | Fim | " + Time() )

	RpcClearEnv()

Return

/*
=====================================================================================
Programa.:              zLimpFila
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              23/07/21
Descricao / Objetivo:   Efetua validações antes da chamada do update de limpeza da fila
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function zLimpFila()

	If RetCodUsr() $ GetNewPar( "CMV_WMS018", ' ' )
		If MsgYesNo("Para o correto funcionamento desta rotina é obrigatorio a paralisação do job ";
					+ "de execução das transferencias, confirma a execução?", "WmsCaoa")
			FWMsgRun( ,{|| zUpdTransf() } ,"Efetuando a limpeza da fila de transferencias..." ,"Por favor aguarde...")
		EndIf
	Else
		MsgAlert("É necessario permissão para execução desta rotina, por favor, contate o administrador do sistema!", "WmsCaoa")
	EndIf

Return

/*
=====================================================================================
Programa.:              zUpdTransf
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              23/07/21
Descricao / Objetivo:   Efetua update para limpeza dos registro em execução no WmsCaoa
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static function zUpdTransf()
	Local cUpdate := ""

	cUpdate :=  " UPDATE " + RetSqlName("SZJ")	+ CRLF
	cUpdate	+=  " SET ZJ_STATUS = ' ' "	+ CRLF
	cUpdate +=  " WHERE ZJ_FILIAL = '" + FWxFilial("SZJ") + "' "	+ CRLF    
	cUpdate +=  " AND ZJ_STATUS = 'X' "	+ CRLF
	cUpdate +=  " AND D_E_L_E_T_ = ' ' "	+ CRLF

	If TcSqlExec(cUpdate) < 0
		Help( ,, , "WmsCaoa",, TcSqlError() , 1, 0)
	Else
		MsgInfo("Limpeza da fila efetuada com sucesso, reative o job para reiniciar as transferencias!", "WmsCaoa")
	EndIf

Return

//--------------------------------------------------------------------------
Static Function ValidField(oModel,cField,xValor,nLinha,xValorAnt,lLimpaUnit)
//--------------------------------------------------------------------------
Local lRet      := .T.
Local oView     := Nil
Local oEndereco := Nil
Local lArmUnit  := .F.
Default lLimpaUnit := .T.

Do Case
	Case cField == "LOCDES"
		oView := FWViewActive()
		If Empty(xValor)
			xValor := oModel:GetValue("LOCAL",nLinha)
			// Se o armazém destino foi limpado, atribui o mesmo que o origem
			oModel:LoadValue("LOCDES",xValor,nLinha)
		EndIf	
			
		NNR->(dbSetOrder(1))
		If !Empty(xValor) .And. !(xValor == xValorAnt)
			NNR->(dbSeek(xFilial("NNR")+xValor))
		Else
			NNR->(dbSeek(xFilial("NNR")+xValorAnt))
		EndIf
			
		If WmsX212118("D0Y")
			lArmUnit := WmsArmUnit(NNR->NNR_CODIGO)
	
			If lArmUnit .And. Empty(oModel:GetValue("CODUNI",nLinha))
				oModel:LoadValue("CODUNI",LoadPadrao(),nLinha)
			EndIf
	
			If lLimpaUnit
				If lArmUnit
					If Empty(oModel:GetValue("UNIDES",nLinha))
						oModel:LoadValue("UNIDES", oModel:GetValue("IDUNIT",nLinha) ,nLinha)
					EndIf
				Else
					oModel:LoadValue("UNIDES"," ",nLinha)
				EndIf
			EndIf
		EndIf
		oView:Refresh()
	Case cField == "ENDDES"
		If WmsArmUnit(oModel:GetValue("LOCDES",nLinha))
			If !Empty(oModel:GetValue("ENDDES",nLinha))
				oEndereco := WMSDTCEndereco():New()
				oEndereco:SetArmazem(oModel:GetValue("LOCDES",nLinha))
				oEndereco:SetEnder(oModel:GetValue("ENDDES",nLinha))
				// Desabilita o campo unitizador destino se o endereço informado for um picking
				If oEndereco:LoadData()
					If !(oEndereco:GetTipoEst() == 2 .Or. oEndereco:GetTipoEst() == 7) .And. Empty(oModel:GetValue("CODUNI",nLinha))
						oModel:LoadValue("CODUNI",LoadPadrao(),nLinha)
					EndIf
				EndIf
				oEndereco:Destroy()
			Else
				If Empty(oModel:GetValue("CODUNI",nLinha))
					oModel:LoadValue("CODUNI",LoadPadrao(),nLinha)
				EndIf
			EndIf
		EndIf
EndCase

Return lRet
