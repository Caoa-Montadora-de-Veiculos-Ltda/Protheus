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


/*---------------------------------------------------------------------------------------
{Protheus.doc} ZCOMF003 
Rdmake 	responsavel pela inclusão/visualização/gravação de historicos da Solicitação de Compras
@class    	Nao Informado
@from       Nao Informado
@param      _aParam - Com informações paramb do MT110TEL
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC Denilso 
@version    Nao Informado
@since      20/08/2020  
@return    	Logico
@sample     Nao Informado
@obs        Chamado pelo Ponto de Entrada MT110TEL
@project    CAOA
@menu       Nao Informado
@history    
--------------------------------------------------------------------------------------*/

User Function ZCOMF003(_aParam)

Local _lJob         := GetRemoteType() == -1 // Verifica se é job
Local _lZCONF003    := SuperGetMV( "CMV_COM001"  ,,.T.)
Local _lRet         := .T.
Private _nTamPar    := 0
Default _lPedido    := .F.
Default _aParam		:= {}

    //Se for Job não chamar tela pois não existira os dados que são obrigatorios  para informações
    //_lZCONF003 parametro para ativar a utilização da funcionalidade deve ser cadastrado no configurador este parametro para ativar
    //DAC 18/02/2010

    If _lJob .or. !_lZCONF003  
        Return _lRet
    Endif     
    //Caso seja chamada do EIC não continuar
    If IsInCallStack("EICPO400")  .or. IsInCallStack("EICSI400") //C7_ORIGEM == EICPO400 SIGAEIC
        Return _lRet
    Endif
    ZCF003SCMN(_aParam)

Return _lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ZCF003SCGR
Reestruturação montar tela de Histórico da Solicitação de Compras e chamada do PE MT110TEL
@author DAC denilso.carvalho
@since 		20/08/2020
@param     	_aParam - Com informações paramb do MT110TEL
@return    	Logico
@project    CAOA
@menu       Nao Informado
@version 	1.0
@obs        Chamado pelo Ponto de Entrada MT110TEL
@history    
/*/
//-------------------------------------------------------------------
Static Function ZCF003SCMN(_aParam)

Local _oCourierNw	:= TFont():New("Courier New",,,,.F.,,,,.F.,.F.)
Local _oNewDialog   
Local _aPosGet      
Local _nOpcx        
Local _nReg        
Local _nSalta 		
Local _nCont  		
Local _nCol  		
Local _nLin
Local _nPos
Local _oTpReq
Local _oMemo
Local _bXTPIMPGWhen 

	If _aParam == Nil 
		Return .T.
	Endif

    If LEN(_aParam) < 4
		Return .T.
	Endif

 	_oNewDialog   := _aParam[1]
	_aPosGet      := _aParam[2]
	_nOpcx        := _aParam[3]
	_nReg         := _aParam[4]
	_bXTPIMPGWhen := { || _nOpcx == 3 .Or. _nOpcx == 4 }   //_nOpcx == 2 .Or.

	// ** CAOA - COM - VARIAVEIS PARA DADOS COMPLEMENTARES - ROTINA ZCOMF003 - GAP COM007/001
	// **  VAIAVEIS PUBLICAS DEFINIDAS NO PROGRAMA ZCOMF003

	Public cC1_XTPIMP  	:= Space(06)
	Public cC1_NR_PRO  	:= Space(30)
	Public cC1_MOEDA  	:= Space(Len(SYF->YF_MOEDA))
	Public cC1_XTPREQ	:= Space(04)
	Public cC1_XREQUIS 	:= if( INCLUI,USRFULLNAME(),Space(30))
	Public cC1_XREQFON 	:= Space(15)
	Public cC1_XREQMAI 	:= if( INCLUI,UsrRetMail(RetCodUsr()),Space(50))
	Public cC1_XOBREQ 	:= Space(10)
	Public cC1_XOBITE   := Space(10)

	//PARA EVITAR ERROS NA TELA NECESSARIO
	If !INCLUI  //CASO NÃO SEJA INCLUSAO
  	  	If SC1->(FieldPos("C1_XTPIMP")) > 0
    	    cC1_XTPIMP  := SC1->C1_XTPIMP  
    	Endif
    	If SC1->(FieldPos("C1_NR_PRO")) > 0
        	cC1_NR_PRO  := SC1->C1_NR_PRO  
    	Endif
 	   	If SC1->(FieldPos("C1_MOEDA")) > 0
  	    	cC1_MOEDA  := SC1->C1_MOEDA  
 	   	Endif
 	   	If SC1->(FieldPos("C1_XTPREQ")) > 0
  	    	cC1_XTPREQ  := SC1->C1_XTPREQ  
 	   	Endif
		If SC1->(FieldPos("C1_XREQUIS")) > 0
   	    	cC1_XREQUIS := SC1->C1_XREQUIS 
 	   	Endif
   		If SC1->(FieldPos("C1_XREQFON")) > 0
     	   cC1_XREQFON := SC1->C1_XREQFON  
		EndIf
    	If SC1->(FieldPos("C1_XREQMAI")) > 0
        	cC1_XREQMAI := SC1->C1_XREQMAI  
		EndIf
    	If SC1->(FieldPos("C1_XOBSREQ")) > 0
        	cC1_XOBREQ := SC1->C1_XOBSREQ  
		Endif
    	If SC1->(FieldPos("C1_XOBSITE")) > 0
        	cC1_XOBITE := SC1->C1_XOBSITE  
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
	@ _nLin, _aPosGet[1,_nCol] 	  SAY 'Tp Import' PIXEL SIZE 30,10 Of _oNewDialog
	@ _nLin, _aPosGet[1,_nCol+=1] MSGET cC1_XTPIMP  PICTURE "@!" PIXEL SIZE 30,10 Valid (Vazio() .or. ExistCpo("ZZ8")) F3 "ZZ8" WHEN Eval( _bXTPIMPGWhen ) Of _oNewDialog

	@ _nLin, _aPosGet[1,_nCol+=1] SAY 'Proforma' PIXEL SIZE 30,10 Of _oNewDialog
	@ _nLin, _aPosGet[1,_nCol+=1] MSGET cC1_NR_PRO PICTURE "@!" PIXEL SIZE 30,10  WHEN Eval( _bXTPIMPGWhen ) Of _oNewDialog

	@ _nLin, _aPosGet[1,_nCol+=1] SAY 'Moeda' PIXEL SIZE 30,10 Of _oNewDialog
	@ _nLin, _aPosGet[1,_nCol+=1] MSGET cC1_MOEDA PICTURE "@!" PIXEL SIZE 30,10 F3 "ZSYF"  WHEN Eval( _bXTPIMPGWhen ) Of _oNewDialog

	_nLin += _nSalta
	SX3->(DbSetOrder(2))
	SX3->(DbSeek("C1_XTPREQ"))
	_aTpReq := StrTokArr(AllTrim(SX3->X3_CBOX),";")

	If _nOpcx == 3  //SE FOR INCLUSÃO
		cC1_XTPREQ 	:= SubsTr(_aTpReq [1],1,at("=",_aTpReq [1])-1) 
	EndIf
	@ _nLin, _aPosGet[1,_nCol+=1] SAY 'Tp Req' PIXEL SIZE 50,10 Of _oNewDialog
	@ _nLin, _aPosGet[1,_nCol+=1] MSCOMBOBOX _oTpReq VAR cC1_XTPREQ ITEMS _aTpReq Valid !Empty(cC1_XTPREQ) PIXEL SIZE 70, 013 Of _oNewDialog COLORS 0, 16777215 PIXEL

	@ _nLin, _aPosGet[1,_nCol+=1] SAY 'Requisitante' PIXEL SIZE 30,10 Of _oNewDialog
	@ _nLin, _aPosGet[1,_nCol+=1] MSGET cC1_XREQUIS PICTURE "@!" Valid !Empty(cC1_XREQUIS) PIXEL SIZE 120,10   WHEN Eval( _bXTPIMPGWhen ) Of _oNewDialog

	@ _nLin, _aPosGet[1,_nCol+=1] SAY 'Tel. Requis.' PIXEL SIZE 30,10 Of _oNewDialog
	@ _nLin, _aPosGet[1,_nCol+=1] MSGET cC1_XREQFON PICTURE "@R (99) 9999-99999" Valid !Empty(cC1_XREQFON) .and. Len(AllTrim(cC1_XREQFON)) >= 10 PIXEL SIZE 50,10  WHEN Eval( _bXTPIMPGWhen ) Of _oNewDialog

	_nLin += _nSalta
	@ _nLin, _aPosGet[1,_nCol+=1] SAY 'E-Mail' PIXEL SIZE 30,10 Of _oNewDialog
	@ _nLin, _aPosGet[1,_nCol+=1] MSGET cC1_XREQMAI   Valid !Empty(cC1_XREQMAI) /*.and. IsEmail(cC1_XREQMAI)*/ PIXEL SIZE 540,10 WHEN Eval( _bXTPIMPGWhen ) Of _oNewDialog

	_nLin += _nSalta
	@ _nLin, _aPosGet[1,_nCol+=1] SAY 'Obs. Geral S.C.' PIXEL SIZE 40,10 Of _oNewDialog
	@ _nLin, _aPosGet[1,_nCol+=1] Get _oMemo VAR cC1_XOBREQ  MEMO SIZE 540, 23 Valid !Empty(cC1_XOBREQ) .and. Len(AllTrim(cC1_XOBREQ)) >= 06 WHEN Eval( _bXTPIMPGWhen ) Of _oNewDialog PIXEL FONT _oCourierNw 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ZCF003SCVD
Validação das informações do historico da Solicitação de Compras
@author DAC denilso.carvalho
@since 		20/08/2020
@param     	Nao Informado
@return    	Logico
@project    CAOA
@menu       Nao Informado
@version 	1.0
@obs        Chamado pelo Ponto de Entrada MT110TOK
@history    
/*/
//-------------------------------------------------------------------

User Function ZCF003SCVD()

Local _lRet := .T.
Local _aMsg := {}
Local _cMsg
Local _nPos
Local nI	  := 1
Local aEmails := {}

If !IsBlind()
		If Type("cC1_XTPREQ") == "C" .and. Empty(cC1_XTPREQ)
			Aadd(_aMsg,"Tipo de requisicao não informada !")
		Endif

		If Type("cC1_XREQUIS") == "C" .and. Empty(cC1_XREQUIS)
			Aadd(_aMsg,"Nome do requisitante não informado !")
		Endif

		If Type("cC1_XREQFON") == "C" 
			If Empty(cC1_XREQFON)
				Aadd(_aMsg,"Telefone do requisitante não informado !")
			Else
				If Len(AllTrim(cC1_XREQFON)) < 10                                                            
					Aadd(_aMsg,"Telefone do requisitante não esta correto, verificar informações como o DDD !")
				Endif
			EndIf
		Endif

		If Type("cC1_XREQMAI") == "C" 
			If Empty(cC1_XREQMAI)
				Aadd(_aMsg,"Email do requisitante não informado !")
			Else
				aEmails := StrTokArr(cC1_XREQMAI, ";")
				For nI := 1 To Len(aEmails)
					If !IsEmail(aEmails[nI])                                                                   
						Aadd(_aMsg,"Email do requisitante não esta correto !")
					EndIf
				Next nI
			Endif
		Endif
EndIf

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

//-------------------------------------------------------------------
/*/{Protheus.doc} ZCF003SCGR
Gravar dados de campos customizados da Solicitação de Compras
@author DAC denilso.carvalho
@since 		20/08/2020
@param     	_lCopia - Indica se é uma copia
@return    	Logico
@project    CAOA
@menu       Nao Informado
@version 	1.0
@obs        Chamado pelo Ponto de Entrada MT110GRV
@history    
/*/
//-------------------------------------------------------------------
User Function ZCF3SCGR(_lCopia)

Default _lCopia := .F.
	If IsBlind() .or. _lCopia //interface com o usuário
		Return Nil
	Endif

	RecLock("SC1",.F.)
	If Type("cC1_XTPIMP") == "C" 	.and. !Empty(cC1_XTPIMP) 	.and. SC1->(FieldPos("C1_XTPIMP")) > 0
		SC1->C1_XTPIMP := UPPER(cC1_XTPIMP)
	Endif

	If Type("cC1_NR_PRO") == "C" 	.and. !Empty(cC1_NR_PRO) 	.and. SC1->(FieldPos("C1_NR_PRO")) > 0
		SC1->C1_NR_PRO := UPPER(cC1_NR_PRO)
	Endif

	If Type("cC1_MOEDA") == "C"  	.and. !Empty(cC1_MOEDA) 	.and. SC1->(FieldPos("C1_MOEDA")) > 0
        IF UPPER(cC1_MOEDA) = '001' .OR. ALLTRIM(UPPER(cC1_MOEDA)) = "01"  .OR. ALLTRIM(UPPER(cC1_MOEDA)) = "1"     //era SC1->C1_MOEDA := UPPER(cC1_MOEDA)
            SC1->C1_MOEDA := 1
        ELSEIF UPPER(cC1_MOEDA) = '002' .OR. ALLTRIM(UPPER(cC1_MOEDA)) ="02" .OR. ALLTRIM(UPPER(cC1_MOEDA)) ="2"
            SC1->C1_MOEDA := 2
        ENDIF
	Endif

    If Type("cC1_XTPREQ") == "C" 	.and. !Empty(cC1_XTPREQ) 	.and. SC1->(FieldPos("C1_XTPREQ")) > 0
        SC1->C1_XTPREQ := UPPER(cC1_XTPREQ)
    Endif
    
	If Type("cC1_XREQUIS") == "C" 	.and. !Empty(cC1_XREQUIS) 	.and. SC1->(FieldPos("C1_XREQUIS")) > 0
        SC1->C1_XREQUIS := UPPER(cC1_XREQUIS)
    Endif
    
	If Type("cC1_XREQFON") == "C" 	.and. !Empty(cC1_XREQFON) 	.and. SC1->(FieldPos("C1_XREQFON")) > 0
        SC1->C1_XREQFON := UPPER(cC1_XREQFON)
	EndIf
    
	If Type("cC1_XREQMAI") == "C" 	.and. !Empty(cC1_XREQMAI) 	.and. SC1->(FieldPos("C1_XREQMAI")) > 0
        SC1->C1_XREQMAI := UPPER(cC1_XREQMAI)
	EndIf
    
	If Type("cC1_XOBREQ") == "C" 	.and. !Empty(cC1_XOBREQ) 	.and. SC1->(FieldPos("C1_XOBSREQ")) > 0
        SC1->C1_XOBSREQ := Upper(cC1_XOBREQ)
	EndIf

    If Type("cC1_XOBITE") == "C" 	.and. !Empty(cC1_XOBITE) 	.and. SC1->(FieldPos("C1_XOBSITE")) > 0
        SC1->C1_XOBSITE := Upper(cC1_XOBITE)
	EndIf
	SC1->(MsUnLock())

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ZCF003PCSC
Gravar dados da Solicitação de Compras o Pedido de Compras
@author DAC denilso.carvalho
@since 		20/08/2020
@param     	_lCopia - Indica se é uma copia
@return    	Logico
@project    CAOA
@menu       Nao Informado
@version 	1.0
@obs        Chamado pelo Ponto de Entrada MT120FIM
@history    
/*/
//-------------------------------------------------------------------
//DAC 04/09/2020
//Avaliar se retira este campo e C7_XOBSCOT (o mesmo também ja possui nome errado de cotação não de SV)
//esta funcionalidade se o acesso deverá ser direto na Socilitação de Compras
Static Function ZCF003PCSC()

Local _cNumSC 	:= SC7->C7_NUMSC
Local _cObs   	:= ""
Local _lRet 	:= .T.

	If IsBlind() .or. Empty(_cNumSC) //interface com o usuário
		Return _lRet
	Endif

    BeginSql Alias _cAliasTab	
   	    SELECT SC1.C1_XOBSREQ
	    FROM %Table:SC1%  SC1 
	    WHERE 	SC1.C1_FILIAL 	= %xFilial:SC1% 
		    AND SC1.C1_NUM 		= %Exp:_cNumSC%
		    AND SC1.C1_XOBSREQ <> ' '
		    AND SC1.%notDel%
		GROUP BY SC1.C1_XOBSREQ	 
    EndSQL
    If (_cAliasTab)->(EOF()) ; Return _lRet ; 	Endif

	While (_cAliasTab)->(!EOF())
		_cObs += (AllTrim((_cAliasTab)->C1_XOBSREQ) +" ")
		(_cAliasTab)->(DbSkip())
	Enddo

	If Empty(_cObs)	
		Return _lRet
	Endif

	RecLock("SC7",.F.)
	SC7->C7_XOBSCOT := _cObs
	SC7->(MsUnlock())

Return _lRet

/*
=====================================================================================
Programa.:              FVALTPO		
Autor....:              CAOA - Sandro Ferreira 
Data.....:              16/05/2022
Descricao / Objetivo:   Funcao para validação dos tipos de documentos
Doc. Origem:           
Solicitante:            Julia
Uso......:              CAOA Montadora.
Obs......:              Função para validar os campos digitados
=====================================================================================
*/
User FUNCTION FVALTPO( cP_ACAO, xVar, xVar2 )
	Local lRet
	Local cQuery := ""
	Local aSetField   := {}
	lRet    := .T.
	cP_ACAO := IF(cP_ACAO==NIL,"",UPPER(cP_ACAO))
	IF cP_ACAO == "SC"
	    ZA4->( dbSetOrder(3) )
		If !( ZA4->( dbSeek( FWxFilial("ZA4") + "SC" + xVar    )    )   )
			MSGINFO("Não existe Amarração para esse Tipo de Documento X Solicitação de Compras !","Atenção!")
			lRet := .F.
		Endif
	ELSEIF cP_ACAO == "CP"
		ZA4->( dbSetOrder(3) )
        IF !FWIsInCallStack("MATA110")
		    cQuery := "SELECT C1_FILIAL, C1_NUM , C1_XTPREQ"
			cQuery += " FROM " + RetSQLName("SC1")
			cQuery += " WHERE  D_E_L_E_T_ <> '*' AND C1_XNUMCTP ='" + SC3->C3_NUM + "'"
			cQuery += " AND C1_FILIAL = '" + xFILIAL("SC3") +"'"
			cQuery += " GROUP BY C1_FILIAL, C1_NUM , C1_XTPREQ "

			cQuery := ChangeQuery( cQuery )

			MPSysOpenQuery( cQuery, "TRB", aSetField )
			If  TRB->( Eof() )
				If !( ZA4->( dbSeek( FWxFilial("ZA4") + "CP" + xVar    )    )   )
					MSGINFO("Não existe Amarração para esse Tipo de Documento X Contrato de Parceira !","Atenção!")
					lRet := .F.
				Endif
			ELSE
			   	If !( ZA4->( dbSeek( FWxFilial("ZA4") + "SC" + TRB->C1_XTPREQ + "CP" + xVar    )    )   )
					MSGINFO("Não existe Amarração para esse Tipo de Documento X Contrato de Parceira !","Atenção!")
					lRet := .F.
				Endif
			ENDIF
			TRB->( DbCloseArea() )
		ELSE
			If !( ZA4->( dbSeek( FWxFilial("ZA4") + "SC" + xVar2  + "CP" + xVar   )    )   )
				MSGINFO("Não existe Amarração para essa Solicitação de Compras X Pedido de Compras!","Atenção!")
				lRet := .F.
			Endif
		ENDIF
	ELSEIF cP_ACAO == "PC"
		ZA4->( dbSetOrder(3) )
		IF EMPTY(cC7_XTPRE2) 
			If !( ZA4->( dbSeek( FWxFilial("ZA4") + "PC" + xVar    )    )   )
				MSGINFO("Não existe Amarração para esse Tipo de Documento X Pedido de Compras!","Atenção!")
				lRet := .F.
			Endif
		else
			If !( ZA4->( dbSeek( FWxFilial("ZA4") + "SC" + cC7_XTPRE2  + "PC" + xVar   )    )   )
				MSGINFO("Não existe Amarração para essa Solicitação de Compras X Pedido de Compras!","Atenção!")
				lRet := .F.
			Endif
		Endif
	ELSEIF cP_ACAO == "AE"
		ZA4->( dbSetOrder(3) )
		If !( ZA4->( dbSeek( FWxFilial("ZA4") + "AE" + xVar    )    )   )
			MSGINFO("Não existe Amarração para esse Tipo de Documento X Autorização de Entrega!","Atenção!")
			lRet := .F.
		Endif
	ENDIF
RETURN(lRet)
