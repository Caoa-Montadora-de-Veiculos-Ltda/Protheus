#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

User Function OX001AP()
Local _aParam  	:= PARAMIXB
Local _aRet		:= {}
Local _aValida  := {}
Local _nPos
Local _nCount

Begin Sequence

	If _aParam == NIL
		Break
	endIf
	_aRet := _aParam[1] //array montado para gravação MATA261	
	//somente chamada pelo programa que gera a onda
   	If !FindFunction("U_ZPECF008")
		Break
   	endIf

	For _nPos := 1 To Len(_aRet)
		_aValida := _aRet[_nPos]
		For _nCount := 1 To Len(_aValida)
			//Tem que estar preenchido
			If Empty(_aValida[_nCount]) .and. _nCount <> 5 .and. _nCount <> 10  //deixo de fora local do SDB nem sempre é preenchido
				_aRet := {}
				If Type("_aMensAglu") == "A"
					Aadd(_aMensAglu, "Problemas na montagem para ExecAuto MATA261, verificar se produto e grupo estão cadastrados em Produtos !")
				EndIf
				Break
			Endif	
			If _nCount >= 10 //10 é a indicação de produto de origem e produto de destino não podem voltar vazio
				Exit
			Endif
		Next _nCount
	Next _nPos
End Sequence		
Return _aRet
 

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
