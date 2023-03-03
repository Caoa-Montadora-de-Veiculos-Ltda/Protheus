#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwbrowse.ch"
#include 'fwmvcdef.ch'

#DEFINE CRLF		chr(13) + chr(10)

/*
=====================================================================================
Programa.:              CMVPCP14
Autor....:              Marcelo Carneiro
Data.....:              14/01/2019
Descricao / Objetivo:   Consulta Tela de Integração MES
Doc. Origem:            
Solicitante:            Projeto
Obs......:              
=====================================================================================
*/
User Function CMVPCP14()

Local aRet		:= {}
Local aParambox	:= {}
Local oDlgPCP	:= nil
Local aCoors		:= 	FWGetDialogSize( oMainWnd )
Local bClose		:= { || oDlgPCP:End() }
Local bOk			:= { || oDlgPCP:End()  }

private oFWLayer	:= nil
private oDadosBrw	:= nil
private oDespesBrw	:= nil
private oHistorBrw	:= nil
Private bSair       := .F.
Private oGetMemo       
Private cErroInt    := ''
Private oDetBrow
Private aExcel      := {}
Private aExcel2     := {}
Private aErros    := {}

Private aDados	:= {}
Private aItens  := {}
Private aDetalhes := {}
Private aButtons      := {{"Exporta Excel"   , {|| GeraExcel(1,aExcel)}, "Exporta Excel","Exporta Excel",{|| .T.}},;
                        {"Importa Consulta", {|| Imp_Consulta()}, "Importa Consulta","Importa Consulta",{|| .T.}},;
                        {"Exporta Erro",     {|| GeraExcel(3,aErros)}, "Exporta Erro","Exporta Erro",{|| .T.}}  } 


SGO->(dbSetOrder(1))
NNR->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SB2->(dbSetOrder(1))
D14->(dbSetOrder(3)) //D14_FILIAL+D14_LOCAL+D14_PRODUT+D14_ENDER+D14_LOTECT+D14_NUMLOT+D14_NUMSER+D14_IDUNIT
SD4->(dbSetOrder(2))//D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
AAdd( aParambox,{1,"Dt Processamento Inicial"	,Ctod("")						,""		    ,"" ,""		,"",050,.F.})
AAdd( aParambox,{1,"Dt Processamento Final"	    ,Ctod("")						,""		    ,""	,""		,"",050,.F.})
AAdd( aParambox,{3,"Status" , 1 , { "Sucesso" , "Com Erro", "Todos" } , 070 , "" , .T. } )
AAdd( aParamBox,{1,"Ordem de Produção"       	,Space(tamSx3("D3_OP")[1])  , "@!", ,"SC2" ,, 070	, .F.	})
AAdd( aParamBox,{1,"Produto"       	            ,Space(tamSx3("B1_COD")[1])  , "@!", ,"SB1" ,, 070	, .F.	})
AAdd( aParamBox,{1,"Recurso"       	            ,Space(tamSx3("H1_CODIGO")[1])  , "@!", ,"SH1" ,, 070	, .F.	})
If ParamBox(aParambox, "Filtro Log Integação"	, @aRet, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .T. /*lUserSave*/)
	
	fwMsgRun(, { || Proc_Dados() }		, "Log de MES", "Aguarde.... Selecionando registros..." )
	
	IF Len(aDados)== 0 
		MsgAlert('Não há dados para consulta !!')
		Return
	EndIF
	aItens  := {{}}
	DEFINE MSDIALOG oDlgPCP TITLE 'Log Integração MES x Protheus' FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4] PIXEL STYLE DS_MODALFRAME
		oFWLayer := FWLayer():New()
		oFWLayer:Init( oDlgPCP /*oOwner*/, .F. /*lCloseBtn*/)
	
		oFWLayer:AddLine( 'UP'		/*cID*/, 50 /*nPercHeight*/, .F. /*lFixed*/)
		oFWLayer:AddLine( 'MIDDLE'	/*cID*/, 40 /*nPercHeight*/, .F. /*lFixed*/)
	
		oFWLayer:AddCollumn( 'ALLUP'	/*cID*/, 100 /*nPercWidth*/, .T. /*lFixed*/, 'UP'		/*cIDLine*/)
		oFWLayer:AddCollumn( 'ALLMD1'	/*cID*/, 32 /*nPercWidth*/, .T. /*lFixed*/, 'MIDDLE'	/*cIDLine*/)
		oFWLayer:AddCollumn( 'ALLMD2'	/*cID*/, 68 /*nPercWidth*/, .T. /*lFixed*/, 'MIDDLE'	/*cIDLine*/)
	
		oPanelUp	:= oFWLayer:GetColPanel( 'ALLUP', 'UP'		)
		oPanelMd1	:= oFWLayer:GetColPanel( 'ALLMD1', 'MIDDLE'	)
		oPanelMd2	:= oFWLayer:GetColPanel( 'ALLMD2', 'MIDDLE'	)
	
	    @ 004,004 GET oGetMemo VAR cErroInt OF oPanelMd1 MULTILINE SIZE 200, 70 COLORS 0, 16777215 HSCROLL PIXEL
		
		
		oDadosBrw := fwBrowse():New()
		oDadosBrw:setDataArray()
		oDadosBrw:setArray( aDados )
		oDadosBrw:disableConfig()
		oDadosBrw:disableReport()
		oDadosBrw:setOwner( oPanelUp )
	
		oDadosBrw:addColumn({"Filial"			, { || aDados[oDadosBrw:nAt,01] }, "C", "@!"	, 1, 10,							, .F.})
		oDadosBrw:addColumn({"Transação"		, { || aDados[oDadosBrw:nAt,02] }, "C", "@!"	, 1, 10,							, .F.})
		oDadosBrw:addColumn({"O.P."			    , { || aDados[oDadosBrw:nAt,03] }, "C", "@!"	, 1, 10,							, .F.})
		oDadosBrw:addColumn({"Produto"			, { || aDados[oDadosBrw:nAt,04] }, "C", "@!"	, 1, 20,							, .F.})
		oDadosBrw:addColumn({"Status"			, { || aDados[oDadosBrw:nAt,05] }, "C", "@!"	, 1, 5,							, .F.})
		oDadosBrw:addColumn({"Recurso"			, { || aDados[oDadosBrw:nAt,06] }, "C", "@!"	, 1, 10,							, .F.})
		oDadosBrw:addColumn({"Data"				, { || aDados[oDadosBrw:nAt,07] }, "D", "@!"	, 1, 10,							, .F.})
		oDadosBrw:addColumn({"Hora"		        , { || aDados[oDadosBrw:nAt,08] }, "C", "@!"	, 1, 10,							, .F.})
		oDadosBrw:addColumn({"Quant."			, { || aDados[oDadosBrw:nAt,09] }, "N", "@E 999,9999.99"    , 1, 10	,							    , .F.})
		oDadosBrw:addColumn({"Operação"			, { || aDados[oDadosBrw:nAt,10] }, "C", "@!"	, 1, 5	,							, .F.})
		oDadosBrw:addColumn({"ID MES"  			, { || aDados[oDadosBrw:nAt,11] }, "C", "@!"	, 1, 20	,							, .F.})
	
			
		aDetalhes := aDados[01,13]
		oDetBrow := fwBrowse():New()
		oDetBrow:setDataArray()
		oDetBrow:setArray(aDetalhes)
		oDetBrow:disableConfig()
		oDetBrow:disableReport()
		oDetBrow:setOwner( oPanelMd2 )  //cCodProd,nQuant,nSaldo,nD4,nD4Saldo
		oDetBrow:addColumn({"Produto"	     , { || aDetalhes[oDetBrow:nAt,01] } , "C", "@!"                 , 1, 10, ,  .F., , .F.,, ,, .F., .T.,, })
		oDetBrow:addColumn({"Descrição"	     , { || aDetalhes[oDetBrow:nAt,02] } , "C", "@!"                 , 1, 23, ,  .F., , .F.,, ,, .F., .T.,, })
		oDetBrow:addColumn({"Qtde Integr."	 , { || aDetalhes[oDetBrow:nAt,03] } , "C", "@!"                 , 1, 08, ,  .F., , .F.,, ,, .F., .T.,, })
		oDetBrow:addColumn({"Saldo Estoque"	 , { || aDetalhes[oDetBrow:nAt,04] } , "N", "@!"                 , 1, 08, ,  .F., , .F.,, ,, .F., .T.,, })
		oDetBrow:addColumn({"Validade"	     , { || aDetalhes[oDetBrow:nAt,05] } , "N", "@!"                 , 1, 08, ,  .F., , .F.,, ,, .F., .T.,, })
		oDetBrow:addColumn({"Saldo Empenho"	 , { || aDetalhes[oDetBrow:nAt,06] } , "N", "@!"                 , 1, 08, ,  .F., , .F.,, ,, .F., .T.,, })
		oDetBrow:addColumn({"Estrutura"	     , { || aDetalhes[oDetBrow:nAt,07] } , "N", "@!"                 , 1, 08, ,  .F., , .F.,, ,, .F., .T.,, })
		oDetBrow:activate( .T. )
		
		oDadosBrw:SetChange({|| Atualiza()} )  
		oDadosBrw:activate( .T. )
	    
	    
	    
		enchoiceBar(oDlgPCP, bOk , bClose,, aButtons)
	ACTIVATE MSDIALOG oDlgPCP CENTER
EndIF
	
Return
**********************************************************************************************************************
Static Function Atualiza

 cErroInt := aDados[oDadosBrw:nAt,12]
 oGetMemo:Refresh() 

aDetalhes := aDados[oDadosBrw:nAt,13] 
oDetBrow:setArray(aDetalhes)
oDetBrow:Refresh()
oDetBrow:goTop()
 

Return
**********************************************************************************************************************
Static Function Proc_Dados()

Local cQuery := ''
Local nQuant        := 0 
Local nSaldo        := 0 
Local nD4           := 0 
Local nEstr         := 0 
Local aTexto        := {} 
LOcal cTexto        := {}
Local nI            := 1
Local cCodProd      := ''
Local cLocal        := ''
Local dDtValid      := ''
Local nSaldoGeral   := 0

aExcel      := {}
cQuery := " SELECT a.R_E_C_N_O_ RECNOOG"
cQuery += " FROM "+ RetSQLname("SOG")+" a,"+ RetSQLname("SOH")+" b"	
cQuery += " WHERE a.D_E_L_E_T_ = ' '  "
cQuery += "   AND b.D_E_L_E_T_ = ' '  "
cQuery += "   AND OG_IDMES = OH_IDMES  "
cQuery += IIF(Empty(MV_PAR01),"","  AND OH_DATA >= '"+DTOS(MV_PAR01)+"' ")
cQuery += IIF(Empty(MV_PAR02),"","  AND OH_DATA <= '"+DTOS(MV_PAR02)+"' ")
cQuery += IIF(MV_PAR03==1,"  AND OH_STATUS = '1' ","")
cQuery += IIF(MV_PAR03==2,"  AND OH_STATUS = '2' ","")
cQuery += IIF(Empty(MV_PAR04),"","  AND OG_OP like '%"+Alltrim(MV_PAR04)+"%' ")
cQuery += IIF(Empty(MV_PAR05),"","  AND OG_PRODUTO like '%"+Alltrim(MV_PAR05)+"%' ")
cQuery += IIF(Empty(MV_PAR06),"","  AND OG_RECURSO = '"+MV_PAR06+"' ")
cQuery += " ORDER BY a.R_E_C_N_O_ desc "

If Select("QRY_SOG") > 0
	QRY_SOG->(dbCloseArea())
EndIf	
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY_SOG",.T.,.T.)
dbSelectArea("QRY_SOG")

QRY_SOG->(dbGoTop())
While QRY_SOG->(!Eof())
	SOG->(dbGoTo(QRY_SOG->RECNOOG))
	IF aScan( aDados, { |x| Alltrim(x[11]) == Alltrim(SOG->OG_IDMES)}) == 0 
		aItens  := {}
		cTexto := SOG->OG_MSGRET
		IF "Itens Sem Saldo" $ cTexto
		    IF "MA240NEGAT" $ cTexto  .OR. "MA240NEGLT" $ cTexto
				AADD(aErros,{SOG->OG_IDMES,SOG->OG_OP,SOG->OG_PRODUTO,SOG->OG_STATUS,SOG->OG_RECURSO,SOG->OG_OPERAC,SOG->OG_DATA,SOG->OG_HORA,"Itens sem Saldo - Erro MA240NEG "})
		    Else		
				AADD(aErros,{SOG->OG_IDMES,SOG->OG_OP,SOG->OG_PRODUTO,SOG->OG_STATUS,SOG->OG_RECURSO,SOG->OG_OPERAC,SOG->OG_DATA,SOG->OG_HORA,"Itens sem Saldo"})
		    EndIF
			aTexto := SEPARA(cTexto,'|')
			IF VALTYPE(aTexto)=='A' .And. Len(aTexto) > 0 
				For nI := 1 To Len(aTexto)
				     cCodProd := Alltrim(SubSTR(aTexto[nI],1,21))
				     IF !Empty(cCodProd)
				          IF SB1->(dbSeek(xFilial('SB1')+cCodProd))
							cLocal   := Alltrim(SubSTR(aTexto[nI],23,03))
				     		nQuant   := Alltrim(SubSTR(aTexto[nI],26,32))
							nSaldo   := 0 
							nD4      := 0 
							dDtValid := CTOD("31/12/2222")
		                     //D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
				            IF SD4->(dbSeek(xFilial('SD4')+SOG->OG_OP+PADR(cCodProd,TamSx3("D4_COD")[1])+cLocal))
				                nD4  := SD4->D4_QUANT
				                IF SG1->(dbSeek(xFilial('SG1')+SD4->D4_PRODUTO+SD4->D4_COD+SD4->D4_TRT))	 
				                	nEstr := SG1->G1_QUANT
				                EndIF
				            EndIF
				             //D14_FILIAL+D14_LOCAL+D14_PRODUT+D14_ENDER+D14_LOTECT+D14_NUMLOT+D14_NUMSER+D14_IDUNIT
				             D14->(dbSeek(xFilial('D14')+cLocal+PADR(cCodProd,TamSx3("D4_COD")[1]))) //+'CPD01          '
				             While D14->(!Eof()) .AND. D14->D14_FILIAL == xFilial('D14') .AND.;
				                  D14->D14_LOCAL   == cLocal .AND.;
				                  D14->D14_PRODUT  == PADR(cCodProd,TamSx3("D4_COD")[1])
				             
				                  nSaldo   += D14->D14_QTDEST
				                  IF D14->D14_DTVALD < dDtValid
				                   	  dDtValid := D14->D14_DTVALD
				                  EndIF
				                  D14->(dbSkip())
				             END   
				             IF dDtValid == CTOD("31/12/2222")
				                 dDtValid := CTOD("  /  /  ")
				             EndIF
				             nSaldoGeral := 0 
							 SB2->(dbSeek(xFilial('SB2')+SB1->B1_COD))
							 While  SB2->(!Eof()) .AND.  SB2->B2_FILIAL == xFilial('SB2') .AND. SB1->B1_COD == SB2->B2_COD
							    IF NNR->(DbSeek(xFilial('NNR')+SB2->B2_LOCAL))
							    	IF NNR->NNR_MRP <> '2'	
							    	    nSaldoGeral += SB2->B2_QATU-SB2->B2_RESERVA
							    	EndIF
							    EndIF
							    SB2->(dbSkip())
							    	
							 End
				             AAdd(aItens,{cCodProd,SB1->B1_DESC,nQuant,nSaldo,dDtValid,nD4,nEstr})
				             AAdd(aExcel,{SOG->OG_IDMES,SOG->OG_OP,SOG->OG_PRODUTO,SOG->OG_DATA,SOG->OG_RECURSO,SOG->OG_OPERAC,cCodProd,SB1->B1_TIPO+'-'+SB1->B1_DESC,nQuant,cLocal,nSaldo,nSaldoGeral,dDtValid,nD4,nEstr})
				          EndIF
				     EndIF 
				Next nI
			EndIF 
		Else
			nPos := AT('| Tabela SH6 ',cTexto)
			IF nPos <> 0 
			    cTexto := SUBSTR(cTexto,1,nPos)
			EndIF
			cTexto := STRTRAN(cTexto,'Reprocessado. ',"")
			AADD(aErros,{SOG->OG_IDMES,SOG->OG_OP,SOG->OG_PRODUTO,SOG->OG_STATUS,SOG->OG_RECURSO,SOG->OG_OPERAC,SOG->OG_DATA,SOG->OG_HORA,Alltrim(cTexto)})
		EndIF
		IF Len(aItens)== 0 
		    AAdd(aItens,{"","",'0',0," ",0,0})
		EndIF
		
		AAdd( aDados, {	SOG->OG_FILIAL																	,;	//[01]
						SOG->OG_TRANSAC																	,;	//[02]
						SOG->OG_OP																	   ,;	//[03]
						SOG->OG_PRODUTO																	,;	//[04]
						SOG->OG_STATUS																	,;	//[05]
						SOG->OG_RECURSO																	,;	//[06]
						SOG->OG_DATA																	,;	//[07]
						SOG->OG_HORA																	,;	//[08]
						SOG->OG_QUANTID																	,;	//[09]
						SOG->OG_OPERAC																	,;	//[10]
						SOG->OG_IDMES																	,;  //[11]
						SOG->OG_MSGRET,aItens} )                                                                	//[12]
	EndIF
	QRY_SOG->(dbSkip())
End

Return
***************************************************************************************************************
Static Function GeraExcel(nTipo,aPlanilha)            
Private aAuxZZ  := {}

aAuxZZ := aClone(aPlanilha) 

Gera_ArqExcel(nTipo,aPlanilha)

IF nTipo == 1
    aExcel := aClone(aAuxZZ)
ElseIF nTipo == 2
    aExcel2 := aClone(aAuxZZ)
ElseIF nTipo == 3
    aErros := aClone(aAuxZZ)
EndIF

Return
**********************************************************************************************************************************
Static Function Gera_ArqExcel(nTipo,aPlanilha)

Local aCabDados   := {}
Local oFWMsExcel 
Local nI          := 0
Local cArquivo    :='c:\temp\'
IF nTipo == 1                                                                                                 //9 11 12 14 15
	aCabDados   := {"IDMES","OP","Produto","Data","Recurso","Operacao","Produto","Descrição","Qtde Integr.","Local OP","Saldo Local","Saldo Estoque","Menor Dt. Validade","Saldo Empenho","Estrutura"}
    cArquivo    +=  "Prod_"+Dtos(dDataBase)+"_"+StrTran(Time(),":","")+'.xml'
ElseIF nTipo == 2
   aCabDados:={"OP","Produto","Recurso","Item","Descrição","Estrutura","Saldo Estoque"}
   cArquivo    +=  "Imp_"+Dtos(dDataBase)+"_"+StrTran(Time(),":","")+'.xml'
ElseIF nTipo == 3
   aCabDados:={"Transação","OP","Produto","Status","Recurso","Operac","data","Hora","Erro"}
   cArquivo    +=  "Erros_"+Dtos(dDataBase)+"_"+StrTran(Time(),":","")+'.xml'
EndIF
/*If !ApOleClient("MSExcel")
	MsgAlert("Microsoft Excel não instalado!")
	Return
EndIf         


MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",{||DlgToExcel({ {"ARRAY", 'Integração MES', aCabDados, aPlanilha} }) })                                          
*/

oFWMsExcel := FWMSExcel():New()
oFWMsExcel:AddworkSheet("Integrações") 
oFWMsExcel:AddTable("Integrações","Registros")
For nI := 1 To Len(aCabDados)
   IF nTipo==1 .AND. (nI ==  9 .OR. nI ==11 .OR. nI ==12 .OR. nI == 14 .OR. nI == 15)
      oFWMsExcel:AddColumn("Integrações","Registros",aCabDados[nI],3,2)
   Else
      oFWMsExcel:AddColumn("Integrações","Registros",aCabDados[nI],1,1) //1 = Modo Texto  2 = Valor sem R$ 3 = Valor com R$
   EndIF
Next nI    
For nI:= 1 To Len(aPlanilha)
	oFWMsExcel:AddRow("Integrações","Registros",aPlanilha[nI])
Next nI

oFWMsExcel:Activate()
oFWMsExcel:GetXMLFile(cArquivo)
oExcel := MsExcel():New()             
oExcel:WorkBooks:Open(cArquivo)     
oExcel:SetVisible(.T.)                 
oExcel:Destroy()        

       
Return
********************************************************************************************************************************
Static Function Imp_Consulta()

Local oDLg
Local bGetDir := {|| cDiretorio := cGetFile ( , "Selecione o arquivo:", 1,, .F., GETF_LOCALHARD )}


Private cDir	    := 'C:\TEMP\'
Private cDiretorio	:= 'C:\TEMP\'
Private cFilInv		:= "Campos.txt"
Private cArquivo   := Space(50)
Private cExt	   := ""
Private cTitulo    := "Altera Campos"
Private nTam       := 15
Private nDec       := 5
Private cPict      := '@E 999,999,999.99999'

cDiretorio := cDiretorio + Space(100-Len(cDiretorio))

Define MSDialog oDlg Title cTitulo From 0,0 TO 05,84 Of oMainWnd
	@ 0.2,1	 Say "Arquivo:"
	@ 0.2,7	 MSGet cDiretorio SIZE 200,8 Picture "@!"  Valid (Vazio() .OR. IIF(!File(AllTrim(cDiretorio)),(MsgStop("Arquivo Inválido!"),.F.),.T.)) When .F. Of oDlg
	@ 2,250   BUTTON "..."             SIZE 12,12 ACTION (Eval(bGetDir))                  Pixel OF oDlg
//	@ 22,98   BUTTON "Consultar Saldo" SIZE 60,12 ACTION (AtuSaldo())                    Pixel OF oDlg
	@ 22,160  BUTTON "Importar OP"     SIZE 60,12 ACTION (Atu_dados())                    Pixel OF oDlg
	@ 2,265   BUTTON "Sair"             SIZE 60,12 ACTION (oDlg:End())    				  Pixel OF oDlg

Activate MSDialog oDlg Centered
	
Return
************************************************************************************************************
Static Function Atu_dados
Local cLinha       := ''
//Local cArqRet      := ''
Local aDados2	   := {} 
//Local nCont1       := 0 
Local nEstr       := 0 
//Local cOP         

cDiretorio := Alltrim(cDiretorio)

SG1->(dbSetOrder(1))
Ft_FUse(cDiretorio)
While !FT_FEof() 
	cLinha := FT_FReadLn()
	IF Empty(cLinha)
	     FT_FSkip()
	     Loop
	EndIf
	aDados2	:= Separa(cLinha,";",.T.)
		SD4->(dbSeek(xFilial('SD4')+aDados2[1]))
		While SD4->(!Eof()) .AND. Alltrim(SD4->D4_OP) == Alltrim(aDados2[1])
           IF SG1->(dbSeek(xFilial('SG1')+SD4->D4_PRODUTO+SD4->D4_COD+SD4->D4_TRT))	 
			   nEstr  := SG1->G1_QUANT
			   nSaldo := 0 
			   IF D14->(dbSeek(xFilial('D14')+SD4->D4_LOCAL+SD4->D4_COD+'CPD01          '))
			       nSaldo   := D14->D14_QTDEST
			   ENDIF   
			   SB1->(dbSeek(xFilial('SB1')+SD4->D4_COD))
			   AAdd(aExcel2,{aDados2[1],aDados2[2],aDados2[3],SD4->D4_COD,SB1->B1_DESC,nEstr,nSaldo})
		    EndIF
			SD4->(dbSkip())    
	    End
	FT_FSkip()
End
GeraExcel(2, aExcel2)
Return
************************************************************************************************************
/*
Static Function AtuSaldo
Local cLinha       := ''
Local cArqRet      := ''
Local aDados2	   := {} 
Local nCont1       := 0 
Local nEstr       := 0 
Local cOP         

cDiretorio := Alltrim(cDiretorio)

SG1->(dbSetOrder(1))
Ft_FUse(cDiretorio)
While !FT_FEof() 
	cLinha := FT_FReadLn()
	IF Empty(cLinha)
	     FT_FSkip()
	     Loop
	EndIf
	aDados2	:= Separa(cLinha,";",.T.)
	SB1->(dbSeek(xFilial('SB1')+aDados2[1]))

	While SD4->(!Eof()) .AND. Alltrim(SD4->D4_OP) == Alltrim(aDados2[1])
       IF SG1->(dbSeek(xFilial('SG1')+SD4->D4_PRODUTO+SD4->D4_COD+SD4->D4_TRT))	 
		   nEstr  := SG1->G1_QUANT
		   nSaldo := 0 
		   IF D14->(dbSeek(xFilial('D14')+SD4->D4_LOCAL+SD4->D4_COD+'CPD01          '))
		       nSaldo   := D14->D14_QTDEST
		   ENDIF   
		   SB1->(dbSeek(xFilial('SB1')+SD4->D4_COD))
		   AAdd(aExcel2,{aDados2[1],aDados2[2],aDados2[3],SD4->D4_COD,SB1->B1_DESC,nEstr,nSaldo})
	    EndIF
		SD4->(dbSkip())    
    End
    FT_FSkip()
End
GeraExcel(2, aExcel2)
Return
************************************************************************************************************
/*
