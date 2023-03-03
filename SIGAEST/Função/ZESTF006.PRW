/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ZESTF006 º Autor ³ Antonio Carlos Data ³ 29/12/20          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Leitura e Importacao Arquivo XML para geração de Doc-Entr  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#INCLUDE "PROTHEUS.CH"
#Include "TOTVS.ch"
#include "RWMAKE.ch"
#include "Colors.ch"
#include "Font.ch"
#Include "HBUTTON.CH"
#include "Topconn.ch"

User Function ZESTF006()
Local   aPergs    := {}
Local   cExtens   := "Arquivo XML | *.XML"
Private cFile 	  := Space(10)
Private _nTamF    := 0
Private CPERG     := "NOTAXML"
Private Caminho   := GetMv("CMV_EST001")    //Pasta onde deve ser colocado o arquivo de importacao
Private cLocal    := GetMv("CMV_EST002")    //GetMv("EST002")           907   - Almoxarifado  
Private _cCondP   := GetMv("CMV_EST003")    //GetMv("EST003")           003   - Cond Pag
Private _cMarca   := GetMark()
Private aRetP     := {}
Private aFields   := {}
Private	aPedIte   := {}
Private cArq
Private oDLG
Private aFields2  := {}
Private cArq2
Private lPcNfe	  := GETMV("MV_PCNFE")        //Parâmetro Lógico p/definir se gera Nota Fiscal Eletronica
Private lOk       := .T.
Private _lRetorno := .T.
Private _cAdic    := ""
Private _cPesq    := "CONT:"
Private _cTes     := Space(03)
Private _nPosAT   := 0
Private cMainPath := GetMv("CMV_EST001") 
Private cArqLog	  := GetMv("CMV_EST001")+"\CRIAEIC_"+DTOS(Date())+StrTran(Time(),":")+".LOG"
Private lRes, lResD, lResF, lResS, lResL, lResINV := .F.

PutMV("MV_PCNFE",.f.)

aAdd( aPergs ,{1,"Informe   a  Tes  " , _cTes     ,,, "SF4" ,,0,.T.})
aAdd( aPergs ,{6,"Selecione arquivo " , cMainPath ,"@!",,'.T.',80,.T.,cExtens})

If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Busca XML de Notas Fiscais de Entrada") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina importa dados de NF - EIC") SIZE 268, 8 OF oDlg PIXEL
   @ 38, 15 SAY OemToAnsi("Conforme layout: XML") SIZE 268, 8 OF oDlg PIXEL
   @ 48, 15 SAY OemToAnsi("Confirma Processo ? ") SIZE 268, 8 OF oDlg PIXEL
   DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
   DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
   ACTIVATE MSDIALOG oDlg CENTER

   If nOpca == 0
      Return()
   Endif

   _cTes     := Alltrim(mv_par01)
   cFileOpen := Alltrim(mv_par02)

   Processa({|| ImpCadXML(cFileOpen,@cArqLog) }, "[ZESTF006] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." )
		
   MSGINFO( "Final do processamento!" + CRLF +  "Para mais informações, verifique o arquivo de log: " + cArqLog )
	 
Endif

Return Nil 


Static Function ImpCadXML(cFileOpen,cArqLog)
Local I            := 0
Local V            := 0
Local NX           := 0 
Local nHdl         := 0 
Local lVCHVNFE	   := GetMv("MV_VCHVNFE")
Local cPesq        := "_Importa\"
Local nInd         := 1
Local nPos         := 0 
Private _cCodSAP   := ""
Private cLogWrite  := ""
Private cStatus    := ""
Private aCamposPE  := {} 
Private cEdit1	   := Space(15)
Private _DESCdigit := space(55)
Private _NCMdigit  := space(8)
Private	_cForn     := "" 
Private _cLoja     := ""
Private _cProds    := ""
Private _cDescr    := ""	
Private _cUM       := ""
Private	_cCusto    := ""
Private	_cConta    := ""
Private	_cItemCC   := ""
Private	_cCLVL     := ""
Private cQcom      := 0.00
Private nVUnit     := 0
Private	nVtot      := 0
Private nTotal     := 0
Private nAtual     := 0
Private nAtseg     := 0 
Private _aStruLog  := {}

AADD(_aStruLog,{"STATUS" ,"C",010,0})
AADD(_aStruLog,{"LOG"    ,"C",280,0})

_cArqTRB   := Criatrab(_aStruLog,.T.)
_cIndice   := CriaTrab(Nil,.F.)
_cChaveInd := "LOG"

If Select("TRB6") > 0
    dbSelectArea("TRB6")
    dbCloseArea()
    TCDelFile(_cArqTRB)
EndIf

dbCreate( _cArqTRB , _aStruLog , "TOPCONN" )
dbUseArea( .T., __LocalDriver, _cArqTRB , "TRB6", .F., .F. )
dbCreateIndex( _cArqTRB ,_cChaveInd )

dbSelectArea( "TRB6" )
dbSetOrder(1)

//Verificar arquivos existentes para importar	
_aArqXML	:= Directory( Caminho + "*.XML" )
_nTamF      := Len( _aArqXML )

If _nTamF > 1

	aSort( _aArqXML , , , {|x,y| DTOS(x[3])+x[4]<DTOS(y[3])+y[4] } )

EndIf

For I := 1 to _nTamF  //For para importar mais de um arquivo
   @ 042,006 Say "Arquivo: " + _aArqXML[I][1] 
   cFile := Caminho+_aArqXML[I][1]
   nHdl  := fOpen(cFile,0)
	
	If nHdl == -1
		If !Empty(cFile)
			MsgAlert("O arquivo de nome "+cFile+" nao pode ser aberto! Verifique os parametros.","Atencao!")
		Endif
		PutMV("MV_PCNFE",lPcNfe)
		Return
	Endif

	nPos := AT(cPesq,cMainPath,nInd)

	cArq := Alltrim(Substr(cFileOpen,nPos+9,12))


	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
	nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
	fClose(nHdl)
	
	cAviso := ""
	cErro  := ""
	oNfe := XmlParser(cBuffer,"_",@cErro,@cAviso)

	ProcRegua(_nTamF/Len(cBuffer)) // Numero de registros a processar
	
	Private oNF 

	If !Empty(cErro) .or. !Empty(cAviso)

		MsgAlert("Erro na estrutura do XML(inválido), descrição: " + CRLF + cErro + CRLF + cAviso )
		Return
	Else

		If Type("oNFe:_NFeProc") <> "U"
			oNF := oNFe:_NFeProc:_NFe
		Else
			oNF := oNFe:_NFe
		Endif  

		Private oEmitente  := oNf:_InfNFe:_Emit
		Private oIdent     := oNf:_InfNFe:_IDE
		Private oDestino   := oNf:_InfNFe:_Dest
		Private oTotal     := oNf:_InfNFe:_total:_icmstot:_VNF
		Private oICM       := oNf:_InfNFe:_total:_icmstot:_VICMS      //Val ICMS
		Private ochNFe     := oNf:_InfNFe:_ID       //Chave da Nota
		
		oDet  := oNF:_InfNfe:_Det

		oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
		
		// Validações -------------------------------
		For nX := 1 To LEN(oDet)        //Itens da NF
			cProduto:=oDet[nX]:_Prod:_cProd:TEXT

			VERPROD(cProduto)
			
			If lRes = .F.            
				cLogWrite := " Produto Não Localizado - Verifique " + cProduto
				cStatus := " Erro "
				V := 1
				GERALOGE()
				//Exit
			ENDIF

			If lResL = .T.            
				cLogWrite := " Produto com Local Recebimento errado - Verifique " + cProduto
				cStatus := " Erro "
				V := 1
				GERALOGE()
				//Exit
			ENDIF

			VerInv(cProduto,cLocal)

			IF lResINV = .T.
				cLogWrite := " Produto com bloqueio de data de inventário - Verifique " + cProduto
				cStatus := " Erro "
				V := 1
				GERALOGE()
				//Exit
			ENDIF

		NEXT 

		IF V <> 0
			//*********************************************************************
			//      Chamada do relatório
			//*********************************************************************
			dbSelectArea("TRB6")
			dbGotop()
			If TRB6->(!EOF())
				Processa({|| IMPEXC() },"Gerando Relatorio de Log... "+"[ZESTF006]")
			Else
				cBuffer := Space(512)
			Endif
			//RestArea(aArea) 
			FT_FUSE()
			RETURN()
		ENDIF
		
		_cNota   := Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)
		_cSerie  := OIdent:_serie:TEXT
		
		VerSAP(_cNota,_cSerie)

		If lResS = .F.            
			cLogWrite := " Código SAP ou NF não encontrado no CSV (SZM) - Verifique " + _cNota + ' ' + cProduto
			cStatus := " Erro "
			GERALOGE()
			Return()
		ENDIF

		VerFor(_cCodSAP)
		
		If lResF = .F.            
			cLogWrite := " Código Fornecedor não encontrado SZM - Verifique " + cProduto
			cStatus := " Erro "
			GERALOGE()
			Return()
		ENDIF

			
		aCabec  := {}
		aItens  := {}
		
		cData:=Alltrim(OIdent:_dhEmi:TEXT)
		
		dData:=CTOD(Substr(cData,9,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))

		aAdd(aCabec,{"F1_FILIAL" ,xFilial("SF1")   ,Nil})
		aadd(aCabec,{"F1_DOC"    ,Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9),Nil,Nil})
		aadd(aCabec,{"F1_SERIE"  ,OIdent:_serie:TEXT,Nil,Nil})
		aadd(aCabec,{"F1_TIPO"   ,"N"/*If(MV_PAR01==1,"N",If(MV_PAR01==2,'B','D')),Nil,Nil*/})
		aadd(aCabec,{"F1_FORMUL" ,"N",Nil,Nil})   
		aadd(aCabec,{"F1_PREFIXO","   ",Nil,Nil})
		aadd(aCabec,{"F1_EMISSAO",dData,Nil,Nil})
		aAdd(aCabec,{"F1_DTDIGIT",dDataBase,Nil})
		aadd(aCabec,{"F1_FORNECE",_cForn,Nil,Nil})
		aadd(aCabec,{"F1_LOJA"   ,_cLoja,Nil,Nil})
		aadd(aCabec,{"F1_ESPECIE","SPED",Nil,Nil})
		aadd(aCabec,{"F1_UFORITR" ,"GO",Nil,Nil})  
		aadd(aCabec,{"F1_HIST"   ,"NFe. "+Right("000000000"+Alltrim(_cNota),9)+"/ "+Alltrim(_cSerie)+" Ref. NF Importação."/*If(MV_PAR01=1,"NFe. "+Right("000000000"+Alltrim(_cNota),9)+"/ "+Alltrim(_cSerie)+" Ref. NF Importação.",""),Nil,Nil*/})
		aadd(aCabec,{"F1_CHVNFE" ,Substr((ochNFe:TEXT),4,44),Nil,Nil})     
		aAdd(aCabec,{"F1_COND"	 ,_cCondP,Nil})//cCondP
					//aAdd(aCab,{"F1_MUORITR" ,_cMunOri                ,NIL})//_cMunOri
					//aAdd(aCab,{"F1_UFDESTR" ,_cUfDes                 ,NIL})
					//aAdd(aCab,{"F1_MUDESTR" ,_cMunDes                ,NIL})//_cMunDes
		aPedIte:={}
		
		// -- Nota Fiscal já existe na base ?
		SF1->(DbsetOrder(1)) //Filial+Doc+Serie+Fornec+Loja+Tipo
		If SF1->(DbSeek(XFilial("SF1")+acabec[2][2]+acabec[3][2]+"  "+_cForn+_cLoja+acabec[4][2]))
			MsgAlert("Nota No.: "+acabec[1][2]+"/"+acabec[2][2]+" do Fornec. "+SA2->A2_COD+"/"+SA2->A2_LOJA+" Ja Existe. A Importacao sera interrompida")
			xFile := STRTRAN(Upper(cFile),Caminho, Caminho)
			__CopyFile( cFile, Caminho+"Importados\"+_aArqXML[I][1] )
			FErase(cFile)
	//		PutMV("MV_PCNFE",lPcNfe)
			Return()
		EndIf

		nTotal := LEN(oDet)

		ProcRegua(nTotal)
		
		For nX := 1 To  LEN(oDet)    //Itens da NF
			nAtual++
			cEdit1     := Space(15)
			_DESCdigit := space(55)
			_NCMdigit  := space(8)
			
			cProduto:=oDet[nX]:_Prod:_cProd:TEXT
			xProduto:=cProduto
			
			IncProc("Item " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
			VerProd(cProduto)

			If lRes = .F.             
				MsgAlert("Produto Não Localizado - Verifique " + cProduto + " A Importacao sera interrompida")
				Return
			endif

			If lResD = .F.             
				MsgAlert("Produto sem Sequenciamento - Verifique " + cProduto + " A Importacao sera interrompida")
				Return
			endif

			_cAdic := oNF:_InfNFe:_InfAdic:_Infcpl:Text
			
			_nPosAT := AT( _cPesq, _cAdic )

			IF _nPosAT = 0
				_cCont := "XXXXXXXXXXX"
			ELSE
				_cCont  := Substr(_cAdic,_nPosAT+6,11)       //Buscar nos dados adicionais da NF
			ENDIF

			_cItem := oDet[nX]:_nItem:TEXT                   //oNF:_InfNFe:_DET[nX]:_nItem:Text
			cItem  := StrZero(VAL(_cItem),4)
			cQcom  := oDet[nX]:_Prod:_qCom:Text              //oNF:_InfNFe:_DET[nX]:_Prod:_qCom:Text
			nVUnit := oDet[nX]:_Prod:_vUnCom:Text            //oNF:_InfNFe:_DET[nX]:_Prod:_vUnCom:Text
			nVtot  := oDet[nX]:_Prod:_vProd:Text             //oNF:_InfNFe:_DET[nX]:_Prod:_vProd:Text

			AAdd(aPedIte,{cProduto,Val(cQcom),Val(nVUnit),Val(nVtot)})

			aLinha := {} 
			xProduto:=Right(AllTrim(_cDescr),15)

			aAdd(aLinha,{"D1_FILIAL" ,xFilial("SF1"),Nil})
			aAdd(aLinha,{"D1_TIPO"   ,"N",Nil})
			aadd(aLinha,{"D1_FORMUL" ,"N",Nil,Nil}) 
			aadd(aLinha,{"D1_DATORI" ,dData,Nil,Nil}) 
			aadd(aLinha,{"D1_ITEM"   ,cItem ,NIL})
			aadd(aLinha,{"D1_UM"     , _cUM ,NIL})
			aadd(aLinha,{"D1_LOCAL"  ,cLocal,NIL})
			aadd(aLinha,{"D1_COD"    ,aPedIte[nX][1],Nil,Nil})   
			aadd(aLinha,{"D1_QUANT"  ,aPedIte[nX][2],Nil,Nil})
			aadd(aLinha,{"D1_VUNIT"  ,aPedIte[nX][3],Nil,Nil})       
			aAdd(aLinha,{"D1_TOTAL"  ,aPedIte[nX][4],Nil,Nil})
			aAdd(aLinha,{"D1_DOC"    ,acabec[2][2],Nil})
			aAdd(aLinha,{"D1_SERIE"  ,acabec[3][2],Nil})
			aAdd(aLinha,{"D1_FORNECE",_cForn,Nil})
			aAdd(aLinha,{"D1_LOJA"   ,_cLoja,Nil})
			aAdd(aLinha,{"D1_EMISSAO",dData,Nil})
			aAdd(aLinha,{"D1_DTDIGIT",dDataBase,Nil})
			aAdd(aLinha,{"D1_CC"     ,_cCusto,Nil})
			aAdd(aLinha,{"D1_CONTA"  ,_cConta,Nil})
			aAdd(aLinha,{"D1_ITEMCTA",_cItemCC,Nil})
			aAdd(aLinha,{"D1_CLVL"   ,_cCLVL,Nil})
			aAdd(aLinha,{"D1_XCONT"  ,_cCont,Nil})
			aadd(aLinha,{"D1_TES"    ,_cTes,Nil,Nil})   //TES entrada p/ industrialização Estoque = Sim
			
			aadd(aItens,aLinha) 

		Next nX
		
		aCampos := {}
		aCampos2:= {}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Teste de Inclusao                                            |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aItens) > 0
		nAtseg++
			Private lMsErroAuto := .F.
			Private lMsHelpAuto := .T.

			//--Altera parametro para não validar chave da NFe
			PutMv("MV_VCHVNFE", .F.)

			IncProc("Grv NF " + cValToChar(nAtseg) + " de " + cValToChar(_nTamF) + "...")
			MSExecAuto({|x,y,z|Mata103(x,y,z)},aCabec,aItens,3)
			
			//--Volta parametro ao estado anterior
			PutMv( "MV_VCHVNFE", lVCHVNFE )

			IF lMsErroAuto
				__CopyFile( cFile, Caminho+"Importados\"+_aArqXML[I][1] )
				FErase(cFile)
				
				MSGALERT("ERRO NO PROCESSO")
				MostraErro()   

				PutMV("MV_PCNFE",lPcNfe)
				Return()
			Else
				If SF1->F1_DOC == Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)
					ConfirmSX8()

					__CopyFile( cFile, Caminho+"Importados\"+_aArqXML[I][1] )
					MSGALERT("Nota Gerada com Sucesso !   " + SF1->F1_DOC)

					FErase(cFile)
				Else
					MSGALERT(Alltrim(aCabec[1,2])+' / '+Alltrim(aCabec[2,2])+" - Nota Não Gerada - Tente Novamente !")
				EndIf
			EndIf
		Endif
	EndIf

NEXT I	

//AtuSZM(_cForn,_cLoja,_cNota,_cSerie)
	
PutMV("MV_PCNFE",lPcNfe)
Return()



/*/{Protheus.doc}  
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Verifica o fornecedor
@project
@history
/*/
Static Function VerFor(_cCodSAP)
	Local cQy	:= " "
	Local cAlias:= "FOR"
    lResF := .F.
	cQy := " SELECT A2_COD,A2_LOJA,A2_NOME,A2_XCDSAP,A2_END " + CRLF 
	cQy += "  FROM " + RetSQLName("SA2") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND A2_FILIAL = '" + xfilial('SA2') + "' " + CRLF 
	cQy += " AND A2_XCDSAP = '" + _cCodSAP + "' " + CRLF  

	TcQuery cQy new Alias (cAlias)

	_cForn := (cAlias)->A2_COD 
	_cLoja := (cAlias)->A2_LOJA

    IF !Empty(_cForn)
        lResF := .T. 
    ENDIF
	(cAlias)->(DbCloseArea())
Return(lResF)


/*/{Protheus.doc} 
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Verifica a CODSAP na SZM
@project
@history
/*/
Static Function VerSAP(_cNota,_cSerie)
	Local cQy	:= " "
	Local cAlias:= "ZM"
    lResS := .F.
	cQy := " SELECT ZM_CNPJ " + CRLF 
	cQy += "  FROM " + RetSQLName("SZM") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND ZM_FILIAL = '" + xfilial('SZM') + "' " + CRLF 
	cQy += " AND ZM_DOC = '"    + _cNota + "' " + CRLF
	cQy += " AND ZM_SERIE = '"  + _cSerie + "' " + CRLF  

	TcQuery cQy new Alias (cAlias)

    _cCodSAP := (cAlias)->ZM_CNPJ

    IF !Empty(_cCodSAP)
        lResS := .T. 
    ENDIF
	(cAlias)->(DbCloseArea())
Return(lResS)


/*/{Protheus.doc} 
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Verifica a existência do Produto no Protheus
@project
@history
/*/
Static Function VerProd(cProduto)
    Local _cB1cod := " "
	Local cQy	  := " "
	Local cAlias  := "PRO"
    lRes  := .F. 
	lResL := .F. 
	cQy := " SELECT B1_COD,B1_UM,B1_CC,B1_CONTA,B1_ITEMCC,B1_CLVL,B1_LOCREC " + CRLF 
	cQy += "  FROM " + RetSQLName("SB1") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND B1_FILIAL = '" + xfilial('SB1') + "' " + CRLF 
	cQy += " AND B1_COD = '"    + cProduto + "' " + CRLF  

	TcQuery cQy new Alias (cAlias)

    _cB1cod := (cAlias)->B1_COD
	_cUM    := (cAlias)->B1_UM
	_cCusto := (cAlias)->B1_CC
	_cConta := (cAlias)->B1_CONTA
	_cItemCC:= (cAlias)->B1_ITEMCC
	_cCLVL  := (cAlias)->B1_CLVL
	_cLocrec:= (cAlias)->B1_LOCREC

    IF !Empty(_cB1cod)
        lRes := .T. 
    ENDIF

    IF _cLocrec <> cLocal
        lResL := .T. 
    ENDIF

	(cAlias)->(DbCloseArea())
Return(lRes)


/*/{Protheus.doc} 
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	25/02/2021
@return  	NIL
@obs        Verifica se o endereco está com inventario
@project
@history
/*/
Static Function VerInv(cProduto,cLocal)
	Local cQy3	  := " "
	Local cAlias  := GetNextAlias()

	// verificar na SB2
	cQy3 += Char(13) + Char(10) + " SELECT B2_COD, B2_LOCAL, B2_DTINV FROM " + RetSqlName("SB2") + " SB2 "
	cQy3 += Char(13) + Char(10) + " WHERE D_E_L_E_T_ = ' '
	cQy3 += Char(13) + Char(10) + " AND B2_LOCAL = '" + cLocal + "' "
	cQy3 += Char(13) + Char(10) + " AND B2_COD   = '" + cProduto + "' "	
	cQy3 += Char(13) + Char(10) + " AND B2_DTINV <> ' '    "

	TcQuery cQy3 new alias (cAlias)

	If !Empty( (cAlias)->B2_DTINV)
	    lResINV := .T.
	EndIf

	(cAlias)->(DbCloseArea())

Return lResINV


/*/{Protheus.doc} 
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	25/02/2021
@return  	NIL
@obs        Atualizar o número do Item na SZM
@project
@history
/*/
Static Function AtuSZM(_cForn,_cLoja,_cNota,_cSerie)
Local _cQry1    := " "
Local _cQrySZM  := " "
Local _cCmd     := " "
Local _cCmv     := " "
Local _cAliasZM := "NFC"
Local _cAliasV  := "SMZ"
Local _nRecno   := 0
//_cCmv += " AND D1_PROD    = '" + cProduto + "' "

_cQry1   := " "
_cQry1   := "UPDATE " + RetSqlName("SZM") + " SET ZM_ITEM='    ' "
_cQry1   += " WHERE  " 
_cQry1   += "     D_E_L_E_T_ = ' ' "
_cQry1   += " AND ZM_FILIAL  = '" + xfilial('SZM') + "' " 
_cQry1   += " AND ZM_FORNEC  = '" + _cForn +"' AND ZM_LOJA='"  + _cLoja + "' " 
_cQry1   += " AND ZM_DOC     = '" + _cNota +"' AND ZM_SERIE='" + _cSerie + "' "

TcSqlExec(_cQry1)
If TCSqlExec( _cQry1 ) < 0
	Alert("Erro ao executar a atualização do SZM " + TCSQLError())
EndIf

_cCmv += " SELECT "
_cCmv += "   D1_FILIAL, D1_FORNECE, D1_LOJA, D1_DOC, D1_SERIE, D1_COD, D1_ITEM "
_cCmv += " FROM " + RetSqlName("SD1")
_cCmv += " WHERE"
_cCmv += "     D_E_L_E_T_ = ' ' "
_cCmv += " AND D1_FILIAL  = '" + xfilial('SD1') +  "' "
_cCmv += " AND D1_FORNECE = '" + _cForn +"' AND D1_LOJA='"  + _cLoja  +"' "
_cCmv += " AND D1_DOC     = '" + _cNota +"' AND D1_SERIE='" + _cSerie +"' "
_cCmv += " ORDER BY D1_FILIAL, D1_FORNECE, D1_LOJA, D1_DOC, D1_SERIE, D1_COD, D1_ITEM"
TcQuery _cCmv new Alias (_cAliasV)

(_cAliasV)->(DbGoTop())

While (_cAliasV)->(Eof()) = .F.
     _cCmd := " "
	//pegue o recno da SZM
	_cCmd += " SELECT R_E_C_N_O_ AS RECNO, ZM_PROD"
	_cCmd += " FROM " + RetSqlName("SZM")
	_cCmd += " WHERE "
	_cCmd += "     ROWNUM     = 1  "
	_cCmd += " AND D_E_L_E_T_ = ' '"
	_cCmd += " AND ZM_FILIAL  = '" + xfilial('SZM') +  "' "
	_cCmd += " AND ZM_FORNEC  = '" + (_cAliasV)->D1_FORNECE +"' AND ZM_LOJA='"  + (_cAliasV)->D1_LOJA  + "' "
	_cCmd += " AND ZM_DOC     = '" + (_cAliasV)->D1_DOC +"' AND ZM_SERIE='" + (_cAliasV)->D1_SERIE + "' "
	_cCmd += " AND ZM_PROD    = '" + (_cAliasV)->D1_COD + "' "
	_cCmd += " AND ZM_ITEM    = '    '"

	TcQuery _cCmd new Alias (_cAliasZM)

	_nRecno := (_cAliasZM)->RECNO

	If _nRecno = 0
		cLogWrite := " Produto:" + (_cAliasZM)->ZM_PROD + " com problema no conteúdo do Item."
		cStatus := " Erro "
		GERALOGE()
	Else
	    _cQrySZM   := " "
		_cQrySZM   := " UPDATE " + RetSqlName("SZM") + " SET ZM_ITEM='"+(_cAliasV)->D1_ITEM+"' "
		_cQrySZM   += " WHERE  " 
		_cQrySZM   += "     D_E_L_E_T_ = ' ' "
		_cQrySZM   += " AND R_E_C_N_O_ = " + CvalToChar(_nRecno)
        TcSqlExec(_cQrySZM)
		If TCSqlExec( _cCmd ) < 0
			Alert("Erro ao executar a atualização do SZM " + TCSQLError())
		EndIf
	EndIf

	(_cAliasZM)->(DbCloseArea())
    (_cAliasV)->(DbSkip())

EndDo

(_cAliasV)->(DbCloseArea())

Return()

//		_cQrySZM   += " ZM_FILIAL = '" + xfilial('SZM') + "' " 
//		_cQrySZM   += " AND ZM_FORNEC  = '" + (_cAliasV)->D1_FORNECE +"' AND ZM_LOJA='"  + (_cAliasV)->D1_LOJA + "' " 
//		_cQrySZM   += " AND ZM_DOC     = '" + (_cAliasV)->D1_DOC +"' AND ZM_SERIE='" + (_cAliasV)->D1_SERIE + "' "
//		_cQrySZM   += " AND ZM_PROD    = '" + (_cAliasV)->D1_COD + "' "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para tema "Flat"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Chk_File  ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamado pelo grupo de perguntas EESTR1			          º±±
±±º          ³Verifica se o arquivo em &cVar_MV (MV_PAR06..NN) existe.    º±±
±±º          ³Se não existir abre janela de busca e atribui valor a       º±±
±±º          ³variavel Retorna .T.										  º±±
±±º          ³Se usuário cancelar retorna .F.							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Texto da Janela		                                      º±±
±±º          ³Variavel entre aspas.                                       º±±
±±º          ³Ex.: Chk_File("Arquivo Destino","mv_par06")                 º±±
±±º          ³VerificaSeExiste? Logico - Verifica se arquivo existe ou    º±±
±±º          ³nao - Indicado para utilizar quando o arquivo eh novo.      º±±
±±º          ³Ex. Arqs. Saida.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function Chk_F(cTxt, cVar_MV, lChkExiste)
Local lExiste := File(&cVar_MV)
Local cTipo := "Arquivos XML   (*.XML)  | *.XML | Todos os Arquivos (*.*)    | *.* "
Local cArquivo := ""

//Verifica se arquivo não existe
If lExiste == .F. .or. !lChkExiste
	cArquivo := cGetFile( cTipo,OemToAnsi(cTxt))
	If !Empty(cArquivo)
		lExiste := .T.
		&cVar_Mv := cArquivo
	Endif
Endif
Return (lExiste .or. !lChkExiste)


/*/{Protheus.doc} ZCOMF006
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Grava log das inconsistencias encontradas
@project
@history
/*/
Static Function GERALOGE()
    dbSelectArea("TRB6")
    IF cStatus = " Erro "
        RecLock("TRB6",.T.)
        TRB6->STATUS    := cStatus
        TRB6->LOG       := cLogWrite
        TRB6->( msUnlock() )
    Endif
    
    GravaPen(cLogWrite)
    
Return()


/*
  LOG
*/
Static Function GravaPen(cLogWrite)
Local cCab := "LOG"
If !File(cArqLog)
	nH := FCreate(cArqLog)
	FWrite(nH,cCab+Chr(13)+Chr(10),Len(cCab)+2)
Else
	nH := FOpen(cArqLog,1)
EndIf

FSeek(nH,0,2)
FWrite(nH,cLogWrite+Chr(13)+Chr(10),Len(cLogWrite)+2)
FClose(nH)
cLogWrite := " "
//cStatus   := " "

Return 


/*/{Protheus.doc} 
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Imprime Log das Inconsistencias encontradas
@project
@history
/*/
Static Function IMPEXC()
    Local oReport
    Private _cQuebra := " "

    If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
        oReport := ReportDef()
        oReport:nDevice := 4 //-- Gera arquivo em Planilha
        oReport:nEnvironment := 2 //-- Ambiente Local
        oReport:SetTotalInLine(.F.)
        oReport:PrintDialog()
    EndIf

Return()


/*/{Protheus.doc} 
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Impressão Log das Inconsistencias encontradas
@project
@history    
/*/
Static Function ReportDef()
    Local oReport
    Local oSection1
    
    oReport := TReport():New("IMP","Log",,{|oReport| PrintReport(oReport)},"Este relatorio irá imprimir Log")
    oSection1 := TRSection():New(oReport,OemToAnsi("Log"),{"TRB"})
 
    TRCell():New(oSection1,"STATUS","TRB6","STATUS","@!",040)
    TRCell():New(oSection1,"LOG","TRB6","LOG","@!",280)
    
    oSection1:Cell("STATUS") :SetHeaderAlign("RIGHT")
    oSection1:Cell("LOG")    :SetHeaderAlign("RIGHT")
        
Return oReport


/*/{Protheus.doc} 
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Processo de Impressão Log das Inconsistencias encontradas
@project
@history
/*/
Static Function PrintReport(oReport)

    Local oSection1 := oReport:Section(1)
    oSection1:SetTotalInLine(.F.)
    oSection1:SetTotalText("Total Geral  ")  // Imprime Titulo antes do Totalizador da Seção
    oReport:OnPageBreak(,.T.)

    DbSelectArea("TRB6")
    DbGoTop()

    oReport:SetMeter(RecCount())
    oSection1:Init()
    While  !Eof()
        If oReport:Cancel()
            Exit
        EndIf
        oSection1:PrintLine()

        DbSelectArea("TRB6")
        DbSkip()
        oReport:IncMeter()
    EndDo
    oSection1:Finish()

Return
