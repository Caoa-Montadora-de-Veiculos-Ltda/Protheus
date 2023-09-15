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
Local _lDivergencia := .F.
Local _lDivergeWis  := .F.
Local _cMsgInconWis := ""
Local _lCancela 	:= .F.
Local _cFaseCancela := "0"
Local _aMsg			:= {}
Local _aRegVS1		:= {}
Local _cQueryUPD
Local _nPos
Local _cPicking
Local _cJson

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
	_lRet := ZPEC11GPIK(@_oJson,"I", @_aRegVS1, @_lDivergencia)
	If !_lRet 
		Break
	EndIf
End Sequence

//neste caso deverei gravar as informações dos erros em todos os orçamentos que confiveram erro
_cPicking 	:= AllTrim(_oJson["nu_pedidoorigem"][1]:GetJsonText("nu_pedido")) //"00000510"
//Gravar observação
_cObs		:= "[ZPECF011] RETORNO DE SEPARAÇÃO RG LOG "+If(!_lRet,"APRESENTOU PROBLEMAS ","")+" REFERENTE PICKING "+_cPicking+" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5)+ CRLF		
_cObs 		+= "Status " + CRLF
For _nPos := 1 To Len(_aMsgRet)
	//GAP002 quando posui divergencia com Wis tem que atualizar Picking e alterar código pois não possuem este código para retorno 800, passar para 615
	If _lDivergencia    
		_lDivergeWis 	:= .T.
		_cMsgInconWis	:= Upper(If(Len(_aMsgRet[_nPos,2]) > 100,SubsTr(_aMsgRet[_nPos,2],1,100),_aMsgRet[_nPos,2]))
		//_aMsgRet[_nPos,1] := 615
	Endif
	_cObs += _aMsgRet[_nPos,2] + CRLF
Next
If Len(_aMsgCaoa) > 0 
	_cObs += "Processo" + CRLF
	For _nPos := 1 To Len(_aMsgCaoa)
		_cObs += "[ZPECF011] "+_aMsgCaoa[_nPos] + CRLF
	Next
Endif 
_cObs := Upper(_cObs)
Conout(_cObs)

_cJson 	:= _oJson:toJSON()
_cJson 	:= EncodeUTF8( _cJson )

//GAP002 Caso possua divergencia na quantidade WIS maior não deixar utilizar picking alterar status para D=Divergência WIS
If !_lRet .Or. _lDivergeWis
	//Atualizar Status SZK, não será mais atualizado este picking
	_cQueryUPD := " UPDATE " + RetSqlName("SZK") + " SZK " + CRLF 
	_cQueryUPD += " SET  SZK.ZK_XJSSTRE = '3' " + CRLF  //1=RECEBIDO;2=NAO RECEBIDO;3=INCONSISTENCIA
	If _lDivergeWis
		_cQueryUPD += " 	,SZK.ZK_STATUS 	= 'D'
		_cQueryUPD += " 	,SZK.ZK_OBSCON  = '"+_cMsgInconWis+"' " + CRLF
	Endif 
	_cQueryUPD += " 	,SZK.ZK_XJSREC 	= RAWTOHEX('"+_cJson+ chr(13) + chr(10) +"' ||  NVL(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(SZK.ZK_XJSREC 	, 2000, 1)),' ') )" + CRLF
	//Campo informações sobre processamento SZK
	If SZK->(FieldPos("ZK_INFO")) > 0
		_cQueryUPD += " 	,SZK.ZK_INFO 	= RAWTOHEX('"+_cObs+ chr(13) + chr(10) +"' ||  NVL(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(SZK.ZK_INFO 	, 2000, 1)),' ') )" + CRLF
	Endif
	_cQueryUPD += " WHERE SZK.ZK_FILIAL='" + xfilial("SZK") + "' AND  SZK.ZK_XPICKI = '"+_cPicking+"' " + CRLF

	_nStatus := TcSqlExec(_cQueryUPD)
	if (_nStatus < 0)
		_lRet := .F.
 		ZPEC11RMsg("divergencia", "Não foi possivel gravar Status divergencia WIS")
 		Conout( "[ZPECF011] Não foi possivel gravar Status divergencia WIS, ERRO UPD SZK "+TCSQLError())
	Endif
	//Se estiver com divergência cancelar picking
	If _lDivergeWis
		_lCancela := U_XAPAGAPicking(_cPicking, _cFaseCancela, .F. /*_lMsg*/, @_aMsg)
		If !_lCancela
			_cObs += "Não foi possivel cancelar o Picking "+_cPicking+" o mesmo estara com inciação de divergente (Status = D) verificar " 
		Endif
	Endif 	 
Endif

//Existindo orçamentos gravar mensagens
//NO CASO DE ERRO E TENHA PROCESSADO ALGUM ORÇAMENTO IRA RETORNAR OS PROBLEMAS ENCONTRADOS
If Len(_aRegVS1) > 0
	//Gravar em todos os orçamentos
	For _nPos := 1 To Len(_aRegVS1)
		VS1->(DbGoto(_aRegVS1[_nPos]))
		VS1->(RecLock("VS1",.F.))
		VS1->VS1_OBSAGL	:= Upper(_cObs) + CRLF + VS1->VS1_OBSAGL
		//Garantir que deixara os orçamentos com a fase anterior que é de conferência DAC 29/06/2022
		//If !_lRet .And. VS1->VS1_STATUS <> _cFaseConf
		//	VS1->VS1_STATUS := _cFaseConf  //volto a fase anterior
		//Endif	
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
Static Function ZPEC11GPIK(_oJson, _cTipo, _aRegVS1, _lDivergencia )
Local _lRet			:= .F.
Local _cAlias 		:= GetNextAlias()
Local _cPicking		:= ""
Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local _cFaseFat		:= "F"
Local _cObs			:= ""
Local _aMsgCAOA		:= {}
Local _aOrc			:= {}
Local _lFatAutomatico  := SuperGetMV( "CMV_PEC045"  ,,.F.)  //"WIS.T_DET_PEDIDO_SAIDA@DBLINK_WISHML"

Local _nPos

Begin Sequence
	//_nPos := _oJson["nu_pedidoorigem"][1]:GetJsonText("nu_pedido")
	// numero do pedido
	DbSelectArea("SZK")
	_cPicking 	:= AllTrim(_oJson["nu_pedidoorigem"][1]:GetJsonText("nu_pedido")) 
	If !ZPEC11LPIK( _cPicking ) 
		//GAP002 tratar além de processado se esta bloqueado cancelado
		//ZPEC11RMsg("nu_pedido","Pedido "+_cPicking+" ja consta no cadastro Picking como recebido, não sera processado !")
		Break
	EndIf

	BeginSql Alias _cAlias
		SELECT 	VS1.R_E_C_N_O_ NREGVS1
       	FROM %table:VS1% VS1
       	WHERE VS1.VS1_FILIAL  	= %XFilial:VS1%
			AND VS1.VS1_XPICKI 	= %Exp:_cPicking%
		  	AND VS1.%notDel%		  
	EndSql      
	If (_cAlias)->(Eof()) 	
		ZPEC11RMsg("nexistepick","Pedido "+_cPicking+" não localizou itens !")
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
			ZPEC11RMsg("nostatusorc","Item do Pedido "+_cPicking+" correspondente a numeração "+VS1->VS1_NUMORC+" com fase "+VS1->VS1_STATUS+", diferente de Separação, não sera processado !")
			Break
		EndIf
	Next

	//Controlar a gravação dos dados do orçamento caso tenha 
	Begin Transaction 
		_lRet := ZPEC11VWIS(_cPicking, @_lDivergencia)
		//DAC Selecionar processo VS5 e VS6 de carregamento e efetuar baixa
		//SE NÃO TIVER PASSAR PARA PROXIMO REGISTRO
		If _lRet 
			For _nPos := 1 To Len(_aRegVS1)
				VS1->(DbGoto(_aRegVS1[_nPos]))
				_lRet := ZPEC11Separa(VS1->VS1_NUMORC, _cPicking)
		
				If ! _lRet
					Exit  //sair do for
				Endif
				_cObs 	:= "Gravado a conferência (VM5) para os itens de separação  corretamente no recebimento do REST, para o orçamento "+VS1->VS1_NUMORC 
				Aadd(_aMsgCAOA, Upper(_cObs) )

				//efetua a gravação da tabela para controle de picking obtenção de pesos e medidas para a nota
				_lRet := U_ZPEC11GSZK(_oJson, /*_lGravaIni*/, _cPicking, /*_cObsMenNF*/, /*_cMarca*/, _lRet)
				If ! _lRet
					_cObs	:= "OCORREU PROBLEMAS NO RETORNO DE SEPARAÇÃO REFERENTE PEDIDO "+_cPicking+", PARA O ORÇAMENTO "+VS1->VS1_NUMORC+" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5)+" NÃO FOI GRAVADO" 
					ZPEC11RMsg("divergencia",_cObs)  
					ZPEC11EMAI({_cObs}, _cPicking ) //ENVIA EMAIL COM PROBLEMA
					Exit  //sair do for
				Endif
				_cObs	:= "RETORNO DE SEPARAÇÃO REFERENTE PICKING "+_cPicking+", PARA O ORÇAMENTO "+VS1->VS1_NUMORC+" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5) 
				Aadd(_aMsgCAOA, Upper(_cObs) )

				//Gravar como liberado para faturar
				VS1->(RecLock("VS1",.F.))
				VS1->VS1_STATUS := _cFaseFat
				//VS1->VS1_OBSAGL	:= Upper(_cObs) +CRLF+ VS1->VS1_OBSAGL  //GAP002 será gravado posteriormente _aMsgCAOA
				VS1->(MsUnLock())

				//Gravo dados necessário para o VS1 orçamento
				//Atualiza TES Inteligente
				If !U_ZPECREGFI(_cPicking, VS1->VS1_NUMORC) //cZK_XPICKI _cPicking
					_cObs		:= 	"ERRO NA ATUALIZAÇÃO TES INTELIGENTE NO PICKING "+_cPicking+" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5)
					ZPEC11EMAI({_cObs}, _cPicking )  //ENVIA E-MAIL
					Aadd(_aMsgCAOA, Upper(_cObs) )  //GUARDA MENSAGEM  PARA GRAVAR NO ORÇAMENTO
				EndIf
			Next	 	 
		Endif 
		//Caso tenha dado problema abortar
		If !_lRet	
			Disarmtransaction()
		Endif
	End Transaction 

    //Após receber tenho que tentar faturar, porém caso ocorra problemas os mesmos não retornarão para RGLOG pois ja foi recebido o picking
	If _lRet  .And. _lFatAutomaTico
		_aOrc := {}
		//a funcionalidade de faturamento somente recebe dados relativos ao numero de orçamento
		For _nPos := 1 To Len(_aRegVS1)
			VS1->(DbGoto(_aRegVS1[_nPos]))
			Aadd(_aOrc,VS1->VS1_NUMORC)
		Next 
		U_ZPECF036(_aOrc, _cPicking, /*ENVIA EMAIL*/, /*Indica para não utilizar transaction*/)
	Endif

End Sequence

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
Static Function ZPEC11Separa( _cNumOrc, _cPicking )
Local _lRet			:= .T.
Local _cAliasPesq	:= GetNextAlias()
Local _cNroConf		:= ""

Begin Sequence
	//Verifica se foi gravado o numero de conferência
	_cNroConf := OX0020071_ExisteConferencia( _cNumOrc )
	If !Empty(_cNroConf)
		If !U_XAPAVM5VM6Carregamento(_cNumOrc)	
			ZPEC11RMsg("nosepara", "Pedido "+_cPicking+" não foi possivel atualizar carregamento no Protheus, não sera processado !")
			_lRet := .F.
			Break
		EndIf	
	EndIf
	_cNroConf := ""
	_cNroConf := VS1->(OX0020041_GravaRegistroConferencia( _cNumOrc ))
	If Empty(_cNroConf)
		ZPEC11RMsg("nosepara", "Pedido "+_cPicking+" não foi possivel atualizar carregamento no Protheus, não sera processado !")
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
		ZPEC11RMsg("noitens","Não localizado itens referente ao carregmento para o pedido "+_cPicking)
		_lRet := .F.
		Break
	EndIf
	//Localizando os registros validar de acordo com o Retorno
	(_cAliasPesq)->(DbGoTop())
	//Verifica o Status do Carregamento
	//Garanto que não vai estar sem o carregamento
	If (_cAliasPesq)->NREGVM5 == 0
		ZPEC11RMsg("nosepara", "Pedido "+_cPicking+" não possui carregamento no Protheus, não sera processado !")
		_lRet := .F.
		Break
	EndIf

	VM5->(DbGoto( (_cAliasPesq)->NREGVM5 ))
	If VM5->VM5_STATUS <> "1"
		ZPEC11RMsg("nostatusconf","Pedido "+_cPicking+" com status "+VM5->VM5_STATUS+" divergente no carregamento Protheus para item ref "+_cNumOrc+", nao sera processado !")
		_lRet := .F.
		Break
	EndIf
	While (_cAliasPesq)->(!Eof())
		If (_cAliasPesq)->NREGVM6 == 0  //Verificar se possui numero de registro DAC 04/02/2023
			ZPEC11RMsg("noseparaVM6", "Pedido "+_cPicking+" com problemas na sequencia do carregamento, verificar VS3_SQCONF, não sera processado !")
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
		ZPEC11RMsg("divergencia","Pedido "+_cPicking+" com divergencia na separação, não sera processado !")
		_lRet := .F.
		Break
	EndIf
	VM5->(OX0020061_StatusConferencia( VM5->VM5_CODIGO , "3" ) )   //Altera Status
	If VM5->VM5_DIVERG == "0" // NAO tem Divergencia - Aprova Automaticamente
		If VM5->(OX0020161_LiberaItensConferidos( "0" ))
			VM5->(OX0020121_GravaConbar( VM5->VM5_NUMORC ))
			VM5->(OX0020061_StatusConferencia( VM5->VM5_CODIGO , "4" ))
		Else
			ZPEC11RMsg("liberacao","Pedido "+_cPicking+" não foi possivel fazer liberação na separação, não sera processado !")
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
		ZPEC11RMsg("nu_pedido","Pedido "+_cPicking+" Picking não localizado, não sera processado !")
		_lRet	:= .F.
		Break
	Endif
	While (_cAliasPesq)->(!Eof())  
		SZK->(DbGoto((_cAliasPesq)->NREGSZK)) 
		//não processar faturado, bloqueado, Cancelado e Divergência 
		If !SZK->ZK_STATUS $ 'E_R'  //SZK->ZK_STATUS $ 'B_C_F_D'   //GAP002
			_lRet	:= .F.
			_cMens := If(SZK->ZK_STATUS == "B","Bloqueado",If(SZK->ZK_STATUS == "C","Cancelado",If(SZK->ZK_STATUS == "F","Faturado" ,If(SZK->ZK_STATUS == "D","Divergente WIS"," "+SZK->ZK_STATUS ))))
			ZPEC11RMsg("nu_pedido","Pedido "+_cPicking+" com status "+_cMens+", não sera processado !")
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
@param _cPicking 
@type function
@project	GAP002 | Integração da separação - Informar produto e quantidade da cubagem
@Obs		
/*/
Static Function	ZPEC11VWIS(_cPicking, _lDivergencia)
Local _cAliasPesq		:= GetNextAlias()   
Local _nPedido			:= Val(_cPicking)  //é numerico no WIS
Local _cConectDetWis   	:= AllTrim(SuperGetMV( "CMV_PEC044"  ,,""))  //"WIS.T_DET_PEDIDO_SAIDA@DBLINK_WISHML"
Local _cConectCabWis   	:= AllTrim(SuperGetMV( "CMV_PEC046"  ,,""))  //"WIS.T_CAB_PEDIDO_SAIDA@DBLINK_WISHML"
Local _lRet				:= .F.
Local _aDiverge			:= {}
Local _aStru			:= {}
//Local _aMsgRet 	       	:= {}
Local _aMsg				:= {}
Local _lAborta 			:= .F.
Local _lProcessa 		:= .F.
Local _cErro			:= "" 
Local _lQtdWIS			:= .F.
Local _lQtdPRT			:= .F.
Local _cMens
Local _nPos
Local _oTable
Local _cQuery

Default _lDivergencia 	:= .F.


//	--CONSULTA DIVERGENCIA SEPARAÇÃO SIGAPEC X WIS --
Begin Sequence
	If Empty(_cConectDetWis)
		_lRet	:= .F.
		ZPEC11RMsg("conexaowis","Problemas conexão com WIS, não sera processado !")
		//Enviar Email
		ZPEC11EMAI({"Parâmetro CMV_PEC044 de conexão WIS não informado"}, _cPicking )
		Break
	Endif
	If Empty(_cConectCabWis)
		_lRet	:= .F.
		ZPEC11RMsg("conexaowis","Problemas conexão com WIS, não sera processado !")
		//Enviar Email
		ZPEC11EMAI({"Parâmetro CMV_PEC046 de conexão WIS não informado"}, _cPicking )
		Break
	Endif

	//Não reconhece BeginSQL
     Aadd(_aStru, { "PED"		, TamSX3("ZK_XPICKI")[3]	, TamSX3("ZK_XPICKI")[1]	, TamSX3("ZK_XPICKI")[2]	, PesqPict("SZK","ZK_XPICKI") })
     Aadd(_aStru, { "PROD"		, TamSX3("VS3_CODITE")[3]	, TamSX3("VS3_CODITE")[1]	, TamSX3("VS3_CODITE")[2]	, PesqPict("VS3","VS3_CODITE") })
     Aadd(_aStru, { "QT_PROT"	, TamSX3("VS3_QTDITE")[3]	, TamSX3("VS3_QTDITE")[1]	, TamSX3("VS3_QTDITE")[2]	, PesqPict("VS3","VS3_QTDITE") })
     Aadd(_aStru, { "QT_WIS"	, TamSX3("VS3_QTDITE")[3]	, TamSX3("VS3_QTDITE")[1]   , TamSX3("VS3_QTDITE")[2]	, PesqPict("VS3","VS3_QTDITE") })

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
 
 //Alterado conforme Select enviado por Zé em 31/08/2023 para ajuste de corte 
//--CONSULTA DIVERGENCIA SEPARAÇÃO SIGAPEC X WIS -- V2
	//--SEPARAÇÃO_WIS
    _cQuery += "		WITH SEP_WIS AS" 														+ CRLF
    _cQuery += "			( "																	+ CRLF
    _cQuery += "				SELECT CABWIS.NU_PEDIDO PED "									+ CRLF					
    _cQuery += "						, DETWIS.CD_PRODUTO PROD "								+ CRLF
    _cQuery += "						, DETWIS.QT_SEPARAR-CASE WHEN (DETWIS.QT_CANCELADA IS NOT NULL OR DETWIS.ID_CORTE = 'X') THEN DETWIS.QT_SEPARAR ELSE 0 END AS CONF " + CRLF
//    _cQuery += "				FROM WIS.T_DET_PEDIDO_SAIDA@DBLINK_WISHML DETWIS "		+ CRLF
	_cQuery += " 				FROM " 		 + _cConectDetWis + " DETWIS "						+ CRLF
//    _cQuery += "				INNER JOIN WIS.T_CAB_PEDIDO_SAIDA@DBLINK_WISHML CABWIS ON CABWIS.CD_EMPRESA=DETWIS.CD_EMPRESA AND DETWIS.NU_PEDIDO = CABWIS.NU_PEDIDO AND CABWIS.CD_CLIENTE = DETWIS.CD_CLIENTE
	_cQuery += " 				INNER JOIN " + _cConectCabWis + " CABWIS "						+ CRLF
	_cQuery += "  					ON  CABWIS.CD_EMPRESA	= DETWIS.CD_EMPRESA "				+ CRLF
	_cQuery += "					AND DETWIS.NU_PEDIDO 	= CABWIS.NU_PEDIDO "				+ CRLF
	_cQuery += "					AND CABWIS.CD_CLIENTE 	= DETWIS.CD_CLIENTE "				+ CRLF
    _cQuery += "				WHERE 	DETWIS.DT_UPROW 	>= TO_DATE('2022-05-22','YYYY-MM-DD') " + CRLF
    _cQuery += "					AND CABWIS.NU_PEDIDO 	= "+ AllTrim(Str(_nPedido))    		+ CRLF 
    _cQuery += "				ORDER BY PED DESC " 											+ CRLF
    _cQuery += "			)

//--SEPARAÇÃO PROTHEUS
    _cQuery += ", SEP_PROT AS "																	+ CRLF
    _cQuery += " ( "																			+ CRLF
    _cQuery += "	SELECT 	VS3.VS3_XPICKI PED "												+ CRLF
    _cQuery += "			, VS3.VS3_CODITE PROD "												+ CRLF 
    _cQuery += "			, SUM(VS3.VS3_QTDITE) QT "											+ CRLF	
    _cQuery += "	FROM "+RetSqlName("VS3")+" VS3  "											+ CRLF
    _cQuery += "	INNER JOIN "+RetSqlName("VS1")+" VS1  " 									+ CRLF
    _cQuery += " 		ON  VS1_FILIAL 		= VS3_FILIAL "										+ CRLF
    _cQuery += "	 	AND VS1_NUMORC 		= VS3_NUMORC "										+ CRLF
    _cQuery += "		AND VS1.D_E_L_E_T_ 	= ' ' "												+ CRLF
    _cQuery += "	WHERE VS3.D_E_L_E_T_ 	= ' ' "												+ CRLF
    _cQuery += "		AND VS3.VS3_FILIAL 	= '"+FwXFilial("VS3")+"' " 							+ CRLF
    _cQuery += "		AND VS3.VS3_XPICKI 	= '"+_cPicking+"' " 								+ CRLF
    _cQuery += "		GROUP BY VS3.VS3_XPICKI, VS3.VS3_CODITE "								+ CRLF
    _cQuery += " ) " 																			+ CRLF										

    _cQuery += " SELECT DISTINCT MRG_PED.* "													+ CRLF
    _cQuery += "				, NVL(SEP_PROT.QT,0) QT_PROT "									+ CRLF
	_cQuery += "				, NVL(SEP_WIS.CONF,0) QT_WIS "									+ CRLF
	_cQuery += " FROM ( "																		+ CRLF
	_cQuery += "		SELECT 	CAST(DETWIS.NU_PEDIDO AS VARCHAR(8)) PED "						+ CRLF
	_cQuery += "				,CAST(DETWIS.CD_PRODUTO AS CHAR(27)) PROD "						+ CRLF
	_cQuery += " 		FROM " 		 + _cConectDetWis + " DETWIS "								+ CRLF
	_cQuery += "		WHERE DETWIS.DT_UPROW 		>= TO_DATE('2022-05-22','YYYY-MM-DD') " 	+ CRLF
	_cQuery += "			AND DETWIS.NU_PEDIDO 	= "+ AllTrim(Str(_nPedido))      			+ CRLF	//--AND DETWIS.CD_PRODUTO = 'R-59122SC041'
	//--VALIDAÇÃO DE PARIDADE DE LINHAS
	_cQuery += "		UNION "																	+ CRLF	
	_cQuery += "		SELECT LTRIM(VS3.VS3_XPICKI,0) PED_PROT, VS3.VS3_CODITE PROD_PROT "		+ CRLF
    _cQuery += "		FROM "+RetSqlName("VS3")+" VS3  "										+ CRLF
    _cQuery += "		WHERE VS3.D_E_L_E_T_ 	= ' ' "											+ CRLF
    _cQuery += "			AND VS3.VS3_FILIAL 	= '"+FwXFilial("VS3")+"' " 						+ CRLF
    _cQuery += "			AND VS3.VS3_XPICKI 	= '"+_cPicking+"' " 							+ CRLF
    _cQuery += "		GROUP BY VS3.VS3_XPICKI, VS3.VS3_CODITE "								+ CRLF
    _cQuery += "	 ) MRG_PED "																+ CRLF
    _cQuery += "LEFT JOIN SEP_WIS "																+ CRLF
    _cQuery += "	ON LTRIM(RTRIM(SEP_WIS.PROD))=LTRIM(RTRIM(MRG_PED.PROD)) "					+ CRLF
    _cQuery += "LEFT JOIN SEP_PROT "															+ CRLF
    _cQuery += "	ON LTRIM(RTRIM(SEP_PROT.PROD))=LTRIM(RTRIM(MRG_PED.PROD)) "					+ CRLF
//--WHERE NVL(SEP_WIS.CONF,'0') != NVL(SEP_PROT.QT,'0')
    _cQuery += "ORDER BY MRG_PED.PED "															+ CRLF
			
//Alterado conforme acima DAC 31/08/2023
/* 
    _cQuery += "		WITH SEP_WIS AS " 												+ CRLF
    _cQuery += "			(	"														+ CRLF
    _cQuery += "				SELECT 	DETWIS.NU_PEDIDO PED "							+ CRLF
    _cQuery += "					, 	CAST(DETWIS.CD_PRODUTO AS CHAR(27)) PROD "		+ CRLF
    _cQuery += "					, 	CAST(DETWIS.QT_SEPARAR AS NUMBER(38,0)) QT "	+ CRLF	
//    _cQuery += "				FROM WIS.T_DET_PEDIDO_SAIDA@DBLINK_WISHML DETWIS "		+ CRLF
										
	_cQuery += " 				FROM " + _cConectWis + " DETWIS "						+ CRLF
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
    _cQuery += "					AND VS3.VS3_XPICKI = '"+_cPicking+"' " 				+ CRLF
    _cQuery += "				GROUP BY VS3.VS3_XPICKI, VS3.VS3_CODITE	"				+ CRLF
    _cQuery += "			) "															+ CRLF
    _cQuery += "		SELECT MRG_PED.* "												+ CRLF
    _cQuery += "				, NVL(SEP_WIS.QT,0) QT_WIS "							+ CRLF
    _cQuery += "				, NVL(SEP_PROT.QT,0) QT_PROT "							+ CRLF
    _cQuery += "		FROM ( "														+ CRLF
    _cQuery += "				SELECT 	CAST(DETWIS.NU_PEDIDO AS VARCHAR(8)) PED "		+ CRLF		
    _cQuery += "					, 	CAST(DETWIS.CD_PRODUTO AS CHAR(27)) PROD "		+ CRLF
    //_cQuery += "				FROM WIS.T_DET_PEDIDO_SAIDA@DBLINK_WISHML DETWIS "		+ CRLF
	_cQuery += " 				FROM " + _cConectWis + " DETWIS "						+ CRLF

    _cQuery += "				WHERE DETWIS.NU_PEDIDO = "+ AllTrim(Str(_nPedido))      + CRLF 
    _cQuery += "				UNION "													+ CRLF		
    _cQuery += "				SELECT LTRIM(VS3.VS3_XPICKI,0) PED_PROT	"				+ CRLF
    _cQuery += "					, 	VS3.VS3_CODITE PROD_PROT "						+ CRLF
    _cQuery += "				FROM "+RetSqlName("VS3")+" VS3  " 						+ CRLF
    _cQuery += "				WHERE VS3.D_E_L_E_T_ = ' ' "							+ CRLF
    _cQuery += "					AND VS3.VS3_FILIAL = '"+FwXFilial("VS3")+"' "		+ CRLF
    _cQuery += "					AND VS3.VS3_XPICKI = '"+_cPicking+"' " 				+ CRLF
    _cQuery += "				GROUP BY VS3.VS3_XPICKI, VS3.VS3_CODITE	"				+ CRLF
    _cQuery += "	 		) MRG_PED "													+ CRLF
    _cQuery += "		LEFT JOIN SEP_WIS "												+ CRLF
    _cQuery += "			ON SEP_WIS.PROD	=	MRG_PED.PROD "							+ CRLF
    _cQuery += "		LEFT JOIN SEP_PROT "											+ CRLF
    _cQuery += "			ON SEP_PROT.PROD=MRG_PED.PROD "								+ CRLF
    _cQuery += "		WHERE NVL(SEP_WIS.QT,0) != NVL(SEP_PROT.QT,0) "					+ CRLF  

*/
	nStatus := TCSqlExec(_cQuery)
    If (nStatus < 0)
		Aadd(_aMsgCAOA, Upper("[ZPECF011] Problemas na Seleção de dados, comunicar ADM SISTEMA"+ CRLF +TCSQLError()) )
		_cMens := "[ZPEC11VWIS] Erro recebimento picking "+TCSQLError()
		Conout(_cMens)
		ZPEC11EMAI({_cMens}, _cPicking)
        Break    
    Endif
	
    (_cAliasPesq)->(DbGoTop())
	//não existem inconsistências	
	If (_cAliasPesq)->(Eof())
		_lRet := .T.
		Break	
	Endif 	

	_aDiverge 	:= {}
	_aMsgCAOA	:= {}
	_lAborta 	:= .F.
	_lProcessa 	:= .F.
	_cErro		:= "" 
	_lQtdWIS	:= .F.
	_lQtdPRT	:= .F.
   	While (_cAliasPesq)->(!Eof())
		_cErro		:= "" 
		_lLibera 	:= .F.
		//Caso a quaantidade WIS e Protheus esteja igual a Zero não processar
		If  (_cAliasPesq)->QT_WIS  == 0 .And. (_cAliasPesq)->QT_PROT  == 0
			_cErro := "divergencia"
			_cMens := "Pedido " 			+ _cPicking +" | "
			_cMens += "Produto " 		   	+ AllTrim((_cAliasPesq)->PROD)+" | "
			_cMens += "Qtde Estoque WIS "	+ AllTrim(Str((_cAliasPesq)->QT_WIS) )+" | "
			_cMens += "Qtde Estoque CAOA "	+ AllTrim(Str((_cAliasPesq)->QT_PROT))+" | "
			_cMens += "Qtde zerado no WIS e Protheus"			
			Aadd(_aMsgCAOA, Upper(_cMens) )
		//No caso do Qtde WIS for maior que o Protheus não prosseguir 	
		ElseIf (_cAliasPesq)->QT_WIS > (_cAliasPesq)->QT_PROT
			_cErro := "divergencia"
			_cMens := "Pedido " 			+ _cPicking +" | "
			_cMens += "Produto " 		   	+ AllTrim((_cAliasPesq)->PROD)+" | "
			_cMens += "Qtde Estoque WIS "	+ AllTrim(Str((_cAliasPesq)->QT_WIS) )+" | "
			_cMens += "Qtde Estoque CAOA "	+ AllTrim(Str((_cAliasPesq)->QT_PROT))+" | "
			_cMens += "Qtde maior no WIS"	+" | "
			_cMens += "Picking sera cancelado"			
			AAdd(_aMsgCAOA, _cMens)
			_lAborta 		:= .T.
			Exit	
		//No caso de a quantidade WIS for maior que a quantidade Protheus deixar Prosseguir 
		ElseIf  (_cAliasPesq)->QT_WIS  == 0
			_cErro := "divergewis"
			_cMens := "Pedido " 			+ _cPicking +" | "
			_cMens += "Produto " 		   	+ AllTrim((_cAliasPesq)->PROD)+" | "
			_cMens += "Qtde Estoque WIS "	+ AllTrim(Str((_cAliasPesq)->QT_WIS) )+" | "
			_cMens += "Qtde Estoque CAOA "	+ AllTrim(Str((_cAliasPesq)->QT_PROT))+" | "
			_cMens += "Qtde zerado no WIS zerado"			
			AAdd(_aMsgCAOA, _cMens)
			_lProcessa	:= .T.  //indico que irei processar pelo menos um registro
			_lQtdPRT	:= .T.
		//No caso de a quantidade Protheus for maior que a quantidade WIS não deixar Prosseguir 
		ElseIf  (_cAliasPesq)->QT_PROT  == 0
			_cErro := "divergewis"   //abortar somente o item
			_cMens := "Pedido " 			+ _cPicking +" | "
			_cMens += "Produto " 		   	+ AllTrim((_cAliasPesq)->PROD)+" | "
			_cMens += "Qtde Estoque WIS "	+ AllTrim(Str((_cAliasPesq)->QT_WIS) )+" | "
			_cMens += "Qtde Estoque CAOA "	+ AllTrim(Str((_cAliasPesq)->QT_PROT))+" | "
			_cMens += "Qtde zerado no Protheus zerado"			
			AAdd(_aMsgCAOA, _cMens)
			_lQtdWIS 	:= .T. 
		//Caso seja maior do que no Protheus devo criar um backorder do processo
		ElseIf  (_cAliasPesq)->QT_WIS > 0 .And. (_cAliasPesq)->QT_WIS < (_cAliasPesq)->QT_PROT
			_cErro := "divergewis"
			_cMens := "Pedido " 			+ _cPicking +" | "
			_cMens += "Produto " 		   	+ AllTrim((_cAliasPesq)->PROD)+" | "
			_cMens += "Qtde Estoque WIS "	+ AllTrim(Str((_cAliasPesq)->QT_WIS) )+" | "
			_cMens += "Qtde Estoque CAOA "	+ AllTrim(Str((_cAliasPesq)->QT_PROT))+" | "
			_cMens += "Será processado parcialmente devido Qtde maior no WIS, mas contendo Qtde no Protheus"			
			AAdd(_aMsgCAOA, _cMens)
			_lProcessa	:= .T.  //indico que irei processar pelo menos um registro
			_lQtdWIS    := .T.
		//Caso seja maior do que no Protheus devo criar um backorder do processo
		ElseIf  (_cAliasPesq)->QT_PROT > 0 .And. (_cAliasPesq)->QT_PROT > (_cAliasPesq)->QT_WIS 
			_cErro := "divergewis"
			_cMens := "Pedido " 			+ _cPicking +" | "
			_cMens += "Produto " 		   	+ AllTrim((_cAliasPesq)->PROD)+" | "
			_cMens += "Qtde Estoque WIS "	+ AllTrim(Str((_cAliasPesq)->QT_WIS) )+" | "
			_cMens += "Qtde Estoque CAOA "	+ AllTrim(Str((_cAliasPesq)->QT_PROT))+" | "
			_cMens += "Será processado parcialmente devido Qtde a menor no WIS"			
			AAdd(_aMsgCAOA, _cMens)
			_lProcessa	:= .T.  //indico que irei processar pelo menos um registro
			_lQtdWprt 	:= .T.
		Else
			_lProcessa 	:= .T.
			_lQtdWIS 	:= .T.
			_lQtdprt 	:= .T. 
		Endif
		If !Empty(_cErro)
			//Carregar os valores em uma matriz para processamento posterior
			_nPosCpo := Ascan(_aDiverge, {|x| x[2]==(_cAliasPesq)->PROD})  
			If _nPosCpo > 0 
				_aDiverge[_nPosCpo, 2] += (_cAliasPesq)->QT_WIS
				_aDiverge[_nPosCpo, 3] += (_cAliasPesq)->QT_PROT
			Else
				Aadd(_aDiverge,{ _cPicking,; 
								(_cAliasPesq)->PROD,; 
								(_cAliasPesq)->QT_WIS,;  
								(_cAliasPesq)->QT_PROT,;
								_cErro}) 
			Endif	
		Endif
		(_cAliasPesq)->(DbSkip())
	EndDo
	//caso seja para abortar processo   1 Abortrar pois qtde WIS maior que PRT
 	//									2 Sair  pois todas as qtdes WIS estão zeradas
	//									3 Sair pois todas as quantidades Prothes estão Zeradas	
	If _lAborta .Or. ! _lQtdWIS .Or. ! _lQtdPRT 
		//1 Abortrar pois qtde WIS maior que PRT 	
		If _lAborta
			_cMens 		:= _aMsgCAOA[Len(_aMsgCAOA)]
			//_aMsgCAOA	:= {_cMens}  //posso gerar as demais mensagens pois será enviado para RG
			ZPEC11RMsg("divergencia",_cMens)  //divergewis deverá ser utilizada esta tag somente se ocorrer este processo
			//AAdd(_aMsgCAOA,_cMens)  
			//ZPEC11EMAI({_cMens}, _cPicking, (_cAliasPesq)->QT_PROT)  //Envio e-mail
		Else 
			_cMens		:= "Todos os itens estao com quantidades zeradas tanto para WIS como Protheus nao será processado e status dos orçamentos voltarão ao status inicial, Picking sera cancelado"
			ZPEC11RMsg("divergewis",_cMens)  //divergewis deverá ser utilizada esta tag somente se ocorrer este processo
			AAdd(_aMsgCAOA,_cMens)   
			//rotina para cancelr picking
			//Deixar continuar pois ira verificar todos os itens e enviar via e-mail
		Endif	
		_lDivergencia 	:= .T.
		//montar processo de calcelamento do Picking 
		_aMsg := {}
		If Len(_aMsg)
			For _nPos := 1 To Len(_aMsg)
				Aadd( _aMsgCAOA, _aMsg[_nPos] ) 
			Next _nPos 
		Endif
		Break
	Endif 

	If ! _lProcessa
		_cMens		:= "Não foi possivel processar Pedido "+_cPicking
		ZPEC11RMsg("divergewis",_cMens)  //divergewis deverá ser utilizada esta tag somente se ocorrer este processo
		_AAdd(aMsgCAOA, _cMens)  //posso gerar as demais mensagens pois será enviado para RG
		Break  //Deixar continuar pois estara gravado histórico em _aMsgCaoa
	Endif

	//Caso esteja preenchido pedidos divergentes
	If Len(_aDiverge) > 0
		_lRet := ZPEC11BKOR( _aDiverge )
		If ! _lRet
			_cMens		:= "Não foi possivel desmembrar Pedido "+_cPicking
			ZPEC11RMsg("divergencia",_cMens)  //divergewis deverá ser utilizada esta tag somente se ocorrer este processo
			Break 
		Endif 
	Endif
	_lRet := .T.
End Sequence 

If Len(_aMsgCAOA) > 0
	ZPEC11EMAI(_aMsgCAOA, _cPicking, /*_cCodProd*/)
Endif 

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
@param _aDiverge
@type function
@project	GAP002 | Integração da separação - Informar produto e quantidade da cubagem
@Obs		Necessário fazer este ajuste pois os orçamentos são aglutinados para a geração do picking, podendo existir mais de um orçamento com o mesmo código
/*/
Static Function ZPEC11BKOR( _aDiverge )
Local _lRet 		:= .F.
Local _cAliasPesq	:= GetNextAlias()   
Local _aBackOrder	:= {}
Local _aRegVS3 		:= {}    		 //registros para reserva
Local _aBak 		:= {}
Local _cCodProd 
Local _cPicking	
Local _nQtdeDivWiS 
Local _nQtdeDivPRO 
Local _nSaldoWis
Local _nSaldoProt
Local _nPos 
Local _lZera 
Local _cNumOrc
Local _nQtde
Local _cMsg

Begin Sequence
	For _nPos := 1 To Len(_aDiverge)
		_cPicking 		:= _aDiverge[_nPos,1]
		_cCodProd 		:= _aDiverge[_nPos,2]
		_nQtdeDivWiS	:= _aDiverge[_nPos,3]
		_nQtdeDivPRO	:= _aDiverge[_nPos,4]

		If Select((_cAliasPesq)) <> 0
			(_cAliasPesq)->(DbCloseArea())
		Endif

		BeginSql Alias _cAliasPesq
			SELECT 	  VS3.VS3_NUMORC
					, VS3.VS3_CODITE
					, VS3.VS3_QTDITE
					, VS3.R_E_C_N_O_ NREGVS3
			FROM %table:VS3% VS3
			WHERE VS3.%notDel% 
				AND VS3.VS3_FILIAL = %XFilial:VS3%
				AND VS3.VS3_CODITE = %Exp:_cCodProd%
				AND VS3.VS3_XPICKI = %Exp:_cPicking% 
			ORDER BY VS3.VS3_NUMORC	
		EndSql
		//Caso não localize um produto no picking abortar toda a operação
		If (_cAliasPesq)->(Eof())
			Aadd(_aMsgCAOA,"Nao localizado Pedido "+_cPicking+" para o Produto "+_cCodProd)
			Break
		Endif	

		//Processar podem existir mais de um orçamento pois o picking é agrupamento de orçamentos
		Aadd(_aMsgCAOA, "Atualizando produdo "+AllTrim(_cCodProd)+" orcamento "+VS3->VS3_NUMORC+", Qtde Protheus "+AllTrim(STR(VS3->VS3_QTDITE))+" Qtde WIS "+AllTrim(STR(_nQtdeDivWiS)))
		_nSaldoWis	:= _nQtdeDivWiS
		_nSaldoProt := _nQtdeDivPRO
		While (_cAliasPesq)->(!Eof())
			_lZera 	:= .F.
			_nQtde 	:= 0
			_cObs 	:= "Atualizacao de Divergencia Qtde Protheus X WIS , Picking "+_cPicking+" Valor correspondente a diferenca entre as Qtde  no produto, orcamento Principal "+VS1->VS1_NUMORC + CRLF
			VS3->(DbGoto((_cAliasPesq)->NREGVS3))
			//necessário retirar a reserva
			If _nSaldoWis == 0 .Or. _nSaldoProt == 0
				_nQtde 		:= VS3->VS3_QTDITE
				_lZera 	:= .T.
				_cObs   += "Devido Qtde "+If(_nSaldoWis == 0,"WIS","Prothes")+" igual a zero" + CRLF
				//Caso o orçamento seja maior que o Wis abater os valores
			ElseIf VS3->VS3_QTDITE > _nSaldoWis
				_nQtde 		:= _nSaldoWis
				_lZera 		:= .F.
				_cMsg   	:= "Item "+AllTrim(VS3->VS3_SEQUEN) +", Qtde Protheus "+AllTrim(STR(VS3->VS3_QTDITE))+" Qtde Restante  "+AllTrim(STR(_nSaldoWis)) + CRLF
				_cObs   	+= _cMsg
				Aadd(_aMsgCAOA, _cMsg)
			//Caso o saldo wis seja menor que o orçamento o mesmo ficará não mecher somente abater da soma
	   		//Caso seja o mesmo valor não fazer movimentação
			ElseIf VS3->VS3_QTDITE <= _nSaldoWis 
				_nQtde 		:= VS3->VS3_QTDITE
				_lZera 		:= If(VS3->VS3_QTDITE < _nSaldoWis,.F.,.T.)
				_cMsg		:= "Item "+ AllTrim(VS3->VS3_SEQUEN)+ ", Qtde Protheus "+AllTrim(STR(VS3->VS3_QTDITE))+" Qtde Restante  "+AllTrim(STR(_nSaldoWis)) + CRLF
				_cObs   	+= _cMsg
				Aadd(_aMsgCAOA,_cObs)
			Else  
				_nQtde := VS3->VS3_QTDITE
				_lZera := .T.
				_cObs   += "Devido Qtde divergencias de Qtde "+ AllTrim(Str(VS3->VS3_QTDITE)) + CRLF
			Endif
			_nSaldoWis	-= _nQtde
			If _nQtde > 0
				Aadd(_aBak,{	(_cAliasPesq)->NREGVS3,;
								 _cCodProd,; 
								_nQtde,; 
								_cObs,;
								.T.,;    ///*_LXBO*/
								_lZera /*indica se zera ou*/,;
								(_cAliasPesq)->VS3_NUMORC })

			Endif
			//Caso ja utilizei as quantidades posso sair
			If _nSaldoWis <= 0
				Exit
			Endif
			(_cAliasPesq)->(DbSkip())
		EndDo 
	Next
	//cASO NÃO TENHA BACKORDER
	If  Len(_aBak) == 0
		_lRet := .T.
	Endif 	
	//Gravar BackOrder, necessário fazer isto pois pode ser varios orçamentos
	//Organizo por numero de orçamento
	Asort(_aBak,,, { |x, y| x[7] > y[7] } )
	_cNumOrc 	:= _aBak[1,7]   //numero do orçamento
	_aRegVS3 	:= {}    		 //registros para reserva
	_aBackOrder	:= {}
	For _nPos := 1 To Len(_aBak)
		Aadd(_aBackOrder,{_aBak[_nPos,1], _aBak[_nPos,2], _aBak[_nPos,3], _aBak[_nPos,4],_aBak[_nPos,5],_aBak[_nPos,6]})
		//Sera necessário retirar reserva
		//mudando orçamento e ou no fim do for  
		If _cNumOrc <> _aBak[_nPos,7] .Or. _nPos == Len(_aBak)
			//primeiro tiro as reservas do produto antes de abater as diferenças
			_lRet := ZPEC11BKRE( _cNumOrc, _cPicking, .F., /*_aRegVS3*/)  
			If ! _lRet
				_cMsg :=  "Problemas para retirar as reservas orçamento "+_cNumOrc
				Aadd(_aMsgCAOA, _cMsg)
				Break	
			Endif
			//Fazer a Clonagem do registro
			_lRet := U_XOFUNCLO( _cNumOrc, /*_cGrupo*/, /*_cCodProd*/, /*_nQtdeItem*/, /*_lZera*/, /*_aVazioCpo*/, _aBackOrder)
			If ! _lRet
				_cMsg :=  "Ocorrerão problemas para clonar itens que não possuem status para carregamento aos quais passariam para backorder"
				Aadd(_aMsgCAOA, _cMsg)
				Break	
			EndIf
			_cMsg := "Criado Backorder para orçamento(s) "+ _cNumOrc +" diferença de qtde Protheus  em relação ao retorno Picking WIS"
			Aadd(_aMsgCAOA, _cMsg)
			//Ajustar as quantidades após a Clonagem
			ZPEC11BKAJ(_aBackOrder)
			_lRet := ZPEC11BKRE( _cNumOrc, _cPicking, .T., /*_aRegVS3*/)  
			If ! _lRet
				_cMsg :=  "Problemas para criar as reservas orçamento "+_cNumOrc
				Aadd(_aMsgCAOA, _cMsg)
				Break	
			Endif
			_cNumOrc 	:= _aBak[_nPos,7]
			_aBackOrder	:= {}
		Endif 
	Next	
	_lRet 	:= .T. 
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
@param _cNumOrc, _cPicking, _lReserva, _aRegVS3
@type function
@project	GAP002 | Integração da separação - Informar produto e quantidade da cubagem
@Obs		
/*/
Static Function ZPEC11BKRE(_cNumOrc, _cPicking, _lReserva, _aRegVS3)
Local _lRet 		:= .F.
Local _aSeqVS3 	
Local _cDocto	
Local _cMsg
Local _nPos

DeFault _aRegVS3 		:= {}

Private aHeaderP    	:= {} // Variavel ultilizada na OX001RESITE
Private _aReservaCAOA	:= {}
Private _aMsgCAOAAglu	:= {}

Begin Sequence 

	//montar bakOrder da diferença
	//posicionar VS1
	VS1->(DbSetOrder(1))
	VS1->(DbSeek(FwXFilial("VS1")+ _cNumOrc))

	_aSeqVS3 	:= Aclone({})
	_cDocto		:= ""
	If Len(_aRegVS3) > 0
		For _nPos := 1 To Len(_aRegVS3)
			VS3->( DbGoto( _aRegVS3[_nPos]) )
			Aadd(_aSeqVS3, VS3->VS3_SEQUEN)
		Next
	Endif	 
	_aReservaCAOA 	:= Aclone({ _cNumOrc, _lReserva, _aRegVS3 })	// Variavel utilizada no PE OX001RES
	_cDocto := OX001RESITE(_cNumOrc,_lReserva,_aSeqVS3 )
	if Empty(_cDocto) .or. _cDocto == "NA"
		If _lReserva
			_cMsg := "Não foi possivel criar a reserva do item, orçamento "+_cNumOrc+" devido a Divergencia na qtde "
		Else 
			Aadd(_aMsgCAOA, "Não foi possivel retirar a reserva do item, alterado orçamento "+_cNumOrc+" devido a Divergencia na qtde")
		Endif 	
		Aadd(_aMsgCAOA, _cMsg )
		Break
	Endif
	If _lReserva 
		_cMsg := "Incluido reserva "+_cDocto+" do item, orçamento "+_cNumOrc+" devido a Divergencia na qtde "
	Else
		_cMsg := "Retirada reserva "+_cDocto+" do item, orçamento "+_cNumOrc+" devido a Divergencia na qtde"
	Endif
	Aadd(_aMsgCAOA, _cMsg )
	_lRet := .T.
End Sequence 
Return _lRet



/*/{Protheus.doc} ZPEC11BKAJ
//Função para atualizar qtde de itens que sofreram backorder, abatndo do seu total existente 
@author DAC
@since 14/08/2023
@version undefined
@param _aBackOrder
@type function
@project	GAP002 | Integração da separação - Informar produto e quantidade da cubagem
@Obs		
/*/
Static Function ZPEC11BKAJ(_aBackOrder)
Local _lRet 		:= .F.
Local _nPos

DeFault _aRegVS3 		:= {}

Begin Sequence 
	For _nPos := 1 To Len(_aBackOrder)
		//Ajustar somente os itens que não foram feitos backorder do seu total
		If !_aBackOrder[_nPos,6]  
			VS3->(DbGoto(_aBackOrder[_nPos,1]))
			VS3->(RecLock("VS3",.F.))
			VS3->VS3_QTDITE	-= _aBackOrder[_nPos,3]
			VS3->(MsUnlock())
		Endif
	Next
	_lRet := .T.
End Sequence 
Return _lRet



/*/{Protheus.doc} ValidOJson
Valida os dados do oJson
@author DAC - Denilso
@since 
@version undefined
@param _oJson, _cTipo
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
	Aadd(_aRet, {410,	"conexaowis"			, .F.	, .T., 	"Senha"})


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

	Aadd(_aRet, {616,	"divergewis"			, .F.	, .F., 	"Divergencia na separação WIS"})

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



/*/{Protheus.doc} ZPEC11EMAI
Funcionalidade Responsavel para enviar e-mail com divergencias ocorridas no processo
@author DAC
@since 08/07/2023
@version undefined
@param 
@type function
@project	GAP002 | Integração da separação - Informar produto e quantidade da cubagem
@Obs		
/*/

Static Function ZPEC11EMAI(_aMsg, _cPicking, _cCodProd, _cAssunto)
Local _cAliasPesq	:= GetNextAlias()   
Local _cEmail		:= ""

Begin Sequence 
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT SX5.X5_DESCRI
		FROM %Table:SX5% SX5	
		WHERE SX5.%notDel%
			AND SX5.X5_FILIAL 	= %XFilial:SX5%
			AND	SX5.X5_TABELA   = "2E"
			AND SX5.X5_DESCRI 	<> ' '				
	EndSql
	If (_cAliasPesq)->(Eof())
		Conout("[ZPECF011] - Não cadatrado email SX5 Tabela 2E, referente a problemas ocorridos no recebimento do Picking")
		Break
	Endif 
	While (_cAliasPesq)->(!Eof())
		_cEmail += AllTrim((_cAliasPesq)->X5_DESCRI)+","
		(_cAliasPesq)->(DbSkip())
	EndDo
	//Retirar ", do final"
	_cEmail := SubsTr(_cEmail,1,Len(_cEmail)-1)
	ZPCPF11ENV(_aMsg, _cPicking, _cCodProd, _cAssunto, _cEmail, /*_cEMailCopia*/, /*_aAnexos*/,  /*lSchedule*/)	
End Sequence 

Return Nil



/*
=====================================================================================
Programa.:              ZPCPF07EM
@param 					_aMens   	= Mensagens de erro 
						_cAssunto   = Assunto do e-mail 
						_cEmails    = Destinatário do e-mail 
						_cEMailCopia= Destinatarios em cópia 
						_aAnexos 	= Localização e nome do arquivo anexo 
						_cRotina    = Rotina que chamou o processo
						lSchedule	= Esta rodando em job se verdadeiro não emitira msg em tela
Autor....:              CAOA - DAC Denilso 
Data.....:              10/07/2020
Descricao / Objetivo:   Funcao para processar o envio das notificacoes
Doc. Origem:            GAP COM027
Solicitante:            Compras
Uso......:              ZCOLF001
Obs......:

=====================================================================================
*/
Static Function ZPCPF11ENV(_aMsg, _cPicking, _cCodProd, _cAssunto, _cEmails, _cEMailCopia, _aAnexos,  lSchedule)
Local _cTexto   		:= ""
Local _cEmailDest 		:= ""
Local _lMsgOK			:= .T.
Local _lMsgErro			:= .F.
Local _cObsMail			:= ""
Local _cReplyTo			:= ""
Local _cCorItem			:= "FFFFFF"
Local _lEnvia			:= .T.
Local _cLogo  			:= 'https://tinyurl.com/logocaoa'  
Local _cNomeUsu 		:= "RECEBIMENTO RETORNO PICKING RGLOG [ZPECF011]" //Upper(FwGetUserName(RetCodUsr())) //Retorna o nome completo do usuário  __cUserId
Local _cCodUsu			:= "RGLOG_JS" //RetCodUsr()
Local _cDescProd		:= ""
Local _cRotina			:= "ZPECF011"
Local _nPos

Default _aMsg			:= {}
Default _cPicking		:= ""
Default _cCodProd		:= ""
Default _cAssunto		:= Upper("Informacoes Retorno Picking "+AllTrim(_cPicking)+" [ZPECF011]") 
Default _cEmails 		:= "evandro.mariano@caoa.com.br"  //E-mail para envio problemas integração  
Default _cEMailCopia	:= ""
Default _aAnexos		:= {}
Default _lSchedule   	:= IsBlind()

Begin Sequence 
	_lMsgErro			:= IF( _lSchedule == .F., .T. , .F. )
	If Empty(_cEmails)
		_cTexto := "**** Erros referente ao processo de importação Retorno Picking função [ZPECF011] não possui e-mail cadastrado no SX5 Tabela 2E ****"
		_cTexto += "     Os mesmos serão gravados no log do Sistema conforme informações abaixo" 
		Conout(_cTexto)
		For _nPos := 1 To Len(_aMsg)
			Conout( _aMsg[_nPos])
		Next 
		Break
	EndIf	

	//localizar o produto
	If !Empty(_cCodProd)
		SB1->(DbSetOrder(1))  //B1_FILIAL+B1_COD
		If SB1->(DbSeek(XFilial("SB1") + _cCodProd))
			_cDescProd := AllTrim(SB1->B1_DESC)
		EndIf
	Endif

	_cEmailDest := _cEmails
	_cHtml := ""
	_cHtml += "<html>"+ CRLF
	_cHtml += "	<head>"+ CRLF
	_cHtml += "		<title>Processo de importação Retorno Picking [ZPECF011] Informações/Erros</title>"+ CRLF
	_cHtml += "	</head>"+ CRLF
	_cHtml += "	<body leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>"+ CRLF
	_cHtml += "		<table width='100%' height='100%' border='0' cellpadding='0' cellspacing='0'>"+ CRLF
	_cHtml += "			<tr>"+ CRLF
	_cHtml += "				<th width='1200' height='100%' align='center' valign='top' scope='col'>"+ CRLF
	_cHtml += "					<table width='90%' height='50%' border='0' cellpadding='0' cellspacing='0'>"+ CRLF
	_cHtml += "						<tr>"+ CRLF
	_cHtml += "							<th width='100%' height='100' scope='col'>"+ CRLF
	_cHtml += "								<table width='100%' height='60%' border='3' cellpadding='0' cellspacing='0' >"+ CRLF
	_cHtml += "									<tr>"+ CRLF
	_cHtml += "										<th width='12%' height='0' scope='col'><img src='" + _cLogo + "' width='118' height='40'></th>"+ CRLF
	_cHtml += "										<td width='67%' align='center' valign='middle' scope='col'><font face='Arial' size='+1'><b>Recebimento PICKING RGLOG Informações</b></font></td>"+ CRLF
	_cHtml += "									</tr>"+ CRLF
	_cHtml += "								</table>"+ CRLF
	_cHtml += "							</th>"+ CRLF
	_cHtml += "						</tr>"+ CRLF
	_cHtml += "						<tr>"+ CRLF
	_cHtml += "							<th width='100' height='100' scope='col'>"+ CRLF
	_cHtml += "								<table width='100%' height='100%' border='2' cellpadding='2' cellspacing='1' >"+ CRLF
	_cHtml += "									<tr>"+ CRLF
	_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>Empresa:	</b></font></td>"+ CRLF
	_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>"+AllTrim(FWFilialName(,SM0->M0_CODFIL))+"</font></td>"+ CRLF
	_cHtml += "									</tr>"+ CRLF
	_cHtml += "									<tr>"+ CRLF
	_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>Responsável(is):	</b></font></td>"+ CRLF
	_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>" + _cCodUsu+"-"+_cNomeUsu + "</font></td>"+ CRLF
	_cHtml += "									</tr>"+ CRLF
	_cHtml += "									<tr>"+ CRLF
	_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>Picking:	</b></font></td>"+ CRLF
	_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>"+ _cPicking +"</font></td>"+ CRLF
	_cHtml += "									</tr>"+ CRLF
	_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>Produto:	</b></font></td>"+ CRLF
	_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>"+ _cCodProd + " - "+_cDescProd+"</font></td>"+ CRLF
	_cHtml += "									</tr>"+ CRLF

	_cHtml += "								</table>"+ CRLF
	_cHtml += "							</th>"+ CRLF
	_cHtml += "						</tr>"+ CRLF
	_cHtml += "						<tr >"+ CRLF
	_cHtml += "							<td height='25' style='padding-top:1em;'>"+ CRLF
	_cHtml += "								<table width='100%' height='100%' border='2' cellpadding='2' cellspacing='0' >"+ CRLF
	_cHtml += "									<tr bgcolor='#4682B4'>"+ CRLF
	_cHtml += "										<th width='10%' height='100%' align='center' valign='middle' scope='col'><font face='Arial' size='2'><b>Descrição		</b></font></th>"+ CRLF
	_cHtml += "									</tr>"+ CRLF

	For _nPos := 1 To Len(_aMsg)
		_cHtml += "									<tr> <!--while advpl-->"+ CRLF
		_cMsgErro := _aMsg[_nPos]
		_cHtml += "										<td width='10%' height='16' align='left'	valign='middle' bgcolor='#"+_cCorItem+"' scope='col'><font size='1' face='Arial'>"+_cMsgErro+"</font></td>"+ CRLF
		_cHtml += "									</tr>"+ CRLF
	Next
	
	_cHtml += "					</table>"+ CRLF
	_cHtml += "				</th >"+ CRLF
	_cHtml += "			</tr>"+ CRLF
	_cHtml += "		</table >"+ CRLF
	_cHtml += "	</body >"+ CRLF

    _cHtml +=    "<br/> <br/> <br/> <br/>" 
    _cHtml +=    " <h5>Esse email foi gerado pela rotina " + FunName() + " </h5>"       


	/*
	cMailDestino	- E-mail de Destino
	cMailCopia		- E-mail de cópia
	cAssunto		- Assunto do E-mail
	cHtml			- Corpo do E-mail
	aAnexos			- Anexos que será enviado
	lMsgErro		- .T. Exige msgn na tela - .F. Exibe somente por Conout
	cReplyTo		- Responder para outra pessoa.
	cRotina			- Rotina que está sendo executada.
	cObsMail		- Observação para Gravação do Log.
	*/
	If _lSchedule
		_lEnvia := U_ZGENMAIL(_cEmailDest,_cEMailCopia,_cAssunto,_cHtml,_aAnexos,_lMsgErro,_lMsgOK,_cRotina,_cObsMail,_cReplyTo)
	Else
		MsgRun("Enviando e-mail de notificação. Aguarde!!!","CAOA",{|| _lEnvia := U_ZGENMAIL(_cEmailDest,_cEMailCopia,_cAssunto,_cHtml,_aAnexos,_lMsgErro,_lMsgOK,_cRotina,_cObsMail,_cReplyTo) })
	EndIf

	If !_lEnvia
		If lSchedule
			ConOut("**** [ ZPCPF11EM ] - E-mail não enviado por problemas no envio função ZGENMAIL - Solicitar apoio do administrador! (Totvs Integração RETORNO PICKING) ****"+ CRLF)
		Else
			ApMsgInfo("E-mail não enviado - Solicitar apoio do administrador!! (Totvs Integração RETORNO PICKING)","ERRO EMAIL")
		EndIf
	EndIf
End Sequence
Return nil




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

