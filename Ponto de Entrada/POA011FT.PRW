/*/{Protheus.doc} POA011FT
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	29/08/2022
@return  	NIL
@obs        Ponto de entrada POA011FT chamado pelo OFIXA011
@project
@history    Filtrar orçamentos em BO
*/
User Function POA011FT()
Local cAliasBO  := GetNextAlias()
Local _aArea    := GetArea()
Local aOrcBO    := {}
Local nI        := 0
Local _cQuery   := ""
Local _cFiltro  := ""

    IF IsInCallStack("U_ZPECF024")
        IF !( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
            RETURN Nil
        ENDIF
        _cFiltro:= "VS1_XBO='S'"
        _cQuery := " "
        _cQuery := " Select "
        _cQuery += " V1.VS1_NUMORC cBO FROM " + RetSqlName("VS3") + " V3 "
        _cQuery += " INNER JOIN " + RetSqlName("VS1") + " V1 "
        _cQuery += "     ON V1.VS1_FILIAL  = V3.VS3_FILIAL   "			
        _cQuery += "     AND V1.VS1_NUMORC = V3.VS3_NUMORC   "
        _cQuery += "     AND V1.VS1_XBO = 'S'                "
        _cQuery += "     AND V1.VS1_STATUS NOT IN ('C','X')  "
        _cQuery += "     AND V1.D_E_L_E_T_ = ' '             "
        _cQuery += "     WHERE V3.VS3_FILIAL = '" + xFilial("VS3") + "'" 
        _cQuery += "     AND V3.VS3_CODITE = '" + Alltrim(SB1->B1_COD) + "'"
        _cQuery += "     AND V3.D_E_L_E_T_ = ' '             "

        dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), cAliasBO, .T., .T. )

        (cAliasBO)->(DbGoTop())

        IF (cAliasBO)->(EOF())
            MsgInfo("Item não encontrado em BO!!!  Serão apresentados todos.", "[ ZPECF024 ] - Aviso" )
            //Return(lRet)
        EndIf

        While (cAliasBO)->(!EOF())
            Aadd(aOrcBO,Alltrim(cBO))
            (cAliasBO)->(DbSkip())
        End

        If (Select(cAliasBO) <> 0)
            dbSelectArea(cAliasBO)
            (cAliasBO)->(dbCloseArea())
        EndIf

        IF Len(aOrcBO) > 0 
            FOR nI := 1 to Len(aOrcBO)
                IF nI == 1
                    _cFiltro  += " AND (VS1_NUMORC="
                    _cFiltro  += "'"
                    _cFiltro  += aOrcBO[nI] += "' "
                ELSE
                //If nI < Len(aOrcBO) .AND. nI > 1
                    _cFiltro += "OR"
                    _cFiltro += " VS1_NUMORC='"
                    _cFiltro += aOrcBO[nI] += "' "
                EndIf
                If nI == Len(aOrcBO)
                    //_cFiltro  += " '"
                    _cFiltro += ")"
                EndIf
            Next
        ENDIF

    ENDIF

RestArea(_aArea)

Return(_cFiltro)
