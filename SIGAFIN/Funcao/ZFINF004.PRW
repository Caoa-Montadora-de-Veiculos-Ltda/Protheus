#include "Protheus.ch"
#include 'parmtype.ch'
#include 'TOPCONN.CH'
#include "TBICONN.CH"
/*/{Protheus.doc} ZFINF004
	Função para gravar a forma de pagamento no título de RA usada para integração com o SAP.
    @type       Function chamada pelo PE F040GRV
    @author     CAOA - A.Carlos
    @since 		04/07/2023
    @version 	1.0
    /*/
User Function ZFINF004()
Local _lRet  := .T.
Local _aArea := GetArea()
Local _cEmp  := FWCodEmp()

IF _cEmp == "2010" .AND. SE1->E1_TIPO = 'RA ' .AND. SE1->E1_PARCELA = '1 ' 

	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG)) .AND. FWIsInCallStack("U_M460FIM_PE")
        GrvDBSe1()
	Endif
    
	IF FWIsInCallStack("U_MT410TOK")
	    GeraTitulo('Abat. RA','NF ','1','NF ')
    ENDIF

ELSEIF _cEmp == "2010" .AND. SE1->E1_TIPO = 'RA ' .AND. SE1->E1_PARCELA = '2 ' .AND. !Empty(SC5->C5_XNPG)

	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(xFilial("SE4")+SC5->C5_XNPG)) .AND. FWIsInCallStack("U_M460FIM_PE")
        GrvDBSe1()
	Endif

ELSEIF _cEmp == "2010" .AND. SE1->E1_TIPO = 'RA ' .AND. SE1->E1_PARCELA = '3 ' .AND. !Empty(SC5->C5_XNPG1)

	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(xFilial("SE4")+SC5->C5_XNPG1)) .AND. FWIsInCallStack("U_M460FIM_PE")
        GrvDBSe1()
	Endif

ENDIF

RestArea(_aArea)

return(_lRet) 


/*/{Protheus.doc} ZFINF004
	Função para gravar a forma de pagamento no título de RA usada para integração com o SAP.
    @type       Function
    @author     CAOA - A.Carlos
    @since 		04/07/2023
    @version 	1.0
/*/
Static Function GrvDBSe1()
	RecLock("SE1",.F.)
	SE1->E1_XFORMA  := SE4->E4_XFORMA
	SE1->E1_PORTADO := SA6->A6_COD 
	SE1->E1_AGEDEP  := SA6->A6_AGENCIA
	SE1->E1_CONTA   := SA6->A6_NUMCON
	MsUnlock()
Return()


/*/{Protheus.doc}  GeraTitulo
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	15/06/2023
@return  	NIL
@obs        Gerar os Títulos do Pedido de Venda Futuro em array
@project
@history
/*/
Static Function GeraTitulo(_cHist,_cPrefixo,_cParcela,_cTipo)
Local _aVSE1      := {}
//Local _aVetSE1    := {}
Local _cForma     := ""
Local _cNomCli    := ""
Local _dEmissao   := DDataBase
Local _dVenc      := SE1->E1_VENCTO
Local _dVencReal  := SE1->E1_VENCREA
Local _nValor     := SE1->E1_VALOR
Local lMsErroAuto := .F.

    _cNomCli := POSICIONE("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")
    _cForma  := SE4->E4_XFORMA

    //Prepara o array para o execauto
    aAdd(_aVSE1, {"E1_FILIAL",  FWxFilial("SE1"),  Nil})
    aAdd(_aVSE1, {"E1_NUM",     SC5->C5_NUM,       Nil})
    aAdd(_aVSE1, {"E1_PREFIXO", _cPrefixo,         Nil})
    aAdd(_aVSE1, {"E1_PARCELA", _cParcela,         Nil})
    aAdd(_aVSE1, {"E1_TIPO",    _cTipo,            Nil})
    aAdd(_aVSE1, {"E1_NATUREZ", SC5->C5_NATUREZ,   Nil})
    aAdd(_aVSE1, {"E1_CLIENTE", SC5->C5_CLIENTE,   Nil})
    aAdd(_aVSE1, {"E1_LOJA",    SC5->C5_LOJACLI,   Nil})
    aAdd(_aVSE1, {"E1_NOMCLI",  _cNomCli,          Nil})
    aAdd(_aVSE1, {"E1_EMISSAO", _dEmissao,         Nil})   //DTOC(_dEmissao)
    aAdd(_aVSE1, {"E1_VENCTO",  _dVenc,            Nil})   //DTOC(_dVenc)
    aAdd(_aVSE1, {"E1_VENCREA", _dVencReal,        Nil})   //DTOC(_dVencReal)
    aAdd(_aVSE1, {"E1_VALOR",   _nValor,           Nil})
    aAdd(_aVSE1, {"E1_VALJUR",  0,                 Nil})
    aAdd(_aVSE1, {"E1_PORCJUR", 0,                 Nil})
    aAdd(_aVSE1, {"E1_XFORMA",  _cForma,           Nil})
    aAdd(_aVSE1, {"E1_HIST",    _cHist,            Nil})
    aAdd(_aVSE1, {"E1_MOEDA",   1,                 Nil})

    //aAdd(_aVetSE1, aClone(_aVSE1))

    IF !Empty(_aVSE1)
        Begin Transaction
        dbSelectArea("SE1")
        dbSetOrder(1)
        If !dbSeek(xFilial("SE1") + _cPrefixo + SC5->C5_NUM + '   ' + _cParcela + _cTipo)//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                                                  
                lMsErroAuto := .F.
                MSExecAuto({|x,y| FINA040(x,y)}, _aVSE1, 3)
                If lMsErroAuto
                    lRet := .F.
                    MostraErro()
                else
                    lRet := .T.
                EndIf

            IF !lRet
                DisarmTransaction()
                Return()
            ENDIF
        Else
            MsgInfo("Parcela já existente para esse PV.", "ZFINF004")
            DisarmTransaction()
            Return()
        Endif
        End Transaction
    Endif
    
Return()
