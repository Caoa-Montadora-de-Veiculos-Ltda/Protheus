#INCLUDE "TOTVS.CH"
#Include "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

#define CRLF chr(13) + chr(10)


/*/{Protheus.doc} ZPECF011
Serviço de integração RECEBIMENTO SEPARAÇÃO DE PEDIDOS rg log
Atualização da separação dos orçamentos baixando conforme informaçção recebida
@author 	DAC 
@since 		17/12/2021
@version 	undefined
@param		nao utilizado
@type 		User Function
@client   	CAOA BARUERI
@return   	_aMsg - Array com retorno Json código e ocorrencia
@project 	Interfaces_PortalV3_v2 x Protheus v2
			https://tdn.totvs.com/display/tec/DecodeUTF8
			https://jsonformatter.curiousconcept.com/  VERIFICAR SE JSON ESTA CORRETO
			https://jsonlint.com/?code=   //VALIDAR JSON
            https://jsoneditoronline.org/#left=local.sowavu  //estrutura do json
Z	-Customizado
PEC	- Modulo
F 	- Função
011 - Sequencial
/*/

User Function ZRESTSA1(_oJson, _cEmpFil, _cResp)
Local _aMsg		:= {}

Private _aRetMsg := ZRESTSA1Msg()   //Carregar tabela com erros
Private _aMsgRet := {}				//carregar msg de errp

Default _cEmpFil	:= ""
Default _cResp		:= ""

Begin Sequence
	Conout("INICIANDO FUNCIONALIDADE ZRESTSA1 em "+DtoC(Date())+" as "+Time())
	_aMsgRet 	:= {}

    If ZRESTSA1PR( @_oJson, _cEmpFil, _cResp )
		U_ZRETMsgJson("ok", "Atualização realizada com Sucesso !")
		_aMsg := U_ZSetMsgJson()
	Else
		_aMsg := U_ZSetMsgJson()
	Endif

End Sequence

IF Len(_aMsg) == 0 		//Prevensão forçar o envia da mensagem para o REST
	_aMsg := U_ZSetMsgJson()
EndIf

Conout("TERMINO FUNCIONALIDADE ZRESTSA1 em "+DtoC(Date())+" as "+Time())
Return _aMsg


/*/{Protheus.doc} ZRESTSA1PR
Recebe 		Json RG LOG PUT 
@author 	DAC
@since 		23/07/2021
@version 	undefined
@param 		oJson
@type 		function
@ Obs		Os paremetros de token, empresa e filial serão enviados no cabeçalho reader Json
/*/
Static Function ZRESTSA1PR( _oJson, _cEmpFil, _cResp )
Local _cEmpresa     := ""
Local _cFilAtu      := ""
Local _lRet			:= .F.
Local _nPos
Begin Sequence
	_nPos := At(",", _cEmpFil)
	If _nPos <= 0 
		U_ZRETMsgJson("empresa","nao informada tag empresa")
        Break
    EndIf
	_cEmpresa := SubsTr(_cEmpFil,1,_nPos-1)
	_cFilAtu  := SubsTr(_cEmpFil,_nPos+1)

	If Empty(_cEmpresa)
		U_ZRETMsgJson("empresa","nao informada tag empresa")
        Break
	Endif
	If Empty(_cFilAtu)
		U_ZRETMsgJson("filial","nao informada a filial na tag empresa")
        Break
	Endif
	//Verifica a existencia empresa, para não ficar retornando erro 5, valida se a tabela esta abertar
	If Select("SM0") > 0
		SM0->(DbSetOrder(1))  //M0_CODIGO+M0_CODFIL
		If !SM0->(DbSeek(_cEmpresa+_cFilAtu))
			U_ZRETMsgJson("empresa","Dados da empresa inconsistentes")
        	Break
		Endif
	Endif
    //Tratar abertura da empresa conforme enviado no parametro
	If cEmpAnt <> _cEmpresa .or. cFilAnt <> _cFilAtu
    	RpcClearEnv() 
    	RPCSetType(3) 
    	If !RpcSetEnv(_cEmpresa,_cFilAtu,,,,GetEnvServer(),{ })
			U_ZRETMsgJson("ambiente","nao foi possivel acessar ambiente")
        	Break
		Endif
	EndIf
	// Valida os dados do oJson

	If !ValidOJson(@_oJson,)
		Break
	EndIf
	//processa json
	_lRet := ZRESTSA1GR(_oJson, _cEmpresa, _cFilAtu, _cResp)

End Sequence
Return _lRet


/*/{Protheus.doc} ZRESTSA1GR
Gravar dados do oJson no Cliente
@author DAC - Denilso
@since 
@version undefined
@param 
@type function
/*/
Static Function ZRESTSA1GR(_oJson, _cEmpresa, _cFilAtu, _cResp)
Local _cAliasPesq	:= GetNextAlias()
Local _lRet 		:= .F.
Local _lNovo    	:= .T.
Local _cCodSegmento := AllTrim(SuperGetMV("CMV_JSA101",.F.,"06"))  //"06 - PADRÃO"  //Código do Segmento Cliente
Local _cConta 		:= AllTrim(SuperGetMV("CMV_JSA102",.F.,"1120101001"))  	//Conta Contabil Padrão
Local _cGrpTrib     := AllTrim(SuperGetMV("CMV_JSA103",.F.,"FID"))  	//Grupo de Tributação Padrão

Local _cLoja
Local _cCnPjCpf
Local _cIERG
Local _cEndereco
Local _cMunicipio
Local _cCodMun
Local _cBloqueio
Local _cCodPais
Local _cCodBancen
Local _cContrib
Local _cReduzido
Local _cTipoCli

Local _oModel
Local _oSA1Mod
Local _aErro
Local _cStatus
Local _nPos
Local _aMsg


Begin Sequence 
	//Verifica se existe cliente cadastrado
	_cCnPjCpf	:= AllTrim(_oJson:GetJsonText("cnpjcpf"))  

	//Função para retorno de códigos, verificar se existem pais estado e municipio, indiferente do cliente ser ou nao cadastrdos estas informações tem que estar fornecidas corretamente
	If !ZRESTSA1Valida(_oJson, @_cCodMun, @_cCodPais, @_cCodBancen)
		Break
	Endif

	If Empty(_cCnPjCpf)
		U_ZRETMsgJson("cnpjcpf","CNPJ e CPF do Cliente nao informado")
		Break
	Endif

	BeginSql Alias _cAliasPesq
		SELECT 	SA1.R_E_C_N_O_ NREGSA1
       	FROM %table:SA1% SA1
       	WHERE SA1.A1_FILIAL  	= %XFilial:SA1%
			AND SA1.A1_CGC 		= %Exp:_cCnPjCpf%
		  	AND SA1.%notDel%		  
	EndSql      
	If (_cAliasPesq)->(Eof()) 	
    	_cCodCli    := GetSxeNum("SA1","A1_COD")
		_cLoja   	:= StrZero(1,Len(SA1->A1_LOJA))
		_cBloqueio  := "2"
		_lNovo      := .T.
		_cContrib   := "1"   //Verificar se é exportação testar quem é contribuinte 
	Else 
		SA1->(DbGoto((_cAliasPesq)->NREGSA1))
    	_cCodCli    := SA1->A1_COD
		_cLoja   	:= SA1->A1_LOJA		
		_cBloqueio  := SA1->A1_MSBLQL
		_lNovo      := .F.
		_cConta 	:= SA1->A1_CONTA
		_cGrpTrib   := SA1->A1_GRPTRIB
		_cContrib   := "1"   //Verificar se é exportação testar quem é contribuinte 
	Endif
	_cCnPjCpf	:= AllTrim(_oJson:GetJsonText("cnpjcpf"))  
	_cIERG 		:= AllTrim(_oJson:GetJsonText("ierg"))
	_cEndereco	:= Upper(AllTrim(_oJson:GetJsonText("endereco")))  + If(!Empty(_oJson:GetJsonText("endnum")) , ", "+ AllTrim(_oJson:GetJsonText("endnum")),"" )
	_cMunicipio	:= Upper(AllTrim(_oJson:GetJsonText("municipio")))
	_cReduzido 	:= Upper(AllTrim(_oJson:GetJsonText("reduzido")))
	_cTipoCli 	:= Upper(AllTrim(_oJson:GetJsonText("tipocli")))	
	//Caso nao tenha enviado nome reduzido reproduzo o nome
	If Empty(_cReduzido)
		_cReduzido 	:= Upper(AllTrim(_oJson:GetJsonText("nome")))
	Endif
  
	_oModel := FWLoadModel("CRMA980") //"MATA030" na antiga MATA030
	_oModel:SetOperation(If(_lNovo,MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE))
	_oModel:Activate()
  
	//Pegando o model dos campos da SA1
	_oSA1Mod:= _oModel:getModel("SA1MASTER") //"MATA030_SA1" na antiga MATA030
	_oSA1Mod:setValue("A1_FILIAL"	, FWxFilial('SA1')  								) // Filial 
	//_oSA1Mod:setValue("A1_COD"		, _cCodCli        									) // Codigo 
	//_oSA1Mod:setValue("A1_LOJA"		, _cLoja       										) // Loja
	_oSA1Mod:setValue("A1_NOME"		, Upper(AllTrim(_oJson:GetJsonText("nome"))) 		) // Nome             
	_oSA1Mod:setValue("A1_NREDUZ"	, _cReduzido   										) // Nome reduz. 
	_oSA1Mod:setValue("A1_END"		, _cEndereco   										) // Endereco
	_oSA1Mod:setValue("A1_BAIRRO"	, Upper(AllTrim(_oJson:GetJsonText("bairro"))) 		) // Bairro
	_oSA1Mod:setValue("A1_COMPLEM"	, Upper(AllTrim(_oJson:GetJsonText("complemento")))	) // Endereco
	_oSA1Mod:setValue("A1_CEP"		, AllTrim(_oJson:GetJsonText("cep"))        		) // CEP
	_oSA1Mod:setValue("A1_TIPO"		, _cTipoCli    										) // Tipo 
	_oSA1Mod:setValue("A1_EST"		, Upper(AllTrim(_oJson:GetJsonText("estado")))   	) // Estado
	_oSA1Mod:setValue("A1_COD_MUN"	, _cCodMun     										) // Codigo Municipio                
	_oSA1Mod:setValue("A1_MUN"		, _cMunicipio    									) // Municipio
	_oSA1Mod:setValue("A1_PAIS"		, _cCodPais    										) // Pais            
	_oSA1Mod:setValue("A1_CODPAIS"	, _cCodBancen        								) // Código Bacen            
	_oSA1Mod:setValue("A1_CGC"		, _cCnPjCpf 										) // CNPJ/CPF            
	_oSA1Mod:setValue("A1_MSBLQL"	, _cBloqueio 										) // Bloqueio Sim / Não            
	_oSA1Mod:setValue("A1_CODSEG"	, _cCodSegmento 									) // Segmento            
	If Len(_cCnPjCpf) >= 14 .And. !Empty(_cIERG)
		_oSA1Mod:setValue("A1_INSCR"	, _cIERG         								) // Inscricao Estadual
	ElseIf !Empty(_cIERG) 
		_oSA1Mod:setValue("A1_RG"	, _cIERG         								) // Inscricao Estadual
	Endif

	If Len(_cCnPjCpf) >= 14 .And. _cTipoCli <> "X"
		_oSA1Mod:setValue("A1_PESSOA"	, "J"  											) // Tipo Pessoa
	ElseIf _cTipoCli <> "X"
		_oSA1Mod:setValue("A1_PESSOA"	, "F"  											) // Tipo Pessoa
	Else   //POR ENQUANTO COLOCANDO COMO JURIDICA
		_oSA1Mod:setValue("A1_PESSOA"	, "J"  											) // Tipo Pessoa
	Endif									) // Tipo Pessoa

	_oSA1Mod:setValue("A1_EMAIL"	, AllTrim(_oJson:GetJsonText("email"))       		) // E-Mail
	_oSA1Mod:setValue("A1_DDD"		, AllTrim(_oJson:GetJsonText("ddd"))        		) // DDD            
	_oSA1Mod:setValue("A1_TEL"		, AllTrim(_oJson:GetJsonText("fone"))   			) // Fone                 
	_oSA1Mod:setValue("A1_CONTATO"	, Upper(AllTrim(_oJson:GetJsonText("contato")))		) // Contato                

	_oSA1Mod:setValue("A1_CONTA"	, _cConta   										) // Conta contabil                 
	_oSA1Mod:setValue("A1_GRPTRIB"	, _cGrpTrib        									) // Grupo de tributação            
	_oSA1Mod:setValue("A1_CONTRIB"	, _cContrib        									) // Contribuinte Sim Não            
	_oSA1Mod:setValue("A1_XINTEG"	, "S"	        									) // Contribuinte Sim Não            
  

  
	//Se conseguir validar as informações
	_lRet := _oModel:VldData()
	If _lRet 
    	//Tenta realizar o Commit
    	_lRet := _oModel:CommitData()
	Endif	
    If !_lRet
		//Busca o Erro do Modelo de Dados
    	_aErro := _oModel:GetErrorMessage()
		/*
    	//Monta o Texto que será mostrado na tela
    	AutoGrLog("Id do formulário de origem:"  + ' [' + AllToChar(_aErro[01]) + ']')
    	AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(_aErro[02]) + ']')
    	AutoGrLog("Id do formulário de erro: "   + ' [' + AllToChar(_aErro[03]) + ']')
    	AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(_aErro[04]) + ']')
    	AutoGrLog("Id do erro: "                 + ' [' + AllToChar(_aErro[05]) + ']')
    	AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(_aErro[06]) + ']')
   		AutoGrLog("Mensagem da solução: "        + ' [' + AllToChar(_aErro[07]) + ']')
    	AutoGrLog("Valor atribuído: "            + ' [' + AllToChar(_aErro[08]) + ']')
    	AutoGrLog("Valor anterior: "             + ' [' + AllToChar(_aErro[09]) + ']')
    	//Mostra a mensagem de Erro
    	//MostraErro()
		*/
		U_ZRETMsgJson("erropad",FwNoAccent( AllToChar(_aErro[06])))
	Endif
	//Desativa o modelo de dados
	_oModel:DeActivate()
End Sequence

_aMsg := {}
If _lRet 
	_cStatus 	:=	"1"
	_aMsg 		:=  {"Cliente Recebido com Sucesso"}
Else 
	_cStatus 	:=	"2"
	For _nPos := 1 To Len(_aMsgRet)
		Aadd(_aMsg,_aMsgRet[_nPos,2])
	Next
Endif 
For _nPos := 1 To Len(_aMsg)
	U_CAOA_GRVMONITOR(	FWxFilial("SA1"), ;   //Filial arquivo gravado
						_cStatus, ;         //Status
						"100",;				//Código do Processo  REST IMPORTACAO CLIENTES
						/*cCodtpint*/,;		//Código do tipo
						Upper(_aMsg[_nPos] +" Empresa "+_cEmpresa+" Filial "+_cFilAtu) ,;  //Mensagem de retorno
						_cCnPjCpf,;			//Documento
						 Date(),;			//Data Inicio
						 Time(),;			//Hora Final
						_oJson,;			//Json
						/*_nRecnoDoc*/,;        //Recno do documento
						_cResp,; 			//Nome do Usuário na inclusão
						/*_xHTTP*/,;			//Retorno código
						/*_aCampos*/)					//Campos pré definidos para gravar no SZ1 
Next


Return Nil

//ZRESTSA1Monitor( _cStatus,"SA1", _cCnPjCpf, _oJson, _cErro,  /*_dDataIni*/, /*_cHsIni*/, 100 /*_nErro*/ )	

Return _lRet 


Static Function ZRESTSA1Valida(_oJson, _cCodMun, _cCodPais, _cCodBancen)
Local _cAliasPesq   := GetNextAlias()
Local _lRet := .T.
Local _cMunicipio	:= Upper(AllTrim(_oJson:GetJsonText("municipio")))
Local _cUf			:= Upper(AllTrim(_oJson:GetJsonText("estado")))
Local _cPais		:= Upper(AllTrim(_oJson:GetJsonText("pais")))
Local _cTipoCli 	:= Upper(AllTrim(_oJson:GetJsonText("tipocli")))
Local _aRetX3 		:= RetSX3Box(GetSX3Cache("A1_TIPO", "X3_CBOX"),,,1)  //trazer opções de tipo de clientes
Local _cEmail 		:= AllTrim(_oJson:GetJsonText("email"))

Begin Sequence 
	//Valido o tipo de Cliente 
	If Ascan(_aRetX3, { |x| x[2] == _cTipoCli }) == 0
		U_ZRETMsgJson("tipocli","Tipo de Cliente "+tipocli+" nao localizado")
		_lRet := .F.
		Break
 	Endif

	//Valida E-mail
	If !Empty(_cEmail)
		If At("@",_cEmail) == 0 .Or. (At(".com",_cEmail) == 0 .And. At(".gov",_cEmail) == 0 ) 
			U_ZRETMsgJson("email","E-mail do cliente  "+_cEmail+" informado esta invalido")
			_lRet := .F.
			Break
		Endif
	Endif

	//Verificar municipio estado e pais
	BeginSql Alias _cAliasPesq
		SELECT CC2.CC2_CODMUN  
		FROM %Table:CC2% CC2
       	WHERE CC2.CC2_FILIAL  	= %XFilial:CC2%
			AND CC2.CC2_MUN 	= %Exp:_cMunicipio%
			AND CC2.CC2_EST 	= %Exp:_cUf%
		  	AND CC2.%notDel%		  
	EndSql      
	If (_cAliasPesq)->(Eof()) .and. _cTipoCli <> "X"  //para exterior pode estar sem municipio 
		U_ZRETMsgJson("municipio","Municipio "+_cMunicipio+" com estado "+_cUf+" nao localizado")
		_lRet := .F.
		Break
	Endif
	_cCodMun := (_cAliasPesq)->CC2_CODMUN

	(_cAliasPesq)->(DbCloseArea())
	BeginSql Alias _cAliasPesq
		SELECT 	SYA.YA_CODGI, SYA.YA_SISEXP
       	FROM %table:SYA% SYA
       	WHERE SYA.YA_FILIAL  	= %XFilial:SYA%
			AND SYA.YA_DESCR 	= %Exp:_cPais%
		  	AND SYA.%notDel%		  
	EndSql      
	If (_cAliasPesq)->(Eof())
		U_ZRETMsgJson("pais","Pais "+_cPais+" nao localizado")
		_lRet := .F.
		Break
	Endif
	_cCodPais 	:= (_cAliasPesq)->YA_CODGI
	_cCodBancen	:= "0"+(_cAliasPesq)->YA_SISEXP
End Sequence 

If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 

Return _lRet

/*/{Protheus.doc} ValidOJson
Valida os dados do oJson
@author DAC - Denilso
@since 
@version undefined
@param nCode, numeric, descricao
@param cMsg, characters, descricao
@type function
/*/
Static Function ValidOJson(_oJson, _cTipo)
Local _lRet		:= .T.
Local _aMens 	:= {}
 	//Tem a função de validar os itens obrigatórios neste caso o vabeçalho ZWSRFUN.PRW
	_aMens := U_ZVLDOBRJ(_oJson, _aRetMsg, /*_lItem*/, /*_lTodos*/)
	If Len(_aMens) > 0
	  	_aMsgRet 	:= _aMens
		_lRet		:= .F.	
	Endif
Return _lRet



/*/{Protheus.doc} ZRESTSA1Msg
//Carrega Numero do Erro para retorno
@author DAC
@since 12/11/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/
Static Function ZRESTSA1Msg()
Local _aRet := {}
Begin Sequence
	//			Nr Ret	Tags Json			Item	Obrig	Descrição	
	Aadd(_aRet, {100,	"ok"				, .F.	, .F., 	"Processo realizado com sucesso"})

	Aadd(_aRet, {300,	"empresa"			, .F.	, .F., 	"Empresa nao informada"})
	Aadd(_aRet, {301,	"filial"			, .F.	, .F., 	"Filial nao informada"})
	Aadd(_aRet, {302,	"token"				, .F.	, .F., 	"Token Invalido"})
	Aadd(_aRet, {303,	"ambiente"			, .F.	, .F., 	"nao foi possivel acessar ambiente"})

	Aadd(_aRet, {400,	"cnpjcpf"			, .F.	, .T., 	"CNPJ e OU cpf COM problemas"})
	Aadd(_aRet, {401,	"nome"				, .F.	, .T., 	"Nome do Cliente com problemas"})
	Aadd(_aRet, {402,	"ierg"				, .F.	, .F., 	"Inscricao Estadual e ou R.G. com problemas"})
	Aadd(_aRet, {403,	"cep"				, .F.	, .F., 	"Cep do Cliente com problemas"})
	Aadd(_aRet, {404,	"endereco"			, .F.	, .T., 	"Endereço do Cliente com problemas"})
	Aadd(_aRet, {405,	"municipio"			, .F.	, .F., 	"Municipio do Cliente com problemas"})
	Aadd(_aRet, {406,	"estado"			, .F.	, .F., 	"Estado do Cliente com problemas"})
	Aadd(_aRet, {407,	"pais"				, .F.	, .T., 	"Pais do Cliente com problemas"})
	Aadd(_aRet, {408,	"email"				, .F.	, .F., 	"E-mail do Cliente com problemas"})
	Aadd(_aRet, {409,	"tipocli"			, .F.	, .T., 	"Tipo do Cliente com problemas"})

	Aadd(_aRet, {600,	"erropad"			, .F.	, .T., 	"nao foi possivel atualizar Cliente"})
End Sequence
Return _aRet



/*

{
    "cnpjcpf" : "99999999999999",
    "nome" : "Jose Aparecido da Silva", 
    "reduzido" : "Jose", 
    "ierg" : "999999999999999000",
    "cep" : "00000000",
    "endereco" : "Rua Logradouro",
    "endnum" :  2034,
    "complemento" : "Apto 32",
    "bairro" : "Lagoa",
    "municipio" : "Ribeirao Preto",
    "estado" : "SP",
    "pais" : "Brasil",
    "ddd" : "011",
    "fone" : "9999999999",
    "email" : "joseaparecido@email.com.br",
    "contato" : "Jose Aparecido",
    "tipocli" : "F",
}

*/



/*
=====================================================================================
Programa.:              ZPECAJ01Monitor
@param 					_cStatus   	= Status que será gerado no SZ1 1-OK 2-Divergência 
						_cTab		= Tabela principal que esta sendo gravada na integração
						_cDoc   	= Numero do Documento a ser gravado, ja contém a série 
						_cErro    	= mensagem a ser gravada podendo ser de erro e ou exito 
						_dDataIni	= data inicial da importação 
						_cHsIni 	= hora inicial da importação 
						_cJson    	= Json para importação
						_nErro		= numero de retorno que ocasionou erro e ou exito
Autor....:              CAOA - DAC Denilso 
Data		            14/11/2022
Descricao / Objetivo	Funcionalidade que efetuara a gravação de dados no monitor 
Doc. Origem            	PEC020 - Monitor de Integrações WIS
Solicitante            	CAOA
Uso              		ZWSR012
Obs
@menu       			Nao Informado
@return					_lRet 		- Verdadeiro ou falso
@history 				DAC - 	15/02/2023 
								Implementação de envio de campos a serem gravados para SZ1	
=====================================================================================
*/
Static Function	ZRESTSA1Monitor(_cStatus, _cTab, _cDoc, _cMens, _cErro, _dDataIni, _cHsIni, _nErro, _nReg )	
Local _cUserName := "REST ZRESTSA1"   
Local _aCampos	 := {}  //Adicionar campos a serem gravador na tabela DAC  15/02/2023 

Default _cTab 		:= "SA1"
Default _dDataIni	:= Date()
Default _cHsIni		:= Time()

	//AAdd(_aCampos,{"Z1_NTPINTG"	, "ZRESTSA1" 	})
	U_CAOAGRVM(XFilial(_cTab),;		//Filail
				_cStatus,;				//Status
				"100",;					//Código do Processo  REST IMPORTACAO CLIENTES                          
				/*cCodtpint*/,;			//Código do tipo
				Upper(_cErro),;			//Mensagem de retorno
				_cDoc,;					//Documento
				_dDataIni,;				//Data Inicio
				_cHsIni,;				//Hora Final
				Upper(_cMens),;			//Json
				If(_cStatus=="1", (_cTab)->(Recno()),0),; //Numero do Registro
				_cUserName,;			//Nome do Usuário na inclusão
				_nErro,;				//Retorno código
				_aCampos)				//Campos pré definidos para gravar no SZ1 
Return Nil

