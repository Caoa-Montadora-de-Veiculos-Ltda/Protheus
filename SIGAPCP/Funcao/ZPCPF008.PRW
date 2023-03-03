#include "protheus.ch"
#include "ZPCPF007.CH"

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZPCPF008
Rdmake 	Função chamada Ponto de Entrada MT680EST após estorno de op                                
@class    	Nao Informado
@from       Nao Informado
@param      
@attrib    	Nao Informado
@protected  Nao Informado

@author     DAC Denilso 
@single		19/06/2020
@version    Nao Informado
@since      Nao Informado  
@return    	Logico
@sample     Nao Informado
@obs        
@project    CAOA - Automatizar o processo de apontamento
@menu       Nao Informado
@history    Realizar o estorno dos saldos movimentações e excluzão de Veiculo ref. importação MES
/*/

User Function ZPCPF008(_lJob)
Local _aArea 		:= GetArea()
Local _lRet			:= .T.
Local _lZPCPF008 	:= SuperGetMV( "CMV_PCP001"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade
Local _aMsgErro		:= {}
Local _cTexto	
Local _nPos

Default _lJob   	:= .T.  //Deixar como default Falso

Private lVA010Auto

Begin Sequence
	//Caso não esteja abilitado
	If !_lZPCPF008
		Break
	Endif
	//Verifica se o Veículo possui integração com TOTVS MES

	/*
	//Tem que ser chamado pela integração do MES
	If !FWIsInCallStack("MATI681")
		Break
	Endif
	*/
	//SH6->(DbGoto(13861))
	If _lJob
		ZPCPF08EST(_lJob,_aMsgErro)
	Else
		Processa({|| ZPCPF08EST(_lJob,@_aMsgErro) },OemToAnsi(STR0099))   //Processando cadastro do Veiculo...
	Endif
End Sequence
//Funcionalidade para geração de mensagens
If Len(_aMsgErro) > 0
	U_ZPCPF07EM(@_aMsgErro,,"Informações estorno MT680EST ref. a importações MES")  //chama funcionalidae para carregar as numerações como chassi, numero de motor e ano/modelo
EndIf
If !_lJob
	_cTexto := ""
	For _nPos := 1 To Len(_aMsgErro)	
		_cTexto	+= 	_aMsgErro[_nPos]+CHR(13)+CHR(10)	
	Next _nPos			
	ApMsgInfo(_cTexto,"ATENCAO")
EndIf
RestArea(_aArea)
Return _lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCPF08GRV
Endereçamento Automatico chassi   
@author DAC denilso.carvalho
@since 20/06/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ZPCPF08EST(_lJob,_aMens)
Local _cAliasPesq   := GetNextAlias()
Local _lRet			:= .T.
Local _aCab 		:= {}
Local _aItens		:= {}
Local _aItCol		:= {}
Local _aError		:= {}
Local _cOp 			:= SH6->H6_OP
Local _cProduto		:= SH6->H6_PRODUTO
//Local _cIdent		:= SH6->H6_IDENT
Local _cChassi		:= Upper(SH6->H6_XCHASSI)
Local _cLocPad		:= SH6->H6_LOCAL
//Local _cEnder 		:= GetMv("CMV_PCP05C",.F.,"VEICULO NOVO")
Local _cTexto		:= ""
Local _cBkpFunName 	:= FunName()
Local _nBkpModulo  	:= nModulo
Local _cNumSeq		:= ""
Local _nPos

Private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
//Private lMsHelpAuto 	:= .T.  // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
Private lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog
Private M->VV1_CHASSI :=  Upper(SH6->H6_XCHASSI)  //Necessario fazer isto pois existe validação no TO do Padrão e o mesmo não tem as variaveis de memoria carregadas causando errolog DAC-09/07/2020

Begin Sequence 
	If Empty(_cChassi) .or. Empty(SH6->H6_XIDMES)
		Break
	EndIf
	//Atualizar entrada de Veículos
	VV1->(DbSetOrder(2)) //VV1_FILIAL+VV1_CHASSI
	//Não achou veiculo
	If !VV1->(DbSeek(xFilial("VV1")+_cChassi))
		Aadd(_aMens,{"ZPCPF08MT680EST16",OemToAnsi(STR0016)})  // Não localizado Veículo no cadastro de Veículos
		Break
	EndIf
	VVF->(DbSetOrder(1)) //VVF_FILIAL+VVF_TRACPA
	VVG->(DbSetOrder(1)) //VVG_FILIAL+VVG_TRACPA+VVG_CHAINT
	If VVF->(DbSeek(xFilial("VVF")+VV1->VV1_TRACPA))  
		Aadd(_aCab,{"VVF_FORPRO"  ,"0"   		     ,Nil})
		Aadd(_aCab,{"VVF_CLIFOR"  ,"F"   	      	 ,Nil})
		Aadd(_aCab,{"VVF_CODFOR"  ,VVF->VVF_CODFOR	 ,Nil})
		Aadd(_aCab,{"VVF_LOJA "   ,VVF->VVF_LOJA	 ,Nil})
		Aadd(_aCab,{"VVF_DATEMI"  ,VVF->VVF_DATEMI	 ,Nil})            
		//	Aadd(_aCab,{"VVF_NUMOP"   ,cD3_OP		 ,Nil})
		Aadd(_aCab,{"VVF_DOCSD3"  ,VVF->VVF_DOCSD3	 ,Nil})
		Aadd(_aCab,{"VVF_FORPAG"  ,VVF->VVF_FORPAG	 ,Nil})
		Aadd(_aCab,{"VVF_NUMFI"   ,VVF->VVF_NUMNFI	 ,Nil})
		Aadd(_aCab,{"VVF_SERIE"   ,VVF->VVF_SERNFI	 ,Nil})
	Endif
	_aItCol := {}
	If VVG->(DbSeek(xFilial("VVG")+VV1->VV1_CHAINT))
		_aItCol := {}
		Aadd(_aItCol,{"VVG_CHASSI"  ,VVG->VVG_CHASSI ,Nil})
		Aadd(_aItCol,{"VVG_CHAINT"  ,VVG->VVG_CHAINT ,Nil})
		Aadd(_aItCol,{"VVG_ESTVEI"  ,VVG->VVG_ESTVEI ,Nil})
		Aadd(_aItCol,{"VVG_CODORI"  ,VVG->VVG_CODORI ,Nil})
		Aadd(_aItCol,{"VVG_CODTES"  ,VVG->VVG_CODTES ,Nil})
		Aadd(_aItCol,{"VVG_SITTRI"  ,'0'			 ,Nil})
		Aadd(_aItCol,{"VVG_VALUNI"  ,VVG->VVG_CODTES ,Nil})
		Aadd(_aItens,aClone(_aItCol))
	EndIf
	If Len(_aCab) > 0
		FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT)
		SetFunName('VEIXA001')
		nModulo := 11
	   	lMsErroAuto 	:= .F.
   		lAutoErrNoFile 	:= .T.
		MsExecAuto(	{|a,b,c,d,e,f,g,h,i| VEIXX000(a,b,c,d,e,f,g,h,i) },_aCab,_aItens,{},4,"0",,.F.,,"4")//ESTORNO
		SetFunName(_cBkpFunName)
		nModulo := _nBkpModulo

		If lMsErroAuto            
			_aError := GetAutoGRLog()
			_cTexto := OemToAnsi(STR0007)+CHR(13)+CHR(10)  //Erro ExecAuto VEIXX000 chamado pelo PE MT680EST
			For _nPos := 1 To Len(_aError)	
				_cTexto	+= 	_aError[_nPos]+CHR(13)+CHR(10)	
			Next _nPos			
			Aadd(_aMens,{"ZPCPF08MT680EST07",_cTexto})		
			//Break
		EndIf
	EndIf
	//Apagar o Veiculo
	VV1->(DbSetOrder(1)) //VV1_FILIAL+VV1_CHASSI
	_aCab := {}
	Aadd(_aCab,{"VV1_FILIAL",	XFILIAL("VV1")		, nil})
	Aadd(_aCab,{"VV1_CODMAR",	VV1->VV1_CODMAR		, nil})
	Aadd(_aCab,{"VV1_CHAINT",	VV1->VV1_CHAINT		, nil})
	Aadd(_aCab,{"VV1_CHASSI",	VV1->VV1_CHASSI		, nil})
	Aadd(_aCab,{"VV1_TRACPA",	VV1->VV1_TRACPA		, nil})
	Aadd(_aCab,{"VV1_MODVEI",	VV1->VV1_MODVEI		, nil})
	Aadd(_aCab,{"VV1_LOCPAD",	VV1->VV1_LOCPAD		, nil})
	Aadd(_aCab,{"VV1_PROATU ",	VV1->VV1_PROATU		, nil})		//Proprietario Atual
	Aadd(_aCab,{"VV1_LJPATU",	VV1->VV1_LJPATU		, nil})		//Loja Proprietario

  	lMsErroAuto 	:= .F.
   	lAutoErrNoFile 	:= .T.
	MSExecAuto({|x,y| VEIXA010(x,y)},_aCab,5) 
	If lMsErroAuto            
		_aError := GetAutoGRLog()
		_cTexto := OemToAnsi(STR0017)+CHR(13)+CHR(10)  //Erro ExecAuto VEIXA010, não excluído Veículo no estorno
		For _nPos := 1 To Len(_aError)	
			_cTexto	+= 	_aError[_nPos]+CHR(13)+CHR(10)	
		Next _nPos			
		Aadd(_aMens,{"ZPCPF08MT680EST17",_cTexto})		
//		Break
	Endif

	//Localizar movimentação
	SD3->(DbSetOrder(1))   //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
	If !SD3->(DbSeek(XFilial("SD3")+_cOp+_cProduto))
		Aadd(_aMens,{"ZPCPF08MT680EST18",OemToAnsi(STR0018)})  //Não localizado movimentação(SD3) referente ao Veículo para estorno
		Break
	EndIf
	_cNumSeq := SD3->D3_NUMSEQ

	//Atualizar Saldo
	SDA->(DbSetOrder(1))  //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
   	BeginSql Alias _cAliasPesq	
	    SELECT 	ISNULL(SDA.R_E_C_N_O_,0) NREGSDA
    	FROM %Table:SDA%  SDA 
		WHERE 	SDA.DA_FILIAL 	= %xFilial:SDA%
			AND SDA.DA_PRODUTO  = %Exp:_cProduto%
			AND SDA.DA_LOCAL	= %Exp:_cLocPad%
			AND SDA.DA_NUMSEQ	= %Exp:_cNumSeq%
			AND SDA.DA_SALDO 	= 0 
	    	AND SDA.%notDel% 
		ORDER BY SDA.DA_CLIFOR
	EndSQL
		//AND SDA.DA_QTDORI	= SDA.DA_SALDO

	If (_cAliasPesq)->(Eof())
		Aadd(_aMens,{"ZPCPF08MT680EST18",OemToAnsi(STR0004)})  //Não localizado endereço para endereçamento automático chassi
		Break
	EndIf
	_aCab	:= {}
	While (_cAliasPesq)->(!Eof())
		SDA->(DbGoto(NREGSDA))
		//SDA Saldos a Distribuir           
		Aadd(_aCab,{"DA_PRODUTO",(_cAliasPesq)->DA_PRODUTO	, nil})
		Aadd(_aCab,{"DA_LOCAL"  ,(_cAliasPesq)->DA_LOCAL	, nil})
		Aadd(_aCab,{"DA_NUMSEQ" ,(_cAliasPesq)->DA_NUMSEQ	, nil})
		Aadd(_aCab,{"DA_DOC"    ,(_cAliasPesq)->DA_DOC		, nil})
		//SDB Movimentações Lote Custo FIFO 
		_aItCol := {}
		Aadd(_aItCol,{"DB_ITEM"   	,"0001"    					, nil})
		Aadd(_aItCol,{"DB_ESTORNO"  , CRIAVAR("DB_ESTORNO")  	, nil})
		Aadd(_aItCol,{"DB_LOCALIZ"  , cEnder            		, nil})
		Aadd(_aItCol,{"DB_DATA"     , dDataBase	        		, nil})
		Aadd(_aItCol,{"DB_QUANT"    , (_cAliasPesq)->DA_SALDO   , nil})
		Aadd(_aItCol,{"DB_NUMSERI"  , _cChassi      		    , nil})
		Aadd(_aItens,aClone(_aItCol))
    	lMsErroAuto 	:= .F.
    	lAutoErrNoFile 	:= .T.
		MsExecAuto({|x,y,z|mata265(x,y,z)},_aCab,_aItens,4)
		If lMsErroAuto            
			_aError := GetAutoGRLog()
			_cTexto := OemToAnsi(STR0005)+CHR(13)+CHR(10)  //Erro ExecAuto MATA265
			For _nPos := 1 To Len(_aError)	
				_cTexto	+= 	_aError[_nPos]+CHR(13)+CHR(10)	
			Next _nPos			
			Aadd(_aMens,{"ZPCPF08MT680EST05",_cTexto})		
			Break
		EndIf
		(_cAliasPesq)->(DbSkip())
	EndDo
End Begin
Return _lRet


