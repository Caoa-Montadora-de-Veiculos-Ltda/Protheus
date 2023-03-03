#Include "PROTHEUS.CH"
#Include "TOTVS.CH"

/*
=====================================================================================
Programa.:              ZWMSF017
Autor....:              CAOA - Fagner Barreto
Data.....:              20/01/2020
Descricao / Objetivo:   Função usada para validar locks de registro              
Doc. Origem:
Solicitante:            Evandro Mariano      
=====================================================================================
*/
User Function ZWMSF017(cArmOri, cArmDes, cProduto)
    Local nY        := 0
    Local aRecSB2   := {}
    Local aRecnos   := {}
    Local cMsgLock  := ""

    Default cArmOri     := ""
    Default cArmDes     := ""
    Default cProduto    := ""
    
    //--Recno armazem de origem
    Aadd( aRecSB2, RecnoSB2( cProduto, cArmOri ) )

    //--Recno armazem de destino
    Aadd( aRecSB2, RecnoSB2( cProduto, cArmDes ) )

    Aadd( aRecnos, { "SB2", aRecSB2 } )

	For nY := 1 To Len(aRecnos)
		//--Valida lock de tabela
		If U_ZGENLOCK(@cMsgLock, aRecnos[nY][1], aRecnos[nY][2])
            WMSVTAviso("ZWMSF017", "Não é possivel prosseguir com a transferencia, motivo: Lock na tabela Saldo(SB2)")
            VTKeyBoard(Chr(27)) //-- Tecla ESC para sair
			Return .F.
		EndIf
	Next

Return .T.

/*
=====================================================================================
Programa.:              RecnoSB2
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              28/04/20
Descricao / Objetivo:   Retorna RECNO do produto na tabela SB2        
Solicitante:            
=====================================================================================
*/
Static Function RecnoSB2(cCodProd, cArmazem)
    Local aAreaSB2  := SB2->( GetArea() )
	Local nRecno	:= 0

	SB2->( DbSetOrder(1) )
	If SB2->( DbSeek( FWxFilial("SB2");
					+ Padr( cCodProd, TamSX3("B2_COD")[1] );
					+ Padr( cArmazem, TamSX3("B2_LOCAL")[1] ) ) )
		nRecno := SB2->( Recno() )
	EndIf                                                                   

    RestArea(aAreaSB2)
Return nRecno
