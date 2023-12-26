#include "Protheus.ch"
/*/{Protheus.doc} FA040FIN
    PE para chamar a funçao ZFINF006 para gravar o E1_NUMBCO para o título de RA e não o da Parela1 quando PVF (efeito SAP).
    @type       PE
    @author     CAOA - A.Carlos
    @since 		20/12/2023
    @version 	1.0
    /*/
User Function FA040FIN()

u_ZGENLOG( ProcName() ) //Grava log de execução de fontes

If Findfunction("U_ZFINF006")
	U_ZFINF006()
EndIf

return() 
