#include "topconn.ch"
#include "protheus.ch"
#include "apvt100.ch"

#DEFINE  KEY_ESC     27
#DEFINE  NROWS       12
#DEFINE  NCOLS       24
#DEFINE CRLF  	CHAR(13) + CHAR(10)

/*==============================================================================================
Funcao.........:	ZACDF003
Descricao......:	Gravar a movimentação de Container entre armazéns em tabela auxiliar para posterior processamento
Autor..........:	Valter Carvalho
Criação........:	19/03/2020  vtdebug
==============================================================================================*/
User Function ZACDF003( cXlote )   // vtdebug
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
            cXcont      := "INKU2560412"
            cOriLoc     := "907"
            cOriEnd     := "BRGLPATIO06"
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

        // Efetua as validacoes nos unitizadores
        For i:=1 to Len(aUnitz)

            VtClear()
            @ 00, 00 VtSay "Valid. Orig:" + cValtoChar(i) + " de " + cValtoChar(Len(aUnitz))

            oUnitz := TrfUnit():new(aUnitz[i], cOriLoc, cOriEnd, "", "")

            // faz checagem nos unitizadores
            oUnitz:Chk_Ori(.F.)  //D0R, DCF, D12, SZJ

            Aeval(oUnitz:GetErros(), {|cErr| Iif(Empty(cErr), Nil, Aadd(aErrT, cErr)) } )

            FreeObj( oUnitz )
        Next

        // Verificar se foram todos unitizadores foram montados
        //Aeval(AllUnitEnd(cXcont), {|cIt| Aadd(aErrT, cIt )})

        // checa se o armazem de origem esta com bloqueio
        if Len(aUnitz) >0
            oUnitz := TrfUnit():new(aUnitz[1], cOriLoc, cOriEnd, "", "")
            oUnitz:IsArmazInv(cOriLoc) 
            Aeval(oUnitz:GetErros(), {|cErr| Iif(Empty(cErr), Nil, Aadd(aErrT, cErr)) } )
            FreeObj( oUnitz )
        EndIf

        // se tem erro mostra antes de receber o destino
        If Len(aErrT) > 0
            zShowErr(aErrT, cXcont)
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
            Aadd(aErrT, " - Origem igual ao destino.")
        Endif

        // Verificar se os produtos tem seq de abastecimento
        For  i:=1 to Len(aUnitz)
            VtClear()
            @ 00, 00 VtSay "Valid.Seq abast: " + cValtoChar(i) + "-" + cValtoChar(Len(aUnitz))

            oUnitz := TrfUnit():new(aUnitz[i], cOriLoc, cOriEnd, cDstLoc, cDstEnd)
            
            If oUnitz:Chk_DC3() = .F.
                Aeval(oUnitz:GetErros(), {|cIt| Aadd(aResT, cIt)})
            EndIf    

        Next

        // checa se o armazem de origem esta com bloqueio
        oUnitz:IsArmazInv(cDstLoc) 

        // validar se endereço e unitizavel
        If OkEndUniz(cDstLoc, cDstEnd) = .F.
            Aadd(aErrT, " - Endereço destino não é unitizável.")
        EndIf

		// verificar se tem bloqueio no end destino
		xValor := Posicione("SBE", 1, cFilAnt + cDstLoc + cDstEnd, "BE_STATUS")
		If (xValor $ "3|4|6") = .T.
            Aadd(aErrT, "- Endereço destino bloqueado, com status de " + RetSX3Box(GetSX3Cache("BE_STATUS", "X3_CBOX"),,,1)[Val(xValor),3])
		EndIf

     
		// verifica se tem espaço no Endereco destino
        oUnitz := TrfUnit():new("", cOriLoc, cOriEnd, cDstLoc, cDstEnd)
        
        // checar a capacidade do destino
        oUnitz:Chk_CapDst(Len(aUnitz)) = .F.

        // Se houver erros vou exibir e gravar no log
        If Len(aErrT) > 0
            zShowErr(aErrT, cXcont)
            Loop
        EndIf

        // efetue a gravação dos unitizadores
        GrvSZJ(cOriLoc, cOriEnd, cDstLoc, cDstEnd, aUnitz, cXcont)

        VTBeep()
        Sleep(50)
        VTBeep()
    EndDo
    VtClear()
Return


/*============================================================================================
Funcao.........:	OkEndUniz()
Descricao......:	Verifica se o endereço de destno está em endereço unitizável
Autor..........:	Valter Carvalho
Criação........:	20/06/2020
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
Descricao......:	Efetua a gravação dos registro na SZJ
Autor..........:	Valter Carvalho
Criação........:	20/06/2020
============================================================================================== */
Static Function GrvSZJ(cOriLoc, cOriEnd, cDstLoc, cDstEnd, aUnitz, cXcont )
    Local i     := 1 

    DbSelectArea("SZJ")
    DbSetOrder(1)

    For i:= 1 to Len(aUnitz)
        VtClear()
        @ 02,00 VtSay "Gravando movimento: " + cValtoChar(i) + "- " + cValtoChar(Len(aUnitz))

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
Descricao......:	Pesquisa de um armazem ou endereço existe
Autor..........:	Valter Carvalho
Criação........:	13/03/2020
============================================================================================== */
Static Function ValidaInf(cTabela, nIndice, xVlPesq, cCampo)
    Local lRes := .T.
    if Empty(Posicione(cTabela, nIndice, xVlPesq, cCampo))
        lRes := .F.
        VTBeep()
        VTAlert( Alltrim(GetSx3Cache(cCampo, "X3_DESCRIC")) + " nao cadastrado" , "Erro", .T.)
    EndIf

Return lRes


/*============================================================================================
Funcao.........:	IsXloteOk
Descricao......:	Pesquisa se o container existe
Autor..........:	Valter Carvalho
Criação........:	19/06/2020
============================================================================================== */
Static Function IsXloteOk(cXcont)
    Local cmd   := ""
    Local cAlias:= GetNextAlias()
    Local lRes  := .F.

    if select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf        

    cmd += CRLF + " SELECT ZM_UNIT FROM " + RetSqlName("SZM")
    cmd += CRLF + " WHERE "
    cmd += CRLF + "     D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND ZM_FILIAL  = '" + cFilAnt + "' "
    cmd += CRLF + " AND ZM_CONT    != 'SEM CONTAINER       ' "
    cmd += CRLF + " AND ZM_CONT    = '" + cXcont + "' "

    TcQuery cmd new Alias (cAlias)
 
    lRes := !Empty( (cAlias)->ZM_UNIT )

    (cAlias)->(DbCloseArea())

    if lRes = .F.
        VTBeep()
        VTAlert( "IsXloteOk- Container inexiste na tabela - SZM ", "Erro", .T.)
    EndIf

Return lRes


/*=============================================================================================
Funcao.........:	GetUnitzC
Descricao......:	Obtem a lista de unitizadores que estao no endereço informado pelo operador
Autor..........:	Valter Carvalho
Criação........:	19/06/2020
============================================================================================== */
Static Function GetUnitzC(cXcont, cOriLoc, cOriEnd)
    Local cAlias    := GetNextAlias()
    Local cmd       := ""
    Local aRes      := {}

    cmd += CRLF + " SELECT DISTINCT ZM_UNIT " 
    cmd += CRLF + " FROM " + RetSqlName("SZM") + " SZM "
    cmd += CRLF + " INNER JOIN "  + RetSqlName("D14") + " D14 ON D14.D_E_L_E_T_ = ' '  AND SZM.ZM_FILIAL = D14_FILIAL AND SZM.ZM_UNIT = D14_IDUNIT AND D14_LOCAL = '" + cOriLoc + "' AND D14_ENDER = '" + cOriEnd + "'  "
    cmd += CRLF + " WHERE "
    cmd += CRLF + "     SZM.D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND ZM_FILIAL = '" + cFilAnt + "' " 
    cmd += CRLF + " AND ZM_CONT != 'SEM CONTAINER       ' " 
    cmd += CRLF + " AND ZM_CONT = '" + cXcont + "'  "

    TcQuery cmd new Alias (cAlias)

    DbEval({|| Aadd(aRes, (cAlias)->ZM_UNIT), {|| .T.} })

    (cAlias)->(DbCloseArea())

Return aRes

/*=============================================================================================
Funcao.........:	GetcHawb
Descricao......:	Consulta o numero do embarque relacionado ao container
Autor..........:	Valter Carvalho
Criação........:	19/06/2020
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
Criação........:	08/05/2020
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
Descricao......:	Função que controla os eventos de tecla no browse de detalhes. 
Autor..........:	Valter Carvalho
Criação........:	08/05/2020
==============================================================================================*/
Static Function FValBrw()
	Local nRes := 2

    If VtLastKey() =  KEY_ESC
		nRes :=  0
    EndIf
return nRes




