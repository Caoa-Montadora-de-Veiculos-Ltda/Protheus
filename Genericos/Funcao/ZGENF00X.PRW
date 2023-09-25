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


User Function ZGENF00X()

    Local cCampo    := M->B1_DESC
    Local cCarEsp	:= "!@#$%¨&()+{}^~´`][;.>,<=/¢¬§ªº'?|"+'"'
    //local nPos := StrScan(cCampo, "!@#$%¨&()+{}^~´`][;.>,<=/¢¬§ªº'?|") // Verifica se a string cTexto contém os caracteres "!@#"


        // Se nPos for maior que zero, significa que os caracteres foram encontrados
    //if nPos > 0
        Conout("Não é permitido caracter espenicolcial: " + CRLF ;
             + cCarEsp)
             
         M->B1_DESC := zCadProd(cCampo)
    //else
      //  Conout("A string não contém os caracteres !@#")
    //endif


Return


Static Function zCadProd(cConteudo)
	Local cCarEsp	:= "!@#$%¨&()+{}^~´`][;.>,<=/¢¬§ªº'?|"+'"'
	Local nI		:= 0
    Local cConteudo := ""

	For nI := 1 To Len(cCarEsp)
		
        cConteudo := StrTran(cConteudo, SubStr(cCarEsp, nI, 1), "")

	Next nI

Return cConteudo









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
