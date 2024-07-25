/*Importar as bibliotecas*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _cEol CHR(13)+CHR(10)  //final de linha


/*---------------------------------------------------------------------------------------
{Protheus.doc} ZCOMF015 
Rdmake 	responsavel pela inclusão/visualização de historicos
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC Denilso 
@version    Nao Informado
@since      05/08/2019  
@return    	Logico
@sample     Nao Informado
@obs        Chamado pelo Ponto de Entrada MT120OK,MT11TOK e via menu
@project    CAOA
@menu       Nao Informado
@history    
--------------------------------------------------------------------------------------*/
/*Iniciando sua função*/
User Function ZCOMF015( _cTpDoc, _nOpc, _lGeral,_cNum,_aHeadAux,_aColsAux,_lJobStart,_aEmpFil,_cFunOrig,_lInc,_lAlter,_cUser,_cMemo)
Local _aArea 	    := GetArea()
Local _aMens        := {}
Local _cTipo        := ""
Local _lZCONF015    := .t. //SuperGetMV( "CMV_COM003"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade
Local _lJob         := GetRemoteType() == -1 // Verifica se é job
Local _lNovo        := .F.
Local _lCopia       := .F.
Local _lRet         := .T.
Local _nPos
Local _cMsg
Local _cAlias
Local _cDoc
Local _nTipo
Local cMensage := ""
Private lIsBlind  := .F.
Private _cUsuario := Space(8)
Private _cMotivo  := ""

Default _lGeral    := .F.
Default _lJobStart := .F.
Default _cNum      := ""
Default _aHeadAux  := {}
Default _aColsAux  := {}
Default _aEmpFil   := {"",""}
Default _cFunOrig   := FunName()
Default _lInc       := .T.
Default _lAlter     := .T.
Default _cUser      := space(8)
Default _cMemo   := space(255)
    //Caso seja envio por JOB não continuar
        
    If _lJobStart
        Conout("**************** STARTJOB -- ZCOMF015 ************")
		RpcSetType(3)
		RpcSetEnv(_aEmpFil[1],_aEmpFil[2])
		//RpcClearEnv()
	
        Private aHeader     := aClone(_aHeadAux)
        Private aCols       := aClone(_aColsAux)
        Private INCLUI      := _lInc
        Private ALTERA      := _lAlter
      
        _cUsuario   := _cUser
        lIsBlind := .T.
        _cMotivo := _cMemo
        if INCLUI .and. ALTERA
            Conout("Exite problemas na chamada da função ZCOMF015, contatar admnistrador do Sistema")
            Return
        EndIF
    Else
        _cUsuario := RETCODUSR()
    EndIf
    If _lJob .and. !lIsBlind 
        Return _lRet
    Endif    

    _lZCONF015    := SuperGetMV( "CMV_COM003"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade 
    //Caso esteja desabilitado parametro
    If !_lZCONF015
        Return _lRet
    Endif

    If Valtype(_cTpDoc) <> "C" .or. Valtype(_nOpc) <> "N"
        cMensage := "Exite problemas na chamada da função ZCOMF015, contatar admnistrador do Sistema"
        if lIsBlind 
            Conout(cMensage)
        Else
            Msgalert(cMensage)
        EndIf
        _lRet := .F.
        Return _lRet
	Endif

    If _nOpc == 3  //Inclusão sempre sera novo
        _lNovo := .T.
    EndIf
    
    If lIsBlind    
        GetTab(_cTpDoc,_cNum)
    endIf

  	DBSELECTAREA('SZH')  //Tabela de auditoria Solicitação de Compras e Pedido de Compras	
    If _cTpDoc == "PC"
        _cAlias 	:= "SC7"
        //_cTipo      := "PC"
        //Necessario fazer esta validação se não deveria ser validada em cada ponto de entrada de acordo com a chamada da função para diferenciar pedido de AE
        _nTipo      := If( Type("M->C7_TIPO") <> "U" , M->C7_TIPO, SC7->C7_TIPO)
        _cTipo      := If( _nTipo == 2 , "AE","PC") 
        _cDoc       := If(Type("cA120Num") == "C" .and. !Empty(cA120Num), cA120Num,SC7->C7_NUM)  //SC7->C7_NUM
    ElseIf _cTpDoc == "AE"
        //_cAlias 	:= "SC7"
        //Necessario fazer esta validação se não deveria ser validada em cada ponto de entrada de acordo com a chamada da função para diferenciar pedido de AE
        _nTipo      := If( Type("M->C7_TIPO") <> "U" , M->C7_TIPO, SC7->C7_TIPO)
        _cTipo      := If( _nTipo == 2 , "AE","PC") 
        _cTipo      := "AE"
        _cDoc       := If(Type("cA120Num") == "C" .and. !Empty(cA120Num), cA120Num,SC7->C7_NUM)  //SC7->C7_NUM
    ElseIf _cTpDoc == "SC"
        _cAlias 	:= "SC1"
        _cTipo      := "SC"
        _cDoc       := If(Type("cA110Num") == "C" .and. !Empty(cA110Num),cA110Num,SC1->C1_NUM)   //SC1->C1_NUM
    ElseIf _cTpDoc == "CP"
        _cAlias 	:= "SC3"
        _cTipo      := "CP"
        _cDoc       := If(Type("cA125Num") == "C" .and. !Empty(cA125Num),cA125Num,SC3->C3_NUM)   //SC3->C3_NUM
    Endif

    //Na inclusão pode não estar gravado o tipo da AE
    If _lNovo .and. _cTipo == "PC" .and. _cFunOrig == "MATA122"
        _cTipo      := "AE"
    EndIf

    //Quando for consulta chamada no menu  irá desprezar a carga de dados das variaveis e ira carregar os dados existentes na bas 
    If _lGeral 
        If Type("_cDoc") == "U" .or. Empty(_cDoc)
            If _cTipo == "SC"
                _cDoc := SC1->C1_NUM
            ElseIf _cTipo $ "CP"
                _cDoc := SC3->C3_NUM
            ElseIf _cTipo $ "PC_AE"
                _cDoc := SC7->C7_NUM
            Endif
        Endif 
        VisMotiF15( _cDoc, _cTipo, _lGeral )
        Return _lRet
    Endif

  	//Se retornar falso existem erros não prosseguir
	_lRet := VerAudiF15( _cAlias, _cTipo, _lNovo, _lCopia, @_aMens, _nOpc)
    //Não retornou nenhuma mensagem para gravar ou mostrar pode sair
    If Len(_aMens) == 0
        Return _lRet
    Endif    
    //Existe erro mostrar e sair não gravar estes erros
    If !_lRet
        _cMsg := ""
        For _nPos := 1 To Len(_aMens)
            _cMsg := _aMens[_nPos]+_cEol
        Next
        If  !IsBlind
            Msgalert(_cMsg)
        Else
            
            Conout(_cMsg)
            Conout("****************** END JOB ***********************")
        EndIf
        Return _lRet
    Endif
    //GrvAudiF15(_aMens,_cDoc,_cTipo)
    ApvAudiF15(_aMens,_cDoc,_cTipo,/*_lGeral*/)

    RestArea(_aArea)
    Conout("****************** END JOB ***********************")
Return _lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VerAudiF15
Verificar as diferenças doc campos para ver se gerara ou não dados para auditoria gravada em tabela especifica
@author DAC denilso.carvalho
@since 28/02/2020
@version 1.0
@Obs        DAC Denilso 25/08/2020
            - Numero do item alterado para não aparecer o item quando da inclusão solicitado Douglas - DAC 25/08/2020
/*/
//-------------------------------------------------------------------
Static  Function VerAudiF15( _cAlias, _cTipo, _lNovo, _lCopia,_aMens,_nOpc)

Local _lRet     := .T.
Local _nCol     := Len(aHeader) -2  //retirado alias e numero de registro
Local _nPosItem := aScan(aHeader,{|x|  '_ITEM' $ AllTrim(x[2]) })
Local _nCount
Local _cVarMem
Local _cVarTit
Local _nReg
Local _cVar1
Local _cVar2
Local _nPos
Local cMensage := "" 

    If _nPosItem == 0
        cMensage := "Exite problemas na chamada da função ZCOMF015/VerAudiF15 não localizou campo item, contatar admnistrador do Sistema"
        if IsBlind
            Conout(cMensage)
        Else
            Msgalert(cMensage)
        endif

        Return _lRet
    EndIf

    SX3->(DbSetOrder(2))
    DbSelectArea(_cAlias)
    //Validar os Cabeçalhos
    //Caso S.C.
    For _nPos := 1 To _nCol  //Len(aHeader) 
        _cVarTit := AllTrim(aHeader[_nPos,1])
        _cVarMem := AllTrim(aHeader[_nPos,2])
        If !SX3->(DbSeek(_cVarMem)) 
            AAdd( _aMens,{  "Não localizado campo "+_cVarMem+" no dicionario de dados, verificar com administrador do Sistma !",;
                            aCols[_nCount,_nPosItem],;     //numero do item
                            aCols[ _nCount, _nCol + 2 ] ;  //Registro do item
                })
            _lRet := .F.
            Return _lRet
        Endif
        //Caso seja um campo visual não validar
        If SX3->X3_CONTEXT == "V" 
            Loop
        Endif

        For _nCount := 1 To Len(aCols)   //nao verificar os ultimos registros os mesmos são referencias
            _nReg := aCols[ _nCount, _nCol + 2 ]  //numero de registro na tabela
            If _nReg == 0 
                If _nPos == _nPosItem  //somente para passar uma vez quando de inclusão de item
                    AAdd( _aMens,{   "Inclusão de novo Item ",;                         //
                                    aCols[_nCount,_nPosItem],;                          //numero do item   //Space(Len(aCols[_nCount,_nPosItem])) //alterado conforme douglas DAC 31/08/2020
                                    aCols[ _nCount, _nCol + 2 ], ;                      //Registro do item
                                    "I", ;                                              //Tipo de Operação                         
                                    _cVarMem, ;                                         //Campo
                                    "", ;                                               //Conteudo anterior
                                    "", ;                                               //Conteudo Alterado
                                    _cVarTit ;                                          //Conteudo Titulo
                                })
                                //aCols[_nCount,_nPosItem],;     //numero do item
                EndIf
                Loop  //não passar se não ira emitir varias msg
            Endif    
            //Verifica se item foi deletado
            If _nReg > 0  .and. aCols[ _nCount, _nCol + 3 ]
                If _nPos == _nPosItem  //somente para passar uma vez quando de inclusão de item
                    AAdd( _aMens,{   "Exclusão de Item ",;                         //
                                    aCols[_nCount,_nPosItem],;                          //numero do item   //Space(Len(aCols[_nCount,_nPosItem])) //alterado conforme douglas DAC 31/08/2020
                                    aCols[ _nCount, _nCol + 2 ], ;                      //Registro do item
                                    "E", ;                                              //Tipo de Operação                         
                                    _cVarMem, ;                                         //Campo
                                    "", ;                                               //Conteudo anterior
                                    "", ;                                               //Conteudo Alterado
                                    _cVarTit ;                                          //Conteudo Titulo
                                })
                EndIf
                Loop  //não passar se não ira emitir varias msg
            Endif    

            (_cAlias)->(DbGoto(_nReg))
            If (_cAlias)->(FieldGet(FieldPos(_cVarMem))) <> aCols[_nCount,_nPos]
                If ValType(aCols[_nCount,_nPos]) == "N"
                    if _cAlias == "SC3"
                        _cVar1 := AllTrim(Str(aCols[_nCount,_nPos]))
                        _cVar2 := AllTrim(Str((_cAlias)->(FieldGet(FieldPos(_cVarMem)))))
                    else
                        _cVar1 := AllTrim(Str((_cAlias)->(FieldGet(FieldPos(_cVarMem)))))
                        _cVar2 := AllTrim(Str(aCols[_nCount,_nPos]))
                    endif
                ElseIf ValType(aCols[_nCount,_nPos]) == "D"
                    _cVar1 := DtoC((_cAlias)->(FieldGet(FieldPos(_cVarMem))))
                    _cVar2 := DtoC(aCols[_nCount,_nPos])
                ElseIf ValType(aCols[_nCount,_nPos]) == "L" .and. aCols[_nCount,_nPos]
                    _cVar1 := "Falso"
                    _cVar2 := "Verdadeiro"
                ElseIf ValType(aCols[_nCount,_nPos]) == "L" .and. !aCols[_nCount,_nPos]
                    _cVar1 := "Verdadeiro"
                    _cVar2 := "Falso"
                Else
                    _cVar1 := AllTrim((_cAlias)->(FieldGet(FieldPos(_cVarMem))))
                    _cVar2 := AllTrim(aCols[_nCount,_nPos])
                Endif
                _cMens := "Alteração do campo "+ AllTrim(FWX3Titulo(_cVarMem)) +" "+ _cEol +;
                          "Antes : "  + _cVar1 +" "+ _cEol +;
                          "Depois: "  + _cVar2 +" "+ _cEol 
                AAdd( _aMens,{   _cMens,;
                                aCols[ _nCount,_nPosItem ],;   //numero do item
                                aCols[ _nCount, _nCol + 2 ], ;  //Registro do item
                                "A", ;                          //Tipo de Operação                         
                                _cVarMem, ;                     //Campo
                                _cVar1, ;                       //Conteudo anterior
                                _cVar2, ;                       //Conteudo Alterado
                                _cVarTit ;                      //Conteudo Titulo
                            })
            Endif
        Next _nCount
	Next _nPos
    //somente alteração ou exlusão para validar o cabeçalho
    If _nOpc == 4  .or. _nOpc == 5
        //verificar divergências gravar de cabeçalho para gravação
        CarrMatF15(@_aMens, _cTipo, StrZero(0,Len(SZH->ZH_ITEM)), 0, _nOpc)
    EndIf

Return _lRet 


//========================================================================
//Efetua a validação das variaveis de memoria existentes na SC ou  Pedido

Static Function CarrMatF15(_aMens, _cTipo, _cNumIt, _nRegistro, _nOpc)
Local _aMat := {}
Local _cMens
Local _cVar
Local _cVar1
Local _cVar2
Local _cVarMem
Local _cVarTit
Local _nPos 
Local _lVar
Local cMensage := ""

    //Verifica se ocorreu deleção    
    If _nOpc == 5  //deleção
        _cMens :=   "Exclusão  "+ If(_cTipo=="SC","Solicitação Compras",;
                                  If(_cTipo=="PC","Pedido de Compras",;
                                  If(_cTipo=="AE","Autorização de Entrega",;
                                  If(_cTipo=="CP","Contrado Parceria",;
                                  "Não detinido Tipo "+_cTipo))))
        AAdd( _aMens, {     _cMens,;
                            _cNumIt,;       //numero do item
                            _nRegistro, ;   //Registro do item
                            "E", ;          //Tipo de Operação                         
                            "*", ;          //Campo
                            "", ;           //Conteudo anterior
                            "", ;           //Conteudo Alterado
                            "*" ;           //Conteudo Titulo
                      })
        Return Nil
    EndIf
    
    //Funcionalidade responsavel por carregar as variaveis e campos que serão testados de acordo com o tipo de documento
    _aMat := carregaF15(_cTipo)
    If Len(_aMat) == 0
        cMensage := "Exite problemas na chamada da função ZCOMF015 não conseguiu montar os campos, contatar admnistrador do Sistema"
        If lIsBlind
            Conout(cMensage)
        Else
            Msgalert(cMensage)
        EndIf

        Return Nil
    EndIf

    //Efetua a validação das variaveis de memoria existentes na SC ou  Pedido
    For _nPos := 1 To Len(_aMat)
        //Verifica se existe o campo no dicionarios
        If Type(_aMat[_nPos,1]) == Nil
            Loop
        EndIf
        If FieldPos(_aMat[_nPos,1]) == 0
            Loop
        Endif     
        _cVar       := FieldGet(FieldPos(_aMat[_nPos,1])) 
        _cVarTit    := _aMat[_nPos,1]
        _cVarMem    := _aMat[_nPos,1]
        If _cVar == Nil 
            Loop
        Endif    
        If ValType(_cVar) == "N"
            _cVar1 := AllTrim(Str(_cVar))
            //necessario fazer esta condição devido ao processo possuir problemas com trocas de campos que ainda não foram corrigidas possuem tipo diferente
            If ValType(_aMat[_nPos,2]) <> "N"
                _cVar2 := 0
            Else
                _cVar2 := AllTrim(Str(_aMat[_nPos,2]))
            Endif    
        ElseIf ValType(_cVar) == "D"
            _cVar1 := DtoC(_cVar)
            _cVar2 := DtoC(_aMat[_nPos,2])
        ElseIf ValType(_cVar)  == "L" 
            If _cVar
                _cVar1 := "Verdadeiro"
            Else
                _cVar1 := "Falso"
            EndIf    
            _lVar := _aMat[_nPos,2]
            If _lVar
                _cVar2 := "Verdadeiro"
            Else
                _cVar2 := "Falso"
            EndIf    
        Else
            _cVar1 := AllTrim(_cVar)
            _cVar2 := AllTrim(_aMat[_nPos,2])
        Endif
        //se ocorrerem digergencias guardar mensagem para ser mostrada na tela
       
        If _cVar1 <> _cVar2 .or. _cVar2 <> _cVar1  //necessario pois se perde quanto ao tamanho do cmapo em alguns casos DAC 24/08/2020
            _cMens :=   "Alteração do campo "+AllTrim(FWX3Titulo(_aMat[_nPos,1])) +" "+ _cEol +;
                        "Antes : "  + _cVar1 +" "+ _cEol +;
                        "Depois: "  + _cVar2 +" "+ _cEol 
            AAdd( _aMens, {     _cMens, ;
                                _cNumIt, ;                      //numero do item
                                _nRegistro, ;                   //Registro do item
                                "A", ;                          //Tipo de Operação                         
                                _cVarMem, ;                     //Campo
                                _cVar1, ;                       //Conteudo anterior
                                _cVar2, ;                       //Conteudo Alterado
                                _cVarTit;                        //Conteudo Alterado
                          })
        Endif    
    Next _nPos

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ApvAudiF15
Carregar informações processadas para mostrar na tela e solicitar a informação do Motic
@author DAC denilso.carvalho
@since 05/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ApvAudiF15(_aMens, _cDoc, _cTipo, _lGeral)

Local _aMotivo  := {}
Local _aCab     := {}
//Local _cMotivo  := Space(10)
Local _lRet     := .T.
Local _nPos 
Local _cItem    
Local _cRevisao  
//Local _cUsuario 
Local _cData 
Local _cHora 

Default _lGeral := .F.

    For _nPos := 1 To Len(_aMens)
        //If _lGeral  //Quando esta sendo perquisado(menu Hitorico) e não incluido historico
        //    //Criar select com dados
        //Else
            _aCab     := {}
            _cItem    := _aMens[_nPos,02]
            If _lGeral
                _cRevisao   := _aMens[_nPos,08]   //quando for para mostrar todos o array tem um campo a mais que indica a revisão
                _cMotivo    := _aMens[_nPos,09]
                _cUsuario   := _aMens[_nPos,10]
                _cData      := _aMens[_nPos,11]
                _cHora      := _aMens[_nPos,12]
            Else
                _cRevisao   := StrZero(0,Len(SZH->ZH_REVISAO)) 
                //_cUsuario   := RETCODUSR()
                _cData      := Date()
                _cHora      := Time()
            Endif    
            AAdd(_aCab  ,{ "ZH_ORIGEM"      , _cTipo                ,/*tamanho*/,.T. /*mostrar browse*/})
            AAdd(_aCab  ,{ "ZH_DOCTO"       , _cDoc                 ,/*tamanho*/,.T.})
            AAdd(_aCab  ,{ "ZH_ITEM"        , _cItem                ,/*tamanho*/,.T.})             
            AAdd(_aCab  ,{ "ZH_REVISAO"     , _cRevisao             ,/*tamanho*/,.T.})
            AAdd(_aCab  ,{ "Ajustes"        , _aMens[_nPos,01]      ,30         ,.T.})      //ZH_AJUSTE
            AAdd(_aCab  ,{ "ZH_OPER   "     , _aMens[_nPos,04]      ,/*tamanho*/,.F.})
            AAdd(_aCab  ,{ "ZH_CAMPO  "     , _aMens[_nPos,05]      ,/*tamanho*/,.F.})
            AAdd(_aCab  ,{ "ZH_INFOANT"     , _aMens[_nPos,06]      ,/*tamanho*/,.F.})
            AAdd(_aCab  ,{ "ZH_INFATUA"     , _aMens[_nPos,07]      ,/*tamanho*/,.F.})
            AAdd(_aCab  ,{ "ZH_TITULO "     , _aMens[_nPos,05]      ,/*tamanho*/,.F.})
            AAdd(_aCab  ,{ "ZH_MOTIVO"      , _cMotivo              ,/*tamanho*/,.T.})
            AAdd(_aCab  ,{ "Usuário"        , UsrRetName(_cUsuario) ,30         ,.T.})
            AAdd(_aCab  ,{ "Nome Usuário"   , UsrFullName(_cUsuario),40         ,.T.})
            AAdd(_aCab  ,{ "ZH_DATAI"       , _cData                ,/*tamanho*/,.T.})
            AAdd(_aCab  ,{ "ZH_HORAI"       , _cHora                ,/*tamanho*/,.T.})
            AAdd(_aCab  ,{ "ZH_NUMREG"      , _aMens[_nPos,3]       ,/*tamanho*/,.T.})

            AAdd(_aMotivo,_aCab)

        //Endif                    
    Next

    If Len(_aMotivo) > 0 .and. !INCLUI  //acrescentado conforme solicitação Douglas não mostrar tela quando da influsão
        //funcao responsavel por montar tela para a confirmação dos dados de auditoria com um motiva previamente descrito pelo usuário
        if !lIsBlind
            _lRet := TelAudiF15( _aMotivo, @_cMotivo, _lGeral)  
        Else
            _lRet := .T.
        EndIf
    Endif

    If !_lGeral .and. _lRet  //_lGeral indica somente a visualização
        If INCLUI
            _cMotivo := "INCLUSAO E REGISTRO"
        Endif
        GrvAudiF15(_aMens,_cDoc,_cTipo,_cMotivo)
    Endif

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ApvAudiF15
Gravar dados na tabela SZH referente ao historico
@author DAC denilso.carvalho
@since 05/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GrvAudiF15(_aMens,_cDoc,_cTipo,_cMotivo)
Local _lRet         := .T.
Local _lNovo        := .T.
Local _cAliasTab    := GetNextAlias()
Local _cRevisao     := Strzero(0,Len(SZH->ZH_REVISAO))
Local _cItem        
Local _nPos

    BeginSql Alias _cAliasTab	
   	    SELECT MAX(SZH.ZH_REVISAO) AS REVISAO
	    FROM %Table:SZH%  SZH 
	    WHERE 	SZH.ZH_FILIAL = %xFilial:SZH% 
		    AND SZH.ZH_ORIGEM = %Exp:_cTipo%
		    AND SZH.ZH_DOCTO  = %Exp:_cDoc%
		    AND SZH.%notDel% 
    EndSQL

    If (_cAliasTab)->(!EOF())
        _cRevisao := (_cAliasTab)->REVISAO
    Endif
    //A revisão será sempre a mesma para a operação em curso
    _cRevisao       := soma1(_cRevisao)
    For _nPos := 1 To Len(_aMens)
        _cItem          :=  _aMens[_nPos,2]
        RecLock( "SZH", _lNovo) 
        SZH->ZH_FILIAL  :=  XFilial("SZH")
        SZH->ZH_ORIGEM  :=  _cTipo
        SZH->ZH_DOCTO   :=  _cDoc
        SZH->ZH_ITEM    :=  _cItem  
        SZH->ZH_REVISAO :=  _cRevisao
        SZH->ZH_OPER    :=  _aMens[_nPos,4]
        SZH->ZH_CAMPO   :=  _aMens[_nPos,5]
        SZH->ZH_INFOANT :=  _aMens[_nPos,6]
        SZH->ZH_INFATUA :=  _aMens[_nPos,7]
        SZH->ZH_TITULO  :=  Upper(FWX3Titulo(_aMens[_nPos,5]))  //_aMens[_nPos,8] trazer o título do campo
        SZH->ZH_MOTIVO  :=  Upper(AllTrim(_cMotivo))
        SZH->ZH_NUMREG  :=  _aMens[_nPos,3]
        SZH->ZH_CODUSU  :=  _cUsuario//RETCODUSR() 
        SZH->ZH_DATAI   :=  Date()
        SZH->ZH_HORAI   :=  Time()
        SZH->(MsUnlocK())
    Next    
If Select(_cAliasTab) <> 0 ; (_cAliasTab)->(DbCloseArea()) ; Ferase(_cAliasTab+GetDBExtension()) ; EndIf

Return _lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TelAudiF15
Gravar dados na tabela SZH referente ao historico
@author DAC denilso.carvalho
@since 05/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TelAudiF15(_aMotivo,_cMotivo,_lGeral)

Local _lRet			:= .T.
Local _aItem    	:= {}
Local _aCab			:= {}
Local _aGrava 		:= {}
Local _aItemNovo 	:= {}
Local _aButtons		:= {}
Local _aInfo 
Local _aPosObj 

Local _aCoors
Local _oDlg
Local _nPos
Local _nPos2
Local _oFWLayer
Local _oPanelUp
Local _oPanelDown
Local _aSize
Local _oLbx
Local _aObjects
Local _cCab
Local _aPict 
Local _aTam 

Local _oFontCN10 	:= TFont():New("Courier New",10,0)
Local _oFontT12		:= TFont():New("Tahoma",,-12,.T.,.T.)
Local _oAzul        := LoadBitmap(GetResources(),'br_azul')
Local _oVerde       := LoadBitmap(GetResources(),'br_verde')
Local _oVermelho    := LoadBitmap(GetResources(),'br_vermelho')
Local _oCinza       := LoadBitmap(GetResources(),'br_cinza')

Default _cMotivo := SZH->ZH_MOTIVO
Default _lGeral  := .F.

    SX3->(DbSetOrder(2))
	//Prepara array para visualização
	_aCab  := {}
	_aItem := {}
    _aPict := {}
    _aTam  := {}

    Aadd(_aCab ,"St")
    Aadd(_aPict,"")
    Aadd(_aTam ,2)
	For _nPos := 1 To Len(_aMotivo)
		_aGrava 	:= _aMotivo[_nPos]
		_aItemNovo 	:= {}
        AAdd(_aItemNovo,"")
		For _nPos2 := 1 To Len(_aGrava)
            //Verifica se mostrara no browse dados sobre o campo
	        If Len(_aGrava[_nPos2]) > 3 .and. ValType(_aGrava[_nPos2,4]) == "L" .and. !_aGrava[_nPos2,4]
                Loop
            EndIf 
    		If _nPos == 1  //primeira vez gravo acab adiciono cabeçalho
                _cCab := FWX3Titulo(_aGrava[_nPos2,01])
                //para campos que não estão no dicionário
                If !Empty(_cCab)
    			    Aadd(_aCab,FWX3Titulo(_aGrava[_nPos2,01]))
                Else
    			    Aadd(_aCab,_aGrava[_nPos2,01])
                Endif    
   			    Aadd(_aPict,PictMotF15(_aGrava[_nPos2,01],_aGrava[_nPos2,02]))
                Aadd(_aTam ,TamMoTF15(_aGrava,_nPos2,01))
			EndIf
			AAdd(_aItemNovo,_aGrava[_nPos2,02])	
		Next
		AAdd(_aItem,_aItemNovo)  //adiciono itens
	Next	
    aSort(_aItem,,,{|x,y| x[5]+x[4] < y[5]+y[4] })
	//Gravo o motivo relacionado ao ultimo item
	//_cMotivo := _aItem[Len(_aItem),6]
    _cMotivo := ""
 	_aCoors  := FwGetDialogSize( oMainWnd )
	_aCoors[1] += 100
	_aCoors[2] += 100
	_aCoors[3] -= 150
	_aCoors[4] -= 300
	//DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 080,300 PIXEL
	Define MsDialog _oDlg Title "Historico de Alteracoes" From _aCoors[1], _aCoors[2] To _aCoors[3], _aCoors[4] Pixel STYLE DS_MODALFRAME

	_oFWLayer := FWLayer():New()
	_oFWLayer:Init( _oDlg, .F., .T. )

	// Painel Superior
	_oFWLayer:AddLine( 'UP', If(_lGeral,80,50), .F. )
	_oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	_oPanelUp 	:= _oFWLayer:GetColPanel( 'ALL', 'UP' )
	//aRotina 	:= {}

    _aSize := MsAdvSize(,.F.,400)
    _aObjects := {}
    
    AAdd( _aObjects, { 100, 100, .T., .T. } )
    AAdd( _aObjects, { 10,   10, .T., .T. } )

    _aInfo := { _aSize[ 1 ], _aSize[ 2 ], _aSize[ 3 ], _aSize[ 4 ], 3, 3 }
    _aPosObj := MsObjSize( _aInfo, _aObjects,.T.)

    
    _oLbx  := TWBrowse():New( _aPosObj[1,1]+5, _aPosObj[1,2], _aPosObj[1,4], _aPosObj[1,3],/*bLine*/  , ;
                            /*aHeaders*/, _aSize, _oPanelUp , /*cField*/   , /*uValue1*/  , /*uValue2*/ , ;
                            /*bChange*/ , /*bLDblClick*/    , /*bRClick*/  , _oFontCN10   , /*oCursor*/ , ;
                            /*nClrFore*/, /*nClrBack*/      , /*cMsg*/     , .F.          , /*cAlias*/  , ;
                            .T.         , /*bWhen*/         , .F.          , /*bValid*/   , /*lHScroll*/, ;
                            /*lVScroll*/)		
    //Montar campos para o Browse
   	For _nPos := 1 To Len(_aCab)
        AddColBrw(@_oLbx,_nPos, _aCab,_aItem, _aPict,_aTam,_oAzul,_oVerde,_oVermelho,_oCinza)
    Next _nPos    

    _oLbx:SetArray(_aItem)
    _oLbx:SetFocus()   
    _oLbx:Refresh()    
    _oLbx:align:= CONTROL_ALIGN_ALLCLIENT
    _oLbx:bLDblClick   := {|| VMotAudit(_oLbx,_aItem) }

	If !_lGeral
        // Painel Inferior
	    _oFWLayer:addLine( 'DOWN', 50, .F. )
	    _oFWLayer:AddCollumn( 'CASOS',  100, .T., 'DOWN' )
	    _oPanelDown := _oFWLayer:GetColPanel( 'CASOS', 'DOWN' )
	    //_cMotivo := Space(500)
	    TSay():New( 005,030,{||OemToAnsi("Motivo do Procedimento ?")},_oPanelDown,,_oFontT12,.F.,.F.,.F.,.T.,CLR_BLACK) 
  	    _oMotivo := tMultiget():create( _oPanelDown, {| u | if( pCount() > 0, _cMotivo := u, _cMotivo ) },;
	  	    										 15, 03, 450, 40, _oFontT12, , , , , .T. )	
    Endif

	_oDlg:lEscClose := .F.  //não permitir ESC
	ACTIVATE MSDIALOG _oDlg CENTERED ON INIT EnchoiceBar(_oDlg,{|| _nOpc := 1,If(VldMotiF15( _cMotivo, _lGeral ),_oDlg:End(),_nOpc := 0)},;
                                                               {||If(VldMotiF15( _cMotivo, _lGeral ),If(_lGeral,_oDlg:End(),_nOpc := 0),_nOpc := 0)},,_aButtons)

Return _lRet

//Montar campos no browse
Static Function AddColBrw(_oLbx,_nPos, _aCab,_aItem, _aPict,_aTam,_oAzul,_oVerde,_oVermelho,_oCinza)

    If _nPos == 1
        _oLbx:AddColumn(TCColumn():New(_aCab[01], {|| If(_aItem[_oLbx:nAt,02]=="PC", _oAzul  ,;
                                                      If(_aItem[_oLbx:nAt,02]=="SC", _oVerde ,;
                                                      If(_aItem[_oLbx:nAt,02]=="AE", _oVermelho ,; 
                                                         _oCinza))) } ,;
                                                      ,,,"LEFT", 010,.T.,.F.,,{|| .F. },,.F., ) )

    Else
        _oLbx:AddColumn(TCColumn():New(_aCab[_nPos], {|| _aItem[_oLbx:nAt,_nPos]}	,_aPict[_nPos] ,,,"LEFT", _aTam[_nPos] ,.F.,.F.,,{|| .F. },,.F., ) )
    Endif

Return Nil

//Mostrar dados do motivo
Static Function VMotAudit(_oLbx,_aItem)

Local _cTexto1
Local _cTexto2
Local _oTMultiget1
Local _oTMultiget2

    DEFINE DIALOG _oDlg TITLE "Ajuste / Motivo" FROM 180, 180 TO 550, 700 PIXEL
    _cTexto1 := "Ajuste"+_cEol
    _cTexto1 += Upper(_aItem[_oLbx:nAt,6])
    _cTexto2 := "Motivo"+_cEol
    _cTexto2 += Upper(_aItem[_oLbx:nAt,7])

    _oTMultiget1 := tMultiget():new( 01, 01, {| x | if( pCount() > 0, _cTexto1 := x, _cTexto1 ) }, ;
                                    _oDlg, 260, 92, , , , , , .T. )
    _oTMultiget2 := tMultiget():create( _oDlg, {| x | if( pCount() > 0, _cTexto2 := x, _cTexto2 ) }, 92, 01, ;
                    260, 92, , , , , , .T. )
  ACTIVATE DIALOG _oDlg CENTERED

Return .T.

//Retornar a pict para o campo no SX3 algumas não estão preenchidas sendo necessário este retorno
Static Function PictMotF15(_cCampo, xValor)

Local _cPict := X3PICTURE(_cCampo) 
    //Caso localizou a pict não sera necessario validar
    If _cPict <> Nil .and. !EmPty(_cPict)
         Return _cPict 
    Endif 

    //Caso não Localizou será necessário  informar verificando o tipo
    If ValType("xValor") == "N"
        _cPict  := "@E "+Replicate("9",Len(xValor)) 
    ElseIf ValType("xValor") == "D"
        _cPict  := "@D"
    Else
        _cPict  := "@!"
    Endif

 Return _cPict    


//Retornar o Tamanho
Static Function TamMoTF15(_aGrava,_nPos,_nCol)

Local _nTam := 10

    If Len(_aGrava[_nPos]) > 2 .and. ValType(_aGrava[_nPos,3]) == "N" //Caso seja maior que 2 é que possui tamanho predefinido 
        _nTam  := _aGrava[_nPos,3]
        Return _nTam 
    Endif

    _nTam := TamSX3(_aGrava[_nPos,_nCol])[1]
    If _nTam == Nil .or. _nTam <= 0
        _nTam := 10
    Endif    

Return _nTam 

//=====================================
Static Function VldMotiF15( _cMotivo, _lGeral )

Local _lRet := .T.	
    If _lGeral  //quando for para mostrar tudo não validar motivo
        Return _lRet
    Endif
    If Empty(_cMotivo) 
        //Conforme reunião 18/03/2020 Aide informou que não é necessário estar obrigatório DAC 19/03/2020
        //alinhado com Evandro que fique obrigatório 24/08/2020 não entre nesta opção quando for inclusão
        _lRet := .F.
        MsgAlert("Necessário informar o Motivo da Alteração")
    Endif    
 
 Return _lRet   

//Retornar um array com informação do campo no banco e da variavel relativa ao campo para que possa processar e validar as informações neste
Static Function carregaF15(_cTipo)

Local _aRet     := {}
Local _aRetVal  := {}
Local _nPos

    //Solicitação de Compras
    If _cTipo == "SC"  
        DbSelectarea("SC1")
        Aadd(_aRet,{"C1_DRPIMP"     ,"cDRP"})
        Aadd(_aRet,{"C1_SOLICIT"    ,"cSolic"})
        Aadd(_aRet,{"C1_EMISSAO"    ,"dA110Data"})   
        Aadd(_aRet,{"C1_UNIDREQ"    ,"cUnidReq"})
        Aadd(_aRet,{"C1_CODCOMP"    ,"cCodCompr"})
        Aadd(_aRet,{"C1_DRPIM"      ,"cFilEnt"})
        Aadd(_aRet,{"C1_NATUREZ"    ,"cCodNatu"})
        Aadd(_aRet,{"C1_XTIPOSC"    ,"cTpSC"})
        Aadd(_aRet,{"C1_CC"         ,"cCCusto"})   
        Aadd(_aRet,{"C1_XNUMCT"     ,"cNumCt" })
        Aadd(_aRet,{"C1_XNUMREV"    ,"cNumRev"})
        Aadd(_aRet,{"C1_XSOL"       ,"cReqSol"})
        Aadd(_aRet,{"C1_FILENT"     ,"cFilEnt"})
        Aadd(_aRet,{"C1_TPOP"       ,"cTpOp"})
        Aadd(_aRet,{"C1_XTPIMP"     ,"cC1_XTPIMP"})
        Aadd(_aRet,{"C1_NR_PRO"     ,"cC1_NR_PRO"})
        Aadd(_aRet,{"C1_MOEDA"      ,"cC1_MOEDA"})
        Aadd(_aRet,{"C1_XTPREQ"     ,"cC1_XTPREQ"})
        Aadd(_aRet,{"C1_XREQUIS"    ,"cC1_XREQUIS"})
        Aadd(_aRet,{"C1_XREQFON"    ,"cC1_XREQFON"})
        Aadd(_aRet,{"C1_XREQMAI"    ,"cC1_XREQMAI"})
        Aadd(_aRet,{"C1_XOBSREQ"    ,"cC1_XOBREQ"})
        Aadd(_aRet,{"C1_XOBSITE"    ,"cC1_XOBITE"})

    //Contrato de Parceria    
    ElseIf _cTipo $ "CP"  
        DbSelectarea("SC3")
        AAdd(_aRet  ,{ "C3_EMISSAO", "dA125Emis"  })  
	    AAdd(_aRet  ,{ "C3_FORNECE", "cA125Forn"  })  
	    AAdd(_aRet  ,{ "C3_LOJA"   , "cA125Loj"   })  
	    AAdd(_aRet  ,{ "C3_COND"   , "cCondicao"  })  
	    AAdd(_aRet  ,{ "E4_DESCRI" , "cDescCond"  })  
	    AAdd(_aRet  ,{ "C3_CONTATO", "cContato"   })  
	    AAdd(_aRet  ,{ "C3_FILENT" , "cFilialEnt" })  
	    AAdd(_aRet  ,{ "C3_MSG"    , "cMsg"       })  
	    AAdd(_aRet  ,{ "C3_REAJUST", "cReajuste"  })  
	    AAdd(_aRet  ,{ "C3_TPFRETE", "cTpFrete"   })  
	    AAdd(_aRet  ,{ "C3_MOEDA"  , "nMoeda"     })  
	    AAdd(_aRet  ,{ "C3_TXMOEDA", "nTxMoeda"   })	
        Aadd(_aRet  ,{ "C3_XOBSREQ", "cC3_SCOP"   })

    //Pedido de Compras    
    ElseIf _cTipo $ "PC_AE"  
        DbSelectarea("SC7")
        AAdd(_aRet  ,{ "C7_EMISSAO", "dA120Emis"})  
	    AAdd(_aRet  ,{ "C7_FORNECE", "cA120Forn"})  
	    AAdd(_aRet  ,{ "C7_LOJA"   , "cA120Loj"})  
	    AAdd(_aRet  ,{ "C7_COND"   , "cCondicao"})  
	    AAdd(_aRet  ,{ "E4_DESCRI" , "cDescCond"})  
	    AAdd(_aRet  ,{ "C7_CONTATO", "cContato" })  
	    AAdd(_aRet  ,{ "C7_FILENT" , "cFilialEn"})  
        AAdd(_aRet  ,{ "C7_PROVENT", "cA120ProvEnt" })
	    AAdd(_aRet  ,{ "C7_MSG"    , "cMsg"      })  
	    AAdd(_aRet  ,{ "C7_REAJUST", "cReajuste" })  
	    AAdd(_aRet  ,{ "C7_TPFRETE", "cTpFrete"  })  
	    AAdd(_aRet  ,{ "C7_DESC1"  , "nDesc1"    })  
	    AAdd(_aRet  ,{ "C7_DESC2"  , "nDesc2"    })  
	    AAdd(_aRet  ,{ "C7_DESC3"  , "nDesc3"	 }) 
	    AAdd(_aRet  ,{ "C7_NATUREZ", "cCodNatu"  })  
	    AAdd(_aRet  ,{ "C7_TPOP"   , "cTpOP"	 })	
	    AAdd(_aRet  ,{ "C7_MOEDA"  , "nMoedaPed" })  
	    AAdd(_aRet  ,{ "C7_TXMOEDA", "nTxMoeda"  })	
	    AAdd(_aRet  ,{ "C7_PROVENT", "lProvEnt"  })
        Aadd(_aRet  ,{ "C7_XOBSCOM", "cC7_SCOM"  })
        Aadd(_aRet  ,{ "C7_XOBSFOR", "cC7_SFOR"  })
        Aadd(_aRet  ,{ "C7_XOBSTST", "cC7_XOCOM" })
    Endif
    //Reponsável por verificar se existe o campo 
    _aRetVal := {}
    For _nPos := 1 To Len(_aRet)
        _cVar := _aRet[_nPos,2]
        If Type( _cVar ) != "U"
            Aadd(_aRetVal,{ _aRet[_nPos,1],&_cVar  })
        Endif
    Next _nPos


Return _aRetVal

//-------------------------------------------------------------------
/*/{Protheus.doc} VisMotiF15
Selecionar dados na tabela SZH referente ao historico para visualizar na tela
@author DAC denilso.carvalho
@since 16/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VisMotiF15( _cDoc, _cTipo, _lGeral )

Local _cAliasTab    := GetNextAlias()
Local _aMens        := {}
Local _cMens
Local _cOper

    BeginSql Alias _cAliasTab	
   	    SELECT SZH.R_E_C_N_O_ NREGSZH
	    FROM %Table:SZH%  SZH 
	    WHERE 	SZH.ZH_FILIAL = %xFilial:SZH% 
		    AND SZH.ZH_ORIGEM = %Exp:_cTipo%
		    AND SZH.ZH_DOCTO  = %Exp:_cDoc%
		    AND SZH.%notDel% 
    EndSQL

    If (_cAliasTab)->(EOF())
        if lIsBlind
            Conout("Não existe histórico para este documento")
        else
            Msgalert("Não existe histórico para este documento")
        endif
        Return Nil
    Endif
    
    While (_cAliasTab)->(!EOF())
        SZH->(DbGoto( (_cAliasTab)->NREGSZH))
        If SZH->ZH_OPER == "A"
            _cOper := "Alteração de campo"
        ElseIf SZH->ZH_OPER == "I"
            _cOper := "Inclusão"
        ElseIf SZH->ZH_OPER == "E"
            _cOper := "Exclusão"
        Else
            _cOper := SZH->ZH_OPER+" <--- Não definido verificar"
        Endif
        _cMens :=   _cOper+" "+AllTrim(FWX3Titulo(SZH->ZH_CAMPO)) +" "+ _cEol +;
                    "Antes : "  + AllTrim(SZH->ZH_INFOANT) +" "+ _cEol +;
                    "Depois: "  + AllTrim(SZH->ZH_INFATUA) +" "+ _cEol 
        AAdd( _aMens, { _cMens,         ;                   //SZH->ZH_AJUSTE anteriormente campo sera exluido
                        SZH->ZH_ITEM,   ;             //numero do item
                        SZH->ZH_NUMREG, ;           //Registro do item (_cAliasTab)->NREGSZH
                        SZH->ZH_OPER,   ; 
                        SZH->ZH_CAMPO,  ;
                        SZH->ZH_INFOANT,;
                        SZH->ZH_INFATUA,;
                        SZH->ZH_REVISAO,;
                        SZH->ZH_MOTIVO, ;
                        SZH->ZH_CODUSU, ;
                        SZH->ZH_DATAI,  ;
                        SZH->ZH_HORAI   ; 
                        })

        (_cAliasTab)->(DbSkip())
    Enddo
    ApvAudiF15( _aMens, _cDoc, _cTipo, _lGeral)

If Select(_cAliasTab) <> 0 ; (_cAliasTab)->(DbCloseArea()) ; 	Ferase(_cAliasTab+GetDBExtension()) ; Endif  

Return Nil

Static Function GetTab(_cTpDoc,_cDoc)
Local lRet := .T.

Default _cDoc := ""
DbSelectArea("SC7")
SC7->(DbSetOrder(1))
if !SC7->(DbSeek(xFilial("SC7") + _cDoc))
    lRet := .F.
endif

DbSelectArea("SC1")
SC1->(DbSetOrder(1))
if !SC1->(DbSeek(xFilial("SC1") + _cDoc))
    lRet := .F.
endif

DbSelectArea("SC3")
SC3->(DbSetOrder(1))
if !SC3->(DbSeek(xFilial("SC3") + _cDoc))
    lRet := .F.
endif

Return lRet




//-------------------------------------------------------------------
/*/{Protheus.doc} TelAudiF15
Gravar dados na tabela SZH referente ao historico
@author DAC denilso.carvalho
@since 05/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function TelMotivo(_cMotivo)

Local _lRet			:= .T.
Local _aItem    	:= {}
Local _aCab			:= {}
//Local _aGrava 		:= {}
//Local _aItemNovo 	:= {}
Local _aButtons		:= {}
//Local _aInfo 
//Local _aPosObj 

Local _aCoors
Local _oDlg
//Local _nPos
//Local _nPos2
Local _oFWLayer
//Local _oPanelUp
Local _oPanelDown

Local _aPict 
Local _aTam 
Local _oFontT12		:= TFont():New("Tahoma",,-12,.T.,.T.)

Default _cMotivo := SZH->ZH_MOTIVO
Default _lGeral  := .F.

    SX3->(DbSetOrder(2))
	//Prepara array para visualização
	_aCab  := {}
	_aItem := {}
    _aPict := {}
    _aTam  := {}

    Aadd(_aCab ,"St")
    Aadd(_aPict,"")
    Aadd(_aTam ,2)
	
	//Gravo o motivo relacionado ao ultimo item
	//_cMotivo := _aItem[Len(_aItem),6]
    _cMotivo := ""
 	_aCoors  := FwGetDialogSize( oMainWnd )
	_aCoors[1] += 100
	_aCoors[2] += 100
	_aCoors[3] -= 150
	_aCoors[4] -= 300
	//DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 080,300 PIXEL
	Define MsDialog _oDlg Title "Historico de Alteracoes" From _aCoors[1], _aCoors[2] To _aCoors[3], _aCoors[4] Pixel STYLE DS_MODALFRAME

	_oFWLayer := FWLayer():New()
	_oFWLayer:Init( _oDlg, .F., .T. )
	// Painel Superior
    _oFWLayer:AddLine( 'UP', 80, .F. )
	_oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	_oPanelDown := _oFWLayer:GetColPanel( 'ALL', 'UP' )
    
    //_cMotivo := Space(500)
    TSay():New( 005,030,{||OemToAnsi("Motivo do Procedimento ?")},_oPanelDown,,_oFontT12,.F.,.F.,.F.,.T.,CLR_BLACK) 
    _oMotivo := tMultiget():create( _oPanelDown, {| u | if( pCount() > 0, _cMotivo := u, _cMotivo ) },;
	  	    										 15, 03, 450, 80, _oFontT12, , , , , .T. )	

	_oDlg:lEscClose := .F.  //não permitir ESC
	ACTIVATE MSDIALOG _oDlg CENTERED ON INIT EnchoiceBar(_oDlg,{|| _nOpc := 1,If(VldMotiF15( _cMotivo, _lGeral ),_oDlg:End(),_nOpc := 0)},;
                                                               {||If(VldMotiF15( _cMotivo, _lGeral ),If(_lGeral,_oDlg:End(),_nOpc := 0),_nOpc := 0)},,_aButtons)

Return _lRet
