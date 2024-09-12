#include "Protheus.ch"
#include "OFIXX001.CH"
#Include "TOPCONN.CH"

Static _FG_MARCA_ := nil

Static lFuncOM030GRUSRV := ExistFunc("OM030GRUSRV")

Static lFOM020ArmazemOri:= ExistFunc("OM0200065_ArmazemOrigem")

Static lOFA420021_LevantaRemuneracao := FindFunction("OFA420021_LevantaRemuneracao")

Static lOX001FIS := ExistBlock("OX001FIS")
Static lESTOF110 := ExistBlock("ESTOF110")
Static lOX001SPC := ExistBlock("OX001SPC")
Static lOX001AFP := ExistBlock("OX001AFP")
Static lCHKPRO110 := ExistBlock("CHKPRO110")
Static lOX001VSP := ExistBlock("OX001VSP")

Static _CliRemuneracao_ := {"",.f.}

// MV_MIL0064 => usado para determinar o tipo BackOrder(VEICLSAP) || comentário para simples consulta
Static lVOITPATEN := ExistFunc("FGX_VOITPATEN")

//#define _lConout_ .t.
//#define _lVisDebug_ .f.
//Static aOX001Conout := {}
//Static nConoutColuna := 0

Static SB2Cache := {}
Static SB2CacheTimer := (3 * 60) // Segundos de Cache de Saldo em Estoque

Static tstStatic

Static lVS1PERREM

Static nVS3BICMSB, nVS3CENCUS, nVS3CLVL, nVS3CODINC, nVS3CODITE, nVS3CODTES, nVS3CONTA, nVS3DEPGAR, nVS3DEPINT, nVS3DESINC, nVS3DESITE, nVS3DIFAL, nVS3DOCSDB, nVS3DTVALI, nVS3FORMUL, nVS3GRUINC, nVS3GRUITE, nVS3ICMCAL, nVS3IMPRES, nVS3INSTAL, nVS3ITEMCT, nVS3KEYALT, nVS3LOCAL, nVS3LOCALI, nVS3LOCPRO, nVS3LOTECT, nVS3MARLUC, nVS3MOTPED, nVS3NUMLOT, nVS3OPER, nVS3PECKIT, nVS3PERDES, nVS3PICMSB, nVS3PIPIFB, nVS3PROMOC, nVS3QTD2UM, nVS3QTDAGU, nVS3QTDELI, nVS3QTDEST, nVS3QTDINI, nVS3QTDITE, nVS3QTDPED, nVS3QTDRES, nVS3QTDTRA, nVS3REC_WT, nVS3RESERV, nVS3SEQINC, nVS3SEQUEN, nVS3SITTRI, nVS3VALCMP, nVS3VALCOF, nVS3VALDES, nVS3VALLIQ, nVS3VALPEC, nVS3VALPIS, nVS3VALTOT, nVS3VICMSB, nVS3VIPIFB
Static nVS3BASIRR,nVS3ALIIRR,nVS3VALIRR,nVS3BASCSL,nVS3ALICSL,nVS3VALCSL
Static nVS3SEQVEN, nVS3PESPRO
Static nVS4CODINC, nVS4CODSEC, nVS4CODSER, nVS4DEPGAR, nVS4DEPINT, nVS4DESINC, nVS4DESSER, nVS4GRUINC, nVS4GRUSER, nVS4KILROD, nVS4NOMFOR, nVS4OBSERV, nVS4PERDES, nVS4SEQINC, nVS4SEQSER, nVS4SEQUEN, nVS4TEMPAD, nVS4TIPSER, nVS4VALCUS, nVS4VALDES, nVS4VALHOR, nVS4VALSER, nVS4VALTOT, nVS4VALVEN

Static nVSTCODINC, nVSTDESINC, nVSTGRUINC, nVSTSEQINC

Static nE4FORMVR
Static nVAIDTCDES

Static ITRelCache := {}
Static CacheSBZ := {}
Static CacheTESInt := {}

Static oOficina

//----------------------------------------------------------
// Luis Delorme         : Alterado em 29-04-2010 - 09:05  (INICIO)
// Classe criada para ExecAuto
class AutoGD
data aCols
data nAt
method new()
endclass

method new()  class AutoGD
::aCols:={}
::nAt:=0
return self


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFIXX001   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Orcamento de Pecas e Servicos                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina / AutoPecas                                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXX001(xAutoCab,xAutoPecas, xAutoServ, nOpc, xAutoInco,lLibPv,lAtuTipOrc)
//
Local lDesbloq  := .f.
Local cNOrcBloq := ""
//
Private oXX001TempoProc
//Private oLogger'
Private cIDTempPrepec := ""
//

lVS1PERREM := VS1->(FieldPos("VS1_PERREM")) > 0

Private cMV_VERIORC := Alltrim(GetNewPar("MV_VERIORC","1"))
//
Private cCadastro := STR0001 + "*"
Private aItensKit := {}
Private aPedTransf := {}
Private cGruFor   := "04" 										// Grupo de Formulas que podem ser utilizadas nos orcamentos
Private lVAMCid  		:= GetNewPar("MV_CADCVAM","S") == "S" 	// Utiliza VAM (Cidades)?
Private lRecompra  	:= .F.										// Indica se eh um orcamento para recompra
Private lPassou := .f.											// Tratamento da mudanca de aba na funcao OX001MUDFOL()
Private aIteRel := {{"","","",0,0,"","",""}}					// Vetor contendo os itens relacionados da listbox oLItRel
Private aMemos1   := {{"VS1_OBSMEM","VS1_OBSERV"}}				// Observacao do Orcamento
Private lAbortPrint	:= .f.										// Variavel de Aborto de Operacao
Private lOrcJaRes := .f.
Private dDatOrc := ctod("")
//
Private cApCodMar := ""
Private cApModVei := ""
Private lDupOrc := .f.
Private cApSegMod := ""
Private cApAno := Replicate("0",TamSX3("VE3_ANOMOD")[1])
// Variaveis Fiscais
Private n														// Controle do Fiscal para linha da aCols
Private aNumP := {}		  										// Controle do Fiscal para aCols de Pecas
Private aNumS := {}												// Controle do Fiscal para aCols de Servicos
Private nTotFis := 0											// Numero total de itens do Fiscal (pecas + servicos)
Private bRefresh := { || .t. } 									// Variavel necessaria ao MAFISREF
Private aCodErro := {"",""}										// Variavel de Codigo de Erro na Importacao de OS
Private aItensNImp := {}										// Variavel de retorno de importacao de pecas p/ O.S.
Private lJaPerg := .t. 											// Variavel necessaria ao OFIOC040
Private cFaseOrc 												// Fases do orcamento
Private lInconveniente := (GetNewPar("MV_INCORC","N") == "S")
Private lInconvObr     := (GetNewPar("MV_INCOBR","N") == "S")
Private cIncDefault    := Alltrim(GetNewPar("MV_MIL0094",""))	// SEM INSTALAR
// Variaveis de integracao
Private aAutoCab := {} 											// Cabecalho do Orcamento (VS1)
Private aAutoPecas := {}										// Pecas do Orcamento (VS3)
Private aAutoServ := {}											// Servicos do Orcamento (VS4)
Private aAutoInco := {}											// Inconvenientes do Orcamento
// 'lOX001Auto' indica se todos os vetores de integracao foram preenchidos
Private lOX001Auto := ( xAutoCab <> NIL  .and. xAutoPecas <> NIL .and. xAutoServ <> NIL )
// Variaveis de Controle de tela (OBJETOS)
Private aTitulo := {STR0136,STR0134,STR0135}
Private nFolderI := 1 // Numero da Folder de Inconveniente
Private nFolderP := 2 // Numero da Folder de Pecas
Private nFolderS := 3 // Numero da Folder de Servicos
Private aNewBot := {}
//
Private lPediVenda := .f.
Private lCancParc := .f.
Private lAltPedVda := .f.
Private lPVP := .f.
Private lCancelPVP := .f.
Private lFaturaPVP := .f.
Private nUsadoPX01 := 0
Private oPedido := DMS_Pedido():New()
Private oSqlHlp := DMS_SqlHelper():New()
Private oDpm    := DMS_Dpm():New()
Private aNATrf  := {}
//
Private nMaxItNF  := GetMv("MV_NUMITEN")
Private lAprMsg   := GetNewPar("MV_MIL0151",.T.)
//
Private lMsg0268 := .f. // Controle de Msg de Pedido Gravado
Private cVK_F := {}
//
Default lLibPV := .f.
//
Private aOrc    := {}
Private aSugest := {}
Private aIncBot := {}
//
Private cMsgLotMin := ""

Private cMVMIL0006  := AllTrim(GetNewPar("MV_MIL0006","")) // Marca da Filial
Private cMVMIL0011 := GetNewPar("MV_MIL0011","0") // Utiliza Nível de Atendimento ? (0=Não;1=Sim)
Private cMVMIL0117 := GetNewPar("MV_MIL0117","S") // Atualiza o valor de venda das peças no orçamento por fases automaticamente ao alterar informações da linha do item? (S=Sim ou N=Não)                
Private cMVMIL0026 := GetNewPar("MV_MIL0026","S")
Private lNaForte   := GetNewPar("MV_MIL0132",.F.)
Private cMVFORMALO := GetNewPar("MV_FORMALO","")
Private cMVFMLPECA := GETMV("MV_FMLPECA")
Private cMVLBVACB := GetNewPar("MV_LBVACB","S")

Private lMVMIL0172 := GetNewPar("MV_MIL0172",.F.)

//
if nOpc >= 100 .and. nOpc <= 106
	lPediVenda := .t.
	lAltPedVda := .f.
	if nOpc = 100 // Inclusao
		nOpc := 3
	Elseif nOpc = 104 // Alteração
		nOpc := 4
		lAltPedVda := .t.
		lPVP := .t.
	elseif nOpc = 101  // Cancelamento
	   	lCancelPVP := .t.
		nOpc := 4
	elseif nOpc = 103 // Faturamento
		lFaturaPVP := .t.
		nOpc := 4
	elseif nOpc = 105 // Visualização
		nOpc := 2
		lPVP := .t.
	Elseif nOpc = 106 // Alteração
		nOpc := 4
		lAltPedVda := .t.
	endif
endif

if Type("cAnoOld") == "U"
	Private cAnoOld := ""
Endif
if Type("cModOld") == "U"
	Private cModOld   := space(TamSx3("VV2_DESMOD")[1])
Endif
if Type("cMarcOld") == "U"
	Private cMarcOld  := space(TamSx3("VE1_DESMAR")[1])
Endif

Private lPPrepec := .t.  // Controla se sera executada a funcao OX001PREPEC

/////////////////////////////////////////////////////////////////////////
// lTipOrcAtu - controla se atualiza o VS1_TIPORC na funcao OX001GRV() //
// variavel criada devido a opção do menudef "Liberar Itens com Saldo" //
// esta opção trabalha como se fosse chamada pelo "Pedido" (OFIXA018), //
// porem deve manter o Tipo como Orcamento Oficina (VS1_TIPORC='2')    //
/////////////////////////////////////////////////////////////////////////
Default lAtuTipOrc := .t.
Private lTipOrcAtu := lAtuTipOrc // Default .t.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de  Oficina e Auto Peças        //
/////////////////////////////////////////////////////////////////////////////////////////////////////
if !(FindFunction("FMX_CNPJLB")) .or. !FMX_CNPJLB()
	If !AMIIn(14,41) .or. !FMX_AMIIn({"OFIXA018","OFIXA012","OFIXA011","OFIOA330","OFIXA014","OFIXA016","OFIOC060","OFIOC270","OFIOC470","VEICC500","VEIVC220","VEIVA620","OFIOM350","VEIXA018","VEIXA030","OFIOC500","VEIXA019","OFIOC520","OFIOC526","OFIXC001","MATA030","OFIOC150","OFIOC430"})
	    Return()
	EndIf
endif

if Empty(Alltrim(GetNewPar("MV_FMLPECA","")))
	MsgInfo(STR0240,STR0025)
	return .f.
endif

//
AADD(aNewBot, {"SALVAR",    {|| OX001GRV(nOpc)                      } , STR0002 })
if GetNewPar("MV_MIL0006","") == "JD" .and. ( nOpc == 3 .or. lAltPedVda )
	AADD(aNewBot, {"IMPORT",    {|| OX0010134_ImportaOrcCSV()           } , STR0356 }) //"Imp. CSV John Deere"
endif
if lInconveniente

	AADD( aNewBot , {"AVGBOX1", {|| IIf(ExistBlock("OX001CPC"),ExecBlock("OX001CPC",.f.,.f.,{""}),OFIXC001()) , SETKEY(VK_F6,{|| OX001KEYF6(.f.) } ) , FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt) } , STR0004 })

	AADD( aNewBot , {"INSTRUME",  {|| Processa( {|| OX001INCPR(nOpc) } )  } , STR0169 })
Else
	
	AADD( aNewBot , {"AVGBOX1", {|| IIf(ExistBlock("OX001CPC"),ExecBlock("OX001CPC",.f.,.f.,{""}),OFIXC001()) , SETKEY(VK_F6,{|| OX001KEYF6(.f.) } ) , FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt) } , STR0004 })

Endif
AADD( aNewBot , {"CLIENTE",   {|| OX001CONCLI()                       } , STR0005 })
//AADD( aNewBot , {"analitico", {|| OFIOC570(M->VS1_CLIFAT,M->VS1_LOJA) } , STR0294 }) // Retirado pois rotina nao esta finalizada -> Solicitado pelo Alexandre/Otavio
AADD( aNewBot , {"CRITICA",   {|| OX001REGABO()                       } , STR0006 })
AADD( aNewBot , {"PEDIDO",    {|| OX001REQCPR()                       } , STR0007 })
AADD( aNewBot , {"SOLICITA",  {|| OX001VENPER()                       } , STR0008 })
if ! lPediVenda
	AADD( aNewBot , {"AVGARMAZEM",{|| OX001GSUG(nOpc)                     } , STR0171 }) // Sugestão automatica
	AADD( aNewBot , {"AVGARMAZEM",{|| OXX001CBO("NBO")                     } , STR0326 }) 
Endif
AADD( aNewBot , {"FORM",      {|| OX001AVARES(nOpc)                   } , STR0003 })
AADD( aNewBot , {"COMPTITL",  {|| Processa( {|| OX001RECALC(nOpc) })  } , STR0009 }) // Recalcular
AADD( aNewBot , {"IMPRESSAO", {|| OX001IMPR(nOpc)                     } , STR0010 })
AADD( aNewBot , {"PEDIDO",    {|| OX001PRDIA()                        } , STR0348 })
AADD( aNewBot , {"AVGARMAZEM",{|| OFIOC040(,, .f.)                    } , STR0239 })
AADD( aNewBot , {"MAQFOTO",   {|| OX001KEYF6(.f.)                     } , ("<F6> "+STR0245) })
If lAltPedVda
	AADD( aNewBot , {"BACKORDER", {|| OXX001RBO() }, STR0327    })
	AADD( aNewBot , {"BACKORDER", {|| OXX001CBO("BO") }, STR0328 })
EndIf
// Verificar se a concessionária é da Marca Scania ...
If cMVMIL0006 == "SCA" .AND. ExistFunc("OFICSC01")
	AADD( aNewBot , {"GLOBO", { || OX001CLAW() } , "Claw" })
EndIf
//
DBSelectArea("SX2")
if DBSeek("VD4") .and. !Empty(GetNewPar("MV_GORISC ",""))
	aAdd(aNewBot, {"AVGBOX1", {|| OX001MSCA(nOpc)  }, STR0227 } )
endif

//
If nOpc <> 3
	If VS1->VS1_OPORTU == "1" // Orcamento gerado pela Oportunidade de Oficina
		If VS1->VS1_TIPORC == "P" // Pedido de Orcamento
			AADD( aNewBot , {"PEDIDO", {|| OA1000011_Executar(2,.f.,VS1->VS1_FILIAL,VS1->VS1_NUMORC) } , STR0347 }) // Visualiza Interesses
		ElseIf VS1->VS1_TIPORC == "2" // Orcamento de Oficina
			AADD( aNewBot , {"PEDIDO", {|| OA1100011_Executar(2,.f.,VS1->VS1_FILIAL,VS1->VS1_NUMORC) } , STR0347 }) // Visualiza Interesses
		EndIf
	EndIf
EndIf
// calculo do Peso das Peças do Orçamento
AADD(aNewBot, {"SALVAR",    {|| OX0010062_CalculaPeso()  } , STR0346 }) // "Calcula Peso"

If GetNewPar("MV_MIL0075","0") $ "1/S" // Mostrar Tela ( 1=Sim / 0=Nao )
	AADD(aNewBot, {"SALVAR",    {|| OX0010145_TelaTipoPagamento()  } , STR0362 }) // "Tipo de Pagamento"
EndIf

If FindFunction("OIA410011_Tipos_de_Negocios_do_Cliente")
	AADD(aNewBot, {"CLIENTE", {|| OIA410011_Tipos_de_Negocios_do_Cliente( M->VS1_CLIFAT , M->VS1_LOJA ) } , STR0376 }) // Tipos de Negócios do Cliente
EndIf

If FindFunction("OFIC260")
	If nOpc == 3 .or. nOpc == 4
		AADD(aNewBot, {"PEDIDO", {|| IIf(OX001GRV(nOpc),OFIC260( xFilial("VS1") , M->VS1_NUMORC , 0 ),.t.) } , STR0380 }) // Dados da Negociação do Orçamento Balcão
	Else
		AADD(aNewBot, {"PEDIDO", {|| OFIC260( xFilial("VS1") , M->VS1_NUMORC , 1 ) } , STR0380 }) // Dados da Negociação do Orçamento Balcão
	EndIf
EndIf

If GetNewPar("MV_MIL0181",.f.) .and. VAI->VAI_RESERV == "1" // Reserva Manual ( 1=Sim / 0=Nao )
	AADD(aNewBot, {"SALVAR",    {|| OX0010225_ReservaManual(nOpc)  } , STR0400 }) // "Reserva Manual"
EndIf

If GetNewPar("MV_MIL0037","S") == "N" .and. VS1->VS1_STATUS == "5"
	AADD(aNewBot, {"SALVAR",    {|| OX0010345_AjustaQtdRequisitadaConferida()  } , STR0401 }) // "Revisão da Conferência"
EndIf

//
Private oFnt1 := TFont():New( "System", , 12 )
Private oFnt2 := TFont():New( "Courier New", , 16,.t. )
Private oFnt3 := TFont():New( "Arial", , 14,.t. )

Private lMens := .t.
Private	nCkPerg1 := 1

Private aFatParS := {}     //faturar para

Private OFP8600016  := ExistFunc("OFP8600016_VerificacaoFormula")

If !(nOpc == 2 .or. nOpc == 3) 
	If OX0010115_BloqueiaOrcamento(VS1->VS1_NUMORC)
		Return NIL
	Else
		lDesbloq  := .t.
		cNOrcBloq := VS1->VS1_NUMORC
	EndIf
EndIf

// #############################################################################################
// # Em um orçamento novo a sequencia de fase é coletada da Equipe Técnica;                    #
// # em um já existente a sequencia é coletada diretamente do orçamento (previamente gravado)  #
// #############################################################################################
if nOpc == 3
	cFaseOrc := OI001GETFASE(__cUserId,2)
else
	cFaseOrc := OI001GETFASE(VS1->VS1_NUMORC)
endif
// #########################################################
// # Adiciona botões na EnchoiceBar (aNewBot)              #
// #########################################################
If ( ExistBlock("OXX001ABOT") )  // <<<<---- O B S O L E T O
	aNewBot := ExecBlock("OXX001ABOT",.f.,.f.,{aNewBot})
EndIf
If ( ExistBlock("OX001ABT") )
	aNewBot := ExecBlock("OX001ABT",.f.,.f.,{aNewBot})
EndIf
If ( ExistBlock("OX001OPC") )
	aAdd(aNewBot ,{"E5", {|| ExecBlock("OX001OPC",.f.,.f.,{nOpc})  }, STR0174 } ) // Opc.Avanc.
EndIf

if !FM_PILHA("OFIXA011") .and. !FM_PILHA("OFIXA018") .and. !FM_PILHA("OFIXC009")
	aNewBot := {}
endif


//######################################################################################
//# Se for detectado que trata-se de integracao faz os vetores receberem os parametros #
//######################################################################################
If lOX001Auto
	aAutoPecas := xAutoPecas
	aAutoServ  := xAutoServ
	aAutoCab   := xAutoCab
	aAutoInco  := xAutoInco
EndIf
// #####################################################
// # Na integracao as variaveis abaixo nao existirao,  #
// # por isso precisamos carrega-las manualmente       #
// #####################################################
VISUALIZA := ( nOpc == 2 )
INCLUI 	  := ( nOpc == 3 )
ALTERA 	  := ( nOpc == 4 )
EXCLUI 	  := ( nOpc == 5 )
FECHA  	  := ( nOpc == 6 )
//######################################################################################
//# Disponibiliza botão para ver como pagar na visualizacao                            #
//######################################################################################
if VISUALIZA
	aAdd(aNewBot, {"TABPRICE",	{|| OFIXX004("VS1",nOpc)},	STR0175 })
endif
//######################################################################################
//# Armazena status do orcamento                                                       #
//######################################################################################

IF INCLUI
	cVS1Status := "0"
else
	dDatOrc := VS1->VS1_DATORC
	cVS1Status := VS1->VS1_STATUS
endif
// Se não for inclusao e orcamento de Oficina, verifica se é referente a garantia Mutua
// Se sim e tiver pedido gerado nao pode mais alterar o orcamento ...
IF ALTERA .and. VS1->VS1_TIPORC == "2"
	// Se o status do pedido de garantia estiver Pendente Liberacao ou Liberado, nao é possivel alterar o orcamento
	If OA550STAT( "" , VS1->VS1_NUMORC ) $ "P/L"
		MsgInfo(STR0246 + CHR(13) + CHR(10) + STR0247 ) // "Orçamento com pedido de garantia mutua gerado." "Não é possível alterar o mesmo."
		ALTERA := .F.
		FECHA  := .T.
	EndIf
Endif
// ####################################################################################################
// # Caso a funcao tenha escolhido fechar o orcamento, precisamos saber se eh o caso de uma liberacao #
// # de divergencia ou um simples fechamento de orcamento                                             #
// ####################################################################################################
if FECHA
	if cVS1Status == "5" .or. cVS1Status == "A"	// Se for liberar divergencia deixa alterar (nOpc = 4)
		nOpc := 4
	else					// caso contrario apenas fecha (nOpc = 2 = VISUALIZA)
		nOpc := 2
	endif
endif

//#############################################################################
//# Chama a tela contendo os dados do orcamento                               #
//#############################################################################
DBSelectArea("VS1")
dbClearFilter()
lRet := OX001EXEC(alias(),Recno(),nOpc, lLibPV)
//
If lDesbloq
	UnlockByName( 'OFIXX001_' + cNOrcBloq , .T., .F. )
EndIf

Return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OFIXX001   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Orcamento de Pecas e Servicos                                |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001EXEC(cAlias,nReg,nOpc, lLibPv)
//
Local nCntFor, nPos
// Variáveis de Posicionamento de Tela
Local aObjects 	:= {}
Local aSizeAut	:= MsAdvSize(.t.)
// Variaveis da Enchoice
Local aCpos := {}
Local nModelo := 3
Local cTudoOk := ".t."
Local lF3 := .f.
Local lMemoria := .t.
Local lColumn := .f.
Local cATela := ""
Local lNoFolder := .t.
Local lProperty := .t.
Local cVerFas := GetNewPar("MV_FASEORC","0FX")
Local nPosR := 0
Local nPos4 := 0
Local cMotCanDPM := GetNewPar("MV_MIL0032","000002") // Motivo de Cancelamento DPM
Local lAltFormula := .t.
Local lPEAltCpos  := ExistBlock("OX001ALT")
Local nVS1PERREM  := 0
Local cVS1CONPRO  := "2"
Local dDatRefPD   := dDataBase
Local cPesqPromo  := ""

Local lAgrMsgSld   := .t. // Agrupa mensagem de saldo de estoque ?
Local aProdSdEst   := {}

Private aTempPro  := {}

Private aCpoEncS  := {}
Private aVetCort  := {}
Private aVetCortS := {}

Private nPrxVS3Sequen := 0
Private nPrxVS4Sequen := 0
Private lRelSec := .f. // Exibe relacionamentos Segundarios?

Private lChmPERes := .f.

Private cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Default lLibPv := .f.
//################################################################
//# Especifica o espacamento entre os objetos principais da tela #
//################################################################
// Tela Superior - Enchoice do VS1 - Tamanho vertical fixo
AAdd( aObjects, { 0,	80, .T., .F. } )
// Tela Dois - Folder (Pecas e Servicos) - Tamanho vertical VARIAVEL
AAdd( aObjects, { 0,	40, .T., .T. } )

//################################################################
//# Chama a função que calcula os posicionamentos dos objetos    #
//################################################################
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }	// Tamanho total da tela
aPosObj := MsObjSize( aInfo, aObjects ) 										// Monta objetos conforme especificacoes

//MsgInfo("Inicio do Processo")

nIniProcExec := timeFull()

//####################################
//# Campos de Informacoes adicionais #
//####################################
aOrc := {}
aAdd(aOrc, {'MaFisRet(,"NF_TOTAL") - MaFisRet(,"NF_DESCZF")', STR0338, 0, "VS1->VS1_VTOTNF"}) // Total
//aAdd(aOrc, {'OX001TOTPF("ON")', STR0338, 0, "VS1->VS1_VTOTNF"}) // Total

aAdd(aOrc, {'MaFisRet(,"NF_VALICM")',       STR0339, 0, "VS1->VS1_ICMCAL"}) // ICMS Calculado

aAdd(aOrc, {'MaFisRet(,"NF_VALCMP")',   STR0340, 0, "VS1->VS1_VALCMP"}) // ICMS Complementar
aAdd(aOrc, {'MaFisRet(,"NF_VALSOL")',   STR0341, 0, "VS1->VS1_ICMRET"}) // ICMS Substituição Tributária
aAdd(aOrc, {'OX001TOTPF("ON","DIFAL")', STR0342, 0, "VS1->VS1_DIFAL"})  // Diferença de ICMS

aAdd(aOrc, {'MaFisRet(,"NF_DESCONTO")',     STR0015, 0, "VS1->VS1_VALDES"}) // Desconto
aAdd(aOrc, {'MaFisRet(,"NF_SEGURO")',       STR0343, 0, "VS1->VS1_VALSEG"}) // Seguro
aAdd(aOrc, {'MaFisRet(,"NF_DESPESA")',      STR0344, 0, "VS1->VS1_DESACE"}) // Despesa
aAdd(aOrc, {'MaFisRet(,"NF_FRETE")',        STR0345, 0, "VS1->VS1_VALFRE"}) // Frete

If VS1->VS1_VALIPI > 0
	aAdd(aOrc, {'MaFisRet(,"NF_VALIPI")',   RetTitle("VS1_VALIPI"), 0, "VS1->VS1_VALIPI"}) // Valor do IPI
Endif

aAdd(aOrc, {'MaFisRet(,"NF_VALIRR")', RetTitle("VS1_VALIRR"), 0, "VS1->VS1_VALIRR"}) // Valor IRRF
aAdd(aOrc, {'MaFisRet(,"NF_VALCSL")', RetTitle("VS1_VALCSL"), 0, "VS1->VS1_VALCSL"}) // Valor CSLL

// PONTO DE ENTRADA PARA ALTERACAO DO VETOR aOrc
If ExistBlock("OX001MF1")
	ExecBlock("OX001MF1",.f.,.f.)
EndIf

//######################################
//# VERIFICA FASES DO ORÇAMENTOS       #
//######################################
nPosR := At("R",cVerFas)
nPos4 := At(cFaseConfer,cVerFas)
If (nPosR > 0 .and. nPos4 > 0) .and. nPosR > nPos4
	MsgInfo(STR0312)
	Return .f.
Endif
//###################################################################################
//# Cria aHeader e aCols do Fiscal para efeito de compatibilidade com os MaFis      #
//###################################################################################
aHeader := {}
aAdd(aHeader,{STR0011,"C6_COD","@!",TamSx3("B1_COD")[1],TamSx3("B1_COD")[2],"","","C","TRB",""}) // Artigo
aAdd(aHeader,{STR0012,"C6_QUANT","@!",TamSx3("D2_QUANT")[1],TamSx3("D2_QUANT")[2],"","","N","TRB",""}) // Quantidade
aAdd(aHeader,{STR0013,"C6_PRCVEN","@!",TamSx3("D2_PRCVEN")[1],TamSx3("D2_PRCVEN")[2],"","","N","TRB",""}) // Preço Unit
aAdd(aHeader,{STR0014,"C6_VALMERC","@!",TamSx3("D2_PRCVEN")[1],TamSx3("D2_PRCVEN")[2],"","","N","TRB",""}) // Valor Merc
aAdd(aHeader,{STR0015,"C6_DESCON","@!",TamSx3("D2_DESCON")[1],TamSx3("D2_DESCON")[2],"","","N","TRB",""}) // Desconto
aAdd(aHeader,{STR0016,"C6_CODTES","@!",TamSx3("D2_TES")[1],TamSx3("D2_TES")[2],"","","C","TRB",""}) // TES
aAdd(aHeader,{STR0016,"C6_LOTE","@!",TamSx3("C6_LOTECTL")[1],TamSx3("C6_LOTECTL")[2],"","","C","TRB",""}) // TES
aAdd(aHeader,{STR0016,"C6_DTVALID","@!",TamSx3("C6_DTVALID")[1],TamSx3("C6_DTVALID")[2],"","","D","TRB",""}) // TES
aCols := {}
//###########################################################################
//# Cria variaveis de memória e arrays de configuração  da Enchoice do VS1  #
//###########################################################################

If VAI->VAI_ALTFML == "0" // Usuario NAO pode alterar a Formula
	lAltFormula := .f.
EndIf

nVAIDTCDES := VAI->(FieldPos("VAI_DTCDES"))

If !INCLUI 
	If nVAIDTCDES > 0 // Data para validar a Politica de Desconto
		If VAI->VAI_DTCDES == "1" // Utilizar 1=Data de Inclusão do Orçamento para validar a Politica de Desconto
			dDatRefPD := VS1->VS1_DATORC
		EndIf
	EndIf
EndIf

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS1")
//

nIniProcDic := timeFull()

aCpoEncS  := {} 	// ARRAY DE CAMPOS DA ENCHOICE
aCpos  := {} 		// ARRAY DE CAMPOS DA ENCHOICE NAO EDITAVEIS
// lista de campos não editáveis
cVS1nEdit := "VS1_NUMORC,VS1_CENCUS"
If !lAltFormula // Usuario NAO pode alterar a Formula
	cVS1nEdit += "VS1_FORMUL,"
EndIf
// lista de campos que não serão mostrados
cVS1nMostra := "VS1_FILIAL,VS1_NOMFOR,VS1_CHAINT,VS1_PROVEI,VS1_LOJAPR,VS1_ENDPRO,VS1_CIDPRO,VS1_ESTPRO,VS1_NOMPRO,VS1_MVFASE,"
cVS1nMostra += "VS1_VTOTNF,VS1_VPERDI,VS1_NROAPR,VS1_RETPEC,VS1_AUTENV,VS1_ARMFAB,VS1_TITNCC,VS1_STATUS,VS1_CARTEI,VS1_MOTIVO,"
cVS1nMostra += "VS1_ENDCLI,VS1_CIDCLI,VS1_ESTCLI,VS1_DATORC,VS1_HORORC,VS1_FONCLI,VS1_NOMBCO,VS1_DESCCC,VS1_CODFRO,"
cVS1nMostra += "VS1_DESMAR,VS1_DESMOD,VS1_FABMOD,VS1_DESCOR,VS1_APOLIC,VS1_SINIST,VS1_CODMAR,VS1_VALDES,VS1_ICMCAL,VS1_DESCON,"
cVS1nMostra += "VS1_VALDUP,VS1_BRICMS,VS1_ICMRET,VS1_PEDREF,VS1_ORCACE,VS1_RESLOG,VS1_TRFRES,VS1_VALIRR,VS1_VALCSL,VS1_VALCMP,"
cVS1nMostra += "VS1_DIFAL,VS1_FPGBAS,"
cVS1nMostra += IIF(VAI->VAI_RESERV != "1", "VS1_RESERV,","")
//
If ExistBlock("OX001NME")
	ExecBlock("OX001NME",.f.,.f.)
EndIf
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
// Variavel interna para funcionamento correto dos campos MEMOS na Visualizacao por outras Rotinas //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If nOpc == 2 .and. FunName() != "OFIXA011" // Necessario utilizar a funcao FUNNAME (chamada no MENU)
	SetStartMod(.t.)
Endif
//
if lPediVenda
	cVS1nMostra += "VS1_TIPORC,"
endif
//
M->VS1_RESERV := "0"
//
lSX3Processar := .t.
If ! ExistBlock("OX001NME") 
	If lPediVenda .and. Type("aVS1_P_EncS") == "A" .and. Len(aVS1_P_EncS) > 0
		lSX3Processar := .f.
		aVS1_AtuVar := aVS1_P_SX3
		acpoEncS := aClone(aVS1_P_EncS)
		if FECHA .and. cVS1Status == "F"
			aCpos := aClone(aVS1_P_FechaCpos)
		else
			aCpos := aClone(aVS1_P_Cpos)
		Endif
	ElseIf ! lPediVenda .and. Type("aVS1_EncS") == "A" .and. Len(aVS1_EncS) > 0
		lSX3Processar := .f.
		aVS1_AtuVar := aVS1_SX3
		acpoEncS := aClone(aVS1_EncS)
		if FECHA .and. cVS1Status == "F"
			aCpos := aClone(aVS1_FechaCpos)
		else
			aCpos := aClone(aVS1_Cpos)
		Endif
	EndIf
	If ! lSX3Processar
		For nPos := 1 to Len(aVS1_AtuVar)
			cAuxCampo := AllTrim(aVS1_AtuVar[nPos])
			If Inclui .and.  Alltrim(cAuxCampo)!= "VS1_NUMORC"
				&("M->"+cAuxCampo):= CriaVar(cAuxCampo)
			Else
				If GetSX3Cache(cAuxCampo, "X3_CONTEXT") == "V"
					&("M->"+cAuxCampo):= CriaVar(cAuxCampo)
				Else
					&("M->"+cAuxCampo):= &("VS1->"+cAuxCampo)
				EndIf
			EndIf
		Next
	EndIf
EndIf
If lSX3Processar
	If lPediVenda
		If Type("aVS1_P_SX3") == "A"
			aSize(aVS1_P_SX3, 0)
			aSize(aVS1_P_EncS, 0)
			aSize(aVS1_P_Cpos, 0)
			aSize(aVS1_P_FechaCpos, 0)
		Else
			aVS1_P_SX3 := {}
			aVS1_P_EncS := {}
			aVS1_P_Cpos := {}
			aVS1_P_FechaCpos := {}
		EndIf
	Else
		If Type("aVS1_SX3") == "A"
			aSize(aVS1_SX3, 0)
			aSize(aVS1_EncS, 0)
			aSize(aVS1_Cpos, 0)
			aSize(aVS1_FechaCpos, 0)
		Else
			aVS1_SX3 := {}
			aVS1_EncS := {}
			aVS1_Cpos := {}
			aVS1_FechaCpos := {}
		EndIf
	EndIf

	While !Eof().and.(x3_arquivo=="VS1")
		// Monta o array com os campos que aparecerão na Enchoice
		If X3USO(x3_usado).and.cNivel>=x3_nivel .and. !(Alltrim(x3_campo)+"," $ cVS1nMostra)
			AADD(acpoEncS,x3_campo)
			If lPediVenda
				AADD(aVS1_P_EncS,x3_campo)
			Else
				AADD(aVS1_EncS,x3_campo)
			EndIf
		EndIf

		// Monta as variáveis de memória de TODOS os campos
		If Inclui .and.  Alltrim(x3_campo)!= "VS1_NUMORC"
			&("M->"+x3_campo):= CriaVar(x3_campo)
		Else
			If x3_context == "V"
				&("M->"+x3_campo):= CriaVar(x3_campo)
			Else
				&("M->"+x3_campo):= &("VS1->"+x3_campo)
			EndIf
		EndIf
		//

		If lPediVenda
			AADD(aVS1_P_SX3,x3_campo)
		Else
			AADD(aVS1_SX3,x3_campo)
		EndIf

		// Monta o array com os campos não editáveis
		If ( (x3_context != "V" .OR. (x3_context == "V" .AND. X3_VISUAL == "A"))  .or. x3_campo $ "VS1_GETKEY,VS1_OBSERV")
			if !(Alltrim(x3_campo) $ cVS1nEdit) .and.  !(Alltrim(x3_campo)+"," $ cVS1nMostra)
				if FECHA .and. cVS1Status == "F"

					if Alltrim(x3_campo)+"," $ "VS1_MENNOT,VS1_MENPAD,VS1_KILOME,VS1_VEICUL,VS1_TRANSP,VS1_VOLUM1,VS1_VOLUM2,VS1_VOLUM3,VS1_VOLUM4,VS1_ESPEC1,VS1_ESPEC2,VS1_ESPEC3,VS1_ESPEC4,VS1_PESOL,VS1_PESOB,VS1_USUENT,VS1_NATURE,VS1_OBSERV,"
						aAdd(aCpos,X3_CAMPO)

						If lPediVenda
							AADD(aVS1_P_FechaCpos,x3_campo)
						Else
							AADD(aVS1_FechaCpos,x3_campo)
						EndIf

					endif
				else
					aAdd(aCpos,X3_CAMPO)

					If lPediVenda
						AADD(aVS1_P_Cpos,x3_campo)
					Else
						AADD(aVS1_Cpos,x3_campo)
					EndIf
				endif

			endif
		endif
		DbSkip()
	Enddo
EndIf
//
//
// Reposicionamento na SA1 por causa do Posicionamento no Proprietário do Veículo
DbSelectArea("SA1")
DbSetOrder(1)
MsSeek(xFilial("SA1")+M->VS1_CLIFAT+M->VS1_LOJA)

DBSelectArea("VAI")
DBSetOrder(4)
MsSeek(xFilial("VAI")+__cUserId)

// No momento da inclusão deve-se apagar qualquer referência
// de memória que não tenha sido avaliada na montagem acima.
if INCLUI
	M->VS1_NUMORC := ""
	M->VS1_CENCUS := VAI->VAI_CC
else
	lOrcJaRes := (M->VS1_RESERV == "1")
	if !Empty(M->VS1_CHASSI)
		M->VS1_GETKEY := M->VS1_CHASSI
	Endif
endif

//#########################################################################
//# Cria variaveis de memoria, aHeader e aCols da GetDados de Pecas (VS3) #
//#########################################################################
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS3")
//
// lista de campos não editáveis
cVS3nEdit := "VS3_CODINC,VS3_GRUINC,VS3_DESINC,VS3_SEQINC,VS3_SEQUEN,VS3_QTDAGU,VS3_QTDRES,VS3_QTDTRA,VS3_VICMSB,VS3_PICMSB,VS3_MOTPED,"
If !lAltFormula // Usuario NAO pode alterar a Formula
	cVS3nEdit += "VS3_FORMUL,"
EndIf
// lista de campos que não serão mostrados
cVS3nMostra := "VS3_FILIAL,VS3_NUMORC,VS3_ARMORI,VS3_MODVEI,VS3_VBAICM,VS3_ALIICM," // VS3_ICMCAL,"
cVS3nMostra += "VS3_GRUKIT,VS3_CODKIT,VS3_NOTFAB,VS3_CONBAR,VS3_DTNFFB,VS3_PIPIFB,VS3_VIPIFB,"
cVS3nMostra += "VS3_PICMFB,VS3_VICMFB,VS3_NUMIDE,VS3_ITESUB,VS3_BASPIS,VS3_BASCOF," // VS3_VALPIS,VS3_VALCOF,"
cVS3nMostra += "VS3_ALQPIS,VS3_ALQCOF,VS3_TESENT,VS3_QESTNA,VS3_SQCONF,VS3_QE,"
If GetNewPar("MV_MIL0093","0") <> "1" // Quando nao trabalhar com servicos automaticos, nao mostrar o campo de Instalacao de Peça
	cVS3nMostra += "VS3_INSTAL,"
EndIf


// --------------------------------------------------------------------
// O trecho abaixo controla a aparição de campos dependentes de fatores
// --------------------------------------------------------------------
// Fator 1: Depois da fase de liberação de divergência os campos com as quantidades deverão aparecer

nPosA := At(cVS1Status,cFaseOrc)
nPos5 := At("5",cFaseOrc)

if !lPediVenda
	cVS3nMostra += "VS3_QTDPED,VS3_QTDELI,"
	cVS3nEdit += "VS3_QTDCON,VS3_QTDINI,"
	if nPos4 <= 0 .and. nPos5 <= 0
		cVS3nMostra += "VS3_QTDCON,VS3_QTDINI,"
	endif
//else // Para Atender a MaqNelson, vai mostrar a QTDEST quando já houver sido gravado o Nivel de Atendimento
//	cVS3nMostra += "VS3_QTDEST,"
endif
// Fator 2: Na fase de liberação de margem de lucro, deve-se mostrar a quantidade liberada (liberação parcial)
if VS1->VS1_STATUS != "2"
	cVS3nMostra += "VS3_QTDLIB,"
endif
// Fator 3: A existência de inconveniente deve mostrar os campos necessários
if !lInconveniente
	cVS3nMostra += "VS3_CODINC,VS3_GRUINC,VS3_DESINC,VS3_SEQINC,"
endif
If ExistBlock("OX001AHP")
	cVS3nMostra := ExecBlock("OX001AHP",.f.,.f.,{ cVS3nMostra })
EndIf
//

cVS3nEdit += "VS3_QTDINI,"

// Cria Variaveis de Memoria e aHeader
aHeaderP:= {}
aAlterP := {}
aHeaderPObrigat := {}
aAuxStruVS3 := FWFormStruct(3, "VS3")[3]
//
While !Eof().And.(x3_arquivo=="VS3")
	If  X3USO(x3_usado) .and. !(Alltrim(x3_campo)+"," $ cVS3nMostra) .And. ( cNivel>=x3_nivel .or. IIF(cNivel < x3_nivel .and. Alltrim(x3_campo) == "VS3_MARLUC",.t.,.f.) )

		nUsadoPX01:=nUsadoPX01+1

		Aadd(aHeaderP,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,X3CBOX(),SX3->X3_RELACAO})

		aadd(aHeaderPObrigat, X3Obrigat(SX3->X3_CAMPO) )
		
		if x3_usado != "V" .and. (INCLUI .or. ALTERA)
			if !((cVS1Status == "5" .or. cVS1Status == "A") .and. FECHA) .and. !lFaturaPVP .and.  !lCancelPVP
				if !(Alltrim(x3_campo)+"," $ cVS3nEdit)
					aAdd(aAlterP,x3_campo)
				endif
			endif
		endif
		If (Alltrim(x3_campo) == "VS3_MARLUC" .and. cNivel < x3_nivel)
			aHeaderP[Len(aHeaderP),3] := repl("*",TamSx3("VS3_MARLUC")[1])
		Endif
	EndIf
	
	DbSkip()
EndDo

nPosLote        := aScan(aHeaderP,{|x| AllTrim(x[2])=="VS3_NUMLOT"})
nPosLotCtl      := aScan(aHeaderP,{|x| AllTrim(x[2])=="VS3_LOTECT"})
nPosDValid      := aScan(aHeaderP,{|x| AllTrim(x[2])=="VS3_DTVALI"})

// RecNo e Alias
ADHeadRec("VS3", aHeaderP)
nUsadoPX01 := nUsadoPX01 + 2

OX0010123_FGPosVar_VS3()

//############################################################################
//# Cria variaveis de memoria, aHeader e aCols da GetDados de Servicos (VS4) #
//############################################################################
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS4")
// lista de campos não editáveis
cVS4nEdit := "VS4_CODINC,VS4_GRUINC,VS4_DESINC,VS4_SEQINC,VS4_SEQUEN,"
// lista de campos que não serão mostrados
cVS4nMostra := "VS4_FILIAL,VS4_NUMORC,"
//
nUsadoS:=0
// --------------------------------------------------------------------
// O trecho abaixo controla a aparição de campos dependentes de fatores
// --------------------------------------------------------------------
// Fator 1: A existência de inconveniente deve mostrar os campos necessários
if !lInconveniente
	cVS4nMostra += "VS4_CODINC,VS4_GRUINC,VS4_DESINC,VS4_SEQINC,"
endif
If ExistBlock("OX001AHS")
	cVS4nMostra := ExecBlock("OX001AHS",.f.,.f.,{ cVS4nMostra })
EndIf
//
// Cria Variaveis de Memoria e aHeader
aHeaderS:={}
aAlterS :={}
//
While !Eof().And.(x3_arquivo=="VS4")
	If  X3USO(x3_usado) .And. cNivel>=x3_nivel .and. !(Alltrim(x3_campo)+"," $ cVS4nMostra)
		nUsadoS:=nUsadoS+1

		Aadd(aHeaderS,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,X3CBOX(),SX3->X3_RELACAO})

		if x3_usado != "V" .and. (INCLUI .or. ALTERA)
			if !(cVS1Status == "5" .and. FECHA) // .and. !(Alltrim(x3_campo)+"," $ cVS1nMostra)
				if !(Alltrim(x3_campo)+"," $ cVS4nEdit)
					aAdd(aAlterS,X3_CAMPO)
				endif
			endif
		endif
	EndIf
	DbSkip()
EndDo

OX0010133_FGPosVar_VS4()

// Se for o caso de liberaco de divergencia, apenas o VS3_QTDITE estara liberado
if (cVS1Status == "5" .and. FECHA) .or. lFaturaPVP
	aAdd(aAlterP,"VS3_QTDITE")
endif
//
If !INCLUI // deve-se montar a acols com os registros da base
	aColsP:={}

	nVS3_MARLUC := nVS3MARLUC

	DbSelectArea("SA1")
	DbSetOrder(1)
	MsSeek(xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA)

	If lVS1PERREM
		nVS1PERREM := VS1->VS1_PERREM
		cVS1CONPRO := VS1->VS1_CONPRO
	EndIf

	dbSelectArea("VS3")
	dbSetOrder(1)
	dbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
	While !eof() .and. VS3->VS3_FILIAL == xFilial("VS3").and. VS3->VS3_NUMORC == VS1->VS1_NUMORC

		If nVS3_MARLUC == 0
			SF4->(MsSeek(xFilial("SF4")+VS3->VS3_CODTES))
			If SF4->F4_OPEMOV == "05" .and. ALTERA
				SBM->(MsSeek(xFilial("SBM")+VS3->VS3_GRUITE))

				cPesqPromo := cVS1CONPRO
				If cPesqPromo <> "0" .and. nVS3PESPRO > 0 .and. VS3->VS3_PESPRO == "0"
					cPesqPromo := "0"
				EndIf

				SB1->( dbSetOrder(7) )
				SB1->( dbSeek( xFilial("SB1") + VS3->VS3_GRUITE + VS3->VS3_CODITE ) )
				SB1->( dbSetOrder(1) )

				SB2->( dbSetOrder(1) )
				SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + VS3->VS3_LOCAL ) )

				aTempPro := OX005PERDES(;
					SBM->BM_CODMAR,;                                  // cMarca
					VS1->VS1_CENCUS,;                                 // cCenRes
					VS3->VS3_GRUITE,;                                 // cGrupo
					VS3->VS3_CODITE,;                                 // cCodite
					VS3->VS3_QTDITE,;                                 // nQtd
					VS3->VS3_PERDES,;                                 // nPercent
					.f.,;                                             // lHlp
					VS1->VS1_CLIFAT,;                                 // cCliente
					VS1->VS1_LOJA,;                                   // cLoja
					IIF(VS1->VS1_TIPORC == "2","3",VS1->VS1_TIPVEN),; // cTipVen
					VS3->VS3_VALTOT/VS3->VS3_QTDITE,;                 // nValUni
					2,;                                               // nTipoRet
					VS1->VS1_FORPAG,;                                 // cForPag
					,;                                                // cFormAlu
					,;                                                // lFechOfi
					.t.,;                                             // lConMrgLuc
					cPesqPromo,;                                      // cConPromoc
					dDatRefPD,;                                       // dDatRefPD
					nVS1PERREM)                                       // nPERREM

				reclock("VS3",.f.)
				//nMarLucAnt := VS3->VS3_MARLUC
				if aTempPro[2] > 9999.99
					VS3->VS3_MARLUC := 9999.99
				elseif aTempPro[2] < -9999.99
					VS3->VS3_MARLUC := -9999.99
				else
					VS3->VS3_MARLUC := aTempPro[2]
				endif
				msunlock()
			endif
		endif

		if lCancelPVP .or. lFaturaPVP  // .or. lPVP
			if VS3->VS3_QTDPED == 0
				DBSkip()
				loop
			endif
		endif
		if lPVP
			if VS3->VS3_QTDINI == 0
				DBSkip()
				loop
			endif
		endif

		AADD(aColsP,Array(nUsadoPX01+1))
		For nCntFor:=1 to nUsadoPX01
			do case
			case aHeaderP[nCntFor,2] =="VS3_QTDEST"
				SB1->(DBSetOrder(7))
				SB1->(DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
				aColsP[Len(aColsP),nCntFor] := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+VS3->VS3_LOCAL, .t.)
			case IsHeadRec(aHeaderP[nCntFor,2])
				aColsP[Len(aColsP),nCntFor] := VS3->(RecNo())
			case IsHeadAlias(aHeaderP[nCntFor,2])
				aColsP[Len(aColsP),nCntFor] := "VS3"
			case aHeaderP[nCntFor,10] == "V"
				if ! empty(aHeaderP[nCntFor,12])
					aColsP[Len(aColsP),nCntFor] := &(aHeaderP[nCntFor,12])
				else
					aColsP[Len(aColsP),nCntFor] := IIf( aHeaderP[nCntFor,8] == "C" , space(aHeaderP[nCntFor,4]) , 0 )
				endif
			Otherwise
				aColsP[Len(aColsP),nCntFor] := FieldGet(ColumnPos(aHeaderP[nCntFor,2]))
			endcase
		Next

		// "Deleta" linha para pedido 
		If !Empty(VS3->VS3_MOTPED) .and. !(VS3->VS3_MOTPED $ cMotCanDPM)
			aColsP[Len(aColsP),nUsadoPX01+1]:=.T.
		Else
			aColsP[Len(aColsP),nUsadoPX01+1]:=.F.
		Endif

		If Val(VS3->VS3_SEQUEN) > nPrxVS3Sequen
			nPrxVS3Sequen := Val(VS3->VS3_SEQUEN)
		EndIf

		DbSkip()
	EndDo
EndIf
// Cria aCols : Na inclusão cria-se uma linha em branco com os inicializadores padrão...
If INCLUI .or. Len(aColsP) == 0
	aColsP := { Array(nUsadoPX01 + 1) }
	aColsP[1,nUsadoPX01+1] := .F.
	For nCntFor:=1 to nUsadoPX01
		If IsHeadRec(aHeaderP[nCntFor,2])
			aColsP[1,nCntFor] := 0
		ElseIf IsHeadAlias(aHeaderP[nCntFor,2])
			aColsP[1,nCntFor] := "VS3"
		Else
			aColsP[1,nCntFor] := CriaVar(aHeaderP[nCntFor,2])
		EndIf
	Next
Endif

If !INCLUI // deve-se montar a acols com os registros da base
	aColsS:={}
	dbSelectArea("VS4")
	dbSetOrder(1)
	dbSeek(xFilial("VS4")+VS1->VS1_NUMORC)
	While !eof() .and. VS4->VS4_FILIAL == xFilial("VS4") .and. VS4->VS4_NUMORC == VS1->VS1_NUMORC
		AADD(aColsS,Array(nUsadoS+1))
		For nCntFor:=1 to nUsadoS
			if aHeaderS[nCntFor,10] == "V"
				//SX3->(DBSetOrder(2))
				//SX3->(DBSeek(aHeaderS[nCntFor,2]))
				//aColsS[Len(aColsS),nCntFor] := &(sx3->x3_relacao)
				aColsS[Len(aColsS),nCntFor] := &(aHeaderS[nCntFor,12])
			else
				aColsS[Len(aColsS),nCntFor] := FieldGet(ColumnPos(aHeaderS[nCntFor,2]))
			endif
		Next
		aColsS[Len(aColsS),nUsadoS+1]:=.F.

		If Val(VS4->VS4_SEQUEN) > nPrxVS4Sequen
			nPrxVS4Sequen := Val(VS4->VS4_SEQUEN)
		EndIf

		DbSkip()
	EndDo
EndIf
// Cria aCols : Na inclusão cria-se uma linha em branco com os inicializadores padrão...
If INCLUI .or. Len(aColsS) == 0
	aColsS := { Array(nUsadoS+1) }
	aColsS[1,nUsadoS+1] := .F.
	For nCntFor:=1 to nUsadoS
		aColsS[1,nCntFor]:=CriaVar(aHeaderS[nCntFor,2])
	Next
Endif

//##################################################################################
//# Cria variaveis de memoria, aHeader e aCols da GetDados de Inconvenientes (VST) #
//##################################################################################
if lInconveniente
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("VST")
	// cria lista de campos não editáveis
	cVSTnEdit := "VST_FILIAL,VST_SEQINC,VST_GRUINC,VST_CODINC,"
	// lista de campos que não serão mostrados
	cVSTnMostra := "VST_FILIAL,VST_TIPO,VST_CODIGO,VST_EXPPEC,VST_EXPSRV,VST_CODMAR,VST_CHASSI,"
	//
	nUsadoI:=0
	// Cria Variaveis de Memoria e aHeader
	aHeaderI:={}
	aAlterI :={}
	//
	While !Eof().And.(x3_arquivo=="VST")
		If X3USO(x3_usado) .And. cNivel>=x3_nivel .and. !(Alltrim(x3_campo)+"," $ cVSTnMostra)
			nUsadoI++

			Aadd(aHeaderI,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,X3CBOX(),SX3->X3_RELACAO,".T."})

			if x3_usado != "V" .and. (INCLUI .or. ALTERA)
				if !(cVS1Status == "5" .and. FECHA)
					if !(Alltrim(x3_campo)+"," $ cVSTnEdit)
						aAdd(aAlterI,X3_CAMPO)
					endif
				endif
			endif
		EndIf
		DbSkip()
	EndDo

	OX0010143_FGPosVar_VST()

	// Cria aCols : Na inclusão cria-se uma linha em branco com os inicializadores padrão...
	If INCLUI
		aColsI := { Array(nUsadoI+1) }
		aColsI[1,nUsadoI+1] := .F.
		For nCntFor:=1 to nUsadoI
			aColsI[1,nCntFor]:=CriaVar(aHeaderI[nCntFor,2])
		Next

	Else // ... caso contrário deve-se montar a acols com os registros da base
		aColsI:={}
		dbSelectArea("VST")
		dbSetOrder(1)
		dbSeek(xFilial("VST")+"1"+VS1->VS1_NUMORC)
		While !eof() .and. VST->VST_FILIAL == xFilial("VST") .and. VST->VST_TIPO == "1" .and. VST->VST_CODIGO == VS1->VS1_NUMORC
			AADD(aColsI,Array(nUsadoI+1))
			For nCntFor:=1 to nUsadoI
				if aHeaderI[nCntFor,10] == "V"
					//SX3->(DBSetOrder(2))
					//SX3->(DBSeek(aHeaderI[nCntFor,2]))
					aColsI[Len(aColsI),nCntFor] := &(aHeaderI[nCntFor,12])
				else
					aColsI[Len(aColsI),nCntFor] := FieldGet(ColumnPos(aHeaderI[nCntFor,2]))
				endif
			Next
			aColsI[Len(aColsI),nUsadoI+1]:=.F.
			DbSkip()
		EndDo

		If VS1->VS1_TIPORC == "2" .and. !Empty(cIncDefault) // Orcamento de Oficina e possui Inconveniente Default
			nPosInc := aScan(aColsI,{|x| FwNoAccent(Alltrim(x[FG_POSVAR("VST_DESINC","aHeaderI")])) == FwNoAccent(cIncDefault) }) // SEM INSTALAR - MV_MIL0094
	  		If nPosInc <= 0
				aAdd(aColsI,Array(nUsadoI+1))
				nPosInc := Len(aColsI)
				aColsI[nPosInc,nUsadoI+1] := .F.
				For nCntFor:=1 to nUsadoI
					aColsI[nPosInc,nCntFor]:=CriaVar(aHeaderI[nCntFor,2])
				Next
				aColsI[nPosInc,FG_POSVAR("VST_SEQINC","aHeaderI")] := OM420NUMSEQ( "1" , VS1->VS1_NUMORC )
				aColsI[nPosInc,FG_POSVAR("VST_DESINC","aHeaderI")] := cIncDefault // SEM INSTALAR - MV_MIL0094
			EndIf
			For nCntFor := 1 to len(aColsP)
				If Empty(aColsP[nCntFor,nVS3GRUINC]+aColsP[nCntFor,nVS3CODINC]+aColsP[nCntFor,nVS3DESINC]) // Descricao do Incoveniente
					aColsP[nCntFor,nVS3SEQINC] := aColsI[nPosInc,FG_POSVAR("VST_SEQINC","aHeaderI")] // Sequencia
					aColsP[nCntFor,nVS3DESINC] := aColsI[nPosInc,FG_POSVAR("VST_DESINC","aHeaderI")] // SEM INSTALACAO
			    EndIf
			Next
        EndIf
	EndIf
EndIf


//#############################################
//# Zera qualquer montagem previa do fiscal   #
//#############################################
If MaFisFound("NF")
	MaFisEnd()
EndIf
//##########################################################################################################
//# Se for alteracao ou fechamento, a sequencia abaixo deve inicializar o fiscal com as informacoes do VS1 #
//##########################################################################################################
//
lRet := .t.
//
//####################################################
//# ROTINA AUTOMÁTICA: Não monta tela                #
//####################################################
If !lOX001Auto


	//####################################################
	//# Montagem da tela do orcamento                    #
	//####################################################
	// Funcoes de Tecla
	SETKEY(VK_F4,{|| OX001KEYF4() })
	SETKEY(VK_F5,{|| OX001REQCPR() })
	SETKEY(VK_F6,{|| OX001KEYF6() })
    SETKEY(VK_F7,{|| OFIXC001() })

	If ExistBlock("OX001F8")
		SETKEY(VK_F8,{|| ExecBlock("OX001F8",.f.,.f.,{ M->VS1_NUMORC , M->VS3_GRUITE , M->VS3_CODITE }) })
	EndIf
	If ExistBlock("OX001F9")
		SETKEY(VK_F9,{|| ExecBlock("OX001F9",.f.,.f.,{ M->VS1_NUMORC , M->VS3_GRUITE , M->VS3_CODITE }) })
	EndIf
	If GetNewPar("MV_MIL0075","0") $ "1/S" // Mostrar Tela ( 1=Sim / 0=Nao )
		SETKEY(VK_F10,{|| OX0010145_TelaTipoPagamento() } )
	EndIf
	// Funcoes de controle de eventos das getdados de pecas e servicos
	// Verifica a linha inteira da aCols (chamada na troca entre as linhas)
	cLinOkP        :="OX001LINPOK()"
	cLinOkS        :="OX001LINSOK()"
	// Verifica cada um dos campos da aCols (chamada na troca de foco entre os campos)
	cFieldOkP      :="OX001FPOK()"
	cFieldOkS      :="OX001FSOK()"
	// verifica toda a acols
	cTudoOkP		  := "OX001TUDOK()"
	cTudoOkS		  := "OX001TUDOK()"
	// Validacao das aCols
	cDelPecOk := "OX001DPOK"
	cDelSerOk := "OX001DSOK"
	//#####################################################
	//# Define a tela do orcamento de pecas e servicos    #
	//#####################################################
	oDlgXX001 := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,128,,,,,.t.)
	oDlgXX001:lEscClose := .F.
	//
	RegToMemory("VS3",IIF(nopc==3,.t.,.f.))
	RegToMemory("VS4",IIF(nopc==3,.t.,.f.))
	//#####################################################
	//# Monta a enchoice do VS1 com os campos necessarios #
	//#####################################################
	aPosEnchoice := aClone(aPosObj[1])
	aPosEnchoice[4] := INT(aPosEnchoice[4]*0.7)
	oEnch := MSMGet():New( ;
		cAlias ,;
		nReg,;
		IIF( (( ( cVS1Status == "5" .or. cVS1Status == "A" ) .and. FECHA ) .or. ( lPediVenda .and. (nOpc != 3 .and. nOpc != 4) )) , 2 , ;
			 IIF( ( cVS1Status $ "F/G" .and. FECHA ) .or. ( ! Empty(VS1->VS1_PEDREF) .and. FECHA ) , 3 , nOpc ) ),;
		,,,;
		aCpoEncS,;
		aPosEnchoice,;
		aCpos,;
		nModelo,;
		,;
		,;
		cTudoOk,;
		oDlgXX001,;
		lF3,;
		lMemoria,;
		lColumn,;
		caTela,;
		lNoFolder,;
		lProperty)
	//#############################################################################
	//# Folder das GetDados                                                       #
	//#############################################################################
	oFoldX001 := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitulo,{},;
	oDlgXX001,,,,.t.,.f.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
	oFoldX001:bSetOption := { |x| OX001MUDFOL(oFoldX001:nOption , x) } // Executa na mudanca da aba
	
	oTPanP1 := TPanel():New(0,0,"",oFoldX001:aDialogs[nFolderP],NIL,.T.,.F.,NIL,NIL,100,100,.T.,.F.)
	oTPanP1:Align := CONTROL_ALIGN_ALLCLIENT

	oTPanP2 := TPanel():New(0,0,"",oFoldX001:aDialogs[nFolderP],NIL,.T.,.F.,NIL,NIL,100,50,.T.,.F.)
	oTPanP2:Align := CONTROL_ALIGN_BOTTOM

	oTPanP3 := TPanel():New(0,0,"",oFoldX001:aDialogs[nFolderP],NIL,.T.,.F.,NIL,NIL,100,10,.T.,.F.)
	oTPanP3:Align := CONTROL_ALIGN_BOTTOM 

	oGetPecas := MsNewGetDados():New(0, 0, 100 ,100,3,cLinOKP,cTudoOkP,,aAlterP,0,999,cFieldOkP,,cDelPecOk,oTPanP1,aHeaderP,aColsP )
	If nOpc <> 2 .and. nOpc <> 5
		oGetPecas:oBrowse:bDelete := {|| FS_QTDLIN("0") .and. OX001DELP()}
	EndIf
	oGetPecas:oBrowse:bChange := {|| FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt) , OX001ITEREL(),FS_REPDEP() , OX0010181_CamposAlterarLinha( lPEAltCpos , 1 , aAlterP ) }
	oGetPecas:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT

	//#############################################################################
	//# GetDados de Servicos                                                      #
	//#############################################################################

	oTPanS1 := TPanel():New(0,0,"",oFoldX001:aDialogs[nFolderS],NIL,.T.,.F.,NIL,NIL,100,100,.T.,.F.)
	oTPanS1:Align := CONTROL_ALIGN_ALLCLIENT

	oGetServ := MsNewGetDados():New(0, 0, 100 ,100,3,cLinOKS,cTudoOkS,,aAlterS,0,999,cFieldOkS,,cDelSerOk,oTPanS1,aHeaderS,aColsS )
	If nOpc <> 2 .and. nOpc <> 5
		oGetServ:oBrowse:bDelete := {|| OX001DELS() }
	Endif
	oGetServ:oBrowse:bChange := {|| FG_MEMVAR(oGetServ:aHeader,oGetServ:aCols,oGetServ:nAt),FS_REPSEC() , OX0010181_CamposAlterarLinha( lPEAltCpos , 2 , aAlterS ) }
	oGetServ:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT

	//#############################################################################
	//# Cabeçalho e GetDados de Inconveniente                                     #
	//#############################################################################
	if lInconveniente
		// Funcoes de controle de eventos das getdados de pecas e servicos
		// Verifica a linha inteira da aCols (chamada na troca entre as linhas)
		cLinOkI		:= "AllwaysTrue()"
		// Verifica cada um dos campos da aCols (chamada na troca de foco entre os campos)
		cFieldOkI   := "AllwaysTrue()"
		// verifica toda a acols
		cTudoOkI		:= "AllwaysTrue()"
		// Validacao das aCols
		cDelIncOk	:= "AllwaysTrue()"
		//
		cGruInc := space(TamSX3("VST_GRUINC")[1])
		cCodInc := space(TamSX3("VST_CODINC")[1])
		cDesInc := space(TamSX3("VST_DESINC")[1])
		oSay01 := TSay():New(04, 02, {|| AllTrim(aHeaderI[FG_POSVAR("VST_GRUINC","aHeaderI"),1]) },oFoldX001:aDialogs[nFolderI],,oFnt3,,,,.t.,,,40,8)
		@ 03,40 MSGET oGruInc VAR cGruInc F3 "VSK" VALID (Vazio() .or. OX001INC(M->VS1_CODMAR,cGruInc))  PICTURE "@!" SIZE 30,8 PIXEL OF oFoldX001:aDialogs[nFolderI] WHEN ((INCLUI .OR. ALTERA) .AND. !Empty(M->VS1_CHASSI) .AND. M->VS1_TIPORC == "2" .AND. Empty(cDesInc)) HASBUTTON
		//
		oSay01 := TSay():New(04, 80, {|| AllTrim(aHeaderI[FG_POSVAR("VST_CODINC","aHeaderI"),1]) },oFoldX001:aDialogs[nFolderI],,oFnt3,,,,.t.,,,50,8)
		@ 03,115 MSGET oCodInc VAR cCodInc F3 "VSL" VALID OX001INCON(nOpc,cGruInc,cCodInc,cDesInc,"C") PICTURE "@!" SIZE 50,8 PIXEL OF oFoldX001:aDialogs[nFolderI] WHEN ((INCLUI .OR. ALTERA) .AND. !Empty(M->VS1_CHASSI) .AND. M->VS1_TIPORC == "2" .AND. Empty(cDesInc)) HASBUTTON

		//
		oSay01 := TSay():New(04, 175, {|| AllTrim(aHeaderI[FG_POSVAR("VST_DESINC","aHeaderI"),1]) },oFoldX001:aDialogs[nFolderI],,oFnt3,,,,.t.,,,40,8)
		@ 03,212 MSGET oDesInc VAR cDesInc VALID OX001INCON(nOpc,cGruInc,cCodInc,cDesInc,"D") PICTURE "@!" SIZE aPosObj[2,4]-aPosObj[2,2]-214,8 PIXEL OF oFoldX001:aDialogs[nFolderI] WHEN ((INCLUI .OR. ALTERA) .AND. !Empty(M->VS1_CHASSI) .AND. M->VS1_TIPORC == "2" .AND. Empty(cGruInc) .AND. Empty(cCodInc))
		//
//		cGruInc := space(TamSX3("VST_GRUINC")[1])
//		cCodInc := space(TamSX3("VST_CODINC")[1])
//		cDesInc := space(TamSX3("VST_DESINC")[1])
		//
		oGetInconv := MsNewGetDados():New(16, 02, aPosObj[2,3]-aPosObj[2,1]-20,aPosObj[2,4]-aPosObj[2,2]-4,0,;
		cLinOKI,cTudoOkI,,aAlterI,0,999,cFieldOkI,,cDelIncOk,oFoldX001:aDialogs[nFolderI],aHeaderI,aColsI )
		If nOpc <> 2 .and. nOpc <> 5
			oGetInconv:oBrowse:bDelete := {||OX001DELI() }
		EndIf
		//
	endif

	//#############################################################################
	//# ListBox contendo os itens relacionados                                    #
	//#############################################################################
	@ 01,01 LISTBOX oLItRel FIELDS HEADER ;
		OemToAnsi(STR0147), ;   // marca
		OemToAnsi(STR0148), ;   // descricao
		OemToAnsi(STR0149), ;   // codigo interno
		OemToAnsi(STR0018), ;   // grupo
		OemToAnsi(STR0020), ;	// código do item
		OemToAnsi(STR0021), ;	// descricao
		OemToAnsi(STR0012), ;	// quantidade
		OemToAnsi(STR0022) ;	// valor
		COLSIZES 50, 80, 100, 50, 110, 130, 50, 60 ;
		SIZE 200,400;
		OF oTPanP2 ON DBLCLICK ( OX001SOBEREL(oLItRel:nAt), oLItRel:Refresh(), oGetPecas:oBrowse:Refresh() ) PIXEL
	oLItRel:Align := CONTROL_ALIGN_ALLCLIENT
	//
	oLItRel:SetArray(aIteRel)
		oLItRel:bLine := { || { aIteRel[oLItRel:nAt,6],;
		aIteRel[oLItRel:nAt,7],;
		aIteRel[oLItRel:nAt,8],;
		aIteRel[oLItRel:nAt,1],;
		aIteRel[oLItRel:nAt,2],;
		aIteRel[oLItRel:nAt,3],;
		FG_AlinVlrs(Transform(aIteRel[oLItRel:nAt,4],"@E 999,999")),;
		FG_AlinVlrs(Transform(aIteRel[oLItRel:nAt,5],"@E 999,999,999.99"))}}

	@ 01,01 CHECKBOX oRelSec VAR lRelSec PROMPT STR0360 ON CLICK OX001ITEREL() OF oTPanP3 SIZE 250,10 PIXEL // Exibe também relacionamentos Secundários

	//#############################################################################
	//# ListBox contendo os dados adicionais                                      #
	//#############################################################################
	sl3 := (aPosObj[1,4] - aPosObj[1,2] - aPosEnchoice[4]) / 3	 // LARGURA DA CELULA
	//
	@ aPosObj[1,1] ,aPosObj[1,2]+ aPosEnchoice[4] LISTBOX olBox FIELDS HEADER ;
		OemToAnsi(STR0021), OemToAnsi(STR0022) COLSIZES sl3 * 1.9, sl3 ;
		SIZE aPosObj[1,4] - aPosObj[1,2] - aPosEnchoice[4], aPosObj[1,3] - aPosObj[1,1];
		OF oDlgXX001 PIXEL
	//
	olBox:SetArray(aOrc)
	olBox:bLine := { || {  aOrc[olBox:nAt,2] , ;
		FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}

	//#######################################################################################################
	//# Inicialmente apenas o cabecalho estara habilitado.                                                  #
	//# O preenchimento dos demais sera liberado quando o cliente for preenchido. (inicializacao do fiscal) #
	//#######################################################################################################
	If INCLUI
		oGetPecas:disable()
		oGetServ:disable()
		oFoldX001:disable()
		oLItRel:disable()
		olBox:disable()
		if lInconveniente .and. M->VS1_TIPORC == "2"
			oGetInconv:Disable()
		endif
	else
		If ALTERA .or. FECHA  .or. VISUALIZA

			DBSelectArea("SA1")
			DBSetOrder(1)
			DBSeek(xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA)
			MaFisIni(;
				VS1->VS1_CLIFAT,;
				VS1->VS1_LOJA,;
				'C',;
				'N',;
				IIF(!Empty(VS1->VS1_TIPCLI),VS1->VS1_TIPCLI,SA1->A1_TIPO),;
				MaFisRelImp("OF110",{"VS1","VS3"}) )

			if !lLibPV
				if VS1->VS1_RETPEC == '2'
					reclock("VS1",.f.)
					VS1->VS1_RETPEC := '1'
					msunlock()
				endif
			endif

			// ------------------------- //
			// Processa Pecas e Servicos //
			// ------------------------- //
			oProcTTP := MsNewProcess():New({ |lEnd| OX001LVS34() }," ","",.f.)
			oProcTTP:Activate()

			if M->VS1_DESACE <> 0
				MaFisRef("NF_DESPESA",,M->VS1_DESACE)
			endif
			if M->VS1_VALSEG <> 0
				MaFisRef("NF_SEGURO",,M->VS1_VALSEG)
			endif
			if M->VS1_VALFRE <> 0
				MaFisRef("NF_FRETE",,M->VS1_VALFRE)
			endif

			MaFisRef("NF_TPFRETE",,M->VS1_PGTFRE)

			If !Empty(M->VS1_NATURE)
				MaFisRef("NF_NATUREZA",,M->VS1_NATURE)
			Else
				MaFisRef("NF_NATUREZA",,SA1->A1_NATUREZ)
			EndIf

			M->VS1_VTOTNF := MaFisRet(,"NF_TOTAL") - MaFisRet(,"NF_DESCZF") //OX001TOTPF("OF")
			M->VS1_ICMCAL := MaFisRet(,"NF_VALICM")
			M->VS1_VALDES := MaFisRet(,"NF_DESCONTO")
			M->VS1_VALIPI := MaFisRet(,"NF_VALIPI")
			M->VS1_VALCMP := MaFisRet(,"NF_VALCMP")
			M->VS1_DIFAL  := MaFisRet(,"NF_DIFAL")
			M->VS1_VALIRR := MaFisRet(,"NF_VALIRR")
			M->VS1_VALCSL := MaFisRet(,"NF_VALCSL")

			OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)

		endif

	endif

	oFoldX001:SetOption(nFolderP)
	oFoldX001:aEnable(nFolderS,.f.)
	if lInconveniente
		oFoldX001:aEnable(nFolderI,.f.)
	endif
	If M->VS1_TIPORC == "2"
		oFoldX001:aEnable(nFolderS,.t.)
		if lInconveniente
			oFoldX001:aEnable(nFolderI,.t.)
		endif
	endif
	// ######################
	// # Ativacao da janela #
	// ######################
	If lLibPV

		//
		OX001RefNF()
		//
		cMsgLotMin := ""

		for nCntFor := 1 to Len(oGetPecas:aCols)
			lPPrepec := .t.  // Controla se sera executada a funcao OX001PREPEC
			__ReadVar := 'M->VS3_QTDITE'
			M->VS3_QTDITE := oGetPecas:aCols[nCntFor,nVS3QTDITE]
			oGetPecas:nAt := nCntFor
			FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
			OX001FPOK(.f., lLibPv, .f., .f., .t., , lAgrMsgSld, @aProdSdEst)
		next

		If Len(aProdSdEst) > 0
			OX001028D_ExibeProdutosSemSaldo(aProdSdEst)
		Endif

		// Caso Peças com problemas de lote mínimo, mostrar mensagem unificada das peças
		// Não tem retorno false, apenas mostra a mensagem e dá continuidade na liberação
		// da mesma forma que faz com as mensagens separadamente!
		If !Empty(cMsgLotMin)
			OX001LOTM(cMsgLotMin)
		EndIf

		OX001PREPEC("", .f.)
		OX001GRV(nOpc)
		nOpc := 2
		VISUALIZA	:= nOpc==2
		INCLUI 		:= nOpc==3
		ALTERA 		:= nOpc==4
		EXCLUI 		:= nOpc==5
		FECHA  		:= nOpc==6
	endif
	oDlgXX001:bInit := {|| EnchoiceBar(oDlgXX001, { || IIf(OX001TUDOK(nOpc),OX001FAT(nOpc),.t.) } , { || nOpca := 0,lRet:=OX001SAIR(nOpc) },,aNewBot ), OX001TELA(nOpc) }
	oDlgXX001:lCentered := .F.

	oDlgXX001:Activate()
	//
Else
	//########################################################################################################################################################
	//# ROTINA AUTOMÁTICA: Para completa compatibilização e uso adequado precisamos criar uma classe para simular a exitência das acols das MSNEWGETDADOS    #
	//#                    A classe está declarada nas primeiras linhas do programa e permite o uso da acols e nAt dentro do objeto. Dessa forma as funções  #
	//#                    de FieldOk() poderão ser utilizadas sem problema. Como o fieldok não é chamado automaticamente, no linok a função é chamada       #
	//#                    explicitamente para cada campo do vetor.                                                                                          #
	//########################################################################################################################################################
	If EnchAuto("VS1",aAutoCab)
		// inicializa os objetos de compatibilização
		oGetPecas 	:= AutoGD():new()
		oGetInconv 	:= AutoGD():new()
		oGetServ 	:= AutoGD():new()
		// Salva o aCols atual do fiscal
		aHeaderF := aClone(aHeader)
		aColsF := aClone(aCols)
		// Replica as informações da acols de inconveniente e chama a função
		aHeader = aClone(aHeaderI)
		aCols := {}
		lRet := MsGetDAuto(aAutoInco,"OX001LINIOK",  {|| .t. },aAutoCab,nOpc)
		// Replica as informações da acols de serviço e chama a função
		aHeader = aClone(aHeaderS)
		aCols := {}
		lRet := MsGetDAuto(aAutoServ,"OX001LINSOK",  {|| .t. },aAutoCab,nOpc)
		// Replica as informações da acols de pecas e chama a função
		aHeader = aClone(aHeaderP)
		aCols := {}
		lRet := MsGetDAuto(aAutoPecas,"OX001LINPOK",	{|| OX001TUDOK(nOpc).And.OX001FAT(nOpc) },aAutoCab,nOpc)
		if !lRet
			lMsErroAuto := .t.
			return .f.
		endif
	else
		lMsErroAuto := .t.
		return .f.
	EndIf
EndIf
//
SET KEY VK_F4 TO
SET KEY VK_F5 TO
SET KEY VK_F6 TO
SET KEY VK_F7 TO
SET KEY VK_F8 TO
SET KEY VK_F9 TO
SET KEY VK_F10 TO
//
//
Return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001VLDENC | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Rotina de validacao da ENCHOICE                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001VLDENC(nPosVetor,lChmPER, lMsgGrv)
Local lClie := .f.
Local nCntFor
Local cMensagem := ""
Local nOpca  := 0
Local nPosic := 0
Local lRet   := .f.
//
//
//Local oOficina := DMS_Oficina():New()
//
//Local dDatRefPD   := dDataBase
//Local nVS1PERREM  := 0
//
Local lNewRes     := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?
//
Default nPosVetor := 0
Default lChmPER   := .f.
Default lMsgGrv   := .T.

// ############################################################################
If !lNewRes .and. ReadVar() == "M->VS1_RESERV"
	// ########################################################################
	if lOrcJaRes  .and. M->VS1_RESERV == "1"
		return .t.
	endif
	//
	if lOrcJaRes
		MsgStop(STR0276)
		return .f.
	endif
	if M->VS1_RESERV == "0"
		return .t.
	endif
	// SE CHEGAR AQUI EH PQ NAO ESTAVA RESERVADO E O USUARIO QUER A RESERVA
	If !lMsgGrv // se no vai apresentar mensagem de gravao com sucesso
		if INCLUI
			if OX001GRV(3,,,.t.,,lChmPER, lMsgGrv) == .f.
				return .f.
			else
			//
			if ExistBlock("ORDBUSCB")
				ExecBlock("ORDBUSCB",.f.,.f.,{"OR","INCLUI"})
			Endif
			//
			endif
		else
			if OX001GRV(4,,,.t.,,lChmPER, lMsgGrv) == .f.
				return .f.
			else
				//
				if ExistBlock("ORDBUSCB")
					ExecBlock("ORDBUSCB",.f.,.f.,{"OR","ALTERA"})
				Endif
				//
			endif
		endif
	else
		if INCLUI
			if OX001GRV(3,,,.t.,,lChmPER) == .f.
				return .f.
			else
			//
			if ExistBlock("ORDBUSCB")
				ExecBlock("ORDBUSCB",.f.,.f.,{"OR","INCLUI"})
			Endif
			//
			endif
		else
			if OX001GRV(4,,,.t.,,lChmPER) == .f.
				return .f.
			else
				//
				if ExistBlock("ORDBUSCB")
					ExecBlock("ORDBUSCB",.f.,.f.,{"OR","ALTERA"})
				Endif
				//
			endif
		endif
	Endif
	OX001REGIMP(.f.)
	oGetPecas:oBrowse:refresh()
	lOrcJaRes := .t.
endif

// ############################################################################
If ReadVar() == "M->VS1_FORMUL"
	// ########################################################################
	If OFP8600016 .And. !OFP8600016_VerificacaoFormula(M->VS1_FORMUL)
		Return .f. // A mensagem já é exibida dentro da função
	EndIf

	if !Empty(M->VS1_TIPTEM)
		DBSelectArea("VOI")
		DBSetOrder(1)
		DBSeek(xFilial("VOI")+M->VS1_TIPTEM)
		//
		if VOI->VOI_ALTVAL == "0" .and. M->VS1_FORMUL != VOI->VOI_VALPEC
			MsgStop(STR0232)
			return .f.
		endif
	endif
	return .t.
endif
// ############################################################################
If ReadVar() == "M->VS1_TIPVEN"
	// ########################################################################
	DBSelectArea("VAI")
	DBSetOrder(6)
	if DBSeek(xFilial("VAI")+M->VS1_CODVEN)

		if VAI->VAI_TIPVEN == "1" .and. M->VS1_TIPVEN == "1"
			lRet := .t.
		endif

		if VAI->VAI_TIPVEN == "2" .and. M->VS1_TIPVEN == "2"
			lRet := .t.
		endif

		if VAI->VAI_TIPVEN == "3"
			lRet := .t.
		endif

		if !lRet
			MsgInfo(STR0023) // Vendedor nao autorizado a utilizar esse tipo de venda.
			return .f.
		endif

		if lRet
			if !Empty(oGetPecas:aCols[1,nVS3CODITE]) .and. !oGetPecas:aCols[1,Len(oGetPecas:aCols[1])]
				nPos1    := At(cVS1Status,GetNewPar("MV_FASEORC","0FX"))
				nPosicao := At("2",GetNewPar("MV_FASEORC","0FX")) // "2" - MARGEM DE LUCRO E DESCONTO
				if nPos1 < nPosicao .or. nPosicao == 0
					cFormul := FS_FORMULA()
					if !Empty(oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_FORMUL","aHeaderP")])
						if oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_FORMUL","aHeaderP")] <> cFormul

							cMensagem := STR0259+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Deseja realmente alterar a Condição de Pagamento?
							cMensagem += STR0260+CHR(13)+CHR(10) // Se sim, os valores de venda serão RECALCULADOS 
							cMensagem += STR0261 // e todos os conteúdos de Percentual e Valor de Desconto serão APAGADOS.
							DEFINE MSDIALOG oDlg8 FROM 000,000 TO 013,050 TITLE "" OF oMainWnd STYLE DS_MODALFRAME
							oDlg8:lEscClose := .F.

							DEFINE SBUTTON FROM 82,135 TYPE 1 ACTION ( nOpca := 1, oDlg8:End() ) ENABLE OF oDlg8
							DEFINE SBUTTON FROM 82,165 TYPE 2 ACTION ( nOpca := 0, oDlg8:End() ) ENABLE OF oDlg8

							@ 008,010 GET oMsg VAR cMensagem OF oDlg8 MEMO SIZE 180,070 PIXEL READONLY MEMO FONT (TFont():New('Arial',0,-12,.T.,.T.))

							ACTIVATE MSDIALOG oDlg8 CENTER
							if nOpca == 1
								For nPosic := 1 to Len(oGetPecas:aCols)
									// So processa a linha que Interessa
									If nPosVetor > 0
										If nPosic <> nPosVetor
											Loop
										Endif
									Endif
									//
									SBM->(dbSetOrder(1))
									SBM->(msSeek(xFilial("SBM")+oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]))

									oGetPecas:nAt := nPosic

									if !oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])]
									
										FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
										if !Empty(SBM->BM_FORMUL)
											oGetPecas:aCols[oGetPecas:nAt,nVS3FORMUL] := SBM->BM_FORMUL
										else
											oGetPecas:aCols[oGetPecas:nAt,nVS3FORMUL] := &(cFormul)
										endif
										__ReadVar := 'M->VS1_PERDES'
										OX001VLDENC()
										lPPrepec := .t.  // Controla se sera executada a funcao OX001PREPEC
										__ReadVar := 'M->VS3_CODITE'
										oGetPecas:nAt := nPosic
										FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
										OX001PREPEC("", .f.)
										oGetPecas:oBrowse:refresh()
									Endif
								Next
								OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
								M->VS1_FORMUL := &(cFormul)
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif
	endif
endif

// ############################################################################
If ReadVar() == "M->VS1_TIPORC"
	If M->VS1_TIPORC <> "2"
		If FWIsInCallStack("OFIXA120")
			MsgAlert(STR0282,STR0025) //Pelo Painel Oficina é permitido somente Orçamento Oficina.
			return .f.
	    EndIf
	EndIf
	//
	if M->VS1_TIPORC == "1"
		// ######################################
		// Verifica se foi lancado algum servico
		// ######################################
		for nCntFor := 1 to Len(oGetServ:aCols)
			If !(oGetServ:aCols[nCntFor,len(oGetServ:aCols[nCntFor])])
				if !Empty(oGetServ:aCols[nCntFor,fg_posvar("VS4_CODSER","aHeaderS")])
					if !lOX001Auto
						MsgInfo(STR0024,STR0025)
					endif
					return .f.
				endif
			endif
		next
		// ############################################
		// Verifica se foi lancado algum inconveniente
		// ############################################
		if lInconveniente
			for nCntFor := 1 to Len(oGetInconv:aCols)
				If !(oGetInconv:aCols[nCntFor,len(oGetInconv:aCols[nCntFor])])
					if !Empty(oGetInconv:aCols[nCntFor,FG_POSVAR("VST_DESINC","aHeaderI")])
						if !lOX001Auto
							MsgInfo(STR0145,STR0025)
						endif
						return .f.
					endif
				endif
			next
		endif
		oFoldX001:SetOption(nFolderP)
		oFoldX001:aEnable(nFolderS,.f.)
		if lInconveniente
			oFoldX001:aEnable(nFolderI,.f.)
		endif
	else
		if M->VS1_TIPORC == "3"
			// ######################################
			// Verifica se foi lancado algum servico
			// ######################################
			for nCntFor := 1 to Len(oGetServ:aCols)
				If !(oGetServ:aCols[nCntFor,len(oGetServ:aCols[nCntFor])])
					if !Empty(oGetServ:aCols[nCntFor,fg_posvar("VS4_CODSER","aHeaderS")])
						if !lOX001Auto
							MsgInfo(STR0024,STR0025)
						endif
						return .f.
					endif
				endif
			next
			oFoldX001:aEnable(nFolderP,.t.)
			oFoldX001:aEnable(nFolderS,.f.)
			if lInconveniente
				oFoldX001:aEnable(nFolderI,.f.)
			endif
		Else
			oFoldX001:aEnable(nFolderP,.t.)
			oFoldX001:aEnable(nFolderS,.t.)
			if lInconveniente
				oFoldX001:aEnable(nFolderI,.t.)
			endif
		Endif
	endif
EndIf
// ############################################################################
If ReadVar() == "M->VS1_CLIFAT"
	// ########################################################################
	If !Empty(M->VS1_CLIFAT)
		lClie := .t.
	EndIf
EndIf
// ############################################################################
If ReadVar() == "M->VS1_TIPCLI"
	// ########################################################################

	OX001RecFis("NF_TPCLIFOR",M->VS1_TIPCLI) // nova atualização do Fiscal - Junho 2016
	MaFisRef("NF_CODCLIFOR",," ")
	lClie := .t.

endif
// ############################################################################
If ReadVar() == "M->VS1_LOJA" .or. lClie
	// ########################################################################
	If Empty(M->VS1_LOJA)
		Return .t.
	EndIf
	// Posiciona no cliente
	DBSelectArea("SA1")
	DBSetOrder(1)
	if !DbSeek(xFilial("SA1")+M->VS1_CLIFAT+M->VS1_LOJA)
		return .f.
	endif
	// Verifica se o cliente esta bloqueado
	if SA1->A1_MSBLQL == "1"
		if !lOX001Auto
			// CUSTOMIZA MENSAGEMD E CLIENTE BLOQUEADO
			If ExistBlock("OX001HCB")
				ExecBlock("OX001HCB",.f.,.f.)
			else
				Help("",1,"REGBLOQ") //"Cliente bloqueado"
				// MsgInfo(STR0026, STR0025)
			endif
		endif
		Return(.f.)
	Endif
	// Se o cliente esta ok e o fiscal nao foi inicializado entao inicializa o fiscal com essas informacoes
	If !MaFisFound('NF')
		MaFisIni(SA1->A1_COD,SA1->A1_LOJA,'C','N',SA1->A1_TIPO,MaFisRelImp("OF110",{"VS1","VS3"}))
		// Habilita a digitacao dos itens caso a rotina nao seja automatica
		If !lOX001Auto
			oGetPecas:Enable()
			oGetServ:Enable()
			oLItRel:Enable()
			oFoldX001:Enable()
			olBox:Enable()
			if lPediVenda
				oFoldX001:SetOption(nFolderP)
			endif
			if lInconveniente .and. M->VS1_TIPORC == "2"
				oGetInconv:Enable()
			endif
		EndIf
	Else // se o fiscal esta ok apenas atualiza o cliente
		MaFisRef("NF_CODCLIFOR",,M->VS1_CLIFAT)
		MaFisRef("NF_LOJA",,M->VS1_LOJA)
	endif
	If !Empty(M->VS1_NATURE)
		MaFisRef("NF_NATUREZA",,M->VS1_NATURE)
	Else
		MaFisRef("NF_NATUREZA",,SA1->A1_NATUREZ)
	EndIf
	// carrega demais informacoes do cliente
	M->VS1_NCLIFT := SA1->A1_NOME
	M->VS1_ENDCLI := SA1->A1_END
	M->VS1_FONCLI := SA1->A1_TEL
	If readvar() <> "M->VS1_TIPCLI"
		M->VS1_TIPCLI := SA1->A1_TIPO
	Endif
	if lVAMCid
		FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
		M->VS1_CIDCLI := VAM->VAM_DESCID
		M->VS1_ESTCLI := VAM->VAM_ESTADO
	Else
		M->VS1_CIDPRO := SA1->A1_MUN
		M->VS1_ESTPRO := SA1->A1_EST
	Endif
	//
	M->VS1_FORPAG := SA1->A1_COND
	// verifica se eh um processo de recompra
	if !lRecompra .and. !lOX001Auto
		dbSelectArea("VE4")
		dbSeek(xFilial("VE4"))
		While !Eof() .and. xFilial("VE4") == VE4->VE4_FILIAL
			if M->VS1_CLIFAT == VE4->VE4_CODFAB .and. M->VS1_TIPORC == "1"
				if MsgYesNo(STR0027 ,STR0025)
					lRecompra := .t.
					M->VS1_RETPEC := "1"
					M->VS1_ORCACE := "0"
				Endif
				Exit
			Endif
			dbSelectArea("VE4")
			dbSkip()
		Enddo
	Endif
	MaFisRef("NF_TPCLIFOR",,"  ")
	OX001RecFis("NF_TPCLIFOR",M->VS1_TIPCLI) // nova atualização do Fiscal - Junho 2016
	// ############################################################################
	// # Funcao que mostra o risco do cliente                                     #
	// ############################################################################
	if !lOX001Auto
		FG_CKCLINI(M->VS1_CLIFAT+M->VS1_LOJA)
		OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
	endif
EndIf
if ReadVar()=="M->VS1_NATURE"
	If !Empty(M->VS1_NATURE)
		MaFisRef("NF_NATUREZA",,M->VS1_NATURE)
	Else
		MaFisRef("NF_NATUREZA",,SA1->A1_NATUREZ)
	EndIf
EndIf
// ###############################################################################################
if ReadVar()=="M->VS1_DESACE"
	// ###########################################################################################
	If !MaFisFound('NF')
		return .f.
	endif
	MaFisRef("NF_DESPESA",,M->VS1_DESACE)
	if !lOX001Auto
		OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
	endif
endif
// ###############################################################################################
if ReadVar()=="M->VS1_VALSEG"
	// ###########################################################################################
	If !MaFisFound('NF')
		return .f.
	endif
	MaFisRef("NF_SEGURO",,M->VS1_VALSEG)
	if !lOX001Auto
		OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
	endif
endif
// ###############################################################################################
if ReadVar()=="M->VS1_VALFRE"
	// ###########################################################################################
	If !MaFisFound('NF')
		return .f.
	endif
	MaFisRef("NF_FRETE",,M->VS1_VALFRE)
	if !lOX001Auto
		OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
	endif
endif

// ###############################################################################################
if ReadVar()=="M->VS1_PGTFRE"
	// ###########################################################################################

	If !Pertence("CFTRDS")
		return .f.
	EndIf

 	MaFisRef("NF_TPFRETE",,M->VS1_PGTFRE)

	If oGetPecas:aCols[1,nVS3QTDITE] != 0

		nPosic := 0
		For nPosic := 1 to Len(oGetPecas:aCols)
			oGetPecas:nAt := nPosic
			if !oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])]
				FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
				__ReadVar := 'M->VS1_VALFRE'
				OX001VLDENC()
				lPPrepec := .f.  // Controla se sera executada a funcao OX001PREPEC
				__ReadVar := 'M->VS3_CODITE'
				oGetPecas:nAt := nPosic
				FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
				OX001PREPEC("" , .f.)
				oGetPecas:oBrowse:refresh()
			Endif
		Next
		OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)

	Endif

Endif

// ###############################################################################################
if ReadVar()=="M->VS1_FORPAG"
	// ###########################################################################################
	If !MaFisFound('NF')
		return .f.
	endif

	DBSelectArea("SA1")
	DBSetOrder(1)
	if !DbSeek(xFilial("SA1")+M->VS1_CLIFAT+M->VS1_LOJA)
		return .f.
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a Condicao esta bloqueada ou nao       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SE4->(ColumnPos("E4_MSBLQL")) > 0 .AND. !Empty(M->VS1_FORPAG)
		 DbSelectArea("SE4")
		 DbSetOrder(1)
		 If msSeek(xFilial("SE4")+M->VS1_FORPAG)
			If SE4->E4_MSBLQL=="1"
				Help(" ",1,"REGBLOQ")
				return .f.
			Endif
		EndIf
	EndIf

	if SA1->A1_COND != M->VS1_FORPAG .and. !Empty(SA1->A1_COND)
		if !lOX001Auto
			nOperacao := Aviso( STR0028, STR0029, { STR0030 , STR0031 } ) // Cliente Periodico  // Este e um cliente periodico, mudando a condicao de pagamento o sistema nao gerara titulos provisorios.
			if nOperacao <> 1
				M->VS1_FORPAG := SA1->A1_COND
				DBSelectArea("SE4")
				DBSetOrder(1)
				DBSeek(xFilial("SE4")+M->VS1_FORPAG)
				M->VS1_DESFPG := SE4->E4_DESCRI
				Return .t.
			Endif
		Endif
	endif

	if !Empty(oGetPecas:aCols[1,nVS3CODITE]) .and. !oGetPecas:aCols[1,Len(oGetPecas:aCols[1])]
		nPos1    := At(cVS1Status,GetNewPar("MV_FASEORC","0FX"))
		nPosicao := At("2",GetNewPar("MV_FASEORC","0FX"))
		if nPos1 < nPosicao .or. nPosicao == 0
		Else
			MsgInfo(STR0262) // Somente é permitida a alteração da Condição de Pagamento caso o orçamento ainda não tenha passado pela fase de Liberação de Descontos.
			Return(.f.)
		Endif
	Endif
	//
	OX0010271_PercentualRemuneracao( .t. ) // Retorna o % de Remuneração
	//
endif
// ###############################################################################################
if ReadVar()=="M->VS1_PERDES" .or. ReadVar()=="M->VS1_VALPRE"
	If !MaFisFound('NF')
 		return .f.
	endif

	OX0010373_VS1_PERDES_VALPRE(nPosVetor)

endif
// ###############################################################################################
// Validação Tipo de Atendimento por Tipo de Tempo (Peça)
If Readvar() == "M->VS1_TIPTEM"
	If Empty(M->VS1_TIPTEM)
		Return .t.
	EndIf
	if oOficina == NIL
		oOficina := DMS_Oficina():New()
	endif
	If oOficina:TipoTempoBloqueado(M->VS1_TIPTEM,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
		Return .f.
	EndIf
	If M->VS1_TIPORC == "2" .And. !Empty(M->VS1_TPATEN)
		If lVOITPATEN
			If !FGX_VOITPATEN(M->VS1_TPATEN, M->VS1_TIPTEM, .t.)
				Return .f.
			EndIf
		EndIf
	EndIf
EndIf

// ###############################################################################################
// Validação Tipo de Atendimento por Tipo de Tempo (Serviço)
If Readvar() == "M->VS1_TIPTSV"
	If Empty(M->VS1_TIPTSV)
		Return .t.
	EndIf
	if oOficina == NIL
		oOficina := DMS_Oficina():New()
	endif
	If oOficina:TipoTempoBloqueado(M->VS1_TIPTSV,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
		Return .f.
	EndIf
	If M->VS1_TIPORC == "2" .And. !Empty(M->VS1_TPATEN)
		If lVOITPATEN
			If !FGX_VOITPATEN(M->VS1_TPATEN, M->VS1_TIPTSV, .t.)
				Return .f.
			EndIf
		EndIf
	EndIf
EndIf
//
Return .t.


/*/{Protheus.doc} OX0010383_ZeraDescontoPecas
Zera desconto das pecas

@author Rubens
@since 27/10/2023
@version 1.0

@type function
/*/
static function OX0010383_ZeraDescontoPecas()

	local nCntFor 

	for nCntfor := 1 to len(oGetPecas:aCols)
		if oGetPecas:aCols[nCntFor,nVS3VALDES] <> 0 .and. ! oGetPecas:aCols[nCntFor,Len(oGetPecas:aCols[nCntFor])]
			oGetPecas:nAt := nCntFor
			FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
			M->VS3_PERDES := 0
			M->VS3_VALDES := 0
			__ReadVar := 'M->VS3_PERDES'
			OX001FPOK(.f./* lMensagem */ ,,.f. /* lRecalc */ ,.f. /* lMsgLotMin */ )
		endif
	next

return

/*/{Protheus.doc} OX0010373_VS1_PERDES_VALPRE
Rateio de desconto para VS1_PERDES e VS1_VALPRE

@author Rubens
@since 27/10/2023
@version 1.0

@type function
/*/
static Function OX0010373_VS1_PERDES_VALPRE(nPosVetor)

	local lValMaior := .f.
	Local dDatRefPD   := dDataBase
	Local nVS1PERREM  := 0
	local nValMerc := 0 
	local nCntFor, nCntFor2

	Local nUltPosaCols := 0
	Local nMaiorDesc  := 0
	Local nBkpnAt := oGetPecas:nAt

	local nVTotPecAntes
	local nVTotPecDepois
	local aVetItDesc
	local aVetItDif
	local nValPRat
	local nValorDesejado
	Local cCodIte
	Local cGruIte

	local nValMin
	local nValFalta
	local nValSobra
	local nPercDaSobra
	local nLVet
	local nTotFinal
	local nIniProc
	local nFimProc
	local nSubtraiDesc

	if ReadVar()=="M->VS1_PERDES" .and. M->VS1_PERDES == 0
		
		nBkpnAt := oGetPecas:nAt
		OX0010383_ZeraDescontoPecas()
		oGetPecas:nAt := nBkpnAt

		FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
		return
	endif
	//
	if ReadVar()=="M->VS1_VALPRE"
		//
		M->VS1_PERDES := 0
		OX0010383_ZeraDescontoPecas()
		//
		nValMerc := MaFisRet(,"NF_VALMERC")
		if M->VS1_VALPRE > nValMerc
			nValDif := M->VS1_VALPRE
			lValMaior := .t.
		else
			M->VS1_PERDES := Round(100 - (100 * M->VS1_VALPRE / nValMerc), TamSX3("VS1_PERDES")[2])
		endif

		nIniProc := IIf(nPosVetor > 0, nPosVetor, 1)
		nFimProc := IIf(nPosVetor > 0, nPosVetor, Len(oGetPecas:aCols))
		for nCntFor := nIniProc to nFimProc
			if !oGetPecas:aCols[nCntFor,Len(oGetPecas:aCols[nCntFor])] .and. oGetPecas:aCols[nCntFor,nVS3VALDES] > 0
				FMX_HELP("OX001ERR007",STR0407,STR0176) // "Não é possível aplicar um valor pretendido maior que o atual quando alguma peça possui um valor de desconto informado." // Zere os todos os descontos antes de aplicar um valor pretendido maior que o atual.
				return .f.
			endif
		next
	endif

	// calcula o rateio dos itens
	nVTotPecAntes := 0    // valor da soma dos itens antes do rateio
	nVTotPecDepois := 0   // valor da soma dos itens depois do rateio
	aVetItDesc := {}
	aVetItDif := {}
	// Faz o laço tentando ratear os valores
	nValPRat := MaFisRet(,"NF_VALMERC")
	//
	OX001RefNF()
	//
	If nVAIDTCDES > 0 // Data para validar a Politica de Desconto
		VAI->(DBSetOrder(4))
		If VAI->(msSeek(xFilial("VAI")+__cUserID))
			If VAI->VAI_DTCDES == "1" // Utilizar 1=Data de Inclusão do Orçamento para validar a Politica de Desconto
				dDatRefPD := VS1->VS1_DATORC
			EndIf
		EndIf
	EndIf
	If lVS1PERREM
		nVS1PERREM := M->VS1_PERREM
	EndIf
	//

	nIniProc := IIf(nPosVetor > 0,nPosVetor, 1)
	nFimProc := IIf(nPosVetor > 0,nPosVetor, Len(oGetPecas:aCols))
	for nCntFor := nIniProc to nFimProc

		// pula registros deletados
		if oGetPecas:aCols[nCntFor,Len(oGetPecas:aCols[nCntFor])]
			loop
		endif

		if lValMaior

			// executa o fieldok para atualizar os campos
			oGetPecas:aCols[nCntFor,nVS3VALPEC] := A410Arred(nValDif * oGetPecas:aCols[nCntFor,nVS3VALPEC] / nValPRat,"C6_PRUNIT")
			oGetPecas:nAt := nCntFor

			// monta variáveis de memória a partir da linha da acols
			FG_MEMVAR(aHeaderP, oGetPecas:aCols, nCntFor, .f.)

			M->VS3_VALPEC := oGetPecas:aCols[nCntFor,nVS3VALPEC]
			__ReadVar := 'M->VS3_VALPEC'
			OX001FPOK(.f.,,.f.,.f.)

		else

			aAdd(aVetItDesc,{0, 0})			// vetor contendo os valores dos itens antes e depois do rateio
			aAdd(aVetItDif,0)				// vetor contendo a diferença entre os valores antes e depois do rateio
		
			// monta variáveis de memória a partir da linha da acols
			FG_MEMVAR(aHeaderP, oGetPecas:aCols, nCntFor, .f.)

			// armazena o valor anterior nas variáveis
			nVTotPecAntes += Round(M->VS3_VALPEC * M->VS3_QTDITE,2)
			aVetItDesc[Len(aVetItDesc),1] := M->VS3_VALPEC * M->VS3_QTDITE

			// armazena grupo e código do item
			cCodIte := 	oGetPecas:aCols[nCntFor,nVS3CODITE]
			cGruIte := 	oGetPecas:aCols[nCntFor,nVS3GRUITE]

			SBM->(dbSetOrder(1))
			SBM->(msSeek(xFilial("SBM")+cGruIte))

			// calcula o valor mínimo possível para o produto em questão
			nValMin := OX005RETMIN(;
				SBM->BM_CODMAR,; // cMarca
				M->VS1_CENCUS,;  // cCenRes
				M->VS3_GRUITE,;  // cGrupo
				M->VS3_CODITE,;  // cCodite
				M->VS3_QTDITE,;  // nQtd
				M->VS3_PERDES,;  // nPercent
				.f.,;            // lHlp
				M->VS1_CLIFAT,;  // cCliente
				M->VS1_LOJA,;    // cLoja
				M->VS1_TIPVEN,;  // cTipVen
				M->VS3_VALPEC,;  // nValUni
				2,;              // nTipoRet
				M->VS1_FORPAG,;  // cForPag
				,;               // cFormAlu
				.f.,;            // lFechOfi
				dDatRefPD,;      // dDatRefPD
				nVS1PERREM)      // nPERREM)

			// coloca o valor mínimo possível no item da acols
			if M->VS3_VALPEC != 0
				M->VS3_PERDES := Round(( 1 - nValMin/M->VS3_VALPEC)*100, TamSX3("VS3_PERDES")[2])
			endif

			// executa o fieldok para atualizar os campos
			oGetPecas:aCols[nCntFor,nVS3PERDES] := M->VS3_PERDES
			oGetPecas:nAt := nCntFor
			__ReadVar := 'M->VS3_PERDES'
			OX001FPOK(.f.,,.f.,.f.)

			// armazena o valor total e a diferença depois da alteração
			nVTotPecDepois += oGetPecas:aCols[nCntFor,nVS3VALTOT]

			aVetItDesc[Len(aVetItDesc),2] := oGetPecas:aCols[nCntFor,nVS3VALTOT]

			aVetItDif[Len(aVetItDesc)] := aVetItDesc[Len(aVetItDesc),1] - aVetItDesc[Len(aVetItDesc),2]

		endif
	next

	if lValMaior
		nDifFinal := M->VS1_VALPRE - MaFisRet(,"NF_VALMERC")
		if nDifFinal != 0

			nIniProc := IIf(nPosVetor > 0,nPosVetor, 1)
			nFimProc := IIf(nPosVetor > 0,nPosVetor, Len(oGetPecas:aCols))
			for nCntFor := nIniProc to nFimProc
				//
				if !oGetPecas:aCols[nCntFor,Len(oGetPecas:aCols[nCntFor])]

					oGetPecas:aCols[nCntFor,nVS3VALPEC] := nDifFinal/oGetPecas:aCols[nCntFor,nVS3QTDITE] + oGetPecas:aCols[nCntFor,nVS3VALPEC]
					oGetPecas:nAt := nCntFor
					M->VS3_VALPEC := oGetPecas:aCols[nCntFor,nVS3VALPEC]
					__ReadVar := 'M->VS3_VALPEC'
					OX001FPOK(.f.,,.f.,.f.)

				endif

				nDifFinal := M->VS1_VALPRE - MaFisRet(,"NF_VALMERC")
			next
		endif
	endif

	if ! lValMaior
		// verifica qual é o percentual desejado para aplicação do desconto do orçamento
		nValorDesejado := Round(nVTotPecAntes * (1 - M->VS1_PERDES/100),2)

		// Caso não seja possível a aplicação do preço desejado, aplica o máximo possível e avisa o usuário
		if nVTotPecDepois > nValorDesejado
			if !lOX001Auto
				MsgInfo(STR0032,STR0025)// "Não é possível a aplicação do desconto solicitado. Será dado o desconto máximo para todos os itens."
			endif
			if nVTotPecAntes != 0
				M->VS1_PERDES := Round(100* nVTotPecDepois/nVTotPecAntes,2)
			endif
			return .t.
		endif

		// faz o rateio da sobra novamente para alcançar o valor desejado
		nValFalta = nValorDesejado - nVTotPecDepois
		nValSobra = nVTotPecAntes - nVTotPecDepois
		if nValFalta > nValSobra
			if !lOX001Auto
				MsgInfo(STR0033,STR0025)
			endif
		else
			// calcula a diferença percentual a ser decrementada de cada item para alcançar o valor desejado
			nPercDaSobra := nValFalta / nValSobra
			nLVet := 0
			nTotFinal := 0
			nMaiorDesc := 0

			nIniProc := IIf(nPosVetor > 0,nPosVetor, 1)
			nFimProc := IIf(nPosVetor > 0,nPosVetor, Len(oGetPecas:aCols))
			for nCntFor := nIniProc to nFimProc
				if !oGetPecas:aCols[nCntFor,Len(oGetPecas:aCols[nCntFor])]
					nLVet++
					// monta variáveis de memória a partir da linha da acols
					For nCntFor2:=1 to Len(aHeaderP)
						&("M->"+aHeaderP[nCntFor2,2]) := oGetPecas:aCols[nCntFor,nCntFor2]
					next

					// calcula proporcionalmente o quanto o valor deve ser decrementado e executa fieldok
					nSubtraiDesc := aVetItDif[nLVet]*nPercDaSobra
					M->VS3_VALDES := M->VS3_VALDES - nSubtraiDesc
					oGetPecas:nAt := nCntFor
					__ReadVar := 'M->VS3_VALDES'
					OX001FPOK(.f.,,.f.,.f.)

					nTotFinal += oGetPecas:aCols[nCntFor,nVS3VALTOT]

					If M->VS3_VALDES > nMaiorDesc
						nMaiorDesc   := M->VS3_VALDES
						nUltPosaCols := nCntFor
					Endif
				Endif
			Next
			If nUltPosaCols > 0 .and. nTotFinal <> M->VS1_VALPRE .and. abs(nTotFinal - M->VS1_VALPRE) <= 0.05 .and. oGetPecas:aCols[nUltPosaCols,nVS3VALDES] > 0.05

				M->VS3_VALDES := oGetPecas:aCols[nUltPosaCols,nVS3VALDES]
				If nTotFinal > M->VS1_VALPRE
					M->VS3_VALDES += (M->VS1_VALPRE - nTotFinal)
				ElseIf nTotFinal < M->VS1_VALPRE
					M->VS3_VALDES += (nTotFinal - M->VS1_VALPRE)
				Endif
				
				oGetPecas:aCols[nUltPosaCols,nVS3VALDES] := M->VS3_VALDES 
				oGetPecas:nAt := nUltPosaCols
				For nCntFor2:=1 to Len(aHeaderP)
					&("M->"+aHeaderP[nCntFor2,2]) := oGetPecas:aCols[nUltPosaCols,nCntFor2]
				next
				__ReadVar := 'M->VS3_VALDES'
				OX001FPOK(.f.,,.f.,.f.)
			Endif
		Endif
	endif

	oGetPecas:nAt := nBkpnAt
	FG_MEMVAR(aHeaderP, oGetPecas:aCols, oGetPecas:nAt, .f.)
	
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001FPOK   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | FieldOK da aCols de Pecas                                    |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001FPOK(lMensagem, lLibPv, lRefNF, lRecalc, lMsgLotMin, lVerPromo , lAgrMsgSld ,aProdSdEst, lKitChamada)
Local nCntFor, nCntFor4
Local nAuxLinDup // Linha que esta duplicada na aCols
//Local lGrAchou := .f.
Local nEstSeg  := 0
Local nPosSlv  := 0

Local nQtdOrc    := 0

Local lNewRes    := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?

//Local cBx_ORIGEM := ""
local lPesqSB1 := .f.

Local lCodIteAlterado := .f.
Local lGruIteAlterado := .f.

local lCalcDesconto
local aPromocao

Local _cAuxReadVar := Readvar()
local lValidarQtdeLin := .t.

Private lVldDPec := .t.

Default lMensagem  := .t.
Default lLibPv     := .f.
Default lRefNF     := .t. // Parametro nao utilizado
Default lRecalc    := .f.
Default lMsgLotMin := .f.
Default lVerPromo  := .t.

Default lAgrMsgSld := .f. 
Default aProdSdEst := {}

Default lKitChamada := .f. // Controla se a chamanda do FieldOk foi pelo processamento do Kit

// Verifica linha deletada
lPPrepec := .t.  // Controla se sera executada a funcao OX001PREPEC

//nAuxINIProc := timeCounter()

if oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])] .or. VISUALIZA
	return .f.
endif

If !lNewRes
	// sempre é necessária a alteração da quantidade quando se está com VS1_STATUS = 5
	if VS1->VS1_STATUS<>'5' .and. !lRecalc
		if oGetPecas:aCols[oGetPecas:nAt,nVS3RESERV] == "1" .and. ( _cAuxReadVar != "M->VS3_VALPEC" .and.;
																						_cAuxReadVar != "M->VS3_FORMUL" .and.;
																						_cAuxReadVar != "M->VS3_VALDES" .and.;
																						_cAuxReadVar != "M->VS3_PERDES" )
			
			MsgStop(STR0274,STR0025) // Este item está reservado. Nesse caso, apenas o valor da peça pode ser alterado.
			return .f.
		endif
	endif
EndIf

if nVS3MOTPED > 0.and. ! Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3MOTPED])
	MsgStop(STR0292,STR0025) // Linha do orçamento cancelada. Impossível alterar
	return .f.
endif

if nVS3QTDAGU > 0 .and. oGetPecas:aCols[oGetPecas:nAt,nVS3QTDAGU] > 0
	MsgStop(STR0225,STR0025) // Não é possível alterar um item com pedido de peças pendente.
	return .f.
endif
//
if nVS3QTDTRA > 0 .and. oGetPecas:aCols[oGetPecas:nAt,nVS3QTDTRA] > 0 .and. _cAuxReadVar $ "M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE"
	MsgStop(STR0225,STR0025) // Não é possível alterar um item com pedido de peças pendente.
	return .f.
endif

If !FM_PILHA("OX001RECALC") .and. Empty(M->VS1_CODVEN)
	If ( ( Readvar() == "M->VS3_GRUITE" .and. !Empty(M->VS3_GRUITE) ) .or. Readvar() == "M->VS3_CODITE" .and. !Empty(M->VS3_CODITE) )
		MsgStop(STR0392,STR0025) // Necessário informar o Vendedor antes dos Itens. / Atenção
		return .f.
	EndIf
EndIf

lMens := lMensagem
// Ponto de entrada antes do FieldOk
if lOX001AFP
	if !ExecBlock("OX001AFP",.f.,.f.)
		Return(.f.)
	Endif
Endif

// Verifica se é obrigatorio usar o inconveniente
if lInconveniente .and. lInconvObr .and. (M->VS1_TIPORC == "2" ) .and. !OX001INCOBR()
	Return(.f.)
endif
//

// Quando trocar o item deve deixar a TES em branco para recarregar com a TES do novo item informado
If _cAuxReadVar == "M->VS3_CODITE" .and. ( M->VS3_GRUITE + M->VS3_CODITE ) <> ( oGetPecas:aCols[oGetPecas:nAt,nVS3GRUite] + oGetPecas:aCols[oGetPecas:nAt, nVS3CODITE] ) .and. ! Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE])
	M->VS3_CODTES := oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES] := Space(TAMSX3("VS3_CODTES")[1])
Endif
//

If _cAuxReadVar == "M->VS3_CODTES" .and. ( M->VS3_GRUITE <> oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] .or. M->VS3_CODITE <> oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] )
	FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt) // Carrega M-> pois estava desposicionado o Item
EndIf
//
if Empty(M->VS3_CODITE) .and. ! Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE])
	M->VS3_CODITE := oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE]
endif

if Empty(M->VS3_GRUITE) .and. ! Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE])
	M->VS3_GRUITE := oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]
endif

// nao deixa preencher nenhum valor enquanto o grupo e o código do item estiverem em branco
If _cAuxReadVar != "M->VS3_GRUITE" .and.  _cAuxReadVar != "M->VS3_CODITE" .and. Empty(M->VS3_CODITE) .and. Empty(M->VS3_GRUITE)
	if !lOX001Auto
		MsgInfo(STR0035,STR0025) // Preencha o codigo da peca.
	endif
	return .f.
EndIf

// Validar Permissao do Usuario para utilizar o Almoxarifado
If _cAuxReadVar == "M->VS3_LOCAL" .and. !Empty(M->VS3_LOCAL) .and. !Empty(M->VS3_GRUITE+M->VS3_CODITE)
	SB1->(DbSetOrder(7))
	SB1->(MsSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE))
	If !MaAvalPerm( 3 , { M->VS3_LOCAL , SB1->B1_COD } )
		SB1->(DbSetOrder(1))
		return .f.
	EndIf
EndIf

If _cAuxReadVar == "M->VS3_GRUITE"
	// Não permite Verifica se estourou tamanho do Acols de Peças para de acordo com MV_NUMITEN #
	SBM->(dbSetOrder(1))
	SBM->(msSeek(xFilial("SBM")+M->VS3_GRUITE))
	if SBM->BM_TIPGRU $ "4 /7 "
		if !lOX001Auto
			MsgInfo( STR0336 ,STR0025) // "Grupo Inválido! Não é permitido informar Grupo de Veículos ou Serviços!"
		endif
		Return(.f.)
	Endif

	// ##############################################################################
	// Verifica se estourou tamanho do Acols de Peças para de acordo com MV_NUMITEN #
	// ##############################################################################
	if ! FS_QTDLIN("1")
		Return(.f.)
	Endif

	lValidarQtdeLin := .f.

	If ! Empty(M->VS1_PEDREF) .and. cMVMIL0011 == "1" // Utiliza nivel de atendimento 
		If lMensagem
			MsgAlert(STR0270,STR0025) // Não é permitido alterar o Grupo de Peças quando utilizado o Nível de Atendimento!
		EndIf
		return .f.
	Endif

	If Empty(M->VS3_FORMUL)
		if ! Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3FORMUL])
			M->VS3_FORMUL := oGetPecas:aCols[oGetPecas:nAt,nVS3FORMUL]
		else
			M->VS3_FORMUL := oGetPecas:aCols[oGetPecas:nAt,nVS3FORMUL] := FS_FORMULA(oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE])
		endif
	Endif

	lGruIteAlterado := (oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] <> M->VS3_GRUITE)

	oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] := M->VS3_GRUITE

	if empty(M->VS3_CODITE) .or. ! OX0010243_SeekSB1(M->VS3_GRUITE , M->VS3_CODITE )
		oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] := M->VS3_CODITE := space(TamSX3("VS3_CODITE")[1])
		oGetPecas:aCols[oGetPecas:nAt,nVS3DESITE] := M->VS3_DESITE := space(TamSX3("VS3_DESITE")[1])
		if nVS3KEYALT > 0
			oGetPecas:aCols[oGetPecas:nAt,nVS3KEYALT] := M->VS3_KEYALT := space(TamSX3("VS3_KEYALT")[1])
		endif

		if ! lPediVenda
			M->VS3_QTDEST := oGetPecas:aCols[oGetPecas:nAt,nVS3QTDEST] := 0
		endif
	else
		// Alteração do grupo encontrou outra correspondência. Faz algumas verificações e apenas altera os campos necessários
		_cAuxReadVar := "M->VS3_CODITE"
		lPesqSB1 := .f.
	endif

EndIf

If !FM_PILHA("OX001RECALC") .and. lVerPromo
	If M->VS1_TIPORC $ " P" .or. ( M->VS1_TIPORC == "1" .and. Empty(M->VS1_PEDREF) .and. M->VS1_STATUS $ " 0" ) // ( Pedido ou ( Orçamento Balcão que nao esta relacionado com Pedido e o status esta digitado ) )
		If ReadVar() $ "M->VS3_GRUITE/M->VS3_CODITE/M->VS3_QTDITE"
			If nVS3PESPRO > 0
				oGetPecas:aCols[oGetPecas:nAt,nVS3PESPRO] := M->VS3_PESPRO := "1" // Pesquisa Promoção
			EndIf
		EndIf
	EndIf
EndIf

If _cAuxReadVar == "M->VS3_CODITE" //.or. lGrAchou // Desafio: Descubra o que significa lGrAchou

	/*if lPesqSB1 .and. ! OX0010243_SeekSB1(M->VS3_GRUITE , M->VS3_CODITE)
		return .f.
	endif*/

	// ##############################################################################
	// Verifica se estourou tamanho do Acols de Peças para de acordo com MV_NUMITEN #
	// ##############################################################################
	if lValidarQtdeLin
		if ! FS_QTDLIN("1")
			Return(.f.)
		Endif
	Endif

	If !Empty(M->VS1_PEDREF) .and. cMVMIL0011 == "1"
		If lMensagem
			MsgAlert(STR0271,STR0025)
			return .f.
		EndIf
	Endif

	If lInconveniente .and. M->VS1_TIPORC == "2" .and. !Empty(cIncDefault) // Utiliza Inconveniente, Orcamento tipo Oficina e possui Inconveniente Default
		If len(oGetInconv:aCols) == 1 .and. Empty(oGetInconv:aCols[1,FG_POSVAR("VST_GRUINC","aHeaderI")]+oGetInconv:aCols[1,FG_POSVAR("VST_CODINC","aHeaderI")]+oGetInconv:aCols[1,FG_POSVAR("VST_DESINC","aHeaderI")])
			oGetInconv:aCols[1,FG_POSVAR("VST_SEQINC","aHeaderI")] := StrZero(1,TamSX3("VST_SEQINC")[1])
			oGetInconv:aCols[1,FG_POSVAR("VST_DESINC","aHeaderI")] := cIncDefault // SEM INSTALAR - MV_MIL0094
		EndIf
	EndIf

	oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] := M->VS3_GRUITE

	M->VS3_FORMUL := Space(TamSX3("VS3_FORMUL")[1])
	oGetPecas:aCols[oGetPecas:nAt,nVS3FORMUL] := M->VS3_FORMUL

	oGetPecas:aCols[oGetPecas:nAt,nVS3DESITE] := M->VS3_DESITE := SB1->B1_DESC
	If !lRecalc 
		oGetPecas:aCols[oGetPecas:nAt, nVS3LOCAL ]  := M->VS3_LOCAL  := OX0010105_ArmazemOrigem()
	EndIf
	oGetPecas:aCols[oGetPecas:nAt, nVS3CENCUS ] := M->VS3_CENCUS := SB1->B1_CC
	oGetPecas:aCols[oGetPecas:nAt, nVS3CONTA  ] := M->VS3_CONTA  := SB1->B1_CONTA
	oGetPecas:aCols[oGetPecas:nAt, nVS3ITEMCT ] := M->VS3_ITEMCT := SB1->B1_ITEMCC
	oGetPecas:aCols[oGetPecas:nAt, nVS3CLVL   ] := M->VS3_CLVL   := SB1->B1_CLVL

	oGetPecas:aCols[oGetPecas:nAt,nVS3LOCPRO  ] := M->VS3_LOCPRO := OX0010211_Retorna_LOCALI2( M->VS3_GRUITE , M->VS3_CODITE )
	
	If ! lRecalc

		OX0010273_InicializaPerDesPeca()

		// #################################
		// # Verifica Substituicao do Item #
		// #################################
		if ! lOX001Auto
			cCodSIte := FG_ITESUB(M->VS3_GRUITE+M->VS3_CODITE)
			if ValType(cCodSIte) == "A"
				M->VS3_GRUITE := cCodSIte[1]
				M->VS3_CODITE := cCodSIte[2]
			else
				M->VS3_CODITE := cCodSIte
			endif
		endif

		if lInconveniente
			//###################################################################################
			//# Chama a tela para Selecionar Inconveniente, se nao informado pelo Inconveniente #
			//###################################################################################
			OX001SELINCON("P")

			//###################################################################
			//# Verifica duplicidade com grupo / codigo do item e INCONVENIENTE #
			//###################################################################
			if lVldDPec .and. OX001PDUPL(oGetPecas:nAt,M->VS3_GRUITE ,M->VS3_CODITE ,M->VS3_GRUINC ,M->VS3_CODINC ,M->VS3_DESINC, M->VS3_SEQINC ,M->VS3_NUMLOT ,M->VS3_LOTECT , @nAuxLinDup)
				if !lOX001Auto .and. !lDupOrc
					MsgInfo(STR0037 + chr(13) + chr(13) + STR0146 + AllTrim(Str(nAuxLinDup)),STR0025)
				endif
				return .f.
			endif
		else
			//###########################################################
			//# Verifica duplicidade somente com grupo / codigo do item #
			//###########################################################
			if lVldDPec .and. OX001PDUPL(oGetPecas:nAt, M->VS3_GRUITE, M->VS3_CODITE,,,,,M->VS3_NUMLOT ,M->VS3_LOTECT ,@nAuxLinDup)
				if !lOX001Auto .and. !lDupOrc
					MsgInfo(STR0037 + chr(13) + chr(13) + STR0146 + AllTrim(Str(nAuxLinDup)),STR0025)
				endif
				return .f.
			endif
		endif

		if lRecompra
			// Posiciona no grupo da peca para verificar recompra (apenas itens originais)
			SBM->(dbSetOrder(1))
			SBM->(msSeek(xFilial("SBM")+M->VS3_GRUITE))
			if SBM->BM_PROORI <> "1"
				if !lOX001Auto
					MsgInfo( STR0040 ,STR0025)
				endif
				Return(.f.)
			Endif
		Endif

		// ############################# // isso aqui é uma verificação possivelmente desnessessária.
		// # Verifica Garantia do Item # // foi realizada para adequar o P10 às verificações que o AP5
		// ############################# // já fazia nos clientes antigos
		If M->VS1_TIPORC == "2"
			If !FG_GARANTIA( M->VS1_CHAINT , M->VS1_TIPTEM , M->VS3_GRUITE , M->VS3_CODITE , , dDataBase )
				Return(.f.)
			EndIf
		Endif

		if ! lKitChamada // Não é chamada recursiva do Kit ... 
			if OX0010253_Kit() // Se processou kits a funcao retorna .t. e neste caso nao pode continuar o processamento 
				// Recarrega as variaveis m-> pq as variaveis ficavam vazias depois que retorna da funcao do kit 
				FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
				return .t.
			endif
		endif

	Endif

	lCodIteAlterado := (oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] <> M->VS3_CODITE)

	oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] := M->VS3_GRUITE
	oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] := M->VS3_CODITE
	If Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3PECKIT])
		oGetPecas:aCols[oGetPecas:nAt,nVS3PECKIT] := "0"
	EndIf

	OX001PREPEC("", .t.)
	OX0010271_PercentualRemuneracao( .t. ) // Retorna o % de Remuneração
EndIf

if _cAuxReadVar == "M->VS3_VALPEC"
	VAI->(DBSetOrder(6))
	VAI->(mSSeek(xFilial("VAI") + M->VS1_CODVEN))
	do case
	case VAI->VAI_ALTVPC == "0" .or. Empty(VAI->VAI_ALTVPC)
		return .f.
	case VAI->VAI_ALTVPC == "2" .and. M->VS3_VALPEC < oGetPecas:aCols[oGetPecas:nAt,nVS3VALPEC]
		FMX_HELP("OX001ALTVPC2",STR0405) // "Usuário sem permissão para diminuir o preço da peça."
		return .f.
		
	case VAI->VAI_ALTVPC == "3" .and. M->VS3_VALPEC > oGetPecas:aCols[oGetPecas:nAt,nVS3VALPEC]
		FMX_HELP("OX001ALTVPC3",STR0406) // "Usuário sem permissão para aumentar o preço da peça."
		return .f.
	endcase 
endif


If _cAuxReadVar $ "M->VS3_QTDITE,M->VS3_QTD2UM,M->VS3_CODTES,M->VS3_OPER" // tes e oper aqui é por conta do calculo fiscal do Tipo de Frete

	if lPediVenda .and. !INCLUI .and. !lLibPv
		If lAltPedVda .and. oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_QTDPED","aHeaderP")] != 0 // Não pode Alterar registro do Pedido incluido anteriormente
			// 06/01/2014 - Manoel - Conforme conversa com Lino e aval do Ricardo, liberamos a alteração da Quantidade mesmo depois da gravação do Pedido
			//return .f.
		Else
			if M->VS3_QTDITE > oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_QTDPED","aHeaderP")] .and. oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_QTDINI","aHeaderP")] != 0 .and. oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_QTDPED","aHeaderP")] > 0
				MsgStop(STR0267)
				return .f.
			endif
		Endif
	endif

	if SB1->B1_GRUPO <> M->VS3_GRUITE .OR. SB1->B1_CODITE <> M->VS3_CODITE
		SB1->(DBSetOrder(7))
		SB1->(dbSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE))
	endif

	// só entra aqui se:
	// não for Pedido e
	// for um Orçamento que originou-se de um Pedido e que não esteja com o Status 5 (divergencia) e
	// Não for Inclusão
	if !lPediVenda .and. (!Empty(M->VS1_PEDREF).and.VS1->VS1_STATUS<>'5') .and. !INCLUI
		If (_cAuxReadVar == "M->VS3_CODTES" .or. _cAuxReadVar == "M->VS3_OPER")
			If _cAuxReadVar == "M->VS3_OPER"
				M->VS3_CODTES := MaTesInt(2,M->VS3_OPER,M->VS1_CLIFAT,M->VS1_LOJA,"C",SB1->B1_COD)
			Endif
			SF4->(dbseek(xFilial("SF4")+M->VS3_CODTES))
			If SF4->F4_ESTOQUE <> "S"
				Help(" ",1,"A410TEEST")
				return .f.
			Endif
		Else
			If lMensagem
				//MsgStop(STR0273) // Não é permitido alterar a quantidade do Pedido
				FMX_HELP("OX001ERR002",STR0273)  // Não é permitido alterar a quantidade do Pedido // Não é permitido alterar a quantidade do Pedido
				return .f.
			EndIf
		Endif
	Endif

	If _cAuxReadVar == "M->VS3_QTD2UM"
		M->VS3_QTDITE := Round(Iif(SB1->B1_TIPCONV=="M",M->VS3_QTD2UM/SB1->B1_CONV,M->VS3_QTD2UM*SB1->B1_CONV),TamSX3("VS3_QTDITE")[2])
	EndIf

	// Verificação para mostrar mensagem peça por peça
	// Ou apenas unificar os dados (a mensagem será mostrada fora do loop das peças)
	If (_cAuxReadVar == "M->VS3_QTD2UM" .Or. _cAuxReadVar == "M->VS3_QTDITE")

		if M->VS3_QTDITE == 0
			If !lLibPV
				FMX_HELP("OX001ERR005",STR0166) // "A quantidade e o valor do item não podem estar zerados."
			Endif
			return .f.
		endif

		If M->VS1_TIPORC != "2"
			If M->VS3_QTDITE < SB1->B1_LOTVEN .And. SB1->B1_LOTVEN > 0
				If !lMsgLotMin
					MsgInfo(STR0180 + " (" + Alltrim(STR(SB1->B1_LOTVEN)) + "). " + STR0181, STR0025) // Quantidade insuficiente para venda / Verifique no cadastro de peças a quantidade mínima para venda (Qtde Venda). / Atenção
					Return .f.
				Else
					cMsgLotMin += (Alltrim(SB1->B1_GRUPO) + " " + Alltrim(SB1->B1_CODITE) + " (" + Alltrim(STR(SB1->B1_LOTVEN)) + ") " + CHR(13) + CHR(10))
				Endif
			EndIf
		EndIf
	EndIf

	//OFIOM020 - Funcao valida a quantidade maxima do componente por modelo do veiculo.
	If !VALPMOD020( M->VS3_GRUITE , M->VS3_CODITE , M->VS3_QTDITE , "1" , "1" )
		Return(.f.)
	EndIF

	oGetPecas:aCols[oGetPecas:nAt,nVS3QTDITE] := M->VS3_QTDITE

	nSdoPecas := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+M->VS3_LOCAL, .t. )

	If _cAuxReadVar == "M->VS3_QTDITE"
		If BlqInvent( SB1->B1_COD, M->VS3_LOCAL)
			MsgInfo(STR0314 +SB1->B1_COD +" - "+ SB1->B1_DESC +STR0315,STR0025)
		Endif
	EndIf
	// obsoleto
	if lCHKPRO110   // <<<<---- O B S O L E T O
		if !ExecBlock("CHKPRO110",.f.,.f.)
			Return(.f.)
		Endif
	Endif
	// verificação de saldo de pecas
	if lOX001VSP
		if !ExecBlock("OX001VSP",.f.,.f.)
			Return(.f.)
		Endif
	Endif

	// Tratamento de transferencia caso o saldo nao esteja disponivel e faseorc tenha T
	//
	// Dependendo do TES, questiona-se o saldo da peca
	SF4->(dbSeek(xFilial("SF4")+M->VS3_CODTES))
	if SF4->F4_ESTOQUE == "S" .and. cVS1Status != "5"
		if !lOX001Auto


			nEstSeg := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ESTSEG")
			nQtdOrc := M->VS3_QTDITE-M->VS3_QTDRES

			If !OX0010335_ValidaQTDOrcamento(M->VS1_NUMORC,M->VS3_SEQUEN,M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE)
				Return .f.
			EndIf

			if lAprMsg .and. nQtdOrc > 0 // o M->VS3_QTDITE > 0 vai funcionar para o nível de atendimento, mostrando mensagem somente depois de mostrado o saldo
				if nQtdOrc > nSdoPecas
					if !lAgrMsgSld
						MsgInfo( STR0041 +": "+alltrim(SB1->B1_DESC)+" "+ STR0042+": "+str(nSdoPecas,6)+" "+ STR0182, STR0025 )
					else
						AAdd( aProdSdEst, { alltrim(SB1->B1_GRUPO);
										  ,	alltrim(SB1->B1_COD);
										  , alltrim(SB1->B1_DESC);
										  , M->VS3_QTDITE;
										  , nSdoPecas } ) 	
					endif	
				elseif nQtdOrc > (nSdoPecas-nEstSeg)
					MsgInfo( STR0041+": "+SB1->B1_GRUPO + " " + alltrim(SB1->B1_CODITE)+ ": " + alltrim(SB1->B1_DESC)+" "+ STR0043;
					+": "+str(nSdoPecas-nEstSeg,6)+" "+STR0044 , STR0025 )
				endif
			endif
			if At("T",GetNewPar("MV_FASEORC","0FX")) > 0 .and. nQtdOrc > nSdoPecas .AND. M->VS1_TIPORC != "2" // removi a checagem de nivel de atendimento devido ao novo tratamento
				if MsgYesNo(STR0243,STR0025)
			   		aPedTra2 := OXA020LBOX(xFilial("VS1"),SB1->B1_GRUPO,SB1->B1_CODITE, nQtdOrc - (nSdoPecas-nEstSeg))
					if ! Empty(aPedTra2)

						if lPediVenda
							For nCntFor4 := 1 to Len(aPedTra2) // [4]-qtd | [5]-filial
								OX0010074_AdicionaNATransferencia(oGetPecas:nAt, aPedTra2[nCntFor4])
							Next
						endif

						nQtdPTra := 0
						for nCntFor := 1 to Len(aPedTra2)
							nQtdPTra += aPedTra2[nCntFor,4]
						next
						M->VS3_QTDTRA := nQtdPTra
						oGetPecas:aCols[oGetPecas:nAt,nVS3QTDTRA] := nQtdPTra
						for nCntFor4 := 1 to Len (aPedTra2)
							nPos := aScan(aPedTransf,{|x| x[1]+x[2]+x[5] == aPedTra2[nCntFor4,1]+aPedTra2[nCntFor4,2]+aPedTra2[nCntFor4,5]})
							if nPos == 0
								aAdd(aPedTransf,aPedTra2[nCntFor4])
							else
								aPedTransf[nPos,4] = aPedTra2[nCntFor4,4]
							endif
						next
					endif
				endif
			endif
		endif
	Endif

EndIf

If (_cAuxReadVar $ "M->VS3_VALPEC,M->VS3_QTDITE,M->VS3_QTD2UM,M->VS3_PERDES,M->VS3_VALDES,M->VS3_CODTES,M->VS3_OPER,M->VS3_FORMUL")


	if _cAuxReadVar == "M->VS3_FORMUL"
		If OFP8600016 .And. !OFP8600016_VerificacaoFormula(M->VS3_FORMUL)
			Return .f. // A mensagem já é exibida dentro da função
		EndIf

		if !Empty(M->VS1_TIPTEM)
			VOI->(DBSetOrder(1))
			VOI->(MSSeek(xFilial("VOI")+M->VS1_TIPTEM))
			//
			if VOI->VOI_ALTVAL == "0" .and. M->VS3_FORMUL != VOI->VOI_VALPEC
				FMX_HELP("OX001ERR003",STR0232) // O tipo de tempo escolhido não permite a alteração de fórmulas.
				return .f.
			endif
		endif

		if ! lRecalc
			OX0010273_InicializaPerDesPeca()
		endif

	endif

	 // Recalcula preco quando altera a quantidade por causa dos criterios de desconto de promocao 
	If _cAuxReadVar $ "M->VS3_QTDITE,M->VS3_QTD2UM,M->VS3_CODTES,M->VS3_OPER,M->VS3_FORMUL"
		OX0010235_Atualiza_Preco_Peca(.f.,_cAuxReadVar)
	EndIf


	if _cAuxReadVar == "M->VS3_VALDES" .and. M->VS3_VALDES >= (M->VS3_QTDITE * M->VS3_VALPEC)
		FMX_HELP("OX001ERR004",STR0409,STR0410)  // "Valor de desconto maior que valor da peça." // "Informe um valor de desconto menor que o valor unitário da peça."
		return .f.
	endif
	
	SB1->(DBSetOrder(7))
	SB1->(MsSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE))

	If (_cAuxReadVar == "M->VS3_VALPEC")
		OX0010273_InicializaPerDesPeca()
		M->VS3_PROMOC := oGetPecas:aCols[oGetPecas:nAt,nVS3PROMOC] := "0"
	EndIf
	
	// Zera desconto 
	if M->VS3_VALDES == 0 .and. M->VS3_PERDES == 0
		M->VS3_VALLIQ := M->VS3_VALPEC
		M->VS3_PERDES := 0
		M->VS3_VALDES := 0
		M->VS3_VALTOT := Round( (M->VS3_VALPEC * M->VS3_QTDITE) , 2 )
	else

		// Verifica se o criterio de desconto permite informar desconto
		lCalcDesconto := .t.
		if _cAuxReadVar $ "M->VS3_PERDES/M->VS3_VALDES" .and. M->VS3_PROMOC == "1" .and. (M->VS3_VALDES > 0 .or. M->VS3_PERDES > 0)
			aPromocao := OX0010283_Criterio_Promocao_Peca()

			// 0 = NAO PODE DAR DESCONTO EM PROMOCAO
			If Empty(aPromocao) .or. aPromocao[4] == "0" 
				if !lOX001Auto
					MsgInfo(STR0102 + Alltrim(SB1->B1_GRUPO) + " " + Alltrim(SB1->B1_CODITE) + " - " + Alltrim(SB1->B1_DESC) + ">> "+STR0361, STR0025) // Produto <<  >> está em Promoção que não permite Desconto! / Atencao
				endif

				M->VS3_VALDES := 0
				M->VS3_PERDES := 0
				M->VS3_VALLIQ := M->VS3_VALPEC
				M->VS3_VALTOT := Round( (M->VS3_VALPEC * M->VS3_QTDITE) , 2 )

				if nVS3SEQVEN > 0
					oGetPecas:aCols[oGetPecas:nAt,nVS3SEQVEN] := M->VS3_SEQVEN := IIf( empty(aPromocao) , Space(len(M->VS3_SEQVEN)), aPromocao[5] )
				endif

				lCalcDesconto := .f. // Como zeramos desconto, nao ha necessidade de calcular os valores 
			EndIf
		endif

		if lCalcDesconto
			OX0010263_CalculaDesconto(_cAuxReadVar)
		endif
		If M->VS3_VALTOT <= 0
			MsgInfo(STR0166,STR0025)  // "A quantidade e o valor do item não podem estar zerados."
			Return .f.
		Endif
	endif

	oGetPecas:aCols[oGetPecas:nAt,nVS3PERDES] := M->VS3_PERDES
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALPEC] := M->VS3_VALPEC
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALDES] := M->VS3_VALDES
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALTOT] := M->VS3_VALTOT
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALLIQ] := M->VS3_VALLIQ
	
	OX001PREPEC("", .f.)
	OX0010271_PercentualRemuneracao( .t. ) // Retorna o % de Remuneração
EndIf

If _cAuxReadVar == "M->VS3_INSTAL"
	if M->VS1_TIPORC == "2" // Orcamento de Oficina
	
		If M->VS3_INSTAL == "1"
			If oGetPecas:aCols[oGetPecas:nAt,nVS3QTDITE] <= 0
				MsgInfo(STR0051,STR0025)
				Return .f.
			EndIf
			If ( Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC] ) .or. Alltrim(oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC]) == cIncDefault ) // Instalar Peça? 1-Sim
				DbSelectArea("SB1")
				DbSetOrder(7)
				MsSeek( xFilial("SB1") + oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] + oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] )
				DbSetOrder(1)
				nVlrSrv := FG_VALPEC(,GetNewPar("MV_MIL0100",'""'),SB1->B1_GRUPO,SB1->B1_CODITE,,.f.,.t.)
				If nVlrSrv > 0
					cDescInconv := left(FwNoAccent(STR0319)+" "+SB1->B1_DESC+space(100),TamSX3("VST_DESINC")[1]) // INSTALAR
					If !OX001INCON( 3 , "" , "" , cDescInconv , "D" , .t. , nVlrSrv )
					   Return .f.
					EndIf
				EndIf
			EndIf
	
		ElseIf M->VS3_INSTAL == "0" // Instalar Peça? 0-Nao
			If !Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC]) .and. Alltrim(oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC]) <> cIncDefault
				If MsgYesNo(STR0318,STR0025) // Deseja excluir o Servico relacionado a instalacao da Peca? / Atencao
					// Salva posição na getdados
					nPosSlv := oGetServ:nAt
					// ascan na acols de servico com o inconveniente da peca
					nPos := aScan(oGetServ:aCols, {|x| x[FG_POSVAR("VS4_SEQINC","aHeaderS")] == oGetPecas:aCols[oGetPecas:nAt,nVS3SEQINC] })
					//
					If nPos > 0
						oGetServ:aCols[nPos,len(oGetServ:aCols[nPos])] := .t. // apagar servico
						oGetServ:aCols[nPos,FG_POSVAR("VS4_SEQINC","aHeaderS")] := ""
						oGetServ:aCols[nPos,FG_POSVAR("VS4_DESINC","aHeaderS")] := ""
						oGetServ:oBrowse:Refresh()
					EndIf
					n := oGetServ:nAt := nPos
					OX001SrvFis()
					MaFisDel(n,oGetServ:aCols[oGetServ:nAt,Len(oGetServ:aCols[oGetServ:nAt])])
					OX001FisSrv()
					n := oGetServ:nAt := nPosSlv
					//
					// ascan na acols de inconveniente com o inconveniente da peca
					nPos := aScan(oGetInconv:aCols, {|x| x[FG_POSVAR("VST_SEQINC","aHeaderI")] == oGetPecas:aCols[oGetPecas:nAt,nVS3SEQINC] })
					If nPos > 0
						oGetInconv:aCols[nPos,len(oGetInconv:aCols[nPos])] := .t. // apagar inconveniente
						oGetInconv:oBrowse:Refresh()
					EndIf
					// trocar inconveniente da peca para o inconveniente default (sem instalacao)
					nPos := aScan(oGetInconv:aCols, {|x| Alltrim(x[FG_POSVAR("VST_DESINC","aHeaderI")]) == cIncDefault })
					If nPos > 0
						oGetPecas:aCols[oGetPecas:nAt,nVS3SEQINC] := oGetInconv:aCols[nPos,FG_POSVAR("VST_SEQINC","aHeaderI")]
						oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC] := oGetInconv:aCols[nPos,FG_POSVAR("VST_DESINC","aHeaderI")]
						oGetPecas:oBrowse:Refresh()
					EndIf
				Else
					Return .f.
				EndIf
			EndIf
		Else
			Return .f.
		EndIf
	EndIf
EndIf

if M->VS1_TIPORC == "2"

	If ! lRecalc
		If _cAuxReadVar == "M->VS3_DEPINT" .or. _cAuxReadVar == "M->VS3_DEPGAR"
			// Valida Tipo de Tempo de Peças
			DBSelectArea("VOI")
			DBSetOrder(1)
			DBSeek(xFilial("VOI")+M->VS1_TIPTEM)
			if VOI->VOI_SITTPO == "3"
				// Valida Departamento Interno
				If _cAuxReadVar == "M->VS3_DEPINT"
					For nCntFor := 1 to len(oGetPecas:aCols)
						If !oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])]// .and. oGetPecas:nAt <> nCntFor
							if AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPINT]) <> M->VS3_DEPINT .and. ;
								!Empty(AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPINT]))
								if MsgYEsNo(STR0251+"'"+M->VS3_DEPINT+"'"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0250)
									OF001DEPINT()
									Return .t.
								Else
									Return .f.
								Endif
							endif
						endif
					Next
				Endif
				// Valida Departamento Garantia
				If _cAuxReadVar == "M->VS3_DEPGAR"
					For nCntFor := 1 to len(oGetPecas:aCols)
						If !oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])] .and. oGetPecas:nAt <> nCntFor
							if AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPGAR]) <> M->VS3_DEPGAR .and. ;
								!Empty(AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPGAR]))
								if MsgYEsNo(STR0251+"'"+M->VS3_DEPINT+"'"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0250)
									OF001DEPGAR()
									Return .t.
								Else
									Return .f.
								Endif
							endif
						endif
					Next
				Endif
			endif
		Endif
	Endif

Endif

// Verifica Custo dos Itens
If ! lRecalc

	If lVerPromo .and. ReadVar() $ "M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,"
		If M->VS1_TIPORC $ " P" .or. ( M->VS1_TIPORC == "1" .and. Empty(M->VS1_PEDREF) .and. M->VS1_STATUS $ " 0" ) // ( Pedido ou ( Orçamento Balcão que nao esta relacionado com Pedido e o status esta digitado ) )
			OX0010261_Verifica_Saldo_Promocao()
		EndIf
	EndIf

	If _cAuxReadVar $ "M->VS3_VALPEC,M->VS3_QTDITE,M->VS3_QTD2UM,M->VS3_PERDES,M->VS3_VALDES,M->VS3_FORMUL,M->VS3_OPER,M->VS3_CODTES,M->VS3_SITTRI" .and. OX001ExistPecFis(oGetPecas:nAt)

		M->VS3_VALPIS := MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
		M->VS3_VALCOF := MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
		M->VS3_ICMCAL := MaFisRet(n,"IT_VALICM")
		M->VS3_VALCMP := MaFisRet(n,"IT_VALCMP")
		M->VS3_DIFAL  := MaFisRet(n,"IT_DIFAL")
		M->VS3_PICMSB := MaFisRet(n,"IT_ALIQSOL")
		M->VS3_BICMSB := MaFisRet(n,"IT_BASESOL")
		M->VS3_VICMSB := MaFisRet(n,"IT_VALSOL")
		M->VS3_PIPIFB := MaFisRet(n,"IT_ALIQIPI")
		M->VS3_VIPIFB := MaFisRet(n,"IT_VALIPI")
		M->VS3_BASIRR := MaFisRet(n,"IT_BASEIRR")
		M->VS3_ALIIRR := MaFisRet(n,"IT_ALIQIRR")
		M->VS3_VALIRR := MaFisRet(n,"IT_VALIRR")
		M->VS3_BASCSL := MaFisRet(n,"IT_BASECSL")
		M->VS3_ALICSL := MaFisRet(n,"IT_ALIQCSL")
		M->VS3_VALCSL := MaFisRet(n,"IT_VALCSL")

		oGetPecas:aCols[ oGetPecas:nAt , nVS3VALPIS ] := M->VS3_VALPIS
		oGetPecas:aCols[ oGetPecas:nAt , nVS3VALCOF ] := M->VS3_VALCOF
		oGetPecas:aCols[ oGetPecas:nAt , nVS3ICMCAL ] := M->VS3_ICMCAL
		oGetPecas:aCols[ oGetPecas:nAt , nVS3PICMSB ] := M->VS3_PICMSB
		oGetPecas:aCols[ oGetPecas:nAt , nVS3VICMSB ] := M->VS3_VICMSB
		oGetPecas:aCols[ oGetPecas:nAt , nVS3BICMSB ] := M->VS3_BICMSB
		oGetPecas:aCols[ oGetPecas:nAt , nVS3BASIRR ] := M->VS3_BASIRR
		oGetPecas:aCols[ oGetPecas:nAt , nVS3ALIIRR ] := M->VS3_ALIIRR
		oGetPecas:aCols[ oGetPecas:nAt , nVS3VALIRR ] := M->VS3_VALIRR
		oGetPecas:aCols[ oGetPecas:nAt , nVS3BASCSL ] := M->VS3_BASCSL
		oGetPecas:aCols[ oGetPecas:nAt , nVS3ALICSL ] := M->VS3_ALICSL
		oGetPecas:aCols[ oGetPecas:nAt , nVS3VALCSL ] := M->VS3_VALCSL
		If FG_POSVAR("VS3_PIPIFB","aHeaderP") > 0 .and. FG_POSVAR("VS3_VIPIFB","aHeaderP") > 0
			oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_PIPIFB","aHeaderP")] := M->VS3_PIPIFB
			oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_VIPIFB","aHeaderP")] := M->VS3_VIPIFB
		ENDIF
		
		OX001FisPec()
	Endif

	If _cAuxReadVar == "M->VS3_LOCAL"
		If OX0010016_MostraQuantidadeEmEstoque(oGetPecas:nAt, M->VS1_TIPORC)
			SB1->(DBSetOrder(7))
			SB1->(MsSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE))
			nSdoPecas := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+M->VS3_LOCAL, .f. )
	
			M->VS3_QTDEST := nSdoPecas
			oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_QTDEST","aHeaderP")] := M->VS3_QTDEST
		EndIf
	Endif

	//
	If ExistBlock("OX001PPC")
		ExecBlock("OX001PPC",.f.,.f.)
	EndIf
	//
	OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
	//
Else

	If _cAuxReadVar $ "M->VS3_CODTES"
		OX001PecFis()
		OX001RecFis("IT_TES",M->VS3_CODTES) // Manoel 14/06/2016
		M->VS3_PICMSB := MaFisRet(n,"IT_ALIQSOL")
		M->VS3_BICMSB := MaFisRet(n,"IT_BASESOL")
		M->VS3_VICMSB := MaFisRet(n,"IT_VALSOL")
		M->VS3_PIPIFB := MaFisRet(n,"IT_ALIQIPI")
		M->VS3_VIPIFB := MaFisRet(n,"IT_VALIPI")
		oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_PICMSB","aHeaderP")] := M->VS3_PICMSB
		oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_VICMSB","aHeaderP")] := M->VS3_VICMSB
		oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_BICMSB","aHeaderP")] := M->VS3_BICMSB
		If FG_POSVAR("VS3_PIPIFB","aHeaderP") > 0 .and. FG_POSVAR("VS3_VIPIFB","aHeaderP") > 0
			oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_PIPIFB","aHeaderP")] := M->VS3_PIPIFB
			oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_VIPIFB","aHeaderP")] := M->VS3_VIPIFB
		Endif
		OX001FisPec()
	Endif

	OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)


Endif

if !lOX001Auto
	n := oGetPecas:nAt
	oGetPecas:oBrowse:Refresh()
	If lInconveniente
		oGetInconv:oBrowse:Refresh()
	EndIf
endif
//

Return .t.

/*/{Protheus.doc} OX0010243_SeekSB1
Posiciona na SB1

@author Rubens
@since 27/10/2023
@version 1.0

@type function
/*/
Static Function OX0010243_SeekSB1(cGruIteSeek, cCodIteSeek)
	default cCodIteSeek := ""

	DbSelectArea("SB1")
	DbSetOrder(7)
	if ! MsSeek( xFilial("SB1") + cGruIteSeek + cCodIteSeek )
		FMX_HELP("OX001ERR001",STR0036 + CRLF + CRLF + RetTitle("B1_CODITE") + ": " + cGruIteSeek + " - " + cCodIteSeek ) // "Produto inexistente."
		Return .f.
	endif

	// Verifica se o item esta bloqueado
	if SB1->B1_MSBLQL == "1"
		HELP(" ",1,"REGBLOQ",,"SB1" + chr(13) + chr(10) + AllTrim(RetTitle("B1_COD")) + ": " + SB1->B1_COD,3,0)
		Return .f.
	endif

Return .t.


/*/{Protheus.doc} OX0010253_Kit
Adiciona itens do Kit na grid

@author Rubens
@since 27/10/2023
@version 1.0

@type function
/*/
Static Function OX0010253_Kit()

	Local nValKit  := nPDsKit := nValVdK := 00
	Local cTipOperac  := ""
	Local lKitImp  := .t.
	Local lExibeKit := .t.

	local nPosGetPecas := oGetPecas:nAt

	local nCntFor
	local nCntFor2
	local nCntFor3

	// #################################
	// # Chamada da Consulta de KITS   #
	// #################################
	// precisamos verificar se o vetor está preenchido pois se estiver significa que o programa chegou aqui em virtude de uma
	// chamada anterior do kit e portanto não pode entrar novamente (loop infinito)
	if Len(aItensKit) == 0 .and. !lOX001Auto  .and. IIF(lInconveniente,( Empty(M->VS3_CODINC) .and. Empty(M->VS3_DESINC) ),.t.)

		cReadTmp  := __readvar
		If ExistBlock("OX001PIK") // PE para falar se permite importar Kit para um determinado Item (linha da grid de Pecas)
			lKitImp := ExecBlock("OX001PIK",.f.,.f.,)
		EndIf
		If ExistBlock("OX001VKT") // PE para validar se deve exibir a tela de consulta de kit, ao retornar .T. ou .F.
			lExibeKit := ExecBlock("OX001VKT",.f.,.f., {M->VS3_GRUITE, M->VS3_CODITE})
		Endif
		If lExibeKit
			aItensKit := OFIOC040(M->VS3_GRUITE, M->VS3_CODITE, lKitImp)
		Endif

		__readvar := cReadTmp
		// Caso existam kits, deve-se setar o parâmetro de rotina automática para preencher os itens
		nValKit := 0
		nPDsKit := 0
		
		if Len(aItensKit) > 0
		
			lOX001Auto := .t.
			lPrimLinha := .t.
		
			dbSelectArea("VEH")
			dbSetOrder(1)
			dbSeek(xFilial("VEH")+aItensKit[1,7])
		
			nPDsKit := VEH->VEH_PERDES // Perdentual de Desconto
			nValKit := VEH->VEH_VALKIT // Valor do Kit
			nValVdK := 0 // Somatoria dos valores de venda dos itens do KIT
			nValPecKit := 0
		
			If nValKit > 0

				nPDsKit := 0 // Zera percentual pois o desconto sera por valor

				// aItensKit
				//   [4] - Quantidade ja multiplicada pela quantidade do kit
				//   [8] - Quantidade de kit a serem impotadas 
				//   criada mais 4 colunas na array, sendo 
				//   [1] - Valor de venda da peca
				//   [2] - Valor total da peca por KIT
				//   [3] - Percentual da peca no valor total do KIT
				//   [4] - Valor do Desconto ja multiplicada pela quantidade de KIT a ser importada para informar no campo de desconto do orcamento (VS1_VALDES)

				nPosCtrl := Len(aItensKit[1])
				for nCntFor := 1 to Len(aItensKit)

					M->VS3_FORMUL := FS_FORMULA(aItensKit[nCntFor,1])

					nValPecKit := FG_VALPEC(;
						M->VS1_TIPTEM,;   // cTipTem
						"M->VS3_FORMUL",; // cVarFormula
						aItensKit[nCntFor,1],;   // cGruIte
						aItensKit[nCntFor,2],;   // cCodIte
						,;                // cVarValor
						.f.,;             // lWhen
						.t.)              // lValor

					nValVdK += Round(nValPecKit * (aItensKit[nCntFor,4] / aItensKit[nCntFor,8]),2)

					aSize(aItensKit[nCntFor], nPosCtrl + 4 )
					aItensKit[nCntfor,nPosCtrl + 1] := nValPecKit
					aItensKit[nCntfor,nPosCtrl + 2] := Round(nValPecKit * (aItensKit[nCntFor,4] / aItensKit[nCntFor,8]),2)

				Next

				// Descobrindo percentual de participacao de cara peca no total do kit 
				aSort(aItensKit,,, { |x,y| x[nPosCtrl + 2] > y[nPosCtrl + 2] })
				For nCntFor := 1 to Len(aItensKit)
					aItensKit[nCntfor,nPosCtrl + 3] := aItensKit[nCntfor,nPosCtrl + 2] / nValVdK
				Next nCntFor

				// Verificando qual valor de desconto deve ser aplicado em cada item
				nValKitDescRat := (nValVdK - nValKit)
				nValRateio := 0
				nDecimalVS3ValDes := TamSX3("VS3_VALDES")[2]
				For nCntFor := 1 to Len(aItensKit)
					aItensKit[nCntfor,nPosCtrl + 4] := Round((nValKitDescRat * aItensKit[nCntfor,nPosCtrl + 3]) * aItensKit[nCntFor,8] , nDecimalVS3ValDes)
					nValRateio += Round((nValKitDescRat * aItensKit[nCntfor,nPosCtrl + 3]), nDecimalVS3ValDes)
				Next nCntFor

				// Se houver diferenca de arredondamento, deve-se ajustar o valor do ultimo item
				If nValRateio <> nValKitDescRat
					aItensKit[1,nPosCtrl + 4] += Round((nValKitDescRat - nValRateio) * aItensKit[1,8], nDecimalVS3ValDes)
				endif

			Endif
			//
			OX001RefNF()
			//
			for nCntFor := 1 to Len(aItensKit)
				// verifica se o item já foi lancado no orcamento
				lAchouUm := .f.
				for nCntFor2 := 1 to Len(oGetPecas:aCols)
			
					// pula itens deletados
					if oGetPecas:aCols[nCntFor2,Len(oGetPecas:aCols[nCntFor2])]
						loop
					endif
			
					// se o item já foi lançado no orçamento deve-se apenas alterar a quantidade
					if aItensKit[nCntFor,1] == oGetPecas:aCols[nCntFor2,nVS3GRUITE] .and. aItensKit[nCntFor,2] == oGetPecas:aCols[nCntFor2,nVS3CODITE]
		
						// salva valores da acols para restauração
						nAtual := oGetPecas:nAt
						oGetPecas:nAt := nCntFor2
						n := nCntFor2

						// monta as variáveis de memória
						For nCntFor3:=1 to Len(aHeaderP)
							&("M->"+aHeaderP[nCntFor3,2]) := oGetPecas:aCols[oGetPecas:nAt,nCntFor3]
						next

						// atualiza quantidade
						M->VS3_QTDITE := aItensKit[nCntFor,4] + oGetPecas:aCols[nCntFor2,nVS3QTDITE]

						// executa o fieldok com os valores posicionados
						__ReadVar := "M->VS3_QTDITE"
						OX001FPOK(.f. /* lMensagem */ , /* lLibPv */ , .f. /* lRefNF */ , .f. /* lRecalc */ , /* lMsgLotMin */ , /* lAgrMsgSld  */ , /* aProdSdEst */ , .t. /* lKitChamada */ )
						
						// restaura a posição anterior da acols
						oGetPecas:nAt := nAtual
						n := nAtual
						
						lAchouUm := .t.
						exit

					endif

				next

				// se o item sofreu alteração de quantidade (já lançado) faz o loop
				if lAchouUm
					loop
				endif

				// quando o item é lançado pela primeira vez ele deve ocupar o lugar do item atual (kit)
				// caso contrário deve-se criar uma nova linha
				if ! lPrimLinha

					// adiciona a linha com os valores default
					AADD(oGetPecas:aCols,Array(nUsadoPX01+1))
					oGetPecas:aCols[Len(oGetPecas:aCols),nUsadoPX01+1]:=.F.
					For nCntFor2:=1 to nUsadoPX01
						If IsHeadRec(aHeaderP[nCntFor2,2])
							oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor2] := 0
						ElseIf IsHeadAlias(aHeaderP[nCntFor2,2])
							oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor2] := "VS3"
						Else
							oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor2] := CriaVar(aHeaderP[nCntFor2,2])
						EndIf
					Next
					oGetPecas:nAt := Len(oGetPecas:aCols)
					n := Len(oGetPecas:aCols)
				endif
				
				// monta o vetor com os itens necessários

				aVetCmp := {}
				aAdd(aVetCmp,{"VS3_GRUITE",aItensKit[nCntFor,1],M->VS3_GRUITE} )
				aAdd(aVetCmp,{"VS3_CODITE",aItensKit[nCntFor,2],M->VS3_CODITE} )

				DBSelectArea("SB1")
				DBSetOrder(7)
				dbSeek(xFilial("SB1")+aItensKit[nCntFor,1]+aItensKit[nCntFor,2])
				DBSetOrder(1)
				//
				// Verifica se existe o Tipo de Operação no Vetor de Retorno do KIT //
				cTipOperac := aItensKit[nCntFor,9]

				// Se Orcamento Oficina e NAO preencheu o Tipo de Operação na Tela de Kit //
				If M->VS1_TIPORC == "2" .and. Empty(cTipOperac)
					DBSelectArea("VOI")
					DBSetOrder(1)
					DBSeek(xFilial("VOI")+M->VS1_TIPTEM)
					if !Empty(VOI->VOI_CODOPE)
						cTipOperac := VOI->VOI_CODOPE
					EndIf
				EndIf

				// Calcular o TES Inteligente utilizando o Tipo de Operação //
				If !Empty(cTipOperac)
					cTesCmp := OX001TESINT(cTipOperac)
					If !Empty(cTesCmp)
						aItensKit[nCntFor,3] := cTesCmp // TES Inteligente
					EndIf
					aAdd(aVetCmp,{"VS3_OPER",cTipOperac,M->VS3_OPER} ) // Tipo de Operacao 
				EndIf
				aAdd(aVetCmp,{"VS3_CODTES",aItensKit[nCntFor,3],M->VS3_CODTES} ) // TES 
				//
				aAdd(aVetCmp,{"VS3_QTDITE",aItensKit[nCntFor,4],M->VS3_QTDITE} )
				//
				If nPDsKit > 0
					aAdd(aVetCmp,{"VS3_PERDES",nPDsKit,M->VS3_PERDES} )
				EndIf
				If nValKit > 0
					aAdd(aVetCmp,{"VS3_VALDES",aItensKit[nCntFor, nPosCtrl + 4],M->VS3_VALDES} )
				Endif

				RegToMemory("VS3",.t.)

				for nCntFor2 := 1 to Len(aVetCmp)

					__ReadVar := "M->"+aVetCmp[nCntFor2,1]
					&("M->"+aVetCmp[nCntFor2,1]) := aVetCmp[nCntFor2,2]
					oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR(aVetCmp[nCntFor2,1],"aHeaderP")] := aVetCmp[nCntFor2,2]

					if ! OX001FPOK(.f. /* lMensagem */ , /* lLibPv */ ,.f. /* lRefNF */ ,.f. /* lRecalc */ , /* lMsgLotMin */ , /* lAgrMsgSld  */ , /* aProdSdEst */ , .t. /* lKitChamada */ )

						// se o fieldok retornar falso deve-se restaurar a linha anterior (primeira linha) ou exluir a linha (demais linhas)
						if !lPrimLinha
							aSize(oGetPecas:aCols,Len(oGetPecas:aCols)-1)
							For nCntFor3:=1 to Len(aHeaderP)
								&("M->"+aHeaderP[nCntFor3,2]) := oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor3]
							next
						else
							M->VS3_GRUITE := aVetCmp[aScan(aVetCMP,{|x| x[1] == "VS3_GRUITE"}),3]
							M->VS3_CODITE := aVetCmp[aScan(aVetCMP,{|x| x[1] == "VS3_CODITE"}),3]
							M->VS3_CODTES := aVetCmp[aScan(aVetCMP,{|x| x[1] == "VS3_CODTES"}),3]
							M->VS3_QTDITE := aVetCmp[aScan(aVetCMP,{|x| x[1] == "VS3_QTDITE"}),3]
							if asCan(aVetCMP,{|x| x[1] == "VS3_FORMUL"}) <> 0
								M->VS3_FORMUL := aVetCmp[asCan(aVetCMP,{|x| x[1] == "VS3_FORMUL"}),3]
							else
								M->VS3_FORMUL := space(len(M->VS1_FORMUL))
							endif
							if asCan(aVetCMP,{|x| x[1] == "VS3_PERDES"}) <> 0
								M->VS3_PERDES := aVetCmp[asCan(aVetCMP,{|x| x[1] == "VS3_PERDES"}),3]
							else
								M->VS3_PERDES := 0
							endif
							M->VS3_OPER   := aVetCmp[asCan(aVetCMP,{|x| x[1] == "VS3_OPER"})  ,3]
						endif
						oGetPecas:nAt := Len(oGetPecas:aCols)
						exit
					endif

				next

				// Ajusta sequencia da VS3
				OX0010163_SequenciaVS3()

				lPrimLinha := .f.
			next

			// caso ainda esteja na primeira linha significa que todas os itens já estavam no orçamento ou nenhum item deu certo
			if lPrimLinha .and. (Len(oGetPecas:aCols) > 0 .and. Empty(oGetPecas:aCols[1,nVS3CODITE]))
				aSize(oGetPecas:aCols,Len(oGetPecas:aCols)-1)
			endif
			
			for nCntFor := 1 to Len(aItensKit)
				for nCntFor2 := 1 to Len(oGetPecas:aCols)
					// pula itens deletados
					
					if !oGetPecas:aCols[nCntFor2,Len(oGetPecas:aCols[nCntFor2])]
						// se o item já foi lançado no orçamento deve-se apenas alterar a quantidade
						if aItensKit[nCntFor,1] == oGetPecas:aCols[nCntFor2,nVS3GRUITE] .and.;
							aItensKit[nCntFor,2] == oGetPecas:aCols[nCntFor2,nVS3CODITE]
							
							oGetPecas:aCols[nCntFor2,nVS3PECKIT] := aItensKit[nCntFor,10]

							Exit
						Endif
					Endif
				Next
			Next
			// zera o aItensKit e atualiza os valores de tela e acols
			aItensKit := {}
			lOX001Auto := .f.
			OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
			oGetPecas:GoTo(nPosGetPecas)
			return .t.
		else
			// Verifica se o item consta em um kit já lançado no orçamento
			if !lOX001Auto .AND. lExibeKit
				DBSelectArea("VE8")
				DBSetOrder(2)
				if DBSeek(xFilial("VE8")+M->VS3_GRUITE+M->VS3_CODITE)
					while !eof() .and. xFilial("VE8")+M->VS3_GRUITE+M->VS3_CODITE == VE8->VE8_FILIAL+VE8->VE8_GRUITE+VE8->VE8_CODITE
						for nCntFor := 1 to len(oGetPecas:aCols)
							If !oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])]
								if ALLTRIM(VE8->VE8_GRUKIT) + ALLTRIM(VE8->VE8_CODKIT) == AllTrim(oGetPecas:aCols[nCntFor,nVS3GRUITE]) + AllTrim(oGetPecas:aCols[nCntFor,nVS3CODITE])
									MsgInfo(STR0178+ALLTRIM(VE8->VE8_GRUKIT) +"/"+ ALLTRIM(VE8->VE8_CODKIT)+STR0179)
									exit
								endif
							endif
						next
						DBSkip()
					enddo
				endif
			endif
		Endif
	Endif


Return .f.


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001FSOK   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | FieldOK do aCols de servicos                                 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001FSOK()
Local lCalc   := .f.
Local nCntFor := 0
Local lProdSrv := .f.
Private lVldDSrv := .t.
//
if M->VS1_TIPORC == "1"
	MsgInfo(STR0045,STR0025)
	Return .f.
endif
// Verifica linha deletada
if oGetServ:aCols[oGetServ:nAt,Len(oGetServ:aCols[oGetServ:nAt])]
	Return .f.
endif
// Ponto de entrada antes do FieldOk
If ExistBlock("OX001AFS")
	If !ExecBlock("OX001AFS",.f.,.f.)
		Return .f.
	Endif
Endif
// Verifica se é obrigatorio usar o inconveniente
if lInconveniente .and. lInconvObr .and. (M->VS1_TIPORC == "2" ) .and. !OX001INCOBR()
	Return .f.
endif
//
// Posiciona na tabela de servicos e tipo de tempo
DBSelectArea("VOK")
DBSetOrder(1)
DBSeek(xFilial("VOK")+M->VS4_TIPSER)

// Verifica se é serviço de kilometragem
lKilometragem := ( VOK->VOK_INCMOB == "5" )
//
DBSelectArea("VOI")
DBSetOrder(1)
DBSeek(xFilial("VOI")+M->VS1_TIPTSV)
if !Empty(M->VS4_SEQSER)
	cQryAl001 := GetNextAlias()
	cQuery := "SELECT R_E_C_N_O_ RECVO7 FROM "+RetSqlName("VO7")
	cQuery += " WHERE VO7_FILIAL ='" + xFilial("VO7") + "' AND VO7_SEQSER='" + M->VS4_SEQSER + "' AND"
	cQuery += " D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
	If !(cQryAl001)->(Eof())
		DBSelectArea("VO7")
		DBGoto((cQryAl001)->(RECVO7))
	EndIf
	(cQryAl001)->(dbCloseArea())
	DBSelectArea("VO7")
endif

If ReadVar()=="M->VS4_CODFOR" .or. ReadVar()=="M->VS4_FOLOJA"
	DBSelectArea("SA2")
	DBSetOrder(1)
	if DBSeek(xFilial("SA2")+M->VS4_CODFOR+M->VS4_FOLOJA)
		M->VS4_NOMFOR := SA2->A2_NOME
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_NOMFOR","aHeaderS")] := M->VS4_NOMFOR
	endif
EndIf

If ReadVar() == "M->VS4_GRUSER"
	If lFuncOM030GRUSRV
		If !OM030GRUSRV(M->VS4_GRUSER,;
						M->VS1_TIPTSV,;
						M->VS1_CODMAR,;
						.t.)
			return .f.
		EndIf
	EndIf
EndIf

If ReadVar()=="M->VS4_CODSER" .or. ReadVar()=="M->VS4_TIPSER"
	lCalc := .t.
	if lInconveniente
		// #################################################################################
		// Chama a tela para Selecionar Inconveniente, se nao informado pelo Inconveniente
		// #################################################################################
		OX001SELINCON("S")
		// ###########################################################################################
		// Verifica se o produto ja foi lancado no orcamento
		// ################################################################
		// Verifica duplicidade com grupo / codigo do item e INCONVENIENTE
		// ################################################################
		if lVldDSrv .and. OX001SDUPL(oGetServ:nAt,M->VS4_GRUSER ,M->VS4_CODSER ,M->VS4_GRUINC ,M->VS4_CODINC ,M->VS4_DESINC ,M->VS4_SEQINC )
			if !lOX001Auto
				MsgInfo(STR0046,STR0025)
			endif
			return .f.
		endif
	else
		//#########################################################
		// Verifica duplicidade somente com grupo / codigo do item
		//#########################################################
		if lVldDSrv .and. OX001SDUPL(oGetServ:nAt,M->VS4_GRUSER ,M->VS4_CODSER)
			if !lOX001Auto
				MsgInfo(STR0046,STR0025)
			endif
			return .f.
		endif
	endif
	If ReadVar() == "M->VS4_TIPSER"
		If !Empty(M->VS4_TIPSER)
			VOK->(dbSeek(xFilial("VOK") + M->VS4_TIPSER ))
			SB1->(DBSetOrder(7))
			If SB1->(DBSeek(xFilial("SB1")+ VOK->VOK_GRUITE + VOK->VOK_CODITE ))
				lProdSrv := .t.
			EndIf
		EndIf
	Else
		If !Empty(oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_TIPSER","aHeaderS")])
			VOK->(dbSeek(xFilial("VOK") + oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_TIPSER","aHeaderS")] ))
			SB1->(DBSetOrder(7))
			If SB1->(DBSeek(xFilial("SB1")+ VOK->VOK_GRUITE + VOK->VOK_CODITE ))
				lProdSrv := .t.
			EndIf
		EndIf
	EndIf
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_GRUSER","aHeaderS")] := M->VS4_GRUSER
	// Calcula serviço de kilometragem
	if lKilometragem
		if ReadVar() == "M->VS4_TIPSER"
			M->VS4_VALHOR := VOK->VOK_PREKIL
		Endif
		nTemPad := 0
		M->VS4_VALSER := M->VS4_KILROD * M->VS4_VALHOR
	else
		M->VS4_KILROD := 0
		M->VS4_VALHOR := If(VOK->VOK_INCMOB $ "0/2/5/7",0,FG_VALHOR(VOI->VOI_TIPTEM,dDataBase,,,VV1->VV1_CODMAR,M->VS4_CODSER,M->VS4_TIPSER,M->VS1_CLIFAT,M->VS1_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))
		if VO7->(RecCount()) > 0 .and. M->VS1_CODMAR == OX0010393_GM()
			if Empty(M->VS4_SEQSER)
				cQryAl001 := GetNextAlias()
				cQuery := "SELECT VO7_SEQSER, VO7.R_E_C_N_O_ RECVO7 FROM " + RetSQLName("VO7") + " VO7 "
				cQuery += " WHERE VO7_FILIAL = '" + xFilial("VO7") + "'"
				cQuery +=  " AND VO7_CODMAR ='" + M->VS1_CODMAR + "'"
				cQuery +=  " AND VO7_CODSER ='" + M->VS4_CODSER + "'"
				cQuery +=  " AND VO7_APLICA ='" + substr(M->VS1_CHASSI,4,4) + "'"
				cQuery +=  " AND D_E_L_E_T_ = ' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
				If !(cQryAl001)->(Eof())
					M->VS4_SEQSER := (cQryAl001)->VO7_SEQSER
					DBSelectArea("VO7")
					DBGoto((cQryAl001)->(RECVO7))
				EndIf
				(cQryAl001)->(dbCloseArea())
				DBSelectArea("VO7")
			endif
			nTemPad := OX001TemPad(VV1->VV1_CODMAR,M->VS4_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),,VO7->VO7_APLICA,VO7->VO7_CONTRO)
			oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_SEQSER","aHeaderS")] := M->VS4_SEQSER
		Else
			nTemPad := FG_TEMPAD(VV1->VV1_CHAINT,M->VS4_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),,M->VS1_CODMAR)
		Endif
		if ( !Empty(VOK->VOK_TIPSER) .And. VOK->VOK_INCMOB <> "7" ) // Calcular se for diferente de Valor Informado
			M->VS4_VALSER := (nTemPad /100) * M->VS4_VALHOR
		EndIf
	endif
	DBSelectArea("VO6")
	DBSetOrder(3) // VO6_FILIAL+VO6_CODMAR+VO6_GRUSER+VO6_CODSER
	if DBSeek(xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,M->VS4_CODSER)+M->VS4_GRUSER+M->VS4_CODSER)
		if ( !Empty(VOK->VOK_TIPSER) .And. VOK->VOK_INCMOB <> "7" ) // Calcular se for diferente de Valor Informado
			if VO6->VO6_VALSER != 0
				M->VS4_VALSER := VO6->VO6_VALSER
				M->VS4_VALHOR := 0
			EndIf
			if VOK->VOK_INCMOB == "2" // Servico de Terceiro
				M->VS4_VALDES := 0
				M->VS4_PERDES := 0
				oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALVEN","aHeaderS")] := M->VS4_VALVEN := M->VS4_VALSER // Valor de Venda
			endif
		endif
		M->VS4_TEMPAD := nTemPad
		M->VS4_VALTOT := M->VS4_VALSER - M->VS4_VALDES
		if ReadVar()=="M->VS4_CODSER"
			M->VS4_DESSER := VO6->VO6_DESSER
			oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_DESSER","aHeaderS")] := M->VS4_DESSER
		endif
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_CODSEC","aHeaderS")] := M->VS4_CODSEC
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_TEMPAD","aHeaderS")] := M->VS4_TEMPAD
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALHOR","aHeaderS")] := M->VS4_VALHOR
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_KILROD","aHeaderS")] := M->VS4_KILROD
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALSER","aHeaderS")] := M->VS4_VALSER
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALTOT","aHeaderS")] := M->VS4_VALTOT
	endif
	//
	if !Empty(M->VS1_PERSER) .and. M->VS4_PERDES == 0
		M->VS4_PERDES := M->VS1_PERSER
		lCalc := .t.
	endif
	OX001SrvFis()
	If lProdSrv // Se posicionou no Produto - setar o SB1 referente ao Servico
		MaFisRef("IT_PRODUTO","VS300",SB1->B1_COD)
	EndIf
	MaFisRef("IT_QUANT","VS300",1)
	cTesSrv := VOI->VOI_CODTES
	if !Empty(VOI->VOI_CODOPE)
		DBSelectArea("VOK")
		DBSetOrder(1)
		DBSeek(xFilial("VOK")+oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_TIPSER","aHeaderS")])
		DBSelectArea("SB1")
		SB1->(DBSeek(xFilial("SB1")+ VOK->VOK_GRUITE + VOK->VOK_CODITE ))
		SFM->(DBSetOrder(1))
		SFM->(DBSeek(xFilial("SFM")+M->VS3_OPER))
		cTesSrv := OX001TESINT(VOI->VOI_CODOPE)
	endif
	MaFisRef("IT_TES","VS300",cTesSrv)
	MaFisRef("IT_PRCUNI","VS300",M->VS4_VALSER)
	MaFisRef("IT_VALMERC","VS300",M->VS4_VALSER)
	MaFisRef("IT_DESCONTO","VS300",M->VS4_VALDES)
	OX001FisSrv()
	//
	if lInconveniente
		oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_GRUINC","aHeaderS")] := M->VS4_GRUINC
		oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_CODINC","aHeaderS")] := M->VS4_CODINC
		oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_SEQINC","aHeaderS")] := M->VS4_SEQINC
		oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_DESINC","aHeaderS")] := M->VS4_DESINC
	endif
EndIf
If ReadVar() $ "M->VS4_PERDES,M->VS4_VALDES,M->VS4_VALVEN"
	if VOK->VOK_INCMOB == "2" // Servico de Terceiro
		DBSelectArea("VO6")
		DBSetOrder(3) // VO6_FILIAL+VO6_CODMAR+VO6_GRUSER+VO6_CODSER
		if DBSeek(xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,M->VS4_CODSER)+M->VS4_GRUSER+M->VS4_CODSER) .and. VO6->VO6_VALSER != 0
			FMX_HELP("OX001FSOK", STR0399) // O Serviço de Terceiro já possui valor fixo, impossível alterar o valor!
			Return .f.
		EndIf
		If ReadVar()=="M->VS4_VALVEN"
			oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALSER","aHeaderS")] := M->VS4_VALSER := M->VS4_VALVEN // Valor de Venda
			oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALTOT","aHeaderS")] := M->VS4_VALTOT := M->VS4_VALVEN - M->VS4_VALDES // Valor de Venda
			OX001SrvFis()
			MaFisRef("IT_PRCUNI","VS300",M->VS4_VALSER)
			MaFisRef("IT_VALMERC","VS300",M->VS4_VALSER)
			OX001FisSrv()
		EndIf
	EndIf
EndIf
If ReadVar()=="M->VS4_TEMPAD"
	if VOK->VOK_INCTEM != "4"
		if !lOX001Auto
			MsgInfo(STR0047)
		endif
		return .f.
	endif
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_TEMPAD","aHeaderS")] := M->VS4_TEMPAD
	if !lKilometragem
		M->VS4_VALHOR := If(VOK->VOK_INCMOB $ "0/2/5/7",0,FG_VALHOR(VOI->VOI_TIPTEM,dDataBase,,,VV1->VV1_CODMAR,M->VS4_CODSER,M->VS4_TIPSER,M->VS1_CLIFAT,M->VS1_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))
		if ( !Empty(VOK->VOK_TIPSER) .And. VOK->VOK_INCMOB <> "7" ) // Calcular se for diferente de Valor Informado
			M->VS4_VALSER := (M->VS4_TEMPAD /100) * M->VS4_VALHOR
		EndIf
		DBSelectArea("VO6")
		DBSetOrder(3)
		DBSeek(xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,M->VS4_CODSER)+M->VS4_GRUSER+M->VS4_CODSER)
		if ( !Empty(VOK->VOK_TIPSER) .And. VOK->VOK_INCMOB <> "7" ) // Calcular se for diferente de Valor Informado
			if VO6->VO6_VALSER != 0
				M->VS4_VALSER := VO6->VO6_VALSER
				M->VS4_VALHOR := 0
			EndIf
		endif
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALHOR","aHeaderS")] := M->VS4_VALHOR
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALSER","aHeaderS")] := M->VS4_VALSER
		M->VS4_VALTOT := M->VS4_VALSER - M->VS4_VALDES
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALTOT","aHeaderS")] := M->VS4_VALTOT
		OX001SrvFis()
		MaFisRef("IT_PRCUNI","VS300",M->VS4_VALSER)
		MaFisRef("IT_VALMERC","VS300",M->VS4_VALSER)
		OX001FisSrv()
	endif
EndIf

If ReadVar()=="M->VS4_VALHOR"

	lCalc := .t.
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALHOR","aHeaderS")] := M->VS4_VALHOR
	if !lKilometragem
		if ( !Empty(VOK->VOK_TIPSER) .And. VOK->VOK_INCMOB <> "7" ) // Calcular se for diferente de Valor Informado
			M->VS4_VALSER := (M->VS4_TEMPAD /100) * M->VS4_VALHOR
		EndIf
		DBSelectArea("VO6")
		DBSetOrder(3)
		DBSeek(xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,M->VS4_CODSER)+M->VS4_GRUSER+M->VS4_CODSER)
		if ( !Empty(VOK->VOK_TIPSER) .And. VOK->VOK_INCMOB <> "7" ) // Calcular se for diferente de Valor Informado
			if VO6->VO6_VALSER != 0
				M->VS4_VALSER := VO6->VO6_VALSER
				M->VS4_VALHOR := 0
			endif
		EndIf
	Else
		M->VS4_VALSER := M->VS4_KILROD * M->VS4_VALHOR
	Endif

	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALHOR","aHeaderS")] := M->VS4_VALHOR
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALSER","aHeaderS")] := M->VS4_VALSER
	M->VS4_VALTOT := M->VS4_VALSER - M->VS4_VALDES
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALTOT","aHeaderS")] := M->VS4_VALTOT
	OX001SrvFis()
	MaFisRef("IT_PRCUNI","VS300",M->VS4_VALSER)
	MaFisRef("IT_VALMERC","VS300",M->VS4_VALSER)
	OX001FisSrv()
	
EndIf

If ReadVar()=="M->VS4_VALSER"
	lCalc := .t.
	//////////////////////////////////////////////////////////
	VOK->(DbSetOrder(1))
	VOK->(DbSeek( xFilial("VOK") + M->VS4_TIPSER ))
	//
	DBSelectArea("VO6")
	DBSetOrder(3)
	DBSeek(xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,M->VS4_CODSER)+M->VS4_GRUSER+M->VS4_CODSER)
	//////////////////////////////////////////////////////////
	// Utilizar a mesma VALIDACAO da Requisicao de Serviços //
	//////////////////////////////////////////////////////////
	lOM030Auto := .t. // variavel utilizada no OFIOM030 - Retorna .T. caso nao exista o campo VAI_VALSER
	If !OM030VALSER( M->VS4_CODSER , M->VS4_VALSER , OX0010091_LevantaVlrServico() )
		return .f.
	EndIf
	//////////////////////////////////////////////////////////
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALSER","aHeaderS")] := M->VS4_VALSER
	M->VS4_VALTOT := M->VS4_VALSER - M->VS4_VALDES
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALTOT","aHeaderS")] := M->VS4_VALTOT
	OX001SrvFis()
	MaFisRef("IT_PRCUNI","VS300",M->VS4_VALSER)
	MaFisRef("IT_VALMERC","VS300",M->VS4_VALSER)
	OX001FisSrv()
EndIf

If ReadVar()=="M->VS4_KILROD"
	lCalc := .t.
	if VOK->VOK_INCMOB != "5"
		if !lOX001Auto
			MsgInfo(STR0049)
		endif
		return .f.
	endif
	M->VS4_VALHOR := IIf(M->VS4_VALHOR<>0,M->VS4_VALHOR,VOK->VOK_PREKIL)
	M->VS4_VALSER := M->VS4_KILROD * M->VS4_VALHOR
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALHOR","aHeaderS")] := M->VS4_VALHOR
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALSER","aHeaderS")] := M->VS4_VALSER
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_KILROD","aHeaderS")] := M->VS4_KILROD
	M->VS4_VALTOT := M->VS4_VALSER - M->VS4_VALDES
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALTOT","aHeaderS")] := M->VS4_VALTOT
	OX001SrvFis()
	MaFisRef("IT_PRCUNI","VS300",M->VS4_VALSER)
	MaFisRef("IT_VALMERC","VS300",M->VS4_VALSER)
	OX001FisSrv()
EndIf

If ReadVar() $ "M->VS4_PERDES,M->VS4_VALDES" .or. lCalc
	lRepPerDes := .t.	
	While .t.
		nValItem := FtDescItem( @M->VS4_VALSER,;			//ExpN1: Preco de lista aplicado o desconto de cabecalho
		@M->VS4_VALSER,; 			//ExpN2: Preco de Venda
		1,;				//ExpN3: Quantidade vendida
		@M->VS4_VALTOT,;			//ExpN4: Valor Total (do item)
		iif(ReadVar()=="M->VS4_VALDES",M->VS4_PERDES,@M->VS4_PERDES),;           	//ExpN5: Percentual de desconto
		@M->VS4_VALDES,;			//ExpN6: Valor do desconto
		@M->VS4_VALDES,;			//ExpN7: Valor do desconto original
		iif(ReadVar()=="M->VS4_VALDES",2,1))	//ExpN8: Tipo de Desconto (1 % OU 2 R$)
		//
		If ReadVar()=="M->VS4_VALDES"
	   	nPerDesTemp := (M->VS4_VALDES/(M->VS4_VALTOT+M->VS4_VALDES))*100
			If M->VS4_PERDES == 0 .or. lRepPerDes
				M->VS4_PERDES := nPerdesTemp
			Endif				
		Endif
		//
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_PERDES","aHeaderS")] := M->VS4_PERDES
		M->VS4_VALDES := Round(M->VS4_VALSER * M->VS4_PERDES / 100,2)
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALDES","aHeaderS")] := M->VS4_VALDES
		M->VS4_VALTOT := M->VS4_VALSER - M->VS4_VALDES
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALTOT","aHeaderS")] := M->VS4_VALTOT
		OX001SrvFis()
		MaFisRef("IT_DESCONTO","VS300",M->VS4_VALDES)
		OX001FisSrv()
		If ReadVar() == "M->VS4_PERDES"
			__ReadVar := "M->VS4_VALDES"
			lRepPerDes := .f.
			Loop
		Else
			Exit
		EndIf
	EndDo
EndIf
//
If cPaisLoc == "BRA" // Carregar Impostos por Serviço
	If ReadVar() $ "M->VS4_CODSER,M->VS4_TIPSER,M->VS4_TEMPAD,M->VS4_VALHOR,M->VS4_VALSER,M->VS4_KILROD,M->VS4_PERDES,M->VS4_VALDES" .or. lCalc
		OX001SrvFis()
			OX0010151_atualiza_impostos_aCols_Servicos( oGetServ:nAt ) // Atualiza Impostos na aCols de Servicos
		OX001FisSrv()
	EndIf
EndIf
//
if M->VS1_TIPORC == "2"
	If ReadVar() $ "M->VS4_DEPINT/M->VS4_DEPGAR"
		// Valida Tipo de Tempo de Serviços
		DBSelectArea("VOI")
		DBSetOrder(1)
		DBSeek(xFilial("VOI")+M->VS1_TIPTSV)
		if VOI->VOI_SITTPO == "3"
			// Valida Departamento Interno
			If ReadVar() == "M->VS4_DEPINT"
				For nCntFor := 1 to len(oGetPecas:aCols)
					If !oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])]// .and. oGetPecas:nAt <> nCntFor
						if AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPINT]) <> M->VS4_DEPINT .and. ;
							!Empty(AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPINT]))
							if MsgYEsNo(STR0251+"'"+M->VS4_DEPINT+"'"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0250)
								OF001DEPINT()
								Return .t.
							Else
								Return .f.
							Endif
						endif
					endif
				Next
			Endif
			// Valida Departamento Garantia
			If ReadVar() == "M->VS4_DEPGAR"
				For nCntFor := 1 to len(oGetPecas:aCols)
					If !oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])] .and. oGetPecas:nAt <> nCntFor
						if AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPGAR]) <> M->VS4_DEPGAR .and. ;
							!Empty(AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPGAR]))
							if MsgYEsNo(STR0251+"'"+M->VS4_DEPGAR+"'"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0250)
								OF001DEPGAR()
								Return .t.
							Else
							    Return .f.
							Endif
						endif
					endif
				Next
				For nCntFor := 1 to len(oGetServ:aCols)
					If !oGetServ:aCols[nCntFor,len(oGetServ:aCols[nCntFor])] .and. oGetServ:nAt <> nCntFor
						if AllTrim(oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPGAR","aHeaderS")]) <> M->VS4_DEPGAR .and. ;
							!Empty(AllTrim(oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPGAR","aHeaderS")]))
							MsgStop(STR0244,STR0025)
							return .f.
						endif
					endif
				Next
			Endif
		endif
	Endif
Endif
//
if !lOX001Auto
	oGetServ:oBrowse:Refresh()
	OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
endif
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001LINIOK | Autor |  Luis Delorme         | Data | 19/05/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Tratativa para Inconveniente no ExecAuto (rot.automatica)    |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001LINIOK()
//
if lOX001Auto
	AADD(oGetInconv:aCols,aCols[n])
endif

return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001LINPOK | Autor |  Manoel               | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Verifica a linha das aCols de pecas                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001LINPOK()
Local nCntFor := 0

Local nLinDup

//Local nTpProc := 0

Private lVldDPec := .t.

If  lPediVenda .and. !Empty(M->VS1_PEDREF)  .and. cMVMIL0011 == "1"
	MsgAlert(STR0272,STR0025)
	return .f.
Endif
//
if lOX001Auto
	AADD(oGetPecas:aCols,aCols[n])
	//
	OX001RefNF()
	//
	for nCntFor := 1 to Len(aCols[n]) - 1
		&("M->"+aHeaderP[nCntFor,2]):= aCols[Len(oGetPecas:aCols),nCntFor]
		__ReadVar := "M->"+aHeaderP[nCntFor,2]
		oGetPecas:nAt := Len(oGetPecas:aCols)
		n := Len(oGetPecas:aCols)
		OX001FPOK(,,.f.,.f.)
	next
endif
// ############################################################
// # Pula registros deletados                                 #
// ############################################################
If oGetPecas:aCols[oGetPecas:nAt,len(oGetPecas:aCols[oGetPecas:nAt])]
	Return .t.
EndIf
// ############################################################
// # Verifica se a peca realmente existe                      #
// ############################################################
cPeca := oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE]
cGrupo := oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]
//
if Empty(cPeca) .and. Empty(cGrupo)
	return .t. //<<--- Problema da linha vazia na acols de pecas
endif

// ####################################################################
// Ponto de Entrada para validacao das linhas do acols dos itens pecas
// ####################################################################
If ( ExistBlock("OX001LKP") )
	lRet := ExecBlock("OX001LKP",.F.,.F.,{lRet})
	If !lRet
		return .f.
	EndIf
EndIf
//
If SB1->B1_GRUPO <> cGrupo .or. SB1->B1_CODITE <> cPeca
	DBSelectArea("SB1")
	DBSetOrder(7)
	if !dbSeek(xFilial("SB1")+cGrupo+cPeca)
		if !lOX001Auto
			MsgInfo(STR0050,STR0025)
		endif
		return .f.
	endif
endif
//
// ############################################################
// # Verifica tipo de tempo de servico                        #
// ############################################################
If M->VS1_TIPORC == "2"
	DBSelectArea("VOI")
	DBSetOrder(1)
	DBSeek(xFilial("VOI")+M->VS1_TIPTEM)
	if VOI->VOI_DEPGAR=="1"
	   if Empty(M->VS3_DEPGAR)
	 	  Help("  ",1,"OBRIGAT",,aHeaderP[FG_POSVAR('VS3_DEPGAR',"aHeaderP"),1],4,1)
	 	  Return(.f.)
	   Endif
	Endif
	if VOI->VOI_DEPINT=="1"
	   if Empty(M->VS3_DEPINT)
	 	  Help("  ",1,"OBRIGAT",,aHeaderP[FG_POSVAR('VS3_DEPINT',"aHeaderP"),1],4,1)
	 	  Return(.f.)
	   Endif
	Endif
Endif
//
// ############################################################
// # Verifica se venda abaixo do custo                        #
// ############################################################
SF4->(dbseek(xFilial("SF4")+oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_CODTES","aHeaderP")]))
If cMVLBVACB == "N" .and. SF4->F4_OPEMOV == "05"  //VENDA  //Libera Venda Abaixo do Custo (Balcao)
	DbSelectArea("SB1")
	DbSetOrder(7)
	if DbSeek( xFilial("SB1") + cGrupo + cPeca )
		//
		DbSelectArea("SB2")
		DbSetOrder(1)
		DbSeek(xFilial("SB2")+SB1->B1_COD)
		nSdoPecB2 := 0
		While !eof() .and. xFilial("SB2")+SB1->B1_COD == SB2->B2_FILIAL+SB2->B2_COD
			nSdoPecB2 += OX001SLDPC(xFilial("SB2")+SB1->B1_COD+oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_LOCAL","aHeaderP")])//SB2->B2_QATU
			dbSkip()
		Enddo
		DbSeek(xFilial("SB2")+SB1->B1_COD+Iif(!Empty(oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_LOCAL","aHeaderP")]),oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_LOCAL","aHeaderP")],OX0010105_ArmazemOrigem()))
		If Round(oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_VALPEC","aHeaderP")],2) < Round(SB2->B2_CM1,2) .and. nSdoPecB2 > 0
			MsgStop(STR0131)
			return .f.
		Endif
	endif
endif
// ############################################################
//altera valor do campo VS3_SEQUEN                            #
// ############################################################
OX0010163_SequenciaVS3()

// ############################################################
// # Verifica campos obrigatorios                             #
// ############################################################
For nCntFor:=1 to (Len(aHeaderP)-2) // Nao processa as colunas de RECNO e ALIAS
	If aHeaderPObrigat[nCntfor] .and. (Empty(oGetPecas:aCols[oGetPecas:nAt,nCntFor]))
		If lAltPedVda
			If (oGetPecas:aCols[oGetPecas:nAt,nVS3QTDPED]+oGetPecas:aCols[oGetPecas:nAt,nVS3QTDINI] == 0)
				Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderP[nCntFor,2]),4,1)
				Return .f.
			Else
				Return .t.
			Endif
		Else
			Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderP[nCntFor,2]),4,1)
			Return .f.
		Endif
	EndIf
Next

// ############################################################
// # Verifica quantidade requisitada                          #
// ############################################################
If !Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE])  .and. oGetPecas:aCols[oGetPecas:nAt,nVS3QTDITE] <= 0 .and. !lPediVenda
	if !lOX001Auto
		MsgInfo(STR0051,STR0025)
	endif
	Return .f.
EndIf
// ############################################################
// # Verifica valor da peca                                   #
// ############################################################
If M->VS1_TIPORC == "2" .and. oGetPecas:aCols[oGetPecas:nAt,nVS3VALPEC] <= 0
	if !lOX001Auto
		MsgStop(STR0052,STR0025)
	endif
	Return .f.
EndIf
// ##################################
// Verifica se o item esta duplicado
// ##################################
if lInconveniente
	// ################################################################
	// Verifica duplicidade com grupo / codigo do item e INCONVENIENTE
	// ################################################################
	if lVldDPec .and. OX001PDUPL(oGetPecas:nAt,oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] ,;
						oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] ,;
						oGetPecas:aCols[oGetPecas:nAt,nVS3GRUINC] ,;
						oGetPecas:aCols[oGetPecas:nAt,nVS3CODINC] ,;
						oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC] ,;
						oGetPecas:aCols[oGetPecas:nAt,nVS3SEQINC] ,;
						oGetPecas:aCols[oGetPecas:nAt,nVS3NUMLOT] ,;
						oGetPecas:aCols[oGetPecas:nAt,nVS3LOTECT] ,;
						@nLinDup )
		if !lOX001Auto  .and. !lDupOrc
			MsgInfo(STR0037 + chr(13) + chr(13) + STR0146 + AllTrim(Str(nLinDup)),STR0025)
		endif
		return .f.
	endif
else
	// ########################################################
	// Verifica duplicidade somente com grupo / codigo do item
	// ########################################################
	if lVldDPec .and. OX001PDUPL(oGetPecas:nAt,oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] ,;
						oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] ,,,,,;
						oGetPecas:aCols[oGetPecas:nAt,nVS3NUMLOT],;
						oGetPecas:aCols[oGetPecas:nAt,nVS3LOTECT],;
						@nLinDup )

		if !lOX001Auto .and. !lDupOrc
			MsgInfo(STR0037 + chr(13) + chr(13) + STR0146 + AllTrim(Str(nLinDup)),STR0025)
		endif

		return .f.
	endif
endif

// ############################################################
// # Apaga itens relacionados                                 #
// ############################################################
aIteRel := {{"","","",0,0,"","",""}}
//
if !lOX001Auto
	oLItRel:nAt := 1
	oLItRel:SetArray(aIteRel)
	oLItRel:bLine := { || { aIteRel[oLItRel:nAt,6] ,;
									aIteRel[oLItRel:nAt,7],;
									aIteRel[oLItRel:nAt,8],;
									aIteRel[oLItRel:nAt,1],;
									aIteRel[oLItRel:nAt,2] ,;
									aIteRel[oLItRel:nAt,3] ,;
									FG_AlinVlrs(Transform(aIteRel[oLItRel:nAt,4],"@E 999,999")),;
									FG_AlinVlrs(Transform(aIteRel[oLItRel:nAt,5],"@E 999,999,999.99"))}}
	oLItRel:Refresh()
endif

//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001LINSOK | Autor |  Manoel               | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Verifica a linha das aCols de servicos                       |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001LINSOK()
Local nCntFor := 0
Local lTudoBranco := .t.

Local cIncMob := "" // cIncMob do VOK (Servico)
Private lVldDSrv := .t.
// ############################################################
// # Pula registros deletados                                 #
// ############################################################
If oGetServ:aCols[oGetServ:nAt,len(oGetServ:aCols[oGetServ:nAt])]
	Return .t.
EndIf
// ####################################################################
// Ponto de Entrada para validacao das linhas do acols dos itens srv.
// ####################################################################
If ( ExistBlock("OX001LKS") )  // <<<<---- O B S O L E T O
	lRet := ExecBlock("OX001LKS",.F.,.F.,{lRet})
	If !lRet
		return .f.
	EndIf
EndIf
// ############################################################
// # Verifica se trata-se de uma linha inteiramente em branco #
// ############################################################
For nCntFor:=1 to Len(aHeaderS)
	if !Empty(oGetServ:aCols[oGetServ:nAt,nCntFor])
		lTudoBranco := .f.
	endif
Next
if lTudoBranco
	return .t.
endif
// ############################################################
// # Verifica tipo de tempo de servico                        #
// ############################################################
DBSelectArea("VOI")
DBSetOrder(1)
DBSeek(xFilial("VOI")+M->VS1_TIPTSV)
if VOI->VOI_DEPGAR=="1"
   if Empty(M->VS4_DEPGAR)
 	  Help("  ",1,"OBRIGAT",,aHeaderS[FG_POSVAR('VS4_DEPGAR',"aHeaderS"),1],4,1)
 	  Return(.f.)
   Endif
Endif
if VOI->VOI_DEPINT=="1"
   if Empty(M->VS4_DEPINT)
 	  Help("  ",1,"OBRIGAT",,aHeaderS[FG_POSVAR('VS4_DEPINT',"aHeaderS"),1],4,1)
	  Return(.f.)
   Endif
Endif
// Ajusta sequencia da VS4
OX0010365_SequenciaVS4()

// ############################################################
// # Verifica campos obrigatorios                             #
// ############################################################
For nCntFor:=1 to Len(aHeaderS)
	If X3Obrigat(aHeaderS[nCntFor,2])  .and. (Empty(oGetServ:aCols[oGetServ:nAt,nCntFor]))
		Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderS[nCntFor,2]),4,1)
		Return .f.
	EndIf
Next
// ############################################################
// # Verifica valor do servico qdo nao for Mao Obra Gratuita  #
// # ou servico de terceiros !( VOK_INCMOB $ '0/2')           #
// ############################################################
cIncMob := FM_SQL("SELECT VOK_INCMOB FROM " + RetSQLName("VOK") + " VOK WHERE VOK_FILIAL = '" + xFilial("VOK") + "' AND VOK_TIPSER = '" + oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_TIPSER","aHeaderS")] + "' AND D_E_L_E_T_=' '")
If oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_VALSER","aHeaderS")] <= 0 .AND. !( cIncMob $ '0/2' ) // 0=Mao de Obra Gratuita / 2=Serv. Terceiros
	if !lOX001Auto
		MsgStop(STR0053,STR0025)
	endif
	Return .f.
EndIf
// ##############################################################
// Verifica valor de Venda e Custo quando Serviços de Terceiros #
// ##############################################################
if cIncMob == "2" //Serv. Terceiros
   if M->VS4_VALVEN == 0
 	  Help("  ",1,"OBRIGAT",,aHeaderS[FG_POSVAR('VS4_VALVEN',"aHeaderS"),1],4,1)
 	  Return(.f.)
   Endif
   if M->VS4_VALCUS == 0
 	  Help("  ",1,"OBRIGAT",,aHeaderS[FG_POSVAR('VS4_VALCUS',"aHeaderS"),1],4,1)
 	  Return(.f.)
   Endif
Endif

// ###################################
// Verifica se o item esta duplicado
// ###################################
if lInconveniente
	// #################################################################
	// Verifica duplicidade com grupo / codigo do item e INCONVENIENTE
	// #################################################################
	if lVldDSrv .and. OX001SDUPL(oGetServ:nAt,oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_GRUSER","aHeaderS")] ,;
		oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_CODSER","aHeaderS")] ,;
		oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_GRUINC","aHeaderS")] ,;
		oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_CODINC","aHeaderS")] ,;
		oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_DESINC","aHeaderS")] ,;
		oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_SEQINC","aHeaderS")] )
		if !lOX001Auto
			MsgInfo(STR0046,STR0025)
		ENDIF
		return .f.
	endif
else
	// #########################################################
	// Verifica duplicidade somente com grupo / codigo do item
	// #########################################################
	if lVldDSrv .and. OX001SDUPL(oGetServ:nAt,oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_GRUSER","aHeaderS")] ,;
		oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_CODSER","aHeaderS")] )
		if !lOX001Auto
			MsgInfo(STR0046,STR0025)
		endif
		return .f.
	endif
endif


//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001TUDOK  | Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Verifica se as aCols estao preenchidas corretamente          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OX001TUDOK(nOpc, lExecVld)

Local aPecSemEst := {}
//
Local nCntFor    := 0
Local lGrdPecaOk := .t.
Local lGrdSrvOk  := .t.
Local lGrdIncOk  := .t.
Local lDadoPec   := .t.
Local lDadoSrv   := .t.
Local lDadoInc   := .t.

Default lExecVld := .f.
//
IF (!lExecVld .and. FECHA) .or. EXCLUI
	return .t.
endif

// ####################################################
// Ponto de Entrada para validacao de todo o orcamento
// ####################################################
If ( ExistBlock("OFIX01TUDOK") ) // <<<--- O B S O L E T O
	lRet := ExecBlock("OFIX01TUDOK",.F.,.F.,{lRet})
	If !lRet
		return .f.
	EndIf
EndIf
If ( ExistBlock("OX001TOK") )
	lRet := ExecBlock("OX001TOK",.F.,.F.,{lRet})
	If !lRet
		return .f.
	EndIf
EndIf
// ############################################################
// # Verifica campos obrigatorios da Enchoice                 #
// ############################################################
if M->VS1_TIPORC == "2"
	if Empty(M->VS1_CHASSI)
		if !lOX001Auto
			MsgInfo(STR0054,STR0025)
		endif
		return .f.
	endif

	// Verifica se o Tipo de Tempo Peças esta em branco
	If Empty(M->VS1_TIPTEM)
		Help(" ",1,"OBRIGAT2",,RetTitle("VS1_TIPTEM"),4,1)
		Return .f.
	EndIf

	// Verifica se o Tipo de Tempo Servicos esta em branco
	If Empty(M->VS1_TIPTSV)
		Help(" ",1,"OBRIGAT2",,RetTitle("VS1_TIPTSV"),4,1)
		Return .f.
	EndIf

	If lVOITPATEN
		// Validação Tipo de Atendimento por Tipo de Tempo (Peça)
		If !FGX_VOITPATEN(M->VS1_TPATEN, M->VS1_TIPTEM, .t.)
			Return .f.
		EndIf

		// Validação Tipo de Atendimento por Tipo de Tempo (Serviço)
		If !FGX_VOITPATEN(M->VS1_TPATEN, M->VS1_TIPTSV, .t.)
			Return .f.
		EndIf
	EndIf
endif
//
For nCntFor:=1 to Len(acpoEncS)
	If X3Obrigat(acpoEncS[nCntFor]) .and. Empty(&("M->"+acpoEncS[nCntFor]))
		Help(" ",1,"OBRIGAT2",,RetTitle(acpoEncS[nCntFor]),4,1)
		Return .f.
	EndIf
Next
//
If !Empty(M->VS1_FORMUL)
	If OFP8600016 .And. !OFP8600016_VerificacaoFormula(M->VS1_FORMUL)
		Return .f. // A mensagem já é exibida dentro da função
	EndIf
EndIf

if M->VS1_TIPORC == "2"
	If !OX001HOR() // Valida Hora Trilha
		Return .f.
	EndIf
endif

// ############################################################
// # Verifica a linha atual das aCols de pecas e servicos     #
// ############################################################
if !lOX001Auto
	if oFoldX001:nOption == nFolderS
		if !OX001LINSOK()
			return .f.
		endif
	else
		if !OX001LINPOK()
			return .f.
		endif
	endif
endif


// ############################################################
// # Verifica se trata-se de um orcamento vazio               #
// ############################################################
for nCntFor := 1 to len(oGetPecas:aCols)

	lGrdPecaOk := OX0010245_ValidacaoGridPeca(oGetPecas:aCols[nCntFor],nOpc,@lDadoPec,oGetPecas:aCols,@aPecSemEst)

	If !lGrdPecaOk
		Exit
	EndIf

next nCntFor

If lPediVenda .and. lFaturaPVP .and. Len(aPecSemEst) > 0
	aIntCab := {}
	aAdd(aIntCab,{ RetTitle("B1_GRUPO")  , "C" , 10 , "@!" })
	aAdd(aIntCab,{ RetTitle("B1_CODITE") , "C" , 60 , "@!" })
	aAdd(aIntCab,{ RetTitle("VS3_QTDITE"), "N" , 100 , "@E 999,999.99" })
	aAdd(aIntCab,{ RetTitle("VS3_QTDEST"), "N" , 100 , "@E 999,999.99" })
	FGX_VISINT( "PECSEMEST" , STR0238 , aIntCab , aPecSemEst , .t. ) // Quantidade Insuficiente de Peças
	Return .f.
Endif

If !lGrdPecaOk .and. lDadoPec
	Return .f.
EndIf

for nCntFor := 1 to Len(oGetServ:aCols)

	lGrdSrvOk := OX0010255_ValidacaoGridServico(oGetServ:aCols[nCntFor],nOpc,@lDadoSrv)

	If !lGrdSrvOk
		Exit
	EndIf

next nCntFor

If !lGrdSrvOk .and. lDadoSrv
	Return .f.
EndIf

if lInconveniente

	for nCntFor := 1 to Len(oGetInconv:aCols)

		lGrdIncOk := OX0010265_ValidacaoGridInconveniente(oGetInconv:aCols[nCntFor],nOpc,@lDadoInc)

		If !lGrdIncOk
			Exit
		EndIf

	Next nCntFor

endif

If !lGrdIncOk .and. lDadoInc
	Return .f.
EndIf

if !lDadoPec .and. !lDadoSrv .and. !lDadoInc // 19/04/2018 - chamado 007773 - não deixa mais passar em branco - orientação do Otávio
	if !lOX001Auto .and. !lLibPV
		MsgInfo(STR0056, STR0025)
	endif
	return .f.
endif

Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001GRV    |Autor  |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Gravacao do Orcamento                                        |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001GRV(nOpc, lFat,lImp,lResOrc,lCallPed,lChmPER, lMsgGrv, lSugCpa)
//
Local nCntFor, nCntFor2
Local lAchou := .f.
Local lNovoInconv // Controla se foi Incluido um novo Inconv. no Orcamento
Local nPosGruInc, nPosCodInc, nPosDesInc, nPosSeqInc
Local nPosRestAcols := 0
Local cMotivo    := "000004"  //Filtro da consulta do motivo de Cancelamentos
Local aQVS3UPD := {}
Local nI := 0
Local lNewRes  := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?
Local lRetorno := .t.
Local lDesreserva := .f.
Local lExecVld    := .f.
Local aRetVDD     := {}
Local cTipo       := "01"
Local cOrigem     := "OR"

Private aResSeq  := {}
Private aResDel  := {}
Private aMemos   := {{"VS1_OBSMEM","VS1_OBSERV"}}
Private aMemosVS4 := {{"VS4_OBSMEM","VS4_OBSERV"}}
Private aOrcIte  := {}

Default lFat     := .f.
Default lImp     := .f.
Default lResOrc  := .f.
Default lCallPed := .t.
Default lChmPER  := .f.
Default lMsgGrv  := .T.

// ############################################################
// # So pode haver gravacao na ALTERACAO e INCLUSAO           #
// ############################################################
if (EXCLUI .OR. VISUALIZA .OR. FECHA) .and. !lFat .and. !lImp
	if !lOX001Auto .and. !lLibPV
		MsgInfo(STR0055,STR0025)
	endif
	return .f.
endif

// ############################################################
// # Verificacoes Gerais                                      #
// ############################################################
if !lOX001Auto

	If lNewRes
		lExecVld := ( cVS1Status == "5" .or. cVS1Status == "A" ) // Se for a fase 5 de divergência deverá executar as validações do tudo ok
	Endif

	if !OX001TUDOK(nOpc, lExecVld )
		return .f.
	endif

endif

If ExistBlock("OX001GRA")
	If !ExecBlock("OX001GRA",.f.,.f.)
		return .f.
	EndIf
EndIf

If lPediVenda
	cOrigem := "PD"
	cTipo := "06"
EndIf
// ##########################################################################
// # I N I C I A   A   G R A V A C A O   D O   O R C A M E N T O  (VS1/VS3) #
// ##########################################################################
cNumOrcPed := ""
if M->VS1_NUMORC == "" .or. ( lFaturaPVP .and. lFat .and. !lImp )
	cNumOrcPed := M->VS1_NUMORC
	M->VS1_NUMORC := OX001PrxNro()
elseif !(lFaturaPVP .and. !lImp)
	cNumOrcPed := M->VS1_NUMORC
endif
//
// ------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION // --------I-N-I-C-I-O---D-A---T-R-A-N-S-A-C-A-O---------------------------------------------
// ------------------------------------------------------------------------------------------------------------
// ############################################################
// # Apaga qualquer gravacao anterior                         #
// ############################################################
lAltPed:= .f.

aResDel := {}

lBo := OX001ORCBO(cNumOrcPed)

If lFaturaPVP .and. !lImp
	INCLUI := .T.
	ALTERA := .F.
EndIf

If M->VS1_TIPORC == "2"
	cTipo := "09"
EndIf

for nCntFor := 1 to Len(oGetPecas:aCols)

	if oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])]

		if oGetPecas:aCols[nCntFor, nVS3RESERV ] == "1" .and.;
			( oGetPecas:aCols[nCntFor, nVS3QTDITE ] > 0 .or.;
			( oGetPecas:aCols[nCntFor, nVS3QTDITE ] == 0 .and. VS1->VS1_STATUS == "5" ) )
			DBSelectArea("VS3")
			DBSetOrder(2)
			if DBSeek(xFilial("VS3") + M->VS1_NUMORC + oGetPecas:aCols[nCntFor, nVS3GRUITE ] + oGetPecas:aCols[nCntFor, nVS3CODITE ] )
				aAdd(aResDel,VS3->VS3_SEQUEN)

				If lNewRes
					aAdd(aOrcIte,{VS3->(RecNo()),nCntFor})
				EndIf

			endif

			oGetPecas:aCols[nCntFor, nVS3DOCSDB ] := ""

		endif

		lRetorno := .t.

		if lCancelPVP .and. lCallPed

			cMotPed01 := ""

			if Empty(oGetPecas:aCols[nCntFor, nVS3MOTPED ])

				aMotPed01 := OFA210MOT(cMotivo,"4",xFilial("VS1"),VS1->VS1_NUMORC,.T.,"P") //OFA210MOT()
				cMotPed01 := IIf(len(aMotPed01)>0,aMotPed01[1],"")
				if cMotPed01 == ""

					If oGetPecas:aCols[nCntFor, nVS3RESERV ] == "0"
						oGetPecas:aCols[nCntFor, nVS3RESERV ] := "1"
					EndIf

					lRetorno := .f.
					Exit

				EndIf

			EndIf

			DBSelectArea("VS3")
			DBSetOrder(2)
			if DBSeek(xFilial("VS3") + M->VS1_NUMORC + oGetPecas:aCols[nCntFor, nVS3GRUITE ] + oGetPecas:aCols[nCntFor, nVS3CODITE ] )
				reclock("VS3",.f.)
				VS3->VS3_QTDELI := VS3->VS3_QTDPED
				VS3->VS3_QTDPED := 0
				VS3->VS3_MOTPED := cMotPed01
				oGetPecas:aCols[nCntFor, nVS3MOTPED ] := cMotPed01
				msunlock()
			endif

		EndIf

	Elseif !oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])] .and. !Empty(oGetPecas:aCols[nCntFor, nVS3CODITE ])

		If lNewRes
			If oGetPecas:aCols[nCntFor, nVS3RESERV ] == "1"
				DBSelectArea("VS3")
				DBSetOrder(2)
				if DBSeek(xFilial("VS3") + M->VS1_NUMORC + oGetPecas:aCols[nCntFor, nVS3GRUITE ] + oGetPecas:aCols[nCntFor, nVS3CODITE ] )
					SF4->(DbSetOrder(1))
					SF4->(DbSeek(xFilial("SF4")+oGetPecas:aCols[nCntFor, nVS3CODTES ]))
					If SF4->F4_ESTOQUE == "N"
						aAdd(aOrcIte,{VS3->(RecNo()),nCntFor})
					EndIf
				Endif
			EndIf
		EndIf

		If lFaturaPVP .and. !lImp
			DBSelectArea("VS3")
			DBSetOrder(2)
			if DBSeek(xFilial("VS3") + cNumOrcPed + oGetPecas:aCols[nCntFor, nVS3GRUITE ] + oGetPecas:aCols[nCntFor, nVS3CODITE ] )
				reclock("VS3",.f.)
				VS3->VS3_QTDPED := VS3->VS3_QTDPED - oGetPecas:aCols[nCntFor, nVS3QTDITE ]
				VS3->VS3_QTDITE := oGetPecas:aCols[nCntFor, nVS3QTDITE ]
				VS3->VS3_VALTOT := (VS3->VS3_VALPEC*VS3->VS3_QTDITE) - VS3->VS3_VALDES
				msunlock()
			endif
		EndIf

	Endif

	if lBo
		oGetPecas:aCols[nCntFor,nVS3QTDRES] := FM_SQL(" select VS3_QTDRES from "+retsqlName('VS3')+" WHERE VS3_FILIAL = '"+xFilial('VS3')+"' AND VS3_NUMORC = '"+cNumOrcPed+"' AND VS3_GRUITE = '"+oGetPecas:aCols[nCntFor, nVS3GRUITE ]+"' AND VS3_CODITE = '"+oGetPecas:aCols[nCntFor, nVS3CODITE ]+"' AND VS3_SEQUEN = '"+oGetPecas:aCols[nCntFor, nVS3SEQUEN ]+"' AND D_E_L_E_T_=' '")
		M->VS3_QTDRES := oGetPecas:aCols[nCntFor,nVS3QTDRES]
	EndIf

next

If !lRetorno
	DisarmTransaction()
	return .f.
EndIf

If ( lNewRes .and. Len(aOrcIte) > 0 )
	cDocto := OA4820015_ProcessaReservaItem(cOrigem,VS1->(RecNo()),"M","D",aOrcIte,cTipo,,lSugCpa)
	If !Empty(cDocto)
		OX0010275_AtualizaDadosOrcamento(aOrcIte)
	EndIf
	lDesreserva := .t.
Else
	if Len(aResDel) > 0
		cDocto := OX001RESITE(VS1->VS1_NUMORC,.f.,aResDel )
		lDesreserva := .t.
	EndIf
endif

If lDesreserva

	if Empty(cDocto)
		MsgStop(STR0275)
		DisarmTransaction()
		return .f.
	endif

	if lCancelPVP .and. lCallPed
		If !Empty(cMotPed01)
			if ExistBlock("ORDBUSCB")
				ExecBlock("ORDBUSCB",.f.,.f.,{"OR","CANCELA",aResDel})
			Endif
		EndIf
	EndIf

EndIf

if ! lCancelPVP
	// Grava os dados em memoria dos dados pre-existentes no banco de dados que não estão no acols ou M-> e que seriam perdidos no delete
	aCache := oSqlHlp:GetSelect({;
		{"campos", {"VS3_QTDINI", "VS3_QTDPED", "VS3_QESTNA", "VS3_GRUITE", "VS3_CODITE", "VS3_NUMLOT","VS3_LOTECT", "VS3_MOTPED"}},;
		{"query" , "SELECT VS3_GRUITE, VS3_CODITE, VS3_QTDINI, VS3_QTDPED, VS3_QESTNA, VS3_NUMLOT, VS3_LOTECT, VS3_MOTPED FROM "+oSqlHlp:NoLock("VS3")+" WHERE VS3_FILIAL = '"+ xFilial("VS3")+"' AND VS3_NUMORC= '"+M->VS1_NUMORC+"' "};
	})

	If TCCanOpen(RetSqlName("VS3"))
		cString := "DELETE FROM "+RetSqlName("VS3")+ " WHERE VS3_FILIAL = '"+ xFilial("VS3")+"' AND VS3_NUMORC= '"+M->VS1_NUMORC+"'"
		TCSqlExec(cString)
	else
		DisarmTransaction()
		if INCLUI
			M->VS1_NUMORC := space(TamSx3("VS1_NUMORC")[1])
		endif
		if !lOX001Auto
			MsgStop(STR0059+CHR(10)+STR0060,STR0025)
		endif
		return .f.
	endif
	//
	If TCCanOpen(RetSqlName("VS4"))
		cString := "DELETE FROM "+RetSqlName("VS4")+ " WHERE VS4_FILIAL = '"+ xFilial("VS4")+"' AND VS4_NUMORC= '"+M->VS1_NUMORC+"'"
		TCSqlExec(cString)
	else
		DisarmTransaction()
		if INCLUI
			M->VS1_NUMORC := space(TamSx3("VS1_NUMORC")[1])
		endif
		if !lOX001Auto
			MsgStop(STR0061+CHR(10)+STR0060,STR0025)
		endif
		return .f.
	endif
	If TCCanOpen(RetSqlName("VS1"))
		cString := "DELETE FROM "+RetSqlName("VS1")+ " WHERE VS1_FILIAL = '"+ xFilial("VS1")+"' AND VS1_NUMORC= '"+M->VS1_NUMORC+"'"
		TCSqlExec(cString)
	else
		DisarmTransaction()
		if INCLUI
			M->VS1_NUMORC := space(TamSx3("VS1_NUMORC")[1])
		endif
		if !lOX001Auto
			MsgStop(STR0062+CHR(10)+STR0060,STR0025)
		endif
		return .f.
	endif
	If TCCanOpen(RetSqlName("VST"))
		cString := "DELETE FROM "+RetSqlName("VST")+ " WHERE VST_FILIAL = '"+ xFilial("VST")+"' AND VST_TIPO = '1' AND VST_CODIGO= '"+M->VS1_NUMORC+"'"
		TCSqlExec(cString)
	endif
	// #######################################
	// # Gravacao do VS1                     #
	// #######################################
	IF INCLUI
		DBSelectArea("VAI")
		DBSetOrder(6)
		DBSeek(xFilial("VAI") + M->VS1_CODVEN)
	endif
	//
	// MONTA OS CAMPOS DO VS1 DEPENDENTES DE FISCAL
	DBSelectArea("SX3")
	DBSetOrder(1)
	DBSeek("VS1")
	aCmpFis := {}
	while SX3->X3_ARQUIVO=="VS1"
		cValid	:= AllTrim(UPPER(SX3->X3_VALID))
		If "MAFISREF" $ cValid
			nPosRef := AT('MAFISREF("',cValid) + 10
			cRefCols:=Substr(cValid,nPosRef,AT('","VS100",',cValid)-nPosRef )
			aAdd(aCmpFis,{X3_CAMPO,MaFisRet(,cRefCols)})
		EndIf
		DbSkip()
	enddo
	//
	OX0010271_PercentualRemuneracao( .t. ) // Retorna o % de Remuneração
	//
	DBSelectArea("VS1")
	DBSetOrder(1)
	reclock("VS1",.t.)
	FG_GRAVAR("VS1")

	VS1->VS1_RESERV := "0"

	for nCntFor := 1 to Len(aCmpFis)
		&(aCmpFis[nCntFor,1]) := aCmpFis[nCntFor,2]
	next
	IF M->VS1_TIPORC == "1"
		VS1->VS1_CODMAR := ""
	endif
	VS1->VS1_DATALT := dDataBase
	if dDatOrc == ctod("")
		VS1->VS1_DATORC := ddatabase
	else
		VS1->VS1_DATORC := dDatOrc
	endif
	VS1->VS1_VALDES := MaFisRet(,"NF_DESCONTO")
	VS1->VS1_DESCON := MaFisRet(,"NF_DESCONTO")
	VS1->VS1_ICMCAL := MaFisRet(,"NF_VALICM")
	VS1->VS1_VALIPI := MaFisRet(,"NF_VALIPI")
	VS1->VS1_VALCMP := MaFisRet(,"NF_VALCMP")
	VS1->VS1_DIFAL  := OX001TOTPF("ON","DIFAL")
	VS1->VS1_VALIRR := MaFisRet(,"NF_VALIRR")
	VS1->VS1_VALCSL := MaFisRet(,"NF_VALCSL")
	VS1->VS1_VTOTNF := MaFisRet(,"NF_TOTAL") - MaFisRet(,"NF_DESCZF") //OX001TOTPF("ON")
	//
	cOrcOrcT := VS1->VS1_NUMORC
	if lFaturaPVP .and. lPediVenda // .and. !M->VS1_TIPORC $ "P3"
		M->VS1_PEDREF := cNumOrcPed
		VS1->VS1_PEDREF := cNumOrcPed
	elseif lCancParc
		if !ALTERA .or. !lPediVenda // Nao alterar status quando for alteração
			VS1->VS1_PEDSTA := "1"
		Endif
	else
		if !ALTERA .or. !lPediVenda  // Nao alterar status quando for alteração
			VS1->VS1_PEDSTA := "0"
		Endif
	endif
	//
	VS1->VS1_VALDUP := MaFisRet(,"NF_BASEDUP")
	VS1->VS1_NOROUT := "1"
	VS1->VS1_STATUS := cVS1Status
	MSMM(VS1->VS1_OBSMEM,TamSx3("VS1_OBSERV")[1],,&(aMemos[1][2]),1,,,"VS1","VS1_OBSMEM")//gravar a observacao - Rafael - 25/01
	if INCLUI
		VS1->VS1_MVFASE :=  VAI->VAI_MVFASE
	end

	If lPediVenda
		If lTipOrcAtu // Atualiza o campo Tipo de Orcamento? Default .t.
			If !lFaturaPVP .or. ( lFaturaPVP .and. !lFat )
				VS1->VS1_TIPORC := "P"
			Else
				VS1->VS1_TIPORC := "1"
			EndIf
		EndIf
	EndIf
	msunlock()
	If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
		If !Empty(VS1->VS1_PEDREF)
			OA3700021_Grava_DTHR_do_Pedido_para_Orcamento( VS1->VS1_PEDREF , VS1->VS1_NUMORC ) // Gravar Hitorico do Pedido no Orcamento Novo
		EndIf
		OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , IIF(VS1->VS1_TIPORC=="P",STR0374,STR0001) ) // Grava Data/Hora na Mudança de Status do Orçamento / Pedidos de Venda / Orçamento por Fases
	EndIf
	reclock("VS1",.f.)
	// PONTO DE ENTRADA
	If ExistBlock("OX001GVS1") // <<<--- O B S O L E T O
		ExecBlock("OX001GVS1",.f.,.f.)
	EndIf
	If ExistBlock("OX001VS1")
		ExecBlock("OX001VS1",.f.,.f.)
	EndIf
	//
	msunlock()
	DBSelectArea("VS1")
	DBSetOrder(1)
	if !DBSeek(xFilial("VS1")+cOrcOrcT)
		MsgStop(STR0283)
		DisarmTransaction()
		return .f.
	endif

	// #######################################
	// # Gravacao do VPJ - ITENS CONTADOS    #
	// #######################################

	For nCntFor := 1 to Len(aVetCort)
		dbSelectArea("VPJ")
		dbSetOrder(1)
		lAchou := dbSeek(xFilial("VPJ")+aVetCort[nCntFor,2]+aVetCort[nCntFor,5]+aVetCort[nCntFor,6])
		RecLock("VPJ",!lAchou)
		VPJ->VPJ_FILIAL := aVetCort[nCntFor,1]
		VPJ->VPJ_NUMORC := aVetCort[nCntFor,2]
		VPJ->VPJ_DATCAN := aVetCort[nCntFor,3]
		VPJ->VPJ_HORCAN := aVetCort[nCntFor,4]
		VPJ->VPJ_GRUITE := aVetCort[nCntFor,5]
		VPJ->VPJ_CODITE := aVetCort[nCntFor,6]
		VPJ->VPJ_QTDITE := aVetCort[nCntFor,7]
		VPJ->VPJ_VALTOT := aVetCort[nCntFor,8]
		VPJ->VPJ_MOTIVO := aVetCort[nCntFor,9]
		VPJ->VPJ_ORDEM  := aVetCort[nCntFor,10]
		VPJ->VPJ_NOMCLI:= aVetCort[nCntFor,11]
		MsUnlock()
	Next

	For nCntFor := 1 to Len(aVetCortS)
		dbSelectArea("VPM")
		dbSetOrder(1)
		lAchou := dbSeek(xFilial("VPM")+aVetCortS[nCntFor,2]+aVetCortS[nCntFor,5]+aVetCortS[nCntFor,6])
		RecLock("VPM",!lAchou)
		VPM->VPM_FILIAL := aVetCortS[nCntFor,1]
		VPM->VPM_NUMORC := aVetCortS[nCntFor,2]
		VPM->VPM_DATCAN := aVetCortS[nCntFor,3]
		VPM->VPM_HORCAN := aVetCortS[nCntFor,4]
		VPM->VPM_GRUSER := aVetCortS[nCntFor,5]
		VPM->VPM_CODSER := aVetCortS[nCntFor,6]
		VPM->VPM_TIPSER := aVetCortS[nCntFor,7]
		VPM->VPM_VALVEN := aVetCortS[nCntFor,8]
		VPM->VPM_MOTIVO := aVetCortS[nCntFor,9]
		VPM->VPM_ORDEM  := aVetCortS[nCntFor,10]
		VPM->VPM_NOMCLI:= aVetCortS[nCntFor,11]
		MsUnlock()
	Next

	aVetCort := {}
	aVetCortS := {}

	// #######################################
	// # Gravacao do VST - INCONVENIENTES    #
	// #######################################
	if VS1->VS1_TIPORC == "2" .and. lInconveniente
		nPosSeqInc := FG_POSVAR("VST_SEQINC","aHeaderI")
		nPosDesInc := FG_POSVAR("VST_DESINC","aHeaderI")
		// ##################################################
		// Verifica se o orcamento possui inconveniente novo
		// ##################################################
		For nCntFor := 1 to Len(oGetInconv:aCols)
			// Sequencia em branco e com descricao gravada
			lNovoInconv := (Empty(oGetInconv:aCols[nCntFor,nPosSeqInc]) .and. !Empty(oGetInconv:aCols[nCntFor,nPosDesInc]))
		Next nCntFor

		// #########################################################################################
		// Grava os Inconvenientes na VST
		// aCols é passada por Referencia, pois se tiver novos, ele preenchera o campo de SEQUENCIA
		// #########################################################################################
		VV1->(DbSetOrder(1))
		VV1->(DbSeek(xFilial("VV1")+VS1->VS1_CHAINT))
		OM420GRAVA( @oGetInconv:aCols , aHeaderI , "1" , VS1->VS1_NUMORC , VV1->VV1_CODMAR , VV1->VV1_CHASSI )
		oGetInconv:oBrowse:Refresh()
		// Se tiver novos, atualizar a aCols de Pecas e Servicos
		if lNovoInconv
			// Pecas
			nPosSeqInc := FG_POSVAR("VS3_SEQINC","aHeaderP")
			nPosGruInc := FG_POSVAR("VS3_GRUINC","aHeaderP")
			nPosCodInc := FG_POSVAR("VS3_CODINC","aHeaderP")
			nPosDesInc := FG_POSVAR("VS3_DESINC","aHeaderP")
			For nCntFor := 1 to Len(oGetPecas:aCols)
				// Verifica se nao eh uma linha em branco na acols
				If !Empty(oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_CODITE","aHeaderP")])
					// Se tiver vazio, trata-se de uma peca de um inconveniente novo
					if Empty(oGetPecas:aCols[nCntFor, nPosSeqInc])
						// Se o grupo e codigo estiver em branco, procurar por descricao
						if empty(oGetPecas:aCols[nCntFor,nPosGruInc]) .and. empty(oGetPecas:aCols[nCntFor,nPosCodInc])
							oGetPecas:aCols[nCntFor, nPosSeqInc] := OM420CONSINC( "1" , VS1->VS1_NUMORC,,,,oGetPecas:aCols[nCntFor,nPosDesInc] )[4]
						else
							oGetPecas:aCols[nCntFor, nPosSeqInc] := OM420CONSINC( "1" , VS1->VS1_NUMORC,,oGetPecas:aCols[nCntFor,nPosGruInc],oGetPecas:aCols[nCntFor,nPosCodInc] )[4]
						endif
					endif
				endif
			Next nCntFor
			oGetPecas:oBrowse:Refresh()
			// Servicos
			nPosSeqInc := FG_POSVAR("VS4_SEQINC","aHeaderS")
			nPosGruInc := FG_POSVAR("VS4_GRUINC","aHeaderS")
			nPosCodInc := FG_POSVAR("VS4_CODINC","aHeaderS")
			nPosDesInc := FG_POSVAR("VS4_DESINC","aHeaderS")
			For nCntFor := 1 to Len(oGetServ:aCols)
				// Verifica se nao eh uma linha em branco na aCols
				if !Empty(oGetServ:aCols[nCntFor,FG_POSVAR("VS4_CODSER","aHeaderS")])
					// Se tiver vazio, trata-se de uma peca de um inconveniente novo
					if Empty(oGetServ:aCols[nCntFor, nPosSeqInc])
						// Se o grupo e codigo estiver em branco, procurar por descricao
						if empty(oGetServ:aCols[nCntFor,nPosGruInc]) .and. empty(oGetServ:aCols[nCntFor,nPosCodInc])
							oGetServ:aCols[nCntFor, nPosSeqInc] := OM420CONSINC( "1" , VS1->VS1_NUMORC,,,,oGetServ:aCols[nCntFor,nPosDesInc] )[4]
						else
							oGetServ:aCols[nCntFor, nPosSeqInc] := OM420CONSINC( "1" , VS1->VS1_NUMORC,,oGetServ:aCols[nCntFor,nPosGruInc],oGetServ:aCols[nCntFor,nPosCodInc] )[4]
						endif
					endif
				endif
			Next nCntFor
			oGetServ:oBrowse:Refresh()
			//
		endif
	endif
	//

	If lPediVenda .and. lFaturaPVP
		If !OX0010241_SaldoPromocao( .t. , STR0391+" "+VS1->VS1_PEDREF ) // Geração do Orçamento pelo Pedido
			DisarmTransaction()
			return .F.
		EndIf
	EndIf
	//
	// #######################################
	// # Gravacao do VS3                     #
	// #######################################
	nVS3Seq := 1
	DBSelectArea("VS3")

	aOrcIte := {}

	for nCntFor := 1 to Len(oGetPecas:aCols)

		cMot     := oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_MOTPED","aHeaderP")]
		lDeleted := oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])]
		lNaOfi   := ( M->VS1_TIPORC == "2" .AND. GetNewPar("MV_MIL0011","0") == "1" ) // registra na oficina?

		if (lNaOfi .AND. !Empty(cMot)) .OR. ( !Empty(cMot) .AND. !lDeleted ) .OR. ( !Empty(oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_CODITE","aHeaderP")]) .AND. !lDeleted )

			If !lDeleted
				dbSelectArea("VPJ")
				dbSetOrder(1)
				if dbSeek(xFilial("VPJ")+M->VS1_NUMORC+oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_GRUITE","aHeaderP")]+oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_CODITE","aHeaderP")])
					reclock("VPJ",.f.,.t.)
					dbdelete()
					msunlock()
				Endif
			EndIf

			// MONTA OS CAMPOS DO VS3 DEPENDENTES DE FISCAL
			DBSelectArea("SX3")
			DBSetOrder(1)
			DBSeek("VS3")
			aCmpFis := {}
			while SX3->X3_ARQUIVO=="VS3"
				cValid	:= AllTrim(UPPER(SX3->X3_VALID))
				If "MAFISREF"$cValid
					oGetPecas:nAt := nCntFor
					OX001PecFis()
					nPosRef := AT('MAFISREF("',cValid) + 10
					cRefCols:=Substr(cValid,nPosRef,AT('","VS300",',cValid)-nPosRef )
					if Alltrim(SX3->X3_CAMPO) == "VS3_ICMCAL"
						aLivro := MaFisRet(n,"IT_LIVRO")
						aAdd(aCmpFis,{X3_CAMPO,aLivro[5]})
					else
						aAdd(aCmpFis,{X3_CAMPO,MaFisRet(n,cRefCols)})
					endif
					OX001FisPec()
				EndIf
				DbSkip()
			enddo
			//
			reclock("VS3",.t.)
			VS3->VS3_FILIAL := xFilial("VS3")
			VS3->VS3_NUMORC := VS1->VS1_NUMORC
			//VS3_SEQUEN := STRZERO(nVS3Seq,TamSX3("VS3_SEQUEN")[1])
			for nCntFor2 := 1 to Len(aHeaderP)
				if IsHeadRec(aHeaderP[nCntFor2,2])
					oGetPecas:aCols[nCntFor,nCntFor2] := VS3->(RecNo())
				elseif IsHeadAlias(aHeaderP[nCntFor2,2])
					oGetPecas:aCols[nCntFor,nCntFor2] := "VS3"
				elseif aHeaderP[nCntFor2,10] <> "V"
					if  Alltrim(aHeaderP[nCntFor2,2]) == "VS3_MARLUC"
						if oGetPecas:aCols[nCntFor,nCntFor2] < -9999.99
							&(aHeaderP[nCntFor2,2]) := -9999.99
						elseif oGetPecas:aCols[nCntFor,nCntFor2] > 9999.99
							&(aHeaderP[nCntFor2,2]) := 9999.99
						else
							&(aHeaderP[nCntFor2,2]) := oGetPecas:aCols[nCntFor,nCntFor2]
						endif
					else
						&(aHeaderP[nCntFor2,2]) := oGetPecas:aCols[nCntFor,nCntFor2]
					endif
				endif
			next
			for nCntFor2 := 1 to Len(aCmpFis)
				&(aCmpFis[nCntFor2,1]) := aCmpFis[nCntFor2,2]
			next
			nPosA := At(cVS1Status,cFaseOrc)
			nPos5 := At("5",cFaseOrc)
			if iIf(nPos5 > 0, nPosA < nPos5,.t.) .OR. At(cFaseConfer,cFaseOrc) == 0
				VS3->VS3_QTDINI := VS3_QTDITE
			endif

			// Este bloco recupera os valores do nivel de atendimento perdidos no delete da oficina
			lExistia := .F.
			for nCntfor2 := 1 to LEN(aCache)
				oReg := aCache[nCntfor2]

				if AllTrim(oReg:GetValue("VS3_GRUITE")) == AllTrim(VS3->VS3_GRUITE) .and. ;
				   AllTrim(oReg:GetValue("VS3_CODITE")) == AllTrim(VS3->VS3_CODITE) .and. ;
				   AllTrim(oReg:GetValue("VS3_NUMLOT")) == AllTrim(VS3->VS3_NUMLOT) .and. ;
				   AllTrim(oReg:GetValue("VS3_LOTECT")) == AllTrim(VS3->VS3_LOTECT)
					lExistia := .T.
					VS3->VS3_QTDINI := oReg:GetValue("VS3_QTDINI")
					VS3->VS3_QTDPED := oReg:GetValue("VS3_QTDPED")
					VS3->VS3_QESTNA := oReg:GetValue("VS3_QESTNA")
					exit
				EndIf
			Next


			if ! lExistia
				if lPediVenda .and. (INCLUI .or. lAltPedVda)
					SB1->(DBSetOrder(7))
					SB1->(DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
					SB1->(DBSetOrder(1))
					VS3->VS3_QTDINI := VS3_QTDITE
					VS3->VS3_QTDPED := VS3_QTDITE
					VS3->VS3_QESTNA := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_LOCAL","aHeaderP")])
					/* jogo no qestna o saldo que vem de trasferencia */
					VS3->VS3_QESTNA += OX0010084_TotalNaFilialArmazem(nCntFor, VS3->VS3_GRUITE, VS3->VS3_CODITE)
				elseif VS1_TIPORC == "2"
					SB1->(DBSetOrder(7))
					SB1->(DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
					SB1->(DBSetOrder(1))
					// if VS3->VS3_QTDINI == 0
						VS3->VS3_QESTNA := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_LOCAL","aHeaderP")])
						/* jogo no qestna o saldo que vem de trasferencia */
						VS3->VS3_QESTNA += OX0010084_TotalNaFilialArmazem(nCntFor, VS3->VS3_GRUITE, VS3->VS3_CODITE)
					// endif
					VS3->VS3_QTDINI := VS3_QTDITE
				endif

				// Mostrar o saldo em estoque após a gravação
				If GetNewPar("MV_MIL0011","0") == "1" .and. oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_QTDEST","aHeaderP")] == 0
					SB1->(DBSetOrder(7))
					SB1->(DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
					SB1->(DBSetOrder(1))
					nSdoPecas := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_LOCAL","aHeaderP")])
					// dependendo do TES, questiona-se o saldo da peca
					SF4->(DbSeek(xFilial("SF4")+oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODTES","aHeaderP")]))
					if nSdoPecas <= 0 .and. SF4->F4_ESTOQUE == "S"
						if Type("M->VS3_QTDEST") == "U"
							if !lOX001Auto
								MsgInfo(STR0102+Alltrim(SB1->B1_GRUPO)+" "+Alltrim(SB1->B1_CODITE)+" - "+Alltrim(SB1->B1_DESC)+STR0103,STR0025)
							endif
						Endif
					Endif

					M->VS3_QTDEST := nSdoPecas
					oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_QTDEST","aHeaderP")] := nSdoPecas
				Endif
			Else
				// Alteração Manoel - 13/07/2016 - Chamado 005475 - PROBLEMAS NO ORCAMENTO - MAQNELSON
				if lPediVenda .and. (INCLUI .or. lAltPedVda)
					VS3->VS3_QTDPED := VS3->VS3_QTDITE
				Endif
				//
			EndIf


			If lNewRes 
			
				If lResOrc .or. VS3->VS3_RESERV == "1"
					If VS3->VS3_QTDITE <> VS3->VS3_QTDRES
						aAdd(aOrcIte,{VS3->(RecNo()),nCntFor})
						VS3->VS3_QTDINI := VS3->VS3_QTDITE
					EndIf
				EndIf

			Else

				if lResOrc
					if Alltrim(oGetPecas:aCols[nCntFor, FG_POSVAR("VS3_RESERV","aHeaderP")]) != "1"
						If oGetPecas:aCols[nCntFor, FG_POSVAR("VS3_QTDEST","aHeaderP")] > 0
							oGetPecas:aCols[nCntFor, FG_POSVAR("VS3_RESERV","aHeaderP")] := "1"
							VS3->VS3_RESERV := "1"
						Endif
						VS3->VS3_QTDINI := VS3->VS3_QTDITE
						aAdd(aResSeq,VS3->VS3_SEQUEN)
					endif
				endif

			EndIf

			msunlock()

			// Atualizar IsHeadRec (caso não funcione dentro do For da gravação normal)

			nVS3Seq ++

			// PONTO DE ENTRADA
			If ExistBlock("OX001GVS3")  // <<<--- O B S O L E T O
				ExecBlock("OX001GVS3",.f.,.f.)
			EndIf
			If ExistBlock("OX001VS3")
				ExecBlock("OX001VS3",.f.,.f.)
			EndIf

		endif

		if lBo
			cQuery := " SELECT * FROM " + RetSQLName('VS3') + " WHERE VS3_FILIAL = '" + xFilial('VS3') + "' AND VS3_NUMORC = '" + cNumOrcPed + "' AND D_E_L_E_T_ = ' ' "
			If Select("QRYVS3DB") > 0
				QRYVS3DB->(DBCloseArea())
			Endif
			TcQuery cQuery New Alias "QRYVS3DB"

			While !EOF()
				aadd(aQVS3UPD,;
					{QRYVS3DB->VS3_DOCSDB,;
					QRYVS3DB->VS3_FILIAL,;
					QRYVS3DB->VS3_NUMORC,;
					QRYVS3DB->VS3_GRUITE,;
					QRYVS3DB->VS3_CODITE};
				)
				QRYVS3DB->(DBSkip())
			EndDo

			QRYVS3DB->(DBCloseArea())

			For nI := 1 to len(aQVS3UPD)
				cQuery := " "
				cQuery += " UPDATE " + RetSqlName('VS3') + " SET "
				cQuery += " 	VS3_DOCSDB = '" + aQVS3UPD[nI][1] + "',  "
				cQuery += " 	VS3_RESERV = '1' "
				cQuery += " WHERE "
				cQuery += "		VS3_FILIAL = '" + aQVS3UPD[nI][2] + "' "
				cQuery += "     AND VS3_NUMORC = '" + aQVS3UPD[nI][3] + "' "
				cQuery += "     AND VS3_GRUITE = '" + aQVS3UPD[nI][4] + "' "
				cQuery += "     AND VS3_CODITE = '" + aQVS3UPD[nI][5] + "' "
				cQuery += "     AND D_E_L_E_T_ = ' ' "

				if TCSqlExec(cQuery) < 0
					MsgStop(STR0335) // Problema ao Gravar o documento DOCSDB.
					DisarmTransaction()
					return .F.
				EndIf
			Next
		EndIf

	next

	If ( lNewRes .and. Len(aOrcIte) > 0 )
		cDocto := OA4820015_ProcessaReservaItem(cOrigem,VS1->(RecNo()),"M",,aOrcIte,cTipo,,lSugCpa)
		if Empty(cDocto)
			DisarmTransaction()
			return .f.
		EndIf
		OX0010275_AtualizaDadosOrcamento(aOrcIte,cDocto)
	Elseif ( (lResOrc .or. VS1->VS1_RESERV == "1") .and. len(aResSeq) > 0 )
		cDocto := OX001RESITE(VS1->VS1_NUMORC,.t.,aResSeq )
		if Empty(cDocto)
			DisarmTransaction()
			lResOrc := .f.
			for nCntFor := 1 to Len(oGetPecas:aCols)
			    If Len(aResSeq) > 0
			       nPosRestAcols := aScan(aResSeq,oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_SEQUEN","aHeaderP")])
			       If nPosRestAcols > 0
				       oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_RESERV","aHeaderP")] := "0"
			       Endif
			    Endif
			Next
			return .f.
		endif
	endif
	// #######################################
	// # Gravacao do VS4                     #
	// #######################################
	nVS4Seq := 1
	DBSelectArea("VS4")
	for nCntFor := 1 to Len(oGetServ:aCols)
		if !oGetServ:aCols[nCntFor,len(oGetServ:aCols[nCntFor])] .and. !Empty(oGetServ:aCols[nCntFor,FG_POSVAR("VS4_CODSER","aHeaderS")])

			dbSelectArea("VPM")
			dbSetOrder(1)
			if dbSeek(xFilial("VPM")+M->VS1_NUMORC+oGetServ:aCols[nCntFor,FG_POSVAR("VS4_GRUSER","aHeaderS")]+oGetServ:aCols[nCntFor,FG_POSVAR("VS4_CODSER","aHeaderS")])
				reclock("VPM",.f.,.t.)
				dbdelete()
				msunlock()
			Endif

			reclock("VS4",.t.)
			VS4_FILIAL := xFilial("VS4")
			VS4_NUMORC := VS1->VS1_NUMORC
			//VS4_SEQUEN := STRZERO(nVS4Seq,TamSX3("VS4_SEQUEN")[1])
			for nCntFor2 := 1 to Len(aHeaderS)
				if aHeaderS[nCntFor2,10] <> "V"
					&(aHeaderS[nCntFor2,2]) := oGetServ:aCols[nCntFor,nCntFor2]
				endif
			next
			MSMM(VS4->VS4_OBSMEM,TamSx3("VS4_OBSERV")[1],,oGetServ:aCols[nCntFor,FG_POSVAR("VS4_OBSERV","aHeaderS")],1,,,"VS4","VS4_OBSMEM")
			msunlock()
			nVS4Seq++
		endif
	next
	// #######################################
	// # Gravacao do VDD                     #
	// #######################################

	for nCntFor := 1 to Len (aPedTransf)
		DBSelectArea("VDD")
		DBSetOrder(4)

		aRetVDD := OXA0200045_LevantaPedidoTransferencia(xFilial("VS1"), VS1->VS1_NUMORC, aPedTransf[nCntFor,1], aPedTransf[nCntFor,2], aPedTransf[nCntFor,5], "E" )

		if Len(aRetVDD) == 0
			cCodVDD := GetSxENum("VDD","VDD_CODIGO")
			ConfirmSX8()
			reclock("VDD",.t.)
			VDD->VDD_FILIAL := xFilial("VDD")
			VDD->VDD_CODIGO := cCodVDD
			VDD->VDD_FILORC := xFilial("VS1")
			VDD->VDD_NUMORC := VS1->VS1_NUMORC
			VDD->VDD_FILPED := aPedTransf[nCntFor,5]
			VDD->VDD_GRUPO := aPedTransf[nCntFor,1]
			VDD->VDD_CODITE := aPedTransf[nCntFor,2]
			VDD->VDD_STATUS := "S"
			VDD->VDD_QUANT := aPedTransf[nCntFor,4]
			VDD->VDD_TIPTRA := "0" // Avulsa
			VDD->VDD_VENTRA := VS1->VS1_CODVEN
			msunlock()
		endif
	next

	IF !lChmPER .and. ExistBlock("PERESITE") // Alterado por Manoel/Thiago pois no cliente Jaracatia estava sendo chamado o MATA261 2X (Alteração temporaria pois o Rubens esta revendo o processo de reserva)
		ExecBlock("PERESITE",.f.,.f.,{"OFIXX001G"})
	Endif

	// -----------------------------------------------
	// Gravação do STATUS DA RESERVA no VS1 (VS1_STARES)
	// -----------------------------------------------
	lTemResS := .f.
	lNTemRes := .f.

	DBSelectArea("VS3")
	DBSetOrder(1)
	DBSeek(xFilial("VS3")+ VS1->VS1_NUMORC)
	//
	while !eof() .and. xFilial("VS3") + VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
		if 	Alltrim(VS3->VS3_RESERV) == "1"
			lTemResS := .t.
		else
			lNTemRes := .t.
		endif
		DBSkip()
	enddo
	if VS1->VS1_STATUS == '0'
		DBSelectArea("VS1")
		reclock("VS1",.f.)
		if lTemResS .and. !lNTemRes
			VS1_STARES := "1"
		elseif lTemResS .and. lNTemRes
			VS1_STARES := "2"
		elseif lNTemRes
			VS1_STARES := "3"
		endif
	else
		nPosR := At("R",cFaseOrc)
		nPosA := At(VS1->VS1_STATUS,cFaseOrc)
		if nPosA > nPosR .and. nPosR > 0
			VS1_STARES := "1"
		endif
	endif

	M->VS1_STARES := VS1_STARES

	// -----------------------------------------------
	// Gravação do STATUS DA RESERVA no VS1 (VS1_STARES)
	// -----------------------------------------------
	if INCLUI
		ConfirmSX8()
		If !lPediVenda
			INCLUI := .f.
			ALTERA := .t.
		Endif
	endif
endif
//
// ------------------------------------------------------------------------------------------------------------
END TRANSACTION // --------F-I-N-A-L---D-A---T-R-A-N-S-A-C-A-O-------------------------------------------------
// ------------------------------------------------------------------------------------------------------------
If !lPediVenda .AND. lMsgGrv
	if !lChmPER .and. !lOX001Auto .and. nOpc <> 2 .and. lMsgGrv
		MsgInfo(STR0063+Alltrim(M->VS1_NUMORC),STR0025)
	endif
Else
	If nOpc == 3 .and. !lMsg0268
		MsgInfo(STR0268 + Alltrim(M->VS1_NUMORC) ,STR0025)
		lMsg0268 := .t.
	ElseIf nOpc == 4 .and. lFaturaPVP
		If FM_PILHA("OX001FAT")
			MsgInfo(STR0063+Alltrim(M->VS1_NUMORC),STR0025)
		Else
			MsgInfo(STR0268 + Alltrim(M->VS1_NUMORC) ,STR0025)
			lMsg0268 := .t.
		Endif
	Endif
Endif
//
If ExistBlock("OX001DGR")
	ExecBlock("OX001DGR",.f.,.f.)
EndIf
//
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001FAT    |Autor  |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Faturamento do Orcamento                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001FAT(nOpc, lSoGravar, lMsgGrv, lSugCpa)
// ############################################################
// # Verifica se trata-se de CANCELAMENTO DE ORCAMENTO        #
// ############################################################
Local cOrcAtu    := VS1->VS1_NUMORC
Local nCntFor
Local lret       := .t.
Local lAbortProc
Local aInconv
Local cMotCancel := ""
Local aSrvcAdic  := {} // Servicos adicionais de 1ª Revisao (Orc. Oficina com Inc. de Revisao)
Local cCpoAlt    := "" // Lista dos campos que poderão ser alterados
Local aCpoAlt    := {} // Controla os Campos que poderão sofrer alteracoes na VO1
Local nPos       := 0
Local nCol       := 42
Local nLin       := 4
Local nDisLin    := 11
Local nTamGet    := 0
Local lOkOSV     := .f.
Local cObjGName  := ""
Local cMsgErroInc:= "" // Critica retornada pelo OM420VALINC
Local lRetT      := .t.
Local cAlias     := VAI->(GetArea())
Local lPedApr    := .t. //exibe a janela que pede autorizacao de aprovacao
Local cIncMob    := "" // IncMob do VOK (Servico)
Local cNroOS     := ""
Local lNovaOS    := .f.
Local cVO6FILIAL := xFilial("VO6")
Local cVO6CODMAR := space(TamSX3("VO6_CODMAR")[1])
Local cVO6GRUSER := substr( GetNewPar("MV_MIL0080","") + space(15) , 05 , 02 ) // Grupo de Servico
Local aVO4Uti    := {}
Local nQtdVO4    := 0
Local nQtdVS4    := 0
Local nQtdVO6    := 0
Local cQuery     := ""
Local cQAlias    := "SQLVS4"
Local lAltPosSA1 := .f.
Local nImprRoman := 0
Local lMovtoReserva := GetNewPar("MV_RITEORC","N") == "S"
Local lSugCompra  := GetNewPar("MV_SUGCOS","N") == "S"
Local lESTNEG     := GetNewPar("MV_ESTNEG","S") == "S"
Local nRecVO1     := 0

Local lNewRes     := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?
Local lChkFase    := .t.
Local cTipo       := "01"
Local cOrigem     := "OR"
//
Private cMotivo := "000004"  //Filtro da consulta do motivo de Cancelamentos (Orcamento)
Private cNumOrd := "" //numero do orcamento

Default lMsgGrv   := .T.
Default lSugCpa   := .f.
Default lSoGravar := .f.

//Verifica se existe o paramentro 2 da pergunta OF011F12
If ( SX1->( DbSeek( PadR("OF011F12" , Len(SX1->X1_GRUPO) ) + "02" ) ) )
	Pergunte("OF011F12",.f.)
	nImprRoman := MV_PAR02
EndIf

if M->VS1_TIPORC == "2" .and. !lPediVenda
	// Desabilitar a Sugestao de Compra caso MV_ESTNEG igual a S e Tem Reserva na Exportação do Orçamento para a OS
	If lSugCompra .and. lESTNEG .and. lMovtoReserva
		lSugCompra := .f. // NAO sera realizada a Sugestao de Compra na funçao FM_IMPVSJ - VEIFUNB
	EndIf
EndIf

// ##############################################################################
// Verifica se estourou tamanho do Acols de Peças para de acordo com MV_NUMITEN #
// ##############################################################################
if !FS_QTDLIN("2")
	Return(.f.)
Endif
//
If nOpc == 3 .or. nOpc == 4
	If !OX0010221_TemRemuneracao( M->VS1_FORPAG ) // Valida se existe Cadastro do Percentual de Remuneração
		Return .f.
	EndIf
EndIf
//
if ExistBlock("OXA001DBFAT")  // <<<--- O B S O L E T O
	if !ExecBlock("OXA001DBFAT",.f.,.f.)
		Return(.f.)
	Endif
Endif
//
if ExistBlock("OX001FAT")
	if !ExecBlock("OX001FAT",.f.,.f.)
		Return(.f.)
	Endif
Endif

If M->VS1_TIPORC == "2"
	cTipo := "07"
EndIf

If lPediVenda
	cOrigem := "PD"
EndIf

aMotCancel := {}
if EXCLUI

	cTipo := "02"
	If cOrigem == "PD"
		cTipo := "05"
	ElseIf M->VS1_TIPORC == "2"
		cTipo := "10"
	EndIf

	if lOX001Auto .or. MsgYesNo(STR0064,STR0025)
		BEGIN TRANSACTION
		//
		if ExistBlock("OX01CANCEL") // <<<--- O B S O L E T O
			if !ExecBlock("OX01CANCEL",.f.,.f.)
				DisarmTransaction()
				Return(.f.)
			Endif
		Endif
		if ExistBlock("OX001CAN")
			if !ExecBlock("OX001CAN",.f.,.f.)
				DisarmTransaction()
				Return(.f.)
			Endif
		Endif

		If nVS3SEQVEN > 0 .and. ( VS1->VS1_STATUS <> "0" .or. !Empty(VS1->VS1_PEDREF) ) // Quando for Orçamento Balcão com Status diferente de 0-Digitado ou Orçamento Balcão que foi originado do Pedido
			// Devolver Saldo em Promoção
			for nCntFor := 1 to Len(oGetPecas:aCols)
				If oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_PROMOC","aHeaderP")] == "1"
					OA4410011_Incluir_Movimentacoes_Promocao( oGetPecas:aCols[nCntFor,nVS3SEQVEN] , "2" , oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_QTDITE","aHeaderP")] , VS1->VS1_FILIAL , VS1->VS1_NUMORC , oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_SEQUEN","aHeaderP")] , STR0390 ) // Cancelamento do Orçamento
				EndIf
			next
		EndIf

		If ( lNewRes ) // Chama desreserva de todos os itens que foram reservados
			cDocto := OA4820015_ProcessaReservaItem(cOrigem,VS1->(RecNo()),"A","D",,cTipo)
			if Empty(cDocto)
				MsgStop(STR0275)
				DisarmTransaction()
				return .f.
			else
				// desreserva
				if ExistBlock("ORDBUSCB")
					ExecBlock("ORDBUSCB",.f.,.f.,{"OR","CANCELA"})
				Endif
			endif
		Else

			aResDel := {}
			for nCntFor := 1 to Len(oGetPecas:aCols)
				if oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])] == .f.
					if oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_RESERV","aHeaderP")] == "1"
						DBSelectArea("VS3")
						DBSetOrder(2)
						if DBSeek(xFilial("VS3") + M->VS1_NUMORC + oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_GRUITE","aHeaderP")] + oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_CODITE","aHeaderP")]+oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_SEQUEN","aHeaderP")] )
							aAdd(aResDel,VS3->VS3_SEQUEN)
						endif
						oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_RESERV","aHeaderP")] := "0"
					endif
				endif
			next

			if Len(aResDel) > 0
				cDocto := OX001RESITE(VS1->VS1_NUMORC,.f.,aResDel )
				if Empty(cDocto)
					MsgStop(STR0275)
					DisarmTransaction()
					return .f.
				else
					// desreserva
					if ExistBlock("ORDBUSCB")
						ExecBlock("ORDBUSCB",.f.,.f.,{"OR","CANCELA"})
					Endif
				endif
			endif
		EndIf

		If !lOX001Auto
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Motivo do Cancelamento do Orcamento     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While Len(aMotCancel) == 0
				aMotCancel := OFA210MOT(cMotivo,"4",xFilial("VS1"),M->VS1_NUMORC,.T.)
			EndDo
			cMotCancel := aMotCancel[1]
		EndIf
		DBSelectArea("SX2")
		// Se for orcamento de Oficina, exclui pedido de garantia mutua (se for necessario)
		If VS1->VS1_TIPORC == "2"
			If !OA550CANPED( VS1->VS1_NUMORC )
				DisarmTransaction()
				MostraErro()
				Return .f.
			EndIf
		EndIf
		//
		If OXI001REVF(VS1->VS1_NUMORC, "0")
			DBSelectArea("VS1")
			DBSetOrder(1)
			DBSeek(xFilial("VS1")+VS1->VS1_NUMORC)
			//
			DBSelectArea("VS1")
			reclock("VS1",.f.)
			//
			cVS1StAnt := VS1->VS1_STATUS
			//
			VS1->VS1_STATUS := "C"
			VS1->VS1_STARES := "3"
			//
			If !Empty(cMotCancel)
				VS1->VS1_MOTIVO := cMotCancel
			EndIf
			msunlock()
			If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
				OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , IIF(VS1->VS1_TIPORC=="P",STR0374,STR0001) ) // Grava Data/Hora na Mudança de Status do Orçamento / Pedidos de Venda / Orçamento por Fases
			EndIf
			//
			If ExistFunc("FM_GerLog")
				//grava log das alteracoes das fases do orcamento
				FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,cVS1StAnt)
			EndIF
			//
			If !Empty(cMotCancel) .and. aMotCancel[3]
				OX001CEV("C",VS1->VS1_NUMORC,VS1->VS1_TIPORC) // Gerar CEV no Cancelamento do Orcamento
			endif
			//
			If ExistFunc("OM350STATUS")
				OM350STATUS(VS1->VS1_NUMAGE,"2","4")
			EndIf
			//
			oDlgXX001:End()
			//
			if ExistBlock("OX001DCN")
				ExecBlock("OX001DCN",.f.,.f.)
			Endif
		else
			DisarmTransaction()
			MsgInfo(STR0065,STR0025)
			lRetT := .f.
		endif
		//
		End Transaction()

		return lRetT
	else
		return .f.
	endif
	return .t.
endif
// ############################################################
// # Verifica se trata-se de VISUALIZACAO DE ORCAMENTO        #
// ############################################################
if !lOX001Auto
	if VISUALIZA
		oDlgXX001:end()
		return .t.
	endif
	// ############################################################
	// # Pergunta se deseja faturar realmente                     #
	// ############################################################
	if M->VS1_TIPORC == "1" .and. !lPediVenda .and. !FM_PILHA("OX001GSUG") // e não for a criação da sugestão de compras.
		if !MsgYesNo(STR0067,STR0025)
			return .f.
		endif
	endif
endif
// ############################################################
// # Verifica o preenchimento do campo Natureza               #
// ############################################################
if M->VS1_TIPORC == "1" .and. !lPediVenda
	If ( "C5_NATUREZ" $ Upper(SuperGetMv("MV_1DUPNAT",.F.,"")) ) .and. SC5->(ColumnPos("C5_NATUREZ")) <> 0 .and. Empty(M->VS1_NATURE)
		if !lOX001Auto
			MsgStop(STR0322,STR0025)
		EndIf
		Return .f.	
	EndIf
EndIf
///////////////////////////////////////////////////////////////
If ExistBlock("OX001OK")
	If !ExecBlock("OX001OK",.f.,.f.)
		return .f.
	Endif
EndIf
// ############################################################
// # Grava o orcamento (VS1,VS3,VS4)                          #
// ############################################################
if !(cVS1Status $ ("23"+cFaseConfer))
	if !OX001GRV(nOpc,.t.,,,,,,lSugCpa)
		return .f.
	endif
	cOrcAtu := VS1->VS1_NUMORC
endif

If lSoGravar
	Return .t.
EndIf

// ############################################################
// # A fase 4 (conferencia deve ser realizada pelo estoque    #
// ############################################################
if cVS1Status == cFaseConfer
	if !lOX001Auto
		MsgInfo(STR0068,STR0025)
	endif
	return .f.
endif
// ############################################################
// # Fase A (aguardando peças)  #
// ############################################################
/*if cVS1Status == "A"
	cQuery := "SELECT VS3.R_E_C_N_O_ VS3RECNO "
	cQuery += " FROM " + RetSqlName("VS3") + " VS3 "
	cQuery += " WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
	cQuery += 	" AND VS3.VS3_NUMORC = '" + VS1->VS1_NUMORC + "' "
	cQuery += 	" AND ( VS3.VS3_QTDAGU > 0 "
	cQuery += 	" OR VS3.VS3_QTDTRA > 0 )"
	cQuery += 	" AND VS3.D_E_L_E_T_ = ' '"

	If FM_SQL(cQuery) > 0
		MsgInfo("Há itens no orçamento aguardando a entrada em estoque. Assim não é permitido avançar.","Atenção")
		return .f.
	EndIf
endif*/
// ##########################################################################
// # I N I C I A   O   P R O C E S S O   D E   F A T U R A M E N T O        #
// ##########################################################################
if M->VS1_TIPORC == "2" .and. !lPediVenda
	// Dar o tratamento aqui para verificar pendência de O.S.
	if ExistBlock("OX001VPO") // Antes da Exportacao
		lRet := ExecBlock("OX001VPO",.f.,.f.)
		If !lRet
			Return (lRet)
		Endif
	Endif
	if VS1->VS1_STATUS == "P"
		MsgStop(STR0185,STR0025)
		oDlgXX001:end()
		return .f.
	endif

	DBSelectArea("VAI")
	DBSetOrder(4)
	DBSeek(xFilial("VAI")+__cUserId)
	if VAI->VAI_EXPOOS == "0" //Usuario não exporta para OS
		MsgInfo(STR0323,STR0025)
		return .f.
	endif
	
	cTpSrvErr := ""
	lRet := .t.
	If !Empty(M->VS1_TIPTSV)
		VOI->(DbSetOrder(1))
		VOI->(MsSeek( xFilial("VOI") + VS1->VS1_TIPTSV ) )
		if VOI->VOI_CONVOX == "1" .or. VOI->VOI_CONGSV == "1"
			DbSelectArea("VS4")
			DbSetOrder(1)
			DbSeek(xFilial("VS4")+VS1->VS1_NUMORC)
			While !Eof() .and. xFilial("VS4")==VS4->VS4_FILIAL .and. VS4->VS4_NUMORC==VS1->VS1_NUMORC
				DbSelectArea("VOX")
				DbSetOrder(1)
				if VOI->VOI_CONVOX == "1"
					If !DBSeek(xFilial("VOX")+VS4->VS4_TIPSER+VS1->VS1_TIPTSV)
						If !(VS4->VS4_TIPSER $ cTpSrvErr)
							cTpSrvErr += Alltrim(VS4->VS4_TIPSER)+"/"
						EndIf
						lRet:=.F.
					EndIf
				EndIf
				If lFuncOM030GRUSRV
					If !OM030GRUSRV(VS4->VS4_GRUSER,;
									VS1->VS1_TIPTSV,;
									VS1->VS1_CODMAR,;
									.t.)
						lRet:=.F.
						Exit
					EndIf
				EndIF

				DbSelectArea("VS4")
				DBSkip()
			enddo
		EndIf
	endif
	if !lRet
		If !Empty(cTpSrvErr)
			MsgInfo(STR0160+ " ("+Alltrim(cTpSrvErr)+")",STR0025) //"Tipo de serviço não está associado ao tipo de tempo!","Atenção"
		EndIf
		return .f.
	endif

	lRet := .t.
	If !Empty(M->VS1_TIPTEM)
		VOI->(DbSetOrder(1))
		VOI->(MsSeek( xFilial("VOI") + VS1->VS1_TIPTEM ) )
		if VOI->VOI_CONVOV == "1"
			DbSelectArea("VS3")
			DbSetOrder(1)
			DbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
			While !Eof() .and. xFilial("VS3")==VS3->VS3_FILIAL .and. VS3->VS3_NUMORC==VS1->VS1_NUMORC
				DbSelectArea("VOV")
				DbSetOrder(1)
				If !DBSeek(xFilial("VOV")+VS3->VS3_GRUITE+VS1->VS1_TIPTEM)
					MsgInfo(STR0266+ " ("+Alltrim(VS3->VS3_GRUITE)+")",STR0025) //"Grupo de Peça não está associado ao tipo de tempo!","Atenção"
					lRet:=.F.
				EndIf
				DbSelectArea("VS3")
				DBSkip()
			enddo
		EndIf
	endif

	if !lRet
		return .f.
	endif

	DbSelectArea("VAI")
	Dbsetorder(4)
	MsSeek(xFilial("VAI")+__cUserID)
	VOI->(DbSetOrder(1))
	VOI->(MsSeek( xFilial("VOI") + VS1->VS1_TIPTSV ) )
	if VOI->VOI_CONVOW == "1"
		DbSelectArea("VOW")
		DbSetOrder(1)
		If !( MsSeek( xFilial("VOW") + VAI->VAI_CODTEC + VS1->VS1_TIPTSV ))
			Help(" ",1,"TPPRODUT")
			Return .f.
		EndIf
	EndIf

	// ##############################
	// #  VERIFICA  INCONVENIENTES  #
	// ##############################
	// PECAS //
	DbSelectArea("VS3")
	DbSetOrder(1)
	DbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
	While !Eof() .and. xFilial("VS3")==VS3->VS3_FILIAL .and. VS3->VS3_NUMORC==VS1->VS1_NUMORC
		// #  VERIFICA  INCONVENIENTES  #
		cMsgErroInc := ""
		If lInconveniente .and. !Empty(VS3->VS3_SEQINC) .and. !OM420VALINC("P",,,VS1->VS1_CHAINT,VS1->VS1_KILOME,VS1->VS1_TIPTEM,VS1->VS1_NUMORC,"1",VS3->VS3_SEQINC,@cMsgErroInc)
			aInconv := OM420CONSINC( "1" , VS1->VS1_NUMORC, VS3->VS3_SEQINC )
			if !lOX001Auto
				MsgStop(cMsgErroInc+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0070+aInconv[1]+"-"+aInconv[2]+CHR(13)+CHR(10)+STR0071+VS1->VS1_TIPTEM,STR0025)
				//
				//verificar se o usuario tem permissao para utilizar inconveniente
				If lPedApr//primeiro item a pedir aprovacao   .t.
					lPedApr := .f.
					If VAI->VAI_INCFPV<>"0" //usuario sem permissao para utilizar inconveniente fora da validade
						If VAI->VAI_INCFPV=="1"//solicitar aprovacao (usuario e senha do usuario autorizado)
							If !OFX001USR(aInconv[1],aInconv[2])
								RestArea(cAlias)
								return .f.
							EndIF
						else //nao autorizado
							RestArea(cAlias)
							return .f.
						Endif
					EndIf
				EndIF
				//
			endif
		EndIf
		If VS3->VS3_VALPEC <= 0
			if !lOX001Auto
				MsgStop(STR0072,STR0025)
			endif
			Return .f.
		EndIf
		DbSelectArea("VS3")
		DbSkip()
	EndDo
	// SERVICOS //
	DbSelectArea("VS4")
	DbSetOrder(1)
	DbSeek(xFilial("VS4")+VS1->VS1_NUMORC)
	While !Eof() .and. xFilial("VS4")==VS4->VS4_FILIAL .and. VS4->VS4_NUMORC==VS1->VS1_NUMORC
		// #  VERIFICA  INCONVENIENTES  #
		cMsgErroInc := ""
		If lInconveniente .and. !Empty(VS4->VS4_SEQINC) .and. !OM420VALINC("S",,,VS1->VS1_CHAINT,VS1->VS1_KILOME,VS1->VS1_TIPTEM,VS1->VS1_NUMORC,"1",VS4->VS4_SEQINC,@cMsgErroInc)
			aInconv := OM420CONSINC( "1" , VS1->VS1_NUMORC, VS4->VS4_SEQINC )
			if !lOX001Auto
				MsgStop(cMsgErroInc+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0074+aInconv[1]+"-"+aInconv[2]+CHR(13)+CHR(10)+STR0075+VS1->VS1_TIPTEM,STR0025)
				//verificar se o usuario tem permissao para utilizar inconveniente

				If lPedApr//primeiro item a pedir aprovacao   .t.
					lPedApr := .f.
					If VAI->VAI_INCFPV<>"0" //usuario sem permissao para utilizar inconveniente fora da validade
						If VAI->VAI_INCFPV=="1"//solicitar aprovacao (usuario e senha do usuario autorizado)
							If !OFX001USR(aInconv[1],aInconv[2])
								RestArea(cAlias)
								return .f.
							EndIF
						else //nao autorizado
							RestArea(cAlias)
							return .f.
						Endif
					EndIf
				EndIf

			endif
		EndIf
		// ############################################################
		// # Verifica valor do servico qdo nao for Mao Obra Gratuita  #
		// # ou servico de terceiros !( VOK_INCMOB $ '0/2')           #
		// ############################################################
		cIncMob := FM_SQL("SELECT VOK_INCMOB FROM " + RetSQLName("VOK") + " VOK WHERE VOK_FILIAL = '" + xFilial("VOK") + "' AND VOK_TIPSER = '" + VS4->VS4_TIPSER + "' AND D_E_L_E_T_=' '")
		If VS4->VS4_VALSER <= 0 .AND. !( cIncMob $ '0/2' ) // 0=Mao de Obra Gratuita / 2=Serv. Terceiros
			MsgStop(STR0053,STR0025)
			Return .f.
		EndIf
		DbSelectArea("VS4")
		DbSkip()
	EndDo

	if ExistBlock("OX001AEX") // Antes da Exportacao
		lRet := ExecBlock("OX001AEX",.f.,.f.)
		If !lRet
			Return (lRet)
		Endif
	Endif
	// ########################
	// # ORCAMENTO DE OFICINA #
	// ########################
	If !lOX001Auto

		cNroOS := ""

		// Se tiver garantia mutua, verifica se ja existe pedido de garantia criado...
		// se tiver, utiliza a OS do pedido de garantia
		cNroOS := OA550NUMOS(VS1->VS1_NUMORC,"P,L")
		If !Empty(cNroOS)
			DbSelectArea("VO1")
			cQuery := "SELECT R_E_C_N_O_"
			cQuery += "  FROM "+RetSqlName("VO1")
			cQuery += " WHERE VO1_FILIAL = '" + xFilial("VO1") + "'"
			cQuery += "   AND VO1_NUMOSV = '" + cNroOS + "'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			nRecVO1 := FM_SQL(cQuery)
			If nRecVO1 > 0
				VO1->(DbGoTo(nRecVO1))
			Else
				If !lOX001Auto
					MsgInfo(STR0089+" "+cNroOS) // "OS não encontrada"
					OX0010051_LogdaPilhadeChamada("STR0089")
				EndIf
				Return .f.
			endif
			If VO1->VO1_STATUS <> "A"
				Help("  ",1,"OSNABERTA")
				Return .f.
			EndIf
		EndIf
		//
		If Empty(cNroOS)
			cNroOS := OX001ABOS(VS1->VS1_CHAINT)
		EndIf
		if cNroOS == "ret" // Cancelado pelo Usuario
			Return(.f.)
		ElseIf Empty(cNroOS) // Nova OS
			lNovaOS := .t.
		Else // OS ja existente - Orcamento Complementear
			lNovaOS := .f.
			If GetNewPar("MV_MIL0093","0") == "1" // Utiliza Servicos Autmaticos
				//////////////////////////////////////////////////////////////////////
				// Verifica a qtde de Servicos se eh menor que a quantidade no VO6  //
				//////////////////////////////////////////////////////////////////////
				nQtdVO4 := FM_SQL("SELECT COUNT(*) FROM "+RetSQLName("VO4")+" WHERE VO4_FILIAL='"+xFilial("VO4")+"' AND VO4_NUMOSV='"+cNroOS         +"' AND VO4_GRUSER='"+cVO6GRUSER+"' AND D_E_L_E_T_=' '")
				nQtdVS4 := FM_SQL("SELECT COUNT(*) FROM "+RetSQLName("VS4")+" WHERE VS4_FILIAL='"+xFilial("VS4")+"' AND VS4_NUMORC='"+VS1->VS1_NUMORC+"' AND VS4_GRUSER='"+cVO6GRUSER+"' AND D_E_L_E_T_=' '")
				nQtdVO6 := FM_SQL("SELECT COUNT(*) FROM "+RetSQLName("VO6")+" WHERE VO6_FILIAL='"+xFilial("VO6")+"' AND VO6_CODMAR='"+cVO6CODMAR     +"' AND VO6_GRUSER='"+cVO6GRUSER+"' AND D_E_L_E_T_=' '")
				If (nQtdVO4+nQtdVS4) > nQtdVO6 // Qtde de servicos a serem utilizados eh maior que a qtde de servicos da tabela de servicos
					MsgStop(STR0317,STR0025) // Nao foi possivel obter um proximo codigo de servico da tabela de servicos. Por favor, cadastre mais servicos na tabela de servicos! / Atencao
					Return .f.
				EndIf
				//////////////////////////////////////////////////////////////////////
				// Levanta os Servicos ja utilizados no VO4                         //
				//////////////////////////////////////////////////////////////////////
				cQuery := "SELECT VO4_CODSER FROM "+RetSQLName("VO4")
				cQuery += " WHERE VO4_FILIAL='"+xFilial("VO4")+"'"
				cQuery += "   AND VO4_NUMOSV='"+cNroOS+"'"
				cQuery += "   AND VO4_GRUSER='"+cVO6GRUSER+"'"
				cQuery += "   AND D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
				Do While !( cQAlias )->( Eof() )
					aAdd(aVO4Uti,{( cQAlias )->( VO4_CODSER )})
					( cQAlias )->( DbSkip() )
				Enddo
				( cQAlias )->( DbCloseArea() )
				//////////////////////////////////////////////////////////////////////
				// Verifica se os Codigos dos Servicos do VS4 ja existem no VO4     //
				//////////////////////////////////////////////////////////////////////
				cQuery := "SELECT VS4_CODSER , R_E_C_N_O_ RECVS4 FROM "+RetSQLName("VS4")
				cQuery += " WHERE VS4_FILIAL='"+xFilial("VS4")+"'"
				cQuery += "   AND VS4_NUMORC='"+VS1->VS1_NUMORC+"'"
				cQuery += "   AND VS4_GRUSER='"+cVO6GRUSER+"'"
				cQuery += "   AND D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
				Do While !( cQAlias )->( Eof() )
					//////////////////////////////////////////////////////////////////////
					// Verifica se o Codigo do Servico do VS4 ja existe na OS           //
					//////////////////////////////////////////////////////////////////////
					If aScan(aVO4Uti, {|x| x[1] == ( cQAlias )->( VS4_CODSER ) }) > 0 // Caso ja exista o Servico do VS4 na OS, trocar para um NOVO Codigo de Servico
						DbSelectArea("VO6")
						DbSetOrder(3) // VO6_FILIAL + VO6_CODMAR + VO6_GRUSER + VO6_CODSER
						DbSeek( cVO6FILIAL + cVO6CODMAR + cVO6GRUSER )
						While !Eof() .and. VO6->VO6_FILIAL == cVO6FILIAL .and. VO6->VO6_CODMAR == cVO6CODMAR .and. VO6->VO6_GRUSER == cVO6GRUSER
							//////////////////////////////////////////////////////////////////////
							// Verifica se o Codigo do Servico do VO6 nao existe na OS          //
							//////////////////////////////////////////////////////////////////////
							If aScan(aVO4Uti, {|x| x[1] == VO6->VO6_CODSER }) <= 0 // Caso nao exista o NOVO Servico na OS, trocar o Codigo do Servico do VS4
								DbSelectArea("VS4")
								DbGoTo(( cQAlias )->( RECVS4 ))
								RecLock("VS4",.f.)
								VS4->VS4_CODSER := VO6->VO6_CODSER // Troca para o NOVO Codigo do Servico
								MsUnLock()
								aAdd(aVO4Uti,{VO6->VO6_CODSER}) // Adiciona o NOVO Codigo de Servico que nao estava na OS
								Exit
							EndIf
							DbSelectArea("VO6")
							DbSkip()
						EndDo
					Else
						aAdd(aVO4Uti,{( cQAlias )->( VS4_CODSER )}) // Adiciona Codigo de Servico que nao estava na OS
					EndIf
					( cQAlias )->( DbSkip() )
				Enddo
				( cQAlias )->( DbCloseArea() )
				DbSelectArea("VS4")
				//
			EndIf
			cNumOrd := cNroOS
			DbSelectArea("VS1")
			If !OX001VLABERT(cNumOrd,VS1->VS1_TIPTEM, VS1->VS1_CHAINT, VS1->VS1_CLIFAT, VS1->VS1_LOJA, cOrcAtu,VS1->VS1_TIPTSV,VS1->VS1_CODBCO,VS1->VS1_FORPAG,VS1->VS1_FRANQU,IIF(VS1->(ColumnPos("VS1_FRANQP")) <> 0, VS1->VS1_FRANQP , 0 ))
				return .f.
			EndIf
			// Verifica se é OS de Garantia Mutua
			DbSelectArea("VO1")
			cQuery := "SELECT R_E_C_N_O_"
			cQuery += "  FROM "+RetSqlName("VO1")
			cQuery += " WHERE VO1_FILIAL = '" + xFilial("VO1") + "'"
			cQuery += "   AND VO1_NUMOSV = '" + cNumOrd + "'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			nRecVO1 := FM_SQL(cQuery)
			If nRecVO1 > 0
				VO1->(DbGoTo(nRecVO1))
				If VO1->VO1_GARMUT == "1"
					If OA550INC(cNumOrd,VS1->VS1_NUMORC,,!lOX001Auto)
						If !lOX001Auto
							MsgInfo(STR0248) // "Gerado Pedido de Garantia Mutua, aguardando aprovação."
							oDlgXX001:End()
						EndIf
						Return .t.
					EndIf
				Elseif VO1->VO1_GARMUT == "2"
					if !MsgYesNo(STR0269,STR0025)
						Return(.f.)
					Endif
				EndIf
			EndIf
		EndIf
	Endif
	// ##############################
	// # VERIFICA LIMITE DE CREDITO #
	// ##############################
	if !(VS1->VS1_STATUS $ "F/G/2")
		DBSelectArea("VOI")
		DBSetOrder(1)
		DBSeek(xFilial("VOI") + VS1->VS1_TIPTEM)
		if VOI->VOI_SITTPO == "1"
			cTipPag := VS1->VS1_FORPAG
			if Empty(GetNewPar("MV_CPNCLC","")) .or. !alltrim(cTipPag) $ GetMv("MV_CPNCLC") .or. Empty(cTipPag)
				If "I" $ GetMv("MV_CHKCRE")
					SA1->(DBSetOrder(1))
					if GetMv("MV_CREDCLI") == "C"
						SA1->(DBSeek(xFilial("SA1")+VS1->VS1_CLIFAT))
						lAltPosSA1 := .t.
					else
						SA1->(MsSeek(xFilial("SA1")+VS1->VS1_CLIFAT + VS1->VS1_LOJA))
						lAltPosSA1 := .f.
					endif
					If !FGX_AVALCRED(SA1->A1_COD,SA1->A1_LOJA,IIf(VS1->VS1_STATUS=="0",VS1->VS1_VTOTNF,0),.t.)
						 // Reposiciona no SA1
					   If lAltPosSA1
							SA1->(MsSeek(xFilial("SA1")+VS1->VS1_CLIFAT + VS1->VS1_LOJA))
					   Endif
						if !lOX001Auto
							MsgInfo(STR0078,STR0025)
						endif
						OI001ATU(VS1->VS1_NUMORC,"3")
						return .f.
					Else
						 // Reposiciona no SA1
					   If lAltPosSA1
							MsSeek(xFilial("SA1")+VS1->VS1_CLIFAT + VS1->VS1_LOJA)
					   Endif
					EndIf
				EndIf
			Endif
		endif
		//
	endif

	if !(VS1->VS1_STATUS $ "F/G") .and. !(OX001LDOFI(VS1->VS1_NUMORC))
		return .f.
	endif
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve adicionar servicos para o inconveniente ( REVISAO ) ³
	//³ quando o orcamento nao foi gerado pelo agendamento                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lInconveniente
		if Empty(VS1->VS1_NUMAGE)
			aSrvcAdic := {}
			if !OX001SRVAD(@aSrvcAdic)
				Return .f.
			endif
		EndIf
	EndIf

// ------------------------------------------------------------------------------------------------------------
	BEGIN TRANSACTION // --------I-N-I-C-I-O---D-A---T-R-A-N-S-A-C-A-O---------------------------------------------
// ------------------------------------------------------------------------------------------------------------
// ##########################################################################
// # VERIFICA SE EH O CASO O CASO DE ABRIR UMA NOVA O.S. OU NAO             #
// ##########################################################################
	if lOX001Auto .or. Empty(cNroOS)
		If !OX001VERQMX(cNumOrd)
			DisarmTransaction()
			RollBackSX8()
			Return .f.
		EndIF
		cNumOrd := FM_ABREOSV( @aCodErro ,,M->VS1_CHAINT , M->VS1_KILOME , M->VS1_CLIFAT, M->VS1_LOJA , M->VS1_OBSMEM, IIf(Type("M->VS1_DATENT")<>"U",M->VS1_DATENT,Ctod("")),M->VS1_HORTRI, .F. )
		if Empty(cNumOrd)
			if !lOX001Auto
				MsgInfo(aCodErro[2],STR0025 +" - "+aCodErro[1])
			endif
			DisarmTransaction()
			RollBackSX8()
			return .f.
		else
			DbSelectArea("VO1")
			cQuery := "SELECT R_E_C_N_O_"
			cQuery += "  FROM "+RetSqlName("VO1")
			cQuery += " WHERE VO1_FILIAL = '" + xFilial("VO1") + "'"
			cQuery += "   AND VO1_NUMOSV = '" + cNumOrd + "'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			nRecVO1 := FM_SQL(cQuery)
			If nRecVO1 > 0
				VO1->(DbGoTo(nRecVO1))
			Else
				if !lOX001Auto
					MsgStop(STR0089+" "+cNumOrd)
					OX0010051_LogdaPilhadeChamada("STR0089")
				endif
				DisarmTransaction()
				RollBackSX8()
				Return(.f.)
			endif
			reclock("VO1",.f.)
			VO1->VO1_NATURE := VS1->VS1_NATURE
			msunlock()
			If ExistBlock("OFX01OSV")
				cCpoAlt := ExecBlock("OFX01OSV",.f.,.f.)
			EndIf
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek("VO1")
			While !Eof().and.(SX3->X3_ARQUIVO=="VO1")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adiciona na Matriz para Montar TScroll com os GET's ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If AllTrim(SX3->X3_CAMPO) $ cCpoAlt
					AADD(aCpoAlt, { SX3->X3_CAMPO , ;
									SX3->X3_TIPO , ;
									SX3->X3_TAMANHO , ;
									SX3->X3_DECIMAL , ;
									SX3->X3_PICTURE , ;
									SX3->X3_TITULO , ;
									IIf(!Empty(SX3->X3_VALID),AllTrim(SX3->X3_VALID),".T.")+".and."+IIf(!Empty(SX3->X3_VLDUSER),AllTrim(SX3->X3_VLDUSER),".T."),;
									SX3->X3_WHEN ,;
									SX3->X3_CONTEXT ,;
									SX3->X3_F3 } )
				EndIf
				If SX3->X3_CONTEXT == "V"
					&("M->"+SX3->X3_CAMPO):= &(SX3->X3_RELACAO)
				Else
					&("M->"+SX3->X3_CAMPO):= &("VO1->"+SX3->X3_CAMPO)
				EndIf
				dbSelectArea("SX3")
				DbSkip()
			EndDo
			If !Empty(cCpoAlt)
				oDlgOSv := MSDIALOG() :New(0,0,15,45,cCadastro,,,,128,,,,oMainWnd,.f.) // Dados da Ordem de Servico
			else
				oDlgOSv := MSDIALOG() :New(0,0,05,45,cCadastro,,,,128,,,,oMainWnd,.f.) // Dados da Ordem de Servico
			endif
			oDlgOSv:lEscClose := .F.
			@ 002,004 TO 33,174 LABEL STR0091 OF oDlgOSv PIXEL // Nro. da Ordem de Servico:
			@ 008,020 Say cNumOrd OF oDlgOSv PIXEL Font TFont():New( "System", 015, 048 ) SIZE 105,20
			If !Empty(cCpoAlt)
				@ 014,100 BUTTON oSalvar PROMPT STR0164 OF oDlgOSv SIZE 33,11 PIXEL ACTION ( lOkOSV := .t. , oDlgOSv:End() ) // Atualizar
			EndIf
			@ 014,136 BUTTON oSair PROMPT STR0165 OF oDlgOSv SIZE 33,11 PIXEL ACTION ( oDlgOSv:End() ) // Sair
			If !Empty(cCpoAlt)
				oOFX01OSV := TScrollBox():New( oDlgOSv, 034 , 004 , 075 , 170 , .t. , , .t. )
				For nPos := 1 to Len(aCpoAlt)
					If nPos <> 1
						nLin += nDisLin
					EndIf
					bWhen := NIL
					If aCpoAlt[nPos, 9] == "V"
						bWhen := { || .f. }
					ElseIf !Empty(aCpoAlt[nPos,8])
						bWhen := &("{ || " + AllTrim(aCpoAlt[nPos,8]) + " }")
					EndIf
					bBloco := "{|| '" + AllTrim(RetTitle(aCpoAlt[nPos,1])) +"' }"
					TSay():New ( nLin+1 , nCol-38 , MontaBlock(bBloco), oOFX01OSV , /*cPicture */, oOFX01OSV:oFont /*oFont*/ , .f. , .f. , .f. , .t. /*lPixels*/, /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/ ,.F.,.F.,.F.,.F.,.F. )
					nTamGet := CalcFieldSize( aCpoAlt[nPos,2] , aCpoAlt[nPos,3] , 0 , aCpoAlt[nPos,5] , " ")
					cObjGName := "oGet" + AllTrim(aCpoAlt[nPos,1])
					&(cObjGName) := TGet():New( nLin /*<nRow>*/, nCol /*<nCol>*/, ;
					&('{ | U | IF( PCOUNT() == 0,M->'+aCpoAlt[nPos,1]+',M->'+aCpoAlt[nPos,1]+' := U ) }') /*bSETGET(<uVar>)*/,;
					oOFX01OSV /*[<oWnd>]*/, nTamGet+10 /*<nWidth>*/, 1 /*<nHeight>*/, aCpoAlt[nPos,5]/*<cPict>*/, &('{|| ' +aCpoAlt[nPos,7]+' }') /*<{ValidFunc}>*/,;
					/*<nClrFore>*/, /*<nClrBack>*/, /*<oFont>*/, /*<.design.>*/,;
					/*<oCursor>*/, .t. /*<.pixel.>*/, /*<cMsg>*/, /*<.update.>*/, bWhen /*<{uWhen}>*/,;
					/*<.lCenter.>*/, /*<.lRight.>*/,;
					/*[\{|nKey, nFlags, Self| <uChange>\}]*/, /*<.readonly.>*/,;
					/*<.pass.>*/ , iif( !Empty(aCpoAlt[nPos,10]) , aCpoAlt[nPos,10] , NIL ) /*<cAlias>*/,/*<(uVar)>*/,,/*[<.lNoBorder.>]*/, /*[<nHelpId>]*/, .t. /*[<.lHasButton.>] */ )
				Next nPos
			EndIf
			ACTIVATE MSDIALOG oDlgOSv CENTER
			If lOkOSV .and. !Empty(cCpoAlt)
				DbSelectArea("VO1")
				cQuery := "SELECT R_E_C_N_O_"
				cQuery += "  FROM "+RetSqlName("VO1")
				cQuery += " WHERE VO1_FILIAL = '" + xFilial("VO1") + "'"
				cQuery += "   AND VO1_NUMOSV = '" + cNumOrd + "'"
				cQuery += "   AND D_E_L_E_T_ = ' '"
				nRecVO1 := FM_SQL(cQuery)
				If nRecVO1 > 0
					VO1->(DbGoTo(nRecVO1))
					RecLock("VO1",.f.)
					For nPos := 1 to Len(aCpoAlt)
						&("VO1->"+aCpoAlt[nPos,1]) := &("M->"+aCpoAlt[nPos,1])
					Next
					MsUnLock()
				EndIf
			EndIf
		EndIf
	Else

		If !OX001VERQMX(cNumOrd)
			DisarmTransaction()
			RollBackSX8()
			Return .f.
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava Valor de Franquia ... ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if VS1->VS1_FRANQU > 0 .or. (VS1->(ColumnPos("VS1_FRANQP")) <> 0 .and. VO1->(ColumnPos("VO1_FRANQP")) <> 0 .and. VS1->VS1_FRANQP > 0)
			VS1->(dbSetOrder(1))
			VS1->(DBSeek(xFilial("VS1")+cOrcAtu))
			DbSelectArea("VO1")
			cQuery := "SELECT R_E_C_N_O_"
			cQuery += "  FROM "+RetSqlName("VO1")
			cQuery += " WHERE VO1_FILIAL = '" + xFilial("VO1") + "'"
			cQuery += "   AND VO1_NUMOSV = '" + cNumOrd + "'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			nRecVO1 := FM_SQL(cQuery)
			If nRecVO1 > 0
				VO1->(DbGoTo(nRecVO1))
			EndIf
			if reclock("VO1",.f.)
				if VS1->VS1_FRANQU > 0
					VO1->VO1_FRANQU := VS1->VS1_FRANQU
				endif
				IF VS1->(ColumnPos("VS1_FRANQP")) <> 0 .and. VO1->(ColumnPos("VO1_FRANQP")) <> 0 .and. VS1->VS1_FRANQP > 0
					VO1->VO1_FRANQP := VS1->VS1_FRANQP
				endif
				msunlock()
			else
				DisarmTransaction()
				RollBackSX8()
				return .f.
			endif

		endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Manoel - 21/06/2010                                   ³
		//³FNC      - Gravar VO1_OBSERV acumulando OBS's de varios Orcs³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if !Empty(VS1->VS1_OBSMEM)
			DbSelectArea("VO1")
			cQuery := "SELECT R_E_C_N_O_"
			cQuery += "  FROM "+RetSqlName("VO1")
			cQuery += " WHERE VO1_FILIAL = '" + xFilial("VO1") + "'"
			cQuery += "   AND VO1_NUMOSV = '" + cNumOrd + "'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			nRecVO1 := FM_SQL(cQuery)
			If nRecVO1 > 0
				VO1->(DbGoTo(nRecVO1))
				cOBSVO1 := MSMM(VS1->VS1_OBSMEM,TamSx3("VS1_OBSERV")[1])
				M->VO1_OBSERV := MSMM(VO1->VO1_OBSMEM,TamSx3("VO1_OBSERV")[1])
				DbSelectArea("VO1")
				M->VO1_OBSERV := Alltrim(M->VO1_OBSERV)+Chr(13)+Chr(10)+cOBSVO1
				MSMM(VO1->VO1_OBSMEM,TamSx3("VO1_OBSERV")[1],,M->VO1_OBSERV,1,,,"VO1","VO1_OBSMEM")
				RollBackSX8()
			EndIf
		endif
	EndIf

  // ##########################################################################
  // # IMPORTA SERVICOS PARA A OS                                             #
  // ##########################################################################

	cStOrcRes := OA4820105_StatusReservaOrcamento(VS1->VS1_NUMORC)

	if cStOrcRes == "1" .or. cStOrcRes == "2" //Orçamento Parcialmente ou Totalmente Reservado através da reserva Manual

		If !( lNewRes )
			DBSelectArea("VS1")
			reclock("VS1",.f.)
			VS1->VS1_RESERV := "1"
			msunlock()
			cRetRes := OX001RESITE(VS1->VS1_NUMORC,.f., {"9999"})

			if Empty(cRetRes)
				DisarmTransaction()
				Return .f.
			EndIf
		EndIf

	endif
//
	DbSelectArea("VO1")
	cQuery := "SELECT R_E_C_N_O_"
	cQuery += "  FROM "+RetSqlName("VO1")
	cQuery += " WHERE VO1_FILIAL = '" + xFilial("VO1") + "'"
	cQuery += "   AND VO1_NUMOSV = '" + cNumOrd + "'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	nRecVO1 := FM_SQL(cQuery)
	If nRecVO1 > 0
		VO1->(DbGoTo(nRecVO1))
	EndIf
//
	aCodErro := {"",""}
	DBSelectArea("VS1")
	DBSetOrder(1)
	DBSeek(xFilial("VS1")+cOrcAtu)
	// ##########################
	// # Atualiza o Agendamento #
	// ##########################
	OM350STATUS(VS1->VS1_NUMAGE,"1","2")

	// ####################################
	// # Exporta Inconvenientes para a OS #
	// ####################################
	IF lInconveniente
		FM_IMPVST(@aCodErro, VS1->VS1_NUMORC , VO1->VO1_NUMOSV)
	Endif
	// #######################################################
	// # Rubens - 03/11/2009                                 #
	// # Nao gerar VO2 quando nao tiver servico no Orcamento #
	// #######################################################
	VS4->(dbSetOrder(1))
	if VS4->(dbSeek(xFilial("VS4")+VS1->VS1_NUMORC)) .or. Len(aSrvcAdic) > 0
		cNosNum := FM_IMPVO4( @aCodErro, VS1->VS1_NUMORC , VO1->VO1_NUMOSV , aSrvcAdic,,, .F.)
		if Empty(cNosNum)
			if !lOX001Auto
			MsgStop(aCodErro[2],STR0025+" - "+aCodErro[1])
			endif
			DisarmTransaction()
			RollBackSX8()
			return .f.
		endif
	endif
	// Grava numero da O.S. no orcamento
	DBSelectArea("VS1")
	DBSetOrder(1)
	DBSeek(xFilial("VS1")+cOrcAtu)
	reclock("VS1",.f.)
	VS1->VS1_NUMOSV := VO1->VO1_NUMOSV
	msunlock()
	//
	lMSErroAuto := .f.
	//
	If GetNewPar("MV_MIL0098","0") == "1" .AND. !(VS1->VS1_STATUS $ 'F/G') // Trabalha com Conferência/Separação na Exportação do Orçamento para a OS

		DBSelectArea("VS1")
		DBSetOrder(1)
		DBSeek(xFilial("VS1")+cOrcAtu)
		reclock("VS1",.f.)
		VS1->VS1_STATUS := cFaseConfer
		msunlock()
		If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
			OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , IIF(VS1->VS1_TIPORC=="P",STR0374,STR0001) ) // Grava Data/Hora na Mudança de Status do Orçamento / Pedidos de Venda / Orçamento por Fases
		EndIf
		If ExistFunc("OA3610011_Tempo_Total_Conferencia_Saida_Orcamento")
			OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( 1 , cOrcAtu ) // 1=Iniciar o Tempo Total da Conferencia de Saida caso não exista o registro
		EndIf
		ShowHelpDlg ( "OX001CONSEP", { STR0334 }) // Será necessário aguardar a Conferência e a Separação para Importar as Peças na OS.

	  Else

		If !OX001EXPVSJ(.f.,cOrcAtu) // função que exporta peças para o VSJ
			DisarmTransaction()
			RollBackSX8()
			return .f.
		endif

	Endif
	ConfirmSX8()
	// ------------------------------------------------------------------------------------------------------------
	END TRANSACTION // --------F-I-N-A-L---D-A---T-R-A-N-S-A-C-A-O-------------------------------------------------
	// ------------------------------------------------------------------------------------------------------------

	If GetNewPar("MV_MIL0098","0") == "0" // NAO Trabalha com Conferência/Separação na Exportação do Orçamento para a OS

		MsgInfo(STR0093 ,STR0025)
		FG_PEDORD(VO1->VO1_NUMOSV,"N","S")

		if ExistBlock("OX001DEX") // Depois da Exportacao
			ExecBlock("OX001DEX",.f.,.f.)
		Endif

	EndIf

	if ExistBlock("IMPSUBORD") // Impressao da subordem de servico
		ExecBlock("IMPSUBORD",.f.,.f.)
	Endif
	if GetNewPar("MV_EEMAILO","")  == "S"
		if ExistBlock("OXIEMAIL")
			ExecBlock("OXIEMAIL",.f.,.f.,)
		Endif
	Endif

	oDlgXX001:End()
elseif !lPediVenda

	If lNewRes
		If GetNewPar("MV_MIL0037","S") == "S" // Movimenta para armazém de divergência?
			lChkFase := cVS1Status <> "5" // Se for a fase 5 não deve executar as validações da fase de divergencia na conferencia
		EndIf
	Endif

	cMsgFase := ""
	// ########################
	// # ORCAMENTO DE BALCAO  #
	// ########################
	// ########################################################################
	// # Armazena a fase atual e passa para a funcao de fases do orcamento    #
	// ########################################################################
	// ------------------------------------------------------------------------------------------------------------
	BEGIN TRANSACTION // --------I-N-I-C-I-O---D-A---T-R-A-N-S-A-C-A-O---------------------------------------------
	// ------------------------------------------------------------------------------------------------------------
	cFaseIni := VS1->VS1_STATUS
	aRet012 := OFIXI001(VS1->VS1_NUMORC,,lChkFase)
	cMsgFase := aRet012[1]
	lRollback := aRet012[2]
	lRollObrig := aRet012[3]
	lAbortProc := aRet012[4]

	if lAbortProc
		DisarmTransaction()
		return .f.
	endif
	// ------------------------------------------------------------------------------------------------------------
	END TRANSACTION // --------F-I-N-A-L---D-A---T-R-A-N-S-A-C-A-O-------------------------------------------------
	// ------------------------------------------------------------------------------------------------------------
	// Verifica se o orcamento esta barrado em alguma fase observando a variavel de retorno
	if cMsgFase != ""
		if !lOX001Auto
			MsgInfo(cMsgFase,STR0025)
		endif
		// Se a fase inicial do orcamento for a digitacao e eh possivel voltar a fase, questiona o usuario
		if (lRollback .and. cFaseIni == "0") .or. lRollObrig
			if lOX001Auto .or. lRollObrig .or. MsgYesNo(STR0094,STR0025)
				//----------------------------
				BEGIN TRANSACTION
				//----------------------------
				// verifica se precisa desreservar os itens
				nPosI := At(cFaseIni,cFaseOrc)
				nPosR := At("R",cFaseOrc)
				nPosA := At(VS1->VS1_STATUS,cFaseOrc)
				cDocto := "X"
				if nPosI < nPosR .and. nPosR <= nPosA

					If ( lNewRes ) // Chama desreserva de todos os itens que foram reservados
						cDocto := OA4820015_ProcessaReservaItem(cOrigem,VS1->(RecNo()),"M","D",,cTipo)
					Else
						cDocto := OX001RESITE(VS1->VS1_NUMORC,.f.)
					EndIf

				endif
				// verifica se precisa cancelar pedido de liberacao
				if !Empty(VS1->VS1_NUMLIB)
					If TCCanOpen(RetSqlName("VS7"))
						cString := "DELETE FROM "+RetSqlName("VS7")+ " WHERE VS7_FILIAL = '"+ xFilial("VS7")+"' AND VS7_NUMIDE= '"+VS1->VS1_NUMLIB+"'"
						TCSqlExec(cString)
					else
						DisarmTransaction()
						return .f.
					endif
					If TCCanOpen(RetSqlName("VS6"))
						cString := "DELETE FROM "+RetSqlName("VS6")+ " WHERE VS6_FILIAL = '"+ xFilial("VS6")+"' AND VS6_NUMIDE= '"+VS1->VS1_NUMLIB+"'"
						TCSqlExec(cString)
					else
						DisarmTransaction()
						return .f.
					endif
				endif
				if !Empty(VS1->VS1_NUMLIS)
					If TCCanOpen(RetSqlName("VS7"))
						cString := "DELETE FROM "+RetSqlName("VS7")+ " WHERE VS7_FILIAL = '"+ xFilial("VS7")+"' AND VS7_NUMIDE= '"+VS1->VS1_NUMLIS+"'"
						TCSqlExec(cString)
					else
						DisarmTransaction()
						return .f.
					endif
					If TCCanOpen(RetSqlName("VS6"))
						cString := "DELETE FROM "+RetSqlName("VS6")+ " WHERE VS6_FILIAL = '"+ xFilial("VS6")+"' AND VS6_NUMIDE= '"+VS1->VS1_NUMLIS+"'"
						TCSqlExec(cString)
					else
						DisarmTransaction()
						return .f.
					endif
				endif
				DBSelectArea("VS1")
				reclock("VS1",.f.)
				VS1->VS1_NUMLIB := ""
				VS1->VS1_NUMLIS := ""
				cVS1StAnt := VS1->VS1_STATUS
				VS1->VS1_STATUS := "0"
				cVS1Status := "0"
				msunlock()
				If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
					OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , IIF(VS1->VS1_TIPORC=="P",STR0374,STR0001) ) // Grava Data/Hora na Mudança de Status do Orçamento / Pedidos de Venda / Orçamento por Fases
				EndIf
				//
				If FindFunction("FM_GerLog")
					//grava log das alteracoes das fases do orcamento
					FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,cVS1StAnt)
				EndIF

				//----------------------------
				END TRANSACTION
				//----------------------------
				if cDocto == ""
					if !lOX001Auto
						MsgInfo(STR0095,STR0025)
					endif
				endif
				return .f.
			endif
			if !lOX001Auto
				oDlgXX001:End()
			endif
		endif
	endif
	// Se no final das contas o orcamento esta pronto para faturar mostra a tela com essa opcao
	if !lOX001Auto
		DBSelectArea("VAI")
		DBSetOrder(4)
		DBSeek(xFilial("VAI")+__cUserId)
		if VS1->VS1_STATUS $ "F/G"
			if VAI->VAI_FATBAL == "1"
				OFIXX004("VS1",3)
				If VS1->VS1_STATUS == "X" // Orcamento Faturado
					OX001CEV("F",VS1->VS1_NUMORC,VS1->VS1_TIPORC) // Gerar CEV na Finalizacao do Orcamento ( Pos-Venda )

					If nImprRoman == 2 .and. ExistBlock("ROMBALCAO")
						ExecBlock("ROMBALCAO",.f.,.f.,{VS1->VS1_SERNFI,VS1->VS1_NUMNFI})
					EndIf

				EndIf
			else
				MsgInfo(STR0096,STR0025)
			endif
		endif
		oDlgXX001:End()
	endif
else // Quando for Pedido de Venda
	lOX001Auto := .f.
	oDlgXX001:End()
endif
//
if ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" // VMI somente para VALTRA / MASSEY / FENDT
	If FindFunction('OFAGVmi')
		oVmi := OFAGVmi():New()
		oVmi:Trigger({;
			{'EVENTO'          , oVmi:oVmiMovimentos:Orcamento},;
			{'ORIGEM'          , "OFIXX001_DMS4"  },;
			{'NUMERO_ORCAMENTO', M->VS1_NUMORC    } ;
		})
	endif
endif
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OX001DELP  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001DELP()
//
Local cMotCan := ""
Local nCntFor := 1

Local lVerInconv
Local lStatAnt
Local nLinDup
Local nAuxPos   := 0
Local nPosSlv := 0
Local cTipoKit := ""

Local aMotCan := {}

Private cMotivo := "000004"
Private lVldDPec := .t.

If lAltPedVda .and. (oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_QTDPED","aHeaderP")]+oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_QTDINI","aHeaderP")] != 0)
	// return .f.
Endif

if !Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3MOTPED])
	MsgStop(STR0292,STR0025) // Linha do orçamento cancelada. Impossível alterar
	return .f.
endif
//
IF (ALTERA .or. INCLUI) .AND. (M->VS1_TIPORC == 'P' .or. lPediVenda) .and. !lCancelPVP .and. oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])-1] <> 0
	MsgStop(STR0293,STR0025) // "Não é possível deletar linhas do pedido. Utilize o Cancelamento Parcial."
	return .f.
endif
// Não permite deletar peca no momento do faturamento OU quando orcamento é originado de um PEDIDO e não está no Status 5 (Divergência)
If M->VS1_TIPORC == "1" .and. ( M->VS1_STATUS $ "F/G" .or. (!Empty(M->VS1_PEDREF).and.VS1->VS1_STATUS<>'5') )
	Return .f.
EndIf
//
If VS1->VS1_STARES $ "12" .or. oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_QTDRES","aHeaderP")] > 0 // Tem Qtde da PECA reservada?
	// Campo de Permissao do Usuario para Cancelar/Deletar Pecas ja Reservadas?
	//Verificar se o usuario pode cancelar/deletar uma Peca ja Reservada
	VAI->(DbSetOrder(4))
	VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
	If VAI->VAI_CANCPR == '0' // Sem permissão para Cancelar
		MsgStop(STR0368,STR0025) // Usuário sem permissão para deletar Peça já Reservada. Impossivel continuar. / Atencao
		return .f.
	EndIf
EndIf
//
If GetNewPar("MV_MIL0093","0") == "1" // Quando trabalhar com servicos automaticos
	nAuxPos := FG_POSVAR("VS3_INSTAL","aHeaderP")
	If nAuxPos > 0
		If !oGetPecas:aCols[oGetPecas:nAt,len(oGetPecas:aCols[oGetPecas:nAt])] // Excluir PECA -> Excluir Servico
			If oGetPecas:aCols[oGetPecas:nAt,nAuxPos] == "1" // Sim
				If !Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC]) .and. Alltrim(oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC]) <> cIncDefault
					If MsgYesNo(STR0318,STR0025) // Deseja excluir o Servico relacionado a instalacao da Peca? / Atencao
						// Peca Instalar? 0=Nao
						oGetPecas:aCols[oGetPecas:nAt,nAuxPos] := "0" // Nao
						// Salva posição na getdados
						nPosSlv := oGetServ:nAt
						// ascan na acols de servico com o inconveniente da peca
						nPos := aScan(oGetServ:aCols, {|x| x[FG_POSVAR("VS4_SEQINC","aHeaderS")] == oGetPecas:aCols[oGetPecas:nAt,nVS3SEQINC] })
						//
						If nPos > 0
							oGetServ:aCols[nPos,len(oGetServ:aCols[nPos])] := .t. // apagar servico
							oGetServ:aCols[nPos,FG_POSVAR("VS4_SEQINC","aHeaderS")] := ""
							oGetServ:aCols[nPos,FG_POSVAR("VS4_DESINC","aHeaderS")] := ""
							oGetServ:oBrowse:Refresh()
						EndIf
						n := oGetServ:nAt := nPos
						OX001SrvFis()
						MaFisDel(n,oGetServ:aCols[oGetServ:nAt,Len(oGetServ:aCols[oGetServ:nAt])])
						OX001FisSrv()
						n := oGetServ:nAt := nPosSlv
						//
						// ascan na acols de inconveniente com o inconveniente da peca
						nPos := aScan(oGetInconv:aCols, {|x| x[FG_POSVAR("VST_SEQINC","aHeaderI")] == oGetPecas:aCols[oGetPecas:nAt,nVS3SEQINC] })
						If nPos > 0
							oGetInconv:aCols[nPos,len(oGetInconv:aCols[nPos])] := .t. // apagar inconveniente
							oGetInconv:oBrowse:Refresh()
						EndIf
						// trocar inconveniente da peca para o inconveniente default (sem instalacao)
						nPos := aScan(oGetInconv:aCols, {|x| Alltrim(x[FG_POSVAR("VST_DESINC","aHeaderI")]) == cIncDefault })
						If nPos > 0
							oGetPecas:aCols[oGetPecas:nAt,nVS3SEQINC] := M->VS3_SEQINC := oGetInconv:aCols[nPos,FG_POSVAR("VST_SEQINC","aHeaderI")]
							oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC] := M->VS3_DESINC := oGetInconv:aCols[nPos,FG_POSVAR("VST_DESINC","aHeaderI")]
							oGetPecas:oBrowse:Refresh()
						EndIf
					Else
						Return .f.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
//
If oPedido:isBO({; // é back order? se for pode cancelar dependendo do VAI
		{ 'VS3_NUMORC', M->VS1_NUMORC },;
		{ 'VS3_CODITE', oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] },;
		{ 'VS3_GRUITE', oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] },;
		{ 'VS3_SEQUEN', oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_SEQUEN","aHeaderP")] } ;
	})
	oLogger := DMS_Logger():New()
	// dar mensagem falando que vai perder a sugestao/backorder
	// se confirmar apagar VE6 e SDF
	if MsgYesNo( STR0308 /* "Tem certeza que deseja cancelar um item com pedido pendente? O pedido será perdido, essa ação não poderá ser desfeita." */ , STR0025 /* "Atenção" */)
		DbSelectArea("VAI")
		DbSetOrder(4)
		DbSeek( xFilial("VAI") + __CUSERID )
		If VAI->VAI_CANCBO != '1' // Sem permissão
			MsgAlert(STR0311 /*"Seu usuário não possui permissão para cancelar um pedido com sugestão."*/, STR0025 /*"Atenção"*/)
			Return .F.
		Endif

		BEGIN TRANSACTION // ação e log devem ser feitos
			SB1->(dbSelectarea('SB1'))
			SB1->(dbSetOrder(7))
			SB1->(dbSeek( xFilial('SB1') + oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] + oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] ))
			//
			if Empty(cMotCan)
				aMotCan := OFA210MOT('000015',,,,.F.,) // 15 => MOTIVO DO CANCELAMENTO DE BACKORDER
				If Len(aMotCan) == 0
					DisarmTransaction()
					Return .F.
				EndIf
				cMotCan := aMotCan[1]
			EndIf
			//
			oPedido:DelBoItem({; // é back order? se for pode cancelar dependendo do VAI
				{ 'cNUMORC', M->VS1_NUMORC },;
				{ 'cCODITE', oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_CODITE","aHeaderP")] },;
				{ 'cGRUITE', oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_GRUITE","aHeaderP")] },;
				{ 'cSEQUEN', oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_SEQUEN","aHeaderP")] },;
				{ 'MOTIVO'    , cMotCan                                                           } ;
			})
			//
		END TRANSACTION
	Else
		MsgStop( STR0309 /* "Operação abortada" */, STR0025 /* "Atenção" */)
		Return .F.
	EndIf
Else
	//
	if oGetPecas:aCols[oGetPecas:nAt,nVS3QTDAGU] > 0
		MsgStop(STR0224,STR0025) // Não é possível excluir um item com pedido de peças pendente.
		return .f.
	endif
	//
EndIf
//
if oGetPecas:aCols[oGetPecas:nAt,nVS3QTDTRA] > 0
	MsgStop(STR0224,STR0025) // Não é possível excluir um item com pedido de peças pendente.
	return .f.
endif

// Grava status atual, para voltar se nao executar o PE com sucesso
lStatAnt := oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])]

//P.E. para tratamento de delecao de linha do acols de pecas
If ExistBlock("OXA001VDEL") // <<<--- O B S O L E T O
	If !(ExecBlock("OXA001VDEL",.F.,.F.))
		Return .f.
	Endif
EndIf
If ExistBlock("OX001ADP")
	If !(ExecBlock("OX001ADP",.F.,.F.))
		Return .f.
	Endif
EndIf

If oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])] // peca deletada - tenta restaurar linha 
	oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])] := .f.
	// Verifica se o produto ja foi lancado no orcamento
	if lInconveniente
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica duplicidade com grupo / codigo do item e INCONVENIENTE ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if lVldDPec .and. OX001PDUPL(oGetPecas:nAt,oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] ,;
									oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] ,;
									oGetPecas:aCols[oGetPecas:nAt,nVS3GRUINC] ,;
									oGetPecas:aCols[oGetPecas:nAt,nVS3CODINC] ,;
									oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC] ,;
									oGetPecas:aCols[oGetPecas:nAt,nVS3SEQINC] ,;
									oGetPecas:aCols[oGetPecas:nAt,nVS3NUMLOT] ,;
									oGetPecas:aCols[oGetPecas:nAt,nVS3LOTECT] ,;
									@nLinDup)

			oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])] := .t.
			MsgInfo(STR0097 + chr(13) + chr(13) + STR0146 + AllTrim(Str(nLinDup)) ,STR0025)
			return .f.
		endif
	else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica duplicidade somente com grupo / codigo do item³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if lVldDPec .and. OX001PDUPL(oGetPecas:nAt,oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] ,;
									oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] ,,,,,;
									oGetPecas:aCols[oGetPecas:nAt,nVS3NUMLOT] ,;
									oGetPecas:aCols[oGetPecas:nAt,nVS3LOTECT] , @nLinDup )

			oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])] := .t.
			MsgInfo(STR0097 + chr(13) + chr(13) + STR0146 + AllTrim(Str(nLinDup)) ,STR0025) // Produto ja lancado no orcamento.
			return .f.

		endif
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Inconveniente não foi excluido...³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lInconveniente
		lVerInconv := .f. // Indica se o item pode voltar para o orcamento
		for nCntFor := 1 to Len(oGetInconv:aCols)
			if Alltrim(oGetInconv:aCols[nCntFor,FG_POSVAR("VST_SEQINC","aHeaderI")]) == Alltrim(oGetPecas:aCols[oGetPecas:nAt,nVS3SEQINC]) .and. ;
				Alltrim(oGetInconv:aCols[nCntFor,FG_POSVAR("VST_GRUINC","aHeaderI")]) == Alltrim(oGetPecas:aCols[oGetPecas:nAt,nVS3GRUINC]) .and. ;
				Alltrim(oGetInconv:aCols[nCntFor,FG_POSVAR("VST_CODINC","aHeaderI")]) == Alltrim(oGetPecas:aCols[oGetPecas:nAt,nVS3CODINC]) .and. ;
				Alltrim(oGetInconv:aCols[nCntFor,FG_POSVAR("VST_DESINC","aHeaderI")]) == Alltrim(oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC]) .and. ;
				!oGetInconv:aCols[nCntFor,Len(oGetInconv:aCols[nCntFor])]

				lVerInconv := .t.
				exit

			endif
		next
		if !lVerInconv

			oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])] := .t.
			MsgInfo(STR0132) // Nao existe inconveniente para esta peça

			return .f.
		endif
	endif
Else
	cTipoKit := oGetPecas:aCols[oGetPecas:nAt,nVS3PECKIT]
	If !Empty(cTipoKit) .And. cTipoKit <> "0"
		If cTipoKit == "1"
			MsgInfo(STR0263) // Este item é mandatório para o kit. Não é possivel removê-lo do orçamento.
			Return(.f.)
		ElseIf GetNewPar("MV_MIL0002","0") == "0"
			MsgInfo(STR0359) // Não é permitido remover este item do orçamento. Vefificar parâmetro MV_MIL0002.
			Return(.f.)
		EndIf
	EndIf
	oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])] := .t.
	if lPediVenda
		if FECHA
			oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])] := .f.
		endif
	Endif
EndIf
//
if ExistBlock("OXA001DELP") // <<<--- O B S O L E T O
	If !(ExecBlock("OXA001DELP",.f.,.f.))
		oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])] := lStatAnt
		Return .f.
	EndIf
Endif
if ExistBlock("OX001DDP")
	If !(ExecBlock("OX001DDP",.f.,.f.))
		oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])] := lStatAnt
		Return .f.
	EndIf
Endif
//


if M->VS1_TIPORC == "2"	.and. !Empty(M->VS1_NUMORC)
	cACodGrp := oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]
	cACodIte := oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE]
	if oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])]
		if !Empty(cACodGrp+cACodIte)
			if GetNewPar("MV_MIL0011", "0") == "0" // nao registra Nivel de atendimento
				if MsgYesNo(STR0098,STR0025) // Essa peca foi cortada pelo cliente?
					OX001GCORT("P")
				endif
			endif
		Endif
	else
		DBSelectArea("VPJ")
		DBSetOrder(1)
		if DBSeek(xFilial("VPJ") + M->VS1_NUMORC + cACodGrp + cACodIte)
			reclock("VPJ",.f.,.t.)
			dbdelete()
			msunlock()
		endif
		dbSelectArea("VPJ")
		dbSetOrder(1)
		if dbSeek(xFilial("VPJ")+M->VS1_NUMORC)
			cCont := 0
			While !Eof() .and. xFilial("VPJ") == VPJ->VPJ_FILIAL .and. M->VS1_NUMORC == VPJ->VPJ_NUMORC
				cCont += 1
				RecLock("VPJ",.F.)
				VPJ->VPJ_ORDEM := STRZERO(cCont,3)
				dbSelectArea("VPJ")
				dbSkip()
			Enddo
		Endif
	endif
endif

if (lPediVenda.OR.(M->VS1_TIPORC=="2" .AND. GetNewPar("MV_MIL0011", "0") == "1" )) .and. !lCancelPVP
	if !Empty(M->VS1_NUMORC) .and. !Empty(M->VS3_GRUITE) .and. !Empty(M->VS3_CODITE)
		DBSelectArea("VS3")
		DBSetOrder(2)
		if DBSeek(xFilial("VS3") + M->VS1_NUMORC + M->VS3_GRUITE + M->VS3_CODITE)
			if !Empty(VS3->VS3_MOTPED)
				MsgStop(STR0283)
				return .f.
			endif
			cMotPed01 := OA012TMOT()
			if cMotPed01 == ""
				oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])] := .f.
				return .f.
			endif
			reclock("VS3",.f.)
			VS3->VS3_QTDELI := VS3->VS3_QTDITE
			if FG_POSVAR("VS3_QTDELI","aHeaderP") > 0
				oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_QTDELI","aHeaderP")] := VS3->VS3_QTDELI
			endIf
			VS3->VS3_MOTPED := cMotPed01
			oGetPecas:aCols[oGetPecas:nAt,nVS3MOTPED] := cMotPed01
			if ! ( VS1->VS1_TIPORC=="2" .AND. GetNewPar("MV_MIL0011", "0") == "1" )
				VS3->VS3_QTDITE := 0
				oGetPecas:aCols[oGetPecas:nAt,nVS3QTDITE] := 0
			EndIf
			If VS1->VS1_TIPORC <>"2"
				VS3->VS3_QTDPED := 0
				oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_QTDPED","aHeaderP")] := 0
			Endif
			msunlock()
			lCancParc := .t.
		endif
	endif
endif

if OX001ExistPecFis(oGetPecas:nAt)
	MaFisDel(n,oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])])
	OX001FisPec()
endif

// Linha restaurada
If ! oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])]
	if OX001ExistPecFis(oGetPecas:nAt)
		// Vai atualizar os valores da get com os valores do fiscal 
		OX001RecFis("IT_TES",oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES]) // nova atualização do Fiscal - Junho 2016
		OX001FisPec()
	EndIf
Else
	OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
Endif
//
oGetPecas:obrowse:Refresh()
//
OX0010271_PercentualRemuneracao( .t. ) // Retorna o % de Remuneração
//
//OX001ITEREL() // Atualiza informacoes de Itens Relacionados
//
If !oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])]
	If !Empty(oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODITE","aHeaderP")]) .and. oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_QTDITE","aHeaderP")] > 0
		OX0010261_Verifica_Saldo_Promocao()
	EndIf
EndIf
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001DLINS  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001DELS()
//
Local nCntFor
Local lVerInconv

If oGetServ:aCols[oGetServ:nAt,Len(oGetServ:aCols[oGetServ:nAt])]
	oGetServ:aCols[oGetServ:nAt,Len(oGetServ:aCols[oGetServ:nAt])] := .f.
	// Verifica se o produto ja foi lancado no orcamento
	for nCntFor := 1 to Len(oGetServ:aCols)
		if nCntFor != oGetServ:nAt .and. !(oGetServ:aCols[nCntFor,len(oGetServ:aCols[nCntFor])])
			if  oGetServ:aCols[nCntFor,fg_posvar("VS4_CODSER","aHeaderS")] == oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_CODSER","aHeaderS")]  .and. ;
				oGetServ:aCols[nCntFor,fg_posvar("VS4_GRUSER","aHeaderS")] == oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_GRUSER","aHeaderS")]
				oGetServ:aCols[oGetServ:nAt,Len(oGetServ:aCols[oGetServ:nAt])] := .t.
				MsgInfo(STR0099,STR0025)
				return .f.
			endif
		endif
	next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Inconveniente não foi excluido...³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lInconveniente
		lVerInconv := .f. // Indica se o item pode voltar para o orcamento
		for nCntFor := 1 to Len(oGetInconv:aCols)
			if oGetInconv:aCols[nCntFor,FG_POSVAR("VST_SEQINC","aHeaderI")] == oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_SEQINC","aHeaderS")] .and. ;
				oGetInconv:aCols[nCntFor,FG_POSVAR("VST_GRUINC","aHeaderI")] == oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_GRUINC","aHeaderS")] .and. ;
				oGetInconv:aCols[nCntFor,FG_POSVAR("VST_CODINC","aHeaderI")] == oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_CODINC","aHeaderS")] .and. ;
				oGetInconv:aCols[nCntFor,FG_POSVAR("VST_DESINC","aHeaderI")] == oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_DESINC","aHeaderS")] .and. ;
				!oGetInconv:aCols[nCntFor,Len(oGetInconv:aCols[nCntFor])]

				lVerInconv := .t.
				exit

			endif
		next

		if !lVerInconv
			oGetServ:aCols[oGetServ:nAt,Len(oGetServ:aCols[oGetServ:nAt])] := .t.
			MsgInfo(STR0133)
			return .f.
		endif

	endif

Else
	oGetServ:aCols[oGetServ:nAt,Len(oGetServ:aCols[oGetServ:nAt])] := .t.
EndIf
if Len(aNumS) >= oGetServ:nAt
	OX001SrvFis()
	MaFisDel(n,oGetServ:aCols[oGetServ:nAt,Len(oGetServ:aCols[oGetServ:nAt])])
	OX001FisSrv()
endif
//
DBSelectArea("SX2")
if DBSeek("VPM")
	if M->VS1_TIPORC == "2"	.and. !Empty(M->VS1_NUMORC)
		cAGrpSer := oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_GRUSER","aHeaderS")]
		cACodSer := oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_CODSER","aHeaderS")]
		if oGetServ:aCols[oGetServ:nAt,Len(oGetServ:aCols[oGetServ:nAt])]
			if !Empty(cAGrpSer+cACodSer)
				if MsgYesNo(STR0159,STR0025)
					OX001GCORT("S")
				endif
			Endif
		else
			DBSelectArea("VPM")
			DBSetOrder(1)
			if DBSeek(xFilial("VPM") + M->VS1_NUMORC + cAGrpSer + cACodSer)
				reclock("VPM",.f.,.t.)
				dbdelete()
				msunlock()
			endif
			dbSelectArea("VPM")
			dbSetOrder(1)
			if dbSeek(xFilial("VPM")+M->VS1_NUMORC)
				cCont := 0
				While !Eof() .and. xFilial("VPM") == VPM->VPM_FILIAL .and. M->VS1_NUMORC == VPM->VPM_NUMORC
					cCont += 1
					RecLock("VPM",.F.)
					VPM->VPM_ORDEM := STRZERO(cCont,3)
					dbSelectArea("VPM")
					dbSkip()
				Enddo
			Endif
		endif
	endif
endif

OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
//
oGetServ:obrowse:Refresh()
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001DLINS  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001DPOK()
Local nCntFor
// Verifica se o produto ja foi lancado no orcamento

for nCntFor := 1 to Len(oGetPecas:aCols)
	if nCntFor != oGetPecas:nAt .and. !(oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])])
		if oGetPecas:aCols[nCntFor,nVS3CODITE] == oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] .and. ;
			oGetPecas:aCols[nCntFor,nVS3GRUITE] == oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]

			OX001DELP()
			MsgInfo(STR0100,STR0025)
			return .f.

		endif
	endif
next
if FECHA
	OX001DELP()
	return .f.
endif
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001DLINS  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001DSOK()
Local nCntFor
// Verifica se o produto ja foi lancado no orcamento
for nCntFor := 1 to Len(oGetServ:aCols)
	if nCntFor != oGetServ:nAt .and. !(oGetServ:aCols[nCntFor,len(oGetServ:aCols[nCntFor])])
		if  oGetServ:aCols[nCntFor,fg_posvar("VS4_CODSER","aHeaderS")] == oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_CODSER","aHeaderS")]  .and. ;
			oGetServ:aCols[nCntFor,fg_posvar("VS4_GRUSER","aHeaderS")] == oGetServ:aCols[oGetServ:nAt,fg_posvar("VS4_GRUSER","aHeaderS")]
			OX001DELS()
			MsgInfo(STR0099,STR0025)
			return .f.
		endif
	endif
next
//
if FECHA
	OX001DELS()
	return .f.
endif
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001KEYF4  | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Chamada da tecla de atalho <F4>. Executa comandos dependen-  |##
##|          | do do campo selecionado ( ReadVar() ).                       |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001KEYF4()
Local lRetorno := .f.
Local cTmpGrupo, cTmpCodite
//
if readvar() $ "M->VS3_GRUITE,M->VS3_CODITE"
	cTmpGrupo := oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]
	cTmpCodite := M->VS3_CODITE
	DBSelectArea("SB1")
	DBSetOrder(7)
	if DBSeek(xFilial("SB1")+cTmpGrupo+cTmpCodite)
		If ExistBlock("OX001CPC")
			lRetorno := ExecBlock("OX001CPC",.f.,.f.,{SB1->B1_COD})
		else
			lRetorno := OFIXC001(SB1->B1_COD)
		endif
	else
		If ExistBlock("OX001CPC")
			lRetorno := ExecBlock("OX001CPC",.f.,.f.,{cTmpCodite})
		else
			lRetorno := OFIXC001(cTmpCodite)
		endif
	endif
	SETKEY(VK_F4,{|| OX001KEYF4() })
	SETKEY(VK_F5,{|| OX001REQCPR() })
	SETKEY(VK_F6,{|| OX001KEYF6() })
	SETKEY(VK_F7,{|| OFIXC001() })

	If ExistBlock("OX001F8")
		SETKEY(VK_F8,{|| ExecBlock("OX001F8",.f.,.f.,{ M->VS1_NUMORC , M->VS3_GRUITE , M->VS3_CODITE }) })
	EndIf
	If ExistBlock("OX001F9")
		SETKEY(VK_F9,{|| ExecBlock("OX001F9",.f.,.f.,{ M->VS1_NUMORC , M->VS3_GRUITE , M->VS3_CODITE }) })
	EndIf
	If GetNewPar("MV_MIL0075","0") $ "1/S" // Mostrar Tela ( 1=Sim / 0=Nao )
		SETKEY(VK_F10,{|| OX0010145_TelaTipoPagamento() } )
	EndIf
	
	if lRetorno
		M->VS3_GRUITE := SB1->B1_GRUPO
		M->VS3_CODITE := SB1->B1_CODITE
		OX001PREPEC("", .f.)
	else
		M->VS3_GRUITE := cTmpGrupo
		M->VS3_CODITE := cTmpCodite
	endif
	oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] := M->VS3_GRUITE
	oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] := M->VS3_CODITE
endif

If readvar() == "M->VS4_CODSER" .and. ExistFunc("OM030CSRV")
	OM030CSRV("OX001DBSEL")
endif
//
SETKEY(VK_F6,{|| OX001KEYF6(.f.) } )
//
if readvar() $ "M->VS3_LOTECT,M->VS3_NUMLOT"
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFiliaL("SB1")+ oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]+;
	oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE])
	F4LOTE(,,,"OX001",SB1->B1_COD,Iif(!Empty(oGetPecas:aCols[oGetPecas:nAt, nVS3LOCAL ]),oGetPecas:aCols[oGetPecas:nAt, nVS3LOCAL ],OX0010105_ArmazemOrigem()))
	M->VS3_NUMLOT := oGetPecas:aCols[oGetPecas:nAt,nVS3NUMLOT]
	M->VS3_LOTECT := oGetPecas:aCols[oGetPecas:nAt,nVS3LOTECT]
	M->VS3_DTVALI := oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_DTVALI","aHeaderP")]
endif

if readvar() $ "M->VS3_LOCALI"
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFiliaL("SB1")+ oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]+;
	oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE])
	SB1->(DBSetOrder(1))
	F4LOCALIZ( ,,, "A260",SB1->B1_COD,Iif(!Empty(oGetPecas:aCols[oGetPecas:nAt, nVS3LOCAL ]),oGetPecas:aCols[oGetPecas:nAt, nVS3LOCAL ],OX0010105_ArmazemOrigem()),,"M->VS3_LOCALI" )
	oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_LOCALI","aHeaderP")] := M->VS3_LOCALI
endif

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001KEYF6  | Autor | Andre Luis Almeida    | Data | 26/07/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Chamada da tecla de atalho <F6> Foto do Produtos             |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001KEYF6(lB1Pos)
Default lB1Pos := .f.
//
SET KEY VK_F6 TO
//
If !lB1Pos
	SB1->(DBSetOrder(7))
	SB1->(DBSeek( xFiliaL("SB1") + oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] + oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE]) )
EndIf
//
If ExistFunc("OFIXC003")
	OFIXC003( SB1->B1_COD )
EndIf
//
SETKEY(VK_F6,{|| OX001KEYF6(lB1Pos) } )
//
Return()

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001ABORT  | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Janela de aborto. Podera ser chamada apenas dentro de tran-  |##
##|          | sacoes. Exibe uma mensagem e seta o lMsErroAuto para .t.     |##
##|          | caso o usuario tenha optado por abortar a operacao           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001ABORT()
//
If lAbortPrint
	//"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
	If MsgYesNo(STR0101,STR0025)
		Help("  ",1,"M160PROABO")
		DisarmTransaction()
		Return .t.
	Else
		lAbortPrint := .F.
	EndIf
EndIf
//
Return .f.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001SLDPC  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Calcula o saldo da peca                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001SLDPC(cChave, lUtilCache)
	Local nSaldo := 0
	Local nPos_SB2Cache

	Default lUtilCache := .f. // Utiliza Cache

	nIni_SLDPC := timefull()

	If lUtilCache .and. (nPos_SB2Cache := aScan(SB2Cache, { |x| x[1] == cChave })) <> 0
		// Verifica se o saldo ainda é "válido"
		If Seconds() - SB2Cache[nPos_SB2Cache,2] < SB2CacheTimer .and. Seconds() > SB2Cache[nPos_SB2Cache,2]
			nSaldo := SB2Cache[nPos_SB2Cache,3]
			Return nSaldo
		EndIf
	EndIf

	do case
		case lESTOF110
			nSaldo := ExecBlock("ESTOF110",.f.,.f.)

		case lOX001SPC
			nSaldo := ExecBlock("OX001SPC",.f.,.f.)

		OtherWise
			aAlias := GetArea()
			If ( SB2->(dbSeek(cChave)) )
				nSaldo := SaldoSb2()
			EndIf
			RestArea(aAlias)
	endcase

	AADD( SB2Cache, { cChave , Seconds() , nSaldo })

Return(nSaldo)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001PREPEC | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Preenche demais informacoes da peca e calcula o fiscal.      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001PREPEC(cChamadoPor, lForcaAtuPrc, aParFiscal, lAtuIteRel)

Local lAltValorPeca := FWIsInCallStack("OX001RECALC")
Local cAuxReadVar := ReadVar()

Default cChamadoPor := ""
Default lForcaAtuPrc := .f.
Default lAtuIteRel := .t.

// para ser alterado o valor da peça é necessário que seja selecionada a opção Recalculo ou quando 
// não existir no cliente o parâmetro MV_MIL0117 ou quando este parâmetro estiver com conteúdo "S"
// MV_MIL0117 - Altera Valor de Venda da Peca no Orcamento? S(sim) - N(nao)
if !lPPrepec
	return
endif

lPPrepec := .f. // Controla se sera executada a funcao OX001PREPEC
nIni_PrePec := timefull()

//
// Posiciona no cadastro de pecas (seguranca apenas)
//
if SB1->B1_CODITE <> oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] .or. SB1->B1_GRUPO <> oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]
	DBSelectArea("SB1")
	DBSetOrder(7)
	if ! MsSeek(xFilial("SB1")+oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]+oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE])
		return .f.
	endif

endif

If OX0010016_MostraQuantidadeEmEstoque(oGetPecas:nAt, M->VS1_TIPORC)

	nSdoPecas := OX001SLDPC(xFilial("SB2") + SB1->B1_COD + oGetPecas:aCols[oGetPecas:nAt, nVS3LOCAL] , .t. )
	
	/*If nVS3QTDEST == 0
		// dependendo do TES, questiona-se o saldo da peca
		SF4->(MsSeek(xFilial("SF4") + oGetPecas:aCols[oGetPecas:nAt, nVS3CODTES]))
		if nSdoPecas <= 0 .and. SF4->F4_ESTOQUE == "S"
			MsgInfo(STR0102 + Alltrim(SB1->B1_GRUPO) + " " + Alltrim(SB1->B1_CODITE) + " - " + Alltrim(SB1->B1_DESC) + STR0103, STR0025)
		Endif
	EndIf*/

	M->VS3_QTDEST := nSdoPecas
	oGetPecas:aCols[oGetPecas:nAt, nVS3QTDEST] := nSdoPecas
EndIf

nTpProc := 0

if cAuxReadVar=="M->VS3_FORMUL"
	oGetPecas:aCols[oGetPecas:nAt,nVS3FORMUL] := M->VS3_FORMUL
elseif cAuxReadVar=="M->VS3_CODTES"
	oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES] := M->VS3_CODTES
elseif cAuxReadVar=="M->VS3_OPER" .or. cAuxReadVar=="M->VS3_CODITE" .or. cAuxReadVar=="M->VS1_CLIFAT" .or. cAuxReadVar=="M->VS1_LOJA" .or. cAuxReadVar=="M->VS1_TIPCLI"

	oGetPecas:aCols[oGetPecas:nAt,nVS3OPER] := M->VS3_OPER
	If !Empty(M->VS3_OPER)
		oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES] := M->VS3_CODTES := OX001TESINT(M->VS3_OPER)
	EndIf

	OX0010153_PreencheSITTRI(.f.)

endif
//
// A partir da segunda linha, inicializa a Operação com a operação da linha anterior se nao tiver operação ja informada 
if oGetPecas:nAt > 1
	if ! oGetPecas:aCols[oGetPecas:nAt - 1,Len(oGetPecas:aCols[oGetPecas:nAt - 1])]
		if Empty(M->VS3_OPER) .and. !Empty(oGetPecas:aCols[oGetPecas:nAt - 1,nVS3OPER])

			M->VS3_OPER :=  oGetPecas:aCols[oGetPecas:nAt - 1,nVS3OPER]
			oGetPecas:aCols[oGetPecas:nAt,nVS3OPER] := M->VS3_OPER

			M->VS3_CODTES := OX001TESINT(M->VS3_OPER)
			oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES] := M->VS3_CODTES

			OX0010153_PreencheSITTRI(.f.)
		endif
	endif
endif

// Para orcamento de oficina, se não tiver operação informada, inicializa com a operação do tipo de tempo de peca 
if M->VS1_TIPORC == "2"
	if Empty(M->VS3_OPER)
		DBSelectArea("VOI")
		DBSetOrder(1)
		MsSeek(xFilial("VOI")+M->VS1_TIPTEM)
		If !Empty(VOI->VOI_CODOPE)
			M->VS3_OPER := VOI->VOI_CODOPE
			oGetPecas:aCols[oGetPecas:nAt,nVS3OPER] := M->VS3_OPER
			M->VS3_CODTES := OX001TESINT(M->VS3_OPER)
			oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES] := M->VS3_CODTES
		EndIf
	endif
endif

//###################################################################
//# Se nao foi digitado o TES, preenche com o valor do cadastro     #
//###################################################################
if Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3OPER]) .and. Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES])
	if cAuxReadVar $ "M->VS3_GRUITE,M->VS3_CODITE"
		M->VS3_CODTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")//SB1->B1_TS
		oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES] := M->VS3_CODTES //SB1->B1_TS
		OX0010153_PreencheSITTRI(.f.)
	endif
endif
//


if Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3FORMUL])
	ogetPecas:aCols[oGetPecas:nAt,nVS3FORMUL] := FS_FORMULA(M->VS3_GRUITE)
	M->VS3_FORMUL := oGetPecas:aCols[oGetPecas:nAt,nVS3FORMUL]
Endif

if ( oGetPecas:aCols[oGetPecas:nAt,nVS3VALPEC] == 0 ) ;
	.or. lForcaAtuPrc ;
	.or. lAltValorPeca

	OX0010235_Atualiza_Preco_Peca(.f.)

endif

If lOX001FIS // Ponto de entrada para calculo da exceção fiscal
	ExecBlock("OX001FIS",.f.,.f.)
EndIf

// Criado alguns criterios para controlar o momento em que a peca será adicionada no fiscal 
if 	oGetPecas:aCols[oGetPecas:nAt,nVS3QTDITE] > 0 .and. ;
	! empty(oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE]) .and. ;
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALPEC] > 0 .and. ;
	! empty(oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES] )

	//DBSelectArea("VAI")
	//DBSetOrder(6)
	//if MsSeek(xFilial("VAI")+M->VS1_CODVEN)
	//	M->VS1_CENCUS := VAI->VAI_CC
	//endif
	//

	if OX001PecFis() // item novo 

		MaFisIniLoad(n,;
			{ SB1->B1_COD,;                              // [01] 	Caracter	Código do produto
			oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES],;  // [02]  	Caracter	Código da TES
			" "  ,;                                      // [03]  	Numérico	Valor do ISS do item
			oGetPecas:aCols[oGetPecas:nAt,nVS3QTDITE],;  // [04]  	Numérico	Quantidade do Item
			"",;                                         // [05]  	Caracter	Numero da NF Original
			"",;                                         // [06]  	Caracter	Serie da NF Original
			SB1->(RecNo()),;                             // [07] 	Numérico	RecNo do SB1
			SF4->(RecNo()),;                             // [08]  	Numérico	RecNo do SF4
			0 })                                         // [09] 	Numérico	RecNo da NF Original (SD1/SD2)

		MaFisLoad("IT_CLASFIS",M->VS3_SITTRI, n)
		MaFisLoad("IT_PRCUNI",M->VS3_VALPEC, n)
		MaFisLoad("IT_VALMERC",Round(M->VS3_VALPEC*M->VS3_QTDITE,2), n)
		MaFisLoad("IT_DESCONTO",M->VS3_VALDES, n)

		MaFisRecal("",n) // Dispara o calculo do item
		MaFisEndLoad(n,1) // Fecha o calculo do item e atualiza os totalizadores do cabeçalho

	else

		if MaFisRet(n,"IT_PRODUTO") <> SB1->B1_COD
			MaFisRef("IT_PRODUTO","VS300",SB1->B1_COD)
		endif
		if MaFisRet(n,"IT_TES") <> M->VS3_CODTES
			MaFisRef("IT_TES","VS300",M->VS3_CODTES)
		endif
		if MaFisRet(n,"IT_CLASFIS") <> M->VS3_SITTRI
			MaFisRef("IT_CLASFIS","VS300",M->VS3_SITTRI)
		endif
		if MaFisRet(n,"IT_PRCUNI") <> M->VS3_VALPEC
			MaFisRef("IT_PRCUNI","VS300",M->VS3_VALPEC)
		endif
		if MaFisRet(n,"IT_DESCONTO") <> M->VS3_VALDES
			MaFisRef("IT_DESCONTO","VS300",M->VS3_VALDES)
		endif
		if MaFisRet(n,"IT_VALMERC") <> Round(M->VS3_VALPEC*M->VS3_QTDITE,2)
			MaFisRef("IT_VALMERC","VS300",Round(M->VS3_VALPEC*M->VS3_QTDITE,2))
		endif

	endif

	//MaFisRef("IT_TES","VS300",M->VS3_CODTES)
	//MaFisRef("IT_PRCUNI","VS300",M->VS3_VALPEC)
	//MaFisRef("IT_VALMERC","VS300",Round(M->VS3_VALPEC*M->VS3_QTDITE,2))
	//MaFisRef("IT_TES","VS300",M->VS3_CODTES)

	M->VS3_VALPIS := MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
	M->VS3_VALCOF := MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
	M->VS3_ICMCAL := MaFisRet(n,"IT_VALICM")
	M->VS3_VALCMP := MaFisRet(n,"IT_VALCMP")
	M->VS3_DIFAL := MaFisRet(n,"IT_DIFAL")
	M->VS3_PICMSB := MaFisRet(n,"IT_ALIQSOL")
	M->VS3_BICMSB := MaFisRet(n,"IT_BASESOL")
	M->VS3_VICMSB := MaFisRet(n,"IT_VALSOL")
	M->VS3_PIPIFB := MaFisRet(n,"IT_ALIQIPI")
	M->VS3_VIPIFB := MaFisRet(n,"IT_VALIPI")

	OX001FisPec()
	//  O calculo da Margem foi chamado de novo, pois as variáveis de memório só estão carregadas corretamente agora
	SB1->( dbSetOrder(7) )
	SB1->( dbSeek( xFilial("SB1") + M->VS3_GRUITE + M->VS3_CODITE ) )
	SB1->( dbSetOrder(1) )

	SB2->( dbSetOrder(1) )
	SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + M->VS3_LOCAL ) )

	aTempPro := OX005PERDES(;
		SBM->BM_CODMAR,;                              // cMarca
		M->VS1_CENCUS,;                               // cCenRes
		M->VS3_GRUITE,;                               // cGrupo
		M->VS3_CODITE,;                               // cCodite
		M->VS3_QTDITE,;                               // nQtd
		M->VS3_PERDES,;                               // nPercent
		.f.,;                                         // lHlp
		M->VS1_CLIFAT,;                               // cCliente
		M->VS1_LOJA,;                                 // cLoja
		IIF(M->VS1_TIPORC == "2","3",M->VS1_TIPVEN),; // cTipVen
		M->VS3_VALTOT/M->VS3_QTDITE,;                 // nValUni
		2,;                                           // nTipoRet
		M->VS1_FORPAG,;                               // cForPag
		cMVFORMALO,;                                  // cFormAlu
		,;                                            // lFechOfi
		,;                                            // lConMrgLuc
		,;                                            // cConPromoc
		,;                                            // dDatRefPD
		)                                             // nPERREM
	nMarLuc := aTempPro[2]
	//
	oGetPecas:aCols[oGetPecas:nAt,nVS3PERDES] := M->VS3_PERDES
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALPEC] := M->VS3_VALPEC
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALDES] := M->VS3_VALDES
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALTOT] := M->VS3_VALTOT
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALPIS] := M->VS3_VALPIS
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALCOF] := M->VS3_VALCOF
	oGetPecas:aCols[oGetPecas:nAt,nVS3ICMCAL] := M->VS3_ICMCAL
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALCMP] := M->VS3_VALCMP
	oGetPecas:aCols[oGetPecas:nAt,nVS3DIFAL]  := M->VS3_DIFAL

	//
	M->VS3_MARLUC := Round(nMarLuc,2)
	if M->VS3_MARLUC > Val(repl("9",TamSx3('VS3_MARLUC')[1]-TamSx3('VS3_MARLUC')[2]-1))
		M->VS3_MARLUC := Val(repl("9",TamSx3('VS3_MARLUC')[1]-TamSx3('VS3_MARLUC')[2]-1))
	endif
	oGetPecas:aCols[oGetPecas:nAt,nVS3MARLUC] := M->VS3_MARLUC
Endif
//
//###################################################################
//# Monta os itens Relacionados                                     #
//###################################################################
If !FWIsInCallStack("OX001RECALC") .AND. cChamadoPor <> "OX001LVS34" .and. cAuxReadVar == "M->VS3_CODITE" .and. lAtuIteRel
	if !lOX001Auto
		OX001ITEREL()
	endif
endif
//

return


/*/{Protheus.doc} OX0010273_InicializaPerDesPeca
	Inicializa Desconto da Peca

	@type function
	@author Rubens Takahashi
	@since 14/08/2023
/*/
Static Function OX0010273_InicializaPerDesPeca()
	M->VS3_PERDES := oGetPecas:aCols[oGetPecas:nAt, nVS3PERDES] := M->VS1_PERPEC
	M->VS3_VALDES := oGetPecas:aCols[oGetPecas:nAt, nVS3VALDES] := 0
Return

/*/{Protheus.doc} OX0010235_Atualiza_Preco_Peca
	Atualiza Preco da Peca

	@type function

	@param lInitialLoad, bool, Indica se a chamada da funcao foi no momento do carregamento inicial do orcamento

	@author Rubens Takahashi
	@since 14/08/2023
/*/
Static Function OX0010235_Atualiza_Preco_Peca(lInitialLoad, _cAuxReadVar, cPromocao)

	local aPromocao := {}
	local lTESVenda := .f.
	Local nValPec := 0
	Local lJaAtuPreco := .f. // Controla se carregou o preco da peca
	Local cSequenVEN := ""
	Local nValDesconto := 0
	local nPrecoLista := 0

	default _cAuxReadVar := ""
	default cPromocao := ""

	if ! empty(M->VS3_CODTES)
		if SF4->F4_CODIGO <> M->VS3_CODTES
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+M->VS3_CODTES))
		endif
		lTESVenda := (SF4->F4_OPEMOV == "05")
	endif

	If lTESVenda

		SBM->(dbSetOrder(1))
		SBM->(MsSeek(xFilial("SBM")+M->VS3_GRUITE))

		oGetPecas:aCols[oGetPecas:nAt,nVS3VALPEC] := M->VS3_VALPEC

		aPromocao := OX0010283_Criterio_Promocao_Peca()
		nValPec := aPromocao[1]
		nDescPromocaoPerc := aPromocao[3]
		cPermDescPromocao := aPromocao[4]
		If len(aPromocao) > 4
			cSequenVEN := aPromocao[5]
		EndIf

		// 0 = NAO PODE DAR DESCONTO EM PROMOCAO
		If cPermDescPromocao == "0" 
			If M->VS3_VALDES > 0 .or. M->VS3_PERDES > 0
				M->VS3_VALDES := 0
				M->VS3_PERDES := 0
			EndIf
		EndIf

		// Possui um percentual de desconto de Promocao, mas nao tem preco fixo
		// Nesse caso, vamos calcular o valor atual da peca e depois aplicar o desconto de promocao
		If nValPec == 0 .and. nDescPromocaoPerc > 0

			nPrecoLista := FG_VALPEC(;
				M->VS1_TIPTEM,;   // cTipTem
				"M->VS3_FORMUL",; // cVarFormula
				M->VS3_GRUITE,;   // cGruIte
				M->VS3_CODITE,;   // cCodIte
				,;                // cVarValor
				.f.,;             // lWhen
				.t.)              // lValor

			nValDesconto := 0
			nValPec := FtDescItem( ;
				@nPrecoLista,;             // ExpN1: Preco de lista aplicado o desconto de cabecalho
				@nPrecoLista,;             // ExpN2: Preco de Venda
				M->VS3_QTDITE,;	       // ExpN3: Quantidade vendida
				@M->VS3_VALTOT,;       // ExpN4: Valor Total (do item)
				nDescPromocaoPerc,;    // ExpN5: Percentual de desconto
				@nValDesconto,;       // ExpN6: Valor do desconto
				@nValDesconto,;       // ExpN7: Valor do desconto original
				1)                     // ExpN8: Tipo de Desconto (1 % OU 2 R$)
			
			lJaAtuPreco := .t.

		Endif
		//
		
		// se a variavel nValPec chegar neste ponto com valor zerado, podemos 
		// considerar que a peca NAO TEM promocao válida (percentual ou valor fixo)
		If nValPec == 0

			// Peca estava sinalizada com Promocao
			//      Atualiza o preco da peca de acordo com a formula mantendo o MAIOR valor entre o preco da formula e o preco da GRID 
			If M->VS3_PROMOC == "1"

				nValPec := FG_VALPEC(;
					M->VS1_TIPTEM,;   // cTipTem
					"M->VS3_FORMUL",; // cVarFormula
					M->VS3_GRUITE,;   // cGruIte
					M->VS3_CODITE,;   // cCodIte
					,;                // cVarValor
					.f.,;             // lWhen
					.t.)              // lValor

				// Mantem o MAIOR preco da peca
				If M->VS3_VALPEC > nValPec
					nValPec := M->VS3_VALPEC
				Endif

				M->VS3_PERDES := 0
				M->VS3_VALDES := 0

				// retira sinalizacao de promocao
				M->VS3_PROMOC := oGetPecas:aCols[oGetPecas:nAt,nVS3PROMOC] := "0"

				lJaAtuPreco := .t.
			
			// Peca sem promocao e sem criterio de promocao valida,
			// so devemos atualizar o preco da peca na digitação do codigo do item ou da formula
			else
				if ! _cAuxReadVar $ "M->VS3_FORMUL/M->VS3_CODITE" .and. ! Empty(_cAuxReadVar)
					lJaAtuPreco := .t.
				endif
			Endif
			//

		Else

			// sinaliza promocao da peca
			M->VS3_PROMOC := oGetPecas:aCols[oGetPecas:nAt,nVS3PROMOC] := "1"
			lJaAtuPreco := .t.

		Endif
	else
		// se NAO for TES de Venda e a peca NAO for promocao, so deve atualizar o preço se o usuario estiver digitando alterando codigo da peca ou formula
		if M->VS3_PROMOC == "0"
			if ! _cAuxReadVar $ "M->VS3_FORMUL/M->VS3_CODITE" .and. ! Empty(_cAuxReadVar)
				lJaAtuPreco := .t.
			endif
		endif
	endif

	if ! lJaAtuPreco

		M->VS3_PROMOC := oGetPecas:aCols[oGetPecas:nAt,nVS3PROMOC] := "0"

		nValPec := FG_VALPEC(;
			M->VS1_TIPTEM,;   // cTipTem
			"M->VS3_FORMUL",; // cVarFormula
			M->VS3_GRUITE,;   // cGruIte
			M->VS3_CODITE,;   // cCodIte
			,;                // cVarValor
			.f.,;             // lWhen
			.t.)              // lValor

	endif

	M->VS3_VALPEC := IIF( nValPec == 0 , M->VS3_VALPEC , nValPec )
	M->VS3_VALLIQ := oGetPecas:aCols[oGetPecas:nAt, nVS3VALLIQ ] := M->VS3_VALPEC

	// Se possuir percentual de desconto sem valor do desconto, provavelmente
	// o percentual de desconto veio do campo VS1_PERPEC, nesse caso vamos 
	// calcular o valor do desconto 
	if M->VS3_PERDES <> 0 .and. (M->VS3_VALDES == 0 .or. lInitialLoad)
		if lInitialLoad
			nBkpPerDes := M->VS3_PERDES
			nBkpValDes := M->VS3_VALDES
		endif
		OX0010263_CalculaDesconto("M->VS3_PERDES")
		if lInitialLoad
			M->VS3_PERDES := nBkpPerDes
			M->VS3_VALDES := nBkpValDes
			oGetPecas:aCols[oGetPecas:nAt, nVS3VALLIQ ] := M->VS3_VALLIQ
		endif
	endif

	if (M->VS3_VALPEC * M->VS3_QTDITE) > 0
		M->VS3_VALTOT := Round( (M->VS3_VALPEC * M->VS3_QTDITE) - M->VS3_VALDES , 2 ) 
	else
		M->VS3_VALTOT := 0
	endif

	oGetPecas:aCols[oGetPecas:nAt,nVS3PERDES] := M->VS3_PERDES
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALPEC] := M->VS3_VALPEC
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALDES] := M->VS3_VALDES
	oGetPecas:aCols[oGetPecas:nAt,nVS3VALTOT] := M->VS3_VALTOT

	if nVS3SEQVEN > 0 
		oGetPecas:aCols[oGetPecas:nAt,nVS3SEQVEN] := M->VS3_SEQVEN := cSequenVEN
	endif

Return


/*/{Protheus.doc} OX0010283_Criterio_Promocao_Peca
Pesquisa se uma peca tem promocao cadastrada

@author Rubens
@since 27/10/2023
@version 1.0

@type function
/*/
Static Function OX0010283_Criterio_Promocao_Peca()

	local aPromocao := {}
	Local cVS1CONPRO := "2"
	local cPesqPromo
	Local dDatRefPD     := dDataBase
	Local nVS1PERREM    := 0

	If lVS1PERREM
		nVS1PERREM := M->VS1_PERREM
		cVS1CONPRO := M->VS1_CONPRO
	EndIf
	cPesqPromo := cVS1CONPRO
	If cPesqPromo <> "0" .and. nVS3PESPRO > 0 .and. M->VS3_PESPRO == "0"
		cPesqPromo := "0"
	EndIf
	
	If nVAIDTCDES > 0 // Data para validar a Politica de Desconto
		if VAI->VAI_CODUSR <> __cUserID
			VAI->(DBSetOrder(4))
			VAI->(DBSeek(xFilial("VAI")+__cUserID))
		endif
		If VAI->VAI_DTCDES == "1" // Utilizar 1=Data de Inclusão do Orçamento para validar a Politica de Desconto
			dDatRefPD := M->VS1_DATORC
		EndIf
	EndIf

	SB1->( dbSetOrder(7) )
	SB1->( dbSeek( xFilial("SB1") + M->VS3_GRUITE + M->VS3_CODITE ) )
	SB1->( dbSetOrder(1) )

	SB2->( dbSetOrder(1) )
	SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + M->VS3_LOCAL ) )

	aPromocao := OX005PERDES(;
		SBM->BM_CODMAR,;                               // cMarca
		M->VS1_CENCUS,;                                // cCenRes
		M->VS3_GRUITE,;                                // cGrupo
		M->VS3_CODITE,;                                // cCodite
		M->VS3_QTDITE,;                                // nQtd
		M->VS3_PERDES,;                                // nPercent
		.f.,;                                          // lHlp
		M->VS1_CLIFAT,;                                // cCliente
		M->VS1_LOJA,;                                  // cLoja
		IIF(M->VS1_TIPORC == "2","3",M->VS1_TIPVEN),;  // cTipVen
		M->VS3_VALTOT/M->VS3_QTDITE,;                  // nValUni
		2,;                                            // nTipoRet
		M->VS1_FORPAG,;                                // cForPag
		cMVFORMALO,;                                   // cFormAlu
		.f.,;                                          // lFechOfi
		.f.,;                                          // lConMrgLuc
		cPesqPromo,;                                   // cConPromoc
		dDatRefPD,;                                    // dDatRefPD
		nVS1PERREM)                                    // nPERREM

	/*If len(aPromocao) < 3
		AADD(aPromocao,"")
	EndIf*/

Return aPromocao

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001ITEREL | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Preenche os itens relacionados na listbox                    |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/

Function OX001CleanCache()
	//FWFreeArray(@ITRelCache)

	Local nPos

	aSize(ITRelCache,0)
	aSize(SB2Cache,0)

	/*For nPos := 1 to Len(CacheSBZ)
		aSize(CacheSBZ[nPos,2], 0)
	Next nPos
	aSize(CacheSBZ,0)*/

	If ExistFunc("VEIFB_CLEANCACHE")
		VEIFB_CLEANCACHE()
	EndIf

	If ExistFunc("OX005CleanCache")
		OX005CleanCache()
	EndIf

	If ExistFunc("VEIFC_CLEANCACHE")
		VEIFC_CLEANCACHE()
	EndIf

Return


Function OX001ITEREL()
Local nCntFor
Local nCntFor2
Local cCodSB1    := ""
Local nRecnoAux  := 0
Local cGrupoVal  := ""
Local cCodIteVal := ""
Local nPos_ITRelCache

Local lUtilCache := .f.

Local nPosCodigo
Local nPosLocal

Local aRelPri    := {}
Local aRelSec    := {}
Private cForVal  := ""

if EXCLUI
	return .T.
EndIf

cGrupoVal  := oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]
cCodIteVal := oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE]
cForVal    := oGetPecas:aCols[oGetPecas:nAt,nVS3FORMUL]

//######################################################################
//# Passa os campos para a funcao que retorna o array dos relacionados #
//######################################################################
if !oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])] .and. !Empty(cGrupoVal+cCodIteVal)
	

	If (nPos_ITRelCache := aScan(ITRelCache, { |x| x[1] == M->VS1_TIPTEM + cGrupoVal + cCodIteVal + cForVal })) <> 0

		aSize(aIteRel,0)
		aIteRel := aClone(ITRelCache[nPos_ITRelCache,3])

		// Atualiza saldo em estoque da peca ...
		nPosCodigo := Len(aIteRel[1])-1
		nPosLocal := Len(aIteRel[1])
		For nCntFor := 1 to Len(aIteRel)
			if ! empty(aIteRel[nCntFor, nPosCodigo ])
				aIteRel[nCntFor,4] := OX001SLDPC( xFilial("SB2") + aIteRel[nCntFor, nPosCodigo ] + aIteRel[nCntFor, nPosLocal ] , .t. )
			endif
		Next nCntfor

	Else

		aIteRel := FG_ITEREL(M->VS1_TIPTEM,cGrupoVal,cCodIteVal,"cForVal")
		If lRelSec // Fazer os Relacionamentos Secundarios ?
			aRelPri := aClone(aIteRel) // Inicia com os Relacionamentos Primarios
			For nCntFor := 1 to len(aRelPri) // Percorrer os Relacionamenos Primarios
				aRelSec := FG_ITEREL(M->VS1_TIPTEM,aRelPri[nCntFor,1],aRelPri[nCntFor,2],"cForVal") // Buscar Relacionamentos Secundarios
				For nCntFor2 := 1 to len(aRelSec) // Percorrer os Relacionamenos Secundarios
					If ("["+cGrupoVal+cCodIteVal+"]") <> ("["+aRelSec[nCntFor2,1]+aRelSec[nCntFor2,2]+"]") // Tem que ser diferente do Item INICIAL pesquisado
						If aScan(aIteRel,{|x| x[1]+x[2] == aRelSec[nCntFor2,1]+aRelSec[nCntFor2,2] } ) == 0 // Nao pode ja estar nos Itens Relacionados
							aAdd(aIteRel,aClone(aRelSec[nCntFor2]))
						EndIf
					EndIf
				Next
			Next
		EndIf

		nRecnoAux := VE1->(Recno())

		VE1->(DBSetOrder(1))
		SB1->(DBSetOrder(7))

		For nCntFor := 1 to Len(aIteRel)

			SBM->(msSeek(xFilial("SBM")+aIteRel[nCntFor,1]))
			VE1->(msSeek(xFilial("VE1")+SBM->BM_CODMAR))
		
			if ! Empty( aIteRel[nCntFor,1] + aIteRel[nCntFor,2] )
				SB1->(DBSeek( xFilial("SB1") + aIteRel[nCntFor,1] + aIteRel[nCntFor,2] ))
				cCodSB1 := SB1->B1_COD
			Else
				cCodSB1 := ""
			Endif

			aAdd(aIteRel[nCntFor],SBM->BM_CODMAR)
			aAdd(aIteRel[nCntFor],VE1->VE1_DESMAR)
			// Se alterar a posicao da coluna, verificar no loop anterior pois pode dar erro...
			aAdd(aIteRel[nCntFor],cCodSB1)
			aAdd(aIteRel[nCntFor],FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")) 
			//

		next
		DbSelectArea("VE1")
		dbGoto(nRecnoAux)
		//
	EndIf

	If ( ExistBlock("OX001IRL") )
		aIteRel := ExecBlock("OX001IRL",.f.,.f.,{aIteRel})
	EndIf
	//
else
	aIteRel := {{"","","",0,0,"","","",""}}
endif
//
If len(aIteRel) <= 0
	aIteRel := {{"","","",0,0,"","","",""}}
EndIf
//
If ! lUtilCache .and. ! oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])] .and. ! Empty(cGrupoVal+cCodIteVal)
	AADD( ITRelCache, { M->VS1_TIPTEM + cGrupoVal + cCodIteVal + cForVal , timeCounter() , aClone(aIteRel) })
EndIf
//
if Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE])
	oGetPecas:aCols[oGetPecas:nAt,nVS3DESITE] := ""
	M->VS3_DESITE := ""
Endif

oLItRel:nAt := 1
oLItRel:SetArray(aIteRel)
oLItRel:bLine := { || { aIteRel[oLItRel:nAt,6] ,;
	aIteRel[oLItRel:nAt,7] ,;
	aIteRel[oLItRel:nAt,8] ,;
	aIteRel[oLItRel:nAt,1] ,;
	aIteRel[oLItRel:nAt,2] ,;
	aIteRel[oLItRel:nAt,3] ,;
	FG_AlinVlrs(Transform(aIteRel[oLItRel:nAt,4],"@E 999,999")),;
	FG_AlinVlrs(Transform(aIteRel[oLItRel:nAt,5],"@E 999,999,999.99"))}}
oLItRel:Refresh()
//

Return(.t.)
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001SOBEREL| Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Sobe os itens relacionados e atualiza as informaces do fiscal|##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001SOBEREL(_naIteRel)
Local cGrupoVal := aIteRel[_naIteRel,1]
Local cCodIteVal := aIteRel[_naIteRel,2]
Local nCntFor
Local aLinhaSalva := {}
Local cCodSalva
Local cGruSalva
Local cDesSalva
Local cTesSalva


if Empty(cCodIteVal)
	return .f.
endif

If ExistBlock("OX001PIR") // Permite selecionar o Item Relacionado?
	If !ExecBlock("OX001PIR",.f.,.f.,{ cGrupoVal , cCodIteVal })
		Return .f.
	EndIf
EndIf

// Verifica se o produto ja foi lancado no orcamento
for nCntFor := 1 to Len(oGetPecas:aCols)
	if  ! (oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])])
		if oGetPecas:aCols[nCntFor,nVS3CODITE] == cCodIteVal .and. oGetPecas:aCols[nCntFor,nVS3GRUITE] == cGrupoVal

			MsgInfo(Alltrim(cGrupoVal)+ " "+Alltrim(cCodIteVal)+ " - "+ STR0104,STR0025) // Produto ja lancado no orcamento.
			return .f.

		endif
	endif
next
//
aLinhaSalva := aClone(oGetPecas:aCols[oGetPecas:nAt])
cCodSalva := oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODITE","aHeaderP")]
cGruSalva := oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_GRUITE","aHeaderP")]
cDesSalva := oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_DESITE","aHeaderP")]
cTesSalva := oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODTES","aHeaderP")]
M->VS3_CODITE := oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] := Space(Len(cCodIteVal))

oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODITE","aHeaderP")] := Space(Len(cCodIteVal))
M->VS3_CODITE := oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODITE","aHeaderP")]
//
//oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] := cGrupoVal
M->VS3_GRUITE := cGrupoVal
__ReadVar := 'M->VS3_GRUITE'
//
lRetorna := .t.
if OX001FPOK(,,,,,.f.)

	If nVS3PESPRO > 0
		oGetPecas:aCols[oGetPecas:nAt,nVS3PESPRO] := M->VS3_PESPRO := "1" // Pesquisa Promocao nesta linha
	EndIf
	oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_PROMOC","aHeaderP")] := M->VS3_PROMOC := "0" // Promocao: NAO

	//oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] := cCodIteVal
	M->VS3_CODITE := cCodIteVal
 
	// Quando trocar o item deve deixar a TES em branco para recarregar com a TES do item relacionado
	oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODTES","aHeaderP")] := Space(TAMSX3("VS3_CODTES")[1])
	M->VS3_CODTES := Space(TAMSX3("VS3_CODTES")[1])
	__ReadVar := 'M->VS3_CODITE'
	//
	if OX001FPOK()
		If ExistBlock("OX001SRL")
			ExecBlock("OX001SRL",.f.,.f., {{cCodSalva, cGruSalva, cDesSalva, cTesSalva}})
		EndIf
	else
		lRetorna := .f.
	endif
	//
else
	lRetorna := .f.
endif

if !lRetorna
	oGetPecas:aCols[oGetPecas:nAt] := aClone(aLinhaSalva)
	FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
endif

return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001TPTPO  | Autor | Andre LAP             | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Traz dados do folder 1 (dados da nf)                         |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Balcao/Oficina                                               |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
// Tela para escolha do Tipo de Tempo quando Orcamento tipo Oficina // Andre Luis Almeida - 06/08/08 //
Function OX001TPTPO(cAux,lAltEnc)
Local lOk    := .t.
Local cVS1_TIPTEM := M->VS1_TIPTEM
Local cVS1_TIPTSV := M->VS1_TIPTSV
Local cVS1_FORMUL := M->VS1_FORMUL
Private cTpTpo := space(4) // Tipo de Tempo Pecas
Private cTpTSv := space(4) // Tipo de Tempo Servico
Private oTik    := LoadBitmap( GetResources(), "LBTIK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )

aFatParS := {}
If len(aFatParS)<=0
	aAdd(aFatParS,{.f.," "," "," "," "," ", .f., " "})
EndIF

Default cAux := ""
Default lAltEnc := .f. // Quando a alteração do Tipo de Tempo vem da Enchoice

If M->VS1_TIPORC <> "1"
	If !Empty(VS1->VS1_PEDREF) .and. !INCLUI
	    MsgAlert(STR0295,STR0025)
	    return .f.
    EndIf
EndIf

oFoldX001:SetOption(nFolderP)
oFoldX001:aEnable(nFolderS,.f.)
if lInconveniente
	oFoldX001:aEnable(nFolderI,.f.)
endif
If M->VS1_TIPORC == "2"
	oFoldX001:aEnable(nFolderS,.t.)
	if lInconveniente
		oFoldX001:aEnable(nFolderI,.t.)
	endif
endif

If Empty(cAux)
	If M->VS1_TIPORC == "2" .and. ( Empty(M->VS1_TIPTEM) .or. lAltEnc )
		lOk  := .f.
		cAux := cTpTpo := M->VS1_TIPTEM
		cAux2:= cTpTSv := M->VS1_TIPTSV

		DEFINE MSDIALOG oTiTemp TITLE OemtoAnsi(STR0107) FROM  02,04 TO 20,60 OF oMainWnd STYLE DS_MODALFRAME
		oTiTemp:lEscClose := .F.
		@ 001,003 MSpanel oPanel1 VAR "" OF oTiTemp SIZE 217,125 LOWERED
		@ 007,007 SAY (STR0217) SIZE 180,08 OF oPanel1 PIXEL COLOR CLR_BLUE
		@ 007,072 MSGET oTpTpo VAR cTpTpo PICTURE "@!" F3 "VOI" VALID(!Empty(cTpTpo).and.OX001TTPVA(cTpTpo) .and. OX001LVTTP(cTpTpo,cTpTSv) .and. Iif(!Empty(M->VS1_TPATEN) .And. lVOITPATEN, FGX_VOITPATEN(M->VS1_TPATEN, cTpTpo, .t.), .t.)) SIZE 20,08 OF oPanel1 PIXEL COLOR CLR_HBLUE
		@ 027,007 SAY (STR0218) SIZE 180,08 OF oPanel1 PIXEL COLOR CLR_BLUE
		@ 027,072 MSGET oTpTSv VAR cTpTSv PICTURE "@!" F3 "VOI" VALID(!Empty(cTpTSv).and.OX001TTPVA(cTpTSv) .and. OX001LVTTP(cTpTpo,cTpTSv) .and. Iif(!Empty(M->VS1_TPATEN) .And. lVOITPATEN, FGX_VOITPATEN(M->VS1_TPATEN, cTpTSv, .t.), .t.)) SIZE 20,08 OF oPanel1 PIXEL COLOR CLR_HBLUE
		//selecionar o faturar para qdo forem diferentes.

		@ 048,007 LISTBOX oLItCli FIELDS HEADER OemToAnsi(""), OemToAnsi(STR0219), COLSIZES 010,150 SIZE 200, 60;
		OF oPanel1 ON DBLCLICK ( FS_TIK(oLItCli:nAt,aFatParS[oLItCli:nAt,1]) ) PIXEL
		//		OF oPanel1 ON DBLCLICK ( If(GetNewPar("MV_ALTFATP","S")=="S",FS_TIK(oLItCli:nAt,aFatParS[oLItCli:nAt,1]),.t. ) ) PIXEL
		// MV_ALTFATP C Se "S", permite clickar e alterar FATURAR PARA na tela do Tipo de Tempo Oficina, quando mais de um FATURAR PARA

		oLItCli:SetArray(aFatParS)
		oLItCli:bLine := { || { Iif(aFatParS[oLItCli:nAt,1],oTik,oNo),aFatParS[oLItCli:nAt,2]}}

		//
		@ 120,003 MSpanel oPanel2 VAR "" OF oTiTemp SIZE 217,15 LOWERED
		DEFINE SBUTTON oBtnTPTOk FROM 002,140 TYPE 1 ACTION (Iif(!Empty(cTpTpo) .and. !Empty(cTpTSv) .and. OX001ELTT(),(oTiTemp:End(), lOk:=.t.) ,.T.)) ENABLE OF oPanel2
		DEFINE SBUTTON FROM 002,180 TYPE 2 ACTION (oTiTemp:End()) /*(Iif(!Empty(cTpTpo) .and. !Empty(cTpTSv),oTiTemp:End(),.t.))*/ ENABLE OF oPanel2

		If !empty(cTpTpo) .and. !Empty(cTpTsv)
			If OX001LVTTP(cTpTpo,cTpTSv)

				If !Empty(M->VS1_TPATEN)
					If lVOITPATEN
						// Validação Tipo de Atendimento por Tipo de Tempo (Peça)
						If !FGX_VOITPATEN(M->VS1_TPATEN, cTpTpo, .t.)
							Return .f.
						EndIf

						// Validação Tipo de Atendimento por Tipo de Tempo (Serviço)
						If !FGX_VOITPATEN(M->VS1_TPATEN, cTpTSv, .t.)
							Return .f.
						EndIf
					EndIf
				EndIf
			Else
				Return .f.
			Endif
		EndIf

		If Empty(cTpTpo)
			oTpTpo:SetFocus()
		Else
			oBtnTPTOk:SetFocus()
		EndIf

		ACTIVATE MSDIALOG oTiTemp CENTER

		If !lOk
			M->VS1_TIPTEM := cVS1_TIPTEM
			M->VS1_TIPTSV := cVS1_TIPTSV
			M->VS1_FORMUL := cVS1_FORMUL
			lSalvou  := .t.
			lDestroy := .f.
			oEnch:Refresh()
			oFoldX001:SetOption(nFolderP)
		EndIf
	EndIf
EndIF
DbSelectArea("VS1")
Return(lOk)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001LVTTP  | Autor | Rafael Goncalves      | Data | 13/12/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |Leavnta faturar para  os tipo de tempo informados.            |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Balcao/Oficina                                               |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OX001LVTTP(cTpTpo,cTpTSv)
Local lOk    := .t.
Local nPos := 0

default cTpTpo := space(4)
default cTpTSv := space(4)

aFatParS := {}

IF !Empty(cTpTpo)
	DbSelectArea("VOI")
	DbSetOrder(1)
	If DbSeek(xFilial("VOI")+cTpTpo)
		If VOI->VOI_REQPEC != "1"
			Help(" ",1,"TIPTPFAT")
			Return .F.
		EndIf
		IF !Empty(VOI->VOI_CLIFAT) .and. !Empty(VOI->VOI_LOJA) .and. VOI->VOI_USAPRO == "2" // Cliente Padrao
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+VOI->VOI_CLIFAT+VOI->VOI_LOJA)
			nPos := aScan(aFatParS,{|x| x[2] == VOI->VOI_CLIFAT+"-"+VOI->VOI_LOJA+" - "+left(SA1->A1_NOME,35) } )
			if nPos == 0
				aAdd(aFatParS,{ .f. , VOI->VOI_CLIFAT+"-"+VOI->VOI_LOJA+" - "+left(SA1->A1_NOME,35),VOI->VOI_CLIFAT,VOI->VOI_LOJA,SA1->A1_NOME,VOI->VOI_USAPRO, VOI->VOI_ALTCLI, VOI->VOI_TIPTEM})
			endif
		Else
			aAdd(aFatParS,{ .f. , X3CBOXDESC("VOI_USAPRO",VOI->VOI_USAPRO),VOI->VOI_CLIFAT,VOI->VOI_LOJA,Space(Len(SA1->A1_NOME)),VOI->VOI_USAPRO, VOI->VOI_ALTCLI,VOI->VOI_TIPTEM })
		EndIF
	EndIF
EndIf

IF !Empty(cTpTSv)
	DbSelectArea("VOI")
	DbSetOrder(1)
	If DbSeek(xFilial("VOI")+cTpTSv)
		IF !Empty(VOI->VOI_CLIFAT) .and. !Empty(VOI->VOI_LOJA) .and. VOI->VOI_USAPRO == "2" // Cliente Padrao
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+VOI->VOI_CLIFAT+VOI->VOI_LOJA)
			nPos := aScan(aFatParS,{|x| x[2] == VOI->VOI_CLIFAT+"-"+VOI->VOI_LOJA+" - "+left(SA1->A1_NOME,35) } )
			if nPos == 0
				aAdd(aFatParS,{ .f. , VOI->VOI_CLIFAT+"-"+VOI->VOI_LOJA+" - "+left(SA1->A1_NOME,35),VOI->VOI_CLIFAT,VOI->VOI_LOJA,SA1->A1_NOME,VOI->VOI_USAPRO, VOI->VOI_ALTCLI, VOI->VOI_TIPTEM })
			endif
		Else
			aAdd(aFatParS,{ .f. , X3CBOXDESC("VOI_USAPRO",VOI->VOI_USAPRO),VOI->VOI_CLIFAT,VOI->VOI_LOJA,Space(Len(SA1->A1_NOME)),VOI->VOI_USAPRO, VOI->VOI_ALTCLI, VOI->VOI_TIPTEM })
		EndIF
	EndIF
EndIf

If len(aFatParS)<=0
	aAdd(aFatParS,{.f.," "," "," "," "," ",.f., " "})
	if Type("oLItCli")<>"U"
		oLItCli:Disable()
	endif
Else
	If aFatParS[1,2] != If(Len(aFatParS)==2,aFatParS[2,2],aFatParS[1,2])
		//mensagem para informar mais de um faturar para.
		MsgInfo(STR0186+CHR(13)+CHR(10)+STR0187,STR0025)
		If aFatParS[1,6] == "1"// FABRICANTE DO VEICULO
			aFatParS[2,1] := .t.
		ElseIf aFatParS[2,6] == "1"// FABRICANTE DO VEICULO
			aFatParS[1,1] := .t.
		Endif
		if Type("oLItCli")<>"U"
			oLItCli:Enable()
		endif
	Else
		aFatParS := {aClone(aFatParS[1])}
		aFatParS[1,1] := .t.
		if Type("oLItCli")<>"U"
			oLItCli:Disable()
		endif
	EndIF
	if Type("oLItCli")<>"U"
		oLItCli:nAt := 1
		oLItCli:SetArray(aFatParS)
		oLItCli:bLine := { || { Iif(aFatParS[oLItCli:nAt,1],oTik,oNo),aFatParS[oLItCli:nAt,2]}}
		oLItCli:Refresh()
	endif
EndIF

Return(lOk)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |FS_TIK      | Autor | Rafael Goncalves      | Data | 13/12/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |Tik para escolha do Tp de Tempo quando Orcamento tipo Oficina |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Balcao/Oficina                                               |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_TIK(nLinha,lTipSel)
Local ni := 0
For ni := 1 to Len(aFatParS)
	aFatParS[ni,1] := .f.
Next

If  Len(aFatParS) == 1 .and. Empty(aFatParS[1,2]) .and. Empty(aFatParS[1,3]) .and. Empty(aFatParS[1,4]) .and. Empty(aFatParS[1,5]) //Array vazia
	return .t.
endif

If aFatParS[nLinha,7] == "1" // VOI_ALTCLI == 1 - Sim
	If aFatParS[nLinha,6] == "1" // VOI_USAPRO == 1 - Fabricante
		If GetNewPar("MV_ALTFATP","S")=="S"
			aFatParS[nLinha,1] := !lTipSel
		Else
			aFatParS[nLinha,1] := .f.
		Endif
	Else
		aFatParS[nLinha,1] := !lTipSel
	Endif
Else
	aFatParS[nLinha,1] := !lTipSel
Endif

//oLItCli:SetFocus()
oLItCli:Refresh()
Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001TTPVA  | Autor | Andre LAP             | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | valida tipo de tempo (TELA QUANDO FOR ORCAMENTO DE OFICINA)  |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Balcao/Oficina                                               |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001TTPVA(cAux)
Local lOk    := .t.
Local cTpTpR := "" // Tipo de Tempo Relacionado

Local oOficina := DMS_Oficina():New()

Default cAux := ""

dbSelectArea("SX3")
dbSetOrder(2)
If ReadVar() == "CTPTPO"
	cChave := "VS1_TIPTEM"
	M->VS1_TIPTEM := cAux
Else
	cChave := "VS1_TIPTSV"
	M->VS1_TIPTSV := cAux
Endif
cChvAux:= cAux

If dbSeek(cChave)
	cValTpTem := ""
	If !Empty(SX3->X3_VALID)
		cValTpTem += SX3->X3_VALID
	EndIf
	If !Empty(SX3->X3_VLDUSER)
		If !Empty(cValTpTem)
			cValTpTem += " .and. "
		EndIf
		cValTpTem += SX3->X3_VLDUSER
	EndIf
EndIf
DbSetOrder(1)

If oOficina:TipoTempoBloqueado(cChvAux,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
	&("M->"+cChave) := space(TamSX3(cChave)[1])
	lOk := .f.
Else
	If !Empty(cValTpTem)
		If !(&cValTpTem)
			lOk := .f.
		EndIf
	EndIf
	If lOk .and. !OX001LVTTP(cTpTpo,cTpTSv) // Variáveis Private TT de Peças e TT de Serviços
		lOk := .f.
	EndIf
EndIf

DbSelectArea("VOI")
DbSetOrder(1)
DbSeek(xFilial("VOI")+cChvAux)

If lOk
	If !Empty(VOI->VOI_TTRELA)
		cTpTpR := VOI->VOI_TTRELA
	Endif
	If ReadVar() == "CTPTPO" .and. Empty(cTpTSv)
		If Empty(cTpTpR)
			If OX001LVTTP(cTpTpo,cAux)
				cTpTSv := cAux
			Else
				lOk := .f.
			EndIf
		Else
			If OX001LVTTP(cTpTpo,cTpTpR)
				cTpTSv := cTpTpR		
			Else
				lOk := .f.
			EndIf
		EndIf
	ElseIf ReadVar() == "CTPTSV" .and. Empty(cTpTpo)
		If Empty(cTpTpR)
			If OX001LVTTP(cAux,cTpTSv)
				cTpTpo := cAux
			Else
				lOk := .f.
			EndIf
		Else
			If OX001LVTTP(cTpTpR,cTpTSv)
				cTpTpo := cTpTpR		
			Else
				lOk := .f.
			EndIf
		EndIf	
	EndIf
	If lOk
		DbSeek(xFilial("VOI")+cTpTpo)
		M->VS1_FORMUL := VOI->VOI_VALPEC
	EndIf
EndIf

DbSelectArea("VS1")
Return(lOk)
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001MUDFOL | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Trata a mudanca de folders entre as aCols                    |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001MUDFOL(nFOrigem, nFDestino)
if !(INCLUI .or. ALTERA) .or. M->VS1_TIPORC == "1"
	return .t.
endif
//
if nFDestino == 2
	FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
endif
if nFDestino == 3
	FG_MEMVAR(aHeaderS,oGetServ:aCols,oGetServ:nAt)
endif

if (nFOrigem == nFolderP .and. !OX001LINPOK())
	return .f.
endif

if (nFOrigem == nFolderS .and. !OX001LINSOK())
	return .f.
endif
// Apaga itens relacionados
aIteRel := {{"","","",0,0,"","",""}}
oLItRel:nAt := 1
oLItRel:SetArray(aIteRel)
oLItRel:bLine := { || { aIteRel[oLItRel:nAt,6] ,;
aIteRel[oLItRel:nAt,7] ,;
aIteRel[oLItRel:nAt,8] ,;
aIteRel[oLItRel:nAt,1] ,;
aIteRel[oLItRel:nAt,2] ,;
aIteRel[oLItRel:nAt,3] ,;
FG_AlinVlrs(Transform(aIteRel[oLItRel:nAt,4],"@E 999,999")),;
FG_AlinVlrs(Transform(aIteRel[oLItRel:nAt,5],"@E 999,999,999.99"))}}
oLItRel:Refresh()
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001PecFis | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Mudanca da aCols de Pecas p/ a aCols do Fiscal               |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001PecFis()
	local lNovo := .f.
	local nPos
	// Apenas por seguranca.
	//If MaFisRet(,"NF_DESPESA") <> M->VS1_DESACE
	//	MaFisRef("NF_DESPESA",,M->VS1_DESACE)
	//EndIf
	//If MaFisRet(,"NF_SEGURO") <> M->VS1_VALSEG
	//	MaFisRef("NF_SEGURO",,M->VS1_VALSEG)
	//EndIf
	//If MaFisRet(,"NF_FRETE") <> M->VS1_VALFRE
	//	MaFisRef("NF_FRETE",,M->VS1_VALFRE)
	//EndIf
	//
	nPos := aScan(aNumP,{|x| x[1] == oGetPecas:nAt } )
	if nPos == 0
		nTotFis ++
		aAdd(aNumP,{oGetPecas:nAt,nTotFis})
		nPos := Len(aNumP)
		lNovo := .t.
	endif
	//
	n := aNumP[nPos,2]
return lNovo

Function OX001ExistPecFis(nAtGetPecas)
	local nPos := aScan(aNumP,{|x| x[1] == nAtGetPecas } )
	if nPos > 0
		n := aNumP[nPos,2]
	endif
return (nPos > 0)
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001FisPec | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Mudanca da aCols do Fiscal p/ a aCols de Pecas               |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001FisPec()
n := oGetPecas:nAt
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001SrvFis | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Mudanca da aCols de servicos p/ a aCols do Fiscal            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001SrvFis()
// Apenas por seguranca.
MaFisRef("NF_DESPESA",,M->VS1_DESACE)
MaFisRef("NF_SEGURO",,M->VS1_VALSEG)
MaFisRef("NF_FRETE",,M->VS1_VALFRE)
//
nPos := aScan(aNumS,{|x| x[1] == oGetServ:nAt } )
if nPos == 0
	nTotFis ++
	aAdd(aNumS,{oGetServ:nAt,nTotFis})
	nPos := Len(aNumS)
endif
//
n := aNumS[nPos,2]
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001FisSrv | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Mudanca da aCols do Fiscal p/ a aCols de Servicos            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001FisSrv()
n := oGetServ:nAt
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | FS_LIMPAVEI| Autor | Andre Luis Almeida    | Data | 24/08/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Limpa variaveis M->VS1_ referente ao Veiculo                 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_LIMPAVEI()
M->VS1_DESMAR := ""
M->VS1_DESMOD := ""
M->VS1_CHAINT := ""
M->VS1_CHASSI := ""
M->VS1_PLAVEI := ""
M->VS1_CODFRO := ""
M->VS1_FABMOD := ""
M->VS1_DESCOR := ""
M->VS1_PROVEI := ""
M->VS1_NOMPRO := ""
M->VS1_ENDPRO := ""
M->VS1_CIDPRO := ""
M->VS1_ESTPRO := ""
M->VS1_FONPRO := ""
Return()
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001GETCHA | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Preenche o Chassi do Veiculo no Orcamento de Oficina         |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001GETCHA()
Local oVeiculos := DMS_Veiculo():New()
Local aRetEmp := {}
Local nPosVOI := 0

Private cPesqVV1 := M->VS1_GETKEY
//
if !Empty(cPesqVV1)
	if !(FG_POSVEI("cPesqVV1",))
		FS_LIMPAVEI()
		return .f.
	endif

	if VV1->VV1_GRASEV == "6" // SEM CHASSI
		FS_LIMPAVEI()
		return .f.
	endif
else
	FS_LIMPAVEI()
	return .f.
endif
//
DBSelectArea("VV1")

// Chassi Bloqueado
If oVeiculos:Bloqueado(VV1->VV1_CHAINT)
	Return .f. // A mensagem já é exibida dentro da função Bloqueado()
EndIf
//
FGX_ALTVEI("A") // 20/01/2015 - OTAVIO FAVARELLI - VEIXFUNA
//
If ExistFunc("FM_VEIGAR")
	FM_VEIGAR() // Verifica se o Veiculo esta em garantia - 04/05/2009 - Andre Luis Almeida
EndIf
//
M->VS1_GETKEY := VV1->VV1_CHASSI
//
OFA1100016_PesquisaCampanha(VV1->VV1_CHASSI)
//
If Len(aFatParS) == 0
	If !OX001LVTTP(M->VS1_TIPTEM,M->VS1_TIPTSV)
		Return .f.
	EndIf
EndIf

nPosVOI := aScan(aFatParS, {|x| cValToChar(x[1]) == '.T.'})

If nPosVOI > 0
	DbSelectArea("VOI")
	DbSetOrder(1)
	DBSeek(xFilial("VOI")+aFatParS[nPosVOI, 8])
EndIf

M->VS1_CLIFAT := VV1->VV1_PROATU
M->VS1_LOJA   := VV1->VV1_LJPATU

If nPosVOI > 0
	If aFatParS[nPosVOI,6] == "1" // FABRICANTE DO VEICULO
		VE4->(DbSetOrder(1))
		if VE4->(DbSeek(xFilial("VE4")+VV1->VV1_CODMAR))
			M->VS1_CLIFAT := VE4->VE4_CODFAB
			M->VS1_LOJA   := VE4->VE4_LOJA
		Endif
	ElseIf aFatParS[nPosVOI,6] == "2" // CLIENTE PADRAO
		If !Empty(VOI->VOI_CLIFAT)
			M->VS1_CLIFAT := VOI->VOI_CLIFAT
			M->VS1_LOJA   := VOI->VOI_LOJA
		Endif
	ElseIf aFatParS[nPosVOI,6] == "3" // FILIAL CORRENTE
		aRetEmp := FWArrFilAtu()
		DBSelectArea("SA1")
		DBSetOrder(3)
		If DBSeek(xFilial("SA1")+aRetEmp[18]) //CGC
			M->VS1_CLIFAT := SA1->A1_COD
			M->VS1_LOJA   := SA1->A1_LOJA
		Endif
	Endif
EndIf

M->VS1_CODMAR := VV1->VV1_CODMAR
M->VS1_CHASSI := VV1->VV1_CHASSI
M->VS1_CHAINT := VV1->VV1_CHAINT
M->VS1_PLAVEI := VV1->VV1_PLAVEI
M->VS1_CODFRO := VV1->VV1_CODFRO
//
VXA010GVO5(VV1->VV1_CHAINT,3)
//
If ExistBlock("VA010DPGR")
	ExecBlock("VA010DPGR",.f.,.f.,{VV1->VV1_CHAINT,3,0})
EndIf

cCodMar   := VV1->VV1_CODMAR
lJaGravou := .f.

dbSelectArea("VS1")

VO5->(DbSetOrder(1))
VO5->(MsSeek(xFilial("VO5")+VV1->VV1_CHAINT))
//
VE1->(DbSetOrder(1))
VE1->(MsSeek(xFilial("VE1")+VV1->VV1_CODMAR))
VV2->(DbSetOrder(1))
VV2->(MsSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
VVC->(DbSetOrder(1))
VVC->(MsSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
SA1->(DbSetOrder(1))
SA1->(MsSeek(xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU))
//
M->VS1_DESMAR := VE1->VE1_DESMAR
M->VS1_DESMOD := VV2->VV2_DESMOD
M->VS1_CHAINT := VV1->VV1_CHAINT
M->VS1_CHASSI := VV1->VV1_CHASSI
M->VS1_PLAVEI := VV1->VV1_PLAVEI
M->VS1_CODFRO := VV1->VV1_CODFRO
M->VS1_FABMOD := VV1->VV1_FABMOD
M->VS1_DESCOR := VVC->VVC_DESCRI
M->VS1_PROVEI := SA1->A1_COD
M->VS1_NOMPRO := SA1->A1_NOME
M->VS1_ENDPRO := SA1->A1_END
if lVAMCid
	VAM->(DbSetOrder(1))
	VAM->(MsSeek(xFilial("VAM")+SA1->A1_IBGE))
	M->VS1_CIDPRO := VAM->VAM_DESCID
	M->VS1_ESTPRO := VAM->VAM_ESTADO
Else
	M->VS1_CIDPRO := SA1->A1_MUN
	M->VS1_ESTPRO := SA1->A1_EST
Endif
M->VS1_FONPRO := SA1->A1_TEL

If INCLUI .or. ALTERA
	If len(oGetServ:aCols) > 1 .or. ( len(oGetServ:aCols) == 1 .and. !oGetServ:aCols[1,len(oGetServ:aCols[1])] .and. !Empty(oGetServ:aCols[1,fg_posvar("VS4_CODSER","aHeaderS")]) )
		Processa( {|| OX001RECALC( IIf(INCLUI,3,4) ) }) // Recalcular os SERVICOS se o usuario digitar o Veiculo no Orcamento e ja possuir Servicos informados na aCols correspondente
	EndIf
EndIf

Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001ATUF1  | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Atualiza informacoes adicionais                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001ATUF1()
Local nCntFor
//
If aScan(aOrc,{|x| x[2] == Rettitle("VS1_VALIPI")}) == 0 .and. (M->VS1_VALIPI > 0 .Or. M->VS3_VIPIFB > 0)
	aAdd(aOrc, {'MaFisRet(,"NF_VALIPI")',   Rettitle("VS1_VALIPI"), 0, "VS1->VS1_VALIPI"}) // Valor do IPI
Endif
If MaFisFound('NF')
	for nCntFor := 1 to Len(aOrc)
		if INCLUI .or. ALTERA .or. (cVS1Status $ "5.F" .and. FECHA) .or. lPediVenda
			aOrc[nCntFor,3] := &(aOrc[nCntFor,1])
		else
			aOrc[nCntFor,3] := &(aOrc[nCntFor,4])
		endif
	next
EndIf
If !lOX001Auto
	olBox:nAt := 1
	olBox:SetArray(aOrc)
	olBox:bLine := { || { aOrc[olBox:nAt,2],;
	FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}
	olBox:Refresh()
endif
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001SAIR   | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Processa a saida da rotina                                   |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001SAIR(nOpc)
if nOpc == 2 .and. !FECHA
	oDlgXX001:End()
	return .f.
endif
if MsgYesNo(STR0108,STR0025)
	if ExistBlock("OXA001SAIR")       // O B S O L E T O
		ExecBlock("OXA001SAIR",.f.,.f.)
	Endif
	if ExistBlock("OX001SAI")
		ExecBlock("OX001SAI",.f.,.f.)
	Endif
	oDlgXX001:End()
	return .t.
endif
//
return .f.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001VLABERT| Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Lancamento de pecas e servicos nas O.S. a partir do orcamento|##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OX001VLABERT(cNumOrd,cTipTem,cChassiInt,cCliFat,cLojFat,cOrcAtu,cTipTemSrv,cBco,cCondPgto,nVlFraSrvc,nVlFraPeca)
Local aArea := {}
Local cQuery, cQSER := "SQLSERV", cQMOVPS := "SQLMOVPS", cAuxMsg
Local lValidTTPeca := .f. // Indica se sera validado o TT de Peca
Local lValidTTServ := .f. // Indica se sera validado o TT de Servico
Local cDepInt := cDepGar := ""
Local nCntFor := 0
Local cStatGarMut
Local nRecVO1 := 0
//
Default cTipTemSrv := cTipTem
Default cBco := ""
Default cCondPgto := ""
//
aArea := sGetArea(aArea , Alias())
aArea := sGetArea(aArea , "VO1")
aArea := sGetArea(aArea , "VO2")
aArea := sGetArea(aArea , "VO3")
aArea := sGetArea(aArea , "VO4")
aArea := sGetArea(aArea , "VV1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rubens - 04/11/2009                                                                                              ³
//³Verifica se a OS selecionada é do mesmo veiculo, proprietario e foi selecionado o mesmo cliente para faturar para³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VO1")
cQuery := "SELECT R_E_C_N_O_"
cQuery += "  FROM "+RetSqlName("VO1")
cQuery += " WHERE VO1_FILIAL = '" + xFilial("VO1") + "'"
cQuery += "   AND VO1_NUMOSV = '" + cNumOrd + "'"
cQuery += "   AND D_E_L_E_T_ = ' '"
nRecVO1 := FM_SQL(cQuery)
If nRecVO1 > 0
	VO1->(DbGoTo(nRecVO1))
Else
	MsgStop(STR0109+" "+cNumOrd)
	sRestArea(aArea)
	Return(.f.)
endif

If VO1->VO1_GARMUT == "1"
	cStatGarMut := OA550STAT(cNumOrd,VS1->VS1_NUMORC)
	If cStatGarMut <> "L" .and. !Empty(cStatGarMut)
		If !lOX001Auto
			MsgStop(STR0249) // "Garantia Mutua não aprovada"
		EndIf
		Return(.f.)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Franquia - verifica se ja foi informado valor de franquia na OS selecionada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if VO1->VO1_FRANQU > 0 .and. nVlFraSrvc <> 0
	if !lOX001Auto
		MsgStop(STR0150)
	endif
	sRestArea(aArea)
	Return(.f.)
endif
if VO1->(ColumnPos("VO1_FRANQP")) <> 0 .and. VO1->VO1_FRANQP > 0 .and. nVlFraPeca <> 0
	if !lOX001Auto
		MsgStop(STR0151)
	endif
	sRestArea(aArea)
	Return(.f.)
endif
//

dbSelectArea("VV1")
dbSetOrder(1)
dbSeek(xFilial("VV1")+cChassiInt)

if VO1->VO1_CHAINT <> cChassiInt
	if !lOX001Auto
		MsgStop(STR0111)
	endif
	sRestArea(aArea)
	Return(.f.)
endif
//
// Validação do proprietario. Caso a concessionaria possua regras proprias de validação, executa o PE,
// caso contrário realiza a verificação padrão
//
if ExistBlock("OX001VPP")
	if !ExecBlock("OX001VPP",.f.,.f.)
		sRestArea(aArea)
		Return(.f.)
	Endif
else
	if	VO1->VO1_PROVEI <> VV1->VV1_PROATU .or. ;
		VO1->VO1_LOJPRO <> VV1->VV1_LJPATU
		if !lOX001Auto
			MsgStop(STR0112)
		endif
		sRestArea(aArea)
		Return(.f.)
	endif
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query utilizada para verificar se deve validar os tipos de tempo de peca, servico ou ambos³
//³verificacao deve ser feita pois agora existe TT de peca e TT de servico                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT COUNT(VS3.VS3_NUMORC) CONTVS3, COUNT(VS4.VS4_NUMORC) CONTVS4 "
cQuery +=  " FROM "+RetSQLName("VS1")+" VS1 LEFT JOIN "+RetSQLName("VS3")+" VS3 ON VS3_FILIAL='"+xFilial("VS3")+"' AND VS3_NUMORC=VS1_NUMORC AND VS3.D_E_L_E_T_=' '"
cQuery += 											" LEFT JOIN "+RetSQLName("VS4")+" VS4 ON VS4_FILIAL='"+xFilial("VS4")+"' AND VS4_NUMORC=VS1_NUMORC AND VS4.D_E_L_E_T_=' '"
cQuery += " WHERE VS1.VS1_FILIAL = '"+xFilial("VS1")+"'"
cQuery +=   " AND VS1.VS1_NUMORC = '" + cOrcAtu + "'"
cQuery +=   " AND VS1.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQMOVPS, .F., .T. )
(cQMOVPS)->(dbGoTop())
if !(cQMOVPS)->(Eof())
	if (cQMOVPS)->CONTVS3 > 0
		// Validacao do Tipo de Tempo das Pecas
		lValidTTPeca := .t.
	endif

	if (cQMOVPS)->CONTVS4 > 0 .and. cTipTem <> cTipTemSrv
		// Validacao do Tipo de Tempo dos Servicos
		lValidTTServ := .t.
	endif
endif
(cQMOVPS)->(dbCloseArea())
dbSelectArea("VO1")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao do Banco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !Empty(cBco)
	cQuery := "SELECT DISTINCT VS1_CODBCO FROM "+RetSQLName("VS1")+" WHERE VS1_FILIAL ='"+xFilial("VS1")+"' AND VS1_NUMOSV = '"+cNumOrd+"' AND VS1_CODBCO <> '   ' AND D_E_L_E_T_=' '"
	cAuxMsg := FM_SQL(cQuery)
	if !Empty(cAuxMsg) .and. cBco <> cAuxMsg
		if !lOX001Auto
			MsgAlert(STR0113)
		endif
		sRestArea(aArea)
		Return(.f.)
	endif
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao da Condicao do Pgto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !Empty(cCondPgto)
	cQuery := "SELECT DISTINCT VS1_FORPAG FROM "+RetSQLName("VS1")+" WHERE VS1_FILIAL ='"+xFilial("VS1")+"' AND VS1_NUMOSV = '"+cNumOrd+"' AND VS1_FORPAG <> '   ' AND D_E_L_E_T_=' '"
	cAuxMsg := FM_SQL(cQuery)
	if !Empty(cAuxMsg) .and. cCondPgto <> cAuxMsg
		if !lOX001Auto
			MsgAlert(STR0114)
		endif
		sRestArea(aArea)
		Return(.f.)
	endif
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao do Cliente selecionado para Faturar Para³
//³Validacao do Depto. Interno e Garantia            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lValidTTPeca
	For nCntFor := 1 to len(oGetPecas:aCols)
		If !oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])]
			cDepInt := oGetPecas:aCols[nCntFor,nVS3DEPINT]
			cDepGar := oGetPecas:aCols[nCntFor,nVS3DEPGAR]
		endif
	Next
	cAuxMsg := OX001VLDCLI(cNumOrd,cTipTem,cCliFat,cLojFat,"P",cDepInt,cDepGar)
	if !Empty(cAuxMsg)
		if !lOX001Auto
			MsgAlert(cAuxMsg)
		endif
		sRestArea(aArea)
		Return .f.
	endif
endif

if lValidTTServ .and. cTipTem <> cTipTemSrv
	For nCntFor := 1 to len(oGetServ:aCols)
		If !oGetServ:aCols[nCntFor,len(oGetServ:aCols[nCntFor])]
			cDepInt := oGetServ:aCols[nCntFor,fg_posvar("VS4_DEPINT","aHeaderS")]
			cDepGar := oGetServ:aCols[nCntFor,fg_posvar("VS4_DEPGAR","aHeaderS")]
		endif
	Next
	cAuxMsg := OX001VLDCLI(cNumOrd,cTipTemSrv,cCliFat,cLojFat,"S",cDepInt,cDepGar)
	if !Empty(cAuxMsg)
		if !lOX001Auto
		MsgAlert(cAuxMsg)
		EndIf
		sRestArea(aArea)
		Return .f.
	endif
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao do Tipo de Tempo do Orcamento Selecionado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lValidTTPeca
	cAuxMsg := OX001VLDTT(cNumOrd,cTipTem)
	if !Empty(cAuxMsg)
		if !lOX001Auto
		MsgAlert(cAuxMsg)
		EndIf
		sRestArea(aArea)
		Return .f.
	endif
endif

if lValidTTServ .and. cTipTem <> cTipTemSrv
	cAuxMsg := OX001VLDTT(cNumOrd,cTipTemSrv)
	if !Empty(cAuxMsg)
		if !lOX001Auto
			MsgAlert(cAuxMsg)
		EndIf
		sRestArea(aArea)
		Return .f.
	endif
endif
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rubens - 08/12/2009                                    ³
//³Verifica se ja existe o mesmo servico na OS selecionada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VS4")
dbSetOrder(1)
dbSeek(xFilial("VS4")+cOrcAtu)

While !VS4->(Eof()) .and. VS4->VS4_FILIAL == xFilial("VS4") .and. VS4->VS4_NUMORC == cOrcAtu
	//
	If FM_SQL("SELECT VOK_INCMOB FROM "+RetSQLName("VOK")+" WHERE VOK_FILIAL = '"+xFilial("VOK")+"' AND VOK_TIPSER = '"+VS4->VS4_TIPSER+"' AND D_E_L_E_T_ = ' '") <> "2" // só entra aqui se nao for Serviço de Terceiros
		//
		cQuery := "SELECT DISTINCT VO4.VO4_GRUSER GRUSER, VO4.VO4_CODSER CODSER"
		cQuery +=  " FROM "+RetSQLName("VO2")+" VO2 JOIN "+RetSQLName("VO4")+" VO4 ON VO4.VO4_FILIAL = '"+xFilial("VO4")+"'"
		cQuery +=                                  " AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM"
		cQuery +=                                  " AND VO4_DATCAN = '        '" // Desconsidera registros cancelados
		cQuery +=                                  " AND VO4.D_E_L_E_T_=' '"
		cQuery += " WHERE VO2.VO2_FILIAL = '"+xFilial("VO2")+"'"
		cQuery +=   " AND VO2.VO2_NUMOSV = '"+cNumOrd+"'"
		cQuery +=   " AND VO2.VO2_TIPREQ = 'S'" // Requisicao de Servicos
		cQuery +=   " AND VO2.D_E_L_E_T_ = ' '"
		cQuery +=   " AND VO4.VO4_GRUSER = '"+VS4->VS4_GRUSER+"'"
		cQuery +=   " AND VO4.VO4_CODSER = '"+VS4->VS4_CODSER+"'"
		//
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQSER, .F., .T. )
		//
		if !(cQSER)->(Eof())
			MsgStop(STR0115)
			(cQSER)->(dbCloseArea())
			dbSelectArea(aArea[1,1])
			sRestArea(aArea)
			Return(.f.)
		endif
		//
		(cQSER)->(dbCloseArea())
		//
	Endif
	//
	VS4->(dbSkip())
	//
Enddo

dbSelectArea(aArea[1,1])
sRestArea(aArea)
//
Return(.t.)
/*
===============================================================================
###############################################################################
##+----------+----------------+-------+-------------------+------+----------+##
##|Função    |OX001VLDTT      | Autor | Rubens Takahashi  | Data | 11/01/10 |##
##+----------+----------------+-------+-------------------+------+----------+##
##|Descrição | Validacao se o Tipo de Tempo da OS selecionada na exportacao |##
##|          | ja esta Cancelado/Liberado/Fechado                           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OX001VLDTT(cNumOrd,cTipTem)
Local cRetorno := ""

&& Verifica se o tipo de tempo foi disponibilizado
DbSelectArea("VO2")
DbSetOrder(1)
DbSeek(xFilial("VO2")+cNumOrd )
Do While !Eof() .And. xFilial("VO2")==VO2->VO2_FILIAL .And. VO2->VO2_NUMOSV == cNumOrd

	If VO2->VO2_TIPREQ == "P"

		DbSelectArea("VO3")
		DbSetOrder(1)
		DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM+cTipTem)
		If ( !Empty(VO3->VO3_DATDIS) .Or. !Empty(VO3->VO3_DATFEC) .Or. !Empty(VO3->VO3_DATCAN) )
			If !Empty(VO3->VO3_DATCAN)
				cRetorno := STR0116 +Chr(13)+ STR0119 +": "+cTipTem
			Elseif !Empty(VO3->VO3_DATFEC)
				cRetorno := STR0117 +Chr(13)+ STR0119 +": "+cTipTem
			Elseif !Empty(VO3->VO3_DATDIS)
				cRetorno := STR0118 +Chr(13)+ STR0119 +": "+cTipTem
			EndIf
		EndIf
	Else

		DbSelectArea("VO4")
		DbSetOrder(1)
		DbSeek(xFilial("VO4")+VO2->VO2_NOSNUM+cTipTem)
		If ( !Empty(VO4->VO4_DATDIS) .Or. !Empty(VO4->VO4_DATFEC) .Or. !Empty(VO4->VO4_DATCAN) )

			If !Empty(VO4->VO4_DATCAN)
				cRetorno := STR0116 +Chr(13)+ STR0119 +": "+cTipTem
			ElseIf !Empty(VO4->VO4_DATDIS)
				cRetorno := STR0118 +Chr(13)+ STR0119 +": "+cTipTem
			ElseIf !Empty(VO4->VO4_DATFEC)
				cRetorno := STR0117 +Chr(13)+ STR0119 +": "+cTipTem
			EndIf
		EndIf
	EndIf

	DbSelectArea("VO2")
	DbSkip()

EndDo
Return cRetorno
/*
===============================================================================
###############################################################################
##+----------+----------------+-------+-------------------+------+----------+##
##|Função    |OX001VLDCLI     | Autor | Rubens Takahashi  | Data | 11/01/10 |##
##+----------+----------------+-------+-------------------+------+----------+##
##|Descrição | Validacao do cliente faturar para da OS selecionada na       |##
##|          | na exportacao                                                |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OX001VLDCLI(cNumOrd,cTipTem,cCliFat,cLojFat,cTipVld,cDepInt,cDepGar)
Local cRetorno := "", cQuery
Local cQFATPAR := "SQLFTPR"
Local oArea := GetArea()
Local oAreaVOI := GetArea("VOI")
Local aSrvImpVO4 := {}

Default cDepInt := ""
Default cDepGar := ""

VOI->(dbSetOrder(1))
VOI->(MsSeek(xFilial("VOI") + cTipTem ))

cQuery := "SELECT DISTINCT VO3_FATPAR CLIFAT , VO3_LOJA LOJFAT "
cQuery += " , VO3_DEPINT DEPINT , VO3_DEPGAR DEPGAR "
cQuery += " FROM ( SELECT VO3_FATPAR, VO3_LOJA, SUM( CASE VO2_DEVOLU"
cQuery +=                                               " WHEN '1' THEN VO3_QTDREQ "
cQuery +=                                               " WHEN '0' THEN (VO3_QTDREQ * -1) "
cQuery +=                                           " END ) AS SALDO"
cQuery += " , VO3_DEPINT , VO3_DEPGAR "
cQuery +=          " FROM "+RetSQLName("VO2")+" VO2 JOIN "+RetSQLName("VO3")+" VO3 ON VO3.VO3_FILIAL = '"+xFilial("VO3")+"'"
cQuery +=                                         " AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM"
cQuery +=                                         " AND VO3.VO3_TIPTEM = '"+cTipTem+"'"
cQuery +=                                         " AND VO3.VO3_DATCAN = '        '" // Desconsidera registros cancelados
cQuery +=                                         " AND VO3.D_E_L_E_T_ = ' '"
cQuery +=          " WHERE VO2.VO2_FILIAL = '"+xFilial("VO2")+"'"
cQuery +=            " AND VO2.VO2_NUMOSV = '"+cNumOrd+"'"
cQuery +=            " AND VO2.VO2_TIPREQ = 'P'" // Requisicao de Pecas
cQuery +=            " AND VO2.D_E_L_E_T_ = ' '"
cQuery +=          " GROUP BY VO3.VO3_FATPAR, VO3.VO3_LOJA "
cQuery += " , VO3_DEPINT , VO3_DEPGAR "
cQuery += " ) TEMP"
cQuery += " WHERE TEMP.SALDO <> 0" // So considera requisicoes com saldo
cQuery += " UNION "
cQuery += "SELECT DISTINCT VO4.VO4_FATPAR CLIFAT, VO4.VO4_LOJA LOJFAT "
cQuery += " , VO4_DEPINT DEPINT , VO4_DEPGAR DEPGAR "
cQuery +=  " FROM "+RetSQLName("VO2")+" VO2 JOIN "+RetSQLName("VO4")+" VO4 ON VO4.VO4_FILIAL = '"+xFilial("VO4")+"'"
cQuery +=                                 " AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM"
cQuery +=                                 " AND VO4_TIPTEM = '"+cTipTem+"'"
cQuery +=                                 " AND VO4_DATCAN = '        '" // Desconsidera registros cancelados
cQuery +=                                 " AND VO4.D_E_L_E_T_ = ' '"
cQuery += " WHERE VO2.VO2_FILIAL = '"+xFilial("VO2")+"'"
cQuery +=   " AND VO2.VO2_NUMOSV = '"+cNumOrd+"'"
cQuery +=   " AND VO2.VO2_TIPREQ = 'S'" // Requisicao de Servicos
cQuery +=   " AND VO2.D_E_L_E_T_ = ' '"
cQuery += " UNION "
cQuery += "SELECT DISTINCT VS1_CLIFAT CLIFAT, VS1_LOJA LOJFAT"
cQuery += " , VSJ_DEPINT DEPINT , VSJ_DEPGAR DEPGAR "
cQuery +=  " FROM "+RetSQLName("VSJ")+" VSJ JOIN "+RetSQLName("VS1")+" VS1 ON VS1.VS1_FILIAL = '"+xFilial("VS1")+"'"
cQuery +=                                 " AND VS1.VS1_NUMORC = VSJ.VSJ_NUMORC"
cQuery +=                                 " AND VS1.VS1_TIPTEM = '"+cTipTem+"'"
cQuery +=                                 " AND VS1.D_E_L_E_T_ = ' '"
cQuery += " WHERE VSJ.VSJ_FILIAL = '"+xFilial("VSJ")+"'"
cQuery +=   " AND VSJ.VSJ_NUMOSV = '"+cNumOrd+"'"
cQuery +=   " AND VSJ.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQFATPAR, .F., .T. )
(cQFATPAR)->(dbGoTop())
if !(cQFATPAR)->(EOF()) .and. !Empty((cQFATPAR)->CLIFAT)

	// Se for Servico, chama a funcao FM_IMPVO4 somente para retornar a matriz de servicos,
	// pois la existe um PE que pode mudar o faturar para ...
	If cTipVld == "S" .and. ExistBlock("FMIMPORC")
		aCodErro := {"",""}
		FM_IMPVO4( @aCodErro, VS1->VS1_NUMORC , cNumOrd, , .f. , @aSrvImpVO4,, .F. )
		If Len(aSrvImpVO4) > 0
			cCliFat := aSrvImpVO4[1,2]
			cLojFat := aSrvImpVO4[1,3]
		EndIf
	EndIf

	if cCliFat <> (cQFATPAR)->CLIFAT .or. cLojFat <> (cQFATPAR)->LOJFAT
		cRetorno :=STR0120
	endif

	// Valida Departamento Interno
	If VOI->VOI_DEPINT == "1" .and. (cQFATPAR)->DEPINT <> cDepInt
		cRetorno := STR0241
	EndIf

	// Valida Departamento Garantia
	If VOI->VOI_DEPGAR == "1" .and. (cQFATPAR)->DEPGAR <> cDepGar
		cRetorno := STR0242
	EndIf

endif
(cQFATPAR)->(dbCloseArea())
RestArea( oAreaVOI )
RestArea( oArea )
Return cRetorno
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001RESITE | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Faz a (des)reserva de um item a partir de um orcamento       |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001RESITE(cNumOrc,lRes, aVetSeq , lValidFase)
Local cDocumento := ""
Local aItensNew  := {}
Local aAuxItens  := {}
Local nQtAtend   := 0
Local aVetLocPec := {}
Local iVLP, ii
Local i          := 0
Local cQuery     := ""
Local cQAlias    := "SQLSDB"
Local lUsaVenc   := .F.
Local nSaldoLote := 0
Local nPosAcolsLt:= 0
Local lCanc      := .f.

//Local nVS3GRUITE := ""
//Local nVS3CODITE := ""
Local lCtrlLote  := GetNewPar("MV_RASTRO","N") == "S"
Local aRecVS3 	 := {}

Local nSlvQtdTra := 0
Local nSlvQtdAgu := 0

Local lAtuFis    := .f.

Local nRecLote   := 0
Local nPosRecL   := 0
Local aVetRecLt  := {}
Local lObrRes 		:= .f.
Local oPeca 	  := DMS_Peca():New()
Local cTesMvEst := ""

Local cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local cFaseTransf := GetNewPar("MV_MIL0104","") // Fase Default Conferencia/Reserva para Transferencia de Pecas ( OFIOM430 )

Local lESTNEG     := GetNewPar("MV_ESTNEG","S") == "S"

Local lVerConf    := .f.

Local cArmOri := ""
Local cLocOri := ""

Local cArmDes := ""
Local cLocDes := ""

Local aItemMov := {}
Local oEst     := DMS_Estoque():New()

Default aVetSeq   :={}
Default lValidFase:= .t.

lRejLib:= If(Type("lRejLib")=="U",.f.,lRejLib)

///////////////////////////////////////////////////

If lCtrlLote
	if lValidFase
		If (Funname() $ "OFIXA015.OFIXA013.OFIXA016.OFIXA019" .or. lRejLib)
			Return ""
		Endif

		//If Funname() <> "OFIXA021" .AND. (Funname() <> "OFIXA018" .OR. (Funname() == "OFIXA018" .AND. !lXA018CancPed))
			//nVS3GRUITE  := nVS3GRUITE
			//nVS3CODITE  := nVS3CODITE
		//Endif
	Endif
EndIf

If Type("Exclui")=="U"
   Exclui := .f.
Endif

If lValidFase
	cFaseOrc := OI001GETFASE(VS1->VS1_NUMORC)
	nPosR := At("R",cFaseOrc)
	nPosA := At(VS1->VS1_STATUS,cFaseOrc)

	lObrRes := ( nPosR <= nPosA .and. nPosR != 0)
EndIf

//+------------------------------------------------------------+
//| PE para desviar e não fazer a reserva, pois há especifícos |
//| que podem fazer a reserva do produto on-line.              |
//+------------------------------------------------------------+
if ExistBlock("OX00RESERV")
	cDocumento := ExecBlock("OX00RESERV",.F.,.F.)
Endif
if ExistBlock("OX001RES")
	cDocumento := ExecBlock("OX001RES",.F.,.F.)
Endif
//
If ! Empty( cDocumento )
	Return( cDocumento )
Endif
cDocumento  := Criavar("D3_DOC")
cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
cDocumento	:= A261RetINV(cDocumento)
//
DBSelectArea("VS1")
DBSetOrder(1)
DBSeek(xFilial("VS1")+ cNumOrc)
//
if (VS1->VS1_TIPORC <> "2" .and. lValidFase) .or. VS1->VS1_TIPORC == "3"
	cFaseOrc := OI001GETFASE(VS1->VS1_NUMORC)
	if VS1->VS1_TIPORC == "3" // Transferencia
		If cFaseConfer $ IIf(!Empty(cFaseTransf),cFaseTransf,cFaseOrc) .and. ;
			( VS1->VS1_STATUS <> "0" .and. VS1->VS1_STATUS <> cFaseConfer ) // Fase de Conferencia esta contida nas Fases de Transferencia (OFIOM430)
			lVerConf := .t.
		else
			lVerConf := .f.
		EndIf
	Else
		nPos4 := At(cFaseConfer,cFaseOrc)
		nPosAtu := At(VS1->VS1_STATUS,cFaseOrc)
		if nPos4 < nPosAtu .and. nPos4 > 0
			lVerConf := .t.
		else
			lVerConf := .f.
		endif
	EndIf
Else
	lVerConf := .f.
Endif
//
If lESTNEG // Quando MV_ESTNEG igual a "S", NAO validar Conferencia
	lVerConf := .f.
EndIf
//
//////////////////////////////////////////////////////////////////////
//                                                                  //
// TESTAR SEM ESSE BLOCO! CASO O MATA261 NAO BLOQUEIA, VOLTAR BLOCO //
//                                                                  //
//////////////////////////////////////////////////////////////////////
/*
cLocalRes := GetMv( "MV_RESITE" )+Space(TamSx3("B2_LOCAL")[1]-Len(GetMv("MV_RESITE")))
DBSelectArea("VS3")
DBSetOrder(1)
DBSeek(xFilial("VS3")+cNumOrc)
While !eof() .and. xFilial("VS3") + cNumOrc == VS3->VS3_FILIAL + VS3->VS3_NUMORC
	SB1->(DbSetOrder(7))
	SB1->(MsSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
	If !MaAvalPerm( 3 , { VS3->VS3_LOCAL , SB1->B1_COD } ) .or. !MaAvalPerm( 3 , { cLocalRes , SB1->B1_COD } )
		SB1->(DbSetOrder(1))
		Return "" // Usuario sem permissao para utilizar o Almoxarifado
	EndIf
	VS3->(DbSkip())
EndDo
*/
//////////////////////////////////////////////////////////////////////
//
DBSelectArea("VS3")
DBSetOrder(1)
DBSeek(xFilial("VS3")+ cNumOrc)
// Adiciona cabecalho com numero do documento e data da transferencia modelo II
aadd (aItensNew,{ cDocumento , dDataBase})
//
If lCtrlLote .and. lRes .and. lValidFase
	While !eof() .and. xFilial("VS3") + cNumOrc == VS3->VS3_FILIAL + VS3->VS3_NUMORC
		SB1->(DbSetOrder(7))
		SB1->(DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
		oPeca:LoadB1()
		nSaldoLote := 0
		lAtuFis := .f.
		cTesMvEst := FM_SQL("SELECT F4_ESTOQUE FROM " + RetSQLName("SF4") + " SF4 WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = '"+VS3->VS3_CODTES+"' AND D_E_L_E_T_=' '")
		If Rastro( SB1->B1_COD ) .and. cTesMvEst == "S"
			nRecLote := VS3->(Recno())
			nPosRecL := aScan(aVetRecLt,nRecLote)
			If nPosRecL == 0
				aAdd(aVetRecLt,nRecLote)
			Else
				VS3->(DbSkip())
				Loop
			Endif
			if Empty(VS3->VS3_LOTECT)
				nSlvQtdTra := VS3->VS3_QTDTRA
				nSlvQtdAgu := VS3->VS3_QTDAGU
				lUsaVenc:= SuperGetMv('MV_LOTVENC')=='S'
				aSaldos := SldPorLote(SB1->B1_COD,VS3->VS3_LOCAL,VS3->VS3_QTDITE,NIL,"","","","",NIL,NIL,NIL,lUsaVenc,nil,nil,dDataBase)
				nPosAcolsLt := aScan( oGetPecas:aCols,{ |x| x[nVS3GRUITE]+x[nVS3CODITE] == VS3->VS3_GRUITE+VS3->VS3_CODITE })
				For i := 1 to Len(aSaldos)
					For ii:=1 to Len(aHeaderP)
						M->&(aHeaderP[ii,2]):= oGetPecas:aCols[Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols)),ii]
					Next
					If VS3->VS3_QTDITE <= aSaldos[i,5]
						RecLock("VS3",.f.)
						VS3->VS3_LOTECT := aSaldos[i,1]
						VS3->VS3_NUMLOT := aSaldos[i,2]
						VS3->VS3_DTVALI := aSaldos[i,7]
						oGetPecas:aCols[Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols)),nVS3LOTECT]:= aSaldos[i,1]
						oGetPecas:aCols[Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols)),nVS3NUMLOT]:= aSaldos[i,2]
						oGetPecas:aCols[Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols)),FG_POSVAR("VS3_DTVALI","aHeaderP")]:= aSaldos[i,7]
						MsUnLock()

						lPPrepec := .f.  // Controla se sera executada a funcao OX001PREPEC
						__ReadVar := 'M->VS3_QTDITE'
						M->VS3_QTDITE := oGetPecas:aCols[Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols)),nVS3QTDITE]
						oGetPecas:nAt := Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols))
						OX001PREPEC()
						RecLock("VS3",.f.)
						VS3->VS3_QTDINI := M->VS3_QTDITE
						VS3->VS3_VALTOT := M->VS3_VALTOT
						VS3->VS3_SEQUEN := M->VS3_SEQUEN
						VS3->VS3_PERDES := M->VS3_PERDES
						VS3->VS3_VALPEC := M->VS3_VALPEC
						VS3->VS3_VALDES := M->VS3_VALDES
						if nVS3VALPIS > 0
							VS3->VS3_VALPIS := M->VS3_VALPIS
						endif
						if nVS3VALCOF > 0
							VS3->VS3_VALCOF := M->VS3_VALCOF
						endif
						if nVS3ICMCAL > 0
							VS3->VS3_ICMCAL := M->VS3_ICMCAL
						endif
						if nVS3MARLUC > 0
							VS3->VS3_MARLUC := M->VS3_MARLUC
						endif
						if nVS3VALCMP > 0
							VS3->VS3_VALCMP := M->VS3_VALCMP
						endif
						if nVS3DIFAL > 0
							VS3->VS3_DIFAL := M->VS3_DIFAL
						endif
						MsUnLock()
						If Len(aVetSeq) > 0 .and. aScan(aVetSeq,{ |x| x == VS3->VS3_SEQUEN } ) == 0
							aAdd(aVetSeq,VS3->VS3_SEQUEN)
						EndIf
					Else
						lAtuFis := .t.
						nSaldoLote := (VS3->VS3_QTDITE - aSaldos[i,5])
						RecLock("VS3",.f.)
						VS3->VS3_QTDITE := aSaldos[i,5]
						VS3->VS3_LOTECT := aSaldos[i,1]
						VS3->VS3_NUMLOT := aSaldos[i,2]
						VS3->VS3_DTVALI := aSaldos[i,7]
						VS3->VS3_QTDAGU := 0
						VS3->VS3_QTDTRA := 0
						oGetPecas:aCols[Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols)),nVS3QTDITE]:= aSaldos[i,5]
						oGetPecas:aCols[Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols)),nVS3LOTECT]:= aSaldos[i,1]
						oGetPecas:aCols[Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols)),nVS3NUMLOT]:= aSaldos[i,2]
						oGetPecas:aCols[Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols)),FG_POSVAR("VS3_DTVALI","aHeaderP")]:= aSaldos[i,7]
						MsUnLock()

						lPPrepec := .t.  // Controla se sera executada a funcao OX001PREPEC
						__ReadVar := 'M->VS3_QTDITE'
						M->VS3_QTDITE := oGetPecas:aCols[Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols)),nVS3QTDITE]
						oGetPecas:nAt := Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols))
						OX001PREPEC(,.t.)
						RecLock("VS3",.f.)
						VS3->VS3_QTDINI := M->VS3_QTDITE
						VS3->VS3_SEQUEN := M->VS3_SEQUEN
						VS3->VS3_PERDES := M->VS3_PERDES
						VS3->VS3_VALPEC := M->VS3_VALPEC
						VS3->VS3_VALDES := M->VS3_VALDES
						VS3->VS3_VALTOT := M->VS3_VALTOT
						if nVS3VALPIS > 0
							VS3->VS3_VALPIS := M->VS3_VALPIS
						endif
						if nVS3VALCOF > 0
							VS3->VS3_VALCOF := M->VS3_VALCOF
						endif
						if nVS3ICMCAL > 0
							VS3->VS3_ICMCAL := M->VS3_ICMCAL
						endif
						if nVS3MARLUC > 0
							VS3->VS3_MARLUC := M->VS3_MARLUC
						endif
						if nVS3VALCMP > 0
							VS3->VS3_VALCMP := M->VS3_VALCMP
						endif
						if nVS3DIFAL > 0
							VS3->VS3_DIFAL := M->VS3_DIFAL
						endif
						MsUnLock()
						If Len(aVetSeq) > 0 .and. aScan(aVetSeq,{ |x| x == VS3->VS3_SEQUEN } ) == 0
							aAdd(aVetSeq,VS3->VS3_SEQUEN)
						EndIf
						OX001CriRLt(nSaldoLote,nPosAcolsLt)
						aAdd(aVetRecLt,VS3->(Recno()))
					Endif
				Next
				If lAtuFis
					lPPrepec := .t.  // Controla se sera executada a funcao OX001PREPEC
					__ReadVar := 'M->VS3_QTDITE'
					M->VS3_QTDITE := oGetPecas:aCols[Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols)),nVS3QTDITE]
					oGetPecas:nAt := Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols))
					OX001PREPEC(,.t.)
					RecLock("VS3",.f.)
					VS3->VS3_QTDINI := M->VS3_QTDITE
					VS3->VS3_SEQUEN := M->VS3_SEQUEN
					VS3->VS3_PERDES := M->VS3_PERDES
					VS3->VS3_VALPEC := M->VS3_VALPEC
					VS3->VS3_VALDES := M->VS3_VALDES
					VS3->VS3_VALTOT := M->VS3_VALTOT
					if nVS3VALPIS > 0
						VS3->VS3_VALPIS := M->VS3_VALPIS
					endif
					if nVS3VALCOF > 0
						VS3->VS3_VALCOF := M->VS3_VALCOF
					endif
					if nVS3ICMCAL > 0
						VS3->VS3_ICMCAL := M->VS3_ICMCAL
					endif
					if nVS3MARLUC > 0
						VS3->VS3_MARLUC := M->VS3_MARLUC
					endif
					if nVS3VALCMP > 0
						VS3->VS3_VALCMP := M->VS3_VALCMP
					endif
					if nVS3DIFAL > 0
						VS3->VS3_DIFAL := M->VS3_DIFAL
					endif
					MsUnlock()
				Endif
				//
				RecLock("VS3",.f.)
				VS3->VS3_QTDAGU := nSlvQtdAgu
				VS3->VS3_QTDTRA := nSlvQtdTra
				VS3->VS3_VALTOT := (VS3->VS3_VALPEC-(VS3->VS3_VALDES/VS3->VS3_QTDITE))*VS3->VS3_QTDITE
				MsUnLock()
				//
				oGetPecas:oBrowse:refresh()
				//
			Else
				if Empty(VS3->VS3_DTVALI)
					RecLock("VS3",.f.)
					VS3->VS3_DTVALI := oPeca:LoteDtValid(VS3->VS3_LOTECT)
					MsUnlock()
					oGetPecas:aCols[Iif(i==1,nPosAcolsLt,Len(oGetPecas:aCols)),FG_POSVAR("VS3_DTVALI","aHeaderP")]:= VS3->VS3_DTVALI
				Endif
			Endif
			VS3->(DbGoto(nRecLote))
		EndIf
		VS3->(DbSkip())
	EndDo
EndIf

DBSelectArea("VS3")
DBSetOrder(1)
DBSeek(xFilial("VS3")+ cNumOrc)
while !eof() .and. xFilial("VS3") + cNumOrc == VS3->VS3_FILIAL + VS3->VS3_NUMORC
	//
	If lCtrlLote .and. !lRes
		If VS1->VS1_STARES == "3" .or. ( VS1->VS1_STARES == "2" .and. (aScan(aVetSeq,{ |x| x == VS3->VS3_SEQUEN } ) == 0 .and. aScan(aVetSeq,{ |x| x == "9999" } ) == 0) )
			DbSelectArea("VS3")
			DBSkip()
			loop
		EndIf
	EndIf

	if VS3->VS3_QTDITE == 0 .and. aScan(aVetSeq,VS3->VS3_SEQUEN) == 0
		DbSelectArea("VS3")
		DBSkip()
		loop
	endif

	If VS3->VS3_TRSFER <> "1"
		SF4->(dbSeek(xFilial("SF4")+VS3->VS3_CODTES))
		if SF4->F4_ESTOQUE != "S"
			DbSelectArea("VS3")
			DBSkip()
			loop
		endif
	endif
	
	if Exclui
		if Empty(VS3->VS3_DOCSDB)
			DbSelectArea("VS3")
			DBSkip()
			loop
		Endif
	Endif
	if Len(aVetSeq) > 0
		if lRes == .t.
			if aScan(aVetSeq,{ |x| x == VS3->VS3_SEQUEN } ) == 0
				DBSelectArea("VS3")
				DBSkip()
				loop
			endif
		else
			if aVetSeq[1] == "9999"
				if Alltrim(VS3->VS3_RESERV) != "1" .and. !lObrRes
					DBSelectArea("VS3")
					DBSkip()
					loop
				endif
			else
				if aScan(aVetSeq,{ |x| x == VS3->VS3_SEQUEN } ) == 0 .and. !lObrRes
					DBSelectArea("VS3")
					DBSkip()
					loop
				endif
			endif
		endif
	endif
	if lRes == .t.
		if VS3->VS3_RESERV == "1" .and. Len(aVetSeq) == 0
			DBSelectArea("VS3")
			DBSkip()
			loop
		endif
	endif
	//
	DbSelectArea("SB1")
	DbSetOrder(7)
	DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE)
	DbSetOrder(1)
	//
	DbSelectArea("SB5")
	DbSetOrder(1)
	DbSeek( xFilial("SB5") + SB1->B1_COD )
	//
	// sequencia
	// produto, descricao, unidade de medida, local/localizacao origem
	// produto, descricao, unidade de medida, local/localizacao destino
	// numero de serie, lote, sublote, data de validade, qunatidade
	// quantidade na 2 unidade, estorno, numero de sequencia
	If Exclui .and. Localiza(SB1->B1_COD)
		cLocalDis := GetMv( "MV_RESITE" )+Space(TamSx3("B2_LOCAL")[1]-Len(GetMv("MV_RESITE")))
		cLocalRes := VS3->VS3_LOCAL
	Else
		cLocalDis := VS3->VS3_LOCAL
		cLocalRes := GetMv( "MV_RESITE" )+Space(TamSx3("B2_LOCAL")[1]-Len(GetMv("MV_RESITE")))
	Endif
	//
	// 07/01/2014 - Manoel/Andre/Otavio - Quando é feito o cancelamento de um Orçamento ainda não Faturado e sem localizacão
	If !Localiza(SB1->B1_COD) .and. !lRes
		if Exclui
			lCanc := .t.
		Endif
		Exclui := .f.
	Endif
	//
	cLote    := ""
	cNumLote := ""
	if !Empty(VS3->VS3_LOTECT)
		cLote    := VS3->VS3_LOTECT
		cNumLote := VS3->VS3_NUMLOT
	Else
		If lCtrlLote .and. Rastro( SB1->B1_COD )
			DBSelectArea("VS3")
			DBSkip()
			loop
		endif
	endif
	if !Empty(VS3->VS3_LOCALI)
		If lVerConf .and. VS3->VS3_QTDCON <= VS3->VS3_QTDITE
			aVetLocPec  := {{VS3->VS3_LOCALI,VS3->VS3_QTDCON}}
		Else
			If lCtrlLote .and. Rastro( SB1->B1_COD )
				aVetLocPec  := {{VS3->VS3_LOCALI,VS3->VS3_QTDITE}}
			Else
				aVetLocPec  := {{VS3->VS3_LOCALI,VS3->VS3_QTDITE- VS3->VS3_QTDAGU+VS3->VS3_QTDTRA }}
			Endif
		Endif
	else
		If lVerConf .and. VS3->VS3_QTDCON <= VS3->VS3_QTDITE
			aVetLocPec := OX001PRAUTLC(SB1->B1_COD,IIf(lRes.or.(Exclui.and. Len(aVetSeq) == 0),cLocalDis,cLocalRes),VS3->VS3_QTDCON,cLote,cNumLote)  // Funcao de Priorizacao Automatica das Localizacoes
		Else
			aVetLocPec := OX001PRAUTLC(SB1->B1_COD,IIf(lRes.or.(Exclui.and. Len(aVetSeq) == 0),cLocalDis,cLocalRes),VS3->VS3_QTDITE-VS3->VS3_QTDAGU+VS3->VS3_QTDTRA,cLote,cNumLote)  // Funcao de Priorizacao Automatica das Localizacoes
		Endif
		If Len(aVetLocPec) == 1 .and. aVetLocPec[1,1] == "" .and. aVetLocPec[1,2] == 0
			If lVerConf .and. VS3->VS3_QTDCON <= VS3->VS3_QTDITE
				aVetLocPec  := {{"",VS3->VS3_QTDCON}}
			Else
				If lCtrlLote .and. Rastro( SB1->B1_COD )
					aVetLocPec  := {{"",VS3->VS3_QTDITE}}
				Else
					aVetLocPec  := {{"",VS3->VS3_QTDITE-VS3->VS3_QTDAGU+VS3->VS3_QTDTRA}}
				Endif
			Endif
		Endif

	endif
	//
	nQtAtend := 0
	for iVLP := 1 to Len(aVetLocPec)
		nQtAtend += aVetLocPec[iVLP,2]
	Next
	If lVerConf .and. VS3->VS3_QTDCON <= VS3->VS3_QTDITE
		If VS3->VS3_QTDCON > nQtAtend
			reclock("VS3",.f.)
			VS3->VS3_RESERV := "1"
			msunlock()
			MsgStop(STR0238+CHR(13)+CHR(10)+VS3->VS3_GRUITE+" "+VS3->VS3_CODITE,STR0025) // "Quantidade insuficiente para atender solicitação!"
			Return ""
		Endif
	Else
		If VS3->VS3_QTDITE-VS3->VS3_QTDAGU+VS3->VS3_QTDTRA > nQtAtend
			reclock("VS3",.f.)
			VS3->VS3_RESERV := "1"
			msunlock()
			MsgStop(STR0238+CHR(13)+CHR(10)+VS3->VS3_GRUITE+" "+VS3->VS3_CODITE,STR0025) // "Quantidade insuficiente para atender solicitação!"
			Return ""
		Endif
	Endif
	for iVLP := 1 to Len(aVetLocPec)

		If lRes.or.Exclui
			cLocalizDis := aVetLocPec[iVLP,1]
		Else
			cLocalizDis := FM_SQL("SELECT SDB.DB_LOCALIZ FROM "+RetSQLName("SDB")+" SDB WHERE SDB.DB_FILIAL='"+xFilial("SDB")+"' AND SDB.DB_PRODUTO ='"+SB1->B1_COD+"' AND SDB.DB_LOCAL ='"+VS3->VS3_LOCAL+"' AND SDB.DB_DOC ='"+VS3->VS3_DOCSDB+"' AND SDB.D_E_L_E_T_=' '")
		Endif
		If Localiza(SB1->B1_COD)
			cLocalizRes := padr( GetMv( "MV_RESLOC" ) , TamSx3("B5_LOCALI2")[1] )
		Else
			cLocalizRes := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
		EndIf
		If Empty(cLocalizRes)
			cQuery := "SELECT SBF.BF_LOCALIZ FROM "+RetSqlName("SBF")+" SBF WHERE SBF.BF_FILIAL = '"+xFilial("SBF")+"' AND "
			cQuery += "SBF.BF_PRODUTO = '"+SB1->B1_COD+"' AND SBF.BF_LOCAL = '"+VS3->VS3_LOCAL+"' AND SBF.BF_QUANT > 0 AND "
			If !Empty(cLote)
				cQuery += "SBF.BF_LOTECTL = '"+cLote+"' AND "
			Endif
			If !Empty(cNumLote)
				cQuery += "SBF.BF_NUMLOTE = '"+cNumLote+"' AND "
			Endif
			cQuery += "SBF.D_E_L_E_T_=' ' ORDER BY SBF.BF_PRIOR"
			cLocalizRes := Alltrim(FM_SQL(cQuery))
		Endif

		IF ExistBlock("PERESITE") // Alterado por Manoel/Thiago pois no cliente Jaracatia estava sendo chamado o MATA261 2X (Alteração temporaria pois o Rubens esta revendo o processo de reserva)
			nVReserva := ExecBlock("PERESITE",.f.,.f.,{"OFIXX001"})
			nQtdLocPec  := aVetLocPec[iVLP,2] - If(lRes .or. lCanc,nVReserva,0)
		Else
			nQtdLocPec  := aVetLocPec[iVLP,2]
		Endif
		nQtdAgu := VS3->VS3_QTDAGU+VS3->VS3_QTDTRA

		If Exclui .and. Localiza(SB1->B1_COD)

			lRes := .f.
			cQuery := "SELECT SDB.DB_LOCAL, SDB.DB_LOCALIZ, SDB.DB_QUANT,SDB.DB_NUMSEQ, SDB.DB_TM FROM "+RetSqlName("SDB")+" SDB WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"' AND "
			cQuery += "SDB.DB_PRODUTO = '"+SB1->B1_COD+"' AND SDB.DB_DOC = '"+VS3->VS3_DOCSDB+"' AND SDB.DB_QUANT > 0 AND "
			cQuery += "SDB.D_E_L_E_T_ = ' ' ORDER BY SDB.R_E_C_N_O_ "

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
			nNumLeitura := 0
			Do While !( cQAlias )->( Eof() )

				If ( cQAlias )->( DB_TM ) < "500"
					cLocalDis := ( cQAlias )->( DB_LOCAL )
					cLocalizDis := ( cQAlias )->( DB_LOCALIZ )
				Else 
					cLocalRes := ( cQAlias )->( DB_LOCAL )
					cLocalizRes := "" // ( cQAlias )->( DB_LOCALIZ ) // Necessario Enderecar novamente se estiver Cancelando (EXCLUI)
				Endif

				nNumLeitura++
				If nNumLeitura <> 1
					nNumLeitura := 0
				Endif

				If nNumLeitura == 0
					if (lVerConf .and. VS3->VS3_QTDCON > 0 .and. VS3->VS3_QTDCON <= VS3->VS3_QTDITE) .or. (!lVerConf .and. VS3->VS3_QTDITE-nQtdAgu > 0)
						
						cArmOri := IIf(lRes.or.(Exclui.and. Len(aVetSeq) == 0),cLocalDis,cLocalRes)
						cLocOri := IIf(lRes.or.(Exclui.and. Len(aVetSeq) == 0),cLocalizDis,cLocalizRes)
						
						cArmDes := IIf(lRes.or.(Exclui.and. Len(aVetSeq) == 0),cLocalRes,cLocalDis)
						cLocDes := IIf(lRes.or.(Exclui.and. Len(aVetSeq) == 0),cLocalizRes,cLocalizDis)
						
						aItemMov := oEst:SetItemSD3(SB1->B1_COD               ,; //Código do Produto
													cArmOri                   ,; // Armazém de Origem
													cArmDes                   ,; // Armazém de Destino
													cLocOri                   ,; // Localização Origem
													cLocDes                   ,; // Localização Destino
													( cQAlias )->( DB_QUANT ) ,; // Qtd a transferir
													VS3->VS3_LOTECT           ,; // Nro de lote
													VS3->VS3_NUMLOT           ,; // Nro de Sub-Lote
																	          ,; // Nro de Série
													VS3->VS3_DTVALI )            // Data Validade Lote

						aAdd(aItensNew, aClone(aItemMov))

						aadd(aRecVS3,VS3->(Recno()))

						//POSICAO 12 - lotectl
						//POSICAO 13 - numlot
						If ( ExistBlock("OX001ARS") )
							aAuxItens := ExecBlock("OX001ARS",.F.,.F.,{aClone(aItensNew)})
							If ( ValType(aAuxItens) == "A" )
								aItensNew := aClone(aAuxItens)
							EndIf
						EndIf
					EndIf
				Endif
				( cQAlias )->( DbSkip() )
			Enddo
			( cQAlias )->( DbCloseArea() )

		Else

			if ((lVerConf .and. VS3->VS3_QTDCON > 0 .and. VS3->VS3_QTDCON <= VS3->VS3_QTDITE) .or. (!lVerConf .and. VS3->VS3_QTDITE-nQtdAgu > 0) .or. Len(aVetSeq) > 0) .AND. Nqtdlocpec > 0

				cArmOri := IIf(lRes.or.(Exclui.and. Len(aVetSeq) == 0),cLocalDis,cLocalRes)
				cLocOri := IIf(lRes.or.(Exclui.and. Len(aVetSeq) == 0),cLocalizDis,cLocalizRes)
				
				cArmDes := IIf(lRes.or.(Exclui.and. Len(aVetSeq) == 0),cLocalRes,cLocalDis)
				cLocDes := IIf(lRes.or.(Exclui.and. Len(aVetSeq) == 0),cLocalizRes,cLocalizDis)

				aItemMov := oEst:SetItemSD3(SB1->B1_COD     ,; //Código do Produto
											cArmOri         ,; // Armazém de Origem
											cArmDes         ,; // Armazém de Destino
											cLocOri         ,; // Localização Origem
											cLocDes         ,; // Localização Destino
											nQtdLocPec      ,; // Qtd a transferir
											VS3->VS3_LOTECT ,; // Nro de lote
											VS3->VS3_NUMLOT ,; // Nro de Sub-Lote
											                ,; // Nro de Série
											VS3->VS3_DTVALI )  // Data Validade Lote

				aAdd(aItensNew, aClone(aItemMov))

			    aadd(aRecVS3,VS3->(Recno()))
				//POSICAO 12 - lotectl
				//POSICAO 13 - numlot
				If ( ExistBlock("OX001ARS") )
					aAuxItens := ExecBlock("OX001ARS",.F.,.F.,{aClone(aItensNew)})
					If ( ValType(aAuxItens) == "A" )
						aItensNew := aClone(aAuxItens)
					EndIf
				EndIf
			Endif

		endif

	Next

	DBSelectArea("VS3")
	DBSkip()

enddo
//
SB1->(DBSetOrder(1))
//

If (ExistBlock("OX001AP"))
	aItensNew := ExecBlock("OX001AP", .f., .f., {aItensNew})
EndIf

if Len(aItensNew) > 1

	lMSErroAuto := .f.
	MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3)

	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
		if Type("lOX001Auto") == "U" .or. !lOX001Auto
			For i := 2 to Len(aItensNew)
				if OX001SLDPC(xFilial("SB2")+aItensNew[i,1]+aItensNew[i,4], .f.) < aItensNew[i,16]
					MsgStop(	STR0188 + CHR(10)+CHR(13)+;
						STR0189 +aItensNew[i,1]+" / "+aItensNew[i,4]+" / "+aItensNew[i,5] + CHR(10)+CHR(13)+ ;
						STR0190 +aItensNew[i,6]+" / "+aItensNew[i,9]+" / "+aItensNew[i,10] + CHR(10)+CHR(13)+;
						STR0191 +Transform(aItensNew[i,16],"@E999999"),STR0025)
				Endif
			Next
		endif
		return ""

	Else

		If Exclui  .or. lCanc
			// Limpa VS3_DOCSDB
			DBSelectArea("VS3")
			For i := 1 to Len(aRecVS3)

				VS3->(Dbgoto(aRECVS3[i]))
				Reclock("VS3",.f.)
				VS3->VS3_DOCSDB := Space(Len(VS3_DOCSDB))
				MsUnlock()
				// Gravacao do VE6
				OX001VE6(cNumOrc,lRes) // RESERVA / DESRESERVA DO ITEM
				//
			Next

		ElseIf Funname() $ "OFIXA015.OFIXA013.OFIXA016.OFIXA019.OFIOM430.OFIXA021" .or. lRejLib
			DBSelectArea("VS3")
			For i := 1 to Len(aRecVS3)

				VS3->(Dbgoto(aRECVS3[i]))
				Reclock("VS3",.f.)
				VS3->VS3_DOCSDB := cDocumento
				MsUnlock()
				// Gravacao do VE6
				OX001VE6(cNumOrc,lRes) // RESERVA / DESRESERVA DO ITEM
				//
			Next
		Else
			// Atualiza VS3_DOCSDB
			nGruIte :=	nVS3GRUITE
			nCodIte :=	nVS3CODITE
			nDOCSDB :=	FG_POSVAR("VS3_DOCSDB","aHeaderP")
			nPosDel :=	len(aHeaderP)+1
			DBSelectArea("VS3")
			For i := 1 to Len(aRecVS3)

				VS3->(Dbgoto(aRECVS3[i]))
				Reclock("VS3",.f.)
				VS3->VS3_DOCSDB := cDocumento
				MsUnlock()
				if Type("oGetPecas:aCols") == "A"
					nAchou := aScan( oGetPecas:aCols,{ |x| x[nGruIte]+x[nCodIte] == VS3->VS3_GRUITE+VS3->VS3_CODITE .and. x[nPosDel]==.F. })
					if nAchou > 0
						oGetPecas:aCols[nAchou,nDOCSDB] := cDocumento
					Endif
				EndIf
				// Gravacao do VE6
				OX001VE6(cNumOrc,lRes) // RESERVA / DESRESERVA DO ITEM
				//
			Next
			if Type("oGetPecas:aCols") == "A"
				oGetPecas:oBrowse:refresh()
			EndIf
		Endif
		// -----------------------------------------------
		// Gravação do STATUS DA RESERVA no VS1 (VS1_STARES)
		// -----------------------------------------------
		lTemResS := .f.
		lNTemRes := .f.
		lResTotal := .f.
		DBSelectArea("VS3")
		DBSetOrder(1)
		DBSeek(xFilial("VS3")+ cNumOrc)
		//
		while !eof() .and. xFilial("VS3") + cNumOrc == VS3->VS3_FILIAL + VS3->VS3_NUMORC
			if 	Alltrim(VS3->VS3_RESERV) == "1"
				lTemResS := .t.
			else
				lNTemRes := .t.
			endif
			DBSkip()
		enddo
		//
		if Len(aVetSeq) == 0
			lResTotal := .t.
		endif
		//
		DBSelectArea("VS1")
		reclock("VS1",.f.)
		if (lResTotal .and. lRes) .or. lNTemRes == .f.
			VS1->VS1_STARES := "1"
		elseif lTemResS
			VS1->VS1_STARES := "2"
		else
			VS1->VS1_STARES := "3"
		endif
		msunlock()
		// -----------------------------------------------
		// Fim da Gravação do STATUS DA RESERVA no VS1 (VS1_STARES)
		// -----------------------------------------------
	EndIf
else
	return "NA"
endif
//


return cDocumento
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001IMPR   | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Imprime o orcamento                                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001IMPR(nOpc)
Local lImprime := .t.
if nOpc <> 2
	lImprime := OX001GRV(nOpc,.f.,.t.,,.t.)
endif
if lImprime
	if ExistBlock("ORCAMTO")
		ExecBlock("ORCAMTO",.f.,.f.,{VS1->VS1_NUMORC})
	Endif
else
	return .f.
endif
//
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001CONCLI | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Funcao de chamada da ficha do cliente (FINC010)              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001CONCLI()
Local lSetKey := ExistFunc("OFISetKey")
Local oSetKey := nil

If lSetKey
	oSetKey := OFISetKey():New()
EndIf

If !Empty(M->VS1_CLIFAT)
	DBSelectArea("SA1")
	DBSetOrder(1)
	If DBSeek(xFilial("SA1") + M->VS1_CLIFAT + M->VS1_LOJA)
		// Backup das teclas de atalho
		If lSetKey
			oSetKey:Backup()
		EndIf

		Pergunte("FIC010", .t.)
		Fc010Con("SA1", RecNo(), 2)

		// Restaurar as teclas de atalho
		If lSetKey
			oSetKey:Restore()
		EndIf

		Return
	EndIf
EndIf

MsgInfo(STR0122,STR0025)
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001VENPER | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Funcao que faz a chamada da rotina de venda perdida          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001VENPER(xGru,xCod,xQtd)
Local aCpoVP := {{"VE6_INDREG","1"}}
Local xValPec := 0
Local xFormul := ""
Default xGru := ""
Default xCod := ""
Default xQtd := 0
//
//
if ( FWIsInCallStack("OFIXA011") .or. FWIsInCallStack("OFIXA018") ) .and. !FWIsInCallStack("OFIXC001")
	//
	if  VISUALIZA
		return .f.
	endif
	//
	if oGetPecas:nAt > 0 .and. oGetPecas:nAt <= Len(oGetPecas:aCols)
		If Empty(xGru+xCod) .and. xQtd <= 0
			xGru    := oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]
			xCod    := oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE]
			xQtd    := oGetPecas:aCols[oGetPecas:nAt,nVS3QTDITE]
			xValPec := oGetPecas:aCols[oGetPecas:nAt,nVS3VALPEC]
			xFormul := oGetPecas:aCols[oGetPecas:nAt,nVS3FORMUL]
		EndIf
		aAdd(aCpoVP,{"VE6_CODIGO",M->VS1_CODVEN})
		aAdd(aCpoVP,{"VE6_NUMORC",M->VS1_NUMORC})
	endif
	//
else
	If Empty(xGru)
		xGru := cGruIte
	EndIf
	If Empty(xCod)
		xCod := cCodIte
	EndIf
	VAI->(DBSetOrder(4))
	VAI->(DBSeek(xFilial("VAI")+__cUserId))
	aAdd(aCpoVP,{"VE6_CODIGO",VAI->VAI_CODVEN})
endif
If xValPec > 0
	aAdd(aCpoVP,{"VE6_VALPEC",xValPec})
EndIf
If !Empty(xGru)
	SBM->(DbSetOrder(1))
	SBM->(DBSeek(xFilial("SBM")+xGru))
	aAdd(aCpoVP,{"VE6_CODMAR",SBM->BM_CODMAR})
	aAdd(aCpoVP,{"VE6_GRUITE",xGru})
EndIf
If !Empty(xCod)
	aAdd(aCpoVP,{"VE6_CODITE",xCod})
EndIf
If xQtd > 0
	aAdd(aCpoVP,{"VE6_QTDITE",xQtd})
EndIf
If !Empty(xFormul)
	aAdd(aCpoVP,{"VE6_FORMUL",xFormul})
EndIf
OFMI900("VE6",0,3,aCpoVP,.t.,.f.,OemToAnsi(STR0123))
//
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001VENPER | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Funcao que faz a chamada da rotina de registro de abordagem  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001REGABO()
ML500A()
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001RECALC | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Funcao que faz a chamada da rotina de recalculo do orcamento |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
static Function OX001RECALC(nOpc,lCalcSemGrv)
Local nCntFor, nCntFor2

Local nAuxnATPec := IIF( Len(oGetPecas:aCols) > 0 , oGetPecas:nAt , 0 )

Local aVO6Area
Local aVOKArea

Default lCalcSemGrv := .t.

if VISUALIZA .or. nAuxnATPec == 0
	Return
endif

if M->VS1_STATUS <> "0"
	FMX_HELP("OX001ERR006",STR0408) // "Função de recálculo só pode ser executada para orçamentos com status Digitado."
	return
endif

if lCalcSemGrv .or. OX001GRV(nOpc,.f.,.t.,,.f.)

	ProcRegua( 0 )

	IncProc("")

	// recalcula pecas
	aItensKit := { " " }
	//
	OX001RefNF()
	//
	for nCntFor := 1 to Len(oGetPecas:aCols)

		if ! oGetPecas:aCols[nCntFor,Len(oGetPecas:aCols[nCntFor])]

			oGetPecas:nAt := nCntFor

			M->VS3_OPER := oGetPecas:aCols[oGetPecas:nAt,nVS3OPER]
			if !empty(M->VS3_OPER)
				SFM->(DBSetOrder(1))
				SFM->(msSeek(xFilial("SFM")+M->VS3_OPER))

				SB1->(DbSelectArea("SB1"))
				SB1->(DbSetOrder(7))
				SB1->(DbSeek(xFilial("SB1")+oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]+oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE]))

				M->VS3_CODTES := OX001TESINT(M->VS3_OPER)
				oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES] := M->VS3_CODTES
			endif

			//
			aVetCmp := {}
			aAdd(aVetCmp,{"VS3_GRUITE",oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] } )
			aAdd(aVetCmp,{"VS3_CODITE",oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] } )
			aAdd(aVetCmp,{"VS3_CODTES",oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES] } )
			aAdd(aVetCmp,{"VS3_QTDITE",oGetPecas:aCols[oGetPecas:nAt,nVS3QTDITE] } )
			aAdd(aVetCmp,{"VS3_LOCAL", oGetPecas:aCols[oGetPecas:nAt,nVS3LOCAL ] } )
			aAdd(aVetCmp,{"VS3_FORMUL", oGetPecas:aCols[oGetPecas:nAt,nVS3FORMUL] } )

			FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt, .f.)

			OX001PecFis()
			// faz o laço para cada item, preenchendo os valores e chamando o FieldOk
			for nCntFor2 := 1 to Len(aVetCmp)
				oGetPecas:nAt := nCntFor
				&("M->"+aVetCmp[nCntFor2,1] ) := aVetCmp[nCntFor2,2]
				__ReadVar := "M->"+aVetCmp[nCntFor2,1]
				OX001FPOK(.f.,,.f.,.t.)
			next
		endif
	next

	// Atualiza Browse
	oGetPecas:nAt := nAuxnATPec
	OX001FisPec()
	FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt, .f.)




	oGetPecas:oBrowse:refresh()
	//
	aItensKit := {}

	// recalcula servicos
	if (M->VS1_TIPORC == "2")

		aVO6Area := VO6->(GetArea())
		aVOKArea := VOK->(GetArea())

		for nCntFor := 1 to Len(oGetServ:aCols)
			if !oGetServ:aCols[nCntFor,Len(oGetServ:aCols[nCntFor])]
				oGetServ:nAt := nCntFor
				//
				// faz o laço para cada item, preenchendo os valores e chamando o FieldOk
				For nCntFor2 := 1 to Len(aHeaderS)
					&("M->"+aHeaderS[nCntFor2,2]) := oGetServ:aCols[nCntFor,nCntFor2]
				next

				VOK->(dbSetOrder(1))
				VOK->(MsSeek(xFilial("VOK") + M->VS4_TIPSER ))

				VO6->(dbSetOrder(3))
				VO6->(DBSeek(xFilial("VO6") + FG_MARSRV(VV1->VV1_CODMAR, M->VS4_CODSER) + M->VS4_GRUSER + M->VS4_CODSER))

				aVetCmp := {}
				aAdd(aVetCmp,{"VS4_TIPSER",M->VS4_TIPSER})
				aAdd(aVetCmp,{"VS4_CODSER",M->VS4_CODSER})
				aAdd(aVetCmp,{"VS4_GRUSER",M->VS4_GRUSER})
				aAdd(aVetCmp,{"VS4_VALHOR",M->VS4_VALHOR})
				Do Case 
					// Tipo de Cobranca -> 2 = Srv de Terceiro
					Case VOK->VOK_INCMOB == "2"
						aAdd(aVetCmp,{"VS4_VALVEN",M->VS4_VALVEN})

					// Tipo de Cobranca -> 5 = Km Socorro
					Case VOK->VOK_INCMOB == "5"
						aAdd(aVetCmp,{"VS4_KILROD",M->VS4_KILROD})
					
					OtherWise
						aAdd(aVetCmp,{"VS4_TEMPAD",M->VS4_TEMPAD})
				EndCase
				aAdd(aVetCmp,{"VS4_VALDES",M->VS4_VALDES})

				oGetServ:nAt := nCntFor
				for nCntFor2 := 1 to Len(aVetCmp)
					OX001SrvFis()
					&("M->"+aVetCmp[nCntFor2,1] ) := aVetCmp[nCntFor2,2]
					__ReadVar := "M->"+aVetCmp[nCntFor2,1]
					OX001FSOK()
					OX001FisSrv()
				next
				oGetServ:oBrowse:refresh()
			endif
		next

		RestArea(aVO6Area)
		RestArea(aVOKArea)

	endif

	OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
endif
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001AVARES | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Funcao que faz a chamada da rotina de avaliacao de resultado |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001AVARES(nOpc)
Private cArqTrb
Private cArqPes
Private cCodMap
Private cOutMoed
Private cSimOMoe
Private aVetVal := {}
Private aStru   := {}
Private cParPro := "1"
Private cNumero := VS1->VS1_NUMORC
Private cContChv:= "VEC_NUMORC"
Private cParTem := ""
Private lCalcTot:= .f.
Private cCpoDiv := "    1"
Private cSimVda   := "P"  // Pecas
Private cTipAva   := "2"  // Pecas
Private aErrAva   := {}   //Array de formulas incorretas (Compatibilidade com Erro na VEIFUNC)

//
if !VISUALIZA .and. !EXCLUI
	if !OX001GRV(nOpc,.f.,.t.,,.f.)
		return .f.
	endif
endif
//
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VEC")
Do While !EOF() .and. x3_arquivo == "VEC"
	aadd(aVetVal,{x3_campo,x3_tipo,x3_tamanho,x3_decimal})
	dbSkip()
EndDo

aAltSx1  := { {"02","","","","","",GETMV("MV_SIMB1"),GETMV("MV_SIMB2"),GETMV("MV_SIMB3"),GETMV("MV_SIMB4"),GETMV("MV_SIMB5"),"","","","",""} }
FG_AltSx1("ATDCLI","A",aAltSx1)

if !PERGUNTE("ATDCLI")
	Return
Endif

cCodMap  := Mv_Par01
cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))

dbSelectArea("VEC")
oObjTempTable := OFDMSTempTable():New()
oObjTempTable:cAlias := "TRB"
oObjTempTable:aVetCampos := aVetVal
oObjTempTable:AddIndex(, {"VEC_FILIAL","VEC_NUMOSV"} )
oObjTempTable:CreateTable()

MSGRUN(oemtoansi(STR0125),"",{||CursorWait(),FS_AVRES2(),CursorArrow()})//

FG_RESAVA(cOutMoed,3,"P","","OFIXX001")

oObjTempTable:CloseTable()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_AVRES2 ³Ricardo Farinelli           | Data ³  31/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Complemento da funcao de visualizacao do mapa de resultado  º±±
±±º          ³com a MSGRUN para dar um status ao usuario                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Gestao de Concessionarias                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AVRES2()
Local ix_:=0
Local ii := 0
Local cLocalP := ""
Local cNumREL := ""
Local cNumIDE := ""

cCodVen := VS1->VS1_CODVEN
nTotOrc := VS1->VS1_VTOTNF
nTotDes := VS1->VS1_VALDES

OX0010123_FGPosVar_VS3()

dbSelectArea("TRB")
dbSetOrder(1)

For ix_:=1 to Len(oGetPecas:aCols)
	oGetPecas:nAt := ix_
	if Type("cOpeMov2") == "U"
		cOpeMov2 := VS1->VS1_NOROUT
	Endif

	if oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])]
		Loop
	Endif

	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]+oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE])


	cLocalP := Iif(!Empty(oGetPecas:aCols[oGetPecas:nAt, nVS3LOCAL ]),oGetPecas:aCols[oGetPecas:nAt, nVS3LOCAL ],OX0010105_ArmazemOrigem())
	dbSelectArea("SB2")
	dbSeek(xFilial("SB2")+SB1->B1_COD+cLocalP)

	dbSelectarea("SF4")
	SF4->(dbSeek(xFilial("SF4")+oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES]))

	If MaFisFound("NF")
		OX001PecFis()
		nValPis := MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
		nValCof := MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
		nValICM := MaFisRet(n,"IT_VALICM")
		nValIPI := MaFisRet(n,"IT_VALIPI")
		nValCmp := MaFisRet(n,"IT_VALCMP")
		nDifal  := MaFisRet(n,"IT_DIFAL")
		aLivroVEC := MaFisRet(n,"IT_LIVRO")
		nValICM := aLivroVEC[5]
		nBaseIcm := MaFisRet(n,"IT_BASEICM")
		nValIRR  := MaFisRet(n,"IT_VALIRR")
		nValCSL  := MaFisRet(n,"IT_VALCSL")
		OX001FisPec()
	Else
		nValPis  := oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_VALPIS","aHeaderP")]
		nValCof  := oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_VALCOF","aHeaderP")]
		nValICM  := oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_ICMCAL","aHeaderP")]
		nValIPI  := IIf(FG_POSVAR("VS3_VALIPI","aHeaderP") > 0,oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_VALIPI","aHeaderP")],0)
		nValCmp  := oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_VALCMP","aHeaderP")]
		nDifal   := oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_DIFAL","aHeaderP")]
		nBaseIcm := 0
		nValIRR  := 0
		nValCSL  := 0
	EndIf

	cNumREL := GetSXENum("VEC","VEC_NUMREL")
	ConfirmSx8()
	cNumIDE := GetSXENum("VEC","VEC_NUMIDE")
	ConfirmSx8()

	dbSelectArea("TRB")

	RecLock("TRB",.t.)

	VEC_FILIAL := xFilial("VEC")
	VEC_NUMORC := VS1->VS1_NUMORC
	VEC_NUMREL := cNumREL
	VEC_NUMIDE := cNumIDE
	VEC_GRUITE := oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]
	VEC_CODITE := oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE]
	VEC_VALVDA := oGetPecas:aCols[oGetPecas:nAt,nVS3VALTOT]
	VEC_VALDES := oGetPecas:aCols[oGetPecas:nAt,nVS3VALDES]
	VEC_QTDITE := oGetPecas:aCols[oGetPecas:nAt,nVS3QTDITE]
	VEC_VALICM := nValICM
	VEC_VALCOF := nValCof
	VEC_VALPIS := nValPis
	VEC_VALIPI := nValIPI
	VEC_TOTIMP := VEC_VALICM + VEC_VALCOF + VEC_VALPIS + VEC_DIFAL + VEC_VALCMP + VEC_VALIPI
	VEC_CUSMED := SB2->B2_CM1 * oGetPecas:aCols[oGetPecas:nAt,nVS3QTDITE]
	VEC_JUREST := 0
	VEC_CUSTOT := VEC_CUSMED + VEC_JUREST
	VEC_LUCBRU := VEC_VALVDA - VEC_TOTIMP - VEC_CUSMED
	VEC_DATVEN := dDataBase
	VEC_PECINT := SB1->B1_COD
	VEC_VALCMP := nValCmp
	VEC_DIFAL  := nDifal

	VEC_VALIRR := nValIRR
	VEC_VMFIRR := FG_CALCMF( { {dDataBase,VEC_VALIRR} })

	VEC_VALCSL := nValCSL
	VEC_VMFCSL := FG_CALCMF( { {dDataBase,VEC_VALCSL} })

	//Comissao
	if cOpeMov2 <> "2"
		aValCom    := FG_COMISS("P",cCodVen,VEC_DATVEN,VEC_GRUITE,VEC_VALVDA,"T",VEC_NUMIDE)
		VEC_COMVEN := aValCom[1]
		VEC_COMGER := aValCom[2]
	Else
		VEC_COMVEN := 0
		VEC_COMGER := 0
	Endif

	VEC_DESVAR := VEC_COMVEN + VEC_COMGER
	VEC_LUCLIQ := VEC_LUCBRU - VEC_JUREST - VEC_DESVAR - VEC_DESDEP - VEC_DESADM - VEC_DESFIX
	VEC_DESFIX := 0
	VEC_CUSFIX := 0
	VEC_DESDEP := 0
	VEC_DESADM := 0
	VEC_RESFIN := 0
	VEC_BALOFI := "B" //Balcao
	VEC_DEPVEN := ""
	VEC_TIPTEM := ""  //Gravar qdo Ordem de Servico
	VEC_NUMOSV := ""  //Gravar qdo Ordem de Servico
	VEC_RESFIN := VEC_LUCLIQ - VEC_CUSFIX
	VEC_NUMNFI := ""

	VEC_VALBRU := VEC_VALVDA + VEC_VALDES
	VEC_VMFBRU := FG_CALCMF( { {dDataBase,VEC_VALBRU} })
	VEC_VMFVDA := VEC_VMFBRU - FG_CALCMF( {{dDataBase,VEC_VALDES}} )
	VEC_VMFICM := FG_CALCMF( { {FG_RTDTIMP("ICM",dDataBase),VEC_VALICM} })
	VEC_VMFPIS := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC_VALPIS} })
	VEC_VMFCOF := FG_CALCMF( { {FG_RTDTIMP("COF",dDataBase),VEC_VALCOF} })
	VEC_VMFIPI := 0 //FG_CALCMF( { {FG_RTDTIMP("COF",dDataBase),VEC_VALCOF} })
	VEC_TMFIMP := VEC_VMFICM + VEC_VMFCOF + VEC_VMFPIS
	VEC_CMFMED := FG_CALCMF( { {dDataBase,VEC_CUSMED} })
	VEC_JMFEST := FG_CALCMF( { {dDataBase,VEC_JUREST} })
	VEC_CMFTOT := VEC_CMFMED + VEC_JMFEST
	VEC_LMFBRU := VEC_VMFVDA - VEC_TMFIMP - VEC_CMFTOT

	VEC_CMFVEN := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC_COMVEN} })
	VEC_CMFGER := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC_COMGER} })

	VEC_DMFVAR := VEC_CMFVEN + VEC_CMFGER
	VEC_LMFLIQ := VEC_LMFBRU - VEC_DMFVAR
	VEC_DMFFIX := 0
	VEC_CMFFIX := 0
	VEC_CMFDEP := 0
	VEC_DMFADM := 0
	VEC_RMFFIN := VEC_LMFLIQ - VEC_DMFFIX - VEC_CMFFIX - VEC_DMFDEP - VEC_DMFADM

	dbSelectArea("TRB")
	MsUnlock()

	If ExistBlock("OX001VEC") // Ponto de Entrada para Atualizacao dos campos referentes ao ST (VEC_ICMSST + VEC_DCLBST + VEC_COPIST)
		ExecBlock("OX001VEC",.f.,.f.,{SB1->B1_COD,VEC_DATVEN,oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES],nBaseIcm,VEC_QTDITE,"TRB"})
	EndIf

	dbSelectArea("VS5")
	FG_Seek("VS5","cCodMap",1,.f.)

	dbSelectArea("VOQ")
	FG_Seek("VOQ","cCodMap",1,.f.)

	while !eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")

		if VOQ_INDATI # "1" && Sim
			dbSkip()
			Loop
		Endif

		if VOQ_CODMAP # cCodMap
			Exit
		Endif

		cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)

		aadd(aStru,{ VS1->VS1_NUMORC,,SB1->B1_COD,VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,;
		VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,;
		VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,VS1->VS1_DATORC,0,0,VOQ_CTATOT})

		dbSkip()

	Enddo

	dbSelectArea("TRB")

	FG_CalcVlrs(aStru,SB1->B1_COD)
	cCpoDiv := cCpoDiv + "#" + str(len(aStru)+1,5)

Next

lCalcTot:= .t.

dbSelectArea("VS5")
FG_Seek("VS5","cCodMap",1,.f.)

dbSelectArea("VOQ")
FG_Seek("VOQ","cCodMap",1,.f.)

While !Eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")

	if VOQ_INDATI # "1" && Sim
		dbSkip()
		Loop
	Endif

	if VOQ_CODMAP # cCodMap
		exit
	Endif

	cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)

	aadd(aStru,{ VS1->VS1_NUMORC,,STR0192,VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,;
	VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,;
	VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,VS1->VS1_DATORC,0,0,VOQ_CTATOT}) // "Total da Venda"

	dbSkip()

Enddo

// Totaliza Mapa de Resultados quando mais de um Item
If Type("aStru") == "A"

	if Len(aStru) > 0
		cPriCta    := aStru[1,4]
		nQtdEMap   := aScan(aStru,{|x| x[4] == cPriCta},2) - 1  // Qtd de Elementos por Item no Mapa
		nTotStru   := (Len(aStru)-nQtdEMap) // Total de elementos no Vetor, exceto os elementos do Total da Venda
		nPosTotVda := nTotStru // Posicao ultimo elemento do vetor, anterior ao primeiro elemento do Total da Venda

		// Limpeza dos elementos do Total da Venda
		for ii := nPosTotVda+1 To Len(aStru)
			aStru[ii,09] := 0
			aStru[ii,12] := 0
		Next

		// Gravacao dos elementos do Total da Venda
		nSoma := nQtdEMap
		for ii := 1 To nTotStru
			nPosVet := (nPosTotVda+ii)-If(ii>nQtdEMap,nQtdEMap,0)
			if nPosVet > Len(aStru)
				nQtdEMap += nSoma
				nPosVet := (nPosTotVda+ii)-If(ii>nQtdEMap,nQtdEMap,0)
			Endif
			aStru[nPosVet,09] += aStru[ii,09]
			aStru[nPosVet,12] += aStru[ii,12]
		Next
		nTotItem := nTotStru + 1
		for ii := nTotItem To Len(aStru)
			aStru[ii,10] += ( aStru[ii,9]/aStru[nTotItem+1,9] ) * 100
		Next
	Endif
Endif


Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OX001GCORT | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Tela de Itens cortados do orçamento                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001GCORT(cPecSer)
Local cMotCort := Space(100)
Local lGrava   := .f.

DEFINE MSDIALOG oDlgCorte FROM 000,000 TO 100,320 TITLE ("") OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS//bonus do veiculo
oDlgCorte:lEscClose := .F.

if cPecSer == "P"  //Pecas
	@ 005,006 SAY STR0127 SIZE 150,08 OF oDlgCorte PIXEL FONT oFnt3  //Itens cortados pelo cliente
Else
	@ 005,006 SAY STR0158 SIZE 150,08 OF oDlgCorte PIXEL FONT oFnt3  //Servico cortados pelo cliente
Endif
@ 020,006 SAY STR0128 SIZE 150,08 OF oDlgCorte PIXEL  //Motivo
@ 020,027 MSGET oMotivo VAR cMotCort PICTURE "@!" SIZE 130,06 OF oDlgCorte PIXEL

DEFINE SBUTTON FROM 038,105 TYPE 1 ACTION (iif(Empty(cMotCort),MsgInfo(STR0129,STR0025),(lGrava := .t.,oDlgCorte:End()))) ENABLE OF oDlgCorte
DEFINE SBUTTON FROM 038,132 TYPE 2  ACTION (oDlgCorte:End()) ENABLE OF oDlgCorte

ACTIVATE MSDIALOG oDlgCorte CENTER

if lGrava
	if cPecSer == "P"  //Pecas
		cCont := 0
		dbSelectArea("VPJ")
		dbSetOrder(1)
		if dbSeek(xFilial("VPJ")+M->VS1_NUMORC)
			cCont := 1
			While !Eof() .and. xFilial("VPJ") == VPJ->VPJ_FILIAL .and. M->VS1_NUMORC == VPJ->VPJ_NUMORC
				cCont += 1
				dbSelectArea("VPJ")
				dbSkip()
			Enddo
		Else
			cCont := 1
		Endif
		aAdd( aVetCort,{xFilial("VPJ"),M->VS1_NUMORC,dDataBase,val(left(time(),2)+substr(time(),4,2)),oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE],oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE],oGetPecas:aCols[oGetPecas:nAt,nVS3QTDITE],oGetPecas:aCols[oGetPecas:nAt,nVS3VALTOT],cMotCort,STRZERO(cCont,3),M->VS1_NCLIFT} )
	Else       // Servicos
		cCont := 0
		DBSelectArea("SX2")
		if DBSeek("VPM")
			dbSelectArea("VPM")
			dbSetOrder(1)
			if dbSeek(xFilial("VPM")+M->VS1_NUMORC)
				cCont := 1
				While !Eof() .and. xFilial("VPM") == VPM->VPM_FILIAL .and. M->VS1_NUMORC == VPM->VPM_NUMORC
					cCont += 1
					dbSelectArea("VPM")
					dbSkip()
				Enddo
			Else
				cCont := 1
			Endif
			aAdd( aVetCortS,{xFilial("VPM"),M->VS1_NUMORC,dDataBase,val(left(time(),2)+substr(time(),4,2)),;
			oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_GRUSER","aHeaderS")],oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_CODSER","aHeaderS")],;
			oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_TIPSER","aHeaderS")],oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALSER","aHeaderS")],;
			cMotCort,STRZERO(cCont,3),M->VS1_NCLIFT} )
		Endif
	Endif
ElseIf(cPecSer=="P")
	OX001DELP()
Endif

return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001REQCPR | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Chamada da função de pedido de compra de pecas               |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001REQCPR(cGru,cCod,nQtd,lItem)
Local lImportada := .t.
Default cGru := "DEFAULT"
Default cCod := "DEFAULT"
Default nQtd := 0
Default lItem := .f.

if Type("oGetPecas") != "U"
	If MaFisFound('NF')
		if !OX001FPOK()
			return .f.
		endif
		//
		if cGru == "DEFAULT"  // RUBENS
			cGru := oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE]
		endif
		if cCod == "DEFAULT"
			cCod := oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE]
		endif
		if nQtd == 0
			if !lPediVenda
				nQtd := oGetPecas:aCols[oGetPecas:nAt,nVS3QTDITE] - oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_QTDEST","aHeaderP")]
			endif
		endif
		//
		If !lItem
			if oFoldX001:nOption != nFolderP
				lImportada := .f.
			endif
		EndIf
	endif
endif
cGruIte := cGru
cCodIte := cCod
nQtdIte := nQtd
if nQtdIte < 0
	nQtdIte := 0
endif

If !lItem
	if Left(ReadVar(),6)!="M->VS3"
		lImportada := .f.
	endif
EndIf

if Empty(cCodIte)
	lImportada := .f.
endif
//
DBSelectArea("SB1")
DBSetOrder(7)
if !DbSeek( xFilial("SB1") + cGruIte + cCodIte )
	lImportada := .f.
else
	DBSelectArea("SBM")
	DBSetOrder(1)
	DBSeek(xFilial("SBM")+SB1->B1_GRUPO)
endif
//
cIndReg := "0"
if lImportada
	OFMI900("VE6",0,3,{{"VE6_INDREG","0"},{"VE6_GRUITE",cGruIte},{"VE6_CODITE",cCodIte},{"VE6_CODMAR",SBM->BM_CODMAR}},.t.,.f.,STR0130)
else
	cGruIte := ""
	cCodIte := ""
	OFMI900("VE6",0,3,{{"VE6_INDREG","0"}},.t.,.f.,STR0130)
endif

return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OX001INCON | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Funcao para chamar a Tela de Inconvenientes                  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001INCON( nOpc , _cGrupo , _cCodigo , _cDescricao , _cEdit , _lInstalar , _nVlrFixSrv )
Local nCntFor2, nCntFor
Local nAuxPos, cSeqInc
Local nUltKil
Local nValSeq       := 0
Local cVO6CODMAR    := space(TamSX3("VO6_CODMAR")[1])
Local cVO6CODSER    := ""
Local cVO6GRUSER    := substr( GetNewPar("MV_MIL0080","") + space(15) , 05 , 02 ) // Grupo de Servico
Local cVS4TIPSER    := substr( GetNewPar("MV_MIL0080","") + space(15) , 07 , 03 ) // Tipo de Servico
Local cVS4CODSEC    := substr( GetNewPar("MV_MIL0080","") + space(15) , 10 , 03 ) // Secao Oficina
Local nVS4CODSER    := FG_POSVAR("VS4_CODSER","oGetServ:aHeader")
Local aRetParam     := {}
Local aParamBox     := {}
Local lFocoInconv   := .t.
Default _lInstalar  := .f.
Default _nVlrFixSrv := 0
//
_cDescricao := FwNoAccent(_cDescricao)
//
// Se for chamada pela edicao do campo de codigo e nao informado codigo ou grupo nao faz nda
// Se for chamada pela edicao do campo de descricao e nao informada a descricao nao faz nda
if (_cEdit == "C" .and. (Empty(_cGrupo) .or. Empty(_cCodigo))) .or. ;
	(_cEdit == "D" .and. Empty(_cDescricao))
	return .t.
endif
If !MaFisFound('NF') .or. M->VS1_TIPORC == "1"
	return .f.
endif
//

// Valida se é possível adicionar um inconveniente ...
lPrimSer := .f.
lPrimPec := .f.
If !OX001VLINC(@lPrimSer,@lPrimPec)
	Return .f.
EndIf
//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura o inconveniente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !empty(_cGrupo) .and. !empty(_cCodigo)
	dbSelectArea("VSL")
	dbSetOrder(1) // VSL_CODMAR+VSL_CODGRU+VSL_CODINC
	if !dbSeek(xFilial("VSL") + M->VS1_CODMAR + _cGrupo + _cCodigo)
		dbSelectArea("VSL")
		dbSetOrder(1) // VSL_CODMAR+VSL_CODGRU+VSL_CODINC
		if !dbSeek(xFilial("VSL") + Space(TamSX3("VS1_CODMAR")[1]) + _cGrupo + _cCodigo)
			MsgAlert(STR0138)
			Return .f.
		endif
	 Endif
	_cDescricao := VSL->VSL_DESINC
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se ja existe o inconveniente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if OX001IDUPL( 0, _cGrupo, _cCodigo, _cDescricao )
	MsgAlert(STR0139)
	Return .f.
endif

SET KEY VK_F4 TO
SET KEY VK_F5 TO
SET KEY VK_F6 TO
SET KEY VK_F7 TO
SET KEY VK_F8 TO
SET KEY VK_F9 TO
SET KEY VK_F10 TO

// Se nao for informado grupo e codigo do inconveniente, exibe tela para editar as pecas e servicos
if !(empty(_cGrupo) .and. empty(_cCodigo))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se no inconveniente, tem validacao para KM,³
	//³ se tiver, validar a KM digitada no orcamento        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VSL->(DbSetOrder(1)) // VSL_FILIAL+VSL_CODMAR+VSL_CODGRU+VSL_CODINC
	If DbSeek(xFilial("VSL")+M->VS1_CODMAR+_cGrupo+_cCodigo)
		if VSL->VSL_KILOME <> 0 .or. VSL->VSL_KILFIN <> 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ É um inconveniente cadastrado, se for informado KM do Veiculo,                        ³
			//³ validar para ver se é a ultima, pois pode ser necessária para validar o inconveniente ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cValKil := Left(GetNewPar("MV_VKILHOR","SN"),1)
			if cValKil == "S" .or. (cValKil == "P" .and. !Empty(M->VS1_KILOME))
				nUltKil := FG_ULTKIL(M->VS1_CHAINT)
				If nUltKil > M->VS1_KILOME
					if !lOX001Auto
						MsgInfo(STR0152+" ("+Transform(M->VS1_KILOME,"@E 999,999,999")+" ) "+STR0153+" ("+Transform(nUltKil,"@E 999,999,999")+" )!",STR0025) //KM/hora informada # menor que da OS anterior
					endif
					Return .f.
				EndIf
			Endif
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a Consulta de Inconvenientes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRet := OFIOM420( _cGrupo , _cCodigo , M->VS1_CHAINT , M->VS1_KILOME , M->VS1_TIPTEM , _cDescricao , , M->VS1_TIPTSV , .T. , .F. , "" , "" , "" , .T. ) // Inconvenientes
	aPeca := aRet[1]
	aServ := aRet[2]
else
	aPeca := {}
	aServ := {}
	aRet  := {,,.t.}
	If !Empty(_cDescricao)
		If GetNewPar("MV_MIL0093","0") == "1" // Utiliza Servicos Autmaticos e preencheu apenas a Descricao do Inconveniente

			nAuxPos := aScan(oGetServ:aCols, {|x| Alltrim(x[FG_POSVAR("VS4_DESINC","aHeaderS")]) == Alltrim(_cDescricao) })
			If nAuxPos > 0 .and. oGetServ:aCols[nAuxPos,Len(oGetServ:aCols[nAuxPos])] // Verifica se existe o Servico deletado na aCols de Servicos
				oGetServ:aCols[nAuxPos,Len(oGetServ:aCols[nAuxPos])] := .f. // Voltar Servico
			Else
				// Pegar um Codigo de Servico nao utilizado ainda no Orcamento
				DbSelectArea("VO6")
				DbSetOrder(3) // VO6_FILIAL + VO6_CODMAR + VO6_GRUSER + VO6_CODSER
				DbSeek( xFilial("VO6") + cVO6CODMAR + cVO6GRUSER )
				While !Eof() .and. VO6->VO6_FILIAL == xFilial("VO6") .and. VO6->VO6_CODMAR == cVO6CODMAR .and. VO6->VO6_GRUSER == cVO6GRUSER
					If aScan(oGetServ:aCols,{|x| x[nVS4CODSER] == VO6->VO6_CODSER }) <= 0 // Verifica se nao existe o Servico na aCols de Servicos
						cVO6CODSER := VO6->VO6_CODSER // Codigo do Servico
						Exit
					EndIf
					DbSelectArea("VO6")
					DbSkip()
				EndDo
				If !Empty(cVO6CODSER)
					AADD(aParamBox,{1,AllTrim(aHeaderI[FG_POSVAR("VST_GRUINC","aHeaderI"),1]),_cGrupo    ,"@!"           ,""          ,"",".F.",030,.F.}) // 1 - Grupo Inconveniente
					AADD(aParamBox,{1,AllTrim(aHeaderI[FG_POSVAR("VST_CODINC","aHeaderI"),1]),_cCodigo   ,"@!"           ,""          ,"",".F.",080,.F.}) // 2 - Codigo Inconveniente
					AADD(aParamBox,{1,AllTrim(aHeaderI[FG_POSVAR("VST_DESINC","aHeaderI"),1]),_cDescricao,"@!"           ,""          ,"",".F.",120,.F.}) // 3 - Descricao Inconveniente
					If _nVlrFixSrv > 0
						AADD(aParamBox,{1,AllTrim(aHeaderS[FG_POSVAR("VS4_VALSER","aHeaderS"),1]),_nVlrFixSrv,"@E 999,999.99","MV_PAR04>0","",".F.",070,.T.}) // 4 - Vlr.Servico
					Else
						AADD(aParamBox,{1,AllTrim(aHeaderS[FG_POSVAR("VS4_VALSER","aHeaderS"),1]),0          ,"@E 999,999.99","MV_PAR04>0","",".T.",070,.T.}) // 4 - Vlr.Servico
					EndIf
					If ExistBlock("OX01INCX")
						aParamBox := ExecBlock("OX01INCX",.f.,.f.,{"1",aParamBox,aRetParam,aServ}) // PE executado para manipular a Parambox de criacao dos Servicos automaticos pela Descricao do Inconveniente
					EndIf
					If ParamBox(aParamBox,AllTrim(aHeaderS[FG_POSVAR("VS4_VALSER","aHeaderS"),1]),@aRetParam,,,,,,,,.f.) // Vlr.Servico
						//
						AADD(aServ,{ cVO6GRUSER   ,;	// 1 - Grupo
								  	 cVO6CODSER   ,;	// 2 - CodSrv
								  	 cVS4TIPSER   ,;	// 3 - TipSrv
								  	 _cGrupo      ,;	// 4 - Grupo.Inconveniente
							  		 _cCodigo     ,;	// 5 - Cod.Inconveniente
								  	 _cDescricao  ,;	// 6 - Descr.Inconveniente
							  		 cVS4CODSEC   ,;	// 7 - Cod.Secao
								  	 aRetParam[4] ,;	// 8 - Valor Total dos Servicos
								  	 1            })	// 9 - Qtde de Servicos ( FIXO: 1 )
						//
						If ExistBlock("OX01INCX")
							aServ := ExecBlock("OX01INCX",.f.,.f.,{"2",aParamBox,aRetParam,aServ}) // PE executado para manipular o Vetor de Servicos apos OK da Parambox e criacao do Servico automatico
						EndIf
						//
					Else
						aRet[3] := .f.
						lFocoInconv := .f.
					EndIf
				Else
					MsgStop(STR0317,STR0025) // Nao foi possivel obter um proximo codigo de servico da tabela de servicos. Por favor, cadastre mais servicos na tabela de servicos! / Atencao
					aRet[3] := .f.
				EndIf
			EndIf
			//
		Else
			cSeqInc := OX001SEQINC(_cDescricao)
		EndIf
	EndIf
EndIf

cGruInc := space(TamSX3("VST_GRUINC")[1])
cCodInc := space(TamSX3("VST_CODINC")[1])
cDesInc := space(TamSX3("VST_DESINC")[1])
cSeqInc := Space(TamSX3("VST_SEQINC")[1])
SETKEY(VK_F4,{|| OX001KEYF4() })
SETKEY(VK_F5,{|| OX001REQCPR() })
SETKEY(VK_F6,{|| OX001KEYF6() })
SETKEY(VK_F7,{|| OFIXC001() })

If ExistBlock("OX001F8")
	SETKEY(VK_F8,{|| ExecBlock("OX001F8",.f.,.f.,{ M->VS1_NUMORC , M->VS3_GRUITE , M->VS3_CODITE }) })
EndIf
If ExistBlock("OX001F9")
	SETKEY(VK_F9,{|| ExecBlock("OX001F9",.f.,.f.,{ M->VS1_NUMORC , M->VS3_GRUITE , M->VS3_CODITE }) })
EndIf
If GetNewPar("MV_MIL0075","0") $ "1/S" // Mostrar Tela ( 1=Sim / 0=Nao )
	SETKEY(VK_F10,{|| OX0010145_TelaTipoPagamento() } )
EndIf

// Se foi cancelado a janela de Inconvenientes ...
if !aRet[3]
	If lFocoInconv
		oGruInc:SetFocus()
	EndIf
	Return .f.
endif
//
//###########################################
//# Adiciona na GetGados dos Inconvenientes #
//###########################################
// Se tiver em branco, adicionou inconveniente pelo grupo e codigo
if empty(_cDescricao)
	if len(aPeca) > 0
		_cDescricao := aPeca[1,6]
	else
		_cDescricao := aServ[1,6]
	endif
endif
//

// Verifica se é a primeira linha da aCols
lPrimeiraLinha := .f.
nAuxPos := FG_POSVAR("VST_DESINC","aHeaderI")
if Len(oGetInconv:aCols) == 1
	if empty(oGetInconv:aCols[1,nAuxPos])
		lPrimeiraLinha := .t.
	endif
endif
nAuxPos := 0
If Empty(_cGrupo+_cCodigo) .and. !Empty(_cDescricao)
	nAuxPos := aScan(oGetInconv:aCols, {|x| Alltrim(x[FG_POSVAR("VST_DESINC","aHeaderI")]) == Alltrim(_cDescricao) }) // Procurar se ja existe Inconveniente por Descricao
EndIf
If nAuxPos <= 0
	if !lPrimeiraLinha
		AADD(oGetInconv:aCols,Array(nUsadoI+1))
	endif
	nAuxPos := Len(oGetInconv:aCols)
	oGetInconv:aCols[nAuxPos,FG_POSVAR("VST_SEQINC","aHeaderI")] := M->VST_SEQINC := cSeqInc
	oGetInconv:aCols[nAuxPos,FG_POSVAR("VST_GRUINC","aHeaderI")] := M->VST_GRUINC := _cGrupo
	oGetInconv:aCols[nAuxPos,FG_POSVAR("VST_CODINC","aHeaderI")] := M->VST_CODINC := _cCodigo
	oGetInconv:aCols[nAuxPos,FG_POSVAR("VST_DESINC","aHeaderI")] := M->VST_DESINC := _cDescricao
Else
	M->VST_SEQINC := cSeqInc     := oGetInconv:aCols[nAuxPos,FG_POSVAR("VST_SEQINC","aHeaderI")]
	M->VST_GRUINC := _cGrupo     := oGetInconv:aCols[nAuxPos,FG_POSVAR("VST_GRUINC","aHeaderI")]
	M->VST_CODINC := _cCodigo    := oGetInconv:aCols[nAuxPos,FG_POSVAR("VST_CODINC","aHeaderI")]
	M->VST_DESINC := _cDescricao := oGetInconv:aCols[nAuxPos,FG_POSVAR("VST_DESINC","aHeaderI")]
EndIf
oGetInconv:nAt := nAuxPos
oGetInconv:aCols[nAuxPos,nUsadoI+1] := .f.
oGetInconv:oBrowse:Refresh()

//
//###########################################
//# Adiciona na GetDados de Pecas           #
//###########################################
If Len(aPeca) > 0
	//
	OX001RefNF()
	//
	for nCntFor := 1 to Len(aPeca)
		if !lPrimPec
			AADD(oGetPecas:aCols,Array(nUsadoPX01+1))
		endif
		lPrimPec := .f.
		oGetPecas:aCols[Len(oGetPecas:aCols),nUsadoPX01+1]:=.F.
		For nCntFor2:=1 to nUsadoPX01
			If IsHeadRec(aHeaderP[nCntFor2,2])
				oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor2] := VS3->(RecNo())
			ElseIf IsHeadAlias(aHeaderP[nCntFor2,2])
				oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor2] := "VS3"
			Else
				oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor2] := CriaVar(aHeaderP[nCntFor2,2])
			EndIf
		Next
		oGetPecas:nAt := n := Len(oGetPecas:aCols)
		DBSelectArea("SB1")
		DBSetOrder(7)
		DBSeek(xFilial("SB1")+aPeca[nCntFor,1]+aPeca[nCntFor,2])
		aVetCmp := {}
		aAdd(aVetCmp,{"VS3_GRUITE",aPeca[nCntFor,1]} )
		aAdd(aVetCmp,{"VS3_CODITE",aPeca[nCntFor,2]} )
		aAdd(aVetCmp,{"VS3_QTDITE",aPeca[nCntFor,3]} )
		aAdd(aVetCmp,{"VS3_FORMUL",M->VS1_FORMUL} )
		cTesCmp := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
		if M->VS1_TIPORC == "2"
			DBSelectArea("VOI")
			DBSetOrder(1)
			DBSeek(xFilial("VOI")+M->VS1_TIPTEM)
			if !Empty(VOI->VOI_CODOPE)
				cTesCmp := OX001TESINT(VOI->VOI_CODOPE)
			endif
		endif
		aAdd(aVetCmp,{"VS3_CODTES",cTesCmp})
		RegToMemory("VS3",.t.)
		// Ajusta sequencia da VS3
		OX0010163_SequenciaVS3()
		//
		oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] := M->VS3_GRUITE := aPeca[nCntFor,1]
		oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] := M->VS3_CODITE := aPeca[nCntFor,2]
		oGetPecas:aCols[oGetPecas:nAt,nVS3QTDITE] := M->VS3_QTDITE := aPeca[nCntFor,3]
		oGetPecas:aCols[oGetPecas:nAt,nVS3GRUINC] := M->VS3_GRUINC := aPeca[nCntFor,4]
		oGetPecas:aCols[oGetPecas:nAt,nVS3CODINC] := M->VS3_CODINC := aPeca[nCntFor,5]
		oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC] := M->VS3_DESINC := aPeca[nCntFor,6]
		oGetPecas:aCols[oGetPecas:nAt,nVS3CODTES] := M->VS3_CODTES := cTesCmp
		oGetPecas:aCols[oGetPecas:nAt,nVS3SEQINC] := M->VS3_SEQINC := cSeqInc
		//
		If ExistBlock("OX01INCP")
			ExecBlock("OX01INCP",.f.,.f.,{aPeca,nCntFor}) // PE executado no preenchimento da aCols de Pecas (VS3) pelo Inconveniente
		EndIf
		//
		for nCntFor2 := 1 to Len(aVetCmp)
			oGetPecas:nAt := n := Len(oGetPecas:aCols)
			__ReadVar := "M->"+aVetCmp[nCntFor2,1]
			&("M->"+aVetCmp[nCntFor2,1]) := aVetCmp[nCntFor2,2]
			oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR(aVetCmp[nCntFor2,1],"aHeaderP")] := aVetCmp[nCntFor2,2]
			if !OX001FPOK(,,.f.,.f.)
				aSize(oGetPecas:aCols,Len(oGetPecas:aCols)-1)
				exit
			endif
		next

	next

	If Len(oGetPecas:aCols) == 0
		oGetPecas:aCols := { Array(Len(aHeaderP)+1) }
		oGetPecas:aCols[1,Len(aHeaderP)+1] := .F.
		For nCntFor:=1 to Len(aHeaderP)
			If IsHeadRec(aHeaderP[nCntFor,2])
				oGetPecas:aCols[1,nCntFor] := 0
			ElseIf IsHeadAlias(aHeaderP[nCntFor,2])
				oGetPecas:aCols[1,nCntFor] := "VS3"
			Else
				oGetPecas:aCols[1,nCntFor] := CriaVar(aHeaderP[nCntFor,2])
			EndIf
		Next
	Endif
	oGetPecas:oBrowse:refresh()
	FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
EndIf
//
//###########################################
//# Adiciona na GetDados de Servicos        #
//###########################################
If Len(aServ) > 0
	lPrimeiraLinha := .f.
	if Len(oGetServ:aCols) == 1
		cSer := oGetServ:aCols[1,fg_posvar("VS4_CODSER","aHeaderS")]
		cGrupo := oGetServ:aCols[1,fg_posvar("VS4_GRUSER","aHeaderS")]
		// 1a linha vazia (inicio)
		if oGetServ:aCols[oGetServ:nAt,Len(oGetServ:aCols[oGetServ:nAt])]
			lPrimeiraLinha := .f.
		elseif Empty(cGrupo) .and. Empty(cSer)
			lPrimeiraLinha := .t.
		endif
	endif
	for nCntFor := 1 to Len(aServ)
		if !lPrimeiraLinha
			AADD(oGetServ:aCols,Array(nUsadoS+1))
		endif
		lPrimeiraLinha := .f.
		oGetServ:aCols[Len(oGetServ:aCols),nUsadoS+1]:=.F.
		For nCntFor2:=1 to nUsadoS
			oGetServ:aCols[Len(oGetServ:aCols),nCntFor2]:=CriaVar(aHeaderS[nCntFor2,2])
		Next
		oGetServ:nAt := n := Len(oGetServ:aCols)
		//
		aVetCmp := {}
		aAdd(aVetCmp,{"VS4_GRUSER",aServ[nCntFor,1]} )
		aAdd(aVetCmp,{"VS4_CODSER",aServ[nCntFor,2]} )
		aAdd(aVetCmp,{"VS4_TIPSER",aServ[nCntFor,3]} )
		RegToMemory("VS4",.t.)
		// Ajusta sequencia da VS4
		OX0010365_SequenciaVS4()
		//
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_GRUSER","aHeaderS")] := M->VS4_GRUSER := aServ[nCntFor,1]
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_CODSER","aHeaderS")] := M->VS4_CODSER := aServ[nCntFor,2]
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_TIPSER","aHeaderS")] := M->VS4_TIPSER := aServ[nCntFor,3]
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_GRUINC","aHeaderS")] := M->VS4_GRUINC := aServ[nCntFor,4]
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_CODINC","aHeaderS")] := M->VS4_CODINC := aServ[nCntFor,5]
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_DESINC","aHeaderS")] := M->VS4_DESINC := aServ[nCntFor,6]
		If GetNewPar("MV_MIL0093","0") == "1" .and. !Empty(cVO6CODSER) .and. Alltrim(cVO6CODSER)==Alltrim(M->VS4_CODSER) // Utiliza Servicos Automaticos com o valor preenchido pelo usuario
			oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALSER","aHeaderS")] := M->VS4_VALSER := aServ[nCntFor,8] // Valor Servico
			oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_VALTOT","aHeaderS")] := M->VS4_VALTOT := aServ[nCntFor,8] // Total Servicos
		EndIf
		//
		If ExistBlock("OX01INCS")
			ExecBlock("OX01INCS",.f.,.f.,{aServ,nCntFor}) // PE executado no preenchimento da aCols de Servicos (VS4) pelo Inconveniente
		EndIf
		//
		cSeqInc := OX001SEQINC(aServ[nCntFor,6])
		oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_SEQINC","aHeaderS")] := M->VS4_SEQINC := cSeqInc
		//

		M->VS4_CODSEC := aServ[nCntFor,7]
		aAdd(aVetCmp,{"VS4_CODSEC",aServ[nCntFor,7]} )

		VO6->(dbSetOrder(3))
		if VO6->(dbSeek(xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,aServ[nCntFor,2])+aServ[nCntFor,1]+aServ[nCntFor,2]))
			M->VS4_DESSER := VO6->VO6_DESSER
		endif
		for nCntFor2 := 1 to Len(aVetCmp)
			oGetServ:nAt := n := Len(oGetServ:aCols)
			__ReadVar := "M->"+aVetCmp[nCntFor2,1]
			if !OX001FSOK()
				aSize(oGetServ:aCols,Len(oGetServ:aCols)-1)
				exit
			endif
		next
	next
	nValSeq := 0

	oGetServ:oBrowse:refresh()
EndIf
//
If _lInstalar // Preencher Inconveniente da Peca com o mesmo do Servico
	oGetPecas:aCols[oGetPecas:nAt,nVS3SEQINC] := cSeqInc
	oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC] := _cDescricao
EndIf
//
VE1->(dbSetOrder(1))
VE1->(dbSeek(xFilial("VE1") + M->VS1_CODMAR)) //FNC 18967/2010 - BOBY - 30/08/10

If ExistBlock("OX01DINC")
	ExecBlock("OX01DINC",.f.,.f.,{cSeqInc,_cGrupo,_cCodigo,_cDescricao}) // PE executado Depois da Inclusao de Peças e Serviços do Inconveniente
EndIf

oGetInconv:oBrowse:Refresh()
oGruInc:SetFocus()

return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OX001VLINC | Autor | Rubens Takahashi      | Data | 10/09/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Valida se é possivel adicionar um inconveniente ...          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OX001VLINC(lPrimSer,lPrimPec)

Local nCntFor

Local nPosGruSer := FG_POSVAR("VS4_GRUSER","aHeaderS")
Local nPosCodSer := FG_POSVAR("VS4_CODSER","aHeaderS")
Local nPosGruIte := nVS3GRUITE
Local nPosCodIte := nVS3CODITE
Local nPosGruInc := nVS3GRUINC
Local nPosCodInc := nVS3CODINC
Local nPosSeqInc := nVS3SEQINC
Local nPosDesInc := nVS3DESINC

lPrimSer := .f.
if !(oGetServ:aCols[oGetServ:nAt,len(oGetServ:aCols[oGetServ:nAt])])
	cSer := oGetServ:aCols[oGetServ:nAt,nPosCodSer]
	cGrupo := oGetServ:aCols[oGetServ:nAt,nPosGruSer]
	if !(Len(oGetServ:aCols)==1 .and. Empty(cSer) .and. Empty(cGrupo))
		if !OX001LINSOK()
			return .f.
		endif
	else
		lPrimSer := .t.
	endif
endif
//
lPrimPec := .f.
if !(oGetPecas:aCols[oGetPecas:nAt,len(oGetPecas:aCols[oGetPecas:nAt])])
	cPeca := oGetPecas:aCols[oGetPecas:nAt,nPosCodIte]
	cGrupo := oGetPecas:aCols[oGetPecas:nAt,nPosGruIte]
	if !(Len(oGetPecas:aCols)==1 .and. Empty(cPeca) .and. Empty(cGrupo))
		if !OX001LINPOK()
			return .f.
		endif
	else
		lPrimPec := .t.
	endif
endif
//


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ja existe peca/servico e esta sem inconveniente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lInconvObr .or. Empty(cIncDefault)
	if !lPrimPec
		nPosDESINC := nVS3DESINC
		for nCntFor := 1 to Len(oGetPecas:aCols)
			if !oGetPecas:aCols[nCntFor,Len(oGetPecas:aCols[nCntFor])] .and. Empty(oGetPecas:aCols[nCntFor,nPosDESINC])
				if !lOX001Auto
					MsgInfo(STR0162)
				endif
				return .f.
			endif
		next nCntFor
	endif
	if !lPrimSer
		nPosDESINC := fg_posvar("VS4_DESINC","aHeaderS")
		for nCntFor := 1 to Len(oGetServ:aCols)
			if !oGetServ:aCols[nCntFor,Len(oGetServ:aCols[nCntFor])] .and. Empty(oGetServ:aCols[nCntFor,nPosDESINC])
				if !lOX001Auto
					MsgInfo(STR0163)
				endif
				return .f.
			endif
		next nCntFor
	endif
Else
	nPosInc := aScan(oGetInconv:aCols,{|x| FwNoAccent(Alltrim(x[FG_POSVAR("VST_DESINC","aHeaderI")])) == FwNoAccent(cIncDefault) .and. !x[len(oGetInconv:aHeader)+1] })
	if nPosInc == 0
		cDescInconv := cIncDefault
		OX001SEQINC(cDescInconv)
		nPosInc := aScan(oGetInconv:aCols,{|x| FwNoAccent(Alltrim(x[FG_POSVAR("VST_DESINC","aHeaderI")])) == FwNoAccent(cIncDefault) .and. !x[len(oGetInconv:aHeader)+1] })
	Endif
	M->VS3_GRUINC := ""
	M->VS3_CODINC := ""
	M->VS3_SEQINC := oGetInconv:aCols[nPosInc,1]
	M->VS3_DESINC := oGetInconv:aCols[nPosInc,4]
	for nCntFor := 1 to Len(oGetPecas:aCols)
		if !oGetPecas:aCols[nCntFor,Len(oGetPecas:aCols[nCntFor])] .and. Empty(oGetPecas:aCols[nCntFor,nPosDESINC])
			oGetPecas:aCols[nCntFor,nPosGruInc] := M->VS3_GRUINC
			oGetPecas:aCols[nCntFor,nPosCodInc] := M->VS3_CODINC
			oGetPecas:aCols[nCntFor,nPosSeqInc] := M->VS3_SEQINC
			oGetPecas:aCols[nCntFor,nPosDesInc] := M->VS3_DESINC
		endif
	next nCntFor
Endif
//
Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001PRETIP | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | X3_RELACAO do campo VS1_TIPVEN. Verifica no VAI a permissao  |##
##|          | de venda para o  vendedor contido no VS1_CODVEN              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001PRETIP()
DBSelectArea("VAI")
DBSetOrder(6)
if DBSeek(xFilial("VAI")+M->VS1_CODVEN)
	if VAI->VAI_TIPVEN == "1"
		return "1"
	elseif VAI->VAI_TIPVEN == "2"
		return "2"
	else
		return "1"
	endif
endif
return "1"

/*
===============================================================================
###############################################################################
##+----------+---------------+-------+--------------------+------+----------+##
##|Função    | OX001SELINCON | Autor | Rubens Takahashi   | Data | 06/01/10 |##
##+----------+---------------+-------+--------------------+------+----------+##
##|Descrição | Exibe uma tela para o usuario selecionar dentre os inconve.  |##
##|          | ja selecionados no orcamento, um inconveniente para a peca   |##
##|          | ou servico digitada manualmente                              |##
##+----------+--------------------------------------------------------------+##
##|Parametros| _cTp     = "P" -> Pecas  /  "S" -> Servicos                  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001SELINCON(_cTp)
Local aInconv := {"","","",""}
Local cQuery  := ""
Local cTitTelaInc := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se é Orcamento de Oficina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if M->VS1_TIPORC <> "2"
	return
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o Inconveniente esta habilitado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lInconveniente
	return
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se já não esta selecionado o inconveniente da Peca ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if _cTp == "P" .and. ;
	((!Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3GRUINC]) .and. !Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3CODINC]) );
	.or.;
	!Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC]) )
	Return
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se já não esta selecionado o inconveniente do Servico ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if _cTp == "S" .and. ;
	( (!Empty(oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_GRUINC","aHeaderS")]) .and. !Empty(oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_CODINC","aHeaderS")]) );
	.or. ;
	!Empty(oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_DESINC","aHeaderS")]) )
	Return
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama funcao para exibir tela para Selecao do Inconveniente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if _cTp == "S"
	VOK->(dbSetOrder(1))
	VOK->(dbSeek(xFilial("VOK")+M->VS4_TIPSER))
Endif

If lInconvObr .or. Empty(cIncDefault)
	If _cTp == "P" // Pecas
		cQuery := "SELECT B1_DESC FROM "+RetSQLName("SB1")
		cQuery += " WHERE B1_FILIAL='"+xFilial("SB1")+"'"
		cQuery += "   AND B1_GRUPO='"+oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_GRUITE","aHeaderP")]+"'"
		cQuery += "   AND B1_CODITE='"+oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODITE","aHeaderP")]+"'"
		cQuery += "   AND D_E_L_E_T_=' '"
		cTitTelaInc :=	STR0018+": "+oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_GRUITE","aHeaderP")]+" - "+;
						STR0020+": "+oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODITE","aHeaderP")]+" - "+;
						FM_SQL(cQuery)
	Else // Servicos
		cTitTelaInc := ( STR0168+": "+oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_GRUSER","aHeaderS")] +" - "+;
									oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_CODSER","aHeaderS")] ) // Servicos
	EndIf
	aInconv := OM420SELINCON(oGetInconv:aCols, { FG_POSVAR("VST_SEQINC","aHeaderI") , ;
	FG_POSVAR("VST_GRUINC","aHeaderI") , ;
	FG_POSVAR("VST_CODINC","aHeaderI") , ;
	FG_POSVAR("VST_DESINC","aHeaderI") } , oMainWnd , , ,;
	cTitTelaInc )
Else
	nPosInc := aScan(oGetInconv:aCols,{|x| FwNoAccent(Alltrim(x[FG_POSVAR("VST_DESINC","aHeaderI")])) == FwNoAccent(cIncDefault) .and. !x[len(oGetInconv:aHeader)+1] })
	if nPosInc == 0
		cDescInconv := cIncDefault
		OX001SEQINC(cDescInconv)
		nPosInc := aScan(oGetInconv:aCols,{|x| FwNoAccent(Alltrim(x[FG_POSVAR("VST_DESINC","aHeaderI")])) == FwNoAccent(cIncDefault) .and. !x[len(oGetInconv:aHeader)+1] })
	Endif
	aInconv[1] := ""
	aInconv[2] := ""
	aInconv[3] := oGetInconv:aCols[nPosInc,4]
	aInconv[4] := oGetInconv:aCols[nPosInc,1]

Endif

if _cTp == "P"
	oGetPecas:aCols[oGetPecas:nAt,nVS3GRUINC] := M->VS3_GRUINC := aInconv[1]
	oGetPecas:aCols[oGetPecas:nAt,nVS3CODINC] := M->VS3_CODINC := aInconv[2]
	oGetPecas:aCols[oGetPecas:nAt,nVS3SEQINC] := M->VS3_SEQINC := aInconv[4]
	oGetPecas:aCols[oGetPecas:nAt,nVS3DESINC] := M->VS3_DESINC := aInconv[3]
endif

if _cTp == "S"
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_GRUINC","aHeaderS")] := M->VS4_GRUINC := aInconv[1]
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_CODINC","aHeaderS")] := M->VS4_CODINC := aInconv[2]
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_SEQINC","aHeaderS")] := M->VS4_SEQINC := aInconv[4]
	oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_DESINC","aHeaderS")] := M->VS4_DESINC := aInconv[3]
endif

return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001FIOK   | Autor | Rubens Takahashi      | Data | 07/01/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | FieldOK da aCols de Inconvenientes                           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001FIOK(nOpc)

// Linha da aCols Excluida
if oGetInconv:aCols[oGetInconv:nAt,Len(oGetInconv:aCols[oGetInconv:nAt])]
	return .f.
endif

if ReadVar() == "M->VST_DESINC"
	// Se informado grupo e codigo do inconveniente, não é possivel alterar a descricao
	if !Empty(oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_GRUINC","aHeaderI")]) .and. !Empty(oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_CODINC","aHeaderI")])
		MsgAlert(STR0140)
		return .f.
	endif
endif
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001DELI   | Autor | Rubens Takahashi      | Data | 20/01/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |Verifica se pode deletar o inconveniente                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001DELI()

Local nCntFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se tiver excluido, restaura registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if oGetInconv:aCols[oGetInconv:nAt,Len(oGetInconv:aCols[oGetInconv:nAt])]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o inconveniente nao ficara duplicado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if OX001IDUPL(oGetInconv:nAt, oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_GRUINC","aHeaderI")],;
		oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_CODINC","aHeaderI")],;
		oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_DESINC","aHeaderI")],;
		oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_SEQINC","aHeaderI")])

		MsgAlert(STR0139)
		Return .f.

	EndIf

	oGetInconv:aCols[oGetInconv:nAt,Len(oGetInconv:aCols[oGetInconv:nAt])] := .f.
	oGetInconv:Refresh()
	return .t.
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe peca para o inconveniente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCntFor := 1 to Len(oGetPecas:aCols)
	if !oGetPecas:aCols[nCntFor,Len(oGetPecas:aCols[nCntFor])]

		if oGetPecas:aCols[nCntFor,nVS3SEQINC] == oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_SEQINC","aHeaderI")] .and.;
			oGetPecas:aCols[nCntFor,nVS3GRUINC] == oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_GRUINC","aHeaderI")] .and.;
			oGetPecas:aCols[nCntFor,nVS3CODINC] == oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_CODINC","aHeaderI")] .and.;
			oGetPecas:aCols[nCntFor,nVS3DESINC] == oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_DESINC","aHeaderI")]

			MsgAlert(STR0141)
			return .f.
		EndIf

	EndIf
Next nCntFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe servico para o inconveniente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCntFor := 1 to Len(oGetServ:aCols)
	if !oGetServ:aCols[nCntFor,Len(oGetServ:aCols[nCntFor])]

		if oGetServ:aCols[nCntFor,FG_POSVAR("VS4_SEQINC","aHeaderS")] == oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_SEQINC","aHeaderI")] .and.;
			oGetServ:aCols[nCntFor,FG_POSVAR("VS4_GRUINC","aHeaderS")] == oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_GRUINC","aHeaderI")] .and.;
			oGetServ:aCols[nCntFor,FG_POSVAR("VS4_CODINC","aHeaderS")] == oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_CODINC","aHeaderI")] .and.;
			oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DESINC","aHeaderS")] == oGetInconv:aCols[oGetInconv:nAt,FG_POSVAR("VST_DESINC","aHeaderI")]

			MsgAlert(STR0142)
			return .f.
		EndIf

	endif
Next nCntFor

oGetInconv:aCols[oGetInconv:nAt,Len(oGetInconv:aCols[oGetInconv:nAt])] := .t.
oGetInconv:Refresh()

Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001PDUPL  | Autor |Rubens Takahashi       | Data | 21/01/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |Verifica se existe peca duplicada no Orcamento                |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001PDUPL(nAuxLinha, cPGruIte, cPCodIte, cPGruInc, cPCodInc, cPDesInc, cPSeqInc, cNumLot, cLoteCtl, nPLinDup)
Local nCntFor, lRetorno
Local aColsLoc
Local nLoc
Default cPGruInc := ""
Default cPCodInc := ""
Default cPDesInc := ""
Default cPSeqInc := ""
Default cNumLot  := ""
Default cLoteCtl := ""
Default nPLinDup := 0
//
if lOX001Auto
	aColsLoc := aClone(aCols)
	nLoc := n
else
	aColsLoc := aClone(oGetPecas:aCols)
	nLoc := oGetPecas:nAt
endif
lRetorno := .f.
If M->VS1_TIPORC != "1" // Balcão pode repetir os itens
	for nCntFor := 1 to Len(oGetPecas:aCols)
		if  !(oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])]) .and. nCntFor <> nAuxLinha

			if AllTrim(oGetPecas:aCols[nCntFor,nVS3GRUITE]) == AllTrim(cPGruIte) .and. ;
				AllTrim(oGetPecas:aCols[nCntFor,nVS3CODITE]) == AllTrim(cPCodIte) .and. ;
				AllTrim(oGetPecas:aCols[nCntFor,nVS3NUMLOT]) == AllTrim(cNumLot) .and. ;
				AllTrim(oGetPecas:aCols[nCntFor,nVS3LOTECT]) == AllTrim(cLoteCtl)


				if lInconveniente

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se for outro inconveniente, não esta duplicado³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					if AllTrim(oGetPecas:aCols[nCntFor,nVS3GRUINC]) == AllTrim(cPGruInc) .and. ;
						AllTrim(oGetPecas:aCols[nCntFor,nVS3CODINC]) == AllTrim(cPCodInc) .and. ;
						AllTrim(oGetPecas:aCols[nCntFor,nVS3DESINC]) == AllTrim(cPDesInc) .and. ;
						AllTrim(oGetPecas:aCols[nCntFor,nVS3SEQINC]) == AllTrim(cPSeqInc) .and. ;
						AllTrim(oGetPecas:aCols[nCntFor,nVS3NUMLOT]) == AllTrim(cNumLot) .and. ;
						AllTrim(oGetPecas:aCols[nCntFor,nVS3LOTECT]) == AllTrim(cLoteCtl)

						nPLinDup := nCntFor
						Return .t.

					EndIf
				else

					nPLinDup := nCntFor
					Return .t.

				EndIf
			EndIf
		EndIf
	next
Else // TIPORC == "1"
	for nCntFor := 1 to Len(oGetPecas:aCols)
		
		if  !(oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])]) .and. nCntFor <> nAuxLinha
			if AllTrim(oGetPecas:aCols[nCntFor,nVS3GRUITE]) == AllTrim(cPGruIte) .and. ;
				AllTrim(oGetPecas:aCols[nCntFor,nVS3CODITE]) == AllTrim(cPCodIte) .and. ;
				AllTrim(oGetPecas:aCols[nCntFor,nVS3NUMLOT]) == AllTrim(cNumLot) .and. ;
				AllTrim(oGetPecas:aCols[nCntFor,nVS3LOTECT]) == AllTrim(cLoteCtl)
				
				If cFaseConfer $ cFaseOrc .or. "R" $ cFaseOrc .or. (oGetPecas:aCols[nCntFor,nVS3RESERV]=="1")
					MsgStop(STR0291+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0296+oGetPecas:aCols[nCntFor,fg_posvar("VS3_SEQUEN","aHeaderP")],STR0025)
					lDupOrc := .t.
					Return(.t.)
				Endif                                                   
				
			Endif
		Endif
	Next
EndIf

Return .f.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001SDUPL  | Autor |Rubens Takahashi       | Data | 21/01/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |Verifica se existe peca duplicada no Orcamento                |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001SDUPL(nAuxLinha, cSGruIte, cSCodIte, cSGruInc, cSCodInc, cSDesInc, cSSeqInc)

Local nCntFor, lRetorno

Default cSGruInc := ""
Default cSCodInc := ""
Default cSDesInc := ""
Default cSSeqInc := ""

lRetorno := .f.
for nCntFor := 1 to Len(oGetServ:aCols)
	if !(oGetServ:aCols[nCntFor,len(oGetServ:aCols[nCntFor])]) .and. nCntFor <> nAuxLinha

		if AllTrim(oGetServ:aCols[nCntFor,fg_posvar("VS4_GRUSER","aHeaderS")]) == AllTrim(cSGruIte) .and. ;
			AllTrim(oGetServ:aCols[nCntFor,fg_posvar("VS4_CODSER","aHeaderS")]) == AllTrim(cSCodIte)

			if lInconveniente
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for outro inconveniente, não esta duplicado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if AllTrim(oGetServ:aCols[nCntFor,fg_posvar("VS4_GRUINC","aHeaderS")]) == AllTrim(cSGruInc) .and. ;
					AllTrim(oGetServ:aCols[nCntFor,fg_posvar("VS4_CODINC","aHeaderS")]) == AllTrim(cSCodInc) .and. ;
					AllTrim(oGetServ:aCols[nCntFor,fg_posvar("VS4_DESINC","aHeaderS")]) == AllTrim(cSDesInc) .and. ;
					AllTrim(oGetServ:aCols[nCntFor,fg_posvar("VS4_SEQINC","aHeaderS")]) == AllTrim(cSSeqInc)

					Return .t.

				EndIf
			else

				Return .t.

			EndIf
		EndIf
	EndIf
next

Return .f.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001IDUPL  | Autor |Rubens Takahashi       | Data | 21/01/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |Verifica se existe peca duplicada no Orcamento                |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001IDUPL(nAuxLinha, cIGruInc, cICodInc, cIDesInc, cISeqInc)

Local nCntFor, lPesqSeq := .t.

if Type("cISeqInc") == "U"
	lPesqSeq := .f.
EndIf

for nCntFor := 1 to Len(oGetInconv:aCols)
	if !(oGetInconv:aCols[nCntFor,len(oGetInconv:aCols[nCntFor])]) .and. nCntFor <> nAuxLinha

		if oGetInconv:aCols[nCntFor,fg_posvar("VST_GRUINC","aHeaderI")] == cIGruInc .and. ;
			oGetInconv:aCols[nCntFor,fg_posvar("VST_CODINC","aHeaderI")] == cICodInc .and. ;
			oGetInconv:aCols[nCntFor,fg_posvar("VST_DESINC","aHeaderI")] == cIDesInc .and. ;
			( !lPesqSeq .or. ( lPesSeq .and. oGetInconv:aCols[nCntFor,fg_posvar("VST_SEQINC","aHeaderI")] == cISeqInc ))

			Return .t.

		endif
	endif
next

Return .f.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001VE6    | Autor |Manoel / Luis Delorme  | Data | 18/02/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |Reserva / Desreserva do Item no VE6                           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001VE6(cNumOrc,lRes)

Local cQuery, cQVE6 := "SQLVE6"
Local lFound := .f.

cQuery := "SELECT VE6.R_E_C_N_O_ VE6RECNO FROM "+RetSQLName("VE6")+" VE6 "
cQuery += " WHERE VE6.VE6_FILIAL = '"+xFilial("VE6")+"'"
cQuery +=   " AND VE6.VE6_NUMORC = '" + cNumOrc + "'"
cQuery +=   " AND VE6.VE6_GRUITE = '" + VS3->VS3_GRUITE + "'"
cQuery +=   " AND VE6.VE6_CODITE = '" + VS3->VS3_CODITE + "'"
cQuery +=   " AND VE6.VE6_LOTECT = '" + VS3->VS3_LOTECT + "'"
cQuery +=   " AND VE6.VE6_NUMLOT = '" + VS3->VS3_NUMLOT + "'"
cQuery +=   " AND VE6.VE6_INDREG = '3'" // Reserva de Item
cQuery +=   " AND VE6.VE6_ORIREQ = '1'" // Balcao
cQuery +=   " AND VE6.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQVE6, .F., .T. )

If !( cQVE6 )->( eof() )
	DbSelectArea("VE6")
	DbGoTo( ( cQVE6 )->( VE6RECNO ) )
	lFound := .t.
Endif

(cQVE6)->(dbCloseArea())

DbSelectArea("VE6")
If lRes
	If !lFound
		RecLock("VE6" , .T. )
		VE6->VE6_FILIAL := xFilial("VE6")
		VE6->VE6_GRUITE := VS3->VS3_GRUITE
		VE6->VE6_CODITE := VS3->VS3_CODITE
		VE6->VE6_LOTECT := VS3->VS3_LOTECT
		VE6->VE6_NUMLOT := VS3->VS3_NUMLOT
		VE6->VE6_CODMAR := Posicione("SBM",1, xFilial("SBM")+VS3->VS3_GRUITE,"SBM->BM_CODMAR")
		VE6->VE6_INDREG := "3" // Reserva de Item
		VE6->VE6_ORIREQ := "1" // Balcao
		VE6->VE6_DESORI := "BALCAO"
		VE6->VE6_NUMORC := cNumOrc
	Else
		RecLock("VE6" , .F. )
	Endif
	nQtdAgu := VS3->VS3_QTDAGU+VS3->VS3_QTDTRA
	VE6->VE6_VALPEC := VS3->VS3_VALPEC
	VE6->VE6_CODUSU := CriaVar("VE6_CODUSU")
	VE6->VE6_DATREG := dDataBase
	VE6->VE6_HORREG := CriaVar("VE6_HORREG")
	VE6->VE6_QTDITE := VS3->VS3_QTDITE - nQtdAgu // Quantidade Requisitada
	If lFound
		VE6->VE6_QTDATE := VS3->VS3_QTDCON // Quantidade Atendida
		//VE6->VE6_QTDEST := VE6->VE6_QTDITE-VS3->VS3_QTDCON // Quantidade Estornada
	Endif
	MsUnLock()
Else // Desreserva - Pode ser por Cancelamento ou Faturamento
	If lFound
		RecLock("VE6" , .F.,.T. )
		DbDelete()
		MsUnLock()
	Endif
Endif

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001TemPad | Autor | MIL                   | Data | 05/10/99 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |Encontra Tempo Padrao para o Servico / Modelo                 |##
##+----------+--------------------------------------------------------------+##
##|Parametros| cChaInt - Numero Interno de Chassi                           |##
##|          | cCodSer - Codigo do Servico a ser pesquisado                 |##
##|          | cIncTem - Incidencia de Tempo F=Fabrica C=Concessionaria     |##
##|          | cIncMob - Incidencia de Mao de Obra                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001TemPad(cMarca,cCodSer,cIncTem,cIncMob,cAplica,cControle)
//
cQryAl001 := GetNextAlias()
cQuery := "SELECT VO7_TEMFAB, VO7_TEMCON  FROM "+RetSqlName("VO7")+ " VO7"
cQuery += " WHERE VO7_FILIAL ='"+xFilial("VO7")+"' AND"
cQuery += " VO7_FILIAL ='"+xFilial("VO7")+"' AND"
cQuery += " VO7_CODSER ='"+cCodSer+"' AND"
cQuery += " (VO7_APLICA ='"+cAplica+"' OR VO7_APLICA ='999999') AND"
cQuery += " VO7_CONTRO ='"+cControle+"' AND"
cQuery += " D_E_L_E_T_=' ' ORDER BY VO7_APLICA"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
//
nTemFab := 0
nTemCon := 0
nTemPad := 0
if !(cQryAl001)->(eof())
	nTemFab := (cQryAl001)->(VO7_TEMFAB)
	nTemCon := (cQryAl001)->(VO7_TEMCON)
endif
(cQryAl001)->(dbCloseArea())
DBSelectArea("VV1")
//
Do Case
	Case (cIncTem == "1")
		nTemPad := nTemFab
	Case (cIncTem == "2")
		nTemPad := nTemCon
	Case (cIncTem == "4")
		nTemPad := nTemFab
	Case (cIncTem == "5")
		nTemPad := 0
EndCase

Return nTemPad
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OX001CEV ³ Autor ³ Andre Luis Almeida    ³ Data ³ 16/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geracao de CEV no Orcamento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTp = Tipo ('F'=Faturamento/'D'=Deletar/'C'=Cancelamento)  ³±±
±±³          ³ cOrcamto = Numero do Orcamento (VS1)                       ³±±
±±³          ³ cTipOrc = Tipo de Orcamento (VS1)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Orcamento Balcao/Oficina                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001CEV(cTp,cOrcamto,cTipOrc)
Local lVCM510CEV  := ExistFunc("VCM510CEV")
Local aCEV    := {}
Local cCEV    := ""
Local cObs    := ""
Local cSQL    := ""
Local ni      := 0
VS1->(DbSetOrder(1))
VS1->(DbSeek(xFilial("VS1")+cOrcamto))
If lVCM510CEV
	If cTp == "F"
		aCEV := VCM510CEV("1","","",cOrcamto) // 1 = Venda Balcao
	ElseIf cTp == "D"
		aCEV := VCM510CEV("1","","",cOrcamto) // 1 = Venda Balcao
	ElseIf cTp == "C"
		If cTipOrc == "2" // Oficina
			aCEV := VCM510CEV("8","","",cOrcamto) // 8 = Cancelamento Orcamento Oficina
		Else
			aCEV := VCM510CEV("2","","",cOrcamto) // 2 = Cancelamento Orcamento Balcao
		EndIf
	EndIf
Else // Temporario
	If cTp == "F" // GERAR CEV no FATURAMENTO
		cCEV := Alltrim(GetNewPar("MV_GCFBCEV",""))
	ElseIf cTp == "D" // DELETAR CEV gerado no FATURAMENTO
		cCEV := Alltrim(GetNewPar("MV_GCFBCEV",""))
	ElseIf cTp == "C" // GERAR CEV no CANCELAMENTO
		cCEV := Alltrim(GetNewPar("MV_GCCBCEV",""))
	EndIf
	If !Empty(cCEV)
		aCEV := {{substr(cCEV,1,1),Val(substr(cCEV,2,3)),substr(cCEV,5,6),Val(substr(cCEV,11,3))}}
	EndIf
EndIf
For ni := 1 to len(aCEV)
	If Empty(aCEV[ni,3])
		aCEV[ni,3] := VS1->VS1_CODVEN // Vendedor
	EndIf
	cCEV := "X"
	If cTp == "F" // Faturamento
		///////////////////////////////////////////////////////////////////////////////////////////////
		// CEV - Verificar se ja existe Agenda CEV para este Orcamento dentro da Qtde minima de dias //
		///////////////////////////////////////////////////////////////////////////////////////////////
		If aCEV[ni,4] > 0 // Qtde minima de dias necessaria para criar nova Agenda
			cSQL := "SELECT VC1.R_E_C_N_O_ AS RECVC1 FROM "+RetSQLName("VC1")+" VC1 WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND "
			cSQL += "VC1.VC1_TIPAGE='"+aCEV[ni,1]+"' AND "
			cSQL += "VC1.VC1_CODCLI='"+VS1->VS1_CLIFAT+"' AND VC1.VC1_LOJA='"+VS1->VS1_LOJA+"' AND "
			cSQL += "VC1.VC1_CODVEN='"+aCEV[ni,3]+"' AND "
			cSQL += "VC1.VC1_TIPORI='B' AND VC1.VC1_DATAGE>='"+dtos(dDataBase-aCEV[ni,4])+"' AND VC1.D_E_L_E_T_=' '"
			If FM_SQL(cSQL) > 0
				cCEV := "" // Nao Gerar Agenda na Finalizacao quando ja existe Agenda dentro da qtde minima de dias
			EndIf
		EndIf
		If !Empty( cCEV )
			cSQL := "SELECT SA3.A3_NOME FROM "+RetSQLName("SA3")+" SA3 WHERE SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD='"+VS1->VS1_CODVEN+"' AND SA3.D_E_L_E_T_=' '"
			cObs := STR0154 +": "+ cOrcamto +" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5)+STR0157+" - " // Orcamento FATURADO / hs
			cObs += STR0156+": "+VS1->VS1_CODVEN+" "+left(FM_SQL(cSQL),20) // Vendedor
		EndIf
	ElseIf cTp == "D" // Deletar CEV gerado no FATURAMENTO que ainda nao teve abordagem
		DbSelectArea("VC1")
		DbSetOrder(3) // VC1_FILIAL+VC1_TIPAGE+VC1_CODCLI+VC1_LOJA+DTOS(VC1_DATAGE)
		DbSeek( xFilial("VC1") + aCEV[ni,1] + VS1->VS1_CLIFAT + VS1->VS1_LOJA )
		Do While !Eof() .and. xFilial("VC1") == VC1->VC1_FILIAL .and. VC1->VC1_TIPAGE == aCEV[ni,1] .and. VC1->VC1_CODCLI + VC1->VC1_LOJA ==  VS1->VS1_CLIFAT + VS1->VS1_LOJA
			If VC1->VC1_TIPORI == "B" .and. Alltrim(VC1->VC1_ORIGEM) == Alltrim(cOrcamto) .and. Empty(VC1->VC1_DATVIS) .and. VC1->VC1_CODVEN == aCEV[ni,3]
				RecLock("VC1",.f.,.t.)
				DbDelete()
				MsUnlock()
			EndIf
			DbSelectArea("VC1")
			DbSkip()
		EndDo
		cCEV := "" // Ao DELETAR, nao gerar outro CEV
	ElseIf cTp == "C" // Cancelamento
		cObs := STR0155 +": "+ cOrcamto +" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5)+STR0157 // Orcamento CANCELADO / hs
		VS0->(DbSetOrder(1))
		VS0->(DbSeek(xFilial("VS0")+"000004"+VS1->VS1_MOTIVO))
		If !Empty(VS0->VS0_USURES)
			aCEV[ni,3] := VS0->VS0_USURES // Vendedor Responsavel
		EndIf
		cObs += " - "+STR0128+": "+Alltrim(VS0->VS0_DESMOT) // Motivo
	EndIf
	If !Empty( cCEV )
		////////////////////////////////////
		// CEV - Geracao de Agenda        //
		////////////////////////////////////
		FS_AGENDA( aCEV[ni,1] , ( dDataBase+aCEV[ni,2] ) , aCEV[ni,3] , VS1->VS1_CLIFAT , VS1->VS1_LOJA , "" , cOrcamto , "" , cObs , "" , "" )
	EndIf
Next
DbSelectArea("VS1")
Return()
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001GSUG   | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Funcao que faz a chamada da rotina de sugestao de compra     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001GSUG(nOpc, lRegBo)
// Declaração das Variáveis Necessárias
Local nCntFor
Local xAutoInc := {}
//
Local cPictQtd := VS3->(X3PICTURE("VS3_QTDITE"))
//
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lFaseReserv := At("R",GetNewPar("MV_FASEORC","0FX")) > 0
Local lOPM900Perg  := .f. // Tratamento dentro do OFIPM900 para verificar se ja foi chamado nao chamar novamente a tela de paramentros e numeração da sugestão de compra.
Local lOPM900Rel   := .f.
Local cMarVEJ      := ""
Local cTipPed      := ""
Local aTipPed      := {}
Local nTipPed      := GetSX3Cache("VEJ_TIPPED","X3_TAMANHO")
Local lNewRes      := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?

Local cCodMar       := ""

Local nQtSugC      := 0

Private oTik    := LoadBitmap( GetResources(), "LBTIK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )

Default lRegBO := .F.

If !OX0010325_ValidaGeracaoSugestaoCompra()
	Return
Endif

aSugest := {}

for nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
next
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0,  0, .T. , .T. } )
aPos := MsObjSize( aInfo, aObjects )
//
if lNewRes .and. lRegBo
	OX001GRV(nOpc,.t.,,.t.,.f.,,.F.,.t.)
Else
	OX001GRV(nOpc,.t.,,,.f.,,.F.,.t.)
EndIf
//
for nCntFor = 1 to Len(oGetPecas:aCols)

	SF4->(dbseek(xFilial("SF4")+oGetPecas:aCols[nCntFor,fg_posvar("VS3_CODTES","aHeaderP")]))

	// pula registros deletados
	if !oGetPecas:aCols[nCntFor,Len(oGetPecas:aCols[nCntFor])] .and.;
		SF4->F4_ESTOQUE == "S" .and.;
		oGetPecas:aCols[nCntFor,fg_posvar("VS3_QTDAGU","aHeaderP")] == 0 .and.;
		oGetPecas:aCols[nCntFor,fg_posvar("VS3_QTDTRA","aHeaderP")] == 0

		lContinua := .f.
		if !lPediVenda .OR. lRegBO // se for registrar backorder pode fazer sim sugs. compra nao sendo pedido de venda

			nQtSugC := oGetPecas:aCols[nCntFor,fg_posvar("VS3_QTDITE","aHeaderP")] - oGetPecas:aCols[nCntFor,fg_posvar("VS3_QTDEST","aHeaderP")] - oGetPecas:aCols[nCntFor,fg_posvar("VS3_QTDRES","aHeaderP")]

			if nQtSugC > 0
				DBSelectArea("SB1")
				DBSetOrder(7)
				DBSeek(xFilial("SB1")+oGetPecas:aCols[nCntFor,fg_posvar("VS3_GRUITE","aHeaderP")]+oGetPecas:aCols[nCntFor,fg_posvar("VS3_CODITE","aHeaderP")])
				//
				DBSelectArea("SBM")
				DBSetOrder(1)
				DBSeek(xFilial("SBM")+SB1->B1_GRUPO)
				//
				aAdd(aSugest, { .t., ;
				oGetPecas:aCols[nCntFor,fg_posvar("VS3_GRUITE","aHeaderP")] ,;
				oGetPecas:aCols[nCntFor,fg_posvar("VS3_CODITE","aHeaderP")] ,;
				SB1->B1_DESC,;
				oGetPecas:aCols[nCntFor,fg_posvar("VS3_QTDITE","aHeaderP")] - oGetPecas:aCols[nCntFor,fg_posvar("VS3_QTDEST","aHeaderP")] - oGetPecas:aCols[nCntFor,fg_posvar("VS3_QTDRES","aHeaderP")],;
				SBM->BM_CODMAR,;
				oGetPecas:aCols[nCntFor,fg_posvar("VS3_VALPEC","aHeaderP")] ,;
				oGetPecas:aCols[nCntFor,fg_posvar("VS3_QTDEST","aHeaderP")] ,;
				VS1->VS1_FILIAL+VS1->VS1_NUMORC+oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_SEQUEN","aHeaderP")],; // se alterar isso avisar manoel/vinicius, esse campo é usado abaixo com right
				nCntFor,;
				.t.,;
				SB1->B1_COD,;
				oGetPecas:aCols[nCntFor,FG_POSVAR("VS3_SEQUEN","aHeaderP")],;
				oGetPecas:aCols[nCntFor,fg_posvar("VS3_QTDITE","aHeaderP")],;
				oGetPecas:aCols[nCntFor,fg_posvar("VS3_QTDRES","aHeaderP")] } )

				If At(cCodMar,"'"+SBM->BM_CODMAR+"',") == 0
					cCodMar += "'"+SBM->BM_CODMAR+"',"
				EndIf

			endif
		endif

	endif
next

If lNewRes

	if OX0010325_ValidaGeracaoSugestaoCompra(.f.,aSugest,lRegBO)
		OX0010285_GeracaoSugestaoCompra(nOpc,aSugest,lRegBO,cCodMar,lFaseReserv)
	EndIf

	Return
Else

	//
	If lRegBo .AND. Empty(aSugest)
		MsgStop(STR0310  /* "Nenhum item passível de BackOrder detectado nos itens do pedido/orçamento" */, STR0025 /*Atenção*/)
		Return
	ElseIf Empty(aSugest)
		MsgStop(STR0193,STR0025) // Não existe peça em falta no orçamento atual./ Atenção
		return
	EndIf

	If !MsgYesNo(STR0373, STR0025) // A criação da Sugestão de Compras de Peças implicará na reserva das peças disponíveis em estoque e avançará a fase do orçamento, não sendo mais possível alterá-lo. Deseja Continuar?
		return
	Endif

	//
	cQryAl001 := GetNextAlias()
	cQuery := "SELECT COUNT(R_E_C_N_O_) SOMA FROM "+RetSqlName("VE6")
	cQuery += " WHERE VE6_FILIAL ='"+xFilial("VE6")+"' AND"
	cQuery += " VE6_NUMORC ='"+VS1->VS1_NUMORC+"' AND"
	cQuery += " D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
	nSomaVE6 := (cQryAl001)->(SOMA)
	(cQryAl001)->(dbCloseArea())
	//
	if nSomaVE6 > 0
		if !MsgYesNo(STR0194,STR0025) // Ja foi gerada solicitação para este orçamento. Deseja gerar nova solicitação? / Atenção
			return
		endif
	endif

	If ( ExistBlock("OX001SUG") )
		aIncBot := ExecBlock("OX001SUG",.f.,.f.,{aIncBot})
	EndIf

	//
	nOpcao := 1
	cForPed := ""
	aRStatus := {STR0195,STR0196,STR0197,STR0198} // 0=Não Programado / 1=Programado / 2=Unidade Parada / 3=Emergencia
	DEFINE MSDIALOG oSugest TITLE STR0199 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Peças para Solicitação de Compra

	@ aPosObj[1,1]+05,10 SAY STR0200  SIZE 120,8 OF oSugest PIXEL COLOR CLR_BLUE // Forma de Pedido
	@ aPosObj[1,1]+04,60 COMBOBOX oLimite  VAR cForPed ITEMS aRStatus SIZE 80,8 OF oSugest  PIXEL

If lRegBO // registra backorder( peças de orçamento em pedido, é usado no DPM )
	For nCntFor := 1 to Len(aSugest)
		If aSugest[nCntFor,1] // selecionou no listbox
			cMarVEJ += IIf(!Empty(cMarVEJ),",","")
			cMarVEJ += "'"+aSugest[nCntFor,6]+"'"
		EndIf
	Next
	cTipPed := GetNewPar("MV_MIL0064","") // Se existir conteudo no parametro, será utilizado de forma fixa. Caso contrário, será necessário seleção por parte do usuario.
	cQuery := "SELECT DISTINCT VEJ_TIPPED , VEJ_DESCRI "
	cQuery += "  FROM "+RetSqlName("VEJ")
	cQuery += " WHERE VEJ_FILIAL = '"+xFilial("VEJ")+"'"
	cQuery += "   AND VEJ_CODMAR IN ("+cMarVEJ+")"
	If !Empty(cTipPed)
		cQuery += " AND VEJ_TIPPED = '"+left(cTipPed,nTipPed)+"'"
	EndIf
	cQuery += "   AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
	while !( ( cQryAl001 )->(eof()) )
		aAdd( aTipPed , ( cQryAl001 )->( VEJ_TIPPED )+"="+( cQryAl001 )->( VEJ_DESCRI ) )
		( cQryAl001 )->( dbSkip() )
	enddo
	( cQryAl001 )->( dbCloseArea() )
	DbSelectArea("VEJ")
	@ aPosObj[1,1]+05,190 SAY STR0398 SIZE 150,8 OF oSugest PIXEL COLOR CLR_BLUE // Tipo Pedido
	@ aPosObj[1,1]+04,235 COMBOBOX oTipPed VAR cTipPed ITEMS aTipPed SIZE 165,8 OF oSugest  PIXEL
EndIf

@ aPos[1,1]+25,aPos[1,2] LISTBOX oLboxFAI FIELDS HEADER;
	"" ,;
	STR0201 , ; // Grupo
	STR0202 , ; // Código do Item
	STR0203 , ; // Descrição
	STR0324 , ; // Qtde Estoque
	STR0325 , ; // Qtde Dig.Orçamento
	STR0204   ; // Qtde Solicitada
	COLSIZES 10,30,50,90,70,70,70  SIZE aPos[1,4],aPos[1,3]-52 OF oSugest PIXEL ON DBLCLICK (aSugest[oLboxFAI:nAt,1] := ! aSugest[oLboxFAI:nAt,1] , oLboxFAI:Refresh(), .t. )

oLboxFAI:SetArray(aSugest)
oLboxFAI:bLine := { || { IIF(aSugest[oLboxFAI:nAt,01],oTik,oNo),;
	aSugest[oLboxFAI:nAt,02],;
	aSugest[oLboxFAI:nAt,03],;
	aSugest[oLboxFAI:nAt,04],;
	FG_AlinVlrs(Transform(aSugest[oLboxFAI:nAt,08],cPictQtd)) ,;
	FG_AlinVlrs(Transform(aSugest[oLboxFAI:nAt,05]+aSugest[oLboxFAI:nAt,08],cPictQtd)) ,;
	FG_AlinVlrs(Transform(aSugest[oLboxFAI:nAt,05],cPictQtd)) }}
oLboxFAI:bLDblClick := { || OX001019B_ValidaMarcacaoSugCompra(oLboxFAI:aArray[oLboxFAI:nAt, 1]) }

	ACTIVATE MSDIALOG oSugest CENTER ON INIT (EnchoiceBar(oSugest, { || ( nOpcao:=1 , oSugest:End() ) } , { || ( nOpcao:=2 , oSugest:End() ) },,aIncBot))
	//
	if nOpcao == 2
		MsgInfo(STR0205 ,STR0025) // Não foi gerada sugestão de compra para os itens / Atenção
		return
	endif
	//
	cForPed := Left(cForPed,1)
	//
	lSelAlgum := .f.
	Begin TRANSACTION

		lAguardar := .f.
		if Len(aSugest) > 0
			if MsgYesNo(STR0223) // Deseja aguardar a chegada das peças solicitadas?
				lAguardar := .t.
			Endif
		Endif

cOPM900Sug  := ""
for nCntFor := 1 to Len(aSugest)
	if aSugest[nCntFor,1] // selecionou no listbox
		lSelAlgum := .t.
		lAchou := .f.
		DBSelectArea("VEJ")
		DBSetOrder(1)
		if DBSeek(xFilial("VEJ")+aSugest[nCntFor,6])
			while xFilial("VEJ")+aSugest[nCntFor,6] == VEJ->VEJ_FILIAL + VEJ->VEJ_CODMAR
				if VEJ->VEJ_PROGRA == cForPed .and. VEJ->VEJ_PEDOSV != "1" .and. ( !lRegBO .or. left(cTipPed,nTipPed) == VEJ->VEJ_TIPPED )
					lAchou := .t.
					exit
				endif
				DBSKip()
			enddo
		endif
		if !lAchou
			MsgInfo(STR0206  + aSugest[nCntFor,6]+"."+CHR(10)+CHR(13)+; // Não existe tipo de pedido da forma escolhida para a marca
			STR0207 ,STR0025) // Cadastre um Tipo de Pedido que não peça OS e tente gerar a sugestão novamente / Atenção
			disarmTransaction()
			return .f.
		endif
		// Inclusão dos campos e valores manuais {"CAMPO", "VALOR", Nil}
		xAutoInc := {}
		aAdd( xAutoInc,{"VE6_FILIAL", xFilial("VE6")} )
		aAdd( xAutoInc,{"VE6_CODMAR", aSugest[nCntFor,6]} )
		aAdd( xAutoInc,{"VE6_GRUITE", aSugest[nCntFor,2]} )
		aAdd( xAutoInc,{"VE6_CODITE", aSugest[nCntFor,3]} )
		aAdd( xAutoInc,{"VE6_QTDITE", aSugest[nCntFor,5]} )
		aAdd( xAutoInc,{"VE6_VALPEC", aSugest[nCntFor,7]} )
		aAdd( xAutoInc,{"VE6_NUMORC", VS1->VS1_NUMORC} )

		If lRegBO // registra backorder( peças de orçamento em pedido, é usado no DPM )
			aAdd( xAutoInc,{"VE6_FORPED" , cTipPed             })
			aAdd( xAutoInc,{"VE6_INDREG" , "4"                 }) // este 4 vem do CBOX do X3 significa BackOrder
			aAdd( xAutoInc,{"VE6_ORIREQ" , "3"                 }) // este 3 vem do CBox do X3 significa Pedido de Orçamento
			aAdd( xAutoInc,{"VE6_DESORI" , "BACKORDER"         })
			aAdd( xAutoInc,{"VE6_ITEORC" , Right( aSugest[nCntFor, 9] ,TamSX3('VS3_SEQUEN')[1]) })
		Else // não backorder
			aAdd( xAutoInc,{"VE6_INDREG", "0"} )
			aAdd( xAutoInc,{"VE6_FORPED", VEJ->VEJ_TIPPED} )
			aAdd( xAutoInc,{"VE6_ORIREQ" , "1"} )
		EndIf
		//
		if lFaseReserv .OR. lRegBO // e tem fase R lReg
			if lAguardar
				DBSelectArea("VS3")
				DBSetOrder(1)
				if DBSeek(aSugest[nCntFor,9])
					reclock("VS3",.f.)
					VS3_QTDAGU := aSugest[nCntFor,5]
					msunlock()
					oGetPecas:aCols[aSugest[nCntFor,10],nVS3QTDAGU] := aSugest[nCntFor,5]
				endif
			endif
		endif
		nTmp := n
		aColsSav := aClone(aCols)
		aHeaderSav := aClone(aHeader)
		If !OFMI900("VE6",0,3,xAutoInc,.t.,.f.,OemToAnsi(STR0123),,.t.,lOPM900Perg,@lOPM900Rel)
			disarmTransaction()
			return .F.
		Endif
		n       := nTmp
		aCols   := aClone(aColsSav)
		aHeader := aClone(aHeaderSav)
		//
		lOPM900Perg := .t.
		aSugest[nCntFor,11] := lOPM900Rel
		if VEJ->VEJ_PROGRA == "2" .and. !lRegBO // Quando for 'Unidade Parada' e nao for BACKORDER gera um relatorio para cada sugestao de compra separadamente
			OX001RSC(aSugest)
			aSugest[nCntFor,11] := .f.
		Endif

				oGetPecas:oBrowse:refresh()
			endif
		next
		//
		// reserva do que tem saldo
		//
		if lFaseReserv .OR. lRegBO
			//OX001RESITE(VS1->VS1_NUMORC, .t.)
			__ReadVar := "M->VS1_RESERV"
			M->VS1_RESERV := '1'
			OX001VLDENC(,,.F.)
		endif

	End Transaction

EndIf

if !Empty(cOPM900Sug)
	MsgInfo(STR0320+CHR(13)+ CHR(10)+STR0321+cOPM900Sug) // Sugestao de compra gerado / Nro:
Endif
//

if !lSelAlgum
	return .f.
endif
if VEJ->VEJ_PROGRA <> "2" .or. lRegBO // Quando nao for 'Unidade Parada' ou for BACKORDER gera relatorio para sugestao de compra gerada como era antes
	OX001RSC(aSugest)
Endif
//
MsgInfo(STR0208,STR0025) // As peças selecionadas foram solicitadas para compra / Atenção
//
OX001GRV(nOpc,.t.,,,,,.F.)

If lFaseReserv .OR. lRegBO
	OX001FAT(nOpc,,.F.)
Endif
//
return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX001RSC   | Autor |  Luis Delorme         | Data | 17/04/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Relatorio Simples com peças sugeridas no orçamento           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001RSC(aSugest)

Local cDesc1	 := ""
Local cDesc2	 := ""
Local cDesc3	 := ""
Local cAlias	 := "SF2"

Default aSugest := {}

Private nLin 	 := 1
Private aReturn := { STR0220, 1,STR0221, 2, 2, 1, "",1 } //"Zebrado # Administracao
Private cTamanho:= "P"          // P/M/G
Private Limite  := 80           // 80/132/220
Private aOrdem  := {}          // Ordem do Relatorio
Private nCaracter:=15
Private cTitulo := STR0209 +Alltrim(VS1->VS1_NUMORC)
Private cNomProg:= "OX001RSC"
Private cNomeRel:= "OX001RSC"
Private cabec1  := STR0210
Private cabec2  := ""
Private nLastKey:= 0

IF ExistBlock("OX001RSUG")// PE para que substitui a impressão padrão.
	ExecBlock("OX001RSUG",.f.,.f.,{VS1->VS1_NUMORC,aSugest})
	Return
Endif

cNomeRel := SetPrint(cAlias,cNomeRel,NIL,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| FS_RELATO(@lEnd,cNomeRel,cAlias,aSugest) } , cTitulo )
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf

Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | FS_RELATO  | Autor |  Luis Delorme         | Data | 17/04/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Relatorio Simples com peças sugeridas no orçamento           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_RELATO(lEnd,wNRel,cAlias,aSugest)

Local nCntFor
Local aArea := {}
Local aImpSug := aClone(aSugest)

Private nLin := 1
Private cString:= "VV1"
Private cTamanho:= "M"           // P/M/G
Private Li     := 132
Private m_Pag	:= 1
Private lAbortPrint := .f.
Private aRet 	:= {}

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

SetRegua(13)

IncRegua()

aArea := sGetArea(aArea , "SB1")
aArea := sGetArea(aArea , "SB2")
aArea := sGetArea(aArea , "SA3")
aArea := sGetArea(aArea , "SA1")

SA1->(DBSetOrder(1))
SA1->(DBSeek(xFilial("SA1")+M->VS1_CLIFAT + M->VS1_LOJA))
SA3->(DBSetOrder(1))
SA3->(DBSeek(xFilial("SA3")+M->VS1_CODVEN))

SB2->(dbsetorder(1))
SB1->(dbsetorder(7))

nLin := cabec(cTitulo,cabec1,cabec2,cNomProg,ctamanho,nCaracter) + 1
aSort(aImpSug,,,{|x,y| x[2]+x[3] < y[2]+y[3] })
for nCntFor := 1 to Len(aImpSug)

	if aImpSug[nCntFor,1]
		if !aImpSug[nCntFor,11]
			Loop
		Endif
		if nLin > 55
			nLin := cabec(cTitulo,cabec1,cabec2,cNomProg,ctamanho,nCaracter) + 1
			nLin +=1
		endif
		SB1->(dbseek(xFilial("SB1")+aImpSug[nCntFor,02]+aImpSug[nCntFor,03]))
		SB2->(dbseek(xFilial("SB2")+SB1->B1_COD+OX0010105_ArmazemOrigem()))
		@ nLin++ , 00 psay aImpSug[nCntFor,02]+"  "+aImpSug[nCntFor,03]+" "+aImpSug[nCntFor,04]+" "+Transform(aImpSug[nCntFor,05], "@E 999,999,999.99")+" "+Transform(SB2->B2_SALPEDI,"@E 999,999,999.99")
	endif

next

if nLin > 55
	nLin := cabec(cTitulo,cabec1,cabec2,cNomProg,ctamanho,nCaracter) + 1
	nLin +=1
endif

nLin +=5
@ nLin++ , 00 PSAY RetTitle("VS1_NUMORC") + " : " +M->VS1_NUMORC + "      " + RetTitle("VS1_CODVEN") + " : " +M->VS1_CODVEN + " - " + SA3->A3_NREDUZ
nLin +=1
@ nLin++ , 00 PSAY RetTitle("VS1_NCLIFT") + " : " + SA1->A1_COD + " / " + SA1->A1_LOJA + " - " + SA1->A1_NOME
nLin +=1
@ nLin++ , 00 PSAY RetTitle("VE6_SUGCOM") + " : " + VEJ->VEJ_ULTPED + "        " +  RetTitle("VEJ_TIPPED") + " : " + VEJ->VEJ_TIPPED + " - "  + VEJ->VEJ_DESCRI

IncRegua()

Ms_Flush()
Set Printer to
Set Device  to Screen
Return


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OX001VALTT³ Autor ³ Boby-Antonio          ³ Data ³ 23/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao para tipo de tempo com tipo de serviço associado,³±±
±±³          ³ nao aceitar TS q nao esteja associado ao TT - FNC 18962    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Siga Oficina                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function OX001VALTT()

LOCAL aArea := GetArea()
Local lRet  := .T.

If !Empty(M->VS1_TIPTEM)
	DbSelectArea("VOX")
	DbSetOrder(1)
	If !DBSeek(xFilial("VOX")+M->VS4_TIPSER+M->VS1_TIPTEM )
		MsgInfo(STR0160,STR0025) //"Tipo de serviço não está associado ao tipo de tempo!","Atenção"
		lRet:=.F.
	EndIf
EndIf

RestArea(aArea)
Return lRet


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OFXX01V2UM³ Autor ³ Boby-Antonio          ³ Data ³ 25/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao para limpar campo de qtde 2UM ao trocar de cod.  ³±±
±±³          ³ item de produto (VS3_CODITE)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Siga Oficina                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function OFXX01V2UM()

if M->VS3_QTD2UM <> 0
	oGetPecas:aCols[oGetPecas:nAt,fg_posvar("VS3_QTD2UM","aHeaderP")]:= M->VS3_QTD2UM := 0
	oGetPecas:oBrowse:refresh()
endif

Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001INCOBR | Autor | Rubens Takahashi      | Data | 30/08/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Validacao se é obrigatorio usar inconveniente                |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OX001INCOBR()

Local nPos
Local nPosVSTDESINC := FG_POSVAR("VST_DESINC","aHeaderI")

For nPos := 1 to Len(oGetInconv:aCols)
	If !oGetInconv:aCols[nPos,Len(oGetInconv:aCols[nPos])] .and. !Empty(oGetInconv:aCols[nPos,nPosVSTDESINC])
		Return .t.
	EndIf
Next nPos

If !lOX001Auto
	MsgInfo(STR0161)
EndIf

Return .f.

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o      OX001LDOFI Autor ³ Luis Delorme          ³ Data ³ 25/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica margem de desconto e margem de lucro em orçamentos³±±
±±³          ³ de oficina                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Siga Oficina                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function OX001LDOFI(_cNumOrc,lGeraLib)
Local nCntFor2
Local lProbDesPec := .f.
Local lProbDesSer := .f.

Local nPDescUsu   := 0
Local nVS1PERREM  := 0
Local cVS1CONPRO  := "2"
Local dDatRefPD   := dDataBase
Local cPesqPromo  := ""

Local lTemProbl   := .f.
Local lLiberacao  := .t.

Default lGeraLib  := .t.

Private lPrecoFixo := .f. // Preco Fixo - variavel manipulada no OFIXX005 (OX005PERDES)

// ##############################
// # VERIFICA MARGEM DE LUCRO   #
// ##############################
cNumOrc   := _cNumOrc
aIDescont := {} // Desconto de Pecas
aIDesconS := {} // Desconto de Servicos

VS1->(DBSetOrder(1))

If !(VS1->(DBSeek(xFilial("VS1") + _cNumOrc)))
	return .f.
EndIf

If VS1->VS1_TIPORC != "2"
	return .t.
EndIf

If GetNewPar("MV_VMLOROF","S") == "N" // Verifica margem de lucro na exportação do orçamento oficina
	return .t.
EndIf

If VS1->(FieldPos("VS1_PERREM")) > 0
	nVS1PERREM := VS1->VS1_PERREM
	cVS1CONPRO := VS1->VS1_CONPRO
EndIf

SA1->(DbSetOrder(1))
SA1->(MsSeek(xFilial("SA1") + VS1->VS1_CLIFAT + VS1->VS1_LOJA))

DBSelectArea("VS3")
DBSetOrder(1)
DBSeek(xFilial("VS3")+cNumOrc)

lProbDesPec := .f.
lProbDesSer := .f.

// ##############################################################
// # PONTO DE ENTRADA PARA CUSTOMIZACAO DA MARGEM DE LUCRO PECAS#
// ##############################################################
If ExistBlock("OXA012LP")
	aIDescont := ExecBlock("OXA012LP", .f., .f., {cNumOrc})

	For nCntFor2 := 1 to Len(aIDescont)
		If !aIDescont[nCntFor2]
			lProbDesPec := .t.
			Exit
		EndIf
	Next
Else

	VAI->(DBSetOrder(4))
	If VAI->(DBSeek(xFilial("VAI")+__cUserID))
		If VAI->(FieldPos("VAI_DESPEC")) > 0 // Tem % de Desconto Default para o Vendedor
			nPDescUsu := VAI->VAI_DESPEC
		EndIf
		If VAI->(FieldPos("VAI_DTCDES")) > 0 // Data para validar a Politica de Desconto
			If VAI->VAI_DTCDES == "1" // Utilizar 1=Data de Inclusão do Orçamento para validar a Politica de Desconto
				dDatRefPD := VS1->VS1_DATORC
			EndIf
		EndIf
	EndIf

	// Le Pecas
	While !eof() .and. xFilial("VS3") + VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
		//If VS3->VS3_PERDES > 0
		SF4->(dbseek(xFilial("SF4") + VS3->VS3_CODTES))

		If SF4->F4_OPEMOV == "05"
			/* --------------------------------------------
			Conforme CI 007720 (337), foi analisado e decidido que a Marca da Peça deve ser diretamente
				comparada com a Marca do Grupo de Desconto ao invés da Marca do Veículo (Chassi).
			-------------------------------------------- */
			//DBSelectArea("SB1")
			//DBSetOrder(7)
			//DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE)
			
			lPrecoFixo := .f. // Preco Fixo - variavel manipulada no OFIXX005 (OX005PERDES)

			SBM->(dbSetOrder(1))
			SBM->(dbSeek(xFilial("SBM") + VS3->VS3_GRUITE))

			cPesqPromo := IIf( cPesqPromo <> "0" .and. nVS3PESPRO > 0 .and. VS3->VS3_PESPRO == "0" , "0" , cVS1CONPRO )

			SB1->( dbSetOrder(7) )
			SB1->( dbSeek( xFilial("SB1") + VS3->VS3_GRUITE + VS3->VS3_CODITE ) )
			SB1->( dbSetOrder(1) )

			SB2->( dbSetOrder(1) )
			SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + VS3->VS3_LOCAL ) )

			lRetDes := OX005PERDES(;
				SBM->BM_CODMAR,;
				VS1->VS1_CENCUS,;
				VS3->VS3_GRUITE,;
				VS3->VS3_CODITE,;
				VS3->VS3_QTDITE,;
				VS3->VS3_PERDES,;
				.t.,;
				VS1->VS1_CLIFAT,;
				VS1->VS1_LOJA,;
				IIF(VS1->VS1_TIPORC == "2", "3", VS1->VS1_TIPVEN),;
				VS3->VS3_VALTOT / VS3->VS3_QTDITE,;
				,;
				VS1->VS1_FORPAG,,,,cPesqPromo,dDatRefPD,nVS1PERREM)
			
			// Se teve problema de Desconto utilizando a Politica de Desconto
 			// Verifica se o % de desconto default do Vendedor é maior ou igual ao da Peça
			// Deixa passar devido ao % minimo permitido para o Vendedor.
			lRetDes := IIf( !lRetDes .and. nPDescUsu >= VS3->VS3_PERDES+nVS1PERREM , .t. , lRetDes )


			aAdd(aIDescont, lRetDes)

			If ( !lRetDes .and. VS3->VS3_VALDES != 0 ) .or. ( !lRetDes .and. lPrecoFixo ) // Problema de Desconto ou Abaixo do Preco Fixo
				lProbDesPec := .t.
			EndIf
		EndIf

		DBSelectArea("VS3")
		DBSkip()
	EndDo
EndIf

// #################################################################
// # PONTO DE ENTRADA PARA CUSTOMIZACAO DA MARGEM DE LUCRO SERVICOS#
// #################################################################
If ExistBlock("OXA012LS")
	aIDesconS := ExecBlock("OXA012LS", .f., .f., {cNumOrc})

	For nCntFor2 := 1 to Len(aIDesconS)
		If !aIDesconS[nCntFor2]
			lProbDesSer := .t.
			Exit
		EndIf
	Next
Else
	// Le servicos
	DBSelectArea("VS4")
	DBSetOrder(1)
	DBSeek(xFilial("VS4") + cNumOrc)

	While !eof() .and. xFilial("VS4") + VS1->VS1_NUMORC == VS4->VS4_FILIAL + VS4->VS4_NUMORC
		VOK->(dbSetOrder(1))
		VOK->(dbSeek(xFilial("VOK") + VS4->VS4_TIPSER))

		lRetDes := (VOK->VOK_PERMAX >= VS4->VS4_PERDES)

		aAdd(aIDesconS, lRetDes)

		if !lRetDes
			lProbDesSer := .t.
		EndIf

		DBSelectArea("VS4")
		DBSkip()
	EndDo
EndIf

lTemProbl := lProbDesPec .or. lProbDesSer

If lTemProbl
	// Procura Liberacao de Venda ...
	cSQL := "SELECT COUNT(*) "
	cSQL +=  " FROM " + RetSQLname("VS6") + " VS6"
	cSQL += " WHERE VS6_FILIAL = '" + xFilial("VS6") + "'"
	cSQL +=   " AND VS6_NUMORC = '" + cNumOrc + "'"
	cSQL +=   " AND ( VS6_NUMIDE = '" +VS1->VS1_NUMLIB+ "' OR VS6_NUMIDE = '" +VS1->VS1_NUMLIS+ "' )"
	cSQL +=   " AND VS6_DATAUT <> ' ' "
	cSQL +=   " AND D_E_L_E_T_ = ' ' "

	If FM_SQL(cSQL) > 0
		lTemProbl := .f.
		MsgInfo(STR0367,STR0025)//Venda Liberada /Atenção
	EndIf

EndIf

If lTemProbl
	If lGeraLib
		lLiberacao := OX001GERLB()
		If ExistBlock("OX001GLB")
			If ExecBlock("OX001GLB")
				lLiberacao := OX001LDOFI(cNumOrc,.f.)
			EndIf
		EndIf
	Else
		
		lLiberacao := .f.
	EndIf
EndIf

return lLiberacao

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o      OX001GERLB Autor ³ Renato Vinicius       ³ Data ³ 16/05/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geração da solicitação de liberação de desconto e margem   ³±±
±±³          ³ de lucro em orçamentos de oficina                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Siga Oficina                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function OX001GERLB()

	Local lGeraSep    := (GetNewPar("MV_GLIBVEN","N") == "S")
	Local lConfLib
	Local lVS7SemProb := AllTrim(GetNewPar("MV_MIL0131", "0")) == "1" // Cria/Mostra VS7 de todos os Itens se pelo menos 1 tiver problema de Margem ou Desconto
	Local nVS1PERREM  := 0
	Local cVS1CONPRO  := "2"
	Local dDatRefPD   := dDataBase
	Local cPesqPromo  := ""
	
	n_Opcao := Aviso(STR0025, STR0081, {STR0082, STR0083}, 2) // Atenção / Existem itens com margem/desconto nao permitido! / Cancela / Pede Lib.
	If n_Opcao == 1
		return .f.
	EndIf

	lConfLib 	:= .f.
	aMemos2  	:= {{"VS6_OBSMEM", "VS6_OBSERV"}}
	oFonteVS6  	:= TFont():New( "Arial", 8, 14 )
	cObservVS6 	:= space(TamSx3("VS6_OBSERV")[1])

	DEFINE MSDIALOG oDlgVS6 TITLE OemtoAnsi(STR0085) FROM 02,04 TO 14,56 OF oMainWnd // Pedido de Liberacao de Venda

	DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (lConfLib := .t. , oDlgVS6:End()) ENABLE OF oDlgVS6
	DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (lConfLib := .f. , oDlgVS6:End()) ENABLE OF oDlgVS6

	@ 01,011 GET oObserv VAR cObservVS6 OF oDlgVS6 MEMO SIZE 182,67 PIXEL

	oObserv:oFont := oFonteVS6
	oObserv:bRClicked := {|| AllwaysTrue() }
	oObserv:SetFocus()

	ACTIVATE MSDIALOG oDlgVS6 CENTER

	If !lConfLib
		return .f.
	EndIf

	cNumLib := ""

	Begin Transaction
		// Existe Peca com Problema de Desconto
		If aScan( aIDescont, .f. ) <> 0

			If VS1->(FieldPos("VS1_PERREM")) > 0
				nVS1PERREM := VS1->VS1_PERREM
				cVS1CONPRO := VS1->VS1_CONPRO
			EndIf

			// Grava Cabecalho da Liberacao de Venda
			If Empty(cNumLib) .or. lGeraSep
				OX001OFVS6("P",nVS1PERREM)
				cNumLib := VS6->VS6_NUMIDE
			EndIf

			dbSelectArea("VS1")

			RecLock("VS1", .f.)

			M->VS1_NUMLIB   := cNumLib
			VS1->VS1_NUMLIB := cNumLib

			MsUnlock()

			//Pecas
			DBSelectArea("VS3")
			DBSetOrder(1)
			DBSeek(xFilial("VS3") + cNumOrc)

			nItVS7 := 0
			
			While !eof() .and. xFilial("VS3") + VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
				If FM_SQL(" SELECT F4_OPEMOV FROM " + retSqlName("SF4") + " WHERE F4_FILIAL = '"+ xFilial("SF4") +"' AND F4_CODIGO = '" + VS3->VS3_CODTES + "' AND D_E_L_E_T_ = ' ' ") <> "05"
					VS3->(DbSkip())
					Loop
				Endif
				nItVS7++

				If !(aIDescont[nItVS7]) .or. lVS7SemProb // Cria VS7 de todos os Itens se pelo menos 1 tiver problema de Margem ou Desconto

					//Atribui a variavel "nDesPer" o Desconto Permitido
					SBM->(dbSetOrder(1))
					SBM->(dbSeek(xFilial("SBM") + VS3->VS3_GRUITE))

					cPesqPromo := IIf( cPesqPromo <> "0" .and. nVS3PESPRO > 0 .and. VS3->VS3_PESPRO == "0" , "0" , cVS1CONPRO )

					SB1->( dbSetOrder(7) )
					SB1->( dbSeek( xFilial("SB1") + VS3->VS3_GRUITE + VS3->VS3_CODITE ) )
					SB1->( dbSetOrder(1) )

					SB2->( dbSetOrder(1) )
					SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + VS3->VS3_LOCAL ) )

					aRetDes := OX005PERDES(SBM->BM_CODMAR, VS1->VS1_CENCUS, VS3->VS3_GRUITE ,VS3->VS3_CODITE,;
						VS3->VS3_QTDITE, VS3->VS3_PERDES, .t., VS1->VS1_CLIFAT, VS1->VS1_LOJA,;
						IIF(VS1->VS1_TIPORC == "2", "3", VS1->VS1_TIPVEN), VS3->VS3_VALTOT / VS3->VS3_QTDITE, 3, VS1->VS1_FORPAG,,,,cPesqPromo,dDatRefPD,nVS1PERREM)

					dbSelectArea("VS7")

					RecLock("VS7", .t.)

					VS7->VS7_FILIAL := xFilial("VS7")
					VS7->VS7_NUMIDE := VS6->VS6_NUMIDE
					VS7->VS7_SEQUEN := Strzero(nItVS7, 4)
					VS7->VS7_TIPAUT := "1"
					VS7->VS7_GRUITE := VS3->VS3_GRUITE
					VS7->VS7_CODITE := VS3->VS3_CODITE
					VS7->VS7_DESPER := aRetDes[2]
					VS7->VS7_DESDES := VS3->VS3_PERDES
					VS7->VS7_VALORI := VS3->VS3_VALPEC

					VS7->VS7_VALPER := IIF(VS1->VS1_TIPORC == "2", (VS3->VS3_VALPEC * (100 - aRetDes[2]) / 100),;
						IIF(aRetDes[1] == 0, aRetDes[2] * VS3->VS3_QTDITE, aRetDes[1]))

					VS7->VS7_VALDES := VS3->VS3_VALPEC - (VS3->VS3_VALDES / VS3->VS3_QTDITE)
					VS7->VS7_MARPER := aRetDes[3]
					VS7->VS7_MARLUC := VS3->VS3_MARLUC
					VS7->VS7_QTDITE := VS3->VS3_QTDITE
					VS7->VS7_DIVERG := IIf(aIDescont[nItVS7],"0","1") // Se o elemento do Array estiver com .T. é porque não houve Divergencia de Desconto ou Margem
					MsUnlock()
				EndIf

				DBSelectArea("VS3")
				DBSkip()
			EndDo
		EndIf

		// Existe Servico com Problema de Desconto
		If aScan( aIDesconS, .f. ) <> 0
			// Grava Cabecalho da Liberacao de Venda
			If Empty(cNumLib) .or. lGeraSep
				OX001OFVS6("S",0)
				cNumLib := VS6->VS6_NUMIDE
			EndIf

			If lGeraSep
				dbSelectArea("VS1")

				RecLock("VS1", .f.)

				M->VS1_NUMLIS   := cNumLib
				VS1->VS1_NUMLIS := cNumLib

				MsUnlock()
			EndIf

			//Servicos
			DBSelectArea("VS4")
			DBSetOrder(1)
			DBSeek(xFilial("VS4") + cNumOrc)

			nItVS7 := 0

			While !eof() .and. xFilial("VS4") + VS1->VS1_NUMORC == VS4->VS4_FILIAL + VS4->VS4_NUMORC
				nItVS7++
				If !(aIDesconS[nItVS7]) .or. lVS7SemProb // Cria VS7 de todos os Itens se pelo menos 1 tiver problema de Margem ou Desconto
					//Atribui a variavel "nDesPer" o Desconto Permitido
					VOK->(dbSetOrder(1))
					VOK->(dbSeek(xFilial("VOK") + VS4->VS4_TIPSER))

					dbSelectArea("VS7")

					RecLock("VS7", .t.)

					VS7->VS7_FILIAL := xFilial("VS7")
					VS7->VS7_NUMIDE := VS6->VS6_NUMIDE
					VS7->VS7_SEQUEN := Strzero(nItVS7, 4)
					VS7->VS7_TIPAUT := "2"
					VS7->VS7_GRUSER := VS4->VS4_GRUSER
					VS7->VS7_CODSER := VS4->VS4_CODSER
					VS7->VS7_TIPSER := VS4->VS4_TIPSER
					VS7->VS7_DESPER := VOK->VOK_PERMAX
					VS7->VS7_DESDES := VS4->VS4_PERDES
					VS7->VS7_VALORI := VS4->VS4_VALSER
					VS7->VS7_VALPER := VS4->VS4_VALSER * ((100 - VOK->VOK_PERMAX) / 100)
					VS7->VS7_VALDES := VS4->VS4_VALSER - VS4->VS4_VALDES
					VS7->VS7_QTDITE := 1
					VS7->VS7_DIVERG := IIf(aIDesconS[nItVS7],"0","1") // Se o elemento do Array estiver com .T. é porque não houve Divergencia de Desconto ou Margem
					MsUnlock()
				EndIf

				DBSelectArea("VS4")
				DBSkip()
			EndDo
		EndIf

		If Type("lOX001Auto") == "U" .or. !lOX001Auto
			MsgInfo(STR0087, STR0025) // Orcamento aguardando liberacao de desconto/margem. / Atenção
		EndIf

		DBSelectArea("VS1")

		reclock("VS1", .f.)

		cVS1StAnt := VS1->VS1_STATUS
		VS1->VS1_STATUS := "2"

		msunlock()
		If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
			OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , IIF(VS1->VS1_TIPORC=="P",STR0374,STR0001) ) // Grava Data/Hora na Mudança de Status do Orçamento / Pedidos de Venda / Orçamento por Fases
		EndIf

		If ExistFunc("FM_GerLog")
			//grava log das alteracoes das fases do orcamento
			FM_GerLog("F", VS1->VS1_NUMORC,, VS1->VS1_FILIAL, cVS1StAnt)
		EndIf

		If Type("lOX001Auto") == "U" .or. !lOX001Auto
			If Type("oDlgXX001") != "U"
				oDlgXX001:End()
			EndIf
		EndIf
	End Transaction

	If ExistBlock("OX01DSLO")
		ExecBlock("OX01DSLO",.f.,.f.) // Ponto de Entrada Depois da Gravacao da Solicitação de Liberação - Orçamento Oficina
	EndIf

return .f.


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001OFVS6  | Autor | Rubens Takahashi      | Data | 01/02/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Grava cabecalho da liberacao de venda de oficina             |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OX001OFVS6(cTipGer,nVS1PERREM)

Local lVS6PERREM := VS6->(FieldPos("VS6_PERREM")) > 0

Default cTipGer := "P"
Default nVS1PERREM := 0

dbSelectArea("VS6")
RecLock("VS6",.t.)
VS6->VS6_FILIAL := xFilial("VS6")
VS6->VS6_NUMIDE := GetSxENum("VS6","VS6_NUMIDE")
ConfirmSX8()
VS6->VS6_TIPAUT := "2"

If cTipGer == "P"
	VS6->VS6_TIPTEM := VS1->VS1_TIPTEM
Else
	VS6->VS6_TIPTEM := VS1->VS1_TIPTSV
EndIf

VS6->VS6_CODCLI := VS1->VS1_CLIFAT
VS6->VS6_LOJA   := VS1->VS1_LOJA
VS6->VS6_DATOCO := dDataBase
VS6->VS6_HOROCO := val(substr(time(),1,2)+substr(time(),4,2))
VS6->VS6_NUMORC := VS1->VS1_NUMORC
VS6->VS6_TIPOCO := "000008"
VS6->VS6_DESOCO := STR0086
VS6->VS6_USUARI := substr(cUsuario,7,15)
VS6->VS6_FORPAG := VS1->VS1_FORPAG
If lVS6PERREM
	VS6->VS6_PERREM := nVS1PERREM
	If cTipGer == "P"
		VAI->(DBSetOrder(4))
		If VAI->(DBSeek(xFilial("VAI")+__cUserID))
			VS6->VS6_DESPER := VAI->VAI_DESPEC // % Maximo de Desconto Permitido para Peças
		EndIf
	EndIf
EndIf
MSMM(VS6->VS6_OBSMEM,TamSx3("VS6_OBSERV")[1],,cObservVS6,1,,,"VS6","VS6_OBSMEM")
MsUnlock()

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001SRVAD  | Autor | Rubens Takahashi      | Data | 30/09/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Verifica se deve adicionar outros servicos na OS             |##
##|          | Inconveniente de REVISAO                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OX001SRVAD(aRetSrvc)
Local aSrvcAdic
Local cVO4Mostra
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela
Local nCont, nCont2
Local nVO4Usado := 0
Local cBkpVS1_TIPTSV := M->VS1_TIPTSV // Necessario para utilizar a funcao FG_VALHOR
Local nTemPad := 0
Local cQryAl001 := GetNextAlias()

Private lConfirma := .f.

aSrvcAdic := OM420SRVAD(M->VS1_NUMORC, M->VS1_CLIFAT, M->VS1_LOJA, M->VS1_CHAINT,M->VS1_KILOME)

if Len(aSrvcAdic) == 0
	Return .t.
endif

// Verifica se retornou o TT e Faturar Para...
For nCont := 1 to Len(aSrvcAdic)
	If Empty(aSrvcAdic[nCont,02]) .or. Empty(aSrvcAdic[nCont,03]) .or. Empty(aSrvcAdic[nCont,04])
		Return .f.
	EndIf
Next nCont
//

cVO4Mostra := "VO4_FILIAL,VO4_GRUINC,VO4_CODINC,VO4_NOMCLI,VO4_SEQINC,VO4_DESINC,VO4_TIPTEM,VO4_FATPAR,VO4_LOJA,"
cVO4Mostra += "VO4_GRUSER,VO4_CODSER,VO4_TIPSER,VO4_TEMPAD,VO4_CODTES,VO4_KILROD,VO4_CODSEC,"
cVO4Mostra += "VO4_DESSEC,VO4_SEQSER,VO4_OPER,VO4_CODTES,VO4_TIPTIT,VO4_DEPGAR,VO4_DEPINT,"
cVO4Mostra += "VO4_TEMVEN,VO4_SERINT,VO4_VALVEN,VO4_VALHOR,VO4_VALTOT,VO4_OBSERV"

cVO4nEdit := "VO4_FILIAL,VO4_GRUINC,VO4_CODINC,VO4_SEQINC,VO4_DESINC,"
cVO4nEdit += "VO4_GRUSER,VO4_CODSER,VO4_KILROD,"
cVO4nEdit += "VO4_DESSEC,VO4_DESSER,VO4_SEQSER,VO4_OPER,"
cVO4nEdit += "VO4_TEMVEN,VO4_SERINT,VO4_TIPTEM,VO4_FATPAR,VO4_LOJA,VO4_VALVEN,VO4_VALHOR,VO4_VALTOT"

// Cria Variaveis de Memoria e aHeader
aVO4Header := {}
aVO4Alter  := {}
aVO4Cols   := {}
//
dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek("VO4"))
While !Eof().And.(x3_arquivo=="VO4")
	If X3USO(x3_usado) .And. cNivel>=x3_nivel .and. (Alltrim(x3_campo) $ cVO4Mostra)
		nVO4Usado := nVO4Usado + 1
		Aadd(aVO4Header , {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,X3CBOX(),SX3->X3_RELACAO})
		if x3_usado != "V" .and. (INCLUI .or. ALTERA)
			if !(cVS1Status == "5" .and. FECHA)
				if !(Alltrim(x3_campo) $ cVO4nEdit)
					aAdd(aVO4Alter,x3_campo)
				endif
			endif
		endif
	EndIf
	DbSkip()
EndDo


For nCont := 1 to Len(aSrvcAdic)

	AADD(aVO4Cols, Array( nVO4Usado + 1 ) )
	For nCont2 := 1 to nVO4Usado
		aVO4Cols[nCont,nCont2] := CriaVar(aVO4Header[nCont2,2],.f.)
	Next nCont2
	aVO4Cols[Len(aVO4Cols),nVO4Usado+1]:=.F.

	For nCont2 := 1 to nVO4Usado
		if aVO4Header[nCont2,2] $ "VO4_VALVEN"
			Loop
		endif

		Do Case
			Case aVO4Header[nCont2,2] == "VO4_TIPTEM"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := aSrvcAdic[nCont,02]
			Case aVO4Header[nCont2,2] == "VO4_FATPAR"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := aSrvcAdic[nCont,03]
			Case AllTrim(aVO4Header[nCont2,2]) == "VO4_LOJA"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := aSrvcAdic[nCont,04]
			Case aVO4Header[nCont2,2] == "VO4_NOMCLI"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := Posicione("SA1",1,xFilial("SA1")+M->VO4_FATPAR+M->VO4_LOJA,"A1_NOME")
			Case aVO4Header[nCont2,2] == "VO4_GRUSER"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := aSrvcAdic[nCont,05]
			Case aVO4Header[nCont2,2] == "VO4_CODSER"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := aSrvcAdic[nCont,06]
			Case aVO4Header[nCont2,2] == "VO4_DESSER"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := Posicione("VO6",3,xFilial("VO6")+FG_MARSRV(M->VS1_CODMAR,M->VO4_CODSER)+M->VO4_GRUSER+M->VO4_CODSER,"VO6_DESSER")
			Case aVO4Header[nCont2,2] == "VO4_TIPSER"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := aSrvcAdic[nCont,07]
			Case aVO4Header[nCont2,2] == "VO4_GRUINC"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := aSrvcAdic[nCont,08]
			Case aVO4Header[nCont2,2] == "VO4_CODINC"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := aSrvcAdic[nCont,09]
			Case aVO4Header[nCont2,2] == "VO4_DESINC"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := aSrvcAdic[nCont,10]
			Case aVO4Header[nCont2,2] == "VO4_CODSEC"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := aSrvcAdic[nCont,11]
			Case aVO4Header[nCont2,2] == "VO4_SEQINC"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := aSrvcAdic[nCont,01]
			Case aVO4Header[nCont2,2] == "VO4_CODTES"
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := POSICIONE("VOI",1,xFilial("VOI")+VO4->VO4_TIPTEM,"VOI_CODTES")
			Otherwise
				&("M->"+aVO4Header[nCont2,2]) := aVO4Cols[nCont,nCont2] := CriaVar(aVO4Header[nCont2,2])
		EndCase
	Next nCont2

	DBSelectArea("VOK")
	DBSetOrder(1)
	DBSeek(xFilial("VOK")+M->VO4_TIPSER)

	DBSelectArea("VOI")
	DBSetOrder(1)
	DBSeek(xFilial("VOI")+M->VO4_TIPTEM)

	DBSelectArea("VO6")
	DBSetOrder(3)
	DBSeek(xFilial("VO6")+FG_MARSRV(M->VS1_CODMAR,M->VO4_CODSER)+M->VO4_GRUSER+M->VO4_CODSER)

	nTemPad	:= 0
	// Calcula serviço de kilometragem
	if VOK->VOK_INCMOB == "5"
		aVO4Cols[nCont,FG_POSVAR("VO4_VALHOR","aVO4Header")] := M->VO4_VALHOR := VOK->VOK_PREKIL
		aVO4Cols[nCont,FG_POSVAR("VO4_VALTOT","aVO4Header")] := M->VO4_VALTOT := M->VS4_KILROD * VOK->VOK_PREKIL
	else
		aVO4Cols[nCont,FG_POSVAR("VO4_KILROD","aVO4Header")] := M->VO4_KILROD := 0
		if VOK->VOK_INCMOB <> "7" // Calcular se for diferente de Valor Informado
			IF VO6->VO6_VALSER != 0
				aVO4Cols[nCont,FG_POSVAR("VO4_VALTOT","aVO4Header")] := M->VO4_VALTOT := VO6->VO6_VALSER
				aVO4Cols[nCont,FG_POSVAR("VO4_VALHOR","aVO4Header")] := M->VO4_VALHOR := 0
			Else
				M->VS1_TIPTSV := VOI->VOI_TIPTEM
				aVO4Cols[nCont,FG_POSVAR("VO4_VALHOR","aVO4Header")] := M->VO4_VALHOR := If(VOK->VOK_INCMOB $ "0/2/5/7",0,FG_VALHOR(VOI->VOI_TIPTEM,dDataBase,,,VV1->VV1_CODMAR,M->VO4_CODSER,M->VO4_TIPSER,M->VO4_FATPAR,M->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD))
				if VS1->VS1_CODMAR == OX0010393_GM()
					if Empty(M->VO4_SEQSER)
						cQuery := "SELECT VO7_SEQSER, VO7.R_E_C_N_O_ RECVO7 FROM " + RetSQLName("VO7") + " VO7 "
						cQuery += " WHERE VO7_FILIAL = '" + xFilial("VO7") + "'"
						cQuery +=   " AND VO7_CODMAR = '" + M->VS1_CODMAR + "'"
						cQuery +=   " AND VO7_CODSER = '" + M->VO4_CODSER + "'"
						cQuery +=   " AND VO7_APLICA = '" + substr(M->VS1_CHASSI,4,4) + "'"
						cQuery +=   " AND D_E_L_E_T_ = ' '"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
						If !(cQryAl001)->(Eof())
							cSeqSer := (cQryAl001)->VO7_SEQSER
							DBSelectArea("VO7")
							DBGoto((cQryAl001)->(RECVO7))
						EndIf
						(cQryAl001)->(dbCloseArea())
						aVO4Cols[nCont,FG_POSVAR("VO4_SEQSER","aVO4Header")] := M->VO4_SEQSER := VO7->VO7_SEQSER
					else
						cQuery := "SELECT R_E_C_N_O_ RECVO7 FROM "+RetSqlName("VO7")
						cQuery += " WHERE VO7_FILIAL ='" + xFilial("VO7") + "' AND VO7_SEQSER='" + M->VO4_SEQSER + "' AND"
						cQuery += " D_E_L_E_T_=' '"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
						If !(cQryAl001)->(Eof())
							DBSelectArea("VO7")
							DBGoto((cQryAl001)->(RECVO7))
						EndIf
						(cQryAl001)->(dbCloseArea())
					endif
					nTemPad := OX001TemPad(VV1->VV1_CODMAR,M->VO4_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),,VO7->VO7_APLICA,VO7->VO7_CONTRO)
				Else
					nTemPad := FG_TEMPAD(VV1->VV1_CHAINT,M->VO4_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),,M->VS1_CODMAR)
				Endif
				aVO4Cols[nCont,FG_POSVAR("VO4_VALTOT","aVO4Header")] := M->VO4_VALTOT := (nTemPad /100) * M->VO4_VALHOR
			EndIf
		endif
	EndIf
	aVO4Cols[nCont,FG_POSVAR("VO4_TEMPAD","aVO4Header")] := M->VS4_TEMPAD := nTemPad

Next nCont

For nCont := 1 to Len(aSizeHalf)
	aSizeHalf[nCont] := INT(aSizeHalf[nCont] * 0.80)
Next
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
AAdd( aObjects, { 0,  0, .T., .T. } ) // Objetos na Tela: GetDados Pecas
aPos := MsObjSize( aInfo, aObjects )

//aSrvcAdic := OM420SRVAD(M->VS1_NUMORC, M->VS1_CLIFAT, M->VS1_LOJA, M->VS1_CHAINT,M->VS1_KILOME)
dbSelectArea("VO4")
// Tela de Consulta
DEFINE MSDIALOG oIncAd FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0211) OF oMainWnd PIXEL

cVO4LinOk   :="AllwaysTrue()"
cVO4FieldOk :="AllwaysTrue()"
cVO4TudoOk  :="AllwaysTrue()"

oVO4GetServ := MsNewGetDados():New(aPos[1,1]+5,aPos[1,2],aPos[1,3],aPos[1,4],3,cVO4LinOk,cVO4TudoOk,,aVO4Alter,0,Len(aVO4Cols),cVO4FieldOk,,/*cDelPecOk*/, oIncAd , aVO4Header , aVO4Cols )

ACTIVATE MSDIALOG oIncAd CENTER ON INIT (EnchoiceBar(oIncAd, {|| lConfirma := .t. , oIncAd:End() },{|| lConfirma := .f. , oIncAd:End() },,))

aRetSrvc := {}
if lConfirma
	For nCont := 1 to Len(oVO4GetServ:aCols)

		Aadd(aRetSrvc,;
			{;
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_TIPTEM","aVO4Header")],; // 1
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_FATPAR","aVO4Header")],; // 2
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_LOJA",  "aVO4Header")],; // 3
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_GRUSER","aVO4Header")],; // 4
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_CODSER","aVO4Header")],; // 5
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_TIPSER","aVO4Header")],; // 6
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_TEMPAD","aVO4Header")],; // 7
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_CODTES","aVO4Header")],; // 8
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_KILROD","aVO4Header")],; // 9
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_CODSEC","aVO4Header")],; // 10
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_VALVEN","aVO4Header")],; // 11
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_TEMVEN","aVO4Header")],; // 12
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_SERINT","aVO4Header")],; // 13
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_VALHOR","aVO4Header")],; // 14
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_SEQINC","aVO4Header")],; // 15 - Sequencia Inconveniente - VST
				M->VS1_NUMORC,; 												 // 16 - Numero do Orcamento
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_SEQSER","aVO4Header")],; // 17
				0,; 															 // 18 - Valor do Desconto
				0,;  															 // 19 - Percentual de Desconto
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_VALTOT","aVO4Header")],; // 20
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_DEPGAR","aVO4Header")],; // 21 - Departamento Garantia
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_DEPINT","aVO4Header")],; // 22 - Departamento Interno
				oVO4GetServ:aCols[nCont, FG_POSVAR("VO4_OBSERV","aVO4Header")];  // 23 - Observacao
			};
		)

	Next nCont

endif

// Volta valor do VS1_TIPTSV
M->VS1_TIPTSV := cBkpVS1_TIPTSV

Return lConfirma

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001VERQMX | Autor | Rafal Goncalves       | Data | 12/11/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Verifica se a quantidade maxima de componente por modelo     |##
##|          | nao foi excedida - solicitado Manoel.                        |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OX001VERQMX(cNumOrd)
Local aArea := {}
Local cMsgImpor := STR0277 + CHR(13)+CHR(10)+CHR(13)+CHR(10)//Os Itens:
Local lRet := .t.
default cNumOrd := "" // numero da ordem de Servico que esta sendo exportado o orcamento.

aArea := sGetArea(aArea,"VS1")
aArea := sGetArea(aArea,"VS3")
aArea := sGetArea(aArea,"VO1")
aArea := sGetArea(aArea,"SB1")
aArea := sGetArea(aArea,"SB2")
aArea := sGetArea(aArea,"SB5")
aArea := sGetArea(aArea,"SD3")
aArea := sGetArea(aArea,"SBM")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf

//DbSelectArea("VS1")
//DbSetOrder(1)
//If DbSeek( xFilial("VS1") + _cNumOrc )
DbSelectArea("VS3")
DbSetOrder(1)
If DbSeek( xFilial("VS3") + VS1->VS1_NUMORC )
	Do While !Eof() .and. xFilial("VS3") == VS3->VS3_FILIAL .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC

		//OFIOM020 - valida a quantidade maxima por modelo para exportar para nova OS
		If !VALPMOD020( M->VS3_GRUITE , M->VS3_CODITE , M->VS3_QTDITE , "2" , "1" , cNumOrd)
			cMsgImpor += Alltrim(M->VS3_GRUITE)+" - "+Alltrim(M->VS3_CODITE) +CHR(13)+CHR(10)
			lRet := .f.
		EndIF

		DbSelectArea("VS3")
		DbSkip()
	EndDo
endif
//EndIf

sRestArea(aArea)

IF !lRet
	cMsgImpor +=CHR(13)+CHR(10)+STR0212 //terao as quantidades zeradas pois exedeu o limite maximo permitido por modelo.
	MsgAlert(cMsgImpor,STR0075)
EndIF

return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ OFX001USR³ Autor ³  Rafael Goncalves     ³ Data ³ 02/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Pedido de Senha e filtro para utilizar inc. !valido        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OFX001USR(cGruInc,cCodInc)

Local OGetSenha
Local oDlgSenha
Local cSenhaPE   := Space(15)
Local cUsuarPE   := Space(25)
Local cBitMap    := "LOGIN"
Local cRet := .f.
Private _cGruInc := cGruInc
Private _cCodInc := cCodInc

DEFINE DIALOG oDlgSenha TITLE OemToAnsi(STR0022) FROM 20, 20 TO 225,310 PIXEL  //Autorizacao p/ Utilizar Inconveniente

@ 0, 0 BITMAP oBmp RESNAME cBitMap oF oDlgSenha SIZE 50,140 NOBORDER WHEN .F. PIXEL

@ 10,55 SAY OemToAnsi("Usuario")	PIXEL  //Usuario
@ 20,55 MSGET cUsuarPE PIXEL SIZE 80,08 Valid FS_ValNom001(cUsuarPE)

@ 50,55 SAY OemToAnsi("Senha") PIXEL  //Senha
@ 60,55 MSGET oGetSenha VAR cSenhaPE PASSWORD PIXEL SIZE 40,08

DEFINE SBUTTON FROM 85,75  TYPE 1 ACTION If(FS_VALUSR001(cusuarPE,cSenhaPE),(oDlgSenha:End(),cRet := .t.),.f.) ENABLE OF oDlgSenha
DEFINE SBUTTON FROM 85,105 TYPE 2 ACTION (cRet := .F., oDlgSenha:End()) ENABLE OF oDlgSenha

ACTIVATE MSDIALOG oDlgSenha CENTERED

// Restaura usuario de login.
PswOrder(3)

Return(cRet)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |FS_VALUSR001| Autor | Rafal Goncalves       | Data | 02/12/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Valida usuario e senha para utilizar inconveniente           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_VALUSR001(cUsux,cSenhax)

// Senha
/*PswOrder(3)

If PswSeek(cSenhaX)
	If Alltrim(cUsux) == Alltrim(PswRet(1)[1][2])
		VAI->(DbSetOrder(4))
		If VAI->(DbSeek(xFilial("VAI")+PswRet(1)[1][1]))
			If VAI->VAI_INCFPV = "0" // usuario com permissao para utilizar inconveniente fora do prazo
				//gravar log do usuario que liberou o inconveniente
				If ExistFunc("FM_GerLog") //funcao que grava log  - OFIXFUNA
					DbSelectArea("VSL")
					DbSetOrder(1) // VSL_FILIAL+VSL_CODMAR+VSL_CODGRU+VSL_CODINC
					dbSeek(xFilial("VSL")+VV1->VV1_CODMAR+_cGruInc+_cCodInc)
					cLogTexto:= ", "+ STR0213  + Alltrim(cUsux) +"-"+ Alltrim(VAI->VAI_NOMTEC)+", "+ STR0214  + alltrim(_cGruInc) +"-"+ alltrim(_cCodInc) +" - " + Alltrim(VSL->VSL_DESINC) //foi autorizado pelo Usuario: ### utilização do inconveniente não valido
					FM_GerLog("L",,cLogTexto)
				EndIF
				Return(.t.)
			Else
				Msginfo(STR0215,STR0025) //"Usuario sem permissao para utilizar Inconveniente fora da Validade","Atencao"
				Return(.f.)
			Endif
		Else
			Return(.f.)
		EndIf
	Endif
EndIf

Help("  ",1,"NOSENHA")*/

Return(.f.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |FS_ValNom001| Autor | Rafal Goncalves       | Data | 02/12/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Valida uvalida o nome do usuario para utilizar inconveniente |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_ValNom001(cUsux)

PswOrder(2)

If !PswSeek(cUsux)
	Return .f.
Endif

Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001LVS34  |Autor  | Rafal Goncalves       | Data | 02/12/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Faz o levantamento das peças e servicos do orcamento e  exibe|##
##|          | incregua                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001LVS34()

	Local nCntFor

	oProcTTP:SetRegua1(2)
	oProcTTP:IncRegua1( STR0216)
	oProcTTP:SetRegua2(Len(aColsP))

	// ----------------------------------- //
	//Processa Peças                       //
	// ----------------------------------- //
	MaFisRef("NF_TPFRETE",,M->VS1_PGTFRE)
	OX001RecFis("NF_TPCLIFOR",M->VS1_TIPCLI,"OX001LVS34") // Recalcula o Fiscal assim que entra no Orçamento
	oProcTTP:IncRegua1( STR0177 )
	//
	// ----------------------------------- //
	//Processa Servicos                       //
	// ----------------------------------- //
	DBSelectArea("VOI")
	DBSetOrder(1)
	DBSeek(xFilial("VOI")+M->VS1_TIPTSV)
	oProcTTP:SetRegua2(Len(aColsS))

	VOK->(dbSetOrder(1))
	SB1->(DBSetOrder(7))

	for nCntFor := 1 to Len(aColsS)
		
		VOK->(dbSeek(xFilial("VOK") + aColsS[nCntFor,FG_POSVAR("VS4_TIPSER","aHeaderS")] ))
		
		DBSelectArea("SB1")
		SB1->(DBSeek(xFilial("SB1")+ VOK->VOK_GRUITE + VOK->VOK_CODITE ))
		
		oProcTTP:IncRegua2()
		nTotFis ++
		aAdd(aNumS,{nCntFor,nTotFis})
		n := aNumS[nCntFor,2]
		//
		SF4->(dbSeek(xFilial("SF4")+VOI->VOI_CODTES))

		MaFisIniLoad(n,{	"",;
			VOI->VOI_CODTES,;
			" "  ,;
			1,;
			"",;
			"",;
			SB1->(RecNo()),;	//IT_RECNOSB1
			SF4->(RecNo()),;	//IT_RECNOSF4
			0 }) 			//IT_RECORI

		MaFisLoad("IT_PRCUNI",aColsS[nCntFor,FG_POSVAR("VS4_VALSER","aHeaderS")],n)
		MaFisLoad("IT_VALMERC",aColsS[nCntFor,FG_POSVAR("VS4_VALSER","aHeaderS")],n)
		MaFisLoad("IT_DESCONTO",aColsS[nCntFor,FG_POSVAR("VS4_VALDES","aHeaderS")],n)
		MaFisRecal("",n)
		MaFisEndLoad(n,IIf( nCntFor == Len(aColsS) , 2 , 1 ) )
	next

Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001KIL    |Autor  | Rafal Goncalves       | Data | 02/12/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Verifica kilometragem                                        |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001KIL(cChassi)
Local nUltKil := 0
If INCLUI .or. ALTERA
	cValKil := Left(GetNewPar("MV_VKILHOR","SN"),1)
	if cValKil == "N" .or. (cValKil == "P" .and. Empty(M->VS1_KILOME))
		return .t.
	endif
	nOpc := IIf(INCLUI,3,4)
	DbSelectArea("VV1")
	DbSetOrder(2)
	If DbSeek(xFilial("VV1")+cChassi)
		nUltKil := FG_ULTKIL(VV1->VV1_CHAINT)
		If nUltKil > M->VS1_KILOME
			MsgStop( STR0152+" ("+Transform(M->VS1_KILOME,"@E 999,999,999")+" ) "+STR0153+" ("+Transform(nUltKil,"@E 999,999,999")+" )!",STR0025) //KM/hora informada # menor que da OS anterior
			Return .f. // ERRO: KILOMETRAGEM MENOR
		EndIf
	Else
		Return(.f.)
	EndIf
	If M->VS1_HORTRI > M->VS1_KILOME
		MSGINFO(STR0025;
		+Chr(13)+STR0253;
		+Chr(13)+STR0252+" "+Transform(M->VS1_HORTRI,"@E 99,999,999");
			+Chr(13)+STR0183+" "+Transform(M->VS1_KILOME,"@E 99,999,999"))
	EndIf
EndIf
Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |OX001HOR    |Autor  | Luis Delorme          | Data | 10/09/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Verifica horas de trilha                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX001HOR(cChassi)
Local nUltHor := 0
Default cChassi := ""
If INCLUI .or. ALTERA
	cValHor := Subs(GetNewPar("MV_VKILHOR","SN"),2,1)
	if cValHor == "N" .or. (cValHor == "P" .and. Empty(M->VS1_HORTRI))
		return .t.
	endif
	If !Empty(cChassi)
		nOpc := IIf(INCLUI,3,4)
		DbSelectArea("VV1")
		DbSetOrder(2)
		If MsSeek(xFilial("VV1")+cChassi)
			M->VS1_CHAINT := VV1->VV1_CHAINT
		Else
			Return(.f.)
		EndIf
	EndIf
	nUltHor := FG_ULTHOR(M->VS1_CHAINT)
	If nUltHor > M->VS1_HORTRI
		MsgStop( STR0252+" ("+Transform(M->VS1_HORTRI,"@E 99,999,999")+" ) "+STR0153+" ("+Transform(nUltHor,"@E 99,999,999")+" )!",STR0025)
		Return .f.
	EndIf
	If M->VS1_HORTRI > M->VS1_KILOME
		MSGINFO(STR0025;
		+Chr(13)+STR0253;
		+Chr(13)+STR0252+" "+Transform(M->VS1_HORTRI,"@E 99,999,999");
		+Chr(13)+STR0183+" "+Transform(M->VS1_KILOME,"@E 99,999,999"))
		If !Empty(cChassi)
			Return .t. // Esta na digitacao... deixa passar
		Else
			Return .f. // Esta na gravacao... nao deixa passar
		Endif
	EndIf
EndIf
Return(.t.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³OX001INCPR³ Autor ³ Andre Luis Almeida    ³ Data ³ 15/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Utilizacao de Plano de Revisao / Inconvenientes            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Orcamento Oficina                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001INCPR(nOpc)
Local ni      := 0
Local aIncSel := {}
If M->VS1_TIPORC == "1" // Verifica se Orcamento e' Balcao
	MsgStop(STR0045,STR0025)
	Return()
EndIf
If Empty(M->VS1_CHASSI) // Verifica se o Veiculo foi digitado (chassi)
	MsgStop(STR0172,STR0025)
	Return()
EndIf
If M->VS1_KILOME == 0 // Verifica se a KM do Veiculo foi digitada
	MsgStop(STR0173,STR0025)
	Return()
EndIf
aIncSel := FG_PLAREV(VV1->VV1_CHAINT,M->VS1_KILOME,nOpc) // Chamada da Funcao para Visualizar Inconvenientes / Plano de Revisao do Veiculo
ProcRegua(len(aIncSel))
If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	For ni := 1 to len(aIncSel) // Carregar Pecas/Servicos do Inconveniente
		IncProc(STR0170) // Analisando Inconvenientes...
		OX001INCON(nOpc,aIncSel[ni,1],aIncSel[ni,2],aIncSel[ni,3],"C")
	Next
EndIf

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³OX001MSCA ³ Autor ³ Luis Delorme          ³ Data ³ 15/02/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Leitura dos arquivos de orçamento MULTI                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Orcamento Oficina                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001MSCA(nOpc)

Local nCntFor2, nCntFor3

lNovoOrc := .f.

if M->VS1_NUMORC == ""
	cNumOrc := GetSXENum("VS1","VS1_NUMORC")
	M->VS1_NUMORC := cNumOrc
	lNovoOrc := .t.
endif

if !MsgYesNo (STR0228 + M->VS1_NUMORC +CHR(10)+CHR(13) +STR0229)
	return .f.
endif

if lNovoOrc
	ConfirmSx8()
endif

cQryAlSC1 := GetNextAlias()
// arquivo intermediario. preciso de todos os campos
cQuery := "SELECT *  FROM "+RetSqlName("VD4")
cQuery += " WHERE VD4_FILIAL ='" + xFilial("VD4") + "' AND VD4_ORDER = '" + Alltrim(M->VS1_NUMORC) + "' AND"
cQuery += " D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlSC1, .F., .T. )

// arquivo intermediario. preciso de todos os campos
cQryAlSC2 := GetNextAlias()
cQuery := "SELECT *  FROM "+RetSqlName("VD5")
cQuery += " WHERE VD5_FILIAL ='" + xFilial("VD5") + "' AND VD5_ORDER = '" + Alltrim(M->VS1_NUMORC) + "' AND"
cQuery += " D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlSC2, .F., .T. )

cGrupoSCA := "" // VE4->VE4_GRUITE

cGruSCA := Alltrim(GetNewPar("MV_GORISC ","     "))

aGrupos := {}
for nCntFor2 := 1 to Len(cGruSCA) step 5
	aAdd(aGrupos,Subs(cGruSCA,nCntFor2,4))
next


cReadTmp := __readvar
__readvar := cReadTmp
// Caso existam kits, deve-se setar o parâmetro de rotina automática para preencher os itens
if !( (cQryAlSC1)->(eof()) )
	lOX001Auto := .t.
	lPrimLinha := .t.
	while !((cQryAlSC1)->(eof()))
		DbSelectArea("SB1")
		DbSetOrder(7)
		for nCntFor2 := 1 to Len(aGrupos)
			cGrupoSCA := aGrupos[nCntFor2]
			if DbSeek( xFilial("SB1") + cGrupoSCA + Alltrim((cQryAlSC1)->(VD4_PARTNO)))
				exit
			endif
		next
		if !found()
			MsgInfo(STR0230 + cGrupoSCA +" "+ Alltrim((cQryAlSC1)->(VD4_PARTNO)) + STR0231)
			(cQryAlSC1)->(DBSkip())
			loop
		endif
		// verifica se o item já foi lancado no orcamento
		lAchouUm := .f.
		//
		OX001RefNF()
		//
		for nCntFor2 := 1 to Len(oGetPecas:aCols)
			// pula itens deletados
			if !oGetPecas:aCols[nCntFor2,Len(oGetPecas:aCols[nCntFor2])]
				// se o item já foi lançado no orçamento deve-se apenas alterar a quantidade
				if cGrupoSCA == oGetPecas:aCols[nCntFor2,nVS3GRUITE] .and.;
					Alltrim((cQryAlSC1)->(VD4_PARTNO)) == Alltrim(oGetPecas:aCols[nCntFor2,nVS3CODITE])
					// salva valores da acols para restauração
					nAtual := oGetPecas:nAt
					oGetPecas:nAt := nCntFor2
					n := nCntFor2
					// monta as variáveis de memória
					For nCntFor3:=1 to Len(aHeaderP)
						&("M->"+aHeaderP[nCntFor3,2]) := oGetPecas:aCols[oGetPecas:nAt,nCntFor3]
					next
					// atualiza quantidade
					M->VS3_QTDITE := (cQryAlSC1)->(VD4_QUANT) // + oGetPecas:aCols[nCntFor2,nVS3QTDITE]
					// executa o fieldok com os valores posicionados
					__ReadVar := "M->VS3_QTDITE"
					OX001FPOK(.f.,,.f.,.f.)
					// restaura a posição anterior da acols
					oGetPecas:nAt := nAtual
					n := nAtual
					lAchouUm := .t.
					exit
				endif
			endif
		next
		// se o item sofreu alteração de quantidade (já lançado) faz o loop
		if lAchouUm
			(cQryAlSC1)->(DBSkip())
			loop
		endif
		// quando o item é lançado pela primeira vez ele deve ocupar o lugar do item atual (kit)
		// caso contrário deve-se criar uma nova linha
		if Len(oGetPecas:aCols) > 0 .and. !Empty(oGetPecas:aCols[1,nVS3CODITE])
			lPrimLinha := .f.
		endif
		if !lPrimLinha
			// adiciona a linha com os valores default
			AADD(oGetPecas:aCols,Array(nUsadoPX01+1))
			oGetPecas:aCols[Len(oGetPecas:aCols),nUsadoPX01+1]:=.F.
			For nCntFor2:=1 to nUsadoPX01
				If IsHeadRec(aHeaderP[nCntFor2,2])
					oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor2] := 0
				ElseIf IsHeadAlias(aHeaderP[nCntFor2,2])
					oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor2] := "VS3"
				Else
					crVar = CriaVar(aHeaderP[nCntFor2,2])
					oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor2] := crVar
				EndIf
			Next
			oGetPecas:nAt := Len(oGetPecas:aCols)
			n := Len(oGetPecas:aCols)
		endif
		// monta o vetor com os itens necessários
		aVetCmp := {}
		aAdd(aVetCmp,{"VS3_GRUITE",cGrupoSCA,M->VS3_GRUITE} )
		aAdd(aVetCmp,{"VS3_CODITE",Left((cQryAlSC1)->(VD4_PARTNO)+SPACE(100),TamSX3("B1_CODITE")[1]),M->VS3_CODITE} )
		aAdd(aVetCmp,{"VS3_FORMUL",M->VS1_FORMUL,       M->VS3_FORMUL} )
		aAdd(aVetCmp,{"VS3_CODTES",FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS") ,M->VS3_CODTES} )
		aAdd(aVetCmp,{"VS3_QTDITE",(cQryAlSC1)->(VD4_QUANT),M->VS3_QTDITE} )
		RegToMemory("VS3",.t.)
		// faz o laço para cada item, preenchendo os valores e chamando o FieldOk
		for nCntFor2 := 1 to Len(aVetCmp)
			&("M->"+aVetCmp[nCntFor2,1] ) := aVetCmp[nCntFor2,2]
			__ReadVar := "M->"+aVetCmp[nCntFor2,1]
			if !OX001FPOK(.f.,,.f.,.f.)
				// se o fieldok retornar falso deve-se restaurar a linha anterior (primeira linha) ou exluir a linha (demais linhas)
				if !lPrimLinha
					aSize(oGetPecas:aCols,Len(oGetPecas:aCols)-1)
					For nCntFor3:=1 to Len(aHeaderP)
						&("M->"+aHeaderP[nCntFor3,2]) := oGetPecas:aCols[Len(oGetPecas:aCols),nCntFor3]
					next
				else
					M->VS3_GRUITE := aVetCmp[asCan(aVetCMP,{|x| x[1] == "VS3_GRUITE"}),3]
					M->VS3_CODITE := aVetCmp[asCan(aVetCMP,{|x| x[1] == "VS3_CODITE"}),3]
					M->VS3_CODTES := aVetCmp[asCan(aVetCMP,{|x| x[1] == "VS3_CODTES"}),3]
					M->VS3_QTDITE := aVetCmp[asCan(aVetCMP,{|x| x[1] == "VS3_QTDITE"}),3]
					M->VS3_FORMUL := aVetCmp[asCan(aVetCMP,{|x| x[1] == "VS3_FORMUL"}),3]
					M->VS3_PERDES := aVetCmp[asCan(aVetCMP,{|x| x[1] == "VS3_PERDES"}),3]
				endif
				oGetPecas:nAt := Len(oGetPecas:aCols)
				exit
			endif
		next
		lPrimLinha := .f.
		(cQryAlSC1)->(dbSkip())
	enddo
	// caso ainda esteja na primeira linha significa que todas os itens já estavam no orçamento ou nenhum item deu certo
	if lPrimLinha .and. Len(oGetPecas:aCols) > 0
		aSize(oGetPecas:aCols,Len(oGetPecas:aCols)-1)
	endif
	oGetPecas:nAt := Len(oGetPecas:aCols)
	n := oGetPecas:nAt
	lOX001Auto := .f.
	OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
	oGetPecas:oBrowse:refresh()
	return .t.
endif
(cQryAlSC1)->(dbCloseArea())
(cQryAlSC2)->(dbCloseArea())

DBSelectArea("VD4")
DBSetOrder(1)
DBSeek(xFilial("VD4")+M->VS1_NUMORC)
while !eof() .and. xFilial("VD4")+Alltrim(M->VS1_NUMORC) == VD4->VD4_FILIAL + Alltrim(VD4->VD4_ORDER)
	reclock("VD4",.f.,.t.)
	dbdelete()
	msunlock()
	DBSkip()
enddo

return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma OX001PRDIA  Autor ³ Luis Delorme       º Data ³  25/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³Posiciona no VEN e filtra as promocoes do dia VEN_PRODIA=1 º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001PRDIA()

Local cQuery   := ""
Local cQAlVEN  := "SQLVEN"
Local aPromoD   := {} // Promocoes do Dia
Local aPromoG   := {} // Promocoes Gerais

cQuery := "SELECT VEN_GRUITE, VEN_CODITE, VEN_VALPRO, VEN_PERDES, VEN_QTDITE "
cQuery += ", VEN_PRODIA"
cQuery += "  FROM "+RetSQLName("VEN")+" VEN"
cQuery += " WHERE VEN_FILIAL='"+xFilial("VEN")+"'"
cQuery += "   AND VEN_DATINI <= '"+dtos(ddatabase)+"'"
cQuery += "   AND VEN_DATFIN >= '"+dtos(ddatabase)+"'"
cQuery += "   AND VEN_CODITE <> ' ' "
cQuery += "   AND VEN_GRUITE <> ' ' "
cQuery += "   AND ( VEN_VALPRO > 0 OR VEN_PERDES > 0 )"
cQuery += "   AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVEN, .F., .T. )
while !( ( cQAlVEN )->(eof()) )
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1") + ( cQAlVEN )->(VEN_GRUITE) + ( cQAlVEN )->(VEN_CODITE) )
	If ( cQAlVEN )->(VEN_PRODIA) == "1" // Promocao do Dia
		aAdd( aPromoD, { SB1->B1_GRUPO, SB1->B1_CODITE, SB1->B1_DESC, SB1->B1_FABRIC, OX001SLDPC(xFilial("SB2")+SB1->B1_COD+OX0010105_ArmazemOrigem(), .t. ), ( cQAlVEN )->(VEN_VALPRO), ( cQAlVEN )->(VEN_QTDITE), ( cQAlVEN )->(VEN_PERDES) })
	Else
		aAdd( aPromoG, { SB1->B1_GRUPO, SB1->B1_CODITE, SB1->B1_DESC, SB1->B1_FABRIC, OX001SLDPC(xFilial("SB2")+SB1->B1_COD+OX0010105_ArmazemOrigem(), .t. ), ( cQAlVEN )->(VEN_VALPRO), ( cQAlVEN )->(VEN_QTDITE), ( cQAlVEN )->(VEN_PERDES) })
	EndIf
	( cQAlVEN )->( dbSkip() )
enddo
( cQAlVEN )->( dbCloseArea() )
DbSelectArea("VEN")
If len(aPromoD)+len(aPromoG) <= 0
	MsgStop(STR0226)
	return .f.
Else // Possui Promocoes

	If len(aPromoD) <= 0
		aAdd( aPromoD, { "", "", "", "", 0, 0, 0, 0 })
	EndIf
	If len(aPromoG) <= 0
		aAdd( aPromoG, { "", "", "", "", 0, 0, 0, 0 })
	EndIf

	DEFINE MSDIALOG oPromOX001 TITLE (STR0348) From 00,00 to 400,800 PIXEL  of oMainWnd // Promocoes

	@ 02,05 TO 098,398 LABEL STR0222 OF oPromOX001 PIXEL // Promocao do Dia
	oLBoxD := TWBrowse():New( 010,007,389,085,,,,oPromOX001,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLBoxD:AddColumn( TCColumn():New( STR0018 , { || aPromoD[oLBoxD:nAT,1] }                                       ,,,,"LEFT"   ,025,.F.,.F.,,,,.F.,) ) // Grupo
	oLBoxD:AddColumn( TCColumn():New( STR0019 , { || aPromoD[oLBoxD:nAT,2] }                                       ,,,,"LEFT"   ,065,.F.,.F.,,,,.F.,) ) // Codigo Item
	oLBoxD:AddColumn( TCColumn():New( STR0021 , { || aPromoD[oLBoxD:nAT,3] }                                       ,,,,"LEFT"   ,080,.F.,.F.,,,,.F.,) ) // Descricao
	oLBoxD:AddColumn( TCColumn():New( STR0330 , { || Transform(aPromoD[oLBoxD:nAt,7],"@E 99999") }                 ,,,,"RIGHT"  ,040,.F.,.F.,,,,.F.,) ) // Qtd.Minima
	oLBoxD:AddColumn( TCColumn():New( STR0012 , { || Transform(aPromoD[oLBoxD:nAt,5],"@E 999,999,999") }           ,,,,"RIGHT"  ,045,.F.,.F.,,,,.F.,) ) // Quantidade
	oLBoxD:AddColumn( TCColumn():New( STR0014 , { || Transform(aPromoD[oLBoxD:nAt,6],"@E 999,999,999.99") }        ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // Valor
	oLBoxD:AddColumn( TCColumn():New( RetTitle("VEN_PERDES") , { || Transform(aPromoD[oLBoxD:nAt,8],"@E 999.99") } ,,,,"RIGHT"  ,040,.F.,.F.,,,,.F.,) ) // Percentual Desconto
	oLBoxD:nAt := 1
	oLBoxD:SetArray(aPromoD)

	@ 102,05 TO 198,398 LABEL STR0349 OF oPromOX001 PIXEL // Demais Promocoes
	oLBoxG := TWBrowse():New( 110,007,389,085,,,,oPromOX001,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLBoxG:AddColumn( TCColumn():New( STR0018 , { || aPromoG[oLBoxG:nAT,1] }                                       ,,,,"LEFT"   ,025,.F.,.F.,,,,.F.,) ) // Grupo
	oLBoxG:AddColumn( TCColumn():New( STR0019 , { || aPromoG[oLBoxG:nAT,2] }                                       ,,,,"LEFT"   ,065,.F.,.F.,,,,.F.,) ) // Codigo Item
	oLBoxG:AddColumn( TCColumn():New( STR0021 , { || aPromoG[oLBoxG:nAT,3] }                                       ,,,,"LEFT"   ,080,.F.,.F.,,,,.F.,) ) // Descricao
	oLBoxG:AddColumn( TCColumn():New( STR0330 , { || Transform(aPromoG[oLBoxG:nAt,7],"@E 99999") }                 ,,,,"RIGHT"  ,040,.F.,.F.,,,,.F.,) ) // Qtd.Minima
	oLBoxG:AddColumn( TCColumn():New( STR0012 , { || Transform(aPromoG[oLBoxG:nAt,5],"@E 999,999,999") }           ,,,,"RIGHT"  ,045,.F.,.F.,,,,.F.,) ) // Quantidade
	oLBoxG:AddColumn( TCColumn():New( STR0014 , { || Transform(aPromoG[oLBoxG:nAt,6],"@E 999,999,999.99") }        ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // Valor
	oLBoxG:AddColumn( TCColumn():New( RetTitle("VEN_PERDES") , { || Transform(aPromoG[oLBoxG:nAt,8],"@E 999.99") } ,,,,"RIGHT"  ,040,.F.,.F.,,,,.F.,) ) // Percentual Desconto
	oLBoxG:nAt := 1
	oLBoxG:SetArray(aPromoG)

	ACTIVATE MSDIALOG oPromOX001 CENTER
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³OX001ABOS³ Autor ³ Thiago			   º Data ³  27/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³Tela para selecao da ordem de servico.						º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OX001ABOS(cChaint)
Local nNovaOS := 1
Local nOpcao := 2
Local cNumOS := ""
Local aOS := {{"",ctod(""),0}}
Local cAliasVO1 := "SQLVO1"
Local cRet := ""
Local aArea := GetArea()

cQuery := "SELECT VO1.VO1_NUMOSV , VO1.VO1_DATABE , VO1.VO1_KILOME FROM " + RetSqlName( "VO1" ) + " VO1 WHERE "
cQuery += "VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND VO1.VO1_CHAINT='"+cChaint+"' AND VO1.VO1_STATUS='A' AND VO1.D_E_L_E_T_=' ' "
cQuery += "ORDER BY VO1.VO1_NUMOSV"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO1, .T., .T. )
Do While !( cAliasVO1 )->( Eof() )
    If Empty(aOS[1,1])
       aOS := {}
    EndIf
	aadd(aOS,{ ( cAliasVO1 )->VO1_NUMOSV , stod(( cAliasVO1 )->VO1_DATABE) , ( cAliasVO1 )->VO1_KILOME })
   ( cAliasVO1 )->(DbSkip())
EndDo
( cAliasVO1 )->( dbCloseArea() )
if Len(aOS) > 0 .and. !Empty(aOS[1,1])
   nNovaOS := 2
Else
   nNovaOS := 1
Endif

DEFINE DIALOG oDlgOS TITLE STR0233 FROM 20, 20 TO 225,310 PIXEL

@ 004,005 RADIO oRadio1 VAR nNovaOS 3D SIZE 109,10 PROMPT STR0234,STR0235 OF oDlgOS PIXEL
@ 025,001 LISTBOX oLboxOS FIELDS HEADER STR0236,STR0237,STR0258 COLSIZES 45,45,45 SIZE 144,74 OF oDlgOS PIXEL

oLboxOS:SetArray(aOS)
oLboxOS:bLine := { || { aOS[oLboxOS:nAt,01] , transform(aOS[oLboxOS:nAt,02],"@D") , transform(aOS[oLboxOS:nAt,03],"@E 999,999,999,999") }}

DEFINE SBUTTON oBtOk     FROM 001,118 TYPE 1 ACTION IIf(nNovaOS==1.or.FS_VALKMOS(aOS[oLboxOS:nAt,01],aOS[oLboxOS:nAt,03]),(nOpcao:=1,cNumOS := aOS[oLboxOS:nAt,01],oDlgOS:End()),.t.) ENABLE OF oDlgOS
DEFINE SBUTTON oBtCancel FROM 013,118 TYPE 2 ACTION (nOpcao:=2,oDlgOS:End()) ENABLE OF oDlgOS

ACTIVATE MSDIALOG oDlgOS CENTERED

RestArea( aArea )
if nOpcao == 1
	if nNovaOS == 1
		cRet := ""
		cValKil := Left(GetNewPar("MV_VKILHOR","SN"),1)
		if cValKil == "S" .or. (cValKil == "P" .and. !Empty(M->VS1_KILOME))
			nUltKil := FG_ULTKIL(M->VS1_CHAINT)
			If nUltKil > M->VS1_KILOME
				MsgInfo( STR0183+" ("+Transform(M->VS1_KILOME,"@E 999,999,999")+" ) "+STR0184+" ("+Transform(nUltKil,"@E 999,999,999")+" )!",STR0025) //KM/hora informada # menor que da OS anterior
				cRet := "ret"
			EndIf
		endif
	Else
		cRet := cNumOS
	Endif

	// Ponto de Entrada para Validação após a Tela de Exportação
	If ExistBlock("OX001VEX")
		If !ExecBlock("OX001VEX", .f., .f., {nNovaOS, cNumOS})
			cRet := "ret"
		EndIf
	EndIf
Else
	cRet := "ret"
Endif

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FS_VALKMOSº Autor ³ Andre Luis Almeida º Data ³  28/01/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³Validacao da KM/Hora                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALKMOS(cOS,nKM)
Local lRet := .T.
If !Empty(cOS)
	If M->VS1_KILOME < nKM // ERRO
		If !MsgYesNo(STR0375,STR0025) // KM informada no Orçamento é menor que da OS selecionada! Deseja continuar? / Atencao
			lRet := .F.
		EndIf
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³OX001PRAUTLC³ Autor ³ Manoel		   º Data ³  27/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³Priorizacao automatica de Localização (Endereçamento)		º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001PRAUTLC(cCodPec,cLocalPec,nQtdLocPec,cLt,cNLt)
Local aVetRet   := {}
Local nQtdSobra := 0
Local cQuery   := ""
Local cQAlias  := "SQLSBF"

cQuery := "SELECT SBF.BF_LOCALIZ, SBF.BF_QUANT FROM "+RetSqlName("SBF")+" SBF WHERE SBF.BF_FILIAL = '"+xFilial("SBF")+"' AND "
cQuery += "SBF.BF_PRODUTO = '"+cCodPec+"' AND SBF.BF_LOCAL = '"+cLocalPec+"' AND SBF.BF_QUANT-SBF.BF_EMPENHO > 0 AND "
If !Empty(cLt)
	cQuery += "SBF.BF_LOTECTL = '"+cLt+"' AND "
Endif
If !Empty(cNLt)
	cQuery += "SBF.BF_NUMLOTE = '"+cNLt+"' AND "
Endif
cQuery += "SBF.D_E_L_E_T_ = ' ' ORDER BY SBF.BF_PRIOR"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )

Do While !( cQAlias )->( Eof() )
    aadd(aVetRet,{( cQAlias )->( BF_LOCALIZ ),0})
	If ( cQAlias )->( BF_QUANT ) >= (nQtdLocPec-nQtdSobra)
		aVetRet[Len(aVetRet),2] := nQtdLocPec-nQtdSobra
	   exit
	Else
		aVetRet[Len(aVetRet),2] := ( cQAlias )->( BF_QUANT )
	Endif
    nQtdSobra += aVetRet[Len(aVetRet),2]
	( cQAlias )->( DbSkip() )
Enddo
( cQAlias )->( DbCloseArea() )

If Len(aVetRet) == 0
	aVetRet := {{"",0}}
Endif
Return(aVetRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³OX001TSER³ Autor ³ Thiago			   º Data ³  01/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³Valida tipo de servico.									º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OX001TSER(cTipSer,cTipTem,lMensagem)

Default cTipSer   := M->VS4_TIPSER
Default cTipTem   := M->VS1_TIPTSV
Default lMensagem := .t.

//
If ExistBlock("OX001VTS")
	If !ExecBlock("OX001VTS",.f.,.f.,{cTipSer,cTipTem,lMensagem})
		Return .f.
	EndIf
EndIf
//

VOX->( DbSetOrder(1) )
lConsidera := .t.

VOI->(DbSetOrder(1))
VOI->(DbSeek( xFilial("VOI") + cTipTem ))
if VOI->VOI_CONVOX == "0"
	lConsidera := .f.
endif

If !VOX->( DbSeek( xFilial("VOX") + cTipSer + cTipTem ) ) .and. lConsidera
	If lMensagem
		Help(1,"  ","TPSERTEM")
    Endif
	Return(.f.)
EndIf

Return(.t.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³OX001TTPO³ Autor ³ Thiago			   º Data ³  01/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³Posiciona no tipo de tempo de servico.						º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OX001TTPO(cTipTem,cTipo)

dbSelectArea("VOI")
dbSetOrder(1)
dbSeek(xFilial("VOI")+cTipTem)
if cTipo == "G"
	if VOI->VOI_DEPGAR<>"1"
	   Return(.f.)
	Endif
Elseif cTipo == "I"
	if VOI->VOI_DEPINT<>"1"
	   Return(.f.)
	Endif
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OX001SERV ºAutor  ³Thiago              º Data ³  13/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o servico esta ativo ou nao.                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001SERV(cCodMar_,cCodSer_,cGruser_)
Local lRet := .f.
Private cCodMar:=cCodMar_,cCodSer:=cCodSer_,cGruser:=""
Private cAliasVO6  := "SQLVO6"
Private cAliasVO6A := "SQLVO6A"

Default cGruSer_ := M->VS4_GRUSER

cGruser:=cGruser_

cQuery := "SELECT VO6.R_E_C_N_O_ RECVO6 , VO6.VO6_CODMAR FROM "+RetSQLName("VO6")+" VO6 WHERE VO6.VO6_FILIAL='"+xFilial("VO6")+"' AND VO6.VO6_GRUSER = '"+cGruSer+"' AND VO6.VO6_CODSER = '"+cCodSer+"' AND VO6.D_E_L_E_T_ = ' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO6, .T., .T. )

if !( cAliasVO6 )->( Eof())
	Do While !( cAliasVO6 )->( Eof() )
		cRecNo := ( cAliasVO6 )->( RECVO6 )
		if cCodMar_ == ( cAliasVO6 )->VO6_CODMAR .or. Empty(( cAliasVO6 )->VO6_CODMAR)
			dbSelectArea("VO6")
			dbGoto(cRecNo)
			lRet := .t.
			Exit
		Endif
		( cAliasVO6 )->(DbSkip())

    Enddo

Else
	cQuery := "SELECT VO6.R_E_C_N_O_ RECVO6 FROM "+RetSQLName("VO6")+" VO6 WHERE VO6.VO6_FILIAL='"+xFilial("VO6")+"' AND VO6.VO6_CODSER = '"+cCodSer+"' AND VO6.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO6A, .T., .T. )
	if !( cAliasVO6 )->( Eof())
		Do While !( cAliasVO6A )->( Eof() )
			cRecNo := ( cAliasVO6A )->( RECVO6 )
			If ( !Empty(cGruSer) )
				lRet := .f.
			Else
				dbSelectArea("VO6")
				dbGoto(cRecNo)
				if cCodMar_ == VO6->VO6_CODMAR .or. Empty(VO6->VO6_CODMAR)
					lRet := .t.
					Exit
				Endif
			EndIf
			dbSelectArea(cAliasVO6A)
			( cAliasVO6A )->(DbSkip())

		Enddo
	Else
		lRet := .f.
	Endif
    ( cAliasVO6A )->( dbCloseArea() )
Endif
( cAliasVO6 )->( dbCloseArea() )

dbSelectArea("VO6")
if lRet
	If VO6->VO6_SERATI == "0"
		Help(" ",1,"SERINATIVO")
		lRet := .f.
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OX001GRSERºAutor  ³Thiago              º Data ³  13/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpar campo codite quando mudar o campo grupo do item.     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001GRSER(cCodMar_,cCodSer_,cGruser_)
Local lRet := .f.

Private cCodMar:=cCodMar_,cCodSer:=cCodSer_,cGruser:=cGruser_

Default cGruSer_ := M->VS4_GRUSER

if !Empty(cCodSer_)
	cGruser:=cGruser_
	If !FG_Seek("VO6","FG_MARSRV(cCodMar,cCodSer)+cGruSer+cCodSer",3,.f.,"VS4_DESSER","VO6_DESSER")
		If ( !Empty(cGruSer) .Or. !FG_Seek("VO6","FG_MARSRV(cCodMar,cCodSer)+cCodSer",2,.f.,"VS4_DESSER","VO6_DESSER") )
			oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_CODSER","aHeaderS")] := space(len(M->VS4_CODSER))
			oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_DESSER","aHeaderS")] := space(len(M->VS4_DESSER))
			oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_TIPSER","aHeaderS")] := space(len(M->VS4_TIPSER))
			oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_CODSEC","aHeaderS")] := space(len(M->VS4_CODSEC))
			M->VS4_CODSER := space(len(M->VS4_CODSER))
			M->VS4_DESSER := space(len(M->VS4_DESSER))
			M->VS4_TIPSER := space(len(M->VS4_TIPSER))
			M->VS4_CODSEC := space(len(M->VS4_CODSEC))
		EndIf
	EndIf
Endif

dbSelectArea("VOS")
dbSetOrder(1)
if !dbSeek(xFilial("VOS")+cCodMar_+M->VS4_GRUSER)
	dbSelectArea("VOS")
	dbSetOrder(2)
	if dbSeek(xFilial("VOS")+M->VS4_GRUSER)
		While !eof() .and. VOS->VOS_FILIAL + VOS->VOS_CODGRU == xFilial("VOS") + M->VS4_GRUSER
			if cCodMar_ == VOS->VOS_CODMAR .or. Empty(VOS->VOS_CODMAR)
				lRet := .t.
				exit
			Else
				lRet := .f.
			Endif
			DbSkip()
		Enddo
	Else
		lRet := .f.
	Endif
Else
	lRet := .t.
Endif

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OF001DEPINTºAutor  ³Thiago              º Data ³  13/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alteracao no departamento interno.						   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OF001DEPINT()
Local nCntFor := 0

If ReadVar() == "M->VS3_DEPINT"
	For nCntFor := 1 to len(oGetPecas:aCols)
		If !oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])]// .and. oGetPecas:nAt <> nCntFor
			if AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPINT]) <> M->VS3_DEPINT .and. ;
				!Empty(AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPINT]))
		         oGetPecas:aCols[nCntFor,nVS3DEPINT] := M->VS3_DEPINT
	        Endif
    	Endif
	Next
	For nCntFor := 1 to len(oGetServ:aCols)
		If !oGetServ:aCols[nCntFor,len(oGetServ:aCols[nCntFor])]// .and. oGetServ:nAt <> nCntFor
			if AllTrim(oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPINT","aHeaders")]) <> M->VS3_DEPINT .and. ;
				!Empty(AllTrim(oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPINT","aHeaderS")]))
	            oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPINT","aHeaders")] := M->VS3_DEPINT
	        Endif
    	Endif
	Next
	oGetPecas:oBrowse:Refresh()
	oGetServ:oBrowse:Refresh()
Elseif ReadVar() == "M->VS4_DEPINT"
	For nCntFor := 1 to len(oGetPecas:aCols)
		If !oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])]// .and. oGetPecas:nAt <> nCntFor
			if AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPINT]) <> M->VS4_DEPINT .and. ;
				!Empty(AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPINT]))
				oGetPecas:aCols[nCntFor,nVS3DEPINT] := M->VS4_DEPINT
			endif
		endif
	Next
	For nCntFor := 1 to len(oGetServ:aCols)
		If !oGetServ:aCols[nCntFor,len(oGetServ:aCols[nCntFor])]// .and. oGetServ:nAt <> nCntFor
			if AllTrim(oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPINT","aHeaderS")]) <> M->VS4_DEPINT .and. ;
				!Empty(AllTrim(oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPINT","aHeaderS")]))
				oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPINT","aHeaderS")] := M->VS4_DEPINT
			endif
		endif
	Next
	oGetPecas:oBrowse:Refresh()
	oGetServ:oBrowse:Refresh()
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OF001DEPGARºAutor  ³Thiago              º Data ³  24/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alteracao no departamento garantia.						   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OF001DEPGAR()
Local nCntFor := 0

If ReadVar() == "M->VS3_DEPGAR"
	For nCntFor := 1 to len(oGetPecas:aCols)
		If !oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])] .and. oGetPecas:nAt <> nCntFor
	    	if AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPGAR]) <> M->VS3_DEPGAR .and. ;
		    	!Empty(AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPGAR]))
		         oGetPecas:aCols[nCntFor,nVS3DEPGAR] := M->VS3_DEPGAR
	        Endif
	    Endif
	Next
	For nCntFor := 1 to len(oGetServ:aCols)
		If !oGetServ:aCols[nCntFor,len(oGetServ:aCols[nCntFor])] .and. oGetServ:nAt <> nCntFor
			if AllTrim(oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPGAR","aHeaderS")]) <> M->VS3_DEPGAR .and. ;
				!Empty(AllTrim(oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPGAR","aHeaderS")]))
	        	oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPGAR","aHeaderS")] := M->VS3_DEPGAR
	        Endif
	    Endif
	Next
	oGetPecas:oBrowse:Refresh()
	oGetServ:oBrowse:Refresh()
Elseif ReadVar() == "M->VS4_DEPGAR"
	For nCntFor := 1 to len(oGetPecas:aCols)
		If !oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])] .and. oGetPecas:nAt <> nCntFor
			if AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPGAR]) <> M->VS4_DEPGAR .and. ;
				!Empty(AllTrim(oGetPecas:aCols[nCntFor,nVS3DEPGAR]))
				oGetPecas:aCols[nCntFor,nVS3DEPGAR] := M->VS4_DEPGAR
			endif
		endif
	Next
	For nCntFor := 1 to len(oGetServ:aCols)
		If !oGetServ:aCols[nCntFor,len(oGetServ:aCols[nCntFor])] .and. oGetServ:nAt <> nCntFor
			if AllTrim(oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPGAR","aHeaderS")]) <> M->VS4_DEPGAR .and. ;
				!Empty(AllTrim(oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPGAR","aHeaderS")]))
				oGetServ:aCols[nCntFor,FG_POSVAR("VS4_DEPGAR","aHeaderS")] := M->VS4_DEPGAR
				return .f.
			endif
		endif
	Next
	oGetPecas:oBrowse:Refresh()
	oGetServ:oBrowse:Refresh()
Endif
Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OX001XC009 ºAutor  ³ Andre              º Data ³  03/06/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada da OFIXC009 e teclas de atalhos.      			   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001XC009()

//OFIXC009(2)
// Funcoes de Tecla
SETKEY(VK_F4,{|| OX001KEYF4() })
SETKEY(VK_F5,{|| OX001REQCPR() })
SETKEY(VK_F6,{|| OX001KEYF6() })
//If ExistFunc("OFIXC009")
//	SETKEY(VK_F7,{|| OFIXC009(2) })
//EndIf
If ExistBlock("OX001F8")
	SETKEY(VK_F8,{|| ExecBlock("OX001F8",.f.,.f.,{ M->VS1_NUMORC , M->VS3_GRUITE , M->VS3_CODITE }) })
EndIf
If ExistBlock("OX001F9")
	SETKEY(VK_F9,{|| ExecBlock("OX001F9",.f.,.f.,{ M->VS1_NUMORC , M->VS3_GRUITE , M->VS3_CODITE }) })
EndIf
If GetNewPar("MV_MIL0075","0") $ "1/S" // Mostrar Tela ( 1=Sim / 0=Nao )
	SETKEY(VK_F10,{|| OX0010145_TelaTipoPagamento() } )
EndIf

Return(.t.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OX001CONSPEC ºAutor  ³Thiago            º Data ³  04/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada da M_CONSPEC e teclas de atalhos.                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001CONSPEC()


// Funcoes de Tecla
SETKEY(VK_F4,{|| OX001KEYF4() })
SETKEY(VK_F5,{|| OX001REQCPR() })
SETKEY(VK_F6,{|| OX001KEYF6() })

If ExistBlock("OX001F8")
	SETKEY(VK_F8,{|| ExecBlock("OX001F8",.f.,.f.,{ M->VS1_NUMORC , M->VS3_GRUITE , M->VS3_CODITE }) })
EndIf
If ExistBlock("OX001F9")
	SETKEY(VK_F9,{|| ExecBlock("OX001F9",.f.,.f.,{ M->VS1_NUMORC , M->VS3_GRUITE , M->VS3_CODITE }) })
EndIf
If GetNewPar("MV_MIL0075","0") $ "1/S" // Mostrar Tela ( 1=Sim / 0=Nao )
	SETKEY(VK_F10,{|| OX0010145_TelaTipoPagamento() } )
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_FORMULA ºAutor  ³Thiago              º Data ³  05/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Formula para calculo do preco da peca.					   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FORMULA(_cGruIte)

	Local cFormul := ""

	default _cGruIte := ""

	if ! empty(M->VS1_FORMUL)
		return M->VS1_FORMUL
	endif

	If OX0010231_Cliente_Funcionario( M->VS1_CLIFAT , M->VS1_LOJA ) // Verifica se o Cliente se trata de um Funcionario da Empresa
		cFormul := GetNewPar("MV_MIL0174","") // Formula utilizada para Venda de Peças para Funcionarios da Empresa
	Else

		if ! empty(_cGruIte)
			SBM->(dbSetOrder(1))
			SBM->(MsSeek(xFilial("SBM") + _cGruIte))
			if !Empty(SBM->BM_FORMUL)
				cFormul := SBM->BM_FORMUL
			endif
		endif

	Endif

	if Empty(cFormul)
		cFormul := &(cMVFMLPECA)
	Endif

	oEnch:Refresh()

Return(cFormul)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_REPSEC ºAutor  ³Thiago              º Data ³  30/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Repete Secao digitada na aCols para as demais.   		   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_REPSEC()

If oGetServ:nAt == 1 .or. VISUALIZA
   Return(.t.)
Endif
if Empty(oGetServ:aCols[oGetServ:nAt ,fg_posvar("VS4_CODSEC","aHeaderS")])
	oGetServ:aCols[oGetServ:nAt ,fg_posvar("VS4_CODSEC","aHeaderS")] := M->VS4_CODSEC := oGetServ:aCols[oGetServ:nAt-1 ,fg_posvar("VS4_CODSEC","aHeaderS")]
EndIf
If Empty(oGetServ:aCols[oGetServ:nAt ,fg_posvar("VS4_DEPINT","aHeaderS")])
	oGetServ:aCols[oGetServ:nAt ,fg_posvar("VS4_DEPINT","aHeaderS")] := M->VS4_DEPINT := oGetServ:aCols[oGetServ:nAt-1 ,fg_posvar("VS4_DEPINT","aHeaderS")]
EndIf
If Empty(oGetServ:aCols[oGetServ:nAt ,fg_posvar("VS4_DEPGAR","aHeaderS")])
	oGetServ:aCols[oGetServ:nAt ,fg_posvar("VS4_DEPGAR","aHeaderS")] := M->VS4_DEPGAR := oGetServ:aCols[oGetServ:nAt-1 ,fg_posvar("VS4_DEPGAR","aHeaderS")]
EndIf

oGetServ:oBrowse:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_REPDEP ºAutor  ³Thiago              º Data ³  30/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Repete departament garantia e interno digitada na aCols     º±±
±±º		     ³ para as demais.   										   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_REPDEP()

If oGetPecas:nAt == 1  .or. VISUALIZA
   Return(.t.)
Endif
If Empty(oGetPecas:aCols[oGetPecas:nAt ,nVS3DEPINT])
	oGetPecas:aCols[oGetPecas:nAt ,nVS3DEPINT] := M->VS3_DEPINT := oGetPecas:aCols[oGetPecas:nAt-1 ,nVS3DEPINT]
EndIf
If Empty(oGetPecas:aCols[oGetPecas:nAt ,nVS3DEPGAR])
	oGetPecas:aCols[oGetPecas:nAt ,nVS3DEPGAR] := M->VS3_DEPGAR := oGetPecas:aCols[oGetPecas:nAt-1 ,nVS3DEPGAR]
EndIf

oGetPecas:oBrowse:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OXTIPTEM100³ Autor ³ Manoel               ³ Data ³ 13/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atribui valor para a Formula de Preco de acordo com T.Tempo ³±±
±±³          ³SUBSTITUICAO DA FUNCAO FS_TIPTEM100 DO OFIOM110             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Oficina                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXTIPTEM100()

Local lRet     := .T.
Local nPosAltTT := 0
Local nCntFor  := 0
Local nCntFor2 := 0
Local cVS1_TIPTEM := M->VS1_TIPTEM
Local cVS1_TIPTSV := M->VS1_TIPTSV
Local oOficina := DMS_Oficina():New()

If M->VS1_TIPORC <> "2"
	Return .t.
EndIf

If Readvar() == "M->VS1_TIPTEM"

	If oOficina:TipoTempoBloqueado(M->VS1_TIPTEM,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
		Return .f.
	EndIf
	If VOI->VOI_VALPEC <> M->VS1_FORMUL
		if !MsgYesNo(STR0265,STR0025) // A mudança do Tipo de Tempo acarretará na mudança de valores do orçamento, pois a fórmula de cálculo está sendo alterada! Deseja Continuar?
			Return .f.
		Endif
	Endif

	If (M->VS1_STARES == "1" .or. M->VS1_STARES == "2" ) .and.; // Reservado ou Parcialmente
		VOI->VOI_ARMORI <> M->VS3_LOCAL // Armazem diferente

		MsgStop(STR0366,STR0025)//Não é permitida alteração de tipo de tempo quando o armazem de origem é diferente e o orçamento está reservado!
		Return .f.

	Endif

	If Empty(VOI->VOI_VALPEC)  //FNC 1834/2010 - BOBY
		MsgStop(STR0264)       //Campo ->'Fórmula Vlr' no Cadastro de Tipo de Tempo, não Informado, Informe-o para Prosseguir o Orçamento
		Return .f.
	Else
		FG_ATRVAL("VS1_FORMUL","VOI->VOI_VALPEC")
	EndIf

	FG_VALIDA(,"VEGT1M->VS1_FORMUL*","VS1_NOMFOR := VEG_DESCRI")

	// Atualiza Peças

	If OX001TPTPO(,.t.)
		For nPosAltTT := 1 to Len(oGetPecas:aCols)
			If !oGetPecas:aCols[nPosAltTT,len(aHeaderP)+1] // Peça ativa
				oGetPecas:nAt := nPosAltTT
				FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)

				__ReadVar := 'M->VS1_PERDES'
				If OX001VLDENC(nPosAltTT)

					M->VS3_LOCAL := OX0010105_ArmazemOrigem()
					oGetPecas:aCols[oGetPecas:nAt,nVS3LOCAL] := M->VS3_LOCAL

					lPPrepec := .t.  // Controla se sera executada a funcao OX001PREPEC
					__ReadVar := 'M->VS3_CODITE'
					oGetPecas:nAt := nPosAltTT
					FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
					OX001PREPEC(,.t.)
					oGetPecas:oBrowse:refresh()
				EndIf
			EndIf
		Next
		OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
	Else
		M->VS1_TIPTEM := cVS1_TIPTEM
		lRet     := .f.
	Endif

ElseIf Readvar() == "M->VS1_TIPTSV"

	If oOficina:TipoTempoBloqueado(M->VS1_TIPTSV,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
		Return .f.
	EndIf
	If OX001TPTPO(,.t.)
		// Atualiza Serviços
		for nCntFor := 1 to Len(oGetServ:aCols)
			if !Empty(oGetServ:aCols[nCntFor,fg_posvar("VS4_TIPSER","aHeaderS")])
				M->VS4_TIPSER := oGetServ:aCols[nCntFor,fg_posvar("VS4_TIPSER","aHeaderS")]
				For nCntFor2 := 1 to Len(aHeaderS)
					&("M->"+aHeaderS[nCntFor2,2]) := oGetServ:aCols[nCntFor,nCntFor2]
				next
				__ReadVar := 'M->VS4_TIPSER'
				oGetServ:nAt := nCntFor
				OX001FSOK()
				oGetServ:oBrowse:refresh()
		  endif
		next
		OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
	Else
		M->VS1_TIPTSV := cVS1_TIPTSV
		lRet     := .f.
	Endif
Endif
//

if lRet
	if !Empty(M->VS1_CHASSI)
		DbSelectArea("VV1")
		DbSetOrder(2)
		If DbSeek(xFilial("VV1")+Alltrim(M->VS1_CHASSI))
			For nCntFor := 1 to Len(aFatParS)
				If !aFatParS[nCntFor,1]
					Loop
				EndIf
				If aFatParS[nCntFor,6] == "1"	// FABRICANTE DO VEICULO
					VE4->(DbSetOrder(1))
					VE4->(DbSeek(xFilial("VE4")+VV1->VV1_CODMAR))
					M->VS1_CLIFAT := VE4->VE4_CODFAB
					M->VS1_LOJA   := VE4->VE4_LOJA
				ElseIf VOI->VOI_USAPRO == "2"	// CLIENTE PADRAO
					M->VS1_CLIFAT := aFatParS[nCntFor,3]
					M->VS1_LOJA   := aFatParS[nCntFor,4]
				Endif
			Next
			if Empty(M->VS1_CLIFAT)
				M->VS1_CLIFAT := VV1->VV1_PROATU
				M->VS1_LOJA   := VV1->VV1_LJPATU
			Endif
			If MaFisFound('NF')
				MaFisRef("NF_CODCLIFOR",,M->VS1_CLIFAT)
				MaFisRef("NF_LOJA",,M->VS1_LOJA)
			endif
		endif
		if SA1->(dbSeek(xFilial("SA1")+M->VS1_CLIFAT+M->VS1_LOJA))
			M->VS1_NCLIFT := SA1->A1_NOME
		endif
		//
		For nPosAltTT := 1 to Len(oGetPecas:aCols)
			If !oGetPecas:aCols[nPosAltTT,len(aHeaderP)+1] // Peça ativa

				oGetPecas:nAt := nPosAltTT
				FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)

				oGetPecas:aCols[oGetPecas:nAt,nVS3OPER] := VOI->VOI_CODOPE
				M->VS3_OPER := VOI->VOI_CODOPE

				lPPrepec := .t.  // Controla se sera executada a funcao OX001PREPEC
				__ReadVar := 'M->VS3_OPER'
				oGetPecas:nAt := nPosAltTT
				FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
				OX001PREPEC()
				oGetPecas:oBrowse:refresh()
				
			EndIf
		Next
		OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)

	endif
endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OX001ELTT   | Autor ³ Luis Delorme        ³ Data ³ 31/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validação do Vetor de Faturar para da escolha de tipo de   ³±±
±±³          ³ tempo                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Oficina                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001ELTT()
Local  nCntFor
for nCntFor := 1 to Len(aFatParS)
	if aFatParS[nCntFor,1]
		return .t.
	endif
next
MsgInfo(STR0267,STR0025)
return .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OX001CLAW   | Autor ³ Rubens Takahashi    ³ Data ³ 28/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importacao de Pecas e Servicos de Campanhas Scania         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Oficina                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OX001CLAW()

Local nAuxRecno
Local cAuxAlias := Alias()
Local nCont
Local lPrimSer := .f.
Local lPrimPec := .f.
Local cAuxCampOK := ""

Local aAuxNewLine := {}

Local nCntFor2

If M->VS1_TIPORC <> "2"
	MsgInfo(STR0286,STR0025) // "Opção válida somente para orçamento de oficina."
	Return
EndIf

If Empty(M->VS1_CHASSI)
	MsgInfo(STR0284,STR0025) // "Favor informar um Chassi."
	Return
EndIf

If M->VS1_CODMAR <> FMX_RETMAR("SCA")
	MsgInfo(STR0285,STR0025) // "Favor selecionar um chassi Scania"
	Return
EndIf

// Valida se é possível adicionar um inconveniente ...
If !OX001VLINC(@lPrimSer,@lPrimPec)
	Return
EndIf
//

aBkpInc := aClone(oGetInconv:aCols)
aBkpPec := aClone(oGetPecas:aCols)
aBkpSer := aClone(oGetServ:aCols)
MaFisSave()

Begin Sequence

nAuxRecno := VV1->(Recno())
aRetClaw := {}

VV1->(DbSetOrder(2))
VV1->(dbSeek( xFilial("VV1") + M->VS1_CHASSI ))
dbSelectArea("VS1")
OFICSC01(.t.,2,@aRetClaw,.t.)

If Len(aRetClaw) <> 0

	// Verifica se a campanha já está no orcamento ...
	For nCont := 1 to Len(aRetClaw[1])
		If OX001INCON(,Space(TamSX3("VST_GRUINC")[1]),Space(TamSX3("VST_CODINC")[1]),aRetClaw[1,nCont],"D")
			cAuxCampOK += aRetClaw[1,nCont] + "/"
		EndIf
	Next nCont
	//
	OX001RefNF()
	//
	// Verifica se retornou alguma peca ...
	If Len(aRetClaw[2]) > 0

		// Cria uma linha em branco para adicionar na aCols no procesamento das pecas ...
		aAuxNewLine := Array( nUsadoPX01+1 )
		aAuxNewLine[nUsadoPX01+1]:=.F.
		For nCont := 1 to nUsadoPX01
			If IsHeadRec(aHeaderP[nCont,2])
				aAuxNewLine[nCont] := 0
			ElseIf IsHeadAlias(aHeaderP[nCont,2])
				aAuxNewLine[nCont] := "VS3"
			Else
				aAuxNewLine[nCont] := CriaVar( aHeaderP[nCont,2] )
			EndIf
		Next
		//

		nPECCAMPAN := FG_POSVAR("PEC_CAMPAN","aRetClaw[2,1]")
		nPECGRUITE := FG_POSVAR("PEC_GRUITE","aRetClaw[2,1]")
		nPECCODITE := FG_POSVAR("PEC_CODITE","aRetClaw[2,1]")
		nPECDESITE := FG_POSVAR("PEC_DESITE","aRetClaw[2,1]")
		nPECQTDITE := FG_POSVAR("PEC_QTDITE","aRetClaw[2,1]")
		nPECOPER   := FG_POSVAR("PEC_OPER"  ,"aRetClaw[2,1]")
		nPECCODTES := FG_POSVAR("PEC_CODTES","aRetClaw[2,1]")
		nPECDEPGAR := FG_POSVAR("PEC_DEPGAR","aRetClaw[2,1]")

		VOI->(dbSetOrder(1))
		VOI->(MsSeek(xFilial("VOI")+M->VS1_TIPTEM))
		For nCont := 1 to Len(aRetClaw[2,2])

			// Só importa pecas de Campanha com Inconvenientes criados
			If !aRetClaw[2,2,nCont,nPECCAMPAN] $ cAuxCampOK
				Loop
			EndIf
			//

			// Se não informado a quantidade, nao importa ...
			If aRetClaw[2,2,nCont,nPECQTDITE] == 0
				Loop
			EndIf
			//

			if !lPrimPec
				AADD(oGetPecas:aCols,aClone(aAuxNewLine))
			endif
			lPrimPec := .f.

			oGetPecas:nAt := Len(oGetPecas:aCols)
			n := oGetPecas:nAt

			SB1->(DBSetOrder(7))
			SB1->(DBSeek(xFilial("SB1") + aRetClaw[2,2,nCont,nPECGRUITE]+ aRetClaw[2,2,nCont,nPECCODITE]))

			aVetCmp := {}

			aAdd(aVetCmp,{"VS3_GRUITE",aRetClaw[2,2,nCont,nPECGRUITE] } )
			aAdd(aVetCmp,{"VS3_DESINC",aRetClaw[2,2,nCont,nPECCAMPAN] } )
			aAdd(aVetCmp,{"VS3_CODITE",aRetClaw[2,2,nCont,nPECCODITE] } )
			aAdd(aVetCmp,{"VS3_FORMUL",M->VS1_FORMUL} )
			aAdd(aVetCmp,{"VS3_QTDITE",aRetClaw[2,2,nCont,nPECQTDITE] } )

			If !Empty(aRetClaw[2,2,nCont,nPECOPER])
				aAdd(aVetCmp,{"VS3_OPER",aRetClaw[2,2,nCont,nPECOPER]})
			EndIf

			cTesCMP := ""
			If !Empty(aRetClaw[2,2,nCont,nPECCODTES])
				cTesCMP := aRetClaw[2,2,nCont,nPECCODTES]
			Else
				If !Empty(aRetClaw[2,2,nCont,nPECOPER])
					cTesCMP := OX001TESINT(aRetClaw[2,2,nCont,nPECOPER])
				EndIf

				If Empty(cTesCMP)
					cTesCmp := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
					if !Empty(VOI->VOI_CODOPE)
						cTesCmp := OX001TESINT(VOI->VOI_CODOPE)
					endif
				EndIf
			EndIf
			aAdd(aVetCmp,{"VS3_CODTES",cTesCmp})

			If !Empty(aRetClaw[2,2,nCont,nPECDEPGAR])
				aAdd(aVetCmp,{"VS3_DEPGAR",aRetClaw[2,2,nCont,nPECDEPGAR] })
			EndIf

			RegToMemory("VS3",.t.)
			//
			for nCntFor2 := 1 to Len(aVetCmp)
				oGetPecas:nAt := Len(oGetPecas:aCols)
				n := oGetPecas:nAt
				__ReadVar := "M->"+aVetCmp[nCntFor2,1]
				&("M->"+aVetCmp[nCntFor2,1]) := aVetCmp[nCntFor2,2]
				oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR(aVetCmp[nCntFor2,1],"aHeaderP")] := aVetCmp[nCntFor2,2]
				if !OX001FPOK(,,.f.,.f.)
					Break
				endif
			next
			//
		Next nCont
	EndIf
	//

	// Verifica se retornou algum servico ...
	If Len(aRetClaw[3]) > 0

		// Cria uma linha em branco para adicionar na aCols no processamento dos servicos ...
		aAuxNewLine := Array( nUsadoS + 1 )
		aAuxNewLine[nUsadoS+1] := .f.
		For nCont := 1 to nUsadoS
			aAuxNewLine[nCont] := Criavar( aHeaderS[nCont,2] )
		Next nCont
		//

		nSERCAMPAN = FG_POSVAR("SER_CAMPAN","aRetClaw[3,1]")
		nSERGRUSER = FG_POSVAR("SER_GRUSER","aRetClaw[3,1]")
		nSERCODSER = FG_POSVAR("SER_CODSER","aRetClaw[3,1]")
		nSERTEMPAD = FG_POSVAR("SER_TEMPAD","aRetClaw[3,1]")
		nSERTIPSER = FG_POSVAR("SER_TIPSER","aRetClaw[3,1]")
		nSERDEPGAR = FG_POSVAR("SER_DEPGAR","aRetClaw[3,1]")
		nSERCODSEC = FG_POSVAR("SER_CODSEC","aRetClaw[3,1]")

		VOI->(dbSetOrder(1))
		VOI->(MsSeek( xFilial("VOI") + M->VS1_TIPTSV ))
		For nCont := 1 to Len(aRetClaw[3,2])

			// Só importa pecas de Campanha com Inconvenientes criados
			If !aRetClaw[3,2,nCont,nSERCAMPAN] $ cAuxCampOK
				Loop
			EndIf
			//

			If !lPrimSer
				AADD( oGetServ:aCols, aClone(aAuxNewLine))
			EndIf
			lPrimSer := .f.

			n := oGetServ:nAt := Len(oGetServ:aCols)

			aVetCmp := {}

			AADD( aVetCmp , { "VS4_GRUSER" , aRetClaw[3,2,nCont,nSERGRUSER] } )
			AADD( aVetCmp , { "VS4_DESINC" , aRetClaw[3,2,nCont,nSERCAMPAN] } )
			AADD( aVetCmp , { "VS4_CODSER" , aRetClaw[3,2,nCont,nSERCODSER] } )
			If !Empty(aRetClaw[3,2,nCont,nSERTIPSER])
				AADD( aVetCmp , { "VS4_TIPSER" , aRetClaw[3,2,nCont,nSERTIPSER] } )
			EndIf
			If !Empty(aRetClaw[3,2,nCont,nSERCODSEC])
				AADD( aVetCmp , { "VS4_CODSEC" , aRetClaw[3,2,nCont,nSERCODSEC] } )
			EndIf
			If !Empty(aRetClaw[3,2,nCont,nSERDEPGAR])
				AADD( aVetCmp , { "VS4_DEPGAR" , aRetClaw[3,2,nCont,nSERDEPGAR] })
			EndIf

			RegToMemory("VS4",.t.)

			VO6->(dbSetOrder(3))
			If VO6->(dbSeek(xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,aRetClaw[3,2,nCont,nSERCODSER])+aRetClaw[3,2,nCont,nSERGRUSER]+aRetClaw[3,2,nCont,nSERCODSER]))
				M->VS4_DESSER := VO6->VO6_DESSER
			EndIf
			If !Empty(aRetClaw[3,2,nCont,nSERTIPSER])
				VOK->(dbSetOrder(1))
				VOK->(dbSeek( xFilial("VOK") + aRetClaw[3,2,nCont,nSERTIPSER]))
			EndIf

			for nCntFor2 := 1 to Len(aVetCmp)

				oGetServ:nAt := Len(oGetServ:aCols)
				n := oGetServ:nAt
				__ReadVar := "M->"+aVetCmp[nCntFor2,1]
				&("M->"+aVetCmp[nCntFor2,1]) := aVetCmp[nCntFor2,2]
				oGetServ:aCols[oGetServ:nAt,FG_POSVAR(aVetCmp[nCntFor2,1],"aHeaderS")] := aVetCmp[nCntFor2,2]
				if !OX001FSOK()
					Break
				endif
			next


		Next nCont

	EndIf
	//
EndIf
Recover

	oGetInconv:aCols := aClone(aBkpInc)
	oGetPecas:aCols := aClone(aBkpPec)
	oGetServ:aCols := aClone(aBkpSer)
	MaFisRestore()
	OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)

End Sequence

dbSelectArea(cAuxAlias)
oGetPecas:oBrowse:refresh()
oGetServ:oBrowse:refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OX001TOTPF  | Autor ³Carla C e Manoel     ³ Data ³ 24/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza planilha financeira de acordo com os valores infor³±±
±±³          ³ mados no acols. (Evitar problema de arredondamento).       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Oficina                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001TOTPF(cPar,cTip)
Local nValret   := 0
Local nValretD  := 0
Local nCntFor   := 0
Local cQueryTPF := ""
Default cTip := ""

If cPar == "ON" // On line

	For nCntFor := 1 to Len(oGetPecas:aCols)
		if !oGetPecas:aCols[nCntFor,len(oGetPecas:aCols[nCntFor])] .and. oGetPecas:aCols[nCntFor,nVS3QTDITE] > 0  .and. Empty(oGetPecas:aCols[nCntFor,nVS3MOTPED])
			nValRet += oGetPecas:aCols[nCntFor,nVS3VALTOT]
			nValRetD += oGetPecas:aCols[nCntFor,nVS3DIFAL]
		Endif
	Next
	for nCntFor := 1 to Len(oGetServ:aCols)
		if !oGetServ:aCols[nCntFor,len(oGetServ:aCols[nCntFor])]
			nValRet += oGetServ:aCols[nCntFor,FG_POSVAR("VS4_VALTOT","aHeaderS")]
		Endif
	next

Elseif cPar == "OF" // Off line

	cQueryTPF := "SELECT SUM(VS4.VS4_VALTOT) "
	cQueryTPF += "FROM "
	cQueryTPF += RetSqlName( "VS4" ) + " VS4 "
	cQueryTPF += "WHERE "
	cQueryTPF += "VS4.VS4_FILIAL='"+ xFilial("VS4")+ "' AND VS4.VS4_NUMORC = '"+VS1->VS1_NUMORC+"' AND "
	cQueryTPF += "VS4.D_E_L_E_T_=' '"
	nValRet := FM_SQL(cQueryTPF)

	cQueryTPF := "SELECT SUM(VS3.VS3_VALTOT) "
	cQueryTPF += "FROM "
	cQueryTPF += RetSqlName( "VS3" ) + " VS3 "
	cQueryTPF += "WHERE "
	cQueryTPF += "VS3.VS3_FILIAL='"+ xFilial("VS3")+ "' AND VS3.VS3_NUMORC = '"+VS1->VS1_NUMORC+"' AND "
	cQueryTPF += "VS3.VS3_QTDITE > 0 AND VS3.VS3_MOTPED = ' ' AND VS3.D_E_L_E_T_=' '"
	nValRet += FM_SQL(cQueryTPF)

Endif

Return Iif(cTip=="",nValret,nValRetD)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OX001INC    | Autor ³Thiago			    ³ Data ³ 23/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao no grupo do inconveniente.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Oficina                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OX001INC(cCodMar,cGruInc)
Local lRet := .f.
Local cAliasVSK := "SQLVSK"

cQuery := "SELECT VSK.R_E_C_N_O_ RECVSK , VSK.VSK_CODMAR "
cQuery += "FROM "+RetSQLName("VSK")+" VSK "
cQuery += "WHERE VSK.VSK_FILIAL='"+xFilial("VSK")+"' AND VSK.VSK_CODGRU = '"+cGruInc+"' AND VSK.D_E_L_E_T_ = ' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVSK, .T., .T. )

Do While !( cAliasVSK )->( Eof() )

	if ( cAliasVSK )->VSK_CODMAR == cCodMar .or. Empty(( cAliasVSK )->VSK_CODMAR)
		lRet := .t.
		Exit
	Else
		lRet := .f.
 	Endif
	dbSelectArea(cAliasVSK)
	( cAliasVSK )->(dbSkip())
Enddo

( cAliasVSK )->( dbCloseArea() )

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OX001TELA   | Autor ³Luis Delorme         ³ Data ³ 20/05/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela no fecto da DIALOG                       			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OX001TELA(nOpc)
if ExistBlock("OX001TEL")
	ExecBlock("OX001TEL",.f.,.f.,{nOpc})
Endif
//
If nOpc <> 2 .and. nOpc <> 5
	OX0010271_PercentualRemuneracao( .t. ) // Retorna o % de Remuneração
EndIf
//
return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OX001REGIMP | Autor ³ Rubens Takahashi    ³ Data ³ 25/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Registra impressao dos itens de reserva incondincional     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001REGIMP(lAvancaFase)

Local aArea := GetArea()
Local nPosGet
Local nVS3SEQUEN, nVS3IMPRES
Local cOrcamto

Default lAvancaFase := .t.

If !lAvancaFase
	nVS3SEQUEN := FG_POSVAR("VS3_SEQUEN","aHeaderP")
	nVS3IMPRES := FG_POSVAR("VS3_IMPRES","aHeaderP")
EndIf

cOrcamto := IIf( lAvancaFase , VS1->VS1_NUMORC , M->VS1_NUMORC )

dbSelectArea("VS3")
dbGoTo(2)
dbSeek( xFilial("VS3") + cOrcamto )
While !VS3->(Eof()) .AND. VS3->VS3_FILIAL == xFilial("VS3") .AND. VS3->VS3_NUMORC == cOrcamto

	If VS3->VS3_IMPRES == "0"
		RecLock("VS3" , .F. )
		VS3->VS3_IMPRES := "1"
		VS3->(MsUnLock())

		If !lAvancaFase .and. (nPosGet := aScan( oGetPecas:aCols,{ |x| x[nVS3SEQUEN] == VS3->VS3_SEQUEN })) > 0
			oGetPecas:aCols[ nPosGet , nVS3IMPRES ] := "1"
		EndIf
	EndIf

	VS3->(DbSkip())

End

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXX001RBO  | Autor ³ vinicius gati       ³ Data ³ 12/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ faz sugestao de compras de backorder                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXX001RBO()
	OX001GSUG(4, .T.) // 4 => Alteração
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXX001CBO  | Autor ³ vinicius gati       ³ Data ³ 12/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta sugestao de compras de backorder / Não BackOrder  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXX001CBO(cTipCsn)
If cTipCsn == "BO" // Consulta Sugestão de Compras BackOrder
	OFIOC527(VS1_NUMORC,"1")
ElseIf cTipCsn == "NBO" // Consulta Sugestão de Compras Não BackOrder
	OFIOC527(VS1_NUMORC,"0")
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OX001ORCBO | Autor ³ vinicius gati       ³ Data ³ 07/12/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ retorna se o orçamento tem backorder                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001ORCBO(cNumOrcPed)
return FM_SQL("SELECT COUNT(*) FROM "+RetSqlName('VE6')+" WHERE VE6_FILIAL='"+xFilial('VE6')+"' AND VE6_INDREG='4' AND VE6_ORIREQ='3' AND VE6_NUMORC='"+cNumOrcPed+"' AND D_E_L_E_T_=' '" ) > 0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OX001CriRLt ºAutor  ³Renato Vinicius     º Data ³ 10/11/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Desmembramento do item em lotes caso a quantidade solicita-º±±
±±º          ³ da seja maior que o saldo do lote inicial (Criacao do VS3) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OX001CriRLt(nSldLote,nPosAcolsLt)
	Local aVS3 := {}
	Local nY

	DEFAULT nPosAcolsLt := 1
	Default nSldLote := 0

	For nY := 1 To VS3->(FCount())
		aadd(aVS3,VS3->(FieldGet(nY)))
	Next nY

	RecLock("VS3",.T.)
	For nY := 1 To Len(aVS3)
		If !"_MSIDENT"$VS3->(FieldName(nY))
			if VS3->(FieldName(nY)) <> "VS3_LOTECT" .and. VS3->(FieldName(nY)) <> "VS3_NUMLOT" .and. VS3->(FieldName(nY)) <> "VS3_DTVALI"
				FieldPut(nY,aVS3[nY])
			Endif
		EndIf
	Next nY

	VS3->VS3_QTDITE := nSldLote

	MsUnLock()

	AADD(oGetPecas:aCols,AClone(oGetPecas:aCols[nPosAcolsLt]))
	oGetPecas:aCols[Len(oGetPecas:aCols),nUsadoPX01+1]:=.F.
	For nY:=1 to nUsadoPX01
		If aHeaderP[nY,2] == "VS3_LOTECT" .or. aHeaderP[nY,2] == "VS3_NUMLOT"
			oGetPecas:aCols[Len(oGetPecas:aCols),nY]:= space(TamSx3("VS3_LOTECT")[1])
		Elseif aHeaderP[nY,2] == "VS3_NUMLOT"
			oGetPecas:aCols[Len(oGetPecas:aCols),nY]:= space(TamSx3("VS3_NUMLOT")[1])
		Elseif aHeaderP[nY,2] == "VS3_DTVALI"
			oGetPecas:aCols[Len(oGetPecas:aCols),nY]:= cTod("")
		ElseIf IsHeadRec(aHeaderP[nY,2])
			oGetPecas:aCols[Len(oGetPecas:aCols),nY] := 0
		ElseIf IsHeadAlias(aHeaderP[nY,2])
			oGetPecas:aCols[Len(oGetPecas:aCols),nY] := "VS3"
		Else
			oGetPecas:aCols[Len(oGetPecas:aCols),nY]:= FieldGet(ColumnPos(aHeaderP[nY,2]))
		Endif
		If aHeaderP[nY,2] == "VS3_SEQUEN"
			oGetPecas:aCols[Len(oGetPecas:aCols),nY]:= StrZero(Len(oGetPecas:aCols),TamSX3("VS3_SEQUEN")[1])
		Endif
	Next
	oGetPecas:nAt := Len(oGetPecas:aCols)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OX001TESINT   ºAutor ³ Rubens Takahashi  º Data ³ 15/01/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna TES Inteligente                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OX001TESINT(cCodOper)
	local nPosCliente := aScan(CacheTESInt, { |x| x[1] == M->VS1_CLIFAT + M->VS1_LOJA + M->VS1_TIPCLI })
	local nPosTesInt := 0
	local lCache := .t.
	local cRetorno

	if nPosCliente == 0
		AADD( CacheTESInt, {M->VS1_CLIFAT + M->VS1_LOJA + M->VS1_TIPCLI , {} })
		nPosCliente := len(CacheTESInt)
		lCache := .f.
	endif

	if lCache .and.	(nPosTesInt := aScan(CacheTESInt[nPosCliente,2], { |x| x[1] == cCodOper + SB1->B1_COD })) <> 0
		cRetorno := CacheTESInt[nPosCliente,2,nPosTesInt,2]
		return cRetorno
	endif

	cRetorno := MaTesInt(2,cCodOper,M->VS1_CLIFAT,M->VS1_LOJA,"C",SB1->B1_COD,,M->VS1_TIPCLI)

	//AADD( CacheTESInt, { M->VS1_CLIFAT + M->VS1_LOJA + M->VS1_TIPCLI , { cCodOper + SB1->B1_COD , cRetorno} })
	AADD( CacheTESInt[nPosCliente,2], { cCodOper + SB1->B1_COD , cRetorno} )

Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OX001RecFis   ºAutor ³ Thiago/Manoel     º Data ³ 17/06/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recalculo do fiscal.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001RecFis(cReferencia,xValor,cChamadoPor)

Local ny
Local nItem         := 0 // variável criada para não dar erro no loop quando o parâmetro MV_MIl0011 == "1"
Local aArea         := GetArea()
Local nSlvN         := n
Local nSlvNGS       := oGetServ:nAt
Local nSlvNGP       := oGetPecas:nAt
Local lAltReadVar   := .f.

Default cChamadoPor := ""

nIniRecFis := timefull()

If Left(cReferencia,2) == "NF"

	If MaFisFound("NF").And.!(MaFisRet(,cReferencia)==xValor)
	//	MaFisAlt(cReferencia,xValor)
		MaFisRef(cReferencia,,xValor)
	EndIf

	For ny := 1 to Len(oGetPecas:aCols)

		if !oGetPecas:aCols[ny,Len(oGetPecas:aCols[ny])] .and. !Empty(oGetPecas:aCols[ny,nVS3CODITE])

			If cChamadoPor == "OX001LVS34"

				oProcTTP:IncRegua2()
				nTotFis ++
				aAdd(aNumP,{ny,nTotFis})
				nItem += 1
				n := aNumP[nItem,2]
				//
				cACodGrp := oGetPecas:aCols[ny,nVS3GRUITE]
				cACodIte := oGetPecas:aCols[ny,nVS3CODITE]
				//
				DBSelectArea("SB1")
				DBSetOrder(7)
				DBSeek(xFilial("SB1")+cACodGrp+cACodIte)

				//CONOUT( cACodGrp + "-" + cACodIte + cvaltochar(oGetPecas:aCols[ny,nVS3QTDITE]) )

				SF4->(MsSeek(xFilial("SF4")+oGetPecas:aCols[ny,nVS3CODTES]))

				MaFisIniLoad(n,{	;
					SB1->B1_COD,;
					oGetPecas:aCols[ny,nVS3CODTES],;
					" "  ,;
					oGetPecas:aCols[ny,nVS3QTDITE],;
					"",;
					"",;
					SB1->(RecNo()),;	//IT_RECNOSB1
					SF4->(RecNo()),;	//IT_RECNOSF4
					0 }) 			//IT_RECORI
				//[01] Caracter - Código do produto
				//[02] Caracter - Código da TES
				//[03] Numérico - Valor do ISS do item
				//[04] Numérico - Quantidade do Item
				//[05] Caracter - Numero da NF Original
				//[06] Caracter - Serie da NF Original
				//[07] Numérico - RecNo do SB1
				//[08] Numérico - RecNo do SF4
				//[09] Numérico - RecNo da NF Original (SD1/SD2)
				//[10] Caracter - Lote do Produto
				//[11] Caracter - Sub-Lote Produto
				//		aLoad[12] := Space(Len(aLoad[1])) 	// Codigo do Produto Fiscal
				//		aLoad[13] := 0 						// Recno do Produto Fiscal
				//		aLoad[14] := Space(TamSX3("D1_OPER")[1]) // Tipo de Operação

				//MaFisLoad("IT_PRODUTO",SB1->B1_COD,n)
				//MaFisLoad("IT_QUANT",oGetPecas:aCols[ny,nVS3QTDITE],n)
				//MaFisLoad("IT_TES",oGetPecas:aCols[ny,nVS3CODTES],n)

				//MaFisRef("IT_CLASFIS","VS300",M->VS3_SITTRI)
				MaFisLoad("IT_CLASFIS",oGetPecas:aCols[ny,nVS3SITTRI],n)


				if oGetPecas:aCols[ny,nVS3QTDITE] <> 0

					// Parametro so tem influencia para pecas em promocao
					if (INCLUI .OR. ALTERA) .and. cMVMIL0117 == "S" .and. oGetPecas:aCols[ny, nVS3PROMOC] == "1"
						oGetPecas:nAt := ny
						FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
						OX0010235_Atualiza_Preco_Peca(.t.)
					endif


					MaFisLoad("IT_PRCUNI",oGetPecas:aCols[ny,nVS3VALPEC],n)
					MaFisLoad("IT_VALMERC",Round(oGetPecas:aCols[ny,nVS3VALPEC]*oGetPecas:aCols[ny,nVS3QTDITE],2),n)
					MaFisLoad("IT_DESCONTO",oGetPecas:aCols[ny,nVS3VALDES],n)
				else
					MaFisLoad("IT_PRCUNI",oGetPecas:aCols[ny,nVS3VALPEC],n)
					MaFisLoad("IT_VALMERC",Round(oGetPecas:aCols[ny,nVS3VALPEC]*oGetPecas:aCols[ny,nVS3QTDITE],2),n)
					MaFisLoad("IT_DESCONTO",oGetPecas:aCols[ny,nVS3VALDES],n)
				endif
				MaFisRecal("",n)
				//MaFisEndLoad(n,3)
				MaFisEndLoad(n,IIf( ny == Len(oGetPecas:aCols) , 1 , 2 ) )

			Endif

			oGetPecas:nAt := ny
			OX001PecFis()
			if cChamadoPor <> "OX001LVS34" .or. cMVMIL0117 <> "S"
				FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
			endif

			M->VS3_VALPIS := MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
			M->VS3_VALCOF := MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
			M->VS3_ICMCAL := MaFisRet(n,"IT_VALICM")
			M->VS3_PICMSB := MaFisRet(n,"IT_ALIQSOL")
			M->VS3_BICMSB := MaFisRet(n,"IT_BASESOL")
			M->VS3_VICMSB := MaFisRet(n,"IT_VALSOL")
			M->VS3_VALCMP := MaFisRet(n,"IT_VALCMP")
			M->VS3_DIFAL  := MaFisRet(n,"IT_DIFAL")
			M->VS3_VALDES := MaFisRet(n,"IT_DESCONTO")
			M->VS3_PIPIFB := MaFisRet(n,"IT_ALIQIPI")
			M->VS3_VALIPI := MaFisRet(n,"IT_VALIPI")
			OX001FisPec()

			oGetPecas:aCols[ny,nVS3PICMSB] := M->VS3_PICMSB
			oGetPecas:aCols[ny,nVS3VICMSB] := M->VS3_VICMSB
			oGetPecas:aCols[ny,nVS3BICMSB] := M->VS3_BICMSB
			oGetPecas:aCols[ny,nVS3VALPIS] := M->VS3_VALPIS
			oGetPecas:aCols[ny,nVS3VALCOF] := M->VS3_VALCOF
			oGetPecas:aCols[ny,nVS3ICMCAL] := M->VS3_ICMCAL
			oGetPecas:aCols[ny,nVS3VALCMP] := M->VS3_VALCMP
			oGetPecas:aCols[ny,nVS3DIFAL]  := M->VS3_DIFAL
			If nVS3PIPIFB > 0 .and. nVS3VIPIFB > 0
				oGetPecas:aCols[ny,nVS3PIPIFB] := M->VS3_PIPIFB
				oGetPecas:aCols[ny,nVS3VIPIFB] := M->VS3_VIPIFB
			Endif

		Endif

	Next

Else

	If !Empty(oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE])

		M->VS3_VALPIS := MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
		M->VS3_VALCOF := MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
		M->VS3_ICMCAL := MaFisRet(n,"IT_VALICM")
		M->VS3_PICMSB := MaFisRet(n,"IT_ALIQSOL")
		M->VS3_BICMSB := MaFisRet(n,"IT_BASESOL")
		M->VS3_VICMSB := MaFisRet(n,"IT_VALSOL")
		M->VS3_VALCMP := MaFisRet(n,"IT_VALCMP")
		M->VS3_DIFAL  := MaFisRet(n,"IT_DIFAL")
		M->VS3_PIPIFB := MaFisRet(n,"IT_ALIQIPI")
		M->VS3_VIPIFB := MaFisRet(n,"IT_VALIPI")
		oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_PICMSB","aHeaderP")] := M->VS3_PICMSB
		oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_VICMSB","aHeaderP")] := M->VS3_VICMSB
		oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_BICMSB","aHeaderP")] := M->VS3_BICMSB
		oGetPecas:aCols[oGetPecas:nAt,nVS3VALPIS] := M->VS3_VALPIS
		oGetPecas:aCols[oGetPecas:nAt,nVS3VALCOF] := M->VS3_VALCOF
		oGetPecas:aCols[oGetPecas:nAt,nVS3ICMCAL] := M->VS3_ICMCAL
		If FG_POSVAR("VS3_PIPIFB","aHeaderP") > 0 .and. FG_POSVAR("VS3_VIPIFB","aHeaderP") > 0
			oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_PIPIFB","aHeaderP")] := M->VS3_PIPIFB
			oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_VIPIFB","aHeaderP")] := M->VS3_VIPIFB
		Endif
		OX001PREPEC()

	EndIf

EndIf

If lAltReadVar
	__ReadVar := ""
Endif

OX001ATUF1() // Atualiza informacoes adicionais (dependentes do fiscal)
oGetPecas:oBrowse:refresh()
oGetServ:oBrowse:refresh()

RestArea(aArea)

// Alteração Manoel - 13/07/2016 - Chamado 005475 - PROBLEMAS NO ORCAMENTO - MAQNELSON
oGetServ:nAt  := nSlvNGS
oGetPecas:nAt := nSlvNGP
n := nSlvN
//
FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt,.f.)
//

Return


/*
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | OX001RefNF | Autor |  Manoel Filho         | Data | 30/06/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Processa Fiscal apenas dos Itens do Cabeçalho                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina / AutoPecas                                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
*/
Function OX001RefNF()

MaFisRef("NF_TPFRETE",," ")
MaFisRef("NF_TPFRETE",,M->VS1_PGTFRE)
MaFisRef("NF_TPCLIFOR",,M->VS1_TIPCLI)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao  ³ OX001SEQINC ³ Autor ³ Thiago				     ³ Data ³ 28/01/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Sequencia de Inconvenientes                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001SEQINC(cDescInconv)
Local nVSTSEQINC := IIf(lInconveniente,FG_POSVAR("VST_SEQINC","oGetInconv:aHeader"),0) // Posicao no oGetInconv:aHeader VST_SEQINC
Local nVSTDESINC := IIf(lInconveniente,FG_POSVAR("VST_DESINC","oGetInconv:aHeader"),0) // Posicao no oGetInconv:aHeader VST_DESINC
Local nTamSeqInc := TamSX3("VST_SEQINC")[1]
Local nPos       := 0
Local cAux       := ""
Local ni         := 0
nPos := aScan(oGetInconv:aCols, {|x| FwNoAccent(Alltrim(x[nVSTDESINC])) == FwNoAccent(Alltrim(cDescInconv)) .and. !x[len(oGetInconv:aHeader)+1] }) // Verifica se Existe o Inconveniente na aCols de Incovenientes
If nPos <= 0
	nPos := aScan(oGetInconv:aCols, {|x| ( Empty(x[nVSTDESINC]) ) .and. !x[len(oGetInconv:aHeader)+1] }) // Verifica se Existe linha em branco
EndIf
If nPos <= 0
	AADD(oGetInconv:aCols,Array(len(oGetInconv:aHeader)+1))
	oGetInconv:aCols[Len(oGetInconv:aCols),len(oGetInconv:aHeader)+1] := .F.
	For nPos := 1 to len(oGetInconv:aHeader)
		oGetInconv:aCols[Len(oGetInconv:aCols),nPos] := CriaVar(oGetInconv:aHeader[nPos,2])
	Next
	oGetInconv:nAt := nPos := Len(oGetInconv:aCols)
EndIf
If Empty(oGetInconv:aCols[nPos,nVSTSEQINC])
	cAux := StrZero(0,nTamSeqInc)
	For ni := 1 to len(oGetInconv:aCols)
		If oGetInconv:aCols[ni,nVSTSEQINC] > cAux
			cAux := oGetInconv:aCols[ni,nVSTSEQINC]
		EndIf
	Next
	cAux := StrZero(val(cAux)+1,nTamSeqInc)
	oGetInconv:aCols[nPos,nVSTSEQINC] := cAux
	oGetInconv:aCols[nPos,nVSTDESINC] := cDescInconv
EndIf
Return(oGetInconv:aCols[nPos,nVSTSEQINC])

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao  ³ OX001EXPVSJ ³ Autor ³ Manoel Filho		     ³ Data ³ 20/02/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exporta Peças do Orçamento para a OS (VSJ)                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Parâmetros³ lChamaExt - chamada da função foi Externa(por outra rotina)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OX001EXPVSJ(lChamaExt,cNroOrcAtu)

Default cNroOrcAtu := VS1->VS1_NUMORC
Default lChamaExt := .t.

if FM_IMPVSJ( @aItensNImp , VS1->VS1_NUMORC , VO1->VO1_NUMOSV,,, .F.)
	if Len(aItensNImp[2]) > 0
		if !lOX001Auto
			if MsgYesNo(STR0092,STR0025)
				FM_IPECNDISP(aItensNImp)
			endif
		endif
	endif
else
	return .f.
endif
If ExistBlock("IMPORCVSJ")
	ExecBlock("IMPORCVSJ",.f.,.f.,{VO1->VO1_NUMOSV})
Endif
If ExistBlock("OX001IOR")
	ExecBlock("OX001IOR",.f.,.f.,{VO1->VO1_NUMOSV})
Endif
//
DBSelectArea("VS1")
DBSetOrder(1)
DBSeek(xFilial("VS1")+cNroOrcAtu)
reclock("VS1",.f.)
cVS1StAnt := VS1->VS1_STATUS
VS1->VS1_STATUS := "I"
VS1->VS1_DEXPOS := dDataBase    // Data da Exportação do Orçamento para OS
VS1->VS1_HEXPOS := val(left(time(),2)+substr(time(),4,2)) // Hora da Exportação do Orçamento para OS

msunlock()
If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
	OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , IIF(VS1->VS1_TIPORC=="P",STR0374,STR0001) ) // Grava Data/Hora na Mudança de Status do Orçamento / Pedidos de Venda / Orçamento por Fases
EndIf

If ExistFunc("FM_GerLog")
	//grava log das alteracoes das fases do orcamento
	FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,cVS1StAnt)
EndIF


If lChamaExt

	MsgInfo(STR0093 ,STR0025)
	FG_PEDORD(VO1->VO1_NUMOSV,"N","S")

	if ExistBlock("OX001DEX") // Depois da Exportacao
		ExecBlock("OX001DEX",.f.,.f.)
	Endif

EndIf

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao  ³ FS_QTDLIN ³ Autor ³ Thiago                        		     ³ Data ³ 20/02/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se estourou tamanho do Acols de Peças para de acordo com MV_NUMITEN ³±±
±±³          ³ cOpcao 0= Delecao do item                                                    ³±±
±±³          ³ cOpcao 1= Inclusao de item novo                                              ³±±
±±³          ³ cOpcao 2= Faturamento do orçamento/Pedido                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_QTDLIN(cOpcao)
Local i:= 0
Local nQtdLin := 0
Local lRet := .t.
local nPosDelaCols := 0

if cOpcao == "0" .and. !oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])]  // So faz a verificacao se o item estiver deletado e o usuario tentar voltar o item para ativo
	Return(.t.)
Endif

if nMaxItNF <= 0
	return .t.
endif

nIni_QTDLIN := timeFull()

If (M->VS1_TIPORC == "1" .or. lPediVenda).and. Len(oGetPecas:aCols) > nMaxItNF

	nPosDelaCols := Len(oGetPecas:aCols[1])
	For i := 1 to Len(oGetPecas:aCols)
		if ! oGetPecas:aCols[i,nPosDelaCols]
			if ! Empty(oGetPecas:aCols[i,nVS3CODITE])
				nQtdLin += 1
			Endif
		Endif
	Next

	if nQtdLin == 0
		return .t.
	endif

	If nQtdLin >= nMaxItNF .and. cOpcao <> "2"
		if ReadVar() == "M->VS3_GRUITE" .or. ReadVar() == "M->VS3_CODITE"
			oGetPecas:aCols[oGetPecas:nAt,nVS3GRUITE] := M->VS3_GRUITE := space(TamSx3("VS3_GRUITE")[1])
			oGetPecas:aCols[oGetPecas:nAt,nVS3CODITE] := M->VS3_CODITE := space(TamSx3("VS3_CODITE")[1])
		Endif
		lRet := .f.

	Elseif nQtdLin > nMaxItNF .and. cOpcao == "2"
		lRet := .f.
	Endif

	if ! lRet
		oGetPecas:oBrowse:refresh()
		FMX_HELP( "OX001NUMITEM", STR0316 ) // "Estourou o número maximo de Itens pra geração de NF, conforme parâmetro MV_NUMITEN."
		Return .f.
	Endif

	if cOpcao == "2"
		if Empty(oGetPecas:aCols[Len(oGetPecas:aCols),nVS3CODITE])
			oGetPecas:oBrowse:GoTop()
		Endif
	Endif
Endif

Return(.t.)




function ElapTimeFull(cIniTimeFull, cFimTimeFull) 

	Local nIniTime
	Local nFimTime

	If empty(cIniTimeFull) .or. empty(cFimTimeFull)
		return 0
	endif

	//conout(cIniTimeFull + " - " + cFimTimeFull)

	cIniTimeFull := StrTran(cIniTimeFull, ":", "")
	nIniTime := Val(Left(cIniTimeFull,2)) * 3600 +;
		Val(SubStr(cIniTimeFull,3,2)) * 60 +;
		Val(SubStr(cIniTimeFull,5,2)) +;
		Val(Right(cIniTimeFull,3)) / 1000

	cFimTimeFull := StrTran(cFimTimeFull, ":", "")
	nFimTime := Val(Left(cFimTimeFull,2)) * 3600 +;
		Val(SubStr(cFimTimeFull,3,2)) * 60 +;
		Val(SubStr(cFimTimeFull,5,2)) +;
		Val(Right(cFimTimeFull,3)) / 1000

Return (nFimTime - nIniTime)

/*/{Protheus.doc} OX001DBSEL
Selecão do serviço e atualização do acols e variavel de memoria
@author Renato Vinicius
@since 02/08/2017
@version undefined
@param cParGrpSer, characters, descricao
@param cParCodSer, characters, descricao
@type function
/*/
Function OX001DBSEL(cParGrpSer,cParCodSer)

Local lRetorno := .t.

__ReadVar := 'M->VS4_GRUSER'
oGetServ:aCols[oGetServ:nAt,FG_POSVAR("VS4_GRUSER")] := M->VS4_GRUSER := cParGrpSer
lRetorno := OX001FSOK()
__ReadVar := 'M->VS4_CODSER'
M->VS4_CODSER := cParCodSer
Return lRetorno

/*----------------------------------------------------
 Suavizar a nova verificação de integração com o WMS
------------------------------------------------------*/
Static Function a261IntWMS(cProduto)
Default cProduto := ""
	If ExistFunc("IntWMS")
		Return IntWMS(cProduto)
	Else
		Return IntDL(cProduto)
	EndIf
Return

/*/{Protheus.doc} OX001PrxNro
Próximo Numero de Orçamento
@author manoel Filho
@since 21/12/2017
@version undefined
@type function
/*/
Function OX001PrxNro()
Local nPrxNro := ""
//
While Empty(nPrxNro) .Or. ( FM_SQL(" SELECT R_E_C_N_O_ FROM "+retsqlName('VS1')+" WHERE VS1_FILIAL = '"+xFilial('VS1')+"' AND VS1_NUMORC = '"+nPrxNro+"' AND   D_E_L_E_T_=' '") > 0 )
		nPrxNro := GetSxeNum("VS1","VS1_NUMORC")
		ConfirmSx8()
EndDo
//
Return nPrxNro

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   OX001LOTM Autor ³   Fernando Vitor Cavani   ³ Data ³ 13/04/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mensagem Única de Peças para Lote Mínimo                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OX001LOTM(cMsgLotMin)
Local cPulaLinha := CHR(13) + CHR(10)

AVISO(STR0025,               ; // Atenção
	STR0337 + cPulaLinha    +; // As Peças abaixo possuem quantidades insuficientes para venda.
	STR0181                 +; // Verifique no cadastro de peças a quantidade mínima para venda (Qtde Venda).
	cPulaLinha + cPulaLinha +;
	cMsgLotMin               ;
, { "Ok" } , 3)
Return

/*/{Protheus.doc} LinhaSemQuantidade
Valida a quantidade requisitada
@author Renato Vinicius
@since 22/05/2018
@version undefined
@param nOpc,    numerico, Opção selecionada
@param nCntFor, numerico, posição no acols
@type function
/*/
Static function LinhaSemQuantidade(nOpc,oGetPeca)

	If lPediVenda .and. ; //Executado pelo Pedido de Orçamento
		nOpc == 3 .and. ; // Inclusão de Pedido
		!oGetPeca[len(oGetPeca)] .and.; // Não Deletado
		oGetPeca[nVS3QTDITE] == 0 // Quantidade Requisitada
		Return .t.
	EndIf

	If !lPediVenda .and. ; // Não executado pelo Pedido de Orçamento
		!oGetPeca[len(oGetPeca)] .and.; // Não Deletado
		!Empty(oGetPeca[nVS3GRUITE]) .and.; // Não existir peças
		oGetPeca[nVS3QTDITE] == 0 // Quantidade Requisitada
		Return .t.
	EndIf

Return .f.


/*/{Protheus.doc} OX0010016_MostraQuantidadeEmEstoque
Valida a quantidade em estoque
@author Fernando Vitor Cavani | Vinicius Gati
@since 30/07/2018
@version undefined
@param nLinha , numérico, linha da GetDados
@param cTipOrc, caracter, tipo do Orçamento
@type function
/*/
Static function OX0010016_MostraQuantidadeEmEstoque(nLinha, cTipOrc)
Default nLinha := 0

if cMVMIL0011 == "0"
	return .t.
endif

If nLinha > 0
	// Usa NA e peça já foi gravada deve mostrar saldo
	If cMVMIL0011 == "1" .And. oGetPecas:aCols[nLinha, nVS3REC_WT ] > 0
		return .t.
	elseif cMVMIL0011 == "1" .and. lPediVenda // se pedido de venda não deve mostrar
		return .f.
	elseif lNaForte .And. oGetPecas:aCols[nLinha, nVS3REC_WT] == 0
	 	return .f.
	EndIf
EndIf
Return .t.

/*/{Protheus.doc} OX0010051_LogdaPilhadeChamada
Gravação de pilha de chamada em arquivo txt
@author Renato Vinicius
@since 18/10/2018
@version 1.0
@param cCodMsg, Caracter, Código str da mensagem apresentada
/*/
 
Static Function OX0010051_LogdaPilhadeChamada(cCodMsg)

Local aArea  := GetArea()
Local cRotina:= FunName()
Local oGerLog:= DMS_Logger():New()

Default cCodMsg := ""

oGerLog:LogPilhaChamada(cRotina,cCodMsg)

RestArea(aArea)

Return


/*/{Protheus.doc} OX0010051_LogdaPilhadeChamada
Calcula o peso das peças no Orçamento para Informação na NF
@author Manoel Filho
@since 27/12/2018
@version 1.0
@param 
/*/
Function OX0010062_CalculaPeso()//

Local nCntFor := 0
Local cQuery  := ""
Local cQAlias := "SQLSB1"
Local nPosGru := nVS3GRUITE
Local nPosCod := nVS3CODITE
Local nPosQtd := nVS3QTDITE
//
M->VS1_PESOL  := 0
M->VS1_PESOB  := 0

For nCntFor := 1 to Len(oGetPecas:aCols)
	if !oGetPecas:aCols[nCntFor,Len(oGetPecas:aCols[nCntFor])]
		cQuery := " SELECT B1_PESO, B1_PESBRU"
		cQuery += "   FROM "+retsqlName('SB1')
		cQuery += "  WHERE B1_FILIAL = '"+xFilial('SB1')+"'"
		cQuery += "    AND B1_GRUPO = '" +oGetPecas:aCols[nCntFor,nPosGru]+"'"
		cQuery += "    AND B1_CODITE = '"+oGetPecas:aCols[nCntFor,nPosCod]+"'"
		cQuery += "    AND D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
		If !(cQAlias)->(Eof())
			M->VS1_PESOL += (cQAlias)->B1_PESO   * oGetPecas:aCols[nCntFor,nPosQtd]
			M->VS1_PESOB += (cQAlias)->B1_PESBRU * oGetPecas:aCols[nCntFor,nPosQtd]
		Endif
		(cQAlias)->(dbCloseArea())
	Endif
Next
//
oEnch:refresh()
//
DbSelectArea("VS1")
//
Return

/*/{Protheus.doc} OX0010074_AdicionaNATransferencia
	Vai adicionar dados de nivel de atendimento no array de
	transferencias somente caso a filial seja configurada
	como armazem na configuracao do DPM OFIA170 

	aTrsfer contem os seguintes dados:
		[1] => grupo
		[2] => peça
		[3] => descricao da filial
		[4] => quantidade pedida para transferencia
		[5] => filial origem da transferencia
		[6] => saldo disponivel na filial (pode ser que esse parametro nao exista dependendo da versao do OFIXA020, caso seja o problema atualizar)

	lTemSaldo na funcao
	    => esta variavel foi inserida para tratar se na tela de transferencia de peca foi colocada 
		   para tratar se a quantidade pedida na transferencia realmente existe na filial armazem
		   pois é possivel fazer um pedido de transferenca sem que exista a quantidade disponivel
	 
	@type function
	@author Vinicius Gati
	@since 03/06/2019
/*/
static function OX0010074_AdicionaNATransferencia(nAt, aTrsfer)
	local nIdx := 0
	local lTemSaldo := .t. // criada para validar se a qtd pedido na transferencia tem saldo ou nao
	if len(aTrsfer) == 6 .and. aTrsfer[6] /*saldo*/ < aTrsfer[4] /*qtd_pedida*/
		lTemSaldo := .f.
	endif
	if lTemSaldo .and. oDpm:isFilEst(cFilAnt, aTrsfer[5])
		nIdx := ascan(aNATrf, {|aEl| aEl[1] == nAt .and. aEl[2,1] == aTrsfer[1] .and. aEl[2,2] == aTrsfer[2] .and. aEl[2,5] == aTrsfer[5]})
		// se encontrou ja dados dessa peca eu removo e re-adiciono para atualizar o valor
		if nIdx > 0
			ADel(aNATrf, nIdx)
			ASize(aNaTrf, len(aNATrf) - 1)
		endif
		aadd(aNaTrf, { nAt, aclone(aTrsfer) })
	endif
return .t.

/*/{Protheus.doc} OX0010084_TotalNaFilialArmazem
	Retorna o NA total recuperado de transferencia de filial armazem
	configurada via OFIA170
	 
	@type function
	@author Vinicius Gati
	@since 03/06/2019
/*/
static function OX0010084_TotalNaFilialArmazem(nAt, cGrupo, cCodIte)
	local nIdx := 0
	local nTot := 0
	For nIdx:= 1 to Len(aNATrf)
		if aNATrf[nIdx,1] == nAt .and. aNATrf[nIdx,2,1] == cGrupo .and. aNATrf[nIdx,2,2] == cCodIte
			nTot += aNATrf[nIdx,2,4]
		endif
	Next
return nTot


/*/{Protheus.doc} OX0010091_LevantaVlrServico
	Retorna o Valor Padrao do Servico 
	 
	@type function
	@author Andre Luis Almeida
	@since 01/07/2019
/*/
Static Function OX0010091_LevantaVlrServico()

Local nValTot := 0

// Tipo de Servico de KM
If VOK->VOK_INCMOB $ "5"

	nValTot := M->VS4_KILROD * VOK->VOK_PREKIL
//
Else

	If VO6->VO6_VALSER > 0 // Valor Fixo para o Servico
		nValTot := VO6->VO6_VALSER
	EndIf

	If nValTot == 0
		nValTot := (M->VS4_TEMPAD /100) * M->VS4_VALHOR
	EndIf

EndIf

Return nValTot


/*/{Protheus.doc} OX0010105_ArmazemOrigem
	Retorna o Valor Padrao do Servico 
	 
	@type function
	@author Renato Vinicius
	@since 01/07/2019
/*/

Static Function OX0010105_ArmazemOrigem()

	Local cArmazem := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")

	If M->VS1_TIPORC == "2" .and. lFOM020ArmazemOri
		cArmazem := OM0200065_ArmazemOrigem( M->VS1_TIPTEM, cArmazem )
	EndIf

Return cArmazem

/*/{Protheus.doc} OX0010115_BloqueiaOrcamento
		Função que verifica se o orçamento está bloqueado
	@author Renato Vinicius
	@since 15/01/2020
	@version 1.0
	@return lógico
	@param
	@type function
/*/
Function OX0010115_BloqueiaOrcamento(cOrcamento)

	If !LockByName( 'OFIXX001_' + cOrcamento, .T., .F. )
		VS1->(MsUnlock()) 
		ApMsgStop( STR0350 + " ( " + cOrcamento + " ) " ) //"Esse orçamento já está sendo alterado em outra seção!"
		Return .t.
	EndIf

Return .f.


Static Function OX0010123_FGPosVar_VS3()

	//If nVS3CODITE <> NIL
	//	Return
	//EndIf

	nVS3BICMSB := FG_POSVAR("VS3_BICMSB","AHEADERP")
	nVS3CENCUS := FG_POSVAR("VS3_CENCUS","AHEADERP")
	nVS3CLVL   := FG_POSVAR("VS3_CLVL"  ,"AHEADERP")
	nVS3CODINC := FG_POSVAR("VS3_CODINC","AHEADERP")
	nVS3CODITE := FG_POSVAR("VS3_CODITE","AHEADERP")
	nVS3CODTES := FG_POSVAR("VS3_CODTES","AHEADERP")
	nVS3CONTA  := FG_POSVAR("VS3_CONTA" ,"AHEADERP")
	nVS3DEPGAR := FG_POSVAR("VS3_DEPGAR","AHEADERP")
	nVS3DEPINT := FG_POSVAR("VS3_DEPINT","AHEADERP")
	nVS3DESINC := FG_POSVAR("VS3_DESINC","AHEADERP")
	nVS3DESITE := FG_POSVAR("VS3_DESITE","AHEADERP")
	nVS3DIFAL  := FG_POSVAR("VS3_DIFAL" ,"AHEADERP")
	nVS3DOCSDB := FG_POSVAR("VS3_DOCSDB","AHEADERP")
	nVS3DTVALI := FG_POSVAR("VS3_DTVALI","AHEADERP")
	nVS3FORMUL := FG_POSVAR("VS3_FORMUL","AHEADERP")
	nVS3GRUINC := FG_POSVAR("VS3_GRUINC","AHEADERP")
	nVS3GRUITE := FG_POSVAR("VS3_GRUITE","AHEADERP")
	nVS3ICMCAL := FG_POSVAR("VS3_ICMCAL","AHEADERP")
	nVS3IMPRES := FG_POSVAR("VS3_IMPRES","AHEADERP")
	nVS3INSTAL := FG_POSVAR("VS3_INSTAL","AHEADERP")
	nVS3ITEMCT := FG_POSVAR("VS3_ITEMCT","AHEADERP")
	nVS3KEYALT := FG_POSVAR("VS3_KEYALT","AHEADERP")
	nVS3LOCAL  := FG_POSVAR("VS3_LOCAL" ,"AHEADERP")
	nVS3LOCALI := FG_POSVAR("VS3_LOCALI","AHEADERP")
	nVS3LOCPRO := FG_POSVAR("VS3_LOCPRO","AHEADERP")
	nVS3LOTECT := FG_POSVAR("VS3_LOTECT","AHEADERP")
	nVS3MARLUC := FG_POSVAR("VS3_MARLUC","AHEADERP")
	nVS3MOTPED := FG_POSVAR("VS3_MOTPED","AHEADERP")
	nVS3NUMLOT := FG_POSVAR("VS3_NUMLOT","AHEADERP")
	nVS3OPER   := FG_POSVAR("VS3_OPER"  ,"AHEADERP")
	nVS3PECKIT := FG_POSVAR("VS3_PECKIT","AHEADERP")
	nVS3PERDES := FG_POSVAR("VS3_PERDES","AHEADERP")
	nVS3PICMSB := FG_POSVAR("VS3_PICMSB","AHEADERP")
	nVS3PIPIFB := FG_POSVAR("VS3_PIPIFB","AHEADERP")
	nVS3PROMOC := FG_POSVAR("VS3_PROMOC","AHEADERP")
	nVS3QTD2UM := FG_POSVAR("VS3_QTD2UM","AHEADERP")
	nVS3QTDAGU := FG_POSVAR("VS3_QTDAGU","AHEADERP")
	nVS3QTDELI := FG_POSVAR("VS3_QTDELI","AHEADERP")
	nVS3QTDEST := FG_POSVAR("VS3_QTDEST","AHEADERP")
	nVS3QTDINI := FG_POSVAR("VS3_QTDINI","AHEADERP")
	nVS3QTDITE := FG_POSVAR("VS3_QTDITE","AHEADERP")
	nVS3QTDPED := FG_POSVAR("VS3_QTDPED","AHEADERP")
	nVS3QTDRES := FG_POSVAR("VS3_QTDRES","AHEADERP")
	nVS3QTDTRA := FG_POSVAR("VS3_QTDTRA","AHEADERP")
	nVS3REC_WT := FG_POSVAR("VS3_REC_WT","AHEADERP")
	nVS3RESERV := FG_POSVAR("VS3_RESERV","AHEADERP")
	nVS3SEQINC := FG_POSVAR("VS3_SEQINC","AHEADERP")
	nVS3SEQUEN := FG_POSVAR("VS3_SEQUEN","AHEADERP")
	nVS3SITTRI := FG_POSVAR("VS3_SITTRI","AHEADERP")
	nVS3VALCMP := FG_POSVAR("VS3_VALCMP","AHEADERP")
	nVS3VALCOF := FG_POSVAR("VS3_VALCOF","AHEADERP")
	nVS3VALDES := FG_POSVAR("VS3_VALDES","AHEADERP")
	nVS3VALLIQ := FG_POSVAR("VS3_VALLIQ","AHEADERP")
	nVS3VALPEC := FG_POSVAR("VS3_VALPEC","AHEADERP")
	nVS3VALPIS := FG_POSVAR("VS3_VALPIS","AHEADERP")
	nVS3VALTOT := FG_POSVAR("VS3_VALTOT","AHEADERP")
	nVS3VICMSB := FG_POSVAR("VS3_VICMSB","AHEADERP")
	nVS3VIPIFB := FG_POSVAR("VS3_VIPIFB","AHEADERP")
	nVS3BASIRR := FG_POSVAR("VS3_BASIRR","aHeaderP")
	nVS3ALIIRR := FG_POSVAR("VS3_ALIIRR","aHeaderP")
	nVS3VALIRR := FG_POSVAR("VS3_VALIRR","aHeaderP")
	nVS3BASCSL := FG_POSVAR("VS3_BASCSL","aHeaderP")
	nVS3ALICSL := FG_POSVAR("VS3_ALICSL","aHeaderP")
	nVS3VALCSL := FG_POSVAR("VS3_VALCSL","aHeaderP")
	nVS3SEQVEN := FG_POSVAR("VS3_SEQVEN","aHeaderP")
	nVS3PESPRO := FG_POSVAR("VS3_PESPRO","aHeaderP")
Return

Static Function OX0010133_FGPosVar_VS4()
	//If nVS4CODSER <> NIL
	//	Return
	//EndIf
	
	nVS4CODINC := FG_POSVAR("VS4_CODINC","AHEADERS")
	nVS4CODSEC := FG_POSVAR("VS4_CODSEC","AHEADERS")
	nVS4CODSER := FG_POSVAR("VS4_CODSER","AHEADERS")
	nVS4DEPGAR := FG_POSVAR("VS4_DEPGAR","AHEADERS")
	nVS4DEPINT := FG_POSVAR("VS4_DEPINT","AHEADERS")
	nVS4DESINC := FG_POSVAR("VS4_DESINC","AHEADERS")
	nVS4DESSER := FG_POSVAR("VS4_DESSER","AHEADERS")
	nVS4GRUINC := FG_POSVAR("VS4_GRUINC","AHEADERS")
	nVS4GRUSER := FG_POSVAR("VS4_GRUSER","AHEADERS")
	nVS4KILROD := FG_POSVAR("VS4_KILROD","AHEADERS")
	nVS4NOMFOR := FG_POSVAR("VS4_NOMFOR","AHEADERS")
	nVS4OBSERV := FG_POSVAR("VS4_OBSERV","AHEADERS")
	nVS4PERDES := FG_POSVAR("VS4_PERDES","AHEADERS")
	nVS4SEQINC := FG_POSVAR("VS4_SEQINC","AHEADERS")
	nVS4SEQSER := FG_POSVAR("VS4_SEQSER","AHEADERS")
	nVS4SEQUEN := FG_POSVAR("VS4_SEQUEN","AHEADERS")
	nVS4TEMPAD := FG_POSVAR("VS4_TEMPAD","AHEADERS")
	nVS4TIPSER := FG_POSVAR("VS4_TIPSER","AHEADERS")
	nVS4VALCUS := FG_POSVAR("VS4_VALCUS","AHEADERS")
	nVS4VALDES := FG_POSVAR("VS4_VALDES","AHEADERS")
	nVS4VALHOR := FG_POSVAR("VS4_VALHOR","AHEADERS")
	nVS4VALSER := FG_POSVAR("VS4_VALSER","AHEADERS")
	nVS4VALTOT := FG_POSVAR("VS4_VALTOT","AHEADERS")
	nVS4VALVEN := FG_POSVAR("VS4_VALVEN","AHEADERS")
Return

Static Function OX0010143_FGPosVar_VST()
	nVSTCODINC := FG_POSVAR("VST_CODINC","AHEADERI")
	nVSTDESINC := FG_POSVAR("VST_DESINC","AHEADERI")
	nVSTGRUINC := FG_POSVAR("VST_GRUINC","AHEADERI")
	nVSTSEQINC := FG_POSVAR("VST_SEQINC","AHEADERI")
Return


//Static Function FS_VISCONOUT()
//
//	Private oVisConout := OFVisualizaDados():New(, "Conout")
//
//	oVisConout:AddColumn( { { "TITULO" , "Conout" } , { "TAMANHO" , 200 } } ) 
//
//	oVisConout:SetData(aOX001Conout)
//	oVisConout:Activate()
//
//	If MsgYesNo("Limpar console")
//		aSize(aOX001Conout,0)
//	EndIf
//
//Return

//Function OX001_Conout(cTexto, cCor)
//	Default cCor := ""
//
//	If ! _lConout_
//		Return
//	EndIf
//
//	If ! Empty(cCor)
//		cCor := chr(27) + cCor
//	EndIf
//
//	//Conout(cCor + cTexto + chr(27) + "[0m")
//	Conout(cTexto)
//
//	AADD(aOX001Conout, {cTexto})
//
//Return

/*/{Protheus.doc} OX0010153_PreencheSITTRI
Preenche e seta no fiscal o conteudo do campo de situacao tributaria

@author Rubens
@since 27/10/2023
@version 1.0

@type function
/*/
Static Function OX0010153_PreencheSITTRI(lPecFis)
	if !Empty(M->VS3_CODTES)
		SF4->(dbSetOrder(1))
		If SF4->(MsSeek(xFilial("SF4")+M->VS3_CODTES)) .and. ! Empty(SF4->F4_SITTRIB)

			cBx_ORIGEM := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ORIGEM")

			M->VS3_SITTRI := Left(cBx_ORIGEM,1) + SF4->F4_SITTRIB
			oGetPecas:aCols[oGetPecas:nAt,nVS3SITTRI] := M->VS3_SITTRI

			If lPecFis
				OX001PecFis()
				MaFisRef("IT_CLASFIS","VS300",M->VS3_SITTRI)
				OX001FisPec()
			EndIf

		endif
	endif
Return


/*/{Protheus.doc} OX0010124_IncluiItemOrc
	
	@author Vinicius Gati
	@since 24/02/2020
	@type function
/*/
Function OX0010124_IncluiItemOrc(cCod, nQuant, cDet, aDadosExt)
	local aColsPec := oGetPecas:aCols
	local nX  := 1
	local nY  := 1
	local nLastIdx
	local cField
	local lFeito := .f.
	default aDadosExt := {}

	SB1->(DBSetOrder(1))
	if SB1->(DBSeek(xFilial("SB1") + cCod)) .and. alltrim(SB1->B1_COD) == alltrim(cCod)
		// Verifica se o item esta bloqueado
		if SB1->B1_MSBLQL == "1"
			HELP(" ",1,"REGBLOQ")
			cDet := STR0393
			Return .F.
		endif
		for nX := 1 to len(aColsPec)
			if aColsPec[nX, fg_posvar("VS3_GRUITE","aHeaderP")] == SB1->B1_GRUPO .and. ;
			   aColsPec[nX, fg_posvar("VS3_CODITE","aHeaderP")] == SB1->B1_CODITE .and. ;
			   aColsPec[nX, len(aColsPec[nX])] == .f. // nao deletado
				cDet := STR0355 // "item já lançada no orçamento."
				return .f.
			endif
		next
	else
		cDet := STR0354 // " não encontrado na SB1."
		return .f.
	endif

	if ! Empty(aColsPec[oGetPecas:nAt, fg_posvar("VS3_GRUITE","aHeaderP")]) .and. ! empty(aColsPec[oGetPecas:nAt, fg_posvar("VS3_CODITE","aHeaderP")])
		AADD(aColsPec, Array(nUsadoPX01 + 1))
	endif

	nLastIdx := Len(aColsPec)
	oGetPecas:nAt := nLastIdx

	For nX := 1 to nUsadoPX01
		cField := aHeaderP[nX,2]
		lFeito := .f.

		for nY := 1 to len(aDadosExt)
			if alltrim(cField) == alltrim(aDadosExt[nY, 1]) // campo posicao 1
				aColsPec[nLastIdx, nX] := aDadosExt[nY, 2]
				lFeito := .t.
			endif
		next

		if ! lFeito
			if cField == "VS3_QTDEST" .and. GetNewPar("MV_MIL0011", "0") == "0"
				aColsPec[nLastIdx, nX] := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+VS3->VS3_LOCAL, .f.)
			elseif cField == "VS3_QTDITE"
				aColsPec[nLastIdx, nX] := nQuant
			elseif cField == "VS3_QTDINI"
				aColsPec[nLastIdx, nX] := nQuant
			elseif cField == "VS3_CODITE"
				aColsPec[nLastIdx, nX] := SB1->B1_CODITE
			elseif cField == "VS3_GRUITE"
				aColsPec[nLastIdx, nX] := SB1->B1_GRUPO
			elseif cField == "VS3_VALPIS"
				aColsPec[nLastIdx, nX] := 0.0
			elseif IsHeadRec(cField)
				aColsPec[nLastIdx, nX] := 0
			elseif IsHeadAlias(cField)
				aColsPec[nLastIdx, nX] := "VS3"
			else
				aColsPec[nLastIdx, nX] := criavar(cField)
			endif
		endif

		&("M->"+cField) := aColsPec[nLastIdx, nX]
	Next
	
	aColsPec[nLastIdx,nUsadoPX01+1] := .F.

	__ReadVar := "M->VS3_CODITE"
	OX001FPOK(.f.,,.f.,.f.)
	FG_MEMVAR(aHeaderP,oGetPecas:aCols,oGetPecas:nAt)
Return .t.

/*/{Protheus.doc} OX0010134_ImportaOrcCSV
	Importação de orçamentos em csv modelo john deere enviado pela áster máquinas
	
	@type function
	@author Vinicius Gati
	@since 26/02/2020
/*/
Function OX0010134_ImportaOrcCSV()
	local lAllExt   := ExistBlock("OX001131") // se tem o PE trata todas as extensões
	local cFile     := ""

	Local oFile
	local cContent  := ""
	local nQtdInc   := 0
	local cMessage  := STR0353 /*"Detalhes da importação: "*/ + chr(13) + chr(10) + "---" + chr(13) + chr(10)
	local cLine     := ""
	local lFeito    := .f.
	local nX, cDet
	local aContent  := {}

	cFile := cGetFile(iif(lAllExt, "", "*.csv|*.csv"), STR0363, , , .t. , nOR( GETF_NETWORKDRIVE, GETF_LOCALHARD) ) // se tem o PE libera todas as extensões senão só csv
	If Empty(cFile)
		Return .f.
	EndIf

	if Empty(M->VS1_CLIFAT) .or. Empty(M->VS1_LOJA)
		MsgAlert(STR0122)
		return .f.
	endif

	if ! Empty(M->VS1_PEDREF)
		MsgAlert(STR0295,STR0025)
		return .f.
	endif

	lFeito := .f.

	aExtData := {} // retornar array com campo e valor
	If ExistBlock("OX001132")
		aExtData := ExecBlock("OX001132", .f., .f., {})
	EndIf

	// Leitura do arquivo
	oFile := FWFileReader():New(cFile)

	If (oFile:Open())
		aContent := oFile:GetAllLines()
	EndIf

	oFile:Close()

	if lAllExt
		If !Empty(aContent)
			cContent := STRTRAN(ArrTokStr(aContent), '|', CHR(13) + CHR(10))
		EndIf

		aDados := ExecBlock("OX001131", .f., .f., {cContent, cFile})
		if ! Empty(aDados) // retornar em branco segue com importacao padrão
			for nX := 1 to len(aDados)
				
				if OX0010124_IncluiItemOrc(aDados[nX, 1], val(aDados[nX, 2]), @cDet, aExtData)
					nQtdInc += 1
				else
					cMessage += chr(13) + chr(10) + " " + STR0202 + " " + aDados[nX, 1] + " " +STR0351+ " " + cDet // código do item XXX não pode ser importado.
				endif
			next
			lFeito := .t.
		endif
	endif

	if ! lFeito // importação do csv
		If !Empty(aContent)
			For nX := 1 to Len(aContent)
				If nX == 1
					Loop // header do csv JD
				EndIf

				cLine  := STRTRAN(aContent[nx], '"', "")
				aDados := STRTOKARR2(cLine, ",", .T.)

				cDet := ""
				if OX0010124_IncluiItemOrc(aDados[1], val(aDados[2]), @cDet, aExtData)
					nQtdInc += 1
				else
					cMessage += chr(13) + chr(10) + " " + STR0202 + " " + aDados[1] + " " +STR0351+ " " + cDet // código do item XXX não pode ser importado.
				endif
			Next
		EndIf
	endif

	cMessage += chr(13) + chr(10) + cValtoChar(nQtdInc) + STR0352 // " peças incluídas do arquivo selecionado."
	AVISO(STR0025, cMessage, { "Ok" }, 3)
return .t.



Static Function OX0010145_TelaTipoPagamento()
	If !Empty(M->VS1_FORPAG)
		DbSelectArea("SE4")
		DbSeek(xFilial("SE4")+M->VS1_FORPAG)
		If Alltrim(SE4->E4_TIPO) == "A"
			If !( M->VS1_STATUS $ "XCI" )
				OX0040115_TipoDePagamento(IIf(INCLUI.or.ALTERA,3,2),.t.)
			EndIf
		Else
			MsgInfo(STR0364) //Selecione uma condição de pagamento negociada com tipo A
		EndIf
	Else
		MsgInfo(STR0365) //"Selecione uma condição de pagamento negociada"
	EndIf
Return

/*/{Protheus.doc} OX0010151_atualiza_impostos_aCols_Servicos
	Atualiza impostos na aCols de Servicos
	
	@type function
	@author Andre Luis Almeida
	@since 16/06/2021
/*/
Static Function OX0010151_atualiza_impostos_aCols_Servicos(nLinha)
Local nCol     := 0
Default nLinha := 1
IIf( ( nCol := FG_POSVAR("VS4_ABAISS","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_ABAISS := MaFisRet(n,"IT_ABVLISS") ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_BASISS","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_BASISS := MaFisRet(n,"IT_BASEISS") ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_ALIISS","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_ALIISS := MaFisRet(n,"IT_ALIQISS") ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_VALISS","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_VALISS := MaFisRet(n,"IT_VALISS")  ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_CODISS","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_CODISS := MaFisRet(n,"IT_CODISS")  ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_BASPIS","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_BASPIS := MaFisRet(n,"IT_BASEPS2") ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_ALIPIS","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_ALIPIS := MaFisRet(n,"IT_ALIQPS2") ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_VALPIS","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_VALPIS := MaFisRet(n,"IT_VALPS2")  ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_BASCOF","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_BASCOF := MaFisRet(n,"IT_BASECF2") ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_ALICOF","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_ALICOF := MaFisRet(n,"IT_ALIQCF2") ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_VALCOF","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_VALCOF := MaFisRet(n,"IT_VALCF2")  ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_BASIRR","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_BASIRR := MaFisRet(n,"IT_BASEIRR") ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_ALIIRR","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_ALIIRR := MaFisRet(n,"IT_ALIQIRR") ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_VALIRR","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_VALIRR := MaFisRet(n,"IT_VALIRR")  ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_BASCSL","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_BASCSL := MaFisRet(n,"IT_BASECSL") ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_ALICSL","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_ALICSL := MaFisRet(n,"IT_ALIQCSL") ) , .t. )
IIf( ( nCol := FG_POSVAR("VS4_VALCSL","aHeaderS") ) > 0 , ( oGetServ:aCols[nLinha,nCol] := M->VS4_VALCSL := MaFisRet(n,"IT_VALCSL")  ) , .t. )
Return

/*/{Protheus.doc} OX0010181_CamposAlterarLinha
	Executado na mudança de linhas nas grids de Peças e Serviços (Evento bChange) 
	Chama PE que possibilita a alteração do aAlter das GetDados: 1-Peças / 2-Serviços
	
	@type function
	@author Andre Luis Almeida
	@since 21/09/2021
/*/
Static Function OX0010181_CamposAlterarLinha( lPEAltCpos , nTpGD , aAltPad )
Local aRet := {}
Default lPEAltCpos := ExistBlock("OX001ALT")
Default nTpGD      := 0
Default aAltPad    := {}
If lPEAltCpos .and. nTpGD > 0
	aRet := ExecBlock("OX001ALT",.f.,.f.,{ nTpGD , aClone(aAltPad) }) // ( nTpGD: 1-Peças ou 2=Serviços , vetor padrão aAlter )
	If nTpGD == 1 // Peças
		oGetPecas:aAlter := oGetPecas:oBrowse:aAlter := aClone(aRet) // Seta aAlter de Peças
	ElseIf nTpGD == 2 // Serviços
		oGetServ:aAlter := oGetServ:oBrowse:aAlter := aClone(aRet) // Seta aAlter de Servicos
	EndIf
EndIf
Return


/*/{Protheus.doc} OX001019B_ValidaMarcacaoSugCompra
	Função para tratar a Mensagem de não ser possível desmarcar os itens ao criar as Sugestões de Compras no Orçamento de Peças
	
	@type static function
	@author Alecsandre Aparecido Fabiano Santana Ferreira
	@since 27/10/2021
/*/
Static Function OX001019B_ValidaMarcacaoSugCompra(lSelec)
	Local lRet := .F.
	Default lSelec := .T.
	If lSelec
		MsgAlert(STR0372, STR0025) // Não é possível desmarcar os itens. Em todos os itens sem saldo suficiente deve ser criado uma sugestão de compras. / Atenção
	Endif
Return lRet

/*/{Protheus.doc} OX001020B_RetornaStatusOrcamento
	Funcao para retornar o Status do Orçamento
	
	@type function
	@author Alecsandre Aparecido Fabiano Santana Ferreira
	@since 27/10/2021
/*/
Function OX001020B_RetornaStatusOrcamento(cOriReq,cNroOrc,cGruItem,cCodItem)
	Local cQuery := " "
	Local cStatus := " "
	
	Default cNroOrc := ""
	Default cOriReq := ""

	If cOriReq <> "2" // Origem da requisição diferente de 2-Oficina

		cQuery := " SELECT "
		cQuery += " CASE WHEN VS1_TIPORC = 'P' "
		cQuery += 	" THEN "
		cQuery += 		" CASE WHEN VS1_PEDSTA = '3' "
		cQuery += 			" THEN 'C' "
		cQuery += 			" ELSE VS1_PEDSTA END "
		cQuery += 	" ELSE VS1_STATUS END AS VS1STATUS "
		cQuery += " FROM "
		cQuery += " 	" + retSqlName("VS1") + " VS1 "
		cQuery += " WHERE "
		cQuery += " 	VS1_FILIAL = '" + xFilial("VS1") + "' "
		cQuery += " 	AND VS1_NUMORC = '" + cNroOrc + "' "
		cQuery += " 	AND VS1.D_E_L_E_T_ = '' "

		cStatus := FM_SQL(cQuery)

	EndIf

Return Alltrim(cStatus)

/*/{Protheus.doc} OX0010211_Retorna_LOCALI2
	Retorna o LOCALI2 (SB5/SBM)

	@type function
	@author Andre Luis Almeida
	@since 23/09/2022
/*/
Function OX0010211_Retorna_LOCALI2(cGruIte,cCodIte)
Local cRet := ""
Default cGruIte := VS3->VS3_GRUITE
Default cCodIte := VS3->VS3_CODITE
SB1->(DbSetOrder(7))
If SB1->(MsSeek(xFilial("SB1")+cGruIte+cCodIte))
	SB5->(DbSetOrder(1))
	SB5->(MsSeek(xFilial("SB5")+SB1->B1_COD))
	cRet := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
EndIf
Return cRet

Static Function OX0010263_CalculaDesconto(_cAuxReadVar)

	local nQtdIte := IIF( M->VS3_QTDITE > 0 , M->VS3_QTDITE , 1 )

	If cMVMIL0026 == "S"

		M->VS3_VALLIQ := FtDescItem( ;
			@M->VS3_VALPEC,;                          // ExpN1: Preco de lista aplicado o desconto de cabecalho
			@M->VS3_VALPEC,;                          // ExpN2: Preco de Venda
			nQtdIte,;	                          // ExpN3: Quantidade vendida
			@M->VS3_VALTOT,;                          // ExpN4: Valor Total (do item)
			@M->VS3_PERDES,;                          // ExpN5: Percentual de desconto
			@M->VS3_VALDES,;                          // ExpN6: Valor do desconto
			@M->VS3_VALDES,;                          // ExpN7: Valor do desconto original
			iif(_cAuxReadVar=="M->VS3_VALDES",2,1))   // ExpN8: Tipo de Desconto (1 % OU 2 R$)

		//If _cAuxReadVar=="M->VS3_VALDES"
		//	nPerDesTemp := (M->VS3_VALDES/(M->VS3_VALTOT+M->VS3_VALDES))*100
		//	If M->VS3_PERDES == 0 .or. lRepPerDes
		//		M->VS3_PERDES := nPerdesTemp
		//	Endif				
		//Endif

		M->VS3_VALTOT := Round( (M->VS3_VALPEC*M->VS3_QTDITE) , 2 ) - M->VS3_VALDES

	Else
		if _cAuxReadVar == "M->VS3_PERDES"
			M->VS3_VALDES := M->VS3_VALTOT * M->VS3_PERDES / 100
			M->VS3_VALTOT := (M->VS3_VALPEC*M->VS3_QTDITE) - M->VS3_VALDES
		else
			M->VS3_VALTOT := (M->VS3_VALPEC*M->VS3_QTDITE) - M->VS3_VALDES
			M->VS3_PERDES := (M->VS3_VALDES/(M->VS3_VALTOT+M->VS3_VALDES))*100
		endif
		M->VS3_VALLIQ := Round(M->VS3_VALTOT / M->VS3_QTDITE, TamSX3("VS3_VALLIQ")[2])
	Endif
	
Return



/*/{Protheus.doc} OX0010221_TemRemuneracao
	Valida se existe Cadastro do % de Remuneração
	
	@type function
	@author Andre Luis Almeida
	@since 09/02/2022
/*/
Function OX0010221_TemRemuneracao( cCdCond )
Local lRet := .t.
Local aArea := {}
Default cCdCond := M->VS1_FORPAG
If GetNewPar("MV_MIL0172",.F.) .and. FindFunction("OFA420031_Remuneracao") .and. VAI->(FieldPos("VAI_PSCREM")) > 0 // Trabalha com Remuneração?
	If OX0010363_ClienteConsideraRemuneracao( M->VS1_CLIFAT , M->VS1_LOJA )
		aArea := sGetArea(aArea,"VAI")
		VAI->(DbSetOrder(4))
		If VAI->(DbSeek( xFilial("VAI") + __CUSERID )) .and. VAI->VAI_PSCREM == "0" // Não permite Venda Balcão/Oficina quando não existir cadastrado o % de Remuneração por Condição de Pagamento.
			If OFA420031_Remuneracao( cCdCond , IIf( MaFisFound('NF') , ( MaFisRet(,"NF_TOTAL") - MaFisRet(,"NF_DESCZF") ) , 0 ) ) == 0 // Não existe Remuneração Cadastrada
				ShowHelpDlg( "OX0010221_TemRemuneracao", { STR0377 }) // Não existe cadastro do % de Remuneração para a Condição de Pagamento selecionada. Impossivel continuar.
				lRet := .f.
			EndIf
		EndIf
		sRestArea(aArea)
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OX0010231_Cliente_Funcionario
	Verifica se o Cliente ( SA1 ) é funcionario da Empresa ( SRA )
	
	@type static function
	@author Andre Luis Almeida
	@since 10/03/2022
/*/
Static Function OX0010231_Cliente_Funcionario( cCodCli , cLojCli )
Local lFunc   := .f.
Local cCGCSA1 := FM_SQL("SELECT A1_CGC FROM "+RetSqlName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+cCodCli+"' AND A1_LOJA='"+cLojCli+"' AND D_E_L_E_T_=' '")
Local cFilSRA := ""
Local cTabSRA := ""
Local cQAlSRA := "SQLSRA"
Local cQuery  := ""
Local nQtdFil := 0



//conout("OX0010231_Cliente_Funcionario")

If !Empty(cCGCSA1)
	cTabSRA := RetSqlName("SRA")
	cQuery := "SELECT DISTINCT RA_FILIAL FROM "+cTabSRA+" WHERE D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSRA , .F., .T. )
	While !( cQAlSRA )->( Eof() )
		cFilSRA += "'"+( cQAlSRA )->( RA_FILIAL )+"',"
		nQtdFil++
		( cQAlSRA )->( dbSkip() )
	EndDo
	( cQAlSRA )->( dbCloseArea() )
	If nQtdFil > 1
		cFilSRA := "IN ("+left(cFilSRA,len(cFilSRA)-1)+")"
	Else
		cFilSRA := "= '"+xFilial("SRA")+"'"
	EndIf
	cQuery := "SELECT R_E_C_N_O_ FROM "+cTabSRA+" WHERE RA_FILIAL "+cFilSRA+" AND RA_CIC='"+cCGCSA1+"' AND ( RA_DEMISSA=' ' OR RA_DEMISSA>'"+dtos(dDataBase)+"' ) AND RA_CATFUNC<>'A' AND D_E_L_E_T_=' '" // diferente de AUTONOMO
	lFunc := ( FM_SQL(cQuery) > 0 )
EndIf
Return lFunc

/*/
{Protheus.doc} OX0010241_SaldoPromocao
Saldo Promoção - Valida e Utiliza Saldo

@author Andre Luis Almeida
@since 01/06/2022
/*/
Function OX0010241_SaldoPromocao( lUtiPromoc , cObsPromoc )
Local lRet       := .t.
Local cSeqVEN    := ""
Local cCodVBM    := ""
Local nQtdMov    := 0
Local nCntFor    := 0
Local nSldPro    := 0
Local aProSemSld := {} // Promoções SEM saldo
Local aProComSld := {} // Promoções COM saldo
If nVS3SEQVEN > 0 .and. Type( "OGETPECAS" ) != 'U' // Só deve ser executado dentro do orçamento e não na liberação de crédito que não possui o objeto oGetPecas
	For nCntFor := 1 to len(oGetPecas:aCols)
 		If oGetPecas:aCols[nCntFor, nVS3PROMOC ] == "1" // Promoção
			cSeqVEN := oGetPecas:aCols[nCntFor,nVS3SEQVEN]
			If !Empty(cSeqVEN)
				cCodVBM := OA4400011_Codigo_Saldo_Promocao( cSeqVEN )
				If !Empty(cCodVBM)
					nSldPro := OA4410021_Saldo_Promocao( cCodVBM )
					nQtdMov := oGetPecas:aCols[nCntFor, nVS3QTDITE]
					If nSldPro < nQtdMov
						aAdd(aProSemSld,{	oGetPecas:aCols[nCntFor, nVS3SEQUEN] ,;
											oGetPecas:aCols[nCntFor, nVS3GRUITE] ,;
											oGetPecas:aCols[nCntFor, nVS3CODITE] ,;
											oGetPecas:aCols[nCntFor, nVS3DESITE] ,;
											nQtdMov ,;
											nSldPro })
					Else
						If lUtiPromoc
							aAdd(aProComSld,{	cSeqVEN ,;
												nQtdMov ,;
												oGetPecas:aCols[nCntFor, nVS3SEQUEN] })
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next
	If len(aProSemSld) > 0 // Problema de Saldo da Promoção
		If MsgYesNo(STR0381,STR0025) // Existem itens com o saldo em Promoção menor que a quantidade desejada. Impossivel continuar. Deseja Visualizá-los? / Atenção
			OX0010251_Visualiza_Promocao_sem_Saldo( aProSemSld )
		EndIf
		lRet := .f.
	Else
		If lUtiPromoc .and. len(aProComSld) > 0 // Existe Saldo da Promoção, dar baixa das quantidades ( Utilizar )
			For nCntFor := 1 to len(aProComSld)
				OA4410011_Incluir_Movimentacoes_Promocao( aProComSld[nCntFor,1] , "1" , aProComSld[nCntFor,2] , VS1->VS1_FILIAL , VS1->VS1_NUMORC , aProComSld[nCntFor,3] , cObsPromoc )
			Next
		EndIf
	EndIf
EndIf
Return lRet

/*/
{Protheus.doc} OX0010251_Visualiza_Promocao_sem_Saldo
Visualiza Promoção sem Saldo

@author Andre Luis Almeida
@since 01/06/2022
/*/
Static Function OX0010251_Visualiza_Promocao_sem_Saldo( aProSemSld )
Local aIntCab := {}
Local cPicQtd := GetSX3Cache("VS3_QTDITE","X3_PICTURE")
aAdd(aIntCab,{STR0383,"C", 30,"@!"}) // Seq.Orçamento
aAdd(aIntCab,{STR0018,"C", 40,"@!"}) // Grupo
aAdd(aIntCab,{STR0020,"C", 80,"@!"}) // Codigo do Item
aAdd(aIntCab,{STR0021,"C", 100,"@!"}) // Descrição
aAdd(aIntCab,{STR0384,"N",70,cPicQtd}) // Qtd.Desejada
aAdd(aIntCab,{STR0385,"N",70,cPicQtd}) // Saldo em Promoção
FGX_VISINT( "OX0010251" , STR0382 , aIntCab , aClone(aProSemSld) , .t. ) // Visualiza Promoção sem Saldo
Return

/*/
{Protheus.doc} OX0010261_Verifica_Saldo_Promocao
Verifica Saldo em Promoção

@author Andre Luis Almeida
@since 03/06/2022
/*/
Static Function OX0010261_Verifica_Saldo_Promocao()
Local cCodVBM    := ""
Local nVS3PROMOC := FG_POSVAR("VS3_PROMOC","oGetPecas:aHeader")
Local nSldPromoc := 0
Local cPicQtd    := ""
Local cMsgAviso  := ""
Local n_Opcao    := 1
If nVS3SEQVEN > 0 .and. nVS3PESPRO > 0
	If oGetPecas:aCols[oGetPecas:nAt,nVS3PROMOC] == "1" // Promoção
		cCodVBM := OA4400011_Codigo_Saldo_Promocao( oGetPecas:aCols[oGetPecas:nAt,nVS3SEQVEN] )
		If !Empty(cCodVBM)

			nSldPromoc := OA4410021_Saldo_Promocao( cCodVBM )

			If M->VS3_QTDITE > nSldPromoc
				If nSldPromoc > 0
					cPicQtd := GetSX3Cache("VS3_QTDITE","X3_PICTURE")

					cMsgAviso := STR0387+": "+Transform(M->VS3_QTDITE,cPicQtd)+CHR(13)+CHR(10) // Quantidade desejada
					cMsgAviso += STR0388+": "+Transform(nSldPromoc,cPicQtd)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Quantidade disponivel
					cMsgAviso += STR0395 // Deseja manter a quantidade digitada desconsiderando a Promoção ou somente a quantidade Promocional disponivel?

					n_Opcao := Aviso(STR0386, cMsgAviso, { STR0396 , STR0397 }, 3) // Item sem Saldo em Promoção. / Sem Promoção / Com Promoção

				EndIf

				If n_Opcao == 1 // Sem Promoção

					oGetPecas:aCols[oGetPecas:nAt,nVS3PESPRO] := M->VS3_PESPRO := "0" // Nao Pesquisa Promocao nesta linha
					oGetPecas:aCols[oGetPecas:nAt,nVS3PROMOC] := M->VS3_PROMOC := "0" // Promocao: NAO
					oGetPecas:oBrowse:Refresh()

					__ReadVar := "M->VS3_CODITE"// executa o fieldok do VS3_CODITE novamente para pegar o valor normal da peça sem desconto da promoção

				Else // Com Promoção

					oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_QTDITE","oGetPecas:aHeader")] := M->VS3_QTDITE := nSldPromoc // Saldo disponivel para Promoção
					oGetPecas:oBrowse:Refresh()
					__ReadVar := "M->VS3_QTDITE" // executa o fieldok do VS3_QTDITE novamente

				EndIf
				OX001FPOK(.f.,,.f.,.f.,,.f.)
			EndIf
		EndIf
	EndIf
EndIf
Return

/*/{Protheus.doc} OX0010271_PercentualRemuneracao
	Levanta o Percentual de Remuneração
	
	@type static function
	@author Andre Luis Almeida
	@since 08/02/2022
/*/
Static Function OX0010271_PercentualRemuneracao( lLevanta )
Local aRemuner := {}
If Empty(M->VS1_STATUS) .or. M->VS1_STATUS == "0" // Somente para Orçamento com Status 0=Digitado
	If GetNewPar("MV_MIL0172",.F.) .and. lOFA420021_LevantaRemuneracao .and. lVS1PERREM // Trabalha com Remuneração?
		M->VS1_PERREM := 0   // % da Remuneração - Default: 0
		M->VS1_CONPRO := "2" // Considera Promoção? - Default: 2 = Sim e Acrescenta Percentual
		If lLevanta .and. !Empty(M->VS1_FORPAG) .and. !Empty(M->VS1_CLIFAT+M->VS1_LOJA)
			If OX0010363_ClienteConsideraRemuneracao( M->VS1_CLIFAT , M->VS1_LOJA )
				aRemuner := OFA420021_LevantaRemuneracao( M->VS1_FORPAG , IIf( MaFisFound('NF') , ( MaFisRet(,"NF_TOTAL") - MaFisRet(,"NF_DESCZF") ) , 0 ) , M->VS1_CLIFAT , M->VS1_LOJA )
				M->VS1_PERREM := aRemuner[1] // % da Remuneração
				M->VS1_CONPRO := aRemuner[2] // Considera Promoção?
			EndIf
		EndIf
		oEnch:Refresh()
	EndIf
EndIf
Return

Static Function OX0010363_ClienteConsideraRemuneracao(cCodCli,cLojCli)
	if _CliRemuneracao_[1] <> cCodCli + cLojCli
		_CliRemuneracao_[2] := OFA420051_ClienteConsideraRemuneracao(cCodCli,cLojCli)
	endif
return _CliRemuneracao_[2]

/*/{Protheus.doc} OX001028D_ExibeProdutosSemSaldo
	Exibe produtos sem saldo em estoque

	@type function
	@author Francisco Carvalho
	@since 04/01/2023
/*/
Static Function OX001028D_ExibeProdutosSemSaldo( aProdSdEst )

	Local aIntCab := {}, aIntIte := {}
	Local cNomRel := "OFIXX001"
	Local cTitulo := STR0394 //Produtos sem saldo em estoque.

	Default aProdSdEst := {}

	If Len(aProdSdEst) > 0

		aAdd(aIntCab,{STR0018,"C",50,"@!"})					//Grupo
		aAdd(aIntCab,{STR0011,"C",50,"@!"})				    //Produto
		aAdd(aIntCab,{STR0021,"C",200,"@!"})			    //Descricao
		aAdd(aIntCab,{STR0204,"N",50,"@E 999,999.99" })		//Qtde Solicitada
		aAdd(aIntCab,{STR0324,"N",50,"@E 999,999.99" })		//Qtde Estoque

		aIntIte := aClone(aProdSdEst)

		FGX_VISINT(cNomRel , cTitulo , aIntCab , aIntIte , .t. )

	Endif

Return


Function OX0010225_ReservaManual(nOpc)

	if OX001GRV(nOpc,,,.t.,,,) == .f.
		return .f.
	else

		if ExistBlock("ORDBUSCB")
			ExecBlock("ORDBUSCB",.f.,.f.,{"OR","ALTERA"})
		Endif

	endif

Return

/*/{Protheus.doc} OX0010245_ValidacaoGridPeca
	

	@type function
	@author Renato Vinicius
	@since 17/10/2022
/*/

Static Function OX0010245_ValidacaoGridPeca(oGetPeca,nOpc,lDadoPec,aItens,aPecSemEst)

	Local nQtdEst    := 0

	Default aPecSemEst := {}

	If Empty(oGetPeca[FG_POSVAR("VS3_CODITE","aHeaderP")])
		If !(oGetPeca[len(oGetPeca)]) .or. (len(aItens) == 1 .and. oGetPeca[len(oGetPeca)])
			lDadoPec := .f.
		EndIf
		Return .f.
	endif

	If LinhaSemQuantidade(nOpc,oGetPeca)
		FMX_HELP("SEMQTD", STR0051)
		Return .f.
	Endif

	SB1->(DbSetOrder(7))
	SB1->(MsSeek(xFilial("SB1")+oGetPeca[nVS3GRUITE]+oGetPeca[nVS3CODITE]))
	If !MaAvalPerm( 3 , { oGetPeca[nVS3LOCAL] , SB1->B1_COD } )
		SB1->(DbSetOrder(1))
		Return .f. // Usuario sem permissao para utilizar o Almoxarifado
	EndIf

	// verifica se É possivel Faturar a Quantidade existente no Pedido
	SF4->(DbSeek(xFilial("SF4")+oGetPeca[FG_POSVAR("VS3_CODTES","aHeaderP")]))
	If lPediVenda .and. lFaturaPVP .and. SF4->F4_ESTOQUE == "S"
		if oGetPeca[nVS3RESERV] != "1"
			nQtdEst := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+Iif(!Empty(oGetPeca[nVS3LOCAL]),oGetPeca[nVS3LOCAL],OX0010105_ArmazemOrigem()))
			If oGetPeca[nVS3QTDITE] > nQtdEst
				aadd(aPecSemEst,{SB1->B1_GRUPO,SB1->B1_CODITE,oGetPeca[nVS3QTDITE],nQtdEst})
			Endif
		Endif
	Endif

	// Verificação da Fórmula informada
	If !Empty(oGetPeca[nVS3FORMUL])
		If OFP8600016 .And. !OFP8600016_VerificacaoFormula(oGetPeca[nVS3FORMUL])
			Return .f. // A mensagem já é exibida dentro da função
		EndIf
	EndIf


Return .t.

/*/{Protheus.doc} OX0010255_ValidacaoGridServico
	

	@type function
	@author Renato Vinicius
	@since 17/10/2022
/*/

Static Function OX0010255_ValidacaoGridServico(oGetServ,nOpc,lDadoSrv)
	
	if M->VS1_TIPORC == "1"
		If !(oGetServ[len(oGetServ)]) .and. !Empty(oGetServ[fg_posvar("VS4_CODSER","aHeaderS")])
			if !lOX001Auto .and. !lLibPV
				MsgInfo(STR0057,STR0025)
			endif
			Return .f.
		Endif
	Endif

	if !(oGetServ[len(oGetServ)]) .and. Empty(oGetServ[FG_POSVAR("VS4_CODSER","aHeaderS")])
		lDadoSrv := .f.
		Return .f.
	endif

Return .t.

/*/{Protheus.doc} OX0010265_ValidacaoGridInconveniente
	

	@type function
	@author Renato Vinicius
	@since 17/10/2022
/*/

Static Function OX0010265_ValidacaoGridInconveniente(oGetInconv,nOpc,lDadoInc)

	if M->VS1_TIPORC == "1"
		If !(oGetInconv[len(oGetInconv)]) .and. !Empty(oGetInconv[FG_POSVAR("VST_DESINC","aHeaderI")])
			if !lOX001Auto .and. !lLibPV
				MsgInfo(STR0144,STR0025)
			endif
			Return .f.
		EndIf
	EndIf

	if !(oGetInconv[Len(oGetInconv)]) .and. Empty(oGetInconv[FG_POSVAR("VST_DESINC","aHeaderI")])
		lDadoInc := .f.
		Return .f.
	endif

Return .t.

/*/{Protheus.doc} OX0010275_AtualizaDadosOrcamento
	

	@type function
	@author Renato Vinicius
	@since 17/10/2022
/*/

Function OX0010275_AtualizaDadosOrcamento(aVS3Item,cDocto)

	Local nI := 0
	Local aAreaVS3 := GetArea()
	Local nSaldoP  := 0
	Local nPosItem := 0

	Default aVS3Item := {}
	Default cDocto   := ""

	For nI := 1 to Len(aVS3Item)

		nPosItem := aVS3Item[nI,2]

		VS3->( DbGoTo( aVS3Item[nI,1] ) )
		SB1->(DBSetOrder(7))
		SB1->(DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
		SB1->(DBSetOrder(1))
		nSaldoP := OX001SLDPC( xFilial("SB2") + SB1->B1_COD + oGetPecas:aCols[ nPosItem , FG_POSVAR("VS3_LOCAL","aHeaderP")] )

		oGetPecas:aCols[ nPosItem , FG_POSVAR("VS3_RESERV","aHeaderP") ] := M->VS3_RESERV := VS3->VS3_RESERV
		oGetPecas:aCols[ nPosItem , FG_POSVAR("VS3_QTDRES","aHeaderP") ] := M->VS3_QTDRES := VS3->VS3_QTDRES
		oGetPecas:aCols[ nPosItem , FG_POSVAR("VS3_QTDEST","aHeaderP") ] := M->VS3_QTDEST := nSaldoP
		oGetPecas:aCols[ nPosItem , FG_POSVAR("VS3_DOCSDB","aHeaderP") ] := cDocto

	Next

	RestArea(aAreaVS3)

Return

/*/{Protheus.doc} OX0010285_GeracaoSugestaoCompra
	

	@type function
	@author Renato Vinicius
	@since 17/10/2022
/*/

Static Function OX0010285_GeracaoSugestaoCompra(nOpc,aSugest,lRegBO,cCodMar,lFaseReserv)

	Local lOk := .f.
	Local nI  := 0

	Local lImpSugInd := .f.
	
	Local lAguardar  := .f.
	Local lReservar  := .f.
	Local lSoGravar  := .f.

	cForPed := ""

	If lFaseReserv .or. lRegBO
		lReservar := .t.
	EndIf

	lOk := OX0010295_GravaSugestaoCompra(aSugest,lRegBO,@lAguardar)

	If lOk

		For nI := 1 to Len(aSugest)

			OX0010305_GravaDadosItemSugOrcamento(aSugest[nI])

		Next

		if !lImpSugInd // Quando nao for 'Unidade Parada' ou for BACKORDER gera relatorio para sugestao de compra gerada como era antes
			OX001RSC(aSugest)
		Endif

		MsgInfo(STR0208,STR0025) // As peças selecionadas foram solicitadas para compra / Atenção

		If !lReservar
			lSoGravar := .t.
		EndIf

		OX001FAT(nOpc,lSoGravar,.F.,.t.)

	EndIf

Return

/*/{Protheus.doc} OX0010295_MontagemTelaSugestaoCompra
	

	@type function
	@author Renato Vinicius
	@since 17/10/2022
/*/

Static Function OX0010295_GravaSugestaoCompra(aSugest,lRegBO,lAguardar,lUnidParad)

	lRetorno := OFIA485(aSugest,lRegBO,@lAguardar,@lUnidParad)

Return lRetorno

/*/{Protheus.doc} OX0010305_GravaDadosItemSugOrcamento

	@type function
	@author Renato Vinicius
	@since 24/11/2022
/*/

Static Function OX0010305_GravaDadosItemSugOrcamento(aGrvSug)

	DBSelectArea("VS3")
	DBSetOrder(1)

	if DBSeek(aGrvSug[9])

		reclock("VS3",.f.)
			VS3->VS3_QTDAGU := aGrvSug[5]
		msunlock()

		OX0010315_AtualizaGridOrcamento(aGrvSug)

	EndIf

Return

/*/{Protheus.doc} OX0010315_AtualizaGridOrcamento

	@type function
	@author Renato Vinicius
	@since 24/11/2022
/*/

Static Function OX0010315_AtualizaGridOrcamento(aGrvSug)

	oGetPecas:aCols[aGrvSug[10],FG_POSVAR("VS3_QTDAGU","aHeaderP")] := VS3->VS3_QTDAGU
	oGetPecas:oBrowse:refresh()

Return

/*/{Protheus.doc} OX0010325_ValidaGeracaoSugestaoCompra

	@type function
	@author Renato Vinicius
	@since 24/11/2022
/*/

Static Function OX0010325_ValidaGeracaoSugestaoCompra(lVldInicial, aSugest, lRegBO)

	Local lGerouSug     := .f.

	Default lVldInicial := .t.

	If lVldInicial

		If M->VS1_TIPORC <> "1" .And. M->VS1_TIPORC <> "P"
			MsgStop(STR0358, STR0025) // Sugestão de compra é permitido apenas para Orçamentos de Peças! / Atenção
			return
		EndIf

		If FECHA .and. M->VS1_STATUS <> "A"
			MsgAlert(STR0371, STR0025) // A criação da Sugestão de Compras não pode ser utilizada na opção de Faturamento. Para utilizar esta opção, deve-se utilizar a opção de Alteração. / Atencao
			Return .f.
		EndIf

	Else

		If lRegBo .AND. Empty(aSugest)
			MsgStop(STR0310  /* "Nenhum item passível de BackOrder detectado nos itens do pedido/orçamento" */, STR0025 /*Atenção*/)
			Return
		ElseIf Empty(aSugest)
			MsgStop(STR0193,STR0025) // Não existe peça em falta no orçamento atual./ Atenção
			return
		EndIf

		If !MsgYesNo(STR0373, STR0025) // A criação da Sugestão de Compras de Peças implicará na reserva das peças disponíveis em estoque e avançará a fase do orçamento, não sendo mais possível alterá-lo. Deseja Continuar?
			return
		Endif

		lGerouSug := OX0010355_ValidaItemSugestaoCompra(aSugest)

		If lGerouSug
			if !MsgYesNo(STR0194,STR0025) // Ja foi gerada solicitação para este orçamento. Deseja gerar nova solicitação? / Atenção
				Return .f.
			EndIf
		EndIf

	EndIf

Return .t.

/*/{Protheus.doc} OX0010335_ValidaQTDOrcamento

	@type function
	@author Renato Vinicius
	@since 24/11/2022
/*/

Static Function OX0010335_ValidaQTDOrcamento(cNUMORC,cSEQUEN,cGRUITE,cCODITE,nQtdDig)

	Local cQuery := ""

	cQuery := "SELECT VS3.VS3_QTDITE "
	cQuery += " FROM " + RetSQLName("VS3") + " VS3 "
	cQuery += " WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
	cQuery += 	" AND VS3.VS3_NUMORC = '" + cNUMORC + "' "
	cQuery += 	" AND VS3.VS3_SEQUEN = '" + cSEQUEN + "' "
	cQuery += 	" AND VS3.VS3_GRUITE = '" + cGRUITE + "' "
	cQuery += 	" AND VS3.VS3_CODITE = '" + cCODITE + "' "
	cQuery += 	" AND VS3.D_E_L_E_T_ = ' ' "

	nQtItOr := FM_SQL(cQuery)

	If M->VS1_STATUS == "A" .and. nQtdDig > nQtItOr
		MsgInfo(STR0402,STR0025) //"Não é permitido informar uma quantidade superior a quantidade origem do orçamento."
		Return .f.
	EndIf

Return .t.

/*/{Protheus.doc} OX0010345_AjustaQtdRequisitadaConferida

	@type function
	@author Renato Vinicius
	@since 29/06/2023
/*/

Static Function OX0010345_AjustaQtdRequisitadaConferida()

	Local aArea    := {}
	Local lAtualiz := .f.
	Local nPosPec  := 0

	aArea := sGetArea(aArea , "VS3")

	If MsgNoYes(STR0403,STR0025) //"Deseja ajustar as quantidades requisitadas automáticamente de acordo com as quantidades conferidas de todos os itens deste orçamento?"

		cQuery := "SELECT VS3.R_E_C_N_O_ AS VS3RECNO "
		cQuery += "FROM " + RetSQLName("VS3") + " VS3 "
		cQuery += "WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
		cQuery += 	"AND VS3.VS3_NUMORC = '" + VS1->VS1_NUMORC + "' "
		cQuery +=	"AND VS3.VS3_QTDITE <> VS3.VS3_QTDCON "
		cQuery += 	"AND VS3.D_E_L_E_T_ = ' ' "

		TcQuery cQuery New Alias "TMPPEC"

		While !TMPPEC->(Eof())

			lAtualiz := .t.

			DbSelectArea("VS3")
			DbGoTo(TMPPEC->VS3RECNO)

			nPosPec := aScan(oGetPecas:aCols,{|x| x[FG_POSVAR("VS3_REC_WT","aHeaderP")] == TMPPEC->VS3RECNO })
			If nPosPec > 0
				oGetPecas:aCols[nPosPec,FG_POSVAR("VS3_QTDITE","aHeaderP")] := M->VS3_QTDITE := VS3->VS3_QTDCON
				__ReadVar := 'M->VS3_QTDITE'
				oGetPecas:nAt := nPosPec
				OX001FPOK(.f.,,.f.,.f.)
			Endif

			TMPPEC->(DbSkip())

		EndDo


		TMPPEC->(DbCloseArea())

		If lAtualiz
			MsgInfo(STR0404) //"Atualização das quantidades requisitadas de acordo com a quantidades conferidas concluída com sucesso."
			oGetPecas:oBrowse:refresh()
		EndIf

	EndIf

	DbSelectArea("VS3")
	sRestArea(aArea)

Return .t.



/*/{Protheus.doc} OX0010393_GM
Retorna o codigo da marca relacionada a GM/Chevrolet

@author Rubens
@since 10/11/2023
@version 1.0

@type function
/*/
Static Function OX0010393_GM()

	if _FG_MARCA_ == NIL
		_FG_MARCA_ := FG_MARCA("CHEVROLET",,.f.)
	endif

Return _FG_MARCA_


/*/{Protheus.doc} OX0010355_ValidaItemSugestaoCompra

	@type function
	@author Renato Vinicius
	@since 29/06/2023
/*/
Static Function OX0010355_ValidaItemSugestaoCompra(aSugest)

	Local lRetorno := .f.
	Local nI       := 0

	For nI := 1 to Len(aSugest)

		nQtdSug := OA4840015_ItemSugestaoCompra(VS1->VS1_FILIAL, VS1->VS1_NUMORC, , aSugest[nI, 2], aSugest[nI, 3], aSugest[nI, 13], , , , , , , , .t.)

		If nQtdSug > 0
			lRetorno := .t.
			Exit
		EndIf

	next

Return lRetorno

/*/{Protheus.doc} OX0010163_SequenciaVS3

	@type function
	@author Rubens Takahashi
	@since 02/10/2023
/*/

Static Function OX0010163_SequenciaVS3()

	If Empty(M->VS3_SEQUEN)
		M->VS3_SEQUEN := oGetPecas:aCols[oGetPecas:nAt, nVS3SEQUEN] := StrZero(++nPrxVS3Sequen,GetSX3Cache("VS3_SEQUEN","X3_TAMANHO"))
	EndIf

Return

/*/{Protheus.doc} OX0010365_SequenciaVS4

	@type function
	@author Renato Vinicius
	@since 03/10/2023
/*/

Static Function OX0010365_SequenciaVS4()

	If Empty(M->VS4_SEQUEN)
		M->VS4_SEQUEN := oGetServ:aCols[oGetServ:nAt, nVS4SEQUEN] := StrZero(++nPrxVS4Sequen,GetSX3Cache("VS4_SEQUEN","X3_TAMANHO"))
	EndIf

Return
