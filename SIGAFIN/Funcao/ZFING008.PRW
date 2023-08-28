#include "Protheus.ch"
#include 'parmtype.ch'
#include 'TOPCONN.CH'
#include "TBICONN.CH"

/*/{Protheus.doc} ZFING007
	Função P.E. na inclusao do titulo a receber de RA p/ ao alterar cond pgto digitar parcela1
    @type       Function
    @author     CAOA - A.Carlos
    @since 		15/06/2023
    @version 	2.0
	@param 		
    @example
    @see
    @history    
/*/
User Function ZFING008()
    Local _aArea    := GetArea()
	Local _cEmp     := FWCodEmp()
    Local _nVlra    := 0

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
               
                //IF SE1->E1_BAIXA //O titulo precisa estar baixado

                    Ver_Item()
           
                   // M->C5_XPVFT := '1'
                    _nVlra      := SE1->E1_VALOR
                    _cCondPgto  := SC5->C5_CONDPAG

                //ENDIF

                Ver_Item()

                IF SE4->E4_TIPO = '9'
                    M->C5_PARC2 := nVlTtl - _nVlra
                    M->C5_DATA2 := MyCond(M->C5_PARC2,_cCondPgto,_dEmissao)
                ENDIF

            ENDIF

        ENDIF
    
    ENDIF

    RestArea(_aArea)

Return(M->C5_PARC2)


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

