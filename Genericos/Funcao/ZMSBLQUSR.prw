#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"


/*
=====================================================================================
Programa.:              ZMSBLQUSR
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              06/05/2020
Descricao / Objetivo:   Bloqueia usuário do Protheus
Doc. Origem:            
Solicitante:            
Uso......:              Configurador
Obs......:
=====================================================================================
*/
User Function ZMSBLQUSR()

Local lUserAut      := .F.
Local cQuery		:= ""
Local cAliasTRB		:= GetNextAlias()
Local cNameUser     := ""
Local nTotReg       := 0

			//  U_ZGENUSER( <ID User> , <"NOME DA FUNÇÃO"> , <.F.=Não Exibe Msg; .T.=Exibe Msg> )
lUserAut := U_ZGENUSER( RetCodUsr() ,"ZMSBLQUSR"	,.T.)

If lUserAut
    If Select( (cAliasTRB) ) > 0
        (cAliasTRB)->(DbCloseArea())
    EndIf

    cQuery := " "

    cQuery += " SELECT USR_ID, USR_CODIGO, USR_MSBLQL FROM SYS_USR          "		+ CRLF
    cQuery += " WHERE D_E_L_E_T_ = ' '                                      "		+ CRLF
    cQuery += " AND USR_ID IN ('000094','000036','000147','000129','000131','000134','000135','000136','000137','000139','000204','000202','000283','000128','000186','000317','000344','000307','000341','000343','000214','000209','000051','000401','000215','000251','000267','000338','000400','000176','000282','000333','000373','000375','000305','000348','000331','000328','000332','000334','000330','000421','000329','000429','000434','000133','000170','000320','000392','000033','000201','000362','000086','000240','000127','000140','000412','000117','000414','000255','000452','000454','000457','000458','000119','000469','000464','000445','000116')                                    "		+ CRLF
    cQuery += " AND USR_MSBLQL = '2'                                        "		+ CRLF
    cQuery += " ORDER BY USR_ID                                             "		+ CRLF

    cQuery := ChangeQuery(cQuery)

    // Executa a consulta.
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

    DbSelectArea((cAliasTRB))
    nTotReg := Contar(cAliasTRB,"!Eof()")

    // Conta quantos registros existem, e seta no tamanho da régua.
    ProcRegua( nTotReg )

    //Ordena por UserId
    PswOrder(1)

    (cAliasTRB)->(dbGoTop())
    While (cAliasTRB)->(!Eof())

        // Incrementa a mensagem na régua.
        IncProc( "Bloqueando Usuário:" + Alltrim((cAliasTRB)->USR_ID) + " | " + Alltrim((cAliasTRB)->USR_CODIGO) )
        
        //Pesquisa no UserId                     
        If PswSeek((cAliasTRB)->USR_ID)
            //Se encontrou grava o Username na variavel xNameUser                  
            cNameUser := PswRet(1)[1][2]
            //Bloqueia usuário no configurador
            PswBlock(cNameUser)
        EndIf
        (cAliasTRB)->(DbSkip())
    End
    (cAliasTRB)->(DbCloseArea())
EndIf

ApMsgAlert( "Bloqueio realizados com Sucesso.","[ ZMSBLQUSR ] - Aviso" )

Return
