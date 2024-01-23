/*/{Protheus.doc} ZPECFUNA
Responsável pelas funções customizadas com utilizades em outros programas
@author DAC - Denilso
@since 20/11/2021
@version 1.0
@return ${return}, ${return_description}
@type user function
@history    
/*/
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "Totvs.ch"
#include "Topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#define CRLF chr(13) + chr(10)
 
Static oZPEC08Peca  := DMS_Peca():New()

/*/{Protheus.doc} XOFUNLIB
Liberar orçamento verifica se esta disponível para separação e grava separação
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		_cNumOrc 	- Numero orçamento 
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 
@menu       Nao Informado
@return		_lRet 		- Verdadeiro ou falso
@history    28/07/2023 GAP002  Integração da separação - Informar produto e quantidade da cubagem
			incluído _lAtualiza para atualização do VS1 em alguns casos não será necessário
/*/
User Function XOFUNLIB( _cNumOrc, _aSeqVS3, _aVS3Reg, _lAtualiza )
	Local _lRet 		:= .T.
	//Local _cNroConf
	Local _cDocto

	Default _lAtualiza	:= .T.

	//Caso não esteja habilitada crio para que possa retornar mesgs
	If Type("_aMensAglu") == "U"
		Private _aMensAglu := {}
	EndIf
	Begin Sequence
		//Não fazer separação quando esta sem limite de crédito 
		If Valtype(_cNumOrc) <> "C" .Or. Empty(_cNumOrc)
			Aadd(_aMensAglu,"Não foi informado o numero do orçamento !")
			_lRet := .F.
			Break
		EndIf
		DBSELECTAREA("VS1")
		Private aHeaderP    	:= {} 							// Variavel ultilizada na OX001RESITE
		Private _aReservaCAOA 	:= {_cNumOrc,.T.,_aVS3Reg}	// Variavel utilizada no PE OX001RES
		_cDocto := VS1->(OX001RESITE(VS1->VS1_NUMORC, .T., _aSeqVS3))
		//Alterado para utilizar reserva CAOA - DAC 16/08/2022
		//_cDocto := U_XRESCAOAPEC(_cNumOrc, .T., _aSeqVS3)
		If _lAtualiza .And. (Empty(_cDocto) .or. _cDocto == "NA")
			Aadd(_aMensAglu,"Não foi possivel fazer reserva os status serão retornados, verificar com ADM SISTEMAS !")
			RecLock('VS1',.F.)
				VS1->VS1_XBO := 'E'
			VS1->(MsUnlock())
			_lRet := .F.
			Break
		EndIf 
		/* Retirado a geração de carregamento será realizada quando do recebimento da funcionalidade DAC 11/07/2022
		_cNroConf 	:= OX0020071_ExisteConferencia( _cNumOrc  ) 
		//utilizado desta forma pois no padrão não esta atualizando o campo que identifica a reserva no VS1 e VS3 neste momento rodando a onda não foi realizado o picking ajustado DAC - 19/05/2022
		//ja existe o numero de conferencia
		If !Empty(_cNroConf) .and. !Empty(VS1->VS1_XPICKI) 
			Aadd(_aMensAglu,"Ocamento ja possui numeração de conferência "+_cNroConf+" !")
			_lRet := .F.
			Break
		EndIf
		_cNroConf := OX0020041_GravaRegistroConferencia( _cNumOrc )
		If Empty(_cNroConf)
			Aadd(_aMensAglu,"Não foi possivel gravar conferência, ocorreu erro !")
			_lRet := .F.
			Break
		EndIf

		If FindFunction("FM_GerLog")
			//grava log das alteracoes das fases do orcamento
			FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,VS1->VS1_STATUS)
		EndIf
		*/
		Aadd(_aMensAglu,"Orçamento em separação e liberado docto. reserva "+_cDocto+" !")

	End Sequence
Return _lRet		


/*/{Protheus.doc} XOFUNCLO
Clonar um orçamento
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		_cNumOrc 	- Numero orçamento 
			_cGrupo		- Grupo de Produto
			_cCodProd 	- Código do produto
			_nQtdeItem  - Qtde que deseja clonar do produto
			_lZera      - Zerar item original que foi clonado
			_aVazioCpo  - Campos que deverão estar vazio ex {"VS1_XAGLUT","VS1_XUSUAGL","VS1_XDTAGLU"}
			_aBackOrder  - Matriz com numero de registro do VS3 para gerar BackOrder
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 
@menu       Nao Informado
@return		_lRet 		- Verdadeiro ou falso
@history    

/*/
//Clonar um orçamento
User Function XOFUNCLO( _cNumOrc, _cGrupo, _cCodProd, _nQtdeItem, _lZera, _aCpoVazio, _aBackOrder, _cNumOrcNovo )
	Local _lRet 		:= .T.
	Local _nRegVS1		:= VS1->(Recno())
	Local _cObs			:=	""
	Local _lXBO 		:= .F.
	Local _lApagaIT		:= .F.		
	Local _aObs			:= {}
	Local _cOrcNovo	
	Local _nPos
	Local _cOrcConf
	Local _aOrc

	Default _cGrupo		:= ""
	Default _cCodProd	:= ""
	Default _nQtdeItem 	:= 0
	Default _nSaldoSB2 	:= 0
	Default _lZera		:= .F.  //indica se após a clonagem zera os itens do orçamento original
	Default _aBackOrder := {}
	//Campos que deverão estar vazios ou zerados após a cópia
	Default _aCpoVazio	:= {"VS1_OBSAGL",;
							"VS1_XPICKI",;
							"VS1_XUSUPI",;
							"VS1_XUSIMP",;
							"VS1_XINTEG",;
							"VS1_XDTEPI",;
							"VS1_XUSUPI",;
							"VS1_NUMNFI",;
							"VS1_SERNFI",;
							"VS3_XTPSUB",;
							"VS3_XDTSUB",;
							"VS3_XHRSUB",;
							"VS3_XPICKI",;
							"VS3_XQTDIT",;
							"VS3_DOCSDB";
							}	

	//						"VS3_XITSUB",;

	Begin Sequence
		//ja tem que estar posicionado no orçamento
		If AllTrim(_cNumOrc) <> AllTrim(VS1->VS1_NUMORC)
			VS1->(DbSetOrder(1)) 
			If !VS1->(MsSeek(XFilial("VS1")+_cNumOrc))
				Aadd(_aObs, "NÃO LOCALIZADO O ORÇAMENTO "+_cNumOrc+" PARA CLONAR !")
				_lRet := .F.
				Break
			EndIf
		EndIf	
		//Implementado controle de numeração para não deixar duplicar DAC 15/07/2022
		//caso volte a mesma numeração esta correto caso seja diferente é que a sequencia é maior
		_cOrcNovo 		:= VS1->(GetSXENum("VS1","VS1_NUMORC"))
		_cOrcConf		:= U_XVERNUMeracao("VS1", "VS1_NUMORC", _cOrcNovo )
		If AllTrim(_cOrcNovo) <> AllTrim(_cOrcConf)
			Aadd(_aObs, "ATENCAO [XOFUNCLO]")
			Aadd(_aObs, "- NUMERACAO AUTOMATICA DO ORÇAMENTO "  +_cOrcNovo+" ESTA APRESENTANDO PROBLEMAS  !")
			Aadd(_aObs, "- ASSUMIDO NUMERACAO PARA O ORÇAMENTO "+_cOrcConf+" AJUSTAR NUMERACAO AUTOMATICA !")
			_cOrcNovo := _cOrcConf
		Endif
		_cNumOrcNovo	:= _cOrcNovo  //para retornar o numero novo do orçamento
		//para controlar o conteudo da variavel
		If Type("_cAglutina") == "U"
			If FWIsInCallStack("U_ZPECF008") //Validar origem pois esta função pode ser utilizada para clonar com outras chamadas DAC 25/04/2022
				_lRet := .F.
				Aadd(_aObs, "Numero da Onda não informado verificar com ADM Sistema !")
				Break
			Else
				Private _cAglutina := ""
			EndIf	
		EndIf
		If ValType(_cNumOrc) == "C"
			If AllTrim(_cNumOrc) <> AllTrim(VS1->VS1_NUMORC) 
				VS1->(DbSetOrder(1))
				If !VS1->(MsSeek(XFilial("VS1")+_cNumOrc))
					Aadd(_aObs, "NÃO LOCALIZADO O ORÇAMENTO "+_cNumOrc+" PARA CLONAR !")
					_lRet := .F.
					Break
				EndIf
				_nRegVS1	:= VS1->(Recno())
			Endif	
			//caso tenha um orçamento e o numero de aglutinação estiver vazio carregar do orçamento
			If Empty(_cAglutina) .and. !Empty(VS1->VS1_XAGLU)
				_cAglutina := VS1->VS1_XAGLU
			EndIf	
		Else
			Aadd(_aObs, "NUMERO DE ORÇAMENTO NÃO INFORMADO PARA CLONAR !")
			_lRet := .F.
			Break
		EndIf	

		//somente registros BackOrder
		If Len(_aBackOrder) > 0
			_aOrc := XAVLBACKOrder(_aBackOrder, _cNumOrc,  _cAglutina, _cOrcNovo, @_aObs )
		//Avalia VS3 e retorno o registro _cCodProd
		Else
			_aOrc := XAVLITVS3Clonar(_cNumOrc, _cGrupo, _cCodProd, _cOrcNovo, _lXBO, _lApagaIT)
		EndIf
		If Len(_aOrc) == 0
			Aadd(_aObs, "NÃO LOCALIZADO O ORÇAMENTO "+_cNumOrc+" PARA CLONAR !")
			_lRet := .F.
			Break
		Endif
		//Ajustado para chamar carga do VS3
		_lRet := U_XCLONEOR( _aOrc, _aCpoVazio, _lXBO, _lApagaIT, /*_aObs*/)	
	End Sequence
	VS1->(DbGoto(_nRegVS1))
	If !_lRet .and. Len(_aObs) > 0
		VS1->(RecLock("VS1",.F.))
		_cObs 	:= "*** PROBLEMAS NA CLONAGEM DE ORÇAMENTO "+_cNumOrc+If( Type("_cAglutina") == "C" .and. !Empty(_cAglutina)," REFERENTE AO PROCESSO AGLUTINAÇÃO NR. "+_cAglutina,"") + CRLF
		For _nPos := 1 To Len(_aObs)
			_cObs += Upper(_aObs[_nPos])+ CRLF
		Next
		VS1->VS1_OBSAGL := Upper(_cObs) + CRLF + VS1->VS1_OBSAGL
		VS1->(MsUnlock())
	EndIf

Return _lRet


/*/{Protheus.doc} XAVLBACKOrder
Preparar itens do orçamento que esta em BackOrder
@author 	DAC-Denilso
@since 		27/07/2022
@version 	undefined
@param 		_aBackOrder  - Matriz com numero de registro do VS3 para gerar BackOrder
			_cNumOrc 	- Numero orçamento 
			_cAglutina	- Onda
			_cOrcNovo 	- Numero novo orçamento 
			_aObs		= Observações no processo de separação
@project    PEC007
@type 		user function
@obs 		Revitalizado processo para gerar backorder de KIT e outros
@menu       Nao Informado
@return		_aOrc 		- itens do orçamento preparados para clonagem
@history    
/*/

/* visão abakcorder
Aadd(_aBackOrder,{(_cAliasPesq)->NREGVS3, 
					_cCodProd, 
					(_cAliasPesq)->QTDE_TOTAL, 
					_aMensAglu[Len(_aMensAglu)],
					.T. _lXBO,
					 .T. _lZera,
					 })
*/
Static Function XAVLBACKOrder(_aBackOrder, _cNumOrc,  _cAglutina, _cOrcNovo, _aObs )
	Local _lApagaIT := .F.
	Local _aObsVS3	:= {}
	Local _aOrc		:= {}
	Local _aItem 	:= {}
	Local _nQtdeItem
	Local _nPos
	Local _lXBO		:= .F.
	Begin Sequence
		For _nPos := 1 To Len(_aBackOrder) 
			_aItem := {}
			VS3->(DbGoto(_aBackOrder[_nPos,1]))  //a primeira posição tem que ser o numero do registro do VS3
			If VS3->(Recno()) <> _aBackOrder[_nPos,1]
				AAdd(_aObs, "Problemas na localização registro para clonagem ref Backorder, comunicar ADM Sistemas")
				_lRet := .F.
				Break
			Endif
			_lXBO 		:= .T.  //se tem backorder ja deixo omo default .T.
			_nQtdeItem 	:= _aBackOrder[_nPos,3]
			If !Empty(_aBackOrder[_nPos,4])
				Aadd( _aObsVS3, Upper(AllTrim(_aBackOrder[_nPos,4])))
			Endif	 
			//Aadd( _aObsVS3, "ORÇAMENTO DE ORIGEM "+ AllTrim(VS3->VS3_NUMORC)+" CLONADO ")
			//incluindo validação para indicar XBO quando backorder DAC 27/04/2022
			//Quando informação de backorder for maior que 4 indica que não deve ser informado como XBO = "S"
			If Len(_aBackOrder[_nPos]) > 4 .and. Valtype(_aBackOrder[_nPos,5]) == "L"  .and. !_aBackOrder[_nPos,5]
				_lXBO := .F.
			Else
				_lXBO := .T.
			Endif
			//caso necessite zerar processo (apagar o item), validar se será executado
			//Verificar somente quando enviar falso
			If Len(_aBackOrder[_nPos]) > 5 .and. Valtype(_aBackOrder[_nPos,6]) == "L"  .and. _aBackOrder[_nPos,6]
				_lApagaIT := .T.
			Else
				_lApagaIT := .F.
			EndIf
			Aadd(_aItem,{ "VS1_CLIFAT"	, VS1->VS1_CLIFAT})
			Aadd(_aItem,{ "VS1_LOJA"	, VS1->VS1_LOJA})
			Aadd(_aItem,{ "VS1_NUMORC"	,_cNumOrc})
			Aadd(_aItem,{ "NUMORCNOVO"	,_cOrcNovo}) 
			Aadd(_aItem,{ "VS1_XAGLU"	,_cAglutina})
			Aadd(_aItem,{ "VS3_GRUITE"	, VS3->VS3_GRUITE}) 
			Aadd(_aItem,{ "VS3_CODITE"	, VS3->VS3_CODITE}) 
			Aadd(_aItem,{ "VS3_QTDITE"	, _nQtdeItem}) 
			Aadd(_aItem,{ "VS3_PERDES"	, VS3->VS3_PERDES}) 
			Aadd(_aItem,{ "VS3_OPER"	, VS3->VS3_OPER}) 
			Aadd(_aItem,{ "VS3_CODTES"	, VS3->VS3_CODTES})
			Aadd(_aItem,{ "VS1_XTPPED"	, VS1->VS1_XTPPED})
			Aadd(_aItem,{ "VS3_XOBSAGL"	, _aObsVS3})
			Aadd(_aItem,{ "LXBO"		, _lXBO})
			Aadd(_aItem,{ "LAPAGAIT"	, _lApagaIT})
			Aadd(_aItem,{ "LBAKORDER"	, .T.})
			Aadd(_aItem,{ "NREGVS3"		, VS3->(Recno()) })
			Aadd(_aItem,{ "NREGVS1"		, VS1->(Recno()) })

			Aadd(_aOrc, _aItem)
		Next	
	End Sequence
Return _aOrc


/*/{Protheus.doc} XAVLITVS3Clonar
Funcionalidade responsavel por pegar itens para clonagem
@author 	DAC-Denilso
@since 		27/07/2022
@version 	undefined
@param 		_cNumOrc 	- Numero orçamento 
			_cGrupo		- Grupo item orçamento
			_cCodProd 	- Código Produto item orçamento 
			_lXBO		= Indica Se é BO ou não
			_lApagaIT	- Indica se apaga item após a clonagem
@project    PEC007
@type 		user function
@obs 		Revitalizado processo para gerar backorder de KIT e outros
@menu       Nao Informado
@return		_aOrc 		- itens do orçamento preparados para clonagem
@history    
/*/

Static Function XAVLITVS3Clonar(_cNumOrc, _cGrupo, _cCodProd, _cOrcNovo, _lXBO, _lApagaIT)
	Local _aObsVS3	:= {}
	Local _aItem	:= {}
	Local _aOrc		:= {}
	Local _nQtdeItem
	Begin Sequence
		VS3->(DbSetOrder(1))
		VS3->(DbGoTop())
		VS3->(MsSeek(XFilial("VS3")+_cNumOrc))
		While VS3->(!Eof()) .and. VS3->VS3_FILIAL == XFilial("VS3") .and. VS3->VS3_NUMORC == _cNumOrc
			_aItem := {}
			//Caso tenha sido informado o produto validar
			If !Empty(_cCodProd) .and. AllTrim(VS3->VS3_CODITE) <> AllTrim(_cCodProd) 
				VS3->(DbSkip())
				Loop
			Endif
			If !Empty(_cGrupo) .and. AllTrim(VS3->VS3_GRUITE) <> AllTrim(_cGrupo) 
				VS3->(DbSkip())
				Loop
			Endif
			_nQtdeItem := VS3->VS3_QTDITE
			Aadd(_aItem,{ "VS1_CLIFAT"	, VS1->VS1_CLIFAT})
			Aadd(_aItem,{ "VS1_LOJA"	, VS1->VS1_LOJA})
			Aadd(_aItem,{ "VS1_NUMORC"	,_cNumOrc})
			Aadd(_aItem,{ "NUMORCNOVO"	,_cOrcNovo}) 
			Aadd(_aItem,{ "VS1_XAGLU"	,_cAglutina})
			Aadd(_aItem,{ "VS3_GRUITE"	, VS3->VS3_GRUITE}) 
			Aadd(_aItem,{ "VS3_CODITE"	, VS3->VS3_CODITE}) 
			Aadd(_aItem,{ "VS3_QTDITE"	, _nQtdeItem}) 
			Aadd(_aItem,{ "VS3_PERDES"	, VS3->VS3_PERDES}) 
			Aadd(_aItem,{ "VS3_OPER"	, VS3->VS3_OPER}) 
			Aadd(_aItem,{ "VS3_CODTES"	, VS3->VS3_CODTES})
			Aadd(_aItem,{ "VS1_XTPPED"	, VS1->VS1_XTPPED})
			Aadd(_aItem,{ "VS3_XOBSAGL"	, _aObsVS3})
			Aadd(_aItem,{ "LXBO"		, _lXBO})
			Aadd(_aItem,{ "LAPAGAIT"	, _lApagaIT})
			Aadd(_aItem,{ "NREGVS3"		, VS3->(Recno()) })
			Aadd(_aItem,{ "NREGVS1"		, VS1->(Recno()) })

			Aadd(_aOrc, _aItem)
			VS3->(DbSkip())
		EndDo	
	End Sequence
Return _aOrc


/*/{Protheus.doc} XCLONEOR
Funcionalidade responsavel clonar (copiar) dados preparados do VS1 e VS3 de acordo com as informações em _aOrc
@author 	DAC-Denilso
@since 		27/07/2022
@version 	undefined
@param 		_cNumOrc 	- Numero orçamento 
			_cGrupo		- Grupo item orçamento
			_cCodProd 	- Código Produto item orçamento 
			_lXBO		= Indica Se é BO ou não
			_lApagaIT	- Indica se apaga item após a clonagem
@project    PEC007
@type 		user function
@obs 		Revitalizado processo para gerar backorder de KIT e outros
@menu       Nao Informado
@return		_lRet 		- Lógico
@history    
/*/
User Function XCLONEOR( _aOrc, _aCpoVazio, _lXBO, _lApagaIT, _aObs) 
	Local _lRet 		:= .T.
	Local _lBackOrder	:= .F.
	Local _lMsg			:= .F.
	Local _cReserva 	:= "0"	//0=Nao;1=Sim  
	Local _cStAres 		:= "3"  //1=Reservado;2=Parcialmente Reservado;3=Nao Reservado  
	Local _cStatus		:= "0"
	Local _cNumSeq		:= StrZero(0,Len(VS3->VS3_SEQUEN))
	Local _aEstruVS3 	:= VS3->(DbStruct())
	Local _aEstruVS1 	:= VS1->(DbStruct())
	Local _cNumOrc		:= VS1->VS1_NUMORC
	Local _cAglutina	:= VS1->VS1_XAGLU	
	Local _cCliente		:= VS1->VS1_CLIFAT
	Local _cLoja		:= VS1->VS1_LOJA
	Local _cTipoPed		:= VS1->VS1_XTPPED
	Local _nRegVS1Pos	:= VS1->(RECNO())
	Local _cOrcNovo		:= ""
	Local _cObsGrv		:= ""
	Local _cCodItem		:= ""
	Local _cGrupoItem	:= ""
	Local _cOper		:= ""
	Local _nValorUnit	:= 0	
	Local _nQtdeProd	:= 0
	Local _nTotal		:= 0
	Local _cCodTes		:= ""
	Local _xValor		:= 0
	Local _nQtdeItem	:= 0
	Local _nPerdes		:= 0
	Local _nRegVS1		:= 0
	Local _nRegVS3		:= 0
	Local _aRegVS3Del	:= {}
	Local _aObrigatorio	:= {}
	Local _aItem		:= {}
	Local _aVS3			:= {}
	Local _aVS1 		:= {}
	Local _aObsVS3		:= {}
	Local _cFilTransf	:= SuperGetMV( "CMV_PEC030"  ,,"" )
	Local _cFilAtual	:= cFilAnt

	Local _nCount
	Local _nPos
	Local _cObs
	Local _cCampo
	Local _nPosCpo
	Local lWait 		:= .T.

	Default _lXBO		:= .F.
	Default _lApagaIT	:= .F.
	Default _aObs		:= {}
	Default _aCpoVazio	:= {"VS1_OBSAGL",;
							"VS1_XPICKI",;
							"VS1_XUSUPI",;
							"VS1_XUSIMP",;
							"VS1_XINTEG",;
							"VS1_XDTEPI",;
							"VS1_XUSUPI",;
							"VS1_NUMNFI",;
							"VS1_SERNFI",;
							"VS3_XTPSUB",;
							"VS3_XDTSUB",;
							"VS3_XHRSUB",;
							"VS3_XPICKI",;
							"VS3_XQTDIT",;
							"VS3_DOCSDB";
							}	

	Begin Sequence
		_aObrigatorio := XCLONAOBRigatorio(_aOrc )
		If Len(_aObrigatorio) > 0
			For _nPos  := 1 To Len(_aObrigatorio)
				AAdd(_aObs, _aObrigatorio[_nPos] )
			Next
			_lRet := .F. 
			Break
		Endif
		For _nCount := 1 To Len(_aOrc)
			_aObsVS3 := Aclone({})
			//Guardo estas informações somente uma vez
			If _nCount == 1
				_cCliente 	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "VS1_CLIFAT"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _cCliente	)
				_cLoja 		:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "VS1_LOJA"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _cLoja		)
				_cNumOrc 	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "VS1_NUMORC"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _cNumOrc	)
				_cOrcNovo 	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "NUMORCNOVO"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _cOrcNovo 	)
				_cAglutina 	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "VS1_XAGLU"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _cAglutina 	)
				_cTipoPed	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "VS1_XTPPED"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _cTipoPed	)
				_lXBO		:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "LXBO"})) 		> 0, _aOrc[_nCount,_nPosCPo,2], _lXBO		)
				_lBackOrder	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "LBAKORDER"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _lBackOrder	)
				_cStatus 	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "VS1_STATUS"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _cStatus 	)
			EndIf
			_cGrupoItem	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "VS3_GRUITE"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _cGrupoItem	)
			_cCodItem	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "VS3_CODITE"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _cCodItem	)
			_nQtdeItem	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "VS3_QTDITE"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _nQtdeItem	)
			_nPerdes	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "VS3_PERDES"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _nPerdes	)
			_cOper		:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "VS3_OPER"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _cOper		)
			_cCodTes	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "VS3_CODTES"})) 	> 0, _aOrc[_nCount,_nPosCPo,2], _cCodTes	)
			_lApagaIT	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "LAPAGAIT"}))		> 0, _aOrc[_nCount,_nPosCPo,2], _lApagaIT	)
			_aObsVS3	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "VS3_XOBSAGL"}))	> 0, _aOrc[_nCount,_nPosCPo,2], _aObsVS3	)
			_nRegVS3	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "NREGVS3"})) 		> 0, _aOrc[_nCount,_nPosCPo,2], _nRegVS3	)
			_nRegVS1	:= If((_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == "NREGVS1"})) 		> 0, _aOrc[_nCount,_nPosCPo,2], _nRegVS1	)
			//se informado reposicionar registros
			If _nRegVS1 > 0
				VS1->(DbGoto(_nRegVS1))
			ElseIf VS1->(Eof())  //Valida se etiver no final de arquivo não tratara abortar, tem que estar posicionado no orçamento original pelo menos
				Aadd(_aObs, "Não informado o orçamento para clonagem  entrar em contato ADM Sistemas !")
				_lRet := .F.
				Break
			Endif
			//Verifica se Esta posicionado no orçamento original
			If !Empty(_cNumOrc) .and. VS1->VS1_NUMORC <> _cNumOrc
				VS1->(DbSetOrder(1))
				If !VS1->(DbSeek(XFILIAL("VS1")+_cNumOrc))
					Aadd(_aObs, "Não Localizado o orçamento "+_cNumOrc+" para clonagem  entrar em contato ADM Sistemas !")
					_lRet := .F.
					Break
				Endif
				_nRegVS1 := VS1->(Recno())
			ElseIf Empty(_cNumOrc) 		
				Aadd(_aObs, "Não informado o orçamento "+_cNumOrc+" para clonagem  entrar em contato ADM Sistemas !")
				_lRet := .F.
				Break
			Endif
			If _nRegVS1 == 0
				Aadd(_aObs, "Não localizado registro do orçamento "+_cNumOrc+" para clonagem  entrar em contato ADM Sistemas !")
				_lRet := .F.
				Break
			Endif	
			If _nRegVS3 > 0
				VS3->(DbGoto(_nRegVS3))
			Endif
			//se estiver diferente tento reposicionar, não teste codigo e grupo pois são obrigatórios não sendo necessário validar
			If _nRegVS3 <> VS3->(Recno()) .and.  AllTrim(VS3->VS3_CODITE) <> AllTrim(_cCodItem) .and.;
				AllTrim(VS3->VS3_GRUITE) <> AllTrim(_cGrupoItem)
				VS3->(DbSetOrder(2)) //VS3_FILIAL+VS3_NUMORC+VS3_GRUITE+VS3_CODITE+VS3_SEQUEN
				If !VS3->(DbSeek(XFilial("VS3")+_cNumOrc+_cGrupoItem+_cCodItem))                                                                                                          
					Aadd(_aObs, "Não Localizado item "+_cGrupoItem+"-"+AllTrim(_cCodItem)+" do orçamento "+_cNumOrc+" para clonagem  entrar em contato ADM Sistemas !")
					_lRet := .F.
					Break
				Endif	
				_nRegVS3 := VS3->(Recno())
			Endif
			If _nRegVS3 == 0
				Aadd(_aObs, "Não Localizado tegistro do item "+_cGrupoItem+"-"+AllTrim(_cCodItem)+" do orçamento "+_cNumOrc+" para clonagem  entrar em contato ADM Sistemas !")
				_lRet := .F.
				Break
			Endif	
			//totalizo pois necessitarei fazer algumas contas
			If _nQtdeItem <= 0
				Aadd(_aObs, "Qtde de item "+AllTrim(_cCodItem)+" esta zerada e ou menor que zero !")
				_lRet := .F.
				Break
			Endif
			_nQtdeProd	:= _nQtdeItem
			//CONFORME ALINHADO COM ZÉ SERA UTILIZADO PARA VALOR UNITARIO O DA TABELA DA1
			_nValorUnit	:= U_XOFUNVTB( _cCliente, _cLoja, _cCodItem /*VS3->VS3_CODITE*/)
			//Caso não encontre tabela aborto processo
			If _nValorUnit <= 0
				Aadd(_aObsVS3,"Não encontrado tabela de preço para o item " +AllTrim(_cCodItem)+ " para efetuar clonagem do item orçamento, valor ficara zerado "+CRLF)
				_nValorUnit := 0 //VS3->VS3_VALPEC
			EndIf
			If _nValorUnit > 0 .and. _nQtdeProd > 0
				_nTotal 	:= _nQtdeProd * _nValorUnit
			Else
				_nTotal		:= 0
			Endif	
			//para garantir que seja passado somente de um orçamento (ainda não esta para multiplos orçamentos)
			If VS3->VS3_NUMORC <> _cNumOrc
				Aadd(_aObs, "Orçamento para o item "+AllTrim(_cCodItem)+" esta com numeração diferente, orçamento inicial "+_cNumOrc+" orçamento item "+VS3->VS3_NUMORC+" !")
				_lRet := .F.
				Break
			EndIf
			If _lApagaIT 
				Aadd(_aRegVS3Del,VS3->(Recno()))
			Endif
			//caso não esteja informado o novo orçamento
			If Empty(_cOrcNovo)	
				_cOrcNovo 		:= VS1->(GetSXENum("VS1","VS1_NUMORC"))
			Endif
			//observações que podem ter sido mandadas para os itens
			_cNumSeq 	:= Soma1(_cNumSeq)
			_aItem 		:= {}
			For _nPos := 1 To Len(_aEstruVS3)
				_cCampo :=  AllTrim(_aEstruVS3[_nPos,1])
				//caso não localizou o campo foi enciado campo novo	
				If _cCampo $ "VS3_NUMORC"
					_xValor := _cOrcNovo
				ElseIf _cCampo $ "VS3_LOCAL"
					(_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == _cCampo}))
					If _nPosCPo > 0
						_xValor := _aOrc[_nCount,_nPosCPo,2]
					Else
						_xValor	:= VS3->(FieldGet(FieldPos(_aEstruVS3[_nPos,1])))			
					Endif	
					//DAC 07/03/2023
					//Conforme alinhado com Zé quando BO o armazém tem que ser 01
					//No processo da onda no armazém 11 esta gerando BO com local 11 
					//Nicolas 10/01/2024 
					//Conforme alinhado com Juarez o armazém do BO deve ser conforme o orçamento original.
					//If _lXBO .And. AllTrim(_xValor) <> "01"
					//	_xValor := "01"
					//Endif
				ElseIf _cCampo $ "VS3_OPER"  
					If Empty(_cOper)
						_xValor := U_zTpOper( _cCliente, _cLoja, _cTipoPed )	
					Else
						_xValor := _cOper
					Endif	
				ElseIf _cCampo $ "VS3_GRUITE" 
					_xValor := _cGrupoItem
				ElseIf _cCampo $ "VS3_CODITE" 
					_xValor := _cCodItem
				ElseIf _nQtdeProd > 0 .And. _cCampo $ "VS3_QTDITE"   //| VS3_QTDPED | VS3_QTDINI"
					_xValor := _nQtdeProd
				ElseIf _cCampo $ "VS3_SEQUEN"
					_xValor := _cNumSeq
				ElseIf _cCampo $ "VS3_VALPEC"
					_xValor := _nValorUnit 
				ElseIf _cCampo $ "VS3_VALTOT"
					//_xValor := _nQtdePrd * _nValorUnit
					If _nPerdes > 0
						_xValor := _nTotal - Round((_nTotal * _nPerdes / 100),2)
					Else
						_xValor := _nTotal 
					EndIf	
				ElseIf _cCampo $ "VS3_VALDES" .And. _nPerdes > 0 
					_xValor := Round((_nTotal * _nPerdes / 100),2)
				ElseIf _cCampo $ "VS3_CODTES"  
					//_xValor	:= _cCodTes   //VS3->(FieldGet(FieldPos(_aEstruVS3[_nPos,1])))
					//Conforme alinhado com J.C. tera que recalcular devido PEs que podem alterar DAC 11/08/2022
					//If Empty(_xValor)
					_cCodTes 	:= MaTesInt(2,_cOper, _cCliente, _cLoja,"C",_cCodItem,/*"VS3_CODTES"*/)
					If Empty(_cCodTes) .and. !Empty(VS3->VS3_CODTES)
						_cCodTes := VS3->VS3_CODTES
						Aadd(_aObsVS3,"Não encontrado TES para o item " +AllTrim(_cCodItem)+ " para efetuar clonagem do item orçamento, assumido a TES de Origem "+CRLF)
					Endif
					_xValor := _cCodTes
					//EndIf	
				ElseIf _cCampo $ "VS3_XDESMB" 
					_xValor	:= VS3->(FieldGet(FieldPos(_aEstruVS3[_nPos,1])))
					If Empty(_xValor)
						_xValor	:= _cNumOrc
					EndIf	
				ElseIf _cCampo $ "VS3_OBSAGL"
					_cObsGrv	:= "REFERENTE AO PROCESSO AGLUTINAÇÃO NR. "+_cAglutina + CRLF
					_cObsGrv	+= "REF. FILIAL/ORCAMENTO CLONADO " +cFilant+"/"+_cNumOrc+ " item " +AllTrim(_cCodItem)+ " em " +DtoC(Date())+" "+Time()+ CRLF
					If Len(_aObsVS3) > 0
						For _nPosCpo := 1 To Len(_aObsVS3)
							_cObsGrv += Upper(_aObsVS3[_nPosCpo]) +CRLF
						Next _nPosCpo
					EndIf
					Aadd(_aObs, _cObsGrv)
					_xValor := AllTrim(VS3->VS3_OBSAGL)+CRLF+_cObsGrv	
				ElseIf _cCampo $ "VS3_XAGLU" 
					_xValor	:= _cAglutina
				ElseIf _cCampo $ "VS3_XDTAGL" 
					If !Empty(_cAglutina)
						_xValor	:= Date()
					Else
						_xValor	:= CtoD(Space(08))
					EndIf	
				ElseIf _cCampo $ "VS3_XHSAGL" 
					If !Empty(_cAglutina)
						_xValor	:= Time()
					Else
						_xValor	:= Space(05)
					EndIf	
				ElseIf _cCampo $ "VS3_XUSUGL" 
					If !Empty(_cAglutina)
						_xValor	:= RetCodUsr()
					Else
						_xValor	:= Space(10)
					EndIf	
				ElseIf _cCampo $ "VS3_RESERV" 
					_xValor	:= _cReserva
				ElseIf _cCampo $ "VS3_XITSUB" 
					(_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == _cCampo}))
					If _nPosCPo > 0
						_xValor := _aOrc[_nCount,_nPosCPo,2]
					Else
						_xValor	:= VS3->(FieldGet(FieldPos(_aEstruVS3[_nPos,1])))			
					Endif	
					If Empty(_xValor)
						_xValor := VS3->VS3_CODITE
					EndIf
				//Caso tenha sido mandado registro que não esteja contemplado acima	
				ElseIf (_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == _cCampo})) 	> 0	
					_xValor := _aOrc[_nCount,_nPosCPo,2]
				ElseIf Len(_aCpoVazio) > 0 .And. Ascan(_aCpoVazio, AllTrim(_aEstruVS3[_nPos,1])) > 0 //Caso seja vazio 
					If _aEstruVS3[_nPos,2] == "N"
						_xValor := 0
					ElseIf _aEstruVS3[_nPos,2] == "D"
						_xValor := CtoD(Space(08))
					ElseIf _aEstruVS3[_nPos,2] == "C"  
						_xValor := ""
					EndIf
				Else	//a importancia de estar posicionado no registro original VS3 é que se não tratado na função ira gravar o que esta no registro original
					_xValor	:= VS3->(FieldGet(FieldPos(_aEstruVS3[_nPos,1])))
				EndIf	
				Aadd(_aItem, _xValor )
			Next _nPos
			Aadd( _aVS3,_aItem)  
			//Gravar no Produto principal o numero do desmembramento conforme solicitação ZR
			If Empty(VS3->VS3_XDESMB)	
				VS3->(RecLock("VS3",.F.))
				VS3->VS3_XDESMB := _cNumOrc
				VS3->(MsUnlock())
			Endif	
		Next _nCount
		If Len(_aVS3) == 0
			Aadd(_aObs, "Não carregado campos relativo aos itens para o orçamento "+_cNumOrc+" para efetuar clonagem,  entrar em contato ADM Sistemas !")
			_lRet := .F.
			Break
		Endif

		//Preparar VS1
		_cObs := ""	
		For _nPos := 1 To Len(_aObs)
			_cObs += Upper( _aObs[_nPos] ) //+ CRLF
		Next
		//Volto _nCount para 1 ter as informações principais
		_nCount  := 1
		For _nPos := 1 To Len(_aEstruVS1)
			_cCampo :=  AllTrim(_aEstruVS1[_nPos,1])
			If _cCampo $ "VS1_NUMORC"
				_xValor := _cOrcNovo
			ElseIf _cCampo $ "VS1_OBSAGL"
				_xValor := _cObs
			ElseIf _cCampo $ "VS1_STATUS" 
				_xValor := _cStatus
			//Caso tenha sido enviado para a geração do backorder atualizar o campo XBO	com indicação de Sim (S)
			ElseIf _cCampo $ "VS1_XBO" .and.  _lXBO //Len(_aBackOrder) > 0
				_xValor := "S" 
			ElseIf _cCampo $ "VS1_XBO" .and.  !_lXBO //Len(_aBackOrder) == 0
				_xValor := "N" 
			ElseIf _cCampo $ "VS1_XDESMB"    
				_xValor	:= VS1->(FieldGet(FieldPos(_aEstruVS1[_nPos,1])))
				If Empty(_xValor)
					_xValor	:= _cNumOrc
				EndIf
			ElseIf _cCampo $ "VS1_XAGLU" 
				_xValor	:= _cAglutina
			ElseIf  _cCampo $ "VS1_XDTAGL" 
				If !Empty(_cAglutina)
					_xValor	:= Date()
				Else
					_xValor	:= CtoD(Space(08))	
				EndIf	
			ElseIf _cCampo $ "VS1_XHSAGL" 
				If !Empty(_cAglutina)
					_xValor	:= Time()
				Else
					_xValor	:= Space(05)
				EndIf	
			ElseIf _cCampo $ "VS1_XUSUGL" 
				If !Empty(_cAglutina)
					_xValor	:= RetCodUsr()
				Else
					_xValor	:= Space(10)
				EndIf	
			ElseIf _cCampo $ "VS1_RESERV" 
				_xValor	:= _cReserva  
			ElseIf _cCampo $ "VS1_STARES" 
				_xValor	:= _cStAres          
			ElseIf (_nPosCPo := Ascan(_aOrc[_nCount],{|x| AllTrim(x[1]) == _cCampo})) 	> 0	
					_xValor := _aOrc[_nCount,_nPosCPo,2]
			ElseIf Len(_aCpoVazio) > 0 .And. Ascan(_aCpoVazio, _cCampo)  > 0 //Caso seja vazio 
				If _aEstruVS1[_nPos,2] == "N"
					_xValor := 0
				ElseIf _aEstruVS1[_nPos,2] == "D"
					_xValor := CtoD(Space(08))
				ElseIf _aEstruVS1[_nPos,2] == "C"  
					_xValor := ""
				EndIf
			Else
				_xValor	:= VS1->(FieldGet(FieldPos(_aEstruVS1[_nPos,1])))
			EndIf	
			Aadd(_aVS1, _xValor)
		Next	
		If Len(_aVS1) == 0
			Aadd(_aObs, "Não carregado para o orçamento "+_cNumOrc+" para efetuar clonagem,  entrar em contato ADM Sistemas !")
			_lRet := .F.
			Break
		Endif

		//Atualizar as bases
		RecLock("VS1",.T.)
		For _nPos := 1 To Len(_aEstruVS1)
			VS1->(FieldPut(_nPos, _aVS1[_nPos]))
		Next	
		VS1->VS1_OBSAGL := Upper(_cObs)
		VS1->(MsUnlock())
		VS1->(ConfirmSx8())
		//Atualizar item produto
		If Len(_aVS3) > 0
			For _nCount := 1 To Len(_aVS3)
				RecLock("VS3",.T.)
				For _nPos := 1 To Len(_aEstruVS3)
					VS3->(FieldPut(_nPos, _aVS3[_nCount, _nPos]))
				Next	
				VS3->(MsUnlock())
			Next
		EndIf
		lWait := .F.
		//Calcula o imposto, tem que estar posicionado no VS1 DAC 14/03/2022
		//_lRet := VS1->(U_ORCCALFIS(_cOrcNovo,/*_lAtuaPreco*/))
		//Alterado para chamar por startjob DAC 26/09/2022
		
		StartJob("U_XFUNIPOSTO",GetEnvServer(),lWait,_cOrcNovo, cEmpAnt, cFilAnt, .T. /*_lJob*/)
		//U_XFUNIPOSTO(_cOrcNovo, cEmpAnt, cFilAnt, .T. /*_lJob*/)
		
		
	End Sequence

	If _nRegVS1 > 0
		VS1->(DbGoto(_nRegVS1))  //retorno o VS1 posicionado na pesquisa anterior
	ElseIf _nRegVS1Pos > 0  //caso não localize reposiciona no VS1 ao entrar na funcionalidade
		VS1->(DbGoto(_nRegVS1Pos))  //retorno o VS1 posicionado na pesquisa anterior
	Else
		_cObs 	:= "*** PROBLEMAS PARA CLONAGEM DE ORÇAMENTO "+_cNumOrc+If(!Empty(_cAglutina)," REFERENTE AO PROCESSO AGLUTINAÇÃO NR. "+_cAglutina,"") + CRLF
		For _nPos := 1 To Len(_aObs)
			_cObs += Upper(_aObs[_nPos])+ CRLF
		Next
		If _lMsg 
			MSGINFO( _cObs, "[ZEPECFPP8 - XAVLITVS3Clonar] - Atenção" )
		Endif
		ConOut(_cObs+" [XAVLITVS3Clonar]" )
		Return .F.
	Endif

	//Caso seja uma backorder gravar no original as informações de bak
	If _lBackOrder
		Aadd(_aObs, "BACKORDER ORC. " + _cOrcNovo +" FILIAL "+If(_lXBO .and. !Empty(_cFilTransf),_cFilTransf,_cFilAtual))  //VS1->VS1_NUMORC
	Endif
	VS1->(RecLock("VS1",.F.))
	_cObs 	:= "*** CLONAGEM DE ORÇAMENTO "+_cNumOrc+If(!Empty(_cAglutina)," REFERENTE AO PROCESSO AGLUTINAÇÃO NR. "+_cAglutina,"") + CRLF
	For _nPos := 1 To Len(_aObs)
		_cObs += Upper(_aObs[_nPos])+ CRLF
	Next
	VS1->VS1_OBSAGL := Upper(_cObs) +CRLF+ VS1->VS1_OBSAGL
	VS1->(MsUnlock())
	If _lRet .And. Len(_aRegVS3Del) > 0
		For _nPos := 1 To Len(_aRegVS3Del)
			VS3->(DbGoto(_aRegVS3Del[_nPos]))
			VS3->(RecLock("VS3",.F.))
			_cObs 	:= "REFERENTE AO PROCESSO AGLUTINAÇÃO NR. "+_cAglutina + CRLF
			_cObs	+= "REGISTRO EXCLUÍDO NO PROCESSO DE CLONAGEM DO ITEM "+AllTrim(VS3->VS3_CODITE)+" EM "+DtoC(Date())+" "+Time()	
			VS3->VS3_OBSAGL	:= Upper(_cObs) +CRLF+ VS3->VS3_OBSAGL
			//Não zerar causara erros somente apagar
			VS3->(DbDelete())
			VS3->(MsUnlock())
		Next _nPos
	EndIf
	//no final ajustar orçamento original
	If _lRet
		StartJob("U_XFUNIPOSTO",GetEnvServer(),lWait,VS1->VS1_NUMORC, cEmpAnt, cFilAnt, .T. /*_lJob*/)
		//U_XFUNIPOSTO(VS1->VS1_NUMORC, cEmpAnt, cFilAnt, .T. /*_lJob*/)
	EndIf
Return _lRet

//retornar o campo obrigatório
/*/{Protheus.doc} XCLONEOR
Funcionalidade responsavel retornar o campo obrigatório ao qual estão em Array verifica se são ou não obrigatórios
@author 	DAC-Denilso
@since 		27/07/2022
@version 	undefined
@param 		_aOrc 			- Array contendo informações do orçamento para clonar 
			_aObrigatorio	- Array com informações de campos obrigatórios para validar com _aORC
@project    PEC007
@type 		user function
@obs 		Revitalizado processo para gerar backorder de KIT e outros
@menu       Nao Informado
@return		_aObsRet 		- Array com campos que não foram preenchidos caso obrigatório, não tendo volta vazio
@history    
/*/
Static Function XCLONAOBRigatorio(_aOrc, _aObrigatorio )
	Local _lRet		:= .T.
	Local _aObsRet	:= {}
	Local _nCount
	Local _nPos
	Local _nPosCpo
	Local _xConteudo
	Local _cCampo
	Local _lObriga 

	Default _aObrigatorio	:=	{	{"VS1_CLIFAT"	, .T.},;
									{"VS1_LOJA"		, .T.},;
									{"VS1_NUMORC"	, .T.},;
									{"VS3_GRUITE"	, .T.},;
									{"VS3_CODITE"	, .T.},;
									{"VS3_QTDITE"	, .T.} }

	Begin Sequence
		For _nPos := 1 To Len(_aOrc)
			_lObriga := .F.
			For _nCount := 1 To Len(_aOrc[_nPos])
				_cCampo 	:= AllTrim(_aOrc[_nPos,_nCount,1])
				_xConteudo	:= _aOrc[_nPos,_nCount,2]
				_nPosCpo 	:= Ascan(_aObrigatorio,{|x| x[1] == _cCampo})
				If _nPosCpo == 0  //não validar caso não esteja preenchido como obrigatório
					Loop
				Endif
				If ValType(_xConteudo) == "N"
					_lRet := _xConteudo > 0
				ElseIf ValType(_xConteudo) == "A"
					_lRet := Len(_xConteudo) > 0
				ElseIf ValType(_xConteudo) == "L"  //lógico não validar
					_lRet := .T.
				Else 
					_lRet := !Empty(_xConteudo)
				Endif		
				//caso não loclizou nenhuma inconsistência sair
				If _lRet
					Loop
				EndIf
				//Se encontrou retornar obrigaorio como Falso	
				//_nPosCpo := Ascan(_aObrigatorio,{|x| x[1] == _cCampo})
				If _nPosCpo > 0
					_aObrigatorio[_nPosCpo,2] := .F.
					_lObriga := .T.
				Endif
			Next _nCount

			//Verifica se todos os itens obrigatórios foram atendidos
			If _lObriga .and. Len(_aObrigatorio) > 0
				For _nCount := 1 To Len(_aObrigatorio)
					If !_aObrigatorio[_nCount, 2]
						_cCampo := FWSX3Util():GetDescription( _aObrigatorio[_nCount,1] )
						_cObs 	:= "Campo "+_cCampo+ " tem que ser Preenchido para clonagem"	
						Aadd(_aObsRet, _cObs)
					EndIf
				Next _nCount	
				Break	
			Endif
		Next _nPos

	End Sequence
Return _aObsRet


/*/{Protheus.doc} XOFUNVTB
Pesquisa tabela cliente na DA1 por estado
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		_cCLi 		- Código Cliente 
			_cLoja		- Loja Cliente
			_cCodItem 	- Código do produto
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 
@menu       Nao Informado
@return		_nValTab
@history    

/*/
User Function XOFUNVTB(_cCLi, _cLoja, _cCodItem, _lProcUF)
	Local _cCodProd 	:= SubsTr(_cCodItem,1,Len(SB1->B1_COD))  //23
	Local _nValTab		:= 0
	Local _cAliasPesq	:= GetNextAlias()   
	Local _cAtivo		:= '1'
	Local _cData		:= DtOS(dDataBase)  //DtOS(Date()) //06/10/2022 conforme Zé utilizar o database
	Local _cFormula		:= ""
	Local _cCampo
	Local _cFunFor

	//indica que deve procurar a UF para verificação valores customizados DAC 18/04/2022
	Default _lProcUF := .T. 

	Begin Sequence
		//Acresentado validação de Memória JC informou que algumas funcionalidades chamam variavel DAC 06/10/2022 
		If Type("M->VS3_FORMUL") == "C" .And.  FWIsInCallStack("OFIXA011") .And. !(FWIsInCallStack("U_ZPECF008"))
			_cFormula  	:= M->VS3_FORMUL 
		else
			_cFormula 	:= VS3->VS3_FORMUL 
		EndIF
		//Valido Cóigo de Produto se veio preenchido DAC 06/10/2022
		If Empty(_cCodProd)
			If Type("M->VS3_CODITE") == "C" .And.  FWIsInCallStack("OFIXA011") .And. !(FWIsInCallStack("U_ZPECF008"))
				_cCodProd := M->VS3_CODITE
			Else
				_cCodProd := VS3->VS3_CODITE
			Endif	
		EndIf
		//verificação do FORMULA	
		If _cFormula <> '000001'
			DbSelectArea("VS3")
			//VS3->(DbSetOrder(1))  //VS3_FILIAL+VS3_NUMORC
			//VS3->(dbSeek(xFilial("VS3")+VS1->VS1_NUMORC))
			DbSelectArea("VEG")
			VEG->(DbSetOrder(1))  //VEG_FILIAL+VEG_CODIGO
			If !VEG->(dbSeek(xFilial("VEG")+_cFormula))
				Break
			EndIf	
			
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))  //B1_FILIAL+B1_COD
			//SB1->(dbSeek(xFilial("SB1")+VS3->VS3_CODITE))  //Alterado pode vie por variaveis de memória DAC 06/10/2022    
			SB1->(dbSeek(xFilial("SB1")+_cCodProd))     
			If Substr(VEG->VEG_FORMUL,1,5) = "SB1->"
			_nValTab  :=  &(VEG->VEG_FORMUL)    
			ElseIf Substr(VEG->VEG_FORMUL,1,5) = "EXECB"  
				_cFunFor := AllTrim(VEG->VEG_FORMUL)
			_nValTab  := &_cFunFor
			Else
				_cFunFor := AllTrim(VEG->VEG_FORMUL)
			_nValTab  := &_cFunFor
			Endif
			//Controlar para que a função não retorne nada diferente de valor DAC 28/05/2022
			If ValType(_nValTab) <> "N"
				_nValTab := 0 
				Break
			Endif
			Break
		EndIf
		//Caso a formula seja igual a 000001
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	DA1.R_E_C_N_O_ AS NREGDA1,
					SA1.A1_EST
			FROM  %Table:DA1% DA1
			JOIN  %Table:SA1% SA1 
				ON	SA1.A1_FILIAL  	= %xFilial:SA1%
				AND SA1.A1_COD  	= %Exp:_cCLi%
				AND SA1.A1_LOJA 	= %Exp:_cLoja%
				AND SA1.%notDel%
			JOIN %Table:DA0% DA0 
				ON	DA0.DA0_FILIAL  = %xFilial:DA0%
				AND DA0.DA0_ATIVO	= %Exp:_cAtivo%
				AND %Exp:_cData% BETWEEN DA0.DA0_DATDE AND DA0.DA0_DATATE
				AND DA0.%notDel%
			WHERE 	DA1.DA1_FILIAL  = %xFilial:DA1% 
				AND DA1.DA1_CODTAB  = DA0.DA0_CODTAB
				AND DA1.DA1_CODPRO 	= %Exp:_cCodProd%
				AND DA1.%notDel%
		EndSQL	

		If (_cAliasPesq)->(!Eof()) .and. (_cAliasPesq)->NREGDA1 > 0
			DA1->(DbGoto((_cAliasPesq)->NREGDA1))
			If _lProcUF
				_cCampo 	:= "DA1_X"+(_cAliasPesq)->A1_EST
				_nValTab 	:= DA1->(FieldGet(FieldPos(_cCampo)))
			Else
				_nValTab 	:= DA1->DA1_PRCVEN	
			EndIf	
		EndIf

	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 
Return _nValTab

/*/{Protheus.doc} XFASEORC
Responsável por verificar a Fase que esta sendo enviada analisando a mesma
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		_cFase 		- Fase a ser analisada 
			_cGrupo		- Grupo de Produto
			_cCodPro 	- Código do produto
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@menu       Nao Informado
@return		_cMsg - Msg da validação
@history    
@type 		user function
@ Obs		Deverá ser enviada uma fase para ser validada caso não tenha alteração será mantida a mesma fase, 
			caso seja uma liberação de fase ex. esta validando a fase do orçamento que esta em 3 verificou que 
			foi liberado voltara para a fase 0 para dar prosseguimento ao processo, caso não esteja liberado mantera a fase 3.
			Também passara para a fase 3 ou 2 após a validação e assim por diante 
			Tem que estar posicionado no VS1
/*/
User Function XFASEORC(_cFase, _cGrupo, _cCodPro, _nLimAvalia)
Local _cMsg			:= ""
Local _cTpOperPed   := ""
Local _aMsg			:= {}
Local _cFaseRet		:= VS1->VS1_STATUS
Local _nRegVS1		:= VS1->(Recno())
Local _cFaseSepara 	:= Alltrim(GetNewPar("MV_MIL0095","4"))  //Fase conferencia da Separação
Local _nPos

Default _cGrupo 	:= ""
Default _cCodPro	:= ""
Default _nLimAvalia	:= 0

Begin Sequence
	//esta variavel é utilizada em algumas funções caso seja função que nao preve a mesma criara para não dar erro
	//If Type("_aMensAglu") <> "A"   
	//	Private _aMensAglu := {}
	//EndIf
	_cNumOrc 	:= VS1->VS1_NUMORC
	If VS1->VS1_STATUS == "X" // ORCAMENTO FECHADO
		_cMsg	:= "Orçamento Fechado !"
		Break
	EndIf	
	If VS1->VS1_STATUS == "C" // ORCAMENTO CANCELADO
		_cMsg	:= "Orçamento cancelado !"
		Break
	EndIf
	If VS1->VS1_STATUS == "A" // ORCAMENTO AGLUTINADO
		_cMsg	:= "Orçamento agrupado no orçamento "+VS1_XUSUGL+" !"
		Break
	Endif
	If VS1->VS1_TIPORC == "3"	//1=Orcamento Pecas;2=Orcamento Oficina;3=Transferência
		_cMsg 	:= "Orçamento de Transferência, não será processado !"
		Break
	EndIf
	If VS1->VS1_STATUS == _cFaseSepara // ORCAMENTO SEPARAÇÃO
		_cMsg	:= "Orçamento ja esta em separação !"
		Break
	Endif
	If  VS1->VS1_STATUS == "F" // LIBERADO PARA FATURAMENTO
		_cMsg	:= "Orçamento ja esta liberado para faturamento !"
		Break
	Endif	
	If _cFase == "2" // MARGEM DE LUCRO
		_cFaseRet := XFASMARGEM(@_cMsg)
		Break
	Endif
	VS1->(DbGoto(_nRegVS1))  //reposicionar VS1 DAC 20/06/2022	
	If _cFase == "3" // LIMITE DE CREDITO
		//Encontrar tipo de operação
		_cTpOperPed := XLOCTPOPPE("VS3", VS1->VS1_NUMORC)  	
		_cFaseRet := U_XFASLIMCRE( "VS1", VS1->VS1_CLIFAT, VS1->VS1_NUMORC, VS1->VS1_VTOTNF, _cTpOperPed, VS1->VS1_FORPAG, VS1->VS1_STATUS, @_nLimAvalia, @_aMsg)
		If Len(_aMsg) > 0
			_cMsg	:= ""
			For _nPos := 1 To Len(_aMsg)
				_cMsg += Upper(_aMsg[_nPos]) + CRLF
			Next _nPos
		EndIf

		Break
	EndIf
	VS1->(DbGoto(_nRegVS1))  //reposicionar VS1 DAC 20/06/2022	
	If _cFase == "4" // Separação conferência
		_cFaseRet := XFASSEPARA(@_cMsg)
		Break
	EndIf
End Sequence
If !Empty(_cFaseRet) .And. _cFaseRet <> VS1->VS1_STATUS  //adcionar nas msg
	If VS1->(RecLock("VS1",.F.))	
		VS1->VS1_STATUS := _cFaseRet
		VS1->(MsUnLock())
	EndIf
EndIf
//incluo para retorno as msgs de retorno serão array
If !Empty(_cMsg) .and. Type("_aMensAglu") == "A"
	Aadd(_aMensAglu,_cMsg)
EndIf	
Return _cFaseRet


/*/{Protheus.doc} XFASMARGEM
Responsável por validar a Margem de Lucro FASE 2
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		_cFase 		- Fase a ser analisada 
			_cGrupo		- Grupo de Produto
			_cCodPro 	- Código do produto
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 
@menu       Nao Informado
@return		_cFaseRet - Fase atualizada
@history    
@ Obs		Deverá ser enviada fase  e validara e verificara se o mesmo esta ou não na fase 2 retornando a fase correta
/*/
Static Function XFASMARGEM(_cMsg)
Local _cAliasPesq	:= GetNextAlias()   
Local _cFaseRet		:= VS1->VS1_STATUS
Local _lMsg			:= .F.
Local _lProbMargem	:= .F.
Local _lProbDesc	:= .F.
Local _lRetDes		:= .F.	
Local _lRetMargem	:= .F.
Local _aVS3Margem	:= {}
Local _aRetDes 		:= {}
Local _nValPerm		:= 0
Local _lRet

//sou obrigado a passar para private pois esta direcionando para formula (001322) onde pede esta variavel
Private nPercMin   := 0

Begin Sequence
	//possibilidade de um parametro para verificar se deve bloquear todos os orçamentos quando um só não atende a margem
	//possibilidade de desmenbrar
	If !Empty(VS1->VS1_NUMLIB)
		//Cabeçalho da Liberação Venda  
		//caso esteja preenchido data autorização poss liberar para "A"
		If FM_SQL("SELECT COUNT(VS6.R_E_C_N_O_) RECVS6 FROM "+RetSQLName("VS6")+" VS6 WHERE VS6.VS6_FILIAL='"+xFilial("VS6")+"' AND VS6.VS6_DATAUT = '        '  AND VS6.D_E_L_E_T_ = ' ' AND VS6.VS6_NUMORC='"+VS1->VS1_NUMORC+"'") > 0
			_cMsg 		:= "Orçamento possui indicaçao Liberação de Venda " +VS1->VS1_NUMLIB+ " não autorizada, MARGEM DE LUCRO !"
			_cFaseRet 	:= "2"
			lRet 		:= .F.
			Break
		Else	//pode liberar para faturamento existe liberação de vendas		
			_cMsg 			:= "Orçamento com Liberação de Venda "+VS1->VS1_NUMLIB+" autorizada !"
			If _cFaseRet	==	"2" //somente alterar a fase caso seja fase 2 caso contrario não
				lRet 		:= .T.
				_cFaseRet 	:= "0"  //volto a margem 
				Break
			EndIf
		EndIf	
	EndIf

	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT 	VS3.R_E_C_N_O_ AS NREGVS3,
				SB1.R_E_C_N_O_ AS NREGSB1,
				SF4.R_E_C_N_O_ AS NREGSF4,
				SBM.R_E_C_N_O_ AS NREGSBM,
				VS3.VS3_CODTES,
				VS3.VS3_SEQUEN,
				SF4.F4_OPEMOV
		FROM  %Table:VS3% VS3			
		JOIN %Table:SB1% SB1	
			ON 	SB1.B1_FILIAL  	= %xFilial:SB1% 
			AND SB1.B1_GRUPO  	= VS3.VS3_GRUITE
			AND SB1.B1_COD 		= VS3.VS3_CODITE
			AND SB1.%notDel%
		JOIN %Table:SBM% SBM
			ON	SBM.BM_FILIAL  	= %xFilial:SBM%
			AND SBM.BM_GRUPO	= SB1.B1_GRUPO
			AND SBM.%notDel%
		JOIN  %Table:SF4% SF4  
			ON	SF4.F4_FILIAL  	= %xFilial:SF4%
			AND SF4.F4_CODIGO  	= VS3.VS3_CODTES
			AND SF4.%notDel%
		WHERE 	VS3.VS3_FILIAL  = %xFilial:VS3%
			AND VS3.VS3_NUMORC	= %Exp:VS1->VS1_NUMORC% 
			AND VS3.%notDel%
		ORDER BY VS3.VS3_SEQUEN	   
	EndSQL	
	//caso não encontre os registros não mudara a fase
	If (_cAliasPesq)->(Eof())
		_cMsg := "Não encontrado itens referente a Margem de Lucro!"
		Break
	EndIf
	_cMsg := "" 
	While (_cAliasPesq)->(!Eof())
		//Adiciono na matriz valores iniciais para posteriormente testar
		Aadd(_aVS3Margem, {(_cAliasPesq)->NREGVS3, ;    //01
							.F., ;						//02-_lRetMargem
							.F., ;						//03-_lRetDes
							0,;							//04-_aRetDes[2] desc percent
							0,;							//05-_aRetDes[3] margem
							0 }) 						//06-_nValPerm
		If AllTrim((_cAliasPesq)->F4_OPEMOV) <> "05"
			_cMsg	+= "TES "+(_cAliasPesq)->VS3_CODTES+" possui movimento de Operação Tipo de Faturamento diferente 5 na TES, não passara pela fase Margem de Lucro !"
			_cMsg	+= CRLF
			(_cAliasPesq)->(DbSkip())
			Loop
		EndIf
		//posiciono os Registros
		VS3->(DbGoto((_cAliasPesq)->NREGVS3))
		SB1->(DbGoto((_cAliasPesq)->NREGSB1))
		SBM->(DbGoto((_cAliasPesq)->NREGSBM))
		SF4->(DbGoto((_cAliasPesq)->NREGSF4))
		_lRet := OX005PERDES(SBM->BM_CODMAR,VS1->VS1_CENCUS,VS3->VS3_GRUITE,VS3->VS3_CODITE,VS3->VS3_QTDITE,VS3->VS3_PERDES,_lMsg,VS1->VS1_CLIFAT,VS1->VS1_LOJA,VS1->VS1_TIPVEN,VS3->VS3_VALTOT/VS3->VS3_QTDITE,,VS1->VS1_FORPAG)
		If !_lRet  //tem Bloqueio
			//Caso tenha Bloqueio devo gravar VS6/VS7
			_aRetDes 	:= OX005PERDES(SBM->BM_CODMAR,VS1->VS1_CENCUS,VS3->VS3_GRUITE,VS3->VS3_CODITE,VS3->VS3_QTDITE,VS3->VS3_PERDES,.T.,VS1->VS1_CLIFAT,VS1->VS1_LOJA,VS1->VS1_TIPVEN,VS3->VS3_VALTOT/VS3->VS3_QTDITE,3,VS1->VS1_FORPAG)
			_lRetDes	:= .F.	
			_lRetMargem	:= .F.
			If GetNewPar("MV_SEPDML","N") == "S"
				If VS3->VS3_PERDES > aRetDes[2] 
					_lRetDes 	:= .T.
					_lProbDesc	:= .T.
				EndIf	
			Endif
			/*
			VS3->(RecLock("VS3",.F.))
			if aRetDes[2] > 9999.99
				VS3->VS3_MARLUC := 9999.99
			Elseif aRetDes[2] < -9999.99
				VS3->VS3_MARLUC := -9999.99
			Else
				VS3->VS3_MARLUC := aRetDes[2]
			Endif
			*/
			VS3->(MsUnLock())
			If VS3->VS3_MARLUC < _aRetDes[3]  
				_lRetMargem 	:= .T.	
				_lProbMargem	:= .T.
			Endif
			If _lRetDes .or. _lRetMargem
				_nPercMin := _aRetDes[3]
				nPercMin := _aRetDes[3]
				_nValPerc := 	FG_FORMULA(GetNewPar("MV_FORMALI","")) // Formula padrao para calculo do rateio de desconto 
				_nValDesc = (1- _aRetDes[2]/100) * VS3->VS3_VALPEC // valor minimo de venda da peca considerando desconto maximo
				If _nValPerc > _nValDesc
					_nValPerm := _nValPerc
				Else
					_nValPerm := _nValDesc
				Endif
				If _aRetDes[1] <> 0
					_nValPerm := _aRetDes[1]
				Endif
			EndIf
			//Atualiza matriz
			_aVS3Margem[Len(_aVS3Margem),2]	:= _lRetMargem
			_aVS3Margem[Len(_aVS3Margem),3]	:= _lRetDes
			_aVS3Margem[Len(_aVS3Margem),4]	:= _aRetDes[2]
			_aVS3Margem[Len(_aVS3Margem),5]	:= _aRetDes[3]
			_aVS3Margem[Len(_aVS3Margem),6]	:= _nValPerm 
		Endif
		(_cAliasPesq)->(DbSkip())
	EndDo	
	//Caso ocorreu problemas com margem e ou desconto devverá grava VS6 e VS7
	If _lProbMargem .or. _lProbDesc
		XFASMARV67(_aVS3Margem, _lProbMargem, _lProbDesc)
		_cMsg 		+= "Orçamento com Bloqueio Margem de Lucro/ Desconto ! "
		_cMsg		+= CRLF
		_cMsg		+= "Gravado dados para Liberação !"
		_cFaseRet	:= "2"
	Else //caso não verificar se esta com status 2 pois se tiver alguma divergencia não havera mais
		_cMsg 		:= "Orçamento liberado sem Bloqueio Margem de Lucro !"
		If _cFaseRet	==	"2" //somente alterar a fase caso seja fase 2 caso contrario não
			_cFaseRet 	:= "0"  //volto a margem 
		EndIf
	EndIf
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _cFaseRet

/*/{Protheus.doc} XFASMARV67
Responsável por Gravar VS6 VS7 ref. Margem de Lucro FASE 2
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		_aVS3Margem - Matriz com problemas relatados 
			_lProbMargem- indica problemas de margem
			_lProbDesc 	- Problemas de descontos
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 
@menu       Nao Informado
@return		Nil
@history    
/*/
Static Function XFASMARV67(_aVS3Margem, _lProbMargem, _lProbDesc)
	Local _lTemML 		:= .f.
	Local _lTemDesc 	:= .f.
	Local _lVS7SemProb 	:= AllTrim(GetNewPar("MV_MIL0131", "0")) == "1" // Cria/Mostra VS7 de todos os Itens se pelo menos 1 tiver problema de Margem ou Desconto
	Local _cNumVS6
	Local _nPos

	Begin Sequence					
		_cNumVS6 := GetSxENum("VS6","VS6_NUMIDE")
		VS6->(RecLock("VS6",.t.))
		VS6->VS6_FILIAL := xFilial("VS6")
		VS6->VS6_NUMIDE := _cNumVS6
		VS6->VS6_TIPAUT := "1"
		VS6->VS6_CODCLI := VS1->VS1_CLIFAT
		VS6->VS6_LOJA   := VS1->VS1_LOJA
		VS6->VS6_DATOCO := Date()
		VS6->VS6_HOROCO := val(substr(time(),1,2)+substr(time(),4,2))
		VS6->VS6_NUMORC := VS1->VS1_NUMORC
		VS6->VS6_TIPOCO := IIF(_lProbMargem,"000008","000009")
		VS6->VS6_DESOCO := IIF(GetNewPar("MV_SEPDML","N")=="N","DESCONTO / MARGEM MINIMA",IIF(_lTemDesc,"DESCONTOS","MARGEM LUCRO"))
		VS6->VS6_USUARI := SubsTr(cUsuario,7,15)
		VS6->VS6_FORPAG := VS1->VS1_FORPAG
		VS6->VS6_OBSMEM := "REFERENTE AO PROCESSO AGLUTINAÇÃO NR. "+_cAglutina
		VS6->(ConfirmSx8())
		VS6->(MsUnlock())

		For _nPos := 1 To Len(_aVS3Margem)
			VS3->(DBGoto(_aVS3Margem[_nPos,1]))
			_lTemML 	:=  _aVS3Margem[_nPos,2]
			_lTemDesc	:=	_aVS3Margem[_nPos,3]
			//Caso não seja para enviar todos e não tenho divergencias com Margem  nem descontos pular 
			If !_lVS7SemProb .and. !_lTemML .and. !_lTemDesc
				Loop
			EndIf
			VS7->(RecLock("VS7",.T.))
			VS7->VS7_FILIAL := xFilial("VS7")
			VS7->VS7_NUMIDE := _cNumVS6
			VS7->VS7_SEQUEN := Strzero(_nPos,4)
			VS7->VS7_TIPAUT := "1"
			VS7->VS7_GRUITE := VS3->VS3_GRUITE
			VS7->VS7_CODITE := VS3->VS3_CODITE
			VS7->VS7_DESPER := _aVS3Margem[_nPos,4]
			VS7->VS7_DESDES := VS3->VS3_PERDES
			VS7->VS7_VALORI := VS3->VS3_VALPEC
			VS7->VS7_VALPER := _aVS3Margem[_nPos,6]
			VS7->VS7_VALDES := VS3->VS3_VALPEC - (VS3->VS3_VALDES/VS3->VS3_QTDITE)
			VS7->VS7_MARPER := _aVS3Margem[_nPos,5]
			VS7->VS7_MARLUC := VS3->VS3_MARLUC
			VS7->VS7_QTDITE := VS3->VS3_QTDITE
			If VS7->(FieldPos("VS7_DIVERG")) > 0
				VS7->VS7_DIVERG := If( !_lTemML .and. !_lTemDesc,"0","1") // Se o elemento do Array estiver com .F. é porque não houve Divergencia de Desconto ou Margem
			Endif
			VS7->(MsUnlock())
		Next
		VS1->(RecLock("VS1",.F.))
		VS1->VS1_NUMLIB := _cNumVS6
		VS1->(MsUnlock())
	End Begin
Return Nil	


//Localizar o tipo de operação do pedido
Static Function XLOCTPOPPE(_cAlias, _cNumPed) 
Local _cRet	:= ""
Local _nReg := (_cAlias)->(RECNO())

Default _cAlias	:= ""
Default _cNumPed	:= ""

Begin Sequence
	If Empty(_cAlias) .Or. Empty(_cNumPed)
		Break
	EndIf
	_nReg := (_cAlias)->(RECNO())
	(_cAlias)->(DbSetOrder(1))
	(_cAlias)->(DbGotop())
	If (_cAlias)->(DbSeek(XFilial(_cAlias)+_cNumPed))
		_cRet	:= If(_cAlias=="VS3" ,VS3->VS3_OPER, ;
					If(_cAlias=="SC6",SC6->C6_OPER,;
					"")) 
	EndIf				
End Sequence
(_cAlias)->(DbGoto(_nReg))
Return _cRet


/*/{Protheus.doc} XFASLIMCRE
Responsável por validar a Limite de Crédito FASE 3
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		_cMsg 		- grava dados de retorno 
@type 		user function
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@menu       Nao Informado
@return		_cFaseRet - Fase atualizada
@ Obs		Deverá ser enviada fase  e validara e verificara se o mesmo esta ou não na fase 2 retornando a fase correta
@history    DAC 02/03/2023
			GRUPO CAOA - GAP FIN100 - Campo Matriz Clientes (Revitalização Limite de Crédito)
            Revitalição processo limite de crédito, ajuste na informação de LOJA anteriormente estava fixo
			Alteração incluindo tipo de pgto diferenciado que não irá verificar limite de crédito solicitação Aline, DAC - 13/03/2023
/*/

User Function XFASLIMCRE(_cTabPed, _cCliente, _cPedido, _nValTotPed, _cTpOperPed, _cCondPgtoPed, _cStatusPed, _nLimAvalia, _aMsg)
Local _aAreaSA1   	:= SA1->(GetArea())
Local _aArea	   	:= GetArea()
Local _cFaseRet		:= ""
Local _cTpPgtoVista	:= AllTrim(GetMv("MV_CPNCLC")) //Cond. de pagto. p/ venda a vista sem limite Credit
Local _cTpPgtoEsp	:= AllTrim(SuperGetMV( "CMV_PEC039"  ,,"" ))  //Condição de Pagamento a qual liberará sem avaliação do Limite de Crédito
Local _cTpOper      := AllTrim(SuperGetMV( "CAOA_TPLIM" ,,""))  //Tipos de Operação para analise do crédito - CAOA   54;91;90;67;82;93
Local _cLoja		:= ""  
Local _lAvaliaPecas := .T.

Default _cTabPed		:= ""
Default _cCliente		:= ""
Default _cPedido		:= ""
Default _nValTotPed 	:= 0
Default _cTpOperPed		:= ""
Default _cCondPgtoPed   := ""
Default _cStatusPed 	:= ""
Default _nLimAvalia 	:= 0
Default _aMsg			:= {}

Begin Sequence
	If Empty(_cCliente) .Or. Empty(_cTabPed) .Or. Empty(_cPedido) .or. _nValTotPed <= 0 
		_cFaseRet 	:= ""
		Break
	Endif 
	_lAvaliaPecas 	:= If(AllTrim(_cTabPed) == "VS1", .T., .F.)
	_nLimAvalia	  	:= 0
	_cFaseRet		:= _cStatusPed 
	//Neste caso se for informado o tipo de operações a serem validadas e não estiver no parâmetro libera o crédito DAC 05/04/2023
	If !Empty(_cTpOper) .And. !_cTpOperPed $ _cTpOper
		AAdd(_aMsg, "Liberado, condição de pagamento não informada Parâmetro CAOA_TPLIM !")		
		_cFaseRet 	:= "0"
		Break
	EndIf                                                                                                                                                                                                                                    
	//003;011;025       
	If !Empty(_cTpPgtoVista)  //!Empty(GetNewPar("MV_CPNCLC","")) 
		If !AllTrim(_cCondPgtoPed) $ _cTpPgtoVista  .And. _lAvaliaPecas //GetMv("MV_CPNCLC") 
			//Caso não tenha informado condição pgto
			If Empty(_cCondPgtoPed)
				//Local onde sera validado o limite de credito      
				If !"B" $ GetMv("MV_CHKCRE")  //ORÇAMENTO BALCÃO
					_cFaseRet := "0"
					AAdd(_aMsg, "Liberado, não informado condição de pagamento conforme indicação MV_CHKCRE !")		
				Else
					AAdd(_aMsg, "Não informado condição de pagamento conforme indicação MV_CHKCRE !")		
					_cFaseRet := "3"
				Endif
				Break
			Endif
		ElseIf Empty(_cTpPgtoVista)  
			AAdd(_aMsg, "Não informado condição de pagamento !")		
			_cFaseRet 	:= ""
			Break
		Else	//Caso esteja informado no parâmetro não passar pela rotina de bloqueio
			_cFaseRet := "0"
			Break	
		Endif
	Endif
	//Condição de Pagamento Especial liberar credito automaticamente DAC 20/03/2023
	If !Empty(_cTpPgtoEsp) .and. AllTrim(_cTpPgtoVista) $ AllTrim(_cTpPgtoEsp) 
		_cFaseRet := "0"
		Break
	Endif
	//Verificar se o Cliente possui cadastrado a loja deve ser pesquisada conforme tipo de crédito 
	_cLoja := U_XLJLCREDito(_cCliente)
	If Empty(_cLoja)
		AAdd(_aMsg, "Não localizado cliente contendo Limite de Crédito com código "+_cCliente+" !")		
		_cFaseRet 	:= ""
		Break
	Endif
	If SA1->A1_XBLQLC == "1" //1=Bloqueio Manual
		AAdd(_aMsg, "Loja com Bloqueio Manual de Crédito. Cliente "+_cCliente+" loja "+_cLoja)		
		_cFaseRet 	:= ""
		Break
	ElseIf SA1->A1_XBLQLC == "2" //2=Descredenciado  
		AAdd(_aMsg, "Loja com Descredenciamento de Crédito. Cliente "+_cCliente+" loja "+_cLoja)		
		_cFaseRet 	:= ""
	EndIf
	//Avaliação de Crédito
	If SA1->A1_XTPCRED $ "1|2" // 1=FloorPlan 2=Caoa
		_cFaseRet := XFLCREDITO( _lAvaliaPecas, _cCliente, _cLoja, _cPedido, _nValTotPed, _cCondPgtoPed, @_cFaseRet, @_nLimAvalia, @_aMsg )  //Avalia Credito FloorPlan e Caoa
		Break 
	Else
		AAdd(_aMsg, "Não definido tipo de limite de crédito para o cliente com código "+_cCliente+" com a loja "+_cLoja	)
		_cFaseRet 	:= ""
		Break
	EndIf
	AAdd(_aMsg, "Orçamento sem restrição de crédito !")
End Sequence	
RestArea(_aAreaSA1)
RestArea(_aArea)
Return _cFaseRet



/*/{Protheus.doc} XFLCREDITO
Responsável por verificar limite de crédito Floor Plan
@author 	DAC-Denilso
@since 		28/03/2022
@version 	undefined
@param 		_cFaseRet	- Fase orçamento
			_cMsg		- Mensagens que serão gravadas no orçamento
@type 		user function
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@menu       Nao Informado
@return		_cFaseRet 
@ Obs		
@history    24/05/2022 DAC	- Alterado para verificar pela loja principal (01) conforme solicitação Antonio o 
							  limite referente a Forplan será verificado na loja principal	
    		DAC 02/03/2023
			GRUPO CAOA - GAP FIN100 - Campo Matriz Clientes (Revitalização Limite de Crédito)
            Revitalição processo limite de crédito, ajuste na informação de LOJA anteriormente estava fixo

/*/
Static Function XFLCREDITO(_lAvaliaPecas, _cCliente, _cLoja, _cPedido, _nValTotPed, _cCondPgtoPed, _cFaseRet, _nLimAvalia, _aMsg)
Local _nLcUsado  	:= 0
Local _aRetLc		:= {}
Local _nFatorRed    := SuperGetMV( "CMV_PEC035" ,, 0 )					//Fator de redução para calculo do Limite de Crédito	
Local _cForplan		:= AllTrim( SuperGetMV( 'CMV_PEC018' ,, "" ) ) 	//condição de pagamento Forplan = 005
Local _cTpPgtoEsp	:= AllTrim( SuperGetMV( "CMV_PEC039" ,, "" ) ) 	//Condição de Pagamento a qual liberará sem avaliação do Limite de Crédito

Begin Sequence
	//Não deixar ultrapassar 100 %
	If _nFatorRed > 100
		_nFatorRed := 100
	Endif

	_nLimAvalia := 0   
	//Alterado para procurar por limite de crédito DAC 20/03/2023
	If EmpTy(_cLoja) .Or. SA1->A1_COD <> _cCliente .Or. SA1->A1_LOJA <> _cLoja
		_cLoja := U_XLJLCREDito(_cCliente)
		If Empty(_cLoja)
			Aadd(_aMsg, "Não localizado cliente contendo Limite de Crédito com código "+_cCliente+" com a loja "+_cLoja )		
			_cFaseRet := ""
			Break
		Endif
	EndIf	

	If SA1->A1_XTPCRED == "0"
			Aadd(_aMsg, "Cliente possui Tipo limite de crédito [0]")
			_cFaseRet 	:= ""
			Break
	ElseIf SA1->A1_XTPCRED == "1" //floorplan
		//Se não estiver preenchido não validar
		If Empty(_cForplan)
			_cFaseRet 	:= ""
			Aadd(_aMsg, "Não informado condições de pgto no parâmetro ForPlan !")
			Break
		Endif
		//quando indicado forplan no parametro tem que ter a mesma condição pgto e não estar na condição de pgto especial
		If !AllTrim(_cCondPgtoPed) $ _cForplan  
			If !Empty(_cTpPgtoEsp) .And. AllTrim(_cCondPgtoPed) $ _cTpPgtoEsp
				_cFaseRet 	:= "0"  //neste caso posso sair sem validar pois a condição especial não deve avaliar crédito
			Else
				_cFaseRet 	:= ""
				Aadd(_aMsg, "Condição de pgto "+_cCondPgtoPed+" ForPlan não esta informada no parâmetro CMV_PEC018 !")
			Endif	
			Break
		EndIf
	EndIf
	Aadd(_aMsg,"Avaliando Limite de Credito para o cliente "+_cCliente+" loja "+_cLoja+" - Matriz")
	_nLimAvalia := 0   //Zero a avaliação de crédito onde constará o limite a ser utilizado
	_aRetLc := U_ZFATF014(_cCliente, SA1->A1_XTPCRED, _cLoja)
	//GAP096  Nick CAOA 21/11/2023
	//1=Credito Disponivel;2=Falta de Saldo;3=Titulos Em Atraso;4=Credito Vencido;5=Bloqueado                                         
	If ValType(_aRetLc) <> "A" .Or. Len(_aRetLc) == 0 
		Aadd(_aMsg, "Não foi possível verificar limite de crédito disponível")
		_cFaseRet 	:= "3" 
		Break
	ElseIf _aRetLc[01] == "2"
		//enviar o limite para ser avaliado DAC 14/11/2022
		//			 					NCC			  ( Titulos em Aberto + Pedidos em Bo + (Em Reserva + Em faturamento + Em Separação))
		_nLimAvalia := (SA1->A1_XLC +  _aRetLc[06]) - ( _aRetLc[03] + _aRetLc[04]  + _aRetLc[05] )  ////retirar NCC (06) caso exista pois é crédito cliente DAC 05/04/2023
		//Quando for B.o. somo novamente ao saldo que tenho a utilizar  o valor pois já somou no acumulado de B.o. e o mesmo é crédito ainda para utilizar
		//Conforme revitalização sempre somar o que está pendente será sempre B.O. DAC 02/03/2023
		If ( _cFaseRet == "0" .OR. _cFaseRet == "3" ) //VS1->VS1_XBO == 'S' //BO e Em análise consomem limite de crédito 12/2022
			//_nLimAvalia += _nValTotPed
			//neste caso deduzo o limite para que possa avaliar, pois na somatório dos BO's o mesmo foi somado DAC 21/03/2023
			_nLimAvalia +=  ( _nValTotPed * (If(_nFatorRed > 0,_nFatorRed/100,1)) )
		EndIf
		Aadd(_aMsg, "Cliente não possui limite de crédito disponível Status [2]")
		_cFaseRet 	:= "3" 
		Break
	ElseIf _aRetLc[01] == "3"
		Aadd(_aMsg, "Cliente possui algum titulo com mais de 3 dias em atraso Status[3]")
		_cFaseRet 	:= ""
		Break
	ElseIf _aRetLc[01] == "4"
		Aadd(_aMsg, "Cliente possui limite de crédito vencido Status[4]")
		_cFaseRet 	:= ""
		Break
	ElseIf _aRetLc[01] == "5"
		Aadd(_aMsg, "Cliente possui limite de crédito bloqueado Status[5]")
		_cFaseRet 	:= ""
		Break
	EndIf
	//_nValDup := ( Titulos em Aberto + Pedidos em Bo + (Em Reserva + Em faturamento + Em Separação))
	//Alterado conforme alinhamento com Zé e Reinaldo feito revitalização para validar somente quando for na Onda DAC 21/03/2023
	//_nLcUsado := ( _aRetLc[03] + _aRetLc[04]  + _aRetLc[05] ) + (VS1->VS1_VTOTNF * (_nRedBO/100)) //************************************************ verificar avaliação
	_nLcUsado := ( _aRetLc[03] + _aRetLc[04]  + _aRetLc[05] ) - _aRetLc[06]  //retirar NCC caso exista pois é crédito cliente DAC 05/04/2023 
	//DAC 06/12/2022
	_nLimAvalia := SA1->A1_XLC - _nLcUsado 
	//Quando for B.o. deduzu o valor pois já somou no acumulado de B.o.
	// não utilizar no momento/* Não deduzir ja esta na somatória dos BOs com fator de redução validar com o orçamento em questão DAC 21/03/2023

	If ( _cFaseRet == "0" .OR. _cFaseRet == "3" ) //.And. VS1->VS1_XBO == 'S'
		_nLcUsado 	:= _nLcUsado - ( _nValTotPed * (If(_nFatorRed > 0 ,_nFatorRed/100, 1)) ) 
		//somo o valor novamente pois estara na somatória dos BO's e necessitarei utilizar o valor do mesmo para compor a diferença DAC 15/12
		_nLimAvalia +=  ( _nValTotPed * (If(_nFatorRed > 0 , _nFatorRed/100, 1)) ) 
	EndIf

	//Esta opção é somente para avaliação peças DAC 05/04/2023
	If _lAvaliaPecas .and. (_nLcUsado > SA1->A1_XLC )  //.Or. SA1->A1_XDTLC < DATE())
		//Faço a gravação com a loja originada do VS1 para garantir integridade das bases DAC 24/05/2022	
		If !XFLPESQVSW(_cPedido, _cCliente, _cLoja, Iif(SA1->A1_XTPCRED=="1",.T.,.F.),  @_aMsg)  //caso passe  não tem bloqueios
			//_cFaseRet := XFLCREVSWG( VS1->VS1_NUMORC, VS1->VS1_CLIFAT, VS1->VS1_LOJA, "BLOQUEIO FORPLAN", @_aMsg )  //inclui registro de liberação Forplan, verifica se ja possui liberação para mudança de status	
			_cFaseRet 	:= "3"
			Break
		EndIf	
	//EndIf
	//DAC 20/03/2023
	//neste caso tenho que somar o titulo para que tenha o valor do limite de crédito correto se passou pela linha acima existe valores ainda no limite que podem ou não ser utilizados
	//tenho que somar todo o processo pois tem que retornar como bloqueado fase 3 para verificar se pode utilizar parcial
	ElseIf (_nLcUsado + _nValTotPed) > SA1->A1_XLC   
		_cFaseRet 	:= "3"
		Break
	EndIf
	//caso passe pela validação do limite de crédito a fase é a inicial
	_cFaseRet := "0"
End Sequence
Return _cFaseRet



/*/{Protheus.doc} XLJLCREDito
localizar loja do cliente que esteja cadastrada com limite de crédito
@param      _cCliFat 	- Codigo do cliente  
@return     _cLoja
@author     DAC Denilso
@version    12.1.17 / Superior
@project	GRUPO CAOA - GAP FIN100 - Campo Matriz Clientes (Revitalização Limite de Crédito)
@since      02/03/2023
/*/
User Function XLJLCREDito(_cCliente)
Local _cLoja		:= ""
Local _cAliasPesq 	:= GetNextAlias()

Begin Sequence
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT ISNULL(SA1.R_E_C_N_O_,0) NREGSA1
		FROM  %Table:SA1% SA1
		WHERE SA1.A1_FILIAL 	= %XFilial:SA1%
			AND SA1.A1_COD  	= %Exp:_cCliente%
			AND SA1.A1_XTPCRED NOT IN ( '0 ',' ') 
			AND SA1.%notDel%
	EndSQL
	(_cAliasPesq)->(DbGotop())	
	If (_cAliasPesq)->(Eof()) .Or. (_cAliasPesq)->NREGSA1 == 0
		Break
	EndIf
	SA1->(DbGoto((_cAliasPesq)->NREGSA1))
	_cLoja := SA1->A1_LOJA
End Sequence
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _cLoja



/*/{Protheus.doc} XFLPESQVSW
Responsável por verificar limite de crédito na liberação
@author 	DAC-Denilso
@since 		15/02/2022
@version 	undefined
@param 		_cNumOrc	- numero orçamento
			_cCliFat	- Cliente Faturamento
			_cLoja		- Loja cliente faturamento
@type 		user function
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@menu       Nao Informado
@return		_cFaseRet - Fase atualizada
@ Obs		
@history    DAC 24/05/2022 - Incluído parametros de entrada na função
/*/
Static Function XFLPESQVSW(_cNumOrc, _cCliFat, _cLojaFat, _lForplan, _aMsg)
	Local _lRet 		:= .T.
	Local _cAliasPesq   := GetNextAlias()     
	Local _nLimite 		:= 1 
	Local _cWhere		:= ""

	Default _aMsg		:= {}
	Default _lForplan	:= .F.

	Begin Sequence
		If _lForplan
			_cWhere := " TRIM(VSW.VSW_ORIGEM) = 'OFIXA016' "
			_cWhere += " AND VSW.VSW_DTHLIB <> ' ' " 

		Else
			_cWhere :=   " TRIM(VSW.VSW_ORIGEM) <> 'OFIXA016' "
		Endif
		_cWhere := "%"+_cWhere+"%"

		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	ISNULL(VSW.R_E_C_N_O_,0) NREGVSW,
					VSW.VSW_VALCRE
			FROM  %Table:VSW% VSW 
			WHERE 	VSW.VSW_FILIAL 	= %xFilial:VSW% 
				AND VSW.VSW_NUMORC 	= %Exp:_cNumOrc%
				AND %Exp:_cWhere%
				AND VSW.%notDel%
		EndSql
	/* CONFORME JC PESQUISAR SOMENTE O NUMERO DO ORÇAMENTO - DAC 27/05/2022
				AND VSW.VSW_CODCLI 	= %Exp:_cCliFat%
				AND VSW.VSW_LOJA 	= %Exp:_cLojaFat%
	*/
			//			AND TRIM(VSW.VSW_ORIGEM) = "U_ZPECF008"  VSW_VALCRE = ou < VS1_VTOTNF (ver arredondamento)

		If (_cAliasPesq)->(Eof())  .or. (_cAliasPesq)->NREGVSW  == 0
			Aadd(_aMsg, "Não localizao registro de liberação Credito para orçamento "+_cNumOrc+" !")
			_lRet := .F.
			Break
		EndIf	
		VSW->(DbGoto( (_cAliasPesq)->NREGVSW ))
		//validar se os valores são os mesmos 10-12 = -2 12-10 =2
		If VSW->VSW_VALCRE == VS1->VS1_VTOTNF
			Aadd(_aMsg, "Liberado credito especial "  +AllTrim(Transform(VSW->VSW_VALCRE, PesqPict( 'VSW' , 'VSW_VALCRE')))+;
						" para o orçamento com valor "+AllTrim(Transform(VS1->VS1_VTOTNF, PesqPict( 'VS1' , 'VS1_VTOTNF')))+" !")
			Break
		//Caso o valor da nota seja menor pode liberar conforme JC DAC 27/05/2022	
		ElseIf 	VSW->VSW_VALCRE > VS1->VS1_VTOTNF
			Aadd(_aMsg, "Liberado credito especial "  +AllTrim(Transform(VSW->VSW_VALCRE, PesqPict( 'VSW' , 'VSW_VALCRE')))+;
						" para o orçamento com valor "+AllTrim(Transform(VS1->VS1_VTOTNF, PesqPict( 'VS1' , 'VS1_VTOTNF')))+" !")
			Break
		Else	
			_nValidaLimite :=  VS1->VS1_VTOTNF - VSW->VSW_VALCRE
			If _nValidaLimite <=  _nLimite 
				Aadd(_aMsg, "Liberado credito especial "  +AllTrim(Transform(VSW->VSW_VALCRE, PesqPict( 'VSW' , 'VSW_VALCRE')))+;
							" para o orçamento com valor "+AllTrim(Transform(VS1->VS1_VTOTNF, PesqPict( 'VS1' , 'VS1_VTOTNF')))+" obedecendo o limite de "+AllTrim(STR(_nLimite))+" !")
				Break
			Endif
			Aadd(_aMsg, "Não Liberado credito especial " + AllTrim(Transform(VSW->VSW_VALCRE, PesqPict( 'VSW' , 'VSW_VALCRE')))+;
						" para o orçamento com valor "	 + AllTrim(Transform(VS1->VS1_VTOTNF, PesqPict( 'VS1' , 'VS1_VTOTNF')))+" valores divergentes !")
			_lRet := .F.
			Break
		EndIf

	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 
Return _lRet	

/*/{Protheus.doc} XFASSEPARA
Responsável por liberar para transferência FASE 4
@author 	DAC-Denilso
@since 		01/11/2021
@version 	undefined
@param 		_cMsg 		- grava dados de retorno 
@type 		user function
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@menu       Nao Informado
@return		_cFaseRet - Fase atualizada
@ Obs		somente liberara para transferência se estiver na fase 0 é necessário passar pelas outras fases 
@history    
/*/
Static Function XFASSEPARA(_cMsg)
	Local _cFaseRet	:= VS1->VS1_STATUS

	Begin Sequence
		If _cFaseRet == "0"  //somente passa a fase para separação se estiver na fase 0
			_cFaseRet := "4"
			Break
			/*
			if VS3->VS3_QTDCON != 0
				lSeparado := .t.
			endif
			*/
		EndIf

	End Sequence
Return _cFaseRet


/*/{Protheus.doc} XOZPECDA
Responsável por Aplicar desconto e ou acrescimo conforme o tipo parametrizado
@author 	DAC-Denilso
@since 		23/11/2021
@version 	undefined
@param 		 
@type 		user function
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@menu       Nao Informado
@return		_lRet 		- Verdadeiro ou falso
@ Obs		
@history    

/*/

/*

//DAC inclementar dados para desconto e acrescimo
Se Tipo pedido == "seguradora" (parâmetro para tipo com desconto) então desconto total = 5% (parâmetro desconto por tipo pedido)
Se Tipo pedido == "Emergencial" (parâmetro para tipo com acréscimo) então acréscimo total = 5% (parâmetro acrescimo por tipo pedido)
[14:41, 22/11/2021] Ze Totvs sigapec: ntão essas nem passaria por validação, são prévios
[14:43, 22/11/2021] Ze Totvs sigapec: um exemplo: 
por acordo, qdo é seguradora, todos os pedidos já possuem esse desconto.
Pedido emergencial, por causa de falta de programação da concessionária, será cobrado um valor extra
[15:09, 22/11/2021] Ze Totvs sigapec: não, aplicaria os 5% sobre a tabela de preços
[15:10, 22/11/2021] Ze Totvs sigapec: então ignoraria o desconto
[15:10, 22/11/2021] Ze Totvs sigapec: aplicaria 5%
*/
User Function XOZPECDA()  
	Local _cTipoPedSeg  := SuperGetMV( "CMV_PEC010"  ,,"005" )   //Parâmetro para indicação de utilização do programa tendo como Default Verdadeiro, não é necessário a criação do mesmo
	Local _cTipoPedEme  := SuperGetMV( "CMV_PEC011"  ,,"003" )   //Parâmetro para indicação de utilização do programa tendo como Default Verdadeiro, não é necessário a criação do mesmo
	Local _lRet			:= .T.

	Begin Sequence
		If AllTrim(VS1->VS1_XTPPED) == AllTrim(_cTipoPedSeg)
			_lRet := XOSEGUDESC()
		ElseIf AllTrim(VS1->VS1_XTPPED) == AllTrim(_cTipoPedEme)
			_lRet := XOEMERGACR()
		EndIf
	End Sequence
Return _lRet	


/*/{Protheus.doc} XOSEGUDESC
Responsável por Aplicar desconto quando o tipo de pedido for Seguradora
@author 	DAC-Denilso
@since 		23/11/2021
@version 	undefined
@param 		 
@type 		user function
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@menu       Nao Informado
@return		_lRet 		- Verdadeiro ou falso
@ Obs		
@history    
/*/
Static Function XOSEGUDESC()
	Local _nPerc 		:= SuperGetMV( "CMV_PEC012"  ,,5 )   //Parâmetro para indicação de utilização do programa tendo como Default Verdadeiro, não é necessário a criação do mesmo
	Local _cAliasPesq	:= GetNextAlias()   
	Local _lRet			:= .T.
	Local _nValorUnit	:= 0
	Local _nTotal		:= 0 
	Begin Sequence
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	VS3.R_E_C_N_O_ AS NREGVS3
			FROM  %Table:VS3% VS3			
			WHERE 	VS3.VS3_FILIAL  = %xFilial:VS3%
				AND VS3.VS3_NUMORC	= %Exp:VS1->VS1_NUMORC% 
				AND VS3.%notDel%
		EndSQL	
		If (_cAliasPesq)->(Eof())
			Aadd(_aMensAglu,"Não encontrado itens para efetuar desconto Seguradora, não foi aplicado desconto !")
			_lRet := .F.
			Break
		EndIf
		While (_cAliasPesq)->(!Eof())
			VS3->(DbGoto((_cAliasPesq)->NREGVS3))
			//Sera aplicadoo direto
			_nValorUnit	:= U_XOFUNVTB(VS1->VS1_CLIFAT, VS1->VS1_LOJA, VS3->VS3_CODITE)
			_nTotal		:= VS3->VS3_QTDITE * _nValorUnit
			If _nValorUnit <= 0
				Aadd(_aMensAglu,"Não encontrado tabela de preço para o item " +VS3->VS3_CODITE+ " para efetuar desconto Seguradora, não foi aplicado desconto !")
				_lRet := .F.
				Break
			EndIf
			RecLock("VS3",.F.)
			VS3->VS3_PERDES := _nPerc
			VS3->VS3_VALPEC := _nValorUnit
			VS3->VS3_VALDES := (_nTotal * VS3->VS3_PERDES /100)
			VS3->VS3_VALTOT := _nTotal - VS3->VS3_VALDES
			VS3->(MsUnlock())
			Aadd(_aMensAglu,"Aplicado desconto "+StrZero(_nPerc,3)+" no produto "+AllTrim(VS3->VS3_CODITE)+" referente Seguradora !")
			(_cAliasPesq)->(DbSkip())
		EndDo	
	End Sequence		
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 
Return _lRet


/*/{Protheus.doc} XOSEGUDESC
Responsável por Aplicar acrescimo quando o tipo de pedido for Emergencial
@author 	DAC-Denilso
@since 		23/11/2021
@version 	undefined
@param 		 
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 
@menu       Nao Informado
@return		_lRet 		- Verdadeiro ou falso
@history    
/*/

Static Function XOEMERGACR()
	Local _nPerc 		:= SuperGetMV( "CMV_PEC013"  ,,5 )   //Parâmetro para indicação de utilização do programa tendo como Default Verdadeiro, não é necessário a criação do mesmo
	Local _cAliasPesq	:= GetNextAlias()   
	Local _lRet			:= .T.
	Local _nValorUnit	:= 0
	Local _nTotal		:= 0 
	Begin Sequence
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	VS3.R_E_C_N_O_ AS NREGVS3
			FROM  %Table:VS3% VS3			
			WHERE 	VS3.VS3_FILIAL  = %xFilial:VS3%
				AND VS3.VS3_NUMORC	= %Exp:VS1->VS1_NUMORC% 
				AND VS3.%notDel%
		EndSQL	
		If (_cAliasPesq)->(Eof())
			Aadd(_aMensAglu,"Não encontrado itens para efetuar acréscimo Emergencial, não foi aplicado acréscimo !")
			_lRet := .F.
			Break
		EndIf
		While (_cAliasPesq)->(!Eof())
			VS3->(DbGoto((_cAliasPesq)->NREGVS3))
			//Sera aplicadoo direto
			_nValorUnit	:= U_XOFUNVTB(VS1->VS1_CLIFAT, VS1->VS1_LOJA, VS3->VS3_CODITE)
			If _nValorUnit <= 0
				Aadd(_aMensAglu,"Não encontrado tabela de preço para o item " +VS3->VS3_CODITE+ " para efetuar acréscimo Emergencial, não foi aplicado acréscimo !")
				_lRet := .F.
				Break
			EndIf
			RecLock("VS3",.F.)
			_nValorUnit		:= _nValorUnit * (1+(_nPerc / 100))
			_nTotal			:= VS3->VS3_QTDITE * _nValorUnit 
			//---DAC Verificar a necessidade de se criar campo para percentual e valor de acrescimo na VS3
			VS3->VS3_VALPEC :=  _nValorUnit
			//---DAC verificar se podera dar desconto quando temos um acréscimo
			If VS3->VS3_PERDES > 0
				VS3->VS3_VALDES := (_nTotal * VS3->VS3_PERDES /100)
				VS3->VS3_VALTOT := _nTotal - VS3->VS3_VALDES
			Else 
				VS3->VS3_VALTOT := _nTotal 
			EndIf
			VS3->(MsUnlock())
			Aadd(_aMensAglu,"Aplicado acréscimo "+StrZero(_nPerc,3)+" no produto "+AllTrim(VS3->VS3_CODITE)+" referente Emergencial !")
			(_cAliasPesq)->(DbSkip())
		EndDo	
	End Sequence		
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 
Return _lRet

/*/{Protheus.doc} XGERPIK2
Responsável por Gerar numeração de picking antes de enviar para RGLOG
@author 	DAC-Denilso
@since 		14/06/2022
@version 	undefined
@param 		 
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 		Não atualizar data de envio do picking a mesma será o controle do envio
			Substitui a funcionalidade XGERAPIK
@menu       Nao Informado
@return		_lRet 		- Verdadeiro ou falso
@history	14/06/2022 DAC 	- Alterado para receber os registros do VS1 e gravar após processamento do ZPECF008 não ira esperar acumular     
/*/
User Function XGERPIK2(_aVS1 )
	Local _lRet			:= .T.
	Local _cMarca		:= ""
	Local _cPicking     := ""
	Local _cObsMenNF	:= ""
	Local _cObs			:= ""
	Local _aMsg			:= {}
	Local _nRegVS1		:= VS1->(Recno())
	Local _nPos
	Local _cPickNovo

	Default _aVS1 		:= {}  

	Begin Sequence
	//Validar se foi enviado numero registros VS1
		If Len(_aVS1) == 0
			_lRet := .F.
			Break
		Endif
		//Prepara o numero do picking
		//_cPicking 		:= GETSX8NUM("SZK","ZK_XPICKI")  //alinhado com JC no momento não controlar para o SZK deixar como estava
		_cPicking 	:= GETSX8NUM("VS1","VS1_XPICKI")
		VS1->(ConfirmSx8())
		_cPickNovo	:= U_XVERNUMeracao("SZK", "ZK_XPICKI", _cPicking )
		If AllTrim(_cPicking) <> AllTrim(_cPickNovo)
			AAdd(_aMsg,"ATENCAO [XGERPIK2]")
			AAdd(_aMsg,"- NUMERACAO AUTOMATICA DO PICKING "  +_cPicking+" ESTA APRESENTANDO PROBLEMAS  !")
			AAdd(_aMsg,"- ASSUMIDO NUMERACAO PARA O PICKING "+_cPickNovo+" AJUSTAR NUMERACAO AUTOMATICA !")
			_cPicking := _cPickNovo
		Endif
		//Garatir que ira gravar todo agrupamento
		Begin Transaction
			For _nPos := 1 To Len(_aVS1)
				VS1->(DbGoto(_aVS1[_nPos]))
				_cObsMenNF	+=	AllTrim(VS1->VS1_MENNOT)
				_cObsMenNF	+=  " "
				//Gravar Picking na VS3 - Itens
				VS3->(dbSetOrder(1))	//VS3_FILIAL+VS3_NUMORC+VS3_SEQUEN
				If !VS3->(MsSeek(xFilial("VS3")+VS1->VS1_NUMORC))
					AAdd(_aMsg,"NÃO LOCALIZADO ITENS (VS3) PARA O ORÇAMENTO "+VS1->VS1_NUMORC+", NÃO FOI GRAVADO PICKING ")
					_lRet := .F.
					Exit  //sair do loop
				Endif	
				//em caso de erro abortar o next
				While VS3->( !Eof() ) .and. VS3->VS3_FILIAL ==  VS1->VS1_FILIAL .AND. VS3->VS3_NUMORC = VS1->VS1_NUMORC  //_aNumOrc[_nPos,1])
					VS3->(RecLock("VS3",.F.))
					VS3->VS3_XPICKI	:=	_cPicking
					VS3->VS3_XAGLU	:=	VS1->VS1_XAGLU  
					VS3->VS3_XDTAGL	:=	VS1->VS1_XDTAGL
					VS3->VS3_XHSAGL	:=	VS1->VS1_XHSAGL
					VS3->VS3_XUSUGL	:=	VS1->VS1_XUSUGL
					VS3->(MsUnlock())
					VS3->(dbSkip())
				EndDo
				//Conforme solicitação Evandro guardo marca para gravar em SZK DAC-01/06/2022
				If !Empty(VS1->VS1_XMARCA)
					_cMarca := VS1->VS1_XMARCA
				EndIf
			Next _nPos
			//Após Gravar VS1 criar um SZK
			If _lRet .And. !U_ZPEC11GSZK( /*_oJson*/, .T., _cPicking, _cObsMenNF, _cMarca, /*_lIncon*/  )  //Gravar  registro inicial no SZK
				_lRet := .F.			
			EndIf
			If _lRet 
				AAdd(_aMsg,"CRIADO PICKING "+ _cPicking +" EM "+DtoC(Date())+" "+SubsTr(Time(),1,5))		
				VS1->(ConfirmSx8())
			Else
				Disarmtransaction()
			EndIf
		End Transaction	
	End Sequence
	//Gravo as informações do VS1
	_cObs := If( _lRet, "GERADO NUMERO PICKING ", "NÃO FOI GERADO PICKING ")+_cPicking 
	For _nPos := 1 To Len(_aMsg)
		_cObs	+= _aMsg[_nPos] + CRLF  
	Next
	For _nPos := 1 To Len(_aVS1)
		VS1->(DbGoto(_aVS1[_nPos]))
		VS1->(RecLock("VS1",.F.))
		VS1->VS1_XPICKI := _cPicking
		VS1->VS1_OBSAGL	:=  _cObs + CRLF  + AllTrim(VS1->VS1_OBSAGL) 
		//Não gravar as data para ser gravada somente quando enviado na RGLOG
		If Empty(VS1->VS1_XMARCA)
			VS1->VS1_XMARCA := _cMarca
		EndIf
		VS1->(MsUnlock())
		//VS1->VS1_XDTEPI	:= Date() 
		//VS1->VS1_XHSPIC 	:= Time()
		//VS1->VS1_XUSUPI 	:= RetCodUsr()
	Next	
	//ocorreu erro deixar picking zerado
	If !_lRet 
		_cPicking  := ""	
	EndIf 	
	VS1->(DbGoto(_nRegVS1))  //reposicionar VS1 DAC 20/06/2022	
Return _cPicking 


//
/*/{Protheus.doc} ZPEC11GSZK
Responsável por Gravar tabela para geração de pesos notas fiscais
@author 	DAC-Denilso
@since 		11/02/2022
@version 	undefined
@param 		 
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs 
@menu       Nao Informado
@return		_lRet 		- Verdadeiro ou falso
@history    DAC - 01/06/2022 - Gravar SZK->ZK_XMARCA na inclusão do picking  
/*/
User Function ZPEC11GSZK(_oJson, _lGravaIni, _cPicking, _cObsMenNF, _cMarca, _lIncon)
	Local _lRet			:= .F.
	Local _lGrava		:= .F.
	Local _cUsuario		:= SuperGetMV( "CMV_WSR015"  ,,"RG LOG" ) 
	Local _cAliasPesq 	:= GetNextAlias()
	Local _cLocal       := ""

	//Local _cPicking
	Local _nSeqReg
	Local _nTam
	Local _nPos
	Local _cSerieNF
	Local _cUf
	Local _cJson

	Default _lGravaIni 	:= .F.
	Default _lIncon		:= .F.
	Default _cPicking	:= ""
	Default _cObsMenNF	:= ""
	Default _cMarca		:= ""


	Begin Sequence
		//indicar o local ao qual sera guardado no SZK referente a FDR DAC 06/02/2023
		VS3->(DbSetOrder(1))
		If SZK->(FieldPos("ZK_LOCAL")) > 0 .and. VS3->(DbSeek(XFilial("VS3")+VS1->VS1_NUMORC))
			_cLocal := VS3->VS3_LOCAL
		Endif

		_cUf := POSICIONE("SA1",1,xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA,"A1_EST")
		//ZK_FILIAL+ZK_XPICKI+ZK_SEQREG
		//Caso tenha enviado para RG LOG gravar dados iniciais conforme solicitado por Zé 08/02/2022 DAC 11/02/2022
		If _lGravaIni  
			//garante que irá gravar somente um registro
			_nSeqReg	:= 1
			BeginSql Alias _cAliasPesq
				SELECT 	SZK.R_E_C_N_O_ NREGSZK
				FROM %table:SZK% SZK
				WHERE 	SZK.ZK_FILIAL  	= %XFilial:SZK%
					AND SZK.ZK_XPICKI  	= %Exp:_cPicking%
					AND SZK.ZK_SEQREG  	= %Exp:_nSeqReg%
					AND SZK.%notDel%		  
			EndSql      
			//SE NÃO ACHAR INCLUI
			If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGSZK == 0	
				_lGrava 	:= .T.
			Else
				_lGrava 	:= .F.
				SZK->(DbGoto((_cAliasPesq)->NREGSZK))
			EndIf	
			If SZK->(RecLock("SZK", _lGrava ))
				SZK->ZK_FILIAL	:= XFilial("SZK") 
				SZK->ZK_XPICKI 	:= 	_cPicking	//AllTrim(_oJson["nu_pedidoorigem"][1]:GetJsonText("nu_pedido")) //"00000510"
				SZK->ZK_SEQREG 	:=	_nSeqReg	//Val(_oJson["nu_pedidoorigem"][1]:GetJsonText("vol_sequencia"))
				//Não gravar na criação do picking somente quando recebo o picking DAC 11/07/2022
				//SZK->ZK_DTRECPI	:= 	Date()
				//SZK->ZK_HSRECPI	:= 	SubStr( Time(), 1, TamSX3("ZK_HSRECPI")[1] )
				//SZK->ZK_USURECP	:= 	RetCodUsr()
				If SZK->(FieldPos("ZK_DTGERPI")) > 0
					SZK->ZK_DTGERPI		:= Date()
				EndIf	
				If SZK->(FieldPos("ZK_HSGERPI")) > 0
					SZK->ZK_HSGERPI		:= SubStr( Time(), 1, TamSX3("ZK_HSRECPI")[1] )
				EndIf	
				If SZK->(FieldPos("ZK_USGERPI")) > 0
					SZK->ZK_USGERPI		:= 	RetCodUsr()
				EndIF	
				//GRAVAR ZK_MENNOT COM NUMERO DO PICKING
				SZK->ZK_MENNOT	:= SubStr(Upper(AllTrim(_cObsMenNF)), 1, TamSX3("ZK_MENNOT")[1])
				SZK->ZK_UF      := _cUF   
				//Confome solicitação Evandro gravar marca DAC - 01/06/2022         
				If !Empty(_cMarca)
					If SZK->(FieldPos("ZK_XMARCA")) > 0
						SZK->ZK_XMARCA := _cMarca
					Endif	
				Endif                                            
				//Caso seja somente para gravar inicial posso sair
				If SZK->(FieldPos("ZK_STATUS")) > 0   //N=Nao Envidado;E=Enviado;F=Faturado;C=Cancelado
					SZK->ZK_STATUS := "A"
				EndIf				
				//Indicação do armazém que esta direcionado o SZK
				If SZK->(FieldPos("ZK_LOCAL")) > 0
					SZK->ZK_LOCAL		:= _cLocal
				EndIf	
				
				SZK->(MsUnlock())
				_lRet := .T.			
				Break
			EndIf
		Endif

		_cJson 	:= _oJson:toJSON()
		_cJson 	:= EncodeUTF8( _cJson )
		_nTam  := Len(_oJson["nu_pedidoorigem"])      //Contador de Registros Itens no Json p/ criar SZK 
		For _nPos := 1 To _nTam
			If Select(_cAliasPesq) <> 0
				(_cAliasPesq)->(DbCloseArea())
			Endif  
			_cPicking 	:= AllTrim(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("nu_pedido"))
			_nSeqReg	:= Val(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("vol_sequencia"))
			BeginSql Alias _cAliasPesq
				SELECT 	SZK.R_E_C_N_O_ NREGSZK
				FROM %table:SZK% SZK
				WHERE 	SZK.ZK_FILIAL  	= %XFilial:SZK%
					AND SZK.ZK_XPICKI  	= %Exp:_cPicking%
					AND SZK.ZK_SEQREG  	= %Exp:_nSeqReg%
					AND SZK.%notDel%		  
			EndSql      
			//SE NÃO ACHAR INCLUI
			If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGSZK == 0	
				_lGrava 	:= .T.
			Else
				_lGrava 	:= .F.
				SZK->(DbGoto((_cAliasPesq)->NREGSZK))
			EndIf
			//localizar a marca no vs1 para gravar
			_cMarca	:= ZP11PMARCA(_cPicking)
		
			If SZK->(RecLock("SZK", _lGrava ))
				_cSerieNF := AllTrim(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("nu_serie_produto"))
				//Colocar NSERIE somente quando preenchido DAC 22/03/2022
				If !Empty(_cSerieNF)
					_cSerieNF := "NSERIE: "+_cSerieNF
				Else 
					_cSerieNF := ""			
				EndIf	
				SZK->ZK_FILIAL	:=  XFilial("SZK") 
				SZK->ZK_XPICKI 	:= 	AllTrim(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("nu_pedido")) //"00000510"
				SZK->ZK_SEQREG 	:=	Val(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("vol_sequencia"))
				SZK->ZK_STREG   :=	AllTrim(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("cd_situacao"))
				SZK->ZK_BARCOD 	:=	AllTrim(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("vol_barcode"))
				//SZK->ZK_MENNOT 	:= 	SubStr(AllTrim(SZK->ZK_MENNOT)+" NSERIE: "+Upper(AllTrim(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("nu_serie_produto"))) ,1 ,TamSX3("ZK_MENNOT")[1])
				SZK->ZK_MENNOT 	:= 	SubStr(AllTrim(SZK->ZK_MENNOT)+" "+_cSerieNF ,1 ,TamSX3("ZK_MENNOT")[1])
				SZK->ZK_OBSCON 	:= 	Upper(AllTrim(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("ds_observacao")))
				SZK->ZK_VLQTOT 	:=	Val(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("vol_qtde_total"))
				SZK->ZK_VLCOMP 	:=	Val(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("vol_comprimento"))
				SZK->ZK_VLLARG 	:=	Val(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("vol_largura"))
				SZK->ZK_VLALT  	:=	Val(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("vol_altura"))
				SZK->ZK_PLIQUI 	:=	Val(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("vol_pesoliquido"))
				SZK->ZK_PBRUTO 	:=	Val(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("ps_volume"))
				SZK->ZK_XPESOC 	:=	Val(_oJson["nu_pedidoorigem"][_nPos]:GetJsonText("vl_cubagem"))
				SZK->ZK_UF      :=  _cUF  
				SZK->ZK_DTRECPI	:= 	Date()
				SZK->ZK_HSRECPI	:= 	SubStr( Time(), 1, TamSX3("ZK_HSRECPI")[1] )
				SZK->ZK_USURECP	:= 	_cUsuario
				If !Empty(_cMarca)
					If SZK->(FieldPos("ZK_XMARCA")) > 0
						SZK->ZK_XMARCA := _cMarca
					Endif	
				Endif           
				//Gravar REST recebido
				//GRAVAR SZK JSON E DATA
				//Gravar no SZK o Json
				//DAC 09/06/2022
				If SZK->(FieldPos("ZK_XJSREC")) > 0
					SZK->ZK_XJSREC := _cJson
				EndIf	
				If SZK->(FieldPos("ZK_XJSDTRE")) > 0
					SZK->ZK_XJSDTRE := Date()
				EndIf	
				If SZK->(FieldPos("ZK_XJSHSRE")) > 0
					SZK->ZK_XJSHSRE := Time()
				Endif	
				If SZK->(FieldPos("ZK_XJSSTRE")) > 0
					SZK->ZK_XJSSTRE := If(!_lIncon,"1","3") //1=RECEBIDO;2=NAO RECEBIDO;3=INCONSISTENCIA                                                                                      
				EndIf
				//implementado status DAC 05/07/2022
				If SZK->(FieldPos("ZK_STATUS")) > 0   //N=Nao Envidado;E=Enviado;F=Faturado;C=Cancelado
					SZK->ZK_STATUS := "E"
				EndIf				
				//Indicação do armazém que esta direcionado o SZK
				If SZK->(FieldPos("ZK_LOCAL")) > 0
					SZK->ZK_LOCAL		:= _cLocal
				EndIf	
				SZK->(MsUnlock())
				_lRet := .T.			
				//Guardo o primeiro registro somente nele que será gravado a obs
				//If SZK->ZK_SEQREG  == 1
				//	_nRegSZK := SZK->(Recno())
				//EndIf
			EndIf
			(_cAliasPesq)->(DbCloseArea())
		Next	
	End Sequence
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif  
Return _lRet

//Localizar VS1 baseado no picking para retornar a marca
Static Function ZP11PMARCA(_cPicking)
	Local _cAliasPesq 	:= GetNextAlias()
	Local _cMarca		:= ""

	BeginSql Alias _cAliasPesq
		SELECT 	VS1.VS1_XMARCA 
		FROM %table:VS1% VS1
		WHERE 	VS1.VS1_FILIAL 	= %XFilial:VS1%
			AND	VS1.VS1_XPICKI 	= %Exp:_cPicking%
			AND VS1.VS1_XMARCA 	<> ' '
			AND VS1.%notDel%
		GROUP BY VS1.VS1_XMARCA
	EndSql      
	If (_cAliasPesq)->(!Eof())
		_cMarca := (_cAliasPesq)->VS1_XMARCA
	EndIf	
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif  
Return _cMarca 


/*/{Protheus.doc} ORCCALFIS
Responsável por Calcular imposto orçamento
@author 	DAC-Denilso
@since 		11/03/2022
@version 	undefined
@param 		 
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs		função para calculo fiscal orçamentos, importação AW, clonagem, orçamento parcial customizados 
@menu       Nao Informado
@return		_lRet 		- Verdadeiro ou falso
@history    
/*/

User Function ORCCALFIS(_cNumOrc,_lAtuaPreco)
	Local _lRet 	:= .T.
	Local _nRegVS1  := VS1->(Recno())
	Local _nRegVS1P := VS1->(Recno())
	Local _nRegVS3P := VS3->(Recno())
	Local _aArea 	:= GetArea()

	Default _cNumOrc	:= ""
	Default _lAtuaPreco	:= .T.  //atualiza preço unitario do produto

	Private cVS1Status  := "0"
	Private cStatus		:= "0"

	Begin Sequence
		If Type("_aMensAglu") <> "A"
			Private _aMensAglu := {}
		EndIf

		ConOut("ORCCALFIS - ZPECFUNA "+DtOS(Date())+" "+Time())
		DBSELECTAREA("VS1")
		//Caso seja enviado o orçamento posicionar
		If !Empty(_cNumOrc)
			If AllTrim(_cNumOrc) <> AllTrim(VS1->VS1_NUMORC)
				If !VS1->(MsSeek(XFilial("VS1")+_cNumOrc))
					Aadd(_aMensAglu,"Não localizada Orçamento  " +_cNumOrc+ " ORCCALFIS.")
					_lRet := .F.
					Break
				EndIf
				_nRegVS1  := VS1->(Recno())
			EndIf	
		EndIF
		_lRet := XCALCORCImposto(_nRegVS1, _lAtuaPreco)
	End Sequence
	VS1->(DbGoto(_nRegVS1P))
	If _nRegVS3P > 0
		VS3->(DbGoto(_nRegVS3P))
	EndIf
	RestArea(_aArea)
Return _lRet	

/*/{Protheus.doc} XCALCORCImposto
Responsável por Calcular imposto orçamento
@author 	DAC-Denilso
@since 		08/04/2022
@version 	undefined
@param 		 
@project    MIT044-GAP_PECCD07-08-09 Aglutinar  V3
@type 		user function
@obs		Função para calculo fiscal orçamentos, importação AW, clonagem, orçamento parcial customizados 
			Esta funcionalidade foi criada para chamar funcionalidades do Padrão, porém as mesmas possuem 
			variaveis e objetos que devem ser criados podendo se perder no deorrer do código, além disto possui referências 
			a fontes do padrão não permitindo algumas calidações. O tratamento do imposto acabou sendo simplificado e não
			foi retirado algumas informações para o caso da necessidade de chamar novamente oalguma função do Padrão
@menu       Nao Informado
@return		_lRet 		- Verdadeiro ou falso
@history    
/*/

Static Function XCALCORCImposto(_nRegVS1, _lAtuaPreco)
	Local aColsP		:= {}
	Local _aVS3Reg		:= {}
	Local nOpc			:= 4
	Local _lRet			:= .T.
	Local _cAliasPesq	:= GetNextAlias()   

	Local _nValorUnit
	Local _nValTotIt
	Local _nvaldes 
	Local _nTotLiq 
	Local _nPos
	Local _cCodTes
	Local _cTipoOper

	Default lLibPV 		:= .f.
	Default _lAtuaPreco	:= .T.

	Private aHeaderP 		:= {}
	Private	aAutoPecas 		:= {}
	Private	aAutoServ   	:= {}
	Private	aAutoCab    	:= {}
	Private	aAutoInco   	:= {}
	Private LOX001AUTO		:= .T.
	Private n				:= 0
	Private  lFuncOM030GRUSRV := FindFunction("OM030GRUSRV")

	Private lMsHelpAuto     := .T. // Se .T. direciona as mensagens de help para o arq. de log
	Private lMsErroAuto     := .F.
	Private lAutoErrNoFile  := .T. // Precisa estar como .T. para GetAutoGRLog() retornar o array com erros
	Private lPediVenda 		:= .f.
	Private lCancParc 		:= .f.
	Private lAltPedVda 		:= .f.
	Private lPVP 			:= .f.
	Private lCancelPVP 		:= .f.
	Private lFaturaPVP 		:= .f.
	Private oPedido 		:= DMS_Pedido():New()
	Private oSqlHlp 		:= DMS_SqlHelper():New()
	Private oDpm    		:= DMS_Dpm():New()
	Private aNATrf  		:= {}
	//
	Private nMaxItNF  		:= GetMv("MV_NUMITEN")
	Private lAprMsg   		:= GetNewPar("MV_MIL0151",.T.)
	//
	Private lMsg0268 		:= .f. // Controle de Msg de Pedido Gravado
	Private cVK_F 			:= {}
	//
	Private aOrc    		:= {}
	Private aSugest 		:= {}
	Private aIncBot 		:= {}

	Private oGetPecas 		:= AutoGD():new()
	Private oGetInconv 		:= AutoGD():new()
	Private oGetServ 		:= AutoGD():new()

	//

	Begin Sequence

		If Type("_aMensAglu") <> "A"
			Private _aMensAglu := {}
		EndIf
		SX3->(DbSetOrder(1))
		SX3->(MsSeek("VS3"))
		While !SX3->(Eof()) .And.(SX3->x3_arquivo=="VS3")
			If  X3USO(SX3->x3_usado)  //.and. If(Alltrim(SX3->x3_campo) == "VS3_MARLUC",.t.,.f.) 
				Aadd(aHeaderP,{	AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
								SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,X3CBOX(),SX3->X3_RELACAO})
				If (Alltrim(SX3->x3_campo) == "VS3_MARLUC" .and. cNivel < SX3->x3_nivel)
					aHeaderP[Len(aHeaderP),3] := repl("*",TamSx3("VS3_MARLUC")[1])
				Endif
			EndIf
			SX3->(DbSkip())
		EndDo

		// Cria aCols : Na inclusão cria-se uma linha em branco com os inicializadores padrão...
		If Len(aColsP) == 0
			_nTam := Len(aHeaderP)
			_aItens := {}

			BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
				SELECT 	VS3.R_E_C_N_O_ AS NREGVS3
				FROM  %Table:VS3% VS3			
				WHERE 	VS3.VS3_FILIAL  = %xFilial:VS3%
					AND VS3.VS3_NUMORC	= %Exp:VS1->VS1_NUMORC% 
					AND VS3.%notDel%
			EndSQL	
			If (_cAliasPesq)->(Eof())
				Aadd(_aMensAglu,"Não encontrado itens do orçamento "+VS1->VS1_NUMORC+" para efetuar recalculo de impostos  !")
				_lRet := .F.
				Break
			EndIf
			_aVS3Reg := {}
			While (_cAliasPesq)->(!Eof())
				VS3->(DbGoto((_cAliasPesq)->NREGVS3))
				VS3->(RecLock("VS3",.f.))
				//Conforme JC caso a TES não esteja preenchida ajustar a TES, pois o fiscal pode necessitar de informar TES diferenciada DAC 21/07/2022
				_cTipoOper := VS3->VS3_OPER 
				If Empty(_cTipoOper)
					_cTipoOper := U_zTpOper( VS1->VS1_CLIFAT, VS1->VS1_LOJA, VS1->VS1_XTPPED )
					VS3->VS3_OPER	:= _cTipoOper
				Endif
				//Alterado conforme J.C. tem que processar TES devido a PE's a serem executados DAC 11/08/2022
				//Devido ao caso de corte no meufatura, onde pode alterar a TES não é viavel alterar aqui pois pode ser uma TES de transferência por exemplo alinhado com J.C. DAC 12/08/2022
				If Empty(VS3->VS3_CODTES)	
					_cCodTes := MaTesInt(2, _cTipoOper, VS1->VS1_CLIFAT, VS1->VS1_LOJA, "C", VS3->VS3_CODITE, /*"VS3_CODTES"*/)
					Aadd(_aMensAglu,"Não localizada TES para o item " +VS3->VS3_CODITE+ " para efetuar clonagem do item orçamento, mantido valor original ")
					//_lRet := .F.
					//Break
					VS3->VS3_CODTES := _cCodTes
					VS3->VS3_SITTRI := U_XFUNSITT(_cCodTes, VS3->VS3_CODITE, VS3->VS3_GRUITE)				
					_lAtuaPreco		:= .T.  //por mudar a TES deve atualizar preço
				EndIf
				//Atualizar valor unitário do produto
				If _lAtuaPreco
					_nValorUnit	:= U_XOFUNVTB(VS1->VS1_CLIFAT, VS1->VS1_LOJA, VS3->VS3_CODITE)
					If _nValorUnit <= 0
						Aadd(_aMensAglu,"Não encontrado tabela de preço para o item " +VS3->VS3_CODITE+ " para efetuar clonagem do item orçamento, mantido valor original ")
						_nValorUnit := VS3->VS3_VALPEC
					EndIf
				Endif
				//somente atualizar valores caso estejam diferentes // Retirado de lAtuaPreco para corrigir erros no Faturamento no VS3_VALTOT 
				If (_nValorUnit > 0 .and. _nValorUnit <> VS3->VS3_VALPEC) .or. VS3->VS3_VALTOT <> ((VS3->VS3_VALPEC*VS3->VS3_QTDITE) - VS3->VS3_VALDES) //.and. VS3->(RecLock("VS3",.F.))
					VS3->VS3_VALPEC 	:= _nValorUnit //_nPRC_TAB    //Val(_oJson["itens"][_nPos]:GetJsonText("vlPeca"))
					_nValTotIt			:= VS3->VS3_VALPEC * VS3->VS3_QTDITE  //Round((_nPRC_TAB * VS3->VS3_QTDITE),2)        //Round((VS3->VS3_VALPEC * VS3->VS3_QTDITE),2)
					If VS3->VS3_PERDES > 0
						VS3->VS3_VALDES := _nValTotIt * (VS3->VS3_PERDES/100)  
						_nvaldes 		:=  _nValTotIt * (VS3->VS3_PERDES/100)
					Else
						VS3->VS3_VALDES := 0
						_nvaldes		:= 0
					Endif	
					VS3->VS3_VALTOT := (VS3->VS3_VALPEC*VS3->VS3_QTDITE) - VS3->VS3_VALDES
					//necessario esta linha devido as casas decimais do valor liquido
					_nTotLiq 		:= Round(((VS3->VS3_VALPEC*VS3->VS3_QTDITE) - _nvaldes )/VS3->VS3_QTDITE,TamSx3("VS3_VALLIQ")[2])
					VS3->VS3_VALLIQ := _nTotLiq //VS3->VS3_VALTOT / VS3->VS3_QTDITE
				Endif
				VS3->(MsUnLock())
				_aIt 	:= {}	
				For _nPos := 1 To Len(aHeaderP)
					_nPosCmp := VS3->(FieldPos(AllTrim(aHeaderP[_nPos,2])))
					If _nPosCmp > 0
						Aadd( _aIt, VS3->(FieldGet(_nPosCmp)) )
					Else
						Aadd( _aIt, "" )
					EnDif	   
				Next   
				AAdd(_aIt,VS3->(RecNo()))
				Aadd(_aIt,.F.)	
				Aadd(_aItens,_aIt)
				Aadd(_aVS3Reg,(_cAliasPesq)->NREGVS3)
				(_cAliasPesq)->(DbSkip())
			EndDo
			aColsP := Aclone(_aItens)
		Endif
		aHeader := {}
		/*
		aAdd(aHeader,{"Artigo","C6_COD","@!",TamSx3("B1_COD")[1],TamSx3("B1_COD")[2],"","","C","TRB",""}) // Artigo
		aAdd(aHeader,{"Quantidade","C6_QUANT","@!",TamSx3("D2_QUANT")[1],TamSx3("D2_QUANT")[2],"","","N","TRB",""}) // Quantidade
		aAdd(aHeader,{"Preço Unit","C6_PRCVEN","@!",TamSx3("D2_PRCVEN")[1],TamSx3("D2_PRCVEN")[2],"","","N","TRB",""}) // Preço Unit
		aAdd(aHeader,{"Valor Merc","C6_VALMERC","@!",TamSx3("D2_PRCVEN")[1],TamSx3("D2_PRCVEN")[2],"","","N","TRB",""}) // Valor Merc
		aAdd(aHeader,{"Desconto","C6_DESCON","@!",TamSx3("D2_DESCON")[1],TamSx3("D2_DESCON")[2],"","","N","TRB",""}) // Desconto
		aAdd(aHeader,{"TES","C6_CODTES","@!",TamSx3("D2_TES")[1],TamSx3("D2_TES")[2],"","","C","TRB",""}) // TES
		aAdd(aHeader,{"Lote","C6_LOTE","@!",TamSx3("C6_LOTECTL")[1],TamSx3("C6_LOTECTL")[2],"","","C","TRB",""}) // TES
		aAdd(aHeader,{"Validade","C6_DTVALID","@!",TamSx3("C6_DTVALID")[1],TamSx3("C6_DTVALID")[2],"","","D","TRB",""}) // TES
		*/
		aCols := {}

		// inicializa os objetos de compatibilização
		// Salva o aCols atual do fiscal
		aHeaderF 	:= aClone(aHeader)
		aColsF   	:= aClone(aCols)
		// Replica as informações da acols de pecas e chama a função
		aHeader 	:= aClone(aHeaderP)
		aCols 		:= Aclone(aColsP)  
		//EnchAuto("VS1",aAutoCab)

		VISUALIZA := ( nOpc == 2 )
		INCLUI 	  := ( nOpc == 3 )
		ALTERA 	  := ( nOpc == 4 )
		EXCLUI 	  := ( nOpc == 5 )
		FECHA  	  := ( nOpc == 6 )
		_lRet := XOX001RecFis("NF_TPCLIFOR", M->VS1_TIPCLI, "OX001LVS34", _nRegVS1, _aVS3Reg) // Recalcula o Fiscal assim que entra no Orçamento
	End Sequence
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif  
	VS1->(DbGoto(_nRegVS1))  //reposicionar VS1 DAC 20/06/2022	

Return _lRet


//Recalcular os valores de impostos
Static Function XOX001RecFis(cReferencia, xValor, cChamadoPor, _nRegVS1, _aVS3Reg)
	Local _lRet			:= .T.
	Local ny
	Local nItem         := 0 // variável criada para não dar erro no loop quando o parâmetro MV_MIl0011 == "1"
	Local aArea         := GetArea()
	//Local lAltValorPeca := GetNewPar("MV_MIL0117","S") <> "N" 
	Local _aCmpFis		:= {}
	Local _cValid	
	Local _nPosRef 		
	Local _cRefCols	
	Local _nPos

	Default cChamadoPor := ""

	Private aNumP 		:= {}		  									// Controle do Fiscal para aCols de Pecas
	Private aNumS 		:= {}											// Controle do Fiscal para aCols de Servicos
	Private nTotFis 	:= 0											// Numero total de itens do Fiscal (pecas + servicos)
	Private bRefresh 	:= { || .t. } 									// Variavel necessaria ao MAFISREF
	Private aCodErro 	:= {"",""}										// Variavel de Codigo de Erro na Importacao de OS
	Private aItensNImp 	:= {}											// Variavel de retorno de importacao de pecas p/ O.S.
	Private lJaPerg 	:= .t. 											// Variavel necessaria ao OFIOC040

	Begin Sequence
		VS1->(DbGoto(_nRegVS1))
		RegToMemory("VS1",.F.,.F.,.F.)
		MaFisIni(VS1->VS1_CLIFAT,VS1->VS1_LOJA,'C','N',IIF(!Empty(VS1->VS1_TIPCLI),VS1->VS1_TIPCLI,SA1->A1_TIPO),MaFisRelImp("OF110",{"VS1","VS3"}))
		If MaFisFound("NF").And. !(MaFisRet(,cReferencia)==xValor)
			MaFisRef(cReferencia,,xValor)
		EndIf
		oGetPecas:aCols := aCols
		For ny := 1 to Len(oGetPecas:aCols)
			if oGetPecas:aCols[ny,Len(oGetPecas:aCols[ny])] //.and. !Empty(oGetPecas:aCols[ny,FG_POSVAR("VS3_CODITE","aHeaderP")])
				Loop
			Endif	
			nTotFis ++
			aAdd(aNumP,{ny,nTotFis})
			nItem += 1
			n := aNumP[nItem,2]

			VS3->(DbGoto( oGetPecas:aCols[ny,Len(oGetPecas:aCols[ny])-1] ))
			RegToMemory("VS3",.F.,.F.,.F.)

			//
			cACodGrp := VS3->VS3_GRUITE //oGetPecas:aCols[ny,FG_POSVAR("VS3_GRUITE","aHeaderP")]
			cACodIte := VS3->VS3_CODITE //oGetPecas:aCols[ny,FG_POSVAR("VS3_CODITE","aHeaderP")]
			//
			SF4->(DBSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+VS3->VS3_CODTES)) //oGetPecas:aCols[ny,FG_POSVAR("VS3_CODTES","aHeaderP")]))

			DBSelectArea("SB1")
			SB1->(DBSetOrder(7))
			SB1->(MsSeek(xFilial("SB1")+cACodGrp+cACodIte))

			_cSitTrib := SubsTr(SB1->B1_ORIGEM,1,1)+SubsTr(SF4->F4_SITTRIB,1,2)

			MaFisIniLoad(n,{SB1->B1_COD,;
							VS3->VS3_CODTES ,;//oGetPecas:aCols[ny,FG_POSVAR("VS3_CODTES","aHeaderP")],;
							" "  ,;
							VS3->VS3_QTDITE ,;  //oGetPecas:aCols[ny,FG_POSVAR("VS3_QTDITE","aHeaderP")],;
							"",;
							"",;
							SB1->(RecNo()),;	//IT_RECNOSB1
							SF4->(RecNo()),;	//IT_RECNOSF4
							0 }) 				//IT_RECORI

			MaFisLoad("IT_PRODUTO"	,SB1->B1_COD,n)
			MaFisLoad("IT_QUANT"	,VS3->VS3_QTDITE,n) 	//oGetPecas:aCols[ny,FG_POSVAR("VS3_QTDITE"	,"aHeaderP")],n)
			MaFisLoad("IT_TES"		,VS3->VS3_CODTES,n) 	//oGetPecas:aCols[ny,FG_POSVAR("VS3_CODTES"	,"aHeaderP")],n)
			MaFisLoad("IT_PRCUNI"	,VS3->VS3_VALPEC,n)  	//oGetPecas:aCols[ny,FG_POSVAR("VS3_VALPEC"	,"aHeaderP")],n)
			MaFisLoad("IT_VALMERC"	,Round(VS3->VS3_VALPEC * VS3->VS3_QTDITE, 2),n)  //oGetPecas:aCols[ny,FG_POSVAR("VS3_VALPEC","aHeaderP")]*oGetPecas:aCols[ny,FG_POSVAR("VS3_QTDITE","aHeaderP")],2),n)
			MaFisLoad("IT_DESCONTO"	,VS3->VS3_VALDES,n)  	//oGetPecas:aCols[ny,FG_POSVAR("VS3_VALDES"	,"aHeaderP")],n)
			MaFisRecal("",n)
			MaFisEndLoad(n,1)

			lPPrepec := .t.
			oGetPecas:nAt := ny

			M->VS3_SITTRI := _cSitTrib

			OX001PecFis()
			FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)

			MaFisRef("IT_CLASFIS"	,"VS300"	,M->VS3_SITTRI)
			MaFisRef("IT_TES"		,"VS300"	,M->VS3_CODTES)
			MaFisRef("IT_PRCUNI"	,"VS300"	,M->VS3_VALPEC)
			MaFisRef("IT_VALMERC"	,"VS300"	,Round(M->VS3_VALPEC*M->VS3_QTDITE,2))
			MaFisRef("IT_DESCONTO"	,"VS300"	,M->VS3_VALDES)
			OX001FisPec()

			M->VS3_VALPIS := MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
			M->VS3_VALCOF := MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
			M->VS3_ICMCAL := MaFisRet(n,"IT_VALICM")
			M->VS3_PICMSB := MaFisRet(n,"IT_ALIQSOL")
			M->VS3_BICMSB := MaFisRet(n,"IT_BASESOL")
			M->VS3_VICMSB := MaFisRet(n,"IT_VALSOL")
			M->VS3_VALCMP := MaFisRet(n,"IT_VALCMP")
			M->VS3_DIFAL  := MaFisRet(n,"IT_DIFAL")
			M->VS3_VALDES := MaFisRet(n,"IT_DESCONTO")
			//M->VS3_PIPIFB := MaFisRet(n,"IT_ALIQIPI")
			M->VS3_VIPIFB := MaFisRet(n,"IT_VALIPI")
			OX001FisPec()

			VS3->(RecLock("VS3",.f.))
			VS3->VS3_VALPIS := M->VS3_VALPIS 
			VS3->VS3_VALCOF	:= M->VS3_VALCOF 
			VS3->VS3_ICMCAL := M->VS3_ICMCAL
			VS3->VS3_PICMSB := M->VS3_PICMSB
			VS3->VS3_BICMSB := M->VS3_BICMSB
			VS3->VS3_VICMSB := M->VS3_VICMSB
			VS3->VS3_VALCMP := M->VS3_VALCMP
			VS3->VS3_DIFAL  := M->VS3_DIFAL
			VS3->VS3_VALDES := M->VS3_VALDES
			//VS3->VS3_PIPIFB := M->VS3_PIPIFB
			//VS3->VS3_VIPIFB	:= M->VS3_VIPIFB
			VS3->VS3_SITTRI := M->VS3_SITTRI
			
			If Empty(VS3->VS3_CENCUS)
				VS3->VS3_CENCUS := SB1->B1_CC
			EndIf
			If Empty(VS3->VS3_CONTA)
				VS3->VS3_CONTA 	:= SB1->B1_CONTA
			EndIf
			If Empty(VS3->VS3_ITEMCT)
				VS3->VS3_ITEMCT := SB1->B1_ITEMCC
			EndIf
			If Empty(VS3->VS3_CLVL)
				VS3->VS3_CLVL 	:= SB1->B1_CLVL
			EndIf
			
			VS3->(MsUnLock())

			//If lAltValorPeca
				//OX001PREPEC()
			//Endif
		Next
		//Atualizar Cabeçalho
		_aCmpFis	:= {}
		SX3->(DbSetOrder(1))
		SX3->(DbGoTop())
		If SX3->(MsSeek("VS1")) 
			while SX3->(!Eof()) .and. SX3->X3_ARQUIVO=="VS1"
				_cValid	:= AllTrim(UPPER(SX3->X3_VALID))
				If "MAFISREF" $ _cValid
					_nPosRef 	:= AT('MAFISREF("',_cValid) + 10
					_cRefCols	:=Substr(_cValid,_nPosRef,AT('","VS100",',_cValid) - _nPosRef )
					aAdd(_aCmpFis,{SX3->X3_CAMPO, _cRefCols })
				EndIf
				SX3->(DbSkip())
			EndDo
		EndIf
		//Grava os campos definidos no dicionario utilizando matxfis
		VS1->(DbGoto(_nRegVS1))
		VS1->(RecLock("VS1",.f.))
		If Len(_aCmpFis) > 0
			For _nPos := 1 To Len(_aCmpFis)
				_nPosRef := VS1->(FieldPos(_aCmpFis[_nPos,1]))
				If _nPosRef > 0
					_nRet := MaFisRet(,_aCmpFis[_nPos,2])
					VS1->(FieldPut( _nPosRef, _nRet ))
				EndIf
			Next
		EndIf
		VS1->VS1_VALDES := MaFisRet(,"NF_DESCONTO")
		VS1->VS1_DESCON := MaFisRet(,"NF_DESCONTO")
		//VS1->VS1_VALFRE	:= MaFisRet(,'NF_FRETE')	//não esta ativado se usado dara erro 500 no retorno
		//VS1_VALSEG		:= MaFisRet(,'NF_SEGURO')	//não esta ativado se usado dara erro 500 no retorno
		VS1->VS1_ICMCAL := MaFisRet(,'NF_VALICM')
		VS1->VS1_VALIPI := MaFisRet(,"NF_VALIPI")
		VS1->VS1_VALISS := MaFisRet(,"NF_VALISS")
		VS1->VS1_VALCOF := MaFisRet(,"NF_VALCF2")
		VS1->VS1_VALPIS	:= MaFisRet(,"NF_VALPS2")
		VS1->VS1_DESACE	:= IIF( VS1->VS1_XPORAC > 0 , ( ( ( MaFisRet(,"NF_TOTAL") * VS1->VS1_XPORAC ) / 100 ) ), 0 )
		VS1->VS1_VTOTNF := ( ( MaFisRet(,"NF_TOTAL") + VS1->VS1_DESACE ) - MaFisRet(,"NF_DESCZF" ) ) //OX001TOTPF("ON")
		VS1->VS1_ICMRET := MaFisRet(,"NF_VALSOL") 
		if VS1->(FieldPos("VS1_VALCMP")) > 0
			VS1->VS1_VALCMP := MaFisRet(,"NF_VALCMP")
		Endif
		if VS1->(FieldPos("VS1_VALDUP")) > 0
			VS1->VS1_VALDUP := MaFisRet(,"NF_BASEDUP")
		Endif
		VS1->VS1_OBSAGL := "ATUALIZAÇÃO IMPOSTOS (ORCCALFIS)" +CRLF+ AllTrim(VS1->VS1_OBSAGL)
		VS1->(MsUnlock())
	End Sequence
	MaFisEnd()
	RestArea(aArea)
Return _lRet


//Retornar para status inicial
User Function XRETSTVS1(_cNumOrc, _lTela)
	Local _aMsg			:= {}
	Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
	Local _cFaseOrc 	:= AllTrim(GetNewPar("MV_FASEORC","023R45F"))
	Local _aRegVS1		:= {}
	Local _cFase		:= "0"
	Local _cPicking		:= ""
	Local _lRet			:= .T.
	Local _nPos
	Local _cMens

	Default _cNumOrc	:= ""
	Default _lTela		:= .F.

	Begin Sequence
		If Empty(_cNumOrc)
			Aadd(_aMsg, "Não Informado o numero do orçamento, contate o ADM Sistemas !")
			Break
		EndIf
		//reposicionar orçamento
		If VS1->VS1_NUMORC <> _cNumOrc
			VS1->(DbSetOrder(1))
			If !VS1->(DbSeek(XFilial("VS1")+_cNumOrc))
				Aadd(_aMsg, "Numero do orçamento "+_cNumOrc+" não encontrado !")
				Break
			Endif
		EndIf
		_nPos := AT(_cFaseConf, _cFaseOrc)
		If _nPos == 0 
			Aadd(_aMsg, "Parametros de fase orçamento "+_cFaseOrc+" e fase carregamento "+_cFaseConf+" não indicam a fase de carregamento !")
			Break
		Endif
		//identifico os status que posso apagar
		_cFase := SubsTr(_cFaseOrc, 1, _nPos)
		//Valido se esta no status
		_nPos := AT(VS1->VS1_STATUS,_cFase)
		If _nPos == 0
			Aadd(_aMsg, "Parametros de fase orçamento "+_cFaseOrc+" e status do orçamento "+VS1->VS1_STATUS+" não permite retornar a fase !")
			Break
		Endif
		//Verificar se possui picking e se o mesmo esta com outros orçamento
		If !Empty(VS1->VS1_XPICKI) .and. !Empty(VS1->VS1_XDTEPI)
			Aadd(_aMsg, "Orçamento possui picking "+VS1->VS1_XPICKI+" ja enviado para carregamento, não será retornado status !")
			Break
		Endif
		//verificar se existe mais de um orçamento
		If !Empty(VS1->VS1_XPICKI)
			_cPicking	:= VS1->VS1_XPICKI 
			_aRegVS1 	:= XVERSZKVS1(VS1->VS1_XPICKI) 
			//Caso seja processo vindo de interação 		
			If _lTela .and. Len(_aRegVS1) > 1 //caso a quantidade do orçamento seja maior que um perguntar se ira voltar todos os registros
				If !MsgYesNo( "Existem "+StrZero(Len(_aRegVS1),3)+" orçamentos com esta numeração de picking "+AllTrim(_cPicking)+" deseja voltar status de todos orçamentos ? " )
					Break
				EndIf	
			Endif
		Else
			AAdd(_aRegVS1,VS1->(Recno())) 
		EndIf	
		Begin Transaction 
			For _nPos := 1 To Len(_aRegVS1)
				VS1->(DbGoto(_aRegVS1[_nPos]))	
				_cNumOrc := VS1->VS1_NUMORC
				//somente na fase de conferencia que verifica se tem reserva
				If VS1->VS1_STATUS == _cFaseConf 
					//necessario verificar se foi feito reserva para os itens
					_lRet := XTRANSFRES(_cNumOrc, _cFase, .F. /*_lTransf*/, .T. /*_lReserva*/, @_aMsg)
				Endif	
				//retirar picking do VS1 
				If _lRet
					_lRet := VS1->(XAPAGAVS1Picking(_aRegVS1[_nPos], _cPicking, _cNumOrc, "0" /*_cFase*/, @_aMsg))
				EndIF
				//Caso ocorreu erro abortar processo
				If !_lRet
					DisarmTransaction()
					Exit
				EndIf
			Next
			
			If _lRet .and. !Empty(_cPicking)
				SZK->(DbSetOrder(1)) //ZK_FILIAL+ZK_XPICKI+ZK_SEQREG                                                                                                                                   
				If !SZK->(DbSeek(XFilial("SZK")+_cPicking))
					Aadd( _aMsg, "Não localizado picking "+_cPicking+" !" )
					_lRet 	:= .F.
					DisarmTransaction()
				EndIF
				//apagar SZK
				While _lRet .and. SZK->(!Eof()) .and. SZK->ZK_FILIAL ==  XFilial("SZK") .and. SZK->ZK_XPICKI == _cPicking
					If !SZK->(RecLock("SZK",.f.))
						Aadd( _aMsg, "Não foi possivel bloquear tabela de picking !" )
						_lRet 	:= .F.
						DisarmTransaction()
						Exit
					EndIf
					SZK->(DbDelete())
					SZK->(MsUnlock())
					SZK->(DbSkip())
				EndDo	
			EndIf	
		End Transaction
	End Sequence
	If Len(_aMsg) > 0
		_cMens := ""
		For _nPos := 1 To Len(_aMsg)
			_cMens += Upper(_aMsg[_nPos]) + CRLF
		Next
		If _lTela
			MSGINFO( _cMens, "[XRETSTVS1] - Atenção" )
		Else
			Conout(_cMens)
		EndIf
	EndIf
Return _lRet


//verificar qtde de orçamentos com picking
Static Function XVERSZKVS1(_cPicking) 
	Local _cAliasPesq	:= GetNextAlias()   
	Local AVS1Reg 		:= {}
	BeginSql Alias _cAliasPesq
		SELECT 	VS1.R_E_C_N_O_ AS NREGVS1,
				VS1.VS1_NUMORC
		FROM %table:VS1% VS1
		WHERE 	VS1.VS1_FILIAL  	= %XFilial:VS1%
			AND VS1.VS1_XPICKI  	= %Exp:_cPicking%
			AND VS1.%notDel%		  
			GROUP BY VS1.VS1_NUMORC, VS1.R_E_C_N_O_
	EndSql      
	If (_cAliasPesq)->(!Eof()) 	
		While (_cAliasPesq)->(!Eof())
			If (_cAliasPesq)->NREGVS1 > 0
				Aadd(AVS1Reg, (_cAliasPesq)->NREGVS1)
			EndIf	
			(_cAliasPesq)->(DbSkip())
		EndDo	
	EndIf	
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 
Return AVS1Reg		



//Funcionalidade responsável por apagar o numero do picking e as suas relações com orçamento
//DAC 27/04/2022
User Function XAPAGAPicking(_cPicking, _cFase, _lMsg)
	Local _lRet 		:= .T.
	Local _cAliasPesq   := GetNextAlias()     
	Local _aMsg			:= {}
	Local _aColsAnt		:= {}
	Local _aRegSZK		:= {}
	Local _aArea		:= GetArea()
	Local _cChavePik	:= ""		
	Local _nRegVS1		:= VS1->(Recno())
	//Local _cSeq 		:= "0"+VS3->VS3_SEQUEN
	//Local _nQtdeItem	:= VS3->VS3_QTDITE

	Local _cMsg
	Local _nPos
	Local _cNumOrc 

	Default	_cPicking	:= ""
	Default _cFase		:= "0"
	Default _lMsg		:= .T.

	Begin Sequence
		//controle para que sempre seja enviado o picking
		If Empty(_cPicking)
			Aadd(_aMsg, "Numero do picking não informado ! ")
			_lRet 	:= .F.
			Break
		Endif

		//Caso apareça mensagem perguntar se deseja apagar picking
		If _lMsg .and. !MsgYesNo( "Deseja retirar numeração do picking "+AllTrim(_cPicking)+"  ? " )
			_lRet 	:= .F.
			Break
		Endif	
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	SZK.R_E_C_N_O_ AS NREGSZK,
					SZK.ZK_XPICKI,
					VS1.R_E_C_N_O_ AS NREGVS1
			FROM  %Table:SZK% SZK 
			LEFT JOIN %Table:VS1% VS1 
				ON	VS1.VS1_FILIAL 	= %xFilial:VS1%
				AND	VS1.VS1_XPICKI  = SZK.ZK_XPICKI
				AND VS1.%notDel%
			WHERE 	SZK.ZK_FILIAL 	= %xFilial:SZK% 
				AND SZK.ZK_XPICKI 	= %Exp:_cPicking%
				AND SZK.%notDel%
			ORDER BY SZK.ZK_XPICKI, VS1.VS1_NUMORC, VS1.VS1_CLIFAT, VS1.VS1_LOJA	
		EndSql
		If (_cAliasPesq)->(Eof())  
			Aadd(_aMsg, "Não encontrado registro com numero de picking "+ _cPicking +" ! ")
			_lRet	:= .F.
			Break
		EndIf	
		//pegar indicação do SZK (picking) e verificar se possui Fatura
		SZK->(DbGoto((_cAliasPesq)->NREGSZK))

		If SZK->ZK_STATUS == "B" //Bloqueado
			Aadd(_aMsg, "Picking esta bloqueado, não pode ser cancelado  !" )
			_lRet := .f.
			Break
		EndIf
		If SZK->ZK_STATUS == "C" //Cancelado
			Aadd(_aMsg,"Picking esta Cancelado, não pode ser cancelado  !" )
			_lRet := .f.
			Break
		EndIf
		If SZK->ZK_STATUS == "F" .or. !Empty(SZK->ZK_NF) //Faturado
			Aadd(_aMsg, "Picking "+SZK->ZK_XPICKI+" já possui nota fiscal "+SZK->ZK_NF+", não pode ser cancelado  ! ")
			_lRet := .f.
			Break
		EndIf

		If Type("aCols") == "A"
			_aColsAnt := Aclone(aCols)
		Endif

		Begin Transaction
			While (_cAliasPesq)->(!Eof())
				SZK->(DbGoto((_cAliasPesq)->NREGSZK))	
				_cChavePik	:= (_cAliasPesq)->ZK_XPICKI
				_aRegSZK	:= {}
				_aRegVS1	:= {}
				_aMsg		:= {}
				While (_cAliasPesq)->(!Eof()) .and. _cChavePik	== (_cAliasPesq)->ZK_XPICKI
					//guardo o numero do registro do picking pois pode repetir numero com seguencias diferentes
					If (_cAliasPesq)->NREGSZK > 0 .and. Ascan(_aRegSZK,(_cAliasPesq)->NREGSZK) == 0
						Aadd(_aRegSZK, (_cAliasPesq)->NREGSZK)
					EndIf	
					//Garantir que não venham VS1 duplicados, pois existem pickinsg com sequencias diferentes 
					If (_cAliasPesq)->NREGVS1 > 0 .and. Ascan(_aRegVS1,(_cAliasPesq)->NREGVS1) == 0
						Aadd(_aRegVS1, (_cAliasPesq)->NREGVS1)
					EndIf	
					(_cAliasPesq)->(DbSkip())
				EndDo	
				//Alterar primeiro o VS1
				For _nPos := 1 To Len(_aRegVS1)
					VS1->(DbGoto(_aRegVS1[_nPos]))	
					_cNumOrc := VS1->VS1_NUMORC
					_lRet := XTRANSFRES(_cNumOrc, _cFase, .T. /*_lTransf*/, /*_lReserva*/, @_aMsg)
					If !_lRet
						DisarmTransaction()
						Exit
					EndIf
					//retirar picking do VS1 e SZK
					If _lRet
						_lRet := VS1->(XAPAGAVS1Picking(_aRegVS1[_nPos], _cChavePik, _cNumOrc,_cFase ,@_aMsg))
					EndIF
					//Caso ocorreu erro abortar processo
					If !_lRet
						DisarmTransaction()
						Exit
					EndIf
				Next   //skip esta na função  	XAPAZKPVS1Picking
				//sai do while
				If !_lRet
					Exit
				EndIf
				//apagar SZK
				For _nPos := 1 To Len(_aRegSZK)
					SZK->(DbGoto(_aRegSZK[_nPos]))
					If !SZK->(RecLock("SZK",.F.))
						Aadd( _aMsg, "Não foi possivel bloquear tabela de picking !" )
						_lRet 	:= .F.
					Else
						If _lRet
							SZK->ZK_STATUS := "C" //Cancelado
						Endif
						SZK->(MsUnlock())
					EndIf
				Next
				//sai do while
				If !_lRet
					Exit
				EndIf
			EndDo
		End Transaction

	End Sequence
	//Mostra mensagem
	_cMsg	:= If(_lRet,"Retirada do picking realizada com sucesso !","Retirada do picking não foi realizada !")
	_cMsg 	+= CRLF
	//acrescento informações de erro
	If Len(_aMsg)
		For _nPos := 1 To Len(_aMsg)
			_cMsg += _aMsg[_nPos] + CRLF
		Next
	Endif
	If _lMsg 
		MSGINFO( _cMsg, "[XAPAGAPicking] - Atenção" )
	Else
		ConOut(_cMsg+" [XAPAGAPicking]" )
	Endif
	If Len(_aColsAnt) > 0
		aCols := _aColsAnt
	Endif
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 
	VS1->(DbGoto(_nRegVS1))	
	RestArea(_aArea)
Return _lRet


//Fazer Trasnferência e ou retirar a reserva
Static Function XTRANSFRES(_cNumOrc, _cFase, _lTransf, _lReserva, _aMsg)
	Local _lRet			:= .T.
	Local _cStatusAnt 	:= {}
	Local _aVS3Reg		:= {}

	Default _lTransf 	:= .F.
	Default _lReserva 	:= .F.

	Begin Sequence
		If VS1->VS1_STATUS $ "X_C"  //VS1->VS1_STATUS $ "X_C"ja esta faturado
			Aadd(_aMsg, "Orçamento " +_cNumOrc+ " com status "+VS1->VS1_STATUS+", que nao permite este cancelamento !" )
			Break
		Endif
		Private aHeaderP    := {} // Variavel ultilizada na OX001RESITE
		Private aResDel  	:= {}
		_cStatusAnt 		:= VS1->VS1_STATUS

		DbSelectArea("VS1")
		//Fazer transferencia Padrão
		If _lTransf
			//Reverte Fase do Orçamento
			If !VS1->(OXI001REVF(_cNumOrc, _cFase ))
				Aadd(_aMsg, "Não foi possivel reverter Status do orçamento !")
				_lRet := .F.
				Break
			Else
				Aadd(_aMsg,"Realizado Transferência para reversão do orçamento !")
			EndIf
		EndIf	
		//retirar reserva
		If _lReserva
			aResDel		:= {}
			_aVS3Reg	:= {}
			VS3->(DbsetOrder(1))
			If VS3->(MsSeek(XFilial("VS3")+VS1->VS1_NUMORC))
				While VS3->(!Eof()) .and.  VS3->VS3_FILIAL == XFilial("VS3") .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC
					If !Empty(VS3->VS3_DOCSDB) //VS3->VS3_RESERV == "1"
						aAdd(aResDel,VS3->VS3_SEQUEN)
						AAdd(_aVS3Reg, VS3->(Recno()))
					EndIf	
					VS3->(DbSkip())
				EndDo
			Endif	
			//retirar a reserva
			If Len(aResDel) > 0
				Private _aReservaCAOA := {_cNumOrc,.F.,_aVS3Reg}	// Variavel utilizada no PE OX001RES
				_cDocto := VS1->(OX001RESITE(VS1->VS1_NUMORC, .F., aResDel))
				//Alterado para utilizar reserva CAOA - DAC 16/08/2022
				//_cDocto := U_XRESCAOAPEC(_cNumOrc, .F., aResDel)
				If Empty(_cDocto) .or. _cDocto == "NA"
					Aadd(_aMsg,"Não foi localizado reservas para retirar !")
					_lRet := .F. 
					Break
				Else
					Aadd(_aMsg,"Reserva retirada com o numero do docto "+_cDocto+" !")
				EndIf
			Else
				Aadd(_aMsg,"Não existe reservas para retirar de acordo com VS3_DOCSDB !")
			EndIf
		Endif
		//	Aadd(_aMsg,"Não executado transferência e ou reservas para retirar, no processo XTRANSFRES !")
		//	Break
		//Endif
	End Sequence
Return _lRet
	

//apagar VS1 e SZK
Static Function XAPAGAVS1Picking(_nRegVS1, _cPicking, _cNumOrc, _cFase, _aMsg)
	Local _lRet 	:= .T.
	Local _cObs		:= ""
	Local _nPos

	Default _aMsg		:= {}
	Default _cStatus	:= ""
	Default _cFase      := ""

	Begin Sequence
		VS1->(DbGoto(_nRegVS1))	
		VS1->(RecLock("VS1",.f.))
		//Apagar VM5/VM6
		U_XAPAVM5VM6Carregamento(_cNumOrc, @_aMsg)
		_cObs := "Processo de retirada/exclusão Picking "+_cPicking+" em "+DtoC(Date())+" "+Time()  + CRLF
		For _nPos := 1 To Len(_aMsg)
			_cObs += _aMsg[_nPos]
			_cObs += " "
		Next
		_cObs += CRLF

		VS1->(DbGoto(_nRegVS1))
		VS1->(RecLock("VS1",.f.))
		VS1->VS1_OBSAGL := Upper(_cObs) + CRLF + VS1->VS1_OBSAGL
		VS1->VS1_XPICKI := ""
		VS1->VS1_XDTEPI := CtoD(Space(08))
		VS1->VS1_XHSPIC	:= ""
		VS1->VS1_XUSUPI := ""
		If !Empty(_cFase)
			VS1->VS1_STATUS := _cFase
			//Se a fase for inicial retirar o numero de documento do VS3
			If _cFase == "0"
				RETRESERVAVS3(VS1->VS1_NUMORC)
			Endif
		Endif
		VS1->(MsUnlock())
	End Sequence
Return _lRet

//Retirar o numero do documento de reserva constante no VS3 (isto acontece quando retorno a fase inicial e esta servindo de ref pois não esta indicando nos status que esta reservado)
//DAC - 26/05/2022
Static Function RETRESERVAVS3(_cNumOrc)
	Begin Sequence
		VS3->(DbSetOrder(1))
		If !VS3->(DbSeek(XFilial("VS3")+_cNumOrc))
			Break
		Endif
		While VS3->(!Eof()) .and. VS3->VS3_FILIAL == XFilial("VS3") .and.  VS3->VS3_NUMORC == _cNumOrc
			If !Empty(VS3->VS3_DOCSDB)
				VS3->(RecLock("VS3",.f.))
				VS3->VS3_DOCSDB := ""
				VS3->(MsUnlock())
			EndIf			
			VS3->(DbSkip())
		EndDo
	End Sequence
Return Nil


/*/{Protheus.doc} MATA261
@param  	
@author 	CAOA - CAOA - A.Carlos
@version  	P12.1.23
@since  	06/01/2022
@return  	NIL
@project
@history    Tranferência Interna Mútipla (Divergência)   
			PEC042 - Controle de saldo e e-mail apos integracao de armazenagem - Ajuste para localizar dcto D3 NextNumero
@obs         
  	VM5.VM5_CODIGO , (cAlVM5)->VM6_QTORIG - (cAlVM5)->VM6_QTCONF , cArmorig, cArmdes
    	     01                         02    -    Qtde                   03        04
	É necessario que:
	O parametro MV_LOCALIZ = S
	O produto com codigo PA001 tenha controle de endereco ativo
	O armazem padrao definido no produto deve ter 2 endereços: ENDER01 (61) e ENDER02 (65)
	Saldo inicial igual ou superior a 1
	E este saldo deve ser endereçado ao ENDER01
/*/
User Function XMOVA261(_cNumOrc, _cCodProd, _cArmorig, _cArmdes, _nQtde, _nRegvs3,_cFunc)
	Local _aAuto  		:= {}
	Local _aLinha 		:= {}
	Local _nOpcAuto     := 0
	Local _cDocumento   := ""
	Local _lRet 		:= .T.
	Local _aMsgErro		:= {}
	Local _cErro
	Local _nPos

	Default _cCodProd	:= ""
	Default _cNumOrc	:= ""
	Default _cArmorig  	:= AllTrim(GETMV("MV_RESITE"))    //'61'
	Default _cArmdes   	:= AllTrim(GETMV("MV_DIVITE"))    //'65'
	Default _nQtde 		:= 0
	Default _cFunc		:= ""
	//Private cCodMov     := '501'
	//Private cCC         := '13030177MA'
	//Private nVlrCusto   := 1.00
	//Private dDtaTransf  := Date()
	//Private cDoc        := '777'

	Begin Sequence
		//Cabecalho a Incluir
		If Empty(_cCodProd)
			_cErro := "Codigo do produto esta em branco, não será realizada a transferencia comunicar ADM Sistemas !!! " 
			AAdd(_aMsgErro,_cErro)
			MSGINFO( _cErro, "[ZPECF013_MANUTENCAO] - Atenção" )
			_lRet := .F.
			Break
		Endif	
		If Empty(_cNumOrc)
			_cErro := "Não informado o numero orçamento, não será realizada a transferencia comunicar ADM Sistemas!!! " 
			AAdd(_aMsgErro,_cErro)
			MSGINFO( _cErro, "[ZPECF013_MANUTENCAO] - Atenção" )
			_lRet := .F.
			Break
		Endif	
		If Empty(_cArmorig)
			_cErro := "Não informado o armazém origem, não será realizada a transferencia comunicar ADM Sistemas!!! " 
			AAdd(_aMsgErro,_cErro)
			MSGINFO( _cErro, "[ZPECF013_MANUTENCAO] - Atenção" )
			_lRet := .F.
			Break
		Endif	
		If Empty(_cArmdes)
			_cErro := "Não informado o armazém origem, não será realizada a transferencia comunicar ADM Sistemas!!! " 
			AAdd(_aMsgErro,_cErro)
			MSGINFO( _cErro, "[ZPECF013_MANUTENCAO] - Atenção" )
			_lRet := .F.
			Break
		Endif	
		If _nQtde <= 0
			_cErro := "Não informado a quantidade , não será realizada a transferencia comunicar ADM Sistemas!!! " 
			AAdd(_aMsgErro,_cErro)
			MSGINFO( _cErro, "[ZPECF013_MANUTENCAO] - Atenção" )
			_lRet := .F.
			Break
		Endif	

		//_cDocumento := GetSxeNum("SD3","D3_DOC") //não pode ser do SX
		//Implementado pois em alguns casos não esta conseguindo localizar numeração subindo com PEC042 DAC-07/06/2023
		_cDocumento := ""
		For _nPos := 1 To 10
			_cDocumento := Criavar("D3_DOC")
			_cDocumento	:= IIf(Empty(_cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),_cDocumento)
			If !Empty(_cDocumento)
				Exit
			Endif 
		Next 	
		If Empty(_cDocumento)
			_cErro := "Não foi possivel montar numeração SD3, para gerar movimentação." 
			AAdd(_aMsgErro, _cErro)
			MSGINFO( _cErro, "[ZPECF013_MANUTENCAO] - Atenção" )
			_lRet := .F.
			Break
		Endif
		_cDocumento	:= A261RetINV(_cDocumento)
		aadd(_aAuto,{_cDocumento , dDataBase})    //Cabecalho

		//Itens a Incluir
		SB1->(DbSetOrder(1))
		If !SB1->(DbSeek(xFilial("SB1")+PadR(_cCodProd, tamsx3('D3_COD') [1])))
			_cErro := "Não localizado codigo do produto "+_cCodProd+" !!! " 
			AAdd(_aMsgErro,_cErro)
			MSGINFO( _cErro, "[ZPECF013_MANUTENCAO] - Atenção" )
			_lRet := .F.
			Break
		Endif	
		_aLinha 	:= {}
		//origem
		//aadd(aLinha,{"D3_FILIAL" ,  	xFilial("SD3")			, Nil})
		aadd(_aLinha,{"D3_COD"    	, SB1->B1_COD 				, Nil}) //Cod Produto origem
		aadd(_aLinha,{"D3_DESCRI" 	, SB1->B1_DESC 				, Nil}) //descr produto origem
		aadd(_aLinha,{"D3_UM"     	, SB1->B1_UM				, Nil}) //unidade medida origem
		aadd(_aLinha,{"D3_LOCAL"  	, _cArmorig					, Nil}) //armazem origem
		aadd(_aLinha,{"D3_LOCALIZ"	, PadR(_cArmorig, tamsx3('D3_LOCALIZ') [1])	,Nil}) //Informar endereço origem
		//aAdd(_aLinha,{"D3_TM"     , Alltrim(cCodMov)		, Nil }) //Tipo Movimento
		//aAdd(_aLinha,{"D3_DOC"    , Alltrim(cDoc)			, Nil }) //Documento
		//aAdd(_aLinha,{"D3_EMISSAO", dDtaTransf			, Nil }) //EMISSAO
		//Destino
		aadd(_aLinha,{"D3_COD"		, SB1->B1_COD				, Nil}) //cod produto destino
		aadd(_aLinha,{"D3_DESCRI"	, SB1->B1_DESC				, Nil}) //descr produto destino
		aadd(_aLinha,{"D3_UM"		, SB1->B1_UM				, Nil}) //unidade medida destino
		aadd(_aLinha,{"D3_LOCAL"	, _cArmdes					, Nil}) //armazem destino  era  SB1->B1_LOCPAD
		aadd(_aLinha,{"D3_LOCALIZ"	, PadR(_cArmdes, tamsx3('D3_LOCALIZ') [1]),	Nil}) //Informar endereço destino

		aadd(_aLinha,{"D3_NUMSERI"	, ""						, Nil}) //Numero serie
		aadd(_aLinha,{"D3_LOTECTL"	, IIf(!Empty(VS3->VS3_LOTECT),VS3->VS3_LOTECT,"")		, Nil}) //Lote Origem
		aadd(_aLinha,{"D3_NUMLOTE"	, IIf(!Empty(VS3->VS3_NUMLOT),VS3->VS3_NUMLOT,"")		, Nil}) //sublote Origem
		aadd(_aLinha,{"D3_DTVALID"	, IIf(!Empty(VS3->VS3_DTVALI),VS3->VS3_DTVALI,cTod(""))	, Nil}) //data validade
		aadd(_aLinha,{"D3_POTENCI"	, 0 						, Nil}) // Potencia
		aadd(_aLinha,{"D3_QUANT"	, _nQtde					, Nil}) //Quantidade
		aadd(_aLinha,{"D3_QTSEGUM"	, 0 						, Nil}) //Seg unidade medida
		aadd(_aLinha,{"D3_ESTORNO"	, ""						, Nil}) //Estorno
		aadd(_aLinha,{"D3_SEQCALC"	, ""						, Nil}) //Seq. 
		aadd(_aLinha,{"D3_LOTECTL"	, IIf(!Empty(VS3->VS3_LOTECT),VS3->VS3_LOTECT,criavar("D3_LOTECTL")) , Nil}) //Lote destino
		aadd(_aLinha,{"D3_DTVALID"	, ''						, Nil}) //data validade Destino
		aadd(_aLinha,{"D3_ITEMGRD"	,""							, Nil})	//Item Grade 

	/*
		aadd(_aLinha,{"D3_NUMLOTE"	, ""						, Nil}) //sublote destino
		aadd(_aLinha,{"D3_NUMSEQ"	, ""						, Nil}) // Numero sequencia D3_NUMSEQ

		aadd(_aLinha,{"D3_GRUPO"		, SB1->B1_GRUPO				, Nil}) //grupod produto

		aadd(_aLinha,{"D3_LOTECTL"	, ""						, Nil}) //Lote Origem
		
		aadd(_aLinha,{"D3_DTVALID"	, ''						, Nil}) //validade lote destino
		aadd(_aLinha,{"D3_ITEMGRD"	, ""						, Nil}) //Item Grade
		
		aadd(_aLinha,{"D3_CODLAN"	, ""						, Nil}) //cat83 prod origem
		aadd(_aLinha,{"D3_CODLAN"	, ""						, Nil}) //cat83 prod destino

		aadd(_aLinha,{"D3_CONTA"	, SB1->B1_CONTA				, Nil}) //conta contabil produto 
		aadd(_aLinha,{"D3_ITEMCTA"	, SB1->B1_ITEMCC			, Nil}) //item contabil produto 
		aadd(_aLinha,{"D3_CLVL"		, SB1->B1_CLVL				, Nil}) //classe valor produto 
		aadd(_aLinha,{"D3_CC"		, cCC						, Nil}) //centro custo produto 

		aadd(_aLinha,{"D3_STATUS"	,"SERVICO NAO EXECUTADO"	, Nil}) //SATATUS registro
	*/
		aAdd(_aAuto, _aLinha)

		_nOpcAuto := 3   //Inclusao
		Private lMsErroAuto := .F.
		MSExecAuto({|x,y| mata261(x,y)}, _aAuto, _nOpcAuto)

		if lMsErroAuto
			_cErro := "Problemas no execauto MATA261, comunicar ADM Sistemas !!! " 
			AAdd(_aMsgErro,_cErro)
			MostraErro()
			_lRet := .F.
			//lContinua := .F.
			Break
		EndIf
			
	End Sequence	
	//Caso tenha o numero de orçamento atualizar VS1
	If !Empty(_cNumOrc)
		//verifico se ja esta pocicionado no VS1
		If AllTrim(_cNumOrc) <> AllTrim(VS1->VS1_NUMORC)
			If !VS1->(DbSeek(XFILIAL("VS1"+_cNumOrc)))
				_cErro := "Não localizado o orçamento "+AllTrim(_cNumOrc)+", não será atualizado divergencia comunicar o ADM do Sistema!!! "
				AAdd(_aMsgErro,_cErro)
				MSGINFO( _cErro, "[ZPECF013_MANUTENCAO] - Atenção" )
				Return .F.
			Endif
		EndIf	
	Endif	
	//Gravar no sigapec a Transferencia tem que estar posicionado no VS3
	VS3->(DbGoto(_nRegvs3))
	//OX001VE6(_cNumOrc, .T.) // RESERVA / DESRESERVA DO ITEM
	if !(_cFunc $ "ZPECF13G")
		OX001VE6(_cNumOrc, .T.) // RESERVA / DESRESERVA DO ITEM
	EndIf
	_cObs := ""
	_cObs += "[ZPECF013_MANUTENCAO ITENS DIVERGENCIA EM "+DtoC(Date())+" as "+SubsTr(Time(),1,5)+"]"
	_cObs += "Ocorrencias na movimentação do armazem de divergência !"+ CRLF
	If 	Len(_aMsgErro) > 0
		For _nPos := 1 To Len(_aMsgErro)
			_cObs += _aMsgErro[_nPos] + CRLF
		Next _nPos
	ElseIf Len(_aMsgErro) == 0 .and. _lRet
		_cObs += "Gravado movimentação do produto "+AllTrim(_cCodProd)+" qtde "+AllTrim(Str(_nQtde))+" do armazem "+_cArmorig+" para o armazem "+_cArmdes + CRLF
		_cObs += "Dcto movimentação "+_cDocumento	+ CRLF
	Else
		_cObs += "Ocorreram erros na mivimentação de armazem  do produto "+_cCodProd + CRLF
	Endif

	VS1->(RecLock("VS1",.F.))
	VS1->VS1_OBSAGL		:= Upper(_cObs) + CRLF  + AllTrim(VS1->VS1_OBSAGL)
	VS1->(MsUnlock())
Return _lRet


//Verifica se pernite ou não cancelar a NFe avaliando o prazo maximo para cancelamento
User Function XVERCANFe( _cDoc, _cSerie,  _cCli,  _cLoja, _cMens)
	Local _lRet 	:= .T.
	Local _nSpedExc	:= SuperGetMV("MV_SPEDEXC", , 72)   //Indica a quantidade de horas q a NFe pode ser cancelada 
	Local _dData 
	Local _cHora 

	Default _cDoc  	:= ""
	Default _cSerie	:= ""	
	Default _cCli	:= ""
	Default _cLoja	:= ""
	Default _cMens 	:= ""

	Begin Sequence
		If Empty(_cDoc)
			_cMens := "Numero da Nota Fiscal não informado para validação de cancelamento !"
			_lRet  := .F.
			Break
		Endif
		If Empty(_cSerie)
			_cMens := "Serie da Nota Fiscal não informado para validação de cancelamento !"
			_lRet  := .F.
			Break
		Endif
		If Empty(_cCli)
			_cMens := "Cliente da Nota Fiscal não informado para validação de cancelamento !"
			_lRet  := .F.
			Break
		Endif
		If Empty(_cLoja)
			_cMens := "Loja ref. ao Cliente da Nota Fiscal não informado para validação de cancelamento !"
			_lRet  := .F.
			Break
		Endif

		//Verifica se eh uma notafiscal eletronica , pois neste caso deve respeitar o 	
		//parametro MV_SPEDEXC que indica o numero de horas que a Nfe pode ser excluidas 				
		SF2->(dbSetOrder(1))
		If _cDoc <> SF2->F2_DOC .or. _cSerie <> SF2->F2_SERIE .or. _cCli <> SF2->F2_CLIENTE .or. _cLoja <> SF2->F2_LOJA
			If !SF2->(DbSeek(xFilial("SF2") + _cDoc + _cSerie + _cCli + _cLoja))
				_lRet	 := .F.
				_cMens 	:= "Nao localizado NFe "+ _cDoc +" serie "+ _cSerie +" do Cliente "+ _cCli +" loja "+ _cLoja +" para excluisão !"						
				Break
			EndIf
		EndIf								
		If Month(SF2->F2_EMISSAO) <> Month(dDataBase) .OR. Year(SF2->F2_EMISSAO) <> Year(dDataBase)
			_lRet	 := .F.
			_cMens :=  "Nao se pode excluir uma nota fiscal quando o mes ou ano de sua emissao for diferente da database do sistema !"
			Break
		EndIf
		//Caso seja "N"  Status N é não autorizada pode cancelar DAC 24/05/2022
		If Empty(SF2->F2_FIMP) .Or. AllTrim(SF2->F2_FIMP) == "N"
			Break
		Endif
		//Verifica se eh uma notafiscal eletronica , pois neste caso deve respeitar o 	
		//parametro MV_SPEDEXC que indica o numero de horas que a Nfe pode ser excluidas
		If AllTrim(SF2->F2_ESPECIE) <> "SPED"   //se for diferente de SPED deixo continuar
			Break
		Endif	
		//tem que estar nestes status para cancelar
		If  !SF2->F2_FIMP $ "T_S" //verificacao apenas da especie como SPED e notas que foram transmitidas ou impressao DANFE
			_lRet	 := .F.
			_cMens 	 := "NFe "+ _cDoc +" serie "+ _cSerie +" do Cliente "+ _cCli +" loja "+ _cLoja +" não possui status para excluisão, Status atual"+If(Empty(SF2->F2_FIMP),"não enviada [",SF2->F2_FIMP)+"] !"						
			Break  //não é NFE e ou ainda não foi transmitida posso sair
		Endif
		If !Empty(SF2->F2_CODNFE) .Or. !Empty(SF2->F2_CHVNFE)	
			If !Empty(SF2->F2_DAUTNFE) .and. !Empty(SF2->F2_HAUTNFE)
				_dData := SF2->F2_DAUTNFE
				_cHora := SF2->F2_HAUTNFE
			Else
				_dData := SF2->F2_EMISSAO
				_cHora := SF2->F2_HORA
			Endif
			//_nHoras := SubtHoras(SF2->F2_DAUTNFE, SF2->F2_HAUTNFE, dDataBaseXAPAGAPicking, SubStr(Time(), 1, 2) + ":" + SubStr(Time(), 4, 2))
			_nHoras := SubtHoras(_dData, _cHora, dDataBase, SubStr(Time(), 1, 2) + ":" + SubStr(Time(), 4, 2))
			If _nHoras > _nSpedExc					
				_lRet	 := .F.
				_cMens := "Nao foi possivel excluir a nota emitida em "+DtoC(_dData)+", pois o prazo para o cancelamento da NF-e e de: "+StrZero(_nSpedExc,3)+" horas !"						
				Break
			EndIf								
		EndIf

	End Sequence
Return _lRet	



//Apagar VM6, VM5 e VM2
User Function XAPAVM5VM6Carregamento(_cNumOrc, _aMsg)
	Local _lRet 	:= .T. 
	Local _lCarrega := .T.

	DeFault _aMsg 	:= {}

	Begin Sequence
		VM5->(DbSetOrder(3))   //Filial+NumOrc
		VM6->(DbSetOrder(1))  //Filial+CodVM5+VM6SEQUEN
		_lCarrega	:= .F.  //para avaliar se acha VM6
		If !VM5->(MsSeek(XFilial("VM5")+_cNumOrc))
			Break
		Endif
		If !VM5->(RecLock("VM5", .F.))
			_lRet := .F.
			Aadd(_aMsg, "Não foi possivel selecionar VM6 Exclusivo !")
			Break
		EndIf
		//Apaga itens
		If VM6->(MsSeek(XFilial("VM6") + VM5->VM5_CODIGO ))
			While VM6->(!Eof()) .and. VM6->VM6_CODVM5 == VM5->VM5_CODIGO
				If !VM6->(RecLock("VM6", .F.))
					_lRet := .F.
					Aadd(_aMsg, "Não foi possivel selecionar VM6 Exclusivo !")
					Break
				EndIf
				VM6->(DbDelete())
				VM6->(MsUnlock())
				VM6->(DbSkip())
			EndDo	
		EndIf
		//Apagar histórico VM2
		VM2->(DbSetOrder(1))//	VM2_FILIAL+VM2_CODIGO+VM2_TIPO+VM2_STATUS                                                                                                                       
		If VM2->(MsSeek(XFilial("VM2") + VM5->VM5_CODIGO ))
			While VM2->(!Eof()) .and. VM2->VM2_CODIGO == VM5->VM5_CODIGO
				If !VM2->(RecLock("VM2", .F.))
					_lRet := .F.
					Aadd(_aMsg, "Não foi possivel selecionar VM2 Exclusivo !")
					Break
				EndIf
				VM2->(DbDelete())
				VM2->(MsUnlock())
				VM2->(DbSkip())
			EndDo	
		EndIf
		//Apagar VM5
		VM5->(dbDelete())
		VM5->(MsUnlock())
		//neste caso tenho que zerar pois caso seja feito alguma cópia e este registro esteja preenchido dara erro na conferência se a sequencia estiver errada DAC 07/02/2023
		VS3->(DbSetOrder(1))
		If VS3->(DbSeek(XFilial("VS3")+_cNumOrc))
			While VS3->(!Eof()) .and. VS3->VS3_NUMORC ==  _cNumOrc
				If !Empty(VS3->VS3_SQCONF)
					VS3->(RecLock("VS3",.F.))
					VS3->VS3_SQCONF := ""
					VS3->(MsUnlock())
				EndIf
				VS3->(DbSkip())
			EndDo
		Endif

		If _lRet
			Aadd(_aMsg, "Retirado carregamento orçamento(s) !")
		EndIf
	End Sequence
Return _lRet


/*/{Protheus.doc} XSLDCAOAEstoque
Responsável por localizar saldo em estoque
@author 	DAC-Denilso
@since 		25/05/2022
@version 	undefined
@param 		_cProduto	- Produto
			_cArmazem	- Armazém
			_cGrupo		- Grupo do Produto
			_nSaldoSB2	- Saldo Protheus
			_cMarca		- Marca 
@type 		user function
@project    
@return		_lRet		- Se foi calculado corretamente 
			_nSaldo		- Saldo entre as empresas 
			_cMens		- Mensagens do processo 
			_cCodProdRet- Produto avaliado 
			_cArmazemRet- Armazem avaliado 
			_cGrupoRet	- Grupo do produto avaliado

@ Obs		
@history    
/*/
User Function XSLDCAOAEstoque(_cCodProd, _cArmazem, _cGrupo, _nSaldoSB2, _cMarca )
	Local _lRet 		:= .T.
	Local _nSaldo		:= 0
	Local _aMens		:= {}	//se enviar na função pode retornar mensagens
	Local _cCodProdRet 	:= _cCodProd
	Local _cArmazemRet	:= _cArmazem
	Local _cGrupoRet	:= _cGrupo
	Local _lAvaliaWis	:= SuperGetMV( "CMV_PEC024"  ,,.T. )   //Parâmetro para indicar se avaliara saldo wis

	Local _nPos

	Default _cArmazem   := ""	//Ideal enviar armazem
	Default _cGrupo		:= ""   //ideal enviar grupo
	Default _nSaldoSB2  := 0
	Default _cMarca		:= VS1->VS1_XMARCA

	Begin Sequence
		//Caso ja venha com saldo e não é necessário avaliação Wis pode sair
		If !_lAvaliaWis .and. _nSaldoSB2 > 0
			_nSaldo		:= _nSaldoSB2
			Break
		Endif
		//Ajustar tamanho código produto
		If Len(_cCodProd) > Len(SB2->B2_COD)
			_cCodProdRet := SubsTr(_cCodProdRet ,Len(SB2->B2_COD))
		ElseIf Len(_cCodProd) < Len(SB2->B2_COD)
			_cCodProdRet := _cCodProdRet+Space( Len(SB2->B2_COD)- Len(_cCodProdRet))
		EndIf

		//Validar Imetro
		//GAP_PECCD01 - Controle de Validade de Produtos com Inm V1.
		SB1->(DbSetOrder(1))
		If !SB1->(MsSeek(XFilial("SB1")+_cCodProdRet))
			Aadd(_aMens,"Produto "+ AllTrim(_cCodProdRet) +" não localizado no cadastro de Produtos !")
			_lRet := .F.
			Break
		Endif	
		If Empty(_cArmazemRet)
			_cArmazemRet := SB1->B1_LOCPAD
		EndIf
		If Empty(_cGrupoRet)
			_cGrupoRet := SB1->B1_GRUPO
		EndIf
		//quando vem informado o saldo não sera validado novamente, isto ocorrera no similar, kit
		If _nSaldoSB2 <= 0
			//Função no padrão SIGAPEC		
			oZPEC08Peca:SetGrupo(_cGrupoRet)
			oZPEC08Peca:SetCodigo(_cCodProdRet)
			_nSaldoSB2 	:= 0
			_aSaldo 	:= oZPEC08Peca:EstqSaldo(,.t.,.t.)

			For _nPos := 1 To Len(_aSaldo)
				If AllTrim(_cArmazemRet) == AllTrim(_aSaldo[_nPos,2])
					_nSaldoSB2 	:= _aSaldo[_nPos,3]  //(_cAliasPesq)->SALDOSB2
					Exit
				Endif	
			Next
		Endif
		//Caso não seja para avaliar WIS
		If !_lAvaliaWis 
			_nSaldo		:= _nSaldoSB2
			Break
		Endif

		//Verificar o saldo Wis para comparar com saldo Protheus
		_nSaldoWis	:= u_zSaldoWis(_cCodProdRet, _cMarca, _cArmazem)
		If _nSaldoWis < _nSaldoSB2 
			Aadd(_aMens, "Produto "+AllTrim(_cCodProdRet)+", com Saldo Protheus "+AllTrim(Str(_nSaldoSB2))+" maior que saldo Wis "+AllTrim(Str(_nSaldoWis))+", sera utilizado saldo Wis !")
			_nSaldo		:= _nSaldoWis
		ElseIf _nSaldoWis > _nSaldoSB2
			Aadd(_aMens, "Produto "+AllTrim(_cCodProdRet)+", com Saldo Protheus "+AllTrim(Str(_nSaldoSB2))+" menor que saldo Wis "+AllTrim(Str(_nSaldoWis))+", sera utilizado saldo Protheus !")
			_nSaldo		:= _nSaldoSB2
		Else 
			_nSaldo		:= _nSaldoSB2
			Aadd(_aMens, "Produto "+AllTrim(_cCodProdRet)+", com saldo Protheus "+AllTrim(Str(_nSaldoSB2))+" Saldo atual Wis "+AllTrim(Str(_nSaldoWis))+", sera utilizado saldo Protheus !")
		Endif
	End Sequence
	_cMens := ""
	For _nPos := 1 To Len(_aMens)
		_cMens += " "
		_cMens += _aMens[_nPos]
	Next
Return {_lRet, _nSaldo, AllTrim(_cMens), _cCodProdRet, _cArmazemRet, _cGrupoRet}



/*/{Protheus.doc} zSaldoWis
Responsável por verificar limite de crédito na liberação
@author 	DAC-Denilso
@since 		15/02/2022
@version 	undefined
@param 		_cProduto	- Produto
			_cMarca		- Marca 
			_cArmazem	- Armazém
@type 		user function
@project    
@return		_nSaldoWis - Saldo existente no WIS
@ Obs		
@history    Evandro 		26/05/2022	- Localizar Saldo WiS conexão Tclink 
			DAC Denilso 	19/05/2023 	- PEC042 - Controle de saldo e e-mail apos integracao de armazenagem 
										  Zé ajustou a funcionalidade para localizar resserva de acordo com parâmetro _lResIntegr
/*/
User Function zSaldoWis(_cProduto, _cMarca, _cArmazem)
	Local cQryWis	  	:= ""
	Local cAlsWis		:= GetNextAlias()
	Local _nSaldoWis    := 0
	Local _cConectWis   := AllTrim(SuperGetMV( "CMV_PEC031"  ,,"WIS.V_ENDERECO_ESTOQUE@DBLINK_WISPROD"))
	Local _lResIntegr   := SuperGetMV( "CMV_PEC040"  ,,.T.)
	Local _lVlLocWis   	:= SuperGetMV( "CMV_PEC041"  ,,.T.)

	Default _cMarca 	:= ""
	Default _cArmazem	:= ""

    If Select( (cAlsWis) ) > 0
	    (cAlsWis)->(DbCloseArea())
	EndIf
	//implementado por José Totvs 19/05/2023
	If _lResIntegr
		cQryWis := " SELECT CASE WHEN NVL((SUM(ESTWIS.QT_ESTOQUE - ESTWIS.QT_RESERVA_SAIDA-ESTWIS.QT_TRANSITO_SAIDA)),0) > 0 THEN NVL((SUM(ESTWIS.QT_ESTOQUE - ESTWIS.QT_RESERVA_SAIDA-ESTWIS.QT_TRANSITO_SAIDA)),0) ELSE 0 END AS QTDE_EST "
	Else
		cQryWis := " SELECT NVL(SUM(ESTWIS.QT_ESTOQUE - ESTWIS.QT_RESERVA_SAIDA), 0) AS QTDE_EST "
	Endif
	//cQryWis := " SELECT NVL(SUM(ESTWIS.QT_ESTOQUE - ESTWIS.QT_RESERVA_SAIDA), 0) AS QTDE_EST "
	cQryWis += " FROM " + _cConectWis + " ESTWIS "
    cQryWis += " WHERE RTRIM(LTRIM(ESTWIS.CD_PRODUTO)) = '" + AllTrim(_cProduto) + "' "

	If AllTrim(_cMarca) $ "HYU_SBR"
    	cQryWis += " AND CD_EMPRESA = 1006 " //-- HYU SBR
	ElseIf AllTrim(_cMarca) $ "CHE"  
    	cQryWis += " AND CD_EMPRESA = 1002 " //-- CHE
	EndIf
 	
	If _lVlLocWis	
		If _cArmazem == "01" //BARUERI
			cQryWis += " AND ARMAZEM = 'BAR' " //-- Armazenagem BARUERI.
		ElseIf _cArmazem == "11" //FRANCO DA ROCHA
			cQryWis += " AND ARMAZEM = 'FDR' " //-- Armazenagem FRANCO DA ROCHA
		EndIf
	Endif
 
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryWis), cAlsWis, .T., .T. )

	DbSelectArea((cAlsWis))
	(cAlsWis)->(dbGoTop())
    If !(cAlsWis)->(EoF())
        _nSaldoWis := (cAlsWis)->QTDE_EST
    else
        _nSaldoWis := 0
    EndIf
	If Select((cAlsWis)) <> 0
		(cAlsWis)->(DbCloseArea())
		Ferase(cAlsWis+GetDBExtension())
	Endif 
Return(_nSaldoWis)




/*/{Protheus.doc} U_ZRETMsgJson
//Retorna Numero do Erro 
@author DAC
@since 14/07/2022
@version undefined
@param 		_aDir = Matriz com o nome das pastas ex {"import\empresa\pedido"}
			_lJob = Indica se esta processando em job e ou poderá mostrar msg na tela defaulf .T.
@type function
/*/
User Function XVALIDPasta(_aDir,_lJob)
	Local _aPasta   := {}                    
	Local _nPos     
	Local _nTam
	Local _nCount
	Local _cVar
	Local _lRet  	:= .F. 

	Default _lJob 	:= .T.
	Default _aDir	:= {}

	Begin Sequence
		If Len(_aDir) == 0               
			If _lJob
				Conout("[XVALIDPasta] Não existe pasta informadas nos parâmetros verificar")
			Else
				Aviso("ATENCAO","Não existe pasta informadas nos parâmetros verificar [XVALIDPasta] !",{"Sair"})
			Endif
			Break
		Endif
		For _nPos 	:= 1 To Len(_aDir) 
			_cArq 	:= _aDir[_nPos] 
			_nTam 	:= Len(_cArq)
			_cVar 	:= ""  
			_aPasta := {}
			For _nCount := 1 To Len(_cArq)
			If SubsTr(_cArq,_nCount,1) == "\" .and. !Empty(_cVar)
					Aadd(_aPasta,_cVar)        
					_cVar := ""
					Loop
			Endif
			_cVar +=	SubsTr(_cArq,_nCount,1)
			Next	
			Aadd(_aPasta,_cVar) 
			If Len(_aPasta) == 0                                                     
				If _lJob
					Conout("[XVALIDPasta] Não existe pasta informadas nos parâmetros verificar !")
				Else
					Aviso("XVALIDPasta","Não existe pasta informadas nos parâmetros verificar [XVERPasta] !",{"Sair"})
				Endif
				Break
			Endif       
			_cVar := ""
			For _nCount := 1 To Len(_aPasta)
				If Empty(_aPasta[_nCount])
					Loop			
				Endif
				If _nCount <> Len(_aPasta)
					_cVar += ( _aPasta[_nCount] + "\" )
				Else
					_cVar += (_aPasta[_nCount])							
				Endif 		
				If !ExistDir( _cVar )
					If MakeDir( _cVar ) != 0                                       
						If _lJob                                                     
							Conout("[XVALIDPasta] Não foi possivel cria a pasta "+_cVar)
						Else						
							Aviso("ATENCAO","Não foi possivel cria a pasta "+_cVar +" [XVALIDPasta] !",{"Sair"})
						Endif
						Break
					Endif				
				Endif
			Next
		Next
		_lRet := .T.
	End Begin
Return _lRet							


//Verificar ultimo numero do cadastro
User Function XVERNUMeracao( _cTab, _cCampo, _cNum )
	Local _cAliasPesq	:= GetNextAlias()   
	Local _cNumRet		:= "" 
	Local _cCampoPesq
	Local _nTam			
	Local _cQuery
	Local _cCampoFil

	Default _cTab 	:= ""
	Default _cCampo := ""
	Default _cNum	:= ""

	Begin Sequence
		_cNumRet	:= _cNum  //guardo o numero que foi enviado
		If _cAliasPesq == Nil  //pode acontecer de não gerar o arquivo normalmente quando esta recebendo um rest
			Break			
		EndIf
		If Empty(_cTab) .or. Empty(_cCampo)
			Break
		Endif
		//Verificao se existe o campo	
		_nPos	:= (_cTab)->(FieldPos(_cCampo))
		If _nPos == 0
			Break
		EndIf
		_cCampoPesq	:= Upper(AllTrim(_cCampo))
		_nTam		:= TamSx3(AllTrim(_cCampo))[1]

		//monta query
		_cCampoFil := If(Substr(_cTab,1,1)=="S",Substr(_cTab,2,2), _cTab)
		_cQuery := " SELECT MAX("+_cCampoPesq+") NNUM"
		_cQuery += " FROM "+ RetSqlName( _cTab ) 
		_cQuery += " WHERE "+_cCampoFil+"_FILIAL = '"+ xFilial(_cTab)+ "' "
		_cQuery += "	AND D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQuery), _cAliasPesq, .T., .T. )
		If (_cAliasPesq)->(Eof()) .or. Val((_cAliasPesq)->NNUM) == 0
			Break
		EndIf
		//somente se for menor
		If Val(_cNum) < Val((_cAliasPesq)->NNUM) + 1 
			_cNumRet	:= StrZero(Val((_cAliasPesq)->NNUM) + 1,_nTam)
		ElseIf ValType(_cNum) == "N" .and. Valtype((_cAliasPesq)->NNUM) == "N"
			If _cNum < (_cAliasPesq)->NNUM + 1 
				_cNumRet	:= (_cAliasPesq)->NNUM + 1
			EndIf	 
		ElseIf ValType(_cNum) == "C" .and. Valtype((_cAliasPesq)->NNUM) == "N"
			If Val(_cNum) < (_cAliasPesq)->NNUM + 1 
				_cNumRet	:= StrZero((_cAliasPesq)->NNUM + 1,_nTam)
			EndIf	 
		ElseIf ValType(_cNum) == "N" .and. Valtype((_cAliasPesq)->NNUM) == "C"
			If _cNum < (_cAliasPesq)->NNUM + 1 
				_cNumRet	:= Val((_cAliasPesq)->NNUM) + 1
			EndIf	 
		Endif
	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 
Return _cNumRet 



/*/{Protheus.doc} zTpOper
//Verifica informaÃƒÂ§ÃƒÂµes de campos obrigatÃƒÂ³rios 
@author Evandro Mariano
@since 06/05/2022
@version undefined
@param _aMsg, array, descriÃƒÂ§ÃƒÂ£o
@type function
/*/
User Function zTpOper(_cCliente, _cLoja, _cTipoPed)

	Local _cAliasSFM		:= GetNextAlias()   
	Local _cQuery			:= ""   
	Local lSeekSA1          := .F.
	Local lZFMan			:= .F.
	Local lZFDed			:= .F.
	//Local lGRTrib			:= .F.
	Local _cRet 			:= " "
	Local _aAreaSA1			:= SA1->(GetArea())
	Local _cTipoOrc			:= AllTrim(Posicione("VX5", 1, XFilial("VX5") + "Z02" + PadR( AllTrim(_cTipoPed), TamSX3("VX5_CODIGO")[1] ), "VX5_DESCRI")) //Tipo do OrÃƒÂ§amento (Venda/Transferencia/Remessa)
	Local _cCnpjTransf  	:= AllTrim(SuperGetMV( "CMV_WSR019"  ,,"03471344"))	//Raiz CNPJ de transferencia

	//Local _cZFVenda		:= AllTrim(SuperGetMV( "CMV_WSR021"  ,,"AC|93;AP|92;AM|93;RO|93;RR|93"))	//Zona Franca - Venda
	//Local _cZFRemessa		:= AllTrim(SuperGetMV( "CMV_WSR024"  ,,"AC|76;AP|76;AM|76;RO|76;RR|76"))	//Zona Franca - Remessa
	Local _cZFranca			:= AllTrim(SuperGetMV( "CMV_WSR033"  ,,"AC;AP;AM;RO;RR"))	//Zona Franca
	Local _cProtocol 		:= AllTrim(SuperGetMV( "CMV_WSR052"  ,,"SP;CE"))	//Zona Franca
	//Local _cGRTrib			:= AllTrim(SuperGetMV( "CMV_WSR052"  ,,"100;200"))	//Zona Franca

	Local _cBxInter 		:= AllTrim(SuperGetMV( "CMV_WSR039"  ,,"011"))		//Codigo Baixa Interna
	Local _cOpUsoInt		:= AllTrim(SuperGetMV( "CMV_WSR043"  ,,"75"))		//OperaÃƒÂ§ÃƒÂ£o Uso Interno

	Local _cBxScrap			:= AllTrim(SuperGetMV( "CMV_WSR027"  ,,"013"))		//Codigo Scrap
	Local _cOpRefugo		:= AllTrim(SuperGetMV( "CMV_WSR022"  ,,"59"))		//OperaÃƒÂ§ÃƒÂ£o Refugo

	Local _cBxTfUso			:= AllTrim(SuperGetMV( "CMV_WSR040"  ,,"014"))		//Codigo Transferencia Uso
	Local _cOpTfUso			:= AllTrim(SuperGetMV( "CMV_WSR044"  ,,"98"))		//OperaÃƒÂ§ÃƒÂ£o Transferencia Uso

	Local _cBxRemAr			:= AllTrim(SuperGetMV( "CMV_WSR046"  ,,"015"))		//Codigo Remessa Armazenamento
	Local _cOpRemAr			:= AllTrim(SuperGetMV( "CMV_WSR048"  ,,"XA"))		//OperaÃƒÂ§ÃƒÂ£o Remessa Armazenamento

	Local _cBxRemTs			:= AllTrim(SuperGetMV( "CMV_WSR047"  ,,"016"))		//Codigo Remessa Teste
	Local _cOpRemTs			:= AllTrim(SuperGetMV( "CMV_WSR049"  ,,"XB"))		//OperaÃƒÂ§ÃƒÂ£o Remessa Teste

	Local _cOpTransf		:= AllTrim(SuperGetMV( "CMV_WSR020"  ,,"81"))		//OperaÃƒÂ§ÃƒÂ£o Transferencia
	Local _cOpVenda			:= AllTrim(SuperGetMV( "CMV_WSR023"  ,,"90"))		//OperaÃƒÂ§ÃƒÂ£o Venda
	Local _cOpVdUso			:= AllTrim(SuperGetMV( "CMV_WSR041"  ,,"XX"))		//OperaÃƒÂ§ÃƒÂ£o Venda/uso
	Local _cOpRemessa		:= AllTrim(SuperGetMV( "CMV_WSR025"  ,,"77"))		//OperaÃƒÂ§ÃƒÂ£o Remessa

	Local _cOpVEndaZF		:= AllTrim(SuperGetMV( "CMV_WSR021"  ,,"ZF|93;ZD|92"))		//OperaÃƒÂ§ÃƒÂ£o Venda/uso ZF
	Local _cOpVdUsoZF		:= AllTrim(SuperGetMV( "CMV_WSR042"  ,,"ZF|xx;ZD|xy"))		//OperaÃƒÂ§ÃƒÂ£o Venda/uso ZF
	Local _cOpRemessaZF		:= AllTrim(SuperGetMV( "CMV_WSR024"  ,,"ZF|77;ZD|77"))		//OperaÃƒÂ§ÃƒÂ£o Venda/uso ZF

	Local _cOpVendaZFFM     := ' '
	Local _cUFCliente		:= ' '

	//SB1->( DbSetOrder(1))
	//SB1->( DbSeek(XFilial("SB1")+_cCodItem) )
	//lGRTrib := AllTrim(SB1->B1_GRTRIB) $ _cGRTrib		

	//1a Regra - Baixa Interna
	If _cTipoPed == _cBxInter //011
		_cRet := _cOpUsoInt
	ElseIf _cTipoPed == _cBxScrap //013
		_cRet := _cOpRefugo
	ElseIf _cTipoPed == _cBxTfUso //014
		_cRet := _cOpTfUso
	ElseIf _cTipoPed == _cBxRemAr //015
		_cRet := _cOpRemAr
	ElseIf _cTipoPed == _cBxRemTs //016
		_cRet := _cOpRemTs
	EndIf

	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(XFilial("SA1")+_cCliente+_cLoja))

		lSeekSA1 := .T.
		_cUFCliente := SA1->A1_EST
		If _cUFCliente $ _cZFranca
			lZFMan := .T.
		EndIf

		_cQuery := " SELECT "
		_cQuery += " 	SFM.FM_CLIENTE, SFM.FM_LOJACLI, SFM.FM_TIPO "
		_cQuery += " FROM " + RetSqlName("SFM") + " SFM "
		_cQuery += " WHERE "
		_cQuery += " 	SFM.FM_FILIAL  = '"+xFilial("SFM")+"' AND "
		_cQuery += " 	SFM.D_E_L_E_T_ = ' ' AND "
		_cQuery += "	( "
		_cQuery += " 		( SFM.FM_CLIENTE = '" + _cCliente + "' AND "
		_cQuery += " 		  SFM.FM_LOJACLI = '" + _cLoja    + " ' "
		_cQuery += "		) OR 
		_cQuery += "		( SFM.FM_EST     = '" + _cUFCliente + " ' AND "
		_cQuery += "		  SFM.FM_CLIENTE = ' ' "
		_cQuery += "		) "
		_cQuery += "	 ) "
		_cQuery += " ORDER BY SFM.FM_CLIENTE DESC "

		dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQuery), _cAliasSFM, .T., .T. )

		(_cAliasSFM)->(dbGoTop())
		If !(_cAliasSFM)->(EoF())
			lZFDed := .T.
			_cOpVendaZFFM := ((_cAliasSFM)->FM_TIPO)
		EndIf
		(_cAliasSFM)->(DbCloseArea())

		If SA1->A1_EST $ _cProtocol
			lProtocol := .T.
		EndIf

	EndIf

	//2a - Regra - Prioridade Transferencia
	If Empty(_cRet)
		If lSeekSA1
			If Substring(SA1->A1_CGC,1,8) == _cCnpjTransf //'03471344'
				_cRet := _cOpTransf
			//ElseIf SA1->A1_XTIPO == "Z"
			//	_cRet := _cOpTransf
			EndIf
		EndIf
	EndIf

	If Empty(_cRet)

		If _cTipoOrc == "VENDA"

			If lZFDed
				_cRet := _cOpVendaZFFM // Substr( _cOpVEndaZF,(At("ZD", _cOpVEndaZF )+3),2)
			ElseIf lZFMan
				_cRet := Substr( _cOpVEndaZF,(At("ZF", _cOpVEndaZF )+3),2)
			Else
				_cRet := _cOpVenda
			EndIf

		ElseIf _cTipoOrc == "REMESSA"

			If lZFDed
				_cRet := Substr( _cOpRemessaZF,(At("ZD", _cOpRemessaZF )+3),2)
			ElseIf lZFMan
				_cRet := Substr( _cOpRemessaZF,(At("ZF", _cOpRemessaZF )+3),2)
			Else
				_cRet := _cOpRemessa
			EndIf

		ElseIf _cTipoOrc == "VENDA/USO"

			If lZFDed
				_cRet := Substr( _cOpVdUsoZF,(At("ZD", _cOpVdUsoZF )+3),2)
			ElseIf lZFMan
				_cRet := Substr( _cOpVdUsoZF,(At("ZF", _cOpVdUsoZF )+3),2)
			Else
				_cRet := _cOpVdUso
			EndIf
		
		ElseIf _cTipoOrc == "TRANSFERENCIA"
			_cRet := _cOpTransf

		ElseIf _cTipoOrc == "USO/INTERNO"
			_cRet := _cBxScrap

		ElseIf _cTipoOrc == "REFUGO"
			_cRet := _cOpRefugo

		ElseIf _cTipoOrc == "TRANSF/USO"
			_cRet := _cOpTfUso
		EndIf

	//Else
	//	_cRet := _cOpVenda
	Endif

	RestArea(_aAreaSA1)

Return(_cRet)




/*/{Protheus.doc} XRESCAOAPEC
@param  	
@author 	CAOA - CAOA - A.Carlos
@version  	P12.1.23
@since  	06/01/2022
@return  	NIL
@project
@history    Tranferência Interna Mútipla (Divergência)   
			PEC042 - Controle de saldo e e-mail apos integracao de armazenagem - Ajuste para localizar dcto D3 NextNumero
@obs         
  	VM5.VM5_CODIGO , (cAlVM5)->VM6_QTORIG - (cAlVM5)->VM6_QTCONF , cArmorig, cArmdes
    	     01                         02    -    Qtde                   03        04
	É necessario que:
	O parametro MV_LOCALIZ = S
	O produto com codigo PA001 tenha controle de endereco ativo
	O armazem padrao definido no produto deve ter 2 endereços: ENDER01 (61) e ENDER02 (65)
	Saldo inicial igual ou superior a 1
	E este saldo deve ser endereçado ao ENDER01
/*/
User Function XRESCAOAPEC(_cNumOrc, _lReserva, _aRegVS3, _cArmOrig, _cArmDes, _lTela)
		
	Local _aAuto  		:= {}
	Local _aItens 		:= {}
	Local _aMsg			:= {}
	Local _nOpcAuto     := 0
	Local _cDocumento   := ""
	Local _lRet 		:= .T.
	Local _cMens
	Local _nPos

	Local aLogAuto := {}
	//Variáveis de controle do ExecAuto
	Private lMSHelpAuto     := .T.
	Private lAutoErrNoFile  := .T.
	Private lMsErroAuto     := .F.

	Default _cNumOrc	:= ""
	Default _cArmOrig  	:= ""    //'61' Codigo do Armazem de Pecas RESERVADAS             
	Default _cArmDes   	:= ""    //'65' Armazém para Peças com divergência                
	Default _aRegVS3 	:= {}
	Default _lTela		:= .F.
	Default _lReserva	:= .T.

	//Private cCodMov     := '501'
	//Private cCC         := '13030177MA'
	//Private nVlrCusto   := 1.00
	//Private dDtaTransf  := Date()
	//Private cDoc        := '777'

	Begin Sequence

		//Verificar orçamento
		If Empty(_cNumOrc)
			AAdd(_aMsg,"Não informado o numero orçamento, não será realizada a Reserva comunicar ADM Sistemas!!! ")
			_lRet := .F.
			Break
		Endif	
		If VS1->VS1_NUMORC <> _cNumOrc
			VS1->(DbSetOrder(1))
			If !VS1->(DbSeek(XFilial("VS1")+_cNumOrc))
				AAdd(_aMsg,"Não localizado orçamento " +_cNumOrc+ ", não será realizada a Reserva comunicar ADM Sistemas!!! ")
				_cNumOrc := ""
				_lRet := .F.
				Break
			EndIf
		EndIf
		If VS1->VS1_STATUS $ "X_C"  //VS1->VS1_STATUS $ "X_C"ja esta faturado
			Aadd(_aMsg, "Orçamento " +_cNumOrc+ " com status "+VS1->VS1_STATUS+", que nao permite este cancelamento !" )
			_lRet := .F.
			Break
		Endif

		_nOpcAuto := 3   //Inclusao
	
		Begin Transaction
			//incluir itens VS3
			//montar por numero de registro	
			//_cDocumento := GetSxeNum("SD3","D3_DOC")  //não pode ser pelo SX
			//Implementado pois em alguns casos não esta conseguindo localizar numeraçãp
			_cDocumento := ""
			For _nPos := 1 To 10
				_cDocumento  := Criavar("D3_DOC")
				_cDocumento	:= IIf(Empty(_cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),_cDocumento)
				If !Empty(_cDocumento)
					Exit
				Endif 
			Next 	
			If Empty(_cDocumento)
				_cMens := "Não foi possivel montar numeração SD3, para gerar movimentação." 
				Aadd(_aMsg,_cErro)
				_lRet := .F.
				Disarmtransaction()
			Else
				_cDocumento	:= A261RetINV(_cDocumento)
			Endif 
			If _lRet 		
				_aItens 	:= XRESCAOATR(_cNumOrc, _lReserva, @_aRegVS3, _cArmorig, _cArmdes, _cDocumento, @_aMsg)
				If Len(_aItens) == 0
					AAdd(_aMsg,"Não foi possivel fazer transferências ref  orçamento " +_cNumOrc+ ", não será realizada a Reserva comunicar ADM Sistemas!!! ")
					_lRet := .F.
					Disarmtransaction()
				EndIf
			Endif	
			If _lRet 		
				_aAuto := Aclone({})
				Aadd(_aAuto,{_cDocumento , dDataBase})    //Cabecalho
				For _nPos := 1 To Len(_aItens)
					Aadd(_aAuto,_aItens[_nPos])
				Next

				MSExecAuto({|x,y| mata261(x,y)}, _aAuto, _nOpcAuto)
				if lMsErroAuto
					//Pegando log do ExecAuto
					aLogAuto := GetAutoGRLog()
					
					_cMens := "Problemas no execauto MATA261, comunicar ADM Sistemas !!! " 
					AAdd(_aMsg,_cMens)
					_lRet := .F.
					
					//MostraErro()
					Disarmtransaction()
				EndIf
			Endif	
		End Transaction		 
	End Sequence	
	If !_lRet
		AAdd(_aMsg, "Ocorreram problemas na movimentação de armazem  para o orçamento "+_cNumOrc )
		_cDocumento := "NA"			
	EndIf
	_cMens := ""
	If Len(_aMsg)
		For _nPos := 1 To Len(_aMsg)
			_cMens += Upper(_aMsg[_nPos]) + CRLF
		Next	
	EndIf

	//Caso não tenha o numero de orçamento atualizar VS1
	If !Empty(_cNumOrc)
		VS1->(RecLock("VS1",.F.))
		VS1->VS1_OBSAGL		:= _cMens + AllTrim(VS1->VS1_OBSAGL)
		If _lRet
			VS1->VS1_STARES 	:= U_XRCAOVS3(_cNumOrc)  //Retorna o Status
			If _lReserva
				VS1->VS1_RESERV	:= "1"
			Else
				VS1->VS1_RESERV	:= "0"
			EndIF
		EndIf	
		VS1->(MsUnlock())
	Endif	
	//caso possa mostrar na tela
	If _lTela
		MSGINFO( _cMens, "[ XRESCAOAPEC ] - Atenção" )
		Conout("XRESCAOAPEC - "+ _cMens)
	Else
		Conout("XRESCAOAPEC - "+ _cMens)
	EndIf
Return _cDocumento


//Monta transferência Parcial
Static Function XRESCAOATR(_cNumOrc, _lReserva, _aRegVS3, _cArmorig, _cArmdes, _cDocumento, _aMsg)
	Local _cAliasPesq	:= GetNextAlias()   
	Local _aItem 		:= {}
	Local _aRet			:= {}
	Local _cWhere		:= ""
	Local _lGravaVS3	:= .F.
	Local _lRet			:= .T.
	Local _nQtdeItem	:= 0
	Local _cCodProd
	Local _nPos
	Local _nQtde
	Local _cObs

	Begin Sequence
		If Len(_aRegVS3) > 0
			_cWhere := " AND VS3.R_E_C_N_O_  IN ( "
			For _nPos := 1 To Len(_aRegVS3)
				_cWhere += AllTrim(Str(_aRegVS3[_nPos]))
				If _nPos ==  Len(_aRegVS3)
					_cWhere += ") "
				Else
					_cWhere += ","
				EndIf
			Next
		Else
			_lGravaVS3 := .T.
			_cWhere := "AND VS3.VS3_NUMORC	= '"+_cNumOrc+"' "	
		EndIf
		_cWhere := "%"+_cWhere+"%"

		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	ISNULL(VS3.R_E_C_N_O_,0) NREGVS3
			FROM %Table:VS3% VS3	
			WHERE 	VS3.VS3_FILIAL 	= %XFilial:VS3%
				AND	VS3.%notDel%
				%Exp:_cWhere%
		EndSql

		If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGVS3 == 0
			Break
		EndIf	

		While (_cAliasPesq)->(!Eof()) 
			_aItem := {}
			VS3->(DbGoto( (_cAliasPesq)->NREGVS3 ))
			If Len(SB1->B1_COD) < Len(VS3->VS3_CODITE)
				_cCodProd := SubsTr(VS3->VS3_CODITE,1,Len(SB1->B1_COD))
			Else
				_cCodProd := VS3->VS3_CODITE
			EndIf	
			//Itens a Incluir
			SB1->(DbSetOrder(1))
			If !SB1->(DbSeek(xFilial("SB1")+_cCodProd))
				AAdd(_aMsg,"Não localizado codigo do produto "+_cCodProd+" !!! ")
				_lRet := .F.
				Break
			Endif	

			//caso seja para reservar e exista uma reserva não executar
			_nQtde 		:= VS3->VS3_QTDITE
			_nQtdeItem 	:= U_XLOCVE6O(VS3->VS3_NUMORC, VS3->VS3_CODITE)	
			//Se for maior que zero e a quantidade total a ser reservada for maior ou igual VE6 já esta reservado, se for menor é parcial	
			If _lReserva  //.and. VS3->VS3_RESERV == "1" 
				If _nQtdeItem > 0 .and. VS3->VS3_QTDITE >= _nQtdeItem  //ja tem reserva para este item
					AAdd(_aMsg,"Item ja esta reservado, codigo do produto "+_cCodProd+" !!! ")
					_lRet := .F.
					Break
				Endif	
			//Se for igual a zero e a quantidade total a ser reservada for menor VE6 não considerar como reservado 
			ElseIf !_lReserva //.and. VS3->VS3_RESERV == "0" 
				If _nQtdeItem > 0 .or. VS3->VS3_QTDITE < _nQtdeItem  //ja tem reserva para este item
					//Apagar o parcial que esta reservado
					_nQtde := _nQtdeItem   //If(_nQtdeItem > 0, _nQtdeItem, VS3->VS3_QTDITE)
				ElseIf _nQtdeItem == 0 
					AAdd(_aMsg,"Item não possui reserva codigo do produto "+_cCodProd+" !!! ")
					_lRet := .F.
					Break
				Endif	
			EndIf
			//Indica que é necessário guardar os registros atualizados
			If _lGravaVS3
				Aadd(_aRegVS3,(_cAliasPesq)->NREGVS3)
			EndIf
			_cArmazem 		:= VS3->VS3_LOCAL
			If _lReserva
				_cOrigem 	:= If(Empty(_cArmOrig),	_cArmazem					, _cArmOrig)
				_cDestino	:= If(Empty(_cArmDes) , AllTrim(GETMV("MV_RESITE")) , _cArmDes )   //'61' Codigo do Armazem de Pecas RESERVADAS  
				_cObs		:= "Reserva ref. orcamento " +_cNumOrc
			Else
				_cOrigem 	:= If(Empty(_cArmOrig),	AllTrim(GETMV("MV_RESITE"))	, _cArmOrig)
				_cDestino	:= If(Empty(_cArmDes) , _cArmazem 					, _cArmDes )   //'61' Codigo do Armazem de Pecas RESERVADAS  
				_cObs		:= "Retirada reserva ref. orcamento " +_cNumOrc
			Endif
			If Empty(_cOrigem) .or. Empty(_cDestino)
				AAdd(_aMsg,"Não informado armazem origem e ou destino para orçamento " +_cNumOrc+ ", não será realizada processo de Reserva comunicar ADM Sistemas!!! ")
				_lRet := .F.
				Break
			ElseIf _cOrigem == _cDestino
				AAdd(_aMsg,"Verificar armazem origem "+_cOrigem+" e ou destino "+_cDestino+" para orçamento " +_cNumOrc+ " os mesmos estão iguais, não será realizada processo de Reserva comunicar ADM Sistemas!!! ")
				_lRet := .F.
				Break
			EndIf
			//origem
			//aadd(aLinha,{"D3_FILIAL" ,  	xFilial("SD3")			, Nil})
			aadd(_aItem,{"D3_COD"    	, SB1->B1_COD 				, Nil}) //Cod Produto origem
			aadd(_aItem,{"D3_DESCRI" 	, SB1->B1_DESC 				, Nil}) //descr produto origem
			aadd(_aItem,{"D3_UM"     	, SB1->B1_UM				, Nil}) //unidade medida origem
			aadd(_aItem,{"D3_LOCAL"  	, _cOrigem					, Nil}) //armazem origem
			aadd(_aItem,{"D3_LOCALIZ"	, PadR(_cOrigem, tamsx3('D3_LOCALIZ') [1])	,Nil}) //Informar endereço origem
			//aAdd(_aItem,{"D3_TM"     , Alltrim(cCodMov)		, Nil }) //Tipo Movimento
			//aAdd(_aItem,{"D3_DOC"    , Alltrim(cDoc)			, Nil }) //Documento
			//aAdd(_aItem,{"D3_EMISSAO", dDtaTransf				, Nil }) //EMISSAO
			//Destino
			aadd(_aItem,{"D3_COD"		, SB1->B1_COD				, Nil}) //cod produto destino
			aadd(_aItem,{"D3_DESCRI"	, SB1->B1_DESC				, Nil}) //descr produto destino
			aadd(_aItem,{"D3_UM"		, SB1->B1_UM				, Nil}) //unidade medida destino
			aadd(_aItem,{"D3_LOCAL"		, _cDestino					, Nil}) //armazem destino  era  SB1->B1_LOCPAD
			aadd(_aItem,{"D3_LOCALIZ"	, PadR(_cDestino, tamsx3('D3_LOCALIZ') [1]),	Nil}) //Informar endereço destino
	
			aadd(_aItem,{"D3_NUMSERI"	, ""						, Nil}) //Numero serie
			aadd(_aItem,{"D3_LOTECTL"	, IIf(!Empty(VS3->VS3_LOTECT),VS3->VS3_LOTECT,"")		, Nil}) //Lote Origem
			aadd(_aItem,{"D3_NUMLOTE"	, IIf(!Empty(VS3->VS3_NUMLOT),VS3->VS3_NUMLOT,"")		, Nil}) //sublote Origem
			aadd(_aItem,{"D3_DTVALID"	, IIf(!Empty(VS3->VS3_DTVALI),VS3->VS3_DTVALI,cTod(""))	, Nil}) //data validade
			aadd(_aItem,{"D3_POTENCI"	, 0 						, Nil}) // Potencia
			aadd(_aItem,{"D3_QUANT"		, _nQtde					, Nil}) //Quantidade
			aadd(_aItem,{"D3_QTSEGUM"	, 0 						, Nil}) //Seg unidade medida
			aadd(_aItem,{"D3_ESTORNO"	, ""						, Nil}) //Estorno
			aadd(_aItem,{"D3_SEQCALC"	, ""						, Nil}) //Seq. 
			aadd(_aItem,{"D3_LOTECTL"	, IIf(!Empty(VS3->VS3_LOTECT),VS3->VS3_LOTECT,criavar("D3_LOTECTL")) , Nil}) //Lote destino
			aadd(_aItem,{"D3_DTVALID"	, ''						, Nil}) //data validade Destino
			aadd(_aItem,{"D3_ITEMGRD"	,""							, Nil})	//Item Grade 
			If SD3->(FieldPos("D3_GRUPO")) <> 0
				aadd(_aItem,{"D3_GRUPO"	,SB1->B1_GRUPO 				, Nil})	//Item Grade 
			EndIf
			If SD3->(FieldPos("D3_OBSERVA")) <> 0
				aadd(_aItem,{"D3_OBSERVA"	,_cObs					, Nil})	//Item Grade 
			EndIf

		/*
			aadd(_aItem,{"D3_NUMLOTE"	, ""						, Nil}) //sublote destino
			aadd(_aItem,{"D3_NUMSEQ"	, ""						, Nil}) // Numero sequencia D3_NUMSEQ
			aadd(_aItem,{"D3_GRUPO"		, SB1->B1_GRUPO				, Nil}) //grupod produto
			aadd(_aItem,{"D3_LOTECTL"	, ""						, Nil}) //Lote Origem
			aadd(_aItem,{"D3_DTVALID"	, ''						, Nil}) //validade lote destino
			aadd(_aItem,{"D3_ITEMGRD"	, ""						, Nil}) //Item Grade
			aadd(_aItem,{"D3_CODLAN"	, ""						, Nil}) //cat83 prod origem
			aadd(_aItem,{"D3_CODLAN"	, ""						, Nil}) //cat83 prod destino
			aadd(_aItem,{"D3_CONTA"		, SB1->B1_CONTA				, Nil}) //conta contabil produto 
			aadd(_aItem,{"D3_ITEMCTA"	, SB1->B1_ITEMCC			, Nil}) //item contabil produto 
			aadd(_aItem,{"D3_CLVL"		, SB1->B1_CLVL				, Nil}) //classe valor produto 
			aadd(_aItem,{"D3_CC"		, cCC						, Nil}) //centro custo produto 
			aadd(_aItem,{"D3_STATUS"	,"SERVICO NAO EXECUTADO"	, Nil}) //SATATUS registro
		*/
			aAdd(_aRet, _aItem)
			//Gravar e ou retirar  VS6 com informações de reserva 
			//Gravar dados no VS3
			VS3->(DbGoto( (_cAliasPesq)->NREGVS3 ))
			If !VS3->(Reclock("VS3",.F.))
				_lRet := .F.
				Break
			EndIf
			If _lReserva
				VS3->VS3_DOCSDB := _cDocumento
				VS3->VS3_RESERV := "1"
				VS3->VS3_QTDRES	:= VS3->VS3_QTDITE
			Else
				VS3->VS3_DOCSDB := ""
				VS3->VS3_RESERV := "0"
				If VS3->VS3_QTDRES	> 0
					VS3->VS3_QTDRES	:= 0
				EndIf	
			EndIf
			//VS3->VS3_LOCAL  := _cDestino  //o armazem não muda deve ser o inicial (colocado pelo SB1) no SIGAPEC faturamento não muda o armazem após faturar DAC 12/10/2022
			VS3->(MsUnlock())
			//Atualizar VE6
			OX001VE6(_cNumOrc, _lReserva) // RESERVA / DESRESERVA DO ITEM
			//Reposiciono para grarantir que esta no registro correto
			VS3->(DbGoto( (_cAliasPesq)->NREGVS3 ))
			AAdd(_aMsg, "Gravado movimentação do produto "+AllTrim(VS3->VS3_CODITE)+" qtde "+AllTrim(Str(VS3->VS3_QTDITE))+" do Armazem "+_cOrigem+" para armazem "+_cDestino)
			AAdd(_aMsg, "Dcto movimentação "+_cDocumento)	
			(_cAliasPesq)->(DbSkip())
		EndDo
	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 
	//caso ocorreu erro zero a matriz
	If !_lRet
		_aRet := {}
	EndIf
Return _aRet


//Verificar Status da Reserva
User Function XRCAOVS3(_cNumOrc)
	Local _cAliasPesq	:= GetNextAlias()   
	Local _cStatus 		:= "3"  //1=Reservado;2=Parcialmente Reservado;3=Nao Reservado

	Begin Sequence
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	COUNT(VS3.VS3_NUMORC) AS TOTVS3,
					COUNT(VS3R.VS3_RESERV) AS RESERVADO
			FROM %Table:VS3% VS3	
			LEFT JOIN %Table:VS3% VS3R 
				ON	VS3R.%notDel% 	
				AND VS3R.VS3_FILIAL = %XFilial:VS3%
				AND	VS3R.VS3_NUMORC	= VS3.VS3_NUMORC	
				AND VS3R.VS3_RESERV = '1'
			WHERE 	VS3.%notDel%
				AND VS3.VS3_FILIAL 	= %XFilial:VS3%
				AND VS3.VS3_NUMORC	= %Exp:_cNumOrc% 
		EndSql

		If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->TOTVS3 == 0 .or. (_cAliasPesq)->RESERVADO == 0
			Break
		Endif
		If 	(_cAliasPesq)->TOTVS3 > (_cAliasPesq)->RESERVADO
			_cStatus := "2"  	//PARCIAL
		ElseIf 	(_cAliasPesq)->TOTVS3 == (_cAliasPesq)->RESERVADO
			_cStatus := "1"		//RESERVADO
		Endif
	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 

Return _cStatus


//localisar a situação Tributária
User Function XFUNSITT(_cCodTES, _cCodItem, _cGrupo)
	Local _cSitTrib := "" //VS3->VS3_SITTRI  

	Default _cCodTES 	:= ""
	Default _cCodItem	:= ""
	Default _cGrupo		:= ""
	Begin Sequence
		If Empty(_cCodTES) .Or. Empty(_cCodItem) .Or. Empty(_cGrupo)
			Break
		EndIF
		If Len(_cCodItem) > Len(SB1->B1_COD)
			_cCodItem := SubsTr(_cCodItem,1,Len(SB1->B1_COD))
		ElseIf Len(_cCodItem) < Len(SB1->B1_COD)
			_cCodItem := _cCodItem+Space(Len(_cCodItem) - Len(SB1->B1_COD))
		EndIF
		SB1->(DbSetOrder(4))  //B1_FILIAL+B1_GRUPO+B1_COD                    
		If !SB1->(DbSeek(XFilial("SB1")+ _cGrupo +_cCodItem)) 	
			Break
		EndIF	
		SF4->( DbSetOrder(1) )		//B1_FILIAL+B1_GRUPO+B1_COD
		If !SF4->( DbSeek(xFilial("SF4") + _cCodTES) )
			Break
		EndIF	
		_cSitTrib := SubsTr(SB1->B1_ORIGEM,1,1)+SubsTr(SF4->F4_SITTRIB,1,2)
	End Sequence
Return _cSitTrib


//Verificar se existe reserva no VE6 e a quantidade

User Function XLOCVE6O(_cNumOrc, _cCodItem)
	Local _cAliasPesq	:= GetNextAlias()   
	Local _nQtdeItem	:= 0

	Begin Sequence

		BeginSql Alias _cAliasPesq  
			SELECT 	SUM(VE6.VE6_QTDITE) NQTDEIT
			FROM %Table:VE6% VE6	
			WHERE 	VE6.%notDel%
				AND VE6.VE6_FILIAL 	= %XFilial:VE6%
				AND VE6.VE6_NUMORC	= %Exp:_cNumOrc% 
				AND VE6.VE6_CODITE	= %Exp:_cCodItem% 
		EndSql

		If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NQTDEIT == 0
			Break
		Endif
		_nQtdeItem := (_cAliasPesq)->NQTDEIT
	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 

Return _nQtdeItem



/*/{Protheus.doc} XFUNPRRGlog
Responsável por reenviar Pixking não transmitido para RGLOG
@author 	DAC-Denilso
@since 		11/07/2022
@version 	undefined
@param 		_cAglutina - Numero da onda
@project    BARUERI
@type 		user function
@obs 		
@menu       Nao Informado
@return		_lRet		- Verdadeiro ou falso
@history    18/07/2022 	- Conforme solicitação JC é para realizar o processo de reenvio com todos os orçamentos que estão com data
						- em banco pois é para automatizar para Barueri, não fazer perguntas e tentar reenviar
/*/
User Function XFUNPRRGlog(_cAglutina, _cEmpresa, _cFilial, _nReprocessado, _oSay)
	Local _lRet 		:= .T.
	Local _lJob			:= IsBlind()

	Default _cAglutina 		:= ""
	Default _cEmpresa  		:= "02"
	Default _cFilial   		:= "2020012001"
	Default _nReprocessado	:= 0
	Default _oSay			:= Nil

	Begin Sequence

		//se não For pro JOB	
		If _lJob 
			//Tratar abertura da empresa conforme enviado no parametro
			Conout("XFUNPRRGlog - Iniciando JOB")
			If Type("cEmpAnt") <> "C" .or. cEmpAnt <> _cEmpresa .or. cFilAnt <> _cFilial
				Conout("XFUNPRRGlog - Abrindo empresa "+_cEmpresa+" Filial "+_cFilial)
				RpcClearEnv() 
				RPCSetType(3) 
				RpcSetEnv(_cEmpresa,_cFilial,,,,GetEnvServer(),{ })
			EndIf
			_lRet := XENCPICKRGlog(_cAglutina, @_nReprocessado, _oSay, _lJob)
		Else
			FwMsgRun(, {|oSay| _lRet := XENCPICKRGlog(_cAglutina, @_nReprocessado, _oSay, _lJob )}, "Envio de separação", "Por favor aguarde...")
		EndIf
	End Sequence
	Conout("XFUNPRRGlog - Término JOB")
Return _lRet


//função responsável pelo reenvio de picking RGLOG
Static Function XENCPICKRGlog(_cAglutina, _nReprocessado, _oSay, _lJob)
	Local _lRet			:= .T.
	Local _lProcessa	:= .T.
	Local _cAliasPesq 	:= GetNextAlias()
	Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
	Local _nRegPicking	:= 0
	Local _nLidos		:= 0
	Local _aMens		:= {}
	Local _aRetMens		:= {}
	Local _cWhere		:= ""
	Local _cPicking
	Local _nPos
	Local _cObs

	Default _cAglutina 		:= ""

	Begin Sequence
		If !Empty(_cAglutina)
			_cWhere := "AND VS1.VS1_XAGLU =  '"+_cAglutina+"'" 
		EndIf
		_cWhere := "%"+_cWhere+"%"
		BeginSql Alias _cAliasPesq
			SELECT 	VS1.VS1_XPICKI
			FROM %table:VS1% VS1
			WHERE 	VS1.VS1_FILIAL 	= %XFilial:VS1%
				%Exp:_cWhere%
				AND VS1.VS1_XPICKI <> ' '
				AND VS1.VS1_STATUS  = %Exp:_cFaseConf%
				AND VS1.VS1_XDTEPI 	= ' '
				AND VS1.%notDel%		 
			GROUP BY VS1.VS1_XPICKI 		 
			ORDER BY VS1.VS1_XPICKI 		 
		EndSql      
		//		AND VS1.VS1_XAGLU  	= %Exp:_cAglutina%  //anteriormente tratava somente a onda DAC 18/07/2022
		Count To _nRegPicking 
		(_cAliasPesq)->(DbGotop())
		//Caso não localizou sair 
		If (_cAliasPesq)->(Eof()) 	
			Break
		Endif
		//Caso exista algun registro informar se quer tentar reenvio
		// não fazer pegunta processar automaticamente
		// 	If !MsgYesNo( "Existe(m) "+StrZero(_nRegPicking,7)+" Picking ainda não transmitido para RG LOG, ref. a esta onda "+_cAglutina+", Deseja tentar trasmitir novamente ? " )
		//		_lProcessa := .F. 
		//	EndIf
		_lAborta  := .F.
		(_cAliasPesq)->(DbGotop())
		If !_lJob
			_oSay:SetText(" Reprocessamento - Reg. a Reprocessar " + StrZero(_nRegPicking,7)+ " Reg. Enviados "+StrZero(_nLidos,7)  )
			ProcessMessage()
		Endif	 
		While (_cAliasPesq)->(!Eof())
			//preparar todos os orçamentos com o picking para processamento
			_cPicking := AllTrim((_cAliasPesq)->VS1_XPICKI)
			If _lProcessa .and. !U_ZWSR007(/*_cAglutina*/, _cPicking, /*_lDataEnv*/ , cEmpAnt, cFilAnt, @_aRetMens )
				If ValType(_aRetMens)  == "A"
					//verifico se tenho algum item com envio correto
					_cObs := " Ref. Onda: "		+ _cAglutina
					_cObs += " Picking: "   	+ _cPicking	
					_cObs += " Ocorrencias: "   	
					For _nPos := 1 To Len(_aRetMens)
						//caso não validou o envio posso deixar como falso para retorno	
						_cObs += Upper(AllTrim(_aRetMens[_nPos,2]))+ " "
						If _aRetMens[_nPos,1] == 999  //respectivo a conexão irei abortar o processo caso tenham muitos para ser enviados
							_cObs += CRLF+ "Será abortado envio para evitar recorrencia do mesmo erro, Verificar com ADM Sistema !"
							_lAborta  := .T.
						Endif
					Next
				Endif
				Aadd(_aMens, "Nao foi possivel enviar picking, "+_cObs)
				_lRet	:= .F.
			ElseIf !_lProcessa
				Aadd(_aMens, "Ficaram picking sem serem enviados para o carregamento, reg a onda "+ _cAglutina +" !")
			ElseIf _lProcessa
				_nReprocessado 	++
				_nLidos			++
			EndIf
			If !_lJob
				_oSay:SetText(" Reprocessamento - Reg. a Reprocessar " + StrZero(_nRegPicking,7)+ " Reg. Enviados "+StrZero(_nLidos,7)  )
				ProcessMessage() 
			Endif
			//Abortar referente a falta de conexão
			If _lAborta
				Exit
			Endif
			(_cAliasPesq)->(DbSkip())		 
		EndDo	
	End Sequence
	If Len(_aMens) > 0
		_cObs := "PICKING(S) NÃO ENVIADOS PARA CARREGAMENTO RG LOG, REF. ONDA "+AllTrim(_cAglutina)+CRLF
		For _nPos := 1 To Len(_aMens)
			_cObs += " * "+_aMens[_nPos]+CRLF
		Next
		If _lJob
			Conout("XFUNPRRGlog - "+ _cObs)
		Else
			MSGINFO( Upper(_cObs), "[ZPECF008] - Atenção" )
		Endif
	Endif
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif  

Return _lRet


/*/{Protheus.doc} XFUNIPOSTO
Responsável Job para chamar o recalculo do imposto
@author 	DAC-Denilso
@since 		26/09/2022
@version 	undefined
@param 		
@project    BARUERI
@type 		user function
@obs 		
@menu       Nao Informado
@return		_lRet		- Verdadeiro ou falso
@history    
/*/
User Function XFUNIPOSTO(_cNumOrc, _cEmpresa, _cFilial, _lJob )
	Local _lRet 		:= .T.

	Default _cNumOrc 		:= ""
	Default _cEmpresa  		:= "02"
	Default _cFilial   		:= "2020012001"
	Default _lJob			:= IsBlind()

	Begin Sequence

		If Empty(_cNumOrc)
			Break
		EndIf
		//se não For pro JOB	
		If _lJob 
			//Tratar abertura da empresa conforme enviado no parametro
			Conout("XFUNIPOSTO - Iniciando JOB Orçamento "+_cNumOrc)
			If Type("cEmpAnt") <> "C" .or. cEmpAnt <> _cEmpresa .or. cFilAnt <> _cFilial
				Conout("XFUNIPOSTO - Abrindo empresa "+_cEmpresa+" Filial "+_cFilial)
				RpcClearEnv() 
				RPCSetType(3) 
				RpcSetEnv(_cEmpresa,_cFilial,,,,GetEnvServer(),{ })
			EndIf
			_lRet :=  U_ORCCALFIS(_cNumOrc /*_cNumOrc*/,/*_lAtuaPreco*/)  
		Else
			_lRet :=  U_ORCCALFIS( _cNumOrc /*_cNumOrc*/,/*_lAtuaPreco*/)  
		EndIf
	End Sequence
	Conout("XFUNIPOSTO - Término JOB Orçamento "+_cNumOrc)
Return _lRet

/*/{Protheus.doc} XVERTABPreco
Responsável por verificar se existe algum item com valor divergente na tabela de preço
@author 	DAC-Denilso
@since 		06/10/2022
@version 	undefined
@param 		_cCLi 	= Cliente Faturamento 
			_cLoja  = Loja Faturamento
			_cNumOrc= Numero do orçamento a ser pesquisado
@project    BARUERI
@type 		user function
@obs 		
@menu       Nao Informado
@return		_lRet		- Verdadeiro possui itens com divergência de tabela 
						  Falso não possui itens com divergência de tabela
@history    
/*/
User Function XVERTABPreco( _cCLi, _cLoja, _cNumOrc )
	//Local _nValTab		:= 0
	Local _cAliasPesq	:= GetNextAlias()   
	Local _cAtivo		:= '1'
	Local _lRet			:= .F.  //indica não ocorreu alteração
	Local _cData		:= DtOS(dDataBase)  //DtOS(Date()) //06/10/2022 conforme Zé utilizar o database
	Local _cCampo 		 

	Begin Sequence
		If SA1->A1_COD <> _cCLi .AND. SA1->A1_LOJA <> _cLoja 
			SA1->(DbSetOrder(1))
			If !SA1->(DbSeek(XFilial("SA1")+_cCLi+_cLoja))
				_lRet := .T.  //caso não localize SA1 retorno tru para forçar calculo em tabela
				Break
			EndIf	
		Endif
		_cCampo := "DA1.DA1_X"+AllTrim(SA1->A1_EST)
		_cCampo := "%"+_cCampo+"%"
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	DA1.R_E_C_N_O_ AS NREGDA1
				, VS3.VS3_CODITE 
				, VS3.VS3_VALPEC 
				, %Exp:_cCampo% 
			FROM  %Table:DA1% DA1
			JOIN %Table:VS3% VS3
				ON	VS3.VS3_FILIAL  = %xFilial:VS3%
				AND VS3.VS3_NUMORC  = %Exp:_cNumOrc%
				AND VS3.%notDel%
			JOIN %Table:DA0% DA0 
				ON	DA0.DA0_FILIAL  = %xFilial:DA0%
				AND DA0.DA0_ATIVO	= %Exp:_cAtivo%
				AND %Exp:_cData% BETWEEN DA0.DA0_DATDE AND DA0.DA0_DATATE
				AND DA0.%notDel%
			WHERE 	DA1.DA1_FILIAL  = %xFilial:DA1% 
				AND DA1.DA1_CODTAB  = DA0.DA0_CODTAB
				AND DA1.DA1_CODPRO 	= VS3.VS3_CODITE
				AND %Exp:_cCampo%  <> VS3.VS3_VALPEC 
				AND DA1.%notDel%
		EndSQL	
		If (_cAliasPesq)->(!Eof()) .and. (_cAliasPesq)->NREGDA1 > 0
			_lRet := .T.
			Break
		EndIf
	End Sequence
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif 
Return _lRet



//======================================================
USER FUNCTION  zFormula(_cCliFor,_cLoja,_cTipo)
	Local cRet 			:= ""
	Local _cCnpjTransf 	:= AllTrim(SuperGetMV( "CMV_WSR019"  ,,"03471344"))	//Raiz CNPJ de transferencia
	Local aArea 		:= GetArea()

	Default _cCliFor 	:= ""
	Default _cLoja   	:= ""
	Default _cTipo	 	:= ""

	DbSelectarea('SA1')
	SA1->(DbSetOrder(1))

	if SA1->(DbSeek(xFilial('SA1') + _cCliFor + _cLoja ))

		If Substring(SA1->A1_CGC,1,8) == _cCnpjTransf //'03471344'
			cRet := StrTran(AllTrim(GetNewPar("MV_FMLTRAN","000005")), '"')   		//indica formula de Transferencia
		Else
			cRet := StrTran(AllTrim(GetNewPar("MV_FMLPECA","000001")), '"')   		//indica formula padrão
		EndIf

	EndIf
	RestArea(aArea)
RETURN cRet



//função responsável pela Verificação de orçamentos com status de BO XBO = "S"  para transferência para outra filial
//Funcionalidade deverá funcionar por start JOB
//PEC030 - [ CaoaSp ] - Tratamento da Onda para nova Filial_V1
User Function CAOA_TRFO( _cAglutina, _cEmpresa, _cFilial )
	Local _lRet         := .T.
	Local _cAliasPesq 	:= ""
	Local _cFilTransf	:= ""
	Local _lJob 		:= IsBlind()
	Local aSM0Fil		:= {}
	Local _aMens		:= {}
	Local _cStatus		:= ("0")
	Local _cObs
	Local _nPos 		

	Default _cAglutina 	:= "" 
	Default _cEmpresa	:= ""
	Default _cFilial	:= ""

	Begin Sequence

		Aadd(_aMens,"Iniciando "+DtoS(Date())+" "+Time() )
		If Empty(_cAglutina) .Or. Empty(_cEmpresa) .Or. Empty(_cFilial)
			_lRet := .F.
			Break
		EndIf
		//Abrir empresas

		If _lJob .and. (Type("cEmpAnt") <> "C" .or. cEmpAnt <> _cEmpresa .or. cFilAnt <> _cFilial)
			Aadd(_aMens,"Orcamento - Abrindo empresa "+_cEmpresa+" Filial "+_cFilial)
			RpcClearEnv() 
			RPCSetType(3) 
			RpcSetEnv(_cEmpresa,_cFilial,,,,GetEnvServer(),{ })
		EndIf
		//Carrego após abrir empresa caso antes ocorre erro
		_cAliasPesq := GetNextAlias()
		_cFilTransf	:= SuperGetMV( "CMV_PEC030"  ,,"" )
		If Empty(_cFilTransf)
			Aadd(_aMens,"Parâmetro( CMV_PEC030) para transferência de Orçamentos BO's não informado " )
			//_lRet := .F.
			Break
		EndIf
		If AllTrim(_cFilTransf) == AllTrim(cFilAnt)
			Aadd(_aMens,"Filial "+_cFilTransf+" não pode ser a mesma filail de origem, referente transferência de Orçamentos BO's não informado " )
			_lRet := .F.
			Break
		Endif
		aSM0Fil := FWSM0Util():GetSM0Data( cEmpAnt , _cFilTransf , { "M0_CODFIL" } ) //Retorna o M0_CODFIL do grupo  e filial 
		If Len(aSM0Fil) == 0
			Aadd(_aMens,"Filial "+_cFilTransf+" não cadastrada nesta Empresa, para transferência de Orçamentos BO's não informado " )
			_lRet := .F.
			Break
		Endif
		//Pesquisar se existem BO's
		BeginSql Alias _cAliasPesq 
			SELECT 	ISNULL(VS1.R_E_C_N_O_,0) NREGVS1
			FROM %table:VS1% VS1
			WHERE 	VS1.VS1_FILIAL 	= %XFilial:VS1%
				AND VS1.VS1_XAGLU  	= %Exp:_cAglutina%
				AND VS1.VS1_XPICKI 	= ' '
				AND VS1.VS1_XDTEPI 	= ' '
				AND VS1.VS1_XBO		= 'S'
				AND VS1_STATUS IN (%Exp:_cStatus%)
				AND VS1.%notDel%		 
		EndSql
		If (_cAliasPesq)->(Eof()) 	
			Aadd(_aMens,"Não encontrou Registro" )
			Break
		EndIf	
		While (_cAliasPesq)->(!Eof()) 
			VS1->(DbGoto((_cAliasPesq)->NREGVS1))
			Aadd(_aMens,"Processando filial/orçamento "+VS1->VS1_FILIAL+"/"+VS1->VS1_NUMORC )
			If AllTrim(VS1->VS1_FILIAL) <> AllTrim(_cFilTransfer)
				If U_CAOA_OCTrannsfer(VS1->VS1_NUMORC, VS1->VS1_FILIAL, _cFilTransfer)
					Aadd(_aMens,"Processado com sucesso filial/orçamento "+VS1->VS1_FILIAL+"/"+VS1->VS1_NUMORC )
				Endif
			EndIf	
			(_cAliasPesq)->(DbSkip())
		EndDo
	End Sequence
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif  
	Aadd(_aMens,"Termino "+DtoS(Date())+" "+Time() )

	_cObs := "[CAOA_TRFO]" + CRLF
	Conout("[CAOA_TRFO]") 
	For _nPos := 1 To Len(_aMens)
		_cObs += _aMens[_nPos] + CRLF
		Conout(_aMens[_nPos])
	Next _nPos
	If !_lJob
		Help( , ,"Atenção",,_cObs,4,1) //Atenção / Necessário informar os parâmetros 
	EndIf
Return _lRet



//Transferir o orçamento de uma filial para outra
//PEC030 - [ CaoaSp ] - Tratamento da Onda para nova Filial_V1
User Function CAOA_OCTrannsfer(_cNumOrc, _cFilAtu, _cFilTransfer)
	Local _lRet 		:= .T.
	Local _cQuery		:= ""
	Local _cObs			:= "ORCAMENTO TRANSFERIDO DA FILIAL  "+_cFilAtu+" PARA "+_cFilTransfer + CRLF
	Local _cObsVS1		:= ""
	Local _cAliasPesq	:= GetNextAlias()   
	Local _nStatus
	Local _cOrcNovo 
	Local _cOrcConf

	Default _cNumOrc		:= ""
	Default _cFilAtu		:= ""
	Default	_cFilTransfer	:= ""

	Begin Sequence
		If Empty(_cNumOrc) .Or. Empty(_cFilAtu) .Or. Empty(_cFilTransfer)
			_lRet := .F.
			Break
		EndIf
		If VS1->VS1_FILIAL <> _cFilAtu  .Or. VS1->VS1_NUMORC  <> _cNumOrc 
			//Verificar se existe orçamento
			BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
				SELECT 	ISNULL(VS1.R_E_C_N_O_,0) NREGVS1
				FROM  %Table:VS1% VS1
				WHERE VS1.VS1_FILIAL   	= %Exp:_cFilAtu% 
					AND VS1.VS1_NUMORC  = %Exp:_cNumOrc%
					AND VS1.%notDel%
			EndSQL	
			If (_cAliasPesq)->(Eof()) 
				_lRet := .F.
				Break
			EndIf
			VS1->(DbGoto((_cAliasPesq)->NREGVS1))
		EndIf
		//bloquear o orçamento
		If !VS1->(RecLock("VS1",.F.))
			_lRet := .F.
			Conout("[CAOA_OCTrannsfer] NAO FOI POSSIVEL UTILIZAR EXCLUSIVO TABELA VS2")
			Break
		Endif	
		//Garanto que a filial será a de trans
		If _cFilTransfer <> cFilAnt
			cFilAnt := _cFilTransfer
		EndIf
		//Verifico o numero do orçamento na filail de transferência
		_cOrcNovo 		:= VS1->(GetSXENum("VS1","VS1_NUMORC"))
		_cOrcConf		:= U_XVERNUMeracao("VS1", "VS1_NUMORC", _cOrcNovo )
		If AllTrim(_cOrcNovo) <> AllTrim(_cOrcConf)
			_cObsVS1	:=  "ATENCAO [CAOA_OCTrannsfer]"
			_cObsVS1 	+= "- NUMERACAO AUTOMATICA DO ORÇAMENTO "  +_cOrcNovo+" ESTA APRESENTANDO PROBLEMAS  !"
			_cObsVS1	+= "- ASSUMIDO NUMERACAO PARA O ORÇAMENTO "+_cOrcConf+" AJUSTAR NUMERACAO AUTOMATICA !" +CRLF
			_cOrcNovo := _cOrcConf
		Endif
		//Aplico o update no VS3
		_cQuery += "UPDATE " +RetSqlName("VS3")+ " VS3" + CRLF
		_cQuery += "SET 	VS3.VS3_FILIAL 	= '" +_cFilTransfer	+ "'" + CRLF
		_cQuery += " 	,	VS3.VS3_NUMORC 	= '" +_cOrcNovo		+ "'" + CRLF
		_cQuery += " 	,	VS3.VS3_OBSAGL 	=  RAWTOHEX('"+_cObs+ chr(13) + chr(10) +"' ||  NVL(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(VS3.VS3_OBSAGL , 2000, 1)),' ') )" + CRLF   
		_cQuery += "WHERE VS3.D_E_L_E_T_  = ' '" 				+ CRLF
		_cQuery += " 	AND VS3.VS3_FILIAL = '"+_cFilAtu+"'"  	+ CRLF	
		_cQuery += " 	AND VS3.VS3_NUMORC = '"+_cNumOrc+"'"  	+ CRLF	

	//	_cQuery += "i := SQL%rowcount"
		Begin Transaction	
			_nStatus := TcSqlExec(_cQuery)
			if (_nStatus < 0)
				//MSGINFO("Erro ao gravar Status na tabela VS1 "+ TCSQLError() , "[ZPECF0008] - Atenção" )
				Conout("[CAOA_OCTrannsfer] PROBLEMAS NO SELECT "+ CRLF + TCSQLError())
				_lRet := .F.
			Else
				If !Empty(_cObsVS1)
					_cObs := _cObs + CRLF +_cObsVS1
				EndIf
				VS1->VS1_FILIAL	:= _cFilTransfer
				VS1->VS1_NUMORC := _cOrcConf
				VS1->VS1_OBSAGL := _cObs + CRLF + VS1->VS1_OBSAGL
			EndIf
		End Transaction		     
	End Sequence
	//Volto a filial e tiro qualquer bloqueio do VS1
	cFilAnt := _cFilAtu
	VS1->(MsUnlock())
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif  
Return _lRet


/*/{Protheus.doc} ZPECWFLC
Validação para permitir o Usuário alterar ou não a condição especial quando a mesma existir e estiver cadastrado
Esta funcionalidade deve ser utilizada na valiação do campo VS1_FORPAG em X3_WHEN 
@param      _cForPagVS1 	- Forma de Pagamento  
@return     Logico
@author     DAC Denilso
@version    12.1.17 / Superior
@project	GRUPO CAOA - GAP FIN100 - Campo Matriz Clientes (Revitalização Limite de Crédito)
@since      13/03/2023
/*/
User Function ZPECWFLC(_cForPagVS1)
Local _lRet 		:= .T. 
Local _cTpPgtoEsp	:= SuperGetMV( "CMV_PEC039"  ,,"" )  //Condição de Pagamento a qual liberará sem avaliação do Limite de Crédito

Default _cForPagVS1	:= If(Type("M->VS1_FORPAG") 	== "C",M->VS1_FORPAG	,VS1->VS1_FORPAG)

Begin Sequence
	//somente ateração
	If (!INCLUI .And. !ALTERA) .Or. Empty(_cTpPgtoEsp)
		Break
	EndIf

	If AllTrim(_cForPagVS1) $ AllTrim(_cTpPgtoEsp)
		//colocado controle de usuários DAC 13/05/2022
		_lRet := U_ZGENUSER( RetCodUsr() ,"ZPECWFLC" ,.F.)	
		If !_lRet 
			If ALTERA 
				M->VS1_FORPAG	:= VS1->VS1_FORPAG
			ElseIf INCLUI
				M->VS1_FORPAG	:= Space(Len(VS1->VS1_FORPAG))
			Endif	
		EnDif
		//Caso não deixe alterar e voltando a confição antiga
		If Empty(M->VS1_FORPAG) .Or. !AllTrim(M->VS1_FORPAG) $ AllTrim(_cTpPgtoEsp)
			_lRet := .T.
		Endif
	Endif
End Begin
Return _lRet


/*/{Protheus.doc} ZPECREGFI
Atualiza TES inteligente e recalcula Picking 29/03/2023
@param      cZK_XPICKI 	- Numero Picking 	
			_cNumOrc	- Numero do orçamento VS1
@return     Logico
@author     Não informado
@version    12.1.17 / Superior
@project	
@since      29/03/2023
@history    DAC - 23/06/2022 - Ajuste funcionalidade e implementação registro VS1  
				Break antes de iniciar o Sequence
				Implementado parâmetro _cNumOrc para permitir que a função possa receber somente um orçamento para refazer calculo
				Alterado Select ja trazendo os registros da VS3		
				Acresentado no SELECT VS3->VS3_XREGFI igual a "T"	
/*/
User Function ZPECREGFI(cZK_XPICKI, _cNumOrc)
Local _lRet			:= .T.
Local _cAliasPesq 	:= GetNextAlias()
//Local _aOrcs2 		:= {}
//Local _nX 			:= 0
Local _cMens
Local _cTESVS3		:= " "
Local _cCodIte		:= " "
//Local _cNumOrc		:= " "
Local _cXREGFI		:= " "
Local _cOperVS3		:= " "
Local _cStatus		:=  "4,F" 							  //Por erro na chamada pelo ZWSR009
Local _lJob 		:= IsBlind()   //pode ser chamado por Json ou job GAP002 DAC 09/08/2023
Local _cWhere		:= ""
Local _aArea 		:= GetArea()
Local _nRegVS1 		:= VS1->(Recno())


Default cZK_XPICKI	:= ""
Default _cNumOrc	:= ""

Begin sequence  //Ajuste Select não estava dentro do Begin GAP002  DAC 09/08/2023 
	If Empty(cZK_XPICKI) .and. Empty(_cNumOrc)
		_cMens := "[ZPECREGFI] Não Informado Picking e ou Orçamento !"
		If !_lJob
			MsgInfo(_cMens,"Atenção") 
		Endif 
		Conout(_cMens) 
		_lRet := .F. 
		Break
	Endif 
	//Trata somente o orçamento caso seja informado o numero do orçamento //DAC GAP002
	If !Empty(_cNumOrc)
		_cWhere +=   " AND VS1.VS1_NUMORC = '"+_cNumOrc+"' "
	Else
		_cWhere +=   " AND VS1.VS1_XPICKI = '"+cZK_XPICKI+"' "
	Endif		
	_cWhere 	:= "%"+_cWhere+"%"
	_cStatus	:= '%' + FormatIn(_cStatus,',') + '%' //Por erro na chamada pelo ZWSR009

	BeginSql Alias _cAliasPesq
		SELECT VS1_CLIFAT,VS1_LOJA,VS1_NCLIFT,VS1_NUMORC,VS1_TIPORC,VS1_DATORC, VS1_XMARCA
				,NVL(VS1.R_E_C_N_O_,0) NREGVS1
				,NVL(VS3.R_E_C_N_O_,0) NREGVS3
  		FROM %table:VS1% VS1
		JOIN %Table:VS3% VS3
			ON  VS3.VS3_FILIAL 		= %XFilial:VS3%
			AND VS3.VS3_NUMORC		= VS1.VS1_NUMORC
		  	AND VS3.%notDel%	
   		WHERE 	VS1.VS1_FILIAL  	= %XFilial:VS1%
				%Exp:_cWhere%
			AND VS1.VS1_TIPORC 		= '1' 
			AND VS1.VS1_STATUS  	IN %Exp:_cStatus% //Por erro na chamada pelo ZWSR009
			AND VS1.VS1_NUMNFI		= ' '
			AND VS3.VS3_XREGFI		= 'T'
		  	AND VS1.%notDel%	
	EndSql
//		SELECT DISTINCT	VS1_CLIFAT,VS1_LOJA,VS1_NCLIFT,VS1_NUMORC,VS1_TIPORC,VS1_DATORC, VS1_XMARCA
//			AND VS1.VS1_XPICKI  	= %Exp:cZK_XPICKI%

	If (_cAliasPesq)->(Eof())
		//Avaliando saida DAC 09/08/2023 GAP002
		_cMens := "[ZPECREGFI] Não localizado Orçamentos com Picking "+cZK_XPICKI+" para alterar TES, com referencia VS3_XREGFI igual a [T] !"
		//If !_lJob
		//	MsgInfo(_cMens,"Atenção") 
		//Endif 
		Conout(_cMens) 
		Break //Por erro na chamada pelo ZWSR009
	EndIf	

	While !(_cAliasPesq)->(Eof())
		_cNumOrc 	:= (_cAliasPesq)->VS1_NUMORC
		VS1->(DbGoto((_cAliasPesq)->NREGVS1))
		_cMens := ""
		While (_cAliasPesq)->(!Eof()) .and. (_cAliasPesq)->VS1_NUMORC == _cNumOrc
			VS3->(DbGoto((_cAliasPesq)->NREGVS3))
			cTES := " "
			_cOperVS3 := Alltrim(VS3->VS3_OPER)
			_cTESVS3  := Alltrim(VS3->VS3_CODTES)
			_cCodIte  := Alltrim(VS3->VS3_CODITE)
			_cXREGFI  := Alltrim(VS3->VS3_XREGFI)
			cTES := Alltrim(MaTesInt(2, _cOperVS3, VS1->VS1_CLIFAT, VS1->VS1_LOJA,"C", _cCodIte))
			_cMens := "TES Inteligente: NumOrc: "+_cNumOrc+ "/ Cliente: "+VS1->VS1_CLIFAT+VS1->VS1_LOJA+"/ Produto " +_cCodIte+"/ Oper: "+_cOperVS3+"/ Regra: "+_cXREGFI+" / TES_ORC: " +_cTESVS3+ " / Tes Intelig: " +cTES +CRLF
			If (!(_cXREGFI = "T") .and. !(_cTESVS3 = cTES) .and. !Empty(cTES))
				VS1->(RecLock("VS1",.F.))
				VS3->(RecLock("VS3",.F.))
				_cMens += "O produto " +_cCodIte+ " teve a TES " +_cTESVS3+ " alterada para " +cTES+ " conforme OperaÃ§Ã£o " +_cOperVS3+ " no momento do faturamento em " +DtoC(date()) + " Ã s " + Time() + CRLF
				VS1->VS1_OBSAGL	:= Upper(_cMens) + CRLF + AllTrim(VS1->VS1_OBSAGL)
				VS3->VS3_CODTES := cTES
				VS3->VS3_SITTRI := U_XFUNSITT(cTES, VS3->VS3_CODITE, VS3->VS3_GRUITE)
				VS3->(MsUnlock())
				VS1->(MsUnlock())
			Elseif Empty(cTES)
				_cMens += "Erro no retorno da TES Inteligente -> Tes: "+cTES+" Oper: " +_cOperVS3+ " Cliente: "+VS1->VS1_CLIFAT+" Loja: "+VS1->VS1_LOJA+" Cod: "+_cCodIte+DtoC(date()) + " Ã s " + Time() + CRLF
				_lRet := .F.
			EndIf	
	       	(_cAliasPesq)->(DbSkip())
		EndDo
		If !_lRet 
			If !_lJob
				MsgInfo(_cMens,"Atenção") 
			Endif 
			Conout(_cMens) 
		Endif 
		U_ORCCALFIS(VS1->VS1_NUMORC,.F./*atualiza o preÃ§o*/)
	EndDo
	
		/*
		_cCliente 	:= (_cAliasPesq)->VS1_CLIFAT
		_cLoja 		:= (_cAliasPesq)->VS1_LOJA
		_cNumOrc 	:= (_cAliasPesq)->VS1_NUMORC
		_cMens 		:= " "
		aadd( _aOrcs2,_cNumOrc)
		VS1->(dbSetOrder(1))
		VS3->(dbSetOrder(1))
		If VS3->(dbSeek(xFilial("VS3")+_cNumOrc))
			VS1->(dbSeek(xFilial("VS1")+_cNumOrc))
       	 	Do While (VS3->(!EOF()) .AND. VS3->VS3_NUMORC == _cNumOrc)
				cTES := " "
				_cOperVS3 := Alltrim(VS3->VS3_OPER)
				_cTESVS3  := Alltrim(VS3->VS3_CODTES)
				_cCodIte  := Alltrim(VS3->VS3_CODITE)
				_cXREGFI  := Alltrim(VS3->VS3_XREGFI)
				cTES := Alltrim(MaTesInt(2, _cOperVS3, _cCliente, _cLoja,"C", _cCodIte))
				_cMens := "TES Inteligente: NumOrc: "+_cNumOrc+ "/ Cliente: "+_cCliente+_cLoja+"/ Produto " +_cCodIte+"/ Oper: "+_cOperVS3+"/ Regra: "+_cXREGFI+" / TES_ORC: " +_cTESVS3+ " / Tes Intelig: " +cTES+CRLF
				If (!(_cXREGFI = "T") .and. !(_cTESVS3 = cTES) .and. !Empty(cTES))
					VS1->(RecLock("VS1",.F.))
					VS3->(RecLock("VS3",.F.))
					_cMens += "O produto " +_cCodIte+ " teve a TES " +_cTESVS3+ " alterada para " +cTES+ " conforme OperaÃ§Ã£o " +_cOperVS3+ " no momento do faturamento em " +DtoC(date()) + " Ã s " + Time() + CRLF
					VS1->VS1_OBSAGL	:= Upper(_cMens) + CRLF + AllTrim(VS1->VS1_OBSAGL)
					VS3->VS3_CODTES := cTES
					VS3->VS3_SITTRI := U_XFUNSITT(cTES, VS3->VS3_CODITE, VS3->VS3_GRUITE)
					VS3->(MsUnlock())
				Elseif Empty(cTES)
					_cMens += "Erro no retorno da TES Inteligente -> Tes: "+cTES+" Oper: " +_cOperVS3+ " Cliente: "+_cCliente+" Loja: "+_cLoja+" Cod: "+_cCodIte+DtoC(date()) + " Ã s " + Time() + CRLF
					_lRet := .F.
				EndIf	
	        	VS3->(dbSkip())
			EndDo
			VS1->(MsUnlock())
		Else
			_cMens := "Erro na Busca dos itens do ORC: " +(_cAliasPesq)->VS1_NUMORC+ " Ã s " + Time() + CRLF
			_lRet := .F.
		EndIf
		(_cAliasPesq)->(dbSkip())
	EndDo
	For _nX := 1 to len(_aOrcs2)
		U_ORCCALFIS(_aOrcs2[_nX],.F.)
	Next _nX
	*/
End Sequence
RestArea(_aArea)
VS1->(DbGoto(_nRegVS1))

Return _lRet



/*/{Protheus.doc} XFVERORC
Mostrat Orçamento 
@author DAC - Denilso 
@since 31/05/2023
@version 2.0
@project	PEC044 - Revitalização Consulta Peças - Abri consulta orçamento
/*/
/* Descontinuada GAP098 DAC 24/11/2023
User Function XFVERORC(_cAliasPesq,_ObrW)
Local _lRet     := .T.
Local _nOpc     := 2
Local _aArea := GetArea()
Local _nReg
//infelizmente é necessário carregar as variaveis abaixo para que abra a tela de orçamento DAC
Private cCadastro := "Orçamento"
Private aItensKit := {}
Private aPedTransf := {}
Private cGruFor   := "04" 										// Grupo de Formulas que podem ser utilizadas nos orcamentos
Private lVAMCid  		:= GetNewPar("MV_CADCVAM","S") == "S" 	// Utiliza VAM (Cidades)?
Private lRecompra  	:= .F.										// Indica se eh um orcamento para recompra
Private lPassou := .f.											// Tratamento da mudanca de aba na funcao OX001MUDFOL()
Private aIteRel := {{"","","",0,0,"","",""}}					// Vetor contendo os itens relacionados da listbox oLItRel
Private aMemos1   := {{"VS1_OBSMEM","VS1_OBSERV"}}				// Observacao do Orcamento
Private lAbortPrint	:= .f.										// Variavel de Aborto de Operacao
Private lOrcJaRes := .f.
Private dDatOrc := ctod("")
//
Private cMV_VERIORC := Alltrim(GetNewPar("MV_VERIORC","1"))
Private lPediVenda := .f.
Private lCancParc := .f.
Private lAltPedVda := .f.
Private lPVP := .f.
Private lCancelPVP := .f.
Private lFaturaPVP := .f.
Private nUsadoPX01 := 0
Private oPedido := DMS_Pedido():New()
Private oSqlHlp := DMS_SqlHelper():New()
Private oDpm    := DMS_Dpm():New()
Private aNATrf  := {}
Private	cVS1Status := VS1->VS1_STATUS
Private cFaseOrc
Private lInconveniente := (GetNewPar("MV_INCORC","N") == "S")
Private lInconvObr     := (GetNewPar("MV_INCOBR","N") == "S")
Private cIncDefault    := Alltrim(GetNewPar("MV_MIL0094",""))	// SEM INSTALAR
// Variaveis de integracao
Private aAutoCab := {} 											// Cabecalho do Orcamento (VS1)
Private aAutoPecas := {}										// Pecas do Orcamento (VS3)
Private aAutoServ := {}											// Servicos do Orcamento (VS4)
Private aAutoInco := {}											// Inconvenientes do Orcamento
// 'lOX001Auto' indica se todos os vetores de integracao foram preenchidos
Private lOX001Auto := .f. //( xAutoCab <> NIL  .and. xAutoPecas <> NIL .and. xAutoServ <> NIL )
// Variaveis de Controle de tela (OBJETOS)
Private aTitulo := {"STR0136","STR0134","STR0135"}
Private nFolderI := 1 // Numero da Folder de Inconveniente
Private nFolderP := 2 // Numero da Folder de Pecas
Private nFolderS := 3 // Numero da Folder de Servicos
Private aNewBot := {}
Private nMaxItNF  := GetMv("MV_NUMITEN")
Private lAprMsg   := GetNewPar("MV_MIL0151",.T.)
Private lMsg0268 := .f. // Controle de Msg de Pedido Gravado
Private cVK_F := {}

Private n														// Controle do Fiscal para linha da aCols
Private aNumP := {}		  										// Controle do Fiscal para aCols de Pecas
Private aNumS := {}												// Controle do Fiscal para aCols de Servicos
Private nTotFis := 0											// Numero total de itens do Fiscal (pecas + servicos)
Private bRefresh := { || .t. } 									// Variavel necessaria ao MAFISREF
Private aCodErro := {"",""}										// Variavel de Codigo de Erro na Importacao de OS
Private aItensNImp := {}										// Variavel de retorno de importacao de pecas p/ O.S.
Private lJaPerg := .t. 											// Variavel necessaria ao OFIOC040

VISUALIZA := ( _nOpc == 2 )
INCLUI 	  := ( _nOpc == 3 )
ALTERA 	  := ( _nOpc == 4 )
EXCLUI 	  := ( _nOpc == 5 )
FECHA  	  := ( _nOpc == 6 )
//    _nPos := _ObrW:nat 
    _nReg := (_cAliasPesq)->RECNOVS1
    VS1->(DbGoto(_nReg))
    cVS1Status := VS1->VS1_STATUS
    cFaseOrc := OI001GETFASE(VS1->VS1_NUMORC)
    If _lRet 
        //OXA012V("VS1",_nReg,2)
        OX001EXEC("VS1",_nReg,2, /lLibPV/)
    EndIf
    RestArea(_aArea)
Return Nil
*/

/*/{Protheus.doc} MILAXTABELA
Mostrar Orçamento 
@author DAC - Denilso 
@since 31/05/2023
@version 2.0
@project	PEC044 - Revitalização Consulta Peças - Abri consulta Orçamento
@Obs		Devido a forma de tratamento oficna/peÃ§as não é possivel chamar a 
			consulta de oramentos a não ser passando por esta função MILAXTABELA
			caso não passe ai ira tratar CNPJs que estÃ£o hard cold no programa
/*/

USER Function MILAXTABELA(_nRegVS1)
//Local _cFunName :=  Funname()
Local _aArea := GetArea()
	DbSelectArea("VS1")
    VS1->(DbGoto(_nRegVS1))
	//SetFunName("OFIXA018")
	lRet = OXA012V()
    //SetFunName(_cFunName)
RestArea(_aArea)
Return Nil
       