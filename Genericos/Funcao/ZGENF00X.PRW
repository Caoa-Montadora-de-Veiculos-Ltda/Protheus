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
=====================================================================================
*/

User Function FunPrinc(nRegra, lMVC) //Colocar a função principal no X3_VLDUSR do campo desejado.
    //Local nRegra        := 0
    Local lMVC
    Local aArea         := GetArea()
    Local cCampo        := ReadVar()
    Local _lRet         := .F.
    
    Private cConteudo   := &(cCampo)
    Private cConteudoRet:= ""

    Begin SEQUENCE
        cConteudoRet := FunSecund(cConteudo)
        //FunTerc(lMVC, cCampo,cConteudoRet)
    End Begin

    If lMVC
        cCampo := Substr(cCampo, 4)
        _lRet := FWFldPut(cCampo, cConteudoRet, , , , .T.)
    Else
        &(cCampo+" := '"+cConteudo+"' ")
        _lRet = "string" //Para função ADVPL o retorno não pode ser lógico.
    EndIf

    RestArea(aArea)
Return _lRet


Static Function FunSecund(cConteudo)

    Local cCarEsp	:= "!@#$%¨&()+{}^~´`][;.>,<=/¢¬§ªº'?|"+'"'
	Local nI		:= 0

	For nI := 1 To Len(cCarEsp)
		cConteudo := StrTran(cConteudo, SubStr(cCarEsp, nI, 1), "")
	Next nI
    cConteudoRet := Upper(AllTrim(cConteudo))
Return cConteudoRet
    






    
Static Function FunTerc(lMVC, cCampo,cConteudoRet)
    Local _lRet := .F.
    //Local cConteudo   := &(cCampo)

    If lMVC

        _lRet := FWFldPut(cCampo, cConteudoRet, , , , .T.)

        Return _lRet
    Else

        &(cCampo+" := '"+cConteudo+"' ")
        Return 
    
    EndIf

    //3 Devolve a info para tela
    //Verifica se a função é MVC ou ADVPL
    //Retorna de acordo com o tipo de função
    //FunTerc(lMVC, cCampoRet)
Return

User Function ZGENF00X()
 //zLimpaEsp(lEndereco)
    Local aArea       := GetArea()
    Local cCampo      := ReadVar()
    Local cConteudo   := &(cCampo)
    Local nTamOrig    := Len(cConteudo)
   // Local _lRet         := .F.
   // Default lEndereco := .F.
     
    //Retirando caracteres
    cConteudo := StrTran(cConteudo, "'", "")
    cConteudo := StrTran(cConteudo, "#", "")
    cConteudo := StrTran(cConteudo, "%", "")
    cConteudo := StrTran(cConteudo, "*", "")
    cConteudo := StrTran(cConteudo, "&", "E")
    cConteudo := StrTran(cConteudo, ">", "")
    cConteudo := StrTran(cConteudo, "<", "")
    cConteudo := StrTran(cConteudo, "!", "")
    cConteudo := StrTran(cConteudo, "@", "")
    cConteudo := StrTran(cConteudo, "$", "")
    cConteudo := StrTran(cConteudo, "(", "")
    cConteudo := StrTran(cConteudo, ")", "")
    cConteudo := StrTran(cConteudo, "_", "")
    cConteudo := StrTran(cConteudo, "=", "")
    cConteudo := StrTran(cConteudo, "+", "")
    cConteudo := StrTran(cConteudo, "{", "")
    cConteudo := StrTran(cConteudo, "}", "")
    cConteudo := StrTran(cConteudo, "[", "")
    cConteudo := StrTran(cConteudo, "]", "")
    cConteudo := StrTran(cConteudo, "/", "")
    cConteudo := StrTran(cConteudo, "?", "")
    cConteudo := StrTran(cConteudo, ".", "")
    cConteudo := StrTran(cConteudo, "\", "")
    cConteudo := StrTran(cConteudo, "|", "")
    cConteudo := StrTran(cConteudo, ":", "")
    cConteudo := StrTran(cConteudo, ";", "")
    cConteudo := StrTran(cConteudo, '"', '')
    cConteudo := StrTran(cConteudo, '°', '')
    cConteudo := StrTran(cConteudo, 'ª', '')    
    cConteudo := StrTran(cConteudo, ",", "")
    cConteudo := StrTran(cConteudo, "-", "")

    //Adicionando os espaços a direita
    cConteudo := Alltrim(cConteudo)
    cConteudo += Space(nTamOrig - Len(cConteudo))
     
    //Definindo o conteúdo do campo
    //&(cCampo+" := '"+cConteudo+"' ")
    //cCampo := "B1_DESC"
    //cCampo := cConteudo
    //M->B1_DESC := cConteudo
    //M->B9_XLOG := cConteudo

    _lRet := FWFldPut(cCampo, cConteudo, , , , .T.)
    RestArea(aArea)
Return .T.
 