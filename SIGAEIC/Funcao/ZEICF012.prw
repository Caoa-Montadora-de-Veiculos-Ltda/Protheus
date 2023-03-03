#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
=====================================================================================
Programa.:              ZEICF012
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              24/06/2019
Descricao / Objetivo:   Ajustar Fabricante e Loja nos processos do EIC.
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZEICF012()

Local aPergs        := {}
Local lUserAut      := .F.
Private cNumPO      := "" 
Private aErros      := {}
Private aRetP       := {}
Private lSc1        := .F.
Private lSw1        := .F.
Private lSw3        := .F.
Private lSw5        := .F.
Private lSw7        := .F.
Private lSw8        := .F.
Private lValid      := .T.

//  U_ZGENUSER( <ID User> , <"NOME DA FUNÇÃO"> , <.F.=Não Exibe Msg; .T.=Exibe Msg> )
lUserAut := U_ZGENUSER( RetCodUsr() ,"ZEICF012"	,.T.)

If lUserAut

    aAdd( aPergs    ,{1,"Informe o P.O "       , Space( TamSX3('W3_PO_NUM')[1] )        ,"@!"   ,'.T.',"SW2" ,'.T.',80,.T.})
    
    If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 

        cNumPO := AllTrim(aRetP[01])
        //cNumPO := "18891-CT1820210308" 

        Processa({|| ZValid() }, "[ ZEICF012 ] - Validando Purchase Order: - "+cNumPO, "Aguarde .... Realizando validações na Purchase Order...." )

        If lValid
            Processa({|| ZUpdSC1() }, "[ ZEICF012 ] - Processando SC1 - "+cNumPO, "Aguarde .... Realizando o Update na Tabela SC1...." )

            Processa({|| ZUpdSW1() }, "[ ZEICF012 ] - Processando SW1 - "+cNumPO, "Aguarde .... Realizando o Update na Tabela SW1...." )

            Processa({|| ZUpdSW3() }, "[ ZEICF012 ] - Processando SW3 - "+cNumPO, "Aguarde .... Realizando o Update na Tabela SW3...." )

            Processa({|| ZUpdSW5() }, "[ ZEICF012 ] - Processando SW5 - "+cNumPO, "Aguarde .... Realizando o Update na Tabela SW5...." )

            Processa({|| ZUpdSW7() }, "[ ZEICF012 ] - Processando SW7 - "+cNumPO, "Aguarde .... Realizando o Update na Tabela SW7...." )

            Processa({|| ZUpdSW8() }, "[ ZEICF012 ] - Processando SW8 - "+cNumPO, "Aguarde .... Realizando o Update na Tabela SW8...." )

            Aviso("[ ZEICF012 ] - Processo Finalizado",    "Purchase Order: " + cNumPO + CRLF + ;
                                                            " " + CRLF + ;
                                                            IIF( lSc1 == .T., "Solic. Compras (SC1)     : Atualizado"   , "Solic. Compras (SC1)     : Não possui inconsistência"   ) + CRLF + ;
                                                            IIF( lSw1 == .T., "Solic. Importação (SW1) : Atualizado"    , "Solic. Importação (SW1) : Não possui inconsistência"    ) + CRLF + ;
                                                            IIF( lSw3 == .T., "Purchase Order (SW3)   : Atualizado"     , "Purchase Order (SW3)   : Não possui inconsistência"     ) + CRLF + ;
                                                            IIF( lSw5 == .T., "Lic. Importação (SW5)    : Atualizado"    , "Lic. Importação (SW5)    : Não possui inconsistência"    ) + CRLF + ;
                                                            IIF( lSw7 == .T., "Itens Embarque (SW7)    : Atualizado"     , "Itens Embarque (SW7)    : Não possui inconsistência"     ) + CRLF + ;
                                                            IIF( lSw8 == .T., "Itens Invoice (SW8)         : Atualizado"  ,  "Itens Invoice (SW8)         : Não possui inconsistência"  ) , {"Finalizar"}, 3)
        
        EndIf

    EndIf

EndIf

Return()

/*
=====================================================================================
Programa.:              ZValid
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              24/06/2021
Descricao / Objetivo:   Validação do Purchase Order
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZValid()

Local cQryTMP       := ""
Local cAliasTMP     := GetNextAlias()

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf

cQryTMP	:= " "
cQryTMP	+= " SELECT * FROM "+RetSqlName("SD1")+" SD1 "
cQryTMP	+= " WHERE SD1.D1_FILIAL = '" + FWxFilial('SD1') + "' "
cQryTMP	+= " AND SD1.D1_PEDIDO IN    (  SELECT SW2.W2_PO_SIGA FROM "+RetSqlName("SW2")+" SW2 "
cQryTMP	+= "                             WHERE SW2.W2_FILIAL = '" + FWxFilial('SW2') + "' "
cQryTMP	+= "                             AND SW2.W2_PO_NUM = '"+cNumPO+"' "
cQryTMP	+= "                             AND SW2.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                         ) "
cQryTMP	+= " AND SD1.D_E_L_E_T_ = ' ' "

cQryTMP := ChangeQuery(cQryTMP)

// Executa a consulta.
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryTMP), cAliasTMP, .T., .T. )

DbSelectArea((cAliasTMP))
(cAliasTMP)->(dbGoTop())

If (cAliasTMP)->(!Eof())
    lValid := .F.
    Aviso("Abortado.","[ZEICF012] Essa P.O. possui nota fiscal vinculada, não pode ser alterado o Fabricante.",{"&Ok"},,)
EndIf

(cAliasTMP)->(dbCloseArea())

If lValid

    cQryTMP       := ""
    cAliasTMP     := GetNextAlias()

    If Select("TMP") > 0
        TMP->(dbCloseArea())
    EndIf

    cQryTMP	:= " "
    cQryTMP	+= " SELECT SW8.R_E_C_N_O_ FROM "+RetSqlName("SW8")+" SW8 "
    cQryTMP	+= " WHERE  SW8.W8_FILIAL = '" + FWxFilial('SW8') + "' "
    cQryTMP	+= " AND SW8.W8_PO_NUM = '"+cNumPO+"' "
    cQryTMP	+= " AND SW8.D_E_L_E_T_ = ' ' "

    cQryTMP := ChangeQuery(cQryTMP)

    // Executa a consulta.
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryTMP), cAliasTMP, .T., .T. )

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())

    If (cAliasTMP)->(!Eof())
                	
	    If !APMsgYesNo("Essa P.O. possui uma invoice embarcada!!! Caso a integração com o Despachante tenha sido enviada, será necessário novo envio. Deseja prosseguir com a Alteração do Fabricante ???")
		    lValid := .F.
            Aviso("Abortado.","[ZEICF012] Atualização cancelada com Sucesso.",{"&Ok"},,)
        Else
            lValid := .T.
	    Endif
        
    EndIf
    
    (cAliasTMP)->(dbCloseArea())

EndIf 

Return()

/*
=====================================================================================
Programa.:              ZUpdSC1
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              24/06/2021
Descricao / Objetivo:   Faz o Update na Tabela SC1
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZUpdSC1()

Local cQryTMP       := ""
Local cAliasTMP     := GetNextAlias()
Local cUpdate	    := ""
Local nTotReg		:= 0
Local nUpdate       := 0

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf

cQryTMP	:= " "
cQryTMP	+= " SELECT * FROM ( "                                                                                                                                                                                                    
cQryTMP	+= "                 SELECT SC1.R_E_C_N_O_, SC1.C1_NUM, SC1.C1_ITEM, SC1.C1_NUM_SI, SC1.C1_FORNECE, SC1.C1_LOJA, SC1.C1_PRODUTO, SC1.C1_FABR, C1_FABRLOJ, SA5.A5_FABR, SA5.A5_FALOJA FROM "+RetSqlName("SC1")+" SC1 "
cQryTMP	+= "                     LEFT JOIN "+RetSqlName("SA5")+" SA5 "                                                                                                                                            
cQryTMP	+= "                     ON SA5.A5_FILIAL = '" + FWxFilial('SA5') + "' "
cQryTMP	+= "                     AND SC1.C1_FORNECE = SA5.A5_FORNECE "
cQryTMP	+= "                     AND SC1.C1_LOJA = SA5.A5_LOJA "
cQryTMP	+= "                     AND SC1.C1_PRODUTO = SA5.A5_PRODUTO "
cQryTMP	+= "                     AND SA5.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                 WHERE SC1.C1_FILIAL = '" + FWxFilial('SC1') + "' "
cQryTMP	+= "                 AND SC1.C1_NUM_SI IN    (  SELECT SW3.W3_SI_NUM FROM "+RetSqlName("SW3")+" SW3 "
cQryTMP	+= "                                             WHERE SW3.W3_FILIAL = '" + FWxFilial('SW3') + "' "
cQryTMP	+= "                                             AND SW3.W3_PO_NUM = '"+cNumPO+"' " 
cQryTMP	+= "                                             AND SW3.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                                             GROUP BY SW3.W3_SI_NUM "
cQryTMP	+= "                                         ) "
cQryTMP	+= "                 AND SC1.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                 ORDER BY SC1.C1_NUM_SI, SC1.C1_ITEM ) TMP "
cQryTMP	+= " WHERE TMP.C1_FABR || TMP.C1_FABRLOJ <> TMP.A5_FABR || TMP.A5_FALOJA "
cQryTMP	+= " ORDER BY TMP.R_E_C_N_O_ "

cQryTMP := ChangeQuery(cQryTMP)

// Executa a consulta.
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryTMP), cAliasTMP, .T., .T. )

DbSelectArea((cAliasTMP))
nTotReg := Contar(cAliasTMP,"!Eof()")
nUpdate := 1

(cAliasTMP)->(dbGoTop())

// Conta quantos registros existem, e seta no tamanho da régua.
ProcRegua( nTotReg )

While (cAliasTMP)->(!Eof())

      // Incrementa a mensagem na régua.
	IncProc("Processando Update SC1: "+ StrZero(nUpdate,10)  + " De:" + StrZero(nTotReg,10)  )

    If !Empty((cAliasTMP)->A5_FABR)
        
        //Iniciando controle de transações
        Begin Transaction

            cUpdate := " "
            cUpdate += " UPDATE "+RetSqlName("SC1")+" SET C1_FABR = '"+(cAliasTMP)->A5_FABR+"' , C1_FABRLOJ = '"+(cAliasTMP)->A5_FALOJA+"' "
            cUpdate += " WHERE D_E_L_E_T_ = ' ' "
            cUpdate += " AND R_E_C_N_O_ = "+AllTrim( Str( (cAliasTMP)->R_E_C_N_O_ ))+" "

            If TcSqlExec(cUpdate) < 0
                Help( ,, "Caoa",, TcSqlError() , 1, 0)
                Disarmtransaction()
            EndIf

            lSc1 := .T.

        //Finalizando controle de transações
        End Transaction
    
    Else 

        // Adiciona os dados no array de erro para impressão
        AAdd(aErros,{cNumPO, (cAliasTMP)->R_E_C_N_O_, (cAliasTMP)->C1_NUM, (cAliasTMP)->C1_ITEM, (cAliasTMP)->C1_PRODUTO, "CADASTRO PRODUTO X FORNECEDOR NÃO ENCONTRADO"}) 

    EndIf

    nUpdate++
	(cAliasTMP)->(DbSkip())

EndDo
(cAliasTMP)->(dbCloseArea())

Return

/*
=====================================================================================
Programa.:              ZUpdSW1
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              24/06/2021
Descricao / Objetivo:   Faz o Update na Tabela SW1
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZUpdSW1()

Local cQryTMP       := ""
Local cAliasTMP     := GetNextAlias()
Local cUpdate	    := ""
Local nTotReg		:= 0
Local nUpdate       := 0

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf

cQryTMP	:= " "
cQryTMP	+= " SELECT * FROM ( "
cQryTMP	+= "                 SELECT SW1.R_E_C_N_O_, SW1.W1_POSICAO, SW1.W1_SI_NUM, SW1.W1_FORN, SW1.W1_FORLOJ, SW1.W1_COD_I, SW1.W1_FABR, SW1.W1_FABLOJ, SA5.A5_FABR, SA5.A5_FALOJA FROM "+RetSqlName("SW1")+" SW1 "
cQryTMP	+= "                     LEFT JOIN "+RetSqlName("SA5")+" SA5 "
cQryTMP	+= "                     ON SA5.A5_FILIAL = '" + FWxFilial('SA5') + "' "
cQryTMP	+= "                     AND SW1.W1_FORN = SA5.A5_FORNECE "
cQryTMP	+= "                     AND SW1.W1_FORLOJ = SA5.A5_LOJA "
cQryTMP	+= "                     AND SW1.W1_COD_I = SA5.A5_PRODUTO "
cQryTMP	+= "                     AND SA5.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                 WHERE SW1.W1_FILIAL = '" + FWxFilial('SW1') + "' "
cQryTMP	+= "                 AND SW1.W1_PO_NUM = '"+cNumPO+"' "
cQryTMP	+= "                 AND SW1.W1_SI_NUM IN    (  SELECT SW3.W3_SI_NUM FROM "+RetSqlName("SW3")+" SW3 "
cQryTMP	+= "                                             WHERE SW3.W3_FILIAL = '" + FWxFilial('SW3') + "' "
cQryTMP	+= "                                             AND SW3.W3_PO_NUM = '"+cNumPO+"' ""
cQryTMP	+= "                                             AND SW3.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                                             GROUP BY SW3.W3_SI_NUM "
cQryTMP	+= "                                         ) "
cQryTMP	+= "                 AND SW1.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                 ORDER BY SW1.W1_SI_NUM, SW1.W1_POSICAO ) TMP "
cQryTMP	+= " WHERE TMP.W1_FABR+TMP.W1_FABLOJ <> TMP.A5_FABR+TMP.A5_FALOJA "
cQryTMP	+= " ORDER BY TMP.R_E_C_N_O_ "

cQryTMP := ChangeQuery(cQryTMP)

// Executa a consulta.
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryTMP), cAliasTMP, .T., .T. )

DbSelectArea((cAliasTMP))
nTotReg := Contar(cAliasTMP,"!Eof()")
nUpdate := 1

(cAliasTMP)->(dbGoTop())

// Conta quantos registros existem, e seta no tamanho da régua.
ProcRegua( nTotReg )

While (cAliasTMP)->(!Eof())

      // Incrementa a mensagem na régua.
	IncProc("Processando Update SW1: "+ StrZero(nUpdate,10)  + " De:" + StrZero(nTotReg,10)  )

    If !Empty((cAliasTMP)->A5_FABR)

        //Iniciando controle de transações
        Begin Transaction

            cUpdate := " "
            cUpdate += " UPDATE "+RetSqlName("SW1")+" SET W1_FABR = '"+(cAliasTMP)->A5_FABR+"' , W1_FABLOJ = '"+(cAliasTMP)->A5_FALOJA+"' "
            cUpdate += " WHERE D_E_L_E_T_ = ' ' "
            cUpdate += " AND R_E_C_N_O_ =  "+AllTrim( Str( (cAliasTMP)->R_E_C_N_O_))+" "

            If TcSqlExec(cUpdate) < 0
                Help( ,, "Caoa",, TcSqlError() , 1, 0)
                Disarmtransaction()
            EndIf

            lSw1 := .T.

        //Finalizando controle de transações
        End Transaction

    Else

        // Adiciona os dados no array de erro para impressão
        AAdd(aErros,{cNumPO, (cAliasTMP)->R_E_C_N_O_, (cAliasTMP)->W1_SI_NUM, (cAliasTMP)->W1_POSICAO, (cAliasTMP)->W1_COD_I, "CADASTRO PRODUTO X FORNECEDOR NÃO ENCONTRADO"}) 

    EndIf

    nUpdate++
	(cAliasTMP)->(DbSkip())

EndDo
(cAliasTMP)->(dbCloseArea())

Return

/*
=====================================================================================
Programa.:              ZUpdSW3
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              24/06/2021
Descricao / Objetivo:   Faz o Update na Tabela SW3
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZUpdSW3()

Local cQryTMP       := ""
Local cAliasTMP     := GetNextAlias()
Local cUpdate	    := ""
Local nTotReg		:= 0
Local nUpdate       := 0

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf

cQryTMP	:= " "
cQryTMP	+= " SELECT * FROM ( "
cQryTMP	+= "                 SELECT SW3.R_E_C_N_O_, SW3.W3_POSICAO, SW3.W3_PO_NUM, SW3.W3_FORN, SW3.W3_FORLOJ, SW3.W3_COD_I, SW3.W3_PART_N, SW3.W3_FABR, SW3.W3_FABLOJ, SA5.A5_FABR, SA5.A5_FALOJA FROM "+RetSqlName("SW3")+" SW3 "
cQryTMP	+= "                     LEFT JOIN "+RetSqlName("SA5")+" SA5 "
cQryTMP	+= "                     ON SA5.A5_FILIAL = '" + FWxFilial('SA5') + "' "
cQryTMP	+= "                     AND SW3.W3_FORN = SA5.A5_FORNECE "
cQryTMP	+= "                     AND SW3.W3_FORLOJ = SA5.A5_LOJA "
cQryTMP	+= "                     AND SW3.W3_COD_I = SA5.A5_PRODUTO "
cQryTMP	+= "                     AND SA5.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                 WHERE SW3.W3_FILIAL =  '" + FWxFilial('SW3') + "' "
cQryTMP	+= "                 AND SW3.W3_PO_NUM = '"+cNumPO+"' "
cQryTMP	+= "                 AND SW3.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                 ORDER BY SW3.W3_PO_NUM, SW3.W3_POSICAO ) TMP "
cQryTMP	+= " WHERE TMP.W3_FABR+TMP.W3_FABLOJ <> TMP.A5_FABR+TMP.A5_FALOJA "
cQryTMP	+= " ORDER BY TMP.R_E_C_N_O_ "

cQryTMP := ChangeQuery(cQryTMP)

// Executa a consulta.
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryTMP), cAliasTMP, .T., .T. )

DbSelectArea((cAliasTMP))
nTotReg := Contar(cAliasTMP,"!Eof()")
nUpdate := 1

(cAliasTMP)->(dbGoTop())

// Conta quantos registros existem, e seta no tamanho da régua.
ProcRegua( nTotReg )

While (cAliasTMP)->(!Eof())

      // Incrementa a mensagem na régua.
	IncProc("Processando Update SW3: "+ StrZero(nUpdate,10)  + " De:" + StrZero(nTotReg,10)  )

    If !Empty((cAliasTMP)->A5_FABR)

        //Iniciando controle de transações
        Begin Transaction

            cUpdate := " "
            cUpdate += " UPDATE "+RetSqlName("SW3")+" SET W3_FABR = '"+(cAliasTMP)->A5_FABR+"' , W3_FABLOJ = '"+(cAliasTMP)->A5_FALOJA+"' "
            cUpdate += " WHERE D_E_L_E_T_ = ' ' "
            cUpdate += " AND R_E_C_N_O_ =  "+AllTrim( Str( (cAliasTMP)->R_E_C_N_O_))+" "

            If TcSqlExec(cUpdate) < 0
                Help( ,, "Caoa",, TcSqlError() , 1, 0)
                Disarmtransaction()
            EndIf

            lSw3 := .T.

        //Finalizando controle de transações
        End Transaction
    
    Else

        // Adiciona os dados no array de erro para impressão
        AAdd(aErros,{cNumPO, (cAliasTMP)->R_E_C_N_O_, (cAliasTMP)->W3_PO_NUM, (cAliasTMP)->W3_POSICAO, (cAliasTMP)->W3_COD_I, "CADASTRO PRODUTO X FORNECEDOR NÃO ENCONTRADO"}) 

    EndIf

    nUpdate++
	(cAliasTMP)->(DbSkip())

EndDo
(cAliasTMP)->(dbCloseArea())

Return

/*
=====================================================================================
Programa.:              ZUpdSW5
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              24/06/2021
Descricao / Objetivo:   Faz o Update na Tabela SW5
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZUpdSW5()

Local cQryTMP       := ""
Local cAliasTMP     := GetNextAlias()
Local cUpdate	    := ""
Local nTotReg		:= 0
Local nUpdate       := 0
Local aErros        := {}

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf

cQryTMP	:= " "
cQryTMP	+= " SELECT * FROM ( "
cQryTMP	+= "                 SELECT SW5.R_E_C_N_O_, SW5.W5_POSICAO, SW5.W5_PO_NUM, SW5.W5_FORN, SW5.W5_FORLOJ, SW5.W5_COD_I, SW5.W5_FABR, SW5.W5_FABLOJ, SA5.A5_FABR, SA5.A5_FALOJA FROM "+RetSqlName("SW5")+" SW5 "
cQryTMP	+= "                     LEFT JOIN "+RetSqlName("SA5")+" SA5 "
cQryTMP	+= "                     ON SA5.A5_FILIAL = '" + FWxFilial('SA5') + "' "
cQryTMP	+= "                     AND SW5.W5_FORN = SA5.A5_FORNECE "
cQryTMP	+= "                     AND SW5.W5_FORLOJ = SA5.A5_LOJA "
cQryTMP	+= "                     AND SW5.W5_COD_I = SA5.A5_PRODUTO "
cQryTMP	+= "                     AND SA5.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                 WHERE SW5.W5_FILIAL = '" + FWxFilial('SW5') + "'  "
cQryTMP	+= "                 AND SW5.W5_PO_NUM = '"+cNumPO+"' "
cQryTMP	+= "                 AND SW5.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                 ORDER BY SW5.W5_PO_NUM, SW5.W5_POSICAO ) TMP "
cQryTMP	+= " WHERE TMP.W5_FABR+TMP.W5_FABLOJ <> TMP.A5_FABR+TMP.A5_FALOJA "
cQryTMP	+= " ORDER BY TMP.R_E_C_N_O_ "

cQryTMP := ChangeQuery(cQryTMP)

// Executa a consulta.
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryTMP), cAliasTMP, .T., .T. )

DbSelectArea((cAliasTMP))
nTotReg := Contar(cAliasTMP,"!Eof()")
nUpdate := 1

(cAliasTMP)->(dbGoTop())

// Conta quantos registros existem, e seta no tamanho da régua.
ProcRegua( nTotReg )

While (cAliasTMP)->(!Eof())

      // Incrementa a mensagem na régua.
	IncProc("Processando Update SW5: "+ StrZero(nUpdate,10)  + " De:" + StrZero(nTotReg,10)  )
    
    If !Empty((cAliasTMP)->A5_FABR)

        //Iniciando controle de transações
        Begin Transaction

            cUpdate := " "
            cUpdate += " UPDATE "+RetSqlName("SW5")+" SET W5_FABR = '"+(cAliasTMP)->A5_FABR+"' , W5_FABLOJ = '"+(cAliasTMP)->A5_FALOJA+"' "
            cUpdate += " WHERE D_E_L_E_T_ = ' ' "
            cUpdate += " AND R_E_C_N_O_ =  "+AllTrim( Str( (cAliasTMP)->R_E_C_N_O_))+" "

            If TcSqlExec(cUpdate) < 0
                Help( ,, "Caoa",, TcSqlError() , 1, 0)
                Disarmtransaction()
            EndIf

            lSw5 := .T.

        //Finalizando controle de transações
        End Transaction

    Else

        // Adiciona os dados no array de erro para impressão
        AAdd(aErros,{cNumPO, (cAliasTMP)->R_E_C_N_O_, (cAliasTMP)->W5_PO_NUM, (cAliasTMP)->W5_POSICAO, (cAliasTMP)->W5_COD_I, "CADASTRO PRODUTO X FORNECEDOR NÃO ENCONTRADO"}) 

    EndIf

    nUpdate++
	(cAliasTMP)->(DbSkip())

EndDo
(cAliasTMP)->(dbCloseArea())

Return

/*
=====================================================================================
Programa.:              ZUpdSW7
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              24/06/2021
Descricao / Objetivo:   Faz o Update na Tabela SW7
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZUpdSW7()

Local cQryTMP       := ""
Local cAliasTMP     := GetNextAlias()
Local cUpdate	    := ""
Local nTotReg		:= 0
Local nUpdate       := 0
Local aErros        := {}

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf

cQryTMP	:= " "
cQryTMP	+= " SELECT * FROM ( "
cQryTMP	+= "                 SELECT SW7.R_E_C_N_O_, SW7.W7_POSICAO, SW7.W7_PO_NUM, SW7.W7_FORN, SW7.W7_FORLOJ, SW7.W7_COD_I, SW7.W7_FABR, SW7.W7_FABLOJ, SA5.A5_FABR, SA5.A5_FALOJA FROM "+RetSqlName("SW7")+" SW7 "
cQryTMP	+= "                     LEFT JOIN "+RetSqlName("SA5")+" SA5 "
cQryTMP	+= "                     ON SA5.A5_FILIAL = '" + FWxFilial('SA5') + "' "
cQryTMP	+= "                     AND SW7.W7_FORN = SA5.A5_FORNECE "
cQryTMP	+= "                     AND SW7.W7_FORLOJ = SA5.A5_LOJA "
cQryTMP	+= "                     AND SW7.W7_COD_I = SA5.A5_PRODUTO "
cQryTMP	+= "                     AND SA5.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                 WHERE SW7.W7_FILIAL = '" + FWxFilial('SW7') + "' "
cQryTMP	+= "                 AND SW7.W7_PO_NUM = '"+cNumPO+"' "
cQryTMP	+= "                 AND SW7.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                 ORDER BY SW7.W7_PO_NUM, SW7.W7_POSICAO ) TMP "
cQryTMP	+= " WHERE TMP.W7_FABR+TMP.W7_FABLOJ <> TMP.A5_FABR+TMP.A5_FALOJA "
cQryTMP	+= " ORDER BY TMP.R_E_C_N_O_ "

cQryTMP := ChangeQuery(cQryTMP)

// Executa a consulta.
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryTMP), cAliasTMP, .T., .T. )

DbSelectArea((cAliasTMP))
nTotReg := Contar(cAliasTMP,"!Eof()")
nUpdate := 1

(cAliasTMP)->(dbGoTop())

// Conta quantos registros existem, e seta no tamanho da régua.
ProcRegua( nTotReg )

While (cAliasTMP)->(!Eof())

      // Incrementa a mensagem na régua.
	IncProc("Processando Update SW7: "+ StrZero(nUpdate,10)  + " De:" + StrZero(nTotReg,10)  )

    If !Empty((cAliasTMP)->A5_FABR)

        //Iniciando controle de transações
        Begin Transaction

            cUpdate := " "
            cUpdate += " UPDATE "+RetSqlName("SW7")+" SET W7_FABR = '"+(cAliasTMP)->A5_FABR+"' , W7_FABLOJ = '"+(cAliasTMP)->A5_FALOJA+"' "
            cUpdate += " WHERE D_E_L_E_T_ = ' ' "
            cUpdate += " AND R_E_C_N_O_ =  "+AllTrim( Str( (cAliasTMP)->R_E_C_N_O_))+" "

            If TcSqlExec(cUpdate) < 0
                Help( ,, "Caoa",, TcSqlError() , 1, 0)
                Disarmtransaction()
            EndIf

            lSw7 := .T.

        //Finalizando controle de transações
        End Transaction

    Else

        // Adiciona os dados no array de erro para impressão
        AAdd(aErros,{cNumPO, (cAliasTMP)->R_E_C_N_O_, (cAliasTMP)->W7_PO_NUM, (cAliasTMP)->W7_POSICAO, (cAliasTMP)->W7_COD_I, "CADASTRO PRODUTO X FORNECEDOR NÃO ENCONTRADO"}) 

    EndIf

    nUpdate++
	(cAliasTMP)->(DbSkip())

EndDo
(cAliasTMP)->(dbCloseArea())

Return

/*
=====================================================================================
Programa.:              ZUpdSW8
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              24/06/2021
Descricao / Objetivo:   Faz o Update na Tabela SW8
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZUpdSW8()

Local cQryTMP       := ""
Local cAliasTMP     := GetNextAlias()
Local cUpdate	    := ""
Local nTotReg		:= 0
Local nUpdate       := 0
Local aErros        := {}

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf

cQryTMP	:= " "
cQryTMP	+= " SELECT * FROM ( "
cQryTMP	+= "                 SELECT SW8.R_E_C_N_O_, SW8.W8_POSICAO, SW8.W8_PO_NUM, SW8.W8_FORN, SW8.W8_FORLOJ, SW8.W8_COD_I, SW8.W8_FABR, SW8.W8_FABLOJ, SA5.A5_FABR, SA5.A5_FALOJA FROM "+RetSqlName("SW8")+" SW8 "
cQryTMP	+= "                     LEFT JOIN "+RetSqlName("SA5")+" SA5 "
cQryTMP	+= "                     ON SA5.A5_FILIAL = '" + FWxFilial('SA5') + "' "
cQryTMP	+= "                     AND SW8.W8_FORN = SA5.A5_FORNECE "
cQryTMP	+= "                     AND SW8.W8_FORLOJ = SA5.A5_LOJA "
cQryTMP	+= "                     AND SW8.W8_COD_I = SA5.A5_PRODUTO "
cQryTMP	+= "                     AND SA5.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                 WHERE SW8.W8_FILIAL = '" + FWxFilial('SW8') + "'  "
cQryTMP	+= "                 AND SW8.W8_PO_NUM = '"+cNumPO+"' "
cQryTMP	+= "                 AND SW8.D_E_L_E_T_ = ' ' "
cQryTMP	+= "                 ORDER BY SW8.W8_PO_NUM, SW8.W8_POSICAO ) TMP "
cQryTMP	+= " WHERE TMP.W8_FABR+TMP.W8_FABLOJ <> TMP.A5_FABR+TMP.A5_FALOJA "
cQryTMP	+= " ORDER BY TMP.R_E_C_N_O_

cQryTMP := ChangeQuery(cQryTMP)

// Executa a consulta.
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryTMP), cAliasTMP, .T., .T. )

DbSelectArea((cAliasTMP))
nTotReg := Contar(cAliasTMP,"!Eof()")
nUpdate := 1

(cAliasTMP)->(dbGoTop())

// Conta quantos registros existem, e seta no tamanho da régua.
ProcRegua( nTotReg )

While (cAliasTMP)->(!Eof())

      // Incrementa a mensagem na régua.
	IncProc("Processando Update SW8: "+ StrZero(nUpdate,10)  + " De:" + StrZero(nTotReg,10)  )

    If !Empty((cAliasTMP)->A5_FABR)

        //Iniciando controle de transações
        Begin Transaction

            cUpdate := " "
            cUpdate += " UPDATE "+RetSqlName("SW8")+" SET W8_FABR = '"+(cAliasTMP)->A5_FABR+"' , W8_FABLOJ = '"+(cAliasTMP)->A5_FALOJA+"' "
            cUpdate += " WHERE D_E_L_E_T_ = ' ' "
            cUpdate += " AND R_E_C_N_O_ =  "+AllTrim( Str( (cAliasTMP)->R_E_C_N_O_))+" "

            If TcSqlExec(cUpdate) < 0
                Help( ,, "Caoa",, TcSqlError() , 1, 0)
                Disarmtransaction()
            EndIf

            lSw8 := .T.

        //Finalizando controle de transações
        End Transaction

    Else

        // Adiciona os dados no array de erro para impressão
        AAdd(aErros,{cNumPO, (cAliasTMP)->R_E_C_N_O_, (cAliasTMP)->W8_PO_NUM, (cAliasTMP)->W8_POSICAO, (cAliasTMP)->W8_COD_I, "CADASTRO PRODUTO X FORNECEDOR NÃO ENCONTRADO"}) 

    EndIf

    nUpdate++
	(cAliasTMP)->(DbSkip())

EndDo
(cAliasTMP)->(dbCloseArea())

Return
