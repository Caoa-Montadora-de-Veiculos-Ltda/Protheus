
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "Totvs.ch"
#include "Topconn.ch"



#define CMP0001 "Cancelamento Fatura relativo a Orçamentos"
#define CMP0002 "Tipo de Cancelamento"
#define CMP0003 "1=Cancelar Nota Fiscal"
#define CMP0004 "2=Cancelar Nota Fiscal e Pedido"
#define CMP0005 "3=Cancelar Nota Fiscal, Pedido e Orçamento"
#define CMP0006 "Este Programa tem  como  Objetivo  realizar o Cancelamento de Fatura"
#define CMP0007 "obedecendo o Tipo de Cancelamento onde possibilitará o cancelamento "
#define CMP0008 "da fatura retornando o orçamento ao status A Faturar, ou o cancelamento"
#define CMP0009 "da Fatura retornando o orçamento ao status inicial ou o canelamento"
#define CMP0010 "da Fatura retornando o orçamento ao status de cancelado."
#define CMP0011 "Clique no botão Parâmetros para alterar as definições da rotina."
#define CMP0012 "Depois clique no Botão OK."
#define CMP0013 "Necessário informar os parâmetros "
#define CMP0014 "Atenção"
#define CMP0015 "Problemas na seleção contate o ADM Sistema"


/*/{Protheus.doc}
@param
@author  DAC - Denilso
@version P12.1.25
@since   11/05/2022
@return  Lógico
@obs     PE utilizado no cancelamento de orçamentos para definir os tipos de cancelamento a serem utilizados
@project Barueri
@Obs     11/05/2022- Este PE esta sendo utilizado devido não existir ponto de entrada para alterar aRotina 
                     sendo assim sou obrigado a direcionar o tipo de cancelamento no decorrer do processo de cancelamento
@history
/*/
User Function OFM220AT()
Local _lRet       := .T.
Local _aArea      := GetArea()
Local _aPar       := {}
Local _aSays      := {}
Local _aButtons   := {}
Local _aRet       := {}
Local _nRet       := 0
Local _cTitle     := "Cancelamento de Fatura"
Local _cNF        := SF2->F2_DOC  
Local _cSerieNF   := SF2->F2_SERIE
Local _cMensRet   := ""
Local _cMsg

Begin Sequence

   If !U_XVERCANFe( SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, @_cMensRet )
      MSGINFO(OemToAnsi(_cMensRet),OemToAnsi(CMP0014)) // Problemas na seleção contate o ADM Sistema / Atenção
      _lRet := .F.
      //Break
   EndIf
   If !_lRet
      Break
   EndIf
	aAdd(_aPar,{3,OemToAnsi(CMP0002) ,2 ,{CMP0003,CMP0004,CMP0005}	,120,"",.F.})  //Tipo de Cancelamento / 1= Cancelar Nota Fiscal 2=Cancelar Nota Fiscal e Pedido 3=Cancelar Nota Fiscal, Pedido e Orçamento
	AADD(_aSays,OemToAnsi(CMP0006)) //Este Programa tem  como  Objetivo  realizar o Cancelamento de Fatura
	AADD(_aSays,OemToAnsi(CMP0007)) //obedecendo o Tipo de Cancelamento onde possibilitará o cancelamento 
	AADD(_aSays,OemToAnsi(CMP0008)) //da fatura retornando o orçamento ao status 'A Faturar', ou o cancelamento
	AADD(_aSays,OemToAnsi(CMP0009)) //da Fatura retornando o orçamento ao status inicial ou o canelamento
	AADD(_aSays,OemToAnsi(CMP0010)) //da Fatura retornando o orçamento ao status de cancelado.
	AADD(_aSays,OemToAnsi(""))
	AADD(_aSays,OemToAnsi(CMP0011)) //Clique no botão Parâmetros para alterar as definições da rotina. 
	AADD(_aSays,OemToAnsi(CMP0012)) //Depois clique no Botão OK.
	AADD(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
	AADD(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
	AADD(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,"XOFM220AT",.T.,.T.) 			}})

	FormBatch( CMP0001, _aSays, _aButtons )
   If _nRet <> 1
      _lRet := .F.
       Break
   Endif
    If Len(_aRet) == 0
        MSGINFO(OemToAnsi(CMP0013),OemToAnsi(CMP0014)) // Necessário informar os parâmetros / Atenção
         _lRet := .F.
        Break 
    Endif
  
   _nOpc := _aRet[1] 
   If _nOpc <= 0 .and. _nOpc > 3
      MSGINFO(OemToAnsi(CMP0015),OemToAnsi(CMP0014)) // Problemas na seleção contate o ADM Sistema / Atenção
      _lRet := .F. 
      Break 
   Endif

   _cMsg := If(_nOpc==1,"Cancelar Nota fiscal",;
            If(_nOpc==2,"Cancelar Nota Fiscal e Pedido",;
            If(_nOpc==3,"Cancelar Nota Fiscal, Pedido e Orçamento",;
            ""   )))
   If !MsgYesNo( "Confirma "+_cMsg+" - NF/Serie "+_cNF+"/"+_cSerieNF+" ?" )
      _lRet := .F.
      Break 
   EndIf
   //Necessário utilizar as valiaveis publicas pois existe chamadas recursivas passando por PE e não é possivel
   //utilizar PE para arotina (não existe PE), não pode ser Private pois não sera enxergado por outro PE - DAC 11/05/2022
   Public _XlLiberaOrc  := .F. //Cancelar a NF e deixa o orçamento com status a faturar "F" sera visto no PE OFM220FN
   Public _XlCancelaOrc := .F. //Cancelar o orçamento sera visto no PE OFM220FN
   If _nOpc == 1
      //Chamar a função cancelar OFM220AT 
      _XlLiberaOrc := .T.
      //MSGINFO("Em desenvolvimento",OemToAnsi(CMP0014)) //Atenção / Necessário informar os parâmetros 
      //Chamada da funcionalidade para a exclusão do orçamento ao qual esta a Nota Fiscal
      //OM220CANC(cOrcLoja,cNota)   
      //Processa( {|| lRetorno := OM220Cancela( cParSerie , cParNota , cParPrefixo ) } )
      //_lRet := .F. //retornar .f. pois ja executei a rotiana
      //Break
   ElseIf _nOpc == 3
      Public _XlCancelaOrc := .T. //Cancelar o orçamento sera visto no PE OFM220FN
   Endif
End Sequence

  //Ajuste Realizado por erro no Cancelamento da NF Autorizadas e trata para efetivar no SIGAPEC e FISCAL
If SF2->F2_CHVNFE != ' '
   If !MaCanDelF2("SF2",SF2->(RecNo()), , ,) 
      Alert('Aguardando Autorização SEFAZ para o cancelamento da NFe. Tente novamente dentro de alguns minutos')
   Endif
Endif

RestArea(_aArea)
Return _lRet 
