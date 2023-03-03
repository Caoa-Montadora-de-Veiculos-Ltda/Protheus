#Include 'Protheus.ch'
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

    oModel := MPFormModel():New("WMSF014MDL",/*bPre*/, {|oModel| zVldIncZZI(oModel) },/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("ZZIMASTER",/*cOwner*/,oStruZZI)

    oModel:SetDescription("Mestre de inventario Caoa")
    oModel:GetModel("ZZIMASTER"):SetDescription("Mestre de inventario Caoa")
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
    oView:EnableTitleView('VIEW_CAB', "Mestre de inventario Caoa") 

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
    Local cAliasQry     := ""
    Local lRet          := .T.

    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        cAliasQry := GetNextAlias()
        BeginSql Alias cAliasQry
            SELECT 1
            FROM %Table:ZZI% ZZI
            WHERE ZZI.ZZI_FILIAL = %xFilial:ZZI%
                AND ZZI.ZZI_LOCAL = %Exp:oModelZZI:GetValue("ZZI_LOCAL")%
                AND ZZI.ZZI_STATUS != %Exp:'3'%
                AND ZZI.%NotDel%
        EndSql

        If (cAliasQry)->(!Eof())
            lRet := .F.
            Help( ,, "Caoa",, "Existe mestre de inventario em contagem para o armazem " +;
                            AllTrim( oModelZZI:GetValue("ZZI_LOCAL") ) + ". Por favor, informe outro armazem!", 1, 0 )                
        EndIf

        (cAliasQry)->(DbCloseArea())
    EndIf

    If oModel:GetOperation() == MODEL_OPERATION_DELETE
        
        //Permite a deleção somente se o status for Não iniciado
        If oModelZZI:GetValue("ZZI_STATUS") != "0" //(ZZI->ZZI_STATUS == "0")

            lRet := .F.
            Help( ,, "Caoa",, 'Só é possivel a exclusão do inventario quando o status for "Não iniciado"!', 1, 0 )

        EndIf 

    EndIf

Return lRet
