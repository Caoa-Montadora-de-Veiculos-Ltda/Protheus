#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'parmtype.ch'

/*/{Protheus.doc} U_ZFATF004
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	20/03/20
@return  	Preço Unitário no Pedido de Vendas (B2_CM1)
@obs       
@project
@history    usado como gatilho no acols do PV
/*/
User Function ZFATF004()
Local _aArea      := GetArea()
Local cAliasQry   := GetNextAlias()
Local _cPC        := Space(6)
Local _cTipo      := Space(2)
Local _cGrupo     := Space(4)
Local _nPunit     := 0
Local _nK         := 0
Local _cQry       := " "
Local _cColPR     := " "
Local _nPosPr     := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_PRODUTO' })
Local _nPosPU     := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_PRCVEN' })
Local _nPosTes    := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_TES' })
Local _nPosLoc    := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_LOCAL' })
Local _nPosOper   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_OPER' })
Local _nPosCC     := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_CC' })
Local _nPosCLVL   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_CLVL' })
Local _nPosItCt   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_ITEMCTA' })
Local _nPosLiz    := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_LOCALIZ' })

Local _cPerg      := "ZFATF005  "
Private _cTes     := space(03)
Private _cLocal   := space(03)
Private _cOperac  := space(02)
Private _cCusto   := space(11)
Private _cCLVL    := space(11)
Private _cItemcta := space(11)
Private _cLocliz  := space(15)

dbSelectArea( "SX1" )
SX1->(dbSetOrder( 1 ))
If !( DbSeek( _cPerg + '01'))
    RestArea(_aArea)
    Return(_nPunit)   
Else
    While !EOF() .AND. SX1->X1_GRUPO = _cPerg
        IF !Empty(SX1->X1_CNT01) .AND. SX1->X1_ORDEM = '01'
           _cTes := ALLTRIM(SX1->X1_CNT01)
        ELSEIF !Empty(SX1->X1_CNT01) .AND. SX1->X1_ORDEM = '02'
           _cLocal := ALLTRIM(SX1->X1_CNT01)
        ELSEIF !Empty(SX1->X1_CNT01) .AND. SX1->X1_ORDEM = '03'    
           _cOperac:= ALLTRIM(SX1->X1_CNT01)
        ELSEIF !Empty(SX1->X1_CNT01) .AND. SX1->X1_ORDEM = '04'      
           _cCusto := ALLTRIM(SX1->X1_CNT01)
        ELSEIF !Empty(SX1->X1_CNT01) .AND. SX1->X1_ORDEM = '05'      
           _cLocliz:= ALLTRIM(SX1->X1_CNT01)   
        ENDIF
       SX1->(DBSKIP())
    End
EndIF*/
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe  Pedido de Vendas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cPC      := ALLTRIM(M->C5_NUM) 
_cTipo    := ALLTRIM(SB1->B1_TIPO)
_cGrupo   := ALLTRIM(SB1->B1_GRUPO) 
_cCLVL    := ALLTRIM(SB1->B1_CLVL)
_cItemcta := ALLTRIM(SB1->B1_ITEMCC)	

IF _cTipo <> 'SV' .AND. _cGrupo <> 'VEIA'
    
    If IsInCallStack("U_ZFAT002A")  //Função que chama o gatilho
       n := _nLinAc
    EndIf
    
    For _nK := 1 To Len(aColS)  
       _cColPR := aColS[n][_nPosPr]
       _cColLoc:= aColS[n][_nPosLoc]
    Next 

    If !Empty( _cPC ) //Se não encontrar CM1 fica zero

        If Select( (cAliasQry) ) > 0
		    (cAliasQry)->(DbCloseArea())
	    EndIf

        _cQry  := " SELECT * FROM ( SELECT B9_CM1 " + CRLF
        _cQry  += "                 FROM " + RetSqlName("SB9") + " SB9 " + CRLF
        _cQry  += "                 WHERE B9_FILIAL = '" + FWxFilial("SB9") + "' " + CRLF
        _cQry  += "                 AND B9_COD = '" + _cColPr + "' " + CRLF
        _cQry  += "                 AND SB9.D_E_L_E_T_ = ' ' " + CRLF
        _cQry  += "                 ORDER BY B9_DATA DESC ) TMP " + CRLF
        _cQry  += " WHERE ROWNUM = 1 "
        
        //_cQry  := ChangeQuery( _cQry )
        
        dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQry ), cAliasQry, .F., .T. )

    Else
        _cPC := "      "
    EndIf

    //Inclusão do .and. !IsInCallStack("U_PRCDOCIN"), por conta do programa
    // ZESTF004 que utiliza a qtde e custo da planilha de inventario
    If  !(cAliasQry)->(Eof()) .and. !IsInCallStack("U_PRCDOCIN") 

        /*If ((cAliasQry)->VAL/(cAliasQry)->QTDE) < 0
           _cResval := Str((cAliasQry)->VAL/(cAliasQry)->QTDE)
           _cMSG := "Item: " + Alltrim(Str(n)) + "   Código: " + Alltrim(_cColPR) + "    Valor Negativo!! " + _cResval
           MsgInfo(_cMSG, "[ ZFATF004 ] - Aviso" )
           _nPunit := 0
        Else*/
           _nPunit := (cAliasQry)->B9_CM1
        //EndIF

    EndIf

    IF !EMPTY(_cLocal)
        aCols[n][_nPosLoc] := _cLocal	
        __READVAR := "C6_LOCAL"
        &("M->"+__READVAR)	:= _cLocal
        &(GetSx3Cache(__READVAR,"X3_VALID"))
        RunTrigger(2,n,nil,,__READVAR)
    EndIF
  
    //Inclusão do If !IsInCallStack("U_PRCDOCIN"), por conta do programa
    // ZESTF004 que utiliza a qtde e custo da planilha de inventario
    If !IsInCallStack("U_PRCDOCIN")  
        aColS[n][_nPosPU] := _nPunit	
        __READVAR := "C6_PRCVEN"
        &("M->"+__READVAR) := _nPunit
        &(GetSx3Cache(__READVAR,"X3_VALID"))
        RunTrigger(2,n,nil,,__READVAR)
    Endif

    IF !EMPTY(_cLocliz) 
        aCols[n][_nPosLiz] := _cLocliz	
        __READVAR	:= "C6_LOCALIZ"
		&("M->"+__READVAR)	:= _cLocliz
		//&(GetSx3Cache(__READVAR,"X3_VALID"))
		RunTrigger(2,n,nil,,__READVAR)
    EndIf  

    IF !EMPTY(_cOperac)    
        aCols[n][_nPosOper] := _cOperac	
        __READVAR	:= "C6_OPER"
        &("M->"+__READVAR)	:= _cOperac
        &(GetSx3Cache(__READVAR,"X3_VALID"))
        RunTrigger(2,n,nil,,__READVAR)
    EndIF

    IF !EMPTY(_cTes) 
        aCols[n][_nPosTes] := _cTes	
        __READVAR	:= "C6_TES"
        &("M->"+__READVAR)	:= _cTes
        &(GetSx3Cache(__READVAR,"X3_VALID"))
        RunTrigger(2,n,nil,,__READVAR)
    EndIF	

    IF !EMPTY(_cCusto) 
        aCols[n][_nPosCC] := _cCusto
        __READVAR	:= "C6_CC"
        &("M->"+__READVAR)	:= _cCusto
        &(GetSx3Cache(__READVAR,"X3_VALID"))
        RunTrigger(2,n,nil,,__READVAR)
    EndIf 

    IF !EMPTY(_cCLVL) 
        aCols[n][_nPosCLVL] := _cCLVL	
		__READVAR	:= "C6_CLVL"
		&("M->"+__READVAR)	:= _cCLVL
		&(GetSx3Cache(__READVAR,"X3_VALID"))
		RunTrigger(2,n,nil,,__READVAR)
    EndIf 

    IF !EMPTY(_cItemcta) 
        aCols[n][_nPosItCt] := _cItemcta	
		__READVAR	:= "C6_ITEMCTA"
		&("M->"+__READVAR)	:= _cItemcta
		&(GetSx3Cache(__READVAR,"X3_VALID"))
		RunTrigger(2,n,nil,,__READVAR)
    EndIf

ENDIF

RestArea(_aArea)
Return(_nPunit)
