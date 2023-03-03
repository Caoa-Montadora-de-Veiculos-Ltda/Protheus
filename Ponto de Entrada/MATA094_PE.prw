#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH' 
#Include "TopConn.ch"
#Include "TBICONN.CH"
#include "rwmake.ch"
#include "TOTVS.ch"
#Include "DBSTRUCT.CH"
#Include "MSGRAPHI.CH"
#Include "Eicsi400.ch"
#Include "AvPrint.ch"
#Include "FWBROWSE.CH"
#Include "FWFILTER.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} MATA094
@author     A.Carlos
@since 		19/04/2021
@param     	_aParam - 
@return    	Logico
@project    CAOA
@menu       Nao Informado
@version 	1.0
@obs        Chamado pelo Ponto de Entrada PE_MATA094
@history    
/*/ 
//-------------------------------------------------------------------
  
User Function MATA094()
Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''                            

Local lIsGrid    := .F.
 
LOCAL cNum       := ""
LOCAL cTipo      := ""
LOCAL nTotal     := 0

If aParam <> NIL

    oObj       := aParam[1]
    cIdPonto   := aParam[2]
    cIdModel   := aParam[3]
    lIsGrid    := ( Len( aParam ) > 3 )
    
    cFILIAL := SCR->CR_FILIAL
    cNum    := SCR->CR_NUM
    cTipo   := SCR->CR_TIPO
    nTotal  := SCR->CR_TOTAL 
    nNivel  := "  "
    aArea   := {}

    IF cIdPonto == 'BUTTONBAR'
    
        If SCR->CR_TIPO = 'PC' 

            xRet := { {'Caoa - VISUALIZAR PC', 'VISUALIZAR PC'    ,    { || A097Visual(,,2) }, 'Botao Visualiza' }, ;
                      {'Caoa - Observação PC' , 'Caoa Ver Obs Ped',    { || zVerObsPC()     }, ''                }  ;
                    }

            zVerObsPC()

        EndIf

        If SCR->CR_TIPO = 'CP' 

            xRet := { {'Caoa - VISUALIZAR CP', 'VISUALIZAR CP'    ,    { || A097Visual(,,2) }, 'Botao Visualiza' }, ;
                      {'Caoa - Observação CP', 'Caoa Ver Obs CP'  ,    { || zVerObsCP()     }, ''                }  ;
                    }

            zVerObsCP()

        EndIf



    ENDIF
EndIf
 
Return(xRet)


/*=====================================================================================
Programa.:              zDadoVlPO / zVerObsPC
Autor....:              CAOA - Valter Carvalho
Data.....:              14/10/2021
Descricao / Objetivo:   exibir os dados do valor da Po na aprocação do Pedido, no momento que clica no botao de aprovar
Solicitante:            Julia Alcantara / Aide
Uso......:              EICPO400_MVC          
===================================================================================== */

Static Function zVerObsPC()
    Local cMsg := ""
  
    DbSelectArea("SW2")
    SW2->(DbSetOrder(1))

    if SW2->(DbSeek(xFilial("SW2") + SC7->C7_NUMIMP)) = .T.
        
        cMsg := "Moeda PO:" + SW2->W2_MOEDA + " - " + GetAdvFVal("SYF", "YF_DESC_SI", xFilial("SYF") + SW2->W2_MOEDA, 1, " ") + CRLF
        cMsg += "Valor PO:" + Transform(SW2->W2_FOB_TOT, PesqPict( "SW2", "W2_FOB_TOT") )
        
        cMsg += CRLF + CRLF + CRLF + PadR("", 65, "*") + CRLF + CRLF 

        If Vazio(SW2->W2_XOBSPED) = .F. 

            cMsg += "Observação Pedido:"
            cMsg += CRLF + PadR("", 65, "-")
            cMsg += CRLF + SW2->W2_XOBSPED

            cMsg += CRLF + CRLF + CRLF + PadR("", 65, "*") + CRLF + CRLF 

            If Vazio(SC7->C7_NUMIMP) = .F.
                cMsg += "Observação PO(" + Alltrim(SC7->C7_NUMIMP) + "): "
                cMsg += CRLF + PadR("", 65, "-")
                cMsg += CRLF + MSMM(SW2->W2_OBS)
            EndIf

        EndIf        
 
    Else

        cMsg += "Observação Pedido:"
        cMsg += CRLF + PadR("", 65, "-")
        cMsg += CRLF + SC7->C7_XOBSTST

        cMsg += CRLF + CRLF + CRLF + PadR("", 65, "*") + CRLF + CRLF 

        If Vazio(SC7->C7_NUMIMP) = .F.
            cMsg += "Observação compras:"
            cMsg += CRLF + PadR("", 65, "-")
            cMsg += CRLF + SC7->C7_XOBSCOM
        EndIf
        
    Endif    

    If Vazio (cMsg) = .F.
        EecView(cMsg, "Observações do PC" + SC7->C7_NUM)
    EndIf

Return


/*=====================================================================================
Programa.:              MATA094 / zVerObsCP
Autor....:              CAOA - Sandro Ferreira
Data.....:              14/01/2022
Descricao / Objetivo:   exibir os dados do contrato de parceria na aprocação, no momento que clica no botao de aprovar
Solicitante:            Julia Alcantara / Aide
Uso......:              MATA094          
===================================================================================== */

Static Function zVerObsCP()
    Local cMsg := ""
  
    //Observação do contrato de parceria
    IF SCR->CR_TIPO = 'CP'

       cMsg += "Observação Contrato:"
       cMsg += CRLF + PadR("", 65, "-")
       cMsg += CRLF + SC3->C3_XOBSCOP

       cMsg += CRLF + CRLF + CRLF + PadR("", 65, "*") + CRLF + CRLF 

       If Vazio (cMsg) = .F.
          EecView(cMsg, "Observações do Contrato de Parceria:  " + SCR->CR_NUM)
       EndIf

    ENDIF

Return
