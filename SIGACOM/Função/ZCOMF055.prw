#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#include "rwmake.ch"
#include "TOTVS.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF CHR(13)+CHR(10)  //Final de linha

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZCOMF055 

@class    	Nao Informado
@from       Nao Informado
@param      _aParam - Com informações paramb do MT110TEL
@attrib    	Nao Informado
@protected  Nao Informado
@author     Nicolas Lima 
@version    Nao Informado
@since      09/10/2023  
@return    	Logico
@sample     Nao Informado
@obs        Chamado pelo Ponto de Entrada MT110TOK
@project    CAOA
@menu       Nao Informado
@history    
--------------------------------------------------------------------------------------*/

User Function ZCOMF055(cCodCompr)
    
    If !Empty(cCodCompr)
		_lRet := ZCF003CODCOMP()
	EndIf

Return _lRet

/*
=====================================================================================
Programa.:              FVALTPO		
Autor....:              CAOA - Nicolas Lima
Data.....:              09/10/2023
Descricao / Objetivo:   Funcao para verificar se o codigo de comprador e um usuario bloqueado.
Doc. Origem:           
Solicitante:            Thaynara Alves Pimentel
Uso......:              CAOA Montadora.
Obs......:              Função para validar o codigo do comprador
=====================================================================================
*/

Static Function ZCF003CODCOMP()
	//Declarar Variaveis
	//Guardar area
	Local aArea 		:= GetArea()
	Local cQry  		:= ""
	Local cTabela 		:= GetNextAlias()
	Local cBloq  		:= ""
	Local cNomeCompr 	:= ""
	Local _lRet 		:= .F.

	Public cCodCompr //Já vem o valor preenchido no campo

	//Guardar query em tabela temp
	//--QUERY PARA COMPARAR TABELA DE USUARIOS "USR" COM TABELA DE COMPRADORES "SY1"
	//--E MOSTRAR APENAS USUÁRIOS BLOQUEADOS.
	cQry += "	SELECT * FROM " 											+ CRLF
	cQry += "		(	SELECT DISTINCT USRTMP.USR_NOME " 					+ CRLF
	cQry += "			, USRTMP.USR_ID " 									+ CRLF
	cQry += "			, USRTMP.USR_MSBLQL " 								+ CRLF
	cQry += "			FROM " 												+ CRLF //--TABELA DE USUÁRIOS
	cQry += "  			SYS_USR USRTMP"										+ CRLF //--TABELA DE USUÁRIOS
	cQry += "			WHERE " 											+ CRLF
	cQry += "			USRTMP.D_E_L_E_T_ = ' ' " 							+ CRLF
	cQry += "			ORDER BY USRTMP.USR_ID " 							+ CRLF
	cQry += "		) TMP_USR " 											+ CRLF
	cQry += "	LEFT JOIN " 												+ CRLF
	cQry += "		( 	SELECT SY1TMP.Y1_COD " 								+ CRLF
	cQry += "			, SY1TMP.Y1_NOME " 									+ CRLF
	cQry += "			, SY1TMP.Y1_USER " 									+ CRLF 
	cQry += "			FROM " 												+ CRLF  
	cQry += " " 		+ RetSqlName("SY1") + " SY1TMP "					+ CRLF //--TABELA DE COMPRADORES
	cQry += "			WHERE " 											+ CRLF
	cQry += "			SY1TMP.D_E_L_E_T_ = ' ' " 							+ CRLF
	cQry += "			ORDER BY SY1TMP.Y1_USER " 							+ CRLF
	cQry += "		) TMP_SY1 " 											+ CRLF
	cQry += "	ON TMP_USR.USR_ID = TMP_SY1.Y1_USER " 						+ CRLF
	cQry += "	WHERE " 													+ CRLF 
	cQry += "	TMP_SY1.Y1_COD IS NOT NULL "	 							+ CRLF
	cQry += "   AND TMP_SY1.Y1_COD = '"  + AllTrim(cCodCompr) + "'"			+ CRLF

	//Executar query
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTabela, .T., .T. )

	//Verificar se a query encontrou o comprador.
	If (cTabela)->(!EoF())

		(cTabela)->(DbGoTop())
		cBloq 		:= (cTabela)->USR_MSBLQL
		cNomeCompr 	:= (cTabela)->Y1_NOME

		//Rerif. se esta bloqueado
		If cBloq == '1' //Bloqueado
			MsgInfo("O ID " + AllTrim(cCodCompr) + " do comprador " + AllTrim(cNomeCompr) + " esta bloqueado.";
			 + CRLF + " Escolha outro comprador.", "Atenção" )
			_lRet := .F.
		ElseIf cBloq == '2' //Desbloqueado
			_lRet := .T.
		EndIf

	Else
		MsgInfo("Comprador não encontrado." + CRLF + "Por favor, tente outro comprador.","Atenção.")
		_lRet := .F.
	EndIf
	//Se bloqueado, executar mensagem avisando que o cod esta bloqueado e não pode ser utilizado.
	//Se não, passar.
	
	//Retornar area
	RestArea(aArea)
Return _lRet
