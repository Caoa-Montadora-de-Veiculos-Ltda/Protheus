#Include "TOTVS.ch"
#INCLUDE 'APVT100.CH'

/*
=====================================================================================
Programa.:              CBRETEAN
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              09/12/19
Descricao / Objetivo:   P.E. para tratar a leitura do código de barras.
Doc. Origem:
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              ACD
Obs......:
=====================================================================================*/
User Function CBRETEAN()

Local aArea     := GetArea()
Local aAreaSB1  := SB1->(GetArea())
Local cCodBar   := AllTrim(PARAMIXB[1])  // CÓDIGO DE BARRA
Local aRet      := {}                    // DADOS DA ETIQUETA
Local cProduto  := ""                    // CÓDIGO DO PRODUTO (B1_COD)
Local nQtdEmb   := 0
Local aTela     := {}
Local nPos      := 0
Local aSel      := {}
Local nPosic    := 0    
Local aIt       := {}
Local cQt       := ""
Private cAliasTMP := GetNextAlias()

If Empty(cCodBar)
    Return (aRet)
Endif

ZZH->( DbSetOrder(2) )

/**************************************************************************************************************************************
//  TRATAMENTO DAS ETIQUETAS DA HYUNDAI
//  PRECISA TER 29 OU 39 CARACTERES E COMEÇAR COM XF - XK - XT - BS
/*************************************************************************************************************************************/

// ACDV110: Consulta > Cadastros > Etiqueta
// WMSV090: Atualizações > Recebimento WMS > Conferencia Produto
// WMSV095: Atualizações > Estoque WMS > Transferencia endereço

If AllTrim( FunName() ) $ "ACDV110|WMSV090|WMSV095"

    Do Case

        //VALIDA SE O CODIGO DE BARRA DIGITADO CORRESPONDE A UM PRODUTO  
        Case !Empty( Posicione("SB1", 1, FwXfilial("SB1") + cCodBar, "B1_COD") )

            cProduto := AllTrim( cCodBar )

        //ETIQUETA CHERY, CONTIDA NA TABELA ZZH QUE ARMAZENA AS ETIQUETAS IMPORTADAS VIA CSV
        Case ZZH->( DbSeek( FWxFilial("ZZH") + AllTrim( cCodBar ) ) )

            //ZZH->( DbGoTop() )
            While ZZH->( !EOF() ) .And. AllTrim( ZZH->ZZH_CODBOX ) == AllTrim( cCodBar )
                
                //--Matriz com produto e quantidade
                aAdd( aSel, { AllTrim( ZZH->ZZH_PRODUT ), ZZH->ZZH_QTD } )

                //--Vetor apenas com produto para seleção do operador
                aAdd( aIt, AllTrim( ZZH->ZZH_PRODUT ) )

                ZZH->( DbSkip() )

            EndDo

            If Len(aIt) > 1
                VTSave Screen To aTela
                VTClear()

                @ 0,0 VTSay PadC("Selec Produto Chery",VTMaxCol())
                nPosic  := VTACHOICE(2, 0, VTMaxRow(),VTMaxCol(), aIt)

                cProduto := aSel[nPosic][1]
                nQtdEmb  := aSel[nPosic][2]

                VTRestore Screen From aTela
            ElseIf !Empty(aIt)
                cProduto := aSel[1][1]
                nQtdEmb  := aSel[1][2]
            EndIf    

        //ETIQUETA HYUNDAI COM 39 CARACTERES OU COM 29 CARACTERES E ETIQUETAS COMEÇANDO COM XF - XK - XT - BS
        Case ( Len( AllTrim( cCodBar ) ) == 39 .Or. Len( AllTrim( cCodBar ) ) == 29 ) .And. Substr( AllTrim( cCodBar ),1,2 ) $ "XF|XK|XT|BS"  
            
            // PRODUTO RECEBE DA POSIÇÃO 11 A 23
            cProduto := AllTrim( Substr( AllTrim( cCodBar ),11,13 ) )
            nQtdEmb := Val( Substr( AllTrim( cCodBar ),24,06 ) )

        //ETIQUETA QrCode HYUNDAI COM 42 CARACTERES E ETIQUETAS COMEÇANDO COM XF - XK - XT - BS
        Case ( Len( AllTrim( cCodBar ) ) == 42 ) .And. Substr( AllTrim( cCodBar ),1,2 ) $ "XF|XK|XT|BS"  
            
            // PRODUTO RECEBE DA POSIÇÃO 11 A 24
            cProduto := AllTrim( Substr( AllTrim( cCodBar ),11,14 ) )
            nQtdEmb := Val( Substr( AllTrim( cCodBar ),25,08 ) )

        //ETIQUETA NACIONAIS, CONTEM ESPAÇO NA SUA COMPOSIÇÃO, SENDO PRODUTO ANTES DO ESPAÇO E QTD APÓS ESPAÇO
        Case At( " ", AllTrim( cCodBar ) ) > 0
            
            nPos := At( " ", AllTrim( cCodBar ) )
            
            // PRODUTO RECEBE DA POSIÇÃO 0 até espaço
            cProduto := AllTrim( Substr( AllTrim( cCodBar ),1,nPos-1 ) )
            nQtdEmb := Val( Substr( AllTrim( cCodBar ),nPos+1 ) )

    EndCase

    If !Empty(cProduto)
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
        If SB1->(DBSeek(xFilial("SB1")+cProduto))
                    
            If AllTrim( FunName() ) == "ACDV110" // Consulta Etiqueta
            
                nQtdEmb  := SB1->B1_QE

            ElseIf AllTrim( FunName() ) == "WMSV090"

                nQtdEmb  := 0

            ElseIf AllTrim( FunName() ) == "WMSV095"
                
                If nQtdEmb <> 0
                    cQt := "Qtd:     " + cValToChar( nQtdEmb )
                EndIf

                VTSave Screen To aTela
                VTClear()
                //--Informa ao operador a quantidade identificada no código de barras
                If !VTYesNo("Produto: " + AllTrim(cProduto)                             + CRLF + ;
                            cQt                                                         + CRLF + ;
                            "Range:   " + Substr( AllTrim( SB1->B1_XRANGE ), 01, 20 )   + CRLF + ;
                            "Id_Unit: " + AllTrim( SB1->B1_XIDUNIT)                     + CRLF + ;
                            "Qty aUnt:" + AllTrim( SB1->B1_XQTUNIT)                     + CRLF   ;
                          , "Confirma Qtde?") 

                    nQtdEmb := 0        
                EndIf

                VTRestore Screen From aTela

            EndIf
        
            AAdd(aRet, PadR( cProduto, TamSX3("B1_COD")[1]) )   // ARET[1] CÓDIGO DO PRODUTO
            AAdd(aRet, nQtdEmb)                                 // ARET[2] QUANTIDADE POR EMBALAGEM
            AAdd(aRet, PadR("", TamSX3("B8_LOTECTL")[1]))       // ARET[3] LOTE
            AAdd(aRet, PadR("", TamSX3("B8_DTVALID")[1]))       // ARET[4] DATA DE VALIDADE
            AAdd(aRet, PadR("", TamSX3("BF_NUMSERI")[1]))       // ARET[5] NÚMERO DE SÉRIE
            //AAdd(aRet, PadR("", TamSX3("BE_LOCALIZ")[1]))       // ARET[6] ENDEREÇO DESTINO

        EndIf
    EndIf

EndIf

RestArea(aAreaSB1)
RestArea(aArea)

Return(aRet)
