#include 'parmtype.ch'
#include 'protheus.ch'
#include "TBICONN.CH"
#Define CRLF Char(13) + Char(10)
/*{Protheus.doc} Post
Efetua a Criação de Romaneio Automaticamente - ( RG LOG )
@return lRet			, caracter, JSON com os Produtos.
@author		A.Carlos
@since		14/12/2021
@version	12.1.27
@Obs:....   Alterações --> Fagner Barreto - CAOA
===================================================================================== */
User Function ZWSR003(aParam)   //({"02", "2020012001"})
    Local aPergs        := {}
    Local aRet		    := {}
    Local cEmpJob       := ""
    Local cFilJob       := ""
    Local lJob          := IsBlind()
    Local dData         := CTOD('  /  /  ') 
    Private __cChvCTE   := ""
    Private __dData     := CTOD('  /  /  ') 
    Private __lCalcul   := .F.
   
    ConOut("ZWSF003 - inicio de Importação de Romaneios")
    
    If lJob     //-- via JOB
        cEmpJob := aParam[1]
        cFilJob := aParam[2]

        RpcSetType(3)
	    RpcSetEnv( cEmpJob , cFilJob )
        __lCalcul  := .T.
        Return zProcessa(lJob)
    Else

        aAdd(aPergs, {1 ,"Chave CTE"	,Space(TamSX3("GW3_CTE")[1]),""	,""    ,"" ,""    ,120,.F. })
        aAdd(aPergs, {1 ,"Data"	        ,dData		                ,""	,".T." ,"" ,".T." ,60 ,.F. })
        
        while ParamBox( aPergs ,"Informar chave CTE" ,@aRet )

            __cChvCTE := aRet[1]
            __dData   := aRet[2]
            __lCalcul := !Empty(DtoS(__dData))
 
            if !Empty(__cChvCTE) .or. !Empty(__dData)
                Processa({|| zProcessa(lJob) }, "[ZWSR003] - Geracao automatica de romaneio", "Aguarde .... Realizando a carga dos registros...." ) 
            else
                MsgAlert("Pelo menos um parametro deve ser informado ", "[ZWSR003]--Informar Parametro")
            EndIf
        Enddo

    EndIf

    IF lJob
	    RpcClearEnv()
    Endif	

Return


/* ==================================================================================
Programa.:  ZWSF003
Autor....:  CAOA - A.Carlos
Data.....:  14/12/2021
Descricao:  Efetua as tarefas da integração - RG LOG 
Obs......:  Alterações --> Fagner Barreto - CAOA
===================================================================================== */
Static Function zProcessa(lJob)
    Local oJson     := Nil
    Local aRes      := Array(2)
    Local aHeader   := {"Content-Type: application/json"} 
    Local cpath     := ""
    Local nDias     := SuperGetMV( "CMV_PEC014" ,,45)  //Quantidade de dias que serão considerados - Retroativos
    Local cUrl      := SuperGetMV( "CMV_PEC015" ,,"http://www.rgtracking.com.br")  //Link onde o Json do romaneio será liberado
    Local cUrl2     := SuperGetMV( "CMV_PEC016" ,,"/rglog/edi/MinhasColetasJson.php?formato=json&op=3736&filtro=manifesto")  //Path do Arquivo Json
    Local cUrl3     := SuperGetMV( "CMV_PEC021" ,,"/rglog/edi/MinhasColetasJson.php?formato=json&op=3736&filtro=chave&valor=35220510213051001399570010005184801005184809")  //Path do Arquivo Json
    Local oRest     := FwRest():New( cUrl )
    Local dData1    := dtos(dDataBase-nDias)
    Local dData2    := dtos(dDatabase-nDias)
    Local x         := 0
    Local y         := 0
    Local _ctpoper  := ""
    Local cAliasGW8 := ""
    Local cAliasGU3 := ""
    Local aChvNfs   := {}
    Local aChvLoc   := {}
    Local aDadosLoc := {}
    Local cFracion  := "FRACIONADO|DEVOLU_906|DEVOLUCAO|FRACIO_906|TRANSFER|TRANSFER_SR|AERE"
    Local cOperImp  := "CAOA_DI|DI_BARUERI"
    Local nValBrut  := 0
    Local aDadosRat := {}
    Local cHrColeta := ""
    Local nPos      := 0
    Local nPesoB    := 0
    local nPesoC    := 0
    Local cCodMot   := ""
    Local cCDTPVC   := ""   
    Local cDirLog   := AllTrim( GetNewPar("CMV_LOGROM", "EDI/LOG/") )
    Local lContinua := .T.
    Local _cChaveCTE:= ""
    Local _NroRom   := ""
    local _tp_oper  := ""
    Local _nContCmp := ""
    Local aRomaneio := {}
    Local aMunOper  := { {"2034-GUARUJA"   ,"GUARUJA_MA"},;
                         {"4577-SANTOS"    ,"SANTOS_MA" },;
                         {"2036-GUARULHOS" ,"GUARULH_AE"},;
                         {"951-CAMPINAS"   ,"VIRACOP_AE"}   }

    Private __cArqLog   := ""
    Private __cMsgLoc   := ""                         
    Private __cArqOk   := ""
    Private __cMsgOk   := ""
    
    Default lJob        := .F.

    if !lJob
        dData1 := Dtos(__dData)
        dData2 := Dtos(__dData)
    Endif

    If Empty( __cChvCTE )

        dData1 := SUBSTRING(dData1,7,2) + "/" + SUBSTRING(dData1,5,2) + "/" + SUBSTRING(dData1,1,4)
        dData2 := SUBSTRING(dData2,7,2) + "/" + SUBSTRING(dData2,5,2) + "/" + SUBSTRING(dData2,1,4)
    
        cpath :=  SubStr( cUrl2, 1, At( "&dataI" ,cUrl2) - 1 ) + "&dataI=" + dData1 + "&dataF=" + dData2 + SubStr( cUrl2, At( "&aut" ,cUrl2) )

    Else

        cpath := SubStr( cUrl3, 1, At( "&valor" ,cUrl3) - 1 ) + "&valor=" + __cChvCTE

    EndIf

    oRest:SetPath(cpath)

    aRes[1] := oRest:Get(aHeader)

    //--Ativa WorkAreas
    GUU->( DbSetOrder(2) ) //--GUU_FILIAL + GUU_IDFED
    GV3->( DbSetOrder(2) ) //--GV3_FILIAL + GV3_DSTPVC
    GW1->( DbSetOrder(12) ) //--GW1_DANFE + GW1_FILIAL
    GV5->( DbSetOrder(1) ) //--GV5_FILIAL + GV5_CDTPDC
    GWU->( DbSetOrder(1) ) //--GWU_FILIAL + GWU_CDTPDC + GWU_EMISDC + GWU_SERDC + GWU_NRDC + GWU_SEQ
    GWB->( DbSetOrder(2) ) //--GWB_FILIAL + GWB_CDTPDC + GWB_EMISDC + GWB_SERDC + GWB_NRDC + GWB_CDUNIT

    //--Gera arquivo de log a cada execução
    If !Empty( __cChvCTE )

        //--Quando a execução for manual acrescenta a chave do CTe ao nome do arquivo de log
        __cArqLog := cDirLog +"ZWSR003_"+__cChvCTE+"_"+DTOS(Date())+"_"+StrTran(Time(),":")+".LOG"
        //__cArqOk  := cDirLog +"ZWSR003_"+__cChvCTE+"_"+DTOS(Date())+"_"+StrTran(Time(),":")+"_Ok.LOG"

    Else

        __cArqLog := cDirLog +"ZWSR003_Gera_Romaneio_"+DTOS(Date())+"_"+StrTran(Time(),":")+".LOG"
        //__cArqOk  := cDirLog +"ZWSR003_Gera_Romaneio_"+DTOS(Date())+"_"+StrTran(Time(),":")+"_Ok.LOG"

    EndIf    
    GrvLog(__cArqLog, "Iniciando Processo")
    If aRes[1] = .F.

        ConOut("Error: " + oRest:GetLastError())
        aRes[2] := oRest:GetLastError()

        GrvLog(__cArqLog, "Falha na geracao do romaneio, erro: " + oRest:GetLastError() )
        lContinua := .F.
        
    Else

        aRes[2] := oRest:cResult

        oJson := JsonObject():New()

        oJson:Fromjson(oRest:cResult)

        If Len(oJson) > 0 
            
            If !lJob
                ProcRegua( Len(oJson) )
            EndIf    

            For x := 1 to Len(oJson)

                If !lJob
                    IncProc("Efetuando a geracao do romaneio.")  //-- Incrementa a mensagem na régua.
                EndIf

                //Pega o numero do Romaneio
                //_NroRom    := GFE50NRROM()
                lContinua := .T.
                cHrColeta := IIF( Empty( AllTrim( SubStr( oJson[x]['datahora_coleta'], 11 ) ) ), "07:00", AllTrim( SubStr( oJson[x]['datahora_coleta'], 11 ) ) )

                _coleta    := oJson[x]['id_coleta']
                _cChaveCTE := oJson[x]['cte_chave']
                _DtColeta  := CToD(oJson[x]['datahora_coleta'])
                _HrColeta  := IIF( Len(cHrColeta) < 6, cHrColeta + ":00", cHrColeta )
                _CnpjPag   := U_ZGENESPC( oJson[x]['cnpj_pagador'] )
                _CnpjRem   := U_ZGENESPC( oJson[x]['cnpj_remetente'] )
                _CnpjDest  := U_ZGENESPC( oJson[x]['cnpj_destnatario'] )
                _transp    := U_ZGENESPC( oJson[x]['cnpj_transportadora'] )

                If Valtype(oJson[x]['motorista_cpf']) <> 'U'
                    _mot_cpf   := oJson[x]['motorista_cpf']
                Else
                    GrvLog(__cArqLog, "Coleta: " + _coleta + " falha na geracao do romaneio, o dado obrigatorio motorista_cpf não foi informado pela RGLOG" )
                    lContinua := .F.
                EndIf            
                
                If Valtype(oJson[x]['motorista_nome']) <> 'U'
                    _nome_mot  := oJson[x]['motorista_nome']
                Else
                    GrvLog(__cArqLog, "Coleta: " + _coleta + " falha na geracao do romaneio, o dado obrigatorio motorista_nome não foi informado pela RGLOG" )
                    lContinua := .F.
                EndIf

                If Valtype(oJson[x]['veiculo_tipo']) <> 'U'
                    _tp_veic   := U_ZGENESPC( oJson[x]['veiculo_tipo'] )
                Else
                    GrvLog(__cArqLog, "Coleta: " + _coleta + " falha na geracao do romaneio, o dado obrigatorio veiculo_tipo não foi informado pela RGLOG" )
                    lContinua := .F.
                EndIf
                
                If Valtype(oJson[x]['tipo_tabela_frete']) <> 'U' .And. !Empty(oJson[x]['tipo_tabela_frete'])
                    _tp_oper   := oJson[x]['tipo_tabela_frete']

                    If _tp_oper = "TABELA NAO CADASTRADA"
                        GrvLog(__cArqLog, "Coleta: " + _coleta + " falha na geracao do romaneio, o dado obrigatorio tipo_tabela_frete foi enviado como TABELA NAO CADASTRADA pela RGLOG" )
                        lContinua := .F.
                    EndIf

                    If Valtype(oJson[x]['distancia_km']) <> 'U'
                        If AllTrim(_tp_oper) <> "FAIXA KM" .Or. oJson[x]['distancia_km'] > 0
                            _percurs   := oJson[x]['distancia_km']
                        Else
                            GrvLog(__cArqLog, "Coleta: " + _coleta + " falha na geracao do romaneio, o dado obrigatorio distancia_km não foi informado pela RGLOG" )
                            lContinua := .F.
                        EndIf  
                    Else
                        GrvLog(__cArqLog, "Coleta: " + _coleta + " falha na geracao do romaneio, o dado obrigatorio distancia_km não foi informado pela RGLOG" )
                        lContinua := .F.
                    EndIf  

                    If Valtype(oJson[x]['container_comprimento']) <> 'U' 
                    //    If AllTrim(_tp_oper) <> "CAOA_DI" .Or. oJson[x]['container_comprimento'] > 0
                            _nContCmp   := oJson[x]['container_comprimento']
                    //    Else
                    //        GrvLog(__cArqLog, "Coleta: " + _coleta + " falha na geracao do romaneio, o dado obrigatorio container_comprimento não foi informado pela RGLOG" )
                    //        lContinua := .F.    
                    //    EndIf
                    Else 
                        GrvLog(__cArqLog, "Coleta: " + _coleta + " falha na geracao do romaneio, o dado obrigatorio container_comprimento não foi informado pela RGLOG" )
                        lContinua := .F.
                    EndIf  

                    If Valtype(oJson[x]['municipio_coleta']) <> 'U' 
                        _MunCol    := AllTrim( oJson[x]['municipio_coleta'] )
                    ElseIf _tp_oper $ cOperImp
                        GrvLog(__cArqLog, "Coleta: " + _coleta + " falha na geracao do romaneio, o dado obrigatorio municipio_coleta não foi informado pela RGLOG" )
                        lContinua := .F.
                    EndIf

                Else
                    GrvLog(__cArqLog, "Coleta: " + _coleta + " falha na geracao do romaneio, o dado obrigatorio tipo_tabela_frete não foi informado pela RGLOG" )
                    lContinua := .F.
                EndIf             

                If Valtype(oJson[x]['modal']) <> 'U'
                    _modal     := oJson[x]['modal']
                Else
                    GrvLog(__cArqLog, "Coleta: " + _coleta + " falha na geracao do romaneio, o dado obrigatorio modal não foi informado pela RGLOG" )
                    lContinua := .F.
                EndIf                

                If Valtype(oJson[x]['veiculo_placa']) <> 'U'
                    _placa     := oJson[x]['veiculo_placa']
                Else
                    GrvLog(__cArqLog, "Coleta: " + _coleta + " falha na geracao do romaneio, o dado obrigatorio veiculo_placa não foi informado pela RGLOG" )
                    lContinua := .F.
                EndIf
                
                _codtran   := ""
                _tpnf      := ""
                aChvNfs    := {}
                cCDTPVC    := "" 

                If !lContinua
                    Loop //--Proximo registro
                EndIf

                //Verifica se o Motorista existe na GUU, caso ele não exista será criado
                _mot_cpf := StrTran(StrTran(StrTran(_mot_cpf,".",""),"/",""),"-","")

                IF GUU->(DBSEEK(xFilial("GUU")+_mot_cpf))  //se não encontrar o cpf do motorista efetua a gravação
                    cCodMot := GUU->GUU_CDMTR
                Else
                   cCodMot := zCadMot(_mot_cpf, _nome_mot)
                ENDIF

                //--O campo GWN_CDTPVC sera preenchido somente quando o tipo_tabela_frete for FAIXA KM
                If _tp_oper = "FAIXA KM"
                    //--Grava o campo GWN_CDTPVC somente se o tipo de veiculo existir na tabela GV3
                    IF GV3->(DBSEEK(xFilial("GV3") + _tp_veic))
                        cCDTPVC := GV3->GV3_CDTPVC
                    ENDIF
                EndIf

                cAliasGU3 := GetNextAlias()
                BeginSql Alias cAliasGU3
                    SELECT GU3_CDEMIT
                    FROM %Table:GU3% GU3
                    WHERE GU3.GU3_FILIAL = %xFilial:GU3%
                    AND GU3.GU3_IDFED = %Exp:_transp%
                    AND GU3.GU3_TRANSP = '1'
                    AND GU3.%NotDel%
                EndSql

                If (cAliasGU3)->( !Eof() )
                    _codtran := (cAliasGU3)->GU3_CDEMIT
                Else
                    GrvLog(__cArqLog, "Coleta: " + _coleta + "Transportadora CNPJ: " + _transp + " Não localizada no cadastro de emitentes!" )
                EndIf

                (cAliasGU3)->( DbCloseArea() )

                //Ficou definido em reunião Juarez/Sidney, que se caso o campo GW1_NRROM,
                //Estiver preenchido, não deve gerar o romaneio, pois a Ana coloca manualmente
                //Para ela ter o controle.

                If _CnpjPag == "03471344000509" .And. _CnpjRem <> "03471344000509" .And. _CnpjDest <> "03471344000509"
                    _ctpoper := "TRIANGULA"
                ElseIf _tp_oper $ cFracion
                    _ctpoper := "FRACIONADO"
                ElseIf _tp_oper $ cOperImp
                    //--Consulta tipo de operação na matriz de De/Para
                    nPos := aScan( aMunOper, { |x| AllTrim( x[1] ) == _MunCol } )
                    _ctpoper := aMunOper[nPos][2]
                Else
                    _ctpoper := _tp_oper
                EndIf

                cMsgLogCte := "Coleta: " + _coleta + " | Chave CT-e : " + _cChaveCTE
                If Len(oJson[x]['notas']) > 0
                    
                    //--Verifica se todas as notas estão no GFE antes de iniciar a geração do romaneio
                    For y := 1 to Len(oJson[x]['notas'])

                        _cChave := oJson[x]['notas'][y]['ChaveDanfe']
                        If !Empty(_cChave)
                            IF !( GW1->( DBSEEK( _cChave ) ) )
                            
                                //--Se for locação grava msg para as notas não localizadas e não impede a geração do romaneio
                                If _tp_oper = 'LOCACAO'
                                    
                                    If Empty( __cChvCTE )
                                        __cMsgLoc += CRLF + " Nota fiscal chave: " + _cChave + " não localizada no GFE Protheus "
                                    Else
                                        cMsgLogCte += CRLF +  " Nota fiscal chave: " + _cChave + " não localizada no GFE Protheus.
                                        lContinua := .F.
                                    EndIf

                                Else
                                    cMsgLogCte += CRLF +  " Nota fiscal chave: " + _cChave + " não localizada no GFE Protheus.
                                    lContinua := .F.
                                EndIf

                            EndIf
                        Else
                            cMsgLogCte += CRLF +  " Chave da Danfe não foi informada no arquivo da RGLOG.
                            lContinua := .F.
                        EndIf    

                    Next y

                Else
                    cMsgLogCte += CRLF +  " Chave da Danfe não foi informada no arquivo da RGLOG.
                    lContinua := .F.
                EndIf

                If lContinua

                    For y := 1 to Len(oJson[x]['notas'])
                        _cChave := oJson[x]['notas'][y]['ChaveDanfe']
                        IF GW1->( DBSEEK( _cChave ) )
                            IF EMPTY(GW1->GW1_NRROM)

                                /*Grava o volume para o tipo TRG porque na integração do doc carga 
                                via rotina ZGFEF002 ocorreram xmls sem as tags de volume*/
                                If GW1->GW1_CDTPDC == 'TRG' //--Triangulação
                                    
                                    If Valtype(oJson[x]['qtd_volumes']) <> 'U'
                                    
                                        RecLock("GW1", .F.)
                                        GW1->GW1_QTVOL  := oJson[x]['qtd_volumes']
                                        GW1->( MsUnLock() )

                                        If GWB->( MsSeek( FWxFilial("GWB") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC ) )
                                            RecLock("GWB", .F.)
                                            GWB->GWB_QTDE  := oJson[x]['qtd_volumes']
                                            GWB->( MsUnLock() )    
                                        EndIf

                                    EndIf

                                EndIf

                                IF GV5->( DBSEEK(xFilial("GV5") + _tpnf) )
                                    IF GV5->GV5_EMITPF = "1" 
                                        _emitpf_01   := "2"
                                    ELSE
                                        _emitpf_01   := "1"
                                    Endif
                                ENDIF

                                //--Gravação dos pesos bruto e cubado para remetentes diferentes de Barueri
                                If GW1->GW1_CDTPDC <> "NFS"  .or. _tp_oper == "CORREIO"//_CnpjRem <> "03471344000509"

                                    //--Query para calcular o valor bruto total dos itens
                                    cAliasGW8 := GetNextAlias()
                                    BeginSql Alias cAliasGW8
                                        SELECT SUM(GW8_VALOR) AS VLRTOTAL
                                        FROM %Table:GW8% GW8
                                        WHERE GW8.GW8_FILIAL = %xFilial:GW8%                                      
                                        AND GW8.GW8_CDTPDC = %Exp:GW1->GW1_CDTPDC%
                                        AND GW8.GW8_EMISDC = %Exp:GW1->GW1_EMISDC%
                                        AND GW8.GW8_SERDC = %Exp:GW1->GW1_SERDC%
                                        AND GW8.GW8_NRDC = %Exp:GW1->GW1_NRDC%
                                        AND GW8.%NotDel%
                                    EndSql

                                    If (cAliasGW8)->( !Eof() )
                                        nValBrut  := (cAliasGW8)->VLRTOTAL
                                    EndIf

                                    (cAliasGW8)->( DbCloseArea() )

                                    GW8->( DbSetOrder(1) )
                                    If GW8->( DbSeek( FWxFilial("GW8") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC ) )

                                        aDadosRat := {} //--Limpa array a cada documento

                                        While GW8->( !Eof() ) .And.;
                                            GW8->(GW8_CDTPDC + GW8_EMISDC + GW8_SERDC + GW8_NRDC) == GW1->(GW1_CDTPDC + GW1_EMISDC + GW1_SERDC + GW1_NRDC)
                                            
                                            nPesoC := oJson[x]['notas'][y]['pesoCalculado']
                                            nPesoB := oJson[x]['notas'][y]['pesoKG']
                                            if nPesoC == 0
                                                nPesoC := 0.01
                                            ENDIF
                                            if nPesoB == 0
                                                nPesoB := 0.01
                                            ENDIF
                                            
                                            AaDD( aDadosRat, {  GW8->GW8_NRDC,;
                                                                GW8->GW8_SERDC,;
                                                                GW8->GW8_SEQ,;
                                                                GW8->GW8_ITEM,;
                                                                GW8->GW8_QTDE,;
                                                                GW8->GW8_VALOR,;
                                                                nPesoC,;                //oJson[x]['notas'][y]['pesoCalculado'],;
                                                                nPesoB,;                //oJson[x]['notas'][y]['pesoKG'],;
                                                                nValBrut } )

                                            GW8->( DbSkip() )
                                        EndDo

                                        //--Efetua a gravação dos pesos bruto e cubado na tabela GW8 - GFE
                                        If FindFunction("U_ZGFEF001")
                                            U_zAtuPesGW8(aDadosRat)
                                        EndIf

                                    EndIf

                                EndIf

                                //--Se for locação agrupa para gerar apenas 1 romaneio de todos os documentos
                                If _tp_oper = 'LOCACAO'
                                    aDadosLoc := {_ctpoper, _modal, _percurs, cCDTPVC, _codtran, cCodMot, _placa, _emitpf_01,_nContCmp}
                                    _DtLocac  := CToD(oJson[x]['datahora_coleta'])
                                    _cHrLocac := IIF( Len(cHrColeta) < 6, cHrColeta + ":00", cHrColeta ) 
                                    Aadd( aChvLoc, {  _cChave  })
                                Else  
                                    Aadd(aChvNfs, {  _cChave  })  //NFE OU NFS
                                EndIf

                            Else
                                Aadd( aRomaneio, "Chave Danfe: " + _cChave + " atrelada ao Romaneio: " + GW1->GW1_NRROM)
                            ENDIF
                        ENDIF
                    Next y

                    If !(_tp_oper == 'LOCACAO') .And. Len(aChvNfs) > 0
                        _NroRom := zGeraRom(_ctpoper, _modal, _percurs, cCDTPVC, _codtran, cCodMot, _placa, _emitpf_01, aChvNfs, _DtColeta, _HrColeta,lJob,_nContCmp)
                        //GrvLog(__cArqLog, "OK - Romaneio gerado, Numero:" +_NroRom )
                    EndIf

                Else

                    GrvLog(__cArqLog, cMsgLogCte )

                EndIf

            Next x 

            //--Geração de romaneio para o tipo LOCACAO
            If Len(aDadosLoc) > 0
                _NroRom := zGeraRom(aDadosLoc[1], aDadosLoc[2], aDadosLoc[3], aDadosLoc[4], aDadosLoc[5], aDadosLoc[6], aDadosLoc[7], aDadosLoc[8], aChvLoc, _DtLocac, _cHrLocac,lJob, aDadosLoc[9])
            EndIf

           //GrvLog(__cArqLog, "OK - Romaneios gerados Com Sucesso" )
          
            FreeObj(oJson) 
        Else
            If Empty( __cChvCTE )
                GrvLog(__cArqLog, "Falha na geracao do romaneio, erro: " + oRest:GetResult() )
            Else
                GrvLog(__cArqLog, "CTE chave: " + __cChvCTE + " Falha na geracao do romaneio, erro: " + oRest:GetResult() )
                lContinua := .F.
            EndIf
        EndIf

        conout(oJson)
    EndIf

    If !Empty( __cChvCTE ) //--Se utilizou a tela para informar um unico CTe
        If ( !lContinua .Or. !Empty( __cMsgLoc ) ) //--Se apresentou erro
            Help( ,, "CaoaTec",, "Falha na geracao do romaneio, por favor, verifique o arquivo de log." , 1, 0)
        ElseIf Len(aChvNfs) == 0 .And. Len(aDadosLoc) == 0 //--Se todas as danfes do CTe ja possuem romaneio atrelado
            cMsgLogCte += "Todas as danfes do CT-e chave: " + __cChvCTE + " ja possuem romaneio atrelado." + CRLF 

            For y := 1 to Len(aRomaneio)
                cMsgLogCte += aRomaneio[y] + CRLF 
            Next y

            MsgInfo(cMsgLogCte)

        EndIf
    EndIF

    GrvLog(__cArqLog, "Finalizando Processo")

Return

/*
======================================================================================
Programa.:              zGeraRom
Autor....:              CAOA - Fagner Barreto
Data.....:              09/03/2022
Descricao / Objetivo:   Geração de romaneio
======================================================================================
*/
Static Function zGeraRom(_tp_ope_01, _modal_01, _percu_01, cCodTpVei, _codtra_01, cCodMot, _placa_01, _emitpf_01, aChvNfs, dDtColeta, cHrColeta,lJob,_nContCmp)
    Local _NroRom    := GFE50NRROM()
    Local y          := 0
    Local aAreaGUU   := GUU->( GetArea() )
    Local aAreaGV3   := GV3->( GetArea() )
    Local aAreaGW1   := GW1->( GetArea() )
    Local aAreaGV5   := GV5->( GetArea() )
    Local aAreaGWU   := GWU->( GetArea() )

     Default lJob := .F.

    If !Empty( __cMsgLoc )
        GrvLog(__cArqLog, "Romaneio: " + _NroRom + __cMsgLoc )
    EndIf

    DBSELECTAREA("GWN")
    RECLOCK("GWN",.T.)
    GWN->GWN_FILIAL  := FWxFilial("GWN") //Filial
    GWN->GWN_NRROM   := _NroRom          //Numero do Romaneio
    GWN->GWN_CDTPOP  := _tp_ope_01       //Tipo de Operação 
    GWN->GWN_CDCLFR  := _modal_01       //Class Frete
    GWN->GWN_DISTAN  := _percu_01        //Percurso
    GWN->GWN_CDTPVC  := cCodTpVei       //Tipo de Veiculo
    GWN->GWN_CDTRP   := _codtra_01       //Código da Transportadora      
    GWN->GWN_CDMTR   := cCodMot         //Cpf Motorista        
    GWN->GWN_PLACAD  := _placa_01        //Placa do Veiculo              
    GWN->GWN_DTIMPL  := dDtColeta       //Data de Criação 
    GWN->GWN_HRIMPL  := "00:00:00"      //Hora de Criação
    GWN->GWN_DTSAI   := dDtColeta
    GWN->GWN_HRSAI   := cHrColeta
    GWN->GWN_CALC    := "2"              //Situação do Calculo - Na criação é = "2" (Nao Calculado)
    GWN->GWN_ORI     := "4"              //Origem - 1=Usuario; 2=ERP; 3=Outros; 4=Sistema
    GWN->GWN_SIT     := "1"              //Situação - "1" (Digitado)						
    GWN->GWN_USUIMP  := cUserName   		 //Usuário   
    GWN->GWN_BLOQPF  := _emitpf_01        //Bloq PF 
    GWN->GWN_XCDDES  := IIF( _tp_ope_01 = "LOCACAO", "Varios", GW1->GW1_CDDEST )
    GWN->GWN_XCONT   := _nContCmp
    GWN->(MSUNLOCK())

    //Troca o status do Romaneio para embarcado
    For y := 1 to Len(aChvNfs)
        IF GW1->( DBSEEK( aChvNfs[y][1] ) )
            If  RECLOCK("GW1",.F.)
                GW1->GW1_NRROM := _NroRom
                GW1->GW1_SIT   := "4" //Embarcado
                GW1->( MsUnLock() )
            Endif

            IF GWU->( DBSEEK( GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC ) )
                If  RECLOCK("GWU",.F.)
                    GWU->GWU_CDCLFR := _modal_01
                    GWU->GWU_CDTPOP := _tp_ope_01
                    GWU->GWU_CDTRP  := _codtra_01
                    GWU->( MsUnLock() )
                Endif
            ENDIF

        ENDIF
    Next y

    //--Libera Romaneio
    GFEA050LIB(.T.,,dDtColeta, cHrColeta ,.T.)

    //--Efetua Calculo do frete
    if lJob .or. __lCalcul
        GFE050CALC(,,,,.T.,)
    else
        GFE050CALC(,,,,.F.,)
    EndIf

    RestArea( aAreaGUU )
    RestArea( aAreaGV3 )
    RestArea( aAreaGW1 )
    RestArea( aAreaGV5 )
    RestArea( aAreaGWU )

    If !Empty(__cChvCTE)
        MsgInfo("Romaneio: " + cValToChar(_NroRom) + " Incluido com sucesso!")
    EndIf

Return cValToChar(_NroRom)

/*
======================================================================================
Programa.:              zCadMot
Autor....:              CAOA - Fagner Barreto
Data.....:              18/04/2022
Descricao / Objetivo:   Cadastro de motoristas via execauto
======================================================================================
*/
Static Function zCadMot( cCpfMot, cNomeMot)
    Local aCab      := {}
    Local cNrMoto   := GETSXENUM("DA4","DA4_COD")
    Local cCodMot   := ""
    
    Private lMSErroAuto := .F.

    Aadd(aCab,{"DA4_COD"    ,cNrMoto                                        ,NIL })   //-- Código do motorista
    Aadd(aCab,{"DA4_NOME"   ,cNomeMot                                       ,NIL })   //-- Nome do motorista
    Aadd(aCab,{"DA4_CGC"    ,cCpfMot                                        ,NIL })   //-- CPF
    Aadd(aCab,{"DA4_NREDUZ" ,SubStr( cNomeMot, 1, At(" ", cNomeMot) - 1)    ,NIL })   //-- Nome reduzido
    
    //--Função para ordenar um vetor conforme o dicionário para uso em rotinas de MSExecAuto
    aCab := FWVetByDic( aCab, "DA4") 

    MsExecAuto({|x,y| OMSA040(x,y)},aCab,3)
    
    If lMSErroAuto   
        DA4->( RollBackSx8() )
        //MostraErro()
    Else
        DA4->( ConfirmSx8() )

        If GUU->(DBSEEK(xFilial("GUU")+_mot_cpf))
            cCodMot := GUU->GUU_CDMTR
        EndIf

    EndIf
        
Return cCodMot

/*
=====================================================================================
Programa.:              GrvLog
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              
Descricao / Objetivo:   Gravação de log de erro
Doc. Origem:            
Solicitante:            
=====================================================================================
*/
Static Function GrvLog( cArq , cLog )
    Local nHandle 	    := 0
    Local cDrive		:= ""
    Local cDir			:= ""
    Local cNomeArq		:= ""
    Local cExt			:= ""

    cArq := StrTran(Alltrim(cArq)," ","")

    If !File( cArq )

        // -- Tratamento para diretorios
        
        SplitPath( cArq , @cDrive, @cDir, @cNomeArq, @cExt )
        MontaDir(cDir)

        nHandle := FCreate( cArq )
        FClose( nHandle )	

    Endif

    If File( cArq )

        nHandle := FOpen( cArq, 2 )
        FSeek ( nHandle, 0, 2 )			// Posiciona no final do arquivo.
        
        FWrite( nHandle, cLog + CRLF, Len(cLog) + 2 )
        
        FClose( nHandle )
        
    EndIf

Return Nil

//Layout do Json
/*
{
   "id_coleta":"4750597",
   "datahora_coleta":"",
   "numero":"487730",
   "data":"15/10/2021",
   "cnpj_remetente":"56.330.541/0001-32",
   "remetente":"ESTAMPARIA PAULISTA IND.E COM. LTDA -",
   "cnpj_destnatario":"03.471.344/0001-77",
   "destinatario":"CAOA MONTADORA DE VEICULOS S/A",
   "cnpj_transportadora":"10.213.051/0013-99",
   "transportadora":"RG LOG LOGISTICA E TRANSPORTE LTDA.",
   "notas_fiscais":"17735,17734",
   "numero_ordem":"",
   "qtd_volumes":49,
   "peso_cubado":2.860,
   "valor_mercadoria":7028.42,
   "previsao_entrega":"",
   "data_entrega":"",
   "entregue_para":"",
   "vlr_frete_peso":719.71,
   "frete_valor":29.52,
   "vlr_pedagio":19.62,
   "vlr_gris":7.03,
   "vlr_tx_redespacho":19.08,
   "vlr_icms":59.84,
   "vlr_total":854.80,
   "autorizado":"S",
   "status":"CADASTRADO",
   "Notas":[
      {
                 02 = cUF - Código da UF do emitente do Documento Fiscal;
                 04 = AAMM - Ano e Mês de emissão da NF-e;
                 14 = CNPJ - CNPJ do emitente;
                 02 = mod - Modelo do Documento Fiscal;
                 03 = serie - Série do Documento Fiscal;
                 09 = nNF - Número do Documento Fiscal;
                 01 = tpEmis – forma de emissão da NF-e;
                 08 = cNF - Código Numérico que compõe a Chave de Acesso;
                 01 = cDV - Dígito Verificador da Chave de Acesso.

                       UF AAMM CNPJ EMITENTE  MOD  SER   NF        TP  CODIGO    DV
         "ChaveDanfe":"35 2110 56330541000132 55   001   000017735 1   50947827  9"
      },
      {
                 02 = cUF - Código da UF do emitente do Documento Fiscal;
                 04 = AAMM - Ano e Mês de emissão da NF-e;
                 14 = CNPJ - CNPJ do emitente;
                 02 = mod - Modelo do Documento Fiscal;
                 03 = serie - Série do Documento Fiscal;
                 09 = nNF - Número do Documento Fiscal;
                 01 = tpEmis – forma de emissão da NF-e;
                 08 = cNF - Código Numérico que compõe a Chave de Acesso;
                 01 = cDV - Dígito Verificador da Chave de Acesso.

                       UF AAMM CNPJ EMITENTE  MOD  SER   NF        TP  CODIGO    DV
         "ChaveDanfe":"35 2110 56330541000132 55   001   000017734 1   69057091  0"
      }
   ]
}
*/
