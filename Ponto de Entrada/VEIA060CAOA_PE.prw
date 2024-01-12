#Include "totvs.ch"
// ======================================================================= //
User Function VEIA060()
// ======================================================================= //

Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj 
Local cIdPonto   := "" 
Local cIdModel   := "" 

//Local _cForest   := superGetMv( "CMV_PEC044", ,"SJGALK8/SJ5CLBC/SJ5EL7C/SKEDLFL/SK7ALEL/SK7AL8L/SK7BLEL/SK7BLFL/SK7CLEL/SK7CLFL")

Local _nPerc     := 0

Local cTpVdNaoPe := "" 
Local _cPgNF     := AllTrim( GetMV('CMV_FAT011') )

Private _cParc   := ""

If aParam <> Nil 
	oObj      := aParam[1] 
	cIdPonto  := aParam[2] 
	cIdModel  := aParam[3] 

 //	u_MVCLogPR(aParam)

	Do Case
	Case cIdPonto == "FORMLINEPRE"
		If aParam[5] == "SETVALUE"
			Do Case
			Case cIdModel == "MODEL_VRK"
			 //	ConOut(cIdModel + " - " + cIdPonto + " - " + aParam[5] + " - " + aParam[6])
			 //	VarInfo("aParam",aParam) 
			 //	If aParam[6] == "VRK_VALTAB" 
			 //		If oObj:GetValue("VRK_VALPRE") == 0 
			 //			oObj:SetValue("VRK_VALPRE", FWFldGet("VRK_VALTAB")) 
			 //		EndIf 
			 //	EndIf 

			Case cIdModel == "MODEL_VRL"
				If aParam[6] == "VRL_XFORPA"
					SE4->(dbSetOrder(1))
					IF SE4->(MsSeek( FWxFilial("SE4") + FWFldGet("VRL_XFORPA") ))
						oObj:SetValue("VRL_XFORMA",SE4->E4_XFORMA)
						If ! Empty(FWFldGet("VRL_E1DTEM"))
							oObj:SetValue("VRL_E1DTVE",Condicao(1, SE4->E4_CODIGO , ,FWFldGet("VRL_E1DTEM"))[1,1] )
						EndIf 
					EndIf 
				EndIf 
				If aParam[6] == "VRL_XFORMA" 
					If AllTrim(FWFldGet("STATUS_FIN")) == "SEM_FINANC"
						If AllTrim(FWFldGet("VRL_XFORMA")) $ "TED/BOL/FBA/CTE/FIE/LEA"
							oObj:SetValue("VRL_GERTIT","1") 
						Else
							oObj:SetValue("VRL_GERTIT","0") 
						EndIf 
					EndIf 
				EndIf 

// --> Incluso  CRISTIANO  14/12/2021   (*INICIO*) ----------------------- //
/*
   Mensagem informativa para o preenchimento do campo "Chassi" (VRK_CHASSI) caso o mesmo esteja vazio ao digitar quaisquer um dos campos abaixo:
       "Parcela"    (VRL_E1PARC)
       "Tipo"       (VRL_E1TIPO)
       "Natureza"   (VRL_E1NATU)
       "Vlr.Titulo" (VRL_E1VALO)
   Esta mensagem só será exibida para os pedidos com o campo "Tipo Venda" (VRJ_TIPVEN) contido no conteúdo do NOVO parâmetro denominado "MV_ZTPVDCH".
   O conteúdo deste parâmetro, a principio, está cadastrado com "03/05/"
*/
				If aParam[6] == "VRL_E1PARC" 
					cTpVdNaoPe := SuperGetMV("MV_ZTPVDCH" , .F. , "03/05/")	// --> Define Tipos de Vendas com obrigatoriedade de CHASSI para gerar financeiro.
					cTpVdNaoPe := AllTrim(cTpVdNaoPe)
					If AllTrim(FWFldGet("VRJ_TIPVEN")) $ cTpVdNaoPe 		// --> "03/05/"
						If Empty(FWFldGet("VRK_CHASSI")) 
							MsgInfo("O 'Tipo Venda' (VRJ_TIPVEN) está cadastrado com um desses tipos ["+cTpVdNaoPe+"]  .e.  o campo 'Chassi' (VRK_CHASSI) não está preenchido !!!" + Chr(13)+Chr(10) + Chr(13)+Chr(10) + ;
							         "Será necessário o preenchimento do campo 'Chassi' para permissão da gravação do Pedido de Venda.", "VEIA060CAOA_PE.prw - VRL_E1PARC") 
						EndIf 
					EndIf 
				EndIf 
				If aParam[6] == "VRL_E1TIPO" 
					cTpVdNaoPe := SuperGetMV("MV_ZTPVDCH" , .F. , "03/05/")	// --> Define Tipos de Vendas com obrigatoriedade de CHASSI para gerar financeiro.
					cTpVdNaoPe := AllTrim(cTpVdNaoPe) 
					If AllTrim(FWFldGet("VRJ_TIPVEN")) $ cTpVdNaoPe 		// --> "03/05/"
						If Empty(FWFldGet("VRK_CHASSI")) 
							MsgInfo("O 'Tipo Venda' (VRJ_TIPVEN) está cadastrado com um desses tipos ["+cTpVdNaoPe+"]  .e.  o campo 'Chassi' (VRK_CHASSI) não está preenchido !!!" + Chr(13)+Chr(10) + Chr(13)+Chr(10) + ;
							         "Será necessário o preenchimento do campo 'Chassi' para permissão da gravação do Pedido de Venda.", "VEIA060CAOA_PE.prw - VRL_E1TIPO") 
						EndIf 
					EndIf 
				EndIf 
				If aParam[6] == "VRL_E1NATU" 
					cTpVdNaoPe := SuperGetMV("MV_ZTPVDCH" , .F. , "03/05/")	// --> Define Tipos de Vendas com obrigatoriedade de CHASSI para gerar financeiro.
					cTpVdNaoPe := AllTrim(cTpVdNaoPe) 
					If AllTrim(FWFldGet("VRJ_TIPVEN")) $ cTpVdNaoPe 		// --> "03/05/"
						If Empty(FWFldGet("VRK_CHASSI")) 
							MsgInfo("O 'Tipo Venda' (VRJ_TIPVEN) está cadastrado com um desses tipos ["+cTpVdNaoPe+"]  .e.  o campo 'Chassi' (VRK_CHASSI) não está preenchido !!!" + Chr(13)+Chr(10) + Chr(13)+Chr(10) + ;
							         "Será necessário o preenchimento do campo 'Chassi' para permissão da gravação do Pedido de Venda.", "VEIA060CAOA_PE.prw - VRL_E1NATU") 
						EndIf 
					EndIf 
				EndIf 
				If aParam[6] == "VRL_E1VALO" 
					cTpVdNaoPe := SuperGetMV("MV_ZTPVDCH" , .F. , "03/05/")	// --> Define Tipos de Vendas com obrigatoriedade de CHASSI para gerar financeiro.
					cTpVdNaoPe := AllTrim(cTpVdNaoPe) 
					If AllTrim(FWFldGet("VRJ_TIPVEN")) $ cTpVdNaoPe 		// --> "03/05/"
						If Empty(FWFldGet("VRK_CHASSI")) 
							MsgInfo("O 'Tipo Venda' (VRJ_TIPVEN) está cadastrado com um desses tipos ["+cTpVdNaoPe+"]  .e.  o campo 'Chassi' (VRK_CHASSI) não está preenchido !!!" + Chr(13)+Chr(10) + Chr(13)+Chr(10) + ;
							         "Será necessário o preenchimento do campo 'Chassi' para permissão da gravação do Pedido de Venda.", "VEIA060CAOA_PE.prw - VRL_E1VALO") 
						EndIf 
					EndIf 
				EndIf 
// --> Incluso  CRISTIANO  14/12/2021   (*FINAL* ) ----------------------- //

			EndCase

		EndIf
	
	Case cIdPonto == "FORMLINEPOS"
	 //	ConOut(cIdModel + " - " + cIdPonto)
		If cIdModel == "MODEL_VRL"
			If oObj:GetValue("VRL_XFORMA") == "PUT" .And. Empty(oObj:GetValue("VRL_XPLACA"))
				Help( Nil , Nil ,"PLACAOBRIGAT" , , "Necessário informar campo PLACA quando forma de pagamento for igual a PUT.",1,0,Nil, Nil, Nil, Nil,Nil , {"Informar campo de placa de veículo."} ) 
				Return .F. 
			EndIf 
		EndIf 

	Case cIdPonto == "FORMCOMMITTTSPOS"
		If cIdModel == "MODEL_VRJ" 			// "VEIA060" 
			If FWIsInCallStack("VA0600183_IntegraVEIXX002") .And. !Empty( AllTrim( FWFldGet("VRJ_PEDCOM") ) )// INTEGRAÃ‡ÃƒO DO VEIA060 - AVANCAR PEDIDO.
				oObj:SetValue("VRJ_XINTEG","X") 
			EndIf 
		EndIf 


// --> Incluso  CRISTIANO  14/12/2021   (*INICIO*) ----------------------- //
/*
   Mensagem alerta impeditivo ao tentar gravar um pedido de vendas que não possua o "Chassi" (VRK_CHASSI) preenchido  .E.  possua dados 
   do título preenchido em "Negociação para o Veículo selecionado" (grid com tabela VRL).
   Esta mensagem/regra impeditiva só será considerada para os pedidos com o campo "Tipo Venda" (VRJ_TIPVEN) contido no conteúdo do NOVO 
   parâmetro denominado "MV_ZTPVDCH".
   O conteúdo deste parâmetro, a principio, está cadastrado com "03/05/"
   E também, só será considerada para as opções (menu) de "Incluir" ou "Alterar". Contempla condicional para não passar nesta regra, caso 
   seja via opção (meny) de "Faturar Atendimentos".
*/
	Case cIdPonto == "MODELPOS" 
		If !AtIsRotina(Upper("VA0600273_TelaFaturarAtendimentos")) 			// --> Não entrar se estiver rodando da rotina "Faturar Atendimentos"
			cTpVdNaoPe := SuperGetMV( "MV_ZTPVDCH" , .F. , "03/05/" ) 		// --> Define Tipos de Vendas com obrigatoriedade de CHASSI para gerar financeiro.
			cTpVdNaoPe := AllTrim(cTpVdNaoPe)
			If AllTrim(FWFldGet("VRJ_TIPVEN")) $ cTpVdNaoPe 				// --> "03/05/"
				If FWFldGet("VRL_CANCEL") <> "1" 							// --> 1 = Titulo Cancelado 
					If Empty(FWFldGet("VRK_CHASSI")) 
						If FWFldGet("VRL_E1VALO") 
							MsgAlert("O 'Tipo Venda' (VRJ_TIPVEN) está cadastrado com um dos tipos ["+cTpVdNaoPe+"]  .e.  o campo 'Chassi' (VRK_CHASSI) não está preenchido !!!" + Chr(13)+Chr(10) + Chr(13)+Chr(10) + ;
							         "Preencha o campo 'Chassi' para gravação do Pedido de Venda.", "VEIA060CAOA_PE.prw") 
							xRet := .F. 
						EndIf 
					EndIf 
				EndIf 
			EndIf 
		EndIf 
// --> Incluso  CRISTIANO  14/12/2021   (*FINAL* ) ----------------------- //

    Case cIdPonto == "MODELCOMMITTTS"
		If VRJ->VRJ_FORPAG $ _cPgNF .AND. VRJ->VRJ_STATUS = 'F' .AND. SE1->E1_PARCELA <> "1" //Forçar a parcela 1 no título p/Atribuição
		    //SE1->(dbSetOrder(1))
		    //If SE1->(dbSeek(xFilial("SE1") + '5  ' + cE1NUM  ))
				IF Empty(SE1->E1_PARCELA) .AND. SE1->(!EOF()) 
					RecLock("SE1",.F.) 
						SE1->E1_PARCELA := "1"
					SE1->(MsUnlock())
				ENDIF
			//EndIf
		EndIf

		VRK->(dbSetOrder(1))
		If VRK->(dbSeek(xFilial("VRK") + VRJ->VRJ_PEDIDO ))
			WHILE VRK->VRK_FILIAL = VRJ->VRJ_FILIAL .AND. VRK->VRK_PEDIDO = VRJ->VRJ_PEDIDO
                Do Case
					Case VRJ->VRJ_TIPVEN = "02"   //Comissão			
						RecLock("VRK",.F.) 
							VRK->VRK_XPECOM := VV2->VV2_XCOM2
							VRK->VRK_XVLCOM := (VV2->VV2_XCOM2 * VRK->VRK_VALVDA) / 100
						VRK->(MsUnlock())
						_nPerc := VV2->VV2_XCOM2
					Case VRJ->VRJ_TIPVEN = "03"   //Comissão			
						RecLock("VRK",.F.) 
							VRK->VRK_XPECOM := VV2->VV2_XCOM3
							VRK->VRK_XVLCOM := (VV2->VV2_XCOM3 * VRK->VRK_VALVDA) / 100
						VRK->(MsUnlock())
						_nPerc := VV2->VV2_XCOM3
					Case VRJ->VRJ_TIPVEN = "05"   //Comissão			
						RecLock("VRK",.F.) 
							VRK->VRK_XPECOM := VV2->VV2_XCOM5
							VRK->VRK_XVLCOM := (VV2->VV2_XCOM5 * VRK->VRK_VALVDA) / 100
						VRK->(MsUnlock())
						_nPerc := VV2->VV2_XCOM5
					Case VRJ->VRJ_TIPVEN = "06"   //Comissão			
						RecLock("VRK",.F.) 
							VRK->VRK_XPECOM := VV2->VV2_XCOM6
							VRK->VRK_XVLCOM := (VV2->VV2_XCOM6 * VRK->VRK_VALVDA) / 100
						VRK->(MsUnlock())
						_nPerc := VV2->VV2_XCOM6
					Case VRJ->VRJ_TIPVEN = "04" .AND. VRK->VRK_CODMAR $ ("HYU/CHE")
				        //nposModV := At(VV2_DESMOD, _cForest)
						//IF VRK_CODMAR = "HYU" .OR. VRK_CODMAR = "CHE"
							_nPerc := VV2->VV2_XCOM4
						//ELSEIF VRK_CODMAR = "SBR" .AND. nposModV = 0
						//	_nPerc := _nSBR
						//ELSEIF VRK_CODMAR = "SBR" .AND. nposModV <> 0
						//	_nPerc := _nSBRF
						//ENDIF
						RecLock("VRK",.F.) 
							VRK->VRK_XPECOM := VV2->VV2_XCOM4
							VRK->VRK_XVLCOM := (VV2->VV2_XCOM4 * VRK->VRK_VALVDA) / 100
						VRK->(MsUnlock())
                End Case

				RecLock("VV2",.F.) 
					VV2->VV2_XCOMIS := _nPerc
				VV2->(MsUnlock())
				VRK->(DbSkip())
			End

		EndIf

	EndCase

EndIf
	
Return xRet 


/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 06/12/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/



// ======================================================================= //
User Function VA060CR() 
// ======================================================================= //

Local   oModelVRL  := PARAMIXB[1]
Local   aSE1       := PARAMIXB[2]
Local   cBcoAgCtSb := SuperGetMv("CAOASCBOL"  , , "237,2372,103476,001" )  // Banco Agencia Conta Subconta padrão para geração automática Boletos Veículos
Local   cFormaBol  := SuperGetMv("CAOAFRMBOL" , , "BOL,FBA,CTE,FIE,LEA" )  // Forma de pagamento (VRL) que geram boleto veículo
Local   cBanco     := "" 
Local   cAgencia   := "" 
Local   cConta     := "" 
Local   cSubCt     := ""
Local   nPos   	   := Nil
Local   nX		   := 2
Local   nSep1 , nSep2 , nSep3 := Nil
Local   cNNumSDig  := ""
Local   L     , D     , P     := 0

Default cCar := ","

// ConOut("VA060CR") 

aAdd( aSE1 , {"E1_DECRESC" , oModelVRL:GetValue("VRL_XDECRE") , Nil} ) 
aAdd( aSE1 , {"E1_XPLACA"  , oModelVRL:GetValue("VRL_XPLACA") , Nil} )
aAdd( aSE1 , {"E1_XFORMA"  , oModelVRL:GetValue("VRL_XFORMA") , Nil} )

// Função para gravação automática de Boletos em Contas a Receber de Pedido Veículos Montadora com as formas E1_XFORMA especificadas 
nSep1    := At(cCar, cBcoAgCtSb)
nSep2    := At(cCar, SubStr(cBcoAgCtSb,(nSep1+1),(Len(cBcoAgCtSb)-nSep1)))+nSep1
nSep3    := RAt(cCar, cBcoAgCtSb)

cBanco   := SubStr(cBcoAgCtSb,1,(nSep1-1)) 
cAgencia := Padr(SubStr(cBcoAgCtSb, ((nSep1)+1), ((nSep2)-(nSep1)-1)),TamSx3("EE_AGENCIA")[1]) 
cConta   := Padr(SubStr(cBcoAgCtSb, ((nSep2)+1), ((nSep3)-(nSep2)-1)),TamSx3("EE_CONTA")[1])  
cSubCt   := Padr(RIGHT(cBcoAgCtSb, 3),TamSx3("EE_SUBCTA")[1]) 
 
nPos := Len(aSE1)

If (aSE1[nPos][nX] $ cFormaBol)	

	dbSelectArea("SEE")
	SEE->(dbSetOrder(1))
	SEE->(dbGoTop())

	If SEE->(dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCt))  
		cNNumSDig := SubStr(EE_CODCART,2,2)+StrZero(Val(SEE->EE_FAXATU),11) 
		L := Len(cNNumSDig) 						// REGRA DIGITO DO NOSSO NUMERO PARA 237 BRADESCO (MODULO11)
		D := 0
		P := 2
		While L > 0
			D := D + Val(SubStr(cNNumSDig, L, 1)) * P
			P := P + 1
			L := L - 1
			If P = 8
				P:= 2
			EndIf
		EndDo 
		If mod(D,11) = 0
			D := Str(0)
		Else
			D := Str(11 - (Mod(D,11)))
		EndIf 
		If D = Str(10)
			D := "P"
		EndIf 
		D := AllTrim(D)
	
		aAdd( aSE1 , {"E1_PORTADO" , cBanco   , NIL} )   						
		aAdd( aSE1 , {"E1_AGEDEP"  , cAgencia , NIL} )  						
		aAdd( aSE1 , {"E1_CONTA"   , cConta   , NIL} )
		aAdd( aSE1 , {"E1_NUMBCO"  , Substr(cNNumSDig,3,11) + D , NIL})	

		RecLock("SEE",.F.)		    				
			SEE->EE_FAXATU := StrZero(Val(SEE->EE_FAXATU) + 1,10)  //INCREMENTA P/ TODOS OS BANCOS
		SEE->(MsUnLock())		
	EndIf
	
EndIf

Return aClone(aSE1)



// ======================================================================= //
User Function VA060ATE()
// ======================================================================= //

Local cChamada      := PARAMIXB[1]
Local oAuxModel     := PARAMIXB[2]
Local aArrayIntegra := PARAMIXB[3]
Local nPosaIte

//ConOut("VA060ATE")
Do Case
Case cChamada == "VS9"
	aAdd( aArrayIntegra , { "VS9_XDECRE" , oAuxModel:GetValue("VRL_XDECRE") , Nil } ) 
	aAdd( aArrayIntegra , { "VS9_XPLACA" , oAuxModel:GetValue("VRL_XPLACA") , Nil } )
	aAdd( aArrayIntegra , { "VS9_XFORMA" , oAuxModel:GetValue("VRL_XFORMA") , Nil } )

Case cChamada == "VVA"
	nPosaIte := aScan(aArrayIntegra , { |x| x[1] == "VVA_CHASSI" })
	If nPosaIte == 0
		nPosaIte := aScan(aArrayIntegra , { |x| x[1] == "VVA_CODMAR" })
	EndIf		
	If nPosaIte > 0
		aAdd( aArrayIntegra , { Nil , Nil , Nil} ) 
		aIns(aArrayIntegra, nPosaIte)
		aArrayIntegra[nPosaIte] := {"VVA_XBASST" , oAuxModel:GetValue("VRK_XBASST") , Nil}

		++nPosaIte
		aAdd( aArrayIntegra , { Nil , Nil , Nil} ) 
		aIns(aArrayIntegra, nPosaIte)
		aArrayIntegra[nPosaIte] := {"VVA_XBASPI" , oAuxModel:GetValue("VRK_XBASPI") , Nil}

		++nPosaIte
		aAdd( aArrayIntegra , { Nil , Nil , Nil} ) 
		aIns(aArrayIntegra, nPosaIte)
		aArrayIntegra[nPosaIte] := {"VVA_XBASCO" , oAuxModel:GetValue("VRK_XBASCO") , Nil}

		++nPosaIte
		aAdd( aArrayIntegra , { Nil , Nil , Nil} ) 
		aIns(aArrayIntegra, nPosaIte)
		aArrayIntegra[nPosaIte] := {"VVA_XBASIP" , oAuxModel:GetValue("VRK_XBASIP") , Nil}
	Else
		aAdd( aArrayIntegra , { "VVA_XBASST" , oAuxModel:GetValue("VRK_XBASST") , NIL} ) 
		aAdd( aArrayIntegra , { "VVA_XBASPI" , oAuxModel:GetValue("VRK_XBASPI") , NIL} ) 
		aAdd( aArrayIntegra , { "VVA_XBASCO" , oAuxModel:GetValue("VRK_XBASCO") , NIL} ) 
		aAdd( aArrayIntegra , { "VVA_XBASIP" , oAuxModel:GetValue("VRK_XBASIP") , NIL} ) 
	EndIf
EndCase

Return aArrayIntegra



// ======================================================================= //
User Function VXI02CR()
// ======================================================================= //

Local aFIN040 := PARAMIXB[1]
Local aParcSE1 := PARAMIXB[2]
Local nPosE1_DECRESC

If aParcSE1[27] <> 0
	VS9->(dbGoTo(aParcSE1[27]))
	nPosE1_DECRESC := aScan(aFIN040, { |x| x[1] == "E1_DECRESC" })
	If nPosE1_DECRESC <> 0
		aFIN040[nPosE1_DECRESC,2] := VS9->VS9_XDECRE 
	Else
		aAdd( aFIN040 , { "E1_DECRESC" , VS9->VS9_XDECRE , Nil } )
	EndIf
	aAdd( aFIN040 , { "E1_XPLACA" , VS9->VS9_XPLACA , Nil } )
	aAdd( aFIN040 , { "E1_XFORMA" , VS9->VS9_XFORMA , Nil } )
EndIf

Return aFIN040



// ======================================================================= //
User Function BASSTCAOA()
// ======================================================================= //

Local cVRKCODMAR := FWFldGet("VRK_CODMAR")
Local cVRKMODVEI := FWFldGet("VRK_MODVEI")
Local cVRKSEGMOD := FWFldGet("VRK_SEGMOD")
Local cVRKFABMOD := FWFldGet("VRK_FABMOD")
Local nBaseST    := 0
Local cGrupo     := GetMV("MV_XVEI014",,"000003") 	// Venda de caminhao HD80, base icms st deve estar zerada
Local cMarca     := GetMV("MV_XVEI015",,"HYU") 		// Venda de caminhao HD80, base icms st deve estar zerada
Local cQuery     := ""

//ConOut( " ")
//ConOut( " BASSTCAOA ")
//ConOut( "             Chamada    - " + ReadVar() )
//ConOut( "             VRK_CODMAR - " + cVRKCODMAR )
//ConOut( "             VRK_MODVEI - " + cVRKMODVEI )
//ConOut( "             VRK_SEGMOD - " + cVRKSEGMOD )
//ConOut( "             VRK_FABMOD - " + cVRKFABMOD )
//ConOut( " ")
//ConOut( "             VRJ_TIPVEN - " + FWFldGet("VRJ_TIPVEN") )
//ConOut( "             VRK_VALTAB - " + cValToChar(FWFldGet("VRK_VALTAB")) )
//ConOut( "             VRK_VALPRE - " + cValToChar(FWFldGet("VRK_VALPRE")) )

If (Alltrim(FWFldGet("VRK_CODMAR")) $ Alltrim(cMarca) .And. Alltrim(FWFldGet("VRK_GRUMOD")) $ Alltrim(cGrupo))
	Return nBaseST
EndIf 

If     FWFldGet("VRJ_TIPVEN") $ "02/03/04/06"
	nBaseST := FWFldGet("VRK_VALPRE")
	If nBaseST == 0
		nBaseST := FWFldGet("VRK_VALTAB")
	EndIf
	If FWFldGet("VRJ_TIPVEN") $ "05/06" 			/// ALTERADO
		nBaseST := 0
	EndIf
ElseIf FWFldGet("VRJ_TIPVEN") $ "01"
	cQuery := ;
	          " SELECT   VVP.VVP_BASEST "                              + ; 
	          " FROM     " + RetSqlName("VVP") + " VVP "               + ; 
	          " WHERE    VVP.VVP_FILIAL  = '" + xFilial("VVP")  + "'"  + ;
	          "   AND    VVP.VVP_CODMAR  = '" + cVRKCODMAR      + "' " + ;
	          "   AND    VVP.VVP_MODVEI  = '" + cVRKMODVEI      + "' " + ;
	          "   AND    VVP.VVP_SEGMOD  = '" + cVRKSEGMOD      + "' " + ;
	          "   AND    VVP.VVP_FABMOD  = '" + cVRKFABMOD      + "' " + ;
	          "   AND    VVP.VVP_DATPRC <= '" + dtos(dDataBase) + "'"  + ;
	          "   AND    VVP.D_E_L_E_T_=' ' " +;
	          " ORDER BY VVP.VVP_DATPRC DESC"
	nBaseST := FM_SQL(cQuery)
EndIf

	//MsgAlert("Teste para verificar vase do ICMS " + crlf + crlf + ;
	//	"Base ST: " + cValToChar(nBaseST) + crlf + ;
	//	"Valor de Tabela: " + cValToChar(nValTab) )
	//
	//MaFisRef("IT_VALMERC" ,"VA060", nValTab )
	//ConOut( " ")
	//ConOut( "             VRK_XBASST - " + cValToChar(nBaseST))
	//ConOut( "             VRK_VALPRE - " + cValToChar(FWFldGet("VRK_VALPRE")))
	//ConOut( " ")

Return nBaseST



// ======================================================================= //
User Function INIVALPRE()
// ======================================================================= //

//Local nValMerc := MaFisRet(,"IT_VALMERC")
//ConOut(" ")
//ConOut(" INIVALPRE - Inicializando valor pretendido")
//ConOut("                  Chamada                      - " + ReadVar() )
//ConOut("                  Valor de Tabela - VRK_VALTAB - " + cValToChar(FWFldGet("VRK_VALTAB")))
//ConOut("                  Base do ICMS ST - VRK_XBASST - " + cValToChar(FWFldGet("VRK_XBASST")))
//ConOut(" ")
//ConOut("             Ajustando Fiscal ")
//ConOut("                  -> Recalculando fiscal para buscar base de ICMS ST")
//MaFisRef("IT_VALMERC","VA060", 0 )
MaFisRecal("" , FWFldGet("ITEMFISCAL")) 
//ConOut("          -> Voltando valor de mercadoria")
//MaFisRef("IT_VALMERC","VA060",nValMerc )
//ConOut(" ")

Return FWFldGet("VRK_VALTAB")



// ======================================================================= //
User Function VA060FIN() 
// ======================================================================= //

Local aParam     := PARAMIXB
Local cE1PREFIXO
Local cE1NUM
Local cE1PARCELA
Local cE1TIPO
Local cE1NATUREZ
Local cE1CLIENTE
Local cE1LOJA
Local lRet060F   := .T. 			// --> Incluso  CRISTIANO  14/12/2021 		// --> Apenas para testar via DEBUG, alterando a variável retorno. 

If aParam[1] <> 5 					// --> Cancelamento PV 
 //	Return .T. 						// --> Retirado CRISTIANO  14/12/2021 		// --> Apenas para testar via DEBUG, alterando a variável retorno. 
	Return lRet060F 				// --> Incluso  CRISTIANO  14/12/2021 		// --> Apenas para testar via DEBUG, alterando a variável retorno. 
EndIf

cE1PREFIXO := aParam[ 2, aScan( aParam[2], {|x| x[1] == "E1_PREFIXO"}) , 2 ]
cE1NUM     := aParam[ 2, aScan( aParam[2], {|x| x[1] == "E1_NUM"    }) , 2 ]
cE1PARCELA := aParam[ 2, aScan( aParam[2], {|x| x[1] == "E1_PARCELA"}) , 2 ]
cE1TIPO    := aParam[ 2, aScan( aParam[2], {|x| x[1] == "E1_TIPO"   }) , 2 ]
cE1NATUREZ := aParam[ 2, aScan( aParam[2], {|x| x[1] == "E1_NATUREZ"}) , 2 ]
cE1CLIENTE := aParam[ 2, aScan( aParam[2], {|x| x[1] == "E1_CLIENTE"}) , 2 ]
cE1LOJA    := aParam[ 2, aScan( aParam[2], {|x| x[1] == "E1_LOJA"   }) , 2 ]



SE1->(dbSetOrder(2))
If SE1->(dbSeek(xFilial("SE1") + cE1CLIENTE + cE1LOJA + cE1PREFIXO + cE1NUM + cE1PARCELA + cE1TIPO ))
	RecLock("SE1",.F.) 
		SE1->E1_BAIXA   := dDataBase
		SE1->E1_SALDO   := 0
		SE1->E1_MOVIMEN := dDataBase
		SE1->E1_STATUS  := "B"
		SE1->E1_HIST    := "CANCELADO"
	MsUnLock()
	// Envia titulo ao SAP, como se fosse uma exclusao do titulo	
	// isso se faz necessario, pois esta alteracao tem o efeito de uma exclusao no titulo, mas como o titulo nao serah
	// efetivamentte excluido, eh forcado um envio ao SAP simulando uma exclusao do titulo.
	U_CMVSAP16() 
EndIf

MsgInfo("VA060FIN - Abortando integracao de exclusao de titulo financeiro" )
	
Return .F. 



// ======================================================================= //
User Function VA06001_Chaint(cChaInt) 
// ======================================================================= //

Local cChassi := "" 

If Empty(cChaInt) 
	Return .T. 
EndIf 

cSQL := " SELECT VV1_CHASSI "                                 + ;
        " FROM   " + RetSQLName("VV1") + " VV1 "              + ;
		" WHERE  VV1.VV1_FILIAL = '" + FWxFilial("VV1") + "'" + ;
        "   AND  VV1.VV1_CHAINT = '" + cChaInt + "'"          + ;
        "   AND  VV1.D_E_L_E_T_ = ' ' "
cChassi := FM_SQL(cSQL) 
If Empty(cChassi) 
	FMX_HELP( "CAOAERR04" , "Chassi não encontrado." + CRLF + RetTitle("VV1_CHAINT") + ": " + cChaInt ) 
	Return .F. 
EndIf 
If ! U_VA060SBF(cChassi) 
	FMX_HELP( "SaldoChassi" , "Veículo sem saldo no estoque por endereço/número de série." , "Verifique se o chassi está com saldo na tabela de Saldos por Endereço(SBF)." )
	Return .F. 
EndIf 

Return .T. 



// ======================================================================= //
User Function VA06002_Chassi(cChassi)
// ======================================================================= //

If ! U_VA060SBF(cChassi)
	FMX_HELP( "SaldoChassi" , "Veículo sem saldo no estoque por endereço/número de série." , "Verifique se o chassi está com saldo na tabela de Saldos por Endereço(SBF)." ) 
	Return .F.
EndIf

Return .T.



// ======================================================================= //
User Function VA060SBF(cChassi)
// ======================================================================= //

Local cSQL

	cSQL := " SELECT COUNT(*) "                                   + ;
			" FROM   " + RetSQLName("SBF") + " SBF "              + ;
			" WHERE  SBF.BF_FILIAL  = '" + FWxFilial("SBF") + "'" + ;
			"   AND  SBF.BF_NUMSERI = '" + cChassi + "'"          + ; 
			"   AND  SBF.BF_QUANT   > 0"                          + ;
			"   AND  SBF.D_E_L_E_T_ = ' ' "
	If FM_SQL(cSQL) <= 0
		Return .F.
	else
		U_VA060EMP(cChassi) //Libera o Empenho que o chassi possa ter
	EndIf

Return .T.


// ======================================================================= //
User Function VA060ZF()
// ======================================================================= //

Local oModel      := FWModelActive()

Local oModelVRJ   := oModel:GetModel("MODEL_VRJ")
Local oModelVRK   := oModel:GetModel("MODEL_VRK")

Local oModelRes   := oModel:GetModel("MODEL_RESUMO")

Local nLinha
Local nTotLinha   := oModelVRK:Length()
Local nLinhaAtual := oModelVRK:GetLine()
Local aAtuResumo  := {}

CursorWait()

MaFisEnd()

VA0600023_IniFiscal(oModelVRJ:GetValue("VRJ_CODCLI"), oModelVRJ:GetValue("VRJ_LOJA"))

For nLinha := 1 to oModelRes:Length()
	oModelRes:SetValue("RESQTDEVEND", 0)
	oModelRes:SetValue("RESQTDEVINC", 0)
	oModelRes:SetValue("RESVALTOT", 0)
Next nLinha

For nLinha := 1 To nTotLinha
	oModelVRK:GoLine(nLinha)
	If oModelVRK:isDeleted()
		Loop
	EndIf

	VA0600073_FiscalAdProduto(;
	                          nLinha,;
	                          oModelVRK:GetValue("VRK_VALTAB"),;
	                          oModelVRK:GetValue("VRK_CODTES"),;
	                          oModelVRK:GetValue("B1COD")     ,;
	                          (nLinha == nTotLinha)           ,;
	                          oModelVRK:GetValue("VRK_VALMOV") )

	VA0600143_FiscalAtuCampoLinhaAtual()

	aAtuResumo := {}
	aAdd(aAtuResumo , { "RESQTDEVEND" , 1 })
	aAdd(aAtuResumo , { "RESVALTOT" , oModelVRK:GetValue("VRK_VALVDA") })
	If ! Empty( oModelVRK:GetValue("VRK_CHAINT") )
		aAdd(aAtuResumo, { "RESQTDEVINC" , 1 })
	EndIf

	VA0600253_AtualizaResumo(oModelRes,{oModelVRK:GetValue("VV2RECNO"), oModelVRK:GetValue("VRK_FABMOD")}, aAtuResumo)
Next nLinha

VA0600033_FiscalAtualizaCabecalho()

oModelVRK:GoLine(nLinhaAtual)

CursorArrow()

MsgInfo("Ambiente fiscal reprocessado.")

Return



// --> Incluso  CRISTIANO  14/12/2021   (*INICIO*) ----------------------- //
// ======================================================================= //
User Function CAWHEVLR() 
// ======================================================================= //
/* Função para não permitir a ALTERAÇÃO dos dados do título, preenchidos 
   em "Negociação para o Veículo selecionado" (grid com tabela VRL). 
   Esta mensagem/regra impeditiva só será considerada para os pedidos com 
   o campo "Tipo Venda" (VRJ_TIPVEN) contido no conteúdo do NOVO parâmetro 
   denominado "MV_ZTPVDCH". 
   O conteúdo deste parâmetro, a principio, está cadastrado com "03/05/" 
   Deverá ser inclusa como "U_CAWHEVLR()" no Modo Edição (X3_WHEN) dos 
   seguintes campos da tabela tabela "VRL" - Financeiro - Montadora:
       VRL_E1PREF , VRL_E1NUM  , VRL_E1PARC , VRL_E1TIPO , VRL_E1NATU , 
       VRL_E1CLIE , VRL_E1LOJA , VRL_E1DTEM , VRL_E1DTVE , VRL_E1DTVR , 
       VRL_E1VALO , VRL_E1NBCO , VRL_GERTIT , VRL_XDECRE , VRL_XPLACA , 
       VRL_XFORPA , VRL_XFORMA , VRL_CENCUS , VRL_CONTA  , VRL_ITEMCT , 
       VRL_CLVL  
// ======================================================================= */

Local lRetY      := .T. 
Local aAreaY     := GetArea() 

Local cVRLE1PREF := "" 
Local cVRLE1NUM_ := "" 
Local cVRLE1PARC := ""
Local nVRLE1VALO := 0 

Local cTpVdNaoPe := SuperGetMV( "MV_ZTPVDCH" , .F. , "03/05/" ) 			// --> Define Tipos de Vendas com obrigatoriedade de CHASSI para gerar financeiro.

cTpVdNaoPe := AllTrim(cTpVdNaoPe) 

If ALTERA 
	If VRJ->VRJ_TIPVEN $ cTpVdNaoPe 										// --> MV_ZTPVDCH - "03/05/" 
		If VRL->( !Eof() )  .And.  ( VRL->VRL_PEDIDO == VRJ->VRJ_PEDIDO )	// --> Existe e está posicionado no registro da tabela "VRL" 
			cVRLE1PREF := VRL->VRL_E1PREF 
			cVRLE1NUM_ := VRL->VRL_E1NUM 
			cVRLE1PARC := VRL->VRL_E1PARC
			nVRLE1VALO := VRL->VRL_E1VALO 
			If !Empty(cVRLE1PREF)  .Or.  !Empty(cVRLE1NUM_)  .Or.  !Empty(cVRLE1PARC)  .Or.  nVRLE1VALO <> 0 
				MsgAlert("Não é permitida a alteração dos dados financeiros para este tipo de venda !" , "Especifico") 
				lRetY := .F. 
			EndIf 
		Else 																// --> Caso não esteja posicionado na "VRL"... posiciona para certificar se existe.
			dbSelectArea("VRL") 											// --> Tabela...: "VRL" - Financeiro - Montadora. 
			VRL->(dbSetOrder(2)) 											// --> Indice 02: VRL_FILIAL + VRL_PEDIDO + VRL_ITEPED 
			VRL->(dbSeek(VRJ->VRJ_FILIAL + VRJ->VRJ_PEDIDO)) 
			If VRL->( Eof() )  .Or.  ( VRL->VRL_PEDIDO <> VRJ->VRJ_PEDIDO )
				// --> Realmente não existe registro gravado na base. Então permite a digitação dos campos.  
				lRetY := .T. 
			EndIf 
		EndIf 
	EndIf 
EndIf 

RestArea(aAreaY) 

Return lRetY 
// --> Incluso  CRISTIANO  14/12/2021   (*FINAL* ) ----------------------- //


// --> Incluso  Reinaldo  03/03/2022   (*INICIO*) ----------------------- //
//Função criada para Liberar os empenhos que possa tem na SBF.
//Para Prevenir erro na liberação de Estoque e trave a Tabla SF2
// ======================================================================= //
User Function VA060EMP(cChassi)
// ======================================================================= //
Local cSQL
Local cSQLALIAS := "BFEMP"

	cSQL := " SELECT SBF.BF_EMPENHO, SBF.R_E_C_N_O_ BFREC "               + ;
			" FROM   " + RetSQLName("SBF") + " SBF "              + ;
			" WHERE  SBF.BF_FILIAL  = '" + FWxFilial("SBF") + "'" + ;
			"   AND  SBF.BF_NUMSERI = '" + cChassi + "'"          + ; 
			"   AND  SBF.BF_QUANT   > 0"                          + ;
			"   AND  SBF.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cSQLAlias, .F., .T. )
	DbSelectArea(cSQLALIAS)
	(cSQLALIAS)->(Dbgotop())

	DbSelectArea("SBF")
	SBF->(DbGotop())

	While (cSQLALIAS)->(!Eof())
		
		if (cSQLALIAS)->BF_EMPENHO <> 0

			SBF->(DbGoto((cSQLALIAS)->BFREC))
			RecLock('SBF',.F.)
				SBF->BF_EMPENHO := 0
			SBF->(MsUnlock())

		EndIf
		(cSQLALIAS)->(DbSkip())

	EndDo

	(cSQLAlias)->(dbCloseArea())

Return .T.
// --> Incluso  Reinaldo Rabelo  03/03/2022   (*FINAL* ) ----------------------- //
