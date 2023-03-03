#define CRLF chr(13) + chr(10)


/*/{Protheus.doc}
@param
@author  DAC - Denilso
@version P12.1.25
@since   04/03/2022
@return  Lógico
@obs     ponto de entrada após o cancelamento da nota pela funcionalidade OFIOM220
@project Barueri
@Obs     04/03/2022- 	Verificar o retorno pois caso seja falso o processo esta em transaction abortara o cancelamento
						Em validação mesmo retornando falso apagou a Nota
@history 11/05/2022		Incluído validação de variavel _XlCancelaOrc para verificar se cancela o orçamento caso seja indicado no PE OFM220AT 11/05/2022
/*/

User Function OFM220FN 
Local _lRet := .T.

Begin Sequence

	//Verifica se conseguiu fazer o cancelamento corretamente o processo esta em um trasation
	If Type("lMsErroAuto") == "L" .and. lMsErroAuto
		Break
	EndIf
	If Type("cNota") <> "C" .or. Type("cSerie") <> "C"
		MsgInfo("Referencia a nota e série da nota não estão preenchidas ! Não foi possivel atualizar orçamentos referente a nota, comunicar ADM Sistemas","Atenção") 
		Break
	EndIf 

	//Se vier variavel como verdadeiro significa que o processo é somente para voltar status A faturar 
	//não sendo necessário retirar as informações do picking e aglutinação do orçamento - DAC 12/05/2022 
	If Type("_XlLiberaOrc") == "L" .and. _XlLiberaOrc 
		_lRet := XOFM220FLIB()
		Break
	Endif	

	//Atualizar VS1, VS3, SZK, VM5, VM6
	If !Empty(cNota)
		_lRet := XOFM220FNAT()
	EndIf	  

End Sequence
Return _lRet

//Atualizar VS1, VS3, SZK, VM5, VM6
Static Function XOFM220FNAT()
Local _cAliasPesq 	:= GetNextAlias()
Local _lRet			:= .T.
Local _cPicking		:= ""
Local _lCancela		:= .F.
Local _cStatus		:= "C"
Begin Sequence
	BeginSql Alias _cAliasPesq
		SELECT 	SZK.R_E_C_N_O_ NREGSZK
   		FROM %table:SZK% SZK
   		WHERE 	SZK.ZK_FILIAL  		= %XFilial:SZK%
			AND SZK.ZK_NF  			= %Exp:cNota%
			AND SZK.ZK_SERIE  		= %Exp:cSerie%
		  	AND SZK.%notDel%		  
	EndSql
	If (_cAliasPesq)->(Eof()) 
		Break
	Endif	
	If Type("_XlCancelaOrc") == "L" .and. _XlCancelaOrc .and. VS1->VS1_STATUS <> "C"
		_lCancela := .T.
	Endif	

	While (_cAliasPesq)->(!Eof()) 
		SZK->(DbGoto((_cAliasPesq)->NREGSZK))
		//Apagar SZK
		If Empty(_cPicking)
			_cPicking	:= SZK->ZK_XPICKI
		EndIf
		If SZK->(RecLock("SZK",.F.))
			_cObs			:= AllTrim(SZK->ZK_MENNOT)
			_cObs			+= " -CANCEL "+DtoC(Date())+" EXC FAT "+SZK->ZK_NF
			SZK->ZK_NF		:= ""
			SZK->ZK_SERIE	:= ""
			SZK->ZK_STATUS := _cStatus   //Cancelar Picking
			SZK_ZK_MENNOT	:=  _cObs
			//SZK->(DbDelete())
			SZK->(MsUnlock())
		EndIf
			
		(_cAliasPesq)->(DbSkip())
	EndDo
	//Apagar VS1 e seus relacionamentos
	_lRet := XOFM220FVS1( _cPicking )
End Sequence
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _lRet



//apagar VS1
Static Function XOFM220FVS1(_cPicking)
Local _cAlias 	:= GetNextAlias()
Local _lRet		:= .T.
Local _lCancela := .F.
Local _cObs		:= ""
Local _cObsAux  := ""
Local _cObsGrv  := {}

Begin Sequence
	BeginSql Alias _cAlias
		SELECT 	VS1.R_E_C_N_O_ NREGVS1
   		FROM %table:VS1% VS1
   		WHERE 	VS1.VS1_FILIAL 		= %XFilial:VS1%
			AND VS1.VS1_XPICKI 		= %Exp:_cPicking%
		  	AND VS1.%notDel%		  
	EndSql
	If (_cAlias)->(Eof()) 
		Break
	Endif	
	//Variavel criada no PE OFM220AT para indicar se cancela ou não orçamento
	If Type("_XlCancelaOrc") == "L" .and. _XlCancelaOrc .and. VS1->VS1_STATUS <> "C"
		_lCancela := .T.
	Endif	
	VS1->(DbSetOrder(11))  	//VS1_FILIAL+VS1_NUMNFI+VS1_SERNFI
	VS3->(DbSetOrder(1))	//VS3_FILIAL+VS3_NUMORC+VS3_SEQUEN  
	VM5->(DbSetOrder(3))	//VM5_FILIAL+VM5_NUMORC  
	VM6->(DbSetOrder(1))	//VM6_FILIAL+VM6_CODVM5+VM6_SEQUEN  

	While (_cAlias)->(!Eof()) 
		VS1->(DbGoto(( _cAlias)->NREGVS1 ))
		//caso exista uma nota diferente para o picking
		If !Empty(VS1->VS1_NUMNFI)  .and. AllTrim(VS1->VS1_NUMNFI) <> AlTrim(cNota)
			(_cAlias)->(DbSkip())
			Loop
		EndIf

		If !VS1->(RecLock("VS1",.F.))
			MsgInfo("Não foi possivel utilizar modo exclusivo para VS1 ! Não foi possivel atualizar orçamentos referente a nota, comunicar ADM Sistemas","Atenção") 
			_cObsAux += "Não foi possivel utilizar modo exclusivo para VS1 ! Não foi possivel atualizar orçamentos referente a nota, comunicar ADM Sistemas"
			_lRet := .F.
			Break
		Endif	

		//Apagar VS3
		If VS3->(DbSeek(XFilial("VS3") + VS1->VS1_NUMORC ) )
			While VS3->(!Eof()) .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC
				If VS3->(RecLock("VS3",.F.))
					VS3->VS3_XAGLU 	:= ""
					VS3->VS3_XPICKI	:= ""
					VS3->VS3_XDTAGL := CtoD(Space(08))
					VS3->VS3_XHSAGL := ""
					VS3->VS3_XUSUGL := ""
					VS3->VS3_DOCSDB := ""
					VS3->(MsUnLock())
				EndIf	
				VS3->(DbSkip())
			EndDo
		EndIf
		//Apagar carregamento
		If VM5->(DbSeek(XFilial("VM5")+ VS1->VS1_NUMORC ) )
			While VM5->(!Eof()) .and. VM5->VM5_NUMORC == VS1->VS1_NUMORC
				//apagar primeiro os itens do relacionamento
				If VM6->(DbSeek(XFilial("VM6") + VM5->VM5_CODIGO ) )
					While !VM6->(!Eof()) .and. VM6->VM6_CODVM5 == VM5->VM5_CODIGO
						If VM6->(RecLock("VM6",.F.))
							VM6->(DbDelete())
							VM6->(MsUnlock())
						EndIf	
						VM6->(DbSkip())
					EndDo 
				EndIf
				//apaga VM5
				If VM5->(RecLock("VM5",.F.))
					VM5->(DbDelete())
					VM5->(MsUnlock())
				EndIf	
				VM5->(DbSkip())
			EndDo
		EndIf
		_cObs	:= ""
		_cObs 	+= "- Retirado Aglutinação "	+ VS1->VS1_XAGLU  + CRLF
		_cObs 	+= "- Cancelado Picking "		+ VS1->VS1_XPICKI + CRLF
		
		If _lCancela
			_cObs += "- Orçamento "+ VS1->VS1_NUMORC+" voltado status "+VS1->VS1_STATUS+" Cancelado " 	+ CRLF
		Else
			_cObs += "- Orçamento "+ VS1->VS1_NUMORC+" voltado status "+VS1->VS1_STATUS+" Inicial " 	+ CRLF
		Endif
		_cObsAux += _cObs
		_cObsGrv := "NOTA FISCAL " +cNota+ " - " +cSerie+ " CANCELADA EM "+ DtoC(Date()) + " Usuário " + Upper(FwGetUserName(RetCodUsr())) + CRLF
		_cObsGrv += _cObs	

		VS1->VS1_XAGLU 	:= ""
		VS1->VS1_XPICKI	:= ""
		VS1->VS1_XDTAGL := CtoD(Space(08))
		VS1->VS1_XHSAGL := ""
		VS1->VS1_XUSUGL := ""
		VS1->VS1_XUSUPI := ""
		VS1->VS1_OBSAGL :=  Upper(_cObsGrv) + CRLF + AllTrim(VS1->VS1_OBSAGL)
		//Cancela o orçamento caso seja indicado no PE OFM220AT 11/05/2022
		If _lCancela
			VS1->VS1_STATUS := "C"
		Endif
		VS1->(MsUnLock())
		(_cAlias)->(DbSkip())
	EndDo
End Sequence
//Mostrar mensagem do processo cancelado
If !_lRet
	_cObs := "NOTA FISCAL " +cNota+ " - " +cSerie+ " COM PROBLEMAS PARA CANCELAR EM "+ DtoC(Date()) + " USUÁRIO " + Upper(AllTrim(FwGetUserName(RetCodUsr()))) + CRLF
	If !Empty(_cObsAux)
		_cObs += _cObsAux
	Endif
Else
	_cObs := "NOTA FISCAL " +cNota+ " - " +cSerie+ " CANCELADA EM "+ DtoC(Date()) + " Usuário " + Upper(FwGetUserName(RetCodUsr())) + CRLF
	If !Empty(_cObsAux)
		_cObs += _cObsAux
	Endif
EndIf
If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif
MsgInfo(_cObs,"Atenção") 
Return _lRet


//Voltar os status do orçamento para A Faturarno cancalamento de Fatura
Static Function	XOFM220FLIB()
Local _lRet		:= .T.
Local _cAlias 	:= GetNextAlias()
Local _aSeqVS3	:= {}
Local _aRegVS1	:= {}
Local _cObs     := ""
Local _cObsAux  := ""
Local _cPicking	:= ""
Local _cDocto	:= ""
Local _cAglutina:= ""
Local _cStatus  := "B" 
Local _cNumOrc
Local _nPos

Begin Sequence
	BeginSql Alias _cAlias
		SELECT 	VS1.VS1_NUMNFI,
				SZK.ZK_XPICKI,
				VS1.VS1_NUMORC, 
				VS3.VS3_SEQUEN
   		FROM %table:VS1% VS1
   		JOIN %table:SZK% SZK
		    ON	SZK.ZK_FILIAL  		= %XFilial:SZK%
			AND SZK.ZK_NF  			= %Exp:cNota%
			AND SZK.ZK_SERIE  		= %Exp:cSerie%
		  	AND SZK.%notDel%		  
		JOIN %table:VS3% VS3 
			ON  VS3.VS3_FILIAL 		= %XFilial:VS3%
			AND VS3.VS3_NUMORC		= VS1.VS1_NUMORC
		  	AND VS3.%notDel%		  
   		WHERE 	VS1.VS1_FILIAL 		= %XFilial:VS1%
			AND VS1.VS1_XPICKI 		= SZK.ZK_XPICKI
 		  	AND VS1.%notDel%		  
		GROUP BY VS1.VS1_NUMNFI,  SZK.ZK_XPICKI, VS1_NUMORC, VS3.VS3_SEQUEN	   
		ORDER BY VS1.VS1_NUMORC+VS3.VS3_SEQUEN
	EndSql
	If (_cAlias)->(Eof()) 
		Break
	Endif	

	SZK->(DbSetOrder(1))  //ZK_FILIAL+ZK_XPICKI+ZK_SEQREG                                                                                                                                   
	VS1->(DbSetOrder(1))  //VS1_FILIAL+VS1_NUMORC                                                                                                                                           
	_cPicking := (_cAlias)->ZK_XPICKI

	_cObs += "NOTA FISCAL " +cNota+ " - " +cSerie+ " PARA CANCELAMENTO EM "+ DtoC(Date()) + " USUÁRIO " + Upper(FwGetUserName(RetCodUsr())) + CRLF
	//LOCALIZAR O PICKING
	If !SZK->(DbSeek(XFilial("VS1")+(_cAlias)->ZK_XPICKI))
		_cObsAux += "Picking "+(_cAlias)->ZK_XPICKI+" não localizado (SZK), contate o ADM Sistemas !" 			
		Break
	EndIf
	//Ajustar orçamento
	While (_cAlias)->(!Eof())
		//localizar orçamento
		If !VS1->(DbSeek(XFilial("VS1")+(_cAlias)->VS1_NUMORC))
			_cObsAux += "Orçamento "+(_cAlias)->VS1_NUMORC+" não localizado (VS1), contate o ADM Sistemas !" 			
			_lRet := .F.
			Break
		EndIf
		Aadd(_aRegVS1,VS1->(Recno()))
		_cNumOrc 	:= VS1->VS1_NUMORC
		_cAglutina	:= VS1->VS1_XAGLU
		_aSeqVS3 := {}
		//guardar o VS3
		While (_cAlias)->(!Eof()) .and. _cNumOrc == (_cAlias)->VS1_NUMORC
			If !VS3->(DbSeek(XFilial("VS3")+VS1->VS1_NUMORC))
				_cObsAux += "Não localizado item no orçamento "+_cNumOrc+" (VS3), contate o ADM Sistemas !" 			
				_lRet := .F.
				Break
			EndIf
			If !VS3->(RecLock("VS3",.F.))
				_cObsAux += "Não foi possivel travar item do orçamento (VS3), contate o ADM Sistemas !" 			
				_lRet := .F.
				Break
			Endif	
			VS3->VS3_QTDCON := VS3->VS3_QTDITE  //Qtde conferida 
			VS3->VS3_DOCSDB := ""
			VS3->VS3_RESERV := "0"  //não reservado
			VS3->VS3_QTDRES	:= 0
			VS3->(MsUnLock())
			Aadd(_aSeqVS3,VS3->VS3_SEQUEN)
			(_cAlias)->(DbSkip())
		EndDo	
		//Atualizar status para carregamento
		If !VS1->(RecLock("VS1",.F.))
			_cObsAux += "Não foi possivel travar orçamento (VS1), contate o ADM Sistemas !" 			
			_lRet := .F.
			Break
		Endif
		VS1->VS1_STATUS := "4"  //Carregamento
		VS1->VS1_STARES := "3"  //não reservado
		VS1->(MsUnlock())
		//Caso esteja deletado tenho que recuperar
		If !VM5->(DbSeek(XFilial("VM5")+ _cNumOrc ) )
			If !XFM220RVM5(_cNumOrc)
				_cObsAux += "Não foi possivel localizar carregamento do orçamento "+_cNumOrc+" com Status "+VS1.VS1_STATUS+" !"
				_lRet := .F.
				//Break
			EndIf	
		EndIf
		//Chama Função para liberar e reservar VS1
		DbSelectArea("VS1")
		Private aHeaderP    := {} // Variavel ultilizada na OX001RESITE 
		_cDocto := VS1->(OX001RESITE(_cNumOrc, .T., _aSeqVS3))
		If Empty(_cDocto) .or. _cDocto == "NA" 
			_cObsAux += "Não foi possivel criar reserva para o orçamento "+VS1->VS1_NUMORC+" os status envolvendo os documentos desta fatura serão retornados !"
			//_lRet := .F.
			//Break
		Else
			_cObsAux += "Criado reserva "+_cDocto+" para o orçamento "+VS1->VS1_NUMORC+" ref. status a Faturar envolvendo !"
		EndIf 
		If !VS1->(RecLock("VS1",.F.))
			_cObsAux += "Não foi possivel travar orçamento (VS1), contate o ADM Sistemas !" 			
			_lRet := .F.
			Break
		Endif	
		//verificar se sera melhor transferencia
		VS1->VS1_STATUS := "F"
		VS1->(MsUnlock())
		_cObs += "- Orçamento "			+ VS1->VS1_NUMORC+" voltado status ["+VS1->VS1_STATUS+"] A Faturar " + CRLF
	EndDo
	//Ajustar Picking
	While SZK->(!Eof()) .and. XFilial("SZK") == SZK->ZK_FILIAL .and. SZK->ZK_XPICKI == _cPicking
		If !SZK->(RecLock("SZK",.F.))
			_cObsAux += "Não foi possivel travar Picking (SZK), contate o ADM Sistemas !" 			
			_lRet := .F.
			Break
		Endif	
		SZK->ZK_NF		:= ""
		SZK->ZK_SERIE	:= ""
		SZK->ZK_STATUS := _cStatus   //Bloqueia Picking
		SZK->(MsUnlock())
		SZK->(DbSkip())	
	EndDo
	_cObs += "- Mantida Onda "		+ _cAglutina + CRLF
	_cObs += "- Mantido Picking "	+ _cPicking  + CRLF

End Sequence
If _lRet
	_cObs += "NOTA FISCAL " +cNota+ " - " +cSerie+" finalizado corretamente o cancelamento !"+ CRLF
	If !Empty(_cObsAux)
		_cObs += _cObsAux + CRLF
	EndIf
Else
	_cObs += "NOTA FISCAL " +cNota+ " - " +cSerie+ " COM PROBLEMAS PARA CANCELAR EM "+ DtoC(Date()) + " USUÁRIO " + Upper(AllTrim(FwGetUserName(RetCodUsr()))) + CRLF
	If !Empty(_cObsAux)
		_cObs += _cObsAux
	Endif
EndIf
_cObs := Upper(_cObs)
MsgInfo(_cObs,"Atenção") 

For _nPos := 1 To Len(_aRegVS1)
	VS1->(Dbgoto(_aRegVS1[_nPos]))
	If VS1->(RecLock("VS1",.F.))
		VS1->VS1_OBSAGL := _cObs + CRLF + VS1->VS1_OBSAGL
		VS1->(MsUnlock())
	Endif	
Next
Return _lRet	



//Recuperar registro deletado do VM5
Static Function XFM220RVM5(_cNumOrc)
Local _cAliasPesq 	:= GetNextAlias()
Local _lRet		:= .T.

Begin Sequence
	BeginSql Alias _cAliasPesq
		SELECT 	VM5.R_E_C_N_O_ NREGVM5,
				VM6.R_E_C_N_O_ NREGVM6
   		FROM %table:VM5% VM5
		JOIN %table:VM6% VM6  
			ON  VM6.VM6_FILIAL 	= %XFilial:VM6%
			AND VM6.VM6_CODVM5 	= VM5.VM5_CODIGO
   		WHERE 	VM5.VM5_FILIAL 	= %XFilial:VM5%
			AND VM5.VM5_NUMORC 	= %Exp:_cNumOrc%
	EndSql
	If (_cAliasPesq)->(Eof()) 
		_lRet := .F.
		Break
	Endif	
	(_cAliasPesq)->(DbGotop())

	VM5->(DbGoto((_cAliasPesq)->NREGVM5))
	If VM5->(deleted())
		VM5->( Reclock("VM5", .F., .T. ) )
		VM5->( DBRecall() )
		VM5->( MsUnlock() )
	Endif
	While (_cAliasPesq)->(!Eof())
		VM6->(DbGoto((_cAliasPesq)->NREGVM6))
		If VM6->(deleted())
			VM6->( Reclock("VM6", .F., .T. ) )
			VM6->( DBRecall() )
			VM6->( MsUnlock() )
		EndIf
		(_cAliasPesq)->(DbSkip())
	EndDo
	XFM220RVM2(VM5->VM5_CODIGO)
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet		


//RECUPERAR VM2 CASO EXISTA
//Verificar se ira trata VM2
//	VM2_FILIAL+VM2_CODIGO+VM2_TIPO+VM2_STATUS                                                                                                                       
Static Function XFM220RVM2( _cCodVM5 )
Local _cAliasPesq 	:= GetNextAlias()
Local _lRet			:= .T.
Begin Sequence
	BeginSql Alias _cAliasPesq
		SELECT 	VM2.R_E_C_N_O_ NREGVM2
   		FROM %table:VM2% VM2
   		WHERE 	VM2.VM2_FILIAL 	= %XFilial:VM2%
			AND VM2.VM2_CODIGO 	= %Exp:_cCodVM5%
	EndSql
	If (_cAliasPesq)->(Eof()) 
		Break
	Endif	
	While (_cAliasPesq)->(!Eof())
		VM2->(DbGoto((_cAliasPesq)->NREGVM2))
		If VM2->(deleted())
			VM2->( Reclock("VM2", .F., .T. ) )
			VM2->( DBRecall() )
			VM2->( MsUnlock() )
		EndIf
		(_cAliasPesq)->(DbSkip())
	EndDo
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet		


