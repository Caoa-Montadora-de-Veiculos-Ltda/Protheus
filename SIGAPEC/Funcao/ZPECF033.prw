#Include "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "TOTVS.ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWBROWSE.CH"
#Include "FWMVCDEF.CH"

#define CRLF chr(13) + chr(10)  

/*/{Protheus.doc} ZPECF033
KARDEX ENTRADA E SAIDA 
@author     DAC - Denilso 
@since      24/06/2023
@version    1.0
@obs        Tela esta relacionada com a funcionalidade ZPECF030 a mesma poderá ser colocada também no menu com a chamada ZPECF032 caso seja necessário adaptar parametros para a procura  
/*/

User Function ZPECF033(_cCodProd)
Local _aArea        := GetArea()
Local _cCodProdDe   := Space(Len(SB1->B1_COD))
Local _cCodProdAte  := Space(Len(SB1->B1_COD))
Local _dDataDe      := CtoD(Space(08))
Local _dDataAte     := Date()
Local _cCadastro    := OemToAnsi("Kardex Entrada e Saida")   
Local _cTitle  	    := OemToAnsi("Kardex Entrada e Saida")   
Local _aSays	    := {}
Local _aButtons	    := {}
Local _aPar    	    := {}
Local _aRet    	    := {}
Local _nRet			:= 0
Default _cCodProd   := Space(Len(SB1->B1_COD))

Begin Sequence 
    //quando não informado cod produto solicitar de / ate
    If Empty(_cCodProd)
    	aAdd(_aPar,{1,OemToAnsi("Produto de     : ") ,_cCodProdDe			,"@!"		,".T."	,"SB1" 	,".T."	,100,.F.}) 
    	aAdd(_aPar,{1,OemToAnsi("Produto ate    : ") ,_cCodProdAte		    ,"@!"		,".T."	,"SB1"	,".T."	,100,.T.}) 
   /*
    Else 
        _cCodProd := AllTrim(_cCodProd)
        _cCodProd += Space(Len(SB1->B1_COD) - Len(_cCodProd) )

        _cCodProdDe  := _cCodProd
        _cCodProdAte := _cCodProd
     	aAdd(_aPar,{1,OemToAnsi("Produto de     : ") ,_cCodProdDe			,"@!"		,".T."	,"SB1" 	,".T."	,100,.T.}) 
    	aAdd(_aPar,{1,OemToAnsi("Produto ate    : ") ,_cCodProdAte		    ,"@!"		,".T."	,"SB1"	,".T."	,100,.T.}) 
    */
    Endif 
	aAdd(_aPar,{1,OemToAnsi("Data Inicial   : ") ,_dDataDe		    ,"@D"		,".T."	,	    ,".T."	,100,.F.}) 
	aAdd(_aPar,{1,OemToAnsi("Data Final     : ") ,_dDataAte		    ,"@D"		,".T."	,	    ,".T."	,100,.T.}) 
//	aAdd(_aPar,{3,OemToAnsi("Saldo Inicial") ,2 ,{"1=Sim","2=Não"}	,80,"",.T.})  //Saldo Inicial / 1=Sim 2=Não

	// Monta Tela principal
	aAdd(_aSays,OemToAnsi("Este Programa tem  como objetivo mostrar o Kardex Entrada e Saida.")) 
	//aAdd(_aSays,OemToAnsi("Caso seja escolhido o parametro Saldo Inicial igual a [Sim], desperezara.")) 
	//aAdd(_aSays,OemToAnsi("a data inicial e final trazendo todas as datas de entradas e saidas.")) 

	aAdd(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
	aAdd(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
	aAdd(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,"ZPECF033",.T.,.T.) 	}})

	FormBatch( _cCadastro, _aSays, _aButtons )
	If _nRet <> 1
		Break
	Endif
	If Len(_aRet) == 0
		Help( , ,OemToAnsi("Atenção"),,OemToAnsi("Necessário informar os parâmetros"),4,1)   
		Break 
	Endif
	FwMsgRun(,{ || ZPECF033PR(_aRet, _cCodProd ) }, "Selecionando dados para a Montagem Kardex Entrada e Saida", "Aguarde...")  
    RestArea(_aArea)
End Sequence
Return Nil



Static Function ZPECF033PR(_aRet, _cCodProd )
Local _cCodProdDe   := If(Empty(_cCodProd), _aRet[1], _cCodProd)
Local _cCodProdAte  := If(Empty(_cCodProd), _aRet[2], _cCodProd)
Local _dDataDe      := If(Empty(_cCodProd), _aRet[3], _aRet[1])
Local _dDataAte     := If(Empty(_cCodProd), _aRet[4], _aRet[2])
Local _lSaldoIni    := .F. //_aRet[5] == 1
Local _cAliasPesq   //:= GetNextAlias()
Local _cWhere       := ""
Local _nPos
Local _aBrwCab
Local _aStru
Local _oTable
Local _aCpoCab
Local _cQuery

   
Begin Sequence
    //Caso tenha optado por saldo inicial devera trazer todo o movimento
    If _lSaldoIni
        _dDataDe  := CtoD(Space(08))
        _dDataAte := Date()
    Endif
    _aCpoCab := {}
    Aadd( _aCpoCab, {"SB1", "CODPROD"  , "C","Produto"         , Len(SB1->B1_COD)   , 0, "@!",.F.})
    Aadd( _aCpoCab, {"SB1", "DESCRIC"  , "C","Descrição"       , Len(SB1->B1_DESC)  , 0, "@!",.F.})
   	aAdd( _aCpoCab, {"SD2", "EMISSAO"  , "D","Emissão"         , 08, 0, "@D",.T.})
   	aAdd( _aCpoCab, {"SB1", "LOCAL"    , "C","Armazém"         , Len(SB1->B1_LOCPAD)   , 0, "@!",.T.})
   	aAdd( _aCpoCab, {"SD2", "DOC"      , "C","Nota Fiscal"     , Len(SD2->D2_DOC)      , 0, "@!",.T.})
   	aAdd( _aCpoCab, {"SD2", "SERIE"    , "C","Serie"           , Len(SD2->D2_SERIE)    , 0, "@!",.T.})
   	aAdd( _aCpoCab, {"SD2", "TIPO"     , "C","Entrada/Saida"   , 007                   , 0, "@!",.T.})
   	aAdd( _aCpoCab, {"SD2", "TES"      , "C","TES"             , Len(SD2->D2_TES)      , 0, "@!",.T.})
   	aAdd( _aCpoCab, {"SD2", "CFOP"     , "C","CFOP"            , Len(SD2->D2_CF)      , 0, "@!",.T.})
    _aTamSx3 := TamSX3("D2_QUANT")
   	aAdd( _aCpoCab, {"SD2", "QTDE_MOV" , _aTamSx3[03],"Qtde Movimentada"   , _aTamSx3[01]   , _aTamSx3[02], PesqPict("SD2","D2_QUANT"),.T.})
    _aTamSx3 := TamSX3("D2_TOTAL")
   	aAdd( _aCpoCab, {"SD2", "CUSTO_TOT", _aTamSx3[03],"Custo Total"  , _aTamSx3[01]   , _aTamSx3[02], PesqPict("SD2","D2_TOTAL"),.T.})
   	aAdd( _aCpoCab, {"SD2", "PENTREGA" , "D","Previsão Entrega" , 008                  , 0, "@D",.T.})
   	aAdd( _aCpoCab, {"SA1", "COD_CF"   , "C","Cod. Fornec./Cliente" , Len(SA1->A1_COD) , 0, "@!",.F.})
   	aAdd( _aCpoCab, {"SA1", "LOJA_CF"  , "C","Cod. Fornec./Cliente" , Len(SA1->A1_LOJA) , 0, "@!",.F.})
   	aAdd( _aCpoCab, {"SA1", "NOME_CF"   , "C","Fornecedor/Cliente"   , Len(SA1->A1_NOME)  , 0, "@!",.T.})
   	aAdd( _aCpoCab, {"SF4", "DESC_CFOP" , "C","Descrição CFOP"       , Len(SF4->F4_TEXTO) , 0, "@!",.T.})
 	aAdd( _aCpoCab, {"SD2","NRECNO"     , "N","Recno NF"            , 10, 0, "@!",.F. /*não ncluir no browse*/})
   	aAdd( _aCpoCab, {"SD2", "SALDO", _aTamSx3[03],"Saldo"  , _aTamSx3[01]   , _aTamSx3[02], PesqPict("SD2","D2_TOTAL"),.F.})

    _aBrwCab    := {}
    _aStru      := {}  //Estrutura do Banco
    For _nPos := 1 To Len(_aCpoCab)
        If _aCpoCab[_nPos,Len(_aCpoCab[_nPos])]  //Valida se a coluna irá para o Browse
            Aadd(_aBrwCab,{ _aCpoCab[_nPos,4],;             //titulo
                            _aCpoCab[_nPos,2],;             //campo
                            _aCpoCab[_nPos,3],;             //tipo
                            _aCpoCab[_nPos,5],;             //tamanho    
                            _aCpoCab[_nPos,6],;             //decimal
                            _aCpoCab[_nPos,7];              //pict
                            })
        Endif
        Aadd(_aStru, { _aCpoCab[_nPos,02], _aCpoCab[_nPos,03], _aCpoCab[_nPos,05], _aCpoCab[_nPos,06] })
    Next

    _oTable := FWTemporaryTable():New()
    _oTable:SetFields(_aStru)
    _oTable:AddIndex("INDEX1", {"EMISSAO", "CODPROD"} )
    _oTable:Create()
    _cAliasPesq := _oTable:GetAlias()

    _cTable := _oTable:GetRealName()

	_cWhere     := ""

    _cQuery := " INSERT INTO "+_cTable+"                                                                                    "+(Chr(13)+Chr(10))
    _cQuery += " ("
    For _nPos := 01 To Len(_aStru)
        If AllTrim(_aStru[_nPos,1]) == "SALDO"  //este campo não esta em ordem cronológica
            Loop
        Endif
        _cQuery += _aStru[_nPos,1]
        _cQuery += ", "
    NEXT _nPos
    _cQuery += " D_E_L_E_T_, R_E_C_N_O_, SALDO "  
    _cQuery += " )"+ CRLF
    _cQuery += " SELECT TMPKRD.* "+ CRLF
    _cQuery += "    , SUM(QTDE_MOV) OVER(ORDER BY EMISSAO) SALDO "+ CRLF
    _cQuery += " FROM "+ CRLF
    _cQuery += " ( "+ CRLF
    _cQuery += "     SELECT SD1.D1_COD CODPROD "+ CRLF                    
    _cQuery += "            , SB1.B1_DESC DESCRI "+ CRLF                      
    _cQuery += "            , SD1.D1_EMISSAO  EMISSAO "+ CRLF                
    _cQuery += "     		, SD1.D1_LOCAL LOCAL "+ CRLF                     
    _cQuery += "     		, SD1.D1_DOC DOC "+ CRLF                         
    _cQuery += "     		, SD1.D1_SERIE SERIE "+ CRLF                      
    _cQuery += "     		, 'ENTRADA' TIPO "+ CRLF
    _cQuery += "     		, SD1.D1_TES TES "+ CRLF                          
    _cQuery += "     		, SD1.D1_CF CFOP "+ CRLF                        
    _cQuery += "     		, SD1.D1_QUANT QTDE_MOV "+ CRLF                   
    _cQuery += "     		, SD1.D1_TOTAL CUSTO_TOT "+ CRLF                  
    _cQuery += "     		, SC7.C7_DATPRF PENTREGA "+ CRLF                          
    _cQuery += "     		, SD1.D1_FORNECE CLIFOR "+ CRLF                  
    _cQuery += "     		, SD1.D1_LOJA LOJA "+ CRLF                       
    _cQuery += "     		, SA2.A2_NOME NOME_CF "+ CRLF                    
    _cQuery += "     		, SF4D1.F4_TEXTO DESC_CFOP "+ CRLF                                   
    _cQuery += "             , SF1.R_E_C_N_O_     AS  NRECNO "+ CRLF           
    _cQuery += "             ,' '                 AS  D_E_L_E_T_ "+ CRLF       
    _cQuery += "             , SD1.R_E_C_N_O_     AS  R_E_C_N_O_ "+ CRLF        
    _cQuery += "      	FROM ABDHDU_PROT.SD1020 SD1 "+ CRLF                  
    _cQuery += "     	INNER JOIN ABDHDU_PROT.SF1020 SF1 "+ CRLF           
    _cQuery += "             ON SF1.F1_FILIAL   = '"+FwXFilial("SF1")+"' " + CRLF              
    _cQuery += "             AND SF1.F1_DOC     = SD1.D1_DOC "+ CRLF               
    _cQuery += "             AND SF1.F1_SERIE   = SD1.D1_SERIE "+ CRLF  
    _cQuery += "             AND SF1.F1_FORNECE = SD1.D1_FORNECE "+ CRLF  
    _cQuery += "             AND SF1.F1_LOJA    = SD1.D1_FORNECE "+ CRLF  

    _cQuery += "     	INNER JOIN ABDHDU_PROT.SF4020 SF4D1 "+ CRLF           
    _cQuery += "             ON SF4D1.D_E_L_E_T_ = '  ' "+ CRLF                   
    _cQuery += "             AND SF4D1.F4_FILIAL = '"+FwXFilial("SF4")+"' " + CRLF               
    _cQuery += "     		AND SF4D1.F4_CODIGO = SD1.D1_TES "+ CRLF           
    _cQuery += "     		AND SF4D1.F4_ESTOQUE= 'S' "+ CRLF                 
    _cQuery += "        LEFT JOIN ABDHDU_PROT.SB1020 SB1 "+ CRLF               
    _cQuery += "             ON  SB1.D_E_L_E_T_ = '  '  "+ CRLF                   
    _cQuery += "             AND SB1.B1_FILIAL  = '"+FwXFilial("SB1")+"' " + CRLF              
    _cQuery += "             AND SB1.B1_COD     = SD1.D1_COD "+ CRLF               
    _cQuery += "        LEFT JOIN ABDHDU_PROT.SC7020 SC7 "+ CRLF               
    _cQuery += "             ON  SC7.D_E_L_E_T_ = '  '  "+ CRLF                   
    _cQuery += "             AND SC7.C7_FILIAL  = '"+FwXFilial("SC7")+"' " + CRLF              
    _cQuery += "             AND SC7.C7_NUM     = SD1.D1_PEDIDO "+ CRLF               
    _cQuery += "        LEFT JOIN ABDHDU_PROT.SA2020 SA2 "+ CRLF              
    _cQuery += "             ON SA2.D_E_L_E_T_ = '  '  "+ CRLF                  
    _cQuery += "             AND SA2.A2_FILIAL   = '"+FwXFilial("SA2")+"' " + CRLF               
    _cQuery += "             AND SA2.A2_COD      = SD1.D1_FORNECE "+ CRLF            
    _cQuery += "             AND SA2.A2_LOJA     = SD1.D1_LOJA "+ CRLF             
    _cQuery += "     	WHERE SD1.D_E_L_E_T_ = '  ' "+ CRLF                   
    _cQuery += "             AND SD1.D1_FILIAL   = '"+FwXFilial("SD1")+"' " + CRLF             
    _cQuery += "     		AND SD1.D1_COD      BETWEEN '"+_cCodProdDe+"'  AND '"+_cCodProdAte+"' "+ CRLF        
    _cQuery += "     		AND SD1.D1_QUANT    <> '0' "+ CRLF                   
    _cQuery += "     		AND SD1.D1_EMISSAO  BETWEEN '"+DtOs(_dDataDe) +"' AND '"+DtOs(_dDataAte) + "' "+ CRLF 
    _cQuery += "     	UNION "+ CRLF
    _cQuery += "     	SELECT SD2.D2_COD CODPROD "+ CRLF                     
    _cQuery += "            , SB1.B1_DESC DESCRI "+ CRLF                      
    _cQuery += "     		, SD2.D2_EMISSAO  EMISSAO "+ CRLF                
    _cQuery += "     		, SD2.D2_LOCAL LOCAL "+ CRLF                     
    _cQuery += "      		, SD2.D2_DOC DOC "+ CRLF
    _cQuery += "     		, SD2.D2_SERIE SERIE "+ CRLF
    _cQuery += "     		, 'SAIDA' TIPO "+ CRLF
    _cQuery += "     		, SD2.D2_TES TES "+ CRLF                         
    _cQuery += "     		, SD2.D2_CF CFOP  "+ CRLF                      
    _cQuery += "     		, (SD2.D2_QUANT*-1) QTDE_MOV "+ CRLF              
    _cQuery += "     		, SD2.D2_TOTAL CUSTO_TOT "+ CRLF                 
    _cQuery += "     		, '  ' PENTREGA "+ CRLF                          
    _cQuery += "     		, SD2.D2_CLIENTE CLIFOR "+ CRLF                  
    _cQuery += "     		, SD2.D2_LOJA LOJA  "+ CRLF                      
    _cQuery += "     		, SA1.A1_NOME NOME_CF  "+ CRLF                   
    _cQuery += "     		, SF4D2.F4_TEXTO DESC_CFOP "+ CRLF                                    
    _cQuery += "            , SD2.R_E_C_N_O_     AS  NRECNO "+ CRLF           
    _cQuery += "            ,' '                 AS  D_E_L_E_T_  "+ CRLF      
    _cQuery += "            , SD2.R_E_C_N_O_     AS  R_E_C_N_O_  "+ CRLF        
    _cQuery += "      	FROM ABDHDU_PROT.SD2020 SD2 "+ CRLF                  
    _cQuery += "     	INNER JOIN ABDHDU_PROT.SF4020 SF4D2 "+ CRLF           
    _cQuery += "             ON SF4D2.D_E_L_E_T_ = '  ' "+ CRLF                   
    _cQuery += "             AND SF4D2.F4_FILIAL = '"+FwXFilial("SF4")+"' " + CRLF              
    _cQuery += "     		AND SF4D2.F4_CODIGO = SD2.D2_TES "+ CRLF          
    _cQuery += "     		AND SF4D2.F4_ESTOQUE= 'S' "+ CRLF                
    _cQuery += "        LEFT JOIN ABDHDU_PROT.SB1020 SB1 "+ CRLF              
    _cQuery += "             ON  SB1.D_E_L_E_T_ = '  ' "+ CRLF                   
    _cQuery += "             AND SB1.B1_FILIAL   = '"+FwXFilial("SB1")+"' " + CRLF              
    _cQuery += "             AND SB1.B1_COD      = SD2.D2_COD "+ CRLF               
    _cQuery += "        LEFT JOIN ABDHDU_PROT.SA1020 SA1 "+ CRLF              
    _cQuery += "             ON  SA1.D_E_L_E_T_ = '  ' "+ CRLF                   
    _cQuery += "             AND SA1.A1_FILIAL   = '"+FwXFilial("SA1")+"' " + CRLF              
    _cQuery += "             AND SA1.A1_COD      = SD2.D2_CLIENTE "+ CRLF           
    _cQuery += "             AND SA1.A1_LOJA     = SD2.D2_LOJA "+ CRLF             
    _cQuery += "     	WHERE SD2.D_E_L_E_T_ = '  ' "+ CRLF    
    _cQuery += "             AND SD2.D2_FILIAL   = '"+FwXFilial("SD2")+"' " + CRLF             
    _cQuery += "     	    AND SD2.D2_COD      BETWEEN '"+_cCodProdDe+"'  AND '"+_cCodProdAte+"' "+ CRLF       
    _cQuery += "     		AND SD2.D2_QUANT    <> 0 "+ CRLF                    
    _cQuery += "     		AND SD2.D2_EMISSAO  BETWEEN '"+DtOs(_dDataDe) +"' AND '"+DtOs(_dDataAte) + "' "+ CRLF
    //Se informado para mostrar o Saldo Inicial
    If _lSaldoIni
        _cQuery += "     	UNION "+ CRLF
        _cQuery += "     	SELECT SB9.B9_COD CODPROD "+ CRLF                     
        _cQuery += "            , SB1.B1_DESC DESCRI "+ CRLF                      
        _cQuery += "     		, SB9.B9_DATA EMISSAO "+ CRLF                
        _cQuery += "     		, 'ND' LOCAL "+ CRLF                     
        _cQuery += "      		, 'ND' DOC "+ CRLF
        _cQuery += "     		, 'ND' SERIE "+ CRLF
        _cQuery += "     		, ' ' TIPO "+ CRLF
        _cQuery += "     		, 'ND' TES "+ CRLF                         
        _cQuery += "     		, 'ND' CFOP  "+ CRLF                      
        _cQuery += "     		, SB9.B9_QINI  QTDE_MOV "+ CRLF              
        _cQuery += "     		, 0 CUSTO_TOT "+ CRLF                 
        _cQuery += "     		, 'ND' PENTREGA "+ CRLF                          
        _cQuery += "     		, 'ND' CLIFOR "+ CRLF                  
        _cQuery += "     		, 'ND' LOJA  "+ CRLF                      
        _cQuery += "     		, 'ND' NOME_CF  "+ CRLF                   
        _cQuery += "     		, 'ND' DESC_CFOP "+ CRLF                                    
        _cQuery += "            , MAX(SB9.R_E_C_N_O_)     AS  NRECNO "+ CRLF           
        _cQuery += "            ,' '                 AS  D_E_L_E_T_  "+ CRLF      
        _cQuery += "            , MAX(SB9.R_E_C_N_O_)     AS  R_E_C_N_O_  "+ CRLF        
        _cQuery += "      	FROM ABDHDU_PROT.SB9020 SB9 "+ CRLF                  
        _cQuery += "        LEFT JOIN ABDHDU_PROT.SB1020 SB1 "+ CRLF              
        _cQuery += "             ON  SB1.D_E_L_E_T_ = '  ' "+ CRLF                   
        _cQuery += "             AND SB1.B1_FILIAL   = '"+FwXFilial("SB1")+"' " + CRLF              
        _cQuery += "             AND SB1.B1_COD      = SB9.B9_COD "+ CRLF               
        _cQuery += "        WHERE SB9.D_E_L_E_T_ = ' ' "+ CRLF
         _cQuery += "        	AND SB9.B9_COD BETWEEN '"+_cCodProdDe+"'  AND '"+_cCodProdAte+"' "+ CRLF
    	_cQuery += "        	AND ROWNUM = 1 "+ CRLF
         _cQuery += "        GROUP BY SB9.B9_COD, SB1.B1_DESC, SB9.B9_DATA, SB9.B9_QINI " + CRLF
 	Endif

    _cQuery += "     ) TMPKRD "+ CRLF
    _cQuery += " ORDER BY EMISSAO, CODPROD "+ CRLF

	nStatus := TCSqlExec(_cQuery)
    If (nStatus < 0)
        MsgStop("TCSQLError() " + TCSQLError(), "Registros Cabeçalho")
        Break    
    Endif

    (_cAliasPesq)->(DbGoTop())
	If (_cAliasPesq)->(Eof())
		MSGINFO( "Não existem dados para montar o Kardex", "Atenção" )
		Break
	Endif

    ZPECF033BW(_cCodProd,  _dDataDe, _dDataAte, _cAliasPesq, _aBrwCab)

End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	//Ferase(_cTable+GetDBExtension())
    _oTable:Delete()
Endif      
Return Nil




//gerar browse com informações Kardex
Static Function ZPECF033BW(_cCodProd,  _dDataDe, _dDataAte, _cAliasPesq, _aBrwCab)
//Local _aCpoInf      := {} 
/*
Local _aSizeAut     := MsAdvSize(.f.)
Local _oKardex      := MSDIALOG() :New(_aSizeAut[7],0,_aSizeAut[6],_aSizeAut[5],"Kardex Entrada e Saida",,,,128,,,,,.T.)
Local _oTPanel01    := TPanel():New(0,0,"",_oKardex,NIL,.T.,.F.,NIL,NIL,100,(_oKardex:nClientHeight/6)-10,.F.,.F.)
Local _oTPanel01:Align :=  CONTROL_ALIGN_TOP
Local _oTPanel02    := TPanel():New(0,0,"Informações",_oKardex,NIL,.T.,.F.,NIL,NIL,100,(_oKardex:nClientHeight/4)-10,.F.,.F.)
Local _oTPanel02:Align := CONTROL_ALIGN_BOTTOM
*/
Local _cTitulo      := "Kardex Entrada e Saida de "+DtoC(_dDataDe)+" a "+DtoC(_dDataAte)
Local _oBrw
//Local _oBrwInf
//Local _nPos

Begin Sequence

    //implemento com o nome e o codigo do produto 
    If !Empty(_cCodProd)
        SB1->(DbSetOrder(1)) 
        SB1->(DbSeek(FwXFilial("SB1")+_cCodProd))
        _cTitulo += " Produto: "
        _cTitulo += AllTrim(_cCodProd)
        _cTitulo += " - "
        _cTitulo += AllTrim(SB1->B1_DESC)
    //Caso não tenha informado o produto tenho que incluir o código do produto para visualizar
    Endif


	DbSelectArea(_cAliasPesq)
 	_oBrw := FWMBrowse():New()
	_oBrw:SetCanSaveArea(.T.)	//abertura de mais de uma  browse
	_oBrw:SetTemporary(.T.)
    //_oBrw:SetOwner(_oTPanel01)
    _oBrw:SetAlias(_cAliasPesq)	
	_ObrW:SetMenuDef('')
	_ObrW:SetFields(_aBrwCab)
    _ObrW:SetIgnoreARotina(.T.) // Indica que a mbrowse, ira ignorar a variavel private aRotina na construção das opções de menu.
    _ObrW:SetWalkThru(.F.)
    _ObrW:DisableConfig() // Desabilita a utilização do Browse
    _ObrW:SetAmbiente(.F.) //Habilita a utilização da funcionalidade Ambiente no Browse
    _ObrW:SetFixedBrowse(.T.)
	_ObrW:DisableDetails()
    //_ObrW:ForceQuitButton()     
	//Definimos o título que será exibido como método SetDescription
	_ObrW:SetDescription(_cTitulo)
    //Definimos a tabela que será exibida na Browse utilizando o método SetAlias
    //Legenda da grade, é obrigatório carregar antes de montar as colunas
	
    _ObrW:AddLegend("AllTrim(TIPO) = 'ENTRADA'  "  ,"BLUE" 	   	,"N.F. Entrada")
	_ObrW:AddLegend("AllTrim(TIPO) = 'SAIDA'    "  ,"GREEN"     ,"N.F. Saida")
	//_ObrW:AddLegend("AllTrim(TIPO) = ''         "  ,"YELLOW"    ,"Saldo Inicial")
	_ObrW:AddButton("Notas Entrada/Saida"  	, { || FWMsgRun(, {|| ZPEC33NF(_cAliasPesq) }, "Nota Fiscal", "Localizando Nota Fiscal") },,,, .F., 2 )  //função no ZPECFUNA
  
   //Ativamos a classe
    _ObrW:Refresh(.T.)
	_ObrW:Activate()
/*
    //preparo Informações gerais
    _aBrwInf := {}
    _aCpoInf := {}
   	aAdd( _aCpoInf, {"SA1", "NOME_CF"   , "C","Fornecedor/Cliente"   , Len(SA1->A1_NOME)  , 0, "@!",.T.})
   	aAdd( _aCpoInf, {"SF4", "DESC_CFOP" , "C","Descrição CFOP"       , Len(SF4->F4_TEXTO) , 0, "@!",.T.})
    For _nPos := 1 To Len(_aCpoInf)
        Aadd(_aBrwInf,{ RetTitle(_aCpoInf[_nPos,4]),;    //titulo
                        _aCpoInf[_nPos,02],;             //campo
                        _aCpoInf[_nPos,03],;                  //tipo
                        _aCpoInf[_nPos,05],;                  //tamanho
                        _aCpoInf[_nPos,06],;                  //decimal
                        _aCpoInf[_nPos,07];  //pict
                          })
    Next                      

    _oBrwInf := FWMBrowse():New()
    _oBrwInf:SetAlias(_cAliasPesq)
    _oBrwInf:SetOwner(_oTPanel02)
    _oBrwInf:SetDescription("Cliente/Fornecedor - Descrição CFOP")
    _oBrwInf:SetMenuDef('')
    _oBrwInf:SetTemporary(.T.)
    _oBrwInf:SetUseFilter(.F.)
    _oBrwInf:OptionReport(.F.)
	_oBrwInf:SetFields(_aBrwInf)

    _oBrwInf:DisableDetails()
    _oBrwInf:DisableReport()
    _oBrwInf:Activate()
    _ObrW:Refresh()
    _oBrwInf:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

    _oKardex:Activate()
 */
    /*
    //oRelac:= FWBrwRelation():New()
    //oRelac:AddRelation( oBrwCab , oBrwIte , {{"D1_FILIAL" , "F1_FILIAL" } ,; 
                                             {"D1_DOC"    , "F1_DOC"    } ,;
                                             {"D1_SERIE"  , "F1_SERIE"  } ,;
                                             {"D1_FORNECE", "F1_FORNECE"} ,;
                                             {"D1_LOJA"   , "F1_LOJA"   }})

    */
End Sequence 
Return Nil


/*/{Protheus.doc} ZPEC33NF
//Mostrar NFE e ou NFS
@author DAC denilso
@since 26/05/2023
@version 1.0
@return Nil
@type User function
/*/
Static Function ZPEC33NF(_cAliasPesq)
//nota fiscal de Saida
If AllTrim((_cAliasPesq)->TIPO) == "SAIDA"
    SD2->(DBGOTO((_cAliasPesq)->NRECNO))
    SD2->(A920NFSAI("SD2",SD2->(RecNo()),0))
    //Mc090Visual("SF2", SF2->(RecNo()), 1)  //nfe
ElseIf AllTrim((_cAliasPesq)->TIPO) == "ENTRADA"
    aRotina := {}
    SF1->(DBGOTO((_cAliasPesq)->NRECNO))
    Private cCadastro := "Nota Fiscal Entrada - VISUALIZAR"
    SF1->( a910NFiscal("SF1",SF1->(Recno()),0) )
    //SF1->( A103NFiscal("SF1",SF1->(Recno()),0) )
Else 
	MSGINFO( "Não é uma nota de Entrada ou Saida", "Atenção" )
Endif
Return Nil
