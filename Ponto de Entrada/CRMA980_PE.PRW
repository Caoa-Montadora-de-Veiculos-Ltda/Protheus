#Include "Totvs.CH"
#include "parmtype.ch"

/*/{Protheus.doc} CRMA980
Ponto de Entrada para Cadastro de cliente MVC
@author CAOA
@since 
@version V.03 
@project
@history    DAC Denilso - 24/02/2023 
            GRUPO CAOA - GAP FIN100 - Campo Matriz Clientes (Revitalização Limite de Crédito)
            Revitalição processo limite de crédito, anteriormente iniciariam o processo com um campo Matriz, após analise
            não passou a utilizar este campo utilizando o campo XTPPED para o processo
@history    DAC Denilso - 06/04/2023	        
            GRUPO CAOA GAP FIN108 - Revitalização Credito [ Montadora ]
            Unificação Peças com Montadora
@Obs   
@tdn        https://tdn.totvs.com/pages/releaseview.action?pageId=616215550
/*/

User Function CRMA980()
	Local _aParam   := PARAMIXB
	Local _aArea    := GetArea()
	Local _lRet     := .T.
	Local _oObj     := ""
	Local _cIdPonto := ""
	Local _cIdModel := ""
	Local _nOpcx

	//Private _lZfat14 := .T.

	Begin Sequence
		If _aParam == NIL
			Return(_lRet)
		EndIf
		_oObj           := _aParam[1]
		_cIdPonto       := _aParam[2]
		_cIdModel       := _aParam[3]
		_nOpcx          := _oObj:GetOperation() // PEGA A OPERAÇÃO

		//Na validação total do formulário
		//If (_cIdPonto =="FORMPOS")
		//If (_cIdPonto =="MODELPRE")
		//Na ativação do modelo.
		If (_cIdPonto =="MODELVLDACTIVE")
			_lRet := ZCRMA980LC(_nOpcx, .F.)  //Processo antes de Atualizar
			Break
			//Após a gravação total do modelo e fora da transação.
		ElseIf (_cIdPonto =="MODELCOMMITNTTS")
			If _nOpcx == 3 .or. _nOpcx == 4 //.or. _nOpcx == 5 //Inclusão ou Alteração ou Excluir
				_lRet := ZCRMA980LC(_nOpcx)
				
				//If nOper == 5
                //	xRet := u_M030DEL()
            	//EndIf
				
				Break
			EndIf
			//quando exclusão zero a loja para atualizar todos  DAC 03/04/2023
			If _nOpcx == 5
				_cLoja := ""
			EndIf
			//Antes da gravação da tabela do formulário.
		ElseIf _cIdPonto == "FORMCOMMITTTSPRE"
			//Grava log RGLOG
			//Avalia antes de gravar se foi alterado algum campo customizado para gravar tabela de Log SZ2
			
			ZCRMA980VA(/*_cUserSol*/, /*_cRotina*/) //--- ALTERADO
			
			//ElseIf  _cIdPonto == 'MODELPOS'
		EndIf

	End Sequence
	RestArea(_aArea)
Return(_lRet)


/*/{Protheus.doc} ZCRMA980LC
Processa Limite de Crédito
@author     CAOA DAC - Denilso
@since      05/05/2023
@version    1.0
@project    FIN108- Revitalização L.C
@history    
@Obs   
@tdn        
/*/
Static Function ZCRMA980LC(_nOpcx, _lPrcLog)
	Local _lRet      := .T.
	Local _cCodCli
	Local _cLoja
	Local _cTpCred
	Local _aRet //Retorno da função ZFATF014

	Private nOpcx   := _nOpcx   //necessário pois a funcionalidade ZWSR005 espera como private  DAC 03/04/2023

	Default _lPrcLog    := .T.

	Begin Sequence
		_cCodCli	    := If(Type("M->A1_COD") 	== "C",M->A1_COD	    ,SA1->A1_COD)
		_cLoja		    := If(Type("M->A1_LOJA") 	== "C",M->A1_LOJA	    ,SA1->A1_LOJA)
		_cTpCred        := If(Type("M->A1_XTPCRED")	== "C",M->A1_XTPCRED	,SA1->A1_XTPCRED)
		//Indica se processa Log's, caso não somente processar o calculo do L.C. DAC 10/05/2023
		If _lPrcLog
			//OneGate001 - nova empresa 90 | HMB
			//Executa para 02 | Franco da Rocha e 90 | HMB
        	If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
        		//Serviço de integração  para integração clientes, fornecedores e transportadoras com execauto RGLOG
				U_ZWSR006("C", _cCodCli , _cLoja )
				//ElseIf FWCodEmp() = '2010'
			EndIf
			
			//OneGate001 - nova empresa 90 | HMB
			If ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Franco da Rocha | Caoa
            	U_ZF10GENSAP("SA1", _cCodCli+_cLoja, "A1_XCDSAP", _nOpcx)    //Lê tabela SZ7 para envio SAP
        	EndIf
			//U_ZF10GENSAP("SA1", _cCodCli+_cLoja, "A1_XCDSAP", _nOpcx)    //Lê tabela SZ7 para envio SAP
		Endif
		FwMsgRun(,{ || _aRet := U_ZFATF014(_cCodCli, _cTpCred, _cLoja, .T.) }, 'Limite Crédito','Atualizando Limite de Crédito Caoa, aguarde...')
	End Sequence

	If ValType(_aRet) <> "A" .or. _aRet == Nil
		_lRet := .F.
	EndIF

Return(_lRet)


/*/{Protheus.doc} ZCRMA980LC
Grava LOG para Limite de Credito ZA2
@author     CAOA DAC - Denilso
@since      05/05/2023
@version    1.0
@project    FIN108- Revitalização L.C
@history    
@Obs   
@tdn        
/*/
Static Function ZCRMA980VA(_cUserSol, _cRotina)
	Local _cAliasPesq  	:= GetNextAlias()
	Local _lRet         := .T.
	Local _cCampo
	Local _cTitulo
	Local _xValor
	Local _xValorNovo

	Default _cUserSol := RetCodUsr()
	Default _cRotina  := "CAD. CLIENTES"

	Begin Sequence
		BeginSql Alias _cAliasPesq
		SELECT  SX3.X3_CAMPO  AS CAMPO 
			   ,SX3.X3_TITULO AS TITULO 
		FROM %Table:SX3% SX3
		WHERE SX3.%NotDel%
			AND SX3.X3_ARQUIVO = 'SA1'
            AND (SX3.X3_PROPRI IN ('U') OR SUBSTR(SX3.X3_CAMPO,1,4) = 'A1_X')
		EndSql
    /*
			AND SX3.X3_FOLDER = (	SELECT SXA.XA_ORDEM 
								    FROM SXA010 SXA
								    WHERE
										SXA.%NotDel%
									    AND SXA.XA_ALIAS = %Exp:_cTable%
									    AND SXA.XA_PROPRI = 'U' 
                                        AND SXA.XA_DESCRIC LIKE 'Cr%')
    */
		If (_cAliasPesq)->(Eof())
			Break
		Endif
		(_cAliasPesq)->(DbGoTop())
		While (_cAliasPesq)->(!EOF())
			_xValor	:= SA1->(FieldGet(FieldPos((_cAliasPesq)->CAMPO)))
			If _xValor <> Nil
				_cCampo	    := AllTrim( (_cAliasPesq)->CAMPO )
				_xValorNovo := M->(&_cCampo)
				_cTitulo    := Upper(AllTrim( (_cAliasPesq)->TITULO ))
				If  _xValorNovo <> _xValor
					U_ZGENLZA2( _xValor, _xValorNovo, _cCampo, _cTitulo, "CAD. CLIENTES",/*_cUserSol*/)  //ZEMLOG.PRW
				Endif
			EndIf
			(_cAliasPesq)->(DbSkip())
		EndDo
	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif
Return _lRet


