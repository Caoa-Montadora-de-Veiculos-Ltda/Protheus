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
Local _lProcessa    := .F.
Local _nDias        := 0
Local _nPos         := 0
Local _lJob         := IsBlind()
Private _aMatriz    := {"01","2010022001" }

    ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZMSBLQUSR] Inicio do processamento. ")

    If _lJob  //Rodando via job.

        RpcSetType(3)
        RpcSetEnv(_aMatriz[1],_aMatriz[2])

        ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZMSBLQUSR] Abertura da empresa. Empresa: " + cEmpAnt + " | Filial: " + cFilAnt)
    
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
			    ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZMSBLQUSR] Já existe um processamento em execução, aguarde!")
			EndIf
            
		EndIf
	EndIf

    If _lRet

        _lProcessa    := SuperGetMV( "CMV_GEN005"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade ZPCPF010
        _nDias        := SuperGetMV( "CMV_GEN006"  ,,60)  //parametro para habilitar/desabilitar funcionalidade ZPCPF010
        
        If _lProcessa

		    ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZMSBLQUSR] Inicio do processamento.")

            U_ZMSBLQUSR(_lJob, _nDias)
	
	        UnLockByName("ZGENJ001",.T.,.T.)

	        ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZMSBLQUSR] Termino do processamento.")

        Else

            ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZMSBLQUSR] Processo de bloqueio esta desabilitado, confira o parametro.")

        EndIf
    EndIf
 
 Return()
