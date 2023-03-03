#INCLUDE "TOTVS.CH"

User Function M410LIOK()

	Local lRet		:= .T.
	Local cVeiTes	:= SuperGetMv('CMV_VEITS1',.F.,"703/699/")
	Local cVeiLoc	:= "VEICULO NOVO"
	
	cVeiLoc	:= Stuff( Space(TamSX3("D3_LOCALIZ")[1]) ,1 , Len(cVeiLoc) , cVeiLoc )
	
	//MsgStop(cModulo)

	If !IsBlind()
		If cModulo == "VEI"
			If !GDFieldGet("C6_TES") $ cVeiTes 
				Help("",1,"VEITES",,"TES "+GDFieldGet("C6_TES")+" não pode ser utilizada no módulo Veículos.",1,0)
				lRet	:= .F.
			ElseIf Empty(GDFieldGet("C6_CHASSI")) 
				Help("",1,"VEICHASSI",,"Obrigatório informar Número de Chassi!",1,0)
				lRet	:= .F.
			ElseIf Empty( GetAdvFVal("VV1","VV1_CHAINT",xFilial("VV1")+GDFieldGet("C6_CHASSI"),2,"" )) 
				Help("",1,"VEICHASSI",,"Chassi "+AllTrim(GDFieldGet("C6_CHASSI"))+" não localizado no Cadastro de Veículos (VV1)!",1,0)
				lRet	:= .F.
			//BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
			ElseIf Empty( GetAdvFVal("SBF","BF_QUANT",xFilial("SBF")+GDFieldGet("C6_LOCAL")+cVeiLoc+GDFieldGet("C6_PRODUTO")+Subs(GDFieldGet("C6_CHASSI"),1,TamSX3("BF_NUMSERI")[1]),1,"" )) 
				Help("",1,"VEICHASSI",,"Produto/Chassi "+AllTrim(GDFieldGet("C6_PRODUTO"))+"/"+AllTrim(GDFieldGet("C6_CHASSI"))+" sem saldo!",1,0)
				lRet	:= .F.
			EndIf
		EndIf
	EndIf
	
Return lRet
