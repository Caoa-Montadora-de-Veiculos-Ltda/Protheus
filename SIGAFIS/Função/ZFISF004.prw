#Include "Totvs.ch"

User Function ZFISF004()

	Local aOpcRadio	:= {	"Relatório Notas Fiscais de Entrada",;
                            "Relatório Notas Fiscais de Entrada Canceladas",;
                            "Relatório Notas Fiscais de Saida",;
							"Relatório Notas Fiscais de Saida Canceladas" }
	Local nRadio	:=	1
   
	DEFINE MSDIALOG oDlg TITLE "Relatórios de Conferência" FROM 100,0 TO 300,400 PIXEL of oMainWnd STYLE DS_MODALFRAME

	oRadio1:=tRadMenu():New( 010	,010	,aOpcRadio		,{|u|if(PCount()>0,nRadio:=u,nRadio)}	,oDlg	,,,,,,,	,290	,50     ,,,,.T.	)
	oBotao2:=tButton():New(  070	,030	,"Confirmar"	,oDlg	,{|| zOpc(nRadio), oDlg:End()}		            ,050	,011	,,,,.T.	) // "Imprimir"
	oBotao1:=tButton():New(  070	,120	,"Fechar"		,oDlg	,{|| oDlg:End()}				                ,050	,011	,,,,.T.	) // "Fechar"

	ACTIVATE MSDIALOG oDlg

Return     

Static Function zOpc(nRadio)
   
   Do Case
        Case nRadio == 1 //--Nfs de entrada
            If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
                FWMsgRun( ,{|| U_ZFISR003() } ,"Carregando tela de impressão Treport de Nfs de entrada!" ,"Por favor aguarde...")
            ElseIf ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
                FWMsgRun( ,{|| U_ZFISR010() } ,"Carregando tela de impressão Treport de Nfs de entrada!" ,"Por favor aguarde...")
            EndIf
        Case nRadio == 2 //--Nfs de entrada canceladas
            If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
                FWMsgRun( ,{|| U_ZFISR004() } ,"Carregando tela de impressão Treport de Nfs de entrada canceladas!" ,"Por favor aguarde...")
            ElseIf ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
                FWMsgRun( ,{|| U_ZFISR013() } ,"Carregando tela de impressão Treport de Nfs de entrada canceladas!" ,"Por favor aguarde...")
            EndIf
        Case nRadio == 3 //--Nfs de saida
            If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
                FWMsgRun( ,{|| U_ZFISR005() } ,"Carregando tela de impressão Treport de Nfs de saida!" ,"Por favor aguarde...")
            ElseIf ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
                FWMsgRun( ,{|| U_ZFISR011() } ,"Carregando tela de impressão Treport de Nfs de saida!" ,"Por favor aguarde...")
            EndIF
        Case nRadio == 4 //--Nfs de saida canceladas
            If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
                FWMsgRun( ,{|| U_ZFISR006() } ,"Carregando tela de impressão Treport de Nfs de saida canceladas!" ,"Por favor aguarde...")
            ElseIf ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
                FWMsgRun( ,{|| U_ZFISR014() } ,"Carregando tela de impressão Treport de Nfs de saida canceladas!" ,"Por favor aguarde...")
            EndIf
    EndCase


Return
