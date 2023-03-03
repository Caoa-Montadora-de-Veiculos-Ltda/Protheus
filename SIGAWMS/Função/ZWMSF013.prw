#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static nOperation   := 0

/*
=====================================================================================
Programa.:              ZWMSF013
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Rotina usada para inclusão das contagens do inventario           
=====================================================================================
*/
User Function ZWMSF013() //--U_ZWMSF013()
    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZZI")
    oBrowse:SetDescription("Inventario Caoa")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '0' " ,"ORANGE"   ,"Não iniciado")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '1' " ,"YELLOW"   ,"Em contagem")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '2' " ,"BLUE"     ,"Aguardando Transf. SB7")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '3' " ,"GREEN"    ,"Transferido SB7")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '4' " ,"WHITE"    ,"Parcialmente Transferido SB7")
    oBrowse:AddButton("Incluir Inventario"	    , { || FWExecView("Incluir" ,"ZWMSF014",3,,{|| .T.}) ,oBrowse:Refresh(.F.) } )
    oBrowse:AddButton("Iniciar Inventario"	    , { || zBloqArm(), oBrowse:Refresh(.F.) } ) 
    oBrowse:AddButton("Gerenciar Inventario"	, { || ZWMSF013A() ,ZF13AtuZZI(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL) ,oBrowse:Refresh(.F.) } )
    oBrowse:AddButton("Transf. SB7"	            , { || IIF( zTelaMsg() == 1,;
                                                            Processa( { || zGeraInv(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL) },;
                                                            "Lançamentos de inventario", "Aguarde .... Realizando a carga dos registros...." ),;
                                                            Nil ),;
                                                            ZF13AtuZZI(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL), oBrowse:Refresh(.F.) } )
    oBrowse:AddButton("Relatorio de Conferencia", { || u_ZWMSR002()	})                                                            
    oBrowse:AddButton("Excluir Inventario"      , { || FWExecView("Excluir" ,"ZWMSF014",5,,{|| .T.}),oBrowse:Refresh(.T.) } )
    oBrowse:DisableReport()
    oBrowse:Activate()

Return

/*
=====================================================================================
Programa.:              ZWMSF013A
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Browse da rotina gerenciar inventario
=====================================================================================
*/
Static Function ZWMSF013A()
    Local oBrwCabec

    If !(ZZI->ZZI_STATUS == '0')

        oBrwCabec := FWMBrowse():New()
        oBrwCabec:SetAlias("ZZJ")
        oBrwCabec:SetDescription( "Contagens Mestre: " + ZZI->ZZI_MESTRE + " Armazem: " + ZZI->ZZI_LOCAL )
        oBrwCabec:AddLegend("ZZJ->ZZJ_STATUS == '1' " ,"YELLOW" ,"Em contagem")
        oBrwCabec:AddLegend("ZZJ->ZZJ_STATUS == '2' " ,"BLUE"   ,"Aguardando Transf. SB7")
        oBrwCabec:AddLegend("ZZJ->ZZJ_STATUS == '3' " ,"GREEN"  ,"Transferido SB7")    
        oBrwCabec:DisableDetails()
        oBrwCabec:SetAmbiente(.F.)
        oBrwCabec:SetWalkThru(.F.)
        oBrwCabec:SetFixedBrowse(.T.)
        oBrwCabec:SetFilterDefault("@"+FilCabec(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL))
        oBrwCabec:AddButton("Importar Contagem" ,;
            { || nOperation := 3,; 
            IIF( ZZI->ZZI_STATUS != '3', zSelCSV(ZZI->ZZI_LOCAL) ,;
            MsgAlert("Este mestre esta com o status 'Transferido SB7' e não pode receber novas contagens!", "Caoa") ),;
            oBrwCabec:Refresh(.T.)	})
                                                            
        oBrwCabec:AddButton("Incluir Cont. Manual"  ,;
            { || nOperation := 3,;
            IIF( ZZI->ZZI_STATUS != '3', FWExecView("Incluir"    ,"ZWMSF013",nOperation,,{|| .T.}),;
            MsgAlert("Este mestre esta com o status 'Transferido SB7' e não pode receber novas contagens!", "Caoa") ),;
            oBrwCabec:Refresh(.F.) })
                                                            
        oBrwCabec:AddButton("Gerenciar Contagem" ,;
            { || nOperation := 4, FWExecView("Gerenciar"  ,"ZWMSF013",nOperation,,{|| .T.}),oBrwCabec:Refresh(.F.) })
                                                            
        oBrwCabec:AddButton("Excluir Contagem" ,;
            { || zDelCont(ZZJ->ZZJ_MESTRE, ZZJ->ZZJ_LOCAL, ZZJ->ZZJ_LOTE, ZZJ->ZZJ_ENDER, ZZJ->ZZJ_NUMSER, ZZJ->ZZJ_IDUNIT, ZZJ->ZZJ_PRODUT),;
            oBrwCabec:Refresh(.T.) } )

        oBrwCabec:DisableReport()
        oBrwCabec:Activate()
    
    Else
        Help( ,, "Caoa",, 'Enquanto o status estiver "Não iniciado" não é possivel a inclusão de contagens.', 1, 0,,,,,,;
                        {'Por favor, utilize o botão "Iniciar inventario" para liberação da inclusão de contagens.'} )
    EndIf

Return

/*
=======================================================================================
Programa.:              FilCabec
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Filtro do browse da rotina gerenciar inventario       
=======================================================================================
*/
Static Function FilCabec(cMestre, cLocal)
	Local cFiltro := ""

	cFiltro  +=  " ZZJ_FILIAL = '"+xFilial('ZZJ')+"'"
	cFiltro  +=  "	AND ZZJ_MESTRE = '" + cMestre + "' " + CRLF 
	cFiltro  +=  "	AND ZZJ_LOCAL = '" + cLocal + "' " + CRLF 
 	cFiltro  +=  "	AND D_E_L_E_T_ = ' ' " + CRLF

Return cFiltro

/*
=====================================================================================
Programa.:              LoadUnitz
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Inclui no modelo as quantidades dos produtos contidos no
                        unitizador conforme a tabela padrão D14 ou customizada ZZL        
=====================================================================================
*/
Static Function LoadUnitz( oModel, aDados, cMsgLog )
    Local oModelGrid    := oModel:GetModel("ZZKDETAIL")
    Local cUnitz        := PadR( aDados[6], TamSX3("ZZK_IDUNIT")[1] )
    Local lRet          := .T.
    //Local cCodEstFis    := ""
    Local cCodUni       := ""
    
    Private __cTmpQry     := GetNextAlias()

    ZZL->( DbSetOrder(1) )

    //--Consulta D14 para carregar saldo do unitizador
    zPesqD14(cUnitz)

    If Select(__cTmpQry) > 0
        DbSelectArea( __cTmpQry )
    EndIf

    If (__cTmpQry)->( !EOF() )

        While (__cTmpQry)->( !EOF() )

            oModelGrid:AddLine()

            oModelGrid:SetValue('ZZK_FILIAL'    ,FWxFilial("ZZK"))              
            oModelGrid:SetValue('ZZK_LOTE'      ,PadR( aDados[2], TamSX3("ZZK_LOTE")[1]) )
            oModelGrid:SetValue('ZZK_DTVAL'     ,SToD( aDados[3] ) )
            oModelGrid:SetValue('ZZK_ENDER'     ,PadR( aDados[4], TamSX3("ZZK_ENDER")[1]) )
            oModelGrid:SetValue('ZZK_NUMSER'    ,PadR( aDados[5], TamSX3("ZZK_NUMSER")[1]) )
            oModelGrid:SetValue('ZZK_IDUNIT'    ,(__cTmpQry)->D14_IDUNIT)
            oModelGrid:SetValue('ZZK_PRODUT'    ,(__cTmpQry)->D14_PRODUT) 
            oModelGrid:SetValue('ZZK_QTCONT'    ,(__cTmpQry)->D14_QTDEST)
            oModelGrid:SetValue('ZZK_SEGUM'     ,0 )
            oModelGrid:SetValue('ZZK_USER'      ,RetCodUsr() )

            /*Removido, não é necessario para geração do acerto
            If !Empty( oModelGrid:GetValue("ZZK_ENDER") )
                cCodEstFis  := POSICIONE("SBE",1,FWxFilial("SBE")+oModelGrid:GetValue("ZZK_LOCAL")+oModelGrid:GetValue("ZZK_ENDER"), "BE_ESTFIS")
                oModelGrid:SetValue("ZZK_TPESTR",cCodEstFis)
            EndIf
            */

            cCodUni := POSICIONE("D0Y",1,FWxFilial("D0Y")+cUnitz,"D0Y_TIPUNI")
            oModelGrid:SetValue("ZZK_CODUNI",cCodUni)

            //--Não violado, grava quantidade eleita
            oModelGrid:SetValue('ZZK_QTDELE'    ,(__cTmpQry)->D14_QTDEST )

            (__cTmpQry)->( DbSkip() )

        EndDo

        (__cTmpQry)->(DbCloseArea())

    ElseIf ZZL->( DbSeek( FWxFilial("ZZL") + cUnitz ) )

        While ZZL->( !EOF() ) .And. ZZL->ZZL_IDUNIT == cUnitz
            
            oModelGrid:AddLine()

            oModelGrid:SetValue('ZZK_FILIAL'    ,FWxFilial("ZZK"))              
            oModelGrid:SetValue('ZZK_LOTE'      ,PadR( aDados[2], TamSX3("ZZK_LOTE")[1]) )
            oModelGrid:SetValue('ZZK_DTVAL'     ,SToD( aDados[3] ) )
            oModelGrid:SetValue('ZZK_ENDER'     ,PadR( aDados[4], TamSX3("ZZK_ENDER")[1]) )
            oModelGrid:SetValue('ZZK_NUMSER'    ,PadR( aDados[5], TamSX3("ZZK_NUMSER")[1]) )
            oModelGrid:SetValue('ZZK_IDUNIT'    ,ZZL->ZZL_IDUNIT)
            oModelGrid:SetValue('ZZK_PRODUT'    ,ZZL->ZZL_PRODUT) 
            oModelGrid:SetValue('ZZK_QTCONT'    ,ZZL->ZZL_QTCONT)
            oModelGrid:SetValue('ZZK_SEGUM'     ,0 )
            oModelGrid:SetValue('ZZK_USER'      ,RetCodUsr() )

            /*Removido, não é necessario para geração do acerto
            If !Empty( oModelGrid:GetValue("ZZK_ENDER") )
                cCodEstFis  := POSICIONE("SBE",1,FWxFilial("SBE")+oModelGrid:GetValue("ZZK_LOCAL")+oModelGrid:GetValue("ZZK_ENDER"), "BE_ESTFIS")
                oModelGrid:SetValue("ZZK_TPESTR",cCodEstFis)
            EndIf
            */

            cCodUni := POSICIONE("D0Y",1,FWxFilial("D0Y")+cUnitz,"D0Y_TIPUNI")
            oModelGrid:SetValue("ZZK_CODUNI",cCodUni)

            //--Não violado, grava quantidade eleita
            oModelGrid:SetValue('ZZK_QTDELE'    ,ZZL->ZZL_QTCONT )

            ZZL->( DbSkip() )
        EndDo

    Else
        cMsgLog := 'Falha na localização dos itens do unitizador: ' + cUnitz
        lRet := .F.
    EndIf

    If Select(__cTmpQry) > 0
        (__cTmpQry)->(DbCloseArea())
    EndIf

Return lRet

/*
=====================================================================================
Programa.:              zUltCont
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Retorna o valor da quantidade eleita da ultima contagem   
=====================================================================================
*/
Static Function zUltCont( cMestre, cLocal, cLote, cEndereco, cNumSer, cIDUnit, cProduto, lContZero, nRecnoZZK )
    Local nUltimaQtd := 0

    //--Busca pela ultima contagem
    cAliasQtd := GetNextAlias()
    BeginSql Alias cAliasQtd
        SELECT ZZK_QTDELE, ZZK_CONTAG, ZZK_QTCONT, R_E_C_N_O_ AS ZZKRECNO
        FROM %Table:ZZK% ZZK
        WHERE ZZK.ZZK_FILIAL    = %xFilial:ZZK%
            AND ZZK.ZZK_MESTRE  = %Exp:cMestre%
            AND ZZK.ZZK_LOCAL   = %Exp:cLocal%
            AND ZZK.ZZK_LOTE    = %Exp:cLote%
            AND ZZK.ZZK_ENDER   = %Exp:cEndereco%
            AND ZZK.ZZK_NUMSER  = %Exp:cNumSer%
            AND ZZK.ZZK_IDUNIT  = %Exp:cIDUnit%
            AND ZZK.ZZK_PRODUT  = %Exp:cProduto%
            AND ZZK_CONTAG = (  SELECT MAX(ZZK_CONTAG)
                                FROM %Table:ZZK% ZZKB 
                                WHERE ZZKB.ZZK_FILIAL   = %xFilial:ZZK%
                                    AND ZZKB.ZZK_MESTRE = %Exp:cMestre%
                                    AND ZZKB.ZZK_LOCAL  = %Exp:cLocal%
                                    AND ZZKB.ZZK_LOTE   = %Exp:cLote%
                                    AND ZZKB.ZZK_ENDER  = %Exp:cEndereco%
                                    AND ZZKB.ZZK_NUMSER = %Exp:cNumSer%
                                    AND ZZKB.ZZK_IDUNIT = %Exp:cIDUnit%
                                    AND ZZKB.ZZK_PRODUT = %Exp:cProduto%
                                    AND ZZKB.%NotDel%    )
            AND ZZK.%NotDel%
    EndSql

    If (cAliasQtd)->( !Eof() )
        
        //-- Grava quantidade eleita da ultima contagem
        nUltimaQtd  := (cAliasQtd)->ZZK_QTDELE
        nRecnoZZK   := (cAliasQtd)->ZZKRECNO
        
        /*
        Validação necessaria porque a rotina de geração de contagens zeradas possui esse comportamento e sempre
        que houver contagem com valor zero, essa sera definida como eleita até que ocorram novas contagens, 
        se não ocorrerem, a contagem com valor zero sera gravada na SB7 ao rodar a rotina Transf. SB7
        */
        If /*(cAliasQtd)->ZZK_CONTAG == '001' .And.*/ (cAliasQtd)->ZZK_QTCONT = 0
            lContZero := .T.
        EndIf
    EndIf

    (cAliasQtd)->( DbCloseArea() )

Return nUltimaQtd

/*
=====================================================================================
Programa.:              ZF13Cont
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Retorna sequencia da contagem     
=====================================================================================
*/
Static Function ZF13Cont()
    Local oModel        := FWModelActive()
    Local oModelGrid    := oModel:GetModel("ZZKDETAIL")
    Local cAliasQry     := GetNextAlias()
    Local cQuery        := ""
    Local cQtd          := ""

	cQuery += 	" SELECT MAX(ZZK_CONTAG) AS QTDCONT " + CRLF
	cQuery += 	" FROM "+ RetSqlName("ZZK") + " ZZK " + CRLF
	cQuery += 	" WHERE ZZK_FILIAL = '" + FWxFilial("ZZK") + "' " + CRLF
    cQuery += 		" AND ZZK_MESTRE = '" + oModelGrid:GetValue("ZZK_MESTRE") + "' " + CRLF
    cQuery += 		" AND ZZK_LOCAL = '" + oModelGrid:GetValue("ZZK_LOCAL") + "' " + CRLF
    cQuery += 		" AND ZZK_LOTE = '" + oModelGrid:GetValue("ZZK_LOTE") + "' " + CRLF
    cQuery += 		" AND ZZK_ENDER = '" + oModelGrid:GetValue("ZZK_ENDER") + "' " + CRLF
    cQuery += 		" AND ZZK_NUMSER = '" + oModelGrid:GetValue("ZZK_NUMSER") + "' " + CRLF
    cQuery += 		" AND ZZK_IDUNIT = '" + oModelGrid:GetValue("ZZK_IDUNIT") + "' " + CRLF
    cQuery += 		" AND ZZK_PRODUT = '" + oModelGrid:GetValue("ZZK_PRODUT") + "' " + CRLF
    cQuery += 		" AND ZZK.D_E_L_E_T_ = ' ' " + CRLF

    cQuery := ChangeQuery(cQuery)

   	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T. )

	DbSelectArea( cAliasQry )
	If (cAliasQry)->( !EOF() )
        cQtd := PadL( (cAliasQry)->QTDCONT, TamSX3("ZZK_CONTAG")[1], "0")
    EndIf

    (cAliasQry)->(DbCloseArea())

Return Soma1( cQtd )

/*
=====================================================================================
Programa.:              ZF13QtdEle
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Valida se atingiu a quantidade eleita e retorna o valor         
=====================================================================================
*/
Static Function ZF13QtdEle()
    Local oModel        := FWModelActive()
    Local oModelGrid    := oModel:GetModel("ZZKDETAIL")
    Local nQtdEle       := 0

    cAliasQry := GetNextAlias()
    BeginSql Alias cAliasQry
        SELECT ZZK_QTCONT
        FROM %Table:ZZK% ZZK
        WHERE ZZK.ZZK_FILIAL = %xFilial:ZZK%
            AND ZZK.ZZK_MESTRE = %Exp:oModelGrid:GetValue("ZZK_MESTRE")%
            AND ZZK.ZZK_LOCAL = %Exp:oModelGrid:GetValue("ZZK_LOCAL")%
            AND ZZK.ZZK_LOTE = %Exp:oModelGrid:GetValue("ZZK_LOTE")%
            AND ZZK.ZZK_ENDER = %Exp:oModelGrid:GetValue("ZZK_ENDER")%
            AND ZZK.ZZK_NUMSER = %Exp:oModelGrid:GetValue("ZZK_NUMSER")%
            AND ZZK.ZZK_IDUNIT = %Exp:oModelGrid:GetValue("ZZK_IDUNIT")%
            AND ZZK.ZZK_PRODUT = %Exp:oModelGrid:GetValue("ZZK_PRODUT")%
            AND ZZK.%NotDel%
    EndSql
    
    If (cAliasQry)->(!Eof())
        
        While (cAliasQry)->( !Eof() )

            If oModelGrid:GetValue("ZZK_QTCONT") == (cAliasQry)->ZZK_QTCONT
                nQtdEle := (cAliasQry)->ZZK_QTCONT
                Exit
            EndIf

            (cAliasQry)->( DbSkip() )
        EndDo

    EndIf

    (cAliasQry)->(DbCloseArea())

Return nQtdEle

/*
=====================================================================================
Programa.:              ModelDef
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Model
=====================================================================================
*/
Static Function ModelDef()
    Local oModel        := Nil
    // Estrutura Fake de Field
    Local oStrFake      := FWFormModelStruct():New()
    //Estrutura de Grid, alias Real presente no dicionário de dados
    Local oGridZZK      := FWFormStruct(1, "ZZK")
    Local nI            := 0                    

    oStrFake:addTable("", {"C_STRING1"}, "Contagens", {|| ""})
    oStrFake:addField("String 01", "Campo de texto", "C_STRING1", "C", 15)

    oModel := MPFormModel():New("WMSF013MDL",/*bPre*/, {|oModel| zValidMdl(oModel) },{|oModel| CommitMdl(oModel) },/*bCancel*/)

    oGridZZK:SetProperty('ZZK_MESTRE'   ,MODEL_FIELD_INIT   ,{||  ZZI->ZZI_MESTRE   } )
    oGridZZK:SetProperty('ZZK_LOCAL'    ,MODEL_FIELD_INIT   ,{||  ZZI->ZZI_LOCAL    } )
    oGridZZK:SetProperty('ZZK_DATA'     ,MODEL_FIELD_INIT   ,{||  ZZI->ZZI_DATA     } )
    oGridZZK:SetProperty('ZZK_USER'     ,MODEL_FIELD_INIT   ,{||  RetCodUsr()       } )
    oGridZZK:SetProperty('ZZK_STATUS'   ,MODEL_FIELD_INIT   ,{||  '1'               } ) //--Em contagem

    //--Não carrega o valid se a inclusão for via arquivo CSV ou bloqueio de movimentos
    If !( IsInCallStack("zImpCSV") ) .And. !( IsInCallStack("zProcBloq") )
        oGridZZK:SetProperty('ZZK_PRODUT'   ,MODEL_FIELD_VALID  ,{ | oModel | ValidProd( oModel ) } )
    EndIf

    //Seta campos que não podem ser editados em uma alteração
    For nI := 1 To Len(oGridZZK:aFields)
        If !(oGridZZK:aFields[nI][3] $ "ZZK_QTCONT|ZZK_QTDELE")
            oGridZZK:SetProperty(oGridZZK:aFields[nI][3],MODEL_FIELD_NOUPD  , .T.)
        EndIf
    Next nI

    oModel:AddFields("ZZJMASTER",/*cOwner*/,oStrFake,/*bPre*/,/*bPost*/,{ || {""} })
    oModel:AddGrid('ZZKDETAIL','ZZJMASTER',oGridZZK,/*bLinePre*/,{|oModel|zPoslinVal(oModel)},/*bPre*/,/*bPost*/,;
        {|oModel| LoadGrid(oModel, ZZJ->ZZJ_MESTRE, ZZJ->ZZJ_LOCAL, ZZJ->ZZJ_LOTE, ZZJ->ZZJ_ENDER, ZZJ->ZZJ_NUMSER, ZZJ->ZZJ_IDUNIT, ZZJ->ZZJ_PRODUT  )})

    oModel:SetPrimaryKey({})
    
    // É necessário que haja alguma alteração na estrutura Field
    oModel:setActivate({ |oModel| onActivate(oModel)})

Return oModel

/*
=====================================================================================
Programa.:              ViewDef
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   View
=====================================================================================
*/
Static Function ViewDef()
    Local oModel        := ModelDef()
    // Estrutura Fake de Field
    Local oStrFake      := FWFormViewStruct():New()
    Local oGridZZK      := FWFormStruct(2, "ZZK")
    Local oView         := Nil
    Local nI            := 0

    oStrFake:addField("C_STRING1", "01" , "String 01", "Campo de texto", , "C" )

    //-- Cria View e seta o modelo de dados
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //-- Add cabeçalho e grid
	oView:AddField('VIEW_CAB',oStrFake,'ZZJMASTER')
    oView:AddGrid('VIEW_GRID',oGridZZK,'ZZKDETAIL')

    //--Remove campos do grid para inclusão
    //--Campos ZZK_TPESTR/ZZK_CODUNI serão gravados no commit
    /*--Campo ZZK_IDUNIT somente sera usado nas inclusões via arquivo CSV,
    isso porque é necessario adicionar os itens do unitizador de forma automatica.*/ 
    If nOperation == MODEL_OPERATION_INSERT
        For nI := 1 To Len(oGridZZK:aFields)
            If nI > Len(oGridZZK:aFields)
				Exit
			EndIf
			// Campos que não podem aparecer em tela
			If oGridZZK:aFields[nI][1] $ "ZZK_TPESTR/ZZK_CODUNI/ZZK_IDUNIT"
				oGridZZK:RemoveField(oGridZZK:aFields[nI][1])
			EndIf
		Next nI
    EndIf

    //--Não permite a inclusão de novas linhas no grid quando for alteração
    If nOperation == MODEL_OPERATION_UPDATE
        oView:SetNoInsertLine('VIEW_GRID')
    EndIf

    oView:CreateHorizontalBox('SZO_DADOS',0)
    oView:CreateHorizontalBox('TRANSF_DADOS',100)

    //--Amarra a view com as box
    oView:SetOwnerView('VIEW_CAB','SZO_DADOS')
    oView:SetOwnerView('VIEW_GRID','TRANSF_DADOS')

Return oView

/*
=====================================================================================
Programa.:              onActivate
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Atribui conteudo a um campo da tabela fake          
=====================================================================================
*/
Static function onActivate(oModel)

    //Só efetua a alteração do campo para inserção
    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        FwFldPut("C_STRING1", "FAKE" , /*nLinha*/, oModel)
    EndIf

Return

/*
=====================================================================================
Programa.:              zValidMdl
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Pós validação do modelo      
=====================================================================================
*/
Static Function zValidMdl(oModel)
    Local oModelGrid    := oModel:GetModel("ZZKDETAIL")
    Local nI            := 0
    Local cAliasQry     := ""
    Local lRet          := .T.

    cAliasQry := GetNextAlias()
    BeginSql Alias cAliasQry
        SELECT 1
        FROM %Table:ZZK% ZZK
        WHERE ZZK.ZZK_FILIAL = %xFilial:ZZK%
            AND ZZK.ZZK_MESTRE = %Exp:oModelGrid:GetValue("ZZK_MESTRE")%
            AND ZZK.ZZK_LOCAL = %Exp:oModelGrid:GetValue("ZZK_LOCAL")%
            AND ZZK.ZZK_LOTE = %Exp:oModelGrid:GetValue("ZZK_LOTE")%
            AND ZZK.ZZK_ENDER = %Exp:oModelGrid:GetValue("ZZK_ENDER")%
            AND ZZK.ZZK_NUMSER = %Exp:oModelGrid:GetValue("ZZK_NUMSER")%
            AND ZZK.ZZK_IDUNIT = %Exp:oModelGrid:GetValue("ZZK_IDUNIT")%
            AND ZZK.ZZK_PRODUT = %Exp:oModelGrid:GetValue("ZZK_PRODUT")%
            AND ZZK.ZZK_STATUS = %Exp:'3'%
            AND ZZK.%NotDel%
    EndSql

    If (cAliasQry)->(!Eof())

        For nI := 1 To oModelGrid:Length()
            If oModelGrid:IsDeleted(nI)
                Help( ,, "Caoa",, 'Não é possivel a exclusão de registros com status "Transferido SB7"!', 1, 0 )
                lRet := .F.
                Exit                
            EndIf
        Next

    EndIf

    (cAliasQry)->(DbCloseArea())

Return lRet

/*
=====================================================================================
Programa.:              CommitMdl
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Realiza commit do modelo           
=====================================================================================
*/
Static Function CommitMdl( oModel )
    Local aAreaZZJ      := ZZJ->( GetArea() )
    Local oModelGrid    := oModel:GetModel("ZZKDETAIL")
    Local nI            := 0
    Local cMestre       := ""
    Local cLocal        := ""
    Local cLote         := ""
    Local cNumSer       := ""
    Local cIDUnit       := ""
    Local cProduto      := ""
    Local lRet          := .T.
    Local cEndereco     := ""
    Local cAliasQry     := ""
    Local nCont         := 0
    Local nRecZZK       := 0
    Local lContZero     := .F.
    Local nRecnoZZK     := 0

    //--Ativa Workarea
    ZZJ->( DbSetOrder(1) )

    //--Gravações complementares antes do commit, se não houver unitizador informado
    //--O campo gravado abaixo não passa por validações, portanto não invalida o modelo
    /*Removido, não é necessario para geração do acerto
    If Empty( oModelGrid:GetValue("ZZK_IDUNIT") ) .And. Empty( oModelGrid:GetValue("ZZK_TPESTR") )
        For nI := 1 To oModelGrid:Length()

            If oModelGrid:IsDeleted(nI)
                Loop
            EndIf

            If !Empty( oModelGrid:GetValue("ZZK_ENDER") )
                cCodEstFis  := POSICIONE("SBE",1,FWxFilial("SBE")+oModelGrid:GetValue("ZZK_LOCAL")+oModelGrid:GetValue("ZZK_ENDER"), "BE_ESTFIS")
                oModelGrid:SetValue("ZZK_TPESTR",cCodEstFis)
            EndIf

        Next
    EndIf
    */

    //--Faz o commit do modelo 
    lRet := FWFormCommit( oModel )

    If lRet

        For nI := 1 To oModelGrid:Length()

            //--Faz a limpeza da quantidade eleita quando houver deleção da contagem
            If oModelGrid:IsDeleted(nI)
                
                //--Posiciona no grid
                oModelGrid:GoLine(nI)

                cAliasRec  := GetNextAlias()
                BeginSql Alias cAliasRec
                    SELECT R_E_C_N_O_ AS RECZZK, ZZK_QTDELE
                    FROM %Table:ZZK% ZZK
                    WHERE ZZK.ZZK_FILIAL = %xFilial:ZZK%
                        AND ZZK.ZZK_MESTRE = %Exp:oModelGrid:GetValue("ZZK_MESTRE")%
                        AND ZZK.ZZK_LOCAL = %Exp:oModelGrid:GetValue("ZZK_LOCAL")%
                        AND ZZK.ZZK_LOTE = %Exp:oModelGrid:GetValue("ZZK_LOTE")%
                        AND ZZK.ZZK_ENDER = %Exp:oModelGrid:GetValue("ZZK_ENDER")%
                        AND ZZK.ZZK_NUMSER = %Exp:oModelGrid:GetValue("ZZK_NUMSER")%
                        AND ZZK.ZZK_IDUNIT = %Exp:oModelGrid:GetValue("ZZK_IDUNIT")%
                        AND ZZK.ZZK_PRODUT = %Exp:oModelGrid:GetValue("ZZK_PRODUT")%
                        AND ZZK.ZZK_QTDELE <> %Exp:0%
                        AND ZZK.%NotDel%
                EndSql

                If (cAliasRec)->(!Eof())
                    nRecZZK := (cAliasRec)->RECZZK
                    nQtdEle := (cAliasRec)->ZZK_QTDELE

                    cAliasQtd   := GetNextAlias()
                    BeginSql Alias cAliasQtd
                        SELECT ZZK_QTCONT
                        FROM %Table:ZZK% ZZK
                        WHERE ZZK.ZZK_FILIAL = %xFilial:ZZK%
                            AND ZZK.ZZK_MESTRE = %Exp:oModelGrid:GetValue("ZZK_MESTRE")%
                            AND ZZK.ZZK_LOCAL = %Exp:oModelGrid:GetValue("ZZK_LOCAL")%
                            AND ZZK.ZZK_LOTE = %Exp:oModelGrid:GetValue("ZZK_LOTE")%
                            AND ZZK.ZZK_ENDER = %Exp:oModelGrid:GetValue("ZZK_ENDER")%
                            AND ZZK.ZZK_NUMSER = %Exp:oModelGrid:GetValue("ZZK_NUMSER")%
                            AND ZZK.ZZK_IDUNIT = %Exp:oModelGrid:GetValue("ZZK_IDUNIT")%
                            AND ZZK.ZZK_PRODUT = %Exp:oModelGrid:GetValue("ZZK_PRODUT")%
                            AND ZZK.%NotDel%
                    EndSql
                    
                    If (cAliasQtd)->(!Eof())
                        
                        (cAliasQtd)->( DbGoTop() )
                        While (cAliasQtd)->(!Eof())

                            If (cAliasQtd)->ZZK_QTCONT == nQtdEle
                                nCont++
                            EndIf

                            (cAliasQtd)->( DbSkip() )
                        EndDo

                        If nCont < 2
                            ZZK->( DbGoTo( nRecZZK ) )
                            RecLock("ZZK", .F.)
                            ZZK->ZZK_QTDELE := 0
                            ZZK->ZZK_STATUS := '1' //--Em Contagem
                            ZZK->( MsUnLock() )
                        EndIf

                    EndIf
                    (cAliasQtd)->(DbCloseArea())

                EndIf
                (cAliasRec)->(DbCloseArea())

                Loop
            EndIf

            //--Posiciona no grid
            oModelGrid:GoLine(nI)

            cMestre     := oModelGrid:GetValue("ZZK_MESTRE")
            cLocal      := oModelGrid:GetValue("ZZK_LOCAL")
            cLote       := oModelGrid:GetValue("ZZK_LOTE")
            cEndereco   := oModelGrid:GetValue("ZZK_ENDER")
            cNumSer     := oModelGrid:GetValue("ZZK_NUMSER")
            cIDUnit     := oModelGrid:GetValue("ZZK_IDUNIT")
            cProduto    := oModelGrid:GetValue("ZZK_PRODUT")

            cAliasQry   := GetNextAlias()
            BeginSql Alias cAliasQry
                SELECT R_E_C_N_O_ AS RECZZJ
                FROM %Table:ZZJ% ZZJ
                WHERE ZZJ.ZZJ_FILIAL = %xFilial:ZZJ%
                    AND ZZJ.ZZJ_MESTRE = %Exp:cMestre%
                    AND ZZJ.ZZJ_LOCAL = %Exp:cLocal%
                    AND ZZJ.ZZJ_LOTE = %Exp:cLote%
                    AND ZZJ.ZZJ_ENDER = %Exp:cEndereco%
                    AND ZZJ.ZZJ_NUMSER = %Exp:cNumSer%
                    AND ZZJ.ZZJ_IDUNIT = %Exp:cIDUnit%
                    AND ZZJ.ZZJ_PRODUT = %Exp:cProduto%
                    AND ZZJ.%NotDel%
            EndSql
            
            //--Se não encontrar, realiza a inclusão
            If (cAliasQry)->( !Eof() )
                
                //--Busca ultima contagem para verificar se é eleita
                nQtdEle := zUltCont( cMestre, cLocal, cLote, cEndereco, cNumSer, cIDUnit, cProduto, @lContZero, @nRecnoZZK )

                ZZJ->( DbGoTo( (cAliasQry)->RECZZJ ) )
                If !( ZZJ->ZZJ_STATUS == '3')

                    //--Valida se produto ja possui quantidade eleita
                    RecLock("ZZJ", .F.)
                    ZZJ->ZZJ_STATUS := IIF( nQtdEle <> 0 .Or. lContZero, '2', '1')
                    ZZJ->( MsUnlock() )

                    ZZK->( DbGoTo( nRecnoZZK ) )
                    RecLock("ZZK",.F.)
                    ZZK->ZZK_STATUS := IIF( nQtdEle <> 0 .Or. lContZero, '2', '1')
                    ZZK->( MsUnlock() )

                EndIf

            Else

                //--Busca ultima contagem para verificar se é eleita
                nQtdEle := zUltCont( cMestre, cLocal, cLote, cEndereco, cNumSer, cIDUnit, cProduto, @lContZero, @nRecnoZZK )

                RecLock("ZZJ",.T.)
                ZZJ->ZZJ_FILIAL := FWxFilial("ZZJ")
                ZZJ->ZZJ_MESTRE := cMestre
                ZZJ->ZZJ_LOCAL  := cLocal
                ZZJ->ZZJ_LOTE   := cLote
                ZZJ->ZZJ_ENDER  := cEndereco
                ZZJ->ZZJ_NUMSER := cNumSer
                ZZJ->ZZJ_IDUNIT := cIDUnit
                ZZJ->ZZJ_PRODUT := cProduto
                ZZJ->ZZJ_STATUS := IIF( nQtdEle <> 0 .Or. lContZero, '2', '1')
                ZZJ->( MsUnlock() )

                ZZK->( DbGoTo( nRecnoZZK ) )
                RecLock("ZZK",.F.)
                ZZK->ZZK_STATUS := IIF( nQtdEle <> 0 .Or. lContZero, '2', '1')
                ZZK->( MsUnlock() )

            EndIf

            (cAliasQry)->(DbCloseArea())
        Next

    EndIf

    RestArea( aAreaZZJ )
Return lRet

/*
=====================================================================================
Programa.:              ValidProd
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Validações dos itens        
=====================================================================================
*/
Static Function ValidProd(oModelGrid)
    Local lRet := .T.

    SB1->( DbSetOrder(1) )
    If SB1->( DbSeek( FWxFilial("SB1") + oModelGrid:GetValue("ZZK_PRODUT") ) )

        //--Verifica se possui controle de lote
        If SB1->B1_RASTRO == 'L'
            
            //--Obriga o preenchimento do campo lote
            If Empty( oModelGrid:GetValue("ZZK_LOTE") )
                lRet := .F.
                Help( ,, "Caoa",, "Produto " + AllTrim(oModelGrid:GetValue("ZZK_PRODUT") ) +;
                                    " possui controle de lote, por favor preencher o campo Lote!" , 1, 0 ) 
            EndIf

        EndIf

        //--Obriga o preenchimento do campo lote
        If SB1->B1_LOCALIZ == 'S'
            If Empty( oModelGrid:GetValue("ZZK_ENDER") )
                lRet := .F.
                Help( ,, "Caoa",, "Produto " + AllTrim(oModelGrid:GetValue("ZZK_PRODUT") ) +;
                                    " possui controle de endereço, por favor preencher o campo Endereço!" , 1, 0 ) 
            EndIf
        EndIf

    Else
        lRet := .F.
        Help( ,, "Caoa",, "Produto " + AllTrim(oModelGrid:GetValue("ZZK_PRODUT") ) +;
                            ", não foi localizado no cadastro de produtos!" , 1, 0 ) 
    EndIf

Return lRet

/*
=====================================================================================
Programa.:              zSelCSV
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Seleciona arquivo CSV para importação das contagens       
=====================================================================================
*/
Static Function zSelCSV(cLocal)
    Local cTitulo1  := "Selecione o arquivo para Carga "
    Local cExtens   := "Arquivo CSV | *.CSV"
    Local cMainPath := "C:\"
    Local cFileOpen := ""

    If U_ZGENUSER( RetCodUsr() ,"ZWMSF013" ,.T.)
    
        cFileOpen := cGetFile(cExtens,cTitulo1,,cMainPath,.T.)
        If File(cFileOpen)
            Processa({|| zImpCSV(cFileOpen, cLocal) }, "[ZWMSF013] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." ) 
        Endif

    EndIf

Return

/*
=====================================================================================
Programa.:              zImpCSV
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Processamento do arquivo CSV   
=====================================================================================
*/
Static Function zImpCSV(cFileOpen, cLocal)
    Local oModel        := ModelDef()
    Local oModelGrid    := oModel:GetModel("ZZKDETAIL")
    Local cLinha        := ""
    Local cSeparador	:= ";"
    Local aDados 		:= {}
    Local cArqLog       := SubStr(AllTrim(cFileOpen),1,At(".csv",cFileOpen))+"_log_"+StrTran(AllTrim(Time()),":","")+"_.csv"
    Local cLog          := ""
    Local lRet          := .F.
    Local nCont         := 0
    Local cMsgLog       := ""
    Local lErro         := .F.
    Local lGrvLog       := .T.

    FT_FUSE(cFileOpen)
    FT_FGOTOP()
    FT_FSKIP()

    ProcRegua( FT_FLASTREC() )

    Begin Transaction        
        While !FT_FEOF()
            
            nCont++

            cLinha := FT_FREADLN()
                            
            aDados := Separa(cLinha,cSeparador)

            // Incrementa a mensagem na régua.
            IncProc("Efetuando a gravação dos registros!")

            If AllTrim( aDados[1] ) != AllTrim(cLocal)
                cLog := "Local informado na planilha não corresponde ao armazem do mestre selecionado!"
                
                lErro := .T.

                //--Se não conseguir gerar arquivo de log, encerra a leitura do CSV
                If !GrvLog(cArqLog, cLog)
                    lGrvLog := .F.
                    Exit
                EndIf

                FT_FSKIP(1)
                Loop
            EndIf

            //Ativando o modelo
            oModel:SetOperation(3)
            oModel:Activate()

            cMsgLog := ""

            /*
            Condição removida por solicitação do Natâ e Wallison em 18/06/2021,
            os unitizadores violados receberão a quantidade da contagem via planilha
            */
            //If !Empty( aDados[6] ) .And. !Empty( aDados[7] ) //--Violado
            //    lRet    := LoadUnitz(oModel, .T., aDados, @cMsgLog)
            
            If !Empty( aDados[6] ) .And. Empty( aDados[7] ) //--Não violado
                lRet    := LoadUnitz(oModel, aDados, @cMsgLog)
            Else
                lRet := .T.

                // Carga dos dados
                oModelGrid:SetValue('ZZK_FILIAL'    ,FWxFilial("ZZK"))              
                oModelGrid:SetValue('ZZK_LOTE'      ,PadR( aDados[2], TamSX3("ZZK_LOTE")[1]) )
                oModelGrid:SetValue('ZZK_DTVAL'     ,SToD( aDados[3] ) )
                oModelGrid:SetValue('ZZK_ENDER'     ,PadR( aDados[4], TamSX3("ZZK_ENDER")[1]) )
                oModelGrid:SetValue('ZZK_NUMSER'    ,PadR( aDados[5], TamSX3("ZZK_NUMSER")[1]) )
                oModelGrid:SetValue('ZZK_IDUNIT'    ,PadR( aDados[6], TamSX3("ZZK_IDUNIT")[1]) )
                oModelGrid:SetValue('ZZK_PRODUT'    ,PadR( aDados[7], TamSX3("ZZK_PRODUT")[1]) ) 
                oModelGrid:SetValue('ZZK_QTCONT'    ,Val( aDados[8]) )
                oModelGrid:SetValue('ZZK_SEGUM'     ,0 )
                oModelGrid:SetValue('ZZK_USER'      ,RetCodUsr() )
            EndIf

            If lRet
                
                If ( lRet := oModel:VldData() )

                    oModel:CommitData()
                        
                EndIf

                If !lRet

                    // Se os dados não foram validados obtemos a descrição do erro para gerar
                    // A estrutura do vetor com erro é:
                    // [1] identificador (ID) do formulário de origem
                    // [2] identificador (ID) do campo de origem
                    // [3] identificador (ID) do formulário de erro
                    // [4] identificador (ID) do campo de erro
                    // [5] identificador (ID) do erro
                    // [6] mensagem do erro
                    // [7] mensagem da solução
                    // [8] Valor atribuído
                    // [9] Valor anterior

                    lErro := .T.

                    aErro := oModel:GetErrorMessage()

                    cLog := "Linha: " + Soma1( cValToChar(nCont) ) + CRLF + AllToChar( aErro[6] )

                    //--Se não conseguir gerar arquivo de log, encerra a leitura do CSV
                    If !GrvLog(cArqLog, cLog)
                        lGrvLog := .F.
                        Exit
                    EndIf

                EndIf 
            
            Else

                lErro := .T.

                //--Se não conseguir gerar arquivo de log, encerra a leitura do CSV
                If !GrvLog(cArqLog, cMsgLog)
                    lGrvLog := .F.
                    Exit
                EndIf

            EndIf

            // Desativando o modelo para o proximo registro
            oModel:DeActivate()
            
            FT_FSKIP(1)
        
        END

        If lErro

            If lGrvLog
                MsgAlert("Falha na importação dos registros, por favor, consulte arquivo de log!", "Caoa")
            EndIf

            Disarmtransaction()
        EndIf

    End Transaction

    //--Fecha arquivo
    FT_FUSE()

Return

/*
=====================================================================================
Programa.:              zTelaMsg
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Tela de apresentação da rotina de geração de inventario SB7
=====================================================================================
*/
Static Function zTelaMsg()
    Local aSays     := {}
    Local aButtons  := {} 
    Local cCadastro := "Geração de lançamentos de inventario"
    Local nOpcA     := 0

    AADD(aSays,"Este programa tem o objetivo de realizar a geração de lançamentos de inventario.")
    AADD(aSays,"Clique em OK para confirmar a transferencia das contagens para tabela SB7.")

    AADD(aButtons, { 1,.T.,{|o| nOpca := 1, o:oWnd:End() }} )
    AADD(aButtons, { 2,.T.,{|o| nOpca := 2, o:oWnd:End() }} )
                
    FormBatch( cCadastro, aSays, aButtons )

Return nOpcA

/*
=====================================================================================
Programa.:              zGeraInv
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Geração de lançamentos de inventario 
=====================================================================================
*/
Static Function zGeraInv(cMestre, cLocal)
    Local cAliasQry := GetNextAlias()
    Local cQuery	:= ""
	Local cError	:= ""
	Local nI		:= 0
	Local aInvent	:= {}
	Local aAutoErro	:= {}
    Local nGerou    := 0
    Local nFalhou   := 0
    Local nOpcFile	:= GETF_LOCALHARD+GETF_RETDIRECTORY+GETF_NETWORKDRIVE

	Private nHdl			:= 0
    Private cPath           := ""
    Private lAutoErrNoFile  := .T. //-- Necessario inicializar para utilização da função GetAutoGRLog()
    Private lMsErroAuto     := .F.
    Private cAliasSB7       := GetNextAlias()

    cQuery := " SELECT TMPZZJ.ZZJ_FILIAL, TMPZZJ.ZZJ_MESTRE, TMPZZJ.ZZJ_LOCAL, TMPZZJ.ZZJ_LOTE, " + CRLF 
    cQuery += "  TMPZZJ.ZZJ_ENDER, TMPZZJ.ZZJ_NUMSER, TMPZZJ.ZZJ_IDUNIT, TMPZZJ.ZZJ_PRODUT,   " + CRLF 
    cQuery += " TMPZZJ.ZZJ_STATUS, TMPZZJ.RECZZJ, ZZK.ZZK_QTCONT, ZZK.ZZK_SEGUM, ZZK.ZZK_SUBLOT, " + CRLF 
    cQuery += " ZZK.ZZK_DTVAL, ZZK.ZZK_CONTAG, ZZK.ZZK_CODUNI, ZZK.R_E_C_N_O_ AS RECZZK, ZZK.ZZK_DATA " + CRLF 
    cQuery += " FROM ( " + CRLF 
    cQuery += " SELECT ZZJ_FILIAL, ZZJ_MESTRE, ZZJ_LOCAL, ZZJ_LOTE, ZZJ_ENDER, ZZJ_NUMSER, ZZJ_IDUNIT, " + CRLF 
    cQuery += "  ZZJ_PRODUT, ZZJ_STATUS, ZZJ.R_E_C_N_O_ AS RECZZJ " + CRLF 
    cQuery += "  FROM " + RetSQLName("ZZI") + " ZZI " + CRLF
    cQuery += "  JOIN " + RetSQLName("ZZJ") + " ZZJ " + CRLF
    cQuery += "   ON ZZJ.ZZJ_FILIAL = ZZI.ZZI_FILIAL " + CRLF
    cQuery += "   AND ZZJ.ZZJ_MESTRE = ZZI.ZZI_MESTRE " + CRLF
    cQuery += "   AND ZZJ.ZZJ_LOCAL = ZZI.ZZI_LOCAL " + CRLF
    cQuery += "   AND ZZJ.ZZJ_STATUS = '2' " + CRLF
    cQuery += "   AND ZZJ.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  WHERE ZZI.ZZI_FILIAL = '" + FWxFilial("ZZI") + "' " + CRLF
    cQuery += "   AND ZZI.ZZI_STATUS IN('2','4') " + CRLF
    cQuery += "  AND ZZI.ZZI_MESTRE = '" + cMestre + "' " + CRLF
    cQuery += "  AND ZZI.ZZI_LOCAL = '" + cLocal + "' " + CRLF
    cQuery += "   AND ZZI.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  GROUP BY ZZJ_FILIAL, ZZJ_MESTRE, ZZJ_LOCAL, ZZJ_LOTE, ZZJ_ENDER, ZZJ_NUMSER, ZZJ_IDUNIT, " + CRLF
    cQuery += "   ZZJ_PRODUT, ZZJ_STATUS, ZZJ.R_E_C_N_O_ " + CRLF
    cQuery += "  ORDER BY ZZJ_FILIAL, ZZJ_MESTRE, ZZJ_LOCAL, ZZJ_LOTE, ZZJ_ENDER, ZZJ_NUMSER, ZZJ_IDUNIT, " + CRLF
    cQuery += "  ZZJ_PRODUT ) TMPZZJ " + CRLF
    cQuery += " JOIN " + RetSQLName("ZZK") + " ZZK " + CRLF
    cQuery += "   ON ZZK.ZZK_FILIAL = TMPZZJ.ZZJ_FILIAL " + CRLF
    cQuery += "   AND ZZK.ZZK_MESTRE = TMPZZJ.ZZJ_MESTRE " + CRLF
    cQuery += "   AND ZZK.ZZK_LOCAL = TMPZZJ.ZZJ_LOCAL " + CRLF
    cQuery += "   AND ZZK.ZZK_LOTE = TMPZZJ.ZZJ_LOTE " + CRLF
    cQuery += "   AND ZZK.ZZK_ENDER = TMPZZJ.ZZJ_ENDER " + CRLF
    cQuery += "   AND ZZK.ZZK_NUMSER = TMPZZJ.ZZJ_NUMSER " + CRLF
    cQuery += "   AND ZZK.ZZK_IDUNIT = TMPZZJ.ZZJ_IDUNIT " + CRLF
    cQuery += "   AND ZZK.ZZK_PRODUT = TMPZZJ.ZZJ_PRODUT " + CRLF
    cQuery += "   AND ZZK.ZZK_STATUS = '2' " + CRLF
    cQuery += "   AND ZZK.ZZK_CONTAG = ( SELECT MAX(ZZK_CONTAG) " + CRLF 
    cQuery += "                          FROM " + RetSQLName("ZZK") + " ZZKB " + CRLF
    cQuery += "                          WHERE ZZKB.ZZK_FILIAL   = TMPZZJ.ZZJ_FILIAL " + CRLF
    cQuery += "                              AND ZZKB.ZZK_MESTRE = TMPZZJ.ZZJ_MESTRE " + CRLF
    cQuery += "                              AND ZZKB.ZZK_LOCAL  = TMPZZJ.ZZJ_LOCAL " + CRLF
    cQuery += "                              AND ZZKB.ZZK_LOTE   = TMPZZJ.ZZJ_LOTE " + CRLF
    cQuery += "                              AND ZZKB.ZZK_ENDER  = TMPZZJ.ZZJ_ENDER " + CRLF
    cQuery += "                              AND ZZKB.ZZK_NUMSER = TMPZZJ.ZZJ_NUMSER " + CRLF
    cQuery += "                              AND ZZKB.ZZK_IDUNIT = TMPZZJ.ZZJ_IDUNIT " + CRLF
    cQuery += "                              AND ZZKB.ZZK_PRODUT = TMPZZJ.ZZJ_PRODUT " + CRLF
    cQuery += "                              AND ZZKB.D_E_L_E_T_ = ' '  ) " + CRLF

    cQuery := ChangeQuery(cQuery)

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T. )

    DbSelectArea( cAliasQry )
    ProcRegua( Contar(cAliasQry,"!Eof()") )
    (cAliasQry)->( DbGoTop() )
    If !(cAliasQry)->(EOF())

        //--Solicita pasta para gravação de log em caso de erro
        cPath := AllTrim(cGetFile("*.*","Local para salvar log de erro",,,.F.,nOpcFile,.F.,))
        If !Empty(cPath)
            cPath := cPath + "LOG_geracao_de_Inventario_" + StrTran(DTOC(Date()),'/','-') + "_" + StrTran(TIME(),':','_') + ".txt"

            While !(cAliasQry)->( EOF() )
                
                // Incrementa a mensagem na régua.
                IncProc("Efetuando a gravação dos registros!")

                aInvent := 	{;
                            {"B7_FILIAL",	(cAliasQry)->ZZJ_FILIAL,		Nil},;
                            {"B7_COD",		(cAliasQry)->ZZJ_PRODUT,		Nil},;
                            {"B7_LOCAL",	(cAliasQry)->ZZJ_LOCAL,		    Nil},;
                            {"B7_DOC",		(cAliasQry)->ZZJ_MESTRE,		Nil},;
                            {"B7_DATA",		SToD((cAliasQry)->ZZK_DATA),	Nil},;
                            {"B7_QUANT",	(cAliasQry)->ZZK_QTCONT,		Nil},;
                            {"B7_QTSEGUM",	(cAliasQry)->ZZK_SEGUM,		    Nil},;
                            {"B7_LOTECTL",	(cAliasQry)->ZZJ_LOTE,		    Nil},;
                            {"B7_NUMLOTE",	(cAliasQry)->ZZK_SUBLOT,		Nil},;
                            {"B7_DTVALID",	SToD((cAliasQry)->ZZK_DTVAL),	Nil},;
                            {"B7_LOCALIZ",	(cAliasQry)->ZZJ_ENDER,		    Nil},;
                            {"B7_NUMSERI",	(cAliasQry)->ZZJ_NUMSER,		Nil},;
                            {"B7_CONTAGE",	(cAliasQry)->ZZK_CONTAG,		Nil},;
                            {"B7_CODUNI",	(cAliasQry)->ZZK_CODUNI,		Nil},;
                            {"B7_IDUNIT",	(cAliasQry)->ZZJ_IDUNIT,		Nil},;
                            {"B7_ORIGEM",	"ZWMSF013",					    Nil} }

                zQrySB7( (cAliasQry)->ZZJ_MESTRE,;
                        (cAliasQry)->ZZJ_LOCAL,;
                        (cAliasQry)->ZZJ_LOTE,;
                        (cAliasQry)->ZZJ_NUMSER,;
                        (cAliasQry)->ZZJ_ENDER,;
                        (cAliasQry)->ZZJ_IDUNIT,;
                        (cAliasQry)->ZZJ_PRODUT )

                
                (cAliasSB7)->( DbGoTop() )
                If (cAliasSB7)->( EOF() )
                    
                    //Efetua a Gravação
                    Begin Transaction

                        //--Cria saldo zerado na SB8 caso não exista
                        zCriaSB8(   Padr( (cAliasQry)->ZZJ_PRODUT ,TamSx3("B8_PRODUTO")[1]   ),;
                                    Padr( (cAliasQry)->ZZJ_LOCAL  ,TamSx3("B8_LOCAL")[1]     ),;
                                    Padr( (cAliasQry)->ZZJ_LOTE   ,TamSx3("B8_LOTECTL")[1]   ),;
                                    SToD( (cAliasQry)->ZZK_DTVAL ) )

                        lMsErroAuto := .F.

                        MsExecAuto({|x,y,z| Mata270(x,y,z)}, aInvent , .F. , 3)

                        If lMsErroAuto
                            nFalhou++ 
                            //Captura o LOG para gerar um arquivo Texto.
                            aAutoErro := GETAUTOGRLOG()
                            cError := "Mestre: " + (cAliasQry)->ZZJ_MESTRE +;
                                    " Armazem: " + (cAliasQry)->ZZJ_LOCAL +;
                                    " Lote: " + AllTrim( (cAliasQry)->ZZJ_LOTE ) +;
                                    " Endereço: " + AllTrim( (cAliasQry)->ZZJ_ENDER ) +;
                                    " NumSerie: " + AllTrim( (cAliasQry)->ZZJ_NUMSER ) +;
                                    " Unitizador: " + AllTrim( (cAliasQry)->ZZJ_IDUNIT ) +;
                                    " Produto: " + AllTrim( (cAliasQry)->ZZJ_PRODUT ) + CRLF + CRLF
                                    
                            For nI := 1 To Len(aAutoErro)
                                cError += AllTrim(aAutoErro[nI]) + CRLF
                            Next
                            cError += "-----------------------------------------------" + CRLF + CRLF

                            //Função para Gravar o LOG
                            nHdl := zLogInv(cError)
                        
                        Else
                            nGerou++

                            ZZK->( DbGoTo( (cAliasQry)->RECZZK ) )
                            RecLock("ZZK", .F.)
                            ZZK->ZZK_STATUS := '3' //--Transferido SB7
                            ZZK->( MsUnlock() )

                            ZZJ->( DbGoTo( (cAliasQry)->RECZZJ ) )
                            RecLock("ZZJ", .F.)
                            ZZJ->ZZJ_STATUS := '3' //--Transferido SB7
                            ZZJ->( MsUnlock() )

                        EndIf

                    End Transaction

                EndIf
                (cAliasSB7)->( DbCloseArea() )
                (cAliasQry)->( DbSkip() )
            EndDo

            If!Empty(cError)
                Help( ,, "Caoa",,   "Falha na geração dos lancamentos do inventario: " + CRLF +;
                                    "Qtd de registros processados: " + cValToChar(nGerou) + CRLF +;
                                    "Qtd de registros com erro: " + cValToChar(nFalhou) + CRLF +;
                                    "Por favor, consulte arquivo de log!", 1, 0 )
            Else
                MsgInfo("Lancamentos do inventario gerados com sucesso!","Caoa")
            EndIf

        Else
            Help( ,, "Caoa",, 'É necessario informar o local para gravação do log de erro para prosseguir com o processamento!', 1, 0 )
        EndIf

    Else
        Help( ,, "Caoa",, 'Só é possivel a transferencia para SB7 quando o status estiver "Aguardando Transf. SB7" ou "Parcialmente Transferido SB7"!', 1, 0 )
    EndIf

    (cAliasQry)->(DbCloseArea())

Return

/*
=====================================================================================
Programa.:              zBloqArm
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Tela de apresentação da rotina de bloqueio de armazem  
=====================================================================================
*/
Static Function zBloqArm()
    Local aSays         := {}
    Local aButtons      := {} 
    Local cCadastro     := "Bloqueio de movimentações de estoque"
    Local nOpcA         := 0

    If U_ZGENUSER( RetCodUsr() ,"ZWMSF013" ,.T.)
        
        If ZZI->ZZI_STATUS == '0' 

            AADD(aSays,"Esta rotina tem o objetivo de bloquear as movimentações de estoque de todos os")
            AADD(aSays,"produtos contidos no armazem " + ZZI->ZZI_LOCAL + " durante o periodo de inventario.")
            AADD(aSays,"Tem como objetivo tambem realizar a inclusão de contagens zeradas dos produtos.")
            AADD(aSays,"Clique em OK para prosseguir.")

            AADD(aButtons, { 1,.T.,{|o| nOpca := 1, o:oWnd:End() }} )
            AADD(aButtons, { 2,.T.,{|o| nOpca := 2, o:oWnd:End() }} )
                        
            FormBatch( cCadastro, aSays, aButtons )

            If nOpca == 1
                    
                If MsgYesNo("Confirma o bloqueio de movimentações de estoque de todos os produtos contidos no armazem: " + ZZI->ZZI_LOCAL, "Caoa" )

                    Processa({|| zProcBloq() }, "Carga de Dados.", "Aguarde .... Realizando o bloqueio e a carga dos registros zerados..." )

                EndIf

            EndIf

        Else
            Help( ,, "Caoa",, 'É necessario o status "Não iniciado" para realização do bloqueio de movimentações estoque!', 1, 0 )
        EndIf

    EndIf
    
Return

/*
=====================================================================================
Programa.:              zProcBloq
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Realiza bloqueio de movimentações do armazem posicionado;
                        Realiza inclusão de contagens zeradas.
=====================================================================================
*/
Static Function zProcBloq()
    Local oModel        := ModelDef()
    Local oModelGrid    := oModel:GetModel("ZZKDETAIL")
    Local cUpdate       := ""
    //Local cCodEstFis    := ""
    Local cCodUni       := ""
    Local lRet          := .T.

    Private cAliasD14   := GetNextAlias()
    Private cAliasSBF   := GetNextAlias()
    Private cAliasSB8   := GetNextAlias()
    Private cAliasSB2   := GetNextAlias()

    Begin Transaction
        //--Grava data de bloqueio em todos produtos do armazem
        cUpdate :=  " UPDATE " + RetSqlName("SB2")                      + CRLF
        cUpdate	+=  " SET B2_DTINV = '" + DToS( ZZI->ZZI_DATA ) + "' "  + CRLF
        cUpdate +=  "   , B2_QEMP = 0 "                                 + CRLF
        cUpdate +=  "   , B2_QEMPN = 0 "                                + CRLF
        cUpdate +=  "   , B2_RESERVA = 0 "                              + CRLF
        cUpdate +=  "   , B2_QPEDVEN = 0 "                              + CRLF
        cUpdate +=  "   , B2_NAOCLAS = 0 "                              + CRLF
        cUpdate +=  "   , B2_SALPEDI = 0 "                              + CRLF
        cUpdate +=  "   , B2_QTNP = 0 "                                 + CRLF
        cUpdate +=  "   , B2_QNPT = 0 "                                 + CRLF
        cUpdate +=  "   , B2_QTER = 0 "                                 + CRLF
        cUpdate +=  "   , B2_QACLASS = 0 "                              + CRLF
        cUpdate +=  "   , B2_QEMPSA = 0 "                               + CRLF
        cUpdate +=  "   , B2_QEMPPRE = 0 "                              + CRLF
        cUpdate +=  "   , B2_SALPPRE = 0 "                              + CRLF
        cUpdate +=  " WHERE B2_FILIAL = '" + FWxFilial("SB2") + "'"     + CRLF    
        cUpdate +=  " AND B2_LOCAL = '" + ZZI->ZZI_LOCAL + "'"          + CRLF
        cUpdate +=  " AND D_E_L_E_T_ = ' ' "                            + CRLF

        If TcSqlExec(cUpdate) < 0
            lRet := .F.
            Help( ,, "Caoa",, TcSqlError() , 1, 0)
            Disarmtransaction()
        EndIf

        If lRet
            cUpdate :=  " UPDATE " + RetSqlName("SBF")                      + CRLF
            cUpdate	+=  " SET BF_EMPENHO = 0 "                              + CRLF
            cUpdate +=  "   , BF_QEMPPRE = 0 "                              + CRLF
            cUpdate +=  "   , BF_EMPEN2 = 0 "                               + CRLF
            cUpdate +=  "   , BF_QEPRE2 = 0 "                               + CRLF
            cUpdate +=  " WHERE BF_FILIAL = '" + FWxFilial("SBF") + "'"     + CRLF    
            cUpdate +=  " AND BF_LOCAL = '" + ZZI->ZZI_LOCAL + "'"          + CRLF
            cUpdate +=  " AND D_E_L_E_T_ = ' ' "                            + CRLF

            If TcSqlExec(cUpdate) < 0
                lRet := .F.
                Help( ,, "Caoa",, TcSqlError() , 1, 0)
                Disarmtransaction()
            EndIf
        EndIf

        If lRet
            cUpdate :=  " UPDATE " + RetSqlName("SB8")                      + CRLF
            cUpdate	+=  " SET B8_EMPENHO = 0 "                              + CRLF
            cUpdate +=  "   , B8_QEMPPRE = 0 "                              + CRLF
            cUpdate +=  "   , B8_QACLASS = 0 "                              + CRLF
            cUpdate +=  "   , B8_EMPENH2 = 0 "                              + CRLF
            cUpdate +=  "   , B8_QEPRE2 = 0 "                               + CRLF
            cUpdate +=  "   , B8_QACLAS2 = 0 "                              + CRLF
            cUpdate +=  " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "'"     + CRLF    
            cUpdate +=  " AND B8_LOCAL = '" + ZZI->ZZI_LOCAL + "'"          + CRLF
            cUpdate +=  " AND D_E_L_E_T_ = ' ' "                            + CRLF

            If TcSqlExec(cUpdate) < 0
                lRet := .F.
                Help( ,, "Caoa",, TcSqlError() , 1, 0)
                Disarmtransaction()
            EndIf
        EndIf

        If lRet
            //--Grava data de bloqueio em todos produtos do armazem
            cUpdate :=  " UPDATE " + RetSqlName("D14")                      + CRLF
            cUpdate	+=  " SET D14_QTDEMP = 0 "                              + CRLF
            cUpdate +=  "   , D14_QTDEM2 = 0 "                              + CRLF
            cUpdate +=  " WHERE D14_FILIAL = '" + FWxFilial("D14") + "'"    + CRLF    
            cUpdate +=  " AND D14_LOCAL = '" + ZZI->ZZI_LOCAL + "'"         + CRLF
            cUpdate +=  " AND D_E_L_E_T_ = ' ' "                            + CRLF

            If TcSqlExec(cUpdate) < 0
                lRet := .F.
                Help( ,, "Caoa",, TcSqlError() , 1, 0)
                Disarmtransaction()
            EndIf
        EndIf
        
        If lRet
            RecLock("ZZI",.F.)
            ZZI->ZZI_STATUS := '1' //--Em Contagem
            ZZI->( MsUnLock() )

            //--Monta consulta D14 para gerar itens com quantidade zerada
            zQryD14( ZZI->ZZI_LOCAL )

            ProcRegua( Contar(cAliasD14,"!Eof()") )
            ( cAliasD14 )->( DbGoTop() )
            While ( cAliasD14 )->( !EOF() )
                
                // Incrementa a mensagem na régua.
                IncProc("Efetuando a inclusão das contagens zeradas, tabela origem saldos por endereço WMS!")

                //Ativando o modelo
                oModel:SetOperation(3)
                oModel:Activate()

                // Carga dos dados
                oModelGrid:SetValue('ZZK_FILIAL'    ,FWxFilial("ZZK"))              
                oModelGrid:SetValue('ZZK_LOTE'      ,PadR( ( cAliasD14 )->D14_LOTECT, TamSX3("ZZK_LOTE")[1]) )
                oModelGrid:SetValue('ZZK_DTVAL'     ,POSICIONE('SB8', 3, FWxFilial('SB8')+(cAliasD14)->D14_PRODUT+(cAliasD14)->D14_LOCAL+(cAliasD14)->D14_LOTECT, "B8_DTVALID" ) )
                oModelGrid:SetValue('ZZK_ENDER'     ,PadR( ( cAliasD14 )->D14_ENDER, TamSX3("ZZK_ENDER")[1]) )
                //oModelGrid:SetValue('ZZK_NUMSER'    ,PadR( aDados[5], TamSX3("ZZK_NUMSER")[1]) )
                oModelGrid:SetValue('ZZK_IDUNIT'    ,PadR( ( cAliasD14 )->D14_IDUNIT, TamSX3("ZZK_IDUNIT")[1]) )
                oModelGrid:SetValue('ZZK_PRODUT'    ,PadR( ( cAliasD14 )->D14_PRODUT, TamSX3("ZZK_PRODUT")[1]) ) 
                oModelGrid:SetValue('ZZK_QTCONT'    ,0 )
                oModelGrid:SetValue('ZZK_SEGUM'     ,0 )
                oModelGrid:SetValue('ZZK_USER'      ,RetCodUsr() )

                /*Removido, não é necessario para geração do acerto
                If !Empty( oModelGrid:GetValue("ZZK_ENDER") )
                    cCodEstFis  := POSICIONE("SBE",1,FWxFilial("SBE")+oModelGrid:GetValue("ZZK_LOCAL")+oModelGrid:GetValue("ZZK_ENDER"), "BE_ESTFIS")
                    oModelGrid:SetValue("ZZK_TPESTR",cCodEstFis)
                EndIf
                */

                If !Empty( oModelGrid:GetValue("ZZK_IDUNIT") )
                    cCodUni := POSICIONE("D0Y",1,FWxFilial("D0Y")+oModelGrid:GetValue("ZZK_IDUNIT"),"D0Y_TIPUNI")
                    oModelGrid:SetValue("ZZK_CODUNI",cCodUni)
                EndIf

                //Valid só é instanciado para atender o padrão do MVC, se não instanciar o commit não é realizado.
                //O retorno sempre sera verdadeiro, porque nenhuma validação é executada neste cenario
                If oModel:VldData()

                    oModel:CommitData()
                        
                EndIf

                // Desativando o modelo para o proximo registro
                oModel:DeActivate()

                ( cAliasD14 )->( DbSkip() )

            EndDo
            ( cAliasD14 )->( DbCloseArea() )

            //--Monta consulta SBF para gerar itens com quantidade zerada
            zQrySBF( ZZI->ZZI_LOCAL )

            ProcRegua( Contar(cAliasSBF,"!Eof()") )
            ( cAliasSBF )->( DbGoTop() )
            While ( cAliasSBF )->( !EOF() )

                // Incrementa a mensagem na régua.
                IncProc("Efetuando a inclusão das contagens zeradas, tabela origem saldos por endereço!")

                //Ativando o modelo
                oModel:SetOperation(3)
                oModel:Activate()

                // Carga dos dados
                oModelGrid:SetValue('ZZK_FILIAL'    ,FWxFilial("ZZK"))              
                oModelGrid:SetValue('ZZK_LOTE'      ,PadR( ( cAliasSBF )->BF_LOTECTL, TamSX3("ZZK_LOTE")[1]) )
                oModelGrid:SetValue('ZZK_DTVAL'     ,POSICIONE('SB8', 3, FWxFilial('SB8')+(cAliasSBF)->BF_PRODUTO+(cAliasSBF)->BF_LOCAL+(cAliasSBF)->BF_LOTECTL, "B8_DTVALID" ) )
                oModelGrid:SetValue('ZZK_ENDER'     ,PadR( ( cAliasSBF )->BF_LOCALIZ, TamSX3("ZZK_ENDER")[1]) )
                oModelGrid:SetValue('ZZK_NUMSER'    ,PadR( ( cAliasSBF )->BF_NUMSERI, TamSX3("ZZK_NUMSER")[1]) )
                //oModelGrid:SetValue('ZZK_IDUNIT'    ,PadR( aDados[6], TamSX3("ZZK_IDUNIT")[1]) )
                oModelGrid:SetValue('ZZK_PRODUT'    ,PadR( ( cAliasSBF )->BF_PRODUTO, TamSX3("ZZK_PRODUT")[1]) ) 
                oModelGrid:SetValue('ZZK_QTCONT'    ,0 )
                oModelGrid:SetValue('ZZK_SEGUM'     ,0 )
                oModelGrid:SetValue('ZZK_USER'      ,RetCodUsr() )

                /*Removido, não é necessario para geração do acerto
                If !Empty( oModelGrid:GetValue("ZZK_ENDER") )
                    cCodEstFis  := POSICIONE("SBE",1,FWxFilial("SBE")+oModelGrid:GetValue("ZZK_LOCAL")+oModelGrid:GetValue("ZZK_ENDER"), "BE_ESTFIS")
                    oModelGrid:SetValue("ZZK_TPESTR",cCodEstFis)
                EndIf
                */

                If !Empty( oModelGrid:GetValue("ZZK_IDUNIT") )
                    cCodUni := POSICIONE("D0Y",1,FWxFilial("D0Y")+oModelGrid:GetValue("ZZK_IDUNIT"),"D0Y_TIPUNI")
                    oModelGrid:SetValue("ZZK_CODUNI",cCodUni)
                EndIf

                //Valid só é instanciado para atender o padrão do MVC, se não instanciar o commit não é realizado.
                //O retorno sempre sera verdadeiro, porque nenhuma validação é executada neste cenario
                If oModel:VldData()

                    oModel:CommitData()
                        
                EndIf

                // Desativando o modelo para o proximo registro
                oModel:DeActivate()

                ( cAliasSBF )->( DbSkip() )

            EndDo
            ( cAliasSBF )->( DbCloseArea() )

            //--Monta consulta SBF para gerar itens com quantidade zerada
            zQrySB8( ZZI->ZZI_LOCAL )

            ProcRegua( Contar(cAliasSB8,"!Eof()") )
            ( cAliasSB8 )->( DbGoTop() )
            While ( cAliasSB8 )->( !EOF() )

                // Incrementa a mensagem na régua.
                IncProc("Efetuando a inclusão das contagens zeradas, tabela origem saldos por lote!")

                //Ativando o modelo
                oModel:SetOperation(3)
                oModel:Activate()

                // Carga dos dados
                oModelGrid:SetValue('ZZK_FILIAL'    ,FWxFilial("ZZK"))              
                oModelGrid:SetValue('ZZK_LOTE'      ,PadR( ( cAliasSB8 )->B8_LOTECTL, TamSX3("ZZK_LOTE")[1]) )
                oModelGrid:SetValue('ZZK_DTVAL'     ,POSICIONE('SB8', 3, FWxFilial('SB8')+(cAliasSB8)->B8_PRODUTO+(cAliasSB8)->B8_LOCAL+(cAliasSB8)->B8_LOTECTL, "B8_DTVALID" ) )
                //oModelGrid:SetValue('ZZK_ENDER'     ,PadR( ( cAliasSB8 )->BF_LOCALIZ, TamSX3("ZZK_ENDER")[1]) )
                //oModelGrid:SetValue('ZZK_NUMSER'    ,PadR( ( cAliasSB8 )->BF_NUMSERI, TamSX3("ZZK_NUMSER")[1]) )
                //oModelGrid:SetValue('ZZK_IDUNIT'    ,PadR( aDados[6], TamSX3("ZZK_IDUNIT")[1]) )
                oModelGrid:SetValue('ZZK_PRODUT'    ,PadR( ( cAliasSB8 )->B8_PRODUTO, TamSX3("ZZK_PRODUT")[1]) ) 
                oModelGrid:SetValue('ZZK_QTCONT'    ,0 )
                oModelGrid:SetValue('ZZK_SEGUM'     ,0 )
                oModelGrid:SetValue('ZZK_USER'      ,RetCodUsr() )

                //If !Empty( oModelGrid:GetValue("ZZK_ENDER") )
                //    cCodEstFis  := POSICIONE("SBE",1,FWxFilial("SBE")+oModelGrid:GetValue("ZZK_LOCAL")+oModelGrid:GetValue("ZZK_ENDER"), "BE_ESTFIS")
                //    oModelGrid:SetValue("ZZK_TPESTR",cCodEstFis)
                //EndIf

                //If !Empty( oModelGrid:GetValue("ZZK_IDUNIT") )
                //    cCodUni := POSICIONE("D0Y",1,FWxFilial("D0Y")+oModelGrid:GetValue("ZZK_IDUNIT"),"D0Y_TIPUNI")
                //    oModelGrid:SetValue("ZZK_CODUNI",cCodUni)
                //EndIf

                //Valid só é instanciado para atender o padrão do MVC, se não instanciar o commit não é realizado.
                //O retorno sempre sera verdadeiro, porque nenhuma validação é executada neste cenario
                If oModel:VldData()

                    oModel:CommitData()
                        
                EndIf

                // Desativando o modelo para o proximo registro
                oModel:DeActivate()

                ( cAliasSB8 )->( DbSkip() )

            EndDo
            ( cAliasSB8 )->( DbCloseArea() )

            //--Monta consulta SBF para gerar itens com quantidade zerada
            zQrySB2( ZZI->ZZI_LOCAL )

            ProcRegua( Contar(cAliasSB2,"!Eof()") )
            ( cAliasSB2 )->( DbGoTop() )
            While ( cAliasSB2 )->( !EOF() )

                // Incrementa a mensagem na régua.
                IncProc("Efetuando a inclusão das contagens zeradas, tabela origem saldos fisico e financeiro!")

                //Ativando o modelo
                oModel:SetOperation(3)
                oModel:Activate()

                // Carga dos dados
                oModelGrid:SetValue('ZZK_FILIAL'    ,FWxFilial("ZZK"))              
                //oModelGrid:SetValue('ZZK_LOTE'      ,PadR( ( cAliasSB8 )->B8_LOTECTL, TamSX3("ZZK_LOTE")[1]) )
                //oModelGrid:SetValue('ZZK_DTVAL'     ,POSICIONE('SB8', 3, FWxFilial('SB8')+(cAliasSB8)->B8_PRODUTO+(cAliasSB8)->B8_LOCAL+(cAliasSB8)->B8_LOTECTL, "B8_DTVALID" ) )
                //oModelGrid:SetValue('ZZK_ENDER'     ,PadR( ( cAliasSB8 )->BF_LOCALIZ, TamSX3("ZZK_ENDER")[1]) )
                //oModelGrid:SetValue('ZZK_NUMSER'    ,PadR( ( cAliasSB8 )->BF_NUMSERI, TamSX3("ZZK_NUMSER")[1]) )
                //oModelGrid:SetValue('ZZK_IDUNIT'    ,PadR( aDados[6], TamSX3("ZZK_IDUNIT")[1]) )
                oModelGrid:SetValue('ZZK_PRODUT'    ,PadR( ( cAliasSB2 )->B2_COD, TamSX3("ZZK_PRODUT")[1]) ) 
                oModelGrid:SetValue('ZZK_QTCONT'    ,0 )
                oModelGrid:SetValue('ZZK_SEGUM'     ,0 )
                oModelGrid:SetValue('ZZK_USER'      ,RetCodUsr() )

                //If !Empty( oModelGrid:GetValue("ZZK_ENDER") )
                //    cCodEstFis  := POSICIONE("SBE",1,FWxFilial("SBE")+oModelGrid:GetValue("ZZK_LOCAL")+oModelGrid:GetValue("ZZK_ENDER"), "BE_ESTFIS")
                //    oModelGrid:SetValue("ZZK_TPESTR",cCodEstFis)
                //EndIf

                //If !Empty( oModelGrid:GetValue("ZZK_IDUNIT") )
                //    cCodUni := POSICIONE("D0Y",1,FWxFilial("D0Y")+oModelGrid:GetValue("ZZK_IDUNIT"),"D0Y_TIPUNI")
                //    oModelGrid:SetValue("ZZK_CODUNI",cCodUni)
                //EndIf

                //Valid só é instanciado para atender o padrão do MVC, se não instanciar o commit não é realizado.
                //O retorno sempre sera verdadeiro, porque nenhuma validação é executada neste cenario
                If oModel:VldData()

                    oModel:CommitData()
                        
                EndIf

                // Desativando o modelo para o proximo registro
                oModel:DeActivate()

                ( cAliasSB2 )->( DbSkip() )

            EndDo
            ( cAliasSB2 )->( DbCloseArea() )

        EndIf

    End Transaction

Return

/*
=====================================================================================
Programa.:              zQryD14
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Consulta tabela D14 para inclusão de contagens zeradas  
=====================================================================================
*/
Static Function zQryD14(cLocal)

    BeginSql Alias cAliasD14
        SELECT D14_LOCAL, D14_LOTECT, D14_ENDER, D14_IDUNIT, D14_PRODUT 
        FROM %Table:D14% D14
        WHERE D14.D14_FILIAL = %xFilial:D14%
        AND D14.D14_LOCAL = %exp:cLocal%
        AND D14.D14_QTDEST <> %exp:0%
        AND D14.D14_PRODUT <> %exp:' '%
        AND D14.D14_ENDER <> %exp:' '%
        AND D14.%NotDel%
        GROUP BY D14_LOCAL, D14_LOTECT, D14_ENDER, D14_IDUNIT, D14_PRODUT
        ORDER BY D14_LOCAL, D14_LOTECT, D14_ENDER, D14_IDUNIT, D14_PRODUT
    EndSql

Return

/*
=====================================================================================
Programa.:              zQrySBF
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Consulta tabela SBF para inclusão de contagens zeradas          
=====================================================================================
*/
Static Function zQrySBF(cLocal)

    BeginSql Alias cAliasSBF
        SELECT BF_LOCAL, BF_LOTECTL, BF_LOCALIZ, BF_NUMSERI, BF_PRODUTO
        FROM %Table:SBF% SBF
        WHERE SBF.BF_FILIAL = %xFilial:SBF%
        AND SBF.BF_LOCAL = %exp:cLocal%
        AND SBF.BF_QUANT <> %exp:0%
        AND SBF.BF_PRODUTO <> %exp:' '%
        AND SBF.BF_LOCALIZ <> %exp:' '%
        AND NOT EXISTS ( SELECT 1 FROM %Table:ZZK% ZZK
                         WHERE ZZK_FILIAL = %xFilial:ZZK%
                         AND ZZK_LOCAL = BF_LOCAL
                         AND ZZK_LOTE = BF_LOTECTL
                         AND ZZK_ENDER = BF_LOCALIZ
                         AND ZZK_NUMSER = BF_NUMSERI
                         AND ZZK_PRODUT = BF_PRODUTO
                         AND ZZK.%NotDel% )
        AND SBF.%NotDel%
        GROUP BY BF_LOCAL, BF_LOTECTL, BF_LOCALIZ, BF_NUMSERI, BF_PRODUTO
        ORDER BY BF_LOCAL, BF_LOTECTL, BF_LOCALIZ, BF_NUMSERI, BF_PRODUTO
    EndSql

Return

/*
=====================================================================================
Programa.:              zQrySB8
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              28/12/2020
Descricao / Objetivo:   Consulta tabela SB8 para inclusão de contagens zeradas          
=====================================================================================
*/
Static Function zQrySB8(cLocal)

    BeginSql Alias cAliasSB8
        SELECT B8_LOCAL, B8_LOTECTL, B8_PRODUTO 
        FROM %Table:SB8% SB8
        WHERE SB8.B8_FILIAL = %xFilial:SB8%
        AND SB8.B8_LOCAL = %exp:cLocal%
        AND SB8.B8_SALDO <> %exp:0%
        AND SB8.B8_PRODUTO <> %exp:' '%
        AND SB8.B8_LOTECTL <> %exp:' '%
        AND SB8.%NotDel%
        AND NOT EXISTS ( SELECT 1 FROM %Table:ZZK% ZZK
                        WHERE ZZK_FILIAL = %xFilial:ZZK%
                        AND ZZK_LOCAL = B8_LOCAL
                        AND ZZK_LOTE = B8_LOTECTL
                        AND ZZK_PRODUT = B8_PRODUTO
                        AND ZZK.%NotDel% )
        GROUP BY B8_LOCAL, B8_LOTECTL, B8_PRODUTO 
        ORDER BY B8_LOCAL, B8_LOTECTL, B8_PRODUTO 
    EndSql

Return

/*
=====================================================================================
Programa.:              zQrySB2
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              28/12/2020
Descricao / Objetivo:   Consulta tabela SB2 para inclusão de contagens zeradas          
=====================================================================================
*/
Static Function zQrySB2(cLocal)
    
    BeginSql Alias cAliasSB2
        SELECT B2_LOCAL, B2_COD
        FROM %Table:SB2% SB2
        WHERE SB2.B2_FILIAL = %xFilial:SB2%
        AND SB2.B2_LOCAL = %exp:cLocal%
        AND SB2.B2_QATU <> %exp:0%
        AND SB2.B2_COD <> %exp:' '%
        AND SB2.%NotDel%
        AND NOT EXISTS ( SELECT 1 FROM %Table:ZZK% ZZK
                        WHERE ZZK_FILIAL = %xFilial:ZZK%
                        AND ZZK_LOCAL = B2_LOCAL
                        AND ZZK_PRODUT = B2_COD
                        AND ZZK.%NotDel% )
        GROUP BY B2_LOCAL, B2_COD 
        ORDER BY B2_LOCAL, B2_COD
    EndSql

Return

/*
=====================================================================================
Programa.:              ZF13AtuZZI
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Atualiza status da tabela mestre de inventario     
=====================================================================================
*/
Static Function ZF13AtuZZI( cMestre ,cLocal )
    Local aAreaZZI  := ZZI->( GetArea() )
    Local cAliasQry := GetNextAlias()
    Local cQuery	:= ""
    Local nTotal    := 0

    cQuery := " SELECT " + CRLF
    cQuery += "  SUM(CASE WHEN ZZJ_STATUS = '1' THEN 1 ELSE 0 END) AS CONTAGEM, " + CRLF
    cQuery += "  SUM(CASE WHEN ZZJ_STATUS = '2' THEN 1 ELSE 0 END) AS FINALIZADO, " + CRLF
    cQuery += "  SUM(CASE WHEN ZZJ_STATUS = '3' THEN 1 ELSE 0 END) AS PROCESSADO " + CRLF
    cQuery += " FROM " + RetSqlName("ZZI") + " ZZI " + CRLF
    cQuery += " JOIN " + RetSqlName("ZZJ") + " ZZJ " + CRLF
    cQuery += " ON ZZJ.ZZJ_FILIAL = '" + FWxFilial("ZZJ") + "' " + CRLF 
    cQuery += "  AND ZZJ.ZZJ_MESTRE = ZZI.ZZI_MESTRE " + CRLF 
    cQuery += "  AND ZZJ.ZZJ_LOCAL = ZZI.ZZI_LOCAL " + CRLF 
    cQuery += "  AND ZZJ.D_E_L_E_T_ = ' ' " + CRLF 
    cQuery += " WHERE ZZI.ZZI_FILIAL = '" + FWxFilial("ZZI") + "' " + CRLF 
    cQuery += "  AND ZZI.ZZI_MESTRE = '" + cMestre + "' " + CRLF 
    cQuery += "  AND ZZI.ZZI_LOCAL = '" + cLocal + "' " + CRLF 
    cQuery += "  AND ZZI.D_E_L_E_T_ = ' ' " + CRLF 

    cQuery := ChangeQuery(cQuery)

   	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T. )

	DbSelectArea( cAliasQry )
	If (cAliasQry)->( !EOF() )

        If (cAliasQry)->(CONTAGEM+FINALIZADO+PROCESSADO) != 0
            
            nTotal := (cAliasQry)->(CONTAGEM+FINALIZADO+PROCESSADO)
            ZZI->(DbSetOrder(1))
            If (cAliasQry)->CONTAGEM != 0

                If ZZI->( DbSeek( FWxFilial("ZZI") + cMestre + cLocal ) )
                    RecLock("ZZI", .F.)
                    ZZI->ZZI_STATUS := "1" //Em andamento
                    ZZI->( MsUnlock() )
                EndIf

            ElseIf (cAliasQry)->FINALIZADO == nTotal
                
                If ZZI->( DbSeek( FWxFilial("ZZI") + cMestre + cLocal ) )
                    RecLock("ZZI", .F.)
                    ZZI->ZZI_STATUS := "2" //--Aguardando Transf. SB7
                    ZZI->( MsUnlock() )
                EndIf

            ElseIf (cAliasQry)->PROCESSADO == nTotal

                If ZZI->( DbSeek( FWxFilial("ZZI") + cMestre + cLocal ) )
                    RecLock("ZZI", .F.)
                    ZZI->ZZI_STATUS := "3" //--Transferido SB7
                    ZZI->( MsUnlock() )
                EndIf
            
            Else
                
                If ZZI->( DbSeek( FWxFilial("ZZI") + cMestre + cLocal ) )
                    RecLock("ZZI", .F.)
                    ZZI->ZZI_STATUS := "4" //--Parcialmente Transferido SB7
                    ZZI->( MsUnlock() )
                EndIf

            EndIf

        Else
            
            If ZZI->( DbSeek( FWxFilial("ZZI") + cMestre + cLocal ) )
                RecLock("ZZI", .F.)
                ZZI->ZZI_STATUS := "1" //Em andamento
                ZZI->( MsUnlock() )
            EndIf

        EndIf

    EndIf

    (cAliasQry)->(DbCloseArea())
    RestArea( aAreaZZI )

Return

/*
=====================================================================================
Programa.:              LoadGrid
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Função estática para efetuar o load dos dados do grid      
=====================================================================================
*/
Static function LoadGrid(oModel, cMestre, cLocal, cLote, cEndereco, cNumSer, cIDUnit, cProd )
    local aData as array
    local cAlias as char
    local cWorkArea as char

    cWorkArea := Alias()
    cAlias := GetNextAlias()

    BeginSql Alias cAlias
        SELECT ZZK.*, R_E_C_N_O_ RECNO
        FROM %Table:ZZK% ZZK
        WHERE ZZK.ZZK_FILIAL = %xFilial:ZZK%
        AND ZZK.ZZK_MESTRE = %exp:cMestre%
        AND ZZK.ZZK_LOCAL = %exp:cLocal%
        AND ZZK.ZZK_LOTE = %exp:cLote%
        AND ZZK.ZZK_ENDER = %exp:cEndereco%
        AND ZZK.ZZK_NUMSER = %exp:cNumSer%
        AND ZZK.ZZK_IDUNIT = %exp:cIDUnit%
        AND ZZK.ZZK_PRODUT = %exp:cProd%
        AND ZZK.%NotDel%
    EndSql

    aData := FwLoadByAlias(oModel, cAlias, "ZZK", "RECNO", /*lCopy*/, .T.)

    (cAlias)->(DBCloseArea())

    if !Empty(cWorkArea) .And. Select(cWorkArea) > 0
        DBSelectArea(cWorkArea)
    endif

return aData

/*
=========================================================================================
Programa.:              GrvLog
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Gravação de log de erro na inclusão de lançamentos de inventario     
=========================================================================================
*/
Static Function GrvLog( cArq , cLog )
    Local nHandle 	    := 0
    Local cDrive		:= ""
    Local cDir			:= ""
    Local cNomeArq		:= ""
    Local cExt			:= ""
    Local lRet          := .T.

    cArq := StrTran(Alltrim(cArq)," ","")

    If !File( cArq )

        //-- Tratamento para diretorios
        SplitPath( cArq , @cDrive, @cDir, @cNomeArq, @cExt )
        MontaDir(cDir)

        nHandle := FCreate( cArq )
        FClose( nHandle )	

    Endif

    If File( cArq )

        nHandle := FOpen( cArq, 2 )
        FSeek ( nHandle, 0, 2 )			// Posiciona no final do arquivo.
        
        FWrite( nHandle, cLog + CRLF, Len(cLog) + 2 )
        
        FClose( nHandle )
    
    Else
        
        lRet := .F.
        MsgAlert( "Importação de contagens interrompida, falha ao gerar o arquivo de log, erro n°: " +;
                AllTrim( Str( Ferror() ) ) + CRLF + " Por favor, consulte o administrador do sistema! " )
        
    EndIf

Return lRet

/*
=====================================================================================
Programa.:              zPosLinVal
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Validações do grid      
=====================================================================================
*/
Static Function zPosLinVal(oModelGrid)
	Local lRet      := .T.
    Local cMestre   := oModelGrid:GetValue("ZZK_MESTRE")
    Local cLocal    := oModelGrid:GetValue("ZZK_LOCAL")
    Local cProduto  := oModelGrid:GetValue("ZZK_PRODUT")
    Local cEndereco := oModelGrid:GetValue("ZZK_ENDER")
    Local cLote     := oModelGrid:GetValue("ZZK_LOTE")
    Local cNumSer   := oModelGrid:GetValue("ZZK_NUMSER")
    Local cIDUnit   := oModelGrid:GetValue("ZZK_IDUNIT")
    Local dDtValid  := oModelGrid:GetValue("ZZK_DTVAL")
    Local lUnitz    := .F.
    Local cError    := ""
    Local nI        := 0
    Local cAliasQtd := ""

    Private aErro   := {}

    //Não passa pelo valid se a chamada for da rotina de bloqueio de movimentos e geração de contagens zeradas
    If !( IsInCallStack("zProcBloq") )

        //--Controla WMS
        SB5->( DbSetOrder(1) )
        If SB5->( DbSeek( FWxFilial("SB5") + cProduto ) )
            
            //--Controla WMS
            If SB5->B5_CTRWMS == '1'
                
                If Empty( cEndereco )
                    lRet := .F.
                    Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                                 " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +;  
                                 " | Item possui controle de wms, por favor preencher o campo Endereço!" )
                EndIf

            EndIf

        EndIf

        //--Verifica se é veiculo
        If cLocal == 'VN'
            If Empty( cNumSer )
                lRet := .F.
                Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                             " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +;   
                             " | Item identificado como veiculo, por favor preencher o campo Numserie!" )
            EndIf
        EndIf

        //--Verifica se armazem é unitizado
        NNR->( DbSetOrder(1) )
        If NNR->( DbSeek( FWxFilial("NNR") + cLocal ) )

            lUnitz := NNR->NNR_AMZUNI == '1' //--Armazem unitizado

        EndIf

        If lUnitz

            //--Se a estrutura não for unitizada, não exige o preenchimento do unitizador
            If WmsTipEst(cLocal,cEndereco) == '2' //--Não unitizada

                lRet := ValidCompl(cMestre, cLocal, cLote, cEndereco, cNumSer, cIDUnit, cProduto, dDtValid)

            Else

                lRet := ValidCompl(cMestre, cLocal, cLote, cEndereco, cNumSer, cIDUnit, cProduto, dDtValid)

                //Armazem unitizado, exige o preenchimento do unitizador
                If Empty( cIDUnit )
                    lRet := .F.
                    Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                                 " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +;  
                                 " | Item unitizado, por favor preencher o campo unitizador!")
                Else
                    D0Y->( DbSetOrder(1) )
                    If !( D0Y->( DbSeek( FWxFilial("D0Y") + cIDUnit ) ) )
                        lRet := .F.
                        Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                                     " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +;  
                                     " | Item não localizado no cadastro de unitizadores!")
                    EndIf
                EndIf

            EndIf

        Else

            //Armazem não unitizado, unitizador não pode estar preenchido
            If Empty( cIDUnit )
                lRet := ValidCompl(cMestre, cLocal, cLote, cEndereco, cNumSer, cIDUnit, cProduto, dDtValid)
            Else
                lRet := .F.
                Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                                " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +;  
                                " | Unitizador informado para armazem não unitizado!")
            EndIf

        EndIf

        //--Valida se o produto selecionado ja possui quantidade eleita
        cAliasQtd := GetNextAlias()
        BeginSql Alias cAliasQtd
            SELECT ZZK_QTDELE
            FROM %Table:ZZK% ZZK
            WHERE ZZK.ZZK_FILIAL    = %xFilial:ZZK%
                AND ZZK.ZZK_MESTRE  = %Exp:cMestre%
                AND ZZK.ZZK_LOCAL   = %Exp:cLocal%
                AND ZZK.ZZK_LOTE    = %Exp:cLote%
                AND ZZK.ZZK_ENDER   = %Exp:cEndereco%
                AND ZZK.ZZK_NUMSER  = %Exp:cNumSer%
                AND ZZK.ZZK_IDUNIT  = %Exp:cIDUnit%
                AND ZZK.ZZK_PRODUT  = %Exp:cProduto%
                AND ZZK.ZZK_QTDELE  <> %Exp:0%
                AND ZZK.%NotDel%
        EndSql

        If (cAliasQtd)->( !Eof() )

            If nOperation == 3
                lRet := .F.
                Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                             " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +; 
                             " | Produto informado possui quantidade eleita!. Por favor, delete umas das contagens deste produto" +;
                             " ou informe outro produto." )
            EndIf

        EndIf
        (cAliasQtd)->( DbCloseArea() )

        ZZJ->( DbSetOrder(1) )
        ZZJ->( DbSeek( FWxFilial('ZZJ') + cMestre + cLocal ) )
        If ZZJ->ZZJ_STATUS == '3'
            lRet := .F.
            Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                         " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +; 
                         ' | Item esta com status "Transferido SB7" e não permite alterações!' )
        EndIf

        //--Valida se produto existe no armazem selecionado
        SB2->( DbSetOrder(1) )
        If !( SB2->( DbSeek( FWxFilial("SB2") + cProduto + cLocal ) ) )

            //Não encontrou o Registro na SB2, cria o SB2 com saldo 0
            CriaSB2( cProduto, cLocal )

            If !( SB2->( DbSeek( FWxFilial("SB2") + cProduto + cLocal ) ) )
                lRet := .F.
                Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                            " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +; 
                            " | Produto informado não foi localizado no armazem " + AllTrim(cLocal) + " !" )
            EndIf
        EndIf

        If !Empty( aErro )
            For nI := 1 To Len(aErro)
                cError += AllTrim(aErro[nI]) + CRLF
            Next
            cError += "-----------------------------------------------" + CRLF

            Help( ,, "Caoa",, cError, 1, 0 )
        EndIf
    EndIf

Return lRet

/*
=====================================================================================
Programa.:              ValidCompl
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Validações complementares do grid       
=====================================================================================
*/
Static Function ValidCompl(cMestre, cLocal, cLote, cEndereco, cNumSer, cIDUnit, cProduto, dDtValid)
    Local lRet      := .T.
    //Local dDtValid  := CToD( " / / ")

    SB1->( DbSetOrder(1) )
    If SB1->( DbSeek( FWxFilial("SB1") + cProduto ) )

        //--Verifica se possui controle de lote
        If SB1->B1_RASTRO == 'L'
            If Empty( cLote )
                lRet := .F.
                Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                             " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +; 
                             " | Item possui controle de lote, por favor preencher o campo Lote!" )
            /*Else Especificação DEV03 criação de lotes zerados, os lotes que não existirem serão criados zerados ao gerar a SB7
                //--Verifica se o lote informado existe
                SB8->( DbSetOrder(3) )
                If !( SB8->( DbSeek( xFilial("SB8")+ cProduto + cLocal + cLote ) ) )
                    lRet := .F.
                    Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                                 " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +; 
                                 " | Saldo não encontrado para o lote informado!" )
                EndIf*/    
            EndIf

            If Empty( dDtValid )
                lRet := .F.
                Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                             " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +; 
                             " | Item possui controle de lote, por favor preencher o campo Data de validade!" )
            /*Else --->Validação removida em acordo com o time de custos, os ajustes de data serão feitos em outro momento
                If ValType(SB8->B8_DTVALID) == 'D'
                    dDtValid := IIF( ValType( oModelGrid:GetValue("ZZK_DTVAL") ) == 'D' ,oModelGrid:GetValue("ZZK_DTVAL") ,SToD( oModelGrid:GetValue("ZZK_DTVAL") ) )
                    If dDtValid != SB8->B8_DTVALID
                        lRet := .F.
                        Aadd( aErro, "Data de validade informada  " + DToC( oModelGrid:GetValue("ZZK_DTVAL") ) +;
                                    " não condiz com a data " + DToC( SB8->B8_DTVALID ) + " localizada no cadastro de saldos por lote."  )
                    EndIf
                EndIf*/    
            EndIf
        EndIf

        //--Verifica se possui controle de endereço
        If SB1->B1_LOCALIZ == 'S'
            If Empty( cEndereco)
                lRet := .F.
                Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                             " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +;
                             " | Item informado possui controle de endereço, por favor preencher o campo Endereço!" )
            Else
                SBE->( DbSetOrder(1) )
                If !( SBE->( DbSeek( FWxFilial("SBE") + cLocal + cEndereco ) ) )
                    lRet := .F.
                    Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                                 " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +; 
                                 " | Endereço informado, não foi localizado no cadastro de endereços!" )
                EndIf
            EndIf
        EndIf

        //--Verifica se é veiculo
        If AllTrim( SB1->B1_LOCPAD ) == 'VN' .And. AllTrim( SB1->B1_GRUPO ) == 'VEIA' //GAP - Usar MV_LOCVEIN e MV_GRUVEI? 
            If Empty( cNumSer )
                lRet := .F.
                Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                             " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +; 
                             " | Produto identificado como veiculo, por favor preencher o campo Numserie!" )
            Else
                VV1->( DbSetOrder(2) )
                If !( VV1->( DbSeek( FWxFilial("VV1") + PadR( cNumSer, TamSX3("VV1_CHASSI")[1] ) ) ) )
                    lRet := .F.
                    Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                                 " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +; 
                                 " | Item não localizado no cadastro de veiculos!" )                                     
                EndIf
            EndIf
        EndIf

    Else
        lRet := .F.
        Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Lote: " + cLote + " Endereço: " + cEndereco +;
                     " Numser: " + cNumSer + " Unitizador: " + cIDUnit + " Produto: " + AllTrim( cProduto ) +; 
                     " | Produto informado não foi localizado no cadastro de produtos!" )
    EndIf

Return lRet

/*
=====================================================================================
Programa.:              WmsTipEst
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Retorna se a estrutura é unitizada sim ou não  
=====================================================================================
*/
Static Function WmsTipEst(cArmazem,cEndereco)
    Local cUnitizado   := '1'
    Local cAliasQry := GetNextAlias()

    BeginSql Alias cAliasQry
        SELECT DC8.DC8_STATUS, DC8.DC8_TPESTR 
        FROM %Table:SBE% SBE
        INNER JOIN %Table:DC8% DC8
        ON DC8.DC8_FILIAL = %xFilial:DC8%
        AND DC8.DC8_CODEST = SBE.BE_ESTFIS
        AND DC8.%NotDel%
        WHERE SBE.BE_FILIAL = %xFilial:SBE%
        AND SBE.BE_LOCAL = %Exp:cArmazem%
        AND SBE.BE_LOCALIZ = %Exp:cEndereco%
        AND SBE.%NotDel%
    EndSql
    If (cAliasQry)->(!Eof())

        //--Se a estrutura for picking sera não unitizada independente do status
        If (cAliasQry)->DC8_TPESTR == '2' //--Picking
            cUnitizado := '2' 
        Else
            cUnitizado := (cAliasQry)->DC8_STATUS
        EndIf

    EndIf
    (cAliasQry)->(DbCloseArea())

Return cUnitizado

/*
=====================================================================================
Programa.:              zDelCont
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Exclui contagens do itens posicionado            
=====================================================================================
*/
Static Function zDelCont(cMestre, cLocal, cLote, cEndereco, cNumSer, cIDUnit, cProd )
    Local cAliasRec := ""

    //--WorkAreas Ativas
    ZZJ->( DbSetOrder(2) )
    ZZK->( DbSetOrder(2) )

    If ZZJ->( DbSeek( FWxFilial("ZZJ") + cMestre + cLocal + cLote + cEndereco + cNumSer + cIDUnit + cProd ) )
        
        //Se não estiver Transferido SB7 permite a deleção
        If !(ZZJ->ZZJ_STATUS == "3")

            If MsgYesNo("Tem certeza que deseja excluir as contagens do Mestre: " + cMestre + " Armazem: " + cLocal + " Produto: " + cProd, "Caoa" )

                Begin Transaction
                    RecLock("ZZJ", .F.)
                    ZZJ->( DbDelete() )
                    ZZJ->( MsUnlock() )

                    cAliasRec  := GetNextAlias()
                    BeginSql Alias cAliasRec
                        SELECT R_E_C_N_O_ AS RECZZK
                        FROM %Table:ZZK% ZZK
                        WHERE ZZK.ZZK_FILIAL = %xFilial:ZZK%
                            AND ZZK.ZZK_MESTRE = %Exp:cMestre%
                            AND ZZK.ZZK_LOCAL = %Exp:cLocal%
                            AND ZZK.ZZK_LOTE = %Exp:cLote%
                            AND ZZK.ZZK_ENDER = %Exp:cEndereco%
                            AND ZZK.ZZK_NUMSER = %Exp:cNumSer%
                            AND ZZK.ZZK_IDUNIT = %Exp:cIDUnit%
                            AND ZZK.ZZK_PRODUT = %Exp:cProd%
                            AND ZZK.%NotDel%
                    EndSql

                    If (cAliasRec)->(!Eof())

                        While (cAliasRec)->(!Eof())
                            ZZK->( DbGoTo( (cAliasRec)->RECZZK) )
                            RecLock("ZZK", .F.)
                            ZZK->( DbDelete() )
                            ZZK->( MsUnlock() )

                            (cAliasRec)->( DbSkip() )
                        EndDo

                        MsgInfo("Exclusão realizada com sucesso!", "Caoa")
                    Else
                        MsgAlert("Falha na exclusão das contagens, consulte o administrador do sistema!", "Caoa")
                        Disarmtransaction()
                    EndIf

                End Transaction

            EndIf

        Else
            MsgAlert( "Não é possivel a exclusão das contagens, quando o status é 'Transferido SB7'", "Caoa" )
        EndIf    

    EndIf

Return

/*
=======================================================================================
Programa.:              zLogInv
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Grava log de erro ao tentar gerar os lançamentos de inventario        
=======================================================================================
*/
Static Function zLogInv(cLog)

    cLog := "["+Time()+"]" + " - Erro na geracao de inv." + CRLF + CRLF + cLog

    If File(cPath)
        nHdl := FOpen(cPath,2)
    Else
        nHdl := FCreate(cPath)
    EndIf

    FSeek( nHdl,0,2 ) // Posiciona no final do arquivo.
    FWrite( nHdl,cLog + CRLF)
    FClose( nHdl )

Return( nHdl )

/*
=====================================================================================
Programa.:              zQrySB7
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              19/01/2021
Descricao / Objetivo:   Verifica se registro ja existe na tabela SB7 
=====================================================================================
*/
Static Function zQrySB7( cMestre, cLocal, cLote, cNumSer, cEndereco, cIdUnit, cProduto )

    BeginSql Alias cAliasSB7
        SELECT B7_DOC
        FROM %Table:SB7% SB7
        WHERE SB7.B7_FILIAL = %xFilial:SB7%
        AND SB7.B7_DOC = %exp:cMestre%
        AND SB7.B7_LOCAL = %exp:cLocal%
        AND SB7.B7_LOTECTL = %exp:cLote%
        AND SB7.B7_NUMSERI = %exp:cNumSer%
        AND SB7.B7_LOCALIZ = %exp:cEndereco%
        AND SB7.B7_IDUNIT = %exp:cIdUnit%
        AND SB7.B7_COD = %exp:cProduto%
        AND SB7.%NotDel%
    EndSql				

Return

/*
=====================================================================================
Programa.:              zCriaSB8
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              05/05/2021
Descricao / Objetivo:   cria SB8 zerada se não existir
=====================================================================================
*/
Static Function zCriaSB8(cProduto, cLocal, cLote, dDtValid)

    SB8->( DbSetOrder(3)) //B8_FILIAL + B8_PRODUTO + B8_LOCAL + B8_LOTECTL + B8_NUMLOTE + DTOS(B8_DTVALID)
    If !SB8->( DbSeek( FWxFilial("SB8") + cProduto + cLocal + cLote ) )
        RecLock("SB8",.T.)
        SB8->B8_FILIAL	:= FWxFilial("SB8")
        SB8->B8_PRODUTO	:= cProduto
        SB8->B8_LOCAL	:= cLocal
        SB8->B8_DATA	:= dDataBase
        SB8->B8_DTVALID	:= dDtValid
        SB8->B8_LOTECTL	:= cLote
        SB8->( MsUnlock() )
    EndIf

Return

/*
=====================================================================================
Programa.:              zPesqD14
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              14/06/2021
Descricao / Objetivo:   Retorna saldo do unitizador para contagem de inventario
**Rotina solicitada por Wallison e Marcelo
=====================================================================================
*/
Static Function zPesqD14(cUnitz)
    Local cQuery        := ""

	cQuery += 	" SELECT D14_IDUNIT, D14_PRODUT, D14_QTDEST" + CRLF
	cQuery += 	" FROM " + RetSqlName("D14") + " D14 " + CRLF
	cQuery += 	" WHERE D14_FILIAL = '" + FWxFilial("D14") + "' " + CRLF
    cQuery +=   "   AND D14_IDUNIT = '" + cUnitz + "' " + CRLF
    cQuery +=   "   AND D14.D_E_L_E_T_ = ' ' " + CRLF

    cQuery := ChangeQuery(cQuery)

   	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), __cTmpQry, .T., .T. )

Return
