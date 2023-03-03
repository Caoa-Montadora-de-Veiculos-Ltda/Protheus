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

Default _cCodProd   := ""
Default _cLocal     := ""
Default _cAnoMod    := ""
Default _lMsg       := .F.

Begin Sequence
    If Empty(_cCodProd)
        Aadd(_aMsgErro, {"ZGENCST01","Não informado código do produto, não será calculado o custo do Produto !"})
        Break
    EndIF
    _nCusto := ZGENCSTPRD(_cCodProd, _cLocal, _cAnoMod, @_aMsgErro)
End Sequence

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
/*/{Protheus.doc} ZGENCSTPRD
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

Static Function ZGENCSTPRD(_cCodProd, _cLocal, _cAnoMod, _aMsgErro)
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
    Aadd(_aMsgErro, {"ZGENCST02","Não calculado custo pela tabela de Preços Veiculos (VVP), código do produto"+_cCodProd+If(!Empty(_cLocal)," Local"+_cLocal,"")+" ano fab/mod "+_cAnoMod+" !"})
    //Caso não encontrou na VVP Verificar custo no SB1
	If SB1->( dbSeek( xFilial("SB1")+_cCodProd ) ) .and. SB1->B1_CUSTD > 0
		_nCustoRet := SB1->B1_CUSTD 
        Break
    Endif
    Aadd(_aMsgErro, {"ZGENCST02","Não calculado custo pela tabela de Produtos (SB1), código do produto"+_cCodProd+If(!Empty(_cLocal)," Local"+_cLocal,"")+" ano fab/mod "+_cAnoMod+" !"})
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
    Aadd(_aMsgErro, {"ZGENCST02","Não calculado custo pela tabela de Saldos (SB2), código do produto"+_cCodProd+If(!Empty(_cLocal)," Local"+_cLocal,"")+" ano fab/mod "+_cAnoMod+" !"})
End Begin
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _nCustoRet

