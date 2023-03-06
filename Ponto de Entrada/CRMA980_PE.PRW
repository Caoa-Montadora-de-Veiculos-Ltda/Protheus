/*/{Protheus.doc} CRMA980
Ponto de Entrada para Cadastro de cliente MVC
@author CAOA
@since 
@version 2.0
@project
@history    DAC Denilso - 24/02/2023 
            GRUPO CAOA - GAP FIN100 - Campo Matriz Clientes (Revitalização Limite de Crédito)
            Revitalição processo limite de crédito, anteriormente iniciariam o processo com um campo Matriz, após analise
            não passou a utilizar este campo utilizando o campo XTPPED para o processo
@Obs   
/*/

#include "protheus.ch"
#include "parmtype.ch"


User Function CRMA980()
   Local _cEmp    := FWCodEmp()
   Local _lRet	  := .T.
   Local _aArea	  := GetArea()

   If _cEmp == "2010" //Executa o p.e. Anapolis.
      _lRet := zMontadora()
   Else
      _lRet := zCaoaSp() //Executa o p.e. CaoaSp
   EndIf
   RestArea(_aArea)
Return(_lRet)

/*
==============================================================================================
Programa.:              zMontadora
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada Montadora
===============================================================================================
*/
Static Function zMontadora()
    Local aParam    := PARAMIXB
    Local _lRet     := .T.
    Local oObj      := ""
    Local cIdPonto  := ""
    Local cIdModel  := ""
    Local _nOpcx

    If aParam == NIL
        Return(_lRet)
    EndIf

    //If (aParam <> NIL)
    oObj        := aParam[1]
    cIdPonto    := aParam[2]
    cIdModel    := aParam[3]


    _nOpcx := oObj:GetOperation() // PEGA A OPERAÇÃO

    If (cIdPonto =="MODELCOMMITNTTS")
        _cCodCli	:= If(Type("M->A1_COD") 	== "C",M->A1_COD	,SA1->A1_COD)
        _cLoja		:= If(Type("M->A1_LOJA") 	== "C",M->A1_LOJA	,SA1->A1_LOJA)

        If _nOpcx == 3 .or. _nOpcx == 4 //.or. nOpcx == 5   //Inclusão ou Alteração ou Excluir
           //U_ZF10GENSAP("SA1",SA1->A1_COD+SA1->A1_LOJA,"A1_XCDSAP", _nOpc)
           U_ZF10GENSAP("SA1", _cCodCli+_cLoja, "A1_XCDSAP", _nOpcx)
        EndIf
        MsgRun("Atualizando Limite de Crédito Caoa","Aguarde...",{|| ZAtLCredito(_cCodCli) })
    EndIf
Return(_lRet)


/*
==============================================================================================
Programa.:              zCaoaSp
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada CaoaSp
===============================================================================================
*/
Static Function zCaoaSp()

    Local aParam    := PARAMIXB
    Local _lRet      := .T.
    Local oObj      := ""
    Local cIdPonto  := ""
    Local cIdModel  := ""
    Local _nOpcx 
    
    //Private nOpcx             //opção da manutenção do cadastro (I,A,E)

    If aParam == NIL
        Return(_lRet)
    EndIf
        
    oObj           := aParam[1]
    cIdPonto       := aParam[2]
    cIdModel       := aParam[3]
    nOpcx          := oObj:GetOperation() // PEGA A OPERAÇÃO

    /* passou a ser executado no PE CRM980BFIL
    If (cIDPonto == 'MODELVLDACTIVE')
        IF FWCodEmp() = '2020' .AND. FWFilial() = '2001'
           MsgRun("Atualizando Limite de Crédito Caoa","Aguarde...",{|| u_ZFATF017() })
        EndIf
    */
    //ElseIf  cIdPonto == 'MODELPOS'
    //ElseIf (cIdPonto =="MODELCOMMITNTTS")
    If (cIdPonto =="MODELCOMMITNTTS")
        //IF FWCodEmp() = '2020' .AND. FWFilial() = '2001'
        If _nOpcx == 3 .or. _nOpcx == 4 //.or. _nOpcx == 5 //Inclusão ou Alteração ou Excluir
			U_ZWSR006("C"    ,M->A1_COD  ,M->A1_LOJA )
            U_ZF10GENSAP("SA1", M->A1_COD+M->A1_LOJA, "A1_XCDSAP", _nOpcx)
        EndIf
        //If FWCodEmp() = '2020' .AND. FWFilial() = '2001' 
        //If nOpcx == 3 .or. nOpcx == 4
        MsgRun("Atualizando Limite de Crédito Caoa","Aguarde...",{|| ZAtLCredito(M->A1_COD) })
        //MsgRun("Atualizando Limite de Crédito Caoa","Aguarde...",{|| u_ZFATF017() })
        //EndIf
            //EndIf
		//EndIf
    EndIf
Return(_lRet)


/*/{Protheus.doc} ZAtLCredito
Função para atualiar os valiores de limite de crédito dos clientes que não utilizam limite
pesquisando pelo codigo e avaliando as lojas zerara os valores e dadas do limite de crédito
@author DAC
@since 27/02/2023
@version 2.0
@Obs   
/*/
Static Function ZAtLCredito(_cCodCli)
Local _lRet         := .T.
Local _lJob			:= IsBlind()
Local _cQuery       := ""
Local _nRegSA1      := SA1->(Recno()) //guardo o numero do registro atual para verificar status 
Local _nStatus

Default _cCodCli    := ""

If Empty(_cCodCli)
    Return _lRet
Endif
	//Limpa registro que era Matriz anteriormente diferentes dos registros que  é matriz DAC 24/02/2023
	_cQuery += "UPDATE " +RetSqlName("SA1")+ " SA1" 						+ CRLF
	_cQuery += "SET 	SA1.A1_XLC  	= 0 " 								+ CRLF
	_cQuery += " 	,	SA1.A1_XDTLC 	= '" + Space(08) + "'" 		        + CRLF
	_cQuery += " 	,	SA1.A1_XTPCRED 	= '0' " 		                    + CRLF
	_cQuery += " 	,	SA1.A1_XFPSAL 	= 0 " 		                        + CRLF
	_cQuery += " 	,	SA1.A1_XFPATR 	= 0 " 		                        + CRLF
	_cQuery += " 	,	SA1.A1_XLMUSA 	= 0 " 		                        + CRLF
	_cQuery += " 	,	SA1.A1_XSTAFP 	= '" + Space(01) + "'" 		        + CRLF
	_cQuery += " 	,	SA1.A1_XPEDFP 	= 0 " 		                        + CRLF
	_cQuery += " 	,	SA1.A1_XVALBO 	= 0 " 		                        + CRLF
	_cQuery += " 	,	SA1.A1_XBLQLC 	= '0'" 	                	        + CRLF
	_cQuery += " 	,	SA1.A1_XBLQVEN 	= '" + Space(01) + "'" 		        + CRLF
	_cQuery += "WHERE SA1.D_E_L_E_T_    = ' '" 								+ CRLF
	_cQuery += " 	AND SA1.A1_FILIAL   = '"	+ XFilial("SA1") +"'"  		+ CRLF	
	_cQuery += " 	AND SA1.A1_COD      = '"	+ _cCodCli +"'"  			+ CRLF	
    //De acordo com levantamento caso troque a loja respeonsavel pelo crédito deverá alterar a loja que estava anteriormente com crédito para não ter mais crédito
     If M->A1_XTPCRED == "0"
	    _cQuery += " 	AND SA1.A1_XTPCRED  = '0' "  			            + CRLF
    Else     	
  	    _cQuery += " 	AND SA1.R_E_C_N_O_  <> '"+ AllTrim(Str(_nRegSA1)) +"'"  	+ CRLF	
    EndIf

	Begin Transaction	
		_nStatus := TcSqlExec(_cQuery)
		if (_nStatus < 0)
			If !_lJob 
				MSGINFO("Erro ao gravar dados do limite de crédito tabela SA1 "+ TCSQLError() , "[CRMA980] - Atenção" )
			Endif
			Conout("[CRMA980] PROBLEMAS NO SELECT "+ CRLF + TCSQLError())
			_lRet := .F.
        EndIf
	End Transaction
    If _lRet		  
        u_ZFATF017(_cCodCli)
    Endif
Return _lRet

