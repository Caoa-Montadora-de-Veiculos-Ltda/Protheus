#Include "Protheus.Ch"
#Include "Totvs.Ch"
#include 'parmtype.ch'
#include "TBICONN.CH"
#include 'TOPCONN.CH'

#Define CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} ZMNTR004.PRW
Relatório Arvore Logica - CAOA
@author  CAOA - A. Carlos
@since   14/09/23
@version 1.0
@type function
/*/

User Function ZMNTR004()

    Local oReport, oSection
    Private cPerg     := PadR ("ZMNTR004", Len (SX1->X1_GRUPO))
    Private cAliasTRB := GetNextAlias()
	Private cCodBemPai:= ""
	Private cLocaliz  := ""
	Private cNomeCC   := ""

    CriaSX1()

    oReport:= TReport():New("ZMNTR004",;
                            "Arvore Logica",;
                            cPerg,;
                            {|oReport|  ReportPrint(oReport)},;
                            "Este relatorio efetua a impressão Arvore Logica")
	//oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
    //oReport:HideHeader(.T.)      //--Define que não será impresso o cabeçalho padrão da página
    //oReport:HideFooter()      //--Define que não será impresso o rodapé padrão da página
    //oReport:SetDevice(4)      //--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    //oReport:SetPreview(.T.)   //--Define se será apresentada a visualização do relatório antes da impressão física
    //oReport:SetEnvironment(2) //--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
 	//oReport:SetLandscape()

	oReport:SetPortrait()    
	oReport:SetTotalInLine(.F.)

	//Verifica os parâmetros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.F.)
	
	oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTRB}) 

    TRCell():New( oSection  ,cLocaliz          ,cAliasTRB  ,"Localização"	          )  
    TRCell():New( oSection  ,"T9_CODBEM"       ,cAliasTRB  ,"Código"	              )  
    TRCell():New( oSection  ,"T9_NOME"         ,cAliasTRB  ,"Nome do BEM"	          )       
    TRCell():New( oSection  ,cCodBemPai        ,cAliasTRB  ,"Pai"	    	          )
    TRCell():New( oSection  ,"T9_PRIORID"      ,cAliasTRB  ,"Prioridade"	          )
    TRCell():New( oSection  ,"T9_CCUSTO"       ,cAliasTRB  ,"Centro Custo"            )
	TRCell():New( oSection  ,cNomeCC           ,cAliasTRB  ,"Descrição"	              )
        
    oReport:PrintDialog()

Return()


//----------------------------------------------------------
Static Function  ReportPrint(oReport)
    Local oSection     := oReport:Section(1)

    //Monta Tmp
    TmpDados()

	oReport:SetMeter( Contar(cAliasTRB,"!Eof()") )
	// Secção 1
	oSection:Init()

    DbSelectArea((cAliasTRB))
    (cAliasTRB)->(dbGoTop())
    While (cAliasTRB)->(!EoF()) .And. !oReport:Cancel()

	// Tratamento para buscar a Localização - BEM/LOCALIZAÇÃO
	
	cLocaliz := NGLocComp((cAliasTRB)->T9_CODBEM,'1') //Bem Localização


	//If AllTrim( cLocaliz ) == AllTrim( (cAliasTRB)->T9_CODBEM ) // NÃO cadastrado na arvore
		cCodBemPai := NGBEMPAI((cAliasTRB)->T9_CODBEM)
		if Empty(cCodBemPai) .AND. Empty(cLocaliz)  
			cLocaliz := "Localização não cadastrada"
		Else
			cLocaliz := "Bem Pai:" + POSICIONE("STZ",1,xFilial("STZ")+cCodBemPai,"TZ_BEMPAI")    //NGLocComp(AllTrim(cCodBemPai),'1') //Estrutura de Bem pai
		EndIf
	//EndIf

	    cNomeCC := POSICIONE("SI3",1,xFilial("SI3")+(cAliasTRB)->T9_CCUSTO,"I3_DESC")
                     
		// Incrementa a mensagem na régua.
		oReport:IncMeter()
		
		oSection:Cell( 01 ):SetValue(            cLocaliz                         )    
		oSection:Cell( 02 ):SetValue(           (cAliasTRB)->T9_CODBEM            )    
		oSection:Cell( 03 ):SetValue(           (cAliasTRB)->T9_NOME              )    
		oSection:Cell( 04 ):SetValue(           cCodBemPai                        )   
		oSection:Cell( 05 ):SetValue(  Alltrim( (cAliasTRB)->T9_PRIORID  )        ) 
		oSection:Cell( 06 ):SetValue(  Alltrim( (cAliasTRB)->T9_CCUSTO   )        )
		oSection:Cell( 07 ):SetValue(            Alltrim(cNomeCC)                 )


		oSection:PrintLine()	
    
	    (cAliasTRB)->(dbSkip() )
	
	EndDo               
	oSection:Finish()	           

Return()


Static Function TmpDados()
    Local cQuery := ""

	If Select( cAliasTRB ) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf

    cQuery := " "
	cQuery += " SELECT T9_CODBEM,T9_NOME,T9_PRIORID,T9_CCUSTO,T9_DESCRIC,T9_LOCAL FROM " + RetSqlName("ST9") + " ST9 "		+ CRLF
	cQuery += "     WHERE T9_CODBEM BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "	                        	        + CRLF
	cQuery += " ORDER BY T9_CODBEM	"                                                                                       + CRLF
    cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

Return()


/*/{Protheus.doc} CriaSx1
//TODO Cria grupo de perguntas, caso não exista.
@author 	A. Carlos
@since 		15/09/2023
@version 	P12
@type 		function
/*/
Static Function CriaSx1()

	Local aAreaAnt 	:= GetArea()
	Local aAreaSX1 	:= SX1->(GetArea())
	Local nY 		:= 0
	Local nJ 		:= 0
	Local aReg 		:= {}

	aAdd(aReg,{cPerg,"01","Bem De         ","mv_ch1","C", 17,0,0,"G","","mv_par01","","","","","","","","","","","","","","","ST9","","","",""})
	aAdd(aReg,{cPerg,"02","Bem Até        ","mv_ch2","C", 17,0,0,"G","","mv_par02","","ZZZZZZZZZ","","","","","","","","","","","","","ST9","","","",""})	
	//aAdd(aReg,{cPerg,"01","Localizacao De ","mv_ch1","D", 08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	//aAdd(aReg,{cPerg,"02","Localizacao Até","mv_ch2","D", 08,0,0,"G","(mv_par02>=mv_par01)","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aReg,{"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_CNT01","X1_VAR02","X1_DEF02","X1_CNT02","X1_VAR03","X1_DEF03","X1_CNT03","X1_VAR04","X1_DEF04","X1_CNT04","X1_VAR05","X1_DEF05","X1_CNT05","X1_F3","X1_PYME","X1_GRPSXG","X1_HELP","X1_PICTURE"})
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	For ny := 1 To Len(aReg) - 1
		If !DbSeek( PadR( aReg[ny,1], 10) + aReg[ny,2])
			RecLock("SX1", .T.)
			For nJ := 1 To Len(aReg[ny])
				FieldPut( FieldPos( aReg[Len( aReg)][nJ] ), aReg[ny,nJ] )
			Next nJ
			MsUnlock()
		EndIf
	Next ny	
	
	RestArea(aAreaSX1)
	RestArea(aAreaAnt)

Return
