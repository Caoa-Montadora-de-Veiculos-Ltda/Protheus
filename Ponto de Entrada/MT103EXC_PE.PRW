#Include 'Protheus.ch'
#Include 'Rwmake.ch'
#Include 'TopConn.ch'
/*/{Protheus.doc} MT103EXC
//Motivo do cancelamento.
@author A.Carlos
@since 17/10/2023
@version 
@type function
/*/
User Function MT103EXC()
Local _cEmp		:= FWCodEmp()
Local aRet      := {}
Local aParamBox := {}
Local lRet      := .F.
Local cTitulo   := "Motivos do cancelamento da NF de entrada"  //"Exportação NF Cancelada Protheus -> RGlog"

Private aCabecSF1 := {}
Private aItensSD1 := {}
Private aLinhaSD1 := {}
Private cItem     := StrTran(Space(TamSX3('D1_ITEM')[01]), ' ', '0')
Private cChaveSF1 := ""

	If _cEmp == "2020" //Executa o p.e. Franco da Rocha

		aAdd(aParamBox,{2 ,"Mudar:Série, Valor, TES da NF ?      "  ,1,{"Sim","Não"},30,"",.F.})

		If ParamBox(aParamBox,"Parametros para integração ",@aRet)

			If  RecLock("SF1",.F.)
				SF1->F1_XCANC := Substr(cValToChar(MV_PAR01),1,1)    //-- X = Integrado RgLog
				SF1->( MsUnLock() )
            Endif

		EndIf

//Caso usuário selecione a opção 1, será realizada a exclusão do Doc de Entrada, já criando uma cópia dos itens do 
//documento de entrada Substituto, sem o número da NF Série e TES para preenchimento e gravação. Se usuário não 
//confirmar a inclusão da NF Substituta, o Protheus não validará este cancelamento.

        IF MV_PAR01 = 1
		
			aAdd(aCabecSF1, {"F1_TIPO"    , SF1->F1_TIPO    , Nil})
			aAdd(aCabecSF1, {"F1_FORMUL"  , SF1->F1_FORMUL  , Nil})
			//aAdd(aCabecSF1, {"F1_DOC"     , SF1->F1_DOC     , Nil})
			//aAdd(aCabecSF1, {"F1_SERIE"   , SF1->F1_SERIE   , Nil})
			aAdd(aCabecSF1, {"F1_EMISSAO" , SF1->F1_EMISSAO , Nil})
			aAdd(aCabecSF1, {"F1_FORNECE" , SF1->F1_FORNECE , Nil})
			aAdd(aCabecSF1, {"F1_LOJA"    , SF1->F1_LOJA    , Nil})
			aAdd(aCabecSF1, {"F1_ESPECIE" , SF1->F1_ESPECIE , Nil})
			aAdd(aCabecSF1, {"F1_COND"    , SF1->F1_COND    , Nil})

            cChaveSF1 := FWxFilial("SF1") +;
				//PadR(aLinha[nCabDocu], TamSX3("F1_DOC")[1], ' ') +;
				//PadR(aLinha[nCabSeri], TamSX3("F1_SERIE")[1], ' ') +;
				SF1->F1_FORNECE , TamSX3("F1_FORNECE")[1], ' ' +;
				SF1->F1_LOJA    , TamSX3("F1_LOJA")[1], ' ' +;
				SF1->F1_TIPO    , TamSX3("F1_TIPO")[1], ' '

			cItem := Soma1(cItem)
			aLinhaSD1 := {}
			aAdd(aLinhaSD1, {"D1_ITEM"  , cItem                          , Nil} )
			aAdd(aLinhaSD1, {"D1_COD"   , SD1->D1_COD                    , Nil} )
			aAdd(aLinhaSD1, {"D1_QUANT" , SD1->D1_QUANT                  , Nil} )
			aAdd(aLinhaSD1, {"D1_VUNIT" , SD1->D1_VUNIT                  , Nil} )
			aAdd(aLinhaSD1, {"D1_TOTAL" , SD1->D1_QUANT  * SD1->D1_VUNIT , Nil} )
			aAdd(aLinhaSD1, {"D1_TES"   , SD1->D1_TES                    , Nil} )
			aAdd(aItensSD1, aClone(aLinhaSD1))

			fPreNota()  //Gera a Pré-Nota

		ELSE
            lRet := .T.
        ENDIF

		If Findfunction("U_ZWSR014") .AND. lRet
			U_ZWSR014()
		EndIf

    ENDIF

Return(lRet)


Static Function fPreNota()
    Local cPastaErro := ""
    Local cNomeErro  := ""
    Local cTextoErro := ""
    Local aLogErro   := {}
    Local nLinhaErro := 0
 
    //Se tiver cabeçalho e itens
    If Len(aCabecSF1) > 0 .And. Len(aItensSD1) > 0
        //Se conseguir posicionar na nota, grava no log que já existe
        If SF1->(MsSeek(cChaveSF1))
            cLog += "- NF já existe na base, chave de pesquisa: " + cChaveSF1 + CRLF
 
        //Aciona o ExecAuto
        Else
            lMsErroAuto := .F.
            MSExecAuto({|x, y, z| MATA140(x, y, z)}, aCabecSF1, aItensSD1, 3)
             
            //Se houve erro, gera o log
            If lMsErroAuto
                cPastaErro := "\x_logs\"
                cNomeErro  := "pre_nota_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-") + ".txt"
 
                //Se a pasta de erro não existir, cria ela
                If ! ExistDir(cPastaErro)
                    MakeDir(cPastaErro)
                EndIf
 
                //Pegando log do ExecAuto, percorrendo e incrementando o texto
                aLogErro := GetAutoGRLog()
                For nLinhaErro := 1 To Len(aLogErro)
                    cTextoErro += aLogErro[nLinhaErro] + CRLF
                Next
                 
                //Criando o arquivo txt e incrementa o log
                MemoWrite(cPastaErro + cNomeErro, cTextoErro)
                cLog += "- Falha ao incluir NF, chave de pesquisa: " + cChaveSF1 + ", arquivo de log em '" + cPastaErro + cNomeErro + "' " + CRLF
            Else
                cLog += "- NF incluida como pré-nota, chave de pesquisa: " + cChaveSF1 + CRLF
            EndIf
        EndIf
    EndIf
Return
