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
Obs......:
=====================================================================================
*/
/*

User Function ZGENF00X()

    Local cCampo    := M->B1_DESC
    Local cCarEsp	:= "!@#$%¨&()+{}^~´`][;.>,<=/¢¬§ªº'?|"+'"'
    //local nPos := StrScan(cCampo, "!@#$%¨&()+{}^~´`][;.>,<=/¢¬§ªº'?|") // Verifica se a string cTexto contém os caracteres "!@#"


        // Se nPos for maior que zero, significa que os caracteres foram encontrados
    //if nPos > 0
        Conout("Não é permitido caracter especial: " + CRLF ;
             + cCarEsp)
             
         M->B1_DESC := zCadProd(cCampo)

    //else
      //lRet := .F.
      //  Conout("A string não contém os caracteres !@#")
    //endif


Return cCampo


Static Function zCadProd(cConteudo)
	Local cCarEsp	:= "!@#$%¨&()+{}^~´`][;.>,<=/¢¬§ªº'?|"+'"'
	Local nI		:= 0
    //Local cConteudo := ""

	For nI := 1 To Len(cCarEsp)
		
        cConteudo := StrTran(cConteudo, SubStr(cCarEsp, nI, 1), "")

	Next nI

Return cConteudo
*/








/*
local cTexto := B1_DESC  // Supondo que B1_DESC seja a sua variável

// Se nPos for maior que zero, significa que os caracteres foram encontrados
if nPos > 0
    // Faça algo se os caracteres forem encontrados
    // Por exemplo, exiba uma mensagem ou execute ações específicas
    Conout("A string contém os caracteres !@#")
else
    // Faça algo se os caracteres não forem encontrados
    // Por exemplo, exiba outra mensagem ou execute ações alternativas
    Conout("A string não contém os caracteres !@#")
endif

Static Function zRetCarUni(cConteudo)
	Local cCarEsp	:= "!@#$%¨&()+{}^~´`][;.>,<=/¢¬§ªº'?|"+'"'
	Local nI		:= 0

	For nI := 1 To Len(cCarEsp)
		cConteudo := StrTran(cConteudo, SubStr(cCarEsp, nI, 1), "")
	Next nI

Return cConteudo
*/




 
/*/{Protheus.doc} zLimpaEsp
Função que limpa os caracteres especiais dentro de um campo
@type function
@author Atilio / Achoa
@since 25/04/2016
@version 1.0
@param lEndereco, Lógico, Define se o campo é endereço (caso sim, o traço e vírgula serão ignorados)
    @example
    u_zLimpaEsp()
/*/
 
User Function ZGENF00X()
//zLimpaEsp(lEndereco)
    Local aArea       := GetArea()
    Local cCampo      := ReadVar()
    Local cConteudo   := &(cCampo)
    Local nTamOrig    := Len(cConteudo)
   // Local _lRet         := .F.
   // Default lEndereco := .F.
     
   //Local oStackInfo := GetStackInfo(1) // Obtém informações do quinto nível da pilha
   //Local cStackMt := ("Procedimento no quinto nível: " + oStackInfo:Method)
   //Local cStackSourc := ("Arquivo fonte no quinto nível: " + oStackInfo:Source)
   //Local cStackLine := ("Linha no quinto nível: " + oStackInfo:Line)



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
     
    //Se não for endereço, retira também o - e a ,
    //If !lEndereco
        cConteudo := StrTran(cConteudo, ",", "")
        cConteudo := StrTran(cConteudo, "-", "")
   // EndIf
     
    //Adicionando os espaços a direita
    cConteudo := Alltrim(cConteudo)
    cConteudo += Space(nTamOrig - Len(cConteudo))
     
    //Definindo o conteúdo do campo
    &(cCampo+" := '"+cConteudo+"' ")
    //cCampo := "B1_DESC"
    //cCampo := cConteudo
    //M->B1_DESC := cConteudo
    //M->B9_XLOG := cConteudo

    //_lRet := FWFldPut(cCampo, cConteudo, , , , .T.)
    RestArea(aArea)
Return 
 
