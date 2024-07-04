User Function ZPECF004()
Local  aArea        := GetArea()
Local  _cCLi        := ""
Local  _cLoja       := ""
Local  _cCodItem    := ""                        // Substr(M->VS3_CODITE,1,23)
//Local  _nValTab     := 0
//Local  _cCampo      := ""
//Local  _cAliasPesq	:= GetNextAlias()   
//Local  _cAtivo		:= '1'
Local  _nRet        := 0 //IF(INCLUI, M->VS3_VALPEC, VS3->VS3_VALPEC)

IF ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB

	IF (Upper(FunName()) <> "OFIOC520")
		
		IF !EMPTY(M->VS3_CODITE)

			_cCodItem := Substr(M->VS3_CODITE,1,23)
			
			IF INCLUI
				_cCLi  := M->VS1_CLIFAT
				_cLoja := M->VS1_LOJA
			ELSE
				_cCLi  := VS1->VS1_CLIFAT 
				_cLoja := VS1->VS1_LOJA
			ENDIF

			_nRet := U_XOFUNVTB(_cCLi, _cLoja, _cCodItem)

			/*Begin Sequence
			BeginSql Alias _cAliasPesq    //Define o nome do alias temporário 
				SELECT 	DA1.R_E_C_N_O_ AS NREGDA1,
						SA1.A1_EST
				FROM  %Table:DA1% DA1
				JOIN  %Table:SA1% SA1 
					ON	SA1.A1_FILIAL  	= %xFilial:SA1%
					AND SA1.A1_COD  	= %Exp:_cCLi%
					AND SA1.A1_LOJA 	= %Exp:_cLoja%
					AND SA1.%notDel%
				JOIN %Table:DA0% DA0 
					ON	DA0.DA0_FILIAL  = %xFilial:DA0%
					AND DA0.DA0_ATIVO	= %Exp:_cAtivo%
					AND DA0.%notDel%
				WHERE 	DA1.DA1_FILIAL  = %xFilial:DA1% 
					AND DA1.DA1_CODTAB  = DA0.DA0_CODTAB
					AND DA1.DA1_CODPRO 	= %Exp:_cCodItem%
					AND DA1.%notDel%
				EndSQL

				If (_cAliasPesq)->(!Eof()) .and. (_cAliasPesq)->NREGDA1 > 0
					DA1->(DbGoto((_cAliasPesq)->NREGDA1))
					_cCampo  := "DA1_X"+(_cAliasPesq)->A1_EST
					_nValTab := DA1->(FieldGet(FieldPos(_cCampo)))
				//else
					//IF _nValTab = 00.0000  
					//	MSGINFO( Alltrim(M->VS3_CODITE) + " Sem tabela de preços por estado vigente e ativa.", "[ZPECF004] - Atenção" )
					//ENDIF
				EndIf

			End Sequence*/

		ELSE
			_cCodItem := Space(23)
		ENDIF
		
		//If Select((_cAliasPesq)) <> 0
		//	(_cAliasPesq)->(DbCloseArea())
		//	Ferase(_cAliasPesq+GetDBExtension())
		//Endif

		RestArea(aArea)

	ENDIF

ENDIF

Return(_nRet)
