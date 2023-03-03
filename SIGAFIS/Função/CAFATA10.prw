#include 'Protheus.ch'
#Include 'TOPConn.ch'

/*/{Protheus.doc} GCAO10  CAFATA10
//Interface de importação de Formulas na Tes Inteligente
@author RAFAEL.GARCIA 
@adjustment JACKSON.LIMA	
@since 15/02/2019
@version undefined
@param aParams, array, descricao
@type function
/*/
User Function CAFATA10()
	Local  _aArea := getArea()
	LOCAL cObs    := ' '	
	LOCAL cQuery  := ' '

	If n==1
		If Select("xTMP2")   > 0
			xTMP2->(DBCLOSEAREA())
		endif
		cQuery	:= "SELECT * FROM " + RetSqlName("SFM") 
		cQuery	+= " WHERE D_E_L_E_T_=' ' AND FM_FILIAL = '"+XFILIAL("SFM")+"' AND FM_TIPO = '"+gdfieldget("C6_OPER")+"'"
		cQuery	+= " AND FM_TS = '"+gdfieldget("C6_TES")+"' AND FM_GRPROD = '"+SB1->B1_GRTRIB+"' AND FM_GRTRIB='"+SA1->A1_GRPTRIB+"'"
		TcQuery cQuery New Alias xTMP2
		
        cObs := ALLTRIM(FORMULA(xTMP2->FM_XFOR1)) + CHR(10)+CHR(13) + ALLTRIM(FORMULA(xTMP2->FM_XFOR2)) + CHR(10)+CHR(13) + ALLTRIM(FORMULA(xTMP2->FM_XFOR3))
		
		if !EMPTY(cObs)
            M->C5_XMENSER := cObs
            GetDRefresh() //Refresh na Tela de PV toda 
		endif
		
		If Select("xTMP2")   > 0
			xTMP2->(DBCLOSEAREA())
		endif
		
	Endif	 
	RestArea(_aArea)	

Return(gdfieldget("C6_OPER"))


