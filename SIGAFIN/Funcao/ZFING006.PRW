#include "Protheus.ch"
#include 'parmtype.ch'
#include 'TOPCONN.CH'
#include "TBICONN.CH"
/*/{Protheus.doc} ZFING006
	Função P.E. na inclusao do titulo a receber de RA p/ alterar cond pgto
    @type       Function
    @author     CAOA - A.Carlos
    @since 		15/06/2023
    @version 	2.0
	@param 		
    @example
    @see
    @history    
/*/
User Function ZFING006()
    Local _nMaxParc := SUPERGETMV("CMV_FIN001",.T.,4) //Qtde de parcelas para o PV Futuro  
    Local _aArea    := GetArea()
	Local _cEmp     := FWCodEmp()
    Local _nVlra    := 0
    Local _nOpcDif  := 0
    Local _nParcelas:= 0
    Local _nPeriodo := 0
    Local _nVlGrv   := 0
    Local _cHist    := Space(40)
    Local _cParcela := ""
    Local _cPrefixo := "PVF"
    Local _cTipo    := "NF" 
    Local oDlg

    Private _cCondPgto := ""
    Private _aVetSE1   := {}
    Private _dEmissao  := DDataBase
    Private _dVenc     := Ctod("  /  /    ") 
    Private _dVencReal := Ctod("  /  /    ")
    Private _nValor    := 0
    Private _nVlTtl    := 0
    Private nVlTtl     := 0

	If _cEmp == "2010" //.AND. IsInCallStack("MATA410") //Executa o p.e. Anapolis.
         
       IF Altera
           DbSelectArea("SE1")
	       SE1->(DbSetOrder(1))  //Filial + Prefixo + Num + Parcela + Tipo

		   if SE1->( DbSeek(xFilial("SE1") + 'RA ' + M->C5_NUM + '   ' + '1 ' + 'RA ') )
               
                IF SE1->E1_BAIXA //O titulo precisa estar baixado

                    Ver_Item()
           
                    //M->C5_XPVFT := '1'
                    _nVlra      := SE1->E1_VALOR
                    _cCondPgto  := SC5->C5_CONDPAG
                    _cHist      := Space(40)

                ENDIF

                While .T. .AND. _nParcelas < _nMaxParc 

                    _nParcelas++

                    _nValor   := 0

                    IF _nParcelas = 1
                        _nValor  := SE1->E1_VALOR
                    else
                        _nVlTtl  := nVlTtl - _nVlGrv
                        _nValor  := nVlTtl - _nVlGrv
                    EndIf

                    _nOpcDif := 0
                    DEFINE MSDIALOG oDlg FROM	0,0 TO 260,280 TITLE "Entrada da Diferença" PIXEL    //DEFINE MSDIALOG oDlg FROM	0,0 TO 235,280 TITLE STR0053 PIXEL //"Desdobramento"

                    @ 004, 007 TO 125, 105 OF oDlg PIXEL
                    
                    @ 010, 014 SAY "Condição Pagamento" SIZE 90, 7 OF oDlg PIXEL  //"Condição de Pagamento"
                    @ 028, 014 SAY "Numero de Parcelas" SIZE 90, 7 OF oDlg PIXEL  //"Numero de Parcelas"
                    @ 046, 014 SAY "Valor do Titulo"    SIZE 90, 7 OF oDlg PIXEL  //"Valor do Titulo (Total ou Parcela)"
                    @ 064, 014 SAY "Vencimento"         SIZE 90, 7 OF oDlg PIXEL  //"Periodo de Vencto. (em dias)"
                    @ 082, 014 SAY "Historico"          SIZE 90, 7 OF oDlg PIXEL  //"Historico"

                    @ 018, 014 MSGET _cCondPgto	F3 "SE4"    Picture "!!!" SIZE 72, 08 OF oDlg PIXEL ;
                                                             When IIf(_nParcelas=1,.F.,.T.);
                                                             Valid (Empty (_cCondPgto) .or. ExistCpo("SE4",_cCondPgto)) .and. ;
                                                             Fa290Cond(_cCondPgto)
                    @ 036, 014 MSGET  _nParcelas   	        Picture "9999" When IIf(Empty(_cCondPgto),.T.,.F.);
                                                            Valid f040ValPar(_nParcelas,_nMaxParc) ;
                                                            SIZE 80, 08 OF oDlg PIXEL
                    @ 054, 014 MSGET  _nValor   	        Picture "9,999,999.99" SIZE 80, 10 OF oDlg PIXEL;
                                                             When IIf(_nParcelas=1,.F.,.T.);
                                                             Valid fValTtl(_nParcelas,_nMaxParc);
                                                             
                    //Valid IIf(_nParcelas=_nMaxParc,_nVlTtl,_nValor < _nVlTtl);
                    // When IIf(_nValor <= (SC6->C6_VALOR - SE1->E1_VALOR),.T.,.F.);
                    //@ 054, 014 COMBOBOX oVlDsd VAR _nValor ITEMS {"TOTAL","PARCELA"} SIZE 80, 10 OF oDlg PIXEL ; //"TOTAL"###"PARCELA" //"TOTAL"###"PARCELA"
                    //When IIf(Empty(_cCondPgto),.T.,.F.)

                    @ 072, 014 MSGET _dVencReal	            Picture "999" When IIf(!Empty(_cCondPgto),.T.,.T.) ;
                    Valid MyCond(_nValor,_cCondPgto,_dEmissao);
                    SIZE 80, 08 OF oDlg PIXEL
                    @ 090, 014 MSGET  _cHist	            Picture "@A40";   // When IIf(!Empty(_cHist),.T.,.T.) ;
                    SIZE 80, 08 OF oDlg PIXEL

                    //@ 108, 014 COMBOBOX oDesdDif VAR _cDesdDif ITEMS {"","1=SIM","2=NÃO"} SIZE 80, 10; 
                    //OF oDlg PIXEL When lVLDINSS

                    DEFINE SBUTTON FROM 07, 110 TYPE 1 ACTION ;
                    {||_nOpcDif:=1,IF(A040TudoOK(_cCondPgto,_nParcelas,_nValor,_nPeriodo),oDlg:End(),_nOpcDif:=0)} ENABLE OF oDlg
                    DEFINE SBUTTON FROM 23, 110 TYPE 2 ACTION {||_nOpcDif:=0 ,oDlg:End()} ENABLE OF oDlg

                    ACTIVATE MSDIALOG oDlg CENTERED

                    _nVlGrv  := _nVlGrv + _nValor
                
                    If _nOpcDif == 1

                        GeraTitulo(_nParcelas,_cHist,_cPrefixo,_cParcela,_cTipo) //Gerar os títulos PVF
                        IF _nParcelas=_nMaxParc
                            If MsgYesNo("Gerar Títulos ? ")
                                GrvTitulo(_aVetSE1,_cPrefixo,_cParcela,_cTipo)
                            Else
                                Exit
                            Endif
                        ENDIF
                    else  //_nOpcDif == 0

                        If MsgYesNo("Gerar Títulos ? ")
                            GrvTitulo(_aVetSE1,_cPrefixo,_cParcela,_cTipo)
                        Else
                            Exit
                        Endif
                    
                    Endif

                EndDo	
           
           endif
	
       ENDIF

	EndIf

    RestArea(_aArea)

Return(M->C5_XPVFT)


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
Static Function GeraTitulo(_nParcelas,_cHist,_cPrefixo,_cParcela,_cTipo)
Local _aVSE1    := {}
Local _cForma   := ""
Local _cNomCli  := ""
Local _nPcJuros := 0
Local _nVlJuros := 0

    _cParcela:= PADR(Alltrim(Str(_nParcelas)),2," ")
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
    aAdd(_aVSE1, {"E1_VALJUR",  _nVlJuros,         Nil})
    aAdd(_aVSE1, {"E1_PORCJUR", _nPcJuros,         Nil})
    aAdd(_aVSE1, {"E1_XFORMA",  _cForma,           Nil})
    aAdd(_aVSE1, {"E1_HIST",    _cHist,            Nil})
    aAdd(_aVSE1, {"E1_MOEDA",   1,                 Nil})

    aAdd(_aVetSE1, aClone(_aVSE1))
    
Return()


/*/{Protheus.doc}  GrvTitulo
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	15/06/2023
@return  	NIL
@obs        Gravar os Títulos do Pedido de Venda Futuro que se encontravam em array
@project
@history
/*/
Static Function GrvTitulo(_aVetSE1,_cPrefixo,_cParcela,_cTipo)
Local lRet        := .T.
Local I           := 0
Local lMsErroAuto := .F.

IF !Empty(_aVetSE1)
    Begin Transaction
    FOR I := 1 TO Len(_aVetSE1)
        dbSelectArea("SE1")
        dbSetOrder(1)
        If !dbSeek(xFilial("SE1") + _cPrefixo + M->C5_NUM + '   ' + _aVetse1[I][4][2] + _cTipo)//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                                                  
                lMsErroAuto := .F.
                MSExecAuto({|x,y| FINA040(x,y)}, _aVetSE1[I], 3)
                If lMsErroAuto
                    lRet := .F.
                    MostraErro()
                else
                    lRet := .T.
                EndIf

            IF !lRet
                Exit
            ENDIF
        Else
            MsgInfo("Parcelas já criadas para esse PV.", "ZFING006")
            Return()
        Endif
    Next

    IF lRet
        MsgInfo("Parcelas criadas com sucesso.", "ZFING006")   
    ELSE
        !lRet
        DisarmTransaction()
    ENDIF

    End Transaction
ENDIF

Return()


/*/{Protheus.doc}  Ver_Item
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	15/06/2023
@return  	NIL
@obs        Verifica totaldo Pedido de Vendas
@project
@history
/*/
Static Function Ver_Item()
	Local cQy	  := " "
	Local cAlias  := "ITEM"

    lRes  := .F. 
	lResL := .F. 
	cQy := " SELECT SUM(C6_VALOR) nSomaPv " + CRLF 
	cQy += "  FROM " + RetSQLName("SC6") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ = ' '" + CRLF 
	cQy += " AND C6_FILIAL = '"   + xfilial('SC6') + "' " + CRLF 
	cQy += " AND C6_NUM    = '"   + M->C5_NUM + "' " + CRLF  

	TcQuery cQy new Alias (cAlias)

    nVlTtl := (cAlias)->nSomaPv

	(cAlias)->(DbCloseArea())
Return(nVlTtl)


STATIC Function MyCond(_nValor,_cCondPgto,_dEmissao)
Local _aParc := {}
Local cQy	  := ""
Local cAlias  := "COND"
Local _Cond   := ""

	cQy := " SELECT E4_COND " + CRLF 
	cQy += "  FROM " + RetSQLName("SE4") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ = ' '" + CRLF 
	cQy += " AND E4_FILIAL = '"   + xfilial('SE4') + "' " + CRLF 
	cQy += " AND E4_CODIGO = '"   + _cCondPgto + "' " + CRLF  

	TcQuery cQy new Alias (cAlias)

    _Cond := Alltrim((cAlias)->E4_COND)

	(cAlias)->(DbCloseArea())

    IF _Cond <> "00"
        _aParc     :=  Condicao(_nValor,_cCondPgto,,_dEmissao)
        _dVenc     :=  _aParc[1,1]
    ELSE
        _dVenc     := _dEmissao
    ENDIF
    
    _dVencReal :=  DataValida(_dVenc)   

Return(_dVencReal)


/*/{Protheus.doc} F040Valpar
	Função Faz verificacao do numero de parcelas
    @type       Function
    @author     CAOA - A.Carlos
    @since 		15/06/2023
    @version 	2.0
	@param 		
    @example
    @see
    @history    
/*/
Static Function F040VALPAR(_nParceDsd,_nMaxParc)

If _nParceDsd > _nMaxParc .or. _nParceDsd < 2
	Help(" " , 1 , "Parcelas invalidas!")
	Return .F.
Endif	

Return .T.


Static Function fValTtl(_nParcelas,_nMaxParc)
Local lRet := .F.
If _nParcelas = _nMaxParc 
    IF _nValor = _nVlTtl
        lRet := .T.
    ENDIF
Else    
    IF _nValor <= _nVlTtl
        lRet := .T.
    ENDIF 
ENDIF

Return(lRet)


/*/{Protheus.doc} A040TudoOK³
	Função Verifica se dados para geração de títulos estão corretos
    @type       Function
    @author     CAOA - A.Carlos
    @since 		15/06/2023
    @version 	2.0
	@param 		
    @example
    @see
    @history    
/*/
Static Function A040TudoOk(_cCondPgto,_nParcelas,_cValor,_nPeriodo)

If nModulo <> 11 .And. nModulo <> 14 .And. Alltrim(_cCondPgto) == "A"
	Help(" " , 1 , "CONDPGTOA",,"exclusiva SIGAVEI",1,0) // "Condição de Pagamento exclusiva para os ambientes Veículos (SIGAVEI) e Oficinas (SIGAOFI)"
	Return .F.
Endif

If Empty (_cCondPgto)
	If _nParcelas < 2 .or. _nParcelas > _nMaxParc .or. Empty(_cValor) .or. _nPeriodo <= 0
		Help(" " , 1 , "FA050DADOS")
		Return .F.
	Endif
Endif

Return .T.
