#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWBROWSE.CH"

Static _oMark     


User Function ZFISF009()
//Local _cFilter   
Local _oFnt10    	:= TFont():New("Courier New",10,0)
//Local _oOk       	:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
//Local _oNo       	:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local _aColumns
Local _aCampos
Local _oSay

//Private aRotina	 :=  {}  //Menudef() //Se for criar menus via MenuDef         
//Private _nCopias := 1
Begin Sequence 
    //Preparar visualização de colunas   
    _aColumns := {}
    _aCampos  := {}
    Aadd(_aCampos,{"F2_DOC"     , PesqPict("SF2","F2_DOC")}  ) 
    Aadd(_aCampos,{"F2_SERIE"   , PesqPict("SF2","F2_SERIE")} )  
    Aadd(_aCampos,{"F2_CLIENTE" , PesqPict("SF2","F2_CLIENTE")} )  
    Aadd(_aCampos,{"F2_LOJA"    , PesqPict("SF2","F2_LOJA")} )  
    Aadd(_aCampos,{"F2_EMISSAO" , PesqPict("SF2","F2_EMISSAO")} )  
    Aadd(_aCampos,{"F2_EST"     , PesqPict("SF2","F2_EST")} )  

    aEval(_aCampos, { |e| Aadd(_aColumns, { Posicione('SX3', 2, AllTrim(e[1]), 'X3Titulo()'), e[1], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,e[2]} ) } )

    _oMark := FWMarkBrowse():New()
    _oMark:SetAlias( "SF2" )
    _oMark:SetFields(_aColumns)
    _oMark:SetFontBrowse(_oFnt10) 
    //_oMark:SetSemaphore(.T.)     
    _oMark:SetDescription("Selecionar Notas ")  
   	_oMark:SetDoubleClick({||ZFISF09MRK()})
    //Indicador do campo que sofrerá o checklist
    _oMark:SetFieldMark( 'F2_OK' )
    // _oMark:AddMarkColumns( _oOk, _oOk,_oOk)   
    //Cria botão sair caso não esteja previsto  
    _oMark:ForceQuitButton()                  
    //Função para Validar registro selecionado 
    //_oMark:Valid(U_???MRK())
    //_oMark:SetValid({||U_???MRK()})
    //_oMark:SetDoubleClick({||U_???MRK() })
    //_oMark:SetCustomMarkRec({||U_????})
    //_oMark:SetDoubleClick({||U_?????MRK()})   
	//_oMark:SetEditCell ( .T., {||U_?????()} )
    //_oMark:AddMarkColumns({| If(U_????MRK(),_oOk,_oNo) }, {|| Mark(1) }, {|| MarkAll(1) })

    _oMark:SetMenuDef( '' )
    //Montar legenda 
    _oMark:AddLegend( "F2_FIMP==' ' .AND. AllTrim(F2_ESPECIE)=='SPED'"  , "DISABLE" , OemToAnsi("NF não transmitida")  )  
    _oMark:AddLegend( "F2_FIMP=='S'"                                    , "ENABLE"  , OemToAnsi("NF Autorizada")  )  
    _oMark:AddLegend( "F2_FIMP=='T'"                                    , "BR_AZUL" , OemToAnsi("NF Transmitida")  )  
    _oMark:AddLegend( "F2_FIMP=='D'"                                    , "BR_CINZA" , OemToAnsi("NF Uso Denegado")  )  
    _oMark:AddLegend( "F2_FIMP=='N'"                                    , "BR_PRETO" , OemToAnsi("NF nao autorizada")  )  

	
    _oMark:AddButton("Gerar arquivos"  	, { || FwMsgRun(,{ | _oSay | ZFISF09GAQ( @_oSay) }, "Gerando arquivos ", "Aguarde...")  },,,, .F., 2 )  


    // Filtros 
    //_oMark:AddFilter("NF NÃO Autorizada","F2_FIMP==' ' AND AllTrim(F2_ESPECIE)=='SPED'"    ,.T.,.T.)
    //_oMark:AddFilter("NF Autorizada"    ,"Z1_CRATEDA <> ''",.T.,.T.)
    _oMark:SetInvert(.F.)
    // Define se utiliza marcacao exclusiva  
    //_oMark:SetSemaphore(.F.)	 
    //Indica que a marca deve ser considerada invertida Obs.: Utilizada em casos como o de marcação de todos os registros
    //_oMark:SetInvert(.F.)
    //Limpar objeto mark
    //_oMark:SetAllMark( { || _oMark:AllMark() } )

//    _oMark:SetWalkThru(.T.)
    //Ativa
    _oMark:Activate() 
    //Fecha todos os filtros da rotina
//    _oMark:CleanFilter()
End Sequence    
Return Nil


//========================================================
//Validação quando da seleção do registro no objeto mark
//========================================================
Static Function ZFISF09MRK()
Local _lRet := .T.
Local _cMarca := _oMark:Mark()
Begin Sequence               
    //Caso esteja desmarcando não validar
    If !_oMark:IsMark(_cMarca)  
      Break
    Endif
	//Montar validação em relação aos relacionamentos verificar se ja esta selecionado pois outro usuário pode acessar
End Sequence
Return _lRet 



Static Function ZFISF09GAQ( _oSay) 
Local _cMarca   := _oMark:Mark()
Local _cArqXML  := "" 
Local _lMostra  := .T.
    If _oMark:IsMark(_cMarca)
        Pergunte("NFSIGW",.F.)
        MV_PAR01 := SF2->F2_SERIE
        MV_PAR02 := SF2->F2_DOC  
        MV_PAR03 := SF2->F2_DOC  
        MV_PAR04 := "c:\temp\"  
        MV_PAR05 := Date() - 600  
        MV_PAR06 := Date()  
        //StaticCall(SPEDNFE,SpedPExp, MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04,.T.,MV_PAR05, MV_PAR06, , 1,)
        //SpedPExp(cIdEnt,cSerie,cNotaIni,cNotaFim,cDirDest,lEnd,dDataDe,dDataAte,cCnpjDIni,cCnpjDFim,nTipo,lCTe,cSerMax,cOpcExp)
        _oMark:SetInvert(.F.)
        SpedExport()
        //zSpedXML(SF2->F2_DOC, SF2->F2_SERIE, @_cArqXML, _lMostra)
        _oMark:refresh()
    Endif  
Return .t.



    
/*/{Protheus.doc} zSpedXML
Função que gera o arquivo xml da nota (normal ou cancelada) através do documento e da série disponibilizados
@author Atilio
@since 25/07/2017
@version 1.0
@param cDocumento, characters, Código do documento (F2_DOC)
@param cSerie, characters, Série do documento (F2_SERIE)
@param cArqXML, characters, Caminho do arquivo que será gerado (por exemplo, C:\TOTVS\arquivo.xml)
@param lMostra, logical, Se será mostrado mensagens com os dados (erros ou a mensagem com o xml na tela)
@type function
@example Segue exemplo abaixo
    u_zSpedXML("000000001", "1", "C:\TOTVS\arquivo1.xml", .F.) //Não mostra mensagem com o XML
        
    u_zSpedXML("000000001", "1", "C:\TOTVS\arquivo2.xml", .T.) //Mostra mensagem com o XML
/*/
    
Static Function zSpedXML(cDocumento, cSerie, cArqXML, lMostra)
    Local aArea        := GetArea()
    Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local oWebServ
    Local cTextoXML    := ""
    Local oFileXML

    Default cDocumento := ""
    Default cSerie     := ""
    Default cArqXML    := GetTempPath()+"arquivo_"+cSerie+cDocumento+".xml"
    Default lMostra    := .F.

    Private cIdEnt     := ""

    If IsReady()
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³Obtem o codigo da entidade                                              ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    cIdEnt := SF2->(RetIdEnti())  //GetIdEnt()
    Endif 

    //Se tiver documento
    If !Empty(cDocumento) .and. !Empty(cIdEnt)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
            
        //Instancia a conexão com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"
            
        //Se tiver notas
        If oWebServ:RetornaNotas()
            
            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
                
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                        
                //Senão, pega o xml normal (foi alterado abaixo conforme dica do Jorge Alberto)
                Else
                    cTextoXML := '<?xml version="1.0" encoding="UTF-8"?>'
                    cTextoXML += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXMLPROT
                    cTextoXML += '</nfeProc>'
                EndIf
                    
                //Gera o arquivo
                oFileXML := FWFileWriter():New(cArqXML, .T.)
                oFileXML:SetEncodeUTF8(.T.)
                oFileXML:Create()
                oFileXML:Write(cTextoXML)
                oFileXML:Close()
                    
                //Se for para mostrar, será mostrado um aviso com o conteúdo
                If lMostra
                    Aviso("zSpedXML", cTextoXML, {"Ok"}, 3)
                EndIf
                    
            //Caso não encontre as notas, mostra mensagem
            Else
                ConOut("zSpedXML > Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...")
                    
                If lMostra
                    Aviso("zSpedXML", "Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...", {"Ok"}, 3)
                EndIf
            EndIf
            
        //Senão, houve erros na classe
        Else
            ConOut("zSpedXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
                
            If lMostra
                Aviso("zSpedXML", IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)), {"Ok"}, 3)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return

