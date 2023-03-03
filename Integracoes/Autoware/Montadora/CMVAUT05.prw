#include "totvs.ch"                                   
#include "protheus.ch"
#include "topconn.ch"

//Constantes
#define CRLF chr(13) + chr(10)                               

/*
============================================================================================
Programa.:              CMVAUT05
Autor....:              Marcelo Carneiro         
Data.....:              26/02/2019
Descricao / Objetivo:   Integração Autoware
Doc. Origem:            Envio das informações modelos validos para vendas
Solicitante:            Cliente
Obs......:              
===============================================================================================
*/

User Function CMVAUT05

Private cCadastro := "Modelos para Vendas"
Private aRotina   := { {"Pesquisar" 		,"AxPesqui"			,0	,1				} 	,;       
		               {"Visualizar"		,"AxVisual"			,0	,2	,0	,NIL	}	,;
		               {"Incluir"   		,"U_AUTO05_INC"		,0	,3				} 	,;
					   {"Alterar"   		,"AxAltera"			,0	,4	,0	,NIL	} }
		               //{"Transmitir Rede"	,"U_AUT05_ENVIA(1)"	,0	,6				}	,;
//{"Transmitir CAOA"	,"U_AUT05_ENVIA(2)"	,0	,6				}}
					   //{"Excluir"   		,"AxDeleta", 0,5} ,;
		               

Private cDelFunc  := ".T."            

ChkFile("SZC")
dbSelectArea("SZC")
dbSetOrder(1)

mBrowse( 6,1,22,75,"SZC")

Return
*************************************************************************************************************************
/*User Function OF560VX5
Local cFiltro := PARAMIXB[2]
Do Case
	Case cFiltro == "M->ZC_COREXT"
		cFiltroVX5 := "067"
	Case cFiltro == "M->ZC_CORINT"
		cFiltroVX5 := "066"
	Case cFiltro == "M->ZC_OPCION"
		cFiltroVX5 := "068"
EndCase

Return cFiltroVX5
*/
*************************************************************************************************************************
User Function AUT05_ENVIA(nTipo)

Local cRet    := ''
Local cErro   := ''
Local cWsURL  := ''
Local cSoap   := ''
Local lRet    := .F.
Local cRetMsg := ''
Local cChave  := ''
Local bTemReg := .F.

Private oWsdl

cWsURL:= ALLTRIM(SuperGetMV("CAOA_WS003",.T.,'https://treinamento.caoamontadora.com.br/servicos/v2/PedidoVeiculo.asmx?WSDL'))
                                              
SZC->(dbGoTop())
IF SZC->(!EOF())
	oWsdl := TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.
	If !oWsdl:ParseURL( cWsURL )
		cRet  := '2'
		cErro := 'Não foi possivel Acessar o WSDL '+oWsdl:cError
		U_CAOA_MONITOR( cFilant,cRet,'001','005',cErro,'','0',cSoap ,0)
		freeObj(oWsdl)
		oWsdl := nil
		SZC->(dbCloseArea())
		Return
	EndIF
	If !oWsdl:SetOperation('DadosModelos')
		cRet  := '2'
		cErro := 'Não foi possivel setar a Operação DadosModelos '+oWsdl:cError
		U_CAOA_MONITOR( cFilant  ,cRet,'001','005',cErro,'','0',cSoap ,0)
		freeObj(oWsdl)
		oWsdl := nil
		SZC->(dbCloseArea())
		Return
	EndIF
	aCBox := RetSX3Box(Posicione("SX3",2,"VV1_COMVEI","X3CBox()"),,,1)
	cSoap := '<x:Envelope xmlns:x="http://www.w3.org/2003/05/soap-envelope"  xmlns="http://tempuri.org/">'
	cSoap += "<x:Header/>                                                                                 "
	cSoap += "<x:Body>                                                                                    "
	cSoap += "    <DadosModelos>                                                                                "
	cSoap += "        <ListaModelos>                                                              "
	While SZC->(!EOF())
		IF ( (nTipo == 1 .AND. SZC->ZC_DISPON $ ('AR')) .OR.	(nTipo == 2 .AND. SZC->ZC_DISPON $ ('AC')) )
			cSoap += "            <DadosModelos>                                                      "
			cSoap += putTag('CdMarca',          Alltrim(SZC->ZC_CODMAR))
			cSoap += putTag('DsMarca',          AllTrim(GetAdvFVal("VE1","VE1_DESMAR",xFilial('VE1')+SZC->ZC_CODMAR,1,'')))
			cSoap += putTag('CdLinha',          Alltrim(SZC->ZC_GRUMOD ))
			cSoap += putTag('DsLinha',          AllTrim(GetAdvFVal("VVR","VVR_DESCRI",xFilial('VVR')+SZC->ZC_CODMAR+SZC->ZC_GRUMOD,2,'')))
			cSoap += putTag('CdModeloComercial',Alltrim(SZC->ZC_SEGMOD) 			)
			cSoap += putTag('DsModeloComercial',AllTrim(GetAdvFVal("VVX","VVX_DESSEG",xFilial('VVX')+SZC->ZC_CODMAR+SZC->ZC_SEGMOD,1,'')))
			cSoap += putTag('CdModelo',         Alltrim(SZC->ZC_MODVEI)  )
			cSoap += putTag('DsModelo',         Alltrim(GetAdvFVal("VV2","VV2_DESMOD",xFilial('VV2')+SZC->ZC_CODMAR+SZC->ZC_MODVEI,1,'')))
			cSoap += putTag('AnoModelo',        SZC->ZC_MODANO )
			cSoap += putTag('AnoFabricacao',    SZC->ZC_FABANO )
			cSoap += putTag('CdCorExterna',     Alltrim(SZC->ZC_COREXT))
			cSoap += putTag('DsCorExterna',     AllTrim(GetAdvFVal("VX5","VX5_DESCRI",xFilial('VX5')+'067'+SZC->ZC_COREXT,1,'')))
			cSoap += putTag('CdCorInterna',     Alltrim(SZC->ZC_CORINT))
			cSoap += putTag('DsCorInterna',     AllTrim(GetAdvFVal("VX5","VX5_DESCRI",xFilial('VX5')+'066'+SZC->ZC_CORINT,1,'')))
			cSoap += "                </DadosModelos>                                                  "
			bTemReg := .T.
		EndIF
		SZC->(dbSkip())
	EndDo
	IF bTemReg 
		cSoap += "                </ListaModelos>                                                      "
		cSoap += "        </DadosModelos>                                                               "
		cSoap += "    </x:Body>                                                            "
		cSoap += "</x:Envelope>                                                            "
		lRet := oWsdl:SendSoapMsg(cSoap)
		IF !lRet
			cRet  := '2'
			cErro := 'Não foi enviar o XML '+oWsdl:cError
		Else
			cRetMsg := oWsdl:GetSoapResponse()
			cRetMsg := GetSimples( cRetMsg , "<RetornoModelosDados>", "</RetornoModelosDados" )
			cCdRet  := GetSimples( cRetMsg , "<CdRetorno>", "</CdRetorno>" )
			cDsRet  := GetSimples( cRetMsg , "<DsRetorno>", "</DsRetorno>" )
			IF Empty(cRetMsg)
				cRet  := '2'
				cErro := 'Não encontrado mensagem de retorno'
			ElseIf Alltrim(cCdRet) == "1" .OR. Alltrim(cCdRet) == "0"
				cRet  := '1'
				cErro := 'Integrado com sucesso'
			Else
				cRet  := '2'
				cErro := Alltrim(cCdRet)+'-'+Alltrim(cDsRet)
			EndIF
		Endif
		cChave := Alltrim(SZC->ZC_GRUMOD)+Alltrim(SZC->ZC_GRUMOD)+Alltrim(SZC->ZC_GRUMOD)+Alltrim(SZC->ZC_GRUMOD)
		U_CAOA_MONITOR( cFilant  ,cRet,'001','005',cErro, cChave ,'0',cSoap ,SZC->(Recno()))
	EndIF
EndIF
 
MsgAlert('Integração Finalizada !') 
freeObj(oWsdl)               
oWsdl := nil

Return
*********************************************************************************************************
Static Function putTag(cTag,cValor) 
Local cRet := ''

cRet := '<'+cTag+'>'+cValor+'</'+cTag+'>'

Return cRet

**********************************************************************************************************************
User Function AUTO05_INC
Local aSizeAut    := MsAdvSize(,.F.,400)
Local  nI      := 0 

Private nTipoOrder := 1
//Private oOK        := LoadBitmap(GetResources(),'LBOK')
//Private oNO        := LoadBitmap(GetResources(),'LBNO')
Private cbLine     := ''
Private oDlg    
Private oGroup1
Private oBold
Private aObjects
Private aInfo
Private aPosObj
Private aBrowse      := {}
Private aOperacao    := {}
Private aHeader      := {'Marca','Linha','Modelo','Segmento','Descrição'}
Private aTam         := {40     ,70     ,70      ,70        ,150} 
Private aCabDados    := AClone(aHeader)
Private oBrowseDados
Private aGeral       := {}
Private oCmb1    
Private oCmb2    
Private oCmb3    
Private oCmb4    
Private oCmb5                       
Private nComboBo1 := ''
Private nComboBo2 := ''
Private nComboBo3 := ''
Private nComboBo4 := ''
Private aCmb01    := {}
Private aCmb02    := {}
Private aCmb03    := {}
Private aCmb04    := {}


dbSelectArea('ZZE')
Monta_Cab(1)
IF Len(aBrowse) == 0 
     MsgAlert('Não há dados para o filtro selecionado !')
     Return
ENDIF                                                         


DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD

aObjects := {}
AAdd( aObjects, { 0,    65, .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 0,    75, .T., .F. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )


DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE "Modelo Disponiveis para Venda"  OF oMainWnd PIXEL
                                            
	oBrowseDados := TWBrowse():New( 60,aPosObj[2,2],aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3],,,,oDlg, , , ,,{||}, , , , ,,,.F.,,.T.,,.F.,,, )
	oBrowseDados:addColumn(TCColumn():new(aHeader[01],{||aBrowse[oBrowseDados:nAt][01]},"@!"             ,,,"LEFT"  ,aTam[01],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[02],{||aBrowse[oBrowseDados:nAt][02]},"@!"             ,,,"LEFT"  ,aTam[02],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[03],{||aBrowse[oBrowseDados:nAt][03]},"@!"             ,,,"LEFT"  ,aTam[03],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[04],{||aBrowse[oBrowseDados:nAt][04]},"@!"             ,,,"LEFT"  ,aTam[04],.F.,.F.,,,,,))
	oBrowseDados:addColumn(TCColumn():new(aHeader[05],{||aBrowse[oBrowseDados:nAt][05]},"@!"             ,,,"LEFT"  ,aTam[05],.F.,.F.,,,,,))
//	oBrowseDados:addColumn(TCColumn():new(aHeader[06],{||aBrowse[oBrowseDados:nAt][06]},"@!"             ,,,"LEFT"  ,aTam[06],.F.,.F.,,,,,))
	oBrowseDados:SetArray(aBrowse)                           
	oBrowseDados:bLDblClick  := {|| SZC_Inclui() }//{|| aBrowse[oBrowseDados:nAt][1] := IIF(aBrowse[oBrowseDados:nAt][1]==oOK,oNO,oOK),oBrowseDados:DrawSelect()}
    oBrowseDados:bHeaderClick:= {|oBrw,nCol| OrdenaCab(nCol)}
	cbLine := "{||{ aBrowse[oBrowseDados:nAt,01] "                      
	For nI := 2 To Len(aHeader)
	 cbLine += ",aBrowse[oBrowseDados:nAt,"+STRZERO(nI,2)+"]"
	Next nI         
	cbLine +="  } }"
	oBrowseDados:bLine      := &cbLine          

     	                     

    @ 005, 008 GROUP oGroup1 TO 057, 300 PROMPT "Filtro" OF oDlg COLOR 0, 16777215 PIXEL
    
    @ 015, 052 SAY "Marca" SIZE 025, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
	@ 012, 086 MSCOMBOBOX oCmb1 VAR nComboBo1 ITEMS aCmb01 SIZE 072, 010 OF oGroup1 COLORS 0, 16777215 PIXEL
    
	@ 030, 052 SAY  "Linha" SIZE 025, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 027, 086 MSCOMBOBOX oCmb2 VAR nComboBo2 ITEMS aCmb02 SIZE 072, 010 OF oGroup1 COLORS 0, 16777215 PIXEL
    
    @ 015, 170 SAY "Modelo" SIZE 025, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 012, 203 MSCOMBOBOX oCmb3 VAR nComboBo3 ITEMS aCmb03 SIZE 072, 010 OF oGroup1 COLORS 0, 16777215 PIXEL

	@ 030, 170 SAY "Segmento" SIZE 025, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
	@ 027, 203 MSCOMBOBOX oCmb4 VAR nComboBo4 ITEMS aCmb04 SIZE 072, 010 OF oGroup1 COLORS 0, 16777215 PIXEL


	oBtn := TButton():New( 042, 240,'Filtro', oGroup1,{|| Monta_Cab(2) }     ,50, 011,,,.F.,.T.,.F.,,.F.,,,.F. )                                                                                            

	oBrowseDados:Setfocus() 
	oBtn := TButton():New( 005, aPosObj[3,4]-050,'Sair'            , oDlg,{|| oDlg:End()}     ,50, 011,,,.F.,.T.,.F.,,.F.,,,.F. )                                                                                            
	oBtn := TButton():New( aPosObj[2,3]+65, aPosObj[3,4]-050,'Incluir'           , oDlg,{|| SZC_Inclui()      }     ,50, 011,,,.F.,.T.,.F.,,.F.,,,.F. )                                                                                            
	
ACTIVATE MSDIALOG oDlg 

Return
*********************************************************************************************************************************
Static Function Monta_Cab(nTipo)
Local cQuery      := ""
Local aRec        := {}
Local nI 		:= 0

aCmb01	:= {}
aCmb02	:= {}
aCmb03	:= {}
aCmb04	:= {} 
aBrowse	:= {}

cQuery  := " SELECT VV2_CODMAR, VV2_GRUMOD, VV2_MODVEI, VV2_SEGMOD, VV2_DESMOD, VV2_COREXT, VV2_CORINT, VV2_OPCION "
cQuery  += " FROM "+RetSqlName('VV2')
cQuery  += " WHERE D_E_L_E_T_  = ' ' "
cQuery  += " 	AND VV2_CODMAR  <> '   ' "
If nTipo == 2
	IF Alltrim(nComboBo1) <> 'Todos'
		cQuery  += " 	AND VV2_CODMAR = '"+ nComboBo1 +"' "
	EndIF
	IF Alltrim(nComboBo2) <> 'Todos'
		cQuery  += " 	AND VV2_GRUMOD = '"+ nComboBo2 +"' "
	EndIF
	IF Alltrim(nComboBo3) <> 'Todos'
		cQuery  += " 	AND VV2_MODVEI = '"+ nComboBo3 +"' "
	EndIF
	IF Alltrim(nComboBo4) <> 'Todos'
		cQuery  += " 	AND VV2_SEGMOD = '"+ nComboBo4 +"' "
	EndIF
EndIf
cQuery  += " ORDER BY VV2_CODMAR, VV2_GRUMOD, VV2_MODVEI, VV2_SEGMOD, VV2_DESMOD "

If Select("QRY_DADOS") > 0
	QRY_DADOS->(dbCloseArea())
EndIf

cQuery  := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY_DADOS",.T.,.F.)

dbSelectArea("QRY_DADOS")
QRY_DADOS->(dbGoTop())

While !QRY_DADOS->(EOF())
    //IF Ativa_Filtro(nTipo)
	    aRec        := {}
	    AAdd(aRec,QRY_DADOS->VV2_CODMAR)
	    AAdd(aRec,QRY_DADOS->VV2_GRUMOD)
	    AAdd(aRec,QRY_DADOS->VV2_MODVEI)
	    AAdd(aRec,QRY_DADOS->VV2_SEGMOD)
	    AAdd(aRec,QRY_DADOS->VV2_DESMOD)
	    AAdd(aRec,QRY_DADOS->VV2_COREXT)
	    AAdd(aRec,QRY_DADOS->VV2_CORINT)
	    AAdd(aRec,QRY_DADOS->VV2_OPCION)
	    
	    AAdd(aBrowse, aRec)
		//IF nTipo == 1
			IF aScan( aCmb01, { |x| x == QRY_DADOS->VV2_CODMAR }) == 0 
		         AADD(aCmb01, QRY_DADOS->VV2_CODMAR)      
			EndIF
			IF aScan( aCmb02, { |x| x == QRY_DADOS->VV2_GRUMOD }) == 0 
		         AADD(aCmb02, QRY_DADOS->VV2_GRUMOD)      
			EndIF
			IF aScan( aCmb03, { |x| x == QRY_DADOS->VV2_MODVEI }) == 0 
		         AADD(aCmb03, QRY_DADOS->VV2_MODVEI)      
			EndIF
			IF aScan( aCmb04, { |x| x == QRY_DADOS->VV2_SEGMOD }) == 0 
		         AADD(aCmb04, QRY_DADOS->VV2_SEGMOD)      
			EndIF
		//EndIF
	//EndIF
	QRY_DADOS->(dbSkip())
End      
IF Len(aBrowse) == 0 
     aBrowse :={{'','','','','','',''}}
EndIF
IF nTipo == 1

	aCmb01:= Ordena(aCmb01)
	aCmb02:= Ordena(aCmb02)
	aCmb03:= Ordena(aCmb03)
	aCmb04:= Ordena(aCmb04)
	
ElseIF nTipo == 2

	aCmb01:= Ordena(aCmb01)
	aCmb02:= Ordena(aCmb02)
	aCmb03:= Ordena(aCmb03)
	aCmb04:= Ordena(aCmb04)
	
	oCmb1:SetItems(aCmb01)
	oCmb2:SetItems(aCmb02)
	oCmb3:SetItems(aCmb03)
	oCmb4:SetItems(aCmb04)

	
	If nComboBo1 <> 'Todos'
		oCmb1:Set( nComboBo1 )
		oCmb1:Refresh()
	//	aAdd(aCmb01,'Todos')
	//Else
	//	aCmb01:= Ordena(aCmb01)
	EndIf
	If nComboBo2 <> 'Todos'
		oCmb2:Set( nComboBo2 )
		oCmb2:Refresh()
	//	aAdd(aCmb02,'Todos')
	//Else
	//	aCmb02:= Ordena(aCmb02)
	EndIf
	If nComboBo3 <> 'Todos'
		oCmb3:Set( nComboBo3 )
		oCmb3:Refresh()
	//	aAdd(aCmb03,'Todos')
	//Else
	//	aCmb03:= Ordena(aCmb03)
	EndIf
	If nComboBo4 <> 'Todos'
		oCmb4:Set( nComboBo4 )
		oCmb4:Refresh()
	//	aAdd(aCmb04,'Todos')
	//Else
	//	aCmb04:= Ordena(aCmb04)
	EndIf

	cbLine := "{||{ aBrowse[oBrowseDados:nAt,01] "                      
	For nI := 2 To Len(aHeader)
	 cbLine += ",aBrowse[oBrowseDados:nAt,"+STRZERO(nI,2)+"]"
	Next nI         
	cbLine +="  } }"
	oBrowseDados:SetArray(aBrowse)
    oBrowseDados:DrawSelect()
    oBrowseDados:Refresh()          

EndIF

Return
********************************************************************************************************
Static Function OrdenaCab(nCol)
Local aOrdena := {}       
				   
aOrdena := AClone(aBrowse)                                         
IF nTipoOrder == 1                              
   nTipoOrder := 2
   aOrdena := aSort(aOrdena,,,{|x,y| x[nCol] < y[nCol]})                    
Else              
   nTipoOrder := 1
   aOrdena := aSort(aOrdena,,,{|x,y| x[nCol] > y[nCol]})                    
ENDIF     
aBrowse    := aOrdena
oBrowseDados:DrawSelect()
oBrowseDados:Refresh()          

Return
*******************************************************************************************************************************************************
Static Function Ordena(aAux)
Local nI   := 0
Local aRet := {'Todos'}

aSort(aAux,,,{|x,y| x < y })                                 
For nI := 1 To Len(aAux)
   AAdd(aRet,aAux[nI])
Next

Return aRet 

***********************************************************************************************************************
Static Function Ativa_Filtro(nTipo)
Local bRet  := .T.            

IF nTipo == 2         
	IF Alltrim(nComboBo1) <> 'Todos'
	    IF QRY_DADOS->VV2_CODMAR <> nComboBo1
	        bRet :=.F.
	    EndIF
	EndIF
	IF bRet .AND. Alltrim(nComboBo2) <> 'Todos'
	    IF  QRY_DADOS->VV2_GRUMOD <> nComboBo2
	        bRet :=.F.
	    EndIF
	EndIF
	IF bRet .AND. Alltrim(nComboBo3) <> 'Todos'
	    IF  QRY_DADOS->VV2_MODVEI <> nComboBo3
	        bRet :=.F.
	    EndIF
	EndIF
	IF bRet .AND. Alltrim(nComboBo4) <> 'Todos'
	    IF  QRY_DADOS->VV2_SEGMOD <> nComboBo4
	        bRet :=.F.
	    EndIF
	EndIF
EndIF
            
Return bRet 
************************************************************************************************************************************************
Static Function SZC_Inclui
Local aParambox	  := {}                 
Local aDisp       := {'Ambos','Rede Independente','CAOA'}       
Local aRet			:= {}

Local cCorExt		:= aBrowse[oBrowseDados:nAt][06]+"-"+Subs(GetAdvFVal('VX5','VX5_DESCRI',xFilial("VX5")+'067'+aBrowse[oBrowseDados:nAt][06],1,Space(Len(VX5->VX5_DESCRI))),1,26)                                                                       
Local cCorInt		:= aBrowse[oBrowseDados:nAt][07]+"-"+Subs(GetAdvFVal('VX5','VX5_DESCRI',xFilial("VX5")+'066'+aBrowse[oBrowseDados:nAt][07],1,Space(Len(VX5->VX5_DESCRI))),1,26)

//MsgStop("cCorExt "+cCorExt)
//MsgStop("cCorInt "+cCorInt)

AAdd(aParamBox	, {1, "Ano fabricação:" ,Year(dDataBase)	, "9999","MV_PAR01 > 2000"  ,"","", 070, .T.	})
AAdd(aParamBox	, {1, "Ano Modelo:"     ,Year(dDataBase)    , "9999","MV_PAR02 < 2200"  ,"","", 070, .T.	})
//AAdd(aParamBox	, {1, "Cor Externa:"    ,Space(tamSx3("ZC_COREXT")[1]), "@!"   ,"ExistCpo('VX5','067'+MV_PAR03)","VX5","" , 070, .T.	})
//AAdd(aParamBox	, {1, "Cor Interna:"    ,Space(tamSx3("ZC_CORINT")[1]), "@!"   ,"ExistCpo('VX5','066'+MV_PAR04)","VX5","" , 070, .T.	})
AAdd(aParamBox	, {1, "Cor Externa:"    ,cCorExt, "@!"   ,,,".F." , 070, .F.	})
AAdd(aParamBox	, {1, "Cor Interna:"    ,cCorInt, "@!"   ,,,".F." , 070, .F.	})

//AAdd(aParamBox, {1, "Opcional :"      ,Space(tamSx3("ZC_OPCION")[1]), "@!"   ,"ExistCpo('VX5','068'+MV_PAR05)","VX5","" , 070, .T.	})
AAdd(aParamBox	, {2, "Disponibilidade:"	, 1                        , aDisp                  , 070	, ,  .T.	})


IF ParamBox(aParambox, "Informações sobre o Modelo"	, @aRet, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .F. /*lUserSave*/)
    cQuery  := " SELECT *"
	cQuery  += " FROM "+RetSqlName('SZC')
	cQuery  += " WHERE D_E_L_E_T_  = ' ' "
	cQuery  += "  AND ZC_CODMAR = '"+aBrowse[oBrowseDados:nAt][01]+"'"
	cQuery  += "  AND ZC_GRUMOD = '"+aBrowse[oBrowseDados:nAt][02]+"'"
	cQuery  += "  AND ZC_MODVEI = '"+aBrowse[oBrowseDados:nAt][03]+"'"
	cQuery  += "  AND ZC_SEGMOD = '"+aBrowse[oBrowseDados:nAt][04]+"'"
	cQuery  += "  AND ZC_FABANO = '"+Alltrim(STR(MV_PAR01))+"'"
	cQuery  += "  AND ZC_MODANO = '"+Alltrim(STR(MV_PAR02))+"'"
	//cQuery  += "  AND ZC_COREXT = '"+MV_PAR03+"'"
	//cQuery  += "  AND ZC_CORINT = '"+MV_PAR04+"'"
	cQuery  += "  AND ZC_COREXT = '"+aBrowse[oBrowseDados:nAt][06]+"'"
	cQuery  += "  AND ZC_CORINT = '"+aBrowse[oBrowseDados:nAt][07]+"'"
	cQuery  += "  AND ZC_OPCION = '"+aBrowse[oBrowseDados:nAt][08]+"'"
	cQuery  += "  AND ZC_DISPON = '"+IIF(VALTYPE(MV_PAR05) == 'C',SUBSTR(MV_PAR05,1,1),SUBSTR(aDisp[MV_PAR05],1,1) )+"'"
	
	If Select("QRY_PROC") > 0
		QRY_PROC->(dbCloseArea())
	EndIf
	cQuery  := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY_PROC",.T.,.F.)
	dbSelectArea("QRY_PROC")
	QRY_PROC->(dbGoTop())
	IF !QRY_PROC->(EOF())
	       MsgAlert('Já existe registro com este dados!')
	       Return
	Else
	    Reclock("SZC",.T.)
		SZC->ZC_FILIAL := xFilial('SZC')
		SZC->ZC_CODMAR	:= aBrowse[oBrowseDados:nAt][01]
		SZC->ZC_GRUMOD := aBrowse[oBrowseDados:nAt][02]
		SZC->ZC_MODVEI := aBrowse[oBrowseDados:nAt][03]
		SZC->ZC_SEGMOD := aBrowse[oBrowseDados:nAt][04]
		SZC->ZC_FABANO := Alltrim(STR(MV_PAR01))
		SZC->ZC_MODANO := Alltrim(STR(MV_PAR02))
		//SZC->ZC_COREXT := MV_PAR03
		//SZC->ZC_CORINT := MV_PAR04
		SZC->ZC_COREXT := aBrowse[oBrowseDados:nAt][06]
		SZC->ZC_CORINT := aBrowse[oBrowseDados:nAt][07]
		SZC->ZC_OPCION := aBrowse[oBrowseDados:nAt][08] // VV2_OPCION
		IF VALTYPE(MV_PAR05) == 'C'
			SZC->ZC_DISPON := SUBSTR(MV_PAR05,1,1)
		Else
			SZC->ZC_DISPON := SUBSTR(aDisp[MV_PAR05],1,1)
		EndIF
		SZC->ZC_MSBLQL := "2"
		SZC->(MsUnlock())
		MsgAlert('Modelo Cadastrado com Sucesso!!')
	EndIF
EndIF

Return

Static Function myChange()

//MsgStop(nComboBo1)

//MsgStop(PCount())


Return(.T.)

