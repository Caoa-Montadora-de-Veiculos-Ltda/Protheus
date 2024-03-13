#Include "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "TOTVS.ch"
#INCLUDE "MSGRAPHI.CH"

#define CRLF chr(13) + chr(10)

/*/{Protheus.doc} ZPECF035
Geração do Faturamento a partir do recebimento do Picking
@author     DAC - Denilso 
@since      20/08/2023
@version    1.0
@obs        Esta funcionalidade poderá ser utilizada para o faturamento do SIGAPEC
/*/

User Function ZPECF036(_aOrcs, _cPicking, _cEmpresa, _cFilial, _lEnviaEmail, _lTransaction, _lJob)
	Local _lRet 		:= .F.
	Local _aMsg 		:= {}
	Local _aRegVS1		:= {}
	Local _aPicking     := {}
	Local _aVS9			:= {}
	Local _cNota		:= ""
	Local _cSerie		:= ""
	Local _cPedido  	:= ""
	Local _cTitulo		:= ""
	Local _nPos

	Default _aOrcs			:= {}
	Default _cPicking		:= ""
	Default _lEnviaEmail	:= .T.
	Default _lTransaction 	:= .T.  //pode vir de uma operaçao que ja esta em transaction
	Default _lJob			:= IsBlind()
	//Default _cEmpresa       := ""  
	//Default _cFilial		:= ""


	Private aParcBRNF  	:= {}
	//Variáveis utilizadas no fonte padrão TOTVS OX100VS9E1 - Nicolas GAP098
	Private nCntSE1     := 0 
	Private cE1TIPOorig := "" 
	Private aVS9SE1     := {}   // Contem os registros da VS9 quando for condicao negociada
	Private aTitSE1 	:= {}
 
	Begin Sequence
		//Tratar abertura da empresa conforme enviado no parametro
		If _lJob
			If ValType(_cEmpresa) <> "C" .Or. ValType(_cFilial) <> "C"
				Aadd(_aMsg,"Problemas na informação de Empresa e Filial para executar ZPECF036, Faturamento não realizado para este Picking !")
				Break
			Endif
			Conout("ZPECF036 - Iniciando JOB")
			If Type("cEmpAnt") <> "C" .or. cEmpAnt <> _cEmpresa .or. cFilAnt <> _cFilial
				Conout("ZPECF036 - Abrindo empresa "+_cEmpresa+" Filial "+_cFilial)
				RpcClearEnv()
				RPCSetType(3)
				RpcSetEnv(_cEmpresa,_cFilial,,,,GetEnvServer(),{ })
			Endif
		Endif
		If Len(_aOrcs) == 0
			Aadd(_aMsg,"Não informado orçamentos para Faturar!")
			Break
		Endif
		Private aOrcs := _aOrcs  //necessario para utilizar PE OX004APV
		If _lTransaction
			Begin Transaction
				_lRet := ZPECF036PV(_aOrcs, _cPicking, @_cPedido, @_aRegVS1, @_aPicking, @_aVS9, @_aMsg)
				If _lRet
					_lRet := ZPECF036FT(_cPedido, _cPicking, @_cNota, @_cSerie, @_cTitulo, _aRegVS1, _aVS9, @_aMsg)
				Endif
				If _lRet
					_lRet := ZPECF036AT(_cPedido, _cNota, _cSerie, _cTitulo, _aRegVS1, _aPicking, @_aMsg)
				Endif
				If !_lRet
					Disarmtransaction()
				Endif
			End Transaction
		Else
			If !ZPECF036PV(_aOrcs, _cPicking, @_cPedido, @_aRegVS1, @_aPicking, @_aVS9, @_aMsg)
				Break
			Endif
			If !ZPECF036FT(_cPedido, _cPicking, @_cNota, @_cSerie, @_cTitulo, _aRegVS1, _aVS9, @_aMsg)
				Break
			Endif
			If !ZPECF036AT(_cPedido, _cNota, _cSerie, _cTitulo, _aRegVS1, _aPicking, @_aMsg)
				Break
			Endif
			_lRet := .T.
		Endif
	End Sequence

	If Len(_aMsg) > 0
		//Gravo Informações no orçamento
		If Len(_aRegVS1) > 0
			For _nPos := 1 To Len(_aRegVS1)
				VS1->(DbGoto(_aRegVS1[_nPos]))
				VS1->(RecLock("VS1",.f.))
				VS1->VS1_OBSAGL	:= Upper(_aMsg[_nPos]) + CRLF + VS1->VS1_OBSAGL
				VS1->(MsUnlock())
			Next
		Endif
		//Se enviar e-mail referente a problemas no faturamento
		If _lEnviaEmail
			//Caso tenha sido enviado numero do picking e não passou para carregar o numero
			If Len(_aPicking) == 0 .and. !Empty(_cPicking)
				_aPicking  := {_cPicking}
			Endif
			ZPECF036EM(_aMsg, _cPedido, _aPicking, "Problemas no Faturamento")
		Endif
	Endif

Return _aMsg


////////////////////
//Gerar Pedido
Static Function ZPECF036PV(_aOrcs, _cPicking, _cPedido, _aRegVS1, _aPicking, _aVS9, _aMsg)
	Local _cAliasPesq 	:= GetNextAlias()
	Local _lRet 		:= .F.
	Local _cNumSeq		:= StrZero(0,Len(SC6->C6_ITEM))
	Local _aIteTempPV	:= {}
	Local _aCabPV 		:= {}
	Local _aItePv		:= {}
	Local _aVendedores	:= {}
	//Local _aPvlNfs 		:= {}
	//Local _aBloqueio	:= {}
	Local _aObsVS1		:= {}
	Local _nDESACE 		:= 0
	Local _nVALFRE 		:= 0
	Local _nVALSEG 		:= 0
	Local _nPESOL 		:= 0
	Local _nPESOB 		:= 0
	Local _nVOL1 		:= 0
	Local _nVOL2 		:= 0
	Local _nVOL3 		:= 0
	Local _nVOL4 		:= 0
	Local _nValPis 		:= 0
	Local _nValCof 		:= 0
	Local _nValICM 		:= 0
	Local _nValDes 		:= 0
	Local _nValTot 		:= 0
	Local _nValDup 		:= 0
	Local _nValST  		:= 0
	Local _nValIPI 		:= 0
	Local _nVALPEC 		:= 0
	Local _nPERDES 		:= 0
	Local _nItVLDESC 	:= 0
	Local _nItVALTOT 	:= 0
	//Local _nAcresFin	:= 0
	//Local _aLivroVEC    := {}
	Local _cBanco      	:= ""
	Local _cObs			:= ""
	Local _lESTNEG     	:= GetMV("MV_ESTNEG") == "S"
	Local _cErro
	Local _aError
	Local _nRegVS1
	Local _cDocto
	Local _nPos
	Local _nCount
	Local _lReserva
	Local _lExisteReserva 
	Local _nQtdLib
	Local _lCredito
	Local _lEstoque
	Local _lLiber
	Local _lTransf
	Local _cProduto := ""

	Default _aRegVS1	:= {}
	Default _aPicking 	:= {}
	Default _cPicking   := ""
	Default _aMsg       := {}
	Default _aVS9		:= {}

	Private aTitSE1 := {}  //necessário cria pois na chamada da função OX100VS9E1 adicionara  registros
	Private aHeaderP    	:= {} 							// Variavel ultilizada na OX001RESITE
	Private _aReservaCAOA 	:= {}	// Variavel utilizada no PE OX001RES

	Begin Sequence
		// Desreserva dos Itens
		For _nPos := 1 to Len(_aOrcs)
			VS1->(DBSetOrder(1))
			If !VS1->(DBSeek(xFilial("VS1")+_aOrcs[_nPos]))
				Aadd(_aMsg,"Orçamento "+_aOrcs[_nPos]+ " não localizado, para a geração da Nota Fiscal")
				Break
			Endif
			//Guardar informações pois serão utilizadas em diversos processamentos
			_nRegVS1 	:= VS1->(Recno())
			Aadd(_aRegVS1,_nRegVS1)
			//Tem que estar no Status F = A Faturar
			If VS1->VS1_STATUS <> "F"
				Aadd(_aMsg,"Orçamento "+VS1->VS1_NUMORC+" com Status "+AllTrim(VS1->VS1_STATUS)+" diferente de Status A FATURAR, para a geração da Nota Fiscal ")
				Break
			Endif
			//Não permitir faturamento caso não esteja preenchido o picking
			If Empty(VS1->VS1_XPICKI)
				Aadd(_aMsg,"Orçamento "+VS1->VS1_NUMORC+" não possui Picking, não será gerado Nota Fiscal")
				Break
			Endif
			//localizar picking
			SZK->(DbSetOrder(1))
			If !SZK->(DbSeek(FWxFilial("SZK")+VS1->VS1_XPICKI))
				Aadd(_aMsg,"Orçamento "+VS1->VS1_NUMORC+" com Picking "+VS1->VS1_XPICKI+" não localizado, não será gerado Nota Fiscal")
				Break
			Endif
			//Verificar se o Picking esta liberado para faturamento
			If 	!Empty(SZK->ZK_NF) .Or. SZK->ZK_STATUS $ 'B_C_F_D' .Or. Empty(SZK->ZK_STREG)
				Aadd(_aMsg,"Orçamento "+VS1->VS1_NUMORC+" com Picking "+VS1->VS1_XPICKI+" o picking não possui status para faturamento, não será gerado Nota Fiscal")
				Break
			Endif
			/*
				//Caso informado picking validar com orçamento, desta forma estou permitindo somente faturar um picking 
				If !Empty(_cPicking) .And. AllTrim(_cPicking) <> AllTrim(VS1->VS1_XPICKI)
					Aadd(_aMsg,"Orçamento "+VS1->VS1_NUMORC+" com Picking "+VS1->VS1_XPICKI+" diferente do Picking para faturamento "+_cPicking+", não será geraco notafiscal Nota Fiscal ") 
					Break
				Endif
			*/
			//Guardar numero do picking
			If Ascan(_aPicking,VS1->VS1_XPICKI) == 0
				Aadd(_aPicking,VS1->VS1_XPICKI)
			Endif
			If Empty(_cPicking) .And. !Empty(VS1->VS1_XPICKI)
				_cPicking := VS1->VS1_XPICKI
			Endif

			_lReserva   := VS3->(FieldPos("VS3_RESERV")) > 0 .and. VS1->(FieldPos("VS1_RESERV")) > 0
			_cBanco     := If(Empty(_cBanco), VS1->VS1_CODBCO, _cBanco)
			VS3->(DBSetOrder(1))
			If !VS3->(DBSeek(xFilial("VS3")+VS1->VS1_NUMORC))
				Aadd(_aMsg,"Não encontrado itens para o Orçamento "+AllTrim(VS1->VS1_NUMORC))
				Break
			Endif
			_lExisteReserva	:= .F.
			_nPosItem := 1
			U_XFUNIPOSTO(VS3->VS3_NUMORC, cEmpAnt, cFilAnt, .T. /*_lJob*/)

			//Abrindo a tabela de Produtos e posicionando no topo
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
			SB1->(DbGoTop())
			
			
			//Prepara itens para execauto
			While VS3->(!Eof()) .And. FwXFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL+VS3->VS3_NUMORC
				/*
					OX001PecFis()
					//VS1_VLBRNF = 0 recalcula valores com o desconto zerado (não é enviado para o faturamento)
					If VS1->(FieldPos("VS1_VLBRNF")) > 0 .and. VS1->VS1_VLBRNF == "0" .and. VS1->(FieldPos("VS1_FPGBAS")) > 0 .and. !Empty(VS1->VS1_FPGBAS)
						MaFisAlt("IT_DESCONTO"	, 0, _nPosItem)
						MaFisAlt("IT_PRCUNI"	, VS3->VS3_VALPEC - VS3->VS3_VALDES / VS3->VS3_QTDITE, _nPosItem)
						MaFisAlt("IT_VALMERC"	, VS3->VS3_VALTOT, _nPosItem)
						_nValIPI	+= MaFisRet(n,"IT_VALIPI")
						_nValST		+= MaFisRet(n,"IT_VALSOL")
					EndIf
					_nValPis 	:= MaFisRet(_nPosItem,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
					_nValCof 	:= MaFisRet(_nPosItem,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
					_aLivroVEC 	:= MaFisRet(_nPosItem,"IT_LIVRO")
					_nValICM 	:= aLivroVEC[5]
					OX001FisPec()
					//
					aAdd(aImposVEC,{_nValICM, _nValPis, _nValCof})
					_nValDup	:= MaFisRet(,"NF_BASEDUP")

					_nSaldo := _nValDup
					_nSaldo += _nAcresFin

					if VS3->VS3_RESERV == "1"
						_lExisteReserva := .T.
					Endif
				*/
				//Preparar carga para gravar Pedido
				
				_cNumSeq 	:= Soma1(_cNumSeq)
				If  VS1->(FieldPos("VS1_VLBRNF")) > 0 .and. VS1->VS1_VLBRNF == "0" // Nao passar o Valor Bruto para NF/Loja
					_nVALPEC 	:= VS3->VS3_VALPEC - ( VS3->VS3_VALDES / VS3->VS3_QTDITE )
					_nPERDES 	:= 0
					_nItVLDESC 	:= 0
					_nItVALTOT 	:= VS3->VS3_VALTOT+VS3->VS3_VALDES
				Else // Passar Valor Bruto e Desconto para NF/Loja
					_nVALPEC 	:= VS3->VS3_VALPEC
					_nPERDES 	:= VS3->VS3_PERDES
					_nItVLDESC 	:= VS3->VS3_VALDES
					_nItVALTOT 	:= VS3->VS3_VALTOT+VS3->VS3_VALDES
				EndIf
				_nValPis := VS3->VS3_VALPIS
				_nValCof := VS3->VS3_VALCOF
				_nValICM := VS3->VS3_ICMCAL
				_nValDes := _nItVLDESC

				_cProduto := alltrim(VS3->VS3_CODITE)
				SB1->(MsSeek(FWxFilial("SB1") + _cProduto  )) //Posicionar item a ser inserido no PV (B1_FILIAL+B1_COD)

				aAdd(_aIteTempPV,{"C6_ITEM"   ,	_cNumSeq			,Nil})
				aAdd(_aIteTempPV,{"C6_PRODUTO",	SB1->B1_COD  		,Nil})
				aAdd(_aIteTempPV,{"C6_TES"    ,	VS3->VS3_CODTES  	,Nil})
				aAdd(_aIteTempPV,{"C6_ENTREG" ,	dDataBase  			,Nil})
				aAdd(_aIteTempPV,{"C6_UM"     ,	SB1->B1_UM         	,Nil})
				aAdd(_aIteTempPV,{"C6_LOCAL"  ,	VS3->VS3_LOCAL		,Nil})
				aAdd(_aIteTempPV,{"C6_QTDVEN" ,	VS3->VS3_QTDITE		,Nil})
				aAdd(_aIteTempPV,{"C6_QTDLIB" ,	0              		,Nil})
				aAdd(_aIteTempPV,{"C6_PRUNIT" ,	_nVALPEC			,Nil})
				aAdd(_aIteTempPV,{"C6_PRCVEN" ,	_nVALPEC			,Nil})
				aAdd(_aIteTempPV,{"C6_VALOR"  ,	_nItVALTOT			,Nil})
				aAdd(_aIteTempPV,{"C6_VALDESC",	_nItVLDESC			,Nil})
				// Ticket: 1932063
				// ISSUE: MMIL-2426
				// O TES está sendo enviado novamente pois na base o cliente ocorria uma falha. O conteudo do TES na aCols (MATA410)
				// ficava com conteúdo VAZIO.
				// O problema nao foi reproduzido em base teste, mas verificamos que passando o TES novamente a falha não ocorria novamente
				// A mensagem de HELP disparada era A410VZ.
				aAdd(_aIteTempPV,{"C6_TES"    	, VS3->VS3_CODTES  					,Nil})
				if VS3->(FieldPos("VS3_SITTRI")) > 0
					aAdd(_aIteTempPV,{"C6_CLASFIS", VS3->VS3_SITTRI  				,Nil})
				Endif
				aAdd(_aIteTempPV,{"C6_CLI"    	, VS1->VS1_CLIFAT      				,Nil})
				aAdd(_aIteTempPV,{"C6_LOJA"   	, VS1->VS1_LOJA  				    ,Nil})
				if VS3->(FieldPos("VS3_LOTECT")) > 0 .and. !Empty(VS3->VS3_LOTECT)
					aAdd(_aIteTempPV,{"C6_LOTECTL" , VS3->VS3_LOTECT         		,Nil})
					aAdd(_aIteTempPV,{"C6_NUMLOTE" , VS3->VS3_NUMLOT         		,Nil})
				endif
				if VS3->(FieldPos("VS3_LOCALI")) > 0 .and. !Empty(VS3->VS3_LOCALI)
					aAdd(_aIteTempPV,{"C6_LOCALIZ" , VS3->VS3_LOCALI         		,Nil})
				endif
				if VS1->VS1_TIPORC == "1"
					If SC6->(FieldPos("C6_CC"))>0 .and. VS3->(FieldPos("VS3_CENCUS"))>0
						aAdd(_aIteTempPV,{"C6_CC" , VS3->VS3_CENCUS 				,Nil})
					Endif
					If SC6->(FieldPos("C6_CONTA"))>0 .and. VS3->(FieldPos("VS3_CONTA"))>0
						aAdd(_aIteTempPV,{"C6_CONTA" , VS3->VS3_CONTA 				,Nil})
					Endif
					If SC6->(FieldPos("C6_ITEMCTA"))>0 .and. VS3->(FieldPos("VS3_ITEMCT"))>0
						aAdd(_aIteTempPV,{"C6_ITEMCTA" , VS3->VS3_ITEMCT 			,Nil})
					Endif
					If SC6->(FieldPos("C6_CLVL"))>0 .and. VS3->(FieldPos("VS3_CLVL"))>0
						aAdd(_aIteTempPV,{"C6_CLVL" , VS3->VS3_CLVL 				,Nil})
					Endif
				Endif
				If SC6->(FieldPos("C6_FCICOD"))>0 .and. (VS3->(FieldPos("VS3_FCICOD"))>0 .and. !Empty(VS3->VS3_FCICOD) )
					aAdd(_aIteTempPV,{"C6_FCICOD" , VS3->VS3_FCICOD 				,Nil})
				Endif
				If SC6->(FieldPos("C6_NUMPCOM"))>0 .and. (VS3->(FieldPos("VS3_PEDXML"))>0 .and. !Empty(VS3->VS3_PEDXML) )
					aAdd(_aIteTempPV,{"C6_NUMPCOM" , VS3->VS3_PEDXML 				,Nil})
				Endif
				If SC6->(FieldPos("C6_ITEMPC"))>0 .and. (VS3->(FieldPos("VS3_ITEXML"))>0 .and. !Empty(VS3->VS3_ITEXML) )
					aAdd(_aIteTempPV,{"C6_ITEMPC" , VS3->VS3_ITEXML 				,Nil})
				Endif
				// NT 2021.004 v1.21 - Alecsandre Ferreira
				if SC6->(FieldPos("C6_OBSCONT")) > 0 .AND. (VS3->(FieldPos("VS3_OBSCON")) > 0 .and. !Empty(VS3->VS3_OBSCON) )
					aAdd(_aIteTempPV,{"C6_OBSCONT", VS3->VS3_OBSCON					,Nil})
				endif
				if SC6->(FieldPos("C6_OBSCCMP")) > 0 .AND. (VS3->(FieldPos("VS3_OBSCCM")) > 0 .and. !Empty(VS3->VS3_OBSCCM) )
					aAdd(_aIteTempPV,{"C6_OBSCCMP", VS3->VS3_OBSCCM					,Nil})
				endif
				if SC6->(FieldPos("C6_OBSFISC")) > 0 .AND. (VS3->(FieldPos("VS3_OBSFIS")) > 0 .and. !Empty(VS3->VS3_OBSFIS) )
					aAdd(_aIteTempPV,{"C6_OBSFISC", VS3->VS3_OBSFIS					,Nil})
				endif
				if SC6->(FieldPos("C6_OBSFCMP")) > 0 .AND. (VS3->(FieldPos("VS3_OBSFCP")) > 0 .and. !Empty(VS3->VS3_OBSFCP) )
					aAdd(_aIteTempPV,{"C6_OBSFCMP", VS3->VS3_OBSFCP					,Nil})
				endif
				If SC6->(FieldPos("C6_XORCVS3")) > 0
					aAdd(_aIteTempPV,{"C6_XORCVS3" , VS3->VS3_NUMORC 				,Nil})
				Endif

				// NT 2021.004 v1.21
				If ( ExistBlock("OXX004AIPV") )
					_aIteTempPV := ExecBlock("OXX004AIPV",.f.,.f.,{_aIteTempPV})
				EndIf
				// CUSTOMIZACAO DO ITEM DO PEDIDO DE VENDA MATA410
				If ( ExistBlock("OX004AIP") )
					_aIteTempPV := ExecBlock("OX004AIP",.f.,.f.,{_aIteTempPV})
				EndIf
				aAdd(_aItePv,aClone(_aIteTempPV))

				VS3->(DBSkip())
			Enddo
			//VS1_RESERV -> Reserva peça?
			//VS1_RESERV == "0" -> Não
			//VS1_RESERV == "1" -> Sim
			Reclock("VS1",.f.)
			If _lExisteReserva .And. VS1->VS1_RESERV <> "1"
				VS1->VS1_RESERV := "1"
			ElseIf !_lExisteReserva .And. VS1->VS1_RESERV <> "0"
				VS1->VS1_RESERV := "0"
			Endif
			VS1->(MsUnlock())

			// PE ANTES DE DESRESERVAR O ITEM
			If  ExistBlock("OX04RESITE")       // O B S O L E T O
				VS1->(DbGoto(_nRegVS1))
				If !ExecBlock("OX04RESITE",.F.,.F.,{VS1->VS1_NUMORC})
					Aadd(_aMsg,"Orçamento "+AllTrim(VS1->VS1_NUMORC)+" com problemas PE OX04RESITE")
					Break
				Endif
			Endif
			If ExistBlock("OX004RIT")
				VS1->(DbGoto(_nRegVS1))
				If !ExecBlock("OX004RIT",.F.,.F.,{VS1->VS1_NUMORC})
					Aadd(_aMsg,"Orçamento "+AllTrim(VS1->VS1_NUMORC)+" com problemas PE OX004RIT")
					Break
				Endif
			Endif

			//Retirar as reservas
			VS1->(DbGoto(_nRegVS1))
			//OX004COND()

			If _lReserva .And. _lExisteReserva
				if VS1->(FieldPos("VS1_RESERV")) > 0 .and. VS1->VS1_RESERV == "1"
					HeaderP    		:= {} 						// Variavel utilizada na OX001RESITE
					_aReservaCAOA 	:= {VS1->VS1_NUMORC,.F.}	// Variavel utilizada no PE OX001RES
					_cDocto 		:= VS1->(OX001RESITE(VS1->VS1_NUMORC, .F.))
					if Empty(_cDocto) .Or. _cDocto == "NA"
						Aadd(_aMsg,"Orçamento "+AllTrim(VS1->VS1_NUMORC)+" não foi possivel retirar a reserva")
						Break
					Endif
					_cObs := "Retirado Reserva para faturamento dos produtos referente orçamento "+VS1->VS1_NUMORC+" documento "+_cDocto
					Aadd(_aObsVS1, _cObs)
				Endif
				//Caso onde não são marcados os controles de Reserva
			Elseif  At("R",OI001GETFASE(VS1->VS1_NUMORC)) != 0 .or. At("T",OI001GETFASE(VS1->VS1_NUMORC)) != 0
				aHeaderP    	:= {} 							// Variavel ultilizada na OX001RESITE
				_aReservaCAOA 	:= {VS1->VS1_NUMORC,.F.}	// Variavel utilizada no PE OX001RES
				_cDocto := VS1->(OX001RESITE(VS1->VS1_NUMORC, .F.))
				if Empty(_cDocto) .Or. _cDocto == "NA"
					//Aadd(_aMsg,"Orçamento "+AllTrim(VS1->VS1_NUMORC)+" não foi possivel retirar a reserva para documentos com fase R ou T")
					//Break  //neste caso não vou deixar abortar pois pode não existir a reserva
				Else
					_cObs := "[ZPECF036] Retirado Reserva para faturamento dos produtos referente orçamento "+VS1->VS1_NUMORC+" documento "+_cDocto+" com orçamentos com Status [R|T]"
					Aadd(_aObsVS1, _cObs)
				Endif
			Endif

			_nValFre 	+= VS1->VS1_VALFRE
			_nValDes 	+= VS1->VS1_DESACE
			_nValTot 	+= VS1->VS1_VTOTNF
			_nValDup 	+= VS1->VS1_VALDUP
			_nValSeg 	+= VS1->VS1_VALSEG
			_nValST  	+= VS1->VS1_ICMRET
			_nValIPI 	+= VS1->VS1_VALIPI
			_nDESACE 	+= VS1->VS1_DESACE

			//Guardar pesos acumulado para o cabeçalho
			If VS1->(Fieldpos('VS1_PESOB')) > 0 // Se possui o update dos novos campos processa
				_nPESOL += VS1->VS1_PESOL
				_nPESOB += VS1->VS1_PESOB
				_nVOL1 	+= VS1->VS1_VOLUM1
				_nVOL2 	+= VS1->VS1_VOLUM2
				_nVOL3 	+= VS1->VS1_VOLUM3
				_nVOL4 	+= VS1->VS1_VOLUM4
			EndIf
		Next
		
		/*
			//Ajustar valores
			MaFisRef("NF_DESPESA"	,, _nValDes)
			MaFisRef("NF_SEGURO"	,, _nValSeg)
			MaFisRef("NF_FRETE"		,, _nValFre)
			_nValTot := MaFisRet(,"NF_TOTAL") 	- MaFisRet(,"NF_DESCZF")
			_nValDup := MaFisRet(,"NF_BASEDUP") 	- MaFisRet(,"NF_DESCZF")
		*/
		//Se gera Pedido de Venda, verifica se tem estoque disponivel  #
		//para atender o pedido                                        #
		if GetMV("MV_ESTNEG") <> "S"
			if OFXFA0034_AlgumaPecaSemSaldo(_aOrcs, .F.)
				Aadd(_aMsg,"Existem Orçamentos sem saldo para faturamento para o picking "+_cPicking)
				Break
			Endif
		EndIf

		//Pego o ultimo orçamento para referenciar no SC5 cabeçalho
		VS1->(DbGoto(_nRegVS1))

		//Carrega Cabeçalho
		_aVendedores := {{VS1->VS1_CODVEN,0},{VS1->VS1_CODVE2,0},{VS1->VS1_CODVE3,0},{VS1->VS1_CODVE4,0},{VS1->VS1_CODVE5,0}}
		SA3->(DBSetOrder(1))
		For _nCount := 1 to 5
			If !Empty(_aVendedores[_nCount,1])
				SA3->(DBSeek(xFilial("SA3")+_aVendedores[_nCount,1]))
				_aVendedores[_nCount,2] := SA3->A3_COMIS
			Endif
		Next

		//Nic Lima 05/02/2024 - GAP098 - Alinhado com Juarez e DAC.
		//Deve ser mantida a condição de pagamento original do orçamento.
		//_cTipPag := RetCondVei()   //Condição de Pagamento
		_cTipPag := VS1->VS1_FORPAG  //Condição de Pagamento

		aAdd(_aCabPV,{"C5_TIPO"   , "N"					,Nil})
		aAdd(_aCabPV,{"C5_CLIENTE", VS1->VS1_CLIFAT  	,Nil})
		aAdd(_aCabPV,{"C5_LOJACLI", VS1->VS1_LOJA  		,Nil})
		if ( VS1->(FieldPos("VS1_TIPCLI")) > 0 .And. !Empty(VS1->VS1_TIPCLI) )
			aAdd(_aCabPV,{"C5_TIPOCLI",VS1->VS1_TIPCLI 	,Nil})
		Else
			aAdd(_aCabPV,{"C5_TIPOCLI",SA1->A1_TIPO		,Nil})
		endif
		aAdd(_aCabPV,{"C5_TRANSP" , VS1->VS1_TRANSP  	,Nil})
		aAdd(_aCabPV,{"C5_CONDPAG", _cTipPag			,Nil})
		aAdd(_aCabPV,{"C5_VEND1"  , _aVendedores[1,1]	,Nil})
		aAdd(_aCabPV,{"C5_COMIS1" , _aVendedores[1,2] 	,Nil})
		aAdd(_aCabPV,{"C5_VEND2"  , _aVendedores[2,1]	,Nil})
		aAdd(_aCabPV,{"C5_COMIS2" , _aVendedores[2,2]	,Nil})
		aAdd(_aCabPV,{"C5_VEND3"  , _aVendedores[3,1]	,Nil})
		aAdd(_aCabPV,{"C5_COMIS3" , _aVendedores[3,2]	,Nil})
		aAdd(_aCabPV,{"C5_VEND4"  , _aVendedores[4,1]	,Nil})
		aAdd(_aCabPV,{"C5_COMIS4" , _aVendedores[4,2]	,Nil})
		aAdd(_aCabPV,{"C5_VEND5"  , _aVendedores[5,1]	,Nil})
		aAdd(_aCabPV,{"C5_COMIS5" , _aVendedores[5,2]	,Nil})
		aAdd(_aCabPV,{"C5_EMISSAO", ddatabase         	,Nil})
		if VS1->(FieldPos("VS1_MENNOT")) > 0
			aAdd(_aCabPV,{"C5_MENNOTA", VS1->VS1_MENNOT ,Nil})
			aAdd(_aCabPV,{"C5_MENPAD" , VS1->VS1_MENPAD ,Nil})
		endif
		aAdd(_aCabPV,{"C5_MOEDA"  , 1                	,Nil}) // Moeda
		If !Empty(_cBanco) // Caso exista a informação do banco
			aAdd(_aCabPV,{"C5_BANCO"  , _cBanco   		,Nil})
		Else
			aAdd(_aCabPV,{"C5_BANCO"  , VS1->VS1_CODBCO	,Nil})
		EndIf
		aadd(_aCabPV,{"C5_DESPESA", _nDESACE   			,Nil}) // Despesas na Venda a Integrar na NF
		aadd(_aCabPV,{"C5_FRETE"  , _nVALFRE   			,Nil}) // Despesas na Venda a Integrar na NF
		aadd(_aCabPV,{"C5_SEGURO" , _nVALSEG   			,Nil}) // Despesas na Venda a Integrar na NF
		aadd(_aCabPV,{"C5_TPFRETE", VS1->VS1_PGTFRE   	,Nil})
		If VS1->(Fieldpos('VS1_PESOB')) > 0 // Se possui o update dos novos campos processa
			aAdd(_aCabPV, {"C5_PESOL"  , _nPESOL  		,Nil})
			aAdd(_aCabPV, {"C5_PBRUTO" , _nPESOB  		,Nil})
			aAdd(_aCabPV, {"C5_VEICULO", VS1->VS1_VEICUL,Nil})
			aAdd(_aCabPV, {"C5_VOLUME1", _nVOL1 		,Nil})
			aAdd(_aCabPV, {"C5_VOLUME2", _nVOL2 		,Nil})
			aAdd(_aCabPV, {"C5_VOLUME3", _nVOL3 		,Nil})
			aAdd(_aCabPV, {"C5_VOLUME4", _nVOL4 		,Nil})
			aAdd(_aCabPV, {"C5_ESPECI1", VS1->VS1_ESPEC1,Nil})
			aAdd(_aCabPV, {"C5_ESPECI2", VS1->VS1_ESPEC2,Nil})
			aAdd(_aCabPV, {"C5_ESPECI3", VS1->VS1_ESPEC3,Nil})
			aAdd(_aCabPV, {"C5_ESPECI4", VS1->VS1_ESPEC4,Nil})
		EndIf

		If SC5->(FieldPos("C5_NATUREZ")) <> 0
			aAdd(_aCabPV,{"C5_NATUREZ" , VS1->VS1_NATURE ,Nil } ) // Natureza no Pedido
		EndIf
		If SC5->(FieldPos("C5_INDPRES")) > 0 .and. ( VS1->(FieldPos("VS1_INDPRE")) > 0 .and. !Empty(VS1->VS1_INDPRE) )
			aAdd(_aCabPV, {"C5_INDPRES",  VS1->VS1_INDPRE ,Nil}) //Presenca do Comprador
		Endif
		If SC5->(FieldPos("C5_NTEMPEN")) > 0 .And. ( VS1->(FieldPos("VS1_NTEMPE")) > 0 .and. !Empty(VS1->VS1_NTEMPE) )
			aAdd(_aCabPV, {"C5_NTEMPEN",  VS1->VS1_NTEMPE ,Nil}) // Nt Empenho
		EndIf
		If SC5->(FieldPos("C5_CODA1U")) > 0 .and. ( VS1->(FieldPos("VS1_CODA1U")) > 0 .and. !Empty(VS1->VS1_CODA1U) )
			aAdd(_aCabPV, {"C5_CODA1U",  VS1->VS1_CODA1U ,Nil})
		Endif
		//Necessário pois os PEs tratam privates
		Private aCabPV 		:= _aCabPV
		Private aItePv 		:= _aItePv

		//Pego o ultimo orçamento para a referenciar no SC5 cabeçalho
		// PE ANTES DA MONTAGEM DO PEDIDO DE VENDA
		if ExistBlock("OXX004AMPV") // O B S O L E T O
			VS1->(DbGoto(_nRegVS1))
			if !ExecBlock("OXX004AMPV",.f.,.f.)
				Aadd(_aMsg,"Retorno PE OXX004AMPV não esta permitindo faturamento")
				Break
			Endif
		Endif

		//Pego o ultimo orçamento para a referenciar no SC5 cabeçalho
		if ExistBlock("OX004AMP")
			VS1->(DbGoto(_nRegVS1))
			if !ExecBlock("OX004AMP",.f.,.f.)
				Aadd(_aMsg,"Retorno PE OX004AMP não esta permitindo faturamento")
				Break
			Else
				_aCabPV 	:= aCabPV
				_aItePv		:= aItePv
			Endif
		Endif

		// PE ANTES DA GERACAO DO PEDIDO DE VENDA
		if ExistBlock("OXX004APV")
			//Pego o ultimo orçamento par a referenciar no SC5 cabeçalho
			VS1->(DbGoto(_nRegVS1))
			if !ExecBlock("OXX004APV",.f.,.f.,)
				Aadd(_aMsg,"Retorno PE OXX004APV não esta permitindo faturamento")
				Break
			Else
				_aCabPV 	:= aCabPV
				_aItePv		:= aItePv
			Endif
		Endif

		if ExistBlock("OX004APV")
			//Pego o ultimo orçamento par a referenciar no SC5 cabeçalho
			VS1->(DbGoto(_nRegVS1))
			if !ExecBlock("OX004APV",.f.,.f.,{@_aCabPV, @_aItePv})
				Aadd(_aMsg,"Retorno PE OX004APV não esta permitindo faturamento")
				Break
			Else
				_aCabPV 	:= aCabPV
				_aItePv		:= aItePv
			Endif
		Endif

		//////////////////////////////////////
		//DAC___
		//# Grava VS9                                                                 #
		nVS9Seq := 0
		//OX0040035_CondicaoPagamento(cCond,nOpc
		AaDD(_aVS9, {VS1->VS1_NUMORC, "DP", _nValDup, dDataBase})

		//INCLUIR VS9
		_cTipo := "DP"
		VS9->(DbSetOrder(1))  //
		VS9->(reclock("VS9",.T.))
		VS9->VS9_FILIAL := xFilial("VS9")
		VS9->VS9_NUMIDE := VS1->VS1_NUMORC
		VS9->VS9_SEQUEN := STRZERO(1,TamSX3("VS9_SEQUEN")[1])
		VS9->VS9_DATPAG := dDataBase
		VS9->VS9_VALPAG := _nValDup
		VS9->VS9_TIPPAG := _cTipo
		VS9->VS9_ENTRAD := "N"
		VS9->(MsUnlock())

		//Pego o ultimo orçamento par a referenciar no SC5 cabeçalho
		VS1->(DbGoto(_nRegVS1))
		ZPECFTONEG(@_aCabPV) // Carrega negociacao quando condicao de pagamento do tipo 9 ou A verifica VS9

		// CHAMADA DO MATA410 COM OS DADOS DA INTEGRACAO #
		Private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
		//Private lMsHelpAuto 	:= .T.  // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
		Private lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog

		MSExecAuto({|x,y,z|Mata410(x,y,z)},_aCabPV,_aItePv,3)
		//
		If lMsErroAuto
			_cErro := "[ZPECFTORC] Problemas no execauto Mata410" + CRLF
			// se estiver em debug, pega o log inteiro do erro para uma analise mais detalhada
			_aError := GetAutoGRLog()
			For _nPos := 1 To Len(_aError)
				If !Empty((AllTrim(_aError[_nPos])))
					_cErro	+= 	AllTrim(_aError[_nPos]) + CRLF
				EndIf
			Next _nPos
			Aadd(_aMsg,_cErro)
			Break
		EndIf

		//Fazer a liberação dos Pedidos
		_lCredito := .T.
		_lEstoque := .T.
		_lLiber   := .T.
		_lTransf  := .T.

		SC9->(dbSetOrder(1))
		SC6->(dbSetOrder(1))
		SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM + "01"))
		While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == SC5->C5_NUM
			If !SC9->(dbSeek(FWxFilial("SC9")+SC5->C5_NUM+SC6->C6_ITEM))
				_nQtdLib := SC6->C6_QTDVEN
				_nQtdLib := MaLibDoFat(SC6->(RecNo()),_nQtdLib,@_lCredito,@_lEstoque,.F.,(!_lESTNEG),_lLiber,_lTransf)
			EndIf
			SC6->(dbSkip())
		Enddo
		_cPedido := SC5->C5_NUM
		//Atualizar Pedido com o numero da Cotação sempre será utilizado o numero inicial
		/*
			//Nic Lima 29/01/2024 - GAP098 - Alinhado com Juarez.
			//Deve ser gravado o número de Picking no PV, isso já é feito no execauto.
			If SC5->(FieldPos("C5_XPICKI")) > 0
				SC5->(RecLock("SC5",.f.))
				SC5->C5_XPICKI = VS1->VS1_NUMORC
				SC5->(MsUnlock())
			Endif
		*/
		/*

			// Liberacao de pedidos
			Ma410LbNfs( 2, @_aPvlNfs, @_aBloqueio )
			// Checa itens liberados
			Ma410LbNfs( 1, @_aPvlNfs, @_aBloqueio )

			If Len(_aBloqueio) > 0
				_cErro := "Existe bloqueio de Crédito para a aprovação do Pedido "+_cPedido+" o mesmo não será gravado"
				Aadd(_aMsg,_cErro)
				_lRet := .F. 
				Break
			Endif 
		*/
		//Atualizar a Cotação
		_cObs := "Criado Pedido de Vendas "+_cPedido + CRLF
		If Len(_aObsVS1)
			For _nPos := 1 To Len(_aObsVS1)
				_cObs += _aObsVS1[_nPos] + CRLF
			Next
		Endif
		_cObs += "Liberado Pedido de Venda "+_cPedido + CRLF
		For _nPos := 1 To Len(_aRegVS1)
			VS1->(DbGoto(_aRegVS1[_nPos]))
			VS1->(RecLock("VS1",.f.))
			VS1->VS1_OBSAGL	:= Upper(_cObs) + CRLF + VS1->VS1_OBSAGL
			VS1->(MsUnlock())
		Next
		_lRet := .T.

	End Sequence
	//No caso de Ter abortado e não ter trazido os orçamentos com seus numeros de registros Pego estes numeros pelo Picking
	If Len(_aRegVS1) == 0 .And. !Empty(_cPicking)
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário
		SELECT 	ISNULL(VS1.R_E_C_N_O_,0) NREGVS1
				, VS1.VS1_XPICKI
			FROM  	%Table:VS1% VS1
			WHERE 	VS1.VS1_FILIAL 	= %xFilial:VS1%
				AND VS1.VS1_XPICKI 	= %Exp:_cPicking%
				AND VS1.%notDel%
		EndSql
		If (_cAliasPesq)->(!Eof())
			While (_cAliasPesq)->(!Eof())
				Aadd(_aRegVS1, (_cAliasPesq)->NREGVS1)
				If Ascan(_aPicking,VS1->VS1_XPICKI) == 0
					Aadd(_aPicking,VS1->VS1_XPICKI)
				Endif
				(_cAliasPesq)->(DbSkip())
			EndDo
		Endif
		If Select((_cAliasPesq)) <> 0
			(_cAliasPesq)->(DbCloseArea())
			Ferase(_cAliasPesq+GetDBExtension())
		Endif
	Endif
	//Garanto que tera um numero de picking para atualizar
	If Len(_aPicking) == 0 .And. !Empty(_cPicking)
		_aPicking := {_cPicking}
	ElseIf Len(_aPicking) > 0 .And. Empty(_cPicking)
		_cPicking := _aPicking[1]
	Endif
Return _lRet



//Gerar nota fiscal
Static Function ZPECF036FT(_cPedido, _cPicking, _cNota, _cSerie, _cTitulo, _aRegVS1, _aVS9, _aMsg)
	Local _cAliasPesq 	:= GetNextAlias()
	Local _lRet 		:= .F.
	Local _nPrcVen		:= 0
	Local _cCliente 	:= ""
	Local _cLoja		:= ""
	Local _cAtuGerFin	:= ""
	Local _nModBkp 		:= nModulo
	Local _cModBkp 		:= cModulo
	Local _cPrefBAL 	:= GetNewPar("MV_PREFBAL","BAL")
	Local _cTipPer     	:= Left(Alltrim(GetNewPar("MV_TIPPER","TP"))+space(3),Len(SE1->E1_TIPO)) // Tipo de Titulo Provisorio
	Local _aPvlNfs		:= {}
	Local _cSerieHYU 	:= Alltrim(SuperGetmv("ZCD_FAT001",.F.,"")) //Serie HYU (Barueri)
	Local _cSerieCHE 	:= Alltrim(SuperGetmv("ZCD_FAT002",.F.,"")) //Serie Che (Barueri)
	Local _cSerieSBR 	:= Alltrim(SuperGetmv("ZCD_FAT003",.F.,"")) //Serie SBR (Barueri)
	Local _c1DUPNAT     := GetMV("MV_1DUPNAT")
	Local _nRegVS1   	:= _aRegVS1[1]  //posicionar no primeiro orçamento
	Local _cNaturezaSA1:= ""
	Local _cPrefNF
	Local _lMostraCtb
	Local _lAglutCtb
	Local _lCtbOnLine
	Local _lCtbCusto
	Local _lReajuste
	Local _cPrefAnt
	Local _cMens
	Local _nPos
	Local _nRegSA1
	Local _cQuery
	Local _nStatus
	Local _lFinanceiro
	Local _nRegSC5
	Local _nRegSF2
	Local _nRegSE4

	Default _cPedido:= ""
	Default _cNota 	:= ""
	Default _cSerie	:= ""

	Begin Sequence
		VS1->(DbGoto(_nRegVS1))

		If Empty(_cPedido)
			Aadd(_aMsg, "Pedido não informado para faturamento")
			Break
		Endif

		SC5->(DbSetOrder(1))
		SC6->(DbSetOrder(1))
		SE4->(DbSetOrder(1)) //E4_FILIAL
		SB1->(DbSetOrder(1))
		SB2->(DbSetOrder(1))
		SF4->(DbSetOrder(1))
		SC9->(DbSetOrder(2)) //C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM

		If _cPedido <> SC5->C5_NUM
			If !SC5->(DbSeek(FWxFilial("SC5")+_cPedido))
				Aadd(_aMsg, "Não localizado Pedido "+_cPedido+" para faturamento")
				Break
			Endif
		Endif
		_nRegSC5 := SC5->(Recno())

		SA1->(DBSeek(xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA))
		_lPeriodico := .F.
		If SA1->A1_COND == VS1->VS1_FORPAG .And. !Empty(SA1->A1_COND)
			_lPeriodico := .t.
		Endif
		_cNaturezaSA1 	:= SA1->A1_NATUREZ //Guardo a Narureza SA1
		_nRegSA1		:= SA1->(Recno())
		// Altera natureza para gerar o titulo na natureza correta ...
		If !(Alltrim(SE4->E4_TIPO) $ "A.9")
			If !Empty(VS1->VS1_NATURE)
				If _c1DUPNAT == "SA1->A1_NATUREZ" .and. SA1->A1_NATUREZ <> VS1->VS1_NATURE
					SA1->(RecLock("SA1",.f.))
					SA1->A1_NATUREZ := VS1->VS1_NATURE
					SA1->(MsUnLock())
				EndIf
			Endif
		Endif

		//Carregar perguntas
		Pergunte("MT460A",.F.)
		_lMostraCtb := MV_PAR01 == 1
		_lAglutCtb  := MV_PAR02 == 1
		_lCtbOnLine := MV_PAR03 == 1
		_lCtbCusto  := MV_PAR04 == 1
		_lReajuste  := MV_PAR05 == 1
		_cCliente 	:= SC5->C5_CLIENTE
		_cLoja		:= SC5->C5_LOJACLI


		SC6->(DbGotop())
		If !SC6->( DbSeek(xFilial('SC6') + _cPedido) )
			Aadd(_aMsg, "Itens do Pedido "+_cPedido+" nao localizado para faturamento")
			Break
		Endif

		While SC6->( !Eof() ) .AND. SC6->C6_FILIAL == FWxFilial("SC6") .And.  SC6->C6_NUM ==  _cPedido
			If !SC9->( DbSeek( xFilial('SC9') + _cCliente + _cLoja + SC6->C6_NUM + SC6->C6_ITEM) )
				Aadd(_aMsg, "Pedido "+_cPedido+" não esta Liberados Para Faturamento")
				_lRet := .F.
				Break
			Endif
			// Posiciona na condicao de pagamento
			SE4->( DbSeek(xFilial('SE4') + SC5->C5_CONDPAG) )
			_nRegSE4 := SE4->(Recno())
			// Posiciona no produto
			SB1->( DbSeek(xFilial('SB1') + SC6->C6_PRODUTO) )
			// Posiciona no saldo em estoque
			SB2->( DbSeek(xFilial('SB2') + SC6->C6_PRODUTO + SC6->C6_LOCAL) )
			// Posiciona no TES
			SF4->( DbSeek(xFilial('SF4') + SC6->C6_TES) )
			// Converte o valor unitario em Reais quando pedido em outra moeda
			_nPrcVen := SC9->C9_PRCVEN
			//INDICAR SE USA FINACEIRO
			If SF4->F4_DUPLIC == "S"
				If Alltrim(SE4->E4_TIPO)=="A"
					_cAtuGerFin := "0"
				Else
					_cAtuGerFin := "1"
				Endif
			Endif

			/* JA ESTA GRAVADO NO SE5 DAC, ESTA CONDIÇÃO EXISTE NO OGIXX004
				// Altera natureza para gerar o titulo na natureza correta ...
				if !(Alltrim(SE4->E4_TIPO) $ "A.9")
					if !Empty(VS1->VS1_NATURE)
						If c1DUPNAT == "SA1->A1_NATUREZ" .and. SA1->A1_NATUREZ <> VS1->VS1_NATURE
							lAltSA1 := .t.
							cBkpNatSA1 := SA1->A1_NATUREZ
							RecLock("SA1",.f.)
							SA1->A1_NATUREZ := VS1->VS1_NATURE
							SA1->(MsUnLock())
						EndIf
						nRecSA1 := SA1->(Recno())
					Endif
				Endif
			*/
			// Monta array para gerar a nota fiscal
			Aadd(_aPvlNfs,{	SC9->C9_PEDIDO	,;  //01
			SC9->C9_ITEM	,;  //02
			SC9->C9_SEQUEN	,;  //03
			SC9->C9_QTDLIB	,;  //04
			_nPrcVen		,;  //05
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
		nModulo := 5
		cModulo := "FAT"

		/*
			//	lUsaNewKey := GetSX3Cache("F2_SERIE","X3_TAMANHO") == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso
			//	cSerieId   := IIf( lUsaNewKey , SerieNfId("SF2",4,"F2_SERIE",dDataBase,A460Especie(cSerie),cSerie) , cSerie )

			//	lContinua := Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS"),,,,@cSerieId,dDataBase ) // O parametro cSerieId deve ser passado para funcao Sx5NumNota afim de tratar a existencia ou nao do mesmo numero na funcao VldSx5Num do MATXFUNA.PRX

			//Private cSerie    := ""
			//lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))

			//_lRet := SX5NumNota(@_cSerie, GetNewPar("MV_TPNRNFS","1"))
			//If !_lRet
			//	Aadd(_aMsg,"Não foi possivel criar numero da Nota Fiscal")
			//	Break
			//Endif
			//Criar a Série da NF caso não exista
			//_RetVar := CriaSerSx5(SC5->C5_SERIE)
		*/
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida a inclusao da Nota Fiscal. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// CHAMADA DO MATA410 COM OS DADOS DA INTEGRACAO #
		_cSerie := ""
		If FWFilial() == "2001" //Barueri CD
			If VS1->VS1_XMARCA $ "HYU"
				_cSerie := AllTrim(_cSerieHYU)
			ElseIf VS1->VS1_XMARCA $ "CHE"
				_cSerie := AllTrim(_cSerieCHE)
			ElseIf VS1->VS1_XMARCA $ "SBR"
				_cSerie := AllTrim(_cSerieSBR)
			Endif
		Endif
		If Empty(_cSerie)
			Aadd(_aMsg, "Problemas com Série não foi possivel faturar")
			Break
		Endif

		Private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
		//Private lMsHelpAuto 	:= .T.  // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
		Private lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog
		_cNota := MaPvlNfs( _aPvlNfs,;         //1
		_cSerie,;			 //2
		(mv_par01 == 1),; //3
		(mv_par02 == 1),; //4
		(mv_par03 == 1),; //5
		(mv_par04 == 1),; //6
		.F.,;					//7
		0,;					//8
		0,; 					//9
		.T.,;					//10
		.F.,;					//11
		,;          		//12
		{ |x| OX100VS9E1(x,_cPrefBal,(SE4->E4_TIPO == "9"),_lPeriodico,_cTipPer) } ,;  //13
		,;          		//14
		,;          		//15
		,)          		//16

		If lMsErroauto
			_cErro := "[ZPECFTORC] Problemas no execauto MaPvlNfs" + CRLF
			// se estiver em debug, pega o log inteiro do erro para uma analise mais detalhada
			_aError := GetAutoGRLog()
			For _nPos := 1 To Len(_aError)
				If !Empty((AllTrim(_aError[_nPos])))
					_cErro	+= 	AllTrim(_aError[_nPos]) + CRLF
				EndIf
			Next
			AAdd(_aMsg,_cErro)
			Break
		EndIf

		_cNota 		:= PadR(_cNota		,TAMSX3("F2_DOC")[1])
		_cSerie 	:= PadR(_cSerie		,TAMSX3("F2_SERIE")[1])
		_cCliente 	:= PadR(_cCliente	,TAMSX3("F2_CLIENTE")[1])
		_cLoja 		:= PadR(_cLoja		,TAMSX3("F2_LOJA")[1])

		If Empty(_cNota)
			_cMens := "Problema ocorrido na gravação da Not Fiscal de Saida verificar tabelas relacionadas com processo, Pedido "+cPedido
			Aadd(_aMsg, _cMens)
			Break
		Endif
		SF2->(dbSetOrder(1))	//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If !(SF2->( dbSeek( xFilial("SF2") + _cNota + _cSerie + _cCliente + _cLoja ) ))
			_cMens := "Problema ocorrido na gravação da Nota Fiscal de Saida "+_cNota +" serie "+ _cSerie+". Nota Fiscal ja cadastrada, mas nao foi gerada Nota Fiscal para o pedido "+_cPedido
			Aadd(_aMsg, _cMens)
			Break
		EndIf

		// DEPOIS DA GERACAO DA NOTA FISCAL
		if ExistBlock("OX004DNF")
			if !ExecBlock("OX004DNF",.f.,.f.)
				Aadd(_aMsg, "Problemas ocorridos com Ponto de Entrada OX004DNF")
				Break
			Endif
		Endif
		//Atualizar dados da nota no VS1
		For _nPos := 1 to Len(_aRegVS1)
			VS1->(DbGoto(_aRegVS1[_nPos]))
			Reclock("VS1",.f.)
			VS1->VS1_NUMNFI	:= _cNota
			VS1->VS1_SERNFI := _cSerie
			VS1->(MsUnlock())
		Next

		//Gravar dados da nova
		Reclock("SF2",.f.)
		_cPrefAnt 		:= SF2->F2_PREFIXO
		SF2->F2_PREFORI := _cPrefBAL
		_cPrefNF 		:= &(GetNewPar("MV_1DUPREF","cSerie"))
		SF2->F2_PREFIXO := _cPrefNF
		SF2->(MsUnLock())
		_nRegSF2 := SF2->(RecNo())

		//Atualizar o financeiro caso crie
		_cTitulo := SF2->F2_DUPL
		//Caso não tenha o titulo significa que não era para a geração do titulo
		If !Empty(_cTitulo)
			BeginSql Alias _cAliasPesq //Define o nome do alias temporário
			SELECT 	ISNULL(SE1.R_E_C_N_O_,0) NREGSE1
				FROM  	%Table:SE1% SE1
				WHERE 	SE1.E1_FILIAL 	= %xFilial:SE1%
					AND SE1.E1_PREFIXO 	= %Exp:_cPrefAnt%
					AND SE1.E1_NUM		= %Exp:_cTitulo%
					AND SE1.%notDel%
			EndSql
			While (_cAliasPesq)->(!Eof())
				SE1->(DbGoto((_cAliasPesq)->NREGSE1))
				If RecLock("SE1",.F.)
					SE1->E1_PREFIXO := SF2->F2_PREFIXO
					SE1->E1_PREFORI := SF2->F2_PREFORI
					if _lPeriodico
						SE1->E1_TIPO := _cTipPer // MV_TIPPER - Tipo de Titulo Provisorio
					Endif
					SE1->(MsUnLock())
				Endif
				(_cAliasPesq)->(DbSkip())
			EndDo
			// Acerta E1_TITPAI para titulos gerados por condicao de pagamento padrao ...
			If FindFunction("OX100E1TITPAI")
				If !OX100E1TITPAI(aTitSE1)
					_cMens := "Problema ocorrido na gravação Financeiro titulo PAI [OX100E1TITPAI] ref. Nota Fiscal de Saida "+_cNota +" serie "+ _cSerie+". nao foi gerada Nota Fiscal e pedido "+_cPedido+" para o Picking "+_cPicking
					Aadd(_aMsg, _cMens)
					Break
				EndIf
			EndIf
		Endif

		//################################################################
		//# Geracao dos Titulos                                          #
		//################################################################
		VS1->(DbGoto(_nRegVS1))


		_lFinanceiro :=  ZPEFF036FN(VS1->VS1_NUMNFI, VS1->VS1_SERNFI, _nRegSC5, _nRegSF2, _nRegSE4, _aRegVS1, _aVS9, @_aMsg)
		If !_lFinanceiro
			_cMens := "Não foi possivel gerar Financeiro para a Nota "+_cNota+" Serie "+_cSerie+" referente ao picking "+_cPicking
			Aadd(_aMsg, _cMens)
			Break
		Endif
		//Atualizar o financeiro caso crie
		_cTitulo := SF2->F2_DUPL
		//Baixa titulos a vista, não esta validando retorno pois caso não consiga baixar deve continuar com processo
		ZPECF036BX(_cNota, @_aMsg)

		If VS1->(FieldPos("VS1_GERFIN")) > 0
			For _nPos := 1 to Len(_aRegVS1)
				VS1->(DbGoto(_aRegVS1[_nPos]))
				Reclock("VS1",.f.)
				VS1->VS1_GERFIN := IIf(_lFinanceiro,"1","0")
				VS1->(MsUnlock())
				// Se foi possivel gerar financeiro, vamos excluir todos os registros de logs ja gravados
				If _lFinanceiro
					// Exclui os LOGS gerados no momento do faturamento
					_cQuery := "DELETE FROM "+ RetSqlName("VQL")
					_cQuery += " WHERE VQL_FILIAL = '"+xFilial("VQL")+"' "
					_cQuery += "   AND VQL_AGROUP = 'OFIXX004' "
					_cQuery += "   AND VQL_FILORI = '" 	+ VS1->VS1_FILIAL + "' "
					_cQuery += "   AND VQL_TIPO = 'VS1-" + VS1->VS1_NUMORC + "'"
					_cQuery += "   AND D_E_L_E_T_ = ' '"

					_nStatus := TcSqlExec(_cQuery)
					If (_nStatus < 0)
						_cMens := "Não foi possivel atualizar LOGS gerados no momento do faturamento para a Nota "+_cNota+" Serie "+_cSerie+" referente ao picking "+_cPicking
						Aadd(_aMsg, _cMens)
					Endif
				Endif
			Next _nPos
		EndIf
		//Reposiciono no primeiro VS1
		VS1->(DbGoto(_nRegVS1))
		//Atualizo retorno para verdadeiro
		_lRet := .T.

	End Sequence
	nModulo := _nModBkp
	cModulo := _cModBkp
	//Verificar se a natureza SA1 foi alterada
	SA1->(DbGoto(_nRegSA1))
	If !Empty(_cNaturezaSA1) .And. SA1->A1_NATUREZ	<> _cNaturezaSA1
		SA1->(RecLock("SA1",.f.))
		SA1->A1_NATUREZ := _cNaturezaSA1
		SA1->(MsUnLock())
	Endif
	//apagar arquivo temporario
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif
Return _lRet

///////////////////////////////////////////////////////
/*/{Protheus.doc}  ZPEFF036FN
Funcao responsavel por gerar o Financeiro 
@author Manoel
@since 29/11/2017
@version 1.0
/*/
Static Function ZPEFF036FN(_cNota, _cSerie,  _nRegSC5, _nRegSF2, _nRegSE4, _aRegVS1, _aVS9, _aMsg)
	Local _lRet 		:= .F.

	Local _cAliasPesq 	:= GetNextAlias()

	Local _cNumPed		:= ""
	Local _cCodBco		:= ""
	Local _cPrefNF		:= ""
	Local _cTipCob		:= ""
	Local _cNumBord 	:= ""
	Local _dDatBord 	:= CtoD(Space(08))
	Local _cParcela		:= ""
	Local _cErro 		:= ""
	Local _cNumOrc		:= ""

	Local _nRecSA1		:= 0
	Local _nParcelas	:= 0
	Local _nValTit 		:= 0
	Local _aTitulo		:= {}
	Local _aError 		:= {}

	Local _cDupNat    	:= GetMV("MV_1DUPNAT")

	Local _nPos

	Local _nPicki 			:= 0 //GAP098
	Private lMsErroAuto 	:= .F.	//variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
	Private lAutoErrNoFile 	:= .T.  //variavel de Controle do GetAutoGRLog

	Default  _nRegSC5	:= 0
	Default _nRegSF2	:= 0
	Default _aRegVS1	:= {}

	Begin Sequence
		If Len(_aRegVS1) == 0
			Aadd(_aMsg,"Não enviado orçamentos para a geração do Financeiro")
			Break
		Endif

		VS1->(DbGoto(_aRegVS1[1]))  //posicionar no Primeiro orçamento
		_nPicki := (VS1->VS1_XPICKI) //Obter número de picking para usar na query da VS9 GAP098
		// Orcamento integrado com o Loja / Faturamento Direto, neste caso o controle de titulos no financeiro será do BackOffice
		If !Empty(VS1->VS1_PESQLJ)
			Break
		EndIf
		_cNumOrc := VS1->VS1_NUMORC 

		If  _nRegSC5  == 0
			Aadd(_aMsg,"Não informado numero do pedido para o orçamento")
			Break
		Endif

		If _nRegSF2 == 0
			Aadd(_aMsg,"Não informado numero da nota fiscal para o orçamento")
			Break
		Endif

		VS3->(DBSetOrder(1))

		If !VS3->(DBSeek(xFilial("VS3")+VS1->VS1_NUMORC))
			Aadd(_aMsg,"Não localizado item para o orçamento "+VS1->VS1_NUMORC+" para a geração do Financeiro")
			Break
		Endif

		If !SF4->(DbSeek(xFilial("SF4") + VS3->VS3_CODTES))
			Aadd(_aMsg,"Não localizado codição de pgto "+VS3->VS3_CODTES+" item "+VS3->VS3_CODITE+" para o orçamento "+VS1->VS1_NUMORC+" para a geração do Financeiro")
			Break
		Endif

		SC5->(DbGoto( _nRegSC5))
		SF2->(DbGoto(_nRegSF2))

		_cNumPed := SC5->C5_NUM
		_cPrefNF := &(GetNewPar("MV_1DUPREF","_cSerie"))
		//# Gravacao dos Titulos a receber                                            #

		//Verifica se a fatura é A Vista e se gera financeiro, caso necessário grava os titulos a recebe
		if Alltrim(SE4->E4_TIPO)=="A" .and. SF4->F4_DUPLIC == "S"
			_nParcelas := 0
			//Passar por todos os orçamentos para verificar se possuem titulos ja pagos
			BeginSql Alias _cAliasPesq //Define o nome do alias temporário
			SELECT 	  ISNULL(VS9.R_E_C_N_O_,0) NREGVS9
			FROM %Table:VS9% VS9
			LEFT JOIN %table:VS1% VS1
				ON VS1.%NOTDEL%
				AND VS1.VS1_FILIAL = %xFilial:VS1%
				AND VS1.VS1_NUMORC = VS9.VS9_NUMIDE
			WHERE 	VS9.VS9_FILIAL = %xFilial:VS9% 
				//AND VS9.VS9_NUMIDE = %Exp:_cNumOrc%
				AND VS1.VS1_XPICKI = %Exp:_nPicki%
				AND VS9.%notDel%
			EndSql
				/* Informações VS9
			VS9->VS9_FILIAL := xFilial("VS9")
			VS9->VS9_NUMIDE := VS1->VS1_NUMORC
			VS9->VS9_SEQUEN := STRZERO(1,TamSX3("VS9_SEQUEN")[1]) -> Controle de seq de parcelas
			VS9->VS9_DATPAG := dDataBase -> Data do pagamento
				dDataBase -> Variavel publica que contém a data logada no sistema
			VS9->VS9_VALPAG := _nValDup -> Valor do pagamento
				_nValDup 	+= VS1->VS1_VALDUP - Acredito que seja o valor somado dos itens do orçamento
			VS9->VS9_TIPPAG := _cTipo -> Forma de pagamento para particionar os valores da entrada
				_cTipo := "DP"
			VS9->VS9_ENTRAD := "N" -> Informar se tem entrada

			VS9->VS9_NATURE - Natureza financeira de peças -> Todos os registros vazios no BD.
			VS9->VS9_PORTAD - Código do portador deste título
		*/
			If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGVS9 == 0
				Aadd(_aMsg,"Não localizado Liberação de Pedidos para nota "+_cNota+" série "+_cSerie+" com orçamento "+VS1->VS1_NUMORC+" para a geração do Financeiro")
				Break
			Endif

			VS9->(DbGoto((_cAliasPesq)->NREGVS9))
			SA3->(DBSetOrder(1))
			SA3->(DBSeek(xFilial("SA3")+VS1->VS1_CODVEN))

			_cNatureza := VS9->VS9_NATURE
			//
			if Empty(_cNatureza) .and. !Empty(VS1->VS1_NATURE)
				_cNatureza := VS1->VS1_NATURE
			EndIf
			if Empty(_cNatureza) .and. !Empty(SA1->A1_NATUREZ)
				_cNatureza := SA1->A1_NATUREZ
			EndIf
			If Empty(_cNatureza)
				_cNatureza := _cDupNat
			Endif
			_cCodBco :=  VS9->VS9_PORTAD
			_cTipCob  := if(!Empty(_cCodBco),"1","0") // TODO:
			if Empty(_cCodBco)
				_cCodBco := VS1->VS1_CODBCO
				if Empty(_cCodBco)
					_cCodBco := GetNewPar("MV_BCOCXA","")
				Endif
			Endif
			SA6->(DbSetOrder(1))
			//FG_Seek("SA6","_cCodBco",1,.f.)
			_cNumBord :=""
			_dDatBord := cTod("")

			If SA6->(DbSeek(FWxFilial("SA6")+_cCodBco)) .And. SA6->A6_BORD == "0"
				_cNumBord := "BCO"+SA6->A6_COD
				_dDatBord := dDataBase
			Endif

			_nParcelas ++
			if TamSx3("E1_PARCELA")[1] = 1
				_cParcela := ConvPN2PC(_nParcelas)
			Else
				_cParcela := Soma1( str(_nParcelas-1,TamSx3("E1_PARCELA")[1]) )
			Endif
			/*
				If VS1->(FieldPos("VS1_VLBRNF")) > 0 .and. VS1->VS1_VLBRNF == "0" .and. VS1->(FieldPos("VS1_FPGBAS")) > 0  .and. ;
					!Empty(VS1->VS1_FPGBAS) .and. !_lMultOrc
						nValTit := aParcBRNF[_nPos,2]
				Else
					nValTit := VS9->VS9_VALPAG
				EndIf
			*/
			_nValTit := VS9->VS9_VALPAG

			_aTitulo := {	{"E1_PREFIXO" 	,	_cPrefNF		,Nil},;
				{"E1_NUM"     	,	_cNota 			,Nil},;
				{"E1_PARCELA" 	, _cParcela			,Nil},;
				{"E1_TIPO"    	, VS9->VS9_TIPPAG	,Nil},;
				{"E1_NATUREZ" 	, _cNatureza		,Nil},;
				{"E1_SITUACA" 	, _cTipCob			,Nil},;
				{"E1_CLIENTE" 	, SF2->F2_CLIENTE	,Nil},;
				{"E1_LOJA"    	, SF2->F2_LOJA		,Nil},;
				{"E1_EMISSAO" 	, dDataBase			,Nil},;
				{"E1_VENCTO"  	, VS9->VS9_DATPAG	,Nil},;
				{"E1_VENCREA" 	, DataValida(VS9->VS9_DATPAG)	,Nil},;
				{"E1_VALOR"   	, _nValTit       	,Nil},;
				{"E1_NUMBOR"  	, _cNumBord			,Nil},;
				{"E1_DATABOR" 	, _dDatBord			,Nil},;
				{"E1_PORTADO" 	, _cCodBco			,Nil},;
				{"E1_PREFORI" 	, SF2->F2_PREFORI	,Nil},;
				{"E1_VEND1"   	, SA3->A3_COD		,nil},;
				{"E1_COMIS1"  	, SA3->A3_COMIS		,nil},;
				{"E1_BASCOM1" 	, VS9->VS9_VALPAG	,nil},;
				{"E1_PEDIDO"  	, _cNumPed			,nil},;
				{"E1_NUMNOTA" 	, _cNota			,nil},;
				{"E1_ORIGEM"  	, "MATA460 "		,nil},;
				{"E1_SERIE"   	, _cSerie			,nil} }
			//cMsgErr := OX0040143_LogArrayExecAuto(aTitulo)
			Pergunte("FIN040",.F.)
			_nRecSA1 := SA1->(Recno())//Salva posicao SA1
			//PE para permitir a manipulação do vetor aTitulo
			If ExistBlock("OX004TIT")
				_aTitulo := ExecBlock("OX004TIT",.f.,.f.,{_aTitulo,/**/})
			EndIf

			lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
			lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog

			MSExecAuto({|x| FINA040(x)},_aTitulo)
			SA1->(Dbgoto(_nRecSA1))//Volta posicao SA1
			If lMsErroAuto
				_cErro := "[ ZPEFF036FN] Problemas no execauto FINA040" + CRLF
				// se estiver em debug, pega o log inteiro do erro para uma analise mais detalhada
				_aError := GetAutoGRLog()
				For _nPos := 1 To Len(_aError)
					If !Empty((AllTrim(_aError[_nPos])))
						_cErro	+= 	AllTrim(_aError[_nPos]) + CRLF
					EndIf
				Next _nPos
				Aadd(_aMsg,_cErro)
				Break
			EndIf
		Endif

		// Gravar o F2_VALFAT com a soma de todos os titulos referente a NF //
		SF2->(DbGoto(_nRegSF2))
		SE4->(DbGoto(_nRegSE4))

		SF2->(RecLock("SF2",.f.))
		SF2->F2_DUPL 	:= _cNota
		SF2->F2_VALFAT 	:= FMX_VALFIN( SF2->F2_PREFIXO , SF2->F2_DUPL , SF2->F2_CLIENTE , SF2->F2_LOJA )
		SF2->(MsUnLock())
		_lRet := .T.

	End Sequence
//apagar arquivo temporario
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif
Return _lRet



// #######################################
// # BAIXA AUTOMATICA DO TITULO A VISTA  #
// #######################################
Static Function ZPECF036BX(_cNota, _aMsg)
	Local _lRet 		:= .F.
	Local _cAliasPesq 	:= GetNextAlias()
	Local _aBaixa		:= {}
	Local _aError		:= {}
	Local _cErro		:= ""
	Local _cPrefNF := &(GetNewPar("MV_1DUPREF","_cSerie"))

	Local _nPos

	Begin Sequence
		if AllTrim(GetNewPar("MV_BXPEC","N")) <> "S"
			_lRet := .T.
			Break
		Endif
		//Faz select para verificar se encontra titulos a baixar
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário
		SELECT 	ISNULL(SE1.R_E_C_N_O_,0) NREGSE1
		FROM %Table:SE1% SE1
		WHERE 	SE1.E1_FILIAL 	= %xFilial:SE1% 
			AND SE1.E1_PREFIXO	= %Exp:_cPrefNF%
			AND SE1.E1_NUM		= %Exp:_cNota%
			AND SE1.E1_VENCTO   = %Exp:DtoS(ddatabase)%
			AND SE1.%notDel%
		EndSql
		If (_cAliasPesq)->(Eof())
			_lRet := .T.
			Break
		Endif
		While (_cAliasPesq)->(!Eof())
			SE1->(DbGoto((_cAliasPesq)->NREGSE1))
			_aBaixa  := {;
				{"E1_PREFIXO"  ,SE1->E1_PREFIXO   		,Nil } ,;
				{"E1_NUM"	   ,SE1->E1_NUM        		,Nil } ,;
				{"E1_PARCELA"  ,SE1->E1_PARCELA      	,Nil } ,;
				{"E1_TIPO"	   ,SE1->E1_TIPO      		,Nil } ,;
				{"AUTMOTBX"	   ,"NOR"                  	,Nil } ,;
				{"AUTDTBAIXA"  ,dDataBase              	,Nil } ,;
				{"AUTDTCREDITO",dDataBase              	,Nil } ,;
				{"AUTHIST"	   ,"BAIXA AUTOMATICA"     	,Nil } ,;
				{"AUTVALREC"   ,SE1->E1_VALOR          	,Nil }}
			//PE criado para passagem de parâmetros customizados no ExecAuto do FINA070, seguindo o parâmetro MV_BXPEC
			If ExistBlock("OX004BXF")
				_aBaixa := ExecBlock("OX004BXF", .F., .F., _aBaixa)
			Endif

			lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
			lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog
			MSExecAuto({|x| FINA070(x)}, _aBaixa)
			If lMsErroAuto
				_cErro := "[ ZPEFF036FN] Problemas no execauto FINA070" + CRLF
				// se estiver em debug, pega o log inteiro do erro para uma analise mais detalhada
				_aError := GetAutoGRLog()
				For _nPos := 1 To Len(_aError)
					If !Empty((AllTrim(_aError[_nPos])))
						_cErro	+= 	AllTrim(_aError[_nPos]) + CRLF
					EndIf
				Next _nPos
				_cErro += "Faturamento ja foi realizado, não foi possivel baixar o titulo a vista"
				Aadd(_aMsg,_cErro)
				Break
			EndIf
			(_cAliasPesq)->(DbSkip())
		Enddo
		_lRet := .T.
	End Sequence
	//apagar arquivo temporario
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif
Return _lRet


//Atualizar dados
Static Function ZPECF036AT(_cPedido, _cNota, _cSerie, _cTitulo, _aRegVS1, _aPicking, _aMsg)
	Local _cAliasPesq 	:= GetNextAlias()
	Local _lRet  		:= .T.
	Local _cStatusAnt	:= ""
	Local _cCliente 	:= ""
	Local _cLoja 		:= ""
	Local _nPesoL 		:= 0
	Local _nPesoB 		:= 0
	Local _nPesoS 		:= 0
	Local _nRegSF2      := 0

	Local _cQuery
	Local _nStatus
	Local _cObs
	Local _cPicking
	Local _nPos

	Default _aPicking	:= {}
	Default _aMsg		:= {}

	Begin Sequence
		//Locallizar a nota gerada
		SF2->(dbSetOrder(1))	//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If !(SF2->( dbSeek( xFilial("SF2") + _cNota + _cSerie + _cCliente + _cLoja ) ))
			_cObs := "Problema ocorrido na gravação da Nota Fiscal de Saida "+_cNota +" serie "+ _cSerie+". Nota Fiscal ja cadastrada, mas nao foi gerada Nota Fiscal para o pedido "+_cPedido
			Aadd(_aMsg, _cObs)
			Break
		EndIf
		_nRegSF2 := SF2->(RECNO())

		//Prepara as observações para o processo
		_cObs := "Orçamento Faturado com fatura nr. " +_cNota+ " Serie " +_cSerie+ " em " +DtoC(date()) + " as " + Time() + CRLF
		For _nPos := 1 To Len(_aMsg)
			_cObs += Upper(_aMsg[_nPos]) + CRLF
		Next
		//atualizar orçamento
		For _nPos := 1 To Len(_aRegVS1)
			VS1->(DbGoto(_aRegVS1[_nPos]))
			//Guardo Cliente para poder utilizar
			If Empty(_cCliente)
				_cCliente  	:= VS1->VS1_CLIFAT
				_cLoja		:= VS1->VS1_LOJA
			Endif
			_cStatusAnt 	:= VS1->VS1_STATUS
			RecLock("VS1",.f.)
			VS1->VS1_STATUS := "X"
			VS1->VS1_FORPAG := SC5->C5_CONDPAG  //cTipPag // Gravar o VS1_FORPAG em todos os Orcamentos
			VS1->VS1_CFNF   := "1"  //indica 1=NF  2=Cupon Fiscal
			VS1->VS1_NUMPED := _cPedido
			VS1->VS1_NUMNFI := _cNota
			VS1->VS1_SERNFI := _cSerie
			If VS1->(FieldPos("VS1_STARES")) > 0
				VS1->VS1_STARES := "3"
			Endif
			If VS1->(FieldPos("VS1_GERFIN")) > 0
				VS1->VS1_GERFIN := IIf(!Empty(_cTitulo),"1","0")
			Endif
			//Verificar empresa
			SM0->(dbSetOrder(1))
			If SM0->(dbSeek(cEmpAnt + VS1->VS1_FILIAL))  //FWSM0Util():setSM0PositionBycFilAnt()
				VS1->VS1_XCGCEM := AllTrim(SM0->M0_CGC)
				VS1->VS1_DATALT := Date()
				VS1->VS1_XHRALT := Time()
			EndIf
			If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
				OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , "Alterado Status anterior "+_cStatusAnt ) // Grava Data/Hora na Mudança de Status do Orçamento / Orçamento por Fases
			EndIf
			If FindFunction("FM_GerLog")
				//grava log das alteracoes das fases do orcamento
				FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,_cStatusAnt)
			EndIF

			// Gerar CEV na Finalizacao do Orcamento ( Pos-Venda )
			OX001CEV("F",VS1->VS1_NUMORC,VS1->VS1_TIPORC)

			//Atualizar VS3
			_cObs 	:= "Atualizado status de reserva para 0, faturamento nota fiscal "+_cNota+" serie "+_cSerie
			_cQuery := "UPDATE " +RetSqlName("VS3")+ " VS3" + CRLF
			_cQuery += "SET 	VS3.VS3_RESERV 	= '0' " + CRLF
			_cQuery += " 	,	VS3.VS3_QTDRES 	= '0' " + CRLF
			_cQuery += " 	,	VS3.VS3_OBSAGL 	=  RAWTOHEX('"+Upper(_cObs)+ chr(13) + chr(10) +"' ||  NVL(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(VS3.VS3_OBSAGL , 2000, 1)),' ') )" + CRLF
			_cQuery += "WHERE VS3.D_E_L_E_T_  = ' ' " 				+ CRLF
			_cQuery += " 	AND VS3.VS3_FILIAL = '"+FWxFilial("VS3")+"' "  	+ CRLF
			_cQuery += " 	AND VS3.VS3_NUMORC = '"+VS1->VS1_NUMORC+"' "  	+ CRLF

			_nStatus := TcSqlExec(_cQuery)
			if (_nStatus < 0)
				_cObs += "Não foi possivel atualizar status da Reserva no VS3 - VS3_RESERV" + CRLF
			Endif
			VS1->VS1_OBSAGL		:= Upper(_cObs) + CRLF + AllTrim(VS1->VS1_OBSAGL)
			VS1->(MsUnLock())
			Conout("[ZPECF036] "+ CRLF + _cObs )
		Next _nPos

		//Atualizando Status do Picking caso exista
		_nPesoL := 0
		_nPesoB := 0
		_nPesoS := 0

		For _nPos := 1 To Len(_aPicking)
			_cPicking := _aPicking[_nPos]
			If SZK->(FieldPos("ZK_STATUS")) > 0   //N=Nao Envidado;E=Enviado;F=Faturado;C=Cancelado
				_cQuery := " UPDATE " + RetSqlName("SZK") + " SZK " 		+ CRLF
				_cQuery += " SET 	SZK.ZK_NF = '" 		+ _cNota 	+ "' " 	+ CRLF
				_cQuery += " 	, 	SZK.ZK_SERIE = '" 	+ _cSerie 	+"' " 	+ CRLF
				_cQuery += " 	, 	SZK.ZK_STATUS = 'F' " 					+ CRLF
			Else
				_cQuery := " UPDATE " + RetSqlName("SZK") + " SZK " 		+ CRLF
				_cQuery += " SET 	SZK.ZK_NF ='" 		+ _cNota 	+ "' " 	+ CRLF
				_cQuery += " 	, 	SZK.ZK_SERIE ='" 	+ _cSerie 	+"' " 	+ CRLF
			EndIf
			_cQuery += " WHERE ZK_XPICKI = '"+_cPicking+"' AND ZK_FILIAL='" + xfilial("SZK") + "'"
			_nStatus := TcSqlExec(_cQuery)
			if (_nStatus < 0)
				_cObs += "Não foi possivel atualizar status do Picking "+_cPicking+" para Faturado com a nota "+_cNota+" Serie "+_cSerie+", alterar o dados com ADM SISTEMA"+ CRLF
				Aadd(_aMsg, _cObs)
			Endif

			If Select((_cAliasPesq)) <> 0
				(_cAliasPesq)->(DbCloseArea())
			Endif
			//Pegar a somatoria do peso para atualizar na nota
			BeginSql Alias _cAliasPesq
			SELECT SUM(ZK_PLIQUI) PLIQUI, SUM(ZK_PBRUTO) PBRUTO, SUM(ZK_XPESOC) XPESOC 
       		FROM %table:SZK% SZK
       		WHERE 	SZK.ZK_FILIAL  	= %XFilial:SZK%
				AND SZK.ZK_XPICKI  	= %Exp:_cPicking%
			  	AND SZK.%notDel%		  
			EndSql
			If (_cAliasPesq)->(!Eof())
				_nPesoL += (_cAliasPesq)->PLIQUI
				_nPesoB += (_cAliasPesq)->PBRUTO
				_nPesoS += (_cAliasPesq)->XPESOC
			EndIf
		Next

		//reposiciono na nota
		SF2->(DbGoto(_nRegSF2))
		RecLock("SF2",.F.)
		SF2->F2_PLIQUI := If(_nPesoL > 0, _nPesoL, SF2->F2_PLIQUI)
		SF2->F2_PBRUTO := If(_nPesoB > 0, _nPesoB, SF2->F2_PBRUTO)
		SF2->F2_XPESOC := If(_nPesoS > 0, _nPesoS, SF2->F2_XPESOC)
		SF2->(MsUnlock())

		//--Efetua a gravação dos pesos bruto e cubado na tabela GW8 - GFE
		U_ZGFEF001(	_cNota, _cSerie, _cCliente, _cLoja )
		//--Efetua a gravação do campo GW1_XTPTRA - GFE
		U_ZGFEF003()
		//Gravacao da tabela VEC e VSC
		FM_GVECVSC(SF2->F2_DOC,SF2->F2_SERIE,"VEC")
		_lRet := .T.

	End Sequence

	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif
Return _lRet


/*/{Protheus.doc} ZPECFTONEG
Funcao responsavel por montar as parcelas  no cabecalho do pedido de venda quando utilizada uma condicao de pagamento do tipo '9'
@author Rubens / Manoel
@since 14/10/2016
@version 1.0
@param 
/*/
Static Function ZPECFTONEG(_aCabPV)
	Local _cAliasPesq	:= GetNextAlias()
	Local _aVS9			:= {}
	Local _cParcela		:= ""
	Local _nPos
	Local _nPosSC5
	Local _nPicki 		:= _aCabPV[41][2] //Número do Picking utilizado na query da VS9 - GAP098 

	Begin Sequence
		//If SE4->E4_TIPO == "9" .OR. SE4->E4_TIPO == "A"
		//Caso não esteja contido posso sair do processo
		If AllTrim(SE4->E4_TIPO) $ "9_A"
			Break
		Endif
		BeginSql Alias _cAliasPesq
		SELECT VS9_TIPPAG, VS9_DATPAG , VS9_VALPAG , VS9_TIPPAG 
		FROM %table:VS9% VS9
		LEFT JOIN %table:VS1% VS1
			ON VS1.%NOTDEL%
			AND VS1.VS1_FILIAL = %xFilial:VS1%
			AND VS1.VS1_NUMORC = VS9.VS9_NUMIDE
		WHERE VS9.VS9_FILIAL   = %XFilial:VS9%
			AND VS9.VS9_TIPOPE = ' '
			AND VS1.VS1_XPICKI = %Exp:_nPicki%
			//AND VS9.VS9_NUMIDE = %Exp:VS1->VS1_NUMORC% 
			AND VS9.%notDel%	
		ORDER BY VS9_NUMIDE , VS9_DATPAG , VS9_SEQUEN
		EndSql
		//não tendo dados posso sair
		If (_cAliasPesq)->(Eof())
			Break
		Endif

		_cParcela := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0" // cParcela igual ao MATA410A, funcao A410Tipo9()
		While (_cAliasPesq)->(!Eof())
			_nPos := aScan( _aVS9 ,{ |x| x[1] == (_cAliasPesq)->VS9_DATPAG .and. x[2] == (_cAliasPesq)->VS9_TIPPAG })
			If _nPos == 0
				AADD( _aVS9 , { (_cAliasPesq)->VS9_DATPAG , (_cAliasPesq)->VS9_TIPPAG , "" } )
				_nPos := Len(_aVS9)
				_aVS9[_nPos,3]  := SubStr(_cParcela,_nPos,1)
				aAdd(_aCabPV,{"C5_DATA" + _aVS9[_nPos,3] , StoD((_cAliasPesq)->VS9_DATPAG)  , Nil }) // Data da Parcela
				aAdd(_aCabPV,{"C5_PARC" + _aVS9[_nPos,3] , (_cAliasPesq)->VS9_VALPAG        , Nil }) // Valor da Parcela
			Else
				_nPosSC5 := aScan(_aCabPV,{ |x| x[1] == "C5_PARC" + _aVS9[_nPos,3] })
				_aCabPV[ _nPosSC5 , 2 ] += (_cAliasPesq)->VS9_VALPAG
			EndIf
			(_cAliasPesq)->(dbSkip())
		EndDo
	End Sequence
//
Return Nil



//Enviar e-mail para enviar relativo ao Faturamento
Static Function ZPECF036EM(_aMsg, _cPedido, _aPicking, _cAssunto )
	Local _cAliasPesq	:= GetNextAlias()
	Local _cEmail		:= ""

	Begin Sequence
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário
		SELECT SX5.X5_DESCRI
		FROM %Table:SX5% SX5	
		WHERE SX5.%notDel%
			AND SX5.X5_FILIAL 	= %XFilial:SX5%
			AND	SX5.X5_TABELA   = "2D"
			AND SX5.X5_DESCRI 	<> ' '				
		EndSql
		If (_cAliasPesq)->(Eof())
			Conout("[ZPECF036] - Não cadatrado email SX5 Tabela 2D, referente a problemas ocorridos no recebimento do Picking")
			Break
		Endif
		While (_cAliasPesq)->(!Eof())
			_cEmail += AllTrim((_cAliasPesq)->X5_DESCRI)+","
			(_cAliasPesq)->(DbSkip())
		EndDo
		//Retirar ", do final"
		_cEmail := SubsTr(_cEmail,1,Len(_cEmail)-1)
		ZPECF036EV(_aMsg, _cPedido, _aPicking, _cAssunto, _cEmail, /*_cEMailCopia*/, /*_aAnexos*/,  /*lSchedule*/)
	End Sequence

Return Nil



/*
=====================================================================================
Programa.:              ZPECF036EV
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
Static Function ZPECF036EV(_aMsg, _cPedido, _aPicking, _cAssunto, _cEmails, _cEMailCopia, _aAnexos,  lSchedule)
	Local _cTexto   		:= ""
	Local _cEmailDest 		:= ""
	Local _lMsgOK			:= .T.
	Local _lMsgErro			:= .F.
	Local _cObsMail			:= ""
	Local _cReplyTo			:= ""
	Local _cCorItem			:= "FFFFFF"
	Local _lEnvia			:= .T.
	Local _cLogo  			:= 'https://tinyurl.com/logocaoa'
	Local _cNomeUsu 		:= "RECEBIMENTO RETORNO PICKING RGLOG FATURAMENTO AUTOMATICO[ZPECF036]"  //Upper(FwGetUserName(RetCodUsr())) //Retorna o nome completo do usuário  __cUserId
	Local _cCodUsu			:= "RGLOG_JS" //RetCodUsr()
	Local _cDescricao		:= ""
	Local _cRotina			:= "ZPECF036"
	Local _nPos

	Default _aMsg			:= {}
	Default _cPedido		:= ""
	Default _aPicking		:= {}
	Default _cAssunto		:= "Informacoes Retorno Picking Faturamento Automatico [ZPECF036]"
	Default _cEmails 		:= "evandro.mariano@caoa.com.br"  //E-mail para envio problemas integração
	Default _cEMailCopia	:= ""
	Default _aAnexos		:= {}
	Default _lSchedule   	:= IsBlind()

	Begin Sequence
		_lMsgErro			:= IF( _lSchedule == .F., .T. , .F. )
		If Empty(_cEmails)
			_cTexto := "**** Erros referente ao processo de importação Retorno Picking função [ZPECF036] não possui e-mail cadastrado no SX5 Tabela 2E ****"
			_cTexto += "     Os mesmos serão gravados no log do Sistema conforme informações abaixo"
			Conout(_cTexto)
			For _nPos := 1 To Len(_aMsg)
				Conout( _aMsg[_nPos])
			Next
			Break
		EndIf

		//localizar o produto
		If !Empty(_aPicking)
			_cDescricao := ""
			For _nPos := 1 To Len(_aPicking)
				_cDescricao += _aPicking[_nPos] +"|"
			Next
			_cDescricao := SubsTr(_cDescricao,1,Len(_cDescricao))
		Endif

		_cEmailDest := _cEmails
		_cHtml := ""
		_cHtml += "<html>"+ CRLF
		_cHtml += "	<head>"+ CRLF
		_cHtml += "		<title>Processo de importação Retorno Picking [ZPECF036] Faturamento Automatico Informações/Erros</title>"+ CRLF
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
		_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>Pedido:	</b></font></td>"+ CRLF
		_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>"+ _cPedido +"</font></td>"+ CRLF
		_cHtml += "									</tr>"+ CRLF
		_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>Picking:	</b></font></td>"+ CRLF
		_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>"+_cDescricao+"</font></td>"+ CRLF
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



