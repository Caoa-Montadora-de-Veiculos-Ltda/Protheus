/*/{Protheus.doc} CRMZFATJ001A980
JOB para processar Libera��o de Cr�dito
@author 	CAOA DAC Denilso
@since 		13/04/2023
@version 	1.0
@project	GRUPO CAOA GAP FIN108 - Revitaliza��o Credito [ Montadora ]
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
		If !_lJob  //interface com o usu�rio
			MSGInfo( "N�o � possivel executar libera��o de cr�dito, motivo par�metro CMV_FAT001 desabilitado -)","ATENCAO")
		EndIf
		Break	
	Endif
	//Garantir que o processamento seja unico
	If !LockByName(_cChave,.T.,.T.)  
		//tentar locar por 10 segundos caso n�o consiga n�o prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 3000 ) // Para o processamento por 3 segundos
			If LockByName("ZPCPJ001",.T.,.T.)
				_lRet := .T.
			EndIf
		Next		
		If !_lRet
			If !_lJob
				MSGINFO("J� existe um processamento em execu��o rotina ZFATJ001, aguarde!", "[ZFATJ001] - Aten��o" )
			Else
				CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFATJ001] J� existe um processamento em execu��o, aguarde!")
				ConOut("*************************************************************************************************************************"	+ CRLF)
				ConOut("----------- [ ZFATJ001 ] - J� existe um processamento em execu��o rotina ZFATJ001 "														+ CRLF)
				ConOut("*************************************************************************************************************************"	+ CRLF)
			EndIf
			Break
		EndIf
	EndIf
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFATJ001] Iniciado processamento Avalia��o Limite de Cr�dito ")
	If _lJob
		U_ZFATF014()  //Sem parametros processa todo
	Else
        FwMsgRun(,{ || U_ZFATF014() }, 'Limite Cr�dito','Atualizando Limite de Cr�dito Caoa, aguarde...')  //Separa��o Or�amentos / Aguarde
	Endif
	UnLockByName(_cChave,.T.,.T.)
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFATJ001] Finalizado processamento Avalia��o Limite de Cr�dito ")
End Sequence
Return _lRet
