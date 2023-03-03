//-------------------------------------------------------------------
/*/{Protheus.doc}

@description    Efetua a conversao para csv da primeira planilha passada como parametro
@author         @walterfcarvalho
@since          16/08/2020
@version        1.00
/*/
//-------------------------------------------------------------------

#INCLUDE 'PROTHEUS.CH'
#include "shell.ch"
#INCLUDE 'TOTVS.CH'


User function xlsxToArr(cArq, cIdPlan, cDelimiter)
    Local oProcess  := nil
    Local aRes      := nil
    Local lEnd      := .F.

    Default cIdPlan := "1"
    Default cArq    := ""
    Default cDelimiter := ","

    oProcess := MsNewProcess():New({|lEnd| aRes:= Converter(cArq, cIdPlan, cDelimiter, @oProcess, @lEnd)  },"Extraindo dados da planilha XLSX","Efetuando a leitura do arquivo xlsx...", .T.)

    oProcess:Activate()

Return aRes

Static Function Converter(cArq, cIdPlan, cDelimiter, oProcess, lEnd)
    Local i         := 1
    Local aLines    := {}
    Local oFile     := Nil
    Local nPassos   := 0
    Local nShell    := 0
    Local cMsgHead  := "xlsxToArr()"
    Local aRes      := {}
    Local cExe      := "xlsxToCsv.exe"
    Local cArqCsv   := ""
    Local cArqTmp   := ""
    Local aLinha    := {}
    Local aPrm      := {}
    Local lManterVazio := .T.  
    Private aRtPrm    := {}

    //setar o delimitador  
    If cDelimiter <> ";"
       cDelimiter := ","		
    EndIf

    //Testar se existe excel instalado na maquina
     If ApOleClient("MsExcel") = .F.
        ApMsgStop("N�o detectei excel instalado na m�quina:", cMsgHead)
        Return aRes
    EndIf
    
    // Se nao enviar cArq, abre dialogo para escolher o arquivo
    If Empty(cArq) = .T.
  
        Aadd(aPrm , {6, "Arquivo", Space(1024), "", "", "", 90, .F., "Planilha Excel|*.xlsx|Arquivo Excel 2003|*.xls", Strtran(GetTempPath(), "\AppData\Local\Temp\", "")})
        Aadd(aPrm, {1, "Planilha (primeira � 1)", "01",   "@E 99",   "", "", "", 50, .T.})
        If ParamBox(aPrm, "Dados do embarque:", aRtPrm, , , , , , , , 50, .T.) = .T.
            cArq    := aRtPrm[1]
            cIdPlan := AllTrim(cValToChar(aRtPrm[2]))
        Else
            ApMsgStop("Importacao Cancelada:", cMsgHead)
            Return aRes
        EndIf
    EndIf

    // Gere o nome do arquivo CSV temporario
    cArqCsv := GetTempPath() + zArqSemExt(cArq) + ".csv"
    cArqTmp := GetTempPath() + zArqSemExt(cArq) + ".tmp"

    FErase(cArqCsv)
    FErase(cArqTmp)

    // Valida se o arquivo informado existe
    If File(cArq,/*nWhere*/,.T.) = .F.
        ApMsgStop("Arquivo n�o encontrado:" + cArq, cMsgHead)
        Return aRes
    EndIf

    oProcess:SetRegua1(4)
    oProcess:SetRegua2(2)

    oProcess:IncRegua1("1/4 Baixar xlsxTocsv.exe")
    oProcess:IncRegua2("")

    // Pega do servidor o arquivo que vai converter o xlsx  para csv
    If CpyS2T("\system\xlsxtocsv.exe", GetClientDir(), .F., .F.) = .F.
        ApMsgStop('N�o foi poss�vel baixar o conversor do servidor, em "\system\"' + cExe, cMsgHead)
        Return aRes
    EndIf

    oProcess:IncRegua1("2/4 Arq CSV temporario")
    oProcess:SetRegua2(20)

    nShell := Shellexecute('open', '"' + GetClientDir() + cExe + '"', '"' + Alltrim(cArq) + '" "' + cIdPlan + '" "' + cDelimiter + '" ' , GetClientDir(), 0)

    While File(cArqCsv) = .F.
        nPassos += 1

        if lEnd = .T.    //VERIFICAR SE N�O CLICOU NO BOTAO CANCELAR
            ApMsgStop("Processo cancelado pelo usu�rio." + cArq, cMsgHead)
            Return aRes
        EndIf

        If nPassos = 50
            ApMsgStop("A convers�o excedeu o tempo limite para o arquivo" + cArq, cMsgHead)
            Return aRes
        EndIf

        oProcess:IncRegua2("Convertendo arquivo...")

        If nShell = -1 .Or. nShell = 2
            ApMsgStop("N�o foi poss�vel efetuar a convers�o do arquivo." + cArq, cMsgHead)
            Return aRes
        Else
            Sleep(1000)
        EndIf

    EndDo

    oFile := FWFileReader():New(cArqCsv)

    If oFile:Open() = .F.
        ApMsgStop("N�o foi poss�vel efetuar a leitura do arquivo." + cArq, cMsgHead)
        Return aRes
    EndIf

    aLines := oFile:GetAllLines()

    if lEnd = .T.   //VERIFICAR SE N�O CLICOU NO BOTAO CANCELAR
        ApMsgStop("Processo cancelado pelo usu�rio." + cArq, cMsgHead)
        Return aRes
    EndIf


    oProcess:IncRegua1("3/4 Ler Arquivo CSV")
    oProcess:SetRegua2(Len(aLines))

    For i:=1 to len(aLines)

        if lEnd = .T.    //VERIFICAR SE N�O CLICOU NO BOTAO CANCELAR
            ApMsgStop("Processo cancelado pelo usu�rio." + cArq, cMsgHead)
            Return {}
        EndIf
        
        if i % 10 = 0
            oProcess:IncRegua2("Lendo registro " + CvalToChar(i) + " de " + cValToCHar(Len(aLines)) )
        EndIf            

        cLinha  := aLines[i]

        If Empty(cLinha) = .F.
            cLinha := StrTran(cLinha, '"', '')

            aLinha := Separa(cLinha, ",", lManterVazio)

            If Len(aLinha) > 0
                Aadd( aRes, aLinha )
            EndIf    
        EndIf
    Next

    oFile:Close()

    oProcess:IncRegua1("4/4 Remove temporarios")
    oProcess:SetRegua2(1)
    oProcess:IncRegua2("")

    FErase(cArqCsv)
    FErase(cArqTmp)

Return aRes

 Static Function zArqSemExt(cArq)
    Local i          := 1
    Local nPosPonto  := 1
    Local nPosBarra  := 1
//    Local cRes       := ""

    For i:= Len(cArq) to 1 step -1
        if Substr(cArq, i) = "."
            nPosPonto := i
            Exit
        EndIf
    Next

    For i:= Len(cArq) to 1 step -1
        if Substr(cArq, i) = "\"
            nPosBarra := i
            Exit
        EndIf
    Next    

Return  Substr(cArq, nPosBarra + 1,    nPosPonto - nPosBarra -1  )

