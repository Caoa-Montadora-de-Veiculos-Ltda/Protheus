#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} U_Jura095
Pontos de entrada da rotina JURA095 - Assuntos Jurídicos
Desenvolvedor: Plinio Filho
/*/
//-------------------------------------------------------------------
User Function Jura095()

	Local aParam	:= PARAMIXB
	Local oObjeto	:= Nil
	Local cIdPonto	:= ""
    Local cIdModel	:= ""
    Local nOpc		:= 0
	Local xRet		:= .T.


    If aParam <> Nil

		oObjeto  := aParam[1]	//Objeto do formulário ou do modelo, conforme o caso 
		cIdPonto := aParam[2]	//ID do local de execução do ponto de entrada
    	cIdModel := aParam[3]	//ID do formulário
    	nOpc 	 := oObjeto:GetOperation()
    	
    	Do Case			
    		Case cIdPonto == "MODELVLDACTIVE"	//Chamada na ativação do modelo			
    		Case cIdPonto == "MODELPRE"			//Chamada antes da alteração de qualquer campo do modelo			
    		Case cIdPonto == "MODELPOS"			//Chamada na validação total do modelo	
    		Case cIdPonto == "FORMPRE"			//Chamada antes da alteração de qualquer campo do formulário			
    		Case cIdPonto == "FORMPOS"			//Chamada na validação total do formulário
				If cIdModel == "NSZMASTER" 
					//Verifica se é Contrato
					If M->NSZ_TIPOAS == '006' 	
						//Validação da Data término de vigência
						If Empty(M->NSZ_XPRAZO) .And. M->NSZ_RENOVA == "1" .And. (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE)
							FWAlertError("Contrato com renovação automática sem prazo em meses definido", "Prazo da Renovação")
							xRet := .F.
						EndIf
						
					EndIf
				ENDIF	

    		Case cIdPonto == "FORMLINEPRE"		//Chamada na pré validação da linha do formulário			
    		Case cIdPonto == "FORMLINEPOS"		//Chamada na validação da linha do formulário		
    		Case cIdPonto == "MODELCOMMITTTS"	//Chamada após a gravação total do modelo e dentro da transação			
    		Case cIdPonto == "MODELCOMMITNTTS" 	//Após a gravação total do modelo e fora da transação.
    		Case cIdPonto == "FORMCOMMITTTSPRE"	//Chamada antes da gravação da tabela do formulário			
    		Case cIdPonto == "FORMCOMMITTTSPOS"	//Chamada após a gravação da tabela do formulário			
    		Case cIdPonto == "MODELCANCEL"		//Cancelamento			
    		Case cIdPonto == "BUTTONBAR"		//Adicionar botao
			
    	End Case

    EndIf

Return xRet
