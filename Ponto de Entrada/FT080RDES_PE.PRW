#INCLUDE "PROTHEUS.CH"
 
User Function FT080RDES()
 
Local _cProduto  := PARAMIXB[1]     //Código do Produto
Local _cCliente  := PARAMIXB[2]     //Código do Cliente
Local _cLoja     := PARAMIXB[3]     //Loja do Cliente
Local _cTabPrc   := PARAMIXB[4]     //Tabela de Preço
Local _nQtdVen   := PARAMIXB[5]     //Quantidade Vendida
Local _cCondPg   := PARAMIXB[6]     //Condição de Pagamento
Local _cForPgto  := PARAMIXB[7]     //Forma de Pagamento
Local _nTpDesc   := PARAMIXB[8]     //Tipo de Desconto, sendo: 1- Por item / 2- Por total
Local _nDesconto := 0              
 
//Quando for o Cliente: 000001, vamos dar um desconto por item.
//Neste exemplo vamos dar um desconto de 10%, caso seja a condição de pagamento: 001,
//produto: 05 e a quantidade seja maior que 5 pçs 

//If _cCliente == "000001" .And. _cLoja == "01" .And. _nTpDesc == 1
//    If _cCondPg == "001" .And. _cProduto == "05             " .And. _nQtdVen > 5
//        _nDesconto := 10
//    EndIf
//EndIf
ALERT("FT080RDES") 
//Quando for o Cliente: 000002, vamos dar um desconto de 5% por total.
//If _cCliente == "000002" .And. _cLoja == "01" .And. _nTpDesc == 2
//    _nDesconto := 5
//EndIf
 
Return _nDesconto
