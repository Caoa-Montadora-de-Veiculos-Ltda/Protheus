#INCLUDE "DBSTRUCT.CH"
#include "Fileio.ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#include "totvs.ch"

#define F_BLOCK  512
#define KEY_ESC  27

/*/{Protheus.doc} ZESTF011
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	28/04/2020
@return  	NIL
@obs        Local cMainPath	:= GetMv("CMV_EST001")      
@project
@history    Importar ajustes de CM por Produto da planilha excel (gatilhado preco unit)
/*/
User Function ZESTF011()  
    Local cExtens   := "Arquivo CSV | *.CSV"
    Local cArq      := ""
    Local nOpca     := 0
    Local aPergs    := {}
    Local aLabol    := {}

    Private aArea     := GetArea()
    Private cMainPath := "C:\TEMP\" + space(20) //GetMv("CMV_EST001") + space(20)       //"C:\TEMP"  //"C:\Users\antonio.poliveira\Documents\Desenvolvimento\Tabelas"   //"C:\TEMP"   
    Private cArqLog	  := cMainPath+"\AJUSCM_"+DTOS(Date())+StrTran(Time(),":")+".LOG"
    Private cLogWrite := " " 
    Private cStatus   := ""
    Private cFileOpen := ""
    Private _nReco    := 0
    Private aRetP     := {}
    Private lRes      := .F.
    Private _lRetorno := .T.
    Private _dFecha   := GetMv("MV_ULMES")
    Private _dFecha1  := GetMv("MV_DBLQMOV")

    aadd(alabol , " Esta rotina realiza o Ajustes Custos")
    aadd(alabol , " ")
    aadd(aLabol , " 1. Layout -> TM;EMISSAO;PRODUTO;LOCAL;CUSTO;OBSERVAÇÃO")
    aadd(aLabol , " 2. Delimitador dos campos com ;(ponto e vírgula)")
    aadd(aLabol , " 3. Separador de decimal no campo CUSTO com ,(vírgula)")
    aadd(aLabol , " 4. Um arquivo por TM e EMISSAO")
    aadd(aLabol , " ")
    aadd(aLabol , " Confirma Processo ? ")

    //aAdd( aPergs ,{1,"Data de Procesamento ",_dDtFim      ,"   ","U_TestaDT()","   " ,'.T.',80,.F.})
    aAdd( aPergs ,{6,"Selecione arquivo "   ,cMainPath    ,"@!" ,     ,'.T.' ,50,.T.,cExtens })

    nLin := 20
    DEFINE MSDIALOG oDlg FROM  96,9 TO 350,592 TITLE OemToAnsi("Ajuste Custos") PIXEL
    
        @ 18, 6 TO 100, 287 LABEL "" OF oDlg  PIXEL
        @ nLin, 15 SAY OemToAnsi( aLabol[01] ) SIZE 268, 8 OF oDlg PIXEL
        nLin += 10
        @ nLin, 15 SAY OemToAnsi( aLabol[02] ) SIZE 268, 8 OF oDlg PIXEL
        nLin += 10
        @ nLin, 15 SAY OemToAnsi( aLabol[03] ) SIZE 268, 8 OF oDlg PIXEL
        nLin += 10
        @ nLin, 15 SAY OemToAnsi( aLabol[04] ) SIZE 268, 8 OF oDlg PIXEL
        nLin += 10
        @ nLin, 15 SAY OemToAnsi( aLabol[05] ) SIZE 268, 8 OF oDlg PIXEL
        nLin += 10
        @ nLin, 15 SAY OemToAnsi( aLabol[06] ) SIZE 268, 8 OF oDlg PIXEL
        nLin += 10
        @ nLin, 15 SAY OemToAnsi( aLabol[07] ) SIZE 268, 8 OF oDlg PIXEL
        nLin += 10
        @ nLin, 15 SAY OemToAnsi( aLabol[08] ) SIZE 268, 8 OF oDlg PIXEL
        
        DEFINE SBUTTON FROM 110, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
        DEFINE SBUTTON FROM 110, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
    
    ACTIVATE MSDIALOG oDlg CENTER

    If nOpca == 0 
          Return()
    Endif
    
    if ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.)
       
        cArq := ALLTRIM(MV_PAR01)

        cFileOpen := cArq

        Processa({|| ZESTF011B(cFileOpen,@cArqLog) }, "[ZESTF011] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." )
                
        MSGINFO( "Processamento Finalizado!" )//+ CRLF +  "Para mais informações, verifique o arquivo de log: " + cArqLog )
	 
    Endif

Return Nil 

/*
==============================================================================================
Funcao.........:	ZESTF001B
Descricao......:	Faz a leitura do arquivo CSV e a gravação da tabela 
Autor..........:	A. Oliveira
Criação........:	28/04/2020
Alterações.....:    //4110108106  caso precise fixar conta contábil
===============================================================================================
*/
Static Function ZESTF011B(cFileOpen,cArqLog)
    Local cSepar        := ""
    Local nPasso        := 0
    Local nLoop         := 0
    Local nTotal        := 0
    Local aDados 		:= {}						// Array dos dados da linha do laco
    Local aDadosLi      := {}

    Private cLocal    	:= ""
    Private cCCC      	:= ""
    Private cConta		:= ""
    Private cUM         := ""
    Private cDoc  		:= ""
    Private cProduto	:= ""
    Private cTM    		:= ""
    Private cNumSeq     := ""
    Private cObserva    := "" 
    Private _cBlq       := ""
    Private _cArqTRB    := ""
    Private _cIndice    := ""
    Private _cChaveInd  := ""
    Private nQuant 		:= 0
    Private nCusto 		:= 0
    Private nAtual      := 0
    Private nValUn      := 0
    Private nCusto1		:= 0
    Private dDtRet      := 0
    Private _aStruLog   := {}
    Private _cUser      := Substr(cUserName,1,20)
    Private dDatEmi     := dDataBase
    Private _cMesProc   := Month(_dFecha)
    private lMsErroAuto := .F.
    Private lAutoErrNoFile := .T.


    AADD(_aStruLog,{"LINHA"      ,"C",006,0})
    AADD(_aStruLog,{"STATUS"     ,"C",010,0})
    AADD(_aStruLog,{"LOG"        ,"C",280,0})
    AADD(_aStruLog,{"FILIAL"     ,"C",010,0})
    AADD(_aStruLog,{"COD"        ,"C",023,0})
    AADD(_aStruLog,{"DOC"        ,"C",009,0})
    AADD(_aStruLog,{"UM"         ,"C",002,0})
    AADD(_aStruLog,{"QUANT"      ,"N",013,3})
    AADD(_aStruLog,{"CUSTO"      ,"N",014,2})
    AADD(_aStruLog,{"CUSTO1"     ,"N",014,2})   
    AADD(_aStruLog,{"ARMAZEM"    ,"C",003,0})
    AADD(_aStruLog,{"TM"         ,"C",003,0}) 
    AADD(_aStruLog,{"CONTA"      ,"C",020,0})     
    AADD(_aStruLog,{"CC"         ,"C",011,0})
    AADD(_aStruLog,{"NUMSEQ"     ,"C",006,0})   
    AADD(_aStruLog,{"EMISSAO"    ,"D",008,0})          
    AADD(_aStruLog,{"OBSERVA"    ,"C",240,0})             
            
    _cArqTRB   := Criatrab(_aStruLog,.T.)
    _cIndice   := CriaTrab(Nil,.F.)
    _cChaveInd := "LINHA"

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

    FT_FUSE(cFileOpen)
    FT_FGOTOP()
    
    cLinha := FT_FREADLN()
    cSepar := Substr(cLinha,4,1)
  
    If !(cSepar $ ";" )
        MsgInfo("Separador do arquivo invalido!!! " + cSepar)
        cLogWrite += ("Erro Separador do arquivo invalido! ")
        cStatus := " Erro "
        GERLOG()
        FT_FUSE()
        Return
    ENDIF

    //FT_FSKIP()
    lVal  := .F.
    cTM   := Space(3)
    cData := Space(8)

    DbSelectArea('SF5')
    SF5->(DbSetOrder(1))

    While !FT_FEOF()
        nTotal++
        cLinha := FT_FREADLN()	
        aDados := Separa(cLinha,cSepar)
        
        if len(aDados) <> 6
            MsgInfo("Layout invalido!!! " + cSepar)
            cLogWrite += ("Layout do arquivo invalido! ")
            lVal := .T.
        Endif
        
        if Empty(aDados[1]) .or.Empty(aDados[2]) .or.Empty(aDados[3]) .or.Empty(aDados[4]) .or.Empty(aDados[5]) 
            MsgInfo("Dados invalido!!! " + cSepar)
            cLogWrite += ("Dados invalido! ")
            lVal := .T.
        EndIf

        if Len(aDados[1]) <> 3
            MsgInfo("TM invalido!!! " + cSepar)
            cLogWrite += ("TM invalido! ")
            lVal := .T.
        else
            if Empty(cTM)
                cTM := aDados[1]
                if !(SF5->(DbSeek(xFilial('SF5')+cTM) ))
                    MsgInfo("Arquivo  invalido!!! TM não cadastrado " + cSepar)
                    cLogWrite += ("Arquivo  invalido!!! TM não cadastrado")
                    lVal := .T.
                ElseIf SF5->F5_VAL <> 'S' .and. SF5->F5_QTDZERO <> '1'
                    MsgInfo("Arquivo invalido!!! TM que movimenta Estoque não deve ser usada" + cSepar)
                    cLogWrite += ("Arquivo  invalido!!! TM que movimenta Estoque não deve ser usada")
                    lVal := .T.
                EndIf

            ElseIf cTM <> aDados[1]
                MsgInfo("Arquivo  invalido!!! Possuem TM diferente " + cSepar)
                cLogWrite += ("Arquivo  invalido!!! Possuem TM diferente")
                lVal := .T.
            endif
        endif
        
        if Len(aDados[2]) <> 8
            MsgInfo("Data invalido!!! " + cSepar)
            cLogWrite += ("Data invalido! ")
            lVal := .T.
        else
            if Empty(cData)
                cData:= aDados[2]
            ElseIf cData <> aDados[2]
                MsgInfo("Arquivo invalido!!! Possuem Datas diferentes " + cSepar)
                cLogWrite += ("Arquivo  invalido!!! Possuem Datas diferentes")
                lVal := .T.
            endif
        endif
        
        if ('.' $ aDados[5])
            MsgInfo("Valor invalido!!! " + cSepar)
            cLogWrite += ("Valor invalido! ")
            lVal := .T.
        endif
            
        if lVal
            cStatus := " Erro "
            GERLOG()
            FT_FUSE()
            Return
        EndIf
        
        aAdd(aDadosLi, aClone(aDados))

        FT_FSKIP()
    END

    FT_FUSE()
    ProcRegua(nTotal)

    cDoc := NextNumero("SD3",2,"D3_DOC",.T.)  //BUSCA NUMERACAO DO SD3

    For nLoop := 1 to Len(aDadosLi)
        
        lRes  := .T. //Inicializa a validação do produto
        nAtual++

        IncProc("Registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

        cProduto	:= Alltrim(aDadosLi[nLoop][03])     //Posição 03 Produto
        cLocal		:= aDadosLi[nLoop][04]              //Posição 04 Armazém
        nCusto      := VAL( StrTran(StrTran( aDadosLi[nLoop][05],".","" ), ",",".") )         //Posição 05 Valor Total
        nValUn      := VAL(aDadosLi[nLoop][04])         //Posição 04 Valor Unitário
        nCusto1     := nCusto
        cTM    	    := PadR(aDadosLi[nLoop][01] ,TamSX3("D3_TM"   )[1]," ")
        cCCC        := PadR(cCCC                ,TamSX3("D3_CC"   )[1]," ")
        cConta	    := PadR(cConta              ,TamSX3("D3_CONTA")[1]," ")
        cProduto    := PadR(cProduto            ,TamSX3("B1_COD"  )[1]," ")
        dDatEmi     := StoD(aDadosLi[nLoop][02])
        cObs        := aDadosLi[nLoop][06]  

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Verifica se existe  Produto ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        IF !EMPTY(cProduto)

            cObserva := "ZESTF011 " + _cUser + " " + Dtoc(Date()) + " " + Time()
            cLocal	 := PadR(cLocal,TamSX3("D3_LOCAL")[1]," ")
            cNumSeq  := PadL(cNumSeq,TamSX3("D3_NUMSEQ ")[1]," ")
            nPasso   := 0

            cObserva += " R.SD3"
            cObserva += "|" + cObs
            
            GrvProd()
            cStatus := " OK "
        
        ENDIF

    Next nLoop

    //*********************************************************************
    //      Chamada do relatório
    //*********************************************************************
    dbSelectArea("TRB1")
    dbGotop()
    If TRB1->(!EOF())
        Processa({|| IMPEXC() },"Gerando Relatorio de Log... "+"[ZESTF011]")
    Else
        cBuffer := Space(512)
    Endif

    RestArea(aArea) 
    FT_FUSE()

Return()


//==============================================================================================
//Funcao.........:	GrvProd()
//Descricao......:	Gravar o registro da SD3   13068560
//Autor..........:	A.Oliveira
//Criação........:	13/05/2020
//==============================================================================================
Static Function GrvProd()
    Local cNtEr     := 0
    Local nOpc      := 3
    Local aErro     := {} 
    Local aVetor    := {}

    Begin Transaction

		aVetor := {}
      
        aadd( aVetor, { "D3_FILIAL" , xFilial('SD3'), Nil } )
		aadd( aVetor, { "D3_DOC"    , cDoc          , Nil } )
		aadd( aVetor, { "D3_COD"    , cProduto      , Nil } )   //cProduto
		aadd( aVetor, { "D3_UM"     , cUM           , Nil } )   //cUM
		aadd( aVetor, { "D3_QUANT"  , 0             , Nil } )
        aadd( aVetor, { "D3_CUSTO1" , nCusto1       , Nil } )
		aadd( aVetor, { "D3_LOCAL"  , cLocal        , Nil } )   //cLocal
		aadd( aVetor, { "D3_TM"     , cTM           , Nil } )   //cTM
        aadd( aVetor, { "D3_CONTA"  , cConta        , Nil } ) 
        aadd( aVetor, { "D3_CC"     , cCCC          , Nil } )
       	aadd( aVetor, { "D3_EMISSAO", dDatEmi       , Nil } )
		aadd( aVetor, { "D3_OBSERVA", cObserva      , Nil } )
       
		MSExecAuto( { |x,y| MATA240( x , y ) }, aVetor, nOpc )
		
		If lMsErroAuto
            aErro := GetAutoGRLog()
            cStatus := " Erro "

			For cNtEr := 1 To Len(aErro)
				cLogWrite += AllTrim(aErro[cNtEr]) + chr(13) + chr(10)
			Next
			
		Else
            cLogWrite := ( " Cadastrado! " )
            cStatus := " OK "
            cNumSeq := SD3->D3_NUMSEQ
            ConfirmSx8() 
            //_lRetorno := .T.
        Endif
        GERLOG()
	End Transaction

Return()

/*/{Protheus.doc} ZCOMF006
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/05/2020
@return  	NIL
@obs        Grava log das inconsistencias encontradas
@project
@history
/*/
Static Function GERLOG()

    dbSelectArea("TRB1")

    IF cStatus = " Erro "
        
        RecLock("TRB1",.T.)
            TRB1->Linha     := StrZero(nAtual,6) 
            TRB1->COD       := cProduto        
            TRB1->ARMAZEM   := cLocal
            TRB1->CUSTO1    := nCusto1
            TRB1->STATUS    := cStatus
            TRB1->LOG       := cLogWrite
        TRB1->( msUnlock() )
    
    ELSE
    
        RecLock("TRB1",.T.)
            TRB1->Linha     := StrZero(nAtual,6) 
            TRB1->COD       := cProduto
            TRB1->ARMAZEM   := cLocal
            TRB1->CUSTO     := nCusto
            TRB1->CUSTO1    := nCusto1
            TRB1->STATUS    := cStatus
            TRB1->LOG       := cLogWrite
            TRB1->FILIAL    := xFilial("SD3")
            TRB1->DOC       := cDoc
            TRB1->UM        := cUM       
            TRB1->QUANT     := nQuant            
            TRB1->TM        := cTM           
            TRB1->CONTA     := cConta        
            TRB1->CC        := cCCC    
            TRB1->NUMSEQ    := cNUMSEQ     
            TRB1->EMISSAO   := dDatEmi
            TRB1->OBSERVA   := cObserva      
        TRB1->( msUnlock() )

    Endif
    
    GravaPen(cLogWrite)
    
Return()


Static Function GravaPen(cLogWrite)
    Local cCab := "LOG"
    
    If !File(cArqLog)
        nH := FCreate(cArqLog)
        FWrite(nH,cCab+Chr(13)+Chr(10),Len(cCab)+2)
    Else
        nH := FOpen(cArqLog,1)
    EndIf

    FSeek(nH,0,2)
    FWrite(nH,cLogWrite+Chr(13)+Chr(10),Len(cLogWrite)+2)
    FClose(nH)
    
    cLogWrite := " "
    cStatus   := " "

Return 


/*/{Protheus.doc} ZESTF001
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/05/2020
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
        oReport:nDevice := 4 //-- Gera arquivo em Planilha
        oReport:nEnvironment := 2 //-- Ambiente Local
        oReport:SetTotalInLine(.F.)
        oReport:PrintDialog()
    EndIf

Return()


/*/{Protheus.doc} ZESTF001
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/05/2020
@return  	NIL
@obs        Impressão Log das Inconsistencias encontradas
@project
@history
/*/
Static Function ReportDef()
    Local oReport
    Local oSection1
    Local cAlias := 'SD3'
    
    oReport := TReport():New("IMP","Log",,{|oReport| PrintReport(oReport)},"Este relatorio irá imprimir Log")
    oSection1 := TRSection():New(oReport,OemToAnsi("Log"),{"TRB"})

    TRCell():New(oSection1,"LINHA"  ,"TRB1","LINHA"  ,"@!",040)
    TRCell():New(oSection1,"COD"    ,"TRB1","COD"    ,PesqPict(cAlias,"D3_COD"   ) ,TamSX3("D3_COD"   )[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"ARMAZEM","TRB1","ARMAZEM",PesqPict(cAlias,"D3_LOCAL" ) ,TamSX3("D3_LOCAL" )[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"CUSTO"  ,"TRB1","CUSTO"  ,PesqPict(cAlias,"D3_CUSTO1") ,TamSX3("D3_CUSTO1")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"CUSTO1" ,"TRB1","CUSTO1" ,PesqPict(cAlias,"D3_CUSTO1") ,TamSX3("D3_CUSTO1")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"STATUS" ,"TRB1","STATUS" ,"@!"                         ,040)
    TRCell():New(oSection1,"LOG"    ,"TRB1","LOG"    ,"@!"                         ,280)
    TRCell():New(oSection1,"FILIAL" ,"TRB1","FILIAL" ,"@!"                         ,040)
    TRCell():New(oSection1,"DOC"    ,"TRB1","DOC"    ,PesqPict(cAlias,"D3_DOC"    ),TamSX3("D3_DOC"    )[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"UM"     ,"TRB1","UM"     ,PesqPict(cAlias,"D3_UM"     ),TamSX3("D3_UM"     )[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"QUANT"  ,"TRB1","QUANT"  ,PesqPict(cAlias,"D3_QUANT"  ),TamSX3("D3_QUANT"  )[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"TM"     ,"TRB1","TM"     ,PesqPict(cAlias,"D3_TM"     ),TamSX3("D3_TM"     )[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"CONTA"  ,"TRB1","CONTA"  ,PesqPict(cAlias,"D3_CONTA"  ),TamSX3("D3_CONTA"  )[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"CC"     ,"TRB1","CC"     ,PesqPict(cAlias,"D3_CC"     ),TamSX3("D3_CC"     )[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"NUMSEQ" ,"TRB1","NUMSEQ" ,PesqPict(cAlias,"D3_NUMSEQ" ),TamSX3("D3_NUMSEQ" )[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"EMISSAO","TRB1","EMISSAO",PesqPict(cAlias,"D3_EMISSAO"),TamSX3("D3_EMISSAO")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"OBSERVA","TRB1","OBSERVA",PesqPict(cAlias,"D3_OBSERVA"),TamSX3("D3_OBSERVA")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    
    oSection1:Cell("LINHA"  ):SetHeaderAlign("RIGHT")
    oSection1:Cell("COD"    ):SetHeaderAlign("RIGHT")
    oSection1:Cell("ARMAZEM"):SetHeaderAlign("RIGHT")
    oSection1:Cell("CUSTO"  ):SetHeaderAlign("RIGHT")
    oSection1:Cell("CUSTO1" ):SetHeaderAlign("RIGHT")
    oSection1:Cell("STATUS" ):SetHeaderAlign("RIGHT")
    oSection1:Cell("LOG"    ):SetHeaderAlign("RIGHT")
    oSection1:Cell("FILIAL" ):SetHeaderAlign("RIGHT")
    oSection1:Cell("DOC"    ):SetHeaderAlign("RIGHT")
    oSection1:Cell("UM"     ):SetHeaderAlign("RIGHT")
    oSection1:Cell("QUANT"  ):SetHeaderAlign("RIGHT")
    oSection1:Cell("TM"     ):SetHeaderAlign("RIGHT")
    oSection1:Cell("CONTA"  ):SetHeaderAlign("RIGHT")
    oSection1:Cell("CC"     ):SetHeaderAlign("RIGHT")
    oSection1:Cell("NUMSEQ" ):SetHeaderAlign("RIGHT")
    oSection1:Cell("EMISSAO"):SetHeaderAlign("RIGHT")
    oSection1:Cell("OBSERVA"):SetHeaderAlign("RIGHT")
    
Return oReport


/*/{Protheus.doc} ZESTF001
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/05/2020
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
