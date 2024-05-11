#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

User Function GFEA044()
    Local aArea     := GetArea()
    Local aParam    := PARAMIXB
    Local oObj      := aParam[1]
    Local cIdPonto  := aParam[2]
    Local lRet      := .T.
    Local cId       := aParam[3]

    If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
        If FWIsInCallStack("OMSM011") //-- Chamada da rotina ZGFEF001 somente pela rotina de sincronização 
            
            /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
            |   Este PE não é utilizado tambem pela rotina de fatumento(MEUFATURA) porque os campos de peso |
            |   F2_XPESOC e F2_PBRUTO, são gravados somente após a integracao com o GFE.                    |
            +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */                   

            If ( aParam <> NIL )

                If cIdPonto == 'MODELCOMMITNTTS' //-- Apos a gravação total do modelo e fora da transacao

                    //--Filtra apenas por Barueri
                    IF !( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
                        Return lRet
                    EndIf

                    //--Efetua a gravação dos pesos bruto e cubado na tabela GW8 - GFE
                    U_ZGFEF001( GW1->GW1_NRDC, GW1->GW1_SERDC )

                EndIf

            EndIf

        EndIf
        If ( aParam <> NIL )
            If cIdPonto == 'MODELCOMMITTTS' .and. cId == 'GFEA044' .And. !(oObj:GetOperation() == MODEL_OPERATION_DELETE)
                IF ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
                    //Efetua a Gravação dos totais bruto na tabela GW8
                    U_ZGFEF006( GW1->GW1_NRDC, GW1->GW1_SERDC,GW1->GW1_CDTPDC )  
                EndIf
                
            EndIf
        Endif
    EndIf
    RestArea(aArea)

Return(lRet)
