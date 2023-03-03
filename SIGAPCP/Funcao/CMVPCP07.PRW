#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"           
/*
=====================================================================================
Programa.:              CMVPCP07
Autor....:              Atilio Amarilla
Data.....:              17/01/2019
Descricao / Objetivo:   Integração PROTHEUS - PCP x MES
Doc. Origem:            Contrato - GAP PCP004
Solicitante:            Cliente
Uso......:              CAOA
Obs......:              Job para Integração de Informações de VIN
=====================================================================================
*/
/*
[OnStart]
jobs=CPP07JOB,MTP13JOB
RefreshRate=300

[CPP07JOB_012010022001]
Environment=ATILIO
Main=U_CPP07JOB
nParms=2
Parm1=01
Parm2=2010022001

[MTP13JOBGRP02]
Environment=ATILIO
Main=U_MTP13JOB
nParms=6
Parm1=1
Parm2=010050
Parm3=010013
Parm4=010060
Parm5=010006
Parm6=010003


[FWSCHDMANAG_ATILIO]
Main=FWSCHDMANAG
Environment=ATILIO

[FWSCHDQUEUE_ATILIO]
Main=FWSCHDQUEUE
Environment=ATILIO

*/
User Function CPP07JOB(cPar1,cPar2)


	Local aParam	:= { { cPar1, cPar2 } }

	U_CMVPCP07( aParam )

Return

User Function zCallP07()


	Local aParam	:= { { "01" , "2010022001" } }

	U_CMVPCP07( aParam )

Return


User Function CMVPCP07( aParam )

	Local cAlias		:= ""
	Local nOper			:= 0
	Local aCpoMaster	:=	{}
	Local aCpoDetail	:=	{}
	Local cCodPro		:= ""

	Local bError	:= ErrorBlock( { |oError| MyError( oError ) } )

	Local lRet		:= .T.
	Local nQtdThread:= 0
	Local cFunTAP	:= ""
	Local nI

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto	   := .T.
	Private lAutoErrNoFile := .T.

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Validação de Parâmetros Empresa / Filial. Necessário para preparação de ambientes                        |
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	If ValType( aParam ) <> "A"
		ConOut("## CMVPCP07 Parametro Empresa/Filial Incorreto [aParam] Kill... ##")
		Return
	ElseIf ValType( aParam[1][1] ) <> "C" .Or. ValType( aParam[1][2] ) <> "C"
		ConOut("## CMVPCP07 Parametro Empresa e/ou Filial Incorreto(s) [aParam] Kill... ##")
		Return
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Controle de semaforo - Nao permitir execução de mais de uma instância:                                   |
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	cNomLck	:=	"CMVPCP07-"+aParam[1][1]+aParam[1][2]

/*	
	If !LockByName(cNomLck,.F.,.F. )
		ConOut("## "+cNomLck+" Ativo Kill... ##")
		MemoWrite("C:\TEMP\CMVPCP07-01-"+DTOS(Date())+"-"+StrTran(Time(),":")+".TXT","## "+cNomLck+" Ativo Kill... ##")
		Return
	Else
		ConOut("## "+cNomLck+" Inicio ##")
		MemoWrite("C:\TEMP\CMVPCP07-02-"+DTOS(Date())+"-"+StrTran(Time(),":")+".TXT","## "+cNomLck+" Inicio ##")
	EndIf
*/
	// Seta job para nao consumir licenças
	// RpcSetType(3)
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Preparação do Ambiente.                                                                                  |
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	RpcSetEnv( aParam[1][1] , aParam[1][2] , Nil, Nil, "PCP", Nil )//, aTables )

	SetFunName("CMVPCP07")
	
	Private cSeqTrim	:= SuperGetMV("CMV_PCP07A",,"003") // C2_SEQUEN para TRIM
	Private cPosPBS1	:= SuperGetMV("CMV_PCP07B",,"013") // Posição PBS

	Private cError

	BEGIN SEQUENCE


		dbSelectArea("SB1")
		SB1->( dbSetOrder(1) )
		dbSelectArea("SC2")
		SC2->( dbSetOrder(1) )
		dbSelectArea("ZZ1")
		ZZ1->( dbSetOrder(1) )
		dbSelectArea("ZZ2")
		ZZ2->( dbSetOrder(1) )
		dbSelectArea("ZZ3")
		ZZ3->( dbSetOrder(1) )
		dbSelectArea("ZZG")
		ZZG->( dbSetOrder(1) )

		ConOut("## CMVPCP07 [Filial "+cFilAnt+"] Iniciado "+Dtoc(Date())+"-"+Time()+" ##")
	/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Seleciona registros a processar													   |
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		
		cAlias 		:= GetNextAlias()
		CALIASD4	:= "CMVPCP07"
		
		BeginSql Alias cAlias

			SELECT *

			FROM %table:ZZG% ZZG

			WHERE ZZG.%NotDel%
				AND ZZG_FILIAL = %xFilial:ZZG%
				AND ZZG_TPINFO <> ' '
				AND ZZG_STATUS = ' '
			
			ORDER BY ZZG_TPINFO, R_E_C_N_O_

		EndSql
		
		//MemoWrite("C:\TEMP\"+FunName()+"-03-"+DTOS(Date())+"-"+StrTran(Time(),":")+".TXT",GetLastQuery()[2])
		//MemoWrite("C:\TEMP\"+FunName()+"-04-"+DTOS(Date())+"-"+StrTran(Time(),":")+".TXT","ZZG_TPINFO 3 PBS "+cPosPBS1+"-"+Subs((cAlias)->ZZG_INFORM,1,3))

		While !(cAlias)->( eof() )
			aCpoMaster	:=	{}
			aCpoDetail	:=	{}
			If ZZ3->( dbSeek(xFilial("ZZ3")+(cAlias)->ZZG_BARCOD ) )
				cCodpro	:= GetAdvFVal("SC2","C2_PRODUTO",xFilial("SC2")+ZZ3->ZZ3_OP)
				SB1->( dbSeek(xFilial("SB1") + cCodpro ))
				If (cAlias)->ZZG_TPINFO == "1" // VIN (Inclusão)
					If !Empty( ZZ3->ZZ3_VIN ) .And. ZZ3->ZZ3_VIN <> (cAlias)->ZZG_INFORM
						ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
						RecLock("ZZG",.F.)
						ZZG->ZZG_STATUS := '2'
						ZZG->ZZG_DESC	:= "[ZZ3] BARCOD " +(cAlias)->ZZG_BARCOD+ " POSSUI VIN DIVERGENTE"
						ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
						ZZG->( msUnlock() )
					ElseIf ZZ1->( dbSeek( xFilial("ZZ1")+(cAlias)->ZZG_INFORM ) )
						ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
						RecLock("ZZG",.F.)
						ZZG->ZZG_STATUS := '1'
						ZZG->ZZG_DESC	:= "[ZZ1] VIN " +AllTrim((cAlias)->ZZG_INFORM) + " JA EXISTE"
						ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
						ZZG->( msUnlock() )
						If !Empty( ZZ3->ZZ3_VIN )
							RecLock("ZZ3",.F.)
							ZZ3->ZZ3_VIN := (cAlias)->ZZG_INFORM
							ZZ3->( msUnlock() )
						EndIf
					Else
						
						//aAdd( aCpoMaster, { 'ZZ1_VIN'		, (cAlias)->ZZG_INFORM } )
						//aAdd( aCpoMaster, { 'ZZ1_PRODUT'	, ZZ3->ZZ3_PRODUT } )
						//aAdd( aCpoMaster, { 'ZZ1_DESC'		, GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+ZZ3->ZZ3_PRODUT,1,"") } )

						//aAdd( aCpoDetail, { 'ZZ1_VIN'		, (cAlias)->ZZG_INFORM } )
						//aAdd( aCpoDetail, { 'ZZ1_PRODUT'	, (cAlias)->ZZG_PRODUT } )
						
						//aAux	:= Import(  "MVCPCP01"/*cModel*/, 3/*nOper*/, "ZZ1"/*cMaster*/, "ZZ2"/*cDetail*/, aCpoMaster, aCpoDetail )
	
						RecLock("ZZ1",.T.)
						ZZ1->ZZ1_FILIAL	:= xFilial("ZZ1")
						ZZ1->ZZ1_VIN	:= (cAlias)->ZZG_INFORM
						ZZ1->ZZ1_PRODUT	:= cCodpro
						ZZ1->ZZ1_DESC	:= SB1->B1_DESC
						ZZ1->ZZ1_BARCOD	:= ZZ3->ZZ3_BARCOD
						ZZ1->ZZ1_OP		:= ZZ3->ZZ3_OP
						ZZ1->( msUnlock() )

						ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
						//If aAux[1] // Inclusão Confirmada
							RecLock("ZZG",.F.)
							ZZG->ZZG_STATUS := '1'
							ZZG->ZZG_DESC	:= "[ZZ1] VIN " +AllTrim((cAlias)->ZZG_INFORM) + " INCLUIDO"
							ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
							ZZG->( msUnlock() )
							
							RecLock("ZZ3",.F.)
							ZZ3->ZZ3_VIN := (cAlias)->ZZG_INFORM
							ZZ3->( msUnlock() )
						//Else
						//EndIf
					EndIf
				ElseIf (cAlias)->ZZG_TPINFO $ "24" // ITEM DE SEGURANÇA (Inclusão) / Motor (4)
					If Empty( ZZ3->ZZ3_VIN )
						ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
						RecLock("ZZG",.F.)
						ZZG->ZZG_STATUS := '2'
						ZZG->ZZG_DESC	:= "[ZZ3] BARCOD " +(cAlias)->ZZG_BARCOD+ " NAO POSSUI VIN ASSOCIADO"
						ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
						ZZG->( msUnlock() )
					ElseIf !ZZ1->( dbSeek( xFilial("ZZ1")+ZZ3->ZZ3_VIN ) )
						ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
						RecLock("ZZG",.F.)
						ZZG->ZZG_STATUS := '2'
						ZZG->ZZG_DESC	:= "[ZZ1] VIN " +AllTrim(ZZ3->ZZ3_VIN) + " NAO CADASTRADO"
						ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
						ZZG->( msUnlock() )
					ElseIf ZZ2->( dbSeek( xFilial("ZZ2")+ZZ3->ZZ3_VIN+(cAlias)->ZZG_PRODUT ) )
						ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
						RecLock("ZZG",.F.)
						If ZZ2->ZZ2_ETIQ <> (cAlias)->ZZG_INFORM
							ZZG->ZZG_STATUS := '2'
							ZZG->ZZG_DESC	:= "[ZZ2] ETIQUETA " +AllTrim((cAlias)->ZZG_INFORM) + " DIVERGENTE"
						Else
							ZZG->ZZG_STATUS := '1'
							ZZG->ZZG_DESC	:= "[ZZ2] ETIQUETA " +AllTrim((cAlias)->ZZG_INFORM) + " JA CADASTRADA"
						Endif
						ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
						ZZG->( msUnlock() )
					ElseIf (cAlias)->ZZG_TPINFO == "4" .And. !Empty( ZZ1->ZZ1_MOTOR )// Motor
						ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
						RecLock("ZZG",.F.)
						If AllTrim(ZZ1->ZZ1_MOTOR) <> AllTrim((cAlias)->ZZG_PRODUT)
							ZZG->ZZG_STATUS := '2'
							ZZG->ZZG_DESC	:= "[ZZ1] CODIGO DO MOTOR " +AllTrim((cAlias)->ZZG_PRODUT) + " DIVERGENTE"
						Else
							ZZG->ZZG_STATUS := '1'
							ZZG->ZZG_DESC	:= "[ZZ1] CODIGO DO MOTOR " +AllTrim((cAlias)->ZZG_PRODUT) + " JA CADASTRADO"
						Endif
						ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
						ZZG->( msUnlock() )
					Else
						
						//aAdd( aCpoMaster, { 'ZZ1_VIN'		, (cAlias)->ZZG_INFORM } )
						//aAdd( aCpoMaster, { 'ZZ1_PRODUT'	, ZZ3->ZZ3_PRODUT } )
						//aAdd( aCpoMaster, { 'ZZ1_DESC'		, GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+ZZ3->ZZ3_PRODUT,1,"") } )

						//aAdd( aCpoDetail, { 'ZZ1_VIN'		, (cAlias)->ZZG_INFORM } )
						//aAdd( aCpoDetail, { 'ZZ1_PRODUT'	, (cAlias)->ZZG_PRODUT } )
						
						//aAux	:= Import(  "MVCPCP01"/*cModel*/, 3/*nOper*/, "ZZ1"/*cMaster*/, "ZZ2"/*cDetail*/, aCpoMaster, aCpoDetail )
	
						RecLock("ZZ2",.T.)
						ZZ2->ZZ2_FILIAL	:= xFilial("ZZ2")
						ZZ2->ZZ2_VIN	:= ZZ1->ZZ1_VIN
						ZZ2->ZZ2_ITSEG	:= (cAlias)->ZZG_PRODUT
						ZZ2->ZZ2_DESC	:= GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+(cAlias)->ZZG_PRODUT,1,"")
						ZZ2->ZZ2_ETIQ	:= (cAlias)->ZZG_INFORM
						ZZ2->( msUnlock() )

						If (cAlias)->ZZG_TPINFO == "4"
							RecLock("ZZ1",.F.)
							ZZ1->ZZ1_MOTOR		:= (cAlias)->ZZG_PRODUT
							//ZZ1->ZZ1_SERMOT	:= Right(AllTrim(ZZ1->ZZ1_VIN),8)
							ZZ1->ZZ1_SERMOT		:= (cAlias)->ZZG_INFORM
							ZZ2->( msUnlock() )
						EndIf

						ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
						//If aAux[1] // Inclusão Confirmada
							RecLock("ZZG",.F.)
							ZZG->ZZG_STATUS := '1'
							ZZG->ZZG_DESC	:= "[ZZ2] ITEM DE SEGURANCA " +AllTrim((cAlias)->ZZG_PRODUT) + " INCLUIDO"
							ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
							ZZG->( msUnlock() )
							
						//Else
						//EndIf
					EndIf
				ElseIf (cAlias)->ZZG_TPINFO == "3"
					
					//MemoWrite("C:\TEMP\"+FunName()+"-01-"+DTOS(Date())+"-"+StrTran(Time(),":")+".TXT","cPosPBS1 == Subs((cAlias)->ZZG_INFORM,1,3)-"+IIF(cPosPBS1 == Subs((cAlias)->ZZG_INFORM,1,3),"T","F"))
					
					If cPosPBS1 == Subs((cAlias)->ZZG_INFORM,1,3) // Requisição para Empenho
						// 07/05/2018 - Uso de execauto com WMSA508 - Requisição Automática
						BeginSql Alias cAliasD4
				
							SELECT D4_OP 
				
							FROM %table:SD4% SD4
							INNER JOIN %table:SB5% SB5 ON SB5 .%NotDel%
								AND B5_FILIAL = %xFilial:SB5%
								AND B5_COD = D4_COD
								AND B5_CTRWMS = '1'
								
							WHERE SD4.%NotDel%
								AND D4_FILIAL = %xFilial:SD4%
								AND D4_OP = %Exp:ZZ3->ZZ3_OP+'01'+cSeqTrim%  
								AND D4_IDDCF = '      '
								AND D4_QUANT > 0
							
							GROUP BY D4_OP
							ORDER BY 1
				
						EndSql
						
						//MemoWrite("C:\TEMP\"+FunName()+"-02-"+DTOS(Date())+"-"+StrTran(Time(),":")+".TXT",GetLastQuery()[2])
						
						aErro	:= {}
						cErro	:= ""
						
						//MemoWrite("C:\TEMP\"+FunName()+"-03-"+DTOS(Date())+"-"+StrTran(Time(),":")+".TXT","(cAliasD4)->D4_OP - "+(cAliasD4)->D4_OP)

						If !Empty((cAliasD4)->D4_OP)
							
							ConOut("WMSA508GRA Inicio "+Time())
							
							aResErro   := {}
							aResOk     := {}
							If WMSA508GRA(.F./*lExibe*/,(cAliasD4)->D4_OP,.F./*lSldPrd*/,/*cRegra*/,@aResErro/*aResErro*/,@aResOk/*aResOk*/)

								ConOut("WMSA508GRA OK! - Fim "+Time())
	
								cResOk   := ""
								If Len(aResOk) > 0
									For nI := 1 to Len(aResOk)
										cResOk   += aResOk[nI] + CRLF 
									Next nI  
								EndIf
								
								ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
								RecLock("ZZG",.F.)
								ZZG->ZZG_STATUS := '1'
								ZZG->ZZG_DESC	:= "[SD4] OP " +ZZ3->ZZ3_OP+'01'+cSeqTrim+ " REQUISICAO PARA EMPENHO EFETIVADA"
								ZZG->ZZG_ERRO	:= cResOk
								ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
								ZZG->( msUnlock() )

							Else

								ConOut("WMSA508GRA NOK! - Fim "+Time())
								
								cResErro   := ""
								If Len(aResErro) > 0
									For nI := 1 to Len(aResErro)
										cResErro   += aResErro[nI] + CRLF 
									Next nI  
								EndIf
								
								ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
								RecLock("ZZG",.F.)
								ZZG->ZZG_STATUS := '2'
								ZZG->ZZG_DESC	:= "[SD4] OP " +ZZ3->ZZ3_OP+'01'+cSeqTrim+ " ERRO EM REQUISICAO PARA EMPENHO"
								ZZG->ZZG_ERRO	:= cResErro 
								ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
								ZZG->( msUnlock() )

							Endif
							
						
						Else
							ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
							RecLock("ZZG",.F.)
							ZZG->ZZG_STATUS := '2'
							ZZG->ZZG_DESC	:= "[SD4] OP " +ZZ3->ZZ3_OP+ " EMPENHO NAO LOCALIZADO"
							ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
							ZZG->( msUnlock() )
						EndIf



						/* Desativado em 07/05/2019 - Requisição com uso de WMSA505  									
						BeginSql Alias cAliasD4
				
							SELECT MIN(D4_OP) D4_OPMIN, MAX(D4_OP) D4_OPMAX, MIN(D4_DATA) D4_DATAD, MAX(D4_DATA) D4_DATAA 
				
							FROM %table:SD4% SD4
							INNER JOIN %table:SB5% SB5 ON SB5 .%NotDel%
								AND B5_FILIAL = %xFilial:SB5%
								AND B5_COD = D4_COD
								AND B5_CTRWMS = '1'
								
							WHERE SD4.%NotDel%
								AND D4_FILIAL = %xFilial:SD4%
								AND SUBSTRING(D4_OP,1,6) = %Exp:ZZ3->ZZ3_OP%  
								AND SUBSTRING(D4_OP,9,3) = %Exp:cSeqTrim%
								AND D4_IDDCF = '      '
								AND D4_QUANT > 0
							
							GROUP BY SUBSTRING(D4_OP,1,6)
							ORDER BY 1
				
						EndSql
						
						MemoWrite("C:\TEMP\"+FunName()+"-02-"+DTOS(Date())+"-"+StrTran(Time(),":")+".TXT",GetLastQuery()[2])
						
						aErro	:= {}
						cErro	:= ""
						MemoWrite("C:\TEMP\"+FunName()+"-03-"+DTOS(Date())+"-"+StrTran(Time(),":")+".TXT","(cAliasD4)->D4_OPMIN-"+(cAliasD4)->D4_OPMIN)
						If !Empty((cAliasD4)->D4_OPMIN)
					
							
							//-- Monta array para utilizacao da Rotina Automatica
							aRotAuto	:= {}
							aAdd( aRotAuto  ,	(cAliasD4)->D4_OPMIN				)
							aAdd( aRotAuto  ,	(cAliasD4)->D4_OPMAX				)
							aAdd( aRotAuto  ,	STOD((cAliasD4)->D4_DATAD)			)
							aAdd( aRotAuto  ,	STOD((cAliasD4)->D4_DATAA)			)
							aAdd( aRotAuto  ,	Space( TamSX3("D4_COD")[1] 			)							)
							aAdd( aRotAuto  ,	Replicate("Z",TamSX3("D4_COD")[1]	)							)
							aAdd( aRotAuto  ,	1									)
							
							lMsErroAuto := .F.
							
							// Chamada da rotina automatica
							MsExecAuto({|x,y| WMSA505(x,y)},aRotAuto,2)

							If lMsErroAuto
								
								cErro += FunName() +" - Requisicao TRIM - ExecAuto WMSA505" + CRLF
								cErro += "Ordem   - "+ ZZ3->ZZ3_OP + CRLF
								cErro += " " + CRLF
								
								aErro := GetAutoGRLog() // Retorna erro em array
	
								for nX := 1 to len(aErro)
									cErro += aErro[nX] + CRLF
								next nX
	
								ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
								RecLock("ZZG",.F.)
								ZZG->ZZG_STATUS := '2'
								ZZG->ZZG_DESC	:= "[SD4] OP " +ZZ3->ZZ3_OP+ " ERRO EM REQUISICAO PARA EMPENHO"
								ZZG->ZZG_ERRO	:= cErro
								ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
								ZZG->( msUnlock() )
								
								//If !IsBlind()
								//	MsgStop(cErro,"CMVWMS003")
								//EndIf
								
								//ConOut(cErro)
	
							Else
								
								//MsgStop("ExecAuto OK!")
	
								ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
								RecLock("ZZG",.F.)
								ZZG->ZZG_STATUS := '1'
								ZZG->ZZG_DESC	:= "[SD4] OP " +ZZ3->ZZ3_OP+ " REQUISICAO PARA EMPENHO EFETIVADA"
								ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
								ZZG->( msUnlock() )
	
							EndIf
						
						Else
							ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
							RecLock("ZZG",.F.)
							ZZG->ZZG_STATUS := '2'
							ZZG->ZZG_DESC	:= "[SD4] OP " +ZZ3->ZZ3_OP+ " EMPENHO NAO LOCALIZADO"
							ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
							ZZG->( msUnlock() )
						EndIf
						*/
					
					Else
						ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
						RecLock("ZZG",.F.)
						ZZG->ZZG_STATUS := '1'
						ZZG->ZZG_DESC	:= "[PBS] POSICAO " +Subs((cAlias)->ZZG_INFORM,1,3)+ " - SEM ACAO DEFINIDA"
						ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
						ZZG->( msUnlock() )
					EndIf
					
					dbSelectArea(cAliasD4)
					dbCloseArea()

				ElseIf (cAlias)->ZZG_TPINFO == "5" // Ano Fabricação/Modelo
					If SC2->( dbSeek( xFilial("SC2")+ZZ3->ZZ3_OP+"01001" ) )
					RecLock("SC2",.F.)
						//SC2->C2_XFABMOD	:= Subs((cAlias)->ZZG_INFORM,At(";",(cAlias)->ZZG_INFORM)+1,4)+Subs((cAlias)->ZZG_INFORM,1,4) // StrTran((cAlias)->ZZG_INFORM,";")
						SC2->C2_XFABMOD	:= Subs((cAlias)->ZZG_INFORM,6,4)+Subs((cAlias)->ZZG_INFORM,1,4) // StrTran((cAlias)->ZZG_INFORM,";")
						SC2->( msUnlock() )
	
						ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
						RecLock("ZZG",.F.)
						ZZG->ZZG_STATUS := '1'
						ZZG->ZZG_DESC	:= "[SC2] OP " +ZZ3->ZZ3_OP+ " ANO FABRICACAO/MODELO GRAVADO"
						ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
						ZZG->( msUnlock() )
					Else
						ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
						RecLock("ZZG",.F.)
						ZZG->ZZG_STATUS := '2'
						ZZG->ZZG_DESC	:= "[SC2] OP " +ZZ3->ZZ3_OP+"01001 NAO LOCALIZADA"
						ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
						ZZG->( msUnlock() )
					EndIf
				Else
					ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
					RecLock("ZZG",.F.)
					ZZG->ZZG_STATUS := '2'
					ZZG->ZZG_DESC	:= "[ZZG] TIPO DE INFORMACAO NAO DEFINIDO"
					ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
					ZZG->( msUnlock() )
				EndIf
			Else
				ZZG->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
				RecLock("ZZG",.F.)
				ZZG->ZZG_STATUS := 2
				ZZG->ZZG_DESC	:= "[ZZ3] BARCOD " +(cAlias)->ZZG_BARCOD+ " NAO EXISTE"
				ZZG->ZZG_TSPROC	:= FWTimeStamp(1)
				ZZG->( msUnlock() )
			EndIf
			(cAlias)->( dbSkip() )
		EndDo

		dbSelectArea(cAlias)
		dbCloseArea()

//		UnLockByName(cNomLck,.F.,.F. )

		RECOVER

		Conout('##### CMVPCP07 - Erro no Processamento - Verificar Log - ' + dToC(Date()) + ' - ' + time() )
	
	END SEQUENCE                               

	ErrorBlock( bError )

	If ValType(cError) == 'C'

		ConOut("cError"+cError)

		cArqLog := FunName() +"-ERRO-"+ DToS(Date()) +"-"+ StrTran(Time(),":")+".LOG"

		MemoWrite( /*cDirLog*/ "\SYSTEM\" + cArqLog , cError )

		cMsgErr	:= /*cDirLog +*/ cArqLog

		_lRet	:= .F.

		UnLockByName(cNomLck,.F.,.F. )

	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Finalização do Ambiente.                                                                                 |
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	RpcClearEnv()
	
//	UnLockByName(cNomLck,.F.,.F. )

	ConOut("## CMVPCP07 [Filial "+cFilAnt+"] Encerrado "+Dtoc(Date())+"-"+Time()+" ##")
	
Return .T.


//-------------------------------------------------------------------
Static Function Import(  cModel, nOper, cMaster, cDetail, aCpoMaster, aCpoDetail )

	Local oModel, oAux, oStruct
	Local	nI		:= 0
	Local	nJ		:= 0
	Local	nPos	:= 0
	Local	lRet	:= .T.
	Local	cRet	:= ""
	Local	aAux	:= {}
	Local	aC		:= {}
	Local	aH		:= {}
	Local	nItErro	:= 0
	Local	lAux	:= .T.
	Local cErro		:= ""
	
	dbSelectArea( cDetail )
	dbSetOrder( 1 )
	
	dbSelectArea( cMaster )
	dbSetOrder( 1 )
	
	// Aqui ocorre o instanciamento do modelo de dados (Model)
	// Neste exemplo instanciamos o modelo de dados do fonte COMP021_MVC
	// que é a rotina de manutenção de musicas
	oModel := FWLoadModel( cModel )
	
	// Temos que definir qual a operação deseja: 3 - Inclusão / 4 - Alteração / 5 - Exclusão
	If nOper	== 3
		oModel:SetOperation( MODEL_OPERATION_INSERT )
	ElseIf nOper	== 4
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
	Endif
	
	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	// Se o Modelo nao puder ser ativado, talvez por uma regra de ativacao
	// o retorno sera .F.
	IF lRet := oModel:Activate()
		ConOut("oModel:Activate()")
		If lRet

		
			// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
			oAux    := oModel:GetModel( cMaster + 'MASTER' )
		
			// Obtemos a estrutura de dados do cabeçalho
			oStruct := oAux:GetStruct()
			aAux	:= oStruct:GetFields()
		
			If lRet
				For nI := 1 To Len( aCpoMaster )
		
					// Verifica se os campos passados existem na estrutura do cabeçalho
					If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoMaster[nI][1] ) } ) ) > 0
		
						// È feita a atribuicao do dado aos campo do Model do cabeçalho
						If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )
		
							// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
							// o método SetValue retorna .F.
							lRet    := .F.
							
							ConOut("Exit 1" + Str(nI) )
							
							Exit
		
						EndIf
					EndIf
				Next
			EndIf
		EndIf
		
		If lRet
			// Intanciamos apenas a parte do modelo referente aos dados do item
			oAux     := oModel:GetModel( cDetail + 'DETAIL' )
			ConOut("oAux")
			// Obtemos a estrutura de dados do item
			oStruct  := oAux:GetStruct()
			aAux	 := oStruct:GetFields()
			ConOut("aAux")
			nItErro  := 0
			If !Empty( aCpoDetail )
				ConOut("Empty( aCpoDetail )")
				For nI := 1 To Len( aCpoDetail )
					// Incluímos uma linha nova
					// ATENCAO: O itens são criados em uma estrura de grid (FORMGRID), portanto já é criada uma primeira linha
					//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
			
					If nI > 1
			
						// Incluimos uma nova linha de item
			
						If  ( nItErro := oAux:AddLine() ) <> nI
			
							// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
							// ele retorna a quantidade de linhas já
							// existem no grid. Se conseguir retorna a quantidade mais 1
							lRet    := .F.
							Exit
			
						EndIf
			
					EndIf
			
					For nJ := 1 To Len( aCpoDetail[nI] )
			
					// Verifica se os campos passados existem na estrutura de item
						If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0
			
							If !( lAux := oModel:SetValue( cDetail + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )
			
								// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
								// o método SetValue retorna .F.
								lRet    := .F.
								nItErro := nI
								Exit
			
							EndIf
						EndIf
					Next
			
					If !lRet
						Exit
					EndIf
			
				Next
			EndIf
		EndIf
		
		If lRet
			ConOut("lRet Fim")
			// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
			// neste momento os dados não são gravados, são somente validados.
			If ( lRet := oModel:VldData() )
				ConOut("lRet oModel:VldData()")
				// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
				lRet := oModel:CommitData()
				ConOut("lRet := oModel:CommitData()")
				ConOut(lRet)
			Else
				ConOut("lRet oModel:VldData() FALSE")
			EndIf
	
		EndIf
		
		If !lRet
		
			// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
			aErro   := oModel:GetErrorMessage()
		
			// A estrutura do vetor com erro é:
			//  [1] Id do formulário de origem
			//  [2] Id do campo de origem
			//  [3] Id do formulário de erro
			//  [4] Id do campo de erro
			//  [5] Id do erro
			//  [6] mensagem do erro
			//  [7] mensagem da solução
			//  [8] Valor atribuido
			//  [9] Valor anterior
		
			cErro += "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' + CRLF 
			cErro += "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' + CRLF
			cErro += "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' + CRLF
			cErro += "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' + CRLF
			cErro += "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' + CRLF
			cErro += "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' + CRLF
			cErro += "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' + CRLF
			cErro += "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' + CRLF
			cErro += "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' + CRLF
		
			If nItErro > 0
				cErro += "Erro no Item:              " + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' + CRLF
			EndIf
		
			ConOut( cErro )
		
		EndIf
		
		// Desativamos o Model
		oModel:DeActivate()

	Else
		ConOut("NO oModel:Activate()")
	EndIf
	
Return( {lRet,cRet} )
//-------------------------------------------------------------------
Static Function MyError(oError)

	cError := oError:ERRORSTACK

Return
//-------------------------------------------------------------------
