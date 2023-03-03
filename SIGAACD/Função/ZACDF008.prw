#include "topconn.ch"
#include "protheus.ch"
#include "apvt100.ch"

#DEFINE  KEY_ESC    27
#DEFINE  NROWS      12
#DEFINE  NCOLS      24
#DEFINE  CRLF       CHAR(13) + CHAR(10)


/*==============================================================================================
Funcao.........:	ZACDF008
Descricao......:	Gravar a movimenta��o de Container entre armaz�ns em tabela auxiliar para posterior processamento
Autor..........:	Valter Carvalho
Cria��o........:	19/03/2020
                    
                    COMPILAR JUNTO COM O ZACDF004

==============================================================================================*/
User Function ZACDF008( cXlote )   // vtdebug
    Local oUnitz    := Nil
    Local i         := 1
    Local aUnitz    := {}
    Local aErrT     := {}
    Local lLoop		:= .T.
    Local cOriLoc  	:= Space(TamSx3("NNR_CODIGO")[1])   		//aramzem orige
    Local cOriEnd  	:= Space(TamSx3("BE_LOCALIZ")[1])   		// endereco origem
    Local cDstLoc 	:= Space(TamSx3("NNR_CODIGO")[1])           //  armazem destino
    Local cDstEnd	:= Space(TamSx3("BE_LOCALIZ")[1])		    //  endereco destino
    Local cXcont    := Space(TamSx3("WN_XCONT")[1])

    VtSetSize(NROWS , NCOLS)

    While lLoop = .T.

		If (RetCodUsr() $ '000358|000429') = .T.
            cXcont      := Padr("MIEU3013751", TamSx3("WN_XCONT")[1], " ")
            cOriLoc     := Padr("907", TamSx3("NNR_CODIGO")[1], " ")
            cOriEnd     := Padr("DCE01", TamSx3("BE_LOCALIZ")[1], " ")
        else
            cXcont      := Space(TamSx3("WN_XCONT")[1])
            cOriLoc  	:= Space(TamSx3("NNR_CODIGO")[1])   		//aramzem orige
            cOriEnd  	:= Space(TamSx3("BE_LOCALIZ")[1])   		// endereco origem
        EndIf

        cDstLoc 	:= Space(TamSx3("NNR_CODIGO")[1])           //  armazem destino
        cDstEnd		:= Space(TamSx3("BE_LOCALIZ")[1])			//  endereco destino

        aErrT := {}

        VTClear()

        @ 00, 00 VtSay "- Transf CONTAINER(1/2)-"

        @ 02, 00 VtSay "ID Container:           " 
        @ 03, 00 VtGet cXcont Pict PesqPict("SWN", "WN_XCONT") Valid IsXloteOk(cXcont)

        @ 04, 00 VtSay "Armz.Origem:            " 
        @ 05, 00 VtGet cOriLoc Pict PesqPict("NNR", "NNR_CODIGO") Valid ValidaInf("NNR", 1, FwXfilial("NNR") + cOriLoc, "NNR_CODIGO")

        @ 06, 00 VtSay "Endereco Origem:        " 
        @ 07, 00 VtGet cOriEnd Pict PesqPict("SBE", "BE_LOCALIZ") Valid ValidaInf("SBE", 1, FwXfilial("SBE") + cOriLoc + cOriEnd, "BE_LOCALIZ")

        VTRead()
        If VtLastKey() = KEY_ESC
            Return
        EndIf


        // listar os unitizadores
        aUnitz :=  GetUnitzC(cXcont, cOriLoc, cOriEnd)

        if Len(aUnitz) = 0
            zShowErr({"Nao encontrado unitizadores no endere�o "}, cXcont)
            Loop
        EndIf

        // Efetua as validacoes nos unitizadores
        oUnitz := TrfUnit():new("", cOriLoc, cOriEnd, "", "")
        For i:=1 to Len(aUnitz)

            VtClear()
            @ 00, 00 VtSay "Validando Origem:" + cValtoChar(i) + " de " + cValtoChar(Len(aUnitz))

            oUnitz:SetUnitz(aUnitz[i])

            // faz checagem nos unitizadores
            oUnitz:Chk_Ori(.F.)  //D0R, DCF, D12, SZJ

            //  Aeval(oUnitz:GetErros(), {|cErr| Iif(Empty(cErr), Nil, Aadd(aErrT, cErr)) } )

        Next

        // verificar se a origem est� em inventario
        oUnitz:IsArmazInv(cDstLoc)  = .F. 

        // Se houver algum erro  mostra o erro e retorna
        If Len(oUnitz:GetErros()) > 0
            zShowErr(oUnitz:GetErros(), cXcont)
            Loop
        EndIf

        // Consulta o destino
        VtClear()
        @ 00, 00 VtSay "- Transf CONTAINER(2/2)-"

        @ 02, 00 VtSay "Armz.Destino:           "	 
        @ 03, 00 VtGet cDstLoc Pict PesqPict("NNR", "NNR_CODIGO") Valid ValidaInf("NNR", 1, FwXfilial("NNR") + cDstLoc, "NNR_CODIGO")

        @ 04, 00 VtSay "Endereco Destino:       " 
        @ 05, 00 VtGet cDstEnd Pict PesqPict("SBE", "BE_LOCALIZ") Valid ValidaInf("SBE", 1, FwXfilial("SBE") + cDstLoc + cDstEnd, "BE_LOCALIZ")
        VTRead()
        If VtLastKey() = KEY_ESC
            Loop
        EndIf

        // Validar para nao mandar para o mesmo destino da origem
        If (cDstLoc = cOriLoc) .AND. ( cDstEnd = cOriEnd)
            zShowErr({" - Origem igual ao destino."}, cXcont)
            Loop
        Endif

        if oUnitz:IsArmazInv(cDstLoc)  = .F. 
            zShowErr({" Local destino esta em inventario (SB2)"}, cXcont)
            Loop
        Endif
        
        // Verificar se os produtos tem seq de abastecimento
        oUnitz := TrfUnit():new("", cOriLoc, cOriEnd, cDstLoc, cDstEnd)
        For  i:=1 to Len(aUnitz)
            VtClear()
            @ 00, 00 VtSay "Validando Seq abastec: " + cValtoChar(i) + " de " + cValtoChar(Len(aUnitz))

            oUnitz:SetUnitz(aUnitz[i])
            
            oUnitz:Chk_DC3() = .F.
        Next
        
        // validar se endere�o e unitizavel
        If OkEndUniz(cDstLoc, cDstEnd) = .F.
            Aadd(aErrT, " - Endere�o destino n�o � unitiz�vel.")
        EndIf

		// verificar se tem bloqueio no end destino
		xValor := Posicione("SBE", 1, cFilAnt + cDstLoc + cDstEnd, "BE_STATUS")
		If (xValor $ "3|4|6") = .T.
            Aadd(aErrT, "- Endere�o destino bloqueado, com status de " + RetSX3Box(GetSX3Cache("BE_STATUS", "X3_CBOX"),,,1)[Val(xValor),3])
		EndIf
      
		// verifica se tem espa�o no Endereco destino
        // oUnitz := TrfUnit():new("", cOriLoc, cOriEnd, cDstLoc, cDstEnd)
        oUnitz:Chk_CapDst(Len(aUnitz)) = .F.

        // Se houver erros vou exibir e gravar no log
        If Len(oUnitz:GetErros()) > 0
            zShowErr(oUnitz:GetErros(), cXcont)
            Loop
        EndIf

        // efetue a grava��o dos unitizadores
        GrvSZJ(cOriLoc, cOriEnd, cDstLoc, cDstEnd, aUnitz, cXcont)

        VTBeep()
        Sleep(50)
        VTBeep()
    EndDo
    VtClear()
Return


/*============================================================================================
Funcao.........:	OkEndUniz()
Descricao......:	Verifica se o endere�o de destno est� em endere�o unitiz�vel
Autor..........:	Valter Carvalho
Cria��o........:	20/06/2020
============================================================================================== */
Static Function OkEndUniz(cDstLoc, cDstEnd)
    Local lRes    := .T.        
    Local cTpEstr := Posicione("SBE", 1, FwXfilial("SBE") + cDstLoc + cDstEnd, "BE_ESTFIS")
            
    If Posicione("DC8", 1, cFilAnt + cTpEstr, "DC8_STATUS") = "2"
        lRes := .F.
    EndIf

Return lRes


/*============================================================================================
Funcao.........:	GrvSZJ()
Descricao......:	Efetua a grava��o dos registro na SZJ
Autor..........:	Valter Carvalho
Cria��o........:	20/06/2020
============================================================================================== */
Static Function GrvSZJ(cOriLoc, cOriEnd, cDstLoc, cDstEnd, aUnitz, cXcont )
    Local i     := 1 

    DbSelectArea("SZJ")
    DbSetOrder(1)

    For i:= 1 to Len(aUnitz)
        VtClear()
        @ 02,00 VtSay "Gravando movimento: " + cValtoChar(i) + " de " + cValtoChar(Len(aUnitz))

        RecLock("SZJ", .T.)
        SZJ->ZJ_FILIAL	:= cFilAnt
        SZJ->ZJ_DOCTO	:= Space(tamsx3("ZJ_DOCTO")[1])
        SZJ->ZJ_TIPO    := "T"
        SZJ->ZJ_TIPOUNI := ""
        SZJ->ZJ_STATUS  := ""
        SZJ->ZJ_PRODUTO	:= Space(TamSx3("B1_COD")[1])
        SZJ->ZJ_QTDE	:= 0

        SZJ->ZJ_LOCORI	:= cOriLoc
        SZJ->ZJ_ENDORI	:= cOriEnd
        SZJ->ZJ_IDUNIT	:= aUnitz[i]

        SZJ->ZJ_LOCDEST	:= cDstLoc
        SZJ->ZJ_ENDDEST := cDstEnd
        SZJ->ZJ_IDUDEST	:= aUnitz[i]
        SZJ->ZJ_HRLEITU := Time()
        SZJ->ZJ_USR     := RetCodUsr()
        SZJ->ZJ_DATA    := Date()

        SZJ->(Msunlock())
    Next

    SZJ->(DbCloseArea())
    

    // efetue o update da tabela de monitoramento dos erros
    TCSqlExec( "UPDATE " + RetSqlName("SZN") + " SET ZN_STATUS = '1' WHERE D_E_L_E_T_ = ' ' AND ZN_XCONT = '" + cXcont + "'  " )

    VtAlert("Registrado com sucesso " + Padl(Len(aUnitz), 4, "0") + " Unitizadores"   , "", .T.)
Return


/*==============================================================================================
Funcao.........:	validaInf(cTabela, nIndice, xVlPesq, cCampo)
Descricao......:	Pesquisa de um armazem ou endere�o existe
Autor..........:	Valter Carvalho
Cria��o........:	13/03/2020
============================================================================================== */
Static Function ValidaInf(cTabela, nIndice, xVlPesq, cCampo)
    Local lRes := .T.
    if Empty(Posicione(cTabela, nIndice, xVlPesq, cCampo))
        lRes := .F.
        VTBeep()
        VTAlert( Alltrim(GetSx3Cache(cCampo, "X3_DESCRIC")) + " nao cadastrado" , "Erro", .T.)
    EndIf

Return lRes


Static Function IsXloteOk(cXcont)
    Local cmd   := ""
    Local cAlias:= GetNextAlias()
    Local lRes  := .F.

    cmd += CRLF + " SELECT WN_XCONT FROM " + RetSqlName("SWN")
    cmd += CRLF + " WHERE "
    cmd += CRLF + "     D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND WN_FILIAL = '" + cFilAnt + "' "
    cmd += CRLF + " AND WN_XCONT  != 'SEM CONTAINER       ' "
    cmd += CRLF + " AND WN_XCONT  = '" + cXcont + "' "

    TcQuery cmd new Alias (cAlias)
 
    lRes := !Empty( (cAlias)->WN_XCONT )

    (cAlias)->(DbCloseArea())

    if lRes = .F.
        VTBeep()
        VTAlert( "IsXloteOk- Container inexiste na tabela Itens da NF de Importacao(SWN)", "Erro", .T.)
    EndIf

Return lRes


/*=============================================================================================
Funcao.........:	GetUnitzC
Descricao......:	Obtem a lista de unitizadores que estao no endere�o informado pelo operador
Autor..........:	Valter Carvalho
Cria��o........:	19/06/2020
============================================================================================== */
Static Function GetUnitzC(cXcont, cOriLoc, cOriEnd)
    Local cAlias    := GetNextAlias()
    Local cmd       := ""
    Local aRes      := {}

    cmd += CRLF + " SELECT DISTINCT WN_XLOTE " 
    cmd += CRLF + " FROM " + RetSqlName("SWN") + " SWN "
    cmd += CRLF + " LEFT JOIN " + RetSqlName("D14") + " D14 ON D14.D_E_L_E_T_ = ' ' AND WN_FILIAL = D14_FILIAL AND WN_XLOTE = D14_IDUNIT AND D14_LOCAL = '" + cOriLoc + "' AND D14_ENDER = '" + cOriEnd + "'  "
    cmd += CRLF + " WHERE "
    cmd += CRLF + "     SWN.D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND WN_FILIAL = '" + cFilAnt + "' " 
    cmd += CRLF + " AND WN_XCONT != 'SEM CONTAINER       ' " 
    cmd += CRLF + " AND WN_XCONT = '" + cXcont + "'  "

    TcQuery cmd new Alias (cAlias)

    DbEval({|| Aadd(aRes, (cAlias)->WN_XLOTE), {|| .T.} })

    (cAlias)->(DbCloseArea())

Return aRes


/*=============================================================================================
Funcao.........:	AllUnitEnd
Descricao......:	Verifica se os unitizadores do container foram montados
Autor..........:	Valter Carvalho
Cria��o........:	19/06/2020

Fagner pediu para retirar
==============================================================================================
Static Function AllUnitEnd(cXcont)/
    Local aErr  := {}
    Local cTb   := GetNextAlias()    
    Local cmd   := ""
    Local cHawb := ""
    Local bMSg  := {|| Aadd(aErr, " - Falta montar Unitz " + AllTrim((cTb)->WN_XLOTE))}
    Local bCond := {|| (cTb)->QTD  <> (cTb)->QTDUNIT }

    VtClear()
    @ 00, 00 VtSay "Verificando unitizacao.:" 

    cHawb := GetcHawb(cXcont)

    cTb   := GetNextAlias()    
    cmd := ""
    cmd += CRLF + " SELECT SWN.WN_FILIAL, SWN.WN_INVOICE, SWN.WN_XCONT, SWN.WN_XLOTE, "
    cmd += CRLF + " SUM(WN_QUANT) AS QTD, SUM(D0Q_QUANT) AS QTDCLAS, SUM(D0Q_QTDUNI) AS QTDUNIT " 
    cmd += CRLF + " FROM " + RetSQLName( "SWN" ) + " SWN "
    cmd += CRLF + " LEFT JOIN " + RetSQLName( "SD1" ) + " SD1 " 
    cmd += CRLF + "		ON SD1.D1_FILIAL = '" + FWxFilial("SD1") + "' " 
    cmd += CRLF + "		AND SD1.D1_DOC = SWN.WN_DOC " 
    cmd += CRLF + "		AND SD1.D1_SERIE = SWN.WN_SERIE "
    cmd += CRLF + "		AND SD1.D1_FORNECE = SWN.WN_FORNECE "
    cmd += CRLF + "		AND SD1.D1_LOJA = SWN.WN_LOJA " 
    cmd += CRLF + "		AND SD1.D1_COD = SWN.WN_PRODUTO " 
    cmd += CRLF + "		AND SD1.D1_ITEM = LPAD(SWN.WN_LINHA, 4, '0') " 
    cmd += CRLF + "		AND SD1.D_E_L_E_T_ = ' ' "
    cmd += CRLF + " LEFT JOIN " + RetSQLName( "D0Q" ) + " D0Q "
    cmd += CRLF + " 	ON D0Q.D0Q_FILIAL = '" + cFilAnt + "' " 
    cmd += CRLF + " 	AND D0Q.D0Q_DOCTO = SD1.D1_DOC " 
    cmd += CRLF + " 	AND D0Q.D0Q_SERIE = SD1.D1_SERIE " 
    cmd += CRLF + " 	AND D0Q.D0Q_CLIFOR = SD1.D1_FORNECE " 
    cmd += CRLF + " 	AND D0Q.D0Q_LOJA = SD1.D1_LOJA " 
    cmd += CRLF + " 	AND D0Q.D0Q_CODPRO = SD1.D1_COD "
    cmd += CRLF + " 	AND D0Q.D0Q_NUMSEQ = SD1.D1_NUMSEQ " 
    cmd += CRLF + "		AND D0Q.D_E_L_E_T_ = ' ' "
    cmd += CRLF + " WHERE SWN.WN_FILIAL = '" + cFilAnt + "' " 
    cmd += CRLF + "		AND SWN.WN_HAWB = '" + cHawb   + "' "
    cmd += CRLF + "		AND SWN.WN_XCONT = '" + cXcont + "' "
    cmd += CRLF + "		AND SWN.D_E_L_E_T_ = ' ' "
    cmd += CRLF + " GROUP BY SWN.WN_FILIAL, SWN.WN_INVOICE, SWN.WN_XCONT, SWN.WN_XLOTE "
    cmd += CRLF + " ORDER BY SWN.WN_FILIAL, SWN.WN_INVOICE, SWN.WN_XCONT, SWN.WN_XLOTE " 

    TcQuery cmd new Alias (cTb)

    (cTb)->(DbEval(bMSg, bCond))

    (cTb)->(DbCloseArea())

Return aErr
 */

/*=============================================================================================
Funcao.........:	GetcHawb
Descricao......:	Consulta o numero do embarque relacionado ao container
Autor..........:	Valter Carvalho
Cria��o........:	19/06/2020
============================================================================================== */
Static Function GetcHawb(cXcont)
    Local cmd := ""
    Local cTb := GetNextAlias()

    // procedimento para pegar o processo mais recente que contem esse container
    // o container pode aparecer em mais de um processo
    cmd += CRLF + " SELECT DISTINCT WN_HAWB, W9_INVOICE, W9_DT_EMIS, WN_XCONT"
    cmd += CRLF + " FROM " + RetSqlName("SWN") + " SWN "
    cmd += CRLF + " LEFT JOIN " + RetSqlName("SW9") + " SW9 ON SW9.D_E_L_E_T_ = ' ' AND W9_FILIAL = WN_FILIAL AND WN_HAWB = W9_HAWB "
    cmd += CRLF + " WHERE "
    cmd += CRLF + "     SWN.D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND WN_FILIAL = '" + cFilAnt + "' " 
    cmd += CRLF + " AND WN_XCONT  = '" + cXcont  + "' "
    cmd += CRLF + " ORDER BY W9_DT_EMIS DESC "
    TcQuery cmd new Alias (cTb)

    cmd := (cTb)->WN_HAWB

    (ctb)->(DbCloseArea())

Return cmd


/*============================================================================================
Funcao.........:	zShowErr
Descricao......:	Mostra uma grid com os erros e grava o log de erros
Autor..........:	Valter Carvalho
Cria��o........:	08/05/2020
==============================================================================================*/
Static Function zShowErr(aErrT, cXcont)
    Local i         := 1
    Local aAux      := {}
	Local aCab		:= {"Erros na Rotina"}
	Local aSize   	:= {1}
	Local cTexto    := ""
    
    VtClear()

	// array de larguras das colunas
	Aeval(aErrT, {|aIt| Iif(Len(aIt) > aSize[1], aSize[1] := Len(aIt), "" )})

	@ 0,0 VTSAY "ESC:Voltar" 

    VTBeep()
    
    // montar o array das mensagens
    For i:=1 to Len(aErrT)
        If aScan(aAux, aErrT[i]) = 0
            Aadd(aAux, {aErrT[i]})
        EndIf    
    Next    

    VTaBrowse(1, 0, 7, 20, aCab, aAux, aSize, {||FValBrw()}, 0)

    // gravar o arquivo de LOG
    Aeval(aErrT, {|cLin| cTexto += CRLF + cLin})

    DbSelectArea("SZN")
    DbSetOrder(1)
    RecLock("SZN", .T.)
    
    SZN->ZN_FILIAL  := cFilAnt
    SZN->ZN_HAWB    := GetcHawb(cXcont)
    SZN->ZN_XCONT   := cXcont
    SZN->ZN_STATUS  := "0"
    SZN->ZN_DTHR    := Dtoc(Date()) + " " + Time()
    SZN->ZN_USER    := RetCodUsr()
    SZN->ZN_MSGERR  := cTexto

    SZN->(MsUnlock())
Return

/*============================================================================================
Funcao.........:	FValBrw
Descricao......:	Fun��o que controla os eventos de tecla no browse de detalhes. 
Autor..........:	Valter Carvalho
Cria��o........:	08/05/2020
==============================================================================================*/
Static Function FValBrw()
	Local nRes := 2

    If VtLastKey() =  KEY_ESC
		nRes :=  0
    EndIf
return nRes





