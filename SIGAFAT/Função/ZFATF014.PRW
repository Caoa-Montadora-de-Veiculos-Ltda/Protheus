#Include "Totvs.CH"

/*
=====================================================================================
Programa.:              ZFATF014
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              28/07/2022
Descricao / Objetivo:   Ajusta os limites de Crédito
Doc. Origem:            
Solicitante:            Faturamento/Pecas
Uso......:              
Obs......:              TESTE DE COMMIT
@history    DAC Denilso - 06/04/2023	        
            GRUPO CAOA GAP FIN108 - Revitaliza��o Credito [ Montadora ]
            Unifica��o Pe�as com Montadora
=====================================================================================
*/

User Function ZFATF014(_cCliFat, _cTpCred, _cLoja, _lZera)
Local _aArea      	:= GetArea()
Local _nValAtr 		:= 0
Local _nValAbe 		:= 0
Local _nValBo 		:= 0
Local _nValPed 		:= 0
Local _nValCred		:= 0   //implementar para NCC como cr�dito
Local _cRet			:= ""
Local _cPgNAval		:= AllTrim(SuperGetMV( "MV_CPNCLC" 	,,"")) 	//condi��o de pagamento n�o ser� avaliado LC
Local _cPgFP 		:= AllTrim(SuperGetMV( "CMV_PEC018" ,,""))  //condi��o de pagamento Forplan = 005 	
Local _cPgCAOA		:= AllTrim(SuperGetMV( "CMV_FAT007" ,,"")) 	//condi��o de pagamento CAOA 
Local _cTpOper      := AllTrim(SuperGetMV( "CAOA_TPLIM" ,,""))  //Tipos de Opera��o para analise do cr�dito - CAOA   54;91;90;67;82;93

Default _cCliFat 	:= ""
Default _cLoja 		:= ""
Default _cTpCred	:= ""
Default _lZera		:= .F.

Begin Sequence	
	//Tem que vir informado o Cliente
	If Empty(_cCliFat)
		//quando n�o informar o cliente faturamento avaliar todos os clientes
		ZFAT014GER(/*_cCliFat*/ ,/* _cLoja */)  //quando geral n�o enviar a loja
		Break
	Endif
	//Caso n�o venha a loja informado localizo a principal que deve ter a referencias do cr�dito DAC 28/03/2023
	If Empty(_cLoja) .or. Empty(_cTpCred)
		_cLoja	:= ZFATF014LJ( _cCliFat, _cLoja, @_cTpCred)
	Endif
	//Se continuar vazio retorno os valores zerados
	If Empty(_cLoja) .or. Empty(_cTpCred)
		Break	
	Endif	
	_nValAtr 	:= ZFATF14TAT(_cCliFat, _cTpCred, _cTpOper, _cPgNAval, _cPgFP, _cPgCAOA) //Verifica os Titulos Em Atraso a mais de 3 dias.
	_nValAbe 	:= ZFATF14TAB(_cCliFat, _cTpCred, _cTpOper, _cPgNAval, _cPgFP, _cPgCAOA) //Verifica os Titulos Em Aberto
	//Na quest�o BO foi necessario separar pois � verificado VS1 para pe�as e SC6 para Fabrica
	//para Fabrica 
	If FWCodEmp() == "2010"
		_nValBo  	:= ZFATF14TBF(_cCliFat, _cTpCred, _cTpOper, _cPgNAval, _cPgFP, _cPgCAOA) //Verifica os Pedidos Em Bo
		_nValPed 	:= ZFATF14TPF(_cCliFat, _cTpCred, _cTpOper, _cPgNAval, _cPgFP, _cPgCAOA) //Verifica os Pedidos Em Reserva/Em Faturamento/Em Separa��o
	//Para Pe�as
	ElseIf FWCodEmp() == "2020"
		_nValBo  	:= ZFATF14TBP(_cCliFat, _cTpCred, _cTpOper, _cPgNAval, _cPgFP, _cPgCAOA) //Verifica os Pedidos Em Bo
		_nValPed 	:= ZFATF14TPP(_cCliFat, _cTpCred, _cTpOper, _cPgNAval, _cPgFP, _cPgCAOA) //Verifica os Pedidos Em Reserva/Em Faturamento/Em Separa��o
	Endif

	/*  Caso incluam credito avaliar se tem NCC para retornar cr�dito, Financeiro CAOA informou que atualmente n�o calcula o Cr�dito para L.C.
	_nValCred 	:= ZProc040(_cCliFat, _cTpCred, _cTpOper, _cPgNAval, _cPgFP, _cPgCAOA)
	*/
	_cRet := ZFATF14SA1(_cCliFat, _cTpCred, _nValAtr, _nValAbe, _nValBo, _nValPed, _nValCred, _cLoja) //Grava os Dados na SA1
	//Zera todas as lojas que est�o com tipo de limite igaula 0=N�o tem
	If _lZera
		ZF014ZERLC( _cCliFat , _cLoja, _cTpCred)
	EndIf
End Sequence	
RestArea(_aArea)
Return({_cRet, _nValAtr, _nValAbe, _nValBo, _nValPed, _nValCred})

/*/{Protheus.doc} ZFATF014TA
Verifica os Titulos Em Atraso a mais de 3 dias.
@param     	_cCliFat	,c�digo cliente
			_cTpCred	,tipo de cr�dito utilizado 
			_cTpOper	,tipo de opera��o a ser utilizada
			_cPgNAval	,condi��o de pgto a vista 	
			_cPgFP		,condi��o de pagamento Forplan  
			_cPgCAOA,	,condi��o de pagamento CAO
@return		_nValAtraso	,Valores em atraso
@author     CAOA - Evandro A Mariano dos Santos 
@version    12.1.17 / Superior
@project	GRUPO CAOA 
@since      28/07/2022
@history 	28/03/2023	,GAP FIN108 - Revitaliza��o Credito [ Montadora ]
						 Ajustando funcionalidade para utilizar LC na Montadora como em Barueri
/*/
Static Function ZFATF14TAT(_cCliFat, _cTpCred, _cTpOper, _cPgNAval, _cPgFP, _cPgCAOA)
Local _cAliasPesq  	:= GetNextAlias()
Local _nValAtraso  	:= 0
Local _nDiasAtraso	:= SuperGetMV( "CMV_PEC027"  ,,3 ) 
Local _DtAtraso		:= Date()
Local _cWhereSF2	:= ""
Local _cWhereSE1	:= ""

Begin Sequence
	_DtAtraso := ( _DtAtraso - _nDiasAtraso )
	//condi��o de pagamento Forplan = 005
	If _cTpCred == '1' .And. !Empty(_cPgFP) 
		_cWhereSF2 += " 	AND SF2.F2_COND IN "+ FormatIn(_cPgFP,";")		
	//condi��o de pagamento CAOA
	ElseIf _cTpCred == '2'  .And. !Empty(_cPgCAOA) 
		_cWhereSF2 += " 	AND SF2.F2_COND IN "+ FormatIn(_cPgCAOA,";") 
	EndIf
	//Caso esteja informado condi��o de pgto a vista n�o computar nos valores DAC 07/03/2023
	If !Empty(_cPgNAval) //Cond. de pagto. p/ venda a vista sem limite Credit
		_cWhereSF2 += " 	AND SF2.F2_COND NOT IN  "+ FormatIn(_cPgNAval,";")  
	Endif	 		
	//verificar pelo tipo de opera��o utilizado em Anapolis
	If !Empty(_cTpOper) .and. FWCodEmp() == "2010"  //somente para Anapolis
		_cWhereSE1 += " AND SE1.E1_PEDIDO = (SELECT C6_NUM "
		_cWhereSE1 += "						FROM "+ RetSQLName('SC6') +" SC6 "		
		_cWhereSE1 += "						WHERE  	SC6.C6_FILIAL 	= '"+FwXFilial("SC6")+"' " 		
		_cWhereSE1 += "							AND SC6.C6_NUM 		= SE1.E1_PEDIDO
		_cWhereSE1 += "							AND SC6.C6_OPER IN "+ FormatIn(_cTpOper,";") + " "
		_cWhereSE1 += "							AND SC6.D_E_L_E_T_ 	= ' '
		_cWhereSE1 += "							GROUP BY SC6.C6_NUM )"
	ElseIf !Empty(_cTpOper) .and. FWCodEmp() == "2020"  //somente para 
		_cWhereSF2 += " AND SF2.F2_DOC 	= ( SELECT VS1.VS1_NUMNFI "
		_cWhereSF2 += "						FROM "+ RetSQLName('VS1') +" VS1 "
		_cWhereSF2 += "						JOIN "+ RetSQLName('VS3') +" VS3 "
		_cWhereSF2 += "							ON 	VS3.VS3_FILIAL 	= '"+FwXFilial("VS3")+"' " 		
		_cWhereSF2 += "							AND VS3.VS3_NUMORC 	= VS1.VS1_NUMORC
		_cWhereSF2 += "							AND VS3.VS3_OPER IN "+ FormatIn(_cTpOper,";") + " "
		_cWhereSF2 += "							AND VS3.D_E_L_E_T_ 	= ' '
		_cWhereSF2 += "						WHERE	VS1.VS1_FILIAL 	= '"+FwXFilial("VS1")+"' " 		
		_cWhereSF2 += "							AND VS1.VS1_NUMNFI	= SF2.F2_DOC "
		_cWhereSF2 += "							AND VS1.VS1_SERNFI	= SF2.F2_SERIE "
		_cWhereSF2 += "							AND VS1.D_E_L_E_T_ 	= ' '		
		_cWhereSF2 += "							GROUP BY VS1.VS1_NUMNFI )"
	Endif

	_cWhereSF2 := "%"+_cWhereSF2+"%"
	_cWhereSE1 := "%"+_cWhereSE1+"%"

	//Procura os titulos em aberto no financeiro.
	BeginSql Alias _cAliasPesq //Define o nome do alias tempor�rio 
		SELECT SE1.E1_CLIENTE, SUM(SE1.E1_SALDO) AS TIT_VENCIDO 
		FROM %table:SE1% SE1 
		JOIN  %Table:SF2% SF2  												
			ON 	SF2.F2_FILIAL 	= %XFilial:SF2%										
			AND SF2.F2_DOC 		= SE1.E1_NUM 
			AND SF2.F2_SERIE 	= SE1.E1_PREFIXO 
			AND SF2.F2_CLIENTE 	= SE1.E1_CLIENTE
			AND SF2.F2_LOJA 	= SE1.E1_LOJA
			AND SF2.F2_EMISSAO 	= SE1.E1_EMISSAO 
			AND SF2.F2_COND 	<> ' ' 
			AND SF2.%notDel%
			%Exp:_cWhereSF2%
		WHERE SE1.%notDel%																
			AND SE1.E1_FILIAL 	= %XFilial:SE1%
			AND SE1.E1_CLIENTE 	=  %Exp:_cCliFat%	
			AND SE1.E1_VENCREA  < %Exp:Dtos(_DtAtraso)%
			AND SE1.E1_SALDO 	> 0 	
			AND SE1.E1_TIPO NOT IN ('NCC','_RA')
			%Exp:_cWhereSE1%
		GROUP BY SE1.E1_CLIENTE 
		ORDER BY SE1.E1_CLIENTE 
	EndSql
	If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->TIT_VENCIDO == 0
		Break
	EndIf	
	_nValAtraso := (_cAliasPesq)->TIT_VENCIDO
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return(_nValAtraso)


/*/{Protheus.doc} ZFATF14TAB
Verifica os Titulos Em Aberto
@param     	_cCliFat	,c�digo cliente
			_cTpCred	,tipo de cr�dito utilizado 
			_cTpOper	,tipo de opera��o a ser utilizada
			_cPgNAval	,condi��o de pgto a vista 	
			_cPgFP		,condi��o de pagamento Forplan  
			_cPgCAOA,	,condi��o de pagamento CAO
@return		_nValAberto	,Valores em aberto
@author     CAOA - Evandro A Mariano dos Santos 
@version    12.1.17 / Superior
@project	GRUPO CAOA 
@since      28/07/2022
@history 	28/03/2023	,GAP FIN108 - Revitaliza��o Credito [ Montadora ]
						 Ajustando funcionalidade para utilizar LC na Montadora como em Barueri
/*/
Static Function ZFATF14TAB(_cCliFat, _cTpCred, _cTpOper, _cPgNAval, _cPgFP, _cPgCAOA)
Local _cAliasPesq  	:= GetNextAlias()
Local _nValAberto  	:= 0
Local _cWhereSF2	:= ""
Local _cWhereSE1	:= ""

Begin Sequence
	//condi��o de pagamento Forplan = 005
	If _cTpCred == '1' .And. !Empty(_cPgFP) 
		_cWhereSF2 += " 	AND SF2.F2_COND IN "+ FormatIn(_cPgFP,";")		
	//condi��o de pagamento CAOA
	ElseIf _cTpCred == '2'  .And. !Empty(_cPgCAOA) 
		_cWhereSF2 += " 	AND SF2.F2_COND IN "+ FormatIn(_cPgCAOA,";") 
	EndIf
	//Caso esteja informado condi��o de pgto a vista n�o computar nos valores DAC 07/03/2023
	If !Empty(_cPgNAval) //Cond. de pagto. p/ venda a vista sem limite Credit
		_cWhereSF2 += " 	AND SF2.F2_COND NOT IN  "+ FormatIn(_cPgNAval,";")  
	Endif	 		
	//verificar pelo tipo de opera��o utilizado em Anapolis
	If !Empty(_cTpOper) .and. FWCodEmp() == "2010"  //somente para Anapolis
		_cWhereSE1 += " AND SE1.E1_PEDIDO = (SELECT C6_NUM "
		_cWhereSE1 += "						FROM "+ RetSQLName('SC6') +" SC6 "		
		_cWhereSE1 += "						WHERE  	SC6.C6_FILIAL 	= '"+FwXFilial("SC6")+"' " 		
		_cWhereSE1 += "							AND SC6.C6_NUM 		= SE1.E1_PEDIDO
		_cWhereSE1 += "							AND SC6.C6_OPER IN "+ FormatIn(_cTpOper,";") + " "
		_cWhereSE1 += "							AND SC6.D_E_L_E_T_ 	= ' '
		_cWhereSE1 += "							GROUP BY SC6.C6_NUM )"
	ElseIf !Empty(_cTpOper) .and. FWCodEmp() == "2020"  //somente para 
		_cWhereSF2 += " AND SF2.F2_DOC 	= ( SELECT VS1.VS1_NUMNFI "
		_cWhereSF2 += "						FROM "+ RetSQLName('VS1') +" VS1 "
		_cWhereSF2 += "						JOIN "+ RetSQLName('VS3') +" VS3 "
		_cWhereSF2 += "							ON 	VS3.VS3_FILIAL 	= '"+FwXFilial("VS3")+"' " 		
		_cWhereSF2 += "							AND VS3.VS3_NUMORC 	= VS1.VS1_NUMORC
		_cWhereSF2 += "							AND VS3.VS3_OPER IN "+ FormatIn(_cTpOper,";") + " "
		_cWhereSF2 += "							AND VS3.D_E_L_E_T_ 	= ' '
		_cWhereSF2 += "						WHERE	VS1.VS1_FILIAL 	= '"+FwXFilial("VS1")+"' " 		
		_cWhereSF2 += "							AND VS1.VS1_NUMNFI	= SF2.F2_DOC "
		_cWhereSF2 += "							AND VS1.VS1_SERNFI	= SF2.F2_SERIE "
		_cWhereSF2 += "							AND VS1.D_E_L_E_T_ 	= ' '		
		_cWhereSF2 += "							GROUP BY VS1.VS1_NUMNFI )"
	Endif
	_cWhereSF2 := "%"+_cWhereSF2+"%"
	_cWhereSE1 := "%"+_cWhereSE1+"%"

	//Procura os titulos em aberto no financeiro.
	BeginSql Alias _cAliasPesq //Define o nome do alias tempor�rio 
		SELECT SE1.E1_CLIENTE, SUM(SE1.E1_SALDO) AS TIT_ABERTO 
		FROM %table:SE1% SE1 
		JOIN  %Table:SF2% SF2  												
			ON 	SF2.F2_FILIAL 	= %XFilial:SF2%										
			AND SF2.F2_DOC 		= SE1.E1_NUM 
			AND SF2.F2_SERIE 	= SE1.E1_PREFIXO 
			AND SF2.F2_CLIENTE 	= SE1.E1_CLIENTE
			AND SF2.F2_LOJA 	= SE1.E1_LOJA
			AND SF2.F2_EMISSAO 	= SE1.E1_EMISSAO 
			AND SF2.F2_COND 	<> ' ' 
			AND SF2.%notDel%
			%Exp:_cWhereSF2%
		WHERE SE1.%notDel%																
			AND SE1.E1_FILIAL 	= %XFilial:SE1%
			AND SE1.E1_CLIENTE 	=  %Exp:_cCliFat%	
			AND SE1.E1_SALDO 	> 0 	
			AND SE1.E1_TIPO NOT IN ('NCC','_RA')
			%Exp:_cWhereSE1%
		GROUP BY SE1.E1_CLIENTE 
		ORDER BY SE1.E1_CLIENTE 
	EndSql
	If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->TIT_ABERTO == 0
		Break
	EndIf	
	_nValAberto := (_cAliasPesq)->TIT_ABERTO
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return(_nValAberto)



/*/{Protheus.doc} ZFATF14TBP
Verifica os Pedidos Em Bo
@param     	_cCliFat	,c�digo cliente
			_cTpCred	,tipo de cr�dito utilizado 
			_cTpOper	,tipo de opera��o a ser utilizada
			_cPgNAval	,condi��o de pgto a vista 	
			_cPgFP		,condi��o de pagamento Forplan  
			_cPgCAOA,	,condi��o de pagamento CAO
@return		_nValBO		,Pedidos em aberto
@author     CAOA - Evandro A Mariano dos Santos 
@version    12.1.17 / Superior
@project	GRUPO CAOA 
@since      28/07/2022
@history 	28/03/2023	,GAP FIN108 - Revitaliza��o Credito [ Montadora ]
						 Ajustando funcionalidade para utilizar LC na Montadora como em Barueri
/*/
Static Function ZFATF14TBP(_cCliFat, _cTpCred, _cTpOper, _cPgNAval, _cPgFP, _cPgCAOA)
Local _cAliasPesq  	:= GetNextAlias()
Local _nFatorRed    := SuperGetMV("CMV_PEC035",,0)
Local _nValBO  		:= 0
Local _cWhereVS1	:= ""

Begin Sequence
	//condi��o de pagamento Forplan = 005
	If _cTpCred == '1' .And. !Empty(_cPgFP) 
		_cWhereVS1 += " 	AND VS1.VS1_FORPAG  IN "+ FormatIn(_cPgFP,";")		
	//condi��o de pagamento CAOA
	ElseIf _cTpCred == '2'  .And. !Empty(_cPgCAOA) 
		_cWhereVS1 += " 	AND VS1.VS1_FORPAG  IN "+ FormatIn(_cPgCAOA,";") 
	EndIf
	//Caso esteja informado condi��o de pgto a vista n�o computar nos valores DAC 07/03/2023
	If !Empty(_cPgNAval) //Cond. de pagto. p/ venda a vista sem limite Credit
		_cWhereVS1 += " 	AND VS1.VS1_FORPAG  NOT IN  "+ FormatIn(_cPgNAval,";")  
	Endif	 		
	//verificar pelo tipo de opera��o utilizado em Anapolis
	If !Empty(_cTpOper)  
		_cWhereVS1 += " AND VS1.VS1_NUMORC 	= ( SELECT VS3.VS3_NUMORC "
		_cWhereVS1 += "						FROM "+ RetSQLName('VS3') +" VS3 "
		_cWhereVS1 += "						WHERE VS3.D_E_L_E_T_ 	= ' ' "
		_cWhereVS1 += "							AND	VS3.VS3_FILIAL 	= '"+FwXFilial("VS3")+"' " 		
		_cWhereVS1 += "							AND VS3.VS3_NUMORC 	= VS1.VS1_NUMORC
		_cWhereVS1 += "							AND VS3.VS3_OPER IN "+ FormatIn(_cTpOper,";") + " "
		_cWhereVS1 += "							GROUP BY VS3.VS3_NUMORC )"
	Endif
	_cWhereVS1 := "%"+_cWhereVS1+"%"

	//Procura os titulos em aberto no financeiro.
	BeginSql Alias _cAliasPesq //Define o nome do alias tempor�rio 
		SELECT NVL(SUM(VS1.VS1_VTOTNF),0) AS TIT_VS1BO
		FROM %table:VS1% VS1 
		WHERE VS1.%notDel%																
			AND VS1.VS1_FILIAL 	= %XFilial:VS1%
			AND VS1.VS1_CLIFAT 	=  %Exp:_cCliFat%	
			AND VS1.VS1_FORPAG  <> ' '
			AND VS1.VS1_STATUS IN ('0','3')
			%Exp:_cWhereVS1%
	EndSql
	If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->TIT_VS1BO == 0
		Break
	EndIf	
	If _nFatorRed > 0
		//para garantir que execute somente at� 100 %
		If _nFatorRed > 100
			_nFatorRed := 100
		Endif
		_nValBO := (_cAliasPesq)->TIT_VS1BO * (_nFatorRed / 100)
	Else
		_nValBO := (_cAliasPesq)->TIT_VS1BO 
	Endif	
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return(_nValBO)



/*/{Protheus.doc} ZFATF14TBF
Verifica os Pedidos Em Bo
@param     	_cCliFat	,c�digo cliente
			_cTpCred	,tipo de cr�dito utilizado 
			_cTpOper	,tipo de opera��o a ser utilizada
			_cPgNAval	,condi��o de pgto a vista 	
			_cPgFP		,condi��o de pagamento Forplan  
			_cPgCAOA,	,condi��o de pagamento CAO
@return		_nValBO		,Pedidos em aberto
@author     CAOA - Evandro A Mariano dos Santos 
@version    12.1.17 / Superior
@project	GRUPO CAOA 
@since      28/07/2022
@history 	28/03/2023	,GAP FIN108 - Revitaliza��o Credito [ Montadora ]
						 Ajustando funcionalidade para utilizar LC na Montadora como em Barueri
/*/
Static Function ZFATF14TBF(_cCliFat, _cTpCred, _cTpOper, _cPgNAval, _cPgFP, _cPgCAOA)
Local _cAliasPesq  	:= GetNextAlias()
Local _nFatorRed    := SuperGetMV("CMV_PEC035",,0)
Local _nValBO  		:= 0
Local _cWhereSC5	:= ""
Local _cWhereSC6	:= ""

Begin Sequence
	//condi��o de pagamento Forplan = 005
	If _cTpCred == '1' .And. !Empty(_cPgFP) 
		_cWhereSC5 += " 	AND SC5.C5_CONDPAG  IN "+ FormatIn(_cPgFP,";")		
	//condi��o de pagamento CAOA
	ElseIf _cTpCred == '2'  .And. !Empty(_cPgCAOA) 
		_cWhereSC5 += " 	AND SC5.C5_CONDPAG  IN "+ FormatIn(_cPgCAOA,";") 
	EndIf
	//Caso esteja informado condi��o de pgto a vista n�o computar nos valores DAC 07/03/2023
	If !Empty(_cPgNAval) //Cond. de pagto. p/ venda a vista sem limite Credit
		_cWhereSC5 += " 	AND SC5.C5_CONDPAG  NOT IN  "+ FormatIn(_cPgNAval,";")  
	Endif	 		
	//verificar pelo tipo de opera��o utilizado em Anapolis
	If !Empty(_cTpOper)  
		_cWhereSC6 += " AND SC6.C6_OPER IN "+ FormatIn(_cTpOper,";") + " "
	Endif
	_cWhereSC5 := "%"+_cWhereSC5+"%"
	_cWhereSC6 := "%"+_cWhereSC6+"%"

	//Procura os titulos em aberto no financeiro.
	BeginSql Alias _cAliasPesq //Define o nome do alias tempor�rio 
		SELECT NVL(SUM(SC6.C6_VALOR),0) AS TIT_SC6BO  
		FROM %Table:SC6% SC6  		
		JOIN %Table:SC5% SC5  		
			ON 	SC5.C5_FILIAL 	= %XFilial:SC5%
			AND SC5.C5_NUM		= SC6.C6_NUM	
			AND SC5.C5_NOTA     = ' '
			AND (SC5.C5_BLQ		<> ' ' OR SC5.C5_CONDPAG 	= ' ')
			AND SC5.%notDel%
			%Exp:_cWhereSC5%
		WHERE SC6.C6_FILIAL 	= %XFilial:SC6%
			AND SC6.C6_CLI     	= %Exp:_cCliFat%	
			AND SC6.%notDel%
			%Exp:_cWhereSC6%
	EndSql
	//			AND SC5.C5_LIBEROK NOT IN('E','S',' ') 
	If (_cAliasPesq)->(Eof())  .Or. (_cAliasPesq)->TIT_SC6BO == 0
		Break
	EndIf	
	If _nFatorRed > 0
		//para garantir que execute somente at� 100 %
		If _nFatorRed > 100
			_nFatorRed := 100
		Endif
		_nValBO := (_cAliasPesq)->TIT_SC6BO * (_nFatorRed / 100)
	Else
		_nValBO := (_cAliasPesq)->TIT_SC6BO 
	Endif	
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return(_nValBO)



/*/{Protheus.doc} ZFATF14TPP
Verifica os Pedidos Em Reserva/Em Faturamento/Em Separa��o Pe�as
@param     	_cCliFat	,c�digo cliente
			_cTpCred	,tipo de cr�dito utilizado 
			_cTpOper	,tipo de opera��o a ser utilizada
			_cPgNAval	,condi��o de pgto a vista 	
			_cPgFP		,condi��o de pagamento Forplan  
			_cPgCAOA,	,condi��o de pagamento CAO
@return		_nValPed	,Pedidos faturados
@author     CAOA - Evandro A Mariano dos Santos 
@version    12.1.17 / Superior
@project	GRUPO CAOA 
@since      28/07/2022
@history 	28/03/2023	,GAP FIN108 - Revitaliza��o Credito [ Montadora ]
						 Ajustando funcionalidade para utilizar LC na Montadora como em Barueri
/*/
Static Function ZFATF14TPP(_cCliFat, _cTpCred, _cTpOper, _cPgNAval, _cPgFP, _cPgCAOA)
Local _cAliasPesq  	:= GetNextAlias()
Local _nValPed 		:= 0
Local _cWhereVS1	:= ""

Begin Sequence
	//condi��o de pagamento Forplan = 005
	If _cTpCred == '1' .And. !Empty(_cPgFP) 
		_cWhereVS1 += " 	AND VS1.VS1_FORPAG  IN "+ FormatIn(_cPgFP,";")		
	//condi��o de pagamento CAOA
	ElseIf _cTpCred == '2'  .And. !Empty(_cPgCAOA) 
		_cWhereVS1 += " 	AND VS1.VS1_FORPAG  IN "+ FormatIn(_cPgCAOA,";") 
	EndIf
	//Caso esteja informado condi��o de pgto a vista n�o computar nos valores DAC 07/03/2023
	If !Empty(_cPgNAval) //Cond. de pagto. p/ venda a vista sem limite Credit
		_cWhereVS1 += " 	AND VS1.VS1_FORPAG  NOT IN  "+ FormatIn(_cPgNAval,";")  
	Endif	 		
	//verificar pelo tipo de opera��o utilizado em Anapolis
	If !Empty(_cTpOper)  
		_cWhereVS1 += " AND VS1.VS1_NUMORC 	= ( SELECT VS3.VS3_NUMORC "
		_cWhereVS1 += "						FROM "+ RetSQLName('VS3') +" VS3 "
		_cWhereVS1 += "						WHERE VS3.D_E_L_E_T_ 	= ' ' "
		_cWhereVS1 += "							AND	VS3.VS3_FILIAL 	= '"+FwXFilial("VS3")+"' " 		
		_cWhereVS1 += "							AND VS3.VS3_NUMORC 	= VS1.VS1_NUMORC
		_cWhereVS1 += "							AND VS3.VS3_OPER IN "+ FormatIn(_cTpOper,";") + " "
		_cWhereVS1 += "							GROUP BY VS3.VS3_NUMORC )"
	Endif
	_cWhereVS1 := "%"+_cWhereVS1+"%"

	//Procura os titulos em aberto no financeiro.
	BeginSql Alias _cAliasPesq //Define o nome do alias tempor�rio 
		SELECT NVL(SUM(VS1.VS1_VTOTNF),0) AS TIT_PEDIDO
		FROM %table:VS1% VS1 
		WHERE VS1.VS1_FILIAL 	= %XFilial:VS1%
			AND VS1.VS1_CLIFAT 	=  %Exp:_cCliFat%	
			AND VS1.VS1_FORPAG  <> ' '
			AND VS1.VS1_STATUS IN ('R','F','4')
			AND VS1.%notDel% 
			%Exp:_cWhereVS1%
	EndSql
	If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->TIT_PEDIDO == 0
		Break
	EndIf	
	_nValPed := (_cAliasPesq)->TIT_PEDIDO 
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return(_nValPed)


/*/{Protheus.doc} ZFATF14TPF
Verifica os Pedidos Em Reserva/Em Faturamento/Em Separa��o Pe�as
@param     	_cCliFat	,c�digo cliente
			_cTpCred	,tipo de cr�dito utilizado 
			_cTpOper	,tipo de opera��o a ser utilizada
			_cPgNAval	,condi��o de pgto a vista 	
			_cPgFP		,condi��o de pagamento Forplan  
			_cPgCAOA,	,condi��o de pagamento CAO
@return		_nValBO		,Pedidos em aberto
@author     CAOA - Evandro A Mariano dos Santos 
@version    12.1.17 / Superior
@project	GRUPO CAOA 
@since      28/07/2022
@history 	28/03/2023	,GAP FIN108 - Revitaliza��o Credito [ Montadora ]
						 Ajustando funcionalidade para utilizar LC na Montadora como em Barueri
/*/

Static Function ZFATF14TPF(_cCliFat, _cTpCred, _cTpOper, _cPgNAval, _cPgFP, _cPgCAOA)
Local _cAliasPesq  	:= GetNextAlias()
Local _nValPed  	:= 0
Local _cWhereSC5	:= ""
Local _cWhereSC6	:= ""

Begin Sequence
	//condi��o de pagamento Forplan = 005
	If _cTpCred == '1' .And. !Empty(_cPgFP) 
		_cWhereSC5 += " 	AND SC5.C5_CONDPAG  IN "+ FormatIn(_cPgFP,";")		
	//condi��o de pagamento CAOA
	ElseIf _cTpCred == '2'  .And. !Empty(_cPgCAOA) 
		_cWhereSC5 += " 	AND SC5.C5_CONDPAG  IN "+ FormatIn(_cPgCAOA,";") 
	EndIf
	//Caso esteja informado condi��o de pgto a vista n�o computar nos valores DAC 07/03/2023
	If !Empty(_cPgNAval) //Cond. de pagto. p/ venda a vista sem limite Credit
		_cWhereSC5 += " 	AND SC5.C5_CONDPAG  NOT IN  "+ FormatIn(_cPgNAval,";")  
	Endif	 		
	//verificar pelo tipo de opera��o utilizado em Anapolis
	If !Empty(_cTpOper)  
		_cWhereSC6 += " AND SC6.C6_OPER IN "+ FormatIn(_cTpOper,";") + " "
	Endif
	_cWhereSC5 := "%"+_cWhereSC5+"%"
	_cWhereSC6 := "%"+_cWhereSC6+"%"

	//Procura os titulos em aberto no financeiro.
	BeginSql Alias _cAliasPesq //Define o nome do alias tempor�rio 
		SELECT NVL(SUM(SC6.C6_VALOR),0) AS TIT_PEDIDO  
		FROM %Table:SC6% SC6  		
		JOIN %Table:SC5% SC5  		
			ON 	SC5.C5_FILIAL 	= %XFilial:SC5%
			AND SC5.C5_NUM		= SC6.C6_NUM	
			AND SC5.C5_NOTA     = ' '
			AND SC5.C5_BLQ		= ' '
			AND SC5.C5_LIBEROK NOT IN( 'E') 
			AND SC5.C5_CONDPAG 	<> ' '
			AND SC5.%notDel%
			%Exp:_cWhereSC5%
		WHERE SC6.C6_FILIAL 	= %XFilial:SC6%
			AND SC6.C6_CLI     	= %Exp:_cCliFat%	
			AND SC6.%notDel%
			%Exp:_cWhereSC6%
	EndSql
	//		AND SC5.C5_BLQ		= ' '
	/* caso seja necess�rio validar item
			SELECT
				C9_OK,
				C9_PEDIDO,
				C9_CLIENTE,
				C9_LOJA,
				C9_BLEST
			FROM %Table:SC9% SC9
			WHERE
					SC9.%NotDel%
				AND SC9.C9_FILIAL = %xFilial:SC9%
				AND %Exp:cWhere%
				AND SC9.C9_NFISCAL = ' '
			GROUP BY
				C9_OK,C9_PEDIDO,C9_CLIENTE,C9_LOJA,C9_BLEST
		*/

	If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->TIT_PEDIDO == 0
		Break
	EndIf	
	_nValPed := (_cAliasPesq)->TIT_PEDIDO 
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return(_nValPed)


/*/{Protheus.doc} ZFATF14SA1
Grava os Dados do Limite de Cr�dito na SA1
@param      _cCliFat 	- Codigo do cliente  
@return     _cLoja
@author     CAOA - Evandro A Mariano dos Santos
@version    12.1.17 / Superior
@project	GRUPO CAOA 
@since      28/07/2022
@history 	28/03/2023	,GAP FIN108 - Revitaliza��o Credito [ Montadora ]
						 Ajustando funcionalidade para utilizar LC na Montadora como em Barueri
/*/
Static Function ZFATF14SA1(_cCliFat, _cTpCred, _nValAtr, _nValAbe, _nValBo, _nValPed, _nValCred, _cLoja)
Local _cRet			:= ""
Local _cWhere		:= ""
Local _nSaldo		:= 0
Local _cAliasPesq 	:= GetNextAlias()
Local _aGrvLog		:= {}
//Local _nPos
Local nValAtr		:= 0
Local nValAbe		:= 0
Local nValBo 		:= 0
Local nValPed		:= 0
Local nSaldo 		:= 0

//Begin Sequence
	//No caso de n�o estar informada a loja
	If !Empty(_cLoja)
		_cWhere := "AND SA1.A1_LOJA =  '" + _cLoja + "'" 
	Endif
	_cWhere := "%"+_cWhere+"%"

	BeginSql Alias _cAliasPesq //Define o nome do alias tempor�rio 
		SELECT 	ISNULL(SA1.R_E_C_N_O_,0) NREGSA1
		FROM  %Table:SA1% SA1
		WHERE SA1.A1_FILIAL 	= %XFilial:SA1%
			AND SA1.A1_COD  	= %Exp:_cCliFat%
			AND SA1.%notDel%
			%Exp:_cWhere%
	EndSQL	

	If (_cAliasPesq)->(Eof()) .Or. (_cAliasPesq)->NREGSA1 == 0
		Break
	EndIf
	//conforme definido s� pode existir um tipo de cr�dito  o select deve retornar somente 1 registro

	(_cAliasPesq)->(DbGoTop())
	While (_cAliasPesq)->(!Eof())
		SA1->(DbGoto((_cAliasPesq)->NREGSA1))
		
		if SA1->A1_XBLQLC $ '0|1|2'
			If FWCodEmp() == "2010" 
				_nSaldo := ( SA1->A1_XLC - ( _nValAbe  ) )
			Else
				_nSaldo := ( SA1->A1_XLC - ( _nValAbe + _nValBo + _nValPed ) )
			Endif
			nValAtr := ZFATF14DIF(SA1->A1_XFPATR, _nValAtr, "A1_XFPATR", @_aGrvLog) //IiF(_nValAtr >= 0, _nValAtr	, 0)
			nValAbe := ZFATF14DIF(SA1->A1_XLMUSA, _nValAbe, "A1_XLMUSA", @_aGrvLog) //IiF(_nValAbe >= 0, _nValAbe	, 0)
			nValBo  := ZFATF14DIF(SA1->A1_XVALBO, _nValBo , "A1_XVALBO", @_aGrvLog) //IiF(_nValBo  >= 0, _nValBo	, 0)
			nValPed := ZFATF14DIF(SA1->A1_XPEDFP, _nValPed, "A1_XPEDFP", @_aGrvLog) //IiF(_nValPed >= 0, _nValPed	, 0)
			nSaldo  := ZFATF14DIF(SA1->A1_XFPSAL, _nSaldo , "A1_XFPSAL", @_aGrvLog) //IiF(_nSaldo  >= 0, _nSaldo	, 0)
		EndIf
		
		If !SA1->(RecLock("SA1",.F.))
			Break
		EndIf

		If SA1->A1_XBLQLC == "1" //1 - Bloqueio Manual
			SA1->A1_XSTAFP	:= "5"	
			_cRet := "5"
		ElseIf SA1->A1_XBLQLC == "2" //2-Descredenciado. 
			SA1->A1_XTPCRED	:= "0"
			SA1->A1_XLC		:= 0
			SA1->A1_XFPATR	:= 0
			SA1->A1_XLMUSA	:= 0
			SA1->A1_XVALBO	:= 0
			SA1->A1_XPEDFP	:= 0
			SA1->A1_XFPSAL	:= 0
			SA1->A1_XBLQVEN := ""
			SA1->A1_XDTLC	:= CToD("//")
			SA1->A1_XSTAFP	:= "5"	
			_cRet := "5"

		ElseIf SA1->A1_XTPCRED == "0" //0-Nao Possui.
			SA1->A1_XLC		:= 0
			SA1->A1_XFPSAL	:= 0
			SA1->A1_XDTLC	:= CToD("//")
			SA1->A1_XBLQVEN := ""
			SA1->A1_XSTAFP	:= " "
			_cRet := "2"
		
		Else
			
			SA1->A1_XFPATR	:= nValAtr
			SA1->A1_XLMUSA	:= nValAbe
			SA1->A1_XVALBO	:= nValBo 
			SA1->A1_XPEDFP	:= nValPed
			SA1->A1_XFPSAL	:= nSaldo 
			
			If nSaldo <= 0
			
				If SA1->A1_XSTAFP <> "2"
					Aadd(_aGrvLog,{ SA1->A1_XSTAFP, "2", "A1_XSTAFP"})
				EndIf
				SA1->A1_XSTAFP := "2" //FALTA DE SALDO
			
			ElseIf SA1->A1_XDTLC < Date()
			
				If SA1->A1_XSTAFP <> "4"
					Aadd(_aGrvLog,{ SA1->A1_XSTAFP, "4", "A1_XSTAFP"})
				EndIf
				SA1->A1_XSTAFP := "4" //CREDITO VENCIDO
			
			ElseIf SA1->A1_XFPATR > 0
				
				If SA1->A1_XBLQVEN == "1" // BLOQUEIA POR ATRASO SOMENTE SE O Bloq.Vencido = "1-SIM"
					If SA1->A1_XSTAFP <> "3"
						Aadd(_aGrvLog,{ SA1->A1_XSTAFP, "3", "A1_XSTAFP"})
					EndIf
					SA1->A1_XSTAFP := "3" //TITULOS EM ATRASO
				Else
					SA1->A1_XSTAFP := "1" //CREDITO DISPONIVEL
				EndIf
			Else
				If SA1->A1_XSTAFP <> "1"
					Aadd(_aGrvLog,{ SA1->A1_XSTAFP, "1", "A1_XSTAFP"})
				EndIf
				SA1->A1_XSTAFP := "1" //CREDITO DISPONIVEL
			EndIf
			_cRet := SA1->A1_XSTAFP
		EndIf
		SA1->(MsUnlock())
		
		(_cAliasPesq)->(DbSkip())
	EndDo

//End Sequence

If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  

Return(_cRet)
//----------------------------------------------------------------------------------------------------------
//DAC - 13/04/2023
//Retornar o valor a ser gravado ref L.C. e separar para grava��o do Log
Static Function ZFATF14DIF(_nValSa1, _nValCalc,_cCampo, _aGrvLog)
Local _nValRet := Round(_nValSa1,2)
Begin Sequence
	If Round(_nValSa1,2) <> Round(_nValCalc,2) 
		_nValRet := Round(IiF(_nValCalc >= 0, _nValCalc	, 0),2)
		//Se esta zerado  o resultado da avalia��o com o que j� esta gravado n�o gravo log 
		If _nValSa1 == 0 .And. _nValRet == 0
			Break
		Endif	
		Aadd(_aGrvLog,{ _nValSa1, _nValCalc, _cCampo})
	Endif
End Sequence
Return _nValRet

/*/{Protheus.doc} ZFATF014LJ
Localizar a loja para processamento respon�vel pelo Limite de Cr�dito
@param      _cCliFat 	- Codigo do cliente  
@return     _cLoja
@author     DAC Denilso
@version    12.1.17 / Superior
@project	GRUPO CAOA - GAP FIN108 - Revitaliza��o Credito [ Montadora ]
@since      28/03/2023
@history 	
/*/
Static Function ZFATF014LJ(_cCliFat, _cLoja, _cTpCred)
Local _cAliasPesq	:= GetNextAlias()   
Local _cWhere		:= ""

Default _cLoja		:= ""
Default _cTpCred	:= ""

Begin Sequence
	If !Empty(_cLoja)
		_cWhere := "	AND SA1.A1_LOJA = '"+_cLoja+"'"
	Endif
	_cWhere := "%"+_cWhere+"%"
	
	BeginSql Alias _cAliasPesq //Define o nome do alias tempor�rio 
		SELECT 	ISNULL(SA1.R_E_C_N_O_,0) NREGSA1
				FROM  %Table:SA1% SA1
				WHERE SA1.%notDel% 	
					AND SA1.A1_FILIAL   = %XFilial:SA1% 
					AND SA1.A1_COD  	= %Exp:_cCliFat%
					AND SA1.A1_XTPCRED NOT IN (' ','0') 
					%Exp:_cWhere%
	EndSQL	
					/*AND 	(  	 SA1.A1_XTPCRED IN ('1','2') 
							 OR (SA1.A1_XTPCRED = '0' AND A1_XLC > 0) )
					*/	
	If (_cAliasPesq)->(Eof()) .Or. (_cAliasPesq)->NREGSA1 == 0
		Break
	EndIf
	SA1->(DbGoto((_cAliasPesq)->NREGSA1))
	_cLoja		:= SA1->A1_LOJA 
	_cTpCred	:= SA1->A1_XTPCRED 
End Sequence
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _cLoja



//UTILIZADOS PELO DICION�RIO
/*/{Protheus.doc} ZF014VTC
Valida��o criado para ajustar valor do limite de cr�dito quando da opera��o altera��o inclus�o
Esta funcionalidade deve ser utilizada na valia��o do campo A1_XTPCRED em X3_VALID 
@param      _cCodCli 	- Codigo do cliente  
			_cLoja 		- Loja do Cliente 
			_cXtpCred	- Tipo de Cr�dito do Cliente
@return     Logico
@author     DAC Denilso
@version    12.1.17 / Superior
@project	GRUPO CAOA - GAP FIN100 - Campo Matriz Clientes (Revitaliza��o Limite de Cr�dito)
@since      27/02/2023
/*/
User Function ZF014VTC( _cCodCli, _cLoja, _cXtpCred)
Local _lRet 		:= .T. 
Local _cAliasQry 	:= GetNextAlias()  
Local _nRegTab  	:= 0
Local _nReg			:= SA1->(Recno()) 
Local _lJob			:= IsBlind()


Default _cCodCli	:= If(Type("M->A1_COD") 	== "C",M->A1_COD	,"")
Default _cLoja		:= If(Type("M->A1_LOJA") 	== "C",M->A1_LOJA	,"")
Default _cXtpCred	:= If(Type("M->A1_XTPCRED")	== "C",M->A1_XTPCRED,"")

Begin Sequence
	//somente inclus�o e atera��o
	If !INCLUI .And. !ALTERA
		Break
	EndIf
	If Empty(_cCodCli) .Or. Empty(_cLoja) .Or. Empty(_cXtpCred)
		Break
	Endif
	//Caso n�o tenha limite zerar
	If _cXtpCred == "0"
		M->A1_XLC	:= 0
		M->A1_XDTLC	:= CtoD(Space(08))
		Break
	Endif

	If !ZF014VDUPL(_cCodCli, _cXtpCred, _cLoja)
		_cMsg := "Cliente ja possui registro com tipo de de cr�dito em outra loja, n�o podendo existir mais de um tipo de Cr�dito por Cliente ! "
		Conout("[ZFAT014 - ZF014VTC]  Usu�rio "+RetCodUsr()+ CRLF + _cMsg + CRLF)
		If !_lJob
			MSGINFO( _cMsg, "[ZF014VTC] - Aten��o" )
		Endif
		M->A1_XTPCRED	:= "0"
		M->A1_XLC		:= 0
		M->A1_XDTLC		:= CtoD(Space(08))
		_lRet := .F.
		Break
	Endif	
	//Verificar se existe outro registro com tipo de cr�dito
	BeginSql Alias _cAliasQry //Define o nome do alias tempor�rio 
		SELECT 	ISNULL(SA1.R_E_C_N_O_,0) NREGSA1
		FROM  %Table:SA1% SA1 
		WHERE 	SA1.A1_FILIAL 	= %xFilial:SA1% 
			AND SA1.A1_COD 		= %Exp:_cCodCli%
			AND SA1.A1_LOJA	   <> %Exp:_cLoja%	
			AND SA1.A1_XTPCRED	= %Exp:_cXtpCred%	
			AND SA1.%notDel%
	EndSql
	If (_cAliasQry)->(!Eof()) .And. (_cAliasQry)->NREGSA1 > 0
		_nRegTab := (_cAliasQry)->NREGSA1
	Endif
	//Caso n�o exista nenhum outro registro com esta op��o de cr�dito posso sair
	If _nRegTab == 0
		Break
	Endif
	//caso exista outro registro com este tipo de cr�dito pego os valores do mesmo paa o atual e informo em mensagem
	//somente mostro msg para o Usu�rio para saber sobre mais de um registro com defini��o de cr�dito
	SA1->(DbGoto( _nRegTab ))
	_cMsg := "Cliente ja possui registro com este tipo de de cr�dito na loja "+SA1->A1_LOJA+ " em rela��o a loja Atual "+M->A1_LOJA+" ! "
	Conout("[ZFAT014 - ZF014VTC]  Usu�rio "+RetCodUsr()+ CRLF + _cMsg + CRLF)
	If !_lJob
		_lRet 	:= MsgYesNo(_cMsg + CRLF + "DESEJA TROCAR A LOJA DENTENTORA DO CR�DITO ? ")
	Else
		_lRet	:= .T.
	Endif
	//Verificar se existe rotina rodando em JOB caso exista ser� necess�rio ajustar as variaveis de mem�ria para tabela
	//Caso aceitou a troca da loja
	If _lRet
		M->A1_XTPCRED	:= _cXtpCred
		M->A1_XLC		:= SA1->A1_XLC
		M->A1_XDTLC		:= SA1->A1_XDTLC
		M->A1_XFPSAL 	:= SA1->A1_XFPSAL
		M->A1_XFPATR 	:= SA1->A1_XFPATR 
		M->A1_XLMUSA 	:= SA1->A1_XLMUSA  
		M->A1_XSTAFP 	:= SA1->A1_XSTAFP 
		M->A1_XPEDFP 	:= SA1->A1_XPEDFP 
		M->A1_XVALBO 	:= SA1->A1_XVALBO 
		M->A1_XBLQLC 	:= SA1->A1_XBLQLC 
		//M->A1_XMOTBLO	:= SA1->A1_XMOTBLO   //n�o alterar o motivo pois existe hist�rico para cada cliente conforme Aline
		M->A1_XFPSAL 	:= SA1->A1_XFPSAL 
		M->A1_XBLQVEN	:= SA1->A1_XBLQVEN
	//Caso n�o aceitou volto o tipo de cr�dito
	Else
		M->A1_XTPCRED	:= "0"
		M->A1_XLC		:= 0
		M->A1_XDTLC		:= CtoD(Space(08))
	Endif	
	SA1->(DbGoto( _nReg ))
	//caso seja JOB gravar diretamente na tabela
	If _lJob
		SA1->A1_XTPCRED :=	M->A1_XTPCRED 
		SA1->A1_XLC		:=	M->A1_XLC		 
		SA1->A1_XDTLC	:=	M->A1_XDTLC		 
		If _lRet
			SA1->A1_XFPSAL	:=	M->A1_XFPSAL 	 
			SA1->A1_XFPATR 	:=	M->A1_XFPATR 	 
			SA1->A1_XLMUSA 	:=	M->A1_XLMUSA 	  
			SA1->A1_XSTAFP 	:=	M->A1_XSTAFP 	 
			SA1->A1_XPEDFP 	:=	M->A1_XPEDFP 	 
			SA1->A1_XVALBO 	:=	M->A1_XVALBO 	 
			SA1->A1_XBLQLC 	:=	M->A1_XBLQLC 	 
			//SA1->A1_XMOTBLO	:=	M->A1_XMOTBLO	 
			SA1->A1_XFPSAL 	:=	M->A1_XFPSAL 	 
			SA1->A1_XBLQVEN	:=	M->A1_XBLQVEN	 
		EndIf
	Endif
End Sequence
If Select(_cAliasQry) <> 0
	(_cAliasQry)->(DbCloseArea())
	Ferase(_cAliasQry+GetDBExtension())
Endif  
GetDRefresh() 
Return _lRet

/*/{Protheus.doc} ZF014VDUPL
Fun��o respons�vel por verificar se existe outro tipo de credito cadastrado
caso exista retornar� .F. Falso
@param      _cCliFat 	- Codigo do cliente  
			_cTpCred	- Tipo de Cr�dito do Cliente
			_cLoja 		- Loja do Cliente 
@return     Logico
@author     DAC Denilso
@version    12.1.17 / Superior
@project	GRUPO CAOA - GAP FIN100 - Campo Matriz Clientes (Revitaliza��o Limite de Cr�dito)
@since      02/03/2023
/*/
Static Function ZF014VDUPL(_cCodCli, _cTpCred, _cLoja)
Local _lRet		:= .T.
Local _cAliasPesq 	:= GetNextAlias()

Begin Sequence
	BeginSql Alias _cAliasPesq //Define o nome do alias tempor�rio 
		SELECT COUNT(SA1.R_E_C_N_O_) AS SA1TOTREG
		FROM  %Table:SA1% SA1
		WHERE SA1.A1_FILIAL 	= %XFilial:SA1%
			AND SA1.A1_COD  	= %Exp:_cCodCli%
			AND SA1.A1_LOJA	   <> %Exp:_cLoja%	
			AND SA1.A1_XTPCRED NOT IN ( '0',' ', %Exp:_cTpCred%) 
			AND SA1.%notDel%
	EndSQL	
	//		AND SA1.A1_XTPCRED NOT IN ( '0 ',' ') 
	//			AND SA1.A1_XTPCRED  = %Exp:_cTpCred%
	If (_cAliasPesq)->(!Eof()) .And. (_cAliasPesq)->SA1TOTREG > 0
		_lRet	:= .F.
		Break
	EndIf
End Sequence
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _lRet



/*/{Protheus.doc} ZFAT014GER
Fun��o respons�vel por verificar se existe outro tipo de credito cadastrado
caso exista retornar� .F. Falso
@param      _cCliFat 	- Codigo do cliente  
			_cLoja 		- Loja do Cliente 
@return     Logico
@author     DAC Denilso
@version    12.1.17 / Superior
@project	GRUPO CAOA - GAP FIN100 - Campo Matriz Clientes (Revitaliza��o Limite de Cr�dito)
@since      02/03/2023
/*/
Static Function ZFAT014GER(_cCliFat, _cLoja)
Local _lRet			:= .T.
Local _cAliasPesq 	:= GetNextAlias()
Local _cWhere 		:= ""

Default _cCodCli	:= ""
Default _cLoja		:= ""

Begin Sequence
	If !Empty(_cCliFat)
		_cWhere += " AND  SA1.A1_COD = '"+_cCliFat +"' "
	Endif
	_cWhere := "%"+_cWhere+"%"

	BeginSql Alias _cAliasPesq //Define o nome do alias tempor�rio 
		SELECT ISNULL(SA1.R_E_C_N_O_,0) NREGSA1
		FROM  %Table:SA1% SA1
		WHERE SA1.A1_FILIAL 	= %XFilial:SA1%
			AND SA1.A1_XTPCRED NOT IN ( '0',' ') 
			AND SA1.%notDel%
			%Exp:_cWhere%
			ORDER BY A1_COD
	EndSQL	
	If (_cAliasPesq)->(Eof()) .Or. (_cAliasPesq)->NREGSA1 == 0
		_lRet	:= .F.
		Break
	EndIf
	While (_cAliasPesq)->(!Eof()) 
		SA1->(DbGoto((_cAliasPesq)->NREGSA1))
		U_ZFATF014(SA1->A1_COD, SA1->A1_XTPCRED, SA1->A1_LOJA, .T. )
		(_cAliasPesq)->(DbSkip())	
	EndDo
End Sequence
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _lRet


/*/{Protheus.doc} ZF014ZERLC
Fun��o para atualiar os valiores de limite de cr�dito dos clientes que n�o utilizam limite
pesquisando pelo codigo e avaliando as lojas zerara os valores e dadas do limite de cr�dito
@author DAC
@since 03/04/2023
@version 2.0
@Obs   
/*/
Static Function ZF014ZERLC( _cCliFat, _cLoja, _cTpCred)
Local _lRet         := .T.
Local _lJob			:= IsBlind()
Local _cQuery       := ""
Local _nStatus

Default _cCliFat    := ""
Default _cLoja      := ""
Default	_cTpCred	:= ""

Begin Sequence
	If Empty(_cCliFat)
    	Break
	Endif
	//Limpa registro que era Matriz anteriormente diferentes dos registros que  � matriz DAC 24/02/2023
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
	//_cQuery += " 	,	SA1.A1_XBLQLC 	= '0'" 	                	        + CRLF
	_cQuery += " 	,	SA1.A1_XBLQVEN 	= '" + Space(01) + "'" 		        + CRLF
	_cQuery += "WHERE SA1.D_E_L_E_T_    = ' '" 								+ CRLF
	_cQuery += " 	AND SA1.A1_FILIAL   = '"	+ XFilial("SA1") +"'"  		+ CRLF	
	_cQuery += " 	AND SA1.A1_COD      = '"	+ _cCliFat +"'"  			+ CRLF	
	If !Empty(_cLoja) .And. !Empty(_cTpCred) .And. 	_cTpCred <> "0"
		_cQuery += " 	AND SA1.A1_LOJA <> '"	+ _cLoja +"'"  				+ CRLF	
	Else
	    _cQuery += " 	AND SA1.A1_XTPCRED  IN ( '0',' ')  "  		            + CRLF
	Endif
 	Begin Transaction	
		_nStatus := TcSqlExec(_cQuery)
		if (_nStatus < 0)
			If !_lJob 
				MSGINFO("Erro ao gravar dados do limite de cr�dito tabela SA1 "+ TCSQLError() , "[CRMA980] - Aten��o" )
			Endif
			Conout("[CRMA980] PROBLEMAS NO SELECT "+ CRLF + TCSQLError())
			_lRet := .F.
        EndIf
	End Transaction
End Sequence
Return _lRet
