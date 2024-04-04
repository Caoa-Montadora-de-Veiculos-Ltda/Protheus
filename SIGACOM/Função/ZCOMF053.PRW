#Include 'Rwmake.ch'
#Include 'TopConn.ch'

#DEFINE cFONT   '<b><font size="3" color="blue"><b>'
#DEFINE cALERT  '<b><font size="3" color="red"><b>'
#DEFINE cNOFONT '</b></font></b></u>'

/*/{Protheus.doc} ZCOMF053
@author A.Carlos
@since 	27/04/2023
@version 1.0
@return ${return}, ${return_description}
@obs	
@history    Chamado pelo PE SF1140I
@type function
/*/
User Function ZCOMF053()
	Local lRet := .T.
	Local i    := 0
	Local cArquivo
	Local cChave
	Local cFor
	Local nIndex

	DbSelectArea('SD1')
	cArquivo := CriaTrab(,.F.)
	cChave   := 'D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM'
	cFor     := '!Empty(D1_ITEM)'
    IndRegua('SD1',cArquivo,cChave,,cFor)
	DbSelectArea('SD1')
	nIndex := RetIndex('SD1')
	#IFNDEF TOP
	DbSetIndex(cArquivo+OrdBagExt())
	#ENDIF
	DbSetOrder(nIndex+1)

	//SD1->(DBSETORDER(1))
    If ( SD1->(DbSeek(FWxFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )))

		While (SD1->D1_FILIAL = xFilial("SD1") .AND. SF1->F1_DOC = SD1->D1_DOC .AND. SF1->F1_SERIE = SD1->D1_SERIE .AND. SF1->F1_FORNECE = SD1->D1_FORNECE .AND. SF1->F1_LOJA = SD1->D1_LOJA)     
            i++
            IF SD1->D1_ITEM <> StrZero(i,4)

				IF !DELETED() 
					RecLock("SD1", .F.)
					SD1->D1_ITEM := StrZero(i,4)
					SD1->( MsUnLock() )
				else
					RecLock("SD1", .F.)
					SD1->D1_ITEM := '9'+StrZero(i,3)
					SD1->( MsUnLock() )				
				ENDIF

            ENDIF

			SD1->(dbSkip())
		end

	EndIf

	DbSelectArea('SD1')
    RetIndex('SD1')
    FErase(cArquivo+OrdBagExt())

Return lRet

