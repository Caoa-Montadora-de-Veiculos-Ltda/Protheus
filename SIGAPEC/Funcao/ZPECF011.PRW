#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#define CRLF chr(13) + chr(10)

Static _aRetMsg 	:= ZPEC11AMsg()   	//Carregar tabela com erros
Static _aMsgRet 	:= {}				//carregar msg de retorno json
Static _aMsgCAOA 	:= {}				//carrega mensagens para gravar nas tabelas Protheus

/*/{Protheus.doc} ZPECF011
Serviço de integração RECEBIMENTO SEPARAÇÃO DE PEDIDOS rg log
Atualização da separação dos orçamentos baixando conforme informaçção recebida
@author 	DAC 
@since 		17/12/2021
@version 	undefined
@param		Não utilizado
@type 		User Function
@client   	CAOA BARUERI
@return   	_aMsg - Array com retorno Json código e ocorrencia
@project 	Interfaces_PortalV3_v2 x Protheus v2
			https://tdn.totvs.com/display/tec/DecodeUTF8
			https://jsonformatter.curiousconcept.com/  VERIFICAR SE JSON ESTA CORRETO
			https://jsonlint.com/?code=   //VALIDAR JSON
            https://jsoneditoronline.org/#left=local.sowavu  //estrutura do json
Z	-Customizado
PEC	- Modulo
F 	- Função
011 - Sequencial
/*/


User Function ZPECF011(_oJson)
Local _aMsg		:= {}

Begin Sequence
	Conout("INICIANDO FUNCIONALIDADE ZPECF011 em "+DtoC(Date())+" as "+Time())
	_aMsgRet 	:= {}
    If ZPECF011PR( @_oJson )
		ZPEC11RMsg("ok", "Atualização realizada com Sucesso !")
		_aMsg := SetMsgRet()
	Else
		_aMsg := SetMsgRet()
	Endif
End Sequence

IF Len(_aMsg) == 0 		//Prevensão forçar o envia da mensagem para o REST
	_aMsg := SetMsgRet()
EndIf

Conout("TERMINO FUNCIONALIDADE ZPECF011 em "+DtoC(Date())+" as "+Time())
Return _aMsg


/*/{Protheus.doc} ZPECF011PR
Recebe 		Json RG LOG PUT 
@author 	DAC
@since 		23/07/2021
@version 	undefined
@param 		oJson
@type 		function
@ Obs		Os paremetros de token, empresa e filial serão enviados no cabeçalho reader Json
/*/
Static Function ZPECF011PR( _oJson )
Local _cEmpresa     := "02"
Local _cFilAtu      := "2020012001"
Local _lRet			:= .F.
Local _aRegVS1		:= {}
Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local _nPos
Local _cPedido
Begin Sequence
	_aMsgCAOA 	:= {}
	_cUsuario 	:= AllTrim(_oJson:GetJsonText("usuario"))
	_cSenha		:= AllTrim(_oJson:GetJsonText("senha"))	 	 
    If Empty ( _cEmpresa )
		ZPEC11RMsg("_cEmpresa", "Campo cEmpresa: Empresa nao pode ser branco, favor verificar !")
        Break
    EndIf
    If Empty ( _cFilAtu )
		ZPEC11RMsg("_cFilAtu", "Campo cFilAtual: Filial nao pode ser branco, favor verificar !")
        Break
 	EndIf
    If Empty ( _cUsuario ) .or. AllTrim(_cUsuario) <> "RGLOG.REST"
 		ZPEC11RMsg("_cUsuario", "Aplicação Web não está autorizada a acessar os serviços Protheus (_cUsuario Failed) !")
         Break
 	EndIf
    If Empty ( _cSenha ) .or. AllTrim(_cSenha) <> "CaOa!RgLogRest@2021"
 		ZPEC11RMsg("_cSenha", "Aplicação Web não está autorizada a acessar os serviços Protheus (_cUsuario Failed) !")
         Break
 	EndIf
    //Tratar abertura da empresa conforme enviado no parametro
	If cEmpAnt <> _cEmpresa .or. cFilAnt <> _cFilAtu
    	RpcClearEnv() 
    	RPCSetType(3) 
    	RpcSetEnv(_cEmpresa,_cFilAtu,,,,GetEnvServer(),{ })
	EndIf

	// Valida os dados do oJson
	_lRet := ValidOJson(@_oJson,"A")
	If !_lRet 
		Break
	EndIf	
	_lRet := .F.   //necessário pois estara com o ultimo que é verdadeiro caso de erro no programa
	_lRet := ZPEC11GPIK(@_oJson,"I", @_aRegVS1)
	If !_lRet 
		Break
	EndIf
End Sequence

//neste caso deverei gravar as informações dos erros em todos os orçamentos que confiveram erro
_cPedido 	:= AllTrim(_oJson["nu_pedidoorigem"][1]:GetJsonText("nu_pedido")) //"00000510"
//Gravar observação
_cObs		:= "[ZPECF011] RETORNO DE SEPARAÇÃO RG LOG "+If(!_lRet,"APRESENTOU PROBLEMAS ","")+" REFERENTE PICKING "+_cPedido+" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5)+ CRLF		
_cObs 		+= "Status " + CRLF
For _nPos := 1 To Len(_aMsgRet)
	_cObs += _aMsgRet[_nPos,2] + CRLF
Next
If Len(_aMsgCaoa) > 0 
	_cObs += "Processo" + CRLF
	For _nPos := 1 To Len(_aMsgCaoa)
		_cObs += _aMsgCaoa[_nPos] + CRLF
	Next
Endif 
_cObs := Upper(_cObs)
Conout(_cObs)
//Existindo orçamentos gravar mensagens
//NO CASO DE ERRO E TENHA PROCESSADO ALGUM ORÇAMENTO IRA RETORNAR OS PROBLEMAS ENCONTRADOS
If Len(_aRegVS1) > 0
	_cJson 	:= _oJson:toJSON()
	_cJson 	:= EncodeUTF8( _cJson )
	//Gravar em todos os orçamentos
	For _nPos := 1 To Len(_aRegVS1)
		VS1->(DbGoto(_aRegVS1[_nPos]))
		VS1->(RecLock("VS1",.F.))
		VS1->VS1_OBSAGL	:= Upper(_cObs) + CRLF + VS1->VS1_OBSAGL
		//Garantir que deixara os orçamentos com a fase anterior que é de conferência DAC 29/06/2022
		If VS1->VS1_STATUS <> _cFaseConf
			VS1->VS1_STATUS := _cFaseConf  //volto a fase anterior
		Endif	
		VS1->(MsUnLock())
	Next
EndIf
Return _lRet



/*/{Protheus.doc} ZPEC11GPIK
Realiza a atualização do piking recebido pela RG LOG
@author DAC Denilso 
@since 18/10/2021
@version undefined
@param nCode, numeric, descricao
@param cMsg, characters, descricao
@type function
@history    DAC - 23/06/2022 - Refeita a funcionalidade para gravar  e ajustar carregamento  
@Obs
				Case VM5->VM5_STATUS == "1"
					cStatConf := STR0049 // Pendente
				Case VM5->VM5_STATUS == "2"
					cStatConf := STR0050 // Parcial
				Case VM5->VM5_STATUS == "3"
					cStatConf := STR0051 // Finalizada
				Case VM5->VM5_STATUS == "4"
					cStatConf := STR0052 // Aprovada
				Case VM5->VM5_STATUS == "5"
					cStatConf := STR0053 // Reprovada

/*/
Static Function ZPEC11GPIK(_oJson, _cTipo, _aRegVS1 )
Local _lRet			:= .F.
Local _cAlias 		:= GetNextAlias()
Local _cPedido		:= ""
Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local _cFaseFat		:= "F"
Local _cMsgInconWis	:= ""
Local _cObs
Local _nPos
Local _cQueryUPD

Begin Sequence
	//_nPos := _oJson["nu_pedidoorigem"][1]:GetJsonText("nu_pedido")
	// numero do pedido
	DbSelectArea("SZK")
	_cPedido 	:= AllTrim(_oJson["nu_pedidoorigem"][1]:GetJsonText("nu_pedido")) 
	If !ZPEC11LPIK( _cPedido ) 
		//GAP002 tratar além de processado se esta bloqueado cancelado
		//ZPEC11RMsg("nu_pedido","Pedido "+_cPedido+" ja consta no cadastro Picking como recebido, não sera processado !")
		Break
	EndIf

	BeginSql Alias _cAlias
		SELECT 	VS1.R_E_C_N_O_ NREGVS1
       	FROM %table:VS1% VS1
       	WHERE VS1.VS1_FILIAL  	= %XFilial:VS1%
			AND VS1.VS1_XPICKI 	= %Exp:_cPedido%
		  	AND VS1.%notDel%		  
	EndSql      
	If (_cAlias)->(Eof()) 	
		ZPEC11RMsg("nexistepick","Pedido "+_cPedido+" não localizou itens !")
		Break
	Endif   
	//GAP002  guardar oe orçamentos antes de processar
	While (_cAlias)->(!Eof())
		Aadd(_aRegVS1, (_cAlias)->NREGVS1)
		(_cAlias)->(DbSkip())
	EndDo
	//Repito a passagem VS1 para que seja atualizado todos os orçamentos existentes no picking
	For _nPos := 1 To Len(_aRegVS1)
		VS1->(DbGoto(_aRegVS1[_nPos]))
		//MESMO COM FASE DE CONFERÊNCIA NÃO GRAVOU NO PICKING SZK DAC 08/06/2022
		If VS1->VS1_STATUS  <> _cFaseConf
			ZPEC11RMsg("nostatusorc","Item do Pedido "+_cPedido+" correspondente a numeração "+VS1->VS1_NUMORC+" com fase "+VS1->VS1_STATUS+", diferente de Separação, não sera processado !")
			Break
		EndIf
	Next

	//Controlar a gravação dos dados do orçamento caso tenha 
	Begin Transaction 
		_lRet := ZPEC11VWIS(_cPedido, @_cMsgInconWis)
		//DAC Selecionar processo VS5 e VS6 de carregamento e efetuar baixa
		//SE NÃO TIVER PASSAR PARA PROXIMO REGISTRO
		If _lRet 
			For _nPos := 1 To Len(_aRegVS1)
				If _lRet
					VS1->(DbGoto(_aRegVS1[_nPos]))
					_lRet := ZPEC11Separa(VS1->VS1_NUMORC, _cPedido)
					//Gravo dados necessário para o VS1 orçamento
					//Atualiza TES Inteligente
					If !(U_ZPECREGFI(_cPedido)) //cZK_XPICKI _cPedido
						_cObs		:= 	"ERRO NA ATUALIZAÇÃO TES INTELIGENTE NO PICKING "+_cPedido+" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5)+ CRLF
						Aadd(_aMsgCAOA, Upper(_cObs) )
					EndIf
		
					VS1->(RecLock("VS1",.F.))
					If Empty(_cObs)
						_cObs	:= "RETORNO DE SEPARAÇÃO REALIZADO COM SUCESSO REFERENTE PICKING "+_cPedido+" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5)+ CRLF
					Else
						_cObs	+= "RETORNO DE SEPARAÇÃO REALIZADO COM SUCESSO REFERENTE PICKING "+_cPedido+" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5)+ CRLF
					Endif
					_cObs 	+= "Gravado a conferência (VM5) para os itens de separação  corretamente no recebimento do REST !"+ CRLF
					VS1->VS1_STATUS := _cFaseFat
					VS1->VS1_OBSAGL	:= Upper(_cObs) +CRLF+ VS1->VS1_OBSAGL
					VS1->(MsUnLock())
	
					//efetua a gravação da tabela para controle de picking obtenção de pesos e medidas para a nota
					_lRet := U_ZPEC11GSZK(_oJson, /*_lGravaIni*/, /*_cPicking*/, /*_cObsMenNF*/, /*_cMarca*/, _lRet)
					If !_lRet
						ZPEC11RMsg("noGrava","Problemas com a gravação de dados em relação aos campos verificar com Administrador !")
					EndIf
				Endif 
			Next	 	 
		Endif 
		If !_lRet	
			Disarmtransaction()
		Endif
	End Transaction 
End Sequence
// atualizar SZK com UPdate
//Responsável por atuaizar Picking para não ser mais utilizado devido inconsistencia maior na qtde Wis
If !_lRet  
	If !Empty(_cMsgInconWis)
		//Atualizar Status SZK, não será mais atualizado este picking
		_cQueryUPD := " UPDATE " + RetSqlName("SZK") + " SZK "  
		_cQueryUPD += " SET  SZK.ZK_STATUS 	= 'D', SZK.ZK_OBSCON = '"+Upper(AllTrim(_cMsgInconWis))+"' "
		_cQueryUPD += "		,SZK.ZK_XJSREC 	= '"+_cJson+ "' "
		_cQueryUPD += "     ,SZK.ZK_XJSSTRE = '3' "   //1=RECEBIDO;2=NAO RECEBIDO;3=INCONSISTENCIA
		_cQueryUPD += " WHERE SZK.ZK_FILIAL='" + xfilial("SZK") + "' AND  SZK.ZK_XPICKI = '"+_cPedido+"' "
		TcSqlExec(_cQueryUPD)
	Else 
		_cQueryUPD := " UPDATE " + RetSqlName("SZK") + " SZK "  
		_cQueryUPD += " SET  SZK.ZK_STATUS  = 'D', SZK.ZK_OBSCON = '"+Upper(AllTrim(_cMsgInconWis))+"' "
		_cQueryUPD += "		,SZK.ZK_XJSREC  = '"+_cJson+ "' "
		_cQueryUPD += "     ,SZK.ZK_XJSSTRE = '3' " //1=RECEBIDO;2=NAO RECEBIDO;3=INCONSISTENCIA
		_cQueryUPD += " WHERE SZK.ZK_FILIAL='" + xfilial("SZK") + "' AND  SZK.ZK_XPICKI = '"+_cPedido+"' "
		TcSqlExec(_cQueryUPD)
	Endif 
Endif

If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif  
Return _lRet



/*/{Protheus.doc} ZPEC11Separa
Recebe 		Verifica se os registros de separação estão informado e se estão de acordo com o VS3, finalizar carregamento VS3 e VM5 
@author 	DAC
@since 		23/06/2022
@version 	undefined
@param 		oJson
@type 		function
@ Obs		Os paremetros de token, empresa e filial serão enviados no cabeçalho reader Json
@history    DAC - 23/06/2022 - Modificada a forma de gravar informações sobre o recebimento VM5, VM6 e VM2 verificando se existe e criando novo processo  
/*/
Static Function ZPEC11Separa( _cNumOrc, _cPedido )
Local _lRet			:= .T.
Local _cAliasPesq	:= GetNextAlias()
Local _cNroConf		:= ""

Begin Sequence
	//Verifica se foi gravado o numero de conferência
	_cNroConf := OX0020071_ExisteConferencia( _cNumOrc )
	If !Empty(_cNroConf)
		If !U_XAPAVM5VM6Carregamento(_cNumOrc)	
			ZPEC11RMsg("nosepara", "Pedido "+_cPedido+" não foi possivel atualizar carregamento no Protheus, não sera processado !")
			_lRet := .F.
			Break
		EndIf	
	EndIf
	_cNroConf := ""
	_cNroConf := VS1->(OX0020041_GravaRegistroConferencia( _cNumOrc ))
	If Empty(_cNroConf)
		ZPEC11RMsg("nosepara", "Pedido "+_cPedido+" não foi possivel atualizar carregamento no Protheus, não sera processado !")
		_lRet := .F.
		Break
	EndIf

	BeginSql Alias _cAliasPesq
		SELECT 	  VM5.VM5_NUMORC
				, VM5.VM5_CODIGO 
				, VS3.VS3_CODITE 
				, VM6.VM6_COD 
				, VM6.VM6_SEQUEN
				, VS3.VS3_SEQUEN
				, VM6.VM6_QTORIG 
				, VM6.VM6_QTCONF
				, VS3.VS3_QTDITE
				, VM5.VM5_STATUS
				, VS3.VS3_SQCONF
				, VS3.R_E_C_N_O_ NREGVS3
				, VM5.R_E_C_N_O_ NREGVM5  
				, VM6.R_E_C_N_O_ NREGVM6  
		FROM %table:VS3% VS3
		LEFT JOIN %table:VM5% VM5
			ON 	VM5.VM5_FILIAL 	= %XFilial:VM5%
			AND	VM5.VM5_NUMORC 	= VS3.VS3_NUMORC
			AND VM5.%notDel% 
		LEFT JOIN %table:VM6% VM6
			ON 	VM6.VM6_FILIAL 	= %XFilial:VM6%
			AND	VM6.VM6_CODVM5 	= VM5.VM5_CODIGO 
			AND VM6.VM6_COD		= VS3.VS3_CODITE
			AND TO_NUMBER(VM6.VM6_SEQUEN) = TO_NUMBER(VS3.VS3_SEQUEN)
			AND VM6.%notDel% 
		WHERE 	VS3.VS3_FILIAL = %XFilial:VS3%
			AND	VS3.VS3_NUMORC = %Exp:_cNumOrc%  
			AND VS3.VS3_SEQUEN <> ' '
			AND VS3.VS3_QTDITE > 0
			AND VS3.%notDel% 
		ORDER BY VS3.VS3_SEQUEN
	EndSql      
	
	//Caso existam registros preenchidos não é a carga inicial e não pode receber da RG
	If (_cAliasPesq)->(Eof()) 
		ZPEC11RMsg("noitens","Não localizado itens referente ao carregmento para o pedido "+_cPedido)
		_lRet := .F.
		Break
	EndIf
	//Localizando os registros validar de acordo com o Retorno
	(_cAliasPesq)->(DbGoTop())
	//Verifica o Status do Carregamento
	//Garanto que não vai estar sem o carregamento
	If (_cAliasPesq)->NREGVM5 == 0
		ZPEC11RMsg("nosepara", "Pedido "+_cPedido+" não possui carregamento no Protheus, não sera processado !")
		_lRet := .F.
		Break
	EndIf

	VM5->(DbGoto( (_cAliasPesq)->NREGVM5 ))
	If VM5->VM5_STATUS <> "1"
		ZPEC11RMsg("nostatusconf","Pedido "+_cPedido+" com status "+VM5->VM5_STATUS+" divergente no carregamento Protheus para item ref "+_cNumOrc+", nao sera processado !")
		_lRet := .F.
		Break
	EndIf
	While (_cAliasPesq)->(!Eof())
		If (_cAliasPesq)->NREGVM6 == 0  //Verificar se possui numero de registro DAC 04/02/2023
			ZPEC11RMsg("noseparaVM6", "Pedido "+_cPedido+" com problemas na sequencia do carregamento, verificar VS3_SQCONF, não sera processado !")
			_lRet := .F.
			Break
		EndIf
		_nRegVM6		:= (_cAliasPesq)->NREGVM6	
		VM6->(DbGoto(_nRegVM6))
		VM5->(OX0020141_GravaQtdConferida( _nRegVM6 , VM6->VM6_QTORIG, "0", (_cAliasPesq)->NREGVS3 ))
		(_cAliasPesq)->(DbSkip())
	EndDo
	//Após a Gravação Verificar se existe divergência
	//VM5->(DbGoto((_cAliasPesq)->NREGVM5))
	VM5->(OX0020131_VerificaDivergencias( VM5->VM5_CODIGO ))
	If VM5->VM5_DIVERG == "1"
		ZPEC11RMsg("divergencia","Pedido "+_cPedido+" com divergencia na separação, não sera processado !")
		_lRet := .F.
		Break
	EndIf
	VM5->(OX0020061_StatusConferencia( VM5->VM5_CODIGO , "3" ) )   //Altera Status
	If VM5->VM5_DIVERG == "0" // NAO tem Divergencia - Aprova Automaticamente
		If VM5->(OX0020161_LiberaItensConferidos( "0" ))
			VM5->(OX0020121_GravaConbar( VM5->VM5_NUMORC ))
			VM5->(OX0020061_StatusConferencia( VM5->VM5_CODIGO , "4" ))
		Else
			ZPEC11RMsg("liberacao","Pedido "+_cPedido+" não foi possivel fazer liberação na separação, não sera processado !")
			_lRet := .F.
			Break
		EndIf	
	EndIf
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet



/*/{Protheus.doc} ZPEC11LPIK
Recebe 		Verificar se ja existe picking processado na tabela SZK
@author 	DAC
@since 		23/06/2022
@version 	_cPicking
@param 		oJson
@type 		function
@ Obs		Os paremetros de token, empresa e filial serão enviados no cabeçalho reader Json
@history      
/*/
Static Function ZPEC11LPIK(_cPicking )
Local _lRet			:= .T.
Local _cAliasPesq	:= GetNextAlias()
Begin Sequence
	BeginSql Alias _cAliasPesq
		SELECT 	SZK.R_E_C_N_O_ NREGSZK
       	FROM %table:SZK% SZK
      	WHERE SZK.ZK_FILIAL  	= %XFilial:SZK%
			AND SZK.ZK_XPICKI 	= %Exp:_cPicking%
		  	AND SZK.%notDel%		  
	EndSql      
	//Alterado GAP002 28/03/2023
	//		AND SZK.ZK_STREG	<> ' '
	//If (_cAliasPesq)->(!Eof()) .or. (_cAliasPesq)->NREGSZK > 0
	//Caso existam registros preenchidos não é a carga inicial e não pode receber da RG
	If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGSZK == 0
		ZPEC11RMsg("nu_pedido","Pedido "+_cPedido+" Picking não localizado, não sera processado !")
		_lRet	:= .F.
		Break
	Endif
	While (_cAliasPesq)->(!Eof())  
		SZK->(DbGoto((_cAliasPesq)->NREGSZK)) 
		//não processar faturado, bloqueado, Cancelado e Divergência 
		If SZK->ZK_STATUS $ 'B_C_F_D'
			_lRet	:= .F.
			_cMens := If(SZK->ZK_STATUS == "B","Bloqueado",If(SZK->ZK_STATUS == "C","Cancelado",If(SZK->ZK_STATUS == "F","Faturado" ,If(SZK->ZK_STATUS == "D","Divergente","Com Problemas" ))))
			ZPEC11RMsg("nu_pedido","Pedido "+_cPicking+" "+_cMens+", não sera processado !")
			Break
		Endif
		//o STREG só é atuaiizado após a recepção do registro
		If !Empty(SZK->ZK_STREG)
			_lRet	:= .F.
			ZPEC11RMsg("nu_pedido","Pedido "+_cPicking+" ja consta no cadastro Picking como recebido, não sera processado !")
			Break
		Endif
		(_cAliasPesq)->(DbSkip())
	EndDo	
End Sequence	
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 

Return _lRet




/*/{Protheus.doc} ZPEC11VWIS
//Verificar se existem divergências na Separação 
@author DAC
@since 25/07/2023
@version undefined
@param _cPedido , _cMsgInconWis
@type function
@project	GAP002 | Integração da separação - Informar produto e quantidade da cubagem
@Obs		
/*/
Static Function	ZPEC11VWIS(_cPedido, _cMsgInconWis)
Local _cAliasPesq	:= GetNextAlias()   
Local _nPedido		:= Val(_cPedido)  //é numerico no WIS
Local _lRet			:= .F.
Local _aPedido		:= {}
Local _aStru		:= {}
Local _cMens
Local _nPos
Local _oTable
Local _cQuery

//	--CONSULTA DIVERGENCIA SEPARAÇÃO SIGAPEC X WIS --
Begin Sequence
	//Não reconhece BeginSQL
     Aadd(_aStru, { "PED"	, TamSX3("ZK_XPICKI")[3]	, TamSX3("ZK_XPICKI")[1]	, TamSX3("ZK_XPICKI")[2]	, PesqPict("SZK","ZK_XPICKI") })
     Aadd(_aStru, { "PROD"	, TamSX3("VS3_CODITE")[3]	, TamSX3("VS3_CODITE")[1]	, TamSX3("VS3_CODITE")[2]	, PesqPict("VS3","VS3_CODITE") })
     Aadd(_aStru, { "QT_WIS"	, TamSX3("VS3_QTDITE")[3]	, TamSX3("VS3_QTDITE")[1]   , TamSX3("VS3_QTDITE")[2]	, PesqPict("VS3","VS3_QTDITE") })
     Aadd(_aStru, { "QT_PROT", TamSX3("VS3_QTDITE")[3]	, TamSX3("VS3_QTDITE")[1]	, TamSX3("VS3_QTDITE")[2]	, PesqPict("VS3","VS3_QTDITE") })

    _oTable := FWTemporaryTable():New()
    _oTable:SetFields(_aStru)
    _oTable:AddIndex("INDEX1", {"PED", "PROD"} )
    _oTable:Create()
    _cAliasPesq := _oTable:GetAlias()

    _cTable := _oTable:GetRealName()

    _cQuery := " INSERT INTO "+_cTable+"                                                                                    "+(Chr(13)+Chr(10))
    _cQuery += " ("
    For _nPos := 01 To Len(_aStru)
        _cQuery += _aStru[_nPos,1]
        _cQuery += ","
    NEXT _nPos
	_cQuery := SubsTr(_cQuery,1,Len(_cQuery)-1)
    _cQuery += " ) "+ CRLF
 
    _cQuery += "		WITH SEP_WIS AS " 												+ CRLF
    _cQuery += "			(	"														+ CRLF
    _cQuery += "				SELECT 	DETWIS.NU_PEDIDO PED "							+ CRLF
    _cQuery += "					, 	CAST(DETWIS.CD_PRODUTO AS CHAR(27)) PROD "		+ CRLF
    _cQuery += "					, 	CAST(DETWIS.QT_SEPARAR AS NUMBER(38,0)) QT "	+ CRLF	
    _cQuery += "				FROM WIS.T_DET_PEDIDO_SAIDA@DBLINK_WISHML DETWIS "		+ CRLF
    _cQuery += "				WHERE DETWIS.NU_PEDIDO = "+ AllTrim(Str(_nPedido))      + CRLF
    _cQuery += "			) "															+ CRLF
    _cQuery += "			, SEP_PROT AS "												+ CRLF
    _cQuery += "			( "															+ CRLF
    _cQuery += "				SELECT 	VS3.VS3_XPICKI PED "							+ CRLF
    _cQuery += "					, 	VS3.VS3_CODITE PROD	"							+ CRLF						
    _cQuery += "					, 	SUM(VS3.VS3_QTDITE) QT	"						+ CRLF
    _cQuery += "	 			FROM "+RetSqlName("VS3")+" VS3  "						+ CRLF
    _cQuery += "				INNER JOIN "+RetSqlName("VS1")+" VS1  " 				+ CRLF
    _cQuery += "					ON	VS1.VS1_FILIAL = VS3.VS3_FILIAL "				+ CRLF
    _cQuery += "					AND VS1.VS1_NUMORC = VS3.VS3_NUMORC "				+ CRLF
    _cQuery += "					AND VS1.D_E_L_E_T_ = ' ' "							+ CRLF
    _cQuery += "				WHERE VS3.D_E_L_E_T_ = ' ' " 							+ CRLF
    _cQuery += "					AND VS3.VS3_FILIAL = '"+FwXFilial("VS3")+"' " 		+ CRLF
    _cQuery += "					AND VS3.VS3_XPICKI = '"+_cPedido+"' " 				+ CRLF
    _cQuery += "				GROUP BY VS3.VS3_XPICKI, VS3.VS3_CODITE	"				+ CRLF
    _cQuery += "			) "															+ CRLF
    _cQuery += "		SELECT MRG_PED.* "												+ CRLF
    _cQuery += "				, NVL(SEP_WIS.QT,0) QT_WIS "							+ CRLF
    _cQuery += "				, NVL(SEP_PROT.QT,0) QT_PROT "							+ CRLF
    _cQuery += "		FROM ( "														+ CRLF
    _cQuery += "				SELECT 	CAST(DETWIS.NU_PEDIDO AS VARCHAR(8)) PED "		+ CRLF		
    _cQuery += "					, 	CAST(DETWIS.CD_PRODUTO AS CHAR(27)) PROD "		+ CRLF
    _cQuery += "				FROM WIS.T_DET_PEDIDO_SAIDA@DBLINK_WISHML DETWIS "		+ CRLF
    _cQuery += "				WHERE DETWIS.NU_PEDIDO = "+ AllTrim(Str(_nPedido))      + CRLF 
    _cQuery += "				UNION "													+ CRLF		
    _cQuery += "				SELECT LTRIM(VS3.VS3_XPICKI,0) PED_PROT	"				+ CRLF
    _cQuery += "					, 	VS3.VS3_CODITE PROD_PROT "						+ CRLF
    _cQuery += "				FROM "+RetSqlName("VS3")+" VS3  " 						+ CRLF
    _cQuery += "				WHERE VS3.D_E_L_E_T_ = ' ' "							+ CRLF
    _cQuery += "					AND VS3.VS3_FILIAL = '"+FwXFilial("VS3")+"' "		+ CRLF
    _cQuery += "					AND VS3.VS3_XPICKI = '"+_cPedido+"' " 				+ CRLF
    _cQuery += "				GROUP BY VS3.VS3_XPICKI, VS3.VS3_CODITE	"				+ CRLF
    _cQuery += "	 		) MRG_PED "													+ CRLF
    _cQuery += "		LEFT JOIN SEP_WIS "												+ CRLF
    _cQuery += "			ON SEP_WIS.PROD=MRG_PED.PROD "								+ CRLF
    _cQuery += "		LEFT JOIN SEP_PROT "											+ CRLF
    _cQuery += "			ON SEP_PROT.PROD=MRG_PED.PROD "								+ CRLF
    _cQuery += "		WHERE NVL(SEP_WIS.QT,0) != NVL(SEP_PROT.QT,0) "					+ CRLF  

	nStatus := TCSqlExec(_cQuery)
    If (nStatus < 0)
		Aadd(_aMsgCAOA, Upper("[ZPECF011] Problemas na Seleção de dados, comunicar ADM SISTEMA"+ CRLF +TCSQLError()) )
		Conout("[ZPEC11VWIS] Eroor recebimento picking "+TCSQLError())
        Break    
    Endif
	
    (_cAliasPesq)->(DbGoTop())
	//não existem inconsistências	
	If (_cAliasPesq)->(Eof())
		_lRet := .T.
		Break	
	Endif 	
	_aPedido 	:= {}
	_aMsgCAOA		:= {}
	While (_cAliasPesq)->(!Eof())
		//No caso de a quantidade WIS for maior que a quantidade Protheus não deixar Prosseguir 
		If  (_cAliasPesq)->QT_WIS > (_cAliasPesq)->QT_PROT
			_cMens := "[ZPECF011] Pedido " + _cPedido
			_cMens += " ref. Produto " + AllTrim((_cAliasPesq)->PROD)
			_cMens += " com qtde WIS " + AllTrim(Str((_cAliasPesq)->QT_WIS) )
			_cMens += " maior que qtde Protheus "+ AllTrim(Str((_cAliasPesq)->QT_PROT))			
			Aadd(_aMsgCAOA, Upper(_cMens) )
			_cMsgInconWis := _cMens  //gravar no SZK e indica para atualizar status
			_lRet := .F.
			Exit	
		//Caso seja maior do que no Protheus devo criar um backorder do processo
		ElseIf  (_cAliasPesq)->QT_WIS < (_cAliasPesq)->QT_PROT
			//só adicionar uma vez se estier repetido não adicionar mais
			If Ascan(_aPedido, {|x| x[2]==(_cAliasPesq)->PROD}) == 0
				Aadd(_aPedido,{_cPedido, (_cAliasPesq)->PROD, (_cAliasPesq)->QT_WIS, (_cAliasPesq)->QT_PROT }) 
			Endif	
			_lRet := .T.
		Endif
		(_cAliasPesq)->(DbSkip())
	EndDo
	If !_lRet 
		Break
	Endif
	//Realiza as alterações como Backorder no processo

	If Len(_aPedido) > 0
		_lRet := ZPEC11BKOR(_aPedido)
	Endif
End Sequence 

If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	//Ferase(_cTable+GetDBExtension())
    _oTable:Delete()
Endif      
Return _lRet



/*/{Protheus.doc} ZPEC11BKOR
//Função para gerar BackOrder dos registros recebidos no Picking 
@author DAC
@since 28/07/2023
@version undefined
@param _aPedido
@type function
@project	GAP002 | Integração da separação - Informar produto e quantidade da cubagem
@Obs		Necessário fazer este ajuste pois os orçamentos são aglutinados para a geração do picking, podendo existir mais de um orçamento com o mesmo código
/*/
Static Function ZPEC11BKOR(_aPedido)
Local _lRet 		:= .T.
Local _cAliasPesq	:= GetNextAlias()   
Local _cCodProd 
Local _cPicking	
Local _nQtdeDivWiS 
Local _nQtdeDivPRO 
Local _nDif
Local _nSaldoWis
Local _nPos 

Begin Sequence
	For _nPos := 1 To Len(_aPedido)
		_cPicking 		:= _aPedido[_nPos,1]
		_cCodProd 		:= _aPedido[_nPos,2]
		_nQtdeDivWiS	:= _aPedido[_nPos,3]
		_nQtdeDivPRO	:= _aPedido[_nPos,4]
		_nDif  			:= _nQtdeDivPRO - _nQtdeDivWiS  //a diferença neste caso sempre será Protheus maior que WIS
		If Select((_cAliasPesq)) <> 0
			(_cAliasPesq)->(DbCloseArea())
		Endif
		BeginSql Alias _cAliasPesq
			SELECT 	VS3.VS3_NUMORC
					, VS3.VS3_CODITE
					, VS3.VS3_QTDITE
					, VS3.R_E_C_N_O_ NREGVS3
			FROM %table:VS3% VS3
			WHERE VS3.%notDel% 
				AND VS3.VS3_FILIAL = %XFilial:VS3%
				AND VS3.VS3_CODITE = %Exp:_cCodProd%
				AND VS3.VS3_XPICKI = %Exp:_cPicking% 
			ORDER BY VS3.VS3_QTDITE DESC	
		EndSql
		//Caso não localize um produto no picking abortar toda a operação
		If (_cAliasPesq)->(Eof())
			Aadd(_aMsgCAOA,"Não localizado Pedido "+_cPicking+" para o Produto "+_cCodProd)
			_lRet := .F. 
			Break
		Endif	
		//Processar podem existir mais de um orçamento pois o picking é agrupamento de orçamentos
		_nSaldoWis	:= _nQtdeDivWiS
		While (_cAliasPesq)->(!Eof())
			VS3->(DbGoto((_cAliasPesq)->NREGVS3))
			//Caso o orçamento seja maior que o Wis abater os valores
			If VS3->VS3_QTDITE > _nSaldoWis
				_lRet := ZPEC11BKRE(_nSaldoWis, _cPicking)  //tem que gerar backorder
				Exit  //ja utilizei o saldo
			//Caso o saldo wis seja menor que o orçamento o mesmo ficará não mecher somente abater da soma
		   //Caso seja o mesmo valor não fazer movimentação
			ElseIf VS3->VS3_QTDITE <= _nSaldoWis 
				_nSaldoWis -= VS3->VS3_QTDITE	
			Endif
			If _nSaldoWis <= 0
				Exit
			Endif
			(_cAliasPesq)->(DbSkip())
		EndDo 
	Next
End Sequence	
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet

/*/{Protheus.doc} ZPEC11BKRE
//Função para atualizar reserva e gerar BackOrder dos registros recebidos no Picking 
@author DAC
@since 28/07/2023
@version undefined
@param _nSaldoWis, _cPicking
@type function
@project	GAP002 | Integração da separação - Informar produto e quantidade da cubagem
@Obs		
/*/

Static Function ZPEC11BKRE(_nSaldoWis, _cPicking)
Local _lRet 		:= .T.
Local _lZera 		:= .F.	
Local _cNumOrc		:= VS3->VS3_NUMORC
Local _cCodProd		:= VS3->VS3_CODITE
Local _aBackOrder	:= {}
Local _nRegVS3		:= VS3->(Recno())	
Local _aSeqVS3 	
Local _aVS3Reg	
Local _cDocto	
Local _nRegVS1
Local _nSaldo 

Private _aReservaCAOA	:= {}
Private _aMsgCAOAAglu		:= {}

Begin Sequence 
	//montar bakOrder da diferença
	//posicionar VS1
	VS1->(DbSetOrder(1))
	VS1->(DbSeek(_cNumOrc))
	_nRegVS1 	:= VS1->(Recno())

	//Tenho que testar se esta reservado caso nã não posso retirar a reserva
	//Necessário fazer esta consistencia devido problemas no Sistema não esta atualizando campo VS3_RESERV = 1 falado com JC sobre o problema 
	//para abrir chamado pois mesmo no padrão não esta atualizando campo VS3_RESERV
	If !Empty(VS3->VS3_DOCSDB) 
		_aSeqVS3 	:= Aclone({})
		_aVS3Reg	:= Aclone({})
		_cDocto		:= ""
		Private aHeaderP    := {} // Variavel ultilizada na OX001RESITE
		aAdd(_aSeqVS3,VS3->VS3_SEQUEN)
		AAdd(_aVS3Reg,VS3->(Recno()))
		If Len(_aSeqVS3) > 0
			//retira as reservas dos itens
			//Alterado para utilizar reserva CAOA - DAC 16/08/2022
			_aReservaCAOA 	:= Aclone({_cNumOrc,.F.,_aVS3Reg})	// Variavel utilizada no PE OX001RES
			_cDocto := OX001RESITE(_cNumOrc,.F.,_aSeqVS3 )
			//_cDocto := U_XRESCAOAPEC(_cNumOrc, .F., _aSeqVS3)
			if Empty(_cDocto) .or. _cDocto == "NA"
				Aadd(_aMsgCAOA, "[ZPECF011] Não foi possivel retirar a reserva do item alterado "+AllTrim(_cCodProd)+" orçamento "+_cNumOrc+" devido a Divergencia na qtde")
				//DisarmTransaction()
				_lRet := .F.
				Break
			Endif
			//Garanto que o documento tenha sido retirado da reserva
			If _lRet .and. !Empty(VS3->VS3_DOCSDB)
				VS3->(RecLock("VS3",.F.))
				VS3->VS3_DOCSDB	:= ""
				VS3->VS3_RESERV := "0"
				VS3->(MsUnlock())
			Endif
			Aadd(_aMsgCAOA, "[ZPECF011] Retirada reserva "+_cDocto+" do item "+AllTrim(_cCodProd)+" orçamento "+_cNumOrc+" devido a Divergencia na qtde" )
		EndIf
	Else
		Aadd(_aMsgCAOA, "[ZPECF011] Não existe reserva do item "+AllTrim(_cCodProd)+" orçamento "+_cNumOrc+" para o processo de Divergencia na qtde")
	Endif

	_aSeqVS3 := {}
	_aVS3Reg := {}
	//primeiro atualizo o registro que irá ficar
	VS3->(RecLock("VS3",.F.))
	_nSaldo 		:= VS3->VS3_QTDITE - _nSaldoWis
	VS3->VS3_QTDITE := _nSaldoWis
	aAdd(_aSeqVS3, VS3->VS3_SEQUEN)
	AAdd(_aVS3Reg, VS3->(Recno()))
	//Fazer Reserva do valor atualizado
	_aReservaCAOA 	:= Aclone({_cNumOrc,.T.,_aVS3Reg})	// Variavel utilizada no PE OX001RES
	_cDocto := OX001RESITE(_cNumOrc,.T.,_aSeqVS3 )
	if Empty(_cDocto) .or. _cDocto == "NA"
		Aadd(_aMsgCAOA, "Não foi possivel criar a reserva do item alterado "+AllTrim(_cCodProd)+" orçamento "+_cNumOrc+" devido a Divergencia na qtde ")
		_lRet := .F.
		Break
	Endif
	//Garanto que o documento tenha sido retirado da reserva
	If _lRet .and. !Empty(VS3->VS3_DOCSDB)
		VS3->(RecLock("VS3",.F.))
		VS3->VS3_DOCSDB	:= _cDocto
		VS3->VS3_RESERV := "1"
		VS3->(MsUnlock())
	Endif
	Aadd(_aMsgCAOA, "[ZPECF011] Incluido reserva "+_cDocto+" do item "+AllTrim(_cCodProd)+" orçamento "+_cNumOrc+" devido a Divergencia na qtde ")
	//Peparo para gerar o Backorder da diferença
	Aadd(_aBackOrder,{VS3->(Recno()),;
	 				_cCodProd,; 
					_nSaldo,;
					"[ZPECF011] Atualização de Divergência Qtde Protheus X WIS -> "+AllTrim(Str(_nSaldoWis))+", Picking "+_cPicking+" Valor correspondente a diferença de Qtde "+AlTrim(Str(_nSaldo))+" no produto",; 
					.T. ,;							//_Lxbo 
					_lZera })					//_lZera	

	If Len(_aBackOrder) > 0
		_lRet := U_XOFUNCLO( _cNumOrc, /*_cGrupo*/, /*_cCodProd*/, /*_nQtdeItem*/, /*_lZera*/, /*_aVazioCpo*/, _aBackOrder)
		If ! _lRet
			Aadd(_aMsgCAOA,"[ZPECF011] Ocorrerão problemas para clonar itens que não possuem status para carregamento aos quais passariam para backorder")
			Break	
		EndIf
	EndIf	
	VS1->(DbGoto(_nRegVS1))

End Sequence 
VS3->(DbGoto(_nRegVS3))
Return _lRet





/*/{Protheus.doc} ValidOJson
Valida os dados do oJson
@author DAC - Denilso
@since 
@version undefined
@param _oJson, _cTipo
@param cMsg, characters, descricao
@type function
/*/
Static Function ValidOJson(_oJson, _cTipo)
Local _lRet			:= .T.
Begin Sequence

	If !ZPEC11Obri(_oJson)  //Tem a função de validar os itens obrigatórios neste caso o vabeçalho
		_lRet := .F.
		Break
	EndIf	
End Sequence
Return _lRet



/*/{Protheus.doc} ZPEC11Obri
//Verifica informações de campos obrigatórios 
@author DAC
@since 12/11/2021
@version undefined
@param _oJson, _lItem, _lTodos
@type function
/*/
Static Function ZPEC11Obri(_oJson, _lItem, _lTodos)
Local _lRet 	:= .T.
Local _xVar
Local _nPos
Local _cMsgRet
Local _nRet

Default _lItem 	:= .F.  //identifica se lera item ou cabeçalho
Default _lTodos	:= .F.	//determina se retornara todos os erros obrigatórios e ou somente o primeiro erro com obrigatório

Begin Sequence
	For _nPos := 1 To Len(_aRetMsg)
		//Caso seja obrigatório devo verificar se item ou cabeçalho  
		If _aRetMsg[_nPos,4] .And. ;
			((!_lItem .And. !_aRetMsg[_nPos,3]) .Or. (_lItem .And. _aRetMsg[_nPos,3]))  
			//armazeno em uma variavel para validar
			_xVar := _oJson:GetJsonText(_aRetMsg[_nPos,2])
			If ValType(_xVar) == "N" .and. _xVar == 0
				_lRet := .F.
			ElseIf ValType(_xVar) == "L" .and. Empty(_xVar) 
				_lRet := .F.
			ElseIf Empty(_xVar)
				_lRet := .F.
			EndIf
		EndIf
		If !_lRet
			_nRet := _aRetMsg[_nPos,1] 
			_cMsgRet := "Tag "+ _aRetMsg[_nPos,2]+" não esta preenchido !"	
			If Len(_aRetMsg[_nPos]) >= 5 .and. ValType(_aRetMsg[_nPos,5]) == "C" .and. !Empty(_aRetMsg[_nPos,5])
				_cMsgRet += " Ref. : "+_aRetMsg[_nPos,5]+" !" 
			EndIf
			Aadd(_aMsgRet, {_nRet,_cMsgRet})
			If !_lTodos  //verifica se lera todos os obrigatórios
				Break
			EndIF
		EndIf
	Next 			
End Sequence
Return _lRet


/*/{Protheus.doc} ZPEC11RMsg
//Retorna Numero do Erro 
@author DAC
@since 12/11/2021
@version undefined
@param _cRefMsg, _cMsgRet
@type function
/*/
Static Function ZPEC11RMsg(_cRefMsg, _cMsgRet)
Local _nRet := 999
Local _nPos

Default _cMsgRet := ""

Begin Sequence
  	_nPos := Ascan(_aRetMsg,{|x| x[2] == _cRefMsg})
	If _nPos > 0 
		_nRet := _aRetMsg[_nPos,1]
	EndIf	
	If Empty(_cMsgRet) .and. Len(_aRetMsg[_nPos]) >= 5 .and. ValType(_aRetMsg[_nPos,5]) == "C"
		_cMsgRet := _aRetMsg[_nPos,5]+" !"
	Endif	
	Aadd(_aMsgRet, {_nRet,_cMsgRet})
	Conout("ZWSR009 - [ZPECF011] "+_cMsgRet)
End Sequence
Return _nRet

/*/{Protheus.doc} ZPEC11AMsg
//Carrega Numero do Erro para retorno
@author DAC
@since 12/11/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/
Static Function ZPEC11AMsg()
Local _aRet := {}
Begin Sequence
	//			Nr Ret	Tags Json				Item	Obrig	Descrição	
	Aadd(_aRet, {100,	"ok"					, .F.	, .F., 	"Processo realizado com sucesso"})

	Aadd(_aRet, {400,	"usuario"				, .F.	, .T., 	"Usuario"})
	Aadd(_aRet, {401,	"senha"					, .F.	, .T., 	"Senha"})

	Aadd(_aRet, {600,	"nu_pedido"				, .T.	, .T., 	"Numero do pedido"})
	Aadd(_aRet, {601,	"cd_situacao"			, .T.	, .T., 	"Código da situação do pedido"})
	Aadd(_aRet, {602,	"vol_barcode"			, .T.	, .F., 	"Código de barras volume"})
	Aadd(_aRet, {603,	"vol_sequencia"			, .T.	, .T., 	"Volume x de y"})
	Aadd(_aRet, {604,	"vol_comprimento"		, .T.	, .T., 	"Comprimento do volume"})
	Aadd(_aRet, {605,	"vol_largura"			, .T.	, .T., 	"Largura do volume"})
	Aadd(_aRet, {606,	"vol_altura"			, .T.	, .T., 	"Altura do volume"})
	Aadd(_aRet, {607,	"vol_peso_liquido"		, .T.	, .T., 	"Peso liquido do volume"})
	Aadd(_aRet, {608,	"ps_volume"				, .T.	, .T., 	"Peso bruto do volume"})
	Aadd(_aRet, {609,	"vl_cubagem"			, .T.	, .T., 	"Valor da cubagem do volume"})
	Aadd(_aRet, {610,	"nu_serie_produto"		, .T.	, .F., 	"Número de série"})
	Aadd(_aRet, {611,	"ds_observacao"			, .T.	, .F., 	"Obs conferente"})
	Aadd(_aRet, {612,	"nexistepick"			, .F.	, .F., 	"Não localizado numero de Pedido"})
	Aadd(_aRet, {613,	"nostatusconf"			, .F.	, .F., 	"Status Separação invalido para conferência"})
	Aadd(_aRet, {613,	"noseparaVM6"			, .F.	, .F., 	"Sequencia Separação invalida entre conferência e PEdido"})
	Aadd(_aRet, {614,	"nostatusorc"			, .F.	, .F., 	"Status Separação invalido para pedido"})
	Aadd(_aRet, {615,	"divergencia"			, .F.	, .F., 	"Divergencia na separação"})
	Aadd(_aRet, {616,	"liberacao"				, .F.	, .F., 	"Problemas com liberação na separação"})
	Aadd(_aRet, {617,	"nosepara"				, .F.	, .F., 	"Não possui carregamento no Protheus"})
	Aadd(_aRet, {618,	"noitens"				, .F.	, .F., 	"Não localizado itens para carregamento no Protheus"})

End Sequence
Return _aRet


/*
nu_pedido_origem		Número do pedido
cd_situacao				Código da situação do pedido
vol_barcode				Código de barras volume
vol_sequencia			Volume x de y
vol_comprimento			Comprimento do volume
vol_largura				Largura do volume
vol_altura				Altura do volume
vol_peso_liquido		Peso liquido do volume
ps_volume				Peso bruto do volume 
vl_cubagem				Valor da cubagem do volume
nu_serie_produto		Número de série
ds_obs_conferente		Obs conferente 
*/


/*/{Protheus.doc} SetMsgRet
Seta mensagem retorno de msg do rest
@author DAC
@since 01/05/2021
@version undefined
@param 
@type function
/*/
Static function SetMsgRet() 
Local _nMsg  := 999
Local _cMsg  := ""
Local _nPos

Begin Sequence
	If Len(_aMsgRet) == 0  //caso não venha com nenhuma msg
		_nMsg	:= 999
		_cMsg	:= "problemas na identificaçao do erro, não processado !"
	ElseIf	Len(_aMsgRet) > 1 //caso seja mais de uma msg enviar os erros aglupados nas msgs
		_nMsg	:= 999
		_cMsg	:= ""
		For _nPos := 1 To Len(_aMsgRet)
			_cMsg += StrZero(_aMsgRet[_nPos,1],3)+ " " +_aMsgRet[_nPos,2]
			_cMsg +=  " - " //CRLF
		Next	
	Else
		_nMsg  := _aMsgRet[1,1]
		_cMsg  := _aMsgRet[1,2]
	Endif
End Sequence
Return {_nMsg,EncodeUtf8(_cMsg)}
//Return {"Code":_nMsg,"detailedMessage": "","message":EncodeUtf8(_cMsg)}




/*
{ "usuario": "RGLOG.REST",
	"senha": "CaOa!RgLogRest@2021*",
	"nu_pedidoorigem": [{
		"nu_pedido": "00000510",
		"cd_situacao": "001",
		"vol_barcode": null,
		"vol_sequencia": 1.00,
		"vol_qtde_total": 3.00,
		"vol_comprimento": 0.55,
		"vol_largura": 0.60,
		"vol_altura": 1.175,
		"vol_pesoliquido": 109.80,
		"ps_volume": 116.325,
		"vl_cubagem": 0.388,
		"nu_serie_produto": "SQRE4T15BBBMD00925",
		"ds_observacao": "pedido separado "
	}]
}
*/
