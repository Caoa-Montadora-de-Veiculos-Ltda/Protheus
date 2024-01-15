#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'

/*
==============================================================================================================================
Programa............: CMVINT99
Autor...............: Joni Lima
Data................:
Descricao / Objetivo: Rotina para Monitoramento de Envios de Integração SAP
Doc. Origem.........: Rotina onde podemos verificar a tabela de Integração de envio para o SAP
Solicitante.........: Cliente
Uso.................: CAOA
==============================================================================================================================
*/
user function CMVINT99()

    Local aStruSZ7	:= {} //Estrutura da tabela de Aprovacao SZ7
    Local cTmp		:= GetNextAlias()
    Local cAliasTmp
    Local aColumns	:= {}

    Local aFieFilter	:= {}
    Local aFldSeek		:= {}
    Local aSeek			:= {}
    Local nX
	Local nI
	Local aBrw := {}

	Private aRetParam := {}
    Private aParamBox := {}
    Private oBrowse
    Private cInsert
    Private cCampos	:= "" //Pega campos que serao de contexto Real
    private cQry	:= ""
    Private cDelete := ""
    Private cTable  := ""
Private oMark

    aAdd(aParamBox,{1 ,"Filial de:",Space(TamSX3("Z7_FILIAL")[1]),"","","SM0","",50,.F.})
    aAdd(aParamBox,{1 ,"Filial ate:",Space(TamSX3("Z7_FILIAL")[1]),"","","SM0","",50,.T.})
    aAdd(aParamBox,{2 ,"Operacao:",6,{"1=Cad. Fornecedor","2=Cad. Clientes","3=Contas a Pagar","4=Contas a Receber","5=Lanc. Contabil","6=Todos"},80,"",.F.})
    aAdd(aParamBox,{1 ,"Data Inclusao de:",cTod(""),"","","","",50,.F.})
    aAdd(aParamBox,{1 ,"Data Inclusao ate:",cTod(""),"","","","",50,.T.})
    aAdd(aParamBox,{1 ,"Data Envio de:",cTod(""),"","","","",50,.F.})
    aAdd(aParamBox,{1 ,"Data Envio ate:",cTod(""),"","","","",50,.F.})
    aAdd(aParamBox,{1 ,"Data Retorno de:",cTod(""),"","","","",50,.F.})
    aAdd(aParamBox,{1 ,"Data Retorno ate:",cTod(""),"","","","",50,.F.})

    //If Pergunte("CMVINT099",.T.)
    If ParamBox(aParamBox,"Parâmetros Monitor de Integração SAP",@aRetParam)

        aStruSZ7	:= SZ7->(DBSTRUCT()) //Estrutura da tabela de LOG de Integração SZ7
        cCampos		:= getCposSx3( "SZ7" , .F. ) //Pega campos que serao de contexto Real

        cQry 		:= xQryDads(cCampos)//Query para selecionar os dados

        aIndices	:= xIndQry("SZ7") //Indices para montagem do pesquisar
        cFieldBrw   := getCposSx3( "SZ7" , .T. ) + " , Z7_FILIAL" //campo que serao apresentados no browse

        aAdd(aStruSZ7, {'RECSZ7','N',10,0})

        //Instancio o objeto que vai criar a tabela temporaria no BD para poder utilizar posteriormente
        oTmp := FWTemporaryTable():New( cTmp )

        //Defino os campos da tabela temporaria
        oTmp:SetFields(aStruSZ7)

        //Adiciono o indice da tabela temporaria
        For nX := 1 To Len(aIndices)

            aChave	:= StrToKarr(Alltrim(aindices[nX,2]),"+")
            cTmpIdx := "Tmp_Idx_" + StrZero(nX,2)

            oTmp:AddIndex(cTmpIdx,aChave)

            aFldSeek	:= {}

            For nI := 1 to Len(aChave)
                nPosFld  := aScan( aStruSZ7, { |x| Alltrim(x[1]) == aChave[nI] })
                AADD(aFldSeek,{"",aStruSZ7[ni,2],aStruSZ7[ni,3],aStruSZ7[ni,4],PesqPict("SZ7",aStruSZ7[ni,1])})
            Next nI

            //Campos que irao compor o combo de pesquisa na tela principal
            Aadd(aSeek,{aIndices[nX,3],aFldSeek,nX, .T.})

        Next nX

        //Criacao da tabela temporaria no BD
        oTmp:Create()

        //Obtenho o nome "verdadeiro" da tabela no BD (criada como temporaria)
        cTable := oTmp:GetRealName()

        //Preparo o comando para alimentar a tabela temporaria
        cInsert := "INSERT INTO " + cTable + " (" + cCampos + " RECSZ7 ) " + cQry

        //Preparo o comando para deletar a tabela temporaria
        cDelete := "DELETE FROM " + cTable

        //Executo o comando para alimentar a tabela temporaria
        Processa({|| TcSQLExec(cInsert)})

        //Campos que irao compor a tela de filtro
        For nI := 1 to Len(aStruSZ7)
            If aStruSZ7[nI,1] $ cCampos
                Aadd(aFieFilter,{aStruSZ7[nI,1],RetTitle(aStruSZ7[nI,1]), aStruSZ7[nI,2], aStruSZ7[nI,3] , aStruSZ7[nI,4],PesqPict("SZ7",aStruSZ7[ni,1])})
            Endif
		Next nI

		// array para tratar a ordenacao dos campos no browse, pois o array astrusz7 nao eh ordenado pelo campo x3_ordem
		aBrw := aClone(aStruSZ7)
		For nX := 1 To Len(aBrw)
			//aAdd(aBrw[nX],X3Ordem(aBrw[nX][1]))
			aAdd(aBrw[nX],GetSX3Cache(aBrw[nX][1],"X3_ORDEM"))
		Next
		aBrw := aSort(aBrw,,,{|x,y| x[5] < y[5]}) // ordena pelo x3_ordem

        //Browse
        For nX := 1 To Len(aBrw)
            If	aBrw[nX][1] $ cFieldBrw
                AAdd(aColumns,FWBrwColumn():New())

                aColumns[Len(aColumns)]:SetData( &("{||"+aBrw[nX][1]+"}") )
                aColumns[Len(aColumns)]:SetTitle(RetTitle(aBrw[nX][1]))
                aColumns[Len(aColumns)]:SetPicture(PesqPict("SZ7",aBrw[nX][1]))
                aColumns[Len(aColumns)]:SetSize(aBrw[nX][3])
                aColumns[Len(aColumns)]:SetDecimal(aBrw[nX][4])

                If !Empty(GetSX3Cache(aBrw[nX][1], "X3_CBOX"))
                    aColumns[Len(aColumns)]:SetOptions(xRetCombX3(aBrw[nX][1]))
                EndIf

            EndIf
        Next nX

        cAliasTmp := oTmp:GetAlias()

        //oBrowse:= FWMBrowse():New()
        oBrowse:= FWMarkBrowse():New()
        oBrowse:SetAlias( cAliasTmp )
oBrowse:SetSemaphore(.T.)
        oBrowse:SetDescription( 'Log de Integração de Envio SAP' )
//oBrowse:SetFieldMark( 'Z7_OK' )
        //oBrowse:SetAllMark( { || oBrowse:AllMark() } )
		oBrowse:AddMarkColumns({|| If(Empty((cAliasTmp)->Z7_OK), 'LBNO', 'LBOK') }, {|| ZDupColClick() } , {||CMVMARC(oBrowse:Mark(),lMarcar := !lMarcar )})     
        //oBrowse:bAllMark := { || FwMsgRun(,{ ||CMVMARC(oBrowse:Mark(),_lMarcar := !_lMarcar )}, "Aguarde...", "Processando atualizando registros ..."), _oBrowse:Refresh(.T.)  }	
        oBrowse:SetSeek(.T.,aSeek)
        oBrowse:SetTemporary(.T.)
        oBrowse:SetLocate()
        oBrowse:SetUseFilter(.T.)
        oBrowse:SetDBFFilter(.T.)
        oBrowse:SetFilterDefault( "" ) //Exemplo de como inserir um filtro padrao >>> "TR_ST == 'A'"
        oBrowse:SetFieldFilter(aFieFilter)
        oBrowse:DisableDetails()

        // Definicao da legenda
        oBrowse:AddLegend( "Z7_XSTATUS=='P'", "BR_AMARELO"  , "Envio Pendente" 				)
        oBrowse:AddLegend( "Z7_XSTATUS=='A'", "BR_AZUL"   	, "Aguardando Retorno SAP"     	)
        oBrowse:AddLegend( "Z7_XSTATUS=='O'", "ENABLE"    	, "Processado com Sucesso"     	)
        oBrowse:AddLegend( "Z7_XSTATUS=='E'", "DISABLE"  	, "Erro"   	 					)
        oBrowse:AddLegend( "Z7_XSTATUS=='N'", "GRAY"  		, "Nao Sera Enviado"  			)
        oBrowse:AddLegend( "Z7_XSTATUS=='M'", "PINK"	    , "Acerto Manual"    			)

        oBrowse:SetColumns(aColumns)

        oBrowse:Activate()

        oTmp:Delete()

    EndIf

return

Static Function xRetCombX3(cCampo)

    Local aRet := {}
    Local aRetX3 := RetSX3Box(GetSX3Cache(cCampo, "X3_CBOX"),,,1)

    local ni

    For ni := 1 to Len(aRetX3)
        AADD(aRet,aRetX3[ni][1])
    Next ni

return aRet

Static Function xIndQry(cxAlias)

    Local aRet := {}
    Local cNextAlias := GetNextAlias()

    BeginSql Alias cNextAlias

        SELECT
        ORDEM,
        CHAVE,
        DESCRICAO
        FROM SIX010 IX
        WHERE
        IX.%NotDel%
        AND IX.INDICE = %Exp:cxAlias%
        ORDER BY ORDEM

    EndSql

    While (cNextAlias)->(!EOF())
        AADD(aRet,{(cNextAlias)->ORDEM,(cNextAlias)->CHAVE,(cNextAlias)->DESCRICAO})
        (cNextAlias)->(dbSkip())
    EndDo

    (cNextAlias)->(DbClosearea())

return aRet

Static Function xQryDads(cCampos)

    Local cQry := ""

    cQry := "SELECT " + cCampos
    cQry +=  " R_E_C_N_O_ RECSZ7 "
    cQry +=  " FROM "+	RetSqlName("SZ7") + " SZ7 "
    cQry +=  " WHERE "
    cQry +=  " 	SZ7.D_E_L_E_T_ = ' ' "

    If !Empty(mv_par02) //Filial, mv_par01|mv_par02
        cQry +=  " AND SZ7.Z7_FILIAL BETWEEN '" + mv_par01 + "' AND '" + mv_par02  + "'"
    EndIf

    //If !Empty(mv_par04) //Tabela, mv_par03|mv_par04
    //	cQry +=  " AND SZ7.Z7_XTABELA BETWEEN '" + mv_par03 + "' AND '" + mv_par04  + "'"
    //EndIf
    If cValToChar(mv_par03) != "6"  //Tabela, mv_par03|mv_par04
        cQry +=  " AND SZ7.Z7_OPERACA = '" +cValToChar(mv_par03)+ "' "
    EndIf

    //If !Empty(mv_par06) //Dt Inclusao, mv_par05|mv_par06
    //	cQry +=  " AND SZ7.Z7_XDTINC BETWEEN '" + DtoS(mv_par05) + "' AND '" + DtoS(mv_par06)  + "'"
    //EndIf
    If !Empty(mv_par05) //Dt Inclusao, mv_par05|mv_par06
        cQry +=  " AND SZ7.Z7_XDTINC BETWEEN '" + DtoS(mv_par04) + "' AND '" + DtoS(mv_par05)  + "'"
    EndIf

    //If !Empty(mv_par08) //Dt Envio, mv_par07|mv_par08
    //	cQry +=  " AND SZ7.Z7_XDTENV BETWEEN '" + DtoS(mv_par07) + "' AND '" + DtoS(mv_par08)  + "'"
    //EndIf
    If !Empty(mv_par07) //Dt Envio, mv_par07|mv_par08
        cQry +=  " AND SZ7.Z7_XDTENV BETWEEN '" + DtoS(mv_par06) + "' AND '" + DtoS(mv_par07)  + "'"
    EndIf

    //If !Empty(mv_par10) //Dt Retorno, mv_par09|mv_par10
    //	cQry +=  " AND SZ7.Z7_XDTRET BETWEEN '" + DtoS(mv_par09) + "' AND '" + DtoS(mv_par10)  + "'"
    //EndIf
    If !Empty(mv_par09) //Dt Retorno, mv_par09|mv_par10
        cQry +=  " AND SZ7.Z7_XDTRET BETWEEN '" + DtoS(mv_par08) + "' AND '" + DtoS(mv_par09)  + "'"
    EndIf

Return cQry

Static Function ModelDef()

    Local oModel	:= Nil
    Local oStrSZ7 	:= FWFormStruct(1,"SZ7")

    oModel := MPFormModel():New("XCMVINT99",/*bPreValidacao*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/ )
    oModel:AddFields("SZ7MASTER",/*cOwner*/,oStrSZ7, /*bPreValid*/, /*bPosValid*/, /*bCarga*/ )

    oModel:SetDescription("Log de Integração SAP")
    oModel:SetPrimaryKey({"Z7_FILIAL","Z7_XLOTE"})

Return oModel

Static Function ViewDef()

    Local oView
    Local oModel  	:= FWLoadModel('CMVINT99')

    Local oStrSZ7 	:= FWFormStruct( 2, "SZ7",nil)

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField( 'VIEW_SZ7' , oStrSZ7, 'SZ7MASTER' )

    oView:CreateHorizontalBox( 'TELA' , 100 )
    oView:SetOwnerView( 'VIEW_SZ7', 'TELA' )

return oView

Static Function MenuDef()

    Local aRotina := {}

    //ADD OPTION aRotina Title "Pesquisar"			Action 'PesqBrw'  		  						OPERATION 1 ACCESS 0
    ADD OPTION aRotina Title "Visualizar"       	    Action 'U_xCMI99Vw()'  							OPERATION 4 ACCESS 0
    ADD OPTION aRotina Title "Atualização tela"		    Action 'U_xCM99ATe()'							OPERATION 3 ACCESS 0
    ADD OPTION aRotina Title "Rastrear"				    Action 'U_xCMVRast()'							OPERATION 2 ACCESS 0
    ADD OPTION aRotina Title "Reprocessar"			    Action 'U_xCMVREP()'							OPERATION 6 ACCESS 0
    ADD OPTION aRotina Title "Acerto Manual"		    Action 'U_xCM99AcM()'							OPERATION 2 ACCESS 0
    ADD OPTION aRotina Title "Gerar integração Contas a Pagar"	Action 'U_xCMCPGerInt()'				OPERATION 6 ACCESS 0

return aRotina

User Function xCM99ATe()

    If ParamBox(aParamBox,"Parâmetros Monitor de Integração SAP",@aRetParam)
        cQry	:= xQryDads(cCampos)
        //Preparo o comando para alimentar a tabela temporaria
        cInsert := "INSERT INTO " + cTable + " (" + cCampos + " RECSZ7 ) " + cQry
        xCMIAtu()
    EndIf

Return

Static Function xCMIAtu()

    Local cAlias := oBrowse:Alias()
    
    Processa({|| TcSQLExec(cDelete)})

    Processa({|| TcSQLExec(cInsert)})

    (cAlias)->(dbGoTop())
   
    oBrowse:GoTo(1,.T.)
    oBrowse:Refresh()

    //oBrowse:GoTo(nRecno,.T.)

Return

User Function xCMI99Vw()

    Local cFilBkp := cFilAnt
    Local cAlias := oBrowse:Alias()

    dbSelectArea("SZ7")
    SZ7->(DbSetOrder(0))
    SZ7->(DbGoTo((cAlias)->RECSZ7))

    cFilAnt := (cAlias)->Z7_FILIAL

    FWExecView ("Log de Integração SAP", "CMVINT99", MODEL_OPERATION_VIEW ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ , /*cOperatId*/ ,/*cToolBar*/,/*oModelAct*/)

    cFilAnt := cFilBkp

return

User Function xCMVRast()

    Local cAlias 		:= oBrowse:Alias()

    //If Alltrim((cAlias)->Z7_ORIGEM) $ "CTBA102|MATA240" 			//Lancto Contabil
    If (cAlias)->Z7_XTABELA == "CT2" 			//Lancto Contabil
        xCMVVLcto()
    ElseIf Alltrim((cAlias)->Z7_ORIGEM) $ "MATA460|CTBANFS" //Documento de Saida
        xCMVVSai()
    ElseIf Alltrim((cAlias)->Z7_ORIGEM) $ "CTBANFE|MATA103|GFEA065" //Documento de Entrada
        xCMVVEnt()
    ElseIf Alltrim((cAlias)->Z7_ORIGEM) $ "MATA030" 		//Clientes
        xCMVVCli()
    ElseIf Alltrim((cAlias)->Z7_ORIGEM) $ "MATA020" 		//Fornecedor
        xCMVVFor()
    ElseIf Alltrim((cAlias)->Z7_ORIGEM) $ "FINA050|FINA370|CTBAFIN" 		//Contas a Pagar
        xCMVVSE2()
    ElseIf Alltrim((cAlias)->Z7_ORIGEM) $ "FINA040/VEIA060" 		//Contas a Receber ( adiantamento )
        xCMVVSE1()
    ElseIf ( Alltrim((cAlias)->Z7_ORIGEM) $ "CMVSAP06" .Or. Alltrim((cAlias)->Z7_ORIGEM) $ "ZSAPF006" ) .and. (cAlias)->Z7_XTABELA == "SE1"  		//Contas a Receber - baixas
        xCMVVSE1()
    ElseIf ( Alltrim((cAlias)->Z7_ORIGEM) $ "CMVSAP06" .Or. Alltrim((cAlias)->Z7_ORIGEM) $ "ZSAPF006" ) .and. (cAlias)->Z7_XTABELA == "SE2"  		//Contas a pagar - baixas
        xCMVVSE2()
    ElseIf Empty((cAlias)->Z7_ORIGEM)
        If (cAlias)->Z7_XTABELA == "SE1"
            xCMVVSE1()
        ElseIf (cAlias)->Z7_XTABELA == "SE2"
            xCMVVSE2()
        EndIf
    EndIf

Return

Static Function xCMVVLcto()

    Local aArea 		:= GetArea()
    Local aAreaCT2 		:= CT2->(GetArea())
    //local aOldRotina 	:= aRotina
    Local cAlias 		:= oBrowse:Alias()
    Local cFilBkp 		:= cFilAnt
    Local nReg	  		:= 0

    cFilAnt := (cAlias)->Z7_FILIAL

    dbSelectArea("CT2")
    CT2->(DbSetOrder(1))//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC

    //If !Empty((cAlias)->Z7_RECORI)
    //	CT2->(dbGoTo((cAlias)->Z7_RECORI))
    //Else
    CT2->(dbSeek((cAlias)->Z7_FILIAL + Alltrim((cAlias)->Z7_XCHAVE) ))
    //EndIf

    dDataLanc	:= CT2->CT2_DATA
    cLote		:= CT2->CT2_LOTE
    cSubLote	:= CT2->CT2_SBLOTE
    cDoc		:= CT2->CT2_DOC
    cPadrao		:= CT2->CT2_LP

    lSubLote 	:= Empty(cSubLote)
    cLoteSub 	:= GetMv("MV_SUBLOTE")
    cCadastro 	:= "Visualização"

    aRotina := {	{"Pesquisar"    ,"AxPesqui"   , 0 , 1,,.F.},; // "Pesquisar"
    {"Visualizar"   ,"Ctba102Cal" , 0 , 2     },; // "Visualizar"
    {"Incluir"      ,"Ctba102Cal" , 0 , 3, 191},; // "Incluir"
    {"Alterar"      ,"Ctba102Cal" , 0 , 4     },; // "Alterar"
    {"Excluir"      ,"Ctba102Cal" , 0 , 5     },; // "Excluir"
    {"Estornar"     ,"Ctba102Cal" , 0 , 4     },; // "Estornar"
    {"Copiar"       ,"Ctba102Cal" , 0 , 3     },; // "Copiar"
    {"Rastrear"     ,"CtbC010Rot" , 0 , 2     },; // "Rastrear"
    {"Cópia Filial" ,"Ctba102Cop" , 0 , 4     } } // "Cópia Filial"

    nReg := CT2->(Recno())
    Ctba102Cal("CT2",nReg,2)

    cFilAnt := cFilBkp
    //aRotina := aOldRotina

    RestArea(aAreaCT2)
    RestArea(aArea)

Return

Static Function xCMVVSai()

    Local aArea 		:= GetArea()
    Local aAreaSF2 		:= SF2->(GetArea())
    Local cAlias 		:= oBrowse:Alias()
    Local cFilBkp 		:= cFilAnt
    Local nReg	  		:= 0

    cFilAnt := (cAlias)->Z7_FILIAL

    dbSelectArea("SF2")
    SF2->(DbSetOrder(0))

    SF2->(dbGoTo((cAlias)->Z7_RECORI))

    nReg := SF2->(Recno())
    Mc090Visual("SF2",nReg,2)

    cFilAnt := cFilBkp

    RestArea(aAreaSF2)
    RestArea(aArea)

return

Static Function xCMVVEnt()

    Local aArea 		:= GetArea()
    Local aAreaSF1 		:= SF1->(GetArea())
    Local cAlias 		:= oBrowse:Alias()
    Local cFilBkp 		:= cFilAnt
    Local nReg	  		:= 0

    aRotina := {}

    aAdd(aRotina,{OemToAnsi("Pesquisar")		, "AxPesqui"   , 0 , 1, 0, .F.}) 		//"Pesquisar"
    aAdd(aRotina,{OemToAnsi("Visualizar")		, "A103NFiscal", 0 , 2, 0, nil}) 		//"Visualizar"
    aAdd(aRotina,{OemToAnsi("Incluir")			, "A103NFiscal", 0 , 3, 0, nil}) 		//"Incluir"
    aAdd(aRotina,{OemToAnsi("Classificar")		, "A103NFiscal", 0 , 4, 0, nil}) 		//"Classificar"
    aAdd(aRotina,{OemToAnsi("Excluir")			, "A103NFiscal", 3 , 5, 0, nil})		//"Excluir"
    aAdd(aRotina,{OemToAnsi("Tracker Contábil")	, "CTBC662"    , 0 , 7, 0, .F.})	    //"Tracker Contabil"
    aAdd(aRotina,{OemToAnsi("Legenda")			, "A103Legenda", 0 , 2, 0, .F.})		//"Legenda"

    cFilAnt := (cAlias)->Z7_FILIAL

    dbSelectArea("SF1")
    SF1->(DbSetOrder(0))

    SF1->(dbGoTo((cAlias)->Z7_RECORI))

    nReg := SF1->(Recno())
    A103NFiscal("SF1",nReg,2)

    cFilAnt := cFilBkp

    RestArea(aAreaSF1)
    RestArea(aArea)

return

Static Function xCMVVCli()

    Local aArea 		:= GetArea()
    Local aAreaSA1 		:= SA1->(GetArea())
    Local cAlias 		:= oBrowse:Alias()
    //Local cFilBkp 		:= cFilAnt
    Local nReg	  		:= 0

    Private cCadastro  := "Clientes"
    Private aMemos     := {}
    Private bFiltraBrw := {|| Nil}
    Private aRotina
    Private aRotAuto   := Nil
    Private aCpoAltSA1 := {} // Vetor usado na gravacao do historico de alteracoes
    Private aCpoSA1    := {} // Vetor usado na gravacao do historico de alteracoes
    Private lCGCValido := .F. // Variavel usada na validacao do CNPJ/CPF (utilizando o Mashup)
    Private l030Auto   := .F. // Variavel usada para saber se é rotina automatica
    Private cFilAux	  := cFilAnt // Variavel utilizada no FINC010

    //cFilAnt := (cAlias)->Z7_FILIAL

    dbSelectArea("SA1")
    SA1->(DbSetOrder(0))

    SA1->(dbGoTo((cAlias)->Z7_RECORI))

    nReg := SA1->(Recno())
    A030Visual("SA1",nReg,2)

    //cFilAnt := cFilBkp

    RestArea(aAreaSA1)
    RestArea(aArea)

Return

Static Function xCMVVFor()

    Local aArea 		:= GetArea()
    Local aAreaSA2 		:= SA2->(GetArea())
    Local cAlias 		:= oBrowse:Alias()
    //Local cFilBkp 		:= cFilAnt
    Local nReg	  		:= 0

    Local bPre			:= {|nOpc| If(nOpc == 5,RegToMemory("SA2",.F.,.F.),),aFornNovo[1]:=M->A2_COD}
    Local bOK         	:= {|nOpc| IIF(fCanAvalSA2(nOpc-2),(aFornNovo[2]:=M->A2_COD,Iif(aFornNovo[2]!=aFornNovo[1] .And. __lSx8 .And. !(nOpc == 3 .And. l020Auto),RollBackSx8(),.T.),.T.),.F.)}
    Local bTTS			:= {|nOpc| FAvalSa2(nOpc-2), aFornNovo[2]:=M->A2_COD}
    Local bNoTTS		:= {|nOpc| fVariavel(nOpc-2) .And. fPosIncFor(nOpc)}

    Private cCadastro		:= OemtoAnsi("Fornecedores")
    Private aRotina			:= {}//MenuDef(.T.)
    Private aRotAuto		:= Nil
    Private lTMSOPdg		:= AliasInDic('DEG') .And. SuperGetMV('MV_TMSOPDG',,'0') == '2'
    Private lPyme			:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)
    Private aMemos			:= {}
    Private lIntLox			:= GetMV("MV_QALOGIX") == "1"
    Private aCpoAltSA2		:= {}	// vetor usado na gravacao do historico de alteracoes
    Private lCGCValido		:= .F.	// Variavel usada na validacao do CNPJ/CPF (utilizando o Mashup)
    Private aCmps			:= {}
    Private aPreCols		:= {}
    Private aCols			:= {}
    Private aHeader			:= {}
    Private cCodFor			:= ""
    Private cCodLoj			:= ""
    Private l020Auto		:= .F.//ValType(xRotAuto) == "A"
    Private aParam			:= {bPre,bOK,bTTS,bNoTTS}
    Private aFornNovo		:={"",""}

    aadd(aRotina,{ "Pesquisar"	, "AxPesqui"	, 0, 1}) //Pesquisar
    aadd(aRotina,{ "Visualizar"	, "A020Visual"	, 0, 2}) //Visualizar
    aadd(aRotina,{ "Incluir"	, "A020Inclui"	, 0, 3}) //Incluir
    aadd(aRotina,{ "Alterar"	, "A020Altera"	, 0, 4}) //Alterar
    aadd(aRotina,{ "Excluir"	, "A020Deleta"	, 0, 5}) //Excluir

    dbSelectArea("SA2")
    SA2->(DbSetOrder(0))

    SA2->(dbGoTo((cAlias)->Z7_RECORI))

    nReg := SA2->(Recno())
    A020Visual("SA2",nReg,2)

    //cFilAnt := cFilBkp

    RestArea(aAreaSA2)
    RestArea(aArea)

Return

Static Function xCMVVSE1()

    Local aArea 		:= GetArea()
    Local aAreaSE1 		:= SE1->(GetArea())
    Local cAlias 		:= oBrowse:Alias()
    Local cFilBkp 		:= cFilAnt
    Local nReg	  		:= 0

    dbSelectArea("SE1")

    //If (cAlias)->Z7_RECORI <> 0 // nao habilitar este techo, pois ha casos de registros na sz7 com a tabela SE1, mas os dados de origem sao o da SF2
    //	SE1->(DbSetOrder(0))
    //	SE1->(dbGoTo((cAlias)->Z7_RECORI))
    //	nReg := SE1->(Recno())
    //Else
    SE1->(DbSetOrder(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
    SE1->(dbSeek((cAlias)->(Z7_FILIAL + Z7_XCHAVE)))
    //Endif

    If SE1->(Found()) .or. !Empty(nReg)
        U_CMVCFIN2()
    Endif

    cFilAnt := cFilBkp

    RestArea(aAreaSE1)
    RestArea(aArea)

Return

Static Function xCMVVSE2()

    Local aArea 		:= GetArea()
    Local aAreaSE2 		:= SE2->(GetArea())
    Local cAlias 		:= oBrowse:Alias()
    Local cFilBkp 		:= cFilAnt
    Local nReg	  		:= 0

    dbSelectArea("SE2")

    If (cAlias)->Z7_RECORI <> 0
        SE2->(DbSetOrder(0))
        SE2->(dbGoTo((cAlias)->Z7_RECORI))
        nReg := SE2->(Recno())
    Else
        SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
        SE2->(dbSeek((cAlias)->(Z7_FILIAL + Z7_XCHAVE)))
    EndIf

    If SE2->(Found()) .or. !Empty(nReg)
        U_CMVCFIN1()
    Endif

    cFilAnt := cFilBkp

    RestArea(aAreaSE2)
    RestArea(aArea)

Return

User Function xCMVREP()
    Local _nPos         := 0
    Local cAlias 		:= oBrowse:Alias()
    Local nRec			:= (cAlias)->RECSZ7
    Local _cEmp         := FWCodEmp()
    Local cMarca        := oBrowse:Mark()

While !Eof() 

        If (cAlias)->Z7_OK <> ' '

            nRec   := (cAlias)->RECSZ7

    dbSelectArea("SZ7")
    SZ7->(dbSetOrder(0))
    SZ7->(dbGoto(nRec))

    If SZ7->Z7_XSTATUS $ "P|A|E" // obs: testar sempre o campo Z7_XSTATUS diretamente pela tabela, ao inves do temporario, pois o campo pode jah ter sido alterado de conteudo pelo job e o temporario estarah refletindo o conteudo anterior do campo.
        If SZ7->Z7_XSTATUS <> "P"
            SZ7->(RecLock("SZ7",.F.))
            SZ7->Z7_XSTATUS := "P"
            SZ7->(MsUnLock())
        EndIf

        RecLock( cAlias , .F. )
        (cAlias)->(Z7_OK)	:= iIf( Empty((cAlias)->Z7_OK ) , oBrowse:Mark() , " ")
        (cAlias)->(MsUnlock())

        If _cEmp == "2010" //Executa o p.e. Anapolis.

            _nPos := At("RA", (cAlias)->Z7_XCHAVE)

            If (cAlias)->Z7_XTABELA == "SA1"
                //U_CMVSAP02( nil , nil , nRec )
                U_CMVSAP02( { { cEmpAnt , cFilAnt , nRec } } )
            ElseIf (cAlias)->Z7_XTABELA == "SA2"
                //U_CMVSAP01( nil , nil , nRec)
                U_CMVSAP01( { { cEmpAnt , cFilAnt , nRec } } )
            ElseIf (cAlias)->Z7_XTABELA == "CT2"
                //U_CMVSAP08(nRec)
                U_CMVSAP08( { { cEmpAnt , cFilAnt , nRec } } )
            ElseIf ((cAlias)->Z7_XTABELA == "SF2" .and. ((cAlias)->Z7_TIPONF <> 'B' .and. (cAlias)->Z7_TIPONF <> 'D' ));
                    .or. ((cAlias)->Z7_XTABELA == "SF1" .and. (cAlias)->Z7_TIPONF == 'D' )
                //U_CMVSAP12( nRec )
                U_CMVSAP12( { { cEmpAnt , cFilAnt , nRec } } )
            ElseIf ((cAlias)->Z7_XTABELA == "SF1" .and. ((cAlias)->Z7_TIPONF <> 'B' .and. (cAlias)->Z7_TIPONF <> 'D' ));
                    .or. ((cAlias)->Z7_XTABELA == "SF2" .and. (cAlias)->Z7_TIPONF == 'D' )
                //U_CMVSAP03( nil , nil , nRec )
                U_CMVSAP03( { { cEmpAnt , cFilAnt , nRec } } )  //Quando emitida a NF
            ElseIf (cAlias)->Z7_XTABELA == "SE2"
                //U_CMVSAP13( nil ,nil , nRec )
                U_CMVSAP13( { { cEmpAnt , cFilAnt , nRec } } )
                // chamada da cmvsap03, pois titulos em moeda diferente da 1 do Comex sao enviados por esta rotina
                If SZ7->Z7_XSTATUS == "P"
                    U_CMVSAP03( { { cEmpAnt , cFilAnt , nRec } } )
                Endif
            ElseIf SZ7->Z7_XTABELA == "SE1" 
                IF _nPos = 0  //se não for RA
                    U_CMVSAP17( { { cEmpAnt , cFilAnt , nRec } } )
                ELSE
                    U_CMVSAP26( { { cEmpAnt , cFilAnt , nRec } } )
                ENDIF
            Else
                //Alert("Tipo não contemplado no reprocessamento")
                Help("",1,"Reprocessamento",,"Tipo não contemplado no reprocessamento",1,0)
                return nil
            EndIf
        Else
             If (cAlias)->Z7_XTABELA == "SA1"
                //U_ZSAPF002( nil , nil , nRec )
                U_ZSAPF002( { { cEmpAnt , cFilAnt , nRec } } )
            ElseIf (cAlias)->Z7_XTABELA == "SA2"
                //U_ZSAPF001( nil , nil , nRec)
                U_ZSAPF001( { { cEmpAnt , cFilAnt , nRec } } )
            ElseIf (cAlias)->Z7_XTABELA == "CT2"
                //U_ZSAPF008(nRec)
                U_ZSAPF008( { { cEmpAnt , cFilAnt , nRec } } )
            ElseIf ((cAlias)->Z7_XTABELA == "SF2" .and. ((cAlias)->Z7_TIPONF <> 'B' .and. (cAlias)->Z7_TIPONF <> 'D' ));
                    .or. ((cAlias)->Z7_XTABELA == "SF1" .and. (cAlias)->Z7_TIPONF == 'D' )
                //U_ZSAPF012( nRec )
                U_ZSAPF012( { { cEmpAnt , cFilAnt , nRec } } )
            ElseIf ((cAlias)->Z7_XTABELA == "SF1" .and. ((cAlias)->Z7_TIPONF <> 'B' .and. (cAlias)->Z7_TIPONF <> 'D' ));
                    .or. ((cAlias)->Z7_XTABELA == "SF2" .and. (cAlias)->Z7_TIPONF == 'D' )
                //U_ZSAPF003( nil , nil , nRec )
                U_ZSAPF003( { { cEmpAnt , cFilAnt , nRec } } )
            ElseIf (cAlias)->Z7_XTABELA == "SE2"
                //U_ZSAPF013( nil ,nil , nRec )
                U_ZSAPF013( { { cEmpAnt , cFilAnt , nRec } } )
                // chamada da ZSAPF003, pois titulos em moeda diferente da 1 do Comex sao enviados por esta rotina
                If SZ7->Z7_XSTATUS == "P"
                    U_ZSAPF003( { { cEmpAnt , cFilAnt , nRec } } )
                Endif
            ElseIf (cAlias)->Z7_XTABELA == "SE1"
                U_ZSAPF017( { { cEmpAnt , cFilAnt , nRec } } )
            Else
                //Alert("Tipo não contemplado no reprocessamento")
                Help("",1,"Reprocessamento",,"Tipo não contemplado no reprocessamento",1,0)
                return nil
            EndIf
        EndIf

        Int99RegAltBrow(SZ7->Z7_FILIAL,SZ7->(Recno()),SZ7->Z7_XSTATUS,SZ7->Z7_XDTENV,SZ7->Z7_XHRENV,SZ7->Z7_XLOTE,SZ7->Z7_XOPESAP,SZ7->Z7_LOTEINC)

        oBrowse:Refresh()

        //Atualiza a tela
        //xCMIAtu()

    Else
        //Alert("Será permitido reprocessamento para os registros com Status: P=Pendente, A=Aguardando retorno,E=Erro."+CRLF+;
        //IIf(!SZ7->Z7_XSTATUS == (cAlias)->Z7_XSTATUS,"O status deste registro foi alterado pelo retorno da integração com o SAP, utilize a opçao 'Atualização tela', para verificar o novo status.",""))
        Help("",1,"Reprocessamento",,"Será permitido reprocessamento para os registros com Status: P=Pendente, A=Aguardando retorno,E=Erro."+;
        IIf(!SZ7->Z7_XSTATUS == (cAlias)->Z7_XSTATUS,"O status deste registro foi alterado pelo retorno da integração com o SAP, utilize a opçao 'Atualização tela', para verificar o novo status.",""),1,0)
    EndIf

EndIf

        dbSelectArea(cAlias)
        dbSkip()

    End

return nil


// faz o acerto manual do registro, grava uma observacao e troca o status do registro
User Function xCM99AcM()

Local cObs := ""
Local oDlg
Local oMGet
Local x := 1
Local cBlkVld := "{|| !Empty(cObs)}"
Local cAlias := oBrowse:Alias()
Local cFilSZ7 := ""
Local cLote := ""
Local cNextAlias := GetNextAlias()

SZ7->(DbGoTo((cAlias)->RECSZ7))
// se nao for exclusao, somente faz acerto manual se status for igual a erro
// ou se for exclusao, somente faz acerto para status diferentes de O/M/N
If (!SZ7->Z7_XOPEPRO == 3 .and. !SZ7->Z7_XSTATUS == "E") .or. (SZ7->Z7_XOPEPRO == 3 .and. SZ7->Z7_XSTATUS $ ("O/M/N"))
    Help("",1,"Acerto Manual",,"Registro não atende as regras para o Acerto Manual.",1,0)

    Return()
Endif

// se for exclusao e a inclusao teve acerto manual, o acerto manual serah feito de acordo com a inclusao
If SZ7->Z7_XOPEPRO == 3
    cFilSZ7 := xFilial("SZ7")
    cLote := SZ7->Z7_LOTEINC
    cObs := "Lote "+Alltrim(cLote)+" de inclusão acertado manualmente."

    BeginSql Alias cNextAlias
        SELECT SZ7.R_E_C_N_O_ SZ7_RECNO
        FROM %Table:SZ7% SZ7
        WHERE
        SZ7.%NotDel%
        AND Z7_FILIAL = %Exp:cFilSZ7%
        AND Z7_XLOTE = %Exp:cLote%
        AND Z7_XOPEPRO <> 3
        AND Z7_XSTATUS IN ('M')
    EndSql

    If (cNextAlias)->(!EOF())
        SZ7->(RecLock("SZ7",.F.))
        SZ7->Z7_XSTATUS := "M"
        SZ7->Z7_XRETORN := "Acerto Manual: "+dToc(dDataBase)+" - "+Time()+CRLF+Upper(cObs)+CRLF+Alltrim(SZ7->Z7_XRETORN)+CRLF
        SZ7->(MsUnlock())
        (cNextAlias)->(dbCloseArea())

        Int99RegAltBrow(SZ7->Z7_FILIAL,SZ7->(Recno()),SZ7->Z7_XSTATUS,SZ7->Z7_XDTENV,SZ7->Z7_XHRENV,SZ7->Z7_XLOTE,SZ7->Z7_XOPESAP,SZ7->Z7_LOTEINC)
        Help("",1,"Acerto Manual",,cObs,1,0)

        Return()
    Endif

    (cNextAlias)->(dbCloseArea())
Endif

While x == 1
    cObs := ""
	DEFINE MSDIALOG oDlg TITLE "Acerto Manual" FROM 200,001 TO 350,350 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS

    @ 05,05	SAY OemToAnsi("Observação do Acerto Manual :") OF oDlg SIZE 80,10 PIXEL
    oMGet := TMultiGet():New(15,05,{|u| If(PCount()>0,cObs:=u,cObs)},oDlg,165,40,,.F.,,,,.T.,,.F.,,.F.,.F.,.F.,&(cBlkVld),,.F.,.F.,.T.)

    DEFINE SBUTTON oBut1 FROM 60,100 TYPE 1 ACTION (nOpcA := 1,x := 0,oDlg:End()) ENABLE OF oDlg
    DEFINE SBUTTON oBut1 FROM 60,140 TYPE 2 ACTION (IIf(MsgYesNo("Deseja mesmo cancelar o Acerto Manual ?"),(x := 0,oDlg:End()),Nil)) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED VALID {|| x <> 0 }
Enddo

If !Empty(cObs)
    SZ7->(Reclock("SZ7",.F.))
    SZ7->Z7_XSTATUS := "M" // acerto manual
    SZ7->Z7_XRETORN := "Acerto Manual: "+dToc(dDataBase)+" - "+Time()+CRLF+Upper(cObs)+CRLF+Alltrim(SZ7->Z7_XRETORN)+CRLF
    SZ7->(MsUnLock())

    // se tiver registro de cancelamento/alteracao pendentes ainda, força o acerto manual no cancelamento/alteracao
    If !SZ7->Z7_XOPEPRO == 3
        cFilSZ7 := xFilial("SZ7")
        cLote := SZ7->Z7_XLOTE
        cObs := "Lote "+Alltrim(cLote)+" de inclusão acertado manualmente."
        BeginSql Alias cNextAlias
            SELECT SZ7.R_E_C_N_O_ SZ7_RECNO
            FROM %Table:SZ7% SZ7
            WHERE
            SZ7.%NotDel%
            AND Z7_FILIAL = %Exp:cFilSZ7%
            AND Z7_LOTEINC = %Exp:cLote%
            AND Z7_XOPEPRO <> 1
            AND Z7_XSTATUS NOT IN ('O','M')
        EndSql

        While (cNextAlias)->(!EOF())
            SZ7->(dbGoto((cNextAlias)->SZ7_RECNO))
            If SZ7->(Recno()) == (cNextAlias)->SZ7_RECNO
                SZ7->(RecLock("SZ7",.F.))
                SZ7->Z7_XSTATUS := "M"
                SZ7->Z7_XRETORN := "Acerto Manual: "+dToc(dDataBase)+" - "+Time()+CRLF+Upper(cObs)+CRLF+Alltrim(SZ7->Z7_XRETORN)+CRLF
                SZ7->(MsUnlock())

                Int99RegAltBrow(SZ7->Z7_FILIAL,SZ7->(Recno()),SZ7->Z7_XSTATUS,SZ7->Z7_XDTENV,SZ7->Z7_XHRENV,SZ7->Z7_XLOTE,SZ7->Z7_XOPESAP,SZ7->Z7_LOTEINC)
            Endif
            (cNextAlias)->(dbSkip())
        Enddo
        (cNextAlias)->(dbCloseArea())
    Endif

    //Atualiza a tela
    xCMIAtu()
Endif

Return()





// atualizacao na tabela temporaria, do status dos registros reprocessados em tela
Static Function Int99RegAltBrow(cFilx,nRecSZ7,cStatus,dDataEnv,cHoraEnv,cLote,nOperSAP,cLoteInc)

Local aArea	:= {SZ7->(GetArea()),GetArea()}
Local cRecCan := ""

Int99EfetAlt(cFilx,nRecSZ7,cStatus,dDataEnv,cHoraEnv,cLote)

// se registro eh de inclusao/alteracao, verifica se tem registro de cancelamento correspondente
If nOperSAP == 1
    cRecCan := Int99RegCanMarc(cFilx,cLote,nRecSZ7)
    // atualiza tambem no temporario do registro de cancelamento
    If !Empty(cRecCan)
        SZ7->(dbGoto(cRecCan))
        If SZ7->(Recno()) == cRecCan
            Int99EfetAlt(SZ7->Z7_FILIAL,SZ7->(Recno()),SZ7->Z7_XSTATUS,SZ7->Z7_XDTENV,SZ7->Z7_XHRENV,SZ7->Z7_XLOTE)
        Endif
    Endif
Endif

// se registro eh de cancelamento, atualiza registro de inclusao/alteracao
If nOperSAP == 2
    SZ7->(dbSetOrder(1))
    If SZ7->(dbSeek(cFilx+cLoteInc))
        Int99EfetAlt(SZ7->Z7_FILIAL,SZ7->(Recno()),SZ7->Z7_XSTATUS,SZ7->Z7_XDTENV,SZ7->Z7_XHRENV,SZ7->Z7_XLOTE)
    Endif
Endif

aEval(aArea,{|x| RestArea(x)})

Return()


// efetiva a alteracao do registro na tabela temporaria
Static Function Int99EfetAlt(cFilx,nRecSZ7,cStatus,dDataEnv,cHoraEnv,cLote)

Local aArea	:= {GetArea()}
Local cAltera := ""

cAltera := "UPDATE "
cAltera += cTable+" "
cAltera += "SET Z7_XSTATUS = '"+cStatus+"', "
cAltera += "Z7_XDTENV = '"+dTos(dDataEnv)+"', "
cAltera += "Z7_XHRENV = '"+cHoraEnv+"' "
cAltera += "WHERE "
cAltera += "Z7_XLOTE = '"+cLote+"' "
cAltera += "AND Z7_FILIAL = '"+cFilx+"' "

TcSQLExec(cAltera)

aEval(aArea,{|x| RestArea(x)})

Return()


// verifica se tem registro de cancelamento jah marcado para nao ser processado
Static Function Int99RegCanMarc(cxFil,cLote,nRecInc)

Local aArea	:= {SZ7->(GetArea()),GetArea()}
local cRet := ""
Local cNextAlias := GetNextAlias()

BeginSql Alias cNextAlias
    SELECT SZ7.R_E_C_N_O_ SZ7_RECNO,Z7_XLOTE
    FROM %Table:SZ7% SZ7
    WHERE
    SZ7.%NotDel%
    AND Z7_FILIAL = %Exp:cxFil%
    AND Z7_LOTEINC = %Exp:cLote%
    AND Z7_XOPESAP = 2
    AND Z7_XSTATUS IN ('N')
EndSql

If (cNextAlias)->(!EOF())
    cRet := (cNextAlias)->SZ7_RECNO
Endif

(cNextAlias)->(dbCloseArea())

aEval(aArea,{|x| RestArea(x)})

Return(cRet)




// gera registro na tabela sz7, para movimentos de contas a pagar, que por algum motivo/problema,
// nao tenham sido gerados na sz7 no momento que o evento ocorreu
User Function xCMCPGerInt()

U_CMVSAP25()

U_xCM99ATe()

return nil


static function getCposSx3( cTabela , lBrowse )
	local cRet			:= ""
	local aSX3			:= ""
	local nI			:= 0
	local nPosCpo		:= 0
	local nPosContex	:= 0
	local nPosBrowse	:= 0

	aSX3 := U_GetSx3( cTabela ) // Chama OpenSXs de forma que não de erro no code analysis

	// Procuro a posição dos campos que serão usados
	nPosCpo 	:= AScan( aSX3[1] , {|x| x ==  "X3_CAMPO"	})
	nPosContex 	:= AScan( aSX3[1] , {|x| x ==  "X3_CONTEXT"	})
	nPosBrowse 	:= AScan( aSX3[1] , {|x| x ==  "X3_BROWSE"	})

	for nI := 1 to len( aSX3[ 2 ] )
		if aSX3[ 2 , nI , nPosContex ] == "R" .or. aSX3[ 2 , nI , nPosContex ] == " "
			if lBrowse .and. aSX3[ 2 , nI , nPosBrowse ] == "S"
				cRet += aSX3[ 2 , nI , nPosCpo ] + ", "
			else
				cRet += aSX3[ 2 , nI , nPosCpo ] + ", "
			endif
		endif
	next
return cRet


//Função para marcar/desmarcar todos os registros do grid
Static Function CMVMARC(cMarca,lMarcar)
Local cAlias  := oBrowse:Alias()

Begin Sequence
    (cAlias)->( dbGoTop() )
    While !(cAlias)->( Eof() )
    	RecLock( cAlias, .F. )
        (cAlias)->Z7_OK := IIf( (cAlias)->Z7_OK=" ", cMarca, '  ' ) //IIf( lMarcar, cMarca, '  ' )
        (cAlias)->(MsUnlock())
        (cAlias)->( DbSkip() )
    EndDo
	//(cAlias)->(DbGoto(_nRecNo))
    //oBrowse:GoTo(_nRecNo,.T.)
    
    (cAlias)->( dbGoTop() )
    oBrowse:GoTop()
    oBrowse:Refresh()

End Sequence
Return .T.


/*/{Protheus.doc} ZDupColClick
//Ação de duplo clique na coluna de marcação
@author A. Carlos
@since 09/01/2024
@version  
@type function
/*/
Static Function ZDupColClick()
	Local cAliasBRW	:= oBrowse:Alias()
    //Local cMarca    := oBrowse:Mark()
	Local aAliasBRW	:= (cAliasBRW)->(GetArea())
	DEFAULT lAll	:= .F.

	RecLock( cAliasBRW , .F. )
	(cAliasBRW)->(Z7_OK)	:= iIf( Empty((cAliasBRW)->Z7_OK ) , oBrowse:Mark() , " ")
	(cAliasBRW)->(MsUnlock())

	If !( lAll )
		oBrowse:Refresh()
	EndIf

	RestArea(aAliasBRW)

Return(.T.)

