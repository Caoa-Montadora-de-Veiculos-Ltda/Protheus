#include "totvs.ch"

User Function INTVX0NF()
	Local xAutoCab := {} // Campos Cabecalho
	Local xAutoItens := {} // Campos Itens
	Local xAutoIt := {}

	Local aParParamBox := {}
	Local aRetParamBox := {}
	
	AADD( aParParamBox , { 1 , RetTitle("F1_DOC")     , Space(TamSX3("F1_DOC"    )[1]) , "" , "" , "" , "" , 40 , .T. } )
	AADD( aParParamBox , { 1 , RetTitle("F1_SERIE")   , Space(TamSX3("F1_SERIE"  )[1]) , "" , "" , "" , "" , 40 , .T. } )
	AADD( aParParamBox , { 1 , RetTitle("F1_FORNECE") , Space(TamSX3("F1_FORNECE")[1]) , "" , "" , "" , "" , 40 , .T. } )
	AADD( aParParamBox , { 1 , RetTitle("F1_LOJA")    , Space(TamSX3("F1_LOJA"   )[1]) , "" , "" , "" , "" , 40 , .T. } )
	AADD( aParParamBox , { 1 , RetTitle("VV1_CHASSI") , Space(TamSX3("VV1_CHASSI")[1]) , "" , "" , "" , "" , 40 , .T. } )

	If ! ParamBox(aParParamBox,"Entrada Veiculo - NF",@aRetParamBox,,,,,,,, .f., .f.)
		Return
	EndIf

	//cNota := "1812110021  00001601"
	cNota := aRetParamBox[1] + aRetParamBox[2] + aRetParamBox[3] + aRetParamBox[4]
	//cNota := FMX_INPUTBOX("Numero da nota fiscal de entrada", Space(TamSX3("F1_DOC")[1] + TamSX3("F1_SERIE")[1]))
	//cNota := FMX_INPUTBOX("Numero da nota fiscal de entrada", cNota )
	// F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

	SF1->(dbSetOrder(1))
	If ! SF1->(dbSeek(xFilial("SF1") + cNota ))
		MsgStop("Nota fiscal não encontrada")
		Return
	EndIf

	cPergunta := "Nota: " + SF1->F1_SERIE + " - " + SF1->F1_DOC + CHR(13) + CHR(10) + ;
		"Fornecedor: " + sf1->F1_FORNECE + " - " + sf1->F1_LOJA

	If ! MsgYesNo("Confirma importacao da nota fiscal " + chr(13) + chr(10) + chr(13) + chr(10) + cPergunta )
		Return 
	EndIf


	aAdd(xAutoCab,{"VVF_CLIFOR"  ,"F"               ,Nil})
	aAdd(xAutoCab,{"VVF_FORPRO"  ,"0"               ,Nil})
	aAdd(xAutoCab,{"VVF_OPEMOV"  ,"0"               ,Nil})
	aAdd(xAutoCab,{"VVF_DATMOV"  ,dDataBase         ,Nil})
	aAdd(xAutoCab,{"VVF_DATEMI"  ,SF1->F1_EMISSAO   ,Nil})
	aAdd(xAutoCab,{"VVF_CODFOR"  ,SF1->F1_FORNECE   ,Nil})
	aAdd(xAutoCab,{"VVF_LOJA"    ,SF1->F1_LOJA      ,Nil})
	aAdd(xAutoCab,{"VVF_FORPAG"  ,RetCondVei()      ,Nil})
	aAdd(xAutoCab,{"VVF_ESPECI"  ,SF1->F1_ESPECIE   ,Nil})
	aAdd(xAutoCab,{"VVF_NUMNFI"  ,SF1->F1_DOC       ,Nil})
	aAdd(xAutoCab,{"VVF_SERNFI"  ,SF1->F1_SERIE     ,Nil})
	aAdd(xAutoCab,{"VVF_NATURE"  ,'1010101   '      ,Nil})
//	aAdd(xAutoCab,{"VVF_VALMOV"  ,SF1->F1_VALBRUT   ,Nil})
	aAdd(xAutoCab,{"VVF_CHVNFE"  ,SF1->F1_CHVNFE    ,Nil})

	xAutoItens:= {} // Campos Itens
	
	VV1->(dbSetOrder(2))

	SD1->(dbSetOrder(1))
	SD1->(dbSeek(xFilial("SD1") + cNota))
	While !SD1->(Eof()) .and. SD1->D1_FILIAL == xFilial("SD1") .and. SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cNota

		//cChassi := "CHASSI_MVC_EXECAUTO_001  "
		cChassi := aRetParamBox[5]

		VV1->(dbSeek(xFilial("VV1") + cChassi))

		xAutoIt := {}
		aAdd(xAutoIt,{"VVG_CHASSI"  ,VV1->VV1_CHASSI 	,Nil})
		aAdd(xAutoIt,{"VVG_CODTES"  ,SD1->D1_TES			,Nil})
		aAdd(xAutoIt,{"VVG_LOCPAD"  ,VV1->VV1_LOCPAD		,Nil})
		aAdd(xAutoIt,{"VVG_VALUNI"  ,SD1->D1_TOTAL		,Nil})
		aAdd(xAutoIt,{"VVG_PICOSB"  ,"0"						,Nil}) // Pis/Cof Subs
		aAdd(xAutoItens,xAutoIt)

		SD1->(dbSkip())
	End

	Private lMsHelpAuto := .t.
	Private lMsErroAuto := .f.

	cBkpFunName := FunName()
	SetFunName('VEIXA001')

	MSExecAuto(;
		{ |a,b,c,d,e,f,g,h,i| ;
		VEIXX000(a       ,b         ,c      ,d   ,e      ,f       ,g         ,h          ,i      ) },;
		         xAutoCab,xAutoItens,{}     ,3   ,"0"    ,        ,.f.       ,           ,"3"    )
	SetFunName(cBkpFunName)
	If lMsErroAuto
		If (!IsBlind()) // COM INTERFACE GRÁFICA
			MostraErro() //TELA
		EndIf
	Else
		MsgInfo("Movimento criado com sucesso")
	EndIf

Return 
