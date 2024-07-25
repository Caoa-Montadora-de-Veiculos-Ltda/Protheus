/* =====================================================================================
Programa.: MA103OPC
Autor....: CAOA - Valter Carvalho
Data.....: 15/11/2021
Descricao / Objetivo: Cria um menu na tela de dpcumento de entrada para classificar notas fiscais filhas.
Doc. Origem:
Solicitante: CAOA - Montadora - Anápolis
Uso......:
=====================================================================================
 */
User Function MA103OPC()

     Local _aRes := {}

     If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
          _aRes        :={{"Caoa - Classf/desbloquer NF EIC" , "U_ZEICF018( 'MAE' )" , 0 , 3}}
     ElseIf ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
          _aRes       :={{"Caoa - Classf/desbloquer NF EIC" , "U_ZEICF018( 'MAE' )" , 0 , 3},;
                         {"Caoa - Integrar NFiscal RgLog"   , "U_ZWSR010(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA, .T.)", 0, 3 },;
                         {"Caoa - Verif.Integração RgLog"   , "U_ZCOMF047(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_TIPO,SF1->F1_FORNECE,SF1->F1_LOJA,.T.)", 0, 3 } }
     EndIf

Return(_aRes)
