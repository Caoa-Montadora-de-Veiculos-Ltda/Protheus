/* =====================================================================================
Programa.:              IDI154MNU
Autor....:              CAOA - Valter Carvalho
Data.....:              15/11/2021
Descricao / Objetivo:   Cria um menu na tela de REceb. importação.
Doc. Origem:            
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              
===================================================================================== */

//  User Function IDI154MNU()
User Function IDI154MNU()

	Local _cEmp	:= FWCodEmp()
	Local aArea    := GetArea()
	Local _aRes    := {}

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		_aRes := { {"Gerar NF filhas Container (CAOA)", "U_ZEICF015()", 0 , 3} }
	Else
		_aRes := zCaoaSp() //Executa o p.e. CaoaSp
	EndIf

	RestArea(aArea)

Return(_aRes)

    /*
==============================================================================================
Programa.:              zMontadora
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada Montadora
===============================================================================================
*/
Static Function zCaoaSp()

     Local cFilCaixa := SuperGetMV("CAOAEICCAI", .F., "2020012001")
     Local cMsg := "Container"
     Local aRes  := {}
     Local aSubMenu := {}

     if FWCodFil() $ cFilCaixa //Verifico se a Empresa esta no parametro
          cMsg := "Caixas"
          aadd(aSubMenu , {"Por Container", "U_ZEICF015(.F.)", 0 , 3})
          aadd(aSubMenu , {"Por Caixas"   , "U_ZEICF015(.T.)", 0 , 3})

          aRes  := { {"Gerar NF filhas Container/Caixas (CAOA)", aSubMenu, 0 , 9} }
     Else
          aRes  := { {"Gerar NF filhas Container (CAOA)",  "U_ZEICF015(.F.)", 0 , 3} }
     
     EndIf
     
Return(aRes)
