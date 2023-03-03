/* =====================================================================================
Programa.:              ZEICF013
Autor....:              CAOA - Valter Carvalho
Data.....:              15/12/2020
Descricao / Objetivo:   Na tela de adicoes de desembarque, efetua o restore das adicoes que estavam salvas
                        Ao alterar as regras de tributacao
Doc. Origem:            
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              TELA DE MANUTENCAO DE DESEMBARACO
===================================================================================== */

User function ZEICF013()
     Local idxCp        := 0
     Local i            := 1
     Local aCpEij       := EIJ->(DbStruct())
     Local aCpWork      := WORK_EIJ->(DbStruct())
     Local aOrd         := SaveOrd({"Work_EIJ", "EIJ"})
     
     WORK_EIJ->(DbGoTop())    
     While WORK_EIJ->(EOF()) = .F.
          
          If EIJ->(DbSeek( cFilant + SW6->W6_HAWB + WORK_EIJ->(EIJ_ADICAO) )) = .F.  // EIJ_FILIAL+EIJ_HAWB+EIJ_ADICAO+EIJ_PO_NUM
               WORK_EIJ->(DbSkip())    
               loop
          EndIf       

          RecLock("WORK_EIJ", .F.)
               
               For i:=1 to Len(aCpEij)
                    
                    idxCp := aScan(aCpWork, {|aCampo|  aCampo[1] == aCpEij[i,1] })
                    
                    If  idxCp = 0
                         loop
                    EndIf

                    WORK_EIJ->&(aCpWork[idxCp, 1]) := EIJ->&(aCpEij[I, 1])
               Next

          MsUnlock()

          WORK_EIJ->(DbSkip())    
     EndDo    

     RestOrd(aOrd, .T.)

return
