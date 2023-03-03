#INCLUDE "PROTHEUS.CH"
#INCLUDE 'XMLXFUN.CH'
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH"
#DEFINE _CEOL CHR(13)+CHR(10)  //final de linha


/*---------------------------------------------------------------------------------------
{Protheus.doc} ZPCPJ001
Rdmake 	JOB Processar Importação recebida do MES BackFlushu 
@class    	Nao Informado
@from       Nao Informado
@param      _lJob
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC - Denilso 
@single		20/10/2020
@version    Nao Informado
@since      Nao Informado  
@return    	Nil
@sample     Nao Informado
@obs         
@project    CAOA - Processo Backflush 3_0 DEV01 - Especificação Funcional Correto_V2
@menu       Nao Informado
@history    

/*/

Static _lJob 	:= .T.

User Function ZPCPJ001(_cTipoVei, _nRegSZZ, _cTime)
Local _lRet 		:= .T.
Local _lZPCPJ001    := SuperGetMV( "CMV_PCP007"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade ZPCPF010
Local _lPrcVeiculo		:= .F.
Local _nPos
Local _oSay

Default _cTipoVei 	:= ""
Default _nRegSZZ	:= 0
Default _cTime		:= ""

Begin Sequence
	If !_lZPCPJ001
		If !IsBlind()  //interface com o usuário
			MSGInfo( "Não é possivel executar BackFlush, motivo PAUSADO -)","ATENCAO")
		EndIf
		Break	
	Endif
	If ! IsBlind()  //interface com o usuário
		_lJob := .F.
	Endif
	//Garantir que o processamento seja unico
	If !LockByName("ZPCPJ001",.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 1000 ) // Para o processamento por 1 segundo
			If LockByName("ZPCPJ001",.T.,.T.)
				_lRet := .T.
			EndIf
		Next		
		If !_lRet
			If !_lJob
				MsgInfo("Já existe um processamento em execução rotina ZPCPJ001, aguarde!")
			Else
				CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Já existe um processamento em execução, aguarde!")
				ConOut("*************************************************************************************************************************"	+ CRLF)
				ConOut("----------- [ ZPCPJ001 ] - Já existe um processamento em execução rotina ZPCPJ001 "														+ CRLF)
				ConOut("*************************************************************************************************************************"	+ CRLF)
			EndIf
			Break
		EndIf
	EndIf

	If ValType(_cTipoVei) == "C" .and.  _cTipoVei == "VEI"
		_lPrcVeiculo := .T.	
	ElseIf ValType(_cTipoVei) == "A" .and.  _cTipoVei[1] == "VEI"
		_lPrcVeiculo := .T.	
	EndIf

	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Iniciado processamento Backflush 3.0 "+If(_lPrcVeiculo," processamento para Veiculos.","."))

	If _lJob
		ZPCPJ001PR( _lPrcVeiculo, _nRegSZZ, _cTime, _oSay )
	Else
		FWMsgRun(,{|_oSay| ZPCPJ001PR( _lPrcVeiculo, _nRegSZZ, _cTime, _oSay) },,"Processando Backflush V3, aguarde...")
	Endif
	
	UnLockByName("ZPCPJ001",.T.,.T.)
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Finalizado processamento Backflush 3.0 "+If(_lPrcVeiculo," processamento para Veiculos.","."))
End Sequence
Return _lRet


//-------------------------------------
/*/{Protheus.doc} ZPCPJ001PR
Processar os dados do arquivo Blackflush, gerando OPs, Saldos Veiculos, atualizando tabela SZZ
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		Utilizara funcionalidade de recebimento do XML MES para a geração das OPs e outros         
/*/
//-------------------------------------
Static Function ZPCPJ001PR( _lPrcVeiculo, _nRegSZZ, _cTime, _oSay)
Local _lRet 		:= .T.
Local _cAliasTab    := GetNextAlias()
Local _cStatus		:= " ' ','E','I','L','B' "   //acrescentado bloqueio de Estoque 'B' 23/03/2021
//Local _cStatus		:= " ' ','E','I' "
Local _aRegOp		:= {}
Local _aMens		:= {}
Local _cWhere   	:= ""
Local _lVeiculo		:= .F.
Local _cLocPad		:= AllTrim(SuperGetMV( "CMV_PCP003"  ,,'VN'))  	//parametro Local padrão para veiculos novos
Local _cGrpProd		:= AllTrim(SuperGetMV( "CMV_PCP004"  ,,'VEIA'))  //parametro Grupo de produtos padrão para veiculos novos
Local _dDataFechEst := GetMv("MV_ULMES")
Local _dDataBlqEst	:= GetMv("MV_DBLQMOV")  //data de bloqueio movimento
Local _nRegProcess  := 0
Local _nRegLidos 	:= 0
Local _cTimeDif     := If(Empty(_cTime),"",ElapTime( Time(), _cTime+":00"))  //SubHoras( _cTimeIni, _cTime )
Local _nCustoMax
Local _cOp 
Local _cProduto	
Local _cLocal 	
Local _cTipoPRD

Default _lPrcVeiculo	:= .F.
Default _nRegSZZ 		:= 0

//_lPrcVeiculo := .T.

Begin Sequence

	//Se o Date() <= MV_ULMES e MV_DBLQMOV ele não executa nada, não executa o JOB e manda um e-mail de erro para os responsáveis.
	If Date() <= _dDataFechEst  
		Aadd(_aMens, "PARAMETRO DATA DE FECHAMENTO ESTOQUE MAIOR OU IGUAL A DATA ATUAL, NAO SERA PROCESSADO BACKFLUSH")
	EndIf
	If Date() <=  _dDataBlqEst	
		Aadd(_aMens, "PARAMETRO DATA DE BLOQUIEO FECHAMENTO ESTOQUE (VIRADA DE SALDO) MAIOR OU IGUAL A DATA ATUAL, NAO SERA PROCESSADO BACKFLUSH")
	EndIf
	If Len(_aMens) > 0  //existem erros para iniciar processamento
		ZPCPJ1EBKF(_aMens, "PROCESSAMENTO BAKFLUSH INTERROMPIDO BLOQUEIO DE ESTOQUE", /*_cOP*/, /*_cProduto*/, /*_cChassi*/, /*_cIdent*/, /*_cIdMes*/ )
		Break
	EndIf
	_cWhere  := ""
	If _lPrcVeiculo
		_cStatus		:= " ' ','I','B' "  //acrescentado bloqueio de Estoque DAC 23/03/2021
		//_cStatus		:= " ' ','I' "
		//_cStatus		:= " ' ','I','L' "
		//_cWhere := " AND SB1.B1_GRUPO = '"+_cGrpProd+"'  AND  SZZ.ZZ_ETAPAPD = '004' "
		_cWhere := " AND SZZ.ZZ_ETAPAPD  = '000004' "
	EndIf
	If _nRegSZZ > 0
		_cWhere += " AND SZZ.R_E_C_N_O_ = "+ AllTrim(Str(_nRegSZZ))
	EndIf
	_cWhere 	:= "%"+_cWhere+"%"
	_cStatus 	:= "%"+_cStatus+"%"

    BeginSql Alias _cAliasTab	
   	    SELECT 	ISNULL(SZZ.R_E_C_N_O_,0) NREGSZZ,
		   		ISNULL(SB1.R_E_C_N_O_,0) NREGSB1,
				SZZ.ZZ_OP, 
				SZZ.ZZ_PRODUTO,
				SZZ.ZZ_LOCAL,
				SZZ.ZZ_STATUS,
				SZZ.ZZ_TPAPONT,
				SZE.ZE_AGRUPA,
				SZE.ZE_CUSTOLI
	    FROM %Table:SZZ%  SZZ 
		JOIN %Table:SB1% SB1 ON
				SB1.B1_FILIAL 	= %xFilial:SB1%
		    AND SB1.B1_COD		= SZZ.ZZ_PRODUTO
		    AND SB1.%notDel%
		JOIN %Table:SZE% SZE ON
				SZE.ZE_FILIAL 	= %xFilial:SZE%
		    AND SZE.ZE_CODIGO 	= SZZ.ZZ_ETAPAPD
			AND SZE.ZE_MSBLQL  <> '1'
		    AND SZE.%notDel%
	    WHERE 	SZZ.ZZ_FILIAL 	= %xFilial:SZZ% 
		    AND SZZ.ZZ_STATUS	IN ( %Exp:_cStatus% )
		    AND SZZ.%notDel%
			%Exp:_cWhere%
		ORDER BY SZZ.ZZ_STATUS ASC, SZE.ZE_SEQ, SZZ.ZZ_OP, SZZ.ZZ_PRODUTO, SZZ.ZZ_LOCAL	
    EndSQL
		//Group by op codproduto (tipo)
		//Necessario colocar a sequencia no cadastro de produtos para ordenar a sequencia de processamento
	If (_cAliasTab)->(EOF())
		If ! _lJob
			MSGInfo( "Não existem dados para processar","ATENCAO")
		EndIf
		Break
	EndIf
	Count To _nRegProcess
	(_cAliasTab)->(DbGotop())
	While (_cAliasTab)->(!EOF())
		//Quando o tempo para termino estiver informado finalizar o processo indiferente de não terminar
		//Quando for sabado e domingo não validar tempo
		//If DOW( DATE() ) <> 7 .or. DOW( DATE() )  <> 1    
		If DOW( DATE() )  <> 1    //no momento não vou tratar _lJob podem deixar processando via tela DAC 23/03/2021
			If !Empty(_cTimeDif)
				//Quando o tempo maxixo é atingido passara a ser maior que o estipulado
				If Hrs2Min(_cTimeDif)  <  Hrs2Min( ElapTime( Time(), _cTime+":00")) 
					Break
				EndIf	
			Endif
		Endif
		
		SB1->(DbGoto( (_cAliasTab)->NREGSB1 ))
		//identificar se esta processando veiculo
		If AllTrim(SB1->B1_LOCPAD) == _cLocPad .or. AllTrim(SB1->B1_GRUPO) == _cGrpProd
			_lVeiculo 	:= .T.
		Else
			_lVeiculo	:= .F.	
		EndIf
		//Guardo em Matriz pois pode ser por agrupamento e ou uma unica OP
		_nCustoMax 	:= (_cAliasTab)->ZE_CUSTOLI
		_cOp 		:= (_cAliasTab)->ZZ_OP
		_cProduto	:= (_cAliasTab)->ZZ_PRODUTO
		_cLocal 	:= (_cAliasTab)->ZZ_LOCAL
		_aRegOp 	:= ZPCPJ001CA( _cAliasTab, _lVeiculo, _nRegProcess, @_nRegLidos, _oSay)
		_cTipoPRD	:= SB1->B1_TIPO
		If Len(_aRegOp)  > 0
			//Verifica se podera processar todas as ops e ou se pode processar o minimo PI
			ZPJ1MNTOP1(_cOp, _cProduto, _cLocal,  @_aRegOp, _lVeiculo, _nCustoMax)
			//Verifica se podera processar todas as ops e ou se pode processar o minimo MP
			//ZPJ1MNTOP2(_cOp, _cProduto, _cLocal,  @_aRegOp, _lVeiculo, _nCustoMax)
			//Deletar Empenho não será mais realizado
			//ZPJ1MNTOP3(_cOp, _cProduto, _cLocal,  @_aRegOp, _lVeiculo, _nCustoMax)
			//Caso passou pelos processo tentar gravar os registros
			ZPCPJ1GRV(_aRegOp) //Retornar true realizou o processo
			//Caso ainda não conseguiu apontar as OPs baixar por emprestimo
			PCPJ1VEMPR( _lVeiculo, @_aRegOp, _cTipoPRD, /*_nOpc*/)
		EndIf	
	Enddo
End Sequence
If Select(_cAliasTab) <> 0
	(_cAliasTab)->(DbCloseArea())
	Ferase(_cAliasTab+GetDBExtension())
Endif  
Return _lRet	


//-------------------------------------
/*/{Protheus.doc} ZPCPJ1GRV
Verificar se existe ops liberadas para a gravação/execução somente as que estiverem com status de apontamento
@author 	DAC - Denilso
@since 		17/02/2021
@version 	1.0
@obs		         
/*/
//-------------------------------------
Static Function ZPCPJ1GRV(_aRegOp)
Local _aOp 		:= {}
Local _nQtdeOP 	:= 0
Local _lRet 	:= .T.
Local _nPos
Begin Sequence
	For _nPos 	:= 1 To Len(_aRegOp)
		If _aRegOp[_nPos,3] == "A"
			Aadd(_aOP,_aRegOp[_nPos,1])
			_nQtdeOP 			+= _aRegOp[_nPos,2]
			_aRegOp[_nPos,3]	:= "U"  //guardo informação de Utilizado
		EndIf
	Next
	If Len(_aOP) == 0
		_lRet := .F.
		Break
	EndIF
	_lRet := ZPCPJ001EA(_aOP, _nQtdeOP, /*_nRegOP*/, /*_nOpc*/)
	//Verificar se processou todas as OPa todas as OPs
	For _nPos := 1 To Len(_aRegOp)
		SZZ->(DbGoto(_aRegOp[_nPos,1]))
		//Neste Caso estou criando uma condição se tentou atualizar e por algum motivo deu erro deixarei 
		//passar para que possa ser utiizado em outro processamento até chegar ao emprestimo
		If _aRegOp[_nPos,3]	== "U" .and.  SZZ->ZZ_STATUS == "E"
		 	_aRegOp[_nPos,3] := "E"  //Volto para erro
			_lRet := .F.  //ainda existe pendencias para que seja avaliado novamente com outras condiçõs
		ElseIf _aRegOp[_nPos,3]	<> "U" 
			_lRet := .F.  //ainda existe pendencias deixar realizar novas analises
		EndIf	
	Next _nPos
End Begin
Return _lRet


//-------------------------------------
/*/{Protheus.doc} ZPCPJ001CA
Avaliar OPs
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		         
/*/
//-------------------------------------
Static Function ZPCPJ001CA( _cAliasTab,  _lVeiculo, _nRegProcess, _nRegLidos, _oSay)
Local _aOp 			:= {}
Local _cOp 			:= (_cAliasTab)->ZZ_OP
Local _cProduto		:= (_cAliasTab)->ZZ_PRODUTO
Local _aMensErro	:= {}
Local _nQtdeOP 		:= 0
Local _dDataFechEst := GetMv("MV_ULMES")
Local _dDataBlqEst	:= GetMv("MV_DBLQMOV")  //data de bloqueio movimento
Local _lSair
Local _nPos
Local _cMsgErro 
Local _cStatus
Local _cMens

Begin Sequence
	//Indica se havera ou não agrupamento
	_lSair := If(_lVeiculo,.T.,(_cAliasTab)->ZE_AGRUPA <> "1")  //sendo veiculo deve processar um a um
	_cTpApont := (_cAliasTab)->ZZ_TPAPONT
	//Guardo em Matriz pois pode ser por agrupamento e ou uma unica OP 
	//Organizar por tipo de apontamento para que não misture apontamentos de estornos
	While (_cAliasTab)->(!EOF()) .and. _cTpApont == (_cAliasTab)->ZZ_TPAPONT .and. ;
		  _cOp == (_cAliasTab)->ZZ_OP .and. _cProduto == (_cAliasTab)->ZZ_PRODUTO
		_aMensErro 	:= {}
		_nRegLidos	++
		//posiciono SZZ para obter dados
		SZZ->(DbGoto( (_cAliasTab)->NREGSZZ ))
		//Validar se Não existe informação sequencia no SB1
		If Empty(SB1->B1_XPCPSEQ)
			Aadd(_aMensErro,"NÃO INFORMADO SEQUENCIA NO CADASTRO DE PRODUTO")
		EndIf
		//Se não esta informado o agrupamento não processa
		If Empty((_cAliasTab)->ZE_AGRUPA)
			Aadd(_aMensErro, "NÃO EXISTE AGRUPAMENTO RELACIONADO A ESTE REGISTROS")
		Endif 
		//Necessario montar processo de estorno para validações
		If (_cAliasTab)->ZZ_TPAPONT == "E"
			Aadd(_aMensErro, "NÃO ESTA IMPLEMENTADO PROCESSO DE ESTORNO, VERIFICAR COM ADM SISTEMA")
		EndIf
		//Verificar OP
		If Len(_aMensErro) == 0	
			_aMensErro := ZPJ1VLDOP(SZZ->ZZ_OP, SZZ->ZZ_LOCAL, SZZ->ZZ_PRODUTO, _nQtdeOP )
		Endif
		//Verificar Veiculo
		If Len(_aMensErro) == 0	.and. _lVeiculo
			_aMensErro := ZPJ1VLVEI(SZZ->ZZ_PRODUTO, SZZ->ZZ_LOCAL, SB1->B1_GRUPO, SZZ->ZZ_CHASSI, SZZ->ZZ_NUMMOT, SZZ->ZZ_FABMOD )
		Endif
		//Quando Status for de emprestimo é necessário validar Data ultimo fechamento do estoque. 
		//DAC 03/03/2021
		If SZZ->ZZ_STATUS == "L" .and. SZZ->ZZ_DTVEMPR <= _dDataFechEst
			Aadd(_aMensErro, {"DATA DE FECHAMENTO ESTOQUE "+DtoC(_dDataFechEst)+" MAIOR OU IGUAL A DATA DO EMPRESTIMO "+DtoC(SZZ->ZZ_DTVEMPR)+;
			                  ", VERIFICAR COM ADM SISTEMA","F"})
		EndIf
		If SZZ->ZZ_STATUS == "L" .and. !Empty(_dDataBlqEst) .and. SZZ->ZZ_DTVEMPR <= _dDataBlqEst
			Aadd(_aMensErro, {"DATA DE BLOQUEIO MOVIMENTO "+DtoC(_dDataBlqEst)+" MAIOR OU IGUAL A DATA DO EMPRESTIMO "+DtoC(SZZ->ZZ_DTVEMPR)+;
			                  ", VERIFICAR COM ADM SISTEMA","B"})
		EndIf

		//retrara o erro ou guarda a op para processamento
		If Len(_aMensErro) > 0
			For _nPos := 1 To Len(_aMensErro)
				//enviado somente msg de erro
				If ValType(_aMensErro[_nPos]) == "C"  
					_cMsgErro := _aMensErro[_nPos]
					_cStatus  := Nil
				//Enviado msg de erro e status
				ElseIf ValType(_aMensErro[_nPos]) == "A"  //Neste caso foi enviado o status a ser gravado
					_cMsgErro := _aMensErro[_nPos,1]
					_cStatus  := _aMensErro[_nPos,2]
				EndIf
				ZPCPJ001ZZ(_cMsgErro, _cStatus)
			Next _nPos	
		Else		
			SZZ->(DbGoto((_cAliasTab)->NREGSZZ))
			Aadd(_aOp, {(_cAliasTab)->NREGSZZ, SZZ->ZZ_QTDEPRD, "A" /*status*/})
			_nQtdeOP += SZZ->ZZ_QTDEPRD
			RecLock('SZZ', .F. )
			SZZ->ZZ_DTAPONT	:= Date()
			SZZ->ZZ_HRAPONT	:= Time()
			SZZ->ZZ_USUAPON	:= RetCodUsr()	
			SZZ->(MsUnlock())
		EndIf
		//Quando for emprestimo tratar um a um pois sera gravado um a um
		If SZZ->ZZ_STATUS == "L"
			_lSair := .T.
		EndIf
		(_cAliasTab)->(DbSkip())
		//indica que deverá abortar o while processamento não é agrupamento
		If _lSair
			Exit
		EndIf
	EndDo	
End Sequence
_cMens := 'Total de Registros ...' + StrZero(_nRegProcess, 6)+ " - Registros Lidos ..." + StrZero(_nRegLidos, 6)
If !_lJob  //no job não pode chamar
	_oSay:cCaption := (	_cMens )
	ProcessMessages()
EndIf	
Return _aOp


//-------------------------------------
/*/{Protheus.doc} ZPCPJ001EA
execauto OP
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		Gravar dados do usuario e observações neste momento ja deve estar posicionado na OP
			http://www.masteradvpl.com.br/index.php/forum/funcoes-advpl/16971-execauto-mata650 - Encerrar	         
/*/
//-------------------------------------
Static Function ZPCPJ001EA(_aOP, _nQtdeOP, _nRegOP, _nOpc)
Local _aGrava		:= {}
Local _aError		:= {}
Local _cMensErro	:= ""
Local _cOperac		:= "01"
Local _cNumSeq		:= ""
Local _lRet			:= .T.
Local _cTipoPRD
Local _cTexto	
Local _nPos
Local _cStatus
Local _cMens

Default _nRegOP		:= 1
Default _nOpc 		:= 3

Private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
//Private lMsHelpAuto 	:= .T.  // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
Private lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog

CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Trace001 - Inicio - Apontamento Producao - MATA681 - IDMES: "+Alltrim(SZZ->ZZ_IDMES)+ If(!Empty(SZZ->ZZ_CHASSI)," Chassi: "+AllTrim(SZZ->ZZ_CHASSI)+".","."))

Begin Sequence
	SZZ->(DbGoto(_aOP[_nRegOP]))
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+SZZ->ZZ_PRODUTO))  //posicionar o SB1
	_cTipoPRD := SB1->B1_TIPO
	//Verificar se ja envia chassi, motor, ano, idmes
	Aadd(_aGrava ,	{"H6_OP"	  	,SZZ->ZZ_OP  		,NIL})
	Aadd(_aGrava ,	{"H6_PRODUTO" 	,SZZ->ZZ_PRODUTO	,NIL})
	Aadd(_aGrava ,	{"H6_OPERAC" 	,_cOperac			,NIL})
	Aadd(_aGrava ,	{"H6_RECURSO" 	,SZZ->ZZ_RECURSO	,NIL})
	Aadd(_aGrava ,	{"H6_DTAPONT"  	,Date()				,NIL})  //SZZ->ZZ_DTINTEG
	Aadd(_aGrava ,	{"H6_DATAINI"  	,Date() 			,NIL})  //SZZ->ZZ_HRINTEG
	//Aadd(_aGrava ,	{"H6_HORAINI"	,Time()    		,NIL})	
	Aadd(_aGrava ,	{"H6_DATAFIN"	,Date() 			,NIL})
	//Aadd(_aGrava ,	{"H6_HORAFIN"	,Time()      	,NIL})
	Aadd(_aGrava ,	{"H6_PT"     	,SZZ->ZZ_TP			,NIL})
	Aadd(_aGrava ,	{"H6_LOCAL"  	,SZZ->ZZ_LOCAL		,NIL})
	Aadd(_aGrava ,	{"H6_QTDPROD"	,_nQtdeOP  			,NIL})      
	Aadd(_aGrava ,	{"H6_XIDMES"    ,SZZ->ZZ_IDMES		,NIL})
	Aadd(_aGrava ,	{"H6_XCHASSI"  	,SZZ->ZZ_CHASSI		,NIL})
	Aadd(_aGrava ,	{"H6_XMOTOR"	,SZZ->ZZ_NUMMOT  	,NIL})      
	Aadd(_aGrava ,	{"H6_XANOMOD"	,SZZ->ZZ_FABMOD  	,NIL})      
	Aadd(_aGrava ,	{"H6_OBSERVA"	,"TOTVSMES"  		,NIL})      
	_cTexto := "PROBLEMAS EXECAUTO MATA681"+CHR(13)+CHR(10)  
	MSExecAuto({|x| mata681(x)},_aGrava)  // inclusão

	/* Verificar possibilidade de validar estes campos e se existe necessidade
	If SD3->D3_TM <> "100"   //TIPO DE MOVIMENTO
	If SD3->D3_CF <> "PR0"   //Tipo de Requisicao/devolu
	*/
/*
	_cTm  := "100"  //temporario avaliar 
	_cCf  := "PR0"
	_cDoc := SubsTr(SZZ->ZZ_OP,1,Len(SC2->C2_NUM))

	Aadd(_aGrava ,{"D3_FILIAL"		, xFilial("SD3")			, NIL})
	Aadd(_aGrava ,{"D3_TM"			, _cTm						, NIL})  //verificar como localizar d3_tm tipo de movimento
	Aadd(_aGrava ,{"D3_CF"     	, _cCf		        		, Nil}) 
	Aadd(_aGrava ,{"D3_COD"    	, SZZ->ZZ_PRODUTO   		, Nil}) 
	aadd(_aGrava ,{"D3_LOCAL"   	, SZZ->ZZ_LOCAL    			, Nil})
	Aadd(_aGrava ,{"D3_QUANT"		, _nQtdeOP					, NIL})
	Aadd(_aGrava ,{"D3_OP"     	, SZZ->ZZ_OP        		, Nil}) 
	Aadd(_aGrava ,{"D3_EMISSAO"	, Date()     				, Nil}) 
	aadd(_aGrava ,{"D3_DOC"     	, _cDoc          			, Nil})
	Aadd(_aGrava ,{"D3_PARCTOT"	, SZZ->ZZ_TP				, NIL})
	//Aadd(_aGrava ,{"D3_NIVEL"		, "95"						, NIL})  //LOCALIZAR E CORRIGIR O NIVEL DA ESTRUTURA
	//Aadd(_aGrava ,{"D3_SERVIC"		, ""						, NIL})  //COD DO SERVIÇO
	Aadd(_aGrava ,{"D3_XIDMES"		, AllTrim(SZZ->ZZ_CHASSI)	, NIL})
	Aadd(_aGrava ,{"D3_XCHASSI"	, AllTrim(SZZ->ZZ_IDMES)	, NIL})
	Aadd(_aGrava ,{"D3_OBSERVA"	, "TOTVSMES"				, NIL})

	//Para que o sistema faça a baixa dos empenhos na chamada via ExecAuto, mesmo com o parâmetro Atu. Empenho está igual a Não, 
	//deve-se enviar um campo extra no array chamado "ATUEMP", com valor "T". 
	//https://tdn.totvs.com/pages/releaseview.action?pageId=6087461
	//Aadd(_aGrava ,{"ATUEMP"    	, "T"              , NIL}) 	
	//aAdd(_aGrava ,{'REQAUT'	    , "N"		  	   , Nil})
	//Para que possa realizar o apontamento de produção, onde a produção é maior que a ordem, você precisa informar a quantidade a maior no array(D3_QTMAIOR)

	_cTexto := "PROBLEMAS EXECAUTO MATA250"+CHR(13)+CHR(10)  
	MSExecAuto({|x, y| mata250(x, y)}, _aGrava, _nOpc)
*/
	If lMsErroAuto
		_aError := GetAutoGRLog()
		For _nPos := 1 To Len(_aError)
			If !Empty((AllTrim(_aError[_nPos])))  	
				_cTexto	+= 	AllTrim(_aError[_nPos])+_CEOL
			EndIf		
		Next _nPos			
		_cMensErro 	:= _cTexto
	Else
		CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Trace001 - FIM - Apontamento Producao - MATA681 - IDMES: "+Alltrim(SZZ->ZZ_IDMES)+ If(!Empty(SZZ->ZZ_CHASSI)," Chassi: "+AllTrim(SZZ->ZZ_CHASSI)+".","."))
		_cNumSeq	:= SD3->D3_NUMSEQ
	EndIf	
	//o erro e Status serão gravados na SZZ e correspondem a um unico processo
	_cTexto := ""
	If Len(_aOP) > 1
		_cTexto := AllTrim(Str(Len(_aOP)))+" OPs AGRUPADAS"
	Endif
	If Empty(_cMensErro) 
		_cMensErro  := 	"OP "+If(_nOpc==5,"EXCLUIDA","ATUALIZADA")+ " COM SUCESSO "+_CEOL
		_cStatus 	:= "A"
	Else
		_cStatus 	:= "E"
		_lRet		:= .F.
	EndIf
	//quando status for igual a emprestimo atualizar movimentação (SD3) e Saldos
	//2.0 - Apagar o SD3 do NumSeq de Emprestimo. (SZZ->ZZ_SEQVEMP) - D3_TM = '007'
	//			3.0 - Alterar a SDA e SDB do Emprestimo para o NumSeq do Apontamento Novo.
	//			3.0 - Rodar Saldo Atual. (Enviado Por WhatsApp)	
	If _cStatus == "A" .and. SZZ->ZZ_STATUS == "L"
		_aError := PCPJ1PGEMP(_cNumSeq, _cTipoPRD)
		If Len(_aError) > 0
			_cMens		:= ""
			For _nPos 	:= 1 To Len(_aError)
				_cMens 	+= _aError[_nPos]+_CEOL
			Next
			_cMensErro 	+= _cMens
			_cStatus   	:= "G"  //retorno o status erros se não conseguiu atualizar o saldo
			_lRet		:= .F.
		Else 
			_cMensErro  += 	"EMPRESTIMO PAGO COM SUCESSO - SEQ. EMPRESTIMO: "+AllTrim(SZZ->ZZ_SEQVEMP)+" SEQ. NOVO APONTAMENTO: "+AllTrim(_cNumSeq)+_CEOL
		EndIf
	// Quando for emprestimo e não for compensado o status deve sempre voltar como emprestimo
	ElseIf SZZ->ZZ_STATUS == "L"
		_cStatus 	:= "L"
	EndIf
	//Gravar atualização na SZZ tem que validar desta forma pois pode existir agrupamento
	For _nPos := 1 to Len(_aOP)
		SZZ->(DbGoto(_aOP[_nPos]))  //possiciono o SZZ para gravação
		ZPCPJ001ZZ(Upper(_cMensErro)+" "+Upper(_cTexto), _cStatus, _cNumSeq )
	Next _nPos	
End Sequence
Return _lRet


//-------------------------------------
/*/{Protheus.doc} ZPCPJ001ZZ
Gravar dados do usuario e observações
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		         
/*/
//-------------------------------------
Static Function ZPCPJ001ZZ(_cMensErro, _cStatus,_cSeqSD3)
Local _cErro		:= ""
Local _cSt			:= ""
Local _cEtapaPrd

Default _cStatus 	:= ""
Default _cMensErro	:= ""
Default _cSeqSD3	:= ""

Begin Sequence
	_cSt := If(!Empty(_cStatus),_cStatus,;
			If(!Empty(_cMensErro),"E","A"))
	//Controlar status de emprestimo não gravar status diferente de A=Processado e ou F=Problemas no Fechamento de estoque 
	If SZZ->ZZ_STATUS == "L" .and. !_cSt $ "A_L_F_B"    
		_cSt := "L"
	EndIf
	RecLock('SZZ', .F. )
	If !Empty(_cMensErro)
		_cErro := AllTrim(SZZ->ZZ_OBSPRC) + If(Empty(AllTrim(SZZ->ZZ_OBSPRC)),"",CHR(13)+CHR(10))  
		_cErro += ("*** "+Dtoc(Date())+"-"+SubsTr(Time(),1,5)+" - "+Upper(_cMensErro))
	EndIf
	SZZ->ZZ_OBSPRC  := _cErro
	SZZ->ZZ_STATUS	:= _cSt
	//Se conseguiu fazer apontamento finalizo gravando a data de apontamento final
	If _cStatus == "A"
		SZZ->ZZ_DTAPONF	:= Date()
		SZZ->ZZ_HRAPONF	:= Time()
		If !Empty(_cSeqSD3)
			SZZ->ZZ_NSEQD3 :=  _cSeqSD3
		EndIf
		//regravo a etapa de produçao para que esteja de acordo com o que esta no SB1
		If Alltrim(SZZ->ZZ_PRODUTO) <> AllTrim(SB1->B1_COD)
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(Xfilial("SB1")+SZZ->ZZ_PRODUTO))
			_cEtapaPrd := SB1->B1_XPCPSEQ
		Else
			_cEtapaPrd := SB1->B1_XPCPSEQ
		EndIf		
		SZZ->ZZ_ETAPAPD := _cEtapaPrd
	EndIf
	//SZZ->ZZ_USUAPON	:= RetCodUsr()	
	SZZ->(MsUnlock())
	ConOut("ZPCPJ001 Processado OP " +SZZ->ZZ_OP+ " Status "+SZZ->ZZ_STATUS)
End Sequence
Return Nil


//-------------------------------------
/*/{Protheus.doc} ZPJ1VLDOP
Validação da OP
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		VALIDAR SE OP POSSUI SALDO E CUMULAR SE AINDA TIVER SALDO NA OP		         
/*/
//-------------------------------------
Static Function ZPJ1VLDOP(_cOp, _cLocal, _cCodProd, _nQtdeOP )
Local _aMensErro := {}
Begin Sequence
	//Posiciono a OP referencia
	SC2->(dbSetOrder(1))  //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
	If !SC2->(DbSeek(xFilial('SC2')+_cOp))
		Aadd(_aMensErro,{"ORDEM DE PRODUCAO NAO LOCALIZADA","C"})
		Break
	EndIf	
	//Esta encerrada
	If !Empty(SC2->C2_DATRF)
		Aadd(_aMensErro,{"OP Encerrada não permite apontamento","C"})
		Break
	EndIf
	//Caso não seja Firme não validar
	If SC2->C2_TPOP <> "F"
		Aadd(_aMensErro,{"OP não possui o tipo de OP Firme","C"})
		Break
	EndIf
	//Local OP
    If SC2->C2_LOCAL <> _cLocal 
		Aadd(_aMensErro,{"Local da OP não confere com Local enviado no XML","C"})
		Break
	EndIf
	//Produto na OP
	If AllTrim(SC2->C2_PRODUTO) <> AllTrim(_cCodProd)
		Aadd(_aMensErro,{"Código de produto informado na OP diferente do código de produto informado no MES "+_cCodProd,"C"}) 
		Break
	EndIf
	//Validar a quantidade
	If SC2->C2_QUJE >= SC2->C2_QUANT 
		Aadd(_aMensErro,{"Quantidade apontada da OP " +AllTrim(STR(SC2->C2_QUJE))+;
						" Quantidade Original da OP "+AllTrim(STR(SC2->C2_QUANT))+;
		 				" Saldo da OP "+AllTrim(STR(SC2->C2_QUANT-SC2->C2_QUJE)),"C"})
		Break
	EndIf
	//Validar na quantidade acumulada verificar se tem saldo	
	If (SC2->C2_QUJE + _nQtdeOP + SZZ->ZZ_QTDEPRD) > SC2->C2_QUANT
		Aadd(_aMensErro,{"Quantidade apontada da OP " +AllTrim(STR(SC2->C2_QUJE))+;
						" Quantidade pendente BackFlush " +AllTrim(STR(_nQtdeOP))+;
						" Quantidade Original da OP "+AllTrim(STR(SC2->C2_QUANT))+;
		 				" Saldo da OP "+AllTrim(STR((SC2->C2_QUJE+_nQtdeOP+SZZ->ZZ_QTDEPRD)-SC2->C2_QUANT)),"C"})
		Break
	EndIf
End Sequence
Return _aMensErro


//-------------------------------------
/*/{Protheus.doc} ZPJ1VLVEI
Valida Veiculos
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		Vverificar se veiculo ja esta cadastrado		         
/*/
//-------------------------------------
Static Function ZPJ1VLVEI(_cProduto, _cLocal, _cGrupo, _cChassi, _cNumMotor, _cFabMod )
Local _aMensErro := {}
Local _nTamChassi	:= SuperGetMV( "CMV_PCP008"  ,,17)
Local _cAnoFab
Local _cAnoMod
Local _nValData
Begin Sequence
	If Empty(_cChassi)
		Aadd(_aMensErro, "Numero de Chassi não informado")
		Break
	EndIf
	If Len(AllTrim(_cChassi)) <> _nTamChassi
		Aadd(_aMensErro, "Numero de Chassi com tamanho divergente, verificar")
		Break
	EndIf
	If Empty(_cNumMotor)
		Aadd(_aMensErro, "Numero do motor não informado")
		Break
	EndIf
	_cAnoFab 	:= SubsTr(_cFabMod,1,4)
	_cAnoMod 	:= SubsTr(_cFabMod,5,4)
	_nValData 	:= Val(_cAnoMod) - Val(_cAnoFab)
	If _nValData > 1  .or. _nValData < 0
		Aadd(_aMensErro,"Ano de Fabricação e Modelo não é permitido") 
		Break
	EndIf 
	//Quando for emprestimo o veiculo existira e não podera retornar erro
	If SZZ->ZZ_STATUS <> "L"  
		VV1->(DbSetOrder(2))	//VV1_FILIAL+VV1_CHASSI
		If VV1->(DbSeek(xFilial('VV1')+_cChassi))
			Aadd(_aMensErro,{"VEICULO JA CADASTRADO","V"})
			Break
		EndIf
	Endif
 	//localizar a Marca
	VV2->(DbSetOrder(7))  //VV2_FILIAL+VV2_PRODUT
	If !VV2->(DbSeek(xFilial('VV2')+_cProduto))
		Aadd(_aMensErro, "MARCA DE VEÍCULO NÃO CADASTRADA PARA O VEÍCULO")
		Break
	Endif
End Begin
Return _aMensErro


//-------------------------------------
/*/{Protheus.doc} PCPJ1VEMPR
Responsável pela gravação de movimentação simples quando do emprestimo do veiculo pelo mesmo não estar liberado no Backflush
deverá gravar a movimentação, atualizar o saldo em estoque e gravar veículos
Este processo é realizado como emprestimo do veículo para posteriormente na baixa do Backflush ser atualizado
@author 	DAC - Denilso
@since 		02/02/2021
@version 	1.0
@obs		
/*/
//-------------------------------------
Static Function PCPJ1VEMPR(_lVeiculo, _aRegOp, _cTipoPRD, _nOpc)
Local _cTm			:= "007"  //devolução
Local _cCf  		:= "PR0"
Local _cGrpProd		:= AllTrim(SuperGetMV( "CMV_PCP004"  ,,'VEIA')) //parametro Grupo de produtos padrão para veiculos novos
Local _lEmpresPI	:= SuperGetMV( "CMV_PCP010"  ,,.T.)  	//Habilitar/desabilitar funcionalidade para emprestimo de PI no Backflush
Local _lEmpresPA	:= SuperGetMV( "CMV_PCP011"  ,,.T.)  	//Habilitar/desabilitar funcionalidade para emprestimo de PA no Backflush
Local _lRet			:= .T.
Local _lJob			:= .T.
Local _aError		:= {}
Local _aDadosSD3 	:= {}
Local _aMensErro	:= {}
Local _cTexto
Local _cNumSeq
Local _nPos
Local _nRegVV2	
Local _nRegSB1	
Local _nRegSC2	
Local _nRegSC3	
Local _lAchouVeic
Local _nCount
Local _cMens

Default _nOpc 		:= 3

Private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
//Private lMsHelpAuto 	:= .T.  // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
Private lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog

Begin Sequence
	//controlar se fara emprestimo
	If _cTipoPRD == "PI" .and. !_lEmpresPI
		Break
	EndIf
	If _cTipoPRD == "PA" .and. !_lEmpresPA
		Break
	EndIf
	//no caso de emprestimo deverá ser realizado um a um indiferente de veiculo
	For _nPos := 1 to Len(_aRegOp)
		If _aRegOp[_nPos,3] == "U"  //ja utilizada
			Loop	//_nPos
		EndIf
		//Criar e Atualizar Veiculo, endereçamento e Saldo
		//Posicionar Ordens de Produção            
		SZZ->(DbGoto(_aRegOp[_nPos,1]))
		//somente pegar os status com erro
		If SZZ->ZZ_STATUS <> "E"
			Loop  //_nPos
		EndIf
		SC2->(dbSetOrder(1))  //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
		If !SC2->(DbSeek(xFilial('SC2')+SZZ->ZZ_OP))
			ZPCPJ001ZZ("NÃO LOCALIZADA ORDEM DE PRODUÇÃO !", "E" )
			Loop  //_nPos
		EndIf	
		If _lVeiculo
			//MODELO DE VEICULO
			VV2->(DbSetOrder(7))  //VV2_FILIAL+VV2_PRODUT
			VV2->(DbSeek(xFilial('VV2')+SZZ->ZZ_PRODUTO))
    		//Verificar se o veiculo esta cadastrado
			_lAchouVeic := U_ZPCF009VEI(SZZ->ZZ_CHASSI, SZZ->ZZ_NUMMOT, VV2->VV2_CODMAR, VV2->VV2_MODVEI, VV2->VV2_SEGMOD, @_aMensErro)
			If _lAchouVeic
				ZPCPJ001ZZ("VEICULO JA CADASTRADO", "V" )
				Loop   //_nPos 
			EndIf	
    	EndIf
		//_cDoc:= GETSX8NUM("SD3","D3_DOC")
		//_cDoc := SubsTr(SZZ->ZZ_OP,1,Len(SC2->C2_NUM))
		Aadd(_aDadosSD3 ,{"D3_FILIAL"	, xFilial("SD3")		, NIL})
		aadd(_aDadosSD3 ,{"D3_TM"		, _cTm					, NIL})
		Aadd(_aDadosSD3 ,{"D3_CF"     	, _cCf		     		, NIL}) 
		aadd(_aDadosSD3 ,{"D3_COD"		, SZZ->ZZ_PRODUTO 		, NIL})
		aadd(_aDadosSD3 ,{"D3_QUANT"	, SZZ->ZZ_QTDEPRD		, NIL})
		aadd(_aDadosSD3 ,{"D3_LOCAL"	, SZZ->ZZ_LOCAL			, NIL})	//_cLocPad
		aadd(_aDadosSD3 ,{"D3_EMISSAO"	, Date()				, NIL})  //dDataBase
		//aadd(_aDadosSD3,{"D3_DOC"     , _cDoc          		, NIL})
		//aadd(_aDadosSD3,{"D3_OP"		, _cOP					, NIL})
		aadd(_aDadosSD3 ,{"D3_GRUPO"	, _cGrpProd 			, NIL})
		Aadd(_aDadosSD3 ,{"D3_XIDMES"	, SZZ->ZZ_IDMES			, NIL})
		Aadd(_aDadosSD3 ,{"D3_XCHASSI"	, SZZ->ZZ_CHASSI		, NIL})
		Aadd(_aDadosSD3 ,{"D3_OBSERVA"	, "TOTVSMES"			, NIL})
		/*
		aadd(_aDadosSD3,{"D3_TM"		, _cTm				, nil})
		aadd(_aDadosSD3,{"D3_COD"		, SZZ->ZZ_PRODUTO 	, nil})
		aadd(_aDadosSD3,{"D3_QUANT"		, SZZ->ZZ_QTDEPRD	, nil})
		aadd(_aDadosSD3,{"D3_LOCAL"		, SZZ->ZZ_LOCAL		, nil})
		aadd(_aDadosSD3,{"D3_EMISSAO"	, Date()			, nil})  //dDataBase
		aadd(_aDadosSD3,{"D3_GRUPO"		, _cGrpProd 		, nil})
		Aadd(_aDadosSD3,{"D3_XIDMES"	, SZZ->ZZ_IDMES		, NIL})
		Aadd(_aDadosSD3,{"D3_XCHASSI"	, SZZ->ZZ_CHASSI	, NIL})
		*/
		MsExecAuto({|x,y|Mata240(x,y)},_aDadosSD3,3)	
		If lMsErroAuto
			_aError := GetAutoGRLog()
			_cTexto := "PROBLEMAS NA GERAÇÃO DE EMPRESTIMO:+_CEOL"
			For _nCount := 1 To Len(_aError)
				If !Empty((AllTrim(_aError[_nCount])))  	
					_cTexto	+= 	AllTrim(_aError[_nCount])+_CEOL
				EndIf		
			Next _nCount			
			ZPCPJ001ZZ(_cTexto, "E" )
			Loop  //_nPos
		Else
			_cNumSeq	:= SD3->D3_NUMSEQ
		EndIf
		If _lVeiculo
			//MODELO DE VEICULO
			VV2->(DbSetOrder(7))  //VV2_FILIAL+VV2_PRODUT
			VV2->(DbSeek(xFilial('VV2')+SB1->B1_COD))
 			_nRegVV2	:= VV2->(Recno())
			_nRegSB1	:= SB1->(Recno())
			_nRegSC2	:= SC2->(Recno())
			_nRegSC3	:= SD3->(Recno())
			//Cria Veículo e atualiza relacionamento do mesmo
			_lRet := U_ZPCPF07VEI(_lJob, _nRegVV2, _nRegSB1, _nRegSC2, _nRegSC3, @_aMensErro)
			//Atualizar endereçamento
			If _lRet
				//Se conseguiu gravar veiculo atualizo algumas informações
				If VV1->(FieldPos("VV1_XSEQEP")) > 0
					RecLock('VV1', .F. )
					VV1->VV1_XSEQEP	:= _cNumSeq
					VV1->VV1_XDTVEP	:= Date()
					VV1->(MsUnlock())
				EndIf		
				U_ZPCPF07GSL(_lJob ,_nRegSB1 ,/*_nRegSH6*/ , _nRegSC3, @_aMensErro)    
			EndIf
		EndIf
		//Se ocorreu erro na gravação do saldo encerrar
		If Len(_aMensErro) > 0
			For _nCount := 1 To Len(_aMensErro)	
				_cMens 	:= "PROBLEMAS NA GERAÇÃO DE EMPRESTIMO :"+_aMensErro[_nCount,01]+"-"+_aMensErro[_nCount,02] 
				ZPCPJ001ZZ(_cMens, "E" )
			Next _nCount	
			Loop 	//_nPos
		EndIf
		//Gravar status como emprestimo no SZZ
		_cMens := If(_lVeiculo,"VEICULO","PRODUTO")+" GERADO POR EMPRESTIMO" 
		ZPCPJ001ZZ(	_cMens, "L", _cNumSeq )
		If SZZ->(FieldPos("ZZ_SEQVEMP")) > 0
			RecLock('SZZ', .F. )
			SZZ->ZZ_SEQVEMP := _cNumSeq
			SZZ->ZZ_DTVEMPR := Date()
			SZZ->(MsUnlock())
		EndIf
	Next _nPos	
End Sequence
Return _lRet


//-------------------------------------
/*/{Protheus.doc} PCPJ1PGEMP
Responsável Atualizar Veiculo retirando o emprestimo quando do processamento Backflush normal
e atualizando SD3, saldos 
@author 	DAC - Denilso
@since 		03/02/2021
@version 	1.0
@obs		
/*/
//-------------------------------------
Static Function PCPJ1PGEMP(_cNumSeq, _cTipoPRD)
Local _cAliasPesq   := GetNextAlias()
Local _aMensErro	:= {}
Local _nReg			:= SD3->(Recno())
Local _aArea		:= GetArea() 
Local _aDadosSD3 	:= {}
Local _cTexto		:= ""
Local _aError
Local _nPos

Begin Sequence
	If Empty(SZZ->ZZ_SEQVEMP)
		Aadd(_aMensErro,"NAO INFORMADO A SEQUENCIA PARA EMPRESTIMO")
		Break
	Endif
	//Somente ajustar os saldos do PA 
	If _cTipoPRD <> "PA"  .and. SB1->B1_LOCALIZ = "N"
		Break
	EndIf
	//*****************************************************************************
	// APÓS REALIZAR O APONTAMENTO CORRETO DE PRODUÇÃO O EMPRESTIMO SERÁ PAGO.
	// LOCALIZA A MOVIMENTAÇÃO NO SDB REFERENTE AO EMPRESTIMO.
	// ALTERA A SDB E GRAVA O NUMSEQ DO NOVO APONTAMENTO NA MOV. DE EMPRESTIMO ANTIGO.
	// ISSO É FEITO PARA DEIXAR O SISTEMA CORRETO.
	////*****************************************************************************
	SDB->(DbSetOrder(1))  //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
  	BeginSql Alias _cAliasPesq	
   	    SELECT 	ISNULL(SDB.R_E_C_N_O_,0) NREGSDB
	    FROM %Table:SDB%  SDB  
		WHERE 	SDB.DB_FILIAL 	= %xFilial:SDB%
			AND SDB.DB_PRODUTO  = %Exp:SZZ->ZZ_PRODUTO%
			AND SDB.DB_LOCAL	= %Exp:SZZ->ZZ_LOCAL%
			AND SDB.DB_NUMSEQ	= %Exp:SZZ->ZZ_SEQVEMP%
		    AND SDB.%notDel% 
	EndSQL
	If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGSDB == 0
		Aadd(_aMensErro,"NAO ENCONTRADO SALDO NO SDB PARA SEQUENCIA DE EMPRESTIMO")
		Break
	EndIf
	SDB->(DbGoto((_cAliasPesq)->NREGSDB))
	RecLock("SDB",.f.)
	SDB->DB_DOC		:= SubsTr(SZZ->ZZ_OP,1,Len(SC2->C2_NUM))
	SDB->DB_NUMSEQ	:= _cNumSeq //SZZ->ZZ_NSEQD3 
	SDB->(MsUnlock())
	(_cAliasPesq)->(DbCloseArea())
	//*****************************************************************************
	// APÓS REALIZAR O APONTAMENTO CORRETO DE PRODUÇÃO O EMPRESTIMO SERÁ PAGO.
	// LOCALIZA A MOVIMENTAÇÃO NO SDA REFERENTE AO NOVO APONTAMENTO DE PRODUÇÃO.
	// ALTERA O SALDO PARA 0, COMO SE TIVESSE SIDO ENDEREÇADO.
	////*****************************************************************************
	SDA->(DbSetOrder(1))  //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
  	BeginSql Alias _cAliasPesq	
   	    SELECT 	ISNULL(SDANEW.R_E_C_N_O_,0) NREGSDA
	    FROM %Table:SDA%  SDANEW  
		WHERE 	SDANEW.DA_FILIAL 	= %xFilial:SDA%
			AND SDANEW.DA_PRODUTO  	= %Exp:SZZ->ZZ_PRODUTO%
			AND SDANEW.DA_LOCAL		= %Exp:SZZ->ZZ_LOCAL%
			AND SDANEW.DA_NUMSEQ	= %Exp:_cNumSeq%
		    AND SDANEW.%notDel% 
	EndSQL
	If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGSDA == 0
		Aadd(_aMensErro,"NAO ENCONTRADO SALDO NO SDA PARA SEQUENCIA DO NOVO APONTAMENTO.")
		Break
	EndIf
	// APAGA O SDA DO APONTAMENTO NOVO.
	// ALTERA O NUMSEQ PARA A MOVIMENTAÇÃO DO APONTAMENTO.
	SDA->(DbGoto((_cAliasPesq)->NREGSDA))
	RecLock("SDA",.f.)
	SDA->DA_SALDO	:= 0
	SDA->(MsUnlock())
	(_cAliasPesq)->(DbCloseArea())
	//*****************************************************************************
	// APÓS REALIZAR O APONTAMENTO CORRETO DE PRODUÇÃO O EMPRESTIMO SERÁ PAGO.
	// LOCALIZA A MOVIMENTAÇÃO NO SDA REFERENTE AO EMPRESTIMO.
	// ALTERA A SDA E GRAVA O SALDO COM 1, PARA PODER ESTORNAR A MOVIMENTAÇÃO.
	////*****************************************************************************
	SDA->(DbSetOrder(1))  //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
  	BeginSql Alias _cAliasPesq	
   	    SELECT 	ISNULL(SDAEMP.R_E_C_N_O_,0) NREGSDA
	    FROM %Table:SDA%  SDAEMP  
		WHERE 	SDAEMP.DA_FILIAL 	= %xFilial:SDA%
			AND SDAEMP.DA_PRODUTO  	= %Exp:SZZ->ZZ_PRODUTO%
			AND SDAEMP.DA_LOCAL		= %Exp:SZZ->ZZ_LOCAL%
			AND SDAEMP.DA_NUMSEQ	= %Exp:SZZ->ZZ_SEQVEMP%
		    AND SDAEMP.%notDel% 
	EndSQL
	If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGSDA == 0
		Aadd(_aMensErro,"NAO ENCONTRADO SALDO NO SDA PARA SEQUENCIA DE EMPRESTIMO")
		Break
	EndIf
	// ALTERA O NUMSEQ PARA A MOVIMENTAÇÃO DO APONTAMENTO.
	SDA->(DbGoto((_cAliasPesq)->NREGSDA))
	RecLock("SDA",.f.)
	SDA->DA_SALDO	:= SZZ->ZZ_QTDEPRD //1
	SDA->(MsUnlock())
	(_cAliasPesq)->(DbCloseArea())
End Sequence
//*****************************************************************************
// APÓS REALIZAR O APONTAMENTO CORRETO DE PRODUÇÃO O EMPRESTIMO SERÁ PAGO.
// FAZ O ESTORNO DO EMPRESTIMO.
////*****************************************************************************
If Len(_aMensErro) == 0
	Private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
	Private lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog

	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Trace006 - Inicio - Estorno do Emprestimo - ZPCPJ001 - IDMES: "+Alltrim(SZZ->ZZ_IDMES)+ If(!Empty(SZZ->ZZ_CHASSI)," Chassi: "+AllTrim(SZZ->ZZ_CHASSI)+".","."))

	_aDadosSD3     := {}	
	aAdd(_aDadosSD3, {"D3_NUMSEQ" , SZZ->ZZ_SEQVEMP   	, Nil})
	aAdd(_aDadosSD3, {"INDEX"     , 4       		 	, Nil})
 	MsExecAuto({|x,y|Mata240(x,y)},_aDadosSD3,5) //5-ESTORNO	
	If lMsErroAuto
		_aError 	:= GetAutoGRLog()
		_cTexto		:= ""  //ajustado estava vindo como nil
		For _nPos := 1 To Len(_aError)
			If !Empty((AllTrim(_aError[_nPos])))  	
				_cTexto	+= 	AllTrim(_aError[_nPos])+_CEOL
			EndIf		
		Next _nPos		
		Aadd(_aMensErro,_cTexto)	
	EndIf	
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Trace006 - FIM - Estorno do Emprestimo - ZPCPJ001 - IDMES: "+Alltrim(SZZ->ZZ_IDMES)+ If(!Empty(SZZ->ZZ_CHASSI)," Chassi: "+AllTrim(SZZ->ZZ_CHASSI)+".","."))
EndIf
If Select(_cAliasPesq) <> 0  
	(_cAliasPesq)->(DbCloseArea())
Endif
If File(_cAliasPesq+GetDBExtension())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
SD3->(DbGoto(_nReg))
RestArea( _aArea )
Return _aMensErro


//-------------------------------------
/*/{Protheus.doc} ZPJ1MNTOP1
Verificar emprenho
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		VALIDAR SE OP POSSUI SALDO E CUMULAR SE AINDA TIVER SALDO NA OP		         
/*/
//-------------------------------------
Static Function ZPJ1MNTOP1( _cNumOp, _cProduto, _cLocal,  _aRegOp, _lVeiculo, _nCustoMax)
Local _cAliasPesq   := GetNextAlias()
Local _nQtdeOP		:= 0

Local _lRet			:= .T.
Local _cMens 
Local _nPos
Local _cStatus

Begin Sequence
	//Qtde da op para lançamento
	For _nPos := 1 To Len(_aRegOp)
		If _aRegOp[_nPos,3] == "A"
			_nQtdeOP += _aRegOp[_nPos,2]
		EndIf
	Next
	//no caso nõ achou nenhuma op para apontar
	If _nQtdeOP == 0
		_lRet := .F.
		Break
	Endif
	//D4_PRODUTO = PRODUTO PAI
   	BeginSql Alias _cAliasPesq	
		SELECT 	CONSUMO.D4_OP, 
				CONSUMO.D4_COD, 
				CONSUMO.D4_LOCAL, 
				CONSUMO.B1_TIPO, 
				CONSUMO.B1_XPCPSEQ, 
				CONSUMO.B1_RASTRO, 
				CONSUMO.B1_LOCALIZ, 
				CONSUMO.QTDE_CONSUMO, 
				CONSUMO.SALDOSB2,
				TRUNC(CONSUMO.SALDOSB2 / CONSUMO.NFATOR) AS SALDO_PRINCIPAL,
				CONSUMO.NFATOR,
               	CONSUMO.B2_VATU1,
				CONSUMO.B2_QATU 
		FROM ( 	SELECT 	SD4.D4_OP,
                       	SD4.D4_QTDEORI ,
                       	SD4.D4_QUANT ,
                   	 	SD4.D4_LOCAL,
                       	SD4.D4_COD,
                       	SC2.C2_QUANT,
                       	SD4.D4_QTDEORI / SC2.C2_QUANT NFATOR,
						((SD4.D4_QTDEORI / SC2.C2_QUANT) *  %Exp:_nQtdeOP% ) AS QTDE_CONSUMO,    
                       	SB2.B2_VATU1,
                       	SB2.B2_QATU,
                       	( SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QACLASS ) SALDOSB2,
                       	SB1.B1_TIPO,
                       	SB1.B1_XPCPSEQ,
                       	SB1.B1_RASTRO,
                       	SB1.B1_LOCALIZ
               	FROM %Table:SD4%  SD4 
                JOIN SB2010 SB2 ON
                   		SB2.B2_FILIAL 	= %xFilial:SB2%
                   	AND SB2.B2_COD		= SD4.D4_COD
                   	AND SB2.B2_LOCAL	= SD4.D4_LOCAL
                   	AND SB2.%notDel% 
                JOIN %Table:SB1% SB1 ON 
                   		SB1.B1_FILIAL 	= %xFilial:SB1%
                   	AND SB1.B1_COD		= SD4.D4_COD
					AND SB1.B1_TIPO NOT IN ('GG','MO')
                   	AND SB1.%notDel% 
                JOIN %Table:SC2% SC2 ON
                        SC2.C2_FILIAL 	= %xFilial:SC2%
                    AND SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN = SD4.D4_OP
                    AND SC2.C2_PRODUTO	= SD4.D4_PRODUTO
                    AND SC2.%notDel% 
               	WHERE 	SD4.D4_FILIAL 	= %xFilial:SD4% 
                   	AND SD4.D4_OP		= %Exp:_cNumOp%
                   	AND SD4.%notDel% 
               	)CONSUMO
		WHERE CONSUMO.QTDE_CONSUMO > CONSUMO.SALDOSB2
		ORDER BY SALDO_PRINCIPAL
    EndSQL
	//AND SB1.B1_XPCPSEQ 	<> ' '
    //AND SB1.B1_TIPO	    = 'PI' 
	//Caso não retornou nenhum erro podera prosseguir com lançamento
	If (_cAliasPesq)->(Eof())
		Break
	EndIf	
	While (_cAliasPesq)->(!Eof())
		//localizar o saldo que ja esta calculada a quantidade necessária minima para a produção será a quantidade de OP
		For _nPos := 1 To Len(_aRegOp)
	 		If (_cAliasPesq)->SALDO_PRINCIPAL >= _nQtdeOP
		 		Break
			EndIf	 
			SZZ->(DbGoto(_aRegOp[_nPos,1]))
			//quando for emprestimo necessario ajustar status
			If SZZ->ZZ_STATUS == "L"
				_cStatus := "L"
			Else
				_cStatus := "E"
			Endif
			//Deduzo saldo para atender as OPs  
			_nQtdeOP			-=  _aRegOp[_nPos,2]  //ajustar a quantidade
			_aRegOp[_nPos,3] 	:=  "E"
			_cMens 		:= 	"PRD : "+AllTrim((_cAliasPesq)->D4_COD)+" - CONSUMO TOTAL : "+AllTrim(Str((_cAliasPesq)->QTDE_CONSUMO))+" "+;
							"SALDO EXISTENTE "+ AllTrim(Str((_cAliasPesq)->SALDOSB2))+" INSUFICIENTE."
			ZPCPJ001ZZ("*** "+_cMens, _cStatus)
			_lRet := .F.  //não processou todas as OPs
		Next
		(_cAliasPesq)->(DbSkip())
	EndDo
End Sequence
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _lRet


//-------------------------------------
/*/{Protheus.doc} ZPJ1MNTOP2
Verificar Saldos das MPs
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		Validar se existe saldo na OP para MP caso não exista no total verificar se pode utilizar o minimo		         
/*/
//-------------------------------------
Static Function ZPJ1MNTOP2(_cNumOp, _cProduto, _cLocal,  _aRegOp, _lVeiculo, _nCustoMax)
Local _cAliasPesq   := GetNextAlias()
Local _lRet			:= .T.
Local _nQtdeOP		:= 0
Local _nPos

Begin Sequence
	//Qtde da op para lançamento
	For _nPos := 1 To Len(_aRegOp)
		If _aRegOp[_nPos,3] == "A"   //Somente pegar as que foram selecionadas pela validação de PI
			_nQtdeOP += _aRegOp[_nPos,2]
		EndIf
	Next
	If _nQtdeOP == 0
		_lRet := .F.
		Break
	EndIf	
   	BeginSql Alias _cAliasPesq	
		SELECT 	CONSUMO.D4_OP, 
				CONSUMO.D4_COD, 
				CONSUMO.D4_LOCAL, 
				CONSUMO.NREGSD4,
				CONSUMO.B1_TIPO, 
				CONSUMO.B1_XPCPSEQ, 
				CONSUMO.B1_RASTRO, 
				CONSUMO.B1_LOCALIZ, 
				CONSUMO.QTDE_CONSUMO, 
				CONSUMO.SALDOSB2,
				TRUNC(CONSUMO.SALDOSB2 / CONSUMO.NFATOR) AS SALDO_PRINCIPAL,
				CONSUMO.NFATOR,
               	CONSUMO.B2_VATU1,
				CONSUMO.B2_QATU,
				CONSUMO.B2_VATU1/CONSUMO.B2_QATU CUSTO_UNIT,
				CONSUMO.NREGSD4 
		FROM ( 	SELECT 	SD4.D4_OP,
                       	SD4.D4_QTDEORI ,
                       	SD4.D4_QUANT ,
                   	 	SD4.D4_LOCAL,
                       	SD4.D4_COD,
						ISNULL(SD4.R_E_C_N_O_,0) NREGSD4,   
                       	SC2.C2_QUANT,
                       	SD4.D4_QTDEORI / SC2.C2_QUANT NFATOR,
						((SD4.D4_QTDEORI / SC2.C2_QUANT) *  %Exp:_nQtdeOP% ) AS QTDE_CONSUMO,    
                       	SB2.B2_VATU1,
                       	SB2.B2_QATU,
                       	( SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QACLASS ) SALDOSB2,
                       	SB1.B1_TIPO,
                       	SB1.B1_XPCPSEQ,
                       	SB1.B1_RASTRO,
                       	SB1.B1_LOCALIZ
               	FROM %Table:SD4%  SD4 
                JOIN SB2010 SB2 ON
                   		SB2.B2_FILIAL 	= %xFilial:SB2%
                   	AND SB2.B2_COD		= SD4.D4_COD
                   	AND SB2.B2_LOCAL	= SD4.D4_LOCAL
                   	AND SB2.%notDel% 
                JOIN %Table:SB1% SB1 ON 
                   		SB1.B1_FILIAL 	= %xFilial:SB1%
                   	AND SB1.B1_COD		= SD4.D4_COD
       				AND SB1.B1_TIPO	= 'MP' 
                   	AND SB1.%notDel% 
                JOIN %Table:SC2% SC2 ON
                        SC2.C2_FILIAL 	= %xFilial:SC2%
                    AND SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN = SD4.D4_OP
                    AND SC2.C2_PRODUTO	= SD4.D4_PRODUTO
                    AND SC2.%notDel% 
               	WHERE 	SD4.D4_FILIAL 	= %xFilial:SD4% 
                   	AND SD4.D4_OP		= %Exp:_cNumOp%
                   	AND SD4.%notDel% 
               	)CONSUMO
		WHERE CONSUMO.QTDE_CONSUMO > CONSUMO.SALDOSB2
		ORDER BY SALDO_PRINCIPAL
    EndSQL
	//Caso não retornou nenhum erro podera prosseguir com lançamento
	If (_cAliasPesq)->(Eof())
		Break
	EndIf	
	While (_cAliasPesq)->(!Eof())
		//localizar o saldo que ja esta calculada a quantidade necessária minima para a produção será a quantidade de OP
		For _nPos := 1 To Len(_aRegOp)
	 		If (_cAliasPesq)->SALDO_PRINCIPAL >= _nQtdeOP
		 		Break
			EndIf	 
			SZZ->(DbGoto(_aRegOp[_nPos,1]))
			//quando for emprestimo necessario ajustar status
			If SZZ->ZZ_STATUS == "L"
				_cStatus := "L"
			Else
				_cStatus := "E"
			Endif
			//Deduzo saldo para atender as OPs  
			_nQtdeOP			-=  _aRegOp[_nPos,2]  //ajustar a quantidade
			_aRegOp[_nPos,3] 	:=  "E"
			_cMens 		:= 	"PRD MP: "+AllTrim((_cAliasPesq)->D4_COD)+" - CONSUMO TOTAL : "+AllTrim(Str((_cAliasPesq)->QTDE_CONSUMO))+" "+;
							"SALDO EXISTENTE "+ AllTrim(Str((_cAliasPesq)->SALDOSB2))+" INSUFICIENTE, REF. AO PRODUTO "+SZZ->ZZ_PRODUTO+"."
			ZPCPJ001ZZ("*** "+_cMens, _cStatus)
			_lRet := .F.  //não processou todas as OPs
		Next
		(_cAliasPesq)->(DbSkip())
	EndDo
End Sequence
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _lRet




//-------------------------------------
/*/{Protheus.doc} ZPJ1MNTOP3
Verificar emprenho
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		Verificar o saldo das MPs e PIs sem etapara caso não tenha apagar emprenhos de acordo com o custo		         
/*/
//-------------------------------------
Static Function ZPJ1MNTOP3(_cNumOp, _cProduto, _cLocal,  _aRegOp, _lVeiculo, _nCustoMax)
Local _cAliasPesq   := GetNextAlias()
Local _lRet			:= .T.
Local _lApagaEmp    := SuperGetMV( "CMV_PCP009"  ,,.F.)  //parametro para habilitar/desabilitar funcionalidade ZPCPF010
Local _nQtdeOP		:= 0
Local _aLogRet		:= {}
Local _nPos
Local _nCount
Local _lCusto

Begin Sequence
	//parametrizado provavelmente não ira utilizar para apagar empenho
	If !_lApagaEmp
		Break
	EndIf	
	//Qtde da op para lançamento
	For _nPos := 1 To Len(_aRegOp)
		If _aRegOp[_nPos,3] == "E"   //pegar somente as que contem erros
			_nQtdeOP += _aRegOp[_nPos,2]
		EndIf
	Next
	If _nQtdeOP == 0
		Break
	EndIf	
   	BeginSql Alias _cAliasPesq	
		SELECT 	CONSUMO.D4_OP, 
				CONSUMO.D4_COD, 
				CONSUMO.D4_LOCAL, 
				CONSUMO.NREGSD4,
				CONSUMO.B1_TIPO, 
				CONSUMO.B1_XPCPSEQ, 
				CONSUMO.B1_RASTRO, 
				CONSUMO.B1_LOCALIZ, 
				CONSUMO.QTDE_CONSUMO, 
				CONSUMO.SALDOSB2,
				TRUNC(CONSUMO.SALDOSB2 / CONSUMO.NFATOR) AS SALDO_PRINCIPAL,
				CONSUMO.NFATOR,
               	CONSUMO.B2_VATU1,
				CONSUMO.B2_QATU,
				CONSUMO.B2_VATU1/CONSUMO.B2_QATU CUSTO_UNIT,
				CONSUMO.NREGSD4 
		FROM ( 	SELECT 	SD4.D4_OP,
                       	SD4.D4_QTDEORI ,
                       	SD4.D4_QUANT ,
                   	 	SD4.D4_LOCAL,
                       	SD4.D4_COD,
						ISNULL(SD4.R_E_C_N_O_,0) NREGSD4,   
                       	SC2.C2_QUANT,
                       	SD4.D4_QTDEORI / SC2.C2_QUANT NFATOR,
						((SD4.D4_QTDEORI / SC2.C2_QUANT) *  %Exp:_nQtdeOP% ) AS QTDE_CONSUMO,    
                       	SB2.B2_VATU1,
                       	SB2.B2_QATU,
                       	( SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QACLASS ) SALDOSB2,
                       	SB1.B1_TIPO,
                       	SB1.B1_XPCPSEQ,
                       	SB1.B1_RASTRO,
                       	SB1.B1_LOCALIZ
               	FROM %Table:SD4%  SD4 
                JOIN SB2010 SB2 ON
                   		SB2.B2_FILIAL 	= %xFilial:SB2%
                   	AND SB2.B2_COD		= SD4.D4_COD
                   	AND SB2.B2_LOCAL	= SD4.D4_LOCAL
                   	AND SB2.%notDel% 
                JOIN %Table:SB1% SB1 ON 
                   		SB1.B1_FILIAL 	= %xFilial:SB1%
                   	AND SB1.B1_COD		= SD4.D4_COD
       				AND (SB1.B1_TIPO	= 'MP' OR ( SB1.B1_TIPO	= 'PI' AND SB1.B1_XPCPSEQ = ' ') )
                   	AND SB1.%notDel% 
                JOIN %Table:SC2% SC2 ON
                        SC2.C2_FILIAL 	= %xFilial:SC2%
                    AND SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN = SD4.D4_OP
                    AND SC2.C2_PRODUTO	= SD4.D4_PRODUTO
                    AND SC2.%notDel% 
               	WHERE 	SD4.D4_FILIAL 	= %xFilial:SD4% 
                   	AND SD4.D4_OP		= %Exp:_cNumOp%
                   	AND SD4.%notDel% 
               	)CONSUMO
		WHERE CONSUMO.QTDE_CONSUMO > CONSUMO.SALDOSB2
		ORDER BY SALDO_PRINCIPAL
    EndSQL
	//Caso não retornou nenhum erro podera prosseguir com lançamento
	If (_cAliasPesq)->(Eof())
		Break
	EndIf	
	_lRet  		:= .T.
	_lCusto		:= .T.
	While (_cAliasPesq)->(Eof())
		//verificar se existe saldo a ser consumido maior que saldo em estoque
		If (_cAliasPesq)->QTDE_CONSUMO > (_cAliasPesq)->SALDO_PRINCIPAL  
			Aadd(_aGravaSD4,{	(_cAliasPesq)->NREGSD4,;			//01
								(_cAliasPesq)->QTDE_CONSUMO, ;		//02
								(_cAliasPesq)->SALDOSB2, ;			//03
								_nCustoMax, ;						//04
								(_cAliasPesq)->NFATOR * (_cAliasPesq)->QTDE_SZZ,;	//05
								(_cAliasPesq)->NFATOR,;				//06
								(_cAliasPesq)->CUSTO_UNIT, ;		//07
								If(_nCustoMax > 0 .and. (_cAliasPesq)->CUSTO_UNIT <= _nCustoMax,"1","2"), ;  //08
								(_cAliasPesq)->D4_COD, ;			//09
								(_cAliasPesq)->SALDO_PRINCIPAL;		//10
								})
			//Se não atende ao custo minimo não será utilizado
			If (_cAliasPesq)->CUSTO_UNIT > _nCustoMax .and. (_cAliasPesq)->SALDO_PRINCIPAL < (_cAliasPesq)->QTDE_CONSUMO
				_lCusto := .F.
			EndIf
		EndIf
		(_cAliasPesq)->(DbSkip())
	EndDo
	//Caso não possa prosseguir por valores de custo e não tenho quantidade minima aborto
	If !_lCusto  
		//Enviar email sobre custo maior não permitido a deleção
		_aLogRet := ZPCPJ1EMAI(_aGravaSD4, _aRegOp)
		_lRet := .F.
		Break
	EndIf
	//posso apagar o restante pois utilizei o minimo
	If Len(_aGravaSD4) > 0 
		_lRet := ZPCPJ1DEMP(_aGravaSD4, @_aLogRet, _aRegOp)
		//Caso deletou o empenho devo liberar o processo para a geração
		If _lRet .and. Len(_aLogRet) == 0
			For _nPos := 1 to Len(_aRegOp) 
				If _aRegOp[_nPos,3] <> "U"   //não pegar os utilizados
					_aRegOp[_nPos,3] := "A"
				EndIf
			Next		
		EndIf
	EndIf
End Sequence
//Atualizar mensagens e status
If Len(_aLogRet) > 0
	For _nCount  := 1 To Len(_aLogRet)
		For _nPos := 1 to Len(_aRegOp) 
			If _aRegOp[_nPos,3] <> "A" .and. _aRegOp[_nPos,3] <> "U"//se não estiver aprovada para apontamento gravo os logs
				SZZ->(DbGoto(_aRegOp[_nPos,1]))  //possiciono o SZZ para gravação
				_aRegOp[_nPos,3] := "E"  //If(_lRet,"A",If(SZZ->ZZ_STATUS=="L","L","E"))   //quando status estiver de emprestimo não modificar
				ZPCPJ001ZZ("### "+_aLogRet[_nPos,1], _aLogRet[_nPos,2] )
			EndIf
		Next _nPos
	Next _nCount	
EndIf	
//Caso não ocorreu erro envio todos
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _lRet


//-------------------------------------
/*/{Protheus.doc} ZPCPJ1DEMP
Apagar empenho
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		https://tdn.totvs.com/pages/releaseview.action?pageId=415699242
/*/
//-------------------------------------
Static Function ZPCPJ1DEMP(_aGravaSD4, _aLogRet, _aRegOp)
Local _aGravaSZI	:= {}
Local _aEmpenho 	:= {}
Local _lRet 		:= .T.
Local _aLog			:= {}
Local _aError
Local _cTexto
Local _nPos
Local _nCount

Default _aLogRet 	:= {}

Private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
//Private lMsHelpAuto 	:= .T.  // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
Private lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog

Begin Sequence
	_lRet := .T.
	Begin Transaction
		For _nPos := 1 To Len(_aGravaSD4)
			If _aGravaSD4[_nPos,8] == "2"  //indica que não pode remover empenho
				Loop
			EndIf 
			SD4->(DbGoto( _aGravaSD4[_nPos,1] ))
			_aEmpenho := {}
			Aadd(_aEmpenho,{"D4_COD"		,SD4->D4_COD		,Nil})
			Aadd(_aEmpenho,{"D4_OP"		    ,SD4->D4_OP			,Nil})
			/*
			Aadd(_aEmpenho,{"D4_LOCAL"		,SD4->D4_LOCAL		,Nil})
			Aadd(_aEmpenho,{"D4_QTSEGUM"	,SD4->D4_QTSEGUM   	,Nil})
			Aadd(_aEmpenho,{"D4_QTDEORI"  	,SD4->D4_QTDEORI    ,Nil})
			Aadd(_aEmpenho,{"D4_QUANT"		,SD4->D4_QUANT      ,Nil})
    		*/
    		//Guardo dados para gravar em tabela especifica referente a deleção do empenho
			For _nCount := 1 To SD4->(FCount())
				Aadd(_aGravaSZI, {SD4->(FieldName(_nCount)), SD4->(FieldGet(FieldPos(FieldName(_nCount)))), Nil})
			Next _Count
			//Tenho que fazer isto quando os valores entao diferentes entre a qtde origem e a quantidade senao não deleta
			If SD4->D4_QTDEORI <> SD4->D4_QUANT
				SD4->(RecLock('SD4', .F. ))
				SD4->D4_QTDEORI := SD4->D4_QUANT  //_nEmpenho
				SD4->(MsUnlock())
			EndIf	

			MSExecAuto({|x,y| mata380(x,y)},_aEmpenho,5)
			If lMsErroAuto
				_aError := GetAutoGRLog()
				For _nPos := 1 To Len(_aError)
					If !Empty((AllTrim(_aError[_nPos])))  	
						_cTexto	+= 	Upper(AllTrim(_aError[_nPos]))+_CEOL
					EndIf		
				Next _nPos			
				Aadd(_aLogRet,{"NÃO FOI POSSIVEL REMOVER EMPENHO DO PRODUTO "+AllTrim(SD4->D4_COD)+_CEOL+_cTexto,;
				 			"E" })
				_lRet := .F.			 	
				Exit
			EndIf	
			//se não ocorreu erro gravar ocorrencia informativa
			//GRAVAR TABELA CUSTOMIZADA REGISTRO DELETADO
			ZPCPJ1GSZI	(_aGravaSZI, ;
						_aGravaSD4[_nPos,1] /*_nRegSD4*/,	;
						_aGravaSD4[_nPos,2] /*_nQtdeConv*/, ;
						_aGravaSD4[_nPos,3] /*_nSaldoEst*/, ; 
						_aGravaSD4[_nPos,4] /*_nCustoMax*/, ; 
						_aGravaSD4[_nPos,5] /*_nQtdeApont*/,;
						_aGravaSD4[_nPos,6] /*_nQtdeFator*/,;
						_aGravaSD4[_nPos,7] /*_nCustoSB2*/, ;
						_aGravaSD4[_nPos,8] /*Tipo Operacao*/)
			Aadd(_aLog,{"PRODUTO "+AllTrim(SD4->D4_COD)+" COM EMPENHO REMOVIDO COM SUCESSO",;
						"I" })
			_aGravaSZI	:= {}
		Next	 				
		//Caso exista erro retornar processo
		If !_lRet
			DisarmTransaction()
		Endif
	End Transaction	
End Sequence
//Existem ocorrencias informativas
If Len(_aLog) > 0
	For _nCount := 1 To Len(_aLog)
		For _nPos := 1 To Len(_aRegOp)
			If _aRegOp[_nPos,3] <> "U"
				SZZ->(DbGoto(_aRegOp[_nPos,1]))  //possiciono o SZZ para gravação
				ZPCPJ001ZZ(Upper(_aLog[_nCount,1]), _aLog[_nCount,2] )
			EndIf
		Next		
	Next
EndIf
Return _lRet


//-------------------------------------
/*/{Protheus.doc} ZPCPJ1GSZI
Responsavel pela gravação do empenho
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		
/*/
//-------------------------------------
Static Function	ZPCPJ1GSZI(_aGravaSZI, _nRegSD4, _nQtdeConv, _nSaldoEst, _nCusto, _nQtdeApont, _nQtdeFator,_nCustoSB2, _cTipoOper)
Local _lRet := .T.
Begin Sequence
	SZI->(RecLock('SZI', .T. ))
	SZI->ZI_FILIAL 	:= 	XFilial("SZI")
	SZI->ZI_OP     	:= ZPCPJ1PVAR("D4_OP",_aGravaSZI)
	SZI->ZI_CODPRD 	:= ZPCPJ1PVAR("D4_COD",_aGravaSZI)
	SZI->ZI_LOCAL  	:= ZPCPJ1PVAR("D4_LOCAL",_aGravaSZI)
	SZI->ZI_QTDEORI	:= ZPCPJ1PVAR("D4_QTDEORI",_aGravaSZI)
	SZI->ZI_QTDEEMP	:= ZPCPJ1PVAR("D4_QUANT",_aGravaSZI)
	SZI->ZI_QTSEGEM	:= ZPCPJ1PVAR("D4_QTSEGUM",_aGravaSZI)
	SZI->ZI_CUSTO  	:= _nCusto
	SZI->ZI_TRT    	:= ZPCPJ1PVAR("D4_TRT",_aGravaSZI)
	SZI->ZI_LOTECTL	:= ZPCPJ1PVAR("D4_LOTECTL",_aGravaSZI)
	SZI->ZI_DTVALID	:= ZPCPJ1PVAR("D4_DTVALID",_aGravaSZI)
	SZI->ZI_PRDPAI 	:= ZPCPJ1PVAR("D4_PRODUTO",_aGravaSZI)
	SZI->ZI_DATAEMP	:= ZPCPJ1PVAR("D4_DATA",_aGravaSZI)
	SZI->ZI_QTDEPAI := _nQtdeApont
	SZI->ZI_QTDEFCV := _nQtdeFator
	SZI->ZI_QTDEOP 	:= _nQtdeConv
	SZI->ZI_SLDOEST	:= _nSaldoEst 
	SZI->ZI_NREGSD4	:= _nRegSD4
	SZI->ZI_CODUSU 	:= RetCodUsr()
	SZI->ZI_DATADEL	:= Date()
	SZI->ZI_HORADEL := Time()
	SZI->(MsUnlock())
End Sequence
Return _lRet


//-------------------------------------
/*/{Protheus.doc} ZPCPJ1PVAR
funcionalidade responsavel por retornar conteudo da matriz chamada ZPCPJ1GSZI
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		
/*/
//-------------------------------------
Static Function ZPCPJ1PVAR(_cCampo,_aChave)
Local _nPos := 0
Local _xRet 
Begin Sequence
	_nPos := aScan(_aChave,{|x| AllTrim(_cCampo)  == AllTrim(x[1]) })
	_xRet := _aChave[_nPos,2]
End Sequence		
Return _xRet


//-------------------------------------
/*/{Protheus.doc} ZPCPJ1EMAI
Responsavel por tratar registros que não conseguiu apagar empenho devido ao custo superior enviar e-mail
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		
/*/
//-------------------------------------
Static Function ZPCPJ1EMAI(_aGravaSD4, _aRegOp)
Local _aMens	:= {}
Local _aLog		:= {}
Local _aChave	:= {}
Local _cOP
Local _nPos
Local _cTexto
Local _cCusto
Local _cCustoMax
Local _cSaldo
Local _cQtdeConv
Local _cTitulo
Local _cProduto
Local _cChassi
Local _cIdent
Local _cIdMes

Begin Sequence
	//Posiciono na primeira op 
	SZZ->(DbGoto(_aRegOp[1,1]))
	_cTitulo := "Informações processamento BACKFLUSH 3.0"
	//montar a chave para enviar por email
	_cOP 		:=	SZZ->ZZ_OP	
	_cProduto 	:=  SZZ->ZZ_PRODUTO
	_cChassi	:= 	SZZ->ZZ_CHASSI
	_cIdent		:= 	""
	_cIdMes		:= SZZ->ZZ_IDMES
	//guardo as ops para informação no e_mail
	_cOP := If(Len(_aRegOp)>1,"OPs Agrupadas","OP")+": " 
	_cOP += SZZ->ZZ_OP
	//Atualiza IDENT
	U_ZPCPF09PS(@_aChave, "D3_IDENT", _cOP)  
	For _nPos := 1 To Len(_aGravaSD4)
		If _aGravaSD4[_nPos,8] == "1"
			Loop
		EndIf 
		//Posiciono o produto
		//SB1->(DbSeek(XFilial("SB1")+_aGravaSD4[_nPos,9]))
		_cCusto 	:= AllTrim(Str(_aGravaSD4[_nPos,7]))
		_cCustoMax 	:= AllTrim(Str(_aGravaSD4[_nPos,4]))
		_cSaldo		:= AllTrim(Str(_aGravaSD4[_nPos,3]))
		_cQtdeConv	:= AllTrim(Str(_aGravaSD4[_nPos,2]))
		_cProduto   := AllTrim(_aGravaSD4[_nPos,9])
		_cTexto 	:= "Produto "+_cProduto+" com custo Superior " +_cCusto+ " ao limite estabelecido "+_cCustoMax+" "
		_cTexto 	+= "Saldo em estoque " +_cSaldo+ " necessidade " +_cQtdeConv
		//Retorno para gravação SZZ
		Aadd(_aLog, 	{_cTexto, "E"})
		//Retorno para envio de e-mail
		Aadd(_aMens, _cTexto)
	Next
	//Enviar Email o memo esta sendo enviado no padrão da integração MES
	ZPCPJ1EBKF(_aMens, _cTitulo, _cOP, _cProduto, _cChassi, _cIdent, _cIdMes )
End Sequence
Return _aLog

//-------------------------------------
/*/{Protheus.doc} ZPCPJV01
Chamada do JOB somente para veiculo
@author 	DAC - Denilso
@since 		29/12/2020
@version 	1.0
@obs		
/*/
//-------------------------------------
User Function ZPCPJV01(_aParam)
Local _cTipoVei := "VEI"
Local _lAbre	:= .F.
Local _cEmpresa 		
Local _cFilial 	
Begin Sequence
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJV01] Iniciado processamento Backflush 3.0 ")
	If ValType(_aParam) == "A"
		//VarInfo("Valores dos parametros recebidos pela rotina ZPCPJV01:",_aParam)
		_cEmpresa 	:=  _aParam[1]
		_cFilial 	:=  _aParam[2]
		CONOUT("INICIANDO EMPRESA "+_cEmpresa)
		CONOUT("INICIANDO FILIAL "+_cFilial)
		RpcClearEnv()
		RpcSetType(3)
		Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "PCP"
		_lAbre		:= .T.
	ElseIf Type("cFilAnt") <> "C"
		_cEmpresa	:=	"01"
		_cFilial	:=  "2010022001"
		CONOUT("INICIANDO EMPRESA "+_cEmpresa)
		CONOUT("INICIANDO FILIAL "+_cFilial)
		RpcClearEnv()
		RpcSetType(3)
		Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "PCP"
		_lAbre		:= .T.
	EndIF
	CONOUT("INICIADA EMPRESA "+cEmpAnt)
	CONOUT("INICIADA FILIAL "+cFilAnt)
	U_ZPCPJ001(_cTipoVei, /*reg szz*/, /*Time Fim*/)
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJV01] Finalizado processamento Backflush 3.0")
	If 	_lAbre	
		Reset Environment
	EndIf
End Sequence
Return Nil


//-------------------------------------
/*/{Protheus.doc} ZPCPJG01
Chamada do JOB rodar geral
@author 	DAC - Denilso
@since 		20/01/2021
@version 	1.0
@obs		
/*/
//-------------------------------------
User Function ZPCPJG01(_aParam)
Local _lAbre	:= .F.
Local _cEmpresa := "" 		
Local _cFilial 	:= ""
Local _cTime    := ""
Local _cHora
Local _cMinuto
Local _nPos		

Begin Sequence
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJV01] Iniciado processamento Backflush 3.0 ")
	_cMens := "TYPE DO PARAMETRO "+ValType(_aParam)
	If ValType(_aParam) == "A"
		VarInfo("Valores dos parametros recebidos pela rotina ZPCPJV01:",_aParam)
		//Quando estiver parametrizado a chamada do job obrigar o parâmetro de hora final para processamento
		CONOUT("HORA FINAL PROCESSAMENTO ZPCPJG01 "+_aParam[1])
		_nPos := At(":", _aParam[1])
		If _nPos == 0
		    If Len(_aParam[1]) < 4  //Exigir a informação de  hora e minuto
				CONOUT("NÃO INFORMADO CORRETAMENTE PARAMETRO DE HORA FINAL FORMATACAO HHMM, O MESMO DEVE SER O PRIMEIRO ZPCPJG01")
				Break
			EndIf
			_cHora		:= SubsTr(_aParam[1],1,2)
			_cMinuto	:= SubsTr(_aParam[1],3,2) 
		ElseIf _nPos <> 3
			CONOUT("NÃO INFORMADO CORRETAMENTE PARAMETRO DE HORA FINAL FORMATACAO HH:MM, O MESMO DEVE SER O PRIMEIRO ZPCPJG01")
			Break
		Else	
		    If Len(_aParam[1]) < 5  //Exigir a informação de  hora e minuto
				CONOUT("NÃO INFORMADO CORRETAMENTE PARAMETRO DE HORA FINAL FORMATACAO HH:MM, O MESMO DEVE SER O PRIMEIRO ZPCPJG01")
				Break
			EndIf
			_cHora		:= SubsTr(_aParam[1],1,2)
			_cMinuto	:= SubsTr(_aParam[1],4,2) 
		EndIf
		If Val(_cHora) > 24
			CONOUT("HORA FINAL PROCESSAMENTO HH NÃO PODE SER MAIOR QUE 24 ZPCPJG01")
			Break
		Endif
		If Val(_cMinuto) > 59
			CONOUT("MINUTO FINAL PROCESSAMENTO MM NÃO PODE SER MAIOR QUE 59 ZPCPJG01")
			Break
		Endif
		_cTime := _cHora+":"+_cMinuto		
		CONOUT("INICIANDO TEMPO   " +_cTime)
		//no processo deve mandar automaticamente a empresa
		If Len(_aParam) > 1		
			_cEmpresa 	:=  _aParam[2]
			CONOUT("INICIANDO EMPRESA " +_cEmpresa)
		EndIf	
		//no processo deve mandar automaticamente a filial
		If Len(_aParam) > 2		
			_cFilial 	:=  _aParam[3]
			CONOUT("INICIANDO FILIAL  " +_cFilial)
		EndIf	
		If Len(_aParam) > 1		
			RpcClearEnv()
			RpcSetType(3)
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "PCP"
			_lAbre		:= .T.
		EndIf
	EndIf
	If Type("cFilAnt") <> "C"
		_cEmpresa	:=	"01"
		_cFilial	:=  "2010022001"
		CONOUT("INICIANDO EMPRESA MANUAL "+_cEmpresa)
		CONOUT("INICIANDO FILIAL MANUAL "+_cFilial)
		RpcClearEnv()
		RpcSetType(3)
		Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "PCP"
		_lAbre		:= .T.
	Else
		_cMens := "NAO ENTROU NAS CONDIÇÕES DA CHAMADA DO JOB ZPCPJG01"
	EndIF
	CONOUT("INICIADA EMPRESA "+cEmpAnt)
	CONOUT("INICIADA FILIAL "+cFilAnt)
	CONOUT(If(Empty(_cTime),"SEM","COM "+_cTime) + " TEMPO DE TERMINO")
	U_ZPCPJ001(/*tipo veic*/, /*reg szz*/, _cTime)
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJV01] Finalizado processamento Backflush 3.0")
	//Resseta area aberta
	If 	_lAbre	
		Reset Environment
	EndIf
End Sequence
Return Nil

//Função responsável por enviar e-mail do Bckflush
Static Function ZPCPJ1EBKF(_aMens, _cTitulo, _cOP, _cProduto, _cChassi, _cIdent, _cIdMes )
Local _aMensEmail	:= {}
Local _aChave		:= {}
Local _nPos

Default _cTitulo 	:= "Informações processamento BACKFLUSH 3.0"
Default _cOP		:= "TODAS"
Default _cProduto	:= ""
Default _cChassi	:= ""
Default _cIdent		:= ""
Default _cIdMes     := ""
Begin Sequence
	//montar a chave para enviar por email
	Aadd(_aChave,{"D3_OP"	  	,	_cOP})	
	Aadd(_aChave,{"D3_COD"		,	_cProduto})
	Aadd(_aChave,{"H6_XCHASSI"	, 	_cChassi})
	Aadd(_aChave,{"D3_IDENT"	, 	_cIdent})
	Aadd(_aChave,{"H6_XIDMES"	, 	_cIdMes})

	For _nPos := 1 to Len(_aMens)
		Aadd(_aMensEmail, {"ZPCPJ001_ZPCPJ1EMAI",_aMens[_nPos]} )
	Next	
	U_ZPCPF07EM(_aMensEmail, _aChave, _cTitulo)
End Sequence
Return Nil



