#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH' 
#Include "TopConn.ch"
#include "rwmake.ch"
#include "TOTVS.ch"

/*/{Protheus.doc} MT094LOK
@author     Sandro Ferreira   
@since 		05/05/2022
@param     	 
@return    	Return (cCampos)
@project    CAOA
@version 	1.0
@obs        Chamado pelo PE MATA094 para mostrar campos da SCR na tela
@history    
/*/

User Function MT094LOK() 

Local lRetorno    := .T. 
Local cNum        := ""
Local cQry        := ""
Local cQry1       := ""
Local cVLIBER    
Local CONTRATO    := GetNextAlias()
Local LIMPEZA     := GetNextAlias()
Local cChave      := ""
Local _cEmp       := FWCodEmp()
Local aArea	      := GetArea()

   If _cEmp == "2010" //Executa o p.e. Anapolis.

      cFILIAL          := SCR->CR_FILIAL
      cNum             := SCR->CR_NUM
      
      //Rotina executada somente para contratos de parcerias
      If SCR->CR_TIPO = 'CP' 
         //Limpa o campo SCR->CR_XVLLIB para reprocessar os valores dos contratos de parcerias
         cChave := SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM
         cQry :=  ""
         cQry :=  "  SELECT CR_FILIAL, CR_NUM  FROM " +  RetSQLName("SCR")   + " SCR "                        + CRLF
         cQry +=  "  WHERE  SCR.D_E_L_E_T_  = ' '  AND SCR.CR_NUM =  '"      + cNUM  + "'"                    + CRLF
         cQry +=  "  ORDER BY CR_FILIAL, CR_NUM             "                                                 + CRLF
         cQry := ChangeQuery(cQry)
         DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"LIMPEZA",.T.,.T.)

         dbSelectArea("LIMPEZA")
         LIMPEZA->(dbGoTop())
         IF LIMPEZA->(!EOF())
            While LIMPEZA->(!EOF())
               If SCR->(dbSeek(xFilial("SCR")+"CP"+LIMPEZA->CR_NUM))
                  While SCR->(!EOF()) .AND. SCR->CR_FILIAL = LIMPEZA->CR_FILIAL .AND. SCR->CR_NUM = LIMPEZA->CR_NUM
                     RecLock( ("SCR"), .F. )
                        SCR->CR_XVLLIB := 0
                        MsUnlock()
                     SCR->(dbSkip())
                  EndDo
               Endif
               LIMPEZA->(dbSkip())
            ENDDO   
         ENDIF
         LIMPEZA->(DbCloseArea())

         //Verifica se existe contratos com as datas validas para somar os valores pendentes
         SCR->(dbSeek(cChave))
         cQry := ""
         cQry := "  SELECT C3_FILIAL, C3_NUM FROM " + RetSQLName("SC3") + " SC3A ," + RetSQLName("SCR") + " SCR " + CRLF                                                     + CRLF
         cQry += "  WHERE   SC3A.C3_FILIAL    = SCR.CR_FILIAL  AND  SC3A.C3_NUM  = SCR.CR_NUM  "                  + CRLF
         cQry += "  AND     SC3A.D_E_L_E_T_   = ' ' AND SCR.D_E_L_E_T_  = ' '  AND SC3A.C3_ENCER <> 'E' "         + CRLF
         cQry += "  AND     SC3A.C3_DATPRF   >= '" +  DTOS( dDataBase  )  + "' AND SC3A.C3_NUM = '" + cNum + "'"  + CRLF
         cQry += "  ORDER BY C3_FILIAL, C3_NUM             "                                                      + CRLF
         cQry := ChangeQuery(cQry)
         DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"CONTRATO",.T.,.T.)
         
         //totaliza os valores pendentes dos contratos pendentes 
         dbSelectArea("CONTRATO")
         CONTRATO->(dbGoTop())
         IF CONTRATO->(!EOF())
            While CONTRATO->(!EOF())
               cVLIBER   := GetNextAlias()
               cQry1 :=  " SELECT SUM(C3_TOTAL) AS nTOTAL FROM " + RetSQLName("SC3")       + " SC3B "    + CRLF
               cQry1 +=  " WHERE SC3B.D_E_L_E_T_  = ' ' AND SC3B.C3_DATPRF >= '" + DTOS(dDataBase) + "'" + CRLF
               cQry1 +=  " AND   SC3B.C3_FILIAL   =  '" +   CONTRATO->C3_FILIAL            + "'"         + CRLF
               cQry1 +=  " AND   SC3B.C3_NUM      =  '" +   CONTRATO->C3_NUM               + "'"         + CRLF
               cQry1 := ChangeQuery(cQry1)
               DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry1),"cVLIBER",.T.,.T.)
               
               If SCR->(dbSeek(xFilial("SCR")+"CP"+CONTRATO->C3_NUM))
                  While SCR->(!EOF()) .AND. SCR->CR_FILIAL = CONTRATO->C3_FILIAL .AND. SCR->CR_NUM = CONTRATO->C3_NUM
                     RecLock( ("SCR"), .F. )
                        SCR->CR_XVLLIB := cVLIBER->nTOTAL
                     MsUnlock()
                     SCR->(dbSkip())
                  EndDo
               Endif

               cVLIBER->(DbCloseArea())
               
               //Ler o próximo contrato
               CONTRATO->(dbSkip())
            END   
            SCR->(dbSeek(cChave))
         ENDIF
         CONTRATO->(DbCloseArea())
      ENDIF
   EndIf

   RestArea(aArea)

Return( lRetorno ) 
