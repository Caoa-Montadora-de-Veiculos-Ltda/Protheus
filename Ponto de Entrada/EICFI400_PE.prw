#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHAR(13) + CHAR(10)
user function EICFI400()
	Local cAlias    := ""
	Local cmd       := ""
	Local aArea		:= GetArea()
	Local aAreaSW2	:= SW2->(GetArea())
	Local aAreaZZ8	:= ZZ8->(GetArea())
	Local aAreaSW6	:= SW6->(GetArea())

	Local cParam	:= If(Type("ParamIxb") = "A",ParamIxb[1],If(Type("ParamIxb") = "C",ParamIxb,""))
	Local lRet		:= .T.

	Local nPosTipo	:= 0
	Local nPosHist	:= 0

	Conout("EICFI400() " + cParam )

	/* =====================================================================================
	Programa.:              EICFI400 - EXECUTA_INTEGRACAO
	Autor....:              CAOA - Valter Carvalho
	Data.....:              05/11/2020
	Descricao / Objetivo:   Evitar ser exibido o display de inclusão do contas a pagar 
							no recebimento do arq despesas se SYB->YB_XINTFIN
	===================================================================================== */
 	If cParam == "EXECUTA_INTEGRACAO" .AND. FunName() = "EICEI100"
		If SYB->YB_XINTFIN = "N"
			lSair := .T.
			//ApMsgInfo( "Despesa " + SYB->YB_DESP + " - " + SYB->YB_DESCR +  CRLF + " Não deve gerar financeiro, conforme parametrização no cadastro de despesas, no campo: " + GetSx3Cache("YB_XINTFIN", "X3_TITULO"), "EICFI400_MVC" )	
		Else
			lSair := .F.
		EndIf
	EndIf

	/* =====================================================================================
	Programa.:              EICFI400 - FI400INCTIT
	Autor....:              CAOA - Valter Carvalho
	Data.....:              05/11/2020
	Descricao / Objetivo:   Efetua o preenchimento dos titulos das despesas do embarque
	===================================================================================== */
 	If cParam == "FI400INCTIT" .AND. FunName() = "EICEI100"
		M->E2_PARCELA  := SYB->YB_XFINPAR
		M->E2_TIPO	:= SYB->YB_XFINTIP
		M->E2_NATUREZ	:= SYB->YB_XFINAT
		M->E2_FORNECE	:= SYB->YB_XFINFOR
		M->E2_LOJA 	:= SYB->YB_XFINLOJ
		M->E2_VENCTO	:= Ctod(Substr(INT_DSPDE->NDDDPAGTO, 1, 2) + "/" + Substr(INT_DSPDE->NDDDPAGTO, 3, 2) + "/" + Substr(INT_DSPDE->NDDDPAGTO, 5, 4))
		M->E2_VENCREAL := Ctod(Substr(INT_DSPDE->NDDDPAGTO, 1, 2) + "/" + Substr(INT_DSPDE->NDDDPAGTO, 3, 2) + "/" + Substr(INT_DSPDE->NDDDPAGTO, 5, 4))

		If Empty(SYB->YB_XFINFOR) = .F. .and. Empty(SYB->YB_XFINLOJ) = .F.
			cAlias := GetNextAlias()

			cmd := ""
			cmd += " SELECT NVL(MAX(E2_NUM), '000000000') as NUMERO
			cmd += " FROM " + RetSqlName("SE2")
			cmd += " WHERE "  
			cmd += "     D_E_L_E_T_ = ' ' "  
			cmd += " AND E2_FILIAL  = '" + Xfilial("SE2")  + "' "  
			cmd += " AND E2_FORNECE = '" + SYB->YB_XFINFOR + "' "
			cmd += " AND E2_LOJA    = '" + SYB->YB_XFINLOJ + "'
			TcQuery cmd new alias (cAlias) 

			cmd := Soma1(Alltrim((cAlias)->NUMERO))

			(cAlias)->(DbCloseArea())

			M->E2_NUMERO = Soma1(cmd)
		EndIf
	EndIf
 

	If cParam == "FI400EDIT_ATIT"

		If IsInCallStack("EICDI501") .Or. IsInCallStack("EICDI502") 

			nPosTipo := AScan(aTit, {|x| AllTrim(x[1]) == "E2_TIPO"})
			nPosHist := AScan(aTit, {|x| AllTrim(x[1]) == "E2_HIST"})

			If nPosTipo > 0 .And. nPosHist > 0
				If Alltrim(aTit[nPosTipo][2]) $ "INV" .and. ( "FRETE" $ Alltrim(aTit[nPosHist][2]) .Or. "SEGURO" $ Alltrim(aTit[nPosHist][2])) 
					dbSelectArea("ZZ8")
					ZZ8->(dbSetOrder(1))//ZZ8_FILIAL+ZZ8_CODIGO
					If ZZ8->(dbSeek(xFilial("ZZ8") + SW6->W6_XTIPIMP))
						AADD(aTit,{"E2_CCUSTO" ,ZZ8->ZZ8_CUSTO    		,Nil})
						AADD(aTit,{"E2_CLVL"   ,ZZ8->ZZ8_XCLVL    		,Nil})
						AADD(aTit,{"E2_ITEMCTA",ZZ8->ZZ8_XITEMC   		,Nil})
						AADD(aTit,{"E2_ZPROFOR","EMB: "+SW6->W6_HAWB	,Nil})
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If cParam == "DEP_GRAVACAO_TIT"

		nPosTipo := AScan(aTit, {|x| AllTrim(x[1]) == "E2_TIPO"})

		If nPosTipo > 0
			If Alltrim(aTit[nPosTipo][2]) $ "INV" .and. IsInCallStack("di500_grava")
				dbSelectArea("ZZ8")
				ZZ8->(dbSetOrder(1))//ZZ8_FILIAL+ZZ8_CODIGO
				If ZZ8->(dbSeek(xFilial("ZZ8") + SW6->W6_XTIPIMP))
					AADD(aTit,{"E2_CCUSTO" ,ZZ8->ZZ8_CUSTO    ,Nil})
					AADD(aTit,{"E2_CLVL"   ,ZZ8->ZZ8_XCLVL    ,Nil})
					AADD(aTit,{"E2_ITEMCTA",ZZ8->ZZ8_XITEMC   ,Nil})
					AADD(aTit,{"E2_ZPROFOR","EMB: "+SW6->W6_HAWB/*"EX1"*//*SW6->W6_PO_NUM*/    ,Nil})
				EndIf
			ElseIf Alltrim(aTit[nPosTipo][2]) $ "PA"
				dbSelectArea("SW2")
				SW2->(dbSetOrder(1))//W2_FILIAL+W2_PO_NUM
				If SW2->(dbSeek(xFilial("SW2") + Alltrim(SWA->WA_HAWB)) )
					dbSelectArea("ZZ8")
					ZZ8->(dbSetOrder(1))//ZZ8_FILIAL+ZZ8_CODIGO
					If ZZ8->(dbSeek(xFilial("ZZ8") + SW2->W2_XTIPIMP))
						AADD(aTit,{"E2_CCUSTO" ,ZZ8->ZZ8_CUSTO    ,Nil})
						AADD(aTit,{"E2_CLVL"   ,ZZ8->ZZ8_XCLVL    ,Nil})
						AADD(aTit,{"E2_ITEMCTA",ZZ8->ZZ8_XITEMC   ,Nil})
						AADD(aTit,{"E2_ZPROFOR","PRO: "+SW2->W2_PO_NUM /*"EX2"*//*SW2->W2_PO_NUM*/    ,Nil})
					EndIf
				EndIf
			ElseIf Alltrim(aTit[nPosTipo][2]) $ "NF"
				dbSelectArea("SW6")
				SW6->(dbSetOrder(1))//W6_FILIAL+W6_HAWB
				If SW6->(dbSeek(xFilial("SW6") + Alltrim(SWA->WA_HAWB) ))
					dbSelectArea("ZZ8")
					ZZ8->(dbSetOrder(1))//ZZ8_FILIAL+ZZ8_CODIGO
					If ZZ8->(dbSeek(xFilial("ZZ8") + SW6->W6_XTIPIMP))
						AADD(aTit,{"E2_CCUSTO" ,ZZ8->ZZ8_CUSTO    ,Nil})
						AADD(aTit,{"E2_CLVL"   ,ZZ8->ZZ8_XCLVL    ,Nil})
						AADD(aTit,{"E2_ITEMCTA",ZZ8->ZZ8_XITEMC   ,Nil})
						AADD(aTit,{"E2_ZPROFOR","EMB: "+SW6->W6_HAWB/*"EX3"*//*SW6->W6_PO_NUM*/    ,Nil})
					EndIf
				EndIf
			ElseIf Alltrim(aTit[nPosTipo][2]) $ "PR"
				dbSelectArea("ZZ8")
				ZZ8->(dbSetOrder(1))//ZZ8_FILIAL+ZZ8_CODIGO
				If ZZ8->(dbSeek(xFilial("ZZ8") + SW2->W2_XTIPIMP))
					AADD(aTit,{"E2_CCUSTO" ,ZZ8->ZZ8_CUSTO    ,Nil})
					AADD(aTit,{"E2_CLVL"   ,ZZ8->ZZ8_XCLVL    ,Nil})
					AADD(aTit,{"E2_ITEMCTA",ZZ8->ZZ8_XITEMC   ,Nil})
					AADD(aTit,{"E2_ZPROFOR","PRO: "+SW2->W2_PO_NUM/*"EX4"*//*SW2->W2_PO_NUM*/    ,Nil})
				EndIf
			EndIf
		EndIf

		lRet := .T.

	EndIf

	If cParam == "FI400INCTIT"
		If IsInCallStack("EICDI502") .Or. IsInCallStack("EICDI503")
			dbSelectArea("ZZ8")
			ZZ8->(dbSetOrder(1))//ZZ8_FILIAL+ZZ8_CODIGO
			If ZZ8->(dbSeek(xFilial("ZZ8") + SW6->W6_XTIPIMP))
				M->E2_CCUSTO	:= ZZ8->ZZ8_CUSTO
				M->E2_CLVL 		:= ZZ8->ZZ8_XCLVL
				M->E2_ITEMCTA	:= ZZ8->ZZ8_XITEMC
				M->E2_ZPROFOR	:= "EMB: "+SW6->W6_HAWB //"EX5"/*SW6->W6_PO_NUM*/
			EndIf
		EndIf
		If IsInCallStack("ape100Grava")
			dbSelectArea("ZZ8")
			ZZ8->(dbSetOrder(1))//ZZ8_FILIAL+ZZ8_CODIGO
			If ZZ8->(dbSeek(xFilial("ZZ8") + SW2->W2_XTIPIMP))
				M->E2_CCUSTO	:= ZZ8->ZZ8_CUSTO
				M->E2_CLVL 		:= ZZ8->ZZ8_XCLVL
				M->E2_ITEMCTA	:= ZZ8->ZZ8_XITEMC
				M->E2_ZPROFOR	:= "PRO: "+SW2->W2_PO_NUM // "EX6"/*SW2->W2_PO_NUM*/
			EndIf
		EndIf
		If IsInCallStack("di500_grava")
			dbSelectArea("ZZ8")
			ZZ8->(dbSetOrder(1))//ZZ8_FILIAL+ZZ8_CODIGO
			If ZZ8->(dbSeek(xFilial("ZZ8") + SW6->W6_XTIPIMP))
				M->E2_CCUSTO	:= ZZ8->ZZ8_CUSTO
				M->E2_CLVL 		:= ZZ8->ZZ8_XCLVL
				M->E2_ITEMCTA	:= ZZ8->ZZ8_XITEMC
				M->E2_ZPROFOR	:= "EMB: "+SW6->W6_HAWB //"EX7"/*SW6->W6_PO_NUM*/
			EndIf
		EndIf
		If FunName() == "EICDI502" .And. IsInCallStack("di500despes") .And. cOrigem == "SWD"
			If ValType(cOperacao) == "C"
				If cOperacao == "2" .And. Empty(M->E2_HIST)
					M->E2_HIST	:= AvKey("P: "+ALLTRIM(SW6->W6_HAWB)+' '+AllTrim(SYB->YB_DESCR),"E2_HIST")
				EndIf
			EndIf
		EndIf
	EndIf

	If cParam == "FI400INIVALPA"
		If IsInCallStack("FI400GERPA")
			dbSelectArea("SW6")
			SW6->(dbSetOrder(1))//W6_FILIAL+W6_HAWB
			If SW6->(dbSeek(xFilial("SW6") + Alltrim(SWD->WD_HAWB) ))
				dbSelectArea("ZZ8")
				ZZ8->(dbSetOrder(1))//ZZ8_FILIAL+ZZ8_CODIGO
				If ZZ8->(dbSeek(xFilial("ZZ8") + SW6->W6_XTIPIMP))
					M->E2_CCUSTO	:= ZZ8->ZZ8_CUSTO
					M->E2_CLVL 		:= ZZ8->ZZ8_XCLVL
					M->E2_ITEMCTA	:= ZZ8->ZZ8_XITEMC
					M->E2_ZPROFOR	:= "EMB: "+SW6->W6_HAWB //"EX8"/*SW6->W6_PO_NUM*/
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSW6)
	RestArea(aAreaZZ8)
	RestArea(aAreaSW2)
	RestArea(aArea)

Return(lRet)
