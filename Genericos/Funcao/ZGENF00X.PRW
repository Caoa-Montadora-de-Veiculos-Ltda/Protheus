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

User Function ZGENF00X(nRegra) //Colocar a função principal no X3_VLDUSR do campo desejado.
    Local lMVC
    Local aArea         := GetArea()
    Local cCampo        := ReadVar()
   
    Private _Ret        := .F.
    Private nRegra       
    Private cConteudo   := &(cCampo)
    Private cConteudoRet:= ""

    Begin Sequence
        If !vazio(cConteudo)  //vazio(var) == .T. Se estiver vazio
            
            cConteudoRet := SubstCarac(cConteudo, nRegra)
            
            _Ret := RetornaCarac(cCampo, cConteudoRet)
    
        EndIf
    End Sequence
    
    RestArea(aArea)
Return _Ret


Static Function SubstCarac(cConteudo, nRegra)

    Local cCarEsp	:= "" //"!@#$%¨&*()-_+=§{}^~´`][:;.>,</°¢¬ªº'?\|¹²³£¬ƒ†©"+'"' - Todos os caracteres.
	Local nI		:= 0

    Do Case //Criar novas opções de acordo com as regras
        Case nRegra == 1
            cCarEsp	:= "!@#$%¨&*()_+=§{}^~´`][:;.>,</°¢¬ªº'?\|¹²³£¬ƒ†©"+'"' //Permitido: '0~9' + 'A~Z' + '-' GAP010
        Case nRegra == 2
            cCarEsp	:= "!@#$%¨&*-_+=§{}^~´`][:;></°¢¬ªº'?\|¹²³£¬ƒ†©"+'"' //Permitido: '0~9' + 'A~Z' + '.,()' GAP010
    EndCase

	For nI := 1 To Len(cCarEsp)
		cConteudo := StrTran(cConteudo, SubStr(cCarEsp, nI, 1), "")
	Next nI
    cConteudoRet := Upper(FWNoAccent(AllTrim(cConteudo)))   

Return cConteudoRet
    
Static Function RetornaCarac(cCampo, cConteudoRet)
       //Verificar se a rotina é MVC (.T.) ou ADVPL padrão (.F.)
        lMVC := (FWModelActive() != Nil)

        If lMVC //.T. == MVC
            cCampo := Substr(cCampo, (At(">",cCampo)+1))
            _Ret := FWFldPut(cCampo, cConteudoRet, , , , .T.)
        Else    //.F. == ADVPL padrão
            &(cCampo+" := '"+cConteudoRet+"' ")
            _Ret = "string" //Para função ADVPL o retorno não pode ser lógico.
        EndIf

Return _Ret



















 /*   
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
 */
