#INCLUDE "TOTVS.CH"
#INCLUDE "FWBROWSE.CH"

#DEFINE _cEol CHR(13)+CHR(10)  //final de linha

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZCTBF001
Rdmake 	 	Gera��o e Envio das Tabelas de Pre�o por UF para a Sefaz.
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     Jo�o Carlos 
@single		25/11/18
@version    Nao Informado
@since      Nao Informado  
@return    	Nil
@sample     Nao Informado
@obs        
@project    CAOA - Gera��o XML
@menu       Nao Informado
@history    DAC Denilso	13/8/2020 - Revitaliza��o do fonte e altera��o nome antes XML001.PRW

/*/

User Function ZCTBF001() 
Local _lZCTBF001 	:= SuperGetMV( "CMV_CTB001"  ,,.T.)  	//parametro para habilitar/desabilitar funcionalidade ZCTBF001
Local _cType 		:= OemToAnsi("Todos") + "(*.*) |*.*|"
Local _cDir 
Begin Sequence

	If !_lZCTBF001
		Break
	EndIf

	_cDir := cGetFile(_cType, OemToAnsi("Selecione a Pasta "), 0,, .T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)
	//� Parametro: GETF_LOCALFLOPPY - Inclui o floppy drive local.   �
	//�            GETF_LOCALHARD - Inclui o Harddisk local.         �

	If MsgYesNo("Confirma a Gera��o e Envio das Tabelas de Pre�o por UF para a Sefaz ?")
		//MSAguarde( { || fGeraXml(_cDir) }, "Aguarde!", "Gerando arquivo(s) ...", .F. )
    	FwMsgRun(,{ || FGeraXml(_cDir) }, "Aguarde!", "Gerando arquivo(s)")  
	EndIf

End Sequence

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FGeraXml
Rdmake 		Respons�vel por indicar locar e gerar arquivo XML SEFAZ   
@author 	DAC denilso.carvalho
@since 		16/07/2020
@version 	2.0
@param      _cDir - Pasta onde ser� gravado o XML
@obs 	
/*/
//-------------------------------------------------------------------
Static Function FGeraXml(_cDir)
Local _cAliasPesq   := GetNextAlias()
Local _nAno 		:= Year(dDataBase)
Local _nMes 		:= Month(dDataBase)
Local _dLimite		:= CtoD(Space(08))
Local _cDirXml 		:= AllTrim(_cDir)   //AllTrim(GetMV("MV_XDIRXML"))
Local _cDirLog		:= AllTrim(GetMV("MV_XDIRXML"))
Local _cDataHora	:= DtoS(dDataBase)+"_"+StrTran(Time(),":","")
Local _cTipo     	:= "VA"  //VA=Ve�culo Automotor,AC=Acess�rio
Local _cEan    		:= ""
Local _cEanTrib		:= ""
Local _cUniMed 		:= "Un"
Local _cUniTrib		:= "Un"
Local _aParamBox	:= {}
Local _aRet			:= {}
Local _aTabVVP		:= {}
Local _aTabUF		:= {}
Local _aTexto		:= {}
Local _lAbortou		:= .F.
Local _cPreco 
Local _cIniTra 
Local _cIniAnt 
Local _cTpComb
Local _cArqLog
Local _cArqXml
Local _nPos
Local _nHdLog
Local _nHandle
Local _cMens
Local _cUF := ""

Begin Sequence

	AAdd(_aParamBox	, {1, "Ano:" ,_nAno	, "@E 9999"	,"!Empty(mv_par01) .and. (mv_par01 >= 2020 .and. mv_par01 <= 2050)"  ,"","", 050, .T.	})
	AAdd(_aParamBox	, {1, "M�s:" ,_nMes  , "@E 99"	,"!Empty(mv_par02) .and. (mv_par02 >= 1 .and. mv_par02 <= 12)"  ,"","", 050, .T.	})
	aAdd(_aParamBox , {4, "Seleciona Estado?",.F.,"Marque para Filtrar por UF",100,"",.F.})
	
	If !ParamBox(_aParambox, "Par�metros"	, @_aRet, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .F. /*lUserSave*/)
		Break 
	Endif
	
	_nAno    := _aRet[1]
	_nMes    := _aRet[2]
	_dLimite := CtoD(Alltrim(Str(Day(LastDay(cTod("01/"+StrZero(_nMes,2)+"/"+Alltrim(Str(_nAno)))))))+"/"+StrZero(_nMes,2)+"/"+Alltrim(Str(_nAno)))
	
	if _aRet[3]
		_cUF := u_MarkUf()
	EndIf
	
	_cVersao := "0100"
	_cCgc    := Alltrim(SM0->M0_CGC) //"3471344000177"
	//cIEst   := Alltrim(SM0->M0_INSC) //"809000385110"
	_cNome   := Alltrim(SM0->M0_NOMECOM) //"CAOA MONTADORA DE VEICULOS LTDA"

	//Separar por estados os emails a serem enviados
	ZC0->(dbSetOrder(1))  //ZC0_FILIAL+ZC0_UF+ZC0_SEQUEN
	ZC0->(dbGoTop())

	If ZC0->(Eof())
		MSGInfo("E-mails do Sefaz vs UF n�o cadastrados !","ATENCAO")
		Break        
	Endif

	While ZC0->(!Eof())
			
		If ZC0->(ZC0_STATUS == "2") .or. ( !Empty(_cUF) .and. !(ZC0->ZC0_UF $ _cUF) ) //Status: 1=Ativo,2=Inativo
			ZC0->(dbSkip())
			Loop
		EndIf

 		If Empty(CLO->CLO_INSCR)
			MSGInfo("N�o encontrado 'Inscri��o Estadual' cadastrada para o Estado: "+ZC0->ZC0_UF+" nas tabelas 'CLO/ZC0'. O arquivo deste Estado n�o ser� gerado!","ATENCAO")
			ZC0->(dbSkip())
			Loop
		EndIf
		_nPos	:= Ascan(_aTabUF,{|x| x[1]==ZC0->ZC0_UF})
		
		If _nPos == 0
			AAdd(_aTabUF,{ZC0->ZC0_UF,AllTrim(ZC0->ZC0_EMAIL),.F.,AllTrim(ZC0->ZC0_INSCR)})
		Else
			_aTabUF[_nPos,2]+=";"+AllTrim(ZC0->ZC0_EMAIL)
		EndIf
		ZC0->(dbSkip())
	EndDo

	//Caso n�o carregue as condi��es para envio e-mail abortar
	If Len(_aTabUF) == 0
		MSGInfo("N�o existem E-mails do Sefaz vs UF cadastrados de acordo com as condi��es exigidas!","ATENCAO")
		Break        
	Endif

	VV2->(dbSetOrder(1))  //VV2_FILIAL+VV2_CODMAR+VV2_MODVEI+VV2_SEGMOD
	SB1->(dbSetOrder(1))  
	VVP->(dbSetOrder(1))
	CLO->(dbSetOrder(1))

	If SubsTr( _cDirXml,Len(_cDirXml),1) <> "\"
		_cDirXml += "\"
	EndIf	
    //n�o � necessario pois esta selecionando somente a pasta entao a mesma deve existir
	MakeDir(_cDirXml)  //Cria a pasta onde ser�o gravados os arquivos XML

	//Crio o arquivo de log antes de processar os xmls
	_cArqLog 	:= _cDirLog+"tabpreco_"+_cDataHora+".txt"
	If File(_cArqLog)
		MSGInfo("Arquivo "+_cArqLog+" j� existe n�o ser� possivel criar este arquivo !","ATENCAO")
		Break
	EndIf

	_nHdLog	:= FCreate(_cArqLog)
	If _nHdLog == -1
		MSGInfo("Arquivo de log "+_cArqLog+" n�o foi possivel criar este arquivo !","ATENCAO")
		Break
	EndIf

	If ! FGravaXML(_nHdLog,{{DtoC(Date())+" "+Time()+" => "+"Inicio do Processamento Log "+_cArqLog}})
		Break
	EndIf	

	//Criar o XML
	//Atualmente os dados para os estados ser�o os mesmos pois esta configurado por empresa
	//Caso atualize com filiais ou unidades de neg�cio desta forma abaixo ser� a correta

	For _nPos := 1 to Len(_aTabUF)
		_nHandle 	:= Nil
		_cArqXml	:= _cDirXml+"tabpreco_"+_cDataHora+"_"+_aTabUF[_nPos,1]+".xml"
		//If File(_cArqXml)
		//	FErase(_cArqXml)
		//EndIf
		//para evitar a concorrencia caso seja executado em mais de um usuario
		If File(_cArqXml)
			_cMens := "Arquivo "+_cArqXml+" j� existe n�o ser� possivel criar este arquivo !"
			MSGInfo(_cMens,"ATENCAO")
			If !FGravaXML(_nHdLog,{{_cMens}})
				Break
			EndIf
			Loop
		EndIf

		_nHandle	:= FCreate(_cArqXml)
		If _nHandle == -1
			_cMens	:= "Arquivo "+_cArqXml+" n�o foi possivel criar este arquivo !"
			MSGInfo(_cMens,"ATENCAO")
			If !FGravaXML(_nHdLog,{{_cMens}})
				Break
			EndIf
			Loop
		EndIf

		//Selecionar registros no VVP
   		BeginSql Alias _cAliasPesq
   			SELECT 	VVP.VVP_FILIAL,
					VVP.VVP_CODMAR,
					VVP.VVP_MODVEI,
					VVP.VVP_SEGMOD,
					VVP.VVP_FABMOD,
					VVP.VVP_DATPRC,
					VV2.VV2_DESMOD,
					VV2.VV2_POTMOT,
        			VV2.VV2_CILMOT,
					VV2.VV2_COMVEI,
        			SB1.B1_CEST,
        			SB1.B1_POSIPI,
					VVP.R_E_C_N_O_ NREGVVP,
					MAX(VV2.R_E_C_N_O_) NREGVV2,
					MAX(SB1.R_E_C_N_O_) NREGSB1
   			FROM %Table:VVP% VVP
			JOIN %Table:VV2% VV2 ON 
					VV2.VV2_FILIAL = %xFilial:VV2%
				AND VV2.VV2_CODMAR = VVP.VVP_CODMAR
				AND VV2.VV2_MODVEI = VVP.VVP_MODVEI
				AND VV2.%notDel%
			JOIN %Table:SB1% SB1 ON 
					SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD  = VV2.VV2_PRODUT
				AND SB1.%notDel%
   			WHERE 	VVP.VVP_FILIAL = %xFilial:VVP%
				AND VVP.VVP_DATPRC = (	SELECT MAX(VVP1.VVP_DATPRC) VVP_DATPRC
										FROM %Table:VVP% VVP1
										WHERE 	VVP1.VVP_FILIAL = VVP.VVP_FILIAL
											AND VVP1.VVP_CODMAR = VVP.VVP_CODMAR
											AND VVP1.VVP_MODVEI = VVP.VVP_MODVEI
											AND VVP1.VVP_SEGMOD = VVP.VVP_SEGMOD
											AND VVP1.VVP_FABMOD = VVP.VVP_FABMOD
											AND VVP1.VVP_DATPRC <= %Exp:DtOs(_dLimite)%
											AND VVP1.%NotDel% )	
				AND VVP.%NotDel%			
   			GROUP BY VVP.VVP_FILIAL,
					VVP.VVP_CODMAR,
					VVP.VVP_MODVEI,
					VVP.VVP_SEGMOD,
					VVP.VVP_FABMOD,
					VVP.VVP_DATPRC,
					VV2.VV2_DESMOD,
					VV2.VV2_POTMOT,
        			VV2.VV2_CILMOT,
					VV2.VV2_COMVEI,
        			SB1.B1_CEST,
        			SB1.B1_POSIPI,VVP.R_E_C_N_O_
			ORDER BY VVP_FILIAL,VVP_CODMAR,VVP_MODVEI,VVP_SEGMOD,VVP_FABMOD,VVP_DATPRC,NREGVVP
   		EndSql

    	If (_cAliasPesq)->(Eof())
			If !FGravaXML(_nHdLog,{{"N�o localizado dados na tabela de pre�o (VVP) para o Estado "+_aTabUF[_nPos,1]}})
				Loop
			EndIf
		  	//Fecho os arquivos por�m n�o deleto para deixar como evid�ncia para o usu�rio
			Fclose(_nHandle)
			//If Ferase(_nHandle) == -1
			//	MSGInfo("N�o foi poss�vel deletar o arquivo "+_cArqXml+" o mesmo n�o possui dados para ser enviado !","ATENCAO")
			//Endif	
			Loop
		Endif
		//Inicio a Grava��o do XML
		_aTexto := Aclone({})
		
		Aadd(_aTexto,{"<enviPSCF>"})
		Aadd(_aTexto,{"    <versao>",_cVersao,"</versao>"})
		Aadd(_aTexto,{"    <dadosDeclarante>"})
		Aadd(_aTexto,{"        <CNPJ>",_cCgc,"</CNPJ>"})
		Aadd(_aTexto,{"        <IEST>",_aTabUF[_nPos,4],"</IEST>"})	//inscri��o estadual
		Aadd(_aTexto,{"        <razaoSocial>",_cNome,"</razaoSocial>"})
		Aadd(_aTexto,{"    </dadosDeclarante>"})
		
		If !FGravaXML(_nHandle,_aTexto)
			_lAbortou := .T.
			Break
		Endif
		
		_aTabUF[_nPos][3] := .T.  //Atualizo para informa��o como enviada
		//Enviar as tabelas de acordo com o select realizado anteriormente
		(_cAliasPesq)->(DbGotop())
		
		While (_cAliasPesq)->(!Eof())

			_cTpComb 	:= DeParaComb( (_cAliasPesq)->VV2_COMVEI )
			
			//Necessario fazer esta sele��o pois o mesmo pega do ultimo e anterior
			_aTabVVP 	:= FPESQVVP(_cAliasPesq)
			_cPreco  	:= AllTrim(Str(Int(_aTabVVP[Len(_aTabVVP),1])))
			_cIniTra 	:= Transform(DtoS(_aTabVVP[Len(_aTabVVP)  ,2]),"@R XXXX-XX-XX")
			_cIniAnt 	:= Transform(DtoS(_aTabVVP[Len(_aTabVVP)-1,2]),"@R XXXX-XX-XX")

			// carrego xml
			_aTexto := Aclone({})
			Aadd(_aTexto,{"    <listaProdutos>"})
			Aadd(_aTexto,{"        <produto>" })
			Aadd(_aTexto,{"            <VA_AC>"             ,AllTrim( _cTipo )                                                      ,"</VA_AC>"             })
			Aadd(_aTexto,{"            <cProd>"             ,Alltrim((_cAliasPesq)->VVP_MODVEI) + Alltrim((_cAliasPesq)->VVP_SEGMOD),"</cProd>"             })
			Aadd(_aTexto,{"            <xProd>"             ,AllTrim( (_cAliasPesq)->VV2_DESMOD )                                   ,"</xProd>"             })
			Aadd(_aTexto,{"            <pot>"               ,AllTrim(Transform( (_cAliasPesq)->VV2_POTMOT,"@E 999,999,999.9") )     ,"</pot>"               })
			Aadd(_aTexto,{"            <cilin>"             ,AllTrim(Transform( (_cAliasPesq)->VV2_CILMOT,"@E 999,999,999.9") )     ,"</cilin>"             })
			Aadd(_aTexto,{"            <tpComb>"            ,AllTrim( _cTpComb )                                                    ,"</tpComb>"            })
			Aadd(_aTexto,{"            <CEST>"              ,AllTrim( (_cAliasPesq)->B1_CEST )                                      ,"</CEST>"              })
			Aadd(_aTexto,{"            <NCM>"               ,AllTrim( (_cAliasPesq)->B1_POSIPI )                                    ,"</NCM>"               })
			Aadd(_aTexto,{"            <cEAN>"              ,AllTrim( _cEan)                                                        ,"</cEAN>"              })
			Aadd(_aTexto,{"            <cEANTrib>"          ,AllTrim( _cEanTrib )                                                   ,"</cEANTrib>"          })
			Aadd(_aTexto,{"            <uCom>"              ,AllTrim( _cUniMed )                                                    ,"</uCom>"              })
			Aadd(_aTexto,{"            <uTrib>"             ,AllTrim( _cUniTrib )                                                   ,"</uTrib>"             })
			Aadd(_aTexto,{"            <anoMod>"            ,AllTrim(Subs( (_cAliasPesq)->VVP_FABMOD,5,4) )                         ,"</anoMod>"            })
			Aadd(_aTexto,{"            <anoFab>"            ,AllTrim(Subs( (_cAliasPesq)->VVP_FABMOD,1,4) )                         ,"</anoFab>"            })
			Aadd(_aTexto,{"            <cUF>"               ,AllTrim( _aTabUF[_nPos,1] )                                            ,"</cUF>"               })
			Aadd(_aTexto,{"            <vuntrib>"           ,AllTrim( _cPreco )                                                     ,"</vuntrib>"           })
			Aadd(_aTexto,{"            <INIC_TRAB>"         ,AllTrim( _cIniTra )                                                    ,"</INIC_TRAB>"         })
			Aadd(_aTexto,{"            <INIC_TRAB_ANTERIOR>",AllTrim( _cIniAnt )                                                    ,"</INIC_TRAB_ANTERIOR>"})
			Aadd(_aTexto,{"        </produto>"})
			Aadd(_aTexto,{"    </listaProdutos>"})

			If !FGravaXML(_nHandle,_aTexto)
				_lAbortou := .T.
				Break
			Endif
			(_cAliasPesq)->(DbSkip())
		EndDo
		//Grava tag final do xml
		If !FGravaXML(_nHandle,{{"</enviPSCF>"}})
			_lAbortou := .T.
			Break
		EndIf

		If _aTabUF[_nPos][3]
			If !FGravaXML(_nHdLog,{{DtoC(Date())+" "+Time()+" => "+"Arquivo gerado com sucesso: "+_cArqXml}})
				Break
			EndIf	
		Endif	

		//Fecho arquivo XML
		Fclose(_nHandle)
		If Select(_cAliasPesq) <> 0
			(_cAliasPesq)->(DbCloseArea())
		Endif	
	Next
	//Caso n�o conseguiu gravar o xml
	If _lAbortou
		FGravaXML(_nHdLog,{{"Processamento foi abortado !!! "}})
	EndIf	
	//Indica final
	If !FGravaXML(_nHdLog,{{DtoC(Date())+" "+Time()+" => "+"Termino do Processamento Log "+_cArqLog}})
		Break
	EndIf	
	//Fecho arquivo de Log
	Fclose(_nHdLog)
	FLerLog(_cArqLog)

End Begin

If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FPESQVVP
Rdmake 		Respons�vel por Localizar os dois ultimos lan�amentos de valores na tabela   
@author 	DAC denilso.carvalho
@since 		16/07/2020
@version 	2.0
@param      N�o informado
@obs 		Ja esta posicionado na VVP necess�rio fazer a releitura da VVP
/*/
//-------------------------------------------------------------------
Static Function FPESQVVP(_cAliasPesq)  
Local _cAliasTab   := GetNextAlias()
Local _aTabRet	:= {}
Local _aTab     := {}
Local _nPos
Default _cAliasPesq := ""

If empty(_cAliasPesq)
	AAdd (_aTabRet, { 0, CtoD("") } )
	AAdd (_aTabRet, { 0, CtoD("") } )
	Return _aTabRet 
Endif

//Begin Sequence
	//necess�rio selecionar novamente o VVP devido o mesmo ter que gerar os dois ultimos registros
  	BeginSql Alias _cAliasTab
   		SELECT 	VVP.VVP_VALTAB,
				VVP.VVP_DATPRC,
				VVP.VVP_BASEST
   		FROM %Table:VVP% VVP
   		WHERE 	VVP.VVP_FILIAL = %xFilial:VVP%
			AND VVP.VVP_CODMAR = %Exp:(_cAliasPesq)->VVP_CODMAR%
			AND VVP.VVP_MODVEI = %Exp:(_cAliasPesq)->VVP_MODVEI%
			AND VVP.VVP_SEGMOD = %Exp:(_cAliasPesq)->VVP_SEGMOD%
			AND VVP.VVP_FABMOD = %Exp:(_cAliasPesq)->VVP_FABMOD%
			AND VVP.%NotDel%			
		ORDER BY VVP.VVP_FILIAL,VVP.VVP_CODMAR,VVP.VVP_MODVEI,VVP.VVP_SEGMOD,VVP.VVP_DATPRC
   	EndSql

    While (_cAliasTab)->(!Eof())
		//AAdd(_aTab,{(_cAliasTab)->VVP_VALTAB, StoD((_cAliasTab)->VVP_DATPRC)})
		AAdd(_aTabRet,{(_cAliasTab)->VVP_BASEST, StoD((_cAliasTab)->VVP_DATPRC)})
		(_cAliasTab)->(DbSkip())
	EndDo

	//Se n�o for localizado devolver zerado
	Do Case 
	 	Case Len(_aTabRet) == 0
		
			AAdd(_aTabRet,{ 0, CtoD("") } )
			AAdd(_aTabRet,{ 0, CtoD("") } )
		
		Case Len(_aTabRet) == 1
			
			AAdd(_aTabRet , { 0, CtoD("") } )
			_aTabRet[2,1] := _aTabRet[1,1]
			_aTabRet[2,2] := _aTabRet[1,2]
			_aTabRet[1,1] := 0
			_aTabRet[1,2] := CtoD("")

	EndCase

//End Sequence//Begin

If Select(_cAliasTab) <> 0
	(_cAliasTab)->(DbCloseArea())
	Ferase(_cAliasTab+GetDBExtension())
Endif  

Return _aTabRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} FGravaXML
Rdmake 		Respons�vel por gravar o texto no padr�o XML   
@author 	DAC denilso.carvalho
@since 		16/07/2020
@version 	2.0
@param      _nHd	-ID do arquivo a ser gravado pode ser o log e ou XML
			_aVar   -Matriz contendo o texto e as tags a serem gravadas
@obs 		
/*/
//-------------------------------------------------------------------
Static Function FGravaXML( _nHd, _aVar )
Local _cBuffer
Local _nPos
Local _cTagIni 
Local _cTexto
Local _cTagFim

  Begin Sequence
	For _nPos := 1 To Len(_aVar)
		_cTagIni := Nil
		_cTexto	 := Nil
		_cTagFim := Nil
		If Len(_aVar[_nPos]) >= 1
			_cTagIni 	:= _aVar[_nPos,1]
		EndIf	
		If Len(_aVar[_nPos]) >= 2
			_cTexto 	:= _aVar[_nPos,2]
		EndIf
		If Len(_aVar[_nPos]) >= 3
			_cTagFim 	:= _aVar[_nPos,3]
        Endif
		_cBuffer  := FAjustaTag(_cTagIni /*Tag inicial*/,_cTexto /*Texto*/,_cTagFim /*Tag Final*/)
		_cBuffer  += _cEol
  		If FWrite(_nHd, _cBuffer, Len(_cBuffer)) != Len(_cBuffer)
    		If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
       			Return .F.
    		Endif
  		Endif
	Next
End Sequence
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} FAjustaTag
Rdmake 		Respons�vel por ajustar o texto a ser gravado poder� vir texto com tag e ou somente texto   
@author 	DAC denilso.carvalho
@since 		16/07/2020
@version 	2.0
@param      _nHd	-ID do arquivo a ser gravado pode ser o log e ou XML
			_aVar   -Matriz contendo o texto e as tags a serem gravadas
@obs 		
/*/
//-------------------------------------------------------------------
Static Function FAjustaTag(_cTagIni, _cTexto, _cTagFim)
Local _cRet := ""
Begin Sequence
	If _cTexto == Nil
		_cRet	:= _cTagIni
	ElseIf Len(_cTexto) == 0
		_cRet 	:= StrTran(_cTagIni,">","/>")
	Else
		_cRet	:= _cTagIni+_cTexto+_cTagFim
	Endif
End Begin	
Return _cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} FLerLog
Rdmake 		Respons�vel por mostrar os logs durante o processamento   
@author 	DAC denilso.carvalho
@since 		16/07/2020
@version 	2.0
@param      _cFile	-Arquivo com o caminho completo
@obs 		
/*/
//-------------------------------------------------------------------
Static Function FLerLog(_cFile)
Local _cBuffer  := ""

Begin Sequence
	FT_FUSE( _cFile )
	FT_FGOTOP()
	While !FT_FEOF()
		_cBuffer += FT_FREADLN()
		_cBuffer += _cEol
		FT_FSKIP()
	End
	FT_FUSE()
	FTelaMemo("Log dos arquivos XML enviados: "+_cFile,_cBuffer)  //Monta tela para um campo memo
End Begin
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FLerLog
Rdmake 		Respons�vel por mostrar os logs durante o processamento   
@author 	DAC denilso.carvalho
@since 		16/07/2020
@version 	2.0
@param      cTitulo	-Titulo da tela
			cMemo	-Texto que ser� mostrado 
@obs 		
/*/
//-------------------------------------------------------------------

Static Function FTelaMemo(cTitulo,cMemo)  //Monta tela para um campo memo
Local oCourierNw:=TFont():New("Courier New",,,,.F.,,,,.F.,.F.)
Local oDlg,oMemo
Begin Sequence
	Define MsDialog oDlg From 0,0 To 320 , 835 Title OemToAnsi(cTitulo) Pixel
	@ 007,010 Get oMemo VAR cMemo MEMO SIZE 400,125 OF oDlg Pixel FONT oCourierNw
	@ 140,190 BUTTON "Ok" SIZE 40,13 PIXEL OF oDlg ACTION (oDlg:End())
	Activate MsDialog oDlg CENTERED
End Sequence
Return Nil

//-----------------------------------------------------------------------------


Static Function DeParaComb( cCombVV1 )

	Local cRetorno := ""

	Conout(" ")
	Conout(" DeParaComb ")
	Conout(" ")

	Do Case
	Case cCombVV1 == "0" ; cRetorno := "02" //-Gasolina"
	Case cCombVV1 == "1" ; cRetorno := "01" //-Alcool"
	Case cCombVV1 == "2" ; cRetorno := "03" //-Diesel"
	Case cCombVV1 == "3" ; cRetorno := "15" //-Gas Natural"
	Case cCombVV1 == "4" ; cRetorno := "16" //-Alcool/Gasolina"
	Case cCombVV1 == "5" ; cRetorno := "17" //-Alcool/Gasolina/GNV"
	Case cCombVV1 == "9" ; cRetorno := ""   //Sem Combustivel"
	Case cCombVV1 == "A" ; cRetorno := "04" //-Gasogenio"
	Case cCombVV1 == "B" ; cRetorno := "05" //-Gas Metano"
	Case cCombVV1 == "C" ; cRetorno := "06" //-Eletrico/Fonte Interna"
	Case cCombVV1 == "D" ; cRetorno := "07" //-Eletrico/Fonte Externa"
	Case cCombVV1 == "E" ; cRetorno := "08" //-Gasol/Gas Natural Combustivel"
	Case cCombVV1 == "F" ; cRetorno := "09" //-Alcool/Gas Natural Combustivel"
	Case cCombVV1 == "G" ; cRetorno := "10" //-Diesel/Gas Natural Combustivel"
	Case cCombVV1 == "H" ; cRetorno := "12" //-Alcool/Gas Natural Veicular"
	Case cCombVV1 == "I" ; cRetorno := "13" //-Gasolina/Gas Natural Veicular"
	Case cCombVV1 == "J" ; cRetorno := "14" //-Diesel/Gas Natural Veicular"
	Case cCombVV1 == "K" ; cRetorno := "18" //-Gasolina/Eletrico"
	Case cCombVV1 == "L" ; cRetorno := "19" //-Gasolina/Alcool/Eletrico"
	EndCase 

Return cRetorno

/* 
//-----------------------------------------------------------------------------------------------

Cria a Tela para Selecionar os Estados

//------------------------------------------------------------------------------------------------
*/

User Function MarkUf()
Local lOk  := .T.
Local nX   := 1
Local cRet := ""

Private lMarker     := .T.
Private aDespes := {}
Private oUf 
Private oDesc

	//Alimenta o array
	BUSDATA()
	
	DEFINE MsDIALOG o3Dlg TITLE 'Estados' From 0, 4 To 580, 500 Pixel
		
		oPnMaster := tPanel():New(5,5,,o3Dlg,,,,,,180,280)
		//oPnMaster:Align := CONTROL_ALIGN_ALLCLIENT
	
		oDespesBrw := fwBrowse():New()
		oDespesBrw:setOwner( oPnMaster )
		oDespesBrw:setDataArray()
		oDespesBrw:setArray( aDespes )
		oDespesBrw:disableConfig()
		oDespesBrw:disableReport()
		oDespesBrw:SetLocate() // Habilita a Localiza��o de registros
	
		//Create Mark Column
		oDespesBrw:AddMarkColumns(	{|| IIf(aDespes[oDespesBrw:nAt,01], "LBOK", "LBNO")},; //Code-Block image
									{|| SelectOne(oDespesBrw, aDespes)},; //Code-Block Double Click
									{|| SelectAll(oDespesBrw, 01, aDespes) }) //Code-Block Header Click
	
		oUf   := oDespesBrw:addColumn({"UF"         , {||aDespes[oDespesBrw:nAt,02]}, "C", "@!"  , 1, 02 , , .T. , , .F.,, "aDespes[oDespesBrw:nAt,02]",, .F., .T., , "ETDESPES1"  })
		oDesc := oDespesBrw:addColumn({"Descri��o"  , {||aDespes[oDespesBrw:nAt,03]}, "C", "@!"  , 1, 10 , , .T. , , .F.,, "aDespes[oDespesBrw:nAt,03]",, .F., .T., , "ETDESPES2"  })
		oDesc:SetSize(20)
			
		oDespesBrw:setEditCell( .F. , { || .T. } ) //Desativa edit and code block for validation
		oDespesBrw:SetLineHeight(10)
		
		oDespesBrw:Activate(.T.)

		oButOk  := TButton():New( 10, 190, "Ok"       ,o3Dlg,{|| lOk := .T. ,o3Dlg:End()}, 50,11,,,.F.,.T.,.F.,,.F.,,,.F. )
		oButCan := TButton():New( 25, 190, "Cancelar" ,o3Dlg,{|| lOk := .F. ,o3Dlg:End()}, 50,11,,,.F.,.T.,.F.,,.F.,,,.F. )
		
	Activate MsDialog o3Dlg CENTERED

	cRet := ""

	For nX := 1 to Len(aDespes)
		
		if lOk 
			if aDespes[nX ,1] 
				cRet += alltrim(aDespes[nX ,2]) +'|'
			EndIf
		else
			cRet += alltrim(aDespes[nX ,2]) +'|'
		EndIf

	Next nX

return cRet
/* 
//-----------------------------------------------------------------------------------------------
Marca ou Desmarca o Item
//------------------------------------------------------------------------------------------------
*/
 
Static Function SelectOne(oBrowse, aArquivo)
	aArquivo[oDespesBrw:nAt,1] := !aArquivo[oDespesBrw:nAt,1]
	//oBrowse:Refresh()
	oBrowse:LineRefresh()
Return .T.
 
/* 
//-----------------------------------------------------------------------------------------------
Marca ou Desmarca Todos os Item ao dar Duplo Clique no Cabe�alho
//------------------------------------------------------------------------------------------------
*/
  
Static Function SelectAll(oBrowse, nCol, aArquivo)
Local _ni := 1
	
	For _ni := 1 to len(aArquivo)
		aArquivo[_ni,1] := lMarker
	Next
	
	oBrowse:Refresh()
	lMarker:=!lMarker

Return .T.
  
/* 
//-----------------------------------------------------------------------------------------------
Cria e p�opula o Array que conter� os itens.
por default todos s�o selecionados
//------------------------------------------------------------------------------------------------
*/

Static Function BUSDATA()
Local cQuery    as Character
Local cQryT3    as Character
 
	cQuery  := ""
	cQryT3  := GetNextAlias()
	aDespes := {}
	
	cQuery += " SELECT * FROM " + RetSqlName("SX5") + " SX5 "
	cQuery += "   WHERE SX5.X5_TABELA  = '12' "
	cQuery += "		AND SX5.X5_CHAVE  <> 'EX' "
	cQuery += " 	AND SX5.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryT3, .T., .F. )
	
	(cQryT3)->(DbGoTop())

	While (cQryT3)->(!EOF())
	
		aadd(aDespes,{.t.,alltrim((cQryT3)->X5_CHAVE) ,alltrim((cQryT3)->X5_DESCRI) })
		(cQryT3)->(dbSkip())

	EndDo

	(cQryT3)->(dbCloseArea())
 
Return .t.
