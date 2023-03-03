#INCLUDE "TOTVS.CH"

// Classe Filha, herda a classe pai 
CLASS ZWMSF010 FROM WMSBCCRegraConvocacao
    METHOD NEW() CONSTRUCTOR
    METHOD zLawExec()
ENDCLASS

// Construtor da filha chama construtor da classe pai
METHOD NEW() CLASS ZWMSF010
    _Super:New()
Return self

METHOD zLawExec() CLASS ZWMSF010
Local lOk       := .F.
Local aAreaD12  := D12->(GetArea())
Local cPriori   := StrZero(0,2) // Inicia neste ponto
Local n1Cnt     := 0
Local lWmsRegSt := ExistBlock('WMSREGST')
Local cRetPE    := ""

	If !Empty(Self:aLibD12)
		// Carrega na temporária os registros da D12 que estão no array
		Self:ArrayToDB()
		// Refaz regra de sequencia caso execucao de servico anterior interrompido.
		Self:LawRefSeq()
		// Somente ordena o array de movimentoS, após todos os movimentos terem sido adicionados ao mesmo.
		// Pois podem ter serviços diferentes no meio do array e se adicionar os documento só no final
		// gera erro no momento de sequenciar o mesmo documento, pois fica na ordem errada no array
		aSort(Self:aLibD12,,, {|x,y| x[3]+x[4]+Str(x[2])<+y[3]+y[4]+Str(y[2])})
		// Executa regras para convocacao do servico
		Self:aLibRegra := {}
		For n1Cnt := 1 To Len(Self:aLibD12)
			//Valida regra por armazem e servico
			//Inicializa os controles
			Self:SetArmazem(Self:aLibD12[n1Cnt,3])
			Self:SetServico(Self:aLibD12[n1Cnt,4])

			AAdd(Self:aLibRegra,Self:aLibD12[n1Cnt])
			If n1Cnt == Len(Self:aLibD12) .OR. Self:aLibD12[n1Cnt+1,3]+Self:aLibD12[n1Cnt+1,4] <> Self:cArmazem+Self:cServico
				lOk := .T.
			EndIf
			If lOk
				// Passa por referência, pois não deve reiniciar quando muda a ordenação de Armazém+Serviço
				// Pois isso fazia com que quando um mesmo documento fosse separado em armazéns diferentes
				// com os mesmos endereços a convocação ficasse alteranando entre os armazéns
				Self:LawSequen(@cPriori)
				If !(Empty(Self:aLibRegra))
					Self:LawGeraSeq(@cPriori)
				EndIf
				lOk := .F.
				Self:aLibRegra := {}
			EndIf
		Next
		// Ordena liberação conforme prioridade
		aSort(Self:aLibD12,,, {|x,y| Iif(Len(x)>4 .And. Len(y)>4,x[5]+Str(x[2])<y[5]+Str(y[2]),.T.)})
		// Disponibiliza registros do D12 para convocacao
		For n1Cnt := 1 To Len(Self:aLibD12)
			D12->(dbGoTo(Self:aLibD12[n1Cnt,2]))
			If D12->(!Eof())
				If lWmsRegSt
					cRetPE := ExecBlock('WMSREGST',.F.,.F.,{Self:aLibD12[n1Cnt,1]})
					If ValType(cRetPE) == "C"
						Self:aLibD12[n1Cnt,1] := cRetPE
					EndIf
				EndIf
				RecLock('D12',.F.)
				D12->D12_STATUS := Self:aLibD12[n1Cnt,1]
				D12->(MsUnlock())
			EndIf
		Next
		// Refaz regra de limite (DCQ_DOCEXC)
		// caso execucao de servico anterior interrompido.
		Self:LawRefDoc()
	EndIf
	RestArea(aAreaD12)
Return
