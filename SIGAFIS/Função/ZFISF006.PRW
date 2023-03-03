#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

Static _oBrowse 	
Static _nQtdRegSel
Static _nQtdeReg
Static _cNCM

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZFISF006
Rdmake 	Alteração de PiS e CONFINS por NCM
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC - Denilso 
@single		25/09/2020
@version    Nao Informado
@since      Nao Informado  
@return    	Nil
@sample     Nao Informado
@obs        
@project    CAOA - FIS002	-	Retenção PIS/COFINS
@menu       Nao Informado
@history    

87089990 ncm
/*/

User Function ZFISF006()
Local _aParamBox	:= {}
Local _aRet 		:= {}
//Local _cNCM			:= Space(TamSx3("YD_TEC")[1])
Local _aArea 	    := GetArea()
Local _lZFISF006    := SuperGetMV( "CMV_FIS003"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade
Begin Sequence
	_cNCM := Space(TamSx3("YD_TEC")[1])
    //Caso esteja desabilitado parametro
    If !_lZFISF006
        Break
    Endif

	//Verificar se o Usuário esta habilitado no padrão CAOA
	//If !U_ZGENUSER( RetCodUsr() ,"ZFISF006" ,.T.)	
	//	Break
	//EndIf
	DbSelectArea("SB1")
    SetFunName('ZFISF006')
	aAdd(_aParamBox,{ 1, "Informar Nomenclatura Ext.Mercosul ", _cNCM, "@!", "", "SYD","", 50	,.T.})
	If !ParamBox( _aParamBox ,"Parametros" ,@_aRet )
       	Break
   	EndIf
	If Len(_aRet) < 1  //Não foi preenchido todos os campos
        Msgalert("Necessário informar Nomenclatura Ext.Mercosul")
		Break
	EndIf
	_cNCM := _aRet[1]
	ZFISF006TE(/*_aRet[1]*/)
End Sequence
RestArea(_aArea)
Return Nil




//-------------------------------------
/*/{Protheus.doc} ZFISF006VL
//Verificar e atualizar contador de registros selecionados
@author DAC - Denilso
@since 01/10/2020
@version 1.0
/*/
//-------------------------------------
//
Static Function ZFISF006VL
Local _cMarca := _oBrowse:Mark()
Begin Sequence
    If _oBrowse:IsMark(_cMarca)
		_nQtdRegSel += 1
	ElseIf _nQtdRegSel > 0
		_nQtdRegSel -= 1	
	Endif
End Sequence
Return .T.




//-------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef
@author DAC - Denilso
@since 01/09/2020
@version 1.0
/*/
//-------------------------------------
Static Function MenuDef()
Local _aRotina 	:= {}
//Local _aRotina := FWMVCMenu("ZCOMF022")
Begin Sequence	
	ADD OPTION _aRotina TITLE "Visualizar"		ACTION 'ZFISF006VI()' 	OPERATION 2 ACCESS 0
	ADD OPTION _aRotina TITLE "Processar"		ACTION 'ZFISF006PR()' 	OPERATION 2 ACCESS 0
	//ADD OPTION _aRotina TITLE "Pesquisar"  		ACTION 'PesqBrw' 						OPERATION 1 ACCESS 0
	//ADD OPTION _aRotina TITLE "Imprimir" 	ACTION "VIEWDEF.ZCOMF022" 	OPERATION 8 ACCESS 0
End Sequence
Return _aRotina




//-------------------------------------
/*/{Protheus.doc} ZFISF006TE
Montar Browse de seleção com produto
@author DAC - Denilso
@since 25/09/2020
@version 1.0
@Obs 	DAC - 27/10/2020
		Refeito para selecionar apartir de temporario na produção por algum motivo esta se perdendo quando direto do banco
	
/*/
//-------------------------------------
Static Function ZFISF006TE(/*_cNCM*/)
Local _aVar		  	:= {}
Local _aCampos	  	:= {}
//Local _aFieFilter := {}
Local _aSeek	  	:= {}
Local _cCab		  	:= "Alteração PIS/CONFINS por N.C.M. "+_cNCM //+_cNCM
Local _aColunas  	:= {'B1_FILIAL','B1_PIS','B1_COFINS','B1_COD','B1_DESC','B1_POSIPI'}
Local _lMarcar  	:= .F.
Local _cAlias
Local _cArqTrb
Local _nPos
Local oTempTbl

SetFunName('ZFISF006')

Begin Sequence	
	//dados para tabela temporária
    _cAlias := GetNextAlias()
	For _nPos := 1 To Len(_aColunas)
			Aadd(_aVar, {_aColunas[_nPos]		,"SB1",.F.,0})
	Next

	For _nPos := 1 To Len(_aVar)
		_aRet := CriaCpoTB(_aVar,_nPos)
    	If Len(_aRet) > 0
            AAdd(_aCampos, _aRet) //Este campo será usado para marcar/desmarcar
        Endif
    Next
    //Criação de Campos que não deverão constar no browse
    AAdd(_aCampos,CriaCpoTB('B1_XMARB'))
    AAdd(_aCampos,{'REGSB1',"N",10,0,"Registro","",""})
    //A função CriaTrab() retorna o nome de um arquivo de trabalho que ainda não existe e dependendo dos parâmetros passados, pode criar um novo arquivo de trabalho.


	oTempTbl := FWTemporaryTable():New("TRB", _aCampos)
    //Criação dos índices
    oTempTbl:AddIndex("01", {"B1_COD"} )
    oTempTbl:AddIndex("02", {"B1_DESC"} )
	oTempTbl:Create()

	//Como antes o cArqTab era a variável que tinha o nome físico do arquivo, podemos trabalhar com ela
	//sendo o nome real da tabela no banco de dados, para isso usamos o método GetRealName
	_cArqTrb := oTempTbl:GetRealName()
    aAdd(_aSeek,{"Cod Produto"	,{{"","C",TamSx3("B1_COD")[1] ,0,RetTitle("B1_COD") ,PesqPict( "SB1", "B1_COD")}} } )
    aAdd(_aSeek,{"Desc Produto" ,{{"","C",TamSx3("B1_DESC")[1],0,RetTitle("B1_DESC"),PesqPict( "SB1", "B1_DESC")}} } )

	//Carregar arquivo temporario
    FwMsgRun(,{ || LoadPrev(_aVar) }, "Cadastro de Produto", "Aguarde")  //Veículos / Aguarde
    //_oBrowse:AddButton(STR0261,{||FWMsgRun( ,{|| FopenPnTrab( (cAliasTrb)->RECNO, (cAliasTrb)->C9V_FILIAL, aChecks, "S-"+Substr((cAliasTrb)->C9V_NOMEVE,2,4),@oTabFilSel) },STR0079,STR0156) })	//"Exibir Painel do Trabalhador"#'Trabalhador'#'Abrindo Painel do Trabalhador'

	DbSelectArea("TRB")
    TRB->(DbSetOrder(1))
	TRB->(DbGotop())   
	_nQtdRegSel := 0

	_oBrowse := FWMarkBrowse():New()
    _oBrowse:SetDescription(OemToAnsi( _cCab )) //Veículos | Bloqueio / Desbloqueio
	_oBrowse:SetAlias( "TRB" ) //Indica o alias da tabela que será utilizada no Browse
    _oBrowse:SetFieldMark( 'B1_XMARB' )  //Necessario criar este campo na tabela tamanho 2 caracter  não utilizado
    //Cria botão sair caso não esteja previsto  
    _oBrowse:ForceQuitButton()                  
	_oBrowse:SetMenuDef('ZFISF006') //funcionalidade corrente  // Nome do fonte onde esta a função MenuDef
    _oBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
    _oBrowse:SetFixedBrowse(.T.)
    _oBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
	_oBrowse:SetTemporary(.T.) //Indica que o Browse utiliza tabela temporária
	_oBrowse:SetFilterDefault( "" ) //Exemplo de como inserir um filtro padrão >>> "TR_ST == 'A'"
	_oBrowse:SetUseFilter(.T.)
	_oBrowse:SetDBFFilter(.T.)
//	_oBrowse:bAllMark := { || ZFISF6INVE(_oBrowse:Mark(),_lMarcar := !_lMarcar ), _oBrowse:Refresh(.T.)  }	
	_oBrowse:bAllMark := { || FwMsgRun(,{ ||ZFISF6INVE(_oBrowse:Mark(),_lMarcar := !_lMarcar )}, "Aguarde...", "Processando atualizando registros ..."), _oBrowse:Refresh(.T.)  }	
	_oBrowse:DisableDetails()
	_oBrowse:DisableReport()
    _oBrowse:SetSeek(.T.,_aSeek) //Habilita a utilização da pesquisa de registros no Browse
   	_oBrowse:SetAfterMark({|| ZFISF006VL() })

    For _nPos := 1 To Len(_aColunas)
        //Campos que não serão exibidos no browse
   		_oBrowse:SetColumns(MontaColunas(_aColunas[_nPos],_nPos))     //Edita campo
    Next   

    _oBrowse:Activate()
End Begin
//Apagar arquivo twmporario criado
If Select("TRB") <> 0
   	TRB->(DbCloseArea())
	oTempTbl:Delete()
Endif  
return(Nil)



/*---------------------------------------------------------------------------------------
{Protheus.doc} MontaColunas
Responsavel montar campos nas colunas com sas respectivas caracteristica
@author     DAC - Denilso Almeida Carvalho
@single		27/10/2020
@version    P.12
@obs        
@project    
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/
Static Function MontaColunas(_cCampo, _nArrData, _cTitulo,  _cPicture, _nAlign, _nSize, _nDecimal, _cTipo, _cCombo,_lEdita)
Local _aColumn
Local _bData 	    := {||}
Local _aCombo       := {}
Local _cVar         := Nil
Local _bFunction    := &("{||.T.}")

Default _cTitulo	:= ""
Default _cPicture   := ""
Default _nAlign 	:= 1
Default _nSize 	    := 20
Default _nDecimal   := 0
Default _nArrData   := 0
Default _cTipo      := "C"
Default _cCombo     := ""
Default _lEdita     := .F.

Begin Sequence	
	SX3->(DbSetOrder(2))
   	If SX3->(DbSeek(_cCampo))
 		_cTitulo	:= SX3->X3_TITULO
 		_cPicture   := SX3->X3_PICTURE
 		_nSize 	    := SX3->X3_TAMANHO	
		_nDecimal   := SX3->X3_DECIMAL
 		_cTipo      := SX3->X3_TIPO
 		_cCombo     := SX3->X3_CBOX
	EndIf
	If _nArrData > 0
		_bData := &("{||" + _cCampo +"}") //&("{||_oBrowse:DataArray[_oBrowse:At(),"+STR(nArrData)+"]}")
        //Caso seja para editar mocar campo memoria
        If _lEdita
            _cVar := "M->"+_cCampo
            _bFunction :=    &("{||DblClickBrow("+Str(_nArrData)+")}")  //{|| DblClickBrow()}
        Endif
    Endif
	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)

	*/
    //Caso o campo tenha opções de combo informar
    If !Empty(_cCombo)
        _aCombo     := StrTokArr(_cCombo, ';')
    Endif    
	_aColumn := {   _cTitulo,   ;   //01 
                    _bData,     ;   //02
                    _cTipo,     ;   //03
                    _cPicture,  ;   //04
                    _nAlign,    ;   //05
                    _nSize,     ;   //06
                    _nDecimal,  ;   //07
                    _lEdita,    ;   //08
                    {||.T.},    ;   //09
                    .F.,        ;   //10
                    _bFunction,    ;   //11
                    _cCampo,      ;   //12
                    {||.T.},    ;   //13
                    .F.,        ;   //14
                    .F.,        ;   //15
                    _aCombo}        //16
End Sequence
Return {_aColumn}


/*---------------------------------------------------------------------------------------
{Protheus.doc} CriaCpoTB
Responsavel Carregar Campos para criação tabela temporaria Retornar detalhes dos campos 
@author     DAC - Denilso Almeida Carvalho
@single		20/04/2020
@version    P.12
@obs        
@project    
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/

Static Function CriaCpoTB(_xVar,_nPos)
Local _aRet := {}
Local _nTam := 0   
Local _cTipo  
Local _nDec    
Local _cTitulo 
Local _cPict   
Local _cCombo
Local _cCampo
Begin Sequence
    If ValType(_xVar) == "A"
        _cCampo := _xVar[_nPos,1]
        If Len(_xVar) >= 4
            _nTam := _xVar[_nPos,4]
        Endif
    Else
        _cCampo := _xVar
    Endif    

	SX3->(DbSetOrder(2))
	If !SX3->(Dbseek(_cCampo))
        Break
    Endif    
	_cTipo  := SX3->X3_TIPO
  	_nTam   := If(_nTam == 0,SX3->X3_TAMANHO,_nTam)
	_nDec   := SX3->X3_DECIMAL
	_cTitulo:= SX3->X3_TITULO 
	_cPict  := SX3->X3_PICTURE
    _cCombo := SX3->(X3Cbox())

	Aadd(_aRet,_cCampo)
	Aadd(_aRet,_cTipo)
	Aadd(_aRet,_nTam)
	Aadd(_aRet,_nDec)
	Aadd(_aRet,_cTitulo)
	Aadd(_aRet,_cPict)
	Aadd(_aRet,SX3->(X3Cbox()))
End Begin
Return _aRet


/*---------------------------------------------------------------------------------------
{Protheus.doc} LoadPrev
Responsavel por popular Tabela Temporária 
@author     DAC - Denilso Almeida Carvalho
@single		22/04/2020
@version    P.12
@obs        
@project    
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/

Static Function LoadPrev(_aVar)
Local _cAliasTRB    := GetNextAlias()      
Local _lRet   	    := .T.
Local _cCodNCM		:= AllTrim(_cNCM)
Local _nPos
Local _xValor
Local _nPosCpo
Local _cAlisDic
Begin Sequence
	_nQtdeReg := 0
    //Popular tabela temporária, irei colocar apenas um unico registro
	BeginSql Alias _cAliasTRB //Define o nome do alias temporário 
		SELECT  SB1.R_E_C_N_O_ NREGSB1
		FROM 	%Table:SB1% SB1
        WHERE	SB1.B1_FILIAL	    =  %xFilial:SB1%  					
				AND SB1.B1_POSIPI 	= %Exp:_cCodNCM%
				AND SB1.%notDel% 
  	EndSql //Gera a consulta no alias informado anteriormente 
 
	//TCSetField(_cAliasTRB,'ZD0_DATPRF','D',8,0)
	If (_cAliasTRB)->(Eof())  
		Aviso("AVISO","Não foram encontrados Produtos com o NCM "+_cCodNCM+" !",{"Ok"})
		_lRet := .F.
		Break	
	Endif
    ProcRegua(0)
    While (_cAliasTRB)->(!Eof())
        IncProc()
        If RecLock("TRB",.t.)
            SB1->(DbGoto((_cAliasTRB)->NREGSB1))
            For _nPos := 1 To Len(_aVar)
                _cAlisDic  := _aVar[_nPos,2]
                _nPosCpo   := TRB->(FieldPos(_aVar[_nPos,1])) 
           		_xValor    := (_cAlisDic)->(FIELDGET((FieldPos(_aVar[_nPos,1]))))  //importante lembrar que a matriz tem que estar na mesma ordem de campos do select 
           		TRB->(FieldPut(_nPosCpo, _xValor))
            Next
            //Guardar a posição 
            TRB->REGSB1 	:= (_cAliasTRB)->NREGSB1
			TRB->B1_XMARB	:= ""
       		TRB->(MsUnLock())
			_nQtdeReg ++   
    	Endif
    	(_cAliasTRB)->(DbSkip())
    EndDo
 End Sequence
 If Select((_cAliasTRB)) <> 0
	(_cAliasTRB)->(DbCloseArea())
	Ferase(_cAliasTRB+GetDBExtension())
Endif      
Return _lRet

//============================================================================================

//-------------------------------------
/*/{Protheus.doc} ZFISF006PR
//Processar os registros selecionados indicar alteração dos campos Pis Cofins
@author DAC - Denilso
@since 25/09/2020
@version 1.0
/*/
//-------------------------------------
Static Function ZFISF006PR()
Local _cTitulo  := "Selecione as opções para processamento"    
Local _nAcao    := 0
Local _cPis	  	:= ""	    
Local _cCofins  := ""	    
Local _aPis
Local _oPis
Local _oCofins
Local _aCofins
Local _oDlg
Local _cTexToPis
Local _cTexToCofins
Local _nlin1
Local _nlin2
Local _nCol1
Local _nCol2
Local _nReg

Begin Sequence
	//Carregar o Box
	SX3->(DbSetOrder(2))
	SX3->(DbSeek("B1_PIS "))
	_aPis 			:= StrTokArr(AllTrim(SX3->X3_CBOX),";")
	_cTexToPis		:= AllTrim(SX3->X3_Titulo)
	SX3->(DbSeek("B1_COFINS "))
	_aCofins 		:= StrTokArr(AllTrim(SX3->X3_CBOX),";")
	_cTexToCofins	:= AllTrim(SX3->X3_Titulo)
    //para facilitar controle das linhas
    _nlin1 := 5
	_nCol1 := 16
    _nlin2 := 45
	_nCol2 := 305

	DEFINE MSDIALOG _oDlg FROM  00, 70 TO 130, 700 TITLE _cTitulo PIXEL
	@ _nlin1, _nCol1 TO _nlin2, _nCol2 OF _oDlg PIXEL
	@ _nlin1+5 	, _nCol1+05 SAY  _cTexToPis 	SIZE 80, 20 OF _oDlg PIXEL     	
	@ _nlin1+4	, _nCol1+50 MSCOMBOBOX _oPis VAR _cPis ITEMS _aPis Valid !Empty(_cPis) PIXEL SIZE 70, 013 Of _oDlg COLORS 0, 16777215 PIXEL
  
	@ _nlin1+20, _nCol1+05 	SAY  _cTexToCofins 	SIZE 80, 20 OF _oDlg PIXEL     	
	@ _nlin1+19, _nCol1+50 	MSCOMBOBOX _oCofins VAR _cCofins ITEMS _aCofins Valid !Empty(_cPis) PIXEL SIZE 70, 013 Of _oDlg COLORS 0, 16777215 PIXEL

    DEFINE SBUTTON FROM _nlin2+5, 050 TYPE 1 ENABLE ACTION (_nAcao:=1,_oDlg:End()) OF _oDlg
	DEFINE SBUTTON FROM _nlin2+5, 120 TYPE 2 ENABLE ACTION (_oDlg:End()) OF _oDlg
	ACTIVATE MSDIALOG _oDlg CENTERED
    //Se for pressionado para sair
    If _nAcao == 1 
		//mesmo que o indicador esteja zerado ira verificar se existe registros a serem processados isto pode aconecer quando selecionar todos no header
		If _nQtdRegSel <= 0
			FwMsgRun(,{ || ZFISF006CN(.F. /*_lAtualiza*/, _cPis, _cCofins, @_nReg, lEnd) }, "Aguarde...", "Processando registros selecionados...")  
			If _nReg == 0
    			MsgInfo( " Não existem registro selecionados alterados PIS e COFINS", "[ ZFISF006 ] - Aviso" )
				Break
			EndIf
		Else
			_nReg := _nQtdRegSel	
		EndIf
		If MsgYesNo( "Foram selecionados "+StrZero(_nReg,6)+". registros. Deseja proceder com a alteração? " )
			FwMsgRun(,{ || ZFISF006CN(.T. /*_lAtualiza*/, _cPis, _cCofins, @_nReg, lEnd) }, "Aguarde...", "Processando registros selecionados...")  
    		MsgInfo( StrZero(_nReg,6)+" registros foram alterados com sucesso.", "[ ZFISF006 ] - Aviso" )
		EndIf
	Endif
End Sequence	
Return Nil

//-------------------------------------
/*/{Protheus.doc} ZFISF006CN
Funcionalidade responsavel por contar itens selecionados e atualizar
Processar itens selecionados
@author DAC - Denilso
@since 25/09/2020
@version 1.0
/*/
//-------------------------------------
Static Function ZFISF006CN(_lAtualiza, _cPis, _cCofins, _nReg, lEnd) 
Local _lRet   := .T.
Local _cMarca := _oBrowse:Mark()

Default lEnd       := .F.               

Begin Sequence
	_nReg := 0
    ProcRegua(0)
    //Se não estiver marcado pular registro
    TRB->(DbGotop())
    While TRB->(!Eof())
		//Caso pressionado cancelar
    	If lEnd
        	MsgInfo(OemToAnsi("Cancelado pelo Usuário"),OemToAnsi("Processo abortado"))  
        	Break
    	Endif
        If !TRB->(_oBrowse:IsMark(_cMarca))
            TRB->(DbSkip())
            Loop
        Endif

        //IncProc()
		//incluido para ter maior segurança apesar do filtro executado para marcação foi informado que selecionou registros que não eram da NCN
		//DAC 27/10/2020
		SB1->(DbGoto(TRB->REGSB1))		//COLOCADO SOMENTE COMO MARGEM DE SEGURANÇA ANTERIORMENTE SEM O TEMPORORARIO ESTAVA SE PERDENDO
		If AllTrim(SB1->B1_POSIPI) <> AllTrim(_cNCM)
            TRB->(DbSkip())
            Loop
		EndIf
        //Quando for para alterar
       	_nReg ++
		//Caso seja a chamada para atualizar   

		If _lAtualiza
   			RecLock("SB1", .F.)
			_cMsg 	:= ""
			If !EmpTy(SB1->B1_XLOG)
				_cMsg := AllTrim(SB1->B1_XLOG) 
				_cMsg += CHR(13)+CHR(10)
			EndIf
			_cMsg	+=  "ALTERACAO ZFISF006" + CHR(13)+CHR(10)
			_cMsg	+=  "B1_PIS = "		+SB1->B1_PIS	+" PARA "+ _cPis 	+ CHR(13)+CHR(10) 
			_cMsg	+=  "B1_COFINS = "	+SB1->B1_COFINS	+" PARA "+ _cCofins + CHR(13)+CHR(10) 
			_cMsg	+=  "POR " +Substr(cUserName,1,20) +" EM "+DtoC(Date())+ " "+ SubsTr(Time(),1,5)			
			SB1->B1_PIS 		:= _cPis
			SB1->B1_COFINS 		:= _cCofins
   			SB1->B1_XMARB 		:= ""
			SB1->B1_XLOG 		:= _cMsg
			SB1->(MsUnlock())

   			RecLock("TRB", .F.)
			TRB->B1_PIS 		:= _cPis
			TRB->B1_COFINS 		:= _cCofins
   			TRB->B1_XMARB 		:= ""
			TRB->(MsUnlock())
		Endif
       	TRB->(DbSkip())
	Enddo      
    _oBrowse:GoTop()
    _oBrowse:Refresh()
	//Zerr o contador após a atualização
	If _lAtualiza
		_nQtdRegSel := 0
	EndIf	
End Sequence
Return _lRet


//Função para marcar/desmarcar todos os registros do grid
Static Function ZFISF6INVE(cMarca,lMarcar)
Local _nRecNo := TRB->(Recno())
Begin Sequence
    TRB->( dbGoTop() )
    While !TRB->( Eof() )
    	RecLock( "TRB", .F. )
        TRB->B1_XMARB := IIf( lMarcar, cMarca, '  ' )
        TRB->(MsUnlock())
        TRB->( DbSkip() )
    EndDo
	Trb->(DbGoto(_nRecNo))
    _oBrowse:GoTo(_nRecNo,.T.)
    _oBrowse:Refresh()

End Sequence
Return .T.

//-------------------------------------
/*/{Protheus.doc} ZFISF006VI
VisualizaçãoEntrada de Veículos ACD
@author DAC - Denilso
@since 25/09/2020
@version 1.0
/*/
//-------------------------------------
Static Function ZFISF006VI()
Private  cCadastro := "Alteração PIS/CONFINS por N.C.M. produto "+SB1->B1_DESC
AxVisual("SB1",SB1->( RecNo() ),2)
Return Nil

