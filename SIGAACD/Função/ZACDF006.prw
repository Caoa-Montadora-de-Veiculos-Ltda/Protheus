#include "topconn.ch"
#include "protheus.ch"
#include "apvt100.ch"

#DEFINE  KEY_ESC     27
#DEFINE  NROWS       12
#DEFINE  NCOLS       24

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZACDF006
Rdmake 	Gravar a movimentação de Controle de Veiculos atualmente utilizado na Fabrica X Gabardo
@class    	Nao Informado
@from       Nao Informado
@param      
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC Denilso 
@single		18/09/2020
@version    Nao Informado
@since      Nao Informado  
@return    	Logico
@sample     Nao Informado
@obs        Para a liberação manual utilizar o menu
			SIGAVEI >> Miscelania >> Específicos CAOA >> Entrada de Veículos   --> Visualização do log
@project    ACD104 - Movimentação Veiculos Gabardo
@menu       SIGAACD >> Atualizacoes >> Específicos CAOA >> Transf Gabardo 
			 
@history    
--------------------------------------------------------------------------------------*/
User Function ZACDF006( )   // vtdebug
Local _cVin			:= ""
Local _lZACDF006    := SuperGetMV( "CMV_ACD004"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade
Local _nTamVin		:= 17
Begin Sequence
    If !_lZACDF006
        Break
    Endif

	VtSetSize(NROWS , NCOLS)
	While  .T.
	 	_cVin		:= Space(TamSx3("VV1_CHASSI")[1])
		VtClear()
		@ 0,00 VTSAY "-Entrada Veículo ACD CAOA"
		@ 1,00 VTSAY ""
		@ 2,00 VTSAY "V.I.N:"
		@ 3,00 VTSAY "" VTGet _cVin Pict PesqPict("VV1", "VV1_CHASSI") Valid !Empty(_cVin) 
		VTRead()
		If VtLastKey() = KEY_ESC
			Break
		EndIf

		If Len(AllTrim(_cVin)) < _nTamVin
			VTAlert("TAMANHO CODIGO V.I.N. ERRADO !" , "", .T., 3500)
			Loop
		EndIf

		//Verificar o status da montagem do unitizador
		If !ZACDF006GR(_cVin)
			Loop
		EndIf
		//chama job e não espera o retorno
		//StartJob("U_ZACDJ005", GetEnvServer(), .F.)
		U_ZACDJ005()
		VTBeep()
		VtClear()
		VTAlert("REGISTRADO COM SUCESSO" , "", .T., 3500)
	EndDo
End Sequence
VtClear()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ZACDF006GR
Gravar dados para o processamento    
@author DAC denilso.carvalho
@since 18/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ZACDF006GR(_cVin)
Local _cAliasTab    := GetNextAlias()
Local _lRet 		:= .T.
Local _lBloqueado 	:= .F.
Local _cBloqueio    := Space(01)
Local _cObs

Begin Sequence
	_cVin := AllTrim(_cVin)
	//Verifica se o chassi ja esta cadatrado
	SZW->(DbSetOrder(1))  //ZW_FILIAL+ZW_CHASSI+ZW_CODPROD
	//Verifica se o veiculo possui status diferente de liberado caso sim não pode passar
	If  !ZACDF006LV(_cVin) 
		_lRet := .F.
		Break
	Endif                                                                                                                
	//Localizar o veiculo
	VV1->(DbSetOrder(2))  //FILIAL+CHASSI
    BeginSql Alias _cAliasTab	
    	SELECT  ISNULL(MAX(VV1.R_E_C_N_O_),0) NREGVV1,
				ISNULL(MAX(VV2.R_E_C_N_O_),0) NREGVV2,
				ISNULL(MAX(SB1.R_E_C_N_O_),0) NREGSB1,
				ISNULL(MAX(VB0.R_E_C_N_O_),0) NREGVB0
	    FROM %Table:VV1%  VV1 
		LEFT JOIN %Table:VV2%  VV2 ON 
				VV2.VV2_FILIAL 	= %xFilial:VV2% 
		    AND VV2.VV2_CODMAR 	= VV1.VV1_CODMAR
		    AND VV2.VV2_MODVEI 	= VV1.VV1_MODVEI
		    AND VV2.VV2_SEGMOD 	= VV1.VV1_SEGMOD
		    AND VV2.%notDel% 
		LEFT JOIN %Table:SB1%  SB1 ON 
				SB1.B1_FILIAL 	= %xFilial:SB1% 
		    AND SB1.B1_COD 		= VV2.VV2_PRODUT
		    AND SB1.%notDel% 
        LEFT JOIN  %Table:VB0% VB0  
                ON  VB0.VB0_FILIAL = %xFilial:VB0%
                AND VB0.VB0_CHAINT =  VV1.VV1_CHAINT
                AND VB0.VB0_DATDES = ' '
                AND VB0.%notDel%  
	    WHERE VV1.VV1_FILIAL	= %xFilial:VV1% 
			AND	VV1.VV1_CHASSI 	= %Exp:_cVin%
			AND VV1.%notDel%
    EndSQL

    //SE NÃO LOCALIZOU NADA EFETUA GRAVAÇÃO DIRETO
	//Somente Verfica bloqueo se o veículo estiver cadastrado
	If (_cAliasTab)->NREGVV1 > 0
		If (_cAliasTab)->NREGVB0 > 0 
			_lBloqueado := .T.
		EndIf
		@ 4,00 VTSAY ""
		@ 5,00 VTSAY If(_lBloqueado,"LIBERA","BLOQUEIA")+" VEICULO?"
		@ 6,00 VTSAY "1=(SIM) 2=(NAO) :  " VTGet _cBloqueio Pict "@!" Valid !Empty(_cBloqueio) .and. _cBloqueio $ "1_2" 
		VTRead()
		If VtLastKey() = KEY_ESC
			_cObs	:= "NAO INFORMADO BLOQUEIO OU LIBERAÇÃO DO VEICULO TENTAR NOVAMENTE"
			VTBeep()
			VtClear()
			VTAlert(_cObs , "", .T., 3500)
			_lRet := .F.
			Break
		EndIf
	//Caso não localize veiculo deixar bloqueio como desbloqueado DAC 18/11/2020
	Else
		_cBloqueio := "2"   //Deixar como desbloqueado
	EndIf	
	RecLock("SZW",.T.)
	SZW->ZW_FILIAL	:= XFilial("SZW") 
	SZW->ZW_CHASSI  := _cVin
	SZW->ZW_CODUSU  := RetCodUsr()
	SZW->ZW_DATALEI := Date() 
	SZW->ZW_HORALEI	:= Time() 
	SZW->ZW_STATUS  := "P"	
	//VERIFICA SE EXISTE RELACIONAMENTO
    If (_cAliasTab)->(!EOF()) 
		//Para indicação do código do Produto deve veriricar o veiculo
		If (_cAliasTab)->NREGVV2 > 0 
			VV2->(DbGoto((_cAliasTab)->NREGVV2))
			SZW->ZW_CODPROD := VV2->VV2_PRODUT
		EndIf
		//Estou gravando a descrição de acordo com informação que tem que gravar pois pode mudar caso contrario estaria como campo virtual
		If (_cAliasTab)->NREGSB1 > 0   
			SB1->(DbGoto((_cAliasTab)->NREGSB1))
			SZW->ZW_DESCPRD	:= SB1->B1_DESC
		EndIf
	EndIf
	//Caso possua veicuo verifica bloqueio e grava para boquear desbloquear
	//tem que ser feita validação para gravar corretamente
	SZW->ZW_BLOQUEI := If(_cBloqueio=="1","B","D")  //gravo o bloqueio inicialmente caso ainda não exista o Veiculo para que o mesmo tenha um status de bloqueio ou não
	If (_cAliasTab)->NREGVV1 > 0 .and. !Empty(_cBloqueio)
		If SZW->( FieldPos("ZW_BLOQUEI") ) > 0
			If _lBloqueado .and. _cBloqueio == "1"  //"S"
				_cBloqueio := "D"
			ElseIf _lBloqueado .and. _cBloqueio == "2"  //"N"
				_cBloqueio := "B"
			ElseIf !_lBloqueado .and. _cBloqueio == "1"  //"S"
				_cBloqueio := "B"
			ElseIf !_lBloqueado .and. _cBloqueio == "2"  //"N"
				_cBloqueio := "D"
			//retirado para que não grave em branco DAC 18/11/2020
			//Else
			//	_cBloqueio := ""
			EndIf	
			SZW->ZW_BLOQUEI := _cBloqueio
		EndIf	
	EndIf
	SZW->(MsUnlock())
End Sequence
If Select(_cAliasTab) <> 0
	(_cAliasTab)->(DbCloseArea())
	Ferase(_cAliasTab+GetDBExtension())
Endif  
Return _lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ZACDF006LV
Verificar se o veiculo possui status diferente de Liberado pela VIN (Chassi)    
@author DAC denilso.carvalho
@since 02/10/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ZACDF006LV(_cVin)
Local _cAliasPesq    := GetNextAlias()
Local _lRet 		:= .T.
Local _cLiberado	:= "L"
Local _cObs
Begin Sequence
	_cVin := AllTrim(_cVin)
	//Verifica se o chassi ja esta cadatrado
	SZW->(DbSetOrder(1))  //ZW_FILIAL+ZW_CHASSI+ZW_CODPROD
    BeginSql Alias _cAliasPesq	
    	SELECT  SZW.R_E_C_N_O_ NREGSZW
	    FROM %Table:SZW%  SZW 
	    WHERE SZW.ZW_FILIAL	= %xFilial:SZW% 
			AND	SZW.ZW_CHASSI 	= %Exp:_cVin%
			AND	SZW.ZW_STATUS <> %Exp:_cLiberado%
			AND SZW.%notDel%
    EndSQL
    //SE NÃO LOCALIZOU PODE AUTORIZAR
	//Somente Verfica bloqueo se o veículo estiver cadastrado
	If (_cAliasPesq)->(!Eof())
		_cObs	:= "VEICULO NÃO POSSUI LIBERACAO, O MESMO ESTA PENDENTE VERIFICAR!"
		VTBeep()
		VtClear()
		VTAlert(_cObs , "", .T., 3500)
		_lRet := .F.
		Break
	EndIf
End Sequence
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _lRet
