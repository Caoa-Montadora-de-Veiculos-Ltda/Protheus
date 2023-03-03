#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MTA131C8_PE
//PE p/ adicionar dados a Cotação  
@author A.Carlos
@since 	09/10/2020
@version 1.0
@return 
@obs	
@history    Obs geral da SC1
@type function
/*/
User Function ZCOMF025(oModFor, _lRet)
Local cQuery  := ""
Local cFornec := ""
Local cLojaFor:= ""

	cFornec  := oModFor:GetValue("C8_FORNECE")
	cLojaFor := oModFor:GetValue("C8_LOJA")

	If (Select("TRBSD1") <> 0 )
		dbSelectArea("TRBSD1")
		dbCloseArea()
	Endif
	
	cQuery := " SELECT D1_VUNIT FROM "+RetSQLName("SD1")+"  WHERE D1_FILIAL='"+xFilial("SD1")+"' "
	cQuery += " AND D_E_L_E_T_<>'*' AND D1_COD='"+SC1->C1_PRODUTO+"' AND D1_TIPO='N' "
	cQuery += " AND D1_FORNECE='"+cFornec+"' AND D1_LOJA='"+cLojaFor+"' "
	cQuery += " ORDER BY D1_EMISSAO DESC "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBSD1",.T.,.T.)

	dbSelectArea("TRBSD1")
	dbGoTop()
	If TRBSD1->(!Eof())
		oModFor:LoadValue("C8_XULTPRC",TRBSD1->D1_VUNIT)
	Endif	
    
	
	oModFor:LoadValue("C8_XOBSITE",SC1->C1_XOBSITE)
    oModFor:LoadValue("C8_XOBSREQ",SC1->C1_XOBSREQ)
	oModFor:LoadValue("C8_XDESCL1",SC1->C1_XDESCL1)
	//oModFor:LoadValue("C8_XDESCL2",SC1->C1_XDESCL2)

Return(_lRet)
