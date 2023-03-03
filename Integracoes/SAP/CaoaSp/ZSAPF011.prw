#include 'protheus.ch'
#include 'parmtype.ch'

/*
	Grava Contas a Receber para ser enviado ao SAP
	Chamado pelo PE SF2460I
	Chamado pelo PE MS520DEL
*/
user function ZSAPF011(nOpc)
	
	If nOpc == 3//inclusao
		xIncSZ7()
	Elseif nOpc == 4//Alteração
		xAltSZ7()
	Elseif nOpc == 6//Estorno
		xEstSZ7()
	EndIf	
	
return

Static Function xIncSZ7()
	
    Local aArea			:= GetArea()                                                                                   
	Local aAreaSF2		:= SF2->(GetArea())
	
	Local cChvSZ7		:= SF2->( F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO )//Chave para o While
			
			U_ZF11GENSAP(SF2->F2_FILIAL,; //Filial
					"SF2"			 ,;	//Tabela
					"1"				 ,;	//Indice Utilizado
					cChvSZ7			 ,;	//Chave
					1				 ,;	//Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					1)					//Operação SAP 1=Inclusao;2=cancelamento

	
	RestArea(aAreaSF2)
	RestArea(aArea)

return


Static Function xEstSZ7()

   Local aArea			:= GetArea()                                                                                   
	Local aAreaSF2		:= SF2->(GetArea())
	
	Local cChvSZ7		:= SF2->( F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO )//Chave para o While
	

			U_ZF11GENSAP(SF2->F2_FILIAL,; //Filial
					"SF2"			 ,;	//Tabela
					"1"				 ,;	//Indice Utilizado
					cChvSZ7			 ,;	//Chave
					3				 ,;	//Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					2)					//Operação SAP 1=Inclusao;2=cancelamento
			

	RestArea(aAreaSF2)
	RestArea(aArea)

Return
