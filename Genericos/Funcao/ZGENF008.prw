#Include "Protheus.Ch"
#Include "TopConn.Ch"

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

//Fun��o principal.
User Function ZGENF008( lMsg, nRegra, nDgtVlr) //Colocar a fun��o principal no X3_VLDUSR do campo desejado.

    Local aArea 	    as Array
    Local cCpo          as Character
    
    //Local nValor   := aCols[n][nPosQtde]
    //Local nQtd     := &(cCpo)

    Private lRet        as Logical
    Private nQtd        as Numeric
    //M->C1_QUANT := 1.0
    //&(cCpo+" := '"+AllTrim(STR(nQtd))+"' ")

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


//Verificar regras, verificar valor e faz o arredondamento.
Static Function zArredVlr(nQtd, nRegra, nDgtVlr, lMsg, cCpo)

    //If (M->(//&_cCpo)) <> Nil .Or. (M->(&_cCpo)) > 0
            //nQtd := M->(&_cCpo)
            //_lTabela := .F.
        //ElseIf &(_cTabela+"->"+_cCpo) <> Nil .Or. &(_cTabela+"->"+_cCpo) > 0
        //    nQtd := ((&_cTabela)->(&_cCpo))
        //    _lTabela := .T.
        //Else
            //nQtd := 0
    //EndIf

    If (nQtd <> Round(nQtd, nDgtVlr)) .or. (nQtd > 0)
        
        Do Case //Criar novas op��es de acordo com as regras de arredondamento. -- REVER ESSE TRECHO TODO
            Case nRegra == 1 .and. (nDgtVlr == Nil .or. nDgtVlr == 0) //Arredonda sempre para cima e considera n�mero inteiro
                nQtd	:= Ceiling(nQtd) //
            Case nRegra == 2 //Arredonda sempre para baixo
                nQtd   := NoRound(nQtd, DgtVlr) //AJUSTAR ISSO - AVALIAR TRUNCATE, A FUN��O NO ROUND N�O SERVE PARA ISSO.
            Case nRegra == 3 //Segue Regra matem�tica
                nQtd   := Round(nQtd, nDgtVlr)
            Otherwise //Caso n�o atenda aos requesitos de cma.
                nQtd   := 0
        EndCase
        
        If lMsg //Deve mostrar mensagem na tela.
	        MsgInfo("N�o � permitido informar quantidade quebrada, verifique as casas decimais para esse item.", "[ Quantidade Quebrada - A L E R T A ]")
        EndIf

        lRet := RetornaCarac(cCpo, nQtd)
    Else //Valor de nQtd == 0
        lRet := .T.
	EndIf

    //Pegar posi��o do c�digo produto
    //Posso usar a var publica NREG ?




Return lRet


//Verifica o tipo de rotina MVC ou ADPL e devolve a informa��o no campo posicionado.
Static Function RetornaCarac(cCpo, nQtd)
       Local nPosQtde  As Numeric
       Local lRet      As Logic 
       Local cCpoLmp   As Character

       lRet := .F.
       cCpoLmp   := Substr(cCpo, (At(">",cCpo)+1))
       //Local oModel := FwModelActive()
       //Local cConteudoRet 
       
       //Verificar se a rotina � MVC (.T.) ou ADVPL padr�o (.F.)
        lMVC := (FWModelActive() != Nil)

        If lMVC //.T. == MVC
            //cCpo  := Substr(cCpo, (At(">",cCpo)+1))
            lRet   := FWFldPut(cCpoLmp, nQtd, , , , .T.)
        Else  //.F. == ADVPL padr�o
            nPosQtde  := GDFieldPos(cCpoLmp) //Da pra colcoar aqui qualquer campo?!
            If (Type("aCols") == "A")
               
                //&(cCpo+" := '"+Alltrim(Str(nQtd))+"' ")
                //&(cCpo+" := '"+AllTrim(STR(nQtd))+"' ")
                //If aCols > 0
                aCols[n][nPosQtde] := nQtd
                lRet := .T.
            Else
                &(cCpo) := nQtd
                //FieldPut( FieldPos("C1_QUANT"), 10 )
                lRet := .T.
            EndIF
        EndIf

Return lRet

