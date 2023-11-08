#Include "Protheus.Ch"
#Include "TopConn.Ch"

#DEFINE CRLF chr(10)+chr(13)

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZGENF008
Rdmake 	Bloqueia a digitação de quantidade quebrada
@class    	Nao Informado
@from       Nao Informado
@param      nRegra = Define a regra utilizada para arredondamento, lMsg = .T. demostra mensagem .F. não demostra mensagem.
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

//Se a função for executada via Execauto lMsg deve receber .F.
//Se a função for execuitada via inclusão manual lMsg deve receber .T.

//Função principal 01 para o X3_VLDUSR do campo desejado.
User Function ZGENF008( lMsg, nRegra, nDgtVlr) //Colocar a função principal no X3_VLDUSR do campo desejado.

    Local aArea 	    as Array
    Local cCpo          as Character

    Private lRet        as Logical
    Private nQtde       as Numeric

    Default lMsg        := .F.
    Default nRegra      := 3 //Deve ser início 0
    Default nDgtVlr     := Nil

    aArea       := GetArea()
    cCpo        := ReadVar()
    lRet        := .F.
    nQtde       := &(cCpo) //Recebe conteúdo digitado no campo.
    
        Begin Sequence

            lRet := zArredVlr(nQtde, nRegra, nDgtVlr, lMsg, cCpo)

        End Sequence

    RestArea(aArea)
Return lRet


//Verificar regras, verificar valor e faz o arredondamento.
Static Function zArredVlr(nQtde, nRegra, nDgtVlr, lMsg, cCpo)

    Local nQtdAtg As Numeric
    nQtdAtg := nQtde

    If (nQtde <> NoRound(nQtde, nDgtVlr)) .and. (nQtde > 0)
        
        Do Case //Criar novas opções de acordo com as regras de arredondamento.
            Case nRegra == 1 .and. (nDgtVlr == Nil .or. nDgtVlr == 0)
                nQtde	:= Ceiling(nQtde) //Arredonda para cima forçando, sem casas decimais.
            Case nRegra == 2 
                nQtde   := NoRound(nQtde, nDgtVlr) //Joga os valores fora e mantém após a vírgula a qtd de caracter informado.
            Case nRegra == 3 
                nQtde   := Round(nQtde, nDgtVlr)//Arredonda matematicamente mantendo após a vírgula o valor desejado.
            Otherwise //Zera o valor.
                nQtde   := 0
        EndCase
        
        If lMsg //Deve mostrar mensagem na tela.
	        MsgInfo("Não é permitido informar quantidade quebrada." + CRLF + "O valor: " + Alltrim(Str(nQtdAtg)) + " foi alterado para: " + Alltrim(Str(nQtde)) + " .", "Quantidade quebrada - ZGENF008 ")
        EndIf

        lRet := RetornaCarac(cCpo, nQtde)
    Else //Valor de nQtde == 0
        lRet := .T.
	EndIf

Return lRet



//Verifica o tipo de rotina MVC ou ADVPL e devolve a informação no campo posicionado.
Static Function RetornaCarac(cCpo, nQtde)
       Local nPosQtde  As Numeric
       Local nAcolsLin As Numeric
       Local lRet      As Logic 
       Local cCpoLmp   As Character

        lRet        := .F.
        cCpoLmp     := Substr(cCpo, (At(">",cCpo)+1))
   
       //Verificar se a rotina é MVC (.T.) ou ADVPL padrão (.F.)
        lMVC := (FWModelActive() != Nil)

        If lMVC //.T. == MVC
            lRet   := FWFldPut(cCpoLmp, nQtde, , , , .T.)
        Else    //.F. == ADVPL padrão

            nPosQtde  := GDFieldPos(cCpoLmp) 
            If (Type("aCols") == "A")
                nAcolsLin   := n
                If ExistTrigger(cCpoLmp)    //Executa gatilhos exisentes no campo.
                    RunTrigger( 2,;         //nTipo (1=Enchoice; 2=GetDados; 3=F3)
                            nAcolsLin,;     //Linha atual da Grid quando for tipo 2
                            Nil,;           //Não utilizado
                            ,;              //Objeto quando for tipo 1
                            cCpoLmp	)       //Campo que dispara o gatilho
                EndIf            
                aCols[n][nPosQtde] := nQtde
                &("M->"+cCpoLmp) := nQtde
                lRet := .T.

            Else
                If ExistTrigger(cCpoLmp)    //Executa gatilhos exisentes no campo.
                    RunTrigger( 1,;         //nTipo (1=Enchoice; 2=GetDados; 3=F3)
                                ,;          //Linha atual da Grid quando for tipo 2
                                Nil,;       //Não utilizado
                                ,;          //Objeto quando for tipo 1
                                cCpoLmp	)   //Campo que dispara o gatilho
                EndIF
                &(cCpo) := nQtde
                lRet := .T.
            EndIF
        EndIf
    
Return lRet
