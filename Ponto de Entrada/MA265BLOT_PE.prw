#INCLUDE "TOTVS.CH"
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} MA125BUT_PE
P.E. - Para tratar o bloq. data de validade.
@author CAOA - Evandro Mariano
@since 08/10/2021
@version 1.0
@type function
/*/

User Function MA265BLOT()

Local lAuto := ParamIxb[1]   // Indica se est� executando rotina autom�tica
Local lRet  := .T.// Valida��es do usu�rio p/definir se executa ou n�o a fun��o p/validar venctos dos lotes: BloqData()

//Se executa via execauto, n�o precisa validar os lotes vencidos.
//A valida��o s� ir� acontecer pea rotina padr�o MATA265
If FWIsInCallStack("U_ZPCPF007")
    
    ConOut("[MA265BLOT] - Ponto de Entrada - Nao valida lote e vencimento no enderecamento")
    
    If lAuto
        lRet := .F.
    EndIf

EndIf

Return(lRet) 
