#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#define CRLF chr(13) + chr(10)

Static _aMsgRet := {}				//carregar msg de errp

/*/{Protheus.doc} ZWSR007
Interface de Pedido a Separar Envio
@author     DAC
@since      07/12/2021
@version    V.03 
@param    
@type       class
@return   	lRet			, caracter, JSON com tabelas.
@client   	CAOA BARUERI
@project 	RGLOG-Senior API-WIS_Integração_Webservices RGLOG vs 40 REV004_ (002)
			   Interface de Pedido a Separar - INT_E_CAB_PEDIDO_SAIDA / INT_E_DET_PEDIDO_SAIDA
			   http://ipservidor:porta/interfacewis/entrada/pedido
Z  -Customizado
WS - Modulo
R  - resT OU W WebServer
011- Sequencial
/*/


User Function ZWSR007(_cAglutina, _cPicking, _lDataEnv, _cEmpresa, _cFilial, _aMens)
	Local _oSay			:= Nil
	Local _lRet			:= .T.	
	Local _lJob			:= IsBlind()
	Local _nRegVS1		

	Default _cAglutina 	:= ""   
	Default _cPicking  	:= ""
	Default _lDataEnv	:= .F.
	Default _cEmpresa  	:= "02"
	Default _cFilial   	:= "2020012001"

	Private oJsRet		:= Nil
	Begin Sequence
		//se não For pro JOB	
		If _lJob 
			//Tratar abertura da empresa conforme enviado no parametro
			Conout("ZWSR007 - Iniciando JOB")
			If Type("cEmpAnt") <> "C" .or. cEmpAnt <> _cEmpresa .or. cFilAnt <> _cFilial
				Conout("ZWSR007 - Abrindo empresa "+_cEmpresa+" Filial "+_cFilial)
				RpcClearEnv() 
				RPCSetType(3) 
				RpcSetEnv(_cEmpresa,_cFilial,,,,GetEnvServer(),{ })
			EndIf
			_lRet := ZWSR007PRC(_cAglutina, _cPicking, _lDataEnv , _oSay, _lJob)
		Else
			_nRegVS1	:= VS1->(Recno())
			FwMsgRun(, {|_oSay| _lRet := ZWSR007PRC(_cAglutina, _cPicking, _lDataEnv , _oSay)}, "Envio de separação", "Por favor aguarde...")
			VS1->(DbGoto(_nRegVS1))
		EndIf
		//uma forma de retornar msg caso seja chamado por uma outra funcionalidade DAC 13/07/2022
		If Valtype(_aMens) == "A"
			_aMens := _aMsgRet
		Endif
	End Sequence
	If _lJob
		Conout("ZWSR007 - Finalizando JOB")
	endif
Return _lRet


//Processar aglutinação para envio de picking
Static Function ZWSR007PRC(_cAglutina, _cPicking, _lDataEnv, _oSay, _lJob)

	Local _cAlias 		:= GetNextAlias()
	Local _cUsuario		:= SuperGetMV( "CMV_WSR009"  ,,"caoa.totvs" )  //Alltrim(Getmv("CMV_WSR009"))  
	Local _cSenha	 	:= SuperGetMV( "CMV_WSR010"  ,,"CAgka2694X" )	//Alltrim(Getmv("CMV_WSR010"))  
	Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
	Local _nSituacao	:= 64
	Local _aNumOrc		:= {}	
	Local _lRet			:= .T.
	Local _cWhere		:= ""
	Local _oJson
	Local _cObs
	Local _lProcessou
	Local _nPos
	Private _cEmpWis		:= ""
	Private _cDepWis		:= ""

	Default _cAglutina	:= ""
	Default _cPicking	:= ""
	Default _lDataEnv	:= .F.  //indicar se valida data de envio 

	Begin Sequence
		If _lJob
			Conout("ZWSR007 - Iniciando processamento envio "+DtoC(Date())+" as "+Time())
		EndIf
		/*
		If Empty(_cPicking) .and.  Empty(_cAglutina)
			Aadd(_aMsgRet, {302,"Não informado Picking e ou Onda para envio Separação "}) 
			_lRet := .F.
			Break
		EndIf
		*/
		//Caso tenha sido informado o numero do picking 
		//foi implementado para posterior reenvio do picking caso seja necessário
		//da forma em que esta o select exige ainda aglutinação caso queira reenviar o picking mas é possivel alterar para não estar atrelado a aglutinação  
		If !Empty(_cPicking)
			_cWhere :=  " VS1.VS1_XPICKI = '"+_cPicking+"' "
		Else
			_cWhere :=  " VS1.VS1_XPICKI <> '"+Space(01)+"' "
		EndIf
		If !Empty(_cAglutina)
			_cWhere +=  " AND VS1.VS1_XAGLU = '"+_cAglutina+"' " 
		Else
			_cWhere +=  " AND VS1.VS1_XAGLU <> '"+Space(01)+"' "
		EndIf
		//If ! _lDataEnv
		//	_cWhere +=  " AND VS1.VS1_XDTEPI = '"+Space(01)+"' "
		//EndIf

		_cWhere := "%"+_cWhere+"%"
		BeginSql Alias _cAlias
			SELECT   VS1.R_E_C_N_O_ NREGVS1 ,
					VS1.VS1_NUMORC,
					VS1.VS1_XPICKI,
					SA1.R_E_C_N_O_ NREGSA1
		FROM %table:VS1% VS1
			JOIN %table:SA1% SA1 
				ON  SA1.A1_FILIAL 	= %XFilial:SA1%
				AND SA1.A1_COD		= VS1.VS1_CLIFAT
				AND SA1.A1_LOJA		= VS1.VS1_LOJA
				AND SA1.%notDel%		  
		WHERE 	VS1.%notDel%
				AND VS1.VS1_FILIAL  = %XFilial:VS1%
				AND VS1.VS1_STATUS	= %Exp:_cFaseConf%
				AND VS1.VS1_TIPORC = '1'
				AND %Exp:_cWhere%
				AND VS1.%notDel%		  

			ORDER BY VS1.VS1_XPICKI, VS1.VS1_NUMORC
		EndSql      
			//	AND VS1.VS1_XAGLU   = %Exp:_cAglutina%
			//VS1.VS1_XTPPED, VS1.VS1_XTPTRA, VS1.VS1_CLIFAT, VS1.VS1_LOJA, VS1.VS1_FORPAG, VS1_XDATOS, VS1_XHOROS
			//GROUP BY A1.A1_CGC, VS1.VS1_FORPAG, VS1.VS1_XTPPED, VS1.VS1_XTPTRA, VS3.VS3_CODITE, VS3.VS3_QTDITE--, B2.B2_QATU -- TIPOS_MODAIS.TIPO_MODAL,
			//ORDER BY VS1.VS1_XTPPED, VS1.VS1_XTPTRA
			/*

			*/
		_lProcessou := .F.  //indica que passou pelo processamento e não será tratado nas msg de erros acima
		_aMsgRet 	:= {}
		If (_cAlias)->(Eof())
			Aadd(_aMsgRet, {200,"Não localizados registros para envio Separação "}) 
			_lRet	:= .F.
			Break
		EndIf
		//	ORDEM : TIPO FRETE+TIPO TRANSPORTE+CLIENTE+LOJA+forpag+DATA ORC+HORA ORC+COD PRODUTO
		//::SetContentType('application/json')
		//_oJson := JsonObject():new()
		//_oJson:fromJson(DecodeUTF8(Self:GetContent(,.T.)))  //Correto
		While (_cAlias)->(!Eof())
			VS1->(DbGoto((_cAlias)->NREGVS1))  
			SA1->(DbGoto((_cAlias)->NREGSA1))
			VE1->(DbSeek(XFilial("VE1")+VS1->VS1_CODMAR))
			If Empty(VS1->VS1_XPICKI) .or. (_cAlias)->NREGVS1 == 0
				(_cAlias)->(DbSkip())
				Loop
			EndIf	  	
			If ! _lDataEnv .and. !Empty(VS1->VS1_XDTEPI)  
				Aadd(_aMsgRet, {301,"Orçamento "+VS1->VS1_NUMORC+" com envio já informado ref, Picking "+_cPicking+" para envio Separação "}) 
				_lRet	:= .F.
				Break
			EndIf	
			_cPicking := VS1->VS1_XPICKI	
			If !_lJob
				_oSay:SetText("Processando para envio Picking " + _cPicking  )
			EndIf	
			SZK->(DbSetOrder(1))
			SZK->(DbGotop())
			If !SZK->(DbSeek(XFilial("SZK")+_cPicking))
				Aadd(_aMsgRet, {301,"Problemas no envio RG LOG Não localizados registros Cabeçalho Picking "+_cPicking+" para envio Separação "}) 
				_lRet	:= .F.
				Break
			Endif	
		//Caso não seja processamento em job chamo para liberar o processo de encio	
		Else
			StartJob("U_XFUNIPOSTO",GetEnvServer(),.F.,VS1->VS1_NUMORC, cEmpAnt, cFilAnt, /*_nReprocessado*/, /*_oSay*/)
		Endif

		_cEmpWis := ""
		_cDepWis := ""
        If ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa 02-Franco da Rocha
            If AllTrim(VS1->VS1_XMARCA) =="CHE"
                _cEmpWis := "1002"
			    _cDepWis := "PREP"
            ElseIf AllTrim(VS1->VS1_XMARCA) =="SBR"
                _cEmpWis := "1006"
			    _cDepWis := "RGLOG"
            ElseIf AllTrim(VS1->VS1_XMARCA) =="HYU"
                _cEmpWis := "1006"
			    _cDepWis := "RGLOG"
            EndIf
        ElseIf( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) //90- HMB
            If AllTrim(VS1->VS1_XMARCA) =="HYU"
                _cEmpWis := "1008"
			    _cDepWis := "RGLOG"
            EndIf
		EndIf
	
	    FreeObj(_oJson)
    	_oJson 				:= JsonObject():new()
		_oJson['usuario']	:= _cUsuario
		_oJson['senha']		:= _cSenha
    	_oJson['pedido'] 	:= JSonObject():New()
		_oJson['pedido'] ['nu_pedido']			:= _cPicking
		_oJson['pedido'] ['cd_cliente']			:= Val(SA1->A1_CGC) //Conversão para inteiro - Alteração solicitada por Sidney em 31/01/2022
		_oJson['pedido'] ['cd_empresa']			:= _cEmpWis
		_oJson['pedido'] ['cd_situacao']		:= _nSituacao
		_oJson['pedido'] ['dt_addrow']			:= ""  	//DtoC(Date())+" "+SubsTr(time(),1,8)
		_oJson['pedido'] ['id_processado']		:= "N"
		_oJson['pedido'] ['cd_error']			:= ""
		_oJson['pedido'] ['dt_processado']		:= ""		//DtoC(Date())+" "+SubsTr(time(),1,8)
		_oJson['pedido'] ['tp_pedido']			:= zBuscaTp(AllTrim(VS1->VS1_XTPPED)) //"C" 		//AllTrim(VS1->VS1_XTPPED) precisar de uma tabela de /para Cirilo ira passar os códigos DAC 21/12/2021
		_oJson['pedido'] ['cd_rota']			:= "2"
		_oJson['pedido'] ['ds_arquivo']			:= ""
		_oJson['pedido'] ['referencia']			:= ""
		_oJson['pedido'] ['cd_assunto']			:= ""
		_oJson['pedido'] ['ds_assunto']			:= ""
		_oJson['pedido'] ['cd_posto']			:= ""
		_oJson['pedido'] ['descricao']			:= ""
		_oJson['pedido'] ['nr_kit']				:= ""
		_oJson['pedido'] ['cd_linha_montagem']	:= ""
		_oJson['pedido'] ['nu_interface']		:= ""
		_oJson['pedido'] ['cd_porta']			:= "1"      	//Verificar valor default sera definido Sidney
		_oJson['pedido'] ['nu_pedido_origem']	:= _cPicking
		_oJson['pedido'] ['cd_produto']			:= ""
		_oJson['pedido'] ['cd_carga']			:= "1"
		_oJson['pedido'] ['dt_faturamento']		:= ""
		_oJson['pedido'] ['tp_frete']			:= ""
		_oJson['pedido'] ['id_cliente_retira']	:= ""
		_oJson['pedido'] ['cd_onda']			:= ""	
		_oJson['pedido'] ['cd_transportador']	:= ""
		_oJson['pedido'] ['ds_transportadora']	:= ""
		_oJson['pedido'] ['cd_registro']		:= ""
		_oJson['pedido'] ['ds_cliente']			:= AllTrim(SA1->A1_NOME)
		_oJson['pedido'] ['nu_seq_entrega']		:= 0
		_oJson['pedido'] ['qt_itens']			:= ""
		_oJson['pedido'] ['id_cross_docking']	:= ""
		_oJson['pedido'] ['cd_deposito']		:= _cDepWis
		_oJson['pedido'] ['cd_roteiro']			:= ""
		_oJson['pedido'] ['nu_agenda']			:= ""
		_oJson['pedido'] ['ds_placa']			:= SA1->A1_EST	//"" alterado conforme solicitação Sidnei RG LOG tem que ser UF do cliente  DAC 16/02/2022
		_oJson['pedido'] ['cd_freteiro']		:= ""
		_oJson['pedido'] ['nm_municipio']		:= ""
		_oJson['pedido'] ['dt_liberacao_pedido']:= ""
		_oJson['pedido'] ['cd_cgc_cliente']		:= Val(SA1->A1_CGC) //Conversão para inteiro - Alteração solicitada por Sidney em 31/01/2022
		_oJson['pedido'] ['nm_representante']	:= ""
		_oJson['pedido'] ['cd_representante']	:= ""
		_oJson['pedido'] ['ds_bairro']			:= AllTrim(SA1->A1_BAIRRO)
		_oJson['pedido'] ['ds_cidade']			:= AllTrim(SA1->A1_MUN)
		_oJson['pedido'] ['ds_endereco']		:= AllTrim(SA1->A1_END)
		_oJson['pedido'] ['nm_solicitante']		:= ""
		_oJson['pedido'] ['nm_destinatario']	:= ""
		_oJson['pedido'] ['nu_picking']			:= _cPicking
		_oJson['pedido'] ['nu_pedido_referencia']:= ""
		_oJson['pedido'] ['ds_meio_transp']		:= ""
    	_oJson['pedido'] ['item']  				:= ZWSR007ITE( _oJson, _cPicking, @_lRet, @_aMsgRet)

		If !_lRet
			_lRet := .F.
			Break
		EndIf
		_aNumOrc := {}
		//Guardo orçamentos para poder agrupar os produtos nos itens
		//desta forma passo os orçamentos que ja foram enviados em ZWSR007ITE enviara somente VS3 nesta função conforme numero do picking
		_cObs := "Pick "+AllTrim(_cPicking)+" ref.orc.fases " 
  		While (_cAlias)->(!Eof()) .And. (_cAlias)->VS1_XPICKI == _cPicking 
			_nPos := Ascan(_aNumOrc,{|x| x[1] == (_cAlias)->VS1_NUMORC})
			If  _nPos == 0 .and. (_cAlias)->NREGVS1 > 0
				Aadd(_aNumOrc,{(_cAlias)->VS1_NUMORC,(_cAlias)->NREGVS1})
				//_cObs += AllTrim( (_cAlias)->VS1_NUMORC )+" "  //Não sera necessário mandar será tratado no SC5 conforme alinhado com Zé DAC  22/02/2022 
				EndIf
				//-- Guardo recnos para gravação do VS1_PICKI em todos os registros da VS1
				//-- em caso de sucesso na integração do pedido - Fagner - 07/01/2021
				//Aadd( aRecVS1, (_cAlias)->NREGVS1)  //Retirado não é necessário _aNumorc ja possui numero de registro DAC 03/02/2022
				(_cAlias)->(DbSkip())
			EndDo
			_lProcessou := .T.  //indica que passou pelo processamento e não será tratado nas msg de erros acima
			_lRet := ZWSRENVPOS( _oJson, _oSay, _lJob)
			ZWSR007AOP(_aNumOrc, _cPicking, _lRet, _cObs, _oJson )
			//Caso ja tenha entrado sem informação do picking deverá zerar o numero do picking para criar um sequencial
			/*
			If zPostRg(_oJson)
				VS1->(ConfirmSx8())
			Else
				RollBackSX8()	
			Endif
			*/
		EndDo
	End Sequence

	If !_lProcessou .and. Len(_aMsgRet) > 0 
		_cObs := "PROBLEMAS NO ENVIO RG LOG [ZWSR007], NÃO ENVIADO PICKING "+ _cPicking + " em " + DtoC(Date())+ SubsTr(Time(),1,5) +CRLF
		If _aMsgRet[1,1] == 200  //Caso não tenha localizado registro
			_cObs += " - "+_aMsgRet[1,2] + CRLF
			Conout(_cObs)
		Else
			For _nPos := 1 To Len(_aMsgRet)
				_cObs += " - "+_aMsgRet[_nPos,2]+ CRLF
			Next _nPos
			(_cAlias)->(DbGotop())
			While (_cAlias)->(!Eof())
				VS1->(DbGoto((_cAlias)->NREGVS1))  
				//Gravo informação no registro
				VS1->(RecLock("VS1", .F. ))
				VS1->VS1_OBSAGL	:= Upper(_cObs) + CRLF  + AllTrim(VS1->VS1_OBSAGLU)
				VS1->VS1_XBO	:= "E"  //Problemas na integração
				VS1->(MsUnlock())
				(_cAlias)->(DbSkip())
			EndDo
			Conout(_cObs)
		EndIf
	Endif	
	If Select((_cAlias)) <> 0
		(_cAlias)->(DbCloseArea())
		Ferase(_cAlias+GetDBExtension())
	Endif 
	If _lJob
		Conout("ZWSR007 - Finalizando processamento envio "+DtoC(Date())+" as "+Time()+" com "+If(_lRet,"Sucesso","Inconsistência"))
	EndIf

Return _lRet



//Carregar o itens do envio
Static Function ZWSR007ITE( _oJson, _cPicking, _lRet, _aMsgRet)
Local _aItens 		:= {}
Local _cAliasPesq	:= GetNextAlias()   
Local _nSituacao	:= 64
Local _nPos
Local _nSeq

Begin Sequence
	//Faço um Select para agrupar por quantidade
	//Ajustado GROUP BY não pode ser de item e sequencia
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT 	VS3.VS3_CODITE, 
				SUM(VS3.VS3_QTDITE) AS VS3_QTDITE,
				SUM(VS3.VS3_VALTOT) AS VS3_VALTOT
		FROM  %Table:VS3% VS3 
		WHERE 	VS3.VS3_FILIAL 	=  	%xFilial:VS3% 
			AND VS3.VS3_XPICKI 	=	%Exp:_cPicking%
			AND VS3.VS3_QTDITE 	>  0
            AND VS3.%notDel%
		GROUP BY VS3.VS3_CODITE
		ORDER BY VS3.VS3_CODITE
	EndSql
	//VERIFICA SE LOCALIZOU ITENS
	If (_cAliasPesq)->(Eof())  
    	//adiciono retorno em branco
		Aadd(_aItens,JsonObject():new())
		Aadd(_aMsgRet, {301,"Problemas envio RG LOG, Não localizados registros relacionados aos itens para envio Separação "}) 
		_lRet := .F.
		Break	
	Endif
	While (_cAliasPesq)->(!Eof())
		//Controlar 
		If (_cAliasPesq)->VS3_VALTOT <= 0
			Aadd(_aMsgRet, {302,"Problemas envio RG LOG, Valores referente ao total zerados, não será enviado Picking ! "}) 
			_lRet := .F.
			Break	
		Endif
    	Aadd(_aItens,JsonObject():new())
    	_nPos := Len(_aItens)
    	_nSeq := _nPos //Val((_cAliasPesq)->VS3_SEQUEN) //Len(_aItens)
    	_aItens[_nPos] ['nu_pedido'] 			:= _cPicking
    	_aItens[_nPos] ['cd_cliente'] 			:= Val(SA1->A1_CGC) //Conversão para inteiro - Alteração solicitada por Sidney em 31/01/2022
    	_aItens[_nPos] ['cd_empresa'] 			:= _cEmpWis //"1"
		_aItens[_nPos] ['cd_produto'] 			:= AllTrim((_cAliasPesq)->VS3_CODITE)
		_aItens[_nPos] ['cd_faixa'] 			:= ""
		_aItens[_nPos] ['nu_seq_pedido'] 		:= _nSeq
		_aItens[_nPos] ['qt_separar'] 			:= (_cAliasPesq)->VS3_QTDITE
		_aItens[_nPos] ['ps_separar'] 			:= "" //AllTrim((_cAliasPesq)->VS3_CODITE)
		_aItens[_nPos] ['qt_volumenes_separar']	:= "" //(_cAliasPesq)->VS3_QTDITE
		_aItens[_nPos] ['qt_pallets_separar'] 	:= ""
		_aItens[_nPos] ['vl_separar'] 			:= ""
		_aItens[_nPos] ['cd_situacao'] 			:= _nSituacao
		_aItens[_nPos] ['cd_carga'] 			:= 1
		_aItens[_nPos] ['qt_pedido'] 			:= ""
		_aItens[_nPos] ['ps_pedido'] 			:= ""
		_aItens[_nPos] ['nu_pedido_origem'] 	:= _cPicking
		_aItens[_nPos] ['nu_seq_corp'] 			:= _nSeq
		_aItens[_nPos] ['cd_posto'] 			:= ""
		_aItens[_nPos] ['nr_kit'] 				:= ""
		_aItens[_nPos] ['cd_destino'] 			:= ""
		_aItens[_nPos] ['nu_lote'] 				:= ""
		_aItens[_nPos] ['nu_serie_produto'] 	:= ""
		_aItens[_nPos] ['dt_addrow'] 			:= ""
		_aItens[_nPos] ['nu_interface'] 		:= ""
		_aItens[_nPos] ['dt_processado'] 		:= ""
		_aItens[_nPos] ['id_busca_lote'] 		:= ""
		_aItens[_nPos] ['cd_registro'] 			:= ""
		_aItens[_nPos] ['id_processado'] 		:= "N"
		_aItens[_nPos] ['nu_doc_erp'] 			:= ""
		_aItens[_nPos] ['cd_deposito'] 			:= _cDepWis//If(VS1->VS1_XMARCA == "CHE","PREP", "RGLOG") //conforme solicitação JC DAC 13/04/2022
		_aItens[_nPos] ['cd_roteiro'] 			:= ""
		_aItens[_nPos] ['nu_seq_entrega'] 		:= ""
		_aItens[_nPos] ['nu_agenda'] 			:= ""
		_aItens[_nPos] ['qt_cross_docking'] 	:= ""
		_aItens[_nPos] ['qt_unidade_embalagem']	:= ""
		_aItens[_nPos] ['nu_picking'] 			:= _cPicking
		(_cAliasPesq)->(DbSkip())
	EndDo     	 
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _aItens

//Atualizar os orçamentos com os numero do picking
Static Function ZWSR007AOP(_aNumOrc, _cPicking, _lProcessado, _cObsMenNF, _oJson)
Local _lRet	:= .T.
Local _cObs	:= "[ZWSR007AOP] ENVIO SEPARAÇÃO PICKING "+ _cPicking +" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5)+ CRLF		
Local _nPos

Default _lProcessado 	:= .F. 
Default _cObsMenNF		:= ""

Begin Sequence
	//guardo primeiro a observação
	//pega informações do retorno para gravar na obs
	For _nPos := 1 To Len(_aMsgRet)
		_cObs += _aMsgRet[_nPos,2] + CRLF
	Next
	If !Empty(_cObsMenNF)
		_cObs 	+= _cObsMenNF
	EndIf	
	//Gravar no SZK o Json
	ZWSR007GRJ(_cPicking, _oJson, _lProcessado, @_cObs)
	//Gravo usuario e obs
	For _nPos := 1 To Len(_aNumOrc) 
		VS1->(DbGoto( _aNumOrc[_nPos,2] )) // //N.Orçamento [1], N.do Registro na VS1 [2]
		If VS1->(RecLock("VS1",.F.))
			If _lProcessado
				//VS1->VS1_XPICKI := _cPicking  JA ESTA GRAVADO ANTERIORMENTE
				VS1->VS1_XDTEPI	:= Date() 
				VS1->VS1_XHSPIC := Time()
				VS1->VS1_XUSUPI := RetCodUsr()
				VS1->VS1_XBO	:= "I"  //foi integrado
				VS1->VS1_OBSAGL	:=  Upper(_cObs) + CRLF  + AllTrim(VS1->VS1_OBSAGL) 
				//Gravar Picking e Aglutinação no VS3 na VS3 - Itens
				VS3->(dbSetOrder(1))
				VS3->(dbSeek(xFilial("VS3")+VS1->VS1_NUMORC))  //_aNumOrc[_nPos,1]))
       	    	Do While (!("VS3")->( Eof() ) .and. VS3->VS3_FILIAL ==  VS1->VS1_FILIAL .AND. VS3->VS3_NUMORC = VS1->VS1_NUMORC )//_aNumOrc[_nPos,1])
                	VS3->(RecLock("VS3",.F.))
			    	//VS3->VS3_XPICKI	:=	VS1->VS1_XPICKI JA ESTA GRAVADO ANTERIORMENTE
					VS3->VS3_XAGLU	:=	VS1->VS1_XAGLU  
					VS3->VS3_XDTAGL	:=	VS1->VS1_XDTAGL
					VS3->VS3_XHSAGL	:=	VS1->VS1_XHSAGL
					VS3->VS3_XUSUGL	:=	VS1->VS1_XUSUGL
		        	VS3->(MsUnlock())
                	VS3->(dbSkip())
            	EndDo
				//NÃO GRAVAR INFORMAÇÕES SERA ENVIADO NO RECEBIMENTO E NO MOMENTO DO SC5 DAC 22/02/2022
				//VS1->VS1_MENNOT := AllTrim(VS1->VS1_NUMORC) //Upper(AllTrim(_cObsMenNF))
				//EndIf
			Else
				//DAC Reverter o orçamento e o picking Avalidar com  JC se libera esta funcionalidade neste ponto
				//U_XRETSTVS1(VS1->VS1_NUMORC, .F. /*_lTela*/)  //reverter orçamento caso não conseguiu enviar	
				//Não ira voltar para o status inicial será implementado nova sigla de pendente no picking para aproveitar o ja processado, alinhado com Zé e Rosangela DAC 06/06/2022
				//VS1->VS1_XBO	:= "E"  //se for voltar a fase a 0 colocar xbo como erro
				_cObs := "NÃO FOI POSSIVEL INTEGRAR PICKING COM RGLOG"+ CRLF  +_cObs
				VS1->VS1_OBSAGL	:=  Upper(_cObs) + CRLF  + AllTrim(VS1->VS1_OBSAGL) 
				VS1->VS1_XDTEPI := CtoD(Space(08))
				VS1->VS1_XHSPIC := Time()
				VS1->VS1_XUSUPI := RetCodUsr()
				VS1->VS1_XBO	:= "E"  //Problemas na integração
			Endif
			VS1->(MsUnlock())
			//Fazer o recalculo dos valores antes de enviar para a separação conforme solicitação JC TOTVS
			//AJUSTADO PARA REFAZER O VALOR NO MOMENTO DE ATUALIZAR O REGISTRO DAC 06/06/2022
		Else
			ConOut("ZWSR007AOP - ERRO AO BLOQUEAR VS1 ")
		EndIf	
	Next	
End Sequence
Return _lRet



// Envio do Picking para carregamento
//******************************************
Static Function ZWSRENVPOS( _oJson, _oSay, _lJob) //zPostRg(_oJson)  
	//******************************************
	local cUrl 		   	:= Alltrim(Getmv("CMV_WSR001"))  //"wmsapi.rgtracking.com.br:8080/interfacewis/entrada/pedido/"
	//Local cPathUrl    	:= Alltrim(Getmv("CMV_WSR002"))  //interfacewis/entrada/pedido
	Local aHeader     	:= {"Content-Type: application/json; charset=utf-8"}  //"Content-Type: application/json"
	Local cRes        	:= Nil
	Local cHeaderGet  	:= ""  
	Local _lRet			:= .T.
	Local nCont			:= 0
	Local cApi 			:= SubStr( cUrl, At("/", cUrl) )
	Local _nTempo		:= 3	//reduzido o tempo pois podera tentar enviar novamente após o final do processamento ZPECF08
	Local _cJson 	   	

	oJsRet	:= JsonObject():New()

	Begin Sequence
		//oJsonEnv["usuario"] := Alltrim(Getmv("CMV_WSR009")) // Usuário
		//oJsonEnv["senha"]   := Alltrim(Getmv("CMV_WSR010")) // Senha encodada no Postman com o tipo Basic
		//oJsonEnv["pedido"]  := _oJson
		_cJson 	:= _oJson:toJSON()
		_cJson 	:= EncodeUTF8( _cJson )

		While Valtype(cRes) = "U"
			nCont++
			If !_lJob
				_oSay:SetText("Conectando a API " + cApi + " - RGLog... " + "Tentativa " + cValToChar(nCont) + " de " + cValToChar(10)  )
			EndIf
			cRes 	:= HttpPost( cUrl, "", _cJson, 60, aheader, @cHeaderGet)

			If Valtype(cRes) = "U"
				Sleep(3000)
			EndIf

			If nCont == _nTempo  //10
				Exit
			EndIf 
		EndDo

		if Valtype(cRes) = "U"
			_lRet := .F.
			//Return {.f., "Sen retorno do Host"}
			Aadd(_aMsgRet,{999,"Não existe retorno do Host, excedido o numero de tentativas de conexão"})
			Break
		EndIf

		oJsRet:FromJSON(cRes)
		if oJsRet:hasProperty("status") = .F.
			_lRet := .F.
			//Return { .F., "Não retornou Status de Processamento:" + cRes}
			Aadd(_aMsgRet,{999,"Não retornou Status de Processamento:" + cRes})
			Break
		Endif

		if  oJsRet["status"] = 200 .Or. oJsRet["status"] = 201 //Alteração solicitada por Sidney via e-mail em 05/01/2021 -- Fagner  
			Aadd(_aMsgRet,{oJsRet["status"],"Processado com Sucesso "+cRes})
			//Return { .T., "Ok, processado" + cRes}
			Break
		EndIf

		if  oJsRet["status"] >= 400 .AND. oJsRet["status"] <= 500 
			_lRet := .F.
			Aadd(_aMsgRet,{oJsRet["status"],"Erro interno do servidor RgLog "+cRes})
			//Return { .F., "Erro interno do servidor RgLog" + cRes}
			Break
		EndIf
	End Sequence
	SetRestFault(_aMsgRet[1,1],_aMsgRet[1,2])
Return _lRet


//Reprocessar envio separação para orçamentos que não gerarão picking - DAC 29/12/2021
User Function ZWSR007R()
	Local _cAliasPesq	:= GetNextAlias()   
	Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
	Local _lTodos		:= .F.
	Local _lDataEnv		:= .F.
	Local _cWhere		:= ""
	Local _cPicking 	:= VS1->VS1_XPICKI
	Local _cAglutina	:= VS1->VS1_XAGLU

	Local _cPerg		:= "U_ZWSR007R"
	Local _aPar			:= {}
	Local _aSays		:= {}
	Local _aButtons		:= {}
	Local _aRet    	    := {}

	Local _cCadastro    := OemToAnsi("Reprocessar envio Picking RG LOG")   //"Separação Orçamento"
	Local _cTitle  	    := OemToAnsi("Reprocessar envio Picking")   //"Separação Orçamento"

	Local _nRet			:= 0
	Local _cCodMarca	:= Space(TamSx3("VS1_XMARCA")[1]) 


	Begin Sequence
		//	Aadd(_aPar,{1,"Filial de:"				,_cFilDe 	,"@D"		,".T."	,"SM0" ,".T."	,50,.F.})
		//	Aadd(_aPar,{1,"Filial Ate:"				,_cFilAte	,"@D"		,".T."	,"SM0" ,".T."	,50,.T.})
		aAdd(_aPar,{3 , OemToAnsi("Reprocessar") ,2 , {OemToAnsi("Todos"), OemToAnsi("Selecionado")}	,60,"",.F.})  //Descrição / 1=Todos 2=Selecionado 
		Aadd(_aPar,{1 , OemToAnsi("Marca      ") , _cCodMarca	, "@!"		, ".T."	, "VE1" 	, ".T."	, 50,.F.}) //Código do marca
		// Monta Tela principal
		AADD(_aSays,OemToAnsi("indique se ira reprocessar todos os picking não enviados")) 
		AADD(_aSays,OemToAnsi("ou se ira processar o picking Selecionado.")) 
		AADD(_aSays,OemToAnsi("Caso seja reprocessamento de Todos Picking, poderá ser ")) 
		AADD(_aSays,OemToAnsi("informado a Marca, caso este campo esteja vazio processara")) 
		AADD(_aSays,OemToAnsi("todas as marcas relativos aos Picking não enviados")) 

		AADD(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
		AADD(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
		AADD(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,_cPerg,.T.,.T.) 		}})

		FormBatch( _cCadastro, _aSays, _aButtons )
		If _nRet <> 1
			Break
		Endif
		If Len(_aRet) == 0
			Help("",1,OemToAnsi("Atenção"),,OemToAnsi("Necessário informar os parâmetros"),4,1) // Atenção/Necessário informar os parâmetros
			Break 
		Endif
		If _aRet[01] == 1  //todos
			_lTodos 	:= .T.
			_cPicking	:= ""
			_cAglutina  := ""		 	
			_cWhere 	+=  " VS1.VS1_XDTEPI = ' ' "
		Else
			_cWhere +=	" 	  VS1.VS1_XPICKI = '"+ _cPicking	+"' "
			_cWhere +=	" AND VS1.VS1_XAGLU  = '"+ _cAglutina	+"' "
		EndIf
		If !Empty(_cCodMarca)
			_cWhere	+=  " AND VS1.VS1_XCODMA = '"+ _cCodMarca +"' "
		Endif	
		_cWhere 	:= "%"+_cWhere+"%"

		If !_lTodos .and. Empty(_cPicking)	
			Help( , ,OemToAnsi("ATENCAO"),,OemToAnsi("O orçamentos posicionado não possue numero Picking  !"),4,1) 
			Break
		EndIf
		If !_lTodos .and. VS1->VS1_STATUS <> _cFaseConf	
			Help( , ,OemToAnsi("ATENCAO"),,OemToAnsi("O orçamentos pocicionado não esta na fase de conferência  !"),4,1) 
			Break
		EndIf

		_aMsgRet := {}
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	VS1.VS1_XPICKI
			FROM  %Table:VS1% VS1 
			WHERE 	VS1.VS1_FILIAL 	=  %xFilial:VS1% 
				AND VS1.VS1_XAGLU 	<> ' '
				AND VS1.VS1_XPICKI 	<> ' '
				AND VS1.VS1_TIPORC 	= '1'
				AND VS1.VS1_STATUS	= %Exp:_cFaseConf%
				AND %Exp:_cWhere%
				AND VS1.%notDel%
			GROUP BY VS1.VS1_XPICKI
			ORDER BY VS1.VS1_XPICKI 		 
		EndSql
		//VERIFICA SE LOCALIZOU ITNES
		If (_cAliasPesq)->(Eof()) 
			Help( , ,OemToAnsi("ATENCAO"),,OemToAnsi("Não existem orçamentos a serem reprocessados  com Picking "+_cPicking+" !"),4,1) //Atenção / Não existem orçamentos a serem reprocessados para geração do Picking !
			Break
		EndIf	
		If !_lTodos .And. !Empty(VS1->VS1_XDTEPI)
			If !MsgYesNo( "Este Picking "+ _cPicking +" ja foi enviado para carregamento, deseja reenvia-lo novamente ?"  )
				Break
			EndIf	 
			_lDataEnv := .T.
		EndIf
		//conforme J.C. Não perguntar o processo tem que ser automatico DAC  18/07/2022	
		//If MsgYesNo( "Confirma Reprocessar envio de Picking " +If(_lTodos,"para todos não enviados","numero "+_cPicking)+" para carregamento RG LOG ?"  )
			//Reprocessar
		FwMsgRun(,{ || ZWSR007REP( _cAliasPesq, _lTodos, _lDataEnv ) }, "Reprocessando Picking ", "Aguarde...")  
		//EndIf
	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 

Return Nil

//Reprocessar orçamentos que não gerarão picking
Static Function ZWSR007REP(_cAliasPesq, _lTodos, _lDataEnv)
	Local _lRet 	:= .T.
	Local _lValida  := .T.
	Local _lAborta	:= .T.
	Local _aMens	:= {}
	Local _cObs		:= ""
	Local _lJob		:= IsBlind()
	Local _nPos

	Default _lDataEnv := .F.

	Begin Sequence
		While (_cAliasPesq)->(!Eof())
			_lAborta  	:= .F.
			_lValida 	:= U_ZWSR007( /*VS1_XAGLU*/, (_cAliasPesq)->VS1_XPICKI, _lDataEnv )
			//Caso tenha retorno do processamento
			If !_lValida  
				//Faço verificação do código para saber
				If ValType(_aMsgRet)  == "A"
					//verifico se tenho algum item com envio correto
					For _nPos := 1 To Len(_aMsgRet)
						//caso não validou o envio posso deixar como falso para retorno	
						If _aMsgRet[_nPos,1] == 100
							_lValida  := .T.
						Endif
						Aadd( _aMens,{	_aMsgRet[_nPos,2], ;
										AllTrim((_cAliasPesq)->VS1_XPICKI )})	
						If _aMsgRet[_nPos,1] == 999  //respectivo a conexão irei abortar o processo caso tenham muitos para ser enviados
							_lAborta  := .T.
						Endif
					Next
				Else
					Aadd( _aMens,{	"Problemas no envio para REST RG LOG", ;
									AllTrim((_cAliasPesq)->VS1_XPICKI )})	
				Endif
				If !_lValida  
					_lRet 	:= .F.
				ElseIf _lValida   //ocorreu uma validação de envio apesar de ter código 999 no meio não vai poder abortar
					_lAborta  := .F.
				EndIf	
			EndIf	
			//no caso de poder abortar e for mais de um picking posso sais do while
			(_cAliasPesq)->(DbSkip())
			If (_cAliasPesq)->(!Eof()) .and. _lAborta .and. _lTodos
				Aadd( _aMens,{	"Processo interrompido devido a Erro recorrente (acima) não processara os demais itens para ", ;
								"Todos"	})			
					_lRet 	:= .F.
				Exit
			Endif
		EndDo
	End Sequence
	If !_lRet
		_cObs := ""
		For _nPos := 1 To Len(_aMens) 
			_cObs += " * "+_aMens[_nPos,1] + " Picking "+_aMens[_nPos,2]+CRLF
		Next
		If _lJob
			Conout("ZWSR007 "+_cObs)
		Else
			MSGINFO( Upper(_cObs), "[ZWSR007] - Problemas ocorridos no envio" )
		EndIf
	Else
		_cObs := "Processo integrado com Sucesso !"
		If _lJob
			Conout("ZWSR007 "+_cObs)
		Else	
			MSGINFO( Upper(_cObs), "[ZWSR007] - Atenção" )
		EndIf
	EndIf
Return _lRet

//Busca o tipo de pedido de acordo com o De/Para RgLog
Static Function zBuscaTp(_cTpPedido)
	Local _cRet		:= "C"
	Local _cQry      := '' 
	Local _cAlsVX5 	:= GetNextAlias()  
	If Select(_cAlsVX5) > 0
		(_cAlsVX5)->(dbCloseArea())
	EndIf

	_cQry := " SELECT VX5_DESCRI FROM "+RetSqlName("VX5")+" VX5 "
	_cQry += " WHERE VX5.VX5_FILIAL = '" + FWxFilial("VX5") +"' "
	_cQry += " AND VX5.VX5_CHAVE = 'Z04' "
	_cQry += " AND VX5.VX5_CODIGO = '"  + AllTrim(_cTpPedido)  + "' "
	_cQry += " AND VX5.D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlsVX5,.T.,.F.)
	dbSelectArea(_cAlsVX5)
	(_cAlsVX5)->(dbGoTop())
    If (_cAlsVX5)->(!EOF())
		_cRet := AllTrim((_cAlsVX5)->VX5_DESCRI)
	EndIf
	(_cAlsVX5)->(dbCloseArea())

	If Select((_cAlsVX5)) <> 0
		(_cAlsVX5)->(DbCloseArea())
		Ferase(_cAlsVX5+GetDBExtension())
	Endif 
Return(_cRet)



//documento json
/*
{
"usuario":"interfacewis",
	"senha":"sythex@123",
	"pedido":
{
		"nu_pedido":"",
"cd_cliente":'12',
"cd_empresa":'1',
		"cd_situacao":'1',
dt_addrow:"",
id_processado:'N',
cd_error:"",
dt_processado:"",
"tp_pedido":'A',
"cd_rota":"",
ds_arquivo:"",
referencia:"",
cd_assunto:"",
ds_assunto:"",
cd_posto:"",
descricao:"",
nr_kit:"",
cd_linha_montagem:"",
nu_interface:"",
"cd_porta":'1',
"nu_pedido_origem":'221',
cd_produto:'A1444',
"cd_carga":"",
"dt_faturamento":"",
tp_frete:"",
id_cliente_retira:"",
cd_onda:"",
cd_transportador:"",
"ds_transportadora":"",
cd_registro:"",
"ds_cliente":"",
"nu_seq_entrega":"",
qt_itens:"",
id_cross_docking:"",
		"cd_deposito":'001',
		cd_roteiro:"",
		nu_agenda:"",
		ds_placa:'UHI-0900',
		cd_freteiro:"",
		nm_municipio:"",
		dt_liberacao_pedido:"",
		cd_cgc_cliente: '909009009',
		nm_representante:"",
		cd_representante:"",
		ds_bairro: 'Teste123',
		ds_cidade: 'São Paulo',
		ds_endereco: 'Rua teste, 123',
		nm_solicitante: 'Joao',
		nm_destinatario: 'Jose',
		nu_picking:'122',
		nu_pedido_referencia:"",
		ds_meio_transp:"",
		
		"item":
		[
			{
				"nu_pedido":"",
"cd_cliente":'12',	
"cd_empresa":'1',
"cd_produto":'P000123',
cd_faixa:"",
nu_seq_pedido:1,
"qt_separar":'10',
ps_separar:"",
qt_volumenes_separar:"",
qt_pallets_separar:"",
vl_separar:"",
"cd_situacao":'1',
"cd_carga":"",
qt_pedido:"",
ps_pedido:"",
"nu_pedido_origem":'221',
nu_seq_corp:1,
cd_posto:"",
nr_kit:"",
cd_destino:"",
"nu_lote":"",
nu_serie_produto:"",
dt_addrow:"",
nu_interface:"",
dt_processado:"",
id_busca_lote:"",
cd_registro:"",
id_processado:'N',
nu_doc_erp:"",
				"cd_deposito":'001',
				cd_roteiro:"",
				nu_seq_entrega:"",
				nu_agenda:"",
				qt_cross_docking:"",
				qt_unidade_embalagem:"",
				nu_picking: '8989'

						}

		]
}
}

*/



//Ex RG LOG 2812
/*
{
    "usuario": "caoa.totvs",
    "senha": "CAgka2694X*",
    "pedido": {
        "nu_pedido": "12654370",
        "cd_cliente": "03097084000111",
        "cd_empresa": 1,
        "cd_situacao": 64,
        "dt_addrow": "",
        "id_processado": "N",
        "cd_error": "",
        "dt_processado": "",
        "tp_pedido": "C",
        "cd_rota": "2",
        "ds_arquivo": "",
        "referencia": "",
        "cd_assunto": "",
        "ds_assunto": "",
        "cd_posto": "",
        "descricao": "",
        "nr_kit": "",
        "cd_linha_montagem": "",
        "nu_interface": "",
        "cd_porta": "1",
        "nu_pedido_origem": "12654370",
        "cd_produto": "",
        "cd_carga": "1",
        "dt_faturamento": "",
        "tp_frete": "",
        "id_cliente_retira": "",
        "cd_onda": "",
        "cd_transportador": "",
        "ds_transportadora": "",
        "cd_registro": "",
        "ds_cliente": "CIBRAS INFORMATICA 4X",
        "nu_seq_entrega": 0,
        "qt_itens": "",
        "id_cross_docking": "",
        "cd_deposito": "RGLOG",
        "cd_roteiro": "",
        "nu_agenda": "",
        "ds_placa": "",
        "cd_freteiro": "",
        "nm_municipio": "",
        "dt_liberacao_pedido": "",
        "cd_cgc_cliente": "03097084000111",
        "nm_representante": "",
        "cd_representante": "" ,
        "ds_bairro": "VILA MARIA",
        "ds_cidade": "RIO DE JANEIRO",
        "ds_endereco": "",
        "nm_solicitante": "",
        "nm_destinatario": "",
        "nu_picking": "12654370",
        "nu_pedido_referencia": "",
        "ds_meio_transp": "",
        "item": [
            {
                "nu_pedido": "12654370",
                "cd_cliente": "03097084000111",
                "cd_empresa": 1,
                "cd_produto": "R-2851037500",
                "cd_faixa": "",
                "nu_seq_pedido": 1,
                "qt_separar": 1,
                "ps_separar": "",
                "qt_volumenes_separar": "",
                "qt_pallets_separar": "",
                "vl_separar": "",
                "cd_situacao": 64,
                "cd_carga": 1,
                "qt_pedido": "",
                "ps_pedido": "",
                "nu_pedido_origem": "12654370",
                "nu_seq_corp": 1,
                "cd_posto": "",
                "nr_kit": "",
                "cd_destino": "",
                "nu_lote": "",
                "nu_serie_produto": "",
                "dt_addrow": "",
                "nu_interface": "",
                "dt_processado": "",
                "id_busca_lote": "",
                "cd_registro": "",
                "id_processado": "N",
                "nu_doc_erp": "",
                "cd_deposito": "RGLOG",
                "cd_roteiro": "",
                "nu_seq_entrega": 1,
                "nu_agenda": "",
                "qt_cross_docking": "",
                "qt_unidade_embalagem": "",
                "nu_picking": "12654370"
            },
            {
                "nu_pedido": "12654370",
                "cd_cliente": "03097084000111",
                "cd_empresa": 1,
                "cd_produto": "R-89400A5310SBL",
                "cd_faixa": "",
                "nu_seq_pedido": 2,
                "qt_separar": 5.08,
                "ps_separar": "",
                "qt_volumenes_separar": "",
                "qt_pallets_separar": "",
                "vl_separar": "",
                "cd_situacao": 64,
                "cd_carga": 1,
                "qt_pedido": "",
                "ps_pedido": "",
                "nu_pedido_origem": "12654370",
                "nu_seq_corp": 2,
                "cd_posto": "",
                "nr_kit": "",
                "cd_destino": "",
                "nu_lote": "",
                "nu_serie_produto": "",
                "dt_addrow": "",
                "nu_interface": "",
                "dt_processado": "",
                "id_busca_lote": "",
                "cd_registro": "",
                "id_processado": "N",
                "nu_doc_erp": "",
                "cd_deposito": "RGLOG",
                "cd_roteiro": "",
                "nu_seq_entrega": 2,
                "nu_agenda": "",
                "qt_cross_docking": "",
                "qt_unidade_embalagem": "",
                "nu_picking": "12654370"
            }
        ]
    }
}
*/


////////////////////
//rodado ajustando após geração
/*
{ "usuario": "caoa.totvs",
	"senha": "CAgka2694X*",
	"pedido": {
		"nu_pedido": "00000520",
		"cd_cliente": "10510247000101",
		"cd_empresa": "1",
		"cd_situacao": 64,
		"dt_addrow": null,
		"id_processado": "N",
		"cd_error": null,
		"dt_processado": null,
		"tp_pedido": "C",
		"cd_rota": "2",
		"ds_arquivo": null,
		"referencia": null,
		"cd_assunto": null,
		"ds_assunto": null,
		"cd_posto": null,
		"descricao": null,
		"nr_kit": null,
		"cd_linha_montagem": null,
		"nu_interface": null,
		"cd_porta": "1",
		"nu_pedido_origem": "00000520",
		"cd_produto": null,
		"cd_carga": "1",
		"dt_faturamento": null,
		"tp_frete": null,
		"id_cliente_retira": null,
		"cd_onda": null,
		"cd_transportador": null,
		"ds_transportadora": null,
		"cd_registro": null,
		"ds_cliente": "VITAL COM DE VEICS LTDA",
		"nu_seq_entrega": 0,
		"qt_itens": 1,
		"id_cross_docking": null,
		"cd_deposito": "RGLOG",
		"cd_roteiro": null,
		"nu_agenda": null,
		"ds_placa": "SP",
		"cd_freteiro": null,
		"nm_municipio": null,
		"dt_liberacao_pedido": null,
		"cd_cgc_cliente": "10510247000101",
		"nm_representante": null,
		"cd_representante": null,
		"ds_bairro": "IGUACU",
		"ds_cidade": "IPATINGA",
		"ds_endereco": "R DOS CAETES, 30",
		"nm_solicitante": null,
		"nm_destinatario": null,
		"nu_picking": "00000520",
		"nu_pedido_referencia": null,
		"ds_meio_transp": null,
		"item": [
			{
			"nu_pedido": "00000520",
			"cd_cliente": "10510247000101",
			"cd_empresa": 1,
			"cd_produto": "R-2851037500",
			"cd_faixa": null,
			"nu_seq_pedido": 1,
			"qt_separar": 3,
			"ps_separar": null,
			"qt_volumenes_separar": null,
			"qt_pallets_separar": null,
			"vl_separar": null,
			"cd_situacao": 64,
			"cd_carga": 1,
			"qt_pedido": null,
			"ps_pedido": null,
			"nu_pedido_origem": "00000520",
			"nu_seq_corp": 1,
			"cd_posto": null,
			"nr_kit": null,
			"cd_destino": null,
			"nu_lote": null,
			"nu_serie_produto": null,
			"dt_addrow": null,
			"nu_interface": null,
			"dt_processado": null,
			"id_busca_lote": null,
			"cd_registro": null,
			"id_processado": "N",
			"nu_doc_erp": null,
			"cd_deposito": "RGLOG",
			"cd_roteiro": null,
			"nu_seq_entrega": null,
			"nu_agenda": null,
			"qt_cross_docking": null,
			"qt_unidade_embalagem": null,
			"nu_picking": "00000520"
			} 
		]
	}
}
*/


//Gravar Json no picking
Static Function ZWSR007GRJ(_cPicking, _oJson, _lProcessado, _cObs)
	Local _cAliasPesq	:= GetNextAlias()   
	Local _lRet			:= .T.
	Local _cJson

	Begin Sequence
		If SZK->(FieldPos("ZK_XJSENV")) == 0
			Break
		EndIf
		If SZK->ZK_XPICKI <> _cPicking
			BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
				SELECT 	SZK.R_E_C_N_O_ NREGSZK 
				FROM  %Table:SZK% SZK 
				WHERE 	SZK.ZK_FILIAL 	=  	%xFilial:SZK% 
					AND SZK->ZK_XPICKI 	=	%Exp:_cPicking%
				ORDER BY SZK.ZK_SEQREG
			EndSql
			If (_cAliasPesq)->(Eof())  .or. (_cAliasPesq)->NREGSZK == 0
				_cObs 	+= "NÃO LOCALIZADO PICKING "+_cPicking + CRLF 
				Break
			EndIf
			SZK->(DbGoto((_cAliasPesq)->NREGSZK))
		EndIf	
		If !SZK->(RecLock("SZK",.F.))
			_cObs	+= "ERRO AO BROQUEAR SZK " + CRLF 
			Break
		EndIf	
		_cJson 	:= _oJson:toJSON()
		_cJson 	:= EncodeUTF8( _cJson )
		If SZK->(FieldPos("ZK_XJSENV")) > 0
			SZK->ZK_XJSENV := _cJson
		EndIf
		If SZK->(FieldPos("ZK_XJSDTEN")) > 0
			SZK->ZK_XJSDTEN := Date()
		EndIf
		If SZK->(FieldPos("ZK_XJSHSEN")) > 0
			SZK->ZK_XJSHSEN := Time()
		Endif
		If SZK->(FieldPos("ZK_XJSSTEN")) > 0 
			SZK->ZK_XJSSTEN := If(_lProcessado,"1","3")  //1=ENVIADO;2=NAO ENVIADO;3=INCONSISTENCIA                                                                                           
		EndIf
		//dados que retornarão gravar não recebido inicialmente DAC 09/06/2022
		If SZK->(FieldPos("ZK_XJSSTRE")) > 0
			SZK->ZK_XJSSTRE := "2" //1=RECEBIDO;2=NAO RECEBIDO;3=INCONSISTENCIA                                                                                      
		EndIf
		If SZK->(FieldPos("ZK_STATUS")) > 0 .and. _lProcessado  //somente se foi processado
			If FWIsInCallStack("U_ZWSR007R")
				SZK->ZK_STATUS := "R"
			Else
				SZK->ZK_STATUS := "E"
			EndIf	
		EndIf
		SZK->(MsUnlock())          
	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 
Return _lRet 

