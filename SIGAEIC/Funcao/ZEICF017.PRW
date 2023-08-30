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
     Local cAux        := ""
     Local cQr         := GetNextAlias()
     Local cmd         := ""
     Local areaD1      := SD1->(GetArea())
     Local nCD5_VTRANS := 0
     Local nCD5_VAFRMM := 0
     Local TRFILIAL    := '' 
     Local TRDOC       := '' 
     Local TRSERIE     := '' 
     Local TRFORN      := ''
     Local TRLOJA      := ''
     Local TRHawb      := ''
     Local TRXCONT     := ''
     
     DbSelectArea("SD1")
     DbSetOrder(1)

     DbSelectArea("CD5") // CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_ITEM
     DbSetOrder(4)

     /*IF ctipo = "I"

         SD1->(dbSeek(SD1->(D1_FILIAL + D1_NFORI + D1_SERIORI + D1_FORNECE + D1_LOJA)))
         TRFILIAL := SD1->D1_FILIAL 
         TRDOC    := SD1->D1_NFORI
         TRSERIE  := SD1->D1_SERIORI
         TRFORN   := SD1->D1_FORNECE
         TRLOJA   := SD1->D1_LOJA
         TRHawb   := _cHawb
         TRXCONT  := SD1->D1_XCONT

     ELSE*/
          
         SD1->(dbSeek(SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))
         TRFILIAL := SD1->D1_FILIAL 
         TRDOC    := SD1->D1_DOC
         TRSERIE  := SD1->D1_SERIE
         TRFORN   := SD1->D1_FORNECE
         TRLOJA   := SD1->D1_LOJA
         TRHawb   := SF1->F1_HAWB
         TRXCONT  := SD1->D1_XCONT
         cWhereA  := ''
     
     //ENDIF

     cmd := CRLF + " SELECT DISTINCT "
     cmd += CRLF + " W2_PO_NUM, W2_TIPO_EM,
     cmd += CRLF + " W6_DI_NUM, W6_DTREG_D, W6_DT_DESE, W6_LOCAL, W6_LOCALN, W6_UFDESEM, W6_VIA_TRA VIA_TRA,"
     cmd += CRLF + " F1_COND, F1_SERIE, F1_DOC, ZM_INVOICE, W8_HAWB, W8_FABLOJ "
     cmd += CRLF + " FROM " + RetSqlName("SZM") + " SZM "
     cmd += CRLF + " LEFT JOIN " + RetSqlName("SW8") + " SW8 ON SW8.D_E_L_E_T_ = ' ' AND W8_FILIAL = ZM_FILIAL AND W8_INVOICE = ZM_INVOICE 
     cmd += CRLF + " LEFT JOIN " + RetSqlName("SW6") + " SW6 ON SW6.D_E_L_E_T_ = ' ' AND W6_FILIAL = W8_FILIAL AND W6_HAWB = W8_HAWB
     cmd += CRLF + " LEFT JOIN " + RetSqlName("SW2") + " SW2 ON SW2.D_E_L_E_T_ = ' ' AND W6_FILIAL = W2_FILIAL AND W6_PO_NUM = W2_PO_NUM
     cmd += CRLF + " LEFT JOIN " + RetSqlName("SF1") + " SF1 ON SF1.D_E_L_E_T_ = ' ' AND W8_FILIAL = F1_FILIAL AND W8_FORN = F1_FORNECE AND W8_FORLOJ = F1_LOJA AND F1_HAWB = W8_HAWB
     cmd += CRLF + " WHERE "
     cmd += CRLF + " SZM.D_E_L_E_T_ = ' ' "
     cmd += CRLF + " AND ZM_CONT = '" + TRXCONT + "'   

     TcQuery cmd new alias (cQr)

     While SD1->D1_FILIAL = TRFILIAL .AND. SD1->D1_DOC = TRDOC .AND. SD1->D1_SERIE = TRSERIE .AND. SD1->D1_FORNECE = TRFORN .AND. SD1->D1_LOJA = TRLOJA

          If CD5->(dbSeek((TRFILIAL + TRDOC + TRSERIE + TRFORN + TRLOJA) + SD1->D1_ITEM)) = .T.
		     RecLock("CD5", .F.)
		          CD5->(DbDelete())
		     CD5->(MsUnLock())
	     EndIf		                    

		RecLock("CD5", .T.)

               CD5->CD5_FILIAL := TRFILIAL
               CD5->CD5_DOC    := TRDOC
               CD5->CD5_SERIE  := TRSERIE
               CD5->CD5_FORNEC := TRFORN
               CD5->CD5_LOJA   := TRLOJA
               CD5->CD5_ITEM   := SD1->D1_ITEM
               CD5->CD5_ESPEC  := CESPECIE
               CD5->CD5_LOCDES := (cQr)->W6_LOCALN  //"PORTO SECO ANAPOLIS"
               CD5->CD5_CODEXP := TRFORN
			CD5->CD5_LOJEXP := TRLOJA
			CD5->CD5_DOCIMP := (cQr)->W8_HAWB
               CD5->CD5_NADIC  := '1' 
    			CD5->CD5_LOCAL  := '0'
			CD5->CD5_TPIMP  := '0'
			CD5->CD5_INTERM := '1'
			CD5->CD5_SQADIC := '001'

               CD5->CD5_NDI    := (cQr)->W6_DI_NUM
               CD5->CD5_UFDES  := (cQr)->W6_UFDESEM

               cAux := (cQr)->W6_DTREG_D
               CD5->CD5_DTDI   := CTOD(Substr(cAux, 7, 2) + '/' + Substr(cAux, 5, 2) + '/' + Substr(cAux, 1, 4))
              
               cAux := (cQr)->W6_DT_DESE
               CD5->CD5_DTDES  := CTOD(Substr(cAux, 7, 2) + '/' + Substr(cAux, 5, 2) + '/' + Substr(cAux, 1, 4))

               CD5->CD5_CODFAB := TRFORN
               CD5->CD5_LOJFAB := (cQr)->W8_FABLOJ
               
			If (cQr)->VIA_TRA = 'M'
				nCD5_VTRANS := '1 '
				nCD5_VAFRMM := Posicione("SWD", 1, SD1->D1_FILIAL + TRHAWB + '405', "WD_VALOR_R")
			ElseIf (cQr)->VIA_TRA = 'A' 
				nCD5_VTRANS := '4 '
			EndIf  

               CD5->CD5_VTRANS := nCD5_VTRANS
               CD5->CD5_VAFRMM := nCD5_VAFRMM
  
          CD5->(MsUnLock())
          SD1->(DbSkip())
     EndDo          

     (cQr)->(DbCloseArea())
     SD1->(RestArea(areaD1))

     // efetua o ajuste do tipo do doc
     cmd := CRLF + " UPDATE " + RetSqlName("SF1") + " SET F1_TIPO = 'C' 
     cmd += CRLF + " WHERE D_E_L_E_T_ = ' ' "
     cmd += CRLF + " AND F1_FILIAL  = '" + TRFILIAL + "' "
     cmd += CRLF + " AND F1_DOC     = '" + TRDOC    + "' "
     cmd += CRLF + " AND F1_SERIE   = '" + TRSERIE  + "' "
     cmd += CRLF + " AND F1_FORNECE = '" + TRFORN   + "' "
     cmd += CRLF + " AND F1_LOJA    = '" + TRLOJA   + "' "
     TCsqLeXEC(cmd)

     cmd := CRLF + " UPDATE " + RetSqlName("SD1") + " SET D1_TIPO = 'C' 
     cmd += CRLF + " WHERE D_E_L_E_T_ = ' ' "
     cmd += CRLF + " AND D1_FILIAL  = '" + TRFILIAL + "' "
     cmd += CRLF + " AND D1_DOC     = '" + TRDOC    + "' "
     cmd += CRLF + " AND D1_SERIE   = '" + TRSERIE  + "' "
     cmd += CRLF + " AND D1_FORNECE = '" + TRFORN   + "' "
     cmd += CRLF + " AND D1_LOJA    = '" + TRLOJA   + "' "
     TCsqLeXEC(cmd)

Return
