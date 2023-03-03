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

/*/{Protheus.doc} ZSAPR001
Relatorio  Cadastro LOG Monitor Integração SAP 
@author Antonio Oliveira
@since 22/06/2022
@version 2.0
/*/
User Function ZSAPR001()
Local aAreaSZ7      := SZ7->( GetArea() )
Local nOpca         := 1
Local aPergs        := {}

Private cOpepro    	:= SPACE(01)
Private cOpeSAP    	:= SPACE(01)

Private cDescricao  := "Relação Integração SAP"
Private dDataI      := Date()
Private dDataF      := Date()
Private aRetP       := {}
Private cAliasQry	:= GetNextAlias()
Private oReport, oSection1          // objeto que contem o relatorio

aadd( aPergs, {1,"Data Ini Envio.: ",dDataI,"@D", , ""   ,  "" ,60,.F.})  //1
aadd( aPergs, {1,"Data Fim Envio.: ",dDataF,"@D", , ""   ,  "" ,60,.F.})  //2

If ParamBox(aPergs, "Parâmetros p/ Relatório", aRetP, , , , , , , , ,.T.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi(cDescricao) PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a impressão de " + cDescricao) SIZE 268, 8 OF oDlg PIXEL
   @ 38, 15 SAY OemToAnsi("Da Caoa.") SIZE 268, 8 OF oDlg PIXEL
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

RestArea( aAreaSZ7 )

Return()


/*/{Protheus.doc} ZSAPR001
Relatorio  Integração SAP (2 na planilha)
@author Antonio Oliveira
@since 28/11/2022
@version 2.0
/*/
Static Function ReportDef()

oReport:= TReport():New("ZSAPR001",cDescricao,"", {|oReport| ReportPrint(oReport)},cDescricao) 
oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.

//Verifica os parâmetros selecionados via Pergunte
Pergunte(oReport:GetParam(),.F.)

oSection1 := TRSection():New(oReport,cDescricao + " - ",{cAliasQry},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSection1,"FILIAL"   ,"cAliasQry","FILIAL"   ,PesqPict("SZ7","Z7_FILIAL") ,TamSX3("Z7_FILIAL")[1] ,/*lPixel*/,{||cAliasQry->FILIAL})
TRCell():New(oSection1,"LOTE"     ,"cAliasQry","LOTE"     ,PesqPict("SZ7","Z7_XLOTE")  ,TamSX3("Z7_XLOTE")[1]  ,/*lPixel*/,{||cAliasQry->LOTE})
TRCell():New(oSection1,"SEQUENCIA","cAliasQry","SEQUENCIA",PesqPict("SZ7","Z7_XSEQUEN"),TamSX3("Z7_XSEQUEN")[1],/*lPixel*/,{||cAliasQry->SEQUENCIA})
TRCell():New(oSection1,"TABELA"   ,"cAliasQry","TABELA"   ,PesqPict("SZ7","Z7_XTABELA"),TamSX3("Z7_XTABELA")[1],/*lPixel*/,{||cAliasQry->TABELA})
TRCell():New(oSection1,"OPERACAO" ,"cAliasQry","OPERACAO" ,PesqPict("SZ7","Z7_OPERACA"),TamSX3("Z7_OPERACA")[1],/*lPixel*/,{||cAliasQry->OPERACAO})
TRCell():New(oSection1,"OPER_PROT","cAliasQry","OPER_PROT","@!",TamSX3("Z7_XOPEPRO")[1],/*lPixel*/,/*{||cAliasQry->OPEPRO}*/)
TRCell():New(oSection1,"OPER_SAP" ,"cAliasQry","OPER_SAP" ,"@!",TamSX3("Z7_XOPESAP")[1],/*lPixel*/,/*{||cAliasQry->OPESAP}*/)
TRCell():New(oSection1,"RETORNO"  ,"cAliasQry","RETORNO"  ,PesqPict("SZ7","Z7_XRETORN"),TamSX3("Z7_XRETORN")[1],/*lPixel*/,{||cAliasQry->RETORN})
TRCell():New(oSection1,"DT_INC"   ,"cAliasQry","DT_INC"   ,PesqPict("SZ7","Z7_XDTINC") ,TamSX3("Z7_XDTINC")[1] ,/*lPixel*/,{||cAliasQry->DTINC})
TRCell():New(oSection1,"HR_INC"   ,"cAliasQry","HR_INC"   ,PesqPict("SZ7","Z7_XHRINC") ,TamSX3("Z7_XHRINC")[1] ,/*lPixel*/,{||cAliasQry->HRINC})
TRCell():New(oSection1,"DT_ENV"   ,"cAliasQry","DT_ENV"   ,PesqPict("SZ7","Z7_XDTENV") ,TamSX3("Z7_XDTENV")[1] ,/*lPixel*/,{||cAliasQry->DTENV})
TRCell():New(oSection1,"HR_ENV"   ,"cAliasQry","HR_ENV"   ,PesqPict("SZ7","Z7_XHRENV") ,TamSX3("Z7_XHRENV")[1] ,/*lPixel*/,{||cAliasQry->HRENV})
TRCell():New(oSection1,"DT_RET"   ,"cAliasQry","DT_RET"   ,PesqPict("SZ7","Z7_XDTRET") ,TamSX3("Z7_XDTRET")[1] ,/*lPixel*/,{||cAliasQry->XDTRET})
TRCell():New(oSection1,"HR_RET"   ,"cAliasQry","HR_RET"   ,PesqPict("SZ7","Z7_XHRRET") ,TamSX3("Z7_XHRRET")[1] ,/*lPixel*/,{||cAliasQry->XHRRET})
TRCell():New(oSection1,"IDSAP"    ,"cAliasQry","IDSAP"    ,PesqPict("SZ7","Z7_XIDSAP") ,TamSX3("Z7_XIDSAP")[1] ,/*lPixel*/,{||cAliasQry->IDSAP})
TRCell():New(oSection1,"XML"      ,"cAliasQry","XML"      ,PesqPict("SZ7","Z7_XXML")   ,TamSX3("Z7_XXML")[1]   ,/*lPixel*/,{||cAliasQry->XXML})
TRCell():New(oSection1,"ORIGEM"   ,"cAliasQry","ORIGEM"   ,PesqPict("SZ7","Z7_ORIGEM") ,TamSX3("Z7_ORIGEM")[1] ,/*lPixel*/,{||cAliasQry->ORIGEM})
TRCell():New(oSection1,"DOCTO"    ,"cAliasQry","DOCTO"    ,PesqPict("SZ7","Z7_DOCORI") ,TamSX3("Z7_DOCORI")[1] ,/*lPixel*/,{||cAliasQry->DOCORI})
TRCell():New(oSection1,"SERIE"    ,"cAliasQry","SERIE"    ,PesqPict("SZ7","Z7_SERORI") ,TamSX3("Z7_SERORI")[1] ,/*lPixel*/,{||cAliasQry->SERORI })
TRCell():New(oSection1,"CLIENTE"  ,"cAliasQry","CLIENTE"  ,PesqPict("SZ7","Z7_CLIFOR") ,TamSX3("Z7_CLIFOR")[1] ,/*lPixel*/,{||cAliasQry->CLIFOR})
TRCell():New(oSection1,"LOJA"     ,"cAliasQry","LOJA"     ,PesqPict("SZ7","Z7_LOJA")   ,TamSX3("Z7_LOJA")[1]   ,/*lPixel*/,{||cAliasQry->LOJA})

Return(oReport) 


/*/{Protheus.doc} ZSAPR001
Relatorio  Cadastro Produtos (2 na planilha)
@author Antonio Oliveira
@since 28/11/2022
@version 2.0
/*/
Static Function ReportPrint(oReport)
Local _cWhere   := ""

If !Empty(aRetP[01]) 
    _cWhere += " AND SZ7.Z7_XDTENV >= '" + DTOS(aRetP[01]) + "' "  
    _cWhere += " AND SZ7.Z7_XDTENV <= '" + DTOS(aRetP[02]) + "' "  
endif

_cWhere := "%"+_cWhere+"%"

BeginSql Alias cAliasQry //Define o nome do alias temporário 

    SELECT SZ7.Z7_FILIAL    AS FILIAL
        , SZ7.Z7_XLOTE      AS LOTE
        , SZ7.Z7_XSEQUEN    AS SEQUENCIA
        , SZ7.Z7_XTABELA    AS TABELA    
        , SZ7.Z7_OPERACA    AS OPERACAO
        , SZ7.Z7_XOPEPRO    AS OPEPRO
        , SZ7.Z7_XOPESAP    AS OPESAP
        ,UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(Z7_XRETORN, 2000, 1)) AS RETORN
        , Substr(TO_CHAR(SZ7.Z7_XDTINC),7,2)||'/'||Substr(TO_CHAR(SZ7.Z7_XDTINC),5,2)||'/'||Substr(TO_CHAR(SZ7.Z7_XDTINC),1,4) AS DTINC      
        , SZ7.Z7_XHRINC     AS HRINC
        , Substr(TO_CHAR(SZ7.Z7_XDTRET),7,2)||'/'||Substr(TO_CHAR(SZ7.Z7_XDTRET),5,2)||'/'||Substr(TO_CHAR(SZ7.Z7_XDTRET),1,4) AS DTRET      
        , SZ7.Z7_XHRRET     AS HRRET 
        , Substr(TO_CHAR(SZ7.Z7_XDTENV),7,2)||'/'||Substr(TO_CHAR(SZ7.Z7_XDTENV),5,2)||'/'||Substr(TO_CHAR(SZ7.Z7_XDTENV),1,4) AS DTENV     
        , SZ7.Z7_XHRENV     AS HRENV 
        , SZ7.Z7_XIDSAP     AS IDSAP  
        ,UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(Z7_XXML, 2000, 1)) AS XXML           
        , SZ7.Z7_ORIGEM     AS ORIGEM     
        , SZ7.Z7_DOCORI     AS DOCORI 
        , SZ7.Z7_SERORI     AS SERORI 
        , SZ7.Z7_CLIFOR     AS CLIFOR
        , SZ7.Z7_LOJA       AS LOJA 
    FROM  %Table:SZ7% SZ7
    WHERE  
        SZ7.%notDel%
        %Exp:_cWhere%
EndSql

If (cAliasQry)->(Eof())  
    MsgInfo("Não há dados a serem consultados.","CAOA")
    Return
Endif


//oSection1:EndQuery()
PQuery(cAliasQry,oReport) //Imprime
oReport:IncMeter()
oSection1:Finish() 

Return()


/*/{Protheus.doc} ZSAPR001
Imprimir a Query	
@author Antonio Oliveira
@since 28/11/2022
@version 2.0
/*/
Static Function PQuery(cAliasQry,oReport)

dbSelectArea(cAliasQry)
dBGotop()

oReport:SetMeter((cAliasQry)->(LastRec()))
oSection1:Init()

Do While !(cAliasQry)->( Eof() )

    cOpepro := (cAliasQry)->OPEPRO
    cOpeSAP := (cAliasQry)->OPESAP

    oReport:IncMeter()

    oSection1:Cell("FILIAL"):SetValue((cAliasQry)->FILIAL)
    oSection1:Cell("LOTE"):SetValue((cAliasQry)->LOTE)
    oSection1:Cell("SEQUENCIA"):SetValue((cAliasQry)->SEQUENCIA)
    oSection1:Cell("TABELA"):SetValue((cAliasQry)->TABELA)
    oSection1:Cell("OPERACAO"):SetValue((cAliasQry)->OPERACAO)
    oSection1:Cell("OPER_PROT"):SetValue(cOpepro)
    oSection1:Cell("OPER_SAP"):SetValue(cOpeSAP)
    oSection1:Cell("RETORNO"):SetValue((cAliasQry)->RETORN)
    oSection1:Cell("DT_INC"):SetValue((cAliasQry)->DTINC)
    oSection1:Cell("HR_INC"):SetValue((cAliasQry)->HRINC)
    oSection1:Cell("DT_ENV"):SetValue((cAliasQry)->DTENV)
    oSection1:Cell("HR_ENV"):SetValue((cAliasQry)->HRENV)
    oSection1:Cell("DT_RET"):SetValue(DTRET)
    oSection1:Cell("HR_RET"):SetValue(HRRET)
    oSection1:Cell("IDSAP"):SetValue((cAliasQry)->IDSAP)
    oSection1:Cell("XML"):SetValue((cAliasQry)->XXML)
    oSection1:Cell("ORIGEM"):SetValue((cAliasQry)->ORIGEM)
    oSection1:Cell("DOCTO"):SetValue((cAliasQry)->DOCORI)
    oSection1:Cell("SERIE"):SetValue((cAliasQry)->SERORI)
    oSection1:Cell("CLIENTE"):SetValue((cAliasQry)->CLIFOR)
    oSection1:Cell("LOJA"):SetValue((cAliasQry)->LOJA)

	oSection1:PrintLine()
    TReport():Print() 

	(cAliasQry)->( DbSkip() )
	
EndDo

Return()
