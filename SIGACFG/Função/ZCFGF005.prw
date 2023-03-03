#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
=====================================================================================
Programa.:              ZCFGF005
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              27/12/2021
Descricao / Objetivo:   Testa Conexão com os WebService Caoa.
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
User Function ZCFGF005()

Private cWs001  := ""
Private cWs003  := ""
Private cWs005  := ""
Private cWs007  := ""

    FwMsgRun(, { || TstWs001() }		, "Conexão Autoware Produção - Status Pedidos ", "Aguarde...." )
    
    FwMsgRun(, { || TstWs003() }		, "Conexão Autoware Produção - Nota Fiscal", "Aguarde...." )

    FwMsgRun(, { || TstWs005() }		, "Conexão Sap Produção - Fornecedores", "Aguarde...." )
    
    FwMsgRun(, { || TstWs007() }		, "Conexão Sap Produção - Clientes", "Aguarde...." )

    FWMsgRun(, {|| zBrwConexao() }, "[ ZCFGF005 ] - Conectando...", "Visualização Conexões...")    
    
Return()

/*
=====================================================================================
Programa.:              TstWs001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              27/12/2021
Descricao / Objetivo:   Testa Conexão com os WebService SAP - Produção / Internet.
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function TstWs001()

Local cWsURL  := ""      
Private oWsdl

cWsURL := ALLTRIM(SuperGetMV("CAOA_WS003",.T.,'http://extranet.caoamontadora.com.br/servicos/v2/PedidoVeiculo.asmx?WSDL')) 
//cWsURL := "http://extranet.caoamontadora.com.br/servicos/v2/PedidoVeiculo.asmx?WSDL"

oWsdl := TWsdlManager():New()
oWsdl:bNoCheckPeerCert := .T.
oWsdl:lSSLInsecure := .T.

	If !oWsdl:ParseURL( cWsURL )
		cWs001 := "ERRO"
    Else
        cWs001 := "SUCESSO"
	EndIF

freeObj(oWsdl)
oWsdl := nil
	    
Return()

/*
=====================================================================================
Programa.:              TstWs003
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              27/12/2021
Descricao / Objetivo:   Testa Conexão com os WebService SAP - Produção / Internet.
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function TstWs003()

Local cWsURL  := ""      
Private oWsdl

cWsURL := ALLTRIM(SuperGetMV("CAOA_WS004",.T.,'http://extranet.caoamontadora.com.br/servicos/v2/NotaFiscal.asmx?wsdl'))

oWsdl := TWsdlManager():New()
oWsdl:bNoCheckPeerCert := .T.
oWsdl:lSSLInsecure := .T.

	If !oWsdl:ParseURL( cWsURL )
		cWs003 := "ERRO"
    Else
        cWs003 := "SUCESSO"
	EndIF

freeObj(oWsdl)
oWsdl := nil
	    
Return()

/*
=====================================================================================
Programa.:              TstWs005
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              27/12/2021
Descricao / Objetivo:   Testa Conexão com os WebService SAP - Produção / MPLS.
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function TstWs005()

Local cUser         := ""
Local cPass         := ""
Local cWsURL        := ""    
Local cAutorizat    := "" 
Local xPostRet		:= Nil
Local nStatuHttp	:= 0
Local nTimeOut		:= 120
Local cHeadRet		:= ""
Local aHeadOut		:= {}
Local cError        := ""
Private oWsdl

cUser := AllTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
cPass := AllTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP

cWsURL := "http://10.120.40.141:53400/dir/wsdl?p=ic/9f324344323d391792946bbd98bd4139"

cAutorizat := encode64( allTrim( cUser ) + ":" + allTrim( cPass ) )

aadd( aHeadOut	, 'Content-Type: text/xml; charset=UTF-8'								)
aadd( aHeadOut	, 'SOAPAction: http://sap.com/xi/WebService/soap1.1'					)
aadd( aHeadOut	, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')'	)
aadd( aHeadOut	, 'Authorization: Basic ' + cAutorizat									)

xPostRet	:= httpQuote( cWsURL /*<cUrl>*/, "GET" /*<cMethod>*/, /*[cGETParms]*/, /*[cPOSTParms]*/, nTimeOut /*[nTimeOut]*/, aHeadOut /*[aHeadStr]*/, @cHeadRet /*[@cHeaderRet]*/ )

nStatuHttp	:= HTTPGetStatus( @cError, .F. )

    If nStatuHttp >= 200 .and. nStatuHttp <= 299
	    cWs005 := "SUCESSO"
    Else
        cWs005 := "ERRO"
	EndIF

Return()

/*
=====================================================================================
Programa.:              TstWs005
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              27/12/2021
Descricao / Objetivo:   Testa Conexão com os WebService SAP - Produção / MPLS.
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function TstWs007()

Local cUser         := ""
Local cPass         := ""
Local cWsURL        := ""    
Local cAutorizat    := "" 
Local xPostRet		:= Nil
Local nStatuHttp	:= 0
Local nTimeOut		:= 120
Local cHeadRet		:= ""
Local aHeadOut		:= {}
Local cError        := ""
Private oWsdl

cUser := AllTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
cPass := AllTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP

cWsURL := allTrim( superGetMv( "CAOASAP02A"	, , "http://10.120.40.141:53400/dir/wsdl?p=ic/97d120e0442d33278268b0eccac3643c") )

cAutorizat := encode64( allTrim( cUser ) + ":" + allTrim( cPass ) )

aadd( aHeadOut	, 'Content-Type: text/xml; charset=UTF-8'								)
aadd( aHeadOut	, 'SOAPAction: http://sap.com/xi/WebService/soap1.1'					)
aadd( aHeadOut	, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')'	)
aadd( aHeadOut	, 'Authorization: Basic ' + cAutorizat									)

xPostRet	:= httpQuote( cWsURL /*<cUrl>*/, "GET" /*<cMethod>*/, /*[cGETParms]*/, /*[cPOSTParms]*/, nTimeOut /*[nTimeOut]*/, aHeadOut /*[aHeadStr]*/, @cHeadRet /*[@cHeaderRet]*/ )

nStatuHttp	:= HTTPGetStatus( @cError, .F. )

    If nStatuHttp >= 200 .and. nStatuHttp <= 299
	    cWs007 := "SUCESSO"
    Else
        cWs007 := "ERRO"
	EndIF

Return()

/*
=====================================================================================
Programa.:              zBrwConexao
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              27/12/2021
Descricao / Objetivo:   Tela com os teste de conexão
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function zBrwConexao()

Local oDlg	    := Nil
Local clTitulo	:= "Painel de Conexões WEBSERVICE - CAOA"

Define FONT oFontDef  NAME "Arial"	Size 06,14 Bold

DEFINE MSDIALOG oDlg TITLE clTitulo FROM  15,6 TO 300,550 COLORS 0,16777215 PIXEL //OF oMainWnd 
		
    
    @ 008, 004 TO 120, 133 OF oDlg  PIXEL // Processamento Nota Fiscal
    @ 008, 138 TO 120, 271 OF oDlg  PIXEL // Envio de Workflow
   
    @ 011,038 SAY OemToAnsi("AMBIENTE PRODUÇÃO")	SIZE 150, 07 OF oDlg PIXEL COLOR CLR_BLUE FONT oFontDef
    @ 013,008 SAY OemToAnsi("________________________________________")	SIZE 150, 07 OF oDlg PIXEL
    
    @ 032,008 SAY OemToAnsi("AUTOWARE - STATUS PEDIDOS")    SIZE 150, 07 OF oDlg PIXEL FONT oFontDef
    @ 032,090 SAY cWs001	                                SIZE 150, 07 OF oDlg PIXEL COLOR IIF(cWs001 == "SUCESSO", CLR_GREEN, CLR_RED) FONT oFontDef  
    
    @ 042,008 SAY OemToAnsi("AUTOWARE - NOTA FISCAL")       SIZE 150, 07 OF oDlg PIXEL FONT oFontDef
    @ 042,090 SAY cWs003	                                SIZE 150, 07 OF oDlg PIXEL COLOR IIF(cWs003 == "SUCESSO", CLR_GREEN, CLR_RED) FONT oFontDef  

    @ 052,008 SAY OemToAnsi("SAP - FORNECEDORES")           SIZE 150, 07 OF oDlg PIXEL FONT oFontDef
    @ 052,090 SAY cWs005	                                SIZE 150, 07 OF oDlg PIXEL COLOR IIF(cWs005 == "SUCESSO", CLR_GREEN, CLR_RED) FONT oFontDef  

    @ 062,008 SAY OemToAnsi("SAP - CLIENTES")               SIZE 150, 07 OF oDlg PIXEL FONT oFontDef
    @ 062,090 SAY cWs007	                                SIZE 150, 07 OF oDlg PIXEL COLOR IIF(cWs007 == "SUCESSO", CLR_GREEN, CLR_RED) FONT oFontDef  

    @ 011,175 SAY OemToAnsi("AMBIENTE HOMOLOGAÇÃO")	SIZE 150, 07 OF oDlg PIXEL COLOR CLR_RED FONT oFontDef
    @ 013,143 SAY OemToAnsi("_________________________________________")	SIZE 150, 07 OF oDlg PIXEL
    
    //@ 032,143 SAY OemToAnsi("AUTOWARE: ")           SIZE 150, 07 OF oDlg PIXEL FONT oFontDef
    //@ 032,176 SAY cWs002	                        SIZE 150, 07 OF oDlg PIXEL COLOR IIF(cWs002 == "SUCESSO", CLR_GREEN, CLR_RED) FONT oFontDef  
    
    //@ 042,143 SAY OemToAnsi("SAP: ")     SIZE 150, 07 OF oDlg PIXEL FONT oFontDef
    //@ 042,175 SAY cHrWF	                        SIZE 150, 07 OF oDlg PIXEL 

    DEFINE SBUTTON FROM 125,121 TYPE 2 ENABLE OF oDlg ACTION {|| oDlg:End() }
	//DEFINE SBUTTON FROM 87,182 TYPE 2 ENABLE OF oDlg ACTION {|| oDlg:End() }
			
ACTIVATE MSDIALOG oDlg CENTERED 

Return()
