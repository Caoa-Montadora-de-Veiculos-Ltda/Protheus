#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ZVEIF005 ³ Autor ³  A.Carlos             ³ Data ³ 21/05/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Movimentacao dos Veiculos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ZVEIF005(cParCHASSI, cParChaInt)
Local aObjects  := {}, aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
//
Local cBkpFilAnt  := cFilAnt
Local nCont       := 0
Local nRadio      := 1
Local aVeiAux     := {}
Local lPEVC140VEI := ExistBlock("VC140VEI")
Local cVMvOutFil  := "0" // 0 = Sem Permissao ( Não Ver Movimentacoes de Filiais se o usuario nao tem acesso )
//
Private cPesqV   := space(30) // Pesquisa VEICULO
Private cChaInt  := space(6) // ChaInt VEICULO
Private cChassi  := "" // Chassi VEICULO
Private cPlaVei  := "" // Placa VEICULO
Private cFilAtu  := ""
Private aMov     := {} // Movimentacao Externa
Private aInt     := {} // Movimentacao Interna
Private aAte     := {} // Atendimentos
Private aVei     := {} // Informações Chassi - Descricao VEICULO
Private cAte     := "01/11" // VV0_OPEMOV ( 0-Venda / 1-Simulacao ) / VV0_SITNFI ( 1-Valida )
Private cSitVei  := ""
Private cBloqVei := ""
Private cSitVVF  := ""
Private cOpeVVF  := ""
Private cSitVV0  := ""
Private cOpeVV0  := ""
Private aFil     := {}
Private aNFCanE  := {} // NFs canceladas Entrada
Private aNFCanS  := {} // NFs canceladas Saida
Private cCadastro  := "Atendimentos de Veiculo"
Private oBR_VERDE  := LoadBitmap( GetResources(), "BR_VERDE")
Private oBR_OCEAN  := LoadBitmap( GetResources(), "lbok_ocean")
Private oBR_PRETO  := LoadBitmap( GetResources(), "BR_PRETO")
Private oBR_AMARELO:= LoadBitmap( GetResources(), "BR_AMARELO")
Private oBR_LARANJA:= LoadBitmap( GetResources(), "BR_LARANJA")
Private oBR_BRANCO := LoadBitmap( GetResources(), "BR_BRANCO")
Private oBR_AZUL   := LoadBitmap( GetResources(), "BR_AZUL")
Private oBR_VERMELHO := LoadBitmap( GetResources(), "BR_VERMELHO")
Private lVendid    := .f.
Private lReqOS     := .f.
Private lBotBloq   := .f.
Private lBotDesB   := .f.
Private lVNFComp   := .f.
Private lVNFFret   := .f.
Private lVNFCanc   := .t.
Private lBuscChaInt:= .F.
Private oHelperFil := DMS_FilialHelper():New()
Private aSM0Ver    := {} // Filiais Permitidas para o usuario VER linhas das Movimentacoes
Private aSM0Clic   := {} // Filiais Permitidas para o usuario CLICAR na linha da Movimentacao
Default cParCHASSI := cPesqV
Default cParChaInt := cChaInt

If VAI->(FieldPos("VAI_PERRAS")) > 0 // Movimentacoes em Filiais onde o usuario nao tem acesso
	VAI->(dbSetOrder(4))
	If VAI->(MsSeek( xFilial("VAI") + __cUserID ) ) .and. !Empty( VAI->VAI_PERRAS )
		cVMvOutFil := VAI->VAI_PERRAS // 0 = Sem Permissao para Visualizar / 1 = Permite somente VER as Linhas das Movimentacoes / 2 = Permite CLICAR nas linhas das Movimentacoes
	EndIf
EndIf

// Traz todas as Filiais que o usuario tem Permissao de VER as linhas referente a Movimentacao
aSM0Ver  := oHelperFil:GetAllFil( ( cVMvOutFil <> "0" ) ) // .t. = Retorna todas as Filiais mesmo que o usuario nao tem acesso / .f. = Retorna somente as Filiais que o usuario tem acesso

// Traz todas as Filiais que o usuario tem Permissao de CLICAR na linha referente a Movimentacao
aSM0Clic := oHelperFil:GetAllFil( ( cVMvOutFil == "2" ) ) // .t. = Retorna todas as Filiais mesmo que o usuario nao tem acesso / .f. = Retorna somente as Filiais que o usuario tem acesso

//Ponto de entrada para verificação se permite utilizar a rotina.
/*if ExistBlock("VC140VRF")
	if !ExecBlock("VC140VRF",.f.,.f.)
		Return
	Endif
Endif*/

if !Empty(cParChaInt)
	lBuscChaInt := .T.
	cPesqV := cParChaInt
	cChaInt := cParChaInt
elseif ! Empty(cParCHASSI)
	cPesqV := left(cParCHASSI+space(30),30)
end
//
For nCont := 1 to Len(aSM0Ver)

	cFilAnt := aSM0Ver[nCont]
	aAdd(aFil,{ cFilAnt , FWFilialName() })

Next
cFilAnt := cBkpFilAnt
//

// Arrays Listbox
Aadd(aMov, { ctod("") , "" , "   " , "" , "" , "" , "" , 0 ,   "" , "" , "", 0, -1 , "" , "" })
Aadd(aInt, { ctod("") , "" , "" , "" , "" })
Aadd(aAte, { "O" , ctod("") , "" , "" , "" , 0 , "" })

// Ponto de Entrada para retorno de informações customizadas do Veículo
// Retorna: títulos das colunas e tamanhos das colunas
/*If lPEVC140VEI
	aVeiAux := ExecBlock("VC140VEI", .f., .f., { 0, "", "" })
EndIf*/

// Array Listbox (Padrão)
Aadd(aVei, { "Marca"   , 25, "" }) // Marca
Aadd(aVei, { "Modelo"  , 50, "" }) // Modelo
Aadd(aVei, { "Cor"     , 50, "" }) // Cor
Aadd(aVei, { "Fabr/Mod", 35, "" }) // Fabr/Mod
Aadd(aVei, { "Placa"   , 25, "" }) // Placa

// Colunas customizadas pelo Ponto de Entrada referente ao Veículo
If lPEVC140VEI
	For nCont := 1 to Len(aVeiAux)
		Aadd(aVei, { aVeiAux[nCont,1], aVeiAux[nCont,2], "" })
	Next
EndIf

// Pesquisa
If !Empty(cParCHASSI) .OR. !Empty(cParChaInt)
	FS_PESQVEI(0, aPos, lPEVC140VEI)
EndIf

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ], aSizeHalf[ 3 ], aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 15 , .T. , .F. } ) // Topo
aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox Movimentacoes Externas
aAdd( aObjects, { 0 , 80 , .T. , .F. } ) // ListBox Movimentacoes Internas / Atendimentos
aAdd( aObjects, { 0 , 35 , .T. , .F. } ) // Rodape
aPos := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oMov140 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE ("Movimentos") OF oMainWnd;
	PIXEL STYLE DS_MODALFRAME STATUS //Movimentos / Atendimentos do Veiculo

	oMov140:lEscClose := .F.

	// ------- //
	// Veículo //
	// ------- //
	@ aPos[1,1] - 003, aPos[1,2] + 001 TO aPos[1,1] + 015, aPos[1,4] - 055 LABEL (" " + "Veiculo" + " ") OF oMov140 PIXEL // Veiculo
	@ aPos[1,1] + 004, aPos[1,2] + 006 SAY "Chassi" SIZE 30,08 OF oMov140 PIXEL COLOR CLR_BLUE // Chassi:

	@ aPos[1,1] + 003, aPos[1,2] + 027 MSGET oPesq VAR cPesqV VALID FS_PESQVEI(1, aPos, lPEVC140VEI) .and. FS_ORDEM(nRadio) PICTURE "@!";
		F3 "VV1" SIZE 80,06 OF oMov140 PIXEL COLOR CLR_BLUE WHEN Empty(cParCHASSI)

	@ aPos[1,1] + 004, aPos[1,2] + 113 SAY ( cSitVei + " " + IIf(!lReqOS, cFilAtu, "") ) SIZE 400,08 OF oMov140 PIXEL COLOR CLR_BLUE
	@ aPos[1,1] + 004, aPos[1,2] + 350 SAY cBloqVei SIZE 100,08 OF oMov140 PIXEL COLOR CLR_RED
	@ aPos[1,1] + 004, aPos[1,4] - 097 SAY "<< " + cChaInt + " >>" SIZE 50,08 OF oMov140 PIXEL COLOR CLR_RED
	@ aPos[1,1] + 003, aPos[1,4] - 050 BUTTON oGrpSair PROMPT "SAIR" OF oMov140 SIZE 50,10 PIXEL ACTION oMov140:End() //SAIR
	// Fim Veículo

	// --------------------- //
	// Movimentações Fiscais // 
	// --------------------- //
	@ aPos[2,1] - 003, aPos[2,2] TO aPos[2,3], aPos[2,4] + 001 LABEL (" " + "Movimentacoes Fiscais" + " ") OF oMov140 PIXEL // Movimentacoes Fiscais

	@ aPos[2,1] + 005, aPos[2,2] + 003 CHECKBOX oVNFCanc VAR lVNFCanc PROMPT "Exibir NFs Canceladas" OF oMov140 ON CLICK ( FS_PESQVEI(1, aPos, lPEVC140VEI) );
		SIZE 200,08 PIXEL WHEN !Empty(cPesqV) // Exibir NFs Canceladas

	@ aPos[2,1] + 015, aPos[2,2] + 003 CHECKBOX oVNFComp VAR lVNFComp PROMPT "Exibir NFs de complemento em linhas separadas" OF oMov140 ON CLICK ( FS_PESQVEI(1, aPos, lPEVC140VEI) );
		SIZE 200,08 PIXEL WHEN !Empty(cPesqV) // Exibir NFs de complemento em linhas separadas

	@ aPos[2,1] + 025, aPos[2,2] + 003 CHECKBOX oVNFFret VAR lVNFFret PROMPT "Exibir NFs de frete em linhas separadas" OF oMov140 ON CLICK ( FS_PESQVEI(1, aPos, lPEVC140VEI) );
		SIZE 200,08 PIXEL WHEN !Empty(cPesqV) // Exibir NFs de frete em linhas separadas

	@ aPos[2,1] + 008, aPos[2,2] + 165 SAY "Ordem" SIZE 50,08 OF oMov140 PIXEL
	@ aPos[2,1] + 007, aPos[2,2] + 185 RADIO oRadio VAR nRadio PROMPT "Cronológica", "Cronológica Inversa" 3D OF oMov140 PIXEL SIZE 075,10 // Cronológica / Cronológica Inversa
	oRadio:bChange := {|| FS_ORDEM(nRadio) }

	// Listbox Movimentações Fiscais
	oLbMov140 := TWBrowse():New( aPos[2,1]+035, aPos[2,2]+001, aPos[2,4]-4, aPos[2,3]-(aPos[2,1]+36),,,,oMov140 ,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
	oLbMov140:AddColumn( TCColumn():New( "Data"                          , { || Transform(aMov[oLbMov140:nAt,1], "@D")                } ,,,,"LEFT",  025 ,.F.,.F.,,,,.F.,) )
	oLbMov140:AddColumn( TCColumn():New( "Filial"                        , { || aMov[oLbMov140:nAt,2]                                 } ,,,,"LEFT",  027 ,.F.,.F.,,,,.F.,) )
	oLbMov140:AddColumn( TCColumn():New( "Tipo"                          , { || substr(aMov[oLbMov140:nAt,3], 3)                      } ,,,,"LEFT",  023 ,.F.,.F.,,,,.F.,) )
	oLbMov140:AddColumn( TCColumn():New( "Operação"                      , { || aMov[oLbMov140:nAt,4]                                 } ,,,,"LEFT",  042 ,.F.,.F.,,,,.F.,) )
	oLbMov140:AddColumn( TCColumn():New( AllTrim(RetTitle("VVF_TIPDOC")) , { || aMov[oLbMov140:nAt,14]                                } ,,,,"LEFT",  042 ,.F.,.F.,,,,.F.,) )
	oLbMov140:AddColumn( TCColumn():New( "TES"                           , { || aMov[oLbMov140:nAt,5]                                 } ,,,,"LEFT",  045 ,.F.,.F.,,,,.F.,) )
	oLbMov140:AddColumn( TCColumn():New( "Status"                        , { || aMov[oLbMov140:nAt,6]                                 } ,,,,"LEFT",  023 ,.F.,.F.,,,,.F.,) )
	oLbMov140:AddColumn( TCColumn():New( "NF/Série"                      , { || aMov[oLbMov140:nAt,7]                                 } ,,,,"LEFT",  043 ,.F.,.F.,,,,.F.,) )
	oLbMov140:AddColumn( TCColumn():New( "Valor"                         , { || Transform(aMov[oLbMov140:nAt, 8], "@E 99,999,999.99") } ,,,,"RIGHT", 042 ,.F.,.F.,,,,.F.,) )
	oLbMov140:AddColumn( TCColumn():New( "Custo+Frete"                   , { || Transform(aMov[oLbMov140:nAt,12], "@E 99,999,999.99") } ,,,,"RIGHT", 042 ,.F.,.F.,,,,.F.,) )
	oLbMov140:AddColumn( TCColumn():New( "Fornecedor/Clisnte"            , { || aMov[oLbMov140:nAt,9]                                 } ,,,,"LEFT",  120 ,.F.,.F.,,,,.F.,) )
	oLbMov140:AddColumn( TCColumn():New( "Transação/Atendimento"         , { || aMov[oLbMov140:nAt,10]                                } ,,,,"LEFT",  040 ,.F.,.F.,,,,.F.,) )
	If VVF->(FieldPos("VVF_NUMOP")) <> 0
		oLbMov140:AddColumn( TCColumn():New( AllTrim(RetTitle("VVF_NUMOP")) , { || aMov[oLbMov140:nAt,15]                              } ,,,,"LEFT",  042 ,.F.,.F.,,,,.F.,) )
	EndIf
	oLbMov140:bLDblClick := { |nRow,nCol,nFlags| FS_DRILLIN(aMov[oLbMov140:nAt,13],aMov[oLbMov140:nAt,3],Left(aMov[oLbMov140:nAt,2],Len(cFilAnt))) }
	oLbMov140:SetArray(aMov)
	// Fim Listbox Movimentações Fiscais
	// Fim Movimentações Fiscais

	// Movimentações Internas
	@ aPos[3,1] - 003, aPos[3,2] TO aPos[3,3], (aPos[3,4] * 0.3) + 002 LABEL (" " + "Movimentacoes Internas" + " ") OF oMov140 PIXEL // Movimentacoes Internas

	// Listbox Movimentações Internas
	@ aPos[3,1] + 004, aPos[3,2] + 001 LISTBOX oLbInt140 FIELDS HEADER "Data", "Filial", "Arm", "Localizacao" COLSIZES 25, 27, 15, 60; //Data # Filial # Arm. # Localizacao
		SIZE ((aPos[3,4] - aPos[3,2]) * 0.3) - 2, aPos[3,3] - aPos[3,1] - 5 OF oMov140 PIXEL

	oLbInt140:SetArray(aInt)
	oLbInt140:bLine := { || {  Transform(aInt[oLbInt140:nAt,1], "@D"),;
							aInt[oLbInt140:nAt,2],                 ;
							aInt[oLbInt140:nAt,3],                 ;
							aInt[oLbInt140:nAt,4] }}
	// Fim Listbox Movimentações Internas
	// Fim Movimentações Internas

	// Atendimentos Não Finalizados
	@ aPos[3,1] - 003, aPos[3,2] + (aPos[3,4] * 0.3) TO aPos[3,3], aPos[3,4] + 001 LABEL (" " + "Atendimentos Nao Finalizados" + " ") OF oMov140 PIXEL // Atendimentos Nao Finalizados

	// Listbox Atendimentos Não Finalizados
	@ aPos[3,1] + 004, aPos[3,2] + 001 + (aPos[3,4] * 0.3) LISTBOX oLbAte140 FIELDS HEADER "", "Data", "Filial", "Atendimento", "TES",; // Data # Filial # Atendimento # TES
		"Valor", "Cliente" COLSIZES 10, 25, 27, 35, 45, 45, 150 SIZE ((aPos[3,4] - aPos[3,2]) * 0.7) - 2, aPos[3,3] - aPos[3,1] - 5; // Valor # Cliente
			OF oMov140 PIXEL ON DBLCLICK FS_VERATEND(aAte[oLbAte140:nAt,3], aAte[oLbAte140:nAt,4])

	oLbAte140:SetArray(aAte)
	oLbAte140:bLine := { || {  IIf(aAte[oLbAte140:nAt,1] == "A", oBR_VERDE,                      ;
								IIf(aAte[oLbAte140:nAt,1] == "X", oBR_OCEAN,                  ;
								IIf(aAte[oLbAte140:nAt,1] == "F", oBR_PRETO,                  ;
								IIf(aAte[oLbAte140:nAt,1] == "P", oBR_AMARELO,                ;
								IIf(aAte[oLbAte140:nAt,1] == "R", oBR_LARANJA,                ;
								IIf(aAte[oLbAte140:nAt,1] == "O", oBR_BRANCO,                 ;
								IIf(aAte[oLbAte140:nAt,1] == "L", oBR_AZUL,                   ;
								oBR_VERMELHO))))))),                                       ;
							Transform(aAte[oLbAte140:nAt,2], "@D"),                           ;
							aAte[oLbAte140:nAt,3],                                            ;
							aAte[oLbAte140:nAt,4],                                            ;
							aAte[oLbAte140:nAt,5],                                            ;
							FG_AlinVlrs(Transform(aAte[oLbAte140:nAt,6], "@E 99,999,999.99")),;
							aAte[oLbAte140:nAt,7] }}
	// Fim Listbox Atendimentos Não Finalizados
	// Fim Atendimentos Não Finalizados

	// Informações Chassi
	@ aPos[4,1] - 003, aPos[4,2] TO aPos[4,3] + 003, aPos[4,4] - 125 LABEL (" " + "Informações Chassi" + " ") OF oMov140 PIXEL // Informações Chassi

	// Listbox Informações Chassi
	FS_OLBVEI(0, aPos)
	// Fim Listbox Informações Chassi
	// Fim Informações Chassi

	// Botões
	@ aPos[4,1] + 005, aPos[4,4] - 120 BUTTON oGrpDesBlo PROMPT ("Veículo Desbloqueado" + CHR(13) + CHR(10) + "Visualiza Histórico") OF oMov140 SIZE 65,25 PIXEL ACTION FS_BLOQVEI() // Veículo Desbloqueado / Visualiza Histórico
	oGrpDesBlo:lVisible := lBotDesB

	@ aPos[4,1] + 005, aPos[4,4] - 120 BUTTON oGrpBloque PROMPT ("Veículo Bloqueado" + CHR(13) + CHR(10) + "Visualiza Histórico") OF oMov140 SIZE 65,25 PIXEL ACTION FS_BLOQVEI() // Veículo Bloqueado / Visualiza Histórico
	oGrpBloque:lVisible := lBotBloq

	@ aPos[4,1] + 005, aPos[4,4] - 050 BUTTON oGrpNFCanc PROMPT "NFs Canceladas" OF oMov140 SIZE 50,10 PIXEL ACTION FS_NFCANC('V') WHEN ( len(aNFCanE) > 0 .or. len(aNFCanS) > 0 ) //NFs Canceladas
	@ aPos[4,1] + 020, aPos[4,4] - 050 BUTTON oGrpLegend PROMPT "Legenda" OF oMov140 SIZE 50,10 PIXEL ACTION VXA018LEG() //Legenda
	// Fim Botões

ACTIVATE MSDIALOG oMov140

DbSelectArea("VV1")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ZVEIF005 ³ Autor ³  A.Carlos             ³ Data ³ 21/05/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levantamento do Nome do Cliente 			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTip = Tipo de Chamada (0 - Inicial / 1 - Pesquisa)        ³±±
±±³          ³ aPos = Posição do objeto na tela principal                 ³±±
±±³          ³ lPEVC140VEI = Existência do Ponto de Entrada VC140VEI      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQVEI(nTip, aPos, lPEVC140VEI)
Local aRet      := {}
Local lRet      := .f.
Local nTam      := 0
Local cNome     := ""
Local cFilMov   := ""
Local cQuery    := ""
Local cQAlSC6   := "SQLSC6"  // VV1
Local cQAlVO3   := "SQLVO3"  // VO3
Local cQAlSB1   := "SQLSB1"  // SB1
Local cQAlSB2   := "SQLSB2"  // SB2
Local cQAlVVFG  := "SQLVVFG" // VVF/VVG
Local cQAlVV0A  := "SQLVV0A" // VV0/VVA/VV9
Local cQAlSD1   := "SQLSD1"  // SD1
Local cQAlSD2   := "SQLSD2"  // SD2
Local cQAlSD3   := "SQLSD3"  // SD3
Local cSTATUS   := ""
Local aVV1      := {}
Local cGetKey   := Alltrim(cPesqV)
Local cNroNF    := ""
Local cSerNF    := ""
Local cB1COD    := ""
Local lAchouVV1 := .f.
Local nCont     := 0
Local nCntFor   := 0
Local aNFsTodas := {} // TODAS NFs de Frete relacionadas
Local cGruVei   := PadR(GetMv("MV_GRUVEI"),SX3->(TamSX3('B1_GRUPO')[1])) // Grupo do Veiculo
Local lTIPMOV   := ( VV0->(FieldPos("VV0_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )
Local lNUMOP    := ( VVF->(FieldPos("VVF_NUMOP")) > 0 ) // Numero da OP quando intergado com SIGAPCP
//
Local cNamSB1   := RetSqlName("SB1")
Local cNamSB2   := RetSqlName("SB2")
Local cNamSD1   := RetSqlName("SD1")
Local cNamSD2   := RetSqlName("SD2")
Local cNamSD3   := RetSqlName("SD3")
Local cNamSA1   := RetSqlName("SA1")
Local cNamSA2   := RetSqlName("SA2")
Local cNamVVF   := RetSqlName("VVF")
Local cNamVVG   := RetSqlName("VVG")
Local cNamVV9   := RetSqlName("VV9")
Local cNamVV0   := RetSqlName("VV0")
Local cNamVVA   := RetSqlName("VVA")
Local cNamSF4   := RetSqlName("SF4")
Local cNamVOO   := RetSqlName("VOO")
Local cNamSF5   := RetSqlName("SF5")
//
Local cFilSA1   := ""
Local cFilSA2   := ""
Local cFilSF4   := ""
//
Local cAgrDes   := ""
Local cDescTES  := ""
//
Local cBkpFilAnt := cFilAnt
Local cAuxEmpresa := ""
//
Local nRECVOO   := 0
//
Local lVVF_TIPDOC := ( VVF->(FieldPos("VVF_TIPDOC")) > 0 )
Local lVV0_TIPDOC := ( VV0->(FieldPos("VV0_TIPDOC")) > 0 )
Local lVV1_MSBLQL := ( VV1->(FieldPos("VV1_MSBLQL")) > 0 )
//
Local xOrd01    := ctod("")
Local xOrd11    := ""
//
Local nTamPadrao := 0
Local aVeiAux := {} // Informações Chassi - Descricao VEICULO (Customizado)
//
Local lFuncFrete := FindFunction("VA1800111_LevantaTodasNFsFretes")
//
aMov     := {}
aInt     := {}
aAte     := {}
//cChaInt  := left(cPesqV,len(SC6->C6_CHAINT))
cChassi  := left(cPesqV,len(SC6->C6_CHASSI))
//cPlaVei  := left(cPesqV,len(SC6->C6_PLAVEI))
cSitVei  := ""
cBloqVei := ""
cFilAtu  := ""
lBotDesB := .f.
lBotBloq := .f.
If nTip > 0
	oGrpDesBlo:lVisible := .f.
	oGrpBloque:lVisible := .f.
EndIf
If Empty(cPesqV)
	lRet := .t.
Else

	if lBuscChaInt // se chaint foi passado por parametro
		dbSelectArea('VV1')
		dbSetOrder(1)
		lRet := dbSeek( xFilial('VV1') + cChaInt )
		lBuscChaInt := .f.
	else
		lRet := FG_POSVEI("cPesqV",)
	end

	If lRet
		If FindFunction("VM060VEIBLO")
			aRet := VM060VEIBLO(VV1->VV1_CHAINT,"B") // Verifica se o Veiculo esta Bloqueado.
		    If len(aRet) > 0
				lBotBloq := .t.
				If nTip > 0
					oGrpBloque:lVisible := .t.
				EndIf
		 	Else
				aRet := VM060VEIBLO(VV1->VV1_CHAINT,"D") // Verifica se o Veiculo esta Desbloqueado.
			    If len(aRet) > 0
					lBotDesB := .t.
					If nTip > 0
						oGrpDesBlo:lVisible := .t.
					EndIf
		 		EndIf
		 	EndIf
		EndIf

		lRet := .f.
		//cChaInt:= VV1->VV1_CHAINT
		cPesqV := left(SC6->C6_CHASSI + space(30), 30)
        cPesqV   := cChassi

		cQuery := "SELECT               "    //Chassi interno   VV1.VV1_CHAINT
		cQuery += "       SC6.C6_CHASSI "    //VV1.VV1_CHASSI
		cQuery += "     , SC6.C6_XCODMAR"    //VV1.VV1_CODMAR
		cQuery += "     , VV1.VV1_CHAINT"    //Chassi Interno 
		cQuery += "     , VV1.VV1_SITVEI"    //Situação         VV1.VV1_SITVEI
		cQuery += "     , VV1.VV1_PLAVEI"    //Número da Placa  VV1.VV1_PLAVEI
		cQuery += "     , SC6.C6_XFABMOD"    //VV1.VV1_FABMOD
		cQuery += "     , SC6.C6_XDESMOD"    //VV2.VV2_DESMOD
		cQuery += "     , SC6.C6_XCOREXT"
		If lVV1_MSBLQL
			cQuery += " , SC6.C6_BLOQUEI"    //VV1.VV1_MSBLQL
		EndIf
		cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
		/*cQuery +=        " JOIN " + RetSqlName("VV2") + " VV2 "
		cQuery +=               " ON VV2.VV2_FILIAL = '" + xFilial("VV2") + "'"
		cQuery +=              " AND VV2.VV2_CODMAR = VV1.VV1_CODMAR "
		cQuery +=              " AND VV2.VV2_MODVEI = VV1.VV1_MODVEI "
		cQuery +=              " AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD "
		cQuery +=              " AND VV2.D_E_L_E_T_ = ' ' "
		cQuery +=        " JOIN " + RetSqlName("VVC") + " VVC "
		cQuery +=               " ON VVC.VVC_FILIAL = '" + xFilial("VVC") + "'"
		cQuery +=              " AND VVC.VVC_CODMAR = VV1.VV1_CODMAR "
		cQuery +=              " AND VVC.VVC_CORVEI = VV1.VV1_CORVEI "
		cQuery +=              " AND VVC.D_E_L_E_T_ = ' ' "*/
		cQuery +=        " JOIN " + RetSqlName("VV1") + " VV1 "
		cQuery +=               " ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "'"
		cQuery +=              " AND VV1.VV1_CHASSI = SC6.C6_CHASSI "
		cQuery += "WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + " ' "
		cQuery += "  AND SC6.C6_CHASSI = '" + cPesqV + "' "    //AND VV1.VV1_CHAINT = '" + cChaInt + "' "
		cQuery += "  AND SC6.D_E_L_E_T_ = ' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSC6, .F., .T. )

		If !( cQAlSC6 )->( Eof() )
			lRet := .t.
			cChassi := ( cQAlSC6 )->( C6_CHASSI )
			cChaInt := ( cQAlSC6 )->( VV1_CHAINT )
			cPlaVei := ( cQAlSC6 )->( VV1_PLAVEI )

			// Informações Chassi - Descricao VEICULO (Padrão)
			aVei[1,3] := ( cQAlSC6 )->( C6_XCODMAR )
			aVei[2,3] := Alltrim(( cQAlSC6 )->( C6_XDESMOD ))
			aVei[3,3] := Alltrim(( cQAlSC6 )->( C6_XCOREXT ))
			aVei[4,3] := Transform(( cQAlSC6 )->( C6_XFABMOD ), "@R 9999/9999")
			aVei[5,3] := IIF(!Empty(cPlaVei), Transform(cPlaVei, X3Picture("VV1_PLAVEI")), "")

			// Ponto de Entrada para retorno de informações customizadas do Veículo
			////If lPEVC140VEI
				////nTamPadrao := 5 // Tamanho padrão do vetor "aVei" (Informações Chassi - Descricao VEICULO)

				/*aVeiAux := ExecBlock("VC140VEI", .f., .f., { 1, cChassi, cChaInt })*/

				// Colunas customizadas pelo Ponto de Entrada referente ao Veículo
				////For nCont := 1 to Len(aVeiAux)
				////	aVei[nTamPadrao + nCont, 3] := aVeiAux[nCont,1] // Incluir apenas os dados
				////Next
			////EndIf

			cPesqV   := left(( cQAlSC6 )->( C6_CHASSI )+space(30),30)
			cSitVei := "Situacao: "+X3CBOXDESC("VV1_SITVEI",( cQAlSC6 )->( VV1_SITVEI ))+space(5) // Situacao:
			lVendid := .f.
			lReqOS  := .f.

			If ( cQAlSC6 )->( VV1_SITVEI ) == "1"      //Vendido
				lVendid := .t.
			ElseIf ( cQAlSC6 )->( VV1_SITVEI ) == "9"  //Requisitado na OS
				lReqOS := .t.
				/*cQuery := "SELECT VO3.VO3_NUMOSV , VO1.VO1_STATUS , VO3.VO3_FILIAL "
				cQuery +=  " FROM "+RetSqlName("VO3")+" VO3 "
				cQuery +=         " JOIN "+RetSqlName("VO1")+" VO1"
				cQuery +=                " ON VO1.VO1_FILIAL=VO3.VO3_FILIAL "
				cQuery +=               " AND VO1.VO1_NUMOSV=VO3.VO3_NUMOSV "
				cQuery +=               " AND VO1.D_E_L_E_T_=' ' "
				cQuery += "WHERE VO3.VO3_GRUITE='"+cGruVei+"' AND "
				cQuery +=      " VO3.VO3_CODITE='"+left(cChaInt+space(30),len(SB1->B1_CODITE))+"' AND "
				cQuery +=      " VO3.D_E_L_E_T_=' ' "
				cQuery += "ORDER BY VO3.R_E_C_N_O_ DESC"*/
				cQuery := "SELECT SD3.D3_OP , SD3.D3_STATUS , SD3.D3_FILIAL "
				cQuery += "   FROM "+RetSqlName("SD3")+" SD3 "
				cQuery += "WHERE SD3.D3_FILIAL = '"   + xFilial("SD3") + " ' "	
				cQuery += "   AND SD3.D3_XCHASSI = '" + cChassi +"' "
				cQuery += "   AND SD3.D_E_L_E_T_ = ' '"
				cQuery += "ORDER BY SD3.R_E_C_N_O_ DESC"

				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO3, .F., .T. )

				If !( cQAlVO3 )->( Eof() )
					cSitVei += ( cQAlVO3 )->( D3_OP )+" ( "+X3CBOXDESC("VO1_STATUS",( cQAlVO3 )->( D3_STATUS ))+" ) - "+"Filial"+": "+( cQAlVO3 )->( D3_FILIAL ) // Filial
				EndIf
				( cQAlVO3 )->( dbCloseArea() )
			EndIf

			If lVV1_MSBLQL .and. ( cQAlSC6 )->( VV1_MSBLQL ) == "1" // Bloqueado
				cBloqVei := "Bloqueado"
			EndIf
		EndIf
		( cQAlSC6 )->( dbCloseArea() )
	EndIf

	If lRet
		// Levantamento do Codigo no SB1 //
		// 		cQuery += "   AND SB1.B1_CODITE  = '"+left(cChaInt+space(30),len(SB1->B1_CODITE))+"'"
		cQuery := "SELECT SB1.B1_COD "
		cQuery += "  FROM "+RetSqlName("SB1") + " SB1 "
		cQuery += " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
		cQuery += "   AND SB1.B1_GRUPO   = '" + cGruVei +"'"
		cQuery += "   AND SB1.B1_CHASSI  = '" + cChassi +"' "
		cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSB1 , .F., .T. )
		If !( cQAlSB1 )->( Eof() )
			cB1COD := ( cQAlSB1 )->( B1_COD )  // Codigo do Produto (VEICULO)
		EndIf
		( cQAlSB1 )->( dbCloseArea() )

		For nCont := 1 to Len(aSM0Ver)

			cFilAnt := aSM0Ver[nCont]

			cFilSA1 := xFilial("SA1")
			cFilSA2 := xFilial("SA2")
			cFilSF4 := xFilial("SF4")

			If ! Empty(cB1COD)
				// Em Estoque na Filial -> SB2 //
				// Rubens - 07/08/2009
				// Se a VV1 for exclusiva, deve pesquisar pelo CHASSI do Veiculo
				cQuery := "SELECT SB2.B2_FILIAL "
				cQuery += "  FROM " + cNamSB2 + " SB2 "
				cQuery += " WHERE SB2.B2_FILIAL   = '" + xFilial("SB2") + "'"
				cQuery += "   AND SB2.B2_COD      = '" + cB1COD + "'"
				cQuery += "   AND SB2.B2_QATU > 0 " // Somente Registros com Estoque
				cQuery += "   AND SB2.D_E_L_E_T_  = ' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSB2 , .F., .T. )
				If !( cQAlSB2 )->( Eof() )
					cFilAtu := "Em estoque na filial" + ( cQAlSB2 )->( B2_FILIAL )  // Em estoque na filial
					nTam := aScan(aFil,{|x| x[1] == cFilAnt })
					If nTam > 0
						cFilAtu += "-"+left(aFil[nTam,2]+space(20),20)
					EndIf
				EndIf
				( cQAlSB2 )->( dbCloseArea() )

		 		// Movimentacao Interna -> SD3 //
				// Rubens - 07/08/2009
				// Se a VV1 for exclusiva, deve pesquisar pelo CHASSI do Veiculo
				cQuery := "SELECT SD3.D3_FILIAL , SD3.D3_EMISSAO , SD3.D3_LOCAL , SD3.D3_LOCALIZ , SD3.D3_DOC , SD3.D3_NUMSEQ , SD3.D3_TM , SD3.D3_CUSTO1 "
				cQuery += " , SF5.F5_TEXTO "
				cQuery += "   FROM   " + cNamSD3 + " SD3 "
				cQuery += "LEFT JOIN " + cNamSF5 + " SF5 "
				cQuery += "   ON SF5.F5_FILIAL   = '" + xFilial("SF5") + "'"
				cQuery += "   AND SF5.F5_CODIGO  = SD3.D3_TM "
				cQuery += "   AND SF5.D_E_L_E_T_ = ' ' "
				cQuery += "WHERE SD3.D3_FILIAL   = '" + xFilial("SD3") + "'"
				cQuery += "   AND SD3.D3_COD     = '" + cB1COD +"' "
				cQuery += "   AND SD3.D3_TM IN ('499','"+Alltrim(GetNewPar("MV_MIL0065","_"))+"') "
				cQuery += "   AND SD3.D3_CF NOT LIKE 'PR%' " // Nao considerar movimentos de produção
				cQuery += "   AND SD3.D3_ESTORNO <> 'S' "    // Nao imprimir registros estornados
				cQuery += "   AND SD3.D_E_L_E_T_ =  ' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSD3 , .F., .T. )
				While !( cQAlSD3 )->( Eof() )
					cFilMov := ""

					nTam := aScan(aFil,{|x| x[1] == cFilAnt })
					If nTam > 0
						cFilMov += "-"+left(aFil[nTam,2]+space(20),20)
					EndIf

					If ( cQAlSD3 )->( D3_TM ) == '499' // Movimentacao Interna

						Aadd(aInt,{;
							stod(( cQAlSD3 )->( D3_EMISSAO )),;
							cFilAnt+cFilMov,;
							( cQAlSD3 )->( D3_LOCAL ),;
							( cQAlSD3 )->( D3_LOCALIZ ),;
							( cQAlSD3 )->( D3_NUMSEQ ) })

					Else // Despesas do Veiculo

						nRECVOO := FM_SQL("SELECT R_E_C_N_O_ FROM "  + cNamVOO + " WHERE VOO_FILIAL='"+xFilial("VOO")+"' AND VOO_D3DVEI='"+( cQAlSD3 )->( D3_NUMSEQ )+"' AND D_E_L_E_T_=' '")
						If nRECVOO > 0
							DbSelectArea("VOO")
							DbGoTo(nRECVOO)

							// SD3/VOO 
							Aadd(aMov,{;
									stod(( cQAlSD3 )->( D3_EMISSAO )) , ; // 01
									cFilAnt+cFilMov , ; // 02
									"3-"+"Despesa" , ; // "Despesa" // 03
									"Interna" , ; // "Interna" // 04
									( cQAlSD3 )->( D3_TM ) + "-" + ( cQAlSD3 )->( F5_TEXTO ) , ; // 05
									"Válida" , ; // "Válida" // 06
									( cQAlSD3 )->( D3_DOC ) + "-" +( cQAlSD3 )->( D3_NUMSEQ ) , ; // 07
									( cQAlSD3 )->( D3_CUSTO1 ) , ; // 08
									"" , ; // 09
									VOO->VOO_NUMOSV , ; // 10
									dtoc(stod(( cQAlSD3 )->( D3_EMISSAO ))) , ; // 11
									( cQAlSD3 )->( D3_CUSTO1 ) , ; // 12
									nRECVOO,; // 13
									"" ,;  // 14
									"" })  // 15

						EndIf
					EndIf
				  	( cQAlSD3 )->( DbSkip() )
				EndDo
				( cQAlSD3 )->( dbCloseArea() )
			
			EndIf

			// Movimentacao Externa -> Entradas //
			// Rubens - 07/08/2009
			// Se a VV1 for exclusiva, deve pesquisar pelo CHASSI do Veiculo
			cQuery := "SELECT VVF.VVF_FILIAL , VVF.VVF_DTHEMI , VVF.VVF_TRACPA , VVF.VVF_OPEMOV , VVF.VVF_SITNFI , VVF.VVF_DATMOV , VVF.VVF_CLIFOR , VVG.VVG_CODTES , VVF.VVF_NUMNFI , VVF.VVF_SERNFI , VVG.VVG_VALUNI , "
			cQuery +=       " VVF.VVF_NUMTRA , VVF.VVF_CODFOR , VVF.VVF_LOJA , VVF.VVF_NUMNFI , VVF.VVF_SERNFI , VVG.VVG_VALUNI , VVG.VVG_VCNVEI , VVG.VVG_VALFRE , VVF.R_E_C_N_O_ RECVVF, "
			cQuery +=       " VVF.VVF_TIPDOC "
			If lTIPMOV
				cQuery += ", VVF.VVF_TIPMOV "
			EndIf
			If lNUMOP
				cQuery += ", VVF.VVF_NUMOP "
			EndIf
			cQuery += "FROM "+cNamVVG+" VVG "
			cQuery +=       " JOIN "+cNamVVF+" VVF "
			cQuery +=              " ON VVF.VVF_FILIAL = VVG.VVG_FILIAL "
			cQuery +=             " AND VVF.VVF_TRACPA = VVG.VVG_TRACPA "
			cQuery +=             " AND VVF.D_E_L_E_T_=' ' "
			cQuery += "WHERE VVG.VVG_FILIAL = '" + xFilial("VVG") + "' AND "
			cQuery +=      " VVG.VVG_CHAINT = '"+cChaInt+"' AND "
			If !lVNFCanc // Nao mostrar NFs Canceladas
				cQuery +=   " VVF.VVF_SITNFI <> '0' AND "
			EndIf
			cQuery +=      " VVG.D_E_L_E_T_ = ' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVFG , .F., .T. )
			While !( cQAlVVFG )->( Eof() )

				cSitVVF := left(X3CBOXDESC("VVF_SITNFI",( cQAlVVFG )->( VVF_SITNFI ))+space(15),15)
				cOpeVVF := ""
				cAgrDes := ""
				cTipDoc := PadR( X3CBOXDESC("VVF_TIPDOC", ( cQAlVVFG )->VVF_TIPDOC ) , 15 )
				cNumOP  := ""

				If lTIPMOV .and. ( cQAlVVFG )->( VVF_TIPMOV ) <> "0"
					cAgrDes := ( cQAlVVFG )->( VVF_TIPMOV )
				EndIf

				If !Empty(cAgrDes)
					cOpeVVF := IIf(cAgrDes=="1","Agregacao","Desagregacao") // Agregacao / Desagregacao
				Else
					cOpeVVF := PadR( X3CBOXDESC("VVF_OPEMOV",( cQAlVVFG )->( VVF_OPEMOV )) ,15)
				EndIf

				If !Empty(( cQAlVVFG )->( VVF_NUMNFI ))
					cDescTES := ( cQAlVVFG )->( VVG_CODTES )+"-"+left(FM_SQL("SELECT F4_TEXTO FROM "+cNamSF4+" WHERE F4_FILIAL='"+cFilSF4+"' AND F4_CODIGO='"+( cQAlVVFG )->( VVG_CODTES )+"' AND D_E_L_E_T_=' '"),18)
				Else
					cDescTES := " "
					//cDescTES := STR0060 // Mov.Interna - Agrega/Desagrega
				EndIf

				cFilMov := ""
				nTam := aScan(aFil,{|x| x[1] == cFilAnt })
				If nTam > 0
					cFilMov += "-"+left(aFil[nTam,2]+space(20),20)
				EndIf

				cNome := ""
				If ( cQAlVVFG )->( VVF_CLIFOR ) == "C" // Cliente
					cNome := left(FM_SQL("SELECT A1_NOME FROM "+cNamSA1+" WHERE A1_FILIAL='"+cFilSA1+"' AND A1_COD='"+( cQAlVVFG )->( VVF_CODFOR )+"' AND A1_LOJA='"+( cQAlVVFG )->( VVF_LOJA )+"' AND D_E_L_E_T_=' '"),30)
				Else
					cNome := left(FM_SQL("SELECT A2_NOME FROM "+cNamSA2+" WHERE A2_FILIAL='"+cFilSA2+"' AND A2_COD='"+( cQAlVVFG )->( VVF_CODFOR )+"' AND A2_LOJA='"+( cQAlVVFG )->( VVF_LOJA )+"' AND D_E_L_E_T_=' '"),30)
				EndIf

				If lNUMOP
					cNumOP := (cQAlVVFG)->VVF_NUMOP
				EndIf

				// ENTRADA 
				Aadd(aMov,{	;
					stod(( cQAlVVFG )->( VVF_DATMOV )) , ; // 01
					cFilAnt+cFilMov , ; // 02
					"0-"+"OP" , ; // 03  str(30)
					cOpeVVF , ; // 04
					cDescTES , ; // 05
					cSitVVF , ; // 06
					( cQAlVVFG )->( VVF_NUMNFI )+"-"+( cQAlVVFG )->( VVF_SERNFI ) , ; // 07
					( cQAlVVFG )->( VVG_VALUNI ) , ; // 08
					( cQAlVVFG )->( VVF_CODFOR )+"-"+( cQAlVVFG )->( VVF_LOJA )+" "+cNome , ; // 09
					( cQAlVVFG )->( VVF_TRACPA ) , ; // 10
					( cQAlVVFG )->( VVF_DTHEMI ) , ; // 11
					( cQAlVVFG )->( VVG_VCNVEI )+( cQAlVVFG )->( VVG_VALFRE ) , ; // 12
					( cQAlVVFG )->( RECVVF ) ,; // 13
					cTipDoc ,;  // 14
					cNumOP })  // 15
				//

				// Variaveis utilizadas para agrupar o Frete com a NF de Entrada //
				xOrd01 := stod(( cQAlVVFG )->( VVF_DATMOV ))
				xOrd11 := left(( cQAlVVFG )->( VVF_DTHEMI ),15)+"XXX"
				//
				If lVNFComp .and. !Empty(( cQAlVVFG )->( VVF_NUMNFI )) .and. ( Empty(( cQAlVVFG )->( VVF_TIPDOC )) .or. ( cQAlVVFG )->( VVF_TIPDOC ) == '1' )
					cQuery := "SELECT SD1.D1_DTDIGIT , SD1.D1_TES , SD1.D1_DOC , SD1.D1_SERIE , SD1.D1_TOTAL , SD1.D1_FORNECE , SD1.D1_LOJA , SA2.A2_NOME , SD1.D1_EMISSAO , SD1.D1_TOTAL "
					cQuery +=  " FROM "+cNamSD1+" SD1 "
					cQuery +=         " JOIN "+cNamSA2+" SA2 "
					cQuery +=               " ON SA2.A2_FILIAL = '"+xFilial("SA2")+"'"
					cQuery +=              " AND SA2.A2_COD = SD1.D1_FORNECE "
					cQuery +=              " AND SA2.A2_LOJA = SD1.D1_LOJA "
					cQuery +=              " AND SA2.D_E_L_E_T_ = ' ' "
					cQuery += "WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND "
					cQuery +=      " SD1.D1_NFORI = '"+( cQAlVVFG )->VVF_NUMNFI+"' AND "
					cQuery +=      " SD1.D1_SERIORI = '"+( cQAlVVFG )->VVF_SERNFI+"' AND "
					cQuery +=      " SD1.D1_COD = '"+cB1COD+"' AND "
					cQuery +=      " SD1.D_E_L_E_T_ = ' ' "
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSD1 , .F., .T. )
					While !( cQAlSD1 )->( Eof() )
						
						// COMPLEMENTO 
						Aadd(aMov,{;
							stod(( cQAlSD1 )->( D1_DTDIGIT )) , ; //  01
							cFilAnt+cFilMov , ; //  02
							"2-"+"Entrada" , ; //  03 STR0030
							" " , ; //  04  STR0050
							( cQAlSD1 )->( D1_TES )+"-"+left(FM_SQL("SELECT F4_TEXTO FROM "+cNamSF4+" WHERE F4_FILIAL='"+cFilSF4+"' AND F4_CODIGO='"+( cQAlSD1 )->( D1_TES )+"' AND D_E_L_E_T_=' '"),18) , ; //  05
							cSitVVF , ; //  06
							( cQAlSD1 )->( D1_DOC )+"-"+( cQAlSD1 )->( D1_SERIE ) , ; //  07
							( cQAlSD1 )->( D1_TOTAL ) , ; //  08
							( cQAlSD1 )->( D1_FORNECE )+"-"+( cQAlSD1 )->( D1_LOJA )+" "+( cQAlSD1 )->( A2_NOME ) , ; //  09
							"" , ; //  10
							dtoc(stod(( cQAlSD1 )->( D1_EMISSAO ))) , ; //  11
							( cQAlSD1 )->( D1_TOTAL ) , ; //  12
							-1,; //  13
							"" ,;  // 14
							"" })  // 15
						//

						dbSelectArea(cQAlSD1)
						( cQAlSD1 )->( DbSkip() )
					Enddo
					( cQAlSD1 )->( dbCloseArea() )
				EndIf
				//////////////////////////////////////////
				// Ver registro referente a NF de Frete //
				//////////////////////////////////////////
				If lVNFFret .and. !Empty(( cQAlVVFG )->( VVF_NUMTRA )) .and. lFuncFrete
					// Levanta todas as NFs de Frete relacionadas a NF de Origem
					aNFsTodas := VA1800111_LevantaTodasNFsFretes( ( cQAlVVFG )->( VVF_FILIAL ) , ( cQAlVVFG )->( VVF_NUMNFI ) , ( cQAlVVFG )->( VVF_SERNFI ) , ( cQAlVVFG )->( VVF_CODFOR ) , ( cQAlVVFG )->( VVF_LOJA ) ) // TODAS as NFs de Fretes relacionadas
					//
					For nCntFor := 1 to len(aNFsTodas)
						cQuery := "SELECT SD1.D1_DTDIGIT , SD1.D1_TES , SD1.D1_DOC , SD1.D1_SERIE , SD1.D1_TOTAL , "
						cQuery +=       " SD1.D1_FORNECE , SD1.D1_LOJA , SA2.A2_NOME , SD1.D1_EMISSAO , SD1.D1_TOTAL , "
						cQuery +=       " SD1.R_E_C_N_O_ AS RECSD1 "
						cQuery += " FROM "+cNamSD1+" SD1 "
						cQuery +=        " JOIN "+cNamSA2+" SA2 "
						cQuery +=           " ON SA2.A2_FILIAL = '"+xFilial("SA2")+"'"
						cQuery +=          " AND SA2.A2_COD = SD1.D1_FORNECE "
						cQuery +=          " AND SA2.A2_LOJA = SD1.D1_LOJA "
						cQuery +=          " AND SA2.D_E_L_E_T_ = ' ' "
						cQuery += "WHERE SD1.D1_FILIAL  = '"+aNFsTodas[nCntFor,1]+ "'"
						cQuery +=  " AND SD1.D1_DOC     = '"+aNFsTodas[nCntFor,2]+"'"
						cQuery +=  " AND SD1.D1_SERIE   = '"+aNFsTodas[nCntFor,3]+"'"
						cQuery +=  " AND SD1.D1_FORNECE = '"+aNFsTodas[nCntFor,4]+"'"
						cQuery +=  " AND SD1.D1_LOJA    = '"+aNFsTodas[nCntFor,5]+"'"
						cQuery +=  " AND SD1.D1_COD     = '"+cB1COD+"'"
						cQuery +=  " AND SD1.D_E_L_E_T_ = ' ' "
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSD1 , .F., .T. )
						While !( cQAlSD1 )->( Eof() )
							// Frete
							Aadd(aMov,{;
								xOrd01 , ; // 01
								cFilAnt+cFilMov , ; // 02
								"2-"+"Entrada" , ; // 03  STR0030
								" " , ; // 04 STR0025
								( cQAlSD1 )->( D1_TES )+"-"+left(FM_SQL("SELECT F4_TEXTO FROM "+cNamSF4+" WHERE F4_FILIAL='"+cFilSF4+"' AND F4_CODIGO='"+( cQAlSD1 )->( D1_TES )+"' AND D_E_L_E_T_=' '"),18) , ; // 05
								cSitVVF , ; // 06
								( cQAlSD1 )->( D1_DOC )+"-"+( cQAlSD1 )->( D1_SERIE ) , ; // 07
								( cQAlSD1 )->( D1_TOTAL ) , ; // 08
								( cQAlSD1 )->( D1_FORNECE )+"-"+( cQAlSD1 )->( D1_LOJA )+" "+( cQAlSD1 )->( A2_NOME ) , ; // 09
								strzero(( cQAlSD1 )->( RECSD1 ),10) , ; // 10
								xOrd11 , ; // 11
								( cQAlSD1 )->( D1_TOTAL ) , ; // 12
								( cQAlSD1 )->( RECSD1 ) ,; // 13
								"" ,;  // 14
								"" })  // 15

							dbSelectArea(cQAlSD1)
							( cQAlSD1 )->( DbSkip() )
						Enddo
						( cQAlSD1 )->( dbCloseArea() )
					Next
				EndIf
				dbSelectArea(cQAlVVFG)
				( cQAlVVFG )->( DbSkip() )
			EndDo
			( cQAlVVFG )->( dbCloseArea() )

			// Movimentacao Externa -> Saidas //
			// Rubens - 07/08/2009
			// Se a VV1 for exclusiva, deve pesquisar pelo CHASSI do Veiculo
			cQuery := "SELECT VV0.VV0_FILIAL , VV0.VV0_DTHEMI , VV0.VV0_NUMTRA , VV0.VV0_OPEMOV , VV0.VV0_SITNFI , VV0.VV0_DATMOV , VV0.VV0_CLIFOR , VVA.VVA_CODTES , VV0.VV0_TIPFAT , VV9.VV9_STATUS , "
			cQuery +=       " VV0.VV0_NUMNFI , VV0.VV0_SERNFI , VV0.VV0_NNFFDI , VV0.VV0_SNFFDI , VV0.VV0_CODCLI , VV0.VV0_LOJA , VVA.VVA_VALVDA , VVA.VVA_VCAVEI , VVA.VVA_VALFRE , VV0.R_E_C_N_O_ RECVV0 "
			cQuery += "     , VV0.VV0_TIPDOC "
			If lTIPMOV
				cQuery += ", VV0.VV0_TIPMOV "
			EndIf
			cQuery += " FROM "+cNamVVA+" VVA "
			cQuery +=        " JOIN "+cNamVV0+" VV0 "
			cQuery +=             " ON VV0.VV0_FILIAL = VVA.VVA_FILIAL "
			cQuery +=            " AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA "
			cQuery +=            " AND VV0.D_E_L_E_T_=' ' "
			cQuery +=  " LEFT JOIN "+cNamVV9+" VV9 "
			cQuery +=             " ON VV9.VV9_FILIAL = VVA.VVA_FILIAL "
			cQuery +=            " AND VV9.VV9_NUMATE = VVA.VVA_NUMTRA "
			cQuery +=            " AND VV9.D_E_L_E_T_=' ' "
			cQuery += " WHERE VVA.VVA_FILIAL = '"+xFilial("VVA")+"' AND "
			cQuery +=       " VVA.VVA_CHAINT = '"+cChaInt+"' AND "
			If !lVNFCanc // Nao mostrar NFs Cacneladas
				cQuery += "VV0.VV0_SITNFI <> '0' AND "
			EndIf
			cQuery +=       " VVA.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0A , .F., .T. )
			While !( cQAlVV0A )->( Eof() )
			
				cSitVV0 := left(X3CBOXDESC("VV0_SITNFI",( cQAlVV0A )->( VV0_SITNFI ))+space(15),15)
				cOpeVV0 := ""
				cAgrDes := ""
				cTipDoc := PadR( X3CBOXDESC("VV0_TIPDOC", ( cQAlVV0A )->VV0_TIPDOC ) , 15 )

				If lTIPMOV .and. ( cQAlVV0A )->( VV0_TIPMOV ) <> "0"
					cAgrDes := ( cQAlVV0A )->( VV0_TIPMOV )
		 		EndIf

	 			If !Empty(cAgrDes)
					cOpeVV0 := IIf(cAgrDes=="1","Agregacao","Desagregacao") // Agregacao / Desagregacao
				Else
					cOpeVV0 := left(X3CBOXDESC("VV0_OPEMOV",( cQAlVV0A )->( VV0_OPEMOV ))+space(15),15)
				EndIf

				cFilMov := ""
				nTam := aScan(aFil,{|x| x[1] == cFilAnt })
				If nTam > 0
					cFilMov += "-"+left(aFil[nTam,2]+space(20),20)
				EndIf

				cNroNF := ( cQAlVV0A )->( VV0_NUMNFI )
				cSerNF := ( cQAlVV0A )->( VV0_SERNFI )
				If ( cQAlVV0A )->( VV0_TIPFAT ) == "2" // Faturamento Direto
					cNroNF := ( cQAlVV0A )->( VV0_NNFFDI )
					cSerNF := ( cQAlVV0A )->( VV0_SNFFDI )
				EndIf

				If ! Empty(cNroNF)
					cDescTES := ( cQAlVV0A )->( VVA_CODTES )+"-"+left(FM_SQL("SELECT F4_TEXTO FROM "+cNamSF4+" WHERE F4_FILIAL='"+cFilSF4+"' AND F4_CODIGO='"+( cQAlVV0A )->( VVA_CODTES )+"' AND D_E_L_E_T_=' '"),18)
				Else
					//cDescTES := STR0060 // Mov.Interna - Agrega/Desagrega
					cDescTES := " " // Mov.Interna - Agrega/Desagrega
				EndIf
				
				cSTATUS := ( cQAlVV0A )->( VV9_STATUS )
				If cSTATUS == "A" .and. lVendid
					cSTATUS := "X"
				EndIf
				If ( cQAlVV0A )->( VV0_TIPDOC ) == '2' // Mov.Interna SD3
					cSTATUS := "F" // F - Para entrar no vetor de Movimentações
				EndIf

				cNome := ""
				If ( cQAlVV0A )->( VV0_CLIFOR ) == "F" // Fornecedor
					cNome := left(FM_SQL("SELECT A2_NOME FROM "+cNamSA2+" WHERE A2_FILIAL='"+cFilSA2+"' AND A2_COD='"+( cQAlVV0A )->( VV0_CODCLI )+"' AND A2_LOJA='"+( cQAlVV0A )->( VV0_LOJA )+"' AND D_E_L_E_T_=' '"),30)
				Else
					cNome := left(FM_SQL("SELECT A1_NOME FROM "+cNamSA1+" WHERE A1_FILIAL='"+cFilSA1+"' AND A1_COD='"+( cQAlVV0A )->( VV0_CODCLI )+"' AND A1_LOJA='"+( cQAlVV0A )->( VV0_LOJA )+"' AND D_E_L_E_T_=' '"),30)
				EndIf

				If cSTATUS <> "F" .and. Empty( cNroNF+cSerNF ) .and. ( ( cQAlVV0A )->( VV0_OPEMOV )+( cQAlVV0A )->( VV0_SITNFI ) ) $ cAte
					Aadd(aAte,{ ;
						cSTATUS,;
						stod(( cQAlVV0A )->( VV0_DATMOV )),;
						cFilAnt+cFilMov,;
						( cQAlVV0A )->( VV0_NUMTRA ),;
						( cQAlVV0A )->( VVA_CODTES )+"-"+left(FM_SQL("SELECT F4_TEXTO FROM "+cNamSF4+" WHERE F4_FILIAL='"+cFilSF4+"' AND F4_CODIGO='"+( cQAlVV0A )->( VVA_CODTES )+"' AND D_E_L_E_T_=' '"),18),;
						( cQAlVV0A )->( VVA_VALVDA ),;
						( cQAlVV0A )->( VV0_CODCLI )+"-"+( cQAlVV0A )->( VV0_LOJA )+" " + cNome })
				Else
					// SAIDA
					Aadd(aMov,{ ;
						stod(( cQAlVV0A )->( VV0_DATMOV )) ,; // 01
						cFilAnt+cFilMov ,; // 02
						"1-"+"Saída" ,; // 03 STR0029
						cOpeVV0 ,; // 04
						cDescTES ,; // 05
						cSitVV0 ,; // 06
						cNroNF+"-"+cSerNF ,; // 07
						( cQAlVV0A )->( VVA_VALVDA ) ,; // 08
						( cQAlVV0A )->( VV0_CODCLI )+"-"+( cQAlVV0A )->( VV0_LOJA )+" "+cNome ,; // 09
						( cQAlVV0A )->( VV0_NUMTRA ) ,; // 10
						( cQAlVV0A )->( VV0_DTHEMI ) ,; // 11
						( cQAlVV0A )->( VVA_VCAVEI )+( cQAlVV0A )->( VVA_VALFRE ) ,; // 12
						( cQAlVV0A )->( RECVV0 ),; // 13
						cTipDoc ,;  // 14
						"" })  // 15
					//

					If lVNFComp .and. !Empty(( cQAlVV0A )->( VV0_NUMNFI )) .and. ( !lVV0_TIPDOC .or. ( cQAlVV0A )->( VV0_TIPDOC ) <> '2' )
						cQuery := "SELECT SD2.D2_EMISSAO , SD2.D2_TES , SD2.D2_DOC , SD2.D2_SERIE , SD2.D2_TOTAL , SD2.D2_CLIENTE , SD2.D2_LOJA , SA1.A1_NOME , SD2.D2_TOTAL "
						cQuery +=  " FROM "+cNamSD2+" SD2 "
						cQuery +=         " JOIN "+cNamSA1+" SA1 "
						cQuery +=               " ON SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
						cQuery +=              " AND SA1.A1_COD = SD2.D2_CLIENTE "
						cQuery +=              " AND SA1.A1_LOJA = SD2.D2_LOJA "
						cQuery +=              " AND SA1.D_E_L_E_T_ = ' ' "
						cQuery += "WHERE SD2.D2_FILIAL ='" + xFilial("SD2") + "' AND "
						cQuery +=      " SD2.D2_NFORI ='"+( cQAlVV0A )->VV0_NUMNFI+"' AND "
						cQuery +=      " SD2.D2_SERIORI = '"+( cQAlVV0A )->VV0_SERNFI+"' AND "
						cQuery +=      " SD2.D2_COD = '"+cB1COD+"' AND "
						cQuery +=      " SD2.D2_TIPO ='C' AND "
						cQuery +=      " SD2.D_E_L_E_T_ =' ' "
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSD2 , .F., .T. )
						While !( cQAlSD2 )->( Eof() )

							// COMPLEMENTO 
							Aadd(aMov,{	;
								stod(( cQAlSD2 )->( D2_EMISSAO )) , ; // 01
								cFilAnt+cFilMov , ; // 02
								"1-"+"Saída" , ; // 03 STR0029
								" " , ; // 04 STR0050
								( cQAlSD2 )->( D2_TES )+"-"+left(FM_SQL("SELECT F4_TEXTO FROM "+cNamSF4+" WHERE F4_FILIAL='"+cFilSF4+"' AND F4_CODIGO='"+( cQAlSD2 )->( D2_TES )+"' AND D_E_L_E_T_=' '"),18) , ; // 05
								cSitVV0 , ; // 06
								( cQAlSD2 )->( D2_DOC )+"-"+( cQAlSD2 )->( D2_SERIE ) , ; // 07
								( cQAlSD2 )->( D2_TOTAL ) , ; // 08
								( cQAlSD2 )->( D2_CLIENTE )+"-"+( cQAlSD2 )->( D2_LOJA )+" "+( cQAlSD2 )->( A1_NOME ) , ; // 09
								"" , ; // 10
								dtoc(stod(( cQAlSD2 )->( D2_EMISSAO ))) , ; // 11
								( cQAlSD2 )->( D2_TOTAL ) , ; // 12
								-1 ,; // 13
								"" ,;  // 14
								"" })  // 15
							//
							dbSelectArea(cQAlSD2)
							( cQAlSD2 )->( DbSkip() )
						Enddo
						( cQAlSD2 )->( dbCloseArea() )
					EndIf
				EndIf
			  	( cQAlVV0A )->( DbSkip() )
			EndDo
			( cQAlVV0A )->( dbCloseArea() )
		Next nCont
		cFilAnt := cBkpFilAnt
		FS_NFCANC('M',cGruVei,cNamSB1,cNamSD1,cNamSD2,cNamSA1,cNamSA2) // Monta Vetor das NF's Canceladas
	Else
		MsgStop("Veiculo nao encontrado!","Atenção") //Veiculo nao encontrado! # Atencao
		cPesqV := space(30) // Pesquisa VEICULO
		If nTip > 0
			oPesq:Refresh()
		EndIf
	EndIf
EndIf
//

If len(aMov) <= 0
	Aadd(aMov,{ ctod("") , "" , "   " , "" , "" , "" , "" , 0 , "" , "" , "", 0, -1 , "" , "" })
Else
	aSort(aMov,1,,{|x,y| dtos(x[1]) + substr(x[11],10,8) + x[10] < dtos(y[1]) + substr(y[11],10,8) + y[10] })
EndIf

If len(aInt) <= 0
	Aadd(aInt,{ ctod("") , "" , "" , "" , "" })
Else
	aSort(aInt,1,,{|x,y| x[5] < y[5] })
	If !Empty(cFilAtu) .and. substr(cFilAtu,len("Filial")+1,len(SB2->B2_FILIAL)) == substr(aInt[len(aInt),2],1,len(SD3->D3_FILIAL))                   //subtrisn + filial
		cFilAtu += " ( "+aInt[len(aInt),3]+" - "+aInt[len(aInt),4]+" )"
	EndIf
EndIf

If len(aAte) <= 0
	Aadd(aAte,{ "O" , ctod("") , "" , "" , "" , 0 , "" })
Else
	aSort(aAte,1,,{|x,y| dtos(x[2])+x[4]+x[3] < dtos(y[2])+y[4]+y[3] })
EndIf

If nTip > 0
	// Listbox Movimentações Fiscais
	oLbMov140:nAt := 1
	oLbMov140:SetArray(aMov)
	oLbMov140:SetFocus()
	oLbMov140:Refresh()
	// Fim Listbox Movimentações Fiscais

	// Listbox Movimentações Internas
	oLbInt140:nAt := 1
	oLbInt140:SetArray(aInt)
	oLbInt140:bLine := { || {  Transform(aInt[oLbInt140:nAt,1], "@D"),;
							aInt[oLbInt140:nAt,2],                 ;
							aInt[oLbInt140:nAt,3],                 ;
							aInt[oLbInt140:nAt,4] }}
	oLbInt140:SetFocus()
	oLbInt140:Refresh()
	// Listbox Movimentações Internas

	// Listbox Atendimentos Não Finalizados
	oLbAte140:nAt := 1
	oLbAte140:SetArray(aAte)
	oLbAte140:bLine := { || {  IIF(aAte[oLbAte140:nAt,1] == "A", oBR_VERDE,                      ;
								IIF(aAte[oLbAte140:nAt,1] == "X", oBR_OCEAN,                  ;
								IIF(aAte[oLbAte140:nAt,1] == "F", oBR_PRETO,                  ;
								IIF(aAte[oLbAte140:nAt,1] == "P", oBR_AMARELO,                ;
								IIF(aAte[oLbAte140:nAt,1] == "R", oBR_LARANJA,                ;
								IIF(aAte[oLbAte140:nAt,1] == "O", oBR_BRANCO,                 ;
								IIF(aAte[oLbAte140:nAt,1] == "L", oBR_AZUL,                   ;
								oBR_VERMELHO))))))),                                       ;
							Transform(aAte[oLbAte140:nAt,2], "@D"),                           ;
							aAte[oLbAte140:nAt,3],                                            ;
							aAte[oLbAte140:nAt,4],                                            ;
							aAte[oLbAte140:nAt,5],                                            ;
							FG_AlinVlrs(Transform(aAte[oLbAte140:nAt,6], "@E 99,999,999.99")),;
							aAte[oLbAte140:nAt,7] }}
	oLbAte140:SetFocus()
	oLbAte140:Refresh()
	oLbMov140:SetFocus()
	// Fim Listbox Atendimentos Não Finalizados

	// Listbox Informações Chassi
	FS_OLBVEI(0, aPos)
	// Fim Listbox Informações Chassi
EndIf
DbSelectArea("VV1")
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ZVEIF005 ³ Autor ³  A.Carlos             ³ Data ³ 21/05/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta Vetor / Visualiza Tela com as NF Canceladas do		  ³±±
±±³          ³ CHASSI selecionado 					                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_NFCANC(cTip,cGruVei,cNamSB1,cNamSD1,cNamSD2,cNamSA1,cNamSA2)
Local aObjects   := {}, aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cQAlSD1    := "SQLSD1"
Local cQAlSD2    := "SQLSD2"
Local cFilSD1    := ""
Local cFilSD2    := ""
Local cFilSB1    := ""
Local nTam       := 0
Local cQuery     := ""
Local cBkpFilAnt := cFilAnt
Local cAuxEmpresa
Local nCont
Default cGruVei  := ""
Default cNamSB1  := ""
Default cNamSD1  := ""
Default cNamSD2  := ""
Default cNamSA1  := ""
Default cNamSA2  := ""

If cTip == 'M' // Monta Vetor das NF's Canceladas

	aNFCanE := {}
	aNFCanS := {}

	For nCont := 1 to Len(aSM0Ver)

		cFilAnt := aSM0Ver[nCont]

		cFilSB1 := xFilial("SB1")

	    // ENTRADA
		// Rubens - 07/08/2009
		// Se a VV1 for exclusiva, deve pesquisar pelo CHASSI do Veiculo
		cQuery := "SELECT SD1.D1_DTDIGIT , SD1.D1_FILIAL , SD1.D1_DOC , SD1.D1_SERIE , SD1.D1_TOTAL , SD1.D1_FORNECE , SD1.D1_LOJA , SA2.A2_NOME , SD1.D1_TIPO "
		cQuery += " FROM "+cNamSB1+" SB1 "
		cQuery += " JOIN "+cNamSD1+" SD1 ON ( SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_COD=SB1.B1_COD AND SD1.D_E_L_E_T_<>' ' ) "
		cQuery += " JOIN "+cNamSA2+" SA2 ON ( SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD=SD1.D1_FORNECE AND SA2.A2_LOJA=SD1.D1_LOJA AND SA2.D_E_L_E_T_=' ' ) "
		cQuery += " WHERE SB1.B1_FILIAL='"+cFilSB1+"' "
		cQuery += "   AND SB1.B1_GRUPO='"+cGruVei+"' "
		cQuery += "   AND SB1.B1_CODITE='"+left(cChaInt+space(30),len(SB1->B1_CODITE))+"' "
		cQuery += "   AND SB1.D_E_L_E_T_=' ' "
		cQuery += " ORDER BY SD1.D1_NUMSEQ"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSD1 , .F., .T. )
		While !( cQAlSD1 )->( Eof() )
			cFilSD1 := ( cQAlSD1 )->( D1_FILIAL )
			nTam    := aScan(aFil,{|x| x[1] == cFilAnt })
			If nTam > 0
				cFilSD1 += "-"+left(aFil[nTam,2]+space(20),20)
			EndIf
			aAdd(aNFCanE,{stod(( cQAlSD1 )->( D1_DTDIGIT )),cFilSD1,( cQAlSD1 )->( D1_DOC )+"-"+( cQAlSD1 )->( D1_SERIE ),( cQAlSD1 )->( D1_TOTAL ),( cQAlSD1 )->( D1_FORNECE )+"-"+( cQAlSD1 )->( D1_LOJA )+" "+left(( cQAlSD1 )->( A2_NOME ),30) , "Op"+IIf(( cQAlSD1 )->( D1_TIPO )=="C"," - "+"Entrada","")})  //STR0030  STR0050
		  	( cQAlSD1 )->( DbSkip() )
		EndDo
		( cQAlSD1 )->( dbCloseArea() )

		// SAIDA
		// Rubens - 07/08/2009
		// Se a VV1 for exclusiva, deve pesquisar pelo CHASSI do Veiculo
		cQuery := "SELECT SD2.D2_EMISSAO , SD2.D2_FILIAL , SD2.D2_DOC , SD2.D2_SERIE , SD2.D2_TOTAL , SD2.D2_CLIENTE , SD2.D2_LOJA , SA1.A1_NOME , SD2.D2_TIPO "
		cQuery += " FROM "+cNamSB1+" SB1 "
		cQuery += " JOIN "+cNamSD2+" SD2 ON ( SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_COD=SB1.B1_COD AND SD2.D_E_L_E_T_<>' ' ) "
		cQuery += " JOIN "+cNamSA1+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SD2.D2_CLIENTE AND SA1.A1_LOJA=SD2.D2_LOJA AND SA1.D_E_L_E_T_=' ' ) "
		cQuery += " WHERE SB1.B1_FILIAL='" + cFilSB1 + "' "
		cQuery += "   AND SB1.B1_GRUPO='"+cGruVei+"' "
		cQuery += "   AND SB1.B1_CODITE='"+left(cChaInt+space(30),len(SB1->B1_CODITE))+"' "
		cQuery += "   AND SB1.D_E_L_E_T_=' ' "
		cQuery += " ORDER BY SD2.D2_NUMSEQ"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSD2 , .F., .T. )
		While !( cQAlSD2 )->( Eof() )
			cFilSD2 := ( cQAlSD2 )->( D2_FILIAL )
			nTam    := aScan(aFil,{|x| x[1] == cFilAnt })
			If nTam > 0
				cFilSD2 += "-"+left(aFil[nTam,2]+space(20),20)
			EndIf
			aAdd(aNFCanS,{stod(( cQAlSD2 )->( D2_EMISSAO )),cFilSD2,( cQAlSD2 )->( D2_DOC )+"-"+( cQAlSD2 )->( D2_SERIE ),( cQAlSD2 )->( D2_TOTAL ),( cQAlSD2 )->( D2_CLIENTE )+"-"+( cQAlSD2 )->( D2_LOJA )+" "+left(( cQAlSD2 )->( A1_NOME ),30) , "  "+IIf(( cQAlSD2 )->( D2_TIPO )=="C"," - "+"Saída","") })  //STR0029   STR0050
		  	( cQAlSD2 )->( DbSkip() )
		EndDo
		( cQAlSD2 )->( dbCloseArea() )

	Next nCont
    cFilAnt := cBkpFilAnt

Else// cTip == 'V' // Visualiza Tela com NF's Canceladas
	If len(aNFCanE) <= 0
		aAdd(aNFCanE,{ctod(""),"","",0,"","Entrada"})   //STR0030
	EndIf
	If len(aNFCanS) <= 0
		aAdd(aNFCanS,{ctod(""),"","",0,"","Saída"})  //STR0029
	EndIf

	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ], aSizeHalf[ 3 ], aSizeHalf[ 4 ], 3, 3 } // Tamanho Total da Tela
	aAdd( aObjects, { 0 , 35 , .T. , .F. } ) // Topo
	aAdd( aObjects, { 0 , 50 , .T. , .T. } ) // ListBox Entradas / Saidas
	aAdd( aObjects, { 0 , 50 , .T. , .T. } ) // ListBox Entradas / Saidas
	aPos := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oNFCan140 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE ("NF Canceladas") OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS //NF Canceladas

		// Informações Chassi
		@ aPos[1,1] - 003, aPos[1,2] TO aPos[1,3] + 003, aPos[1,4] - 055 LABEL (" " + "Informações Chassi" + " ") OF oNFCan140 PIXEL // Informações Chassi

		// Listbox Informações Chassi
		FS_OLBVEI(1, aPos)
		// Fim Listbox Informações Chassi

		@ aPos[1,1] + 015, aPos[1,4] - 050 BUTTON oNFCSair PROMPT "SAIR" OF oNFCan140 SIZE 50,10 PIXEL ACTION oNFCan140:End() //SAIR
		// Fim Informações Chassi

		// Entrada - NF/Serie
		@ aPos[2,1], aPos[2,2] TO aPos[2,3] + 003, aPos[2,4] + 001 LABEL (" " + "Entrada" + " - " + "NF/Serie" + " ") OF oNFCan140 PIXEL // Entrada - NF/Serie

		// Listbox Entrada - NF/Serie
		@ aPos[2,1] + 007, aPos[2,2] + 001 LISTBOX oLbNFCE140 FIELDS HEADER "data", "filial", " ", "nf/serie", "valor", "fornecedor"; //data # filial # nf/serie # valor # fornecedor
			COLSIZES 25, 27, 70, 35, 45, 170 SIZE (aPos[2,4] - aPos[2,2]) - 1, (aPos[2,3] - aPos[2,1]) - 5 OF oNFCan140 PIXEL

		oLbNFCE140:nAt := 1
		oLbNFCE140:SetArray(aNFCanE)
		oLbNFCE140:bLine := { || { Transform(aNFCanE[oLbNFCE140:nAt,1], "@D"),                           ;
								aNFCanE[oLbNFCE140:nAt,2],                                            ;
								aNFCanE[oLbNFCE140:nAt,6],                                            ;
								aNFCanE[oLbNFCE140:nAt,3],                                            ;
								FG_AlinVlrs(Transform(aNFCanE[oLbNFCE140:nAt,4], "@E 99,999,999.99")),;
								aNFCanE[oLbNFCE140:nAt,5] }}
		// Fim Listbox Entrada - NF/Serie
		// Fim Entrada - NF/Serie

		// Saída - NF/Serie
		@ aPos[3,1], aPos[3,2] TO aPos[3,3] + 003, aPos[3,4] + 001 LABEL (" " + "Saida" + " - " + "NF/Serie" + " ") OF oNFCan140 PIXEL // Saida - NF/Serie

		// Listbox Saída - NF/Serie
		@ aPos[3,1] + 007, aPos[3,2] + 001 LISTBOX oLbNFCS140 FIELDS HEADER "data", "filial", "nf/serie", "valor", cliente, " "; //data # filial # nf/serie # valor # cliente
			COLSIZES 25, 27, 70, 35, 45, 170 SIZE (aPos[3,4] - aPos[3,2]) - 1, (aPos[3,3] - aPos[3,1]) - 5 OF oNFCan140 PIXEL

		oLbNFCS140:nAt := 1
		oLbNFCS140:SetArray(aNFCanS)
		oLbNFCS140:bLine := { || { Transform(aNFCanS[oLbNFCS140:nAt,1], "@D"),                           ;
								aNFCanS[oLbNFCS140:nAt,2],                                            ;
								aNFCanS[oLbNFCS140:nAt,6],                                            ;
								aNFCanS[oLbNFCS140:nAt,3],                                            ;
								FG_AlinVlrs(Transform(aNFCanS[oLbNFCS140:nAt,4], "@E 99,999,999.99")),;
								aNFCanS[oLbNFCS140:nAt,5] }}
		// Fim Listbox Saída - NF/Serie
		// Saída - NF/Serie

	ACTIVATE MSDIALOG oNFCan140
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ZVEIF005 ³ Autor ³  A.Carlos             ³ Data ³ 21/05/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza Tela com os Bloqueios/Desbloqueios do Veiculo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_BLOQVEI()
Local aObjects  := {}, aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cQuery    := ""
Local cQAlVB0   := "SQLVB0"
Local cTitTela  := ""
Local aBloqVei  := {}
cQuery := "SELECT "
cQuery += "VB0.VB0_USUBLO , VB0.VB0_DATBLO , VB0.VB0_HORBLO , VB0.VB0_MOTBLO , "
cQuery += "VB0.VB0_USUDES , VB0.VB0_DATDES , VB0.VB0_HORDES , VB0.VB0_MOTDES , "
cQuery += "VB0.VB0_DATVAL , VB0.VB0_HORVAL "
cQuery += "FROM "+RetSQLName("VB0")+" VB0 "
cQuery += "   WHERE VB0.VB0_FILIAL='"+xFilial("VB0")+"' AND VB0.VB0_CHAINT='"+VV1->VV1_CHAINT+"' AND VB0.D_E_L_E_T_=' ' "
cQuery += "   ORDER BY VB0.VB0_DATBLO , VB0.VB0_HORBLO , VB0.VB0_DATDES , VB0.VB0_HORDES "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVB0 , .F., .T. )
While !( cQAlVB0 )->( Eof() )
    // BLOQUEIO //
	cTitTela := "Visualiza Historico" // Veiculo Bloqueado - Visualiza Historico
	aAdd(aBloqVei,{ UPPER("Veiculo Bloqueado") , UsrRetName(( cQAlVB0 )->( VB0_USUBLO )) ,;
					 Transform(stod(( cQAlVB0 )->( VB0_DATBLO )),"@D")+" "+Transform(( cQAlVB0 )->( VB0_HORBLO ),"@R 99:99")+" "+" " ,;
					 Transform(stod(( cQAlVB0 )->( VB0_DATVAL )),"@D")+" "+Transform(( cQAlVB0 )->( VB0_HORVAL ),"@R 99:99")+" "+" " ,;
					 ( cQAlVB0 )->( VB0_MOTBLO ) })
	// DESBLOQUEIO //
	If !Empty(( cQAlVB0 )->( VB0_USUDES ))
		cTitTela := "Visualiza Historico" // Veiculo Desbloqueado - Visualiza Historico
		aAdd(aBloqVei,{ UPPER("Veiculo Desbloqueado") , UsrRetName(( cQAlVB0 )->( VB0_USUDES )) ,;
					Transform(stod(( cQAlVB0 )->( VB0_DATDES )),"@D")+" "+Transform(( cQAlVB0 )->( VB0_HORDES ),"@R 99:99")+" "+" " ,;
					"",;
					( cQAlVB0 )->( VB0_MOTDES ) })
	EndIf
  	( cQAlVB0 )->( DbSkip() )
EndDo
( cQAlVB0 )->( dbCloseArea() )
If len(aBloqVei) <= 0
	aAdd(aBloqVei,{"","","","",""})
EndIf

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ], aSizeHalf[ 3 ], aSizeHalf[ 4 ], 3, 3 } // Tamanho Total da Tela
aAdd( aObjects, { 0 , 35 , .T. , .F. } ) // Topo
aAdd( aObjects, { 0 , 50 , .T. , .T. } ) // ListBox Entradas / Saidas
aPos := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oBloq140 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (cTitTela) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS

	// Informações Chassi
	@ aPos[1,1] - 003, aPos[1,2] TO aPos[1,3] + 003, aPos[1,4] - 055 LABEL (" " + "Informações Chassi" + " ") OF oBloq140 PIXEL // Informações Chassi

	// Listbox Informações Chassi
	FS_OLBVEI(2, aPos)
	// Fim Listbox Informações Chassi

	@ aPos[1,1] + 015, aPos[1,4] - 050 BUTTON oNFCSair PROMPT "SAIR" OF oBloq140 SIZE 50,10 PIXEL ACTION oBloq140:End() //SAIR
	// Fim Informações Chassi

	// Bloqueio/Desbloqueio do Veiculo
	@ aPos[2,1], aPos[2,2] TO aPos[2,3] + 003, aPos[2,4] + 001 LABEL (" " + "Bloqueio/Desbloqueio do Veiculo" + " ") OF oBloq140 PIXEL // Bloqueio/Desbloqueio do Veiculo

	// Listbox Bloqueio/Desbloqueio do Veiculo
	@ aPos[2,1] + 007, aPos[2,2] + 001 LISTBOX oLbBlq140 FIELDS HEADER "Tipo", "Usuario", "Data/Hora", "Validade", "Motivo"; // Tipo / Usuario / Data/Hora / Validade / Motivo
		COLSIZES 40, 50, 50, 50, 150 SIZE (aPos[2,4] - aPos[2,2]) - 1, (aPos[2,3] - aPos[2,1]) - 5 OF oBloq140 PIXEL

	oLbBlq140:nAt := 1
	oLbBlq140:SetArray(aBloqVei)
	oLbBlq140:bLine := { || { aBloqVei[oLbBlq140:nAt,1],;
							 aBloqVei[oLbBlq140:nAt,2],;
							 aBloqVei[oLbBlq140:nAt,3],;
							 aBloqVei[oLbBlq140:nAt,4],;
							 aBloqVei[oLbBlq140:nAt,5] }}
	// Fim Listbox Bloqueio/Desbloqueio do Veiculo
	// Fim Bloqueio/Desbloqueio do Veiculo

ACTIVATE MSDIALOG oBloq140
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ZVEIF005 ³ Autor ³  A.Carlos             ³ Data ³ 21/05/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza Atendimento no VEIVM011                          |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERATEND(cEmpFil,cAtend)
Local cFilSALVA := cFilAnt
Local cFilAtend := left(cEmpFil,len(VV9->VV9_FILIAL))
Private Inclui  := .f. // Variavel INTERNA utilizada no VEIVM011
Private Altera  := .f. // Variavel INTERNA utilizada no VEIVM011
Private lEmiNfi := .t. // Variavel INTERNA utilizada no VEIVM011
Private lNegPag := .t. // Variavel INTERNA utilizada no VEIVM011
Private lLibVei := .f. // Variavel INTERNA utilizada no VEIVM011
Private lAutFat := .f. // Variavel INTERNA utilizada no VEIVM011
Private _lVerBotoes := .f. // Variavel INTERNA utilizada no VEIVM011
Private bFiltraBrw := {|| Nil}
Private aCampos := {}
Private cCadastro := "Atendimentos"
Private aNewBot := {}
Private aRotina := {{"","PesqV011", 0, 1},;
	  			{"","ATEND011", 0, 2},;
				{"","ATEND011", 0, 3},;
				{"","ATEND011", 0, 4},;
				{"","ATEND011", 0, 5}}
//
If aScan(aSM0Clic,cFilAtend) <= 0
	MsgStop("Usuario sem permissao para Visualizar Movimentacoes desta Filial.","Atenção") // Usuario sem permissao para Visualizar Movimentacoes desta Filial. # Atencao
	Return
EndIf
//
cFilAnt := cFilAtend
DbSelectArea("VV9")
DbSetOrder(1)
If DbSeek( xFilial("VV9") + cAtend )
	If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
		VEIXX002(NIL,NIL,NIL,2,)
	EndIf
EndIf
cFilAnt := cFilSALVA
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ZVEIF005 ³ Autor ³  A.Carlos             ³ Data ³ 21/05/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz o drill na linha de movimentação para as nfs de ent/sai³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DRILLIN(nRECNO, cTipo, cParFil)
Local cFilBkp := cFilAnt
If nRECNO <= 0
	Return
endif
If aScan(aSM0Clic,cParFil) <= 0
	MsgStop("Usuario sem permissao para Visualizar Movimentacoes desta Filial.","Atenção") // Usuario sem permissao para Visualizar Movimentacoes desta Filial. # Atencao
	Return
EndIf
nOpc := 2
aRotina := {{ "" ,"" , 0 , 1},;	// Pesquisar
			{ "" ,"" , 0 , 2},;	// Visualizar
			{ "" ,"" , 0 , 3},;	// Incluir
			{ "" ,"" , 0 , 5},;	// Cancelar
			{ "" ,"" , 0 , 6},;	// Legenda
			{ "" ,"" , 0 , 1}}	// Pesquisa Avancada ( S-Saida por 0-Venda )
cFilAnt := cParFil
Do Case
	Case Left(cTipo,1) == "0" // VVF
		cCadastro := "Entrada" // Entrada
		DBSelectArea("VVF")
		DBGoTo(nRECNO)
		VEIXX000(NIL,NIL,NIL,2,"0")
	Case Left(cTipo,1) == "1" // VV0
		cCadastro := "Saida" // Saida
		DBSelectArea("SD2")
		DBGoTo(nRECNO)
		DBSelectArea("SF2")
		dbSetOrder(1)
		dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE)
		VEIXX001(NIL,NIL,NIL,2,"0")
	Case Left(cTipo,1) == "2" // SD1
		cCadastro := "Entrada" // Entrada
		DBSelectArea("SD1")
		DBGoTo(nRECNO)
		DBSelectArea("SF1")
		dbSetOrder(1)
		dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE)
		MATA103(,,2)
	Case Left(cTipo,1) == "3" // VOO
		cCadastro := "Ordem de Servico" // Ordem de Servico
		VISUALIZA := .T.
		INCLUI    := .F.
		ALTERA    := .F.
		EXCLUI    := .F.
		DBSelectArea("SC2")
		DBGoTo(nRECNO)
		/*DBSelectArea("VO1")
		DBSetOrder(1)
		DBSeek(xFilial("VO1")+VOO->VOO_NUMOSV)
		OFIOC060(.T.)*/
EndCase
cCadastro := "Atendimentos de Veiculo - VOLTA cCadastro" //Atendimentos de Veiculo - VOLTA cCadastro
cFilAnt := cFilBkp
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ZVEIF005 ³ Autor ³  A.Carlos             ³ Data ³ 21/05/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ordena cronalogica ou cronologica inverso.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ORDEM(nRadio)
if nRadio == 1
	aSort(aMov,1,,{|x,y| dtos(x[1])+substr(x[11],10,8) < dtos(y[1])+substr(y[11],10,8) })
Else
	aSort(aMov,1,,{|x,y| dtos(x[1])+substr(x[11],10,8) > dtos(y[1])+substr(y[11],10,8) })
Endif
oLbMov140:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ZVEIF005 ³ Autor ³  A.Carlos             ³ Data ³ 21/05/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Listbox da Descrição do Veículo                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTip = Tipo de Chamada (0 - Inicial / 1 - Pesquisa)        ³±±
±±³          ³ aPos = Posição dos objetos nas telas (Principal /          ³±±
±±³          ³        NFCanceladas / Histórico Bloqueio/Desbloqueio )     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OLBVEI(nTip, aPos)
Local nCont := 0

If nTip == 0
	// ZVEIF005() / FS_PESQVEI()
	// Destruir o objeto
	oLbVei140 := Nil

	// Criar novamente o objeto Listbox (Informações Chassi)
	oLbVei140 := TWBrowse():New(aPos[4,1] + 004, aPos[4,2] + 001, (aPos[4,4] - 130), (aPos[4,3] - aPos[4,1] - 002);
		,,,, oMov140,,,,, { || },,,,,,, .F.,, .T.,, .F.,,,)

	// Array
	For nCont := 1 To Len(aVei)
		oLbVei140:addColumn( TCColumn():New( aVei[nCont,1], &("{ || aVei[" + Str(nCont) + ",3] }"),,,, "LEFT", aVei[nCont,2], .F., .F.,,,, .F.,) )
	Next

	oLbVei140:nAT := 1
	oLbVei140:SetArray(aVei)
	oLbVei140:SetFocus()
	oLbVei140:Refresh()
ElseIf nTip == 1
	// FS_NFCANC()
	// Destruir o objeto
	oLbNFV140 := Nil

	// Criar novamente o objeto Listbox (Informações Chassi)
	oLbNFV140 := TWBrowse():New(aPos[1,1] + 004, aPos[1,2] + 001, (aPos[1,4] - 060), (aPos[1,3] - aPos[1,1] - 002);
		,,,, oNFCan140,,,,, { || },,,,,,, .F.,, .T.,, .F.,,,)

	// Chassi
	oLbNFV140:addColumn( TCColumn():New( "Chassi", &("{ || cPesqV }"),,,, "LEFT", 50, .F., .F.,,,, .F.,) ) // Chassi

	// Array
	For nCont := 1 To Len(aVei)
		oLbNFV140:addColumn( TCColumn():New( aVei[nCont,1], &("{ || aVei[" + Str(nCont) + ",3] }"),,,, "LEFT", aVei[nCont,2], .F., .F.,,,, .F.,) )
	Next

	oLbNFV140:nAT := 1
	oLbNFV140:SetArray(aVei)
	oLbNFV140:SetFocus()
	oLbNFV140:Refresh()
ElseIf nTip == 2
	// FS_BLOQVEI()
	// Destruir o objeto
	oLbBlV140 := Nil

	// Criar novamente o objeto Listbox (Informações Chassi)
	oLbBlV140 := TWBrowse():New(aPos[1,1] + 004, aPos[1,2] + 001, (aPos[1,4] - 060), (aPos[1,3] - aPos[1,1] - 002);
		,,,, oBloq140,,,,, { || },,,,,,, .F.,, .T.,, .F.,,,)

	// Chassi
	oLbBlV140:addColumn( TCColumn():New( "Chassi", &("{ || cPesqV }"),,,, "LEFT", 50, .F., .F.,,,, .F.,) ) // Chassi

	// Array
	For nCont := 1 To Len(aVei)
		oLbBlV140:addColumn( TCColumn():New( aVei[nCont,1], &("{ || aVei[" + Str(nCont) + ",3] }"),,,, "LEFT", aVei[nCont,2], .F., .F.,,,, .F.,) )
	Next

	oLbBlV140:nAT := 1
	oLbBlV140:SetArray(aVei)
	oLbBlV140:SetFocus()
	oLbBlV140:Refresh()
EndIf
Return()
