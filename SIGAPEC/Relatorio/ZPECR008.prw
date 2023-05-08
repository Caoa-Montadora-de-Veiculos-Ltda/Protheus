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

/*/{Protheus.doc} ZPECR008
Relatorio FP
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
User Function ZPECR008()
Local aAreaSA1      := SA1->( GetArea() )
Local nOpca         := 1
Local aPergs        := {}
Local cCodigo       := SPACE(06)
Private MV_PAR01    := ""
Private aRetP       := {}
Private cAliasQry	:= GetNextAlias()
Private oReport, oSection1          // objeto que contem o relatorio

aAdd( aPergs ,{1,"Cliente   ",cCodigo      ,"@!",'.T.',"SA1" ,'.T.',40,.F.})

If ParamBox(aPergs, "Parâmetros p/ Relatório", aRetP, , , , , , , , ,.T.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Relação FLOORPLAN - Barueri") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a impressão de Conferência da Relação FLOORPLAN") SIZE 268, 8 OF oDlg PIXEL
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

RestArea( aAreaSA1 )

Return()


/*/{Protheus.doc} ZPECR008
Definição do Relatorio FP
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
Static Function ReportDef()

MV_PAR01 := aRetP[01]

oReport:= TReport():New("ZPECR008",' Relação FLOORPLAN ',"BARUERI", {|oReport| ReportPrint(oReport)},' FP ') 
oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.

//Verifica os parâmetros selecionados via Pergunte
Pergunte(oReport:GetParam(),.F.)

oSection1 := TRSection():New(oReport,"FLOORPLAN - Barueri",{cAliasQry},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSection1,"CODIGO"         ,"cAliasQry","COD_CLIENTE","@!",10,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CNPJ"           ,"cAliasQry","CNPJ","@!",14,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"NOME"           ,"cAliasQry","NOME","@!",70,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"LC_CAOA"        ,"cAliasQry","LIMITE_CAOA",PesqPict("SA1","A1_LC"),TamSX3("A1_LC")[1],/*lPixel*/,{||cAliasQry->LIMITE_CAOA})
TRCell():New(oSection1,"CONS_CAOA"      ,"cAliasQry","CONSUMIDO_CAOA",PesqPict("SA1","A1_LC"),TamSX3("A1_LC")[1],/*lPixel*/,{||cAliasQry->CONSUMIDO_CAOA})
TRCell():New(oSection1,"SALDO_CAOA"     ,"cAliasQry","SALDO_CAOA",PesqPict("SA1","A1_LC"),TamSX3("A1_LC")[1],/*lPixel*/,{||cAliasQry->SALDO_CAOA})
TRCell():New(oSection1,"LC_FLOORPLAN"   ,"cAliasQry","LIMITE_FLOORPLAN",PesqPict("SA1","A1_XLC"),TamSX3("A1_XLC")[1],/*lPixel*/,{||cAliasQry->LIMITE_FLOORPLAN})
TRCell():New(oSection1,"CONS_FLOORPLAN" ,"cAliasQry","CONSUMIDO_FLOORPLAN",PesqPict("SA1","A1_XLMUSA"),TamSX3("A1_XLMUSA")[1],/*lPixel*/,{||cAliasQry->CONSUMIDO_FLOORPLAN})
TRCell():New(oSection1,"SALDO_FLOORPLAN","cAliasQry","SALDO_FLOORPLAN",PesqPict("SA1","A1_XLMUSA"),TamSX3("A1_XLMUSA")[1],/*lPixel*/,{||cAliasQry->SALDO_FLOORPLAN})
        
//TRPosition():New(oSection1,"SA2",1,{|| xFilial("SA2")+(cAliasQry)->FORNECE+(cAliasQry)->LOJA})	
		
Return(oReport) 


/*/{Protheus.doc} ZPECR008
Impressão do relatório FP
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
Static Function ReportPrint(oReport)
Local _cQ       := " "

//oSection1:BeginQuery()

_cQ := ""
_cQ += "SELECT 	s.a1_cod   AS COD_CLIENTE,   " 
_cQ += "     	S.A1_CGC   AS CNPJ , "
_cQ += "        S.A1_NOME  AS NOME,   "

//_cQ += "     	(	select c.a1_CGC FROM " + RetSQLname("SA1") +" C  "
//_cQ += " 			WHERE c.a1_cod = s.a1_cod     "
//_cQ += "     		and c.a1_loja = '01'  ) CNPJ  "
//_cQ += "     		,(select c.a1_nome            "
//_cQ += "        from " + RetSQLname("SA1") +" C   "   
//_cQ += "            where c.a1_cod = s.a1_cod     "
//_cQ += "            and c.a1_loja = '01') NOME,   "
_cQ += "     	sum(s.a1_lc)     				 AS LIMITE_CAOA,         "
_cQ += "	    sum(s.a1_msaldo) 				 AS CONSUMIDO_CAOA,      "
_cQ += "     	sum(s.a1_lc) - sum(s.a1_msaldo)  AS SALDO_CAOA,          "
_cQ += "     	sum(s.a1_xlc)            		 AS LIMITE_FLOORPLAN,    " 
_cQ += "     	sum(s.a1_xlmusa)      			 AS CONSUMIDO_FLOORPLAN, "
_cQ += "     	sum(s.a1_xlc) - sum(s.a1_xlmusa) AS SALDO_FLOORPLAN      "
_cQ += "from "+ RetSQLname("SA1") +" S  "
_cQ += "WHERE s.a1_filial = '" + xFilial('SA1') + "'  "
If aRetP[01] <> "******"
    _cQ += "         and s.a1_cod =  '" + aRetP[01]  + "' "   + CRLF
ENDIF
//incluido validação tipo de crédito  DAC 17/04/2023
_cQ += "	AND SA1.A1_XTPCRED IN ('1') " 
_cQ += "and s.d_e_l_e_t_ = ' '        "
_cQ += "GROUP BY s.a1_cod             "
_cQ += "ORDER BY 3                    "

dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQ),cAliasQry, .T., .T. ) 

//oSection1:EndQuery()
PQuery(cAliasQry,oReport) //Imprime
oReport:IncMeter()
oSection1:Finish() 

Return


/*/{Protheus.doc} ZPECR008
Imprimir a Query	
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
Static Function PQuery(cAliasQry,oReport)
Local cMens   := " "

dbSelectArea(cAliasQry)
dBGotop()

oReport:SetMeter((cAliasQry)->(LastRec()))
oSection1:Init()

Do While !(cAliasQry)->( Eof() )

    /*IF (cAliasQry)->CODIGO_CLIENTE <> aRetP[01] 
        (cAliasQry)->( DbSkip() )
        LOOP
    ENDIF*/

    oReport:IncMeter()

    oSection1:Cell("CODIGO"):SetValue((cAliasQry)->COD_CLIENTE)
    oSection1:Cell("CNPJ"):SetValue((cAliasQry)->CNPJ)
    oSection1:Cell("NOME"):SetValue((cAliasQry)->NOME)
    oSection1:Cell("LC_CAOA"):SetValue((cAliasQry)->LIMITE_CAOA)
    oSection1:Cell("CONS_CAOA"):SetValue((cAliasQry)->CONSUMIDO_CAOA)
    oSection1:Cell("SALDO_CAOA"):SetValue((cAliasQry)->SALDO_CAOA)
    oSection1:Cell("LC_FLOORPLAN"):SetValue((cAliasQry)->LIMITE_FLOORPLAN)
    oSection1:Cell("CONS_FLOORPLAN"):SetValue((cAliasQry)->CONSUMIDO_FLOORPLAN)
    oSection1:Cell("SALDO_FLOORPLAN"):SetValue((cAliasQry)->SALDO_FLOORPLAN)

	oSection1:PrintLine()
    TReport():Print() 
    cMens := " "
	(cAliasQry)->( DbSkip() )
	
EndDo

Return()
