#include "protheus.ch"
#include "parmtype.ch"

/*
=====================================================================================
Programa............: PE_MATA010
Autor...............: Marcelo Carneiro
Data................: 18/06/2019
Descricao / Objetivo: Ponto de entrada MVC para o cadastro de Produto
Doc. Origem.........: Integraï¿½ï¿½o SILT para marcar o campo como Integra.
Solicitante.........: Cliente
Uso.................: CAOA
Obs.................: 
=====================================================================================
*/
User Function ITEM()

   Local _cEmp    := FWCodEmp()
   Local _lRet	  := .T.
   Local aArea	  := GetArea()

   If _cEmp == "2010" //Executa o p.e. Anapolis.
      _lRet := zMontadora()
   Else
      _lRet := zCaoaSp() //Executa o p.e. CaoaSp
   EndIf

   RestArea(aArea)

Return(_lRet)

/*
==============================================================================================
Programa.:              zMontadora
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada Montadora
===============================================================================================
*/
Static Function zMontadora()

Local aParam 	:= PARAMIXB
Local xRet   	:= .T.
Local oObj   	:= ""
Local cIdPonto 	:= ""
Local cIdModel 	:= ""
Local cFilSilt 	:= Alltrim(SuperGetMV("CAOA_ST006",.T.,"2010072005"))
Local _cEmp  	:= FWCodEmp()
Local _cFilial	:= FWFilial()
Local cCodProd 	:= ""
 
If aParam <> NIL

    oObj     := aParam[1]
    cIdPonto := aParam[2]
    cIdModel := aParam[3]
    nOpcx := oObj:GetOperation()

	If cIdPonto == 'FORMCOMMITTTSPOS'
	
		IF _cEmp = '2020' .AND. _cFilial = '2001' .AND. Substr(M->B1_COD,1,1) = "R" //somente Peças Barueri
	
			If nOpcx == 3  .or.  nOpcx == 4  .or.  nOpcx == 5  //Inclusão ou Alteração ou Excluir
        		cCodProd := M->B1_COD
		        U_WSR004(cCodProd)
			EndIf
	
		Else
	
			If nOpcx == 3 .OR. nOpcx == 4
	
	        	If Alltrim(SB1->B1_FILIAL) == SubStr(cFilSilt,1,Len(Alltrim(SB1->B1_FILIAL)))
					RecLock("SB1", .F.)
					//SB1->B1_XSILST  := 'N'
					SB1->(MsUnlock())
				EndIF

	    	EndIf
			
		EndIf

	EndIF

	/*
	   CAOA GAP FIS106
	*/
	If cIdPonto == 'FORMCOMMITTTSPRE'

		IF _cEmp = '2010'
		
			If FindFunction("U_ZCOMF021") .And. FunName() <> "EICA130"
    			U_ZCOMF021(oObj) // ataliza campos na SB1
        	Endif

		EndIf

	EndIf

EndIf

Return xRet 

/*
==============================================================================================
Programa.:              zCaoaSp
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada CaoaSp
===============================================================================================
*/
Static Function zCaoaSp()

Local aParam 	:= PARAMIXB
Local xRet   	:= .T.
Local oObj   	:= ""
Local cIdPonto 	:= ""
Local cIdModel 	:= ""
//Local cFilSilt 	:= Alltrim(SuperGetMV("CAOA_ST006",.T.,"2010072005"))
Local _cEmp  	:= FWCodEmp()
Local _cFilial	:= FWFilial()
Local cCodProd 	:= ""
Local _lVisual	:= .T.
Local cTipo     := "" 
Local cCampo    := ""
Local xConteudo := nil
Local cFornece  := ""
Local cLojaFor  := ""
Local oModel    := nil
Local oModelSB5 := nil
Local cMarPec	:= ""
Local cDescMarc := ""

If aParam <> NIL

    oObj     := aParam[1]
    cIdPonto := aParam[2]
    cIdModel := aParam[3]
	
	if len(aParam) == 6
	
		cTipo     := aParam[4]
		cCampo    := aParam[5]
		xConteudo := aParam[6]
		
		oModel    := FWModelActive()
		oModelSB5 := oModel:GetModel("SB5DETAIL")
		
	Endif
    
	nOpcx := oObj:GetOperation()

	If cIdPonto == 'FORMCOMMITTTSPOS' 
	
		IF _cEmp = '2020' .AND. _cFilial = '2001' .AND. Substr(M->B1_COD,1,1) = "R" .AND. !FWIsInCallStack("U_ZPECF023")//somente Peças Barueri
	
			If nOpcx == 3  .or.  nOpcx == 4  .or.  nOpcx == 5  //Inclusão ou Alteração ou Excluir
        		cCodProd := M->B1_COD
				RecLock("SB1", .F.)
					SB1->B1_XDTULT := Date()
				SB1->(MsUnlock())
		        U_ZWSR004(cCodProd)
			EndIf

		EndIf

	ElseIf cIdPonto == 'FORMCOMMITTTSPRE'

		IF _cEmp = '2010'
		
			If FindFunction("U_ZCOMF021") .And. FunName() <> "EICA130"
    			U_ZCOMF021(oObj) // ataliza campos na SB1
        	Endif

		EndIf

	ElseIf cIdPonto == "BUTTONBAR"

            //Criar um botão na barra de botões da rotina
			xRet := {{"Caoa-Integrar RgLog", "Caoa-Integrar RgLog", {||U_ZWSR004(M->B1_COD,_lVisual)}}}
	
	ElseIf cIdPonto =="FORMPRE" 
		if cTipo == 'SETVALUE'
		
			if  cCampo == 'B1_LOJPROC'
				
				cFornece := oObj:GetModel(cIdPonto):GetValue('SB1MASTER','B1_PROC'   )
				//cLojaFor := oObj:GetModel(cIdPonto):GetValue('SB1MASTER','B1_LOJPROC')
				cLojaFor := xConteudo	
				if !empty(cFornece) .and. !Empty(cLojaFor) .AND. !IsInCallStack("U_ZPECF023")
				
					If ApMsgYesNo( "Deseja atualizar a marca do produto?","[ MATA010_PE ] - Confirma a operação?" )
								
						VQS->(DbSetOrder(4))
					
						If VQS->(DbSeek(xFilial("VQS") + cFornece + cLojaFor ))
							cMarPec  := VQS->VQS_MARPEC
							cDescMarc:= VQS->VQS_DESCRI
							VQS->(DbSetOrder(1))
							if !oModelSB5:GetModel(cIdPonto):SetValue("SB5DETAIL","B5_MARPEC", cMarPec )
								ApMsgStop("Registro não encontrado na tabela de Marca de Pecas.","MATA010_PE")
							else
								oModelSB5:GetModel(cIdPonto):SetValue("SB5DETAIL","B5_XDESCMA", cDescMarc )
							EndIf
						else
							ApMsgStop("Registro não encontrado na tabela de Marca de Pecas.","MATA010_PE")
						EndIf
					EndIf
				EndIf
			Elseif  cCampo == 'B5_MARPEC'
				VQS->(DbSetOrder(1))
				
				If VQS->(DbSeek(xFilial("VQS") + xConteudo ))
				
					if empty(xConteudo)
						cDescMarc:= Space(len(VQS->VQS_DESCRI))
					Else
						cDescMarc:= VQS->VQS_DESCRI
					endif
				
				else
						cDescMarc:= Space(len(VQS->VQS_DESCRI))
				EndIf
				
				oModelSB5:GetModel(cIdPonto):SetValue("SB5DETAIL","B5_XDESCMA", cDescMarc )
				
			EndIf
		Endif
	EndIf

EndIf

Return xRet 

/*
aParam[1] == Object
aParam[2] == 'FORMPRE'
aParam[3] == 'SB1MASTER'
aParam[4] == 'SETVALUE'
aParam[5] == 'B1_PROC'
aParam[6] == '000001'

aParam[1] == Object
aParam[2] == 'FORMPRE'
aParam[3] == 'SB5DETAIL'
aParam[4] == 'SETVALUE'
aParam[5] == 'B5_MARPEC'
aParam[6] == '000001'


*/

