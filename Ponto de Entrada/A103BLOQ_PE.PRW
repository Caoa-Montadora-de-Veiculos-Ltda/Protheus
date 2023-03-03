/*/{Protheus.doc}  
@param  	 
@author 	   Sandro Ferreira
@version  	P12.1.25
@since  	   06/04/2022
@return  	NIL
@obs        PE p/ a NFe entrarem bloqueadas caso ocorra divergência entre o valores dos pedidos de compras
@project    Usado no processo de Recebimento (SINC)
@history    também para a validação de Divergência no Valor de Entrada NF x PC. (06/04/2022)

No Parametro informar no parâmetro MV_NFAPROV o número do grupo de aprovação para liberação dos documentos entradas;
/*/

User Function  A103BLOQ()
   
   Local _cEmp    := FWCodEmp()
   Local _lRet	   := PARAMIXB[1] 
   Local aArea	   := GetArea()

   If _cEmp == "2010" //Executa o p.e. Anapolis.
      _lRet	   := zMontadora()
   Else
      _lRet  := zCaoaSp() //Executa o p.e. Barueri
   EndIf

   RestArea(aArea)

Return(_lRet)

/*
==============================================================================================
Programa.:              zMontadora
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada Montadora
===============================================================================================
*/
Static Function zMontadora()

Local lRet     := PARAMIXB[1] 
Local  nVlMai  := 0
Local  nvlMen  := 0 
Local  cCod      := " "
Local  cPed      := " "
Local  cFornec   := " "
Local  cItem     := " "
Local  cImport   := .F.
Local  nValor    := 0
Local  nLinha    := 0
Local  cMsg      := .F.
Local _aArea     := GetArea()
Local aAreaSD1	  := SD1->(GetArea())

Local _nPosCod   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_COD'   })
Local _nPosPed   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_PEDIDO'})
Local _nPosIte   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_ITEMPC'})
Local _nPosVlr   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_VUNIT' })
Local _nPosForne := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_FORNECE' })

IF IsInCallStack("U_ZESTF006")
   lRet := .F.
ENDIF


For nLinha := 1 to Len(aCols)
   If !aCols[nLinha][Len(aHeader)+1]
       cCod    := aCols[nLinha, _nPosCod ]
       cPed    := aCols[nLinha, _nPosPed ] 
       cItem   := aCols[nLinha, _nPosIte ] 
       nValor  := aCols[nLinha, _nPosVlr ] 
       cFornec := aCols[nLinha, _nPosForne ] 

       //Caso a nota fiscal esteja bloqueada, será veficado se houve ajuste no pedido de compras
       DbSelectArea("SC7")
       SC7->(DbSetOrder(19))
       IF SC7->(DbSeek(xFilial("SC7") + cCod + cPed + cItem))
         If SC7->C7_ORIGEM = 'EICPO400'
             cImport := .T.
             nLinha := Len(aCols) + 1
             lRet := .F.
         Endif
         If cImport == .F.
             nVlMai := ( nValor - SC7->C7_PRECO )
             IF nVlMai < 0
                nVlMai := nVlMai * -1
             Endif
             nVlMen := ( SC7->C7_PRECO - nValor )
             If nVlmen < 0
                nVlMen := nVlMen * -1
             Endif  
                 
             IF (((( nValor >= SC7->C7_PRECO ) .AND.   nValor <= (SC7->C7_PRECO + ((SC7->C7_PRECO / 100) * AIC->AIC_PPRECO ))) .OR. ;
                (( nValor <= SC7->C7_PRECO ) .AND.   nValor >= (SC7->C7_PRECO - ((SC7->C7_PRECO / 100) * AIC->AIC_PPRECO )))) .and.;
                ( ( nVlMai < AIC->AIC_XTVAL  )          .OR.    ( nVlMen < AIC->AIC_XTVAL ) ) ) 
                lRet := .F. //As notas fiscais Não serão Bloqueadas
             ELSE
                cMsg := .T.
             ENDIF
         ENDIF
      ENDIF
   ENDIF
Next nLinha

If cMsg
   MSGINFO( 'Divergência no Valor de Entrada NF com PC, N.F. Bloqueada.', 'Atenção' )
   RecLock("SF1",.F.)
   SF1->F1_STATUS := 'B'
   SF1->(MsUnlock())
   lRet := .T.  //As notas fiscais Serão Bloqueadas
Endif


SD1->(RestArea(aAreaSD1))
RestArea(_aArea)

Return(lRet) 

/*
==============================================================================================
Programa.:              zMontadora
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada Montadora
===============================================================================================
*/
Static Function zCaoaSp()

   Local lRet     := PARAMIXB[1] // Recebe o Resultado da Regra do Sistema // Rotina do usuário
   Local nPercT   := 0
   Local _aArea   := GetArea()
   Local aAreaSD1 := SD1->(GetArea())

   IF IsInCallStack("U_ZESTF006")
      lRet           := .F.
   ENDIF

   IF INCLUI .AND. lRet = .T.
      nPercT         := ((AIC->AIC_PPRECO * SD1->D1_TOTAL) / 100)
      IF nPercT < AIC->AIC_XTVAL .OR. nPercT > AIC->AIC_XTVAL
         MSGINFO( 'Divergência no Valor de Entrada NF x PC. ' , 'Atenção' )
      ENDIF
   ENDIF

   SD1->(RestArea(aAreaSD1))
   RestArea(_aArea)

Return(lRet)
