#include "protheus.ch"
#include "rwmake.ch"
#include "TOTVS.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "Eicsi400.ch"
#INCLUDE "AvPrint.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWFILTER.CH"
#INCLUDE "FWMVCDEF.CH"
/*MATA061 cadastro produto x fornecedor MVC
=====================================================================================
Programa.:              CMVIMP01
Autor....:              Tiago Barbieri
Data.....:              05/09/2016
Descricao / Objetivo:   Importação de cadastros
Doc. Origem:            Contrato - GAP CMVIMP01
Solicitante:            Cliente
Uso......:              CAOA
Obs......:              Tela de Importação de cadastros
Obs......:              Requer biblioteca CMVZFUNA.PRW
=====================================================================================
*/

User Function CMVIMP01()    // U_CMVIMP01()

	Local oRadMenu1
	Local oSay1
	Local aOpcoes := {}
	Static oDlg3

	Private nRadMenu1 := 1

	//Private cLogDir	:= GetMv("CMV_IMP01A",,"\CMV\IMP\") // Parametro foi utilizado em outro GAP
	Private cLogDir	:= GetMv("CMV_IMPLOG",,"\CMV\IMP\") // Pasta de gravação de logs - servidor
	Private nThrTrn	:= GetMv("CMV_IMP01B",,40)			// Número de Transações x Thread
	Private nThrMax	:= GetMv("CMV_IMP01C",,10)			// Número Máximo de Threads
	Private cTMCus	:= GetMv("CMV_IMP01D",,"497")		// TM devolução - Custo informado
	Private cTMCus0	:= GetMv("CMV_IMP01E",,"498")		// TM devolução - Custo zero
	//Private lGrid	:= GetMv("CMV_IMP01F",,.T.)			// Uso de grid de Processamento
	Private nThrSlv	:= GetMv("CMV_IMP01G",,10)			// Número de Slaves disponíveis para processar Threads

	//private lMsHelpAuto     := .T.
	//private lMsErroAuto     := .F.
	//private lAutoErrNoFile  := .T. // Precisa estar como .T. para GetAutoGRLog() retornar o array com erros

	Private cArqTop	//:= CriaTrab(,.F.)

	//Verificar se o Usuário esta habilitado no padrão CAOA
	If !U_ZGENUSER( RetCodUsr() ,"CMVIMP01" ,.T.)	
		Return Nil
	EndIf
	
	//MsgStop(cArqTop)
	
	dbSelectArea("NNR")
	dbSetOrder(1)

	dbSelectArea("SYD")
	dbSetOrder(1)
	//MsgStop( "01 - xFilial NNR " + xFilial("NNR") )
	//MsgStop( "01 - cFilAnt     " + cFilAnt )

	aadd(aOpcoes,"Cadastros de Produtos SB1")                              //01 SB1
	aadd(aOpcoes,"Estrutura de Produtos SG1")                              //02 SG1
	aadd(aOpcoes,"Clientes SA1")                                           //03 SA1
	aadd(aOpcoes,"Fornecedores SA2")                                       //04 SA2
	aadd(aOpcoes,"Representantes/Vendedores SA3")                          //05 SA3
	aadd(aOpcoes,"Veículos DA3")                                           //06 DA3
	aadd(aOpcoes,"Transportadoras SA4")                                    //07 SA4
	aadd(aOpcoes,"Cadastro de Bens 'Ativo Fixo' - 2 arquivos SN1/SN3")     //08 SN1/SN3
	aadd(aOpcoes,"Saldos de Estoque SD3")                                  //09 SD3
	aadd(aOpcoes,"Pedidos de Compra em Aberto SC7")                        //10 SC7
	aadd(aOpcoes,"Pedidos de Venda em Aberto - 2 arquivos SC5/SC6")        //11 SC5/SC6
	aadd(aOpcoes,"Movimento Financeiro Contas a Pagar em Aberto SE2")      //12 SE2
	aadd(aOpcoes,"Movimento Financeiro Contas a Receber em Aberto SE1")    //13 SE1
	aadd(aOpcoes,"Ordens de Compra SC1")     							   //14 SC1
	aadd(aOpcoes,"Endereço de Entrega SZ9")       						   //15 SZ9
	aadd(aOpcoes,"Complemento de Produtos SB5")					   		   //16 SB5
	aadd(aOpcoes,"Contrato de Parceria SC3")     						   //17 SC3
	aadd(aOpcoes,"Veículos VV1")                						   //18 VV1	
	aadd(aOpcoes,"Pedido de Venda Veículo Montadora VRJ/VRK")   		   //19 VRJ/VRK
	aadd(aOpcoes,"Nota Entrada Veículo Montadora VVF/VVG")   		   	   //20 VVF/VVG
	aadd(aOpcoes,"Purchase Order - 2 arquivos SW2/SW3")                    //21 SW2/SW3	
	aadd(aOpcoes,"Cadastro Produto x Fornecedor SA5")                      //22 SA5	 
	aadd(aOpcoes,"Inventário SB7")                      				   //23 SB7
	aadd(aOpcoes,"Custo Standart SB1 (B1_CUSTD)")          				   //24 SB1 (B1_CUSTD)
	
	DEFINE MSDIALOG oDlg3 TITLE "Importação de Cadastros CAOA" FROM 000, 000  TO 480, 400 COLORS 0, 16777215 PIXEL
	oRadMenu1:= tRadMenu():New(20,06,aOpcoes,{|u|if(PCount()>0,nRadMenu1:=u,nRadMenu1)}, oDlg3,,,,,,,,159,130,,,,.T.)
	@ 006, 006 SAY oSay1 PROMPT "Selecione o cadastro a importar :" SIZE 091, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
	@ 170,  90 BUTTON "Importar" SIZE 050, 012 PIXEL OF oDlg3 Action(processa ({|| ImpCad()},"Importação de Cadastros Básicos"))
	@ 170, 150 BUTTON "Cancelar" SIZE 050, 012 PIXEL OF oDlg3 Action(oDlg3:End())

	ACTIVATE MSDIALOG oDlg3 CENTERED

Return

/*
========================================================
Função de Importação de arquivo CSV com separador ";"
========================================================
*/
Static Function ImpCad

	Local cArq	    := ""
	Local cArqd	    := ""

	Local aMonThread	:= {}
	//Local aParEnv	:= { "01" , "010001" }

	Local cLogFile   := ""
	//      := ""
	//Local aLog       := {}
	//Local cLogWrite  := ""

	//Local nHandle
	Local cLinha     := ''
	Local cLinhad    := ''
	Local lPrim      := .T.
	Local lPrimd     := .T.
	Local lPrimThr	 := .T.
	Local aCampos    := {}
	Local aCamposd   := {}
	Local aStru      := {}
	Local aDados     := {}
	Local aDadosd    := {}
	Local cBKFilial  := cFilAnt
	Local nCampos    := 0
	Local nCamposd   := 0
	//Local cSQL       := ''
	//Local cSQLd      := ''
	Local aExecAuto  := {}
	Local aExecAutod := {}
	Local aExecAutol := {}
	Local aThrCab	:= {}
	Local aThrDet	:= {}
	Local aThrLin	:= {}
	Local aThrFil	:= {}
	Local aTipoImp   := {}
	Local aTipoImpd  := {}
	Local nTipoImp   := 0
	//Local nTipoImpd  := 0
	Local cTipo      := ''
	Local cTipod     := ''
	Local cTab       := ''
	//Local cTabd      := ''
	Local nI
	Local nId
	Local nX
	//Local cNiv
	Local cCod
	Local cBemN1
	//Local cBemN3
	Local cItemN1
	//Local cItemN3
	Local cChave
	Local nLinha	:= 0

	Local oGrid, cGridFunSt, cGridFunEx
	Local aGridParSt	:= {"01","010001"}
	Local nGrid	:= 0
	Local cAliasTRB		:= "CMVIMP01"

	//Private lMsErroAuto    := .F.
	//Private lMsHelpAuto	   := .F.
	//Private lAutoErrNoFile := .T.
	Private aTabExclui     := 	{	{'B1',{"SB1"} },;										//01 SB1
									{'G1',{"SG1"} },;										//02 SG1
									{'A1',{"SA1"} },;										//03 SA1
									{'A2',{"SA2"} },;										//04 SA2
									{'A3',{"SA3"} },;										//05 SA3
									{'DA3',{"DA3"} },;										//06 DA3
									{'A4',{"SA4"} },;										//07 SA4
									{'N1',{"SN1","SN2","SN3","SN4","SN5","SN6","SNC"} },;	//08 SN1/SN3
									{'D3',{"SB2","SB8","SBF","SD3","SD5","SDA","SDB"} },;	//09 SD3
									{'C7',{"SC7","SCR"} },;									//10 SC7
									{'C5',{"SC5","SC6"} },;									//11 SC5/SC6
									{'E2',{"SE2","SCR"} },;									//12 SE2
									{'E1',{"SE1"} },;										//13 SE1
									{'C1',{"SC1","SCR"} },;									//14 SC1
									{'Z9',{"SZ9"} } ,;										//15 SZ9
									{'B5',{"SB5"} } ,;										//16 SB5
									{'C3',{"SC3"} } ,;										//17 SC3
									{'VV1',{"VV1"} } ,;										//18 VV1
									{'VRJ',{"VRJ","VRK"} } ,;								//19 VRJ/VRK
									{'VVF',{"VVF","VVG"} } ,;								//20 VVF/VVG
									{'W2',{"SW2","SW3"} }  ,;   							//21 SW2/SW3
									{'A5',{"SA5"} } ,;   									//22 SA5	
									{'B7',{"SB7"} } ,;   									//23 SB7	
									{'B1',{"SB1"} } }   									//24 SB1
	
	Private lGrid	:= GetMv("CMV_IMP01F",,.F.) .And. nRadMenu1 <> 8			// Uso de grid de Processamento

	nThrMax			:= IIF(nRadMenu1 == 8 .Or. nRadMenu1 == 2 .Or. nRadMenu1 == 18,1,nThrMax)

	cLogFile   := ""
	
	//MsgStop( "02 - xFilial NNR " + xFilial("NNR") )
	//MsgStop( "02 - cFilAnt     " + cFilAnt )
	
	If !FWMakeDir( cLogDir , .T. ) //!U_zMakeDir( cLogDir , "Pasta Servidor" )

		Return

	EndIf
	
	//MsgStop( "03 - xFilial NNR " + xFilial("NNR") )
	//MsgStop( "03 - cFilAnt     " + cFilAnt )

	cLogProc	:= cLogDir+"PROC_"+aTabExclui[nRadMenu1][1]+"-"+DTOS(Date())+StrTran(Time(),":")+".LOG"
	//cLogProc	:= "PROC_"+aTabExclui[nRadMenu1][1]+"-"+DTOS(Date())+StrTran(Time(),":")+".XML"
	dDataIni	:= dDataAux	:= dDataFim	:= Date()
	cHoraIni	:= cHoraAux := cHoraFim := Time()

	cTxtProc	:= Replicate("-",80)+CRLF
	aTxtproc	:= {}
	//  --------------------------------------------------------------------------------
	//##### CMVIMP01 - Importacao N1 - 04/04/2017 - 12:12:12 #####
	cTxtProc 	+= "##### [CMVIMP01] Importacão "+aTabExclui[nRadMenu1][1] +" - " + DtoC( dDataIni ) + "  - " + cHoraIni + " #####"+CRLF+CRLF
	nTxtProc	:= 0

	//MsgStop( "04 - xFilial NNR " + xFilial("NNR") )
	//MsgStop( "04 - cFilAnt     " + cFilAnt )
	
	If lGrid

		oGrid := GridClient():New()

		// Defines name of preparation functions of environment and execution
		aGridParSt	:= {"01","010001",nRadmenu1}
		cGridFunSt  := 'U_ZGRIDS'
		cGridFunEx  := 'U_ZGRIDE'
		lGrid := oGrid:Prepare(cGridFunSt,aGridParSt,cGridFunEx)

		dDataFim	:= Date()
		cHoraFim	:= Time()

		cTxtProc 	+= "##### "+StrZero(nTxtProc++,2)+" Preparação do Grid - Inicio: " + cHoraAux + " / Fim: " + cHoraFim + IIF(dDataAux==dDataFim," / Intervalo: "+ElapTime(cHoraAux,cHoraFim)," ") + " #####)"+CRLF
		aAdd( aTxtProc , { StrZero(Len(aTxtProc)+1,4) , "Preparação do Grid" , cHoraAux , cHoraFim , IIF(dDataAux==dDataFim, ElapTime(cHoraAux,cHoraFim) ," " ) } )

		dDataAux	:= Date()
		cHoraAux	:= Time()


		If !lGrid
			If !MsgYesNo("Erro na preparação do grid:"+CRLF+oGrid:GetError()+CRLF+CRLF+"Deseja continuar a importação usando multi-trheads?","Grid Prepare()")

				oGrid:Terminate()

				oGrid := NIL
				Return
			EndIf
		EndIf

	EndIf

	//MsgStop( "05 - xFilial NNR " + xFilial("NNR") )
	//MsgStop( "05 - cFilAnt     " + cFilAnt )
	
	If .F. //!lGrid

		oGrid := FWIPCWait():New('U_XEXEC' , 10000)
		oGrid:SetThreads( nThrMax * nThrSlv )
		oGrid:SetEnvironment(cEmpAnt, cFilAnt)
		oGrid:Start('U_XEXEC') 	
		Sleep( 600 )

		dDataFim	:= Date()
		cHoraFim	:= Time()


		cTxtProc 	+= "##### "+StrZero(nTxtProc++,2)+" Preparação de Threads - Início: " + cHoraAux + " / Fim: " + cHoraFim + IIF(dDataAux==dDataFim," / Intervalo: "+ElapTime(cHoraAux,cHoraFim)," ") + " #####)"+CRLF
		aAdd( aTxtProc , { StrZero(Len(aTxtProc)+1,4) , "Preparação de Threads" , cHoraAux , cHoraFim , IIF(dDataAux==dDataFim, ElapTime(cHoraAux,cHoraFim) ," " ) } )

		dDataAux	:= Date()
		cHoraAux	:= Time()


	EndIf

	//Return

	/*
	If nRadMenu1 <> 8 .And. nRadMenu1 <> 14

	MsgAlert("Importação de Cadastros - Opção desabilitada!","ATENÇÃO")

	Return

	EndIf
	*/

	/*
	========================================================
	Importação de Dados
	========================================================
	*/


	// renomear arquivos LOG de importações anteriores
	aArqLog := Directory(cLogDir+"IMP_"+aTabExclui[nRadMenu1][1]+"-*.LOG")
	cPatLoc	:= ""
	If !Empty(aArqLog)
		For nX := 1 to Len(aArqLog)
			fRename(cLogDir+aArqLog[nX,1],cLogDir+Subs(aArqLog[nX,1],1,At(".LOG",Upper(aArqLog[nX,1])))+"BKP")
		Next nX
	EndIf

	dDataFim	:= Date()
	cHoraFim	:= Time()

	cTxtProc 	+= "##### "+StrZero(nTxtProc++,2)+" Backup arquivos Log - Inicio: " + cHoraAux + " / Fim: " + cHoraFim + IIF(dDataAux==dDataFim," / Intervalo: "+ElapTime(cHoraAux,cHoraFim)," ") + " #####)"+CRLF
	aAdd( aTxtProc , { StrZero(Len(aTxtProc)+1,4) , "Backup arquivos Log" , cHoraAux , cHoraFim , IIF(dDataAux==dDataFim, ElapTime(cHoraAux,cHoraFim) ," " ) } )

	dDataAux	:= Date()
	cHoraAux	:= Time()

	//Arquivo Cabeçalho
	If nRadMenu1 == 8 .Or. nRadMenu1 == 11 .Or. nRadMenu1 == 21
		MsgAlert("Essa opção precisa de 2 arquivos, o primeiro é o arquivo de CABEÇALHO!","ATENÇÃO")
	EndIf

	cArq := cGetFile("Todos os Arquivos|*.csv", OemToAnsi("Informe o diretório onde se encontra o arquivo."), 0, "SERVIDOR\", .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ,.T.)

	If !File(cArq)
		MsgStop("O arquivo " +cArq + " não foi selecionado. A Importação será abortada!","ATENÇÃO")
		Return
	Else
		cPatLoc := Subs(cArq,1, Rat("\",cArq) )
		cArqPen	:= cLogDir + Subs(cArq,Rat("\",cArq)+1, Rat(".",cArq)-1 )+"-PEND-"+DTOS(Date())+StrTran(Time(),":")+".CSV"
		If !CpyT2S(cArq,cLogDir)
			MsgStop("O arquivo " +cArq + " não foi copiado para o server. A Importação será abortada!","ATENÇÃO")
			Return
		Else
			cArq	:= cLogDir + Subs( cArq , Rat("\",cArq) + 1 )
			If !File(cArq)
				MsgStop("O arquivo " +cArq + " não foi localizado no servidor. A Importação será abortada!","ATENÇÃO")
				Return
			ElseIf fRename(cArq,Subs(cArq,1, Rat(".",cArq)-1 )+"-"+DTOS(Date())+StrTran(Time(),":")+".CSV") == -1
				MsgStop("O arquivo " +cArq + " não foi renomeado no servidor. A Importação será abortada!","ATENÇÃO")
				Return
			Else
				cArq	:= Subs(cArq,1, Rat(".",cArq)-1 )+"-"+DTOS(Date())+StrTran(Time(),":")+".CSV"
				If !File(cArq)
					MsgStop("O arquivo " +cArq + " (renomeado) não foi localizado no servidor. A Importação será abortada!","ATENÇÃO")
					Return
				EndIf
			EndIf
		EndIf
	EndIf

	//MsgStop( "06 - xFilial NNR " + xFilial("NNR") )
	//MsgStop( "06 - cFilAnt     " + cFilAnt )
	
	FT_FUSE(cArq)
	FT_FGOTOP()
	cLinha    := FT_FREADLN()
	aTipoImp  := Separa(cLinha,";",.T.)
	cTipo     := SUBSTR(aTipoImp[1],1,2)
	If cTiPO $ ("DA/VV/") 
		cTipo     := SUBSTR(aTipoImp[1],1,3)
	EndIf
	/*
	If nRadMenu1 == 18 //Veiculos
		cTipo     := SUBSTR(aTipoImp[1],2,2)
	EndIf	
	*/
	FT_FUSE()

	IF !(cTIPO $(aTabExclui[nRadMenu1][1]/*'N1'*/))
		MsgAlert('Não é possível importar a tabela: '+cTipo+ '  !!')
		Return
	EndIf
	
	If nRadMenu1 == 24 .And. ( aScan( aTipoImp, { |x| AllTrim( x )  == "B1_COD" } ) == 0 .Or. aScan( aTipoImp, { |x| AllTrim( x ) == "B1_CUSTD" } ) == 0 .Or. Len(aTipoImp)>2)

	  MsgAlert('Atualização de Custo Standart de ter SOMENTE os campos B1_COD e B1_CUSTD !!')
	  Return

	Else
		aAreaSX3	:= SX3->( GetArea() )
		//dbSelectArea("SX3")
		SX3->(DbSetOrder(2))
		For nI := 1 To Len(aTipoImp)
			IF SUBSTR(cTipo,1,1) <> "V"
			   IF cTipo <> SUBSTR(aTipoImp[nI],1,2) .AND.;
			      !("CNUMCON" $ aTipoImp[nI] .OR. "CBANCOADT" $ aTipoImp[nI] .OR. "CAGENCIAADT" $ aTipoImp[nI] )//.OR. "AUTO" $ aTipoImp[nI])  
				  MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				  Return
			   ENDIF
			Endif
			
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI]))) .AND. !aTipoImp[nI] $ "IMOBILIZADO;NUMERO_DI;DT_DI;NOTA_FISCAL;SERIE_NOTA;DATA_FATURAMENTO;FORNECEDOR;LOJA;CUSTO_MEDIO;VV1_PRODUTO"
				MsgStop( "01 "+aTipoImp[nI] )
			//!("CNUMCON" $ aTipoImp[nI] .OR. "CBANCOADT" $ aTipoImp[nI] .OR. "CAGENCIAADT" $ aTipoImp[nI] )//.OR. "AUTO" $ aTipoImp[nI])  
				MsgAlert('Campo não encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
				//ELSEIF ( /*S/->X3_VISUAL $ ('V') .OR.*/ SX3->X3_CONTEXT == "V" ) .And. !AllTrim( SX3->X3_CAMPO )+"/" $ "C1_ITEM/C6_FILIAL/C6_ITEM/A1_COD/A1_LOJA/C7_ITEM/C7_UM/C7_OPER/A2_COD/A2_LOJA/"
			//ELSEIF ( SX3->X3_CONTEXT == "V" ) .And. !(AllTrim( SX3->X3_CAMPO ) $ "C1_ITEM|C6_FILIAL|C6_ITEM|A1_COD|A1_LOJA|C7_ITEM|C7_UM|C7_OPER|A2_COD|A2_LOJA")
			ELSEIF ( SX3->X3_CONTEXT == "V" ) .And. !(AllTrim( SX3->X3_CAMPO ) $ "B1_VM_I|B1_VM_GI|B1_VM_P"	)//Incluída validação por conta do EIC
				MsgAlert('Campo marcado na tabela como visual (X3_CONTEXT) :'+aTipoImp[nI]+' !!')
				Return
			ElseIf cTipo $ 'C1/C7/G1/C3/A5/' .OR. SUBSTR(cTipo,1,1) = "V"
				aAdd( aStru , { aTipoImp[nI] , SX3->X3_TIPO , SX3->X3_TAMANHO , SX3->X3_DECIMAL } )
			ENDIF
		Next nI
	EndIf

	//MsgStop( "08 - xFilial NNR " + xFilial("NNR") )
	//MsgStop( "08 - cFilAnt     " + cFilAnt )
	
	nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

	cTab := ''
	For nI := 1 To Len(aTabExclui[nTipoImp,2])
		cTab += aTabExclui[nTipoImp,2,nI]+' '
	Next nI

	//msgStop( "09 - xFilial NNR " + xFilial("NNR") )
	//MsgStop( "09 - cFilAnt     " + cFilAnt )
	
	
	//Arquivo Itens
	If nRadMenu1 == 8 .Or. nRadMenu1 == 11 .Or. nRadMenu1 == 21  /*.Or. nRadMenu1 == 22*/
		MsgAlert("Agora é o arquivo de DETALHE!","ATENÇÃO")
		cArqd := cGetFile("Todos os Arquivos|*.csv", OemToAnsi("Informe o diretório onde se encontra o arquivo."), 0, "SERVIDOR\", .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ,.T.)

		If !File(cArqd)
			MsgStop("O arquivo " +cArqd + " não foi selecionado. A Importação será abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArqd)
		FT_FGOTOP()
		cLinhad    := FT_FREADLN()
		aTipoImpd  := Separa(cLinhad,";",.T.)
		cTipod     := SUBSTR(aTipoImpd[1],1,2)

		IF !(cTIPOd $('N3/C6/W3'))
			MsgAlert('Não é possivel importar a tabela: '+cTipod+ '  !!')
			Return
		ENDIF

		//dbSelectArea("SX3")
		SX3->(DbSetOrder(2))
		For nId := 1 To Len(aTipoImpd)
			IF cTipod <> SUBSTR(aTipoImpd[nId],1,2) .AND. ;
			!("CNUMCON" $ aTipoImpd[nId] .OR. "CBANCOADT" $ aTipoImpd[nId] .OR. "CAGENCIAADT" $ aTipoImpd[nId] )//.OR. "AUTO" $ aTipoImpd[nId])  
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImpd[nId]))) .AND. ;
			!("CNUMCON" $ aTipoImpd[nId] .OR. "CBANCOADT" $ aTipoImpd[nId] .OR. "CAGENCIAADT" $ aTipoImpd[nId] )//.OR. "AUTO" $ aTipoImpd[nId])
				MsgStop( "02 "+aTipoImp[nI] )
				MsgAlert('Campo não encontrado na tabela :'+aTipoImpd[nId]+' !!')
				Return
			ELSEIF ( SX3->X3_VISUAL $ ('V') .OR. SX3->X3_CONTEXT == "V" ) .And. !AllTrim( SX3->X3_CAMPO )+"/" $ "C1_ITEM/C6_FILIAL/C6_ITEM/C6_UM/C6_OPER/A1_COD/A1_LOJA/C7_ITEM/C7_UM/"
				MsgAlert('Campo marcado na tabela como visual : (X3_CONTEXT) '+aTipoImpd[nId]+' !!')
				Return
			Else
				aAdd( aStru , { aTipoImpd[nId] , SX3->X3_TIPO , SX3->X3_TAMANHO , SX3->X3_DECIMAL } )
			ENDIF
		Next nId

	EndIf

	//msgStop( "10 - xFilial NNR " + xFilial("NNR") )
	//MsgStop( "10 - cFilAnt     " + cFilAnt )
	
	SX3->( RestArea(aAreaSX3) )

	//msgStop( "11 - xFilial NNR " + xFilial("NNR") )
	//MsgStop( "11 - cFilAnt     " + cFilAnt )
	
	dDataFim	:= Date()
	cHoraFim	:= Time()

	cTxtProc 	+= "##### "+StrZero(nTxtProc++,2)+" Verificação de Arquivo(s) - Inicio: " + cHoraAux + " / Fim: " + cHoraFim + IIF(dDataAux==dDataFim," / Intervalo: "+ElapTime(cHoraAux,cHoraFim)," ") + " #####)"+CRLF
	aAdd( aTxtProc , { StrZero(Len(aTxtProc)+1,4) , "Verificação de Arquivo(s)" , cHoraAux , cHoraFim , IIF(dDataAux==dDataFim, ElapTime(cHoraAux,cHoraFim) ," " ) } )


	dDataAux	:= Date()
	cHoraAux	:= Time()
	
	/*########EXCLUSAO REGISTROS
	If ! aTabExclui[nTipoImp,2,1] $ "VV1/SB1/"
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da Importação ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If aTabExclui[nTipoImp,2,nI] == "SCR"
					cSQL += " where CR_TIPO = "
					If aTabExclui[nTipoImp,2,1] == "SC1"
						cSQL += "'SC'"
					ElseIf aTabExclui[nTipoImp,2,1] == "SC7"
						cSQL += "'PC'"
					ElseIf aTabExclui[nTipoImp,2,1] == "SE2"
						cSQL += "'ZC'"
					EndIf
				EndIf
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
	EndIf
	########EXCLUSAO REGISTROS*/

	dDataFim	:= Date()
	cHoraFim	:= Time()

	cTxtProc 	+= "##### "+StrZero(nTxtProc++,2)+" Limpeza Tabelas - Inicio: " + cHoraAux + " / Fim: " + cHoraFim + IIF(dDataAux==dDataFim," / Intervalo: "+ElapTime(cHoraAux,cHoraFim)," ") + " #####)"+CRLF
	aAdd( aTxtProc , { StrZero(Len(aTxtProc)+1,4) , "Limpeza Tabelas" , cHoraAux , cHoraFim , IIF(dDataAux==dDataFim, ElapTime(cHoraAux,cHoraFim) ," " ) } )

	dDataAux	:= Date()
	cHoraAux	:= Time()

	// Detalhe - Montagem de Arquivo de Trabalho
	If nRadMenu1 == 8 .Or. nRadMenu1 == 11 .Or. nRadMenu1 == 14 .Or. nRadMenu1 == 10  .Or. nRadMenu1 == 2 .or. nRadMenu1 == 17 /*.or. nRadMenu1 == 18*/ .or. nRadMenu1 == 21  .or. nRadMenu1 == 22
	
		cArqTRB := Criatrab(aStru,.T.)
		//MsgStop("cArqTRB "+cArqTRB)

		If Select("TRB1") > 0
			dbSelectArea("TRB1")
			dbCloseArea()
		EndIf

		dbUseArea( .T., __LocalDriver, cArqTrb , "TRB1", .F., .F. )

		If nRadMenu1 == 8
			cIndTrb	:= IIF( TRB1->( FieldPos( "N3_FILIAL" ) ) > 0,"N3_FILIAL+","")+"N3_CBASE+N3_ITEM+N3_TIPO"
		ElseIf nRadMenu1 == 14
			cIndTrb	:= IIF( TRB1->( FieldPos( "C1_FILIAL" ) ) > 0,"C1_FILIAL+","")+"C1_NUM+C1_ITEM"
		ElseIf nRadMenu1 == 11
			cIndTrb	:= IIF( TRB1->( FieldPos( "C6_FILIAL" ) ) > 0,"C6_FILIAL+","")+"C6_NUM+C6_ITEM"
		ElseIf nRadMenu1 == 10
			cIndTrb	:= IIF( TRB1->( FieldPos( "C7_FILIAL" ) ) > 0,"C7_FILIAL+","")+"C7_NUM+C7_ITEM"
		ElseIf nRadMenu1 == 2
			cIndTrb	:= IIF( TRB1->( FieldPos( "G1_FILIAL" ) ) > 0,"G1_FILIAL+","")+"G1_COD+G1_COMP+G1_TRT"
		ElseIf nRadMenu1 == 17
			cIndTrb	:= IIF( TRB1->( FieldPos( "C3_FILIAL" ) ) > 0,"C3_FILIAL+","")+"C3_NUM"
		ElseIf nRadMenu1 == 18
			cIndTrb	:= IIF( TRB1->( FieldPos( "VV1_FILIAL" )) > 0,"VV1_FILIAL+","")+"VV1_CHAINT"
		ElseIf nRadMenu1 == 19
			cIndTrb	:= IIF( TRB1->( FieldPos( "VRK_FILIAL" ) ) > 0,"VRK_FILIAL+","")+"VRK_PEDIDO+VRK_ITEPED"
		ElseIf nRadMenu1 == 20
			cIndTrb	:= IIF( TRB1->( FieldPos( "VVF_FILIAL" ) ) > 0,"VVF_FILIAL+","")+"VVF_TRACPA"
		ElseIf nRadMenu1 == 21
			cIndTrb	:= IIF( TRB1->( FieldPos( "W3_FILIAL" ) ) > 0,"W3_FILIAL+","")+"W3_PO_NUM"
		ElseIf nRadMenu1 == 22
			cIndTrb	:= IIF( TRB1->( FieldPos( "A5_FILIAL" ) ) > 0,"A5_FILIAL+","")+"A5_PRODUTO+A5_FORNECE+A5_LOJA"
		EndIf

		IndRegua( "TRB1", cArqTrb , cIndTrb , , , "Criando Índice ...")

		If nRadMenu1 == 14 .Or. nRadMenu1 == 10 .Or. nRadMenu1 == 2 .or. nRadMenu1 == 17 .or. nRadMenu1 == 18 .or. nRadMenu1 == 22 
			cArqd	:= cArq
		EndIf

		FT_FUSE(  cArqd )
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Montando arquivo de trabalho...")// Detalhe - Montagem de Arquivo de Trabalho
			cLinhad := FT_FREADLN()
			If lPrimd
				aCamposd := Separa(cLinhad,";",.T.)
				lPrimd := .F. 
			Else
				aDadosd	:= Separa(cLinhad,";",.T.)

				If nRadMenu1 == 2 // SG1 - Estrutura

					cFilSG1	:= IIF("G1_FILIAL"$cIndTrb,xFilial("SG1"),"")
					cCodSG1	:= AllTrim(aDadosd[aScan(aTipoImp,{|x| alltrim(x) == "G1_COD"})])   
					cCodSG1	:= Stuff( Space( TamSX3("G1_COD")[1] ) , 1 , Len(cCodSG1) , cCodSG1 ) 
					cCmpSG1	:= AllTrim(aDadosd[aScan(aTipoImp,{|x| alltrim(x) == "G1_COMP"})])   
					cCmpSG1	:= Stuff( Space( TamSX3("G1_COMP")[1] ) , 1 , Len(cCmpSG1) , cCmpSG1 ) 
					cTrtSG1	:= AllTrim(aDadosd[aScan(aTipoImp,{|x| alltrim(x) == "G1_TRT"})])   
					cTrtSG1	:= Stuff( Space( TamSX3("G1_TRT")[1] ) , 1 , Len(cTrtSG1) , cTrtSG1 ) 

					If cCodSG1 == cCmpSG1

						FT_FSKIP()
						Loop
					
					ElseIf TRB1->( dbSeek( xFilial("SG1") + cCodSG1 + cCmpSG1 + cTrtSG1 ) )
						FT_FSKIP()
						Loop

					ElseIf TRB1->( dbSeek( cFilSG1 + cCodSG1 + cCmpSG1 + cTrtSG1 ) )
						//ConOut("FT_FSKIP() "+ cFilSG1 + cCodSG1 + cCmpSG1 + cTrtSG1)
						FT_FSKIP()
						Loop
					EndIf
				EndIf
				
				RecLock("TRB1",.T.)
				For nCamposd := 1 to Len( aDadosd )

					If  TamSx3(Upper(aCamposd[nCamposd]))[3] =='N'
						xValor	:= Val( StrTran(aDadosd[nCamposd],",",".") )
					ElseIf TamSx3(Upper(aCamposd[nCamposd]))[3] =='D'
						xValor	:= CTOD(aDadosd[nCamposd] )
					Else
						xValor	:= StrTran(aDadosd[nCamposd],'"')
					EndIf

					TRB1->( FieldPut( nCamposd , xValor ) )

				Next nCamposd
				If nRadMenu1 == 21
				EndIf
				TRB1->( msUnlock() )
			EndIf

			FT_FSKIP()

		EndDo
		FT_FUSE()

		dDataFim	:= Date()
		cHoraFim	:= Time()

		cTxtProc 	+= "##### "+StrZero(nTxtProc++,2)+" Arquivo de Trabalho - Início: " + cHoraAux + " / Fim: " + cHoraFim + IIF(dDataAux==dDataFim," / Intervalo: "+ElapTime(cHoraAux,cHoraFim)," ") + " #####)"+CRLF
		aAdd( aTxtProc , { StrZero(Len(aTxtProc)+1,4) , "Arquivo de Trabalho" , cHoraAux , cHoraFim , IIF(dDataAux==dDataFim, ElapTime(cHoraAux,cHoraFim) ," " ) } )

		dDataAux	:= Date()
		cHoraAux	:= Time()

	EndIf

	aThrDat	:= {}
	nI		:= 0



	// 07/08/2019 - Atilio
	// - Verifica se tabela de cadastro tem dados, nesse caso pergunta se deve validar registros de arquivo e desprezar itens existentes
	// - Inicialmente aplicado a SB1
/*
	lVldReg := .F.
	If aTabExclui[nRadMenu1][2][1] $ "SB1/SB5/"
		// MsgStop("SB1")
		dbSelectArea(aTabExclui[nRadMenu1][2][1])
		dbSetOrder(1)
		If dbSeek( xFilial(aTabExclui[nRadMenu1][2][1]) )
			// MsgStop("SB1-Carga Anterior")
			// If MsgYesNo("Deseja validar cada linha do arquivo e desconsiderar cadastros existentes? "+CRLF+CRLF+;
			// 			"Obs: Validação implica em custo de processamento. Deve ser usado para arquivos que contém itens já incluidos no cadastro.","Tabela "+aTabExclui[nRadMenu1][2][1]+" não está vazia!")
				lVldReg := .T.
			// EndIf
		EndIf
	EndIf
*/
	
	cCpoCab	:= ""
	nPosCod	:= 0

	lVldReg := .F.
	nPosChv1	:= 0
	nPosChv2	:= 0
	nPosChv3	:= 0
	nPosChv4	:= 0
	nPosChv5	:= 0
	nPosChv6	:= 0

	If nRadMenu1 == 1 /* SB1 - Produto */ .Or. nRadMenu1 == 24 /* B1_CUSTD */
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "B1_COD"})
		nPosCust	:= aScan(aTipoImp,{|x| alltrim(x) == "B1_CUSTD"})
		If nRadMenu1 == 24
			lVldReg := .T.
		ElseIf nPosChv1 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 2 // SG1 - Estrutura
		cCpoCab		:= "G1_FILIAL/G1_COD/"
		nPosCod		:= aScan(aTipoImp,{|x| alltrim(x) == "G1_COD"})
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "G1_COD"})
		nPosChv2	:= aScan(aTipoImp,{|x| alltrim(x) == "G1_COMP"})
		nPosChv3	:= aScan(aTipoImp,{|x| alltrim(x) == "G1_TRT"})
		nPosQtd		:= aScan(aTipoImp,{|x| alltrim(x) == "G1_QUANT"})
		If nPosChv1 > 0 .And. nPosChv2 > 0 .And. nPosChv3 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 3 // SA1 - Clientes
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "A1_COD"})
		nPosChv2	:= aScan(aTipoImp,{|x| alltrim(x) == "A1_LOJA"})
		If nPosChv1 > 0 .And. nPosChv2 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 4 // SA2 - Fornecedores
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "A2_COD"})
		nPosChv2	:= aScan(aTipoImp,{|x| alltrim(x) == "A2_LOJA"})
		If nPosChv1 > 0 .And. nPosChv2 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 5 // SA3 - Vendedores
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "A3_COD"})
		If nPosChv1 > 0 // .And. nPosChv2 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 6 // DA3 - Veiculos
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "DA3_COD"})
		If nPosChv1 > 0 .And. nPosChv2 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 7 // SA4 - Transportadoras
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "A4_COD"})
		If nPosCod > 0 // .And. nPosChv1 > 0 .And. nPosChv2 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 8 // SN1- Ativo FIxo
		cCpoCab  := ""
		nPosCod	:= aScan(aTipoImp,{|x| alltrim(x) == "N1_CBASE"}) 
		nPosGrp	:= aScan(aTipoImp,{|x| alltrim(x) == "N1_GRUPO"}) // "N1_CBASE"})
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "N1_CBASE"})
		nPosChv2	:= aScan(aTipoImp,{|x| alltrim(x) == "N1_ITEM"})
		If nPosChv1 > 0 .And. nPosChv2 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 9 // SD3 - Saldos de Estoque
		cCpoCab  := ""
		nPosCod	:= aScan(aTipoImp,{|x| alltrim(x) == "D3_COD"}) 
		//D3_COD;D3_LOCAL;D3_CUSTO1;D3_LOTECTL;D3_LOCALIZ
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "D3_COD"})
		nPosChv2	:= aScan(aTipoImp,{|x| alltrim(x) == "D3_LOCAL"})
		nPosChv3	:= aScan(aTipoImp,{|x| alltrim(x) == "D3_LOTECTL"})
		nPosChv4	:= aScan(aTipoImp,{|x| alltrim(x) == "D3_LOCALIZ"})
		//lVldReg := .T.
	ElseIf nRadMenu1 == 10 // SC7 - Pedidos de Compra
		cCpoCab	:= "C7_FILIAL/C7_NUM/C7_EMISSAO/C7_FORNECE/C7_LOJA/C7_COND/C7_CONTATO/C7_FILENT/C7_MOEDA/C7_TXMOEDA/"
		nPosCod	:= aScan(aTipoImp,{|x| alltrim(x) == "C7_NUM"})
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "C7_NUM"})
		nPosChv2	:= 0
		If nPosChv1 > 0 // .And. nPosChv2 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 11 // SC5 - Pedidos de Venda
		cCpoCab		:= ""
		nPosCod		:= aScan(aTipoImp,{|x| alltrim(x) == "C5_NUM"})
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "C5_NUM"})
		nPosChv2	:= 0
		If nPosChv1 > 0 // .And. nPosChv2 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 12 // SE2- Contas a Pagar
		cCpoCab  := ""
		nPosCod	:= aScan(aTipoImp,{|x| alltrim(x) == "E2_FORNECE"})
		nPosLoj	:= aScan(aTipoImp,{|x| alltrim(x) == "E2_LOJA"})
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "E2_PREFIXO"})
		nPosChv2	:= aScan(aTipoImp,{|x| alltrim(x) == "E2_NUM"})
		nPosChv3	:= aScan(aTipoImp,{|x| alltrim(x) == "E2_PARCELA"})
		nPosChv4	:= aScan(aTipoImp,{|x| alltrim(x) == "E2_TIPO"})
		nPosChv5	:= aScan(aTipoImp,{|x| alltrim(x) == "E2_FORNECE"})
		nPosChv6	:= aScan(aTipoImp,{|x| alltrim(x) == "E2_LOJA"})
		If nPosChv1 > 0 .And. nPosChv2 > 0 .And. nPosChv3 > 0 .And. nPosChv4 > 0 .And. nPosChv5 > 0 .And. nPosChv6 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 13 // SE1- Contas a Receber
		cCpoCab  := ""
		nPosCod	:= aScan(aTipoImp,{|x| alltrim(x) == "E1_CLIENTE"})
		nPosLoj	:= aScan(aTipoImp,{|x| alltrim(x) == "E1_LOJA"})
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "E1_PREFIXO"})
		nPosChv2	:= aScan(aTipoImp,{|x| alltrim(x) == "E1_NUM"})
		nPosChv3	:= aScan(aTipoImp,{|x| alltrim(x) == "E1_PARCELA"})
		nPosChv4	:= aScan(aTipoImp,{|x| alltrim(x) == "E1_TIPO"})
		nPosChv5	:= aScan(aTipoImp,{|x| alltrim(x) == "E1_CLIENTE"})
		nPosChv6	:= aScan(aTipoImp,{|x| alltrim(x) == "E1_LOJA"})
		If nPosChv1 > 0 .And. nPosChv2 > 0 .And. nPosChv3 > 0 .And. nPosChv4 > 0 .And. nPosChv5 > 0 .And. nPosChv6 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 14 // SC1 - Solictações de Compra
		cCpoCab  := "C1_FILIAL/C1_NUM/C1_SOLICIT/C1_EMISSAO/C1_UNIDREQ/C1_CODCOMP/C1_FILENT/"
		nPosCod	:= aScan(aTipoImp,{|x| alltrim(x) == "C1_NUM"})
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "C1_NUM"})
		If nPosChv1 > 0 // .And. nPosChv2 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 16 // SB5 - Complemento de Produto
		cCpoCab  := ""
		nPosCod	:= aScan(aTipoImp,{|x| alltrim(x) == "B5_COD"})
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "B5_COD"})
		If nPosChv1 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 17 // SC3- Contrato de Parceria
		cCpoCab  := "C3_FILIAL/C3_NUM/C3_EMISSAO/C3_FORNECE/C3_LOJA/C3_COND/C3_CONTATO/C3_FILENT/C3_MOEDA/"
		nPosCod	:= aScan(aTipoImp,{|x| alltrim(x) == "C3_NUM"})
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "C3_NUM"})
		If nPosChv1 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 18 // VV1 - Veiculos
		cCpoCab  := ""
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "VV1_CHASSI"})
		If nPosChv1 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(2) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 19 // VRJ - Pedido de Venda de Veiculo  Montadora
		cCpoCab  := ""
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "VRJ_PEDIDO"})
		If nPosChv1 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If ( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 20 // VVF - Nota Entrada Veículo Montadora
		cCpoCab  := ""
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "VVF_TRACPA"})
		If nPosChv1 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 21 // SW2 - Purchase Order
		cCpoCab  := ""
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "W2_PO_NUM"})
		If nPosChv1 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(1) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	ElseIf nRadMenu1 == 22 // SA5- Amarracao Produto x Fornecedor
		cCpoCab		:= "A5_FILIAL/A5_PRODUTO/"
		nPosCod		:= aScan(aTipoImp,{|x| alltrim(x) == "A5_PRODUTO"})
		nPosChv1	:= aScan(aTipoImp,{|x| alltrim(x) == "A5_PRODUTO"})
		If nPosChv1 > 0
			(aTabExclui[nRadMenu1][2][1])->( dbSetOrder(2) )
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial((aTabExclui[nRadMenu1][2][1])) ) )
				lVldReg := .T.
			EndIf
		EndIf
	EndIf

	cCpoCod	:= ""
	aCodPro	:= {}
	nI		:= 0

	// 08/08/2019 - Atilio - Geração de log em tabela
	aCampos	:= {}
	AADD(aCampos,{"LINHA"	,"C", 06	, 00	})
	AADD(aCampos,{"CODIGO"	,"C", 50	, 00	}) // G1_COD (23) + G1_COMP (23) + G1_TRT (03)
	AADD(aCampos,{"STATUS"	,"C", 09	, 00	})
	AADD(aCampos,{"ERRO"	,"M", 20	, 00	})
	
	cArqTop	:= CriaTrab(,.F.)
	If Select("TMPLOG") > 0
		dbSelectArea( "TMPLOG" )
		dbCloseArea()
		TCDelFile(cArqTop)
	EndIf
	
	dbCreate( cArqTop , aCampos , "TOPCONN" )
	
	dbUseArea( .T. , "TOPCONN" , cArqTop , "TMPLOG" , .T. , .F. )
	dbCreateIndex( cArqTop , "LINHA" )
	
	dbSelectArea( "TMPLOG" )
	dbSetOrder(1)
	
	FT_FUSE(cArq)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	
	cLinha	:= FT_FREADLN()
	cLinCab	:= cLinha
	cLinDet	:= ""
	aCampos := Separa(cLinha,";",.T.)
	FT_FSKIP()
	lPrim := .F.
	cLinha := ""
	nI++

	While !FT_FEOF()

		IncProc("Importando registros...")

		nI++
		
		//MsgStop('IncProc("Importando registros...") ' + AllTrim(Str(nI)))

		If Empty( cLinha )
			cLinha := FT_FREADLN()
		EndIf

		//If lPrim
		//	aCampos := Separa(cLinha,";",.T.)
		//	lPrim := .F.
		//	If nRadMenu1 <> 12
		//		FT_FSKIP()
		//	EndIf
		
		//ElseIf !Empty(cLinha)

		aDados	:= Separa(cLinha,";",.T.)
		cLinha  := " "

		aExecAuto	:= {}
		aExecAutod	:= {}
		aExecAutol	:= {}
		aFilAnt		:= {}

		If nPosCod > 0
			cCod	:= aDados[nPosCod]
		
			If nRadMenu1 == 12  
				cLoj	:= aDados[nPosLoj]
			ElseIf nRadMenu1 == 8 // SN1- Ativo FIxo
				cGrupo	:= aDados[nPosGrp]
			EndIf

		Else
			cCod	:= ""
		EndIf

		cVldReg	:= ""
		If nPosChv1 > 0
		
			//cVldReg	:= Stuff( Space( TamSX3(Upper(aCampos[nPosChv1]))[1] ) , 1 , Len(AllTrim(cCod)) , AllTrim(cCod) )
			If nPosChv1 > 0
				cVldReg	+= Stuff( Space( TamSX3(Upper(aCampos[nPosChv1]))[1] ) , 1 , Len(AllTrim(aDados[nPosChv1])) , AllTrim(aDados[nPosChv1]) )
			EndIf
			If nPosChv2 > 0
				cVldReg	+= Stuff( Space( TamSX3(Upper(aCampos[nPosChv2]))[1] ) , 1 , Len(AllTrim(aDados[nPosChv2])) , AllTrim(aDados[nPosChv2]) )
			EndIf
			If nPosChv3 > 0
				cVldReg	+= Stuff( Space( TamSX3(Upper(aCampos[nPosChv3]))[1] ) , 1 , Len(AllTrim(aDados[nPosChv3])) , AllTrim(aDados[nPosChv3]) )
			EndIf
			If nPosChv4 > 0
				cVldReg	+= Stuff( Space( TamSX3(Upper(aCampos[nPosChv4]))[1] ) , 1 , Len(AllTrim(aDados[nPosChv4])) , AllTrim(aDados[nPosChv4]) )
			EndIf
			If nPosChv5 > 0
				cVldReg	+= Stuff( Space( TamSX3(Upper(aCampos[nPosChv5]))[1] ) , 1 , Len(AllTrim(aDados[nPosChv5])) , AllTrim(aDados[nPosChv5]) )
			EndIf
			If nPosChv6 > 0
				cVldReg	+= Stuff( Space( TamSX3(Upper(aCampos[nPosChv6]))[1] ) , 1 , Len(AllTrim(aDados[nPosChv6])) , AllTrim(aDados[nPosChv6]) )
			EndIf
		
		EndIf
			
		RecLock("TMPLOG",.T.)
		TMPLOG->LINHA	:= StrZero(nI,6)
		TMPLOG->CODIGO	:= IIF(Empty(cVldReg),aTabExclui[nRadMenu1][2][1],cVldReg)

		If lVldReg
			If (aTabExclui[nRadMenu1][2][1])->( dbSeek( xFilial(aTabExclui[nRadMenu1][2][1])+cVldReg ) )
				If nRadMenu1 == 24
					If RecLock("SB1",.F.)
						SB1->B1_CUSTD	:= Val( aDados[nPosCust] )
						SB1->( msUnlock() )
						TMPLOG->STATUS	:= "Sucesso"
					Else
						TMPLOG->STATUS	:= "Erro"
						TMPLOG->ERRO	:= "Falha em travar registro"
					EndIf
				Else
					TMPLOG->STATUS	:= "Sucesso"
					TMPLOG->ERRO	:= "Cadastro Existente"
				EndIf
			ElseIf nRadMenu1 == 24
				TMPLOG->STATUS	:= "Erro"
				TMPLOG->ERRO	:= "Produto nao cadastrado: "+AllTrim(cVldReg)
			ElseIf nRadMenu1 == 2 // "SG1"
				cPrdPai	:= Stuff( Space( TamSX3(Upper(aCampos[nPosChv1]))[1] ) , 1 , Len(AllTrim(aDados[nPosChv1])) , AllTrim(aDados[nPosChv1]) )
				cPrdFil	:= Stuff( Space( TamSX3(Upper(aCampos[nPosChv2]))[1] ) , 1 , Len(AllTrim(aDados[nPosChv2])) , AllTrim(aDados[nPosChv2]) )
				cSeqTRT	:= Stuff( Space( TamSX3(Upper(aCampos[nPosChv3]))[1] ) , 1 , Len(AllTrim(aDados[nPosChv3])) , AllTrim(aDados[nPosChv3]) )
				//cQtdEst	:= Stuff( Space( TamSX3(Upper(aCampos[nPosQtd]))[1] ) , 1 , Len(AllTrim(aDados[nPosQtd])) , AllTrim(aDados[nPosQtd]) ) 
				lLoop := .F.
				If  cPrdPai == cPrdFil
					TMPLOG->STATUS	:= "N/A"
					TMPLOG->ERRO	:= "Codigos de Produto se repete no Componente"
					lLoop := .T.
				ElseIf !SB1->( dbSeek( xFilial("SB1")+cPrdPai ) )
					TMPLOG->STATUS	:= "Erro"
					TMPLOG->ERRO	:= "Produto nao cadastrado: "+AllTrim(cPrdPai)
					lLoop := .T.
				ElseIf !SB1->( dbSeek( xFilial("SB1")+cPrdFil ) )
					TMPLOG->STATUS	:= "Erro"
					TMPLOG->ERRO	:= "Produto nao cadastrado: "+AllTrim(cPrdFil)
					lLoop := .T.
				ElseIf SG1->( dbSeek( xFilial("SG1")+cPrdPai+cPrdFil+cSeqTRT ) )
					TMPLOG->STATUS	:= "Sucesso"
					TMPLOG->ERRO	:= "Cadastro Existente"
					lLoop := .T.
				//ElseIf Val(cQtdEst)
				//	TMPLOG->STATUS	:= "N/A"
				//	TMPLOG->ERRO	:= "Quantidade 0"
				ElseIf SG1->( dbSeek( xFilial("SG1")+cPrdPai ) )
					TMPLOG->STATUS	:= "Erro"
					TMPLOG->ERRO	:= "Existe estrutura cadastrada para produto "+AllTrim(cPrdPai)
					lLoop := .T.
				Else
					// Verifica se chave já existe na carga (G1_COD || G1_COMP || G1_TRT)
	
					cQuery := "SELECT  LINHA "
					cQuery += "FROM "+ cArqTop +" "    
					cQuery += "WHERE CODIGO = '"+cVldReg+"' "
					cQuery += "		AND LINHA <> '"+StrZero(nI,6)+"'  "
					
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.T.,.T.)
					dbSelectArea(cAliasTRB)
				
					If !Empty( (cAliasTRB)->LINHA )
						TMPLOG->STATUS	:= "N/A"
						TMPLOG->ERRO	:= "Registro duplicado, verificar linha "+(cAliasTRB)->LINHA
						lLoop := .T.
						//If TRB1->( dbSeek( IIF("G1_FILIAL"$cIndTrb,xFilial("SG1"),"")+cVldReg ) )
						//	RecLock("TRB1",.F.)
						//	TRB1->( dbDelete() )
						//	TRB1->( msUnlock() )
						//EndIf
					EndIf
					
					(cAliasTRB)->( dbCloseArea() )
					
					If lLoop
						FT_FSKIP()
						Loop
					EndIf

				EndIf
			EndIf
		ElseIf nRadMenu1 == 2 // "SG1"
			cPrdPai	:= Stuff( Space( TamSX3(Upper(aCampos[nPosChv1]))[1] ) , 1 , Len(AllTrim(aDados[nPosChv1])) , AllTrim(aDados[nPosChv1]) )
			cPrdFil	:= Stuff( Space( TamSX3(Upper(aCampos[nPosChv2]))[1] ) , 1 , Len(AllTrim(aDados[nPosChv2])) , AllTrim(aDados[nPosChv2]) ) 
			If  cPrdPai == cPrdFil
				TMPLOG->STATUS	:= "N/A"
				TMPLOG->ERRO	:= "Codigos de Produto se repete no Componente"
			ElseIf !SB1->( dbSeek( xFilial("SB1")+cPrdPai ) )
				TMPLOG->STATUS	:= "Erro"
				TMPLOG->ERRO	:= "Produto nao cadastrado: "+AllTrim(cPrdPai)
			ElseIf !SB1->( dbSeek( xFilial("SB1")+cPrdFil ) )
				TMPLOG->STATUS	:= "Erro"
				TMPLOG->ERRO	:= "Produto nao cadastrado: "+AllTrim(cPrdFil)
			ElseIf SG1->( dbSeek( xFilial("SG1")+cPrdPai+cPrdFil ) )
				TMPLOG->STATUS	:= "Sucesso"
				TMPLOG->ERRO	:= "Cadastro Existente"
			Else
				// Verifica se chave já existe na carga (G1_COD || G1_COMP || G1_TRT)

				cQuery := "SELECT  LINHA "
				cQuery += "FROM "+ cArqTop +" "    
				cQuery += "WHERE CODIGO = '"+cVldReg+"' "
				cQuery += "		AND LINHA <> '"+StrZero(nI,6)+"'  "
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.T.,.T.)
				dbSelectArea(cAliasTRB)
			
				If !Empty( (cAliasTRB)->LINHA )
					TMPLOG->STATUS	:= "N/A"
					TMPLOG->ERRO	:= "Registro duplicado, verificar linha "+(cAliasTRB)->LINHA
					//If TRB1->( dbSeek( IIF("G1_FILIAL"$cIndTrb,xFilial("SG1"),"")+cVldReg ) )
					//	RecLock("TRB1",.F.)
					//	TRB1->( dbDelete() )
					//	TRB1->( msUnlock() )
					//EndIf
				EndIf
				
				(cAliasTRB)->( dbCloseArea() )

			EndIf
		ElseIf nRadMenu1 == 9

			cPrdSD3	:= Stuff( Space( TamSX3("B1_COD")[1] ) , 1 , Len(AllTrim(cCod)) , AllTrim(cCod) )

			If !SB1->( dbSeek( xFilial("SB1")+cPrdSD3 ) )
				TMPLOG->STATUS	:= "Erro"
				TMPLOG->ERRO	:= "Produto nao cadastrado"
			ElseIf SB1->B1_MSBLQL == "1"
				TMPLOG->STATUS	:= "Erro"
				TMPLOG->ERRO	:= "Produto bloqueado"
			ElseIf SB1->B1_FANTASM == "S"
				TMPLOG->STATUS	:= "Erro"
				TMPLOG->ERRO	:= "Produto fantasma"
			ElseIf "1" == GetAdvFVal("SB5","B5_CTRWMS",xFilial("SB5")+cPrdSD3,1,"")
				TMPLOG->STATUS	:= "N/A"
				TMPLOG->ERRO	:= "Produto controlado pelo WMS"
			Else
				// Verifica se chave já existe na carga (D3_COD || D3_LOCAL || D3_LOTECTL || D3_LOCALIZ)

				cQuery := "SELECT  LINHA "
				cQuery += "FROM "+ cArqTop +" "    
				cQuery += "WHERE CODIGO = '"+cVldReg+"' "
				cQuery += "		AND LINHA <> '"+StrZero(nI,6)+"'  "
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.T.,.T.)
				dbSelectArea(cAliasTRB)
			
				If !Empty( (cAliasTRB)->LINHA )
					TMPLOG->STATUS	:= "N/A"
					TMPLOG->ERRO	:= "Registro duplicado, verificar linha "+(cAliasTRB)->LINHA
				EndIf
				
				(cAliasTRB)->( dbCloseArea() )
				
				If Empty(TMPLOG->STATUS)
						
					// Verifica se chave já existe na carga (D3_COD || D3_LOCAL || D3_LOTECTL || D3_LOCALIZ)
					BeginSql Alias cAliasTRB
				
						SELECT *
				
						FROM %table:SD3% SD3
				
						WHERE  SD3.%NotDel%
							AND D3_FILIAL = %xFilial:SD3%
							AND D3_OBSERVA = %Exp:cVldReg%
							
				
					EndSql
				
					If !Empty( (cAliasTRB)->D3_FILIAL )
						TMPLOG->STATUS	:= "Sucesso"
						TMPLOG->ERRO	:= "Codigo localizado"
					EndIf
					
					(cAliasTRB)->( dbCloseArea() )
					
				EndIf
			EndIf

		EndIf

		TMPLOG->( msUnlock() )

		//MsgStop( "TMPLOG " + TMPLOG->(LINHA+"-"+CODIGO+"-"+STATUS+"-"+ERRO) )
		
		If !Empty(TMPLOG->STATUS)
				
			FT_FSKIP()
			Loop

		EndIf

		If (Empty( cCpoCab ) .Or. cCpoCod <> cCod) .And. IIF(Empty(cCod),.T.,IIF(Empty(aCodPro),.T.,aScan(aCodPro,{|x| alltrim(x) == cCod})==0))

			cCpoCod := cCod
			If nRadMenu1 == 2 /*SG1*/
				aAdd(aCodPro,cCod)
			EndIf

			nLinha	:= nI

			For nCampos := 1 To Len(aCampos)
				If IIF(Empty(cCpoCab),.T.,AllTrim(Upper(aCampos[nCampos]))+"/"$cCpoCab)
					IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL' //.OR. SUBSTR(Upper(aCampos[nCampos]),5,6)=='FILIAL' //Por conta das VV
						IF !Empty(aDados[nCampos])
							//msgStop( "12C - xFilial NNR " + xFilial("NNR") ) 
							//MsgStop( "12C - cFilAnt     " + cFilAnt )
							//MsgStop( "12C - aDados      " + aDados[nCampos] )

							//cFilAnt := aDados[nCampos]
						ENDIF
					Else
						If ("CNUMCON" $ aCampos[nCampos] .OR. "CBANCOADT" $ aCampos[nCampos] .OR. "CAGENCIAADT" $ aCampos[nCampos] ) .Or. ;
							aCampos[nCampos] $ "IMOBILIZADO;NUMERO_DI;DT_DI;NOTA_FISCAL;SERIE_NOTA;DATA_FATURAMENTO;FORNECEDOR;LOJA;CUSTO_MEDIO;VV1_PRODUTO" //.OR. "AUTO" $ aCampos[nCampos])
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	aDados[nCampos]	,Nil})
						ElseIF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
							aDados[nCampos]	:= StrTran( aDados[nCampos] , "," , "." )
							If  AllTrim(Upper(aCampos[nCampos]))== 'D3_CUSTO1'
								If !Empty(VAL(aDados[nCampos] )) // Custo > 0
									aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nCampos] )	,Nil})
									aAdd(aExecAuto ,{ "D3_TM" , cTMCus , Nil} )
								Else
									aAdd(aExecAuto ,{ "D3_TM" , cTMCus0 , Nil} )
								EndIf
							ElseIf !Empty(VAL(aDados[nCampos] ))
								aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nCampos] )	,Nil})
							EndIf


						ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
							If !Empty( CTOD(aDados[nCampos] ) )
								aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nCampos] )	,Nil})
							EndIf
						ElSeIf !Empty( aDados[nCampos] )

							If Upper(aCampos[nCampos]) $ "A3_COD/B1_COD/B1_LOCPAD/D3_COD/D3_LOCALIZ/D3_LOTECTL/N1_CBASE/N1_ITEM/C1_NUM/C5_NUM/C7_NUM/A1_COD/G1_COD/C3_NUM/B5_COD/Z9_ZCLIENT/W0__NUM/W2_PO_NUM/VRJ_PEDIDO/VV1_CHAINT/W3_PO_NUM/A5_PRODUTO/"
								xValor	:= Stuff( Space( TamSX3(Upper(aCampos[nCampos]))[1] ) , 1 , Len(aDados[nCampos]) , aDados[nCampos] )
								If Upper(aCampos[nCampos]) == "G1_FIXVAR" .And. xValor == "F"
									xValor := "V"
								EndIf 
								aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	xValor	, IIF(Upper(aCampos[nCampos]) == "B1_LOCPAD", ".T." , Nil ) })
								If Upper(aCampos[nCampos]) $ "N1_CBASE/C1_NUM/C5_NUM/C7_NUM/A1_COD/G1_COD/C3_NUM/VV1_CHAINT/W2_PO_NUM/W3_PO_NUM/A5_PRODUTO/"
									cBemN1  := xValor
								ElseIf Upper(aCampos[nCampos]) $ "N1_ITEM/"
									cItemN1 := xValor
								EndIf
								//EndIf
							Else
								aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	aDados[nCampos] 	,Nil})
							EndIf

						ENDIF
					ENDIF
				EndIf
			Next nCampos

			If nRadMenu1 == 2
				aAdd(aExecAuto ,{"G1_QUANT",1,NIL})
				aAdd(aExecAuto ,{"NIVALT","S",NIL})
			ElseIf nRadMenu1 == 9
				aAdd(aExecAuto ,{"D3_OBSERVA",cVldReg,NIL})
			EndIf

			lCodBase	:= .T.

			If nRadMenu1 == 8 .Or. nRadMenu1 == 11 .Or. nRadMenu1 == 14 .Or. nRadMenu1 == 10  .Or. nRadMenu1 == 2 .Or. nRadMenu1 == 17 /*.Or. nRadMenu1 == 18*/ .Or. nRadMenu1 == 21 .or. nRadMenu1 == 22

				If nRadMenu1 == 8
					cChave	:= "TRB1->("+IIF( TRB1->( FieldPos( "N3_FILIAL" ) ) > 0,"N3_FILIAL+","")+"N3_CBASE+N3_ITEM)"
					cFilChv	:= IIF( TRB1->( FieldPos( "N3_FILIAL" ) ) > 0,cFilAnt,"") + cBemN1 + cItemN1
				ElseIf nRadMenu1 == 14
					cChave	:= "TRB1->("+IIF( TRB1->( FieldPos( "C1_FILIAL" ) ) > 0,"C1_FILIAL+","")+"C1_NUM)"
					cFilChv	:= IIF( TRB1->( FieldPos( "C1_FILIAL" ) ) > 0,cFilAnt,"") + cBemN1
				ElseIf nRadMenu1 == 11
					cChave	:= "TRB1->("+IIF( TRB1->( FieldPos( "C6_FILIAL" ) ) > 0,"C6_FILIAL+","")+"C6_NUM)"
					cFilChv	:= IIF( TRB1->( FieldPos( "C6_FILIAL" ) ) > 0,cFilAnt,"") + cBemN1
				ElseIf nRadMenu1 == 10
					cChave	:= "TRB1->("+IIF( TRB1->( FieldPos( "C7_FILIAL" ) ) > 0,"C7_FILIAL+","")+"C7_NUM)"
					cFilChv	:= IIF( TRB1->( FieldPos( "C7_FILIAL" ) ) > 0,cFilAnt,"") + cBemN1
				ElseIf nRadMenu1 == 2
					cChave	:= "TRB1->("+IIF( TRB1->( FieldPos( "G1_FILIAL" ) ) > 0,"G1_FILIAL+","")+"G1_COD)"
					cFilChv	:= IIF( TRB1->( FieldPos( "G1_FILIAL" ) ) > 0,cFilAnt,"") + cBemN1
				ElseIf nRadMenu1 == 17
					cChave	:= "TRB1->("+IIF( TRB1->( FieldPos( "C3_FILIAL" ) ) > 0,"C3_FILIAL+","")+"C3_NUM)"
					cFilChv	:= IIF( TRB1->( FieldPos( "C3_FILIAL" ) ) > 0,xFilial("SC3"),"") + cBemN1
    			ElseIf nRadMenu1 == 18
					cChave	:= "TRB1->("+IIF( TRB1->( FieldPos( "VV1_FILIAL" ) ) > 0,"VV1_FILIAL+","")+"VV1_CHAINT)"
					cFilChv	:= IIF( TRB1->( FieldPos( "VV1_FILIAL" ) ) > 0,xFilial("VV1"),"") + cBemN1
				ElseIf nRadMenu1 == 19
					cChave	:= "TRB1->("+IIF( TRB1->( FieldPos( "VRK_FILIAL" ) ) > 0,"VRK_FILIAL+","")+"VRK_PEDIDO)"
					cFilChv	:= IIF( TRB1->( FieldPos( "VRK_FILIAL" ) ) > 0,xFilial("VRK"),"") + cBemN1
				ElseIf nRadMenu1 == 20
					cChave	:= "TRB1->("+IIF( TRB1->( FieldPos( "VVF_FILIAL" ) ) > 0,"VVF_FILIAL+","")+"VVF_TRACPA)"
					cFilChv	:= IIF( TRB1->( FieldPos( "VVF_FILIAL" ) ) > 0,xFilial("VVF"),"") + cBemN1
				ElseIf nRadMenu1 == 21
					cChave	:= "TRB1->("+IIF( TRB1->( FieldPos( "W3_FILIAL" ) ) > 0,"W3_FILIAL+","")+"W3_PO_NUM)"
					cFilChv	:= IIF( TRB1->( FieldPos( "W3_FILIAL" ) ) > 0,xFilial("SW3"),"") + cBemN1
					/*
					TRB1->( DbGoTop() )  
					While !TRB1->( eof() ) 
					   	For nCamposd := 1 to Len( aCamposd ) //
							If IIF(Empty(cCpoCab) .Or. nRadMenu1 == 2,.T.,!aCamposd[nCamposd]+"/" $ cCpoCab )
								//If !Empty( &("TRB1->"+aCamposd[nCamposd]) )
									aAdd( aExecAutol , { aCamposd[nCamposd] , &("TRB1->"+aCamposd[nCamposd]) , NIL } )
								//EndIf
							EndIf
						Next nCamposd
						
						If aScan(aExecAutol, {|x|x[1] == "W3_REG"}) == 0
							ConOut("aAdd( aExecAutol")
						   aAdd( aExecAutol , { "W3_REG" , Space(TamSX3("W3_REG")[1]) , NIL } )
						Endif

						aAdd( aExecAutod , aExecAutol )
						aExecAutol	:= {}
						TRB1->( dbSkip() )
					EndDo
					*/
				ElseIf nRadMenu1 == 22
					//cChave	:= "TRB1->("+IIF( TRB1->( FieldPos( "A5_FILIAL" ) ) > 0,"A5_FILIAL+","")+"A5_PRODUTO+A5_FORNECE)"
					//cFilChv	:= IIF( TRB1->( FieldPos( "A5_FILIAL" ) ) > 0,cFilAnt,"") + cBemN1
					cChave	:= "TRB1->("+IIF( TRB1->( FieldPos( "A5_FILIAL" ) ) > 0,"A5_FILIAL+","")+"A5_PRODUTO)"
					cFilChv	:= IIF( TRB1->( FieldPos( "A5_FILIAL" ) ) > 0,xFilial("SA5"),"") + cBemN1
				Else
					cChave	:= ""
					cFilChv	:= ""
				EndIf

                //If nRadMenu1 <> 21
					lSeek	:= TRB1->( dbSeek( cFilChv ) )
	
					While !TRB1->( eof() ) .And. &(cChave) == cFilChv
						For nCamposd := 1 to Len( aCamposd )
							If IIF(Empty(cCpoCab) .Or. nRadMenu1 == 2,.T.,!aCamposd[nCamposd]+"/" $ cCpoCab )
								If !Empty( &("TRB1->"+aCamposd[nCamposd]) )
									aAdd( aExecAutol , { aCamposd[nCamposd] , &("TRB1->"+aCamposd[nCamposd]) , NIL } )
								ElseIf aCamposd[nCamposd] == "G1_QUANT"
									aAdd( aExecAutol , { aCamposd[nCamposd] , 0.001 , NIL } )
								EndIf
							EndIf
						Next nCamposd
						aAdd( aExecAutod , aExecAutol )
						aExecAutol	:= {}
						TRB1->( dbSkip() )
					EndDo
                //EndIF
/*
				If nRadMenu1 == 8

//					If TRB1->N3_CBASE == cBemN1
//
//						lCodBase	:= .F.
//
//					Else


						FT_FSKIP()

						If !FT_FEOF()

							cLinha := FT_FREADLN()

							aDados	:= Separa(cLinha,";",.T.)
							
							If cCod == aDados[nPosCod]
								lCodBase	:= .F.
							EndIf

						EndIf

//					EndIf

				EndIf
*/
			ElseIf nRadMenu1 == 12  

				FT_FSKIP()

				If !FT_FEOF()

					cLinha := FT_FREADLN()

					aDados	:= Separa(cLinha,";",.T.)
					If cCod + cLoj == aDados[nPosCod]+aDados[nPosLoj]
						lCodBase	:= .F.
					EndIf

				EndIf
				//FT_FSKIP(-1)

			EndIf

			aAdd( aThrCab , aExecAuto	)
			aAdd( aThrDet , aExecAutod 	)
			aAdd( aThrLin , nLinha	)
			aAdd( aThrFil , cFilAnt )

		Else
			RecLock("TMPLOG",.F.)
			TMPLOG->STATUS	:= "N/A"
			TMPLOG->ERRO	:= "Registro referente a item de carga"
			TMPLOG->( msUnlock() )
		EndIf

		If nRadMenu1 == 8

			FT_FSKIP()

			If !FT_FEOF()

				cLinha := FT_FREADLN()

				aDados	:= Separa(cLinha,";",.T.)
							
				If cCod	== aDados[nPosCod] // .Or. cGrupo	== aDados[nPosGrp]
					lCodBase	:= .F.
				EndIf

			EndIf

		EndIf
		
//						xValor	:= StrTran(aDadosd[nCamposd],'"')

		
		/*If nRadMenu1 == 18
		   aCamposD := {}
		   FOR nY := 1 TO LEN(aCampos)
		   	   IF  TamSx3(Upper(aCampos[nY]))[3] =='N'
					aDados[nY] := Val(StrTran( aDados[nY] , "," , "." ))
               ELSEIF TamSx3(Upper(aCampos[nY]))[3] =='D'
					If !Empty( CTOD(aCampos[nY] ) )
						aAdd(aCamposD ,{Upper(aCampos[nY]),  CTOD(aDados[nY] )	,Nil})
					EndIf
			   EndIf
               aAdd(aCamposD,{aCampos[nY],	aDados[nY]}) 			   	
           Next nY
		   cErro := ImptVeic(aCamposD)  //Cadastro de Veículos				
		endif*/
		
/*
		If nRadMenu1 == 1

			lMsHelpAuto := .T.
			lMsErroAuto := .F.

			//MsgStop( "13 - xFilial NNR " + xFilial("NNR") )
			//MsgStop( "13 - cFilAnt     " + cFilAnt )
			
			ConOut( VarInfo("CMVIMP01",aExecAuto) )
			
			MSExecAuto({|x,y| MATA010(x,y)},aExecAuto,3) // SB1 Produto
			
			//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
			If lMsErroAuto

				MostraErro()

			EndIf
		
		ElseIf Len( aThrCab ) >= nThrTrn .And. lCodBase
*/		
		If Len( aThrCab ) >= nThrTrn .And. lCodBase
		
			//ConOut("Len( aThrCab ) " + Str(Len( aThrCab )))

			aAdd( aThrDat , {	aThrCab	,;
			aThrDet	,;
			aThrLin ,;
			cEmpAnt ,;
			aThrFil , cLogDir+"IMP_"+aTabExclui[nRadMenu1][1]+"-"+DTOS(Date())+StrTran(Time(),":")+".LOG" , nRadMenu1 } )

			aThrCab := {}
			aThrDet := {}
			aThrLin	:= {}
			aThrFil	:= {}

			If !lGrid // Threads
				/*
				oGrid:Go(aThrDat[1][7],aThrDat[1][3],aThrDat[1][1],aThrDat[1][2],aThrDat[1][4],aThrDat[1][5],aThrDat[1][6],dDataBase)

				aDel( aThrDat , 1 )

				aSize( aThrDat , Len( aThrDat ) - 1 )

				ElseIf !lGrid // Threads
				*/
				aMonThread := U_zMonThread("U_XEXEC")

				While aMonThread[1] >= nThrMax // .And. Len( aThrDat ) > 0

					Sleep( 1000 )

					aMonThread := U_zMonThread("U_XEXEC")

				EndDo

				ConOut("## CMVIMP01 - Nr de Threads ["+StrZero(aMonThread[1],03,0)+"] - Memoria ["+StrZero(aMonThread[2],12,0)+"] ##")

				// 26/09/2019 - Desabilitar multi-threasd
				StartJob ("U_XEXEC",GEtEnvServer(),.F.,aThrDat[1][7],aThrDat[1][3],aThrDat[1][1],aThrDat[1][2],aThrDat[1][4],aThrDat[1][5],aThrDat[1][6],dDataBase,lGrid,cArqTop)
				//StartJob ("U_XEXEC",GEtEnvServer(),.T.,aThrDat[1][7],aThrDat[1][3],aThrDat[1][1],aThrDat[1][2],aThrDat[1][4],aThrDat[1][5],aThrDat[1][6],dDataBase,lGrid,cArqTop)

				If lPrimThr
					Sleep( 30000 )
					lPrimThr	 := .F.
				EndIf

				aDel( aThrDat , 1 )

				aSize( aThrDat , Len( aThrDat ) - 1 )

				aMonThread := U_zMonThread("U_XEXEC")

				nThrTrn	:= GetMv("CMV_IMP01B",,20)			// Número de Transações x Thread
				If nRadMenu1 <> 8
					nThrMax	:= GetMv("CMV_IMP01C",,20)			// Número de Transações x Thread
				EndIf

			Else
				/*
				While oGrid:GetIdleThreads() == 0

				Sleep( 1000 )

				EndDo
				*/
				//ConOut("## CMVIMP01 - Nr de Idle Threads ["+StrZero(oGrid:GetIdleThreads(),05,0)+"] ##")

				lGridOk := .F.
				nGrid++
				//MsgStop("Grid de Processamento - Envio ["+StrZero(nGrid,05,0)+"]" ,"Grid Execution")
				//While !lGridOk
				//MsgStop("Grid de Processamento - Start ["+StrZero(nGrid,05,0)+"]" ,"Grid Execution")

				lGridOk := oGrid:Execute({aThrDat[1][7],aThrDat[1][3],aThrDat[1][1],aThrDat[1][2],aThrDat[1][4],aThrDat[1][5],aThrDat[1][6],dDataBase,lGrid,cArqTop})
				//EndDo
				If !lGridOk
					cGridMsg := "[GRID] Erro oGrid:Execute()"+CRLF
					// An error occurred, either in processing, or in
					// Grid termination. Check the property arrays
					If !empty(oGrid:aErrorProc)
						// One or more fatal errors occurred that aborted the process
						// [1] : Sequential number of sent instruction that was not processed
						// [2] : Parameter sent for processing
						// [3] : Identification of Agent where the error occurred
						// [4] : Details of error event
						cGridMsg += CRLF
						cGridMsg += varinfo('ERR',oGrid:aErrorProc)+CRLF
					Endif
					If !empty(oGrid:aSendProc)
						// returns list of calls sent and not executed
						// [1] Sequential number of instruction
						// [2] Sending parameter
						// [3] Identification of Agent that received the requisition
						cGridMsg += CRLF
						cGridMsg += varinfo('PND',oGrid:aSendProc)+CRLF
					Endif
					cGridMsg += oGrid:GetError()
					cGridArq := cLogDir+"IMP_"+aTabExclui[nRadMenu1][1]+"-"+DTOS(Date())+StrTran(Time(),":")+".LOG"
					U_zGravaLog(cGridArq,cGridMsg)
				EndIf

				//MsgStop("Grid de Processamento - Fim ["+StrZero(nGrid,05,0)+"]","Grid Execution")

				If lPrimThr
					Sleep( 30000 )
					lPrimThr	 := .F.
				EndIf

				aDel( aThrDat , 1 )

				aSize( aThrDat , Len( aThrDat ) - 1 )

				nThrTrn	:= GetMv("CMV_IMP01B",,20)			// Número de Transações x Thread
				If nRadMenu1 <> 8
					nThrMax	:= GetMv("CMV_IMP01C",,20)			// Número de Transações x Thread
				EndIf

			EndIf

		EndIf

		//EndIf

		If nRadMenu1 <> 12 .And. nRadMenu1 <> 8 
			FT_FSKIP()
			// ConOut("FT_FSKIP()")
		EndIf

	EndDo

	//FT_FUSE()



//cErro := GravaMVC( "VEIA070","VV1","MODEL_VV1",aExecAuto,"MODEL_VV1",aExecAutod )  //Veículos 

	//If nRadMenu1 <> 1
	//Else
	If Len( aThrCab ) > 0 .Or. Len( aThrDat ) > 0

		If Len( aThrCab ) > 0

			aAdd( aThrDat , { aThrCab , aThrDet , aThrLin , cEmpAnt , aThrFil , cLogDir+"IMP_"+aTabExclui[nRadMenu1][1]+"-"+DTOS(Date())+StrTran(Time(),":")+".LOG" , nRadMenu1 } )

			aThrCab := {}
			aThrDet := {}
			aThrLin	:= {}
			aThrFil	:= {}

		EndIf

		While Len( aThrDat ) > 0

			If !lGrid
				/*
				oGrid:Go(aThrDat[1][7],aThrDat[1][3],aThrDat[1][1],aThrDat[1][2],aThrDat[1][4],aThrDat[1][5],aThrDat[1][6],dDataBase)

				aDel( aThrDat , 1 )

				aSize( aThrDat , Len( aThrDat ) - 1 )

				ElseIf !lGrid
				*/
				aMonThread := U_zMonThread("U_XEXEC")

				If aMonThread[1] < nThrMax

					ConOut("## CMVIMP01 - Nr de Threads ["+StrZero(aMonThread[1],03,0)+"] - Memoria ["+StrZero(aMonThread[2],12,0)+"] ##")
					
					// 26/09/2019 - Desabilitar multi-threasd
					StartJob ("U_XEXEC",GEtEnvServer(),.F.,aThrDat[1][7],aThrDat[1][3],aThrDat[1][1],aThrDat[1][2],aThrDat[1][4],aThrDat[1][5],aThrDat[1][6],dDataBase,lGrid,cArqTop)
					//StartJob ("U_XEXEC",GEtEnvServer(),.T.,aThrDat[1][7],aThrDat[1][3],aThrDat[1][1],aThrDat[1][2],aThrDat[1][4],aThrDat[1][5],aThrDat[1][6],dDataBase,lGrid,cArqTop)

					If lPrimThr
						Sleep( 10000 )
						lPrimThr	 := .F.
					EndIf

					aDel( aThrDat , 1 )

					aSize( aThrDat , Len( aThrDat ) - 1 )

				Else
					Sleep(1000)
				EndIf

			Else
				/*
				While oGrid:GetIdleThreads() == 0

				Sleep( 1000 )

				EndDo
				*/
				//ConOut("## CMVIMP01 - Nr de Idle Threads ["+StrZero(oGrid:GetIdleThreads(),05,0)+"] ##")


				lGridOk := .F.
				nGrid++

				//MsgStop("Grid de Processamento - Envio ["+StrZero(nGrid,05,0)+"]" ,"Grid Execution")
				//While !lGridOk
				//MsgStop("Grid de Processamento - Start ["+StrZero(nGrid,05,0)+"]" ,"Grid Execution")

				lGridOk := oGrid:Execute({aThrDat[1][7],aThrDat[1][3],aThrDat[1][1],aThrDat[1][2],aThrDat[1][4],aThrDat[1][5],aThrDat[1][6],dDataBase,lGrid,cArqTop})
				//EndDo
				If !lGridOk
					cGridMsg := "[GRID] Erro oGrid:Execute()"+CRLF
					// An error occurred, either in processing, or in
					// Grid termination. Check the property arrays
					If !empty(oGrid:aErrorProc)
						// One or more fatal errors occurred that aborted the process
						// [1] : Sequential number of sent instruction that was not processed
						// [2] : Parameter sent for processing
						// [3] : Identification of Agent where the error occurred
						// [4] : Details of error event
						cGridMsg += CRLF
						cGridMsg += varinfo('ERR',oGrid:aErrorProc)+CRLF
					Endif
					If !empty(oGrid:aSendProc)
						// returns list of calls sent and not executed
						// [1] Sequential number of instruction
						// [2] Sending parameter
						// [3] Identification of Agent that received the requisition
						cGridMsg += CRLF
						cGridMsg += varinfo('PND',oGrid:aSendProc)+CRLF
					Endif
					cGridMsg += oGrid:GetError()
					cGridArq := cLogDir+"IMP_"+aTabExclui[nRadMenu1][1]+"-"+DTOS(Date())+StrTran(Time(),":")+".LOG"
					U_zGravaLog(cGridArq,cGridMsg)
				EndIf

				//MsgStop("Grid de Processamento - Fim ["+StrZero(nGrid,05,0)+"]","Grid Execution")

				If lPrimThr
					Sleep( 30000 )
					lPrimThr	 := .F.
				EndIf

				aDel( aThrDat , 1 )

				aSize( aThrDat , Len( aThrDat ) - 1 )

				nThrTrn	:= GetMv("CMV_IMP01B",,20)			// Número de Transações x Thread
				
				If nRadMenu1 <> 8
					nThrMax	:= GetMv("CMV_IMP01C",,20)			// Número de Transações x Thread
				EndIf

			EndIf

		EndDo

	EndIf

	//If nRadMenu1 <> 1
	//Else
	If !lGrid
		/*
		// Fechamento das Threads
		oGrid:Stop()	//Metodo aguarda o encerramento de todas as threads antes de retornar o controle.
		FreeObj(oGrid) 

		ElseIf !lGrid
		*/
		//Espera termino de todas as threads
		aMonThread := U_zMonThread("U_XEXEC","[CMVIMP01-"+AllTrim(StrZero(nRadMenu1,2))+"]")

		While aMonThread[1] > 0

			Sleep(1000)

			aMonThread := U_zMonThread("U_XEXEC","[CMVIMP01-"+AllTrim(Str(nRadMenu1))+"]")

		EndDo
	Else
		// Finalizar o Grid Grid.
		lGridOk := oGrid:Terminate()
		If !lGridOk
			cGridMsg := "[GRID] Erro oGrid:Terminate()"+CRLF
			// An error occurred, either in processing, or in
			// Grid termination. Check the property arrays
			If !empty(oGrid:aErrorProc)
				// One or more fatal errors occurred that aborted the process
				// [1] : Sequential number of sent instruction that was not processed
				// [2] : Parameter sent for processing
				// [3] : Identification of Agent where the error occurred
				// [4] : Details of error event
				cGridMsg += CRLF
				cGridMsg += varinfo('ERR',oGrid:aErrorProc)+CRLF
			Endif
			If !empty(oGrid:aSendProc)
				// returns list of calls sent and not executed
				// [1] Sequential number of instruction
				// [2] Sending parameter
				// [3] Identification of Agent that received the requisition
				cGridMsg += CRLF
				cGridMsg += varinfo('PND',oGrid:aSendProc)+CRLF
			Endif
			cGridMsg += oGrid:GetError()
			cGridArq := cLogDir+"IMP_"+aTabExclui[nRadMenu1][1]+"-"+DTOS(Date())+StrTran(Time(),":")+".LOG"
			U_zGravaLog(cGridArq,cGridMsg)
		EndIf
	EndIf

	dDataFim	:= Date()
	cHoraFim	:= Time()

	cTxtProc 	+= "##### "+StrZero(nTxtProc++,2)+" Importacao de Dados - Inicio: " + cHoraAux + " / Fim: " + cHoraFim + IIF(dDataAux==dDataFim," / Intervalo: "+ElapTime(cHoraAux,cHoraFim)," ") + "#####)"+CRLF
	aAdd( aTxtProc , { StrZero(Len(aTxtProc)+1,4) , "Importacao de Dados" , cHoraAux , cHoraFim , IIF(dDataAux==dDataFim, ElapTime(cHoraAux,cHoraFim) ," " ) } )

	Sleep(30000)

	dDataAux	:= Date()
	cHoraAux	:= Time()

	//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
	aArqLog := Directory(cLogDir+"IMP_"+aTabExclui[nRadMenu1][1]+"-*.LOG")

	cFilAnt := cBKFilial

	dDataFim	:= Date()
	cHoraFim	:= Time()

	cTxtProc 	+= "##### "+StrZero(nTxtProc++,2)+" Arquivo(s) LOG - Inicio: " + cHoraAux + " / Fim: " + cHoraFim + IIF(dDataAux==dDataFim," / Intervalo: "+ElapTime(cHoraAux,cHoraFim)," ") + "#####)"+CRLF+CRLF
	aAdd( aTxtProc , { StrZero(Len(aTxtProc)+1,4) , "Arquivo(s) LOG" , cHoraAux , cHoraFim , IIF(dDataAux==dDataFim, ElapTime(cHoraAux,cHoraFim) ," " ) } )

	dDataAux	:= Date()
	cHoraAux	:= Time()

	cTxtProc 	+= "##### [CMVIMP01] - Processamento Terminado - Inicio: " + cHoraIni + " / Fim: " + cHoraFim + IIF(dDataIni==dDataFim," / Intervalo: "+ElapTime(cHoraIni,cHoraFim),"") + " #####)"+CRLF
	cTxtProc	+= Replicate("-",80)+CRLF
	aAdd( aTxtProc , { "    " , "Processamento Total" , cHoraIni , cHoraFim , IIF(dDataAux==dDataFim, ElapTime(cHoraIni,cHoraFim) ," " ) } )

	//U_zGravaLog(cLogProc,cTxtProc)
/*
	aColunas := {"Etapa","Descrição","Inicio","Final","Intervalo"}
	//aTxtProc	:= {{"0001","Linha 0001"},{"0002","Linha 0002"}}
	cLogProc	:= "PROC_"+aTabExclui[nRadMenu1][1]+"-"+DTOS(Date())+StrTran(Time(),":")+".XML"
	cTxtProc	:= "CMVIMP01 Importacao "+aTabExclui[nRadMenu1][1] +" - " + DtoC( dDataIni ) + " - " + cHoraIni
	U_zGeraExc(aColunas,aTxtProc,cLogProc,cLogDir,IIf(!Empty( cPatLoc ) .And. ":\" $ cPatLoc , cPatLoc , "" ),cTxtProc)
*/

	aTxtLog := {}
	
	FT_FGoTop()
	nI	:= 1
	dbSelectArea( "TMPLOG" )
	dbGoTop()
	While !TMPLOG->(eof())
	
		If nRadMenu1 == 2 .And. Empty(TMPLOG->STATUS)
			RecLock("TMPLOG",.F.)
			If SG1->( dbSeek( xFilial("SG1") + AllTrim(TMPLOG->CODIGO) ) ) 
				TMPLOG->STATUS	:= "Sucesso"
				TMPLOG->ERRO	:= "Codigo localizado"
			Else
				TMPLOG->STATUS	:= "Erro"
				TMPLOG->ERRO	:= "Codigo nao localizado"
			EndIf
			TMPLOG->( msUnlock() )
		EndIf
		

		aAdd( aTxtLog , { TMPLOG->LINHA , TMPLOG->CODIGO , TMPLOG->STATUS , TMPLOG->ERRO } )
		
		If AllTrim(TMPLOG->STATUS) == "Erro" .Or. Empty(TMPLOG->STATUS)

			nLinha	:= Val(TMPLOG->LINHA)
			
			While !FT_FEOF() .And. nLinha > nI
			
				FT_FSkip()
				
				ni++
				
			EndDo 

			If nLinha == nI
				//cLinDet	+= FT_FReadLn() + CRLF
				GravaPen(FT_FReadLn(),cArqPen,cLinCab)
			EndIf


		EndIf
	
		TMPLOG->(dbSkip())

	EndDo

	FT_FUSE()
	
	dbSelectArea( "TMPLOG" )
	dbCloseArea()
	TCDelFile(cArqTop)

	If Len(aTxtLog) > 0
		//aColunas := {"  Linha  ","  Codigo  "," Status ","     Observacao     "}
		
		cLogProc	:= "LOG_"+aTabExclui[nRadMenu1][1]+"-"+DTOS(Date())+StrTran(Time(),":")+".XML"
		cTxtProc	:= "Carga "+aTabExclui[nRadMenu1][1] +" - Arquivo " + Subs(cArq,Rat("\",cArq)+1 )
		
		//If !Empty(cLinDet)
		//	MemoWrite(cArqPen,cLinCab+CRLF+cLinDet)
		//EndIf
		
		//U_zGeraExc(aColunas,aTxtLog,cLogProc,cLogDir,IIf(!Empty( cPatLoc ) .And. ":\" $ cPatLoc , cPatLoc , "" ),cTxtProc)
		
		xWorkSheet	:= {"Resumo",cTxtProc} 
		
		xTable		:= {"Resumo","Log"}
		
		aColunas := {{"Etapa","Descrição","Inicio","Final","Intervalo"},{"  Linha  ","  Codigo  "," Status ","     Observacao     "}}
		
		aTxtLog	:= {aTxtProc,aTxtLog}
		
		zGeraExcel(aColunas,aTxtLog,cLogProc,cLogDir,IIf(!Empty(cPatLoc).And.":\"$cPatLoc,cPatLoc,""),xWorkSheet,xTable)

	//	MsgInfo("Fim de Processamento!!")
	//Else
	//	MsgInfo("Não foi gerado log de carga!!"+CRLF+CRLF+"Verifique conteúdo do arquivo processado e logs do sistema.")
	EndIf

	dDataAux	:= Date()
	cHoraAux	:= Time()

	cTxtProc 	+= "##### [CMVIMP01] - Processamento Terminado - Inicio: " + cHoraIni + " / Fim: " + cHoraFim + IIF(dDataIni==dDataFim," / Intervalo: "+ElapTime(cHoraIni,cHoraFim),"") + " #####)"+CRLF
	cTxtProc	+= Replicate("-",80)+CRLF
	aAdd( aTxtProc , { "    " , "Processamento Total" , cHoraIni , cHoraFim , IIF(dDataAux==dDataFim, ElapTime(cHoraIni,cHoraFim) ," " ) } )
/*
	aColunas := {"Etapa","Descrição","Inicio","Final","Intervalo"}
	//aTxtProc	:= {{"0001","Linha 0001"},{"0002","Linha 0002"}}
	cLogProc	:= "PROC_"+aTabExclui[nRadMenu1][1]+"-"+DTOS(Date())+StrTran(Time(),":")+".XML"
	//cTxtProc	:= "CMVIMP01 Importacao "+aTabExclui[nRadMenu1][1] +" - " + DtoC( dDataIni ) + " - " + cHoraIni
	U_zGeraExc(aColunas,aTxtProc,cLogProc,cLogDir,IIf(!Empty( cPatLoc ) .And. ":\" $ cPatLoc , cPatLoc , "" ),cTxtProc)
*/
	If Len(aTxtLog) > 0
		MsgInfo("Fim de Processamento!!")

		If file(cArqPen)
			If !CpyS2T(cArqPen,cPatLoc)
				MsgStop("O arquivo " +cArqPen + " não foi copiado para pasta local!","ATENÇÃO")
			Else
			EndIf
		//Else
		//	MsgStop("O arquivo " +cArqPen + " não foi localizado no servidor!","ATENÇÃO")
		EndIf

	Else
		MsgInfo("Não foi gerado log de carga!!"+CRLF+CRLF+"Verifique conteúdo do arquivo processado e logs do sistema.")
	EndIf


/*
	If !Empty( aArqLog ) // .And. nRadMenu1 <> 1
		If !Empty( cPatLoc ) .And. ":\" $ cPatLoc

			For nX := 1 to Len(aArqLog)
				CpyS2T(cLogDir+aArqLog[nX,1],cPatLoc)
			Next nX

			MsgAlert("LOG(S) de erros (IMP_"+aTabExclui[nRadMenu1][1]+"-*.LOG) copiado(s) para "+cPatLoc)
		Else
			MsgAlert("LOG(S) de erros (IMP_"+aTabExclui[nRadMenu1][1]+"-*.LOG) gerado(s) em "+cLogDir)
		EndIf
	Else //If nRadMenu1 <> 1
		MsgInfo("Arquivo importado com sucesso!!")
	//Else
	//	MsgInfo("Fim de Processamento!!")
	Endif
*/




Return

/*
========================================================
StartJob Padrão
========================================================
*/
User function xExec(nOpc,xI,aAutoCab,aAutoDet,cEmpresa,aFil,cLogFile,dData,lGrid,cArqTop)

	Local cLogWrite := ""
	Local nX := 0
	//Local aLog := {}
	Local bError	:= ErrorBlock( { |oError| MyError( oError ) } )
	//Local cLogDir	:= "\CMV\IMP\"
	Local cCodigo, cStatus, cAliasTRB

	Private cError

	DEFAULT lGrid := .F.

	BEGIN SEQUENCE

		FWMonitorMsg("[CMVIMP01-"+AllTrim(StrZero(nOpc,2))+"][Thread: "+StrZero(ThreadId(),6)+"]" )

		//Prepare environment EMPRESA cEmpresa FILIAL cFil

		/*
		ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
		Â³ Preparação do Ambiente.                                                                                  |
		Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
		*/
		// Seta job para nao consumir licenças
		If !lGrid
			If nOpc == 17 .OR. nOpc == 22
				// RpcSetType(3)
				IF(ValType(aFil)=="A")
					Prepare environment EMPRESA cEmpresa FILIAL aFil[1] MODULO "COM"
				Else
					Prepare environment EMPRESA cEmpresa FILIAL aFil MODULO "COM"
				EndIf
			Else /*If nOpc <> 10 .And. nOpc <> 14*/
				// RpcSetType(3)

				RpcSetEnv( cEmpresa , IIF(ValType(aFil)=="A",aFil[1],aFil))

			//Else

			//	RpcSetEnv( cEmpresa , IIF(ValType(aFil)=="A",aFil[1],aFil),"t1004690","123")

			EndIf
		EndIf
		
		If ValType( dData ) == "D"
			dDataBase	:= dData
		EndIf

		//ConOut("Select('SX6') "+Str(Select('SX6')))
		
		dbUseArea( .T. , "TOPCONN" , cArqTop , "TMPLOG" , .T. , .F. )
		//ConOut("cArqTop "+cArqTop)
		//ConOut("Select('TMPLOG') "+Str(Select('TMPLOG')))
		dbSetIndex( cArqTop )
		//ConOut("Alias "+Alias())
		//ConOut("IndexKey "+IndexKey())
		dbSelectArea( "TMPLOG" )
		//ConOut("Alias "+Alias())

		For nx	:= 1 to Len(aAutoCab)

			cFilAnt	:= aFil[nX]

			cErro	:= ""
			cErro	:= u_myExec(nOpc,aAutoCab[nX],IIF(Len(aAutoDet)>0,aAutoDet[nX],aAutoDet))

            IF !Empty(cErro)

				cLogWrite	+= Replicate("-",80)+CRLF
				cLogWrite	+= "Linha do erro no arquivo CSV: "+str(xI[nX])+CRLF+CRLF
				cLogWrite	+= cErro

			EndIf

			If TMPLOG->( dbSeek(StrZero(xI[nX],6)) )
				RecLock("TMPLOG",.F.)
				TMPLOG->STATUS	:= IIF(Empty(cErro),"Sucesso","Erro")
				TMPLOG->ERRO	:= cErro // StrTran(cLogTop," --------------------------------------------------------------------------------","")
				TMPLOG->( msUnlock() )
/*
				If nOpc == 10 // SC7 - Pedido de Compras
					cCodigo := TMPLOG->CODIGO 
					cStatus := TMPLOG->STATUS
					
					cAliasTRB := "CMVIMP01"

					BeginSql Alias cAliasTRB
				
						SELECT R_E_C_N_O_ TRB_RECNO
				
						FROM %Exp:cArqTop%
				
						WHERE  CODIGO = %Exp:cCodigo%
							AND STATUS = ' '
				
					EndSql
				
					While !(cAliasTRB)->( eof() )
						TMPLOG->( dbGoTo( (cAliasTRB)->TRB_RECNO ) )
						RecLock("TMPLOG",.F.)
						TMPLOG->STATUS	:= IIF(Empty(cErro),"Sucesso","Erro")
						TMPLOG->ERRO	:= cErro // StrTran(cLogTop," --------------------------------------------------------------------------------","")
						TMPLOG->( msUnlock() )
						(cAliasTRB)->( dbSkip() )
					EndDo
					
					dbSelectArea(cAliasTRB)
					(cAliasTRB)->( dbCloseArea() )
				EndIf
*/
			Else
				ConOut("TMPLOG->( dbSeek(StrZero(xI[nX],6)) ) " + StrZero(xI[nX],6))
			EndIf


		Next nX

		If !Empty( cLogWrite )
			U_zGravaLog(cLogFile,cLogWrite)
		EndIf

		/*
		ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
		Â³ Finalização do Ambiente.                                                                                 |
		Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
		*/
		If !lGrid
			RpcClearEnv()
		EndIf

		RECOVER
		Conout('##### CMVIMP01 - Erro no Processamento - Verificar Log - ' + dToC(Date()) + ' - ' + time() )
	END SEQUENCE

	ErrorBlock( bError )

	If ValType(cError) == 'C'

		//ConOut("cError"+cError)

		cLogWrite += cError

		U_zGravaLog(cLogFile,cLogWrite)

	EndIf


Return cLogWrite

/*
========================================================
StartJob ExecAuto
========================================================
*/
User function MyExec(nOpc,aExecAuto,aExecAutod)

	Local cErro := ""
	Local aAux	:= {}
	Local cCod	:= cItem	:= ""
	Local cBkpFunName	:= ""
	
	Local nBkpModulo	:= 0
	Local nCont	:= 0
	Local nI	:= 0

	//Local cErro		:= ""
	Local aErro
	local cLocal, cTes
	local cNatNf

	Local nNumDoc, nSerDoc, nDatFat, nCodFor, nLojFor, nCodPro, nCusMed, nCodCha
	Local cNumDoc, cSerDoc, cDatFat, cCodFor, cLojFor, cCodPro, cCusMed, cCodCha
	Local nRecSD1


	Private lMsHelpAuto     := .T.
	Private lMsErroAuto		:= .F.
	Private lAutoErrNoFile  := .T. // Precisa estar como .T. para GetAutoGRLog() retornar o array com erros

	If nOpc == 1
		//cErro := ImportMVC( "MATA010","SB1","SB1MASTER",aExecAuto )  // SB1 com MVC
		
		//M010BrwAuto(3,aExecAuto,"SB1")
		
		dbSelectArea("NNR")

		cCod	:=	aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "B1_COD"})][2]
		
		MSExecAuto({|x,y| MATA010(x,y)},aExecAuto,3) // SB1 Produto

		If lMsErroAuto
			If SB1->( dbSeek( xFilial("SB1")+cCod ) )
				ConOut("cCod "+cCod+" lMsErroAuto	:= .F.")
				lMsErroAuto	:= .F.
			EndIf
		EndIf

	ElseIf nOpc == 2

		cCod	:=	aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "G1_COD"})][2]

		MSExecAuto({|x,y,z| MATA200(x,y,z)},aExecAuto,aExecAutod,3) // SG1 Estrutura de Produto

		If !lMsErroAuto
			If !SG1->( dbSeek( xFilial("SG1")+cCod ) )
				ConOut("cCod "+cCod+" lMsErroAuto	:= .T.")
				lMsErroAuto	:= .T.
			EndIf
		EndIf

	ElseIf nOpc == 3
		cCod	:=	aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "A1_COD"})][2]
		cLoja	:=	aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "A1_LOJA"})][2]
		
		MSExecAuto({|x,y| MATA030(x,y)},aExecAuto,3) // SA1 Cliente

		If lMsErroAuto
			ConOut(cCod+cLoja)
			If SA1->( dbSeek( xFilial("SA1")+cCod+cLoja ) )
				lMsErroAuto	:= .F.
				cErro		:= ""
			EndIf
		EndIf

	ElseIf nOpc == 4
		cCod	:=	aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "A2_COD"})][2]
		cLoja	:=	aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "A2_LOJA"})][2]

		MSExecAuto({|x,y| MATA020(x,y)},aExecAuto,3) // SA2 Fornecedores
		If lMsErroAuto
			If SA2->( dbSeek( xFilial("SA2")+cCod+cLoja ) )
				lMsErroAuto	:= .F.
			EndIf
		EndIf
	ElseIf nOpc == 5
		MSExecAuto({|x,y| MATA040(x,y)},aExecAuto,3) // SA3 Representantes/Vendedores
	ElseIf nOpc == 6
		MSExecAuto({|x,y| OMSA060(x,y)},aExecAuto,3) // DA3 Veículos
	ElseIf nOpc == 7
		MSExecAuto({|x,y| MATA050(x,y)},aExecAuto,3) // SA4 Transportadoras
	ElseIf nOpc == 8
		cCod	:=	aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "N1_CBASE"})][2]
		cItem	:=	aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "N1_ITEM"})][2]
		/*
		While !FreeForUse("SN1",cCod) .And. nCont <= 20
			nCont++
			ConOut("FreeForUse "+cCod+"/"+cItem)
			Sleep(1000)
		EndDo
		*/
		aParamATF	:= {}
		aAdd( aParamATF , {"MV_PAR01", 2 } ) // Mostra Lanc CTB	- 2 = Não
		aAdd( aParamATF , {"MV_PAR02", 2 } ) // Repete Chapa	- 2 = Não
		aAdd( aParamATF , {"MV_PAR03", 2 } ) // Copiar Valores	- 2 = Sem Acumulados
		aAdd( aParamATF , {"MV_PAR04", 2 } ) // Exibe Painel de Detalhes	- 2 = Não
		aAdd( aParamATF , {"MV_PAR05", 2 } ) // Contabilizar Online			- 2 = Não
		aAdd( aParamATF , {"MV_PAR06", 2 } ) // Aglutina Lançamentos		- 2 = Não
		
		MSExecAuto({|x,y,z| ATFA012(x,y,z)},aExecAuto,aExecAutod,3,aParamATF) // SN1/SN3 Bens Ativo Fixo CABECALHO/ITENS
		//MSExecAuto({|x,y,z| U_ATFZ012(x,y,z)},aExecAuto,aExecAutod,3) // SN1/SN3 Bens Ativo Fixo CABECALHO/ITENS
	ElseIf nOpc == 9

		// dDataBase := CTOD("31/03/2017")

		cCodPro	:=	aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "D3_COD"})][2]
		nQtdPro	:=	aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "D3_QUANT"})][2]
		cCodLoc	:=	IIF(aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="D3_LOCAL"})>0,aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="D3_LOCAL"})][2],"")
		cCodEnd	:=	IIF(aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="D3_LOCALIZ"})>0,aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="D3_LOCALIZ"})][2],"")
		cCodDoc	:=	IIF(aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="D3_DOC"})>0,aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="D3_DOC"})][2],"")

		If Empty( cCodDoc )
			aAdd( aExecAuto , { "D3_DOC" , DTOS( dDataBase ) + "1" , NIL } )
		EndIf

		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial("SB1")+cCodPro ) )
		if Empty( cCodLoc )
			cCodLoc := SB1->B1_LOCPAD
		EndIf
		SB2->( dbSetOrder(1) )
		If !SB2->( dbSeek( xFilial("SB2")+SB1->B1_COD+cCodLoc ) )
			CriaSB2(SB1->B1_COD,cCodLoc)
		EndIf


		MSExecAuto({|x,y| MATA240(x,y)},aExecAuto,3) // SD3 Saldo de estoque

		If !lMsErroAuto .And. !Empty( cCodEnd ) .And. SB1->B1_LOCALIZ == "S"


			__aCabec := {}
			//aAdd( __aCabec , {"DA_FILIAL"	, "010001"			, Nil}	)
			aAdd( __aCabec , {"DA_PRODUTO"	, SD3->D3_COD		, Nil}	)
			aAdd( __aCabec , {"DA_LOCAL"	, SD3->D3_LOCAL		, Nil}	)
			aAdd( __aCabec , {"DA_NUMSEQ"	, SD3->D3_NUMSEQ			, Nil}	)
			aAdd( __aCabec , {"DA_DOC"		, SD3->D3_DOC		, Nil}	)
			aAdd( __aCabec , {"DA_ORIGEM"	, "SD3"				, Nil}	)
			//aAdd( __aCabec , {"INDEX"		,1					, NIL}	)

			__aItens :=	{}

			//DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_LOTECTL+DB_NUMLOTE+DB_NUMSERI+DB_LOCALIZ+DB_NUMSEQ
			aAdd( __aItens , {"DB_ITEM"		, "0001"				, Nil}	)
			aAdd( __aItens , {"DB_PRODUTO"	, SD3->D3_COD			, Nil}	)
			aAdd( __aItens , {"DB_LOCAL"	, SD3->D3_LOCAL			, Nil}	)
			aAdd( __aItens , {"DB_LOTECTL"	, SD3->D3_LOTECTL		, Nil}	)
			aAdd( __aItens , {"DB_NUMLOTE"	, SD3->D3_NUMLOTE		, Nil}	)
			aAdd( __aItens , {"DB_NUMSERI"	, SD3->D3_NUMSERI		, Nil}	)
			aAdd( __aItens , {"DB_LOCALIZ"	, cCodEnd				, Nil}	)
			aAdd( __aItens , {"DB_NUMSEQ"	, SD3->D3_NUMSEQ		, Nil}	)
			aAdd( __aItens , {"DB_DATA"		, SD3->D3_EMISSAO		, Nil}	)
			aAdd( __aItens , {"DB_QUANT"	, SD3->D3_QUANT			, Nil}	)

			__aItens	:= { __aItens }

			MsExecAuto({|x,y,z| Mata265(x,y,z)},__aCabec,__aItens,3)

		EndIf

		//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo

	ElseIf nOpc == 10
		SetFunName("MATA121")
		MSExecAuto({|x,y,z| MATA121(x,y,z)},aExecAuto,aExecAutod,3) // SC7 Pedido de Compra
	ElseIf nOpc == 11
		MSExecAuto({|x,y,z| MATA410(x,y,z)},aExecAuto,aExecAutod,3) // SC5/SC6 Pedidos de Venda CABECALHO/ITENS
	ElseIf nOpc == 12
		SetFunName("FINA050")
		If aExecAuto[ascan(aExecAuto,{|x| x[1]='E2_TIPO'}),2] $ "PA "
			aAdd(aExecAuto, {"AUTBANCO","996",nil})
			aAdd(aExecAuto, {"AUTAGENCIA","00000",nil})
			aAdd(aExecAuto, {"AUTCONTA","0000000001",nil})
		EndIf
		aAux	:= {PADR(aExecAuto[ascan(aExecAuto,{|x| x[1]='E2_PREFIXO'}),2],TAMSX3('E2_PREFIXO')[1]	),;
					PADR(aExecAuto[ascan(aExecAuto,{|x| x[1]='E2_NUM'}),	2],TAMSX3('E2_NUM')[1]		),;
					PADR(aExecAuto[ascan(aExecAuto,{|x| x[1]='E2_PARCELA'}),2],TAMSX3('E2_PARCELA')[1]	),;
					PADR(aExecAuto[ascan(aExecAuto,{|x| x[1]='E2_TIPO'}),	2],TAMSX3('E2_TIPO')[1]		),;
					PADR(aExecAuto[ascan(aExecAuto,{|x| x[1]='E2_FORNECE'}),2],TAMSX3('E2_FORNECE')[1]	),;
					PADR(aExecAuto[ascan(aExecAuto,{|x| x[1]='E2_LOJA'}),	2],TAMSX3('E2_LOJA')[1]		)	}
		DbSelectArea("SE2")
		DbSetOrder(1)
		//If !DbSeek(xFilial("SE2")+aAux[1]+aAux[2]+aAux[3]+aAux[4]+aAux[5]+aAux[6])
			pergunte("FINA050",.F.)
			//MSExecAuto({|y,z| FINA050(y,z)},aExecAuto,3)   // SE2 Contas a Pagar em aberto MESTRE
			
			public lPaMovBco := .F.
			
			MSExecAuto({|y,z| FINA050(y,z)},aExecAuto,3,/*nOpcAuto*/,/*bExecuta*/,/*aDadosBco*/,/*lExibeLanc*/,/*lOnline*/,/*aDadosCTB*/,/*aTitPrv*/,/*lMsBlQl*/,.F.)   // SE2 Contas a Pagar em aberto MESTRE
			//aRotAuto,nOpcion,nOpcAuto,bExecuta,aDadosBco,lExibeLanc,lOnline,aDadosCTB,aTitPrv,lMsBlQl,lPaMovBco
			
		//EndIf
	ElseIf nOpc == 13
		MSExecAuto({|x,y| FINA040(x,y)},aExecAuto,3)   // SE1 Contas a Receber em aberto MESTRE
	ElseIf nOpc == 14

		cCodPro	:=	aExecAutod[1][aScan(aExecAutod[1],{|aAux|alltrim(aAux[1]) == "C1_PRODUTO"})][2]
		cCtoCus	:=	IIF(aScan(aExecAutod[1],{|aAux|alltrim(aAux[1])=="C1_CC"})>0,aExecAutod[1][aScan(aExecAutod[1],{|aAux|alltrim(aAux[1])=="C1_CC"})][2],"")
		cGrpPro	:=	IIF(aScan(aExecAutod[1],{|aAux|alltrim(aAux[1])=="C1_ZGRPPRD"})>0,aExecAutod[1][aScan(aExecAutod[1],{|aAux|alltrim(aAux[1])=="C1_ZGRPPRD"})][2],"")

		if Empty( cGrpPro )
			SB1->( dbSetOrder(1) )
			SB1->( dbSeek( xFilial("SB1")+cCodPro ) )
			cGrpPro := SB1->B1_GRUPO
		EndIf

		xCriaTab()

		SetFunName("MATA110")
		MSExecAuto({|x,y,z| MATA110(x,y,z)},aExecAuto,aExecAutod,3) // SC1 Solicitação de Compra
	ElseIf nOpc == 15
		cErro := ImportMVC( "CMVFAT01","SZ9","FAT01MASTER",aExecAuto )  // SZ9 Endereço de Entrega
	ElseIf nOpc == 16
		//MSExecAuto({|x,y| OMSA040(x,y)},aExecAuto,3)   // DA4 Motoristas
		MSExecAuto({|x,y| Mata180(x,y)},aExecAuto,3)   // SB5 Complemento Produto 
	ElseIf nOpc == 17
		dbSelectArea("SC3")
		dbSetOrder(1)
		MSExecAuto( {|x,y,z| mata125(x,y,z)},aExecAuto,aExecAutod,3)
		//		MSExecAuto({|x,y,z| mata125(x,y,z)},aExecAuto,aExecAutod,3)   // SC3 Acordo Comercial
	ElseIf nOpc == 18
		//		cErro := ImportMVC( "VEIA060","VRJ" ,"MODEL_VRJ",aExecAuto,"VRK"  ,"MODEL_VRK",aExecAutod )  // SZ9 Endereço de Entrega
		//		cErro := ImportMVC( "CMVFAT01","SZ9","FAT01MASTER",aExecAuto )  // VRJ/VRK Pedido de montadora -> FUNCIONA NORMAL

		If ascan(aExecAuto,{|x| x[1]=='VV1_CODORI'}) == 0
			aAdd( aExecAuto , { 'VV1_CODORI' , '0'       } )
		EndIf
		If ascan(aExecAuto,{|x| x[1]=='VV1_ESTVEI'}) == 0
			aAdd( aExecAuto , { 'VV1_ESTVEI' , '0'       } )
		EndIf
		If ascan(aExecAuto,{|x| x[1]=='VV1_TIPVEI'}) == 0
			aAdd( aExecAuto , { 'VV1_TIPVEI' , '1'		 } )
		EndIf
		If ascan(aExecAuto,{|x| x[1]=='VV1_LOCPAD'}) == 0
			aAdd( aExecAuto , { 'VV1_LOCPAD' , 'VN'      } )
		EndIf
		If ascan(aExecAuto,{|x| x[1]=='VV1_SITVEI'}) == 0
			aAdd( aExecAuto , { 'VV1_SITVEI' , '0'       } )
		EndIf
		
		cErro := ImportMVC( "VEIA070","VV1","MODEL_VV1",aExecAuto )  //Veículos ,"MODEL_VV1",aExecAutod
        //                   cModel,cAlias,cModelCab,aCpoCab,cModelDet,aCpoDet
		//cErro := ImptVeic(aDados)  //Cadastro de Veículos
		If Empty( cErro )

			//"IMOBILIZADO;NUMERO_DI;DT_DI;NOTA_FISCAL;SERIE_NOTA;DATA_FATURAMENTO;FORNECEDOR;LOJA;CUSTO_MEDIO;VV1_PRODUTO"
			nNumDoc	:=	aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "NOTA_FISCAL"})
			nSerDoc	:=	aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "SERIE_NOTA"})
			nDatFat	:=	aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "DATA_FATURAMENTO"})
			nCodFor	:=	aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "FORNECEDOR"})
			nLojFor	:=	aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "LOJA"})
			nCodPro	:=	aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "VV1_PRODUTO"})
			nCusMed	:=	aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "CUSTO_MEDIO"})
			nCodCha	:=	aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "VV1_CHASSI"})

			cNumDoc	:=	Alltrim(aExecAuto[nNumDoc,2])
			cSerDoc	:=	Alltrim(aExecAuto[nSerDoc,2])
			cDatFat	:=	Alltrim(aExecAuto[nDatFat,2])
			cCodFor	:=	Alltrim(aExecAuto[nCodFor,2])
			cLojFor	:=	Alltrim(aExecAuto[nLojFor,2])
			cCodPro	:=	Alltrim(aExecAuto[nCodPro,2])
			cCusMed	:=	Alltrim(aExecAuto[nCusMed,2])
			cCodCha	:=	Alltrim(aExecAuto[nCodCha,2])

			cNumDoc	:=	Stuff( Space( TamSX3("F1_DOC")[1] )		, 1 , Len(cNumDoc) , cNumDoc )
			cSerDoc	:=	Stuff( Space( TamSX3("F1_SERIE")[1] )	, 1 , Len(cSerDoc) , cSerDoc )
			//cDatFat	:=	
			cCodFor	:=	Stuff( Space( TamSX3("F1_FORNECE")[1] ) , 1 , Len(cCodFor) , cCodFor )
			cLojFor	:=	Stuff( Space( TamSX3("F1_LOJA")[1] )	, 1 , Len(cLojFor) , cLojFor )
			cCodPro	:=	Stuff( Space( TamSX3("D1_COD")[1] )		, 1 , Len(cCodPro) , cCodPro )
			//cCusMed	:=	
			cCodCha	:=	Stuff( Space( TamSX3("D1_CHASSI")[1] )	, 1 , Len(cCodCha) , cCodCha )

			// -- Cria array com o cabeçalho da Nota Fiscal de Entrada (SF1)
			aCab := {}
			aadd( aCab, { "F1_TIPO"	   , 'N'			, nil } )
			aadd( aCab, { "F1_FORMUL"  , 'N'			, nil } )
			aadd( aCab, { "F1_DOC"	   , cNumDoc		, nil } )
			aadd( aCab, { "F1_SERIE"   , cSerDoc		, nil } )
			aadd( aCab, { "F1_EMISSAO" , CTOD(cDatFat)	, nil } ) // Tratar Emissao
			aadd( aCab, { "F1_FORNECE" , cCodFor		, nil } )
			aadd( aCab, { "F1_LOJA"	   , cLojFor		, nil } )
			aadd( aCab, { "F1_ESPECIE" , 'NF'			, nil } )
			aadd( aCab, { "F1_DESCONT" , 0				, nil } )
			aadd( aCab, { "F1_SEGURO"  , 0				, nil } )
			aadd( aCab, { "F1_DESPESA" , 0				, nil } )
			aadd( aCab, { "F1_COND"	   , '001'			, nil } )
			aadd( aCab, { "F1_STATUS"  , "A"			, nil } )
		

			cTes	:= SuperGetMv( "CMV_VE1TES"	, , "200"	)
			
			aTmp   := {}
			aItens := {}
			// -- Cria array com os Itens da NFE (SD1)
			aadd( aTmp, { "D1_COD"	  ,	cCodPro		, nil } )
			aadd( aTmp, { "D1_QUANT"  ,	1			, nil } )
			aadd( aTmp, { "D1_VUNIT"  ,	VAL(cCusMed), nil } )
			aadd( aTmp, { "D1_TOTAL"  ,	VAL(cCusMed), nil } )
			aadd( aTmp, { "D1_LOCAL"  ,	'VN'		, nil } )
			aadd( aTmp, { "D1_TES"	  ,	cTes		, nil } )   //TES da NF de Entrada para carga de Veículos
			aadd( aTmp, { "D1_CHASSI" ,	cCodCha		, nil } )
			aadd( aTmp, { "AUTDELETA" ,	"N"			, nil } )
		
			aadd( aItens, aClone( aTmp ) )

			MSExecAuto({|x,y| MATA103(x,y)}, aCab, aItens, 3)
			
			If !lMsErroAuto
				// Endereçar
				cLocal	:= allTrim( superGetMv( "CMV_VE1LOC"	, , "VEICULO NOVO"		) )
				
				nRecSD1	:= 0
				If SD1->( D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD ) <> xFilial("SD1")+cNumDoc+CSerDoc+cCodFor+cLojFor+cCodPro
					SD1->( dbSetOrder(1) ) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
					If !SD1->( dbSeek( xFilial("SD1")+cNumDoc+CSerDoc+cCodFor+cLojFor+cCodPro ) )
						cErro := 'Item de NFE não localizado. Chave xFilial("SD1")+cNumDoc+CSerDoc+cCodFor+cLojFor+cCodPro: '+xFilial("SD1")+cNumDoc+CSerDoc+cCodFor+cLojFor+cCodPro 
					Else
						nRecSD1	:= SD1->( Recno() )
					EndIf
				Else
					nRecSD1	:= SD1->( Recno() )
				EndIf
				
				If Empty( cErro )

					aCabSDA := {}
					aAdd( aCabSDA, {"DA_FILIAL" 	, SD1->D1_FILIAL	, Nil} )
					aAdd( aCabSDA, {"DA_PRODUTO" 	, SD1->D1_COD		, Nil} )
					aAdd( aCabSDA, {"DA_LOCAL"		, SD1->D1_LOCAL		, Nil} )
					aAdd( aCabSDA, {"DA_NUMSEQ" 	, SD1->D1_NUMSEQ 	, Nil} )
					aAdd( aCabSDA, {"DA_DOC"		, SD1->D1_DOC		, Nil}	)
					aAdd( aCabSDA, {"INDEX"			, 1					, NIL}	)
					
					aItSDB := {}
					//DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_LOTECTL+DB_NUMLOTE+DB_NUMSERI+DB_LOCALIZ+DB_NUMSEQ
					aAdd( aItSDB, {"DB_ITEM" 	, '0001' 				, Nil}	)
					aAdd( aItSDB, {"DB_ESTORNO"	, " " 					, Nil}	)
					aAdd( aItSDB, {"DB_PRODUTO"	, SD1->D1_COD			, Nil}	)
					aAdd( aItSDB, {"DB_LOCAL"	, SD1->D1_LOCAL			, Nil}	)
					aAdd( aItSDB, {"DB_LOCALIZ"	, cLocal				, Nil}	)
					aAdd( aItSDB, {"DB_QUANT" 	, SD1->D1_QUANT 		, Nil}	)
					aAdd( aItSDB, {"DB_DATA" 	, dDataBase 			, Nil}	)
					aAdd( aItSDB, {"DB_LOTECTL"	, SD1->D1_LOTECTL		, Nil}	)
					aAdd( aItSDB, {"DB_NUMLOTE"	, SD1->D1_NUMLOTE		, Nil}	)
					aAdd( aItSDB, {"DB_NUMSERI" , SD1->D1_CHASSI	 	, Nil}	)
					
					aItensSDB := {}
					aadd( aItensSDB, aitSDB )
					MATA265( aCabSDA, aItensSDB, 3)
					
					If !lMsErroAuto
						cNatNf	  := allTrim( superGetMv( "CMV_VE1NAT"	, , "2104"		) )	// Natureza para Nota fiscal SIGAVEI
						
						If SF1->( F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA ) <> xFilial("SF1")+cNumDoc+CSerDoc+cCodFor+cLojFor
							SF1->( dbSetOrder(1) ) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
							If !SF1->( dbSeek( xFilial("SF1")+cNumDoc+CSerDoc+cCodFor+cLojFor ) )
								cErro := 'NFE não localizada. Chave xFilial("SF1")+cNumDoc+CSerDoc+cCodFor+cLojFor: '+xFilial("SF1")+cNumDoc+CSerDoc+cCodFor+cLojFor 
							EndIf
						EndIf
						
						ConOut("nRecSD1 "+Str(nRecSD1))
						ConOut("SD1->( Recno() ) "+Str(SD1->( Recno() )))
						//If nRecSD1	<> SD1->( Recno() )
						//	SD1->( dgGoTo(nRecSD1) )
						//EndIf

						If SD1->( D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD ) <> xFilial("SD1")+cNumDoc+CSerDoc+cCodFor+cLojFor+cCodPro
							SD1->( dbSetOrder(1) ) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
							SD1->( dbSeek( xFilial("SD1")+cNumDoc+CSerDoc+cCodFor+cLojFor+cCodPro ) )
						EndIf

						If Empty( cErro )
							aCab	:= {}
							aAdd(aCab,{"VVF_CLIFOR"  ,"F"          				,Nil})
							aAdd(aCab,{"VVF_FORPRO"  ,"0"          				,Nil})
							aAdd(aCab,{"VVF_OPEMOV"  ,"0"          				,Nil})
							aAdd(aCab,{"VVF_DATMOV"  ,SF1->F1_DTDIGIT 	        ,Nil})
							aAdd(aCab,{"VVF_DATEMI"  ,SF1->F1_EMISSAO 	        ,Nil})
							aAdd(aCab,{"VVF_CODFOR"  ,SF1->F1_FORNECE   		,Nil})
							aAdd(aCab,{"VVF_LOJA"    ,SF1->F1_LOJA       		,Nil})
							aAdd(aCab,{"VVF_FORPAG"  ,SF1->F1_COND      		,Nil})
							aAdd(aCab,{"VVF_ESPECI"  ,SF1->F1_ESPECIE   		,Nil})
							aAdd(aCab,{"VVF_NUMNFI"  ,SF1->F1_DOC        		,Nil})
							aAdd(aCab,{"VVF_SERNFI"  ,SF1->F1_SERIE      		,Nil})
							aAdd(aCab,{"VVF_NATURE"	 ,"1101"					,Nil})
							aAdd(aCab,{"VVF_CHVNFE"  ,SF1->F1_CHVNFE    		,Nil})
							aAdd(aCab,{"VVF_RECSF1"	 ,SF1->(Recno())    		,Nil})					
							
							// ConOut( VarInfo("aCab",aCab) )
							
							axItem	:= {}
							aItens	:= {}
							aAdd(axItem,{"VVG_FILIAL"  , SD1->D1_FILIAL   , nil})
							aAdd(axItem,{"VVG_CHASSI"  , SD1->D1_CHASSI   , nil})
							aAdd(axItem,{"VVG_CODTES"  , SD1->D1_TES      , nil})
							aAdd(axItem,{"VVG_ESTVEI"  , "0"			  , nil})
							aAdd(axItem,{"VVG_LOCPAD"  , SD1->D1_LOCAL    , nil})
							aAdd(axItem,{"VVG_SITTRIB" , SD1->D1_CLASFIS  , nil})
							aAdd(axItem,{"VVG_VALUNI"  , SD1->D1_VUNIT    , nil})
							aAdd(axItem,{"VVG_VBAIPI"  , SD1->D1_BASEIPI  , nil})
							aAdd(axItem,{"VVG_VBAICM"  , SD1->D1_BASEICM  , nil})
							aAdd(axItem,{"VVG_ICMCOM"  , SD1->D1_VALICM   , nil})
							aAdd(axItem,{"VVG_VCNVEI"  , SD1->D1_TOTAL    , nil})
							
							//ConOut( "SD1->D1_CHASSI "+SD1->D1_CHASSI )
							//ConOut( SD1->( Recno() ) )
							//ConOut( VarInfo("axItem",axItem) )
									
							AADD(aItens,axItem)
									
							cBkpFunName := FunName()
							nBkpModulo  := nModulo
							SetFunName('VEIXA001')
							nModulo := 11		
								
							aCols := {}
									
							MSExecAuto(;
								{ |a,b,c,d,e,f,g,h,i| ;
								VEIXX000(a       ,b         ,c      ,d   ,e      ,f       ,g         ,h          ,i      ) },;
							     aCab,aItens,{}     ,3   ,"0"    ,        ,.f.       ,           ,"3"    )
							SetFunName(cBkpFunName)
							nModulo := nBkpModulo
						EndIf
					EndIf
				EndIf
			
			EndIf

		EndIf
	ElseIf nOpc == 19
		//		cErro := ImportMVC( "VEIA060","VRJ" ,"MODEL_VRJ",aExecAuto,"VRK"  ,"MODEL_VRK",aExecAutod )  // SZ9 Endereço de Entrega
		//		cErro := ImportMVC( "CMVFAT01","SZ9","FAT01MASTER",aExecAuto )  // VRJ/VRK Pedido de montadora -> FUNCIONA NORMAL
		cErro := ImportMVC( "VEIA060","VRJ","MODEL_VRJ",aExecAuto,"MODEL_VRK",aExecAutod )  // VRJ/VRK Pedido de montadora -> FUNCIONA NORMAL
	ElseIf nOpc == 20

		cBkpFunName := FunName()
		nBkpModulo  := nModulo
		SetFunName('VEIXA001')
		nModulo := 11		

		aCols := {}

		MSExecAuto(;
			{ |a,b,c,d,e,f,g,h,i| ;
			VEIXX000(a       ,b         ,c      ,d   ,e      ,f       ,g         ,h          ,i      ) },;
			         aExecAuto,aExecAutod,{}     ,3   ,"0"    ,        ,.f.       ,           ,"3"    )
		SetFunName(cBkpFunName)
		nModulo := nBkpModulo

	ElseIf nOpc == 21
		nBkpModulo  := nModulo
		cBkpFunName := FunName()
		SetFunName('EICPO400')

		nDatPO	:=	aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "W2_PO_DT"})

		dDatPO	:=	aExecAuto[nDatPO,2]
		
		dDataBase	:= dDatPO
/*
		If aScan(aExecAuto, {|x|x[1] == "W2_DT_PAR"}) == 0
			ConOut("aAdd( aExecAuto")
		   aAdd( aExecAuto , { "W2_DT_PAR" , dDataBase , NIL } )
		Endif
*/
		
		nModulo := 17
//Processa({|| PO400SIAUTO() })
		ConOut("MSExecAuto EICPO400 - Inicio: "+Time())
		MSExecAuto({|a,b,c,d| EICPO400(a,b,c,d)},NIL,aExecAuto,aExecAutod,3) // SW2/SW3 Purchase Order
		ConOut("MSExecAuto EICPO400 - Fim: "+Time())
		SetFunName(cBkpFunName)
		nModulo := nBkpModulo
		
		If !lMsErroAuto
			nNumPO	:=	aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "W2_PO_NUM"})
	
			cNumPO	:=	Alltrim(aExecAuto[nNumPO,2])
			cNumPO	:=	Stuff( Space( TamSX3("W2_PO_NUM")[1] )	, 1 , Len(cNumPO) , cNumPO )
	
			nTipImp	:=	aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "W2_XTIPIMP"})
			cTipImp	:=	Alltrim(aExecAuto[nTipImp,2])
			cTipImp	:=	Stuff( Space( TamSX3("W2_XTIPIMP")[1] )	, 1 , Len(cTipImp) , cTipImp )
			nClaImp	:=	aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "W2_XCLAIMP"})
			cClaImp	:=	Alltrim(aExecAuto[nClaImp,2])
			cClaImp	:=	Stuff( Space( TamSX3("W2_XCLAIMP")[1] )	, 1 , Len(cClaImp) , cClaImp )
			
			if Emtpy(SW2->W2_XTIPIMP)
				RecLock("SW2",.F.)
					SW2->W2_XTIPIMP	:= cTipImp
					SW2->W2_XCLAIMP	:= cClaImp
				SW2->( msUnlock() )
			EndIf
		EndIf

	ElseIf nOpc == 22
		//cErro := ImportMVC( "MATA061","SA5","MODEL_SA5",aExecAuto,"MODEL_SA5",aExecAutod )  // MATA061 MVC SA5
		cErro := ImportMVC( "MATA061","SA5","MdFieldSA5",aExecAuto,"SA5","MdGridSA5",aExecAutod )  // MATA061 MVC SA5
	ElseIf nOpc == 23

		// dDataBase := CTOD("31/03/2017")

		cCodPro	:=	aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "B7_COD"})][2]
		nQtdPro	:=	aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "B7_QUANT"})][2]
		cCodLoc	:=	IIF(aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="B7_LOCAL"})>0,aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="B7_LOCAL"})][2],"")
		cCodEnd	:=	IIF(aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="B7_LOCALIZ"})>0,aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="B7_LOCALIZ"})][2],"")
		cCodDoc	:=	IIF(aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="B7_DOC"})>0,aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="B7_DOC"})][2],"")
		cCodLot	:=	IIF(aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="B7_LOTECTL"})>0,aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="B7_LOTECTL"})][2],"")
		dDatVld	:=	IIF(aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="B7_DTVALID"})>0,aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1])=="B7_DTVALID"})][2],"")
		
		If Empty( cCodDoc )
			aAdd( aExecAuto , { "B7_DOC" , DTOS( dDataBase ) + "1" , NIL } )
		EndIf

		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial("SB1")+cCodPro ) )
		if Empty( cCodLoc )
			cCodLoc := SB1->B1_LOCPAD
		EndIf
		SB2->( dbSetOrder(1) )
		If !SB2->( dbSeek( xFilial("SB2")+SB1->B1_COD+cCodLoc ) )
			CriaSB2(SB1->B1_COD,cCodLoc)
		EndIf
		If SB1->B1_RASTRO == "L"
			// B8_FILIAL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)+B8_LOTECTL+B8_NUMLOTE
			SB8->( dbSetOrder(1) )
			SB8->( dbGoTop() )
			If !SB8->( dbSeek( xFilial("SB8")+SB1->B1_COD+cLocal+DTOS(dValid)+cLote ) )
				RecLock("SB8",.T.)
				SB8->B8_FILIAL	:= xFilial("SB8")
				SB8->B8_PRODUTO	:= SB1->B1_COD
				SB8->B8_LOCAL	:= cCodLoc
				SB8->B8_DATA	:= dDataBase
				SB8->B8_DTVALID	:= dDatVld
				SB8->B8_LOTECTL	:= cCodLot
			EndIf
			SB8->(msUnlock())
		EndIf


		MSExecAuto({|x,y| MATA270(x,y)},aExecAuto,3) // SB7 Inventário

	Endif

	If lMsErroAuto
		cErro	:= ""
		If nOpc == 8
			
			cErro += 	"[Thread: "+StrZero(ThreadId(),6)+"] Codigo/Item: " + ;
						aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "N1_CBASE"})][2] + "/" + ;
						aExecAuto[aScan(aExecAuto,{|aAux|alltrim(aAux[1]) == "N1_ITEM"})][2] +CRLF+CRLF
											
		EndIf

		If Empty(cErro)
			aErro := GetAutoGRLog() // Retorna erro em array
	
			lMVC	:= .F. 
			for nI := 1 to len(aErro)
				If !Empty(aErro[nI])
					cLogWrite	+= aErro[nI] + CRLF
				EndIf
				If nOpc == 2 .Or. nOpc == 23// .Or. nOpc == 21
					cErro	+= aErro[nI] + CRLF
				Else
					cAux := ""
					ConOut(aErro[nI])
					If "--------------------------------------------------------------------------------" $ aErro[nI]
						If !lMVC
							//cAux := StrTran(aErro[nI],"--------------------------------------------------------------------------------","")
							cAux := Subs(aErro[nI],At("Mensagem do erro:",aErro[nI]))
							cAux := Subs(cAux,1,At("]",cAux))
							cErro		+= IIF(!Empty(cErro)," &#10;","") + cAux
							lMVC	:= .T.
						EndIf
					ElseIf "Tabela" $ aErro[nI] .Or. "< -- Invalido" $ aErro[nI]
							cErro	+= IIF(!Empty(cErro)," &#10;","") + aErro[nI]
					ElseIf Empty(cErro)
							cErro	+= IIF(!Empty(cErro)," &#10;","") + aErro[nI]
					EndIf
				EndIf
			next nX

		EndIf
		If Empty(cErro) .And. nOpc == 2
			cErro	:= "Erro MATA200"
			ConOut(cErro)
			ConOut(varinfo('MATA200',aExecAuto))
			ConOut(varinfo('MATA200',aExecAutod))
			cErro	+= varinfo('MATA200 Cab',aExecAuto)
			cErro	+= varinfo('MATA200 Det',aExecAutod)
		EndIf
	EndIf

return cErro



User function zExec( aParExec )
	Local nThrMax	:= GetMv("CMV_IMP01C",,20)			// Número Máximo de Threads

	While U_zNumThread("U_XEXEC") >= nThrMax

		Sleep(1000)

	EndDo
	
	// 26/09/2019 - Desabilitar multi-threasd
	StartJob("U_XEXEC",GEtEnvServer(),.F.,aParExec[7],aParExec[3],aParExec[1],aParExec[2],aParExec[4],aParExec[5],aParExec[6])
	//StartJob("U_XEXEC",GEtEnvServer(),.T.,aParExec[7],aParExec[3],aParExec[1],aParExec[2],aParExec[4],aParExec[5],aParExec[6])

Return

Static Function MyError(oError)

	cError := oError:ERRORSTACK

Return

Static Function xCriaTab()

	Local __aStrut    := { {"CCUSTO","C",TamSX3('C1_CC')[1],0},{"GRUPO","C",TamSX3('B1_GRUPO')[1],0} }
	Local cArqThr     := CriaTrab( __aStrut , .T. )

	If Select('ZCUSTGRADE')>0
		('ZCUSTGRADE')->(dbGoTop())
		RecLock("ZCUSTGRADE",.F.)
		('ZCUSTGRADE')->CCUSTO :=''
		('ZCUSTGRADE')->GRUPO :=''
		('ZCUSTGRADE')->(MsUnlock())
	Else

		// Acessar o arquivo e coloca-lo na lista de arquivos abertos.
		dbUseArea( .T., __LocalDriver, cArqThr, "ZCUSTGRADE" , .T. , .F. )

		RecLock("ZCUSTGRADE",.T.)
		('ZCUSTGRADE')->(MsUnlock())
	EndIf

Return

Static Function ImportMVC( cModel,cAlias,cMaster,aCampos,cAliasD,cDetail,aCamposD )
	Local oModel, oAux, oStruct
	Local nI := 0
	Local nJ := 0
	Local nPos := 0
	Local lRet := .T.
	Local aAux := {}
	Local aC := {}
	Local aH := {}
	Local nItErro := 0
	Local lAux := .T.
	Local cErro := ""

	Default cDetail		:= ""
	Default cAliasD		:= ""
	Default aCamposD	:= {}

	dbSelectArea( cAlias )
	dbSetOrder( 1 )
	If !Empty(cAliasD)
		dbSelectArea( cAliasD )
		dbSetOrder( 1 )
	EndIf
	// Aqui ocorre o instÃ¢nciamento do modelo de dados (Model)
	// Neste exemplo instanciamos o modelo de dados do fonte COMP022_MVC
	// que é a rotina de manutenção de musicas
	oModel := FWLoadModel( cModel )
	// Temos que definir qual a operação deseja: 3 â€“ Inclusão / 4 â€“ Alteração / 5 - Exclusão
	oModel:SetOperation( 3 )
	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	oModel:Activate()
	// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
	oAux := oModel:GetModel( cMaster  )
	// Obtemos a estrutura de dados do cabeçalho
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	If lRet
		For nI := 1 To Len( aCampos )
			// Verifica se os campos passados existem na estrutura do cabeçalho
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCampos[nI][1] ) } ) ) > 0
				// Ã‰ feita a atribuição do dado ao campo do Model do cabeçalho
				If !( lAux := oModel:SetValue( cMaster , aCampos[nI][1],aCampos[nI][2] ) )
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf
	If lRet .and. !Empty(cDetail)
		// Instanciamos apenas a parte do modelo referente aos dados do item
		oAux := oModel:GetModel( cDetail )
		// Obtemos a estrutura de dados do item
		oStruct := oAux:GetStruct()
		aAux := oStruct:GetFields()
		nItErro := 0
		For nI := 1 To Len( aCamposD )
			// Incluímos uma linha nova
			// ATENÇÃO: Os itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
			//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2a. vez
			If nI > 1
				// Incluímos uma nova linha de item
				If ( nItErro := oAux:AddLine() ) <> nI
					// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
					lRet := .F.
					Exit
				EndIf
			EndIf
			For nJ := 1 To Len( aCamposD[nI] )
				// Verifica se os campos passados existem na estrutura de item
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCamposD[nI][nJ][1] ) } ) ) > 0
					If !( lAux := oModel:SetValue( cDetail, aCamposD[nI][nJ][1], aCamposD[nI][nJ][2] ) )
						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRet := .F.
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
	If lRet
		// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
		// neste momento os dados não são gravados, são somente validados.
		If ( lRet := oModel:VldData() )
			// Se os dados foram validados faz-se a gravação efetiva dos
			// dados (commit)
			oModel:CommitData()
		EndIf
	EndIf
	If !lRet
		// Se os dados não foram validados obtemos a descrição do erro para gerar
		// LOG ou mensagem de aviso
		aErro := oModel:GetErrorMessage()
		// A estrutura do vetor com erro é:
		// [1] identificador (ID) do formulário de origem
		// [2] identificador (ID) do campo de origem
		// [3] identificador (ID) do formulário de erro
		// [4] identificador (ID) do campo de erro
		// [5] identificador (ID) do erro
		// [6] mensagem do erro
		// [7] mensagem da solução
		// [8] Valor atribuído
		// [9] Valor anterior
		AutoGrLog( "Id do formulário de origem: " + " [" + AllToChar( aErro[1] ) + ']' )+CRLF 
		AutoGrLog( "Id do campo de origem:      " + " [" + AllToChar( aErro[2] ) + "]" )+CRLF 
		AutoGrLog( "Id do formulário de erro:   " + " [" + AllToChar( aErro[3] ) + "]" )+CRLF 
		AutoGrLog( "Id do campo de erro:        " + " [" + AllToChar( aErro[4] ) + "]" )+CRLF 
		AutoGrLog( "Id do erro:                 " + " [" + AllToChar( aErro[5] ) + "]" )+CRLF 
		AutoGrLog( "Mensagem do erro:           " + " [" + AllToChar( aErro[6] ) + "]" )+CRLF 
		AutoGrLog( "Mensagem da solução:        " + " [" + AllToChar( aErro[7] ) + "]" )+CRLF 
		AutoGrLog( "Valor atribuído:            " + " [" + AllToChar( aErro[8] ) + "]" )+CRLF 
		AutoGrLog( "Valor anterior:             " + " [" + AllToChar( aErro[9] ) + "]" )+CRLF 
		cErro := ( "Id do formulário de origem: " + " [" + AllToChar( aErro[1] ) + "]" )+CRLF
		cErro += ( "Id do campo de origem:      " + " [" + AllToChar( aErro[2] ) + "]" )+CRLF
		cErro += ( "Id do formulário de erro:   " + " [" + AllToChar( aErro[3] ) + "]" )+CRLF
		cErro += ( "Id do campo de erro:        " + " [" + AllToChar( aErro[4] ) + "]" )+CRLF
		cErro += ( "Id do erro:                 " + " [" + AllToChar( aErro[5] ) + "]" )+CRLF
		cErro += ( "Mensagem do erro:           " + " [" + AllToChar( aErro[6] ) + "]" )+CRLF
		cErro += ( "Mensagem da solução:        " + " [" + AllToChar( aErro[7] ) + "]" )+CRLF
		cErro += ( "Valor atribuído:            " + " [" + AllToChar( aErro[8] ) + "]" )+CRLF
		cErro += ( "Valor anterior:             " + " [" + AllToChar( aErro[9] ) + "]" )+CRLF
		If nItErro > 0
			AutoGrLog( "Erro no Item: " + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' ) 
		EndIf
		//MostraErro()
	EndIf
	// Desativamos o Model
	oModel:DeActivate()

Return cErro

//---------------------------------------------------------------------------
/*
Static Function GravaMVC( cModel,cAlias,cModelCab,aCpoCab,cModelDet,aCpoDet )

	Local  nI           := 0
	Local  lRet         := .T.
	
	Private aRotina     := {}
	Private oModel      
	Private lMsErroAuto := .F.

	oModel  := FWLoadModel( cModel )
	aRotina := FWLoadMenuDef( cModel )

	FWMVCRotAuto(	oModel,;        //Model
	cAlias,;                        //Alias
	MODEL_OPERATION_INSERT,;        //Operacao
	{{cModelCab, aCpoCab}, {cModelDet, aCpoDet}})

	If lMsErroAuto
		aErro   := oModel:GetErrorMessage()
        aErrorProc := oModel:GetErrorMessage()
		cErro :=  "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']'+CRLF 
		cErro +=  "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']'+CRLF
		cErro +=  "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']'+CRLF
		cErro +=  "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']'+CRLF
		cErro +=  "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']'+CRLF
		cErro +=  "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']'+CRLF
		cErro +=  "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']'+CRLF
		cErro +=  "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']'+CRLF
		cErro +=  "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']'
		lRet := .F.
	EndIf

	oModel:DeActivate()

Return lRet
*/

User Function zGridS(aParms)
	Local cEmp := aParms[1]
	Local cFil := aParms[2]
	Local nOpc := aParms[3]

	Conout("[GRID] Preparing Environment " + cEmp+cFil )

	RPCSetType(3) //Nao utilizar licenca
	
	If nOpc = 17 .OR. nOpc = 22
		PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO "COM"
	Else
		RpcSetEnv( cEmp , cFil )
	EndIf

	If !(nOpc <> 10)
		//	If !(nOpc <> 10 .And. nOpc <> 14)
		__cUserId	:= Alltrim(GetMv("CMV_USRAUT"))	
	EndIf

	Conout("[GRID] Environment Prepared " + cEmp+cFil )

Return .T.

USER Function ZGRIDE(aParam)
	/*
	Local	nOpc	:=
	Local	xI
	Local	aAutoCab
	Local	aAutoDet
	Local	cEmpresa
	Local	aFil
	Local	cLogFile
	Local	dData
	Local	lGrid
	aThrDat[1][7],aThrDat[1][3],aThrDat[1][1],aThrDat[1][2],aThrDat[1][4],aThrDat[1][5],aThrDat[1][6],dDataBase,lGrid
	*/
	// Conout("[GRID] REQUISITION [aParam] Processing Parameter ["+str(Len(aParam),4)+"]")

	Sleep( 100000 )

	U_XEXEC(aParam[1],aParam[2],aParam[3],aParam[4],aParam[5],aParam[6],aParam[7],aParam[8],aParam[9])

	// Conout("[GRID] REQUISITION ["+str(Len(aParam),4)+"] OK")

Return

User Function zVldCpo(cAlias,cChave,nOrdem,cHelp)
LOCAL xAlias,nSalvReg,cFil,nOldOrder

Default cHelp := STR0020 //"Registro não existe"

IF ValType(cChave) = "U"
	cChave := &(ReadVar())
ENDIF

xAlias := Alias()
nOldOrder  := IndexOrd()
dbSelectArea(cAlias)

If EOF() .Or. RecC() == 0
	nSalvReg := 0
Else
	nSalvReg := RecNo()
EndIf
If Subs(cAlias,1,3) == "SM2"
	cFil := Space(FWSizeFilial())
Else
	cFil := cFilial
EndIf

nOrdem := Iif(nOrdem==Nil,IndexOrd(),nOrdem)
dbSetOrder(nOrdem)
dbSeek(cFil+cChave)

IF Found()
	If nSalvReg > 0
		dbGoTo(nSalvReg)
	EndIf
	dbSelectArea(xAlias)
	dbSetorder(nOldOrder)
	Return .T.
Else
	dbSetorder(nOrdem)
	dbSeek(cFil+cChave)
	If Found()
		If nSalvReg > 0
			Go nSalvReg
		EndIf
		dbSelectArea(xAlias)
		dbSetOrder(nOldOrder)
		Return .T.
	Endif
Endif

Tone(3000,1)
MsgStop(cHelp,STR0021) //"Atenção"

If nSalvReg > 0
	dbGoto(nSalvReg)
EndIf
dbSelectArea(xAlias)
dbSetorder(nOldOrder)
Return .F.


/*
Realiza o Cadastro do Veiculo
*/
Static Function ImptVeic(aCamposD)
	Local  oModel, oAux, oStruct
	Local  nI        := 0
	Local  nPos      := 0
	Local  lRet      := .T.
	Local  aAux	     := {}
	Local  cModelVV1 := 'MODEL_VV1'
    Local  aErro     := {}

	oModel := FWLoadModel( 'VEIA070' )
	oModel:SetOperation( MODEL_OPERATION_INSERT )
	lRet := oModel:Activate()

	If lRet
		oAux    := oModel:GetModel( cModelVV1 )
		oStruct := oAux:GetStruct()
		aAux	:= oStruct:GetFields()
		For nI := 1 To Len( aCamposD )
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCamposD[nI][1] ) } ) ) > 0
				If !oModel:SetValue( cModelVV1, aCamposD[nI][1], aCamposD[nI][2] )
					lRet    := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf

	If lRet
		If ( lRet := oModel:VldData() )
			lRet := oModel:CommitData()  //Salva campos
		EndIf
	EndIf

	If !lRet

		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro := oModel:GetErrorMessage()

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

		AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
		AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
		AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
		AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
		AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
		AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
		AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
		AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
		AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )

		MostraErro()

		If !Empty(aErro)
			/*		cGridMsg := "[GRID] Erro oGrid:Execute()"+CRLF
					// An error occurred, either in processing, or in
					// Grid termination. Check the property arrays
					If !empty(oGrid:aErrorProc)
						// One or more fatal errors occurred that aborted the process
						// [1] : Sequential number of sent instruction that was not processed
						// [2] : Parameter sent for processing
						// [3] : Identification of Agent where the error occurred
						// [4] : Details of error event
						cGridMsg += CRLF
						cGridMsg += varinfo('ERR',oGrid:aErrorProc)+CRLF
					Endif
					If !empty(oGrid:aSendProc)
						// returns list of calls sent and not executed
						// [1] Sequential number of instruction
						// [2] Sending parameter
						// [3] Identification of Agent that received the requisition
						cGridMsg += CRLF
						cGridMsg += varinfo('PND',oGrid:aSendProc)+CRLF
					Endif*/
					
					cGridMsg += (aErro[1]+" "+aErro[2]+" "+aErro[6]+" "+aErro[7])     //oGrid:GetError()
					cGridArq := cLogDir+"IMP_"+aTabExclui[nRadMenu1][1]+"-"+DTOS(Date())+StrTran(Time(),":")+".LOG"
					U_zGravaLog(cGridArq,cGridMsg)
				EndIf





	EndIf

	// Desativamos o Model
	oModel:DeActivate()

Return aErro

/*/{Protheus.doc} zGeraExcel
Gera planilha excel
@param  	aColunas -> Colunas da planilha
aItens -> Itens/Dados da planilha
cArqExc -> Nome arquivo a ser criado
cPatSrv -> Pasta do server para criação da planilha
cPatLoc -> Pasta local para copiar planilha
cTitulo -> Titulo da planilha
@author 	Atilio Amarilla
@version  	P11.8
@since  	02/03/2015
@return  	NIL
@obs
@project
@history
/*/

Static Function zGeraExcel(aColunas,aItens,cArqExc,cPatSrv,cPatLoc,xWorkSheet,xTable)
	
	Local oExcel         := FWMSEXCEL():New()
	Local aLinha         := {}
	
	Local cLinhaXML      :=""
	Local nHXML
	Local cColXML        :=""
	
	Local oSay1
	Local oButtonOK
	Local oButtonCancela
	Local cTpSald
	
	local 	_lAll1       := .F.
	local 	_oOk         := LoadBitmap( GetResources(), "LBOK")
	local 	_oNo 	     := LoadBitmap( GetResources(), "LBNO")
	//Local bValid         := {|| Iif(ApOleClient("MsExcel"),.T.,(MsgAlert("MsExcel não instalado"),)) }
	Local nX, nY, nI
	
	DEFAULT xTable	:= ""
	
	xTable	:= IIF(Empty(xTable),xWorkSheet,xTable)
	
	cPatSrv	:= IIF(cPatSrv==NIL,"",cPatSrv)
	cPatLoc	:= IIF(cPatLoc==NIL,"",cPatLoc) // GetTempPath()
	
	If !Empty(cPatSrv)
		If !FWMakeDir( cPatSrv , .T. )
			cPatSrv := ""
		EndIf
	EndIf
	
	If !Empty(cPatLoc)
		If !FWMakeDir( cPatLoc , .T. )
			cPatLoc := GetTempPath()
		EndIf
	Else
		cPatLoc := GetTempPath()
	EndIf
	
	
	If Empty(xTable) .Or. ValType(xTable) == "C"

		//Cria Planilha
		oExcel:AddworkSheet(xWorkSheet)

		//Cria Tabela
		oExcel:AddTable (xWorkSheet,xTable)
		
		//Adiciona Colunas
		For nX := 1 to Len( aColunas )
			oExcel:AddColumn(xWorkSheet,xTable,aColunas[nX]		,1,1)
		Next nX
		
		For nX	:= 1 to Len( aItens )
			aLinha	:= {}
			For nY	:= 1 to Len( aItens[nx] )
				aAdd( aLinha , aItens[nX,nY] )
			Next nY
			oExcel:AddRow(xWorkSheet,xTable,aLinha)
		Next nX
	Else
		For nI := 1 to Len(xTable)

			//Cria Planilha
			oExcel:AddworkSheet(xTable[nI])

			//Cria Tabela
			oExcel:AddTable (xTable[nI],xWorkSheet[nI])
			
			//Adiciona Colunas
			For nX := 1 to Len( aColunas[nI] )
				oExcel:AddColumn(xTable[nI],xWorkSheet[nI],aColunas[nI][nX],1,1)
			Next nX
			
			For nX	:= 1 to Len( aItens[nI] )
				aLinha	:= {}
				For nY	:= 1 to Len( aItens[nI][nx] )
					aAdd( aLinha , aItens[nI][nX,nY] )
				Next nY
				oExcel:AddRow(xTable[nI],xWorkSheet[nI],aLinha)
			Next nX
		
		Next nI
	EndIf
	//%%%%%%%%%%%%%%%%%%   TODOS A ESTRUTURA MONTADA %%%%%%%%%%%%%%%%%%%%%%%%%
	//Ativa a planilha e deixa pronta para gerar arquivo.
	oExcel:Activate()
	
	oExcel:GetXMLFile(cPatSrv+cArqExc)
	
	oExcel:DeActivate()
	
	If CpyS2T(cPatSrv+cArqExc,cPatLoc)
		//		 MsgInfo( "Arquivo " + cArq + " gerado com sucesso no diretório " + cPath )
		If ApOleClient("MsExcel")
			
			If !"X:" $ AllTrim(cPatLoc)
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( cPatLoc + cArqExc )
				oExcelApp:SetVisible(.T.)              // Abre excel automaticamente .T. // Não .F.
			//		  oExcel:Destroy()                       // exclui Excel.exe do processo no gerenciador de tarefas
			EndIf
		Else
			Aviso("zGeraExcel","MsExcel não instalado"+CRLF+"Planilha "+cArqExc+" copiado para pasta "+cPatLoc+".",{'Ok'})
		EndIf
	else
		Aviso("zGeraExcel","Planilha "+cArqExc+" não copiado para pasta "+cPatLoc+"."+CRLF+"Verifique suas permissões.",{'Ok'})
	endif
	//   Endif
	
	
Return

Static Function GravaPen(cMsg,cArq,cCab)

If !File(cArq)
	nH := FCreate(cArq)
	FWrite(nH,cCab+Chr(13)+Chr(10),Len(cCab)+2)
Else
	nH := FOpen(cArq,1)
EndIf

FSeek(nH,0,2)
FWrite(nH,cMsg+Chr(13)+Chr(10),Len(cMsg)+2)
FClose(nH)

Return
