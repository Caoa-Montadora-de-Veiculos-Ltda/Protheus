#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"
/*
=====================================================================================
Programa.:              ZPECR001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              04/03/22
Descricao / Objetivo:   Exportação Tabela de Preço
Doc. Origem:            
Solicitante:            Barueri
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZPECR001()

	Processa({|| zRel0001()}	,"Gerando Relatório..."	)

Return()

/*
=====================================================================================
Programa.:              zRel0001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              08/12/21
Descricao / Objetivo:   Gera relatorio
Doc. Origem:            
Solicitante:            Logistica
Uso......:              ZEICR001
Obs......:
=====================================================================================
*/
Static Function zRel0001()

	Local lUserAut      := .F.
	Local cQuery	  	:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cArquivo	  	:= GetTempPath()+'Tabela_de_preco'+SUBSTRING(dtoc(date()),1,2)+SUBSTRING(dtoc(date()),4,2)+SUBSTRING(dtoc(date()),9,2)+'_'+SUBSTRING(time(),1,2) +SUBSTRING(time(),4,2) +SUBSTRING(time(),7,2)+'.xml'
	Local oFWMsExcel
	Local oExcel
	Local aParamBox 	:= {}
	Local aRet 			:= {}	
	Local cOrigem		:= ""
	Local nTotReg		:= 0
	Private aArea     := GetArea()
	Private aRetP     := {}

	If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB

		lUserAut 	:= U_ZGENUSER( RetCodUsr() ,FunName(),.T.)

    	If lUserAut

			aAdd(aParamBox,{1 ,"Tabela de Preço :" 	,Space(TamSX3("DA0_CODTAB")[1])	,"@!","","DA0","",40	,.T.}) // Tipo caractere
			
			If ParamBox(aParamBox,"Parametros para geração do Arquivo...",@aRet)

				//Criando o objeto que irá gerar o conteúdo do Excel
				oFWMsExcel := FWMSExcel():New()

				//Aba - Gympass
				oFWMsExcel:AddworkSheet("Tabela de Preço por UF")
			
				//Criando a Tabela
				oFWMsExcel:AddTable("Tabela de Preço por UF","Tabela")
				
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","Produto"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","Descricao"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","NCM"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","Tabela"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","Origem"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","IPI"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","Grupo Trib."		,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","MARCA"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","Prc_Lista"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","ACRE"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","ALAGOAS"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","AMAPA"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","AMAZONAS"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","BAHIA"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","CEARA"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","DISTRITO"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","ESP. SANTO"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","GOIAS"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","MARANHAO"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","MINAS"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","MATO G.SUL"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","MATO GROSSO"		,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","PARA"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","PARAIBA"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","PERNAMBUCO"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","PIAUI"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","PARANA"				,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","RIO JANEIRO"		,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","RIO G.NORTE"		,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","RONDONIA"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","RORAIMA"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","RIO G. SUL"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","STA CATARINA"		,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","SERGIPE"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","SAO PAULO"			,1)
				oFWMsExcel:AddColumn("Tabela de Preço por UF","Tabela","TOCANTINS"			,1)
				
				If Select( (cAliasTRB) ) > 0
					(cAliasTRB)->(DbCloseArea())
				EndIf

				cQuery += " SELECT														" + CRLF
				cQuery += " 		DA1.DA1_CODPRO,										" + CRLF
				cQuery += " 		SB1.B1_DESC,										" + CRLF
				cQuery += " 		SB1.B1_POSIPI,										" + CRLF
				cQuery += " 		DA1.DA1_CODTAB,										" + CRLF
				cQuery += " 		SB1.B1_ORIGEM,										" + CRLF
				cQuery += " 		SB1.B1_IPI,											" + CRLF
				cQuery += " 		SBM.BM_CODMAR,										" + CRLF 
				cQuery += " 		DA1.DA1_PRCVEN,										" + CRLF
				cQuery += " 		DA1.DA1_XACIMP,         							" + CRLF
				cQuery += " 		DA1.DA1_XALIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XAPIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XAMIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XBAIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XCEIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XDFIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XESIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XGOIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XMAIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XMGIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XMSIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XMTIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XPAIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XPBIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XPEIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XPIIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XPRIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XRJIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XRNIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XROIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XRRIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XRSIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XSCIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XSEIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XSPIMP,										" + CRLF
				cQuery += " 		DA1.DA1_XTOIMP,										" + CRLF	
				cQuery += " 		SB1.B1_GRTRIB										" + CRLF	
				cQuery += " FROM " +  RetSQLName("DA0") +" DA0 							" + CRLF
				cQuery += " 		INNER JOIN " +  RetSQLName("DA1") +" DA1			" + CRLF
				cQuery += " 		ON DA1.DA1_FILIAL = DA0.DA0_FILIAL					" + CRLF 
				cQuery += " 		AND DA1.DA1_CODTAB = DA0.DA0_CODTAB					" + CRLF  
				cQuery += " 		AND DA1.D_E_L_E_T_ = ' '							" + CRLF
				cQuery += " 	INNER JOIN " +  RetSQLName("SB1") +" SB1				" + CRLF
				cQuery += " 		ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "'		" + CRLF
				cQuery += " 		AND SB1.B1_COD = DA1.DA1_CODPRO						" + CRLF
				cQuery += " 		AND SB1.D_E_L_E_T_ = ' '							" + CRLF
				cQuery += "     INNER JOIN " + RetSqlName("SBM") + " SBM                " + CRLF
				cQuery += "         ON SBM.BM_FILIAL = SB1.B1_FILIAL                    " + CRLF
				cQuery += "         AND SBM.BM_GRUPO = SB1.B1_GRUPO                     " + CRLF
				cQuery += "         AND SBM.D_E_L_E_T_ = ' '                            " + CRLF
				cQuery += " WHERE DA0.DA0_FILIAL = '" + FWxFilial('DA0') + "'			" + CRLF
				cQuery += " AND DA0.DA0_CODTAB = '" + aRet[1] + "'						" + CRLF
				cQuery += " AND DA0.D_E_L_E_T_ = ' '									" + CRLF
				cQuery += " ORDER BY DA0.DA0_FILIAL, DA1.DA1_CODPRO 					" + CRLF

				cQuery := ChangeQuery(cQuery)

				// Executa a consulta.
				DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

				DbSelectArea((cAliasTRB))
				nTotReg := Contar(cAliasTRB,"!Eof()")
				(cAliasTRB)->(dbGoTop())
		
				While !(cAliasTRB)->(EoF())

					// Incrementa a mensagem na régua.
					IncProc("Exportando informações para Excel...")

					cOrigem	:= GetAdvFVal("SX5","X5_DESCRI",xFilial( "SX5" ) + "S0" + (cAliasTRB)->B1_ORIGEM, 1, "")

					oFWMsExcel:AddRow(	"Tabela de Preço por UF","Tabela",{;
										(cAliasTRB)->DA1_CODPRO,;
										AllTrim((cAliasTRB)->B1_DESC),;
										(cAliasTRB)->B1_POSIPI,;
										(cAliasTRB)->DA1_CODTAB,;
										(cAliasTRB)->B1_ORIGEM+"-"+cOrigem,;
										(cAliasTRB)->B1_IPI,;
										(cAliasTRB)->B1_GRTRIB,;
                                        (cAliasTRB)->BM_CODMAR,;
										(cAliasTRB)->DA1_PRCVEN,;
										(cAliasTRB)->DA1_XACIMP,;
										(cAliasTRB)->DA1_XALIMP,;
										(cAliasTRB)->DA1_XAPIMP,;
										(cAliasTRB)->DA1_XAMIMP,;
										(cAliasTRB)->DA1_XBAIMP,;
										(cAliasTRB)->DA1_XCEIMP,;
										(cAliasTRB)->DA1_XDFIMP,;
										(cAliasTRB)->DA1_XESIMP,;
										(cAliasTRB)->DA1_XGOIMP,;
										(cAliasTRB)->DA1_XMAIMP,;
										(cAliasTRB)->DA1_XMGIMP,;
										(cAliasTRB)->DA1_XMSIMP,;
										(cAliasTRB)->DA1_XMTIMP,;
										(cAliasTRB)->DA1_XPAIMP,;
										(cAliasTRB)->DA1_XPBIMP,;
										(cAliasTRB)->DA1_XPEIMP,;
										(cAliasTRB)->DA1_XPIIMP,;
										(cAliasTRB)->DA1_XPRIMP,;
										(cAliasTRB)->DA1_XRJIMP,;
										(cAliasTRB)->DA1_XRNIMP,;
										(cAliasTRB)->DA1_XROIMP,;
										(cAliasTRB)->DA1_XRRIMP,;
										(cAliasTRB)->DA1_XRSIMP,;
										(cAliasTRB)->DA1_XSCIMP,;
										(cAliasTRB)->DA1_XSEIMP,;
										(cAliasTRB)->DA1_XSPIMP,;
										(cAliasTRB)->DA1_XTOIMP			})
				
					(cAliasTRB)->(DbSkip()) 
				EndDo
			
				//Ativando o arquivo e gerando o xml
				oFWMsExcel:Activate()
				oFWMsExcel:GetXMLFile(cArquivo)
				
				//Abrindo o excel e abrindo o arquivo xml
				oExcel := MsExcel():New() 			    //Abre uma nova conexão com Excel
				oExcel:WorkBooks:Open(cArquivo) 	    //Abre uma planilha
				oExcel:SetVisible(.T.) 				    //Visualiza a planilha
				oExcel:Destroy()						//Encerra o processo do gerenciador de tarefas
			
				(cAliasTRB)->(DbCloseArea())
				
			EndIf
		EndIf
	EndIf

RestArea(aArea)

Return()
