#Include "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "TOTVS.ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWBROWSE.CH"
#Include "FWMVCDEF.CH"

#define CRLF chr(13) + chr(10)  

/*/{Protheus.doc} ZPECF032
Viualizar Or�amentos de Itens 
@author     DAC - Denilso 
@since      26/05/2023
@version    1.0
@obs        Tela esta relacionada com a funcionalidade ZPECF030 a mesma poder� ser colocada tamb�m no menu com a chamada ZPECF032 caso seja necess�rio adaptar parametros para a procura  
/*/

User Function ZPECF032(_cCodProd, _lPickAll, _lMostraCF)
Local _aArea := GetArea()

Default _cCodProd   := Space(Len(VS3->VS3_CODITE))
Default _lPickAll   := .T.
Default _lMostraCF  := .T.

    ZPECF032PR(_cCodProd, _lPickAll, _lMostraCF)

RestArea(_aArea)
Return Nil



Static Function ZPECF032PR(_cCodProd, _lPickAll, _lMostraCF)
Local _aBrwFil		:= {}
Local _aStru         := {}
Local _aCampos      := {}
Local _cWhere       := ""
Local _cWherevs1    := ""
Local _cQuery       := ""
Local _cTitulo      := ""
Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local _cFaseOrc 	:= AllTrim(GetNewPar("MV_FASEORC","023R45F"))
Local _cFase
Local _cFasePrc
Local _aTamSx3
Local _cAliasPesq    //:= GetNextAlias()
Local _ObrW         
Local _nPos
Local _nPosCpo
Local _lInicio

Default _cCodProd   := Space(Len(VS3->VS3_CODITE))
Default _lPickAll   := .T.
Default _lMostraCF  := .T.
    
Begin Sequence
	//Definir as fases que ser�o atendidas no processo
	_nPosCpo := AT(_cFaseConf, _cFaseOrc)
	If _nPosCpo == 0 
		MSGINFO( "N�o existe fase de or�amento no par�metro indicativo de Fase", "[ZPECF032PR] - Aten��o" )
		Break
	Endif
	//identifico os status do or�amento (fase) para trazer na tela
	_cFase := SubsTr(_cFaseOrc, 1, _nPosCpo -1)
	If Empty(_cFase) 
		MSGINFO( "N�o localizado fase de or�amento no par�metro indica��o de Fase", "[ZPECF032PR] - Aten��o" )
		Break
	Endif
    _cFasePrc   := ""
    For _nPos := 1 To LEN( _cFase )
        _cFasePrc   += SubsTr(_cFase,_nPos,1)+";"
    Next _nPos
    //_cFasePrc := SubsTr(_cFasePrc,1, Len(_cFasePrc)-1)
    _cFasePrc := SubsTr(_cFasePrc,1, Len(_cFasePrc))

    _cTitulo      := "Posi��o Or�amento por Produto"
    //implemento com o nome e o codigo do produto 
    If !Empty(_cCodProd)
        SB1->(DbSetOrder(1)) 
        SB1->(DbSeek(FwXFilial("SB1")+_cCodProd))
        _cTitulo += " "
        _cTitulo += AllTrim(_cCodProd)
        _cTitulo += " - "
        _cTitulo += AllTrim(SB1->B1_DESC)
    //Caso n�o tenha informado o produto tenho que incluir o c�digo do produto para visualizar
    Endif

    _aCampos := {}
    Aadd( _aCampos, {"VS3", "VS3_QTDITE" ,.T.})
    Aadd( _aCampos, {"VS3", "VS3_QTDINI" ,.T.})
    Aadd( _aCampos, {"VS1", "VS1_STATUS" ,.F.})
    Aadd( _aCampos, {"VS3", "VS3_NUMORC" ,.T.})
    Aadd( _aCampos, {"VS3", "VS3_SEQUEN" ,.T.})
    Aadd( _aCampos, {"VS1", "VS1_XTPPED" ,.F.})
    Aadd( _aCampos, {"VS1", "VS1_DATORC" ,.T.})
    Aadd( _aCampos, {"VS1", "VS1_XPVAW"  ,.T.})
    //Campos que serao inclu�dos no browse mas criados na tabela
   	aAdd( _aCampos, {"VS1", "ORC_STATUS" , "C","Status Orc.", 30, 0, "@!",.T.})
   	aAdd( _aCampos, {"VX5", "ORC_TIPO"   , "C","Tipo"       , 30, 0, "@!",.T.})
 	aAdd( _aCampos, {"VS1", "RECNOVS1"   , "N","Recno VS1"  , 10, 0, "@!",.F. /*n�o ncluir no browse*/})
    
    _aBrwFil    := {}
    _aStru      := {}  //Estrutura do Banco
    For _nPos := 1 To Len(_aCampos)
        If Len(_aCampos[_nPos]) == 3
            _aTamSx3 := TamSX3(_aCampos[_nPos,2])
            If _aCampos[_nPos,Len(_aCampos[_nPos])]  //Valida se a coluna ir� para o Browse
                Aadd(_aBrwFil,{ RetTitle(_aCampos[_nPos,2]),;    //titulo
                                _aCampos[_nPos,2],;             //campo
                                _aTamSx3[03],;                  //tipo
                                _aTamSx3[01],;                  //tamanho
                                _aTamSx3[02],;                  //decimal
                             PesqPict(_aCampos[_nPos,1],_aCampos[_nPos,2]);  //pict
                          })
            Endif
            Aadd(_aStru, {_aCampos[_nPos,02], _aTamSx3[03], _aTamSx3[01], _aTamSx3[02] })
        Else  
            If _aCampos[_nPos,Len(_aCampos[_nPos])]  //Valida se a coluna ir� para o Browse
                Aadd(_aBrwFil,{ _aCampos[_nPos,4],;             //titulo
                                _aCampos[_nPos,2],;             //campo
                                _aCampos[_nPos,3],;             //tipo
                                _aCampos[_nPos,5],;             //tamanho    
                                _aCampos[_nPos,6],;             //decimal
                                _aCampos[_nPos,7];              //pict
                                })
            Endif
            Aadd(_aStru, { _aCampos[_nPos,02], _aCampos[_nPos,03], _aCampos[_nPos,05], _aCampos[_nPos,06] })
        Endif
    Next

    _oTable := FWTemporaryTable():New()
    _oTable:SetFields(_aStru)
    _oTable:AddIndex("INDEX1", {"VS3_NUMORC", "VS3_SEQUEN"} )
    _oTable:Create()
    _cAliasPesq := _oTable:GetAlias()

    _cTable := _oTable:GetRealName()

	_cWhere     := ""
    _cWhereVS1  := ""
    //Somente picking deste produto
   
	If !Empty(_cCodProd) .And. !_lPickAll
		_cWhere +=   " AND VS3.VS3_CODITE = '"+_cCodProd+"'"+ CRLF
	//indica se trara todos os demais produtos do Pincking quando estiver indicado produto
    ElseIf !Empty(_cCodProd) .And. _lPickAll
        _cWhereVS1 += "AND  (   SELECT DISTINCT VS3A.VS3_CODITE "+ CRLF
        _cWhereVS1 += "         FROM VS3020 VS3A " + CRLF
        _cWhereVS1 += "         WHERE VS3A.VS3_NUMORC  =  VS1.VS1_NUMORC "+ CRLF
        _cWhereVS1 += "             AND VS3A.VS3_CODITE =  '"+_cCodProd+"') <> ' ' "+ CRLF
	Endif
    //indica que mostra cancelado e faturado
    If _lMostraCF
        _cFasePrc += "C;F" 
    EndIf

    _cQuery := " INSERT INTO "+_cTable+"                                                                                    "+(Chr(13)+Chr(10))
    _cQuery += " ("
    For _nPos := 01 To Len(_aStru)
        _cQuery += _aStru[_nPos,1]
        _cQuery += ", "
    NEXT _nPos
    _cQuery += " D_E_L_E_T_, R_E_C_N_O_ "  
    _cQuery += " )"+ CRLF
    _cQuery += "SELECT  "
    //montar os campos que possuem no dicion�rio os demais que n�o est�o no dicion�rio devem ser os ultimos e implemeentados conforme select
    _lInicio:= .T.
    For _nPos := 1 To Len(_aCampos)   
        If Len(_aCampos[_nPos]) == 3
            If !_lInicio
 	            _cQuery +=  "   ,"+_aCampos[_nPos,1] +"." +_aCampos[_nPos,2]+ " AS "+ _aCampos[_nPos,2] +CRLF
            Else
 	            _cQuery +=  "    "+_aCampos[_nPos,1] +"." +_aCampos[_nPos,2]+ " AS "+ _aCampos[_nPos,2] +CRLF
                _lInicio:= .F.
            Endif
        Endif 
    Next _nPos       

    //Campos n�o normatizados pelo dicion�rio 
    _cQuery += "        , CASE "+ CRLF
	_cQuery += "             WHEN  VS1.VS1_STATUS = '0'   THEN '"+Upper("Digitado")                 +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = '2'   THEN '"+Upper("Margem Pendente")          +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = '3'   THEN '"+Upper("Avaliacao de Credito")     +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = '4'   THEN '"+Upper("Carregamento")             +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'S'   THEN '"+Upper("Aguardando Lib.Diverg.")   +"' "+ CRLF
	_cQuery += "             WHEN  VS1.VS1_STATUS = 'RT'  THEN '"+Upper("Aguardando Reserva")       +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'F'   THEN '"+Upper("libera��o p/ faturamento") +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'P'   THEN '"+Upper("Pendente para O.S.")       +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'L'   THEN '"+Upper("Liberado para O.S.")       +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'I'   THEN '"+Upper("Importado para O.S.")      +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'C'   THEN '"+Upper("cancelado")                +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'X'   THEN '"+Upper("Faturado")                 +"' "+ CRLF
    _cQuery += "         ELSE 'STATUS N�O INFORMADO' "+ CRLF
    _cQuery += "         END AS ORC_STATUS "+ CRLF
    _cQuery += "        ,SUBSTR(VX5.VX5_DESCRI,1,30)   AS  ORC_TIPO "  + CRLF
    _cQuery += "        ,VS1.R_E_C_N_O_     AS  RECNOVS1 "  + CRLF
    _cQuery += "        ,' '                AS  D_E_L_E_T_ "+ CRLF
    _cQuery += "        ,ROW_NUMBER() OVER (ORDER BY VS3_XPICKI, VS3_NUMORC, VS3_SEQUEN)     AS  R_E_C_N_O_ "+ CRLF    
	_cQuery += "FROM "+RetSqlName("VS3")+" VS3 "+ CRLF
	_cQuery += "JOIN "+RetSqlName("VS1")+" VS1 "+ CRLF
	_cQuery += "	ON 	VS1.D_E_L_E_T_ = ' ' "+ CRLF
	_cQuery += "	AND VS1.VS1_FILIAL	= '"+FwXFilial("VS1")+"' " + CRLF
	_cQuery += "	AND VS1.VS1_NUMORC 	= VS3.VS3_NUMORC "+ CRLF
	_cQuery += "	AND VS1.VS1_TIPORC 	= '1' "+ CRLF
	_cQuery += "	AND VS1.VS1_STATUS IN "+ FormatIn(_cFasePrc,";") +" "+ CRLF
    _cQuery +=      _cWhereVS1
	_cQuery += "JOIN "+RetSqlName("SA1")+" SA1 "+ CRLF
	_cQuery += "	ON 	SA1.D_E_L_E_T_ = ' ' "+ CRLF
	_cQuery += "	AND SA1.A1_FILIAL	= '"+FwXFilial("SA1")+"' "+ CRLF
	_cQuery += "	AND SA1.A1_COD 	    = VS1.VS1_CLIFAT "+ CRLF
	_cQuery += "	AND SA1.A1_LOJA 	= VS1.VS1_LOJA "+ CRLF
    _cQuery += "LEFT JOIN "+RetSqlName("VX5")+" VX5 "+ CRLF
	_cQuery += "	ON 	VX5.D_E_L_E_T_ = ' ' " + CRLF
	_cQuery += "	AND VX5.VX5_FILIAL = '"+FwXFilial("SA1")+"' "+ CRLF
	_cQuery += "	AND VX5.VX5_CHAVE = 'Z00' "+ CRLF
	_cQuery += "	AND VX5.VX5_CODIGO = VS1.VS1_XTPPED "
	_cQuery += "WHERE  VS3.D_E_L_E_T_ = ' ' "
	_cQuery += "	AND VS3.VS3_FILIAL	= '"+FwXFilial("VS3")+"' "+ CRLF
	_cQuery += "	AND VS3.VS3_XPICKI 	<> ' ' "+ CRLF
    _cQuery +=      _cWhere
    _cQuery += "ORDER BY VS3.VS3_NUMORC, VS3.VS3_SEQUEN"    

	nStatus := TCSqlExec(_cQuery)
    If (nStatus < 0)
        MsgStop("TCSQLError() " + TCSQLError(), "Registros Cabe�alho")
        Break    
    Endif
    
    (_cAliasPesq)->(DbGoTop())
	If (_cAliasPesq)->(Eof())
		MSGINFO( "N�o existe Or�amento pendente para este item", "Aten��o" )
		Break
	Endif
	DbSelectArea(_cAliasPesq)

 	_ObrW := FWMBrowse():New()
	_ObrW:SetCanSaveArea(.T.)	//abertura de mais de uma  browse
	_ObrW:SetTemporary(.T.)
    _oBrw:SetAlias(_cAliasPesq)	
	_ObrW:SetMenuDef('')
	_ObrW:SetFields(_aBrwFil)
    _ObrW:SetIgnoreARotina(.T.) // Indica que a mbrowse, ira ignorar a variavel private aRotina na constru��o das op��es de menu.
    _ObrW:SetWalkThru(.F.)
    _ObrW:DisableConfig() // Desabilita a utiliza��o do Browse
    _ObrW:SetAmbiente(.F.) //Habilita a utiliza��o da funcionalidade Ambiente no Browse
    _ObrW:SetFixedBrowse(.T.)
	_ObrW:DisableDetails()
	//Definimos o t�tulo que ser� exibido como m�todo SetDescription
	_ObrW:SetDescription(_cTitulo)
    //Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
//	//Legenda da grade, � obrigat�rio carregar antes de montar as colunas
	_ObrW:AddLegend("VS1_STATUS = '0' "  ,"YELLOW" 	   	,"Digitado")
	_ObrW:AddLegend("VS1_STATUS = '2'"   ,"RED"   		,"Margem Pendente")
	_ObrW:AddLegend("VS1_STATUS = '3'"   ,"BLACK"   	,"Avaliacao de Credito")
	_ObrW:AddLegend("VS1_STATUS = 'F'"   ,"GREEN"       ,"libera��o p/ faturamento")
	_ObrW:AddLegend("VS1_STATUS = 'C' "  ,"BLUE" 	   	,"cancelado")
	_ObrW:AddLegend("VS1_STATUS = 'X ' " ,"WHITE" 	   	,"Sem Faturado")

	_ObrW:AddButton("Visualiza Or�amento"  	, { || FWMsgRun(, {|oSay| U_XFVERORC(_cAliasPesq,@_ObrW) }, "Or�amento", "Localizando Or�amento") },,,, .F., 2 )  //fun��o no ZPECFUNA

   //Ativamos a classe
    _ObrW:Refresh(.T.)
	_ObrW:Activate()
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	//Ferase(_cTable+GetDBExtension())
    _oTable:Delete()
Endif      
Return Nil





