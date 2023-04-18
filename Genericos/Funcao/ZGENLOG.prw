#INCLUDE "PROTHEUS.CH"

/*
================================================================================
Programa.:              ZGENLOG
Autor....:              CAOA - Evandro Mariano
Data.....:              11/03/2022
Descricao / Objetivo:   Grava os fontes que são executados no ambiente Barueri
Parametros:             
Doc. Origem:            
Solicitante:            
================================================================================
*/

User Function ZGENLOG(cNome)
/*
Local 	lCont := .T.
Local 	clQuery := ""
Default cNome := ""

If lCont

	If ( "_PRD" $ AllTrim(GetEnvServer()) .And. "SP" $ AllTrim(GetEnvServer()) ) 
		
		If Empty(cNome)

			clQuery := " INSERT INTO Z0S020 (Z0S_FILIAL,Z0S_ROTINA,Z0S_DATA,R_E_C_N_O_) VALUES ( '" + FwFilial("Z0S")+ "','" + Alltrim(Upper(FunName()))+ "','" + Dtos(Date())+ "',(SELECT MAX(R_E_C_N_O_)+1 FROM Z0S020) )"
			
			If TCSqlExec(clQuery) < 0
				ConOut("O comando SQL gerou erro:", TCSqlError())
			Endif	
			
		Else
			
			If IsInCallStack(cNome)
				
				clQuery := " INSERT INTO Z0S020 (Z0S_FILIAL,Z0S_ROTINA,Z0S_DATA,R_E_C_N_O_) VALUES ( '2020012001','" + Alltrim(Upper(cNome))+ "','" + Dtos(Date())+ "',(SELECT MAX(R_E_C_N_O_)+1 FROM Z0S020) )"
				
				If TCSqlExec(clQuery) < 0
					ConOut("O comando SQL gerou erro:", TCSqlError())
				Endif	

			EndIf
			
		EndIf
		
	EndIf
EndIf
*/
Return


/*/{Protheus.doc} ZGENLZA2
 Gravar Log de Limite de Crédito na tabela ZA2
 @type       Function
 @author     CAOA - DAC Denilso
 @since      12/04/2023
 @version 
 @param      
 @return     Lógico`
 @project	GRUPO CAOA GAP FIN108 - Revitalização Credito [ Montadora ]
 @example
 @history 	
 @see TDN 
 @Obs       
/*/

User Function ZGENLZA2(_xValor, _xValorNovo, _cCampo, _cTitulo, _cRotina,_cUserSol)
Local _lRet         := .T.
Local _cTexto

Default _cTitulo    := ""
Default _cRotina    := "" 
Default _cUserSol   := ""

Begin Sequence
    If _xValor == Nil .Or. _xValorNovo == Nil .Or. _cCampo == Nil
        Break
    Endif			
    If Empty(_cTitulo)    
        SX3->(DbSetOrder(2))
        SX3->(DbSeek(_cCampo))
        _cTitulo := Upper(AllTrim(SX3->X3_TITULO))   
    EndIf
    //noca caso de não vir o nome do solicitante gravar o nome do usuário da alteração
    If Empty(_cUserSol)
        _cUserSol   := PswChave(RetCodUsr()) //Retorna o nome do usuário  
    Endif    
 	_cCampo	    := AllTrim( _cCampo )
    //Trata os dados para os campos
    If ValType(_xValor) == "N"	 
        _xValor     := AllTrim(Str(_xValor))
        _xValorNovo := AllTrim(Str(_xValorNovo))
    ElseIf ValType(_xValor) == "D"	 
        _xValor     := DtoC(_xValor)
        _xValorNovo := DtoC(_xValorNovo)
    ElseIf ValType(_xValor) == "L" .And. _xValor
        _xValor     := "Verdadeiro"
        _xValorNovo := "Verdadeiro"
    ElseIf ValType(_xValor) == "L" .And. !_xValor
        _xValor     := "Falso"
        _xValorNovo := "Falso"
    Else
        _xValor     := AllTrim(_xValor)
        _xValorNovo := AllTrim(_xValorNovo)
    Endif    
    _cTexto := "CAMPO " +_cTitulo+ "("+_cCampo +") ALTERADO DE " +_xValor+ " PARA "+_xValorNovo+ " ROTINA: "+_cRotina
    _cTexto := Upper(FwNoAccent(_cTexto))       

	RecLock("ZA2",.T.)
	ZA2->ZA2_FILIAL	:= xFilial("ZA2")
	ZA2->ZA2_CLIENT	:= SA1->A1_COD
	ZA2->ZA2_LOJA	:= SA1->A1_LOJA
	ZA2->ZA2_DATA	:= Date()
	ZA2->ZA2_HORA	:= Time()
    //Caso exista o campo código do usuário responsável pela alteração
	If ZA2->(FieldPos("ZA2_CODUSR")) > 0
		ZA2->ZA2_CODUSR := RetCodUsr()
    Endif            
	ZA2->ZA2_RESPON	:= PswChave(RetCodUsr())    //Retorna o nome do usuário
	ZA2->ZA2_SOLICI	:= _cUserSol      
	ZA2->ZA2_OBSERV	:= _cTexto

	ZA2->(MsUnlock())
End Sequence
Return _lRet
