#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 

/*
=====================================================================================
Programa.:              ZFISF003
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              04/02/2020
Descricao / Objetivo:   Tela para alterar parametros do fechamento
Doc. Origem:            
Solicitante:            
Uso......:              Faturamento
Obs......:
=====================================================================================
*/

// Disponibilizacao de alteracao dos Parametros
// MV_DATAFIN = Financeiro
// MV_DATAFIS = Faturamento/Compras
// Pelo Usuario Contabil

User Function ZFISF003()

Local lUserAut    := .F.
Private dDataFin  := GETMV("MV_DATAFIN")
Private dDataFis  := GETMV("MV_DATAFIS")
Private dDataMov  := GETMV("MV_DBLQMOV")
Private oDlgFecha

lUserAut := U_ZGENUSER( RetCodUsr() ,"ZFISF003"	,.T.)

If lUserAut
  
  SET CENTURY ON
  @ 227,199 To 404,629 Dialog oDlgFecha Title OemToAnsi("Fechamento.")
  @ 9,5   Say OemToAnsi("Esta rotina tem  objetivo de permitir o Fechamento/Abertura das operações do") Size 214,18
  @ 23,4  Say OemToAnsi("SIGAFIN, SIGAFIS e SIGAEST, não permitindo alteracoes com data igual ou inferior a mencionada nos parâmetros abaixo:") Size 214,14
  @ 42,20 Say OemToAnsi("Data Limite FIN")      Size 78,08
  @ 53,20 Say OemToAnsi("Data Limite FIS")      Size 78,08
  @ 64,20 Say OemToAnsi("Data Limite EST BLQ")  Size 78,08
  @ 41,98 Get dDataFin Size 76,10
  @ 52,98 Get dDataFis Size 76,10
  @ 63,98 Get dDataMov Size 76,10
  @ 75,96  BMPBUTTON TYPE 1 ACTION GRVFEC()         OBJECT oButtOK
  @ 75,138 BMPBUTTON TYPE 2 ACTION FECHADLG()       OBJECT oButtCc
  ACTIVATE DIALOG oDlgFecha CENTERED

Endif  

Return Nil

Static Function GRVFEC()            

  PUTMV("MV_DATAFIS",dDatafis)
  PUTMV("MV_DATAFIN",dDatafin)
  PUTMV("MV_DBLQMOV",dDataMov)

  SET CENTURY OFF
  Alert("Alteracao Efetuada!","Ok","INFO")
  Close(oDlgFecha)

Return Nil                      


Static Function FECHADLG()                   
  SET CENTURY OFF
  Close(oDlgFecha)
Return Nil

