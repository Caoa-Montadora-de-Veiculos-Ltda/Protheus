#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

/*=====================================================================================
Programa.:              EICOR100
Autor....:              CAOA - Valter Carvalho
Data.....:              17/03/2020
Descricao / Objetivo:   Efetua ajustes no conteúdo do arquivo Envio de P.O.
Doc. Origem:
Solicitante:            Evandro Mariano
Uso......:              EICOR100          
=====================================================================================*/
User Function ZEICF001()
    Local cProcImp  := ""
    Local cCodCli   := ""
    Local cInvoice  := ""

	Begin Sequence

        ConOut(" EICOR100,ZEICF001->" + ParamIxb)

		Do Case

		Case ParamIxb $ "ANTES_CRIA_GIP_LITE"           // altera o tamanho maximo das colunas do arquivo

            nTamReg   := 304                            // de 300 para 304

		Case ParamIxb $ "CAPI" // |ITEA|ITEA_VALORES

            cProcImp    := SW6->W6_HAWB   // SW2->W2_PO_NUM ALTERADO EM 11/06
            cCodCli     := SW6->W6_HAWB      //PadR(Substr(cTexto,20,20), 30, " ")

            // Altera alinha que vai para o arquivo
            cTexto := Stuff(cTexto, 020, 020, cCodCli)                  // coloca o novo codigo
            cTexto := Stuff(cTexto, 005, 015, cProcImp)                 // codigo do processo

		Case ParamIxb $ "ITEA"

            cProcImp    := SW6->W6_HAWB   // SW2->W2_PO_NUM  ALTERADO EM 11/06

            // Altera alinha que vai para o arquivo           
			if Vazio(SW7->W7_XPESOD) = .F.
                cTexto := Stuff(cTexto, 057, 012, zAjNum(SW7->W7_XPESOD, 12, 05 ) )                  // peso liquido total
			EndIf
            cTexto := Stuff(cTexto, 020, 020, getCodForn())                  // coloca o codigo do produto que está na sa5
            cTexto := Stuff(cTexto, 005, 015, cProcImp)                             // codigo do processo

		Case ParamIxb $ "CAP2|CAP3|ITEB|ITEC"

            cProcImp    := SW6->W6_HAWB   // SW2->W2_PO_NUM   ALTERADO EM 11/06

            // Altera alinha que vai para o arquivo
            cTexto      := Stuff(cTexto, 005, 015, cProcImp)      // codigo do processo

		Case ParamIxb $ "DPNN"

            cProcImp    := SW6->W6_HAWB   // SW2->W2_PO_NUM
            cTexto      := Stuff(cTexto, 005, 015, cProcImp)      // codigo do processo

		Case ParamIxb $ "ITED_FINAL"

            cProcImp    := SW6->W6_HAWB   // SW2->W2_PO_NUM  ALTERADO EM 11/06
            cPedComp    := SW2->W2_PO_NUM
            cInvoice    := SW9->W9_INVOICE

            // Altera alinha que vai para o arquivo
            cTexto := Stuff(cTexto, 301, 303, SW8->W8_NVE)    // NVE
            cTexto := Stuff(cTexto, 241, 030, cInvoice)       // invoice
            cTexto := Stuff(cTexto, 039, 015, cPedComp)       // ped compra
            cTexto := Stuff(cTexto, 005, 015, cProcImp)       // codigo do processo

            
		Case ParamIxb $ "ANTES_CRIA_ARQ" // Editar o nome do arquivo gerado

			If  cFase = 2   // geracao do arquivo embarque
            
            FWMsgRun(, {|| zExpArq() },"", "Preparando exportação do arquivo..." )

			EndIf

		EndCase

	End Sequence

Return


/*=====================================================================================
Programa.:              zExpArq
Autor....:              CAOA - Valter Carvalho
Data.....:              17/03/2020
Descricao / Objetivo:   Efetua a gravação do arquivo no desktop do usuario
Doc. Origem:
Solicitante:            Evandro Mariano
=====================================================================================
Static Function zExpArq()
    Local cTxtDesp  := ""
    Local cArq_Dest := ""
    Local nPeso := 0
    Local nQtIt := 0
    Local cMsg  := ""

    cArq_Dest := AllTrim(cCodigo ) + "_" + AllTrim(TRB->W6_HAWB) + "_" + dtos(date()) + "_" + StrTran(time(), ":", "") + ".txt"
               
    GIP_LITE->(DbGoTop())

	while GIP_LITE->(Eof()) = .F.
        
        cTxtDesp += Upper(GIP_LITE->giptexto) + CRLF

		if Substr(GIP_LITE->giptexto, 1, 4) == "ITEA"
            nPeso +=  Val(Substr(GIP_LITE->giptexto, 82, 12))

            nQtIt += 1
		EndIf

        GIP_LITE->(DbSkip())
	EndDo
    GIP_LITE->(DbGoTop())
    
    MemoWrite( strTran(GetTempPath(), "AppData\Local\Temp\", "desktop\") + cArq_Dest, cTxtDesp )

    cMsg := " O arquivo foi copiado para o sua área de trabalho: " + CRLF + CRLF + cArq_Dest + CRLF + CRLF
    cMsg += " Quantidade de itens: " + cValToChar(nQtIt)  + CRLF
    cMsg += " Peso total: " + Transform(nPeso, "@E 999999.99999")

    MsgInfo( cMsg , "ZEICF001()")

Return
*/

/*=====================================================================================
Programa.:              getCodForn
Autor....:              CAOA - Valter Carvalho
Data.....:              17/03/2020
Descricao / Objetivo:   pega o codigo do produto no fornecedor , contante na SA5
Doc. Origem:
Solicitante:            Evandro Mariano
Uso......:              
=====================================================================================*/
Static Function getCodForn()
    Local cRes      := ""

    Local cCodForn  := Posicione("SA5", 1, Xfilial("SA5") + SW2->W2_FORN + SW2->W2_FORLOJ + SW8->W8_COD_I, "A5_CODPRF")    // INDICE 01 SA5: A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO+A5_FABR+A5_FALOJA

	If Vazio(cCodForn) = .F.
        cRes := cCodForn
	Else
        //cRes := AllTrim(cCodOld)
        cRes := SW8->W8_COD_I
	EndIf

    cRes := PadR(cRes, 30, " ")  // 30 é o tamanho do campo que tem que ser gravado

Return cRes

Static Function zAjNum(nVl, nTam, nDec)
    Local cAux:= cValToCHar(nVl)

    // coloca ponto no fim, se nao houver
    cAux := Iif(At(".", cAux) = 0, cAux + ".", cAux)

    // adicionar a parte decimal
	while (Len(cAux) - At(".", cAux)) <> (nDec)
		If (Len(cAux) - At(".", cAux)) < 6
            cAux += "0"    
		Else
            cAux :=  Substr(cAux,1, Len(cAux)-1)
		EndIf
	EndDo

	While Len(cAux) < nTam -1
        cAux :=  "0" + cAux    
	EndDo

    cAux += "0"    

Return cAux


/*=====================================================================================
Programa.:              zExpArq
Autor....:              CAOA - Valter Carvalho
Data.....:              17/03/2020
Descricao / Objetivo:   Efetua a gravação do arquivo no desktop do usuario
                        As posicoes sao definidas no layout do despachante  GAP  xxxxxx
Doc. Origem:
Solicitante:            Evandro Mariano
===================================================================================== */
Static Function zExpArq()
    Local aParam    := {}
    Local nOrdIt    := 1
    Local aRetOrd   := {}
    Local i         := 0
    Local j         := 0
    Local aLn       := {}
    Local aIt       := {} 
    Local aPosIt    := {}  // {cCod, cNcm, cNve, cPosIni, cPosFim}
    Local cTxtDesp  := ""
    Local cArq_Dst  := ""
    Local nPeso     := 0
    Local nQtIt     := 0
    Local cMsg      := ""
    Local nLnItIni  := 0
    Local nLnItFim  := 0
    
    cArq_Dst  := AllTrim(cCodigo ) + "_" + AllTrim(TRB->W6_HAWB) + "_" + dtos(date()) + "_" + StrTran(time(), ":", "") + ".txt"
    cArq_Dst2 := AllTrim(cCodigo ) + "_" + AllTrim(TRB->W6_HAWB) + "_" + dtos(date()) + "_" + StrTran(time(), ":", "") + "_ordenado.txt"
               
    GIP_LITE->(DbGoTop())

	while GIP_LITE->(Eof()) = .F.
        
        Aadd(aLn, Upper(GIP_LITE->giptexto) + CRLF)

		if Substr(GIP_LITE->giptexto, 1, 4) == "ITEA"
            nPeso +=  Val(Substr(GIP_LITE->giptexto, 82, 12))

            nQtIt += 1
		EndIf

        GIP_LITE->(DbSkip())
	EndDo
    GIP_LITE->(DbGoTop())

    // gravar padrao antes de ordenar
    cTxtDesp := ""
    aEval(aLn, {|cLn| cTxtDesp += cLn})
    MemoWrite( GetTempPath() + cArq_Dst, cTxtDesp )


    // ordenacao dos itens por ncm e nve
	For i:=1 to Len(aLn)

        // linha inicial dos itens
		If Substr(aLn[i], 1, Len("ITEA")) = "ITEA" .and. nLnItIni = 0
            nLnItIni := i
		EndIf

        // linha final dos itens
		If Substr(aLn[i], 1, Len("AG4")) = "AG4" .and. nLnItFim = 0
            nLnItFim := i - 1
		EndIf

        aPosIt := {"", "", "", 0, 0}
        // {cCod, cNcm, cNve, cPosIni, cPosFim}
		If Substr(aLn[i], 1, Len("ITEA")) = "ITEA"
            
            aPosIt[1] := Substr(aLn[i], 035, 030) // cod
            aPosIt[2] := Substr(aLn[i], 139, 013) + Substr(aLn[i], 149, 003) // ncm + ex
            aPosIt[4] := i                        // linha_inicio_item      

            j := i + 1
			While (Substr(aLn[j], 1, Len("ITEA")) <> "ITEA") .AND. (Substr(aLn[j], 1, Len("AG4")) <> "AG4")

				If Substr(aLn[i], 1, Len("ITED")) = "ITED"
                    aPosIt[3] := Substr(aLn[j], 301, 3)      // cod_nve   
				EndIf

                aPosIt[5] := j                        // linha_inicio_item   

                j := j + 1
			EndDo

            Aadd(aIt, aPosIt)
		Endif
	Next


    Aadd( aParam, {3, "Ordem:", 1, {"Produto + NCM + NVE", "NCM + NVE + Produto"}, 90, "", .F.} )
    Aadd( aParam, {9, "Clicando em Cancelar não será feito nenhum ordenamento", 200, 7, .T.} )
	If ParamBox(aParam, "Informar a ordem itens:", aRetOrd, , , , , , , , 50, .T.)  = .T.
        nOrdIt := aRetOrd[1]

        // efetue a ordenacao   {cCod, cNcm, cNve, cPosIni, cPosFim}
		If nOrdIt = 1
            aSort(aIt, , , {|x, y| (x[1] + x[2] + x[3]) < (y[1] + y[2] + y[3])})
		Else
            aSort(aIt, , , {|x, y| (x[2] + x[3] + x[1]) < (y[2] + y[3] + y[1])})
		EndIf

        // montar o arquivo novo
        cTxtDesp := ""

		For i:=1 to nLnItIni -1
            cTxtDesp += aLn[i]
		Next

        //Insere o registro ipNN
        Aeval(geraIpnn(), {|cLn| cTxtDesp += cLn })

		For i:=1 to Len(aIt)
			For j := aIt[i, 4] to aIt[i, 5]

            // ajustar o numero do item
				If Substr(aLn[j], 1, Len("ITEA")) = "ITEA"
                    aLn[j] := Substr(aLn[j], 1, 261) + PadL(i, 4, "0")
                    aLn[j] := PadR(aLn[j], 300, " ") + CRLF
				EndIf

            cTxtDesp += aLn[j]
			Next
		Next

		For i:= nLnItFim + 1 to  Len(aLn)
            cTxtDesp += aLn[i]
		Next

	EndIf

    MemoWrite( strTran(GetTempPath(), "AppData\Local\Temp\", "desktop\") + cArq_Dst, cTxtDesp )

    cMsg := " O arquivo foi copiado para o sua área de trabalho: " + CRLF + CRLF + cArq_Dst + CRLF + CRLF
    cMsg += " Quantidade de itens: " + cValToChar(nQtIt)  + CRLF
    cMsg += " Peso total: " + Transform(nPeso, "@E 999999.99999")

    MsgInfo( cMsg , "ZEICF001()")

Return

Static Function geraIpnn()
    Local cQry      := GetNextAlias()
    Local cLn       := ""
    Local aArea     := Nil
    Local aIp       := {}
    Local i         := 1
    Local cmd       := ""

   // montar o registro Ipnn
    DbSelectArea("SW8")
    aArea := SW8->(GetArea())
    SW8->(DbSetOrder(1))  
    SW8->( DbSeek( Xfilial("SW8") + SW6->W6_HAWB))

    While SW8->W8_FILIAL + SW8->W8_HAWB == Xfilial("SW8") + SW6->W6_HAWB

        If Vazio(SW8->W8_XVIN) = .T.
            SW8->(DbSkip())
            Loop
        EndIf

        cLn := ""
        cLn += "IP" + PadL(i, 2, "0") + SW2->W2_PO_NUM
        cLn +=  " Part Number: " + SW8->W8_COD_I 
        cLn +=  " Chassi: " + SW8->W8_XVIN
        cLn +=  " Motor: " + SW8->W8_XLOTE
        cLn +=  " Opcional: " + SW8->W8_OPCION

        i:= Iif( i > 100, 1, i+1 )

        cmd =  " SELECT VVC_DESCRI FROM " + RetSqlName("VVC")
        cmd += " WHERE "
        cmd += "     D_E_L_E_T_ = ' ' "
        cmd += " AND VVC_FILIAL = '" + XFilial("VVC") + "' "
        cmd += " AND VVC_CORVEI = '" + SW8->W8_COREXT + "' "

        TcQuery cmd new alias (cQry)
        cLn +=  " Cor: " + Iif( Vazio((cQry)->VVC_DESCRI) = .T., " ", (cQry)->VVC_DESCRI )

        (cQry)->(DbCloseArea())

        Aadd(aIp, cLn + CRLF )
        SW8->(DbSkip())
    EndDo

    RestArea(aArea)
Return aIp
