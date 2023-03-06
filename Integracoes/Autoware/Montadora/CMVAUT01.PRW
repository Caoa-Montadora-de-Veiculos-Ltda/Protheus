#Include "Protheus.Ch"
#Include "APWebEx.Ch"
#Include "APWebSrv.Ch"
#Include "TopConn.Ch"
#Include "AP5Mail.Ch"  
#Include "Prtopdef.ch"  
#Include "TbiConn.ch"
#Include "TbiCode.ch"  
#Include "FileIO.Ch"
#Include "FWBrowse.Ch"
#Include "FWFilter.Ch"
#Include "FWMVCDEF.CH"
#Define CRLF chr(13) + chr(10)             

/*/{Protheus.doc} CMVAUT01
//TODO WS Pedidos do Atacado.
@author marcos cavalaro
@since 25/10/2018
@version 1.0
@type function
/*/

WSSERVICE CMVAUT01 DESCRIPTION "WebServices de Integração Pedido Atacado Autoware"          
    WSDATA aDadosPed    As PedidoVenda  
    WSDATA aRetorno     As RetPedido    
    WSMETHOD WSCAOA_INCLUSAO_PEDIDO_ATACADO DESCRIPTION "Inclui um Pedido de Atacado"
ENDWSSERVICE

WSSTRUCT PedidoVenda
    WSDATA PedCab       As CabPedido    
    WSDATA PedItem      As Array Of ItemPedido  
ENDWSSTRUCT

WSSTRUCT CabPedido
    WSDATA Filial               As String
    WSDATA cdPedido             As String
    WSDATA cnpj                 As String
    WSDATA dtPedido             As String   
    WSDATA cdTipoPedido         As String      
    WSDATA dsTipoPedido         As String OPTIONAL
    WSDATA cdCondicaoPagamento  As String
    WSDATA dsCondicaoPagamento  As String OPTIONAL 
    WSDATA cnpjBanco            As String OPTIONAL
    WSDATA comentario           As String OPTIONAL
    WSDATA cdMarca              As String       
    WSDATA natureza             As String OPTIONAL
    WSDATA dsObservacao         As String OPTIONAL
ENDWSSTRUCT

WSSTRUCT ItemPedido
    WSDATA cdLinha              As String           
    WSDATA dsLinha              As String OPTIONAL                  
    WSDATA cdModeloComercial    As String       
    WSDATA dsModeloComercial    As String OPTIONAL         
    WSDATA cdModelo             As String      
    WSDATA dsModelo             As String OPTIONAL
    WSDATA nuAnoModelo          As String OPTIONAL
    WSDATA nuAnoFabricacao      As String OPTIONAL
    WSDATA quantidade           As Float     
    WSDATA cdCorExterna         As String     
    WSDATA dsCorExterna         As String OPTIONAL  
    WSDATA cdCorInterna         As String     
    WSDATA dsCorInterna         As String OPTIONAL              
    WSDATA Id_Item              As Float  OPTIONAL
ENDWSSTRUCT

WSSTRUCT RetPedido
    WSDATA cdPedido1 As String
    WSDATA cdRetorno As String      
    WSDATA dsRetorno As String
    WSDATA cdPedido  As String         
ENDWSSTRUCT

//Função para validar o WS
************************
User Function CMVAUT01()
************************

Local aITEM := {{'000002','GFSCNNBWW2','S1W7J461KG','2020','2020',1,'WW2','NNB',2019}}
Local aRet  := {} 

Private _aMatriz := {"01","2010022001"}
Private lIsBlind := IsBlind() .OR. Type("__LocalDriver") == "U"

IF lIsBlind
    RpcSetType(3)
    RpcSetEnv(_aMatriz[1],_aMatriz[2])
    If !LockByName("CMVAUT01")
        Conout("JOB já em Execução : CMVAUT01 " + DTOC(dDATABASE) + " - " + TIME() )
        RpcClearEnv()
        Return
    EndIf   
EndIf

MsgAlert('Entrou')
aRet := ProcWSPed ({'2010022001'    ,;
                    '008'           ,;
                    'HYU'           ,;
                    '3902'          ,;
                    '02'            ,;
                    '18705716000150',;
                    '00000000000001',; // CNPJ Banco
                    'A VISTA'       ,;
                    '14/01/2020'    ,;
                    '1105'          },;
                    aITEM  )


MsgAlert(aRet[01]+CRLF+aRet[02]+CRLF+aRet[03]+CRLF+aRet[04])

U_CAOA_MONITOR( cFilant  ,aRet[02],'001','002',aRet[03], '2010022001-'+aRet[01]+'-'+aRet[04] ,'0','' ,0)

Return

************************************
* Método principal do WebService
************************************
WSMETHOD WSCAOA_INCLUSAO_PEDIDO_ATACADO WSRECEIVE aDadosPed WSSEND aRetorno WSSERVICE CMVAUT01

Local aRet  := {}
Local aITEM := {}
Local aRec  := {}
Local nI    := 0

For nI := 1 To Len(::aDadosPed:PedItem)
    aRec := {}
    Aadd(aRec, ::aDadosPed:PedItem[nI]:CDLINHA              )
    Aadd(aRec, ::aDadosPed:PedItem[nI]:CDMODELOCOMERCIAL    )
    Aadd(aRec, ::aDadosPed:PedItem[nI]:CDMODELO             )
    Aadd(aRec, ::aDadosPed:PedItem[nI]:nuAnoModelo          )
    Aadd(aRec, ::aDadosPed:PedItem[nI]:nuAnoFabricacao      )
    Aadd(aRec, ::aDadosPed:PedItem[nI]:QUANTIDADE           )
    Aadd(aRec, ::aDadosPed:PedItem[nI]:CDCOREXTERNA         )
    Aadd(aRec, ::aDadosPed:PedItem[nI]:CDCORINTERNA         )
    Aadd(aRec, ::aDadosPed:PedItem[nI]:ID_ITEM          )   
    Aadd(aITEM, aRec)
Next NI

aRet :=  ProcWSPed ({::aDadosPed:PedCab:Filial              ,;
                     ::aDadosPed:PedCab:cdCondicaoPagamento ,;
                     ::aDadosPed:PedCab:cdMarca             ,;
                     ::aDadosPed:PedCab:cdPedido            ,;
                     ::aDadosPed:PedCab:cdTipoPedido        ,;
                     ::aDadosPed:PedCab:cnpj                ,;
                     ::aDadosPed:PedCab:cnpjBanco           ,;
                     ::aDadosPed:PedCab:comentario          ,;
                     ::aDadosPed:PedCab:dtPedido            ,;
                     ::aDadosPed:PedCab:natureza            ,;
                     ::aDadosPed:PedCab:dsObservacao }      ,;
                     aITEM )

::aRetorno:cdPedido1   := aRet[1]
::aRetorno:cdRetorno   := aRet[2]
::aRetorno:dsRetorno   := Substr(aRet[3],1,254)
::aRetorno:cdPedido    := aRet[4]

U_CAOA_MONITOR( cFilant  ,aRet[02],'001','002',aRet[03], ::aDadosPed:PedCab:Filial+aRet[01]+'-'+aRet[04] ,'0','' ,0)

Return .T.

******************************************
Static Function ProcWSPed(aParam1,aParam2)
******************************************

Local aDadosCab := aParam1
Local cCodCli   := ""
Local cLjCli    := ""
Local dEmis
Local cOper1    := GetMV("CAOA_AUT1A",.F.,'92')
Local cOper2    := GetMV("CAOA_AUT1B",.F.,'93')
Local cTes      := GetMV("CAOA_AUT1C",.F.,'501')
Local cTesFinal := "" 
Local nX        := 0
Local aCabec    := {}
Local aLinha    := {}
//Local lRet    := .T.
Local cItem     := '001'
Local nI        := 0 

Local cWsFILIAL  := aDadosCab[01]
Local cWsPag     := aDadosCab[02]
Local cWSMarca   := aDadosCab[03]
Local cWSPedido  := aDadosCab[04]
Local cWSTipoPed := aDadosCab[05]
Local cWSCNPJ    := aDadosCab[06]
//Local cWSBanco   := aDadosCab[07]
//Local cWSOBS     := aDadosCab[08]
Local cWSDtPed   := aDadosCab[09]
Local cWSNat     := If(aDadosCab[10] == Nil ,"" , aDadosCab[10])
//Local cWSObserv    := aDadosCab[11]
Local aDadosIt   := aParam2
Local cWSLinha   := ''
Local cWSModCom  := ''
Local cWSModelo  := ''
Local cWSAnoM    := ''
Local cWSAnoF    := ''
Local nWSQuant   := ''
Local cWSCorExt  := ''
Local cWSCorInt  := ''
Local nWSID      := 0 
Local bTem       := .F.

Private cErro      := ""
Private aRet       := {}
Private aItens     := {}
Private aHeader    := {}

cFilant := cWsFILIAL

// O WS J tem filial parametrizada
//Private _aMatriz := {"01","2010022001"}
//Private lIsBlind := IsBlind() .OR. Type("__LocalDriver") == "U"
//RpcSetType(3)
//RpcSetEnv(_aMatriz[1],_aMatriz[2])
SA1->(DbSetOrder(3)) 
If SA1->(DbSeek(xFilial("SA1")+cWSCNPJ))
    cCodCli := SA1->A1_COD
    cLjCli  := SA1->A1_LOJA
Else
    Return {cWSPedido,"0","Cliente nao cadastrado: "+cWSCNPJ,""}
EndIf

SA1->(DbSetOrder(1)) 

VVR->(DbSetOrder(2))
VX5->(dbSetOrder(1))

For nX:=1 To Len(aDadosIt)    
    cWSLinha   := aDadosIt[nX,01]
    cWSModCom  := aDadosIt[nX,02]
    cWSModelo  := aDadosIt[nX,03]
    cWSAnoM    := Alltrim(aDadosIt[nX,04])
    cWSAnoF    := Alltrim(aDadosIt[nX,05])
    nWSQuant   := aDadosIt[nX,06]
    cWSCorExt  := aDadosIt[nX,07]
    cWSCorInt  := aDadosIt[nX,08]
    nWSID      := aDadosIt[nX,09] 

    For nI:= 1 To nWSQuant
        aLinha    := {} 
        cTesFinal := ""
        bTem      := .F.
        VV2->(DbSetOrder(2)) 
        If VV2->(!DbSeek(xFilial("VV2")+cWSMarca+ cWSModCom ))
            Return {cWSPedido,"0",AllTrim(cWSModCom)+" Modelo Comercial no encontrado.",""}
        EndIf
        Aadd(aLinha,{"VRK_ITEPED"   ,cItem                                                      ,Nil})
        Aadd(aLinha,{"VRK_CODMAR"   ,cWSMarca                                                   ,Nil})
        Aadd(aLinha,{"VRK_GRUMOD"   ,cWSLinha                                                   ,Nil})
        Aadd(aLinha,{"VRK_MODVEI"   ,cWSModelo                                                  ,Nil})
        Aadd(aLinha,{"VRK_SEGMOD"   ,cWSModCom                                                  ,Nil})
        Aadd(aLinha,{"VRK_FABMOD"   ,cWSAnoF+cWSAnoM                                            ,Nil})
        Aadd(aLinha,{"VRK_COREXT"   ,cWSCorExt                                                  ,Nil})
        Aadd(aLinha,{"VRK_CORINT"   ,cWSCorInt                                                  ,Nil})  
        Aadd(aLinha,{"B1COD"        ,Alltrim(cWSModelo)+Alltrim(cWSModCom)                      ,Nil})

        IF !Empty(cOper1)
            cTesFinal := MaTesInt(2,cOper1,cCodCli,cLjCli,"C",VV2->VV2_PRODUT,"C6_TES") 
            IF !Empty(cTesFinal)
                AAdd(aLinha,{"VRK_OPER" ,cOper1 ,Nil})
                bTem       := .T.
            EndIf
        EndIf
        
        IF !Empty(cOper2) .And.  !bTem
              cTesFinal := MaTesInt(2,cOper2,cCodCli,cLjCli,"C",VV2->VV2_PRODUT,"C6_TES")
              IF !Empty(cTesFinal)
                 AAdd(aLinha,{"VRK_OPER"    ,cOper2 ,Nil})
                 bTem       := .T.
              EndIf
        EndIf

        AAdd(aLinha,{"VRK_CODTES"   ,If(!Empty(Alltrim(cTesFinal)),cTesFinal,cTes)  ,Nil})
        Aadd(aLinha,{"VRK_XID"      ,nWSID                                          ,Nil})
        cItem := SOMA1(cItem) 
        Aadd(aItens, aLinha)

        VVR->(DbSetOrder(2)) 
        If VVR->(!DbSeek(xFilial("VVR")+cWSMarca+cWSLinha ))
            Return {cWSPedido,"0",AllTrim(cWSLinha)+" Linha no cadastrada.",""}
        EndIf

        VV2->(DbSetOrder(4)) 
        If VV2->(!DbSeek(xFilial("VV2")+cWSModelo ))
            Return {cWSPedido,"0",AllTrim(cWSModelo)+" Modelo no cadastrado.",""}
        EndIf

        VX5->(DbSetOrder(1)) 
        If VX5->(!DbSeek(xFilial("VX5")+'067'+cWSCorExt ))
            Return {cWSPedido,"0",AllTrim(cWSCorExt)+" Cor externa no cadastrada.",""}
        EndIf
    Next nI
Next nX

If !BuscaPed(cWsFILIAL,cWSPedido)
    Return {cWSPedido,"0",AllTrim(cWSPedido)+" - Pedido j incluido.",""}
EndIf

// Montando a Data de Emisso
dEmis:=Ctod(cWSDtPed)       

Aadd(aCabec,{"VRJ_FILIAL"   ,cWsFILIAL  ,Nil})
Aadd(aCabec,{"VRJ_PEDCOM"   ,cWSPedido  ,Nil})
Aadd(aCabec,{"VRJ_TIPVEN"   ,cWSTipoPed ,Nil})
Aadd(aCabec,{"VRJ_FORPAG"   ,cWsPag     ,Nil})
Aadd(aCabec,{"VRJ_CODCLI"   ,cCodCli    ,Nil})
Aadd(aCabec,{"VRJ_LOJA"     ,cLjCli     ,Nil})
Aadd(aCabec,{"VRJ_DATDIG"   ,dEmis      ,Nil})    
Aadd(aCabec,{"VRJ_NATURE"   ,cWSNat     ,Nil})
//Aadd(aCabec,{"VRJ_OBSPED" ,cWSObserv  ,Nil})

If !GravaPed(aCabec, aItens )
    Return {cWSPedido,"0",Alltrim( cErro ),""}
EndIf

Return {cWSPedido,"1","Pedido Cadastrado com Sucesso",VRJ->VRJ_PEDIDO}

*********************************************
Static Function GravaPed(  aCpoVRJ, aCpoVRK )
*********************************************

Local  lRet     := .T.
Local  aCabPed  := {}
Local  aItePed  := {}
Local  cQuery   := ""
Local  cTmpAlias:= GetNextAlias()
Local  aArea    := GetArea()
Local  aLinha   := {}
Local  cProduto := ""
Local  cCorInt  := ""
Local  cCorExt  := ""
Local  cNumPed  := ""

Private oModel      
Private oModelVRK
Private aRotina         := {}
Private aHeader         := {}
Private aCols           := {}
Private N               := 1
Private BREFRESH        := { || .T. }
Private ASAIDACONSOLE   := {}
Private lMsHelpAuto     := .T.
Private lMsErroAuto     := .F.

aArea   := GetArea()
oModel  := FWLoadModel('VEIA060')
aRotina := FWLoadMenuDef('VEIA060')

FWMVCRotAuto(oModel                 ,; //Model
             "VRJ"                  ,; //Alias
             MODEL_OPERATION_INSERT ,; //Operacao
             {{'MODEL_VRJ', aCpoVRJ},;
              {"MODEL_VRK", aCpoVRK}})

If lMsErroAuto .And. Upper(Alltrim(VRJ->VRJ_PEDCOM)) != Upper(Alltrim(aCpoVRJ[2][2]))
    aErro   := oModel:GetErrorMessage()
    cErro +=  "Id do formulrio de origem:" + ' [' + AllToChar( aErro[1]  ) + ']'+CRLF 
    cErro +=  "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']'+CRLF
    cErro +=  "Id do formulrio de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']'+CRLF
    cErro +=  "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']'+CRLF
    cErro +=  "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']'+CRLF
    cErro +=  "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']'+CRLF
    cErro +=  "Mensagem da soluo:       " + ' [' + AllToChar( aErro[7]  ) + ']'+CRLF
    cErro +=  "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']'+CRLF
    cErro +=  "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']'+CRLF
    lRet := .F.
Else
    cQuery := ""
    cQuery += " SELECT *                                                                "
    cQuery += " FROM "+RetSqlName("VRJ") + " VRJ                                        "
    cQuery += " INNER JOIN                                                              "
    cQuery += "      "+RetSqlName("VRK") + " VRK ON VRJ.VRJ_FILIAL  = VRK.VRK_FILIAL    "
    cQuery += "                                 AND VRJ.VRJ_PEDIDO  = VRK.VRK_PEDIDO    "
    cQuery += "                                 AND VRJ.D_E_L_E_T_  = VRK.D_E_L_E_T_    "
    cQuery += " WHERE   VRJ.VRJ_FILIAL  = '"+xFilial("VRJ")+"'                          "
    cQuery += "     AND VRJ.VRJ_PEDIDO  = '"+VRJ->VRJ_PEDIDO+"'                         "
    cQuery += "     AND VRJ.D_E_L_E_T_  = ' '                                           "
    
    If Select(cTmpAlias) <> 0 ; (cTmpAlias)->(DbCloseArea()) ; EndIf
    DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTmpAlias, .F., .T. )

    (cTmpAlias)->(DbGoTop())
    If (cTmpAlias)->(!Eof())
        cNumPed := GetSxeNum("SC5","C5_NUM")  
        aCabPed := {}
        Aadd(aCabPed, {"C5_NUM"    ,cNumPed                 , Nil}); Aadd(aCabPed, {"C5_TIPO"   ,"N"                        , Nil})
        Aadd(aCabPed, {"C5_CLIENTE",(cTmpAlias)->VRJ_CODCLI , Nil}); Aadd(aCabPed, {"C5_LOJACLI",(cTmpAlias)->VRJ_LOJA      , Nil})
        Aadd(aCabPed, {"C5_CLIENT" ,(cTmpAlias)->VRJ_CODCLI , Nil}); Aadd(aCabPed, {"C5_LOJAENT",(cTmpAlias)->VRJ_LOJA      , Nil})
        Aadd(aCabPed, {"C5_TRANSP" ,(cTmpAlias)->VRJ_CODTRA , Nil}); Aadd(aCabPed, {"C5_TIPOCLI",(cTmpAlias)->VRJ_TIPOCL    , Nil})
        Aadd(aCabPed, {"C5_CONDPAG",(cTmpAlias)->VRJ_FORPAG , Nil}); Aadd(aCabPed, {"C5_EMISSAO",dDataBase                  , Nil})
        Aadd(aCabPed, {"C5_TPFRET" ,(cTmpAlias)->VRJ_TPFRET , Nil}); Aadd(aCabPed, {"C5_MOEDA"  ,1                          , Nil})
        Aadd(aCabPed, {"C5_PESOL"  ,(cTmpAlias)->VRJ_PESOL  , Nil}); Aadd(aCabPed, {"C5_PBRUTO" ,(cTmpAlias)->VRJ_PBRUTO    , Nil})
        Aadd(aCabPed, {"C5_VOLUME1",(cTmpAlias)->VRJ_VOLUME , Nil}); Aadd(aCabPed, {"C5_ESPECI1",(cTmpAlias)->VRJ_ESPECI    , Nil})
        Aadd(aCabPed, {"C5_TIPLIB" ,"1"                     , Nil}); Aadd(aCabPed, {"C5_NATUREZ",(cTmpAlias)->VRJ_NATURE    , Nil})
        Aadd(aCabPed, {"C5_XTIPVEN",(cTmpAlias)->VRJ_TIPVEN , Nil})

        aItePed := {}
        While (cTmpAlias)->(!Eof())

            cCorInt := Posicione("VX5",1,xFilial("VX5")+"066"+(cTmpAlias)->VRK_CORINT,"VX5_DESCRI")
            cCorExt := Posicione("VX5",1,xFilial("VX5")+"067"+(cTmpAlias)->VRK_COREXT,"VX5_DESCRI")

            VVX->(DbSetOrder(1)); VVX->(DbSeek(xFilial("VVX")+(cTmpAlias)->VRK_CODMAR+(cTmpAlias)->VRK_SEGMOD                           ))
            VE1->(DbSetOrder(1)); VE1->(DbSeek(xFilial("VE1")+(cTmpAlias)->VRK_CODMAR                                                   ))
            VV2->(DbSetOrder(1)); VV2->(DbSeek(xFilial("VV2")+(cTmpAlias)->VRK_CODMAR+(cTmpAlias)->VRK_MODVEI+(cTmpAlias)->VRK_SEGMOD   ))

            aLinha   := {}
            cProduto := Alltrim((cTmpAlias)->VRK_MODVEI)+Alltrim((cTmpAlias)->VRK_SEGMOD)

            Aadd(aLinha,{"C6_ITEM"   ,Right((cTmpAlias)->VRK_ITEPED,2),Nil  })
            Aadd(aLinha,{"C6_PRODUTO",cProduto               ,Nil  });Aadd(aLinha,{"C6_QTDVEN" ,1                        ,Nil  })
            Aadd(aLinha,{"C6_PRCVEN" ,(cTmpAlias)->VRK_VALMOV,Nil  });Aadd(aLinha,{"C6_VALOR"  ,(cTmpAlias)->VRK_VALMOV  ,Nil  })
            Aadd(aLinha,{"C6_PRUNIT" ,(cTmpAlias)->VRK_VALMOV,Nil  });Aadd(aLinha,{"C6_TES"    ,(cTmpAlias)->VRK_CODTES  ,Nil  })
            Aadd(aLinha,{"C6_OPER"   ,(cTmpAlias)->VRK_OPER  ,Nil  });Aadd(aLinha,{"C6_PEDCLI" ,(cTmpAlias)->VRJ_PEDCOM  ,Nil  })
            Aadd(aLinha,{"C6_QTDLIB" ,0                      ,Nil  });Aadd(aLinha,{"C6_CHASSI" ,CriaVar("C6_CHASSI" )    ,Nil  })
            Aadd(aLinha,{"C6_LOCALIZ",CriaVar("C6_LOCALIZ")  ,Nil  });Aadd(aLinha,{"C6_NUMSERI",CriaVar("C6_NUMSERI")    ,Nil  })
            Aadd(aLinha,{"C6_XCODMAR",(cTmpAlias)->VRK_CODMAR,Nil  });Aadd(aLinha,{"C6_XDESMAR",VE1->VE1_DESMAR          ,Nil  })
            Aadd(aLinha,{"C6_XCORINT",(cTmpAlias)->VRK_CORINT,Nil  });Aadd(aLinha,{"C6_XCOREXT",(cTmpAlias)->VRK_COREXT  ,Nil  })
            Aadd(aLinha,{"C6_XMODVEI",(cTmpAlias)->VRK_MODVEI,Nil  });Aadd(aLinha,{"C6_XDESMOD",VV2->VV2_DESMOD          ,Nil  })
            Aadd(aLinha,{"C6_XSEGMOD",(cTmpAlias)->VRK_SEGMOD,Nil  });Aadd(aLinha,{"C6_XDESSEG",VVX->VVX_DESSEG          ,Nil  })
            Aadd(aLinha,{"C6_XFABMOD",(cTmpAlias)->VRK_FABMOD,Nil  });Aadd(aLinha,{"C6_XGRPMOD",""                       ,Nil  })
            Aadd(aLinha,{"C6_XPRCTAB",(cTmpAlias)->VRK_VALTAB,Nil  });Aadd(aLinha,{"C6_XVLRPRD",(cTmpAlias)->VRK_VALPRE  ,Nil  })
            Aadd(aLinha,{"C6_XVLRMVT",(cTmpAlias)->VRK_VALMOV,Nil  });Aadd(aLinha,{"C6_XVLRVDA",(cTmpAlias)->VRK_VALVDA  ,Nil  })
            Aadd(aLinha,{"C6_XBASST", (cTmpAlias)->VRK_XBASST,Nil  })
            Aadd(aItePed, aLinha)
            (cTmpAlias)->(DbSkip())
        End
           
        lMsHelpAuto := .T.
        lMsErroAuto := .F.
        MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabPed, aItePed, 3, .F.)
        If lMsErroAuto
            MostraErro()
        EndIf
    EndIf
EndIf

oModel:DeActivate()

RestArea(aArea)

Return lRet

*****************************************
Static Function BuscaPed(cPedFIl,cPedCOM)
*****************************************

Local cQuery := ''
Local bRet   := .T.

cQuery := " SELECT *                        "
cQuery += " FROM "+RetSQLName("VRJ")
cQuery += " WHERE D_E_L_E_T_ = ' '          "
cQuery += "   AND VRJ_FILIAL ='"+cPedFIl+"' "
cQuery += "   AND VRJ_PEDCOM ='"+cPedCom+"' "                                                                                     "
cQuery  := ChangeQuery(cQuery)

If Select("QRY_PED") > 0 ; QRY_PED->(DbCloseArea()) ; EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY_PED",.T.,.F.)
DbSelectArea("QRY_PED")
QRY_PED->(DbGoTop())
If QRY_PED->(!Eof())
    bRet   := .F.
EndIf

Return bRet

