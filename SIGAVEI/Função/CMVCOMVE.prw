#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'
#include "totvs.ch"
#INCLUDE 'TOPCONN.CH'
#include "tbiconn.ch"

/*==========================================================================================
Programa.:              CMVCOMVE
Autor....:              Joni Lima
Data.....:              Fev/2019
Descricao / Objetivo:   Criação dos Veiculos/nota no Modulo SIGAVEI
Solicitante:            Cliente
Uso......:              CAOA
==========================================================================================*/
user function CMVCOMVE(cxFil,cDoc,cSerie,cFornec,cLoja)

	Local cBkpFunName := ""
	Local cChvSF1	  := ""
	Local cChaInt	  := ""
	Local nBkpModulo  := 0
	Local lCont		  := .T.
	Local aDados      := {}
	Local aCab        := {}
	Local axItem      := {}
	Local aItens      := {}
	
	Local aArea	      := GetArea()
	Local aAreaSF1    := SF1->(GetArea())
	Local aAreaSD1    := SD1->(GetArea())
	Local cNextAlias  := xQryDVeNF(cxFil,cDoc,cSerie,cFornec,cLoja)
	local cNatNf	  := AllTrim( superGetMv( "CMV_VE1NAT"	, , "2104" ) )	// Natureza para Nota fiscal SIGAVEI
	
	Private lMsHelpAuto := .t.
	Private lMsErroAuto := .f.
	
	
	
	//u_TMATA265()
	If (cNextAlias)->(!Eof())

		//Begin Transaction

			//Endereçamento Produtos
			xEndProd()

			dbSelectArea("VV1")
			VV1->(dbSetOrder(2))//VV1_FILIAL+VV1_CHASSI

			//Inclusão dos Veiculos
			While (cNextAlias)->(!Eof())

				If !(VV1->(dbSeek(xFilial("VV1",(cNextAlias)->D1_FILIAL) + ALLTRIM((cNextAlias)->D1_CHASSI) )))

					zIncVCM(cNextAlias)	// valter 20/02/2021

					aDados := {}

					aAdd(aDados,{"VV1_FILIAL",	xFilial("VV1",(cNextAlias)->D1_FILIAL) })
					aAdd(aDados,{"VV1_CODMAR",	(cNextAlias)->VV2_CODMAR})
					aAdd(aDados,{"VV1_CHASSI",	(cNextAlias)->D1_CHASSI })
					aAdd(aDados,{"VV1_MODVEI",	(cNextAlias)->VV2_MODVEI})
					aAdd(aDados,{"VV1_SEGMOD",	(cNextAlias)->VV2_SEGMOD})
					aAdd(aDados,{"VV1_FABMOD",	Alltrim((cNextAlias)->WN_ANOFAB) + Alltrim((cNextAlias)->WN_ANOMOD)	})
					aAdd(aDados,{"VV1_CORVEI",	(cNextAlias)->VV2_COREXT})

					If !Empty(Alltrim((cNextAlias)->VV2_COMVEI))
						aAdd(aDados,{"VV1_COMVEI",	(cNextAlias)->VV2_COMVEI})
					EndIf

					aAdd(aDados,{"VV1_CODORI",	"0"				        })
					aAdd(aDados,{"VV1_PROVEI",	(cNextAlias)->B1_ORIGEM })
					aAdd(aDados,{"VV1_ESTVEI",	"0"				        })
					aAdd(aDados,{"VV1_TIPVEI",	"1"				        })
					//aAdd(aDados,{"VV1_PROATU",	(cNextAlias)->A2_COD    })
					//aAdd(aDados,{"VV1_LJPATU",	(cNextAlias)->A2_LOJA   })
					//aAdd(aDados,{"VV1_CAMBIO",	(cNextAlias)->WV_XCAMBIO})
					If !Empty(Alltrim((cNextAlias)->VV2_CILMOT))
						aAdd(aDados,{"VV1_CILMOT",	(cNextAlias)->VV2_CILMOT})
					EndIf

					aAdd(aDados,{"VV1_NUMMOT",	(cNextAlias)->WV_XMOTOR})

					If !Empty(Alltrim((cNextAlias)->VV2_POTMOT))
						aAdd(aDados,{"VV1_POTMOT",	(cNextAlias)->VV2_POTMOT})
					EndIf

					If !Empty(Alltrim((cNextAlias)->VV2_DISEIX))
						aAdd(aDados,{"VV1_DISEIX",	(cNextAlias)->VV2_DISEIX})
					EndIf

					If !Empty(Alltrim((cNextAlias)->B1_GRTRIB))
						aAdd(aDados,{"VV1_GRTRIB",	(cNextAlias)->B1_GRTRIB })
					EndIf

					aAdd(aDados,{"VV1_LOCPAD",	(cNextAlias)->B1_LOCPAD })

					If !Empty(Alltrim((cNextAlias)->B1_POSIPI))
						aAdd(aDados,{"VV1_POSIPI",	(cNextAlias)->B1_POSIPI })
					EndIf
					If !Empty(Alltrim((cNextAlias)->VV2_CM3))
						aAdd(aDados,{"VV1_CM3"	 ,	(cNextAlias)->VV2_CM3   })
					EndIf
					If !Empty(Alltrim((cNextAlias)->B1_PESO))
						aAdd(aDados,{"VV1_PESLIQ",	(cNextAlias)->B1_PESO	})
					EndIf

					aAdd(aDados,{"VV1_SERMOT",	RIGHT(Alltrim((cNextAlias)->D1_CHASSI),8)	})

					// valter carvalho 29/03/2021
					//Campos solicitados de inclusão pelo Wagson
					
					Aadd(aDados,{"VV1_POSIPI",	(cNextAlias)->B1_POSIPI		})
					Aadd(aDados,{"VV1_CAPTRA",	(cNextAlias)->VV2_CAPTRA	})
					Aadd(aDados,{"VV1_PESBRU",	(cNextAlias)->VV2_PESBRU	})
					Aadd(aDados,{"VV1_QTDCIL",	(cNextAlias)->VV2_QTDCIL	})
					Aadd(aDados,{"VV1_CILMOT",	(cNextAlias)->VV2_CILMOT	})
					Aadd(aDados,{"VV1_QTDEIX",	(cNextAlias)->VV2_QTDEIX	})
					Aadd(aDados,{"VV1_POTMOT",	(cNextAlias)->VV2_POTMOT	})
					Aadd(aDados,{"VV1_DISEIX",	(cNextAlias)->VV2_DISEIX	})
					Aadd(aDados,{"VV1_PORTAS",	(cNextAlias)->VV2_PORTAS	})

					lCont := ImptVeic(aDados)

					cChaInt := VV1->VV1_CHAINT

				EndIf

				(cNextAlias)->(dbSkip())
			EndDo

			(cNextAlias)->(dbGoTop())
			
			If lCont
				//Inclusão da NF no SIGAVEI
				While (cNextAlias)->(!Eof())

					If Empty(aCab)
						cChvSF1 := (cNextAlias)->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO)

						aAdd(aCab,{"VVF_CLIFOR" , "F"               				,Nil})
						aAdd(aCab,{"VVF_FORPRO" , "0"               				,Nil})
						aAdd(aCab,{"VVF_OPEMOV" , "0"               				,Nil})
						aAdd(aCab,{"VVF_DATMOV" , Stod((cNextAlias)->F1_DTDIGIT) 	,Nil})
						aAdd(aCab,{"VVF_DATEMI" , Stod((cNextAlias)->F1_EMISSAO) 	,Nil})
						aAdd(aCab,{"VVF_CODFOR" , (cNextAlias)->F1_FORNECE   		,Nil})
						aAdd(aCab,{"VVF_LOJA"   , (cNextAlias)->F1_LOJA       		,Nil})
						aAdd(aCab,{"VVF_FORPAG" , (cNextAlias)->F1_COND      		,Nil})
						aAdd(aCab,{"VVF_ESPECI" , (cNextAlias)->F1_ESPECIE   		,Nil})
						aAdd(aCab,{"VVF_NUMNFI" , (cNextAlias)->F1_DOC        		,Nil})
						aAdd(aCab,{"VVF_SERNFI" , (cNextAlias)->F1_SERIE      		,Nil})
						aAdd(aCab,{"VVF_NATURE"	, Alltrim(cNatNf)					,Nil})
						aAdd(aCab,{"VVF_CHVNFE" , (cNextAlias)->F1_CHVNFE    		,Nil})
						aAdd(aCab,{"VVF_RECSF1"	, (cNextAlias)->RECSF1	    		,Nil})

					EndIf

					axItem:= {}

					aAdd(axItem,{"VVG_FILIAL" , (cNextAlias)->D1_FILIAL   , nil})
					aAdd(axItem,{"VVG_CHASSI" , (cNextAlias)->D1_CHASSI   , nil})
					aAdd(axItem,{"VVG_CODTES" , (cNextAlias)->D1_TES      , nil})
					aAdd(axItem,{"VVG_ESTVEI" , "0"						  , nil})
					aAdd(axItem,{"VVG_LOCPAD" , (cNextAlias)->D1_LOCAL    , nil})
					aAdd(axItem,{"VVG_SITTRIB", (cNextAlias)->D1_CLASFIS  , nil})
					aAdd(axItem,{"VVG_VALUNI" , (cNextAlias)->D1_VUNIT    , nil})
					aAdd(axItem,{"VVG_VBAIPI" , (cNextAlias)->D1_BASEIPI  , nil})
					aAdd(axItem,{"VVG_VBAICM" , (cNextAlias)->D1_BASEICM  , nil})
					aAdd(axItem,{"VVG_ICMCOM" , (cNextAlias)->D1_VALICM   , nil})
					aAdd(axItem,{"VVG_VCNVEI" , (cNextAlias)->D1_TOTAL    , nil})
					aAdd(axItem,{"VVG_NUMPED" , (cNextAlias)->D1_PEDIDO   , ".T."})
					aAdd(axItem,{"VVG_ITPED"  , (cNextAlias)->D1_ITEMPC   , ".T."})

					AADD(aItens,axItem)

					(cNextAlias)->(dbSkip())
				EndDo

				cBkpFunName := FunName()
				nBkpModulo  := nModulo
				SetFunName('VEIXA001')
				nModulo := 11

				dbSelectArea("SF1")
				SF1->(dbSetOrder(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

				lMsHelpAuto := .T.
				lMsErroAuto := .F.

				aCols := {}

				If SF1->(dbSeek(cChvSF1))
					MSExecAuto(	{ |a,b,c,d,e,f,g,h,i| VEIXX000(a,b,c,d,e,f,g,h,i) },aCab,aItens,{},3,"0",,.f.,,"3")

					SetFunName(cBkpFunName)
					nModulo := nBkpModulo

					If lMsErroAuto
						
						MostraErro()
						DisarmTransaction()
						MsgInfo("Erro ao Cadastrar o Veiculo, Por Favor corrigir e realizar o processo novamente.")
					
					Else
					
						MsgInfo("Veiculo Cadastrado com Sucesso ( SigaVEI ).")
						RecLock("VB0",.T.)
							VB0->VB0_FILIAL := xFilial("VB0")
							VB0->VB0_CHAINT := cChaInt
							VB0->VB0_DATBLO := dDataBase
							VB0->VB0_HORBLO := VAL(LEFT(TIME(),2)+SUBSTR(TIME(),4,2))
							VB0->VB0_USUBLO := Alltrim(__CUSERID)
							VB0->VB0_MOTBLO := "IMPORTACAO"
							VB0->VB0_DATVAL := CTOD("01/12/2050")
							VB0->VB0_HORVAL := 2359
						VB0->(MsUnlock())
					EndIf

				EndIf

			EndIf

		//End Transaction

	EndIf

	(cNextAlias)->(dbCloseArea())

	RestArea(aAreaSF1)
	RestArea(aAreaSD1)
	RestArea(aArea)

return

/*
	Realiza Query para extração dos dados.
*/
Static Function xQryDVeNF(cxFil,cDoc,cSerie,cFornec,cLoja)

	Local cNextAlias := GetNextAlias()

	If Select(cNextAlias) > 0
		(cNextAlias)->(DbClosearea())
	Endif

	BeginSql Alias cNextAlias

		SELECT
			SB1.B1_GRTRIB ,
			SB1.B1_LOCPAD ,
			SB1.B1_ORIGEM ,
			SB1.B1_PESO   ,
			SB1.B1_POSIPI ,
			SD1.D1_BASEICM,
			SD1.D1_BASEIPI,
			SD1.D1_CHASSI ,
			SD1.D1_CLASFIS,
			SD1.D1_FILIAL ,
			SD1.D1_COD    ,
			SD1.D1_ITEM   ,
			SD1.D1_FILIAL ,
			SD1.D1_ITEMPC ,
			SD1.D1_LOCAL  ,
			SD1.D1_PEDIDO ,
			SD1.D1_TES    ,
			SD1.D1_TOTAL  ,
			SD1.D1_VALICM ,
			SD1.D1_VUNIT  ,
			SF1.F1_BASEICM,
			SF1.F1_COND   ,
			SF1.F1_DOC    ,
			SF1.F1_DTDIGIT,
			SF1.F1_EMISSAO,
			SF1.F1_ESPECIE,
			SF1.F1_FILIAL ,
			SF1.F1_FORNECE,
			SF1.F1_LOJA   ,
			SF1.F1_SERIE  ,
			SF1.F1_VALBRUT,
			SF1.F1_VALICM ,
			SF1.F1_VALMERC,
			SF1.F1_CHVNFE ,
			SF1.F1_TIPO   ,
			SF1.R_E_C_N_O_ RECSF1,
			SWN.WN_ANOFAB ,
			SWN.WN_ANOMOD ,
			SWV.WV_XMOTOR ,
			VV2.VV2_CODMAR,
			VV2.VV2_MODVEI,
			VV2.VV2_COREXT,
			VV2.VV2_COMVEI,
			VV2.VV2_CILMOT,
			VV2.VV2_POTMOT,
			VV2.VV2_SEGMOD,
			VV2.VV2_CM3   ,
			VV2.VV2_PESBRU,
			VV2.VV2_PESLIQ,
			VV2.VV2_CAPTRA,
			VV2.VV2_QTDCIL,
			VV2.VV2_CILMOT,
			VV2.VV2_QTDEIX,
			VV2.VV2_DISEIX,
			VV2.VV2_PORTAS,
			VV2.VV2_TIPVEI,
			VV2.VV2_ESPVEI,
			VV2.VV2_MODFAB,
			VV2.VV2_QTDPAS

		FROM
		%Table:SF1% SF1

		INNER JOIN %Table:SD1% SD1
			 ON SD1.D1_FILIAL  = SF1.F1_FILIAL
			AND SD1.D1_DOC     = SF1.F1_DOC
			AND SD1.D1_SERIE   = SF1.F1_SERIE
			AND SD1.D1_FORNECE = SF1.F1_FORNECE
			AND SD1.D1_LOJA    = SF1.F1_LOJA
		
		INNER JOIN %Table:SB1% SB1
			 ON SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD    = SD1.D1_COD
		
		INNER JOIN %Table:SWN% SWN
			 ON SWN.WN_FILIAL  = SF1.F1_FILIAL
			AND SWN.WN_DOC     = SF1.F1_DOC
			AND SWN.WN_SERIE   = SF1.F1_SERIE
			AND SWN.WN_FORNECE = SF1.F1_FORNECE
			AND SWN.WN_LOJA    = SF1.F1_LOJA
		
		INNER JOIN %Table:SWV% SWV
			 ON SWV.WV_FILIAL = SWN.WN_FILIAL
			AND SWV.WV_HAWB   = SWN.WN_HAWB
			AND SWV.WV_XVIN   = SWN.WN_XVIN
		
		INNER JOIN %Table:VV2% VV2
			 ON VV2.VV2_FILIAL = %xFilial:VV2%
			AND VV2.VV2_PRODUT = SWV.WV_COD_I
		
		WHERE 1 = 1
			AND SF1.%NotDel%
			AND SD1.%NotDel%
			AND SB1.%NotDel%
			AND SWN.%NotDel%
			AND SWV.%NotDel%
			AND VV2.%NotDel%
			AND SF1.F1_FILIAL  = %Exp:cxFil%
			AND SF1.F1_DOC     = %Exp:cDoc%
			AND SF1.F1_SERIE   = %Exp:cSerie%
			AND SF1.F1_FORNECE = %Exp:cFornec%
			AND SF1.F1_LOJA    = %Exp:cLoja%
			AND SD1.D1_CHASSI <> ' '
	EndSql

Return cNextAlias

/*
Realiza o Cadastro do Veiculo
*/
Static Function ImptVeic(aCpoCAB)
	Local  oModel, oAux, oStruct
	Local  nI        := 0
	Local  nPos      := 0
	Local  lRet      := .T.
	Local  aAux	     := {}
	Local  cModelVV1	  := 'MODEL_VV1'

	oModel := FWLoadModel( 'VEIA070' )
	oModel:SetOperation( MODEL_OPERATION_INSERT )
	lRet := oModel:Activate()

	If lRet
		oAux    := oModel:GetModel( cModelVV1 )
		oStruct := oAux:GetStruct()
		aAux	:= oStruct:GetFields()
		
		For nI := 1 To Len( aCpoCAB )
			
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoCAB[nI][1] ) } ) ) > 0
				
				oModel:SetValue( cModelVV1, aCpoCAB[nI][1], aCpoCAB[nI][2] )
				
				If !oModel:SetValue( cModelVV1, aCpoCAB[nI][1], aCpoCAB[nI][2] )
					lRet    := .F.
					Exit
				EndIf

			EndIf

		Next nI

	EndIf

	If lRet
		If (lRet := oModel:VldData())
			lRet := oModel:CommitData()
		EndIf
	EndIf

	If !lRet

		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro   := oModel:GetErrorMessage()
																							// A estrutura do vetor com erro é:
		AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )	//  [1] Id do formulário de origem
		AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )	//  [2] Id do campo de origem
		AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )	//  [3] Id do formulário de erro
		AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )	//  [4] Id do campo de erro
		AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )	//  [5] Id do erro
		AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )	//  [6] mensagem do erro
		AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )	//  [7] mensagem da solução
		AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )	//  [8] Valor atribuido
		AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )	//  [9] Valor anterior

		MostraErro()
		DisarmTransaction()
	EndIf

	// Desativamos o Model
	oModel:DeActivate()

Return lRet

Static Function xEndProd()

	Local cAlias    := ""
	Local aCabSDA   := {}
	Local aItSDB    := {}
	Local aItensSDB := {}
	Local nCount    := 0
	
	Local aArea 	:= GetArea()
	local aAreaSF1	:= SF1->(GetArea())
	Local aAreaSDA	:= SDA->(GetArea())
	Local aAreaSDB	:= SDB->(GetArea())

	local cLocal	  := allTrim( superGetMv( "CMV_VE1LOC", ,"VEICULO NOVO") )	// Natureza para Nota fiscal SIGAVEI
	///Local cBkpFunName := Funname()
	
	Private lMsErroAuto := .F.
	
	zSX3Valid_Ajusta("DB_LOCALIZ")
	
	
	cLocal := "VEICULO NOVO   " //padr( cLocal , TamSx3("DB_LOCALIZ")[1] ," " )
	cAlias := getNextAlias()
	
	BeginSql Alias cAlias
		SELECT
			SD1.D1_COD,
			SD1.D1_CHASSI ,
			SDA.DA_NUMSEQ ,
			SDA.DA_LOCAL  ,
			SD1.D1_QUANT  ,
			SDA.DA_SALDO
		FROM %TABLE:SD1% SD1
	
		INNER JOIN %TABLE:SDA% SDA
			 ON SDA.DA_FILIAL = SD1.D1_FILIAL
			AND SDA.DA_DOC    = SD1.D1_DOC
			AND SDA.DA_SERIE  = SD1.D1_SERIE
			AND SDA.DA_CLIFOR = SD1.D1_FORNECE
			AND SDA.DA_LOJA   = SD1.D1_LOJA
			AND SDA.DA_LOCAL  = SD1.D1_LOCAL
			AND SDA.DA_ORIGEM = %EXP:"SD1"%
			AND SDA.DA_SALDO  > %EXP:0%
			AND SDA.%NOTDEL%

		WHERE
				SD1.D1_FILIAL  = %EXP:SF1->F1_FILIAL%
			AND SD1.D1_DOC     = %EXP:SF1->F1_DOC%
			AND SD1.D1_SERIE   = %EXP:SF1->F1_SERIE%
			AND SD1.D1_FORNECE = %EXP:SF1->F1_FORNECE%
			AND SD1.D1_LOJA    = %EXP:SF1->F1_LOJA%
			AND SD1.%NOTDEL%
	EndSQl

	(cAlias)->(dbEval( { || nCount++ } ))
	(cAlias)->(dbGoTop())

	if nCount == 0
		alert("Sem itens disponíveis para o endereçamento!")
	else
		dbSelectArea("SDA")
		SDA->(dbSetOrder(1))
		
		//dbSelectArea('SBE')
		//SBE->(DbSetOrder(9))
		//SBE->(DbSeek(xFilial('SBE')+cLocal))
		
		ProcRegua( nCount )
		processMessage()
		
		if l103Auto
			_SetNamedPrvt( "DB_LOCALIZ" ,  , "MATA103" )
			M->DB_LOCALIZ := cLocal
			Pergunte("MTA265",.F.)
		else
			Pergunte("MTA265",.T.)
		EndIf
		
//		_SetNamedPrvt( "oDMSBrwStru" ,  , "U_ZVEIR002" )
		While !(cAlias)->(EOF())
			incProc("Produto: " + allTrim((cAlias)->D1_COD) + " - Sequencial:"  + (cAlias)->DA_NUMSEQ )
			processMessage()
		
			SDA->(dbGoTop()) // posiciona o cabeçalho
			if SDA->(dbSeek( xfilial("SDA") + (cAlias)->D1_COD + (cAlias)->DA_LOCAL + (cAlias)->DA_NUMSEQ + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ))
				if SDA->DA_SALDO > 0
					lMsErroAuto := .F.
					RegToMemory("SDA", .F. , .T. , .T. )
					aCabSDA := {}
					aAdd( aCabSDA, {"DA_PRODUTO" 	,SDA->DA_PRODUTO	, Nil} )
					aAdd( aCabSDA, {"DA_LOCAL" 	    ,SDA->DA_LOCAL 		, Nil} )
					aAdd( aCabSDA, {"DA_NUMSEQ" 	,SDA->DA_NUMSEQ 	, Nil} )

					aItSDB := {}
					aAdd( aItSDB, {"DB_ITEM" 	, "0001" 				, Nil} )
					aAdd( aItSDB, {"DB_ESTORNO"	, " " 					, Nil} )
					aAdd( aItSDB, {"DB_LOCALIZ"	, cLocal				, Nil} )
					aAdd( aItSDB, {"DB_QUANT" 	, SDA->DA_SALDO 		, Nil} )
					aAdd( aItSDB, {"DB_DATA" 	, dDataBase 			, Nil} )
					aAdd( aItSDB, {"DB_NUMSERI" , (cAlias)->D1_CHASSI 	, Nil} )

					aItensSDB := {}
					aadd( aItensSDB, aitSDB )
					
					//MATA265( aCabSDA, aItensSDB, 3)
					MSExecAuto({ |x,y,z,| MATA265( x, y,z) } , aCabSDA , aItensSDB, 3)
				  	If lMsErroAuto
        				MostraErro()
    			    Endif
				endif
			endif

			(cAlias)->(dbSkip())
		enddo
	endif
	(cAlias)->(dbCloseArea())
	
	//SetFunName(cBkpFunName)
	RestArea(aAreaSDB)
	RestArea(aAreaSDA)
	RestArea(aAreaSF1)
	RestArea(aArea)

Return

/*=====================================================================================
Programa.:              zIncVCM
Autor....:              CAOA - Valter Carvalho
Data.....:              20/03/2021
Descricao / Objetivo:   insere os dados na tabela VCM para poder gravar os campos da VV1
Solicitante:
Uso......:
===================================================================================== */
Static Function zIncVCM(cNextAlias)
	DbSelectArea("VCM")
	VCM->(DbSetOrder(1))

	If !(VCM->(DbSeek( xFilial("VCM") + (cNextAlias)->VV2_TIPVEI + Str((cNextAlias)->VV2_POTMOT, 6, 1)))) //== .F. // VCM_FILIAL+VCM_TIPVEI+STR(VCM_POTMOT,6,1)

		RecLock("VCM", .T.)
		VCM->VCM_FILIAL := Xfilial("VCM")

		VCM->VCM_TIPVEI := (cNextAlias)->VV2_TIPVEI
		VCM->VCM_POTMOT := (cNextAlias)->VV2_POTMOT
		VCM->VCM_POSIPI := " "

		VCM->(MsUnlock())
	EndIf

	VCM->(DbCloseArea())
Return


/*=====================================================================================
Programa.:              zIncVCM
Autor....:              CAOA - Valter Carvalho
Data.....:              20/03/2021
Descricao / Objetivo:   insere os dados na tabela VCM para poder gravar os campos da VV1
Solicitante:
Uso......:
===================================================================================== */
Static Function zSX3Valid_Ajusta(cCampo)
Local aArea    := GetArea()
Local aSX3Area := GetArea('SX3')

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))

	If SX3->(DbSeek(cCampo))
		IF "M->"+cCampo $ SX3->X3_VALID
			RecLock("SX3", .F.)
				SX3->X3_VALID := 'Vazio() .Or.  BloqEndWMS()    '
			SX3->(MSUNLOCK())
		EndIf
	EndIf

	RestArea(aSX3Area)
	RestArea(aArea)
Return
