/*/ {Protheus.doc} SaldoCAOAPEC
Classe para localizar saldo WIS e retornar saldo valido entre WIS e Prothes
@author DAC - Denilso
@since  V.03
@version 
@return ${return}, ${return_description}
@type Class
@history  substitui a função U_XSLDCAOAEstoque   

exemplo chamada
		_oSaldoWis:SaldoCAOAPEC():New("R-F4J16-1012030            ")
		//_nSaodoWIS := _oSaldoWis:RetSaldoWIS()
		_oSaldo    := _oSaldoWis:RetSldCAOAPEC()	

/*/
#include "Totvs.ch"
#include "Topconn.ch"
#define CRLF chr(13) + chr(10)
 
Class SaldoCAOAPEC
	//Atributo
	Data _cCodProd		As Character
	Data _cMarca		As Character
	Data _cArmazem		As Character
	Data _cGrupo		As Character
	Data _cConectWIS	As Character	HIDDEN  //NÃO PERMITE MANIPULAR E VISUALIZAR
	Data _lResIntegr	As Logical		HIDDEN
	Data _lVlLocWIS		As Logical		HIDDEN
	Data _lAvaliaWis    As Logical		HIDDEN
	Data _nSaldoWIS 	As Number
	Data _nSaldoEST     As Number	
	Data _nSaldoPEC     As Number
	Data _aMsg			As Array 
	Data _aError		As Array 
	//Metodo
	Method New(cCodProd, cArmazem, cGrupo, cMarca) CONSTRUCTOR
	Method RetSaldoWIS() 
	Method RetSldCAOAPEC()
	Method CarregaCAOAPEC(cCodProd, cArmazem, cGrupo, cMarca, nSaldoSB2)

End Class 

//Metodo constructos
Method New(cCodProd, cArmazem, cGrupo, cMarca) class SaldoCAOAPEC
	Default cCodProd 	:= ""
	Default cMarca		:= ""
	Default cArmazem    := ""
	Default cGrupo    	:= ""

	::_cCodProd := cCodProd
	::_cArmazem	:= cArmazem 
	::_cGrupo   := cGrupo
	::_cMarca 	:= cMarca
	::_cConectWIS   := AllTrim(SuperGetMV( "CMV_PEC031"  ,,"WIS.V_ENDERECO_ESTOQUE@DBLINK_WISPROD"))
	::_lResIntegr   := SuperGetMV( "CMV_PEC040"  ,,.T.)
	::_lVlLocWIS   	:= SuperGetMV( "CMV_PEC041"  ,,.T.)
	::_lAvaliaWis   := SuperGetMV( "CMV_PEC024"  ,,.T. )   //Parâmetro para indicar se avaliara saldo wis
	::_nSaldoWIS 	:= 0	//Saldo WIS
	::_nSaldoEST	:= 0  	//Saldo Protheus
	::_nSaldoPEC    := 0	//Saldo a ser utilizado entre WIS e Protheus
	::_aError 		:= {}
	::_aMsg			:= {}

Return Self

//Methodo para carregar dados entre saldo Protheus e saldo WIS
Method CarregaCAOAPEC(cCodProd, cArmazem, cGrupo, cMarca, nSaldoSB2) class SaldoCAOAPEC
	Default cCodProd 	:= ""
	Default cMarca		:= ""
	Default cArmazem    := ""
	Default cGrupo    	:= ""
	DeFault nSaldoSB2	:= 0

	Begin Sequence
		::_cCodProd 	:= PADR(ALLTRIM(cCodProd),TAMSX3("B1_COD"  )[1]) // cCodProd
		::_cArmazem		:= PADR(ALLTRIM(cArmazem),TAMSX3("B2_LOCAL")[1]) //cArmazem 
		::_cGrupo   	:= cGrupo
		::_cMarca 		:= cMarca
		::_nSaldoEST	:= nSaldoSB2  	//Saldo Protheus
		::_nSaldoWIS 	:= 0			//Saldo WIS
		::_nSaldoPEC    := 0			//Saldo a ser utilizado entre WIS e Protheus
		::_aError 		:= {}
		::_aMsg			:= {}
		//ja são carregados no construtor
		//::_cConectWIS   := AllTrim(SuperGetMV( "CMV_PEC031"  ,,"WIS.V_ENDERECO_ESTOQUE@DBLINK_WISPROD"))
		//::_lResIntegr   := SuperGetMV( "CMV_PEC040"  ,,.T.)  
		//::_lVlLocWIS   	:= SuperGetMV( "CMV_PEC041"  ,,.T.)

		//Verifico se foi informado produto
		If Empty(cCodProd)
			Aadd(::_aError, "Produto não informado !")
			Break
		Endif
		//Carregar todos os Saldos
		Self:RetSldCAOAPEC()	
	End Sequence
Return Nil

//Methodo para retornar diferença entre saldo Protheus e saldo WIS
Method RetSldCAOAPEC() class SaldoCAOAPEC
	Local _cAliasPesq	:= GetNextAlias()   
	Local cWhere 		:= ""
	Local aSaldo		:= {}
	Local cCodProd 		:= ::_cCodProd
	Local cArmazem 		:= ::_cArmazem
	Local nSaldoSB2     := 0
	Local oZPEC08Peca
	Local nPos

	Begin Sequence
		//caso não esteja preenchido Produto
		If Empty(cCodProd)
			Aadd(::_aError,"Produto Não Informado")
			Break
		Endif 

		//GAP098 | Desmembrar itens bloqueados por inventário
		//Verificar se esta em inventário DAC 07/11/2023
		If SB2->B2_COD <> cCodProd .Or. AllTrim(SB2->B2_LOCAL) <> AllTrim(cArmazem)
			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek(XFilial("SB2")+cCodProd+cArmazem))
				Aadd(::_aError, "Produto "+ AllTrim(cCodProd) +" Armazém "+cArmazem+" não localizao função RetSldCAOAPEC !")
				Break
			Endif
			If !Empty(SB2->B2_DTINV)
				Aadd(::_aError, "Produto "+ AllTrim(cCodProd) +" Armazém "+cArmazem+" com bloqueio de inventário em "+SB2->B2_DTINV+" RetSldCAOAPEC !")
				Break
			Endif
		Endif 

		/*
		nSaldoSB2 := ::_nSaldoEST
		If ! ::lAvaliaWis .and. nSaldoSB2 > 0
			::_nSaldoPEC := nSaldoSB2
			Break 
		Endif
		*/
		
		//Garantir que as variaveis possuam conteúdo
		If Empty( ::_cGrupo ) .And. AllTrim(cCodProd) == AllTrim(VS3->VS3_CODITE)
			::_cGrupo := VS3->VS3_GRUITE
		Endif 
		If Empty( ::_cArmazem ) .And. AllTrim(cCodProd) == AllTrim(VS3->VS3_CODITE)
			::_cArmazem := VS3->VS3_LOCAL
		Endif 

		If !Empty( ::_cGrupo )
			cWhere := "AND SB1.B1_GRUPO  	= '"+::_cGrupo+"' "
		Endif 
		//Não utilizar armazem pois poderá ser visto mais de um portanto SB2 será mais acertivo
		//	If !Empty( ::_cArmazem )
		//		cWhere := "AND SB1.B1_LOCAL  	= '"+::_cArmazem+"' "	
		//	Endif 
		cWhere := "%"+cWhere+"%"
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	ISNULL(SB1.R_E_C_N_O_,0) NREGSB1
				FROM %Table:SB1% SB1	
				WHERE 	SB1.B1_FILIAL 	= %XFilial:SB1%
					AND SB1.B1_COD  	= %Exp:cCodProd%
					AND	SB1.%notDel%
					%Exp:cWhere%
		EndSql
		If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGSB1 == 0
			Aadd(::_aError,"Não localizado Produto "+cCodProd+" "+If(Empty(cWhere),""," ref. "+cWhere) )
			Break
		EndIf	
		SB1->(DbGoto((_cAliasPesq)->NREGSB1))

		//neceasario atribuir armazem caso não seja enviado ira pegar armazem do produto
		cArmazem := ::_cArmazem
		If Empty(cArmazem)
			cArmazem 	:= SB1->B1_LOCPAD
			::_cArmazem	:= SB1->B1_LOCPAD
		Endif

		//quando vem informado o saldo não sera validado novamente, isto ocorrera no similar, kit
		If nSaldoSB2 <= 0
			//Função no padrão SIGAPEC		
			oZPEC08Peca := DMS_Peca():New()
			oZPEC08Peca:SetGrupo(SB1->B1_GRUPO)
			oZPEC08Peca:SetCodigo(SB1->B1_COD)
			nSaldoSB2 	:= 0
			aSaldo 		:= oZPEC08Peca:EstqSaldo(,.t.,.t.)
			For nPos := 1 To Len(aSaldo)
				If AllTrim(cArmazem) == AllTrim(aSaldo[nPos,2])
					nSaldoSB2 	:= aSaldo[nPos,3]  //(_cAliasPesq)->SALDOSB2
					Exit
				Endif	
			Next
		Endif

		//Atualizo o saldo Protheus
		::_nSaldoEST := nSaldoSB2
		//Caso não seja para avaliar WIS
		If ! (Self:_lAvaliaWis) 
			::_nSaldoPEC := nSaldoSB2
			If ::_nSaldoPEC == 0 
				Aadd(::_aError, "Produto "+AllTrim(cCodProd)+", com saldo Protheus "+AllTrim(Str(::_nSaldoPEC))+" Armazem "+cArmazem+", possui saldo zerado , SALDO INVALIDO ! ")
			Endif
			Break
		Endif

		//Garantir que carrega saldo WIS
		::_nSaldoWIS := Self:RetSaldoWIS()  //carrego o valor do saldo WIS

		If ::_nSaldoWIS == 0 
			Aadd(::_aError, "Produto "+AllTrim(cCodProd)+", Saldo atual Protheus "+AllTrim(Str(::_nSaldoEST))+" Saldo atual Wis "+AllTrim(Str(::_nSaldoWis))+" Armazem "+cArmazem+", possui saldo zerado no WIS, SALDO INVALIDO ! ")
			Break
		Endif
		If ::_nSaldoEST == 0 
			Aadd(::_aError, "Produto "+AllTrim(cCodProd)+", Saldo atual Protheus "+AllTrim(Str(::_nSaldoEST))+" Saldo atual Wis "+AllTrim(Str(::_nSaldoWis))+" Armazem "+cArmazem+", possui saldo zerado no Protheus, SALDO INVALIDO ! ")
			Break
		Endif
		If ::_nSaldoWIS < nSaldoSB2 
			Aadd(::_aMsg, "Produto "+AllTrim(cCodProd)+", com Saldo Protheus "+AllTrim(Str(nSaldoSB2))+" maior que saldo Wis "+AllTrim(Str(::_nSaldoWis))+" Armazem "+cArmazem+", sera utilizado saldo Wis !")
			::_nSaldoPEC	= ::_nSaldoWIS
		ElseIf ::_nSaldoWIS > nSaldoSB2
			Aadd(::_aMsg, "Produto "+AllTrim(cCodProd)+", com Saldo Protheus "+AllTrim(Str(nSaldoSB2))+" menor que saldo Wis "+AllTrim(Str(::_nSaldoWis))+" Armazem "+cArmazem+", sera utilizado saldo Protheus !")
			::_nSaldoPEC	:= nSaldoSB2
		Else 
			::_nSaldoPEC	:= nSaldoSB2
			Aadd(::_aMsg, "Produto "+AllTrim(cCodProd)+", com saldo Protheus "+AllTrim(Str(nSaldoSB2))+" Saldo atual Wis "+AllTrim(Str(::_nSaldoWis))+" Armazem "+cArmazem+", sera utilizado saldo Protheus !")
		Endif
	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 

Return Nil 

	

//Metodo para retornar saldo do WIS
Method RetSaldoWIS() class SaldoCAOAPEC
	Local cQryWis	  	:= ""
	Local cAlsWis		:= GetNextAlias()
	Local nSaldoWIS     := 0
	Local cMarca		:= ::_cMarca
	Local lResIntegr	:= ::_lResIntegr
	Local cConectWis    := ::_cConectWis
	Local cCodProd		:= ::_cCodProd
	Local cArmazem  	:= ::_cArmazem
	Local lVlLocWIS		:= ::_lVlLocWIS

	Begin Sequence
		//Caso esteja em branco deve estar posicionado no VS1 para trazer a marca
		If Empty(cMarca) 
			cMarca		:= VS1->VS1_XMARCA
			::_cMarca 	:= cMarca
		Endif
		If Select( (cAlsWis) ) > 0
			(cAlsWis)->(DbCloseArea())
		EndIf
		//passado por José Totvs 19/05/2023
		If lResIntegr   //trata reserva na integração
			cQryWis := " SELECT CASE WHEN NVL(SUM(ESTWIS.QT_ESTOQUE - ESTWIS.QT_RESERVA_SAIDA),0)- MAX(ESTWIS.QT_TRANSITO_SAIDA) > 0 THEN NVL(SUM(ESTWIS.QT_ESTOQUE - ESTWIS.QT_RESERVA_SAIDA),0)- MAX(ESTWIS.QT_TRANSITO_SAIDA) ELSE 0 END AS QTDE_EST "
		Else
			cQryWis := " SELECT NVL(SUM(ESTWIS.QT_ESTOQUE - ESTWIS.QT_RESERVA_SAIDA), 0) AS QTDE_EST "
		Endif
		//cQryWis := " SELECT NVL(SUM(ESTWIS.QT_ESTOQUE - ESTWIS.QT_RESERVA_SAIDA), 0) AS QTDE_EST "
		cQryWis += " FROM " + cConectWis + " ESTWIS "
		cQryWis += " WHERE RTRIM(LTRIM(ESTWIS.CD_PRODUTO)) = '" + AllTrim(cCodProd) + "' "

		//Início - OneGate001 - nova empresa 90 | HMB
		If ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa 02-Franco da Rocha
			If AllTrim(cMarca) =="CHE"
				cQryWis += " AND ESTWIS.CD_EMPRESA = 1002 "
			ElseIf AllTrim(cMarca) == "SBR"
				cQryWis += " AND ESTWIS.CD_EMPRESA = 1006 "
			ElseIf AllTrim(cMarca) =="HYU"
				cQryWis += " AND ESTWIS.CD_EMPRESA = 1006 "
			EndIf
		ElseIf( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) //90- HMB
			If AllTrim(cMarca) =="HYU"
				cQryWis += " AND ESTWIS.CD_EMPRESA = 1008 "
			EndIf
		EndIf
		/*
		If AllTrim(cMarca) $ "HYU_SBR"
			cQryWIS += " AND CD_EMPRESA = 1006 " //-- HYU SBR
		ElseIf AllTrim(cMarca) $ "CHE"  
			cQryWIS += " AND CD_EMPRESA = 1002 " //-- CHE
		EndIf
		*/
		//Fim - OneGate001 - nova empresa 90 | HMB
		If lVlLocWIS	
			If cArmazem == "01" //BARUERI
				cQryWIS += " AND ARMAZEM = 'BAR' " //-- Armazenagem BARUERI.
			ElseIf cArmazem == "11" //FRANCO DA ROCHA
				cQryWIS += " AND ARMAZEM = 'FDR' " //-- Armazenagem FRANCO DA ROCHA
			EndIf
		Endif
	
		DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryWis), cAlsWIS, .T., .T. )
		DbSelectArea((cAlsWis))
		(cAlsWis)->(dbGoTop())
		If !(cAlsWis)->(EoF())
			nSaldoWIS := (cAlsWis)->QTDE_EST
		Else
			nSaldoWIS := 0
		EndIf
		//nSaldoWIS := 1000 // para Simular saldo no WIS
		//apaga arquivo temporario criado
		If Select((cAlsWis)) <> 0
			(cAlsWis)->(DbCloseArea())
			Ferase(cAlsWis+GetDBExtension())
		Endif 
		//Atribuo o saldo WIS ao objeto
		::_nSaldoWIS := nSaldoWIS
	End Sequence	
Return nSaldoWIS


