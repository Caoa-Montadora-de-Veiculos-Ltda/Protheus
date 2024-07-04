#Include "TopConn.ch"
#DEFINE CRLF  Char(13) + Char(10)

/* =====================================================================================
Programa.:              ZEICF017
Autor....:              CAOA - Valter Carvalho
Data.....:              15/11/2021
Descricao / Objetivo:   Insere a inf da cd5 para as notas filhas de container, e muda o tipo do documento para "C" 
                        para poder ser transmitido
Doc. Origem:            
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              mt103fimn
===================================================================================== */

USER FUNCTION ZEICF017()
     Local cAux   := ""
     Local cQr    := GetNextAlias()
     Local cmd    := ""
     Local areaD1 := SD1->(GetArea())
     
     DbSelectArea("SD1")
     DbSetOrder(1)

     DbSelectArea("CD5") // CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_ITEM
     DbSetOrder(4)

     SD1->(dbSeek(SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))

     cmd += CRLF + " SELECT DISTINCT  "
     cmd += CRLF + " W2_PO_NUM, W2_TIPO_EM, "
     cmd += CRLF + " W6_DI_NUM, W6_DTREG_D, W6_DT_DESE, W6_LOCAL,  "
     cmd += CRLF + " F1_COND, F1_SERIE, F1_DOC, ZM_INVOICE,W8_INVOICE,ZM_CONT , W8_HAWB,  "
     cmd += CRLF + " W6_UFDESEM "
     cmd += CRLF + " FROM " + RetSqlName("SW8") + " SW8 "
     cmd += CRLF + " LEFT JOIN " + RetSqlName("SW6") + " SW6 ON SW6.D_E_L_E_T_ = ' ' AND W6_FILIAL = W8_FILIAL AND W6_HAWB = W8_HAWB "
     cmd += CRLF + " LEFT JOIN " + RetSqlName("SW2") + " SW2 ON SW2.D_E_L_E_T_ = ' ' AND W6_FILIAL = W2_FILIAL AND W6_PO_NUM = W2_PO_NUM "
     cmd += CRLF + " LEFT JOIN " + RetSqlName("SF1") + " SF1 ON SF1.D_E_L_E_T_ = ' ' AND F1_FILIAL = W8_FILIAL AND F1_FORNECE = W8_FORN AND F1_LOJA = W8_FORLOJ AND F1_HAWB = W8_HAWB "
     cmd += CRLF + " LEFT JOIN " + RetSqlName("SZM") + " SZM ON SZM.D_E_L_E_T_ = ' ' AND ZM_FILIAL = W8_FILIAL AND ZM_INVOICE = W8_INVOICE  "
     cmd += CRLF + " WHERE  "
     cmd += CRLF + " SW8.D_E_L_E_T_ = ' '  "
     cmd += CRLF + " AND W8_HAWB = '" + SD1->D1_XCONHEC + "' "
     
     TcQuery cmd new alias (cQr)

     While (SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA) == SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)) 


          If CD5->(dbSeek(SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA) + SD1->D1_ITEM)) == .T.
		     RecLock("CD5", .F.)
		          CD5->(DbDelete())
		     CD5->(MsUnLock())
	     EndIf		                    

		RecLock("CD5", .T.)

               CD5->CD5_FILIAL := SF1->F1_FILIAL
               CD5->CD5_DOC    := SF1->F1_DOC
               CD5->CD5_SERIE  := SF1->F1_SERIE
               CD5->CD5_FORNEC := SF1->F1_FORNECE
               CD5->CD5_LOJA   := SF1->F1_LOJA
               CD5->CD5_ITEM   := SD1->D1_ITEM
               CD5->CD5_ESPEC  := SF1->F1_ESPECIE
               CD5->CD5_LOCDES := "PORTO SECO ANAPOLIS"
               CD5->CD5_INTERM := "1"   
               CD5->CD5_CODEXP := SF1->F1_FORNECE
               CD5->CD5_NADIC  := "1" 
               CD5->CD5_SQADIC := "1" 
               CD5->CD5_NDI    := (cQr)->W6_DI_NUM
               CD5->CD5_UFDES  := (cQr)->W6_UFDESEM

               cAux := (cQr)->W6_DTREG_D
               CD5->CD5_DTDI   := CTOD(Substr(cAux, 7, 2) + '/' + Substr(cAux, 5, 2) + '/' + Substr(cAux, 1, 4))
              
               cAux := (cQr)->W6_DT_DESE
               CD5->CD5_DTDES  := CTOD(Substr(cAux, 7, 2) + '/' + Substr(cAux, 5, 2) + '/' + Substr(cAux, 1, 4))

               CD5->CD5_CODFAB := SF1->F1_FORNECE
               CD5->CD5_VTRANS := IIF( (cQr)->W2_TIPO_EM = "M", "1", "2")          
          
          CD5->(MsUnLock())
          SD1->(DbSkip())
     EndDo          

     (cQr)->(DbCloseArea())
     SD1->(RestArea(areaD1))

     // efetua o ajuste do tipo do doc
     cmd := CRLF + " UPDATE " + RetSqlName("SF1") + " SET F1_TIPO = 'C' 
     cmd += CRLF + " WHERE D_E_L_E_T_ = ' ' "
     cmd += CRLF + " AND F1_FILIAL  = '" + SF1->F1_FILIAL + "' "
     cmd += CRLF + " AND F1_DOC     = '" + SF1->F1_DOC    + "' "
     cmd += CRLF + " AND F1_SERIE   = '" + SF1->F1_SERIE  + "' "
     cmd += CRLF + " AND F1_FORNECE = '" + SF1->F1_FORNECE+ "' "
     cmd += CRLF + " AND F1_LOJA    = '" + SF1->F1_LOJA   + "' "
     TCsqLeXEC(cmd)

     cmd := CRLF + " UPDATE " + RetSqlName("SD1") + " SET D1_TIPO = 'C' 
     cmd += CRLF + " WHERE D_E_L_E_T_ = ' ' "
     cmd += CRLF + " AND D1_FILIAL  = '" + SF1->F1_FILIAL + "' "
     cmd += CRLF + " AND D1_DOC     = '" + SF1->F1_DOC    + "' "
     cmd += CRLF + " AND D1_SERIE   = '" + SF1->F1_SERIE  + "' "
     cmd += CRLF + " AND D1_FORNECE = '" + SF1->F1_FORNECE+ "' "
     cmd += CRLF + " AND D1_LOJA    = '" + SF1->F1_LOJA   + "' "
     TCsqLeXEC(cmd)

Return
