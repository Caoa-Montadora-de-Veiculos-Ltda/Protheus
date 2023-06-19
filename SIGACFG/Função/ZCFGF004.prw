#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwbrowse.ch"
#include 'fwmvcdef.ch'


/*
=====================================================================================
Programa.:              ZCFGF004
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              22/06/2020
Descricao / Objetivo:   Atualiza Parametros das Bases de Teste.
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
User function ZCFGF004()

Local aPergs    := {}
Local lUserAut  := .F.
Private aRetP   := {}

			//  U_ZGENUSER( <ID User> , <"NOME DA FUNÇÃO"> , <.F.=Não Exibe Msg; .T.=Exibe Msg> )
lUserAut := U_ZGENUSER( RetCodUsr() ,"ZCFGF004"	,.T.)

If lUserAut
    If !( "_PRD" $ AllTrim(GetEnvServer()) .OR. AllTrim(GetEnvServer()) == "PRIME" )

        aAdd(aPergs,    {2, "Limpa Tabelas"                , "SIM"      , {"SIM", "NÃO"}    ,     050, ".T.", .F.})
        aAdd(aPergs,    {2, "Altera Parametro (SX6)"       , "SIM"      , {"SIM", "NÃO"}    ,     050, ".T.", .F.})
        aAdd(aPergs,    {2, "Altera SOD - MES"             , "SIM"      , {"SIM", "NÃO"}    ,     050, ".T.", .F.})
        aAdd(aPergs,    {2, "Altera CKP - Colab Saida"     , "SIM"      , {"SIM", "NÃO"}    ,     050, ".T.", .F.})
        aAdd(aPergs,    {2, "Altera User Admin APSDU"      , "SIM"      , {"SIM", "NÃO"}    ,     050, ".T.", .F.})
        aAdd(aPergs,    {2, "Update SA1|SA2|SA4-Email "     , "SIM"     , {"SIM", "NÃO"}    ,     050, ".T.", .F.})

        If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 
        
            If aRetP[1] == "SIM"
                Processa({|| ZZapTable() }, "[ZCFGF004] - Deletando", "Aguarde .... Apagando os registros...." )
            Endif

            If aRetP[2] == "SIM"
                Processa({|| ZAltSX6() }, "[ZCFGF004] - Alterando", "Aguarde .... Alterando os parâmetros...." )
            EndIf

            If aRetP[3] == "SIM"
                Processa({|| ZAltSOD() }, "[ZCFGF004] - Alterando", "Aguarde .... Alterando os parâmetros do MES...." )
            EndIf

            If aRetP[4] == "SIM"
                Processa({|| ZAltCKP() }, "[ZCFGF004] - Alterando", "Aguarde .... Alterando os parâmetros do Colab Saída...." )
            EndIf

            If aRetP[5] == "SIM"
                Processa({|| ZAltUsr() }, "[ZCFGF004] - Alterando", "Aguarde .... Alterando os direitos de Apsdu dos users Admin...." )
            EndIf

              If aRetP[6] == "SIM"
                Processa({|| ZUpdTable() }, "[ZCFGF004] - Alterando", "Aguarde .... Realizando Update no SA1|SA2|SA4 - Apagando Email...." )
            EndIf

            ApMsgInfo( "Processo finalizado com Sucesso" , "[ ZCFGF004 ] - Finalizado" )

        EndIf 

    Else
            
        ApMsgInfo( "Essa rotina não pode ser executada em ambiente de Produção." , "[ ZCFGF004 ] - Finalizado" )

    EndIf
EndIf

Return()

/*
=====================================================================================
Programa.:              ZZapTable()
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              02/08/19
Descricao / Objetivo:   Apaga as Tabelas de Schedule
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static function ZZapTable()

Local aTabelas  := {}
Local _cDelete  := " "
Local nAtual    := 0

//Adiciona as tabelas que irão sofrer o pack
aAdd(aTabelas, "CKOCOL")
aAdd(aTabelas, "SCHDTSK")
aAdd(aTabelas, "XX0")
aAdd(aTabelas, "XX1")
aAdd(aTabelas, "XX2")

ProcRegua(Len(aTabelas))

//Percorre as tabelas
For nAtual := 1 To Len(aTabelas)
 
    IncProc("Excluindo Tabela : " + AllTrim( aTabelas[nAtual] ) )

    _cDelete := " "
    _cDelete := " DELETE FROM "+ AllTrim( aTabelas[nAtual] ) +" "
    TcSqlExec(_cDelete)

Next

Return()

/*
=====================================================================================
Programa.:              ZAltSX6()
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              02/08/19
Descricao / Objetivo:   Apaga as Tabelas de Schedule
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static function ZAltSX6()

Local aSX6      := {}
Local nAtual    := 0

// CAMPOS COM A OPÇÃO .F., NÃO REALIZA A ALTERAÇÃO NO AMBIENTE

        // Paramentros        , TIPO  , Alt HML , Conteudo HML                  , Alt TST   , Conteudo TST                  , Alt DES   , Conteudo DES
aAdd(aSX6, { "MV_AMBCTEC"     , "N"   ,  .T.    , 2                             , .T.       , 2                             , .T.       , 2                                 } )
aAdd(aSX6, { "MV_AMBICOL"     , "N"   ,  .T.    , 2                             , .T.       , 2                             , .T.       , 2                                 } )
aAdd(aSX6, { "MV_NGINN"       , "C"   ,  .T.    , " "                           , .T.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_NGOUT"       , "C"   ,  .T.    , " "                           , .T.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_NGLIDOS"     , "C"   ,  .T.    , " "                           , .T.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_COMCOL1"     , "N"   ,  .T.    , 0                             , .T.       , 0                             , .F.       , " "                               } )
aAdd(aSX6, { "MV_COMCOL2"     , "C"   ,  .T.    , " "                           , .T.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_COMCOLD"     , "N"   ,  .T.    , " "                           , .T.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_CONFALL"     , "C"   ,  .F.    , " "                           , .F.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_DOCSCOL"     , "C"   ,  .T.    , "4"                           , .T.       , "4"                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_EMCONTA"     , "C"   ,  .T.    , "caoa_totvs_tst@caoa.com.br"  , .T.       , "caoa_totvs_tst@caoa.com.br"  , .T.       , "caoa_totvs_tst@caoa.com.br"      } )
aAdd(aSX6, { "MV_EMSENHA"     , "C"   ,  .T.    , "T0tvsC@0A*!"                 , .T.       , "T0tvsC@0A*!"                 , .T.       , "T0tvsC@0A*!"                     } )
aAdd(aSX6, { "MV_NRETCOL"     , "N"   ,  .T.    , 0                             , .T.       , 0                             , .T.       , 10                                } )
aAdd(aSX6, { "MV_PASSCOL"     , "C"   ,  .T.    , " "                           , .T.       , " "                           , .T.       , " "                               } )
aAdd(aSX6, { "MV_PASSCOL"     , "N"   ,  .T.    , " "                           , .T.       , " "                           , .T.       , " "                               } )
aAdd(aSX6, { "MV_PCNFE"       , "L"   ,  .F.    , " "                           , .F.       , " "                           , .F.       , " "                               } ) 
aAdd(aSX6, { "MV_RELSERV"     , "C"   ,  .F.    , " "                           , .F.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_RESTNFE"     , "C"   ,  .F.    , " "                           , .F.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_SPEDCOL"     , "C"   ,  .T.    , "N"                           , .T.       , "N"                           , .T.       , "S"                               } )
aAdd(aSX6, { "MV_SPEDURL"     , "C"   ,  .T.    , " "                           , .T.       , " "                           , .T.       , "172.28.35.143:34381/tss_tst"     } )
aAdd(aSX6, { "MV_TESPCNF"     , "C"   ,  .F.    , " "                           , .F.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_USERCOL"     , "C"   ,  .T.    , " "                           , .T.       , " "                           , .T.       , " "                               } )
aAdd(aSX6, { "MV_XMLCFBN"     , "C"   ,  .F.    , " "                           , .F.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_XMLCFDV"     , "C"   ,  .F.    , " "                           , .F.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_XMLCPCT"     , "C"   ,  .F.    , " "                           , .F.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_XMLPFCT"     , "C"   ,  .F.    , " "                           , .F.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_XMLTECT"     , "C"   ,  .F.    , " "                           , .F.       , " "                           , .F.       , " "                               } )
aAdd(aSX6, { "MV_TCNEW"       , "C"   ,  .T.    , " "                           , .T.       , " "                           , .F.       , " "                               } )  
aAdd(aSX6, { "MV_RELACNT"     , "C"   ,  .T.    , "caoa_totvs_tst@caoa.com.br"  , .T.       , "caoa_totvs_tst@caoa.com.br"  , .T.       , "caoa_totvs_tst@caoa.com.br"      } )
aAdd(aSX6, { "MV_RELAUSR"     , "C"   ,  .T.    , "caoa_totvs_tst@caoa.com.br"  , .T.       , "caoa_totvs_tst@caoa.com.br"  , .T.       , "caoa_totvs_tst@caoa.com.br"      } )
aAdd(aSX6, { "MV_RELFROM"     , "C"   ,  .T.    , "caoa_totvs_tst@caoa.com.br"  , .T.       , "caoa_totvs_tst@caoa.com.br"  , .T.       , "caoa_totvs_tst@caoa.com.br"      } )
aAdd(aSX6, { "MV_RELPSW"      , "C"   ,  .T.    , "T0tvsC@0A*!"                 , .T.       , "T0tvsC@0A*!"                 , .T.       , "T0tvsC@0A*!"                     } )

// INTEGRAÇÃO SAMPLE MANAGER
aAdd(aSX6, { "CMV_WMS007"     , "C"   ,  .T.    , "http://172.16.33.168:56105/webitf"                           ,  .T.      , "http://172.16.33.168:56105/webitf"                           ,  .T.      , "http://172.16.33.168:56105/webitf"          } )

//PARAMETROS SAP
        // Paramentros      , TIPO  , HML                       ,   TST                     ,    DES
aAdd(aSX6, { "CAOASAP01A"     , "C"   ,  .T.    , "http://10.120.40.141:53400/dir/wsdl?p=ic/9f324344323d391792946bbd98bd4139"                           ,  .T.      , "http://10.120.40.141:53400/dir/wsdl?p=ic/9f324344323d391792946bbd98bd4139"                           ,  .T.      , "http://10.120.40.141:53400/dir/wsdl?p=ic/9f324344323d391792946bbd98bd4139"  } )
aAdd(aSX6, { "CAOASAP02A"     , "C"   ,  .T.    , "http://10.120.40.141:53400/dir/wsdl?p=ic/97d120e0442d33278268b0eccac3643c"                           ,  .T.      , "http://10.120.40.141:53400/dir/wsdl?p=ic/97d120e0442d33278268b0eccac3643c"                           ,  .T.      , "http://10.120.40.141:53400/dir/wsdl?p=ic/97d120e0442d33278268b0eccac3643c"  } )
aAdd(aSX6, { "CAOASAP03A"     , "C"   ,  .T.    , "http://10.120.40.141:53400/dir/wsdl?p=ic/7e57f79630be3849a4ebcfa108259ed4"                           ,  .T.      , "http://10.120.40.141:53400/dir/wsdl?p=ic/7e57f79630be3849a4ebcfa108259ed4"                           ,  .T.      , "http://10.120.40.141:53400/dir/wsdl?p=ic/7e57f79630be3849a4ebcfa108259ed4"  } )
aAdd(aSX6, { "CAOASAP03D"     , "C"   ,  .T.    , "http://10.120.40.141:53400/dir/wsdl?p=ic/913e3fad55e73c668da03847cc77174a"                           ,  .T.      , "http://10.120.40.141:53400/dir/wsdl?p=ic/913e3fad55e73c668da03847cc77174a"                           ,  .T.      , "http://10.120.40.141:53400/dir/wsdl?p=ic/913e3fad55e73c668da03847cc77174a"  } )
aAdd(aSX6, { "CAOASAP08A"     , "C"   ,  .T.    , "http://10.120.40.141:53400/dir/wsdl?p=ic/7cd73db8a3283b5cbbbf1fe55d2f205c"                           ,  .T.      , "http://10.120.40.141:53400/dir/wsdl?p=ic/7cd73db8a3283b5cbbbf1fe55d2f205c"                           ,  .T.      , "http://10.120.40.141:53400/dir/wsdl?p=ic/7cd73db8a3283b5cbbbf1fe55d2f205c"  } )
aAdd(aSX6, { "CAOASAP12A"     , "C"   ,  .T.    , "http://10.120.40.141:53400/dir/wsdl?p=ic/67105a33fc843b8b843c892dae69f375"                           ,  .T.      , "http://10.120.40.141:53400/dir/wsdl?p=ic/67105a33fc843b8b843c892dae69f375"                           ,  .T.      , "http://10.120.40.141:53400/dir/wsdl?p=ic/67105a33fc843b8b843c892dae69f375"  } )
aAdd(aSX6, { "CAOASAP251"     , "C"   ,  .F.    , " "                                                                                                   ,  .F.      , " "                                                                                                   ,  .F.      , " "                                                                          } )

//PARAMETROS AUTOWARE
        // Paramentros      , TIPO  , HML                       ,   TST                     ,    DES
aAdd(aSX6, { "CAOA_WS001"     , "C"   ,  .T.    , "http://10.120.41.106/servicos/v2/chassi.asmx?WSDL"                                  ,  .T.      , "http://10.120.41.106/servicos/v2/chassi.asmx?WSDL"                                  ,  .T.      , "http://10.120.41.106/servicos/v2/chassi.asmx?WSDL"          } )
aAdd(aSX6, { "CAOA_WS003"     , "C"   ,  .T.    , "http://10.120.41.106/Servicos/v2/PedidoVeiculo.asmx?WSDL"                           ,  .T.      , "http://10.120.41.106/Servicos/v2/PedidoVeiculo.asmx?WSDL"                           ,  .T.      , "http://10.120.41.106/Servicos/v2/PedidoVeiculo.asmx?WSDL"   } )
aAdd(aSX6, { "CAOA_WS004"     , "C"   ,  .T.    , "http://10.120.41.106/Servicos/v2/NotaFiscal.asmx?WSDL"                              ,  .T.      , "http://10.120.41.106/Servicos/v2/NotaFiscal.asmx?WSDL"                              ,  .T.      , "http://10.120.41.106/Servicos/v2/NotaFiscal.asmx?WSDL"      } )


//PARAMETROS FLUIG
        // Paramentros        , TIPO  , Alt HML , Conteudo HML                  , Alt TST   , Conteudo TST                          , Alt DES  , Conteudo DES
aAdd(aSX6, { "ES_XFLUIG1"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "admin"            } )
aAdd(aSX6, { "ES_XFLUIG2"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "Caoat99#ch"       } )
aAdd(aSX6, { "ES_XFLUIG3"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "admin"            } )
aAdd(aSX6, { "ES_XFLUIG4"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "1"                } )
aAdd(aSX6, { "ES_XFLUIG5"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "https://caoatst.fluig.cloudtotvs.com.br/webdesk/ECMWorkflowEngineService?wsdl"                } )
aAdd(aSX6, { "MV_ECMURL"      , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "https://caoatst.fluig.cloudtotvs.com.br/webdesk"                                              } ) //parametro integ. juridico com Fluig


//PARAMETROS BARUERI
        // Paramentros        , TIPO  , Alt HML , Conteudo HML                  , Alt TST   , Conteudo TST                          , Alt DES  , Conteudo DES
aAdd(aSX6, { "CMV_PEC015"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "http://www.rgtracking.com.br"            } )
aAdd(aSX6, { "CMV_PEC016"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "/rglog/edi/MinhasColetasJson.php?formato=json&op=3736&filtro=coleta&dataI=25/05/2022&dataF=25/05/2022&aut=N&st=D"            } )
aAdd(aSX6, { "CMV_PEC021"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "/rglog/edi/MinhasColetasJson.php?formato=json&op=3736&filtro=chave&valor=35220510213051001399570010005184801005184809"            } )
aAdd(aSX6, { "CMV_PEC031"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "WIS.V_ENDERECO_ESTOQUE@DBLINK_WISHML"            } )
aAdd(aSX6, { "CMV_WSR001"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "wmsapi.rgtracking.com.br:8080/interfacewis/entrada/pedido/"            } )
aAdd(aSX6, { "CMV_WSR002"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "interfacewis/entrada/pedido"            } )
aAdd(aSX6, { "CMV_WSR007"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "wmsapi.rgtracking.com.br:8080/interfacewis/entrada/produto/"            } )
aAdd(aSX6, { "CMV_WSR008"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "interfacewis/entrada/fornecedor"            } )
aAdd(aSX6, { "CMV_WSR009"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "caoa.totvs"            } )
aAdd(aSX6, { "CMV_WSR010"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "CAgka2694X*"            } )
aAdd(aSX6, { "CMV_WSR011"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "wmsapi.rgtracking.com.br:8080/"            } )
aAdd(aSX6, { "CMV_WSR012"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "interfacewis/entrada/cliente"            } )
aAdd(aSX6, { "CMV_WSR013"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "jose.dearaujo@totvspartners.com.br"            } )
aAdd(aSX6, { "CMV_WSR016"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "caoa.totvs"            } )
aAdd(aSX6, { "CMV_WSR017"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "CAgka2694X*"            } )
aAdd(aSX6, { "CMV_WSR018"     , "C"   ,  .T.    , " "                           ,  .T.      , " "                                  ,  .T.      , "interfacewis/entrada/recebimento"            } )

aAdd(aSX6, { "MV_INTGFE"      , "L"   ,  .T.    , ".F."                         ,  .T.      , ".F."                                ,  .T.      , ".T."            } )

ProcRegua(Len(aSX6))

//Percorre as tabelas
For nAtual := 1 To Len(aSX6)

     If "_HOM" $ AllTrim(GetEnvServer())

        If aSX6[nAtual][03] == .T.
            //      PARAMETRO           ,   CONTEUDO        
            PutMv(aSX6[nAtual][01]  , aSX6[nAtual][04])
        EndIf

    ElseIf "_TST" $ AllTrim(GetEnvServer())

        If aSX6[nAtual][05] == .T. 
            //      PARAMETRO           ,   CONTEUDO        
            PutMv(aSX6[nAtual][01]  , aSX6[nAtual][06])
        EndIf

    ElseIf "_DES" $ AllTrim(GetEnvServer())

        If aSX6[nAtual][07] == .T.
            //      PARAMETRO           ,   CONTEUDO        
            PutMv(aSX6[nAtual][01]  , aSX6[nAtual][08])
        EndIf

    EndIf

Next

Return()

/*
=====================================================================================
Programa.:              ZAltSOD()
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              02/08/19
Descricao / Objetivo:   Atualiza tabelas do mes
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static function ZAltSOD()

Local aSOD      := {}
Local nAtual    := 0

//PARAMETRO TOTVS MES
        //  CAMPO       , FILIAL        , ATIVO/DESABILITADO    , URL
aAdd(aSOD, { "SOD"        , "2010022001"  , "1"                   , "http://10.120.41.103:4321/PcfIntegService?wsdl" } )

ProcRegua(Len(aSOD))

dbSelectArea("SOD")

//Percorre as tabelas
For nAtual := 1 To Len(aSOD)

    SOD->(dbSetOrder(1))
	If DbSeek( aSOD[nAtual][02] + aSOD[nAtual][03] + aSOD[nAtual][04] )
		If "_HOM" $ AllTrim(GetEnvServer())
            
            RecLock("SOD", .F.)
                SOD->OD_ATIVO   := "2"
		        SOD->OD_CAMINHO := "http://10.120.41.109:4321/PcfIntegService?wsdl "
		    SOD->(MsUnLock())

        ElseIf "_TST" $ AllTrim(GetEnvServer())

            RecLock("SOD", .F.)
                SOD->OD_ATIVO   := "2"
		        SOD->OD_CAMINHO := "http://10.120.41.109:4321/PcfIntegService?wsdl "
		    SOD->(MsUnLock())

        ElseIf "_DES" $ AllTrim(GetEnvServer())'

            RecLock("SOD", .F.)
                SOD->OD_ATIVO   := "2"
		        SOD->OD_CAMINHO := "http://10.120.41.109:4321/PcfIntegService?wsdl "
		    SOD->(MsUnLock())

        EndIf
	Endif

Next


Return()

/*
=====================================================================================
Programa.:              ZAltCKP()
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              02/08/19
Descricao / Objetivo:   Atualiza tabelas de transmissão da nota fiscal
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static Function ZAltCKP()

Local aCKP      := {}
Local nAtual    := 0

//PARAMETRO TOTVS MES
        //  CAMPO       , FILIAL        , PARAMETRO             , CONTEUDO
aAdd(aCKP, { "CKP"        , "2010022001"  , "MV_AMBIENT"          , "2" } )

ProcRegua(Len(aCKP))

dbSelectArea("CKP")

//Percorre as tabelas
For nAtual := 1 To Len(aCKP)

    CKP->(dbSetOrder(1))
	If DbSeek(xFilial("CKP") + aCKP[nAtual][03] + aCKP[nAtual][04] )
		If "_HOM" $ AllTrim(GetEnvServer())
            
            RecLock("CKP", .F.)
                CKP->CKP_VALOR   := aCKP[nAtual][04]
		    CKP->(MsUnLock())

        ElseIf "_TST" $ AllTrim(GetEnvServer())

            RecLock("CKP", .F.)
                CKP->CKP_VALOR   := aCKP[nAtual][04]
		    CKP->(MsUnLock())

        ElseIf "_DES" $ AllTrim(GetEnvServer())'

            RecLock("CKP", .F.)
                CKP->CKP_VALOR   := aCKP[nAtual][04]
		    CKP->(MsUnLock())

        EndIf
	Endif

Next

Return()

/*
=====================================================================================
Programa.:              ZAltUsr()
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              02/08/19
Descricao / Objetivo:   Altera os usuários para ter acesso ao APSDU na Bases de Teste
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static Function ZAltUsr()

Local _cUpdate  := ""
Local cQry01	:= ""
Local cTabSql   := GetNextAlias()

If Select((cTabSql)) > 0
    (cTabSql)->(DbCloseArea())
EndIf

cQry01	:= ""
cQry01	:= " SELECT USR_ID, USR_ACESSO FROM SYS_USR_ACCESS "    + CRLF  
cQry01	+= " WHERE USR_CODACESSO = '173' "                      + CRLF 
cQry01	+= " AND USR_ACESSO = 'F' "                             + CRLF  
cQry01	+= " AND D_E_L_E_T_ = ' ' "                             + CRLF
cQry01	+= " ORDER BY USR_ID "                                  + CRLF

cQry01  := ChangeQuery(cQry01)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry01),cTabSql,.T.,.T.)

DbSelectArea((cTabSql))
(cTabSql)->(dbGoTop())
While !(cTabSql)->(Eof())

    //QUANDO O USUÁRIO É ADMIN, HABILITA ACESSO AO APSDU
    If FwIsAdmin( (cTabSql)->USR_ID )
        _cUpdate := " "
        _cUpdate := " UPDATE SYS_USR_ACCESS SET USR_ACESSO = 'T' WHERE D_E_L_E_T_ = ' ' AND USR_ID = '" + (cTabSql)->USR_ID + "' AND USR_ACESSO = 'F' AND USR_CODACESSO = '173' "
        TcSqlExec(_cUpdate)
    EndIf

    (cTabSql)->(DbSkip())
EndDo
(cTabSql)->(DbCloseArea())

Return()

/*
=====================================================================================
Programa.:              ZUpdTable()
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              18/12/20
Descricao / Objetivo:   Apaga o e-mail das Tabelas SA1|SA2|SA4
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static function ZUpdTable()

Local aTabelas  := {}
Local _cUpdate  := " "
Local nAtual    := 0

//Adiciona as tabelas que irão sofrer o pack
aAdd(aTabelas, "SA1010")
aAdd(aTabelas, "SA2010")
aAdd(aTabelas, "SA4010")

ProcRegua(Len(aTabelas))

//Percorre as tabelas
For nAtual := 1 To Len(aTabelas)
 
    IncProc("Excluindo Tabela : " + AllTrim( aTabelas[nAtual] ) )

    _cUpdate := " "
    _cUpdate := " UPDATE " + AllTrim( aTabelas[nAtual] ) + " SET " + Substr(AllTrim( aTabelas[nAtual] ),2,2) + "_EMAIL = ' ' WHERE D_E_L_E_T_ = ' '  "
    TcSqlExec(_cUpdate)

Next

Return()

