/*
=====================================================================================
Programa.:              ImpCsvGen
Autor....:              CAOA - Sandro Ferreira
Data.....:              04/09/2023
Descricao / Objetivo:   Seleciona arquivo CSV para importação.
=====================================================================================
*/
User Function ZWMSF019()

	Local cTitulo1  := "Selecione o arquivo para Carga "
	Local cExtens   := "Arquivo CSV | *.CSV"
	Local cMainPath := "C:\"
	Local cFileOpen := ""

   	cFileOpen := cGetFile(cExtens,cTitulo1,,cMainPath,.T.)
	If File(cFileOpen)
		Processa({|| zImpCSV(cFileOpen) }, "[ZWMSF019] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." )
	Endif

Return()

/*
=====================================================================================
Programa.:              zImpCSV
Autor....:              CAOA - Sandro Ferreira
Data.....:              04/09/2023
Descricao / Objetivo:   Processamento do arquivo CSV   
=====================================================================================
*/
Static Function zImpCSV(cFileOpen)

	Local cLinha        := ""
	Local cSeparador	:= ";"
	Local aDados 		:= {}
	Local nCont         := 0
	Local cDoc			:= ""
	Local cProc         := .T.

    //Valida Armazem e Local Destino
		FT_FUSE(cFileOpen)
	FT_FGOTOP()
	//FT_FSKIP()

	ProcRegua( FT_FLASTREC() )

	While !FT_FEOF()

		nCont++

		cLinha := FT_FREADLN()

		aDados := Separa(cLinha,cSeparador)

		// Incrementa a mensagem na régua.
		IncProc("Efetuando a validação da Planilha!")

		DbSelectArea("SBE")
		DbSetOrder(1)
		DBSEEK( FWxFilial("SZJ") + AllTrim(aDados[4]) + AllTrim(aDados[6]) )
		IF EOF("SBE") .and. nCont > 1
		   MSGINFO( "Armaz.: " + AllTrim(aDados[4]) + " ou Local: " + AllTrim(aDados[6]) + " de Destino Invalido! Processamento cancelado !" )
		   cProc := .F.
		   Exit
		Endif

		FT_FSKIP(1)

	END

	//--Fecha arquivo
	FT_FUSE()
    
    //Carga na tabela SZJ
    If cProc
		//Carga da Tabela
		nCont := 0
		FT_FUSE(cFileOpen)
		FT_FGOTOP()
		//FT_FSKIP()

		ProcRegua( FT_FLASTREC() )

		While !FT_FEOF()

			nCont++

			cLinha := FT_FREADLN()

			aDados := Separa(cLinha,cSeparador)

			// Incrementa a mensagem na régua.
			IncProc("Efetuando a importação dos registros!")

			DbSelectArea("SZJ")
			DbSetOrder(1)
			cDoc := Space(tamsx3("ZJ_DOCTO")[1])
            
			if nCont > 1
				RecLock("SZJ", .T.) 
					SZJ->ZJ_FILIAL	:= FWxFilial("SZJ")
					SZJ->ZJ_DOCTO	:= cDoc
					SZJ->ZJ_TIPO    := "T"
					SZJ->ZJ_TIPOUNI := ""
					SZJ->ZJ_STATUS  := ""
					SZJ->ZJ_PRODUTO	:= Space(TamSx3("B1_COD")[1])
					SZJ->ZJ_QTDE	:= 0

					SZJ->ZJ_LOCORI	:= AllTrim(aDados[1])
					SZJ->ZJ_ENDORI	:= AllTrim(aDados[2])
					SZJ->ZJ_IDUNIT	:= AllTrim(aDados[3])

					SZJ->ZJ_LOCDEST	:= AllTrim(aDados[4])
					SZJ->ZJ_ENDDEST := AllTrim(aDados[6])
					SZJ->ZJ_IDUDEST	:= AllTrim(aDados[5])
					SZJ->ZJ_HRLEITU := Time()
					SZJ->ZJ_USR     := RetCodUsr()
					SZJ->ZJ_DATA    := Date()

				SZJ->(Msunlock())
			Endif

			FT_FSKIP(1)

		END

		//--Fecha arquivo
		FT_FUSE()
		
		If cProc
           MSGINFO( "Planilha importada com sucesso! total de Registros Importados: " + cvaltochar(nCont) )
		Endif
    Endif
Return
