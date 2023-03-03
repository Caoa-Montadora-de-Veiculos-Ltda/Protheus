#Include "Protheus.Ch"
#Include "Report.Ch"
#include "Rwmake.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include 'parmtype.ch'

/*{Protheus.doc} CMFISR02
Desenvolvimento de relatório empresa CAOA - utilizado para apresentar os dados da SM4 em Excel
@obs 1)                                 
@obs -                  
@obs -                
@obs -                 
@obs Faz-se necessario porque o padrão não tem só esses campos               
@type function
@author Antonio Carlos
@since 10/06/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
*/
User Function CMFISR02()
PRIVATE oReport
PRIVATE MV_PAR01    := ' '
PRIVATE MV_PAR02    := 'ZZZ'
PRIVATE _cQuery     := ' '
PRIVATE aSelFil  	:= {}
PRIVATE cAliasQry  	:= GetNextAlias()

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Antonio Carlos        ³ Data ³10/06/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relação de SM4                                             ³±±
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
Local cPerg 	:= "FAT002"
Local oReport
Local oSection1 
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

oReport := TReport():New("AFATR002","Relacao de Fórmulas ",cPerg, {|oReport| ReportPrint(oReport,cAliasQry)},;
"Este programa tem como objetivo imprimir relatorio de Fórmulas de acordo com os parametros informados pelo usuario. ")

	oReport:nFontBody 		:= 07
	oReport:nLineHeight 	:= 60
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
oSection1 := TRSection():New(oReport,"Relação de Fórmulas - SM4 ",{cAliasQry},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oSection1,"M4_FILIAL"	,"SM4","FILIAL"   ,PesqPict("SM4","M4_FILIAL") ,TamSX3("M4_FILIAL")[1] ,/*lPixel*/,{|| (cAliasQry)->M4_FILIAL  },,.T.)
TRCell():New(oSection1,"M4_CODIGO"  ,"SM4","CODIGO"   ,PesqPict("SM4","M4_CODIGO") ,TamSX3("M4_CODIGO")[1] ,/*lPixel*/,{|| (cAliasQry)->M4_CODIGO  },,.T.)
TRCell():New(oSection1,"M4_DESCR" 	,"SM4","DESCRICAO",PesqPict("SM4","M4_DESCR")  ,TamSX3("M4_DESCR")[1]  ,/*lPixel*/,{|| (cAliasQry)->M4_DESCR   },,.T.)
TRCell():New(oSection1,"M4_FORMULA"	,"SM4","FORMULA"  ,"@!",260,/*lPixel*/,{|| (cAliasQry)->M4_FORMULA },,.F.)
TRCell():New(oSection1,"M4_XMSG"	,"SM4","MENSAGEM" ,PesqPict("SM4","M4_XMSG")   ,200/*TamSX3("M4_XMSG")[1]*/,/*lPixel*/,{|| (cAliasQry)->M4_XMSG    },,.T.)
oSection1:Cell("M4_FILIAL")  :SetHeaderAlign("RIGHT")
oSection1:Cell("M4_CODIGO")  :SetHeaderAlign("RIGHT")
oSection1:Cell("M4_DESCR")   :SetHeaderAlign("RIGHT")
oSection1:Cell("M4_FORMULA") :SetHeaderAlign("RIGHT")
oSection1:Cell("M4_XMSG")    :SetHeaderAlign("RIGHT")

Return(oReport)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint ³ Autor ³ Antonio Carlos        ³ Data ³10/06/2019³±±
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                                           ³_cQuery += "UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(M4_XMSG, 2000, 1)) AS OBS " +Chr(10) 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):BeginQuery()

_cQuery := "SELECT " +Chr(10)
_cQuery += "M4_FILIAL, M4_CODIGO, M4_DESCR, " +Chr(10)
//_cQuery += "ISNULL( CONVERT( VARCHAR(4096), CONVERT(VARBINARY(4096), M4_XMSG)),'') AS OBS " +Chr(10)   ////SQL
_cQuery += "UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(M4_XMSG, 1000, 1)) AS M4_XMSG, " +Chr(10) 
_cQuery += " M4_FORMULA " +Chr(10)
_cQuery += "FROM " + RetSqlName("SM4") +" M4 " +Chr(10)
_cQuery += "WHERE M4.D_E_L_E_T_= ' ' AND M4_CODIGO <= '" + MV_PAR02 +"'" +Chr(10) 
_cQuery += " Order By M4_FILIAL, M4_CODIGO " +Chr(10)  

//MemoWrit("C:\CAOA\SM4.SQL",_cQuery) //Gravei a Query em TXT p/Testes
_cQuery := ChangeQuery(_cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQuery),cAliasQry, .F., .T. ) 

oReport:Section(1):EndQuery()
oReport:Section(1):Init()
PQuery(cAliasQry,oReport)     //Imprime
oReport:Section(1):Finish() 
 
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PQuery	³ Autor ³ Antonio Carlos        ³ Data ³10/06/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para imprimir a Query				 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PQuery(cAliasQry,oReport)
Local Section1  := oReport:Section(1) 

dbSelectArea(cAliasQry)
dBGotop()

oReport:SetMeter((cAliasQry)->(LastRec()))

Do While (cAliasQry)->( !Eof() )
   //IF (cAliasQry)->PIS > 0 .AND. (cAliasQry)->COFINS > 0
   	   oReport:Section(1):PrintLine()
   //ENDIF
   	
	(cAliasQry)->( DbSkip() )
	
    If oReport:Cancel()
		Exit
	EndIf
 
	oReport:IncMeter()

EndDo

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaSx1   ºAutor  ³   	    		 º Data ³ 10/06/2019  º±±
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
   AAdd(aRegs,{cPerg,"02","Codigo","","","mv_ch2","C",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","Código Fórmula"})

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
