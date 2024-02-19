#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "TBICONN.CH"
#include "rwmake.ch"
#include "TOTVS.ch"

#define CRLF chr(13) + chr(10)

/*/{Protheus.doc} ZTESTE01
@param  	
@author 	Nicolas Lima
@version  	P12.1.23
@since  	28/12/2021
@return  	NIL
@obs         
@project
@history    Seleciona Picking para faturamento.   
/*/
User Function ZTESTE01()

    //Local cTabela   := "SB1"
    //Local cIndTmp   := GetNextAlias()
    //Local cCampos   := "B1_FILIAL+B1_PRODUTO+B1_UM"
    Local cMensagem := ""
    Local cProduto  := "R-957802E000"

    MsgInfo("Início do fonte","Atenção")

    //Abre a tabela de produtos
    //DbSelectArea(cTabela)

    //Agora monta o índice temporário
   // IndRegua(cTabela, cIndTmp, cCampos)

    //Monta a mensagem 
    //cMensagem += "O índice numérico é: " + cValToChar((cTabela)->(IndexOrd())) + CRLF
    //cMensagem += "E a chave do índice é: " + (cTabela)->(IndexKey()) + CRLF
    //cMensagem += "Estou no registro: " + Alltrim((cTabela)->B1_COD) + " - " + Alltrim((cTabela)->B1_UM) + CRLF
    //cMensagem += CRLF + CRLF    
    //Abrindo a tabela de Produtos e posicionando no topo
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	SB1->(DbGoTop())

	SB1->(MsSeek(FWxFilial("SB1") + cProduto ))
    cMensagem += "A unidade de medida é: " + Alltrim(SB1->B1_UM)

    //Mostra a mensagem
    ShowLog(cMensagem)
Return


 
/*/{Protheus.doc} User Function zTstIndic
Função para testar a criação de índices temporárias em tabelas padrões
@type  Function
@author Atilio
@since 04/11/2023
/*/
 
User Function zTstIndic()
    Local cTabela   := "SB1"
    Local cIndTmp   := GetNextAlias()
    Local cCampos   := "B1_FILIAL+B1_CODGTIN+B1_DESC"
    Local cMensagem := ""
 
    //Abre a tabela de produtos
    DbSelectArea(cTabela)
 
    //Monta a mensagem do Antes
    cMensagem += "==== ANTES ====" + CRLF
    cMensagem += "O índice numérico é: " + cValToChar((cTabela)->(IndexOrd())) + CRLF
    cMensagem += "E a chave do índice é: " + (cTabela)->(IndexKey()) + CRLF
    cMensagem += "Estou no registro: " + Alltrim((cTabela)->B1_COD) + " - " + Alltrim((cTabela)->B1_DESC) + CRLF
    cMensagem += CRLF + CRLF
 
    //Agora monta o índice temporário
    IndRegua(cTabela, cIndTmp, cCampos)
 
    //Monta a mensagem do Depois
    cMensagem += "==== DEPOIS ====" + CRLF
    cMensagem += "O índice numérico é: " + cValToChar((cTabela)->(IndexOrd())) + CRLF
    cMensagem += "E a chave do índice é: " + (cTabela)->(IndexKey()) + CRLF
    cMensagem += "Estou no registro: " + Alltrim((cTabela)->B1_COD) + " - " + Alltrim((cTabela)->B1_DESC) + CRLF
    cMensagem += CRLF + CRLF
 
    //Mostra a mensagem
    ShowLog(cMensagem)
Return
