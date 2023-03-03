#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
/* =====================================================================================
Programa.:              ZVEIF004.PRW
Autor....:              CAOA - Sandro Ferreira
Data.....:              07/02/2022
Descricao / Objetivo:   VEI108 - Atualização Automatica Preço de Venda
Doc. Origem:            
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              VEIA060
Obs......:				ponto de entrada usado atualizar preço da tabela.	
===================================================================================== */
User Function ZVEIF004()

	Private cPerg     := "ZVEIF004"

	// Cria as perguntas em SX1
	Criaperg()
	
	// Monta tela de paramentos para usuario, se cancelar sair
	If !Pergunte(cPerg,.T.)
	   Return
	End    
    
    MsAguarde({|| fBuscPed()}, "Aguarde...", "Selecionando os Pedidos em Abertos...")

Return .t.  

/* =====================================================================================
Função...:              fBuscPed
Autor....:              CAOA - Sandro Ferreira
Data.....:              11/02/2022
Descricao / Objetivo:   Seleciona os Pedidos Para Atualização Automatica Preço de Venda
===================================================================================== */
Static Function fBuscPed()
    Local cQuery     := ""
    Local cQry       := ""
    Local lRet       := .T.
    Local nTotal     := 0
    Local nAtual     := 0
    Local aDados     := {}
    Local cPedidos   := GetNextAlias()
    Local cQtPed     := GetNextAlias()
    Private cErro    := ""

    If Select(cQtPed) > 0
  	   (cQtPed)->(DbCloseArea())
    EndIf
    cQry := " SELECT  *  FROM " + RetSQLName("VRJ")      + " VRJ "                                                                                     
    cQry += " WHERE  VRJ.VRJ_STATUS = 'A'                                                                   "
	cQry += " AND    VRJ.D_E_L_E_T_ = ' '" 
	cQry += " AND    VRJ_DATDIG >= '"  + DTOS(MV_PAR01) + "' AND VRJ_DATDIG <= '"  + DTOS(MV_PAR02) + "'"   
    cQry := ChangeQuery(cQry)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cQtPed,.T.,.T.)                  
    If Select(cQtPed) > 0
        Count To nTotal
    Endif


    If Select(cPedidos) > 0
  	   (cPedidos)->(DbCloseArea())
    EndIf
    cQuery := " SELECT                                                                                        " 
    cQuery += "  VRK_FILIAL  FILIAL                                                                           "
    cQuery += ", VRJ_PEDCOM  PEDCOM                                                                           "
    cQuery += ", VRJ_TIPVEN  TIPVEN                                                                           "
    cQuery += ", VRJ_FORPAG  FORPAG                                                                           "
	cQuery += ", VRJ_CODCLI  CODCLI                                                                           "
    cQuery += ", VRJ_LOJA    LOJA                                                                             "
	cQuery += ", VRJ_DATDIG  DATDIG                                                                           " 
    cQuery += ", VRJ_NATURE  NATURE                                                                           "
    cQuery += ", VRJ_STATUS  STATUS                                                                           "
    cQuery += ", VRK_PEDIDO  PEDIDO                                                                           "
    cQuery += ", UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(VRJ_OBSPED, 2000, 1)) AS OBSPED                     "
    cQuery += ", VRK_ITEPED  ITEPED                                                                           "
    cQuery += ", VRK_GRUMOD  GRUMOD                                                                           "
    cQuery += ", VRK_MODVEI  MODVEI                                                                           "
    cQuery += ", VRK.R_E_C_N_O_  RECNO                                                                        "
    cQuery += ", VRK_OPER    OPER                                                                             "
    cQuery += ", VRK_SEGMOD  SEGMOD                                                                           "
    cQuery += ", VRK_FABMOD  FABMOD                                                                           "
    cQuery += ", VRK_COREXT  COREXT                                                                           "
    cQuery += ", VRK_CORINT  CORINT                                                                           "
    cQuery += ", VRK_CHASSI  CHASSI                                                                           "
    cQuery += ", VRK_CODMAR  CODMAR                                                                           " 
   	cQuery += ", VRK_VALTAB  VALTAB                                                                           "
    cQuery += ", VRK_CODTES  TES                                                                              "
    cQuery += ", VRK_XID     XID                                                                              "
    cQuery += ", VRK_VALVDA  VALVDA                                                                           " 
   	cQuery += ", VRK_VALPRE  VALPRE                                                                           "
    cQuery += ", VRK_VALMOV  VALMOV                                                                           " 
   	cQuery += ", VRK_XBASST  XBASST                                                                           "
    cQuery += ", VRK_VBAICM  VBAICM                                                                           " 
    cQuery += ", VRK_ICMVEN  ICMVEN                                                                           " 
    cQuery += " FROM " + RetSQLName("VRJ")      + " VRJ " 
	cQuery += " JOIN " + RetSQLName("VRK")      + " VRK" 
	cQuery += " ON VRK.VRK_FILIAL =  VRJ.VRJ_FILIAL                                                           "
	cQuery += " AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO                                                           " 
    cQuery += " WHERE  VRJ.VRJ_STATUS = 'A'                                                                   "
	cQuery += " AND    VRJ.D_E_L_E_T_ = ' '" 
	cQuery += " AND    VRK.D_E_L_E_T_ = ' '"                         
	cQuery += " AND    VRJ_DATDIG >= '"  + DTOS(MV_PAR01) + "' AND VRJ_DATDIG <= '"  + DTOS(MV_PAR02) + "'"                     
	cQuery += " ORDER BY VRK.VRK_PEDIDO,VRK.VRK_ITEPED "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cPedidos,.T.,.T.)

    If Select(cPedidos) > 0
        ProcRegua(nTotal)
        (cPedidos)->(DbGoTop())

        While !(cPedidos)->(EOF())
            aDados  := {}
            cPed    := (cPedidos)->PEDIDO
            nAtual++

            While (cPedidos)->PEDIDO == cPed  .and. !(cPedidos)->(EOF())
                MsProcTxt("Atualizando Pedidos: " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "  Pedido:" + cPed  )
    
                //Busca preço da tabela
                nPrec     := (cPedidos)->VALTAB
                _nXBasst  := (cPedidos)->XBASST
                nPrec     := BuscaTab( (cPedidos)->FILIAL , (cPedidos)->CODMAR , (cPedidos)->MODVEI , (cPedidos)->SEGMOD , (cPedidos)->FABMOD ) 
                _nXBasst  := BuscaSt( (cPedidos)->FILIAL  , (cPedidos)->CODMAR , (cPedidos)->MODVEI , (cPedidos)->SEGMOD , (cPedidos)->FABMOD ) 

                AAdd(aDados,{  (cPedidos)->FILIAL , (cPedidos)->PEDIDO , (cPedidos)->ITEPED , nPrec, nPrec, _nXBasst, (cPedidos)->TES , (cPedidos)->OPER })

                (cPedidos)->(DbSkip())
            End

            If !AtualPed( aDados )
               MsgInfo("Pedidos  " + cPed +  "  Não Atualizado!", "Atualiza Preço Tabela")
               MsgInfo(cErro)
               cErro := " "
            EndIf

            If !AtuXBAS( aDados )
               MsgInfo("Pedidos  " + cPed +  "  Não Atualizado!", "Atualiza Preço Tabela")
               MsgInfo(cErro)
               cErro := " "
            EndIf


        EndDo

        (cPedidos)->(DbCloseArea())

        MsgInfo("Pedidos  Atualizados com Sucesso!", "Atualiza Preço Tabela") 
    Else
 
        lRet := .F. 
        MsgAlert("NãO Existem Pedidos em Abertos para Atualizar!", "Atualiza Preço Tabela")

    EndIF       

Return lRet

/* =====================================================================================
Função...:              fBuscPed
Autor....:              CAOA - Sandro Ferreira
Data.....:              11/02/2022
Descricao / Objetivo:   Atualiza os Pedidos Selecionados -  Automatica Preço de Venda
===================================================================================== */
Static Function AtualPed( aCampos )
    Local i          := 1
    Local lRet       := .T.
    Local oModel     := FWLoadModel( 'VEIA060' )           //Modelo
    Local oModelVRK  := oModel:GetModel( "MODEL_VRK" )    //SubModelo

    ProcRegua(Len(aCampos))

    DbSelectArea("VRK")
    VRK->(DbSetOrder(1))
    
    oModel:SetOperation( 4 )  //Alteração
    For i:=1 to Len(aCampos)
        dbSelectArea( 'VRJ' )
        VRJ->( dbSetOrder(1) )
        If VRJ->( dbSeek( aCampos[i][1] + ALLTRIM(aCampos[i][2] ) ))
	       oModel:Activate()
            If ( oModelVRK:SeekLine({{"VRK_FILIAL", aCampos[i][1]}, {"VRK_PEDIDO", ALLTRIM(aCampos[i][2])}, {"VRK_ITEPED", aCampos[i][3]} })  .And. !oModelVRK:IsDeleted() )	
                If !( oModel:SetValue("MODEL_VRK", "VRK_VALTAB"  , (aCampos[I][4] ) ) ) 
                    lRet := .F.
                    Exit
                EndIf
                If !( oModel:SetValue("MODEL_VRK", "VRK_VALPRE"  , (aCampos[I][5] ) ) ) 
                    lRet := .F.
                    Exit
                EndIf
                If !( oModel:SetValue("MODEL_VRK", "VRK_XBASST"  , (aCampos[I][6] ) ) ) 
                    lRet := .F.
                    Exit
                EndIf
                If !( oModel:SetValue("MODEL_VRK", "VRK_CODTES"  , (aCampos[I][7] ) ) ) 
                    lRet := .F.
                    Exit
                EndIf
                If !( oModel:SetValue("MODEL_VRK", "VRK_OPER"  , (aCampos[I][8] ) ) ) 
                    lRet := .F.
                    Exit
                EndIf
                If lRet
                    If ( lRet := oModel:VldData() )
                        oModel:CommitData()
                    EndIf
                EndIf
                If !lRet
                    aErro := oModel:GetErrorMessage()
                    cErro +=  "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']'+CRLF 
                    cErro +=  "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']'+CRLF
                    cErro +=  "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']'+CRLF
                    cErro +=  "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']'+CRLF
                    cErro +=  "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']'+CRLF
                    cErro +=  "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']'+CRLF
                    cErro +=  "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']'+CRLF
                    cErro +=  "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']'+CRLF
                    cErro +=  "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']'+CRLF
                    cErro += "Filial: " + aCampos[i][1] + " PEDIDO: " + aCampos[i][2] + " ITEM " + aCampos[i][3]  + CRLF
                Endif
                oModel:DeActivate()
            else
                Conout( "Não encontrados as linhas do Pedido: " + "Filial: " + aCampos[i][1] + " Pedido: " + aCampos[i][2] + " Item " + aCampos[i][3] )
                lRet := .F.
            ENDIF
        endif
    Next

Return lRet



/* =====================================================================================
Função...:              fBuscPed
Autor....:              CAOA - Sandro Ferreira
Data.....:              11/02/2022
Descricao / Objetivo:   Atualiza os Pedidos Selecionados -  Automatica Preço de Venda
===================================================================================== */
Static Function AtuXBAS( aCampos )
    Local i          := 1
    Local lRet       := .T.
    Local oModel     := FWLoadModel( 'VEIA060' )           //Modelo
    Local oModelVRK  := oModel:GetModel( "MODEL_VRK" )    //SubModelo

    ProcRegua(Len(aCampos))

    DbSelectArea("VRK")
    VRK->(DbSetOrder(1))
    
    oModel:SetOperation( 4 )  //Alteração
    For i:=1 to Len(aCampos)
        dbSelectArea( 'VRJ' )
        VRJ->( dbSetOrder(1) )
        If VRJ->( dbSeek( aCampos[i][1] + ALLTRIM(aCampos[i][2] ) ))
	       oModel:Activate()
            If ( oModelVRK:SeekLine({{"VRK_FILIAL", aCampos[i][1]}, {"VRK_PEDIDO", ALLTRIM(aCampos[i][2])}, {"VRK_ITEPED", aCampos[i][3]} })  .And. !oModelVRK:IsDeleted() )	
                If !( oModel:SetValue("MODEL_VRK", "VRK_XBASST"  , (aCampos[I][6] ) ) ) 
                    lRet := .F.
                    Exit
                EndIf
                If lRet
                    If ( lRet := oModel:VldData() )
                        oModel:CommitData()
                    EndIf
                EndIf
                If !lRet
                    aErro := oModel:GetErrorMessage()
                    cErro +=  "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']'+CRLF 
                    cErro +=  "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']'+CRLF
                    cErro +=  "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']'+CRLF
                    cErro +=  "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']'+CRLF
                    cErro +=  "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']'+CRLF
                    cErro +=  "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']'+CRLF
                    cErro +=  "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']'+CRLF
                    cErro +=  "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']'+CRLF
                    cErro +=  "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']'+CRLF
                    cErro += "Filial: " + aCampos[i][1] + " PEDIDO: " + aCampos[i][2] + " ITEM " + aCampos[i][3]  + CRLF
                Endif
                oModel:DeActivate()
            else
                Conout( "Não encontrados as linhas do Pedido: " + "Filial: " + aCampos[i][1] + " Pedido: " + aCampos[i][2] + " Item " + aCampos[i][3] )
                lRet := .F.
            ENDIF
        endif
    Next

Return lRet




/* =====================================================================================
Função...:              BuscaTab
Autor....:              CAOA - Sandro Ferreira
Data.....:              11/02/2022
Descricao / Objetivo:   Busca os preços da tabela de Preço de Venda
===================================================================================== */
Static Function BuscaTab( _cFilial, _cCodMar, _cModVei, _cSegMod, _cFabMod )
Local _nPrecoab     := 0
Local cQry          := ""
Local cTabela       := GetNextAlias()
cQry := "   SELECT VVP_VALTAB VALTAB                      "
cQry +=	"        FROM " + RetSQLName("VVP")      + " VVP "
cQry +=	" 		    WHERE 	VVP.VVP_FILIAL 	  = '" + xFilial("VVP") + "'"
cQry +=	" 			    AND VVP.VVP_CODMAR    = '" + _cCodMar + "'"
cQry +=	" 			    AND VVP.VVP_MODVEI    = '" + _cModVei + "'"
cQry +=	" 			    AND VVP.VVP_SEGMOD    = '" + _cSegMod + "'"
cQry +=	"               AND VVP.VVP_FABMOD  = '"   + _cFabMod + "'"
cQry +=	" 		        AND VVP.D_E_L_E_T_  = ' ' "
cQry +=	"               AND VVP.VVP_DATPRC = (  SELECT MAX(VVPB.VVP_DATPRC)  "
cQry +=	"                                        FROM " + RetSQLName("VVP")      + " VVPB "
cQry +=	"                                         WHERE  VVPB.VVP_FILIAL = VVP.VVP_FILIAL "
cQry +=	" 			                               AND VVPB.VVP_CODMAR   = VVP.VVP_CODMAR "
cQry +=	" 			                               AND VVPB.VVP_MODVEI   = VVP.VVP_MODVEI "
cQry +=	" 			                               AND VVPB.VVP_SEGMOD   = VVP.VVP_SEGMOD "
cQry +=	"                                          AND VVPB.VVP_FABMOD   = VVP.VVP_FABMOD "
cQry +=	"                                          AND VVPB.D_E_L_E_T_   = ' ' ) "
cQry := ChangeQuery(cQry)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cTabela,.T.,.T.)

If Select(cTabela) > 0
   _nPrecoab := (cTabela)->VALTAB
	(cTabela)->(DbCloseArea())
EndIf

Return _nPrecoab


/* =====================================================================================
Função...:              BuscaSt
Autor....:              CAOA - Sandro Ferreira
Data.....:              11/02/2022
Descricao / Objetivo:   Busca os preços da tabela de Preço de Venda
===================================================================================== */
Static Function BuscaSt( _cFilial, _cCodMar, _cModVei, _cSegMod, _cFabMod )
Local _nXBasst      := 0
Local cQry          := ""
Local cTabela       := GetNextAlias()
cQry := "   SELECT VVP_BASEST BASEST                      "
cQry +=	"        FROM " + RetSQLName("VVP")      + " VVP "
cQry +=	" 		    WHERE 	VVP.VVP_FILIAL 	  = '" + xFilial("VVP") + "'"
cQry +=	" 			    AND VVP.VVP_CODMAR    = '" + _cCodMar + "'"
cQry +=	" 			    AND VVP.VVP_MODVEI    = '" + _cModVei + "'"
cQry +=	" 			    AND VVP.VVP_SEGMOD    = '" + _cSegMod + "'"
cQry +=	"               AND VVP.VVP_FABMOD  = '"   + _cFabMod + "'"
cQry +=	" 		        AND VVP.D_E_L_E_T_  = ' ' "
cQry +=	"               AND VVP.VVP_DATPRC = (  SELECT MAX(VVPB.VVP_DATPRC)  "
cQry +=	"                                        FROM " + RetSQLName("VVP")      + " VVPB "
cQry +=	"                                         WHERE  VVPB.VVP_FILIAL = VVP.VVP_FILIAL "
cQry +=	" 			                               AND VVPB.VVP_CODMAR   = VVP.VVP_CODMAR "
cQry +=	" 			                               AND VVPB.VVP_MODVEI   = VVP.VVP_MODVEI "
cQry +=	" 			                               AND VVPB.VVP_SEGMOD   = VVP.VVP_SEGMOD "
cQry +=	"                                          AND VVPB.VVP_FABMOD   = VVP.VVP_FABMOD "
cQry +=	"                                          AND VVPB.D_E_L_E_T_   = ' ' ) "
cQry := ChangeQuery(cQry)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cTabela,.T.,.T.)

If Select(cTabela) > 0
   _nXBasst := (cTabela)->BASEST
	(cTabela)->(DbCloseArea())
EndIf

Return _nXBasst


/*/{Protheus.doc} CriaSx1
//TODO Cria grupo de perguntas, caso não exista.

@author 	Sandro Ferreira
@since 		05/07/2021
@version 	P12
@type 		function
/*/
Static Function Criaperg()

	Local aAreaAnt 	:= GetArea()
	Local aAreaSX1 	:= SX1->(GetArea())
	Local nY 		:= 0
	Local nJ 		:= 0
	Local aReg 		:= {}
	
	aAdd(aReg,{cPerg,"01","Da Data de Digitação      ","mv_ch1","D", 30,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SW9_1"})
	aAdd(aReg,{cPerg,"02","Até Data de Digitação     ","mv_ch2","D", 30,0,0,"G","(mv_par02>=mv_par01)","mv_par02","","","","","","","","","","","","","","","SW9_1"})


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

