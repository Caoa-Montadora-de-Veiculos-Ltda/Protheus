#Include "PROTHEUS.CH"
#Include "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FILEIO.CH"
#INCLUDE "XMLXFUN.CH"

#DEFINE DIRLIDO "LIDO\"
#DEFINE DIRERRO "ERRO\"
#DEFINE DIRLIDOLNX "lido\"
#DEFINE DIRERROLNX "erro\"

/*
===========================================================================================
Programa.:              ZGFEF002
Autor....:              CAOA - Fagner Barreto
Data.....:              03/01/2022
Descricao / Objetivo:   Realiza a geração de documento de carga para documentos em que a 
                        contratação do frete foi realizada por terceiros
===========================================================================================
*/
User Function ZGFEF002()
    Private __cMark   := GetMark()

	If IsBlind()
		Conout( "Chamada Job ZGFEF002 | " + Time() )
        
        //--Chamada da importação dos xmls
        U_zImport()

        //--Chamada da geração do doc. carga
        U_zProcAll()

	Else
		
        //--Chamada de tela
        zMontaBrw()

	EndIf

Return

/*
===========================================================================================
Programa.:              zMontaBrw
Autor....:              CAOA - Fagner Barreto
Data.....:              03/01/2022
Descricao / Objetivo:   Markbrowse para seleção dos registros para gerar doc carga    
===========================================================================================
*/
Static Function zMontaBrw()
    Private oMarkBrw  := Nil

    oMarkBrw := FWMarkBrowse():New()
    oMarkBrw:SetDescription("Doc. Carga Triangulação")
    oMarkBrw:SetAlias("ZA3")
    oMarkBrw:SetFieldMark( "ZA3_OK" )
    oMarkBrw:SetMark( __cMark, "ZA3", "ZA3_OK" )
    oMarkBrw:SetMenuDef('ZGFEF002')
    oMarkBrw:SetAllMark({|| zMarkAll( oMarkBrw, __cMark, "ZA3" ) }) // Ação ao marcar tudo
    oMarkBrw:AddLegend("ZA3_EDISIT == '1'", "BLUE"   	, "Importado"          ) // "Importado"
	oMarkBrw:AddLegend("ZA3_EDISIT == '2'", "YELLOW"	, "Importado com erro" ) // "Importado com erro"
	oMarkBrw:AddLegend("ZA3_EDISIT == '3'", "RED"    	, "Rejeitado"          ) // "Rejeitado"
	oMarkBrw:AddLegend("ZA3_EDISIT == '4'", "GREEN"	    , "Processado"         ) // "Processado"
    oMarkBrw:DisableReport()
    oMarkBrw:Activate()

    oMarkBrw:DeActivate()

Return

/*
===========================================================================================
Programa.:              MenuDef
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   
===========================================================================================
*/
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE "Importar"          ACTION "U_zImport()"       OPERATION 3 ACCESS 0 // "Importar"
	ADD OPTION aRotina TITLE "Alterar"           ACTION "VIEWDEF.ZGFEF002"  OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE "Visualizar"        ACTION "VIEWDEF.ZGFEF002"  OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE "Processar"         ACTION "U_zProcMark()"     OPERATION 4 ACCESS 0 // "Processar"
    ADD OPTION aRotina TITLE "Processar todos"   ACTION "U_zProcAll()"      OPERATION 4 ACCESS 0 // "Processar todos"
	ADD OPTION aRotina TITLE "Excluir"           ACTION "VIEWDEF.ZGFEF002"  OPERATION 5 ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE "Exc. Selecionados" ACTION "U_zExclMark()"     OPERATION 5 ACCESS 0 // "Excluir Todos"

Return aRotina

/*
===========================================================================================
Programa.:              ModelDef
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   
===========================================================================================
*/
Static Function ModelDef()
	Local oModel
	Local oStructZA3 := FWFormStruct(1, "ZA3")
	Local oStructZA4 := FWFormStruct(1, "ZA4")
	Local oStructZA5 := FWFormStruct(1, "ZA5")
	Local oStructZA6 := FWFormStruct(1, "ZA6")

	oModel := MPFormModel():New("ZF002MDL",/*bPre*/, {|oModel| zVldModel(oModel) },/*bCommit*/,/*bCancel*/) 

	oModel:AddFields("ZGFEF002_ZA3", Nil, oStructZA3, /*bPre*/ ,/**/,/*bLoad*/)
	oModel:SetPrimaryKey({"ZA3_FILIAL" , "ZA3_CDTPDC" , "ZA3_EMISDC" , "ZA3_SERDC" , "ZA3_NRDC" })

	oModel:AddGrid("ZGFEF002_ZA4","ZGFEF002_ZA3", oStructZA4,/*bLinePre*/,/*{|oMod| If(IsInCallStack("GFEA044"),If(lCopy,.T.,GF44_ZA4PS(oMod)),GF44_ZA4PS(oMod))}*/,,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("ZGFEF002_ZA4",{{"ZA4_FILIAL","xFilial('ZA4')"},{"ZA4_CDTPDC","ZA3_CDTPDC"},{"ZA4_EMISDC","ZA3_EMISDC"},{"ZA4_SERDC","ZA3_SERDC"},{"ZA4_NRDC","ZA3_NRDC"}},"ZA4_FILIAL+ZA4_CDTPDC+ZA4_EMISDC+ZA4_SERDC+ZA4_NRDC+ZA4_SEQ")
	
    oModelZA4 = oModel:GetModel("ZGFEF002_ZA4")
	oModelZA4:SetUniqueLine({"ZA4_SEQ"})
	oModelZA4:SetDescription("dos itens do documento de carga ")

	oModel:AddGrid("ZGFEF002_ZA5","ZGFEF002_ZA3", oStructZA5,/*bLinePre*/,/*{|oMod| GFE44PSZA5(oMod)}*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("ZGFEF002_ZA5",{{"ZA5_FILIAL","xFilial('ZA5')"},{"ZA5_CDTPDC","ZA3_CDTPDC"},{"ZA5_EMISDC","ZA3_EMISDC"},{"ZA5_SERDC","ZA3_SERDC"},{"ZA5_NRDC","ZA3_NRDC"}},"ZA5_FILIAL+ZA5_CDTPDC+ZA5_EMISDC+ZA5_SERDC+ZA5_NRDC")
	oModelZA5 = oModel:GetModel("ZGFEF002_ZA5")
	oModelZA5:SetUniqueLine({"ZA5_CDUNIT"})
	oModelZA5:SetDescription("Unitizadores")
	oModelZA5:SetDelAllLine(.T.)

	oModel:SetOptional("ZGFEF002_ZA5", .T. )

	oModel:AddGrid("ZGFEF002_ZA6","ZGFEF002_ZA3", oStructZA6, ,/*{|oMod| If(IsInCallStack("GFEA044"), If(lCopy,.T.,GF44_ZA6PS(oMod)), GF44_ZA6PS(oMod))}*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("ZGFEF002_ZA6",{{"ZA6_FILIAL","xFilial('ZA6')"},{"ZA6_CDTPDC","ZA3_CDTPDC"},{"ZA6_EMISDC","ZA3_EMISDC"},{"ZA6_SERDC","ZA3_SERDC"},{"ZA6_NRDC","ZA3_NRDC"}},"ZA6_FILIAL+ZA6_CDTPDC+ZA6_EMISDC+ZA6_SERDC+ZA6_NRDC")
	oModelZA6 = oModel:GetModel("ZGFEF002_ZA6")
	oModelZA6:SetUniqueLine({"ZA6_SEQ"})
	oModelZA6:SetDescription("Trechos do documento de carga")

Return oModel

/*
===========================================================================================
Programa.:              ViewDef
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   
===========================================================================================
*/
Static Function ViewDef()
	Local oModel 		:= ModelDef() //FWLoadModel("ZF002MDL")
	Local oView 		:= Nil
	Local oStructZA3	:= FWFormStruct(2,"ZA3")
	Local oStructZA4 	:= FWFormStruct(2,"ZA4")
	Local oStructZA5 	:= FWFormStruct(2,"ZA5")
	Local oStructZA6 	:= FWFormStruct(2,"ZA6")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "ZGFEF002_ZA3" , oStructZA3 )

	oView:AddGrid( "ZGFEF002_ZA4" , oStructZA4)
	oStructZA4:RemoveField("ZA4_FILIAL")
	oStructZA4:RemoveField("ZA4_CDTPDC")
	oStructZA4:RemoveField("ZA4_EMISDC")
	oStructZA4:RemoveField("ZA4_SERDC")
	oStructZA4:RemoveField("ZA4_NRDC")

	oView:AddIncrementField("ZGFEF002_ZA4","ZA4_SEQ")

	oView:AddGrid( "ZGFEF002_ZA5" , oStructZA5)
	oStructZA5:RemoveField("ZA5_FILIAL")
	oStructZA5:RemoveField("ZA5_CDTPDC")
	oStructZA5:RemoveField("ZA5_EMISDC")
	oStructZA5:RemoveField("ZA5_SERDC")
	oStructZA5:RemoveField("ZA5_NRDC")

	oView:AddGrid( "ZGFEF002_ZA6" , oStructZA6)
	oStructZA6:RemoveField("ZA6_FILIAL")
	oStructZA6:RemoveField("ZA6_CDTPDC")
	oStructZA6:RemoveField("ZA6_EMISDC")
	oStructZA6:RemoveField("ZA6_SERDC")
	oStructZA6:RemoveField("ZA6_NRDC")

	oView:CreateHorizontalBox( "MASTER" , 55)
	oView:CreateHorizontalBox( "DETAIL" , 45)

	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01","Itens")
	oView:AddSheet("IDFOLDER","IDSHEET02","Unitizadores")
	oView:AddSheet("IDFOLDER","IDSHEET03","Trechos")

	oView:CreateHorizontalBox( "DETAIL_ZA4"  , 100,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "DETAIL_ZA5"  , 100,,,"IDFOLDER","IDSHEET02" )
	oView:CreateHorizontalBox( "DETAIL_ZA6"  , 100,,,"IDFOLDER","IDSHEET03" )

	oView:SetOwnerView( "ZGFEF002_ZA3" , "MASTER" )
	oView:SetOwnerView( "ZGFEF002_ZA4" , "DETAIL_ZA4" )
	oView:SetOwnerView( "ZGFEF002_ZA5" , "DETAIL_ZA5" )
	oView:SetOwnerView( "ZGFEF002_ZA6" , "DETAIL_ZA6" )

	oView:AddIncrementField("ZGFEF002_ZA6","ZA6_SEQ")

Return oView

/*
===========================================================================================
Programa.:              zImport
Autor....:              CAOA - Fagner Barreto
Data.....:              03/01/2022
Descricao / Objetivo:   Aciona a importação dos arquivos XML
===========================================================================================
*/
//Static Function zImport()
User Function zImport()

    If IsBlind()
		zImpArqXML()
	Else
		Processa({|| zImpArqXML()},"Importando arquivos", "")
	EndIf

Return

/*
===========================================================================================
Programa.:              zProcAll
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   Processa todos os registros independente de marcações 
===========================================================================================
*/
//Static Function zProcAll()
User Function zProcAll()
    Local cAliasQry := GetNextAlias()
    Local cWhere    := ""

    Private __cErrDoc := ""

    If IsBlind()
        //--Se via Job processa somente os arquivos importados, isso porque arquivos com erro serão tratados manualmente
		cWhere :=  " ZA3.ZA3_EDISIT = '1'" 
	Else
        //--Se via browse processa todos os arquivos com exceção dos ja processados
		cWhere :=  " ZA3.ZA3_EDISIT <> '4'" 
	EndIf
	
    cWhere := "%"+cWhere+"%"

    BeginSql Alias cAliasQry
        SELECT ZA3_CDTPDC, ZA3_EMISDC, ZA3_SERDC, ZA3_NRDC, R_E_C_N_O_ AS RECZA3
        FROM %Table:ZA3% ZA3
        WHERE ZA3.ZA3_FILIAL = %xFilial:ZA3%
        AND %Exp:cWhere%  
        AND ZA3.%NotDel%
    EndSql

    (cAliasQry)->( DbGoTop() )
    If (cAliasQry)->( !Eof() )
        While (cAliasQry)->( !Eof() )
            If !( zCargaDoc((cAliasQry)->ZA3_CDTPDC, (cAliasQry)->ZA3_EMISDC, (cAliasQry)->ZA3_SERDC, (cAliasQry)->ZA3_NRDC) )

                DbGoTo( (cAliasQry)->RECZA3 )
                RecLock("ZA3", .F.)
                ZA3->ZA3_EDISIT := '3'
                ZA3->ZA3_EDIMSG := __cErrDoc
                ZA3->( MsUnlock() )
            
            Else

                DbGoTo( (cAliasQry)->RECZA3 )
                RecLock("ZA3", .F.)
                ZA3->ZA3_EDISIT := '4'
                ZA3->ZA3_EDIMSG := __cErrDoc
                ZA3->( MsUnlock() )

            EndIf

            (cAliasQry)->( DbSkip() )
        EndDo
    EndIf

    (cAliasQry)->( DbCloseArea() )

Return

/*
===========================================================================================
Programa.:              zImpArqXML
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   Importa arquivo XML e aciona a gravação nas tabelas auxiliares
===========================================================================================
*/
Static Function zImpArqXML()
    Local lContinua := .T.
    Local lIsLinux  := IsSrvUnix()
    Local aErros    := {}
    Local cDirXML   := ""
    Local cDirLido  := ""
    Local cDirErro  := ""
    Local nCont     := 0
    Local oXML      := Nil

    //Verifica e cria, se necessÃ¡rio, a estrutura de diretÃ³rios
    cDirXML := zRemBarra( AllTrim( GetNewPar("CMV_XMLTRG", "XMLTRIANG\") ) )

    If Empty(cDirXML) .And. IsBlind()
        Help( ,, "CaoaTec",, "Nao foi especificado um diretorio para importacao no parametro " , 1, 0)
        lContinua := .F.
    EndIF

    If lContinua
        cDirLido  := cDirXML + If(lIsLinux, DIRLIDOLNX, DIRLIDO)
        cDirErro  := cDirXML + If(lIsLinux, DIRERROLNX, DIRERRO)

        If !zCriaArq(cDirXML)
            lContinua := .F.
        EndIf
        If !zCriaArq(cDirLido)
            lcontinua := .F.
        EndIf
        If !zCriaArq(cDirErro)
            lContinua := .F.
        EndIf

        If lContinua
            aDirImpor := DIRECTORY(Alltrim(cDirXML) + "*.XML" ) //--Retorna xmls contidos no diretorio
            If Len(aDirImpor) < 1
                If !IsBlind()
                    Help( ,, "CaoaTec",, "Nao foram encontrados arquivos XML no diretorio " + cDirXML + "." , 1, 0)
                EndIf
                lContinua := .F.
            Endif
        EndIf
    EndIf

	If lContinua
		cDirXML  := AllTrim(cDirXML)
		cDirLido := AllTrim(cDirLido)
		cDirErro := AllTrim(cDirErro)

		If !IsBlind()
			ProcRegua(0)
		EndIf

		For nCont := 1 to Len(aDirImpor)
			cXMLArq := cDirXML + aDirImpor[nCont][1]

            oXML := Nil

			//SÃ³ retornarÃ¡ falso quando o arquivo for invÃ¡lido
			If zParserXML(cXMLArq,@aErros,cDirLido,cDirErro, @oXML)

                If zGeraAux(oXML, cXMLArq)

                    zMoveArq(cXMLArq, cDirLido + aDirImpor[nCont][1])

                Else

                    zMoveArq(cXMLArq, cDirErro + aDirImpor[nCont][1])

                EndIf

            Else
                zMoveArq(cXMLArq, cDirErro + aDirImpor[nCont][1])
			EndIf

			If !IsBlind()
				IncProc(aDirImpor[nCont][1])
			EndIf

		Next nCont

		If !IsBlind() .And. !Empty(aErros)
        
			For nCont := 1 To Len(aErros)
                Help( ,, "CaoaTec",, "Arquivo: " + aErros[nCont][1] + CRLF + aErros[nCont][2] , 1, 0)
				//GFEResult:AddErro(Replicate("-",50) + CRLF)
			Next nCont

            Help( ,, "CaoaTec",, "Ocorreram erros na importaÃ§Ã£o de um ou mais arquivos. PossÃ­veis motivos:" + CRLF + "- Erros nos arquivos XML;" + CRLF + "- Arquivos incompatÃ­veis com o formato XML;" + CRLF + "- Chave de CTE jÃ¡ importada/processada." + CRLF , 1, 0)
			//GFEResult:Show("ImportaÃ§Ã£o de arquivos Ct-e", "Arquivos", "Erros", "Clique no botÃ£o 'Erros' para mais detalhes.")
		EndIf
	EndIf
Return

/*
===========================================================================================
Programa.:              zCriaArq
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   Verificar se diretorio existe, se não existir, efetua a criação  
===========================================================================================
*/
Static Function zCriaArq(cDir)
Local lRet := .T.

	If !ExistDir(cDir)
        //--Cria diretorio
		If MakeDir(cDir) <> 0
			//	Help( ,, 'HELP',, "NÃ£o foi possÃ­vel criar diretÃ³rio " + cDir + " (Erro " + cValToChar(FError()) + ").",1,0)
            Help( ,, "CaoaTec",, "Nao foi possivel criar diretorio "  + cDir + " (Erro " + cValToChar(FError()) + ")." , 1, 0)
			lRet := .F.
		EndIf
	EndIf
Return lRet

/*
===========================================================================================
Programa.:              zMoveArq
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   Move arquivos entre pastas  
===========================================================================================
*/
Static Function zMoveArq(cOrigem, cDestino)
    Local nFError := 1

	Copy File &(cOrigem) To &(cDestino)

	nFError := FError()
	If nFError == nil
		nFError := 1
	EndIf

	If nFError <> 0
        Conout('Erro ao copiar arquivo (' + Alltrim(STR(nFError)) + ') ')
	Else

		If File(cDestino)
            Conout('Arquivo ' + cDestino + ' encontrado.')
		Else
            Conout('Arquivo ' + cDestino + ' não encontrado.')
		EndIf

		If FErase(cOrigem) == -1
            Conout('Erro ao excluir arquivo (' + STR(FERROR()) + ') ' + GFERetFError(FError()) + '.')
		Else
            Conout('Exclusão efetuada com sucesso.')
		EndIf

	EndIf

Return

/*
===========================================================================================
Programa.:              zParserXML
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   Realiza parser no arquivo XML  
===========================================================================================
*/
Static Function zParserXML(cXMLFile,aErros,cDirLido,cDirErro,oXML)
Local lRet      := .T.
Local cError    := ""
Local cWarning  := ""
Local nHandle   := 0

Default aErros    := {}
Default oXML      := Nil
Private cBuffer   := ''
Private nSize     := 0

	nHandle := FOpen(cXMLFile,FO_READ+FO_SHARED) //Parametros: Arquivo, Leitura - Escrita, Servidor
	If nHandle < 0
		cError := str(FError())
		aAdd(aErros,{cXMLFile,"Erro ao abrir arquivo: ( " + cError + CHR(13)+CHR(10), ")" + GFERetFError(FError())})
		lRet := .F.
	EndIf

	If lRet
		nSize := FSeek(nHandle,FS_SET,FS_END)
		FSeek(nHandle,0)
		FRead(nHandle,@cBuffer,nSize)

		oXML  := XmlParser( cBuffer , "_", @cError, @cWarning)
		FClose(nHandle)
		nHandle   := -1

		If ValType(XmlChildEx(oXML,"_NFEPROC")) == "O"
			
            If !(ValType(XmlChildEx(oXML:_nfeProc:_NFe:_infNfe:_Transp,"_MODFRETE")) == "O")
                
				cError := 'Esta rotina só permite a importação de NFe com modalidade de frete igual a 2 = Contratação do Frete por conta de Terceiros'

				aAdd(aErros,{cXMLFile,"Erro >> Arquivo: " + cError + CHR(13)+CHR(10), ""})
				lRet := .F.
			EndIf
        
        Else
            Help( ,, "CaoaTec",, 'Esta rotina só permite a importação de NF-e' , 1, 0)
            lRet := .F.
		EndIf
		
	EndIf

Return lRet

/*
===========================================================================================
Programa.:              zGeraAux
Autor....:              CAOA - Fagner Barreto
Data.....:              03/01/2022
Descricao / Objetivo:   Leitura do arquivo XML e gravação das tabelas auxiliares
===========================================================================================
*/
Static Function zGeraAux(oXML, cXMLArq)
    Local lRet          := .T.
    Local nI            := 0
    Local cCodEmit      := ""
    Local cCodDest      := ""
    Local cCodTransp    := ""
    Local nQtdVol       := 0
    Local nSomaVol      := 0
    Local cAliasQry     := Nil
    Local dDtEmis       := ctod('  /  /  ')
    Local nValItem      := 0
    Local nValICMS      := 0
    Local nValIPI       := 0
    Local nValFCP       := 0
    Local cCNPJTrp      := ""

    Private cMsgErro    := ""

    If oXML:_nfeProc:_NFe:_infNFe:_Transp:_modFrete:TEXT == "2" //-- 2 --> Contratação do Frete por conta de Terceiros

        //--Ativação das workareas
        GU3->( DbSetOrder(11) )
        ZA3->( DbSetOrder(1) )
        ZA4->( DbSetOrder(1) )
        ZA5->( DbSetOrder(1) )
        ZA6->( DbSetOrder(1) )
        
        If GU3->( DbSeek( FWxFilial("GU3") + oXML:_nfeProc:_NFe:_infNFe:_emit:_CNPJ:TEXT ))
            cCodEmit := GU3->GU3_CDEMIT

            //--Alteração necessaria para inclusão do documento de carga
            If GU3->GU3_EMFIL <> '1'
                RecLock("GU3", .F.)
                GU3->GU3_EMFIL := '1'
                GU3->( MsUnLock() )
            EndIf
        Else

            //--Efetua cadastro do fornecedor
            If zIncluiSA2(oXML)

                If GU3->( DbSeek( FWxFilial("GU3") + oXML:_nfeProc:_NFe:_infNFe:_emit:_CNPJ:TEXT ))
                    cCodEmit := GU3->GU3_CDEMIT

                    //--Alteração necessaria para inclusão do documento de carga
                    If GU3->GU3_EMFIL <> '1'
                        RecLock("GU3", .F.)
                        GU3->GU3_EMFIL := '1'
                        GU3->( MsUnLock() )
                    EndIf

                Else
                    cMsgErro += "Emitente CNPJ: " + oXML:_nfeProc:_NFe:_infNFe:_emit:_CNPJ:TEXT + " Não localizado no cadastro de emitentes!"
                    //lRet := .F.
                EndIf

            EndIf

        EndIf


        If GU3->( DbSeek( FWxFilial("GU3") + oXML:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:TEXT ))
            cCodDest := GU3->GU3_CDEMIT
        Else
            
            //--Efetua cadastro de cliente
            If zIncluiSA1(oXML)

                If GU3->( DbSeek( FWxFilial("GU3") + oXML:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:TEXT ))
                    cCodDest := GU3->GU3_CDEMIT 
                Else
                    cMsgErro += "Destinatario CNPJ: " + oXML:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:TEXT + " Não localizado no cadastro de emitentes!"
                    //lRet := .F.
                EndIf

            EndIf

        EndIf

        If ValType( XmlChildEx(oXML:_nfeProc:_NFe:_infNfe:_transp,"_TRANSPORTA") ) == "O"
            //--Se não constar CNPJ da transportadora, utiliza o da RG LOG
            cCNPJTrp  := IIF(   Empty( oXML:_nfeProc:_NFe:_infNFe:_transp:_transporta:_CNPJ:TEXT ),;
                                "10213051001399", oXML:_nfeProc:_NFe:_infNFe:_transp:_transporta:_CNPJ:TEXT )

        Else
            cMsgErro += "Transportador não informado no arquivo XML!"
        EndIf

        cAliasQry := GetNextAlias()
        BeginSql Alias cAliasQry
            SELECT GU3_CDEMIT
            FROM %Table:GU3% GU3
            WHERE GU3.GU3_FILIAL = %xFilial:GU3%
            AND GU3.GU3_IDFED = %Exp:cCNPJTrp%
            AND GU3.GU3_TRANSP = '1'
            AND GU3.%NotDel%
        EndSql

        If (cAliasQry)->( !Eof() )
            cCodTransp := (cAliasQry)->GU3_CDEMIT
        Else
            cMsgErro += "Transportadora CNPJ: " + cCNPJTrp + " Não localizada no cadastro de emitentes!"
        EndIf

        (cAliasQry)->( DbCloseArea() )

        cNota  := PadL( oXML:_nfeProc:_NFe:_InfNfe:_ide:_nNF:TEXT, TamSX3("F2_DOC")[1], "0" )
        cSerie := oXML:_nfeProc:_NFe:_InfNfe:_ide:_serie:TEXT

        cAliasQry := GetNextAlias()
        BeginSql Alias cAliasQry
            SELECT 1
            FROM %Table:ZA3% ZA3
            WHERE ZA3.ZA3_FILIAL = %xFilial:ZA3%
            AND ZA3.ZA3_CDTPDC = %Exp:'TRG'% 
            AND ZA3.ZA3_EMISDC = %Exp:cCodEmit% 
            AND ZA3.ZA3_SERDC = %Exp:cSerie% 
            AND ZA3.ZA3_NRDC = %Exp:cNota% 
            AND ZA3.%NotDel%
        EndSql

        (cAliasQry)->( DbGoTop() )
        If (cAliasQry)->( Eof() )

            Begin Transaction

                if ValType(oXML:_nfeProc:_NFe:_infNFe:_transp:_vol) == 'A'

                    For nI := 1 to Len(oXML:_nfeProc:_NFe:_infNFe:_transp:_vol)

                        If ValType(XmlChildEx(oXML:_nfeProc:_NFe:_infNFe:_transp:_vol[nI],"_qVol")) == "O"
                            nQtdVol := Val(oXML:_nfeProc:_NFe:_infNFe:_transp:_vol[nI]:_qVol:TEXT)
                        Else
                            nQtdVol := 1
                        EndIf

                        //--Similar a GWB - UNITIZADORES DO DOCTO DE CARGA
                        RecLock("ZA5", .T.)
                        ZA5->ZA5_FILIAL :=  FWxFilial("ZA5")
                        ZA5->ZA5_CDTPDC :=  'TRG'                                                                                                       
                        ZA5->ZA5_EMISDC :=  cCodEmit            
                        ZA5->ZA5_SERDC  :=  cSerie          
                        ZA5->ZA5_NRDC   :=  cNota           
                        ZA5->ZA5_CDUNIT :=  'VOLUME'          
                        ZA5->ZA5_QTDE   :=  nQtdVol
                        ZA5->( MsUnLock() )

                        nSomaVol := nSomaVol + nQtdVol

                    Next

                Else

                    If ValType(XmlChildEx(oXML:_nfeProc:_NFe:_infNFe:_transp:_vol,"_qVol")) == "O"
                        nQtdVol := Val(oXML:_nfeProc:_NFe:_infNFe:_transp:_vol:_qVol:TEXT)
                    Else
                        nQtdVol := 1
                    EndIf

                    //--Similar a GWB - UNITIZADORES DO DOCTO DE CARGA
                    RecLock("ZA5", .T.)
                    ZA5->ZA5_FILIAL := FWxFilial("ZA5")
                    ZA5->ZA5_CDTPDC := 'TRG'                                                                                                       
                    ZA5->ZA5_EMISDC := cCodEmit            
                    ZA5->ZA5_SERDC  := cSerie          
                    ZA5->ZA5_NRDC   := cNota           
                    ZA5->ZA5_CDUNIT := 'VOLUME'         
                    ZA5->ZA5_QTDE   := nQtdVol
                    ZA5->( MsUnLock() )

                    nSomaVol := nSomaVol + nQtdVol

                EndIf

                if ValType(oXML:_nfeProc:_NFe:_InfNfe:_Det) == 'A'

                    For nI := 1 to Len(oXML:_nfeProc:_NFe:_InfNfe:_Det)

                        nValItem    := 0
                        nValICMS    := 0
                        nValIPI     := 0
                        nValFCP     := 0

                        If ValType(XmlChildEx(oXML:_nfeProc:_NFe:_InfNfe:_Det[nI]:_imposto,"_ICMS")) == "O"
                            If ValType(XmlChildEx(oXML:_nfeProc:_NFe:_InfNfe:_Det[nI]:_imposto:_ICMS,"_ICMS10")) == "O"
                                nValICMS := Val(oXML:_nfeProc:_NFe:_InfNfe:_Det[nI]:_imposto:_ICMS:_ICMS10:_vICMSST:TEXT)
                                If ValType(XmlChildEx(oXML:_nfeProc:_NFe:_InfNfe:_Det[nI]:_imposto:_ICMS:_ICMS10,"_VFCPST")) == "O"
                                    nValFCP  := Val(oXML:_nfeProc:_NFe:_InfNfe:_Det[nI]:_imposto:_ICMS:_ICMS10:_vFCPST:TEXT)
                                EndIf
                            EndIf
                        EndIf

                        If ValType(XmlChildEx(oXML:_nfeProc:_NFe:_InfNfe:_Det[nI]:_imposto,"_IPI")) == "O"
                            nValIPI := Val(oXML:_nfeProc:_NFe:_InfNfe:_Det[nI]:_imposto:_IPI:_IPITrib:_vIPI:TEXT)
                        EndIf

                        nValItem := Val(oXML:_nfeProc:_NFe:_InfNfe:_Det[nI]:_prod:_vProd:TEXT)

                        //--Similar a GW8 - ITENS DO DOCUMENTO DE CARGA
                        RecLock("ZA4", .T.)
                        ZA4->ZA4_FILIAL := FWxFilial("ZA4")                                                 
                        ZA4->ZA4_CDTPDC := 'TRG'                                                                                              
                        ZA4->ZA4_EMISDC := cCodEmit                                               
                        ZA4->ZA4_SERDC  := cSerie          
                        ZA4->ZA4_NRDC   := cNota           
                        ZA4->ZA4_SEQ    := strzero(nI, 5)           
                        ZA4->ZA4_ITEM   := oXML:_nfeProc:_NFe:_InfNfe:_Det[nI]:_prod:_cProd:TEXT                  
                        ZA4->ZA4_DSITEM := oXML:_nfeProc:_NFe:_InfNfe:_Det[nI]:_prod:_xProd:TEXT     
                        ZA4->ZA4_QTDE   := Val(oXML:_nfeProc:_NFe:_InfNfe:_Det[nI]:_prod:_qCom:TEXT)
                        ZA4->ZA4_VALOR  := nValItem + nValICMS + nValIPI + nValFCP
                        //ZA4->ZA4_RATEIO  := '1'             
                        //ZA4->ZA4_TRIBP   := '1' 
                        ZA4->( MsUnLock() )

                    Next
                    
                Else

                    nValItem    := 0
                    nValICMS    := 0
                    nValIPI     := 0
                    nValFCP     := 0

                    If ValType(XmlChildEx(oXML:_nfeProc:_NFe:_InfNfe:_Det:_imposto,"_ICMS")) == "O"
                        If ValType(XmlChildEx(oXML:_nfeProc:_NFe:_InfNfe:_Det:_imposto:_ICMS,"_ICMS10")) == "O"
                            nValICMS := Val(oXML:_nfeProc:_NFe:_InfNfe:_Det:_imposto:_ICMS:_ICMS10:_vICMSST:TEXT)
                            If ValType(XmlChildEx(oXML:_nfeProc:_NFe:_InfNfe:_Det:_imposto:_ICMS:_ICMS10,"_VFCPST")) == "O"
                                nValFCP  := Val(oXML:_nfeProc:_NFe:_InfNfe:_Det:_imposto:_ICMS:_ICMS10:_vFCPST:TEXT)
                            EndIf
                        EndIf
                    EndIf

                    If ValType(XmlChildEx(oXML:_nfeProc:_NFe:_InfNfe:_Det:_imposto,"_IPI")) == "O"
                        nValIPI := Val(oXML:_nfeProc:_NFe:_InfNfe:_Det:_imposto:_IPI:_IPITrib:_vIPI:TEXT)
                    EndIf

                    nValItem := Val(oXML:_nfeProc:_NFe:_InfNfe:_Det:_prod:_vProd:TEXT)

                    //--Similar a GW8 - ITENS DO DOCUMENTO DE CARGA
                    RecLock("ZA4", .T.)
                    ZA4->ZA4_FILIAL := FWxFilial("ZA4")                                                    
                    ZA4->ZA4_CDTPDC := 'TRG'                                                                                                    
                    ZA4->ZA4_EMISDC := cCodEmit                                                     
                    ZA4->ZA4_SERDC  := cSerie          
                    ZA4->ZA4_NRDC   := cNota           
                    ZA4->ZA4_SEQ    := strzero(1, 5)                 
                    ZA4->ZA4_ITEM   := oXML:_nfeProc:_NFe:_InfNfe:_Det:_prod:_cProd:TEXT                        
                    ZA4->ZA4_DSITEM := oXML:_nfeProc:_NFe:_InfNfe:_Det:_prod:_xProd:TEXT
                    ZA4->ZA4_QTDE   := Val(oXML:_nfeProc:_NFe:_InfNfe:_Det:_prod:_qCom:TEXT)
                    ZA4->ZA4_VALOR  := nValItem + nValICMS + nValIPI + nValFCP
                    //ZA4->ZA4_RATEIO := '1'               
                    //ZA4->ZA4_TRIBP  := '1'
                    ZA4->( MsUnLock() )

                EndIf

                dDtEmis := ctod(substr(oXML:_nfeProc:_NFe:_InfNfe:_ide:_dhEmi:TEXT,9,2)+'/'+;
                            substr(oXML:_nfeProc:_NFe:_InfNfe:_ide:_dhEmi:TEXT,6,2)+'/'+;
                            substr(oXML:_nfeProc:_NFe:_InfNfe:_ide:_dhEmi:TEXT,1,4))

                //--Similar a GW1 - DOCUMENTOS DE CARGA
                RecLock("ZA3", .T.)
                ZA3->ZA3_FILIAL := FWxFilial("ZA3")
                ZA3->ZA3_CDTPDC := 'TRG'        //--Definido na MIT044                                                                                     
                ZA3->ZA3_EMISDC := cCodEmit                                              
                ZA3->ZA3_DTEMIS := dDtEmis
                ZA3->ZA3_NRDC   := cNota 
                ZA3->ZA3_SERDC  := cSerie
                ZA3->ZA3_SIT    := '3'  //-- Liberado
                ZA3->ZA3_CDREM  := cCodEmit                
                ZA3->ZA3_CDDEST := cCodDest
                ZA3->ZA3_TPFRET := '5' //-- Consignado                
                ZA3->ZA3_DTIMPL := Date() 
                ZA3->ZA3_HRIMPL := LEFT( TIME(),5)
                ZA3->ZA3_QTVOL  := nSomaVol        
                ZA3->ZA3_DSESP  := 'VOLUME'          
                ZA3->ZA3_DANFE  := oXML:_nfeProc:_protNFe:_infProt:_chNFe:TEXT
                ZA3->ZA3_EDIARQ := SubStr(cXMLArq, At("\", cXMLArq ) + 1 )

                If Empty( cMsgErro )
                    ZA3->ZA3_EDISIT := '1'
                Else 
                    ZA3->ZA3_EDISIT := '2'
                    ZA3->ZA3_EDIMSG := cMsgErro
                EndIf

                ZA3->( MsUnLock() )

                //--Similar a GWU - TRECHOS DO ITINERARIO
                RecLock("ZA6", .T.)
                ZA6->ZA6_FILIAL := FWxFilial("ZA6")
                ZA6->ZA6_CDTPDC := 'TRG'                                                                                                    
                ZA6->ZA6_EMISDC := cCodEmit         
                ZA6->ZA6_SEQ    := '01'     
                ZA6->ZA6_SERDC  := cSerie          
                ZA6->ZA6_NRDC   := cNota           
                ZA6->ZA6_CDTRP  := cCodTransp                    
                ZA6->ZA6_NRCIDD := oXML:_nfeProc:_NFe:_infNFe:_dest:_enderDest:_cMun:TEXT
                //ZA6->ZA6_PAGAR  := '1'         
                ZA6->ZA6_CDCLFR := 'RODO'      
                ZA6->ZA6_CDTPOP := 'TRIANGULA'
                ZA6->( MsUnLock() )                                    

            End Transaction

        Else
            Help( ,, "CaoaTec",, "XML já processado anteriormente e portanto não será importado!" , 1, 0)
            lRet := .F.
        EndIf    
    Else
        Help( ,, "CaoaTec",, "O tipo de contratação do frete deve ser 'Por conta de Terceiros'. XML não será importado!" , 1, 0)
        lRet := .F.
    EndIf

    If ( Select(cAliasQry) <> 0 )
        dbSelectArea(cAliasQry)
        (cAliasQry)->( DbCloseArea() )
    EndIf

Return lRet

/*
===========================================================================================
Programa.:              zProcMark
Autor....:              CAOA - Fagner Barreto
Data.....:              03/01/2022
Descricao / Objetivo:   Filtra registros marcados e aciona a geração do documento de carga
===========================================================================================
*/
//Static Function zProcMark()
User Function zProcMark()
	Local cAliasQry	:= GetNextAlias()

    Private __cErrDoc := ""

    If !( oMarkBrw:IsMark(__cMark) )
        Help( ,, "CaoaTec",, 'É necessario selecionar um ou mais registros para seguir com o processamento!' , 1, 0)
        Return
    EndIf

    BeginSql Alias cAliasQry
        SELECT ZA3_CDTPDC, ZA3_EMISDC, ZA3_SERDC, ZA3_NRDC, R_E_C_N_O_ AS RECZA3
        FROM %Table:ZA3% ZA3
        WHERE ZA3.ZA3_OK = %Exp:__cMark%
        AND ZA3.ZA3_EDISIT <> '4'
        AND ZA3.%NotDel%
    EndSql

    (cAliasQry)->( DbGoTop() )
    If (cAliasQry)->( !Eof() )

        While (cAliasQry)->( !Eof() )

            __cErrDoc := ""

            If !( zCargaDoc((cAliasQry)->ZA3_CDTPDC, (cAliasQry)->ZA3_EMISDC, (cAliasQry)->ZA3_SERDC, (cAliasQry)->ZA3_NRDC) )

                DbGoTo( (cAliasQry)->RECZA3 )
                RecLock("ZA3", .F.)
                ZA3->ZA3_EDISIT := '3'
                ZA3->ZA3_EDIMSG := __cErrDoc
                ZA3->ZA3_OK     := ""
                ZA3->( MsUnlock() )
            
            Else

                DbGoTo( (cAliasQry)->RECZA3 )
                RecLock("ZA3", .F.)
                ZA3->ZA3_EDISIT := '4'
                ZA3->ZA3_EDIMSG := __cErrDoc
                ZA3->ZA3_OK     := ""
                ZA3->( MsUnlock() )

            EndIf

            (cAliasQry)->( DbSkip() )

        EndDo

    Else
        Help( ,, "CaoaTec",, 'Os registros selecionados ja estão processados!' , 1, 0)
    EndIf

    (cAliasQry)->( DbCloseArea() )

Return

/*
===========================================================================================
Programa.:              zExclMark
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   Exclui registros marcados  
===========================================================================================
*/
//Static Function zExclMark()
User Function zExclMark()
	Local cAliasQry	:= GetNextAlias()

    If !( oMarkBrw:IsMark(__cMark) )
        Help( ,, "CaoaTec",, 'É necessario selecionar um ou mais registros para seguir com a exclusão!' , 1, 0)
        Return
    EndIf

    //--Ativação das workareas
    ZA3->( DbSetOrder(1) )
    ZA4->( DbSetOrder(1) )
    ZA5->( DbSetOrder(1) )
    ZA6->( DbSetOrder(1) )

    BeginSql Alias cAliasQry
        SELECT R_E_C_N_O_ AS RECZA3
        FROM %Table:ZA3% ZA3
        WHERE ZA3.ZA3_OK = %Exp:__cMark%
        AND ZA3.ZA3_EDISIT <> '4'
        AND ZA3.%NotDel%
    EndSql

    (cAliasQry)->( DbGoTop() )
    If (cAliasQry)->( !Eof() )

        While (cAliasQry)->( !Eof() )

            ZA3->( DbGoTo( (cAliasQry)->RECZA3 ) )

            If ZA4->( DbSeek( FWxFilial("ZA4") + ZA3->( ZA3_CDTPDC + ZA3_EMISDC + ZA3_SERDC + ZA3_NRDC ) ) )

                While ZA4->( !Eof() ) .And.;
                    ZA4->(ZA4_CDTPDC + ZA4_EMISDC + ZA4_SERDC + ZA4_NRDC) == ZA3->( ZA3_CDTPDC + ZA3_EMISDC + ZA3_SERDC + ZA3_NRDC )

                        RecLock("ZA4", .F.)
                        ZA4->( DbDelete() )
                        ZA4->( MsUnlock() )

                    ZA4->( DbSkip() )
                EndDo

            EndIf

            If ZA5->( DbSeek( FWxFilial("ZA5") + ZA3->ZA3_NRDC ) )

                While ZA5->( !Eof() ) .And.;
                    ZA5->(ZA5_CDTPDC + ZA5_EMISDC + ZA5_SERDC + ZA5_NRDC) == ZA3->( ZA3_CDTPDC + ZA3_EMISDC + ZA3_SERDC + ZA3_NRDC )

                        RecLock("ZA5", .F.)
                        ZA5->( DbDelete() )
                        ZA5->( MsUnlock() )   

                    ZA5->( DbSkip() )
                EndDo
            
            EndIf

            If ZA6->( DbSeek( FWxFilial("ZA6") + ZA3->( ZA3_CDTPDC + ZA3_EMISDC + ZA3_SERDC + ZA3_NRDC ) ) )

                RecLock("ZA6", .F.)
                ZA6->( DbDelete() )
                ZA6->( MsUnlock() ) 

            EndIf


            RecLock("ZA3", .F.)
            ZA3->( DbDelete() )
            ZA3->( MsUnlock() )
            
            (cAliasQry)->( DbSkip() )

        EndDo

    Else
        Help( ,, "CaoaTec",, 'Os registros selecionados não podem ser excluidos pois ja estão processados!' , 1, 0)
    EndIf

    (cAliasQry)->( DbCloseArea() )

Return

/*
===========================================================================================
Programa.:              zCargaDoc
Autor....:              CAOA - Fagner Barreto
Data.....:              03/01/2022
Descricao / Objetivo:   Efetua a carga dos registros para geração do documento de carga  
===========================================================================================
*/
Static Function zCargaDoc(cCdtpdc, cEmisdc, cSerdc, cNrdc)
    Local lRet      := .T.
    Local aDadosGW8 := {}
    Local aDadosGWB := {}
    Local aExAutGW1 := {}
    Local aExAutGW8 := {}
    Local aExAutGWB := {}
    Local aExAutGWU := {}

    //--Ativação das workareas
    ZA3->( DbSetOrder(1) )
    ZA4->( DbSetOrder(1) )
    ZA5->( DbSetOrder(1) )
    ZA6->( DbSetOrder(1) )

    If ZA3->( DbSeek( FWxFilial("ZA3") + cCdtpdc + cEmisdc + cSerdc + cNrdc ) )

        //ZA3_FILIAL
        aAdd( aExAutGW1, { 'GW1_FILIAL',  FWxFilial("ZA3")} )
        aAdd( aExAutGW1, { 'GW1_CDTPDC',  ZA3->ZA3_CDTPDC } )                                                                                            
        aAdd( aExAutGW1, { 'GW1_EMISDC',  ZA3->ZA3_EMISDC } )                                                
        aAdd( aExAutGW1, { 'GW1_DTEMIS',  ZA3->ZA3_DTEMIS } )
        aAdd( aExAutGW1, { 'GW1_NRDC'  ,  ZA3->ZA3_NRDC   } )
        aAdd( aExAutGW1, { 'GW1_SERDC' ,  ZA3->ZA3_SERDC  } )
        aAdd( aExAutGW1, { 'GW1_SIT'   ,  ZA3->ZA3_SIT    } )
        aAdd( aExAutGW1, { 'GW1_CDREM' ,  ZA3->ZA3_CDREM  } )                 
        aAdd( aExAutGW1, { 'GW1_CDDEST',  ZA3->ZA3_CDDEST } )
        aAdd( aExAutGW1, { 'GW1_TPFRET',  ZA3->ZA3_TPFRET } )                 
        aAdd( aExAutGW1, { 'GW1_DTIMPL',  ZA3->ZA3_DTIMPL } )
        aAdd( aExAutGW1, { 'GW1_HRIMPL',  ZA3->ZA3_HRIMPL } )
        aAdd( aExAutGW1, { 'GW1_QTVOL' ,  ZA3->ZA3_QTVOL  } )
        aAdd( aExAutGW1, { 'GW1_DSESP' ,  ZA3->ZA3_DSESP  } )      
        aAdd( aExAutGW1, { 'GW1_DANFE' ,  ZA3->ZA3_DANFE  } ) 
        aAdd( aExAutGW1, { 'GW1_AUTSEF',  '1' } ) //--Solicitado por Juarez em 03/02/2022 via whatsapp  

    EndIf

    If ZA4->( DbSeek( FWxFilial("ZA4") + cCdtpdc + cEmisdc + cSerdc + cNrdc ) )

        While ZA4->( !Eof() ) .And.;
            ZA4->(ZA4_CDTPDC + ZA4_EMISDC + ZA4_SERDC + ZA4_NRDC) == cCdtpdc + cEmisdc + cSerdc + cNrdc

            //ZA4_FILIAL
            aAdd( aExAutGW8, { 'GW8_FILIAL',  FWxFilial("ZA4")  } )                                                      
            aAdd( aExAutGW8, { 'GW8_CDTPDC',  ZA4->ZA4_CDTPDC } )                                                                                            
            aAdd( aExAutGW8, { 'GW8_EMISDC',  ZA4->ZA4_EMISDC } )                                                
            aAdd( aExAutGW8, { 'GW8_SERDC' ,  ZA4->ZA4_SERDC  } )
            aAdd( aExAutGW8, { 'GW8_NRDC'  ,  ZA4->ZA4_NRDC   } )
            aAdd( aExAutGW8, { 'GW8_SEQ'   ,  ZA4->ZA4_SEQ    } )                 
            aAdd( aExAutGW8, { 'GW8_ITEM'  ,  ZA4->ZA4_ITEM   } )                 
            aAdd( aExAutGW8, { 'GW8_DSITEM',  ZA4->ZA4_DSITEM } )                 
            //aAdd( aExAutGW8, { 'GW8_CDCLFR', 'RODO'          } )   //Verificar
            aAdd( aExAutGW8, { 'GW8_QTDE'  ,  ZA4->ZA4_QTDE   } )   
            aAdd( aExAutGW8, { 'GW8_VALOR' ,  ZA4->ZA4_VALOR  } )   
            //aAdd( aExAutGW8, { 'GW8_RATEIO', '1'             } )                 
            //aAdd( aExAutGW8, { 'GW8_TRIBP' , '1'             } )  

            aAdd( aDadosGW8, aExAutGW8 )

            aExAutGW8 := {}

            ZA4->( DbSkip() )
        EndDo

    EndIf

    If ZA5->( DbSeek( FWxFilial("ZA5") + cNrdc ) )

        While ZA5->( !Eof() ) .And.;
            ZA5->(ZA5_CDTPDC + ZA5_EMISDC + ZA5_SERDC + ZA5_NRDC) == cCdtpdc + cEmisdc + cSerdc + cNrdc

            //ZA5_FILIAL
            aAdd( aExAutGWB, { 'GWB_FILIAL',  xFilial("ZA5")  } )
            aAdd( aExAutGWB, { 'GWB_CDTPDC',  ZA5->ZA5_CDTPDC } )                                                                                            
            aAdd( aExAutGWB, { 'GWB_EMISDC',  ZA5->ZA5_EMISDC } )    
            aAdd( aExAutGWB, { 'GWB_SERDC' ,  ZA5->ZA5_SERDC  } )
            aAdd( aExAutGWB, { 'GWB_NRDC'  ,  ZA5->ZA5_NRDC   } )
            aAdd( aExAutGWB, { 'GWB_CDUNIT',  ZA5->ZA5_CDUNIT } ) 
            aAdd( aExAutGWB, { 'GWB_QTDE'  ,  ZA5->ZA5_QTDE } )  

            aAdd( aDadosGWB, aExAutGWB )

            aExAutGWB := {}

            ZA5->( DbSkip() )
        EndDo
    
    EndIf

    If ZA6->( DbSeek( FWxFilial("ZA6") + cCdtpdc + cEmisdc + cSerdc + cNrdc ) )
        //ZA6_FILIAL
        aAdd( aExAutGWU, { 'GWU_FILIAL',  xFilial("ZA6")  } )
        aAdd( aExAutGWU, { 'GWU_CDTPDC',  ZA6->ZA6_CDTPDC } )                                                                                            
        aAdd( aExAutGWU, { 'GWU_EMISDC',  ZA6->ZA6_EMISDC } )    
        aAdd( aExAutGWU, { 'GWU_SEQ'   ,  ZA6->ZA6_SEQ    } )    
        aAdd( aExAutGWU, { 'GWU_SERDC' ,  ZA6->ZA6_SERDC  } )
        aAdd( aExAutGWU, { 'GWU_NRDC'  ,  ZA6->ZA6_NRDC   } )
        aAdd( aExAutGWU, { 'GWU_CDTRP' ,  ZA6->ZA6_CDTRP  } )                 
        aAdd( aExAutGWU, { 'GWU_NRCIDD',  ZA6->ZA6_NRCIDD } )
        //aAdd( aExAutGWU, { 'GWU_PAGAR' ,  ZA6->ZA6_PAGAR  } )                                     
        aAdd( aExAutGWU, { 'GWU_CDCLFR',  ZA6->ZA6_CDCLFR } )                                     
        aAdd( aExAutGWU, { 'GWU_CDTPOP',  ZA6->ZA6_CDTPOP } )                                     
    EndIf

    If !zGerDocCar( aExAutGW1, aDadosGW8, aDadosGWB, aExAutGWU)
        lRet := .F.
    EndIf

Return lRet

/*
===========================================================================================
Programa.:              zGerDocCar
Autor....:              CAOA - Fagner Barreto
Data.....:              03/01/2022
Descricao / Objetivo:   Efetua a geração do documento de carga    
===========================================================================================
*/
Static Function zGerDocCar( aExAutGW1, aDadosGW8, aDadosGWB, aExAutGWU )
    Local oModel
    Local oModelGW8
	Local oModelGWB
    Local nI := 0
    Local nY := 0
    Local lRet := .T.
    Local aErro := {}
                            
    oModel := FWLoadModel( 'GFEA044' )
    oModel:SetOperation( 3 )
    oModel:Activate()

    // Capturando submodelos que possuem grid para preenchimento dos itens
    oModelGW8 := oModel:GetModel("GFEA044_GW8")
    oModelGWB := oModel:GetModel("GFEA044_GWB")
                                  
    For nI := 1 To Len( aExAutGW1 )       
        If !( oModel:SetValue('GFEA044_GW1', aExAutGW1[nI][1], aExAutGW1[nI][2] ) ) 
            lRet := .F.
            Exit
        EndIf
    Next
    
    If lRet                                   
        For nI := 1 To Len( aExAutGWU )       
            If !( oModel:SetValue('GFEA044_GWU', aExAutGWU[nI][1], aExAutGWU[nI][2] ) ) 
                lRet := .F.
                Exit
            EndIf
        Next
    EndIf  

    If lRet                                   
        For nI := 1 To Len( aDadosGW8 )

            If nI != 1
                oModelGW8:AddLine() //--Quando possui grid no modelo é necessario adicionar linha a linha
            EndIf

            For nY := 1 To Len( aDadosGW8[nI] )
                If !( oModelGW8:SetValue(aDadosGW8[nI][nY][1], aDadosGW8[nI][nY][2] ) ) 
                    lRet := .F.
                    Exit
                EndIf
            Next
        Next
    EndIf  

    If lRet                                   
        For nI := 1 To Len( aDadosGWB )  

            If nI != 1
                oModelGWB:AddLine() //--Quando possui grid no modelo é necessario adicionar linha a linha
            EndIf

            For nY := 1 To Len( aDadosGWB[nI] )     
                If !( oModelGWB:SetValue(aDadosGWB[nI][nY][1], aDadosGWB[nI][nY][2] ) ) 
                    lRet := .F.
                    Exit
                EndIf
            Next
        Next
    EndIf  

    If lRet
        If ( lRet := oModel:VldData() )
            oModel:CommitData()
        EndIf
    EndIf

    If !lRet
    
        aErro := oModel:GetErrorMessage()
        
    Endif
    
    If Len(aErro) > 0
        //AutoGrLog( "Erro no Item: " + aErro[6] )      
        cDescMsgError := "Erro no Item: " + aErro[4] +' - ' + aErro[6] + CRLF 
        if valtype(aErro[9]) <> 'U'
        cDescMsgError += aErro[9] + CRLF 
        endif   
        cDescMsgError += aErro[7]
        //AutoGrLog(cDescMsgError)
        Conout(cDescMsgError)
        __cErrDoc := cDescMsgError       
    EndIf

    oModel:DeActivate()
 
Return lRet

/*
===========================================================================================
Programa.:              zRemBarra
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   Inclui a barra ('/' ou '\') no fim do diretorio, caso haja necessidade.   
===========================================================================================
*/
Static Function zRemBarra(cDir)

	Local cBarra := If(isSrvUnix(),"/","\")

	If SubStr(cDir, Len(cDir), 1) != '/' .And. SubStr(cDir, Len(cDir), 1) != '\'
		cDir += cBarra
	EndIf
return cDir

/*
===========================================================================================
Programa.:              zIncluiSA2
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   Realiza inclusão de cadastro de fornecedor  
===========================================================================================
*/
Static Function zIncluiSA2(oXML)
    Local oModel        := Nil
    Local lRet          := .T.
    Local aErro         := {}
    Local nI            := 0
    Local aIncForn      := {}
    Local cCodForn      := ""
    Local cLoja         := ""
    Local cDescMsgError := ""

    SA2->( DbSetOrder(3) )
    If !( SA2->( DbSeek( FWxFilial('SA2') + oXML:_nfeProc:_NFe:_infNFe:_emit:_CNPJ:TEXT ) ) )

        cCodForn    := GetSxeNum("SA2","A2_COD")
        cLoja	    := PadR("1",TamSx3("A2_LOJA")[1],"0")

        aAdd( aIncForn, { 'A2_FILIAL' ,  FWxFilial('SA2')  } )   
        aAdd( aIncForn, { 'A2_COD'    ,  cCodForn } )
        aAdd( aIncForn, { 'A2_LOJA'   ,  cLoja } )
        aAdd( aIncForn, { 'A2_NOME'   ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_xNome:TEXT } )
        aAdd( aIncForn, { 'A2_NREDUZ' ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_xFant:TEXT } ) 
        aAdd( aIncForn, { 'A2_END'    ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_xLgr:TEXT } )
        aAdd( aIncForn, { 'A2_NR_END' ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_nro:TEXT } )
        aAdd( aIncForn, { 'A2_BAIRRO' ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_xBairro:TEXT } )
        aAdd( aIncForn, { 'A2_EST'    ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_UF:TEXT } )
        aAdd( aIncForn, { 'A2_COD_MUN',  oXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_cMun:TEXT } )
        aAdd( aIncForn, { 'A2_MUN'    ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_xMun:TEXT } )
        aAdd( aIncForn, { 'A2_TIPO'   ,  'J' } )
        aAdd( aIncForn, { 'A2_CGC'    ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_CNPJ:TEXT  } )

        oModel := FWLoadModel('MATA020')

        oModel:SetOperation(3)
        oModel:Activate()
                                    
        For nI := 1 To Len( aIncForn )       
            If !( oModel:SetValue('SA2MASTER', aIncForn[nI][1], aIncForn[nI][2] ) ) 
                lRet := .F.
                Exit
            EndIf
        Next

        If lRet
            If ( lRet := oModel:VldData() )
                oModel:CommitData()
            EndIf
        EndIf

        If !lRet
        
            aErro := oModel:GetErrorMessage()

            SA2->( RollBackSX8() )
        Else
            SA2->( ConfirmSx8() )            
        Endif
        
        If Len(aErro) > 0
            //AutoGrLog( "Erro no Item: " + aErro[6] )      
            cDescMsgError := "Erro no Item: " + aErro[4] +' - ' + aErro[6] + CRLF 
            if valtype(aErro[9]) <> 'U'
                cDescMsgError += aErro[9] + CRLF 
            endif   
            cDescMsgError += aErro[7]
            //AutoGrLog(cDescMsgError)
            Conout(cDescMsgError)
            cMsgErro := cDescMsgError       
        EndIf

        oModel:DeActivate()

        oModel:Destroy()

    EndIf

Return lRet

/*
===========================================================================================
Programa.:              zIncluiSA1
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   Realiza inclusão de cadastro de cliente  
===========================================================================================
*/
Static Function zIncluiSA1(oXML)
    Local oModel        := Nil
    Local lRet          := .T.
    Local aErro         := {}
    Local nI            := 0
    Local cCodCli       := ""
    Local cLoja         := ""
    Local aIncCli       := {}
    Local cDescMsgError := ""

    SA1->( DbSetOrder(3) )
    If !( SA1->( DbSeek( FWxFilial('SA1') + oXML:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:TEXT ) ) )

        cCodCli    := GetSxeNum("SA1","A1_COD")
        cLoja	    := PadR("1",TamSx3("A1_LOJA")[1],"0")

        aAdd( aIncCli, { 'A1_FILIAL' ,  FWxFilial('SA1')  } )   
        aAdd( aIncCli, { 'A1_COD'    ,  cCodCli } )
        aAdd( aIncCli, { 'A1_LOJA'   ,  cLoja } )
        aAdd( aIncCli, { 'A1_NOME'   ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_xNome:TEXT } )
        //aAdd( aIncCli, { 'A1_NREDUZ' ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_xFant:TEXT } ) 
        aAdd( aIncCli, { 'A1_TIPO'   ,  'J' } )
        aAdd( aIncCli, { 'A1_END'    ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_enderDest:_xLgr:TEXT + ", " +;
                                            oXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_nro:TEXT  } )
        //aAdd( aIncCli, { 'A1_NR_END' ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_nro:TEXT } )
        aAdd( aIncCli, { 'A1_BAIRRO' ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_xBairro:TEXT } )
        aAdd( aIncCli, { 'A1_EST'    ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_UF:TEXT } )
        aAdd( aIncCli, { 'A1_COD_MUN',  oXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_cMun:TEXT } )
        aAdd( aIncCli, { 'A1_MUN'    ,  oXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_xMun:TEXT } )
        aAdd( aIncCli, { 'A1_CGC'    ,  oXML:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:TEXT  } )

        oModel := FWLoadModel('MATA020')
        oModel:SetOperation(3)
        oModel:Activate()
                                    
        For nI := 1 To Len( aIncCli )       
            If !( oModel:SetValue('MATA030_SA1', aIncForn[nI][1], aIncForn[nI][2] ) ) 
                lRet := .F.
                Exit
            EndIf
        Next
    
        If lRet
            If ( lRet := oModel:VldData() )
                oModel:CommitData()
            EndIf
        EndIf

        If !lRet
        
            aErro := oModel:GetErrorMessage()
                            
            SA1->( RollBackSX8() )

        Else

            SA1->( ConfirmSx8() )
            
        Endif
        
        If Len(aErro) > 0
            //AutoGrLog( "Erro no Item: " + aErro[6] )      
            cDescMsgError := "Erro no Item: " + aErro[4] +' - ' + aErro[6] + CRLF 
            if valtype(aErro[9]) <> 'U'
                cDescMsgError += aErro[9] + CRLF 
            endif   
            cDescMsgError += aErro[7]
            //AutoGrLog(cDescMsgError)
            Conout(cDescMsgError)
            cMsgErro := cDescMsgError       
        EndIf

        oModel:DeActivate()

        oModel:Destroy()
    
    EndIf

Return lRet

/*
===========================================================================================
Programa.:              
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:     
===========================================================================================
*/
Static Function zVldModel(oModel)
	Local lRet       := .T.
    Local oModelZA3  := oModel:GetModel("ZGFEF002_ZA3")

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
        
        If oModelZA3:GetValue("ZA3_EDISIT") == '4'
            Help( ,, "CaoaTec",, 'Este registro não pode ser excluido pois ja esta processado!' , 1, 0)
            lRet := .F.
        EndIf

    ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE

        If oModelZA3:GetValue("ZA3_EDISIT") == '4'
            Help( ,, "CaoaTec",, 'Este registro não pode ser alterado pois ja esta processado!' , 1, 0)
            lRet := .F.
        EndIf

	EndIf

Return lRet

/*
===========================================================================================
Programa.:              zMarkAll
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:     
===========================================================================================
*/
Static Function zMarkAll( oMark, cMarkOk, cTrbAux )

	dbSelectArea( cTrbAux )
	dbGotop()
	While !Eof()
		RecLock( cTrbAux, .F. )

		If Empty( (cTrbAux)->ZA3_OK )
			(cTrbAux)->ZA3_OK := cMarkOk
		Else
			(cTrbAux)->ZA3_OK := "  "
		EndIf

		MsUnLock()

		(cTrbAux)->( dbSkip() )
	EndDo

	dbSelectArea( cTrbAux )
	dbGotop()

	oMark:Refresh()

Return 

//--------------------------------------------------------------

/* Validação do emitente para Destinatário e remetente */
User Function GFEAZA3Emi(cCampo)

	Local lReturn := .T.
	Local cTpDcSent := Posicione("GV5", 1, xFilial("GV5") + M->ZA3_CDTPDC, "GV5_SENTID")
	Local lFilialRem
	Local lFilialDes

	Default cCampo := ReadVar()

	// Documento SAÍDA - Remetente
	If "ZA3_CDREM" $ cCampo
		lFilialRem := Posicione("GU3", 1, xFilial("GU3") + M->ZA3_CDREM, "GU3_EMFIL") // Atribuir o valor de cCampo

		// Se o sentido do  tipo de documento for SAÍDA (2), o remetente deve ser do tipo filial
		If cTpDcSent == "2".AND.lFilialRem == "2"
			Help( ,, 'HELP',, 'Se o sentido do documento é saída, o remetente deve ser filial', 1, 0)
			lReturn := .F.
		Endif
	Endif

	// Documento ENTRADA - Destinatário
	If lReturn.AND."ZA3_CDDEST" $ cCampo
		lFilialDes := Posicione("GU3", 1, xFilial("GU3") + M->ZA3_CDDEST, "GU3_EMFIL") // Atribuir o valor de cCampo

		// Se o sentido do  tipo de documento for ENTRADA (1), o destinatário deve ser do tipo filial
		If cTpDcSent == "1".AND.lFilialDes == "2"
			Help( ,, 'HELP',, 'Se o sentido do documento é entrada, o destinatário deve ser filial', 1, 0) //
			lReturn := .F.
		Endif
	Endif

	// Documento EXTERNO - Remetente
	If lReturn.AND."ZA3_CDREM" $ cCampo
		lFilialRem  := Posicione("GU3", 1, xFilial("GU3") + M->ZA3_CDREM, "GU3_EMFIL") // Atribuir o valor de cCampo

		// Se o sentido do  tipo de documento for EXTERNO (3), o remetente e o destinatário não devem ser do tipo filial
		If cTpDcSent == "3".AND.lFilialRem == "1"
			Help( ,, 'HELP',, 'Se o sentido do documento é externo, o remetente e o destinarário não devem ser filial', 1, 0) //
			lReturn := .F.
		Endif
	Endif

	// Documento EXTERNO - Destinatário
	If lReturn.AND."ZA3_CDDEST" $ cCampo
		lFilialDes 	:= Posicione("GU3", 1, xFilial("GU3") + M->ZA3_CDDEST, "GU3_EMFIL") // Atribuir o valor de cCampo

		// Se o sentido do  tipo de documento for EXTERNO (3), o remetente e o destinatário não devem ser do tipo filial
		If cTpDcSent == "3".AND.lFilialDes == "1"
			Help( ,, 'HELP',, 'Se o sentido do documento é externo, o remetente e o destinarário não devem ser filial', 1, 0) //
			lReturn := .F.
		Endif
	Endif

	// Documento INTERNO - Remetente
	If lReturn.AND."ZA3_CDREM" $ cCampo
		lFilialRem  := Posicione("GU3", 1, xFilial("GU3") + M->ZA3_CDREM, "GU3_EMFIL") // Atribuir o valor de cCampo

		// Se o sentido do  tipo de documento for INTERNO (4), o remetente deve ser do tipo filial
		If cTpDcSent == "4".AND.lFilialRem != "1"
			Help( ,, 'HELP',, 'Se o sentido do documento é externo, o remetente e o destinarário não devem ser filial', 1, 0) //x
			lReturn := .F.
		Endif
	Endif

	// Documento INTERNO - Destinatário
	If lReturn.AND."ZA3_CDDEST" $ cCampo
		lFilialDes 	:= Posicione("GU3", 1, xFilial("GU3") + M->ZA3_CDDEST, "GU3_EMFIL") // Atribuir o valor de cCampo

		// Se o sentido do  tipo de documento for INTERNO (4), o destinatário não devem ser do tipo filial
		If cTpDcSent == "4".AND.lFilialDes != "1"
			Help( ,, 'HELP',, 'Se o sentido do documento é interno, o remetente e o destinarário devem ser filial', 1, 0) //
			lReturn := .F.
		Endif
	Endif

Return lReturn

