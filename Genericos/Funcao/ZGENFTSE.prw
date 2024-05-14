#Include "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "TOTVS.ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWBROWSE.CH"
#Include "FWMVCDEF.CH"

#define CRLF chr(13) + chr(10)  

Static _aNotas 
/*/{Protheus.doc} ZGENFTSE
Transfer�ncia de Produto armaz�m FDR para Empresa Hyunday, esta transfer�ncia esta preparada para realizar para qualquer cliente e armazem 
@author     DAC - Denilso 
@since      17/03/2024
@project    GAP151  OneGate  Hyundai  FaturamentoEntrada
@version    1.0
/*/

User Function ZGENFTSE()
Local _aSays	    := {}
Local _aButtons	    := {}
Local _cCadastro    := OemToAnsi("Transfer�ncia de Produto para empresa (Cliente)")   
Local _cTitle  	    := OemToAnsi("Transfer�ncia de Produto para empresa (Cliente)")   
Local _aPar    	    := {}
Local _aRet    	    := {}
Local _nRet			:= 0

Local _cCodCli		:= Space(TamSx3("A1_COD")[1])
Local _cLoja		:= Space(TamSx3("A1_LOJA")[1])
Local _cMarcaDe 	:= Space(TamSx3("VE1_CODMAR")[1])
Local _cMarcaAte	:= Space(TamSx3("VE1_CODMAR")[1])
Local _cCodProdDe	:= Space(TamSx3("B1_COD")[1])
Local _cCodProdAte 	:= Space(TamSx3("B1_COD")[1])
//Local _cGrupoDe		:= Space(TamSx3("BM_GRUPO")[1])
//Local _cGupoAte		:= Space(TamSx3("BM_GRUPO")[1])
Local _cGrupo		:= Space(TamSx3("BM_GRUPO")[1])
Local _cArmOrigem	:= Space(TamSx3("B1_LOCPAD")[1])
Local _cTipoOper	:= Space(TamSx3("C6_OPER")[1])
Local _cCondPag		:= Space(TamSx3("E4_CODIGO")[1])
Local _cNatureza	:= Space(TamSx3("ED_CODIGO")[1])
Local _cSerie		:= Space(TamSx3("C5_SERIE")[1])
Local _cCodTab		:= Space(TamSx3("DA0_CODTAB")[1])

Local _cChave		:= AllTrim(FWCodEmp())+"ZGENFTSE"
Local _lRet			:= .T.
Local _lSerieObr	:= If(FWCodEmp() == '2020', .F., .T.)  //indicar para obrigat�rio quando embpresa for diferente de 020 na serie  

Local _oSay
Local _nPos

Begin Sequence
	//_lRet := U_ZGENUSER( RetCodUsr() ,"ZGENFTSE" ,.T.)	
	If !_lRet
		Break
	EndIf
	/*
	IF FWCodEmp() <> '2020' //Verificar Empresa Pe�as, somente rodar em Pe�as
		Help( , ,OemToAnsi("Aten��o"),,OemToAnsi("Esta rotina n�o � valida para esta empresa"),4,1)   
	    Break
	ENDIF
	*/

	aAdd(_aPar,{1,OemToAnsi("Cliente Faturamento  : ") 	,_cCodCli		,"@!"		,".T."	,"SA1" 	,".T."	,100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Loja Faturamento 	  : ")	,_cLoja 		,"@!"		,".T."	,""		,".T."	,100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Marca de   		  : ") 	,_cMarcaDe		,"@!"		,".T."	,"VE1" 	,".T."	,100,.F.}) 
	aAdd(_aPar,{1,OemToAnsi("Marca ate  		  : ") 	,_cMarcaAte		,"@!"		,".T."	,"VE1"	,".T."	,100,.T.}) 

	aAdd(_aPar,{1,OemToAnsi("Produto de   		  : ") 	,_cCodProdDe	,"@!"		,".T."	,"SB1" 	,".T."	,100,.F.}) 
	aAdd(_aPar,{1,OemToAnsi("Produto ate  		  : ") 	,_cCodProdAte	,"@!"		,".T."	,"SB1"	,".T."	,100,.F.}) 

	//aAdd(_aPar,{1,OemToAnsi("Grupo de   		  : ") 	,_cGrupoDe		,"@!"		,".T."	,"SBM" 	,".T."	,100,.F.}) 
	//aAdd(_aPar,{1,OemToAnsi("Grupo ate  		  : ") 	,_cGupoAte		,"@!"		,".T."	,"SBM"	,".T."	,100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Grupo    		  	: ") 	,_cGrupo		,"@!"		,".T."	,"SBM" 	,".T."	,100,.T.}) 

	aAdd(_aPar,{1,OemToAnsi("Armazem de Origem 	  : ") 	,_cArmOrigem	,"@!"		,".T."	,"NNR"	,".T."	,100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Tipo de Operera��o	  : ") 	,_cTipoOper		,"@!"		,".T."	,"DJ"	,".T."	,100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Forma de Pagto 	  : ") 	,_cCondPag		,"@!"		,".T."	,"SE4"	,".T."	,100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Natureza de Opera��o : ") 	,_cNatureza		,"@!"		,".T."	,"SED"	,".T."	,100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Serie Nota Fiscal 	  : ") 	,_cSerie		,"@!"		,".T."	,		,".T."	,100,_lSerieObr}) 
	aAdd(_aPar,{1,OemToAnsi("Cod Tabela Pre�o 	  : ") 	,_cCodTab		,"@!"		,".T."	,"DA0"	,".T."	,100,.T.}) 


	//aAdd(_aPar,{3,OemToAnsi("Atualiza Base: ") ,2 ,{"SIM","NAO"}	,80,"",.F.})  

	// Monta Tela principal
	aAdd(_aSays,OemToAnsi("Este Programa tem  como  Objetivo realizar transfer�ncia de Produto")) 
	aAdd(_aSays,OemToAnsi("da empresa CAOA PE�AS para um determinado Cliente (empresa).")) 
	aAdd(_aSays,OemToAnsi("Ser� gerado Pedido de Venda e nota fiscal de Sa�da com os Produtos")) 
	aAdd(_aSays,OemToAnsi("que possuem saldos no armaz�m para empresa destino (Cliente) indicados")) 
	aAdd(_aSays,OemToAnsi("por par�metro, e liberada ! ")) 

	aAdd(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
	aAdd(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
	aAdd(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,"ZGENFTSE",.T.,.T.) 			}})

	FormBatch( _cCadastro, _aSays, _aButtons )
	If _nRet <> 1
		Break
	Endif
	If Len(_aRet) == 0
		Help( , ,OemToAnsi("Aten��o"),,OemToAnsi("Necess�rio informar os par�metros"),4,1)   
		Break 
	Endif

	//Garantir que o processamento seja unico
	_cChave		:= AllTrim(FWCodEmp())+"ZGENFTSE"+_aRet[07]
	If !LockByName(_cChave,.T.,.T.)  
		//tentar locar por 10 segundos caso n�o consiga n�o prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 3000 ) // Para o processamento por 3 segundos
			If LockByName(_cChave,.T.,.T.)
				_lRet := .T.
			EndIf
		Next		
		If !_lRet
			MSGINFO("J� existe um processamento em execu��o rotina ZGENFTSE com grupo "+_aRet[07]+", aguarde o t�rmino!", "[ZGENFTSE] - Aten��o" )
			Break
		EndIf
	EndIf

	FwMsgRun(,{ |_oSay| ZGENFTSEPR(_aRet, @_oSay ) }, "Transfer�ncia de Produtos para Cliente", "Aguarde...")  //Separa��o Or�amentos / Aguarde
	//Libera para utiliza��o de outros usuarios
	UnLockByName(_cChave,.T.,.T.)
End Sequence
Return Nil


Static Function ZGENFTSEPR(_aRet, _oSay)
Local _cAliasPesq   := GetNextAlias()      
Local _lRet			:= .T.
Local _cCodCli		:= _aRet[01]
Local _cLoja		:= _aRet[02]
Local _cMarcaDe 	:= _aRet[03]
Local _cMarcaAte	:= _aRet[04]
Local _cCodProdDe	:= _aRet[05]
Local _cCodProdAte 	:= _aRet[06]
//Local _cGrupoDe		:= _aRet[07]
//Local _cGupoAte		:= _aRet[08]
Local _cGrupo		:= _aRet[07]

Local _cArmOrigem	:= _aRet[08]
Local _cTipoOper	:= _aRet[09]
Local _cCondPag		:= _aRet[10]
Local _cNatureza	:= _aRet[11]
Local _cSerie 		:= _aRet[12]
Local _cCodTab		:= _aRet[13]

Local _nLimites 	:= SuperGetMV("CMV_ZGNF01",,100)   //Limite de itens a serem gerados
Local _nRegistros	:= 0
Local _nLidos		:= 0
Local _nOpc			:= 3
Local _aItemAux   	:= {}
Local _aItemPV 		:= {}
Local _aCabPV 		:= ()
Local _cTipoFre  	:= 'S'
Local _cTipoPed 	:= "N"

Local _cNumPV   	
Local _cItem		
Local _nRegMax
Local _nValUnit 
Local _nValTot  

Local _cCodTes			
Local _cTipoCli
Local _cNotas
Local _nPos

Begin Sequence
	_aNotas		:= {} 
	SA1->( DBSetOrder(01) )
	if !SA1->( MsSeek(FwXFilial("SA1") + _cCodCli+_cLoja ))
		Help( " ", 1, "ZGENFTSEPR", , 'Cliente '+_cCodCli+'-'+_cLoja+' n�o cadastrado n�o ser�o gerados o Pedido/NFS ', 1 )  
		_lRet := .F.
		Break
	Endif
	_cTipoCli 	:= SA1->A1_TIPO

	_oSay:SetText("Selecionando dados")
	ProcessMessage() 

	BeginSql Alias _cAliasPesq 
		SELECT 	SB1.R_E_C_N_O_ NREGSB1,
				SB2.R_E_C_N_O_ NREGSB2,
				SBM.R_E_C_N_O_ NREGSBM,
				SBM.BM_CODMAR ,
				SB1.B1_COD
		FROM %table:SB1% SB1
		JOIN %table:SB2% SB2
			ON  SB2.%notDel%	
			AND SB2.B2_FILIAL 	= %XFilial:SB2%
			AND SB2.B2_COD 		= SB1.B1_COD
			AND SB2.B2_LOCAL 	= %Exp:_cArmOrigem% 
			AND SB2.B2_QATU 	> 0
		JOIN %table:SBM% SBM
			ON 	SBM.%notDel%
			AND SBM.BM_FILIAL	= %XFilial:SBM%
			AND SBM.BM_GRUPO 	= SB1.B1_GRUPO
			AND SBM.BM_CODMAR 	BETWEEN %Exp:_cMarcaDe% AND %Exp:_cMarcaAte%
		WHERE SB1.%notDel%	
			AND	SB1.B1_FILIAL 	= %XFilial:SB1%
			AND SB1.B1_COD  	BETWEEN  %Exp:_cCodProdDe% AND %Exp:_cCodProdAte%
			AND SB1.B1_GRUPO	=  %Exp:_cGrupo% 
		ORDER BY SBM.BM_CODMAR, SB1.B1_COD	
	EndSql
	//			AND SB1.B1_GRUPO	BETWEEN  %Exp:_cGrupoDe% AND %Exp:_cGupoAte%

	If (_cAliasPesq)->(Eof())
		Help( , ,OemToAnsi("Aten��o"),,OemToAnsi("N�o existem produtos com saldo para envio Cliente"),4,1)   
		Break 
	EndIf	

	If !MsgYesNo( "Confirma gerar nota de Sa�da para Cliente "+AllTrim(SA1->A1_NREDUZ)+" ? " )
		_lRet := .F.
		Break 
	Endif	
	
	(_cAliasPesq)->( DbGotop()) 
	 Count To _nRegistros 	
	(_cAliasPesq)->(DbGotop()) 
	_aCabPV		:= {}	
	_aItemPV	:= {}
	While (_cAliasPesq)->(!Eof()) 
		_cCodMarca := (_cAliasPesq)->BM_CODMAR
		//organizar pelo codigo da marca
		While (_cAliasPesq)->(!Eof()) .And. _cCodMarca == (_cAliasPesq)->BM_CODMAR
			_nLidos ++
			_oSay:SetText("Lendo Registro "+StrZero(_nLidos,7)+" de "+StrZero(_nRegistros,7))
			ProcessMessage() 

			SB2->(DbGoto((_cAliasPesq)->NREGSB2))
			//Pega o valor de custom�dio
			//_nValUnit := NoRound(U_ZGENCST(SB2->B2_COD))
			_nValUnit := NoRound(ZGENFTSEValorInutario(_cCodTab, SB2->B2_COD))
			If _nValUnit == 0
				Help( " ", 1, "ZGENFTSEPR", , "N�o localizado valor Unitario para o Produto "+AllTrim(SB2->B2_COD)+", n�o ser� faturado este produto Verificar", 1 )  
				(_cAliasPesq)->(DbSkip())
				Loop
			Endif

			If Len(_aCabPV) == 0
 				_cNumPV   	:= CriaVar("C5_NUM")
 				_cItem		:= CriaVar("C6_ITEM")
				_nRegMax    := 0
				_aItemAux   := {}
				_aItemPV 	:= {}
				_aCabPV := 	{{"C5_FILIAL" , XFilial("SC5")			,Nil},;
						 	{"C5_NUM"    , _cNumPV					,Nil},;
							{"C5_TIPO"   , _cTipoPed				,Nil},;
							{"C5_CLIENTE", _cCodCli					,Nil},;
							{"C5_CLIENT" , _cCodCli					,Nil},;
							{"C5_LOJAENT", _cLoja					,Nil},;
							{"C5_LOJACLI", _cLoja					,Nil},;
				        	{"C5_EMISSAO", dDatabase				,Nil},;
							{"C5_CONDPAG", _cCondPag				,Nil},;
							{"C5_NATUREZ", _cNatureza				,Nil},;
							{"C5_TIPLIB" , "1"						,Nil},;
							{"C5_MOEDA"  , 1						,Nil},;
							{"C5_TIPOCLI", _cTipoCli				,Nil},;
							{"C5_TPFRETE", _cTipoFre                ,Nil};
							 }
							//{"C5_DESC1"  , 0						,Nil},;
				_cItem := Soma1(_cItem)
			Endif				 
			_nValTot  := SB2->B2_QATU * _nValUnit
			SB1->(DbGoto((_cAliasPesq)->NREGSB1))
			SB2->(DbGoto((_cAliasPesq)->NREGSB2))
			SBM->(DbGoto((_cAliasPesq)->NREGSBM))

			//_cTipoOper := U_zTpOper( SA1->A1_COD, SA1->A1_LOJA, _cTipoPed)
			_cCodTes := MaTesInt(2,_cTipoOper,_cCodCli,_cLoja,"C",SB1->B1_COD,/*"_CODTES"*/)
			//para n�o gerar erro na integra��o DAC 15/02/2022
			//mesmo com a valida��o o precesso aborta  DAC 23/02/2022
			If Valtype(_cCodTes) <> "C"
				_cCodTes := ""
			EndIf

			AAdd( _aItemAux,{{"C6_FILIAL" , FwXFilial("SC6")	,Nil},;
							{"C6_NUM"    , _cNumPV				,Nil},;
							{"C6_ITEM"   , _cItem				,Nil},;
							{"C6_PRODUTO", SB1->B1_COD			,Nil},;
							{"C6_QTDVEN" , SB2->B2_QATU			,Nil},;  
							{"C6_QTDLIB" , SB2->B2_QATU			,Nil},;
							{"C6_PRUNIT" , _nValUnit			,Nil},;
							{"C6_PRCVEN" , _nValUnit			,Nil},;
							{"C6_VALOR"  , _nValTot				,Nil},;
							{"C6_ENTREG" , dDatabase			,Nil},;
							{"C6_UM"     , SB1->B1_UM			,Nil},;
							{"C6_TES"    , _cCodTes				,Nil},; 
							{"C6_LOCAL"  , _cArmOrigem			,Nil},;
							{"C6_CLI"    , _cCodCli				,Nil},;
							{"C6_LOJA"   , _cLoja				,Nil};
							})
			_cItem 		:= Soma1(_cItem)
			_nRegMax 	++

			(_cAliasPesq)->(DbSkip())

			If (_nRegMax >= _nLimites .Or. (_cAliasPesq)->(Eof())) .And. Len(_aItemAux) > 0 //Caso atija fim do select
				_lRet := ZGENFTSEFatura(_aCabPV, _aItemAux, _cSerie, _nOpc, _cCodCli, _cLoja,  _cNumPV, _cCodMarca, @_oSay)
				If !_lRet
					Break
				Endif 
				_aCabPV	:= {}
			Endif
		EndDo 
		//Caso n�o valide o final
		If Len(_aCabPV) > 0
			_lRet 	:= ZGENFTSEFatura(_aCabPV, _aItemAux, _cSerie, _nOpc, _cCodCli, _cLoja,  _cNumPV, _cCodMarca, @_oSay)
			_aCabPV	:= {}
		Endif		
	EndDo	
End Sequence

If Len(_aNotas) > 0
	//Help( " ", 1, "ZGENFTSEPR", , "Termino do Processamento !", 1 )  
	_cNotas := ""
	For _nPos := 1 To Len(_aNotas)
		_cNotas += "Nota : "+_aNotas[_nPos,1]+ " serie: "+_aNotas[_nPos,2]+ " Pedido: "+_aNotas[_nPos,3]+ CRLF 
	Next 
	EecView("CAOA | Gera��o de Notas" + CRLF + _cNotas, "ZGENFTSE")
	
/*	
	EecView(cAviso, "Problemas encontrados na rotina:")
	EecView(cMsg, "Observa��es do PC" + SC7->C7_NUM)
	cMsg += "Observa��o compras:"
            cMsg += CRLF + PadR("", 65, "-")
            cMsg += CRLF + SC7->C7_XOBSCOM

*/
Endif

If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  

Return Nil

//Executa o Faturamento
Static Function ZGENFTSEFatura(_aCabPV, _aItemPV, _cSerie, _nOpc, _cCliente, _cLoja,  _cNumPV, _cCodMarca, _oSay)
Local _lRet := .T.

Default _aCabPV		:= {} 
Default _aItemPV 	:= {}
Default _cSerie		:= ""
Default _nOpc 		:= 0
Default _cCliente 	:= ""
Default _cLoja		:= ""
Default _cNumPV 	:= ""
Default _cCodMarca	:= ""

Private lMsErroAuto := .F.

Begin Sequence
	If Len(_aCabPV) == 0 .Or. Len(_aItemPV) == 0 .Or. _nOpc == 0 .Or. Empty(_cCliente) .Or. Empty(_cLoja) .Or. Empty(_cCodMarca)
		Help( " ", 1, "ZGENFTSEFatura", , "Existe Problemas nos parametros para gera��o de nota do numero de pedido "+_cNumPV+", n�o ser� faturado produto Verificar", 1 )  
		_lRet 	:= .F. 
		Break
	Endif
	_oSay:SetText("Gerando Pedido "+AllTrim(_cNumPV)+" de Vendas")
	ProcessMessage() 
	MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, _aCabPV, _aItemPV, _nOpc, .F.)//Estorno
	If lMsErroAuto
		Mostraerro()
		_lRet := .F.
		Break	
	Else
		ConfirmSX8()
		//MsgInfo("Pedido de Vendas N� "+_cNumPV+" criado com sucesso!","Pedido para remessa CD")
		//Gravar informa��o no SB1
		/*
		For _nPos := 1 To Len(_aRegSB1)
			SB1->(DbGoto(_aRegSB1[_nPos]))
			SB1->(Reclock("SB1",.F.))
			SB1->B1_ 	:= _cNumPV
			SB1->(MsUnlock())
		Next
		*/	
	EndIf
	//Gera a Nota funcionalidade apresenta informa��es e exige intera��o do usu�rio
	//SC5->( Ma410PvNfs(Alias(), Recno()) )
	//Libera Pedido                  
	_oSay:SetText("Liberando Pedido "+AllTrim(_cNumPV))
	ProcessMessage() 
	_lRet := ZGENFTSELPedido(_cNumPV)  //Avaliar se a Libera��o vai ser total ou passara pelos crit�rios DAC 06/08/2018
	If ! _lRet 
		Break
	Endif
	_oSay:SetText("Gerando Nota Fiscal de Saida para o Pedido de Vendas "+AllTrim(_cNumPV))
	ProcessMessage() 
	If Empty(_cSerie)
		_cSerie := XVerSerieNF(_cCodMarca)
		If Empty(_cSerie)
			_lRet := .F.
			Help( " ", 1, "ZGENFTSEPR", , 'N�o localizado Serie, informar a serie no par�metro inicial', 1 )  
			Break
		Endif 
	Endif	
	//Gerar a Nota Fiscal de Saida

	_lRet := ZGENFTSENSaida(_cCliente, _cLoja, _cNumPV, _cSerie,.F.)				

	If !_lRet
		Break
	Endif
End Sequence
Return _lRet



/*---------------------------------------------------------------------------------------
{Protheus.doc} ZGENFTSELPedido
Responsavel Fazer a Libera��o de Pedidos
@author     DAC - Denilso Almeida Carvalho
@single		27/03/2024
@version    P.12
@obs        
@project    GAP151  OneGate  Hyundai  FaturamentoEntrada
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/
Static Function ZGENFTSELPedido(_cPedido, _cFilial)  
Local _aArea		:= GetArea()
Local _lRetorno		:= .T.
Local _cAliasPESQ 	:= GetNextAlias()
Local _cStLibCre    := "'10'"+","+"'09'"     
Local _cStLibEst    := "'10'"     

Default _cPedido := ""                    
Default _cFilial := FwXFilial("SC9") 

Begin Sequence                    
	_cStLibCre  := "%"+_cStLibCre+"%" 
	_cStLibEst  := "%"+_cStLibEst+"%" 
	//Se n�o tiver pedido n�o verifica
	If Empty(_cPedido)
		Break	
	Endif
	BeginSql Alias _cAliasPESQ //Define o nom GU3e do alias tempor�rio 
		SELECT SC9.R_E_C_N_O_ NREGSC9
		FROM %Table:SC9% SC9                   
		WHERE 	SC9.C9_FILIAL 	=  %Exp:_cFilial% 				AND   
				SC9.C9_PEDIDO	=  %Exp:_cPedido%				AND
				(SC9.C9_BLEST <> ' ' OR SC9.C9_BLCRED <> ' ' ) 	AND
				SC9.C9_BLCRED NOT IN(%Exp:_cStLibCre%) 			AND
				SC9.C9_BLEST <> %Exp:_cStLibEst%				AND
				SC9.%notDel%                       
	EndSql 
	If (_cAliasPESQ)->(Eof()) 
		Break
	Endif
	SC6->(DbSetOrder(1))
	(_cAliasPESQ)->(DbGotop())	 
	While (_cAliasPESQ)->(!Eof())
		SC9->(DbGoto((_cAliasPESQ)->NREGSC9))                                              
		If !(	(Empty(SC9->C9_BLCRED) .AND. Empty(SC9->C9_BLEST )) .OR. ;
				(SC9->C9_BLCRED == "10"	.AND. SC9->C9_BLEST == "10") .OR. ;
			 	SC9->C9_BLCRED == "09" 	)                 
			A450Grava( 1, .T., .T., .F. )                
        Endif
		//Reposiciono SC9 devido a funcionalidade que gera o titulo retirar o valor calculando quantidade X valor unitario do SC9 O MESMO NECESSITA FICAR IGUAL A SC6 esta gravando somente com 4 casas decimais e n�o com as nove que � a necessidade da Cisco DAC 25/05/2017
		//necessario verificar onde � realizado o arredondamento pois n�o esta de acordo com a da SC6
		If SC6->(MsSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)) .and. SC6->C6_PRCVEN <> SC9->C9_PRCVEN
			RecLock("SC9", .F.)		
			SC9->C9_PRCVEN := SC6->C6_PRCVEN			
			SC9->(MsUnlock())	
		Endif
		(_cAliasPESQ)->(DbSkip())
	EndDo		
End Begin   
//Apagar arquivo twmporario criado
If Select(_cAliasPESQ) <> 0
   (_cAliasPESQ)->(DbCloseArea())
   Ferase(_cAliasPESQ+GetDBExtension())
Endif  
RestArea( _aArea )
Return(_lRetorno)



/*---------------------------------------------------------------------------------------
{Protheus.doc} ZGENFTSENSaida
Responsavel emissao da NF pelo Pedido gerado
@author     DAC - Denilso Almeida Carvalho
@single		27/03/2024
@version    P.12
@obs        
@project    GAP151  OneGate  Hyundai  FaturamentoEntrada
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/
Static Function ZGENFTSENSaida(_cCodCli, _cLoja, _cPedido, _cSerie, lAutoGravErro)
Local _aArea	 	:= GetArea()
Local _aPvlNfs		:= {}
Local _nPrcVen    	:= 0
Local _nRegDAK   	:= 0
Local _lMostraCtb 	:= .F.
Local _lAglutCtb  	:= .F.
Local _lCtbOnLine 	:= .F.
Local _lCtbCusto  	:= .F.
Local _lReajuste  	:= .F.
Local _cNota		:= ""
Local _lRet	 	    := .T.         
Local _cMens  		:= ""

Default _cSerie	  	:= "9"         
Default _cCodCli 	:= ""	
Default _cLoja 	  	:= ""	 	                            
Default _cPedido  	:= ""	
Default _lAutoGravErro := .T.
  
Private _lRotAut		:= .T.					//Identifica para os pontos de entrada que est� sendo executado uma carga e n�o deve ser chamado os pontos de entrada
Private lMsErroAuto 	:= .F. 					//Informa se houve erro na ExecAuto.
//Private lMsHelpAuto 	:= .T. 					//Se .T. direciona as mensagens de Help para o arquivo de log.
If _lAutoGravErro
	Private lAutoErrNoFile 	:= .T.					//Forca a gravacao das informacoes de erro em array para manipulacao da gravacao ao inves de gravar direto no arquivo temporario 
Endif

Begin Sequence
	If Empty(_cSerie) .or. Empty(_cCodCli) .or. Empty(_cLoja) .or. Empty(_cPedido)
		_lRet := .F.
		Break 
	Endif	
    //Carregar perguntas
	Pergunte("MT460A",.F.) 
	_lMostraCtb  := MV_PAR01 == 1
	_lAglutCtb   := MV_PAR02 == 1
	_lCtbOnLine  := MV_PAR03 == 1
	_lCtbCusto   := MV_PAR04 == 1
	_lReajuste   := MV_PAR05 == 1

	SC5->(DBSetOrder(3))
	SC6->(DBSetOrder(1))
	SC9->(DBSetOrder(2))
	SE4->(DBSetOrder(1))
	SB1->(DBSetOrder(1))
	SB2->(DBSetOrder(1))
	SF4->(DBSetOrder(1))
	SM2->(DbSetOrder(1))
	DAK->(DbSetOrder(1))  ////FILIAL+COD+SEQCAR   DAC 17/12/2014 

	//Posiciona as tabelas necessaria para emissao da NF
	If !SC5->( MsSeek(xFilial('SC5') + _cCodCli + _cLoja + _cPedido) )
      	_cMens  := "Pedido nao localizado"
		_lRet 	:= .F.
      	Break
	Endif
	If !SC6->( DbSeek(xFilial('SC6') + _cPedido) )
      	_cMens  := "Itens do Pedido nao localizado"
		_lRet := .F.
	  	Break
	Endif
    While SC6->( !Eof() ) .AND. SC6->C6_FILIAL + SC6->C6_NUM == xFilial('SC6') + _cPedido
      	If !SC9->( DbSeek( xFilial('SC9') + _cCodCli + _cLoja + SC6->C6_NUM + SC6->C6_ITEM) )
        	_cMens  := "Pedido n�o esta Liberados "
			_lRet := .F.
        	Break
      	Endif
      	// Posiciona na condicao de pagamento
      	SE4->( DbSeek(xFilial('SE4') + SC5->C5_CONDPAG) )
      	// Posiciona no produto
      	SB1->( DbSeek(xFilial('SB1') + SC6->C6_PRODUTO) )
      	// Posiciona no saldo em estoque
      	SB2->( DbSeek(xFilial('SB2') + SC6->C6_PRODUTO + SC6->C6_LOCAL) )
      	// Posiciona no TES
      	SF4->( DbSeek(xFilial('SF4') + SC6->C6_TES) )
      	// Converte o valor unitario em Reais quando pedido em outra moeda
      	_nPrcVen := SC9->C9_PRCVEN
      	If (SC5->C5_MOEDA != 1)
        	If SM2->( MsSeek(DTOS(dDataBase)) )
          		_nPrcVen := SC9->C9_PRCVEN * SM2->M2_MOEDA2
        	Else
          		_nPrcVen := xMoeda(_nPrcVen,SC5->C5_MOEDA,1,dDataBase)
        	EndIf
      	EndIf
	  
	  	//Caso esteja informado a carga verificar se existe	
	  	If !Empty(SC9->C9_CARGA)                           
			If DAK->(DbSeek(XFilial(DAK)+SC9->C9_CARGA))         	  
				_nRegDAK := DAK->(Recno())
			//Caso n�o localize retirar o carregamento da SC9
			Else
		        _cMens  := "Informado carregamento, por�m o mesmo n�o esta cadastrado na tabela DAK"
				_lRet := .F.
        		Break
			Endif
	  	Endif

      	// Monta array para gerar a nota fiscal
      	Aadd(_aPvlNfs,{	SC9->C9_PEDIDO	,;  //01
						SC9->C9_ITEM	,;  //02
						SC9->C9_SEQUEN	,;  //03
						SC9->C9_QTDLIB	,;  //04
						_nPrcVen			,;  //05
						SC9->C9_PRODUTO	,;  //06
						.F.				,;  //07
						SC9->(RecNo())	,;  //08
						SC5->(RecNo())	,;  //09
						SC6->(RecNo())	,;  //10
						SE4->(RecNo())	,;  //11
						SB1->(RecNo())	,;  //12
						SB2->(RecNo())	,;  //13
						SF4->(RecNo())	,;  //14
						SC6->C6_LOCAL	,;  //15
						1				,;  //16
						SC9->C9_QTDLIB2	}	)
			
      	SC6->( DBSkip() )
    EndDo
	
	//������������������������Ŀ
	//�Faz a inclusao da Nota. �
	//��������������������������
	If Empty(_aPvlNfs)
		_lRet := .F.
	  	Break
	Endif  
 
 	//Criar a S�rie da NF caso n�o exista
 	//CriaSerSx5(SC5->C5_SERIE)
	If !Empty(SC5->C5_SERIE)
		_cSerie := SC5->C5_SERIE
	Endif

    _cNota := MaPvlNfs(	_aPvlNfs		,;  //aPvlNfs
               		   	_cSerie       	,;  //cSerie,
                   		.F.    			,;  //lMostraCtb
                   		.F.    			,;  //lAglutCtb
                   		.T.   			,;  //lCtbOnLine
                   		.F.    			,;  //lCtbCusto
                   		.F.    			,; 	//lReajusta
                   		0       		,;	//nCalAcrs
                   		0       		,;	//nArredPrcLis
                   		.F.     		,; 	//lAtuSA7
                   		.F.     		,; 	//lECF
                   		'' )				//cembexp

    //����������������������������������Ŀ
    //�Valida a inclusao da Nota Fiscal. �
    //������������������������������������
	SX6->(MSRUnlock())
    If Empty(_cNota)
     	_cMens := "Problema ocorrido na grava��o da Not Fiscal de Saida verificar tabelas relacionadas com processo "
		_lRet := .F.
      	Break
    ElseiF (FwXFilial("SF2")+ _cNota + _cSerie + _cCodCli + _cLoja) <> (SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA) 
    	SF2->(dbSetOrder(1))	//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
    	If !(SF2->( dbSeek( FwXFilial("SF2") + _cNota + _cSerie + _cCodCli + _cLoja ) ))
   	 		_cMens := "Problema ocorrido na grava��o da Not Fiscal de Saida "+_cNota +" serie "+ _cSerie+". Processo retornado OK, mas nao foi gerada a Nota Fiscal"
			_lRet := .F.
	      	Break
    	EndIf
    Endif
	//Deixar como marcado para integra��o da RG LOG n�o vai sair do armazem
	If SF2->(Reclock("SF2",.F.))
		SF2->F2_XINTEG := "X"
		SF2->(MsUnlock())
	Endif
    _lRet := .T.
	Aadd(_aNotas,{_cNota, _cSerie, _cPedido, _cCodCli, _cLoja })
End Begin
//Retorna as areas originais
SX5->(MsUnlock())        
If !_lRet .and. !Empty(_cMens) 
	Conout(_cMens) //verificar onde gravar
	AutoGrLog(Replicate("-", 80))
	AutoGrLog( "Data.................: " + DtoC(Date()) )
	AutoGrLog( "Hora.................: " + Time() )
	AutoGrLog( "Aonde................: JOB BTCJB001 " )
	AutoGrLog( "Para Depositante Cod.: " + _cCodCli+"-"+_cLoja )
	AutoGrLog( "Pedido...............: " +_cPedido )
	AutoGrLog( "N�o foi possivel gerar nota do Pedido "+_cPedido)
	AutoGrLog( "Acumulado no CD via JOB, necess�rio gerar nota do mesmo")
	AutoGrLog(_cMens)
	If !_lAutoGravErro  
		Mostraerro()	
	Endif
Endif
RestArea(_aArea)
Return _lRet


//Retornar a serie da nota Fiscal conforme a marca do veiculo
Static Function XVerSerieNF(_cMarca)
Local _cSerie01 := Alltrim(SuperGetmv("ZCD_FAT001",.F.,"")) //Serie HYU (Barueri)
Local _cSerie02 := Alltrim(SuperGetmv("ZCD_FAT002",.F.,"")) //Serie Che (Barueri)
Local _cSerie03 := Alltrim(SuperGetmv("ZCD_FAT003",.F.,"")) //Serie SBR (Barueri)
//Local _cSerie04 := Alltrim(SuperGetmv("ZCD_FAT004",.F.,"")) //Serie Nota Normal (Anhanguera)
//Local _cSerie06 := Alltrim(SuperGetmv("ZCD_FAT006",.F.,"")) //Serie Nota Normal (Raposo)
//Local _cSerie08 := Alltrim(SuperGetmv("ZCD_FAT008",.F.,"")) //Serie Nota Normal (SCS)
Local _cEmp     := FWCodEmp()
Local _cSerie 	:= ""

	If _cEmp == "2020" //Executa o p.e. somente para Anapolis.
		If  AllTrim(_cMarca) == "HYU"
    		_cSerie := AllTrim(_cSerie01)
		ElseIf  AllTrim(_cMarca) == "CHE"
    		_cSerie := AllTrim(_cSerie02)
		ElseIf  AllTrim(_cMarca) == "SBR"
    		_cSerie := AllTrim(_cSerie03)
		Endif
	Endif
	//Caso esteja menor no tamanho ajustar pois ser� utilizado na pesquisa
	If Len(SC5->C5_SERIE) > Len(_cSerie)
		_cSerie := _cSerie+Space(Len(SC5->C5_SERIE)- Len(_cSerie)) 
	//N�o deixar passar se estiver maior no tamanho
	ElseIf Len(SC5->C5_SERIE) < Len(_cSerie)
		Help( , ,OemToAnsi("Aten��o"),,OemToAnsi("Verificar parametros da Serie NF "+_cSerie+" o mesmo esta maior [ZGENFTSE]" ),4,1)   
	Endif

Return _cSerie



//Localizar o valor unitario
Static Function ZGENFTSEValorInutario(_cCodTab, _cCodProd)
Local _cAliasPESQ 	:= GetNextAlias()
Local _nValUnit   	:= 0 
Local _cAtivo		:= '1'
//Local _cData		:= DtOS(dDataBase)  //DtOS(Date()) //06/10/2022 conforme Zé utilizar o database
 
    BeginSql Alias _cAliasPesq
        SELECT 	DA1_PRCVEN 
				, DA1_PRCVEN
				, DA1.R_E_C_N_O_ AS NREGDA1
        FROM %Table:DA0% DA0
        INNER JOIN %Table:DA1% DA1
            ON  DA1.DA1_FILIAL = %xFilial:DA1%
            AND DA1.DA1_CODTAB = DA0.DA0_CODTAB
            AND DA1.DA1_CODPRO = %Exp:_cCodProd%
            AND DA1.%NotDel%
        WHERE DA0.DA0_FILIAL 	= %xFilial:DA0%
			AND DA0.DA0_ATIVO	= %Exp:_cAtivo%
			AND DA0.DA0_CODTAB 	= %Exp:_cCodTab%
			AND DA0.%notDel%
    EndSql
	//retirado expressao de data pois estara cadastrado com data de vigencia anterior e ser� definido uma unica tabela conforme Wandre 05/04/2024			
	// AND %Exp:_cData% BETWEEN DA0.DA0_DATDE AND DA0.DA0_DATATE

	If (_cAliasPesq)->(!Eof()) .and. (_cAliasPesq)->NREGDA1 > 0
		_nValUnit 	:= (_cAliasPesq)->DA1_PRCVEN
	EndIf
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return  _nValUnit 



