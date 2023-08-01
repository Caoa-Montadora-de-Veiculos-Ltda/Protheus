#INCLUDE "PROTHEUS.CH"
#INCLUDE 'XMLXFUN.CH'
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH"

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZGENJ001
JOB para bloquear os usuários com um periodo de inatividade.
@param      _lJob
@author     Evandro Mariano
@single		01/08/2023
@history    
/*/

User Function ZGENJ001()

Local _lRet 		:= .T.
Local _lProcessa    := SuperGetMV( "CMV_GEN005"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade ZPCPF010
Local _nDias        := SuperGetMV( "CMV_GEN006"  ,,60)  //parametro para habilitar/desabilitar funcionalidade ZPCPF010
Local _nPos         := 0
Local _lJob         := IsBlind()

    If _lProcessa
	    If _lJob  //Rodando via job.
		    //Garantir que o processamento seja unico
	        If !LockByName("ZGENJ001",.T.,.T.)  
                //tentar locar por 10 segundos caso não consiga não prosseguir
                _lRet := .F.
                For _nPos := 1 To 10
                    Sleep( 1000 ) // Para o processamento por 1 segundo
                    If LockByName("ZGENJ001",.T.,.T.)
                        _lRet := .T.
                    EndIf
                Next		
		        If !_lRet
			    	ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZGENJ001] Já existe um processamento em execução, aguarde!")
			    EndIf
		    EndIf
	    EndIf

        If _lRet
		    ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZGENJ001] Inicio do processamento.")

            U_ZMSBLQUSR(_lJob, _nDias)
	
	        UnLockByName("ZGENJ001",.T.,.T.)

	        ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZGENJ001] Termino do processamento.")
        EndIf
    EndIf

Return()
