#INCLUDE "TopConn.ch"

#Define CRLF  CHAR(13) + CHAR(10)
/*=====================================================================================
Programa.:              ZFATF011
Autor....:              CAOA - Valter Carvalho
Data.....:              08/03/2022
Descricao / Objetivo:   Se o item da nota for um veiculo, valida se existe o cd9
Doc. Origem:
Solicitante:            Julia Alcantara
Uso......:              FISVAL_NFE   
=====================================================================================*/
User function ZFATF011()

	Local _lRet 	:= .T.

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
		_lRet := zFMontadora()
    EndIf

Return(_lRet)

/*
=====================================================================================
Programa.:              ZExecMont
Autor....:              TOTVS
Data.....:              10/03/2022
Descricao / Objetivo:   Executa o P.e. empresa Montadora
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/
Static Function zFMontadora()

	Local cQry 		:= ""
	Local cES, cDoc, cSer, cCliFor, cLj, cFil
	Local cCmd  	:= ""
	Local cGrupo 	:= ""
	Local aStru
	Local lRes 		:= .T.

	cQry := GetNextAlias()

	cES       := PARAMIXB[1]
	cFil      := PARAMIXB[2]
	cDoc      := PARAMIXB[4]
	cSer      := PARAMIXB[5]
	cCliFor   := PARAMIXB[6]
	cLj       := PARAMIXB[7]

	ConOut("ZFATF011 - INICIO - NF: " + cDoc + " Serie: " + cSer )

	If cES == "E"
		cmd := CRLF + " SELECT D1_GRUPO AS GRUPO FROM " + RetSqlName("SD1")
		cmd += CRLF + " WHERE 											"
		cmd += CRLF + "     D_E_L_E_T_ = ' ' 							"
		cmd += CRLF + " AND D1_FILIAL  = '" +  FwxFilial("SD1")  + "' 	"
		cmd += CRLF + " AND D1_DOC     = '" +  cDoc              + "' 	"
		cmd += CRLF + " AND D1_SERIE   = '" +  cSer              + "' 	"
		cmd += CRLF + " AND D1_FORNECE = '" +  cCliFor           + "' 	"
		cmd += CRLF + " AND D1_LOJA    = '" +  cLj               + "' 	"
		cmd += CRLF + " AND D1_TIPO    = 'N' "
		cmd += CRLF + " AND D1_GRUPO   = 'VEIA' "
		cmd += CRLF + " AND D1_TES NOT IN (" + zgetSeqTEs("CMV_FAT005") + ")"
	Else
		cmd := CRLF + " SELECT D2_GRUPO  AS GRUPO FROM " + RetSqlName("SD2")
		cmd += CRLF + " WHERE "
		cmd += CRLF + "     D_E_L_E_T_ = ' ' 							"
		cmd += CRLF + " AND D2_FILIAL  = '" +  FwxFilial("SD1")  + "' 	"
		cmd += CRLF + " AND D2_DOC     = '" +  cDoc              + "' 	"
		cmd += CRLF + " AND D2_SERIE   = '" +  cSer              + "' 	"
		cmd += CRLF + " AND D2_CLIENTE = '" +  cCliFor           + "' 	"
		cmd += CRLF + " AND D2_LOJA    = '" +  cLj               + "' 	"
		cmd += CRLF + " AND D2_GRUPO   = 'VEIA' 						"
		cmd += CRLF + " AND D2_TIPO    = 'N' 							"
		cmd += CRLF + " AND D2_TES NOT IN (" + zgetSeqTEs("CMV_FAT006") + ")"
	EndIf

	cGrupo := MpSysExecScalar(cmd,"GRUPO")

	If Empty(cGrupo)

		Return(.T.)

	EndIf

	cCmd :=        " SELECT * FROM " + RetSQLName("CD9")
	cCmd += CRLF + "  WHERE "
	cCmd += CRLF + "      D_E_L_E_T_ = ' ' "
	cCmd += CRLF + "  AND CD9_TPMOV = '"  + cES       + "' "
	cCmd += CRLF + "  AND CD9_FILIAL = '" + cFilAnt   + "' "
	cCmd += CRLF + "  AND CD9_DOC    = '" + cDoc      + "' "
	cCmd += CRLF + "  AND CD9_SERIE  = '" + cSer      + "' "
	cCmd += CRLF + "  AND CD9_CLIFOR = '" + cCliFor     + "' "
	cCmd += CRLF + "  AND CD9_LOJA   = '" + cLj       + "' "
	cCmd += CRLF + "  ORDER BY CD9_ITEM "

	TcQuery cCmd new alias (cQry)

	aStru := (cQry)->(DbStruct())

	If (cQry)->(Eof())

		lRes := .F.

	Else

		lRes := .T.

	EndIf

	(cQry)->(DbCloseArea())

	ConOut("ZFATF011, NF:" + cDoc + " Serie:" + cSer + " Resultado: " +  cValToChar(lRes) )

	ConOut("ZFATF011 - FIM - NF: " + cDoc + " Serie: " + cSer )
	
Return(lRes)

/*
=====================================================================================
Programa.:              zgetSeqTEs
Autor....:              TOTVS
Data.....:              03/02/2022
Descricao / Objetivo:   retorna alista das tes a serem igoradas
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/
Static Function zgetSeqTEs(cParam)
	Local aAux   := ""
	Private cRes := ""

	aAux := StrTokArr( GetMv(cParam), ",")

	aEval(aAux, {|cTes| cRes +=  " '" + Alltrim(cTes)+ "', "})

	cRes := SubStr(cRes, 1, Len(cRes)-2)
Return cRes
