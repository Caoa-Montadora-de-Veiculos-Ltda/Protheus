/*/{Protheus.doc} CRMA980
Ponto de Entrada referente a filtro do Browse de Clientes SA1
@author CAOA
@since 
@version 2.0
@project	GRUPO CAOA GAP FIN108 - Revitaliza��o Credito [ Montadora ]
@history    DAC Denilso - 28/02/2023 
            GRUPO CAOA - GAP FIN100 - Campo Matriz Clientes (Revitaliza��o Limite de Cr�dito)
            Revitali��o processo limite de cr�dito
@Obs        DAC Denilso - 28/02/2023
            Este PE esta sendo aproveitado para fazer valida��o do limite de cr�dito de todos os clientes
            antes de abrir o browse retornando vazio n�o far� nenhum filtro, caso exista a neessidade de implementa��o
            filtro somente adicionar e ajustar retorno (_cRet)
/*/

#Include "Totvs.CH"

User Function CRM980BFIL()
Local _cRet := ""
//N�o executar executar somente um a um DAC 10/05/2023
//FwMsgRun(,{ || U_ZFATF014() }, 'Limite Cr�dito','Atualizando Limite de Cr�dito Caoa, aguarde...')  //Separa��o Or�amentos / Aguarde
Return _cRet




