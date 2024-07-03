#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} OX004AIP
Ponto de entrada referente a grava��o SC6, recebe matriz para execauto
@author     DAC - Denilso 
@since      20/09/2023
@version    V.03
@obs        Esta funcionalidade foi criada para manter a padroniza��o do Faturamento  realizado pela fun��o OFIXX004
			O item (VS3) tem que estar aberto neste momento
/*/

User Function OX004AIP
Local _aItem := ParamIXB[1]
Local _nPosCpo

Begin Sequence
	If Valtype(_aItem) <> "A" 
		_aItem := {}
	Endif	

	If Len(_aItem) == 0
		Break 
	Endif 

	//@project	GAP002 | Integra��o da separa��o - Informar produto e quantidade da cubagem - DAC 20/09/2023 
	//Gravar numero Or�amento no SC6
	If SC6->(FieldPos("C6_XORCVS3")) > 0 
   		_nPosCpo 	:= Ascan(_aItem,{|x| AllTrim(x[1]) == "C6_XORCVS3"} )
 		If _nPosCpo > 0
    		_aItem[_nPosCpo,2] := VS3->VS3_NUMORC // inicialmente so colocar a primeira msg padr�o
   		Else
			aAdd(_aItem, {"C6_XORCVS3", VS3->VS3_NUMORC , Nil})
		Endif
	Endif
End Sequence 
Return _aItem

