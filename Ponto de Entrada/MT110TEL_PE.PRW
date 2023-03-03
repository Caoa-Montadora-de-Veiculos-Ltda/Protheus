#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT110TEL
P.E. - Manipulação do cabeçalho da Solicitação de Compras
@author
@since 15/05/2019
@version 1.0
@type function
/*/
user function MT110TEL()
    Local _lRet
	//local bXTPIMPGWhen := { || nOpcx == 3 .Or. nOpcx == 4 }

    public oNewDialog   := PARAMIXB[1]
	public aPosGet      := PARAMIXB[2]
	public nOpcx        := PARAMIXB[3]
	public nReg         := PARAMIXB[4]
	/*// ** TOTVS - EIC
	public cTpImp	   := iif( INCLUI, Space(TamSX3('C1_XTPIMP')[1]), SC1->C1_XTPIMP)
	public cNumPRO	   := iif( INCLUI, Space(TamSX3('C1_NR_PRO')[1]), SC1->C1_NR_PRO)
	public czMoeda	   := iif( INCLUI, Space(TamSX3('C1_MOEDA')[1]) , SC1->C1_MOEDA )

	aadd(aPosGet[1],0)
	aadd(aPosGet[1],0)

	aadd(aPosGet[1],0)
	aadd(aPosGet[1],0)

	aadd(aPosGet[1],0)
	aadd(aPosGet[1],0)

	aPosGet[1,07] := aPosGet[1,1]//031
	aPosGet[1,08] := aPosGet[1,2]//109

	aPosGet[1,09] := aPosGet[1,3]//031
	aPosGet[1,10] := aPosGet[1,4]//109

	aPosGet[1,11] := aPosGet[1,5]//031
	aPosGet[1,12] := aPosGet[1,6]//109


	@ 63, aPosGet[1,07] SAY 'Tp Import' PIXEL SIZE 50,10 Of oNewDialog
	@ 63 ,aPosGet[1,08] MSGET cTpImp PICTURE "@!" PIXEL SIZE 40,10 Valid (Vazio() .or. ExistCpo("ZZ8")) F3 "ZZ8" WHEN Eval( bXTPIMPGWhen ) Of oNewDialog

	@ 63, aPosGet[1,09] SAY 'Proforma' PIXEL SIZE 50,10 Of oNewDialog
	@ 63 ,aPosGet[1,10] MSGET cNumPRO PICTURE "@!" PIXEL SIZE 40,10 Valid .T. WHEN Eval( bXTPIMPGWhen ) Of oNewDialog

	@ 63, aPosGet[1,11] SAY 'Moeda' PIXEL SIZE 50,10 Of oNewDialog
	@ 63 ,aPosGet[1,12] MSGET czMoeda PICTURE "@!" PIXEL SIZE 40,10 F3 "ZSYF" Valid .T. WHEN Eval( bXTPIMPGWhen ) Of oNewDialog
*/
	// ** ************************************************************ ** //
    // **  DIALOG INFORMACOES ADICIONAIS (Enchoise / MsmGet)           ** //
    // ** ************************************************************ ** //
	If FindFunction("U_ZCOMF003")
		// ** DIALOG DADOS COMPLEMENTARES EXECUCAO INICIAL
		// **  CRIA VARIAVEIS E CARREGA VALORES ULTIMA REVISAO (SZV)
		//U_ZCOMF003(nOpcX,.F.) // .F. - NAO EXIBE DIALOG PARA INICIALIZACAO

		Begin Sequence
		    _lRet := U_ZCOMF003({oNewDialog,aPosGet,nOpcx,nReg})
		End Sequence

	EndIf

Return (_lRet)
