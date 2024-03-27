#INCLUDE "PROTHEUS.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
/*/
{Protheus.doc} ZCOMF051
@param
@author Antonio Oliveira
@version P12.1.23
@since 25/04/2023
@return NIL
@obs e chamdo pelo PE MA140BUT_PE cria opções: Importa Itens
@project
@history Importar itens de pre-nota da planilha excel (CSV)
/*/
User Function ZCOMF051()
	Local cTitulo1  := "Selecione o arquivo para Carga "
	Local cExtens   := "Arquivo CSV | *.CSV"
	Local cMainPath := "C:\"
	Local cArqLog   := ""
	Public _cFile051:= ""

	////U_ZGENUSER( <ID User> , <"NOME DA FUNÇÃO"> , <.F.=Não Exibe Msg; .T.=Exibe Msg> )
	IF U_ZGENUSER( RetCodUsr() ,"ZCOMF051" ,.T.) = .F.
		RETURN Nil
	ENDIF

	_cFile051 := cGetFile(cExtens,cTitulo1,,cMainPath,.T.)

	If !File(_cFile051)
		MsgAlert("Arquivo CSV: " + _cFile051 + " não localizado","[ZCOMF051] - Atenção")
	Else

		Processa({|| ZCOMF51B(_cFile051,@cArqLog)}, "[ZCOMF051] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." )

	Endif

Return Nil


/*/
	{Protheus.doc} ZCOMF051
	@param
	@author Antonio Oliveira ZCOMF51B
	@version P12.1.23
	@since 25/04/2023
	@return NIL
	@obs e chamdo pelo PE MA140BUT_PE cria opções: Importa Itens
	@project
	@history Importar itens de pre-nota da planilha excel (CSV)
/*/
Static Function ZCOMF51B(_cFile051,cArqLog)
	Local cSeparador     := ";" // Separador do arquivo
	Local aDados         := {} // Array dos dados da linha do laco
	Local cItem          := ""
	Local nQtdven        := 0
	Local _nPunit        := 0
	Local n              := 0
	Local cDescri        := ""
	Local cUm            := ""
	Local cConta         := ""
	Local cCC            := ""
	Local cCLVL          := ""
	Local cItemcta       := ""
	Local cConhec        := ""
	Local cCase 		 := ""
	Local _cAliasQry     := GetNextAlias()
	Local _nPosCon       := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_CONHEC' })
	Local _nPosCC        := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_CLVL'   })
	Local _nPosCONTA     := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_CONTA'  })
	Local _nPosITCTA     := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_ITEMCTA'})
	Local _nPosItem      := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_ITEM'   })
	Local _nPosPro       := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_COD'    })
	Local _nPosUm        := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_UM'     })
	Local _nPosLoc       := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_LOCAL'  })
	Local _nPosQtd       := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_QUANT'  })
	Local _nPosPU        := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_VUNIT'  })
	Local _nPosCase      := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_XCASE'  })
	//Local _nPos          := 0
	Local nPosPesq       := 7 //Posição a pesquisar no Array
	Local aItens         := {}

	Private _cFil  	     := FWCodFil()
	Private _cInvoice    := ""
	Private _cProduto    := ""
	Private _cSerie      := cSerie
	Private _cNFiscal    := cNFiscal
	Private _cFornec     := CA100FOR
	Private _cLoja       := cLoja
	Private aItsoma      := {}
	Private aArea        := GetArea()
	Private nQtdent      := 0
	Private nAchou       := 0
	Private lErroGer

	Public aDadosLi      := {}
	Public _cEmp  	     := FWCodEmp()
	Public _nCtItem      := 0
	Public _nLinAc       := 0

	ProcRegua(311)    //311
	IncProc()
	FT_FUSE(_cFile051)
	FT_FGOTOP()
	//FT_FSKIP()

	aTemp	:= aClone(aCols[1])

	While !FT_FEOF()
		cLinha	:= FT_FREADLN()

		aDados	:= Separa(cLinha,cSeparador)
		If alltrim(aDados[1]) == "INVOICE"
			FT_FSKIP()
			Loop
		EndIf
		aadd(aDadosLi, aClone(aDados))

		FT_FSKIP(1)
		IncProc()
	EndDo

	FT_FUSE()

	lErroGer := CompacItem(aDadosli,nPosPesq,aItsoma)  //Somar itens idênticos + divisão 200

	IF !lErroGer

		For n := 1 to Len(aItsoma)

			_cProduto := PadR( AllTrim( aItsoma[n][01] ) , TamSX3( "D1_COD" )[1]   ," ")
			cConhec   := PadR( AllTrim( aItsoma[n][03] ) , TamSX3( "D1_CONHEC" )[1]," ")
			nQtdven   := VAL(aItsoma[n][02])
			cCase     := PadR( AllTrim( aItsoma[n][04] ) , TamSX3( "D1_XCASE" )[1]," ")
			IF Empty(_cProduto)
				LOOP
			ENDIF

			cItem                := PadL( AllTrim( STR(n) ) , TamSX3( "D1_ITEM" )[1],"0")
			cDescri              := POSICIONE("SB1",1,XFILIAL("SB1")+_cProduto,"SB1->B1_DESC"  )
			cLocal               := POSICIONE("SB1",1,XFILIAL("SB1")+_cProduto,"SB1->B1_LOCPAD")
			cUm                  := POSICIONE("SB1",1,XFILIAL("SB1")+_cProduto,"SB1->B1_UM"    )
			cConta               := POSICIONE("SB1",1,XFILIAL("SB1")+_cProduto,"SB1->B1_CONTA" )
			cCLVL                := POSICIONE("SB1",1,XFILIAL("SB1")+_cProduto,"SB1->B1_CLVL"  )
			cItemcta             := POSICIONE("SB1",1,XFILIAL("SB1")+_cProduto,"SB1->B1_ITEMCC")
			cCC                  := POSICIONE("SB1",1,XFILIAL("SB1")+_cProduto,"SB1->B1_CC"    )

			If Select( (_cAliasQry) ) > 0
				(_cAliasQry)->(DbCloseArea())
			EndIf

			_cQry      := " SELECT SB2.B2_COD, SB2.B2_CM1 VAL"
			_cQry      += " FROM " + RetSqlName("SB2") + " SB2 "
			_cQry      += " WHERE SB2.D_E_L_E_T_ = ' ' "
			_cQry      += " AND SB2.B2_FILIAL = '"+ xFilial("SB2") + "' "
			_cQry      += " AND SB2.B2_COD = '"   + _cProduto + "' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQry ), _cAliasQry, .F., .T. )

			If !(_cAliasQry)->(Eof())
				_nPunit	:= (_cAliasQry)->VAL
			EndIf

			(_cAliasQry)->(dbCloseArea())

			IF n > 1
				aadd(aCols   , aClone(aTemp))
			ENDIF

			aCols[n][_nPosItem]  := cItem
			__READVAR            := "D1_ITEM"
			&("M->"+__READVAR)   := cItem
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosPro]   := _cProduto
			__READVAR            := "D1_COD"
			&("M->"+__READVAR)   := _cProduto
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosUm]    := cUM
			__READVAR            := "D1_UM"
			&("M->"+__READVAR)   := cUm
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosQtd]   := nQtdVen
			__READVAR            := "D1_QUANT"
			&("M->"+__READVAR)   := nQtdVen
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aColS[n][_nPosPU]    := _nPunit
			__READVAR            := "D1_VUNIT"
			&("M->"+__READVAR)   := _nPunit
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosConta] := cConta
			__READVAR            := "D1_CONTA"
			&("M->"+__READVAR)   := cConta
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosITCTA] := cItemcta
			__READVAR            := "D1_ITEMCTA"
			&("M->"+__READVAR)   := cItemcta
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosCC]    := cCC
			__READVAR            := "D1_CC"
			&("M->"+__READVAR)   := cCC
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosLoc] := cLocal
			__READVAR	:= "D1_LOCAL"
			&("M->"+__READVAR)	:= cLocal
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosCC] := cCLVL
			__READVAR	:= "D1_CLVL"
			&("M->"+__READVAR)	:= cCLVL
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosCon] := cConhec
			__READVAR	:= "D1_CONHEC"
			&("M->"+__READVAR)	:= cConhec
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aCols[n][_nPosCase] := cCase
			__READVAR	:= "D1_XCASE"
			&("M->"+__READVAR)	:= cCase
			&(GetSx3Cache(__READVAR,"X3_VALID"))
			RunTrigger(2,n,nil,,__READVAR)

			aadd(aItens  , aClone(aCols[n]))

			GETDREFRESH()
			SetFocus(oGetDados:oBrowse:hWnd) // Atualizacao por linha
			oGetDados:oBrowse:Refresh()

			IF n = Len(aItsoma)
				Exit
			EndIF

		Next n

	ENDIF

	aCols	:= aClone( aItens )

	GETDREFRESH()
	SetFocus(oGetDados:oBrowse:hWnd) // Atualizacao por linha
	oGetDados:oBrowse:Refresh()

	RestArea(aArea)

Return()


/*/
	{Protheus.doc} ZCOMF051
	@param
	@author Antonio Oliveira CompacItem
	@version P12.1.23
	@since 25/04/2023
	@return NIL
	@obs e chamdo pelo PE MA140BUT_PE
	@project
	@history Importar itens de pre-nota da planilha excel (CSV) agrupados por código de produto
/*/
Static Function CompacItem(aDadosli,nPosPesq,aItsoma)
	Local cItemPesq := ""

	Local _nPos     := 0
	Local _nSoma    := 0
	Local _x      := 0
	Private _lErro  := .F.

	ASORT(aDadosli, , , { | x,y | x[nPosPesq] < y[nPosPesq] } )
	cItemPesq := PadR( AllTrim( aDadosLi[1][nPosPesq] ) , TamSX3( "D1_COD" )[1]," ")

	for _x := 1 to len(aDadosLi)
		_lErro := Valida_CSV(_x)    //Validações
		_nPos := 0
		If _lErro
			Exit
		EndIf
		_nPos := ASCAN(aItsoma, {|x| x[5] == (aDadosLi[_x][7] + aDadosLi[_x][6]) })
		IF _nPos <> 0 //:= ASCAN(aItsoma, {|x| x[5] == (aDadosLi[_x][7] + aDadosLi[_x][6]) })
			_nSoma := Val(aItsoma[_nPos][2]) + Val(aDadosLi[_x][9])
			aItsoma[_nPos][2] := ALLTRIM(STR(_nSoma))        //aDadosLi[nAux][9]
		else
			AADD(aItsoma, {aDadosLi[_x][7], aDadosLi[_x][9], aDadosLi[_x][11],aDadosLi[_x][6],(aDadosLi[_x][7]+aDadosLi[_x][6])})
		endif
	next _x

Return(_lErro)


/*/
	{Protheus.doc} ZCOMF051
	@param
	@author Antonio Oliveira Inc_SZM
	@version P12.1.23
	@since 25/04/2023
	@return NIL
	@obs e chamdo pelo PE MA140BUT_PE
	@project
	@history Importar itens da planilha excel (CSV) para tabela SZM
/*/

User Function Inc_SZM()
//Somar as quantidades de Produtos idênticos e com mesmo unitizador
	Local K := 0
	Local _cProd     := ""
//Local _cFil  	 := FWCodFil()
//Local _cPoNum    := ""

	For K := 1 to Len(aDadosLi)

		//IF K == 1
		//    LOOP
		//ENDIF

		_cInvoice:= PadR( AllTrim( aDadosLi[K][01] ) , TamSX3( "EW4_INVOIC" )[1]," ")
		//_cPoNUM  := PadR( AllTrim( aDadosLi[K][07] ) , TamSX3( "W2_PO_NUM" )[1]," ")
		_cProd   := PadR( AllTrim( aDadosLi[K][07] ) , TamSX3( "D1_COD" )[1]," ")
		cConhec  := PadR( AllTrim( aDadosLi[K][11] ) , TamSX3( "D1_CONHEC" )[1]," ")
		nQtdven  := VAL(aDadosLi[K][09])

		IF Empty(_cProd)
			LOOP
		ENDIF

	Next

	zGrvSZM()   //Gravar a Tabela SZM

Return()


/*/
	{Protheus.doc} ZCOMF051
	@param
	@author Antonio Oliveira zGrvSZM
	@version P12.1.23
	@since 25/04/2023
	@return NIL
	@obs e chamdo pelo PE MA140BUT_PE
	@project
	@history Gravar a tabela SZM (via planilha CSV)
/*/
Static Function zGrvSZM()
//Local cErr	     := ""
	Local cZM_BL     := ""
	Local cZM_INVOIC := ""
	Local cZM_FORNEC := ""
	Local cZM_LOJA   := ""
	Local cZM_ITEM   := ""
	Local cZM_NAVIO  := ""
	Local cZM_DESCR  := ""
	Local cZM_UNIT   := ""
	Local nZM_QTDE   := ""
	Local cZM_CASE   := ""
	Local cZM_LOTE   := ""
	Local cZM_CONT   := ""
	Local nLn        := 0
	Local lLimpaAnt  := .F.
	Local aLn        := {}
	Private oArq	 := FWFileReader():New(_cFile051)

	if (oArq:Open())

		while (oArq:hasLine())

			aLn := Separa(oArq:GetLine(), ";")

			If aLn[1] = "INVOICE"
				Loop
			else
				nLn ++
			Endif

    		/*
            [01] INVOICE
            [02] NAVIO
            [03] BL
            [04] CONTAINER
            [05] LOTE
            [06] CASE
            [07] PRODUTO
            [08] DESCRICAO
            [09] QUANTIDADE
            [10] UNITIZADOR
            [11] PROCESSO */

            cZM_INVOIC	:= Padr(aLn[1], TamSx3("ZM_INVOICE")[1], " ")
            cZM_BL		:= Padr(aLn[3], TamSx3("ZM_BL")[1], " ")
            cZM_FORNEC	:= CA100FOR
            cZM_LOJA	:= cLoja
            cZM_ITEM	:= STRZERO(nLn,4)
            cZM_DOC		:= Padr(cNFiscal, TAMSX3("ZM_DOC")[1], " ")
            cZM_SERIE	:= Padr(cSerie, TAMSX3("ZM_SERIE")[1], " ")
            cZM_NAVIO	:= Padr(aLn[2], TamSx3("ZM_NAVIO")[1], " ")
            cZM_CONT	:= Alltrim(aLn[4])
            cZM_LOTE	:= Alltrim(aLn[5])
            cZM_CASE	:= Alltrim(aLn[6])
            cZM_PROD	:= Alltrim(StrTran(AllTrim(aLn[07]), "-", ""))
            nZM_QTDE	:= Val(aLn[09])
            cZM_UNIT	:= Alltrim(aLn[10])
            cZM_XPROC   := PadL( AllTrim( aLn[11] ) , 15, "0" )  //Alltrim(aLn[11]) 
            cZM_DESCR   := Posicione("SB1", 1, FwxFilial("SB1") + Alltrim(aLn[07]), "B1_DESC")
	
			aLn[09] := StrTran(aLn[09], ".", "" )

			If lLimpaAnt = .F.
				//TcSqlExec("DELETE FROM " + RetSqlName("SZM") + " WHERE D_E_L_E_T_ = '*' AND ZM_INVOICE = '" + cZM_INVOIC + "' "   )
				//Alterado conforme GAP 082 - SZM.R_E_C_D_E_L_ = SZM.R_E_C_N_O_ 
				TcSqlExec("UPDATE " + RetSqlName("SZM") + " SZM SET SZM.D_E_L_E_T_ = '*', SZM.R_E_C_D_E_L_ = SZM.R_E_C_N_O_ WHERE ZM_FILIAL = '" + FwXfilial("SZM") + "' AND ZM_INVOICE = '" + cZM_INVOIC + "' ")
				//TcSqlExec("UPDATE " + RetSqlName("SZM") + " SET D_E_L_E_T_ = '*' WHERE ZM_FILIAL = '" + FwXfilial("SZM") + "' AND ZM_INVOICE = '" + cZM_INVOIC + "' ")
				lLimpaAnt = .T.
			EndIf

			RecLock("SZM", .T.)
				SZM->ZM_FILIAL 	:= FwXfilial("SZM")
				SZM->ZM_INVOICE	:= Alltrim(cZM_INVOIC)
				SZM->ZM_NAVIO	:= Alltrim(cZM_NAVIO)
				SZM->ZM_BL		:= Alltrim(cZM_BL)
				SZM->ZM_CONT	:= cZM_CONT
				SZM->ZM_LOTE	:= cZM_LOTE
				SZM->ZM_CASE	:= cZM_CASE
				SZM->ZM_PROD	:= cZM_PROD
				SZM->ZM_QTDE	:= nZM_QTDE
				SZM->ZM_UNIT	:= zRetCarUni(cZM_UNIT)
				SZM->ZM_DOC		:= cZM_DOC
				SZM->ZM_SERIE	:= cZM_SERIE
				SZM->ZM_FORNEC	:= cZM_FORNEC
				SZM->ZM_LOJA	:= cZM_LOJA
				SZM->ZM_ITEM	:= cZM_ITEM
				SZM->ZM_DESCR   := cZM_DESCR
                SZM->ZM_XPROC   := cZM_XPROC
				SZM->ZM_EMIS    := dDataBase
			SZM->(MsUnlock())

		EndDo
		oArq:Close()
	EndIf

Return(.T.)


/*/
{Protheus.doc} ZCOMF051
@param
@author Antonio Oliveira Valida_CSV
@version P12.1.23
@since 27/04/2023
@return NIL
@obs e chamdo pelo PE MA140BUT_PE 
@project
@history Função para validar a importação do CSV
/*/
Static Function Valida_CSV(nX)
Local _TProd  := Padr(aDadosLi[nX][07], TamSx3("ZM_PROD"   )[1], " ")
Local _TInvoi := Padr(aDadosLi[nX][01], TamSx3("ZM_INVOICE")[1], " ")
//Local _TProc  := Padr(aDadosLi[_x][11], TamSx3("D1_CONHEC")[1], " ")

    SB1->( DbSetOrder( 1 ) )
    If !SB1->( DbSeek( xFilial( "SB1" ) + _TProd ) )
        MsgInfo("[ZCOMF051] Produto: " + Alltrim(_TProd) + " não cadastrado, Linha: " + Str(nX) + " Corrigir e refazer.")
        _lErro := .T.
    EndIf

    DbSelectArea("SZM")
    SZM->(dbSetOrder(2)) //ZM_FILIAL+ZM_INVOICE+ZM_SERIE              
    If SZM->(dbSeek(_cFil + _TInvoi + "CKD")) //1° validação
        MsgInfo("[ZCOMF051] INVOICE: " + Alltrim(_TInvoi) + " já existe na tabela SZM! Corrigir e refazer. " )
        _lErro := .T.
    Endif

    If Empty(Alltrim(_TInvoi))  			   			//ERRO INVOICE EM BRANCO
        MsgInfo("[ZCOMF051] Número da Invoice em branco! " + Alltrim(_TInvoi))
        _lErro := .T.
    EndIf

Return(_lErro)


/*/ {Protheus.doc} ZCOMF051
@param
@author Antonio Oliveira zRetCarUni
@version P12.1.23
@since 27/04/2023
@return NIL
@obs e chamdo pelo PE MA140BUT_PE 
@project
@history Função para remoção de caracteres especiais do unitizador
/*/

Static Function zRetCarUni(cConteudo)
	Local cCarEsp	:= "!@#$%¨&()+{}^~´`][;.>,<=/¢¬§ªº'?|"+'"'
	Local nI		:= 0

	For nI := 1 To Len(cCarEsp)
		cConteudo := StrTran(cConteudo, SubStr(cCarEsp, nI, 1), "")
	Next nI

Return cConteudo
