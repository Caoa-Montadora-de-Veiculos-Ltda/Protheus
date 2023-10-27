#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"
#Include 'FWMVCDef.ch'

/*
=====================================================================================
Programa.:              ModelDef
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Modelo da rotina de inclusão de mestre de inventario         
=====================================================================================
*/
Static Function ModelDef()
    Local oModel    := Nil
    Local oStruZZI  := FWFormStruct(1, "ZZI")

    oModel := MPFormModel():New("ZESTF014",/*bPre*/, {|oModel| zVldIncZZI(oModel) },/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("ZZIMASTER",/*cOwner*/,oStruZZI)

    oModel:SetDescription("Inventario Peças")
    oModel:GetModel("ZZIMASTER"):SetDescription("Inventario Peças")
    oModel:SetPrimaryKey({})

Return oModel

/*
=====================================================================================
Programa.:              ViewDef
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   View da rotina de inclusão de mestre de inventario 
=====================================================================================
*/
Static Function ViewDef()
    Local oModel        := ModelDef()
    Local oStruZZI      := FWFormStruct(2, "ZZI")
    Local oView         := Nil

    //-- Cria View e seta o modelo de dados
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //-- Add cabeçalho
	oView:AddField('VIEW_CAB',oStruZZI,'ZZIMASTER')

    //-- Define os títulos do cabeçalho
    oView:EnableTitleView('VIEW_CAB', "Inventario Peças") 

    //-- Seta o dimensionamento de tamanho
    oView:CreateHorizontalBox('ZZI_DADOS',100)

    //--Amarra a view com as box
    oView:SetOwnerView('VIEW_CAB','ZZI_DADOS')

Return oView

/*
=====================================================================================
Programa.:              zVldIncZZI
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              08/12/2020
Descricao / Objetivo:   Pós validações da inclusão          
=====================================================================================
*/
Static Function zVldIncZZI(oModel)
	Local oModelZZI     := oModel:GetModel("ZZIMASTER") 
    Local cAliasQry     := GetNextAlias()
    Local cQryZZI       := ""
    Local lRet          := .T.

    If oModel:GetOperation() == MODEL_OPERATION_INSERT

        cQryZZI := " SELECT * FROM " + RetSQLName("ZZI") + " ZZI "                               + CRLF
        cQryZZI += " WHERE ZZI.D_E_L_E_T_ = ' ' "                                               + CRLF
        cQryZZI += " AND ZZI.ZZI_STATUS <> '3' "                                                + CRLF
        cQryZZI += " AND ZZI.ZZI_LOCAL = '" + oModelZZI:GetValue("ZZI_LOCAL") + "' "            + CRLF
        If !Empty(oModelZZI:GetValue("ZZI_PRODUT"))
            cQryZZI += " AND ZZI.ZZI_PRODUT = '" + oModelZZI:GetValue("ZZI_PRODUT") + "' "            + CRLF
        EndIf

        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryZZI), cAliasQry, .T., .T. )

        DbSelectArea( cAliasQry )
        (cAliasQry)->( DbGoTop() )
        If (cAliasQry)->(!Eof())
            lRet := .F.
            Help( ,, "Caoa",, "Existe inventario em contagem para o armazem " +;
                            AllTrim( oModelZZI:GetValue("ZZI_LOCAL") ) + ". Por favor, informe outro armazem!", 1, 0 )                
        EndIf

        (cAliasQry)->(DbCloseArea())
    EndIf

    If oModel:GetOperation() == MODEL_OPERATION_DELETE
        
        //Permite a deleção somente se o status for Não iniciado
        If !( oModelZZI:GetValue("ZZI_STATUS") $ "0|1") //'0'- Não iniciado | '1' - Em contagem

            lRet := .F.
            Help( ,, "Caoa",, 'Só é possivel a exclusão do inventario quando o status for "Não iniciado"!', 1, 0 )

        EndIf 

    EndIf

Return lRet
