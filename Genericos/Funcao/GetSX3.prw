#INCLUDE "protheus.ch"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// UTILIZAÇÃO DO DICIONÁRIO DE DADOS SX3
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function GetSx3(cTabela)
	Local aSX3    := {}           	// DADOS DA SX3 COM BASE NO VETOR AFIELDS
	Local aFields :=  GetColumns() 	// CAMPOS DA SX3 PARA ESTRUTURA

	// EFETUA A ABERTURA E GERAÇÃO DO ARQUIVO DE TRABALHO
	If (OpenDic(cTabela))
		// PERCORRE A TABELA FILTRADA E MONTA ESTRUTURA
		DbEval({|| AAdd(aSX3, GenStruct(aFields))})

		// FECHA O ARQUIVO DE TRABALHO
		DbCloseArea()
	EndIf

Return ({aFields, aSX3})

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CAMPOS QUE DESEJO UTILIZAR NA MINHA ESTRUTURA
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function GetColumns()
	Local aFields := {} // VETOR DE CAMPOS

	// ADIÇÃO DOS CAMPOS DESEJADOS
	AAdd(aFields, "X3_ARQUIVO")
	AAdd(aFields, "X3_ORDEM")
	AAdd(aFields, "X3_CAMPO")
	AAdd(aFields, "X3_TIPO")
	AAdd(aFields, "X3_TAMANHO")
	AAdd(aFields, "X3_DECIMAL")
	AAdd(aFields, "X3_TITULO")
	AAdd(aFields, "X3_DESCRIC")
	AAdd(aFields, "X3_PICTURE")
	AAdd(aFields, "X3_VALID")
	AAdd(aFields, "X3_USADO")
	AAdd(aFields, "X3_RELACAO")
	AAdd(aFields, "X3_F3")
	AAdd(aFields, "X3_NIVEL")
	AAdd(aFields, "X3_RESERV")
	AAdd(aFields, "X3_CHECK")
	AAdd(aFields, "X3_TRIGGER")
	AAdd(aFields, "X3_PROPRI")
	AAdd(aFields, "X3_BROWSE")
	AAdd(aFields, "X3_VISUAL")
	AAdd(aFields, "X3_CONTEXT")
	AAdd(aFields, "X3_OBRIGAT")
	AAdd(aFields, "X3_VLDUSER")
	AAdd(aFields, "X3_CBOX")
	AAdd(aFields, "X3_PICTVAR")
	AAdd(aFields, "X3_WHEN")
	AAdd(aFields, "X3_INIBRW")
	AAdd(aFields, "X3_GRPSXG")
	AAdd(aFields, "X3_FOLDER")
	AAdd(aFields, "X3_PYME")
	AAdd(aFields, "X3_CONDSQL")
	AAdd(aFields, "X3_CHKSQL")
	AAdd(aFields, "X3_IDXSRV")
	AAdd(aFields, "X3_ORTOGRA")
	AAdd(aFields, "X3_IDXFLD")
	AAdd(aFields, "X3_TELA")
	AAdd(aFields, "X3_PICBRV")
	AAdd(aFields, "X3_AGRUP")
	AAdd(aFields, "X3_POSLGT")
	AAdd(aFields, "X3_MODAL")
	
Return (aFields)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// EFETUA A ABERTURA E GERAÇÃO DO ARQUIVO TEMPORÁRIO
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function OpenDic(cTabela)
	Local lOpen   	:= .F.				// VALIDAÇÃO DE ABERTURA DE TABELA
	Local cAlias  	:= GetNextAlias()	// APELIDO DO ARQUIVO DE TRABALHO
	Local _cFilter	:= "" 				// FILTRO PARA A TABELA SX3

	Default	cTabela := "SA1"

	_cFilter :=  cAlias + "->" + "X3_ARQUIVO" + " == " + "'"+cTabela+"'"

	// ABERTURA DO DICIONÁRIO SX3
	//OpenSXs( NIL, NIL, NIL, NIL, "99", cAlias, "SX3", NIL, .F.) // EMPRESA É OBRIGATÓRIO SE FOR UM JOB
	OpenSXs( NIL, NIL, NIL, NIL, NIL, cAlias, "SX3", NIL, .F.) // EMPRESA NÃO É OBRIGATÓRIO SE TIVER INTERFACE/USUÁRIO
	lOpen := Select(cAlias) > 0

	// CASO ABERTO FILTRA O ARQUIVO PELO X3_ARQUIVO "SA1",
	// DEFINE COMO TABELA CORRENTE E POSICIONA NO TOPO
	If (lOpen)
		DbSelectArea(cAlias)
		DbSetFilter({|| &(_cFilter)}, _cFilter)
		DbGoTop()
	EndIf

Return (lOpen)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// RETORNA A ESTRUTURA DE UM CAMPO COM BASE NA SX3
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function GenStruct(aFields)
	Local aAux := {} // VETOR AUXILIAR PARA MONTAGEM DA ASX3

	// LAÇO DE REPETIÇÃO NOS CAMPOS DA SX3 PARA MONTAR A ESTRUTURA DE SA1
	AEval(aFields, {|cField| AAdd(aAux, &(cField))})
Return (aAux)