#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOTVS.CH" 
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FWBROWSE.CH" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FILEIO.CH" 

/*
* Programa..............: CMVFOO01
* Author................: Edson Deluca
* Data..................: 24/09/2018
* Descrição / Objetivo..: FWmBrowse de Tabela de cabeçalho e itens de programação
* Doc. Origem...........: Contrato - GAP
* Solicitante...........: CAOA             
* USO...................:
* Observação............: Criado 2 tabelas ZZ5 (cabeçalho) e ZZ6 (itens) de programação,ZZ0 (log) ZZ7 Limite de Crédito
*/

************************
User Function CMVFOO01()
************************ 

Local aCoors := FWGetDialogSize( oMainWnd ) 
Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseDown, oRelacZA4, oRelacZA5 

//Private aRotina	  := CMVMNU()
Private oDlgPrinc 
Private _lJob     := IIf(GetRemoteType() == -1, .T., .F.)
Private nTipoOrder := 1	
	If _lJob
		RpcSetType(2)
 		RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )
    EndIf

Define MsDialog oDlgPrinc Title "Programação Floor Plan" From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel 

// 
// Cria o conteiner onde serão colocados os browses 

// 
oFWLayer := FWLayer():New() 
oFWLayer:Init( oDlgPrinc, .F., .T. ) 

// 
// Define Painel Superior 
// 
oFWLayer:AddLine( "UP", 50, .F. ) 
// Cria uma "linha" com 50% da tela 
oFWLayer:AddCollumn( "ALL", 100, .T., "UP" ) 
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela 
oPanelUp := oFWLayer:GetColPanel( "ALL", "UP" ) 
// Pego o objeto desse pedaço do container 

// 
// Painel Inferior 
// 
oFWLayer:AddLine( "DOWN", 50, .F. ) 
oFWLayer:AddCollumn( "LEFT" , 100, .T., "DOWN" ) 
oPanelLeft := oFWLayer:GetColPanel( "LEFT" , "DOWN" ) // Pego o objeto do pedaço esquerdo 

// 
// FWmBrowse Superior ZZ1 - Cabeçalho PROPOSTAS Caoa 
// 
oBrowseUp:= FWmBrowse():New() 
oBrowseUp:SetOwner( oPanelUp ) 
oBrowseUp:SetDescription( "Programação" ) 
oBrowseUp:SetAlias( "ZZ5" ) 

oBrowseUp:SetMenuDef( "CMVFOO01" ) 
oBrowseUp:SetProfileID( "1" ) 
oBrowseUp:ForceQuitButton() 

//oBrowseUp:SetMenuDef( "CAOMNU" ) 
oBrowseUp:DisableDetails() 

oBrowseUp:AddLegend("ZZ5_STATUS=='E'","BLUE"   ,"Enviada")
oBrowseUp:AddLegend("ZZ5_STATUS=='A'","YELLOW" ,"Aceita")
oBrowseUp:AddLegend("ZZ5_STATUS=='C'","RED"    ,"Cancelada")
oBrowseUp:AddLegend("ZZ5_STATUS=='X'","BLACK"  ,"Recusada")
oBrowseUp:AddLegend("ZZ5_STATUS=='F'","GREEN"  ,"Faturada")
oBrowseUp:AddLegend("ZZ5_STATUS=='B'","PINK"  ,"Aceite Faturamento")

oBrowseUp:Activate() 

// 
// FWmBrowse Inferior ZZ6 - Itens PROPOSTAS Caoa
// 
oBrowseDown:= FWMBrowse():New() 
oBrowseDown:SetOwner( oPanelLeft ) 
oBrowseDown:SetDescription( "Itens" ) 
oBrowseDown:SetAlias( "ZZ6" ) 

oBrowseDown:SetMenuDef( "" ) 
oBrowseDown:SetProfileID( "2" ) 
oBrowseUp:ForceQuitButton() 

oBrowseDown:Activate() 

// Relacionamento entre os Paineis 
oRelacZZ1:= FWBrwRelation():New() 
oRelacZZ1:AddRelation( oBrowseUp , oBrowseDown , { {"ZZ6_FILIAL","xFilial('ZZ6')"},{"ZZ6_NUMATE","ZZ5_NUMATE"} }) 
oRelacZZ1:Activate() 


Activate MsDialog oDlgPrinc Center 

Return NIL

************************
User Function CMVLEG()
************************

Local oLegenda := FWLegend():New() // Objeto FwLegend. 

oLegenda:Add("","BR_AZUL","Enviada")
oLegenda:Add("","BR_AMARELO","Aceite") 
oLegenda:Add("","BR_VERMELHO","Cancelada") 
oLegenda:Add("","BR_PRETO","Recusada") 
oLegenda:Add("","BR_VERDE","Faturada") 
oLegenda:Add("","BR_PINK","Aceite Faturamento") 

oLegenda:Activate() 
oLegenda:View() 
oLegenda:DeActivate() 

Return( Nil )

************************
Static Function Menudef()
************************

	Local aArea		:= GetArea()
	Local aRotina 	:= {}
	Local aRotina1 := {}
	
	AADD(aRotina, {"Programação"    , "U_CMVPRG()"		, 0, 3, 0, Nil })
	AADD(aRotina, {"Gera Arq.Novamente"    , "U_CMVPRG2()"		, 0, 6, 0, Nil })
	AADD(aRotina, {"Cancelamento"   , "U_CMVCAN()"		, 0, 4, 0, Nil })
	AADD(aRotina, {"Aceite"			, "U_CMVACE()"		, 0, 6, 0, Nil })
	AADD(aRotina, {"Faturamento"	, "U_CMVFAT()"		, 0, 6, 0, Nil })
	AADD(aRotina, {"Denatran"		, "U_CMVDEN()"		, 0, 6, 0, Nil })
	AADD(aRotina, {"Limite Crédito"	, "U_CMVLIM()"		, 0, 6, 0, Nil })
	AADD(aRotina, {"Legenda"	    , "U_CMVLEG()"		, 0, 6, 0, Nil })
	AADD(aRotina, {"LOG"			, "U_CMVLOG()"		, 0, 6, 0, Nil })
	
Return( aRotina )

*****************************
STATIC FUNCTION PRGAjustaX1()
*****************************
Local bRet := .F.
Local aRet := {}
Private aParamBox := {}


AAdd(aParamBox, {1, "Atendimento De "	, Space(10)        , "@!",,     ,, 070	, .F.	})
AAdd(aParamBox, {1, "Atendimento Ate"	, Space(10)        , "@!",,  	,, 070	, .F.	})
AAdd(aParamBox, {1, "Emissao De "       , CTOD('  /  /  ') , "@!",,     ,, 070	, .F.	})
AAdd(aParamBox, {1, "Emissao Ate"    	, CTOD('  /  /  ') , "@!",,     ,, 070	, .F.	})
AAdd(aParamBox, {1, "Cliente De "    	, Space(06)        , "@!",,"SA1",, 070	, .F.	})
AAdd(aParamBox, {1, "Cliente Ate"       , Space(06)        , "@!",,"SA1",, 070	, .F.	})
AAdd(aParamBox, {1, "Loja De "       	, Space(02)        , "@!",,     ,, 070	, .F.	})
AAdd(aParamBox, {1, "Loja Ate"       	, Space(02)        , "@!",, 	,, 070	, .F.	})
AAdd(aParamBox, {1, "Cod.Veiculo De "   , Space(30)        , "@!",,"VV2",, 070	, .F.	})
AAdd(aParamBox, {1, "Cod.Veiculo Ate"	, Space(30)        , "@!",,"VV2",, 070	, .F.	})
bRet := ParamBox(aParambox, "Parametros para seleção dos dados"	, @aRet, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .T. /*lUserSave*/)


Return bRet

*********************************************************************
Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp)
*********************************************************************
	Local aArea := GetArea()
	Local cKey
	Local lPort := .f.
	Local lSpa := .f.
	Local lIngl := .f.

	cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	cPyme    := Iif( cPyme           == Nil, " ", cPyme          )
	cF3      := Iif( cF3           == NIl, " ", cF3          )
	cGrpSxg  := Iif( cGrpSxg     == Nil, " ", cGrpSxg     )
	cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      )
	cHelp    := Iif( cHelp          == Nil, "" , cHelp          )

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )

	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

		Reclock( "SX1" , .T. )

		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid

		Replace X1_VAR01   With cVar01

		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg

		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif

		Replace X1_CNT01   With cCnt01
		If cGSC == "C"               // Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1

			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2

			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3

			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4

			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif

		Replace X1_HELP With cHelp

		//     PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

		MsUnlock()
	Else
		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)

		If lPort .Or. lSpa .Or. lIngl
			RecLock("SX1",.F.)
			If lPort
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf
			If lSpa
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif

	RestArea( aArea )

Return

*********************
User Function CMVPRG
*********************

Local cQuery    := ""
Local oOK       := LoadBitmap(GetResources(),'br_verde')
Local oNO       := LoadBitmap(GetResources(),'br_vermelho')  
Local _lRet     := .T.    
Local _nI       := 0
Local oBtn   
Local bSair     := .F.    


Private aBrowse :={}
Private cNomeArq  := "901_P_"+StrTran(DTOC(dDataBase),"/","")+StrTran(Time(),":","")+".TXT"      
IF !PRGAJUSTAX1()
     Return
EndIF
//Pergunte( cPerg, .T. ,,.F.) 
_cCondPag := SuperGetMV( "CAOA_FLO01" , , "001" ) ///*lHelp*/, .F. /*cPadrao*/ )

cQuery += " SELECT VV0.VV0_FILIAL,VV0.VV0_NUMTRA,VV0.VV0_DATEMI,VV0.VV0_CODCLI,VV0.VV0_LOJA,SA1.A1_NREDUZ,VVA.VVA_MODVEI,VV2.VV2_SEGMOD, VV2.VV2_DESMOD , F2_DOC  FROM "+RetSqlName("VV0")+" VV0 "
cQuery += " INNER JOIN "+RetSqlName("VVA")+" VVA ON VVA.VVA_FILIAL = '"+xFilial("VV0")+"' AND VVA.VVA_NUMTRA = VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' "
cQuery += " INNER JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL = '"+xFilial("VV2")+"' AND VV2.VV2_MODVEI = VV0.VV0_MODVEI  AND VV2.VV2_SEGMOD = VV0.VV0_SEGMOD  AND VV2.D_E_L_E_T_=' ' "
cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = VV0.VV0_CODCLI AND SA1.A1_LOJA = VV0.VV0_LOJA AND SA1.D_E_L_E_T_=' ' "
cQuery += " LEFT JOIN "+RetSqlName("SF2")+" SF2 ON VV0_FILIAL = F2_FILIAL AND VV0_CODCLI = F2_CLIENTE AND VV0_LOJA = F2_LOJA AND VV0_NUMNFI = F2_DOC AND VV0_SERNFI= F2_SERIE AND SF2.D_E_L_E_T_=' ' "
cQuery += " WHERE VV0.VV0_FILIAL = '"+xFilial("VV0")+"' "
cQuery += " AND VV0.VV0_NUMTRA BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
cQuery += " AND VV0.VV0_DATEMI BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+Dtos(MV_PAR04)+"' "
cQuery += " AND VV0.VV0_CODCLI BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
cQuery += " AND VV0.VV0_LOJA BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
cQuery += " AND VVA.VVA_MODVEI BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' "
//cQuery += " AND VV0.VV0_STATUS in  ('A','L','P','O') "
cQuery += " AND VV0.VV0_FORPAG = '"+AllTrim(_cCondPag)+"'"
cQuery += " AND VV0.VV0_NUMTRA NOT IN "
cQuery += " (SELECT ZZ5.ZZ5_NUMATE FROM "+RetSqlName("ZZ5")+" ZZ5 "
cQuery += " WHERE ZZ5.D_E_L_E_T_=' ' AND ZZ5.ZZ5_NUMATE = VV0.VV0_NUMTRA) " 
cQuery += " AND VV0.VV0_NUMTRA NOT IN "
cQuery += " (SELECT VV9.VV9_NUMATE FROM "+RetSqlName("VV9")+" VV9 "
cQuery += " WHERE VV9.D_E_L_E_T_=' ' AND VV9_STATUS = 'C' ) " 
cQuery += " ORDER BY VV0.VV0_NUMTRA "

Iif(Select("TMPQRY")>0,TMPQRY->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQRY")

dbSelectArea("TMPQRY")
dbGoTop()

If Eof() 
   Msgstop("Sem dados a apresentar...")
   Return                              
EndIf

While !Eof()       
           
   aadd(aBrowse,{.F.,TMPQRY->VV0_NUMTRA,TMPQRY->VV0_DATEMI,TMPQRY->VV0_CODCLI,TMPQRY->VV0_LOJA,TMPQRY->A1_NREDUZ,Alltrim(TMPQRY->VVA_MODVEI)+Alltrim(TMPQRY->VV2_SEGMOD),TMPQRY->VV2_DESMOD, TMPQRY->F2_DOC})
   
   dbSelectArea("TMPQRY")
   dbSkip()

End   
                                                                 //550 ,1100
DEFINE DIALOG oDlgX TITLE "Escolha de Propostas" FROM 180,180 TO 600,1350 PIXEL	    

oBrowse := TWBrowse():New( 01 , 01, 508,184,,{'','Atendimento','Data Mov.','Cod.Cliente','Loja','Nome Cliente','Cod.Veículo','Desc. Veiculo','Nota Fiscal'},{20,60,40,40,30,100,80,100},oDlgX,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    

oBrowse:SetArray(aBrowse)    
oBrowse:bLine := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05],aBrowse[oBrowse:nAt,06],aBrowse[oBrowse:nAt,07],aBrowse[oBrowse:nAt,08],aBrowse[oBrowse:nAt,09]}}    
oBrowse:bHeaderClick  := {|oBrw,nCol| OrdenaCab(nCol)}
oBrowse:bLDblClick := {|| aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1],oBrowse:DrawSelect()}  


oBtn  := TButton():New( 004,515,"Confirmar"       ,oDlgX,{|| bSair     := .T.,oDlgX:End()      },060,012,,,,.T.,,"",,,,.F. )
oBtn  := TButton():New( 017,515,"Sair"            ,oDlgX,{|| bSair     := .F.,oDlgX:End()      },060,012,,,,.T.,,"",,,,.F. )


oBtn  := TButton():New( 190,004,'Marcar/Desmarcar', oDlgX,{|| MarcaDesmarca(1) }  ,60, 012,,,.F.,.T.,.F.,,.F.,,,.F. )
oBtn  := TButton():New( 190,065,'Marcar Todas'    , oDlgX,{|| MarcaDesmarca(2) }  ,60, 012,,,.F.,.T.,.F.,,.F.,,,.F. )
oBtn  := TButton():New( 190,126,'Desmarcar Todas' , oDlgX,{|| MarcaDesmarca(3) }  ,60, 012,,,.F.,.T.,.F.,,.F.,,,.F. )


ACTIVATE DIALOG oDlgX CENTERED 

IF bSair 
    Processa( {|| U_GERATUDO(aBrowse,cNomeArq) }, "Aguarde...", "Carregando Propostas...",.F.)
EndIF
              
****************************************
User Function GeraTudo(aBrowse,cNomeArq) 
****************************************
          
Local _nI     := 0
Local _lRet   := .T.
Local bPassou := .F.
Local aSel    := {} 
Local cID     := GetMV("CAOA_FLO02",.F.,) 


Begin Transaction

cID := Soma1(cID)

For _nI:=1 to Len(aBrowse) 

   If aBrowse[_nI][1]
      GeraZZ5ZZ6(aBrowse[_nI][2],cNomeArq,cID)
      AAdd(aSel,aBrowse[_nI][2])
      bPassou := .T.
   EndIf
   
Next _nI               

IF bPassou
	If !MsgYesNo("Deseja enviar as propostas marcadas?", "Atenção")
	   _lRet := .F.
	   DisarmTransaction()
	EndIf
Else
    _lRet := .F.
EndIF


End Transaction

If _lRet
   PutMV("CAOA_FLO02",cID)
   GeraTXT(aSel,cNomeArq,cID)
Else
   MsgStop("Desfeito todas as gravações e envio")      
EndIf

Return         

********************************************
Static Function GeraZZ5ZZ6(cNumAte,cNomeArq,_cSequen )
********************************************


dbSelectArea("VVA")
dbSetOrder(1)
dbSeek(xFilial("VVA")+cNumAte,.F.)
                                   
dbSelectArea("VV0")
dbSetOrder(1)
If dbSeek(xFilial("VV0")+cNumAte,.F.)
   dbSelectArea("ZZ5")
   If RecLock("ZZ5",.T.)
      ZZ5->ZZ5_FILIAL := xFilial("ZZ5")
      ZZ5->ZZ5_NUMATE := cNumAte
      ZZ5->ZZ5_CLIENT := VV0->VV0_CODCLI
      ZZ5->ZZ5_LOJA   := VV0->VV0_LOJA
      ZZ5->ZZ5_NOME   := POSICIONE("SA1",1,XFILIAL("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA,"A1_NREDUZ")
      ZZ5->ZZ5_EMISSA := VV0->VV0_DATEMI
      ZZ5->ZZ5_TIPO   := VV0->VV0_TIPFAT 
      ZZ5->ZZ5_DTREF  := dDataBase
      ZZ5->ZZ5_HRREF  := TIME()
      ZZ5->ZZ5_SEQUEN := _cSequen
      ZZ5->ZZ5_STATUS := "E"
      ZZ5->ZZ5_PEDIDO := ""
      ZZ5->ZZ5_SERIE  := ""
      ZZ5->ZZ5_NOTAF  := ""
      ZZ5->ZZ5_STPED  := ""
      ZZ5->ZZ5_DTFATU := CTOD("  /  /  ")
      ZZ5->ZZ5_USER   := UsrRetName(RetCodUsr())
      ZZ5->ZZ5_DTACEI := CTOD("  /  /  ")
      ZZ5->ZZ5_DTCANC := CTOD("  /  /  ")
      ZZ5->ZZ5_DTGPS  := CTOD("  /  /  ")
      ZZ5->ZZ5_DTDENA := CTOD("  /  /  ") 
      ZZ5->ZZ5_DTLIM  := CTOD("  /  /  ")
      MsUnLock("ZZ5")
   EndIf 
   
   dbSelectArea("ZZ6")
   If RecLock("ZZ6",.T.)
      ZZ6->ZZ6_FILIAL := xFilial("ZZ6")
      ZZ6->ZZ6_NUMATE := cNumAte
      ZZ6->ZZ6_MODVEI := VV0->VV0_MODVEI
      ZZ6->ZZ6_DESMOD := POSICIONE("VV2",2,XFILIAL("VV2")+VVA->VVA_CHASSI,"VV2_DESMOD")
      ZZ6->ZZ6_CHASSI := VVA->VVA_CHASSI
      ZZ6->ZZ6_COR    := VV0->VV0_CORVEI
      MsUnLock("ZZ6")
   EndIf                             
EndIf                      

U_CMVLOGINC("Proposta enviada",cNomeArq,_cSequen)

Return                          

**************************************************
User Function CMVLOGINC(cMotivo,cNomeArq,_cSequen)
**************************************************

dbSelectArea("ZZ0")
If RecLock("ZZ0",.T.)
   ZZ0->ZZ0_FILIAL := xFilial("ZZ0")
   ZZ0->ZZ0_PROPOS := VV0->VV0_NUMTRA
   ZZ0->ZZ0_SEQ    := _cSequen
   ZZ0->ZZ0_STATUS := cMotivo
   ZZ0->ZZ0_DATA   := dDataBase
   ZZ0->ZZ0_HORA   := TIME()
   ZZ0->ZZ0_USER   := UsrRetName(RetCodUsr())
   ZZ0->ZZ0_ARQUIV := cNomeArq
   MsUnLock("ZZ0")
EndIf

return

*********************      
User Function CMVCAN
*********************
Private cNomeArq  := "901_C_"+StrTran(DTOC(dDataBase),"/","")+StrTran(Time(),":","")+".TXT"        


If MsgYesNo("Deseja cancelar as propostas marcada?", "Atenção")
    AtualZZ5(ZZ5->ZZ5_NUMATE,cNomeArq)
    GeraTXT({ZZ5->ZZ5_NUMATE},cNomeArq,"000000")
EndIF

Return

******************************************
Static Function AtualZZ5(cNumAte,cNomeArq)
******************************************

dbSelectArea("VVA")
dbSetOrder(1)
dbSeek(xFilial("VVA")+cNumAte,.F.)
                                   
dbSelectArea("VV0")
dbSetOrder(1)
If dbSeek(xFilial("VV0")+cNumAte,.F.)


   dbSelectArea("ZZ5")
   dbSetOrder(1)
   dbSeek(xFilial("ZZ5")+cNumAte,.F.)
   If RecLock("ZZ5",.F.)
      ZZ5->ZZ5_STATUS := "C"
      ZZ5->ZZ5_STPED  := "C"
      ZZ5->ZZ5_USER   := UsrRetName(RetCodUsr())
      ZZ5->ZZ5_DTCANC := dDataBase
      MsUnLock("ZZ5")
   EndIf 
   
EndIf                      

U_CMVLOGINC("Proposta Cancelada",cNomeArq,_cSequen)

Return                          

*****************************************               
Static Function GeraTxt(aBrowse,cNomeArq,_cSeqTXT)
*****************************************
            
Local _xI      := 0
Local cHeader  := ""
Local cDetail  := ""      
Local cTrail   := ""      
Local _nSeqTXT := 0 
Local _cHrGer  := StrTran(Time(),":","")
Local nRet     := 0 
Local cCGC     := ''
Local cGetDir := cGetFile( , "Selecione o arquivo:", 1,, .T.,  GETF_RETDIRECTORY+GETF_NETWORKDRIVE+GETF_LOCALHARD )

cNomeArq := cGetDir + cNomeArq
  
If (nHandle := MSFCreate(cNomeArq))== -1
	MsgStop("Erro na criação do arquivo de envio" + " " + strzero(ferror(),4))
	Return
EndIf                 

cHeader := "50"+DtoS(dDataBase)+"1CAOAIMP01PROGRAMACAO                        CAOA MONTADORA DE VEICULOS LTD                  "+DtoS(dDataBase)+_cHrGer+_cSeqTXT+Space(5)+Space(86)+Space(30)+"000001"

fWrite(nHandle,cHeader+CRLF)

dbSelectArea("ZZ5")
ZZ5->(dbSetOrder(1))
dbSelectArea("VVA")
VVA->(dbSetOrder(1))
dbSelectArea("VV0")
VV0->(dbSetOrder(1))
dbSelectArea("VV2")
VV2->(dbSetOrder(1)) //VV2_FILIAL+VV2_MODVEI
dbSelectArea("VV6")
VV6->(dbSetOrder(6))
SA1->(dbSetOrder(1))
VV1->(dbSetOrder(2))
_nTotal := 0.00


               
For _xI := 1 to Len(aBrowse)                                                                     

    ZZ5->(dbSeek(xFilial("ZZ5")+aBrowse[_xI],.F.))
    VVA->(dbSeek(xFilial("VVA")+aBrowse[_xI],.F.))
    VV0->(dbSeek(xFilial("VV0")+aBrowse[_xI],.F.))
    VV6->(dbSeek(xFilial("VV6")+aBrowse[_xI]+VVA->VVA_CHAINT,.F.))//Filial+num.Atendimento+Num.Interno Chassi)
    SA1->(dbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA,.F.))  
    VV1->(dbSeek(xFilial("VV1")+VVA->VVA_CHASSI,.F.))
    VV2->( DbSeek( xFilial("VV2") + VV1->( VV1_CODMAR + VV1_MODVEI + VV1_SEGMOD) ) )

    _cOpc   := Space(96)                   
    
    /*While !Eof() .And. VV6->VV6_NUMATE==aBrowse[_xI] .And. VVA->VVA_CHAINT==VV6->VV6_CHAINT 
    
       _cOpc := _cOpc + VV6->VV6_CODOPC+Space(6)
       
       dbSkip()
    
    End*/
//Detalhe programação 51
    cCGC    := SA1->A1_CGC  //Substr(SM0->M0_CGC,1,9)+Substr(SM0->M0_CGC,9,4)+Substr(SM0->M0_CGC,13,2)
    cDetail := "51041"+;
    			PADL(Alltrim(cCGC),15,'0')+;
    			PADR(Alltrim(VV0->VV0_MODVEI),12)+;
    			PADR(Alltrim(VV2->VV2_OPCION),12)+;//PADR(Alltrim(VV0->VV0_SEGMOD),12)+;
    			PADR(Alltrim(VV0->VV0_CORVEI),12)+;
    			PADR('',96)+; //Alltrim(VV2->VV2_OPCION)
                PADR('',24)+;//xFilial("VV0")+VV0->VV0_NUMTRA
                VV1->VV1_FABMOD+;
                "0000000000"+;
                DtoS(dDataBase)+;
                PADL(StrTran(Alltrim(TRANSFORM(Round(VV0->VV0_VALTOT,2),"@E 9999999999.99")),',',''),15,'0')+;
                PADR(Alltrim(VVA->VVA_CHASSI),17)+;
                '01'+;
                Space(8)+Strzero(_xI+1,6)
    _nTotal := _nTotal + VV0->VV0_VALTOT               
    
    fWrite(nHandle,cDetail+CRLF)
              
Next _xI           

cTrail := "59"+strzero(len(aBrowse),5,0)+;
           PADL(StrTran(Alltrim(TRANSFORM(Round(_nTotal,2),"@E 9999999999.99")),',',''),15,'0')+;
           space(192)+space(30)+STRZERO(Len(aBrowse)+2,6)
fWrite(nHandle,cTrail+CRLF)

If !fClose(nHandle)
   MsgStop("Erro no fechamento do Arquivo Texto, erro: "+fError())
Else
   MsgStop("Arquivo criado com sucesso!! Arquivo: "+cNomeArq)
EndIf

Return

*********************
User Function CMVLOG
*********************

Local oBrw            

//Instaciamento
oBrw := FWMBrowse():New()

//tabela que será utilizada
oBrw:SetAlias("ZZ0")                         
//Filtro
oBrw:SetFilterDefault('ZZ0_FILIAL = "'+XFILIAL("ZZ0")+'" .AND. ZZ0_PROPOS = "'+ZZ5->ZZ5_NUMATE+'" ')
//Titulo
oBrw:SetDescription( "Log Transmissão Programação" )


//ativa
oBrw:Activate()

Return              

********************
User Function CMVACE
********************
 
Local aBaixa := {}
PRIVATE aArq := {}

IF fx02LerArq()           
  MsAguarde({|| fProcessaArq(@aArq)})  
EndIF

Return

******************************
Static Function fProcessaArq()
******************************     

Local I        := 1
LOcal cTipoReg := Substr(aArq[I],1,2)
Local cCGC     := ''
Local cChassi  := ''
Local cStatus  := ''
          
If cTipoReg<>"50"
   MsgStop("Arquivo não é de retorno de Aceite Floor Plan, Verifique!")
   Return
EndIf

For I:=2 to Len(aArq)               
                                 
    cTipoReg   := Substr(aArq[I],1,2)
    cStatus    := Substr(aArq[I],56,2)
    
    cCGC     := Substr(aArq[I],7,14)
    cChassi  := Substr(aArq[I],21,17)

	MsProcTxt('Lendo Chassi '+cChassi)
                                   
    If cTipoReg<>"55"
       Exit
    EndIf             
    
    If cStatus $ "05#06#07#08#01"
       U_UPDZZ5(cCGC,cChassi,cStatus)    
    EndIf
    
Next I

msgstop("Fim de Processamento")

Return   

****************************
Static Function fx02LerArq()
****************************

Local cArq  := ""
	
	//Pede pra escolher o arquivo
	cArq := cGetFile("*.txt |*.TXT  |","Selecione o Caminho....",0,,.F.,GETF_LOCALHARD+GETF_OVERWRITEPROMPT)
    cNomeArq := cArq
    
	//Valida arquivo
	If Empty(cArq) .OR. !file(cArq) 
		Aviso("Arquivo","Arquivo não selecionado ou invalido.",{"Sair"},1)
		Return .F.
    EndIf
		
	If (nHandle := FT_FUse(cArq))== -1
		Help(" ",1,"NOFILEIMPOR")
		Return .F.
	EndIf

	MsAguarde({|| fLerArq(@aArq)})  

	If Aviso('Confirmacao','Foram lidas '+Alltrim(Str(Len(aArq)))	+" linhas."+CRLF+'Confirma importacao?.',{'Importar','Cancelar'}) == 1
		Return  .T.
	Endif

Return     
       
*****************************
Static Function fLerArq(aArq)
*****************************

Local cLinha	:=	""
Local nCampo	:=	1
Local aArqTmp	:=	{}
Local nCnt		:=	0 
aArq			:=	{}

	FT_FGOTOP()
	
	While !FT_FEOF()
		
		nCnt++
		If Mod(nCnt,10) == 0
			MsProcTxt('Lendo linha '+StrZero(nCnt,6))
		Endif
		
		cLinha  := FT_FREADLN()
		
		AADD(aArq,cLinha)
		
		FT_FSKIP()
	
	Enddo
	
	FT_FUSE()
	
Return  

**********************************************
User Function UPDZZ5(cCGC,cChassi,cStatus)
**********************************************
Local xStatus  := ""
Local aAreaZZ5 := ZZ5->(GetArea())
Local cQuery   := ""
Local cNomeArq  := ""
Local cSequen   := ""

cQuery := " Select b.R_E_C_N_O_  RECZZ5              "
cQuery += " From "+RetSQLname("ZZ6") +" a , "+RetSQLname("ZZ5") +" b "
cQuery += " Where a.D_E_L_E_T_ = ' '                  "
cQuery += "   AND b.D_E_L_E_T_ = ' '                    "
cQuery += "   AND ZZ6_FILIAL   = ZZ5_FILIAL              "
cQuery += "   AND ZZ6_NUMATE   = ZZ5_NUMATE               "
/*cQuery += "   AND A1_FILIAL    = '          '              "
cQuery += "   AND ZZ5_CLIENT   = A1_COD                   "
cQuery += "   AND ZZ5_LOJA     =  A1_LOJA                  "
cQuery += "   AND A1_CGC       like '%"+cCGC+"%'      "*/
cQuery += "   AND ZZ6_CHASSI   = '"+cChassi+"'      "
cQuery += " Order by b.R_E_C_N_O_ desc "

If Select("QRY_ZZ5") > 0
	QRY_ZZ5->(dbCloseArea())
EndIf	
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY_ZZ5",.T.,.T.)
dbSelectArea("QRY_ZZ5")

QRY_ZZ5->(dbGoTop())
IF QRY_ZZ5->(!Eof())
	If cStatus=="05"   
	   xStatus := "A"
	ElseIf cStatus=="06" .Or. cStatus=="07"
	   xStatus := "X"
	ElseIf cStatus=="01"
	   xStatus := "B"
	Else 
	   xStatus := "C"
	EndIf
	ZZ5->(dbGoTo(QRY_ZZ5->RECZZ5))
	If RecLock("ZZ5",.F.)
	   ZZ5->ZZ5_STATUS := xStatus
	   ZZ5->ZZ5_DTACEI := dDataBase
	   MsUnLock("ZZ5")
	EndIf
	                              
	If xStatus=="A"                                    
	   U_CMVLOGINC("Proposta Aceita",cNomeArq,cSequen)
	ElseIf xStatus=="X"                                    
	   U_CMVLOGINC("Proposta Recusada",cNomeArq,cSequen)
	ElseIf xStatus=="B"                                    
	   U_CMVLOGINC("Aceite Faturamento",cNomeArq,cSequen)
	Else
	   U_CMVLOGINC("Proposta Cancelada Aceita",cNomeArq,cSequen)
	EndIf
EndIF

RestArea(aAreaZZ5)

Return

*****************************
STATIC FUNCTION FATAjustaX1()
*****************************
Local bRet := .F.
Local aRet := {}
Private aParamBox := {}


AAdd(aParamBox, {1, "Proposta de"	  , Space(10)           , "@!",,     ,, 070	, .F.	})
AAdd(aParamBox, {1, "Proposta ate"	  , Space(10)           , "@!",,  	,, 070	, .F.	})
AAdd(aParamBox, {1, "Nota Fiscal de"  , Space(09) 		    , "@!",,"SF2",, 070	, .F.	})
AAdd(aParamBox, {1, "Nota Fiscal até" , Space(09) 		    , "@!",,"SF2",, 070	, .F.	})
AAdd(aParamBox, {1, "Cliente de "     , Space(06)           , "@!",,"SA1",, 070	, .F.	})
AAdd(aParamBox, {1, "Cliente ate"     , Space(06)           , "@!",,"SA1",, 070	, .F.	})
AAdd(aParamBox, {1, "Loja de "        , Space(02)           , "@!",,     ,, 070	, .F.	})
AAdd(aParamBox, {1, "Loja ate"        , Space(02)           , "@!",, 	,, 070	, .F.	})
AAdd(aParamBox, {1, "Cod.Veiculo de " , Space(30)           , "@!",,"VV2",, 070	, .F.	})
AAdd(aParamBox, {1, "Cod.Veiculo ate"  , Space(30)          , "@!",,"VV2",, 070	, .F.	})
AAdd(aParamBox, {1, "Dt Faturamento de"  , CTOD('  /  /  ') , "@!",,     ,, 070	, .F.	})
AAdd(aParamBox, {1, "Dt FaturamentoAte?" , CTOD('  /  /  ') , "@!",,     ,, 070	, .F.	})

bRet := ParamBox(aParambox, "Parametros para seleção dos dados"	, @aRet, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .T. /*lUserSave*/)


Return bRet


Return

*********************
User Function CMVFAT
*********************

Local cQuery    := ""
Local oOK       := LoadBitmap(GetResources(),'br_verde')
Local oNO       := LoadBitmap(GetResources(),'br_vermelho')  
Local _lRet     := .T.    
Local _nI       := 0
Local oBtn    
Local bSair     := .F.


Private aBrowse :={}
Private cNomeArq  := "901_F_"+StrTran(DTOC(dDataBase),"/","")+StrTran(Time(),":","")+".TXT"       
Private cNomeGPS  := "901_G_"+StrTran(DTOC(dDataBase),"/","")+StrTran(Time(),":","")+".TXT"        

IF !FATAJUSTAX1()
     Return
EndIF
//Pergunte( cPerg, .T. )

cQuery += " SELECT VV0.VV0_FILIAL,VV0.VV0_NUMTRA,VV0.VV0_DATEMI,VV0.VV0_CODCLI,VV0.VV0_LOJA,SA1.A1_NREDUZ,VVA.VVA_MODVEI,VV2.VV2_SEGMOD,VV2.VV2_DESMOD FROM "+RetSqlName("VV0")+" VV0 "
cQuery += " INNER JOIN "+RetSqlName("VVA")+" VVA ON VVA.VVA_FILIAL = '"+xFilial("VV0")+"' AND VVA.VVA_NUMTRA = VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' "
cQuery += " INNER JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL = '"+xFilial("VV2")+"' AND VV2.VV2_MODVEI = VV0.VV0_MODVEI AND VV2.VV2_SEGMOD = VV0.VV0_SEGMOD AND VV2.D_E_L_E_T_=' ' "
cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = VV0.VV0_CODCLI AND SA1.A1_LOJA = VV0.VV0_LOJA AND SA1.D_E_L_E_T_=' ' "
cQuery += " INNER JOIN "+RetSqlName("ZZ5")+" ZZ5 ON ZZ5.ZZ5_FILIAL = '"+xFilial("ZZ5")+"' AND ZZ5.ZZ5_NUMATE = VV0.VV0_NUMTRA AND ZZ5.D_E_L_E_T_=' ' "
cQuery += " INNER JOIN "+RetSqlName("SF2")+" SF2 ON VV0_FILIAL = F2_FILIAL AND VV0_CODCLI = F2_CLIENTE AND VV0_LOJA = F2_LOJA AND VV0_NUMNFI = F2_DOC AND VV0_SERNFI= F2_SERIE AND SF2.D_E_L_E_T_=' ' "
cQuery += " WHERE VV0.VV0_FILIAL = '"+xFilial("VV0")+"' "
cQuery += " AND VV0.VV0_NUMTRA BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
cQuery += " AND F2_EMISSAO     BETWEEN '"+DtoS(MV_PAR11)+"' AND '"+Dtos(MV_PAR12)+"' "
cQuery += " AND F2_DOC         BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
cQuery += " AND VV0.VV0_CODCLI BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
cQuery += " AND VV0.VV0_LOJA   BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
cQuery += " AND VVA.VVA_MODVEI BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' "
cQuery += " AND ZZ5.ZZ5_FTENVI <> 'S' "
cQuery += " ORDER BY VV0.VV0_NUMTRA "

Iif(Select("TMPFAT")>0,TMPFAT->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPFAT")

dbSelectArea("TMPFAT")
dbGoTop()

If Eof() 
   Msgstop("Sem dados a apresentar...")
   Return                              
EndIf

While !Eof()       
           
   aadd(aBrowse,{.F.,TMPFAT->VV0_NUMTRA,TMPFAT->VV0_DATEMI,TMPFAT->VV0_CODCLI,TMPFAT->VV0_LOJA,TMPFAT->A1_NREDUZ,Alltrim(TMPFAT->VVA_MODVEI)+Alltrim(TMPFAT->VV2_SEGMOD),TMPFAT->VV2_DESMOD})
   
   dbSelectArea("TMPFAT")
   dbSkip()

End   

DEFINE DIALOG oDlgX TITLE "Escolha Propostas Faturadas" FROM 180,180 TO 600,1350 PIXEL	    

oBrowse := TWBrowse():New( 01 , 01, 508,184,,{'','Atendimento','Data Mov.','Cod.Cliente','Loja','Nome Cliente','Cod.Veículo','Desc. Veiculo'},{20,60,40,40,30,100,80,100},oDlgX,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    

oBrowse:SetArray(aBrowse)    
oBrowse:bLine := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05],aBrowse[oBrowse:nAt,06],aBrowse[oBrowse:nAt,07],aBrowse[oBrowse:nAt,08]}}    
oBrowse:bHeaderClick  := {|oBrw,nCol| OrdenaCab(nCol)}
oBrowse:bLDblClick := {|| aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1],oBrowse:DrawSelect()}  

oBtn  := TButton():New( 004,515,"Confirmar"       ,oDlgX,{|| bSair     := .T.,oDlgX:End()      },060,012,,,,.T.,,"",,,,.F. )
oBtn  := TButton():New( 017,515,"Sair"            ,oDlgX,{|| bSair     := .F.,oDlgX:End()      },060,012,,,,.T.,,"",,,,.F. )


oBtn  := TButton():New( 190,004,'Marcar/Desmarcar', oDlgX,{|| MarcaDesmarca(1) }  ,60, 012,,,.F.,.T.,.F.,,.F.,,,.F. )
oBtn  := TButton():New( 190,065,'Marcar Todas'    , oDlgX,{|| MarcaDesmarca(2) }  ,60, 012,,,.F.,.T.,.F.,,.F.,,,.F. )
oBtn  := TButton():New( 190,126,'Desmarcar Todas' , oDlgX,{|| MarcaDesmarca(3) }  ,60, 012,,,.F.,.T.,.F.,,.F.,,,.F. )


ACTIVATE DIALOG oDlgX CENTERED 

IF bSair 
	Processa( {|| U_zGERATUDO(aBrowse,cNomeArq,cNomeGPS) }, "Aguarde...", "Carregando Propostas...",.F.)
EndIF

              
**************************************************
User Function zGeraTudo(aBrowse,cNomeArq,cNomeGPS) 
**************************************************
          
Local _nI := 0
Local _lRet := .T.
Local bPassou := .F.
Local cID     := GetMV("CAOA_FLO03",.F.,) 
Local aSel    := {} 


Begin Transaction

cID := Soma1(cID)

For _nI:=1 to Len(aBrowse) 

   If aBrowse[_nI][1]
      AtuaZZ5(aBrowse[_nI][2],cNomeArq,cNomeGPS)
      AAdd(aSel,aBrowse[_nI][2])
      bPassou := .T.
   EndIf
   
Next _nI               

If bPassou 
 IF !MsgYesNo("Deseja enviar as propostas Faturadas marcadas?", "Atenção")
   _lRet := .F.
   DisarmTransaction()
 EndIf
Else
   _lRet := .F.
EndIF

End Transaction

If _lRet
   PutMV("CAOA_FLO03",cID)
   GeraFAT(aSel,cNomeArq,cNomeGPS,cID)
Else
   MsgStop("Desfeito todas as gravações e envio")      
EndIf

Return         

**************************************************
Static Function AtuaZZ5(cNumAte,cNomeArq,cNomeGPS)
**************************************************
             
dbSelectArea("ZZ5")
dbSetOrder(1)
dbSeek(xFilial("ZZ5")+cNumAte,.F.)

dbSelectArea("VVA")
dbSetOrder(1)
dbSeek(xFilial("VVA")+cNumAte,.F.)
                                   
dbSelectArea("VV0")
dbSetOrder(1)
If dbSeek(xFilial("VV0")+cNumAte,.F.)

   dbSelectArea("ZZ5")
   dbSetOrder(1)
   dbSeek(xFilial("ZZ5")+cNumAte,.F.)
   
   If RecLock("ZZ5",.F.)
      ZZ5->ZZ5_FTENVI := "S"
      ZZ5->ZZ5_USER   := UsrRetName(RetCodUsr())
      ZZ5->ZZ5_DTGPS  := dDataBase
      MsUnLock("ZZ5")
   EndIf 
   
EndIf                      

U_CMVLOGINC("Faturamento e GPS Enviados",cNomeArq,' ',cNomeGPS)

Return                          

**************************************************               
Static Function GeraFAT(aBrowse,cNomeArq,cNomeGPS,_cSeqTXT)
**************************************************
            
Local _xI         := 0
Local cHeader     := ""
Local cDetail     := ""      
Local cTrail      := ""      
Local cGPSHeader  := ""
Local cGPSDetail  := ""      
Local cGPSTrail   := ""      
Local nCont       := 0 
Local nHandle    
Local nGPSHandle
Local nRet := 0 
Local aSM0    :=  FWArrFilAtu("01",cFilAnt)
Local cCnpj   :=  aSM0[18]
Local cGetDir := cGetFile( , "Selecione o arquivo:", 1,, .T.,  GETF_RETDIRECTORY+GETF_NETWORKDRIVE+GETF_LOCALHARD )
cNomeArq := cGetDir + cNomeArq
cNomeGPS := cGetDir +cNomeGPS
  
If (nHandle := MSFCreate(cNomeArq))== -1
	MsgStop("Erro na criação do arquivo FAT de envio" + " " + strzero(ferror(),4))
	Return
EndIf                 

If (nGPSHandle := MSFCreate(cNomeGPS))== -1
	MsgStop("Erro na criação do arquivo GPS de envio" + " " + strzero(ferror(),4))
	Return
EndIf                 
                   
cHeader := "50"+DtoS(dDataBase)+"1CAOAIMP02FATURAMENTO                        CAOA MONTADORA DE VEICULOS LTD                  "+DtoS(dDataBase)+StrTran(Time(),":","")+_cSeqTXT+Space(5)+Space(86)+Space(30)+"000001"

cGPSHeader := "70"+DtoS(dDataBase)+"CAOAIMPARQUIVO GPS "+_cSeqTXT+Space(19)+"000001"

fWrite(nHandle,cHeader+CRLF)
fWrite(nGPSHandle,cGPSHeader+CRLF)

SA1->(dbSetOrder(1))
SF2->(dbSetOrder(1))

dbSelectArea("ZZ5")
ZZ5->(dbSetOrder(1))
dbSelectArea("VVA")
VVA->(dbSetOrder(1))
dbSelectArea("VV0")
VV0->(dbSetOrder(1))
dbSelectArea("VV2")
VV2->(dbSetOrder(1))
dbSelectArea("VV6")
VV6->(dbSetOrder(6))
VV1->(dbSetOrder(2))


_nTotal := 0.00
               
For _xI := 1 to Len(aBrowse)                                                                     


    ZZ5->(dbSeek(xFilial("ZZ5")+aBrowse[_xI],.F.))
    VVA->(dbSeek(xFilial("VVA")+aBrowse[_xI],.F.))
    VV0->(dbSeek(xFilial("VV0")+aBrowse[_xI],.F.))
    VV6->(dbSeek(xFilial("VV6")+aBrowse[_xI]+VVA->VVA_CHAINT,.F.))//Filial+num.Atendimento+Num.Interno Chassi)
    SA1->(dbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA,.F.))  
    VV1->(dbSeek(xFilial("VV1")+VVA->VVA_CHASSI,.F.))
    SA1->(dbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA,.F.))
    SF2->(dbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA))
    VV2->( DbSeek( xFilial("VV2") + VV1->( VV1_CODMAR + VV1_MODVEI + VV1_SEGMOD) ) )
    _cOpc   := Space(96)                   
    
    cDetail := "520410"+Substr(SA1->A1_CGC,1,8)+Substr(SA1->A1_CGC,9,4)+Substr(SA1->A1_CGC,13,2)+;
    			Substr(VV0->VV0_MODVEI,1,12)+;
    			SUBSTR(VV2->VV2_OPCION,1,6)+SPACE(6)+;
    			VV0->VV0_CORVEI+Space(6)+;
    			_cOpc+SPACE(24)+;
    			VV1->VV1_FABMOD+;
                VV0->VV0_NUMNFI+SPACE(9)+;
                Substr(VVA->VVA_CHASSI,1,17)+;
                DTOS(SF2->F2_EMISSAO)+;
                STRZERO(VV0->VV0_VALTOT*100,15,0)+;
                "01"+Strzero(_xI+1,6,0)
    _nTotal := _nTotal + VV0->VV0_VALTOT               
      
    cGPSDetail := "710410"+Substr(PADR(cCnpj,14),1,14)+Substr(VVA->VVA_CHASSI,1,17)+"20180101"+Space(9)+Strzero(_xI,6,0)
    
    fWrite(nHandle,cDetail+CRLF)
    fWrite(nGPSHandle,cGPSDetail+CRLF)
              
Next _xI           


cTrail := "59"+strzero(len(aBrowse),5,0)+Strzero(_nTotal*100,15,0)+space(192)+space(30)+Strzero(len(aBrowse)+2,6,0)
cGPSTrail := "79"+strzero(len(aBrowse),5,0)+Space(47)+Strzero(len(aBrowse),6,0)

fWrite(nHandle,cTrail+CRLF)
fWrite(nGPSHandle,cGPSTrail+CRLF)

If !fClose(nHandle)
   MsgStop("Erro no fechamento do Arquivo Texto, erro: "+fError())
Else               
   If fClose(nGPSHandle)
      MsgStop("Arquivo FAT criado com sucesso!! Arquivo: "+alltrim(cNomeArq)+" e "+alltrim(cNOmeGPS))
   Else
      MsgStop("Erro no fechamento do Arquivo Texto, erro: "+fError())
   EndIf
EndIf

Return

*************************
User Function XMT460UPD()
*************************

dbSelectArea("VV0")
dbSetOrder(4)
If dbSeek(xFilial("VV0")+SF2->F2_DOC+SF2->F2_SERIE,.F.)
   
   _cNumTra := VV0->VV0_NUMTRA
   
   dbSelectArea("ZZ5")
   dbSetOrder(1)
   If dbSeek(xFilial("ZZ5")+_cNumTra,.F.)
   
      If RecLock("ZZ5",.F.)
         ZZ5->ZZ5_STATUS := "F"
         ZZ5->ZZ5_DTFATU := SF2->F2_EMISSAO
         ZZ5->ZZ5_PEDIDO := SC5->C5_NUM
         ZZ5->ZZ5_NOTAF  := SF2->F2_DOC
         ZZ5->ZZ5_SERIE  := SF2->F2_SERIE
         MsUnLock("ZZ5")
      EndIf
   EndIf
EndIf

Return

*****************************
STATIC FUNCTION DENAjustaX1()
*****************************

Local cPerg  := "CMVDEN    "
Local aArea := GetArea()

xPUTSX1(cPerg,"01","Emissao De ?","Emissao De ?","Emissao De ?","mv_ch1","D",08,0,0,"C","","","","","MV_PAR01","","","","","","","","","","","","","","","","")
xPUTSX1(cPerg,"02","Emissao Ate?","Emissao Ate?","Emissao Ate?","mv_ch2","D",08,0,0,"C","","","","","MV_PAR02","","","","","","","","","","","","","","","","")

RestArea( aArea )

Return

*********************
User Function CMVDEN
*********************

Local cQuery    := ""
Local cPerg     := "CMVDEN    "
Local oOK       := LoadBitmap(GetResources(),'br_verde')
Local oNO       := LoadBitmap(GetResources(),'br_vermelho')  
Local _lRet     := .T.    
Local _nI       := 0
Local bSair     := .F.

Private aBrowse :={}
Private cNomeArq  := "901_D_"+StrTran(DTOC(dDataBase),"/","")+StrTran(Time(),":","")+".TXT"          

//DENAJUSTAX1()

//IF Pergunte( cPerg, .T. )

	cQuery += " SELECT VV0.VV0_FILIAL,VV0.VV0_NUMTRA,VV0.VV0_DATEMI,VV0.VV0_CODCLI,VV0.VV0_LOJA,SA1.A1_NREDUZ,VVA.VVA_MODVEI,VV2.VV2_DESMOD, VV1.* " 
	cQuery += " FROM "+RetSqlName("VV0")+" VV0 "
	cQuery += " INNER JOIN "+RetSqlName("VVA")+" VVA ON VVA.VVA_FILIAL = '"+xFilial("VVA")+"' AND VVA.VVA_NUMTRA = VV0.VV0_NUMTRA AND VVA.D_E_L_E_T_=' ' "
	cQuery += " INNER JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL = '"+xFilial("VV2")+"' AND VV2.VV2_MODVEI = VV0.VV0_MODVEI AND VV2.VV2_SEGMOD = VV0.VV0_SEGMOD AND VV2.D_E_L_E_T_=' ' "
	cQuery += " INNER JOIN "+RetSqlName("VV1")+" VV1 ON VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.VV1_NUMTRA = VV0.VV0_NUMTRA AND VV1.D_E_L_E_T_=' ' "
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"' AND SA1.A1_COD = VV0.VV0_CODCLI AND SA1.A1_LOJA = VV0.VV0_LOJA AND SA1.D_E_L_E_T_=' ' "
	cQuery += " INNER JOIN "+RetSqlName("ZZ5")+" ZZ5 ON ZZ5.ZZ5_FILIAL = '"+xFilial("ZZ5")+"' AND ZZ5.ZZ5_NUMATE = VV0.VV0_NUMTRA AND ZZ5.D_E_L_E_T_=' ' "
	cQuery += " WHERE VV0.VV0_FILIAL = '"+xFilial("VV0")+"' "
	//cQuery += " AND VV0.VV0_DATEMI BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
	//cQuery += " AND ZZ5.ZZ5_STATUS = 'I' "
	cQuery += " AND ZZ5.ZZ5_DTDENA = ' ' "
	cQuery += " AND VV1.VV1_XINTEG = 'S' "
	cQuery += " ORDER BY VV0.VV0_NUMTRA "
	
	Iif(Select("TMPDEN")>0,TMPDEN->(dbCloseArea()),Nil)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPDEN")
	
	dbSelectArea("TMPDEN")
	dbGoTop()
	//Msgstop(TMPDEN->VV0_FILIAL)
	
	If Eof() 
	   Msgstop("Sem dados a apresentar...")
	   Return                              
	EndIf
	
	While !Eof()       
	           
	   aadd(aBrowse,{.F.,TMPDEN->VV0_NUMTRA,TMPDEN->VV0_DATEMI,TMPDEN->VV0_CODCLI,TMPDEN->VV0_LOJA,TMPDEN->A1_NREDUZ,TMPDEN->VVA_MODVEI,TMPDEN->VV2_DESMOD})
	   
	   dbSelectArea("TMPDEN")
	   dbSkip()
	
	End   
	
	DEFINE DIALOG oDlgX TITLE "Escolha de Placas" FROM 180,180 TO 600,1350 PIXEL	    
	
	//oBrowse := TWBrowse():New( 01 , 01, 360,184,,{'','Atendimento','Cod.Cliente'},{60,30,30},oDlgX,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    
	oBrowse := TWBrowse():New( 01 , 01, 508,184,,{'','Atendimento','Data Mov.','Cod.Cliente','Loja','Nome Cliente','Cod.Veículo','Desc. Veiculo'},{60,30,30,30,30,30,30,30},oDlgX,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    
	
	oBrowse:SetArray(aBrowse)    
	oBrowse:bLine := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05],aBrowse[oBrowse:nAt,06],aBrowse[oBrowse:nAt,07],aBrowse[oBrowse:nAt,08]}}    
	oBrowse:bHeaderClick  := {|oBrw,nCol| OrdenaCab(nCol)}
	oBrowse:bLDblClick := {|| aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1],oBrowse:DrawSelect()}  
	
	oBtn  := TButton():New( 004,515,"Confirmar"       ,oDlgX,{|| bSair     := .T.,oDlgX:End()      },060,012,,,,.T.,,"",,,,.F. )
	oBtn  := TButton():New( 017,515,"Sair"            ,oDlgX,{|| bSair     := .F.,oDlgX:End()      },060,012,,,,.T.,,"",,,,.F. )
	
	
	oBtn  := TButton():New( 190,004,'Marcar/Desmarcar', oDlgX,{|| MarcaDesmarca(1) }  ,60, 012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn  := TButton():New( 190,065,'Marcar Todas'    , oDlgX,{|| MarcaDesmarca(2) }  ,60, 012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn  := TButton():New( 190,126,'Desmarcar Todas' , oDlgX,{|| MarcaDesmarca(3) }  ,60, 012,,,.F.,.T.,.F.,,.F.,,,.F. )
		
	
	ACTIVATE DIALOG oDlgX CENTERED 
	IF bSair 
		Processa( {|| U_wGERATUDO(aBrowse,cNomeArq) }, "Aguarde...", "Carregando Propostas...",.F.)
	EndIF
//EndIF
Return              
****************************************
User Function wGeraTudo(aBrowse,cNomeArq) 
****************************************
          
Local _nI     := 0
Local _lRet   := .T.
Local nPassou := .F.

Begin Transaction

For _nI:=1 to Len(aBrowse) 

   If aBrowse[_nI][1]
      GeraPlacaZZ5(aBrowse[_nI][2],cNomeArq)
      nPassou := .T.
   EndIf
   
Next _nI               

IF nPassou 
	If !MsgYesNo("Deseja enviar as propostas marcadas?", "Atenção")
	   _lRet := .F.
	   DisarmTransaction()
	EndIf
Else
    _lRet := .F.
EndIF
End Transaction

If _lRet
   GeraDENtxt(aBrowse,cNomeArq)
Else
   MsgStop("Desfeito todas as gravações e envio")      
EndIf

Return         

********************************************
Static Function GeraPlacaZZ5(cNumAte,cNomeArq)
********************************************

dbSelectArea("VVA")
dbSetOrder(1)
dbSeek(xFilial("VVA")+cNumAte,.F.)
                                   
dbSelectArea("VV0")
dbSetOrder(1)
If dbSeek(xFilial("VV0")+cNumAte,.F.)

   dbSelectArea("ZZ5")
   dbSetOrder(1)
   dbSeek(xFilial("ZZ5")+cNumAte,.F.)

   If RecLock("ZZ5",.T.)
      ZZ5->ZZ5_USER   := UsrRetName(RetCodUsr())
      ZZ5->ZZ5_DTDENA := dDataBase 
      MsUnLock("ZZ5")
   EndIf 
   
EndIf                      

U_CMVLOGINC("Placas ao Denatran Enviado",cNomeArq,_cSequen)

Return                          

*****************************************               
Static Function GeraDENTxt(aBrowse,cNomeArq)
*****************************************
//Gera Denatran             
Local _xI      := 0
Local cHeader  := ""
Local cDetail  := ""      
Local cTrail   := ""      
Local _nSeqTXT := 0 
Local aSM0    :=  FWArrFilAtu()
Local cCnpj   :=  aSM0[18]
Local nRet := 0 
Local cGetDir := cGetFile( , "Selecione o arquivo:", 1,, .T.,  GETF_RETDIRECTORY+GETF_NETWORKDRIVE+GETF_LOCALHARD )
cNomeArq := cGetDir + cNomeArq


/*
If !ExistDir("C:\Floorplan")
   nRet := MakeDir( "C:\FloorPlan" )
   if nRet != 0
      MsgStop( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
   endif
EndIf */

  
If (nHandle := MSFCreate(cNomeArq))== -1
	MsgStop("Erro na criação do arquivo de envio" + " " + strzero(ferror(),4))
	Return
EndIf                 
cHeader := "ITP"+DtoS(dDataBase)+Space(59)

fWrite(nHandle,cHeader+CRLF)
               
For _xI := 1 to Len(aBrowse)                                                                     

    dbSelectArea("ZZ5")
    dbSetOrder(1)
    dbSeek(xFilial("ZZ5")+aBrowse[_xI][2],.F.)
    
    dbSelectArea("VVA")
    dbSetOrder(1)
    dbSeek(xFilial("VVA")+aBrowse[_xI][2],.F.)
    
    dbSelectArea("VV0")
    dbSetOrder(1)
    dbSeek(xFilial("VV0")+aBrowse[_xI][2],.F.)

    dbSelectArea("VV1")
    dbSetOrder(8)
    dbSeek(xFilial("VV1")+aBrowse[_xI][2],.F.)

    dbSelectArea("VV2")                  
    dbSetOrder(4)
    dbSeek(xFilial("VV2")+VV0->VV0_MODVEI,.F.)

    dbSelectArea("SA1")
    dbSetOrder(1)
    dbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA,.F.)   
      
                     
//+VV0->VV0_CODVEN
    cDetail := Dtos(dDataBase)+Substr(VVA->VVA_CHASSI,1,17)+Space(4)+Substr(VV1->VV1_PLAVEI,1,7)+Alltrim(cCnpj)+SUBSTR(VV1->VV1_XCIDAD,2,4)+VV1->VV1_XUFPL+sPACE(14)  
    
    fWrite(nHandle,cDetail+CRLF)
              
Next _xI           

cTrail := "ITP"+strzero(len(aBrowse),9,0)+SPACE(58)

fWrite(nHandle,cTrail+CRLF)

If !fClose(nHandle)
   MsgStop("Erro no fechamento do Arquivo Texto, erro: "+fError())
Else
   MsgStop("Arquivo criado com sucesso!! Arquivo: "+cNomeArq)
EndIf

Return
************************************************************************************************************************
Static Function OrdenaCab(nCol,bMudaOrder)
Local aOrdena := {}
Local aTotal  := {}

aOrdena := AClone(aBrowse)
IF nTipoOrder == 1
	nTipoOrder := 2
	aOrdena := aSort(aOrdena,,,{|x,y| x[nCol] < y[nCol]})
Else
	nTipoOrder := 1
	aOrdena := aSort(aOrdena,,,{|x,y| x[nCol] > y[nCol]})
ENDIF
aBrowse    := aOrdena
oBrowse:DrawSelect()
oBrowse:Refresh()

Return
******************************************************************************************************************************
Static Function MarcaDesmarca(pTipo)            
Local nI := 0

IF pTipo == 1 // Somente uma Linha
	aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1]
	oBrowse:DrawSelect()
	oBrowse:SetFocus()
Else
	For nI:= 1 TO LEN(aBrowse)
		aBrowse[nI][1] := IIF(pTipo==2,.T., .F.)
	Next
	oBrowse:DrawSelect()
	oBrowse:SetFocus()
EndIF
Return
********************************************************************************************************************************************
User Function CMVPRG2
Local cQuery := ''
Local aSel   := {}

Private cNomeArq  := "901_P_"+StrTran(DTOC(ZZ5->ZZ5_EMISSAO),"/","")+StrTran(Time(),":","")+".TXT"      

cQuery := " SELECT ZZ5_NUMATE "
cQuery += " FROM "+RetSqlName("ZZ5")+" ZZ5 "
cQuery += " WHERE D_E_L_E_T_=' ' "
cQuery += "   AND ZZ5_SEQUEN = '"+ZZ5->ZZ5_SEQUEN+"'" 

Iif(Select("TMPQRY")>0,TMPQRY->(dbCloseArea()),Nil)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQRY")

dbSelectArea("TMPQRY")
TMPQRY->(dbGoTop())
While !TMPQRY->(Eof())  
     AAdd(aSel, TMPQRY->ZZ5_NUMATE)
     TMPQRY->(dbSkip())
End

GeraTxt(aSel,cNomeArq,ZZ5->ZZ5_SEQUEN)

Return
