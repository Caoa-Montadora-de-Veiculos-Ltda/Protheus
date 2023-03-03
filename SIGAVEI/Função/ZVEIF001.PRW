#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ZVEIF001.CH"

Static _cAlias
Static _oBrowse
Static _cOper

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZVEIF001
Rdmake 	Funcionalidade responsavelpelo Bloqueio / Desbloqueio em lote por seleção	
@class    	Nao Informado
@from       Nao Informado
@param      
@attrib    	Nao Informado
@protected  Nao Informado

@author     DAC Denilso 
@single		02/04/2020
@version    Nao Informado
@since      Nao Informado  
@return    	Logico
@sample     Nao Informado
@obs        
@project    VEI103 - Bloqueio de Veículos (397320) - MIT044 - R01PT - Geração do pedido acumulado no CD
@menu       SIGAVEI/MISCELANIA/ESPECIFICO CAOA/BLOQUEIO DESBLOQ VEICU
@history    
--------------------------------------------------------------------------------------*/

User Function ZVEIF001()
Local _aSays	    := {}
Local _aButtons	    := {}
Local _cCadastro    := OemToAnsi("Bloqueio/Desbloqueio de Veiculo")
Local _cTitle  	    := OemToAnsi("Bloqueio/Desbloqueio")
Local _aPar    	    := {}
Local _aRet    	    := {}
Local _nRet	        := 0
Local _lLibera      := .T.
Local _lZVEIF001    := SuperGetMV( "CMV_VEI008"  ,,.T. )   //Parâmetro para indicação de utilização do programa tendo como Default Verdadeiro, não é necessário a criação do mesmo

//Desabilitei para que não seja utilizado para verificar varias empresas
//Local _cFilDe 	:= Space(TamSx3("VV1_FILIAL")[1])
//Local _cFilAte	:= Space(TamSx3("VV1_FILIAL")[1])

Begin Sequence
    //Caso não seja para executar a rotina sair
    If !_lZVEIF001                             
        Break
    Endif           

    //	Aadd(_aPar,{1,"Filial de:"				,_cFilDe 	,"@D"		,".T."	,"SM0" ,".T."	,50,.F.})
    //	Aadd(_aPar,{1,"Filial Ate:"				,_cFilAte	,"@D"		,".T."	,"SM0" ,".T."	,50,.T.})
    aAdd(_aPar,{3 , OemToAnsi(STR0008)	,1 ,{OemToAnsi(STR0004),OemToAnsi(STR0005)}	 ,50	,""	,.T.}) //B=Bloqueio D=Desbloqueio / Bloqueio","Desbloqueio
    aAdd(_aPar,{11, OemToAnsi(STR0026) ,"",".T.",".T.",.T.})  //"Informe o motivo"    --->Texto Aleatório
	// Monta Tela principal
	AADD(_aSays,OemToAnsi(STR0040)) //Este Programa tem  como  Objetivo  possibilitar  o  bloqueio  e  ou
	AADD(_aSays,OemToAnsi(STR0041)) //Desbloqueio dos Veículos, ao qual será possivel selecionar diversos
	AADD(_aSays,OemToAnsi(STR0042)) //veículos e permitira pesquisa/filtros no processo.
	AADD(_aSays,OemToAnsi(STR0043)) //Clique no botão Parâmetros para alterar as definições da rotina. 
	AADD(_aSays,OemToAnsi(STR0044)) //Depois clique no Botão OK.
	AADD(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
	AADD(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
	AADD(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,"XINV001",.T.,.T.) 			}})

	FormBatch( _cCadastro, _aSays, _aButtons )
    If _nRet <> 1
        Break
    Endif
    If Len(_aRet) == 0
        Help("",1,OemToAnsi(STR0035),,OemToAnsi(STR0030),4,1) // Necessário informar os parâmetros
        Break 
    Endif
	//Desabilitado para não acessar vária empresas
    //_cFilDe		:= PadR(AllTrim(_aRet[1]),TamSx3("VV1_FILIAL")[1])
 	//_cFilAte	:= PadR(AllTrim(_aRet[2]),TamSx3("VV1_FILIAL")[1])
    If _aRet[1]  == 1
        _cOper  := "B"
    Else      
        _cOper  := "D"
    Endif   
    _cMotivo    := AllTrim(Upper(_aRet[2]))
    //Verificar se o tecnico possui direitos para bloquear/desbloquear  
    _lLibera := .F.  
    VAI->(DbSetOrder(4))  //Filial + CodUsr
    If VAI->(DbSeek( xFilial("VAI") + RetCodUsr() )) .and. VAI->VAI_BLOQVE # "0"
	      If _cOper == "B" .and. VAI->VAI_BLOQVE $ "1/3"
		        _lLibera := .T.
	      EndIf
	      If _cOper == "D" .and. VAI->VAI_BLOQVE $ "2/3"
		        _lLibera := .T.
	      EndIf
    EndIf
    If !_lLibera
       	Help("",1,OemToAnsi(STR0035),,OemToAnsi(STR0034),4,1) // Usuário não possui direitos para execução desta operação verificar cadastros de Técnicos
        Break
    Endif
	ZVF01PRC(_cMotivo)
End Sequence
Return Nil

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZVF01PRC
Responsavel Funcionalidade responsável pelo Bloqueio / Desbloqueio de Veículo
@author     DAC - Denilso Almeida Carvalho
@single		02/04/2020
@version    P.12
@obs        
@project    
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/
Static Function ZVF01PRC(_cMotivo)
Local _aVar		  := {}
Local _aCampos	  := {}
//Local _aFieFilter := {}
Local _aSeek	  := {}
Local _cArqTrb
Local _nPos
Local _cIndice1
Local _cIndice2
Local _nPosCpo

SetFunName('ZVEIF001')

Begin Sequence	
	//dados para tabela temporária
    _cAlias := GetNextAlias()
	Aadd(_aVar, {"VV1_FILIAL"		,"VV1",.F.,0})
	Aadd(_aVar, {"VV1_CHAINT"		,"VV1",.F.,0})
	Aadd(_aVar, {"VV1_CODMAR"		,"VV1",.F.,0})
	Aadd(_aVar, {"VE1_DESMAR"		,"VE1",.F.,0})
	Aadd(_aVar, {"VV1_CHASSI"		,"VV1",.F.,0})
	Aadd(_aVar, {"VV1_MODVEI"		,"VV1",.F.,0})
	Aadd(_aVar, {"VV2_DESMOD"		,"VV2",.F.,0})
	Aadd(_aVar, {"VV1_FABMOD"		,"VV1",.F.,0})
	Aadd(_aVar, {"VV1_CORVEI"		,"VV1",.F.,0})
	Aadd(_aVar, {"VVC_DESCRI"		,"VVC",.F.,0})
	Aadd(_aVar, {"VV1_COMVEI"		,"VV1",.F.,0})
	Aadd(_aVar, {"VV1_ESTVEI"		,"VV1",.F.,0})
	Aadd(_aVar, {"VV1_PLAVEI"		,"VV1",.F.,0})
	Aadd(_aVar, {"VV1_SITVEI"		,"VV1",.F.,0})
	If _cOper == "B"
        Aadd(_aVar, {"VB0_MOTBLO"		,"VB0",.T.,0})
	    Aadd(_aVar, {"VB0_DATBLO"		,"VB0",.F.,0})
	    //Aadd(_aVar, {"VB0_USUBLO"		,"VB0",.F.,0})
    Else
        Aadd(_aVar, {"VB0_MOTDES"		,"VB0",.T.,0})
	   // Aadd(_aVar, {"VB0_DATDES"		,"VB0",.F.,0})
	    Aadd(_aVar, {"VB0_DATBLO"		,"VB0",.F.,0})
        Aadd(_aVar, {"VB0_MOTBLO"		,"VB0",.F.,0})
	    Aadd(_aVar, {"VB0_USUBLO"		,"VB0",.F.,40})
	    //Aadd(_aVar, {"VB0_USUDES"		,"VB0",.F.})
    EndIf
	For _nPos := 1 To Len(_aVar)
		_aRet := CriaCpoTB(_aVar,_nPos)
    	If Len(_aRet) > 0
            AAdd(_aCampos, _aRet) //Este campo será usado para marcar/desmarcar
        Endif
    Next
    //Criação de Campos que não deverão constar no browse
    AAdd(_aCampos,CriaCpoTB('VV1_OK'))
    AAdd(_aCampos,{'REGVV1',"N",10,0,"Registro","",""})
    AAdd(_aCampos,{'REGVB0',"N",10,0,"Registro","",""})

    //A função CriaTrab() retorna o nome de um arquivo de trabalho que ainda não existe e dependendo dos parâmetros passados, pode criar um novo arquivo de trabalho.
    _cArqTrb   := CriaTrab(_aCampos,.T.)
    //Criar indices
    _cIndice1 := Alltrim(CriaTrab(,.F.))
    _cIndice1 := Left(_cIndice1,5) + Right(_cIndice1,2) + "A"
    _cIndice2 := Left(_cIndice1,5) + Right(_cIndice1,2) + "B"
    _cIndice3 := Left(_cIndice1,5) + Right(_cIndice1,2) + "C"

    //Se indice existir excluir
    If File(_cIndice1+OrdBagExt())
        FErase(_cIndice1+OrdBagExt())
    EndIf
    //A função dbUseArea abre uma tabela de dados na área de trabalho atual ou na primeira área de trabalho disponível
    DbUseArea(.T.,,_cArqTrb,"TRB",Nil,.F.)
    //A função IndRegua cria um índice temporário para o alias especificado, podendo ou não ter um filtro
    IndRegua("TRB", _cIndice1, "VV1_CHAINT"	,,, "Chassis Interno ...")
    IndRegua("TRB", _cIndice2, "VV1_CHASSI"	,,, "Chassis ...")
    IndRegua("TRB", _cIndice3, "VV1_PLAVEI"	,,, "Placa ...")

    //Fecha todos os índices da área de trabalho corrente.
    DbClearIndex()
    //Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho.
    DbSetIndex(_cIndice1+OrdBagExt())
    DbSetIndex(_cIndice2+OrdBagExt())
    DbSetIndex(_cIndice3+OrdBagExt())

    aAdd(_aSeek,{"Chassis Interno"	,{{"","C",TamSx3("VV1_CHAINT")[1],0,RetTitle("VV1_CHAINT"),PesqPict( "VV1", "VV1_CHAINT")}} } )
    aAdd(_aSeek,{"Chassis"	        ,{{"","C",TamSx3("VV1_CHASSI")[1],0,RetTitle("VV1_CHASSI"),PesqPict( "VV1", "VV1_CHASSI")}} } )
    aAdd(_aSeek,{"Placa"	        ,{{"","C",TamSx3("VV1_PLAVEI")[1],0,RetTitle("VV1_PLAVEI"),PesqPict( "VV1", "VV1_PLAVEI")}} } )

	//Carregar arquivo temporario
    FwMsgRun(,{ || LoadPrev(_aVar,_cMotivo) }, STR0001, STR0032)  //Veículos / Aguarde
    //_oBrowse:AddButton(STR0261,{||FWMsgRun( ,{|| FopenPnTrab( (cAliasTrb)->RECNO, (cAliasTrb)->C9V_FILIAL, aChecks, "S-"+Substr((cAliasTrb)->C9V_NOMEVE,2,4),@oTabFilSel) },STR0079,STR0156) })	//"Exibir Painel do Trabalhador"#'Trabalhador'#'Abrindo Painel do Trabalhador'

	DbSelectArea("TRB")
    TRB->(DbSetOrder(1))
	TRB->(DbGotop())   
	_oBrowse := FWMarkBrowse():New()
    _oBrowse:SetDescription(OemToAnsi(STR0001 + " - "+ If(_cOper=="B",STR0004,STR0005) )) //Veículos | Bloqueio / Desbloqueio
	_oBrowse:SetAlias( "TRB" ) //Indica o alias da tabela que será utilizada no Browse
    _oBrowse:SetFieldMark( 'VV1_OK' )  //Necessario criar este campo na tabela tamanho 2 caracter  não utilizado
    //Cria botão sair caso não esteja previsto  
    _oBrowse:ForceQuitButton()                  
	_oBrowse:SetMenuDef('ZVEIF001') //funcionalidade corrente  // Nome do fonte onde esta a função MenuDef
    _oBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
    _oBrowse:SetFixedBrowse(.T.)
    _oBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
	_oBrowse:SetTemporary(.T.) //Indica que o Browse utiliza tabela temporária
	_oBrowse:SetFilterDefault( "" ) //Exemplo de como inserir um filtro padrão >>> "TR_ST == 'A'"
	_oBrowse:SetUseFilter(.T.)
	_oBrowse:SetDBFFilter(.T.)
    _oBrowse:DisableDetails()
	_oBrowse:DisableReport()
    _oBrowse:SetSeek(.T.,_aSeek) //Habilita a utilização da pesquisa de registros no Browse
    _oBrowse:AddLegend( "VV1_SITVEI = '0'"     , "BLUE"	    , OemToAnsi(STR0013)  )  // "Estoque"
    _oBrowse:AddLegend( "VV1_SITVEI = '1'"     , "BLACK"     , OemToAnsi(STR0014)  )  // "Vendido"
    _oBrowse:AddLegend( "VV1_SITVEI = '2'"     , "GREEN"     , OemToAnsi(STR0015)  )  // "Transito"
    _oBrowse:AddLegend( "VV1_SITVEI = '3'"     , "YELLOW"    , OemToAnsi(STR0016)  )  // "Remessa"
    _oBrowse:AddLegend( "VV1_SITVEI = '4'"     , "PINK" 	    , OemToAnsi(STR0017)  )  // "Consignado"
    _oBrowse:AddLegend( "VV1_SITVEI = '5'"     , "BROWN" 	, OemToAnsi(STR0018)  )  // "Transferido"
    _oBrowse:AddLegend( "VV1_SITVEI = '6'"     , "ORANGE"    , OemToAnsi(STR0019)  )  // "Reservado"
    _oBrowse:AddLegend( "VV1_SITVEI = '7'"     , "WHITE"     , OemToAnsi(STR0020)  )  // "Progresso"
    _oBrowse:AddLegend( "VV1_SITVEI = '8'"     , "RED" 	    , OemToAnsi(STR0021)  )  // "Pedido"

    For _nPos := 1 To Len(_aCampos)
        //Campos que não serão exibidos no browse
        If (_nPosCpo := Ascan(_aVar,{|x| AllTrim(x[1]) == AllTrim(_aCampos[_nPos,1])})) == 0
            Loop
        Endif
   		_oBrowse:SetColumns(MontaColunas(_aCampos[_nPos,1],;     //_cCampo
   										_aCampos[_nPos,5],;     //_cTitulo
   										_nPos,;                 //_nArrData
   										_aCampos[_nPos,6],;     //_cPicture
   										 ,;                     //_nAlign
   										_aCampos[_nPos,3],;     //_nSize
   										_aCampos[_nPos,4],;     //_nDecimal
   										_aCampos[_nPos,2],;     //_cTipo
                                        _aCampos[_nPos,7],;     //_cCombo
                                        _aVar[_nPosCpo,3]))     //Edita campo
    Next   
    _oBrowse:Activate()
End Begin
//Apagar arquivo twmporario criado
If Select("TRB") <> 0
   	TRB->(DbCloseArea())
   	Ferase(_cAlias+GetDBExtension())
	Ferase(_cIndice1+OrdBagExt())
	Ferase(_cIndice2+OrdBagExt())
	Ferase(_cIndice3+OrdBagExt())

Endif  
return(Nil)

USER fUNCTION ZVEITEST()
RETURN .T.


/*---------------------------------------------------------------------------------------
{Protheus.doc} MenuDef
Responsavel montar campos nas colunas com sas respectivas caracteristica
@author     DAC - Denilso Almeida Carvalho
@single		29/04/2020
@version    P.12
@obs        
@project    
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/

Static Function MontaColunas(_cCampo, _cTitulo, _nArrData, _cPicture, _nAlign, _nSize, _nDecimal, _cTipo, _cCombo,_lEdita)
Local _aColumn
Local _bData 	    := {||}
Local _aCombo       := {}
Local _cVar         := Nil
Local _bFunction    := &("{||.T.}")
Default _nAlign 	:= 1
Default _nSize 	    := 20
Default _nDecimal   := 0
Default _nArrData   := 0
Default _cTipo      := ""
Default _cCombo     := ""
Default _lEdita     := .F.
Begin Sequence	
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

Static Function LoadPrev(_aVar,_cMotivo)
Local _cAliasTRB    := GetNextAlias()      
Local _lRet   	    := .T.
Local _lBloqueio    := If(_cOper=="B",.T.,.F.)
Local _nPos
Local _xValor
Local _nPosCpo
Local _cAlisDic
Local _cCond
Begin Sequence
    If _lBloqueio
        _cCond := "AND (SELECT ISNULL(MAX(VB0A.R_E_C_N_O_),0) "
   	    _cCond += "     FROM VB0010 VB0A  
        _cCond += "     WHERE   VB0A.VB0_FILIAL = '201002    '        	
		_cCond += "         AND VB0A.VB0_CHAINT =  VV1.VV1_CHAINT "
        _cCond += "         AND VB0A.VB0_DATDES = ' '  AND VB0.VB0_DATVAL >= '"+DtoS(Date())+"' " 
        _cCond += "         AND VB0A.D_E_L_E_T_ = ' ' ) = 0 "    
    Else
        _cCond := "AND (SELECT ISNULL(MAX(VB0A.R_E_C_N_O_),0) "
   	    _cCond += "     FROM VB0010 VB0A  
        _cCond += "     WHERE   VB0A.VB0_FILIAL = '201002    '        	
		_cCond += "         AND VB0A.VB0_CHAINT =  VV1.VV1_CHAINT "
        _cCond += "         AND VB0A.VB0_DATDES = ' ' " 
        _cCond += "         AND VB0A.D_E_L_E_T_ = ' ' ) > 0 "    
    Endif    
    _cCond := "%"+_cCond+"%"
    //Popular tabela temporária, irei colocar apenas um unico registro
	BeginSql Alias _cAliasTRB //Define o nome do alias temporário 
		SELECT  VV1.R_E_C_N_O_ NREGVV1,
                MAX(VE1.R_E_C_N_O_) NREGVE1,
                MAX(VV2.R_E_C_N_O_) NREGVV2,
                MAX(VVC.R_E_C_N_O_) NREGVVC,
                ISNULL(MAX(VB0.R_E_C_N_O_),0) NREGVB0
		FROM 	%Table:VV1% VV1
        LEFT JOIN  %Table:VB0% VB0  
                ON  VB0.VB0_FILIAL = %xFilial:VB0%
                AND VB0.VB0_CHAINT =  VV1.VV1_CHAINT
                AND VB0.VB0_DATDES = ' '
                AND VB0.%notDel%  
        LEFT JOIN  %Table:VE1% VE1 
                ON  VE1.VE1_FILIAL  = %xFilial:VE1%
                AND VE1.VE1_CODMAR  = VV1.VV1_CODMAR
                AND VE1.%notDel%
        LEFT JOIN  %Table:VV2% VV2 
                ON  VV2.VV2_FILIAL  = %xFilial:VV2%
                AND VV2.VV2_CODMAR  = VV1.VV1_CODMAR
                AND VV2.VV2_MODVEI  = VV1.VV1_MODVEI
                AND VV2.VV2_SEGMOD  = VV1.VV1_SEGMOD
                AND VV2.%notDel%
        LEFT JOIN  %Table:VVC% VVC 
                ON  VVC.VVC_FILIAL  = %xFilial:VVC%
                AND VVC.VVC_CODMAR = VV1.VV1_CODMAR
                AND VVC.VVC_CORVEI = VV1.VV1_CORVEI
                AND VVC.%notDel%
        WHERE	VV1.VV1_FILIAL	    =  %xFilial:VV1%  					
				AND VV1_SITVEI      <> '1'
				AND VV1.%notDel% 
                %Exp:_cCond%
        GROUP BY VV1.R_E_C_N_O_
        ORDER BY NREGVV1

  	EndSql //Gera a consulta no alias informado anteriormente 
//        GROUP by ROLLUP(VV1.R_E_C_N_O_)
 
	//TCSetField(_cAliasTRB,'ZD0_DATPRF','D',8,0)
	If (_cAliasTRB)->(Eof())  
		Aviso("AVISO","Não foram encontrados Previsões em Aberto! ",{"Ok"})
		_lRet := .F.
		Break	
	Endif
    ProcRegua(0)
    While (_cAliasTRB)->(!Eof())
        IncProc()
        //Quando for bloqueio e localizr algum registro significa que ainda existem pedidos para serem desbloqueados
        /* não necessário ja tratado no select
        If _lBloqueio .and. (_cAliasTRB)->NREGVB0 > 0   
    	    (_cAliasTRB)->(DbSkip())
            Loop
        //Quando for desbloqueio e não localizr algum registro significa que não existem bloqueados
        ElseIf !_lBloqueio .and. (_cAliasTRB)->NREGVB0 = 0   
    	    (_cAliasTRB)->(DbSkip())
            Loop
        Endif
        */
        If RecLock("TRB",.t.)
            VV1->(DbGoto((_cAliasTRB)->NREGVV1))
            VE1->(DbGoto((_cAliasTRB)->NREGVE1))
            VV2->(DbGoto((_cAliasTRB)->NREGVV2))
            VVC->(DbGoto((_cAliasTRB)->NREGVVC))
            VB0->(DbGoto((_cAliasTRB)->NREGVB0))
            For _nPos := 1 To Len(_aVar)
                _cAlisDic  := _aVar[_nPos,2]
                _nPosCpo   := TRB->(FieldPos(_aVar[_nPos,1])) 
           		_xValor    := (_cAlisDic)->(FIELDGET((FieldPos(_aVar[_nPos,1]))))  //importante lembrar que a matriz tem que estar na mesma ordem de campos do select 
           		TRB->(FieldPut(_nPosCpo, _xValor))
            Next
            //Guardar a posição 
            TRB->REGVV1 := (_cAliasTRB)->NREGVV1
            TRB->REGVB0 := (_cAliasTRB)->NREGVB0
            If _lBloqueio
                TRB->VB0_MOTBLO := _cMotivo
       	        TRB->VB0_DATBLO := Date()
                //não carrego a hora de bloqueio   
	            //TRB->VB0_HORBLO := val(left(time(), 2) + substr(time(), 4, 2))
            Else
                TRB->VB0_MOTDES := _cMotivo
                TRB->VB0_USUBLO := UsrFullName(TRB->VB0_USUBLO)
            EndIf
       		TRB->(MsUnLock())
  	        //validar data de validade quando for bloqueio se a data for menor desbloquear automativamente
            //tanto no bloqueio como no desbloqueio vira com a data de validade vencida no bloqueio desbloquear automaticamente e mostrar na tela
            //no desbloqueio desbloquear e não mostrar na tela  
            If VB0->(!Eof()) .and. !Empty(VB0->VB0_DATBLO) .and. VB0->VB0_DATVAL < Date() .and. ;
                Empty(VB0->VB0_DATDES) .and. RecLock("VB0",.F.)
	            VB0->VB0_DATDES := Date()
	            VB0->VB0_HORDES := val(left(time(), 2) + substr(time(), 4, 2))
	            VB0->VB0_USUDES := RetCodUsr()
	            VB0->VB0_MOTDES := UPPER(STR0045) // "DESBLOQUEIO AUTOMATICO"
                VB0->(MsUnlock())
            Endif
    	Endif
    	(_cAliasTRB)->(DbSkip())
    EndDo
 End Sequence
 Return _lRet
 If Select((_cAliasTRB)) <> 0
	(_cAliasTRB)->(DbCloseArea())
	Ferase(_cAliasTRB+GetDBExtension())
Endif      


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
    //nesse caso deverei retornar o tamanho para nome e não o código
    If _cCampo == "VB0_USUBLO"

    Endif
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
{Protheus.doc} ZVF01GER
Responsavel Processar registros selecionados
@author     DAC - Denilso Almeida Carvalho
@single		06/04/2020
@version    P.12
@obs        
@project    
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/
User Function ZVF01GER()       
Local _lRet     := .T. 
Begin Sequence
    If !MsgYesNo(STR0031+" ?") //Confirma processamento dos itens Selecionados
        Break
    Endif             
    FwMsgRun(,{ || ZVF01GERPR() }, STR0033, STR0032)
End Sequence
Return _lRet



/*---------------------------------------------------------------------------------------
{Protheus.doc} ZVF01GERPR
Responsavel Processar registros selecionados
@author     DAC - Denilso Almeida Carvalho
@single		06/04/2020
@version    P.12
@obs        
@project    
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/
Static Function ZVF01GERPR()
Local _lRet   := .T.
Local _cMarca := _oBrowse:Mark()
Local _aReg   := {}
Local _nProc  := 0
Local _nPeriodo := SuperGetMV( "CMV_VEI010"  ,,3500)  //quantidade de dias correspondente ao bloqueio de veiculos
Local _nPos
Local aChassiFat := {}
Local nI         := 0
Local cChassis   := ""

Begin Sequence
    ProcRegua(0)
    //Se não estiver marcado pular registro
    TRB->(DbGotop())
    While TRB->(!Eof())
        IncProc()
        If !_oBrowse:IsMark(_cMarca)
            TRB->(DbSkip())
            Loop
        Endif
        //Quando for Bloqueio
        VV1->(DbGoto(TRB->REGVV1))

        If VV1->VV1_SITVEI == '1' //--Vendido
            Aadd( aChassiFat, AllTrim( VV1->VV1_CHASSI ) )
        ElseIf _cOper == "B"
	        // Bloqueio Automatico
	        RecLock("VB0", .t.)
	        VB0->VB0_FILIAL := xFilial("VB0")
	        VB0->VB0_CHAINT := VV1->VV1_CHAINT
	        VB0->VB0_DATBLO := Date()
	        VB0->VB0_HORBLO := val(left(time(), 2) + substr(time(), 4, 2))
	        VB0->VB0_USUBLO := RetCodUsr()
	        VB0->VB0_MOTBLO := TRB->VB0_MOTBLO  //Upper(AllTrim(_cMotivo))
	        VB0->VB0_DATVAL := (Date() + _nPeriodo)
	        VB0->VB0_HORVAL := val(left(time(), 2) + substr(time(), 4, 2))
	        VB0->(MsUnlock())
        //Desbloqueio
        ElseIf _cOper == "D"
            //Necessario fazer esta busca pois pode existir mais de um registro de bloqueio com data vencida
            //VB0->(DbGoto(TRB->REGVB0))
            _aReg := {} 
            U_ZVF01VLDBL(.T. /*Indica que existem regsitros bloqueados*/,@_aReg /*Retorna os nr dos registros para desbloquear*/)
            For _nPos := 1 To Len(_aReg)
                VB0->(DbGoto(_aReg[_nPos]))
                RecLock("VB0", .f.)
		        VB0->VB0_DATDES := Date()
		        VB0->VB0_HORDES := val(left(time(), 2) + substr(time(), 4, 2))
		        VB0->VB0_USUDES := RetCodUsr()
		        VB0->VB0_MOTDES := TRB->VB0_MOTDES  //Upper(AllTrim(_cMotivo))   
	            VB0->(MsUnlock())
            Next
	    EndIf
        _nProc ++
        RecLock("TRB", .F.)
        TRB->(DbDelete())
        //VV1->VV1_OK := "  "
        TRB->(MsUnlock())
        TRB->(DbSkip())
    Enddo   

    If Len(aChassiFat) > 0

        For nI := 1 To Len(aChassiFat)
            cChassis += aChassiFat[nI] + CRLF
        Next

        MsgInfo("Os seguintes chassis estão faturados e não permitem Bloqueio/Desbloqueio!" + CRLF + cChassis, "Chassis faturados")
    Else
        MsgInfo(STR0038 +" "+ StrZero(_nProc,7) +" "+If(_cOper=="B",STR0004,STR0005),STR0039)  //Registros atualizados /Bloqueio /Desbloqueio /Processado
    EndIf

    _oBrowse:GoTop()
    _oBrowse:Refresh()
End Sequence
Return _lRet


/*---------------------------------------------------------------------------------------
{Protheus.doc} ZVF01VLDBL
Responsavel Funcionalidade responsave por verificar se no VB0 existe bloqueio pela data de validade
@author     DAC - Denilso Almeida Carvalho
@single		03/04/2020
@version    P.12
@obs        
@project    
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/
User Function ZVF01VLDBL(_lRetDado,_aRet,_cChaInt)
Local _cAliasPesq := GetNextAlias()
Local _lBloqueio  := .F.
Local _aArea      := GetArea()

Default _lRetDado := .F.
Default _aRet     := {}

Begin Sequence
    If _cChaInt == Nil
        _cChaInt := VV1->VV1_CHAINT
    EndIf
    //Verificar se existe esta mencionado em algun periodo ja cadastrado de datas
    BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
        SELECT  VB0.R_E_C_N_O_ NREGVB0
        FROM %Table:VB0% VB0
        WHERE VB0.VB0_FILIAL    =  %xFilial:VB0%             
            AND VB0.VB0_CHAINT  =  %Exp:VV1->VV1_CHAINT%
            AND VB0.VB0_DATDES  = ' '
            AND VB0.%notDel%  
    EndSql 
    //TCSetField(_cAliasPesq,'VB0_DATVAL','D',8,0)
    //Não localizou bloqueio valido
    If (_cAliasPesq)->(EOF()) .or. (_cAliasPesq)->NREGVB0 == 0 
        _lBloqueio  := .T.
        Break
    Endif    
    //Se for para retornar dados onde estão os bloqueios
    If _lRetDado
        While (_cAliasPesq)->(!EOF())
            Aadd(_aRet, (_cAliasPesq)->NREGVB0)
            (_cAliasPesq)->(DbSkip())
        EndDo
    Endif
End Begin
If Select(_cAliasPesq) <> 0
    (_cAliasPesq)->(DbCloseArea())
    Ferase(_cAliasPesq+GetDBExtension())
Endif  
RestArea(_aArea)
Return _lBloqueio  

/*---------------------------------------------------------------------------------------
{Protheus.doc} DblClickBrow
Responsavel Tela utilizada no duplo click para informações de motivo bloquio/desbloqueio arquivo temporario
@author     DAC - Denilso Almeida Carvalho
@single		04/05/2020
@version    P.12
@obs        
@project    
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/

Static Function DblClickBrow(_nPos)
  Local _cTitulo  := STR0026   //"Informe o motivo"    
  Local _nAcao    := 0
  Local _oDlg
  Local _cMotivo    
  Local _cTexto
  Begin Sequence 
    If _cOper == "B"  //Bloqueio
        _cTexto := STR0004   //"Bloqueio"
        _cMotivo  := TRB->VB0_MOTBLO    //Space(Len(VB0->VB0_MOTBLO))
    Else
        _cTexto := STR0004  //"Desbloqueio"
        _cMotivo  := TRB->VB0_MOTDES    //Space(Len(VB0->VB0_MOTBLO))
    Endif
	DEFINE MSDIALOG _oDlg FROM  00, 70 TO 80, 900 TITLE _cTitulo PIXEL
	@ 0, 2 TO 22, 412 OF _oDlg PIXEL
	@ 7, 50 MSGET _cMotivo Picture "@!"  SIZE 350, 10 OF _oDlg PIXEL
	@ 8, 08 SAY  _cTexto SIZE 100, 20 OF _oDlg PIXEL     	
    DEFINE SBUTTON FROM 29, 50 TYPE 1 ENABLE ACTION (_nAcao:=1,_oDlg:End()) OF _oDlg
	DEFINE SBUTTON FROM 29, 90 TYPE 2 ENABLE ACTION (_oDlg:End()) OF _oDlg
	ACTIVATE MSDIALOG _oDlg CENTERED
    //Se for pressionado para sair
    If _nAcao == 1 
        RecLock("TRB", .f.)
        If _cOper == "B"  //Bloqueio
            TRB->VB0_MOTBLO := _cMotivo
        Else
            TRB->VB0_MOTDES := _cMotivo
        EndIf    
        TRB->(MsUnlock())
    Endif 
  End Sequence
  Return Nil

/*---------------------------------------------------------------------------------------
{Protheus.doc} MenuDef
Responsavel Menu Funcional
@author     DAC - Denilso Almeida Carvalho
@single		02/04/2020
@version    P.12
@obs        
@project    
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/
Static Function MenuDef()
Local aRotina := {}  
Begin Sequence
  ADD OPTION aRotina Title OemToAnsi(STR0024) Action 'U_ZVF01GER()' OPERATION 2  ACCESS 0 DISABLE MENU  //Processar

End Sequence
Return aRotina



/*   

Static Function DblClickBrow()
Local acols := _oBrowse:oBrowse:ACOLUMNS
//If ( _oBrowse:ColPos() == 15 )
	lEditCell(acols, _oBrowse, "@!", _oBrowse:oBrowse:COLPOS())
//EndIf       
Return nOL   
//_oBrowse:oBrowse:COLPOS()
//_oBrowse:oBrowse:LEDITCELL
*/
