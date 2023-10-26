#Include "Protheus.Ch"
#Include "TopConn.Ch"

#DEFINE CRLF chr(10)+chr(13)

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZGENF008
Rdmake 	Bloqueia a digita��o de quantidade quebrada
@class    	Nao Informado
@from       Nao Informado
@param      nRegra = Define a regra utilizada para arredondamento, lMsg = .T. demostra mensagem .F. n�o demostra mensagem.
@attrib    	Nao Informado
@protected  Nao Informado
@author     Nicolas Lima
@single		23/10/2023
@version    Nao Informado
@since      Nao Informado  
@return    	lRet
@sample     Nao Informado
@obs        Deve ser colocado no X3_VLDUSR  do campo que deseja arredondar um valor.
@project    CAOA - Bloquear quantidade quebrada na entrada de NF - GAP009
@menu       Nao Informado
@history    
---------------------------------------------------------------------------------------*/

//Se a fun��o for executada via Execauto lMsg deve receber .F.
//Se a fun��o for execuitada via inclus�o manual lMsg deve receber .T.

//Fun��o principal 01 para o X3_VLDUSR do campo desejado.
User Function ZGENF008( lMsg, nRegra, nDgtVlr) //Colocar a fun��o principal no X3_VLDUSR do campo desejado.

    Local aArea 	    as Array
    Local cCpo          as Character

    Private lRet        as Logical
    Private nQtd        as Numeric

    Default lMsg        := .F.
    Default nRegra      := 3 //Deve ser in�cio 0
    Default nDgtVlr     := Nil

    aArea       := GetArea()
    cCpo        := ReadVar()
    lRet        := .F.
    nQtd   := &(cCpo) //Recebe conte�do digitado no campo.
    
        Begin Sequence

            lRet := zArredVlr(nQtd, nRegra, nDgtVlr, lMsg, cCpo)

        End Sequence

    RestArea(aArea)
Return lRet

User Function ZGENF08A(nQtd, lMsg, nRegra, nDgtVlr)//Fun��o principal 02 para o ser chamado de outro fonte
    Local aArea 	    as Array
    Local cCpo          as Character

    Private lRet        as Logical
    //Private nQtd        as Numeric

    Default lMsg        := .F.
    Default nRegra      := 3 //Deve ser in�cio 0
    Default nDgtVlr     := Nil

    aArea       := GetArea()
    cCpo        := ReadVar() //O que acontece com esse cara aqui?
    lRet        := .F.
    //nQtd   := &(cCpo) //Recebe conte�do digitado no campo.
    
        Begin Sequence

            lRet := zArredVlr(nQtd, nRegra, nDgtVlr, lMsg, cCpo)

        End Sequence

    RestArea(aArea)

Return lRet

//Verificar regras, verificar valor e faz o arredondamento.
Static Function zArredVlr(nQtd, nRegra, nDgtVlr, lMsg, cCpo)

    Local nQtdAtg As Numeric
    nQtdAtg := nQtd

    If (nQtd <> Round(nQtd, nDgtVlr)) .or. (nQtd > 0)
        
        Do Case //Criar novas op��es de acordo com as regras de arredondamento.
            Case nRegra == 1 .and. (nDgtVlr == Nil .or. nDgtVlr == 0)
                nQtd	:= Ceiling(nQtd) //Arredonda para cima for�ando, sem casas decimais.
            Case nRegra == 2 
                nQtd   := NoRound(nQtd, nDgtVlr) //Joga os valores fora e mant�m ap�s a v�rgula a qtd de caracter informado.
            Case nRegra == 3 
                nQtd   := Round(nQtd, nDgtVlr)//Arredonda matematicamente mantendo ap�s a v�rgula o valor desejado.
            Otherwise //Zera o valor.
                nQtd   := 0
        EndCase
        
        If lMsg //Deve mostrar mensagem na tela.
	        MsgInfo("N�o � permitido informar quantidade quebrada." + CRLF + "O valor: " + Alltrim(Str(nQtdAtg)) + " foi alterado para: " + Alltrim(Str(nQtd)) + " .", "Quantidade quebrada - ZGENF008 ")
        EndIf

        lRet := RetornaCarac(cCpo, nQtd)
    Else //Valor de nQtd == 0
        lRet := .T.
	EndIf

Return lRet


//Verifica o tipo de rotina MVC ou ADPL e devolve a informa��o no campo posicionado.
Static Function RetornaCarac(cCpo, nQtd)
       Local nPosQtde  As Numeric
       Local lRet      As Logic 
       Local cCpoLmp   As Character

       lRet     := .F.
       cCpoLmp  := Substr(cCpo, (At(">",cCpo)+1))

       
       //Verificar se a rotina � MVC (.T.) ou ADVPL padr�o (.F.)
        lMVC := (FWModelActive() != Nil)

        If lMVC //.T. == MVC
            lRet   := FWFldPut(cCpoLmp, nQtd, , , , .T.)
        Else  //.F. == ADVPL padr�o
            nPosQtde  := GDFieldPos(cCpoLmp) 
            If (Type("aCols") == "A")
                aCols[n][nPosQtde] := nQtd
                lRet := .T.
            Else
                &(cCpo) := nQtd
                lRet := .T.
            EndIF
        EndIf

Return lRet

