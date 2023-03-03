#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ XREL001  ºAutor  ³ João Carlos        º Data ³  23/02/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Crédito de PIS e COFINS por Linha e Sublinha               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CAOA                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XREL001()
Local oReport

oReport:=ReportDef()
oReport:PrintDialog()

Return
//-----------------------------------------------------------------------------

Static Function ReportDef()
Local cTitRel:=OemToAnsi("Crédito de PIS e COFINS por Linha e Sublinha")
Local cPerg:="XREL001"
Local oReport
Local oSection
Local cCampo:=""

Pergunte(cPerg,.t.)

oReport := TReport():New(cPerg,cTitRel,cPerg,{|oReport| PrintReport(oReport)},cTitRel)
oReport:SetTotalInLine(.F.)
oReport:SetLandScape(.T.)

oSection := TRSection():New(oReport,"","QRY")

//                   TRCell():New(oParent ,cName ,cAlias,cTitle          ,cPicture              ,nSize              ,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
cCampo:="FT_TIPOMOV";TRCell():New(oSection,cCampo,"QRY","Tipo Movimento" ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"LEFT",          ,"LEFT" )  //Tipo Movimento
cCampo:="FT_NFISCAL";TRCell():New(oSection,cCampo,"QRY","NF"             ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"LEFT",          ,"LEFT" )  //NF
cCampo:="FT_SERIE"  ;TRCell():New(oSection,cCampo,"QRY","Série"          ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"LEFT",          ,"LEFT" )  //Série
cCampo:="FT_ITEM"   ;TRCell():New(oSection,cCampo,"QRY","Item"           ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"LEFT",          ,"LEFT" )  //Item
cCampo:="FT_CLIEFOR";TRCell():New(oSection,cCampo,"QRY","Cliente/Fornecedor"     ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"LEFT",          ,"LEFT" )  //Fornecedor
cCampo:="FT_LOJA"   ;TRCell():New(oSection,cCampo,"QRY","Loja"           ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"LEFT",          ,"LEFT" )  //Loja
cCampo:="A2_NOME"   ;TRCell():New(oSection,cCampo,"QRY","Razão Social"   ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"LEFT",          ,"LEFT" )  //Razão Social
cCampo:="FT_ENTRADA";TRCell():New(oSection,cCampo,"QRY","Data de Entrada",PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"LEFT",          ,"LEFT" )  //Data de Entrada
cCampo:="FT_EMISSAO";TRCell():New(oSection,cCampo,"QRY","Data de Emissão",PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"LEFT",          ,"LEFT" )  //Data de emissão
cCampo:="FT_ESTADO" ;TRCell():New(oSection,cCampo,"QRY","UF"             ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"LEFT",          ,"LEFT" )  //UF
cCampo:="FT_PRODUTO";TRCell():New(oSection,cCampo,"QRY","Produto"        ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"LEFT",          ,"LEFT" )  //Produto
cCampo:="ZZC_LINHA" ;TRCell():New(oSection,cCampo,"QRY","Linha"          ,"@X"                  ,08               +3,      ,      ,"LEFT",          ,"LEFT" )  //Linha
cCampo:="ZZC_SUBLIN";TRCell():New(oSection,cCampo,"QRY","Sublinha"       ,"@X"                  ,08               +3,      ,      ,"LEFT",          ,"LEFT" )  //Sublinha
cCampo:="B1_DESC"   ;TRCell():New(oSection,cCampo,"QRY","Descrição"      ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"LEFT",          ,"LEFT" )  //Descrição
cCampo:="FT_VALCONT";TRCell():New(oSection,cCampo,"QRY","Valor Contábil" ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"RIGHT",         ,"RIGHT")  //Valor contábil
cCampo:="FT_QUANT"  ;TRCell():New(oSection,cCampo,"QRY","Qtd Item"       ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"RIGHT",         ,"RIGHT")  //Qtd Item
cCampo:="FT_PRCUNIT";TRCell():New(oSection,cCampo,"QRY","Preco Unitário" ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"RIGHT",         ,"RIGHT")  //Preço Unitário
cCampo:="FT_TOTAL"  ;TRCell():New(oSection,cCampo,"QRY","Total Item"     ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"RIGHT",         ,"RIGHT")  //Total item
cCampo:="FT_BASEPIS";TRCell():New(oSection,cCampo,"QRY","Base PIS"       ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"RIGHT",         ,"RIGHT")  //Base PIS
cCampo:="FT_ALIQPIS";TRCell():New(oSection,cCampo,"QRY","Aliq PIS"       ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"RIGHT",         ,"RIGHT")  //Aliq PIS
cCampo:="FT_VALPIS" ;TRCell():New(oSection,cCampo,"QRY","Valor PIS"      ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"RIGHT",         ,"RIGHT")  //Valor PIS
cCampo:="FT_BASECOF";TRCell():New(oSection,cCampo,"QRY","Base COFINS"    ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"RIGHT",         ,"RIGHT")  //Base COFINS
cCampo:="FT_ALIQCOF";TRCell():New(oSection,cCampo,"QRY","Aliq COFINS"    ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"RIGHT",         ,"RIGHT")  //Aliq COFINS
cCampo:="FT_VALCOF" ;TRCell():New(oSection,cCampo,"QRY","Valor COFINS"   ,PesqPict("SFT",cCampo),TamSx3(cCampo)[1]+3,      ,      ,"RIGHT",         ,"RIGHT")  //Valor COFINS

Return oReport
//-----------------------------------------------------------------------------

Static Function PrintReport(oReport)
Local aArea := GetArea()
Local oSection := oReport:Section(1)
Local cQry := ""
Local nRegistros:=0

Local aTabAux:={}
Local nPos:=0

Local nTipo:=MV_PAR01  //1=Entradas,2=Saidas,3=Ambos
Local dEmiD:=MV_PAR02  //Emissao De?
Local dEmiA:=MV_PAR03  //Emissao Ate?
Local cNumD:=MV_PAR04  //NF De?
Local cNumA:=MV_PAR05  //NF Ate?
Local cCliD:=MV_PAR06  //Cliente/Fornecedor De?
Local cCliA:=MV_PAR07  //Cliente/Fornecedor Ate?

cQry+="SELECT "
cQry+="FT_TIPOMOV"
cQry+=",FT_NFISCAL"
cQry+=",FT_SERIE"
cQry+=",FT_ITEM"
cQry+=",FT_CLIEFOR"
cQry+=",FT_LOJA"
cQry+=",A2_NOME"
cQry+=",A1_NOME"
cQry+=",FT_ENTRADA"
cQry+=",FT_EMISSAO"
cQry+=",FT_ESTADO"
cQry+=",FT_PRODUTO"
//cQry+=",ZZC_LINHA"
//cQry+=",ZZC_SUBLIN"
cQry+=",B1_DESC"
cQry+=",FT_VALCONT"
cQry+=",FT_QUANT"
cQry+=",FT_PRCUNIT"
cQry+=",FT_TOTAL"
cQry+=",FT_BASEPIS"
cQry+=",FT_ALIQPIS"
cQry+=",FT_VALPIS"
cQry+=",FT_BASECOF"
cQry+=",FT_ALIQCOF"
cQry+=",FT_VALCOF"
cQry+=CRLF

cQry+=" FROM "+RetSqlName("SFT")+" SFT"+CRLF

cQry+=" LEFT JOIN "+RetSqlName("SB1")+" SB1"+CRLF
cQry+=" on B1_FILIAL='"+xFilial("SB1")+"'"+CRLF
cQry+=" AND B1_COD=FT_PRODUTO"+CRLF
cQry+=" and SB1.D_E_L_E_T_ = ' '"+CRLF
/*
cQry+=" LEFT JOIN "+RetSqlName("ZZC")+" ZZC"+CRLF
cQry+=" on ZZC_FILIAL='"+xFilial("ZZC")+"'"+CRLF
cQry+=" AND ZZC_PRODUT=FT_PRODUTO"+CRLF
cQry+=" and ZZC.D_E_L_E_T_ = ' '"+CRLF
*/
cQry+=" LEFT JOIN "+RetSqlName("SA2")+" SA2"+CRLF
cQry+=" on A2_FILIAL='"+xFilial("SA2")+"'"+CRLF
cQry+=" AND A2_COD=FT_CLIEFOR"+CRLF
cQry+=" AND A2_LOJA=FT_LOJA"+CRLF
cQry+=" and SA2.D_E_L_E_T_ = ' '"+CRLF

cQry+=" LEFT JOIN "+RetSqlName("SA1")+" SA1"+CRLF
cQry+=" on A1_FILIAL='"+xFilial("SA1")+"'"+CRLF
cQry+=" AND A1_COD=FT_CLIENT"+CRLF
cQry+=" AND A1_LOJA=FT_LOJENT"+CRLF
cQry+=" and SA1.D_E_L_E_T_ = ' '"+CRLF

cQry+=" WHERE FT_FILIAL='"+xFilial("SFT")+"'"+CRLF
Do Case
	Case nTipo==1  //1=Entradas,2=Saidas,3=Ambos
		cQry+=" AND FT_TIPOMOV='E'"+CRLF  //Tipo Mov.: E=Entrada;S=Saida
	Case nTipo==2  //1=Entradas,2=Saidas,3=Ambos
		cQry+=" AND FT_TIPOMOV='S'"+CRLF  //Tipo Mov.: E=Entrada;S=Saida
EndCase
cQry+=" AND FT_EMISSAO BETWEEN '"+DtoS(dEmiD)+"' AND '"+DtoS(dEmiA)+"'"+CRLF
cQry+=" AND FT_NFISCAL BETWEEN '"+cNumD+"' AND '"+cNumA+"'"+CRLF
cQry+=" AND FT_CLIEFOR BETWEEN '"+cCliD+"' AND '"+cCliA+"'"+CRLF
cQry+=" AND ( FT_BASEPIS > 0 or FT_BASECOF > 0 ) "+CRLF
cQry+=" AND FT_DTCANC = ' '"+CRLF
cQry+=" AND SFT.D_E_L_E_T_ = ' '"+CRLF
cQry+=" ORDER BY FT_NFISCAL"+CRLF

dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQry),'QRY',.T.,.T.)

TCSetField('QRY','FT_ENTRADA','D',8,0)
TCSetField('QRY','FT_EMISSAO','D',8,0)

nRegistros:=0
QRY->(dbEval({|| nRegistros++}))
oReport:SetMeter(nRegistros)

dbSelectArea("QRY")

oSection:Init()

QRY->(dbGoTop())
While QRY->(!Eof())

	oReport:IncMeter()

	If oReport:Cancel()
		Exit
	EndIf

	oSection:Cell("FT_TIPOMOV"):SetValue(If(QRY->FT_TIPOMOV=="E","Entrada",If(QRY->FT_TIPOMOV=="S","Saída","N/D")))
	if ! empty( QRY->A1_NOME )
		oSection:Cell("A2_NOME"   ):SetValue(QRY->A1_NOME   )
	else
		oSection:Cell("A2_NOME"   ):SetValue(QRY->A2_NOME   )
	endif

	if ZZC->( dbSeek( xFilial("ZZC") + QRY->FT_PRODUTO ) )
		oSection:Cell("ZZC_LINHA" ):SetValue(ZZC->ZZC_LINHA)
		oSection:Cell("ZZC_SUBLIN"):SetValue(ZZC->ZZC_SUBLIN)
	else
		oSection:Cell("ZZC_LINHA" ):SetValue("")
		oSection:Cell("ZZC_SUBLIN"):SetValue("")
	endif

	oSection:PrintLine()

	QRY->(dbSkip())
End

oSection:Finish()

QRY->(dbCloseArea())

RestArea(aArea)
Return
//-----------------------------------------------------------------------------
