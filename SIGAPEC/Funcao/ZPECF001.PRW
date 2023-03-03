#Include "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "RWMAKE.ch"
#Include "Colors.ch"
#Include "Font.ch"
#Include "HBUTTON.CH"
#Include "Topconn.ch"
#Include "TBICONN.CH"
#Include "FWADAPTEREAI.CH"


/*/{Protheus.doc} ZPECF001
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	08/09/2021
@return  	NIL
@obs        Local cMainPath	:= GetMv("CMV_PEC008")      
@project
@history    Importar dados da Tabela de Preços via planilha 
/*/

User Function ZPECF001()
    Local   K         := 1
    Local   nPos      := 0
    Local   nPos1     := 0
    Local   cProd     := ""
    Local   aPergs    := {}
    Local   cExtens   := "Arquivo XLS | *.XLS"

    Private cFile 	  := Space(10)
    Private _nTamF    := 0
    Private Caminho   := GetMv("CMV_PEC008")    //"C:\Users\antonio.poliveira\Documents\Arquivos_Importa\"    //"C:\Users\antonio.poliveira\Documents\Arquivos_Importa\"   //Pasta onde deve ser colocado o arquivo de importacao  "C:\Users\antonio.poliveira\Documents\Arquivos_Importa"    //GetMv("CMV_PEC008")    // "C:\Users\antonio.poliveira\Documents\Arquivos_Importa\"   //Pasta onde deve ser colocado o arquivo de importacao  "C:\Users\antonio.poliveira\Documents\Arquivos_Importa" 
    Private cMoeda    := GetMv("CMV_PEC002")    // 1 - Reais - Moeda
    Private cTpOper   := GetMv("CMV_PEC003")    // 4 - Todos - Tipo Operação
    Private cTpPrec   := GetMv("CMV_PEC004")    // 1 - Preço de Venda - Tipo Preço
    Private cItem     := "0000"
    Private lItem     := .F.
    Private _cDestab  := Space(20)
    Private _cDtIni   := CTOD("  /  /  ")
    Private _cDtFim   := CTOD("  /  /  ")
    Private _cHrIni   := "  :  "
    Private _cHrFim   := "  :  "
    Private _cMarca   := ""
    Private _cTabAtv  := Space(01)
    Private _cAtv     := Space(01)
    Private _cAtBO    := .T.
    Private _cGrvPr   := .T.

    Private aPreco    := {}
    Private aRetP     := {}
    Private	aPedIte   := {}
    Private aArqXLS   := {}
    Private aErr      := {}
    Private aCampos   := SetCampos()
    Private cArq
    Private oDLG
    Private cArqLog	  := Caminho+"TPPEC_"+DTOS(Date())+StrTran(Time(),":")+".LOG"

    aAdd( aPergs ,{1,"Descrição Tabela   " , _cDestab,,,,,60,.T.})
    aAdd( aPergs ,{1,"Data Inicial       " , _cDtIni ,,"!Empty(mv_par01)",,,45,.T.})
    aAdd( aPergs ,{1,"Data Final         " , _cDtFim ,,"mv_par03>=Date()",,,45,.T.})
    aAdd( aPergs ,{1,"Hora Inicial       " , _cHrIni ,,,,,00,.T.})
    aAdd( aPergs ,{1,"Hora Final         " , _cHrFim ,,,,,00,.T.})
    aAdd( aPergs ,{1,"Tabela Ativa (S/N) " , _cTabAtv,,"PERTENCE('S|N')",,,00,.T.})
    aAdd( aPergs ,{4,"Atualiza PRV B.O.  " , _cAtBO  ,"Click",45,".T.",.F.})
    aAdd( aPergs ,{4,"Grava PRV Cad Prod " , _cGrvPr ,"Click",45,".T.",.F.})
    aAdd( aPergs ,{1,"Moeda              " , cMoeda  ,,,,,00,.T.})
    aAdd( aPergs ,{1,"Tipo Operação      " , cTpOper ,,,,,00,.T.})
    aAdd( aPergs ,{1,"Tipo Preço         " , cTpPrec ,,,,,00,.T.})

    aAdd( aPergs ,{6,"Selecione arquivo " , Caminho ,"@!",,'.T.',80,.T.,cExtens})

    If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 

        DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Busca XLS de Tabela de Preços") PIXEL
        @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
        @ 29, 15 SAY OemToAnsi("Esta rotina importa dados de Tabela de Preços - PEC") SIZE 268, 8 OF oDlg PIXEL
        @ 38, 15 SAY OemToAnsi("Conforme layout: Nr. Tabela,	Part Number, Description, New Price 5 Net ") SIZE 268, 8 OF oDlg PIXEL
        @ 48, 15 SAY OemToAnsi("Confirma Processo ? ") SIZE 268, 8 OF oDlg PIXEL
        DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
        DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
        ACTIVATE MSDIALOG oDlg CENTER

        If nOpca == 0
            Return Nil
        Endif

        _cDestab := MV_PAR01
        _cDtIni  := MV_PAR02
        _cDtFim  := MV_PAR03
        _cHrIni  := MV_PAR04
        _cHrFim  := MV_PAR05
        _cTabAtv := MV_PAR06
        //_cAtBO   := MV_PAR07
        //_cGrvPr  := MV_PAR08
        cMoeda   := MV_PAR09
        cTpOper  := MV_PAR10
        cTpPrec  := MV_PAR11

        If _cTabAtv = "S"
            _cAtv := "1"
        else
            _cAtv := "2"
        EndIf

        //Verificar arquivos existentes para importar	
        aArqXLS	:= Directory( Caminho + "*.XLS" )
        _nTamF   := Len( aArqXLS )

        If Empty(aArqXLS)
            ApMsgInfo("Importação cancelada ou arquivo não encontrado", FunName())
            Return Nil
        EndIf

        aPreco := u_XlsxToArr(Alltrim(MV_PAR12), "1")

        FOR K := 2 TO LEN(aPreco)
            cProd := aPreco[K][2]
            IF nPos1 = 0
                nPos1 := k
            ENDIF
            nPos  := aScan(aPreco, {|x| Alltrim(x[2]) == cProd},nPos1)
            nPos++   
            nPos1 := aScan(aPreco, {|x| Alltrim(x[2]) == cProd},nPos)  
            If nPos1 > 0
                If MsgYesNo("Produto duplicado na planilha. Abortar ?  "+Alltrim(cProd))
                    Return Nil
                Endif
            Endif
        NEXT K

        Processa({|| ImpCadXLS(@cArqLog) }, "[ZPECF001] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." )
            
        MSGINFO( "Processado com Sucesso!","Final do processamento!" )
        
    Endif

Return Nil 


Static Function ImpCadXLS(cArqLog)
    Local nLinIni      := 2
    Local nTabel       := "Nr. Tabela"
    Local nPosTab      := 0 
    Local cAviso       := ""
    Local dHoraAtu     := Time()

    Private I          := 1
    Private __dDataAtu := Date()
    Private nTotal     := 0
    Private nAtual     := 0
    Private nAtseg     := 0 
    Private _aStruLog  := {}
    Private cCampoUF   := ""
    Private cTitUF     := ""

    AADD(_aStruLog,{"STATUS" ,"C",010,0})
    AADD(_aStruLog,{"LOG"    ,"C",280,0})

    _cArqTRB   := Criatrab(_aStruLog,.T.)
    _cIndice   := CriaTrab(Nil,.F.)
    _cChaveInd := "LOG"

    If Select("TRB7") > 0
        dbSelectArea("TRB7")
        dbCloseArea()
        TCDelFile(_cArqTRB)
    EndIf

    dbCreate( _cArqTRB , _aStruLog , "TOPCONN" )
    dbUseArea( .T., __LocalDriver, _cArqTRB , "TRB7", .F., .F. )
    dbCreateIndex( _cArqTRB ,_cChaveInd )

    dbSelectArea( "TRB7" )
    dbSetOrder(1)

    //--Ativação de workareas
    SB1->( DbSetOrder(1) )
    DA0->( DbSetOrder(1) )

    If _nTamF > 1

        aSort( aArqXLS , , , {|x,y| DTOS(x[3])+x[4]<DTOS(y[3])+y[4] } )

    EndIf

    //Importa arquivo
    ProcRegua(Len(aPreco))

    If Empty(aPreco)
        ApMsgInfo("Importação cancelada ou arquivo vazio", FunName())
        Return Nil
    EndIf

    For I := nLinIni to Len(aPreco)
        
        If Len(aPreco[i]) < 4   // cada linha tem que ter 4 colunas
            Loop
        Endif

        If Empty(Upper(aPreco[I, 1]))
            Loop
        EndIf    

        nPosTab := aScan(aPreco,nTabel)

        If Len(aPreco[i]) <  aCampos[Len(aCampos), 3]
            Aadd(aErr, " - Linha " + cValToChar(i) + " ERRO, quant campos linha: " + cValToChar(Len(aPreco[i])) + " esperado " + cValToChar(aCampos[Len(aCampos), 3]) )
            Loop
        EndIf

        aPreco[i][1] := PADR(aPreco[i][1], TamSX3("DA0_CODTAB")[1] )
        aPreco[i][2] := PADR(aPreco[i][2], TamSX3("B1_COD")[1] )

        If !( SB1->( DbSeek( FWxFilial("SB1") + aPreco[i][2] ) ) )
            Aadd(aErr, " - Linha " + cValToChar(i) + " ERRO, produto: " + aPreco[i][2] + " não localizado no cadastro de produtos." )
            Loop
        EndIf
                
        Busca_Marca(Alltrim(aPreco[i][2]))   //'HYU',  'SBR',  'CHE'

        If DA0->(dbSeek(xFilial("DA0")+(aPreco[i][1])))

            IF _cAtBO   //Ajustar pedidos BO
			    RecLock("DA0", .F.)
				DA0->DA0_XBOPRV := _cAtBO 
				DA0->(MsUnlock())
            ELSE 
			    RecLock("DA0", .F.)
				DA0->DA0_XBOPRV := _cAtBO
				DA0->(MsUnlock())
            ENDIF

            IF _cGrvPr    //replicar para o B1_PRV1,
                RecLock("DA0", .F.)
				DA0->DA0_XB1PRV := _cGrvPr
				DA0->(MsUnlock())
			ELSE
			    RecLock("DA0", .F.)
				DA0->DA0_XB1PRV := _cGrvPr 
				DA0->(MsUnlock())
            ENDIF

            RecLock("DA0", .F.)
                DA0->DA0_XDATIM := __dDataAtu
                DA0->DA0_DATDE  := _cDtIni
                DA0->DA0_HORADE := _cHrIni
                DA0->DA0_DATATE := _cDtFim
                DA0->DA0_HORATE := _cHrFim
                DA0->DA0_ATIVO  := _cAtv
                DA0->DA0_XDATIM := __dDataAtu 
                DA0->DA0_XHRIMP := dHoraAtu
                DA0->DA0_XUSIMP := __cUserId
			DA0->(MsUnlock())

            DA1->(DbGoTop())
            DA1->(DbOrderNickName("TABPROD"))
			If DA1->(dbSeek(xFilial("DA1")+(aPreco[i][1])+(aPreco[i][2])))

                SZL->(DbGoTop())
                While !SZL->(EOF())

                    cCampoUF := AllTrim( SZL->ZL_UF )
                    cTitUF   := AllTrim( SZL->ZL__DA1UF )
            
                    RecLock("DA1", .F.)
                        DA1->DA1_PRCVEN := VAL(aPreco[i][4]) 
                        DA1->DA1_DATVIG := _cDtFim
                        DA1->DA1_ATIVO  := _cAtv
                        DA1->DA1_TPOPER := cTpOper
                        DA1->DA1_MOEDA  := VAL(cMoeda)
                        DA1->DA1_XCDMAR := _cMarca
                        &("DA1->" + cTitUF)      := VAL(aPreco[i][4])
                        DA1->DA1_XDATIM := __dDataAtu
                        DA1->DA1_QTDLOT := 999999.99
                        DA1->DA1_INDLOT := "000000000999999.99"
                    DA1->(MsUnlock())
                
                    SZL->(DbSkip())
                EndDo
   
            Else

                Busca_Item()
                IF cItem = "0000" 
                    cItem := Soma1(cItem)
                ENDIF
                SZL->(DbGoTop())
                While !SZL->(EOF())

                    cCampoUF := AllTrim( SZL->ZL_UF )
                    cTitUF   := AllTrim( SZL->ZL__DA1UF )
            
                    IF lItem .OR. cItem = "0001" 

                       Grv_DA1N()

                    ELSE
                        RecLock("DA1", .F.)
                        &("DA1->" + cTitUF)      := VAL(aPreco[i][4])
                        DA1->(MsUnlock())
                    ENDIF
              
                    SZL->(DbSkip())
                EndDo

            Endif

	    ENDIF

        //Tabela não existente precisa criar e para cada estado
		If !DA0->(dbSeek(xFilial("DA0")+(aPreco[i][1])))

			RecLock("DA0", .T.)
                DA0->DA0_FILIAL := xFilial("DA0")
                DA0->DA0_CODTAB := (aPreco[i][1])
                DA0->DA0_DESCRI := _cDestab
                DA0->DA0_DATDE  := _cDtIni
                DA0->DA0_DATATE := _cDtFim
                DA0->DA0_HORADE := _cHrIni
                DA0->DA0_HORATE := _cHrFim
                DA0->DA0_ATIVO  := _cAtv
                DA0->DA0_XBOPRV := _cAtBO
                DA0->DA0_XB1PRV := _cGrvPr
                DA0->DA0_XDATIM := __dDataAtu
                DA0->DA0_XHRIMP := dHoraAtu
                DA0->DA0_XUSIMP := __cUserId
			DA0->(MsUnlock())

			SZL->(DbGoTop())
            While !SZL->(EOF())

                cCampoUF := AllTrim( SZL->ZL_UF )
                cTitUF   := AllTrim( SZL->ZL__DA1UF )
                DA1->(DbGoTop())
                DA1->(DbOrderNickName("TABPROD"))
                If !DA1->(dbSeek(xFilial("DA1")+(aPreco[i][1]+aPreco[i][2])))

                    Grv_DA1N()

                Else
                    RecLock("DA1", .F.)
                    &("DA1->" + cTitUF)      := VAL(aPreco[i][4])
                    DA1->(MsUnlock())
                Endif
                
                SZL->(DbSkip())
            EndDo

            SZL->(DbCloseArea()) 

		EndIf

    Next I

	If Len(aErr) > 0
        cAviso += "Arquivo:" + Alltrim(MV_PAR12)  + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
        
        Aeval(aErr, {|x|  cAviso += x + CHAR(13) + CHAR(10)   } )
        
        EecView(cAviso, "Problemas encontrados na rotina:")
    Else
        ApMsgInfo("Não foram encontradas ocorrências de erros na importação dos dados da planilha." , FunName())   // + CRLF + "Arquivo:" + Alltrim(MV_PAR12)
    EndIf

Return()


/*/{Protheus.doc}  
@param  	Busca_Marca
@author 	A. Oliveira
@version  	P12.1.25
@since  	06/05/2022
@return  	NIL
@obs        Buscar a marca do Item da Tabela de Preços 	'HYU',  'SBR',  'CHE'
@project
@history
/*/
Static Function Busca_Marca(cProduto)
    Local _cQryM := " "

    _cQryM   := "SELECT SB1.B1_GRUPO,SBM.BM_CODMAR FROM " + RetSqlName("SB1") + " SB1"
    _cQryM   += " INNER JOIN " + RetSqlName("SBM") + " SBM"
    _cQryM   += " ON SBM.BM_FILIAL = SB1.B1_FILIAL "
    _cQryM   += " AND SBM.BM_GRUPO = SB1.B1_GRUPO  "
    _cQryM   += " AND SBM.D_E_L_E_T_ = ' ' "
    _cQryM   += " WHERE " 
    _cQryM   += "    SB1.B1_FILIAL = '" + xFilial("SB1") + "'" 
    _cQryM   += "    AND SB1.B1_COD = '" + (cProduto) + "'"  
    _cQryM   += "    AND SB1.D_E_L_E_T_ = ' ' "

    If (Select("qryMar") <> 0 )
        dbSelectArea("qryMar")
        dbCloseArea()
    Endif

    _cQryM := ChangeQuery(_cQryM)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryM),"qryMar",.T.,.T.)
    dbSelectArea("qryMar")    
    qryMar->(dbGoTop())

    While qryMar->(!Eof()) 
        _cMarca := qryMar->BM_CODMAR
        qryMar->(DbSkip()) 
    ENDDO

Return()



/*/{Protheus.doc}  
@param  	Busca_Item
@author 	A. Oliveira
@version  	P12.1.25
@since  	09/09/2021
@return  	NIL
@obs        Buscar o último Item da Tabela de Preços p/ incluir novos
@project
@history
/*/
Static Function Busca_Item()
    Local _cQry1 := " "

    cItem  := "0001"         //Definido no início do fonte que chama a função

    _cQry1   := "SELECT * FROM " + RetSqlName("DA1") 
    _cQry1   += " WHERE " 
    _cQry1   += "    DA1_ITEM = (SELECT max(DA1_ITEM) FROM " + RetSqlName("DA1") + ")"

    If (Select("qryIt") <> 0 )
        dbSelectArea("qryIt")
        dbCloseArea()
    Endif

    _cQry1 := ChangeQuery(_cQry1)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry1),"qryIt",.T.,.T.)
    dbSelectArea("qryIt")    
    qryIt->(dbGoTop())

    While qryIt->(!Eof()) 
        cItem := qryIt->DA1_ITEM
        cItem := Soma1(cItem) 
        lItem := .T. 
        qryIt->(DbSkip()) 
    ENDDO

Return()


 /*/{Protheus.doc}  
@param  	GRV_DA1N
@author 	A. Oliveira
@version  	P12.1.25
@since  	09/09/2021
@return  	NIL
@obs        Inicia  o array acampos
@project
@history
/*/  
Static Function Grv_DA1N()                 

    RecLock("DA1", .T.)
        DA1->DA1_FILIAL := xFilial("DA1")
        DA1->DA1_TIPPRE := cTpPrec
        DA1->DA1_ITEM   := cItem 
        DA1->DA1_CODTAB := (aPreco[i][1])
        DA1->DA1_CODPRO := (aPreco[i][2])
        DA1->DA1_PRCVEN := VAL(aPreco[i][4])
        DA1->DA1_ATIVO  := _cAtv
        DA1->DA1_TPOPER := cTpOper
        DA1->DA1_MOEDA  := VAL(cMoeda)
        DA1->DA1_XCDMAR := _cMarca
        DA1->DA1_DATVIG := _cDtFim
        //DA1->DA1_ESTADO := cCampoUF
        &("DA1->" + cTitUF)      := VAL(aPreco[i][4])
        DA1->DA1_XDATIM := __dDataAtu
        DA1->DA1_QTDLOT := 999999.99
        DA1->DA1_INDLOT := "000000000999999.99"
    DA1->(MsUnlock())

    lItem := .F.

Return()


/*/{Protheus.doc}  
@param  	MostraMsg 
@author 	A. Oliveira
@version  	P12.1.25
@since  	09/09/2021
@return  	NIL
@obs        Inicia  o array acampos
@project
@history
/*/
Static Function SetCampos()
    Local aRes := {}

    Aadd(aRes, {"Nr. Tabela",          "Tabela",    01})
    Aadd(aRes, {"Part Number",         "Cod",       02})
    Aadd(aRes, {"Description",         "Desc",      03})
    Aadd(aRes, {"New Price 5 Net",     "Prc",       04})

Return aRes


/*/{Protheus.doc}  
@param  	GetCp 
@author 	A. Oliveira
@version  	P12.1.25
@since  	09/09/2021
@return  	NIL
@obs        Retorna o id do array 
@project
@history
/*/
Static Function GetCp(cCampo)
    Local oVal  := Nil
    Local oHash := Nil

    oHash := AToHM( aCampos )

    HMGet(oHash, cCampo, oVal)

Return oVal[1,3]


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para tema "Flat"³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If "MP8" $ oApp:cVersion
        If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
            nTam *= 0.90
        EndIf
    EndIf
Return Int(nTam)


/*/{Protheus.doc} 
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Imprime Log das Inconsistencias encontradas
@project
@history
/*/
Static Function IMPEXC()
    Local oReport
    Private _cQuebra := " "

    If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
        oReport := ReportDef()
        oReport:nDevice := 4 //-- Gera arquivo em Planilha
        oReport:nEnvironment := 2 //-- Ambiente Local
        oReport:SetTotalInLine(.F.)
        oReport:PrintDialog()
    EndIf

Return()


/*/{Protheus.doc} 
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Impressão Log das Inconsistencias encontradas
@project
@history    
/*/
Static Function ReportDef()
    Local oReport
    Local oSection1
    
    oReport := TReport():New("IMP","Log",,{|oReport| PrintReport(oReport)},"Este relatorio irá imprimir Log")
    oSection1 := TRSection():New(oReport,OemToAnsi("Log"),{"TRB"})
 
    TRCell():New(oSection1,"STATUS","TRB7","STATUS","@!",040)
    TRCell():New(oSection1,"LOG","TRB7","LOG","@!",280)
    
    oSection1:Cell("STATUS") :SetHeaderAlign("RIGHT")
    oSection1:Cell("LOG")    :SetHeaderAlign("RIGHT")
        
Return oReport


/*/{Protheus.doc} 
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Processo de Impressão Log das Inconsistencias encontradas
@project
@history
/*/
Static Function PrintReport(oReport)

    Local oSection1 := oReport:Section(1)
    oSection1:SetTotalInLine(.F.)
    oSection1:SetTotalText("Total Geral  ")  // Imprime Titulo antes do Totalizador da Seção
    oReport:OnPageBreak(,.T.)

    DbSelectArea("TRB7")
    DbGoTop()

    oReport:SetMeter(RecCount())
    oSection1:Init()
    While  !Eof()
        If oReport:Cancel()
            Exit
        EndIf
        oSection1:PrintLine()

        DbSelectArea("TRB7")
        DbSkip()
        oReport:IncMeter()
    EndDo
    oSection1:Finish()

Return
