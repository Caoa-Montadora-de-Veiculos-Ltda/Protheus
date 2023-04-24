#INCLUDE "Totvs.ch"

/*/{Protheus.doc} ZFATF018
//Função Transferência emergencial armazém Barueri
@author A.Carlos
@since 11/04/2023
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, Alias da tabela corrente
@param nReg, numeric, recno do registro
@param ALLTRIM(SuperGetMV("CMV_EST005",.T.,"11")) - Armazém Destino FDR Mudanca Emergencial  
@type function
/*/
User Function ZFATF018()
    Local lRet     := .t.
    Local aArea    := {SD2->(GetArea()),SF2->(GetArea()),GetArea()}
    Local _cCGCFil := FWSM0Util():GetSM0Data(,,{"M0_CGC"})[1,2]
    Local _cTPMud  := AllTrim(SuperGetMV( "CMV_WSR047"  ,,"016"))		//Tipo Pedido Mudança
    If _cCGCFil == SA1->A1_CGC .and. SF2->F2_TIPO == 'N' .And. (_cTPMud == VS1->VS1_XTPPED .OR. SC6->C6_OPER=='79' )
    
        Transf_ZFATF018()
    
    EndIf

    aEval(aArea,{|x| RestArea(x)})

Return lRet

//------------------------------------------------------------------------------------------
//
//
//
//------------------------------------------------------------------------------------------

Static Function Transf_ZFATF018()
    //Local _Obs       := ""
    //Local _cOper     := ""
    //Local _cOperTrans:= SuperGetMV("CMV_FAT005",.T.,"81")
    Local _cTesTrans := SuperGetMV("CMV_PEC037",.T.,"348")
    //Local _cArmPec   := ALLTRIM(SuperGetMV("MV_RESITE",.T.,"61")) 
    Local _cArmDes   := Space(02) //ALLTRIM(SuperGetMV("CMV_EST004",.T.,"90"))
    Local _cTesMud   := ALLTRIM(SuperGetMV("CMV_FAT013",.T.,"777"))
    Local _nOpcAuto  := 3
    Local _xInteg    := Space(01)    
    Local _aCab      := {}
    Local _aItens    := {}
    Local _aLinha    := {}
    Private lMsErroAuto := .F.
    Private lMsHelpAuto	:= .T.

    If ( cFilant = '2020012001' .AND. SC6->C6_TES = _cTesMud .AND. FWIsInCallStack("U_ZPECF013"))
       _cArmDes  := ALLTRIM(SuperGetMV("CMV_EST004",.T.,"90")) 
       //_xInteg   := ' ' 
    else
       _cArmDes  := ALLTRIM(SuperGetMV("CMV_EST005",.T.,"11")) 
       _xInteg   := 'X' 
    EndIf
   
    SD2->(DbSetOrder(3))
    SD2->(DbSeek(xFilial('SD2') + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA,.T.,.F. ))
    
    _cArmDes := PADR( _cArmDes ,LEN(SD2->D2_LOCAL)) 
	
    //Cabecalho
    //***********************************************************
    
    DbSelectArea('SA2')
    SA2->(DbSetOrder(3))
    SA2->(DbSeek(xFilial('SA2') + SA1->A1_CGC))

    Aadd(_aCab,{"F1_TIPO"    , 'N'                 , NIL })
    Aadd(_aCab,{"F1_FORMUL"  , SF2->F2_FORMUL      , NIL })
    Aadd(_aCab,{"F1_DOC"     , SF2->F2_DOC         , NIL })
    Aadd(_aCab,{"F1_SERIE"   , SF2->F2_SERIE       , NIL })
    Aadd(_aCab,{"F1_EMISSAO" , SF2->F2_EMISSAO     , NIL })
    Aadd(_aCab,{"F1_DTDIGIT" , Date()              , NIL })
    Aadd(_aCab,{"F1_FORNECE" , SA2->A2_COD         , NIL })
    Aadd(_aCab,{"F1_LOJA"    , SA2->A2_LOJA        , NIL })
    Aadd(_aCab,{"F1_ESPECIE" , "NFE"               , NIL })
    Aadd(_aCab,{"F1_MOEDA"   , SF2->F2_MOEDA       , NIL })
    Aadd(_aCab,{"F1_XINTEG"  , _xInteg             , NIL })    
    //*******************************************************************
    While SD2->(!EOF() ) .and. SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) == SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)
        
        _aLinha   := {}
                
        DbSelectArea('SB1')
        DbSetOrder(1)
        SB1->(DbSeek(xFilial('SB1')+SD2->D2_COD))
        fCriaArm(_cArmDes, SD2->D2_COD )
        
        Aadd(_aLinha,{"D1_ITEM"  , SD2->D2_ITEM   , NIL })
        Aadd(_aLinha,{"D1_COD"   , SD2->D2_COD    , NIL })
        Aadd(_aLinha,{"D1_UM"    , SD2->D2_UM     , NIL })
        Aadd(_aLinha,{"D1_QUANT" , SD2->D2_QUANT  , NIL })
        Aadd(_aLinha,{"D1_VUNIT" , SD2->D2_PRCVEN , NIL })
        Aadd(_aLinha,{"D1_TOTAL" , SD2->D2_TOTAL  , NIL })
        Aadd(_aLinha,{"D1_TES"   , _cTesTrans     , NIL })
        Aadd(_aLinha,{"D1_LOCAL" , _cArmDes       , NIL })
        
        AADD(_aItens,_aLinha)
        
        SD2->(DbSkip())

    EndDo           

    If Len(_aItens) > 0
			
        lMsErroAuto 	:= .F.
        lMsHelpAuto		:= .T.
      
        MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},_aCab, _aItens, _nOpcAuto, {}, {})
      
        If lMsErroAuto
            Mostraerro()
            _cErro := "Problemas no execauto MATA261, Nota Fiscal TOTVS!" 
        ENDIF
    ENDIF

Return

//*****************************************************************************
//Verificar se existe saldo inicial na SB2, se não tiver cria saldo para o 
// armazem e produto
//
//*****************************************************************************
Static Function fCriaArm(cArmazem,cProduto)
    Local aArea := GetArea()
    Local lRet := .T.
    
    DbSelectArea('NNR')
    NNR->(DbSetOrder(1))
    if !NNR->(DbSeek(FWxFilial("SB2") + cArmazem ))
        lRet := .F.
    EndIf
	
	DBSELECTAREA( "SB2" )
    SB2->(DbSetOrder(1))
	
    If !SB2->(DbSeek(FWxFilial("SB2")+PadR(cProduto, TamSx3('B2_COD') [1])+PadR(NNR->NNR_CODIGO,TamSx3('B2_LOCAL') [1])))
		CriaSB2(Alltrim(cProduto),Alltrim(NNR->NNR_CODIGO))
	EndIf
	
    RestArea(aArea)
Return lRet

	
User Function ValSC6SALDO(cNum,cCodcli,cLoja)
    Local aArea     := GetArea()
    Local aAreaSC6  := GetArea("SC6")
    Local lRet      := .T.
    Local cProduto  := ""
    Local nQuant    := 0
    Local cLocal    := ""
    Local cItem     := 1
    Local _cCGCFil  := FWSM0Util():GetSM0Data(,,{"M0_CGC"})[1,2]
    Local cCgcCliente := ""
    Default cNum    := ""
    
    DbSelectArea('SA1')
    SA1->(dBSetOrder(1))
    SA1->(DbSeek(xFilial('SA1') + cCodCli + cLoja))
    
    cCgcCliente := SA1->A1_CGC
    
    If _cCGCFil == cCgcCliente  .and. alltrim(SC5->C5_TIPO) == 'N' 
    
        DbSelectArea("SC6")
        SC6->(DbSetOrder(1))
        cItem := Strzero(1,len(SC6->C6_ITEM))
        
        SC6->(DbSeek(xFilial("SC6") + cNUm + cItem ,.t. ))
        
        While !SC6->(Eof()) .and. xFilial("SC6") + cNUm  == SC6->C6_FILIAL + SC6->C6_NUM 
            
            cProduto := SC6->C6_PRODUTO
            nQuant   := SC6->C6_QTDVEN
            cLocal   := SC6->C6_LOCAL

            if !ValSaldo(cProduto,nQuant,cLocal)
                lRet := .F.
                MSGALERT( " Não possui Saldo para o iTem:" + cProduto, "Abortar" )
                EXIT
            EndIf

            SC6->(DbSkip())
        EndDo
    EndIf
    
    RestArea(aAreaSC6)
    RestArea(aArea)

Return lRet
    


Static Function ValSaldo(cProduto,nQuant,cLocal)
    
    Local _lRet := .T.
    Local nSaldoAtu := 0
    Local aArea := GetArea()
    
    Default cProduto := ""
    Default nQuant   := 0
    Default cLocal   := ""
    
    DbSelectArea("SB2")
    SB2->(DbSetOrder(1))
	If SB2->(DbSeek(FWxFilial("SB2") + cProduto + cLocal))

		nSaldoAtu := SB2->(SaldoSb2())
		If nQuant > nSaldoAtu
			_lRet := .F.
        else
            _lRet := .T.
		EndIf
    else
        _lRet := .F.
    EndIf

    RestArea(aArea)

Return _lRet
