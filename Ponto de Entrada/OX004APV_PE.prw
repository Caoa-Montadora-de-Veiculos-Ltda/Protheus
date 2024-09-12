#INCLUDE "PROTHEUS.CH"

/*
==============================================================================================
Programa.:              OX004APV
Autor....:              Evandro Mariano
Data.....:              02/03/22
Descricao / Objetivo:   V.03 
Doc. Origem:
Solicitante:            
Uso......:              
Obs......:              
===============================================================================================
*/
User Function OX004APV
Local _lRet := .T.
Begin Sequence
    If FWIsInCallStack("U_ZPECF013") .and. Type("_aVarVS3") == "A"   
		//somente realizar a operação caso  estejam diferentes a variaveis no padrão estava somente faturando 1
		If Type("aOrcs") <> "A" .or. (Type("aOrcs") == "A" .and. Len(aOrcs)  <> Len(_aVarVS3))
        	_lRet := OX004APVAJ()
		Endif	
    Endif    
	If Type("aOrcs") == "A" .and. _lRet
		//funcionalidade para gravar mensagens e dados faltantes DAC 22/02/2022
		_lRet := OX004APVMS()  
	Endif
	_lPrcZPECF013 := .T.  //indica que esta sendo processado faturamento
End Sequence
Return _lRet

//funcionadidade responsável por ajustar a forma de gravação  dos itens do orçmento
Static Function OX004APVAJ()
Local _lRet             := .T.
Local _aItemVS3         := {}
Local _aItem            := {}
Local _nValPeca         := 0
Local _nValDes          := 0
Local _nValTotal        := 0
Local _nVS1DespVend     := 0
Local _nVS1ValFrete     := 0
Local _nVS1ValSeguro    := 0   
Local _nVS1PesoL        := 0    
Local _nVS1PesoB        := 0    
Local _nVS1Vol1         := 0    
Local _nVS1Vol2         := 0    
Local _nVS1Vol3         := 0         
Local _nVS1Vol4         := 0  

Local _nPos
Local _nPosCpo
Local _cNumOrc
Local _cNumItem

VS3->(DbSetOrder(1))
VS1->(DbSetOrder(1))
SB1->(DbSetOrder(1))
Begin Sequence
    _cNumItem := StrZero(0,Len(SC6->C6_ITEM))
    For _nPos := 1 To Len(_aVarVS3)
        _cNumOrc := _aVarVS3[_nPos]
        If !VS1->(DbSeek(XFilial("VS1")+_cNumOrc))
            lRet := .F.
            Break
        EndIf   
        If !VS3->(DbSeek(XFilial("VS3")+_cNumOrc))
            lRet := .F.
            Break
        EndIf    
		_nVS1DespVend       += VS1->VS1_DESACE
		_nVS1ValFrete       += VS1->VS1_VALFRE
		_nVS1ValSeguro      += VS1->VS1_VALSEG
        _nVS1PesoL          += VS1->VS1_PESOL
        _nVS1PesoB          += VS1->VS1_PESOB
        _nVS1Vol1           += VS1->VS1_VOLUM1
        _nVS1Vol2           += VS1->VS1_VOLUM2
        _nVS1Vol3           += VS1->VS1_VOLUM3
        _nVS1Vol4           += VS1->VS1_VOLUM4

        While VS3->(!Eof()) .and. VS3->VS3_NUMORC == _cNumOrc
            _aItem    := {}
            _cNumItem := SOMA1(_cNumItem)
            // Nao passar o Valor Bruto para NF/Loja
             If VS1->(FieldPos("VS1_VLBRNF")) > 0 
				_nValPeca   := VS3->VS3_VALPEC - ( VS3->VS3_VALDES / VS3->VS3_QTDITE )
				_nValDes    := 0
				_nValTotal  := VS3->VS3_VALTOT
			Else // Passar Valor Bruto e Desconto para NF/Loja
				_nValPeca   := VS3->VS3_VALPEC
				_nValDes    := VS3->VS3_VALDES
				_nValTotal  := VS3->VS3_VALTOT+VS3->VS3_VALDES
            Endif

            //_nPosCpo := Ascan(_aVarVS3,{|x| AllTrim(x[2]) == AllTrim(VS3->VS3_CODITE)} )
            SB1->(DbSeek(XFilial("SB1")+VS3->VS3_CODITE))
			aAdd(_aItem,{"C6_ITEM"   ,  _cNumItem		  	,Nil})
			aAdd(_aItem,{"C6_PRODUTO",  SB1->B1_COD  		,Nil})
			aAdd(_aItem,{"C6_TES"    ,  VS3->VS3_CODTES  	,Nil})
			aAdd(_aItem,{"C6_ENTREG" ,  dDataBase  			,Nil})
			aAdd(_aItem,{"C6_UM"     ,  SB1->B1_UM      	,Nil})
			aAdd(_aItem,{"C6_LOCAL"  ,  VS3->VS3_LOCAL		,Nil})
			aAdd(_aItem,{"C6_QTDVEN" ,  VS3->VS3_QTDITE		,Nil})
			aAdd(_aItem,{"C6_QTDLIB" ,  0              	   	,Nil})
			aAdd(_aItem,{"C6_PRUNIT" ,  _nValPeca			,Nil})
			aAdd(_aItem,{"C6_PRCVEN" ,  _nValPeca			,Nil})
			aAdd(_aItem,{"C6_VALOR"  ,  _nValTotal			,Nil})
			aAdd(_aItem,{"C6_VALDESC",  _nValDes			,Nil})
			aAdd(_aItem,{"C6_TES"    ,  VS3->VS3_CODTES 	,Nil})
			if VS3->(FieldPos("VS3_SITTRI")) > 0
				aAdd(_aItem,{"C6_CLASFIS", VS3->VS3_SITTRI 	,Nil})
			endif
			aAdd(_aItem,{"C6_COMIS1" ,  0  					,Nil})
			aAdd(_aItem,{"C6_CLI"    ,  VS1->VS1_CLIFAT		,Nil})
			aAdd(_aItem,{"C6_LOJA"   ,  VS1->VS1_LOJA  	    ,Nil})
			if VS3->(FieldPos("VS3_LOTECT")) > 0 .and. !Empty(VS3->VS3_LOTECT)
				aAdd(_aItem,{"C6_LOTECTL" , VS3->VS3_LOTECT	,Nil})
				aAdd(_aItem,{"C6_NUMLOTE" , VS3->VS3_NUMLOT	,Nil})			
			endif
			if VS3->(FieldPos("VS3_LOCALI")) > 0 .and. !Empty(VS3->VS3_LOCALI)
				aAdd(_aItem,{"C6_LOCALIZ" , VS3->VS3_LOCALI	,Nil})
			endif                                       
			if VS1->VS1_TIPORC == "1"
				If SC6->(FieldPos("C6_CC"))>0 .and. VS3->(FieldPos("VS3_CENCUS"))>0 
					aAdd(_aItem,{"C6_CC"   , VS3->VS3_CENCUS , Nil})
				Endif
				If SC6->(FieldPos("C6_CONTA"))>0 .and. VS3->(FieldPos("VS3_CONTA"))>0
					aAdd(_aItem,{"C6_CONTA" , VS3->VS3_CONTA , Nil})
				Endif
				If SC6->(FieldPos("C6_ITEMCTA"))>0 .and. VS3->(FieldPos("VS3_ITEMCT"))>0
					aAdd(_aItem,{"C6_ITEMCTA" , VS3->VS3_ITEMCT , Nil})
				Endif
				If SC6->(FieldPos("C6_CLVL"))>0 .and. VS3->(FieldPos("VS3_CLVL"))>0
					aAdd(_aItem,{"C6_CLVL"  , VS3->VS3_CLVL , Nil})
				Endif
			Endif
			If SC6->(FieldPos("C6_FCICOD"))>0 .and. (VS3->(FieldPos("VS3_FCICOD"))>0 .and. !Empty(VS3->VS3_FCICOD) )
				aAdd(_aItem,{"C6_FCICOD"    , VS3->VS3_FCICOD , Nil})
			Endif                
			If SC6->(FieldPos("C6_NUMPCOM"))>0 .and. (VS3->(FieldPos("VS3_PEDXML"))>0 .and. !Empty(VS3->VS3_PEDXML) )
				aAdd(_aItem,{"C6_NUMPCOM"   , VS3->VS3_PEDXML , Nil})
			Endif                
			If SC6->(FieldPos("C6_ITEMPC"))>0 .and. (VS3->(FieldPos("VS3_ITEXML"))>0 .and. !Empty(VS3->VS3_ITEXML) )
				aAdd(_aItem,{"C6_ITEMPC" , VS3->VS3_ITEXML , Nil})
			Endif                
			aAdd(_aItemVS3,aClone(_aItem))
			VS3->(DBSkip())
		EndDo

	Next
    _nPosCpo := Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_DESPESA"} )
    If _nPosCpo > 0
	    aCabPV[_nPosCpo,2] := _nVS1DespVend // Despesas na Venda a Integrar na NF
    Endif
    _nPosCpo := Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_FRETE"} )
    If _nPosCpo > 0
	    aCabPV[_nPosCpo,2] := _nVS1ValFrete // Valor Frete
    Endif
   _nPosCpo := Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_SEGURO"} )
    If _nPosCpo > 0
	    aCabPV[_nPosCpo,2] := _nVS1ValSeguro // Valor Seguro
    Endif

	If VS1->(Fieldpos('VS1_PESOB')) > 0 // Se possui o update dos novos campos processa
        _nPosCpo := Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_PESOL"} )
        If _nPosCpo > 0
            aCabPV[_nPosCpo,2] := _nVS1PesoL // Valor Seguro
        Endif
        _nPosCpo := Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_PBRUTO"} )
        If _nPosCpo > 0
            aCabPV[_nPosCpo,2] := _nVS1PesoB // Valor Seguro
        Endif
        _nPosCpo := Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_VOLUME1"} )
        If _nPosCpo > 0
            aCabPV[_nPosCpo,2] := _nVS1Vol1 // Valor Seguro
        Endif
        _nPosCpo := Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_VOLUME2"} )
        If _nPosCpo > 0
            aCabPV[_nPosCpo,2] := _nVS1Vol2 // Valor Seguro
        Endif
        _nPosCpo := Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_VOLUME3"} )
        If _nPosCpo > 0
            aCabPV[_nPosCpo,2] := _nVS1Vol3 // Valor Seguro
        Endif
        _nPosCpo := Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_VOLUME4"} )
        If _nPosCpo > 0
            aCabPV[_nPosCpo,2] := _nVS1Vol4 // Valor Seguro
        Endif
    EndIf    
	If Len(aItePv) <> Len(_aItemVS3)
    	aItePv := Aclone(_aItemVS3)
	EndIf	
End Sequence
Return _lRet


//Gravar informações que serão enviadas pela SC5 na Nota Fiscal (SF2)
Static Function OX004APVMS()
Local _lRet 	:= .T.
Local _aPedAuto	:= {}
Local _aMenPad	:= {}
Local _aEspecie	:= {}
Local _cPicking	:= ""
Local _cMsg		:= ""
Local _cMensNF	:= ""
Local _nQtdVol	:= 0
Local _nPesoC	:= 0
Local _nPosCpo 
Local _nPos
Local _cNumOrc
Local _cModal := ""
local _cTped  := ""

Begin Sequence
	VS1->(DbSetOrder(1))
	For _nPos := 1 To Len(aOrcs)
        _cNumOrc := aOrcs[_nPos]
        If VS1->(DbSeek(XFilial("VS1")+_cNumOrc))
			//Guardo pedido Autoware
			If !Empty(VS1->VS1_XPVAW) .and. Ascan(_aPedAuto,AllTrim(VS1->VS1_XPVAW)) == 0
				Aadd(_aPedAuto,AllTrim(VS1->VS1_XPVAW))
			EndIf
			//Mensagem padrão
			If !Empty(VS1->VS1_MENPAD) .and. Ascan(_aMenPad,AllTrim(VS1->VS1_MENPAD)) == 0
				Aadd(_aMenPad,AllTrim(VS1->VS1_MENPAD))
			EndIf
			//Especie
			If !Empty(VS1->VS1_ESPEC1) .and. Ascan(_aEspecie,AllTrim(VS1->VS1_ESPEC1)) == 0
				Aadd(_aEspecie,AllTrim(VS1->VS1_ESPEC1))
			EndIf
			//Nr Picking este é unico
			If Empty(_cPicking)
				_cPicking	:= AllTrim(VS1->VS1_XPICKI) 
			EndIF
		Endif
	Next
	//verificar quantidade maxima picking
	If !Empty(_cPicking)
		_cMsg := OX4APVMSZK(_cPicking, @_nQtdVol, @_nPesoC)
	EndIf
	//mensagem padrão
	If Len(_aMenPad) > 0
	    _nPosCpo := Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_MENPAD "} )
   	 	If _nPosCpo > 0
	    	aCabPV[_nPosCpo,2] := _aMenPad[1] // inicialmente so colocar a primeira msg padrão
		Else
			aAdd(aCabPV, {"C5_MENPAD", _aMenPad[1] , Nil})
    	Endif
	Endif	
	//Quantidade de volumes
	If _nQtdVol > 0  
    	_nPosCpo := Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_VOLUME1 "} )
    	If _nPosCpo > 0
	    	aCabPV[_nPosCpo,2] := _nQtdVol 
		Else
			aAdd(aCabPV, {"C5_VOLUME1", _nQtdVol , Nil})
		EndIf	
    Endif
	//Especie
	If Len(_aEspecie) == 0
		Aadd(_aEspecie,"VOLUME")
	EndIf
	If Len(_aEspecie) > 0
	    _nPosCpo := Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_ESPECI1 "} )
   	 	If _nPosCpo > 0
	    	aCabPV[_nPosCpo,2] := _aEspecie[1] // inicialmente so colocar a primeira msg padrão
    	Else
			aAdd(aCabPV, {"C5_ESPECI1", _aEspecie[1] , Nil})
		Endif
	Endif	
	//mensagem da nota
	If !Empty(_cPicking)
 		_cMensNF += "Pedido: " + _cPicking
	EndIf

    //Incluído aqui conf. solicitação Juarez 20/06/22
	_cMensNF 	+= " "
	_cMensNF 	+= "PESO CUBADO"
	_cMensNF 	+= " "
	_cMensNF 	+= AllTrim(STR(_nPesoC))

    //Incluir Tipo de Pedido e Modal 
	If !Empty(VS1->VS1_XTPPED) .OR. !Empty(VS1->VS1_XTPTRA)
		VX5->(dbSetOrder(1))
		If VX5->(dbSeek(xFilial("VX5")+"Z00"+VS1->VS1_XTPPED))
            _cTped := VX5->VX5_DESCRI
		ELSE
			_lRet := .F.
		EndIf
        If VX5->(dbSeek(xFilial("VX5")+"Z01"+VS1->VS1_XTPTRA))
            _cModal := VX5->VX5_DESCRI
		ELSE
			_lRet := .F.
		EndIf
	EndIf
	//_cTped   := POSICIONE("VX5",1,XFILIAL("VX5")+"Z00"+VS1->VS1_XTPPED,"VX5_DESCRI")   //X3CBOXDESC('VS1_TIPORC', VS1->VS1_TIPORC)                                                                                       
    //_cModal  := POSICIONE("VX5",1,XFILIAL("VX5")+"Z01"+VS1->VS1_XTPTRA,"VX5_DESCRI") 
	_cMensNF += " "
	_cMensNF += "Ped:"
	_cMensNF += " "
	_cMensNF += AllTrim(_cTped) 
	_cMensNF += " "
	_cMensNF += "Mod:"
	_cMensNF += AllTrim(_cModal) 

	//volumes
	/* Ja sai na Obs da NF conforme alinhado com Zé 24/02/2022 DAC
	If Len(_aEspecie) > 0
		_cMensNF 	+= " "
		_cMensNF 	+= AllTrim(STR(_nQtdVol))
		_cMensNF 	+= " "
		_cMensNF 	+= _aEspecie[1]
	Endif
	*/
	//localizar mensagem nota
	//_cMensNF 	+= " "
	//_cMensNF 	+= "PESO CUBADO"
	//_cMensNF 	+= " "
	//_cMensNF 	+= AllTrim(STR(_nPesoC))

    //Colocado o Pedido AW no final a pedido do JC dia 07/07/22
	If Len(_aPedAuto) > 0
		_cMensNF += " "
		_cMensNF += "Ped AW:"	
		For _nPos := 1 To Len(_aPedAuto)
			_cMensNF += " "
			_cMensNF += _aPedAuto[_nPos]
		Next
	EndIf

	_cMensNF 	+= " "
	_cMensNF 	+= AllTrim(_cMsg)
	_cMensNF 	:= Upper(AllTrim(_cMensNF))
   _nPosCpo 	:= Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_MENNOTA"} )
 	If _nPosCpo > 0
    	aCabPV[_nPosCpo,2] := _cMensNF // inicialmente so colocar a primeira msg padrão
   	Else
		aAdd(aCabPV, {"C5_MENNOTA", _cMensNF , Nil})
	Endif

	//@project	GAP002 | Integração da separação - Informar produto e quantidade da cubagem - DAC 20/09/2023 
	//Gravar numero picking no SC5
	If SC5->(FieldPos("C5_XPICKI")) > 0 .And. !Empty(_cPicking)
   		_nPosCpo 	:= Ascan(aCabPV,{|x| AllTrim(x[1]) == "C5_XPICKI"} )
 		If _nPosCpo > 0
    		aCabPV[_nPosCpo,2] := _cPicking // inicialmente so colocar a primeira msg padrão
   		Else
			aAdd(aCabPV, {"C5_XPICKI", _cPicking , Nil})
		Endif
	Endif

End Sequence
Return _lRet


//pegar mensagem szk qtde vol e peso cubado no szk
Static Function OX4APVMSZK(_cPicking, _nQtdVol, _nPesoC)
Local _cAliasPesq	:= GetNextAlias()   
Local _cMsg			:= ""

Begin Sequence
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT 	SZK.R_E_C_N_O_ AS NREGSZK
		FROM  %Table:SZK% SZK			
		WHERE 	SZK.ZK_FILIAL  = %xFilial:SZK%
			AND SZK.ZK_XPICKI  = %Exp:_cPicking% 
           	AND SZK.%notDel%
	EndSQL	
	If (_cAliasPesq)->(Eof())
		Break
	Endif	 
	While (_cAliasPesq)->(!Eof())
		SZK->(DbGoto((_cAliasPesq)->NREGSZK))
		_nQtdVol 	:=  SZK->ZK_VLQTOT
		//Mensagem da Nota
		If !Empty(SZK->ZK_MENNOT)
			_cMsg 	+=  " "  
			_cMsg 	+=	AllTrim(SZK->ZK_MENNOT)
		EndIf
		_nPesoC	+=	SZK->ZK_XPESOC  
		(_cAliasPesq)->(DbSkip())
	EndDo	
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 

Return _cMsg
