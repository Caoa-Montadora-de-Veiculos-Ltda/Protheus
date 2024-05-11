#INCLUDE "PROTHEUS.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"

/*/{Protheus.doc} ZFATF002
@param
@author Antonio Oliveira
@version P12.1.23
@since 12/02/2020
@return NIL
@obs e chamdo pelo PE GMMA410BUT cria opções: Importa Itens e Incluir Dados Padrões
@project
@history Importar itens de pedido de vendas da planilha excel (gatilhado preco unit)
/*/
User Function ZFATF002() //MA410MNU()
 
    aadd(aRet, {"", {|| U_ZFAT002A() }, 'Importa Itens'        , 'Importa Itens'})
	aadd(aRet, {"", {|| U_ZFATF005() }, 'Incluir Dados Padrões', 'Incluir Dados Padrões'})

Return(aRet)

/*
==============================================================================================
Funcao.........: ZFAT002A
Descricao......: Busca o arquivo para gravar na tabela
Autor..........: A. Oliveira
Criação........: 12/02/2020
Alterações.....:
===============================================================================================
*/
User Function ZFAT002A()

	Local cTitulo1  := "Selecione o arquivo para Carga "
	Local cExtens   := "Arquivo CSV | *.CSV"
	Local cMainPath := "C:\"
	Local cFileOpen := ""
	Local cArqLog   := ""
	Local _aArea 	:= GetArea()

	////U_ZGENUSER( <ID User> , <"NOME DA FUNÇÃO"> , <.F.=Não Exibe Msg; .T.=Exibe Msg> )
	If U_ZGENUSER( RetCodUsr() ,"ZFATF002" ,.T.) = .F.
		Return Nil
	EndIf
		
	cFileOpen	:= cGetFile(cExtens,cTitulo1,,cMainPath,.T.,)

	If !File(cFileOpen)
		MsgAlert("Arquivo CSV: " + cFileOpen + " não localizado","[ZFATF002] - Atenção")
	Else
		Processa({|| ZFAT002B(cFileOpen,@cArqLog)}, "[ZFATF002] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." )
	Endif

	RestArea(_aArea)

Return Nil

/*
==============================================================================================
Funcao.........: ZFAT002B
Descricao......: Faz a leitura do arquivo CSV e a gravação da tabela
Autor..........: A. Oliveira
Criação........: 12/02/2020
Alterações.....:
===============================================================================================
*/
Static Function ZFAT002B(cFileOpen,cArqLog)
	
Local _aDados      		:= {}
Local _aLidos			:= {}
Local _aItens         	:= {}
Local _aTemp			:= {}
Local _cSeparador    	:= ";" // Separador do arquivo 	
Local _cLinha			:= ""
Local _cProduto      	:= ""
Local _nQtde       		:= 0
Local _nPrcUnit       	:= 0
Local _nX	        	:= 0
Local _cDescricao       := ""
Local _cUm           	:= ""
Local _cConta        	:= ""
Local _cClasseValor     := ""
Local _cItemConta 	    := ""
Local _nPosItem     	:= Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_ITEM' 	})
Local _nPosProduto  	:= Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_PRODUTO' })
Local _nPosDescricao	:= Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_DESCRI' 	})
Local _nPosUM       	:= Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_UM' 		})
Local _nPosQtde      	:= Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_QTDVEN' 	})
Local _nPosPreco       	:= Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_PRCVEN' 	})
Local _nPosConta    	:= Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_CONTA' 	})
Local _nPosItemConta    := Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_ITEMCTA' })
Local _lErroImp			:= .F.
Local _aColsBkp			:= aClone( aCols )
Public _nLinAc      	:= 0

	FT_FUSE(cFileOpen)
	FT_FGOTOP()
	FT_FSKIP()

	ProcRegua( FT_FLASTREC() )

	_aTemp	:= aClone(aCols[01])

	If !FT_FEOF()	
		While !FT_FEOF()
				
			_cLinha	:= FT_FREADLN()
							
			_aLidos	:= Separa(_cLinha,_cSeparador)
			aadd(_aDados, aClone(_aLidos))
			
			FT_FSKIP(1)
		End

		For _nX	:= 1 To Len(_aDados)

			IncProc("Importando registros...")
		
			_nLinAc		:= _nX
			_cProduto	:= PadR( AllTrim( _aDados[_nX][01] ) , TamSX3( "C6_PRODUTO" )[1]," ") //Posição 01 do lay-out
				
			SB1->( DbSetOrder( 1 ) )
			If !SB1->( DbSeek( xFilial( "SB1" ) + _cProduto ) )
				MsgInfo("Produto não cadastrado :" + _cProduto , " [ZFATF002]")
				Loop
			EndIf

			If AllTrim(SB1->B1_TIPO) <> 'SV' .AND. AllTrim(SB1->B1_GRUPO) <> 'VEIA'

				_cItem   		:= PadL( AllTrim( Str(_nX) ) , TamSX3( "C6_ITEM" )[1],"0")
				_cDescricao 	:= SB1->B1_DESC
				_cUm     		:= SB1->B1_UM
				_cConta  		:= SB1->B1_CONTA
				_cClasseValor	:= SB1->B1_CLVL
				_cItemConta		:= SB1->B1_ITEMCC
				_nQtde 			:= NoRound(Val(_aDados[_nX][02]), TamSx3("C6_QTDVEN")[02])
				
				If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
				
					If At(".", AllTrim(_aDados[_nX][02])) > 0 .Or. At(",", AllTrim(_aDados[_nX][02])) > 0
						MsgInfo("Não é permitido quantidade com ponto ou virgula no arquivo de importação."+ CRLF + " Produto: " + _cProduto , " [ZFATF002]")
						_lErroImp := .T.
						Exit
					EndIf
				
				
					If _nQtde <> NoRound(VAL(_aDados[_nX][02]), 0)
						MsgInfo("Arquivo com quantidade quebrada, processo será abortado, verifique o arquivo."+ CRLF + " Produto: " + _cProduto , " [ZFATF002]")
						_lErroImp := .T.
						Exit
					EndIf

				EndIf

				//Retorna o preço unitario baseado nas regras de cada empresa.
				_nPrcUnit := NoRound(U_ZGENCST(_cProduto),TamSx3("C6_PRCVEN")[02])
				If _nPrcUnit == 0
					MsgInfo("O produto esta com o custo zerado, informe o preço unitario manualmente."+ CRLF + " Produto: " + _cProduto , " [ZFATF002]")
				EndIf
			
				If _nX > 1
					aadd(aCols   , aClone(_aTemp))
				EndIf

				//Alimenta o campo do aCols
				aCols[_nX][_nPosItem] 		:= _cItem
	
				aCols[_nX][_nPosProduto] 	:= _cProduto
				zUpdCampo("C6_PRODUTO"	,_cProduto		,_nX )				

				aCols[_nX][_nPosDescricao] 	:= _cDescricao
				zUpdCampo("C6_DESCRI"	,_cDescricao	,_nX )				

				aCols[_nX][_nPosUM] 		:= _cUm					

				aCols[_nX][_nPosQtde] 		:= _nQtde
				zUpdCampo("C6_QTDVEN"	,_nQtde			,_nX )				

				aColS[_nX][_nPosPreco] 		:= _nPrcUnit
				zUpdCampo("C6_PRCVEN"	,_nPrcUnit		,_nX )

				aCols[_nX][_nPosConta] 		:= _cConta
				zUpdCampo("C6_CONTA"	,_cConta		,_nX )

				aCols[_nX][_nPosItemConta] 	:= _cItemConta
				zUpdCampo("C6_ITEMCTA"	,_cItemConta	,_nX )

				aadd(_aItens  , aClone(aCols[_nX]))

			Else
				MsgInfo("Não é permitido a importação de produtos com o Tipo: " + AllTrim(SB1->B1_TIPO) + " ou do Grupo: "+AllTrim(SB1->B1_GRUPO) , " [ZFATF002]")
			EndIf

		Next _nX

		If _lErroImp
			aCols	:= aClone( _aColsBkp )
		Else
			aCols	:= aClone( _aItens )
		EndIf
	Else
		MsgInfo("Não foi possivel importar o arquivo, verifique o conteudo do arquivo e processe novamente." , " [ZFATF002]")
	EndIf

	GETDREFRESH()
	SetFocus(oGetDad:oBrowse:hWnd) // Atualizacao por linha
	oGetDad:Refresh()

Return()

/*
==============================================================================================
Funcao.........: zRunTrigger
Descricao......: Roda as Trigger do Gatilho
Autor..........: Evandro Mariano
Criação........: 28/07/2023
Alterações.....:
===============================================================================================
*/
Static Function zUpdCampo(_cCampo, _xConteudo, _nPos)

Local _aArea			:= FWGetArea()
Local _lValid			:= .F.
Default _nPos			:= 0
Default _cCampo			:= ""
Default _xConteudo		:= " "

//Altera o ReadVar da Memória
&("M->"+_cCampo) := _xConteudo
__ReadVar := _cCampo

//Chama as validações do sistema
_lValid := CheckSX3(_cCampo, _xConteudo)

//Se deu tudo certo nas validações
If _lValid
	If ExistTrigger(_cCampo)
	
		RunTrigger( 2		,;  //nTipo (1=Enchoice; 2=GetDados; 3=F3)
					_nPos	,;  //Linha atual da Grid quando for tipo 2
					Nil		,;  //Não utilizado
							,;  //Objeto quando for tipo 1
					_cCampo	)   //Campo que dispara o gatilho
	EndIf
EndIf

RestArea(_aArea)

Return()
