#include "totvs.ch"

User Function VX001AFA()
	Local cSQL, cSQLAlias, aArea, lBloqFat

	If VV0->VV0_VALTRO <> 0
		FMX_HELP("VX001AFA","Impossível continuar." + CRLF + "Atendimento possui um valor de troco." + CRLF + "Troco: " + Transform(VV0->VV0_VALTRO,"@E 999,999,999.99"),"Verifique a negociação do atendimento.")
		Return .t.
	EndIf

	If ParamIXB[2] == "L"
		cSQLAlias := "TVVAVAL"
		aArea := GetArea()
		lBloqFat := .f.

		cSQL := ;
			"SELECT VVA_CHASSI " + ;
			 " FROM " + RetSQLName("VVA") + " VVA " + ;
			" WHERE VVA.VVA_FILIAL = '" + xFilial("VVA") + "' " + ;
			  " AND VVA.VVA_NUMTRA = '" + VV0->VV0_NUMTRA + "' " + ;
			  " AND VVA.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cSQLAlias, .F., .T. )
		While ! (cSQLAlias)->(Eof())
			If ! u_VA06002_Chassi((cSQLAlias)->VVA_CHASSI)
				If ! lBloqFat
					lBloqFat := .t.
				EndIf
			EndIf
			(cSQLAlias)->(DBSkip())
		End
		(cSQLAlias)->(dbCloseArea())

		RestArea( aArea )

		Return lBloqFat

	EndIf

Return .f.
