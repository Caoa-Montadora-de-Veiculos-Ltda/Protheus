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

/*
=====================================================================================
Programa.:              CMVAUT01
Autor....:              CAOA - Projeto Implementação Montadora
Data.....:              
Descricao / Objetivo:   Processa pedidos do Portal Autoware Veiculos
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:  GAP228- ESTE FONTE SERÁ DESCONTINUADO SUBSTITUIDO PELO ZWR018 DAC- 08/2024
=====================================================================================
*/
WSSTRUCT RetPedido
	WSDATA cdPedido1       as String
	WSDATA cdRetorno       as String      
	WSDATA dsRetorno	   as String
	WSDATA cdPedido		   as String	     
END WSSTRUCT  	
	
WSSTRUCT CabPedido
	WSDATA Filial				As String
	WSDATA cdPedido 	    	As String
	WSDATA cnpj 		    	As String
	WSDATA dtPedido 			As String	
	WSDATA cdTipoPedido	    	As String      
	WSDATA dsTipoPedido    		As String OPTIONAL
	WSDATA cdCondicaoPagamento	As String
	WSDATA dsCondicaoPagamento	As String OPTIONAL 
	WSDATA cnpjBanco		    As String OPTIONAL
	WSDATA comentario		    As String OPTIONAL
	WSDATA cdMarca		    	As String	    
	WSDATA natureza 		    As String OPTIONAL
	WSDATA dsObservacao			As String OPTIONAL
END WSSTRUCT

WSSTRUCT ItemPedido
	WSDATA cdLinha		 		As String			
	WSDATA dsLinha    	 		As String OPTIONAL					
	WSDATA cdModeloComercial  	As String		
	WSDATA dsModeloComercial  	As String OPTIONAL		   
	WSDATA cdModelo     		As String      
	WSDATA dsModelo   			As String OPTIONAL
	WSDATA nuAnoModelo			As String OPTIONAL
	WSDATA nuAnoFabricacao 		As String OPTIONAL
	WSDATA quantidade			As Float     
	WSDATA cdCorExterna			As String     
	WSDATA dsCorExterna			As String OPTIONAL  
	WSDATA cdCorInterna			As String     
	WSDATA dsCorInterna			As String OPTIONAL    			
	WSDATA Id_Item              As Float  OPTIONAL
END WSSTRUCT

WSSTRUCT PedidoVenda
	WSDATA PedCab		As CabPedido	
	WSDATA PedItem  	AS ARRAY OF	ItemPedido	
END WSSTRUCT

WSSERVICE CMVAUT01 DESCRIPTION "WebServices de Integração Pedido Atacado Autoware" 			
	WSDATA aDadosPed	As PedidoVenda	
	WSDATA aRetorno		As RetPedido	
 	WSMETHOD WSCAOA_INCLUSAO_PEDIDO_ATACADO	DESCRIPTION "Inclui um Pedido de Atacado"
ENDWSSERVICE

/*
=====================================================================================
Programa.:              CMVAUT01
Autor....:              CAOA - Projeto Implementação Montadora
Data.....:              
Descricao / Objetivo:   Função para executar manualmente
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
User Function CMVAUT01()

Local aITEM := {{'000002','GFSCNNBWW2','S1W7J461KG','2020','2020',1,'WW2','NNB',2019}}
Local aRet  := {} 

Private _aMatriz := {"01","2010022001" }
Private lIsBlind := IsBlind() .OR. Type("__LocalDriver") == "U"

IF lIsBlind
    RpcSetType(3)
    RpcSetEnv(_aMatriz[1],_aMatriz[2])
    If !LockByName("CMVAUT01")
        Conout("JOB já em Execução : CMVAUT01 " + DTOC(dDATABASE) + " - " + TIME() )
        RpcClearEnv()
        Return
    EndIf
    Conout("[ CMVAUT01 ] - Empresa: " + AllTrim(_aMatriz[1]) + " - Filial: " + AllTrim(_aMatriz[2])  +" - " + DTOC(dDATABASE) + " - " + TIME() )
EndIf

//MsgAlert('Entrou')
aRet := zProcWS ({'2010022001'    ,;
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


U_CAOA_MONITOR( FWFilial()  ,aRet[02],'001','002',aRet[03], '2010022001-'+aRet[01]+'-'+aRet[04] ,'0','' ,0)

Return

/*
=====================================================================================
Programa.:              CMVAUT01
Autor....:              CAOA - Projeto Implementação Montadora
Data.....:              
Descricao / Objetivo:   Método principal do WebService
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
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

aRet :=  zProcWS     ({::aDadosPed:PedCab:Filial              ,;
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

U_CAOA_MONITOR( FWFilial()  ,aRet[02],'001','002',aRet[03], ::aDadosPed:PedCab:Filial+aRet[01]+'-'+aRet[04] ,'0','' ,0)

Return .T.

/*
=====================================================================================
Programa.:              zProcWS
Autor....:              CAOA - Projeto Implementação Montadora
Data.....:              
Descricao / Objetivo:   Processa o Recebimento do WS
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function zProcWS(aParam1,aParam2)

Local aDadosCab     := aParam1
Local cCodCli       := ""
Local cLjCli        := ""
Local dEmis
Local cOper1        := ""
Local cOper2        := ""
Local cTes          := ""
Local cTesFinal     := "" 
Local nX            := 0
Local aCabec        := {}
Local aLinha        := {}
Local cItem         := '001'
Local nI            := 0 
Local cWsFILIAL     := "2010022001"//aDadosCab[01]
Local cWsPag        := aDadosCab[02]
Local cWSMarca      := aDadosCab[03]
Local cWSPedido     := aDadosCab[04]
Local cWSTipoPed    := aDadosCab[05]
Local cWSCNPJ       := aDadosCab[06]
Local cWSDtPed      := aDadosCab[09]
Local cWSNat        := If(aDadosCab[10] == Nil ,"" , aDadosCab[10])
Local aDadosIt      := aParam2
Local cWSLinha      := ''
Local cWSModCom     := ''
Local cWSModelo     := ''
Local cWSAnoM       := ''
Local cWSAnoF       := ''
Local nWSQuant      := ''
Local cWSCorExt     := ''
Local cWSCorInt     := ''
Local nWSID         := 0 
Local bTem          := .F.
Local _cProduto     := " "
Local _lRetPed      := .F.
Local _cEmpresa     := "01"   // Código da Empresa que deseja manipular
Local _cFilial      := "2010022001"   // Código da Filial que deseja manipular

Private cErro       := ""
Private aRet        := {}
Private aItens      := {}
Private aHeader     := {}
Private cTipErro    := "0"
Private cPedido     := ""

Conout("[ CMVAUT01 ] - ABRINDO A EMPRESA: " + DTOC(dDATABASE) + " - " + TIME() )

RpcClearEnv()
RPCSetType(3)
RpcSetEnv(_cEmpresa, _cFilial,,,,GetEnvServer(),{ })

cOper1  := GetMV("CAOA_AUT1A",.F.,'92')
cOper2  := GetMV("CAOA_AUT1B",.F.,'93')
cTes    := GetMV("CAOA_AUT1C",.F.,'501')

/*DbSelectArea('SA1')
DbSelectArea('VV2')
DbSelectArea('VVR')
DbSelectArea('VX5')*/

If !( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
    Conout("[ CMVAUT01 ] - ERRO NA ABERTURA DA EMPRESA: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) +" - " + DTOC(dDATABASE) + " - " + TIME() )
Else
    Conout("[ CMVAUT01 ] - EMPRESA ABERTA COM SUCESSO: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) +" - " + DTOC(dDATABASE) + " - " + TIME() )
EndIf

Conout("[ CMVAUT01 ] - Processando Pedido: " + AllTrim(cWSPedido) +" - INICIO -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) +" - " + DTOC(dDATABASE) + " - " + TIME() )

_lRetPed := zBuscaPed(cWSPedido)
If _lRetPed
    Conout("[ CMVAUT01 ] - Pedido: " + AllTrim(cWSPedido) + " - Pedido ja incluido: " + AllTrim(cWSPedido)  +" -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() )
    Return {cWSPedido,"0",AllTrim(cWSPedido)+" - Pedido ja incluido.",cPedido}
EndIf

If Empty(cWSMarca)
    Conout("[ CMVAUT01 ] - Pedido: " + AllTrim(cWSPedido) + " - Marca nao informada: " + AllTrim(cWSMarca)  + " -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() )
    Return {cWSPedido,"0",AllTrim(cWSMarca)+" - Marca nao informada.",cPedido}
EndIf

SA1->(DbSetOrder(3)) 
If SA1->(DbSeek(xFilial("SA1")+cWSCNPJ))
	cCodCli := SA1->A1_COD
	cLjCli  := SA1->A1_LOJA
	if SA1->A1_MSBLQL == '1'
        Conout("[ CMVAUT01 ] - Pedido: " + AllTrim(cWSPedido) + " - Cliente Bloqueado: " + AllTrim(cWSCNPJ)  +" -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) +" - " + DTOC(dDATABASE) + " - " + TIME() )
		Return {cWSPedido,"0","Cliente Bloqueado: " + cWSCNPJ , "" }
	Endif
Else
    Conout("[ CMVAUT01 ] - Pedido: " + AllTrim(cWSPedido) + " - Cliente nao cadastrado: " + AllTrim(cWSCNPJ)  +" -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) +" - " + DTOC(dDATABASE) + " - " + TIME() )
	Return {cWSPedido,"0","Cliente nao cadastrado: " + cWSCNPJ , ""}
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

    For nI := 1 To nWSQuant

        Conout("[ CMVAUT01 ] - Processando Pedido: " + AllTrim(cWSPedido) +" - Antes de Buscar Modelo -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) +" - " + DTOC(dDATABASE) + " - " + TIME() )
        
        aLinha    := {} 
        cTesFinal := ""
        bTem      := .F.

        _cProduto := " "
        _cProduto := zBuscaModelo( AllTrim(cWSMarca), AllTrim(cWSModelo), AllTrim(cWSModCom), cWSPedido )
        If Empty(_cProduto)
            Conout("[ CMVAUT01 ] - Pedido: " + AllTrim(cWSPedido) + " - Modelo/Modelo Comercial nao encontrado - Modelo: " + AllTrim(cWSModelo) + " | Modelo Comercial: " + AllTrim(cWSModCom) + " -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() )
            Return {cWSPedido,"0", AllTrim(cWSModelo) + " | " + AllTrim(cWSModCom) + " Modelo/Modelo Comercial nao encontrado.",""}
        EndIf

        VVR->(DbSetOrder(2)) 
        If VVR->(!DbSeek(xFilial("VVR")+cWSMarca+cWSLinha ))
            Conout("[ CMVAUT01 ] - Pedido: " + AllTrim(cWSPedido) + " - Linha nao cadastrada: " + AllTrim(cWSLinha) + " -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() )
            Return {cWSPedido,"0",AllTrim(cWSLinha)+" Linha nao cadastrada.",""}
        EndIf

        VX5->(DbSetOrder(1)) 
        If VX5->(!DbSeek(xFilial("VX5")+'067'+cWSCorExt ))
            Conout("[ CMVAUT01 ] - Pedido: " + AllTrim(cWSPedido) + " - Cor externa nao cadastrada: " + AllTrim(cWSCorExt) + " -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() )
            Return {cWSPedido,"0",AllTrim(cWSCorExt)+" Cor externa nao cadastrada.",""}
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
            cTesFinal := MaTesInt(2,cOper1,cCodCli,cLjCli,"C",_cProduto,"C6_TES") 
            Conout("[ CMVAUT01 ] - Processando Pedido: " + AllTrim(cWSPedido) +" - Primeira TES Inteligente - Operacao 01 -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) +" - " + DTOC(dDATABASE) + " - " + TIME() )
            IF !Empty(cTesFinal)
                AAdd(aLinha,{"VRK_OPER" ,cOper1 ,Nil})
                bTem       := .T.
            EndIf
        EndIf
        
        IF !Empty(cOper2) .And.  !bTem
              cTesFinal := MaTesInt(2,cOper2,cCodCli,cLjCli,"C",_cProduto,"C6_TES")
              Conout("[ CMVAUT01 ] - Processando Pedido: " + AllTrim(cWSPedido) +" - Segunda TES Inteligente - Operacao 02 -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) +" - " + DTOC(dDATABASE) + " - " + TIME() )
              IF !Empty(cTesFinal)
                 AAdd(aLinha,{"VRK_OPER"    ,cOper2 ,Nil})
                 bTem       := .T.
              EndIf
        EndIf

        AAdd(aLinha,{"VRK_CODTES"   ,If(!Empty(Alltrim(cTesFinal)),cTesFinal,cTes)  ,Nil})
        Aadd(aLinha,{"VRK_XID"      ,nWSID                                          ,Nil})
        cItem := SOMA1(cItem) 
        Aadd(aItens, aLinha)
        
    Next nI
Next nX

// Montando a Data de Emisso
dEmis := Ctod(cWSDtPed)       

Aadd(aCabec,{"VRJ_FILIAL"   ,cWsFILIAL  ,Nil})
Aadd(aCabec,{"VRJ_PEDCOM"   ,cWSPedido  ,Nil})
Aadd(aCabec,{"VRJ_TIPVEN"   ,cWSTipoPed ,Nil})
Aadd(aCabec,{"VRJ_FORPAG"   ,cWsPag     ,Nil})
Aadd(aCabec,{"VRJ_CODCLI"   ,cCodCli    ,Nil})
Aadd(aCabec,{"VRJ_LOJA"     ,cLjCli     ,Nil})
Aadd(aCabec,{"VRJ_DATDIG"   ,dEmis      ,Nil})    
Aadd(aCabec,{"VRJ_NATURE"   ,cWSNat     ,Nil})
//Aadd(aCabec,{"VRJ_OBSPED" ,cWSObserv  ,Nil})

Conout("[ CMVAUT01 ] - Pedido: " + AllTrim(cWSPedido) + " - Iniciando gravacao do pedido - INICIO -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() )

If !zGravaPed(aCabec, aItens )
    Return {cWSPedido,cTipErro, Alltrim( cErro ),""}
EndIf

Conout("[ CMVAUT01 ] - Pedido: " + AllTrim(cWSPedido) + " - Finalizado gravacao do pedido - FIM -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() )

Return {cWSPedido,"1","Pedido Cadastrado com Sucesso",VRJ->VRJ_PEDIDO}

/*
=====================================================================================
Programa.:              zGravaPed
Autor....:              CAOA - Projeto Implementação Montadora
Data.....:              
Descricao / Objetivo:   Grava o pedido
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function zGravaPed(  aCpoVRJ, aCpoVRK )

Local lRet              := .T.
Local aCabPed           := {}
Local aItePed           := {}
Local cQuery            := ""
Local cTmpAlias         := GetNextAlias()
Local aArea             := GetArea()
Local aLinha            := {}
Local cProduto          := ""
Local cCorInt           := ""
Local cCorExt           := ""
Local cNumPed           := ""
Local cStartPath        := GetSrvProfString("Startpath","\")
Local cLog              := ""
Local cPedAuto          := ""

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

Conout("[ CMVAUT01 ] INICIO - Transaction -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() )

Begin Transaction 

    Conout("[ CMVAUT01 ] INICIO - Gravacao Pedido SigaVEI - FWMVCRotAuto -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() )

	FWMVCRotAuto(oModel					,; //Model
				"VRJ"					,; //Alias
				MODEL_OPERATION_INSERT	,; //Operacao
				{{'MODEL_VRJ', aCpoVRJ},;
				{"MODEL_VRK", aCpoVRK}})

	If lMsErroAuto .And. Upper(Alltrim(VRJ->VRJ_PEDCOM)) != Upper(Alltrim(aCpoVRJ[2][2]))
		aErro   := oModel:GetErrorMessage()
		cErro +=  "Id do formulario de origem:" + ' [' + AllToChar( aErro[1]  ) + ']'+CRLF 
		cErro +=  "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']'+CRLF
		cErro +=  "Id do formulario de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']'+CRLF
		cErro +=  "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']'+CRLF
		cErro +=  "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']'+CRLF
		cErro +=  "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']'+CRLF
		cErro +=  "Mensagem da solucao:       " + ' [' + AllToChar( aErro[7]  ) + ']'+CRLF
		cErro +=  "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']'+CRLF
		cErro +=  "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']'+CRLF
		lRet := .F.
        //DisarmTransaction()
	EndIf

	oModel:DeActivate()

    If lMsErroAuto .And. Upper(Alltrim(VRJ->VRJ_PEDCOM)) != Upper(Alltrim(aCpoVRJ[2][2]))

        aErro   := oModel:GetErrorMessage()
        cErro +=  "Id do formulario de origem:" + ' [' + AllToChar( aErro[1]  ) + ']'+CRLF 
        cErro +=  "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']'+CRLF
        cErro +=  "Id do formulario de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']'+CRLF
        cErro +=  "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']'+CRLF
        cErro +=  "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']'+CRLF
        cErro +=  "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']'+CRLF
        cErro +=  "Mensagem da solucao:       " + ' [' + AllToChar( aErro[7]  ) + ']'+CRLF
        cErro +=  "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']'+CRLF
        cErro +=  "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']'+CRLF

        lRet := .F.
        cTipErro := "0"
        DisarmTransaction()
    Else
        Conout("[ CMVAUT01 ] FIM - Gravacao Pedido SigaVEI - FWMVCRotAuto -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() )

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
        
        If Select(cTmpAlias) <> 0
            (cTmpAlias)->(DbCloseArea())
        EndIf

        DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTmpAlias, .F., .T. )

        (cTmpAlias)->(DbGoTop())

        If (cTmpAlias)->(!Eof())
            
            cNumPed := GetSxeNum("SC5","C5_NUM")
                        
            WHILE ExistCpo("SC5", cNumPed , 1)   //Valido se a numeração já existe para evitar que use uma chave que já existe
                ConfirmSX8()
                cNumPed := GetSxeNum("SC5","C5_NUM")
            ENDDO
            ConfirmSX8() 
            
            aCabPed := {}
            Aadd(aCabPed, {"C5_NUM"    ,cNumPed                    , Nil}) 
            Aadd(aCabPed, {"C5_TIPO"   ,"N"                        , Nil})
            Aadd(aCabPed, {"C5_CLIENTE",(cTmpAlias)->VRJ_CODCLI    , Nil}) 
            Aadd(aCabPed, {"C5_LOJACLI",(cTmpAlias)->VRJ_LOJA      , Nil})
            Aadd(aCabPed, {"C5_CLIENT" ,(cTmpAlias)->VRJ_CODCLI    , Nil}) 
            Aadd(aCabPed, {"C5_LOJAENT",(cTmpAlias)->VRJ_LOJA      , Nil})
            Aadd(aCabPed, {"C5_TRANSP" ,(cTmpAlias)->VRJ_CODTRA    , Nil}) 
            Aadd(aCabPed, {"C5_TIPOCLI",(cTmpAlias)->VRJ_TIPOCL    , Nil})
            Aadd(aCabPed, {"C5_CONDPAG",(cTmpAlias)->VRJ_FORPAG    , Nil}) 
            Aadd(aCabPed, {"C5_EMISSAO",dDataBase                  , Nil})
            Aadd(aCabPed, {"C5_TPFRET" ,(cTmpAlias)->VRJ_TPFRET    , Nil}) 
            Aadd(aCabPed, {"C5_MOEDA"  ,1                          , Nil})
            Aadd(aCabPed, {"C5_PESOL"  ,(cTmpAlias)->VRJ_PESOL     , Nil}) 
            Aadd(aCabPed, {"C5_PBRUTO" ,(cTmpAlias)->VRJ_PBRUTO    , Nil})
            Aadd(aCabPed, {"C5_VOLUME1",(cTmpAlias)->VRJ_VOLUME    , Nil}) 
            Aadd(aCabPed, {"C5_ESPECI1",(cTmpAlias)->VRJ_ESPECI    , Nil})
            Aadd(aCabPed, {"C5_TIPLIB" ,"1"                        , Nil}) 
            Aadd(aCabPed, {"C5_NATUREZ",(cTmpAlias)->VRJ_NATURE    , Nil})
            Aadd(aCabPed, {"C5_XTIPVEN",(cTmpAlias)->VRJ_TIPVEN    , Nil})

            aItePed := {}
            While (cTmpAlias)->(!Eof())
                cPedAuto := Alltrim( (cTmpAlias)->VRJ_PEDCOM )
                
                cCorInt := Posicione("VX5",1,xFilial("VX5")+"066"+(cTmpAlias)->VRK_CORINT,"VX5_DESCRI")
                cCorExt := Posicione("VX5",1,xFilial("VX5")+"067"+(cTmpAlias)->VRK_COREXT,"VX5_DESCRI")

                VVX->(DbSetOrder(1))
                VVX->(DbSeek(xFilial("VVX")+(cTmpAlias)->VRK_CODMAR+(cTmpAlias)->VRK_SEGMOD))
                
                VE1->(DbSetOrder(1))
                VE1->(DbSeek(xFilial("VE1")+(cTmpAlias)->VRK_CODMAR))
                
                VV2->(DbSetOrder(1))
                VV2->(DbSeek(xFilial("VV2")+(cTmpAlias)->VRK_CODMAR+(cTmpAlias)->VRK_MODVEI+(cTmpAlias)->VRK_SEGMOD))

                aLinha   := {}
                cProduto := Alltrim((cTmpAlias)->VRK_MODVEI)+Alltrim((cTmpAlias)->VRK_SEGMOD)

                Aadd( aLinha, { "C6_ITEM"   , Right((cTmpAlias)->VRK_ITEPED,2),Nil  } )
                Aadd( aLinha, { "C6_PRODUTO", cProduto                , Nil } ) 
                Aadd( aLinha, { "C6_QTDVEN" , 1                       , Nil } )
                Aadd( aLinha, { "C6_PRCVEN" , (cTmpAlias)->VRK_VALMOV , Nil } )
                Aadd( aLinha, { "C6_VALOR"  , (cTmpAlias)->VRK_VALMOV , Nil } )
                Aadd( aLinha, { "C6_PRUNIT" , (cTmpAlias)->VRK_VALMOV , Nil } )
                Aadd( aLinha, { "C6_OPER"   , (cTmpAlias)->VRK_OPER   , Nil } )
                Aadd( aLinha, { "C6_TES"    , (cTmpAlias)->VRK_CODTES , Nil } )
                Aadd( aLinha, { "C6_PEDCLI" , (cTmpAlias)->VRJ_PEDCOM , Nil } )
                Aadd( aLinha, { "C6_QTDLIB" , 0                       , Nil } )
                Aadd( aLinha, { "C6_CHASSI" , CriaVar("C6_CHASSI" )   , Nil } )
                Aadd( aLinha, { "C6_LOCALIZ", CriaVar("C6_LOCALIZ")   , Nil } )
                Aadd( aLinha, { "C6_NUMSERI", CriaVar("C6_NUMSERI")   , Nil } )
                Aadd( aLinha, { "C6_XCODMAR", (cTmpAlias)->VRK_CODMAR , Nil } )
                Aadd( aLinha, { "C6_XDESMAR", VE1->VE1_DESMAR         , Nil } )
                Aadd( aLinha, { "C6_XCORINT", (cTmpAlias)->VRK_CORINT , Nil } )
                Aadd( aLinha, { "C6_XCOREXT", (cTmpAlias)->VRK_COREXT , Nil } )
                Aadd( aLinha, { "C6_XMODVEI", (cTmpAlias)->VRK_MODVEI , Nil } )
                Aadd( aLinha, { "C6_XDESMOD", VV2->VV2_DESMOD         , Nil } )
                Aadd( aLinha, { "C6_XSEGMOD", (cTmpAlias)->VRK_SEGMOD , Nil } )
                Aadd( aLinha, { "C6_XDESSEG", VVX->VVX_DESSEG         , Nil } )
                Aadd( aLinha, { "C6_XFABMOD", (cTmpAlias)->VRK_FABMOD , Nil } )
                Aadd( aLinha, { "C6_XGRPMOD", ""                      , Nil } )
                Aadd( aLinha, { "C6_XPRCTAB", (cTmpAlias)->VRK_VALTAB , Nil } )
                Aadd( aLinha, { "C6_XVLRPRD", (cTmpAlias)->VRK_VALPRE , Nil } )
                Aadd( aLinha, { "C6_XVLRMVT", (cTmpAlias)->VRK_VALMOV , Nil } )
                Aadd( aLinha, { "C6_XVLRVDA", (cTmpAlias)->VRK_VALVDA , Nil } )
                Aadd( aLinha, { "C6_XBASST",  (cTmpAlias)->VRK_XBASST , Nil } )
                Aadd( aItePed ,  aLinha )
                (cTmpAlias)->(DbSkip())
            EndDo
            
            Conout("[ CMVAUT01 ] INICIO - Gravacao Pedido SigaFAT - MSExecAuto(MATA410) -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() )

            cTipErro    := "1"
            lRet        := .T.
            lMsHelpAuto := .T.
            lMsErroAuto := .F.
            
            MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabPed, aItePed, 3, .F.)
                        
            If lMsErroAuto
                            
                cErro += "Pedido com Erro" + CRLF
                cErro += "Algumas providencias deverao ser tomadas no Protheus para Faturar" + CRLF
                cLog  += mostraerro(cStartPath+'CMVAUTO01.log')
                cErro += Substr(cLog,1,100)
                MemoWrite("\autoware\" + cPedAuto + ".Log",cLog)
                conout(cErro)

                DisarmTransaction()
                cTipErro := "0"
                lRet := .F.

            EndIf
            Conout("[ CMVAUT01 ] FIM - Gravacao Pedido SigaFAT - MSExecAuto(MATA410) -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() )
        EndIf
    EndIf

    oModel:DeActivate()

End Transaction

Conout("[ CMVAUT01 ] FIM - Transaction -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() )

RestArea(aArea)

Return lRet

/*
=====================================================================================
Programa.:              zBuscaPed
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              07/08/2022
Descricao / Objetivo:   Busca o Pedido
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function zBuscaPed(_cPedido)

Local aArea		  	:= GetArea()
Local cQuery	  	:= ""
Local cAliasTRB		:= GetNextAlias()
Local _lRet         := .T.

Default _cPedido    := " "

If Select( (cAliasTRB) ) > 0
    (cAliasTRB)->(DbCloseArea())
EndIf

cQuery := " "
cQuery += " SELECT * FROM "+RetSQLName("VRJ") +"  VRJ "
cQuery += " WHERE VRJ.D_E_L_E_T_ = ' ' "
cQuery += "   AND VRJ.VRJ_FILIAL = '" + FWxFilial('VRJ') + "' "
cQuery += "   AND VRJ.VRJ_PEDCOM ='"+_cPedido+"' " 

// Executa a consulta.
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

DbSelectArea((cAliasTRB))
(cAliasTRB)->(dbGoTop())

If (cAliasTRB)->(EoF())
    _lRet   := .F.
EndIf

(cAliasTRB)->(DbCloseArea())

RestArea(aArea)

Return(_lRet)

/*
=====================================================================================
Programa.:              zBuscaModelo
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              07/08/2022
Descricao / Objetivo:   Busca o modelo do veiculo.
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function zBuscaModelo(_cMarca, _cModelo, _cSegmento, _cPedido )

Local _cCod         := " "
Local aArea		  	:= GetArea()
Local cQuery	  	:= ""
Local cAliasTRB		:= GetNextAlias()

Default _cMarca     := " "
Default _cModelo    := " "
Default _cSegmento  := " "

If Select( (cAliasTRB) ) > 0
    (cAliasTRB)->(DbCloseArea())
EndIf

cQuery := "	"
cQuery += " SELECT VV2.VV2_PRODUT FROM " + RetSQLName("VV2") +"  VV2 "
cQuery += " WHERE VV2.VV2_FILIAL = '" + FWxFilial('VV2') + "' " 
cQuery += " AND VV2.VV2_CODMAR = '" + _cMarca + "' "
cQuery += " AND VV2.VV2_MODVEI = '" + _cModelo + "' "
cQuery += " AND VV2.VV2_SEGMOD = '" + _cSegmento + "' "
cQuery += " AND VV2.D_E_L_E_T_ = ' ' "

// Executa a consulta.
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

DbSelectArea((cAliasTRB))
(cAliasTRB)->(dbGoTop())

If !(cAliasTRB)->(EoF())
    _cCod := (cAliasTRB)->VV2_PRODUT
Else
    Conout("[ CMVAUT01 ] - Pedido: " + AllTrim(_cPedido) + " - Erro na query de Marca: " + AllTrim(_cMarca) + " | Modelo: " + AllTrim(_cModelo) + " | Modelo Comercial: " + AllTrim(_cSegmento) + " | Produto: " + Alltrim(_cCod) + " -  Empresa: " + Alltrim(FWCodEmp()) + " - Filial : " + AllTrim(FWFilial()) + " - " + DTOC(dDATABASE) + " - " + TIME() +" - " + Alltrim(cQuery) )
EndIf

(cAliasTRB)->(DbCloseArea())

RestArea(aArea)

Return(_cCod)
