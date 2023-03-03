#INCLUDE "TOTVS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XML001    ºAutor  ³João Carlos         º Data ³  25/11/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geração e Envio das Tabelas de Preço por UF para a Sefaz.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Caoa                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XML001()

If MsgYesNo("Confirma a Geração e Envio das Tabelas de Preço por UF para a Sefaz ??")
	MSAguarde( { || fGeraXml() }, "Aguarde!", "Gerando arquivo(s) ...", .F. )
EndIf

Return(.t.)
//-----------------------------------------------------------------------------

Static Function fGeraXml()
Local cVersao :=""
Local cCgc    :=""
Local cIEst   :=""
Local cNome   :=""
Local cVa     :=""
Local cProd   :=""
Local cDesc   :=""
Local cPot    :=""
Local cCilin  :=""
Local cTpComb :=""
Local cCEst   :=""
Local cNcm    :=""
Local cEan    :=""
Local cEanTrib:=""
Local cUniMed :=""
Local cUniTrib:=""
Local cAnoMod :=""
Local cAnoFab :=""
Local cUf     :=""
Local cPreco  :=""
Local cIniTra :=""
Local cIniAnt :=""
Local cDirXml :=AllTrim(GetMV("MV_XDIRXML"))
Local cArqXml :=""
Local cDirLog :=AllTrim(GetMV("MV_XDIRXML"))
Local cArqLog :=""
Local cCodMar :=""
Local cModVei :=""
Local cSegMod :=""
Local aTabVVP :={}
Local aTabUF  :={}
Local cDataHora:=DtoS(dDataBase)+"_"+StrTran(Time(),":","")
Local aRet := {}
Local aParamBox := {}
Local nAno := Year(dDataBase)
Local nMes := Month(dDataBase)
Local cNextAlias := GetNextAlias()
Local dLimite := cTod("")
Local lPassou := .F.
Local nPos	:= 0

AAdd(aParamBox	, {1, "Ano:" ,nAno	, "@E 9999"	,"!Empty(mv_par01) .and. (mv_par01 >= 2020 .and. mv_par01 <= 2050)"  ,"","", 050, .T.	})
AAdd(aParamBox	, {1, "Mês:" ,nMes  , "@E 99"	,"!Empty(mv_par02) .and. (mv_par02 >= 1 .and. mv_par02 <= 12)"  ,"","", 050, .T.	})

If !ParamBox(aParambox, "Parâmetros"	, @aRet, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .F. /*lUserSave*/)
	Return()
Endif

nAno := aRet[1]
nMes := aRet[2]
dLimite := cTod(Alltrim(Str(Day(LastDay(cTod("01/"+StrZero(nMes,2)+"/"+Alltrim(Str(nAno)))))))+"/"+StrZero(nMes,2)+"/"+Alltrim(Str(nAno)))

cVersao := "0100"
cCgc    := Alltrim(SM0->M0_CGC) //"3471344000177"
//cIEst   := Alltrim(SM0->M0_INSC) //"809000385110"
cNome   := Alltrim(SM0->M0_NOMECOM) //"CAOA MONTADORA DE VEICULOS LTDA"

aTabUF  :={}

ZC0->(dbSetOrder(1))  //ZC0_FILIAL+ZC0_UF+ZC0_SEQUEN
ZC0->(dbGoTop())
While ZC0->(!Eof())
	If ZC0->(ZC0_STATUS=="2")  //Status: 1=Ativo,2=Inativo
		ZC0->(dbSkip())
		Loop
	EndIf
	nPos:=ZC0->(Ascan(aTabUF,{|x| x[1]==ZC0_UF}))
	If nPos==0
		ZC0->(AAdd(aTabUF,{ZC0_UF,AllTrim(ZC0_EMAIL),.F.,AllTrim(ZC0_INSCR)}))
	Else
		aTabUF[nPos,2]+=";"+AllTrim(ZC0->ZC0_EMAIL)
	EndIf
	ZC0->(dbSkip())
End

VV2->(dbSetOrder(1))  //VV2_FILIAL+VV2_CODMAR+VV2_MODVEI+VV2_SEGMOD
SB1->(dbSetOrder(1))  //VV2_FILIAL+VV2_CODMAR+VV2_MODVEI+VV2_SEGMOD
VVP->(dbSetOrder(1))
CLO->(dbSetOrder(1))

MakeDir(cDirXml)  //Cria a pasta onde serão gravados os arquivos XML

For nPos:=1 to Len(aTabUF)
	If Empty(aTabUF[nPos][4])
		If CLO->(dbSeek(xFilial("CLO")+aTabUF[nPos,1])) .and. !Empty(CLO->CLO_INSCR)
			cIEst := Alltrim(CLO->CLO_INSCR)
		Else
			Alert("Não encontrado 'Inscrição Estadual' cadastrada para o Estado: "+aTabUF[nPos,1]+" nas tabelas 'CLO/ZC0'. O arquivo deste Estado não será gerado.")
			Loop
		Endif		
	Else
		cIEst := Alltrim(aTabUF[nPos][4])
	Endif

	cArqLog:=cDirLog+"tabpreco_"+cDataHora+".txt"
	cArqXml:=cDirXml+"tabpreco_"+cDataHora+"_"+aTabUF[nPos,1]+".xml"
	If File(cArqXml)
		FErase(cArqXml)
	EndIf

	fGravaXml(cArqXml,"<enviPSCF>")
	fGravaXml(cArqXml,"    <versao>",cVersao,"</versao>")
	fGravaXml(cArqXml,"    <dadosDeclarante>")
	fGravaXml(cArqXml,"        <CNPJ>",cCgc,"</CNPJ>")
	fGravaXml(cArqXml,"        <IEST>",cIEst,"</IEST>")
	fGravaXml(cArqXml,"        <razaoSocial>",cNome,"</razaoSocial>")
	fGravaXml(cArqXml,"    </dadosDeclarante>")

    BeginSql Alias cNextAlias
    SELECT VVP_FILIAL,VVP_CODMAR,VVP_MODVEI,VVP_SEGMOD,VVP_FABMOD,VVP_DATPRC,R_E_C_N_O_ VVP_RECNO
    FROM %Table:VVP% VVP
    WHERE
    VVP.%NotDel%
    AND VVP_FILIAL = %Exp:xFilial("VVP")%
	AND VVP_DATPRC = 
	(
		SELECT MAX(VVP_DATPRC) VVP_DATPRC
		FROM %Table:VVP% VVP1
		WHERE
		VVP1.%NotDel%
		AND VVP1.VVP_FILIAL = VVP.VVP_FILIAL
		AND VVP1.VVP_CODMAR = VVP.VVP_CODMAR
		AND VVP1.VVP_MODVEI = VVP.VVP_MODVEI
		AND VVP1.VVP_SEGMOD = VVP.VVP_SEGMOD
		AND VVP1.VVP_FABMOD = VVP.VVP_FABMOD
		AND VVP1.VVP_DATPRC <= %Exp:dTos(dLimite)%
	)
    GROUP BY VVP_FILIAL,VVP_CODMAR,VVP_MODVEI,VVP_SEGMOD,VVP_FABMOD,VVP_DATPRC,R_E_C_N_O_
	ORDER BY VVP_FILIAL,VVP_CODMAR,VVP_MODVEI,VVP_SEGMOD,VVP_FABMOD,VVP_DATPRC,R_E_C_N_O_
    EndSql

    While (cNextAlias)->(!EOF())
        VVP->(dbGoto((cNextAlias)->VVP_RECNO))
        If VVP->(Recno()) == (cNextAlias)->VVP_RECNO
			cCodMar := VVP->VVP_CODMAR
			cModVei := VVP->VVP_MODVEI
			cSegMod := VVP->VVP_SEGMOD

			aTabVVP:=fTrazVVP(cCodMar,cModVei,cSegMod)  //Traz campos da tabela de preço

			If VV2->(dbSeek(xFilial("VV2")+cCodMar+cModVei))  //Posiciona no VV2
				If SB1->(dbSeek(xFilial("SB1")+Alltrim(cModVei)+Alltrim(cSegMod)))  //Posiciona no VV2

					aTabUF[nPos][3] := .T.

					cVa     := "VA"  //VA=Veículo Automotor,AC=Acessório
					cProd   := Alltrim(VVP->VVP_MODVEI)+Alltrim(VVP->VVP_SEGMOD)
					cDesc   := VV2->VV2_DESMOD
					cPot    := AllTrim(Transform(VV2->VV2_POTMOT,"@E 999,999,999.9")) // VV2_POTMOT
					cCilin  := AllTrim(Transform(VV2->VV2_CILMOT,"@E 999,999,999.9")) // VV2_CILMOT
					cTpComb := DeParaComb(VV2->VV2_COMVEI)
					cCEst   := SB1->B1_CEST
					cNcm    := SB1->B1_POSIPI
					cEan    := ""
					cEanTrib:= ""
					cUniMed := "Un"
					cUniTrib:= "Un"
					cAnoMod := AllTrim(Subs(VVP->VVP_FABMOD,5,4)) // VVP_FABMOD
					cAnoFab := AllTrim(Subs(VVP->VVP_FABMOD,1,4)) // VVP_FABMOD
					cUf     := aTabUF[nPos,1]
					cPreco  := AllTrim(Str(Int(aTabVVP[Len(aTabVVP),1])))
					cIniTra := Transform(DtoS(aTabVVP[Len(aTabVVP)  ,2]),"@R XXXX-XX-XX")
					cIniAnt := Transform(DtoS(aTabVVP[Len(aTabVVP)-1,2]),"@R XXXX-XX-XX")
			
					fGravaXml(cArqXml,"    <listaProdutos>")
					fGravaXml(cArqXml,"        <produto>")
					fGravaXml(cArqXml,"            <VA_AC>",AllTrim(cVa),"</VA_AC>")
					fGravaXml(cArqXml,"            <cProd>",AllTrim(cProd),"</cProd>")
					fGravaXml(cArqXml,"            <xProd>",AllTrim(cDesc),"</xProd>")
					fGravaXml(cArqXml,"            <pot>",AllTrim(cPot),"</pot>")
					fGravaXml(cArqXml,"            <cilin>",AllTrim(cCilin),"</cilin>")
					fGravaXml(cArqXml,"            <tpComb>",AllTrim(cTpComb),"</tpComb>")
					fGravaXml(cArqXml,"            <CEST>",AllTrim(cCEst),"</CEST>")
					fGravaXml(cArqXml,"            <NCM>",AllTrim(cNcm),"</NCM>")
					fGravaXml(cArqXml,"            <cEAN>",AllTrim(cEan),"</cEAN>")
					fGravaXml(cArqXml,"            <cEANTrib>",AllTrim(cEanTrib),"</cEANTrib>")
					fGravaXml(cArqXml,"            <uCom>",AllTrim(cUniMed),"</uCom>")
					fGravaXml(cArqXml,"            <uTrib>",AllTrim(cUniTrib),"</uTrib>")
					fGravaXml(cArqXml,"            <anoMod>",AllTrim(cAnoMod),"</anoMod>")
					fGravaXml(cArqXml,"            <anoFab>",AllTrim(cAnoFab),"</anoFab>")
					fGravaXml(cArqXml,"            <cUF>",AllTrim(cUf),"</cUF>")
					fGravaXml(cArqXml,"            <vuntrib>",AllTrim(cPreco),"</vuntrib>")
					fGravaXml(cArqXml,"            <INIC_TRAB>",AllTrim(cIniTra),"</INIC_TRAB>")
					fGravaXml(cArqXml,"            <INIC_TRAB_ANTERIOR>",AllTrim(cIniAnt),"</INIC_TRAB_ANTERIOR>")
					fGravaXml(cArqXml,"        </produto>")
					fGravaXml(cArqXml,"    </listaProdutos>")
				Endif
			Endif		
		Endif	
		(cNextAlias)->(dbSkip())
	Enddo

	(cNextAlias)->(dbCloseArea())

	fGravaXml(cArqXml,"</enviPSCF>")

	If aTabUF[nPos][3]
		fGravaLog(cArqLog,DtoC(Date())+" "+Time()+" => "+"Arquivo gerado com sucesso: "+cArqXml)
		lPassou := .T.
	Endif	
Next

For nPos:=1 to Len(aTabUF)
	If !aTabUF[nPos][3]
		Loop
	Endif	
	cArqLog:=cDirLog+"tabpreco_"+cDataHora+".txt"
	cArqXml:=cDirXml+"tabpreco_"+cDataHora+"_"+aTabUF[nPos,1]+".xml"
	If !File(cArqXml)
		fConOut("Arquivo nao encontrado: "+cArqXml)
		Loop
	EndIf
	cFrom   :=""
	cTo     :=aTabUF[nPos,2]
	cCc     :=""
	cBcc    :=""
	cSubject:=OemToAnsi("XML Tabela de Preço")
	cBody   :=OemToAnsi("Tabela de Preço")
	fMail(cFrom,cTo,cCc,cBcc,cSubject,cBody,{cArqXml})
	fGravaLog(cArqLog,DtoC(Date())+" "+Time()+" => "+"Arquivo enviado com sucesso: "+cArqXml)
Next

If lPassou
	fLerLog(cArqLog)
Endif	

Return
//-----------------------------------------------------------------------------

Static Function fTrazVVP(cCodMar,cModVei,cSegMod)  //Traz campos da tabela de preço

Local aArea := {VVP->(GetArea())}
Local aTabVVP:={}

VVP->(dbSetOrder(1))  //VVP_FILIAL+VVP_CODMAR+VVP_MODVEI+VVP_SEGMOD+DTOS(VVP_DATPRC)
VVP->(dbSeek(xFilial("VVP")+cCodMar+cModVei+cSegMod))  //Posiciona no VVP
While VVP->(!Eof() .and. VVP_FILIAL+VVP_CODMAR+VVP_MODVEI+VVP_SEGMOD==xFilial("VVP")+cCodMar+cModVei+cSegMod)
	VVP->(AAdd(aTabVVP,{VVP_VALTAB,VVP_DATPRC}))
	VVP->(dbSkip())
End

Do Case
Case Len(aTabVVP)==0
	AAdd(aTabVVP,{0,CtoD("")})
	AAdd(aTabVVP,{0,CtoD("")})
Case Len(aTabVVP)==1
	AAdd(aTabVVP,{0,CtoD("")})
	aTabVVP[2,1]:=aTabVVP[1,1]
	aTabVVP[2,2]:=aTabVVP[1,2]
	aTabVVP[1,1]:=0
	aTabVVP[1,2]:=CtoD("")
EndCase

aEval(aArea,{|x| RestArea(x)})

Return(aTabVVP)
//-----------------------------------------------------------------------------

Static Function fGravaXml(cArqXml,cTagIni,cTexto,cTagFim)
fGravaLog(cArqXml,fAjustaTag(cTagIni,cTexto,cTagFim))
Return
//-----------------------------------------------------------------------------

Static Function fGravaLog(cArqLog,cMens)
Local nPosFim,nHandle,cBuffer

If !File(cArqLog)
	nHandle:=fCreate(cArqLog,0)
	If nHandle==-1
		Alert("LOG ERROR: "+nHandle+" ==> Nao foi possivel criar "+cArqLog)
		Return(.f.)
	EndIf
	fClose(nHandle)
EndIf

nHandle:=fOpen(cArqLog,2)

If fError()<>0
	Alert("LOG ERROR: "+fError()+" ==> Nao foi possivel abrir "+cArqLog)
	Return(.f.)
EndIf

cBuffer:=cMens+Chr(13)+Chr(10)

nPosFim:=fSeek(nHandle,0,2)  //Posiciona no Fim do Arquivo               

fWrite(nHandle,cBuffer,Len(cBuffer))

If fError()<>0
	Alert("LOG ERROR: "+fError()+" ==> Nao foi possivel gravar "+cArqLog)
	fClose(nHandle)
	Return(.f.)
EndIf

nPosFim:=fSeek(nHandle,0,2)  //Posiciona no Fim do Arquivo               

fClose(nHandle)

Return(.t.)
//-----------------------------------------------------------------------------

Static Function fAjustaTag(cTagIni,cTexto,cTagFim)
Local cRet:=""

Do Case
Case cTexto==Nil
	cRet:=cTagIni
Case Len(cTexto)==0
	cRet:=StrTran(cTagIni,">","/>")
Otherwise
	cRet:=cTagIni+cTexto+cTagFim
EndCase

Return(cRet)
//-----------------------------------------------------------------------------

Static Function fMail(cFrom,cTo,cCc,cBcc,cSubject,cBody,aFiles)
Local oServer
Local oMessage
Local nErro
Local cErro

Local cSmtp   := AllTrim(GetMV("MV_RELSERV"))
Local cConta  := AllTrim(GetMV("MV_RELACNT"))
Local xFrom   := AllTrim(GetMV("MV_RELFROM"))
Local cSenha  := AllTrim(GetMV("MV_RELPSW"))
//Local lAuth   := GetMV("MV_RELAUTH")
Local nTimeOut:= GetMV("MV_RELTIME")
Local nPorta  :=0

Local nPos    :=0

cSenha  := AllTrim(GetMV("MV_RELPSW"))

nPos:=At(":",cSmtp)
If nPos>0
	nPorta:=Val(Subs(cSmtp,nPos+1))
	cSmtp:=Subs(cSmtp,1,nPos-1)
EndIf

////////////////////////////////////////////////////////////////////////////////////////
If Empty(cFrom)
	cFrom:=xFrom
EndIf
If Empty(cFrom)
	cFrom:=cConta
EndIf
If nPorta==0
	nPorta:=587
EndIf
////////////////////////////////////////////////////////////////////////////////////////

oServer := TMailManager():New()

oServer:SetUseSSL(.f.)
oServer:SetUseTLS(.f.)

oServer:Init("",cSmtp,cConta,cSenha,0,nPorta)

nErro:=oServer:SetSmtpTimeOut(nTimeOut)
If nErro<>0
	fConOut( "Falha ao setar o time out: "+oServer:getErrorString(nErro) )
	Return .F.
EndIf

nErro:=oServer:SmtpConnect()
If nErro<>0
	fConOut( "Falha ao conectar SMTP: "+oServer:getErrorString(nErro) )
	Return .F.
EndIf

nErro:=oServer:SmtpAuth(cConta,cSenha)
If nErro<>0
	fConOut( "Falha autenticacao SMTP: "+oServer:getErrorString(nErro) )
	oServer:SmtpDisconnect()
	oServer:=Nil
	Return .F.
EndIf

oMessage := TMailMessage():New()
oMessage:Clear()

oMessage:cFrom   :=cFrom
oMessage:cTo     :=cTo
oMessage:cCc     :=cCc
oMessage:cBcc    :=cBcc
oMessage:cSubject:=cSubject
oMessage:cBody   :=cBody

oMessage:cDate   :=cValToChar(Date())

For nPos:=1 to Len(aFiles)
	nErro:=oMessage:AttachFile(aFiles[nPos])
	If nErro<>0
		fConOut( "Erro ao anexar o arquivo " + aFiles[nPos] + ": "+oServer:getErrorString(nErro) )
		Return .F.
	EndIf
Next

nErro:=oMessage:Send( oServer )
If nErro<>0
	cErro:=oServer:GetErrorString( nErro )
	fConOut( "Erro ao enviar o e-mail: " + cErro )
	Return .F.
EndIf

nErro:=oServer:SmtpDisconnect()
If nErro<>0
	fConOut( "Erro ao desconectar do servidor SMTP" )
	Return .F.
EndIf

Return(.t.)
//-----------------------------------------------------------------------------

Static Function fConOut(cMens)
ConOut(cMens)
MsgAlert(cMens)
Return
//-----------------------------------------------------------------------------

Static Function fLerLog(pArqTxt)
Local aTabAux
Local cDirTxt,cArqTxt,nRegistros

Local cDrive,cDir,cNome,cExt

SplitPath(pArqTxt,@cDrive,@cDir,@cNome,@cExt)

cDirTxt   :=cDrive+cDir
cArqTxt   :=cNome+cExt
nRegistros:=20

Processa({||aTabAux:=fLerTxt(cDirTxt,cArqTxt,nRegistros)},"Lendo "+cDirTxt+cArqTxt+"...")

fTelaMens(aTabAux,cDirTxt,cArqTxt)

Return
//-----------------------------------------------------------------------------

Static Function fTelaMens(aMens,cDirTxt,cArqTxt)
Local nPos
//Local bOk    :={||lRet:=.t.,oDlg:End()}
//Local bCancel:={||lRet:=.f.,oDlg:End()}
//Local oCourierNw:=TFont():New("Courier New",,,,.F.,,,,.F.,.F.)

//Local nPos   :=0
Local cMens  :=""

For nPos:=1 to Len(aMens)
	cMens+=aMens[nPos]+CRLF
Next

fTelaMemo("Log dos arquivos XML enviados: "+cArqTxt,cMens)  //Monta tela para um campo memo

Return
//-----------------------------------------------------------------------------

Static Function fTelaMemo(cTitulo,cMemo)  //Monta tela para um campo memo
Local oCourierNw:=TFont():New("Courier New",,,,.F.,,,,.F.,.F.)
Local oDlg,oMemo
While .t.
	Define MsDialog oDlg From 0,0 To 320,535+300 Title OemToAnsi(cTitulo) Pixel
	@ 007+00,10 Get oMemo VAR cMemo MEMO SIZE 250+50+50+50,100+25 OF oDlg Pixel FONT oCourierNw
	@ 130+10,115+25+25+25 BUTTON "Ok" SIZE 40,13 PIXEL OF oDlg ACTION (oDlg:End())
	Activate MsDialog oDlg CENTERED
	Exit
End
Return(cMemo)
//-----------------------------------------------------------------------------

Static Function fLerTxt(cDirTxt,cArqTxt,nRegistros)
Local aRet:={}
Local nHandle,cBuffer

ProcRegua(nRegistros) // Numero de registros a processar

nHandle:=FT_FUSE(cDirTxt+cArqTxt)  //Abre o Arquivo
If nHandle==-1
	MsgAlert("O arquivo nao pode ser aberto: "+AllTrim(cDirTxt+cArqTxt))
	Return(aRet)
EndIf

FT_FGOTOP()
While !FT_FEOF()
	IncProc()
	cBuffer:=FT_FREADLN()
	AAdd(aRet,cBuffer)
	FT_FSKIP()
End
FT_FUSE()  //Fecha o Arquivo

Return(aRet)
//-----------------------------------------------------------------------------

Static Function DeParaComb( cCombVV1 )

	Local cRetorno := ""

	Conout(" ")
	Conout(" DeParaComb ")
	Conout(" ")

	Do Case
	Case cCombVV1 == "0" ; cRetorno := "02" // Gasolina
	Case cCombVV1 == "1" ; cRetorno := "01" // Alcool
	Case cCombVV1 == "2" ; cRetorno := "03" // Diesel
	Case cCombVV1 == "3" ; cRetorno := "15" // Gas Natural
	Case cCombVV1 == "4" ; cRetorno := "16" // Alcool/Gasolina
	Case cCombVV1 == "5" ; cRetorno := "17" // Alcool/Gasolina/GNV
	Case cCombVV1 == "9" ; cRetorno := ""// Sem Combustivel
	Case cCombVV1 == "A" ; cRetorno := "04" // Gasogenio
	Case cCombVV1 == "B" ; cRetorno := "05" // Gas Metano
	Case cCombVV1 == "C" ; cRetorno := "06" // Eletrico/Fonte Interna
	Case cCombVV1 == "D" ; cRetorno := "07" // Eletrico/Fonte Externa
	Case cCombVV1 == "E" ; cRetorno := "08" // Gasol/Gas Natural Combustivel
	Case cCombVV1 == "F" ; cRetorno := "09" // Alcool/Gas Natural Combustivel
	Case cCombVV1 == "G" ; cRetorno := "10" // Diesel/Gas Natural Combustivel
	Case cCombVV1 == "H" ; cRetorno := "12" // Alcool/Gas Natural Veicular
	Case cCombVV1 == "I" ; cRetorno := "13" // Gasolina/Gas Natural Veicular
	Case cCombVV1 == "J" ; cRetorno := "14" // Diesel/Gas Natural Veicular    
	Case cCombVV1 == "K" ; cRetorno := "18" // Gasolina/Eletrico
	Case cCombVV1 == "L" ; cRetorno := "19" // Gasolina/Alcool/Eletrico
	EndCase 

Return cRetorno
//-----------------------------------------------------------------------------
