/*/{Protheus.doc} CRMZFATJ001A980
JOB para processar Liberação de Crédito
@author 	CAOA DAC Denilso
@since 		13/04/2023
@version 	1.0
@project	GRUPO CAOA GAP FIN108 - Revitalização Credito [ Montadora ]
@history     
@Obs        
/*/

User Function ZFATJ001(_aParam)
Local _lRet 		:= .T.
Local _lZFATJ001    := SuperGetMV( "CMV_FAT001"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade ZPCPF010
Local _lJob         := IsBlind()
Local _cChave		:= AllTrim(FWCodEmp())+"ZFATJ001"
Local _nPos

Begin Sequence
	If !_lZFATJ001
		If !_lJob  //interface com o usuário
			MSGInfo( "Não é possivel executar liberação de crédito, motivo parâmetro CMV_FAT001 desabilitado -)","ATENCAO")
		EndIf
		Break	
	Endif
	//Garantir que o processamento seja unico
	If !LockByName(_cChave,.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 3000 ) // Para o processamento por 3 segundos
			If LockByName("ZPCPJ001",.T.,.T.)
				_lRet := .T.
			EndIf
		Next		
		If !_lRet
			If !_lJob
				MSGINFO("Já existe um processamento em execução rotina ZFATJ001, aguarde!", "[ZFATJ001] - Atenção" )
			Else
				CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFATJ001] Já existe um processamento em execução, aguarde!")
				ConOut("*************************************************************************************************************************"	+ CRLF)
				ConOut("----------- [ ZFATJ001 ] - Já existe um processamento em execução rotina ZFATJ001 "														+ CRLF)
				ConOut("*************************************************************************************************************************"	+ CRLF)
			EndIf
			Break
		EndIf
	EndIf
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFATJ001] Iniciado processamento Avaliação Limite de Crédito ")
	If _lJob
		U_ZFATF014()  //Sem parametros processa todo
	Else
        FwMsgRun(,{ || U_ZFATF014() }, 'Limite Crédito','Atualizando Limite de Crédito Caoa, aguarde...')  //Separação Orçamentos / Aguarde
	Endif
	UnLockByName(_cChave,.T.,.T.)
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFATJ001] Finalizado processamento Avaliação Limite de Crédito ")
End Sequence
Return _lRet
