
#include "Protheus.ch"
#include "OFIXX001.CH"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    |ZPECF007    | Autor | Sandro Ferreira       | Data | 14/10/21 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Funcao que faz a chamada da rotina de sugestao de compra     |##
##|          | tento como base a função padrão: OX001GSUG                   |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/ 
user Function ZPECF007(nOrc)
Local nCntFor      := 1
//Local nCntfor2, nCntSug
Local xAutoInc     := {}
Local aSugest      := {}
Local nEst         := 0
Local lFaseReserv  := At("R",GetNewPar("MV_FASEORC","0FX")) > 0
Local lOPM900Perg  := .f. // Tratamento dentro do OFIPM900 para verificar se ja foi chamado nao chamar novamente a tela de paramentros e numeração da sugestão de compra.
Local lOPM900Rel   := .f.
Local cDocSdb      := nOrc
Default lRegBO     := .T.
Private oPedido    := DMS_Pedido():New()

If VS1->VS1_TIPORC <> "1" .And. VS1->VS1_TIPORC <> "P"
	MsgStop(" Sugestão de compra é permitido apenas para Orçamentos de Peças! / Atenção ")
	return
EndIf

//Posiciona no primeiro registro da VS3 
dbSelectArea("VS3")
dbSetOrder(1)
If dbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
   While !(VS3->(Eof())) .AND. ( VS3->VS3_FILIAL = VS1->VS1_FILIAL .AND. VS3->VS3_NUMORC = VS1->VS1_NUMORC ) 
         nEst := 0
         DBSelectArea("SB1")
  	     DBSetOrder(7)
		 DBSeek(xFilial("SB1") + VS3->VS3_GRUITE + VS3->VS3_CODITE)
         nEst:= OX001SLDPC(xFilial("SB2")+VS3->VS3_CODITE+VS3->VS3_LOCAL)
		 DBSelectArea("SBM")
		 DBSetOrder(1)
		 DBSeek(xFilial("SBM")+SB1->B1_GRUPO)
		 aAdd(aSugest, { .t.                                , ;
		 VS3->VS3_GRUITE                                    , ;
		 VS3->VS3_CODITE                                    , ;
		 SB1->B1_DESC                                       , ;
		 VS3->VS3_QTDITE - nEst                             , ;
	     SBM->BM_CODMAR                                     , ;  
		 VS3->VS3_VALPEC                                    , ;
		 nEst                                               , ;
		 VS1->VS1_FILIAL + VS1->VS1_NUMORC + VS3->VS3_SEQUEN ,; // se alterar isso avisar manoel/vinicius, esse campo é usado abaixo com right
	     nCntFor,;
		 VS1->VS1_XTPPED ,;
	     .f. } )
        dbSelectArea("VS3")
        DbSkip()
        nCntFor ++
    END
Endif

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

nOpcao   := 1
cForPed  := ""
aRStatus := {STR0195,STR0196,STR0197,STR0198} // 0=Não Programado / 1=Programado / 2=Unidade Parada / 3=Emergencia

if nOpcao == 2
	MsgInfo(STR0205 ,STR0025) // Não foi gerada sugestão de compra para os itens / Atenção
	return
endif

If TYPE( oPedido:GtTpPedBO() ) == "L" // validação se o tipo de pedido de backorder está configurado
	MsgInfo(STR0305/*"Parâmetro MV_MIL0064 não configurado corretamente, verifique se o código existe na tabela VEJ ou que tenha o TIPO 'BO' cadastrado."*/ , STR0025/*"Atenção"*/)
	return
EndIf
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
				if VEJ->VEJ_XSUGC == '1' .AND. xFilial("VEJ")+aSugest[nCntFor,6] == VEJ->VEJ_FILIAL + VEJ->VEJ_CODMAR .and. aSugest[nCntFor,11] == VEJ->VEJ_XTPPED
					lAchou := .t.
				endif
				DBSKip()
			enddo
		endif
		
        /*
		DBSelectArea("VX5")
		DBSetOrder(1)
		if DBSeek(xFilial("VX5")+"Z00"+aSugest[nCntFor,6])
			while !eof() .and. VX5->VX5_CHAVE = "Z00"  .AND. aSugest[nCntFor,6] == alltrim(VX5->VX5_CODIGO)
				If VX5->VX5_CHAVE == "Z00" .and. alltrim(VX5->VX5_CODIGO)  == aSugest[nCntFor,6] 
                   lAchou := .t.
				   exit
                Endif    
				DBSKip()
			enddo
		endif
		*/

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
			aAdd( xAutoInc,{"VE6_FORPED" , oPedido:GtTpPedBO() })
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
		if VS3->(FieldPos("VS3_QTDAGU")) > 0 // se tem alguma peça aguardando
			if lFaseReserv .OR. lRegBO // e tem fase R lReg
				if lAguardar
					DBSelectArea("VS3")
					DBSetOrder(1)
					if DBSeek(aSugest[nCntFor,9])
						reclock("VS3",.f.)
						VS3_QTDAGU := aSugest[nCntFor,5]
					    VS3->VS3_RESERV := '1'
    					VS3->VS3_DOCSDB := cDocSdb
						msunlock()
					endif
				endif
			endif
			If !OFMI900("VE6",0,3,xAutoInc,.t.,.f.,OemToAnsi(STR0123),,.t.,lOPM900Perg,@lOPM900Rel)
				disarmTransaction()
				return .F.
			Endif
		endif
        lOPM900Perg := .T.
		aSugest[nCntFor,12] := lOPM900Rel
		if VEJ->VEJ_PROGRA == "2" .and. !lRegBO // Quando for 'Unidade Parada' e nao for BACKORDER gera um relatorio para cada sugestao de compra separadamente
			OX001RSC(aSugest)
			aSugest[nCntFor,12] := .f.
		Endif
	endif
next

//
// reserva do que tem saldo
//
if lFaseReserv .OR. lRegBO
	OX001RESITE(VS1->VS1_NUMORC, .t.)
endif

if !Empty(cOPM900Sug)
	MsgInfo(STR0320+CHR(13)+ CHR(10)+STR0321+cOPM900Sug) // Sugestao de compra gerado / Nro:
Endif
//
End Transaction

if !lSelAlgum
	return .f.
endif

return
