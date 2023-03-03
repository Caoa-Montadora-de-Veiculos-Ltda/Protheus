#include "Totvs.ch"
/*

Chamada via sheduler
Para Agendamento Futuro

U_ZESTJ001(date())

Para Agendar para rodar numa data expecifica

U_ZESTJ001(STOD("20220901"))

*/

User Function ZESTJ001(aParam)
    Local ddataFec := Date()
	Local lIsBlind := .T.

    If !Empty(aParam)
		if ValType(aParam[1]) == "D"
			ddataFec := aParam[1]
		else
			ddataFec := stdo(aParam[1])	
		endif
		If ValType(aParam[2]) == "C"
			cEmpJob := aParam[2]
		Endif	
		If ValType(aParam[3]) == "C"
			cFilJob := aParam[3]
		Endif
	Endif		 
	
	IF lIsBlind
		RpcSetType(3)
		RpcSetEnv( cEmpJob , cFilJob )

	EndIF

    if !Empty(cEmpJob) .and. ValType(aParam[1]) == "D" .and. !empty(aParam[1])
        conout('Inicio ZESTJ001')
        MATA280(.t.,ddataFec,"SF1","SD1","SF2","SD2","SD3","SC2","AF9")
        conout('Final ZESTJ001')
    EndIf

RETURN
/*
User Function TSTZESTJ()

U_ZESTJ001({STOD("20220901"),'01','2010022001'})

Return
*/
