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

     Local _cEmp := FWCodEmp()
     Local _aRes := {}

     If _cEmp == "2010" //Executa o p.e. somente para Anapolis.
          _aRes        :={{"Caoa - Classf/desbloquer NF EIC" , "U_ZEICF018( 'MAE' )" , 0 , 3}}
     ElseIf _cEmp == "2020"
          _aRes       :={{"Caoa - Classf/desbloquer NF EIC" , "U_ZEICF018( 'MAE' )" , 0 , 3},;
                         {"Caoa - Integrar NFiscal RgLog"   , "U_ZWSR010(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA, .T.)", 0, 3 },;
                         {"Caoa - Verif.Integração RgLog"   , "U_ZCOMF047(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_TIPO,SF1->F1_FORNECE,SF1->F1_LOJA,.T.)", 0, 3 } }
     EndIf

Return(_aRes)
