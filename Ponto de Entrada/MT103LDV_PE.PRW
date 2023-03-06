#Include 'Protheus.Ch'
#Include 'RwMake.Ch'
#Include 'Font.Ch'
#Include 'Colors.Ch'
#Include "TopConn.Ch"
#Include "TbiConn.CH"

/*/{Protheus.doc} MT103LDV
Ponto de entrada para geração automática de 
pedido de venda no processo de devolução de 
nota fiscais

@author Leonardo Miranda
@since 03/03/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

************************
User Function MT103LDV()
************************

Local aReturn   As Array
Local cAliasSD2 As Character

aReturn     := aClone(ParamIxb[01])
cAliasSd2   := ParamIxb[02]

If Upper(Alltrim(FunName())) == "ZFATF019" .And. ValType(lGerPVDev) <> "U" .And. lGerPVDev
    Aadd(aReturn ,{ "D1_GERAPV" ,"S"  			        ,Nil})
    Aadd(aReturn ,{ "D1_NUMPV"  ,(cAliasSD2)->D2_PEDIDO ,Nil})
    Aadd(aReturn ,{ "D1_IEMPV"  ,(cAliasSD2)->D2_ITEMPV ,Nil})
EndIf

Return(aReturn)
