#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwbrowse.ch"
#include 'fwmvcdef.ch'


/*
=====================================================================================
Programa.:              ZCFGF003
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              02/08/19
Descricao / Objetivo:   Manuten��o dos Acessos x Rotinas (CAOA)
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
User function ZCFGF003()

    local oBrowse
    Local lUserAut      := .F.
    Private aRotina     := MenuDef()

    //  U_ZGENUSER( <ID User> , <"NOME DA FUN��O"> , <.F.=N�o Exibe Msg; .T.=Exibe Msg> )
    lUserAut 	:= U_ZGENUSER( RetCodUsr() ,"ZCFGF003",.T.)
        
    If lUserAut
        //Cria um Browse Simples instanciando o FWMBrowse
        oBrowse := FWMBrowse():New()
        //Define um alias para o Browse
        oBrowse:SetAlias('SZX')
        //Adiciona uma descri��o para o Browse
        oBrowse:SetDescription('Manuten��o dos Acessos x Rotinas (CAOA)')

        // Defini��o da legenda
        oBrowse:AddLegend( "SZX->ZX_ROTINA == '**********'.And.SZX->ZX_ACESSO == 'S'"	, "BR_AZUL"	        ,"Usu�rio Com Acesso Completo" )
        oBrowse:AddLegend( "SZX->ZX_ACESSO == 'B'"	                                    , "BR_VERMELHO"		,"Usu�rio Bloqueado" )
        oBrowse:AddLegend( "SZX->ZX_ACESSO == 'S'"	                                    , "BR_VERDE"	    ,"Usu�rio Liberado" )
        oBrowse:AddLegend( "SZX->ZX_ACESSO == 'N'"	                                    , "BR_CINZA"	    ,"Usu�rio Sem Acesso" )
        oBrowse:AddLegend( "SZX->ZX_ACESSO == 'T'"	                                    , "BR_AMARELO"	    ,"Usu�rio Com Acesso Tempor�rio" )

        //Ativa o Browse
        oBrowse:Activate()
    EndIf

Return()

/*
=====================================================================================
Programa.:              MenuDef
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              02/08/19
Descricao / Objetivo:   Monta bot�es
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Pesquisar'	        ACTION 'PesqBrw'		  OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE 'Visualizar'	        ACTION 'VIEWDEF.ZCFGF003' OPERATION 2 ACCESS 0
    ADD OPTION aRotina Title 'Incluir'              ACTION 'VIEWDEF.ZCFGF003' OPERATION 3 ACCESS 0
    ADD OPTION aRotina Title 'Alterar'              ACTION 'VIEWDEF.ZCFGF003' OPERATION 4 ACCESS 0
    ADD OPTION aRotina Title 'Excluir'              ACTION 'VIEWDEF.ZCFGF003' OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Legenda'    	        ACTION 'zBrwLeg()'        OPERATION 6 ACCESS 0
    ADD OPTION aRotina TITLE 'Copiar Acessos'       ACTION 'zCopySZX()'       OPERATION 7 ACCESS 0
    ADD OPTION aRotina TITLE 'Bloqueio de Acessos'  ACTION 'zBlqSZX()'	      OPERATION 8 ACCESS 0

Return( aRotina )

/*
=====================================================================================
Programa.:              ModelDef
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              02/08/19
Descricao / Objetivo:   Monta bot�es
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static Function ModelDef()

    // Cria a estrutura a ser usada no Modelo de Dados
    Local oStruSZX  := FWFormStruct( 1, 'SZX', /*bAvalCampo*/,/*lViewUsado*/ )
    Local bPos      := { ||bPosSZX(oModel) }
    // Local bPre      := { ||bPreSZX(oModel) }
    Local oModel

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New('GENF002MDL',  /*bPreValidacao*/, bPos /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    // Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
    oModel:AddFields( 'SZXMASTER', /*cOwner*/, oStruSZX, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

    oModel:SetPrimaryKey({ 'ZX_FILIAL', 'ZX_ID', 'ZX_ROTINA' })

    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription( 'Manuten��o dos Acessos x Rotinas (CAOA)' )

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel( 'SZXMASTER' ):SetDescription( 'Manuten��o dos Acessos x Rotinas (CAOA)' )

Return( oModel )

/*
=====================================================================================
Programa.:              ViewDef
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              02/08/19
Descricao / Objetivo:   Monta bot�es
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static Function ViewDef()

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    Local oModel   := FWLoadModel( 'ZCFGF003' )

    // Cria a estrutura a ser usada na View
    Local oStruSZX := FWFormStruct( 2, 'SZX' )
    Local oView

    // Cria o objeto de View
    oView := FWFormView():New()

    // Define qual o Modelo de dados será utilizado
    oView:SetModel( oModel )

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField( 'VIEW_SZX', oStruSZX, 'SZXMASTER' )


    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox( 'TELA' , 100 )

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView( 'VIEW_SZX', 'TELA' )

Return( oView )
/*
=====================================================================================
Programa.:              zBrwLeg
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              02/08/19
Descricao / Objetivo:   Monta bot�es
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/  

Static Function zBrwLeg()

    Local aLegenda := {}

    //Monta as cores
    AADD(aLegenda,{"BR_VERMELHO"	,"Usu�rio Bloqueado"		        })
    AADD(aLegenda,{"BR_VERDE"		,"Usu�rio Liberado"	                })
    AADD(aLegenda,{"BR_CINZA"		,"Usu�rio Sem Acesso"	            })
    AADD(aLegenda,{"BR_AZUL"		,"Usu�rio Com Acesso Completo"	    })
    AADD(aLegenda,{"BR_AMARELO"		,"Usu�rio Com Acesso Tempor�rio"    })

    BrwLegenda("Status", "Pend�ncias", aLegenda)

Return()

/*
=====================================================================================
Programa.:              bPosSZX
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              05/08/19
Descricao / Objetivo:   Monta bot�es
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/  
Static Function bPosSZX(oModel)

    Local oModelSZX		:= oModel:getmodel('SZXMASTER')
    Local cRotina       := oModelSZX:GetValue('ZX_ROTINA')
    Local cId           := oModelSZX:GetValue('ZX_ID')
    Local dDataDe		:= oModelSZX:GetValue('ZX_DTAUTDE')
    Local dDataAte		:= oModelSZX:GetValue('ZX_DTAUTAT')
    Local cAcesso       := oModelSZX:GetValue('ZX_ACESSO')
    Local cMotBloq      := oModelSZX:GetValue('ZX_MOTBLOQ')
    Local nOperation    := oModel:GetOperation()
    local lRet			:= .T.
    Local lExistSZX     := .F.

    //1 - View
    //3 - Insert
    //4 - Update
    //5 - Delete
    //Inclus�o(3) ou Altera��o(4)
    If nOperation == 3 .Or. nOperation == 4

        //Verifica se j� existe esse acesso para esse usu�rio e rotina.
        lExistSZX	:= ZSeekSZX(cRotina,cId,nOperation)

        If !(lExistSZX)
            If cAcesso == "T"
                If Empty(dDataDe) .Or. Empty(dDataAte)
                    Help(NIL, NIL, "[ ZCFGF003 ] - Help", NIL, "Preenchimento da Data Tempor�ria", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Um dos campos de data tempor�ria n�o foram preenchidos corretamente, informe o per�odo de acesso tempor�rio corretamente.!"})
                    lRet := .F.
                ElseIf dDataDe < Date()
                    Help(NIL, NIL, "[ ZCFGF003 ] - Help", NIL, "Preenchimento da Data Tempor�ria", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Data inicial do acesso tempor�rio inv�lida, precisa ser maior ou igual a data de hoje.!"})
                    lRet := .F.
                ElseIf dDataAte < Date()
                    Help(NIL, NIL, "[ ZCFGF003 ] - Help", NIL, "Preenchimento da Data Tempor�ria", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Data final do acesso tempor�rio inv�lida, precisa ser maior ou igual a data de hoje.!"})
                    lRet := .F.
                ElseIf dDataDe > dDataAte
                    Help(NIL, NIL, "[ ZCFGF003 ] - Help", NIL, "Preenchimento da Data Tempor�ria", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Data Inicial � maior que a data final, Verifique novamente as datas.!"})
                    lRet := .F.
                EndIf
            ElseIf cAcesso == "B"
                If Empty(cMotBloq)
                    Help(NIL, NIL, "[ ZCFGF003 ] - Help", NIL, "Motivo do bloqueio n�o preenchido", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Quando um usu�rio � bloqueado, � obrigatorio o preenchimento do Motivo do Bloqueio"})
                    lRet := .F.
                EndIf
            ElseIf "(" $ cRotina .Or. "U_" $ cRotina .Or. "u_" $ cRotina .Or. ")" $ cRotina
                Help(NIL, NIL, "[ ZCFGF003 ] - Help", NIL, "Nome da Rotina preenchida de forma incorreta.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para rotinas de usu�rio, n�o existe a necessidade de adicionar a express�o U_ ou Par�nteses () , Cadastre somente o nome da Rotina. Ex.: ZCFGF003."})
                lRet := .F.
            EndIf
        Else
            lRet := .F.
        EndIf
    Endif

Return( lRet )

/*
=====================================================================================
Programa.:              ZSeekSZX
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              05/08/19
Descricao / Objetivo:   Verifica se existe algum cadastro igual o que est� 
                        sendo realizado.
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/ 
Static Function ZSeekSZX(cRotina,cId,nOperation)

    Local cQrySZX   	:= ""
    Local cAliSZX 		:= GetNextAlias()
    Local cRotSeek      := cRotina
    Local cIDSeek       := cId
    Local nOperSeek     := nOperation
    Local lRetorno      := .F.
    Local cMsgErro      := ""
    Local cMsgSolu      := ""
    Local lSeek         := .T.

//� uma altera��o e Rotina n�o mudou e ID n�o mudou, n�o precisa realizar uma nova busca.
    If ( nOperSeek == 4 .And. ( AllTrim(SZX->ZX_ROTINA) == AllTrim(cRotSeek) .And. AllTrim(SZX->ZX_ID) == AllTrim(cIDSeek)  ) )
        lSeek := .F.
    EndIf

    If lSeek

        If Select((cAliSZX)) > 0
            (cAliSZX)->(DbCloseArea())
        EndIf

        cQrySZX := ""
        cQrySZX += " SELECT ZX_ROTINA, ZX_ID, ZX_LOGIN, ZX_ACESSO "                             + CRLF
        cQrySZX += " FROM "+RetSQLName('SZX')+" SZX "                                           + CRLF
        cQrySZX += " WHERE SZX.ZX_FILIAL = '"+FWxFilial('SZX')+"' "                             + CRLF
        cQrySZX += " AND SZX.ZX_ID = '" + cIDSeek + "' "                       					+ CRLF
        cQrySZX += " AND (SZX.ZX_ROTINA = '" + cRotSeek + "' OR SZX.ZX_ROTINA = '**********') " + CRLF
        cQrySZX += " AND SZX.D_E_L_E_T_ = ' ' "                                					+ CRLF
        cQrySZX += " ORDER BY SZX.ZX_FILIAL, SZX.ZX_ID, SZX.ZX_ROTINA "       					+ CRLF

        cQrySZX := ChangeQuery(cQrySZX)

        //Executa a consulta
        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQrySZX), cAliSZX, .T., .T. )

        DbSelectArea((cAliSZX))
        (cAliSZX)->(dbGoTop())
        If (cAliSZX)->(!Eof())
            If (cAliSZX)->ZX_ROTINA == "**********"
                If (cAliSZX)->ZX_ACESSO $ "S|T"
                    cMsgErro      := "Usu�rio com perfil de acesso Completo (FULL)"
                    cMsgSolu      := "N�o existe a necessidade de cadastrar o seu usu�rio para essa rotina, seu usu�rio possui acesso Completo!"
                ElseIf !((cAliSZX)->ZX_ACESSO) $ "S|T"
                    cMsgErro      := "Usu�rio com perfil de acesso Completo (FULL) - Com Problema"
                    cMsgSolu      := "Usu�rio possui cadastro Completo (FULL), por�m existe diverg�ncia no acesso cadastrado, verifique o cadastro existente e os acessos para esse usu�rio!"
                EndIf
            Else
                If (cAliSZX)->ZX_ACESSO $ "S|T"
                    cMsgErro      := "Usu�rio j� possui cadastro para essa rotina."
                    cMsgSolu      := "N�o existe a necessidade de cadastrar o seu usu�rio para essa rotina, seu usu�rio possui acesso!"
                ElseIf !((cAliSZX)->ZX_ACESSO) $ "S|T"
                    cMsgErro      := "Usu�rio j� possui cadastro para essa rotina - Com Problema"
                    cMsgSolu      := "Usu�rio possui cadastro, por�m existe diverg�ncia no acesso cadastrado, verifique o cadastro existente e os acessos para esse usu�rio!"
                EndIf
            EndIf
            Help(NIL, NIL, "[ ZCFGF003 ] - Help", NIL, cMsgErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgSolu})
            lRetorno := .T.
        EndIf
        (cAliSZX)->(DbCloseArea())
    EndIf

Return( lRetorno )

/*
=====================================================================================
Programa.:              ZCopySZX
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              05/08/19
Descricao / Objetivo:   Copia os direitos de um Usu�rio para Outro
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/ 
Static Function ZCopySZX()

Local cQryUpd   	:= ""
// Local cError        := ""
Local cQryCopy   	:= ""
Local cAliCopy 		:= GetNextAlias()
Local cPerg         := "ZCFGF003P1"
Local lMaster       := .F.
Local lContinua     := .T.
Local lUpdSZX       := .F.

DbSelectArea("SZX")
SZX->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA

Pergunte(cPerg,.T.)

If !( Empty(MV_PAR01) .Or. Empty(MV_PAR02) )
    If !( MV_PAR01 == MV_PAR02 )
        If MsgYesNo("Deseja prosseguir com a seguinte c�pia ?" + CRLF + CRLF + "Copiar Acessos" + CRLF + CRLF + "De:   " + MV_PAR01 + " - " + AllTrim( UsrRetName( MV_PAR01 ) ) + CRLF + "Para: " + MV_PAR02 + " - " + AllTrim( UsrRetName( MV_PAR02 ) ) + CRLF + CRLF + "Deseja realmente continuar ??? ","ZCFGF003")

            //Verifica se o DE: possui acesso Completo(FULL), caso possua, n�o realiza a copia.
            SZX->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA
            If SZX->( dbSeek( xFilial("SZX") + MV_PAR01 + "**********" ))
                lMaster := .T.
            EndIf

            If !( lMaster )

                //Verifica se o DE: possui cadastro de acesso, caso n�o possua, cancela a opera��o
                SZX->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA
                If SZX->( dbSeek( xFilial("SZX") + MV_PAR01 ))
                
                    //Verifica se o PARA: possui cadastro de acesso, caso possua, pergunta se realmente deseja substituir.
                    SZX->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA
                    If SZX->( dbSeek( xFilial("SZX") + MV_PAR02 ))
                        If MsgYesNo("O usu�rio: " + MV_PAR02 + " - " + AllTrim( UsrRetName( MV_PAR02 ) ) + " possui um cadastro de acesso."    + CRLF + CRLF + "Deseja realmente substituir os acessos ??? ","ZCFGF003")
                            
                            //Confirmando a substitui��o, apaga os registros do PARA:
                            lContinua := .T.
                            cQryUpd := ""
                            cQryUpd += " UPDATE " + RetSqlName("SZX")       + CRLF
                            cQryUpd += " SET D_E_L_E_T_ = '*' "             + CRLF
                            cQryUpd += " WHERE D_E_L_E_T_ = ' ' "           + CRLF
                            cQryUpd += " AND ZX_ID = '" + MV_PAR02 + "' "   + CRLF
                            
                            lUpdSZX :=  TcSqlExec(cQryUpd)
        
                            If lUpdSZX <> 0
                                ApMsgStop("Problema para substituir os registros! Tente novamente." + CRLF + CRLF + "SQL Error: " +TcSqlError() ,"ZCFGF003")    
                                lContinua := .F.
                            Else
                                lContinua := .T.
                            Endif   
                        Else
                            lContinua := .F.
                        EndIf
                    EndIf
                
                    If lContinua
                        If Select((cAliCopy)) > 0
                            (cAliCopy)->(DbCloseArea())
                        EndIf

                        cQryCopy := ""
                        cQryCopy += " SELECT * "                                            + CRLF
                        cQryCopy += " FROM "+RetSQLName('SZX')+" SZX "                      + CRLF
                        cQryCopy += " WHERE SZX.ZX_FILIAL = '"+FWxFilial('SZX')+"' "        + CRLF
                        cQryCopy += " AND SZX.ZX_ID = '" + MV_PAR01 + "' "                  + CRLF
                        cQryCopy += " AND SZX.D_E_L_E_T_ = ' ' "                            + CRLF
                        cQryCopy += " ORDER BY SZX.ZX_FILIAL, SZX.ZX_ID, SZX.ZX_ROTINA "    + CRLF

                        cQryCopy := ChangeQuery(cQryCopy)

                        //Executa a consulta
                        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryCopy), cAliCopy, .T., .T. )

                        DbSelectArea((cAliCopy))
                        (cAliCopy)->(dbGoTop())
                        While (cAliCopy)->(!Eof())

                            Reclock( "SZX" , .T. )
                                SZX->ZX_FILIAL      := xFilial("SZX")
                                SZX->ZX_ROTINA      := (cAliCopy)->ZX_ROTINA
                                SZX->ZX_ID          := MV_PAR02
                                SZX->ZX_LOGIN       := UsrRetName( MV_PAR02 )
                                SZX->ZX_NOME        := UsrFullName( MV_PAR02 )
                                SZX->ZX_DEPART      := AllTrim( MV_PAR03 )
                                SZX->ZX_ACESSO      := (cAliCopy)->ZX_ACESSO
                                SZX->ZX_DESCROT     := (cAliCopy)->ZX_DESCROT
                                SZX->ZX_DTAUTDE     := SToD( (cAliCopy)->ZX_DTAUTDE )
                                SZX->ZX_DTAUTAT     := SToD( (cAliCopy)->ZX_DTAUTAT )
                                SZX->ZX_MOTBLOQ     := If( (cAliCopy)->ZX_ACESSO == "B" , "BLOQUEIO HERDADO DEVIDO A C�PIA DO USU�RIO: "+MV_PAR01 , "" )
                            SZX->(MsUnlock())   

                            (cAliCopy)->(DbSkip())
                        EndDo
                        ApMsgInfo("Usu�rio copiado com Sucesso!!","[ ZCFGF003 ] - Conclu�do")
                        (cAliCopy)->(DbCloseArea())
                    Else
                        ApMsgStop("Processo abortado com sucesso.","ZCFGF003")  
                    EndIf
                Else
                    ApMsgStop("O usu�rio: " + MV_PAR01 +" - " + AllTrim( UsrRetName( MV_PAR01 ) ) + CRLF + CRLF + "N�o possui nenhum registro de acesso cadastrado, revise os par�metros e tente novamente!!","ZCFGF003")
                EndIf
            Else
                ApMsgStop("O Usu�rio que est� sendo copiado, possui o perfil de acesso Completo (FULL)"+ CRLF + CRLF + "N�o � permitido a c�pia desse tipo de perfil, realize um novo cadastro.","ZCFGF003")
            EndIf
        Else
            ApMsgStop("Processo cancelado com sucesso.","ZCFGF003")
        EndIf
    Else
        ApMsgStop("N�o � permitida a c�pia para o mesmo usu�rio de origem!","ZCFGF003")
    EndIf
Else
    ApMsgStop("� necess�rio o preenchimento de ambos os usu�rios para c�pia!","ZCFGF003")
EndIf

Return()

/*
=====================================================================================
Programa.:              ZBlqSZX
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              05/08/19
Descricao / Objetivo:   Bloqueia direitos de um Usu�rio
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/ 
Static Function ZBlqSZX()

Local cQryBlq   	:= ""
Local cAliBlq 		:= GetNextAlias()
Local cPerg         := "ZCFGF003P2"
// Local lMaster       := .F.
// Local lContinua     := .T.
// Local lUpdSZX       := .F.

DbSelectArea("SZX")
SZX->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA

Pergunte(cPerg,.T.)

If !( Empty(MV_PAR01) )
    If MsgYesNo("Deseja prosseguir com o bloqueio seguinte ?" + CRLF + CRLF + "Bloquear Usu�rio: " + MV_PAR01 + " - " + AllTrim( UsrRetName( MV_PAR01 ) ) + CRLF + CRLF + "Deseja realmente realizar o bloqueio ??? ","ZCFGF003")

        //Verifica se o usu�rio de bloqueio possui cadastro de acesso, caso n�o possua, cancela a opera��o
        SZX->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA
        If SZX->( dbSeek( xFilial("SZX") + MV_PAR01 ))

            If Select( (cAliBlq) ) > 0
                (cAliBlq)->(DbCloseArea())
            EndIf

            cQryBlq := ""
            cQryBlq += " SELECT ZX_FILIAL, ZX_ID, ZX_ROTINA  "                 + CRLF
            cQryBlq += " FROM "+RetSQLName('SZX')+" SZX "                      + CRLF
            cQryBlq += " WHERE SZX.ZX_FILIAL = '"+FWxFilial('SZX')+"' "        + CRLF
            cQryBlq += " AND SZX.ZX_ID = '" + MV_PAR01 + "' "                  + CRLF
            cQryBlq += " AND SZX.D_E_L_E_T_ = ' ' "                            + CRLF
            cQryBlq += " ORDER BY SZX.ZX_FILIAL, SZX.ZX_ID, SZX.ZX_ROTINA "    + CRLF

            cQryBlq := ChangeQuery(cQryBlq)

            //Executa a consulta
            DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryBlq), cAliBlq, .T., .T. )

            DbSelectArea((cAliBlq))
            (cAliBlq)->(dbGoTop())
            While (cAliBlq)->(!Eof())
                
                SZX->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA
                If SZX->( DbSeek( (cAliBlq)->ZX_FILIAL  + (cAliBlq)->ZX_ID + (cAliBlq)->ZX_ROTINA  ))
                    Reclock( "SZX" , .F. )
                        SZX->ZX_ACESSO      := "B"
                        SZX->ZX_MOTBLOQ     := AllTrim( MV_PAR02 )
                    SZX->(MsUnlock())   
                EndIf

                (cAliBlq)->(DbSkip())
            EndDo
            ApMsgInfo("Usu�rio bloqueado com Sucesso!!","[ ZCFGF003 ] - Conclu�do")
            (cAliBlq)->(DbCloseArea())
        Else
            ApMsgStop("O usu�rio: " + MV_PAR01 +" - " + AllTrim( UsrRetName( MV_PAR01 ) ) + CRLF + CRLF + "N�o possui nenhum registro de acesso cadastrado, revise os par�metros e tente novamente!!","ZCFGF003")
        EndIf
    Else
        ApMsgStop("Processo cancelado com sucesso.","ZCFGF003")
    EndIf
Else
    ApMsgStop("� necess�rio o preenchimento do usu�rio que ser� bloqueado!","ZCFGF003")
EndIf

Return()
