#Include 'Rwmake.ch'
#Include 'TopConn.ch'
#Include 'Protheus.ch'
#Include 'TOTVS.ch'
/*/{Protheus.doc} U_ZEICF023
@author A.Carlos
@since 	21/08/2023
@version 1.0
@return ${return}, ${return_description}
@obs	
@history    Preenchimento autom�tico ICMS NF-Complemento
@type function
/*/
User Function ZEICF033()
Local aAreaSF1      := SF1->(GetArea())
Local aAreaSD1      := SD1->(GetArea())
Local cAliasCD5     := GetNextAlias() 
Local cAliasCD9     := GetNextAlias() 
Local nCD5_VTRANS   := 0
Local nCD5_VAFRMM   := 0
Local cDesp         := '405'
Local cCD9_TPPINT   := ''
Local cCOMVEI       := ''
Local cNFOrig       := SD1->D1_NFORI
Local cSerOrig      := SD1->D1_SERIORI
Local cHAWB         := ''
Local cChassi       := ''
Local cTipo         := SF1->F1_TIPO
Local cProduto      := SD1->D1_COD
Local cFilF1        := SF1->F1_FILIAL
Local cNota         := SF1->F1_DOC
Local cSerie        := SF1->F1_SERIE
Local cEspec        := SF1->F1_ESPECIE
Local cFornec       := SF1->F1_FORNECE
Local cLoja         := SF1->F1_LOJA
Private cCD9_TPCOMB := ''

IF SF1->F1_EST= 'EX' 

	SD1->(dbSetOrder(1))
	SD1->(dbSeek(xFilial("SD1")+SD1->D1_NFORI+SD1->D1_SERIORI+cFornec+cLoja))

    cChassi := SD1->D1_CHASSI    //Posicione("SD1", 1, cFilF1 + cNFOrig + cSerOrig + cFornec + cLoja + cProduto, "D1_CHASSI")	
    cHAWB   := Posicione("SF1", 1, cFilF1 + cNFOrig + cSerOrig + cFornec + cLoja, "F1_HAWB")	

    IF !Empty(cChassi) .AND. !Empty(cHAWB) .AND. cTipo == 'I' 

		BeginSql Alias cAliasCD5

		SELECT DISTINCT SW6.W6_DI_NUM AS CD5_NDI,SW6.W6_DTREG_D AS CD5_DT_DI,SW6.W6_LOCALN AS CD5_LOCDES,SW6.W6_UFDESEM AS CD5_UFDES,;
		    SW6.W6_LOCALN LOCAL_NOME,SW6.W6_DT_DESE AS CD5_DTDES,SW8.W8_ADICAO AS CD5_NADIC,SW6.W6_IMPORT IMPORT,SW6.W6_DA_NUM NUM_DI,SW6.W6_VIA_TRA VIA_TRA,;
		    SW8.W8_SEQ_ADI AS CD5_SEQADI,SW8.W8_FABR AS CD5_CODFAB,SW8.W8_FABLOJ AS CD5_LOJFAB,SD1.D1_ITEM AS CD5_ITEM,WD_VALOR_R AS VALFREM
		FROM %table:SW6% SW6 
		LEFT JOIN %table:SD1% SD1 ON SD1.%NotDel%
			AND SD1.D1_FILIAL = %Exp:cFilF1%
			AND SD1.D1_DOC    = %Exp:cNFOrig%
			AND SD1.D1_SERIE  = %Exp:cSerOrig%
		LEFT JOIN %table:SW8% SW8 ON SW8.%NotDel%
			AND SW8.W8_FILIAL = %Exp:cFilF1%
			AND SW8.W8_HAWB   = %Exp:cHAWB%
			AND SW8.W8_COD_I  = SD1.D1_COD 
			AND SW8.W8_FORN   = %Exp:cFornec%
			AND SW8.W8_FORLOJ = %Exp:cLoja%
		LEFT JOIN %table:SWD% SWD ON SWD.%NotDel%
			AND SWD.WD_FILIAL = %Exp:cFilF1%
			AND SWD.WD_HAWB   = %Exp:cHAWB%
			AND SWD.WD_DESPESA= %Exp:cDesp%

		WHERE  SW6.%NotDel% 
		    AND SW6.W6_FILIAL = %xFilial:SW6% 
			AND SW6.W6_HAWB   = %Exp:cHAWB%

		EndSql

		DbSelectArea((cAliasCD5))
		(cAliasCD5)->(dbGoTop())
		If (cAliasCD5)->(!EOF())

			If (cAliasCD5)->VIA_TRA = 'M'
				nCD5_VTRANS := '1 '
				nCD5_VAFRMM := (cAliasCD5)->VALFREM
			ElseIf (cAliasCD5)->VIA_TRA = 'A' 
				nCD5_VTRANS := '4 '
			EndIf 

			DbSelectArea('CD5')
			CD5->(DbSetOrder(1)) // CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+CD5_NADIC                                                                                           

			If CD5->(DbSeek(FWxFilial('CD5') + cNota + cSerie + cFornec + cLoja + cHAWB))
				RecLock('CD5', .F.)
			else
				RecLock('CD5', .T.)
			EndIf
			CD5_FILIAL := xFilial("SF1")					
			CD5_LOCAL  := '0'
			CD5_TPIMP  := '0'
			CD5_INTERM := '1'
			CD5_SQADIC := '001'
			CD5_DOC    := cNota
			CD5_SERIE  := cSerie
			CD5_ESPEC  := cEspec
			CD5_FORNEC := cFornec
			CD5_LOJA   := cLoja
			CD5_CODEXP := cFornec
			CD5_LOJEXP := cLoja
			CD5_DOCIMP := cHAWB
			CD5_NDI    := (cAliasCD5)->CD5_NDI
			CD5_DTDI   := Stod((cAliasCD5)->CD5_DT_DI) 
			CD5_LOCDES := (cAliasCD5)->LOCAL_NOME
			CD5_UFDES  := (cAliasCD5)->CD5_UFDES
			CD5_DTDES  := Stod((cAliasCD5)->CD5_DTDES)
			CD5_NADIC  := (cAliasCD5)->CD5_NADIC
			CD5_SQADIC := (cAliasCD5)->CD5_SEQADI
			CD5_CODFAB := (cAliasCD5)->CD5_CODFAB
			CD5_LOJFAB := (cAliasCD5)->CD5_LOJFAB
			CD5_ITEM   := (cAliasCD5)->CD5_ITEM
			CD5_VTRANS := nCD5_VTRANS
			CD5_VAFRMM := nCD5_VAFRMM

			CD5->(MsUnlock())
		EndIf

		BeginSql Alias cAliasCD9

		SELECT SD1.D1_FILIAL AS CD9_FILIAL, SD1.D1_ITEM AS CD9_ITEM, SD1.D1_COD AS CD9_COD, SD1.D1_CHASSI AS CD9_CHASSI,;
			VV1.VV1_SERMOT AS CD9_SERIAL, VV1.VV1_NUMMOT AS CD9_NMOTOR, VV1.VV1_FABMOD AS CD9_ANOFAB, VV1.VV1_FABMOD AS CD9_ANOMOD,;
		    VVC.VVC_GRUCOR AS CD9_CODCOR, VVC.VVC_DESCRI AS CD9_DSCCOR, VV2.VV2_POTMOT AS CD9_POTENC, VVC.VVC_TIPCOR AS CD9_TIPCOR,;
		    VV2.VV2_PESLIQ AS CD9_PESOLI, VV2.VV2_PESBRU AS CD9_PESOBR, VV2.VV2_CAPTRA AS CD9_TRACAO,;
		    VV2.VV2_DISEIX AS CD9_DISTEI, VV2.VV2_TIPVEI AS CD9_TPVEIC, VV2.VV2_MODFAB AS CD9_CODMOD,;
			VV2.VV2_QTDPAS AS CD9_LOTAC,  VV2.VV2_CILMOT AS CD9_CILIND, VV2.VV2_COMVEI AS CD9_COMBUS,VVE.VVE_ESPREN AS CD9_ESPEVEI
		FROM %table:VV1% VV1 
		LEFT JOIN %table:SD1% SD1 ON SD1.%NotDel% 
			AND SUBSTR(VV1.VV1_FILIAL,1,6) = SUBSTR(SD1.D1_FILIAL,1,6) 
			AND VV1.VV1_CHASSI = %Exp:cChassi%
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
            
			fSX5CV(cCOMVEI)  //De x Para combust�veis    ,CD5.R_E_C_N_O_ RECNOCD5

			DbSelectArea('CD9')
			CD9->(DbSetOrder(1)) //CD9_FILIAL+CD9_TPMOV+CD9_SERIE+CD9_DOC+CD9_CLIFOR+CD9_LOJA+CD9_ITEM+CD9_COD                                                                                                                                                                      

			If CD9->(DbSeek(FWxFilial('CD9') + 'E' + cSerie + cNota + cFornec + cLoja + (cAliasCD9)->CD9_ITEM + (cAliasCD9)->CD9_COD))
				RecLock('CD9', .F.)
			else
				RecLock('CD9', .T.)
			EndIf
			CD9->CD9_FILIAL := xFilial("SF1")					
			CD9->CD9_DOC    := cNota
			CD9->CD9_SERIE  := cSerie
			CD9->CD9_ESPEC  := cEspec
		    CD9->CD9_CLIFOR := cFornec
			CD9->CD9_LOJA   := cLoja
			CD9->CD9_ITEM   := (cAliasCD9)->CD9_ITEM
			CD9->CD9_COD    := (cAliasCD9)->CD9_COD
			CD9->CD9_TPMOV  := 'E'
			CD9->CD9_TPOPER := '0' 
			CD9->CD9_CONVIN := 'R'
			CD9->CD9_CONVEI := '1'
			CD9->CD9_RESTR  := '0'
			CD9->CD9_TPPINT := cCD9_TPPINT
			CD9->CD9_TPCOMB := cCD9_TPCOMB

			CD9->(MsUnlock())
		EndIf

		
		DbSelectArea('CDD')
		CDD->(DbSetOrder(1))   //CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA+CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF

		If CDD->(DbSeek(FWxFilial('CDD') + 'E' + cNota + cSerie + cFornec + cLoja + cNFOrig + cSerOrig ))   //+ parref + lojref
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
@history    Tabela De x Para de Combust�vel do V�culo
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
		Conout("MT100CLA - C�digo N�o informado na SX5, referente ! Verificar com ADM Sistemas")
		_lRet := .F.
		Break
    Else
		cCD9_TPCOMB	:= AllTrim((_cAliasSX5)->DESCRI)
	EndIf	

	(_cAliasSX5)->(dbCloseArea())	

Return(_lRet) 
