//Bibliotecas
#Include "TOTVS.ch"
 
/*
=====================================================================================
Programa.:              ZFATF012
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              29/08/2022
Descricao / Objetivo:   Realiza a importação da Planilha de Crédito Floor Plan
Doc. Origem:            
Solicitante:            
Uso......:              [Barueri] - Financeiro
@project	GRUPO CAOA GAP FIN108 - Revitalização Credito [ Montadora ]
Obs......: 
@history 	04/04/2023	, DAC, Revitalização Limite de Crédito, alterado chamada de funcionalidade ZFATF017 para ZFATF014  
=====================================================================================
*/
User Function ZFATF012()

	Local _aArea := GetArea()
	//DimensÃµes da janela
	Local _nAltura := 180
	Local _nLargura := 650
	//Objetos da tela
	Local _oGrpAco
	Local _oBtnSair
	Local _oBtnImp
	Private _oDlgImp
	
	//Criando a janela
	DEFINE MSDIALOG _oDlgImp TITLE "[ ZFATF012 ] - Importação Crédito Floor Plan" FROM 000, 000  TO _nAltura, _nLargura COLORS 0, 16777215 PIXEL
				
		//Grupo AçÃµes
		@ 010, 003 	GROUP _oGrpAco TO (_nAltura/2)-3, (_nLargura/2) 	PROMPT "[ CAOA ] - Importação" 		OF _oDlgImp COLOR 0, 16777215 PIXEL
		
        //BotÃµes
        @ 043, 050  BUTTON _oBtnImp  PROMPT "Importar"   SIZE 60, 014 OF _oDlgImp ACTION ( zProcImp()       ) PIXEL
        @ 043, 225  BUTTON _oBtnSair PROMPT "Sair"       SIZE 60, 014 OF _oDlgImp ACTION ( _oDlgImp:End()   ) PIXEL

    ACTIVATE MSDIALOG _oDlgImp CENTERED
	
	
	RestArea(_aArea)
Return()
/*
=====================================================================================
Programa.:              zImport
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              29/08/2022
Descricao / Objetivo:   Realiza a importação da Planilha de Crédito Floor Plan
Doc. Origem:            
Solicitante:            
Uso......:              [Barueri] - Financeiro
Obs......:
=====================================================================================
*/
Static Function zProcImp() //u_ZFATF012()

    Local cTitulo   := "Selecione o arquivo para Carga "
    Local cExtens   := "Arquivo CSV | *.CSV"
    Local cMainPath := "C:\"
    Local cFileOpen := ""
    Local _lRet      := .T.

    cFileOpen := cGetFile(cExtens,cTitulo,0,cMainPath,.T.,,.F.)
    
    //Se tiver o arquivo selecionado e ele existir
    If !Empty(cFileOpen) .And. File(cFileOpen)
        Processa({|| ( _lRet := zImporta(cFileOpen) ) }, "Importando Crédito Floor Plan...")
        If _lRet
            FWMsgRun(, {|| U_ZFATF014() },'Atualização Limite de Crédito','Aguarde atualizando Saldos do Limite de Credito dos Clientes')
        EndIf
    EndIf
    
Return

/*
=====================================================================================
Programa.:              zImporta
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              29/08/2022
Descricao / Objetivo:   Faz a importação do arquivo.
Doc. Origem:            
Solicitante:            
Uso......:              [Barueri] - Financeiro
Obs......:
=====================================================================================
*/ 
Static Function zImporta(_cArqSel)

    Local _nTotLinhas   := 0
    Local _cLinAtu      := ""
    Local _nLinhaAtu    := 0
    Local _aLinha       := {}
    //Local _cCnpjMatriz  := ""
    Local _cSeparador	:= ";"
    Local _cMsgLog      := ""
    Local _cTitLog      := "[ZFATF012] - Log Importação Crédito Floor Plan"
    Local _dDataVenc    := CToD("//")
    Local _lRet         := .F.
    Local _nVlrLim      := 0
    Local _oArquivo
    Local _aLinhas
    Local _nRegSA1
    
    
    Private _cLog       := ""

    //Abre as tabelas que serão usadas
    DbSelectArea('SA1')

   //Definindo o arquivo a ser lido
    _oArquivo := FWFileReader():New(_cArqSel)
     
    //Se o arquivo pode ser aberto
    If (_oArquivo:Open())
 
        //Se não for fim do arquivo
        If ! (_oArquivo:EoF())
 
            //Definindo o tamanho da régua
            _aLinhas := _oArquivo:GetAllLines()
            _nTotLinhas := Len(_aLinhas)
            ProcRegua(_nTotLinhas)
             
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            _oArquivo:Close()
            _oArquivo := FWFileReader():New(_cArqSel)
            _oArquivo:Open()

            //Zera o crédito Floor Plan antes de iniciar a importação.
            If zUpdateFp()

                //Iniciando controle de transação
                Begin Transaction
 
                    //Enquanto tiver linhas
                    While (_oArquivo:HasLine())
 
                        //Incrementa na tela a mensagem
                        _nLinhaAtu++
                        IncProc("Analisando linha " + cValToChar(_nLinhaAtu) + " de " + cValToChar(_nTotLinhas) + "...")
                     
                        //Pegando a linha atual e transformando em array
                        _cLinAtu := _oArquivo:GetLine()
                        //_aLinha  := StrTokArr(_cLinAtu, ";")
                        _aLinha  := Separa(_cLinAtu,_cSeparador)

                        //_aLinha[01] - CODUSUARIOINT
                        //_aLinha[02] - CNPJMATRIZ
                        //_aLinha[03] - CNPJCPFFORNECEDOR
                        //_aLinha[04] - CODPRODUTO
                        //_aLinha[05] - DESPRODUTO
                        //_aLinha[06] - IDLIMITE
                        //_aLinha[07] - NROLIMITE
                        //_aLinha[08] - CNPJFILIAL
                        //_aLinha[09] - NOMEFILIAL
                        //_aLinha[10] - TIPO
                        //_aLinha[11] - NOMEMATRIZ
                        //_aLinha[12] - NOMEFORNECEDOR
                        //_aLinha[13] - CODMARCA
                        //_aLinha[14] - NOME_MARCA
                        //_aLinha[15] - CODCATEGORIA
                        //_aLinha[16] - DESCATEGORIA
                        //_aLinha[17] - CODSEGMENTO
                        //_aLinha[18] - DESSEGMENTO
                        //_aLinha[19] - VLRLIMITEMAT
                        //_aLinha[20] - VLRLIMITEAPROVMAT
                        //_aLinha[21] - VLROVERLIMIT
                        //_aLinha[22] - VLRPIPELINE
                        //_aLinha[23] - VLRUTILIZADOMAT
                        //_aLinha[24] - VLRDISPONIVELMAT
                        //_aLinha[25] - DATINICIO
                        //_aLinha[26] - DATFIM
                        //_aLinha[27] - VLRLIMITE
                        //_aLinha[28] - VLRUTILIZADO
                        //_aLinha[29] - VLRDISPONIVEL
                        //_aLinha[30] - TIPOORIGEM
                        //_aLinha[31] - RATINGWHS
                        //_aLinha[32] - RATINGTAXA
                        //_aLinha[33] - TAXAORIGEM
                        //_aLinha[34] - INDBLOQUEIO
                        //_aLinha[36] - MOTIVOSBLOQUEIO
    
                        //Se houver posições no array
                        If Len(_aLinha) > 0

                            If !(AllTrim(_aLinha[01])) $ "CODUSUARIOINT"

                                //Busca o Cnpj da cliente Matriz do Floor Plan.
                                //Alterado FIN100
                                _nRegSA1    := zBuscaCli(Substring(StrZero(Val(AllTrim(_aLinha[08]) ),14),01,08))

                                If  _nRegSA1 == Nil
                                    _cMsgLog += "Linha:"+PADR(" ", 3 - Len(AllTrim(cValToChar(_nLinhaAtu))))+AllTrim(cValToChar(_nLinhaAtu))+" |Matriz CNPJ não encontrado no Cadastro de Cliente |Excel: " + AllTrim(_aLinha[08]) + CRLF
                                ElseIf  _nRegSA1 > 0
                                    SA1->(DbGoto(_nRegSA1)) 
                                    _dDataVenc  := CToD(_aLinha[26]) //DATFIM
                                    _nVlrLim    := Val(StrTran(StrTran(_aLinha[24],".",""),",",".")) //VLRDISPONIVELMAT
                                    RecLock("SA1",.F.)                      
                                    SA1->A1_XLC	    := Iif(_nVlrLim > 0, _nVlrLim, 0 )
                                    SA1->A1_XDTLC	:= _dDataVenc
                                    SA1->A1_XBLQLC	:= "0"
                                    SA1->(MsUnlock())
                                    _lRet := .T.
                                Else                                    
                                    _cMsgLog += "Linha:"+PADR(" ", 3 - Len(AllTrim(cValToChar(_nLinhaAtu))))+AllTrim(cValToChar(_nLinhaAtu))+" |Esse cliente não esta habilitado como FloorPlan (1) CNPJ: " + AllTrim(_aLinha[08]) + CRLF
                                Endif  
                                /* 
                                _cCnpjMatriz := zBuscaCli(Substring(StrZero(Val(AllTrim(_aLinha[08]) ),14),01,08))

                                SA1->(DbSetOrder(3)) //A1_FILIAL+A1_CGC                                                                                                                                                
                                If SA1->(DbSeek(FwXFilial("SA1") + _cCnpjMatriz ) )

                                    If SA1->A1_XTPCRED == "1"

                                        //_dDataVenc  := CToD(Substring(_aLinha[26],7,2)+"/"+Substring(_aLinha[26],5,2)+"/"+Substring(_aLinha[26],1,4)) //DATFIM
                                        _dDataVenc  := CToD(_aLinha[26]) //DATFIM
                                        _nVlrLim    := Val(StrTran(StrTran(_aLinha[24],".",""),",",".")) //VLRDISPONIVELMAT

                                        RecLock("SA1",.F.)                      
                                            SA1->A1_XLC	    := Iif(_nVlrLim > 0, _nVlrLim, 0 )
                                            SA1->A1_XDTLC	:= _dDataVenc
                                            SA1->A1_XBLQLC	:= "0"
                                        SA1->(MsUnlock())

                                        _lRet := .T.
                                    Else
                                        _cMsgLog += "Linha:"+PADR(" ", 3 - Len(AllTrim(cValToChar(_nLinhaAtu))))+AllTrim(cValToChar(_nLinhaAtu))+" |Esse cliente não esta habilitado como FloorPlan (1) |Cadastro Cliente Tipo: " + AllTrim(SA1->A1_XTPCRED) + CRLF
                                    EndIf   
                                Else
                                    _cMsgLog += "Linha:"+PADR(" ", 3 - Len(AllTrim(cValToChar(_nLinhaAtu))))+AllTrim(cValToChar(_nLinhaAtu))+" |Matriz CNPJ não encontrado no Cadastro de Cliente |Excel: " + AllTrim(_aLinha[08]) + CRLF
                                EndIf 
                                */
                            EndIf                                            
                        Else
                            _cMsgLog += "O Arquivo não possui informações para atualização." + CRLF
                        EndIf
                            
                    EndDo
 
                End Transaction
            Else
                MsgStop("Não foi possivel apagar o Limite de Crédito Atual, reprocesse o arquivo!", "Atenção")
            EndIf         
             
        Else
            MsgStop("Arquivo não tem conteúdo!", "Atenção")
        EndIf
 
        //Fecha o arquivo
        _oArquivo:Close()
    Else
        MsgStop("Arquivo não pode ser aberto!", "Atenção")
    EndIf
    
    If !Empty(_cMsgLog)
        u_zGenMsg(_cMsgLog, _cTitLog)
    EndIf

Return(_lRet)
 
/*
=====================================================================================
Programa.:              zUpdateFp
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              29/08/2022
Descricao / Objetivo:   Faz a importação do arquivo.
Doc. Origem:            
Solicitante:            
Uso......:              [Barueri] - Financeiro
Obs......:
=====================================================================================
*/ 
Static Function zUpdateFp()

Local _lRet     := .T.
Local _cUpdSA1  := " "

    //Iniciando controle de transações
    Begin Transaction

        _cUpdSA1 := " "
        _cUpdSA1 +=  " UPDATE " + RetSqlName("SA1")                         + CRLF
        _cUpdSA1 +=  " SET    A1_XLC    = 0 "                               + CRLF
        _cUpdSA1 +=  "       ,A1_XVALBO = 0 "                               + CRLF
        _cUpdSA1 +=  "       ,A1_XPEDFP = 0 "                               + CRLF
        _cUpdSA1 +=  "       ,A1_XFPSAL = 0 "                               + CRLF
        _cUpdSA1 +=  "       ,A1_XDTLC  = ' ' "                             + CRLF
        _cUpdSA1 +=  "       ,A1_XSTAFP = '5' "                             + CRLF
        _cUpdSA1 +=  " WHERE A1_FILIAL  = '" + FWxFilial("SA1") + "'"       + CRLF    
        _cUpdSA1 +=  " AND A1_XTPCRED   = '1' "                             + CRLF
        _cUpdSA1 +=  " AND D_E_L_E_T_   = ' ' "                             + CRLF

        If TcSqlExec(_cUpdSA1) < 0
            _lRet := .F.
            Help( ,, "Caoa",, TcSqlError() , 1, 0)
            Disarmtransaction()
        EndIf
    //Finalizando controle de transações
    End Transaction

Return(_lRet)


/*
=====================================================================================
Programa.:              zBuscaCli
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              29/08/2022
Descricao / Objetivo:   Busca o Cliente de acordo com o CNPJ.
Doc. Origem:            
Solicitante:            
Uso......:              [Barueri] - Financeiro
Obs......:
=====================================================================================
*/ 
Static Function zBuscaCli(_cCnpj)
Local _cAliasPesq 	:= GetNextAlias()
Local _nReg         
/*   
    Local _cRet         := " "
    Local _cQrySA1    	:= " "
	Local _cAlsSA1 	  	:= GetNextAlias()
 
    If Select(_cAlsSA1) > 0
		(_cAlsSA1)->(DbCloseArea())
	EndIf

    _cQrySA1 := " "
    //_cQrySA1 += " SELECT SA1.A1_CGC FROM " + RetSqlName("SA1") + " SA1 "    + CRLF
    SELECT 	ISNULL(SA1.R_E_C_N_O_,0) NREGSA1
    _cQrySA1 += " WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "' "          + CRLF
    _cQrySA1 += " AND SUBSTR(SA1.A1_CGC, 1, 8) = '" +_cCnpj+"' "            + CRLF 
    _cQrySA1 += " AND SA1.A1_LOJA = '01' "                                 + CRLF
    _cQrySA1 += " AND SA1.D_E_L_E_T_ = ' ' "                                + CRLF
    DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQrySA1 ), _cAlsSA1, .F., .T. )
	DbSelectArea((_cAlsSA1)) 
	(_cAlsSA1)->(dbGoTop())
	If (_cAlsSA1)->(!Eof())
	    _cRet   := (_cAlsSA1)->A1_CGC
	EndIf
	
	(_cAlsSA1)->(DbCloseArea())
*/
    //Alteração FIN100 Limite de crédito revitalização DAC 09/03/2022    
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT 	ISNULL(SA1.R_E_C_N_O_,0) NREGSA1, SA1.A1_XTPCRED 
		FROM  %Table:SA1% SA1
		WHERE SA1.A1_FILIAL 	= %XFilial:SA1%
            AND SUBSTR(SA1.A1_CGC, 1, 8) = %Exp:_cCnpj%
            AND SA1.A1_XTPCRED  = '1'
			AND SA1.%notDel%    
        ORDER BY SA1.A1_XTPCRED
	EndSQL
    (_cAliasPesq)->(DbGotop())	
	If (_cAliasPesq)->(!Eof()) .AND. (_cAliasPesq)->NREGSA1 > 0 
        _nReg   := (_cAliasPesq)->NREGSA1
    EndIf 

If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
Return _nReg 


