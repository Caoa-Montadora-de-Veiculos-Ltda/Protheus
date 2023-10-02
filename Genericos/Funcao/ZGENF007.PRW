#Include 'Protheus.ch'
#Include 'TOTVS.ch'
#Include 'TopConn.ch'
#Include 'FWEditPanel.ch'
#INCLUDE 'RWMAKE.CH'

/*
=====================================================================================
Programa.:              ZGENF00X
Autor....:              CAOA - Nicolas C Lima Santos
Data.....:              22/09/23
Descricao / Objetivo:   Bloquear o uso de caracter especial e alterar para outros caracteres
Doc. Origem:
Solicitante:            Valmir Firmino
Uso......:              Geral
Obs......:              lMVC := .T. //Função do campo em MVC
Obs......:              lMVC := .F. //Função do campo em ADVPL padrão
Obs......:              Permite apenas: letra Maiúscula, sem espaço a esquerda, sem acento.
=====================================================================================
*/

User Function ZGENF007(nRegra) //Colocar a função principal no X3_VLDUSR do campo desejado.
    Local aArea         := GetArea()
    Local cCampo        := ReadVar()
    Local cConteudo     := &(cCampo)
    Local cConteudoRet  := ""
    Private _lRet         := .F.    

    Begin Sequence
        If !vazio(cConteudo)  //vazio(var) == .T. Se estiver vazio
            
            cConteudoRet := SubstCarac(cConteudo, nRegra, cCampo)
            
            RetornaCarac(cCampo, cConteudoRet)
        EndIf
    End Sequence
    
    RestArea(aArea)
Return _lRet


Static Function SubstCarac(cConteudo, nRegra, cCampo)

    Local cCarEsp	:= "" //"!@#$%¨&*()-_+=§{}^~´`][:;.>,</°¢¬ªº'?\|¹²³£¬ƒ†©"+'"' - Todos os caracteres.
	Local nI		:= 0
    Local cCampoTam := Substr(cCampo, (At(">",cCampo)+1))
    Local cTam      := TamSX3(cCampoTam)[1]

    Do Case //Criar novas opções de acordo com as regras
        Case nRegra == 1
            cCarEsp	:= "!@#$%¨&*()_+=§{}^~´`][:;.>,</°¢¬ªº'?\|¹²³£¬ƒ†©"+'"' //Permitido: '0~9' + 'A~Z' + '-' GAP010
        Case nRegra == 2
            cCarEsp	:= "!@#$%¨&*-_+=§{}^~´`][:;></°¢¬ªº'?\|¹²³£¬ƒ†©"+'"' //Permitido: '0~9' + 'A~Z' + '.,()' GAP010
    EndCase

	For nI := 1 To Len(cCarEsp)
		cConteudo := StrTran(cConteudo, SubStr(cCarEsp, nI, 1), "")
	Next nI
    cConteudoRet := PadR(Upper(FWNoAccent(Alltrim(cConteudo))),cTam," ")   

Return cConteudoRet
    
Static Function RetornaCarac(cCampo, cConteudoRet)
       //Verificar se a rotina é MVC (.T.) ou ADVPL padrão (.F.)
        lMVC := (FWModelActive() != Nil)

        If lMVC //.T. == MVC
            cCampo := Substr(cCampo, (At(">",cCampo)+1))
            _lRet := FWFldPut(cCampo, cConteudoRet, , , , .T.)
        Else    //.F. == ADVPL padrão
            &(cCampo+" := '"+cConteudoRet+"' ")
            _lRet := .T.
        EndIf

Return
