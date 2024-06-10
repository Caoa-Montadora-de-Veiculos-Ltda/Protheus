#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH"
#include "rwmake.ch"
#include "TOTVS.ch"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "Eicsi400.ch"
#INCLUDE "AvPrint.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWFILTER.CH"
#INCLUDE "FWMVCDEF.CH"

#define CMD_OPENWORKBOOK			1
#define CMD_CLOSEWORKBOOK			2
#define CMD_ACTIVEWORKSHEET			3
#define CMD_READCELL				4
/*/{Protheus.doc} ZCOMF036
Importacao de planilha e geracao de CTE
@param  	Numero Origem e Município Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
@return  	NIL
@obs
@project
@history
/*/
User Function ZCOMF036()
    LOCAL oDlg
    LOCAL nOpca       := 0
    Local aPergs 	  := {}
    Local cCaminho    := Space(60)
    Private cArq      := ""          
    Private cExt      := "Arquivo CSV | *.CSV"
    Private lRet      := .T.
    Private _cLocal   := ""
    Public aRetP 	  := {}
    Public cCusto     := Space(15)
    Public cTes       := Space(03)
    Public cCondP     := Space(03)
    Public cProd      := Space(25)
    Public cFor       := Space(06)
    Public cLoja      := Space(02)
    Public cFatura    := Space(40)
    Public _cMunOri   := GetMv("MV_XMUNORI",.F.,"48500")
    Public _cMunDes   := GetMv("MV_XMUNDES",.F.,"01108")
    Public _cSerie    := GetMv("CMV_SERCTE",.F.,"1  "  )

    If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
        _cLocal := "PRD"
    else
        _cLocal := "55"
    EndIf
    aAdd( aPergs ,{6,"Diretorio do Arquivo ",cCaminho     ,"@!" ,     ,'.T.' ,80,.T.,cExt })
    aAdd( aPergs ,{1,"Fornecedor           ",cFor	      ,"@!"	,'.T.',"SA2A",'.T.',03,.T.})
    aAdd( aPergs ,{1,"Loja                 ",cLoja	      ,"@!"	,'.T.'," "   ,'.T.',03,.T.})
    //aAdd( aPergs ,{1,"Nome                 ",cNome	      ,"@!"	,'.T.'," "   ,'.T.',80,.F.})
    aAdd( aPergs ,{1,"Tes                  ",cTes	      ,"@!"	,'.T.',"SF4" ,'.T.',03,.T.})
    aAdd( aPergs ,{1,"Cond.Pgto            ",cCondP	      ,"@!"	,'.T.',"SE4" ,'.T.',03,.T.})
    aAdd( aPergs ,{1,"Produto              ",cProd	      ,"@!"	,'.T.',"SB1" ,'.T.',80,.T.})
    aAdd( aPergs ,{1,"Centro de Custo      ",cCusto	      ,"@!"	,'.T.',"CTT" ,'.T.',80,.T.})
    aAdd( aPergs ,{1,"Fatura               ",cFatura      ,"@!"	,'.T.'," "   ,'.T.',80,.T.})

    If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 

        DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Importação Documento Entrada") PIXEL
        @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
        @ 29, 15 SAY OemToAnsi("Esta rotina realiza a importação de Planilha CSV para Geração de CTE Conf.Lay-Out: ") SIZE 268, 8 OF oDlg PIXEL
        @ 38, 15 SAY OemToAnsi("Nota+Serie+Data+Conteiner+Valor+Chave+Municipio_Origem+UF_Origem+Municipio_Destino+UF_Destino") SIZE 268, 8 OF oDlg PIXEL
        @ 48, 15 SAY OemToAnsi("Confirma Geração da Documento?") SIZE 268, 8 OF oDlg PIXEL
        DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
        DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
        ACTIVATE MSDIALOG oDlg CENTER
        If nOpca == 1
            Processa ({|| FImpDTA()},"Aguarde! Efetuando Importação da Planilha "+"[ZCOMF036]")
        Endif

    Endif

Ferase(cArq)

Return()


/*/{Protheus.doc} ZCOMF036
Importacao de planilha e geracao de CTE
@param  	Numero Origem e Município Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
@return  	NIL
@obs
@project
@history
/*/
Static Function FImpDTA()
    Local nHdl 		   := 0       //ExecInDLLOpen ('readexcel.dll')//('C:\TEMP\readexcel.dll')//('readexcel.dll')   //Esse arquivo precisa estar dentro da smartclient do usuario
    Local cDir         := Alltrim(MV_PAR01)  
    Private cLinha     := ""
    Private cSeparador := ";"
    Private aDados     := {}
    Private aDadosLi   := {}
    Private _dData     := ""
    Private _cNota     := ""
    Private _lExtrai   := .F.
    Private _aStruLog  := {}
    Private _aErro     := {}
    Private _cLog 	   := ""
    Private _aCelulas  := {}
    Private aCab       := {}
    Private aIteNFE    := {}
    Private nTotal     := 0
    Private nAtual     := 0
    Private nItDoc     := 0

// Elementos da Matriz _aCelulas
// 1o.-> Descrição do Campo
// 2o.-> Coluna da Planilha
// 3o.-> Linha da Planilha
// 4o.-> Tipo do dado a ser Gravado( Caracter,Numerico,Data)
// 5o.-> Tamanho do Dado a Ser Gravado
// 6o.-> Casas decimais do dado a ser Gravado

// Montagem das Celulas do Cabeçalho
    AADD(_aCelulas,{'NOTA'             ,"A",04,'C',09,0})  //1
    AADD(_aCelulas,{'SERIE'            ,"B",04,'C',03,0})  //2
    AADD(_aCelulas,{'EMISSAO'          ,"C",04,'D',08,0})  //3
    AADD(_aCelulas,{'CONTEINER'        ,"D",04,'C',20,0})  //4
    AADD(_aCelulas,{'VLR.FRETE'        ,"M",04,'N',14,7})  //5
    AADD(_aCelulas,{'CHAVE'            ,"V",04,'C',44,0})  //6
    AADD(_aCelulas,{'UF_ORIGEM'        ,"X",04,'C',02,0})  //7
    AADD(_aCelulas,{'MUN_ORIGEM'       ,"W",04,'C',44,0})  //8
    AADD(_aCelulas,{'UF_DESTINO'       ,"Z",04,'C',02,0})  //9
    AADD(_aCelulas,{'MUN_DESTINO'      ,"Y",04,'C',44,0})  //10

    AADD(_aStruLog,{"LOG","C",280,0})
    AADD(_aStruLog,{"NOTA","C",009,0}) 
    AADD(_aStruLog,{"EMISSAO","D",008,0}) 

    _cArqTRB   := Criatrab(_aStruLog,.T.)
	_cIndice   := CriaTrab(Nil,.F.)
    _cChaveInd := "NOTA"

	If Select("TRB1") > 0
		dbSelectArea("TRB1")
		dbCloseArea()
        TCDelFile(_cArqTRB)
	EndIf

    dbCreate( _cArqTRB , _aStruLog , "TOPCONN" )
	dbUseArea( .T., __LocalDriver, _cArqTRB , "TRB1", .F., .F. )
    dbCreateIndex( _cArqTRB ,_cChaveInd )

    dbSelectArea( "TRB1" )
	dbSetOrder(1)
  
    dbSelectArea("SA2")
    dbSetOrder(1)
    If !dbSeek(xFilial("SA2") + aRetP[2] + aRetP[3])
	   MsgStop("Fornecedor ou loja não cadastrado!   Abortando Importação...   "+"[ZCOMF036]")
       lRet := .F.
	   Return .F.
    EndIf

    // Verifica se Conseguiu efetuar a Abertura do Arquivo
    If !File(AllTrim(cDir))
   	   MsgStop("[ZCOMF036] - "+"Arquivo não existe! ")
	   lRet := .F.
       Return()
    Endif

    cArq := ALLTRIM(MV_PAR01)

    // Extrai os Dados 
    U_IMPDTA(cArq,_aCelulas,_lExtrai)

    dbSelectArea("TRB1")
    dbGotop()
    If TRB1->(!EOF())
        Processa({|| IMPEXC() },"Gerando Relatorio de Log... "+"[ZCOMF036]")
    Else

    Endif
    
    FCLOSE(nHdl)

Return()


/*/{Protheus.doc} ZCOMF036
Importacao de planilha e geracao de CTE
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
@return  	NIL
@obs        Retorna o Conteudo de Uma planilha CSV para o Protheus
@project
@history
/*/
User Function IMPDTA(cArq,_cMatriz,_lExtrai)
Local _cNota     := "000000000"
Local _cCaract   := "R$"
Local _cCarp     := "."
Local _cCarv     := ","
Local _cCont	 := ""
Local _nValTot   := 0
Local _cChave	 := ""
Local _cUfOri	 := ""
Local _cMunOri   := ""
Local _cUfDes	 := ""
Local _cMunDes   := ""
Local _nLoop     := 0

    FT_FUSE(cArq)
    FT_FGOTOP()
    FT_FSKIP()

    While !FT_FEOF()
        nTotal++
        cLinha := FT_FREADLN()
        aDados := Separa(cLinha,cSeparador)
        aAdd(aDadosLi, aClone(aDados))
        FT_FSKIP()
    END

    If cSeparador <> ";"
        MsgInfo("Separador do arquivo invalido!!! " + cSeparador)
        cLogWrite += ("Erro Separador do arquivo invalido! ")
        cStatus   := " Erro "
        GERALOG()
        FT_FUSE()
        Return
    ENDIF

    FT_FUSE()
    ProcRegua(nTotal)

    For _nLoop := 1 to Len(aDadosLi)
        cLogWrite := ''

        IncProc("Registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        
        _cVal  := StrTran(aDadosLI[_nLoop][13],_cCaract," ") 
        _cVal  := StrTran(_cVal,_cCarp," ")
        _cVal  := StrTran(_cVal,_cCarv,".") 
        _cVal  := StrTran(_cVal, " ", "")
        
        cFor      := 	aRetP[2]
        cLoja     :=	aRetP[3]
        cTes      := 	aRetP[4]
        cCondP    := 	aRetP[5]
        cProd     := 	aRetP[6]
        cCusto    := 	aRetP[7]
        cFatura   := 	aRetP[8]
        cItens    :=    '0000'

        _cNota   := PadL( AllTrim( aDadosLI[_nLoop][01] ) , TamSX3( "F1_DOC"     )[1],"0")
        _cSerie  := PadR( AllTrim( aDadosLI[_nLoop][02] ) , TamSX3( "F1_SERIE"   )[1],"")
        _dData   := CTOD(aDadosLI[_nLoop][03])
        _cCont   := PadR( AllTrim( aDadosLI[_nLoop][04] ) , TamSX3( "D1_XCONT"   )[1],"")
        _nValTot := Val(_cVal)     //Val(Substring(aDados[13],_nPos+3,(LEN(aDados[13])-4)))
        _cChave  := PadR( AllTrim( aDadosLI[_nLoop][22] ) , TamSX3( "F1_CHVNFE"  )[1],"")
        _cMunOri := PadR( AllTrim( aDadosLI[_nLoop][23] ) , TamSX3( "F1_MUORITR" )[1],"")
        _cUfOri  := PadR( AllTrim( aDadosLI[_nLoop][24] ) , TamSX3( "F1_UFORITR" )[1],"")
        _cMunDes := PadL( AllTrim( aDadosLI[_nLoop][25] ) , TamSX3( "F1_MUDESTR" )[1],"0")
        _cUfDes  := PadR( AllTrim( aDadosLI[_nLoop][26] ) , TamSX3( "F1_UFDESTR" )[1],"")

        If Empty(_cNota) .OR. _cNota = "000000000"
            cLogWrite := " Número de NF inválido. " + cProd 
            cStatus   := " Erro "
            GERALOG()
            Exit
        Endif

        IncProc("Montando dados de entrada...")

        cItens := Soma1(cItens,4)
        aTemp  := {}

        Begin Transaction
            If Len(aCab) == 0
                aAdd(aCab,{"F1_FILIAL"	,xFilial("SF1")          ,Nil})
                aAdd(aCab,{"F1_TIPO"	,"N"	                 ,Nil})
                aAdd(aCab,{"F1_FORMUL"	,"N"                     ,Nil})
                aAdd(aCab,{"F1_DOC"		,_cNota                  ,Nil})//_cNota
                aAdd(aCab,{"F1_SERIE"	,_cSerie                 ,Nil})// coloca no layout
                aAdd(aCab,{"F1_EMISSAO"	,_dData                  ,Nil})
                aAdd(aCab,{"F1_DTDIGIT"	,dDataBase		   	     ,Nil})
                aAdd(aCab,{"F1_FORNECE"	,cFor                    ,Nil})//cFor
                aAdd(aCab,{"F1_LOJA"	,cLoja   	             ,Nil})//cLoja
                aAdd(aCab,{"F1_ESPECIE"	,"CTE"                   ,NIL})
                aAdd(aCab,{"F1_COND"	,cCondP			         ,Nil})//cCondP
                aAdd(aCab,{"F1_CHVNFE"	,_cChave                 ,NIL})
                aAdd(aCab,{"F1_TPCTE"   ,"N"                     ,NIL})
                aAdd(aCab,{"F1_XFATURA" ,cFatura                 ,NIL})
                aAdd(aCab,{"F1_UFORITR" ,_cUfOri                 ,NIL})
                aAdd(aCab,{"F1_MUORITR" ,_cMunOri                ,NIL})//_cMunOri
                aAdd(aCab,{"F1_UFDESTR" ,_cUfDes                 ,NIL})
                aAdd(aCab,{"F1_MUDESTR" ,_cMunDes                ,NIL})//_cMunDes
            Endif

            aAdd(aTemp,{"D1_FILIAL"   ,xFilial("SF1")    			            ,Nil})
            aAdd(aTemp,{"D1_TIPO"     ,"N"						                ,Nil})
            aAdd(aTemp,{"D1_COD"      ,cProd      				            	,Nil})
            aAdd(aTemp,{"D1_ITEM"     ,cItens						            ,Nil})
            aAdd(aTemp,{"D1_UM"       ,"UN"         			                ,Nil})
            aAdd(aTemp,{"D1_CC"       ,cCusto					                ,Nil})
            aAdd(aTemp,{"D1_LOCAL"    ,_cLocal 						            ,Nil})
            aAdd(aTemp,{"D1_QUANT"    , 1									    ,Nil})
            aAdd(aTemp,{"D1_VUNIT"    ,_nValTot                            		,Nil})
            aAdd(aTemp,{"D1_TOTAL"    ,_nValTot                            		,Nil})
            aAdd(aTemp,{"D1_TES"      ,cTes                     				,Nil})
            aAdd(aTemp,{"D1_DOC"      ,_cNota					                ,Nil})
            aAdd(aTemp,{"D1_SERIE"    ,_cSerie   	         		    		,Nil})
            aAdd(aTemp,{"D1_FORNECE"  ,cFor		         			            ,Nil})
            aAdd(aTemp,{"D1_LOJA"     ,cLoja			         	     	    ,Nil})
            aAdd(aTemp,{"D1_EMISSAO"  ,_dData   						        ,Nil})
            aAdd(aTemp,{"D1_DTDIGIT"  ,dDataBase						        ,Nil})
            aAdd(aTemp,{"D1_XCONT"    ,_cCont						            ,Nil})

            aAdd(aIteNFE,aclone(aTemp))

            lMsErroAuto := .F.

            If !Empty(aCab) .And. !Empty(aIteNFE)
                msExecAuto({|x,Y,Z|mata103(x,Y,Z)},aCab,aIteNFE,3)
                //If lMsErroAuto

                SF1->(DbSetOrder(1))
                If (!SF1->(DbSeek(xFilial("SF1") + _cNota + _cSerie + cFor + cLoja )) .AND. lMsErroAuto = .T.)

                    MostraErro()
                
                    aErro := GetAutoGRLog() //Retorna erro em array
                    _cLog := Alltrim(AllToChar( aErro[1] )) + Alltrim(_cNota)
                    GERALOG()
                Else
                    _cLog := "[ZCOMF036] - Documento Gerado Num.: " + Alltrim(_cNota)
                    cStatus := " OK "
                    GERALOG()
                Endif
            Else
                MsgInfo( "Não foi possivel gerar as notas, realizar novo processamento.", "[ ZCOMF036 ] - Aviso" )
            EndIf

        End Transaction

        aIteNFE := {}
        aCab    := {}

    Next _nLoop 

    FT_FUSE("TRB1")

RETURN()


/*/{Protheus.doc} ZCOMF036
Importacao de planilha e geracao de CTE
@param  	Numero Origem e Município Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
@return  	NIL
@obs        Grava log das inconsistencias encontradas
@project
@history
/*/
Static Function GERALOG()
    dbSelectArea("TRB1")
    If !dbSeek(_cLog)
        RecLock("TRB1",.T.)
        TRB1->NOTA         := _cNota
        TRB1->LOG          := _cLog
        TRB1->EMISSAO      := _dData
        /*TRB1->SERIE        := _cSerie
        TRB1->CONTEINER    := _cCont
        TRB1->VLR.FRETE    := _nValTot
        TRB1->CHAVE        := _cChave
        TRB1->UF_ORIGEM    := _cUfOri
        TRB1->MUN_ORIGEM   := _cMunOri
        TRB1->UF_DESTINO   := _cUfDes
        TRB1->MUN_DESTINO  := _cMunDes
        TRB1->LOG          := _cLog*/
        TRB1->( msUnlock() )
    Endif

Return()


/*/{Protheus.doc} ZCOMF036
Importacao de planilha e geracao de CTE
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
@return  	NIL
@obs        Imprime Log das Inconsistencias encontradas
@project
@history
/*/
Static Function IMPEXC()
    Local oReport
    Private _cQuebra := " "

    If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
        oReport := ReportDef()
        oReport:SetTotalInLine(.F.)
        oReport:PrintDialog()
    EndIf

Return()


/*/{Protheus.doc} ZCOMF036
Importacao de planilha e geracao de CTE
@param  	Numero Origem e Município Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
@return  	NIL
@obs        Impressão Log das Inconsistencias encontradas
@project
@history
/*/
Static Function ReportDef()
    Local oReport
    Local oSection1

    oReport := TReport():New("IMPEXC","Log",,{|oReport| PrintReport(oReport)},"Este relatorio irá imprimir Log")

    oSection1 := TRSection():New(oReport,OemToAnsi("Log"),{"TRB1"})

    TRCell():New(oSection1,"LOG","TRB1","LOG","@!",280)
    TRCell():New(oSection1,"EMISSAO","TRB1","EMISSAO",PesqPict("SF1","F1_EMISSAO"),TamSX3("F1_EMISSAO")[1],/*lPixel,{|| (TRB1)->EMISSAO }*/)

    oSection1:Cell("LOG")     :SetHeaderAlign("RIGHT")
    oSection1:Cell("EMISSAO") :SetHeaderAlign("RIGHT")
    	
Return oReport


/*/{Protheus.doc} ZCOMF036
Importacao de planilha e geracao de CTE
@param  	Numero Origem e Município Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
@return  	NIL
@obs        Processo de Impressão Log das Inconsistencias encontradas
@project
@history
/*/
Static Function PrintReport(oReport)

    Local oSection1 := oReport:Section(1)

    oSection1:SetTotalInLine(.F.)
    oSection1:SetTotalText("Total Geral  ")  // Imprime Titulo antes do Totalizador da Seção
    oReport:OnPageBreak(,.T.)

// Impressao da Primeira secao
    DbSelectArea("TRB1")
    DbGoTop()

    oReport:SetMeter(RecCount())
    oSection1:Init()
    While  !Eof()
        If oReport:Cancel()
            Exit
        EndIf
        oSection1:PrintLine()

        DbSelectArea("TRB1")
        DbSkip()
        oReport:IncMeter()
    EndDo
    oSection1:Finish()

Return
