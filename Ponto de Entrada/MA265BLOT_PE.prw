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

Local lAuto := ParamIxb[1]   // Indica se está executando rotina automática
Local lRet  := .T.// Validações do usuário p/definir se executa ou não a função p/validar venctos dos lotes: BloqData()

//Se executa via execauto, não precisa validar os lotes vencidos.
//A validação só irá acontecer pea rotina padrão MATA265
If FWIsInCallStack("U_ZPCPF007")
    
    ConOut("[MA265BLOT] - Ponto de Entrada - Nao valida lote e vencimento no enderecamento")
    
    If lAuto
        lRet := .F.
    EndIf

EndIf

Return(lRet) 
