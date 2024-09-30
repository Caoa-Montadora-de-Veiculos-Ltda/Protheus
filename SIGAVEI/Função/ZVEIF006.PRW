#INCLUDE "PROTHEUS.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
/*/
{Protheus.doc} ZVEIF006
@param
@author Antonio Oliveira
@version P12.1.23
@since 25/04/2023
@return NIL
@obs e chamdo pelo PE MA140BUT_PE cria opções: Importa Itens
@project
@history Importar itens de pre-nota da planilha excel (CSV)
/*/
User Function ZVEIF006()
	Local cTitulo1  := "Selecione o arquivo para Carga "
	Local cExtens   := "Arquivo CSV | *.CSV"
	Local cMainPath := "C:\"
	Local cArqLog   := ""
	Public _cFile990:= ""

	////U_ZGENUSER( <ID User> , <"NOME DA FUNÇÃO"> , <.F.=Não Exibe Msg; .T.=Exibe Msg> )
	//IF U_ZGENUSER( RetCodUsr() ,"ZVEIF006" ,.T.) = .F.
	//	RETURN Nil
	//ENDIF

	_cFile990 := cGetFile(cExtens,cTitulo1,,cMainPath,.T.)

	If !File(_cFile990)
		MsgAlert("Arquivo CSV: " + _cFile990 + " não localizado","[ZVEIF006] - Atenção")
	Else

		Processa({|| ZCOMF99B(_cFile990,@cArqLog)}, "[ZVEIF006] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." )

	Endif

Return Nil


/*/
	{Protheus.doc} ZVEIF006
	@param
	@author Antonio Oliveira ZCOMF99B
	@version P12.1.23
	@since 25/04/2023
	@return NIL
	@obs e chamdo pelo PE MA140BUT_PE cria opções: Importa Itens
	@project
	@history Importar itens da planilha excel (CSV)
/*/
Static Function ZCOMF99B(_cFile990,cArqLog)
	Local cSeparador     := ";" // Separador do arquivo
	Local aDados         := {} // Array dos dados da linha do laco
	Local n              := 0
	//Local _cAliasQry     := GetNextAlias()

	Local nPosPesq       := 1 //Posição a pesquisar no Array
	//Local aItens         := {}

	Private _cFil  	     := FWCodFil()
	Private aItsoma      := {}
	Private aArea        := GetArea()
	Private nQtdent      := 0
	Private nCont        := 0
	Private lErroGer

	Public aDadosLi      := {}
	Public _nCtItem      := 0
	Public _nLinAc       := 0

	ProcRegua(311)    //311
	IncProc()
	FT_FUSE(_cFile990)
	FT_FGOTOP()
	//FT_FSKIP()

	While !FT_FEOF()
		cLinha	:= FT_FREADLN()

		aDados	:= Separa(Alltrim(cLinha),cSeparador)

		nCont++

        IF nCont > 1
		    aadd(aDadosLi, aClone(aDados))
        ENDIF

		FT_FSKIP(1)
		IncProc()
	EndDo


	//FT_FUSE()

	//lErroGer := CompacItem(aDadosli,nPosPesq)  //Somar itens idênticos + divisão 200

	//IF !lErroGer

		For n := 1 to Len(aDadosli)

    		IncProc("Analisando linha " + cValToChar(n-1) + " de " + cValToChar(nCont-1) + "...")

			IF  Empty(aDadosLi[nPosPesq])
				LOOP
			ENDIF


		Next n



	//ENDIF

	RestArea(aArea)

Return(aDadosLi)
