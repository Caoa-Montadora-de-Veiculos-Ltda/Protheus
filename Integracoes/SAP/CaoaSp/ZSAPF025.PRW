#include "totvs.ch"
#include "rwmake.ch"
#include "Protheus.ch"

/*
=========================================================================================================
Programa.................: ZSAPF025
Autor:...................: Totvs
Data.....................: Mar/20
Descrição / Objetivo.....: Rotina de reprocessamento do SAP, a partir dos movimentos de origem
Doc. Origem..............: 
Solicitante..............: Cliente
Uso......................: Caoa
Obs......................: 
=========================================================================================================
*/
User Function ZSAPF025()

Local aArea := {GetArea()}
Local cAliasTrb := GetNextAlias()
Local cQ := ""
local cPass := Space(50)
Local aRetParam := {}
Local cSerie := Space(tamSx3("F1_SERIE")[1])
Local cDoc := Space(tamSx3("F1_DOC")[1])
Local cFornece := Space(tamSx3("F1_FORNECE")[1])
Local cLoja := Space(tamSx3("F1_LOJA")[1])
Local lRet := .F.
Local cRoot := GetSrvProfString( "RootPath" , "" )
Local cDir := "\REINTEGRA_SAP\"
Local cLog := ""
Local aParamBox := {}
Local aTabParam := {"Contas a Pagar"}
Local cTab := ""
Local lSE2 := .F.
Local cOrigRet := GetMv("CAOAORRETP",,"650-222/650-223/650-224/650-225")
Local cSD1 := ""
Local cSeq := ""
Local aTab := {}
Local cChave := ""
Local cQSZ7 := ""

@ 067,020 To 169,312 Dialog oDlg Title OemToAnsi("Liberação de Acesso")
@ 015,005 Say OemToAnsi("Informe a senha para o acesso ?") Size 80,8
@ 015,089 Get cPass Size 50,10 Password
@ 037,055 BmpButton Type 1 Action fOK(oDlg,@lRet,cPass)
@ 037,106 BmpButton Type 2 Action (lRet:=.F.,Close(oDlg))
Activate Dialog oDlg CENTERED

If !lRet
	Return()
Endif

lRet := .F.

AAdd(aParamBox	, {1, "Numero Nota",cDoc,"@!",,"SD1",,070,.T.})
AAdd(aParamBox	, {1, "Serie Nota:",cSerie,"@!",,"",, 070,.F.})
AAdd(aParamBox	, {1, "Fornecedor:",cFornece,"@!",,"SA2",, 070,.T.})
AAdd(aParamBox	, {1, "Loja",cLoja,"@!",,"",,070,.T.})
AAdd(aParamBox	, {2, "Tipo de Integração",1,aTabParam,070,,.T.})

If ParamBox(aParambox,"Gerar integração Contas a Pagar - SAP", @aRetParam, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .F. /*lUserSave*/)
	
	If !APMsgYesNo("Deseja realmente executar a reintegração deste documento ?")
		Return()
	Endif

	cDoc := aRetParam[1]
	cSerie := aRetParam[2]
	cFornece := aRetParam[3]
	cLoja := aRetParam[4]
	cTab := aTabParam[aRetParam[5]]

	cLog := "Reintegra_SAP_"+Alltrim(cSerie)+"_"+Alltrim(cDoc)+"_"+dTos(dDataBase)+"_"+StrTran(Time(),":","")+".txt"

	If !ExistDir(cRoot+cDir)
		If !MakeDir(cRoot+cDir) == 0
			Help( ,, "Help",, "Não foi criar diretório de LOG: "+cRoot+cDir, 1, 0 )
			
			Return()
		EndIf
	EndIf

	If cTab == "Contas a Pagar"
		cTab := "SF1"
		SetFunName("MATA103")
		SF1->(dbSetOrder(1))
		If SF1->(dbSeek(xFilial("SF1")+cDoc+cSerie+cFornece+cLoja))
			SD1->(dbSetOrder(1))
			If SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				While SD1->(!Eof()) .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == ;
				SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
					cSD1 := cSD1+Alltrim(Str(SD1->(Recno())))+"/"
					SD1->(dbSkip())
				Enddo
				cSD1 := Subs(cSD1,1,Len(cSD1)-1)
				// reposiciona no 1 registro
				SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
			Endif

			// necessario posicionar antes na ct2, pois a funcao OperIntSAP, que vai retornar a tabela e chave
			// de pesquisa da sz7, precisa estar com a ct2 posicionada
			cQ := " SELECT MAX(CT2_SEQUEN) CT2_SEQUEN "
			cQ += " FROM " + RetSqlName("CT2") + " CT2 " + CRLF
			cQ += " INNER JOIN " + RetSqlName("CV3") + " CV3 " + CRLF
			cQ += " ON TRIM(CV3.CV3_RECDES) = TRIM(CT2.R_E_C_N_O_) "
			cQ += " AND CV3.D_E_L_E_T_ <> '*' "
			cQ += " AND CT2.D_E_L_E_T_ <> '*' " + CRLF
			cQ += " WHERE " + CRLF
			If !lSE2
				//If !lDev
					cQ += " CV3.CV3_RECORI IN "+FormatIn(cSD1,"/")+" "
					cQ += " AND CV3.CV3_TABORI = 'SD1' "
					cQ += " AND CT2.CT2_TPSALD = '1' "
					cQ += " AND CT2_LP = '650' "
				/*
				Else
					cQ += " CV3.CV3_RECORI IN "+FormatIn(cSD2,"/")+" "
					cQ += " AND CV3.CV3_TABORI = 'SD2' "
					cQ += " AND CT2.CT2_TPSALD = '1' "
					cQ += " AND CT2_LP = '610' "
				Endif
				*/
			Else
				cQ += " CV3.CV3_RECORI = '"+Alltrim(Str(SE2->(Recno())))+"' "
				cQ += " AND CV3.CV3_TABORI = 'SE2' "
				cQ += " AND CT2.CT2_TPSALD = '1' "
				cQ += " AND CT2_LP IN ('510','511') "
			Endif
			If !lSE2
				cQ += " AND SUBSTR(CT2_ORIGEM,1,7) NOT IN "+FormatIn(cOrigRet,"/")+" "
			Endif
				
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
				
			If !(cAliasTrb)->(EOF()) .and. !Empty((cAliasTrb)->CT2_SEQUEN)
				cSeq := (cAliasTrb)->CT2_SEQUEN
			Endif
				
			(cAliasTrb)->(dbCloseArea())

			If !Empty(cSeq)
				cQ := " SELECT CT2.R_E_C_N_O_ CT2_RECNO " + CRLF
				cQ += " FROM " + RetSqlName("CT2") + " CT2 " + CRLF
				cQ += " INNER JOIN " + RetSqlName("CV3") + " CV3 " + CRLF
				cQ += " ON TRIM(CV3.CV3_RECDES) = TRIM(CT2.R_E_C_N_O_) "
				cQ += " AND CV3.D_E_L_E_T_ <> '*' "
				cQ += " AND CT2.D_E_L_E_T_ <> '*' " + CRLF
				cQ += " WHERE " + CRLF
				If !lSE2
					//If !lDev
						cQ += " CV3.CV3_RECORI IN "+FormatIn(cSD1,"/")+" "
						cQ += " AND CV3.CV3_TABORI = 'SD1' "
						cQ += " AND CT2.CT2_TPSALD = '1' "
						cQ += " AND CT2_LP = '650' "
					/*Else
						cQ += " CV3.CV3_RECORI IN "+FormatIn(cSD2,"/")+" "
						cQ += " AND CV3.CV3_TABORI = 'SD2' "
						cQ += " AND CT2.CT2_TPSALD = '1' "
						cQ += " AND CT2_LP = '610' "
					Endif
					*/
				Else
					cQ += " CV3.CV3_RECORI = '"+Alltrim(Str(SE2->(Recno())))+"' "
					cQ += " AND CV3.CV3_TABORI = 'SE2' "
					cQ += " AND CT2.CT2_TPSALD = '1' "
					cQ += " AND CT2_LP IN ('510','511') "
				Endif
				cQ += " AND CT2_SEQUEN = '"+cSeq+"' "
				If !lSE2
					cQ += " AND SUBSTR(CT2_ORIGEM,1,7) NOT IN "+FormatIn(cOrigRet,"/")+" "
				Endif
					
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
					
				If (cAliasTrb)->(!Eof())
					CT2->(dbGoto((cAliasTrb)->CT2_RECNO))
					If CT2->(Recno()) == (cAliasTrb)->CT2_RECNO
						SAP25Oper(@lRet,@aTab,@cChave,@cQSZ7)
						If lRet	
							SAP25Ger(@lRet,aTab,cChave,cQSZ7,cTab,cRoot,cDir,cLog)
						Endif	
					Endif	
				Endif	

				(cAliasTrb)->(dbCloseArea())
			Else
				Help( ,, "Help",, "Não foi possível encontrar a contabilização do documento.", 1, 0 )	
			Endif	
		Else
			Help( ,, "Help",, "Documento não encontrado na base de dados. Verifique os parâmetros.", 1, 0 )	
		Endif	
	Endif	
Endif	

aEval(aArea,{|x| RestArea(x)})

Return()


Static Function fOK(oDlg,lRet,cPass)

local cPassRot := GetMv("CAOASAP251",,"SAP")

If ALLTRIM(cPass) <> cPassRot
	Help( ,, "Help",, "Senha não confere com a do parâmetro 'CAOASAP251'.", 1, 0 )
   	cPass := Space(50)
   	lRet := .F.
   	dlgRefresh(oDlg)
Else
   	Close(oDlg)
   	lRet := .T.
Endif

Return()


// carrega a tabela correta a ser gerada no SZ7
Static Function SAP25Oper(lRet,aTab,cChave,cQSZ7)

Local aArea := {GetArea()}
Local cAliasTrb := GetNextAlias()
Local aRet := {}

aRet := U_ZF05GENSAP(3)
aTab := aClone(aRet[1])
cChave := aRet[2]

If !Empty(aTab) .and. !Empty(cChave)
	// verifica se a ultima ocorrencia na sz7 nao eh de envio pendente
	cQSZ7 := "SELECT MAX(R_E_C_N_O_) SZ7_RECNO "
	cQSZ7 += "FROM "+RetSqlName("SZ7")+" SZ7 "
	cQSZ7 += "WHERE "
	cQSZ7 += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
	cQSZ7 += "AND Z7_XTABELA = '"+aTab[1]+"' "
	cQSZ7 += "AND Z7_XCHAVE = '"+cChave+"' "
	cQSZ7 += "AND SZ7.D_E_L_E_T_ = ' ' "
											
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQSZ7),cAliasTrb,.T.,.T.)
											
	If (cAliasTrb)->(!Eof()) .and. !Empty((cAliasTrb)->SZ7_RECNO)
		SZ7->(dbGoto((cAliasTrb)->SZ7_RECNO))
		If SZ7->(Recno()) == (cAliasTrb)->SZ7_RECNO
			If !SZ7->Z7_XOPEPRO == 1
				lRet := .T.
			Else	
				Help( ,, "Help",, "Integração deste documento não é necessária. Último lote de integração deste documento: "+SZ7->Z7_XLOTE, 1, 0 )
			Endif
		Endif
	Else
		lRet := .T.
	Endif
	(cAliasTrb)->(dbCloseArea())
Else
	Help( ,, "Help",, "Não foi possível encontrar a Tabela/Chave de integração. Função 'OperIntSAP'.", 1, 0 )	
Endif	

aEval(aArea,{|x| RestArea(x)})

Return()


// gera a integraçao
Static Function SAP25Ger(lRet,aTab,cChave,cQSZ7,cTab,cRoot,cDir,cLog)

Local aArea := {GetArea()}
Local cAliasTrb := GetNextAlias()
Local aDadosOri := {}

If cTab == "SF1"
	// sf1 deve estar posicionada
	aDadosOri := {"MATA103",SF1->F1_DOC,SF1->F1_SERIE,SF1->(Recno()),"",0,SF1->F1_TIPO,,SF1->F1_FORNECE,SF1->F1_LOJA}
Endif	

U_ZF11GENSAP(xFilial("SZ7"),; //Filial
aTab[1]		,;	//Tabela
"1"			,;	//Indice Utilizado
cChave		,;	//Chave
1			,;	//Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
1			,;	//Operação SAP 1=Inclusao;2=cancelamento
,;
,;
,;
aDadosOri)

// verifica se gerou a integracao
// utiliza mesma query da consulta anterior a sz7
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQSZ7),cAliasTrb,.T.,.T.)
														
If (cAliasTrb)->(!Eof()) .and. !Empty((cAliasTrb)->SZ7_RECNO)
	SZ7->(dbGoto((cAliasTrb)->SZ7_RECNO))
	If SZ7->(Recno()) == (cAliasTrb)->SZ7_RECNO
		If SZ7->Z7_XOPEPRO == 1
			MemoWrite(cRoot+cDir+cLog,"Lote SZ7: "+SZ7->Z7_XLOTE+"	"+"Chave SZ7: "+SZ7->Z7_XCHAVE)
			Help( ,, "Help",, "Integração gerada com sucesso. Lote: "+SZ7->Z7_XLOTE, 1, 0 )
		Else
			lRet := .F.
			Help( ,, "Help",, "Houve algum problema na geração da integração. Função: 'xC99IEN'.", 1, 0 )
		Endif	
	Endif	
Else	
	lRet := .F.
	 Help( ,, "Help",, "Houve algum problema na geração da integração. Função: 'xC99IEN'.", 1, 0 )
Endif	 

(cAliasTrb)->(dbCloseArea())			
	
aEval(aArea,{|x| RestArea(x)})

Return()
