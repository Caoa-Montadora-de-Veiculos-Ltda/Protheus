#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static nOperation   := 0

/*
=====================================================================================
Programa.:              ZESTF013
Autor....:              CAOA - Evandro Mariano
Data.....:              17/10/2023
Descricao / Objetivo:   Rotina usada para inclusão das contagens do inventario           
=====================================================================================
*/
User Function ZESTF013() //--U_ZESTF013()
    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZZI")
    oBrowse:SetDescription("Inventario Peças Caoa")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '0' " ,"ORANGE"   ,"Não iniciado")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '1' " ,"YELLOW"   ,"Em contagem")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '2' " ,"BLUE"     ,"Aguardando Transf. SB7")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '3' " ,"BLACK"    ,"Transferido SB7")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '4' " ,"WHITE"    ,"Parcialmente Transferido SB7")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '5' " ,"GRAY"     ,"Acerto de Estoque Parcial")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '6' " ,"GREEN"    ,"Acerto de Estoque Finalizado")
    oBrowse:AddButton("1 - Incluir Inventario"	    , { || FWExecView("Incluir" ,"ZESTF014",3,,{|| .T.}) ,oBrowse:Refresh(.F.) } )
    oBrowse:AddButton("2 - Iniciar Inventario"	    , { || zBloqArm(), oBrowse:Refresh(.F.) } ) 
    oBrowse:AddButton("3 - Preparar Inventario"	    , { || IIF( zTelaMsg() == 1,;
                                                            Processa( { || zGeraInv(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL) },;
                                                            "Preparando inventario", "Aguarde .... Realizando a carga dos registros...." ),;
                                                            Nil ),;
                                                            ZF13AtuZZI(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL), oBrowse:Refresh(.F.) } )
    oBrowse:AddButton("4 - Acerto de Estoque"	    , { || IIF( zTelaInv() == 1,;
                                                            Processa( { || zExec340(ZZI->ZZI_MESTRE) },;
                                                            "Acerto de inventario", "Aguarde .... Realizando o acerto de inventário...." ),;
                                                            Nil ),;
                                                            ZF13AtuZZI(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL), oBrowse:Refresh(.F.) } )
    oBrowse:AddButton("5 - Libera Estoque"	    , { || zBloqEst(.T., ZZI->ZZI_PRODUT, ZZI->ZZI_LOCAL, ZZI->ZZI_DATA), oBrowse:Refresh(.F.) } ) 
    oBrowse:AddButton("Gerenciar Inventario"	, { || ZESTF013A() ,ZF13AtuZZI(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL) ,oBrowse:Refresh(.F.) } )
    oBrowse:AddButton("Relatorio de Conferencia", { || u_ZWMSR002()	})                                                            
    oBrowse:AddButton("Excluir Inventario"      , { || FWExecView("Excluir" ,"ZESTF014",5,,{|| .T.}),oBrowse:Refresh(.T.) } )
    oBrowse:DisableReport()
    oBrowse:Activate()

Return

/*
=====================================================================================
Programa.:              ZESTF013A
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Browse da rotina gerenciar inventario
=====================================================================================
*/
Static Function ZESTF013A()
    Local oBrwCabec

    If !(ZZI->ZZI_STATUS == '0')

        oBrwCabec := FWMBrowse():New()
        oBrwCabec:SetAlias("ZZJ")
        oBrwCabec:SetDescription( "Gerenciamento das Contagens: " + ZZI->ZZI_MESTRE + " Armazem: " + ZZI->ZZI_LOCAL  )
        oBrwCabec:AddLegend("ZZJ->ZZJ_STATUS == '1' " ,"YELLOW" ,"Em contagem")
        oBrwCabec:AddLegend("ZZJ->ZZJ_STATUS == '2' " ,"BLUE"   ,"Aguardando Transf. SB7")
        oBrwCabec:AddLegend("ZZJ->ZZJ_STATUS == '3' " ,"BLACK"  ,"Transferido SB7")    
        oBrwCabec:AddLegend("ZZJ->ZZJ_STATUS == '5' " ,"GRAY"  ,"Acerto de Estoque Parcial")    
        oBrwCabec:AddLegend("ZZJ->ZZJ_STATUS == '6' " ,"GREEN"  ,"Acerto de Estoque Finalizado")    
        oBrwCabec:DisableDetails()
        oBrwCabec:SetAmbiente(.F.)
        oBrwCabec:SetWalkThru(.F.)
        oBrwCabec:SetFixedBrowse(.T.)
        oBrwCabec:SetFilterDefault("@"+FilCabec(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL))
        oBrwCabec:AddButton(    "Importar Contagem" ,;
                            {   || nOperation := 3,; 
                                IIF( ZZI->ZZI_STATUS != '3', zSelCSV(ZZI->ZZI_LOCAL, ZZI->ZZI_PRODUT) ,;
                                MsgAlert("Este inventario esta com o status 'Transferido SB7' e não pode receber novas contagens!", "Inventario Pecas") ),;
                                oBrwCabec:Refresh(.T.)	})
                                                            
        oBrwCabec:AddButton("Incluir Cont. Manual"  ,;
            { || nOperation := 3,;
            IIF( ZZI->ZZI_STATUS != '3', FWExecView("Incluir"    ,"ZESTF013",nOperation,,{|| .T.}),;
            MsgAlert("Este inventario esta com o status 'Transferido SB7' e não pode receber novas contagens!", "Inventario Pecas") ),;
            oBrwCabec:Refresh(.F.) })
                                                            
        oBrwCabec:AddButton("Gerenciar Contagem" ,;
            { || nOperation := 4, FWExecView("Gerenciar"  ,"ZESTF013",nOperation,,{|| .T.}),oBrwCabec:Refresh(.F.) })
                                                            
        oBrwCabec:AddButton("Excluir Contagem" ,;
            { || zDelCont(ZZJ->ZZJ_MESTRE, ZZJ->ZZJ_LOCAL, ZZJ->ZZJ_PRODUT),;
            oBrwCabec:Refresh(.T.) } )

        oBrwCabec:DisableReport()
        oBrwCabec:Activate()
    
    Else
        Help( ,, "Inventario Pecas",, 'Enquanto o status estiver "Não iniciado" não é possivel a inclusão de contagens.', 1, 0,,,,,,;
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
Programa.:              zUltCont
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Retorna o valor da quantidade eleita da ultima contagem   
=====================================================================================
*/
Static Function zUltCont( cMestre, cLocal, cProduto, lContZero, nRecnoZZK )
    Local nUltimaQtd := 0

    //--Busca pela ultima contagem
    cAliasQtd := GetNextAlias()
    BeginSql Alias cAliasQtd
        SELECT ZZK_QTDELE, ZZK_CONTAG, ZZK_QTCONT, R_E_C_N_O_ AS ZZKRECNO
        FROM %Table:ZZK% ZZK
        WHERE ZZK.ZZK_FILIAL    = %xFilial:ZZK%
            AND ZZK.ZZK_MESTRE  = %Exp:cMestre%
            AND ZZK.ZZK_LOCAL   = %Exp:cLocal%
            AND ZZK.ZZK_PRODUT  = %Exp:cProduto%
            AND ZZK_CONTAG = (  SELECT MAX(ZZK_CONTAG)
                                FROM %Table:ZZK% ZZKB 
                                WHERE ZZKB.ZZK_FILIAL   = %xFilial:ZZK%
                                    AND ZZKB.ZZK_MESTRE = %Exp:cMestre%
                                    AND ZZKB.ZZK_LOCAL  = %Exp:cLocal%
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
User Function ZF13Cont()
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
User Function ZF13QtdEle()
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
        {|oModel| LoadGrid(oModel, ZZJ->ZZJ_MESTRE, ZZJ->ZZJ_LOCAL, ZZJ->ZZJ_PRODUT  )})

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
    If nOperation == MODEL_OPERATION_INSERT
        For nI := 1 To Len(oGridZZK:aFields)
            If nI > Len(oGridZZK:aFields)
				Exit
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
            AND ZZK.ZZK_PRODUT = %Exp:oModelGrid:GetValue("ZZK_PRODUT")%
            AND ZZK.ZZK_STATUS = %Exp:'3'%
            AND ZZK.%NotDel%
    EndSql

    If (cAliasQry)->(!Eof())

        For nI := 1 To oModelGrid:Length()
            If oModelGrid:IsDeleted(nI)
                Help( ,, "Inventario Pecas",, 'Não é possivel a exclusão de registros com status "Transferido SB7"!', 1, 0 )
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
    Local cProduto      := ""
    Local lRet          := .T.
    Local cAliasQry     := ""
    Local nCont         := 0
    Local nRecZZK       := 0
    Local lContZero     := .F.
    Local nRecnoZZK     := 0

    //--Ativa Workarea
    ZZJ->( DbSetOrder(1) )

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
            cProduto    := oModelGrid:GetValue("ZZK_PRODUT")

            cAliasQry   := GetNextAlias()
            BeginSql Alias cAliasQry
                SELECT R_E_C_N_O_ AS RECZZJ
                FROM %Table:ZZJ% ZZJ
                WHERE ZZJ.ZZJ_FILIAL = %xFilial:ZZJ%
                    AND ZZJ.ZZJ_MESTRE = %Exp:cMestre%
                    AND ZZJ.ZZJ_LOCAL = %Exp:cLocal%
                    AND ZZJ.ZZJ_PRODUT = %Exp:cProduto%
                    AND ZZJ.%NotDel%
            EndSql
            
            //--Se não encontrar, realiza a inclusão
            If (cAliasQry)->( !Eof() )
                
                //--Busca ultima contagem para verificar se é eleita
                nQtdEle := zUltCont( cMestre, cLocal, cProduto, @lContZero, @nRecnoZZK )

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
                nQtdEle := zUltCont( cMestre, cLocal, cProduto, @lContZero, @nRecnoZZK )

                RecLock("ZZJ",.T.)
                    ZZJ->ZZJ_FILIAL := FWxFilial("ZZJ")
                    ZZJ->ZZJ_MESTRE := cMestre
                    ZZJ->ZZJ_LOCAL  := cLocal
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
            
            lRet := .F.
             Help( ,, "Inventario Pecas",, "Produto " + AllTrim(oModelGrid:GetValue("ZZK_PRODUT") ) +;
                               " possui controle de lote, por favor preencher o campo Lote!" , 1, 0 ) 

        EndIf

        //--Obriga o preenchimento do campo lote
        If SB1->B1_LOCALIZ == 'S'
           lRet := .F.
           Help( ,, "Inventario Pecas",, "Produto " + AllTrim(oModelGrid:GetValue("ZZK_PRODUT") ) +;
                                    " possui controle de endereço, por favor preencher o campo Endereço!" , 1, 0 ) 
        EndIf

    Else
        lRet := .F.
        Help( ,, "Inventario Pecas",, "Produto " + AllTrim(oModelGrid:GetValue("ZZK_PRODUT") ) +;
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
Static Function zSelCSV(cLocal, cProduto)
    Local cTitulo1  := "Selecione o arquivo para Carga "
    Local cExtens   := "Arquivo CSV | *.CSV"
    Local cMainPath := "C:\"
    Local cFileOpen := ""

    If U_ZGENUSER( RetCodUsr() ,"ZESTF013" ,.T.)
    
        cFileOpen := cGetFile(cExtens,cTitulo1,,cMainPath,.T.,)
        If File(cFileOpen)
            Processa({|| zImpCSV(cFileOpen, cLocal, cProduto ) }, "[ZESTF013] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." ) 
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
Static Function zImpCSV(cFileOpen, cLocal, cProduto )
    Local oModel        := ModelDef()
    Local oModelGrid    := oModel:GetModel("ZZKDETAIL")
    Local cLinha        := ""
    Local cSeparador	:= ";"
    Local aDados 		:= {}
    Local cArqLog       := SubStr(AllTrim(cFileOpen),1,At(".csv",cFileOpen))+"_log_"+StrTran(AllTrim(Time()),":","")+"_.csv"
    Local cLog          := ""
    Local lRet          := .F.
    Local nCont         := 0
    Local _nQtde        := 0
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

            If AllTrim( aDados[1] ) <> AllTrim(cLocal)
                cLog := "Local informado na planilha não corresponde ao inventario selecionado!"
                
                lErro := .T.

                //--Se não conseguir gerar arquivo de log, encerra a leitura do CSV
                If !GrvLog(cArqLog, cLog)
                    lGrvLog := .F.
                    Exit
                EndIf

                FT_FSKIP(1)
                Loop
            EndIf

            If !Empty(cProduto)
                If ( AllTrim( aDados[2] ) <> AllTrim(cProduto) )
                    cLog := "Produto informado na planilha não corresponde ao inventario selecionado!"
                    
                    lErro := .T.

                    //--Se não conseguir gerar arquivo de log, encerra a leitura do CSV
                    If !GrvLog(cArqLog, cLog)
                        lGrvLog := .F.
                        Exit
                    EndIf

                    FT_FSKIP(1)
                    Loop
                EndIf
            EndIf

            SB1->(DbSetOrder(1))
			If !(SB1->(DbSeek(FwxFilial('SB1') + AllTrim( aDados[2] ))))
                cLog := "Produto não cadastrado!"
                
                lErro := .T.

                //--Se não conseguir gerar arquivo de log, encerra a leitura do CSV
                If !GrvLog(cArqLog, cLog)
                    lGrvLog := .F.
                    Exit
                EndIf

                FT_FSKIP(1)
                Loop
            EndIf

            If At(".", AllTrim(aDados[3])) > 0 .Or. At(",", AllTrim(aDados[3])) > 0
				cLog := "Não é permitido inserir ponto ou ponto e virgula na quantidade contada."
                
                lErro := .T.

                //--Se não conseguir gerar arquivo de log, encerra a leitura do CSV
                If !GrvLog(cArqLog, cLog)
                    lGrvLog := .F.
                    Exit
                EndIf

                FT_FSKIP(1)
                Loop
			EndIf
				
			_nQtde := NoRound(Val(aDados[03]), TamSx3("ZZK_QTCONT")[02])
            If _nQtde <> NoRound(VAL(aDados[03]), 0)

                cLog := "Não é permitido quantidade fracionada na contagem."
                
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
           
            lRet := .T.

            // Carga dos dados
            oModelGrid:SetValue('ZZK_FILIAL'    ,FWxFilial("ZZK"))              
            oModelGrid:SetValue('ZZK_PRODUT'    ,PadR( aDados[2], TamSX3("ZZK_PRODUT")[1]) ) 
            oModelGrid:SetValue('ZZK_QTCONT'    ,_nQtde )
            oModelGrid:SetValue('ZZK_SEGUM'     ,0 )
            oModelGrid:SetValue('ZZK_USER'      ,RetCodUsr() )

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
                MsgAlert("Falha na importação dos registros, por favor, consulte arquivo de log!", "Inventario Pecas")
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
Programa.:              zTelaInv
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Tela de apresentação da rotina de geração de inventario SB7
=====================================================================================
*/
Static Function zTelaInv()
    Local aSays     := {}
    Local aButtons  := {} 
    Local cCadastro := "Realiza o Acerto de Inventário"
    Local nOpcA     := 0

    AADD(aSays,"Este programa tem o objetivo de realizar o acerto de estoque.")
    AADD(aSays,"Clique em OK para confirmar o acerto.")

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

    cQuery := " SELECT TMPZZJ.ZZJ_FILIAL, TMPZZJ.ZZJ_MESTRE, TMPZZJ.ZZJ_LOCAL, TMPZZJ.ZZJ_PRODUT, " + CRLF 
    cQuery += " TMPZZJ.ZZJ_STATUS, TMPZZJ.RECZZJ, ZZK.ZZK_QTCONT, ZZK.ZZK_SEGUM, " + CRLF 
    cQuery += " ZZK.ZZK_CONTAG, ZZK.R_E_C_N_O_ AS RECZZK, ZZK.ZZK_DATA " + CRLF 
    cQuery += " FROM ( " + CRLF 
    cQuery += " SELECT ZZJ_FILIAL, ZZJ_MESTRE, ZZJ_LOCAL, " + CRLF 
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
    cQuery += "  GROUP BY ZZJ_FILIAL, ZZJ_MESTRE, ZZJ_LOCAL, " + CRLF
    cQuery += "   ZZJ_PRODUT, ZZJ_STATUS, ZZJ.R_E_C_N_O_ " + CRLF
    cQuery += "  ORDER BY ZZJ_FILIAL, ZZJ_MESTRE, ZZJ_LOCAL, " + CRLF
    cQuery += "  ZZJ_PRODUT ) TMPZZJ " + CRLF
    cQuery += " JOIN " + RetSQLName("ZZK") + " ZZK " + CRLF
    cQuery += "   ON ZZK.ZZK_FILIAL = TMPZZJ.ZZJ_FILIAL " + CRLF
    cQuery += "   AND ZZK.ZZK_MESTRE = TMPZZJ.ZZJ_MESTRE " + CRLF
    cQuery += "   AND ZZK.ZZK_LOCAL = TMPZZJ.ZZJ_LOCAL " + CRLF
    cQuery += "   AND ZZK.ZZK_PRODUT = TMPZZJ.ZZJ_PRODUT " + CRLF
    cQuery += "   AND ZZK.ZZK_STATUS = '2' " + CRLF
    cQuery += "   AND ZZK.ZZK_CONTAG = ( SELECT MAX(ZZK_CONTAG) " + CRLF 
    cQuery += "                          FROM " + RetSQLName("ZZK") + " ZZKB " + CRLF
    cQuery += "                          WHERE ZZKB.ZZK_FILIAL   = TMPZZJ.ZZJ_FILIAL " + CRLF
    cQuery += "                              AND ZZKB.ZZK_MESTRE = TMPZZJ.ZZJ_MESTRE " + CRLF
    cQuery += "                              AND ZZKB.ZZK_LOCAL  = TMPZZJ.ZZJ_LOCAL " + CRLF
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
            cPath := cPath + "log_preparar_inventario_" + StrTran(DTOC(Date()),'/','-') + "_" + StrTran(TIME(),':','_') + ".txt"

            While !(cAliasQry)->( EOF() )
                
                // Incrementa a mensagem na régua.
                IncProc("Efetuando a preparação do inventario!")

                aInvent := 	{;
                            {"B7_FILIAL",	(cAliasQry)->ZZJ_FILIAL,		Nil},;
                            {"B7_COD",		(cAliasQry)->ZZJ_PRODUT,		Nil},;
                            {"B7_LOCAL",	(cAliasQry)->ZZJ_LOCAL,		    Nil},;
                            {"B7_DOC",		(cAliasQry)->ZZJ_MESTRE,		Nil},;
                            {"B7_DATA",		SToD((cAliasQry)->ZZK_DATA),	Nil},;
                            {"B7_QUANT",	(cAliasQry)->ZZK_QTCONT,		Nil},;
                            {"B7_QTSEGUM",	(cAliasQry)->ZZK_SEGUM,		    Nil},;
                            {"B7_CONTAGE",	(cAliasQry)->ZZK_CONTAG,		Nil},;
                            {"B7_ORIGEM",	"ZESTF013",					    Nil},;
                            {"B7_RECZZK",	(cAliasQry)->RECZZK,		    Nil} }

                zQrySB7( (cAliasQry)->ZZJ_MESTRE,;
                        (cAliasQry)->ZZJ_LOCAL,;
                        (cAliasQry)->ZZJ_PRODUT )

                
                (cAliasSB7)->( DbGoTop() )
                If (cAliasSB7)->( EOF() )
                    
                    //Efetua a Gravação
                    Begin Transaction

                        lMsErroAuto := .F.

                        MsExecAuto({|x,y,z| Mata270(x,y,z)}, aInvent , .F. , 3)

                        If lMsErroAuto
                            nFalhou++ 
                            //Captura o LOG para gerar um arquivo Texto.
                            aAutoErro := GETAUTOGRLOG()
                            cError :=   "Inventario: " + (cAliasQry)->ZZJ_MESTRE +;
                                        " Armazem: " + (cAliasQry)->ZZJ_LOCAL +;
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
                Help( ,, "Inventario Pecas",,   "Falha na geração dos lancamentos do inventario: " + CRLF +;
                                    "Qtd de registros processados: " + cValToChar(nGerou) + CRLF +;
                                    "Qtd de registros com erro: " + cValToChar(nFalhou) + CRLF +;
                                    "Por favor, consulte arquivo de log!", 1, 0 )
            Else
                MsgInfo("Inventario preparado com sucesso!","Inventario Pecas")
            EndIf

        Else
            Help( ,, "Inventario Pecas",, 'É necessario informar o local para gravação do log de erro para prosseguir com o processamento!', 1, 0 )
        EndIf

    Else
        Help( ,, "Inventario Pecas",, 'Só é possivel a transferencia para SB7 quando o status estiver "Aguardando Transf. SB7" ou "Parcialmente Transferido SB7"!', 1, 0 )
    EndIf

    (cAliasQry)->(DbCloseArea())

Return

/*
=====================================================================================
Programa.:              zGeraAcerto
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Geração de lançamentos de inventario 
=====================================================================================
*/
Static Function zGeraAcerto(cMestre)
    
    Local cQryTMP		:= ""
    Local cAliasTMP		:= GetNextAlias()
    Local cQryZZK		:= ""
    Local cAliasZZK		:= GetNextAlias()
    Local _aCab1        := {}
    Local _aItem        := {}
    Local _atotitem     := {}
    Local _cTm          := ""
    Local _nAcerto      := 0
    Local cError	    := ""
	Local nI		    := 0
	Local aAutoErro	    := {}
    Local nGerou        := 0
    Local nFalhou       := 0
    Local nOpcFile	    := GETF_LOCALHARD+GETF_RETDIRECTORY+GETF_NETWORKDRIVE
    Local _aCalEst      := {}
    Local cUpdate       := ""

	Private nHdl			:= 0
    Private cPath           := ""
    
    Private lAutoErrNoFile  := .T. //-- Necessario inicializar para utilização da função GetAutoGRLog()
    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    

    If Select( (cAliasTMP) ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf
    
    cQryTMP := " SELECT B7_COD, B7_LOCAL, B7_DATA, B7_DOC, B7_QUANT, B7_RECZZK, SB7.R_E_C_N_O_ AS RECSB7 FROM " + RetSQLName("SB7") + " SB7 "           + CRLF
    cQryTMP += " WHERE SB7.B7_FILIAL = '" + FWxFilial("SB7") + "' "                                                                                     + CRLF
    cQryTMP += " AND SB7.B7_DOC = '" + cMestre + "' "                                                                                                   + CRLF
    cQryTMP += " AND SB7.B7_STATUS = '1' "                                                                                                              + CRLF
    cQryTMP += " AND SB7.D_E_L_E_T_ = ' ' "                                                                                                             + CRLF
    cQryTMP += " ORDER BY SB7.B7_COD "                                                                                                                  + CRLF

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryTMP), cAliasTMP, .T., .T. )

    DbSelectArea( cAliasTMP )
    
    ProcRegua( Contar(cAliasTMP,"!Eof()") )
    
    (cAliasTMP)->( DbGoTop() )
    If !(cAliasTMP)->(EOF())

        //--Solicita pasta para gravação de log em caso de erro
        cPath := AllTrim(cGetFile("*.*","Local para salvar log de erro",,,.F.,nOpcFile,.F.,))
        If !Empty(cPath)
            cPath := cPath + "log_acerto_inventario_" + StrTran(DTOC(Date()),'/','-') + "_" + StrTran(TIME(),':','_') + ".txt"

            While !(cAliasTMP)->( EOF() )
                
                // Incrementa a mensagem na régua.
                IncProc("Gerando o acerto de estoque. Produto: " + (cAliasTMP)->B7_COD )  

                SB1->( DbSetOrder(1) )
                If SB1->( DbSeek( FWxFilial("SB1") + (cAliasTMP)->B7_COD ) )

                    //Libera o estoque para realizar o inventario.
                    zBloqEst((cAliasTMP)->B7_COD , (cAliasTMP)->B7_LOCAL, CToD("//") )

                    _aCalEst := CalcEst((cAliasTMP)->B7_COD, (cAliasTMP)->B7_LOCAL, DDatabase)   
                    
                    _nAcerto := ( (cAliasTMP)->B7_QUANT - _aCalEst[1]  )

                    If _nAcerto <> 0

                        If _nAcerto < 0
                            _nAcerto    := _nAcerto * (-1)
                            _cTm        := "600" //Retira saldo no estoque
                        Else
                            _cTm        := "300" //Adiciona saldo no estoque
                        Endif         
       
                        _aCab1 := { {"D3_DOC"       ,"INVENT"                           , NIL},;
                                    {"D3_TM"        ,_cTm                               , NIL},;
                                    {"D3_CC"        ,SB1->B1_CC                         , NIL},;
                                    {"D3_EMISSAO"   ,DDatabase                          , NIL}}

                        _aItem := { {"D3_COD"       ,(cAliasTMP)->B7_COD                ,NIL},;
                                    {"D3_UM"        ,SB1->B1_UM                         ,NIL},; 
                                    {"D3_QUANT"     ,_nAcerto                           ,NIL},;
                                    {"D3_LOCAL"     ,(cAliasTMP)->B7_LOCAL              ,NIL},;
                                    {"D3_OBSERVA"   ,"ZESTF013 - "+cMestre              ,NIL}}

                        _atotitem     := {}
                        aadd(_atotitem,_aitem)     
                        
                        //Efetua a Gravação
                        Begin Transaction

                            lAutoErrNoFile  := .T.
                            lMsErroAuto     := .F.
                            lMsHelpAuto     := .T.
                        
                            MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)

                            If lMsErroAuto
                                nFalhou++ 
                        
                                //Captura o LOG para gerar um arquivo Texto.
                                aAutoErro   := GETAUTOGRLOG()
                                cError      :=  "Inventario: " + (cAliasTMP)->B7_DOC +;
                                                "Armazem: " + (cAliasTMP)->B7_LOCAL +;
                                                "Produto: " + AllTrim( (cAliasTMP)->B7_COD ) + CRLF + CRLF
                                        
                                For nI := 1 To Len(aAutoErro)
                                    cError += AllTrim(aAutoErro[nI]) + CRLF
                                Next
                                cError += "-----------------------------------------------" + CRLF + CRLF

                                //Função para Gravar o LOG
                                nHdl := zLogInv(cError)
                            
                            Else
                                nGerou++

                                ZZK->( DbGoTo( (cAliasTMP)->B7_RECZZK ) )
                                RecLock("ZZK", .F.)
                                    ZZK->ZZK_STATUS := '6' //--Acerto de inventario concluido
                                ZZK->( MsUnlock() )

                                SB7->( DbGoTo( (cAliasTMP)->RECSB7 ) )
                                RecLock("SB7", .F.)
                                    SB7->B7_STATUS := '2' //--Acerto de inventario concluido
                                SB7->( MsUnlock() )

                                //Bloqueia o estoque para realizar movimentacao
                                zBloqEst((cAliasTMP)->B7_COD , (cAliasTMP)->B7_LOCAL, SToD((cAliasTMP)->B7_DATA) )

                            EndIf

                        End Transaction
                    Else
                        //Quando não existe a necessidade de realizar o ajuste de inventário, ele grava o status na contagem como acerto concluido
                        nGerou++

                        ZZK->( DbGoTo( (cAliasTMP)->B7_RECZZK ) )
                        RecLock("ZZK", .F.)
                            ZZK->ZZK_STATUS := '6' //--Acerto de inventario concluido
                        ZZK->( MsUnlock() )

                        SB7->( DbGoTo( (cAliasTMP)->RECSB7 ) )
                        RecLock("SB7", .F.)
                            SB7->B7_STATUS := '2' //--Acerto de inventario concluido
                        SB7->( MsUnlock() )

                        //Bloqueia o estoque para realizar movimentacao
                        zBloqEst((cAliasTMP)->B7_COD , (cAliasTMP)->B7_LOCAL, SToD((cAliasTMP)->B7_DATA) )
                        
                    EndIf
                Else
                    cError      :=  "Inventario: "  + (cAliasTMP)->B7_DOC +;
                                    "Armazem: " + (cAliasTMP)->B7_LOCAL +;
                                    "Produto: " + AllTrim( (cAliasTMP)->B7_COD ) + CRLF + CRLF +;
                                    "Produto não cadastrado no sistema" + CRLF + CRLF
                    cError += "-----------------------------------------------" + CRLF + CRLF

                    //Função para Gravar o LOG
                    nHdl := zLogInv(cError)
                EndIf
                
                (cAliasTMP)->( DbSkip() )

            EndDo
            (cAliasTMP)->( DbCloseArea() )

            If !Empty(cError)
                Help( ,, "Inventario Pecas",,   "Falha na geração dos acertos de inventario: " + CRLF +;
                                                "Qtd de registros processados: " + cValToChar(nGerou) + CRLF +;
                                                "Qtd de registros com erro: " + cValToChar(nFalhou) + CRLF +;
                                                "Por favor, consulte arquivo de log!", 1, 0 )
            Else
                
                If Select( (cAliasZZK) ) > 0
		            (cAliasZZK)->(DbCloseArea())
	            EndIf

                cQryZZK := " SELECT * FROM " + RetSQLName("ZZK") + " ZZK "          + CRLF
                cQryZZK += " WHERE ZZK.D_E_L_E_T_ = ' ' "                           + CRLF
                cQryZZK += " AND ZZK.ZZK_STATUS = '3' "                             + CRLF
                cQryZZK += " AND ZZK.ZZK_MESTRE = '" + cMestre + "' "               + CRLF

                DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryZZK), cAliasZZK, .T., .T. )

                DbSelectArea( cAliasZZK )
                (cAliasZZK)->( DbGoTop() )
                If (cAliasZZK)->(EOF())
                    
                    //--Acerto de inventario concluido
                    cUpdate := ""
                    cUpdate +=  " UPDATE " + RetSqlName("ZZJ")                      + CRLF
                    cUpdate	+=  " SET ZZJ_STATUS  = '6' "                           + CRLF
                    cUpdate +=  " WHERE ZZJ_FILIAL = '" + FWxFilial("ZZJ") + "'"    + CRLF
                    cUpdate +=  " AND ZZJ_MESTRE = '" + cMestre + "'"               + CRLF
                    cUpdate +=  " AND D_E_L_E_T_ = ' ' "                            + CRLF

                    If TcSqlExec(cUpdate) < 0
                        lRet := .F.
                        Help( ,, "Inventario Pecas",, TcSqlError() , 1, 0)
                    EndIf

                   //--Acerto de inventario concluido
                    cUpdate := ""
                    cUpdate +=  " UPDATE " + RetSqlName("ZZI")                      + CRLF
                    cUpdate	+=  " SET ZZI_STATUS  = '6' "                           + CRLF
                    cUpdate +=  " WHERE ZZI_FILIAL = '" + FWxFilial("ZZI") + "'"    + CRLF
                    cUpdate +=  " AND ZZI_MESTRE = '" + cMestre + "'"               + CRLF
                    cUpdate +=  " AND D_E_L_E_T_ = ' ' "                            + CRLF

                    If TcSqlExec(cUpdate) < 0
                        lRet := .F.
                        Help( ,, "Inventario Pecas",, TcSqlError() , 1, 0)
                    EndIf

                    MsgInfo("Acerto de inventario finalizado com sucesso!","Inventario Pecas")
                
                Else

                    ZZJ->(DbSetOrder(1))
                     If ZZJ->( DbSeek( FWxFilial("ZZJ") + cMestre ) )
                        RecLock("ZZJ", .F.)
                            ZZJ->ZZJ_STATUS := '5' //--Acerto de inventario Parcial
                        ZZJ->( MsUnlock() )
                    EndIf

                    ZZI->(DbSetOrder(1))
                    If ZZI->( DbSeek( FWxFilial("ZZI") + cMestre ) )
                        RecLock("ZZI", .F.)
                            ZZI->ZZI_STATUS := '5' //--Acerto de inventario Parcial
                        ZZI->( MsUnlock() )
                    EndIf
                
                    MsgInfo("Acerto de inventario finalizado parcialmente, existem itens pendentes!","Inventario Pecas")

                EndIf
                (cAliasZZK)->( DbCloseArea() )
            EndIf

        Else
            Help( ,, "Inventario Pecas",, 'É necessario informar o local para gravação do log de erro para prosseguir com o processamento!', 1, 0 )
        EndIf

    Else
        Help( ,, "Inventario Pecas",, 'Não existe digitação de inventário.', 1, 0 )
    EndIf

Return

/*
=====================================================================================
Programa.:              zGeraAcerto
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Geração de lançamentos de inventario 
=====================================================================================
*/
Static Function zExec340(cMestre)
    
    Local cQryTMP		:= ""
    Local cAliasTMP		:= GetNextAlias()
    Local cQryZZK		:= ""
    Local cAliasZZK		:= GetNextAlias()
    Local cError	    := ""
	Local nI		    := 0
	Local aAutoErro	    := {}
    Local nOpcFile	    := GETF_LOCALHARD+GETF_RETDIRECTORY+GETF_NETWORKDRIVE
    Local _lSB7 		:= .T.
    Local _lJob  		:= .T.
    Local _nGerou        := 0
    Local _nFalhou       := 0

	Private nHdl			:= 0
    Private cPath           := ""
    
    Private lAutoErrNoFile  := .T. //-- Necessario inicializar para utilização da função GetAutoGRLog()
    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.

    cQryTMP := " SELECT B7_COD, B7_LOCAL, B7_DATA, B7_DOC, B7_QUANT, B7_RECZZK, SB7.R_E_C_N_O_ AS RECSB7 FROM " + RetSQLName("SB7") + " SB7 "           + CRLF
    cQryTMP += " WHERE SB7.B7_FILIAL = '" + FWxFilial("SB7") + "' "                                                                                     + CRLF
    cQryTMP += " AND SB7.B7_DOC = '" + cMestre + "' "                                                                                                   + CRLF
    cQryTMP += " AND SB7.B7_STATUS = '1' "                                                                                                              + CRLF
    cQryTMP += " AND SB7.D_E_L_E_T_ = ' ' "                                                                                                             + CRLF
    cQryTMP += " ORDER BY SB7.B7_COD "                                                                                                                  + CRLF

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryTMP), cAliasTMP, .T., .T. )

    DbSelectArea( cAliasTMP )
    
    ProcRegua( Contar(cAliasTMP,"!Eof()") )

    (cAliasTMP)->( DbGoTop() )
    If !(cAliasTMP)->(EOF())

        //--Solicita pasta para gravação de log em caso de erro
        cPath := AllTrim(cGetFile("*.*","Local para salvar log de erro",,,.F.,nOpcFile,.F.,))
        If !Empty(cPath)
        
            cPath := cPath + "log_acerto_inventario_" + StrTran(DTOC(Date()),'/','-') + "_" + StrTran(TIME(),':','_') + ".txt"
        
            While !(cAliasTMP)->( EOF() )
                
                // Incrementa a mensagem na régua.
                IncProc("Gerando o acerto de estoque. Produto: " + (cAliasTMP)->B7_COD )  

                SB7->( DbGoTo( (cAliasTMP)->RECSB7 ) )    

                Begin Transaction
                    //ExecAuto
                    MSExecAuto({|x,y,z| MATA340(x,y,z)}, _lJob, cMestre, _lSB7)
            
                    If lMsErroAuto

                        _nFalhou++ 
                                        
                        //Captura o LOG para gerar um arquivo Texto.
                        aAutoErro   := GETAUTOGRLOG()
                        cError      :=  "Inventario: "  + (cAliasTMP)->B7_DOC +;
                                        "Armazem: "     + (cAliasTMP)->B7_LOCAL +;
                                        "Produto: "     + AllTrim( (cAliasTMP)->B7_COD ) + CRLF + CRLF
                                                        
                        For nI := 1 To Len(aAutoErro)
                            cError += AllTrim(aAutoErro[nI]) + CRLF
                        Next
                        cError += "-----------------------------------------------" + CRLF + CRLF

                        //Função para Gravar o LOG
                        nHdl := zLogInv(cError)

                        Disarmtransaction()
                    Else
                        
                        _nGerou++

                        ZZK->( DbGoTo( (cAliasTMP)->B7_RECZZK ) )
                        RecLock("ZZK", .F.)
                            ZZK->ZZK_STATUS := '6' //--Acerto de inventario concluido
                        ZZK->( MsUnlock() )

                    EndIf
                End Transaction
                (cAliasTMP)->( DbSkip() )

            EndDo
            (cAliasTMP)->( DbCloseArea() )

            If !Empty(cError)
                Help( ,, "Inventario Pecas",,   "Falha na geração dos acertos de inventario: " + CRLF +;
                                                "Qtd de registros processados: " + cValToChar(_nGerou) + CRLF +;
                                                "Qtd de registros com erro: " + cValToChar(_nFalhou) + CRLF +;
                                                "Por favor, consulte arquivo de log!", 1, 0 )
            Else
                
                If Select( (cAliasZZK) ) > 0
		            (cAliasZZK)->(DbCloseArea())
	            EndIf

                cQryZZK := " SELECT * FROM " + RetSQLName("ZZK") + " ZZK "          + CRLF
                cQryZZK += " WHERE ZZK.D_E_L_E_T_ = ' ' "                           + CRLF
                cQryZZK += " AND ZZK.ZZK_STATUS = '3' "                             + CRLF
                cQryZZK += " AND ZZK.ZZK_MESTRE = '" + cMestre + "' "               + CRLF

                DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryZZK), cAliasZZK, .T., .T. )

                DbSelectArea( cAliasZZK )
                (cAliasZZK)->( DbGoTop() )
                If (cAliasZZK)->(EOF())
                    
                    //--Acerto de inventario concluido
                    cUpdate := ""
                    cUpdate +=  " UPDATE " + RetSqlName("ZZJ")                      + CRLF
                    cUpdate	+=  " SET ZZJ_STATUS  = '6' "                           + CRLF
                    cUpdate +=  " WHERE ZZJ_FILIAL = '" + FWxFilial("ZZJ") + "'"    + CRLF
                    cUpdate +=  " AND ZZJ_MESTRE = '" + cMestre + "'"               + CRLF
                    cUpdate +=  " AND D_E_L_E_T_ = ' ' "                            + CRLF

                    If TcSqlExec(cUpdate) < 0
                        lRet := .F.
                        Help( ,, "Inventario Pecas",, TcSqlError() , 1, 0)
                    EndIf

                   //--Acerto de inventario concluido
                    cUpdate := ""
                    cUpdate +=  " UPDATE " + RetSqlName("ZZI")                      + CRLF
                    cUpdate	+=  " SET ZZI_STATUS  = '6' "                           + CRLF
                    cUpdate +=  " WHERE ZZI_FILIAL = '" + FWxFilial("ZZI") + "'"    + CRLF
                    cUpdate +=  " AND ZZI_MESTRE = '" + cMestre + "'"               + CRLF
                    cUpdate +=  " AND D_E_L_E_T_ = ' ' "                            + CRLF

                    If TcSqlExec(cUpdate) < 0
                        lRet := .F.
                        Help( ,, "Inventario Pecas",, TcSqlError() , 1, 0)
                    EndIf

                    MsgInfo("Acerto de inventario finalizado com sucesso!","Inventario Pecas")
                
                Else

                    ZZJ->(DbSetOrder(1))
                     If ZZJ->( DbSeek( FWxFilial("ZZJ") + cMestre ) )
                        RecLock("ZZJ", .F.)
                            ZZJ->ZZJ_STATUS := '5' //--Acerto de inventario Parcial
                        ZZJ->( MsUnlock() )
                    EndIf

                    ZZI->(DbSetOrder(1))
                    If ZZI->( DbSeek( FWxFilial("ZZI") + cMestre ) )
                        RecLock("ZZI", .F.)
                            ZZI->ZZI_STATUS := '5' //--Acerto de inventario Parcial
                        ZZI->( MsUnlock() )
                    EndIf
                
                    MsgInfo("Acerto de inventario finalizado parcialmente, existem itens pendentes!","Inventario Pecas")

                EndIf
                (cAliasZZK)->( DbCloseArea() )
            EndIf
        Else
            Help( ,, "Inventario Pecas",, 'É necessario informar o local para gravação do log de erro para prosseguir com o processamento!', 1, 0 )
        EndIf
    Else
        Help( ,, "Inventario Pecas",, 'Não existe digitação de inventário.', 1, 0 )
    EndIf

        /*Else
    
            //--Acerto de inventario concluido
            cUpdate := ""
            cUpdate +=  " UPDATE " + RetSqlName("ZZJ")                      + CRLF
            cUpdate	+=  " SET ZZJ_STATUS  = '6' "                           + CRLF
            cUpdate +=  " WHERE ZZJ_FILIAL = '" + FWxFilial("ZZJ") + "'"    + CRLF
            cUpdate +=  " AND ZZJ_MESTRE = '" + cMestre + "'"               + CRLF
            cUpdate +=  " AND D_E_L_E_T_ = ' ' "                            + CRLF

            If TcSqlExec(cUpdate) < 0
                lRet := .F.
                Help( ,, "Inventario Pecas",, TcSqlError() , 1, 0)
            EndIf

            //--Acerto de inventario concluido
            cUpdate := ""
            cUpdate +=  " UPDATE " + RetSqlName("ZZI")                      + CRLF
            cUpdate	+=  " SET ZZI_STATUS  = '6' "                           + CRLF
            cUpdate +=  " WHERE ZZI_FILIAL = '" + FWxFilial("ZZI") + "'"    + CRLF
            cUpdate +=  " AND ZZI_MESTRE = '" + cMestre + "'"               + CRLF
            cUpdate +=  " AND D_E_L_E_T_ = ' ' "                            + CRLF

            If TcSqlExec(cUpdate) < 0
                lRet := .F.
                Help( ,, "Inventario Pecas",, TcSqlError() , 1, 0)
            EndIf

            MsgInfo("Acerto de inventario finalizado com sucesso!","Inventario Pecas")

        EndIf
    EndIf*/

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

    If U_ZGENUSER( RetCodUsr() ,"ZESTF013" ,.T.)
        
        If ZZI->ZZI_STATUS == '0' 

            AADD(aSays,"Esta rotina tem o objetivo de bloquear as movimentações e")
            AADD(aSays,"incluir as contagens zeradas de estoque conforme cenario abaixo")
            AADD(aSays,"INVENTARIO: " + ZZI->ZZI_MESTRE )
            AADD(aSays,"LOCAL: " + ZZI->ZZI_LOCAL )
            If !Empty(ZZI->ZZI_PRODUT)
                AADD(aSays,"PRODUTO: " + AllTrim(ZZI->ZZI_PRODUT)  )
            EndIf
            AADD(aSays," ")
            AADD(aSays,"Clique em OK para prosseguir.")

            AADD(aButtons, { 1,.T.,{|o| nOpca := 1, o:oWnd:End() }} )
            AADD(aButtons, { 2,.T.,{|o| nOpca := 2, o:oWnd:End() }} )
                        
            FormBatch( cCadastro, aSays, aButtons )

            If nOpca == 1
                    
                If MsgYesNo("Confirma o processamento ?", "Inventario Peças" )

                    Processa({|| zProcBloq() }, "Carga de Dados.", "Aguarde .... Realizando o bloqueio e a carga dos registros zerados..." )

                EndIf

            EndIf

        Else
            Help( ,, "Inventario Pecas",, 'É necessario o status "Não iniciado" para realização do bloqueio de movimentações estoque!', 1, 0 )
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
    Local lRet          := .T.

    Private cAliasSB2   := GetNextAlias()

    Begin Transaction

        lRet := zBloqEst(.F., ZZI->ZZI_PRODUT, ZZI->ZZI_LOCAL, ZZI->ZZI_DATA)
        
        If lRet
            RecLock("ZZI",.F.)
                ZZI->ZZI_STATUS := '1' //--Em Contagem
            ZZI->( MsUnLock() )

            //--Monta consulta SBF para gerar itens com quantidade zerada
            zQrySB2( ZZI->ZZI_LOCAL, ZZI->ZZI_PRODUT, ZZI->ZZI_MESTRE )

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
                oModelGrid:SetValue('ZZK_PRODUT'    ,PadR( ( cAliasSB2 )->B2_COD, TamSX3("ZZK_PRODUT")[1]) ) 
                oModelGrid:SetValue('ZZK_QTCONT'    ,0 )
                oModelGrid:SetValue('ZZK_SEGUM'     ,0 )
                oModelGrid:SetValue('ZZK_USER'      ,RetCodUsr() )

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
Programa.:              zQrySB2
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              28/12/2020
Descricao / Objetivo:   Consulta tabela SB2 para inclusão de contagens zeradas          
=====================================================================================
*/
Static Function zQrySB2(cLocal, cProduto, cMestre )

    Local cQuery	:= ""
    
    If Select( (cAliasSB2) ) > 0
	    (cAliasSB2)->(DbCloseArea())
	EndIf

    cQuery := " SELECT B2_LOCAL, B2_COD FROM " + RetSqlName("SB2") + " SB2 "                + CRLF
    cQuery += " WHERE SB2.B2_FILIAL = '" + FWxFilial("SB2") + "' "                          + CRLF
    If !Empty(cProduto)
        cQuery += " AND SB2.B2_COD = '" + cProduto + "' "                                   + CRLF
    EndIf
    cQuery += " AND SB2.B2_LOCAL = '" + cLocal + "' "                                       + CRLF
    cQuery += " AND SB2.B2_QATU <> 0 "                                                      + CRLF
    cQuery += " AND SB2.B2_COD <> ' ' "                                                     + CRLF
    cQuery += " AND SB2.D_E_L_E_T_ = ' ' "                                                  + CRLF
    cQuery += " GROUP BY B2_LOCAL, B2_COD "                                                 + CRLF
    cQuery += " ORDER BY B2_LOCAL, B2_COD "                                                 + CRLF

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB2, .T., .T. )

    DbSelectArea( cAliasSB2 )
    (cAliasSB2)->( DbGoTop() )

Return()

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
    cQuery += "  SUM(CASE WHEN ZZJ_STATUS = '3' THEN 1 ELSE 0 END) AS PROCESSADO, " + CRLF
    cQuery += "  SUM(CASE WHEN ZZJ_STATUS = '6' THEN 1 ELSE 0 END) AS ACERTO " + CRLF
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

        If (cAliasQry)->(CONTAGEM+FINALIZADO+PROCESSADO+ACERTO) != 0
            
            nTotal := (cAliasQry)->(CONTAGEM+FINALIZADO+PROCESSADO+ACERTO)
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
            
            ElseIf (cAliasQry)->ACERTO == nTotal

                If ZZI->( DbSeek( FWxFilial("ZZI") + cMestre + cLocal ) )
                    RecLock("ZZI", .F.)
                    ZZI->ZZI_STATUS := "6" //--Acerto Finalizado
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
Static function LoadGrid(oModel, cMestre, cLocal, cProd )
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
    Local cError    := ""
    Local nI        := 0
    Local cAliasQtd := ""

    Private aErro   := {}

    //Não passa pelo valid se a chamada for da rotina de bloqueio de movimentos e geração de contagens zeradas
    If !( IsInCallStack("zProcBloq") )

        //--Valida se o produto selecionado ja possui quantidade eleita
        cAliasQtd := GetNextAlias()
        BeginSql Alias cAliasQtd
            SELECT ZZK_QTDELE
            FROM %Table:ZZK% ZZK
            WHERE ZZK.ZZK_FILIAL    = %xFilial:ZZK%
                AND ZZK.ZZK_MESTRE  = %Exp:cMestre%
                AND ZZK.ZZK_LOCAL   = %Exp:cLocal%
                AND ZZK.ZZK_PRODUT  = %Exp:cProduto%
                AND ZZK.ZZK_QTDELE  <> %Exp:0%
                AND ZZK.%NotDel%
        EndSql

        If (cAliasQtd)->( !Eof() )

            If nOperation == 3
                lRet := .F.
                Aadd( aErro, "Inventario: " + cMestre + " Armazem: " + cLocal + " Produto: " + AllTrim( cProduto ) +; 
                             " | Produto informado possui quantidade eleita!. Por favor, delete umas das contagens deste produto" +;
                             " ou informe outro produto." )
            EndIf

        EndIf
        (cAliasQtd)->( DbCloseArea() )

        ZZJ->( DbSetOrder(1) )
        ZZJ->( DbSeek( FWxFilial('ZZJ') + cMestre + cLocal ) )
        If ZZJ->ZZJ_STATUS == '3'
            lRet := .F.
            Aadd( aErro, "Inventario: " + cMestre + " Armazem: " + cLocal + " Produto: " + AllTrim( cProduto ) +; 
                         ' | Item esta com status "Transferido SB7" e não permite alterações!' )
        EndIf

        //--Valida se produto existe no armazem selecionado
        SB2->( DbSetOrder(1) )
        If !( SB2->( DbSeek( FWxFilial("SB2") + cProduto + cLocal ) ) )

            //Não encontrou o Registro na SB2, cria o SB2 com saldo 0
            CriaSB2( cProduto, cLocal )

            If !( SB2->( DbSeek( FWxFilial("SB2") + cProduto + cLocal ) ) )
                lRet := .F.
                Aadd( aErro, "Inventario: " + cMestre + " Armazem: " + cLocal + " Produto: " + AllTrim( cProduto ) +; 
                            " | Produto informado não foi localizado no armazem " + AllTrim(cLocal) + " !" )
            EndIf
        EndIf

        If !Empty( aErro )
            For nI := 1 To Len(aErro)
                cError += AllTrim(aErro[nI]) + CRLF
            Next
            cError += "-----------------------------------------------" + CRLF

            Help( ,, "Inventario Pecas",, cError, 1, 0 )
        EndIf
    EndIf

Return lRet

/*
=====================================================================================
Programa.:              zDelCont
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Exclui contagens do itens posicionado            
=====================================================================================
*/
Static Function zDelCont(cMestre, cLocal, cProd )
    Local cAliasRec := ""

    //--WorkAreas Ativas
    ZZJ->( DbSetOrder(2) )
    ZZK->( DbSetOrder(2) )

    If ZZJ->( DbSeek( FWxFilial("ZZJ") + cMestre + cLocal + cProd ) )
        
        //Se não estiver Transferido SB7 permite a deleção
        If !(ZZJ->ZZJ_STATUS == "3")

            If MsgYesNo("Tem certeza que deseja excluir as contagens do inventario: " + cMestre + " Armazem: " + cLocal + " Produto: " + cProd, "Inventario Pecas" )

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

                        MsgInfo("Exclusão realizada com sucesso!", "Inventario Pecas")
                    Else
                        MsgAlert("Falha na exclusão das contagens, consulte o administrador do sistema!", "Inventario Pecas")
                        Disarmtransaction()
                    EndIf

                End Transaction

            EndIf

        Else
            MsgAlert( "Não é possivel a exclusão das contagens, quando o status é 'Transferido SB7'", "Inventario Pecas" )
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
Static Function zQrySB7( cMestre, cLocal, cProduto )

    BeginSql Alias cAliasSB7
        SELECT B7_DOC
        FROM %Table:SB7% SB7
        WHERE SB7.B7_FILIAL = %xFilial:SB7%
        AND SB7.B7_DOC = %exp:cMestre%
        AND SB7.B7_LOCAL = %exp:cLocal%
        AND SB7.B7_COD = %exp:cProduto%
        AND SB7.%NotDel%
    EndSql				

Return

/*
=====================================================================================
Programa.:              zBloqEst
Autor....:              CAOA - Evandro Mariano
Data.....:              18/10/2023
Descricao / Objetivo:   Bloqueia e libera o status
=====================================================================================
*/
Static Function zBloqEst(_lLibera, cProduto, _cLocal, _dData)

Local _cUpdate  := ""
Local _lRet     := .T.

If _lLibera
    _dData    := CToD("//")
EndIf

If _lLibera
    //--Acerto de inventario concluido
    _cUpdate := ""
    _cUpdate := " UPDATE " + RetSqlName("SB2")                   + CRLF
    _cUpdate += " SET B2_DTINV = '" + DToS( _dData ) + "' "      + CRLF
    _cUpdate += " WHERE B2_FILIAL = '" + FWxFilial("SB2") + "'"  + CRLF
    If !Empty(cProduto)    
        _cUpdate += " AND B2_COD = '" + cProduto + "' "      + CRLF
    EndIf
    _cUpdate +=  " AND B2_LOCAL = '" + _cLocal + "'"          + CRLF
    _cUpdate +=  " AND D_E_L_E_T_ = ' ' "                            + CRLF

    If TcSqlExec(_cUpdate) < 0
        _lRet := .F.
        Help( ,, "Inventario Pecas",, TcSqlError() , 1, 0)
    Else
        MsgInfo("Estoque liberado para movimentação!", "Inventario Pecas")  
    EndIf
Else
    //--Grava data de bloqueio em todos produtos do armazem
        _cUpdate :=  " UPDATE " + RetSqlName("SB2")                         + CRLF
        _cUpdate +=  " SET B2_DTINV = '" + DToS( _dData ) + "' "            + CRLF
        _cUpdate +=  "   , B2_QEMP = 0 "                                    + CRLF
        _cUpdate +=  "   , B2_QEMPN = 0 "                                   + CRLF
        _cUpdate +=  "   , B2_RESERVA = 0 "                                 + CRLF
        _cUpdate +=  "   , B2_QPEDVEN = 0 "                                 + CRLF
        _cUpdate +=  "   , B2_NAOCLAS = 0 "                                 + CRLF
        _cUpdate +=  "   , B2_SALPEDI = 0 "                                 + CRLF
        _cUpdate +=  "   , B2_QTNP = 0 "                                    + CRLF
        _cUpdate +=  "   , B2_QNPT = 0 "                                    + CRLF
        _cUpdate +=  "   , B2_QTER = 0 "                                    + CRLF
        _cUpdate +=  "   , B2_QACLASS = 0 "                                 + CRLF
        _cUpdate +=  "   , B2_QEMPSA = 0 "                                  + CRLF
        _cUpdate +=  "   , B2_QEMPPRE = 0 "                                 + CRLF
        _cUpdate +=  "   , B2_SALPPRE = 0 "                                 + CRLF
        _cUpdate +=  " WHERE B2_FILIAL = '" + FWxFilial("SB2") + "'"        + CRLF
        If !Empty(cProduto)    
            _cUpdate +=  " AND B2_COD = '" + cProduto + "' "                + CRLF
        EndIf
        _cUpdate +=  " AND B2_LOCAL = '" + _cLocal + "'"                    + CRLF
        _cUpdate +=  " AND D_E_L_E_T_ = ' ' "                               + CRLF

        If TcSqlExec(_cUpdate) < 0
            _lRet := .F.
            Help( ,, "Inventario Pecas",, TcSqlError() , 1, 0)
        EndIf

EndIf

Return(_lRet)

