#Include "Protheus.Ch"
#Include "Report.Ch"
#include "Rwmake.ch"
#include "Ap5mail.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "TOPCONN.ch"
#include "Parmtype.ch"
#include "Prtopdef.ch"

/*{Protheus.doc} 
Desenvolvimento de relatório empresa CAOA - utilizado para apresentar os doc de entradas e saídas (PIS/COFINS) ZFM
@obs 1)                                 
@obs -                  
@obs -                
@obs -                 
@obs Faz-se necessario porque o padrão não tem só esses campos               
@type function
@author Antonio Carlos
@since 11/02/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
*/
User Function CMFISR01()
PRIVATE oReport
PRIVATE nRecNPIS         := 0
PRIVATE nRecNCOF         := 0  
PRIVATE nTtl001          := 0 
PRIVATE nTtl002          := 0
PRIVATE nTTlRec          := 0
PRIVATE _nTotalP         := 0
PRIVATE _nTotalC         := 0
PRIVATE _nRecDP          := 0 
PRIVATE _nRecDC          := 0
PRIVATE cTPMOV           := ' '
PRIVATE _cQuery          := ' '
PRIVATE cSubTit          := ' '
PRIVATE cClifor          := ' '
PRIVATE aSelFil  	     := {}
PRIVATE cAliasQry  	     := GetNextAlias()

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Antonio Carlos        ³ Data ³11/02/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relação de doc de entradas e saidas (PIS/COFINS)           ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatorio                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local cPerg 	:= "FAT001"
Local oReport
Local lGestao   := FWSizeFilial() > 2	// Indica se usa Gestao Corporativa

CriaSx1(cPerg)
Pergunte(cPerg,.F.)

/* GESTAO - inicio */
If MV_PAR01 == 1
	nRegSM0 := SM0->(Recno())
	aSelFil := AdmGetFil(.F.,.F.,"SFT")
	SM0->(DBGOTO(nRegSM0))
Endif

If Empty(aSelFil)
	Aadd(aSelFil,cFilAnt)
Endif

oReport := TReport():New("CMFISR01","Relacao NFs de Apuracao PIS/COFINS para ZFM",cPerg, {|oReport| ReportPrint(oReport,cAliasQry)},;
"Este programa tem como objetivo imprimir relatorio de acordo com os parametros informados pelo usuario. Faturamento")

	oReport:nFontBody 		:= 07
	oReport:nLineHeight 	:= 30
	oReport:nLeftMargin 	:= 02
	//oReport:nPageWidth	:= 
	//oReport:SetPortrait(.T.)
	oReport:SetLandscape(.T.)
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:SetMsgPrint("Gerando relatorio...")
	oReport:HideParamPage()
	oReport:DisableOrientation()
 
// Secao Principal  
oSection1 := TRSection():New(oReport,"Relação de NFs - ZFM ",{cAliasQry},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oSection1,"FT_FILIAL"	,"SFT","FILIAL"    /*Alltrim(RetTitle("FILIAL"))*/    ,PesqPict("SFT","FT_FILIAL")  ,TamSX3("FT_FILIAL")[1] ,/*lPixel*/,{|| (cAliasQry)->FT_FILIAL })
TRCell():New(oSection1,"FT_NFISCAL"	,"SFT","DOCUMENTO" /*/Alltrim(RetTitle("FT_CFOP"))*/  ,PesqPict("SFT","FT_NFISCAL") ,TamSX3("FT_NFISCAL")[1],/*lPixel*/,{|| (cAliasQry)->FT_NFISCAL })
TRCell():New(oSection1,"FT_SERIE" 	,"SFT","SERIE"     /*/Alltrim(RetTitle("FT_CFOP")) */ ,PesqPict("SFT","FT_SERIE")   ,TamSX3("FT_SERIE")[1]  ,/*lPixel*/,{|| (cAliasQry)->FT_SERIE })
TRCell():New(oSection1,"FT_ESPECIE"	,"SFT","ESPECIE"   /*Alltrim(RetTitle("E1_VENCREA"))*/,PesqPict("SFT","FT_ESPECIE") ,TamSX3("FT_ESPECIE")[1],/*lPixel*/,{|| (cAliasQry)->FT_ESPECIE })
TRCell():New(oSection1,"FT_TIPOMOV"	,"SFT","MOVIMENTO" /*Alltrim(RetTitle("E1_VENCREA"))*/,PesqPict("SFT","FT_TIPOMOV") ,TamSX3("FT_TIPOMOV")[1],/*lPixel*/,{|| IIF((cAliasQry)->FT_TIPOMOV='E','ENTRADA','SAIDA')})
TRCell():New(oSection1,"TIPO"   	,"SD1","TIPO"      /*Alltrim(RetTitle("E1_VENCREA"))*/,PesqPict("SFT","FT_NFISCAL") ,TamSX3("FT_NFISCAL")[1],/*lPixel*/,{|| (cAliasQry)->TIPO})
TRCell():New(oSection1,"FT_EMISSAO" ,"SFT","EMISSAO"   /*/Alltrim(RetTitle("FT_CFOP")) */ ,PesqPict("SFT","FT_EMISSAO") ,TamSX3("FT_EMISSAO")[1],/*lPixel*/,{|| (cAliasQry)->FT_EMISSAO })
TRCell():New(oSection1,"FT_CLIEFOR"	,"SFT","CODIGO"    /*Alltrim(RetTitle("FT_NFISCAL"))*/,PesqPict("SFT","FT_CLIEFOR") ,TamSX3("FT_CLIEFOR")[1],/*lPixel*/,{|| (cAliasQry)->FT_CLIEFOR })
TRCell():New(oSection1,"FT_LOJA" 	,"SFT","LOJA"      /*/Alltrim(RetTitle("FT_CFOP")) */ ,PesqPict("SFT","FT_LOJA")    ,TamSX3("FT_LOJA")[1]   ,/*lPixel*/,{|| (cAliasQry)->FT_LOJA })
TRCell():New(oSection1,"NOME"   	,"   ","FORNECEDOR/CLIENTE",PesqPict("SA2","A2_NOME") ,30/*TamSX3("A2_NOME")[1]*/         ,/*lPixel*/,{|| (cAliasQry)->NOME })
TRCell():New(oSection1,"PIS"        ,"SD1","VALOR_PIS" /*Alltrim(RetTitle("FT_PRODUTO"))*/,PesqPict("SD1","D1_DESCZFP") ,TamSX3("D1_DESCZFP")[1],/*lPixel*/,{|| (cAliasQry)->PIS })
TRCell():New(oSection1,"COFINS"     ,"SD1","VALOR_COF" /*Alltrim(RetTitle("FT_PRODUTO"))*/,PesqPict("SD1","D1_DESCZFC") ,TamSX3("D1_DESCZFC")[1],/*lPixel*/,{|| (cAliasQry)->COFINS })
TRCell():New(oSection1,"DEV_PIS"    ,"SD1","DEV_PIS"   /*Alltrim(RetTitle("FT_PRODUTO"))*/,PesqPict("SD1","D1_DESCZFP") ,TamSX3("D1_DESCZFP")[1],/*lPixel*/,{|| IF((cAliasQry)->TIPO="DEVOLUCAO",(cAliasQry)->PIS,0) })
TRCell():New(oSection1,"DEV_COFINS" ,"SD1","DEV_COFINS"/*Alltrim(RetTitle("FT_PRODUTO"))*/,PesqPict("SD1","D1_DESCZFC") ,TamSX3("D1_DESCZFC")[1],/*lPixel*/,{|| IF((cAliasQry)->TIPO="DEVOLUCAO",(cAliasQry)->COFINS,0) })
TRCell():New(oSection1,"REC_PIS"    ,"SD1","REC_PIS"   /*Alltrim(RetTitle("FT_PRODUTO"))*/,PesqPict("SD1","D1_DESCZFP") ,TamSX3("D1_DESCZFP")[1],/*lPixel*/,{|| IF((cAliasQry)->TIPO="NORMAL",(cAliasQry)->PIS,0) })
TRCell():New(oSection1,"REC_COFINS" ,"SD1","REC_COFINS"/*Alltrim(RetTitle("FT_PRODUTO"))*/,PesqPict("SD1","D1_DESCZFC") ,TamSX3("D1_DESCZFC")[1],/*lPixel*/,{|| IF((cAliasQry)->TIPO="NORMAL",(cAliasQry)->COFINS,0) })

oSection1:Cell("FT_FILIAL")  :SetHeaderAlign("RIGHT")
oSection1:Cell("FT_NFISCAL") :SetHeaderAlign("RIGHT")
oSection1:Cell("FT_SERIE")   :SetHeaderAlign("RIGHT")
oSection1:Cell("FT_ESPECIE") :SetHeaderAlign("RIGHT")
oSection1:Cell("FT_TIPOMOV") :SetHeaderAlign("RIGHT")
oSection1:Cell("TIPO")       :SetHeaderAlign("RIGHT")
oSection1:Cell("FT_EMISSAO") :SetHeaderAlign("RIGHT")
oSection1:Cell("FT_CLIEFOR") :SetHeaderAlign("RIGHT")
oSection1:Cell("FT_LOJA")    :SetHeaderAlign("RIGHT")  
oSection1:Cell("NOME")       :SetHeaderAlign("RIGHT")
oSection1:Cell("PIS")        :SetHeaderAlign("RIGHT")
oSection1:Cell("COFINS")     :SetHeaderAlign("RIGHT")
oSection1:Cell("DEV_PIS")    :SetHeaderAlign("RIGHT")
oSection1:Cell("DEV_COFINS") :SetHeaderAlign("RIGHT")
oSection1:Cell("REC_PIS")    :SetHeaderAlign("RIGHT")
oSection1:Cell("REC_COFINS") :SetHeaderAlign("RIGHT")

oBreak := TRBreak():New(oSection1, oSection1:Cell("FT_CLIEFOR"), "Total Cliente",nil,"CLIENTE")
TRFunction():New(oSection1:Cell("VALOR_PIS") , "Total Cliente", "SUM", oBreak,/*cTitle*/,PesqPict("SD1","D1_DESCZFP"),/*uFormula*/, .F., .F.)
TRFunction():New(oSection1:Cell("VALOR_COF") , "Total Cliente", "SUM", oBreak,/*cTitle*/,PesqPict("SD1","D1_DESCZFC"),            , .F., .F.)
TRFunction():New(oSection1:Cell("REC_PIS")   , "Total Cliente", "SUM", oBreak,/*cTitle*/,PesqPict("SD1","D1_DESCZFC"),            , .F., .F.)
TRFunction():New(oSection1:Cell("REC_COFINS"), "Total Cliente", "SUM", oBreak,/*cTitle*/,PesqPict("SD1","D1_DESCZFC"),            , .F., .F.)
      
//oBreak := TRBreak():New(oSection1, oSection1:Cell("FT_TIPOMOV"), "Total Movimento ",nil,"MOVIMENTO")    
TRFunction():New(oSection1:Cell("VALOR_PIS") ,,"SUM",/*oBreak*/,/*cTitle*/,PesqPict("SD1","D1_DESCZFP"),/*uFormula*/, .F., .T.,.F.,,,,,)
TRFunction():New(oSection1:Cell("VALOR_COF") ,,"SUM",/*oBreak*/,/*cTitle*/,PesqPict("SD1","D1_DESCZFP"),/*uFormula*/, .F., .T.,.F.,,,,,)	
TRFunction():New(oSection1:Cell("DEV_PIS")   ,,"SUM",/*oBreak*/,/*cTitle*/,PesqPict("SD1","D1_DESCZFC"),            , .F., .T.)
TRFunction():New(oSection1:Cell("DEV_COFINS"),,"SUM",/*oBreak*/,/*cTitle*/,PesqPict("SD1","D1_DESCZFC"),            , .F., .T.)
TRFunction():New(oSection1:Cell("REC_PIS")   ,,"SUM",/*oBreak*/,/*cTitle*/,PesqPict("SD1","D1_DESCZFC"),            , .F., .T.)
TRFunction():New(oSection1:Cell("REC_COFINS"),,"SUM",/*oBreak*/,/*cTitle*/,PesqPict("SD1","D1_DESCZFC"),            , .F., .T.)

Return(oReport)
 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint ³ Autor ³ Antonio Carlos        ³ Data ³11/02/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que imprime as linhas detalhes do relatorio            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasQry)
Local aSRC 		:= {}
Local cSaveArea
Local cInicio	:= DtoS(mv_par02)
Local cFim		:= DtoS(mv_par03)
Local cDocIni	:= mv_par04
Local cDocFim	:= mv_par05
Local _cQuery 	:= ''
Local cbakalias := '' 
Local cTmpFil	:= ""   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):BeginQuery()

_cQuery := "SELECT "         +Chr(10)
_cQuery += "FT_FILIAL, "     +Chr(10)
_cQuery += "(CASE WHEN FT.FT_TIPOMOV = 'E' AND D1.D1_TIPO = 'N' "    +Chr(10) 
_cQuery += "           OR FT.FT_TIPOMOV = 'S' AND D2.D2_TIPO = 'N' " +Chr(10)
_cQuery += "           THEN  'NORMAL'                              " +Chr(10)
_cQuery += "     WHEN FT.FT_TIPOMOV = 'E' AND D1.D1_TIPO = 'D'     " +Chr(10) 
_cQuery += "           OR FT.FT_TIPOMOV = 'S' AND D2.D2_TIPO = 'D' " +Chr(10)
_cQuery += "          THEN  'DEVOLUCAO'                            " +Chr(10)
_cQuery += "     ELSE                                              " +Chr(10)
_cQuery += "           '  '                                        " +Chr(10)
_cQuery += "     END) AS TIPO,                                     " +Chr(10)
_cQuery += "(CASE WHEN FT.FT_TIPOMOV = 'E' THEN A2.A2_NOME ELSE A1.A1_NOME END) AS NOME, "         +Chr(10) 
_cQuery += "(CASE WHEN FT.FT_TIPOMOV = 'E' THEN D1.D1_DESCZFC ELSE D2.D2_DESCZFC END) AS COFINS, " +Chr(10) 
_cQuery += "(CASE WHEN FT.FT_TIPOMOV = 'E' THEN D1.D1_DESCZFP ELSE D2.D2_DESCZFP END) AS PIS, "    +Chr(10) 
_cQuery += "FT_NFISCAL, "    +Chr(10)
_cQuery += "FT_SERIE, "      +Chr(10)
_cQuery += "FT_ESPECIE, "    +Chr(10)
//SQL
//_cQuery += "SUBSTRING(FT_EMISSAO,7,2)+'/'+SUBSTRING(FT_EMISSAO,5,2)+'/'+SUBSTRING(FT_EMISSAO,1,4) FT_EMISSAO, " +Chr(10)
//Oracle
_cQuery += "SUBSTRING(FT_EMISSAO,7,2)|| '/' ||SUBSTRING(FT_EMISSAO,5,2)|| '/' ||SUBSTRING(FT_EMISSAO,3,2) FT_EMISSAO, " +Chr(10)
_cQuery += "FT_TIPOMOV, "    +Chr(10)
_cQuery += "FT_CLIEFOR, "    +Chr(10)
_cQuery += "FT_LOJA "       +Chr(10) 
_cQuery += "FROM " + RetSqlName("SFT") +" FT "   +Chr(10)
_cQuery += "    LEFT JOIN  "+RETSQLNAME("SA2")+" A2 ON "              +Chr(10)
//_cQuery += " FT.FT_FILIAL=A2.A2_FILIAL "                            +Chr(10)    
_cQuery += " FT.FT_CLIEFOR=A2.A2_COD "                                +Chr(10)  
_cQuery += " AND FT.FT_LOJA=A2.A2_LOJA "                              +Chr(10)    
_cQuery += " AND A2.D_E_L_E_T_= ' ' "                                 +Chr(10)
_cQuery += "    LEFT JOIN  "+RETSQLNAME("SA1")+" A1 ON "              +Chr(10)
_cQuery += " FT.FT_CLIEFOR=A1.A1_COD "                                +Chr(10)   
//_cQuery += " AND FT.FT_FILIAL=A1.A1_FILIAL       "                  +Chr(10)    
_cQuery += " AND FT.FT_LOJA=A1.A1_LOJA "                              +Chr(10)    
_cQuery += " AND A1.D_E_L_E_T_= ' ' "                                 +Chr(10)
_cQuery += "     LEFT JOIN "+RETSQLNAME("SD1")+" D1 ON "              +Chr(10)
//_cQuery += "      FT.FT_FILIAL=A2.A2_FILIAL "                         +Chr(10)
_cQuery += "     D1.D1_DESCZFC > 0 "                                  +Chr(10)
_cQuery += "  AND FT.FT_NFISCAL=D1.D1_DOC "                           +Chr(10)  
_cQuery += "  AND FT.FT_SERIE=D1.D1_SERIE "                           +Chr(10)
_cQuery += "  AND D1.D_E_L_E_T_= ' ' "                                +Chr(10)
_cQuery += "     LEFT JOIN "+RETSQLNAME("SD2")+" D2 ON "              +Chr(10)
//_cQuery += "  --FT.FT_FILIAL=A2.A2_FILIAL "                         +Chr(10)
_cQuery += "  D2.D2_DESCZFC > 0 "                                     +Chr(10)
_cQuery += "  AND FT.FT_NFISCAL=D2.D2_DOC "                           +Chr(10)
_cQuery += "  AND FT.FT_SERIE=D2.D2_SERIE "                           +Chr(10)
_cQuery += "  AND D2.D_E_L_E_T_= ' ' "                                +Chr(10) 
_cQuery += "WHERE "                                                   +Chr(10)
_cQuery += " FT_FILIAL " + GetRngFil(aSelFil,"SFT",.T., @cTmpFil)     +Chr(10)
_cQuery += " AND FT_EMISSAO >= '"  + cInicio  +"' "                   +Chr(10)
_cQuery += " AND FT_EMISSAO <= '"  + cFim     +"' "                   +Chr(10)             
_cQuery += " AND FT_NFISCAL >= '"  + cDocIni  +"' "                   +Chr(10)
_cQuery += " AND FT_NFISCAL <= '"  + cDocFim  +"' "                   +Chr(10)
_cQuery += " AND FT.D_E_L_E_T_ = ' ' "                                +Chr(10)
_cQuery += " AND FT_DTCANC = ' ' "                                    +Chr(10)
_cQuery += " AND FT_ESTADO IN ('AC','AM','AP','RO','RR') "            +Chr(10)
_cQuery += " ORDER BY FT_FILIAL, FT_TIPOMOV, FT_CLIEFOR, FT_NFISCAL, FT_EMISSAO " +Chr(10)

MemoWrit("C:\SQL\CMFISR01.SQL",_cQuery) //Gravei a Query em TXT p/Testes
_cQuery := ChangeQuery(_cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQuery),cAliasQry, .F., .T. ) 

oReport:Section(1):EndQuery()
oReport:Section(1):Init()
PQuery(cAliasQry,oReport) //Imprime
oReport:Section(1):Finish() 
 
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PQuery	³ Autor ³ Antonio Carlos        ³ Data ³ 12/02/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para imprimir a Query				 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PQuery(cAliasQry,oReport)
Local oBreak
Local Section1  := oReport:Section(1) 

dbSelectArea(cAliasQry)
dBGotop()

Do While (cAliasQry)->( !Eof() )
   IF (cAliasQry)->PIS > 0 .AND. (cAliasQry)->COFINS > 0
   	      
      IF (cAliasQry)->TIPO = "NORMAL"
         nRecNPIS := nRecNPIS + (cAliasQry)->PIS 
         nRecNCOF := nRecNCOF + (cAliasQry)->COFINS
         _nTotalP := _nTotalP + (cAliasQry)->PIS 
      ELSEIF (cAliasQry)->TIPO = "DEVOLUCAO"
         _nRecDP  := _nRecDP  + (cAliasQry)->PIS
         _nRecDC  := _nRecDC  + (cAliasQry)->COFINS
         _nTotalC := _nTotalC + (cAliasQry)->PIS          
      ENDIF	

 	   oReport:Section(1):PrintLine()
 	   
   ENDIF
   	
   (cAliasQry)->( DbSkip() )
	
    If oReport:Cancel()
		Exit
	EndIf
 
	oReport:IncMeter()

EndDo

IF _nTotalP > _nTotalC //Trocar o Titulo final do relatório
	//oReport:aSection[1]:aBreak[3]:bTotalText := {|| 'TOTAL A RECOLHER   '}
	oReport:bTotalText := {|| 'TOTAL A RECOLHER   '}	
Else
	//oReport:aSection[1]:aBreak[3]:bTotalText := {|| 'TOTAL A TRANSPORTAR'}
	oReport:bTotalText := {|| 'TOTAL A TRANSPORTAR '}	
EndIf

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaSx1   ºAutor  ³   	    		 º Data ³ FEV/2019    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para criaçao do grupo de perguntas	  		          º±±
±±º                  .				                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                            	              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CriaSx1(cPerg)
Local aArea    := GetArea()    				// Salva ambiente atual para posterior restauracao
Local aPerg    := {}						// Array com dados referentes ao pergunte a ser criado
Local aHelpPor := {} 						// Texto de help para parametros
Local _sAlias  := Alias()
Local aRegs    := {}
Local i,j

dbSelectArea("SX1")
dbgotop()
dbSetOrder(1)  

cPerg := PADR(cPerg,10)
   AAdd(aRegs,{cPerg,"01","Seleciona Filiais?","","","mv_ch1","N",01,0,0,"C","","MV_PAR01","Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","",""})
   AAdd(aRegs,{cPerg,"02","Data inicial","","","mv_ch2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","Data Inicial de Aprovação"})
   AAdd(aRegs,{cPerg,"03","Data final","","","mv_ch3","D",08,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
   AAdd(aRegs,{cPerg,"04","Doc inicial","","","mv_ch4","C",09,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
   AAdd(aRegs,{cPerg,"05","Doc final","","","mv_ch5","C",09,0,0,"G","","MV_PAR05","","","","ZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","","",""})

For i := 1 to Len(aRegs)
	If !dbSeek(cPerg + aRegs[i, 2])
		RecLock("SX1", .T.)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j, aRegs[i, j])
			Endif
		Next
		MsUnlock()
	Endif
Next

DbSelectArea(_sAlias)
RestArea(aArea)
Return 
