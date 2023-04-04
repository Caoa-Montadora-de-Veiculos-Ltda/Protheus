/*/{Protheus.doc} CRMA980
Ponto de Entrada referente a filtro do Browse de Clientes SA1
@author CAOA
@since 
@version 2.0
@project
@history    DAC Denilso - 28/02/2023 
            GRUPO CAOA - GAP FIN100 - Campo Matriz Clientes (Revitalização Limite de Crédito)
            Revitalição processo limite de crédito
@Obs        DAC Denilso - 28/02/2023
            Este PE esta sendo aproveitado para fazer validação do limite de crédito de todos os clientes
            antes de abrir o browse retornando vazio não fará nenhum filtro, caso exista a neessidade de implementação
            filtro somente adicionar e ajustar retorno (_cRet)
/*/

#Include "Totvs.CH"

User Function CRM980BFIL()
Local _cRet := ""
MsgRun("Atualizando Limite de Crédito Caoa","Aguarde...",{|| U_ZFATF014() })
Return _cRet
