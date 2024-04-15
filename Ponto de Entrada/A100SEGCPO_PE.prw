#Include "TopConn.Ch"
#Include "TbiConn.Ch"
#Include "Xmlxfun.Ch"
#Include "Totvs.Ch"
#Include "Protheus.Ch"

/*
Autor     : Leonardo Miranda
Criacao   : 25/11/2021
Descricao : Ponto de entrada na autorização de entrega para ajustar a aliquota de IPI conforme o contrato de parceria
Partida   : MATA122
*/    
Static _C7_NUMSC
Static _C7_ITEMSC
static _C7_IPI
Static _lMata122

User Function A100SEGCPO()
    Local lRet      := .T.
    Local aArea     
    Local aSC3Area  
    Local cNumCont  
    Local cItemCont 

    DEFAULT _lMata122 := Upper(Alltrim(FunName())) == "MATA122" 

    If _lMata122 .And. Upper(Alltrim(ProcName(3))) == "A120PRODUTO"
        
		If _C7_NUMSC == nil 
            _C7_NUMSC :=  aScan(aHeader,{|x| Alltrim(x[2]) == 'C7_NUMSC'})
            _C7_ITEMSC:=  aScan(aHeader,{|x| Alltrim(x[2]) == 'C7_ITEMSC'})
            _C7_IPI   :=  aScan(aHeader,{|x| Alltrim(x[2]) == 'C7_IPI'})
        EndIf 
        
		aArea       := GetArea()
        aSC3Area    := SC3->(GetArea())
        cNumCont    := aCols[n][_C7_NUMSC]
        cItemCont   := aCols[n][_C7_ITEMSC]
        SC3->(DbSetOrder(1))
        
		If SC3->(DbSeek(xFilial("SC3")+cNumCont+cItemCont))
            aCols[n][_C7_IPI]:=  SC3->C3_IPI 
        EndIf
        
		RestArea(aSC3Area)
        RestArea(aArea   )
        aSize(aSC3Area,0)
        aSC3Area := nil 

        aSize(aArea,0)
        aArea := nil 
    
	EndIf


Return(lRet)

/*

**************************
User Function A100SEGCPO()
**************************

Local lRet 		:= .T.
Local aArea		
Local aSC3Area	
Local cNumCont	
Local cItemCont	

If Upper(Alltrim(FunName())) == "MATA122" .And. Upper(Alltrim(ProcName(3))) == "A120PRODUTO"
	aArea		:= GetArea()
	aSC3Area	:= SC3->(GetArea())
	cNumCont	:= GDFieldGet("C7_NUMSC" ,N)
	cItemCont	:= GDFieldGet("C7_ITEMSC",N)
	SC3->(DbSetOrder(1))
	If SC3->(DbSeek(xFilial("SC3")+cNumCont+cItemCont))
		GDFieldPut("C7_IPI", SC3->C3_IPI , N)
	EndIf
	
	RestArea(aSC3Area)
	RestArea(aArea   )
  	
	aSize(aSC3Area,0)
    aSC3Area := nil 

    aSize(aArea,0)
    aArea := nil 

EndIf



Return(lRet)
*/

