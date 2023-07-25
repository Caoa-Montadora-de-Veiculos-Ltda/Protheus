#INCLUDE "PROTHEUS.CH"

/*
==============================================================================================
Programa.:              MT089CD
Autor....:              Evandro Mariano
Data.....:              02/03/22
Descricao / Objetivo:   
Doc. Origem:
Solicitante:            
Uso......:              
Obs......:              
-----------------------------------------------------------------------------------------------
Historico:	
15/07/2022 -- Reinaldo Rabelo -- Barueri
		Alteração do Bloco de Codigo:
		De
			Posicione('SYD' ,1 ,xFilial('SYD') + _cNCM ,'YD_XUFPROT' )
		Para
			Posicione('SYD' ,1 ,xFilial('SYD') + SB1->B1_POSIPI ,'YD_XUFPROT')
		Neste Ponto a SB1 já está aberta e posicionada no prdouto, assim evitando pegar o NCM errado.
		e Trazendo a TES correta.

===============================================================================================
*/

User Function MT089CD()//As variaveis foram carregada com paramixb somente para verificar o conteudo original.

	Local _cEmp  	:= FWCodEmp()
	Local _aRet 	:= {}
	
//PARAMIXB[1] //Condicao que avalia os campos do SFM
//PARAMIXB[2] //Forma de ordenacao do array onde o 1o elemento sera utilizado. Esse array inicialmente possui 9 posicoes
//PARAMIXB[3] //Regra de selecao dos registros do SFM
//PARAMIXB[4] //Conteudo a ser acrescentado no array
//PARAMIXB[6]  //Tipo de Operação

	If _cEmp == "2010" //Executa o p.e. somente para Anapolis.
		_aRet := zFMontadora()
    Else
        //Retorna os valores padrões quando Barueri
        //_aRet := {PARAMIXB[1],PARAMIXB[2],PARAMIXB[3],PARAMIXB[4],PARAMIXB[6]}
		_aRet := zFBarueri()
    EndIf

Return(_aRet)

/*
=====================================================================================
Programa.:              ZExecMont
Autor....:              TOTVS
Data.....:              03/02/2022
Descricao / Objetivo:   Executa o P.e. empresa Montadora
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/
Static Function zFMontadora()

	Local bCond 	:= PARAMIXB[1] //Condicao que avalia os campos do SFM
	Local bSort 	:= PARAMIXB[2] //Forma de ordenacao do array onde o 1o elemento sera utilizado. Esse array inicialmente possui 9 posicoes
	Local bIRWhile 	:= PARAMIXB[3] //Regra de selecao dos registros do SFM
	Local bAddTes 	:= PARAMIXB[4] //Conteudo a ser acrescentado no array
	Local cTabela 	:= PARAMIXB[5] //Tabela que esta sendo tratada
	Local cTpOper 	:= PARAMIXB[6]  //Tipo de Operação
	Local _cTesInt  := SUPERGETMV( "CMV_TPOPER", .F., '70/71')
	Local _nProd 

	If cTabela == "SC6" 
	
		_nProd := aScan(aHeader, {|x| AllTrim(x[2])=="C6_PRODUTO"}) 
		bCond     := {|| (Posicione("SB1",1,xFilial("SB1")+acols[n][_nProd],"B1_ORIGEM") == (cAliasSFM)->FM_XORIGEM .Or. Empty((cAliasSFM)->FM_XORIGEM) ) } 
		//Acrescenta compo novo a regra, esse campo devera ser acrescentdo no X2_UNICO do SFM. 
		if cTpOper $ _cTesInt
			bSort     := {|x,y| x[14] > y[14]} 
		else
			bSort     := {|x,y| x[11] > y[11]} 
		endif
		bIRWhile:= {||.T.}
		bAddTes := {||aAdd(aTes[Len(aTes)],(cAliasSFM)->FM_XORIGEM)}//Acrescento campo a ser considerado na TES Inteligente. 
	ElseIf cTabela == "" .And. FunName() == "VEIA060" 
	
		_nProd := FwFldGet("B1COD") 
		bCond     := {|| SB1->B1_ORIGEM == (cAliasSFM)->FM_XORIGEM .Or. Empty((cAliasSFM)->FM_XORIGEM)  } 
		
		//Acrescenta compo novo a regra, esse campo devera ser acrescentdo no X2_UNICO do SFM. 
		if cTpOper $ _cTesInt
			bSort     := {|x,y| x[14] > y[14]} 
		else
			bSort     := {|x,y| x[11] > y[11]} 
		endif
		bIRWhile:= {||.T.}
		bAddTes := {||aAdd(aTes[Len(aTes)],(cAliasSFM)->FM_XORIGEM)}//Acrescento campo a ser considerado na TES Inteligente. 
	Else
		bCond   := {||.T.}
		bSort   := bSort
		bIRWhile:= {||.T.}
		bAddTes := {||.T.}
	EndIf
	
Return({bCond,bSort,bIRWhile,bAddTes,cTpOper})

/*
=====================================================================================
Programa.:              ZExecMont
Autor....:              TOTVS
Data.....:              03/02/2022
Descricao / Objetivo:   Executa o P.e. empresa Montadora
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/
Static Function zFBarueri()

	Local bCond 	:= PARAMIXB[1] //Condicao que avalia os campos do SFM
	Local bSort 	:= PARAMIXB[2] //Forma de ordenacao do array onde o 1o elemento sera utilizado. Esse array inicialmente possui 9 posicoes
	Local bIRWhile 	:= PARAMIXB[3] //Regra de selecao dos registros do SFM
	Local bAddTes 	:= PARAMIXB[4] //Conteudo a ser acrescentado no array
	Local cTabela 	:= PARAMIXB[5] //Tabela que esta sendo tratada
	Local cTpOper 	:= PARAMIXB[6]  //Tipo de Operação
	Local _aArea	:= GetArea()
	Local _aAreaSB1 := SB1->(GetArea())
	Local _aAreaSYD := SYD->(GetArea())
	Local _aAreaSA1 := SA1->(GetArea())
	Local cMvProtoc := SuperGetMV("CMV_OPINSP",.F.,"81") // Parametro para indicar a Operação Insenta do Protocolo
	Local lInseProtocolo := !(cTpOper $ alltrim(cMvProtoc))
	Local _cTesInt := SUPERGETMV( "CMV_TPOPER", .F., '93')
		
	If  cTabela == "" .And. ( FunName() == "OFIXA011" .or. FunName() == "ZPECF008" )
		
		if cTpOper $ _cTesInt
			bSort     := {|x,y| x[14] > y[14]} 
		else
			bSort     := {|x,y| x[11] > y[11]} 
		endif
	
		bCond   := {||(!Empty((cAliasSFM)->FM_XORIGEM) .and. AllTrim(SB1->B1_ORIGEM ) == AllTrim((cAliasSFM)->FM_XORIGEM)) .or. Empty((cAliasSFM)->FM_XORIGEM)  } 
		bAddTes := {||AADD(aTes[Len(aTes)],(cAliasSFM)->FM_XORIGEM)}
	
		//alterado pos no ZPECFUNA chama função para atualizar fiscal		
		If FWIsInCallStack("U_ZPECF008") .or. FWIsInCallStack("U_ZPECFUNA")  
		
			If Posicione('SA1' ,1 ,xFilial('SA1') + VS1->VS1_CLIFAT + VS1->VS1_LOJA ,'A1_EST' ) $ "CE|SP" .And. !(VS1->VS1_XTPPED) $ '011' .AND. lInseProtocolo
	
				bCond     := {|| (AllTrim( Posicione('SYD' ,1 ,xFilial('SYD') + SB1->B1_POSIPI ,'YD_XUFPROT' ) ) == AllTrim((cAliasSFM)->FM_DESREF)  ) } 
				
				//Acrescenta compo novo a regra, esse campo devera ser acrescentdo no X2_UNICO do SFM. 
				if cTpOper $ _cTesInt
					bSort     := {|x,y| x[14] > y[14]} 
				else
					bSort     := {|x,y| x[11] > y[11]} 
				endif
				bIRWhile:= {||.T.}
				bAddTes := {||aAdd(aTes[Len(aTes)],AllTrim((cAliasSFM)->FM_DESREF))}//Acrescento campo a ser considerado na TES Inteligente. 
			
			EndIf
		Else
				
			If Posicione('SA1' ,1 ,xFilial('SA1') + M->VS1_CLIFAT + M->VS1_LOJA ,'A1_EST' ) $ "CE|SP" .And. !(M->VS1_XTPPED) $ '011' .and. lInseProtocolo
	
				bCond := {|| (AllTrim( Posicione('SYD' ,1 ,xFilial('SYD') + SB1->B1_POSIPI ,'YD_XUFPROT' ) ) == AllTrim((cAliasSFM)->FM_DESREF)  ) } 
				
				//Acrescenta compo novo a regra, esse campo devera ser acrescentdo no X2_UNICO do SFM. 
				if cTpOper $ _cTesInt
					bSort     := {|x,y| x[14] > y[14]} 
				else
					bSort     := {|x,y| x[11] > y[11]} 
				endif 
				bIRWhile:= {||.T.}
				bAddTes := {||aAdd(aTes[Len(aTes)],AllTrim((cAliasSFM)->FM_DESREF))}//Acrescento campo a ser considerado na TES Inteligente. 
			
			EndIf
		EndIf
	ElseIf cTabela == "" .And. (FWIsInCallStack("U_ZPECF010") .or. FWIsInCallStack("U_ZPECFUNA") .or. FWIsInCallStack("U_ZPECF011")) .or. FWIsInCallStack("U_ZPECF013")
		
		if cTpOper $ _cTesInt
			bSort     := {|x,y| x[14] > y[14]} 
		else
			bSort     := {|x,y| x[11] > y[11]} 
		endif
	
		bCond   := {||(!Empty((cAliasSFM)->FM_XORIGEM) .and. AllTrim(SB1->B1_ORIGEM) == AllTrim((cAliasSFM)->FM_XORIGEM)) .or. Empty((cAliasSFM)->FM_XORIGEM)  } 
		bAddTes := {||AADD(aTes[Len(aTes)],(cAliasSFM)->FM_XORIGEM)}
		
		If Posicione('SA1' ,1 ,xFilial('SA1') + VS1->VS1_CLIFAT + VS1->VS1_LOJA ,'A1_EST' ) $ "CE|SP" .And. !(VS1->VS1_XTPPED) $ '011' .and. lInseProtocolo
			
			bCond     := {|| (AllTrim( Posicione('SYD' ,1 ,xFilial('SYD') + SB1->B1_POSIPI ,'YD_XUFPROT' ) ) == AllTrim((cAliasSFM)->FM_DESREF)  ) } 
			//Acrescenta compo novo a regra, esse campo devera ser acrescentdo no X2_UNICO do SFM. 
			if cTpOper $ _cTesInt
				bSort     := {|x,y| x[14] > y[14]} 
			else
				bSort     := {|x,y| x[11] > y[11]} 
			endif 
			bIRWhile:= {||.T.}
			bAddTes := {||aAdd(aTes[Len(aTes)],AllTrim((cAliasSFM)->FM_DESREF))}//Acrescento campo a ser considerado na TES Inteligente. 
		EndIf
	
	ElseIf cTabela == "" .And. FunName() == "U_ZPECF999"
		
		if cTpOper $ _cTesInt
			bSort     := {|x,y| x[14] > y[14]} 
		else
			bSort     := {|x,y| x[11] > y[11]} 
		endif 
	
		bCond   := {||(!Empty((cAliasSFM)->FM_XORIGEM) .and. AllTrim(SB1->B1_ORIGEM ) == AllTrim((cAliasSFM)->FM_XORIGEM)) .or. Empty((cAliasSFM)->FM_XORIGEM)  } 
		bAddTes := {||AADD(aTes[Len(aTes)],(cAliasSFM)->FM_XORIGEM)}
		
		If Posicione('SA1' ,1 ,xFilial('SA1') + z01PECF999 + z02PECF999 ,'A1_EST' ) $ "CE|SP" .AND. !EMTPY((cAliasSFM)->FM_EST) .and. lInseProtocolo
	
			bCond     := {|| (AllTrim( Posicione('SYD' ,1 ,xFilial('SYD') + SB1->B1_POSIPI ,'YD_XUFPROT' ) ) == AllTrim((cAliasSFM)->FM_DESREF)  ) } 
			
			//Acrescenta compo novo a regra, esse campo devera ser acrescentdo no X2_UNICO do SFM. 
			if cTpOper $ _cTesInt
				bSort     := {|x,y| x[14] > y[14]} 
			else
				bSort     := {|x,y| x[11] > y[11]} 
			endif

			bIRWhile:= {||.T.}
			bAddTes := {||aAdd(aTes[Len(aTes)],AllTrim((cAliasSFM)->FM_DESREF))}//Acrescento campo a ser considerado na TES Inteligente. 
			
		EndIf
	Else
		bCond   := {||.T.}
		bSort   := bSort
		bIRWhile:= {||.T.}
		bAddTes := {||.T.}
	EndIf
		
	RestArea(_aArea)
	RestArea(_aAreaSB1)
	RestArea(_aAreaSYD)
	RestArea(_aAreaSA1)

Return({bCond,bSort,bIRWhile,bAddTes,cTpOper})

User Function ZFINF005()

Return .T.
