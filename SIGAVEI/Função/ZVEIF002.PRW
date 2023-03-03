#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ZVEIF002.CH"

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZVEIF001
Rdmake 	Funcionalidade responsavelpelo Imobilizar / Cancela Imobilizado de Veículos em lote por seleção	
@class    	Nao Informado
@from       Nao Informado
@param      
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC Denilso 
@single		08/04/2020
@version    Nao Informado
@since      Nao Informado  
@return    	Nil
@sample     Nao Informado
@obs        
@project    VEI102 - Bloqueio de Veículos (397320) - Analista Funcional: Renato Mariano
					 Pasta Desenvolvimento: M:\DevOps Caoa\Gaps\11 - Veiculos\VEI103 - Bloqueio de Veículos (397320)
@menu       SIGAVEI/MISCELANIA/ESPECIFICO CAOA/IMOBILIZAR\CANCELE IMOB
@history    
--------------------------------------------------------------------------------------*/

Static _oMark
Static _cOper

User Function ZVEIF002()
Local _aSays	    := {}
Local _aButtons	    := {}
Local _cCadastro    := OemToAnsi(STR0001 + " - "+OemToAnsi(STR0011) + "/" + OemToAnsi(STR0012))
Local _cTitle  	    := OemToAnsi(OemToAnsi(STR0011) + "/" + OemToAnsi(STR0012))
Local _aPar    	    := {}
Local _aRet    	    := {}
Local _nRet	        := 0
Local _lZVEIF002    := SuperGetMV( "CMV_VEI009"  ,,.T. )   //Parâmetro para indicação de utilização do programa tendo como Default Verdadeiro, não é necessário a criação do mesmo

Begin Sequence
    //Caso não seja para executar a rotina sair
    If !_lZVEIF002                             
        Break
    Endif           

    aAdd(_aPar,{3 , OemToAnsi(STR0026)	,1 ,{OemToAnsi(STR0024),OemToAnsi(STR0025)}	 ,50	,""	,.T.}) //I-Imobilizado/C-Cancela Imobilizado \ I-Imobilizado \ C-Cancela Imobilizado
    // Monta Tela principal
  	AADD(_aSays,OemToAnsi(STR0017))  //Este Programa tem  como  Objetivo  possibilitar  o  Imobilizar e  ou
 	AADD(_aSays,OemToAnsi(STR0018))  //Cancelar Imobilização de Veículos, ao qual será possivel selecionar  
	AADD(_aSays,OemToAnsi(STR0019)) //diversos veículos e permitira pesquisa/filtros no processo.
	AADD(_aSays,OemToAnsi(STR0020)) //Clique no botão Parâmetros para alterar as definições da rotina.
	AADD(_aSays,OemToAnsi(STR0021)) //Depois clique no Botão OK.
	AADD(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
	AADD(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
	AADD(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,"XINV001",.T.,.T.) 			}})

	FormBatch( _cCadastro, _aSays, _aButtons )
    If _nRet <> 1
        Break
    Endif
    If Len(_aRet) == 0
        Help("",1,OemToAnsi(STR0006),,OemToAnsi(STR0022),4,1) // ATENÇÃO / Necessário informar os parâmetros
        Break 
    Endif
    If _aRet[1]  == 1
        _cOper  := "I"
    Else      
        _cOper  := "C"
    Endif   
    //Verificar se o tecnico possui direitos para bloquear/desbloquear  
   	FwMsgRun(,{ || ZVF02MRK() }, OemToAnsi(If(_cOper=="I",STR0024,STR0025)),OemToAnsi(STR0013) )  //I-Imobilizar / C-Cancela Imobilizado | Aguarde...  
End Sequence
Return Nil

//Montar MarkBowkse
Static Function ZVF02MRK()
Local 	_cTitulo := STR0001 + " / "+ If(_cOper=="I",STR0024,STR0025) 
Begin Sequence
	If GetNewPar("MV_MIL0122", "0") == "1" .and. Empty(GetNewPar("MV_MIL0123", ""))
	   	FMX_HELP( "VA090ERR01", OemToAnsi(STR0002) , ; //Imobilização integrada com ativo fixo, mas tipo de movimentação não foi configurado.
                                OemToAnsi(STR0003) )   //Verifique o conteúdo do parâmetro MV_MIL0123.
		Break
	EndIf

	// Instanciamento da Classe de Browse
	_oMark := FWMarkBrowse():New()
	_oMark:SetAlias('VV1')
	_oMark:SetDescription(OemToAnsi(_cTitulo))   //Veículos
    _oMark:SetFieldMark( 'VV1_OK' )
    _oMark:SetValid({||U_ZVF2VLD()})
    _oMark:DisableDetails()
	_oMark:DisableReport()
 
	_oMark:SetOnlyFields({'VV1_CHAINT','VV1_CODMAR','VV1_DESMAR','VV1_CHASSI','VV1_MODVEI','VV1_DESMOD','VV1_COMMOD','VV1_FABMOD','VV1_PLAVEI','VV1_PROATU','VV1_LJPATU','VV1_NOMPRO','VV1_SITVEI','VV1_RENAVA'})
	_oMark:AddFilter('Veiculos em Estoque',"@ VV1_IMOBI = '1' OR (VV1_ESTVEI = '0' AND ( ( VV1_SITVEI='0' AND VV1_TRACPA<>' ' ) OR VV1_SITVEI IN ('2','8') ))",.t.,.t.,)
    //_oMark:AddFilter(OemToAnsi(STR0030) ,"VV1_SITVEI <> '1'" 		,.T.,.T.)  //Veículo não Vendido
	If _cOper  == "C"  
        _oMark:AddFilter(OemToAnsi(STR0029) ,"VV1_IMOBI == '1'" 	,.T.,.T.)  //Imobilizado
    Else
        _oMark:AddFilter(OemToAnsi(STR0028) ,"VV1_IMOBI $ ' 0'"  	,.T.,.T.)  //Não Imobilizado
    Endif    
  	_oMark:AddLegend( 'VV1_IMOBI $ " 0"' , 'BR_VERDE'   , OemToAnsi(STR0029) ) //Não Imobilizado
  	_oMark:AddLegend( 'VV1_IMOBI == "1"' , 'BR_VERMELHO', OemToAnsi(STR0028) ) //Imobilizado
	_oMark:Activate()
End Sequence
Return Nil

/*/{Protheus.doc} MenuDef
Menu
@author DAC - Denilso
@since 07/04/2020
@version 1.0

@type function
/*/
Static Function MenuDef()
Local aRotina := {}
Begin Sequence

	  //ADD OPTION aRotina TITLE OemToAnsi(STR0027)  ACTION 'ZVF2IMOB()' OPERATION 4 ACCESS 0   //Processar
	  ADD OPTION aRotina TITLE OemToAnsi(STR0027)  ACTION 'U_ZVF2IMOB' OPERATION 4 ACCESS 0   //Processar

End Sequence
Return aRotina


/*---------------------------------------------------------------------------------------
{Protheus.doc} ZVF2IMOB
Responsavel Processar registros selecionados
@author     DAC - Denilso Almeida Carvalho
@param      _nOpc 1=Imobilizado 2=Cancela
@single		  08/04/2020
@version    P.12
@obs        
@project    
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/
//Static Function ZVF2IMOB()
User Function ZVF2IMOB()
Local _lRet     := .T. 
Begin Sequence
    If _cOper == "I" .and. !MsgYesNo(OemToAnsi(STR0004),OemToAnsi(STR0006)) //Confirma Imobilizar veículo? / Atenção
        Break
	  ElseIf _cOper == "C" .and. ! MsgYesNo(OemToAnsi(STR0005),OemToAnsi(STR0006))  //Confirma estorno de imobilização? / Atenção
        Break
    Endif             
    //Processar itens selecionados
    FwMsgRun(,{ || ZVF2IPRC(If(_cOper=="I",.T.,.F.)) }, OemToAnsi(STR0014), OemToAnsi(STR0013))  //"Aguarde..." | Processando registros selecionados...
End Sequence
Return _lRet

//Validação seleção
User Function ZVF2VLD()
Local _lRet := .T.
Local _aArea      := GetArea()
Begin Sequence
  	If _cOper == "I" .and. ! VXI00101_ValidaVeiculo(VV1->VV1_CHAINT)
		_lRet := .F.	
      	Break
    EndIf

	//Quando for para cancelamento
	If _cOper == "C" .and. !Empty(GetNewPar("MV_MIL0123", ""))
		//para a Gravação do SD3 é necessário o parametro MV_MIL0123 estar informado
		If Empty(VV1->VV1_IMOSD3)
			Help(" ",1,STR0032 + CRLF + RetTitle("VV1_IMOSD3") + ": " + VV1->VV1_IMOSD3 )  //Verificar Movimentação de imobilização esta em branco 
			_lRet := .F.	
			Break
		Endif
		SD3->(dbSetOrder(2))
		If ! SD3->(dbSeek(xFilial("SD3") + VV1->VV1_IMOSD3 ))
			Help(" ",1,STR0031 + CRLF + RetTitle("VV1_IMOSD3") + ": " + VV1->VV1_IMOSD3 )  //Movimentação de imobilização não encontrada
			_lRet := .F.	
			Break
		EndIf
		If SubStr(SD3->D3_CF,1,2) == "PR" .Or. Subs(SD3->D3_CF,3,1)$"2457"
			Help(" ",1,"A240NAO")
			_lRet := .F.
			Break
		Endif
	EndIf
End Sequence
RestArea(_aArea)
Return _lRet

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZVF2IMOBPR
Responsavel Processar registros selecionados
@author     DAC - Denilso Almeida Carvalho
@single		  08/04/2020
@version    P.12
@obs        
@project    
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/
Static Function ZVF2IPRC(_lImobiliza,lEnd)
Local _lRet   := .T.
Local _cMarca := _oMark:Mark()
Local _nProc  := 0

Default lEnd       := .F.               

Begin Sequence
    ProcRegua(0)
    //para este processo tenho que desabilitar o valid
    If lEnd
        MsgInfo(OemToAnsi(STR0015),OemToAnsi(STR0016))  //Cancelado pelo Usuário / Processo abortado
        Break
    Endif
    //Se não estiver marcado pular registro
    VV1->(DbGotop())
    While VV1->(!Eof())
        //IncProc()
        If !_oMark:IsMark(_cMarca)
            VV1->(DbSkip())
            Loop
        Endif
        //Quando for para imobilizar
        If _lImobiliza
            _lRet := ZVF2PRCIMO()  //VA0900013_Imobilizar("VV1",VV1->(Recno()),/*nOpc*/)    
        //Cancela Imobilizado
        Else
            _lRet := ZVF2PRCCAN()
	      EndIf
        //Caso tenha algum erro aborto processamento
        If _lRet
        	_nProc ++
   			RecLock("VV1", .F.)
   			VV1->VV1_OK 	:= "  "
			VV1->(MsUnlock())
		Endif

       	VV1->(DbSkip())
	Enddo      
    MsgInfo(STR0008 +" "+ StrZero(_nProc,7) +" "+If(_lImobiliza,OemToAnsi(STR0011),OemToAnsi(STR0012)),OemToAnsi(STR0009))  //Registros atualizados /Bloqueio /Desbloqueio /Processado
    _oMark:GoTop()
    _oMark:Refresh()
End Sequence
Return _lRet

//funcinalidade para Imobilizar Veículo
Static Function ZVF2PRCIMO()
//Local oModel070
Local cDocSD3
Local _lRet := .T.
If ! VXI00101_ValidaVeiculo(VV1->VV1_CHAINT)
    Return .F.
EndIf
//CursorWait()
oModel070 := FWLoadModel( 'VEIA070' )
oModel070:SetOperation( MODEL_OPERATION_UPDATE )
If ! oModel070:Activate()
   	MostraErro()
   	CursorArrow()
   	Return .F.	  
EndIf
Begin Transaction
    Begin Sequence
		If ! VXI00101_ValidaVeiculo(oModel070:GetValue("MODEL_VV1","VV1_CHAINT"))
	      	_lRet := .F.
			Break
		EndIf
	    If ! oModel070:SetValue("MODEL_VV1","VV1_IMOBI","1")
	      	_lRet := .F. 
			Break
		EndIf
	    If ! Empty(GetNewPar("MV_MIL0123", ""))
		    If !MovEstoque(@cDocSD3)				
			    _lRet := .F.	
				Break
		    EndIf
		    If ! oModel070:SetValue("MODEL_VV1","VV1_IMOFD3",xFilial("SD3"))
				_lRet := .F.
		        Break
	      	EndIf

	      	If ! oModel070:SetValue("MODEL_VV1","VV1_IMOSD3",cDocSD3)
				_lRet := .F.
		        Break
	      	EndIf
			
		EndIf
	    If oModel070:VldData()
	      	oModel070:CommitData()
		Else
		   Break
			_lRet := .F.
	    EndIf
Recover
		DisarmTransaction()
		MsUnlockAll()
		/*
		aErro := oModel070:GetErrorMessage()
		AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
		AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
		AutoGrLog( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
		MostraErro()
		Return .F.
		*/
	End Sequence
End Transaction
//	CursorArrow()
Return _lRet

Static Function ZVF2PRCCAN  //VA0900033_CancImobilizacao()
Local oModel070
Local _lRet := .T.
//	CursorWait()
oModel070 := FWLoadModel( 'VEIA070' )
oModel070:SetOperation( MODEL_OPERATION_UPDATE )
If ! oModel070:Activate()
		MostraErro()
		CursorArrow()
		Return .F.
EndIf
Begin Transaction
	  Begin Sequence
		//Somente movimentara o estoque se o parametro estiver ativo DAC 10/04/2020
        If !Empty(GetNewPar("MV_MIL0123", ""))
			If !EstMovImob(oModel070)
				_lRet := .F.
			   	Break
		    EndIf
		Endif
		//Deixar atualizar o processo necessário verificar com os envolvidos se a parametrização tem que estar ativa pois na base não estão relacionados os itens do SD3 no VV1 - DAC
		oModel070:SetValue("MODEL_VV1","VV1_IMOBI","0")
		oModel070:SetValue("MODEL_VV1","VV1_IMOFD3"," ")
		oModel070:SetValue("MODEL_VV1","VV1_IMOSD3"," ")

		If oModel070:VldData()
		    oModel070:CommitData()
		Else
			_lRet := .F.
			Break
  		EndIf
Recover
		DisarmTransaction()
		MsUnlockAll()
		/*
		aErro := oModel070:GetErrorMessage()
		AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
		AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
		AutoGrLog( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
		MostraErro()
		Return .F.
		*/
    End Sequence
End Transaction

//	CursorArrow()
Return _lRet

Static Function MovEstoque(cDocSD3)

Local aItensNew
Local lRet := .T.

Local aCab241 := {}
Local aItens241 := {}

Private N := 1
If ! FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT)
	Return .f.
EndIf

aItensNew := {}

cDocSD3  := Criavar("D3_DOC")
cDocSD3	:= IIf( Empty(cDocSD3) , NextNumero("SD3",2,"D3_DOC",.T.) , cDocSD3)
cDocSD3	:= A261RetINV(cDocSD3)

aCab241 := {{ "D3_DOC"     , cDocSD3 , NIL },;
			{ "D3_TM"      , GetNewPar("MV_MIL0123", "") , NIL },;
			{ "D3_EMISSAO" , dDataBase , Nil } }

AADD( aItens241,{{ "D3_COD"    , SB1->B1_COD    , NIL },; // Veiculo
				 { "D3_QUANT"  , 1              , NIL },;
				 { "D3_LOCAL"  , SB1->B1_LOCPAD , NIL } } )
lMsHelpAuto := .t.
lMsErroAuto := .f.
MSExecAuto({|x,y,z| Mata241(x,y,z)},aCab241,aItens241,Nil)
If lMsErroAuto
   //MostraErro()
	lRet := .f.
EndIf

Return lRet

Static Function EstMovImob(oModel070)

Local lRet := .T.

Local aCab241 := {}
Local aItens241 := {}
Local cBkpFilAnt := cFilAnt

Private N := 1

If !Empty(oModel070:GetValue("MODEL_VV1","VV1_IMOFD3"))
	cFilAnt := oModel070:GetValue("MODEL_VV1","VV1_IMOFD3")
EndIf

lRet := FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT)

If lRet .and. ! Empty(oModel070:GetValue("MODEL_VV1","VV1_IMOSD3"))
	SD3->(dbSetOrder(2))
	If ! SD3->(dbSeek(xFilial("SD3") + oModel070:GetValue("MODEL_VV1","VV1_IMOSD3") ))
		FMX_HELP("VA090ERR02",STR0013 + CRLF + RetTitle("VV1_IMOSD3") + ": " + oModel070:GetValue("MODEL_VV1","VV1_IMOSD3") ) // "Movimentação de imobilização não encontrada."
		lRet := .f.
	EndIf
EndIf

If lRet
	lMsHelpAuto := .t.
	lMsErroAuto := .f.
	MSExecAuto({|x,y,z| Mata241(x,y,z)},aCab241,aItens241,6)
	If lMsErroAuto
		MostraErro()
		lRet := .f.
	EndIf
EndIf

cFilAnt := cBkpFilAnt

Return lRet
