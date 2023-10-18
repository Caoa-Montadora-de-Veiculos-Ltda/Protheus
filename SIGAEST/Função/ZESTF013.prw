#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static nOperation   := 0

/*
=====================================================================================
Programa.:              ZESTF013
Autor....:              CAOA - Evandro Mariano
Data.....:              17/10/2023
Descricao / Objetivo:   Rotina usada para inclus�o das contagens do inventario           
=====================================================================================
*/
User Function ZESTF013() //--U_ZESTF013()
    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZZI")
    oBrowse:SetDescription("Inventario Pe�as Caoa")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '0' " ,"ORANGE"   ,"N�o iniciado")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '1' " ,"YELLOW"   ,"Em contagem")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '2' " ,"BLUE"     ,"Aguardando Transf. SB7")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '3' " ,"BLACK"    ,"Transferido SB7")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '4' " ,"WHITE"    ,"Parcialmente Transferido SB7")
    oBrowse:AddLegend("ZZI->ZZI_STATUS == '5' " ,"GREEN"    ,"Acerto de Estoque Finalizado")
    oBrowse:AddButton("Incluir Mestre"	    , { || FWExecView("Incluir" ,"ZESTF014",3,,{|| .T.}) ,oBrowse:Refresh(.F.) } )
    oBrowse:AddButton("Iniciar Mestre"	    , { || zBloqArm(), oBrowse:Refresh(.F.) } ) 
    oBrowse:AddButton("Gerenciar Mestre"	, { || ZESTF013A() ,ZF13AtuZZI(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL) ,oBrowse:Refresh(.F.) } )
    oBrowse:AddButton("Preparar Acerto"	    , { || IIF( zTelaMsg() == 1,;
                                                            Processa( { || zGeraInv(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL) },;
                                                            "Preparando inventario", "Aguarde .... Realizando a carga dos registros...." ),;
                                                            Nil ),;
                                                            ZF13AtuZZI(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL), oBrowse:Refresh(.F.) } )
    oBrowse:AddButton("Gerar Acerto."	    , { || IIF( zTelaInv() == 1,;
                                                            Processa( { || zGeraAcerto(ZZI->ZZI_MESTRE) },;
                                                            "Acerto de inventario", "Aguarde .... Realizando o acerto de invent�rio...." ),;
                                                            Nil ),;
                                                            ZF13AtuZZI(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL), oBrowse:Refresh(.F.) } )
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
        oBrwCabec:AddLegend("ZZJ->ZZJ_STATUS == '3' " ,"GREEN"  ,"Transferido SB7")    
        oBrwCabec:DisableDetails()
        oBrwCabec:SetAmbiente(.F.)
        oBrwCabec:SetWalkThru(.F.)
        oBrwCabec:SetFixedBrowse(.T.)
        oBrwCabec:SetFilterDefault("@"+FilCabec(ZZI->ZZI_MESTRE, ZZI->ZZI_LOCAL))
        oBrwCabec:AddButton(    "Importar Contagem" ,;
                            {   || nOperation := 3,; 
                                IIF( ZZI->ZZI_STATUS != '3', zSelCSV(ZZI->ZZI_LOCAL, ZZI->ZZI_PRODUT) ,;
                                MsgAlert("Este mestre esta com o status 'Transferido SB7' e n�o pode receber novas contagens!", "Inventario Pecas") ),;
                                oBrwCabec:Refresh(.T.)	})
                                                            
        oBrwCabec:AddButton("Incluir Cont. Manual"  ,;
            { || nOperation := 3,;
            IIF( ZZI->ZZI_STATUS != '3', FWExecView("Incluir"    ,"ZESTF013",nOperation,,{|| .T.}),;
            MsgAlert("Este mestre esta com o status 'Transferido SB7' e n�o pode receber novas contagens!", "Inventario Pecas") ),;
            oBrwCabec:Refresh(.F.) })
                                                            
        oBrwCabec:AddButton("Gerenciar Contagem" ,;
            { || nOperation := 4, FWExecView("Gerenciar"  ,"ZESTF013",nOperation,,{|| .T.}),oBrwCabec:Refresh(.F.) })
                                                            
        oBrwCabec:AddButton("Excluir Contagem" ,;
            { || zDelCont(ZZJ->ZZJ_MESTRE, ZZJ->ZZJ_LOCAL, ZZJ->ZZJ_PRODUT),;
            oBrwCabec:Refresh(.T.) } )

        oBrwCabec:DisableReport()
        oBrwCabec:Activate()
    
    Else
        Help( ,, "Inventario Pecas",, 'Enquanto o status estiver "N�o iniciado" n�o � possivel a inclus�o de contagens.', 1, 0,,,,,,;
                        {'Por favor, utilize o bot�o "Iniciar inventario" para libera��o da inclus�o de contagens.'} )
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
        Valida��o necessaria porque a rotina de gera��o de contagens zeradas possui esse comportamento e sempre
        que houver contagem com valor zero, essa sera definida como eleita at� que ocorram novas contagens, 
        se n�o ocorrerem, a contagem com valor zero sera gravada na SB7 ao rodar a rotina Transf. SB7
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
    //Estrutura de Grid, alias Real presente no dicion�rio de dados
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

    //--N�o carrega o valid se a inclus�o for via arquivo CSV ou bloqueio de movimentos
    If !( IsInCallStack("zImpCSV") ) .And. !( IsInCallStack("zProcBloq") )
        oGridZZK:SetProperty('ZZK_PRODUT'   ,MODEL_FIELD_VALID  ,{ | oModel | ValidProd( oModel ) } )
    EndIf

    //Seta campos que n�o podem ser editados em uma altera��o
    For nI := 1 To Len(oGridZZK:aFields)
        If !(oGridZZK:aFields[nI][3] $ "ZZK_QTCONT|ZZK_QTDELE")
            oGridZZK:SetProperty(oGridZZK:aFields[nI][3],MODEL_FIELD_NOUPD  , .T.)
        EndIf
    Next nI

    oModel:AddFields("ZZJMASTER",/*cOwner*/,oStrFake,/*bPre*/,/*bPost*/,{ || {""} })
    oModel:AddGrid('ZZKDETAIL','ZZJMASTER',oGridZZK,/*bLinePre*/,{|oModel|zPoslinVal(oModel)},/*bPre*/,/*bPost*/,;
        {|oModel| LoadGrid(oModel, ZZJ->ZZJ_MESTRE, ZZJ->ZZJ_LOCAL, ZZJ->ZZJ_PRODUT  )})

    oModel:SetPrimaryKey({})
    
    // � necess�rio que haja alguma altera��o na estrutura Field
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

    //-- Add cabe�alho e grid
	oView:AddField('VIEW_CAB',oStrFake,'ZZJMASTER')
    oView:AddGrid('VIEW_GRID',oGridZZK,'ZZKDETAIL')

    //--Remove campos do grid para inclus�o
    If nOperation == MODEL_OPERATION_INSERT
        For nI := 1 To Len(oGridZZK:aFields)
            If nI > Len(oGridZZK:aFields)
				Exit
			EndIf
		Next nI
    EndIf

    //--N�o permite a inclus�o de novas linhas no grid quando for altera��o
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

    //S� efetua a altera��o do campo para inser��o
    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        FwFldPut("C_STRING1", "FAKE" , /*nLinha*/, oModel)
    EndIf

Return

/*
=====================================================================================
Programa.:              zValidMdl
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   P�s valida��o do modelo      
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
                Help( ,, "Inventario Pecas",, 'N�o � possivel a exclus�o de registros com status "Transferido SB7"!', 1, 0 )
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

            //--Faz a limpeza da quantidade eleita quando houver dele��o da contagem
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
            
            //--Se n�o encontrar, realiza a inclus�o
            If (cAliasQry)->( !Eof() )
                
                //--Busca ultima contagem para verificar se � eleita
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

                //--Busca ultima contagem para verificar se � eleita
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
Descricao / Objetivo:   Valida��es dos itens        
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
                                    " possui controle de endere�o, por favor preencher o campo Endere�o!" , 1, 0 ) 
        EndIf

    Else
        lRet := .F.
        Help( ,, "Inventario Pecas",, "Produto " + AllTrim(oModelGrid:GetValue("ZZK_PRODUT") ) +;
                            ", n�o foi localizado no cadastro de produtos!" , 1, 0 ) 
    EndIf

Return lRet

/*
=====================================================================================
Programa.:              zSelCSV
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Seleciona arquivo CSV para importa��o das contagens       
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

            // Incrementa a mensagem na r�gua.
            IncProc("Efetuando a grava��o dos registros!")

            If AllTrim( aDados[1] ) <> AllTrim(cLocal)
                cLog := "Local informado na planilha n�o corresponde ao mestre selecionado!"
                
                lErro := .T.

                //--Se n�o conseguir gerar arquivo de log, encerra a leitura do CSV
                If !GrvLog(cArqLog, cLog)
                    lGrvLog := .F.
                    Exit
                EndIf

                FT_FSKIP(1)
                Loop
            EndIf

            If ( AllTrim( aDados[2] ) <> AllTrim(cProduto) )
                cLog := "Produto informado na planilha n�o corresponde ao mestre selecionado!"
                
                lErro := .T.

                //--Se n�o conseguir gerar arquivo de log, encerra a leitura do CSV
                If !GrvLog(cArqLog, cLog)
                    lGrvLog := .F.
                    Exit
                EndIf

                FT_FSKIP(1)
                Loop
            EndIf

            SB1->(DbSetOrder(1))
			If !(SB1->(DbSeek(FwxFilial('SB1') + AllTrim( aDados[2] ))))
                cLog := "Produto n�o cadastrado!"
                
                lErro := .T.

                //--Se n�o conseguir gerar arquivo de log, encerra a leitura do CSV
                If !GrvLog(cArqLog, cLog)
                    lGrvLog := .F.
                    Exit
                EndIf

                FT_FSKIP(1)
                Loop
            EndIf

            If At(".", AllTrim(aDados[3])) > 0 .Or. At(",", AllTrim(aDados[3])) > 0
				cLog := "N�o � permitido inserir ponto ou ponto e virgula na quantidade contada."
                
                lErro := .T.

                //--Se n�o conseguir gerar arquivo de log, encerra a leitura do CSV
                If !GrvLog(cArqLog, cLog)
                    lGrvLog := .F.
                    Exit
                EndIf

                FT_FSKIP(1)
                Loop
			EndIf
				
			_nQtde := NoRound(Val(aDados[03]), TamSx3("ZZK_QTCONT")[02])
            If _nQtde <> NoRound(VAL(aDados[03]), 0)

                cLog := "N�o � permitido quantidade fracionada na contagem."
                
                lErro := .T.

                //--Se n�o conseguir gerar arquivo de log, encerra a leitura do CSV
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

                    // Se os dados n�o foram validados obtemos a descri��o do erro para gerar
                    // A estrutura do vetor com erro �:
                    // [1] identificador (ID) do formul�rio de origem
                    // [2] identificador (ID) do campo de origem
                    // [3] identificador (ID) do formul�rio de erro
                    // [4] identificador (ID) do campo de erro
                    // [5] identificador (ID) do erro
                    // [6] mensagem do erro
                    // [7] mensagem da solu��o
                    // [8] Valor atribu�do
                    // [9] Valor anterior

                    lErro := .T.

                    aErro := oModel:GetErrorMessage()

                    cLog := "Linha: " + Soma1( cValToChar(nCont) ) + CRLF + AllToChar( aErro[6] )

                    //--Se n�o conseguir gerar arquivo de log, encerra a leitura do CSV
                    If !GrvLog(cArqLog, cLog)
                        lGrvLog := .F.
                        Exit
                    EndIf

                EndIf 
            
            Else

                lErro := .T.

                //--Se n�o conseguir gerar arquivo de log, encerra a leitura do CSV
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
                MsgAlert("Falha na importa��o dos registros, por favor, consulte arquivo de log!", "Inventario Pecas")
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
Descricao / Objetivo:   Tela de apresenta��o da rotina de gera��o de inventario SB7
=====================================================================================
*/
Static Function zTelaMsg()
    Local aSays     := {}
    Local aButtons  := {} 
    Local cCadastro := "Gera��o de lan�amentos de inventario"
    Local nOpcA     := 0

    AADD(aSays,"Este programa tem o objetivo de realizar a gera��o de lan�amentos de inventario.")
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
Descricao / Objetivo:   Tela de apresenta��o da rotina de gera��o de inventario SB7
=====================================================================================
*/
Static Function zTelaInv()
    Local aSays     := {}
    Local aButtons  := {} 
    Local cCadastro := "Realiza o Acerto de Invent�rio"
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
Descricao / Objetivo:   Gera��o de lan�amentos de inventario 
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
    Private lAutoErrNoFile  := .T. //-- Necessario inicializar para utiliza��o da fun��o GetAutoGRLog()
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

        //--Solicita pasta para grava��o de log em caso de erro
        cPath := AllTrim(cGetFile("*.*","Local para salvar log de erro",,,.F.,nOpcFile,.F.,))
        If !Empty(cPath)
            cPath := cPath + "LOG_geracao_de_Inventario_" + StrTran(DTOC(Date()),'/','-') + "_" + StrTran(TIME(),':','_') + ".txt"

            While !(cAliasQry)->( EOF() )
                
                // Incrementa a mensagem na r�gua.
                IncProc("Efetuando a prepara��o do inventario!")

                aInvent := 	{;
                            {"B7_FILIAL",	(cAliasQry)->ZZJ_FILIAL,		Nil},;
                            {"B7_COD",		(cAliasQry)->ZZJ_PRODUT,		Nil},;
                            {"B7_LOCAL",	(cAliasQry)->ZZJ_LOCAL,		    Nil},;
                            {"B7_DOC",		(cAliasQry)->ZZJ_MESTRE,		Nil},;
                            {"B7_DATA",		SToD((cAliasQry)->ZZK_DATA),	Nil},;
                            {"B7_QUANT",	(cAliasQry)->ZZK_QTCONT,		Nil},;
                            {"B7_QTSEGUM",	(cAliasQry)->ZZK_SEGUM,		    Nil},;
                            {"B7_CONTAGE",	(cAliasQry)->ZZK_CONTAG,		Nil},;
                            {"B7_ORIGEM",	"ZESTF013",					    Nil} }

                zQrySB7( (cAliasQry)->ZZJ_MESTRE,;
                        (cAliasQry)->ZZJ_LOCAL,;
                        (cAliasQry)->ZZJ_PRODUT )

                
                (cAliasSB7)->( DbGoTop() )
                If (cAliasSB7)->( EOF() )
                    
                    //Efetua a Grava��o
                    Begin Transaction

                        lMsErroAuto := .F.

                        MsExecAuto({|x,y,z| Mata270(x,y,z)}, aInvent , .F. , 3)

                        If lMsErroAuto
                            nFalhou++ 
                            //Captura o LOG para gerar um arquivo Texto.
                            aAutoErro := GETAUTOGRLOG()
                            cError := "Mestre: " + (cAliasQry)->ZZJ_MESTRE +;
                                    " Armazem: " + (cAliasQry)->ZZJ_LOCAL +;
                                    " Produto: " + AllTrim( (cAliasQry)->ZZJ_PRODUT ) + CRLF + CRLF
                                    
                            For nI := 1 To Len(aAutoErro)
                                cError += AllTrim(aAutoErro[nI]) + CRLF
                            Next
                            cError += "-----------------------------------------------" + CRLF + CRLF

                            //Fun��o para Gravar o LOG
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
                Help( ,, "Inventario Pecas",,   "Falha na gera��o dos lancamentos do inventario: " + CRLF +;
                                    "Qtd de registros processados: " + cValToChar(nGerou) + CRLF +;
                                    "Qtd de registros com erro: " + cValToChar(nFalhou) + CRLF +;
                                    "Por favor, consulte arquivo de log!", 1, 0 )
            Else
                MsgInfo("Inventario preparado com sucesso!","Inventario Pecas")
            EndIf

        Else
            Help( ,, "Inventario Pecas",, '� necessario informar o local para grava��o do log de erro para prosseguir com o processamento!', 1, 0 )
        EndIf

    Else
        Help( ,, "Inventario Pecas",, 'S� � possivel a transferencia para SB7 quando o status estiver "Aguardando Transf. SB7" ou "Parcialmente Transferido SB7"!', 1, 0 )
    EndIf

    (cAliasQry)->(DbCloseArea())

Return

/*
=====================================================================================
Programa.:              zGeraAcerto
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Gera��o de lan�amentos de inventario 
=====================================================================================
*/
Static Function zGeraAcerto(cMestre)
    
    Local cQuery	:= ""
	Local cAliasSB7       := GetNextAlias()
    Local cError	:= ""
	Local nI		:= 0
	Local aInvent	:= {}
	Local aAutoErro	:= {}
    Local nGerou    := 0
    Local nFalhou   := 0
    Local nOpcFile	:= GETF_LOCALHARD+GETF_RETDIRECTORY+GETF_NETWORKDRIVE

	Private nHdl			:= 0
    Private cPath           := ""
    Private lAutoErrNoFile  := .T. //-- Necessario inicializar para utiliza��o da fun��o GetAutoGRLog()
    Private lMsErroAuto     := .F.
    

    cQuery := " SELECT * FROM " + RetSQLName("SB7") + " SB7 "       + CRLF
    cQuery += " WHERE SB7.B7_FILIAL = '" + FWxFilial("SB7") + "' "  + CRLF
    cQuery += " AND SB7.B7_DOC = '" + cMestre + "' " + CRLF
    cQuery += " AND SB7.B7_STATUS = '1' " + CRLF
    cQuery += " AND SB7.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " ORDER BY SB7.B7_COD " + CRLF

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB7, .T., .T. )

    DbSelectArea( cAliasSB7 )
    ProcRegua( Contar(cAliasSB7,"!Eof()") )
    (cAliasSB7)->( DbGoTop() )
    If !(cAliasSB7)->(EOF())

        //--Solicita pasta para grava��o de log em caso de erro
        cPath := AllTrim(cGetFile("*.*","Local para salvar log de erro",,,.F.,nOpcFile,.F.,))
        If !Empty(cPath)
            cPath := cPath + "LOG_geracao_de_Inventario_" + StrTran(DTOC(Date()),'/','-') + "_" + StrTran(TIME(),':','_') + ".txt"

            While !(cAliasSB7)->( EOF() )
                
                // Incrementa a mensagem na r�gua.
                IncProc("Gerando o acerto de estoque. Produto: " + (cAliasSB7)->B7_COD )             
                    
                //Efetua a Grava��o
                Begin Transaction

                    lMsErroAuto := .F.

                    MsExecAuto({|x,y,z| Mata270(x,y,z)}, aInvent , .F. , 3)

                    If lMsErroAuto
                        nFalhou++ 
                        
                        //Captura o LOG para gerar um arquivo Texto.
                        aAutoErro := GETAUTOGRLOG()
                        cError := "Mestre: " + (cAliasQry)->ZZJ_MESTRE +;
                                " Armazem: " + (cAliasQry)->ZZJ_LOCAL +;
                                " Produto: " + AllTrim( (cAliasQry)->ZZJ_PRODUT ) + CRLF + CRLF
                                        
                        For nI := 1 To Len(aAutoErro)
                            cError += AllTrim(aAutoErro[nI]) + CRLF
                        Next
                        cError += "-----------------------------------------------" + CRLF + CRLF

                        //Fun��o para Gravar o LOG
                        nHdl := zLogInv(cError)
                            
                    Else
                        nGerou++

                        ZZK->( DbGoTo( (cAliasQry)->RECZZK ) )
                            RecLock("ZZK", .F.)
                            ZZK->ZZK_STATUS := '5' //--Acerto de inventario concluido
                        ZZK->( MsUnlock() )

                        ZZJ->( DbGoTo( (cAliasQry)->RECZZJ ) )
                            RecLock("ZZJ", .F.)
                            ZZJ->ZZJ_STATUS := '5' //--Acerto de inventario concluido
                        ZZJ->( MsUnlock() )

                    EndIf

                End Transaction
                
                (cAliasSB7)->( DbSkip() )
            EndDo
            (cAliasSB7)->( DbCloseArea() )

            If!Empty(cError)
                Help( ,, "Inventario Pecas",,   "Falha na gera��o dos aceretos de inventario: " + CRLF +;
                                    "Qtd de registros processados: " + cValToChar(nGerou) + CRLF +;
                                    "Qtd de registros com erro: " + cValToChar(nFalhou) + CRLF +;
                                    "Por favor, consulte arquivo de log!", 1, 0 )
            Else
                MsgInfo("Acerto de inventario finalizado com sucesso!","Inventario Pecas")
            EndIf

        Else
            Help( ,, "Inventario Pecas",, '� necessario informar o local para grava��o do log de erro para prosseguir com o processamento!', 1, 0 )
        EndIf

    Else
        Help( ,, "Inventario Pecas",, 'S� � possivel gerar o status quando o status estiver Transferido SB7', 1, 0 )
    EndIf

Return

/*
=====================================================================================
Programa.:              zBloqArm
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Tela de apresenta��o da rotina de bloqueio de armazem  
=====================================================================================
*/
Static Function zBloqArm()
    Local aSays         := {}
    Local aButtons      := {} 
    Local cCadastro     := "Bloqueio de movimenta��es de estoque"
    Local nOpcA         := 0

    If U_ZGENUSER( RetCodUsr() ,"ZESTF013" ,.T.)
        
        If ZZI->ZZI_STATUS == '0' 

            AADD(aSays,"Esta rotina tem o objetivo de bloquear as movimenta��es e")
            AADD(aSays,"incluir as contagens zeradas de estoque conforme cenario abaixo")
            AADD(aSays,"MESTRE: " + ZZI->ZZI_MESTRE )
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
                    
                If MsgYesNo("Confirma o processamento ?", "Inventario Pe�as" )

                    Processa({|| zProcBloq() }, "Carga de Dados.", "Aguarde .... Realizando o bloqueio e a carga dos registros zerados..." )

                EndIf

            EndIf

        Else
            Help( ,, "Inventario Pecas",, '� necessario o status "N�o iniciado" para realiza��o do bloqueio de movimenta��es estoque!', 1, 0 )
        EndIf

    EndIf
    
Return

/*
=====================================================================================
Programa.:              zProcBloq
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Realiza bloqueio de movimenta��es do armazem posicionado;
                        Realiza inclus�o de contagens zeradas.
=====================================================================================
*/
Static Function zProcBloq()
    Local oModel        := ModelDef()
    Local oModelGrid    := oModel:GetModel("ZZKDETAIL")
    Local cUpdate       := ""
    Local lRet          := .T.

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
        cUpdate +=  " AND B2_COD = '" + ZZI->ZZI_PRODUT + "' "          + CRLF
        cUpdate +=  " AND B2_LOCAL = '" + ZZI->ZZI_LOCAL + "'"          + CRLF
        cUpdate +=  " AND D_E_L_E_T_ = ' ' "                            + CRLF

        If TcSqlExec(cUpdate) < 0
            lRet := .F.
            Help( ,, "Inventario Pecas",, TcSqlError() , 1, 0)
            Disarmtransaction()
        EndIf
       
        If lRet
            RecLock("ZZI",.F.)
            ZZI->ZZI_STATUS := '1' //--Em Contagem
            ZZI->( MsUnLock() )

            //--Monta consulta SBF para gerar itens com quantidade zerada
            zQrySB2( ZZI->ZZI_LOCAL, ZZI->ZZI_PRODUT )

            ProcRegua( Contar(cAliasSB2,"!Eof()") )
            ( cAliasSB2 )->( DbGoTop() )
            While ( cAliasSB2 )->( !EOF() )

                // Incrementa a mensagem na r�gua.
                IncProc("Efetuando a inclus�o das contagens zeradas, tabela origem saldos fisico e financeiro!")

                //Ativando o modelo
                oModel:SetOperation(3)
                oModel:Activate()

                // Carga dos dados
                oModelGrid:SetValue('ZZK_FILIAL'    ,FWxFilial("ZZK"))              
                oModelGrid:SetValue('ZZK_PRODUT'    ,PadR( ( cAliasSB2 )->B2_COD, TamSX3("ZZK_PRODUT")[1]) ) 
                oModelGrid:SetValue('ZZK_QTCONT'    ,0 )
                oModelGrid:SetValue('ZZK_SEGUM'     ,0 )
                oModelGrid:SetValue('ZZK_USER'      ,RetCodUsr() )

                //Valid s� � instanciado para atender o padr�o do MVC, se n�o instanciar o commit n�o � realizado.
                //O retorno sempre sera verdadeiro, porque nenhuma valida��o � executada neste cenario
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
Descricao / Objetivo:   Consulta tabela SB2 para inclus�o de contagens zeradas          
=====================================================================================
*/
Static Function zQrySB2(cLocal, cProduto )
    
    BeginSql Alias cAliasSB2
        SELECT B2_LOCAL, B2_COD
        FROM %Table:SB2% SB2
        WHERE SB2.B2_FILIAL = %xFilial:SB2%
        AND SB2.B2_COD = %exp:cProduto%
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
Descricao / Objetivo:   Fun��o est�tica para efetuar o load dos dados do grid      
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
Descricao / Objetivo:   Grava��o de log de erro na inclus�o de lan�amentos de inventario     
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
        MsgAlert( "Importa��o de contagens interrompida, falha ao gerar o arquivo de log, erro n�: " +;
                AllTrim( Str( Ferror() ) ) + CRLF + " Por favor, consulte o administrador do sistema! " )
        
    EndIf

Return lRet

/*
=====================================================================================
Programa.:              zPosLinVal
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Valida��es do grid      
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

    //N�o passa pelo valid se a chamada for da rotina de bloqueio de movimentos e gera��o de contagens zeradas
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
                Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Produto: " + AllTrim( cProduto ) +; 
                             " | Produto informado possui quantidade eleita!. Por favor, delete umas das contagens deste produto" +;
                             " ou informe outro produto." )
            EndIf

        EndIf
        (cAliasQtd)->( DbCloseArea() )

        ZZJ->( DbSetOrder(1) )
        ZZJ->( DbSeek( FWxFilial('ZZJ') + cMestre + cLocal ) )
        If ZZJ->ZZJ_STATUS == '3'
            lRet := .F.
            Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Produto: " + AllTrim( cProduto ) +; 
                         ' | Item esta com status "Transferido SB7" e n�o permite altera��es!' )
        EndIf

        //--Valida se produto existe no armazem selecionado
        SB2->( DbSetOrder(1) )
        If !( SB2->( DbSeek( FWxFilial("SB2") + cProduto + cLocal ) ) )

            //N�o encontrou o Registro na SB2, cria o SB2 com saldo 0
            CriaSB2( cProduto, cLocal )

            If !( SB2->( DbSeek( FWxFilial("SB2") + cProduto + cLocal ) ) )
                lRet := .F.
                Aadd( aErro, "Mestre: " + cMestre + " Armazem: " + cLocal + " Produto: " + AllTrim( cProduto ) +; 
                            " | Produto informado n�o foi localizado no armazem " + AllTrim(cLocal) + " !" )
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
        
        //Se n�o estiver Transferido SB7 permite a dele��o
        If !(ZZJ->ZZJ_STATUS == "3")

            If MsgYesNo("Tem certeza que deseja excluir as contagens do Mestre: " + cMestre + " Armazem: " + cLocal + " Produto: " + cProd, "Inventario Pecas" )

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

                        MsgInfo("Exclus�o realizada com sucesso!", "Inventario Pecas")
                    Else
                        MsgAlert("Falha na exclus�o das contagens, consulte o administrador do sistema!", "Inventario Pecas")
                        Disarmtransaction()
                    EndIf

                End Transaction

            EndIf

        Else
            MsgAlert( "N�o � possivel a exclus�o das contagens, quando o status � 'Transferido SB7'", "Inventario Pecas" )
        EndIf    

    EndIf

Return

/*
=======================================================================================
Programa.:              zLogInv
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Grava log de erro ao tentar gerar os lan�amentos de inventario        
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
