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

Local 	lCont := .T.
Local 	clQuery := ""
Default cNome := ""

/*If lCont

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
