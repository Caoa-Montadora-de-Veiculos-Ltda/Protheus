#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#define CRLF chr(13) + chr(10)

Static _aRetMsg := ZRESTSA1Msg()   	//Carregar tabela com erros
Static _aMsgRet := {}				//carregar msg de errp

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

Default _cEmpFil	:= ""
Default _cResp		:= ""
Begin Sequence
	Conout("INICIANDO FUNCIONALIDADE ZRESTSA1 em "+DtoC(Date())+" as "+Time())
	_aMsgRet 	:= {}
	If Empty(_cEmpFil)

	Endif

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
Local _lRet			:= .T.
Local _nPos
Begin Sequence
	_nPos := At(",", _cEmpFil)
	If _nPos <= 0 
		U_ZRETMsgJson("empresa","nao informada tag empresa")
		_lRet := .F.
        Break
    EndIf
	_cEmpresa := SubsTr(_cEmpFil,1,_nPos-1)
	_cFilAtu  := SubsTr(_cEmpFil,_nPos+1)

	If Empty(_cEmpresa)
		U_ZRETMsgJson("empresa","nao informada tag empresa")
		_lRet := .F.
        Break
	Endif
	If Empty(_cFilAtu)
		U_ZRETMsgJson("filial","nao informada a filial na tag empresa")
		_lRet := .F.
        Break
	Endif

    //Tratar abertura da empresa conforme enviado no parametro
	If cEmpAnt <> _cEmpresa .or. cFilAnt <> _cFilAtu
    	RpcClearEnv() 
    	RPCSetType(3) 
    	If !RpcSetEnv(_cEmpresa,_cFilAtu,,,,GetEnvServer(),{ })
			U_ZRETMsgJson("ambiente","nao foi possivel acessar ambiente")
		Endif
	EndIf

	// Valida os dados do oJson
	If !ValidOJson(@_oJson,"A")
		_lRet := .F.
		Break
	EndIf	
	//processa json
	ZRESTSA1GR(_oJson)
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
Static Function ZRESTSA1GR(_oJson)
Local _cAliasPesq	:= GetNextAlias()
Local _lRet 		:= .T.
Local _aCli 		:= {}
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

Begin Sequence 
	//Função para retorno de códigos, verificar se existem pais estado e municipio, indiferente do cliente ser ou nao cadastrdos estas informações tem que estar fornecidas corretamente
	If !ZRESTSA1Valida(_oJson, @_cCodMun, @_cCodPais, @_cCodBancen)
		_lRet := .F.
		Break
	Endif
	//Verifica se existe cliente cadastrado
	_cCnPjCpf	:= AllTrim(_oJson:GetJsonText("cnpjcpf"))  
	If Empty(_cCnPjCpf)
		U_ZRETMsgJson("cnpjcpf","CNPJ e CPF do Cliente nao informado")
		_lRet := .F.
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
	_cEndereco	:= Upper(AllTrim(_oJson:GetJsonText("endereco")))  + ;
					If(_oJson:GetJsonText("endnum") > 0, ", "+ AllTrim(Str(_oJson:GetJsonText("endnum"))),"" )
	_cMunicipio	:= Upper(AllTrim(_oJson:GetJsonText("municipio")))
	_cReduzido 	:= Upper(AllTrim(_oJson:GetJsonText("reduzido")))
	//Caso nao tenha enviado nome reduzido reproduzo o nome
	If Empty(_cReduzido)
		_cReduzido 	:= Upper(AllTrim(_oJson:GetJsonText("nome")))
	Endif
   	aAdd( _aCli, { 'A1_FILIAL' 	,  FWxFilial('SA1')  } )   
    aAdd( _aCli, { 'A1_COD'    	,  cCodCli } )
    aAdd( _aCli, { 'A1_LOJA'   	,  cLoja } )
    aAdd( _aCli, { 'A1_NOME'   	,  Upper(AllTrim(_oJson:GetJsonText("nome"))) } )
  	aAdd( _aCli, { 'A1_NREDUZ' 	,  _cReduzido } ) 
    aAdd( _aCli, { 'A1_TIPO'   	,  Upper(AllTrim(_oJson:GetJsonText("tipocli"))) } )   //F=Cons.Final;L=Produtor Rural;R=Revendedor;S=Solidario;X=Exportacao      
 	aAdd( _aCli, { 'A1_END'  	,  _cEndereco} )
   	aAdd( _aCli, { 'A1_BAIRRO' 	,  Upper(AllTrim(_oJson:GetJsonText("bairro"))) } )
 	aAdd( _aCli, { 'A1_COMPLEM' ,  Upper(AllTrim(_oJson:GetJsonText("complemento"))) } )
 	aAdd( _aCli, { 'A1_CEP'  	,  AllTrim(_oJson:GetJsonText("cep")) } )

    aAdd( _aCli, { 'A1_EST'    	,  Upper(AllTrim(_oJson:GetJsonText("estado"))) } )
    aAdd( _aCli, { 'A1_COD_MUN'	,  _cCodMun })
    aAdd( _aCli, { 'A1_MUN'    	,  _cMunicipio } )
    aAdd( _aCli, { 'A1_PAIS' 	,  _cCodPais } )

    aAdd( _aCli, { 'A1_CGC'    	,  _cCnPjCpf  } )
    aAdd( _aCli, { 'A1_MSBLQL'  ,  _cBloqueio  } )
    aAdd( _aCli, { 'A1_CODSEG'  ,  _cCodSegmento  } )

    aAdd( _aCli, { 'A1_DDD'  	,  AllTrim(_oJson:GetJsonText("ddd")) } )
    aAdd( _aCli, { 'A1_TEL'  	,  AllTrim(_oJson:GetJsonText("fone")) } )
    aAdd( _aCli, { 'A1_EMAIL'  	,  AllTrim(_oJson:GetJsonText("email")) } )
    aAdd( _aCli, { 'A1_CONTATO' ,  Upper(AllTrim(_oJson:GetJsonText("contato"))) } )

    aAdd( _aCli, { 'A1_CONTA'  	,  _cConta  } )
    aAdd( _aCli, { 'A1_GRPTRIB' ,  _cGrpTrib  } )

    aAdd( _aCli, { 'A1_CODPAIS' ,  _cCodBancen  } )
    aAdd( _aCli, { 'A1_CONTRIB' ,  _cContrib  } )  

End Sequence

Return _lRet 


Static Function ZRESTSA1Valida(_oJson, _cCodMun, _cCodPais, _cCodBancen)
Local _cAliasPesq   := GetNextAlias()
Local _lRet := .T.
Local _cMunicipio	:= AllTrim(_oJson:GetJsonText("municipio"))
Local _cUf			:= AllTrim(_oJson:GetJsonText("estado"))
Local _cPais		:= AllTrim(_oJson:GetJsonText("pais"))
Local _cTipoCli 	:= Upper(AllTrim(_oJson:GetJsonText("tipocli")))
Local _aRetX3 		:= RetSX3Box(GetSX3Cache("A1_TIPO", "X3_CBOX"),,,1)  //trazer opções de tipo de clientes
Local _cEmail 		:= AllTrim(_oJson:GetJsonText("email"))

Begin Sequence 
	//Valido o tipo de Cliente 
	If _Ascan(_aRetX3,_cTipoCli) == 0
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
	_cCodBancen	:= (_cAliasPesq)->YA_SISEXP
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
Local _lRet			:= .T.
Begin Sequence
 	//Tem a função de validar os itens obrigatórios neste caso o vabeçalho ZWSRFUN.PRW
	If U_ZVLDOBRJ(_oJson, _aRetMsg, /*_lItem*/, /*_lTodos*/)
		_lRet := .F.
		Break
	EndIf	
End Sequence
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
    "estado" : "SP"
    "pais" : "Brasil",
    "ddd" : "011",
    "fone" : "9999999999",
    "email" : "joseaparecido@email.com.br",
    "contato" : "Jose Aparecido",
    "tipocli" : "F",
}

*/







//Pegando o modelo de dados, setando a operação de inclusão
oModel := FWLoadModel("CRMA980") //"MATA030" na antiga MATA030
oModel:SetOperation(3)
oModel:Activate()
  
//Pegando o model dos campos da SA1
oSA1Mod:= oModel:getModel("SA1MASTER") //"MATA030_SA1" na antiga MATA030
oSA1Mod:setValue("A1_COD",       cCod        ) // Codigo 
oSA1Mod:setValue("A1_LOJA",      cLoja       ) // Loja
oSA1Mod:setValue("A1_NOME",      cNome       ) // Nome             
oSA1Mod:setValue("A1_NREDUZ",    cNomeFant   ) // Nome reduz. 
oSA1Mod:setValue("A1_END",       cEndereco   ) // Endereco
oSA1Mod:setValue("A1_BAIRRO",    cBairro     ) // Bairro
oSA1Mod:setValue("A1_TIPO",      cTp         ) // Tipo 
oSA1Mod:setValue("A1_EST",       cEST        ) // Estado
oSA1Mod:setValue("A1_COD_MUN",   cCodMun     ) // Codigo Municipio                
oSA1Mod:setValue("A1_MUN",       cDescMun    ) // Municipio
oSA1Mod:setValue("A1_CEP",       cCep        ) // CEP
oSA1Mod:setValue("A1_INSCR",     cIE         ) // Inscricao Estadual
oSA1Mod:setValue("A1_CGC",       cCNPJ       ) // CNPJ/CPF            
oSA1Mod:setValue("A1_PAIS",      cCodPais    ) // Pais            
oSA1Mod:setValue("A1_EMAIL",     cEMail      ) // E-Mail
oSA1Mod:setValue("A1_DDD",       cDDD        ) // DDD            
oSA1Mod:setValue("A1_TEL",       cTelefone   ) // Fone                 
oSA1Mod:setValue("A1_PESSOA",    cTipPessoa  ) // Tipo Pessoa
  
//Se conseguir validar as informações
If oModel:VldData()
      
    //Tenta realizar o Commit
    If oModel:CommitData()
        lDeuCerto := .T.
          
    //Se não deu certo, altera a variável para false
    Else
        lDeuCerto := .F.
    EndIf
      
//Se não conseguir validar as informações, altera a variável para false
Else
    lDeuCerto := .F.
EndIf
  
//Se não deu certo a inclusão, mostra a mensagem de erro
If ! lDeuCerto
    //Busca o Erro do Modelo de Dados
    aErro := oModel:GetErrorMessage()
      
    //Monta o Texto que será mostrado na tela
    AutoGrLog("Id do formulário de origem:"  + ' [' + AllToChar(aErro[01]) + ']')
    AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(aErro[02]) + ']')
    AutoGrLog("Id do formulário de erro: "   + ' [' + AllToChar(aErro[03]) + ']')
    AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(aErro[04]) + ']')
    AutoGrLog("Id do erro: "                 + ' [' + AllToChar(aErro[05]) + ']')
    AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(aErro[06]) + ']')
    AutoGrLog("Mensagem da solução: "        + ' [' + AllToChar(aErro[07]) + ']')
    AutoGrLog("Valor atribuído: "            + ' [' + AllToChar(aErro[08]) + ']')
    AutoGrLog("Valor anterior: "             + ' [' + AllToChar(aErro[09]) + ']')
      
    //Mostra a mensagem de Erro
    MostraErro()
EndIf
  
//Desativa o modelo de dados
oModel:DeActivate()



//https://tdn.totvs.com/display/public/PROT/DT+Novo+Fonte+de+Cadastro+de+Clientes+em+MVC

//-------------------------------------------------------------------
/*/{Protheus.doc} MyCRMA980
Função de exemplo para utilização da rotina automática de Clientes.
@param      Nenhum
@return Nenhum
@author     Squad CRM / FAT
@version    12.1.17 / Superior
@since      24/05/2017
/*/
//-------------------------------------------------------------------
User Function MyCRMA980()
 
Local aSA1Auto  := {}
Local aAI0Auto  := {}
Local nOpcAuto  := MODEL_OPERATION_INSERT
Local lRet      := .T.
 
Private lMsErroAuto := .F.
 
lRet := RpcSetEnv("T1","D MG 01","Admin")
 
If lRet
     
    //----------------------------------
    // Dados do Cliente
    //----------------------------------
    aAdd(aSA1Auto,{"A1_COD"     ,"XBX139"               ,Nil})
    aAdd(aSA1Auto,{"A1_LOJA"    ,"01"                   ,Nil})
    aAdd(aSA1Auto,{"A1_NOME"    ,"ROTINA AUTOMATICA"    ,Nil})
    aAdd(aSA1Auto,{"A1_NREDUZ"  ,"ROTAUTO"              ,Nil}) 
    aAdd(aSA1Auto,{"A1_TIPO"    ,"F"                    ,Nil})
    aAdd(aSA1Auto,{"A1_END"     ,"BRAZ LEME"            ,Nil}) 
    aAdd(aSA1Auto,{"A1_BAIRRO"  ,"CASA VERDE"           ,Nil}) 
    aAdd(aSA1Auto,{"A1_EST"     ,"SP"                   ,Nil})
    aAdd(aSA1Auto,{"A1_MUN"     ,"SAO PAULO"            ,Nil})
     
    //---------------------------------------------------------
    // Dados do Complemento do Cliente
    //---------------------------------------------------------
    aAdd(aAI0Auto,{"AI0_SALDO"  ,30                     ,Nil})
     
    //------------------------------------
    // Chamada para cadastrar o cliente.
    //------------------------------------
    MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpcAuto, aAI0Auto)
      
    If lMsErroAuto  
        lRet := lMsErroAuto
    Else
        Conout("Cliente incluído com sucesso!")
    EndIf
     
EndIf
 
RpcClearEnv()
              
Return lRet
