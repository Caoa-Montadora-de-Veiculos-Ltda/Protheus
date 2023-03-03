#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'parmtype.ch'
/*/{Protheus.doc} U_ZFATF003
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	20/03/20
@return  	SX1 pergunta "ZFATF005  "
@obs       
@project
@history    carrega dados padrões para o acols do PV
/*/
User Function ZFATF003()
Local   _aArea   := GetArea()
Local   _cPerg   := "ZFATF005  "
Local   _nLaco   := 0
Local   _cTes    := " "
Local   _cLocal  := " "
Local   _cOperac := " "
Local   _cCusto  := " "

dbSelectArea( "SX1" )
dbSetOrder( 1 )

If !( DbSeek( _cPerg + '01'))
   //RecLock("SX1",.T.)
   //SX1->X1_TES   := _cTes   
   //SX1->X1_LOCAL := _cLocal
   //SX1->X1_OPER  := _cOperac
   //SX1->X1_CCUS  := _cCusto
   //MsUnlock()	
Else
   For _nLaco := 1 to 04    //Numero de perguntas no SX1
      DO CASE
      CASE _nLaco = 1
         RecLock("SX1",.F.)
         SX1->X1_CNT01 := _cTes
         MsUnlock()
      CASE _nLaco = 2
         DbSeek( _cPerg + '02')
         RecLock("SX1",.F.)
         SX1->X1_CNT01 := _cLocal
         MsUnlock()
      CASE _nLaco = 3
         DbSeek( _cPerg + '03')
         RecLock("SX1",.F.)
         SX1->X1_CNT01 := _cOperac 
         MsUnlock()
      CASE _nLaco = 4
         DbSeek( _cPerg + '04')
         RecLock("SX1",.F.)
         SX1->X1_CNT01 := _cCusto 
         MsUnlock()
      ENDCASE
   Next

EndIF

RestArea(_aArea)
Return(.T.)