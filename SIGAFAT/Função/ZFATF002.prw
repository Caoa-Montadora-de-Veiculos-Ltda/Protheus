#INCLUDE "PROTHEUS.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"

/*/                                                                                                                               {Protheus.doc} ZFATF002
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

		////U_ZGENUSER( <ID User> , <"NOME DA FUNÇÃO"> , <.F.=Não Exibe Msg; .T.=Exibe Msg> )
		IF U_ZGENUSER( RetCodUsr() ,"ZFATF002" ,.T.) = .F.
			RETURN Nil
		ENDIF
		
	cFileOpen	:= cGetFile(cExtens,cTitulo1,,cMainPath,.T.,)

	If !File(cFileOpen)
	MsgAlert("Arquivo CSV: " + cFileOpen + " não localizado","[ZFATF002] - Atenção")
	Else

		Processa({|| ZFAT002B(cFileOpen,@cArqLog)}, "[ZFATF002] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." )
		
	Endif

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
	
Local cSeparador    := ";" // Separador do arquivo 	
Local aDados        := {} // Array dos dados da linha do laco
Local aDadosLi      := {}
Local cItem         := ""
Local cProduto      := ""
Local nQtdven       := 0
Local _nPunit       := 0
Local n             := 0
Local cDescri       := ""
Local cUm           := ""
Local cConta        := ""
Local cCLVL         := ""
Local cItemcta      := ""
Local _cQry         := ""
Local _cPC          := Space(6)
Local _cTipo        := Space(2)
Local _cGrupo       := Space(4)
Local _nPosItem     := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_ITEM' })
Local _nPosPro      := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_PRODUTO' })
Local _nPosDes      := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_DESCRI' })
Local _nPosUm       := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_UM' })
Local _nPosQtd      := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_QTDVEN' })
Local _nPosPU       := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_PRCVEN' })
Local _nPosCONTA    := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_CONTA' })
Local _nPosIT       := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_ITEMCTA' })
Local _cAliasQry    := GetNextAlias()
Local _lQtdQbr		:= .F.
Local aItens        := {}
Local _cEmp 		:= FWCodEmp()
Private aArea       := GetArea()
Public _nLinAc      := 0

	ProcRegua(311)
	IncProc()
	FT_FUSE(cFileOpen)
	FT_FGOTOP()
	FT_FSKIP()

	aTemp	:= aClone(aCols[1])
		
	While !FT_FEOF()
			
		cLinha	:= FT_FREADLN()
						
		aDados	:= Separa(cLinha,cSeparador)
		aadd(aDadosLi, aClone(aDados))

		FT_FSKIP(1)
	END

	FT_FUSE()

	For n	:= 1 to Len(aDadosLi)
	
		_nLinAc		:= n
		cProduto	:= PadR( AllTrim( aDadosLi[n][01] ) , TamSX3( "C6_PRODUTO" )[1]," ") //Posição 01 do lay-out
	
		SB1->( DbSetOrder( 1 ) )
		If !SB1->( DbSeek( xFilial( "SB1" ) + cProduto ) )
			MsgInfo("Produto não cadastrado :" + cProduto , " [ZFATF002]")
			Loop
		EndIf

		cItem                := PadL( AllTrim( STR(n) ) , TamSX3( "C6_ITEM" )[1],"0")
		cDescri              := POSICIONE("SB1",1,XFILIAL("SB1")+cProduto,"SB1->B1_DESC")
		cUm                  := POSICIONE("SB1",1,XFILIAL("SB1")+cProduto,"SB1->B1_UM")
		cConta               := POSICIONE("SB1",1,XFILIAL("SB1")+cProduto,"SB1->B1_CONTA")
		cCLVL                := POSICIONE("SB1",1,XFILIAL("SB1")+cProduto,"SB1->B1_CLVL")
		cItemcta             := POSICIONE("SB1",1,XFILIAL("SB1")+cProduto,"SB1->B1_ITEMCC")
		nQtdven              := NoRound(Val(aDadosLi[n][02]), TamSx3("C6_QTDVEN")[02]) //VAL(aDadosLi[n][02]) //Posição 02 do lay-out
		
		If _cEmp == '2020' 
			If nQtdven <> NoRound(VAL(aDadosLi[n][02]), 0)
				MsgInfo("Arquivo com quantidade quebrada, processo será abortado, verifique o arquivo. Produto:" + cProduto , " [ZFATF002]")
				EXIT
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe  Pedido de Vendas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cPC                 := ALLTRIM(M->C5_NUM)
		_cTipo               := ALLTRIM(SB1->B1_TIPO)
		_cGrupo              := ALLTRIM(SB1->B1_GRUPO)

		IF _cTipo <> 'SV' .AND. _cGrupo <> 'VEIA'

			If !Empty( _cPC ) //Se não encontrar CM1 fica zero

				If Select( (_cAliasQry) ) > 0
		    		(_cAliasQry)->(DbCloseArea())
	    		EndIf

				_cQry                := " SELECT SB2.B2_COD, SUM(SB2.B2_VATU1) VAL, SUM(SB2.B2_QATU) QTDE"
				_cQry                += " FROM " + RetSqlName("SB2") + " SB2 "
				_cQry                += " WHERE SB2.D_E_L_E_T_ = ' ' "
				_cQry                += " AND SB2.B2_COD = '" + cProduto + "' "
				_cQry                += " GROUP BY SB2.B2_COD "
				//_cQry                := ChangeQuery( _cQry )
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQry ), _cAliasQry, .F., .T. )
			Else
				_cPC                 := " "
			EndIf

			If !(_cAliasQry)->(Eof())
				If ((_cAliasQry)->VAL/(_cAliasQry)->QTDE) < 0
					_nPunit	:= 0
				Else
					_nPunit	:= ((_cAliasQry)->VAL/(_cAliasQry)->QTDE)
				EndIF
			EndIf

			(_cAliasQry)->(dbCloseArea())

			IF n > 1
				aadd(aCols   , aClone(aTemp))
			ENDIF

			aCols[n][_nPosItem]  := cItem
			__READVAR            := "C6_ITEM"
			&("M->"+__READVAR)   := cItem
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosPro]   := cProduto
			__READVAR            := "C6_PRODUTO"
			&("M->"+__READVAR)   := cProduto
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosDes]   := cDescri
			__READVAR            := "C6_DESCRI"
			&("M->"+__READVAR)   := cDescri
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosUm]    := cUM
			__READVAR            := "C6_UM"
			&("M->"+__READVAR)   := cUm
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosQtd]   := nQtdVen
			__READVAR            := "C6_QTDVEN"
			&("M->"+__READVAR)   := nQtdVen
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aColS[n][_nPosPU]    := _nPunit
			__READVAR            := "C6_PRCVEN"
			&("M->"+__READVAR)   := _nPunit
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosConta] := cConta
			__READVAR            := "C6_CONTA"
			&("M->"+__READVAR)   := cConta
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosIt]    := cItemcta
			__READVAR            := "C6_ITEMCTA"
			&("M->"+__READVAR)   := cItemcta
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			/*
			aCols[n][_nPosLiz] := cLocliz	
			__READVAR	:= "C6_LOCALIZ"
			&("M->"+__READVAR)	:= cLocliz
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)	
			*/

			aadd(aItens  , aClone(aCols[n]))

			IF n = Len(aDadosLi)
				Exit
			EndIF

		ENDIF

	Next n

	aCols	:= aClone( aItens )

	GETDREFRESH()
	SetFocus(oGetDad:oBrowse:hWnd) // Atualizacao por linha
	oGetDad:Refresh()
	//A410LinOk(oGetDad)	

	RestArea(aArea)

Return()
