#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#include "topconn.ch"
#include "fileio.ch"
#include "ZPCPF009.CH"

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZPCPF009
Rdmake 	Integração PROTHEUS - PCP x MES chamado pelo PE MATI681INT fazer a validação para saber se continua o processo
@class    	Nao Informado
@from       Nao Informado
@param      PARAMIXB - oXml com dados da ordem de produção
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC - Denilso 
@single		15/07/2020
@version    Nao Informado
@since      Nao Informado  
@return    	_aRet
@sample     Nao Informado
@obs        Realizar validação para permitir ou não a importação do XML MES
@project    CAOA - Automatizar o processo de apontamento
@menu       Nao Informado
@history    09/10/2020 - Acrescentado projeto DEV01 - Especificação Funcional Correto_V2_Validação 
						 Responsáel por gravar tabela temporaria da importação MES	

/*/


User Function ZPCPF009(_lJob, _lGravaSZZ)
Local _aRet			:= {}
Local _aArea		:= GetArea() //ParamIXB
Local _lZPCPF009 	:= SuperGetMV( "CMV_PCP005"  ,,.T.)  	//parametro para habilitar/desabilitar funcionalidade ZPCPF009

Default _lJob 		:= .T.  //informação do JOB se não colocada assumira senpre como JOB
Default _lGravaSZZ	:= .T.	//Informação para gravação da tabela temporária referente processamento OP recebidas MES SZZ caso não informada assumirá que deeverá sempre gravar 

//Private oXml
Begin Sequence
	If !_lZPCPF009
		ConOut("ZPCPF009 - Integracao esta pausada - Verificar parametro CMV_PCP005")
		Break
	Endif
	_aRet := ZPCPF009VL()
	//desta forma ta dando erro
	//ConOut("ZPCPF009 retorno MES : "+_aRet[1]+" - "+_aRet[2]+" - "+_aRet[3])
End Sequence
RestArea( _aArea )
Return _aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCPF009VL
Rdmake 	Validar dados do XML antes a importação do MES   
@author DAC denilso.carvalho
@since 16/07/2020
@version 1.0
@obs _aChave - 	Campos que servirão para pesquisa no envio de e-mail se não enviados verificara pela tabela padrão os mesmos não estarão 
				posicionados no D3 então é necessário enviar para substituir a pesquisa pelo padrão

/*/
//-------------------------------------------------------------------

Static Function ZPCPF009VL(_lJob, _lGravaSZZ)
Local _cLocPad		:= AllTrim(SuperGetMV( "CMV_PCP003"  ,,'VN'))  	//parametro Local padrão para veiculos novos
//Local _cEndereco	:= "VEICULO NOVO"
Local _cGrpProd		:= AllTrim(SuperGetMV( "CMV_PCP004"  ,,'VEIA'))  //parametro Grupo de produtos padrão para veiculos novos
Local _nTamChassi	:= SuperGetMV( "CMV_PCP008"  ,,17)
Local _aValida		:= {}
Local _aMsgErro		:= {}
Local _aChave		:= {}   //Campos que servirão para pesquisa no envio de e-mail se não enviados verificara pela tabela padrão os mesmos não estarão posicionados no D3 então é necessário enviar para substituir a pesquisa pelo padrão
Local _aRet			:= {}
Local _nQtdeAprov	:= 0
Local _cLocal       := ""
Local _cLocaliza	:= ""
Local _cNumOp		:= ""
Local _cIdMes		:= ""
Local _cChassi 		:= ""   
Local _cNumMotor	:= ""
Local _lAchouVeic	:= .F.  //identifica se localizou o veiculo
Local _cCodProd
Local _nValData
Local _cDocCod 
Local _aDocCod 
Local _nPos
Local _cTexto
Local _cAnoFab
Local _nQuantSZZ
Local _cPT
Local _cMaquina
Local _lEstorno
//Local _nCusFut
//Garantir informações destes paraetros as mesmas podem ser chamadas por outras funcionalidades
Default _lJob 		:= .T.  //informação do JOB se não colocada assumira senpre como JOB
Default _lGravaSZZ	:= .T.	//Informação para gravação da tabela temporária referente processamento OP recebidas MES SZZ caso não informada assumirá que deeverá sempre gravar 

Begin Sequence
	ConOut("ZPCPF009 - Acessou Backflush 3.0  "+DTOC(Date()) + " - " + Time())
	Aadd(_aRet,{"MT2681IMPMES00","Acesso ZPCPF009 PE MATI681INT "+DtoC(Date())+" - "+Time()})   
	//Carregar campos caso envie e-mail não devera pesquisar a tabela sendo que as informações serão substituidas por esta matriz
	Aadd(_aChave,{"D3_OP"		,	""})	
	Aadd(_aChave,{"D3_COD"		,	""})
	Aadd(_aChave,{"H6_XCHASSI"	, 	""})
	Aadd(_aChave,{"D3_IDENT"	, 	""})
	Aadd(_aChave,{"H6_XIDMES"	, 	""})
	//inicio o retorno como verdadeiro
	aAdd(_aValida, .F.) // Irá executar a rotina padrão
   	aAdd(_aValida, .T.) // XML importado com sucesso
   	aAdd(_aValida, "ZPCPF009 - XML processado com sucesso ") // Como não houve erro, o terceiro parâmetro deve estar em branco.

	/*
 	<BusinessMessage>
    <BusinessEvent>
      <Entity>productionappointment</Entity>
      <Identification>
        <key name="IDPCFactory">cd5e35fc-b02d-43d2-b8b8-96df5b09cc9d</key>
      </Identification>
      <Event>upsert</Event>
	*/
	//OXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSEVENT:_IDENTIFICATION:_KEY:Text
	_cIdMes := ZPCF009IDM(oXml,@_aMsgErro)  //Informações importação MES referente ao XML  
	ConOut("ZPCPF009 - IDMES "+If(Valtype(_cIdMes)=="C",_cIdMes," type diferente ")+" Backflush 3.0  "+DTOC(Date()) + " - " + Time())
	U_ZPCPF09PS(@_aChave, "H6_XIDMES", _cIdMes)
	If Empty(_cIdMes)  //Não localizou o ID
		ConOut("ZPCPF009 - Não localizado IDMES "+If(Valtype(_cIdMes)=="C",_cIdMes," type diferente ")+" Backflush 3.0  "+DTOC(Date()) + " - " + Time())
		Break
	EndIf

/*
	If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key") <> "U" 
		If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key") == "A"  //nestes casos são reprocessamento
			For _nPos := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key)
				_cChave := oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key[_nPos]:Text
                If !_cchave $ "true_false" .and. Len(_cchave) > 30
					_cIdMes := _cchave
					Exit
				Endif
			Next
			If Empty(_cIdMes)  //Não localizou o ID
				Aadd(_aMsgErro,{"MT2681IMPMES28",OemToAnsi(STR0028)}) //Informações referente ao ID MES não conferem com a formatação definida  
				Break
			EndIf
		ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key") == "C"  //nestes casos são reprocessamento
   			_cIdMes := AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text)
		Else
			Aadd(_aMsgErro,{"MT2681IMPMES27",OemToAnsi(STR0027)}) //Tipo de dado não confere com a estrutura definida  
			Break
		EndIf
	Else 
		Aadd(_aMsgErro,{"MT2681IMPMES01",OemToAnsi(STR0001)}) //Não possui possui ID MES
		Break
		//_cIdMes := SOH->OH_IDMES  //tem que estar posicionado na SOH
	EndIf
	//carrego a informação  caso tenha que enviar e-mail
*/
	//verificar se o IDMES da SZZ EXISTE
	If ZPCF009ZIM(_cIdMes)
		Aadd(_aMsgErro,{"MT2681IMPMES35",OemToAnsi(STR0035)})  //IDMES ja cadastrado na tabela de Backflush
		//Definido que caso enconte o Veículo retorne verdadeiro ara que não fique repetindo a msg ja que foi integrado DAC 22/12/2020
		For _nPos := 1 To Len(_aMsgErro)
			_cTexto += NoAcento(_aMsgErro[_nPos,1])+ " - " +NoAcento(_aMsgErro[_nPos,2]) +CHR(13)+CHR(10)
		Next
		//Enviar e-mail com erros
		_aValida[3] := _aValida[3]+" "+_cTexto
		_aMsgErro   := {}  //Zero para não retornar falso
		_lGravaSZZ	:= .F.
		Break
	Endif

    //Código do local
    If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text") == "U" 
		Aadd(_aMsgErro,{"MT2681IMPMES02",OemToAnsi(STR0002)})  //Não possui TAG WarehouseCode
		Break
	Endif
    _cLocal := AllTrim(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text)
	//Não emitir msg o mesmo pode pertencer a outro processo sem endereçamento
	If Empty(_cLocal)  
		Aadd(_aMsgErro,{"MT2681IMPMES03",OemToAnsi(STR0003)+" "+_cLocal})	//Local não informado
		Break
	EndIf	

	/*  Não fazer esta validação poderá testar integração não só de veiculo novo
	//Neste caso não é veiculo novo não realizar validação
	If 	_cLocPad <> _cLocal
		Break
	Endif
	*/

    //Localização / LocationCode
    If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LocationCode:Text") == "U" 
		Aadd(_aMsgErro,{"MT2681IMPMES04",OemToAnsi(STR0004)})	//Não possui TAG LocationCode
		Break
	EndIf
	_cLocaliza := AllTrim(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LocationCode:Text)
	//Não emitir msg o mesmo pode pertencer a outro processo sem endereçamento
	If Empty(_cLocaliza)  
		Aadd(_aMsgErro,{"MT2681IMPMES05",OemToAnsi(STR0005)+" "+_cLocaliza})   //Endereçamento localização não informado
		Break
	EndIf
	/*	
	//Neste caso deconsiderar processo pois não é somente veiculo Novo
	If _cLocaliza <> _cEndereco
		Break
	EndIf
	*/

	//Produto
    If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text") == "U" 
		Aadd(_aMsgErro,{"MT2681IMPMES34",OemToAnsi(STR0034)})  //Não possui TAG ItemCode
		Break
	EndIF	
   	_cCodProd 	:= oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text
	_cCodProd	:=	Stuff( Space(TamSX3("D3_COD")[1]) , 1 , Len(_cCodProd) , _cCodProd )
	//carrego a informação caso tenha que enviar e-mail
	U_ZPCPF09PS(@_aChave, "D3_COD", _cCodProd)
	SB1->(DbSetOrder(1))  //B1_FILIAL+B1_COD
	If Empty(_cCodProd)  
		Aadd(_aMsgErro,{"MT2681IMPMES14",OemToAnsi(STR0014)})	//Código de produto não informado
	Else
		If !SB1->( dbSeek( xFilial("SB1")+_cCodProd ) )
			Aadd(_aMsgErro,{"MT2681IMPMES15",OemToAnsi(STR0015)+" - "+_cCodProd})	//Produto não Cadastrado
		Else
			If SB1->B1_MSBLQL == '1'
				Aadd(_aMsgErro,{"MT2681IMPMES16",OemToAnsi(STR0016)+" - "+_cCodProd})	//Produto Bloqueado
			EndIf
			If Empty(SB1->B1_XPCPSEQ)
				Aadd(_aMsgErro,{"MT2681IMPMES16",OemToAnsi(STR0037)+" - "+_cCodProd})	//Produto Bloqueado
			EndIf
		EndIf
	EndIF

	//DAC 28/10/2020
	//Conforme alinhado com Evandro neste ponto validar se o cadastro de produtos terá a informação da Sequencia informada caso não tenha retornar como erro MES
	
    //Ordem de produção
    If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text") == "U" 
		Aadd(_aMsgErro,{"MT2681IMPMES06",OemToAnsi(STR0006)})  //Não possui TAG ProductionOrderNumber
		Break
	EndIf
    _cNumOp := AllTrim(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text)
	//carrego a informação caso tenha que enviar e-mail
	U_ZPCPF09PS(@_aChave, "D3_OP", _cNumOp)
	If Empty(_cNumOp)  
		Aadd(_aMsgErro,{"MT2681IMPMES07",OemToAnsi(STR0007)})  //Numero de OP não informado
		Break
	EndIf	

	//Se não envontrar deixar passar pois existem processos sem OP 
	SC2->(dbSetOrder(1))  //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
	If !SC2->(DbSeek(xFilial('SC2')+_cNumOp))
		Aadd(_aMsgErro,{"MT2681IMPMES08",OemToAnsi(STR0008)})	//Numero de OP não Localizada
		Break
	Endif
	//Verificar se OP Existe, Se não esta encerrada (não pode estar encerrada)
    //se C2_QUJE >= C2_QUANT ERRO
	//verificar se OP esta encerrada se estiver C2_DATRF preenchido não pode ter apontamento de produção
	If !Empty(SC2->C2_DATRF)
		Aadd(_aMsgErro,{"MT2681IMPMES09",OemToAnsi(STR0009)})	//OP Encerrada não permite apontamento
		Break
	EndIf
	//Caso não seja Firme não validar
	If SC2->C2_TPOP <> "F"
		Aadd(_aMsgErro,{"MT2681IMPMES11",OemToAnsi(STR0011)})	//OP não possui o tipo de OP Firme
		Break
	EndIf
    If SC2->C2_LOCAL <> _cLocal 
		Aadd(_aMsgErro,{"MT2681IMPMES12",OemToAnsi(STR0012)+" OP "+SC2->C2_LOCAL+" XML "+_cLocal})	//Local da OP não confere com Local enviado no XML
		Break
	EndIf
	If AllTrim(SC2->C2_PRODUTO) <> AllTrim(_cCodProd)
		Aadd(_aMsgErro,{"MT2681IMPMES13",OemToAnsi(STR0013)+" "+_cCodProd}) //Código de produto informado na OP diferente do código de produto informado no XML 
		Break
	EndIf

	//Posicionar a OP para validar a quantidade
	If SC2->C2_QUJE >= SC2->C2_QUANT 
		Aadd(_aMsgErro,{"MT2681IMPMES10",OemToAnsi(STR0010)+ " Produzida "+AllTrim(Str(SC2->C2_QUJE))+" Existente "+AllTrim(Str(SC2->C2_QUANT)) })	//Quantidade produzida da OP maior que a quantidade existente na OP
		Break
	EndIf
	//Evandro DAC 16/10/2020
	//Implementar validação para a tabela SZZ não deixar ultrapassar a quantidade de OP 
	_nQuantSZZ := ZPCF009LZZ(_cNumOp)
	If (SC2->C2_QUJE + _nQuantSZZ) >= SC2->C2_QUANT
		Aadd(_aMsgErro,{"MT2681IMPMES36",OemToAnsi(STR0036)+ " Produzida/BackFlush " +AllTrim(Str(SC2->C2_QUJE+_nQuantSZZ))+ " Existente " +AllTrim(Str(SC2->C2_QUANT)) })	//Quantidade produzida da OP mais quantidade do BackFlush maior que a quantidade existente na OP
		Break
	EndIf

    //deixado somente para validação do processo não retorna no xml
	//Neste ponto serão feitas as validações sem interrupções para acumular os erros
    //Quantidade aprovada

	If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ApprovedQuantity:Text") == "U" 
		Aadd(_aMsgErro,{"MT2681IMPMES18",OemToAnsi(STR0018)})	//Não possui TAG ApprovedQuantity
		Break
	EndIf	
   	_nQtdeAprov := Val(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ApprovedQuantity:Text)
	If _nQtdeAprov == 0  
		Aadd(_aMsgErro,{"MT2681IMPMES19",OemToAnsi(STR0019)})	//Quantidade aprovada não informada
	Else  //Caso tenha quantidade validar se a quantidade enviada é maior que a quandidade a produzir
		If _nQtdeAprov > ( SC2->C2_QUANT - SC2->C2_QUJE) // +SZZ pendente
			Aadd(_aMsgErro,{"MT2681IMPMES20",OemToAnsi(STR0020)+" - "+AllTrim(Str(SC2->C2_QUANT - SC2->C2_QUJE))})  //"Quantidade informada no MES maior que a quantidade a produzir na OP, quantidade a produzir"
			//Break
		EndIf
	EndIf

	// Indicação de produção Parcial/Total DAC 13/11/2020
   	_cPT := "P"
    If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_CloseOperation:Text") != "U" .And. ;
       !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_CloseOperation:Text)
       	If AllTrim(Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_CloseOperation:Text)) == "TRUE"
        	_cPT := "T"
        Else
        	_cPT := "P"
        EndIf
    EndIf

    //Máquina DAC 14/11/2020
	_cMaquina := ""
    If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_MachineCode:Text") != "U" .And. ;
       !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_MachineCode:Text)
        _cMaquina := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_MachineCode:Text
    EndIf


	//Verificar Se possui Chassi/motor / ano
	If 	_cLocPad == _cLocal .and. SB1->B1_GRUPO == _cGrpProd
   		//localizar a Marca
		VV2->(DbSetOrder(7))  //VV2_FILIAL+VV2_PRODUT
		If !VV2->(DbSeek(xFilial('VV2')+SB1->B1_COD))
			Aadd(_aMsgErro,{"MT2681IMPMES17",OemToAnsi(STR0017)+" - "+_cCodProd})	//Marca de Veículo não cadastrada para o Veículo
		Endif

		_cChassi := ""
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_DocumentCode:Text") == "U" 
			Aadd(_aMsgErro,{"MT2681IMPMES21",OemToAnsi(STR0021)})	//Não foi enviada na TAG informações do Chassi
			Break
    	Endif
		_cDocCod :=	Alltrim(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_DocumentCode:Text)        	
   		_aDocCod := StrTokArr(_cDocCod,";")//95PBAK51BLBK111840;SerialNumberMotor;2019;2019        	
   		If Len(_aDocCod) >= 1   //a Primeira posição é reterente ao Chassi       
     		_cChassi := Upper(_aDocCod[1]) 
		EndIf
		If Empty(_cChassi)
			Aadd(_aMsgErro,{"MT2681IMPMES22",OemToAnsi(STR0022)})	//Não foi informado numeração do Chassi
		ElseIf Len(AllTrim(_cChassi)) <> _nTamChassi
			Aadd(_aMsgErro,{"MT2681IMPMES33",OemToAnsi(STR0033)})	//Chassi invalido conforme formatação passada
			//Break
		Endif
     	If Len(_aDocCod) < 2        
			Aadd(_aMsgErro,{"MT2681IMPMES23",OemToAnsi(STR0023)})	//Não foi informado numeração do Motor
			_cNumMotor := ""
		Else
			_cNumMotor := Upper(_aDocCod[2])
		EndIf
     	If Len(_aDocCod) < 4        
			Aadd(_aMsgErro,{"MT2681IMPMES24",OemToAnsi(STR0024)})	//Não foi informado Ano de fabricação e modelo do Veículo
		Else
			_cAnoFab := _aDocCod[3]+_aDocCod[4]
			_nValData :=  Val(_aDocCod[4]) - Val(_aDocCod[3])
			If _nValData > 1  .or. _nValData < 0
				Aadd(_aMsgErro,{"MT2681IMPMES32",OemToAnsi(STR0032)+" - "+_aDocCod[3]+"/"+_aDocCod[4]})	//Ano de Fabricação e Modelo não é permitido 
			EndIf 
			//somente para testes de validação verificar se esta capitando o custo
			//_nCusFut := U_ZGENCST(_cCodProd, _cLocal, _aDocCod[3]+_aDocCod[4])  //Verifica em varias tabelas o custo para o veiculo
     	Endif     	
		U_ZPCPF09PS(@_aChave, "H6_XCHASSI", _cChassi)
		//localizr na VV1 
		_lAchouVeic := .F.
		If !Empty(_cChassi) .and. !Empty(_cNumMotor)
			_lAchouVeic := U_ZPCF009VEI(_cChassi, _cNumMotor, VV2->VV2_CODMAR, VV2->VV2_MODVEI, VV2->VV2_SEGMOD, @_aMsgErro)
		EndIF
		//Validar se existe registro no SD3 caso exista não ira continuar
		ZPCF009MVP(_cIdMes, _cChassi, _cNumOp, _cCodProd, _cLocal, @_aMsgErro)
	Endif	
End Sequence
// Existindo erro
Aadd(_aRet,{"MT2681IMPMES00","Final ZPCPF009 PE MATI681INT "+DtoC(Date())+" - "+Time()})   
If Len(_aMsgErro) > 0
	//Pegar dados dos erros ocorridos
	_cTexto := NoAcento(OemToAnsi(STR0025)) +CHR(13)+CHR(10)  //*** Problemas ocorridos na leitura do XML o mesmo não será importado...
	For _nPos := 1 To Len(_aMsgErro)
		_cTexto += NoAcento(_aMsgErro[_nPos,1])+ " - " +NoAcento(_aMsgErro[_nPos,2]) +CHR(13)+CHR(10)
	Next
	//De acordo com definição em reunião 06/08/2020 ficou definido que ira processar mesmo localizando o 
	//Veiculo não processara o PE SD3250I sera apresentada msg 
	//será até a definição de uma nova versão
	If !_lAchouVeic
		_aValida[1] := .F.
		_aValida[2]	:= .F.
		_aValida[3]	:= "[CAOA] "+_cTexto
	ElseIf _lAchouVeic
		_aValida := {}
		aAdd(_aValida, .F.) // Irá executar a rotina padrão
   		aAdd(_aValida, .T.) // XML importado com sucesso
		aAdd(_aValida, "[CAOA] "+_cTexto)
	EndIf	
	//colocar este trecho abaixo dentro da validação da msg erro após validação importações
	//adicione hora inicial e final
	For _nPos := 1 To Len(_aRet)
		AAdd(_aMsgErro,_aRet[_nPos])
	Next
	//Enviar e-mail com erros
	U_ZPCPF07EM(_aMsgErro,_aChave,OemToAnsi(STR0026))  //Informações importação MES referente ao XML  
//Caso não tenha erros grava em tabela temporaria
Else
	If _lGravaSZZ
		//Verifica se é apontamento ou estorno
		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReversedReport:Text") <> "U"
			_lEstorno := Iif(Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReversedReport:Text)=="TRUE",.T.,.F.)
		Else
			_lEstorno := .F.		
		EndIF
		ZPCF9GRVZZ(_cIdMes, _cChassi, _cAnoFab, _cNumMotor, _cNumOp, _cCodProd, _nQtdeAprov, _cLocal, _cPT, _cMaquina,_lEstorno)
	EndIf 
EndIf
ConOut("ZPCPF009 - Finalizou Backflush 3.0  "+DTOC(Date()) + " - " + Time())
Return _aValida


//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCPF007EL
Rdmake 	Adcionar informação (conteúdo em _aChave)   
@author DAC denilso.carvalho
@since 17/07/2020
@version 1.0
@obs _aChave - 	Campos que servirão para pesquisa no envio de e-mail se não enviados verificara pela tabela padrão os mesmos não estarão 
				posicionados no D3 então é necessário enviar para substituir a pesquisa pelo padrão

/*/
//-------------------------------------------------------------------

User Function ZPCPF09PS(_aChave,_cCampo,_cConteudo)
Local _nPos
Begin Sequence
	_nPos := aScan(_aChave,{|x| _cCampo  == AllTrim(x[1]) })
	_aChave[_nPos,2] 	:= _cConteudo
End Begin
Return Nil



//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCF009IDM
Rdmake 		Retornar o numero do ID MES de acordo com XML   
@author 	DAC denilso.carvalho
@since 		03/08/2020
@version 	1.0
@param      _oXml 		- objeto com os dados do xml obrigatório
			_aMsgErro	- Array onde consta os erros caso ocorra na leitura se o mesmo existir deve ser mandado como referência para retornar preenchido não é obrigatório
@obs 		Chamado pelo PE MATI681CRG
/*/
//-------------------------------------------------------------------

Static Function ZPCF009IDM(_oXml,_aMsgErro)
Local _cIdMes 	:= ""
Local _nPos
Local _cChave

Default _aMsgErro := {}

Begin Sequence
	//Não localizada a TAG
	If ValType(_oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key) == "U"
		Aadd(_aMsgErro,{"MT2681IMPMES01",OemToAnsi(STR0001)}) //Não possui possui TAG ID MES
		Break
	Endif
	//Caso seja do tipo Array
	If ValType(_oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key) == "A"  //nestes casos são reprocessamento
		For _nPos := 1 To Len(_oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key)
			If ValType(_oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key[_nPos]:Text) <> "U" .and. ;
			   ValType(_oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key[_nPos]:Text) == "C"
				_cChave := _oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key[_nPos]:Text
            	If !_cchave $ "true_false" .and. Len(_cchave) > 30
					_cIdMes := _cchave
					Exit
				Endif
			Endif
		Next
		//não localizou a formatação do tipo definida
		If Empty(_cIdMes)  
			Aadd(_aMsgErro,{"MT2681IMPMES28",OemToAnsi(STR0028)}) //Informações referente ao ID MES não conferem com a formatação definida  
		EndIf
		Break
	EndIf

	//Caso a mesma seja do tipo Texto
	If ValType(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text) <> "U" .and. ;
	   ValType(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text) == "C"  //nestes casos são reprocessamento
   		_cIdMes := AllTrim(_oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text)
		Break
	EndIf	
	//Se não entrou em nenhuma opção acima o problema esta no tipo de dado
	Aadd(_aMsgErro,{"MT2681IMPMES27",OemToAnsi(STR0027)}) //Tipo de dado não confere com a estrutura definida  
End Begin
Return _cIdMes



//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCF009MVP
Rdmake 		Localizar Veiculo ou produto na Movimentaçao   
@author 	DAC denilso.carvalho
@since 		03/08/2020
@version 	1.0
@param      _cIdMes, _cChassi, _cNumOp, _cCodProd, _cLocal
			_aMsgErro	- Array onde consta os erros caso ocorra na leitura se o mesmo existir deve ser mandado como referência para retornar preenchido 
@obs 		
/*/
//-------------------------------------------------------------------
Static Function ZPCF009MVP(_cIdMes, _cChassi, _cNumOp, _cCodProd, _cLocal, _aMsgErro)
Local _lRet 		:= .F.
Local _cAliasPesq   := GetNextAlias()

Default _aMsgErro 	:= {}
Default _cChassi	:= ""
Default _cNumOp 	:= ""
Default _cCodProd 	:= ""
Default	_cLocal		:= ""

Begin Sequence
	//Se vier vazio ocorreu alguma divergencia não validar
	If Empty(_cChassi) .or.  Empty(_cNumOp)  .or. Empty(_cCodProd)  .or. Empty(_cLocal)
		Break
	EndIf
	SD3->(DbSetOrder(1))   //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL                                                                                                                                 
    BeginSql Alias _cAliasPesq	
   	    SELECT 	ISNULL(SD3.R_E_C_N_O_,0) NREGSD3
	    FROM %Table:SD3%  SD3  
		WHERE 	SD3.D3_FILIAL 	= %xFilial:SD3%
			AND SD3.D3_OP  		= %Exp:_cNumOp%
			AND SD3.D3_COD  	= %Exp:_cCodProd%
			AND SD3.D3_LOCAL	= %Exp:_cLocal%
			AND SD3.D3_XCHASSI 	= %Exp:_cChassi%
			AND (SD3.D3_ESTORNO  = '' OR SD3.D3_ESTORNO = 'N')
		    AND SD3.%notDel% 
	EndSQL
	//Não achou o endereçamento
	If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGSD3 == 0
		Break
	EndIf
	Aadd(_aMsgErro,{"MT2681IMPMES29",OemToAnsi(STR0029)})	//Apontamento de Produção ja existente para este chassi
	_lRet := .T.
End Begin 
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCF009VEI
Rdmake 		Verificar se veirulo ou motor ja estao cadastrados   
@author 	DAC denilso.carvalho
@since 		03/08/2020
@version 	1.0
@param      _cChassi, _cCodMarca, cModVei, _cSegMod
			_aMsgErro	- Array onde consta os erros caso ocorra na leitura se o mesmo existir deve ser mandado como referência para retornar preenchido 
@obs 		
/*/
//-------------------------------------------------------------------

User Function ZPCF009VEI(_cChassi, _cNumMotor, _cCodMarca, cModVei, _cSegMod, _aMsgErro)
Local _lRet 		:= .F.
Local _cAliasPesq   := GetNextAlias()

Begin Sequence	
	//Verifico pelo indice se o veiculo existe
	VV1->(DbSetOrder(2))	//VV1_FILIAL+VV1_CHASSI
	If VV1->(DbSeek(xFilial('VV1')+_cChassi))
		AAdd(_aMsgErro,{"MT2681IMPMES30",OemToAnsi(STR0030)})  //Veículo  já cadastrado com este numero de Chassi, será importado mas não atualizara endereço e saldos de Veículos para a importação MES 
		_lRet := .T.  //indicar que não localizou
	EndIf
	//Necessário fazer select para verificar numero de motor não tem indice
	VV1->(DbSetOrder(10))	//VV1_FILIAL+VV1_CODMAR+VV1_MODVEI+VV1_SEGMOD                                                                                                                     
    BeginSql Alias _cAliasPesq	
   	    SELECT 	ISNULL(VV1.R_E_C_N_O_,0) NREGVV1
	    FROM %Table:VV1%  VV1  
		WHERE 	VV1.VV1_FILIAL 	= %xFilial:VV1%
			AND VV1.VV1_CODMAR	= %Exp:_cCodMarca%
			AND VV1.VV1_NUMMOT 	= %Exp:_cNumMotor%
		    AND VV1.%notDel% 
	EndSQL
	//Não achou o endereçamento
	If (_cAliasPesq)->(!Eof()) .or. (_cAliasPesq)->NREGVV1 > 0
		Aadd(_aMsgErro,{"MT2681IMPMES31",OemToAnsi(STR0031)+" - "+_cNumMotor})	//Apontamento de Produção ja existente para este motor cadastrado, será importado mas não atualizara endereço e saldos de Veículos para a importação MES
		_lRet := .T.  //indicar que não localizou
	EndIf
End Begin 
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCF9GRVZZ
Rdmake 		Gravar movimentação em tabela customizada SZZ onde será processado posteriormente   
@author 	DAC denilso.carvalho
@since 		30/10/2020
@version 	1.0
@param      Nil
@obs 		Gravar dados em arquivo customizado para posterior procesamento	
/*/
//-------------------------------------------------------------------

Static Function ZPCF9GRVZZ(_cIdMes, _cChassi, _cAnoFab, _cNumMotor, _cNumOp, _cCodProd, _nQtdeProd, _cLocal, _cPT, _cMaquina,_lEstorno)
Local _cMens   		:= "ZPCF9GRVZZ CAOA GRAVADO DADOS PARA IMPORTACAO MES"
Local _cEtapaPrd	:= ""

Default _cChassi	:= ""
Default _cAnoFab	:= ""
Default	_cNumMotor	:= ""
Default _cCodProd	:= ""
Default _nQtdeProd  := 0
Default _cLocal		:= ""
Default _cPT		:= "P"
Default _cMaquina 	:= ""
Default _lEstorno   := .F.

Begin Sequence
	//1- Verificar possibilidade de indicar a origem do apontamento ex. Body, Trm, paint, veiculo
	//   organizar por etapa verificar com o Nathã
	//2 incluir campo novo para mensagens erro ou acerto
	//3 Incluir campo novo referenciar agrupamento (NUNSEQ Da D3)
    //4 data e hora fim de apontamento
	//localizar o codigo sequencia PCP Etapa de Produção
	If Alltrim(_cCodProd) <> AllTrim(SB1->B1_COD)
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(Xfilial("SB1")+SZZ->ZZ_PRODUTO))
		_cEtapaPrd := SB1->B1_XPCPSEQ
	Else
		_cEtapaPrd := SB1->B1_XPCPSEQ
	EndIf		
	
    //Body SD4 (empenho)
	//Possibiblitar fechar de acordo com a reserva e saldo
   	RecLock("SZZ", .T.)
	SZZ->ZZ_FILIAL	:= XFilial("SZZ")	
	SZZ->ZZ_OP		:= _cNumOp	
	SZZ->ZZ_PRODUTO	:= _cCodProd	
	SZZ->ZZ_LOCAL	:= _cLocal
	SZZ->ZZ_QTDEPRD	:= _nQtdeProd	
	SZZ->ZZ_CHASSI	:= _cChassi 
	SZZ->ZZ_NUMMOT	:= _cNumMotor
	SZZ->ZZ_FABMOD	:= _cAnoFab
	SZZ->ZZ_OBSPRC  := _cMens
	SZZ->ZZ_TP      := _cPT
	SZZ->ZZ_RECURSO	:= _cMaquina
	SZZ->ZZ_ETAPAPD := _cEtapaPrd
	SZZ->ZZ_TPAPONT	:= If( _lEstorno,"E","A")
	SZZ->ZZ_DTINTEG	:= Date()
	SZZ->ZZ_HRINTEG	:= Substr(Time(),1,5)
	SZZ->ZZ_USUINTE	:= RetCodUsr() 
	//SZZ->ZZ_DTAPONT	
	//SZZ->ZZ_HRAPONT	
	//SZZ->ZZ_USUAPON			
	SZZ->ZZ_STATUS	:= ""		 ////" "=AGUARDANDO;"A"=APONTAMENTO;"E"=ERRO
	SZZ->ZZ_IDMES	:= _cIdMes
	//SZZ->ZZ_NSEQD3	
	//SZZ->ZZ_XML		:= _cXml	
	SZZ->(MsUnlock())
End Sequence
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCF009ZIM
Rdmake 		Localizar na tabela SZZ se existes dados com mesmo IDMES   
@author 	DAC denilso.carvalho
@since 		03/08/2020
@version 	1.0
@param      _cIdMes			
@return    	Lógico = _lRet
@obs 		
/*/
//-------------------------------------------------------------------
Static Function ZPCF009ZIM(_cIdMes)
Local _lRet 		:= .T.
Local _cAliasPesq   := GetNextAlias()
Local _cNoStatus	:= "D"  //Não procurar por status diferente de deletado
Begin Sequence
	SZZ->(DbSetOrder(3))   //ZZ_IDMES+ZZ_STATUS                                                                                                                                 
    BeginSql Alias _cAliasPesq	
   	    SELECT 	ISNULL(SZZ.R_E_C_N_O_,0) NREGSZZ
	    FROM %Table:SZZ%  SZZ  
		WHERE 	SZZ.ZZ_FILIAL 	= %xFilial:SZZ%
			AND SZZ.ZZ_IDMES    = %Exp:_cIdMes%
			AND SZZ.ZZ_STATUS  <> %Exp:_cNoStatus%
		    AND SZZ.%notDel% 
	EndSQL
	//Não achou o endereçamento
	If (_cAliasPesq)->NREGSZZ > 0
		Break
	EndIf
	_lRet := .F.
End Begin 
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCF009VZZ
Rdmake 		Localizar na tabela SZZ se existes dados referente a OP e retornar a quantidade   
@author 	DAC denilso.carvalho
@since 		03/08/2020
@version 	1.0
@param      _cNumOp			
@return    	Numerico = _nRet
@obs 		
/*/
//-------------------------------------------------------------------
Static Function ZPCF009LZZ(_cNumOp)
Local _nRet 		:= 0
Local _cAliasPesq   := GetNextAlias()
Local _cNoStatus	:= " 'D','A' "  //Não procurar por status diferente de deletado

Begin Sequence

	_cNoStatus := "%"+_cNoStatus+"%"

	SZZ->(DbSetOrder(1))   //ZZ_FILIAL+ZZ_OP+ZZ_PRODUTO                                                                                                                                 
    BeginSql Alias _cAliasPesq	
   	    SELECT 	SUM(SZZ.ZZ_QTDEPRD) NQTDESZZ
	    FROM %Table:SZZ%  SZZ  
		WHERE 	SZZ.ZZ_FILIAL 	= %xFilial:SZZ%
			AND SZZ.ZZ_OP    	= %Exp:_cNumOp%
			AND SZZ.ZZ_STATUS	NOT IN ( %Exp:_cNoStatus% )
		    AND SZZ.%notDel% 
	EndSQL
	//achou o endereçamento
	If (_cAliasPesq)->(!EOF()) .and. (_cAliasPesq)->NQTDESZZ > 0
		_nRet := (_cAliasPesq)->NQTDESZZ
		Break
	EndIf
End Begin 
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _nRet


//////////////////////////////////////////////
//somente para realizar testes de validação
/////////////////////////////////////////////

User Function XXXIMXML()
Local _cArqXml  := "c:\temp\MES\XMLMES.xml"
Local _cError	:= ""
Local _cWarning := ""
Private cXml

Private _oXml
//_cVarXML := FLerXML(_cArqXml)
//_oXml  := XmlParserFile( _cArqXml, "_", @_cError, @_cWarning )
cXml := EncodeUTF8(FLerXML(_cArqXml))
//Retira tabulação e quebras de linha.
cXml := StrTran(cXml, CHR(10), " " )
cXml := StrTran(cXml, CHR(13), " " )
cXml := StrTran(cXml, CHR(9), " " )
cXml := AllTrim(cXml)
//Realiza o Parse do XML recebido.
oXml := XmlParser(cXml , "_", @_cError, @_cWarning )

If !Empty(_cError) //.or. 	VALTYPE( XmlChildEx(_oXml, "_TotvsMessage") ) == "U"  
	//If ValType(oXMl) <> "O"
	MSGInfo(_cError,"ATENCAO")
	MSGInfo( _cWarning,"ATENCAO")
Else
	//U_MATI681CRG()
	ZPCPF009VL()
Endif

Return Nil


Static Function FLerXML(cArquivo)
Local cXML	:=""
Default cArquivo:=""
Begin Sequence
	If File(cArquivo)
		FT_FUSE(cArquivo)
		FT_FGOTOP()
		//-- Leitura do Arquivo
		Do While !FT_FEOF()          
			cXML += FT_FREADLN()
			FT_FSKIP()
		End
		//--Fecha o arquivo
		FT_FUSE()
	Endif
End Begin
Return cXML



