#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

User Function MATA131()
	
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''

	If aParam <> NIL
		
		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]
		
		If cIdPonto == "MODELVLDACTIVE"
		/*
		=====================================================================================
		GAP COM114 - PopUp na conclusão da Cotação de Compras com o número gerado
		=====================================================================================
		*/
		ElseIf cIdPonto == "MODELCOMMITNTTS"
		    MsgAlert('<h1>'+SC8->C8_NUM+'</h1>COTAÇÃO GERADA NÚMERO:'+SC8->C8_NUM+' </b> pela SC '+SC8->C8_NUMSC+ '</font>', "Atenção")
        EndIf
		
	EndIf
	
Return xRet
 

/*Static Function Grvsc8(cNUM,cNUMSC,cPRODUTO,cITEMSC)

	Local lRet := .T.
	Local cwf  :=""

	cQuery = " "	
	cQuery = " SELECT C8_FILIAL,C8_NUMSC,C8_ITEMSC "
	cQuery += " From " + RetSqlName("SC8") + " "
	cQuery += " WHERE C8_NUM='"+cNUM+"' AND C8_FILIAL='"+cfilant+"' "	
	cQuery += " AND D_E_L_E_T_<>'*' "

	If Select("TEMP15") > 0
		TEMP15->(dbCloseArea())
	EndIf

	cQuery  := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TEMP15",.T.,.F.)
	dbSelectArea("TEMP15")    
	TEMP15->(dbGoTop())

	While TEMP15->(!Eof())

		DbSelectArea("SC1")
		SC1->(dbSetOrder(1))     //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
		If SC1->(dbSeek(TEMP15->C8_FILIAL+TEMP15->C8_NUMSC+TEMP15->C8_ITEMSC))
		    cwf := SC1->C1_ZWFPC
		ENDIF
			
		//GRAVA SC8       
			_cQryCMP	:=" "
			_cQryCMP	:= " UPDATE " + RetSqlName("SC8") + " SET C8_ZWFPC='"+CWF+"' "
			_cQryCMP	+= " WHERE C8_NUMSC = '"+TEMP15->C8_NUMSC+"' AND C8_ITEMSC='"+TEMP15->C8_ITEMSC+"' AND C8_FILIAL='"+TEMP15->C8_FILIAL+"' "
			TcSqlExec(_cQryCMP)
			TEMP15->(dbSKIP())
	EndDo
  
Return lRet*/
