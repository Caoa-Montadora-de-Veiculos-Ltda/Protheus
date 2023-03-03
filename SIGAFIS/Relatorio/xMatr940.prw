#include "totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ xMATR940 ³ Autor ³ Cristiam Rossi        ³ Data ³ 21/02/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Registro de Apuracao de ICMS - P9                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user FUNCTION xMATR940
wnRel:="MATR940"
titulo:="Registro de Apuracao de ICMS"
cDesc1:="Este programa ir  imprimir o Livro de Registro de Apuracao de ICMS (modelo P9)"
cDesc2:="conforme parƒmetros e per¡odo informados."
cDesc3:=""
aReturn:= { "Zebrado", 1,"Administração", 2, 2, 1, "",1 }
nomeprog:="MATR940"
cPerg:="MTR941"
cString:="SF3"
nPagina:=0
nLin:=80
Tamanho:="M"
_Retorno:=NIL
private _aUF := fGetUF()	// variável com as UF e posterior acumulo de valores - Cristiam Rossi em 22/02/2019
//
if ! Pergunte(cPerg,.T.)
	return nil
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLastKey:=0
Iif(mv_par14==1,Tamanho:="M",Tamanho:="G")
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.T.)
If nLastKey==27
	dbClearFilter()
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey==27
	dbClearFilter()
	Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa relatorio                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|lEnd| R940Imp(@lEnd,wnRel,cString,Tamanho)},titulo)

If aReturn[5]==1
	Set Printer To
	ourspool(wnrel)
Endif
MS_FLUSH()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R940Imp  ³ Autor ³ Juan Jose Pereira     ³ Data ³ 18.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Relatorio                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R940Imp(lEnd,wnRel,cString,Tamanho)
local   aDatas
PRIVATE lAbortPrint:=.F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 = Mes                                                                   ³
//³ mv_par02 = Ano                                                                   ³
//³ mv_par03 = Tipo de Apuracao ? Decendial / Quinzenal / Mensal / Semestral / Anual ³
//³ mv_par04 = Periodo Apurado ? 1 / 2 / 3  / 4                                      ³
//³ mv_par05 = Concilia apuracoes ? Sim / Nao                                        ³
//³ mv_par06 = Quebra da Apuracao ? Por Aliquota / Por CFO                           ³
//³ mv_par07 = Indice de Conversao                                                   ³
//³ mv_par08 = Exibe valores convertidos? Sim / Nao                                  ³
//³ mv_par09 = Livro Selecionado                                                     ³
//³ mv_par10 = Dt Entrega da Guia                                                    ³
//³ mv_par11 = Local de Entrega da Guia                                              ³
//³ mv_par12 = numero de paginas                                                     ³
//³ mv_par13 = paginas por feixe                                                     ³
//³ mv_par14 = imprime ? livro / termos                                              ³
//³ mv_par15 = Livro Nr?                                                             ³
//³ mv_par16 = Considera Nao Tributadas                                              ³
//³ mv_par17 = Valor Contabil Imprime ? Valor Contabil / Aliquota                    ³
//³ mv_par18 = Imprime resumo por UF( Subst. Tributaria)? Sim/Nao                    ³
//³ mv_par19 = Imprime diferencial de aliquota                                       ³
//³ mv_par20 = Imprime Credito ST                                                    ³
//³ mv_par21 = Imprime Credito Estimulo                                              ³
//³ mv_par22 = Filial De                                                             ³
//³ mv_par23 = Filial Ate                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nMes		:=	mv_par01,;
		nAno		:=	mv_par02,;
		nApuracao	:=	mv_par03,;
		nPerApurado	:=	mv_par04,;
		lConcilia	:=	(mv_par05==1),;
		nQuebra		:=	mv_par06,;
		nIndice		:=	IIf(mv_par07>0,mv_par07,1),;
		lConverte	:=	(mv_par08==1),;
		cNrLivro	:=	mv_par09,;
		dDtEntrega	:=	mv_par10,;
		cLocEntrega	:=	Upper(mv_par11),;
		nPagIni		:=	mv_par12,;
		nQtFeixe	:=	mv_par13,;
		nImprime	:=	mv_par14,;
		lNaoTrib	:=	(mv_par16==1),;
		lVlrCtb 	:=	(mv_par17==1),;
		lResST		:=	(mv_par18==1),;
		lImpCrdSt 	:=  (mv_par20==1),;
		lMv_UFSt  	:=  If(!Empty(GetNewPar("MV_UFST","")),.T.,.F.),;
		lCrdEst		:=	(MV_PAR21==1),;
		cFilDe		:=	Iif (Empty (MV_PAR22) .And. Empty (MV_PAR23), cFilAnt, MV_PAR22),;
		cFilAte		:=	Iif (Empty (MV_PAR23), cFilAnt, MV_PAR23)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define picture padrao dos valores                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cPictVal:="@E) 999,999,999,999.99"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dias de inicio e fim da apuracao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nPeriodo:=0,dDtIni,dDtFim

	aDatas := DetDatas(nMes,nAno,nApuracao,nPerApurado)
	dDtIni := aDatas[1]
	dDtFim := aDatas[2]

	Matr941()

Return nil



//------------------------------------------------------------------------------------------------------
static FUNCTION MATR941
Local k := 1, n015 := 0, n017 := 0, i :=0
Local lArqST := .F.
Local aTotal := array(03)
Local cDescr := ""
Local nTotEnt :=0
Local nTotSai :=0
Local cMV_UfSt	:=	SuperGetMv("MV_UFST")	// Define o estado a ser desconsiderado no Registro de Apuracao do ICMS-ST ( Artigo 23-Decreto 27.427 - 17/11/00 - RJ )
Local cEstado   :=  SuperGetMv("MV_ESTADO")
Local aEstimulo	:=	{}
Local aIncent	:=	{{"INC",0,0,0,0}}
Local cGNR		:= ""
Local cTit		:= ""
Local cTextFom	:= ""
Local nValFom	:= 	0
Local nNivel	:=	0
Local nTransfE	:= 0
Local nTransfS	:= 0
Local cTermoAb	:= SuperGetMv("MV_LMOD9AB")
// Indica se a ordem dos totais do livro deve seguir os padroes da Nova GIA - SP
Local lGiaSP	:= GetNewPar("MV_GIASP",.F.)
Local lApurBA	:= (SuperGetMv("MV_ESTADO")=="BA" .And. SuperGetMv("MV_APURBA",,.F.))
Local aLisFil	:= {}
Local lFiliais  := If(mv_par25==1,.T.,.F.)
Local nTanapur	:= ""
Local nXF		:= 0
Local cObsCfo	:=	GetNewPar("MV_OBSCFO","") // Indica a CFOP utilizanda quando o Livro Fiscal de ICMS = B-Observacao
Local nCont := 0
Local aDadosAgl:={}
Local nx,nXFil,nY,nPosAgl
Local aFilsAgl:={}
Local cFilBack	:= cFilAnt

Local lCaoa:=.t.//Imprime somente Substituição Tributária

Private nEntUFST := 0
Private nSaiUFST := 0
Private aResEntr := {}
Private aResSaid := {}
Private nValAntMG:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define qual parte da apuracao esta imprimindo                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cImprimindo:="AP_ENT"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebe dados da apuracao                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case nQuebra==1 .And. lVlrCtb
		lQbrAliquota:=.T.
		lQbrCFO		:=.F.
	Case nQuebra==2 .And. lVlrCtb
		lQbrAliquota:=.F.
		lQbrCFO		:=.T.
	OtherWise
		lQbrAliquota:=.T.
		lQbrCFO		:=.T.
EndCase

If lFiliais
	If MV_PAR28==1
		aLisFil  :=MatFilCalc(lFiliais,,,mv_par28==1,,2)
	Else
	 	aLisFil  :=MatFilCalc(lFiliais,,.T.)
	Endif
	nConsFil :=1
Else
	aLisFil:={{.T.,cFilAnt}}
	nConsFil := 1
EndIf

If lFiliais//MV_PAR25==1 .and. MV_PAR28==1
	For nXFil:=1 to Len(aLisFil)
		aFilsAgl:={}
		If aLisFil[nXFil][1]
		   cFilAnt:=aLisFil[nXFil][2]
			AAdd(aFilsAgl,aLisFil[nXFil])
			aDadosTmp:=ResumeF3("IC",dDtIni,dDtFim,cNrLivro,lQbrAliquota,lQbrCFO,2,@lAbortPrint,1,cFilDe,cFilAte,@aResEntr,@aResSaid,AllTrim (aReturn[7]),,,,,,lImpCrdSt,lMv_UFSt,lCrdEst,NIL,NIL,NIL,NIL,NIL,NIL,NIL,"F3_MATRAPR",mv_par24,aFilsAgl)
			If nXFil==1
				aDadosAgl:=ACLONE(aDadosTmp)
			Else
				For nX:=1 to Len(aDadosTmp)
					 nPosAgl:=AScan( aDadosAgl,{ |x| x[1]==aDadosTmp[nX,1] })
					 If nPosAgl>0
					 	 For nY:=1 to Len(aDadosTmp[nX])
							  	If Len(aDadosAgl[nPosAgl])==Len(aDadosTmp[nX])
							  		If ValType(aDadosTmp[nX][nY])=='N'
									    aDadosAgl[nPosAgl,nY]+=aDadosTmp[nX,nY]
									Endif
								Endif
						 Next
					 Else
						Aadd(aDadosAgl,aDadosTmp[nX])
					 Endif
				Next
			Endif
		Endif
	Next
	aDadosApur:=AClone(aDadosAgl)
	cFilant:=cFilBack
Else
	aDadosApur:=ResumeF3("IC",dDtIni,dDtFim,cNrLivro,lQbrAliquota,lQbrCFO,2,@lAbortPrint,1,cFilDe,cFilAte,@aResEntr,@aResSaid,AllTrim (aReturn[7]),,,,,,lImpCrdSt,lMv_UFSt,lCrdEst,NIL,NIL,NIL,NIL,NIL,NIL,NIL,"F3_MATRAPR",mv_par24,aLisFil)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento dos Creditos de Estimulo - Manaus ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCrdEst
   ProcEst(dDtIni,dDtFim,@aEstimulo,,@aIncent)
Endif

Do Case
	Case nQuebra==1
		QbrAliquota:=.T.
		lQbrCFO		:=.F.
	Case nQuebra==2
		lQbrAliquota:=.F.
		lQbrCFO		:=.T.
EndCase

aEntradas:={}
aSaidas:={}
cOperacao:=""
cAliq:=""
cLinha:=""
cConteudo:=""
cArqApur:=""
cCampo:=""
cValor:=""
cTexto:=""
nValICMS:=0
nValBase:=0
nValCont:=0
i:=0
j:=0
nArqIni:=0
nArqFim:=0
nValor:=0
uValCont:=NIL
uValBase:=NIL
uValICMS:=NIL
uValCrdSt:=NIL
aL:=NIL
R941LayOut()
aDriver:={}

nLin:=80
nPagina:=nPagIni
cImp:="IC"
nPeriodo:=0
nPos:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³         Imprime Termos de Abertura e Encerramento            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nImprime==2
	aDriver:=ReadDriver()

	If mv_par26 == 1 .And. !Empty(SuperGetMv("MV_P9ABER"))
		cTermoAb := SuperGetMv("MV_P9ABER")
	EndIf

	XFIS_IMPTERM(cTermoAb,SuperGetMv("MV_LMOD9EN"),cPerg,Iif( aReturn[4] = 1, aDriver[3], aDriver[4] ) )

	Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Separa entradas e saidas                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(Len(aDadosApur))
For i:=1 to Len(aDadosApur)
	IncRegua()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se imprime itens nao tributados                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lNaoTrib.And.aDadosApur[i,4]<=0
		Loop
	Endif
	If lQbrCFO
		If Substr(aDadosApur[i,1],1,1)<"5"
			AADD(aEntradas,aDadosApur[i])
		Else
			AADD(aSaidas,aDadosApur[i])
		Endif
	Else
		If aDadosApur[i,1]=="ENTR".Or.Substr(aDadosApur[i,1],1,3)<"500"
			AADD(aEntradas,aDadosApur[i])
		Else
			AADD(aSaidas,aDadosApur[i])
		Endif
	Endif
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Coloca entradas e saidas em ordem crescente de CFO ou           ³
//³ decrescente de valor contabil                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQbrCfo
	aEntradas	:=Asort(aEntradas	,,,{|x,y|x[1]<y[1]})
	aSaidas		:=Asort(aSaidas	,,,{|x,y|x[1]<y[1]})
Else
	aEntradas	:=Asort(aEntradas	,,,{|x,y|x[02]>y[02]})
	aSaidas		:=Asort(aSaidas	,,,{|x,y|x[02]>y[02]})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acrescenta linha para totalizacao                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aEntradas)
	If lQbrCFO
		AADD(aEntradas,Aclone(aEntradas[1]))
		Afill(aEntradas[Len(aEntradas)],0,2)
		aEntradas[Len(aEntradas),1]:="100"
		AADD(aEntradas,Aclone(aEntradas[1]))
		Afill(aEntradas[Len(aEntradas)],0,2)
		aEntradas[Len(aEntradas),1]:="200"
		AADD(aEntradas,Aclone(aEntradas[1]))
		Afill(aEntradas[Len(aEntradas)],0,2)
		aEntradas[Len(aEntradas),1]:="300"
	Endif
	AADD(aEntradas,Aclone(aEntradas[1]))
	Afill(aEntradas[Len(aEntradas)],0,2)
	aEntradas[Len(aEntradas),1]:="T00"
Endif
If !Empty(aSaidas)
	If lQbrCFO
		AADD(aSaidas,Aclone(aSaidas[1]))
		Afill(aSaidas[Len(aSaidas)],0,2)
		aSaidas[Len(aSaidas),1]:="500"
		AADD(aSaidas,Aclone(aSaidas[1]))
		Afill(aSaidas[Len(aSaidas)],0,2)
		aSaidas[Len(aSaidas),1]:="600"
		AADD(aSaidas,Aclone(aSaidas[1]))
		Afill(aSaidas[Len(aSaidas)],0,2)
		aSaidas[Len(aSaidas),1]:="700"
	Endif
	AADD(aSaidas,Aclone(aSaidas[1]))
	Afill(aSaidas[Len(aSaidas)],0,2)
	aSaidas[Len(aSaidas),1]:="T00"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Totaliza entradas                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aEntradas)>0
	nTot:=Len(aEntradas)
	For i:=1 to nTot
		If Substr(aEntradas[i,1],2)!="00"
			If Substr(aEntradas[i,1],1,1)=="1"
				nPos:=Ascan(aEntradas,{|x|x[1]=="100"})
			ElseIf Substr(aEntradas[i,1],1,1)=="2"
				nPos:=Ascan(aEntradas,{|x|x[1]=="200"})
			ElseIf Substr(aEntradas[i,1],1,1)=="3"
				nPos:=Ascan(aEntradas,{|x|x[1]=="300"})
			Endif
			If nPos>0.or.lQbrAliquota
				If lQbrCFO
					aEntradas[nPos,3]:=aEntradas[nPos,3]+aEntradas[i,3]
					aEntradas[nPos,4]:=aEntradas[nPos,4]+aEntradas[i,4]
					aEntradas[nPos,5]:=aEntradas[nPos,5]+aEntradas[i,5]
					aEntradas[nPos,6]:=aEntradas[nPos,6]+aEntradas[i,6]
					aEntradas[nPos,11]:=aEntradas[nPos,11]+aEntradas[i,11]
				Endif
				aEntradas[nTot,3]:=aEntradas[nTot,3]+aEntradas[i,3]
				aEntradas[nTot,4]:=aEntradas[nTot,4]+aEntradas[i,4]
				aEntradas[nTot,5]:=aEntradas[nTot,5]+aEntradas[i,5]
				aEntradas[nTot,6]:=aEntradas[nTot,6]+aEntradas[i,6]
				aEntradas[nTot,11]:=aEntradas[nTot,11]+aEntradas[i,11]
				nTotEnt +=(aEntradas[nTot,3]+aEntradas[nTot,4]+aEntradas[nTot,5]+aEntradas[nTot,6]+aEntradas[nTot,11])
				nTransfE+=aEntradas[i,15]   //Transferência
			Endif
		Endif
	Next
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Totaliza Saidas                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos :=0
If Len(aSaidas)>0
	nTot:=Len(aSaidas)
	For i:=1 to nTot
		If Substr(aSaidas[i,1],2)!="00"
			If Substr(aSaidas[i,1],1,1)=="5"
				nPos:=Ascan(aSaidas,{|x|x[1]=="500"})
			ElseIf Substr(aSaidas[i,1],1,1)=="6"
				nPos:=Ascan(aSaidas,{|x|x[1]=="600"})
			ElseIf Substr(aSaidas[i,1],1,1)=="7"
				nPos:=Ascan(aSaidas,{|x|x[1]=="700"})
			Endif
			If nPos>0.or.lQbrAliquota
				If lQbrCFO
					aSaidas[nPos,3]:=aSaidas[nPos,3]+aSaidas[i,3]
					aSaidas[nPos,4]:=aSaidas[nPos,4]+aSaidas[i,4]
					aSaidas[nPos,5]:=aSaidas[nPos,5]+aSaidas[i,5]
					aSaidas[nPos,6]:=aSaidas[nPos,6]+aSaidas[i,6]
					aSaidas[nPos,11]:=aSaidas[nPos,11]+aSaidas[i,11]
				Endif
				aSaidas[nTot,3]:=aSaidas[nTot,3]+aSaidas[i,3]
				aSaidas[nTot,4]:=aSaidas[nTot,4]+aSaidas[i,4]
				aSaidas[nTot,5]:=aSaidas[nTot,5]+aSaidas[i,5]
				aSaidas[nTot,6]:=aSaidas[nTot,6]+aSaidas[i,6]
				aSaidas[nTot,11]:=aSaidas[nTot,11]+aSaidas[i,11]
				nTotSai +=(aSaidas[nTot,3]+aSaidas[nTot,4]+aSaidas[nTot,5]+aSaidas[nTot,6]+aSaidas[nTot,11])
				nTransfS+=aSaidas[i,16] //Transferência
			Endif
		Endif
	Next
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso nao exista movimentacao atribui os arrays zerados.	³
//e															³
//³Verifica a CFOP contida no Parametro MV_OBSCFO atravez	³
// da Variaval cObsCfo para tratar operação de livro de ICM ³
// igual a Observação									   	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTotEnt == 0 .And. nTransfE == 0
   If aScan(aDadosApur, { |x| Alltrim(x[1]) $ cObsCfo } )  == 0
      aEntradas :={}
   Endif
Endif
If nTotSai==0 .And. nTransfS==0
   If aScan(aDadosApur, { |x| Alltrim(x[1]) $ cObsCfo } )  == 0
	  aSaidas :={}
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Apuracao                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Entradas                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cImprimindo:="AP_ENT"
lFirst:=.T.
If !lCaoa//Imprime somente Substituição Tributária
SetRegua(Len(aEntradas))
For i:=1 to Len(aEntradas)
	IncRegua()
	If Interrupcao(@lAbortPrint)
		Exit
	Endif
	If nLin>58
		R941Cabec(.f.)
	Endif
	_parametros:={aEntradas[i,11],.T.}
	R941Cv()
	uValCont:=If(lVlrCtb,_retorno,aEntradas[i,2])
	_parametros:={aEntradas[i,3],.T.}
	R941Cv()
	uValBase:=_retorno
	_parametros:={aEntradas[i,4],.T.}
	R941Cv()
	uValICMS:=_retorno
	_parametros:={aEntradas[i,5],.T.}
	R941Cv()
	uValIsentas:=_retorno
	_parametros:={aEntradas[i,6],.T.}
	R941Cv()
	uValOutras:=_retorno
	If Substr(aEntradas[i,1],2,2)!="00"
		If lQbrCFO
			cCfo:=Transform(aEntradas[i,1],PESQPICT("SF3","F3_CFO"))
			FmtLin({cCfo,uValCont,uValBase,uValICMS,uValIsentas,uValOutras},aL[22],,,@nLin)
		Else
			cCfo:="ALIQUOTA "+Transform(aEntradas[i,2],"@E 99.99")
			FmtLin({cCfo,uValCont,uValBase,uValICMS,uValIsentas,uValOutras},aL[21],,,@nLin)
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Totalizacao                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFirst.and.lQbrCFO
			lFirst:=.F.
			FmtLin(,aL[23],,,@nLin)
			FmtLin({"ENTRADAS"},aL[24],,,@nLin)
		Endif
		If Substr(aEntradas[i,1],1,1)=="1"
			cDescr:="1.00 DO ESTADO"
		ElseIf Substr(aEntradas[i,1],1,1)=="2"
			cDescr:="2.00 DE OUTROS ESTADOS"
		ElseIf Substr(aEntradas[i,1],1,1)=="3"
			cDescr:="3.00 DO EXTERIOR"
		ElseIf Substr(aEntradas[i,1],1,1)=="T"
			cDescr:="TOTAIS"
		Else
			Loop
		Endif
		FmtLin(Array(5),aL[26],,,@nLin)
		FmtLin({cDescr},aL[25],,,@nLin)
		FmtLin({uValCont,uValBase,uValICMS,uValIsentas,uValOutras},aL[26],,,@nLin)
	Endif
Next i
If Len(aEntradas)==0
	R941Cabec(.f.)
	FmtLin({"     ","SEM MOVIMENTO",,,,},aL[22],,,@nLin)
Endif
If lAbortPrint
	Return
Endif
EndIf//If !lCaoa//Imprime somente Substituição Tributária
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Saidas                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cImprimindo:="AP_SAI"
lFirst:=.T.
If !lCaoa//Imprime somente Substituição Tributária
SetRegua(Len(aSaidas))
For i:=1 to Len(aSaidas)
	IncRegua()
	If Interrupcao(@lAbortPrint)
		Exit
	Endif
	If (nLin>51 .And. i==1) .Or. nLin > 58
		R941Cabec(.f.)
	ElseIf i==1
		FmtLin(,{aL[10],aL[12],aL[13],aL[14],aL[15],aL[17],aL[18]},,,@nLin)
		FmtLin({"DEBITADO"},aL[19],,,@nLin)
		FmtLin(,aL[20],,,@nLin)
	Endif
	_parametros:={aSaidas[i,11],.T.}
	R941Cv()
	uValCont:=If(lVlrCtb,_retorno,aSaidas[i,2])
	_parametros:={aSaidas[i,3],.T.}
	R941Cv()
	uValBase:=_retorno
	_parametros:={aSaidas[i,4],.T.}
	R941Cv()
	uValICMS:=_retorno
	_parametros:={aSaidas[i,5],.T.}
	R941Cv()
	uValIsentas:=_retorno
	_parametros:={aSaidas[i,6],.T.}
	R941Cv()
	uValOutras:=_retorno
	If Substr(aSaidas[i,1],2,2)!="00"
		If lQbrCFO
			cCfo:=Transform(aSaidas[i,1],PESQPICT("SF3","F3_CFO"))
			FmtLin({cCfo,uValCont,uValBase,uValICMS,uValIsentas,uValOutras},aL[22],,,@nLin)
		Else
			cCfo:="ALIQUOTA "+Transform(aSaidas[i,2],"@E 99.99")
			FmtLin({cCfo,uValCont,uValBase,uValICMS,uValIsentas,uValOutras},aL[21],,,@nLin)
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Totalizacao                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFirst.and.lQbrCFO
			lFirst:=.F.
			FmtLin(,aL[23],,,@nLin)
			FmtLin({"SAIDAS"},aL[24],,,@nLin)
		Endif
		If Substr(aSaidas[i,1],1,1)=="5"
			cDescr:="5.00 PARA O ESTADO"
		ElseIf Substr(aSaidas[i,1],1,1)=="6"
			cDescr:="6.00 PARA OUTROS ESTADOS"
		ElseIf Substr(aSaidas[i,1],1,1)=="7"
			cDescr:="7.00 PARA O EXTERIOR"
		ElseIf Substr(aSaidas[i,1],1,1)=="T"
			cDescr:="TOTAIS"
		Else
			Loop
		Endif
		FmtLin(Array(5),aL[26],,,@nLin)
		FmtLin({cDescr},aL[25],,,@nLin)
		FmtLin({uValCont,uValBase,uValICMS,uValIsentas,uValOutras},aL[26],,,@nLin)
	Endif
	If i==Len(aSaidas)
		While nLin<58
			FmtLin(Array(5),aL[26],,,@nLin)
		End
		FmtLin(,aL[1],,,@nLin)
		nLin := 80
	Endif
Next i
If Len(aSaidas)==0
	FmtLin(,{aL[10],aL[12],aL[13],aL[14],aL[15],aL[17],aL[18]},,,@nLin)
	FmtLin({"DEBITADO"},aL[19],,,@nLin)
	FmtLin(,aL[20],,,@nLin)
	FmtLin({"     ","SEM MOVIMENTO",,,,},aL[22],,,@nLin)
	While nLin<58
		FmtLin(Array(5),aL[26],,,@nLin)
	End
	FmtLin(,aL[1],,,@nLin)
	nLin := 80
Endif
If lAbortPrint
	Return
Endif
EndIf//If !lCaoa//Imprime somente Substituição Tributária

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                RESUMO DA APURACAO DO IMPOSTO                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis que armazenam os campos do resumo da apuracao      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
n001:=0
n001e:=0
n001o:=0
n004:=0
n004e:=0
n004o:=0
n005:=0
n005e:=0
n005o:=0
n008:=0
n008e:=0
n008o:=0
n009:=0
n009e:=0
n009o:=0
n010:=0
n010e:=0
n010o:=0
n011:=0
n011e:=0
n011o:=0
n013:=0
n013e:=0
n013o:=0
n014:=0
n014e:=0
n014o:=0
n023:=0
a002:={}
a002e:={}
a002o:={}
a003:={}
a003e:={}
a003o:={}
a006:={}
a006e:={}
a006o:={}
a007:={}
a007e:={}
a007o:={}
a009:={}
a009e:={}
a009o:={}
a012:={}
a012e:={}
a012o:={}
aTit:={}
aGnr:={}
aObs:={}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para realizacao da impressao de Creditos   ³
//³ Acumulados - Exportacoes e Outras Hipoteses          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin001 := 0
nLin004	:= 0
nLin005	:= 0
nLin008	:= 0
nLin009	:= 0
nLin010	:= 0
nLin011 := 0
nLin013	:= 0
nLin014	:= 0
aA002	:= {}
aA003	:= {}
aA006	:= {}
aA007	:= {}
aA012	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega informacoes dos arquivos .IC?                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aArqApur:={}
If nApuracao==1.or.nApuracao==2.or.!lConcilia
	AADD(aArqApur,NmArqApur("IC",nAno,nMes,nApuracao,nPerApurado,cNrLivro))
Else
	Do Case
		Case nApuracao==3
			nMesIni:=nMes
			nMesFim:=nMes
		Case nApuracao==4
			nMesIni:=If(nPerApurado==1,1,7)
			nMesFim:=If(nPerApurado==1,6,12)
		Case nApuracao==5
			nMesIni:=1
			nMesFim:=12
	EndCase
	For i:=nMesIni to nMesFim
		AADD(aArqApur,NmArqApur("IC",nAno,i,1,0,cNrLivro))
		AADD(aArqApur,NmArqApur("IC",nAno,i,1,1,cNrLivro))
		AADD(aArqApur,NmArqApur("IC",nAno,i,1,2,cNrLivro))
		AADD(aArqApur,NmArqApur("IC",nAno,i,1,3,cNrLivro))
	Next i
Endif

lImp		:=.F.
SetRegua(Len(aArqApur))
For i:=1 to Len(aArqApur)
	IncRegua()
	nPeriodo:=i
	cArqApur:=aArqApur[i]

	If !lArqST
		nTanapur := Len(Alltrim(aArqApur[i]))
		cArqST := Substr(aArqApur[i],1,nTanapur-4)+".ST"+Substr(aArqApur[i],Len(Alltrim(aArqApur[1])),1)
		lArqST := File(cArqST)
	Endif

	If (File(cArqApur))
		FT_FUse(cArqApur)
		FT_FGotop()
		aCampos		:=	{.f.,.f.,.f.,.f.,.f.}
		aCamposE	:=	{.f.,.f.,.f.,.f.,.f.}
		aCamposO	:=	{.f.,.f.,.f.,.f.,.f.}
		While(!FT_FEof())
			cLinha		:= AllTrim(FT_FReadLN())
			nTamLinha 	:= Len(cLinha)+1
			cCampo		:=	Substr(cLinha,1,3)
			If cLinha <> Chr(10) .And. cLinha <> Chr(0)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega valor numerico e descricao                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Substr(cLinha,1,3)$"EXP/OUT"
					If IsDigit(Substr(cLinha,5,3)).and.IsDigit(Substr(cLinha,5,1))
						cValor	:=	Substr(cLinha,52,18)
						cValor	:=	StrTran(cValor,'.')
						cValor	:=	StrTran(cValor,',','.')
						_parametros:={Val(cValor),.F.}
						R941Cv()
						nValor	:=	_retorno
						cTexto	:=	Substr(cLinha,9,50)
					Else
						nValor	:=	0
						cTexto	:=	Substr(cLinha,9)
					Endif
				Else
					If IsDigit(Substr(cCampo,1,1)).and.IsDigit(Substr(cCampo,3,1))
						cValor	:=	Substr(cLinha,52,18)
						cValor	:=	StrTran(cValor,'.')
						cValor	:=	StrTran(cValor,',','.')
						_parametros:={Val(cValor),.F.}
						R941Cv()
						nValor	:=	_retorno
						cTexto	:=	Substr(cLinha,5,50)
					Else
						nValor	:=	0
						cTexto	:=	Substr(cLinha,5)
					Endif
				Endif
				Do Case
					Case cCampo=='001'
						n001	+=	nValor
					Case cCampo=='002'
						If aCampos[1]
							AADD(a002,{cTexto,nValor,0})
						Else
							aCampos[1]:=.t.
						Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Validação removida para atender solitação da Issue DSERFIS2-936,³
				//  pois ao utilizar a palavra Devolucoes para discriminar o estorno³
				//  não acrescenta a linha do ajuste.                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case cCampo=='003'
						If aCampos[2]
							//If "DEVOLUCOES"$cTexto		// LANCA DEV. COMPRA
								//n001+=nValor
							//Else
								AADD(a003,{cTexto,nValor,0})
							//Endif
						Else
							aCampos[2]:=.t.
						Endif
					Case cCampo=='005'
						n005	+=	nValor
					Case cCampo=='006'
						If aCampos[3]
							AADD(a006,{cTexto,nValor,0})
						Else
							aCampos[3]:=.t.
						Endif
					Case cCampo=='007'
						If aCampos[4]
							//If "DEVOLUCOES"$cTexto
								//n005+=nValor			// LANCA DEVOLUCOES DE VENDA
							//Else
								AADD(a007,{cTexto,nValor,0})
							//Endif
						Else
							aCampos[4]:=.t.
						Endif
					Case cCampo=='009' .and. (nPerApurado!=4.or.(nPerApurado==4.and.i==1))
						n009+=nValor
						fAcmST( cEstado, nValor )	// acumula saldo anterior - Cristiam Rossi em 25/02/2019
					Case cCampo=='012'
						If aCampos[5]
							AADD(a012,{cTexto,nValor,0})
						Else
							aCampos[5]:=.t.
						Endif
					Case cCampo=='TIT'
						If nTamLinha >84
							cTit := "TÍTULO: " + Substr(cTexto,1,TamSX3("F2_DOC")[1]) + Space(03) + "DATA: " + Substr(cTexto,TamSX3("F2_DOC")[1]+1,18) + Space(03) + "VALOR: " + alltrim(Substr(cTexto,35,35))
						Else
							cTit := "TÍTULO: " + Substr(cTexto,1,9) + Space(03) + "DATA: " + Substr(cTexto,10,18) + Space(03) + "VALOR: " + alltrim(Substr(cTexto,35,35))
						Endif
						AAdd( aTit, cTit )
					Case cCampo=='GNR'
						If nTamLinha >90
							cGnr := Substr(cTexto,1,12) + Space(01) + SubStr(cTexto,14,10) + Space(01) + SubStr(cTexto,57,16) + Space(03) + Substr(cTexto,25,32)
						Else
							cGnr := Substr(cTexto,1,12) + Space(03) + SubStr(cTexto,14,8) + Space(03) + SubStr(cTexto,57,14) + Space(03) + Substr(cTexto,23,30)
						Endif
						AAdd( aGnr, cGnr )
					Case cCampo=='OBS'
						AADD(aObs,cTexto)
					Case cCampo=='015'
						n015 += nValor
					Case cCampo=='016' .And. mv_par19==1
						AADD(aObs,Trim(cTexto)+" : "+Transform(nValor,"@E 999,999,999,999.99"))
					Case cCampo=='017'
						n017 += nValor
					Case cCampo=='023'
						n023	+=	nValor
					Case cCampo=='FOM' //Fomentar - GO
						// Insiro uma linha no comeco para que separe o relatorio do Fomentar das outras obs.
						If !lImp
							AADD(aObs,"")
							AADD(aObs,"--------------------------------------------------------------------------------------------------------------------------------")
							AADD(aObs,Substr(cTexto,5,Len(cTexto)))
							AADD(aObs,"--------------------------------------------------------------------------------------------------------------------------------")
							lImp := .T.
						Else
							// Imprimo o relatorio do Fomentar
							cTextFom	:= Substr(cTexto,5,Len(cTexto)-14)
							nValFom	    := Val(Substr(cTexto,Len(cTexto)-14,16))
							If Substr(cTexto,1,1)$"01"
								AADD(aObs,cTextFom+Transform(nValFom,"@E 999,999,999.99"))
							Else
								AADD(aObs,cTextFom)
							Endif
						Endif
						// Insiro uma linha no final para que separe o relatorio do Fomentar das outras obs.
						If Substr(Alltrim(cTexto),1,3) == "084"
							AADD(aObs,"--------------------------------------------------------------------------------------------------------------------------------")
							AADD(aObs,"")
						Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³   CREDITO ACUMULADO - EXPORTACOES                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case cCampo=="EXP" .And. Substr(clinha,5,3) == "001"
						n001e	:=	0
					Case cCampo=="EXP" .And. Substr(clinha,5,3) == "002"
						If aCamposE[1]
							AADD(a002e,{cTexto,nValor,0})
						Else
							aCamposE[1]:=.t.
						Endif
					Case cCampo=="EXP" .And. Substr(clinha,5,3) == "003"
						If aCamposE[2]
							//If "DEVOLUCOES"$cTexto		// LANCA DEV. COMPRA
								//n001e+=0
							//Else
								AADD(a003e,{cTexto,nValor,0})
							//Endif
						Else
							aCamposE[2]:=.t.
						Endif
					Case cCampo=="EXP" .And. Substr(clinha,5,3) == "005"
						n005e	:=	0
					Case cCampo=="EXP" .And. Substr(clinha,5,3) == "006"
						If aCamposE[3]
							AADD(a006e,{cTexto,nValor,0})
						Else
							aCamposE[3]:=.t.
						Endif
					Case cCampo=="EXP" .And. Substr(clinha,5,3) == "007"
						If aCamposE[4]
							//If "DEVOLUCOES"$cTexto
								//n005e:=0			// LANCA DEVOLUCOES DE VENDA
							//Else
								AADD(a007e,{cTexto,nValor,0})
							//Endif
						Else
							aCamposE[4]:=.t.
						Endif
					Case cCampo=="EXP" .And. Substr(clinha,5,3) == "012"
						If aCamposE[5]
							AADD(a012e,{cTexto,nValor,0})
						Else
							aCamposE[5]:=.t.
						Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³   CREDITO ACUMULADO - OUTRAS HIPOTESES                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case cCampo=="OUT" .And. Substr(clinha,5,3) == "001"
						n001o	:=	0
					Case cCampo=="OUT" .And. Substr(clinha,5,3) == "002"
						If aCamposO[1]
							AADD(a002o,{cTexto,nValor,0})
						Else
							aCamposO[1]:=.t.
						Endif
					Case cCampo=="OUT" .And. Substr(clinha,5,3) == "003"
						If aCamposO[2]
							//If "DEVOLUCOES"$cTexto		// LANCA DEV. COMPRA
								//n001o+=0
							//Else
								AADD(a003o,{cTexto,nValor,0})
							//Endif
						Else
							aCamposO[2]:=.t.
						Endif
					Case cCampo=="OUT" .And. Substr(clinha,5,3) == "005"
						n005o	:=	0
					Case cCampo=="OUT" .And. Substr(clinha,5,3) == "006"
						If aCamposO[3]
							AADD(a006o,{cTexto,nValor,0})
						Else
							aCamposO[3]:=.t.
						Endif
					Case cCampo=="OUT" .And. Substr(clinha,5,3) == "007"
						If aCamposO[4]
							//If "DEVOLUCOES"$cTexto
								n005o:=0			// LANCA DEVOLUCOES DE VENDA
							//Else
								AADD(a007o,{cTexto,nValor,0})
							//Endif
						Else
							aCamposO[4]:=.t.
						Endif

					Case cCampo=="OUT" .And. Substr(clinha,5,3) == "009"
						AADD(a009o,{cTexto,nValor,0})

					Case cCampo=="OUT" .And. Substr(clinha,5,3) == "012"
						If aCamposO[5]
							AADD(a012o,{cTexto,nValor,0})
						Else
							aCamposO[5]:=.t.
						Endif
			   		Case cCampo=='042' .And. mv_par19==1 .And. nValor > 0
					   For nXF := 1 To Len(aObs)
							If "ICMS Complementar (Diferencial de Aliquotas) :  " $ aObs[nXF]
								aObs[nXF] := "ICMS Complementar (Diferencial de Aliquotas) :  "+ Transform((Val(StrTran(StrTran( Alltrim(substr(aObs[nXF],47,(Len(aObs[nXF])))),".",""),",","."))),"@E 999,999.99" )
							EndIf
						Next(nXF)
						AADD(aObs,Trim(cTexto)+" : "+Transform(nValor,"@E 999,999,999,999.99"))
				EndCase
			EndIf
			If cCampo == "046" .And. nValor > 0 .And. SuperGetMV("MV_ESTADO") = "MG"
				nValAntMG := nValor
			EndIf
			FT_FSkip()
		EndDo
	EndIf
next
FT_FUse()

If lConverte
	AADD(aObs,"VALORES DA APURACAO CONVERTIDOS EM "+SuperGetMv("MV_INDXEST")+", VALOR DA "+SuperGetMv("MV_INDXEST")+": "+SuperGetMv("MV_SIMB1")+Transform(nIndice,"@E 9.999")) //"VALORES DA APURACAO CONVERTIDOS EM "###", VALOR DA "
EndIf

If lCrdEst
	aL[01]		:="STR0086"
	aL[02]		:="STR0091"
	aImpostos	:=&(SuperGetMv("MV_CRDEST"))
	nFMPE		:=0
	nUEA		:=0
	lImp		:=.F.
	For i:=1 to Len(aEstimulo)
		nScan		:=ASCAN(aImpostos,{|x|x[1]==aEstimulo[i,1]})
		If nScan>0
			If !lImp
				AADD(aObs,"STR0088")

				AADD(aObs,"RESUMO DA APURACAO DO ICMS RESTITUIVEL - CREDITO ESTIMULO")
				AADD(aObs,"+--------------+--------------+--------------+--------+--------------+--------------+------------+------------+------------+")
				AADD(aObs,"| Entradas     | Saidas       | Saldo Devedor| % Rest.| Crd Estimulo |Crd N Estimulo|   FMPE     |    U.E.A   |   F.T.I.   |")
				AADD(aObs,"+--------------+--------------+--------------+--------+--------------+--------------+------------+------------+------------+")
				lImp	:=.T.
			Endif
			nFMPE	:=(aEstimulo[i,3]-aEstimulo[i,2])*(aImpostos[nScan,2,1])/100
			nUEA		:=(aEstimulo[i,3]-aEstimulo[i,2])*(aImpostos[nScan,2,2])/100
		Endif
		If (aEstimulo[i,3]-aEstimulo[i,2])>0 .and. aEstimulo[i,1]>0
			AADD(aObs,FmtLin({Transform(aEstimulo[i,5],"@E 99,999,999.99"),Transform(aEstimulo[i,7],"@E 99,999,999.99"),Transform(ABS(aEstimulo[i,7]-aEstimulo[i,5]),"@E 99,999,999.99"),Transform(aEstimulo[i,1],"@E 999.99%"),Transform(ABS(aEstimulo[i,3]-aEstimulo[i,2]),"@E 99,999,999.99"),Transform(ABS(aEstimulo[i,7]-aEstimulo[i,5]-ABS(aEstimulo[i,3]-aEstimulo[i,2])),"@E 99,999,999.99"),Transform(nFMPE,"@E 9999,999.99"),Transform(nUEA,"@E 9999,999.99"),Transform(aEstimulo[i,8],"@E 9999,999.99"),Transform(aEstimulo[i,9],"@E 9999,999.99")},aL[01],,,@nLin, .F.))
			AADD(aObs,"STR0087")
		Endif
	Next
	If Len(aIncent)>0
		AADD(aObs,"STR0088")
		AADD(aObs,"DEMONSTRATIVO DE OPERACOES NAO INCENTIVADAS")
		AADD(aObs," Base Calculo - Entradas      ICMS Entradas     Base Calculo - Saidas      ICMS Saidas      D/C Nao Incentivada  ")
		AADD(aObs,FmtLin({Transform(aIncent[1,2],"@E 99,999,999.99"),Transform(aIncent[1,3],"@E 99,999,999.99"),Transform(aIncent[1,4],"@E 99,999,999.99"),Transform(aIncent[1,5],"@E 99,999,999.99"),Transform(aIncent[1,5]-aIncent[1,3],"@E 99,999,999.99")},aL[02],,,@nLin, .F.))
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz nova totalizacao dos arquivos de apuracao                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ totaliza saidas                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
n004	+=	n001
For i:=1 to Len(a002)
	a002[Len(a002),3]:=a002[Len(a002),3]+a002[i,2]
	n004	+=	a002[i,2]
Next
For i:=1 to Len(a003)
	a003[Len(a003),3]:=a003[Len(a003),3]+a003[i,2]
	n004	+=	a003[i,2]
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ totaliza entradas                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
n008+=n005
For i:=1 to Len(a006)
	a006[Len(a006),3]:=a006[Len(a006),3]+a006[i,2]
	n008+=a006[i,2]
Next
For i:=1 to Len(a007)
	a007[Len(a007),3]:=a007[Len(a007),3]+a007[i,2]
	n008+=a007[i,2]
Next
n010+=n008+n009
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ totaliza apuracao                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
n011	:= if(n004-n010 >0,n004-n010,0)
n013	:=	n004-n010
For i:=1 to Len(a012)
	a012[Len(a012),3]:=a012[Len(a012),3]+a012[i,2]
	n013	:= n013-a012[i,2]
Next
If n013<0
	n014:=Abs(n013)
	n013:=0
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CREDITO ACUMULADO - BAHIA                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lApurBa
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ EXPORTACOES              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    //Totaliza Entradas
    n004e	+=	n001e
	For i:=1 to Len(a002e)
		a002e[Len(a002e),3]:=a002e[Len(a002e),3]+a002e[i,2]
		n004e	+=	a002e[i,2]
	Next
	//Totaliza Saidas
	n008e+=n005e
	For i:=1 to Len(a006e)
		a006e[Len(a006e),3]:=a006e[Len(a006e),3]+a006e[i,2]
		n008e+=a006e[i,2]
	Next
	For i:=1 to Len(a007e)
		a007e[Len(a007e),3]:=a007e[Len(a007e),3]+a007e[i,2]
		n008e+=a007e[i,2]
	Next
	n010e+=n008e+n009e
    //Totaliza Apuracao
	n011e	:= if(n004e-n010e >0,n004e-n010e,0)
	n013e	:=	n004e-n010e
	For i:=1 to Len(a012e)
		a012e[Len(a012e),3]:=a012e[Len(a012e),3]+a012e[i,2]
		n013e	:= n013e-a012e[i,2]
	Next
	If n013e<0
		n014e:=Abs(n013e)
		n013e:=0
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ OUTRAS HIPOTESES         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    //Totaliza Entradas
    n004o	+=	n001o
	For i:=1 to Len(a002o)
		a002o[Len(a002o),3]:=a002o[Len(a002o),3]+a002o[i,2]
		n004o	+=	a002o[i,2]
	Next
	//Totaliza Saidas
	n008o+=n005o
	For i:=1 to Len(a006o)
		a006o[Len(a006o),3]:=a006o[Len(a006o),3]+a006o[i,2]
		n008o+=a006o[i,2]
	Next
	For i:=1 to Len(a007o)
		a007o[Len(a007o),3]:=a007o[Len(a007o),3]+a007o[i,2]
		n008o+=a007o[i,2]
	Next
	For i:=1 to Len(a009o)
		a009o[Len(a009o),3]:=a009o[Len(a009o),3]+a009o[i,2]
		n008o+=a009o[i,2]
		n009o:=a009o[i,2]
	Next
	n010o+=n008o
    //Totaliza Apuracao
	n011o	:= if(n004o-n010o >0,n004o-n010o,0)
	n013o	:=	n004o-n010o
	For i:=1 to Len(a012o)
		a012o[Len(a012o),3]:=a012o[Len(a012o),3]+a012o[i,2]
		n013o	:= n013o-a012o[i,2]
	Next
	If n013o<0
		n014o:=Abs(n013o)
		n013o:=0
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime valores                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCaoa//Imprime somente Substituição Tributária
For K := 1 to 2
	cImprimindo:="RE_DEB"
	nLin:=80
	if K ==2 .and. n015 <> 0 .and. !lArqST
		n001:=n009:=n010:=n011:=n005:=n008:=n014:=0
		a002:={};a003:={};a006:={};a007:={};a012:={};aObs:={}
		n015:= (n015+n017)
		n004:= n015
		n005:= n017
		n008:= n005
		n013:= (n004-n008)
		n010:= (n008)
		n011 := (n004-n010)
		aTit :={}
		aGnr := {}
		R941Cabec(.t.)
		SetRegua(30)
	elseif (K==2 .and. n015 =0) .or.(K==2 .and. lArqST)
		exit
	else
		R941Cabec(.f.)
		SetRegua(30)
	endif

	While !lAbortPrint
		If Interrupcao(@lAbortPrint)
			Loop
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Debitos                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		j:=4
		if k ==1
			FmtLin({WriteVer("DEBITO",j),n001},aL[41],cPictVal,,@nLin) //"DEBITO"
		else
			FmtLin({WriteVer("DEBITO",j),n015},aL[41],cPictVal,,@nLin) //"DEBITO"
		endif
		R941Cab2()
		j:=j+1
		FmtLin({WriteVer("DEBITO",j)},aL[42],,,@nLin) //"DEBITO"
		R941Cab2()
		For i:=1 to Len(a002)
			j:=j+1
			FmtLin({WriteVer("DEBITO",j),a002[i,1],a002[i,2],a002[i,3]},aL[43],cPictVal,,@nLin) //"DEBITO"
			R941Cab2()
		Next i
		j:=j+1
		FmtLin({WriteVer("DEBITO",j)},aL[44],,,@nLin) //"DEBITO"
		R941Cab2()
		For i:=1 to Len(a003)
			j:=j+1
			FmtLin({WriteVer("DEBITO",j),a003[i,1],a003[i,2],a003[i,3]},aL[45],cPictVal,,@nLin) //"DEBITO"
			R941Cab2()
		Next i
		j:=j+1
		FmtLin({WriteVer("DEBITO",j),n004},Iif(!lGiaSP,aL[46],aL[96]),cPictVal,,@nLin) //"DEBITO"
		R941Cab2()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Debitos                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lAbortPrint)
			Loop
		EndIf
		j:=0
		cImprimindo:="RE_CRE"
		FmtLin(,{aL[47],aL[48]},,,@nLin)
		R941Cab2()
		j:=j+1
		FmtLin({WriteVer("CREDITO",j)},aL[49],,,@nLin) //"CREDITO"
		R941Cab2()
		j:=j+1
		FmtLin({WriteVer("CREDITO",j),n005},Iif(!lGiaSP,aL[50],aL[100]),cPictVal,,@nLin) //"CREDITO"
		R941Cab2()
		j:=j+1
		FmtLin({WriteVer("CREDITO",j)},Iif(!lGiaSP,aL[51],aL[101]),,,@nLin) //"CREDITO"
		R941Cab2()
		For i:=1 to Len(a006)
			j:=j+1
			FmtLin({WriteVer("CREDITO",j),a006[i,1],a006[i,2],a006[i,3]},aL[52],cPictVal,,@nLin) //"CREDITO"
			R941Cab2()
		Next i
		j:=j+1
		FmtLin({WriteVer("CREDITO",j)},Iif(!lGiaSP,aL[53],aL[103]),,,@nLin) //"CREDITO"
		R941Cab2()
		For i:=1 to Len(a007)
			j:=j+1
			FmtLin({WriteVer("CREDITO",j),a007[i,1],a007[i,2],a007[i,3]},aL[54],cPictVal,,@nLin) //"CREDITO"
			R941Cab2()
		Next i
		j:=j+1
		FmtLin({WriteVer("CREDITO",j),n008},Iif(!lGiaSP,aL[55],aL[105]),cPictVal,,@nLin) //"CREDITO"
		R941Cab2()
		j:=j+1
		FmtLin({WriteVer("CREDITO",j),n009},Iif(!lGiaSP,aL[56],aL[106]),cPictVal,,@nLin) //"CREDITO"
		R941Cab2()
		j:=j+1
		FmtLin({WriteVer("CREDITO",j),n010},Iif(!lGiaSP,aL[57],aL[107]),cPictVal,,@nLin) //"CREDITO"
		R941Cab2()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Saldo                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lAbortPrint)
			Loop
		EndIf
		j:=0
		cImprimindo:="RE_APU"
		FmtLin(,{aL[58],aL[59]},,,@nLin)
		R941Cab2()
		j:=j+1
		FmtLin({WriteVer("SALDO",j)},aL[60],,,@nLin) //"SALDO"
		R941Cab2()
		j:=j+1
		FmtLin({WriteVer("SALDO",j),n011},Iif(!lGiaSP,aL[61],aL[111]),cPictVal,,@nLin) //"SALDO"
		R941Cab2()
		j:=j+1
		FmtLin({WriteVer("SALDO",j)},Iif(!lGiaSP,aL[62],aL[112]),,,@nLin) //"SALDO"
		R941Cab2()
		For i:=1 to Len(a012)
			j:=j+1
			FmtLin({WriteVer("SALDO",j),a012[i,1],a012[i,2],a012[i,3]},aL[63],cPictVal,,@nLin) //"SALDO"
			R941Cab2()
		Next i
		j:=j+1
		FmtLin({WriteVer("SALDO",j),n013},Iif(!lGiaSP,aL[64],aL[114]),cPictVal,,@nLin) //"SALDO"
		R941Cab2()
		j:=j+1
		FmtLin({WriteVer("SALDO",j),n014},Iif(!lGiaSP,aL[65],aL[115]),cPictVal,,@nLin) //"SALDO"
		R941Cab2()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Informacoes complementares                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lAbortPrint)
			Loop
		EndIf
		j:=0
		cImprimindo:="RE_INF"
		FmtLin(,{aL[66],aL[67],aL[68],aL[69],aL[70],aL[71]},,,@nLin)
		R941Cab2()

		If Len(aGnr) == 0
			FmtLin({Space(71),DtoC(dDtEntrega),cLocEntrega},aL[72],,,@nLin)
			R941Cab2()
		Endif

		For i:=1 to Len(aGnr)
			If i==1
				FmtLin({aGnr[i],DtoC(dDtEntrega),cLocEntrega},aL[72],,,@nLin)
				R941Cab2()
			Else
				FmtLin({aGnr[i]},aL[73],,,@nLin)
				R941Cab2()
			Endif
		Next


		FmtLin(,aL[74],,,@nLin)
		R941Cab2()
		If nValAntMG > 0
			AADD(aObs,"STR0099"+Transform(nValAntMG,"@E 99,999,999.99"))
		EndIf
		For i:=1 to Len(aObs)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Corrigido para quebrar pagina quando houver observacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nLin>51 .And. i==1) .Or. nLin > 58
				R941Cabec(.f.)
			Endif

			If i==1
				FmtLin({aObs[i]},aL[75],,,@nLin)
			Else
				FmtLin({aObs[i]},aL[76],,,@nLin)
			Endif

		Next

		For i:=1 to Len(aTit)
			If Len(aObs) == 0 .And. i == 1
				FmtLin({Space(14)+aTit[i]},aL[75],,,@nLin)
			Else
				FmtLin({aTit[i]},aL[76],,,@nLin)
			Endif
			R941Cab2()
		Next i
		While nLin<58
			FmtLin(,aL[74],,,@nLin)
		End
		FmtLin(,aL[01],,,@nLin)
		Exit
	End

Next
EndIf//If !lCaoa//Imprime somente Substituição Tributária

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Credito Acumulado - Bahia                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCaoa//Imprime somente Substituição Tributária
If lApurBa
	For K := 1 to 2
	    //1 - Exportacoes
	    //2 - Outras Hipoteses
		If k == 1
			nLin001 := n001e
			aA002	:= a002e
			aA003	:= a003e
			nLin004	:= n004e
			nLin005	:= n005e
			aA006	:= a006e
			aA007	:= a007e
			nLin008	:= n008e
			nLin009	:= n009e
			nLin010	:= n010e
			nLin011 := n011e
			aA012	:= a012e
			nLin013	:= n013e
			nLin014	:= n014e
		Else
			nLin001 := n001o
			aA002	:= a002o
			aA003	:= a003o
			nLin004	:= n004o
			nLin005	:= n005o
			aA006	:= a006o
			aA007	:= a007o
			nLin008	:= n008o
			nLin009	:= n009o
			nLin010	:= n010o
			nLin011 := n011o
			aA012	:= a012o
			nLin013	:= n013o
			nLin014	:= n014o
		Endif
		cImprimindo:="RE_DEB"
		nLin:=80
		R941Cabec(.f.)
		SetRegua(30)

		While !lAbortPrint
			If Interrupcao(@lAbortPrint)
				Loop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Debitos                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			j:=4
			FmtLin({WriteVer("DEBITO",j),nLin001},aL[41],cPictVal,,@nLin)
			R941Cab2()
			j:=j+1
			FmtLin({WriteVer("DEBITO",j)},aL[42],,,@nLin)
			R941Cab2()
			For i:=1 to Len(aA002)
				j:=j+1
				FmtLin({WriteVer("DEBITO",j),aA002[i,1],aA002[i,2],aA002[i,3]},aL[43],cPictVal,,@nLin)
				R941Cab2()
			Next i
			j:=j+1
			FmtLin({WriteVer("DEBITO",j)},aL[44],,,@nLin)
			R941Cab2()
			For i:=1 to Len(aA003)
				j:=j+1
				FmtLin({WriteVer("DEBITO",j),aA003[i,1],aA003[i,2],aA003[i,3]},aL[45],cPictVal,,@nLin)
				R941Cab2()
			Next i
			j:=j+1
			FmtLin({WriteVer("DEBITO",j),nLin004},Iif(!lGiaSP,aL[46],aL[96]),cPictVal,,@nLin)
			R941Cab2()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Creditos                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Interrupcao(@lAbortPrint)
				Loop
			EndIf
			j:=0
			cImprimindo:="RE_CRE"
			FmtLin(,{aL[47],aL[48]},,,@nLin)
			R941Cab2()
			j:=j+1
			FmtLin({WriteVer("CREDITO",j)},aL[49],,,@nLin)
			R941Cab2()
			j:=j+1
			FmtLin({WriteVer("CREDITO",j),nLin005},Iif(!lGiaSP,aL[50],aL[100]),cPictVal,,@nLin)
			R941Cab2()
			j:=j+1
			FmtLin({WriteVer("CREDITO",j)},Iif(!lGiaSP,aL[51],aL[101]),,,@nLin)
			R941Cab2()
			For i:=1 to Len(aA006)
				j:=j+1
				FmtLin({WriteVer("CREDITO",j),aA006[i,1],aA006[i,2],aA006[i,3]},aL[52],cPictVal,,@nLin)
				R941Cab2()
			Next i
			j:=j+1
			FmtLin({WriteVer("CREDITO",j)},Iif(!lGiaSP,aL[53],aL[103]),,,@nLin)
			R941Cab2()
			For i:=1 to Len(aA007)
				j:=j+1
				FmtLin({WriteVer("CREDITO",j),aA007[i,1],aA007[i,2],aA007[i,3]},aL[54],cPictVal,,@nLin)
				R941Cab2()
			Next i
			j:=j+1
			FmtLin({WriteVer("CREDITO",j),nLin008},Iif(!lGiaSP,aL[55],aL[105]),cPictVal,,@nLin)
			R941Cab2()
			j:=j+1
			FmtLin({WriteVer("CREDITO",j),nLin009},Iif(!lGiaSP,aL[56],aL[106]),cPictVal,,@nLin)
			R941Cab2()
			j:=j+1
			FmtLin({WriteVer("CREDITO",j),nLin010},Iif(!lGiaSP,aL[57],aL[107]),cPictVal,,@nLin)
			R941Cab2()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Saldo                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Interrupcao(@lAbortPrint)
				Loop
			EndIf
			j:=0
			cImprimindo:="RE_APU"
			FmtLin(,{aL[58],aL[59]},,,@nLin)
			R941Cab2()
			j:=j+1
			FmtLin({WriteVer("SALDO",j)},aL[60],,,@nLin)
			R941Cab2()
			j:=j+1
			FmtLin({WriteVer("SALDO",j),nLin011},Iif(!lGiaSP,aL[61],aL[111]),cPictVal,,@nLin)
			R941Cab2()
			j:=j+1
			FmtLin({WriteVer("SALDO",j)},Iif(!lGiaSP,aL[62],aL[112]),,,@nLin)
			R941Cab2()
			For i:=1 to Len(aA012)
				j:=j+1
				FmtLin({WriteVer("SALDO",j),aA012[i,1],aA012[i,2],aA012[i,3]},aL[63],cPictVal,,@nLin)
				R941Cab2()
			Next i
			j:=j+1
			FmtLin({WriteVer("SALDO",j),nLin013},Iif(!lGiaSP,aL[64],aL[114]),cPictVal,,@nLin)
			R941Cab2()
			j:=j+1
			FmtLin({WriteVer("SALDO",j),nLin014},Iif(!lGiaSP,aL[65],aL[115]),cPictVal,,@nLin)
			R941Cab2()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Informacoes complementares                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Interrupcao(@lAbortPrint)
				Loop
			EndIf
			j:=0
			cImprimindo:="RE_INF"
			FmtLin(,{aL[66],aL[67],aL[68]},,,@nLin)
			R941Cab2()
			FmtLin(,aL[74],,,@nLin)
			R941Cab2()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Corrigido para quebrar pagina quando houver observacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nLin>51 .And. i==1) .Or. nLin > 58
				R941Cabec(.f.)
			Endif

			If K == 1
				FmtLin(,aL[120],,,@nLin) //Exportacoes
			Else
				FmtLin(,aL[121],,,@nLin) //Outras hipoteses
			Endif

			While nLin<58
				FmtLin(,aL[74],,,@nLin)
			End
			FmtLin(,aL[01],,,@nLin)
			Exit
		End
	Next
Endif
EndIf//If !lCaoa//Imprime somente Substituição Tributária

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Resumo por estado das operacoes interestaduais ³
//³no caso de Substituicao Tributaria.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lResST
	If (SuperGetMv ("MV_ESTADO")$"RJ/SP")
		ImpSt (@nNivel, aResEntr, aResSaid, @lAbortPrint, cMv_UfSt, @nLin, lImpCrdSt, @aTOTAL, aL, @nEntUFST, cEstado)
	Else
		ImpSt (@nNivel, aResEntr, aResSaid, @lAbortPrint, cMv_UfSt, @nLin, lImpCrdSt, @aTOTAL, aL, @nEntUFST,)
		R941LeST()
	EndIf
EndIf

resCAOA( @nLin ) // resumo modelo CAOA - Cristiam Rossi em 22/02/2019

If lAbortPrint
	Return
Endif

Return nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³R941LeST  ºAutor  ³Andreia dos Santos  º Data ³  10/04/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Le informacoes de ST do arquivo de apuracao e imprime       º±±
±±º          ³resumo de Apuracao ICMS Substituicao Tributaria             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR941                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function R941LeST()
Local i,j
Local 	aCampos
Local 	cArqST
Local 	cValor
Local 	cCampo
Local 	cLinha
Local 	cTexto
Local 	nValor
Local 	a002	:= {}
Local 	a003	:= {}
Local 	a007	:= {}
Local 	a008	:= {}
Local 	a014	:= {}
Local 	n001	:=	0
Local 	n005	:=	0
Local 	n006	:=	0
Local 	n010	:=	0
Local 	n011	:=	0
Local 	n012	:=	0
Local 	n013	:=	0
Local 	n015	:=	0
Local 	n016	:=	0
Local	aTit	:= {}
Local	aGnr	:= {}
Local	aObs	:= {}
Local	lR941ST	:=	SuperGetMv("MV_R941ST")
Local	nExclDeb	:=	0
Local	nExclCre	:=	0
Local	cExclApu	:=	""
Local	nTanapur	:= ""

For i:=1 to Len(aArqApur)
	IncRegua()
	nPeriodo:=i
	nTanapur := Len(Alltrim(aArqApur[i]))
	cArqST := Substr(aArqApur[i],1,nTanapur-4)+".ST"+Substr(aArqApur[i],Len(Alltrim(aArqApur[1])),1)
	If (File(cArqST))
		FT_FUse(cArqST)
		FT_FGotop()
		aCampos		:=	{.f.,.f.,.f.,.f.,.f.}
		While(!FT_FEof())
			cLinha		:= AllTrim(FT_FReadLN())
			nTamLinha 	:= Len(cLinha)+1
			cCampo		:=	Substr(cLinha,1,3)
			If cLinha <> Chr(10) .And. cLinha <> Chr(0)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega valor numerico e descricao                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If IsDigit(Substr(cCampo,1,1)).and.IsDigit(Substr(cCampo,3,1))
					cValor	:=	Substr(cLinha,52,18)
					cValor	:=	StrTran(cValor,'.')
					cValor	:=	StrTran(cValor,',','.')
					_parametros:={Val(cValor),.F.}
					R941Cv()
					nValor	:=	_retorno
					cTexto	:=	Substr(cLinha,5,50)
					cExclApu:=Substr(cLinha,115,1)
				Else
					nValor	:=	0
					cTexto	:=	Substr(cLinha,5)
				Endif
				Do Case
				Case cCampo=='001'
			  		n001	+=	nValor
				Case cCampo=='002'
					If aCampos[1]
						If cExclApu=="T"
							nExclDeb	+=	nValor
						EndIf
						AADD(a002,{cTexto,nValor,0})
					Else
						aCampos[1]:=.t.
					Endif
				Case cCampo=='003'
					If aCampos[2]
						//If "DEVOLUCOES"$cTexto		// LANCA DEV. COMPRA
							//n001+=nValor
						//Else
							AADD(a003,{cTexto,nValor,0})
						//Endif
					Else
						aCampos[2]:=.t.
					Endif
				Case cCampo=='006'//Por entradas com credito do imposto
					n006 += nValor
				Case cCampo=='007' //Outros creditos
					If aCampos[3]
						If cExclApu=="T"
							nExclCre	+=	nValor
						EndIf
						AADD(a007,{cTexto,nValor,0})
					Else
						aCampos[3]:=.t.
					Endif
				Case cCampo=="008" // Estorno de debitos
					If aCampos[4]
						//If "DEVOLUCOES"$cTexto
							//n006+=nValor			// LANCA DEVOLUCOES DE VENDA
						//Else
							AADD(a008,{cTexto,nValor,0})
						//Endif
					Else
						aCampos[4]:=.t.
					Endif
				Case cCampo=='011' .and. (nPerApurado!=4.or.(nPerApurado==4.and.i==1)) //Saldo credor Per.Ant.
					n011+=nValor
				Case cCampo=='014' //Deducoes
					If aCampos[5]
						AADD(a014,{cTexto,nValor,0})
					Else
						aCampos[5]:=.t.
					Endif
				Case cCampo=='TIT'
					AAdd( aTit, Substr(cTexto,1,70) )
				Case cCampo=='GNR'
					AAdd( aGnr, Substr(cTexto,1,70) )
				Case cCampo=='OBS'
					AADD(aObs,cTexto)
				EndCase
			EndIf
			FT_FSkip()
		EndDo
   EndIf
Next i
FT_FUse()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atribui os totais por saida e entrada conforme Decreto 27.427 de 17/11/2000 - Artigo 23 - RJ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMv_UFSt
   n001 :=nSaiUFST
   n006 :=nEntUFST
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ totaliza saidas                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
n005 := n001
For i:=1 to Len(a002)
	a002[Len(a002),3] += a002[i,2]
	n005+=a002[i,2]
Next
For i:=1 to Len(a003)
	a003[Len(a003),3]+=a003[i,2]
	n005+=a003[i,2]
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ totaliza entradas                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
n010 := n006

For i:=1 to Len(a007)
	a007[Len(a007),3]+=+a007[i,2]
	n010+=a007[i,2]
Next
For i:=1 to Len(a008)
	a008[Len(a008),3]+=a008[i,2]
	n010+=a008[i,2]
Next

n012 := n010+n011
n013 := if(((n005-nExclDeb)-(n012-nExclCre))>=0,((n005-nExclDeb)-(n012-nExclCre)),0)

n015 := n013

For i:=1 to Len(a014)
	a014[Len(a014),3]+=a014[i,2]
	n015-=a014[i,2]
Next

n016 := if( ((n012-nExclCre)-(n005-nExclDeb)) >=0,((n012-nExclCre)-(n005-nExclDeb)),0)

If (lR941ST) .Or. (n005>0 .Or. n010>0 .Or. n011>0)
   cImprimindo:="RE_DEB"
   nLin:=80
   R941Cabec(.T.)
   SetRegua(30)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime sempre o demontrativo do ICMS ST, já que quando não há movimentação, ³
	//³não há a informação no arquivo de apuração. Imprime sempre zerado nesse caso.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !lAbortPrint

		If Interrupcao(@lAbortPrint)
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Debitos                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		j:=4
		FmtLin({WriteVer("DEBITO",j),n001},aL[91],cPictVal,,@nLin)
		R941Cab2()
		j++
		FmtLin({WriteVer("DEBITO",j)},aL[92],,,@nLin)
		R941Cab2()
		For i:=1 to Len(a002)
			j++
			FmtLin({WriteVer("DEBITO",j),a002[i,1],a002[i,2],a002[i,3]},aL[93],cPictVal,,@nLin)
			R941Cab2()
		Next i
		j++

		FmtLin({WriteVer("DEBITO",j)},aL[94],,,@nLin)
		R941Cab2()
		For i:=1 to Len(a003)
			j++
			FmtLin({WriteVer("DEBITO",j),a003[i,1],a003[i,2],a003[i,3]},aL[95],cPictVal,,@nLin)
			R941Cab2()
		Next i
		j++
		FmtLin({WriteVer("DEBITO",j),n005},aL[96],cPictVal,,@nLin)
		R941Cab2()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Debitos                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lAbortPrint)
			Loop
		EndIf
		j:=0
		cImprimindo:="RE_CRE"
		FmtLin(,{aL[97],aL[98]},,,@nLin)
		R941Cab2()
		j++
		FmtLin({WriteVer("CREDITO",j)},aL[99],,,@nLin)
		R941Cab2()
		j:=j+1
		FmtLin({WriteVer("CREDITO",j),n006},aL[100],cPictVal,,@nLin)
		R941Cab2()
		j++
		FmtLin({WriteVer("CREDITO",j)},aL[101],,,@nLin)
		R941Cab2()
		For i:=1 to Len(a007)
			j++
			FmtLin({WriteVer("CREDITO",j),a007[i,1],a007[i,2],a007[i,3]},aL[102],cPictVal,,@nLin)
			R941Cab2()
		Next i
		j++
		FmtLin({WriteVer("CREDITO",j)},aL[103],,,@nLin)
		R941Cab2()
		For i:=1 to Len(a008)
			j++
			FmtLin({WriteVer("CREDITO",j),a008[i,1],a008[i,2],a008[i,3]},aL[104],cPictVal,,@nLin)
			R941Cab2()
		Next i
		j++
		FmtLin({WriteVer("CREDITO",j),n010},aL[105],cPictVal,,@nLin)
		R941Cab2()
		j++
		FmtLin({WriteVer("CREDITO",j),n011},aL[106],cPictVal,,@nLin)
		R941Cab2()
		j++
		FmtLin({WriteVer("CREDITO",j),n012},aL[107],cPictVal,,@nLin)
		R941Cab2()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Saldo                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lAbortPrint)
			Loop
		EndIf
		j:=0
		cImprimindo:="RE_APU"
		FmtLin(,{aL[108],aL[109]},,,@nLin)
		R941Cab2()
		j++
		FmtLin({WriteVer("SALDO",j)},aL[110],,,@nLin)
		R941Cab2()
		j++
		FmtLin({WriteVer("SALDO",j),n013},aL[111],cPictVal,,@nLin)
		R941Cab2()
		j++
		FmtLin({WriteVer("SALDO",j)},aL[112],,,@nLin)
		R941Cab2()
		For i:=1 to Len(a014)
			j++
			FmtLin({WriteVer("SALDO",j),a014[i,1],a014[i,2],a014[i,3]},aL[113],cPictVal,,@nLin)
			R941Cab2()
		Next i
		j++
		FmtLin({WriteVer("SALDO",j),n015},aL[114],cPictVal,,@nLin)
		R941Cab2()
		j++
		FmtLin({WriteVer("SALDO",j),n016},aL[115],cPictVal,,@nLin)
		R941Cab2()
		FmtLin(,aL[116],,,@nLin)
		While nLin<58
			FmtLin(,aL[74],,,@nLin)
		End
		FmtLin(,aL[01],,,@nLin)
		Exit
	Enddo
EndIf
Return nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R941LayOut() ³Autor ³ Juan Jose Pereira    ³Data³ 17/02/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Armazena lay-out para o modelo P9                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R941LayOut
Local lImp  	 := GetNewPar("MV_IMPCABE",.F.)
Local lMVIMPPAGI := GetMV("MV_IMPPAGI",.F.)

	aL:=Array(121)
	aL[001]:="+----------------------------------------------------------------------------------------------------------------------------------+"
		If lImp
			aL[002]:="|                                                    REGISTRO DE APURACAO DO ICMS  - P9                                                  |"
		Else
			aL[002]:="|                                                    REGISTRO DE APURACAO DO ICMS                                                  |"
		Endif
	aL[003]:="|                                                                                                                                  |"
	aL[004]:="| FIRMA: #########################################################                                                                 |"
	aL[005]:="|                                                                                                                                  |"
	aL[006]:="| INSC.EST.: ######################## C.N.P.J.: #################                                                                  |"
	aL[007]:="|                                                                                                                                  |"
	If !lMVIMPPAGI //!lMVIMPPAGI
		aL[008]:="| FOLHA: ####     MES OU PERIODO/ANO: #########                                                                                    |"
	Else
		aL[008]:="| PAGINA: ####     MES OU PERIODO/ANO: #########                                                                                   |"
	EndIf
	aL[009]:="|                                                                                                                                  |"
	aL[010]:="|==================================================================================================================================|"
	aL[011]:="|                                                         E N T R A D A S                                                          |"
	aL[012]:="|                                                           S A I D A S                                                            |"
	aL[013]:="|==================================================================================================================================|"
	aL[014]:="|               |                   |                                  ICMS - VALORES FISCAIS                                      |"
	aL[015]:="|               |                   |----------------------------------------------------------------------------------------------|"
	aL[016]:="|  CODIFICACAO  |                   |       OPERACOES COM CREDITO DO IMPOSTO      |        OPERACOES SEM CREDITO DO IMPOSTO        |"
	aL[017]:="|  CODIFICACAO  |                   |       OPERACOES COM DEBITO DO IMPOSTO       |        OPERACOES SEM DEBITO DO IMPOSTO         |"
	aL[018]:="|---------------|      VALORES      |---------------------------------------------+------------------------------------------------|"
	aL[019]:="|CONTABIL|FISCAL|     CONTABEIS     |   BASE DE CALCULO    |  IMPOSTO #########   |ISENTAS OU NAO TRIBUTADAS|        OUTRAS        |"
	aL[020]:="|========+======|===================|======================+======================+=========================+======================|"
	aL[021]:="|###############| ##################|  ##################  |  ##################  |    ##################   |  ##################  |"
	aL[022]:="|        |######| ##################|  ##################  |  ##################  |    ##################   |  ##################  |"
	aL[023]:="|----------------------------------------------------------------------------------------------------------------------------------|"
	aL[024]:="|SUBTOTAIS ########                 |                      |                      |                         |                      |"
	aL[025]:="|###################################|                      |                      |                         |                      |"
	aL[026]:="|        |      | ##################|  ##################  |  ##################  |    ##################   |  ##################  |"
	aL[027]:="+----------------------------------------------------------------------------------------------------------------------------------+"
	aL[028]:="|                                                    RESUMO DA APURACAO DO IMPOSTO                                                 |"
	aL[029]:="|                                                                                                                                  |"
	aL[030]:="| FIRMA: #########################################################                                                                 |"
	aL[031]:="|                                                                                                                                  |"
	aL[032]:="| INSC.EST.: ######################## C.N.P.J.: #################                                                                  |"
	aL[033]:="|                                                                                                                                  |"
	If !lMVIMPPAGI
		aL[034]:="| FOLHA: ####     MES OU PERIODO/ANO: #########                                                                                    |"
	Else
		aL[034]:="| PAGINA: ####     MES OU PERIODO/ANO: #########                                                                                   |"
	EndIf
	aL[035]:="|                                                                                                                                  |"
	aL[036]:="|==================================================================================================================================|"
	aL[037]:="|   | DEBITO DO IMPOSTO                                                                  |                 VALORES                 |"
	aL[038]:="| # |------------------------------------------------------------------------------------|-----------------------------------------|"
	aL[039]:="| # |                                                                                    |   COLUNA AUXILIAR  |        SOMA        |"
	aL[040]:="| # |                                                                                    |--------------------+--------------------|"
	aL[041]:="| # | 001 - POR SAIDAS / PRESTACOES COM DEBITO DO IMPOSTO                                |                    | ################## |"
	aL[042]:="| # | 002 - OUTROS DEBITOS (DISCRIMINAR ABAIXO)                                          |                    |                    |"
	aL[043]:="| # |       ############################################################################ | ################## | ################## |"
	aL[044]:="| # | 003 - ESTORNO DE CREDITOS (DISCRIMINAR ABAIX0)                                     |                    |                    |"
	aL[045]:="| # |       ############################################################################ | ################## | ################## |"
	aL[046]:="| # | 004 - SUB-TOTAL                                                                    |                    | ################## |"
	aL[047]:="|==================================================================================================================================|"
	aL[048]:="|   | CREDITO DO IMPOSTO                                                                 |                    |                    |"
	aL[049]:="| # |------------------------------------------------------------------------------------|--------------------+--------------------|"
	aL[050]:="| # | 005 - POR ENTRADAS / AQUISICOES COM CREDITO DO IMPOSTO                             |                    | ################## |"
	aL[051]:="| # | 006 - OUTROS CREDITOS (DISCRIMINAR ABAIXO)                                         |                    |                    |"
	aL[052]:="| # |       ############################################################################ | ################## | ################## |"
	aL[053]:="| # | 007 - ESTORNO DE DEBITOS (DISCRIMINAR ABAIXO)                                      |                    |                    |"
	aL[054]:="| # |       ############################################################################ | ################## | ################## |"
	aL[055]:="| # | 008 - SUB-TOTAL                                                                    |                    | ################## |"
	aL[056]:="| # | 009 - SALDO CREDOR DO PERIODO ANTERIOR                                             |                    | ################## |"
	aL[057]:="| # | 010 - TOTAL                                                                        |                    | ################## |"
	aL[058]:="|==================================================================================================================================|"
	aL[059]:="|   | APURACAO DO SALDO                                                                  |                    |                    |"
	aL[060]:="| # |------------------------------------------------------------------------------------|--------------------+--------------------|"
	aL[061]:="| # | 011 - SALDO DEVEDOR (DEBITO MENOS CREDITO)                                         |                    | ################## |"
	aL[062]:="| # | 012 - DEDUCOES (DISCRIMINAR ABAIXO)                                                |                    |                    |"
	aL[063]:="| # |       ############################################################################ | ################## | ################## |"
	aL[064]:="| # | 013 - IMPOSTO A RECOLHER                                                           |                    | ################## |"
	aL[065]:="| # | 014 - SALDO CREDOR (CREDITO MENOS DEBITO) A TRANSPORTAR P/O PERIODO SEGUINTE       |                    | ################## |"
	aL[066]:="|==================================================================================================================================|"
	aL[067]:="|                                                   INFORMACOES COMPLEMENTARES                                                     |"
	aL[068]:="|----------------------------------------------------------------------------------------------------------------------------------|"
	aL[069]:="|                          GUIAS DE RECOLHIMENTO                                              GUIA DE INFORMACAO                   |"
	aL[070]:="|                                                                                                                                  |"
	aL[071]:="|    NUMERO        DATA          VALOR            ORGAO ARRECADADOR           DATA ENTREGA     LOCAL DE ENTREGA(BANCO/REPARTICAO)  |"
	aL[072]:="| #########################################################################   ##########         ##################################|"
	aL[073]:="| #########################################################################                                                        |"
	aL[074]:="|                                                                                                                                  |"
	aL[075]:="| OBSERVACOES: ##################################################################################                                  |"
	aL[076]:="| ##############################################################################################################################   |"
	aL[077]:="|                                                                                                                                  |"
	aL[078]:="|                    RESUMO DA APURACAO DO IMPOSTO - SUBSTITUICAO TRIBUTARIA                                                       |"
	aL[079]:="|                                                                                                                                  |"
	aL[080]:="| FIRMA: #########################################################                                                                 |"
	aL[081]:="|                                                                                                                                  |"
	aL[082]:="| INSC.EST.: ######################## C.N.P.J.: #################                                                                  |"
	aL[083]:="|                                                                                                                                  |"
	If !lMVIMPPAGI
		aL[084]:="| FOLHA: ####     MES OU PERIODO/ANO: #########                                                                                    |"
	Else
		aL[084]:="| PAGINA: ####     MES OU PERIODO/ANO: #########                                                                                   |"
	EndIf
	aL[085]:="|                                                                                                                                  |"
	aL[086]:="|==================================================================================================================================|"
	aL[087]:="|   | DEBITO DO IMPOSTO                                                                  |                 VALORES                 |"
	aL[088]:="| # |------------------------------------------------------------------------------------|-----------------------------------------|"
	aL[089]:="| # |                                                                                    |   COLUNA AUXILIAR  |        SOMA        |"
	aL[090]:="| # |                                                                                    |--------------------+--------------------|"
	aL[091]:="| # | 001 - POR SAIDAS / PRESTACOES COM DEBITO DO IMPOSTO                                |                    | ################## |"
	aL[092]:="| # | 002 - OUTROS DEBITOS (DISCRIMINAR ABAIXO)                                          |                    |                    |"
	aL[093]:="| # |       ############################################################################ | ################## | ################## |"
	aL[094]:="| # | 003 - ESTORNO DE CREDITOS (DISCRIMINAR ABAIX0)                                     |                    |                    |"
	aL[095]:="| # |       ############################################################################ | ################## | ################## |"
	aL[096]:="| # | 004 - SUB-TOTAL(001+002+003)                                                       |                    | ################## |"
	aL[097]:="|==================================================================================================================================|"
	aL[098]:="|   | CREDITO DO IMPOSTO                                                                 |                    |                    |"
	aL[099]:="| # |------------------------------------------------------------------------------------|--------------------+--------------------|"
	aL[100]:="| # | 005 - POR ENTRADAS COM CREDITO DO IMPOSTO                                          |                    | ################## |"
	aL[101]:="| # | 006 - OUTROS CREDITOS (DISCRIMINAR ABAIXO)                                         |                    |                    |"
	aL[102]:="| # |       ############################################################################ | ################## | ################## |"
	aL[103]:="| # | 007 - ESTORNO DE DEBITOS (DISCRIMINAR ABAIXO)                                      |                    |                    |"
	aL[104]:="| # |       ############################################################################ | ################## | ################## |"
	aL[105]:="| # | 008 - SUB-TOTAL( 006+007+008)                                                      |                    | ################## |"
	aL[106]:="| # | 009 - SALDO CREDOR DO PERIODO ANTERIOR                                             |                    | ################## |"
	aL[107]:="| # | 010 - TOTAL( 010+011 )                                                             |                    | ################## |"
	aL[108]:="|==================================================================================================================================|"
	aL[109]:="|   | APURACAO DO SALDO( ST )                                                            |                    |                    |"
	aL[110]:="| # |------------------------------------------------------------------------------------|--------------------+--------------------|"
	aL[111]:="| # | 011 - SALDO DEVEDOR ( 005-012 )                                                    |                    | ################## |"
	aL[112]:="| # | 012 - DEDUCOES (DISCRIMINAR ABAIXO)                                                |                    |                    |"
	aL[113]:="| # |       ############################################################################ | ################## | ################## |"
	aL[114]:="| # | 013 - IMPOSTO A RECOLHER ( 013-014)                                                |                    | ################## |"
	aL[115]:="| # | 014 - SALDO CREDOR A TRANSPORTAR ( 012-005 )                                       |                    | ################## |"
	aL[116]:="|==================================================================================================================================|"
	aL[117]:="|                           REGISTRO DE APURACAO DO ICMS - SUBSTITUICAO TRIBUTARIA                                                 |"
	aL[118]:="|                           REGISTRO DE APURACAO DO ICMS - SUBSTITUICAO TRIBUTARIA - OPERACOES INTERNAS                            |"
	aL[119]:="|                           REGISTRO DE APURACAO DO ICMS - SUBSTITUICAO TRIBUTARIA - OPERACOES INTERESTADUAIS                      |"
	aL[120]:="| OBSERVAÇÕES: CRÉDITO ACUMULADO - EXPORTAÇÕES                                                                                     |"
	aL[121]:="| OBSERVAÇÕES: CRÉDITO ACUMULADO - OUTRAS HIPÓTESES                                                                                |"
	//       123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x
	//                10        20        30        40        50        60        70        80        90        100       110       120       30
Return nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R941Cabec()  ³Autor ³ Juan Jose Pereira    ³Data³ 03/05/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime cabecalho do relatorio                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R941Cabec(lSubsTrib,nNivel)
DEFAULT nNivel := 0

	__LogPages()
	aL:=NIL
	R941LayOut()
	cNome:=cInscr:=cCGC:=cPeriodo:=cPagina:=""
	aImp:=NIL
	cNome	:=SM0->M0_NOMECOM
	cInscr	:=InscrEst()
	cCGC	:=TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")

	If nApuracao==3
		cPeriodo:=Mes(dDtIni)+' / '+StrZero(Year(dDtIni),4)
	Else
		cPeriodo:=Dtoc(dDtIni)+" A "+Dtoc(dDtFim) //" A "
	Endif

	cPagina :=StrZero(nPagina,4)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime caracter de controle de largura de impressao         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin<80
		FMTLIN(,aL[1],,,@nLin)
	Endif

	nLin:=1

	@ nLin,0 PSAY AvalImp(132)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime cabecalho                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cImprimindo$'AP_ENT,AP_SAI'
		if lSubsTrib
			If (SuperGetMv ("MV_ESTADO")$"RJ/SP")
				If nNivel > 1
					FMTLIN(,{aL[1],aL[119],aL[3]},,,@nLin) // Interestaduais
				Else
					FMTLIN(,{aL[1],aL[118],aL[3]},,,@nLin) // Internas
				EndIf
			Else
				FMTLIN(,{aL[1],aL[117],aL[3]},,,@nLin)
			EndIf
		else
			FMTLIN(,{aL[1],aL[2],aL[3]},,,@nLin)
		EndIf
	Else
		if lSubsTrib
			FMTLIN(,{aL[27],aL[78],aL[29]},,,@nLin)
		else
			FMTLIN(,{aL[27],aL[28],aL[29]},,,@nLin)
		endif
	EndIf
	FMTLIN({cNome},aL[4],,,@nLin)

	FMTLIN(,aL[5],,,@nLin)
	FMTLIN({cInscr,cCGC},aL[6],,,@nLin)
	FMTLIN(,aL[7],,,@nLin)
	FMTLIN({cPagina,cPeriodo},aL[8],,,@nLin)
	FMTLIN(,aL[9],,,@nLin)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime sub-cabecalho                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Apuracao|Entradas              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cImprimindo=="AP_ENT"
			FMTLIN(,{aL[10],aL[11],aL[13],aL[14],aL[15],aL[16],aL[18]},,,@nLin)
			FMTLIN({"CREDITADO"},aL[19],,,@nLin) //"CREDITADO"
			FMTLIN(,aL[20],,,@nLin)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Apuracao|Saidas                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cImprimindo=="AP_SAI"
			FMTLIN(,{aL[10],aL[12],aL[13],aL[14],aL[15],aL[17],aL[18]},,,@nLin)
			FMTLIN({"DEBITADO"},aL[19],,,@nLin) //"DEBITADO"
			FMTLIN(,aL[20],,,@nLin)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Resumo|Debitos                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cImprimindo=="RE_DEB"
			FMTLIN(,{aL[36],aL[37]},,,@nLin)
			FMTLIN({"D"},aL[38],,,@nLin)
			FMTLIN({"E"},aL[39],,,@nLin)
			FMTLIN({"B"},aL[40],,,@nLin)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Resumo|Creditos                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cImprimindo=="RE_CRE"
			FMTLIN(,{aL[47],aL[48]},,,@nLin)
			FMTLIN({"C"},aL[49],,,@nLin)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Resumo|Saldo                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cImprimindo=="RE_APU"
			FMTLIN(,{aL[58],aL[59]},,,@nLin)
			FMTLIN({"S"},aL[60],,,@nLin)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Resumo|Inf. Complementares     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cImprimindo=="RE_INF"
			FmtLin(,{aL[66]},,,@nLin)
	EndCase

	NovaPg(@nPagina,nQtFeixe)

Return nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R941Cv()     ³Autor ³ Juan Jose Pereira    ³Data³ 03/05/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Converte valores por indice informado                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R941Cv

	nValor:=_parametros[1]
	lString:=_parametros[2]
	cValor:=""

	If lConverte
		nValor:=Noround(nValor/nIndice,3)
	Endif

	cValor:=Transform(nValor,cPictVal)
	_retorno:=NIL
	_retorno:=IIf(lString,cValor,nValor)

Return nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R941Cab2     ³Autor ³ Juan Jose Pereira    ³Data³ 03/05/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche ultima linha da folha e chama o cabecalho         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R941Cab2()

	IncRegua()
	If nLin>55
		FmtLin(,aL[1],,,@nLin)
		R941Cabec(.f.)
	Endif

Return nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpSt        ³Autor ³ Gustavo G. Rueda     ³Data³18/07/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao recursiva para quando houver necessidade de impressao³±±
±±³          ³ de um determinado estado em paginas separadas. Especifica- ³±±
±±³          ³ mente no caso do RJ e SP.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpSt (nNivel, aResEntr, aResSaid, lAbortPrint, cMv_UfSt, nLin, lImpCrdSt, aTOTAL, aL, nEntUFST, cProcSomEst )
	Local	cUF	:=	""
	Local 	i	:=	0
	Local	uValBase
	Local	uValICMS
	Local	uValCrdSt
	Local   uValTotSt
	Local	lSemMovE	:=	.T.
	Local	lSemMovS	:=	.T.
	Local	lInt		:=	.F.
	Local	lEnt		:=	.F.
	Local 	lPrintSMov	:=  .T.
	Local	nEstEnt		:=	0
	Local	nEstSai		:=	0
	Local 	nMv			:= 	0
	Local   lIntEnt     :=  .F.
	//
	Default	 cProcSomEst	:=	""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³As condicoes abaixo definem caso o estado passado para ser impresso³
	//³separadamente nao conste nos nos arrays de impressao, neste caso   ³
	//³dever ser impresso somente a pagina de movimentos e nao impresso a ³
	//³uma pagina SEM MOVIMENTO para o estado a ser separado.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cProcEstAux	:=	cProcSomEst
	If !(Empty (cProcSomEst))
		nEstEnt	:=	aScan (aResEntr, {|x| x[1]==cProcSomEst})
		nEstSai	:=	aScan (aResSaid, {|x| x[1]==cProcSomEst})
		cProcSomEst	:=	Iif (nEstEnt<>0, cProcSomEst, "")
		If (Empty (cProcSomEst))
			cProcSomEst	:=	Iif (nEstSai<>0, cProcEstAux, "")
		EndIf
		If Empty (cProcSomEst)
			R941LeST()
		EndIf
	EndIf
	//
	nLin	:=	99
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica as informacoes do ICMS ST na apuracao. Se nao existir, ira gerar o resumo zerado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nNivel ==1
		R941LeST()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Esta variavel nNivel controla a recursividade.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nNivel++
	If nNivel>=3
		Return
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Este for eh executado somente para um estado especifico! ³
	//³Caso esteja em branco o parametro cProcSomEst,           ³
	//³fara para todos normalmente.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Entradas interestaduais                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFill (aTotal, 0)
	cImprimindo	:=	"AP_ENT"
	SetRegua (Len (aRESEntr))
	For i := 1 To Len (aResEntr)
		IncRegua ()
		If (Interrupcao (@lAbortPrint))
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifico se algum estado deve ser impresso separadamente. Utilizado atualmente para o RJ. ³
		//³Se sim, o estado estara informado na variavel cProcSomEst e na primeira pagina das duas   ³
		//³na sequencia serao impresso todos(nNivel==1) os estados exceto o que deverah constar em   ³
		//³pagina separada(nNivel=2). Depois de impresso a pagina para os outros estados, eh montada ³
		//³a pagina para o estado individual, chamando novamente a funcao em recursividade(nNivel==2)³
		//³OBS:                                                                                      ³
		//³- Se no primeiro nivel as informacoes estiverem zeradas, nao serah impresso a pagina, pois³
		//³serah impresso a segunda independentemente de haver ou nao movimentacao.                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If (aResEntr[i,3]+aResEntr[i,4]>0) .And.;
	        ((!AllTrim (aResEntr[i,01])$cProcSomEst .And. nNivel==2) .Or. (AllTrim (aResEntr[i,01])$cProcSomEst .And. nNivel==1) .Or. cProcSomEst == "")
       		//

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O parametro MV_UFST exclui determinado estado da apuracao.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (lMv_UFSt)
			   	If (aResEntr[i,01]$cMv_UfSt)	// Estado a ser excluido da apuracao
   			    	Loop
   			 	Else							// Acumulo para impressao do Resumo
   			 		nEntUFST +=aResEntr[i,4]
   			 	Endif
        	Endif

			cUF	:=	aResEntr[i,01]  // UF
			//
			_parametros	:=	{aResEntr[i,3], .T.} // Base ICMS Retido
			R941Cv ()
			uValBase	:=	_retorno
			//
			_parametros	:=	{aResEntr[i,4], .T.} //Valor do Icms Solidario - Nao Creditado
			R941Cv ()
			uValICMS	:=	_retorno
			//
			_parametros	:=	{aResEntr[i,7], .T.} //Valor do Icms Solidario - Creditado
			R941Cv ()
			uValCrdSt 	:=	Iif (Val (_retorno)>0, _retorno, "")
			//
			_parametros := {aResEntr[i,4] + aResEntr[i,7], .T.} // Valor do ICMS-ST Creditado + ICMS-ST Creditado por devolução
			R941Cv()
			uValTotSt := _retorno
			//
			If (nLin>58)
				R941Cabec(.T.,nNivel)
			Endif
			//
		    If (aResEntr[i,4]>0) .Or. (aResEntr[i,7]>0)
		        If (lImpCrdSt)
				   FmtLin ({Space (4), cUF, uValBase, uValTotSt, "", ""}, aL[22],,, @nLin)
				Else
				   FmtLin ({Space (4), cUF, uValBase, "", uValTotSt, ""}, aL[22],,, @nLin)
				Endif
			Endif
			//
			aTOTAL[1]  	+= aResEntr[i,3]
			aTOTAL[2]  	+= aResEntr[i,4]
			aTOTAL[3]  	+= aResEntr[i,7]
			//
			lSemMovE	:=	.F.
        EndIf
    Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informacao de "SEM MOVIMENTO" para as NFs de entrada somente deverah ser   ³
	//³gerada no 2. nivel, pois o primeiro vai depender se terah ou nao informa-  ³
	//³coes para as saidas. Isso se deve ao fato da segunda pagina ser gerada     ³
	//³independente de conter ou não informacoes("SEM MOVIMENTO" ou nao). A pri-  ³
	//³meira pagina soh serah gerada se houver movimentacoes para o estado        |
	//|especifico.                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Len (aResEntr)==0 .Or. lSemMovE) .And. (nNivel==2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Somente gera a pagina "Sem movimento" para entradas do estado se existirem saidas.³
		//³Caso contrario, esta pagina nao e gerada.                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMv_UFSt
			For nMv := 1 to Len(aResSaid)
				If aResSaid[nMv,01]$cProcSomEst .And. aResSaid[nMv,01]$cMv_UfSt
					lInt	:= .T.
				Endif
			Next
		Endif

		If !lMv_UFSt .and. nNivel <> 2 .Or. (lMv_UFSt .And. !lInt)
			R941Cabec(.T.,nNivel)
			FmtLin ({"     ", "SEM MOVIMENTO",,,,}, aL[22],,, @nLin) //"SEM MOVIMENTO"
		Endif
	ElseIf !(lSemMovE)
		FmtLin (Array(5), aL[26],,, @nLin)
		FmtLin ({"TOTAIS"}, aL[25],,, @nLin)
		//
		_parametros	:=	{aTOTAL[1], .T.}
		R941Cv ()
		uValBase	:=	_retorno
		//
		_parametros	:=	{aTOTAL[2], .T.}
		R941Cv ()
		uValICMS	:=	_retorno
		//
		_parametros	:=	{aTOTAL[3],.T.} //Valor do Icms Solidario - Creditado
		R941Cv()
		uValCrdSt :=Iif (Val (_retorno)>0, _retorno, "")
		//
		_parametros := {aTOTAL[2] + aTOTAL[3], .T.} // Valor do ICMS-ST Creditado + ICMS-ST Creditado por devolução
		R941Cv()
		uValTotSt := _retorno
		//
        If (lImpCrdSt)
           FmtLin ({Space (4), Space (2), uValBase, uValTotSt, "", ""}, aL[22],,, @nLin)
		Else
		   FmtLin ({Space (4), Space (2), uValBase, "", uValTotSt, ""}, aL[22],,, @nLin)
		Endif
		FmtLin (, aL[1],,, @nLin)
	Endif
	//
	If lAbortPrint
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Saidas interestaduais                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lFirst		:=	.T.
	cImprimindo	:=	"AP_SAI"
	lSemMovS	:=	.T.
	aFill (aTotal, 0)
	SetRegua (Len (aResSaid))
	For i:=1 To Len (aResSaid)
		IncRegua ()
		//
		If Interrupcao(@lAbortPrint)
			Exit
		Endif
		//

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifico se algum estado deve ser impresso separadamente. Utilizado atualmente para o RJ. ³
		//³Se sim, o estado estara informado na variavel cProcSomEst e na primeira pagina das duas   ³
		//³na sequencia serao impresso todos(nNivel==1) os estados exceto o que deverah constar em   ³
		//³pagina separada(nNivel=2). Depois de impresso a pagina para os outros estados, eh montada ³
		//³a pagina para o estado individual, chamando novamente a funcao em recursividade(nNivel==2)³
		//³OBS:                                                                                      ³
		//³- Se no primeiro nivel as informacoes estiverem zeradas, nao serah impresso a pagina, pois³
		//³serah impresso a segunda independentemente de haver ou nao movimentacao.                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If (aResSaid[i,3]+aResSaid[i,4]>0) .And.;
	        ((!AllTrim (aResSaid[i,01])$cProcSomEst .And. nNivel==2) .Or. (AllTrim (aResSaid[i,01])$cProcSomEst .And. nNivel==1).Or. cProcSomEst == "")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O parametro MV_UFST exclui determinado estado da apuracao.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (lMv_UFSt)
			   	If (aResSaid[i,01]$cMv_UfSt)	// Estado a ser excluido da apuracao
   			    	Loop
   			 	Else							// Acumulo para impressao do Resumo
   			 		nSaiUFST +=aResSaid[i,4]
   			 	Endif
        	Endif

			If (lSemMovE .And. lFirst)
				cImprimindo	:=	"AP_ENT"
				R941Cabec(.T.,nNivel)
				cImprimindo	:=	"AP_SAI"
				FmtLin ({"     ", "SEM MOVIMENTO",,,,}, aL[22],,, @nLin) //"SEM MOVIMENTO"
			EndIf
       		//
			If (nLin>58)
				R941Cabec(.T.,nNivel)
			ElseIf (lFirst)
				FmtLin (, {aL[10], aL[12], aL[13], aL[14], aL[15], aL[17], aL[18]},,, @nLin)
				FmtLin ({"DEBITADO"}, aL[19],,, @nLin) //"DEBITADO"
				FmtLin (, aL[20],,, @nLin)
				lFirst		:=	.F.
			Endif
			//
			cUF	:=	aResSaid[i,01]  // UF
			//
			_parametros:={aResSaid[i,3],.T.} // Base ICMS Retido
			R941Cv()
			uValBase:=_retorno
			//
			_parametros:={aResSaid[i,4],.T.} //vALOR DO ICMS Retido
			R941Cv()
			uValICMS:=_retorno
			//
		    if (aResSaid[i,4]>0)
				FmtLin ({Space (4), cUF, uValBase, uValICMS, "", ""}, aL[22],,, @nLin)
			EndIf
			//
			aTOTAL[1]  	+= aResSaid[i,3]
			aTOTAL[2]	+= aResSaid[i,4]
			//
			lSemMovS	:=	.F.

        EndIf
	Next i
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informacao de "SEM MOVIMENTO" para as NFs de entrada somente deverah ser   ³
	//³gerada no 2. nivel, pois o primeiro vai depender se terah ou nao informa-  ³
	//³coes para as saidas. Isso se deve ao fato da segunda pagina ser gerada     ³
	//³independente de conter ou não informacoes("SEM MOVIMENTO" ou nao). A pri-  ³
	//³meira pagina soh serah gerada se houver movimentacoes para o estado        |
	//|especifico.                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  ((nNivel==2) .And. (Len (aResSaid)==0 .Or. lSemMovS)) .Or.;
		((nNivel==1) .And. !lSemMovE .And. (Len (aResSaid)==0 .Or. lSemMovS))
		If nNivel == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente gera a pagina "Sem movimento" para entradas do estado se existirem saidas.³
			//³Caso contrario, esta pagina nao e gerada.                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lMv_UFSt
				For nMv := 1 to Len(aResEntr)
					If aResEntr[nMv,01]$cProcSomEst .And. aResEntr[nMv,01]$cMv_UfSt
						lIntEnt	:= .T.
					Endif
				Next
			Endif
			lPrintSMov := .F.
			If !lMv_UFSt .Or. (lMv_UFSt .And. !lIntEnt)
				lPrintSMov := .T.
			Endif
		Endif
		If lPrintSMov
			FmtLin (,{aL[10], aL[12], aL[13], aL[14], aL[15], aL[17], aL[18]},,,@nLin)
			FmtLin ({"DEBITADO"}, aL[19],,,@nLin) //"DEBITADO"
			FmtLin (, aL[20],,, @nLin)
			FmtLin ({"     ", "SEM MOVIMENTO",,,,}, aL[22],,, @nLin) //"SEM MOVIMENTO"
			While (nLin<58)
				FmtLin (Array (5), aL[26],,, @nLin)
			End
			FmtLin (, aL[1],,, @nLin)
		Endif

	ElseIf !(lSemMovS)
		FmtLin (Array (5), aL[26],,, @nLin)
		FmtLin ({"TOTAIS"}, aL[25],,, @nLin)
		//
		_parametros	:=	{aTOTAL[1], .T.}
		R941Cv ()
		uValBase	:=	_retorno
		//
		_parametros	:=	{aTOTAL[2], .T.}
		R941Cv ()
		uValICMS	:=	_retorno
		//
		FmtLin ({Space (4), Space (02), uValBase, uValICMS, "", ""}, aL[22],,, @nLin)
		While nLin<58
			FmtLin (Array (5), aL[26],,, @nLin)
		End
		FmtLin (, aL[1],,, @nLin)
	Endif
	//
	If lAbortPrint
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chamada de uma funcao recursiva para processar o MV_ESTADO independente dos ³
	//³outros estados em folhas distintas.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(Empty (cProcSomEst))
		ImpSt (@nNivel, aResEntr, aResSaid, @lAbortPrint, cMv_UfSt, @nLin, lImpCrdSt, @aTOTAL, aL, @nEntUFST, cProcSomEst)
	EndIf
Return nil


//------------------------------------------
// Resumo customizado - solicitação da CAOA
// Cristiam Rossi em 22/02/2019
//------------------------------------------
static function resCAOA(nLin)
local nI

	fGetDC( @_aUF )		// recupera valores de Débito / Crédito ST

	__LogPages()
	cNome:=cInscr:=cCGC:=cPeriodo:=cPagina:=""
	aImp:=NIL

	If nApuracao==3
		cPeriodo:=Mes(dDtIni)+' / '+StrZero(Year(dDtIni),4)
	Else
		cPeriodo:=Dtoc(dDtIni)+" A "+Dtoc(dDtFim) //" A "
	Endif

	cPagina :=StrZero(nPagina,4)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime caracter de controle de largura de impressao         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin<80
		FMTLIN(,aL[1],,,@nLin)
	Endif

	nLin:=1

	@ nLin,0 PSAY AvalImp(132)

// 133
//	aL[085]:= "|                                                                                                                                  |"

	nLin += 2

	@ nLin, 0 PSAY "                                                         APURAÇÃO DE ICMS-ST                                                        "
	nLin += 2

	@ nLin, 0 PSAY "Firma: " + SM0->M0_NOMECOM
	@ nLin,82 PSAY "Inscr.: " + InscrEst()
	nLin++

	@ nLin, 0 PSAY "Período: " + cPeriodo
	@ nLin,82 PSAY "CNPJ: " + TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")
	nLin += 2

//                            1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000111111111122222222223
//                  01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	@ nLin, 0 PSAY "UF --SALDO CREDOR- -----OUTROS---- ----CREDITOS--- -----OUTROS---- ----DEBITOS----    INSCRIÇÃO ST       VENCIMENTO ----SALDO-----"
	nLin++
	@ nLin, 0 PSAY "   ---ANTERIOR---- ----CREDITOS--- -PELAS ENTRADAS ----DEBITOS---- --PELAS SAIDAS-                                  --A RECOLHER--"
	nLin += 2


	nTotal := 0

	for nI := 1 to len( _aUF )
		@ nLin,000 PSAY _aUF[nI][1]
		@ nLin,003 PSAY transform(_aUF[nI][2], "@E 999,999,999.99")
		@ nLin,019 PSAY transform(_aUF[nI][3], "@E 999,999,999.99")
		@ nLin,035 PSAY transform(_aUF[nI][4], "@E 999,999,999.99")
		@ nLin,051 PSAY transform(_aUF[nI][5], "@E 999,999,999.99")
		@ nLin,067 PSAY transform(_aUF[nI][6], "@E 999,999,999.99")

		If _aUF[nI][2]<>0 .or. _aUF[nI][3]<>0 .or. _aUF[nI][4]<>0 .or. _aUF[nI][5]<>0 .or. _aUF[nI][6]<>0
			if ! empty( _aUF[nI][7] )
				@ nLin,086 PSAY _aUF[nI][7]
			endif
		EndIf

		if ! empty( _aUF[nI][8] )
			@ nLin,105 PSAY _aUF[nI][8]
		endif

		//nSldRec := _aUF[nI][2] + _aUF[nI][4] - _aUF[nI][6]  //Original Cristiam
		nSldRec := _aUF[nI][6] - (_aUF[nI][2] + _aUF[nI][4])  //Alterado por João Carlos em 17/04/2019
		@ nLin,116 PSAY transform(nSldRec, "@E 999,999,999.99")
		nLin++

		nTotal += nSldRec
	next

	nLin++
	@ nLin, 0 PSAY "Valor já recolhido do GNRE por operação"
	@ nLin,116 PSAY transform(0, "@E 999,999,999.99")

	nLin++
	@ nLin, 0 PSAY "Valor a recolher Estados com inscrição de substituto"
	@ nLin,116 PSAY transform(nTotal, "@E 999,999,999.99")

return nil


//------------------------------------------------------
static function fGetUF()
local aRet		:= {}
local cInscr	:= ""
local aSX512	:= {}
local nI		:= 0

	chkFile("CLO")
	CLO->( dbSetOrder(1))


	aSX512 := {}
	aSX512 := FWGetSX5( "12")

	for nI := 1 to len( aSX512 )
		CLO->( DBGoTop() )

		if CLO->( dbSeek( xFilial("CLO") + left( aSX512[ nI , 4] , 2) ) )
			cInscr := alltrim( CLO->CLO_INSCR )
		else
			cInscr := ""
		endif

		aadd( aRet, { left( aSX512[ nI , 4] ,2), 0, 0, 0, 0, 0, cInscr, "", 0 })
	next
return aClone( aRet )


//------------------------------------------------------
static function fGetDC( aRet )
local aArea     := getArea()
local cQuery
local cAliasQry := getNextAlias()

	cQuery := "select FT_FILIAL, FT_ESTADO, SUBSTR(FT_CFOP,1,1) CFOP, sum(FT_ICMSRET) FT_ICMSRET"
	cQuery += " from "+retSqlName("SFT")
	cQuery += " where FT_FILIAL='"+xFilial("SFT")+"'"
	cQuery += " and FT_ENTRADA between '"+DtoS(dDtIni)+"' and '"+DtoS(dDtFim)+"'"
	cQuery += " and FT_CREDST in ('2',' ') "
	cQuery += " and FT_ICMSRET > 0 "
	cQuery += " and FT_DTCANC = ' '"
	cQuery += " and D_E_L_E_T_=' '"
	cQuery += " GROUP BY FT_FILIAL, FT_ESTADO, SUBSTR(FT_CFOP,1,1)"
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

	while ! (cAliasQry)->( EOF() )

		nPosUF := aScan( aRet, {|it| it[1] == (cAliasQry)->FT_ESTADO })
		if nPosUF > 0
			if (cAliasQry)->(CFOP < '5')  //SUBSTR(FT_CFOP,1,1)
				aRet[nPosUF][4] += (cAliasQry)->FT_ICMSRET  //Entradas
			else
				aRet[nPosUF][6] += (cAliasQry)->FT_ICMSRET  //Saídas
			endif
		endif

		(cAliasQry)->( dbSkip() )
	end
	(cAliasQry)->( dbCloseArea() )

	restArea( aArea )
return aClone( aRet )


//------------------------------------------------------
static function fAcmST( cEstado, nValor )
local nPosUF := aScan( _aUF, {|it| it[1] == cEstado } )

	if nPosUF > 0
		_aUF[nPosUF][2] += nValor
	endif

return nil
