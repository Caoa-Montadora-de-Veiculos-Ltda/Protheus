#Include "Protheus.Ch"
#Include "Totvs.Ch"
 
/*/{Protheus.doc} PRCDOCIN
Função para gerar as Pré-Notas de Entrada e Pedidos de venda, após processamento do inventário - CAOA.
@author FSW - DWC Consult
@since 09/02/2019
@version 1.0
@type function 
/*/
User Function PRCDOCIN()
	Local nOpca		:= 0
	Local aMv_Par	:= {}
	Local aArea		:= GetArea()
	Local oDlg		:= Nil

	DEFINE MSDIALOG oDlg FROM  096,004 TO 355,625 TITLE OemToAnsi("Documentos Fiscais de Inventário") PIXEL
	@ 018, 009 TO 099,300 LABEL "" OF oDlg  PIXEL
	@ 029, 015 Say OemToAnsi("Este programa irá gerar os documentos abaixo, para regularização dos itens inventáriados.") SIZE 275, 10 OF oDlg PIXEL	
	@ 038, 015 Say OemToAnsi("Ganho no Inventário: Gera Pré-Nota de Entrada") 	 SIZE 275, 10 OF oDlg PIXEL	
	@ 048, 015 Say OemToAnsi("Perda no Inventário: Gera Pedido de Venda") 		 SIZE 275, 10 OF oDlg PIXEL
	@ 058, 015 Say Replicate("-",110) SIZE 255, 10 OF oDlg PIXEL	
	@ 068, 015 Say OemToAnsi("Nota:") SIZE 255, 10 OF oDlg PIXEL
	@ 078, 015 Say OemToAnsi("Rotina deve ser executada após efetivação do inventário") SIZE 275, 10 OF oDlg PIXEL

	DEFINE SBUTTON FROM 108,209 TYPE 5 ACTION ProtPerg(@aMv_Par)  ENABLE OF oDlg
	DEFINE SBUTTON FROM 108,238 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 108,267 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg

	If nOpca == 1
		If  !Empty(aMv_Par)
			Processa( {|| ProcDocs(aMv_Par)},"Processando....","",.F.)
		Else
			MsgAlert("Os Parâmetros não foram informados." + CRLF + CRLF + "Rotina não executada.","Parâmentros não informados !!!")
		EndIf
	EndIf

	RestArea(aArea)
Return



/*/{Protheus.doc} ProcDocs
Função para executar os MsExecAutos de Pré-Nota e Pedido de Venda.
@author FSW - DWC Consult
@since 09/02/2019
@version 1.0
@param aMv_Par, array, descricao
@type function
/*/ 
Static Function ProcDocs(aMv_Par)
Local cCampoCM  := AllTrim(GetMv('CMV_ACD001'))
Local nCustoM   := 0 
Local cAliDoc	:= ""
Local cNumPed	:= ""
Local cNumNF	:= ""
Local cSerNF	:= AllTrim(SuperGetMv('CA_INVSERI',.T., '1'))
//Local nItem		:= 0
Local cItem 	:= "00"
//Local cNextItem := 'A0'
Local cMenNota	:= ""
Local lDocs		:= .F.
Local lPeds		:= .F.
Local aDados	:= {}
Local aCabec	:= {}
Local aLinha	:= {}
Local aItens	:= {}
Private lMsErroAuto	:= .F.



	//Consulta os Movimentos para gerar a Pré-Nota.
	aDados := ConsZA0('E',aMv_Par)
	If aDados[2] > 0

		cAliDoc := aDados[1]
		ProcRegua(aDados[2])


		//(cAliDoc)->(DbGoTop())
		//While !(cAliDoc)->(EOF())

		//	If AllTrim(cCampoCM)=="B2_CM1"
		//		dbSelectArea("SB2")
		//		dbSetOrder(1)
		//		If dbSeek(xFilial('SB2')+(cAliDoc)->ZA0_COD + (cAliDoc)->ZA0_LOCAL )  //Posiciona no SB2
		//			If SB2->B2_CM1<=0
		//				MsgAlert("Não é permitida a inclusão de documento com o custo médio zerado! Produto ("+(cAliDoc)->ZA0_COD+")!","Documentos Fiscais de Inventário")
		//				Return
		//			Endif
		//		Endif
		//	Endif

		//	(cAliDoc)->(DbSkip())
		//EndDo


		cNumNF	 := Strzero( VAL( NxtSX5Nota(cSerNF,.T.,'1') ), TamSX3('F1_DOC')[1] )
		cMenNota := "Doc. de Inventário: " 

		Aadd( aCabec,{'F1_TIPO'	  ,'N'		  ,Nil} )
		Aadd( aCabec,{'F1_FORMUL' ,'S'		  ,Nil} )
		Aadd( aCabec,{'F1_DOC'	  ,cNumNF	  ,Nil} )
		Aadd( aCabec,{'F1_SERIE'  ,cSerNF	  ,Nil} )
		Aadd( aCabec,{'F1_ESPECIE','SPED'	  ,Nil} )
		Aadd( aCabec,{'F1_EMISSAO',aMv_Par[09],Nil} )
		Aadd( aCabec,{'F1_FORNECE',aMv_Par[07],Nil} )
		Aadd( aCabec,{'F1_LOJA'	  ,aMv_Par[08],Nil} )
		Aadd( aCabec,{'F1_COND'	  ,aMv_Par[05],Nil} )


		(cAliDoc)->(DbGoTop())
		While !(cAliDoc)->(EOF())

			IncProc('Gerando Pré-Nota de Entrada')
			nCustoM := 0 
			 
			//If AllTrim(cCampoCM)=="B2_CM1"
			//	dbSelectArea("SB2")
			//	dbSetOrder(1)
			//	If dbSeek(xFilial('SB2')+(cAliDoc)->ZA0_COD + (cAliDoc)->ZA0_LOCAL )  //Posiciona no SB2
			//		nCustoM := SB2->B2_CM1
			//	Endif
			//Endif
  
			aLinha := {}
			Aadd(aLinha,{'D1_COD'	,(cAliDoc)->ZA0_COD,Nil})
			Aadd(aLinha,{'D1_QUANT'	,(cAliDoc)->ZA0_QUANT,Nil})
			//Aadd(aLinha,{'D1_VUNIT'	,nCustoM	         ,Nil})
			Aadd(aLinha,{'D1_VUNIT'	,(cAliDoc)->ZA0_CUSTO1   ,Nil})
            Aadd(aLinha,{'D1_TOTAL'	,Round((cAliDoc)->ZA0_QUANT * (cAliDoc)->ZA0_CUSTO1,2),Nil})
			Aadd(aLinha,{'D1_CC'	,(cAliDoc)->ZA0_CC,Nil})
			Aadd(aItens,aLinha)

			If ! AllTrim(cMenNota) $ (cAliDoc)->ZA0_DOCB7	
				cMenNota += AllTrim((cAliDoc)->ZA0_DOCB7) + "\"
			EndIf

			(cAliDoc)->(DbSkip())
		EndDo

		Aadd( aCabec,{"F1_MENNOTA",cMenNota,Nil})

		Begin Transaction

			lMsErroAuto	:= .F.

			MsExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aItens, 3,,)

			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
			Else
				lDocs := .T.
			EndIf

		End Transaction

		(cAliDoc)->(DbCloseArea())
	EndIf

	//Consulta a tabela para gerar o Pedido de Venda.
	aDados := ConsZA0('S',aMv_Par)

	If aDados[2] > 0

		cAliDoc := aDados[1]
		ProcRegua(aDados[2])
		cNumPed := NextNumero("SC5",1,"C5_NUM",.T.) 


		
		//nItem  	 := 1
		cMenNota := "Doc. de Inventário: "
		aCabec 	 := {}
		aItens	 := {}

		Aadd( aCabec,{"C5_NUM"   	,cNumPed	,Nil})
		Aadd( aCabec,{"C5_TIPO" 	,"N"		,Nil})
		Aadd( aCabec,{"C5_CLIENTE"	,aMv_par[10],Nil})
		Aadd( aCabec,{"C5_LOJACLI"	,aMv_par[11],Nil})
		Aadd( aCabec,{"C5_CLIENT"	,aMv_par[10],Nil})
		Aadd( aCabec,{"C5_LOJAENT"	,aMv_par[11],Nil})
		Aadd( aCabec,{"C5_CONDPAG"	,aMv_par[05],Nil})
		Aadd( aCabec,{"C5_NATUREZ"	,aMv_par[12],Nil})

		(cAliDoc)->(DbGoTop())

		While !(cAliDoc)->(EOF())

			IncProc('Gerando Pedido de Venda')
			nCustoM := 0 
			
			//If AllTrim(cCampoCM)=="B2_CM1"
			//	dbSelectArea("SB2")
			//	dbSetOrder(1)
			//	If dbSeek(xFilial('SB2')+(cAliDoc)->ZA0_COD + (cAliDoc)->ZA0_LOCAL )  //Posiciona no SB2
			//		nCustoM := SB2->B2_CM1
			//	Endif
			//Endif

			aLinha 	 := {}

			cItem	:= Soma1(cItem)
			
			//If cItem > "99"
				//cItem     := cNextItem
				//cNextItem := Soma1( cNextItem )
			//EndIf
 
			cItem	:= PadL( AllTrim( cItem ) , TamSX3( "C6_ITEM"    )[1],"0")
			
			Aadd(aLinha,{'C6_ITEM'	 , cItem	  ,Nil})
			Aadd(aLinha,{'C6_PRODUTO',(cAliDoc)->ZA0_COD  ,Nil})
			Aadd(aLinha,{'C6_QTDVEN' ,(cAliDoc)->ZA0_QUANT,Nil})
			//Aadd(aLinha,{'C6_PRCVEN' ,nCustoM			  ,Nil})
			//Aadd(aLinha,{'C6_PRUNIT' ,nCustoM             ,Nil})
			Aadd(aLinha,{'C6_PRCVEN' ,(cAliDoc)->ZA0_CUSTO1	  ,Nil})
			Aadd(aLinha,{'C6_PRUNIT' ,(cAliDoc)->ZA0_CUSTO1   ,Nil})

		    Aadd(aLinha,{'C6_VALOR'	 ,Round((cAliDoc)->ZA0_QUANT * (cAliDoc)->ZA0_CUSTO1 ,2),Nil})


			Aadd(aLinha,{'C6_OPER'	 ,aMv_par[13],Nil})
			Aadd(aLinha,{'C6_TES'	 ,aMv_par[06],Nil})
			Aadd(aLinha,{'C6_CC'	 ,(cAliDoc)->ZA0_CC,Nil})
			Aadd(aItens,aLinha)
			//nItem ++

			If ! AllTrim(cMenNota) $ (cAliDoc)->ZA0_DOCB7	
				cMenNota += AllTrim((cAliDoc)->ZA0_DOCB7) + "\"
			EndIf

			(cAliDoc)->(DbSkip())
		EndDo

		Aadd( aCabec,{"C5_MENNOTA",cMenNota,Nil})

		Begin Transaction

			lMsErroAuto	:= .F.

			MsExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItens,3)

			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
			Else
				lPeds := .T.
			EndIf

		End Transaction

		(cAliDoc)->(DbCloseArea())
	Endif

	//Altera o Status somente se houver gerado a Pre Nota ou Pedido de Venda.
	If lDocs .Or. lPeds
		AjtStatus(aMv_Par,lDocs,lPeds,cNumPed,cNumNF,cSerNF)

		cMenFim := 'Documento(s) gerado(s) com sucesso !!!' + CRLF
		cMenFim += '----------------------------------------' + CRLF
		If lDocs
			cMenFim += 'Pré-Nota de Entrada: ' + cNumNF + CRLF
		EndIf
		If lPeds
			cMenFim += 'Pedido de Venda     : ' + cNumPed
		EndIf

		Aviso('Documentos Fiscais de Inventário', cMenFim, {'Ok'}, 1)
	Else
		MsgAlert("Não existem movimentos de inventário pendente para geração dos documentos fiscais.","Documentos Fiscais de Inventário")
	EndIf

Return

/*/{Protheus.doc} ConsZA0
Função para consultar os movimentos gerados no processamento do inventário.
@author FSW - DWC Consult
@since 09/02/2019
@version 1.0
@param cTipo, characters, descricao
@param aMv_Par, array, descricao
@type function
/*/
Static Function ConsZA0(cTipo,aMv_Par)
	Local cAliCon := GetNextAlias()
	Local nTotReg := 0
	Local aResult := {}

	If Select(cAliCon) > 0
		(cAliCon)->(DbCloseArea())
	EndIf
	BeginSql Alias cAliCon
		SELECT * FROM %Table:ZA0% Z
		WHERE
				Z.%NotDel%
			AND Z.ZA0_FILIAL = %xFilial:ZA0%
			AND Z.ZA0_DOCB7  BETWEEN %Exp:aMv_Par[01]% AND %Exp:aMv_Par[02]%
			AND Z.ZA0_EMISSA BETWEEN %Exp:DToS(aMv_Par[03])% AND %Exp:DToS(aMv_Par[04])%
			AND Z.ZA0_STATUS = '1'
			AND Z.ZA0_TM = %Exp:cTipo%
		ORDER BY
			ZA0_FILIAL,ZA0_TM,ZA0_COD
	EndSql
	Count To nTotReg

	aResult := {cAliCon,nTotReg}

Return( aResult )

/*/{Protheus.doc} AjtStatus
Função para atualizar o Status dos Movimentos Processados.
@author FSW - DWC Consult
@since 09/02/2019
@version 1.0
@param aMv_Par, array, descricao
@param lDocs, logical, descricao
@param lPeds, logical, descricao
@param cPedido, characters, descricao
@param cNFiscal, characters, descricao
@param cSerie, characters, descricao
@type function
/*/
Static Function AjtStatus(aMv_Par,lDocs,lPeds,cPedido,cNFiscal,cSerie)
	Local cUpdt	:= ""
	Local cErro	:= ""
	Local Up	:= 0

	ProcRegua(0)

	IncProc('Finalizando Processamento')

	For Up := 1 To 2
		cUpdt := "UPDATE " + RetSqlName("ZA0") + " SET "
		cUpdt += "ZA0_STATUS ='2' "
		cUpdt += ",ZA0_DATA = '" + Iif(Empty(aMv_Par[09]),DToS(dDataBase),DTos(aMv_Par[09])) + "' "
		If lPeds .And. Up == 1
			cUpdt += ",ZA0_PEDIDO = '" + cPedido + "' "
		EndIf
		If lDocs .And. Up == 2
			cUpdt += ",ZA0_NOTA = '" + cNFiscal + "' "
			cUpdt += ",ZA0_SERIE = '" + cSerie + "' "
		EndIf
		cUpdt += "WHERE "
		cUpdt += "D_E_L_E_T_ =' ' "
		If lDocs .And. Up == 2
			cUpdt += "AND ZA0_TM = 'E' "
		ElseIf lPeds .And. Up == 1
			cUpdt += "AND ZA0_TM IN ('S') "
		EndIf
		cUpdt += "AND ZA0_EMISSA BETWEEN '" + DToS(aMv_Par[03]) + "' AND '" + DToS(aMv_Par[04]) + "' "
		cUpdt += "AND ZA0_DOCB7 BETWEEN '" + aMv_Par[01] + "' AND '" + aMv_Par[02] + "' "

		//MemoWrite("prcdocint_"+StrZero(Up,1)+".txt",cUpdt)

		If TCSQLExec (cUpdt) < 0
			cErro := TCSQLError()
			//MemoWrite("prcdocint_"+StrZero(Up,1)+"_erro.txt",cUpdt)
		EndIf

	Next Up

Return

/*/{Protheus.doc} ProtPerg
Função para controlar a execução de multi-usuários.
@author FSW - DWC Consult
@since 09/02/2019
@version 1.0
@param aMv_Par, array, descricao
@type function
/*/
Static Function ProtPerg(aMv_Par)
	Pergunte("INVZA0",.T.)
	Aadd(aMv_Par,MV_PAR01)	//Documento de Inventário de?
	Aadd(aMv_Par,MV_PAR02)	//Docuemnto de Inventário ate?
	Aadd(aMv_Par,MV_PAR03)	//Data de Inventário de?
	Aadd(aMv_Par,MV_PAR04)	//Data de Inventário ate?
	Aadd(aMv_Par,MV_PAR05)	//Cond Pagamento?
	Aadd(aMv_Par,MV_PAR06)	//TES para Pedido de Venda?
	Aadd(aMv_Par,MV_PAR07)	//Fornecedor para Pré-Nota?
	Aadd(aMv_Par,MV_PAR08)	//Loja Fornecedor p/ Pré-Nota?
	Aadd(aMv_Par,MV_PAR09)	//Data para Emissão da Pré-Nota?
	Aadd(aMv_Par,MV_PAR10)	//Cliente para Pedido de Venda?
	Aadd(aMv_Par,MV_PAR11)	//Loja Cliente p/ Ped Venda?
	Aadd(aMv_Par,MV_PAR12)	//Natureza Fin. p/ Ped Venda?
	Aadd(aMv_Par,MV_PAR13)	//Natureza Fin. p/ Ped Venda?
Return
