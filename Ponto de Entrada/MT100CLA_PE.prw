#Include 'Rwmake.ch'
#Include 'TopConn.ch'
#Include 'Protheus.ch'
#Include 'TOTVS.ch'

/*/{Protheus.doc} MT100CLA
@author A.Carlos
@since 	21/08/2023
@version 1.0
@return ${return}, ${return_description}
@obs	
@history    Preenchimento automático ICMS NF-Complemento
@type function
/*/
User Function MT100CLA()
Local aAreaSF1      := SF1->(GetArea())
Local aAreaSD1      := SD1->(GetArea())
Local cAliasCD5     := GetNextAlias() 
Local cAliasCD9     := GetNextAlias() 
Local cCD5_VTRANS   := ''
Local cCD9_TPPINT   := ''
Local cNFOrig       := ''
Local cSerOrig      := ''
Local cHAWB         := ''
Local cChassi       := ''
Local cTipo         := ''
Local cCOMVEI       := ''
Private cCD9_TPCOMB := ''

IF SF1->F1_EST= 'EX' 

	SD1->(dbSetOrder(1))
	SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	cTipo    := SF1->F1_TIPO
	cNFOrig  := SD1->D1_NFORI
    cSerOrig := SD1->D1_SERIORI

    cChassi := Posicione("SD1", 1, SD1->D1_FILIAL + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD, "D1_CHASSI")	
    cHAWB   := Posicione("SF1", 1, SD1->D1_FILIAL + cNFOrig + cSerOrig + SD1->D1_FORNECE + SD1->D1_LOJA, "F1_HAWB")	

    IF !Empty(cChassi) .AND. cTipo == 'I' 

		BeginSql Alias cAliasCD5

		SELECT DISTINCT SD1.D1_FILIAL AS FILIAL,SD1.D1_DOC AS CD5_DOC,SD1.D1_SERIE AS CD5_SERIE,SD1.D1_FORNECE AS CD5_FORNEC,SD1.D1_LOJA AS CD5_LOJA,;
		    SF1.F1_ESPECIE AS CD5_ESPEC,SW6.W6_DI_NUM AS CD5_NDI,SW6.W6_DTREG_D AS CD5_DT_DI,SW6.W6_LOCALN AS CD5_LOCDES,SW6.W6_UFDESEM AS CD5_UFDES,;
		    SW6.W6_LOCALN LOCAL_NOME,SW6.W6_DT_DESE AS CD5_DTDES,SW8.W8_ADICAO AS CD5_NADIC,SW6.W6_IMPORT IMPORT,SW6.W6_DA_NUM NUM_DI,SW6.W6_VIA_TRA VIA_TRA,;
		    SW8.W8_SEQ_ADI AS CD5_SEQADI,SW8.W8_FABR AS CD5_CODFAB,SW8.W8_FABLOJ AS CD5_LOJFAB,SD1.D1_ITEM AS CD5_ITEM,CD5.R_E_C_N_O_ RECNOCD5
		FROM %table:SW6% SW6 
		LEFT JOIN %table:SF1% SF1 ON SF1.%NotDel%
			AND SW6.W6_FILIAL = SF1.F1_FILIAL
			AND SW6.W6_HAWB   = %Exp:cHAWB%
		LEFT JOIN %table:SD1% SD1 ON SD1.%NotDel%
			AND SF1.F1_FILIAL = SD1.D1_FILIAL
			AND SF1.F1_DOC    = %Exp:cNFOrig%
			AND SF1.F1_SERIE  = %Exp:cSerOrig%
		LEFT JOIN %table:SW8% SW8 ON SW8.%NotDel%
			AND SF1.F1_FILIAL  = SW8.W8_FILIAL
			AND SF1.F1_HAWB    = SW8.W8_HAWB
			AND SD1.D1_COD     = SW8.W8_COD_I
			AND SD1.D1_FORNECE = SW8.W8_FORN
			AND SD1.D1_LOJA    = SW8.W8_FORLOJ
		WHERE  SW6.%NotDel% 
		    AND SW6.W6_FILIAL = %xFilial:SW6% 
			AND SW6.W6_HAWB   = %Exp:cHAWB%

		EndSql

		DbSelectArea((cAliasCD5))
		(cAliasCD5)->(dbGoTop())
		If (cAliasCD5)->(!EOF())

			If (cAliasCD5)->VIA_TRA = 'M'
				cCD5_VTRANS := '1'
			ElseIf (cAliasCD5)->VIA_TRA = 'A' 
				cCD5_VTRANS := '4'
			EndIf 

			DbSelectArea('CD5')
			CD5->(DbSetOrder(1)) // CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+CD5_NADIC                                                                                           

			If CD5->(DbSeek(FWxFilial('CD5') + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + cHAWB))
				RecLock('CD5', .F.)
			else
				RecLock('CD5', .T.)
			EndIf
			CD5_FILIAL := SF1->F1_FILIAL					
			CD5_TPIMP  := '0'
			CD5_LOCAL  := '0'
			CD5_INTERM := '1'
			CD5_SQADIC := '001'
			CD5_DOC    := SF1->F1_DOC
			CD5_SERIE  := SF1->F1_SERIE
			CD5_ESPEC  := SF1->F1_ESPECIE
			CD5_FORNEC := SF1->F1_FORNECE
			CD5_LOJA   := SF1->F1_LOJA
			CD5_DOCIMP := cHAWB
			CD5_NDI    := (cAliasCD5)->CD5_NDI
			CD5_DTDI   := Stod((cAliasCD5)->CD5_DT_DI) 
			CD5_LOCDES := (cAliasCD5)->LOCAL_NOME
			CD5_UFDES  := (cAliasCD5)->CD5_UFDES
			CD5_DTDES  := Stod((cAliasCD5)->CD5_DTDES)
			CD5_CODEXP := (cAliasCD5)->CD5_FORNEC
			CD5_NADIC  := (cAliasCD5)->CD5_NADIC
			CD5_SQADIC := (cAliasCD5)->CD5_SEQADI
			CD5_CODFAB := (cAliasCD5)->CD5_CODFAB
			CD5_LOJFAB := (cAliasCD5)->CD5_LOJFAB
			CD5_LOJEXP := (cAliasCD5)->CD5_LOJA
			CD5_ITEM   := (cAliasCD5)->CD5_ITEM
			CD5_VTRANS := (cAliasCD5)->VIA_TRA

			CD5->(MsUnlock())
		EndIf

		BeginSql Alias cAliasCD9

		SELECT SD1.D1_FILIAL AS CD9_FILIAL, SF1.F1_ESPECIE AS CD9_ESPEC, SD1.D1_FORNECE AS CD9_CLIFOR, SD1.D1_LOJA AS CD9_LOJA, SD1.D1_ITEM AS CD9_ITEM, ;
		    SD1.D1_COD AS CD9_COD, SD1.D1_CHASSI AS CD9_CHASSI, VVC.VVC_GRUCOR AS CD9_CODCOR, VVC.VVC_DESCRI AS CD9_DSCCOR, VV2.VV2_POTMOT AS CD9_POTENC,;
		    VV2.VV2_PESLIQ AS CD9_PESOLI, VV2.VV2_PESBRU AS CD9_PESOBR, VV1.VV1_SERMOT AS CD9_SERIAL, VV2.VV2_COMVEI, VV1.VV1_NUMMOT AS CD9_NMOTOR,;
		    VV2.VV2_CAPTRA AS CD9_CMKG, VV2_DISEIX AS CD9_DISTEI, VV1.VV1_FABMOD AS CD9_ANOMOD, VV1.VV1_FABMOD AS CD9_ANOFAB,VVC.VVC_TIPCOR AS CD9_TIPCOR,;
		    VV2.VV2_TIPVEI AS CD9_TPVEIC, VVE.VVE_ESPREN AS CD9_ESPEVEI, VV2.VV2_MODFAB AS CD9_CODMOD, VV2.VV2_CAPTRA AS CD9_TRACAO, VV2.VV2_QTDPAS AS CD9_LOTAC,;
		    VV2.VV2_CILMOT AS CD9_CILIND, VVC.VVC_GRUCOR AS CD9_CORDE, VV2.VV2_COMVEI AS CD9_COMBUS,CD9.R_E_C_N_O_ RECNOCD9
		FROM %table:VV1% VV1 
		LEFT JOIN %table:SD1% SD1 ON SD1.%NotDel% 
			AND SUBSTR(VV1.VV1_FILIAL,1,6) = SUBSTR(SD1.D1_FILIAL,1,6) 
			AND VV1.VV1_CHASSI = %Exp:cChassi%
		LEFT JOIN %table:SF1% SF1 ON SF1.%NotDel%
			AND SD1.D1_FILIAL = SF1.F1_FILIAL
			AND SD1.D1_DOC    = SF1.F1_DOC
			AND SD1.D1_SERIE  = SF1.F1_SERIE
		LEFT JOIN %table:VV2% VV2 ON VV2.%NotDel%
			AND VV2.VV2_FILIAL = SD1.D1_FILIAL
			AND VV2.VV2_PRODUT = SD1.D1_COD
		LEFT JOIN %table:VVC% VVC ON VVC.%NotDel% 
			AND SUBSTR(VVC.VVC_FILIAL,1,6) = SUBSTR(SD1.D1_FILIAL,1,6) 
			AND VVC.VVC_CODMAR = VV2.VV2_CODMAR
			AND VVC.VVC_CORVEI = VV2.VV2_COREXT
		LEFT JOIN %table:VVE% VVE ON VVE.%NotDel% 
			AND SUBSTR(VVE.VVE_FILIAL,1,6) = SUBSTR(SD1.D1_FILIAL,1,6) 
			AND VVE.VVE_ESPVEI = VV2.VV2_ESPVEI
		WHERE  VV1.%NotDel% 
			AND VV1.VV1_CHASSI   = %Exp:cChassi% 

		EndSql

		DbSelectArea((cAliasCD9))
		(cAliasCD9)->(dbGoTop())
		If (cAliasCD9)->(!EOF())

			If (cAliasCD9)->CD9_TIPCOR = '0'
				cCD9_TPPINT := '1'
			ElseIf (cAliasCD9)->CD9_TIPCOR = '1'
				cCD9_TPPINT := '2'
			ENDIF

            cCOMVEI := (cAliasCD9)->CD9_COMBUS
            
			fSX5CV(cCOMVEI)  //De x Para combustíveis    ,CD5.R_E_C_N_O_ RECNOCD5

			DbSelectArea('CD9')
			CD9->(DbSetOrder(1)) //CD9_FILIAL+CD9_TPMOV+CD9_SERIE+CD9_DOC+CD9_CLIFOR+CD9_LOJA+CD9_ITEM+CD9_COD                                                                                                                                                                      

			If CD9->(DbSeek(FWxFilial('CD9') + 'E' + SF1->F1_SERIE + SF1->F1_DOC + SF1->F1_FORNECE + SF1->F1_LOJA + (cAliasCD9)->CD9_ITEM + (cAliasCD9)->CD9_COD))
				RecLock('CD9', .F.)
			else
				RecLock('CD9', .T.)
			EndIf					
			CD9_DOC    := SF1->F1_DOC
			CD9_SERIE  := SF1->F1_SERIE
			CD9_TPMOV  := 'E'
			CD9_TPOPER := '0' 
			CD9_CONVIN := 'R'
			CD9_CONVEI := '1'
			CD9_RESTR  := '0'
			CD9_TPPINT := cCD9_TPPINT
			CD9_TPCOMB := cCD9_TPCOMB

			CD5->(MsUnlock())
		EndIf

		
		DbSelectArea('CDD')
		CDD->(DbSetOrder(1))   //CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA+CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF

		If CDD->(DbSeek(FWxFilial('CDD') + 'E' + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ))
			RecLock('CDD', .F.)
			CDD_IFCOMP := '00004'
			CDD->(MsUnlock())
		EndIf                                                        

    ENDIF

ENDIF

RestArea(aAreaSF1)
RestArea(aAreaSD1)

Return(.T.)


/*/{Protheus.doc} MT100CLA
@author A.Carlos
@since 	21/08/2023
@version 1.0
@return ${return}, ${return_description}
@obs	
@history    Tabela De x Para de Combustível do Vículo
@type function
/*/
Static Function fSX5CV(cCOMVEI)
Local _cAliasSX5 := GetNextAlias() 
Local _cChaveSX5 := '2F'
Local _lRet      := .T.

    BeginSql Alias _cAliasSX5

    SELECT SX5.R_E_C_N_O_ SX5_RECNO, X5_CHAVE CHAVE, SX5.X5_DESCRI DESCRI 
	FROM %table:SX5% SX5 
	WHERE SX5.%NotDel%
	    AND SX5.X5_FILIAL = %xFilial:SX5%
	    AND SX5.X5_TABELA = %Exp:_cChaveSX5%
		AND SX5.X5_CHAVE  = %Exp:cCOMVEI%
	    ORDER BY X5_FILIAL,X5_TABELA,X5_CHAVE 

	EndSql

	(_cAliasSX5)->(DbGotop())

	If (_cAliasSX5)->(Eof())
		Conout("MT100CLA - Código Não informado na SX5, referente ! Verificar com ADM Sistemas")
		_lRet := .F.
		Break
    Else
		cCD9_TPCOMB	:= AllTrim((_cAliasSX5)->DESCRI)
	EndIf	

	(_cAliasSX5)->(dbCloseArea())	

Return(_lRet) 
