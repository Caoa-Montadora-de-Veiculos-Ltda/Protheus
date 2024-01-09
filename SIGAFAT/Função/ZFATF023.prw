#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 
/*
=====================================================================================
Programa.:              ZFATF023
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              09/01/2024
Descricao / Objetivo:   Tela para alterar parametros de percentual de Comissão do PV
Doc. Origem:            
Solicitante:            
Uso......:              Faturamento
Obs......:
=====================================================================================
*/

// Disponibilizacao de alteracao dos Parametros
// CMV_FAT014 = % p/ comissao tipo venda 2, 3, 5                  
// CMV_FAT015 = % p/ comissao tipo venda 4 e codigo marca HYU/CHE 
// CMV_FAT016 = % p/ comissao subaru (SBR)                           
// CMV_FAT017 = % p/ comissao subaru (SBR) e modelo Forester        

// Pelo Usuario Comercial

User Function ZFATF023()

Local lUserAut   := .F.
Private nFAT014  := GETMV("CMV_FAT014")
Private nFAT015  := GETMV("CMV_FAT015")
Private nFAT016  := GETMV("CMV_FAT016")
Private nFAT017  := GETMV("CMV_FAT017")

Private oDlgFecha

lUserAut := U_ZGENUSER( RetCodUsr() ,"ZFATF023"	,.T.)

If lUserAut
  
  SET CENTURY ON
  @ 227,199 To 404,629 Dialog oDlgFecha Title OemToAnsi("Parâmetros.")
  @ 7,5   Say OemToAnsi("Esta rotina tem O objetivo de permitir a alteração dos Parâmetros de ") Size 214,18
  @ 17,4  Say OemToAnsi("percentual de comissão no Pedido de Venda.") Size 214,14
  @ 34,20 Say OemToAnsi("FAT014 T.V. 2, 3, 5 ")                       Size 78,08
  @ 45,20 Say OemToAnsi("FAT015 T.V. 4 HYU/CHE ")                     Size 78,08
  @ 54,20 Say OemToAnsi("FAT016 subaru (SBR)   ")                     Size 78,08
  @ 65,20 Say OemToAnsi("FAT017 SBR mod Forester ")                   Size 78,08  
  @ 34,98 Get nFAT014 Size 76,10
  @ 45,98 Get nFAT015 Size 76,10
  @ 54,98 Get nFAT016 Size 76,10
  @ 65,98 Get nFAT017 Size 76,10  
  @ 78,96  BMPBUTTON TYPE 1 ACTION GRVPAR()         OBJECT oButtOK
  @ 78,138 BMPBUTTON TYPE 2 ACTION FECHADLG()       OBJECT oButtCc
  ACTIVATE DIALOG oDlgFecha CENTERED

Endif  

Return Nil

Static Function GRVPAR()            

  PUTMV("CMV_FAT014",nFAT014)
  PUTMV("CMV_FAT015",nFAT015)
  PUTMV("CMV_FAT016",nFAT016)
  PUTMV("CMV_FAT017",nFAT017) 

  SET CENTURY OFF
  Alert("Alteracao Efetuada ! "," Ok "," INFO ")
  Close(oDlgFecha)

Return Nil                      
 

Static Function FECHADLG()                   
  SET CENTURY OFF
  Close(oDlgFecha)
Return Nil
