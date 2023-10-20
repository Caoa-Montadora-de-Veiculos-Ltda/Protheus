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
Local _cPC        := Space(6)
Local _cTipo      := Space(2)
Local _cGrupo     := Space(4)
Local _nPrcUnit     := 0
Local _nK         := 0
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
    Return(_nPrcUnit)   
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

       	_nPrcUnit := NoRound(U_ZGENCST(_cColPr),TamSx3("C6_PRCVEN")[02])
		
    Else
        _cPC := "      "
    EndIf

    IF !Empty(_cLocal)
        aCols[n][_nPosLoc] := _cLocal
        zUpdCampo("C6_LOCAL"	,_cLocal		,n )		
    EndIF
  
    //Inclusão do If !IsInCallStack("U_PRCDOCIN"), por conta do programa
    // ZESTF004 que utiliza a qtde e custo da planilha de inventario
    If !IsInCallStack("U_PRCDOCIN")  
        aColS[n][_nPosPU] := _nPrcUnit
        zUpdCampo("C6_PRCVEN"	,_nPrcUnit		,n )		
    Endif

    IF !Empty(_cLocliz) 
        aCols[n][_nPosLiz] := _cLocliz
        zUpdCampo("C6_LOCALIZ"	,_cLocliz		,n )		
    EndIf  

    IF !Empty(_cOperac)    
        aCols[n][_nPosOper] := _cOperac
        zUpdCampo("C6_OPER"	,_cOperac		    ,n )		
    EndIF

    IF !Empty(_cTes) 
        aCols[n][_nPosTes] := _cTes	
        zUpdCampo("C6_TES"	,_cTes		        ,n )		
    EndIF	

    IF !Empty(_cCusto) 
        aCols[n][_nPosCC] := _cCusto
        zUpdCampo("C6_CC"	,_cCusto		    ,n )		
    EndIf 

    IF !Empty(_cCLVL) 
        aCols[n][_nPosCLVL] := _cCLVL
        zUpdCampo("C6_CLVL"	,_cCLVL		        ,n )		
    EndIf 

    IF !Empty(_cItemcta) 
        aCols[n][_nPosItCt] := _cItemcta
        zUpdCampo("C6_ITEMCTA"	,_cItemcta		,n )		
    EndIf

ENDIF

RestArea(_aArea)

Return(_nPrcUnit)

/*
==============================================================================================
Funcao.........: zRunTrigger
Descricao......: Roda as Trigger do Gatilho
Autor..........: Evandro Mariano
Criação........: 28/07/2023
Alterações.....:
===============================================================================================
*/
Static Function zUpdCampo(_cCampo, _xConteudo, _nPos)

Local _aArea			:= FWGetArea()
Local _lValid			:= .F.
Default _nPos			:= 0
Default _cCampo			:= ""
Default _xConteudo		:= " "

//Altera o ReadVar da Memória
&("M->"+_cCampo) := _xConteudo
__ReadVar := _cCampo

//Chama as validações do sistema
_lValid := CheckSX3(_cCampo, _xConteudo)

//Se deu tudo certo nas validações
If _lValid
	If ExistTrigger(_cCampo)
	
		RunTrigger( 2		,;  //nTipo (1=Enchoice; 2=GetDados; 3=F3)
					_nPos	,;  //Linha atual da Grid quando for tipo 2
					Nil		,;  //Não utilizado
							,;  //Objeto quando for tipo 1
					_cCampo	)   //Campo que dispara o gatilho
	EndIf
EndIf

RestArea(_aArea)

Return()

