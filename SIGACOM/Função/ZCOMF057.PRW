#Include 'Rwmake.ch'
#Include 'TopConn.ch'
#Include "PROTHEUS.CH"
#include "TOTVS.ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWBROWSE.CH"
#Include "FWMVCDEF.CH"

#DEFINE CRLF chr(13) + chr(10)  

/*/{Protheus.doc} ZCOMF057
// Validacao de quantidade de quebrada nos PE TOK para funções em ADVPL padrão.
@author Nicolas Lima
@since 	26/10/2023
@version 1.0
@return ${return}, ${return_description}
@obs	
@type function
/*/

User Function ZCOMF057()

	Local aArea  	:= GetArea()
	Local nLinGrid 	As Numeric
	Local nQtdPos 	As Numeric
	Local nProdPos 	As Numeric
	Local nCount 	As Numeric
	Local nQtdAtg   As Numeric
	Local cMsg 		As Character
	Local cCodAtg	As Character
    Local lRet      As Logical
    Local lContinua As Logical
	
	nLinGrid 		:= 1
	cMsg 		:= ""
	nCount 		:= 0
	nQtdAtg   	:= 0
	cCodAtg		:= ""
    lRet        := .F.
    lContinua   := .F.
	
    Begin Sequence

        If IsInCallStack("MATA110") //SOLICITAÇÃO DE COMPRAS
            nQtdPos 	:= GDFieldPos("C1_QUANT")
            nProdPos 	:= GDFieldPos("C1_PRODUTO")
            lContinua := .T.
        ElseIf IsInCallStack("MATA103") //DOCUMENTO DE ENTRADA
            nQtdPos 	:= GDFieldPos("D1_QUANT") //Campos do DOCUMENTO DE ENTRADA
            nProdPos 	:= GDFieldPos("D1_COD")
            lContinua := .T.
        Else
            MsgInfo("Erro na função ZCOMF057, entre em contato com a equipe de sistemas.")
            lContinua := .F.
        EndIf
        
        If lContinua
            //Verifica linha pro linha do aCols
            While nLinGrid <=  Len(aCols) 
                nQtde := aCols[nLinGrid][nQtdPos]
                    
                //Testa se as qtds estão quebradas via aCols.
                If nQtde <> NoRound(nQtde,0) .and. nQtde > 0
                    //Grava o código do produto e a quantidade antiga.
                    nQtdAtg := aCols[nLinGrid][nQtdPos]
                    cCodAtg := aCols[nLinGrid][nProdPos]
                    //Devolve no campo o valor arredondado. 					
                    nQtde := NoRound(nQtde, 0)
                    aCols[nLinGrid][nQtdPos] := nQtde 
                    cMsg += "Cod. prod.: " + PadR("[ "+ Alltrim(cCodAtg) + " ]",18 , " ") + "";
                    + " Qtd orig.: " + "[ " + PadC(alltrim(str(nQtdAtg)), 5, " ") + " ]";
                    + " Qtd alter.: " + "[ " + PadC(alltrim(str(nQtde)), 3, " ") + " ]";
                    + " " + CRLF + ""
                    //Grava quantos valores com vírgula existem
                    nCount++
                EndIf
                nLinGrid++
            EndDo
            //Mostra itens alterados
            If nCount > 0
                MsgAlert("Foram alterados [" + alltrim(str(nCount)) + "] itens com quantidades quebradas, são eles: " + CRLF;
                + cMsg + " .","Quantidade quebrada - ZCOMF057")
            EndIF
            lRet := .T.
            //Alterar as informações de quantidade linha a linha
        EndIf
    
    End Sequence
    
    RestArea(aArea)

Return lRet


User Function zPedComp()

	Local aArea  	:= GetArea()
	Local nLinGrid 	As Numeric
	Local nQtdPos 	As Numeric
	Local nProdPos 	As Numeric
	Local nCount 	As Numeric
	Local nQtdAtg   As Numeric
	Local cMsg 		As Character
	Local cCodAtg	As Character
	//Local lMsg 		As Logical
    Local lRet      As Logical
    Local lContinua As Logical
	
	nLinGrid 		:= 1
	cMsg 		:= ""
	nCount 		:= 0
	nQtdAtg   	:= 0
	cCodAtg		:= ""
    lRet        := .F.
    lContinua   := .F.


    If IsInCallStack("MATA121") //PEDIDO DE COMPRAS
        nQtdPos 	:= GDFieldPos("C7_QUANT")
        nProdPos 	:= GDFieldPos("C7_PRODUTO") //Campos do PEDIDO DE COMPRAS
        lContinua := .T.
    Else
        MsgInfo("Erro na função ZCOMF057, entre em contato com a equipe de sistemas.")
        lContinua := .F.    
    EndIf

    If lContinua
        //Verifica linha pro linha do aCols
            While nLinGrid <=  Len(aCols) 
                nQtde := aCols[nLinGrid][nQtdPos]
                    
                //Testa se as qtds estão quebradas via aCols.
                If nQtde <> NoRound(nQtde, 0) .and. nQtde > 0
                    //Grava o código do produto e a quantidade antiga.
                    nQtdAtg := aCols[nLinGrid][nQtdPos]
                    cCodAtg := aCols[nLinGrid][nProdPos]
           
                    cMsg += "Codigo: " + PadR("[ "+ Alltrim(cCodAtg) + " ]",18 , " ") + "";
                    + " Qtd.: " + "[ " + PadC(alltrim(str(nQtdAtg)), 5, " ") + " ]";
                    + " " + CRLF + ""

                    //Grava quantos valores com vírgula existem
                    nCount++
                EndIf
                nLinGrid++
            EndDo
            //Mensagem de itens alterados para alterar.
            If nCount > 0
                MsgAlert("São permitidos apenas quantidade inteiras, por favor altere os itens:" + CRLF + CRLF;
                + cMsg + " .","Quantidade quebrada - ZCOMF057")
                
                lRet := .F.
            Else //Não possui itens para arredondar.
                lRet := .T.
            EndIF
    EndIf
    
    RestArea(aArea)

Return lRet


User Function zCOMF57B(nW1_SALDO, nW1_QTDE, cCodProd) //Chamado pelo PE EICSI400_PE
   
    Local aArea	        := GetArea()    
	Local cMsg 	        := ""
    Local lRet          := .F.
    
    Default nW1_QTDE 	:= 0
	Default nW1_SALDO 	:= 0
	Default cCodProd 	:= ""

    
	If ((nW1_SALDO <> NoRound(nW1_SALDO, 0)) .and. (nW1_SALDO > 0)) .or. ((nW1_QTDE <> NoRound(nW1_QTDE, 0)) .and. (nW1_QTDE > 0))

        cMsg += "Codigo: " + PadR("[ "+ Alltrim(cCodProd) + " ]",25 , " ") + "";
            + "   Qtd.: " + "[ " + PadC(alltrim(str(nW1_QTDE)), 5, " ") + " ]";
			+ "   Saldo: " + "[ " + PadC(alltrim(str(nW1_SALDO)), 5, " ") + " ]" + CRLF + ""

        MsgAlert("São permitidos apenas quantidade inteiras, por favor altere os itens:" + CRLF + CRLF;
        + cMsg + " .","Quantidade/Saldo quebrados - ZCOMF57B")
                
        lRet := .F.
    Else
		lRet := .T.		
	EndiF

    RestArea(aArea)

Return lRet
