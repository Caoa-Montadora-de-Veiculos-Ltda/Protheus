#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} U_Jura095
Pontos de entrada da rotina JURA095 - Assuntos Jur�dicos
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

		oObjeto  := aParam[1]	//Objeto do formul�rio ou do modelo, conforme o caso 
		cIdPonto := aParam[2]	//ID do local de execu��o do ponto de entrada
    	cIdModel := aParam[3]	//ID do formul�rio
    	nOpc 	 := oObjeto:GetOperation()
    	
    	Do Case			
    		Case cIdPonto == "MODELVLDACTIVE"	//Chamada na ativa��o do modelo			
    		Case cIdPonto == "MODELPRE"			//Chamada antes da altera��o de qualquer campo do modelo			
    		Case cIdPonto == "MODELPOS"			//Chamada na valida��o total do modelo	
    		Case cIdPonto == "FORMPRE"			//Chamada antes da altera��o de qualquer campo do formul�rio			
    		Case cIdPonto == "FORMPOS"			//Chamada na valida��o total do formul�rio
				If cIdModel == "NSZMASTER" 
					//Verifica se � Contrato
					If M->NSZ_TIPOAS == '006' 	
						//Valida��o da Data t�rmino de vig�ncia
						If Empty(M->NSZ_XPRAZO) .And. M->NSZ_RENOVA == "1" .And. (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE)
							FWAlertError("Contrato com renova��o autom�tica sem prazo em meses definido", "Prazo da Renova��o")
							xRet := .F.
						EndIf
						
					EndIf
				ENDIF	

    		Case cIdPonto == "FORMLINEPRE"		//Chamada na pr� valida��o da linha do formul�rio			
    		Case cIdPonto == "FORMLINEPOS"		//Chamada na valida��o da linha do formul�rio		
    		Case cIdPonto == "MODELCOMMITTTS"	//Chamada ap�s a grava��o total do modelo e dentro da transa��o			
    		Case cIdPonto == "MODELCOMMITNTTS" 	//Ap�s a grava��o total do modelo e fora da transa��o.
    		Case cIdPonto == "FORMCOMMITTTSPRE"	//Chamada antes da grava��o da tabela do formul�rio			
    		Case cIdPonto == "FORMCOMMITTTSPOS"	//Chamada ap�s a grava��o da tabela do formul�rio			
    		Case cIdPonto == "MODELCANCEL"		//Cancelamento			
    		Case cIdPonto == "BUTTONBAR"		//Adicionar botao
			
    	End Case

    EndIf

Return xRet
