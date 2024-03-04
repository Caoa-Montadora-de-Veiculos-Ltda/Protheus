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
@param		Não utilizado
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
		_aMsg := SetMsgRet()
	Else
		_aMsg := SetMsgRet()
	Endif
End Sequence

IF Len(_aMsg) == 0 		//Prevensão forçar o envia da mensagem para o REST
	_aMsg := SetMsgRet()
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
		U_ZRETMsgJson("empresa")
		_lRet := .F.
        Break
    EndIf
	_cEmpresa := SubsTr(_cEmpFil,1,_nPos-1)
	_cFilAtu  := SubsTr(_cEmpFil,_nPos+1)

    //Tratar abertura da empresa conforme enviado no parametro
	If cEmpAnt <> _cEmpresa .or. cFilAnt <> _cFilAtu
    	RpcClearEnv() 
    	RPCSetType(3) 
    	RpcSetEnv(_cEmpresa,_cFilAtu,,,,GetEnvServer(),{ })
	EndIf

	// Valida os dados do oJson
	If !ValidOJson(@_oJson,"A")
		_lRet := .F.
		Break
	EndIf	

	ZRESTSA1GR(_oJson)
End Sequence
Return _lRet




/*/{Protheus.doc} ValidOJson
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
Local _cCodSegmento := AllTrim(SuperGetMV("CMV_RESTI01",.F.,"06"))  //"06 - PADRÃO"
Local _cConta 		:= AllTrim(SuperGetMV("CMV_RESTI02",.F.,""))  	//
Local _cGrpTrib     := AllTrim(SuperGetMV("CMV_RESTI02",.F.,""))  	//

Local _cLoja
Local _cCnPjCpf
Local _cIERG
Local _cEndereco
Local _cMunicipio
Local _cCodMun
Local _cBloqueio
Local _cCodPais
Local _cContrib

Begin Sequence 
	_cCnPjCpf	:= AllTrim(_oJson:GetJsonText("cnpjcpf"))  
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
		_SA1->(DbGoto((_cAliasPesq)->NREGSA1))
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
	_cEndereco	:= AllTrim(_oJson:GetJsonText("endereco"))  + ;
					If(_oJson:GetJsonText("endnum") > 0, ", "+ AllTrim(Str(_oJson:GetJsonText("endnum"))),"" )
	_cMunicipio	:= AllTrim(_oJson:GetJsonText("municipio"))
	
	//Função para retorno de códigos
	ZRESTSA1Localiza(_oJson, @_cCodMun, @_cCodPais)
	_cCodMun 	:= ""  //Função para localizar codigo municipo pelo nome


   	aAdd( _aCli, { 'A1_FILIAL' 	,  FWxFilial('SA1')  } )   
    aAdd( _aCli, { 'A1_COD'    	,  cCodCli } )
    aAdd( _aCli, { 'A1_LOJA'   	,  cLoja } )
    aAdd( _aCli, { 'A1_NOME'   	,  AllTrim(_oJson:GetJsonText("nome")) } )
  	aAdd( _aCli, { 'A1_NREDUZ' 	,  AllTrim(_oJson:GetJsonText("reduzido")) } ) 
    aAdd( _aCli, { 'A1_TIPO'   	,  AllTrim(_oJson:GetJsonText("tipocli")) } )   //F=Cons.Final;L=Produtor Rural;R=Revendedor;S=Solidario;X=Exportacao      
 	aAdd( _aCli, { 'A1_END'  	,  _cEndereco} )
   	aAdd( _aCli, { 'A1_BAIRRO' 	,  AllTrim(_oJson:GetJsonText("bairro")) } )
 	aAdd( _aCli, { 'A1_COMPLEM' ,  AllTrim(_oJson:GetJsonText("complemento")) } )
 	aAdd( _aCli, { 'A1_CEP'  	,  AllTrim(_oJson:GetJsonText("cep")) } )


    aAdd( _aCli, { 'A1_EST'    	,  AllTrim(_oJson:GetJsonText("estado")) } )
    aAdd( _aCli, { 'A1_COD_MUN'	,  _cCodMun })
    aAdd( _aCli, { 'A1_MUN'    	,  _cMunicipio } )
    aAdd( _aCli, { 'A1_PAIS' 	,  AllTrim(_oJson:GetJsonText("pais")) } )

    aAdd( _aCli, { 'A1_CGC'    	,  _cCnPjCpf  } )
    aAdd( _aCli, { 'A1_MSBLQL'  ,  _cBloqueio  } )
    aAdd( _aCli, { 'A1_CODSEG'  ,  _cCodSegmento  } )

    aAdd( _aCli, { 'A1_DDD'  	,  AllTrim(_oJson:GetJsonText("ddd")) } )
    aAdd( _aCli, { 'A1_TEL'  	,  AllTrim(_oJson:GetJsonText("fone")) } )
    aAdd( _aCli, { 'A1_EMAIL'  	,  AllTrim(_oJson:GetJsonText("email")) } )


    aAdd( _aCli, { 'A1_CONTA'  	,  _cConta  } )
    aAdd( _aCli, { 'A1_GRPTRIB' ,  _cGrpTrib  } )

    aAdd( _aCli, { 'A1_CODPAIS' ,  _cCodPais  } )
    aAdd( _aCli, { 'A1_CONTRIB' ,  _cContrib  } )  






End Sequence

Return _lRet 


Static Function ZRESTSA1Localiza(_oJson, _cCodMun, _cCodPais)
Local _lRet := .T.
Local _cMunicipio	:= AllTrim(_oJson:GetJsonText("municipio"))
Local _cPais		:= AllTrim(_oJson:GetJsonText("pais"))

	BeginSql Alias _cAliasPesq
		SELECT A1_PAIS,YA_DESCR, A1_CODPAIS  
		FROM SA1020
		LEFT JOIN SYA020
			ON YA_CODGI = A1_PAIS
		GROUP BY A1_PAIS, YA_DESCR, A1_CODPAIS



		SELECT 	SYA.R_E_C_N_O_ NREGSYA
				, 
       	FROM %table:SA1% SA1
       	WHERE SA1.A1_FILIAL  	= %XFilial:SA1%
			AND SA1.A1_CGC 		= %Exp:_cCnPjCpf%
		  	AND SA1.%notDel%		  
	EndSql      

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
	//			Nr Ret	Tags Json				Item	Obrig	Descrição	
	Aadd(_aRet, {100,	"ok"					, .F.	, .F., 	"Processo realizado com sucesso"})

	Aadd(_aRet, {500,	"empresa"				, .F.	, .F., 	"Empresa e filial não informada"})
	Aadd(_aRet, {501,	"responsavel"			, .F.	, .F., 	"Responsavel não informado"})
	Aadd(_aRet, {502,	"usuario"				, .F.	, .T., 	"Usuario"})
	Aadd(_aRet, {503,	"senha"					, .F.	, .T., 	"Senha"})


	Aadd(_aRet, {600,	"Cidade"				, .T.	, .T., 	"Numero do pedido"})

End Sequence
Return _aRet



/*

{
    "nome" : "Jose Aparecido Silva", 
    "reduzido" : "Jose", 
    "cnpjcpf" : "00000000000000",
    "ierg" : "",
    "cep" : "00000000",
    "endereco" : "Rua da logoa",
    "endnum" :  30,
    "complemento" : "",
    "bairro" : "barrinha",
    "municipio" : "Sao Paulo",
    "estado" : "SP"
    "pais" : "BRA",
    "ddd" : "011",
    "fone" : "9999999999",
    "email" : "jasiva@teste.com.br",
    "tipocli" : "F",
}

*/
