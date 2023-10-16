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
Local  lRet     := .T.
Local _aArea    := GetArea()
Private _cEmp   := FWCodEmp()
Private _cBanco := ''
Private _cAge   := ''
Private _cConta := ''

IF _cEmp == "2010" .AND. SC5->C5_XPREFIX == 'PVF' .AND. SE1->E1_PARCELA == '1 ' .AND. FWIsInCallStack("MATA461")

    _cBanco := SA6->A6_COD 
    _cAge   := SA6->A6_AGENCIA
    _cConta := SA6->A6_NUMCON

    SE1->(dbSetOrder(1))
    If SE1->(dbSeek(xFilial("SE1") + SC5->C5_XPREFIX + M->C5_NUM + '   ' + '1 ' + 'RA '))                                                                                                                
        RecLock("SE1",.F.)
        SE1->E1_PORTADO := _cBanco 
        SE1->E1_AGEDEP  := _cAge
        SE1->E1_CONTA   := _cConta
        MsUnlock()
	ENDIF

    IF !lRET
        Return(lRet)
    Endif

ELSEIF _cEmp == "2010" .AND. SC5->C5_XPREFIX == 'PVF' .AND. SE1->E1_PARCELA = '2 ' .AND. !Empty(SC5->C5_XNPG)

	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(xFilial("SE4")+SC5->C5_XNPG)) .AND. FWIsInCallStack("U_M460FIM_PE")
        GrvDBSe1()
	Endif

ELSEIF _cEmp == "2010" .AND. SC5->C5_XPREFIX == 'PVF' .AND. SE1->E1_PARCELA = '3 ' .AND. !Empty(SC5->C5_XNPG1)

	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(xFilial("SE4")+SC5->C5_XNPG1)) .AND. FWIsInCallStack("U_M460FIM_PE")
        GrvDBSe1()
	Endif

ENDIF

RestArea(_aArea)

return(lRet) 


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


/*/{Protheus.doc}  GTitulo
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	15/06/2023
@return  	NIL
@obs        Gerar os Títulos do Pedido de Venda Futuro em array
@project
@history
/*/
Static Function GTitulo(_cHist,_cPrefixo,_cParcela,_cTipo)
Local _aVSE1      := {}
Local _cForma     := ""
Local _cNomCli    := ""
Local _dEmissao   := DDataBase
Local _dVenc      := SE1->E1_VENCTO
Local _dVencReal  := SE1->E1_VENCREA
Local _nValor     := SE1->E1_VALOR
Local lMsErroAuto := .F.
Local nOpc        := 3
Local cxFil       := xFilial("SZ7")
Local cTab        := "SE1"
Local cChave      := ""   //E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
Local cIndice     := "1"
Local lRet        := .T.
//Local cLote       := ""
//Local cSequen     := ""
////Local cStatusSZ7  := "P"
Local nOperPro    := 1    
Local nOperSAP    := 1  

    _cNomCli := POSICIONE("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_NOME")
    _cForma  := SE4->E4_XFORMA

    //Prepara o array para o execauto
    aAdd(_aVSE1, {"E1_FILIAL",  FWxFilial("SE1"),  Nil})
    aAdd(_aVSE1, {"E1_NUM",     M->C5_NUM,         Nil})
    aAdd(_aVSE1, {"E1_PREFIXO", _cPrefixo,         Nil})
    aAdd(_aVSE1, {"E1_PARCELA", _cParcela,         Nil})
    aAdd(_aVSE1, {"E1_TIPO",    _cTipo,            Nil})
    aAdd(_aVSE1, {"E1_NATUREZ", M->C5_NATUREZ,     Nil})
    aAdd(_aVSE1, {"E1_CLIENTE", M->C5_CLIENTE,     Nil})
    aAdd(_aVSE1, {"E1_LOJA",    M->C5_LOJACLI,     Nil})
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
    aAdd(_aVSE1, {"E1_PORTADO", _cBanco,           Nil})
    aAdd(_aVSE1, {"E1_AGEDEP",  _cAge,             Nil})
    aAdd(_aVSE1, {"E1_CONTA",   _cConta,           Nil})

    IF !Empty(_aVSE1)
        SE1->(dbSetOrder(1))
        If SE1->(!dbSeek(xFilial("SE1") + _cPrefixo + M->C5_NUM + '   ' + _cParcela + _cTipo))//E1_FILIAL+                                                                                                                 
                lMsErroAuto := .F.
                MSExecAuto({|x,y| FINA040(x,y)}, _aVSE1, nOpc)
                If lMsErroAuto
                    lRet := .F.
                    MostraErro()
                    Return(lRet)
                else

                    lRet := .T.
                    cChave  := _cPrefixo + M->C5_NUM + '   ' + _cParcela + _cTipo + M->C5_CLIENTE + M->C5_LOJACLI 
                    U_ZF11GENSAP(cxFil,cTab,cIndice,cChave,nOperPro,nOperSAP,,,,)

                    /*If SZ7->(RecLock("SZ7",.T.))
                        
                                   
                        cLote 	:= GetSxeNum("SZ7","Z7_XLOTE")                                                                                                                   
                        cSequen	:= U_ZF20GENSAP(cxFil , cTab , cChave)
                        
                        If nOperSAP == 2//Cancelamento
                            SZ7->Z7_XXML := U_ZF23GENSAP(cxFil,cTab,cChave)
                        EndIf

                        SZ7->Z7_FILIAL 	:= cxFil
                        SZ7->Z7_XLOTE 	:= cLote
                        SZ7->Z7_XTABELA := cTab
                        SZ7->Z7_XINDICE := cIndice
                        SZ7->Z7_XCHAVE 	:= cChave
                        SZ7->Z7_XSEQUEN := cSequen
                        SZ7->Z7_XSTATUS := cStatusSZ7 //IIf(FWIsInCallStack("xBaixTit"),"O",cStatusSZ7)
                        SZ7->Z7_XOPEPRO	:= nOperPro //1=Inclusao/2=Alteracao/3=Exclusao
                        SZ7->Z7_XOPESAP	:= nOperSAP //1=Inclusao/2=Cancelamento
                        SZ7->Z7_XDTINC	:= dDataBase
                        SZ7->Z7_XHRINC	:= Time()

                        If _cEmp == "2010" //Executa o p.e. Anapolis.
                            SZ7->Z7_ORIGEM  := IIf(IsInCallStack("FINA040"),FunName(),"FINA050")
                        Else
                            SZ7->Z7_ORIGEM  := IIf(IsInCallStack("MATA020") .or. IsInCallStack("MATA030"),FunName(),IIf(Len(aDadosOri) > 1 .and. !Empty(aDadosOri[1]),aDadosOri[1],IIf(FWIsInCallStack("xBaixTit"),"ZSAPF006",IIf(FWIsInCallStack("FINA040"),"FINA040",IIf(FWIsInCallStack("FINA050"),"FINA050",CT2->CT2_ROTINA)))))
                        EndIf

                        SZ7->Z7_OPERACA := IIf(cTab$"SA2","1",IIf(cTab$"SA1","2",IIf(cTab$"SF1/SE2","3",IIf(cTab$"SF2/SE1","4",IIf(cTab$"CT2","5","")))))

                        //SZ7->Z7_LOTEINC := IIf(!Empty(aDadosOri) .and. Len(aDadosOri) > 7,aDadosOri[8],"")

                        If !Empty(aOcor)
                            If aOcor[2] == "1" // erro protheus
                                SZ7->Z7_ERROPRO := aOcor[1]
                            Elseif aOcor[2] == "2" // erro sap
                                SZ7->Z7_ERROSAP := aOcor[1]
                            Endif
                        Endif

                        SZ7->Z7_TIPONF := "N"
                        SZ7->Z7_DOCORI := SE1->E1_NUM
                        SZ7->Z7_SERORI := SE1->E1_PREFIXO
                        SZ7->Z7_RECORI := SE1->(Recno())
                        SZ7->Z7_CLIFOR := SE1->E1_CLIENTE
                        SZ7->Z7_LOJA   := SE1->E1_LOJA

                        SZ7->(MsUnLock())
                        ConfirmSX8()
                    EndIf*/    

                    _aVSE1 := {}   //Limpar o vetor

                EndIf

        Else
            MsgInfo("Parcela já existente para esse PV.", "ZFINF004")
            Return(lRet)
        Endif

    Endif

Return(lRet)
