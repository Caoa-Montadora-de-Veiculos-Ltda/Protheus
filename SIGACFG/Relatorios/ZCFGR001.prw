#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

/*
=====================================================================================
Programa.:              ZCFGR001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              16/06/2020
Descricao / Objetivo:   Relatorio de controle de Acessos e Licenças Totvs
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
User Function ZCFGR001() // u_ZFISR001()

	Local cExtens   := "Arquivo XML | *.XML"
	Local cTitulo	:= "Escolha o caminho para salvar o arquivo.!"
	Local cMainPath := "\"
	Local cArquivo	:= ""
    Local aPergs    := {}
    Private aRetP   := {}

    aAdd(aPergs,    {2, "Mostra Usuário Bloqueados ?"                , "NÃO"      , {"NÃO", "SIM"}    ,     050, ".T.", .F.})
    aAdd(aPergs,    {2, "Mostra Usuário Administrador ?"             , "NÃO"      , {"NÃO", "SIM"}    ,     050, ".T.", .F.})
    
    If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 

	    cArquivo := cGetFile(cExtens,cTitulo,,cMainPath,.F.)
	    If !Empty(cArquivo)
	        Processa({|| zRel0001(cArquivo)}	,"Gerando Relatório de Usuários.."	)
	    EndIf

    EndIf
	
Return()

/*
=====================================================================================
Programa.:              zRel0001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              16/06/2020
Descricao / Objetivo:   Gera Excel com os usuários
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function zRel0001(cArquivo)

	Local cQryUsr		:= ""
    Local cQryGrp		:= ""
    Local cQryMod		:= ""
    Local cQryUsM		:= ""
	Local cTmpUsr		:= GetNextAlias()
    Local cTmpGrp		:= GetNextAlias()
    Local cTmpMod		:= GetNextAlias()
    Local cTmpUsM		:= GetNextAlias()
	Local cAba1			:= "Analitico"
	Local cAba2			:= "Sintetico"
    Local cAba3			:= "SIGAEIC"
    Local cAba4			:= "SIGAMNT"
    Local cAba5			:= "SIGAVEI"
	Local cTabela1		:= "Relação Analitica"
	Local cTabela2		:= "Relação Sintetica"
    Local cTabela3		:= "SIGAEIC"
    Local cTabela4		:= "SIGAMNT"
    Local cTabela5		:= "SIGAVEI"
    Local aGrpAcess     := {}
    Local cGrpAcess     := ""
    Local cGrpTOut      := ""
    Local cUsrTOut      := ""
    Local cRegra        := ""
    Local cUserEIC      := ""
    Local cUserMNT      := ""
    Local cUserVEI      := ""
    Local cUserPTMnt    := ""
    Local cStatus       := ""
    Local cUserAdmin    := ""
    Local nPos          := 0
    Local _nX           := 0
    Local _nZ           := 0
    Local nMnt          := 0
    Local nMntPt        := 0
	Local oFWMsExcel
	Local oExcel
    Local aModulos       := {}
    Local aLicenca       := {}
    Local aSigaEIC       := {}
    Local aSigaMNT       := {}
    Local aSigaVEI       := {}

    cUserEIC      := GetMV("CMV_EICAC1")
    cUserMNT      := GetMV("CMV_MNTAC1")
    cUserVEI      := GetMV("CMV_VEIAC1")
    cUserPTMnt    := GetMV("CMV_MNTPT1")
	
	If !ApOleClient( "MSExcel" )
		MsgAlert( "Microsoft Excel não instalado!!" )
		Return
	EndIf

	If Select( (cTmpUsr) ) > 0
		(cTmpUsr)->(DbCloseArea())
	EndIf

    //SELECIONA TODOS OS USUÁRIOS DO SISTEMA
    cQryUsr := ""
    cQryUsr += " SELECT USR_ID, USR_CODIGO, USR_NOME, USR_MSBLQL, USR_GRPRULE, USR_CHGPSW, USR_DTLOGON " + CRLF
    cQryUsr += " FROM ABDHDU_PROT.SYS_USR "                                                              + CRLF
    cQryUsr += " WHERE D_E_L_E_T_ = ' ' "                                                                + CRLF
    If aRetP[1] == "NÃO"
        cQryUsr += " AND USR_MSBLQL = '2' "                                                              + CRLF
    EndIf
    
    If aRetP[2] == "NÃO"
        cQryUsr += " AND USR_ID <> '000000' "                                                            + CRLF
    EndIf
    
    //cQryUsr += " AND USR_ID = '000028' "                                                            + CRLF

    cQryUsr += " ORDER BY USR_ID "                                                                       + CRLF

	cQryUsr := ChangeQuery(cQryUsr)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryUsr), cTmpUsr, .T., .T. )

	DbSelectArea((cTmpUsr))
	nTotReg := Contar(cTmpUsr,"!Eof()")
	(cTmpUsr)->(dbGoTop())
	If (cTmpUsr)->(!Eof())

		// Criando o objeto que irá gerar o conteúdo do Excel.
		oFWMsExcel := FWMSExcelEx():New()

		// Aba 01
		oFWMsExcel:AddworkSheet(cAba1) // Não utilizar número junto com sinal de menos. Ex.: 1-.

		// Criando a Tabela.
		oFWMsExcel:AddTable( cAba1	,cTabela1	)                                                

		// Criando Colunas.
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"ID"					        ,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Código"					    ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nome" 					    ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Status"					    ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Regra"					    ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Ult.Logon"					,2	,4	,.F.	) // Center - Data
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Módulo por Grupo"			    ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Módulo por Usuário"			,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAATF"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGACOM"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGACON"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAEST"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAFAT"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAFIN"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAGPE"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAFAS"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAFIS"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAPCP"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAVEI"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGALOJA"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGATMK"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAOFI"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGARPM"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAPON"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAEIC"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGATCF"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAMNT"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGARSP"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAQIE"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAQMT"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAFRT"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAQDO"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAQIP"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGATRM"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAEIF"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGATEC"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAEEC"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAEFF"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAECO"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAAFV"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAPLS"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGACTB"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAMDT"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAQNC"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAQAD"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAQCP"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAOMS"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGACSA"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAPEC"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAWMS"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGATMS"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAPMS"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGACDA"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAACD"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAPPAP"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAREP"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAGE "      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAEDC"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAHSP"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAVDOC"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAAPD"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAGSP"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGACRD"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGASGA"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAPCO"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAGPR"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAGAC"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAPRA"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAGFP"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAHHG"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAHPL"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAAPT"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAGAV"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAICE"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAAGR"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAARM"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAGCT"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAORG"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGALVE"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAPHOTO"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGACRM"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGABPM"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAAPON"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAJURI"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAPFS"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAGFE"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGASFC"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAACV"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGALOG"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGADPR"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAVPON"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGATAF"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAESS"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAVDF"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAGCP"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAGTP"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGATUR"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAGCV"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAPDS"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGATFL"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAESP"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAESP1"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGAESP2"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"SIGACFG"      				,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"ADMIN"      				    ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"GRUPOS"				        ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"TIME OUT GROUP"		        ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"TIME OUT USER"      		    ,2	,1	,.F.	) // Center - Texto

		// Conta quantos registros existem, e seta no tamanho da régua.
		ProcRegua( nTotReg )

		DbSelectArea((cTmpUsr))
		(cTmpUsr)->(dbGoTop())

		While (cTmpUsr)->(!EoF())

			// Incrementa a mensagem na régua.
			IncProc("Exportando informações para Excel...")            

            cRegra := ""
            If (cTmpUsr)->USR_GRPRULE == '1'
                cRegra := "1 - Priorizar"
            ElseIf (cTmpUsr)->USR_GRPRULE == '2'
                cRegra := "2 - Desconsiderar"
            ElseIf (cTmpUsr)->USR_GRPRULE == '3'
                cRegra := "3 - Soma"
            EndIf

	        //SELECIONA O GRUPO QUE CADA USUÁRIO PERTENCE
            If Select( (cTmpGrp) ) > 0
		        (cTmpGrp)->(DbCloseArea())
	        EndIf

            cQryGrp := ""
            cQryGrp += " SELECT USR_GRUPO FROM ABDHDU_PROT.SYS_USR_GROUPS "             + CRLF
            cQryGrp += " WHERE  D_E_L_E_T_ = ' ' "                                      + CRLF
            cQryGrp += " AND USR_ID = '" + Alltrim( (cTmpUsr)->USR_ID ) + "' "          + CRLF
            cQryGrp += " AND USR_GRUPO <> ' ' "                                         + CRLF
            cQryGrp += " ORDER BY USR_GRUPO "                                           + CRLF

            cQryGrp := ChangeQuery(cQryGrp)

	        // Executa a consulta.
	        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryGrp), cTmpGrp, .T., .T. )

	        DbSelectArea((cTmpGrp))
            (cTmpGrp)->(dbGoTop())
	        If (cTmpGrp)->(!Eof())
                While (cTmpGrp)->(!Eof())

                    //SELECIONA O MODULO DE CADA GRUPO
                    If Select( (cTmpMod) ) > 0
		                (cTmpMod)->(DbCloseArea())
	                EndIf

                    cQryMod := ""
                    cQryMod += " SELECT GR__ID, GR__ACESSO, GR__MODULO FROM ABDHDU_PROT.SYS_GRP_MODULE "    + CRLF
                    cQryMod += " WHERE  D_E_L_E_T_ = ' ' "                                                  + CRLF
                    cQryMod += " AND GR__ID = '" + Alltrim( (cTmpGrp)->USR_GRUPO ) + "' "                   + CRLF
                    cQryMod += " AND GR__ACESSO = 'T' "                                                     + CRLF
                    cQryMod += " ORDER BY GR__MODULO "                                                      + CRLF

                    cQryMod := ChangeQuery(cQryMod)

	                // Executa a consulta.
	                DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryMod), cTmpMod, .T., .T. )

	                DbSelectArea((cTmpMod))
                    (cTmpMod)->(dbGoTop())
	                If (cTmpMod)->(!Eof())
                        While (cTmpMod)->(!Eof())
                            aAdd( aModulos, {   Alltrim( (cTmpUsr)->USR_ID ) + AllTrim( Str( (cTmpMod)->GR__MODULO ) ) ,; //CHAVE DE PESQUISA
                                                Alltrim( (cTmpUsr)->USR_ID )        ,; //ID DO USUÁRIO
                                                Alltrim( (cTmpUsr)->USR_CODIGO )    ,; // CÓDIGO DO USUÁRIO
                                                Alltrim( (cTmpUsr)->USR_NOME )      ,; // NOME DO USUÁRIO
                                                IIf( (cTmpUsr)->USR_MSBLQL == "2" , "ATIVO", "BLOQUEADO" )  ,; //STATUS DO USUÁRIO
                                                Alltrim( cRegra )                   ,; // REGRA DO GRUPO
                                                IIF( Empty( SToD( (cTmpUsr)->USR_DTLOGON ) ), "", SToD( (cTmpUsr)->USR_DTLOGON ) ) ,;
                                                "SIM"                               ,; // MÓDULO POR GRUPO
                                                "NÃO"                               ,; // MÓDULO POR USUÁRIO
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "01" , "SIM", " " ) ,; // TEM ACESSO AO SIGAATF   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "02" , "SIM", " " ) ,; // TEM ACESSO AO SIGACOM   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "03" , "SIM", " " ) ,; // TEM ACESSO AO SIGACON   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "04" , "SIM", " " ) ,; // TEM ACESSO AO SIGAEST   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "05" , "SIM", " " ) ,; // TEM ACESSO AO SIGAFAT   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "06" , "SIM", " " ) ,; // TEM ACESSO AO SIGAFIN   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "07" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGPE   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "08" , "SIM", " " ) ,; // TEM ACESSO AO SIGAFAS   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "09" , "SIM", " " ) ,; // TEM ACESSO AO SIGAFIS   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "10" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPCP   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "11" , "SIM", " " ) ,; // TEM ACESSO AO SIGAVEI   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "12" , "SIM", " " ) ,; // TEM ACESSO AO SIGALOJA  
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "13" , "SIM", " " ) ,; // TEM ACESSO AO SIGATMK   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "14" , "SIM", " " ) ,; // TEM ACESSO AO SIGAOFI   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "15" , "SIM", " " ) ,; // TEM ACESSO AO SIGARPM   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "16" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPON   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "17" , "SIM", " " ) ,; // TEM ACESSO AO SIGAEIC   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "18" , "SIM", " " ) ,; // TEM ACESSO AO SIGATCF   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "19" , "SIM", " " ) ,; // TEM ACESSO AO SIGAMNT   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "20" , "SIM", " " ) ,; // TEM ACESSO AO SIGARSP   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "21" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQIE   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "22" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQMT   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "23" , "SIM", " " ) ,; // TEM ACESSO AO SIGAFRT   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "24" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQDO   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "25" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQIP   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "26" , "SIM", " " ) ,; // TEM ACESSO AO SIGATRM   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "27" , "SIM", " " ) ,; // TEM ACESSO AO SIGAEIF   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "28" , "SIM", " " ) ,; // TEM ACESSO AO SIGATEC   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "29" , "SIM", " " ) ,; // TEM ACESSO AO SIGAEEC   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "30" , "SIM", " " ) ,; // TEM ACESSO AO SIGAEFF   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "31" , "SIM", " " ) ,; // TEM ACESSO AO SIGAECO   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "32" , "SIM", " " ) ,; // TEM ACESSO AO SIGAAFV   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "33" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPLS   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "34" , "SIM", " " ) ,; // TEM ACESSO AO SIGACTB   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "35" , "SIM", " " ) ,; // TEM ACESSO AO SIGAMDT   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "36" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQNC   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "37" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQAD   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "38" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQCP   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "39" , "SIM", " " ) ,; // TEM ACESSO AO SIGAOMS   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "40" , "SIM", " " ) ,; // TEM ACESSO AO SIGACSA   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "41" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPEC   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "42" , "SIM", " " ) ,; // TEM ACESSO AO SIGAWMS   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "43" , "SIM", " " ) ,; // TEM ACESSO AO SIGATMS   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "44" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPMS   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "45" , "SIM", " " ) ,; // TEM ACESSO AO SIGACDA   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "46" , "SIM", " " ) ,; // TEM ACESSO AO SIGAACD   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "47" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPPAP  
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "48" , "SIM", " " ) ,; // TEM ACESSO AO SIGAREP   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "49" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGE    
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "50" , "SIM", " " ) ,; // TEM ACESSO AO SIGAEDC   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "51" , "SIM", " " ) ,; // TEM ACESSO AO SIGAHSP   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "52" , "SIM", " " ) ,; // TEM ACESSO AO SIGAVDOC  
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "53" , "SIM", " " ) ,; // TEM ACESSO AO SIGAAPD   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "54" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGSP   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "55" , "SIM", " " ) ,; // TEM ACESSO AO SIGACRD   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "56" , "SIM", " " ) ,; // TEM ACESSO AO SIGASGA   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "57" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPCO   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "58" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGPR   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "59" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGAC   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "60" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPRA   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "61" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGFP   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "62" , "SIM", " " ) ,; // TEM ACESSO AO SIGAHHG   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "63" , "SIM", " " ) ,; // TEM ACESSO AO SIGAHPL   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "64" , "SIM", " " ) ,; // TEM ACESSO AO SIGAAPT   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "65" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGAV   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "66" , "SIM", " " ) ,; // TEM ACESSO AO SIGAICE   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "67" , "SIM", " " ) ,; // TEM ACESSO AO SIGAAGR   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "68" , "SIM", " " ) ,; // TEM ACESSO AO SIGAARM   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "69" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGCT   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "70" , "SIM", " " ) ,; // TEM ACESSO AO SIGAORG   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "71" , "SIM", " " ) ,; // TEM ACESSO AO SIGALVE   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "72" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPHOTO 
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "73" , "SIM", " " ) ,; // TEM ACESSO AO SIGACRM   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "74" , "SIM", " " ) ,; // TEM ACESSO AO SIGABPM   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "75" , "SIM", " " ) ,; // TEM ACESSO AO SIGAAPON  
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "76" , "SIM", " " ) ,; // TEM ACESSO AO SIGAJURI  
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "77" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPFS   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "78" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGFE   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "79" , "SIM", " " ) ,; // TEM ACESSO AO SIGASFC   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "80" , "SIM", " " ) ,; // TEM ACESSO AO SIGAACV   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "81" , "SIM", " " ) ,; // TEM ACESSO AO SIGALOG   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "82" , "SIM", " " ) ,; // TEM ACESSO AO SIGADPR   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "83" , "SIM", " " ) ,; // TEM ACESSO AO SIGAVPON  
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "84" , "SIM", " " ) ,; // TEM ACESSO AO SIGATAF   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "85" , "SIM", " " ) ,; // TEM ACESSO AO SIGAESS   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "86" , "SIM", " " ) ,; // TEM ACESSO AO SIGAVDF   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "87" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGCP   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "88" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGTP   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "89" , "SIM", " " ) ,; // TEM ACESSO AO SIGATUR   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "90" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGCV   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "91" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPDS   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "92" , "SIM", " " ) ,; // TEM ACESSO AO SIGATFL   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "96" , "SIM", " " ) ,; // TEM ACESSO AO SIGAESP2  
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "97" , "SIM", " " ) ,; // TEM ACESSO AO SIGAESP   
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "98" , "SIM", " " ) ,; // TEM ACESSO AO SIGAESP1  
                                                IIf( PadL( (cTmpMod)->GR__MODULO, 2, "0" ) == "99" , "SIM", " " ) }) // TEM ACESSO AO SIGACFG   
                            	                
                            (cTmpMod)->(DbSkip())
                        EndDo
                    EndIf
                    (cTmpMod)->(DbCloseArea())
                    (cTmpGrp)->(DbSkip())
                EndDo
            EndIf
            (cTmpGrp)->(DbCloseArea())

            // Verifica se tem acesso ao módulo por usuári
            If Select( (cTmpUsM) ) > 0
		        (cTmpUsM)->(DbCloseArea())
	        EndIf

            cQryUsM := ""
            cQryUsM += " SELECT USR_MODULO FROM ABDHDU_PROT.SYS_USR_MODULE "        + CRLF
            cQryUsM += " WHERE D_E_L_E_T_ = ' ' "                                   + CRLF
            cQryUsM += " AND USR_ACESSO = 'T' "                                     + CRLF
            cQryUsM += " AND USR_ID = '" + Alltrim( (cTmpUsr)->USR_ID ) + "' "      + CRLF
            cQryUsM += " ORDER BY USR_MODULO "                                      + CRLF

            cQryUsM := ChangeQuery(cQryUsM)

	        // Executa a consulta.
	        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryUsM), cTmpUsM, .T., .T. )

	        DbSelectArea((cTmpUsM))
            (cTmpUsM)->(dbGoTop())
	        If (cTmpUsM)->(!Eof())
                While (cTmpUsM)->(!Eof())
                
                    nPos := aScan( aModulos,{|x| AllTrim(x[01]) == Alltrim( (cTmpUsr)->USR_ID ) + AllTrim( Str( (cTmpUsM)->USR_MODULO ) ) } )
                    If nPos > 0
                        aModulos[nPos][09] := "SIM"
                    Else 
                        aAdd( aModulos, {   Alltrim( (cTmpUsr)->USR_ID ) + AllTrim( Str( (cTmpUsM)->USR_MODULO ) ) ,; //CHAVE DE PESQUISA
                                            Alltrim( (cTmpUsr)->USR_ID )        ,; //ID DO USUÁRIO
                                            Alltrim( (cTmpUsr)->USR_CODIGO )    ,; // CÓDIGO DO USUÁRIO
                                            Alltrim( (cTmpUsr)->USR_NOME )      ,; // NOME DO USUÁRIO
                                            IIf( (cTmpUsr)->USR_MSBLQL == "2" , "ATIVO", "BLOQUEADO" )  ,; //STATUS DO USUÁRIO
                                            Alltrim( cRegra )                   ,; // REGRA DO GRUPO
                                            IIF( Empty( SToD( (cTmpUsr)->USR_DTLOGON ) ), "", SToD( (cTmpUsr)->USR_DTLOGON ) ) ,;
                                            "NÃO"                               ,; // MÓDULO POR GRUPO
                                            "SIM"                               ,; // MÓDULO POR USUÁRIO
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "01" , "SIM", " " ) ,; // TEM ACESSO AO SIGAATF   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "02" , "SIM", " " ) ,; // TEM ACESSO AO SIGACOM   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "03" , "SIM", " " ) ,; // TEM ACESSO AO SIGACON   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "04" , "SIM", " " ) ,; // TEM ACESSO AO SIGAEST   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "05" , "SIM", " " ) ,; // TEM ACESSO AO SIGAFAT   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "06" , "SIM", " " ) ,; // TEM ACESSO AO SIGAFIN   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "07" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGPE   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "08" , "SIM", " " ) ,; // TEM ACESSO AO SIGAFAS   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "09" , "SIM", " " ) ,; // TEM ACESSO AO SIGAFIS   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "10" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPCP   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "11" , "SIM", " " ) ,; // TEM ACESSO AO SIGAVEI   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "12" , "SIM", " " ) ,; // TEM ACESSO AO SIGALOJA  
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "13" , "SIM", " " ) ,; // TEM ACESSO AO SIGATMK   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "14" , "SIM", " " ) ,; // TEM ACESSO AO SIGAOFI   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "15" , "SIM", " " ) ,; // TEM ACESSO AO SIGARPM   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "16" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPON   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "17" , "SIM", " " ) ,; // TEM ACESSO AO SIGAEIC   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "18" , "SIM", " " ) ,; // TEM ACESSO AO SIGATCF   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "19" , "SIM", " " ) ,; // TEM ACESSO AO SIGAMNT   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "20" , "SIM", " " ) ,; // TEM ACESSO AO SIGARSP   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "21" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQIE   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "22" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQMT   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "23" , "SIM", " " ) ,; // TEM ACESSO AO SIGAFRT   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "24" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQDO   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "25" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQIP   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "26" , "SIM", " " ) ,; // TEM ACESSO AO SIGATRM   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "27" , "SIM", " " ) ,; // TEM ACESSO AO SIGAEIF   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "28" , "SIM", " " ) ,; // TEM ACESSO AO SIGATEC   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "29" , "SIM", " " ) ,; // TEM ACESSO AO SIGAEEC   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "30" , "SIM", " " ) ,; // TEM ACESSO AO SIGAEFF   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "31" , "SIM", " " ) ,; // TEM ACESSO AO SIGAECO   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "32" , "SIM", " " ) ,; // TEM ACESSO AO SIGAAFV   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "33" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPLS   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "34" , "SIM", " " ) ,; // TEM ACESSO AO SIGACTB   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "35" , "SIM", " " ) ,; // TEM ACESSO AO SIGAMDT   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "36" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQNC   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "37" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQAD   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "38" , "SIM", " " ) ,; // TEM ACESSO AO SIGAQCP   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "39" , "SIM", " " ) ,; // TEM ACESSO AO SIGAOMS   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "40" , "SIM", " " ) ,; // TEM ACESSO AO SIGACSA   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "41" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPEC   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "42" , "SIM", " " ) ,; // TEM ACESSO AO SIGAWMS   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "43" , "SIM", " " ) ,; // TEM ACESSO AO SIGATMS   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "44" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPMS   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "45" , "SIM", " " ) ,; // TEM ACESSO AO SIGACDA   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "46" , "SIM", " " ) ,; // TEM ACESSO AO SIGAACD   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "47" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPPAP  
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "48" , "SIM", " " ) ,; // TEM ACESSO AO SIGAREP   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "49" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGE    
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "50" , "SIM", " " ) ,; // TEM ACESSO AO SIGAEDC   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "51" , "SIM", " " ) ,; // TEM ACESSO AO SIGAHSP   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "52" , "SIM", " " ) ,; // TEM ACESSO AO SIGAVDOC  
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "53" , "SIM", " " ) ,; // TEM ACESSO AO SIGAAPD   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "54" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGSP   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "55" , "SIM", " " ) ,; // TEM ACESSO AO SIGACRD   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "56" , "SIM", " " ) ,; // TEM ACESSO AO SIGASGA   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "57" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPCO   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "58" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGPR   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "59" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGAC   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "60" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPRA   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "61" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGFP   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "62" , "SIM", " " ) ,; // TEM ACESSO AO SIGAHHG   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "63" , "SIM", " " ) ,; // TEM ACESSO AO SIGAHPL   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "64" , "SIM", " " ) ,; // TEM ACESSO AO SIGAAPT   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "65" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGAV   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "66" , "SIM", " " ) ,; // TEM ACESSO AO SIGAICE   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "67" , "SIM", " " ) ,; // TEM ACESSO AO SIGAAGR   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "68" , "SIM", " " ) ,; // TEM ACESSO AO SIGAARM   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "69" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGCT   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "70" , "SIM", " " ) ,; // TEM ACESSO AO SIGAORG   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "71" , "SIM", " " ) ,; // TEM ACESSO AO SIGALVE   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "72" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPHOTO 
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "73" , "SIM", " " ) ,; // TEM ACESSO AO SIGACRM   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "74" , "SIM", " " ) ,; // TEM ACESSO AO SIGABPM   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "75" , "SIM", " " ) ,; // TEM ACESSO AO SIGAAPON  
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "76" , "SIM", " " ) ,; // TEM ACESSO AO SIGAJURI  
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "77" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPFS   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "78" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGFE   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "79" , "SIM", " " ) ,; // TEM ACESSO AO SIGASFC   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "80" , "SIM", " " ) ,; // TEM ACESSO AO SIGAACV   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "81" , "SIM", " " ) ,; // TEM ACESSO AO SIGALOG   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "82" , "SIM", " " ) ,; // TEM ACESSO AO SIGADPR   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "83" , "SIM", " " ) ,; // TEM ACESSO AO SIGAVPON  
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "84" , "SIM", " " ) ,; // TEM ACESSO AO SIGATAF   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "85" , "SIM", " " ) ,; // TEM ACESSO AO SIGAESS   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "86" , "SIM", " " ) ,; // TEM ACESSO AO SIGAVDF   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "87" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGCP   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "88" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGTP   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "89" , "SIM", " " ) ,; // TEM ACESSO AO SIGATUR   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "90" , "SIM", " " ) ,; // TEM ACESSO AO SIGAGCV   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "91" , "SIM", " " ) ,; // TEM ACESSO AO SIGAPDS   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "92" , "SIM", " " ) ,; // TEM ACESSO AO SIGATFL   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "96" , "SIM", " " ) ,; // TEM ACESSO AO SIGAESP2  
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "97" , "SIM", " " ) ,; // TEM ACESSO AO SIGAESP   
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "98" , "SIM", " " ) ,; // TEM ACESSO AO SIGAESP1  
                                            IIf( PadL( (cTmpUsM)->USR_MODULO , 2, "0" ) == "99" , "SIM", " " ) }) // TEM ACESSO AO SIGACFG 
                    EndIf
                
                (cTmpUsM)->(DbSkip())
                EndDo
            EndIf
            (cTmpUsM)->(DbCloseArea())
    
    		(cTmpUsr)->(DbSkip())
		EndDo
        (cTmpUsr)->(DbCloseArea())

        If Len(aModulos) > 0

            aPrinter := ZTrataArray(aModulos)
            
            For _nX := 1 to Len(aPrinter)

                cUserAdmin  := ""
                If FwIsAdmin( Alltrim( aPrinter[_nX][002] ) ) 
                    cUserAdmin  := "SIM"
                Else
                    cUserAdmin  := "NÃO"
                EndIf

                aGrpAcess := {}
                aGrpAcess := zGrp(Alltrim( aPrinter[_nX][002] ))

                cGrpAcess   := ""
                cGrpTOut    := ""
                For _nZ := 1 to Len(aGrpAcess)
                    If Empty(cGrpAcess)
                        cGrpAcess := AllTrim( aGrpAcess[_nZ][001] )
                    Else
                        cGrpAcess += ""+ CRLF + AllTrim( aGrpAcess[_nZ][001] )
                    EndIf
                    
                    If Empty(cGrpTOut)
                        cGrpTOut := AllTrim( aGrpAcess[_nZ][002] )
                    Else
                        cGrpTOut += ""+ CRLF + AllTrim( aGrpAcess[_nZ][002] )
                    EndIf       
                Next

                cUsrTOut    := zTOutUsr(aPrinter[_nX][002])
                

                oFWMSExcel:AddRow( cAba1	,cTabela1	,{  Alltrim( aPrinter[_nX][002] ) ,; // ID DO USUÁRIO
                                                            Alltrim( aPrinter[_nX][003] ) ,; // CÓDIGO DO USUÁRIO
                                                            Alltrim( aPrinter[_nX][004] ) ,; // NOME DO USUÁRIO
                                                            Alltrim( aPrinter[_nX][005] ) ,; // STATUS DO USUÁRIO
                                                            Alltrim( aPrinter[_nX][006] ) ,; // REGRA DO GRUPO
                                                            Alltrim( aPrinter[_nX][007] ) ,; // ULTIMO LOGON 
                                                            Alltrim( aPrinter[_nX][008] ) ,; // MÓDULO POR GRUPO
                                                            Alltrim( aPrinter[_nX][009] ) ,; // MÓDULO POR USUÁRIO
                                                            Alltrim( aPrinter[_nX][010] ) ,; // TEM ACESSO AO SIGAATF   
                                                            Alltrim( aPrinter[_nX][011] ) ,; // TEM ACESSO AO SIGACOM   
                                                            Alltrim( aPrinter[_nX][012] ) ,; // TEM ACESSO AO SIGACON   
                                                            Alltrim( aPrinter[_nX][013] ) ,; // TEM ACESSO AO SIGAEST   
                                                            Alltrim( aPrinter[_nX][014] ) ,; // TEM ACESSO AO SIGAFAT   
                                                            Alltrim( aPrinter[_nX][015] ) ,; // TEM ACESSO AO SIGAFIN   
                                                            Alltrim( aPrinter[_nX][016] ) ,; // TEM ACESSO AO SIGAGPE   
                                                            Alltrim( aPrinter[_nX][017] ) ,; // TEM ACESSO AO SIGAFAS   
                                                            Alltrim( aPrinter[_nX][018] ) ,; // TEM ACESSO AO SIGAFIS   
                                                            Alltrim( aPrinter[_nX][019] ) ,; // TEM ACESSO AO SIGAPCP   
                                                            Alltrim( aPrinter[_nX][020] ) ,; // TEM ACESSO AO SIGAVEI   
                                                            Alltrim( aPrinter[_nX][021] ) ,; // TEM ACESSO AO SIGALOJA  
                                                            Alltrim( aPrinter[_nX][022] ) ,; // TEM ACESSO AO SIGATMK   
                                                            Alltrim( aPrinter[_nX][023] ) ,; // TEM ACESSO AO SIGAOFI   
                                                            Alltrim( aPrinter[_nX][024] ) ,; // TEM ACESSO AO SIGARPM   
                                                            Alltrim( aPrinter[_nX][025] ) ,; // TEM ACESSO AO SIGAPON   
                                                            Alltrim( aPrinter[_nX][026] ) ,; // TEM ACESSO AO SIGAEIC   
                                                            Alltrim( aPrinter[_nX][027] ) ,; // TEM ACESSO AO SIGATCF   
                                                            Alltrim( aPrinter[_nX][028] ) ,; // TEM ACESSO AO SIGAMNT   
                                                            Alltrim( aPrinter[_nX][029] ) ,; // TEM ACESSO AO SIGARSP   
                                                            Alltrim( aPrinter[_nX][030] ) ,; // TEM ACESSO AO SIGAQIE   
                                                            Alltrim( aPrinter[_nX][031] ) ,; // TEM ACESSO AO SIGAQMT   
                                                            Alltrim( aPrinter[_nX][032] ) ,; // TEM ACESSO AO SIGAFRT   
                                                            Alltrim( aPrinter[_nX][033] ) ,; // TEM ACESSO AO SIGAQDO   
                                                            Alltrim( aPrinter[_nX][034] ) ,; // TEM ACESSO AO SIGAQIP   
                                                            Alltrim( aPrinter[_nX][035] ) ,; // TEM ACESSO AO SIGATRM   
                                                            Alltrim( aPrinter[_nX][036] ) ,; // TEM ACESSO AO SIGAEIF   
                                                            Alltrim( aPrinter[_nX][037] ) ,; // TEM ACESSO AO SIGATEC   
                                                            Alltrim( aPrinter[_nX][038] ) ,; // TEM ACESSO AO SIGAEEC   
                                                            Alltrim( aPrinter[_nX][039] ) ,; // TEM ACESSO AO SIGAEFF   
                                                            Alltrim( aPrinter[_nX][040] ) ,; // TEM ACESSO AO SIGAECO   
                                                            Alltrim( aPrinter[_nX][041] ) ,; // TEM ACESSO AO SIGAAFV   
                                                            Alltrim( aPrinter[_nX][042] ) ,; // TEM ACESSO AO SIGAPLS   
                                                            Alltrim( aPrinter[_nX][043] ) ,; // TEM ACESSO AO SIGACTB   
                                                            Alltrim( aPrinter[_nX][044] ) ,; // TEM ACESSO AO SIGAMDT   
                                                            Alltrim( aPrinter[_nX][045] ) ,; // TEM ACESSO AO SIGAQNC   
                                                            Alltrim( aPrinter[_nX][046] ) ,; // TEM ACESSO AO SIGAQAD   
                                                            Alltrim( aPrinter[_nX][047] ) ,; // TEM ACESSO AO SIGAQCP   
                                                            Alltrim( aPrinter[_nX][048] ) ,; // TEM ACESSO AO SIGAOMS   
                                                            Alltrim( aPrinter[_nX][049] ) ,; // TEM ACESSO AO SIGACSA   
                                                            Alltrim( aPrinter[_nX][050] ) ,; // TEM ACESSO AO SIGAPEC   
                                                            Alltrim( aPrinter[_nX][051] ) ,; // TEM ACESSO AO SIGAWMS   
                                                            Alltrim( aPrinter[_nX][052] ) ,; // TEM ACESSO AO SIGATMS   
                                                            Alltrim( aPrinter[_nX][053] ) ,; // TEM ACESSO AO SIGAPMS   
                                                            Alltrim( aPrinter[_nX][054] ) ,; // TEM ACESSO AO SIGACDA   
                                                            Alltrim( aPrinter[_nX][055] ) ,; // TEM ACESSO AO SIGAACD   
                                                            Alltrim( aPrinter[_nX][056] ) ,; // TEM ACESSO AO SIGAPPAP  
                                                            Alltrim( aPrinter[_nX][057] ) ,; // TEM ACESSO AO SIGAREP   
                                                            Alltrim( aPrinter[_nX][058] ) ,; // TEM ACESSO AO SIGAGE    
                                                            Alltrim( aPrinter[_nX][059] ) ,; // TEM ACESSO AO SIGAEDC   
                                                            Alltrim( aPrinter[_nX][060] ) ,; // TEM ACESSO AO SIGAHSP   
                                                            Alltrim( aPrinter[_nX][061] ) ,; // TEM ACESSO AO SIGAVDOC  
                                                            Alltrim( aPrinter[_nX][062] ) ,; // TEM ACESSO AO SIGAAPD   
                                                            Alltrim( aPrinter[_nX][063] ) ,; // TEM ACESSO AO SIGAGSP   
                                                            Alltrim( aPrinter[_nX][064] ) ,; // TEM ACESSO AO SIGACRD   
                                                            Alltrim( aPrinter[_nX][065] ) ,; // TEM ACESSO AO SIGASGA   
                                                            Alltrim( aPrinter[_nX][066] ) ,; // TEM ACESSO AO SIGAPCO   
                                                            Alltrim( aPrinter[_nX][067] ) ,; // TEM ACESSO AO SIGAGPR   
                                                            Alltrim( aPrinter[_nX][068] ) ,; // TEM ACESSO AO SIGAGAC   
                                                            Alltrim( aPrinter[_nX][069] ) ,; // TEM ACESSO AO SIGAPRA   
                                                            Alltrim( aPrinter[_nX][070] ) ,; // TEM ACESSO AO SIGAGFP   
                                                            Alltrim( aPrinter[_nX][071] ) ,; // TEM ACESSO AO SIGAHHG   
                                                            Alltrim( aPrinter[_nX][072] ) ,; // TEM ACESSO AO SIGAHPL   
                                                            Alltrim( aPrinter[_nX][073] ) ,; // TEM ACESSO AO SIGAAPT   
                                                            Alltrim( aPrinter[_nX][074] ) ,; // TEM ACESSO AO SIGAGAV   
                                                            Alltrim( aPrinter[_nX][075] ) ,; // TEM ACESSO AO SIGAICE   
                                                            Alltrim( aPrinter[_nX][076] ) ,; // TEM ACESSO AO SIGAAGR   
                                                            Alltrim( aPrinter[_nX][077] ) ,; // TEM ACESSO AO SIGAARM   
                                                            Alltrim( aPrinter[_nX][078] ) ,; // TEM ACESSO AO SIGAGCT   
                                                            Alltrim( aPrinter[_nX][079] ) ,; // TEM ACESSO AO SIGAORG   
                                                            Alltrim( aPrinter[_nX][080] ) ,; // TEM ACESSO AO SIGALVE   
                                                            Alltrim( aPrinter[_nX][081] ) ,; // TEM ACESSO AO SIGAPHOTO 
                                                            Alltrim( aPrinter[_nX][082] ) ,; // TEM ACESSO AO SIGACRM   
                                                            Alltrim( aPrinter[_nX][083] ) ,; // TEM ACESSO AO SIGABPM   
                                                            Alltrim( aPrinter[_nX][084] ) ,; // TEM ACESSO AO SIGAAPON  
                                                            Alltrim( aPrinter[_nX][085] ) ,; // TEM ACESSO AO SIGAJURI  
                                                            Alltrim( aPrinter[_nX][086] ) ,; // TEM ACESSO AO SIGAPFS   
                                                            Alltrim( aPrinter[_nX][087] ) ,; // TEM ACESSO AO SIGAGFE   
                                                            Alltrim( aPrinter[_nX][088] ) ,; // TEM ACESSO AO SIGASFC   
                                                            Alltrim( aPrinter[_nX][089] ) ,; // TEM ACESSO AO SIGAACV   
                                                            Alltrim( aPrinter[_nX][090] ) ,; // TEM ACESSO AO SIGALOG   
                                                            Alltrim( aPrinter[_nX][091] ) ,; // TEM ACESSO AO SIGADPR   
                                                            Alltrim( aPrinter[_nX][092] ) ,; // TEM ACESSO AO SIGAVPON  
                                                            Alltrim( aPrinter[_nX][093] ) ,; // TEM ACESSO AO SIGATAF   
                                                            Alltrim( aPrinter[_nX][094] ) ,; // TEM ACESSO AO SIGAESS   
                                                            Alltrim( aPrinter[_nX][095] ) ,; // TEM ACESSO AO SIGAVDF   
                                                            Alltrim( aPrinter[_nX][096] ) ,; // TEM ACESSO AO SIGAGCP   
                                                            Alltrim( aPrinter[_nX][097] ) ,; // TEM ACESSO AO SIGAGTP   
                                                            Alltrim( aPrinter[_nX][098] ) ,; // TEM ACESSO AO SIGATUR   
                                                            Alltrim( aPrinter[_nX][099] ) ,; // TEM ACESSO AO SIGAGCV   
                                                            Alltrim( aPrinter[_nX][100] ) ,; // TEM ACESSO AO SIGAPDS   
                                                            Alltrim( aPrinter[_nX][101] ) ,; // TEM ACESSO AO SIGATFL   
                                                            Alltrim( aPrinter[_nX][102] ) ,; // TEM ACESSO AO SIGAESP2  
                                                            Alltrim( aPrinter[_nX][103] ) ,; // TEM ACESSO AO SIGAESP   
                                                            Alltrim( aPrinter[_nX][104] ) ,; // TEM ACESSO AO SIGAESP1  
                                                            Alltrim( aPrinter[_nX][105] ) ,; // TEM ACESSO AO SIGACFG      
                                                            cUserAdmin                    ,; // USUÁRIO ADMIN
                                                            cGrpAcess                     ,; // QUAIS GRUPOS O USER PERTENCE  
                                                            cGrpTOut                      ,; // TIME OUT CONFIGURADO POR Grupo
                                                            cUsrTOut                       })// TIME OUT CONFIGURADO POR USUÁRIO
                
                If !( Empty( aPrinter[_nX][010] ) ) // TEM ACESSO AO SIGAATF   
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAATF"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAATF" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][011] ) ) // TEM ACESSO AO SIGACOM
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGACOM"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGACOM" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][012] ) ) // TEM ACESSO AO SIGACON
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGACON"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGACON" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][013] ) ) // TEM ACESSO AO SIGAEST
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAEST"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAEST" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][014] ) ) // TEM ACESSO AO SIGAFAT
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAFAT"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAFAT" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][015] ) ) // TEM ACESSO AO SIGAFIN
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAFIN"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAFIN" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][016] ) ) // TEM ACESSO AO SIGAGPE
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAGPE"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAGPE" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][017] ) ) // TEM ACESSO AO SIGAFAS
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAFAS"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAFAS" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][013] ) ) // TEM ACESSO AO SIGAEST
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAEST"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAEST" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][015] ) ) // TEM ACESSO AO SIGAFIN
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAFIN"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAFIN" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][016] ) ) // TEM ACESSO AO SIGAGPE
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAGPE"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAGPE" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][018] ) ) // TEM ACESSO AO SIGAFIS
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAFIS"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAFIS" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][019] ) ) // TEM ACESSO AO SIGAPCP
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAPCP"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAPCP" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][020] ) ) // TEM ACESSO AO SIGAVEI
                    aAdd( aSigaVEI, {  "SIGAVEI" ,;                 // MODULO
                                        aPrinter[_nX][002] ,;       // ID DO USUÁRIO
                                        aPrinter[_nX][003] })       // NOME DO USUÁRIO
                    
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAVEI"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAVEI" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][021] ) ) // TEM ACESSO AO SIGALOJA
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGALOJA"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGALOJA" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][022] ) ) // TEM ACESSO AO SIGATMK
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGATMK"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGATMK" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][023] ) ) // TEM ACESSO AO SIGAOFI
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAOFI"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAOFI" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][024] ) ) // TEM ACESSO AO SIGARPM
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGARPM"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGARPM" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][025] ) ) // TEM ACESSO AO SIGAPON
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAPON"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAPON" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][026] ) ) // TEM ACESSO AO SIGAEIC

                    aAdd( aSigaEIC, {  "SIGAEIC" ,; // MODULO
                        aPrinter[_nX][002] ,;       // ID DO USUÁRIO
                        aPrinter[_nX][003] })       // NOME DO USUÁRIO

                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAEIC"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAEIC" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][027] ) ) // TEM ACESSO AO SIGATCF
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGATCF"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGATCF" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][028] ) ) // TEM ACESSO AO SIGAMNT

                    aAdd( aSigaMNT, {  "SIGAMNT" ,; // MODULO
                        aPrinter[_nX][002] ,;       // ID DO USUÁRIO
                        aPrinter[_nX][003] })       // NOME DO USUÁRIO

                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAMNT"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAMNT" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][029] ) ) // TEM ACESSO AO SIGARSP
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGARSP"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGARSP" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][030] ) ) // TEM ACESSO AO SIGAQIE
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAQIE"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAQIE" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][031] ) ) // TEM ACESSO AO SIGAQMT
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAQMT"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAQMT" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][032] ) ) // TEM ACESSO AO SIGAFRT
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAFRT"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAFRT" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][033] ) ) // TEM ACESSO AO SIGAQDO
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAQDO"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAQDO" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][034] ) ) // TEM ACESSO AO SIGAQIP
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAQIP"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAQIP" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][035] ) ) // TEM ACESSO AO SIGATRM
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGATRM"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGATRM" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][036] ) ) // TEM ACESSO AO SIGAEIF
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAEIF"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAEIF" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][037] ) ) // TEM ACESSO AO SIGATEC
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGATEC"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGATEC" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][038] ) ) // TEM ACESSO AO SIGAEEC
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAEEC"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAEEC" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][039] ) ) // TEM ACESSO AO SIGAEFF
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAEFF"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAEFF" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][040] ) ) // TEM ACESSO AO SIGAECO
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAECO"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAECO" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][041] ) ) // TEM ACESSO AO SIGAAFV
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAAFV"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAAFV" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][042] ) ) // TEM ACESSO AO SIGAPLS
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAPLS"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAPLS" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][043] ) ) // TEM ACESSO AO SIGACTB
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGACTB"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGACTB" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][044] ) ) // TEM ACESSO AO SIGAMDT
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAMDT"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAMDT" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][045] ) ) // TEM ACESSO AO SIGAQNC
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAQNC"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAQNC" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][046] ) ) // TEM ACESSO AO SIGAQAD
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAQAD"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAQAD" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][047] ) ) // TEM ACESSO AO SIGAQCP
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAQCP"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAQCP" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][048] ) ) // TEM ACESSO AO SIGAOMS
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAOMS"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAOMS" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][049] ) ) // TEM ACESSO AO SIGACSA
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGACSA"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGACSA" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][050] ) ) // TEM ACESSO AO SIGAPEC
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAPEC"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAPEC" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][051] ) ) // TEM ACESSO AO SIGAWMS
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAWMS"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAWMS" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][052] ) ) // TEM ACESSO AO SIGATMS
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGATMS"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGATMS" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][053] ) ) // TEM ACESSO AO SIGAPMS
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAPMS"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAPMS" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][054] ) ) // TEM ACESSO AO SIGACDA
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGACDA"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGACDA" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][055] ) ) // TEM ACESSO AO SIGAACD
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAACD"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAACD" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][056] ) ) // TEM ACESSO AO SIGAPPAP
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAPPAP"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAPPAP" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][057] ) ) // TEM ACESSO AO SIGAREP
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAREP"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAREP" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][058] ) ) // TEM ACESSO AO SIGAGE
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAGE"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAGE" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][059] ) ) // TEM ACESSO AO SIGAEDC
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAEDC"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAEDC" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][060] ) ) // TEM ACESSO AO SIGAHSP
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAHSP"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAHSP" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][061] ) ) // TEM ACESSO AO SIGAVDOC
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAVDOC"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAVDOC" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][062] ) ) // TEM ACESSO AO SIGAAPD
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAAPD"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAAPD" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][063] ) ) // TEM ACESSO AO SIGAGSP
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAGSP"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAGSP" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][064] ) ) // TEM ACESSO AO SIGACRD
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGACRD"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGACRD" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][065] ) ) // TEM ACESSO AO SIGASGA
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGASGA"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGASGA" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][066] ) ) // TEM ACESSO AO SIGAPCO
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAPCO"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAPCO" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][067] ) ) // TEM ACESSO AO SIGAGPR
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAGPR"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAGPR" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][068] ) ) // TEM ACESSO AO SIGAGAC
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAGAC"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAGAC" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][069] ) ) // TEM ACESSO AO SIGAPRA
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAPRA"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAPRA" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][070] ) ) // TEM ACESSO AO SIGAGFP
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAGFP"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAGFP" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][071] ) ) // TEM ACESSO AO SIGAHHG
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAHHG"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAHHG" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][072] ) ) // TEM ACESSO AO SIGAHPL
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAHPL"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAHPL" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][073] ) ) // TEM ACESSO AO SIGAAPT
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAAPT"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAAPT" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][074] ) ) // TEM ACESSO AO SIGAGAV
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAGAV"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAGAV" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][075] ) ) // TEM ACESSO AO SIGAICE
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAICE"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAICE" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][076] ) ) // TEM ACESSO AO SIGAAGR
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAAGR"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAAGR" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][077] ) ) // TEM ACESSO AO SIGAARM
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAARM"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAARM" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][078] ) ) // TEM ACESSO AO SIGAGCT
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAGCT"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAGCT" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][079] ) ) // TEM ACESSO AO SIGAORG
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAORG"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAORG" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][080] ) ) // TEM ACESSO AO SIGALVE
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGALVE"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGALVE" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][081] ) ) // TEM ACESSO AO SIGAPHOTO
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAPHOTO"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAPHOTO" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][082] ) ) // TEM ACESSO AO SIGACRM
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGACRM"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGACRM" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][083] ) ) // TEM ACESSO AO SIGABPM
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGABPM"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGABPM" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][084] ) ) // TEM ACESSO AO SIGAAPON
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAAPON"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAAPON" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][085] ) ) // TEM ACESSO AO SIGAJURI
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAJURI"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAJURI" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][086] ) ) // TEM ACESSO AO SIGAPFS
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAPFS"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAPFS" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][087] ) ) // TEM ACESSO AO SIGAGFE
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAGFE"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAGFE" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][088] ) ) // TEM ACESSO AO SIGASFC
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGASFC"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGASFC" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][089] ) ) // TEM ACESSO AO SIGAACV
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAACV"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAACV" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][090] ) ) // TEM ACESSO AO SIGALOG
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGALOG"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGALOG" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][091] ) ) // TEM ACESSO AO SIGADPR
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGADPR"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGADPR" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][092] ) ) // TEM ACESSO AO SIGAVPON
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAVPON"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAVPON" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][093] ) ) // TEM ACESSO AO SIGATAF
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGATAF"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGATAF" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][094] ) ) // TEM ACESSO AO SIGAESS
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAESS"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAESS" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][095] ) ) // TEM ACESSO AO SIGAVDF
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAVDF"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAVDF" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][096] ) ) // TEM ACESSO AO SIGAGCP
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAGCP"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAGCP" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][097] ) ) // TEM ACESSO AO SIGAGTP
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAGTP"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAGTP" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][098] ) ) // TEM ACESSO AO SIGATUR
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGATUR"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGATUR" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][099] ) ) // TEM ACESSO AO SIGAGCV
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAGCV"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAGCV" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][100] ) ) // TEM ACESSO AO SIGAPDS
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAPDS"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAPDS" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][101] ) ) // TEM ACESSO AO SIGATFL
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGATFL"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGATFL" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][102] ) ) // TEM ACESSO AO SIGAESP2
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAESP2"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAESP2" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][103] ) ) // TEM ACESSO AO SIGAESP
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAESP"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAESP" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][104] ) ) // TEM ACESSO AO SIGAESP1
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGAESP1"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGAESP1" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf

                If !( Empty( aPrinter[_nX][105] ) ) //TEM ACESSO AO SIGACFG
                    nPosLinc := aScan( aLicenca,{|x| AllTrim(x[001]) == "SIGACFG"  } )
                    If nPosLinc > 0
                        aLicenca[nPosLinc][002] := aLicenca[nPosLinc][002] + 1
                    Else
                        aAdd( aLicenca, {  "SIGACFG" ,;   // MODULO
                                            1        })   // LICENCA
                    EndIf
                EndIf


            Next
		
        
            If Len(aLicenca) > 0

                // Aba 02
                oFWMsExcel:AddworkSheet(cAba2) //Não utilizar número junto com sinal de menos. Ex.: 1-.

                // Criando a Tabela.
                oFWMsExcel:AddTable( cAba2	,cTabela2	)

                // Criando Colunas.
                oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Módulo"				,1	,1	,.F.	) // Left - Texto	
                oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Qtde Habilitada"	    ,3	,2	,.F.	) // Right - Number
                

                aSort(aLicenca, , , { | x,y | x[1] < y[1] } )

                For _nX := 1 to Len(aLicenca)
                    
                    oFWMSExcel:AddRow( cAba2	, cTabela2	, { aLicenca[_nX][1],;    //--Empresa
                                                                aLicenca[_nX][2] } )    //--Descrição
                Next

            EndIf

            If Len(aSigaEIC) > 0

                cTabela3 += " - Usando: " + AllTrim( Str ( Len(aSigaEIC) ) ) + " - Disponivel: 31 "

                // Aba 02
                oFWMsExcel:AddworkSheet(cAba3) //Não utilizar número junto com sinal de menos. Ex.: 1-.

                // Criando a Tabela.
                oFWMsExcel:AddTable( cAba3	,cTabela3	)

                // Criando Colunas.
                oFWMsExcel:AddColumn( cAba3	,cTabela3	,"Módulo"				,1	,1	,.F.	) // Left - Texto	
                oFWMsExcel:AddColumn( cAba3	,cTabela3	,"Id User"				,1	,1	,.F.	) // Left - Texto	
                oFWMsExcel:AddColumn( cAba3	,cTabela3	,"Nome"				    ,1	,1	,.F.	) // Left - Texto	
                oFWMsExcel:AddColumn( cAba3	,cTabela3	,"Status"				,1	,1	,.F.	) // Left - Texto	

                For _nX := 1 to Len(aSigaEIC)

                    cStatus := ""
                    If aSigaEIC[_nX][02] $ cUserEIC
                        cStatus := "POSSUI ACESSO"
                    Else
                        cStatus := "NÃO POSSUI ACESSO"
                    EndIf

                    oFWMSExcel:AddRow( cAba3	, cTabela3	, { aSigaEIC[_nX][01],;     // MODULO
                                                                aSigaEIC[_nX][02],;     // ID DO USER
                                                                aSigaEIC[_nX][03],;     // NOME DO USUARIO
                                                                cStatus          } )    // STATUS
                Next

            EndIf

            If Len(aSigaMNT) > 0

                For _nX := 1 to Len(aSigaMNT)

                    If aSigaMNT[_nX][02] $ cUserMNT
                        nMnt++
                    Else
                        If aSigaMNT[_nX][02] $ cUserPTMnt
                            nMntPt++
                        Else
                            nMnt++
                        EndIf
                    EndIf
                Next

                cTabela4 += " - 1 Comunic.Portal + " + AllTrim( Str ( nMnt ) ) + " Acesso ao Módulo - Disponivel: 35 ( " + AllTrim( Str ( nMntPt ) ) + " Somente Portal ) "

                // Aba 02
                oFWMsExcel:AddworkSheet(cAba4) //Não utilizar número junto com sinal de menos. Ex.: 1-.

                // Criando a Tabela.
                oFWMsExcel:AddTable( cAba4	,cTabela4	)

                // Criando Colunas.
                oFWMsExcel:AddColumn( cAba4	,cTabela4	,"Módulo"				,1	,1	,.F.	) // Left - Texto	
                oFWMsExcel:AddColumn( cAba4	,cTabela4	,"Id User"				,1	,1	,.F.	) // Left - Texto	
                oFWMsExcel:AddColumn( cAba4	,cTabela4	,"Nome"				    ,1	,1	,.F.	) // Left - Texto	
                oFWMsExcel:AddColumn( cAba4	,cTabela4	,"Status"				,1	,1	,.F.	) // Left - Texto	

                _nX := 0
                For _nX := 1 to Len(aSigaMNT)

                    cStatus := ""
                    If aSigaMNT[_nX][02] $ cUserMNT
                        cStatus := "ACESSO AO MODULO"
                    Else
                        If aSigaMNT[_nX][02] $ cUserPTMnt
                            cStatus := "ACESSO AO PORTAL"
                        Else
                            cStatus := "NAO POSSUI ACESSO"
                        EndIf
                    EndIf

                    oFWMSExcel:AddRow( cAba4	, cTabela4	, { aSigaMNT[_nX][01],;     // MODULO
                                                                aSigaMNT[_nX][02],;     // ID DO USER
                                                                aSigaMNT[_nX][03],;     // NOME DO USUARIO
                                                                cStatus          } )    // STATUS
                Next

            EndIf

            If Len(aSigaVEI) > 0

                cTabela5 += " - Usando: " + AllTrim( Str ( Len(aSigaVEI) ) ) + " - Disponivel: 31 "

                // Aba 02
                oFWMsExcel:AddworkSheet(cAba5) //Não utilizar número junto com sinal de menos. Ex.: 1-.

                // Criando a Tabela.
                oFWMsExcel:AddTable( cAba5	,cTabela5	)

                // Criando Colunas.
                oFWMsExcel:AddColumn( cAba5	,cTabela5	,"Módulo"				,1	,1	,.F.	) // Left - Texto	
                oFWMsExcel:AddColumn( cAba5	,cTabela5	,"Id User"				,1	,1	,.F.	) // Left - Texto	
                oFWMsExcel:AddColumn( cAba5	,cTabela5	,"Nome"				    ,1	,1	,.F.	) // Left - Texto	
                oFWMsExcel:AddColumn( cAba5	,cTabela5	,"Status"				,1	,1	,.F.	) // Left - Texto	

                For _nX := 1 to Len(aSigaVEI)

                    cStatus := ""
                    If aSigaVEI[_nX][02] $ cUserVEI
                        cStatus := "POSSUI ACESSO"
                    Else
                        cStatus := "NÃO POSSUI ACESSO"
                    EndIf

                    oFWMSExcel:AddRow( cAba5	, cTabela5	, { aSigaVEI[_nX][01],;     // MODULO
                                                                aSigaVEI[_nX][02],;     // ID DO USER
                                                                aSigaVEI[_nX][03],;     // NOME DO USUARIO
                                                                cStatus          } )    // STATUS
                Next

            EndIf

        EndIf
		// Ativando o arquivo e gerando o xml.
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)

		oFWMsExcel:DeActivate()
		FreeObj(oFWMsExcel)

		// Abrindo o excel e abrindo o arquivo xml.
		oExcel := MsExcel():New()           // Abre uma nova conexão com Excel.
		oExcel:WorkBooks:Open(cArquivo)     // Abre uma planilha.
		oExcel:SetVisible(.T.)              // Visualiza a planilha.
		oExcel:Destroy()                    // Encerra o processo do gerenciador de tarefas.

	Else
		ApMsgAlert( "Não foi encontrado nenhuma nota fiscal com os parâmetros informados!!" )
	EndIf

Return()

/*
=====================================================================================
Programa.:              zRel0002
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              13/06/19
Descricao / Objetivo:   Gera Excel Notas de Saida
Doc. Origem:            GAP EST007 E GAP FAT022
Solicitante:            Fiscal
Uso......:              zSelect
Obs......:
=====================================================================================

Static Function ZPesqMod(cParam01)

Local cMod  := cParam01
Local cRet  := ""

Do Case
    Case PadL( cMod, 2, "0" ) == "01" 
	    cRet := "01 - SIGAATF"   
    Case PadL( cMod, 2, "0" ) == "02" 
        cRet := "02 - SIGACOM"   
    Case PadL( cMod, 2, "0" ) == "03" 
        cRet := "03 - SIGACON"   
    Case PadL( cMod, 2, "0" ) == "04" 
        cRet := "04 - SIGAEST"   
    Case PadL( cMod, 2, "0" ) == "05" 
        cRet := "05 - SIGAFAT"   
    Case PadL( cMod, 2, "0" ) == "06" 
        cRet := "06 - SIGAFIN"   
    Case PadL( cMod, 2, "0" ) == "07" 
        cRet := "07 - SIGAGPE"   
    Case PadL( cMod, 2, "0" ) == "08" 
        cRet := "08 - SIGAFAS"   
    Case PadL( cMod, 2, "0" ) == "09" 
        cRet := "09 - SIGAFIS"   
    Case PadL( cMod, 2, "0" ) == "10" 
        cRet := "10 - SIGAPCP"   
    Case PadL( cMod, 2, "0" ) == "11" 
        cRet := "11 - SIGAVEI"   
    Case PadL( cMod, 2, "0" ) == "12" 
        cRet := "12 - SIGALOJA"  
    Case PadL( cMod, 2, "0" ) == "13" 
        cRet := "13 - SIGATMK"   
    Case PadL( cMod, 2, "0" ) == "14" 
        cRet := "14 - SIGAOFI"   
    Case PadL( cMod, 2, "0" ) == "15" 
        cRet := "15 - SIGARPM"   
    Case PadL( cMod, 2, "0" ) == "16" 
        cRet := "16 - SIGAPON"   
    Case PadL( cMod, 2, "0" ) == "17" 
        cRet := "17 - SIGAEIC"   
    Case PadL( cMod, 2, "0" ) == "18" 
        cRet := "18 - SIGATCF"   
    Case PadL( cMod, 2, "0" ) == "19" 
        cRet := "19 - SIGAMNT"   
    Case PadL( cMod, 2, "0" ) == "20" 
        cRet := "20 - SIGARSP"   
    Case PadL( cMod, 2, "0" ) == "21" 
        cRet := "21 - SIGAQIE"   
    Case PadL( cMod, 2, "0" ) == "22" 
        cRet := "22 - SIGAQMT"   
    Case PadL( cMod, 2, "0" ) == "23" 
        cRet := "23 - SIGAFRT"   
    Case PadL( cMod, 2, "0" ) == "24" 
        cRet := "24 - SIGAQDO"   
    Case PadL( cMod, 2, "0" ) == "25" 
        cRet := "25 - SIGAQIP"   
    Case PadL( cMod, 2, "0" ) == "26" 
        cRet := "26 - SIGATRM"   
    Case PadL( cMod, 2, "0" ) == "27" 
        cRet := "27 - SIGAEIF"   
    Case PadL( cMod, 2, "0" ) == "28" 
        cRet := "28 - SIGATEC"   
    Case PadL( cMod, 2, "0" ) == "29" 
        cRet := "29 - SIGAEEC"   
    Case PadL( cMod, 2, "0" ) == "30" 
        cRet := "30 - SIGAEFF"   
    Case PadL( cMod, 2, "0" ) == "30" 
        cRet := "31 - SIGAECO"   
    Case PadL( cMod, 2, "0" ) == "32" 
        cRet := "32 - SIGAAFV"   
    Case PadL( cMod, 2, "0" ) == "33" 
        cRet := "33 - SIGAPLS"   
    Case PadL( cMod, 2, "0" ) == "34" 
        cRet := "34 - SIGACTB"   
    Case PadL( cMod, 2, "0" ) == "35" 
        cRet := "35 - SIGAMDT"   
    Case PadL( cMod, 2, "0" ) == "36" 
        cRet := "36 - SIGAQNC"   
    Case PadL( cMod, 2, "0" ) == "37" 
        cRet := "37 - SIGAQAD"   
    Case PadL( cMod, 2, "0" ) == "38" 
        cRet := "38 - SIGAQCP"   
    Case PadL( cMod, 2, "0" ) == "39" 
        cRet := "39 - SIGAOMS"   
    Case PadL( cMod, 2, "0" ) == "40" 
        cRet := "40 - SIGACSA"   
    Case PadL( cMod, 2, "0" ) == "41" 
        cRet := "41 - SIGAPEC"   
    Case PadL( cMod, 2, "0" ) == "42" 
        cRet := "42 - SIGAWMS"   
    Case PadL( cMod, 2, "0" ) == "43" 
        cRet := "43 - SIGATMS"   
    Case PadL( cMod, 2, "0" ) == "44" 
        cRet := "44 - SIGAPMS"   
    Case PadL( cMod, 2, "0" ) == "45" 
        cRet := "45 - SIGACDA"   
    Case PadL( cMod, 2, "0" ) == "46" 
        cRet := "46 - SIGAACD"   
    Case PadL( cMod, 2, "0" ) == "47" 
        cRet := "47 - SIGAPPAP"  
    Case PadL( cMod, 2, "0" ) == "48" 
        cRet := "48 - SIGAREP"   
    Case PadL( cMod, 2, "0" ) == "49" 
        cRet := "49 - SIGAGE "   
    Case PadL( cMod, 2, "0" ) == "50" 
        cRet := "50 - SIGAEDC"   
    Case PadL( cMod, 2, "0" ) == "51" 
        cRet := "51 - SIGAHSP"   
    Case PadL( cMod, 2, "0" ) == "52" 
        cRet := "52 - SIGAVDOC"  
    Case PadL( cMod, 2, "0" ) == "53" 
        cRet := "53 - SIGAAPD"   
    Case PadL( cMod, 2, "0" ) == "54" 
        cRet := "54 - SIGAGSP"   
    Case PadL( cMod, 2, "0" ) == "55" 
        cRet := "55 - SIGACRD"   
    Case PadL( cMod, 2, "0" ) == "56" 
        cRet := "56 - SIGASGA"   
    Case PadL( cMod, 2, "0" ) == "57" 
        cRet := "57 - SIGAPCO"   
    Case PadL( cMod, 2, "0" ) == "58" 
        cRet := "58 - SIGAGPR"   
    Case PadL( cMod, 2, "0" ) == "59" 
        cRet := "59 - SIGAGAC"   
    Case PadL( cMod, 2, "0" ) == "60" 
        cRet := "60 - SIGAPRA"   
    Case PadL( cMod, 2, "0" ) == "61" 
        cRet := "61 - SIGAGFP"   
    Case PadL( cMod, 2, "0" ) == "62" 
        cRet := "62 - SIGAHHG"   
    Case PadL( cMod, 2, "0" ) == "63" 
        cRet := "63 - SIGAHPL"   
    Case PadL( cMod, 2, "0" ) == "64" 
        cRet := "64 - SIGAAPT"   
    Case PadL( cMod, 2, "0" ) == "65" 
        cRet := "65 - SIGAGAV"   
    Case PadL( cMod, 2, "0" ) == "66" 
        cRet := "66 - SIGAICE"   
    Case PadL( cMod, 2, "0" ) == "67" 
        cRet := "67 - SIGAAGR"   
    Case PadL( cMod, 2, "0" ) == "68" 
        cRet := "68 - SIGAARM"   
    Case PadL( cMod, 2, "0" ) == "69" 
        cRet := "69 - SIGAGCT"   
    Case PadL( cMod, 2, "0" ) == "70" 
        cRet := "70 - SIGAORG"   
    Case PadL( cMod, 2, "0" ) == "71" 
        cRet := "71 - SIGALVE"   
    Case PadL( cMod, 2, "0" ) == "72" 
        cRet := "72 - SIGAPHOTO" 
    Case PadL( cMod, 2, "0" ) == "73" 
        cRet := "73 - SIGACRM"   
    Case PadL( cMod, 2, "0" ) == "74" 
        cRet := "74 - SIGABPM"   
    Case PadL( cMod, 2, "0" ) == "75" 
        cRet := "75 - SIGAAPON"  
    Case PadL( cMod, 2, "0" ) == "76" 
        cRet := "76 - SIGAJURI"  
    Case PadL( cMod, 2, "0" ) == "77" 
        cRet := "77 - SIGAPFS"   
    Case PadL( cMod, 2, "0" ) == "78" 
        cRet := "78 - SIGAGFE"   
    Case PadL( cMod, 2, "0" ) == "79" 
        cRet := "79 - SIGASFC"   
    Case PadL( cMod, 2, "0" ) == "80" 
        cRet := "80 - SIGAACV"   
    Case PadL( cMod, 2, "0" ) == "81" 
        cRet := "81 - SIGALOG"   
    Case PadL( cMod, 2, "0" ) == "82" 
        cRet := "82 - SIGADPR"   
    Case PadL( cMod, 2, "0" ) == "83" 
        cRet := "83 - SIGAVPON"  
    Case PadL( cMod, 2, "0" ) == "84" 
        cRet := "84 - SIGATAF"   
    Case PadL( cMod, 2, "0" ) == "85" 
        cRet := "85 - SIGAESS"   
    Case PadL( cMod, 2, "0" ) == "86" 
        cRet := "86 - SIGAVDF"   
    Case PadL( cMod, 2, "0" ) == "87" 
        cRet := "87 - SIGAGCP"   
    Case PadL( cMod, 2, "0" ) == "88" 
        cRet := "88 - SIGAGTP"   
    Case PadL( cMod, 2, "0" ) == "89" 
        cRet := "89 - SIGATUR"   
    Case PadL( cMod, 2, "0" ) == "90" 
        cRet := "90 - SIGAGCV"   
    Case PadL( cMod, 2, "0" ) == "91" 
        cRet := "91 - SIGAPDS"   
    Case PadL( cMod, 2, "0" ) == "92" 
        cRet := "92 - SIGATFL"   
    Case PadL( cMod, 2, "0" ) == "96" 
        cRet := "96 - SIGAESP2"  
    Case PadL( cMod, 2, "0" ) == "97" 
        cRet := "97 - SIGAESP"   
    Case PadL( cMod, 2, "0" ) == "98" 
        cRet := "98 - SIGAESP1"  
    Case PadL( cMod, 2, "0" ) == "99" 
        cRet := "99 - SIGACFG"   
    OtherWise
		cRet := "Módulo não encontrado"
EndCase


If aScan(aLicenca,{|x| AllTrim(x[01]) == PadL( cMod, 2, "0" )  }) > 0
    aLicenca[aScan(aLicenca,{|x| AllTrim(x[01]) == PadL( cMod, 2, "0" ) })][02] := aLicenca[aScan(aLicenca,{|x| AllTrim(x[01]) == PadL( cMod, 2, "0" ) })][02] + 1
Else 
    aAdd( aLicenca, { PadL( cMod, 2, "0" )  ,	1	} ) 
EndIf


Return(cRet)
*/
/*
=====================================================================================
Programa.:              zTrataArray()
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              16/06/19
Descricao / Objetivo:   Agrupa o array
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/

Static Function zTrataArray(aParam)

Local aCopia    := aParam
Local aReturn   := {}
Local _nX       := 0
Local nPos      := 0

aSort(aCopia, , , { | x,y | x[1] < y[1] } )

For _nX := 1 to Len(aCopia)

    nPos := aScan( aReturn,{|x| AllTrim(x[002]) == aCopia[_nX][002]  } )
    If nPos > 0
        If aCopia[_nX][008] == "SIM"
            aReturn[nPos][008] := aCopia[_nX][008] // MÓDULO POR GRUPO
        EndIf

        If aCopia[_nX][009] == "SIM"
            aReturn[nPos][009] := aCopia[_nX][009] // MÓDULO POR USUÁRIO
        EndIf

        If Empty(aReturn[nPos][010])
            aReturn[nPos][010] := aCopia[_nX][010] // TEM ACESSO AO SIGAATF   
        EndIf

        If Empty(aReturn[nPos][011])
            aReturn[nPos][011] := aCopia[_nX][011] // TEM ACESSO AO SIGACOM   
        EndIf

        If Empty(aReturn[nPos][012])
            aReturn[nPos][012] := aCopia[_nX][012] // TEM ACESSO AO SIGACON   
        EndIf

        If Empty(aReturn[nPos][013])
            aReturn[nPos][013] := aCopia[_nX][013] // TEM ACESSO AO SIGAEST   
        EndIf

        If Empty(aReturn[nPos][014])
            aReturn[nPos][014] := aCopia[_nX][014] // TEM ACESSO AO SIGAFAT   
        EndIf

        If Empty(aReturn[nPos][015])
            aReturn[nPos][015] := aCopia[_nX][015] // TEM ACESSO AO SIGAFIN   
        EndIf

        If Empty(aReturn[nPos][016])
            aReturn[nPos][016] := aCopia[_nX][016] // TEM ACESSO AO SIGAGPE   
        EndIf

        If Empty(aReturn[nPos][017])
            aReturn[nPos][017] := aCopia[_nX][017] // TEM ACESSO AO SIGAFAS   
        EndIf

        If Empty(aReturn[nPos][018])
            aReturn[nPos][018] := aCopia[_nX][018] // TEM ACESSO AO SIGAFIS   
        EndIf

        If Empty(aReturn[nPos][019])
            aReturn[nPos][019] := aCopia[_nX][019] // TEM ACESSO AO SIGAPCP   
        EndIf

        If Empty(aReturn[nPos][020])
            aReturn[nPos][020] := aCopia[_nX][020] // TEM ACESSO AO SIGAVEI   
        EndIf

        If Empty(aReturn[nPos][021])
            aReturn[nPos][021] := aCopia[_nX][021] // TEM ACESSO AO SIGALOJA  
        EndIf

        If Empty(aReturn[nPos][022])
            aReturn[nPos][022] := aCopia[_nX][022] // TEM ACESSO AO SIGATMK   
        EndIf

        If Empty(aReturn[nPos][023])
            aReturn[nPos][023] := aCopia[_nX][023] // TEM ACESSO AO SIGAOFI   
        EndIf

        If Empty(aReturn[nPos][024])
            aReturn[nPos][024] := aCopia[_nX][024] // TEM ACESSO AO SIGARPM   
        EndIf

        If Empty(aReturn[nPos][024])
            aReturn[nPos][024] := aCopia[_nX][025] // TEM ACESSO AO SIGAPON   
        EndIf

        If Empty(aReturn[nPos][026])
            aReturn[nPos][026] := aCopia[_nX][026] // TEM ACESSO AO SIGAEIC   
        EndIf

        If Empty(aReturn[nPos][027])
            aReturn[nPos][027] := aCopia[_nX][027] // TEM ACESSO AO SIGATCF   
        EndIf

        If Empty(aReturn[nPos][028])
            aReturn[nPos][028] := aCopia[_nX][028] // TEM ACESSO AO SIGAMNT   
        EndIf

        If Empty(aReturn[nPos][029])
            aReturn[nPos][029] := aCopia[_nX][029] // TEM ACESSO AO SIGARSP   
        EndIf

        If Empty(aReturn[nPos][030])
            aReturn[nPos][030] := aCopia[_nX][030] // TEM ACESSO AO SIGAQIE   
        EndIf

        If Empty(aReturn[nPos][031])
            aReturn[nPos][031] := aCopia[_nX][031] // TEM ACESSO AO SIGAQMT   
        EndIf

        If Empty(aReturn[nPos][032])
            aReturn[nPos][032] := aCopia[_nX][032] // TEM ACESSO AO SIGAFRT   
        EndIf

        If Empty(aReturn[nPos][033])
            aReturn[nPos][033] := aCopia[_nX][033] // TEM ACESSO AO SIGAQDO   
        EndIf

        If Empty(aReturn[nPos][034])
            aReturn[nPos][034] := aCopia[_nX][034] // TEM ACESSO AO SIGAQIP   
        EndIf

        If Empty(aReturn[nPos][035])
            aReturn[nPos][035] := aCopia[_nX][035] // TEM ACESSO AO SIGATRM   
        EndIf

        If Empty(aReturn[nPos][036])
            aReturn[nPos][036] := aCopia[_nX][036] // TEM ACESSO AO SIGAEIF   
        EndIf

        If Empty(aReturn[nPos][037])
            aReturn[nPos][037] := aCopia[_nX][037] // TEM ACESSO AO SIGATEC   
        EndIf

        If Empty(aReturn[nPos][038])
            aReturn[nPos][038] := aCopia[_nX][038] // TEM ACESSO AO SIGAEEC   
        EndIf

        If Empty(aReturn[nPos][038])
            aReturn[nPos][039] := aCopia[_nX][039] // TEM ACESSO AO SIGAEFF   
        EndIf

        If Empty(aReturn[nPos][040])
            aReturn[nPos][040] := aCopia[_nX][040] // TEM ACESSO AO SIGAECO   
        EndIf

        If Empty(aReturn[nPos][041])
            aReturn[nPos][041] := aCopia[_nX][041] // TEM ACESSO AO SIGAAFV   
        EndIf

        If Empty(aReturn[nPos][042])
            aReturn[nPos][042] := aCopia[_nX][042] // TEM ACESSO AO SIGAPLS   
        EndIf

        If Empty(aReturn[nPos][042])
            aReturn[nPos][042] := aCopia[_nX][043] // TEM ACESSO AO SIGACTB   
        EndIf

        If Empty(aReturn[nPos][042])
            aReturn[nPos][044] := aCopia[_nX][044] // TEM ACESSO AO SIGAMDT   
        EndIf

        If Empty(aReturn[nPos][045])
            aReturn[nPos][045] := aCopia[_nX][045] // TEM ACESSO AO SIGAQNC   
        EndIf

        If Empty(aReturn[nPos][046])
            aReturn[nPos][046] := aCopia[_nX][046] // TEM ACESSO AO SIGAQAD   
        EndIf

        If Empty(aReturn[nPos][047])
            aReturn[nPos][047] := aCopia[_nX][047] // TEM ACESSO AO SIGAQCP   
        EndIf

        If Empty(aReturn[nPos][047])
            aReturn[nPos][048] := aCopia[_nX][048] // TEM ACESSO AO SIGAOMS   
        EndIf

        If Empty(aReturn[nPos][049])
            aReturn[nPos][049] := aCopia[_nX][049] // TEM ACESSO AO SIGACSA   
        EndIf

        If Empty(aReturn[nPos][050])
            aReturn[nPos][050] := aCopia[_nX][050] // TEM ACESSO AO SIGAPEC   
        EndIf

        If Empty(aReturn[nPos][051])
            aReturn[nPos][051] := aCopia[_nX][051] // TEM ACESSO AO SIGAWMS   
        EndIf

        If Empty(aReturn[nPos][052])
            aReturn[nPos][052] := aCopia[_nX][052] // TEM ACESSO AO SIGATMS   
        EndIf

        If Empty(aReturn[nPos][053])
            aReturn[nPos][053] := aCopia[_nX][053] // TEM ACESSO AO SIGAPMS   
        EndIf

        If Empty(aReturn[nPos][054])
            aReturn[nPos][054] := aCopia[_nX][054] // TEM ACESSO AO SIGACDA   
        EndIf

        If Empty(aReturn[nPos][055])
            aReturn[nPos][055] := aCopia[_nX][055] // TEM ACESSO AO SIGAACD   
        EndIf

        If Empty(aReturn[nPos][056])
            aReturn[nPos][056] := aCopia[_nX][056] // TEM ACESSO AO SIGAPPAP  
        EndIf

        If Empty(aReturn[nPos][057])
            aReturn[nPos][057] := aCopia[_nX][057] // TEM ACESSO AO SIGAREP   
        EndIf

        If Empty(aReturn[nPos][058])
            aReturn[nPos][058] := aCopia[_nX][058] // TEM ACESSO AO SIGAGE    
        EndIf

        If Empty(aReturn[nPos][059])
            aReturn[nPos][059] := aCopia[_nX][059] // TEM ACESSO AO SIGAEDC   
        EndIf

        If Empty(aReturn[nPos][060])
            aReturn[nPos][060] := aCopia[_nX][060] // TEM ACESSO AO SIGAHSP   
        EndIf

        If Empty(aReturn[nPos][061])
            aReturn[nPos][061] := aCopia[_nX][061] // TEM ACESSO AO SIGAVDOC  
        EndIf

        If Empty(aReturn[nPos][061])
            aReturn[nPos][062] := aCopia[_nX][062] // TEM ACESSO AO SIGAAPD   
        EndIf

        If Empty(aReturn[nPos][063])
            aReturn[nPos][063] := aCopia[_nX][063] // TEM ACESSO AO SIGAGSP   
        EndIf

        If Empty(aReturn[nPos][064])
            aReturn[nPos][064] := aCopia[_nX][064] // TEM ACESSO AO SIGACRD   
        EndIf

        If Empty(aReturn[nPos][065])
            aReturn[nPos][065] := aCopia[_nX][065] // TEM ACESSO AO SIGASGA   
        EndIf

        If Empty(aReturn[nPos][066])
            aReturn[nPos][066] := aCopia[_nX][066] // TEM ACESSO AO SIGAPCO   
        EndIf

        If Empty(aReturn[nPos][067])
            aReturn[nPos][067] := aCopia[_nX][067] // TEM ACESSO AO SIGAGPR   
        EndIf

        If Empty(aReturn[nPos][068])
            aReturn[nPos][068] := aCopia[_nX][068] // TEM ACESSO AO SIGAGAC   
        EndIf

        If Empty(aReturn[nPos][069])
            aReturn[nPos][069] := aCopia[_nX][069] // TEM ACESSO AO SIGAPRA   
        EndIf

        If Empty(aReturn[nPos][070])
            aReturn[nPos][070] := aCopia[_nX][070] // TEM ACESSO AO SIGAGFP   
        EndIf

        If Empty(aReturn[nPos][071])
            aReturn[nPos][071] := aCopia[_nX][071] // TEM ACESSO AO SIGAHHG   
        EndIf

        If Empty(aReturn[nPos][072])
            aReturn[nPos][072] := aCopia[_nX][072] // TEM ACESSO AO SIGAHPL   
        EndIf

        If Empty(aReturn[nPos][073])
            aReturn[nPos][073] := aCopia[_nX][073] // TEM ACESSO AO SIGAAPT   
        EndIf

        If Empty(aReturn[nPos][074])
            aReturn[nPos][074] := aCopia[_nX][074] // TEM ACESSO AO SIGAGAV   
        EndIf

        If Empty(aReturn[nPos][075])
            aReturn[nPos][075] := aCopia[_nX][075] // TEM ACESSO AO SIGAICE   
        EndIf

        If Empty(aReturn[nPos][076])
            aReturn[nPos][076] := aCopia[_nX][076] // TEM ACESSO AO SIGAAGR   
        EndIf

        If Empty(aReturn[nPos][077])
            aReturn[nPos][077] := aCopia[_nX][077] // TEM ACESSO AO SIGAARM   
        EndIf

        If Empty(aReturn[nPos][078])
            aReturn[nPos][078] := aCopia[_nX][078] // TEM ACESSO AO SIGAGCT   
        EndIf

        If Empty(aReturn[nPos][079])
            aReturn[nPos][079] := aCopia[_nX][079] // TEM ACESSO AO SIGAORG   
        EndIf

        If Empty(aReturn[nPos][080])
            aReturn[nPos][080] := aCopia[_nX][080] // TEM ACESSO AO SIGALVE   
        EndIf

        If Empty(aReturn[nPos][081])
            aReturn[nPos][081] := aCopia[_nX][081] // TEM ACESSO AO SIGAPHOTO 
        EndIf

        If Empty(aReturn[nPos][082])
            aReturn[nPos][082] := aCopia[_nX][082] // TEM ACESSO AO SIGACRM   
        EndIf

        If Empty(aReturn[nPos][083])
            aReturn[nPos][083] := aCopia[_nX][083] // TEM ACESSO AO SIGABPM   
        EndIf

        If Empty(aReturn[nPos][084])
            aReturn[nPos][084] := aCopia[_nX][084] // TEM ACESSO AO SIGAAPON  
        EndIf

        If Empty(aReturn[nPos][085])
            aReturn[nPos][085] := aCopia[_nX][085] // TEM ACESSO AO SIGAJURI  
        EndIf

        If Empty(aReturn[nPos][086])
            aReturn[nPos][086] := aCopia[_nX][086] // TEM ACESSO AO SIGAPFS   
        EndIf

        If Empty(aReturn[nPos][087])
            aReturn[nPos][087] := aCopia[_nX][087] // TEM ACESSO AO SIGAGFE   
        EndIf

        If Empty(aReturn[nPos][088])
            aReturn[nPos][088] := aCopia[_nX][088] // TEM ACESSO AO SIGASFC   
        EndIf

        If Empty(aReturn[nPos][089])
            aReturn[nPos][089] := aCopia[_nX][089] // TEM ACESSO AO SIGAACV   
        EndIf

        If Empty(aReturn[nPos][090])
            aReturn[nPos][090] := aCopia[_nX][090] // TEM ACESSO AO SIGALOG   
        EndIf

        If Empty(aReturn[nPos][091])
            aReturn[nPos][091] := aCopia[_nX][091] // TEM ACESSO AO SIGADPR   
        EndIf

        If Empty(aReturn[nPos][092])
            aReturn[nPos][092] := aCopia[_nX][092] // TEM ACESSO AO SIGAVPON  
        EndIf

        If Empty(aReturn[nPos][030])
            aReturn[nPos][093] := aCopia[_nX][093] // TEM ACESSO AO SIGATAF   
        EndIf

        If Empty(aReturn[nPos][094])
            aReturn[nPos][094] := aCopia[_nX][094] // TEM ACESSO AO SIGAESS   
        EndIf

        If Empty(aReturn[nPos][095])
            aReturn[nPos][095] := aCopia[_nX][095] // TEM ACESSO AO SIGAVDF   
        EndIf

        If Empty(aReturn[nPos][096])
            aReturn[nPos][096] := aCopia[_nX][096] // TEM ACESSO AO SIGAGCP   
        EndIf

        If Empty(aReturn[nPos][097])
            aReturn[nPos][097] := aCopia[_nX][097] // TEM ACESSO AO SIGAGTP   
        EndIf

        If Empty(aReturn[nPos][098])
            aReturn[nPos][098] := aCopia[_nX][098] // TEM ACESSO AO SIGATUR   
        EndIf

        If Empty(aReturn[nPos][099])
            aReturn[nPos][099] := aCopia[_nX][099] // TEM ACESSO AO SIGAGCV   
        EndIf

        If Empty(aReturn[nPos][100])
            aReturn[nPos][100] := aCopia[_nX][100] // TEM ACESSO AO SIGAPDS   
        EndIf

        If Empty(aReturn[nPos][101])
            aReturn[nPos][101] := aCopia[_nX][101] // TEM ACESSO AO SIGATFL   
        EndIf

        If Empty(aReturn[nPos][102])
            aReturn[nPos][102] := aCopia[_nX][102] // TEM ACESSO AO SIGAESP2  
        EndIf

        If Empty(aReturn[nPos][103])
            aReturn[nPos][103] := aCopia[_nX][103] // TEM ACESSO AO SIGAESP   
        EndIf

        If Empty(aReturn[nPos][104])
            aReturn[nPos][104] := aCopia[_nX][104] // TEM ACESSO AO SIGAESP1  
        EndIf

        If Empty(aReturn[nPos][105])
            aReturn[nPos][105] := aCopia[_nX][105] // TEM ACESSO AO SIGACFG 
        EndIf

    Else  
        aAdd( aReturn,  {  Alltrim( aCopia[_nX][001] ) ,; // CHAVE DE PESQUISA
                            Alltrim( aCopia[_nX][002] ) ,; // ID DO USUÁRIO
                            Alltrim( aCopia[_nX][003] ) ,; // CÓDIGO DO USUÁRIO
                            Alltrim( aCopia[_nX][004] ) ,; // NOME DO USUÁRIO
                            Alltrim( aCopia[_nX][005] ) ,; // STATUS DO USUÁRIO
                            Alltrim( aCopia[_nX][006] ) ,; // REGRA DO GRUPO
                            Alltrim( aCopia[_nX][007] ) ,; // ULTIMO LOGON 
                            Alltrim( aCopia[_nX][008] ) ,; // MÓDULO POR GRUPO
                            Alltrim( aCopia[_nX][009] ) ,; // MÓDULO POR USUÁRIO
                            Alltrim( aCopia[_nX][010] ) ,; // TEM ACESSO AO SIGAATF   
                            Alltrim( aCopia[_nX][011] ) ,; // TEM ACESSO AO SIGACOM   
                            Alltrim( aCopia[_nX][012] ) ,; // TEM ACESSO AO SIGACON   
                            Alltrim( aCopia[_nX][013] ) ,; // TEM ACESSO AO SIGAEST   
                            Alltrim( aCopia[_nX][014] ) ,; // TEM ACESSO AO SIGAFAT   
                            Alltrim( aCopia[_nX][015] ) ,; // TEM ACESSO AO SIGAFIN   
                            Alltrim( aCopia[_nX][016] ) ,; // TEM ACESSO AO SIGAGPE   
                            Alltrim( aCopia[_nX][017] ) ,; // TEM ACESSO AO SIGAFAS   
                            Alltrim( aCopia[_nX][018] ) ,; // TEM ACESSO AO SIGAFIS   
                            Alltrim( aCopia[_nX][019] ) ,; // TEM ACESSO AO SIGAPCP   
                            Alltrim( aCopia[_nX][020] ) ,; // TEM ACESSO AO SIGAVEI   
                            Alltrim( aCopia[_nX][021] ) ,; // TEM ACESSO AO SIGALOJA  
                            Alltrim( aCopia[_nX][022] ) ,; // TEM ACESSO AO SIGATMK   
                            Alltrim( aCopia[_nX][023] ) ,; // TEM ACESSO AO SIGAOFI   
                            Alltrim( aCopia[_nX][024] ) ,; // TEM ACESSO AO SIGARPM   
                            Alltrim( aCopia[_nX][025] ) ,; // TEM ACESSO AO SIGAPON   
                            Alltrim( aCopia[_nX][026] ) ,; // TEM ACESSO AO SIGAEIC   
                            Alltrim( aCopia[_nX][027] ) ,; // TEM ACESSO AO SIGATCF   
                            Alltrim( aCopia[_nX][028] ) ,; // TEM ACESSO AO SIGAMNT   
                            Alltrim( aCopia[_nX][029] ) ,; // TEM ACESSO AO SIGARSP   
                            Alltrim( aCopia[_nX][030] ) ,; // TEM ACESSO AO SIGAQIE   
                            Alltrim( aCopia[_nX][031] ) ,; // TEM ACESSO AO SIGAQMT   
                            Alltrim( aCopia[_nX][032] ) ,; // TEM ACESSO AO SIGAFRT   
                            Alltrim( aCopia[_nX][033] ) ,; // TEM ACESSO AO SIGAQDO   
                            Alltrim( aCopia[_nX][034] ) ,; // TEM ACESSO AO SIGAQIP   
                            Alltrim( aCopia[_nX][035] ) ,; // TEM ACESSO AO SIGATRM   
                            Alltrim( aCopia[_nX][036] ) ,; // TEM ACESSO AO SIGAEIF   
                            Alltrim( aCopia[_nX][037] ) ,; // TEM ACESSO AO SIGATEC   
                            Alltrim( aCopia[_nX][038] ) ,; // TEM ACESSO AO SIGAEEC   
                            Alltrim( aCopia[_nX][039] ) ,; // TEM ACESSO AO SIGAEFF   
                            Alltrim( aCopia[_nX][040] ) ,; // TEM ACESSO AO SIGAECO   
                            Alltrim( aCopia[_nX][041] ) ,; // TEM ACESSO AO SIGAAFV   
                            Alltrim( aCopia[_nX][042] ) ,; // TEM ACESSO AO SIGAPLS   
                            Alltrim( aCopia[_nX][043] ) ,; // TEM ACESSO AO SIGACTB   
                            Alltrim( aCopia[_nX][044] ) ,; // TEM ACESSO AO SIGAMDT   
                            Alltrim( aCopia[_nX][045] ) ,; // TEM ACESSO AO SIGAQNC   
                            Alltrim( aCopia[_nX][046] ) ,; // TEM ACESSO AO SIGAQAD   
                            Alltrim( aCopia[_nX][047] ) ,; // TEM ACESSO AO SIGAQCP   
                            Alltrim( aCopia[_nX][048] ) ,; // TEM ACESSO AO SIGAOMS   
                            Alltrim( aCopia[_nX][049] ) ,; // TEM ACESSO AO SIGACSA   
                            Alltrim( aCopia[_nX][050] ) ,; // TEM ACESSO AO SIGAPEC   
                            Alltrim( aCopia[_nX][051] ) ,; // TEM ACESSO AO SIGAWMS   
                            Alltrim( aCopia[_nX][052] ) ,; // TEM ACESSO AO SIGATMS   
                            Alltrim( aCopia[_nX][053] ) ,; // TEM ACESSO AO SIGAPMS   
                            Alltrim( aCopia[_nX][054] ) ,; // TEM ACESSO AO SIGACDA   
                            Alltrim( aCopia[_nX][055] ) ,; // TEM ACESSO AO SIGAACD   
                            Alltrim( aCopia[_nX][056] ) ,; // TEM ACESSO AO SIGAPPAP  
                            Alltrim( aCopia[_nX][057] ) ,; // TEM ACESSO AO SIGAREP   
                            Alltrim( aCopia[_nX][058] ) ,; // TEM ACESSO AO SIGAGE    
                            Alltrim( aCopia[_nX][059] ) ,; // TEM ACESSO AO SIGAEDC   
                            Alltrim( aCopia[_nX][060] ) ,; // TEM ACESSO AO SIGAHSP   
                            Alltrim( aCopia[_nX][061] ) ,; // TEM ACESSO AO SIGAVDOC  
                            Alltrim( aCopia[_nX][062] ) ,; // TEM ACESSO AO SIGAAPD   
                            Alltrim( aCopia[_nX][063] ) ,; // TEM ACESSO AO SIGAGSP   
                            Alltrim( aCopia[_nX][064] ) ,; // TEM ACESSO AO SIGACRD   
                            Alltrim( aCopia[_nX][065] ) ,; // TEM ACESSO AO SIGASGA   
                            Alltrim( aCopia[_nX][066] ) ,; // TEM ACESSO AO SIGAPCO   
                            Alltrim( aCopia[_nX][067] ) ,; // TEM ACESSO AO SIGAGPR   
                            Alltrim( aCopia[_nX][068] ) ,; // TEM ACESSO AO SIGAGAC   
                            Alltrim( aCopia[_nX][069] ) ,; // TEM ACESSO AO SIGAPRA   
                            Alltrim( aCopia[_nX][070] ) ,; // TEM ACESSO AO SIGAGFP   
                            Alltrim( aCopia[_nX][071] ) ,; // TEM ACESSO AO SIGAHHG   
                            Alltrim( aCopia[_nX][072] ) ,; // TEM ACESSO AO SIGAHPL   
                            Alltrim( aCopia[_nX][073] ) ,; // TEM ACESSO AO SIGAAPT   
                            Alltrim( aCopia[_nX][074] ) ,; // TEM ACESSO AO SIGAGAV   
                            Alltrim( aCopia[_nX][075] ) ,; // TEM ACESSO AO SIGAICE   
                            Alltrim( aCopia[_nX][076] ) ,; // TEM ACESSO AO SIGAAGR   
                            Alltrim( aCopia[_nX][077] ) ,; // TEM ACESSO AO SIGAARM   
                            Alltrim( aCopia[_nX][078] ) ,; // TEM ACESSO AO SIGAGCT   
                            Alltrim( aCopia[_nX][079] ) ,; // TEM ACESSO AO SIGAORG   
                            Alltrim( aCopia[_nX][080] ) ,; // TEM ACESSO AO SIGALVE   
                            Alltrim( aCopia[_nX][081] ) ,; // TEM ACESSO AO SIGAPHOTO 
                            Alltrim( aCopia[_nX][082] ) ,; // TEM ACESSO AO SIGACRM   
                            Alltrim( aCopia[_nX][083] ) ,; // TEM ACESSO AO SIGABPM   
                            Alltrim( aCopia[_nX][084] ) ,; // TEM ACESSO AO SIGAAPON  
                            Alltrim( aCopia[_nX][085] ) ,; // TEM ACESSO AO SIGAJURI  
                            Alltrim( aCopia[_nX][086] ) ,; // TEM ACESSO AO SIGAPFS   
                            Alltrim( aCopia[_nX][087] ) ,; // TEM ACESSO AO SIGAGFE   
                            Alltrim( aCopia[_nX][088] ) ,; // TEM ACESSO AO SIGASFC   
                            Alltrim( aCopia[_nX][089] ) ,; // TEM ACESSO AO SIGAACV   
                            Alltrim( aCopia[_nX][090] ) ,; // TEM ACESSO AO SIGALOG   
                            Alltrim( aCopia[_nX][091] ) ,; // TEM ACESSO AO SIGADPR   
                            Alltrim( aCopia[_nX][092] ) ,; // TEM ACESSO AO SIGAVPON  
                            Alltrim( aCopia[_nX][093] ) ,; // TEM ACESSO AO SIGATAF   
                            Alltrim( aCopia[_nX][094] ) ,; // TEM ACESSO AO SIGAESS   
                            Alltrim( aCopia[_nX][095] ) ,; // TEM ACESSO AO SIGAVDF   
                            Alltrim( aCopia[_nX][096] ) ,; // TEM ACESSO AO SIGAGCP   
                            Alltrim( aCopia[_nX][097] ) ,; // TEM ACESSO AO SIGAGTP   
                            Alltrim( aCopia[_nX][098] ) ,; // TEM ACESSO AO SIGATUR   
                            Alltrim( aCopia[_nX][099] ) ,; // TEM ACESSO AO SIGAGCV   
                            Alltrim( aCopia[_nX][100] ) ,; // TEM ACESSO AO SIGAPDS   
                            Alltrim( aCopia[_nX][101] ) ,; // TEM ACESSO AO SIGATFL   
                            Alltrim( aCopia[_nX][102] ) ,; // TEM ACESSO AO SIGAESP2  
                            Alltrim( aCopia[_nX][103] ) ,; // TEM ACESSO AO SIGAESP   
                            Alltrim( aCopia[_nX][104] ) ,; // TEM ACESSO AO SIGAESP1  
                            Alltrim( aCopia[_nX][105] ) }) // TEM ACESSO AO SIGACFG  
    EndIf
Next


Return(aReturn)

/*
=====================================================================================
Programa.:              zTOutUsr()
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              13/07/2020
Descricao / Objetivo:   Retorna o TimeOut do usuário
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function zTOutUsr(cParam)

Local cQry      := ""
Local cTable    := GetNextAlias()
Local cUser     := cParam
Local cRet      := ""

If Select( (cTable) ) > 0
    (cTable)->(DbCloseArea())
EndIf

cQry := ""
cQry += " SELECT USR_TIMEOUT "                          + CRLF
cQry += " FROM ABDHDU_PROT.SYS_USR "                    + CRLF 
cQry += " WHERE D_E_L_E_T_ = ' ' "                      + CRLF 
cQry += " AND USR_ID = '" + Alltrim( cUser ) + "' "     + CRLF 
cQry += " ORDER BY USR_ID "                             + CRLF

cQry := ChangeQuery(cQry)

// Executa a consulta.
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTable, .T., .T. )

DbSelectArea((cTable))
(cTable)->(dbGoTop())
If (cTable)->(!Eof())
    cRet := AllTrim( Str( (cTable)->USR_TIMEOUT ) )
Else
    cRet := "0"
EndIf

Return(cRet)
/*
=====================================================================================
Programa.:              zGrp()
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              13/07/2020
Descricao / Objetivo:   Retorna os Grupos que o usuário pertence.
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/

Static Function zGrp(cId)

Local cQry      := ""
Local cTable    := GetNextAlias()
Local cUser     := cId
Local aGrpRet   := {}

If Select( (cTable) ) > 0
    (cTable)->(DbCloseArea())
EndIf

cQry := ""
cQry += " SELECT IDGRUPO.USR_GRUPO, ACGRUPO.GR__ID, ACGRUPO.GR__CODIGO, ACGRUPO.GR__NOME, ACGRUPO.GR__TIMEOUT  FROM ABDHDU_PROT.SYS_USR_GROUPS IDGRUPO "    + CRLF
cQry += "     INNER JOIN ABDHDU_PROT.SYS_GRP_GROUP ACGRUPO "                                                                                                + CRLF
cQry += "     ON IDGRUPO.USR_GRUPO = ACGRUPO.GR__ID "                                                                                                       + CRLF
cQry += "     AND ACGRUPO.D_E_L_E_T_ = ' ' "                                                                                                                + CRLF
cQry += " WHERE IDGRUPO.D_E_L_E_T_ = ' ' "                                                                                                                  + CRLF                      
cQry += " AND IDGRUPO.USR_ID = '" + Alltrim( cUser ) + "' "                                                                                                 + CRLF        
cQry += " AND IDGRUPO.USR_GRUPO <> ' ' "                                                                                                                    + CRLF                        
cQry += " ORDER BY IDGRUPO.USR_GRUPO "                                                                                                                      + CRLF   

cQry := ChangeQuery(cQry)

// Executa a consulta.
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTable, .T., .T. )

DbSelectArea((cTable))
(cTable)->(dbGoTop())
If (cTable)->(!Eof())
    While (cTable)->(!Eof())
        
        aAdd( aGrpRet, {  Alltrim((cTable)->USR_GRUPO) + " | " + Alltrim( (cTable)->GR__NOME ) , AllTrim( Str( (cTable)->GR__TIMEOUT ) )  })   //Grupo de acesso

        (cTable)->(DbSkip())
    EndDo
    (cTable)->(DbCloseArea())  
Else
    aAdd( aGrpRet, {  "NÃO PERTENCE A GRUPO"," "  })   //Grupo de acesso 
EndIf


Return(aGrpRet)

