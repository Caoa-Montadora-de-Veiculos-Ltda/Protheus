#Include 'Rwmake.ch'
#Include 'TopConn.ch'

#DEFINE cFONT   '<b><font size="3" color="blue"><b>'
#DEFINE cALERT  '<b><font size="3" color="red"><b>'
#DEFINE cNOFONT '</b></font></b></u>'
#DEFINE CRLF chr(13) + chr(10)  

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

	//Private _Logic := .F.
	
	//Ajuste referente ao GAP091 -------------------------------------------
	Public cCodCompr //Vari�vel do campo C1_CODCOMP C�digo do comprador.

		If !Empty(cCodCompr) .and. _lRet .and. FindFunction("U_ZCOMF055")
			//_Logic := .T.
			_lRet := U_ZCOMF055(cCodCompr)
	
		EndIf
		//Fim dos ajustes referente ao GAP091 -------------------------------------------	

		//Local  _nOpc      := If(INCLUI,3, ;
		//					 IF(ALTERA,4, ;
		//					 5) )

		//funcionalidade validar produtos de importa��o
		// valida Tipo de Importacao, caso n�o seja produto de importacao
		// inibido conforme solicita��o do DAC   _lRet := VLDI110TOK()
		
		//	Verifica se CENTO DE CUSTO, ITEM CONT�BIL CLASSE DE VALOR est�o preenchidos, 
		//	ou h� rateio do item DA SOLICITA��O
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

Return _lRet



//Funcao para valida��o
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
		//caso deletado n�o utilizar
		if GDdeleted(i)
			Loop
		Endif

		If Type("cTpImp") <> "C"
			Return lRet
		Endif 

		// -- Se o produto for do tipo Importacao, deixa o campos Tp Import como obrigatorio
		if aCols[i][nPosIM] == 'S'  .and. empty(cTpImp)
			lRet := .F.
			MsgAlert(cALERT+'Aten��o'+cFONT+;
					'<br><br>O campo Tp Import � obrigat�rio para este Tipo de Solicita��o<br>'+;
					'Favor fa�a o preenchimento correto deste campo.'+cNOFONT,"Tipo de Importa��o")
			Return lRet
		Endif

		If !ZZ8->(DbSeek(xFilial("ZZ8")+cTpImp))
			Loop
		Endif
		
		if ZZ8->ZZ8_CORINT == "1" .And. empty(aCols[i][nPosCI])
			lRet := .F.
			MsgAlert(cALERT+'Aten��o'+cFONT+;
			'<br><br>O campo COR INTERNA � obrigat�rio para este Tipo de Importa��o<br>'+;
			'Favor fa�a o preenchimento correto deste campo.'+cNOFONT,"Tipo de Importa��o")
			Return lRet
		Endif

		If ZZ8->ZZ8_COREXT == "1" .And. empty(aCols[i][nPosCE])
			lRet := .F.
			MsgAlert(cALERT+'Aten��o'+cFONT+;
			'<br><br>O campo COR EXTERNA � obrigat�rio para este Tipo de Importa��o<br>'+;
			'Favor fa�a o preenchimento correto deste campo.'+cNOFONT,"Tipo de Importa��o")
			Return lRet
		Endif

		If ZZ8->ZZ8_OPCION == "1" .And. empty(aCols[i][nPosOT])
			lRet := .F.
			MsgAlert(cALERT+'Aten��o'+cFONT+;
			'<br><br>O campo OPCIONAIS � obrigat�rio para este Tipo de Importa��o<br>'+;
			'Favor fa�a o preenchimento correto deste campo.'+cNOFONT,"Tipo de Importa��o")
			Return lRet
        Endif

	Next i

Return lRet
