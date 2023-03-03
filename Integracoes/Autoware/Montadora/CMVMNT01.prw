#include "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"


/*
=====================================================================================
Programa.:              CMVMNT01
Autor....:              Marcelo Carneiro
Data.....:              11/10/2018
Descricao / Objetivo:   Monitor de Integrações
Doc. Origem:            Contrato 
Solicitante:            Cliente
Uso......:              CAOA
Obs......:              Tela de Monitor de Interface
=====================================================================================
*/

User Function xMonCAOA
//teste do monitor 
Private _aMatriz   := {"01","2010022001"}  
Private lIsBlind   :=  IsBlind() .OR. Type("__LocalDriver") == "U"

IF lIsBlind
   RpcSetType(3)
   RpcSetEnv(_aMatriz[1],_aMatriz[2])  

   //cFil,cStatus,cCodint,cCodtpint,cErro,cDocori,cTempo,cJSON,nRecnoDoc,cHTTP)
   U_CAOA_MONITOR( cFilant   ,;
			      '1',;  //Status
			      '001',; //cCodint
		          '002',;//cCodtpint
				  SUBSTR('Incluído com Sucesso',1,TamSX3("Z1_ERRO")[1]),; //cErro
			      '000001-01'  ,; //cDOcori
		          '0' ,;//cTempo
		          '',; //cJSON
		           0,; //Recno
		           '201')// HTTP
EndIF
		          
Return		          
*****************************************************************************************
User Function CMVMNT01()
	private cPerg     := Padr("CAOAMNT01",Len(SX1->X1_GRUPO))

	If !Pergunte(cPerg,.T.)
		return
	EndIf

	MonitorIntegr()
Return

/*
==================================================================================

==================================================================================
*/
User Function VLD_SZ2PERG()
	Local bRet   := .T.

	DbSelectArea("SZ2")
	SZ2->(DbSetOrder(1)) // Z2_CODIGO
	IF !SZ2->(dbSeek(xFilial("SZ2")+M->MV_PAR04)) .AND. !Empty(MV_PAR04)
		MsgAlert("Código de integração não cadastrado!!!")
		bRet := .F.
	EndIF

return bRet


/*
========================================================
Tela do Monitor
========================================================
*/
Static Function MonitorIntegr()
	Local nI
	Private oTimer
	Private cbLine
	Private oDlg2
	Private aBrowse      := {}
	Private aHeader      := {'Filial','Status','ID','Cnt.','Integra','C.Int.','Tipo Integr.','Erro','Data Exec.','Hora Exec.','Doc. Orig.','Tempo Proc.','Usu','Recno Doc.','HTTP'}
	Private aTam         := {20      ,20      ,40  ,20    ,65       ,20      ,80            ,140   ,35          ,35          ,50          ,40           ,40   , 30 ,20      }
	Private oBrowseDados
	Private aSize  	:= getScreenRes( )
	Private aPixela := MsAdvSize(.F.)
	Private aPixelb := {} 
	//Private nTimer := (GetNewPar("MGF_TIMER",5)*1000)
	Private nTimer := (MV_PAR10*1000)

	GridMonitor()

	aPixelb := { aPixela[ 1 ], aPixela[ 2 ], aPixela[ 3 ], aPixela[ 4 ], aPixela[ 5 ], aPixela[ 6 ] }

	DEFINE MSDIALOG oDlg2 FROM 0,0 TO aPixela[6],aPixela[5] TITLE "Monitor de Integração"  OF oMainWnd PIXEL

	oBrowseDados := TWBrowse():New(25,01,aPixela[3],aPixela[4],,,,oDlg2, , , ,,{||}, , , , ,,,.F.,,.T.,,.F.,,, )
	oBrowseDados:SetArray(aBrowse)
	cbLine := "{||{ aBrowse[oBrowseDados:nAt,01] "

	For nI := 2 To Len(aHeader)
		cbLine += ",aBrowse[oBrowseDados:nAt,"+STRZERO(nI,2)+"]"
	Next
	cbLine +="  } }"
	oBrowseDados:bLine      := &cbLine
	oBrowseDados:bHeaderClick  := {|oBrw,nCol| OrdenaCabMon(nCol,.T.)}

	oBrowseDados:addColumn(TCColumn():new(aHeader[01],{||aBrowse[oBrowseDados:nAt][01]},"@!"                       ,,,"LEFT"  ,aTam[01],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[02],{||aBrowse[oBrowseDados:nAt][02]},"@!"                       ,,,"LEFT"  ,aTam[02],.T.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[03],{||aBrowse[oBrowseDados:nAt][03]},"@!"                       ,,,"RIGHT" ,aTam[03],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[04],{||aBrowse[oBrowseDados:nAt][04]},"@!"                       ,,,"LEFT"  ,aTam[04],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[05],{||aBrowse[oBrowseDados:nAt][05]},"@!"                       ,,,"LEFT"  ,aTam[05],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[06],{||aBrowse[oBrowseDados:nAt][06]},"@!"                       ,,,"LEFT"  ,aTam[06],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[07],{||aBrowse[oBrowseDados:nAt][07]},"@!"                       ,,,"LEFT"  ,aTam[07],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[08],{||aBrowse[oBrowseDados:nAt][08]},"@!"                       ,,,"LEFT"  ,aTam[08],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[09],{||aBrowse[oBrowseDados:nAt][09]},"@!"                       ,,,"LEFT"  ,aTam[09],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[10],{||aBrowse[oBrowseDados:nAt][10]},"@!"                       ,,,"LEFT"  ,aTam[10],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[11],{||aBrowse[oBrowseDados:nAt][11]},"@!"                       ,,,"LEFT"  ,aTam[11],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[12],{||aBrowse[oBrowseDados:nAt][12]},"@!"                       ,,,"LEFT"  ,aTam[12],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[13],{||aBrowse[oBrowseDados:nAt][13]},"@!"                       ,,,"LEFT"  ,aTam[13],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[14],{||aBrowse[oBrowseDados:nAt][14]},"@E 999999999999999999"    ,,,"LEFT"  ,aTam[14],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[15],{||aBrowse[oBrowseDados:nAt][15]},"@!"                       ,,,"LEFT"  ,aTam[15],.F.,.F.,,,,,))

	//oBrowseDados:Setfocus()

	oTButton1 := TButton():New( 10, 001, "Atualizar"     ,oDlg2,{||oBrowseDados:Refresh()}, 50,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 := TButton():New( 10, 519, "Exportar JSON/XML"  ,oDlg2,{||EXPXML()}              , 50,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton3 := TButton():New( 10, 570, "Legenda"       ,oDlg2,{||LEGMONITOR()}          , 50,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton4 := TButton():New( 10, 621, "Fechar"        ,oDlg2,{||oDlg2:End()}           , 50,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	//oTButton5 := TButton():New( 10, 461, "Zera Flag Tent.",oDlg2,{||LimpaFlag()}          , 50,11,,,.F.,.T.,.F.,,.F.,,,.F. )

	//DEFINE TIMER oTimer INTERVAL 20000 Action AtuGrid() of oDlg2 //OBJETO PARA ATUALIZ AUTOMATICA DO GRID, NESSE CASO A CADA 20 SEGUNDOS
	oTimer := TTimer():New(nTimer, {|| AtuGrid() }, oDlg2 ) // VER12 SUBSTITUI O COMANDO "DEFINE TIMER"
	oTimer:Activate() // Ativa o timer automatico

	SetKey (VK_F12,{||FPERG03()})

	ACTIVATE MSDIALOG oDlg2 CENTERED //on INIT AtuGrid()

Return

/*
========================================================
Tecla F12
========================================================
*/

Static Function FPERG03()

	If !Pergunte(cPerg,.T.)
		return
	EndIf

	oDlg2:End()
	MonitorIntegr()
	SetKey (VK_F12,Nil)

Return

/*
========================================================
Legenda
========================================================
*/
Static Function LEGMONITOR()
	Local   aLegenda  := {}
	Private cCadastro := "Monitor de Integração"

	AADD(aLegenda,{"BR_VERDE" ,"Processo integrado com sucesso" })
	AADD(aLegenda,{"BR_VERMELHO" ,"Processo com erro de integração" })

	BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil


Static Function AtuGrid()

	Pergunte(cPerg,.F.)
	//Processa( {||GridMonitor(), oBrowseDados:Refresh() },"Processa","Processando..." )
	oDlg2:End()
	MonitorIntegr()
Return

/*
========================================================
Dados do Grid do Monitor
========================================================
*/
Static Function GridMonitor()
	Local oInteg  := LoadBitmap(GetResources(),'br_verde')
	Local oErro   := LoadBitmap(GetResources(),'br_vermelho')
	Local cQuery  := ""
	Local aReg    := {}

	cQuery  := " SELECT * FROM ("
	cQuery  += " SELECT * FROM "+RetSqlName("SZ1") "
	cQuery  += " WHERE 1=1 "
	cQuery  += "   AND D_E_L_E_T_ = ' ' "
	If !Empty(MV_PAR09)
		cQuery  += "   AND Z1_TPINTEG = '"+MV_PAR09+"' "
	Endif
	cQuery  += "   AND Z1_DTEXEC >= '"+dtos(MV_PAR01)+"' "
	cQuery  += "   AND Z1_DTEXEC <= '"+dtos(MV_PAR02)+"' "
	If MV_PAR03 == 3
		cQuery  += "   AND Z1_STATUS  != '"+alltrim(str(MV_PAR03))+ "'"
	Else
		cQuery  += "   AND Z1_STATUS   = '"+alltrim(str(MV_PAR03))+ "'"
	Endif
	If !Empty(MV_PAR04)
		cQuery  += "   AND Z1_INTEGRA = '"+alltrim(MV_PAR04)+ "'"
	Endif
	If !Empty(MV_PAR05) .AND. !Empty(MV_PAR06)
		cQuery  += "   AND Z1_FILIAL >= '"+alltrim(MV_PAR05)+"'"
		cQuery  += "   AND Z1_FILIAL <= '"+alltrim(MV_PAR06)+"'"
	Endif
	If MV_PAR07 != 0 .AND. MV_PAR08 != 0
		cQuery  += "   AND Z1_ID >= '"+STRZERO(MV_PAR07,TamSX3("Z1_ID")[1])+"'"
		cQuery  += "   AND Z1_ID <= '"+STRZERO(MV_PAR08,TamSX3("Z1_ID")[1])+"'"
	Endif
	If !Empty(MV_PAR11)
		cQuery  += "   AND Z1_DOCORI LIKE '%"+alltrim(MV_PAR11)+"%'"
	Endif
	If !Empty(MV_PAR12)
		cQuery  += "   AND Z1_HTTP LIKE '%"+alltrim(MV_PAR12)+"%'"
	Endif
	cQuery  += " ORDER BY R_E_C_N_O_ DESC) "
	cQuery  += " WHERE ROWNUM <= 1000 "

	If Select("QRY_DADOS") > 0
		QRY_DADOS->(dbCloseArea())
	EndIf
	cQuery  := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY_DADOS",.T.,.F.)
	dbSelectArea("QRY_DADOS")

	conout(cQuery)

	aBrowse := {}
	QRY_DADOS->(dbGoTop())
	While QRY_DADOS->(!Eof())
		aReg := {}
		AADD(aReg,QRY_DADOS->Z1_FILIAL)
		If (QRY_DADOS->Z1_STATUS) == "1"
			AADD(aReg,oInteg)
		Else
			AADD(aReg,oErro)
		End
		AADD(aReg,QRY_DADOS->Z1_ID)
		AADD(aReg,QRY_DADOS->Z1_INTEGRA)
		AADD(aReg,QRY_DADOS->Z1_NOMEITG)
		AADD(aReg,QRY_DADOS->Z1_TPINTEG)
		If !Empty(QRY_DADOS->Z1_TPINTEG)
			AADD(aReg,QRY_DADOS->Z1_NTPINTG)
		Else
			AADD(aReg,"**NAO CADASTRADO**")
		End
		AADD(aReg,QRY_DADOS->Z1_ERRO)
		AADD(aReg,stod(QRY_DADOS->Z1_DTEXEC))
		AADD(aReg,QRY_DADOS->Z1_HREXEC)
		AADD(aReg,QRY_DADOS->Z1_DOCORI)
		AADD(aReg,QRY_DADOS->Z1_TMPPRO)
		AADD(aReg,QRY_DADOS->Z1_USUARIO)
		AADD(aReg,Alltrim(Str(QRY_DADOS->Z1_DOCRECN)))
		AADD(aReg,QRY_DADOS->Z1_HTTP)
		AADD(aReg,QRY_DADOS->R_E_C_N_O_)
		AADD(aBrowse,aReg)
		QRY_DADOS->(dbSKIP())
	EndDo
	IF Len(aBrowse) == 0
		AADD(aBrowse,{'','','','','','','','','','','','','','',''})
	EndiF

RETURN

/*
========================================================
Ordena campos do Monitor
========================================================
*/

Static Function OrdenaCabMon(nCol,bMudaOrder)
	Local aOrdena := {}
	Local aTotal  := {}
	Local nTipoOrder

	aOrdena := AClone(aBrowse)
	IF nTipoOrder == 1
		IF bMudaOrder
			nTipoOrder := 2
		ENDIF
		aOrdena := aSort(aOrdena,,,{|x,y| x[nCol] < y[nCol]})
	Else
		IF bMudaOrder
			nTipoOrder := 1
		ENDIF
		aOrdena := aSort(aOrdena,,,{|x,y| x[nCol] > y[nCol]})
	ENDIF
	aBrowse    := aOrdena
	oBrowseDados:DrawSelect()
	oBrowseDados:Refresh()

Return

/*
========================================================
Função para gravar registros no monitor de integração
========================================================
*/

User Function CAOA_MONITOR(cFil,cStatus,cCodint,cCodtpint,cErro,cDocori,cTempo,cJSON,nRecnoDoc,cHTTP)
	Local aArea     := GetArea()
	Local nId       := 0
	Local cQuery    := ""
	Local cUser
	Local cEmail
	Local cNomeInt
	Local cTipoInt
	
	Default nRecnoDoc := 0                                                                   
	Default cHTTP     := ''

	Private cPara
	Private cHtml                
	
	default cJSON := ''
	
	If ValType(nRecnoDoc) != "N"
		nRecnoDoc := 0
	Endif	

	//Buscando nomes de integra
	DbSelectArea("SZ2")
	SZ2->(DbSetOrder(1)) // Z2_CODIGO
	If SZ2->(dbSeek(xFilial("SZ2")+cCodint))
		cNomeInt := SZ2->Z2_NOME   
	Else
		Return 0
	EndIf

	//Buscando tipo de integr e email da SZ3
	DbSelectArea("SZ3")
	SZ3->(DbSetOrder(1)) // Z3_CODINTG+Z3_CODTINT
	If SZ3->(dbSeek(xFilial("SZ3")+cCodint+cCodtpint))
		cTipoInt := SZ3->Z3_TPINTEG
		cEmail   := alltrim(lower(SZ3->Z3_EMAIL))
	Else
		Return  0
	EndIf          
	//IF Alltrim(cCodint)+Alltrim(cCodtpint) == AllTrim(GetMv("MGF_MONI01"))+AllTrim(GetMv("MGF_MONT10"))
	//    IF cStatus <> '2'
	//        Return  0
	//    EndIF
	//EndIF 


	//Buscando ultimo registro ID da tabela SZ1

	SZ1->(DbSetOrder(1)) //ID 

	While .t.
		cID := GetSxeNum("SZ1","Z1_ID")
		SZ1->(DbSeek(cID)) 
		IF SZ1->(Found())
			ConfirmSX8()
		Else
			Exit
		Endif
	End
	ConfirmSX8()
	
	dData   := Date() //dDatabase
	cUser   := RetCodUsr()//PswRet()[1][2] Troca para Codigo do Usuario, quando não tem login aparesenta erro
	
	//Abrindo a tabela de produtos e setando o para insert
	DbSelectArea("SZ1")
	SZ1->(DbSetOrder(1)) // Z1_ID


		RecLock("SZ1", .T.)
		SZ1->Z1_FILIAL   := cFil // (xFilial("SZ1"))
		SZ1->Z1_ID       := cID
		SZ1->Z1_STATUS   := cStatus
		SZ1->Z1_INTEGRA  := cCodint
		SZ1->Z1_NOMEITG  := cNomeInt
		SZ1->Z1_TPINTEG  := cCodtpint
		SZ1->Z1_NTPINTG  := cTipoInt
		SZ1->Z1_ERRO     := cErro
		SZ1->Z1_DTEXEC   := dData
		SZ1->Z1_HREXEC   := time()
		SZ1->Z1_DOCORI   := Alltrim(cDocori)
		SZ1->Z1_TMPPRO   := cTempo
		SZ1->Z1_USUARIO  := cUser                                                  
		SZ1->Z1_JSON     := cJSON
		SZ1->Z1_DOCRECN  := nRecnoDoc
		SZ1->Z1_HTTP     := cHTTP
		SZ1->(MsUnlock())

	RestArea(aArea)

	If cStatus == "2"  .AND. .F. // Erro
		cPara := cEmail

		cHtml := ""
		cHtml += "<HTML>"
		cHtml += "<HEAD>"
		cHtml += "	<META HTTP-EQUIV='CONTENT-TYPE' CONTENT='text/html; charset=utf-8'>"
		cHtml += "	<TITLE></TITLE>"
		cHtml += "	<META NAME='GENERATOR' CONTENT='LibreOffice 4.1.6.2 (Linux)'>"
		cHtml += "	<META NAME='CREATED' CONTENT='0;0'>"
		cHtml += "	<META NAME='CHANGED' CONTENT='0;0'>"
		cHtml += "	<STYLE TYPE='text/html'>"
		cHtml += "	<!--"
		cHtml += "		@page { margin: 0.79in }"
		cHtml += "		P { margin-bottom: 0.08in }"
		cHtml += "		PRE.ctl { font-family: 'arial black', 'avant garde'; font-size: medium; color: #ff0000 }"
		cHtml += "	-->"
		cHtml += "	</STYLE>"
		cHtml += "</HEAD>"
		cHtml += "<BODY LANG='pt-BR' DIR='LTR'>"
		cHtml += "<P><font face = 'verdana' size='5'><strong>ERRO DE INTEGRAÇÃO PROTHEUS</strong></font></p>" +CRLF
		cHtml += CRLF+"<P><font face = 'verdana' size='3'>INTEGRAÇÃO:</font></p>"
		cHtml += "<P><font face = 'verdana' size='3' color='blue'><strong>"+alltrim(cNomeInt)+" / "+alltrim(cTipoInt)+" / DOC.ORIGEM: "+alltrim(cDocori)+"</strong></font></p>"
		cHtml += "<P><font face = 'verdana' size='3'> ID:</font></p>"
		cHtml += "<P><font face = 'verdana' size='3' color='blue'><strong>"+alltrim(str(nIdm))+"</strong></font></p>" +CRLF
		cHtml += CRLF+"<P><font face = 'verdana' size='3' color='red'><strong>"+alltrim(cERRO)+"</strong></font></p>" +CRLF
		cHtml += CRLF+"<P><font face = 'verdana' size='3'>FAVOR CORRIGIR O ERRO E EM SEGUIDA ACESSAR O MONITOR DE INTEGRAÇÕES PARA REPROCESSAR O ID MENCIONADO ACIMA.</font></p>"
		cHtml += "</BODY>"
		cHtml += "</HTML>"

		//EnvMail()
	Endif
Return SZ1->( Recno() )

/*
========================================================
Função que Envia E-mail do erro (EnvMail())
========================================================
*/
Static Function EnvMail()

	Local oMail, oMessage
	Local nErro		:= 0
	Local lRetMail 	:= .T.
	Local cSmtpSrv  := GETMV("MGF_SMTPSV")
	Local cCtMail   := GETMV("MGF_CTMAIL")
	Local cPwdMail  := GETMV("MGF_PWMAIL")
	Local nMailPort := GETMV("MGF_PTMAIL")
	Local nParSmtpP := GETMV("MGF_PTSMTP")
	Local nSmtpPort
	Local nTimeOut  := GETMV("MGF_TMOUT")
	Local cEmail    := GETMV("MGF_EMAIL")
	Local cErrMail

	oMail := TMailManager():New()

	if nParSmtpP == 25
		oMail:SetUseSSL( .F. )
		oMail:SetUseTLS( .F. )
		oMail:Init("", cSmtpSrv, cCtMail, cPwdMail,, nParSmtpP)
	elseif nParSmtpP == 465
		nSmtpPort := nParSmtpP
		oMail:SetUseSSL( .T. )
		oMail:Init("", cSmtpSrv, cCtMail, cPwdMail,, nSmtpPort)
	else
		nParSmtpP == 587
		nSmtpPort := nParSmtpP
		oMail:SetUseTLS( .T. )
		oMail:Init("", cSmtpSrv, cCtMail, cPwdMail,, nSmtpPort)
	endif

	oMail:SetSmtpTimeOut( nTimeOut )
	nErro := oMail:SmtpConnect()

	If nErro != 0
		cErrMail :=("ERROR:" + oMail:GetErrorString(nErro))
		conout(cErrMail)
		Alert(cErrMail)
		oMail:SMTPDisconnect()
		lRetMail := .F.
		Return (lRetMail)
	Endif

	If 	nParSmtpP != 25
		nErro := oMail:SmtpAuth(cCtMail, cPwdMail)
		If nErro != 0
			cErrMail :=("ERROR:" + oMail:GetErrorString(nErro))
			conout(cErrMail)
			oMail:SMTPDisconnect()
			lRetMail := .F.
			Return (lRetMail)
		Endif
	Endif

	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom                  := cEmail
	oMessage:cTo                    := cPara
	oMessage:cCc                    := ""
	oMessage:cSubject               := "Aviso de Erro de Integra Protheus"
	oMessage:cBody                  := cHtml
	nErro := oMessage:Send( oMail )

	if nErro != 0
		cErrMail :=("ERROR:" + oMail:GetErrorString(nErro))
		conout(cErrMail)
		Alert(cErrMail)
		oMail:SMTPDisconnect()
		lRetMail := .F.
		Return (lRetMail)
	Endif

	conout('Desconectando do SMTP')
	oMail:SMTPDisconnect()

Return
/*
========================================================
Exporta JSON
========================================================
*/

Static Function EXPXML
Private cJSON := ''
Private oDlg1
Private oMGet1
Private nRecno := aBrowse[oBrowseDados:nAt][16]    
        
dbSelectArea('SZ1')
SZ1->(dbGoTo(nRecno))
cJSON  := SZ1->Z1_JSON
oDlg1  := MSDialog():New( 075,297,575,759,"Json enviado",,,.F.,,,,,,.T.,,,.T. )
oMGet1 := TMultiGet():New( 004,004,{|u| If(PCount()>0,cJSON:=u,cJSON)},oDlg1,216,232,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
oDlg1:Activate(,,,.T.)

Return


// limpa flag usado para controlar o numero de tentativas de envio da integracao para o barramento
Static Function LimpaFlag()

Local cTab   := ""
Local aArea  := {GetArea()}
Local cCampo := ""           
Local bPed   := .F.

If aBrowse[oBrowseDados:nAt][04] == Alltrim(GetMv("MGF_MONI01")) // taura
	If aBrowse[oBrowseDados:nAt][06] == Alltrim(GetMv("MGF_MONT01"))
		cTab := "SA2"
		cCampo := "A2_ZTAUVEZ"
	Elseif aBrowse[oBrowseDados:nAt][06] == Alltrim(GetMv("MGF_MONT02"))
		cTab := "SA4"
		cCampo := "A4_ZTAUVEZ"
	Elseif aBrowse[oBrowseDados:nAt][06] == Alltrim(GetMv("MGF_MONT03"))
		cTab := "SB1"
		cCampo := "B1_ZTAUVEZ"
	Elseif aBrowse[oBrowseDados:nAt][06] == Alltrim(GetMv("MGF_MONT04"))
		cTab := "DA4"
		cCampo := "DA4_ZTAUVE" 
	Elseif aBrowse[oBrowseDados:nAt][06] == Alltrim(GetMv("MGF_MONT05"))
		cTab := "DA3"
		cCampo := "DA3_ZTAUVE"
	Elseif aBrowse[oBrowseDados:nAt][06] == Alltrim(GetMv("MGF_MONT06"))
		cTab := "SA1"
		cCampo := "A1_ZTAUVEZ"
	Elseif aBrowse[oBrowseDados:nAt][06] == Alltrim(GetMv("MGF_MONT08"))
		cTab := "SC5"
		cCampo := "C5_ZTAUREE"
		bPed   := .T.
	Endif
Endif

If Empty(cTab)
	APMsgStop("Tipo de integração não tem tratamento para número de tentativas de envio. Escolha outro tipo de integração.")
	Return()
Endif	
	
If Empty(Val(aBrowse[oBrowseDados:nAt][14]))
	APMsgStop("Recno da tabela de origem não gravado na tabela de integrações.")
	Return()
Endif	
			
If !Empty(cTab) .and. APMsgYesNo("Será limpo o flag de tentativas de envio da Tabela: "+cTab+", Documento: "+aBrowse[oBrowseDados:nAt][11]+", Recno: "+aBrowse[oBrowseDados:nAt][14]+CRLF+;
	"Deseja prosseguir ?")
	(cTab)->(dbGoto(Val(aBrowse[oBrowseDados:nAt][14])))
	If (cTab)->(Recno()) == Val(aBrowse[oBrowseDados:nAt][14])
		(cTab)->(RecLock(cTab,.F.))
		(cTab)->&(cCampo) := IIF(bPed,'N',0)
		(cTab)->(MsUnLock())
	Endif
Endif		
	
aEval(aArea,{|x| RestArea(x)})

Return()	  