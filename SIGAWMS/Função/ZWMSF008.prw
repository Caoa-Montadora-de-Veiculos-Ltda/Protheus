#INCLUDE "TOTVS.CH"

// Classe Filha, herda a classe pai 
CLASS ZWMSF008 FROM WMSDTCMontagemUnitizadorItens
    DATA NumSeq

    METHOD NEW() CONSTRUCTOR
    METHOD zMntUnit()
    METHOD zAssignD0S()
    METHOD zUpdD0Q()
    METHOD SetNumSeq(NumSeq)
    METHOD zGrvD0R()
ENDCLASS

// Construtor da filha chama construtor da classe pai
METHOD NEW() CLASS ZWMSF008
    _Super:New()
return self

METHOD SetNumSeq(NumSeq) CLASS ZWMSF008
	Self:NumSeq := NumSeq
Return

//-----------------------------------------------------------------------------
METHOD zMntUnit() CLASS ZWMSF008
    Local lRet       := .T.
    Local aAreaAnt   := GetArea()
    Local cWhere     := ""
    Local cAliasQry  := Nil

	// Controle
	Self:SetIdUnitA(Self:GetIdUnit())
	// Valida unitizador
	If !Self:VldIdUnit()
		Return .F.
	EndIf
    
    cAliasQry := GetNextAlias()
    // Parâmetro Where
    cWhere := "%"
    If !Empty(Self:GetLoteCtl())
        cWhere += " AND D0Q.D0Q_LOTECT = '"+Self:GetLoteCtl()+"'"
    EndIf
    If !Empty(Self:GetNumLote())
        cWhere += " AND D0Q.D0Q_NUMLOT = '"+Self:GetNumLote()+"'"
    EndIf
    If !Empty(Self:oUnitiz:GetServico())
        cWhere += " AND D0Q.D0Q_SERVIC = '"+Self:oUnitiz:GetServico()+"'"
    EndIf
    cWhere += "%"
    cAliasQry := GetNextAlias()
    BeginSql Alias cAliasQry
        SELECT D0Q.D0Q_ID,
                D0Q.D0Q_SERVIC
        FROM %Table:D0Q% D0Q
        WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
        AND D0Q.D0Q_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
        AND D0Q.D0Q_ENDER = %Exp:Self:oUnitiz:GetEnder()%
        AND D0Q.D0Q_CODPRO = %Exp:Self:GetProduto()%
        AND D0Q.D0Q_PRDORI = %Exp:Self:GetPrdOri()%
        AND D0Q.D0Q_ORIGEM = %Exp:Self:oUnitiz:GetOrigem()%
        AND D0Q.D0Q_NUMSEQ = %Exp:Self:NumSeq%
        AND (D0Q.D0Q_QUANT-D0Q.D0Q_QTDUNI) > 0
        %Exp:cWhere%
        AND D0Q.%NotDel%
    EndSql
     
    If (cAliasQry)->(!Eof())
        Self:SetIdD0Q((cAliasQry)->D0Q_ID)
        Self:oUnitiz:SetServico((cAliasQry)->D0Q_SERVIC)
        If !Self:zAssignD0S()
            lRet := .F.
        EndIf
    Else
        Self:cErro := "Demanda de unitização não localizada, Numseq: " + Self:NumSeq
        lRet := .F.
    EndIf

    (cAliasQry)->(dbCloseArea())

	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
METHOD zAssignD0S() CLASS ZWMSF008
    Local lRet      := .T.

	// Criar um unitizador caso não exista
	If !Self:zGrvD0R()
		Self:cErro := Self:oUnitiz:oEtiqUnit:cErro
		lRet := .F.
	EndIf
	// Seta as informações para a criação da D0S
	If lRet
		If !Self:RecordD0S()
			Self:cErro := "Erro ao incluir D0S!"
			lRet := .F.
		EndIf

		If Self:lUsaD0Q
			If lRet .And. !Self:UpdateD14()
				lRet := .F.
			EndIf
			If lRet
				// Atualização da demanda
				Self:zUpdD0Q()
			EndIf
		EndIf
	EndIf
Return lRet

METHOD zUpdD0Q() CLASS ZWMSF008
    Local lRet       := .T.
    Local aAreaAnt   := GetArea()

	D0Q->(dbSetOrder(3))
    If D0Q->(dbSeek(xFilial("D0Q")+Self:GetIdD0Q()))
        RecLock("D0Q",.F.)
        D0Q->D0Q_QTDUNI := D0Q->D0Q_QTDUNI + Self:GetQuant()
        If QtdComp(D0Q->D0Q_QTDUNI) == QtdComp(0)
            D0Q->D0Q_STATUS := "1" // Pendente
        ElseIf QtdComp(D0Q->D0Q_QTDUNI) < QtdComp(D0Q->D0Q_QUANT)
            D0Q->D0Q_STATUS := "2" // Em Andamento
        Else
            D0Q->D0Q_STATUS := "3" // Finalizado
        EndIf
        D0Q->(MsUnLock())
    Else
        lRet := .F.
        Self:cErro := "Não foi possivel finalizar a demanda de unitização " +;
                      "IDD0Q " + Self:GetIdD0Q() + " não encontrado na tabela D0Q!"
    EndIf

	RestArea(aAreaAnt)
Return lRet

METHOD zGrvD0R() CLASS ZWMSF008
Local lRet      := .T.
Local lAchou    := .F.
Local cAliasQry := GetNextAlias()
	If Self:oUnitiz:oEtiqUnit:LoadData() .And. Self:oUnitiz:oEtiqUnit:LockD0Y()
		// Atualiza status da etiqueta de unitizador
		If !Self:oUnitiz:oEtiqUnit:GetIsUsed()
			Self:oUnitiz:oEtiqUnit:SetTipUni(Self:oUnitiz:GetTipUni())
			Self:oUnitiz:oEtiqUnit:SetUsado("1")
			Self:oUnitiz:oEtiqUnit:UpdateD0Y(.F.)
		EndIf

        // Busca as informações da Ordem de Serviço do primeiro documento da demanda
        BeginSql Alias cAliasQry
            SELECT 1
            FROM %Table:D0R% D0R
            WHERE D0R.D0R_FILIAL = %xFilial:D0R%
            AND D0R.D0R_LOCAL = %Exp:Self:oUnitiz:GetArmazem()%
            AND D0R.D0R_ENDER = %Exp:Self:oUnitiz:GetEnder()%
            AND D0R.D0R_IDUNIT = %Exp:Self:oUnitiz:GetIdUnit()%
            AND D0R.%NotDel%
        EndSql

	    lAchou := (cAliasQry)->(!Eof())
		// Grava D0R
		D0R->(dbSetOrder(1)) // D0R_FILIAL+D0R_LOCAL+D0R_ENDER+D0R_IDUNIT+D0R_IDDCF
		//lAchou := D0R->(dbSeek(xFilial("D0R")+Self:oUnitiz:GetArmazem()+Self:oUnitiz:GetEnder()+Self:oUnitiz:GetIdUnit()+Self:oUnitiz:cIdDCF))
		Reclock("D0R",!lAchou)
		If !lAchou
			D0R->D0R_FILIAL := xFilial("D0R")
			D0R->D0R_LOCAL  := Self:oUnitiz:GetArmazem()
			D0R->D0R_ENDER  := Self:oUnitiz:GetEnder()
			D0R->D0R_IDUNIT := Self:oUnitiz:GetIdUnit()
			D0R->D0R_CODUNI := Self:oUnitiz:oTipUnit:GetTipUni()
			D0R->D0R_STATUS := Self:oUnitiz:cStatus
			D0R->D0R_SERVIC := Self:oUnitiz:cServico
			D0R->D0R_DATINI := Self:oUnitiz:dDatIni
			D0R->D0R_HORINI := Self:oUnitiz:cHorIni
			D0R->D0R_DATFIM := Iif(Empty(Self:oUnitiz:dDatFim),dDataBase,Self:oUnitiz:dDatFim)
			D0R->D0R_HORFIM := Iif(Empty(Self:oUnitiz:cHorFim),Time(),Self:oUnitiz:cHorFim)
			D0R->D0R_IDDCF  := Self:oUnitiz:cIdDCF
		Else
			D0R->D0R_DATFIM := Iif(Empty(Self:oUnitiz:dDatFim),dDataBase,Self:oUnitiz:dDatFim)
			D0R->D0R_HORFIM := Iif(Empty(Self:oUnitiz:cHorFim),Time(),Self:oUnitiz:cHorFim)
		EndIf
		D0R->(MsUnLock())
		D0R->(DbCommit())
		// Grava recno
		Self:oUnitiz:nRecno := D0R->(Recno())
		// Libera lock
		Self:oUnitiz:oEtiqUnit:UnLockD0Y()
	Else
		lRet := .F.
	EndIf

    If Select(cAliasQry) > 0
        (cAliasQry)->(DbCloseArea())
    EndIf
	
Return lRet
