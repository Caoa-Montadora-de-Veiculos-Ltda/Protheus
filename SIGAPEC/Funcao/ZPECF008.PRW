#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "Totvs.ch"
#include "Topconn.ch"
//#include "PROTHEUS.CH" 
#include "ZPECF008.CH"

#define CRLF chr(13) + chr(10)

Static oZPEC08Peca  := DMS_Peca():New()

/*/{Protheus.doc} ZPECF008
Responsável por Aglutinar e Separação do orçamento passando pelas fases automaticamente
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		 
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 
@menu       Nao Informado
@return		Nulo
@history    DAC - 16/12/2022 PEC031 - Limite de Credito - Revitalização DAC
@    		DAC -19/05/2023
            PEC042 - Controle de saldo e e-mail apos integracao de armazenagem - Imprimir sem passar pelo parâmetro chamada ZPECR007
/*/
User Function ZPECF008()
	Local _aSays	    := {}
	Local _aButtons	    := {}
	Local _cCadastro    := OemToAnsi(STR0001)   //"Separação Orçamento"
	Local _cTitle  	    := OemToAnsi(STR0002)   //"Separação Orçamento"
	Local _aPar    	    := {}
	Local _aRet    	    := {}
	Local _nRet			:= 0
	Local _lZPECF008    := SuperGetMV( "CMV_PEC009"  ,,.T. )   //Parâmetro para indicação de utilização do programa tendo como Default Verdadeiro, não é necessário a criação do mesmo
	//Local _lAvaliaOrc   := SuperGetMV( "CMV_PEC032"  ,,.F. )   //Parâmetro para indicação de utilização do programa tendo como Default Verdadeiro, não é necessário a criação do mesmo
	//Local _lAvaliaItem  := SuperGetMV( "CMV_PEC033"  ,,.F. )   //Parâmetro para indicação de utilização do programa tendo como Default Verdadeiro, não é necessário a criação do mesmo
	Local _cArmazemFDR 	:= AllTrim(SuperGetMV( "CMV_PEC036" ,,"" ))   //Parâmetro para indicação de utilização de validação armazem Franco da Rocha

	//Local _cFilDe 	:= Space(TamSx3("VS1_FILIAL")[1])
	//Local _cFilAte	:= Space(TamSx3("VS1_FILIAL")[1])
	Local _cCliFatDe	:= Space(TamSx3("VS1_CLIFAT")[1])
	Local _cCliFatAte 	:= Space(TamSx3("VS1_CLIFAT")[1])
	Local _cLojaCFDe 	:= Space(TamSx3("VS1_LOJA")[1])
	Local _cLojaCFAte	:= Space(TamSx3("VS1_LOJA")[1])
	Local _dDataIni		:= CtoD(Space(08))
	Local _dDataFim		:= CtoD(Space(08))
	Local _cNumOrcDe	:= Space(TamSx3("VS1_NUMORC")[1])
	Local _cNumOrcAte	:= Space(TamSx3("VS1_NUMORC")[1])
	Local _cCodProd		:= Space(TamSx3("B1_COD")[1]) 
	Local _cCodMarca	:= Space(TamSx3("VE1_CODMAR")[1])
	Local _aVar			:= {}
	Local _aCampos		:= {}
	Local _cAliasPesq   := GetNextAlias()      
	Local _aChave 		:= {}
	Local _lJob   		:=	If( IsBlind(),.T.,.F.)
	Local _oSay			:= Nil
	Local _cLocal		:= "01"  //iniciar com armazem 01
	Local _cObsPrc		:= ""
	Local _aOndaRel 	:= {}
	Local _nPos

	Private _cAglutina 	:= ""
	Private _aMensAglu	:= {}
	
	Begin Sequence
		If !_lZPECF008                             
			Break
		Endif        
		/* Retirado para utilizar as duas situações onde o orçamento total avalia fator de redução e o de item não  DAC 21/03/2023
		If _lAvaliaOrc  .And. _lAvaliaItem  
			Help( , ,"Atenção",,"Não é permitido avaliação de Crédito Total e por Item, rever parametrização com o ADM Sistemas !",4,1) //Atenção / Necessário informar os parâmetros 
			_lRet := .F.
			Break
		Endif
		*/
		//If U_ZGENUSER( RetCodUsr() ,"ZPECF008" ,.T.)
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	VX5.VX5_CHAVE,
					VX5.VX5_CODIGO,
					VX5.VX5_DESCRI
			FROM  %Table:VX5% VX5 
			WHERE 	VX5.VX5_FILIAL 	=  %xFilial:VX5% 
				AND VX5.VX5_CHAVE 	IN ('Z00','Z01')
				AND VX5.%notDel%
			ORDER BY VX5.VX5_CHAVE, VX5.VX5_CODIGO	
		EndSql
		If (_cAliasPesq)->(Eof())  
			Help( , ,"Atenção",,"Não foram encontrados Tipos de Pedidos e ou Tipos de Modal tabela VX5 !",4,1) //Atenção / Necessário informar os parâmetros 
			_lRet := .F.
			Break	
		Endif
		While (_cAliasPesq)->(!Eof())
			Aadd(_aChave,{	AllTrim((_cAliasPesq)->VX5_CHAVE), ;
							AllTrim((_cAliasPesq)->VX5_CODIGO),;
							AllTrim((_cAliasPesq)->VX5_DESCRI),;
							0,;   //Posição do Parametro selecionado
							})
			(_cAliasPesq)->(DbSkip())
		EndDo	
		//Aadd(_aPar,{1,OemToAnsi(STR003) ,_cFilDe 	,"@!"		,".T."	,"SM0" ,".T."	,50,.F.}) //"Filial de:"
		//Aadd(_aPar,{1,OemToAnsi(STR004) ,_cFilAte	,"@!"		,".T."	,"SM0" ,".T."	,50,.T.}) //"Filial Ate:"
		Aadd(_aPar,{1,OemToAnsi(STR0007) ,_cCliFatDe			,"@!"		,".T."	,"SA1" 	,".T."	,50,.F.}) //Cod. Cliente de
		Aadd(_aPar,{1,OemToAnsi(STR0009) ,_cLojaCFDe			,"@!"		,".T."	, 		,".T."	,50,.F.}) //Loja Cliente de
		Aadd(_aPar,{1,OemToAnsi(STR0008) ,_cCliFatAte			,"@!"		,".T."	,"SA1" 	,".T."	,50,.T.}) //Cod. Cliente Até
		Aadd(_aPar,{1,OemToAnsi(STR0010) ,_cLojaCFAte			,"@!"		,".T."	, 		,".T."	,50,.T.}) //Loja Cliente até
		Aadd(_aPar,{1,OemToAnsi(STR0011) ,_dDataIni				,"@D"		,".T."	, 		,".T."	,50,.F.}) //Data Inicial Orçamento
		Aadd(_aPar,{1,OemToAnsi(STR0012) ,_dDataFim				,"@D"		,".T."	, 		,".T."	,50,.T.}) //Data Final Orçamento
		Aadd(_aPar,{1,OemToAnsi(STR0013) ,_cNumOrcDe			,"@!"		,".T."	, 		,".T."	,50,.F.}) //Numero Orçamento de
		Aadd(_aPar,{1,OemToAnsi(STR0014) ,_cNumOrcAte			,"@!"		,".T."	, 		,".T."	,50,.T.}) //Numero Orçamento Até
		Aadd(_aPar,{1,OemToAnsi(STR0040) ,_cCodProd				,"@!"		,".T."	,"SB1" 	,".T."	,50,.F.}) //Código do Produto
		Aadd(_aPar,{1,OemToAnsi(STR0041) ,_cCodMarca			,"@!"		,".T."	,"VE1" 	,".T."	,50,.T.}) //Código do marca
		aAdd(_aPar,{3,OemToAnsi(STR0042) ,2 ,{STR0005,STR0006,STR0043}	,60,"",.F.})  //Descrição / 1=Sim 2=Não 3=Todos
		For _nPos := 1 To Len(_aChave)
			aAdd(_aPar,{3,OemToAnsi(_aChave[_nPos,3]) ,2 ,{STR0005,STR0006}	,60,"",.F.})  //Descrição / 1=Sim 2=Não
			_aChave[_nPos,4] := Len(_aPar)
		Next
		aAdd(_aPar,{3,OemToAnsi(STR0039) ,2 ,{STR0005,STR0006}	,80,"",.F.})  //Todas Alternativas / 1=Sim 2=Não
		aAdd(_aPar,{3,OemToAnsi(STR0044) ,2 ,{STR0005+" (Se orçamento inicial não preenchido e final com ZZZZZZZZ)",STR0006}	,175,"",.T.})  //BY PASS / 1=Sim 2=Não

		// Monta Tela principal
		AADD(_aSays,OemToAnsi(STR0020)) //Este Programa tem  como  Objetivo  realizar a separação de Produtos
		AADD(_aSays,OemToAnsi(STR0030)) //constantes  no Orçamento, sendo aglutinado conforme  definições 
		AADD(_aSays,OemToAnsi(STR0031)) //previas e enviando a quantidade para a separação dos orçamentos.
		AADD(_aSays,OemToAnsi(STR0032)) //Clique no botão Parâmetros para alterar as definições da rotina. 
		AADD(_aSays,OemToAnsi(STR0033)) //Depois clique no Botão OK.
		AADD(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
		AADD(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
		AADD(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,"ZPECF008",.T.,.T.) 			}})

		FormBatch( _cCadastro, _aSays, _aButtons )
		If _nRet <> 1
			Break
		Endif
		If Len(_aRet) == 0
			Help( , ,OemToAnsi(STR0028),,OemToAnsi(STR0027),4,1) //Atenção / Necessário informar os parâmetros 
			Break 
		Endif
		_cAglutina 	:= ""
		_aMensAglu	:= {}
		_cObsPrc    := ""

		If ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) //90- HMB
			If ( AllTrim(_aRet[10]) == "CHE" .Or. AllTrim(_aRet[10]) == "SBR" )
				Help( , ,OemToAnsi(STR0028),,"Marca CHE/SBR bloqueada na empresa 90 | HMB",4,1) //Atenção / Necessário informar os parâmetros 
				Break 
			EndIf
		EndIf
		//Carregar processo
		If _lJob
			ZPECF08PRC( _aRet, _aVar, _aCampos, _aChave, _cLocal,/*indica FDR*/ , @_cObsPrc )
			//validar armazem Franco da Rocha caso existam saldos manutenção temporária devido mudança,  DAC 02/02/2023
			If !Empty(_cArmazemFDR)
				ZPECF08PRC( _aRet, _aVar, _aCampos, _aChave, _cArmazemFDR, .T., @_cObsPrc )
			Endif
			Conout("[ZPECF008]"+CRLF+_cObsPrc)
		Else
			FwMsgRun(,{ |_oSay| ZPECF08PRC( _aRet, _aVar, _aCampos, _aChave, _cLocal ,/*indica FDR*/, @_cObsPrc , @_aOndaRel, @_oSay ) }, "Separação Orçamentos armazém PADRÃO", "Aguarde...")  //Separação Orçamentos / Aguarde
			//validar armazem Franco da Rocha caso existam saldos manutenção temporária devido mudança,  DAC 02/02/2023
			If !Empty(_cArmazemFDR) 
				FwMsgRun(,{ |_oSay| ZPECF08PRC( _aRet, _aVar, _aCampos, _aChave, _cArmazemFDR , .T., @_cObsPrc,  @_aOndaRel, @_oSay ) }, "Separação Orçamentos armazém "+_cArmazemFDR, "Aguarde...")  //Separação Orçamentos / Aguarde
			Endif
			MSGINFO( _cObsPrc , "[ZPECF008] - Atenção" )
			ZPECF08R07(_aOndaRel)
		Endif

	End Sequence 
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif  

Return Nil

/*/{Protheus.doc} ZPECF008
Responsável pelo processamento Aglutinando e Separando do orçamento passando pelas fases automaticamente
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		 
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 
@menu       Nao Informado
@return		Nulo
@history    06/07/2022 DAC - Alterado select para onda incluído para não trazer com picking preenchido ZK_XPICKI
/*/
Static Function ZPECF08PRC( _aRet, _aVar, _aCampos, _aChave , _cLocal, _lArmFDR, _cObsPrc, _aOndaRel, _oSay )
Local _cAliasTRB    	:= GetNextAlias()      
Local _cCliFatDe 		:= _aRet[01]
Local _cLojaCFDe		:= _aRet[02]
Local _cCliFatAte 	    := _aRet[03]
Local _cLojaCFAte 		:= _aRet[04]
Local _dDataIni			:= _aRet[05]
Local _dDataFim			:= _aRet[06]
Local _cNumOrcDe 		:= _aRet[07]
Local _cNumOrcAte 		:= _aRet[08]
Local _cCodProd			:= _aRet[09]
Local _cMarca			:= _aRet[10]
Local _nXBO				:= _aRet[11]
Local _nTodos			:= _aRet[Len(_aRet) -1]
Local _nByPass			:= _aRet[Len(_aRet)]
Local _cWhere			:= ""
Local _aWherePed		:= {}
Local _aWhereTra		:= {}
Local _aVS1				:= {}
Local _lRet				:= .T.
Local _lSepara			:= .F.
Local _lValCred  		:= .T. 	

Local _cFaseConf 		:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local _cFaseOrc 		:= AllTrim(GetNewPar("MV_FASEORC","023R45F"))
Local _cConectWis  		:= AllTrim(SuperGetMV( "CMV_PEC031"  ,,"WIS.V_ENDERECO_ESTOQUE@DBLINK_WISPROD")) 
Local _cTPedTransfFDR 	:= AllTrim(SuperGetMV( "CMV_PEC038" ,,"" ))   //Parâmetro para indicação de tipo de pedido de transferencia

Local _nRegProcess		:= 0
Local _nProcessado		:= 0
Local _nGerado			:= 0
Local _nTotByPass		:= 0
Local _nGeradoErr		:= 0
Local _nLimAvalia		:= 0

Local _lInconSaldo		
Local _cStatus
Local _nPos
Local _cObs
Local _aBackOrder
Local _aSeqVS3
Local _aVS3Reg
Local _cTipoPed		
Local _cTipoModal	
Local _cCliFat		
Local _cLoja 		
Local _cFormaPgto 	
Local _cFasePrd
Local _nPosCpo
Local _cPicking
Local _dInicio 
Local _cHsInicio 
Local _dFinal 
Local _cHsFinal
Local _cCdEmpWIS
Local _cLojaCredito
Local _cFaseRet

Default _lArmFDR := .F.

//Private _cAglutina 	:= ""
//Private _aMensAglu	:= {}

_dInicio 	:= Date()
_cHsInicio 	:= SubsTr(Time(),1,5)
_dFinal 	:= Date() 
_cHsFinal	:= Substr(Time(),1,5)

Begin Sequence
	//Definir as fases que serão atendidas no processo
	_nPosCpo := AT(_cFaseConf, _cFaseOrc)
	If _nPosCpo == 0 
		MSGINFO( "Não existe fase de orçamento no parâmetro Fase", "[ZPECF008] - Atenção" )
		Break
	Endif
	//identifico os status que posso apagar
	_cFasePrd := SubsTr(_cFaseOrc, 1, _nPosCpo -1)+ " "

	//Verificar informações passadas no pergunte 
	If _nTodos <> 1   //Caso não esteja informado todas as alternativas  devo avaliar as altenativas selecionadas
		//Verificarei nos itens contidos no VX5 e acrescentados nas perguntas
		For _nPos := 1 To Len(_aChave)
			//Verifico se esta marcado com Sim
			If _aChave[_nPos,4] > 0 .and. _aRet[_aChave[_nPos,4]] == 1 
				//Verifico se é Modal
				If _aChave[_nPos,1] == "Z01" 
					Aadd( _aWhereTra, _aChave[_nPos,2])  	
				ElseIf _aChave[_nPos,1] == "Z00"
					Aadd( _aWherePed,_aChave[_nPos,2])
				EndIf
			EndIf
		Next
		//ajustar para o Select 
		If Len( _aWhereTra) > 0
			_cWhere += " AND VS1.VS1_XTPTRA IN ("	 	
 			For _nPos := 1 To Len(_aWhereTra)
				_cWhere += "'" +_aWhereTra[_nPos]+ "',"
			Next
			_cWhere := SubsTr(_cWhere,1,Len(_cWhere)-1)
			_cWhere += ") "	 + CRLF	
		EndIf
		//ajustar para o Select 
		If Len( _aWherePed) > 0
			_cWhere += " AND VS1.VS1_XTPPED IN("	 	
 			For _nPos := 1 To Len(_aWherePed)
				_cWhere += "'" +_aWherePed[_nPos]+ "',"
			Next
			_cWhere := SubsTr(_cWhere,1,Len(_cWhere)-1)
			_cWhere += ") "	+ CRLF 	
		EndIf
		//Verifico caso não tenha selecionado todos tem que ter informações dos selecionados
		If Empty(_cWhere)
			Aviso("AVISO","Não foram selecionados itens para verificação e ou opção [Todos] ! ",{"Ok"})
			Break
		EndIf
	EndIf
	//Verificar por código de produto conforme solicitado por Zé DAC 21/12/2021
	If !Empty(_cCodProd)
		_cWhere += "AND (SELECT VS3.VS3_NUMORC "
		_cWhere += " 	FROM "+ RetSQLName('VS3') +" VS3 "
		_cWhere += "		WHERE 	VS3.VS3_FILIAL = '"+ XFilial("VS3")  +"' "	
		_cWhere += "			AND VS3.VS3_NUMORC = VS1.VS1_NUMORC  "	
		_cWhere += "			AND VS3.VS3_CODITE = '"+ _cCodProd		 +"' "
		_cWhere += "			AND VS3.D_E_L_E_T_ = ' ' ) = VS1.VS1_NUMORC  " + CRLF
	EndIf

	If _nXBO == 1
		_cWhere += "AND VS1.VS1_XBO = 'S' " + CRLF
	ElseIf _nXBO == 2
		_cWhere += "AND VS1.VS1_XBO <> 'S' " + CRLF

	EndIf
	//verificar as fases até o processamento da fase de conferencia
	_cStatus := ""
	//_cFaseOrc := "023RTZ"  //tratar somente as fase 0, 2, R no momento
	For _nPos := 1 to Len(_cFaseOrc)
		If SubsTr(_cFaseOrc,_nPos,1) == _cFaseConf
			Exit
		Endif
		_cStatus += "'" +SubsTr(_cFaseOrc,_nPos,1)+ "',"
	Next
	_cStatus := SubsTr(_cStatus,1,Len(_cStatus)-1)
	//_cStatus := "%"+_cStatus+"%"

	//acrecentado validações gerais
	_cWhere += 	" AND VS1.VS1_FILIAL	= '" +XFilial("VS1")+ "' " + CRLF
	//caso seja armazem Franco da Rocha não pode tratar com o numero do orçamento somente com o numero de aglutinação DAC 02/02/2023
	If _lArmFDR .and. !Empty(_cAglutina)
		_cWhere += 	" AND VS1.VS1_XAGLU BETWEEN '" +_cAglutina+ "'	AND '" +_cAglutina+ "' " + CRLF 
		_cWhere += 	" AND VS1.VS1_XBO = 'S' " + CRLF
	Else
		_cWhere += 	" AND VS1.VS1_NUMORC BETWEEN '" +_cNumOrcDe+ "'	AND '" +_cNumOrcAte+ "' " + CRLF 
	EndIf

	_cWhere += 	" AND VS1.VS1_TIPORC = '1' " + CRLF
	_cWhere += 	" AND VS1.VS1_XMARCA = '"    +_cMarca+ "' " + CRLF 
	_cWhere += 	" AND VS1.VS1_XPICKI = ' ' " + CRLF
	_cWhere += 	" AND VS1.VS1_CLIFAT BETWEEN '" +_cCliFatDe+ "'	AND '" +_cCliFatAte+ "' " + CRLF
	_cWhere += 	" AND VS1.VS1_LOJA   BETWEEN '" +_cLojaCFDe+ "'	AND '" +_cLojaCFAte+ "' " + CRLF
	If !Empty(_cStatus)
		_cWhere += 	" AND VS1.VS1_STATUS IN  (" +_cStatus+ ") " + CRLF
	EndIf
	_cWhere += 	" AND VS1.VS1_XDTIMP BETWEEN '" +DtOS(_dDataIni)+ "'	AND '" +DtOS(_dDataFim)+   "' " + CRLF 
	
	/*
	VS1->VS1_STATUS == "0"  //Digitado
	VS1->VS1_STATUS == "2"	//Margem Pendente
	VS1->VS1_STATUS == "3"	//Avaliacao de Credito
	VS1->VS1_STATUS == "5"	//Aguardando Lib.Diverg.
	VS1->VS1_STATUS $ "RT"	//Aguardando Reserva
	VS1->VS1_STATUS == "F"	//liberação para faturamento
	VS1->VS1_STATUS == "P"  //Pendente para O.S.
	VS1->VS1_STATUS == "L"	//Liberado para O.S.
	VS1->VS1_STATUS == "I"	//Importado para O.S.
	VS1->VS1_STATUS == "C"  //cancelado
	VS1->VS1_STATUS == "X"  //faturado  
	
	VS1_TIPOORC 1=Orcamento Pecas;2=Orcamento Oficina;3=Transferência                                                                           
	VS1_STARES 1=Reservado;2=Parcialmente Reservado;3=Nao Reservado                                                                            
			//AND VS1_STARES NOT IN ('1,2')
	*/
	//pegar a conexão wIS
    //If  "_PRD" $ AllTrim(GetEnvServer())  //"PRODUÇÃO"  //.or. AllTrim(GetEnvServer()) == "PRIME"
	
	//	_cConectWis 		:= " WIS.V_ENDERECO_ESTOQUE@DBLINK_WISPROD "
	//Conforme solicitação JC em reunião com Sidnei RG colocar validação de empresa relacionada a marca DAC 28/062022
	If AllTrim(_cMarca) $ "HYU_SBR"
       	_cCdEmpWIS 	:= "1006"  //-- HYU SBR
	ElseIf AllTrim(_cMarca) $ "CHE"  //1002 CHE
       	_cCdEmpWIS	:= "1002"  //-- HYU SBR
	EndIf
	/*
    Else
		//Não esta funcionando homologação pegar produção pois somente consulta	
        //_cConectWis 		:= " WIS.V_ENDERECO_ESTOQUE@DBLINK_WISHML "
		_cConectWis 		:= " WIS.V_ENDERECO_ESTOQUE@DBLINK_WISPROD "

		//Conforme solicitação JC em reunião com Sidnei RG colocar validação de empresa relacionada a marca DAC 28/062022
		If AllTrim(_cMarca) $ "HYU_SBR"
        	_cCdEmpWIS 	:= "1006"  //-- HYU SBR
		ElseIf AllTrim(_cMarca) $ "CHE"  //1002 CHE
        	_cCdEmpWIS 	:= "1002"  //-- HYU SBR
		EndIf
    EndIf
	*/
	//_cConectWis := "%"+_cConectWis+"%"
	//_cCdEmpresa := "%"+_cCdEmpresa+"%"
	//CRIO O NUMERO DA AGLUTINAÇÃO E CONFIRMO PARA NÃO PERDER O PONTEIRO
	//somente criar numero de aglutinação no processo normal não do armazem FDR DAC 02/02/2023
	//If !_lArmFDR  //caso faça isto dara erro na 10 pois xonda será o mesmo da aglutinação antes de testas FDR
	_cAglutina := GETSX8NUM("VS1","VS1_XAGLU")
	VS1->(ConfirmSx8())

	//Aadd(_aOndaRel,_cAglutina)

	//Endif	

	//Caso o usuário informe a numeração do orçamentono parametor inicial e final não executar como bypass DAC 
	If !Empty(_cNumOrcDe) .or.  !"Z" $ _cNumOrcAte
		_nByPass := 2
	Endif	
	//Separar os itens que não serão lidos BY PASS 
	//Verifica itens que não posuem saldos no orçamento despresando no processamento, verifica saldo item principal, similar, substituto e KIT
	If _nByPass == 1
		If _nXBO == 2 
			Aviso("AVISO","Não será possivel processar Provisório pois a indicação de BO esta como não para BO, "+;
				 		  "para processamento Provisório somente leva em consideração BOs ! ",{"Ok"})
			_lRet := .F.
			Break	
		EndIf
		If !ZPEC08PROVisorio(_cAglutina, _cWhere, _cLocal, _cConectWis, _cCdEmpWIS)  //verificar se enviar somente BO, todos ou sem BO
			Aviso("AVISO","Não foi possivel atualizar os itens Provisórios ! ",{"Ok"})
			_lRet := .F.
			Break	
		EndIf
		_cWhere += "AND VS1.VS1_XONDA <>  '"+_cAglutina+"'"
		_nTotByPass := XCONTBYPAss( _cAglutina ) 
	Else
		_nTotByPass := 0	
	EndIf	

	_dInicio 	:= Date()
	_cHsInicio 	:= SubsTr(Time(),1,5)

	_cWhere := "%"+_cWhere+"%"
    //Popular tabela temporária, irei colocar apenas um unico registro
	BeginSql Alias _cAliasTRB //Define o nome do alias temporário 
		SELECT  NVL(VS1.R_E_C_N_O_,0) NREGVS1
				,VS1.VS1_XTPPED
				,VS1.VS1_XTPTRA
	 			,VS1.VS1_CLIFAT
				,VS1.VS1_LOJA
				,VS1.VS1_FORPAG
				,VS1.VS1_XDTIMP
				,VS1.VS1_XHSIMP
		FROM 	%Table:VS1% VS1
		INNER JOIN %Table:VX5% VX5Z03
			ON VX5Z03.%notDel%
			AND VX5Z03.VX5_FILIAL = ' '
			AND VX5Z03.VX5_CHAVE = 'Z03'
			AND VX5Z03.VX5_CODIGO = VS1.VS1_XTPPED
        WHERE	VS1.%notDel%  					
				%Exp:_cWhere%
  		ORDER BY VX5Z03.VX5_DESCRI, VS1.VS1_XTPTRA,VS1.VS1_XDTIMP, VS1.VS1_XHSIMP, VS1.VS1_CLIFAT, VS1.VS1_LOJA, VS1.VS1_FORPAG 
	EndSql

//Alterado conforme solicitação JC 20/20/2022, alterado ORDER BY e incluido INIER JOIN
//   ORDER BY VS1.VS1_XTPPED, VS1.VS1_XTPTRA, VS1.VS1_CLIFAT, VS1.VS1_LOJA, VS1.VS1_FORPAG, VS1.VS1_XDTIMP, VS1.VS1_XHSIMP 
//Alterado solicitado por Zé 19/05/2022 conforme Rosangela
//			AND VS1.VS1_DATORC BETWEEN %Exp:_dDataIni% 		AND %Exp:_dDataFim%
//        ORDER BY VS1.VS1_XTPPED, VS1.VS1_XTPTRA, VS1.VS1_CLIFAT,VS1.VS1_LOJA, VS1.VS1_FORPAG, VS1.VS1_DATORC, VS1.VS1_HORORC
 //ORDER BY VS1.VS1_XTPPED, VS1.VS1_XTPTRA, VS1.VS1_CLIFAT,VS1.VS1_LOJA, VS1.VS1_FORPAG, VS1.VS1_XDATOS, VS1.VS1_XHOROS
//        GROUP by ROLLUP(VV1.R_E_C_N_O_)
//GROUP BY A1.A1_CGC, VS1.VS1_FORPAG, VS1.VS1_XTPPED, VS1.VS1_XTPTRA, VS3.VS3_CODITE, VS3.VS3_QTDITE--, B2.B2_QATU -- TIPOS_MODAIS.TIPO_MODAL,
//ORDER BY VS1.VS1_XTPPED, VS1.VS1_XTPTRA
//            AND VS1.VS1_STATUS IN ('0','R','T','L','I')   //MV_FASEORC PEGAR TUDO QUE FOR ANTES DE QUATRO ACRESCIDO DO STATUS BAKORDER "R" 
//        ORDER BY VS1.VS1_XTPPED, VS1.VS1_XTPTRA, VS1.VS1_CLIFAT,VS1.VS1_LOJA, VS1.VS1_FORPAG

	//TCSetField(_cAliasTRB,'ZD0_DATPRF','D',8,0)
	If (_cAliasTRB)->(Eof())  
		If !_lArmFDR
			Aviso("AVISO","Não foram encontrados Orçamentos ! ",{"Ok"})
		EndIf	
		_lRet := .F.
		Break	
	Endif
	(_cAliasTRB)->(DbGotop())	
	Count To _nRegProcess
	_oSay:SetText(StrZero(_nRegProcess,7)+" Registros - Reg. Lidos " + StrZero(_nProcessado,7)+ " Reg. Gerados "+StrZero(_nGerado,7)  )
	ProcessMessage() 
	(_cAliasTRB)->(DbGotop())
	//ProcRegua(_nRegProcess)
	//Caso exista registros guardarei um numero para aglutinação
	//_cAglutina := GETSX8NUM("VS1","VS1_XAGLU")
    While (_cAliasTRB)->(!Eof())
		//caso seja o armazém de transferência não validar somente validar se não for transferência o tipo de pedido, esta transferência sera de Barueri para FDR DAC 08/02/2023
		If _lArmFDR .and. !Empty(_cTPedTransfFDR) .and. AllTrim((_cAliasTRB)->VS1_XTPPED) == _cTPedTransfFDR 	
			(_cAliasTRB)->(DbSkip())
			Loop
		Endif	
		//organizar para geração do Picking após o acumuo dos orçamentos DAC 14/06/2022
		_cTipoPed		:= (_cAliasTRB)->VS1_XTPPED
		_cTipoModal		:= (_cAliasTRB)->VS1_XTPTRA
	 	_cCliFat		:= (_cAliasTRB)->VS1_CLIFAT
		_cLoja 			:= (_cAliasTRB)->VS1_LOJA
		_cFormaPgto 	:= (_cAliasTRB)->VS1_FORPAG
		_aVS1			:= {}
		_lSepara		:= .F.
		_lValCred 		:= .T.
		_nLimAvalia 	:= 0
		//DAC montar um while com controle do order by para pickin
		//Guardo orçamentos para poder agrrupar os produtos nos itens
  		While (_cAliasTRB)->(!Eof()) .And. _cTipoPed 	== (_cAliasTRB)->VS1_XTPPED .And. 	_cTipoModal	== (_cAliasTRB)->VS1_XTPTRA ;
								  	 .And. _cCliFat  	== (_cAliasTRB)->VS1_CLIFAT .And. 	_cLoja 		== (_cAliasTRB)->VS1_LOJA ;
								  	 .And. _cFormaPgto 	== (_cAliasTRB)->VS1_FORPAG

		        //IncProc("Verificando Orçamentos para Separação... ")
			_lRet			:= .T.
			_aMensAglu		:= {}
			_lInconSaldo 	:= .F.  //inconsistencias com saldo serão as unicas que gravarão XBO = S conforme alinhado com Zé 04/02/2022  DAC 04/02/2022
			_nProcessado	++
			VS1->(DbGoto((_cAliasTRB)->NREGVS1))
			If !Softlock("VS1") // Travar Registro do VS1
        		Help( , ,OemToAnsi(STR0028),,OemToAnsi("Não Foi ossivel travar registro orçamento "+VS1->VS1_NUMORC+" para processamento a operação será abortada !"),4,1) //Atenção / "Não Foi ossivel travar registro para processamento a operação será abortada ! 
				_lRet 	:= .F.
				Break	
			EndIf

			If !VS1->VS1_STATUS $ _cFasePrd
				(_cAliasTRB)->(DbSkip())
				Loop
			Endif		
			//No caso de ja possuir reserva aguardar
			If VS1->VS1_STATUS $ "R_T"
				VS1->(RecLock("VS1",.F.))
				_cObs			:="Orçamento "+ AllTrim(VS1->VS1_NUMORC) +" esta com reserva, não será separado  referente a Onda "+_cAglutina+" !
				VS1->VS1_OBSAGL	:= Upper(_cObs) + CRLF  + AllTrim(VS1->VS1_OBSAGL)
				VS1->(MsUnlock())
				(_cAliasTRB)->(DbSkip())
				Loop
			Endif		
			//Verificar se existe divergência de Tabela
			If U_XVERTABPreco (_cCliFat, _cLoja, VS1->VS1_NUMORC )
				//Recalcular valores
				If !VS1->(U_ORCCALFIS(VS1->VS1_NUMORC /*_cNumOrc*/,/*_lAtuaPreco*/))
					VS1->(RecLock("VS1",.F.))
					_cObs			:="Não foi possivel recalcular valores deste orçamento referente a Onda "+_cAglutina+" !
					VS1->VS1_OBSAGL	:= Upper(_cObs) + CRLF  + AllTrim(VS1->VS1_OBSAGL)
					VS1->(MsUnlock())
					(_cAliasTRB)->(DbSkip())
					Loop
				Endif
			Endif

			//Conforme e-mail Zé devido a problemas com o Padrão necessário voltar para o status "0" quando estiver com "3" 25/04/2022 
			//Estamos com um problema no padrão conforme abaixo e, acredito que como paliativo, até que seja feita essa correção, o ideal seria que, todos Orc.Fases no status ‘3’ que estejam no parâmetro da rotina de Separação, retornem para status ‘0’ antes da chamada da função de análise de crédito do padrão evitando o bloqueio indevido dos mesmos.
			If VS1->VS1_STATUS == "3"
				VS1->(RecLock("VS1",.F.))
				VS1->VS1_STATUS := "0"
				VS1->(MsUnlock())
			EndIf
			//somente validar se não for transferência o tipo de pedido, esta transferência sera de Barueri para FDR DAC 08/02/2023
			If Empty(_cTPedTransfFDR) .Or. AllTrim(VS1->VS1_XTPPED) <> _cTPedTransfFDR
				//Verificar Fases
				If "2" $ _cFaseOrc  //somente se estiver na fase do orçamento conforme alinhado com Zé 30/11/2021
					U_XFASEORC("2")  //Verifica se passa pela Fase MARGEM DE LUCRO
					If VS1->VS1_STATUS == "2"
						_lRet := .F. 
					EndIf	
				Else
					//Conforme José TOTVS caso esteja nesta fase voltar para zero se não 01/12/2021 
					If VS1->VS1_STATUS == "2"
						VS1->(RecLock("VS1",.F.))
						VS1->VS1_STATUS := "0"
						VS1->(MsUnlock())
						//_lRet	:= .F.  DEIXAR CONTINUAR temporariamente conforme solicitado
					EndIf
				EndIf
			Endif	
			IF VS1->VS1_CLIFAT == '000314'
				CONOUT('TESTE')
			ENDIF
			//Verifica Saldos 
			If _lRet
				_aBackOrder 	:= {}
				_lInconSaldo 	:= .F.  //inconsistencias com saldo serão as unicas que gravarão XBO = S conforme alinhado com Zé 04/02/2022  DAC 04/02/2022
				Begin Transaction
					//Caso esteja com bloqueio de limite verificar se é possivel utilizar o limite para os itens existentes em quanto o valor estiver atendendo a quantidade
					If _lRet .and. !Empty(_cTPedTransfFDR) .And. AllTrim(VS1->VS1_XTPPED) == _cTPedTransfFDR
						If !ZPECF8TVS3(VS1->VS1_NUMORC, VS1->VS1_XMARCA, @_aBackOrder, _cConectWis, _cCdEmpWIS, _cLocal, _cTPedTransfFDR)
							_lRet 		 := .F.
							_lInconSaldo := .T.
           					Disarmtransaction()
						EndIf  
					ElseIf _lRet
						If !ZPECF08VS3(VS1->VS1_NUMORC, VS1->VS1_XMARCA, @_aBackOrder, _cConectWis, _cCdEmpWIS, _cLocal, _cTPedTransfFDR)
							_lRet 		 := .F.
							_lInconSaldo := .T.
           					Disarmtransaction()
						EndIf  
					
						//Caso esteja com bloqueio de limite verificar se é possivel utilizar o limite para os itens existentes em quanto o valor estiver atendendo a quantidade
						If _lRet 
							//Verifica Limite de Crédito
							//AJUSTE PARA UTILIZAR LIMITE DE CRÉDITO PARCIAL - RETIRADO CALCULO DAC 09/12/2022
							If "3" $ _cFaseOrc  //somente se estiver na fase do orçamento conforme alinhado com Zé 30/11/2021
								_cFaseRet := U_XFASEORC("3" /*_cFase*/, /*_cGrupo*/, /*_cCodPro*/, @_nLimAvalia) //Verifica se passa pela Fase Limite de Crédito
								If Empty(_cFaseRet)  //quando retorna em branco não conseguiu definir limite de crédito
									_lRet 		:= .F.   
									_lValCred 	:= .F.
									Disarmtransaction()
								EndIf
							Else
								//Conforme José TOTVS caso esteja nesta fase voltar para zero se não 01/12/2021 
								If VS1->VS1_STATUS == "3"
									VS1->(RecLock("VS1",.F.))
									VS1->VS1_STATUS := "0"
									VS1->VS1_XBO    := "N"
									VS1->(MsUnlock())
									//_lRet	:= .F.  DEIXAR CONTINUAR
								EndIf
							EndIf
						
							//Utilizar limite de crédito Parcial
							//PEC031 - Limite de Credito - Revitalização
							If _lRet .And. "3" $ _cFaseOrc  .And. _cFaseRet == "3" //somente se estiver na fase do orçamento conforme alinhado com Zé 30/11/2021
								_cLojaCredito := U_XLJLCREDito(_cCliFat)  //função ja posiciona SA1
								//"1=Credito Disponivel;2=Falta de Saldo;3=Titulos Em Atraso;4=Credito Vencido;5=Bloqueado
								If Empty(_cLojaCredito)
									_lRet     := .F.
									_lValCred := .F.
								Else	
									If  (SA1->A1_XSTAFP $ "1|2" .OR. (SA1->A1_XSTAFP == "3" .AND. SA1->A1_XBLQVEN == "2") ) //.AND. _nLimAvalia > 0 
										//Caso ainda esteja bloqueado deverá tentar liberar o limite de crédito que possui
										VS1->(DbGoto((_cAliasTRB)->NREGVS1))
										If !ZPECF08LCC(VS1->VS1_NUMORC,_nLimAvalia, _aBackOrder)
											_lRet     := .F.
										EndIf
									Else
										_lRet     := .F.
									EndIf
								EndIf
								If !_lRet
									_lValCred := .F.
									Disarmtransaction()	
								EndIf
							EndIf	
						EndIf	
					Endif   //Fim tratamento por tipo pedido transferencia FDR
					
					//Atualiza fase para Separação e se necessário gera Backorder
					//Retorno para o registro VS1 pode ter sido disposicionado DAC 20/06/2022
					//Mesmo que esta bloqueado por limite de crédito deixo fazer o carregamento devido os arquivos em bakorder
					VS1->(DbGoto((_cAliasTRB)->NREGVS1))
					If _lRet .and. !ZPECF08CAR(VS1->VS1_NUMORC, @_aBackOrder, @_aSeqVS3,(_cAliasTRB)->NREGVS1, @_aVS3Reg, If(_lArmFDR, _cLocal, ""))
						_lRet := .F.
           				Disarmtransaction()
					EndIf	
					//Cria separação e faz reserva
					If _lRet  .And. VS1->VS1_STATUS <> "3"  //somente deixar criar se não for bloqueio de credito
						_lRet := U_XOFUNLIB(VS1->VS1_NUMORC, _aSeqVS3, _aVS3Reg) 
						If !_lRet
           					Disarmtransaction()
						EndIf	
					Endif
					//If _lRet .and. !U_XOZPECDA()  //Aplicar desconto e ou acrescimo conforme o tipo parametrizado
					//	_lRet	:= .F._cObs
           			//	Disarmtransaction()
					//EndIf
				End Transaction
			EndIf	
			//Retorno para o registro VS1 pode ter sido disposicionado DAC 20/06/2022
			VS1->(DbGoto((_cAliasTRB)->NREGVS1))
			//indicação para preparar a separação
			//_cAglutina:=_cAglutina
			If _lRet
				Aadd(_aVS1, (_cAliasTRB)->NREGVS1 )
				_lSepara	:= .T.
				_nGerado  	++
			Endif

			//gravar informações no VS1
			_cObs := 	Upper("Aglutinado/Separação "+ _cAglutina +" em "+ DtoC(Date()) +" "+ ;
		  				SubsTr(Time(),1,5) +" hs." +If(_lRet," com sucesso "," não realizado")) + CRLF
			_cObs += "PROCESSANDO ARMAZÉM"+ _cLocal + CRLF
			
			If Len(_aMensAglu) > 0
				For _nPos := 1 To Len(_aMensAglu)
					If !Empty(_aMensAglu[_nPos])
						_cObs += Upper((_aMensAglu[_nPos]) + CRLF)
					EndIf	
				Next
			EndIf
  			VS1->(RecLock("VS1",.F.))
			VS1->VS1_XAGLU 		:= _cAglutina  //Gravar o numero da Aglutinação
			VS1->VS1_XDTAGL		:= Date()
			VS1->VS1_XHSAGL		:= Time()
			VS1->VS1_XUSUGL		:= RetCodUsr()
			VS1->VS1_OBSAGL		:= _cObs + CRLF  + AllTrim(VS1->VS1_OBSAGL)
			//caso tenha passado não estar marcado como problema 
			/*
			If _lInconSaldo .and. VS1->VS1_XBO <> "S"
				If _lRet 
					VS1->VS1_XBO	:= "N"
				ElseIf !_lRet 
					VS1->VS1_XBO	:= "S"
				EndIf
			EndIf
			*/
			If !_lValCred .and. !_lRet 
				VS1->VS1_XBO	:= "N"
				VS1->VS1_STATUS := "3"
			ElseIf _lInconSaldo //.And. VS1->VS1_XBO <> "S" 
				VS1->VS1_XBO	:= "S"
				VS1->VS1_STATUS := "0"
			ElseIf !_lInconSaldo .And. _lRet  //.And. _lRet .And. VS1->VS1_XBO == "S"
				VS1->VS1_XBO	:= "N"
			EndIf	
			VS1->(MsUnlock()) // Retirar SoftLock do VS1
			(_cAliasTRB)->(DbSkip())
			_oSay:SetText(StrZero(_nRegProcess,7)+" Registros - Reg. Lidos " + StrZero(_nProcessado,7)+ " Reg. Gerados "+StrZero(_nGerado,7)  )
			ProcessMessage() 
    	EndDo
		//Garantir que ira retirar o lock
		VS1->(MsUnlock()) // Retirar SoftLock do VS1
		If _lSepara
			//Gera o numero do picking para envio RG LOG
			_cPicking := U_XGERPIK2( _aVS1 )  //Enviar separação para aglutinação ZPECFUNA cria um numero de picking antes do envio para separaçao
			//Caso não gere Picking retornar para status 0
			If Empty(_cPicking)	
				For _nPos := 1 To Len(_aVS1)
					VS1->(DbGoto(_aVS1[_nPos]))
					U_XRETSTVS1(VS1->VS1_NUMORC, /*_lTela*/)
				Next
				_lSepara	:= .F.
				_nGerado  	--
				_nGeradoErr	++
			//Envia o picking pata a RG LOG
			Else
				StartJob("U_ZWSR007",GetEnvServer(),.F.,_cAglutina, _cPicking, /*_lDataEnv*/, cEmpAnt, cFilAnt, /*_aMens*/)
				//Incluir processamento da onda somente quando tiver algum titulo gerado
				If Ascan(_aOndaRel, _cAglutina) == 0
					Aadd(_aOndaRel,_cAglutina)
				EndIf
			EndIf
		EndIf
	EndDo
	//Verifica se existe picking pendente ao qual não foi enviado
	_dFinal 	:= Date() 
	_cHsFinal	:= Substr(Time(),1,5)
	Sleep(30000) //aguardar um momento para inicializar reprocesso assim não causa sobreposição	
	//Função para reprocessar envio RGLOG
	StartJob("U_XFUNPRRGlog",GetEnvServer(),.F.,_cAglutina, cEmpAnt, cFilAnt, /*_nReprocessado*/, /*_oSay*/)
End Sequence
Sleep(5000) //aguardar um momento para inicializar reprocesso assim não causa sobreposição	
//Função que verifica a quantidade de envios realizadas com Sucesso
_nGeradoErr += XCONTIRGLog( _cAglutina )

_cObs		:= Upper("Processo referente a Onda  "	+_cAglutina+" finalizado !!!")  + CRLF
_cObs		+= CRLF
_cObs		+= Upper("REFERENTE AO ARMAZÉM " +If(_lArmFDR, _cLocal, "PADRÃO"))
_cObs		+= CRLF
_cObs		+= "Total Reg................ 	 " 		+ StrZero(_nTotByPass+_nRegProcess,7)	+" Registros" + CRLF
_cObs		+= "Selecionados........  " 			+ StrZero(_nRegProcess,7)	+" Registros" + CRLF
_cObs		+= CRLF
_cObs		+= "Lidos.......................  " 	+ StrZero(_nProcessado,7)	+" Registros" + CRLF 
_cObs		+= "Gerados.................  " 		+ StrZero(_nGerado,7)  		+" Registros" + CRLF
_cObs		+= "Enviados................  " 		+ StrZero(XCONTERGLog( _cAglutina ),7)  +" Registros" + CRLF
_cObs		+= "Problemas envio.. " 				+ StrZero(_nGeradoErr,7)  +" Registros" + CRLF
_cObs		+= CRLF
_cObs		+= "Iniciado em.........  " 			+ DtoC(_dInicio)+ " as " 	+_cHsInicio   + CRLF 
_cObs		+= "Finalizado em.....  " 				+ DtoC(_dFinal) + " as " 	+_cHsFinal    + CRLF

//U_CAOA_TRFO(_cAglutina, cEmpAnt, cFilAnt)
//StartJob("U_CAOA_TRFO",GetEnvServer(),.F.,_cAglutina, cEmpAnt, cFilAnt) // Transferencia entre filial não validado
_cObsPrc += CRLF
_cObsPrc += _cObs
//MSGINFO( _cObs , "[ZPECF008] - Atenção" )
If Select((_cAliasTRB)) <> 0
	(_cAliasTRB)->(DbCloseArea())
	Ferase(_cAliasTRB+GetDBExtension())
Endif 
Return _lRet


/*/{Protheus.doc} ZPECF08VS3
Responsável por verificar se pode liberar o orçamento para carregamento
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		_cNumOrc - Numero do orçamento 
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 
@menu       Nao Informado
@return		_lRet	- Verdadeiro ou falso  
@history    DAC - 28/12/2021
			GAP_PECCD01 - Controle de Validade de Produtos com Inm V1.
			DAC - 02/02/2023
			GAP 		- Incluido armazém para verificação onda FDR
			DAC 08/08/2023
			GAP			- Incluindo validação tipo de Pedido para transferência Barueri para FDR
/*/
Static Function	ZPECF08VS3(_cNumOrc, _cMarca, _aBackOrder, _cConectWis, _cCdEmpWIS, _cLocal, _cTPedTransfFDR)  
Local _lRet 		:= .F.
Local _lSepara		:= .F.
Local _lParcial		:= .F.
Local _cAliasPesq	:= GetNextAlias()   
Local _cArmazem		:= _cLocal
Local _aBak			:= {}
Local _cValidItSubs := Upper(AllTrim(SuperGetMV( "CMV_PEC022"  ,,"" )))   //Parâmetro para indicação de utilização do programa tendo como Default Verdadeiro, não é necessário a criação do mesmo

Local _nPos
Local _aRetSaldo 
Local _lRetorno 
Local _cMens
//Local _aCpoVazio	:= {"VS1_XAGLU","VS1_XDTAGL","VS1_XHSAGL","VS1_XUSUGL","VS1_OBSAGL"}
//Local _nTam			:= TamSx3("B2_LOCAL")[1]
Local _nSaldoSB2
Local _nQtdeItem 
Local _cCodProd
Local _nQtdePrd  
Local _nQtdeParc 
Local _lZera
Local _cObs
Local _nSAldo := 0
Begin Sequence
	_cConectWis := "%"+_cConectWis+"%"
	_cCdEmpWIS 	:= "%"+_cCdEmpWIS+"%"

	//--PRODUTOS COM SALDO EM CÓDIGOS ALTERNATIVOS(IT.REL/SUBST/CORRELATO) + CONSULTA WIS		
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT DISTINCT 
			VS3.VS3_NUMORC 
		, 	VS3.VS3_CODITE 
		, 	VS3.VS3_GRUITE 
		, 	VS3.VS3_LOCAL 
		, 	VS3.VS3_CODTES 
		, 	VS3.VS3_QTDITE  AS  QTDE_TOTAL 
		, 	VS3.VS3_SEQUEN 
		, 	SB1.B1_MSBLQL
		, 	SB1.B1_XNUMINM 
		, 	SB1.B1_XVLDINM 
		, 	AVG(	CASE WHEN VS3.VS3_CODITE IS NOT NULL 
				THEN
				(	SELECT NVL((B2VS3.B2_QATU - B2VS3.B2_RESERVA - B2VS3.B2_QACLASS),0) 
					FROM %Table:SB2%  B2VS3 
					WHERE 	B2VS3.B2_FILIAL		= %xFilial:SB2%	
						AND B2VS3.B2_COD 		= VS3.VS3_CODITE 										
						AND B2VS3.B2_LOCAL 		= %Exp:_cArmazem%
						AND B2VS3.%notDel% 
				) 
	  	  		ELSE 
					0	  
	  	  		END ) AS SLD_VS3
		,	AVG(COALESCE(VS3.R_E_C_N_O_,0)) NREGVS3 	
		FROM %Table:VS3% VS3
		LEFT  JOIN %Table:SB1% SB1
			ON SB1.B1_FILIAL 		= %xFilial:SB1%
			AND SB1.B1_COD 			= VS3.VS3_CODITE
			AND SB1.%notDel%
		WHERE VS3.VS3_FILIAL 		= %xFilial:VS3%
			AND VS3.VS3_NUMORC 		= %Exp:_cNumOrc%
			AND VS3.%notDel%
		GROUP BY  VS3.VS3_NUMORC 
				, VS3.VS3_CODITE 
				, VS3.VS3_GRUITE 
				, VS3.VS3_LOCAL 
				, VS3.VS3_CODTES 
				, VS3.VS3_QTDITE   
				, VS3.VS3_SEQUEN 
				, SB1.B1_MSBLQL
				, SB1.B1_XNUMINM 
				, SB1.B1_XVLDINM 
		ORDER BY VS3.VS3_NUMORC, VS3.VS3_SEQUEN
	EndSql
/*  Retirado 05/12/2022 para que execute o calculo pelo Padrão
		, 	AVG( CASE WHEN VE9.VE9_ITENOV IS NOT NULL 
				THEN 
				( 	SELECT SUM(NVL((B2VE9.B2_QATU - B2VE9.B2_RESERVA - B2VE9.B2_QACLASS),0)) 
					FROM %Table:SB2% B2VE9
					JOIN %Table:VE9% VE9
						ON 	VE9.VE9_FILIAL 		= %xFilial:VE9%
						AND VE9.VE9_ITEANT 		= VS3.VS3_CODITE
						AND VE9.%notDel%							
				) 
				ELSE 
					0 
				END)  AS SLD_SUBSTI 
		,	AVG( CASE WHEN VPD.VPD_CODREL IS NOT NULL 
				THEN 
				( 	SELECT SUM(NVL((B2VPD.B2_QATU - B2VPD.B2_RESERVA - B2VPD.B2_QACLASS),0))			
					FROM %Table:SB2% B2VPD
		 			JOIN %Table:VPD% VPD
						ON VPD.VPD_FILIAL 		= %xFilial:VPD%
						AND VPD.VPD_COD 		= VS3.VS3_CODITE
						AND VPD.%notDel% 							
				WHERE 	B2VPD.B2_FILIAL		= %xFilial:SB2% 	
					AND B2VPD.B2_COD 		= VPD.VPD_CODREL 									
					AND B2VPD.B2_LOCAL 		= %Exp:_cArmazem%
					AND B2VPD.%notDel%
		  		) 
				ELSE 
					0 
				END)  AS SLD_SIMILAR 
		, ( SELECT SUM(NVL((B2VE8.B2_QATU - B2VE8.B2_RESERVA - B2VE8.B2_QACLASS),0))  		
	 		FROM %Table:VE8% VE8
	 		JOIN %Table:SB2% B2VE8 
				ON  B2VE8.B2_FILIAL 	= %xFilial:SB2% 
				AND B2VE8.B2_COD 		= VE8.VE8_CODITE 
		 		AND B2VE8.B2_LOCAL 		= %Exp:_cArmazem% 
				AND B2VE8.B2_QATU 		> 0
				AND B2VE8.%notDel% 	
			WHERE VE8.VE8_FILIAL		= %xFilial:VE8% 
				AND VE8.VE8_CODKIT 		= VS3.VS3_CODITE 
				AND VE8.%notDel%
			) AS SLD_KIT


		LEFT JOIN %Table:VE9% VE9 
			ON VE9.VE9_FILIAL 		= %xFilial:SB1%    
			AND VE9.VE9_ITEANT 		= VS3.VS3_CODITE 
			AND VE9.%notDel%
		LEFT JOIN  %Table:VPD% VPD 
			ON VPD.VPD_FILIAL 		= %xFilial:SB1%      
			AND VPD.VPD_COD 		= VS3.VS3_CODITE 
			AND VPD.%notDel%

*/


//	TCSetField(_cAliasPesq,'VS3_CODITE','C',TamSx3("B2_COD")[1],0)

	_lSepara	:= .F.  //indica se tera algum item que será separado
	_aBackOrder := {}

 	If (_cAliasPesq)->(Eof())  
		_lRet := .F.
		Aadd(_aMensAglu,"Orçamento não possui itens localizados !")
		Break	
	Endif
	
	While (_cAliasPesq)->(!Eof())
		//Ajustar tamanho código produto
		//_cArmazem	:= (_cAliasPesq)->VS3_LOCAL
		_cCodProd 	:= AllTrim((_cAliasPesq)->VS3_CODITE)
		_cGrupo		:= (_cAliasPesq)->VS3_GRUITE

		//Conforme solicitação JC e Fabio caso não tenha TES Abortar o orçamento inteiro
		If 	Empty((_cAliasPesq)->VS3_CODTES)
			Aadd(_aMensAglu,"Produto "+ AllTrim(_cCodProd) +" com TES não informado no item do orçamento !")
			_lSepara	:= .F.  //indica se tera algum item que será separado
			_aBackOrder  := {}
			Break	
		Endif

		//Não deixar com armazem em branco	
		If Empty((_cAliasPesq)->VS3_LOCAL)
			Aadd(_aMensAglu,"Armazem do Produto "+ AllTrim(_cCodProd) +" não informado no item do orçamento !")
			Aadd(_aBak,{(	_cAliasPesq)->NREGVS3,;
							_cCodProd,;
							(_cAliasPesq)->QTDE_TOTAL,;
							_aMensAglu[Len(_aMensAglu)],; 
							.T. ,;  					//_Lxbo
							.T. })  					//_lZera
   			(_cAliasPesq)->(DbSkip())  //Devo verificar se existem outros itens
			Loop
		Endif
		//Verificar se esta bloqueado
		//Tratamento de trasferencia para FDR por tipo de pedido DAC 08/02/2023
		If Empty(_cTPedTransfFDR) .Or. AllTrim(VS1->VS1_XTPPED) <> _cTPedTransfFDR
			If (_cAliasPesq)->B1_MSBLQL == "1"  
				Aadd(_aMensAglu,"Produto "+ AllTrim(_cCodProd) +" bloqueado não será permitido faturar !")
				Aadd(_aBak,{(	_cAliasPesq)->NREGVS3,;
				 				_cCodProd,; 
								(_cAliasPesq)->QTDE_TOTAL,;
								_aMensAglu[Len(_aMensAglu)],; 
								.T. ,;							//_Lxbo 
								.T. })							//_lZera	
	   			(_cAliasPesq)->(DbSkip())  //Devo verificar se existem outros itens
				Loop
			EndIf		
			//Validar Imetro
			//GAP_PECCD01 - Controle de Validade de Produtos com Inm V1.
			//ja esta posicionado no SB1 função U_XSLDCAOAEstoque
			If !Empty((_cAliasPesq)->B1_XNUMINM) .And. (_cAliasPesq)->B1_XVLDINM < DtOS(DATE())
				Aadd(_aMensAglu,"Produto "+ AllTrim(_cCodProd) +" não permitido faturar, restrição INMETRO !")
				Aadd(_aBak,{(	_cAliasPesq)->NREGVS3,;
				 				_cCodProd,; 
								(_cAliasPesq)->QTDE_TOTAL,;
								_aMensAglu[Len(_aMensAglu)],; 
								.T. ,;							//_Lxbo 
								.T. })							//_lZera	
	   			(_cAliasPesq)->(DbSkip())  //Devo verificar se existem outros itens
				Loop
			EndIf
			//Caso o saldo tenha sido encontrado no produto devo validar pelo Sistema 
			//no caso
		Endif
		_nSaldoSB2 := 0
		If (_cAliasPesq)->SLD_VS3 > 0 
			_aRetSaldo 	:= U_XSLDCAOAEstoque(_cCodProd, _cArmazem, _cGrupo ) //procurar saldo entre Wis e Proteus DAC 25/05/2022
			_lRetorno  	:= _aRetSaldo[1]  //Retorna verdadeiro ou falso
			_nSaldoSB2  := _aRetSaldo[2]  //Retorna oSaldo calculado
			_cMens		:= _aRetSaldo[3]  //Retorna as Mensagens de validações	 
			_cCodProd	:= _aRetSaldo[4]  //pego o produto novamente pois o mesmo pode ter sido ajustado o tamanho
			//quando retorno mensagem ja devo separar para gravar	
			If !Empty(_cMens)
				Aadd(_aMensAglu,_cMens)
			EndIf	
			If !_lRetorno  //posição de retorno
				Aadd(_aMensAglu, _cMens)  //retorno de msg
				Aadd(_aBak,{(	_cAliasPesq)->NREGVS3,;
			 					_cCodProd,; 
								(_cAliasPesq)->QTDE_TOTAL,;
								_aMensAglu[Len(_aMensAglu)],; 
								.T. ,;							//_Lxbo 
								.T. })							//_lZera	
				(_cAliasPesq)->(DbSkip())  //Devo verificar se existem outros itens
				Loop
			EndIf
		EndIf
		//Avaliar e tratar item parcial quando for parcial deverá utilizar o saldo do B2 e o restante deverá gerar separação via Bakorder
		If (_cAliasPesq)->QTDE_TOTAL <= _nSaldoSB2  //possui saldo posso processar
			//1 item substituto
			//MV_MIL0095 -- Fase de Conferência e Separação Personalizada      = 4
			// não verificar substituto para Subaro quando existe saldo  //DAC 02/03/2022
			_lSepara := .T.   //ja indico que existira separação
			//Tratamento de trasferencia para FDR por tipo de pedido DAC 08/02/2023
			If Empty(_cTPedTransfFDR) .Or. AllTrim(VS1->VS1_XTPPED) <> _cTPedTransfFDR
				//no caso de não estar no parametro posso passar para próximo registro
				If !Empty(_cValidItSubs) .and. VS1->VS1_XMARCA $ _cValidItSubs  //alterado para parametro conforme solicitação JC 19/05/2022 DAC
					(_cAliasPesq)->(DbSkip())  //Devo verificar se existem outros itens
					Loop
				EndIf
				//Verifica se tem item substituto
				_nQtdeItem := (_cAliasPesq)->QTDE_TOTAL
				Aadd(_aMensAglu,"Existe saldo no item principal, procurar item Substitutos para o produto " +AllTrim(_cCodProd)+ " armazem "+_cArmazem+"+ verificar se existe saldo produtos antigos !")	
				_lRet := ZPECF08SUB( _cNumOrc, _cGrupo, _cCodProd, _cArmazem, @_nQtdeItem )
				//Caso seja feito parcial informar
				If _lRet .and. _nQtdeItem <> (_cAliasPesq)->QTDE_TOTAL
					Aadd(_aMensAglu,"Feita Sustituição "+If(_nQtdeItem > 0," parcial","")+ "do item principal, por item Substitutos para o produto " +AllTrim(_cCodProd)+ " armazem "+_cArmazem+" não possui saldo total no substituto ! ")	
				EndIf
			Endif
			(_cAliasPesq)->(DbSkip())  //Devo verificar se existem outros itens
			Loop
		EndIf
		//Verificar utilização do parcial
		Aadd(_aMensAglu,"Produto "+AllTrim(_cCodProd)+" armazem "+_cArmazem+" não possui saldo suficiente para faturamento, saldo atual " +AllTrim(Transform(_nSaldoSB2,"@E 999,999.999")))	
		 _nQtdeParc := 0  
		 _nQtdePrd  := 0
		 _lParcial	:= .F.
 		//Caso não possua quantidade suficiente  tenho que avaliar parcial
		If (_cAliasPesq)->QTDE_TOTAL > _nSaldoSB2 .and.  _nSaldoSB2 > 0
			_nQtdeItem := (_cAliasPesq)->QTDE_TOTAL - _nSaldoSB2
			//quando possui saldo e o mesmo não atende total montar parcial para este saldo
			_nQtdePrd  := (_cAliasPesq)->QTDE_TOTAL- _nQtdeItem
			_nQtdeParc := _nQtdePrd   //(_cAliasPesq)->QTDE_TOTAL
			//ja ajusto com a quantidade parcial pois caso  não faça não ira faturar esta quantidade, o restante devrá ser avaliado e ou gerar backorder DAC 02/05/08
			If !ALTERAITParcial( (_cAliasPesq)->NREGVS3, _cNumOrc, _cGrupo, _cCodProd, _cArmazem, _cCodProd, _cGrupo, _nQtdePrd, _nQtdePrd, _nSaldoSB2, "0" ,,@_nSaldo)
				_lSepara := .F.
				Break
			EndIf	
			_lParcial 	:= .T.  //indica que usou parcial
			_lSepara 	:= .T.
		Else
			//Tratamento de trasferencia para FDR por tipo de pedido DAC 08/02/2023
			If !Empty(_cTPedTransfFDR) .And. AllTrim(VS1->VS1_XTPPED) == _cTPedTransfFDR
				(_cAliasPesq)->(DbSkip())  //Devo verificar se existem outros itens
				Loop
			Endif
			_nQtdeItem := (_cAliasPesq)->QTDE_TOTAL
		EndIf

		//Tratamento de trasferencia para FDR por tipo de pedido DAC 08/02/2023
		//necessário validar e ir até o final caso seja saldo parcial do tipo de transferência, pode gerar backorder
		If Empty(_cTPedTransfFDR) .Or. AllTrim(VS1->VS1_XTPPED) <> _cTPedTransfFDR
			//Após continuar avaliando
			//analisar possibilidades de utilizar outros produtos
			//1 item substituto
			//MV_MIL0095 -- Fase de Conferência e Separação Personalizada      = 4
			//Verificar pelo padrão existem regras que verificam produtos com situações diferentes exemplo similar DAC 01/12/2022
			//If (_cAliasPesq)->SLD_SUBSTI > 0
			_lRet := ZPECF08SUB( _cNumOrc, _cGrupo, _cCodProd, _cArmazem, @_nQtdeItem )
			//Caso consegui completar orçamento posso sair
			If _lRet .and. _nQtdeItem <= 0
				(_cAliasPesq)->(DbSkip())  //Devo verificar se existem outros itens
				_lSepara := .T.   
				Loop
			Endif		
			//EndIf
			//2- item similar
			//If (_cAliasPesq)->SLD_SIMILAR > 0
			_lRet := ZPECF08SIM( _cNumOrc, _cGrupo, _cCodProd, _cArmazem, @_nQtdeItem  )
			//Caso consegui completar orçamento posso sair
			If _lRet .and. _nQtdeItem <= 0  
				(_cAliasPesq)->(DbSkip())  //Devo verificar se existem outros itens
				_lSepara := .T.   
				Loop
			Endif		
			//EndIf
			/* conforme Zé não vai entrar num primeiro momento
			Zé solicitou validação do KIT 03/02/2022 DAC */
			//If (_cAliasPesq)->SLD_KIT	
			_lRet := ZPECF08KIT( _cNumOrc, _cGrupo, _cCodProd, _cArmazem, @_nQtdeItem, (_cAliasPesq)->NREGVS3, _lParcial )
			//Caso consegui completar orçamento posso sair
			If _lRet //.and. _nQtdeItem <= 0   //kit tem que ser tratado diferente na questão quantidade se retornar verdadeiro a quantidade do produto original ja foi zerada na funcionalidade
				(_cAliasPesq)->(DbSkip())  //Devo verificar se existem outros itens
				_lSepara := .T.   
				Loop
			EndIf
			//EndIf
		Endif
		If _nQtdePrd > 0  //significa que utilizou parcial não podendo zerar
			_lZera := .F.
		Else
			_lZera := .T.
		Endif	 

		If Empty(_cTPedTransfFDR) .Or. AllTrim(VS1->VS1_XTPPED) <> _cTPedTransfFDR
			_cObs := If(Len(_aBak) > 0,"","Não possui Saldo, item Substituto,item Similar, KIT para produto no armazem "+_cArmazem) 
		Else
			_cObs := If(Len(_aBak) > 0,"","Não possui Saldo total para a transfereria FDR conforme parametrização tipo de pedido "+_cTPedTransfFDR+" armazém "+_cArmazem) 
		Endif
		Aadd(_aBak,{	(_cAliasPesq)->NREGVS3,;
						 _cCodProd,; 
						_nQtdeItem,; 
						_cObs,;
						.T.,;    ///*_LXBO*/
						_lZera /*indica se zera ou*/})
	   (_cAliasPesq)->(DbSkip())
	Enddo
End Sequence
//no caso que conseguiu passar um item posso fazer backorder, caso não não gerar backorder
If _lSepara .and. Len(_aBak) > 0
	For _nPos := 1 To Len(_aBak)
		Aadd(_aBackOrder,_aBak[_nPos])
	Next	
EndIf	
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lSepara


/*/{Protheus.doc} ZPECF008
Responsável por pesquisar item substituto
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		_cNumOrc 	- Numero do orçamento 
			_cGrupo 	- Grupo de produto
			_cCodItem 	- Codigo produto
			_cLocal 	- Armazem
			_nQtdeItem	- Qtde de item a ser processada
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 		NÃO ESTOU UTILIZANDO Item Substituto (VB1) ESTOU UTILIZANDO VE9 ESTA ERRADO ? - menu cadastro/itens alternativos mas o ódigo do principal esta livre
			verificar a utilização do VB1 e não VE9 seria somente a inforação que utilizou o código alternativo ?
			O CORRETO É UTILIZAR A TABELA VE9 ALINHADO COM ZE SIGAPEC
@menu       Nao Informado
@return		_lRet		- Verdadeiro ou falso
@history    
/*/
Static Function	ZPECF08SUB(_cNumOrc, _cGrupo, _cCodItem, _cLocal, _nQtdeItem)
	Local _lRet			:= .F.
	Local _nQtdeAnt		:= _nQtdeItem
	Local _nSaldoSB2
	Local _aItemRelac	
	Local _cCodSubst
	Local _cGrupoSubst 
	Local _nQtdePrd  
	Local _nPos
	Local _aRetSaldo 
	Local _lRetorno
	Local _cMens
	Local _cCodProd	

	//Local _lSaldoItSubs	:= GetNewPar("MV_CHKQSUB","N") == "S"  //indica se verifica saldo do SB2 para dar continuidade no processamento

	Begin Sequence
		oZPEC08Peca:SetGrupo(_cGrupo)
		oZPEC08Peca:SetCodigo(_cCodItem)
		_aItemRelac := oZPEC08Peca:ItensSubstituidos()

		If Len(_aItemRelac) == 0 .or. Empty(AllTrim(_aItemRelac[1,2]))
			Aadd(_aMensAglu,"Não existe item Substitutos para o produto " +AllTrim(_cCodItem))	
			Break	
		Endif
		For _nPos := 1 To Len(_aItemRelac)
			_cGrupoSubst	:= _aItemRelac[_nPos,1]
			_cCodSubst 		:= AllTrim(_aItemRelac[_nPos,2])
			_nSaldoSB2 		:= _aItemRelac[_nPos,7]
			//Verificar saldo wis DAC 26/05/2022
			_aRetSaldo 	:= U_XSLDCAOAEstoque(_cCodSubst, _cLocal, _cGrupoSubst, _nSaldoSB2 ) //procurar saldo entre Wis e Proteus DAC 25/05/2022
			_lRetorno  	:= _aRetSaldo[1]  //Retorna verdadeiro ou falso
			_nSaldoSB2  := _aRetSaldo[2]  //Retorna oSaldo calculado
			_cMens		:= _aRetSaldo[3]  //Retorna as Mensagens de validações	 
			_cCodProd	:= _aRetSaldo[4]  //pego o produto novamente pois o mesmo pode ter sido ajustado o tamanho
			//quando retorno mensagem ja devo separar para gravar	
			If !Empty(_cMens)
				Aadd(_aMensAglu,_cMens)
			EndIf	
			If !_lRetorno
				Break
			Endif
			//Caso esteja zerado
			If _nSaldoSB2 <= 0
				Aadd(_aMensAglu,"Não existe saldo do item Substituto " +AllTrim(_cCodSubst)+ " para o produto " +AllTrim(_cCodItem))	
				Loop  //Pode existir outros itens	
			EndIf
			//Atualizo a quantidade que irei utilizar
			If _nSaldoSB2 >= _nQtdeItem
				_nQtdePrd := _nQtdeItem
			Else		
				_nQtdePrd :=  _nSaldoSB2
			EndIf	
			If !ZPECF08PARC( _cNumOrc, _cGrupo, _cCodItem, _cLocal, _cCodSubst, _cGrupoSubst, @_nQtdeItem, _nQtdePrd, _nSaldoSB2, "1" )
				Aadd(_aMensAglu,"Não foi possivel montar PARCIAL doProduto "+AllTrim(_cCodItem))	
				Break
			EndIf		
			If _nQtdeItem <= 0
				Exit
			EndIf		
		Next
		If _nQtdeAnt <> _nQtdeItem  //no caso gravou movimentos
			_lRet := .T.
		EndIf
	End Sequence
Return _lRet


/*/{Protheus.doc} ZPECF008
Responsável por pesquisar item Similar
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		_cNumOrc 	- Numero do orçamento 
			_cGrupo 	- Grupo de produto
			_cCodItem 	- Codigo produto
			_cLocal 	- Armazem
			_nQtdeItem	- Qtde de item a ser processada
			_cFormula	- Formula para calculo de tabela
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 		
@menu       Nao Informado
@return		_lRet		- Verdadeiro ou falso
@history    
/*/
Static Function ZPECF08SIM( _cNumOrc, _cGrupo, _cCodItem, _cLocal, _nQtdeItem)
	Local _lRet 	:= .F.
	Local _nQtdeAnt := _nQtdeItem
	Local _aItemSim
	Local _nPos
	Local _cCodSimilar
	Local _cGrupoSubst
	Local _aRetSaldo
	Local _lRetorno  
	Local _nSaldoSB2
	Local _cMens
	Local _cCodProd	
	//Local _lSaldoItSubs	:= GetNewPar("MV_CHKQSUB","N") == "S"  //indica se verifica saldo do SB2 para dar continuidade no processamento

	Begin Sequence
		oZPEC08Peca:SetGrupo(_cGrupo)
		oZPEC08Peca:SetCodigo(_cCodItem)
		_aItemSim := oZPEC08Peca:ItensRelacionados()
		//aAuxAtu := oZPEC08Peca:EstqSaldo(,.t.,.t.)

		If Len(_aItemSim) == 0 .or. Empty(AllTrim(_aItemSim[1,2]))
			Aadd(_aMensAglu,"Não existe item Similar para o produto " +AllTrim(_cCodItem))	
			Break	
		Endif
		For _nPos := 1 To Len(_aItemSim)
			_cGrupoSubst	:= _aItemSim[_nPos,1]
			_cCodSimilar	:= AllTrim(_aItemSim[_nPos,2])
			_nSaldoSB2 		:= _aItemSim[_nPos,4] //SB2->(SaldoSB2())
			//Verificar saldo wis DAC 26/05/2022
			_aRetSaldo 	:= U_XSLDCAOAEstoque(_cCodSimilar, _cLocal, _cGrupoSubst, _nSaldoSB2 ) //procurar saldo entre Wis e Proteus DAC 25/05/2022
			_lRetorno  	:= _aRetSaldo[1]  //Retorna verdadeiro ou falso
			_nSaldoSB2  := _aRetSaldo[2]  //Retorna oSaldo calculado
			_cMens		:= _aRetSaldo[3]  //Retorna as Mensagens de validações	 
			_cCodProd	:= _aRetSaldo[4]  //pego o produto novamente pois o mesmo pode ter sido ajustado o tamanho
			//quando retorno mensagem ja devo separar para gravar	
			If !Empty(_cMens)
				Aadd(_aMensAglu,_cMens)
			EndIf	
			If !_lRetorno
				Break
			Endif

			//Caso esteja zerado
			If _nSaldoSB2 <= 0
				Aadd(_aMensAglu,"Não existe saldo do item Similar " +AllTrim(_cCodSimilar)+ " para o produto " +AllTrim(_cCodItem))	
				Loop	
			EndIf
			//Atualizo a quantidade que irei utilizar
			If _nSaldoSB2 >= _nQtdeItem
				_nQtdePrd := _nQtdeItem
			Else		
				_nQtdePrd := _nSaldoSB2
			EndIf	
			//Gravar o saldo existente em novo registro
			If !ZPECF08PARC( _cNumOrc, _cGrupo, _cCodItem, _cLocal, _cCodSimilar, _cGrupoSubst, @_nQtdeItem, _nQtdePrd, _nSaldoSB2, "2" )
				Aadd(_aMensAglu,"Não foi possivel montar PARCIAL doProduto "+AllTrim(_cCodItem))	
				Break
			EndIf
			//Se zerou é por que conseguiu atingir todos os produtos
			//VERIFICAR POSTERIORMENTE SE IRA PODER SER COM PARCIAL CASO SEJA AI TEM QUE RETORNAR VERDADEIRO E MONTAR OUTRO ORÇAMENTO COM A QUANTIDADE FALTANTE
			If _nQtdeItem <= 0
				Exit
			EndIf		
		Next
		If _nQtdeAnt <> _nQtdeItem  //no caso gravou movimentos
			_lRet := .T.
		EndIf
	End Sequence
Return _lRet


/*/{Protheus.doc} ZPECF08KIT
Responsável por pesquisar e verificar se existe KIT disponivel
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		_cNumOrc 	- Numero do orçamento 
			_cGrupo 	- Grupo de produto
			_cCodItem 	- Codigo produto
			_cLocal 	- Armazem
			_nQtdeItem	- Qtde de item a ser processada
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 		
@menu       Nao Informado
@return		_lRet		- Verdadeiro ou falso
@history    06/07/2022 DAC - JC solicitou alterar o tipo VEH_TIPO = 2 para VEH_TIPO = 1
			21/07/2022 DAC - Alteração na seleção do KIT irá verificar VEH_TIPO 1 e 2, onde 1 = MANDATÓRIO e 2 = CORRELATO
/*/
Static Function ZPECF08KIT( _cNumOrc, _cGrupo, _cCodItem, _cLocal, _nQtdeItem, _nRegVS3, _lParcial  )
	//Local aRet := OFIOC040(_cGrupo,AllTrim(_cCodItem)+"KIT")
	Local _cCodKit 		:= AllTrim(_cCodItem) //+"KIT"  	//verificar se o codigo do kit será o mesmo código com final KIT - CONFORME ALINHADO COM ZÉ SERA INCLUÍDO NO CADASTRO COM MESMO CÓDIGO DE PRODUTO ACRESCENTANDO NO FINAL KIT
	Local _cGrupoKit	:= _cGrupo							//verificar se o grupo do kit sera o mesmo do grupo do produto normal - CONFORME ALINHADO COM ZÉ SIM DEVERÁ SER O MESMO GRUPO DO PRODUTO ORIGINAL	
	Local _cTipo		:= "" //"1"  //tipo VEH = ITEM
	Local _cWhere		:= ""
	Local _cAliasPesq	:= GetNextAlias()
	Local _lRet 		:= .T.
	Local _aKit			:= {}
	Local _aBak			:= {}

	Default _nRegVS3	:= 0

	Begin Sequence

		If _nRegVS3 == 0
			Aadd(_aMensAglu,"Problemas nas referencias para gravar itens para o kit  comunicar ADM SISTEMAS !")	
			_lRet := .F.
			Break	
		EndIf

		_cWhere := ""
		If VEH->(FieldPos("VEH_MSBLQL")) > 0
			_cWhere +=   " AND VEH.VEH_MSBLQL <> '1' "
		Endif
		If !Empty(_cTipo)
			_cWhere +=   " AND VEH.VEH_TIPO = '"+_cTipo+"'"
		Endif
		_cWhere := "%"+_cWhere+"%"

		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	ISNULL(VEH.R_E_C_N_O_,0) NREGVEH,
					VEH.VEH_TIPO
			FROM  	%Table:VEH% VEH
			WHERE 	VEH.VEH_FILIAL 	= %xFilial:VEH%
				AND VEH.VEH_GRUKIT 	= %Exp:_cGrupoKit%
				AND VEH.VEH_CODKIT	= %Exp:_cCodKit%
				AND VEH.%notDel%
				%Exp:_cWhere%
			ORDER BY VEH.VEH_TIPO	
		EndSql
	//			AND (VEH.VEH_TIPO	= '1' OR VEH.VEH_TIPO	= '2')

		If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGVEH == 0
			Aadd(_aMensAglu,"Não existe kit para o produto " +AllTrim(_cCodItem))	
			_lRet := .F.
			Break	
		EndIf	   

		//Verificar os itens dos KITs para saber se tem algun zerado caso tenha não ira utilizar o kit
		While (_cAliasPesq)->(!Eof())
			_cTipo 	:= (_cAliasPesq)->VEH_TIPO	
			While (_cAliasPesq)->(!Eof()) .and. _cTipo == (_cAliasPesq)->VEH_TIPO
				VEH->(DbGoto((_cAliasPesq)->NREGVEH))	
				_cGrupoKit 	:= VEH->VEH_GRUKIT
				_cCodKit	:= VEH->VEH_CODKIT
				_aKit  	:= {}
				_aBak	:= {}
				_aRet 	:= ZPECF8KITAvalia(_cTipo, _cNumOrc, _nQtdeItem, _cGrupoKit, _cCodKit, _cCodItem, _cLocal, _nRegVS3)
				If Len(_aRet) == 0 .or. Len(_aRet[1]) == 0  //sempre tem que ter um KIT
					_lRet := .F.
					Break	
				EndIf
				If Len(_aRet[1]) > 0
					_aKit :=  Aclone(_aRet[1])
					//Guardo os registros que gerarão Backorder dos KITs
					If Len(_aRet[2]) > 0
						_aBak :=  Aclone(_aRet[2])
					Endif	
					//Processar KIT gravará no orc original os KITs Encontrados
					If !ZPECF8KITProcessa(_aKit, _nQtdeItem, _nRegVS3, _lParcial)
						_lRet := .F.
						Break	
					EndIf
					If Len(_aBak) > 0 .and. !ZPECF8KITBakOrder( _aBak, _nRegVS3 )		
						_lRet := .F.
						Break	
					EndIf
				EndIf
				//Se processou o kit posso sair
				If Len(_aKit) > 0
					Break
				EndIf
				(_cAliasPesq)->(DbSkip())
			EndDo
		EndDo
	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 
Return _lRet

//Avaliar itens do KIT
Static Function	ZPECF8KITAvalia(_cTipo, _cNumOrc, _nQtdeItem, _cGrupoKit, _cCodKit, _cCodItem, _cLocal, _nRegVS3)
	Local _lRet			:= .T.
	Local _cAliasPesq	:= GetNextAlias()
	Local _aKit			:= {}
	Local _aBak			:= {}
	Local _cCodSubst
	Local _cGrupoSubst
	Local _aRetSaldo
	Local _lRetorno  
	Local _nSaldoSB2
	Local _cMens
	Local _cCodProd	
	Local _nQtdePrd
	Local _nQtde

	Default _nRegVS3 	:= 0

	Begin Sequence
		If _nRegVS3 == 0
			Aadd(_aMensAglu,"KIT - Problemas nas referencias para gravar itens para o kit  comunicar ADM SISTEMAS !")	
			_lRet := .F.
			Break	
		EndIf
		If _nQtdeItem == 0
			Break
		EndIf
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	ISNULL(VE8.R_E_C_N_O_,0) NREGVE8
			FROM %Table:VE8% VE8	
			WHERE 	VE8.VE8_FILIAL 	= %XFilial:VE8%
				AND VE8.VE8_GRUKIT	= %Exp:_cGrupoKit% 
				AND VE8.VE8_CODKIT	= %Exp:_cCodKit%
				AND VE8.%notDel%
			ORDER BY VE8.VE8_TIPO	
		EndSql
		If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGVE8 == 0
			Aadd(_aMensAglu,"KIT - Não existe itens para o kit "+_cGrupoKit+"-"+_cCodKit+" para o produto " +AllTrim(_cCodItem))	
			_lRet := .F.
			Break	
		EndIf	   
		VS3->(DbGoto(_nRegVS3))
		While (_cAliasPesq)->(!Eof())
			VE8->(DbGoto((_cAliasPesq)->NREGVE8))
			//Verificar o Saldo do item substituto
			_cCodSubst 		:= AllTrim(VE8->VE8_CODITE)
			_cGrupoSubst	:= VE8->VE8_GRUITE
			If Len(_cCodSubst) > Len(SB2->B2_COD)
				_cCodSubst := SubsTr(_cCodSubst ,1,Len(SB2->B2_COD))
			ElseIf Len(_cCodSubst) < Len(SB2->B2_COD)
				_cCodSubst := _cCodSubst+Space( Len(SB2->B2_COD)- Len(_cCodSubst))
			EndIf
			SB2->(DbSetOrder(1))  //B2_FILIAL+B2_COD+B2_LOCAL
			If !SB2->(MsSeek(XFilial("SB2")+_cCodSubst+_cLocal))
				Aadd(_aMensAglu,"KIT - Não existe saldo do item KIT " +AllTrim(_cCodSubst)+ " para o produto " +AllTrim(_cCodKit)+" armazém "+_cLocal)	
				//Caso seja mandatório e não tenha saldo nenhum abortar
				If VE8->VE8_TIPO == "1" 	
					_aKit := {}
					Break
				Endif	
				(_cAliasPesq)->(DbSkip())
				Loop
			EndIf	   
			_nSaldoSB2 := SB2->(SaldoSB2())

			//Verificar saldo wis DAC 26/05/2022
			_aRetSaldo 	:= U_XSLDCAOAEstoque(_cCodSubst, _cLocal, _cGrupoSubst, _nSaldoSB2 ) //procurar saldo entre Wis e Proteus DAC 25/05/2022
			_lRetorno  	:= _aRetSaldo[1]  //Retorna verdadeiro ou falso
			_nSaldoSB2  := _aRetSaldo[2]  //Retorna oSaldo calculado
			_cMens		:= _aRetSaldo[3]  //Retorna as Mensagens de validações	 
			_cCodProd	:= _aRetSaldo[4]  //pego o produto novamente pois o mesmo pode ter sido ajustado o tamanho
			//quando retorno mensagem ja devo separar para gravar	
			If !Empty(_cMens)
				Aadd(_aMensAglu,_cMens)
			EndIf	
			If !_lRetorno
				_aKit := {}
				(_cAliasPesq)->(DbSkip())
				Loop
			Endif
			//como é KIT tenho que multiplicar pela quantidade
			_nQtdePrd := _nQtdeItem * VE8->VE8_QTDADE  //verificar se a conta será realizada deste jeito ESTA CORRETO
			//Verifico se o tipo do KIT VEH for "2=KIT" e não tiver saldo não posso utilizar
			If _cTipo == "2" .and. (_nSaldoSB2 <= 0 .or. _nSaldoSB2 < _nQtdePrd ) //KIT
				Aadd(_aMensAglu,"KIT - Item " +AllTrim(_cCodSubst)+ " para o KIT " +AllTrim(_cCodKit)+" pertencente ao tipo 2=KIT não posui saldo suficiente, por este motivo não sera utilizado KIT !")	
				_aKit := {}
				Break	
			EndIf
			//Caso seja mandatório e não tenha saldo nenhum abortar
			//itens mandatórios não permitem que envio demais itens do produto
			If VE8->VE8_TIPO == "1" .and. (_nSaldoSB2 <= 0 .or. _nSaldoSB2 < _nQtdePrd ) //Mandatório se o saldo é menor não utilizar VE8_TIPO = 1 MANDATÓRIO
				Aadd(_aMensAglu,"KIT - Item " +AllTrim(_cCodSubst)+ " para o KIT " +AllTrim(_cCodKit)+" é mandatório e não possue saldo suficiente, por este motivo não sera utilizado KIT !")	
				_aKit := {}
				Break	
			EndIF

			If _nSaldoSB2 <= 0
				Aadd(_aMensAglu,"KIT - Não existe saldo do item " +AllTrim(_cCodSubst)+ " para o produto KIT " +AllTrim(_cCodKit)+" tipo "+_cTipo)	
				//Aadd(_aBak,{(_cAliasPesq)->NREGVE8,_nQtdePrd})  //Deverá gerar backorder caso algum atenda	
				_nQtde 		:= _nQtdePrd   			//diferença para backorder
				_nQtdePrd	:= _nSaldoSB2
				Aadd(_aBak,{ 	_cTipo,;			//01- Tipo VEH
								_cGrupoSubst,;		//02- Grupo do KIT a ser utilizado
								_cCodSubst,; 		//03- Cód produto do KIT a ser utilizado
								_nQtde,;			//04- Quantidade do KIT que será usada para BakOrder
								_nQtdePrd,; 		//05- Valor real utilizado pelo KIT que ja possui saldo
								_cNumOrc,;			//06- Numero do orçamento
								_cGrupo,; 			//07- Grupo produto solicitado no orçamento original
								_cCodItem,;			//08- Código do item solicitdo no orçamento original
								_nQtdeItem,;		//09- Qtde do item solicitada no orçamento original
								VE8->VE8_TIPO})		//10 - VS3_PECKIT 0=Não;1=Mandatório;2=Correlato 
				(_cAliasPesq)->(DbSkip())
				Loop
			EndIf

			//Atualizo a quantidade que irei utilizar
			If _nSaldoSB2 < _nQtdePrd
				Aadd(_aMensAglu,"KIT - Saldo " +AllTrim(Str(_nSaldoSB2))+ " do item " +AllTrim(_cCodSubst)+ " para o produto KIT " +AllTrim(_cCodKit)+ " menor que a qtde de item necessaria " +AllTrim(Str(_nQtdePrd))+ " será utilizado o saldo parcial!")	
				//Atendendo pelo KIT a quantidade a ser vista passa a ser do KIT e não mais a quantidade do orçamento original
				_nQtde 		:= _nQtdePrd - _nSaldoSB2  //diferença para backorder
				_nQtdePrd	:= _nSaldoSB2
				Aadd(_aBak,{ 	_cTipo,;			//01- Tipo VEH
								_cGrupoSubst,;		//02- Grupo do KIT a ser utilizado
								_cCodSubst,; 		//03- Cód produto do KIT a ser utilizado
								_nQtde,;			//04- Quantidade do KIT que será usada para BakOrder
								_nQtdePrd,; 		//05- Valor real utilizado pelo KIT que ja possui saldo
								_cNumOrc,;			//06- Numero do orçamento
								_cGrupo,; 			//07- Grupo produto solicitado no orçamento original
								_cCodItem,;			//08- Código do item solicitdo no orçamento original
								_nQtdeItem,; 		//09- Qtde do item solicitada no orçamento original
								VE8->VE8_TIPO})		//10 - VS3_PECKIT 0=Não;1=Mandatório;2=Correlato 
			EndIf	
			//Caso passe guardar no KIT
			AAdd(_aKit,{_cNumOrc,; 
						_cGrupo,;
						_cCodItem,;
						_cLocal,;
						_cCodSubst,;
						_cGrupoSubst,; 
						_nQtdePrd,; 
						_nSaldoSB2,;
						VE8->VE8_TIPO})		//09 - VS3_PECKIT 0=Não;1=Mandatório;2=Correlato 

			(_cAliasPesq)->(DbSkip())
		EndDo
	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 
Return {_aKit, _aBak}

//Gravar KIT no parcial
Static Function ZPECF8KITProcessa(_aKit, _nQtdeItem, _nRegVS3, _lParcial)
	Local _lEncKit 	:= .F.   //para não encerrar / apagar registro original	
	Local _lRet		:= .T.	 
	Local _nPos
	Local _cNumOrc 		
	Local _cGrupo  		
	Local _cCodItem   	
	Local _cLocal		
	Local _cCodSubst	
	Local _cGrupoSubst	
	Local _nQtdePrd		
	Local _nSaldoSB2	
	Local _cPecKit

	Default _nRegVS3	:= 0

	Begin Sequence
		If _nRegVS3 == 0
			Aadd(_aMensAglu,"KIT - Problemas nas referencias para gravar itens para o kit  comunicar ADM SISTEMAS !")	
			_lRet := .F.
			Break	
		EndIf
		VS3->(DbGoto(_nRegVS3))
		//Gravar os itens do processo
		For _nPos := 1 To Len(_aKit)
			_cNumOrc 	:= _aKit[_nPos,1]
			_cGrupo  	:= _aKit[_nPos,2] 
			_cCodItem   := _aKit[_nPos,3]
			_cLocal		:= _aKit[_nPos,4]
			_cCodSubst	:= _aKit[_nPos,5]
			_cGrupoSubst:= _aKit[_nPos,6]
			_nQtdePrd	:= _aKit[_nPos,7]
			_nSaldoSB2	:= _aKit[_nPos,8]
			//_lEncKit	:= If( Len(_aKit) == _nPos .and. !_lParcial, .T.,.F. )  //controlar quando encerra o processo 
			//quando é utilizado kit o produto principal não sera parcial tera que ser apagado DAC 29/09/2022
			_lEncKit	:= If( Len(_aKit) == _nPos , .T.,.F. )  //controlar quando encerra o processo 
			If !ZPECF08PARC( _cNumOrc, _cGrupo, _cCodItem, _cLocal, _cCodSubst, _cGrupoSubst, @_nQtdeItem, _nQtdePrd, _nSaldoSB2, "3", _lEncKit, _cPecKit )
				Aadd(_aMensAglu,"KIT - Não foi possivel montar PARCIAL do Produto "+AllTrim(_cCodItem))	
				_lRet := .F.
				Break
			Endif
		Next _nPos
	End Sequence
Return _lRet

//Gerar BakOrder dos KITs
/*
			Aadd(_aBak,{ 	_cTipo.;			//01- Tipo VEH
							VE8->VE8_GRUKIT,;	//02- Grupo do KIT a ser utilizado
							VE8->VE8_CODKIT.; 	//03- Cód produto do KIT a ser utilizado
							_nQtde,;			//04- Quantidade do KIT que será usada para BakOrder
							_nQtdePrd,; 		//05- Valor real utilizado pelo KIT que ja possui saldo
							_cNumOrc,;			//06- Numero do orçamento
							_cGrupo,; 			//07- Grupo produto solicitado no orçamento original
							_cCodItem,;			//08- Código do item solicitdo no orçamento original
							_nQtdeItem })		//09- Qtde do item solicitada no orçamento original

*/
Static Function ZPECF8KITBakOrder( _aBak, _nRegVS3 )
	Local _lRet 	:= .T.
	Local _lApagaIT	:= .F.
	Local _lXBO		:= .T.
	Local _aOrc		:= {}
	Local _aItem	:= {}
	Local _aObs		:= {}
	Local _aObsVS3	:= {}
	Local _cOrcNovo := VS1->(GetSXENum("VS1","VS1_NUMORC"))
	Local _cTpSub	:= "3"
	Local _nQtdeProd
	Local _cNumOrc
	Local _cGrupo
	Local _cCodItem
	Local _nPos
	Local _cTipo
	Local _cGrupoKit
	Local _cCodKit
	Local _nQtdeKitB
	Local _nQtdeKitR 
	Local _cObs

	Default _nRegVS3	:= 0

	Begin Sequence
		If _nRegVS3 == 0
			Aadd(_aMensAglu,"KIT - Problemas nas referencias para gravar itens para o kit  comunicar ADM SISTEMAS !")	
			_lRet := .F.
			Break	
		EndIf
		VS3->(DbGoto(_nRegVS3))

		//Gravar os itens do processo
		For _nPos := 1 To Len(_aBak)
			_aItem		:= Aclone({})
			_cTipo 		:= _aBak[_nPos,1]
			_cGrupoKit	:= _aBak[_nPos,2]
			_cCodKit	:= _aBak[_nPos,3]
			_nQtdeKitB 	:= _aBak[_nPos,4] 
			_nQtdeKitR 	:= _aBak[_nPos,5] 
			_cNumOrc	:= _aBak[_nPos,6]
			_cGrupo		:= _aBak[_nPos,7]
			_cCodItem	:= _aBak[_nPos,8]
			_nQtdeProd	:= _aBak[_nPos,9]

			Aadd(_aItem,{ "VS1_CLIFAT"	, VS1->VS1_CLIFAT})
			Aadd(_aItem,{ "VS1_LOJA"	, VS1->VS1_LOJA})
			Aadd(_aItem,{ "VS1_NUMORC"	,_cNumOrc})
			Aadd(_aItem,{ "NUMORCNOVO"	,_cOrcNovo}) 
			Aadd(_aItem,{ "VS1_XAGLU"	,_cAglutina})
			Aadd(_aItem,{ "VS3_GRUITE"	, _cGrupoKit}) 
			Aadd(_aItem,{ "VS3_CODITE"	, _cCodKit}) 
			Aadd(_aItem,{ "VS3_QTDITE"	, _nQtdeKitB}) 
			Aadd(_aItem,{ "VS3_PERDES"	, VS3->VS3_PERDES}) 
			Aadd(_aItem,{ "VS3_OPER"	, VS3->VS3_OPER}) 
			Aadd(_aItem,{ "VS3_CODTES"	, VS3->VS3_CODTES})
			Aadd(_aItem,{ "VS1_XTPPED"	, VS1->VS1_XTPPED})
			Aadd(_aItem,{ "VS3_XTPSUB"	, _cTpSub})
			//Zé solicitou para deixar as informações será tratado de outra forma no select das posições do mesmo
			//Aadd(_aItem,{ "VS3_XITSUB"	, ""})  //deixar em branco no caso do KIT, conforme solicitação Zé 17/08/2022, 00729891 
			Aadd(_aItem,{ "VS3_CODKIT"	, _cCodItem})
			Aadd(_aItem,{ "VS3_GRUKIT"	, _cGrupo})
			Aadd(_aItem,{ "VS3_QTDINI"	, _nQtdeKitB})  //a quantidade do KIT tem que ser alterada , conforme solicitação Zé 17/08/2022
			Aadd(_aItem,{ "VS3_XDTSUB"	, Date()})
			Aadd(_aItem,{ "VS3_XHRSUB"	, Time()})
			Aadd(_aItem,{ "VS3_XAGLU"	, _cAglutina})
			Aadd(_aItem,{ "VS3_XUSUGL"	, RetCodUsr()})
			Aadd(_aItem,{ "VS3_XOBSAGL"	, _aObsVS3})
			Aadd(_aItem,{ "LXBO"		, _lXBO})
			Aadd(_aItem,{ "LAPAGAIT"	, _lApagaIT})
			Aadd(_aItem,{ "LBAKORDER"	, .T.})
			Aadd(_aItem,{ "NREGVS3"		, _nRegVS3 })
			Aadd(_aItem,{ "NREGVS1"		, VS1->(Recno()) })
			Aadd(_aOrc, _aItem)
			//Gravar na observação
			_cObs := "Item " +AllTrim(_cCodItem)+ " "
			_cObs += "qtde " +AllTrim(STR(_nQtdeProd))+ " "
			_cObs += "BakOrder KIT Tipo "	+_cTipo+ " " 
			_cObs += "item " +AllTrim(_cCodKit)+ " "
			_cObs += "qtde " +AllTrim(STR(_nQtdeKitB))+ " "
			_cObs += "utilizado "+AllTrim(StR(_nQtdeKitR))+ " "
			Aadd(_aObs,_cObs)
		Next _nPos

		_lRet := U_XCLONEOR( _aOrc, /*_aCpoVazio*/, /*_lXBO*/, /*_lApagaIT*/, _aObs)	
	End Sequence
Return _lRet


//Avaliar se pode realizar fechamnto
Static Function ZPECF08CAR(_cNumOrc, _aBackOrder, _aSeqVS3, _nRegVS1, _aVS3Reg, _cArmazemFDR)
	Local _lRet 		:= .T.
	Local _cNumSeq
	//Garantir que esta posicionado no VS1 DAC 20/06/2022
	Default _nRegVS1 		:= VS1->(Recno()) 
	Default _cArmazemFDR	:= ""
	Begin Sequence
		//Montar novo orçamento caso tenha inconsistencias em itens DAC 08/02/2022
		If Len(_aBackOrder) > 0
			_lRet := U_XOFUNCLO( _cNumOrc, /*_cGrupo*/, /*_cCodProd*/, /*_nQtdeItem*/, /*_lZera*/, /*_aVazioCpo*/, _aBackOrder)
			If ! _lRet
				Aadd(_aMensAglu,"Ocorrerão problemas para clonar itens que não possuem status para carregamento aos quais passriam para backorder <ZPECF08CAR> !")
				Break	
			EndIf
		EndIf	

		VS1->(DbGoto(_nRegVS1))
		VS3->(DbSetOrder(1))
		VS3->(MsSeek(XFilial("VS3")+_cNumOrc))
		If !VS3->(MsSeek(XFilial("VS3")+_cNumOrc))
			_lRet := .F.
			Aadd(_aMensAglu,"Não localizado itens do orçamento "+_cNumOrc+" para ajuste parcial (ZPECF08PARC) do produto principal !")
			Break
		EndIF	
		//organizar a sequencia
		_cNumSeq := StrZero(0,Len(VS3->VS3_SEQUEN))
		_aSeqVS3 := Aclone({})
		_aVS3Reg := Aclone({})
		While VS3->(!Eof()) .and. VS3->VS3_NUMORC == _cNumOrc
			_cNumSeq 	:= Soma1(_cNumSeq)
			If ! RecLock("VS3",.F.)
				_lRet := .F.
				Aadd(_aMensAglu,"Não foi possivel ajustar a sequencia dos itens, não conseguiu bloquear registro !")
				Exit
			Endif
			VS3->VS3_SEQUEN := _cNumSeq
			//Atualizar para o armazem de Franco da Rocha quando estiver lendo o depósito deste processo  DAC 02/02/2023
			If !Empty(_cArmazemFDR)
				VS3->VS3_LOCAL 	:= _cArmazemFDR
				//VS3->VS3_SQCONF := ""   //STRZERO(Val(VS3->VS3_SEQUEN),Len(VS3->VS3_SQCONF))  //caso não faça isto na troca da sequencia terei problemas na geração do VM5 no retorno do carregamento DAC 04/02/2022 
			EndIf
			If !Empty(VS3->VS3_SQCONF) 
				VS3->VS3_SQCONF := ""   //caso não faça isto na troca da sequencia terei problemas na geração do VM5 no retorno do carregamento DAC 04/02/2022 
			Endif
			aAdd(_aSeqVS3, VS3->VS3_SEQUEN)
			AAdd(_aVS3Reg, VS3->(Recno()))
			//Envia o numero de registro para a nova função U_XRESCAOAPEC
			//aAdd(_aResVS3,VS3->(Recno())) 
			VS3->(MsUnlock())
			VS3->(DbSkip())
		EndDo

		If _lRet 
			//AJUSTAR VALORES E IMPOSTOS
			//U_ORCCALFIS(/*_cNumOrc*/,/*_lAtuaPreco*/)
			If VS1->VS1_STATUS <> "3"  //deixo passar caso seja bloqueio
				U_XFASEORC("4")
				If VS1->VS1_STATUS <> "4" 
					_lRet	:= .F.
					Aadd(_aMensAglu,"Ocorrerão problemas para mudança de status carregamento <ZPECF08CAR> !")
					Break
				EndIf
			Endif	
		Endif

	End Sequence
Return _lRet


/*/{Protheus.doc} ZPECF008
Responsável por Alterar as quantidades do orçamento e criar nova linha
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		_cNumOrc 	- Numero do orçamento 
			_cGrupo 	- Grupo de produto
			_cCodItem 	- Codigo produto
			_cLocal 	- Armazem
			_cCodSubst	- Codigo produto que substituira o original
			_cGrupoSubst- Grupo do produto que substituira o original	
			_nQtdeItem	- Qtde de item a ser processada
			_nQtdePrd   - Qtde do produto a ser substituida
			_nSaldoSB2  - Saldo atual do produto substituido
			_cTpSub     - Tipo de operação para subsititução ex 0=Normal;1=Substituido;2=Similar;3=Kit
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 		
@menu       Nao Informado
@return		_lRet		- Verdadeiro ou falso
@history    
/*/
Static Function ZPECF08PARC( _cNumOrc, _cGrupo, _cCodItem, _cLocal, _cCodSubst, _cGrupoSubst, _nQtdeItem, _nQtdePrd, _nSaldoSB2, _cTpSub, _lEncKit, _cPecKit )
	Local _lRet			:= .T.
	Local _nQtdReal
	//Local _nQtdeDif
	Local _nValorUnit
	Local _nTotal
	Local _nRegVS3
	Local _nSaldo       := 0
	Local _lInclui 		:= .F.
	Local _nItenNovo 	:= 0
	Default _nQtdePrd 	:= 0
	Default _cTpSub		:= ""
	Default _lEncKit	:= .F.	
	Default _cPecKit	:= "0"

	Begin Sequence
		If _nQtdePrd == 0						
			Aadd(_aMensAglu,"Quantidade a ser avaliada veio zerada no parametro, verificar para avaliar item Similar/Substituto !")
			_lRet  := .F.
			Break
		Endif
		//AJUSTAR TAMANHO 
		If Len(_cCodItem) < Len(VS3->VS3_CODITE)
			_cCodItem := _cCodItem + Space( Len(VS3->VS3_CODITE) - Len(_cCodItem) )  
		Endif
		If Len(_cCodSubst) < Len(VS3->VS3_CODITE)
			_cCodSubst := _cCodSubst + Space( Len(VS3->VS3_CODITE) - Len(_cCodSubst) )  
		Endif

		//Verificar se código Substituto ja esta gravado para não ocorrer duplicidade em itens DAC 29/04/2022
		//Procuto o item principal para guardar posição
		VS3->(DbSetOrder(2))  //VS3_FILIAL+VS3_NUMORC+VS3_GRUITE+VS3_CODITE+VS3_SEQUEN                                                                                                          
		If !VS3->(DbSeek(XFilial("VS3")+_cNumOrc+_cGrupo+_cCodItem))
			Aadd(_aMensAglu,"Não localizado item "+_cCodItem+" com grupo "+_cGrupo+ " nos itens do orçamento, verificar para avaliar item Similar/Substituto !")
			_lRet  := .F.
			Break
		Else
			_nRegVS3 := VS3->(Recno())
		EndIf
		//verifico se ja existe o item subistituto para incluir ou alterar
		If VS3->(DbSeek(XFilial("VS3")+_cNumOrc+_cGrupoSubst+_cCodSubst))
			//Monto consistencia para não perder armazem DAC 10/02/2022
			//SERA AVALIADO O ARMAZEM DO ITEM PRINCIPAL
			If Empty(_cLocal)   
				//nao deixar passar sem local pois interferira na reserva
				If Empty(VS3->VS3_LOCAL)
					Aadd(_aMensAglu,"Não informado armazem para o item " +_cCodSubst+ " para produto substituto sequencia "+VS3->VS3_SEQUEN+" !")
					_lRet := .F.
					Break
				EndIf
				_cLocal	:= VS3->VS3_LOCAL
			EndIf 
			_lRet := ALTERAITParcial( VS3->(Recno()), _cNumOrc, _cGrupo, _cCodItem, _cLocal, _cCodSubst, _cGrupoSubst, _nQtdeItem, _nQtdePrd, _nSaldoSB2, _cTpSub, _cPecKit,@_nSaldo )
			If ! _lRet
				Break
			Else
				_lInclui := .F.
			EndIf
		Else
			_lRet := INCLUIITParcial( _nRegVS3, _cNumOrc, _cGrupo, _cCodItem, _cLocal, _cCodSubst, _cGrupoSubst, _nQtdeItem, _nQtdePrd, _nSaldoSB2, _cTpSub, _cPecKit )
			If ! _lRet
				Break
			Else
				_nItenNovo := VS3->VS3_QTDITE
				_lInclui := .T.
			EndIf
		EndIf	
						
		//Após processar ajusto os valores dos campos
		VS3->(DbGoto(_nRegVS3))  //volta para o item principal
		//indica que ainda não é para encerrar o processo de kit somente no ultimo registro do kit que encerra pois o mesmo é relativo a quentidade total DAC 09/02/2022
		If _cTpSub == "3" .and. !_lEncKit  
			If RecLock("VS3",.F.)
				VS3->VS3_QTDINI		:= VS3->VS3_QTDITE
				VS3->(MsUnlock())
			EndIf	
			//_nQtdeItem -= _nQtdePrd
			Break
		Endif		
		//Caso tenha sido utilizado não poderá ser deduzido 
		//If !Empty(VS3->VS3_XTPSUB)  .and. _nQtdeItem >= _nQtdePrd
		//	_nQtdeItem -= _nQtdePrd
			//Break
		//Endif
		//Atualizar valores do item original deverá ser deduzido pois não foi atendido parcialmente
		_nQtdeItem 		-= _nQtdePrd
		//_nQtdeDif 		:= _nQtdePrd
		If !_lEncKit .and. _nQtdePrd <= VS3->VS3_QTDITE
			_nQtdReal 	:=  VS3->VS3_QTDITE - _nQtdePrd
		Else
			_nQtdReal 	:= 0
		EndIf	
		//Atualizar registro existente ao qual foi substituido
		If ! RecLock("VS3",.F.)
			_lRet := .F.
			Aadd(_aMensAglu,"Não foi possivel alterar registro na tabela VS3 (ZPECF08PARC) !")
			Break
		EndIf	
		If _nQtdReal <= 0 .and. (_nItenNovo +VS3->VS3_QTDITE) <> VS3->VS3_QTDINI
			VS3->(DbDelete())
			VS3->(MsUnlock())
			Break
		Else
			_nQtdReal := VS3->VS3_QTDITE	
		EndIf	
		//ajustar os valores
		//_nQtdeDif 		-= _nQtdReal
		//quando a quantidade for menor ou igual a zero excluir o registro principal
		//não deixar quantidade igual a zero causa problemas no processo DAC 07/02/2022
		_nValorUnit		:= U_XOFUNVTB(VS1->VS1_CLIFAT, VS1->VS1_LOJA, VS3->VS3_CODITE)
		//neste caso se não conseguiu achar DA1 assume o valor que ja estava anteriormente não necessário sair
		If _nValorUnit <= 0
			_nValorUnit 	:= VS3->VS3_VALPEC
			Aadd(_aMensAglu,"Não encontrado tabela de preço para o item " +VS3->VS3_CODITE+ " para efetuar desconto Seguradora, não foi aplicado desconto !")
			//no caso de alteração assumir o valor da tabela conforme passado sempre utilizar valor tabela
		Else  
			VS3->VS3_VALPEC	:= _nValorUnit
		EndIf
		_nTotal 			:= _nQtdReal * _nValorUnit
		VS3->VS3_QTDITE 	:= _nQtdReal
		//VS3->VS3_QTDPED := _nQtdReal
		//VS3->VS3_QTDINI := _nQtdReal
		If VS3->VS3_PERDES > 0
			VS3->VS3_VALDES := _nTotal * VS3->VS3_PERDES / 100
		Else
			VS3->VS3_VALDES := 0
		EndIf
		VS3->VS3_VALTOT 	:= _nTotal - VS3->VS3_VALDES 
		//Se zerar pode sair ja realizou ajustes posso apagar o item principal
		VS3->(MsUnlock())
		//atualizo a quantidade necessária
		//_nQtdeItem -= _nQtdePrd
	End Sequence
	/* calcular somente no envio
	If _lRet
		U_ORCCALFIS(_cNumOrc)
	EndIf
	*/
Return _lRet


//Altera VS3 com quantidade parcial caso ja exista um item de produto substituto
Static Function ALTERAITParcial( _nRegVS3Sub, _cNumOrc, _cGrupo, _cCodItem, _cLocal  , _cCodSubst, _cGrupoSubst, _nQtdeItem, _nQtdePrd, _nSaldoSB2, _cTpSub, _cPecKit ,_nSaldo)
	Local _lRet			:= .T.
	Local _nValorUnit
	Local _nTotal
	Local _nQtdeAtu
	Local _nQtdTot

	Default _cPecKit := "0"
	Default _nSAldo := 0

	Begin Sequence
		VS3->(DbGoto(_nRegVS3Sub))  //reposiciona VS3
		If ! RecLock("VS3",.F.)
			_lRet := .F.
			Aadd(_aMensAglu,"Não foi possivel Alterar registro de itens ref. tabela VS3 (ZPECF08PARC) !")
			Break
		Endif
		//guardo o quantidade atual
		_nQtdeAtu 			:= VS3->VS3_QTDITE
		If _cTpSub == "0"  //sendo somente parcial não somar pois no parcial altera o mesmo registro com a quantidade ja definida os demais soman-se
			_nQtdTot 		:= _nQtdePrd
		Else
			_nQtdTot 		:= _nQtdeAtu + _nQtdePrd   //somo o que ja tinha no VS3 com o que irei acrescentar para obtr nova quantidade
		Endif	
		//VERIFICO VALOR UNITÁRIO
		_nValorUnit	:= U_XOFUNVTB(VS1->VS1_CLIFAT, VS1->VS1_LOJA, _cCodSubst)
		//garantir que não fique zerado 
		If _nValorUnit <= 0
			Aadd(_aMensAglu,"Não encontrado tabela de preço para o item " +VS3->VS3_CODITE+ " para efetuar desconto Seguradora, não foi aplicado desconto !")
			_nValorUnit	:= VS3->VS3_VALPEC
		EndIf
		_nTotal 			:= _nQtdTot * _nValorUnit
		VS3->VS3_QTDITE		:= _nQtdTot
		_nSAldo := _nQtdTot
		//VS3->VS3_QTDINI		:= VS3->VS3_QTDITE
		VS3->VS3_VALPEC 	:= _nValorUnit 
		If VS3->VS3_PERDES > 0 
			VS3->VS3_VALDES := ROUND((_nTotal * VS3->VS3_PERDES / 100),2)
			VS3->VS3_VALTOT := 	_nTotal - VS3->VS3_VALDES
		Else
			VS3->VS3_VALTOT := _nTotal 
		Endif
		//Conforme Zé caso eja KIT gravar em branco para não multiplicar estes valores no rel de acompanhamento DAC 17/08/2022
		
		/* Zé solicitou deixar o código substituto DAC 18/08/2022
		If _cTpSub <> "3" 
			VS3->VS3_XITSUB	:= ""
		*/
		If Empty(VS3->VS3_XITSUB)
			VS3->VS3_XITSUB	:= _cCodItem
		EndIF	
		VS3->VS3_XTPSUB := _cTpSub	
		VS3->VS3_XDTSUB := Date()	
		VS3->VS3_XHRSUB := Time()	
		VS3->VS3_XAGLU	:= _cAglutina
		VS3->VS3_XUSUGL	:= RetCodUsr()
		VS3->VS3_PECKIT := _cPecKit
		//omente para KIT
		If _cTpSub == "3"
			VS3->VS3_CODKIT := _cCodItem
			VS3->VS3_GRUKIT	:= _cGrupo
		EndIf	
		If _cTpSub == "0"
			_cObs := "ITEM PRODUTO " +AllTrim(_cCodItem)+ " AJUSTADO QANTIDADE PARA ORCAMENTO "+_cNumOrc
			_cObs += " QTDE ANTERIOR "+AllTrim(STR(_nQtdeAtu))+ " ALTERADO PARA "+AllTrim(STR(_nQtdePrd))+" EM ITEM JA EXISTENTE"
			_cObs += " OPERAÇÃO PARCIAL"
		Else
			_cObs := "ITEM PRODUTO " +AllTrim(_cCodItem)+ " SUBSTITUIDO POR "+ AllTrim(_cCodSubst)+ " ORCAMENTO "+_cNumOrc
			_cObs += " QTDE ANTERIOR "+AllTrim(STR(_nQtdeAtu))+ " ACRESCENTADA "+AllTrim(STR(_nQtdePrd))+" EM ITEM SUBSTITUIDO JA EXISTENTE"
			_cObs += " OPERAÇÃO "+	If(_cTpSub=="1","SUBSTITUTO",;
									If(_cTpSub=="2","SIMILAR",;
									If(_cTpSub=="3","KIT",;
									"PARCIAL")))
		Endif	
		VS3->VS3_OBSAGL	:= 	Upper(_cObs) + CRLF + VS3->VS3_OBSAGL
		VS3->(MsUnlock())
		Aadd(_aMensAglu, Upper(_cObs))
	End Sequence
Return _lRet

//incluir registro novo  no VS3
Static Function INCLUIITParcial( _nRegVS3, _cNumOrc, _cGrupo, _cCodItem, _cLocal, _cCodSubst, _cGrupoSubst, _nQtdeItem, _nQtdePrd, _nSaldoSB2, _cTpSub, _cPecKit )
	Local _cAliasPesq	:= GetNextAlias()   
	Local _aEstruVS3 	:= VS3->(DbStruct())
	Local _aVS3			:= {}
	Local _aItem		:= {}
	Local _lRet			:= .T.
	Local _cObs			:= ""
	Local _nCount
	Local _nPos
	Local _nValorUnit
	Local _xValor
	Local _nTotal
	Local _cNumSeq

	Default _cPecKit := "0"

	Begin Sequence
		//Posicionar SB1
		SB1->(DbSetOrder(1))
		SB1->(MsSeek(XFilial("SB1")+AllTrim(_cCodSubst)))
		//Sera Incluído verificar a próxima sequencia
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	MAX(VS3.VS3_SEQUEN) AS SEQUEN
			FROM  %Table:VS3% VS3
			WHERE VS3.VS3_FILIAL   	= %xFilial:VS3% 
				AND VS3.VS3_NUMORC  = %Exp:_cNumOrc%
				AND VS3.%notDel%
		EndSQL	
		If (_cAliasPesq)->(Eof()) 
			Aadd(_aMensAglu,"Não encontrado itens para orçamento " +_cNumOrc+ " não sendo possivel montar o parcial !")
			_lRet := .F.
			Break
		EndIf
		//reposicionar o item que será clonado parcialmente
		VS3->(DbGoto(_nRegVS3))
		_cNumSeq := (_cAliasPesq)->SEQUEN	 
		_cNumSeq := Soma1(_cNumSeq)
		_aItem 	:= {}
		//CONFORME ALINHADO COM ZÉ SERA UTILIZADO PARA VALOR UNITARIO O DA TABELA DA1
		_nValorUnit	:= U_XOFUNVTB(VS1->VS1_CLIFAT, VS1->VS1_LOJA, _cCodSubst)
		//Caso não encontre tabela aborto processo
		If _nValorUnit <= 0
			Aadd(_aMensAglu,"Não encontrado tabela de preço para o item " +_cCodSubst+ " para efetuar desconto Seguradora, não foi aplicado desconto !")
			_lRet := .F.
			Break
		EndIf
		//totalizo pois necessitarei fazer algumas contas
		_nTotal := _nQtdePrd * _nValorUnit
		For _nPos := 1 To Len(_aEstruVS3)
			If AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_SEQUEN"
				_xValor := _cNumSeq
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_QTDITE"   //VS3_QTDPED | VS3_QTDINI"
				_xValor := _nQtdePrd
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_QTDEST"  //verificar se ira imprementar
				_xValor := _nSaldoSB2
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_LOCAL"  //verificar se ira imprementar
				_xValor :=  _cLocal 	//IIf(VS1->VS1_ORCACE$"1 ",SB1->B1_LOCPAD,GetMv("MV_RESITE"))
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_VALPEC"
				_xValor := _nValorUnit 
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_VALTOT"
				//_xValor := _nQtdePrd * _nValorUnit
				If VS3->VS3_PERDES > 0
					_xValor := _nTotal - ROUND((_nTotal * VS3->VS3_PERDES / 100),2)
				Else
					_xValor := _nTotal 
				EndIf	
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_VALDES" .And. VS3->VS3_PERDES > 0 
				_xValor := ROUND((_nTotal * VS3->VS3_PERDES / 100),2)
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_CODITE"
				_xValor	:= _cCodSubst
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_GRUITE"
				_xValor	:= _cGrupoSubst
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_XITSUB"
				/* Zé solicitou deixar o código DAC 18/08/2022
				If _cTpSub == "3"  //quando for KIT não gravar VS3_XITSUB senão ira multiplicar no relatório que é retirado conforme Zé 17/08/2022
					_xValor := ""
				Else		
				*/
				_xValor	:= VS3->(FieldGet(FieldPos(_aEstruVS3[_nPos,1])))
				If Empty(_xValor)
					_xValor	:= _cCodItem
				EndIF
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_XTPSUB"
				_xValor := _cTpSub	
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_XDTSUB"
				_xValor := Date()	
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_XHRSUB"
				_xValor := Time()	
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_OBSAGL"
				_cObs += "ITEM PRODUTO " +AllTrim(_cCodItem)+ " SUBSTITUIDO POR "+ AllTrim(_cCodSubst)+ " ORCAMENTO "+_cNumOrc
				_cObs += " OPERAÇÃO "+	If(_cTpSub=="1","SUBSTITUTO",;
										If(_cTpSub=="2","SIMILAR",;
										If(_cTpSub=="3","KIT",;
										"PARCIAL")))
				_xValor := _cObs	
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_XAGLU" 
				_xValor := _cAglutina
			//para indicar que é kit - Peca faz parte de um kit - 0=Não;1=Mandatório;2=Correlato  
			//ElseIf _cTpSub == 3 .And. AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_PECKIT"
			//	_xValor :=  
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_XUSUGL"
				_xValor := RetCodUsr()	
			//a quantidade do KIT tem que ser alterada , conforme solicitação Zé 17/08/2022	
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_QTDINI" .and. _cTpSub <> "3"
				_xValor := _nQtdePrd
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_QTDINI" .and. _cTpSub == "3"
				_xValor := 0
			//quando for kit gravar ódigo do item como substituto	
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_CODKIT" .and. _cTpSub == "3"
				_xValor := _cCodItem
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_GRUKIT" .and. _cTpSub == "3"
				_xValor := _cGrupo
			ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_PECKIT" 
				_xValor := _cPecKit
			//ElseIf AllTrim(_aEstruVS3[_nPos,1]) $ "VS3_QTDINI" 
			Else
				_xValor	:= VS3->(FieldGet(FieldPos(_aEstruVS3[_nPos,1])))
			EndIf	
			Aadd(_aItem, {_aEstruVS3[_nPos,1],_xValor} )
		Next
		If Len(_aItem) == 0
			Aadd(_aMensAglu,"Não foi possivel carregar dados dos itens para orçamento " +_cNumOrc+ " não sendo possivel montar o parcial, comunicar ADM Sistemas !")
			_lRet := .F.
			Break
		EndIf

		Aadd(_aVS3,_aItem )
		//Inclui novo registro
		For _nCount := 1 To Len(_aVS3)
			If ! RecLock("VS3",.T.)
				_lRet := .F.
				Aadd(_aMensAglu,"Não foi possivel incluir registro na tabela VS3 (ZPECF08PARC) !")
				Break
			Endif
			For _nPos := 1 To Len(_aEstruVS3)
				VS3->(FieldPut(_nPos, _aVS3[_nCount, _nPos,2]))
			Next	
			VS3->(MsUnlock())
		Next
		Aadd(_aMensAglu, Upper(_cObs))

	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 
Return _lRet




/*
SELECT ROW_NUMBER() OVER(ORDER BY VS1.VS1_XTPPED, VS1.VS1_XTPTRA ASC) AS Linha
        ,A1.A1_CGC 
        , VS1.VS1_FORPAG--, E4_DESCRI
        , VS1.VS1_XTPPED--, VX5.VX5_DESCRI AS TIPO_PEDIDO
        , VS1.VS1_XTPTRA--, TIPOS_MODAIS.VX5_DESCRI AS TIPO_MODAL
        , VS3.VS3_CODITE
        , SUM(VS3.VS3_QTDITE) AS QTD_TOTAL
FROM ABDHDU_DES.VS1020 VS1
LEFT JOIN ABDHDU_DES.SA1020 A1 ON A1.A1_COD = VS1.VS1_CLIFAT AND A1.A1_LOJA = VS1.VS1_LOJA
LEFT JOIN ABDHDU_DES.VX5020 VX5 ON VX5.D_E_L_E_T_ = ' ' AND VX5.VX5_CHAVE = 'Z00' AND VX5.VX5_CODIGO = VS1.VS1_XTPPED
--LEFT JOIN ABDHDU_DES.SE4020 E4 ON E4.D_E_L_E_T_ = ' '  AND E4.E4_CODIGO = VS1.VS1_FORPAG
--LEFT JOIN ABDHDU_DES.VX5020 MODAIS ON MODAIS.D_E_L_E_T_ = ' ' AND MODAIS.VX5_CHAVE = 'Z01' AND MODAIS.VX5_CODIGO = VS1.VS1_XTPPED
--LEFT JOIN TIPOS_MODAIS ON TIPOS_MODAIS.CODIGO = VS1.VS1_XTPTRA
LEFT JOIN ABDHDU_DES.VS3020 VS3 ON VS3_FILIAL = VS1_FILIAL AND VS3_NUMORC = VS1_NUMORC
LEFT JOIN ABDHDU_DES.SB2020 B2 ON B2_FILIAL = VS1_FILIAL AND B2_COD = VS3.VS3_CODITE AND B2_LOCAL = '01'
WHERE	VS1.D_E_L_E_T_ = ' ' 
	AND VS1_FILIAL = '2020012001' 
	AND VS1.VS1_STATUS IN ('0') 
	AND VS1.VS1_TIPORC = '1'
    AND B2.B2_QATU > 0 -- <= '0' SEGUE PARA REGRA DE: ITEM SUBSTITUTO, ITEM RELACIONADO, KIT E, CASO NO CASO DE NÃO SER ATENDIDO GERAR BACKORDER DO TOTAL OU SALDO DO ITEM
GROUP BY A1.A1_CGC, VS1.VS1_FORPAG, VS1.VS1_XTPPED, VS1.VS1_XTPTRA, VS3.VS3_CODITE, VS3.VS3_QTDITE--, B2.B2_QATU -- TIPOS_MODAIS.TIPO_MODAL,
ORDER BY VS1.VS1_XTPPED, VS1.VS1_XTPTRA

*/



//Funcionalidade responsavel pelo retorno do orçamento a fase principal
//chamado pelo PE OXA011BOT
User Function ZPF8REV1()
	Local _cFase := If(VS1->VS1_STATUS=="F","A FATURAR",;
					If(VS1->VS1_STATUS=="C","CANCELADO",;
					"INICIAL"))
	Begin Sequence
		//If VS1->VS1_STATUS $ "X_C_0"  //Alterado conforme solicitação JC - DAC 14/10/2022
		If VS1->VS1_STATUS $ "X_0"
			MSGINFO( "Orçamento não pode ser retornado para fase inicial pois fase do mesmo esta "+ _cFase+ " !!! ", "[ZPECF008] - Atenção" )
			Break
		EndIf
		//Conforme solicitado JC - DAC 14/10/2022 
		If VS1->VS1_STATUS $ "C"
			If !MsgYesNo( "Orçamento foi Cancelado " + VS1->VS1_NUMORC + " Retornar a Fase Inicial  ? " )
				Break
			Else
				RetCancel()
				Break			
			EndIf
		ElseIf !MsgYesNo( "Deseja retornar Fase do orçamento "+VS1->VS1_NUMORC+" para Fase Inicial  ? " )
			Break
		EndIf
		U_XRETSTVS1(VS1->VS1_NUMORC, .T. /*_lTela*/)		
	End Sequence
Return Nil

//Volta status do orçamento para "0" 
Static Function RetCancel()
	RecLock('VS1',.F.)
	VS1->VS1_STATUS := '0'
	VS1->(MsUnlock())
Return Nil



//opção para atualizar reservas 
Static Function XTRANSRERVA()
	Local _lReserva := .T.
	Local _lParcial := .F. 
	Local _cArmazem := "01"
	Local _aPar     := {}
	Local _aSays  	:= {}
	Local _aButtons	:= {}
	Local _aRet    	:= {}
	Local _aRegVS3	:= {}
	Local _nRet		:= 0
	Local _cTitle	:= "Transferência de Reservas"
	Local _cNumOrc	:= VS1->VS1_NUMORC
	Local _cMsg

	Begin Sequence
		If VS1->VS1_STARES 	== "1"  //Reservado
			_lReserva := .F.
		ElseIf VS1->VS1_STARES 	== "3"  //Reservado
			_lReserva := .T.
		ElseIf VS1->VS1_STARES 	== "2"  //Parcial
			_lParcial := .T.	
		Endif

		If _lReserva
			_cOrigem 	:= _cArmazem
			_cDestino	:= AllTrim(GETMV("MV_RESITE"))    //'61' Codigo do Armazem de Pecas RESERVADAS  
		Else
			_cOrigem 	:= AllTrim(GETMV("MV_RESITE"))	
			_cDestino	:= If(Empty(_cArmDes) , _cArmazem 					, _cArmDes )   //'61' Codigo do Armazem de Pecas RESERVADAS  
		Endif
		If Empty(_cOrigem) .or. Empty(_cDestino)
			AAdd(_aMsg,"Não informado armazem origem e ou destino para orçamento " +_cNumOrc+ ", não será realizada a Reserva comunicar ADM Sistemas!!! ")
			_lRet := .F.
			Break
		EndIf

		While .T.
			If _lReserva .and. !_lParcial
				aAdd(_aPar,{3,OemToAnsi("Retirar Reserva") ,2 ,{"1=Sim ","2=Não"}	,60,"",.F.})  
			ElseIf !_lReserva .and. !_lParcial
				aAdd(_aPar,{3,OemToAnsi("Incluir Reserva") ,2 ,{"1=Sim ","2=Não"}	,60,"",.F.})  
			ElseIf _lParcial
				aAdd(_aPar,{3,OemToAnsi("Retirar/Incluir Reservas Parcial") ,2 ,{"Retirar Reservas","Incluir Reservas"}	,120,"",.F.})  
			Endif
			Aadd(_aPar,{1,OemToAnsi("Armazém Origem") 	, _cOrigem	,"@!"		,".T."	,"NNR" 	,".T."	,50,.T.}) 
			Aadd(_aPar,{1,OemToAnsi("Armazém Destino") 	, _cDestino	,"@!"		,".T."	,"NNR" 	,".T."	,50,.T.}) 
			
			AADD(_aSays,OemToAnsi("Este Programa tem  como  Objetivo  realizar a transferência de Reservas")) 
			AADD(_aSays,OemToAnsi("Permitindo que o Usuário realize ou retire a reserva de acordo com Armazem"))  
			AADD(_aSays,OemToAnsi("Verificando se o orçamento possui ou não reserva")) 
			AADD(_aSays,OemToAnsi(""))
			AADD(_aSays,OemToAnsi("Clique no botão Parâmetros para alterar as definições da rotina."))  
			AADD(_aSays,OemToAnsi("Depois clique no Botão OK.")) 
			AADD(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
			AADD(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
			AADD(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,"XTRANSRERVA",.T.,.T.) 	}})

			FormBatch( "Transferência de Reservas", _aSays, _aButtons )
			If _nRet <> 1
				MSGINFO(OemToAnsi("Necessário informar os parâmetros"),OemToAnsi("Atenção")) 
				Loop
			Endif	
			If Len(_aRet) == 0
				MSGINFO(OemToAnsi("Necessário informar os parâmetros"),OemToAnsi("Atenção")) 
				Loop 
			Endif
	
			_cMsg	:= ""
			//quando for parcial deverá incluir o motivo para o ajuste parcial
			If !_lParcial
				_nOpc := _aRet[3]
				If _nOpc <= 0 .and. _nOpc > 2
					MSGINFO(OemToAnsi("Problemas na seleção contate o ADM Sistema"),OemToAnsi("Atenção"))  
					Loop
				Endif
				If _nOpc == 1
					_lReserva	:= .F.
				Else
					_lReserva	:= .T.
				EndIf	
				_cMsg := 	If(_nOpc==1	,"Deseja retirar as reservas dos itens que estão reservados neste orçamento parcial " ;
										,"Deseja incluir as reservas dos itens que estão reservados neste orçamento parcial " )

			ElseIf _lReserva 
				_cMsg := 	"Deseja retirar reservas"
			Else 
				_cMsg := 	"Deseja Incluir reservas"
			EndIf
			If !MsgYesNo( "Confirma "+_cMsg+" - Orçamento "+_cNumOrc+" ?" )
				MSGINFO(OemToAnsi("Necessário confirmação dos parâmetros"),OemToAnsi("Atenção")) 
				Loop 
			Endif
			NNR->(DbSetOrer(1)) //NNR_FILIAL+NNR_CODIGO                                                                                                                                           
			If !NNR->(DbSeek(XFilial("NNR")+_cOrigem))
				MSGINFO(OemToAnsi("Armazém "+_cOrigem+" não cadastrado !"),OemToAnsi("Atenção"))  
				Loop
			EndIf	
			If !NNR->(DbSeek(XFilial("NNR")+_cDestino))
				MSGINFO(OemToAnsi("Armazém "+_cDestino+" não cadastrado !"),OemToAnsi("Atenção"))  
				Loop
			EndIf	
			//chegando aqui posso sair
			Exit
		EndDo
		If _nOpc <> 1
			Break
		EndIf	


		VS3->(DbSetOrder(1))
		If !VS3->(DbSeek(XFilial("VS3")+_cNumOrc))
			MSGINFO(OemToAnsi("Não encontrados itens para o orçamento "+_cNumOrc+"  !"),OemToAnsi("Atenção"))  
			Break
		EndIf		

		While VS3->(!Eof()) .and. VS3->VS#_FILIAL == XFilial("VS3") .and. VS3->VS3_NUMORC == _cNumOrc
			//Qaundo for parcial e for retira tem que ter a reserva
			If _lParcial .and. 	aRet[1] == 1 .and. (  VS3->VS3_RESERV == "1" .or. !Empty(VS3->VS3_DOCSDB))  //foi incluído VS3_DOCSDB pois podem ter dados antigos onde somente era gravado este registro
				AAdd(_aRegVS3,VS3->(Recno()))
			//Qaundo for parcial e for retira tem que ter a reserva
			ElseIf _lParcial .and. 	aRet[1] == 2 .and. (  VS3->VS3_RESERV <> "1" .or. Empty(VS3->VS3_DOCSDB))  //foi incluído VS3_DOCSDB pois podem ter dados antigos onde somente era gravado este registro
				AAdd(_aRegVS3,VS3->(Recno()))
			Else
				AAdd(_aRegVS3,VS3->(Recno()))
			EndIf	
			VS3->(DbSkip())
		EndDo	
		/*
		If Len(_aRegVS3) > 0
			XRESCAOAPEC(_cNumOrc, _lReserva, _aRegVS3, _cOrigem, _cDestino, .T. )
						VS3->VS3_DOCSDB := _cDocumento
						VS3->VS3_RESERV := "1"
						VS3->VS3_RESERV	:= VS3->VS3_QTDITE
		*/
	End Sequence
Return _lRet




//==================================================================
//--DAC
//dispensa dados que não serão utilizados sem saldo

Static Function ZPEC08PROVisorio(_cAglutina, _cWhere, _cLocal, _cConectWis, _cCdEmpWIS)
	Local _lRet 		:= .T.
	Local _cQuery		:= ""
	Local _cObs			:= "BYPASS ONDA "+_cAglutina 
	Local _nStatus

	Begin Sequence
	//	_cQuery += "DECLARE"
	//	_cQuery += "i NUMBER 
		_cQuery += "UPDATE  " +RetSqlName("VS1")+ " VS1" + CRLF
		_cQuery += "SET 	VS1.VS1_XAGLU 	= '" +_cAglutina+ "'" + CRLF
		_cQuery += " 	,	VS1.VS1_XONDA 	= '" +_cAglutina+ "'" + CRLF
		_cQuery += " 	,	VS1.VS1_XONDDT  = '" +DtOS(Date())+ "'" + CRLF
		_cQuery += " 	,	VS1.VS1_XONDHS  = '" +SubsTr(Time(),1,5)+ "'" + CRLF	
		_cQuery += " 	,	VS1.VS1_OBSAGL 	=  RAWTOHEX('"+_cObs+ chr(13) + chr(10) +"' ||  NVL(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(VS1.VS1_OBSAGL , 2000, 1)),' ') )" + CRLF   
		_cQuery += "WHERE VS1.D_E_L_E_T_  = ' '" + CRLF
		_cQuery += 		_cWhere
		_cQuery += " 	AND VS1.VS1_XBO = 'S' "+  CRLF	
		_cQuery += "	AND NOT EXISTS ( ( SELECT VS3.VS3_NUMORC" + CRLF 
		_cQuery += "		FROM  " +RetSqlName("VS3")+ " VS3" + CRLF 
		_cQuery += "		LEFT JOIN  " +RetSqlName("SB2")+ " B2VS3 	ON B2VS3.B2_FILIAL 	=  '" +XFilial("SB2")+ "'  AND B2VS3.B2_COD		= VS3.VS3_CODITE AND B2VS3.B2_LOCAL =  '" +_cLocal+ "' AND B2VS3.B2_QATU > 0 AND B2VS3.D_E_L_E_T_= ' '" + CRLF 
		_cQuery += "		LEFT JOIN  "+_cConectWis+ " WISVS3 ON RTRIM(LTRIM(WISVS3.CD_PRODUTO)) = RTRIM(LTRIM(VS3.VS3_CODITE)) 		AND WISVS3.CD_EMPRESA = " +_cCdEmpWIS + CRLF

		_cQuery += "		LEFT JOIN  " +RetSqlName("VPD")+ " VPD   	ON VPD.VPD_FILIAL  	=  '" +XFilial("VPD")+ "'  AND VPD.VPD_COD  	= VS3.VS3_CODITE AND VPD.D_E_L_E_T_	= ' ' " + CRLF
		_cQuery += "		LEFT JOIN  " +RetSqlName("SB2")+ " B2VPD 	ON B2VPD.B2_FILIAL 	=  '" +XFilial("SB2")+ "'  AND B2VPD.B2_COD 	= VPD.VPD_CODREL AND B2VPD.B2_LOCAL =  '" +_cLocal+ "' AND B2VPD.B2_QATU > 0 AND B2VPD.D_E_L_E_T_= ' '" + CRLF
		_cQuery += "		LEFT JOIN  "+_cConectWis+ " WISVPD ON RTRIM(LTRIM(WISVPD.CD_PRODUTO)) = RTRIM(LTRIM(VPD.VPD_CODREL)) 		AND WISVPD.CD_EMPRESA = " +_cCdEmpWIS + CRLF
		//Ajuste verificado que a pesquisa pode funcionar pela relação do codigo e ou do relacionamento 
		_cQuery += "		LEFT JOIN  " +RetSqlName("VPD")+ " VPDA   	ON VPDA.VPD_FILIAL 	=  '" +XFilial("VPD")+ "'  AND VPDA.VPD_CODREL 	= VS3.VS3_CODITE AND VPDA.D_E_L_E_T_	= ' ' " + CRLF
		_cQuery += "		LEFT JOIN  " +RetSqlName("SB2")+ " B2VPDA 	ON B2VPDA.B2_FILIAL	=  '" +XFilial("SB2")+ "'  AND B2VPDA.B2_COD 	= VPDA.VPD_COD AND B2VPDA.B2_LOCAL =  '" +_cLocal+ "' AND B2VPDA.B2_QATU > 0 AND B2VPDA.D_E_L_E_T_= ' '" + CRLF
		_cQuery += "		LEFT JOIN  "+_cConectWis+ " WISVPDA ON RTRIM(LTRIM(WISVPDA.CD_PRODUTO)) = RTRIM(LTRIM(VPDA.VPD_COD)) 	AND WISVPDA.CD_EMPRESA = " +_cCdEmpWIS + CRLF

		_cQuery += "		LEFT JOIN  " +RetSqlName("VE9")+ " VE9   	ON VE9.VE9_FILIAL  	=  '" +XFilial("VE9")+ "'  AND VE9.VE9_ITEANT 	= VS3.VS3_CODITE AND VE9.D_E_L_E_T_= ' ' " + CRLF
		_cQuery += "		LEFT JOIN  " +RetSqlName("SB2")+ " B2VE9 	ON B2VE9.B2_FILIAL 	=  '" +XFilial("SB2")+ "'  AND B2VE9.B2_COD 	= VE9.VE9_ITENOV AND B2VE9.B2_LOCAL =  '" +_cLocal+ "' AND B2VE9.B2_QATU > 0 AND B2VE9.D_E_L_E_T_= ' '"+ CRLF
		_cQuery += "		LEFT JOIN  "+_cConectWis+ " WISVE9 ON RTRIM(LTRIM(WISVE9.CD_PRODUTO)) = RTRIM(LTRIM(VE9.VE9_ITEANT)) 		AND WISVE9.CD_EMPRESA = " +_cCdEmpWIS + CRLF
		_cQuery += "		LEFT JOIN  " +RetSqlName("VE8")+ " VE8 		ON VE8.VE8_FILIAL 	=  '" +XFilial("VE8")+ "'  AND VE8.VE8_CODKIT 	= VS3.VS3_CODITE AND VE8.D_E_L_E_T_= ' ' "+  CRLF
		_cQuery += "		LEFT JOIN  " +RetSqlName("SB2")+ " B2VE8 	ON B2VE8.B2_FILIAL 	=  '" +XFilial("SB2")+ "'  AND B2VE8.B2_COD 	= VE8.VE8_CODITE AND B2VE8.B2_LOCAL =  '" +_cLocal+ "' AND B2VE8.B2_QATU > 0 AND B2VE8.D_E_L_E_T_= ' '"+ CRLF
		_cQuery += "		LEFT JOIN  "+_cConectWis+ " WISVE8 ON RTRIM(LTRIM(WISVE8.CD_PRODUTO)) = RTRIM(LTRIM(VE8.VE8_CODKIT )) 		AND WISVE8.CD_EMPRESA = " +_cCdEmpWIS + CRLF
		_cQuery += "		WHERE 	VS3.VS3_FILIAL = VS1.VS1_FILIAL"+  CRLF 
		_cQuery += "			AND VS3.VS3_NUMORC = VS1.VS1_NUMORC"+  CRLF
		_cQuery += "			AND 	VS3.D_E_L_E_T_ = ' '"+  CRLF
		_cQuery += "			AND (	( 	NVL( B2VS3.B2_QATU - B2VS3.B2_RESERVA - B2VS3.B2_QACLASS , 0) > 0 AND NVL( WISVS3.QT_ESTOQUE - WISVS3.QT_RESERVA_SAIDA, 0 )  > 0)"+  CRLF
		_cQuery += "				OR 	(	NVL( B2VPD.B2_QATU - B2VPD.B2_RESERVA - B2VPD.B2_QACLASS , 0) > 0 AND NVL( WISVPD.QT_ESTOQUE - WISVPD.QT_RESERVA_SAIDA, 0 )  > 0)"+  CRLF
		//Ajuste verificado que a pesquisa pode funcionar pela relação do codigo e ou do relacionamento 
		_cQuery += "				OR 	(	NVL( B2VPDA.B2_QATU - B2VPDA.B2_RESERVA - B2VPDA.B2_QACLASS , 0) > 0 AND NVL( WISVPDA.QT_ESTOQUE - WISVPDA.QT_RESERVA_SAIDA, 0 )  > 0)"+  CRLF
		_cQuery += "				OR 	(	NVL( B2VE9.B2_QATU - B2VE9.B2_RESERVA - B2VE9.B2_QACLASS , 0) > 0 AND NVL( WISVE9.QT_ESTOQUE - WISVE9.QT_RESERVA_SAIDA, 0 )  > 0)"+  CRLF
		_cQuery += "				OR  NVL( B2VE8.B2_QATU,0 ) > 0 ) "+  CRLF
		_cQuery += "))"+  CRLF
	//	_cQuery += "i := SQL%rowcount"
		//TcLink()
		_nStatus := TcSqlExec(_cQuery)
		if (_nStatus < 0)
			_lRet := .F.
			MSGINFO("Erro ao gravar Status na tabela VS1 "+ TCSQLError() , "[ZPECF0008] - Atenção" )
		Endif
		TCRefresh("VS1")
		//TcUnlink()
	End Sequence
Return _lRet





//retorna as ondas que estão rodando
//Verificar se existe a possibilidade de utilizar a função http://tdn.totvs.com/pages/viewpage.action?pageId=6814895 
/* Não esta sendo utilizada
A Funcao MayIUseCode tem o objetivo de reservar uma palavra , ou seja quando uma estacao reserva uma palavra, a outra nao conseguirah usar.
Podem ser reservadas ateh 20 palavras simultaneamente e estas palavras sao liberadas automaticamente nos seguintes pontos :
- Volta para o Menu
- VOlta para a mbrwose ou MarkBrowse
- no End Transaction
*/

Static Function ZPECF08OPEnonda( _cOnda, _aOndaPrc, _lJob ) 
	Local _cDir     := AllTrim(SuperGetMV( "CMV_PECXXX"  ,,"\sigapec\onda\prc" ))       //processamento
	Local _cDirDocs := MsDocPath()
	Local _cExtenc	:= "ond"
	Local _cRef		:= "ONDASIGAPECPRC"
	Local _aMens	:= {}

	Local _nPos
	Local _nHd1
	Local _cArq		
	//Local _nHandle
	Local _aFiles

	//Local _cPath 	 := AllTrim(GetTempPath())  //define o diretório na maquina cliente onde será gravado o arq excell "C:\Users\DAC\AppData\Local\Temp\"

	Default _lJob	:= .T.

	Begin Sequence  
		_aOndaPrc	:= {}
		If SubsTr(_cDir,1,1) <> "\"
			_cDir := "\"+_cDir	
		Endif
		If SubsTr(_cDir,Len(_cDir),1) <> "\"
			_cDir := _cDir+"\"	
		Endif

		If !U_XVALIDPasta( {_cDirDocs+_cDir}, _lJob )
			AAdd(_aMens, "ZPECF008 [ZPECF08OPEnonda] - Não foi possivel criar pasta "+_cDirOri+" e nem recriar a mesmapara Json para o Pedido "+_cPedido)
			Break
		Endif	
		_cDirOri := _cDirDocs+_cDir
		If !ExistDir( _cDirOri )
			AAdd(_aMens, "ZPECF008 [ZPECF08OPEnonda] - Não foi possivel criar pasta "+_cDirOri+" para Json para o Pedido "+_cPedido)
			Break
		EndIf 
		_cArq := _cOnda+_cRef+DtOS(Date())+SubsTr(Time(),1,2)+SubsTr(Time(),4,2)
		//Se for para gravar arquivo
		_cArq := _cArq +"."+_cExtenc
		_nHd1 := FCreate(_cDirOri+_cArq)	                            
		If _nHd1 == -1              
			AAdd(_aMens, "ZPECF008 [ZPECF08OPEnonda] - Nao foi possivel criar o arquivo de Log para arquivo "+_cDirOri+_cArqAW+". Verifique com ADM Sistema!")
			Break
		Endif

		/*
		If File(_cDirOri+_cArq)
			//tenta abrir para verificar se esta exclusivo
			_nHandle  := FOPEN(_cDirOri+_cArq, FO_READWRITE)
			If _nHandle == -1
				_lRet := .F.
				Break
			Endif	
		Endif	
		*/

		_aFiles := DIRECTORY(_cDirOri + "*."+_cExtenc )
		If Len(_aFiles) > 0
			For _nPos := 1 to Len(_aFiles)
				//Se não conseguir apagar é porque não terminou rodou a onda e não devo utilizar estes arquivos no processo
				If Ferase(_aFiles(_aFiles)) == -1
					_nPos := AT(_cRef, _aFiles[_nPos])
		
					If _nPos > 0 
						Aadd(_aOndaPrc, SubsTr(_aFiles[_nPos], 1, _nPos -1))
					Endif	
				Endif
			Next

		Endif
	End Sequence
Return _lRet



//função responsável pela contagem de picking enviado para RGLOG
Static Function XCONTERGLog( _cAglutina )
	Local _nEnviados 	:= 0
	Local _cAliasPesq 	:= GetNextAlias()

	Begin Sequence
		BeginSql Alias _cAliasPesq 
			SELECT 	NVL(COUNT(VS1.VS1_NUMORC),0) NREGENVIADOS
			FROM %table:VS1% VS1
			WHERE 	VS1.VS1_FILIAL 	= %XFilial:VS1%
				AND VS1.VS1_XAGLU  	= %Exp:_cAglutina%
				AND VS1.VS1_XPICKI <> ' '
				AND VS1.VS1_XDTEPI <> ' '
				AND VS1.%notDel%		 
		EndSql
		If (_cAliasPesq)->(!Eof()) 	
			_nEnviados := (_cAliasPesq)->NREGENVIADOS
		EndIf	
	End Sequence
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif  
Return _nEnviados


//função responsável pela contagem de picking não enviado para RGLOG devido a algum problema
Static Function XCONTIRGLog( _cAglutina )
	Local _nCount 		:= 0
	Local _cAliasPesq 	:= GetNextAlias()

	Begin Sequence
		BeginSql Alias _cAliasPesq 
			SELECT 	NVL(COUNT(VS1.VS1_NUMORC),0) NINCONSISTENCIA
			FROM %table:VS1% VS1
			WHERE 	VS1.VS1_FILIAL 	= %XFilial:VS1%
				AND VS1.VS1_XAGLU  	= %Exp:_cAglutina%
				AND VS1.VS1_XPICKI <> ' '
				AND VS1.VS1_XDTEPI 	= ' '
				AND VS1.%notDel%		 
		EndSql
		If (_cAliasPesq)->(!Eof()) 	
			_nEnviados := (_cAliasPesq)->NINCONSISTENCIA
		EndIf	
	End Sequence
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif  
Return _nCount


//função responsável por retornar a quantidade dos registros bypass
Static Function XCONTBYPAss (_cAglutina )
	Local _nEnviados 	:= 0
	Local _cAliasPesq 	:= GetNextAlias()

	Begin Sequence
		BeginSql Alias _cAliasPesq 
			SELECT 	NVL(COUNT(VS1.VS1_NUMORC),0) NREGENVIADOS
			FROM %table:VS1% VS1
			WHERE 	VS1.VS1_FILIAL 	= %XFilial:VS1%
				AND VS1.VS1_XAGLU 	= %Exp:_cAglutina%	
				AND VS1.VS1_XONDA 	= %Exp:_cAglutina%
				AND VS1.%notDel%		 
		EndSql
		If (_cAliasPesq)->(!Eof()) 	
			_nEnviados := (_cAliasPesq)->NREGENVIADOS
		EndIf	
	End Sequence
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif  
Return _nEnviados



/*/{Protheus.doc} ZPECF08LCC
Liberação de Limite de Crédito Parcial
@since      06/12/2022
@param      _cNumOrc 	- Numero de Orçamento
			_nLimAvalia - Limite parcial para liberação
			_aBackOrder - Registros ja grvados para backorder caso os tenha
@return     _lRet
@author     DAC Denilso
@version    12.1.17 / Superior
@project	GRUPO CAOA - Liberação de Limite de Crédito Parcial
@since      06/12/2022
@ Obs		
@history    06/12/2022 DAC	- PEC031 - Limite de Credito - Revitalização 
			Tratar limite de crédito Parcial avaliando se bloqueia e ou libera parcialment
			21/03/2022 DAC	- GAP FIN100 - Revitalização Limite de Crédito V2	
			Incluído fator para calculo percentual do orçamento para liberação de crédito parcial
/*/

Static Function ZPECF08LCC(_cNumOrc,_nLimAvalia, _aBackOrder)
Local _lAvaliaOrc   := SuperGetMV( "CMV_PEC032"  ,,.F. )   //Avalia limite de crédito por orçamento na Onda baseado pelos valores mais baixos e pendentes     
Local _lAvaliaItem  := SuperGetMV( "CMV_PEC033"  ,,.F. )   //Avalia limite de crédito por itens orçamento Onda baseado pelos valores mais baixos e pendentes     
Local _lRet			:= .T. 

Default _cNumOrc 	:= ""
Default _nLimAvalia	:= 0
Default _aBackOrder	:= {}
	
Begin Sequence
	//Se não existe saldo não validar processo
	If _nLimAvalia <= 0
		_lRet	:= .F.
		Break
	Endif

	//Não faz validações de limite de crédito
	If !_lAvaliaOrc .And. !_lAvaliaItem
		_lRet	:= .F.
		Break
	Endif
	//Caso não esteja bloqueao nçao validar
	If VS1->VS1_STATUS <> "3"
		_lRet	:= .F.
		Break
	EndIf
	//tem que informar o numero do orçamento senão é erro
	If Empty(_cNumOrc)
		Aadd(_aMensAglu,"[ZPECF08LCC] Orçamento  não Informado na validação do limite de crédito !")
		_lRet := .F.
		Break
	EndIf
	
	//Reposicionar orçamento, caso não localize aborta
	If AllTrim(_cNumOrc) <> AllTrim(VS1->VS1_NUMORC)
		VS1->(DbSetOrder(1))
		If !VS1->(DbSeek(XFilial("VS1")+_cNumOrc))
			Aadd(_aMensAglu,"[ZPECF08LCC] Orçamento "+ AllTrim(_cNumOrc) +" não localizado na calidação do limite de crédito !")
			_lRet := .F.
			Break
		Endif
	Endif
	
	//Verificar o valor total do orçamento em relação ao limite de crédito
	If _lAvaliaOrc 		
		_lRet 	:= ZPECF8LCAO(_cNumOrc, _nLimAvalia, _aBackOrder)
	EndIf
	//Verifica por item e pode realizar o item parcial
	//If _lAvaliaItem  .and. (!_lAvaliaOrc .or. !_lRet)
	If !_lRet .and. _lAvaliaItem   
		_lRet	:= ZPECF8LCAI(_cNumOrc, _nLimAvalia, VS1->(Recno()), _aBackOrder)
	EndIf
	If !_lRet
		Aadd(_aMensAglu,"[ZPECF08LCC] Não foi possivel utilizar crédito parciarl de "+AllTrim(STR(_nLimAvalia))+", não se enquadrando aos valores existentes !")
		Break
	EndIf
End Sequence
Return _lRet


/*/{Protheus.doc} ZPECF8LCAO
Avaliação de limite de crédito por orçamento
@since      06/12/2022
@param      _cNumOrc 	- Numero de Orçamento
			_nLimAvalia - Limite parcial para liberação
			_aBackOrder - Registros ja grvados para backorder caso os tenha
@return     _lAvalia
@author     DAC Denilso
@version    12.1.17 / Superior
@project	GRUPO CAOA - Liberação de Limite de Crédito Parcial
@since      06/12/2022
@ Obs		Foi implementado o fator de calculo percentual para avaliar o limite nesta funcionalidade, 
			pois a mesma tem que ser para todo o orçamento não podendo ser utilizada na avaliação de itens
@history    06/12/2022 DAC	- PEC031 - Limite de Credito - Revitalização 
			Tratar limite de crédito Parcial avaliando se bloqueia e ou libera parcialment
			21/03/2022 DAC	- GAP FIN100 - Revitalização Limite de Crédito V2	
			Incluído fator para calculo percentual do orçamento para liberação de crédito parcial
/*/

Static Function ZPECF8LCAO(_cNumOrc, _nLimAvalia, _aBackOrder)
Local _cAliasPesq   := GetNextAlias()
Local _nRedBO       := SuperGetMV("CMV_PEC035",,100)
Local _lAvalia		:= .T.
Local _cObs			:= ""
Local _nValPrd 		:= 0
Local _nFatorLimite	:= 0

Begin Sequence
	_cObs 	:= "[ZPECF08LCC] ORÇAMENTO COM LIMITE DE CRÉDITO "+AllTrim(Transform(_nLimAvalia,PesqPict("VS1","VS1_VTOTNF ")))+" AVALIANDO LIBERAÇÃO POR LIMITE DE CRÉDITO"
	_cObs 	+= CRLF
	//Necessario fazer o select e avaliar se gerou orçamentos que atendam os limites
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT NVL(VS3.R_E_C_N_O_,0) NREGVS3 	
		FROM %Table:VS3% VS3
		WHERE VS3.VS3_FILIAL 		= %xFilial:VS3%
			AND VS3.VS3_NUMORC 		= %Exp:_cNumOrc%
			AND VS3.VS3_QTDITE		> 0
			AND VS3.%notDel%
		ORDER BY VS3.VS3_VALTOT	
	EndSql
	(_cAliasPesq)->(DbGotop())
	If (_cAliasPesq)->(Eof()) .Or. (_cAliasPesq)->NREGVS3 == 0
		_cObs += "Não localizado itens do orçamento "+_cNumOrc
			_cObs 	+= CRLF
		Break
	EndIf 
	While (_cAliasPesq)->(!Eof()) 
		VS3->(DbGoto( (_cAliasPesq)->NREGVS3))
		//Verifica se o item esta no Backorder
		_nPosCpo := Ascan(_aBackOrder,{|x| AllTrim(x[2]) == AllTrim(VS3->VS3_CODITE)}) 	 
		//Caso esteja no BackOrder e não tenha referencia ao item que substitui e ou se é normal não possui saldo e será apagado
		If _nPosCpo > 0 .And. Empty(VS3->VS3_XTPSUB)
			(_cAliasPesq)->(DbSkip())
			Loop	
		EndIf
		_nValPrd += VS3->VS3_VALTOT
		(_cAliasPesq)->(DbSkip())
	EndDo	
	If _nValPrd == 0
		_lAvalia := .F.
		Break 
	Endif	
	//DAC 21/03/2023
	//aplicado o percentual para verificar se poderá ou não utilizar o limite para o total da nota
	//este fator foi criado tendo em consideração que poderá liberar um orçamento que ja esteja parado baseado num percentua informado no parâmetro
	//caso atinja este valor no limite existente para utilização de crédito a nota será liberada no seu valor total (maior que o fator) conforme alinhado equipe CAOA

	//Fator de redução do orçamento percentual aceitavel para liberação do orçamento no seu valor total DAC 21/03/2023
	If _nRedBO > 100
		_nRedBO := 100
	Endif

	_nFatorLimite := _nValPrd //* (_nRedBO/100) conforme alinhado com Zé avaliar o valor total DAC 24/01/2023
	If _nLimAvalia < _nFatorLimite
		_lAvalia := .F.
	Endif
End Sequence
If _lAvalia
	_cObs += "Produtos com valor total "+AllTrim(Transform(_nValPrd,PesqPict("VS1","VS1_VTOTNF ")))+" Limite Parcial de " +AllTrim(Transform(_nLimAvalia,PesqPict("VS1","VS1_VTOTNF ")))+" Aprovado Limite de Crédito Parcial" 
Else
	_cObs += "Produtos com valor total "+AllTrim(Transform(_nValPrd,PesqPict("VS1","VS1_VTOTNF ")))+" Limite Parcial de " +AllTrim(Transform(_nLimAvalia,PesqPict("VS1","VS1_VTOTNF ")))+" não Aprovado pelo Limite de Crédito Parcial" 
Endif
_cObs 	+= CRLF
_cObs	:= Upper(_cObs)
Aadd(_aMensAglu,Upper(_cObs))
//Gravo informações do processo
VS1->(RecLock("VS1",.F.))
//Se o Status esta igual a 3 e liberei algum parcial atualizo o status para 0 Normal
If _lAvalia .And. VS1->VS1_STATUS == "3"
	VS1->VS1_STATUS := "0"
Endif
VS1->(MsUnlock())
Return _lAvalia  //neste caso sempre volto vervadeiro



/*/{Protheus.doc} ZPECF8LCAI
Avaliação de limite de crédito orçamento item a item
@since      06/12/2022
@param      _cNumOrc 	- Numero de Orçamento
			_nLimAvalia - Limite parcial para liberação
			_aBackOrder - Registros ja grvados para backorder caso os tenha
@return     _lAvalia
@author     DAC Denilso
@version    12.1.17 / Superior
@project	GRUPO CAOA - Liberação de Limite de Crédito Parcial
@since      06/12/2022
@ Obs		Esta função não irá utilizar fator de redução para avaliar limite a mesma avalia item a item 
			para liberar limite parcial DAC 21/03/2023
@history    06/12/2022 DAC	- PEC031 - Limite de Credito - Revitalização 
			Tratar limite de crédito Parcial avaliando se bloqueia e ou libera parcialment
			21/03/2022 DAC	- GAP FIN100 - Revitalização Limite de Crédito V2	
			Incluído fator para calculo percentual do orçamento para liberação de crédito parcial
/*/

Static Function	ZPECF8LCAI(_cNumOrc, _nLimAvalia, _nRegVS1, _aBackOrder)
Local _cAliasPesq   := GetNextAlias()
Local _lRet 		:= .F.  //indica se foi utilizado o limite de crédito
Local _nLimCredito	:=	0
Local _aObs			:= {}
Local _aBak			:= {}
Local _lParcial		:= .F.
Local _lZera		:= .F.
Local _cObs			:= ""		
Local _nQtdePrd
Local _nValorPrd
Local _nPos 
Local _nQtdeBak

Begin Sequence
	//Guardo o valor do limite de crédito pois será alterado caso possa utilizar o mesmo
	_nLimCredito	:= _nLimAvalia
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT NVL(VS3.R_E_C_N_O_,0) NREGVS3 	
		FROM %Table:VS3% VS3
		WHERE VS3.VS3_FILIAL 		= %xFilial:VS3%
			AND VS3.VS3_NUMORC 		= %Exp:_cNumOrc%
			AND VS3.VS3_QTDITE		> 0
			AND VS3.%notDel%
		ORDER BY VS3.VS3_VALTOT	
	EndSql
	(_cAliasPesq)->(DbGotop())
	If (_cAliasPesq)->(Eof()) .Or. (_cAliasPesq)->NREGVS3 == 0
		Break
	EndIf 
	Aadd( _aObs,"[ZPECF08LCC] ORÇAMENTO COM LIMITE DE CRÉDITO PARCIAL "+AllTrim(Transform(_nLimAvalia,PesqPict("VS3","VS3_VALTOT")))+" AVALIANDO LIBERAÇÃO POR LIMITE DE CRÉDITO")
	While (_cAliasPesq)->(!Eof()) 
		VS3->(DbGoto( (_cAliasPesq)->NREGVS3))
		//Verifica se o item esta no Backorder
		_nPosCpo := Ascan(_aBackOrder,{|x| AllTrim(x[2]) == AllTrim(VS3->VS3_CODITE)}) 	 
		//Caso esteja no BackOrder e não tenha referencia ao item que substitui e ou se é normal não possui saldo e será apagado
		If _nPosCpo > 0 .And. Empty(VS3->VS3_XTPSUB)
			(_cAliasPesq)->(DbSkip())
			Loop	
		EndIf
		//Avaliar crédito se  é possivel utilizar  para todo o produto
		_nQtdePrd 	:= 0
		_lParcial	:= .F.
		If VS3->VS3_VALTOT <= _nLimCredito
			_nLimCredito 	-= VS3->VS3_VALTOT
			_nQtdePrd		:= VS3->VS3_QTDITE 
			_lRet 			:= .T.
		//Neste caso verificar por unidade o quanto atende	
		ElseIf VS3->VS3_QTDITE > 1   
			_nValorPrd 	:=  VS3->VS3_VALPEC
			For _nPos := 1 To VS3->VS3_QTDITE
				If _nValorPrd <= _nLimCredito
					_nLimCredito 	-= _nValorPrd
					_nQtdePrd 		++
					_lParcial		:= .T.
					_lRet 			:= .T.
				Else
					Exit
				Endif	
			Next
		Endif
		//Caso atenda verificar se ja existe BakOrder  caso sim atualizar o processo deve ser com o parcial
		If _nQtdePrd > 0
			If _lParcial	
				_lZera 		:= .F.
				_nQtdeBak	:= VS3->VS3_QTDITE - _nQtdePrd
				Aadd( _aObs,"GERADO BAKORDER PROD "+AllTrim((VS3->VS3_CODITE))+ " NA QUANTIDADE " +AllTrIm(STR(_nQtdeBak))+" LIMITE DE CREDITO PARCIAL ATUALIZADO "+AllTrim(Transform(_nLimCredito,PesqPict("VS3","VS3_VALTOT"))) ) 
				aAdd(_aBak, { 	VS3->(Recno()),;
								_nQtdeBak,;
								_aObs[Len(_aObs)],;
								_lZera,;
								VS3->VS3_QTDITE;
							})
			Else
				_nQtdeBak	:= VS3->VS3_QTDITE 
			Endif
			Aadd( _aObs,"PROD "+AllTrim(VS3->VS3_CODITE)+" LIBERADO POR L.C. PARCIAL UTILIZADO QTDE "+AllTrIm(STR(_nQtdePrd))+" DE "+AllTrIm(STR(VS3->VS3_QTDITE))+" LIMITE DE CREDITO ATUALIZADO "+AllTrim(Transform(_nLimCredito,PesqPict("VS3","VS3_VALTOT"))) ) 
			
			//tenho que ajustar a quantidade
			VS3->(RecLock("VS3",.F.))
			VS3->VS3_QTDITE := _nQtdePrd
			VS3->VS3_VALTOT := _nQtdePrd * (ROUND(VS3->VS3_VALPEC*(1-(VS3->VS3_PERDES/100)),2))//erro valor total Orc Orig em desmbr por LC
			VS3->VS3_OBSAGL	:= VS3->VS3_OBSAGL + CRLF  + _aObs[Len(_aObs)]
			VS3->(MsUnlock())
		Else
			//Caso não atenda tenho que jogar para o Backorder	 
			//Neste caso se o item ja estiver em backorder somar a quantidade de item pois o mesmo não esta com saldo e deverá ficar fora do pedido
			_lZera	:= .T.   //neste caso zero para tirar o item do pedido pois caso possa utilizar os itens de limite de crédito este não poderá existir
			Aadd( _aObs,"PROD "+AllTrim(VS3->VS3_CODITE)+" NÃO UTILIZADA QTDE "+AllTrIm(STR(VS3->VS3_QTDITE))+" DEVIDO NÃO TER LIMITE "+AllTrim(Transform(_nLimAvalia,PesqPict("VS3","VS3_VALTOT"))))
			aAdd(_aBak, { 	VS3->(Recno()),;
							VS3->VS3_QTDITE,;
							_aObs[Len(_aObs)],;
							_lZera,;
							VS3->VS3_QTDITE;
						})
		Endif
		(_cAliasPesq)->(DbSkip())
	EndDo
	//Caso tenha liberação e exista liberação parcial
	If _lRet .and. Len(_aBak) > 0
		//Criar rotina para gerar orçamento com bloqueio de crédito (lembrar de não marcar BO)
		_lRet := ZPECF8LCGR(_aBak, _nRegVS1)
	EnDif
End Sequence

VS1->(DbGoto(_nRegVS1))
_cObs := ""
For _nPos := 1 To Len(_aObs)
	_cObs	+= Upper(_aObs[_nPos]) + CRLF
Next
Aadd(_aMensAglu,Upper(_cObs))
//Gravo informações do processo
VS1->(RecLock("VS1",.F.))
//Se o Status esta igual a 3 e liberei algum parcial atualizo o status para 0 Normal
If _lRet .And. VS1->VS1_STATUS == "3"
	VS1->VS1_STATUS := "0"
	VS1->VS1_XBO	:= "N"
Endif
VS1->(MsUnlock())
Return _lRet



//Gravar dados em matriz para backorder
Static Function ZPECF8LCBK(_nReg, _cProd, _nQtde, _cObs, _lZera)
	Local _aRet := {}
	Default _lZera := .F.
	Begin Sequence
		_aRet := { 	_nReg,;
					_cProd,;
					_nQtde,; 
					_cObs,;
					_cObs}
	End Sequence
Return _aRet

/*
				Aadd(_aBak,{	(_cAliasPesq)->NREGVS3,;
						 		VS3->VS3_CODITE,; 
								VS3->VS3_QTDITE,; 
								_aObs[Len(_aObs)],;
								.T.,;    ///*_LXBO*/
								//_lZera /*indica se zera ou*/})
*/



Static Function ZPECF8LCGR(_aBak, _nRegVS1)
	Local _lRet 		:= .T.
	Local _cTpSub		:= "4"   //Bloqueio de Crédito 
	Local _aItem		:= {}
	Local _aOrc 		:= {}
	Local _aObs			:= {}
	Local _cNumOrc   	:= VS1->VS1_NUMORC
	Local _cOrcNovo 	:= VS1->(GetSXENum("VS1","VS1_NUMORC"))
	Local _cStatus 		:= "3"  //bloqueado limite de crédito
	Local _nPos
	Local _nRegVS3 
	Local _nQtdeItem	
	Local _cObs 		
	Local _lZera		     
	Local _nQtdeOri

	Default _aBak		:= {}
	Default _nRegVS1	:= 0

	Begin Sequence
		If Len(_aBak) == 0 
			_lRet := .F.
			Break
		EndIf	
		//Gravar os itens do processo caso não esteja fornecido tem que estar posicionado no registo
		If _nRegVS1 > 0 
			VS1->(DbGoto(_nRegVS1))
		Endif

		For _nPos := 1 To Len(_aBak)
			_aItem 		:= Aclone({})
			_nRegVS3 	:= _aBak[_nPos,1]
			_nQtdeItem	:= _aBak[_nPos,2]
			_cObs 		:= _aBak[_nPos,3]
			_lZera		:= _aBak[_nPos,4] 
			_nQtdeOri 	:= _aBak[_nPos,5]    
			VS3->(DbGoto(_nRegVS3))
			Aadd(_aItem,{ "VS1_CLIFAT"	, VS1->VS1_CLIFAT})
			Aadd(_aItem,{ "VS1_LOJA"	, VS1->VS1_LOJA})
			Aadd(_aItem,{ "VS1_NUMORC"	, VS1->VS1_NUMORC})
			Aadd(_aItem,{ "NUMORCNOVO"	, _cOrcNovo}) 
			Aadd(_aItem,{ "VS1_XAGLU"	, _cAglutina})
			Aadd(_aItem,{ "VS1_STATUS"	, _cStatus})
			Aadd(_aItem,{ "VS3_GRUITE"	, VS3->VS3_GRUITE}) 
			Aadd(_aItem,{ "VS3_CODITE"	, VS3->VS3_CODITE}) 
			Aadd(_aItem,{ "VS3_QTDITE"	, _nQtdeItem}) 
			Aadd(_aItem,{ "VS3_PERDES"	, VS3->VS3_PERDES}) 
			Aadd(_aItem,{ "VS3_OPER"	, VS3->VS3_OPER}) 
			Aadd(_aItem,{ "VS3_CODTES"	, VS3->VS3_CODTES})
			Aadd(_aItem,{ "VS1_XTPPED"	, VS1->VS1_XTPPED})
			Aadd(_aItem,{ "VS3_XTPSUB"	, _cTpSub})
			//Aadd(_aItem,{ "VS3_QTDINI"	, _nQtdeItem})  
			Aadd(_aItem,{ "VS3_XDTSUB"	, Date()})
			Aadd(_aItem,{ "VS3_XHRSUB"	, Time()})
			Aadd(_aItem,{ "VS3_XAGLU"	, VS1->VS1_XAGLU})
			Aadd(_aItem,{ "VS3_XUSUGL"	, RetCodUsr()})
			Aadd(_aItem,{ "VS3_XOBSAGL"	, {_cObs}})
			Aadd(_aItem,{ "LXBO"		, .F.})
			Aadd(_aItem,{ "LAPAGAIT"	, _lZera})
			Aadd(_aItem,{ "LBAKORDER"	, .T.})
			Aadd(_aItem,{ "NREGVS3"		, _nRegVS3 })
			Aadd(_aItem,{ "NREGVS1"		, VS1->(Recno()) })
			Aadd(_aOrc, _aItem)
			
			//Gravar na observação
			_cObs := "Item " +AllTrim(VS3->VS3_CODITE)+ " "
			_cObs += "qtde original " +AllTrim(STR(_nQtdeOri ))+ " "
			_cObs += "qtde alterada " +AllTrim(STR(_nQtdeItem))+ " "
			_cObs += "BakOrder limite de crédito Tipo "	+_cTpSub+ " " 
			_cObs += "Orçamento referencia " +AllTrim(_cNumOrc)+ " "
			_cObs += _aBak[_nPos,3]
			Aadd(_aObs, Upper(_cObs))
			
		Next _nPos
		_lRet := U_XCLONEOR( _aOrc, /*_aCpoVazio*/, /*_lXBO*/, /*_lApagaIT*/, _aObs)	
		U_XFUNIPOSTO(_cOrcNovo, '02'/*cEmpAnt*/, cFilAnt, .T. /*_lJob*/)
		
	End Sequence
Return _lRet





/*/{Protheus.doc} ZPECF8TVS3
Responsável por verificar se pode liberar o orçamento para carregamento que esteja com tipo de pedido Transferência para FDR
@author 	DAC-Denilso
@since 		07/02/2023
@version 	undefined
@param 		_cNumOrc - Numero do orçamento 
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 
@menu       Nao Informado
@return		_lRet	- Verdadeiro ou falso  
@history    /*/
Static Function	ZPECF8TVS3(_cNumOrc, _cMarca, _aBackOrder, _cConectWis, _cCdEmpWIS, _cLocal, _cTPedTransfFDR)  
Local _lRet 		:= .F.
Local _lSepara		:= .F.
Local _lParcial		:= .F.
Local _cAliasPesq	:= GetNextAlias()   
Local _cArmazem		:= _cLocal
Local _aBak			:= {}
Local _nPos
Local _aRetSaldo 
Local _lRetorno 
Local _cMens
Local _nSaldoSB2
Local _nQtdeItem 
Local _cCodProd
Local _nQtdePrd  
Local _nQtdeParc 
Local _lZera
Local _cObs

Begin Sequence
	_cConectWis := "%"+_cConectWis+"%"
	_cCdEmpWIS 	:= "%"+_cCdEmpWIS+"%"

	//--PRODUTOS COM SALDO EM CÓDIGOS ALTERNATIVOS(IT.REL/SUBST/CORRELATO) + CONSULTA WIS		
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT DISTINCT 
			VS3.VS3_NUMORC 
		, 	VS3.VS3_CODITE 
		, 	VS3.VS3_GRUITE 
		, 	VS3.VS3_LOCAL 
		, 	VS3.VS3_CODTES 
		, 	VS3.VS3_QTDITE  AS  QTDE_TOTAL 
		, 	VS3.VS3_SEQUEN 
		, 	SB1.B1_MSBLQL
		, 	SB1.B1_XNUMINM 
		, 	SB1.B1_XVLDINM 
		, 	AVG(	CASE WHEN VS3.VS3_CODITE IS NOT NULL 
				THEN
				(	SELECT NVL((B2VS3.B2_QATU - B2VS3.B2_RESERVA - B2VS3.B2_QACLASS),0) 
					FROM %Table:SB2%  B2VS3 
					WHERE 	B2VS3.B2_FILIAL		= %xFilial:SB2%	
						AND B2VS3.B2_COD 		= VS3.VS3_CODITE 										
						AND B2VS3.B2_LOCAL 		= %Exp:_cArmazem%
						AND B2VS3.%notDel% 
				) 
	  	  		ELSE 
					0	  
	  	  		END ) AS SLD_VS3
		,	AVG(COALESCE(VS3.R_E_C_N_O_,0)) NREGVS3 	
		FROM %Table:VS3% VS3
		LEFT  JOIN %Table:SB1% SB1
			ON SB1.B1_FILIAL 		= %xFilial:SB1%
			AND SB1.B1_COD 			= VS3.VS3_CODITE
			AND SB1.%notDel%
		WHERE VS3.VS3_FILIAL 		= %xFilial:VS3%
			AND VS3.VS3_NUMORC 		= %Exp:_cNumOrc%
			AND VS3.%notDel%
		GROUP BY  VS3.VS3_NUMORC 
				, VS3.VS3_CODITE 
				, VS3.VS3_GRUITE 
				, VS3.VS3_LOCAL 
				, VS3.VS3_CODTES 
				, VS3.VS3_QTDITE   
				, VS3.VS3_SEQUEN 
				, SB1.B1_MSBLQL
				, SB1.B1_XNUMINM 
				, SB1.B1_XVLDINM 
		ORDER BY VS3.VS3_NUMORC, VS3.VS3_SEQUEN
	EndSql
//	TCSetField(_cAliasPesq,'VS3_CODITE','C',TamSx3("B2_COD")[1],0)

 	If (_cAliasPesq)->(Eof())  
		_lRet := .F.
		Aadd(_aMensAglu,"Orçamento não possui itens localizados !")
		Break	
	Endif
	
	_lSepara	:= .F.  //indica se tera algum item que será separado
	_aBackOrder := {}
	
	While (_cAliasPesq)->(!Eof())
		//Ajustar tamanho código produto
		//_cArmazem	:= (_cAliasPesq)->VS3_LOCAL
		_cCodProd 	:= AllTrim((_cAliasPesq)->VS3_CODITE)
		_cGrupo		:= (_cAliasPesq)->VS3_GRUITE

		//Conforme solicitação JC e Fabio caso não tenha TES Abortar o orçamento inteiro
		If 	Empty((_cAliasPesq)->VS3_CODTES)
			Aadd(_aMensAglu,"Produto "+ AllTrim(_cCodProd) +" com TES não informado no item do orçamento !")
			_lSepara	:= .F.  //indica se tera algum item que será separado
			_aBackOrder  := {}
			Break	
		Endif

		//Não deixar com armazem em branco	
		If Empty((_cAliasPesq)->VS3_LOCAL)
			Aadd(_aMensAglu,"Armazem do Produto "+ AllTrim(_cCodProd) +" não informado no item do orçamento !")
			Aadd(_aBak,{(	_cAliasPesq)->NREGVS3,;
							_cCodProd,;
							(_cAliasPesq)->QTDE_TOTAL,;
							_aMensAglu[Len(_aMensAglu)],; 
							.T. ,;  					//_Lxbo
							.T. })  					//_lZera
   			(_cAliasPesq)->(DbSkip())  //Devo verificar se existem outros itens
			Loop
		Endif
		_nSaldoSB2 := 0
		If (_cAliasPesq)->SLD_VS3 > 0 
			_aRetSaldo 	:= U_XSLDCAOAEstoque(_cCodProd, _cArmazem, _cGrupo ) //procurar saldo entre Wis e Proteus DAC 25/05/2022
			_lRetorno  	:= _aRetSaldo[1]  //Retorna verdadeiro ou falso
			_nSaldoSB2  := _aRetSaldo[2]  //Retorna oSaldo calculado
			_cMens		:= _aRetSaldo[3]  //Retorna as Mensagens de validações	 
			_cCodProd	:= _aRetSaldo[4]  //pego o produto novamente pois o mesmo pode ter sido ajustado o tamanho
			//quando retorno mensagem ja devo separar para gravar	
			If !Empty(_cMens)
				Aadd(_aMensAglu,_cMens)
			EndIf	
			If !_lRetorno  //posição de retorno
				Aadd(_aMensAglu, _cMens)  //retorno de msg
				Aadd(_aBak,{(	_cAliasPesq)->NREGVS3,;
			 					_cCodProd,; 
								(_cAliasPesq)->QTDE_TOTAL,;
								_aMensAglu[Len(_aMensAglu)],; 
								.T. ,;							//_Lxbo 
								.T. })							//_lZera	
				(_cAliasPesq)->(DbSkip())  //Devo verificar se existem outros itens
				Loop
			EndIf
		EndIf
		//Avaliar e tratar item parcial quando for parcial deverá utilizar o saldo do B2 e o restante deverá gerar separação via Bakorder
		If (_cAliasPesq)->QTDE_TOTAL <= _nSaldoSB2  //possui saldo posso processar
			_lSepara := .T.   //ja indico que existira separação
			(_cAliasPesq)->(DbSkip())  //Devo verificar se existem outros itens
			Loop
		EndIf
		//Verificar utilização do parcial
		Aadd(_aMensAglu,"Produto "+AllTrim(_cCodProd)+" armazem "+_cArmazem+" não possui saldo suficiente para faturamento, saldo atual " +AllTrim(Transform(_nSaldoSB2,"@E 999,999.999")))	
		 _nQtdeParc := 0  
		 _nQtdePrd  := 0
		 _lParcial	:= .F.
 		//Caso não possua quantidade suficiente  tenho que avaliar parcial
		If (_cAliasPesq)->QTDE_TOTAL > _nSaldoSB2 .and.  _nSaldoSB2 > 0
			_nQtdeItem := (_cAliasPesq)->QTDE_TOTAL - _nSaldoSB2
			//quando possui saldo e o mesmo não atende total montar parcial para este saldo
			_nQtdePrd  := (_cAliasPesq)->QTDE_TOTAL- _nQtdeItem
			_nQtdeParc := _nQtdePrd   //(_cAliasPesq)->QTDE_TOTAL
			//ja ajusto com a quantidade parcial pois caso  não faça não ira faturar esta quantidade, o restante devrá ser avaliado e ou gerar backorder DAC 02/05/08
			If !ALTERAITParcial( (_cAliasPesq)->NREGVS3, _cNumOrc, _cGrupo, _cCodProd, _cArmazem, _cCodProd, _cGrupo, _nQtdePrd, _nQtdePrd, _nSaldoSB2, "0" ,,@_nSaldo)
				_lSepara := .F.
				Break
			EndIf	
			_lParcial 	:= .T.  //indica que usou parcial
			_lSepara 	:= .T.
		Else
			_nQtdeItem := (_cAliasPesq)->QTDE_TOTAL
		EndIf

		If _nQtdePrd > 0  //significa que utilizou parcial não podendo zerar
			_lZera := .F.
		Else
			_lZera := .T.
		Endif	 

		If _lParcial
			_cObs := If(Len(_aBak) > 0,"","Urilizado saldo parcial "+AllTrim(STR(_nQtdeParc))+" de acordo com tipo de pedido transferencia FDR "+_cTPedTransfFDR+" armazém "+_cArmazem) 
		Else
			_cObs := If(Len(_aBak) > 0,"","Não possui Saldo  para a transfereria FDR conforme parametrização tipo de pedido "+_cTPedTransfFDR+" armazém "+_cArmazem) 
		Endif
		Aadd(_aBak,{	(_cAliasPesq)->NREGVS3,;
						 _cCodProd,; 
						_nQtdeItem,; 
						_cObs,;
						.T.,;    ///*_LXBO*/
						_lZera /*indica se zera ou*/})
	   (_cAliasPesq)->(DbSkip())
	Enddo
End Sequence
//no caso que conseguiu passar um item posso fazer backorder, caso não não gerar backorder
If _lSepara .and. Len(_aBak) > 0
	For _nPos := 1 To Len(_aBak)
		Aadd(_aBackOrder,_aBak[_nPos])
	Next	
EndIf	
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lSepara


//DAC Denilso 	19/05/2023 	-  
/*/{Protheus.doc} ZPECF08R07
Responsável por Gerar relatório Relação Carga  - Barueri
@author 	DAC-Denilso
@since 		19/05/2023
@version 	undefined
@param 		_aOndaRel	- Ondas geradas no processo  
@project    PEC042 - Controle de saldo e e-mail apos integracao de armazenagem - Geração do relatório ZPECR007 no final de qualquer onda 
@type 		user function
@obs 
@menu       Nao Informado
@return		Nil  
@history    /*/

Static Function	ZPECF08R07(_aOndaRel)
Local aRetP 	:= {}
Local _cOndaRel	:= ""
Local _nPos

Begin Sequence
	If Len(_aOndaRel) == 0
		Break
	Endif
	For _nPos := 1 To Len(_aOndaRel)
		_cOndaRel += (_aOndaRel[_nPos]+";")
    Next
	_cOndaRel := SubsTr(_cOndaRel,1,Len(_cOndaRel)-1)
	//passar parametros para a 
	aAdd( aRetP , _cOndaRel)  	//Onda
	aadd( aRetP	, Date()) 		//Data Inicial
	aadd( aRetP	, Date()) 		//Data Final
	aAdd( aRetP , Space(TamSx3("VS1_XMARCA")[1]))			//Marca
	aAdd( aRetP ,.F.)			//HYU - Hyundai
	aAdd( aRetP ,.F.)			//CHE - Chery
	aAdd( aRetP ,.F.)			//SBR - Subaru
	aAdd( aRetP , Space(TamSx3("VS1_XPICKI")[1]))			//Pick Inicial
	aAdd( aRetP , Repl("Z",TamSx3("VS1_XPICKI")[1]))			//Pick Final
	U_ZPECR007(aRetP)	
End Sequence

Return Nil
