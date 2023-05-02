#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH"
#include "rwmake.ch"
#include "TOTVS.ch"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "Eicsi400.ch"
#INCLUDE "AvPrint.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWFILTER.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _cEol CHR(13)+CHR(10)  //final de linha
//-------------------------------------------------------------------
/*/{Protheus.doc} ZCOMF029
Reestruturação montar tela de Histórico do Pedido de Compras 
@author     A.Carlos
@since 		21/10/2020
@param     	_aParam - Com informações paramb do MT120TEL
@return    	Logico
@project    CAOA
@menu       Nao Informado
@version 	1.0
@obs        Chamado pelo Ponto de Entrada MT120TEL
@history    
/*/
//-------------------------------------------------------------------
User Function ZCOMF029(_aParam)
Local _oCourierNw	:= TFont():New("Courier New",,,,.F.,,,,.F.,.F.)
Local _oNewDialog   
Local _aPosGet      
Local _nOpcx        
Local _nSalta 		
Local _nCont  		
Local _nCol  		
Local _nLin
Local _nPos
Local _cTela    := " "
Local _oMemo    := " "
Local _oObscmp  := " "
Local _oXobsCom := " "
Local _oXFORMAI := " "
Local _bXTPIMPGWhen 
//Local aTpReq    := {'Item 1','Item 2','Item 3','Item 4'}

Public cC7_SCOM 	:= Space(10)
Public cC7_SFOR 	:= Space(10)
Public cC7_XOCOM    := Space(10)
Public cC7_XFORMAI  := ""
Public cC7_XTPREQ   := space(04)
Public cC7_XTPRE2   := space(04)
Public cC7_XFCA     := space(01)

// ** CAOA - COM - VARIAVEIS PARA DADOS COMPLEMENTARES - ROTINA ZCOMF003 - GAP COM007/001

Begin Sequence
	
	If _aParam == Nil .or. LEN(_aParam) < 4
		Break
	Endif

 	_oNewDialog   := _aParam[1]
	_aPosGet      := _aParam[2]
	_nOpcx        := _aParam[4]
	//_nReg         := _aParam[4]
	//_bXTPIMPGWhen := { || _nOpcx == 2 .Or. _nOpcx == 3 .Or. _nOpcx == 4 }
    _bXTPIMPGWhen := { ||  _nOpcx == 3 .Or. _nOpcx == 4 }


	//PARA EVITAR ERROS NA TELA NECESSARIO
	If !INCLUI  //CASO NÃO SEJA INCLUSAO
    	If SC7->(FieldPos("C7_XOBSCOM")) > 0
        	cC7_SCOM := SC7->C7_XOBSCOM  
		Endif
        If SC7->(FieldPos("C7_XOBSFOR")) > 0
        	cC7_SFOR := SC7->C7_XOBSFOR             
		Endif
		If SC7->(FieldPos("C7_XOBSTST")) > 0
        	cC7_XOCOM := SC7->C7_XOBSTST             
		Endif
		If SC7->(FieldPos("C7_XFORMAI")) > 0
        	cC7_XFORMAI := SC7->C7_XFORMAI             
		Endif
		If SC7->(FieldPos("C7_XTPPED")) > 0
        	   cC7_XTPREQ := SC7->C7_XTPPED          
		Endif
        If SC7->(FieldPos("C7_XFCA")) > 0
        	   cC7_XFCA := SC7->C7_XFCA          
		Endif
	Endif

	_nCol  := Len(_aPosGet[1])+1  //pega o tamanho definido pelo padrão acrescentar a proxia
	_nCont := 1   				  //Primeira coluna de impressão a linha
    For _nPos := 1 To 8
		//forço quebrar para a primeira linha neste ponto ex xreqemai
		If _nPos >= 7
			_nCont := 1
		EndIf
		aadd(_aPosGet[1],_aPosGet[1,_nCont])
		aadd(_aPosGet[1],_aPosGet[1,_nCont+1])
		_nCont += 2
	Next

  	_nSalta := 15
	_nLin	:= 63
	_nLin += _nSalta

  	IF FunName() = "MATA121" 
        _cTela := "P.C."
    ELSEIF FunName() = "MATA122"
	    _cTela := " A.E."
	ENDIF

    @ 062, _aPosGet[1,08] - 012 SAY 'Tipo de Documento' PIXEL SIZE 50,10 Of _oNewDialog  
    IF _cTela == "P.C."
       @ 061, _aPosGet[1,09] - 006     MSGET  cC7_XTPREQ  PICTURE "@!" Valid Empty(cC7_XTPREQ) .or. u_FVALTPO("PC",cC7_XTPREQ,"")  F3 "ZA4"   SIZE 80, 08  WHEN Eval( _bXTPIMPGWhen )   Of _oNewDialog PIXEL FONT _oCourierNw 
    ELSE
       @ 061, _aPosGet[1,09] - 006     MSGET  cC7_XTPREQ  PICTURE "@!" Valid Empty(cC7_XTPREQ) .or. u_FVALTPO("AE",cC7_XTPREQ,"")  F3 "ZA4"   SIZE 80, 08  WHEN Eval( _bXTPIMPGWhen )   Of _oNewDialog PIXEL FONT _oCourierNw 
    ENDIF
    @ _nLin, 13 SAY 'Obs. Geral ' + _cTela PIXEL SIZE 40,10 Of _oNewDialog  
	@ _nLin, _aPosGet[1,_nCol+=1] Get _oMemo VAR cC7_SCOM  MEMO SIZE 240, 23 WHEN Eval( _bXTPIMPGWhen ) Of _oNewDialog PIXEL FONT _oCourierNw 
		
	@ _nLin, 350 SAY 'Obs. p/o Fornec' PIXEL SIZE 40,10 Of _oNewDialog  
	@ _nLin, 400 Get _oObscmp VAR cC7_SFOR  MEMO SIZE 240, 23 WHEN Eval( _bXTPIMPGWhen ) Of _oNewDialog PIXEL FONT _oCourierNw
	_nLin += _nSalta
	_nLin += _nSalta
	@ _nLin, 13 SAY 'Obs. Compras' PIXEL SIZE 40,10 Of _oNewDialog  
	@ _nLin, 90 Get _oXobsCom VAR cC7_XOCOM  MEMO SIZE 540, 15 WHEN Eval( _bXTPIMPGWhen ) Of _oNewDialog PIXEL FONT _oCourierNw 
	_nLin += 10
	_nLin += 10
	@ _nLin, 13 SAY 'E-mails' PIXEL SIZE 40,10 Of _oNewDialog  
	@ _nLin, 90 Get _oXFORMAI VAR cC7_XFORMAI  MEMO SIZE 540, 15 WHEN Eval( _bXTPIMPGWhen ) Of _oNewDialog PIXEL FONT _oCourierNw 

	
End Sequence
Return .T.

/*
===========================================================================================================
Programa.:              MT120OK_PE
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              06/07/2020
Descricao / Objetivo:   Chamada pelo PE MT120OK_PE para validação dos e-mails de fornecedor informados no PC         
============================================================================================================
*/
User Function ZCF29PCVD()
Local _lRet := .T.
Local _aMsg := {}
Local _cMsg
Local _nPos
Local nI	  := 1
Local aEmails := {}

Begin Sequence

    If INCLUI .Or. ALTERA

        If Type("cC7_XFORMAI") == "C"
            If Empty(cC7_XFORMAI) 
                Aadd(_aMsg,"Email do fornecedor não informado !")
            Else			
                aEmails := StrTokArr(cC7_XFORMAI, ";")
                For nI := 1 To Len(aEmails)
                    If !IsEmail(aEmails[nI])                                                                   
                        Aadd(_aMsg,"Email do requisitante não esta correto !")
                    EndIf
                Next nI
            Endif
        Endif
    EndIf

End Sequence
//Cso ocarro erros
If Len(_aMsg) > 0    
    _lRet := .F.
    _cMsg := ""
    For _nPos := 1 To Len(_aMsg)
        _cMsg += _aMsg[_nPos] +_cEol
    Next
    Msgalert(_cMsg)
Endif
Return _lRet

/*
=========================================================================================================
Programa.:              ZCF029PCGR
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              06/07/2020
Descricao / Objetivo:   Chamada pelo PE MT120FIM para gravação dos e-mails de fornecedor informados no PC         
==========================================================================================================
*/
User Function ZCF029PCGR()
    Local aAreaSC7  := SC7->( GetArea() )
    Local cNumPC    := SC7->C7_NUM


    Begin Sequence
        SC7->( DbSetOrder(1) )
        If SC7->( DbSeek( FWxFilial("SC7") + cNumPC) )
            While SC7->( !EOF() ) .And. cNumPC == SC7->C7_NUM

                RecLock("SC7",.F.)
                If Type("cC7_XFORMAI") == "C" .and. !Empty(cC7_XFORMAI) .and. SC7->(FieldPos("C7_XFORMAI")) > 0
                    SC7->C7_XFORMAI    := UPPER(cC7_XFORMAI)
                    SC7->C7_XTPPED     := cC7_XTPREQ
                Endif
                SC7->( MsUnLock() )
                
                SC7->( DbSkip() )
            EndDo
        EndIf
    End Sequence

    RestArea(aAreaSC7)

Return Nil

/*
===========================================================================================
Programa.:              ZCF029EMAI
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              06/07/2020
Descricao / Objetivo:   Chamada pelo PE MT097APR para envio de PC por e-mail após aprovação          
===========================================================================================
*/
User Function ZCF029EMAI()
    Local aAreaSY1  := SY1->( GetArea() )
    Local aAreaSC1  := SC1->( GetArea() )
    Local aEmails   := {}
    Local aDest     := {}
    Local nI        := 1

    SY1->( DbSetOrder(1) )
    SC1->( DbSetOrder(6) )

    /* Validação necessaria para evitar o envio indevido de pedidos por e-mail,
    isso porque o PE é chamado a cada item da SC7*/
    If AllTrim( SCR->CR_NUM ) == AllTrim( SC7->C7_NUM ) .And. SC7->C7_ITEM == "0001"

        If SCR->CR_TIPO == "PC"

            If SC1->( DbSeek( FWxFilial("SC1") + SC7->C7_NUM ) )
                
                //--e-mails informados na solicitação de compras
                If !Empty( SC1->C1_XREQMAI )
                    aEmails := StrTokArr(SC1->C1_XREQMAI, ";")
                    For nI := 1 To Len(aEmails)                                                                 
                        Aadd(aDest,aEmails[nI])
                    Next nI
                EndIf

                //--e-mail do comprador
                If !Empty( SC1->C1_CODCOMP )
                    If SY1->( DbSeek( FWxFilial("SY1") + SC1->C1_CODCOMP ) )
                        AADD( aDest, SY1->Y1_EMAIL )
                    EndIf
                EndIf

                //--e-mail do usuário que gerou a solicitação
                If !Empty( SC1->C1_USER )
                    AADD( aDest, zEmailUsr(SC1->C1_USER) )
                EndIf

            EndIf
            
            //--e-mails informados no pedido de compras
            If !Empty( SC7->C7_XFORMAI )
                aEmails := StrTokArr( SC7->C7_XFORMAI, ";" )
                For nI := 1 To Len(aEmails)                                                                 
                    Aadd(aDest,aEmails[nI])
                Next nI
            EndIf

            //--Chamada da rotina de envio de pedido por e-mail
        
            If !Empty(aDest)
               IF SC7->C7_ORIGEM = "EICPO400"
                  U_ZCOMR004(,,,,,,,aDest)
               ELSE
                  U_ZCOMR001(,,,,,,,aDest)
                ENDIF
            EndIf

        EndIf
    EndIf

    RestArea(aAreaSC1)
    RestArea(aAreaSY1)

Return

/*
=======================================================================================
Programa.:              zEmailUsr
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              06/07/2020
Descricao / Objetivo:   Retorna e-mail do usuario          
=======================================================================================
*/
Static Function zEmailUsr(cUserId)
    Local cQuery		:= ""
    Local cAliasTRB		:= GetNextAlias()
    Local cEmailUser    := ""

    Default cUserId     := ""

    cQuery += " SELECT USR_EMAIL FROM SYS_USR "   + CRLF
    cQuery += " WHERE D_E_L_E_T_ = ' '  "   + CRLF
    cQuery += " AND USR_ID = '" + cUserId + "' "    + CRLF
    cQuery += " ORDER BY USR_ID "   + CRLF

    cQuery := ChangeQuery(cQuery)

    // Executa a consulta.
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

    DbSelectArea((cAliasTRB))
    (cAliasTRB)->(dbGoTop())
    If (cAliasTRB)->(!EOF())
        cEmailUser := AllTrim( (cAliasTRB)->USR_EMAIL )
    EndIf
    (cAliasTRB)->(DbCloseArea())

Return cEmailUser
