#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH"
#include "rwmake.ch"
#include "TOTVS.ch"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "Eicsi400.ch"
#INCLUDE "AvPrint.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWFILTER.CH"
#INCLUDE "FWMVCDEF.CH"
#define CRLF chr(13) + chr(10)  

/*/{Protheus.doc} ZPECR012
Relatorio Produto e Complemento
@author Antonio Oliveira
@since 22/08/2022
@version 2.0
/*/
User Function ZPECR012()
Local aAreaSB1      := SB1->( GetArea() )
Local nOpca         := 1
Local aPergs        := {}
Local _cCodigo      := SPACE(23)
Private cDescricao  := "Relação Produto com Complemento"
Private MV_PAR01    := ""
Private cDescProd   := ""
Private aRetP       := {}
Private cAliasQry	:= GetNextAlias()
Private oReport, oSection1          // objeto que contem o relatorio

aAdd( aPergs ,{1,"Código....: ",_cCodigo   ,"@!", , "SB1",'',60,.F.})

If ParamBox(aPergs, "Parâmetros p/ Relatório", aRetP, , , , , , , , ,.T.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi(cDescricao + " - Barueri") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a impressão de " + cDescricao) SIZE 268, 8 OF oDlg PIXEL
   @ 38, 15 SAY OemToAnsi("Da Caoa Peças.") SIZE 268, 8 OF oDlg PIXEL
   @ 48, 15 SAY OemToAnsi("Confirma Geração do Documento ? ") SIZE 268, 8 OF oDlg PIXEL
   DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
   DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
   ACTIVATE MSDIALOG oDlg CENTER

   If nOpca == 1
      oReport := ReportDef()
      oReport:PrintDialog()   
   Endif

Endif

If Select(cAliasQry) <> 0
	(cAliasQry)->(DbCloseArea())
	Ferase(cAliasQry+GetDBExtension())
Endif

RestArea( aAreaSB1 )

Return()


/*/{Protheus.doc} ZPECR012

@author Antonio Oliveira
@since 22/08/2022
@version 2.0
/*/
Static Function ReportDef()

MV_PAR01 := aRetP[01]

oReport:= TReport():New("ZPECR020",cDescricao,"BARUERI", {|oReport| ReportPrint(oReport)},cDescricao) 
oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.

//Verifica os parâmetros selecionados via Pergunte     
Pergunte(oReport:GetParam(),.F.)
oSection1 := TRSection():New(oReport,cDescricao + " - Barueri",{cAliasQry},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSection1,"CODIGO"   ,"cAliasQry","CODIGO",PesqPict("SB1","B1_COD"),TamSX3("B1_COD")[1],/*lPixel*/,{||cAliasQry->CODIGO})
TRCell():New(oSection1,"DESCRICAO","cAliasQry","DESCRICAO",PesqPict("SB1","B1_DESC"),TamSX3("B1_DESC")[1],/*lPixel*/,{||cAliasQry->DESCRICAO})
TRCell():New(oSection1,"TIPO"     ,"cAliasQry","TIPO",PesqPict("SB1","B1_TIPO"),TamSX3("B1_TIPO")[1],/*lPixel*/,{||cAliasQry->TIPO})
TRCell():New(oSection1,"GRUPO"    ,"cAliasQry","GRUPO",PesqPict("SB1","B1_GRUPO"),TamSX3("B1_GRUPO")[1],/*lPixel*/,{||cAliasQry->GRUPO})
TRCell():New(oSection1,"NCM"      ,"cAliasQry","NCM",PesqPict("SB1","B1_POSIPI"),TamSX3("B1_POSIPI")[1],/*lPixel*/,{||cAliasQry->NCM})
TRCell():New(oSection1,"ORIGEM"   ,"cAliasQry","ORIGEM",PesqPict("SB1","B1_ORIGEM"),TamSX3("B1_ORIGEM")[1],/*lPixel*/,{||cAliasQry->ORIGEM})
TRCell():New(oSection1,"GRUPOTRIB","cAliasQry","GRUPOTRIB",PesqPict("SB1","B1_GRTRIB"),TamSX3("B1_GRTRIB")[1],/*lPixel*/,{||cAliasQry->GRUPOTRIB})
TRCell():New(oSection1,"PRV1"     ,"cAliasQry","PRV1",PesqPict("SB1","B1_PRV1"),TamSX3("B1_PRV1")[1],/*lPixel*/,{||cAliasQry->PRV1})
TRCell():New(oSection1,"CUSTD"    ,"cAliasQry","CUSTD",PesqPict("SB1","B1_CUSTD"),TamSX3("B1_CUSTD")[1],/*lPixel*/,{||cAliasQry->CUSTD})
TRCell():New(oSection1,"MARCAPECA","cAliasQry","MARCAPECA","@!",10,/*lPixel*/,{||cAliasQry->MARCAPECA})
TRCell():New(oSection1,"LINHA"    ,"cAliasQry","LINHA","@!",10,/*lPixel*/,{||cAliasQry->LINHA})
TRCell():New(oSection1,"FAMILIA"  ,"cAliasQry","FAMILIA","@!",10,/*lPixel*/,{||cAliasQry->FAMILIA})
TRCell():New(oSection1,"CONTA_CTB","cAliasQry","CONTA_CTB","@!",15,/*lPixel*/,{||cAliasQry->CONTA_CTB})
TRCell():New(oSection1,"ATIVO"    ,"cAliasQry","ATIVO",PesqPict("SB1","B1_MSBLQL"),TamSX3("B1_MSBLQL")[1],/*lPixel*/,{||cAliasQry->ATIVO})
TRCell():New(oSection1,"DESC_1"   ,"cAliasQry","DESCRICAO_LONGA","@!",240,/*lPixel*/,{||cAliasQry->DESC_1})
TRCell():New(oSection1,"OBS"      ,"cAliasQry","OBS","@!",2000,/*lPixel*/,{||_cDescProd})

Return(oReport) 


/*/{Protheus.doc} ZPECR012

@author Antonio Oliveira
@since 22/08/2022
@version 2.0
/*/
Static Function ReportPrint(oReport)
Local _cQ           := " "

//oSection1:BeginQuery()
_cQ := " SELECT " 
_cQ += " 	  B1_COD AS CODIGO        "
_cQ += " 	, B1_DESC AS DESCRICAO    " 
_cQ += " 	, B1_TIPO AS TIPO         " 
_cQ += " 	, B1_GRUPO AS GRUPO       "
_cQ += " 	, B1_POSIPI AS NCM        "
_cQ += " 	, B1_ORIGEM AS ORIGEM     "
_cQ += " 	, B1_GRTRIB AS GRUPOTRIB  "
_cQ += " 	, B1_PRV1 AS PRV1         "
_cQ += " 	, B1_CUSTD AS CUSTD       "
_cQ += " 	, B5_MARPEC AS MARCAPECA  "
_cQ += "	, B5_CODLIN AS LINHA      "
_cQ += "	, B5_CODFAM AS FAMILIA    "
_cQ += "	, B1_CONTA AS CONTA_CTB   "
_cQ += "	, B1_XDESCL1 AS DESC_1    "
//_cQ += "	, UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(B1.B1_VM_I, 2000, 1)) AS OBS "
_cQ += "	, B1_MSBLQL AS ATIVO      "
_cQ += "FROM " + RetSQLname("SB1") + " B1 "
_cQ += "INNER JOIN " + RetSQLname("SB5") + " B5 " 
_cQ += "	ON B5.D_E_L_E_T_  = ' '  "
_cQ += "	AND B5.B5_COD = B1.B1_COD      "
_cQ += "WHERE B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.D_E_L_E_T_ = ' ' "
IF !Empty(MV_PAR01)
    _cQ += "   AND B1.B1_COD = '" + MV_PAR01 + "'"
EndIF
_cQ += "ORDER BY 1                   "

dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQ),cAliasQry, .T., .T. ) 
//oSection1:EndQuery()
PQuery(cAliasQry,oReport) //Imprime
oReport:IncMeter()
oSection1:Finish() 

Return


/*/{Protheus.doc} ZPECR012
Imprimir a Query	
@author Antonio Oliveira
@since 22/08/2022
@version 2.0
/*/
Static Function PQuery(cAliasQry,oReport)
Local _cCodProd    := ''
Private _cDescProd := ''

dbSelectArea(cAliasQry)
dBGotop()

oReport:SetMeter((cAliasQry)->(LastRec()))
oSection1:Init()

Do While !(cAliasQry)->( Eof() )

    SB1->(DbSetOrder(1))
    If SB1->(DbSeek( xFilial("SB1") + Alltrim(MV_PAR01) ) )
        _cCodProd := AllTrim(SB1->B1_DESC_I)

       _cDescProd := MSMM (_cCodProd,80,,,3,,,"SB1","B1_COD")

        /*SYP->(DbSetOrder(1))
        If SYP->(DbSeek( xFilial("SYP") + _cCodProd ) )
            _cDescProd := Alltrim(SYP->YP_TEXTO)
        Endif*/
    ENDIF

    oReport:IncMeter()
    oSection1:Cell("CODIGO"):SetValue((cAliasQry)->CODIGO)
    oSection1:Cell("DESCRICAO"):SetValue((cAliasQry)->DESCRICAO)
    oSection1:Cell("TIPO"):SetValue((cAliasQry)->TIPO)
    oSection1:Cell("GRUPO"):SetValue((cAliasQry)->GRUPO)
    oSection1:Cell("NCM"):SetValue((cAliasQry)->NCM)
    oSection1:Cell("ORIGEM"):SetValue((cAliasQry)->ORIGEM)
    oSection1:Cell("GRUPOTRIB"):SetValue((cAliasQry)->GRUPOTRIB)
    oSection1:Cell("PRV1"):SetValue((cAliasQry)->PRV1)
    oSection1:Cell("CUSTD"):SetValue((cAliasQry)->CUSTD) 
    oSection1:Cell("MARCAPECA"):SetValue((cAliasQry)->MARCAPECA)    
    oSection1:Cell("LINHA"):SetValue((cAliasQry)->LINHA)
    oSection1:Cell("FAMILIA"):SetValue((cAliasQry)->FAMILIA)
    oSection1:Cell("CONTA_CTB"):SetValue((cAliasQry)->CONTA_CTB)
    oSection1:Cell("ATIVO"):SetValue((cAliasQry)->ATIVO)
    oSection1:Cell("DESC_1"):SetValue((cAliasQry)->DESC_1)
    oSection1:Cell("OBS"):SetValue(_cDescProd)
     
	oSection1:PrintLine()
    TReport():Print() 

	(cAliasQry)->( DbSkip() )
	
EndDo

Return()
