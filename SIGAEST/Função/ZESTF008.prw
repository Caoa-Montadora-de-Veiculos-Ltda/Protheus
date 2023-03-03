#Include "Protheus.Ch"
#Include "TopConn.Ch"
#INCLUDE "TOTVS.Ch"

/*
=====================================================================================
Programa.:              ZESTF008
Autor....:              CAOA - Sandro Ferreira
Data.....:              18/04/2022
Descricao / Objetivo:   Funcao para correção B2_QACLASS
Doc. Origem:            EST110 - Rotina de correção B2_QACLASS
Solicitante:            Estoque
Uso......:              CAOA Montadora.
Obs......:
=====================================================================================
*/
User Function ZESTF008()
Private oDlg        := Nil
Private oPanel      := Nil
Private oSay        := Nil
Private cArmazem    := "907"
Private cEnderec    := "DCE01          "
Private cEndeAte    := "DCE01          "
Private cDoProd     := SPACE(23)
Private cAteProd    := SPACE(23)
Default oModel	     := Nil

oDlg                := FWDialogModal():New()
oDlg:SetBackGround( .T. )
oDlg:SetTitle( "[ ZESTF008 ] - Rotina de correção do campo B2_QACLASS" ) 
oDlg:SetEscClose( .T. )
oDlg:SetSize( 140, 380 )
oDlg:EnableFormbar( .T. )

//----------------------------------------
// Cria a Janela
//----------------------------------------
oDlg:CreateDialog()

//----------------------------------------
// Cria o Painel
//----------------------------------------
oPanel := oDlg:GetPanelMain()
oDlg:CreateFormBar()

oSay := TSay():New( 015, 005,      { || "Armazém: "           },  oPanel,,,,,,.T.) 
@ 015, 040   MSGET cArmazem    valid(FVALCPO("ARMAZEM", cArmazem) )   SIZE 100,009 F3 "NNR"    OF    oPanel  Pixel    WHEN .T.

oSay := TSay():New( 040, 005,      { || "Endereço: "          },  oPanel,,,,,,.T.) 
@ 040, 040   MSGET cEnderec    Valid(FVALCPO("LOCAL" , cEnderec) )    SIZE 100,009  F3 "SBELO" OF    oPanel  Pixel    WHEN .t.

oSay := TSay():New( 065, 005,      { || "Do Produto: "        },  oPanel,,,,,,.T.) 
@ 065, 040   MSGET cDoProd     Valid(FVALCPO("PRODUTO" , cDoProd ) )  SIZE 100,009  F3 "SB1"   OF    oPanel  Pixel    WHEN .T.

oSay := TSay():New( 065, 210,      { || "Até o Produto: "     },  oPanel,,,,,,.T.) 
@ 065, 260   MSGET cAteProd     Valid(FVALCPO("PRODUTO" , cAteProd))   SIZE 100,009  F3 "SB1"   OF    oPanel  Pixel    WHEN .T.

oDlg:AddButton( "Corrige",         { || zGrvSB2(cArmazem, cEnderec, cDoProd, cAteProd) , oDlg:Deactivate() }, "Confirmar", , .T., .F., .T., )    
oDlg:AddButton( "Sair",            { || oDlg:Deactivate()     }, "Sair", , .T., .F., .T., )

oDlg:Activate()
        
Return()

/*
=====================================================================================
Programa.:              zGrvSB2
Autor....:              CAOA - Sandro Ferreira 
Data.....:              19/04/2022
Descricao / Objetivo:   Funcao para correção B2_QACLASS
Doc. Origem:            EST110 - Rotina de correção B2_QACLASS
Solicitante:            Walisson
Uso......:              CAOA Montadora.
Obs......:
=====================================================================================
*/
Static Function zGrvSB2(cArm, cEnd, cDProd, cAProd)
Local aArea     := GetArea()
Local cUpdate   := ""
Local cQuery    := ""
Local nQtd      := 0

If !Empty(cArm) .and. !Empty(cEnd) .and. !Empty(cDProd) .and. !Empty(cAProd) 
   IF MsgYesNo("Essa rotina atualizará o campo B2_QACLASS, conforme os parametros informados, Deseja continuar ? ")
      //Busca recno na SB2
      cQuery  := " SELECT B2_COD AS CODIGO, R_E_C_N_O_ AS RECNOSB2 "                          + CRLF
      cQuery  += " FROM "+RetSQLname("SB2") +  " SB2"                                         + CRLF
      cQuery  += " WHERE SB2.D_E_L_E_T_ <> '*'     "                                          + CRLF
      cQuery  += " AND   SB2.B2_LOCAL = '"         + cArm    + "'"                            + CRLF
      cQuery  += " AND   SB2.B2_COD BETWEEN '"     + cDProd  + "' AND '" + cAProd    + "' "   + CRLF
      cQuery  := ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYSB2",.T.,.T.)

      //Atualiza campo da tabela SB2->B2_QACLASS
      dbSelectArea("QRYSB2")
      QRYSB2->(dbGoTop())

      IF QRYSB2->(!EOF())
         While QRYSB2->(!EOF())

            cUpdate :=  ""
            cUpdate :=  " UPDATE " + RetSqlName("SB2")    + " SB2"                                   + CRLF
            cUpdate +=  " SET SB2.B2_QACLASS = (SELECT SUM (D14_QTDEST)  "                           + CRLF
            cUpdate +=  " FROM " + RetSqlName("D14")      + " D14"                                   + CRLF
            cUpdate +=  " WHERE D14.D_E_L_E_T_  = ' ' "                                              + CRLF
            cUpdate +=  " AND   D14.D14_PRODUT = '" + QRYSB2->CODIGO   + "'"                         + CRLF
            cUpdate +=  " AND   D14.D14_LOCAL  = '" + cArm  + "'"                                    + CRLF
            cUpdate +=  " AND   D14.D14_ENDER  = '" + cEnd  + "')"                                   + CRLF
            cUpdate +=  " WHERE SB2.R_E_C_N_O_ = "  + AllTrim( Str( QRYSB2->RECNOSB2 )) + " "        + CRLF
         
            If tcSQLExec( cUpdate ) >= 0
               nQtd ++ 
            Else

               cUpdate :=  ""
               cUpdate :=  " UPDATE " + RetSqlName("SB2")    + " SB2"                                   + CRLF
               cUpdate +=  " SET SB2.B2_QACLASS = 0                         "                           + CRLF
               cUpdate +=  " WHERE SB2.R_E_C_N_O_ = "  + AllTrim( Str( QRYSB2->RECNOSB2 )) + " "        + CRLF

               If tcSQLExec( cUpdate ) >= 0
                  nQtd ++ 
               Endif   

            Endif
            
            QRYSB2->(dbSkip())

         End
      ENDIF

      If nQtd > 0
         ApMsgInfo("Campo B2_QACLASS corrigido com Sucesso!!!"                  ,"[ ZESTF008 ] - Sucesso")       
      Else
         ApMsgInfo("Nenhum Registro Processado para os parametros informados!!!","[ ZESTF008 ] - Falha")       
      ENDIF
   ELSE
      ApMsgInfo("Processamento cancelado pelo usuário!!!","[ ZESTF008 ] - Cancelado")   
   ENDIF
else
   ApMsgInfo("Todos os parametros devem estar preenchidos!!!","[ ZESTF008 ] - Cancelado")   
Endif

RestArea(aArea)

Return()


/*
=====================================================================================
Programa.:              FVALCPO
Autor....:              CAOA - Sandro Ferreira 
Data.....:              25/04/2022
Descricao / Objetivo:   Funcao para correção B2_QACLASS
Doc. Origem:            EST110 - Rotina de correção B2_QACLASS
Solicitante:            Walisson
Uso......:              CAOA Montadora.
Obs......:              Função para validar os campos digitados
=====================================================================================
*/
STATIC FUNCTION FVALCPO( cP_ACAO, xVar )
	Local lRet
	lRet    := .T.
	cP_ACAO := IF(cP_ACAO==NIL,"",UPPER(cP_ACAO))
	IF cP_ACAO == "ARMAZEM"
		IF EMPTY(xVar)
			MSGINFO("Nenhum Armazém foi selecionado!","Atenção!")
		Endif
	ELSEIF cP_ACAO == "LOCAL"
		IF EMPTY(xVar)
			MSGINFO("Nenhum Local foi selecionado!","Atenção!")
		Endif
	ELSEIF cP_ACAO == "PRODUTO"
		IF EMPTY(xVar)
			MSGINFO("Nenhum Produto foi selecionado!","Atenção!")
		Endif
	ENDIF
RETURN(lRet)
