#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZACDJ005
Rdmake 	Job referente Log de movimentação de Veiculo produção para Gabardo
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC - Denilso 
@single		17/09/2020
@version    Nao Informado
@since      Nao Informado  
@return    	Nil
@sample     Nao Informado
@obs        
@project    CAOA - Automatizar o processo de movimentação veiculo para Gabardo
@menu       Nao Informado
@history    

/*/

User Function ZACDJ005(_aParam)
//Local _lSchedule	:= If( aParam <> Nil,.T.,.F.)
//Local _lJob      	:= GetRemoteType() == -1 // Verifica se é job
Local _lJob   		:=	If( IsBlind(),.T.,.F.)
Local _lAbre		:= .F.
Local _lZACDJ005    
Local _lRet
Local _nPos
Local _cEmpresa	
Local _cFilial 	

Begin Sequence
	If _lJob
		ConOut("*************************************************************************************************************************"	+ CRLF)
		ConOut("----------- [ ZACDJ005 ] - Inicio da funcionalidade "														+ CRLF)
		ConOut("*************************************************************************************************************************"	+ CRLF)
	EndIf

	//sendo job testar parametros
	If _lJob
		If ValType(_aParam) == "A"
			//VarInfo("Valores dos parametros recebidos pela rotina ZPCPJV01:",_aParam)
			_cEmpresa 	:=  _aParam[1]
			_cFilial 	:=  _aParam[2]
			CONOUT("INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("INICIANDO FILIAL "+_cFilial)
			RpcClearEnv()
			RpcSetType(3)
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "ACD"
			_lAbre		:= .T.
		ElseIf Type("cFilAnt") <> "C"
			_cEmpresa	:=	"01"
			_cFilial	:=  "2010022001"
			CONOUT("INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("INICIANDO FILIAL "+_cFilial)
			RpcClearEnv()
			RpcSetType(3)
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "ACD"
			_lAbre		:= .T.
		EndIf
	EndIF
	CONOUT("INICIADA EMPRESA "+cEmpAnt)
	CONOUT("INICIADA FILIAL "+cFilAnt)

    //Caso esteja desabilitado parametro
 	_lZACDJ005    := SuperGetMV( "CMV_ACD003"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade
    If !_lZACDJ005
		ConOut("*************************************************************************************************************************"	+ CRLF)
		ConOut("----------- [ ZACDJ005 ] - JOB ZACDJ005 não esta com parametro CMV_ACD003 ativo para executar "														+ CRLF)
		ConOut("*************************************************************************************************************************"	+ CRLF)
        Break
    Endif

	ConOut("*************************************************************************************************************************"	+ CRLF)
	ConOut("----------- [ ZACDJ005 ] - VERIFICANDO SE JA EXISTE PROCESSAMENTO DO JOB  "														+ CRLF)
	ConOut("*************************************************************************************************************************"	+ CRLF)

	If !LockByName("ZACDJ005",.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 1000 ) // Para o processamento por 1 segundo
			If LockByName("ZACDJ005",.T.,.T.)
				_lRet := .T.
			EndIf
		Next		
		If !_lRet
			If !_lJob
				MsgInfo("Já existe um processamento em execução rotina ZACDJ005, aguarde!")
			Else
				CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZACDJ005] Já existe um processamento em execução, aguarde!")
				ConOut("*************************************************************************************************************************"	+ CRLF)
				ConOut("----------- [ ZACDJ005 ] - Já existe um processamento em execução rotina ZACDJ005 "														+ CRLF)
				ConOut("*************************************************************************************************************************"	+ CRLF)
			EndIf
			Break
		EndIf
	EndIf
 
	DbSelectArea("SZW")
	If !_lJob
		FWMsgRun(,{|| ZACDJ05PRC(_lJob) },,"Realizando atualização Status para Entrada de Veículos ACD, aguarde...")
	Else
		CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZACDJ005] Iniciado processamento atualização Status para Entrada de Veículos ACD ")
		ZACDJ05PRC(_lJob)
	Endif
	UnLockByName("ZACDJ005",.T.,.T.)
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZACDJ005] Finalizado processamento atualização Status para Entrada de Veículos ACD")
End Sequence
//Caso abriu o processo empresa e filial tem que fechar
If  _lAbre	
	Reset Environment
Endif
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ZACDJ05PRC
Selecionar os status para processamento   
@author DAC denilso.carvalho
@since 17/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ZACDJ05PRC(_lJob)
Local _cAliasTab    := GetNextAlias()
Local _cStatus		:= "'P','D',' '"    //VERIFICO PENDENTES E EM BRANCO
Default _lJob := .F.

Begin Sequence
	SZW->(DbSetOrder(3))  //ZW_FILIAL+ZW_STATUS+ZW_ORIGEM+ZW_CODPROD                                                                                                                        
    _cStatus := "%"+_cStatus+"%"
    BeginSql Alias _cAliasTab	
    SELECT SZW.R_E_C_N_O_ NREGSZW
	    FROM %Table:SZW%  SZW 
	    WHERE 	SZW.ZW_FILIAL = %xFilial:SZW% 
		    AND SZW.ZW_STATUS IN (%Exp:_cStatus%)
		    AND SZW.%notDel% 
    EndSQL
    If (_cAliasTab)->(EOF()) .or. (_cAliasTab)->NREGSZW == 0
		Break
    Endif
	//Verificar e providenciar Baixa
	While (_cAliasTab)->(!EOF())
		SZW->(DbGoto((_cAliasTab)->NREGSZW))
		ZACDJ05BLQ()
		(_cAliasTab)->(DbSkip())
	EndDo

End Sequence
If Select(_cAliasTab) <> 0
	(_cAliasTab)->(DbCloseArea())
	Ferase(_cAliasTab+GetDBExtension())
Endif  
Return Nil




//-------------------------------------------------------------------
/*/{Protheus.doc} ZACDJ05BLQ
Gravar os status do processamento e Verificar se possui algum bloqueio e desbloquear  
@author DAC denilso.carvalho
@since 17/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ZACDJ05BLQ
Local _aReg 	:= {}
Local _cMotivo 	:= "ACD AUTOMATICO ZACDJ005"
Local _lRet		:= .T.
Local _cStatus  := ""
Local _cMens    := "NÃO IDENTIFICADO"
Local _nTamVin  := 17
Local _nPeriodo := SuperGetMV( "CMV_VEI010"  ,,3500)  //quantidade de dias correspondente ao bloqueio de veiculos

Local _nPos
Begin Sequence
	//Verifica tamanho da VIN (Chassi)
	//Quando Status for liberado não fazer nada
	If SZW->ZW_STATUS == "L"
		Break
	EndIf
	//Verificar tamanho do campo
	If Len(AllTrim(SZW->ZW_CHASSI)) < _nTamVin
		_cStatus 	:= "D"
		_cMens		:= "TAMANHO CODIGO V.I.N. ERRADO"
		Break
	EndIf
	//Localizar o veiculo
	VV1->(DbSetOrder(2))  //FILIAL+CHASSI
	If ! VV1->(DbSeek(XFilial("VV1")+SZW->ZW_CHASSI))
		_cStatus 	:= "D"
		_cMens		:= "VEÍCULO NÃO EXISTENTE NO CADADASTRO VEÍCULOS"
		_lRet := .F.
		Break
	Endif
	//significa que o carro já foi vendido, então não preciso de liberação para entrar na Gabardo .. o carro já foi vendido...
	If VV1->VV1_SITVEI <> "0"
		_cStatus 	:= "L"
		_cMens		:= "VEÍCULO VENDIDO"
		Break
	EndIf 
   
    _aReg := {} 
    //Desbloquear veiculo se chegou ate aqui
	//Necessario fazer esta busca pois pode existir mais de um registro de bloqueio com data vencida
  	U_ZVF01VLDBL(.T./*indica que é para retornar os regsitros bloqueados */,;
	  			 @_aReg /*Retorna os nr dos registros para desbloquear*/,;
				VV1->VV1_CHAINT)

	If SZW->( FieldPos("ZW_BLOQUEI") ) > 0
       	// Bloqueio Automatico
		If SZW->ZW_BLOQUEI == "B" 
		 	If Len(_aReg) > 0  //Somente bloquear se não existir bloqueios caso contrario deixar o que ja existe 
				_cStatus	:= "L"
				_cMens		:= "VEICULO LIBERADO E JA EXISTE BLOQUEIO ANTERIOR"
			Else
        		RecLock("VB0", .t.)
	    		VB0->VB0_FILIAL := xFilial("VB0")
	    		VB0->VB0_CHAINT := VV1->VV1_CHAINT
	    		VB0->VB0_DATBLO := Date()        	
				VB0->VB0_HORBLO := val(left(time(), 2) + substr(time(), 4, 2))
				VB0->VB0_USUBLO := RetCodUsr()
	    		VB0->VB0_MOTBLO := Upper(AllTrim(_cMotivo +" BLOQUEIO"))
	    		VB0->VB0_DATVAL := (Date() + _nPeriodo)
	    		VB0->VB0_HORVAL := val(left(time(), 2) + substr(time(), 4, 2))
	    		VB0->(MsUnlock())
				_cStatus	:= "L"
				_cMens		:= "VEICULO LIBERADO E BLOQUEADO "
			EndIf
        //Desbloqueio
        ElseIf SZW->ZW_BLOQUEI == "D"  
			If Len(_aReg) == 0  //Se existir bloqueio desbloquear existindo mais de um debloquear todos
				_cStatus	:= "L"
				_cMens		:= "VEICULO LIBERADO E NAO EXISTE BLOQUEIO ANTERIOR EM ABERTO"
			Else
    			For _nPos := 1 To Len(_aReg)
        			VB0->(DbGoto(_aReg[_nPos]))
        			RecLock("VB0", .f.)
					VB0->VB0_DATDES := Date()
					VB0->VB0_HORDES := val(left(time(), 2) + substr(time(), 4, 2))
					VB0->VB0_USUDES := RetCodUsr()
					VB0->VB0_MOTDES := Upper(AllTrim(_cMotivo+" DESBLOQUEIO"))   
	    			VB0->(MsUnlock())
    			Next
				_cStatus	:= "L"
				_cMens		:= "VEICULO LIBERADO E DESBLOQUEADO "
			EndIf	
        ElseIf ! SZW->ZW_BLOQUEI $ "B_D" 
			_cMens		:= "VEICULO NAO PROCESSADO NAO EXISTE INDICACAO DE BLOQUEIO/DESBLOQUEIO "
			_cStatus	:= "D"
        Else 
			_cMens		:= "EXISTE PROBLEMAS RELACIOADO AO BLOQUEIO/DESBLOQUEIO CONTATE ADMINISTRADOR"
			_cStatus	:= "D"
	    
		EndIf
	Else
		_cMens		:= "CAMPO ZW_BLOQUEI DE BLOQUEIO/DESBLOQUEIO NAO CRIADO CONTATE ADMINISTRADOR"
		_cStatus	:= "D"
	EndIf
	//Se Chegou aqui o Veículo não estara bloqueado
End Sequence
If !Empty(_cStatus)
	RecLock("SZW",.F.)
	_cMens += " AUTOMATICO ZACDJ005"
	SZW->ZW_STATUS 	:= _cStatus
	SZW->ZW_OBS		:= _cMens 
	SZW->ZW_DTMOVIM := Date() 
	SZW->ZW_HRMOVIM	:= Time() 
	SZW->(MsUnlock())
EndIf
Return _lRet	
