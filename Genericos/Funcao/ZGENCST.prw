#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZGENCST
Rdmake 	Retornar valor de custo do produto
@class    	Nao Informado
@from       Nao Informado
@param      _cCodProd = Código Produto, _cLocal = Local do Produto (opcional Default Branco), _lMsg = Mostra mensagem (Opcional Default .F.)
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC - Denilso 
@single		10/08/2020
@version    Nao Informado
@since      Nao Informado  
@return    	_nCusto
@sample     Nao Informado
@obs        Funcionalidade baseada na ZFATF004 
@project    CAOA - Automatizar o processo de apontamento
@menu       Nao Informado
@history    

/*/

User Function ZGENCST(_cCodProd, _cLocal, _cAnoMod, _lMsg)
Local _aMsgErro     := {}
Local _cError       := ""
Local _nPos         := ""
Local _nCusto       := 0
Local _aArea 		:= GetArea()
Local _cEmpresa 	:= FWCodEmp()

Default _cCodProd   := ""
Default _cLocal     := ""
Default _cAnoMod    := ""
Default _lMsg       := .F.

If Empty(_cCodProd)
    Aadd(_aMsgErro, {"ZGENCST01","Não informado código do produto, não será calculado o custo do Produto !"})
    Break
EndIF

If _cEmpresa == "2010"
    If !Empty(_cAnoMod)
        _nCusto := ZCSTVEI(_cCodProd, _cLocal, _cAnoMod, @_aMsgErro)
    Else
        _nCusto := zEmp2010(_cCodProd)
    EndIf
Else
    _nCusto := zEmp2020(_cCodProd)
EndIf


If Len(_aMsgErro) > 0
    For _nPos := 1 To Len(_aMsgErro)
        _cError := _aMsgErro[_nPos,1]+" - "+_aMsgErro[_nPos,2]
        If _lMsg
       	    MSGInfo(_cError,"ATENCAO")
        EndIf
        Conout(_cError)
    Next _nPos   
EndIf
RestArea(_aArea)
Return _nCusto



//-------------------------------------------------------------------
/*/{Protheus.doc} ZCSTVEI
Rdmake 		Localizar valores para informação de custo no SB2   
@author 	DAC denilso.carvalho
@since 		10/08/2020
@version 	1.0
@param      cCodProd, _cLocal
			_aMsgErro	- Array onde consta os erros caso ocorra na leitura se o mesmo existir deve ser mandado como referência para retornar preenchido 
@obs 		Esta pesquisa esta de acordo com a ultima formatação montada no ZFATF004 para a formatação de Custos
            foi incluido a validação de quantidade e valor diferente de zero
/*/
//-------------------------------------------------------------------

Static Function ZCSTVEI(_cCodProd, _cLocal, _cAnoMod, _aMsgErro)
Local _cAliasPesq   := GetNextAlias()
Local _cWhere       := ""
Local _nCustoRet    := 0

Begin Sequence
    //Se tem ano e modelo verificar VVP
    VV2->(DbSetOrder(7))  //VV2_FILIAL+VV2_PRODUT
    If !Empty(_cAnoMod) .and. VV2->(DbSeek(xFilial('VV2')+_cCodProd)) 
        VVP->(DbSetOrder(1))    //VVP_FILIAL+VVP_CODMAR+VVP_MODVEI+VVP_SEGMOD+DTOS(VVP_DATPRC)
        BeginSql Alias _cAliasPesq	
   	        SELECT VVP.VVP_CUSTAB
	        FROM %Table:VVP%  VVP  
		    WHERE 	VVP.VVP_FILIAL 	= %xFilial:VVP%
			    AND VVP.VVP_CODMAR  = %Exp:VV2->VV2_CODMAR%
			    AND VVP.VVP_MODVEI  = %Exp:VV2->VV2_MODVEI%
			    AND VVP.VVP_SEGMOD  = %Exp:VV2->VV2_SEGMOD%
                AND VVP.VVP_FABMOD  = %Exp:_cAnoMod%
		        AND VVP.%notDel% 
                AND VVP.VVP_DATPRC = (  SELECT MAX(VVPB.VVP_DATPRC) 
                                        FROM %Table:VVP%  VVPB 
                                        WHERE  VVPB.VVP_FILIAL = %xFilial:VVP%
			                               AND VVPB.VVP_CODMAR = %Exp:VV2->VV2_CODMAR%
			                               AND VVPB.VVP_MODVEI  = %Exp:VV2->VV2_MODVEI%
			                               AND VVPB.VVP_SEGMOD  = %Exp:VV2->VV2_SEGMOD%
                                           AND VVPB.VVP_FABMOD  = %Exp:_cAnoMod%
                                           AND VVPB.%notDel% ) 
	    EndSQL

	    If (_cAliasPesq)->(!Eof())
            _nCustoRet := (_cAliasPesq)->VVP_CUSTAB
            Break
        EndIf
    EndIf
    Aadd(_aMsgErro, {"ZCSTVEI","Não calculado custo pela tabela de Preços Veiculos (VVP), código do produto"+_cCodProd+If(!Empty(_cLocal)," Local"+_cLocal,"")+" ano fab/mod "+_cAnoMod+" !"})
    //Caso não encontrou na VVP Verificar custo no SB1
	If SB1->( dbSeek( xFilial("SB1")+_cCodProd ) ) .and. SB1->B1_CUSTD > 0
		_nCustoRet := SB1->B1_CUSTD 
        Break
    Endif
    Aadd(_aMsgErro, {"ZCSTVEI","Não calculado custo pela tabela de Produtos (SB1), código do produto"+_cCodProd+If(!Empty(_cLocal)," Local"+_cLocal,"")+" ano fab/mod "+_cAnoMod+" !"})
    //Caso não localizou custo verificar no SB2
    If Select(_cAliasPesq) <> 0
	    (_cAliasPesq)->(DbCloseArea())
    EndIf
    If !Empty(_cLocal)
        _cWhere += "AND SB2.B2_LOCAL = '"+_cLocal+"'"
    EndIf
    _cWhere := "%" + _cWhere + "%"

    BeginSql Alias _cAliasPesq	
   	    SELECT SB2.B2_COD, 
               SUM(SB2.B2_VATU1) VALATUB2, 
               SUM(SB2.B2_QATU)  QTDEB2 	
	    FROM %Table:SB2%  SB2  
		WHERE 	SB2.B2_FILIAL 	= %xFilial:SB2%
			AND SB2.B2_COD 	    = %Exp:_cCodProd%
            AND SB2.B2_VATU1    > 0
            AND SB2.B2_QATU     > 0
            %Exp:_cWhere% 
		    AND SB2.%notDel% 
        GROUP BY SB2.B2_COD
	EndSQL
	//Não achou 
	If (_cAliasPesq)->(!Eof()) 
        _nCustoRet := 0
        While (_cAliasPesq)->(!Eof())
            _nCustoRet += (_cAliasPesq)->VALATUB2 / (_cAliasPesq)->QTDEB2 
            (_cAliasPesq)->(DbSkip())
        EndDo    
        Break
    Endif
    //Se não localizou guardar msg
    Aadd(_aMsgErro, {"ZCSTVEI","Não calculado custo pela tabela de Saldos (SB2), código do produto"+_cCodProd+If(!Empty(_cLocal)," Local"+_cLocal,"")+" ano fab/mod "+_cAnoMod+" !"})
End Begin
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return(_nCustoRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} zEmp2020
Rdmake 		Localizar valores para informação de custo de Peças   
@author 	Evandro Mariano
@since 		25/07/2023
@version 	1.0
@param      cCodProd, _cLocal
			_aMsgErro	- Array onde consta os erros caso ocorra na leitura se o mesmo existir deve ser mandado como referência para retornar preenchido 
@obs 		
/*/
//-------------------------------------------------------------------

Static Function zEmp2020(_cCodProd)

Local _cQry01	  	:= ""
Local _cAls01		:= GetNextAlias()
Local _cAls02		:= GetNextAlias()
Local _nCustoRet    := 0
Local _aAreaSB1		:= SB1->(GetArea())
Local _aAreaSB2		:= SB2->(GetArea())
Local _aAreaSB9		:= SB9->(GetArea())
Local _dDataFech    := GetMv("MV_ULMES")
Local _cLocal       := ""
Local _cLocHist     := "80"

/***************************************************************************************
Busca o custo no local de recebimento, geralmente no local 90.
Não encontrando no 90, faz a busca no primeiro local de recebimento Barueri (80)
***************************************************************************************/

SB1->(DBSetOrder(1))
If SB1->(MsSeek( FwxFilial("SB1") + AvKey(_cCodProd , "B1_COD") ))
    
    _cLocal := SB1->B1_LOCREC //busca o local de recebimento

    //1a Regra: ETAPA01 - Busca o custo do SB2 - Saldo Atual - Local de recebimento
    SB2->(DBSetOrder(1))
    If SB2->(MsSeek( FwxFilial("SB2") + AvKey(_cCodProd , "B2_COD") + AvKey(_cLocal , "B2_LOCAL")))
        If SB2->B2_CM1 > 0
            _nCustoRet := IIf( SB2->B2_CM1 <= 0, 0 , SB2->B2_CM1 ) 
        EndIf
    EndIf

    //1a Regra: ETAPA02 - Busca o custo do SB2 - Saldo Atual - Local Historico de recebimento
    If  _nCustoRet == 0 .And. ( AllTrim(_cLocHist) <> AllTrim(_cLocal) )
        SB2->(DBSetOrder(1))
        If SB2->(MsSeek( FwxFilial("SB2") + AvKey(_cCodProd , "B2_COD") + AvKey(_cLocHist , "B2_LOCAL")))
            If SB2->B2_CM1 > 0
                _nCustoRet := IIf( SB2->B2_CM1 <= 0, 0 , SB2->B2_CM1 ) 
            EndIf
        EndIf
    EndIf

    //2a Regra: ETAPA01 - Busca o custo do SB9 - Local de recebimento
    If  _nCustoRet == 0 
        SB9->(DBSetOrder(1))
        If SB9->( MsSeek( FwxFilial("SB9") + AvKey(_cCodProd , "B9_COD") + AvKey(_cLocal , "B9_LOCAL") + DToS(_dDataFech) ) )
            If SB9->B9_CM1  > 0
                _nCustoRet := IIf( SB9->B9_CM1 <= 0, 0 , SB9->B9_CM1 ) 
            EndIf
        EndIf
    EndIf

     //2a Regra: ETAPA02 - Busca o custo do SB9 - Local Historico de recebimento
    If  _nCustoRet == 0 .And. ( AllTrim(_cLocHist) <> AllTrim(_cLocal) )
        SB9->(DBSetOrder(1))
        If SB9->( MsSeek( FwxFilial("SB9") + AvKey(_cCodProd , "B9_COD") + AvKey(_cLocHist , "B9_LOCAL") + DToS(_dDataFech) ) )
            If SB9->B9_CM1  > 0
                _nCustoRet := IIf( SB9->B9_CM1 <= 0, 0 , SB9->B9_CM1 ) 
            EndIf
        EndIf
    EndIf

    //3a Regra: Busca o custo do SD1 - Nota Fiscal - Local de recebimento
    If  _nCustoRet == 0 
        If Select( (_cAls01) ) > 0
            (_cAls01)->(DbCloseArea())
        EndIf

        //1a - Etada - Busca nota fiscal de entrada (Compra)
        _cQry01 := "	"
        _cQry01 += " SELECT SD1.D1_COD, SD1.D1_LOCAL, SD1.D1_CUSTO, SD1.D1_QUANT, SD1.D1_DTDIGIT, SD1.R_E_C_N_O_ "              + CRLF
        _cQry01 += " FROM " +  RetSQLName("SD1") +" SD1 "                                                                       + CRLF
        _cQry01 += "    LEFT JOIN " +  RetSQLName("SF4") +" SF4  "                                                              + CRLF
        _cQry01 += " 	ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "' "                                                         + CRLF
        _cQry01 += " 	AND SF4.F4_CODIGO = SD1.D1_TES "                                                                        + CRLF
        _cQry01 += " 	AND SF4.F4_ESTOQUE = 'S' "                                                                              + CRLF
        _cQry01 += " 	AND SF4.D_E_L_E_T_ = ' '  "                                                                             + CRLF
        _cQry01 += " WHERE SD1.D1_FILIAL = '" + FWxFilial('SD1') + "' "                                                         + CRLF
        _cQry01 += " AND SD1.D1_COD = '" + _cCodProd + "' "                                                                     + CRLF
        _cQry01 += " AND SD1.D1_LOCAL = '" + _cLocal + "' "                                                                     + CRLF
        _cQry01 += " AND SD1.D1_TIPO = 'N' "                                                                                    + CRLF
        _cQry01 += " AND SD1.D_E_L_E_T_ = ' '  "                                                                                + CRLF
        _cQry01 += " ORDER BY SD1.D1_DTDIGIT, SD1.R_E_C_N_O_ DESC "                                                             + CRLF

        // Executa a consulta.
        DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQry01), _cAls01, .T., .T. )

        DbSelectArea((_cAls01))
        (_cAls01)->(dbGoTop())

        If !(_cAls01)->(EoF())

            If Select( (_cAls02) ) > 0
                (_cAls02)->(DbCloseArea())
            EndIf

            //2a - Etada - Busca nota fiscal de complemento de frete
            _cQry02 := "	"
            _cQry02 += " SELECT SD1.D1_COD, SD1.D1_LOCAL, SD1.D1_CUSTO, SD1.D1_QUANT, SD1.D1_DTDIGIT, SD1.R_E_C_N_O_  "         + CRLF
            _cQry02 += " FROM " +  RetSQLName("SD1") +" SD1 "                                                                   + CRLF
            _cQry02 += "    LEFT JOIN " +  RetSQLName("SF4") +" SF4  "                                                          + CRLF
            _cQry02 += " 	ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "' "                                                     + CRLF
            _cQry02 += " 	AND SF4.F4_CODIGO = SD1.D1_TES "                                                                    + CRLF
            _cQry02 += " 	AND SF4.F4_ESTOQUE = 'S' "                                                                          + CRLF
            _cQry02 += " 	AND SF4.D_E_L_E_T_ = ' '  "                                                                         + CRLF
            _cQry02 += " WHERE SD1.D1_FILIAL = '" + FWxFilial('SD1') + "' "                                                     + CRLF
            _cQry02 += " AND SD1.D1_COD = '" + _cCodProd + "' "                                                                 + CRLF
            _cQry02 += " AND SD1.D1_LOCAL = '" + _cLocal + "' "                                                                 + CRLF
            _cQry02 += " AND SD1.D1_TIPO = 'C' "                                                                                + CRLF
            _cQry02 += " AND SD1.D_E_L_E_T_ = ' '  "                                                                            + CRLF
            _cQry02 += " ORDER BY SD1.D1_DTDIGIT, SD1.R_E_C_N_O_  DESC "                                                        + CRLF

            // Executa a consulta.
            DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQry02), _cAls02, .T., .T. )

            DbSelectArea((_cAls02))
            (_cAls02)->(dbGoTop())

            //3a - Etada - Encontrou nota de complemento de frete considera o custo dela, não encontrou considera a de compra.
            If !(_cAls02)->(EoF())
                _nCustoRet := ( ( (_cAls01)->D1_CUSTO + (_cAls02)->D1_CUSTO ) / ( (_cAls01)->D1_QUANT + (_cAls02)->D1_QUANT ) )
            Else
                _nCustoRet := ( (_cAls01)->D1_CUSTO / (_cAls01)->D1_QUANT )
            EndIf
            (_cAls02)->(DbCloseArea())
        EndIf 

        (_cAls01)->(DbCloseArea())
    EndIf

    //3a Regra: Busca o custo do SD1 - Nota Fiscal - Local de recebimento Historico
    If  _nCustoRet == 0 .And. ( AllTrim(_cLocHist) <> AllTrim(_cLocal) )
        
        If Select( (_cAls01) ) > 0
            (_cAls01)->(DbCloseArea())
        EndIf

        //1a - Etada - Busca nota fiscal de entrada (Compra)
        _cQry01 := " "
        _cQry01 += " SELECT SD1.D1_COD, SD1.D1_LOCAL, SD1.D1_CUSTO, SD1.D1_QUANT, SD1.D1_DTDIGIT, SD1.R_E_C_N_O_ "              + CRLF
        _cQry01 += " FROM " +  RetSQLName("SD1") +" SD1 "                                                                       + CRLF
        _cQry01 += "    LEFT JOIN " +  RetSQLName("SF4") +" SF4  "                                                              + CRLF
        _cQry01 += " 	ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "' "                                                         + CRLF
        _cQry01 += " 	AND SF4.F4_CODIGO = SD1.D1_TES "                                                                        + CRLF
        _cQry01 += " 	AND SF4.F4_ESTOQUE = 'S' "                                                                              + CRLF
        _cQry01 += " 	AND SF4.D_E_L_E_T_ = ' '  "                                                                             + CRLF
        _cQry01 += " WHERE SD1.D1_FILIAL = '" + FWxFilial('SD1') + "' "                                                         + CRLF
        _cQry01 += " AND SD1.D1_COD = '" + _cCodProd + "' "                                                                     + CRLF
        _cQry01 += " AND SD1.D1_LOCAL = '" + _cLocHist + "' "                                                                   + CRLF
        _cQry01 += " AND SD1.D1_TIPO = 'N' "                                                                                    + CRLF
        _cQry01 += " AND SD1.D_E_L_E_T_ = ' '  "                                                                                + CRLF
        _cQry01 += " ORDER BY SD1.D1_DTDIGIT, SD1.R_E_C_N_O_ DESC "                                                             + CRLF

        // Executa a consulta.
        DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQry01), _cAls01, .T., .T. )

        DbSelectArea((_cAls01))
        (_cAls01)->(dbGoTop())

        If !(_cAls01)->(EoF())

            If Select( (_cAls02) ) > 0
                (_cAls02)->(DbCloseArea())
            EndIf

            //2a - Etada - Busca nota fiscal de complemento de frete
            _cQry02 := " "
            _cQry02 += " SELECT SD1.D1_COD, SD1.D1_LOCAL, SD1.D1_CUSTO, SD1.D1_QUANT, SD1.D1_DTDIGIT, SD1.R_E_C_N_O_  "         + CRLF
            _cQry02 += " FROM " +  RetSQLName("SD1") +" SD1 "                                                                   + CRLF
            _cQry02 += "    LEFT JOIN " +  RetSQLName("SF4") +" SF4  "                                                          + CRLF
            _cQry02 += " 	ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "' "                                                     + CRLF
            _cQry02 += " 	AND SF4.F4_CODIGO = SD1.D1_TES "                                                                    + CRLF
            _cQry02 += " 	AND SF4.F4_ESTOQUE = 'S' "                                                                          + CRLF
            _cQry02 += " 	AND SF4.D_E_L_E_T_ = ' '  "                                                                         + CRLF
            _cQry02 += " WHERE SD1.D1_FILIAL = '" + FWxFilial('SD1') + "' "                                                     + CRLF
            _cQry02 += " AND SD1.D1_COD = '" + _cCodProd + "' "                                                                 + CRLF
            _cQry02 += " AND SD1.D1_LOCAL = '" + _cLocHist + "' "                                                               + CRLF
            _cQry02 += " AND SD1.D1_TIPO = 'C' "                                                                                + CRLF
            _cQry02 += " AND SD1.D_E_L_E_T_ = ' '  "                                                                            + CRLF
            _cQry02 += " ORDER BY SD1.D1_DTDIGIT, SD1.R_E_C_N_O_  DESC "                                                        + CRLF

            // Executa a consulta.
            DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQry02), _cAls02, .T., .T. )

            DbSelectArea((_cAls02))
            (_cAls02)->(dbGoTop())

            //3a - Etada - Encontrou nota de complemento de frete considera o custo dela, não encontrou considera a de compra.
            If !(_cAls02)->(EoF())
                _nCustoRet := ( ( (_cAls01)->D1_CUSTO + (_cAls02)->D1_CUSTO ) / ( (_cAls01)->D1_QUANT + (_cAls02)->D1_QUANT ) )
            Else
                _nCustoRet := ( (_cAls01)->D1_CUSTO / (_cAls01)->D1_QUANT )
            EndIf
            (_cAls02)->(DbCloseArea())
        EndIf 

        (_cAls01)->(DbCloseArea())
    EndIf
EndIf

//Caso o custo seja negativo, retorna 0
_nCustoRet := IIf( _nCustoRet <= 0, 0, _nCustoRet)

RestArea(_aAreaSB1)
RestArea(_aAreaSB2)
RestArea(_aAreaSB9)

Return( _nCustoRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} zEmp2010
Rdmake 		Localizar valores para informação de custo de Peças   
@author 	Evandro Mariano
@since 		25/07/2023
@version 	1.0
@param      cCodProd, _cLocal
			_aMsgErro	- Array onde consta os erros caso ocorra na leitura se o mesmo existir deve ser mandado como referência para retornar preenchido 
@obs 		
/*/
//-------------------------------------------------------------------

Static Function zEmp2010(_cCodProd)

Local _cQry01	  	:= ""
Local _cAls01		:= GetNextAlias()
Local _nCustoRet    := 0
Local _aAreaSB1		:= SB1->(GetArea())

SB1->(DBSetOrder(1))
If SB1->(MsSeek( FwxFilial("SB1") + AvKey(_cCodProd , "B1_COD") ))
    
        If Select( (_cAls01) ) > 0
            (_cAls01)->(DbCloseArea())
        EndIf

        //1a - Etada - Busca nota fiscal de entrada (Compra)
        _cQry01 := "	"
        _cQry01 += " SELECT SB2.B2_COD, SUM(SB2.B2_VATU1) VALOR, SUM(SB2.B2_QATU) QTDE "            + CRLF
        _cQry01 += " FROM " +  RetSQLName("SB2") +" SB2 "                                           + CRLF
        _cQry02 += " WHERE SB2.B2_FILIAL = '" + FWxFilial('SB2') + "' "                             + CRLF
        _cQry01 += " AND SB2.B2_COD = '" + _cCodProd + "' "                                         + CRLF
        _cQry01 += " AND SB2.D_E_L_E_T_ = ' ' "                                                     + CRLF
        _cQry01 += " GROUP BY SB2.B2_COD "                                                          + CRLF

        // Executa a consulta.
        DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQry01), _cAls01, .T., .T. )

        DbSelectArea((_cAls01))
        (_cAls01)->(dbGoTop())

        If !(_cAls01)->(EoF())
           If ( (_cAls01)->VALOR / (_cAls01)->QTDE ) < 0
			    _nCustoRet	:= 0
			Else
			    _nCustoRet	:= ((_cAls01)->VALOR/(_cAls01)->QTDE)
			EndIF
        EndIf 

        (_cAls01)->(DbCloseArea())
EndIf

//Caso o custo seja negativo, retorna 0
_nCustoRet := IIf( _nCustoRet <= 0, 0, _nCustoRet)

RestArea(_aAreaSB1)

Return(_nCustoRet)

