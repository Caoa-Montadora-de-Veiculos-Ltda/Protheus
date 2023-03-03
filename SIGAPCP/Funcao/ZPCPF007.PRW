#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#Include 'FWMVCDef.ch'
#Include "FWBROWSE.CH"   
#include "ZPCPF007.ch"
          
/*---------------------------------------------------------------------------------------
{Protheus.doc} ZPCPF007
Rdmake 	Função chamada Ponto de Entrada SD3250I após apontamento de op, para geracao de VV1 de apontamento CPS                                 |
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
@history    Fonte remanejado o mesmo foi inicialmente montado por Wilker Marçal  17/12/19
			Este programa tem por base a importação do MES
			DAC - DENILSO 11/11/2020
			Ajustes para Backflush versão 3 os controles não serão realizados ais pelo PE SD3250I pois as OPs poderão ser agrupadas gerando um unico movimento com vários veiculos novos

/*/
Static  _lBKF681 := .T.

User Function ZPCPF007(_lJob)
Local _aArea 		:= GetArea()
Local _aMens		:= {}
Local _lRet			:= .T.
Local _lZPCPF007 	:= SuperGetMV( "CMV_PCP001"  ,,.T.)  			//parametro para habilitar/desabilitar funcionalidade
Local _cLocPad		:= AllTrim(SuperGetMV( "CMV_PCP003"  ,,'VN'))  	//parametro Local padrão para veiculos novos
Local _cGrpProd		:= AllTrim(SuperGetMV( "CMV_PCP004"  ,,'VEIA')) //parametro Grupo de produtos padrão para veiculos novos
Local _cNumMotor	:= SZZ->ZZ_NUMMOT
Local _cTexto		:= ""
Local _lAchouVeic   := .F.
Local _nPos

Private _aRet		:= {}
Private _cIDMES		:= ""
Private _cChassi	:= SZZ->ZZ_CHASSI

Default _lJob   	:= .T.  //Deixar como default Verdadeiro

Aadd(_aRet,{"IDMESINT000","Acesso ZPCPF007 PE SD3250I "+DtoC(Date())+" - "+Time()})   
ConOut("ZPCPF007 - Acessou Backflush 3.0  "+DTOC(Date()) + " - " + Time())

If !_lZPCPF007
	ConOut("ZPCPF007 - Falta parametrizacao CMV_PCP001 "+DTOC(Date()) + " - " + Time())
	Return
Endif

//Verifica chamado pela integração do MES
If FWIsInCallStack("MATI681")
	_lBKF681 := .T.
Else
	_lBKF681 := .F.
Endif

//localizar o produto
SB1->(DbSetOrder(1))  //B1_FILIAL+B1_COD
If SB1->(!MSSeek(XFilial("SB1") + SD3->D3_COD))
	Aadd(_aMens,{"IDMESINT003",OemToAnsi(STR0003)})  //Veículo não localizado no cadastro de Produtos
	EnviaMsg(_aMens)
	Return(.F.)
EndIf

//Posicionar Ordens de Produção            
SC2->(dbSetOrder(1))  //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
If !SC2->(DbSeek(xFilial('SC2')+SD3->D3_OP))
	Aadd(_aMens,{"IDMESINT002",OemToAnsi(STR0002)})   //Não localizada Ordem de Produção, o processo será realizado a mensagem é informativa
	EnviaMsg(_aMens)
	Return(.F.)
Endif

//para validar deve estar posicionado H6
If _lBKF681  //Chamada SH6  
    //Verifica se possui a informação do MES
	_nPos := At("TOTVSMES",SD3->D3_OBSERVA)
	If _nPos == 0
		EnviaMsg(_aMens)
		Return(.F.)
	EndIf	
EndIf

If SZZ->ZZ_OP <> SD3->D3_OP
	Aadd(_aMens,{"IDMESINT001",OemToAnsi(STR0001)+" "+SZZ->ZZ_OP})   //Não esta posicionado tabela SH6 em relação a movimentação interna
	EnviaMsg(_aMens)
	Return(.F.)
Endif
	
If SD3->D3_COD <> SZZ->ZZ_PRODUTO
	Aadd(_aMens,{"IDMESINT001",OemToAnsi("Produto tab temporaria "+SZZ->ZZ_PRODUTO+" diferente do movimento "+SD3->D3_COD)})   
	EnviaMsg(_aMens)
	Return(.F.)
Endif

_cTexto := ""
If SD3->D3_CF  == "PR0"   
	RecLock( "SD3", .F.)
	If  SD3->(FieldPos("D3_XCHASSI")) > 0
		SD3->D3_XCHASSI := AllTrim(SZZ->ZZ_CHASSI)
	EndIf
	If  SD3->(FieldPos("D3_XIDMES ")) > 0
		SD3->D3_XIDMES  := AllTrim(SZZ->ZZ_IDMES) 
	EndIf

	SD3->D3_OBSERVA := AllTrim(SD3->D3_OBSERVA)+" - EXECUTADO PELO ZPCPJ001" //_cTexto
	SD3->(MsUnlocK())
EndIf

//Neste Caso não deverá passar pelo processo o mesmo não faz referencia ao local e grupo do veiculo novo 
If AllTrim(SD3->D3_LOCAL) <> _cLocPad .or. AllTrim(SD3->D3_GRUPO) <> _cGrpProd
	EnviaMsg(_aMens)
	Return(.F.)
EndIf

//Acrescentado validação do emprestimo veiculo pelo Backflush 3.0  DAC 03/02/2021
//Se for Status de emprestimo não deverá gravar veiculo, movimentação 
If SZZ->ZZ_STATUS == "L"
	EnviaMsg(_aMens)
	Return(.F.)
EndIf

//Validar se vem preenchido chassi e motor
If Empty(SZZ->ZZ_CHASSI) .or. Empty(SZZ->ZZ_NUMMOT)
	Aadd(_aMens,{"IDMESINT012",OemToAnsi(STR0012)})   //Informações de Chassi e Motor não estão completas verificar, o processo será realizado a mensagem é informativa
	EnviaMsg(_aMens)
	Return(.F.)
EndIf

//localizar a Marca
VV2->(DbSetOrder(7))  //VV2_FILIAL+VV2_PRODUT
VV2->(DbSeek(xFilial('VV2')+SB1->B1_COD))
//Verificar se o veiculo esta cadastrado
// retirar/Substituir StaticCall ->degrada 
//_lAchouVeic := StaticCall(ZPCPF009,ZPCF009VEI,_cChassi, _cNumMotor, VV2->VV2_CODMAR, VV2->VV2_MODVEI, VV2->VV2_SEGMOD, @_aMens)
_lAchouVeic := U_ZPCF009VEI(_cChassi, _cNumMotor, VV2->VV2_CODMAR, VV2->VV2_MODVEI, VV2->VV2_SEGMOD, @_aMens)
	
If _lAchouVeic
	EnviaMsg(_aMens)
	Return(.F.)
Endif

//Gravar Veículo e atualizar saldo do mesmo
If _lJob
	_lRet := ZPCPF07GRV(_lJob,@_aMens)
Else
	Processa({|| _lRet := ZPCPF07GRV(_lJob,@_aMens) },OemToAnsi(STR0099))   //Processando cadastro do veiculo...
Endif

EnviaMsg(_aMens)
RestArea(_aArea)

Return _lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EnviaMsg
Envio de Mensagem
@author Leonardo Miranda
@since 17/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnviaMsg(_aMens)

Local _lRet := .T.
Local _nPos := 1

Aadd(_aRet,{"IDMESINT000","Termino ZPCPF007 PE SD3250I "+DtoC(Date())+" - "+Time()})   
//providenciar envio de e-mail
If Len(_aMens)	> 0
	//Guardar hora inicial e final
	For _nPos := 1 To Len(_aRet)
		Aadd(_aMens,_aRet[_nPos])
	Next	
	//Envia Email
	U_ZPCPF07EM(_aMens, /*_aChave*/, /*_cAssunto*/, /*_cEmails*/, /*_cEMailCopia*/, /*_aAnexos*/, _cIDMES, _cChassi ,/*_cRotina*/, /*lSchedule*/)
	_lRet := .F.
EndIf

Return(_lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCPF07GRV
Endereçamento Automatico chassi   
@author DAC denilso.carvalho
@since 20/06/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ZPCPF07GRV(_lJob,_aMens)
Local _lRet		:= .T.
Local _aArea 	:= GetArea()

//Garanto o posicionamento dos registros
Local _nRegVV2	:= VV2->(Recno())
Local _nRegSB1	:= SB1->(Recno())
Local _nRegSC2	:= SC2->(Recno())
Local _nRegSC3	:= SD3->(Recno())
Local _nRegSH6	:= SH6->(Recno())

//Cria Veículo e atualiza relacionamento do mesmo
_lRet := ZPCPF07XVEI(_lJob, _nRegVV2, _nRegSB1, _nRegSC2, _nRegSC3, @_aMens)

//Atualizar endereçamento
If _lRet  //Não fara o endereçamento se não criou o veículo
	_lRet := ZPCPF07GSL(_lJob ,_nRegSB1 ,_nRegSH6 , _nRegSC3, @_aMens)
EndIf	

RestArea(_aArea)

Return _lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCPF07XVEI
Inclusão do Cadastro de Veículos   
@author DAC denilso.carvalho
@since 04/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ZPCPF07XVEI(_lJob, _nRegVV2, _nRegSB1, _nRegSC2, _nRegSD3, _aMens)

Local _aCab 		:= {}
Local _aSM0			:= {}
Local _aError		:= {}
Local _lRet 		:= .F. 
Local _cChassi		:= ""
Local _cChaInt 		:= ""
Local _cTexto		:= ""
Local _nRegVV1		:= 0
Local _cPropAtu		:= SuperGetMV( "CMV_VEI011"  ,,"000373")  //000373 Proprietario Atual  NAO CADASTRADO 
Local _cPropLjAtu	:= SuperGetMV( "CMV_VEI012"  ,,"01")
Local _cFunNameAnt 	:= FunName()
Local _nModuloAnt  	:= nModulo

Default _aMens		:= {}

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

Private oModel  := FWLoadModel('VEIA070')
Private aRotina := FWLoadMenuDef('VEIA070')

//Posicionar informações
VV2->(DbGoto(_nRegVV2))
SB1->(DbGoto(_nRegSB1))
SC2->(DbGoto(_nRegSC2))
SD3->(DbGoto(_nRegSD3))
//Necessário mudar o módulo caso não faça ocorrera errolog perderá no acols para execauto VEIXX000
nModulo 	:= 11
_cChassi	:= Upper(SD3->D3_XCHASSI)

Private M->VV1_CHASSI :=  _cChassi  //Upper(SH6->H6_XCHASSI) //Necessario fazer isto pois existe validação no TO do Padrão e o mesmo não tem as variaveis de memoria carregadas causando errolog DAC-09/07/2020

_aSM0 		:= FWArrFilAtu(cEmpAnt,cFilAnt)
_cChaInt 	:= GETSXENUM("VV1","VV1_CHAINT")
//Caso ja esteja cadastrado o Veiculo
VV1->(DbSetOrder(2))	//VV1_FILIAL+VV1_CHASSI
If VV1->(DbSeek(xFilial('VV1')+_cChassi))
	AAdd(_aMens,{"IDMESINT011",OemToAnsi(STR0011)})  //Veículo  já cadastrado, não serão gravados dados na impostação !
	//Break
	RETURN .F.
EndIf

CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Trace002 - Inicio - Criacao VV1 - ZPCPF007 - IDMES: "+Alltrim(SZZ->ZZ_IDMES)+ If(!Empty(SZZ->ZZ_CHASSI)," Chassi: "+AllTrim(SZZ->ZZ_CHASSI)+".","."))

Aadd(_aCab,{"VV1_CODMAR" ,VV2->VV2_CODMAR				 ,Nil})
Aadd(_aCab,{"VV1_CHAINT" ,_cChaInt						 ,Nil})
Aadd(_aCab,{"VV1_CHASSI" ,_cChassi						 ,Nil}) //Upper(SH6->H6_XCHASSI)
Aadd(_aCab,{"VV1_MODVEI" ,VV2->VV2_MODVEI				 ,Nil})
Aadd(_aCab,{"VV1_SEGMOD" ,VV2->VV2_SEGMOD				 ,Nil})
Aadd(_aCab,{"VV1_FABMOD" ,SZZ->ZZ_FABMOD				 ,Nil})
Aadd(_aCab,{"VV1_CARROC" ,""							 ,Nil})
Aadd(_aCab,{"VV1_CORVEI" ,VV2->VV2_COREXT				 ,Nil})
Aadd(_aCab,{"VV1_COMVEI" ,VV2->VV2_COMVEI				 ,Nil})
Aadd(_aCab,{"VV1_CORVEI" ,VV2->VV2_COREXT				 ,Nil})
Aadd(_aCab,{"VV1_CODORI" ,"0"							 ,Nil})	//Origem			= Fabrica
Aadd(_aCab,{"VV1_PROVEI" ,"0"							 ,Nil})	//Procedencia 		= Nacional
Aadd(_aCab,{"VV1_ESTVEI" ,"0"							 ,Nil})	//Estado do Veículo = Novo
Aadd(_aCab,{"VV1_INDCAL" ,"0"							 ,Nil})	//Ind Calculo 		= Nacional
Aadd(_aCab,{"VV1_VEIACO" ,"0"							 ,Nil})	//Acordo/Contr		= Veiculo NAO pertencente a Contrato
Aadd(_aCab,{"VV1_LOCPAD" ,SB1->B1_LOCPAD				 ,Nil})
Aadd(_aCab,{"VV1_PROATU" ,_cPropAtu						 ,Nil})	//Proprietario Atual
Aadd(_aCab,{"VV1_LJPATU" ,_cPropLjAtu					 ,Nil})	//Loja Proprietario
Aadd(_aCab,{"VV1_TIPVEI" ,"1"							 ,Nil})	//Tipo Veiculo		= Normal
Aadd(_aCab,{"VV1_SITVEI" ,"0"							 ,Nil})	//Situacao    		= Estoque
Aadd(_aCab,{"VV1_POSIPI" ,SB1->B1_POSIPI				 ,Nil})
Aadd(_aCab,{"VV1_NUMMOT" ,Upper(SZZ->ZZ_NUMMOT )		 ,Nil})
Aadd(_aCab,{"VV1_GRTRIB" ,SB1->B1_GRTRIB				 ,Nil})
Aadd(_aCab,{"VV1_CHARED" ,""							 ,Nil})	//Chassi Reduz
Aadd(_aCab,{"VV1_PESLIQ" ,0								 ,Nil})	//Peso Liquido
Aadd(_aCab,{"VV1_PESBRU" ,SB1->B1_PESBRU				 ,Nil})		
Aadd(_aCab,{"VV1_SERMOT" ,Alltrim(Substr(_cChassi,10,8)) ,Nil})	//Numero de Serie do Motor 
Aadd(_aCab,{"VV1_FILENT" ,xFilial("VV1")				 ,Nil})
Aadd(_aCab,{"VV1_ULTMOV" ,"E"							 ,Nil})	//Ultima Movimentacao    
Aadd(_aCab,{"VV1_TRANSM" ,"0"							 ,Nil})	//Transmitido?		= Não
Aadd(_aCab,{"VV1_IMOBI"  ,"0"							 ,Nil})	//Imobilizado 		= Não Ativo
Aadd(_aCab,{"VV1_CHARED" ,SUBSTR(_cChassi,10,7)			 ,Nil})	//Chassis Reducido
Aadd(_aCab,{"VV1_DOCIND" ,_aSM0[SM0_CGC]				 ,Nil})	//Docto Identificacao  
If VV1->(FieldPos("VV1_XIDMES")) > 0
	Aadd(_aCab,{"VV1_XIDMES",	SZZ->ZZ_IDMES	, nil})	//Docto Identificacao  
EndIf

lMsErroAuto 	:= .F.
lAutoErrNoFile 	:= .T.
FWMVCRotAuto(oModel					,; //Model
			 "VV1"					,; //Alias
			 MODEL_OPERATION_INSERT	,; //Operacao
			 {{'MODEL_VV1', _aCab}})

If lMsErroAuto            
	_aError   := oModel:GetErrorMessage()
	cErro +=  "Id do formulário de origem:" + ' [' + AllToChar( _aError[1]  ) + ']'+CRLF 
	cErro +=  "Id do campo de origem:     " + ' [' + AllToChar( _aError[2]  ) + ']'+CRLF
	cErro +=  "Id do formulário de erro:  " + ' [' + AllToChar( _aError[3]  ) + ']'+CRLF
	cErro +=  "Id do campo de erro:       " + ' [' + AllToChar( _aError[4]  ) + ']'+CRLF
	cErro +=  "Id do erro:                " + ' [' + AllToChar( _aError[5]  ) + ']'+CRLF
	cErro +=  "Mensagem do erro:          " + ' [' + AllToChar( _aError[6]  ) + ']'+CRLF
	cErro +=  "Mensagem da solução:       " + ' [' + AllToChar( _aError[7]  ) + ']'+CRLF
	cErro +=  "Valor atribuido:           " + ' [' + AllToChar( _aError[8]  ) + ']'+CRLF
	cErro +=  "Valor anterior:            " + ' [' + AllToChar( _aError[9]  ) + ']'+CRLF

	_cTexto := OemToAnsi(STR0008)+CHR(13)+CHR(10)
	_cTexto += cErro
	Aadd(_aMens,{"IDMESINT008",cErro})		
	EnviaMsg(_aMens)
	Return(.F.)
Endif

CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Trace002 - FIM - Criacao VV1 - ZPCPF007 - IDMES: "+Alltrim(SZZ->ZZ_IDMES)+ If(!Empty(SZZ->ZZ_CHASSI)," Chassi: "+AllTrim(SZZ->ZZ_CHASSI)+".","."))
	
_nRegVV1 := VV1->(Recno())

If !ZPCPF07MVE(_lJob, _nRegVV1, _nRegSD3, _aSM0, @_aMens)
	Return()
EndIf

If VV1->(FieldPos("VV1_XNUMSE")) > 0
   	RecLock("VV1", .F.)
	VV1->VV1_XNUMSE  :=  SD3->D3_NUMSEQ		//Numero Sequencia SD3
	VV1->(MsUnlock())
EndIf

_lRet := .T.
SetFunName(_cFunNameAnt)
nModulo := _nModuloAnt

Return _lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCPF07MVE
Cria entrada de veiculos no sigavei Movimentos   
@author DAC denilso.carvalho
@since 04/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ZPCPF07MVE(_lJob, _nRegVV1, _nRegSD3, _aSM0, _aMens)
Local _cForPgto 	:= AllTrim(SuperGetMV("MV_XFORPAG", .T., "001"))
Local _cTES 		:= AllTrim(SuperGetMV("MV_XCODTES", .T., "001"))
Local _nPeriodo 	:= SuperGetMV( "CMV_VEI010"  ,,3500)  //Quantidade de dias correspondente ao bloqueio de veiculos
Local _cMotivo		:= "PRODUCAO"
Local _lRet 		:= .F.
Local _aCab			:= {}
Local _aItCol		:= {}
Local _aItens		:= {}
Local _aError		:= {}
Local _cCodFor  	:= ""
Local _cLojFor      := ""
Local _cTexto		:= ""
Local _nCusFut      := 0
Local _cCnpjFor		:= _aSM0[SM0_CGC]
Local _nPos
Local _cValidaSB2 	

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

_cValidaSB2 	:= SuperGetMV("MV_XVLDSB2",.F.,"0")  //1=Valida B2_VATU1,2=Alerta B2_VATU1

//Ja esta posicionado no SD3, SB1, VV1
//localizar Fornecedor
SA2->(DbSetOrder(3))	//A2_FILIAL+A2_CGC
If SA2->(DbSeek(xFilial("SA2")+_cCnpjFor)) .or. SA2->(DbSeek(xFilial("SA2")+left(_cCnpjFor,8)))
	_cCodFor := SA2->A2_COD
	_cLojFor := SA2->A2_LOJA
Else
	Aadd(_aMens,{"IDMESINT021",OemToAnsi(STR0021)+" - "+_cCnpjFor+"/"+_aSM0[SM0_CGC]})  //Não encontrado fornecedor para o CNPJ 
EndIf

_nCusFut := U_ZGENCST(SD3->D3_COD, SD3->D3_LOCAL, SZZ->ZZ_FABMOD , /*lMostramsg*/)  //Verifica em varias tabelas o custo para o veiculo programa ZGENCST
If _nCusFut == 0	
	_nCusFut := 1  //verificar se deixara assumindo custo 1
EndIf

CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Trace003 - Inicio - Criacao VVG E VVF - ZPCPF007 - IDMES: "+Alltrim(SZZ->ZZ_IDMES)+ If(!Empty(SZZ->ZZ_CHASSI)," Chassi: "+AllTrim(SZZ->ZZ_CHASSI)+".","."))

//adicionar dados para execauto
_aCab := {}
aAdd(_aCab,{"VVF_FORPRO"  , "0"   		 	,Nil})
aAdd(_aCab,{"VVF_CLIFOR"  , "F"   		 	,Nil})
aAdd(_aCab,{"VVF_CODFOR"  , _cCodFor		,Nil})
aAdd(_aCab,{"VVF_LOJA "   , _cLojFor		,Nil})
aAdd(_aCab,{"VVF_DATEMI"  , dDataBase	 	,Nil})            
aAdd(_aCab,{"VVF_DOCSD3"  , SD3->D3_DOC	 	,Nil})
aAdd(_aCab,{"VVF_FORPAG"  , _cForPgto	 	,Nil})
aAdd(_aCab,{"VVF_NUMFI"   , SD3->D3_DOC	 	,Nil})
aAdd(_aCab,{"VVF_SERIE"   , SD3->D3_CF	 	,Nil})

_aItens := {} // Campos Itens
_aItCol := {}
aAdd(_aItCol,{"VVG_CHASSI"  , VV1->VV1_CHASSI ,Nil})
aAdd(_aItCol,{"VVG_CHAINT"  , VV1->VV1_CHAINT ,Nil})
aAdd(_aItCol,{"VVG_ESTVEI"  , VV1->VV1_ESTVEI ,Nil})
aAdd(_aItCol,{"VVG_CODORI"  , VV1->VV1_CODORI ,Nil})
aAdd(_aItCol,{"VVG_CODTES"  , _cTES		 	  ,Nil})
aAdd(_aItCol,{"VVG_SITTRI"  , '0'			  ,Nil})
aAdd(_aItCol,{"VVG_VALUNI"  , _nCusFut		  ,Nil})
//VVG_CF  cODIGO FISCAL 1949     
aAdd(_aItens,aClone(_aItCol))

FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT)  //Posiciona Grupo de Veiculo
	
//Aadd(_aMens,{"IDMESINT000","ExecAuto VEIXX000 VV1 "+Str(_nRegVV1)+" "+DtoC(Date())+" - "+Time()})  
SetFunName('VEIXA001')
lMsErroAuto 	:= .F.
lAutoErrNoFile 	:= .T.
MsExecAuto(	{|a,b,c,d,e,f,g,h,i| VEIXX000(a,b,c,d,e,f,g,h,i) },_aCab ,_aItens ,{} ,3 ,"0" , ,.F. , ,"4")
If lMsErroAuto            
	_aError := GetAutoGRLog()
	_cTexto := OemToAnsi(STR0010)+CHR(13)+CHR(10)  //Erro ExecAuto VEIXA000, não gravado Movimento de Veículo chamado pelo PE MT681INC
	For _nPos := 1 To Len(_aError)	
		_cTexto	+= 	_aError[_nPos]+CHR(13)+CHR(10)	
	Next _nPos			
	Aadd(_aMens,{"IDMESINT010",_cTexto})
	EnviaMsg(_aMens)
	Return(.F.)		
Endif

CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Trace003 - FIM - Criacao VVG E VVF - ZPCPF007 - IDMES: "+Alltrim(SZZ->ZZ_IDMES)+ If(!Empty(SZZ->ZZ_CHASSI)," Chassi: "+AllTrim(SZZ->ZZ_CHASSI)+".","."))

//Bloqueia Veículo
CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Trace004 - Inicio - Criacao VB0 - Bloq. Veiculo - ZPCPF007 - IDMES: "+Alltrim(SZZ->ZZ_IDMES)+ If(!Empty(SZZ->ZZ_CHASSI)," Chassi: "+AllTrim(SZZ->ZZ_CHASSI)+".","."))

RecLock("VB0", .T.)
VB0->VB0_FILIAL := xFilial("VB0")
VB0->VB0_CHAINT := VV1->VV1_CHAINT
VB0->VB0_DATBLO := Date()
VB0->VB0_HORBLO := val(left(time(), 2) + substr(time(), 4, 2))
VB0->VB0_USUBLO := __CUSERID
VB0->VB0_MOTBLO := _cMotivo
VB0->VB0_DATVAL := (Date() + _nPeriodo)
VB0->VB0_HORVAL := val(left(time(), 2) + substr(time(), 4, 2))
VB0->(MsUnlock())
//Aadd(_aMens,{"IDMESINT000","Gravou Bloqueio Veiculo"})  
_lRet := .T.

CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Trace004 - FIM - Criacao VB0 - Bloq. Veiculo - ZPCPF007 - IDMES: "+Alltrim(SZZ->ZZ_IDMES)+ If(!Empty(SZZ->ZZ_CHASSI)," Chassi: "+AllTrim(SZZ->ZZ_CHASSI)+".","."))

Return _lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCPF07GSL
Atualizazr Endereçamento   
@author DAC denilso.carvalho
@since 20/06/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ZPCPF07GSL(_lJob ,_nRegSB1 ,_nRegSH6 ,_nRegSD3 ,_aMens)
Local _cAliasPesq   := GetNextAlias()
Local _lRet			:= .T.
Local _aCab 		:= {}
Local _aItens		:= {}
Local _aItCol		:= {}
Local _aError		:= {}
Local _cProduto		:= ""
Local _cNumSeq		:= ""
Local _cChassi		:= ""
Local _cLocPad		:= ""  //	cEnderec:= SD3->D3_LOCALIZ
Local _cEnder 		:= GetMv("CMV_PCP05C",.F.,"VEICULO NOVO")
Local _cTexto		:= ""
Local _nCount 		:= 0
Local aArea			:= GetArea()
Local _nPos
Local aBind     	:= {} //As array

Static cQuery    	:= ''

Private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
Private lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog

SB1->(DbGoto(_nRegSB1))
SD3->(DbGoto(_nRegSD3))
SetFunName("MATA681")

_cProduto	:= SD3->D3_COD
_cNumSeq	:= SD3->D3_NUMSEQ
_cChassi	:= Upper(SD3->D3_XCHASSI)
_cLocPad	:= SB1->B1_LOCPAD  //	cEnderec:= SD3->D3_LOCALIZ

If Empty(_cNumSeq)
	Aadd(_aMens,{"IDMESINT020",OemToAnsi(STR0020)})  //Numero sequencia SD3 não preenchido, não sera atualizado Endereço (SDA)
	EnviaMsg(_aMens)
	Return(.F.)		
EndIf

//Ajustar Saldos
SDA->(DbSetOrder(1))  //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA

//Neste select esta pegando o código do produto para respeitar a ordem do indice anteriorente não pegava
//Validar com usuário se esta correto ou deverá atualizar SDA dos outros Saldos na mesma sequencia
//If cQuery == Nil
	cQuery := ""
	cQuery += " SELECT NVL(SDA.R_E_C_N_O_,0) NREGSDA		"
	cQuery += " FROM " + RetSqlName("SDA") + " SDA			"
	cQuery += " 	WHERE 	SDA.DA_FILIAL 	= ?				"
	cQuery += " 		AND SDA.DA_PRODUTO  = ?				"
	cQuery += " 		AND SDA.DA_LOCAL	= ?				"
	cQuery += " 		AND SDA.DA_NUMSEQ	= ?				"
	cQuery += " 		AND SDA.DA_SALDO 	> 0 			"
	cQuery += " 		AND SDA.DA_QTDORI	= SDA.DA_SALDO	"
	cQuery += " 	    AND SDA.D_E_L_E_T_	= ?				"
	cQuery += " 	ORDER BY SDA.DA_CLIFOR
//EndIf

Aadd(aBind,xFilial("SDA")	)
Aadd(aBind,_cProduto		)
Aadd(aBind,_cLocPad			)
Aadd(aBind,_cNumSeq			)
Aadd(aBind,Space(1)			)
DbUseArea(.T., "TOPCONN", TCGenQry2(Nil, Nil, cQuery, aBind), _cAliasPesq, .F., .T.)

//Não achou o endereçamento
If (_cAliasPesq)->(Eof())
	Aadd(_aMens,{"IDMESINT004",OemToAnsi(STR0004)})  //Não localizado endereço para endereçamento automático chassi
	_lRet	:= .F.
	EnviaMsg(_aMens)
	
	(_cAliasPesq)->(DbCloseArea())
	RestArea(aArea)

	aSize(aArea,0)
	aSize(aBind,0)

	aBind 	 := Nil
	aArea    := nil 

	Return(.F.)		
EndIf

While (_cAliasPesq)->(!Eof())

	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Trace005 - Inicio - Enderecamento Veiculo - ZPCPF007 - IDMES: "+Alltrim(SZZ->ZZ_IDMES)+ If(!Empty(SZZ->ZZ_CHASSI)," Chassi: "+AllTrim(SZZ->ZZ_CHASSI)+".","."))
		
	SDA->(DbGoto((_cAliasPesq)->NREGSDA))
	//SDA Saldos a Distribuir
	_aCab 	:= {}           
	_aItCol := {}
	_aItens	:= {}

	Aadd(_aCab,{"DA_FILIAL" , SDA->DA_FILIAL ,Nil})
	Aadd(_aCab,{"DA_PRODUTO", _cProduto		 ,Nil})
	Aadd(_aCab,{"DA_LOCAL"  , _cLocPad		 ,Nil})
	Aadd(_aCab,{"DA_DOC"    , SDA->DA_DOC	 ,Nil})
	Aadd(_aCab,{"DA_SERIE"  , SDA->DA_SERIE  ,Nil})
	Aadd(_aCab,{"DA_NUMSEQ" , _cNumSeq		 ,Nil})

	//SDB Movimentações Lote Custo FIFO 
	Aadd(_aItCol,{"DB_ITEM"   	, StrZero(1,Len(SDB->DB_ITEM))	, Nil})
	Aadd(_aItCol,{"DB_ESTORNO"  , CRIAVAR("DB_ESTORNO")  		, Nil})
	Aadd(_aItCol,{"DB_LOCALIZ"  , _cEnder            			, Nil})
	Aadd(_aItCol,{"DB_DATA"     , dDataBase	        			, Nil})
	Aadd(_aItCol,{"DB_QUANT"    , SDA->DA_SALDO    				, Nil})
	Aadd(_aItCol,{"DB_NUMSERI"  , _cChassi      		        , Nil})			
	Aadd(_aItens, Aclone(_aItCol))

	lMsErroAuto 	:= .F.
   	lAutoErrNoFile 	:= .T.
	_nCount ++
	MsExecAuto({|x,y,z|mata265(x,y,z)},_aCab,_aItens,3)
	If lMsErroAuto            
		_aError := GetAutoGRLog()
		_cTexto := OemToAnsi(STR0005)+" Ref. reg. SDA "+StrZero((_cAliasPesq)->NREGSDA,10)+CHR(13)+CHR(10)  //Erro ExecAuto MATA265
		For _nPos := 1 To Len(_aError)	
			_cTexto	+= 	_aError[_nPos]+CHR(13)+CHR(10)	
		Next _nPos			
		Aadd(_aMens,{"IDMESINT005",_cTexto})		
		//somente gerar mensagens do While pois deverá gravar o veículo mesmo não alterando o saldo
		_lRet := .F.
		//Exit
	EndIf

	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ001] Trace005 - FIM - Enderecamento Veiculo - ZPCPF007 - IDMES: "+Alltrim(SZZ->ZZ_IDMES)+ If(!Empty(SZZ->ZZ_CHASSI)," Chassi: "+AllTrim(SZZ->ZZ_CHASSI)+".","."))
		
	(_cAliasPesq)->(DbSkip())
EndDo

If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  


RestArea(aArea)

aSize(aArea,0)
aSize(aBind,0)

aBind 	 := Nil
aArea    := nil 

Return _lRet

/*
=====================================================================================
Programa.:              ZPCPF07EM
@param 					_aMens   	= Mensagens de erro 
						_aChave		= Campos relativos a pesquisa com seu conteudo se vazio pesquisara baseado na tabela posicionada
						_cAssunto   = Assunto do e-mail 
						_cEmails    = Destinatário do e-mail 
						_cEMailCopia= Destinatarios em cópia 
						_aAnexos 	= Localização e nome do arquivo anexo 
						_cRotina    = Rotina que chamou o processo
						lSchedule	= Esta rodando em job se verdadeiro não emitira msg em tela
Autor....:              CAOA - DAC Denilso 
Data.....:              10/07/2020
Descricao / Objetivo:   Funcao para processar o envio das notificacoes
Doc. Origem:            GAP COM027
Solicitante:            Compras
Uso......:              ZCOLF001
Obs......:

=====================================================================================
*/
User Function ZPCPF07EM(_aMens, _aChave, _cAssunto, _cEmails, _cEMailCopia, _aAnexos, _cIDMES, _cChassi , _cRotina, lSchedule)
Local _cTexto   		:= ""
Local _cEmailDest 		:= ""
Local _lMsgOK			:= .T.
Local _lMsgErro			:= .F.
Local _cObsMail			:= ""
Local _cReplyTo			:= ""
Local _cCorItem			:= "FFFFFF"
Local _lEnvia			:= .T.
Local _cLogo  			:= "lg_caoa.png"
Local _cNomeUsu 		:= Upper(FwGetUserName(RetCodUsr())) //Retorna o nome completo do usuário  __cUserId
Local _cCodUsu			:= RetCodUsr()
Local _cDescProd		:= ""
Local _cCodProd			:= SD3->D3_COD
Local _cNumOP			:= SD3->D3_OP
Local _cIDEnt			:= SD3->D3_IDENT
Local _nPos

Default _lSchedule   	:= .T.
Default _cAssunto		:= "Informações importação MES"
Default _cEmails 		:= AllTrim(SuperGetMV("CMV_PCP002",.F.,"evandro.mariano@caoa.com.br;nata.milhomem@caoamontadora.com.br;denilso.carvalho@caoa.com.br"))  //E-mail para envio problemas integração TOTVS x MES 
Default _aAnexos		:= {}
Default _aChave			:= {}
Default _cEMailCopia	:= ""
Default _cRotina		:= "ZPCPF07EM"
Default _cChassi		:= SD3->(FieldPos("D3_XCHASSI") > 0,SD3->D3_XCHASSI,"")
Default _cIDMES			:= SD3->(FieldPos("D3_XIDMES") > 0,SD3->D3_XIDMES,"") 

_lMsgErro			:= IF( _lSchedule == .F., .T. , .F. )
If Empty(_cEmails)
	_cTexto := "**** Erros referente ao processo de importação MES função ZPCP007 não possui e-mail cadastrado no parâmetro CMV_PCP002****"
	_cTexto += "     Os mesmos serão gravados no log do Sistema conforme informações abaixo" 
	Return Nil
EndIf	

//Caso as informações não dependam do posicionamento das tabelas deverá ser enviado as mesmas dentro desta variavel
If Len(_aChave) > 0
	_cCodProd 	:= ZPCPF007EL(_aChave,"D3_COD")
	_cNumOP		:= ZPCPF007EL(_aChave,"D3_OP")
	_cChassi	:= ZPCPF007EL(_aChave,"H6_XCHASSI")		
	_cIDEnt		:= ZPCPF007EL(_aChave,"D3_IDENT")	
	_cIDMES		:= ZPCPF007EL(_aChave,"H6_XIDMES")
EndIf

//localizar o produto
If !Empty(_cCodProd)
	SB1->(DbSetOrder(1))  //B1_FILIAL+B1_COD
	If SB1->(DbSeek(XFilial("SB1") + _cCodProd))
		_cDescProd := AllTrim(SB1->B1_DESC)
	EndIf
Endif

_cEmailDest := _cEmails
_cHtml := ""
_cHtml += "<html>"+ CRLF
_cHtml += "	<head>"+ CRLF
_cHtml += "		<title>Processo de importação MES Informações/Erros</title>"+ CRLF
_cHtml += "	</head>"+ CRLF
_cHtml += "	<body leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>"+ CRLF
_cHtml += "		<table width='100%' height='100%' border='0' cellpadding='0' cellspacing='0'>"+ CRLF
_cHtml += "			<tr>"+ CRLF
_cHtml += "				<th width='1200' height='100%' align='center' valign='top' scope='col'>"+ CRLF
_cHtml += "					<table width='90%' height='50%' border='0' cellpadding='0' cellspacing='0'>"+ CRLF
_cHtml += "						<tr>"+ CRLF
_cHtml += "							<th width='100%' height='100' scope='col'>"+ CRLF
_cHtml += "								<table width='100%' height='60%' border='3' cellpadding='0' cellspacing='0' >"+ CRLF
_cHtml += "									<tr>"+ CRLF
_cHtml += "										<th width='12%' height='0' scope='col'><img src='" + _cLogo + "' width='118' height='40'></th>"+ CRLF
_cHtml += "										<td width='67%' align='center' valign='middle' scope='col'><font face='Arial' size='+1'><b>WF Importação MES Informações</b></font></td>"+ CRLF
_cHtml += "									</tr>"+ CRLF
_cHtml += "								</table>"+ CRLF
_cHtml += "							</th>"+ CRLF
_cHtml += "						</tr>"+ CRLF
_cHtml += "						<tr>"+ CRLF
_cHtml += "							<th width='100' height='100' scope='col'>"+ CRLF
_cHtml += "								<table width='100%' height='100%' border='2' cellpadding='2' cellspacing='1' >"+ CRLF
_cHtml += "									<tr>"+ CRLF
_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>Empresa:	</b></font></td>"+ CRLF
_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>"+AllTrim(FWFilialName(,SM0->M0_CODFIL))+"</font></td>"+ CRLF
_cHtml += "									</tr>"+ CRLF
_cHtml += "									<tr>"+ CRLF
_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>Responsável(is):	</b></font></td>"+ CRLF
_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>" + _cCodUsu+"-"+_cNomeUsu + "</font></td>"+ CRLF
_cHtml += "									</tr>"+ CRLF
_cHtml += "									<tr>"+ CRLF
_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>Ordem de Produção:	</b></font></td>"+ CRLF
_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>"+ _cNumOP +"</font></td>"+ CRLF
_cHtml += "									</tr>"+ CRLF
_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>Veiculo/Produto:	</b></font></td>"+ CRLF
_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>"+ _cCodProd + " - "+_cDescProd+"</font></td>"+ CRLF
_cHtml += "									</tr>"+ CRLF
_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>Chassi:	</b></font></td>"+ CRLF
_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>"+ _cChassi +"</font></td>"+ CRLF
_cHtml += "									</tr>"+ CRLF
_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>ID:	</b></font></td>"+ CRLF
_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>"+ _cIDEnt +"</font></td>"+ CRLF
_cHtml += "									</tr>"+ CRLF
_cHtml += "										<td width='12%' height='16' align='left'  valign='middle' bgcolor='#D3D3D3' scope='col'><font size='2' face='Arial'><b>ID MES:	</b></font></td>"+ CRLF
_cHtml += "										<td width='88%' height='16' align='left'  valign='middle' scope='col'><font size='2' face='Arial'>"+ _cIDMES +"</font></td>"+ CRLF
_cHtml += "									</tr>"+ CRLF

_cHtml += "								</table>"+ CRLF
_cHtml += "							</th>"+ CRLF
_cHtml += "						</tr>"+ CRLF
_cHtml += "						<tr >"+ CRLF
_cHtml += "							<td height='25' style='padding-top:1em;'>"+ CRLF
_cHtml += "								<table width='100%' height='100%' border='2' cellpadding='2' cellspacing='0' >"+ CRLF
_cHtml += "									<tr bgcolor='#4682B4'>"+ CRLF
_cHtml += "										<th width='10%' height='100%' align='center' valign='middle' scope='col'><font face='Arial' size='2'><b>Descrição		</b></font></th>"+ CRLF
_cHtml += "									</tr>"+ CRLF

ConOut(_cAssunto)
For _nPos := 1 To Len(_aMens)
	_cHtml += "									<tr> <!--while advpl-->"+ CRLF
	_cMsgErro := _aMens[_nPos,1]+" - "+_aMens[_nPos,2]
	_cHtml += "										<td width='10%' height='16' align='left'	valign='middle' bgcolor='#"+_cCorItem+"' scope='col'><font size='1' face='Arial'>"+_cMsgErro+"</font></td>"+ CRLF
	_cHtml += "									</tr>"+ CRLF
	ConOut(_aMens[_nPos,1]+" - "+_aMens[_nPos,2])
Next
	
/*
cMailDestino	- E-mail de Destino
cMailCopia		- E-mail de cópia
cAssunto		- Assunto do E-mail
cHtml			- Corpo do E-mail
aAnexos			- Anexos que será enviado
lMsgErro		- .T. Exige msgn na tela - .F. Exibe somente por Conout
cReplyTo		- Responder para outra pessoa.
cRotina			- Rotina que está sendo executada.
cObsMail		- Observação para Gravação do Log.
*/
If _lSchedule
	_lEnvia := U_ZGENMAIL(_cEmailDest,_cEMailCopia,_cAssunto,_cHtml,_aAnexos,_lMsgErro,_lMsgOK,_cRotina,_cObsMail,_cReplyTo)
Else
	MsgRun("Enviando e-mail de notificação. Aguarde!!!","CAOA",{|| _lEnvia := U_ZGENMAIL(_cEmailDest,_cEMailCopia,_cAssunto,_cHtml,_aAnexos,_lMsgErro,_lMsgOK,_cRotina,_cObsMail,_cReplyTo) })
EndIf

If !_lEnvia
	If lSchedule
		ConOut("**** [ ZPCPF07EM ] - E-mail não cadastrado para envio - Solicitar apoio do administrador! (Totvs Integração MES) ****"+ CRLF)
	Else
		ApMsgInfo("E-mail não cadastrado para envio - Solicitar apoio do administrador!! (Totvs Integração MES)","Cadastro")
	EndIf
EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ZPCPF007EL
Rdmake 	Retornar informação (conteúdo em _aChave)   
@author DAC denilso.carvalho
@since 17/07/2020
@version 1.0
@obs _aChave - 	Campos que servirão para pesquisa no envio de e-mail se não enviados verificara pela tabela padrão os mesmos não estarão 
				posicionados no D3 então é necessário enviar para substituir a pesquisa pelo padrão

/*/
//-------------------------------------------------------------------

Static Function ZPCPF007EL(_aChave,_cCampo)
Local _xRet := ""
Local _nPos

//Atualiza conforme o retorno dicionário
SX3->(DbSetOrder(2))
If SX3->(DbSeek(_cCampo))
	If SX3->X3_TIPO == "N"
		_xRet := 0
	ElseIf SX3->X3_TIPO == "D"
		_xRet := CtoD(Space(08))
	ElseIf SX3->X3_TIPO == "L"
		_xRet := .T.
	Endif
Endif		

_nPos := aScan(_aChave,{|x| _cCampo  == AllTrim(x[1]) })
If _nPos > 0
	_xRet := _aChave[_nPos,2]
EndIf

Return _xRet
