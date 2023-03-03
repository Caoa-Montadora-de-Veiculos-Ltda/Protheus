#INCLUDE "protheus.ch"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// UTILIZAÇÃO DO DICIONÁRIO DE DADOS SX2
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function GetSX2(cTabela)
	Local aSX2    := {}           	// DADOS DA SX2 COM BASE NO VETOR AFIELDS
	Local aFields :=  GetColumns() 	// CAMPOS DA SX2 PARA ESTRUTURA

	// EFETUA A ABERTURA E GERAÇÃO DO ARQUIVO DE TRABALHO
	If (OpenDic(cTabela))
		// PERCORRE A TABELA FILTRADA E MONTA ESTRUTURA
		DbEval({|| AAdd(aSX2, GenStruct(aFields))})

		// FECHA O ARQUIVO DE TRABALHO
		DbCloseArea()
	EndIf

Return ({aFields, aSX2})

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CAMPOS QUE DESEJO UTILIZAR NA MINHA ESTRUTURA
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function GetColumns()
	Local aFields := {} // VETOR DE CAMPOS

	// ADIÇÃO DOS CAMPOS DESEJADOS
	AAdd(aFields, "X2_CHAVE")
	AAdd(aFields, "X2_PATH")
	AAdd(aFields, "X2_ARQUIVO")
	AAdd(aFields, "X2_NOME")
	AAdd(aFields, "X2_NOMESPA")
	AAdd(aFields, "X2_NOMEENG")
	AAdd(aFields, "X2_ROTINA")
	AAdd(aFields, "X2_MODO")
	AAdd(aFields, "X2_MODOUN")
	AAdd(aFields, "X2_MODOEMP")
	AAdd(aFields, "X2_DELET")
	AAdd(aFields, "X2_TTS")
	AAdd(aFields, "X2_UNICO")
	AAdd(aFields, "X2_PYME")
	AAdd(aFields, "X2_MODULO")
	AAdd(aFields, "X2_DISPLAY")
	AAdd(aFields, "X2_SYSOBJ")
	AAdd(aFields, "X2_USROBJ")
	AAdd(aFields, "X2_POSLGT")
	AAdd(aFields, "X2_CLOB")
	AAdd(aFields, "X2_AUTREC")
	AAdd(aFields, "X2_TAMFIL")
	AAdd(aFields, "X2_TAMUN")
	AAdd(aFields, "X2_TAMEMP")
		
Return (aFields)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// EFETUA A ABERTURA E GERAÇÃO DO ARQUIVO TEMPORÁRIO
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function OpenDic(cTabela)
	Local lOpen   	:= .F.				// VALIDAÇÃO DE ABERTURA DE TABELA
	Local cAlias  	:= GetNextAlias()	// APELIDO DO ARQUIVO DE TRABALHO
	Local _cFilter	:= "" 				// FILTRO PARA A TABELA SX2

	Default	cTabela := "SA1"

	_cFilter :=  cAlias + "->" + "X2_CHAVE" + " == " + "'"+cTabela+"'"

	// ABERTURA DO DICIONÁRIO SX2
	//OpenSXs( NIL, NIL, NIL, NIL, "99", cAlias, "SX2", NIL, .F.) // EMPRESA É OBRIGATÓRIO SE FOR UM JOB
	OpenSXs( NIL, NIL, NIL, NIL, NIL, cAlias, "SX2", NIL, .F.) // EMPRESA NÃO É OBRIGATÓRIO SE TIVER INTERFACE/USUÁRIO
	lOpen := Select(cAlias) > 0

	// CASO ABERTO FILTRA O ARQUIVO PELO X2_CHAVE "SA1",
	// DEFINE COMO TABELA CORRENTE E POSICIONA NO TOPO
	If (lOpen)
		DbSelectArea(cAlias)
		DbSetFilter({|| &(_cFilter)}, _cFilter)
		DbGoTop()
	EndIf

Return (lOpen)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// RETORNA A ESTRUTURA DE UM CAMPO COM BASE NA SX2
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function GenStruct(aFields)
	Local aAux := {} // VETOR AUXILIAR PARA MONTAGEM DA ASX2

	// LAÇO DE REPETIÇÃO NOS CAMPOS DA SX2 PARA MONTAR A ESTRUTURA DE SA1
	AEval(aFields, {|cField| AAdd(aAux, &(cField))})
Return (aAux)