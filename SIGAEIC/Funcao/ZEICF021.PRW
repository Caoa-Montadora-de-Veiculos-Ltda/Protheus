#Include "Protheus.Ch"
#Include "TopConn.Ch"
#Include "FWEditPanel.Ch"

Static eol := CHR(13)+CHR(10)
/*
==============================================================================================
Programa.:              ZEICF021
Autor....:              Reinaldo Rabelo
Data.....:              02/09/22
Descricao / Objetivo:   
Doc. Origem:
Solicitante:            
Uso......:              
Obs......:              
-----------------------------------------------------------------------------------------------
Historico:	
15/07/2022 -- Reinaldo Rabelo -- Barueri
		

===============================================================================================
*/
User Function ZEICF021(cINTCSV,cPoNum,nLayout)

Local aLinha		:= {}
Local aItem 		:= {}

Local lRetorno		:= .T.
Local lRet 			:= .T.

Local nY 			:= 0
Local nLinha		:= 0
Local nPos			:= 0
Local nRec 			:= 0 

Local cLinhaIT		:= ""
Local cLoteHyudai   := SUPERGETMV( "CMV_EICHYU",.F., "" )  //Ajuste no Lote da Invoice antecipada para Hyundai
Local cLote2Hyudai	:= SUPERGETMV( "CMV_EICHY2",.F., "" )  //Ajuste no Lote da Invoice antecipada para Hyundai se necessario
Local cLote3Hyudai	:= SUPERGETMV( "CMV_EICHY3",.F., "" )  //Ajuste no Lote da Invoice antecipada para Hyundai se necessario
Private lErro		:= .F.	
Private aDados		:= {}
Private cFornecedor	:= ""
Private cForloj		:= ""
Private cInvoice	:= ""
Private cPedido 	:= ""
Private lCapaOK     := .F.

Private dDtInvoice	:= dDataBase //CTOD("  /  /  ")
Private cIncoterm	:= ""
Private cFreInc		:= ""
Private cSegInc		:= ""
Private nVlrFre		:= 0
Private nVlrSeg		:= 0
Private nVlrInland	:= 0
Private nVlrPack	:= 0
Private nVlrDesc	:= 0
Private nVlOutD		:= 0
Private cWKSZM      := 'WKSZM'
Private nLay		:= 1
Private lOk_Anu		:= "2-Não"

Default cPoNum     := ""
Default nLayOut   := 5
aInvoice := {}
nLay := nLayOut
 
cLoteHyudai := Alltrim(cLoteHyudai) + alltrim(cLote2Hyudai) + alltrim(cLote3Hyudai)

If Empty(cINTCSV)
	U_FCMVEIC0101("Caminho do arquivo em Branco!",,,,"R",,,)
	MsgInfo("Caminho do arquivo em Branco!" + CRLF +  "Para ver um log do resultado clique no botão 'Log' ")
	Return(.F.)
EndIF

//If Empty(cPoNum) 
	//U_FCMVEIC0101("Numero da Purchase Order Não informado",,,,"R",,,)
	//Return(.F.)
//EndIf

DbSelectArea('SW2')
SW2->(DbSetOrder(1))
 
If !Empty(cPoNum) .and. !SW2->(DbSeek(FwXFilial('SW2')+cPoNum))
	U_FCMVEIC0101("Numero da Purchase Order Não Encontrado",,,,"R",cPoNum,,)
	MsgInfo("Numero da Purchase Order " + Alltrim(cPoNum) + " Não Encontrado" + CRLF +  "Para ver um log do resultado clique no botão 'Log' ")

	Return(.F.)
EndIf


/*
Lay-out do arquivo de importação
[01] SEQUENCIA DO ITEM
[02] NUMERO DA INVOICE
[03] NCM
[04] EX
[05] CODIGO PRODUTO
[06] QUANTIDADE
[07] VALOR UNITÁRIO
[08] CONTAINER
[09] CAIXA
[10] PESO LIQUIDO
[11] NUMERO DA PURCHASE ORDER
[12] CONHECIMENTO EMBARQUE
[13] NAVIO
*/

FT_FUse(cINTCSV)	
FT_FGotop()

MontaSZM()

While !FT_FEof()
	
	cLinhaIT := FT_FReadLn()
	lErro    := .F.
	nLinha++

	If  Empty(cLinhaIT)                                      .Or. ;
        cLinhaIT                == ";"                       .Or. ;
        SubStr(cLinhaIT,1,10)   == "Engine No."              .Or. ;
        cLinhaIT                == "CASE;MODEL;VIN-CODE;ENGINE;COLOR;SPECOP;KEYNO;T/MNO;"
		FT_FSkip()
		Loop
	EndIF

    aLinha := {}
	cLinhaIT := StrTran(cLinhaIT,';;','; ;')
	cLinhaIT := StrTran(cLinhaIT,';;','; ;')
    aLinha   := StrTokArr(cLinhaIT, ";")
    
	cInvoice := aLinha[02]
	
	if !Empty(cPoNum) .and. alltrim(cPoNum) <> alltrim(aLinha[11]) 
		FT_FSkip()
		loop
	Endif
	
	If (Len(aLinha) <> 13 .and. nLay == 5) .or. (Len(aLinha) <> 12 .and. nLay == 1)
 		U_FCMVEIC0101("Layout da linha inválido!",nLinha,,cFornecedor,cForloj,"R",,,cInvoice)
		lRetorno := .F.
	EndIF
	
	If Empty(AllTrim(aLinha[5]))
		U_FCMVEIC0101("Código de produto em branco!",nLinha,,cFornecedor,cForloj,"R",AllTrim(cPoNum),,cInvoice)
		lRetorno := .F.
	EndIf

	if nLay <> 5
		aLinha := aClone( fAjuArr(aLinha,nLay) )
	EndIf

	aLinha[11] := Padr(aLinha[11],TamSx3("W2_PO_NUM")[1], " ")
	
	If !SW2->(DbSeek(FwXFilial('SW2') + aLinha[11]))
		U_FCMVEIC0101("Numero da Purchase Order Não Encontrado",nLinha,,cFornecedor,cForloj,"R",aLinha[11],,cInvoice)
		lRetorno := .F.
	else
		cFornecedor	:= SW2->W2_FORN
		cForloj		:= SW2->W2_FORLOJ
		cPedido 	:= SW2->W2_PO_SIGA
		if (cFornecedor +cForloj) $  cLoteHyudai
			aLinha[09]	 := fAjutCaixa(aLinha[09])
		endif
		
	EndIf

	nRec := SetSZM(aLinha,cFornecedor,cForloj,cPedido)
	nPos := aScan(aDados, {|x| AllTrim(Upper(x[4])) == UPPER(ALLTRIM(aLinha[5])) .and. AllTrim(Upper(x[8])) == UPPER(ALLTRIM(aLinha[11]))})
	//aItem := {}
	aItem := {	StrZero( Val( aLinha[01] ), 4 ),;										//Linha
				VAL(aLinha[06]),;									//Quantidade
				VAL(StrTran(aLinha[07], ",", ".")),;				//Valor
				aLinha[08],;										//Container
				aLinha[09],;										//Caixa
				Val(StrTran(aLinha[10], ",", ".")),;				//Peso Liquido
				aLinha[11],;										//PURCHASE ORDER
				aLinha[12],;										//Conhecimento de Embarque
				aLinha[13],;										//Navio
				VAL(aLinha[06]),;									//Saldo
				Round(VAL( alltrim(StrTran(aLinha[07], ",", ".")) )/VAL( Alltrim( aLinha[06] ) ), 5 ),;//Preço Unitario
				0 ,;
				"",;						//RECSW3
				0 ,;
				"",;
				0 ,; 						//RECSW5
				nRec,; //Rec da Temporaria
				"",;
				.F.,;
				iif( nLay == 1 , aLinha[14] , "" );
			}
	
	if nPos == 0
		Aadd(aDados,{PadR(aLInha[2], TamSx3("EW5_INVOIC")[1], " "),;		//Invoive
					 PadR(aLInha[3], TamSx3("YD_TEC"    )[1], " "),;		//NCM
					 PadR(aLInha[4], TamSx3("W3_EX_NCM" )[1], " "),;		//EX-NCM
					 PadR(aLInha[5], TamSx3("EW5_COD_I" )[1], " "),;		//Produto
					 {aItem},;			//Dados da Invoice
					 VAL(aLInha[6]),;
					 0,;
					 PadR(aLinha[11],TamSx3("EW5_PO_NUM")[1], " ")})	//Total de Itens do Produto na Invoice

	else
		Aadd(aDados[nPos,5],aItem)
		aDados[nPos,6] += VAL(aLInha[6])
	endif
	
	FT_FSkip()
	
EndDo

FT_FUse()

nY := 1
If Len(aDados) == 0
	U_FCMVEIC0101("Layout da linha inválido!",nLinha,,cFornecedor,cForloj,"R",,,cInvoice)
	lRetorno := .F.
EndIf

dbSelectArea("EW4")
EW4->(dbSetOrder(1))
	
dbSelectArea("SA5")
SA5->(dbSetOrder(2))

cInvoice := Padr(aDados[1,1],  TamSX3("EW4_INVOIC")[1] )

If EW4->( dbSeek( xFilial("EW4") + cInvoice ) )
	conout('Invoice já cadastrada anterioemnte')
	U_FCMVEIC0101("Número da Invoice já existe!",nLinha,,EW4->EW4_FORN,EW4->EW4_FORLOJ,"R",AllTrim(aDados[1,8]),,cInvoice)
	//MsgInfo("Número da Invoice " + alltrim(aDados[1]) + " já existe!" + CRLF +  "Para ver um log do resultado clique no botão 'Log' ")
	lRetorno := .F.
Endif
lErro := !lRetorno 
//If lRetorno
	//if nLay == 1
lRet := Val1Dados() // Unificando os Layout da Montadora com Barueri
	//if lRet	
SetArea()
If lRet 
	CMV01Capa()
Else
	lErro := .T.
endif
	
If lCapaOK .and. !lErro
	FWMsgRun(, {|| CMV01GravaInv() }, "", "Gravando Tabelas EW4 e EW5...")
		
	FWMsgRun(, {|| zGrvArq() }, "", "Gravando SZM...")
		
	// renomeia arquivo .csv
	if lOk
		fRename(cINTCSV,Subs(cINTCSV,1,At(".CSV",Upper(cINTCSV))-1)+".OK")
	endif
	MsgInfo("Integração concluida com sucesso!" + CRLF +  "Para ver um log do resultado clique no botão 'Log' ")
else
	if lErro
		MsgStop("Integração Cancelada Consulta Log!")	
	else
		MsgStop("Integração Cancelada pelo Usuário!")
	endif

EndIf

Return(lRetorno)


//-------------------------------------------------------------------------------


//-------------------------------------------------------------------------------
Static Function ValDados()
Local lRet 		:= .T.
Local lErro 	:= .F.
Local lAux 		:= .T.

Local cAliasW3 	:= "TBLW3"
Local cProduto 	:= ""
Local cChave   	:= ""
Local cTipo 	:= ""
Local cPGI_NUM  := ""

Local nX 		:= 1
Local nY 		:= 1
Local nTotal 	:= 0
Local nSaldoAnt := 0
Local nSaldo    := 0
Local nRec		:= 0
Local nQuant    := 0

For nY := 1 to len(aDados)

	nX        := 1
	nTotal    := 0
	nSaldo    := 0
	nSaldoAnt := 0 
	
	cProduto := aDados[nY,4]
	
	//if Empty(cPoNum)
	cPoNum   := aDados[nY,8]
	//EndIf
	
	QrySW3(cAliasW3,cProduto)
	nLinha := nY
	If (cAliasw3)->(eof())
		U_FCMVEIC0101("Item " + AllTrim(cProduto) + " não existe no pedido " + SW2->W2_PO_NUM ,nLinha,AllTrim(cProduto) ,cFornecedor,cForloj,"R",AllTrim(cPoNum), , cInvoice)
		lErro := .T.
	EndIf

	While !(cAliasw3)->(eof())

		iif (nX > 1, nX--, nX:=1)
		lAux := .T.
		
		cTipo    := (cAliasW3)->W3_FLUXO
		cPGI_NUM := (cAliasW3)->W5_PGI_NUM 

		if cTipo == "7" .or. ( cTipo == "1" .and. !empty( (cAliasW3)->W5_PGI_NUM ) )
			nTotal += (cAliasW3)->W5_SALDO_Q
			nQuant := (cAliasW3)->W5_SALDO_Q
			nSaldo := (cAliasW3)->W5_SALDO_Q + ABS(nSaldo)
			cChave := SubStr((cAliasW3)->CHVW5,1,88)  //7
			nRec   := (cAliasW3)->SW5REC
		else
			nTotal += (cAliasW3)->W3_SALDO_Q
			nQuant := (cAliasW3)->W3_SALDO_Q
			nSaldo := (cAliasW3)->W3_SALDO_Q + ABS(nSaldo)
			cChave := SUBSTR((cAliasW3)->CHVW3,1,80)//1
			nRec   := (cAliasW3)->SW3REC
		EndIf						
		
		aDados[nY,7] := nTotal
		nSaldoAnt := 0
		While nX <= len(aDados[nY,5]) .and. lAux
			if aDados[nY,5,nX,10] > 0
				nSaldo := (aDados[nY,5,nX,10] + nSaldoAnt) - nSaldo
				if nSaldo <= 0
					aDados[nY,5,nX,10] := 0//aDados[nY,5,nX,2] - (cAliasW3)->W5_SALDO_Q
					aDados[nY,5,nX,12] := nSaldo * (-1)  //(cAliasW3)->W5_SALDO_Q - aDados[nY,5,nX,2] 
					nSaldoAnt := 0
					aDados[nY,5,nX,18] := cPGI_NUM
				else
					aDados[nY,5,nX,10] := nSaldo
					aDados[nY,5,nX,12] := 0
					nSaldoAnt := nSaldo
					nSaldo    := 0
					aDados[nY,5,nX,18] := cPGI_NUM
				Endif
				if Empty(aDados[nY,5,nX,13]) .or. aDados[nY,5,nX,14] <> nRec
					aDados[nY,5,nX,13] := cTipo
					aDados[nY,5,nX,14] := nRec
					aDados[nY,5,nX,15] := cChave
					aDados[nY,5,nX,18] := cPGI_NUM
				EndIf
				aDados[nY,5,nX,16] := nQuant
				
				if aDados[nY,5,nX,10] <= 0 //.and. aDados[nY,5,nX,12] <= 0
					lAux := .F.
				EndIf
			EndIF
			nLinha := aDados[nY,5,nX,1]
			nX ++
		EndDo				
				
		(cAliasw3)->(dbSkip())
	EndDo

	if aDados[nY,6] >aDados[nY,7]
		U_FCMVEIC0101("Não há saldo para o Item " + AllTrim(cProduto) + "  pedido : " + cPoNum ,nLinha,AllTrim(cProduto) ,cFornecedor,cForloj,"R",AllTrim(cPoNum), , cInvoice)
		lErro := .T.
	endif

	If  Empty(GetAdvFVal("SYD", "YD_TEC", FwXFilial("SYD") + aDados[nY,2] + aDados[nY,3], 1, " ")) == .T.
		U_FCMVEIC0101("NCM + Ex não cadastrado: " + aDados[nY,2] + aDados[nY,3] + " não encontrado no sistema!", nLinha,AllTrim(cProduto),cFornecedor,cForloj,"R",cPoNum,,cInvoice)
		lErro := .T.
	EndIF

Next nY

lRet := !lErro

Return lRet

//-------------------------------------------------------------------------------


//-------------------------------------------------------------------------------
Static Function Val1Dados()
Local lRet 		:= .T.
Local lErro 	:= .F.
Local lAux 		:= .F.

Local cAliasW3 	  := "TBLW3"
Local cAliasSaldo := "TBWS5"
Local cProduto 	  := ""
//Local cChave   	  := ""
Local cTipo 	  := ""
Local cPGI_NUM    := ""

Local nX 		:= 1
Local nY 		:= 1
Local nZ		:= 1
Local nTotal 	:= 0
Local nSaldoAnt := 0
Local nSaldo    := 0
//Local nRec		:= 0
Local nQuant    := 0
Local nLin      := 0
Local aTotal    := {0,0}
//Local lCriaLin  := .F.
Local aSaldos   := {}

For nY := 1 to len(aDados)

	nX        := 1
	nTotal    := 0
	nSaldo    := 0
	nSaldoAnt := 0 
	aSaldos   := {}
	lErro     := .F.
	aSort( aDados[nY,5] , , , { |x,y| x[2] > y[2] } )
	
	cProduto := aDados[ nY , 4 ]
	cPoNum   := aDados[ nY , 8 ]
	nLin     := Len( aDados[ nY , 5 ] )
	aTotal   := QrySaldo( cAliasSaldo , cProduto )

	QrySW3(cAliasW3,cProduto)
	nLinha := nY

	If (cAliasw3)->(eof())
		U_FCMVEIC0101("Item " + AllTrim(cProduto) + " não existe no pedido " + AllTrim(cPoNum) ,nLinha,AllTrim(cProduto) ,cFornecedor,cForloj,"R",AllTrim(cPoNum), , cInvoice)
		lErro := .T.
	EndIf
	
	While !(cAliasw3)->(eof())
		
		cTipo    := (cAliasW3)->W3_FLUXO 
		cPGI_NUM := (cAliasW3)->W5_PGI_NUM
		
		IF (cAliasW3)->W5_SALDO_Q <= 0 .AND. (cAliasW3)->W3_SALDO_Q <= 0
			(cAliasW3)->(DbSkip())
			Loop
		ENDIF

		if cTipo == "7" .or. ( cTipo == "1" .and. !empty( (cAliasW3)->W5_PGI_NUM ) )
			aadd( aSaldos, {cProduto,;
							aTotal[2],;
							(cAliasW3)->W5_SALDO_Q,;
							(cAliasW3)->W5_SALDO_Q ,;
							SubStr((cAliasW3)->CHVW5,1,88),;
							(cAliasW3)->SW5REC;
							})
		else
			aadd( aSaldos, {cProduto,;
							aTotal[1],;
							(cAliasW3)->W3_SALDO_Q,;
							(cAliasW3)->W3_SALDO_Q ,;
							SUBSTR((cAliasW3)->CHVW3,1,80),;
							(cAliasW3)->SW3REC;
							})
			
		EndIf
		(cAliasW3)->(DbSkip())
	ENDDO	
	nZ := 0
	 
	For nX := 1 to  len(aDados[nY,5]) 
		 
		if aDados[nY,5,nX,19] 
			LOOP
		EndIf
		aSort( aSaldos , , , { |x,y| x[4] > y[4] } )

		nZ := aScan(aSaldos,{|x| x[4] == aDados[nY,5,nX,10] .and. x[4] > 0 })
		
		If nZ > 0
			nSaldo += aSaldos[nZ,4]
			aDados[nY,5,nX,10] := aSaldos[nZ,4]
			aDados[nY,5,nX,12] := 0
			aDados[nY,5,nX,16] := aDados[nY,5,nX,10]
			aDados[nY,5,nX,13] := cTipo
			aDados[nY,5,nX,14] := aSaldos[nZ,6] //Rec
			aDados[nY,5,nX,15] := aSaldos[nZ,5] //Chave
			aDados[nY,5,nX,18] := cPGI_NUM
			aDados[nY,5,nX,19] := .T.
			aSaldos[nZ,4] := 0
			aDados[nY,7] += aDados[nY,5,nX,16]
			nQuant := 0
			Loop
		EndIf

		nZ := aScan(aSaldos,{|x| x[4] < aDados[nY,5,nX,2] .and. x[4] > 0 })
		if nZ > 0
			nQuant := aDados[nY,5,nX,10]
			nSaldo += aSaldos[nZ,4]
			aDados[nY,5,nX,10] := aSaldos[nZ,4]
			aDados[nY,5,nX,12] := nQuant - aSaldos[nZ,4] 
			aDados[nY,5,nX,16] := aDados[nY,5,nX,10]
			aDados[nY,5,nX,13] := cTipo
			aDados[nY,5,nX,14] := aSaldos[nZ,6] //Rec
			aDados[nY,5,nX,15] := aSaldos[nZ,5] //Chave
			aDados[nY,5,nX,18] := cPGI_NUM
			aDados[nY,5,nX,19] := .T.
			aSaldos[nZ,4] := 0
			aDados[nY,7] += aDados[nY,5,nX,16]
			nQuant := 0
		EndIf
		
		nZ := aScan(aSaldos,{|x| x[4] > aDados[nY,5,nX,2] .and. x[4] > 0 })
		if nZ > 0
			nQuant := aDados[nY,5,nX,10]
			nSaldo += aSaldos[nZ,4]
			aDados[nY,5,nX,10] := aDados[nY,5,nX,10]
			aDados[nY,5,nX,12] := 0//nQuant - aSaldos[nZ,4] 
			aDados[nY,5,nX,16] := aDados[nY,5,nX,10]
			aDados[nY,5,nX,13] := cTipo
			aDados[nY,5,nX,14] := aSaldos[nZ,6] //Rec
			aDados[nY,5,nX,15] := aSaldos[nZ,5] //Chave
			aDados[nY,5,nX,18] := cPGI_NUM
			aDados[nY,5,nX,19] := .T.
			aSaldos[nZ,4] := aSaldos[nZ,4] - nQuant
			aDados[nY,7] += aDados[nY,5,nX,16]
			nQuant := 0
		EndIf

	Next nX
	
	For nX := 1 to len(aDados[nY,5]) 
		aSort( aSaldos , , , { |x,y| x[4] > y[4] } )
		
		If  aDados[nY,5,nX,12] > 0
			aItem := {	Space(4),;				//Linha
						aDados[nY,5,nX, 12] ,;				//Quantidade
						aDados[nY,5,nX ,03] ,;				//Valor
						aDados[nY,5,nX ,04] ,;				//Container
						aDados[nY,5,nX ,05] ,;				//Caixa
						aDados[nY,5,nX ,06] ,;				//Peso Liquido
						aDados[nY,5,nX ,07] ,;				//PURCHASE ORDER
						aDados[nY,5,nX ,08] ,;				//Conhecimento de Embarque
						aDados[nY,5,nX ,09] ,;				//Navio
						aDados[nY,5,nX ,12] ,;				//Saldo
						aDados[nY,5,nX ,11] ,;				//Preço Unitario
						0 ,;
						"",;						//RECSW3
						0 ,;
						"",;
						0 ,; 						//RECSW5
						0 ,; 
						"",;//Rec da Temporaria
						.F.,;
						aDados[nY,5,nX ,20] ;
					}
			aDados[nY,5,nX ,12] := 0
			aadd(aDados[nY,5],aItem)
			nLin := Len(aDados[nY,5])
			nZ := aScan(aSaldos,{|x| x[4] == aDados[nY,5,nLin,10] .and. x[4] > 0 })
			
			If nZ > 0
				nSaldo += aSaldos[nZ,4]
				aDados[nY,5,nLin,10] := aSaldos[nZ,4]
				aDados[nY,5,nLin,12] := 0
				aDados[nY,5,nLin,16] := aDados[nY,5,nLin,10]
				aDados[nY,5,nLin,13] := cTipo
				aDados[nY,5,nLin,14] := aSaldos[nZ,6] //Rec
				aDados[nY,5,nLin,15] := aSaldos[nZ,5] //Chave
				aDados[nY,5,nLin,18] := cPGI_NUM
				aDados[nY,5,nLin,19] := .T.
				aSaldos[nZ,4] := 0
				aDados[nY,7] += aDados[nY,5,nLin,16]
				nQuant := 0
				Loop
			EndIf
			nZ := aScan(aSaldos,{|x| x[4] < aDados[nY,5,nLin,2] .and. x[4] > 0 })
			if nZ > 0
				nQuant := aDados[nY,5,nX,10]
				nSaldo += aSaldos[nZ,4]
				aDados[nY,5,nLin,10] := aSaldos[nZ,4]
				aDados[nY,5,nLin,12] := nQuant - aSaldos[nZ,4] 
				aDados[nY,5,nLin,16] := aDados[nY,5,nX,10]
				aDados[nY,5,nLin,13] := cTipo
				aDados[nY,5,nLin,14] := aSaldos[nZ,6] //Rec
				aDados[nY,5,nLin,15] := aSaldos[nZ,5] //Chave
				aDados[nY,5,nLin,18] := cPGI_NUM
				aDados[nY,5,nLin,19] := .T.
				aSaldos[nZ,4] := 0
				aDados[nY,7] += aDados[nY,5,nLin,16]
				nQuant := 0
			EndIf
			nZ := aScan(aSaldos,{|x| x[4] > aDados[nY,5,nLin,2] .and. x[4] > 0 })
			if nZ > 0
				nQuant := aDados[nY,5,nX,10]
				nSaldo += aSaldos[nZ,4]
				aDados[nY,5,nLin,10] := nQuant
				aDados[nY,5,nLin,12] := nQuant - aSaldos[nZ,4] 
				aDados[nY,5,nLin,16] := aDados[nY,5,nX,10]
				aDados[nY,5,nLin,13] := cTipo
				aDados[nY,5,nLin,14] := aSaldos[nZ,6] //Rec
				aDados[nY,5,nLin,15] := aSaldos[nZ,5] //Chave
				aDados[nY,5,nLin,18] := cPGI_NUM
				aDados[nY,5,nLin,19] := .T.
				aSaldos[nZ,4] := aSaldos[nZ,4] - nQuant
				aDados[nY,7] += aDados[nY,5,nLin,16]
				nQuant := 0
			EndIf
		endIf 
	Next nX

	
	if aDados[nY,6] > aDados[nY,7] //.and. !lErro
		U_FCMVEIC0101("Não há saldo para o Item " + AllTrim(cProduto) + "  pedido : " + cPoNum ,nLinha,AllTrim(cProduto) ,cFornecedor,cForloj,"R",AllTrim(cPoNum), , cInvoice)
		lErro := .T.
	endif

	If  /*!lErro .and.*/ Empty(GetAdvFVal("SYD", "YD_TEC", FwXFilial("SYD") + aDados[nY,2] + aDados[nY,3], 1, " ")) == .T.
		U_FCMVEIC0101("NCM + Ex não cadastrado: " + aDados[nY,2] + aDados[nY,3] + " não encontrado no sistema!", nLinha,AllTrim(cProduto),cFornecedor,cForloj,"R",cPoNum,,cInvoice)
		lErro := .T.
	EndIF
	if lErro
		lAux := .T.
	endif
Next nY
lErro := lAux
lRet := !lErro

Return lRet


//-------------------------------------------------------------------------------


//-------------------------------------------------------------------------------
Static Function QrySaldo(cAliasSaldo,cProduto)
Local cQuery := ''

cQuery += eol +  " Select " 
cQuery += eol +  "		sum(SW3.W3_SALDO_Q) as W3_SALDO_P, "
cQuery += eol +  "		sum(NVL(SW5.W5_SALDO_Q, 0 ) ) as W5_SALDO_P , "
cQuery += eol +  "      sum(NVL(EW5.EW5_QTDE  , 0 ) ) as EW5_QTDE, "
cQuery += eol +  "      sum(SW3.W3_SALDO_Q - NVL(EW5.EW5_QTDE  , 0 ) ) as W3_SALDO,"
cQuery += eol +  "      sum(NVL(SW5.W5_SALDO_Q, 0 ) - NVL(EW5.EW5_QTDE  , 0 )) as W5_SALDO "
cQuery += eol +  " FROM " + RetSqlName("SW3") + " SW3 " 

cQuery += eol +  " 	LEFT OUTER JOIN " + RetSqlName("SW5") + " SW5   " 
cQuery += eol +  " 		ON	SW5.W5_FILIAL  = '" + FwXFilial('SW5') + "' " 
cQuery += eol +  " 		AND	SW5.W5_PO_NUM  = SW3.W3_PO_NUM " 
cQuery += eol +  " 		AND	SW5.W5_SI_NUM  = SW3.W3_SI_NUM " 
cQuery += eol +  " 		AND	SW5.W5_FORN	   = SW3.W3_FORN " 
cQuery += eol +  " 		AND	SW5.W5_FORLOJ  = SW3.W3_FORLOJ " 
cQuery += eol +  " 		AND	SW5.W5_COD_I   = SW3.W3_COD_I " 
cQuery += eol +  " 		AND	SW5.W5_POSICAO = SW3.W3_POSICAO " 
cQuery += eol +  " 		AND	SW5.D_E_L_E_T_ = ' ' " 
cQuery += eol +  " 		AND SW5.W5_SALDO_Q > 0 "

cQuery += eol +  "LEFT OUTER JOIN " + RetSqlName("EW5") + " EW5 " 
cQuery += eol +  "		ON	EW5.EW5_FILIAL  = '" + FwXFilial('EW5') + "' "  
cQuery += eol +  "		AND	EW5.EW5_PO_NUM  = SW3.W3_PO_NUM "
cQuery += eol +  "		AND	EW5.EW5_SI_NUM  = SW3.W3_SI_NUM "
cQuery += eol +  "		AND	EW5.EW5_FORN	= SW3.W3_FORN "
cQuery += eol +  "		AND	EW5.EW5_FORLOJ  = SW3.W3_FORLOJ "
cQuery += eol +  "		AND	EW5.EW5_COD_I   = SW3.W3_COD_I "
cQuery += eol +  "		AND	EW5.EW5_POSICA  = SW3.W3_POSICAO "
cQuery += eol +  "		AND	EW5.D_E_L_E_T_ = ' '  "

cQuery += eol +  " WHERE	SW3.W3_FILIAL  = '" + FwXFilial('SW3') + "' " 
cQuery += eol +  "     	AND SW3.W3_SEQ 	   = 0 " 
cQuery += eol +  "  	AND	SW3.W3_FORN	   = '" + cFornecedor + "' " 
cQuery += eol +  "  	AND	SW3.W3_FORLOJ  = '" + cForloj     + "' " 
cQuery += eol +  "  	AND	SW3.W3_PO_NUM  = '" + cPoNum      + "' " 
cQuery += eol +  " 		AND SW3.W3_COD_I   = '" + cProduto    + "' " 
cQuery += eol +  " 		AND	SW3.D_E_L_E_T_ = ' ' " 
cQuery += eol +  " ORDER BY W3_COD_I , W3_SALDO_Q DESC , SW5.W5_SALDO_Q DESC " 

MemoWrite("C:\TEMP\"+FunName()+"1.SQL",cQuery)
//cQuery := ChangeQuery(cQuery)
IF Select(cAliasSaldo) > 0
	(cAliasSaldo)->(DbCloseArea())
	fErase(cAliasSaldo+GetDbExtension())
EndIf

dbUseArea(.F.,"TOPCONN",TcGenQry(,,cQuery ),cAliasSaldo,.T.,.T.)


Return iif((cAliasSaldo)->(!eof()), {(cAliasSaldo)->W3_SALDO , (cAliasSaldo)->W5_SALDO}, {0,0})


//-------------------------------------------------------------------------------


//-------------------------------------------------------------------------------
Static Function QrySW3(cAliasW3,cProduto)
Local cQuery := ''

cQuery += eol +  " SELECT " 
cQuery += eol +  " 	SW3.W3_FILIAL,  " 
cQuery += eol +  " 	SW3.W3_FLUXO, " 
cQuery += eol +  " 	SW3.W3_PO_NUM, " 
cQuery += eol +  " 	SW3.W3_COD_I, " 
cQuery += eol +  " 	SW3.W3_QTDE, " 
cQuery += eol +  " 	NVL(SW5.W5_QTDE,SW3.W3_QTDE) AS W5_QTDE,  " 
cQuery += eol +  " 	SW3.W3_SALDO_Q as SALDO_W3, " 
cQuery += eol +  "  NVL(SW5.W5_SALDO_Q, 0 ) AS SALDO_W5 ,"
cQuery += eol +  "  NVL(EW5.EW5_QTDE  , 0 ) AS EW5_QTDE ,
cQuery += eol +  "  (SW3.W3_SALDO_Q - NVL(EW5.EW5_QTDE  , 0 )) AS W3_SALDO_Q ,
cQuery += eol +  "  (NVL(SW5.W5_QTDE  , 0 ) - NVL(EW5.EW5_QTDE  , 0 )) AS W5_SALDO_Q ,
cQuery += eol +  "  NVL(SW5.W5_POSICAO,' ') AS W5_POSICAO, 
cQuery += eol +  " 	NVL(SW5.W5_PGI_NUM,' ') as W5_PGI_NUM , " 
cQuery += eol +  " 	SW3.R_E_C_N_O_ as SW3REC, " 
cQuery += eol +  " 	SW5.R_E_C_N_O_ as SW5REC, " 
cQuery += eol +  " 	W3_FILIAL || W3_PO_NUM || W3_CC || W3_SI_NUM || W3_COD_I || LPAD(TRIM(CAST(W3_REG AS VARCHAR(4))),4,' ') ||  LPAD(TRIM(CAST(W3_SEQ AS VARCHAR(2))),2,' ') AS CHVW3, " 
cQuery += eol +  "	NVL(W5_FILIAL || W5_PO_NUM || W5_COD_I || LPAD(TRIM(CAST(W5_SEQ AS VARCHAR(2))),2,' ') || W5_SI_NUM||LPAD(TRIM(CAST(W5_REG AS VARCHAR(4))),4,' ')|| W5_CC||W5_FABR ||W5_FABLOJ, ' ') AS CHVW5 " 
cQuery += eol +  " FROM " + RetSqlName("SW3") + " SW3 " 

cQuery += eol +  " 	LEFT OUTER JOIN " + RetSqlName("SW5") + " SW5   " 
cQuery += eol +  " 		ON	SW5.W5_FILIAL  = '" + FwXFilial('SW5') + "' " 
cQuery += eol +  " 		AND	SW5.W5_PO_NUM  = SW3.W3_PO_NUM " 
cQuery += eol +  " 		AND	SW5.W5_SI_NUM  = SW3.W3_SI_NUM " 
cQuery += eol +  " 		AND	SW5.W5_FORN	   = SW3.W3_FORN " 
cQuery += eol +  " 		AND	SW5.W5_FORLOJ  = SW3.W3_FORLOJ " 
cQuery += eol +  " 		AND	SW5.W5_COD_I   = SW3.W3_COD_I " 
cQuery += eol +  " 		AND	SW5.W5_POSICAO = SW3.W3_POSICAO " 
cQuery += eol +  " 		AND	SW5.D_E_L_E_T_ = ' ' " 
cQuery += eol +  " 		AND SW5.W5_SALDO_Q > 0 "

cQuery += eol +  "LEFT OUTER JOIN " + RetSqlName("EW5") + " EW5 " 
cQuery += eol +  "		ON	EW5.EW5_FILIAL  = '" + FwXFilial('EW5') + "' "  
cQuery += eol +  "		AND	EW5.EW5_PO_NUM  = SW3.W3_PO_NUM "
cQuery += eol +  "		AND	EW5.EW5_SI_NUM  = SW3.W3_SI_NUM "
cQuery += eol +  "		AND	EW5.EW5_FORN	= SW3.W3_FORN "
cQuery += eol +  "		AND	EW5.EW5_FORLOJ  = SW3.W3_FORLOJ "
cQuery += eol +  "		AND	EW5.EW5_COD_I   = SW3.W3_COD_I "
cQuery += eol +  "		AND	EW5.EW5_POSICA  = SW3.W3_POSICAO "
cQuery += eol +  "		AND	EW5.D_E_L_E_T_ = ' '  "

cQuery += eol +  " WHERE	SW3.W3_FILIAL  = '" + FwXFilial('SW3') + "' " 
cQuery += eol +  "     	AND SW3.W3_SEQ 	   = 0 " 
cQuery += eol +  "  	AND	SW3.W3_FORN	   = '" + cFornecedor + "' " 
cQuery += eol +  "  	AND	SW3.W3_FORLOJ  = '" + cForloj     + "' " 
cQuery += eol +  "  	AND	SW3.W3_PO_NUM  = '" + cPoNum      + "' " 
cQuery += eol +  " 		AND SW3.W3_COD_I   = '" + cProduto    + "' " 
cQuery += eol +  " 		AND	SW3.D_E_L_E_T_ = ' ' " 
cQuery += eol +  " ORDER BY W3_COD_I , W3_SALDO_Q DESC , SW5.W5_SALDO_Q DESC " 

MemoWrite("C:\TEMP\"+FunName()+".SQL",cQuery)
//cQuery := ChangeQuery(cQuery)
IF Select(cAliasW3) > 0
	(cAliasW3)->(DbCloseArea())
	fErase(cAliasW3+GetDbExtension())
EndIf

dbUseArea(.F.,"TOPCONN",TcGenQry(,,cQuery ),cAliasW3,.T.,.T.)


Return


//-------------------------------------------------------------------------------


//-------------------------------------------------------------------------------

Static Function SetArea()
Local nX 	 := 1
Local nY 	 := 1
Local cPesoB := 0
Local nLinha := 0
Local nQtd   := 0
Local nSaldo := 0 
Local nConsumido := 0

Local cCC     := ""
Local cSI  	  := ""
Local cPO  	  := ""
Local cPOS 	  := ""
Local cPGI 	  := ""
Local cFabLoj := ""
Local cSeq 	  := ""
Local cReg 	  := ""
Local cFabri  := ""
Local cSerMo  := ""
Local cChave  := ""
Local cProduto:= ""
Local Ctipo   := ""
Local cAuxChave := ""
Local lContinua := .T. 
Local lIncl 	:= .T.
Local cTexto := ""
	DbSelectArea('SW5')
	SW5->(DbSetOrder(3))
					
	DbSelectArea('SW3')
	SW3->(DbSetOrder(1))
	
	For nY := 1 to Len(aDados)					
		
		cProduto   := aDados[nY,4]
		nSaldo 	   := aDados[nY,6]
		nConsumido := 0
		
		For nX :=1 to Len(aDados[nY,5])
			lContinua := .T.
			
			if Empty(aDados[nY,5,nX,15])
				cAuxChave := cChave //:= aDados[nY,5,nX ,15]
				//cTipo  := aDados[nY,5,nX,13]
			Else
				cAuxChave := aDados[nY,5,nX ,15]
				cChave    := aDados[nY,5,nX ,15]
				cTipo     := aDados[nY,5,nX ,13]
			endIf

			nLinha := aDados[nY,5,nX ,1]
						
			if  cTipo == "7" .or. ( cTipo == "1" .and. !empty( aDados[nY,5,nX ,18]) )
				if SW5->(DbSeek(cChave))
					cCC  	:= SW5->W5_CC
					cSI  	:= SW5->W5_SI_NUM
					cPO  	:= SW5->W5_PO_NUM
					cPOS 	:= SW5->W5_POSICAO
					cPGI 	:= SW5->W5_PGI_NUM
					cFabLoj := SW5->W5_FABLOJ
					cSeq 	:= SW5->W5_SEQ
					cReg 	:= SW5->W5_REG
					cPesoB	:= SW5->W5_PESO_BR
					cFabri  := SW5->W5_FABR
				else
					lContinua := .F.
				endif
			else
				if SW3->(DbSeek(cChave))
					cCC  	:= SW3->W3_CC
					cSI  	:= SW3->W3_SI_NUM
					cPO  	:= SW3->W3_PO_NUM
					cPOS 	:= SW3->W3_POSICAO 
					cPGI 	:= SW3->W3_PGI_NUM
					cFabLoj := SW3->W3_FABLOJ
					cSeq 	:= SW3->W3_SEQ
					cReg 	:= SW3->W3_REG
					cPesoB	:= SW3->W3_PESO_BR///wkew5->(DbSeek(aDados[nY,1]+aDados[nY,8]+aDados[nY,4]+cSI+cPOS))
					cFabri  := SW3->W3_FABR
				else
					lContinua := .F.
				endif
			EndIf

			if !Empty(cChave )
				cAuxChave := aDados[nY,1]+cPO+cProduto+cSI+cPOS
			EndIf
			cTexto += cChave + chr(13)+chr(10)
			If lContinua
				
				if WKEW5->(DbSeek(cAuxChave ) )
					lIncl := .F.
				else
					lIncl := .T.
				EndIf
					
				if aDados[nY,5,nX,16] <= aDados[nY,6] .and. nConsumido < aDados[nY,6]
					if aDados[nY,5,nX,16] == 0 .or. nSaldo == 0
						nQtd :=  0 //aDados[nY,5,nX,2]
					else
						If nSaldo >= aDados[nY,5,nX,16]
							nQtd :=  aDados[nY,5,nX,16]
						elseIf nSaldo >= aDados[nY,5,nX,2]
							nQtd :=  aDados[nY,5,nX,2]
						else
							nQtd := nSaldo
						EndIf	
					EndIf	
					nSaldo := nSaldo - nQtd
				elseIf aDados[nY,5,nX,16] > aDados[nY,6] .and. nConsumido < aDados[nY,6]
					nQtd :=  aDados[nY,6]  //aDados[nY,5,nX,2]
					nSaldo := nSaldo - nQtd
				elseIf aDados[nY,5,nX,16] <= aDados[nY,6] .and. nConsumido >= aDados[nY,6]
					nQtd := 0
					nSaldo := nSaldo - nQtd
				elseIf aDados[nY,5,nX,16] > aDados[nY,6] .and. nConsumido >= aDados[nY,6]
					nQtd := 0
					nSaldo := nSaldo - nQtd
				else
					nQtd := 0
					nSaldo := nSaldo - nQtd
				EndIf
				
				fUpdSZM(aDados[nY,5,nX,17],cPos,cFornecedor,cForloj)
				
				if nQtd > 0	
				
					WKEW5->(RecLock("WKEW5",lIncl))
						//nSaldo := nSaldo - aDados[nY,5,nX,16]
						WKEW5->EW5_QTDE += nQtd
						nConsumido      += nQtd

						if lIncl
							WKEW5->EW5_INVOIC	:=	aDados[nY,1]
							WKEW5->EW5_COD_I	:=	aDados[nY,4]
							WKEW5->EW5_PRECO	:=	aDados[nY,5,nX,3]
							WKEW5->EW5_FORN		:=	cFornecedor
							WKEW5->EW5_FORLOJ	:=	cForloj
							WKEW5->EW5_CC		:=	cCC
							WKEW5->EW5_SI_NUM	:=	cSI
							WKEW5->EW5_PO_NUM	:=	cPO
							WKEW5->EW5_POSICA	:=	cPOS
							WKEW5->EW5_PGI_NU	:=	cPGI
							WKEW5->EW5_FABLOJ	:=	cFabLoj
							WKEW5->EW5_SEQ		:=	cSeq
							WKEW5->EW5_REG		:=	cReg
							WKEW5->EW5_PESOL	:=	aDados[nY,5,nX,6]
							WKEW5->EW5_PESOB	:=	aDados[nY,5,nX,6]
							WKEW5->EW5_FABR		:=	cFabri
							WKEW5->EW5_NCM		:=  aDados[nY,2]//cNcm
							WKEW5->EW5_EXNCM    :=  aDados[nY,3]//cExNcm
							WKEW5->EW5_XSERMO   :=  cSerMo
							WKEW5->EW5_XHOUSE	:=	zRetCarUni(aDados[nY,5,nX,8])
							WKEW5->EW5_XNAVIO	:=	zRetCarUni(aDados[nY,5,nX,9])
							WKEW5->EW5_XCASE	:=	zRetCarUni(aDados[nY,5,nX,5])
							WKEW5->EW5_XCONT	:=	zRetCarUni(aDados[nY,5,nX,4])
							WKEW5->EW5_XCHAV2	:=  cChave
							
							If nLay == 1
								WKEW5->EW5_XLOTE	:=	zRetCarUni(aDados[nY,5,nX,20]) + zRetCarUni(aDados[nY,5,nX,5])
							EndIf
							
							If aDados[nY,5,nX,13] == "1"
								lAnuente := .T.
								WKEW5->EW5_XFLUXO := "1"
								lOk_Anu		      := "1-Sim"
							Else
								WKEW5->EW5_XFLUXO := "2"
							EndIF
						EndIf
					WKEW5->(MSUnlock())
				EndIf
			Else
				U_FCMVEIC0101("Chave não encontrado " + AllTrim(cProduto) + " pedido : " + cPoNum ,nLinha,AllTrim(cProduto) ,cFornecedor,cForloj,"R",AllTrim(cPoNum), , cInvoice)
				lErro := .T.
			EndIf
		Next nY
	Next nX				
	//memowrite("C:\temp\cTexto.txt",cTexto)			

Return 

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function CMV01GravaInv()
  	Local nTotInv	:= 0
	Local nI        := 1
	Local cSeqEW5	:= StrZero(1,TamSX3("EW5_XITEW5")[1])
	Local aBind     as array
	Local cInvoice  := ""
	Local cHouse 	:= ""
	Local cNavio 	:= ""
	aBind := {}

	//WKEW5->(dbSetOrder(2))
	WKEW5->(DbGotop())
	
	
	dbSelectAre('SW2')
	SW2->(dbSetOrder(1))
	
	dbSelectArea("EW4")
	DbSetOrder(1)

	dbSelectArea("EW5")
	DbSetOrder(3)

Begin Transaction
		
	While !WKEW5->(EOF())

		cInvoice := WKEW5->EW5_INVOIC
		cHouse 	 := WKEW5->EW5_XHOUSE
		cNavio 	 := WKEW5->EW5_XNAVIO
		nTotalFOB := 0

		While cInvoice == WKEW5->EW5_INVOIC
			
			If EW5->(DbSeek(xFilial("EW5") + WKEW5->(EW5_PGI_NU + EW5_INVOIC + EW5_FORN + EW5_FORLOJ + EW5_PO_NUM + EW5_POSICA) ) )
				EW5->( RecLock( "EW5" , .F. ) )
					EW5->EW5_QTDE += WKEW5->EW5_QTDE
				EW5->(MSUnlock())
			Else
				EW5->(RecLock("EW5",.T.))
					EW5->EW5_FILIAL	:= xFilial("EW5")
					EW5->EW5_INVOIC	:= WKEW5->EW5_INVOIC //cInvoice
					EW5->EW5_FORN	:= WKEW5->EW5_FORN
					EW5->EW5_FORLOJ	:= WKEW5->EW5_FORLOJ
					EW5->EW5_CC		:= WKEW5->EW5_CC
					EW5->EW5_SI_NUM	:= WKEW5->EW5_SI_NUM
					EW5->EW5_PO_NUM	:= WKEW5->EW5_PO_NUM
					EW5->EW5_POSICA	:= WKEW5->EW5_POSICA
					EW5->EW5_PGI_NU	:= WKEW5->EW5_PGI_NU
					EW5->EW5_COD_I	:= WKEW5->EW5_COD_I
					EW5->EW5_QTDE 	:= WKEW5->EW5_QTDE
					EW5->EW5_PRECO	:= WKEW5->EW5_PRECO
					EW5->EW5_FABLOJ	:= WKEW5->EW5_FABLOJ
					EW5->EW5_SEQ	:= WKEW5->EW5_SEQ
					EW5->EW5_REG	:= WKEW5->EW5_REG
					EW5->EW5_PESOL	:= WKEW5->EW5_PESOL
					EW5->EW5_PESOB	:= WKEW5->EW5_PESOB
					EW5->EW5_FABR	:= WKEW5->EW5_FABR
					EW5->EW5_XLOTE	:= WKEW5->EW5_XLOTE
					EW5->EW5_XCASE	:= WKEW5->EW5_XCASE
					EW5->EW5_XCONT	:= WKEW5->EW5_XCONT
					EW5->EW5_XVIN	:= WKEW5->EW5_XVIN
					EW5->EW5_XMOTOR	:= WKEW5->EW5_XMOTOR
					EW5->EW5_XCHAVE	:= WKEW5->EW5_XCHAVE
					EW5->EW5_XOPC	:= WKEW5->EW5_XOPC
					EW5->EW5_XANOFB	:= WKEW5->EW5_XANOFB
					EW5->EW5_XANOMD	:= WKEW5->EW5_XANOMD
					EW5->EW5_XCORIN	:= WKEW5->EW5_XCORIN
					EW5->EW5_XCOREX	:= WKEW5->EW5_XCOREX
					EW5->EW5_XSERMO	:= WKEW5->EW5_XSERMO

					If WKEW5->EW5_XFLUXO == "1"
						EW5->EW5_XFLUXO := "1"
					Else
						EW5->EW5_XFLUXO := "2"
					EndIF
					EW5->EW5_XITEW5 := cSeqEW5

				EW5->(MSUnlock())
				cSeqEW5 := Soma1(cSeqEW5)
			endif

			nTotalFOB := nTotalFOB + NoRound( WKEW5->EW5_QTDE * WKEW5->EW5_PRECO , 2 )
	
			IF aScan( aInvoice, { |x| x[1] ==  cInvoice } )== 0
				AAdd(aInvoice, {cInvoice,cHouse,cNavio})
			EndIF
				
			if zAtuNcmW3() == .T.
				U_FCMVEIC0101("Atualizado NCM + ExNCM na W3",, WKEW5->EW5_COD_I, WKEW5->EW5_FORN, WKEW5->EW5_FORLOJ, "A", WKEW5->EW5_PO_NUM, WKEW5->EW5_POSICA, cInvoice)
			EndIF
	
			//atualiza a PLI
			CMV01AtulizaPLI()
			//EndIf
			
			WKEW5->(dbSkip())
		EndDo


			nTotInv	:= nTotalFOB + IIF(cFreInc == "Sim",0,nVlrFre) + IIF(cSegInc == "Sim",0,nVlrSeg) + nVlrInland - nVlrDesc + nVlOutD + nVlrPack
			EW4->(RecLock("EW4",.T.))
				EW4->EW4_FILIAL	:=	xFilial("EW4")
				EW4->EW4_INVOIC	:=	cInvoice
				EW4->EW4_DT_EMI	:=	dDtInvoice
				EW4->EW4_FORN	:=	SW2->W2_FORN
				EW4->EW4_FORLOJ	:=	SW2->W2_FORLOJ
				EW4->EW4_MOEDA	:=	SW2->W2_MOEDA
				EW4->EW4_INCOTE	:=	cIncoterm
				EW4->EW4_COND_P	:=	SW2->W2_COND_PA
				EW4->EW4_DIAS_P	:=	SW2->W2_DIAS_PA
				EW4->EW4_FREINC	:=	IIF(cFreInc == "Sim","1","2")
				EW4->EW4_SEGINC	:=	IIF(cSegInc == "Sim","1","2")
				EW4->EW4_RATPOR	:=	IIF(cRateado == "Peso","1",IIF(cRateado == "Preço","2","3"))
				EW4->EW4_FOBTOT	:=	nTotalFOB
				EW4->EW4_FRETEI	:=	nVlrFre
				EW4->EW4_SEGURO	:=	nVlrSeg
				EW4->EW4_INLAND	:=	nVlrInland
				EW4->EW4_PACKIN	:=	nVlrPack
				EW4->EW4_DESCON	:=	nVlrDesc
				EW4->EW4_TOTINV	:=	nTotInv
				EW4->EW4_OK_SHP	:= 	lOk_SHP
				EW4->EW4_AGENTE	:= 	Sw2->W2_Agente
				EW4->EW4_Usr_AU	:=	SubStr(cUsuario, 7, 15)
				EW4->EW4_U_Ok_A	:=	SubStr(cUsuario, 7, 15)
				
				If lOk_Shp == "1"
					EW4->EW4_DT_Lib	:=	dDataBase
				EndIF

				EW4->EW4_Agt_OK	:= 	lAgt_Ok

				If lOk_Shp="1"
					EW4->EW4_D_Ok_A	:=	dDataBase
				EndIF

				IF EW4->(FieldPos("EW4_XHOUSE")) > 0
					EW4->EW4_XHOUSE :=  aInvoice[nI][02]
				EndIF

				IF EW4->(FieldPos("EW4_XNAVIO")) > 0
					EW4->EW4_XNAVIO :=  aInvoice[nI][03]
				EndIF

				If lAnuente
					EW4->EW4_XFLUXO := "1"
				Else
					EW4->EW4_XFLUXO := "2"
				EndIF
				//EW4->EW4_XTOTIT := nTotItens	|
			EW4->(MSUnlock())

			//Apagando a SZD
			SZD->(dbSeek(xFilial("SZD")+cInvoice))

			While SZD->(!EOF())
				Reclock("SZD",.F.)
				SZD->(dbDelete())
				SZD->(MsUnlock())
				SZD->(dbSeek(xFilial("SZD")+cInvoice))
			EndDo
		//Gravando a SZD
		For nI := 1 To Len(aSZD)
			SZD->(RecLock("SZD",.T.))
			SZD->ZD_FILIAL	:= xFilial("SZD")
			SZD->ZD_CHAVE   := aSZD[nI,02]
			SZD->ZD_LOTE    := aSZD[nI,03]
			SZD->ZD_CAIXA   := aSZD[nI,04]
			SZD->ZD_QTDE    := aSZD[nI,05]
			SZD->(MSUnlock())
		Next
	
	EndDo
		lOk := .T.
		
		if !lOk
			MsgAlert("Existe inconsistencia de valores verifique o Logs", "Atenção")
		EndIf
		
	End Transaction

	WKEW5->(dbSetOrder(1))

Return


//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function zAtuNcmW3()
	Local lOk := .T.
	Local cmd := ""

	cmd := CRLF + " UPDATE " + RetSqlName("SW3") + " SET "
	cmd += CRLF + "	W3_TEC    = '" + WKEW5->EW5_NCM   + "', "
	cmd += CRLF + "	W3_EX_NCM = '" + WKEW5->EW5_EXNCM + "' "
	cmd += CRLF + " WHERE D_E_L_E_T_ = ' ' "
	cmd += CRLF + " AND W3_FILIAL = '" + FwXfilial("SW3") + "' "
	cmd += CRLF + " AND W3_PO_NUM = '" + WKEW5->EW5_PO_NUM + "' "
	cmd += CRLF + " AND W3_COD_I  = '" + WKEW5->EW5_COD_I + "' "

	If TcSQLExec(cmd) < 0
		FWAlertError("Erro na rotina zAtuNcmW3(): " + TcSqlError(), "CMVEIC01" )
		lOk := .F.
	EndIF

Return lOk

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function CMV01AtulizaPLI()
	LOCAL cOrdSw3  := SW3->(IndexOrd())
	LOCAL nSw3Recno:= SW3->(Recno())
	LOCAL bSw3Valid:= {|| 	SW3->(!EOF())	.And.;
							SW3->W3_FILIAL  == xFilial("SW3")  .AND.;
							SW3->W3_PO_NUM	== EW5->EW5_PO_NUM .AND.;
							SW3->W3_FORN	==	EW5->EW5_FORN  .AND. IIF(EICLoja(),SW3->W3_FORLOJ == EW5->EW5_FORLOJ,.T.) .And. ;
							SW3->W3_POSICAO ==	EW5->EW5_POSICA}
	
	SW3->(dbSetOrder(8))
	
	If SW3->(dbSeek(xFilial("SW3")+EW5->EW5_PO_NUM+EW5->EW5_POSICA))
		//	If SW3->W3_FLUXO == "7"  // Não anuentes = "7"
		cPli := ""
		
		While eval(bSw3Valid)
		
			If SW3->W3_SEQ <> 1
				SW3->(dbSkip())
				Loop

			EndIF

			//EW5->EW5_PGI_NU := SW3->W3_PGI_NUM
			SW5->(dbSetOrder(8))
			If SW5->(dbSeek(xFilial("SW5")+EW5->EW5_PGI_NU+EW5->EW5_PO_NUM+EW5->EW5_POSICA))
				SW5->(RecLock("SW5"),.F.)
				SW5->W5_INVANT := EW5->EW5_INVOIC
				SW5->(MSUnlock())

			EndIF

			Exit

		EndDo
		//		EndIF
	EndIF

	SW3->(dbSetOrder(cOrdSw3))
	SW3->(dbGoTo(nSw3Recno))

Return(.T.)



Static Function CMV01Capa()
	Local oDlg2
	Local cDados := substr(cInvoice,1,20)
	Local nCo1:=1, nCo2:=6, nCo3:=20 , nCo4:=26
	Local nOffP12 :=3//@ticket 1247174 - T09025 - Rubens Torquette Junior – Alteração por problema da ChoiceBar que foi para o topo da tela na P12
	Local nLarg := 100
	Local nAlt  := 2
	If Empty(cIncoterm)
		cIncoterm := Space(03)
	EndIF
	
	IF Len(aInvoice) > 1
		cDados := 'VARIAS'
	EndIF

	Define MSDialog oDlg2 Title "Informar dados da " + cTitulo From 0,0 TO 25,70 Of oMainWnd
		@ 0.2 + nOffP12,nCo1	Say "Invoice:"
		@ 0.2 + nOffP12,nCo2	MSGet cDados Picture "@!" SIZE nLarg,nAlt When .F. Of oDlg2
		@ 0.2 + nOffP12,nCo3	Say "Incoterm:"
		@ 0.2 + nOffP12,nCo4	MSGet cIncoterm F3 "SYJ" Picture "@!" VALID (ExistCPO("SYJ")) Of oDlg2
		@ 1.4 + nOffP12,nCo1	Say "Frete Incl S/N?" SIZE 4,2 Of oDlg2
		@ 1.4 + nOffP12,nCo2	Combobox cFreInc ITEMS {"Sim","Não"} When .T. SIZE 40,12 Of oDlg2
		@ 1.4 + nOffP12,nCo3	Say "Seg Incl S/N?" SIZE 4,2 Of oDlg2
		@ 1.4 + nOffP12,nCo4	Combobox cSegInc ITEMS {"Sim","Não"} When .T. SIZE 40,12 Of oDlg2
		@ 2.6 + nOffP12,nCo1	Say "Vlr Frete:"
		@ 2.6 + nOffP12,nCo2	MSGet nVlrFre Picture cPicVlr VALID (nVlrFre >= 0) Of oDlg2
		@ 2.6 + nOffP12,nCo3	Say "Vlr Seguro:"
		@ 2.6 + nOffP12,nCo4	MSGet nVlrSeg Picture cPicVlr VALID (nVlrSeg >= 0) of oDlg2
		@ 3.8 + nOffP12,nCo1	Say "Inland:"
		@ 3.8 + nOffP12,nCo2	MSGet nVlrInland Picture cPicVlr VALID (nVlrInland >= 0) Of oDlg2
		@ 3.8 + nOffP12,nCo3	Say "Packing:"
		@ 3.8 + nOffP12,nCo4	MSGet nVlrPack Picture cPicVlr VALID (nVlrPack >= 0) Of oDlg2
		@ 5.0 + nOffP12,nCo1	Say "Desconto:"
		@ 5.0 + nOffP12,nCo2	MSGet nVlrDesc Picture cPicVlr VALID (nVlrDesc >= 0) Of oDlg2
		@ 5.0 + nOffP12,nCo3	Say "Outras Desp:"
		@ 5.0 + nOffP12,nCo4	MSGet nVlOutD Picture cPicVlr VALID (nVlOutD >= 0) of oDlg2
		@ 6.2 + nOffP12,nCo1	Say "Rateado por:" SIZE 4,2 Of oDlg2
		@ 6.2 + nOffP12,nCo2	Combobox cRateado ITEMS {"Peso","Preço","Quantidade"} When .T. SIZE 80,12 Of oDlg2
		@ 6.2 + nOffP12,nCo3	Say "Data Invoice:"
		@ 6.2 + nOffP12,nCo4	MSGet dDtInvoice VALID !Empty(dDtInvoice) SIZE 50,08 of oDlg2
		@ 7.4 + nOffP12,nCo1	Say "Ok Agente:" SIZE 4,2 Of oDlg2
		@ 7.4 + nOffP12,nCo2	Combobox lAgt_Ok ITEMS {"1-Sim", "2-Não"} When .T. SIZE 40,12 Of oDlg2
		@ 7.4 + nOffP12,nCo1 + nOffP12+15	Say "Data Liberação:"
		@ 7.4 + nOffP12,nCo2 + nOffP12+15	MsGet dAgt_Ok Picture "@E" When lAgt_Ok="1" SIZE 80,12 Of oDlg2
		@ 8.6 + nOffP12,nCo1	Say "Ok Ship:" SIZE 4,2 Of oDlg2
		@ 8.6 + nOffP12,nCo2	Combobox lOk_Shp ITEMS {"1-Sim", "2-Não"} When .T. SIZE 40,12 Of oDlg2
		@ 8.6 + nOffP12,nCo1 + nOffP12+15	Say "Ok Ship:"
		@ 8.6 + nOffP12,nCo2 + nOffP12+15	MsGet	dOk_Shp Picture "@E" When lOk_Shp="1"  SIZE 80,12 Of oDlg2
	    @ 9.6 + nOffP12,nCo1	Say "Itens Anuente:" SIZE 8,2 Of oDlg2
		@ 9.6 + nOffP12,nCo2	MSGet lOk_Anu  When .F. SIZE 40,12 Of oDlg2
	Activate MSDialog oDlg2 ON INIT EnchoiceBar(oDlg2,{|| IIF(CMV01ValCapa(),(lCapaOK := .T.,oDlg2:End()),)},{|| lCapaOk := .F. ,oDlg2:End() },) Centered

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function CMV01ValCapa()
	Local lRet := .T.

	If Empty(cIncoterm)
		MsgStop("Incoterm em Branco!")
		lRet := .F.
	Else
		If !ExistCPO("SYJ",cIncoterm)
			lRet := .F.
		EndIF
	EndIF

	If nVlrFre < 0
		MsgStop("Frete não pode ser negativo!")
		lRet := .F.
	EndIF

	If nVlrSeg < 0
		MsgStop("Seguro não pode ser negativo!")
		lRet := .F.
	EndIF

	If nVlrInland < 0
		MsgStop("InLand não pode ser negativo!")
		lRet := .F.
	EndIF

	If nVlrPack < 0
		MsgStop("Packing não pode ser negativo!")
		lRet := .F.
	EndIF

	If nVlrDesc  < 0
		MsgStop("Desconto não pode ser negativo!")
		lRet := .F.
	EndIF

	If nVlOutD < 0
		MsgStop("Valor de Outras Despesas não pode ser negativo!")
		lRet := .F.
	EndIF

	If Empty(cFreInc)
		MsgStop("Informe se frete é incluso!")
		lRet := .F.
	EndIF

	If Empty(cSegInc)
		MsgStop("Informe se seguro é incluso!")
		lRet := .F.
	EndIF

	If Empty(cRateado)
		MsgStop("Informe a forma de rateio!")
		lRet := .F.
	EndIF

	If Empty(dDtInvoice)
		MsgStop("Informe a data da Invoice!")
		lRet := .F.
	EndIF

Return lRet

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function MontaSZM()
	Local aStrut1 := {}
	Local nArea	  := Select()
	Local cArqSZM_1 := soma1(cWKSZM)
	Local cArqSZM_2 := soma1(cArqSZM_1)
	If Select(cWKSZM) > 0
		(cWKSZM)->(dbCloseArea())
	EndIF

	dbselectArea("SX3")
	dbsetOrder(1)
	dbSeek("SZM")

	While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SZM"
		If !(SX3->X3_CAMPO $ "ZM_FILIAL")// .And. X3Uso(SX3->X3_USADO)
			AADD(aStrut1, {X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL})
		EndIF
		SX3->(DbSkip())
	EndDo

	// NCM e Ex para o layout de pecas
	//AADD(aStrut1, {"EW5_NCM"   , "C", TamSx3("B1_POSIPI")[1], 0})
	//AADD(aStrut1, {"EW5_EXNCM" , "C", TamSx3("B1_EX_NCM")[1], 0})
	//AADD(aStrut1, {"EW5_XNAVIO", "C", TamSx3("EW4_XNAVIO")[1], 0})
	//AADD(aStrut1, {"EW5_XHOUSE", "C", TamSx3("EW4_XHOUSE")[1], 0})
	//AADD(aStrut1, {"EW5_XCHAV2", "C", 100, 0})

	cArqSZM := CriaTrab(aStrut1, .T.)
	
	If File(cArqSZM_1+OrdBagExt())
		fErase(cArqSZM_1+OrdBagExt())
	EndIF
	
	If File(cArqSZM_2+OrdBagExt())
		fErase(cArqSZM_2+OrdBagExt())
	EndIF
	
	dbUseArea(.t.,,cArqSZM,cWKSZM,.T.,.F.)

	dbSelectArea(nArea)

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function SetSZM(aLinha,cFornecedor,cForloj,cPedido)
Local nRec := 0

Default cFornecedor := ""
Default cForloj 	:= ""
Default cPedido := ""

	RecLock('WKSZM',.T.)
		WKSZM->ZM_FILIAL := FwXFilial('SZM')
		WKSZM->ZM_INVOICE:= aLinha[02]
		WKSZM->ZM_NAVIO  :=zRetCarUni(aLinha[13])
		WKSZM->ZM_BL     :=aLinha[12]
		WKSZM->ZM_CONT   :=zRetCarUni(aLinha[08])
		WKSZM->ZM_LOTE   := iif(nLay == 1,zRetCarUni(Alltrim(aLinha[11])) ,' ' )
		WKSZM->ZM_CASE   :=zRetCarUni(aLinha[09])
		WKSZM->ZM_PROD   := aLinha[05]
		WKSZM->ZM_DESCR  := Posicione("SB1", 1, FwxFilial("SB1") + Alltrim(aLinha[05]), "B1_DESC")
		WKSZM->ZM_QTDE   := val(aLinha[06])
		WKSZM->ZM_UNIT   := iif(nLay == 1 , zRetCarUni(Alltrim(aLinha[14])) + zRetCarUni(Alltrim(aLinha[09])),' ' )
		WKSZM->ZM_DOC    := ""
		WKSZM->ZM_SERIE  := ""
		WKSZM->ZM_FORNEC := cFornecedor
		WKSZM->ZM_LOJA   := cForloj
		WKSZM->ZM_ITEM   := StrZero( Val( aLinha[01] ), 4 )
		WKSZM->ZM_EMIS   := date()
		WKSZM->ZM_CNPJ   := ""
		WKSZM->ZM_PO_NUM := aLinha[11]
		WKSZM->ZM_LOGERR := ""
		WKSZM->ZM_POSICAO:= ""
		WKSZM->ZM_PO_SIGA:= cPedido
		//aLinha[07] //Valor Unitario
		//aLinha[10] //Peso liquido
	WKSZM->(MsUnlock())
	
	nRec := WKSZM->(RECNO())
Return nRec 

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function fUpdSZM(nReg,cPos,cForn,cLoja)
Local aArea := GetArea()

If nReg > 0

	DbSelectArea('WKSZM')
	WKSZM->(DbGoto(nReg))
	RecLock('WKSZM', .F.)
		WKSZM->ZM_POSICAO 	:= cPos
		WKSZM->ZM_FORNEC	:= cForn
		WKSZM->ZM_LOJA		:= cLoja	
	WKSZM->(MsUnlock())

EndIf

RestArea(aArea)

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------
Static Function zGrvArq()
	Local lLimpaAnt:= .F.
	Local cErr	:= ""
	
	DbSelectArea('WKSZM')
	WKSZM->(DBGOTOP())

	while WKSZM->(!Eof())
		If lLimpaAnt = .F.
			TcSqlExec("DELETE FROM " + RetSqlName("SZM") + " WHERE D_E_L_E_T_ = '*' AND ZM_INVOICE = '" + WKSZM->ZM_INVOICE + "' "   )
			TcSqlExec("UPDATE " + RetSqlName("SZM") + " SET D_E_L_E_T_ = '*' WHERE ZM_FILIAL = '" + FwXfilial("SZM") + "' AND ZM_INVOICE = '" + WKSZM->ZM_INVOICE+ "' ")
			lLimpaAnt = .T.
		EndIF

		RecLock("SZM", .T.)
			SZM->ZM_FILIAL := WKSZM->ZM_FILIAL 
			SZM->ZM_INVOICE:= WKSZM->ZM_INVOICE
			SZM->ZM_NAVIO  := WKSZM->ZM_NAVIO  
			SZM->ZM_BL     := WKSZM->ZM_BL     
			SZM->ZM_CONT   := WKSZM->ZM_CONT   
			SZM->ZM_LOTE   := WKSZM->ZM_LOTE   
			SZM->ZM_CASE   := WKSZM->ZM_CASE   
			SZM->ZM_PROD   := WKSZM->ZM_PROD   
			SZM->ZM_DESCR  := WKSZM->ZM_DESCR  
			SZM->ZM_QTDE   := WKSZM->ZM_QTDE   
			SZM->ZM_UNIT   := WKSZM->ZM_UNIT   
			SZM->ZM_DOC    := WKSZM->ZM_DOC    
			SZM->ZM_SERIE  := WKSZM->ZM_SERIE  
			SZM->ZM_FORNEC := WKSZM->ZM_FORNEC 
			SZM->ZM_LOJA   := WKSZM->ZM_LOJA   
			SZM->ZM_ITEM   := WKSZM->ZM_ITEM   
			SZM->ZM_EMIS   := WKSZM->ZM_EMIS   
			SZM->ZM_CNPJ   := WKSZM->ZM_CNPJ   
			SZM->ZM_PO_NUM := WKSZM->ZM_PO_NUM 
			SZM->ZM_LOGERR := WKSZM->ZM_LOGERR 
			SZM->ZM_POSICAO:= WKSZM->ZM_POSICAO
			SZM->ZM_PO_SIGA:= WKSZM->ZM_PO_SIGA
		SZM->(MsUnlock())
		
		WKSZM->(DBSKIP( ))
	EndDo

	If cErr <> ""
		ApMsgStop("Erros encontrados: " + cErr, "CMVEIC01")
	EndIF
Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function fAjuArr(aLinha,nLayOut)
Local aAux   := ARRAY(13)
Local cProd  := " "
Local cNCM   := " "
Local cEXNCM := " "

Default nLayOut := 5

if nLayOut == 1
	cProd  := PadR(StrTran(aLinha[05],'-'),TamSx3("B1_COD"    )[1], " ")
	cNCM   := Posicione('SB1',1,xFilial('SB1') + cProd, "B1_POSIPI")
	cEXNCM := Posicione('SB1',1,xFilial('SB1') + cProd, "B1_EX_NCM")

	aAux[01] := aLinha[04] //SEQ
	aAux[02] := aLinha[02] //INVOICE
	aAux[03] := cNCM       //NCM 
	aAux[04] := cEXNCM     //EX
	aAux[05] := cProd      //CODIGO PRODUTO
	aAux[06] := aLinha[06] //QUANTIDADE
	aAux[07] := aLinha[07] //VALOR UNITARIO
	aAux[08] := aLinha[09] //CONTAINER
	aAux[09] := aLinha[10] //CAIXAS
	aAux[10] := "0"        // PESO LIQUIDO
	aAux[11] := aLinha[11] //NUMERO DA PURCHASE ORDER
	aAux[12] := aLinha[03] //CONHECIMENTO EMBARQUE SW6
	aAux[13] := aLinha[08] //NAVIO SW6
	aadd(aAux,aLinha[01])
Else
	aAux := aClone(aLinha)
endIf

Return aAux


Static Function zRetCarUni(cConteudo)
	Local cCarEsp		:= "!@#$%¨&()+{}^~´`][;.>,<=/¢¬§ªº'?|"+'"'
	Local nI			:= 0

	//Retirando caracteres
	For nI := 1 To Len(cCarEsp)
		cConteudo := StrTran(cConteudo, SubStr(cCarEsp, nI, 1), "")
	Next nI

Return cConteudo

Static Function fAjutCaixa(cCase)

cCase := alltrim(cCase)
If Len(cCase) < 3 .and. Type(cCase) == "N"
	cCase := strzero(val(cCase),3)
endif

Return cCase


/*
Layout == 1
  CKD
	LAYOUT 
	[01] LOTE
	[02] INVOICE
	[03] CONHECIMENTO EMBARQUE SW6
	[04] SEQ
	[05] CODIGO PRODUTO
	[06] QUANTIDADE
	[07] VALOR UNITARIO
	[08] NAVIO SW6
	[09] CONTAINER
	[10] CAIXAS
	[11] PO
	[12] unitizador

Layout == 5 e Geral

	Lay-out do arquivo de importação
	[01] SEQUENCIA DO ITEM
	[02] NUMERO DA INVOICE
	[03] NCM
	[04] EX
	[05] CODIGO PRODUTO
	[06] QUANTIDADE
	[07] VALOR UNITÁRIO
	[08] CONTAINER
	[09] CAIXA
	[10] PESO LIQUIDO
	[11] NUMERO DA PURCHASE ORDER
	[12] CONHECIMENTO EMBARQUE
	[13] NAVIO
*/
