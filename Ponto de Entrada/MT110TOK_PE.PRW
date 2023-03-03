#Include 'Rwmake.ch'
#Include 'TopConn.ch'

#DEFINE cFONT   '<b><font size="3" color="blue"><b>'
#DEFINE cALERT  '<b><font size="3" color="red"><b>'
#DEFINE cNOFONT '</b></font></b></u>'

/*/{Protheus.doc} MT110TOK
// Validacao dos campos customizados no TudoOk da Solicitacao de Compras
@author Rodrigo Moraes
@since 	16/12/2018
@version 1.0
@return ${return}, ${return_description}
@obs	
@history    DAC - 28/02/2020 	Ajustado para a chamada de novas funcionalidades
								Mantida as chamadas e funcionalidades anteriores criada ums static function 
								para separar da chamada principal
@type function
/*/

User Function MT110TOK()

Local _aArea  	:= GetArea()
Local _lRet 	:= .T.
//Local  _nOpc      := If(INCLUI,3, ;
//					 IF(ALTERA,4, ;
//					 5) )

	//funcionalidade validar produtos de importação
	// valida Tipo de Importacao, caso náo seja produto de importacao
	// inibido conforme solicitação do DAC   _lRet := VLDI110TOK()
	
	//	Verifica se CENTO DE CUSTO, ITEM CONTÁBIL CLASSE DE VALOR estão preenchidos, 
	//	ou há rateio do item DA SOLICITAÇÃO
	If _lRet .and. FindFunction("U_ZCOMF010")
		_lRet := U_ZCOMF010()
	Endif
	
	If _lRet .and. FindFunction("U_ZCOMF003")
		_lRet := U_ZCF003SCVD()
	Endif
	//Gravar dados para auditoria
	//If _lRet  .and. FindFunction("U_ZCOMF015")
	//	_lRet := U_ZCOMF015( "SC" /*Doc*/,_nOpc, /*indica se devve mostrar somente a tela*/)
	//Endif

RestArea(_aArea)

return _lRet



//Funcao para validação
Static Function	VLDI110TOK()

Local lRet    := .T.
Local nPosCI  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CORINT'})
Local nPosCE  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_COREXT'})
Local nPosOT  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_OPCION'})
Local nPosIM  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_IMPORT'})
Local i 

	DbSelectArea("ZZ8")
	Dbsetorder(1)
	DbSelectArea("SC1")
	Dbsetorder(1)
	For i = 1 to len(acols)
		//caso deletado não utilizar
		if GDdeleted(i)
			Loop
		Endif

		If Type("cTpImp") <> "C"
			Return lRet
		Endif 

		// -- Se o produto for do tipo Importacao, deixa o campos Tp Import como obrigatorio
		if aCols[i][nPosIM] == 'S'  .and. empty(cTpImp)
			lRet := .F.
			MsgAlert(cALERT+'Atenção'+cFONT+;
					'<br><br>O campo Tp Import é obrigatório para este Tipo de Solicitação<br>'+;
					'Favor faça o preenchimento correto deste campo.'+cNOFONT,"Tipo de Importação")
			Return lRet
		Endif

		If !ZZ8->(DbSeek(xFilial("ZZ8")+cTpImp))
			Loop
		Endif
		
		if ZZ8->ZZ8_CORINT == "1" .And. empty(aCols[i][nPosCI])
			lRet := .F.
			MsgAlert(cALERT+'Atenção'+cFONT+;
			'<br><br>O campo COR INTERNA é obrigatório para este Tipo de Importação<br>'+;
			'Favor faça o preenchimento correto deste campo.'+cNOFONT,"Tipo de Importação")
			Return lRet
		Endif

		If ZZ8->ZZ8_COREXT == "1" .And. empty(aCols[i][nPosCE])
			lRet := .F.
			MsgAlert(cALERT+'Atenção'+cFONT+;
			'<br><br>O campo COR EXTERNA é obrigatório para este Tipo de Importação<br>'+;
			'Favor faça o preenchimento correto deste campo.'+cNOFONT,"Tipo de Importação")
			Return lRet
		Endif

		If ZZ8->ZZ8_OPCION == "1" .And. empty(aCols[i][nPosOT])
			lRet := .F.
			MsgAlert(cALERT+'Atenção'+cFONT+;
			'<br><br>O campo OPCIONAIS é obrigatório para este Tipo de Importação<br>'+;
			'Favor faça o preenchimento correto deste campo.'+cNOFONT,"Tipo de Importação")
			Return lRet
        Endif

	Next i

Return lRet
