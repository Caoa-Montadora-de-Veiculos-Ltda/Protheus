#INCLUDE "PROTHEUS.CH"

/*
=====================================================================================
Programa.:              ZCOMF023
Autor....:              A. Carlos
Data.....:              02/10/20
Descricao / Objetivo:   Validar opera��o p/bloquear edi��o das descri��es de Produto 
Doc. Origem:
Solicitante:            Compras
Uso......:              CAOA Montadora de Veiculos
Obs......:
@history.:              usado na configura��o do campo	

=====================================================================================
*/
User Function ZCOMF023()
Local _lRet	    := .T.
    
    IF FunName() $ ("MATA110,MATA121,MATA122,MATA125,MATA150,MATA179") .AND. (INCLUI .OR. ALTERA)
       _lRet := .F.
    ELSE
       _lRet := .T.
    ENDIF 
    
Return _lRet

