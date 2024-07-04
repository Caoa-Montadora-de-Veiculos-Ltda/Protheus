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

	Local aArea    := GetArea()
	Local _aRes    := {}

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
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

     Local cMsg := "Container"
     Local aRes  := {}
     Local aSubMenu := {}

     If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
          cMsg := "Caixas"
          aadd(aSubMenu , {"Por Container", "U_ZEICF015(.F.)", 0 , 3})
          aadd(aSubMenu , {"Por Caixas"   , "U_ZEICF015(.T.)", 0 , 3})

          aRes  := { {"Gerar NF filhas Container/Caixas (CAOA)", aSubMenu, 0 , 9} }
     Else
          aRes  := { {"Gerar NF filhas Container (CAOA)",  "U_ZEICF015(.F.)", 0 , 3} }
     
     EndIf
     
Return(aRes)
