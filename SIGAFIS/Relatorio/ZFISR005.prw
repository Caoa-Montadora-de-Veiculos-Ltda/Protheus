#Include "Protheus.ch"
#Include "Topconn.ch"

//----------------------------------------------------------
User Function ZFISR005()
    Local oReport,  oSection

    Private cAliasTMP := GetNextAlias()

	oReport:= TReport():New("ZFISR005",;
                            "Saidas",;
                            "ZFISR001R2",;
                            {|oReport|  ReportPrint(oReport)},;
                            "Este relatorio efetua a impressão das notas fiscais de saida")
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
    oReport:HideHeader() //--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter() //--Define que não será impresso o rodapé padrão da página
    oReport:SetDevice(4) //--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetPreview(.T.) //--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2) //--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
    //oReport:SetEdit(.T.) 
	
	//Verifica os parâmetros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.F.)
	
	oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTMP}) 

    TRCell():New( oSection  ,"CgcCpf"      ,cAliasTMP  ,"Cnpj/Cpf"						)
    TRCell():New( oSection  ,"CGCLocEnt"   ,cAliasTMP  ,"CNPJ Loc. Entr."				)
    TRCell():New( oSection  ,"IncEst"      ,cAliasTMP  ,"Insc.Estadual"				    )
    TRCell():New( oSection  ,"TpPessoa"    ,cAliasTMP  ,"Pessoa Fisica/Juridica"		)
    TRCell():New( oSection  ,"EstCli"      ,cAliasTMP  ,"UF"							)
    TRCell():New( oSection  ,"D2_TES"      ,cAliasTMP  ,"Tes"							)
    TRCell():New( oSection  ,"F4_FINALID"  ,cAliasTMP  ,"Finalidade TES"				)
    TRCell():New( oSection  ,"B1_ORIGEM"   ,cAliasTMP  ,"Origem do Produto"			    )
    TRCell():New( oSection  ,"B1_POSIPI"   ,cAliasTMP  ,"NCM"							)
    TRCell():New( oSection  ,"B1_EX_NBM"   ,cAliasTMP  ,"Ex-NBM"						)
    TRCell():New( oSection  ,"ModVei"      ,cAliasTMP  ,"Modelo Veículo"				)
    TRCell():New( oSection  ,"VRK_OPCION"  ,cAliasTMP  ,"Opcional"						)
    TRCell():New( oSection  ,"B1_GRUPO"    ,cAliasTMP  ,"Grupo\Linha"					)
    TRCell():New( oSection  ,"BM_DESC"     ,cAliasTMP  ,"Descrição do Grupo"			)
    TRCell():New( oSection  ,"D2_TOTAL"    ,cAliasTMP  ,"Valor Total Item"				)
    TRCell():New( oSection  ,"D2_CF"       ,cAliasTMP  ,"Cfop"							)
    TRCell():New( oSection  ,"FT_VALCONT"  ,cAliasTMP  ,"Valor Contábil"				)
    TRCell():New( oSection  ,"FT_BASEICM"  ,cAliasTMP  ,"Base ICMS"					    )
    TRCell():New( oSection  ,"FT_ALIQICM"  ,cAliasTMP  ,"Aliq. ICMS"					)
    TRCell():New( oSection  ,"FT_VALICM"   ,cAliasTMP  ,"Valor ICMS"					)
    TRCell():New( oSection  ,"C6_XVLCOM"   ,cAliasTMP  ,"Comissão"						)
    TRCell():New( oSection  ,"FT_BASEIPI"  ,cAliasTMP  ,"Base IPI"						)
    TRCell():New( oSection  ,"FT_ALIQIPI"  ,cAliasTMP  ,"Aliq. IPI"					    )
    TRCell():New( oSection  ,"FT_VALIPI"   ,cAliasTMP  ,"Valor IPI"					    )
    TRCell():New( oSection  ,"VlIPIRegi"   ,cAliasTMP  ,"Credito_Regional IPI"			)
    TRCell():New( oSection  ,"VlIPIPres"   ,cAliasTMP  ,"Credito_Presumido IPI/Frete"	)
    TRCell():New( oSection  ,"FT_BASERET"  ,cAliasTMP  ,"Base Subst"					)
    TRCell():New( oSection  ,"FT_ICMSRET"  ,cAliasTMP  ,"Valor Subst"					)
    TRCell():New( oSection  ,"FT_BASEPIS"  ,cAliasTMP  ,"Base Pis Apuração"			    )
    TRCell():New( oSection  ,"FT_ALIQPIS"  ,cAliasTMP  ,"Aliq. Pis Apuração"			)
    TRCell():New( oSection  ,"FT_VALPIS"   ,cAliasTMP  ,"Valor Pis Apuração"			)
    TRCell():New( oSection  ,"FT_BASECOF"  ,cAliasTMP  ,"Base Cofins Apuração"			)
    TRCell():New( oSection  ,"FT_ALIQCOF"  ,cAliasTMP  ,"Aliq. Cofins Apuração"		    )
    TRCell():New( oSection  ,"FT_VALCOF"   ,cAliasTMP  ,"Valor Cofins Apuração"		    )
    TRCell():New( oSection  ,"FT_BASEPS3"  ,cAliasTMP  ,"Base PIS ST ZFM"				)
    TRCell():New( oSection  ,"FT_ALIQPS3"  ,cAliasTMP  ,"Aliq. PIS ST ZFM"				)
    TRCell():New( oSection  ,"FT_VALPS3"   ,cAliasTMP  ,"Vl. PIS ST ZFM"				)
    TRCell():New( oSection  ,"FT_BASECF3"  ,cAliasTMP  ,"Base COF ST ZFM"				)
    TRCell():New( oSection  ,"FT_ALIQCF3"  ,cAliasTMP  ,"Aliq. COF ST ZFM"				)
    TRCell():New( oSection  ,"FT_VALCF3"   ,cAliasTMP  ,"Vl. COF ST ZFM"				)
    TRCell():New( oSection  ,"FT_DIFAL"    ,cAliasTMP  ,"ICMS Difal"					)
    TRCell():New( oSection  ,"FT_CLASFIS"  ,cAliasTMP  ,"CST ICMS"						)
    TRCell():New( oSection  ,"FT_CTIPI"    ,cAliasTMP  ,"CST IPI"						)
    TRCell():New( oSection  ,"FT_CSTPIS"   ,cAliasTMP  ,"CST PIS"						)
    TRCell():New( oSection  ,"FT_CSTCOF"   ,cAliasTMP  ,"CST COFINS"					)
    TRCell():New( oSection  ,"F4_ICM"      ,cAliasTMP  ,"Calcula ICMS"					)
    TRCell():New( oSection  ,"F4_CREDICM"  ,cAliasTMP  ,"Credita ICMS"					)
    TRCell():New( oSection  ,"F4_IPI"      ,cAliasTMP  ,"Calcula IPI"					)
    TRCell():New( oSection  ,"F4_CREDIPI"  ,cAliasTMP  ,"Credita IPI"					)
    TRCell():New( oSection  ,"D2_DOC"      ,cAliasTMP  ,"Nota Fiscal"					)
    TRCell():New( oSection  ,"NfPref"      ,cAliasTMP  ,"Nf. Prefeitura"				)
    TRCell():New( oSection  ,"D2_SERIE"    ,cAliasTMP  ,"Série"						    )
    TRCell():New( oSection  ,"F2_ESPECIE"  ,cAliasTMP  ,"Espécie"						)
    TRCell():New( oSection  ,"ModNot"      ,cAliasTMP  ,"Modelo"						)
    TRCell():New( oSection  ,"D2_EMISSAO"  ,cAliasTMP  ,"Dt. de Emissão"				)
    TRCell():New( oSection  ,"D2_CLIENTE"  ,cAliasTMP  ,"Cliente\Fornecedor"			)
    TRCell():New( oSection  ,"D2_LOJA"     ,cAliasTMP  ,"Loja"							)
    TRCell():New( oSection  ,"CliFor"      ,cAliasTMP  ,"Nome"							)
    TRCell():New( oSection  ,"C6_CHASSI"   ,cAliasTMP  ,"Chassi"						)
    TRCell():New( oSection  ,"D2_COD"      ,cAliasTMP  ,"Cód.Produto"					)
    TRCell():New( oSection  ,"B1_DESC"     ,cAliasTMP  ,"Descrição do Produto"			)
    TRCell():New( oSection  ,"B5_CEME"     ,cAliasTMP  ,"Descrição Científico"			)
    TRCell():New( oSection  ,"B1_XDESCL1"  ,cAliasTMP  ,"Descrição Longa"				)
    TRCell():New( oSection  ,"D2_UM"       ,cAliasTMP  ,"Un Medida"					    )
    TRCell():New( oSection  ,"D2_QUANT"    ,cAliasTMP  ,"Quant."						)
    TRCell():New( oSection  ,"D2_PRUNIT"   ,cAliasTMP  ,"Valor Unit. Item"				)
  //TRCell():New( oSection  ,"D2_DESC"     ,cAliasTMP  ,"Desconto Item"				    )
    TRCell():New( oSection  ,"D2_DESCON"   ,cAliasTMP  ,"Desconto Item"				    )
    TRCell():New( oSection  ,"VlrFrete"    ,cAliasTMP  ,"Frete"						    )
    TRCell():New( oSection  ,"VlrSeguro"   ,cAliasTMP  ,"Seguro"						)
    TRCell():New( oSection  ,"VlrDesp"     ,cAliasTMP  ,"Despesas"						)
    TRCell():New( oSection  ,"D2_CUSTO1"   ,cAliasTMP  ,"Custo"						    )
    TRCell():New( oSection  ,"D2_CONTA"    ,cAliasTMP  ,"Conta Contábil"				)
    TRCell():New( oSection  ,"CT1_DESC01"  ,cAliasTMP  ,"Desc.Conta Contábil"			)
    TRCell():New( oSection  ,"D2_FILIAL"   ,cAliasTMP  ,"Empresa"						)
    TRCell():New( oSection  ,"Situacao"    ,cAliasTMP  ,"Situação"						)
    TRCell():New( oSection  ,"TpNF"        ,cAliasTMP  ,"Tipo Nota Fiscal"				)
    TRCell():New( oSection  ,"FT_CHVNFE"   ,cAliasTMP  ,"Chave Nota Fiscal"			    )
    TRCell():New( oSection  ,"Protocolo"   ,cAliasTMP  ,"Protocolo"					    )
    TRCell():New( oSection  ,"D2_NFORI"    ,cAliasTMP  ,"Nota Fiscal Origem"			)
    TRCell():New( oSection  ,"DescTipo"    ,cAliasTMP  ,"Tipo Cli\For"					)
    TRCell():New( oSection  ,"TpCliFor"    ,cAliasTMP  ,"Cli\For"						)
    TRCell():New( oSection  ,"X5_DESCRI"   ,cAliasTMP  ,"Estado"						)
    TRCell():New( oSection  ,"CC2_MUN"     ,cAliasTMP  ,"Município"					    )
    TRCell():New( oSection  ,"B1_CEST"     ,cAliasTMP  ,"CEST"							)
    TRCell():New( oSection  ,"DesMod"      ,cAliasTMP  ,"Descr. Modelo Veículo"		    )
    TRCell():New( oSection  ,"ComVei"      ,cAliasTMP  ,"Combustível Veículo"			)
    TRCell():New( oSection  ,"F4_TEXTO"    ,cAliasTMP  ,"Descrição CFOP"				)
    TRCell():New( oSection  ,"F2_CODNFE"   ,cAliasTMP  ,"Cód.Verificação"				)
    TRCell():New( oSection  ,"Ambiente"    ,cAliasTMP  ,"Ambiente"						)
    TRCell():New( oSection  ,"FT_BASEIRR"  ,cAliasTMP  ,"Base Irrf Retenção"			)
    TRCell():New( oSection  ,"FT_ALIQIRR"  ,cAliasTMP  ,"Aliq. Irrf Retenção"			)
    TRCell():New( oSection  ,"FT_VALIRR"   ,cAliasTMP  ,"Irrf Retenção"				    )
    TRCell():New( oSection  ,"FT_BASEINS"  ,cAliasTMP  ,"Base Inss"					    )
    TRCell():New( oSection  ,"FT_ALIQINS"  ,cAliasTMP  ,"Aliq. Inss"					)
    TRCell():New( oSection  ,"D2_ABATINS"  ,cAliasTMP  ,"Inss Recolhido"				)
    TRCell():New( oSection  ,"FT_VALINS"   ,cAliasTMP  ,"Valor Inss"					)
    TRCell():New( oSection  ,"D2_BASEISS"  ,cAliasTMP  ,"Base Iss"						)
    TRCell():New( oSection  ,"D2_ALIQISS"  ,cAliasTMP  ,"Aliq. Iss"					    )
    TRCell():New( oSection  ,"D2_ABATISS"  ,cAliasTMP  ,"Iss Serviços"					)
    TRCell():New( oSection  ,"D2_ABATMAT"  ,cAliasTMP  ,"Iss Materiais"				    )
    TRCell():New( oSection  ,"D2_VALISS"   ,cAliasTMP  ,"Valor Iss"					    )
    TRCell():New( oSection  ,"FT_BASECSL"  ,cAliasTMP  ,"Base Csll"					    )
    TRCell():New( oSection  ,"FT_ALIQCSL"  ,cAliasTMP  ,"Aliq. Csll"					)
    TRCell():New( oSection  ,"FT_VALCSL"   ,cAliasTMP  ,"Valor Csll"					)
    TRCell():New( oSection  ,"FT_BRETPIS"  ,cAliasTMP  ,"Base Pis Retenção"			    )
    TRCell():New( oSection  ,"FT_ARETPIS"  ,cAliasTMP  ,"Aliq. Pis Retenção"			)
    TRCell():New( oSection  ,"FT_VRETPIS"  ,cAliasTMP  ,"Valor Pis Retenção"			)
    TRCell():New( oSection  ,"FT_BRETCOF"  ,cAliasTMP  ,"Base Cofins Retenção"			)
    TRCell():New( oSection  ,"FT_ARETCOF"  ,cAliasTMP  ,"Aliq. Cofins Retenção"		    )
    TRCell():New( oSection  ,"FT_VRETCOF"  ,cAliasTMP  ,"Valor Cofins Retenção"		    )
    TRCell():New( oSection  ,"LogInc"      ,cAliasTMP  ,"Log. de Inclusão"				)
    TRCell():New( oSection  ,"LogAlt"      ,cAliasTMP  ,"Log. de Alteração"			    )
    TRCell():New( oSection  ,"DtLogAlt"    ,cAliasTMP  ,"Dt. Log. de Alteração"		    )
    TRCell():New( oSection  ,"VV3_TIPVEN"  ,cAliasTMP  ,"Tipo Venda"					)
    TRCell():New( oSection  ,"VV3_DESCRI"  ,cAliasTMP  ,"Descr. Tipo Venda"			    )
    TRCell():New( oSection  ,"NumPed"      ,cAliasTMP  ,"Num. Pedido"					)
    TRCell():New( oSection  ,"Naturez"     ,cAliasTMP  ,"Natureza Financeira"			)
    TRCell():New( oSection  ,"C6_TNATREC"  ,cAliasTMP  ,"Tab. Nat. Receita"			    )
    TRCell():New( oSection  ,"D2_ITEMCC"   ,cAliasTMP  ,"Item Contábil"				    )
    TRCell():New( oSection  ,"F3_ISENICM"  ,cAliasTMP  ,"ICMS Isento"					)
    TRCell():New( oSection  ,"F3_OUTRICM"  ,cAliasTMP  ,"ICMS Outros"					)
    TRCell():New( oSection  ,"F3_ISENIPI"  ,cAliasTMP  ,"IPI Isento"					)
    TRCell():New( oSection  ,"F3_OUTRIPI"  ,cAliasTMP  ,"IPI Outros"					)
    TRCell():New( oSection  ,"Transp"      ,cAliasTMP  ,"Cód. Transportadora"			)
    TRCell():New( oSection  ,"VRJ_CLIRET"  ,cAliasTMP  ,"Cat. Local de Entrega"		    )
    TRCell():New( oSection  ,"NomLocEnt"   ,cAliasTMP  ,"Nome Loc. Entr."				)
    TRCell():New( oSection  ,"UFLocEnt"    ,cAliasTMP  ,"UF Loc. Entr."				    )
    TRCell():New( oSection  ,"MsgSefaz"    ,cAliasTMP  ,"Msgn Sefaz"					)
    TRCell():New( oSection  ,"F2_MENNOTA"  ,cAliasTMP  ,"Msgn Nota Fiscal"				)
    TRCell():New( oSection  ,"MenNota"     ,cAliasTMP  ,"Mens.p/Nota"					)
    TRCell():New( oSection  ,"MenPad"      ,cAliasTMP  ,"Mens. Padrão"					)
    TRCell():New( oSection  ,"MensNFS"     ,cAliasTMP  ,"Mensagem NFS"					)
    TRCell():New( oSection  ,"VlrTrib"     ,cAliasTMP  ,"Vlr. Aprox. dos Tributos"		)
    TRCell():New( oSection  ,"F4_DUPLIC"   ,cAliasTMP  ,"Gera Duplicata"				)
    //TRCell():New( oSection  ,"VRK_CHASSI"   ,cAliasTMP  ,"Chassi"				)
    
    //TRPosition():New( oSection,"SA2",1,{|| xFilial("SA2")+DCX->DCX_FORNEC+DCX->DCX_LOJA})	
    oReport:PrintDialog()
	                            	
Return

//----------------------------------------------------------
Static Function ReportPrint(oReport)
    Local oSection     := oReport:Section(1)
	Local cDescTipo		:= ""
	Local cLogInc 		:= ""
	Local cLogAlt 		:= ""
	Local cDtLogAlt		:= ""
	Local cSituacao		:= ""
	Local cComVei		:= ""
	Local cModVei		:= ""
	Local cDesMod		:= ""
	Local cCliFor		:= ""
	Local cCgcCpf		:= ""
	Local cIncEst		:= ""
	Local cEstCli		:= ""
	Local cCodMun		:= ""
	Local cTpCliFor		:= ""
	Local cTpPessoa		:= ""
	Local cTpNF			:= ""
	Local cNumPed 		:= ""
	Local nVlrFrete 	:= 0
	Local nVlrSeguro	:= 0
	Local nVlrDesp		:= 0
	Local cMenNota		:= ""
	Local cMenPad		:= ""
	Local cNaturez		:= ""
	Local cTransp		:= ""
	Local cMensNFS		:= ""
	Local cCGCLocEnt	:= ""
	Local cNomLocEnt	:= ""
	Local cUFLocEnt		:= "" 
	Local nVlIPIRegi	:= 0
	Local nVlIPIPres	:= 0
	
    //Monta Tmp
    zTmpRadio3()

	oReport:SetMeter( Contar(cAliasTMP,"!Eof()") )
	// Secção 1
	oSection:Init()

    VV2->( DbSetOrder(7) ) // VV2_FILIAL+VV2_PRODUT
    SF2->( DbSetOrder(2) ) // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
    SA1->( DbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA
    SA2->( DbSetOrder(1) ) // A2_FILIAL+A2_COD+A2_LOJA
    SC5->( DbSetOrder(1) ) // C5_FILIAL+C5_NUM
    CDA->( DbSetOrder(1) ) // CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+CDA_NUMITE

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()

        // Incrementa a mensagem na régua.
        oReport:IncMeter()

        // TRATAMENTO PARA BUSCAR O LOG DO USUÁRIO.
        cLogInc 	:= ""
        cLogAlt 	:= ""
        cDtLogAlt	:= ""
        If SF2->(dbSeek( (cAliasTMP)->D2_FILIAL + (cAliasTMP)->D2_CLIENTE + (cAliasTMP)->D2_LOJA + (cAliasTMP)->D2_DOC + (cAliasTMP)->D2_SERIE + (cAliasTMP)->F2_TIPO + (cAliasTMP)->F2_ESPECIE))
            cLogInc 	:= FWLeUserlg( "F2_USERLGI" )
            cLogAlt 	:= FWLeUserlg( "F2_USERLGA" )
            cDtLogAlt	:= FWLeUserlg( "F2_USERLGA", 2 )
        EndIf

        // Busca o Status da Nota Fiscal.
        cSituacao	:= ""
        Do Case
            Case (cAliasTMP)->F2_FIMP == " " .And. AllTrim( (cAliasTMP)->F2_ESPECIE ) == "SPED"
                cSituacao	:= "NF não transmitida"
            Case (cAliasTMP)->F2_FIMP == "S"
                cSituacao	:= "NF Autorizada"
            Case (cAliasTMP)->F2_FIMP == "T"
                cSituacao	:= "NF Transmitida"
            Case (cAliasTMP)->F2_FIMP == "D"
                cSituacao	:= "NF Uso Denegado"
            Case (cAliasTMP)->F2_FIMP == "N"
                cSituacao	:= "NF nao autorizada"
            OtherWise
                cSituacao	:= ""
        EndCase

        // Busca o Modelo do Veiculo
        cModVei		:= ""
        cDesMod		:= ""
        cComVei 	:= ""
        If VV2->(DbSeek( xFilial("VV2") + (cAliasTMP)->D2_COD ))
            cModVei	:= AllTrim( VV2->VV2_MODVEI )
            cDesMod	:= AllTrim( VV2->VV2_DESMOD )
            cComVei	:= X3Combo( "VV2_COMVEI"	,VV2->VV2_COMVEI	)			
        Endif

        cCliFor 	:= ""
        cCgcCpf		:= ""
        cIncEst		:= ""
        cDescTipo	:= ""
        cTpCliFor	:= ""
        cTpPessoa	:= ""
        If (cAliasTMP)->F2_TIPO $ "B|D" // Benefeciamento ou devolução
            If SA2->(DbSeek( xFilial("SA2") + (cAliasTMP)->D2_CLIENTE + (cAliasTMP)->D2_LOJA ))
                cCliFor		:= SA2->A2_NOME
                cIncEst 	:= SA2->A2_INSCR
                cCgcCpf 	:= IIF( Len( Alltrim( SA2->A2_CGC) )>11 ,Transform( SA2->A2_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA2->A2_CGC ,"@R 999.999.999-99" ) ) 
                cEstCli 	:= SA2->A2_EST
                cCodMun		:= SA2->A2_COD_MUN
                cTpCliFor	:= "Fornecedor"

                // Busca o Tipo do Fornecedor.
                If SA2->A2_TIPO == "J"
                    cDescTipo := "Juridico"
                ElseIf SA2->A2_TIPO == "F"
                    cDescTipo := "Fisico"
                ElseIf SA2->A2_TIPO == "X"
                    cDescTipo := "Outros"
                Else
                    cDescTipo := ""
                Endif

                cTpPessoa := cDescTipo

            Else
                cCliFor		:= "FORNECEDOR NÃO ENCONTRADO NA BASE DE DADOS"
                cIncEst 	:= ""
                cCgcCpf 	:= ""
                cDescTipo	:= ""
                cEstCli		:= ""
                cCodMun		:= ""
                cTpCliFor	:= "Fornecedor"
                cTpPessoa	:= ""
            EndIf
        Else
            If SA1->(DbSeek( xFilial("SA1") + (cAliasTMP)->D2_CLIENTE + (cAliasTMP)->D2_LOJA ))
                cCliFor		:= SA1->A1_NOME
                cIncEst 	:= SA1->A1_INSCR
                cCgcCpf 	:= IIF( Len( Alltrim( SA1->A1_CGC) )>11 ,Transform( SA1->A1_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA1->A1_CGC ,"@R 999.999.999-99" ) ) 
                cEstCli		:= SA1->A1_EST
                cCodMun		:= SA1->A1_COD_MUN
                cTpCliFor	:= "Cliente"

                If SA1->A1_PESSOA == "J"
                    cTpPessoa := "Juridico"
                ElseIf SA1->A1_PESSOA == "F"
                    cTpPessoa := "Fisico"
                Else
                    cTpPessoa := ""
                Endif

                // Busca o Tipo do Cliente.
                Do Case
                    Case SA1->A1_TIPO == "F"
                        cDescTipo	:= "Cons.Final"
                    Case SA1->A1_TIPO == "L"
                        cDescTipo	:= "Produtor Rural"
                    Case SA1->A1_TIPO == "R"
                        cDescTipo	:= "Revendedor"
                    Case SA1->A1_TIPO == "S"
                        cDescTipo	:= "Solidario"
                    Case SA1->A1_TIPO == "X"
                        cDescTipo	:= "Exportacao"
                    OtherWise
                        cDescTipo	:= ""
                EndCase

            Else
                cCliFor		:= "CLIENTE NÃO ENCONTRADO NA BASE DE DADOS"
                cIncEst 	:= ""
                cCgcCpf		:= ""
                cDescTipo	:= ""
                cEstCli		:= ""
                cCodMun		:= ""
                cTpCliFor	:= "Cliente"
                cTpPessoa	:= ""
            EndIf
        EndIf

        cCGCLocEnt := ""
        cNomLocEnt := ""
        cUFLocEnt  := ""

        //--Necessario essa redundancia porque o cliente da nota não sera o cliente de retirada na maioria dos casos
        //--Grava registros de cliente/fornecedor quando informados no pedido de venda do SIGAVEI, campo VRJ_CLIRET
        If !Empty( (cAliasTMP)->VRJ_CLIRET )
            If (cAliasTMP)->F2_TIPO $ "B|D" // Benefeciamento ou devolução
                If SA2->( DbSeek( FWxFilial('SA2') + (cAliasTMP)->VRJ_CODCLI + (cAliasTMP)->VRJ_LOJA ) )
                    cCGCLocEnt := IIF( Len( Alltrim( SA2->A2_CGC) )>11 ,Transform( SA2->A2_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA2->A2_CGC ,"@R 999.999.999-99" ) ) 
                    cNomLocEnt := SA2->A2_NOME
                    cUFLocEnt  := SA2->A2_EST
                EndIf
            Else
                If SA1->( DbSeek( FWxFilial('SA1') + (cAliasTMP)->VRJ_CODCLI + (cAliasTMP)->VRJ_LOJA ) )	
                    cCGCLocEnt := IIF( Len( Alltrim( SA1->A1_CGC) )>11 ,Transform( SA1->A1_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA1->A1_CGC ,"@R 999.999.999-99" ) ) 
                    cNomLocEnt := SA1->A1_NOME
                    cUFLocEnt  := SA2->A2_EST
                EndIf
            EndIf
        EndIf

        //Verifica o tipo da Nota Fiscal
        cTpNF := ""
        Do Case
            Case (cAliasTMP)->F2_TIPO == "N"
                cTpNF	:= "NF Normal"
            Case (cAliasTMP)->F2_TIPO == "P"
                cTpNF	:= "NF de Compl. IPI"
            Case (cAliasTMP)->F2_TIPO== "I"
                cTpNF	:= "NF de Compl. ICMS"
            Case (cAliasTMP)->F2_TIPO == "C"
                cTpNF	:= "NF de Complemento"
            Case (cAliasTMP)->F2_TIPO == "B"
                cTpNF	:= "NF de Beneficiamento"
            Case (cAliasTMP)->F2_TIPO == "D"
                cTpNF	:= "NF de Devolucao"
            OtherWise
                cTpNF	:= "Tipo não encontrado"
        EndCase

        //-- Retorna dados do pedido
        cNumPed 	:= ""
        nVlrFrete 	:= 0
        nVlrSeguro	:= 0
        nVlrDesp	:= 0
        cMenNota	:= ""
        cMenPad		:= ""
        cNaturez	:= ""
        cTransp		:= ""
        cMensNFS	:= ""

        If SC5->( DbSeek( (cAliasTMP)->C6_FILIAL + (cAliasTMP)->C6_NUM ) )
            cNumPed 	:= SC5->C5_NUM
            nVlrFrete 	:= SC5->C5_FRETE
            nVlrSeguro	:= SC5->C5_SEGURO
            nVlrDesp	:= SC5->C5_DESPESA
            cMenNota	:= AllTrim( SC5->C5_MENNOTA )
            cMenPad		:= AllTrim( SC5->C5_MENPAD )
            cNaturez	:= AllTrim( SC5->C5_NATUREZ )
            cTransp		:= AllTrim( SC5->C5_TRANSP )
            cMensNFS	:= AllTrim( SC5->C5_XMENSER )	
        EndIf

        nVlIPIRegi := 0
        nVlIPIPres := 0
        //-- Retorna Valor de IPI regional e presumido
        zRel0003(@nVlIPIRegi, @nVlIPIPres, (cAliasTMP)->F2_ESPECIE, (cAliasTMP)->F2_DOC, (cAliasTMP)->F2_SERIE,;
                (cAliasTMP)->D2_CLIENTE, (cAliasTMP)->D2_LOJA, (cAliasTMP)->D2_ITEM )	

        oSection:Cell( "CgcCpf"      ):SetValue( cCgcCpf     ) //--Cnpj/Cpf
        oSection:Cell( "CGCLocEnt"   ):SetValue( cCGCLocEnt  ) //--CNPJ Loc. Entr.
        oSection:Cell( "IncEst"      ):SetValue( cIncEst     ) //--Insc.Estadual
        oSection:Cell( "TpPessoa"    ):SetValue( cTpPessoa   ) //--Pessoa Fisica/Juridica
        oSection:Cell( "EstCli"      ):SetValue( cEstCli     ) //--UF
        oSection:Cell( "D2_TES"      ):SetValue( (cAliasTMP)->D2_TES ) //--Tes
        oSection:Cell( "F4_FINALID"  ):SetValue( Alltrim( (cAliasTMP)->F4_FINALID ) ) //--Finalidade TES
        oSection:Cell( "B1_ORIGEM"   ):SetValue( AllTrim( (cAliasTMP)->B1_ORIGEM ) ) //--Origem do Produto
        oSection:Cell( "B1_POSIPI"   ):SetValue( AllTrim( (cAliasTMP)->B1_POSIPI ) ) //--NCM
        oSection:Cell( "B1_EX_NBM"   ):SetValue( AllTrim( (cAliasTMP)->B1_EX_NBM ) ) //--Ex-NBM
        oSection:Cell( "ModVei"      ):SetValue( AllTrim( cModVei ) ) //--Modelo Veículo
        oSection:Cell( "VRK_OPCION"  ):SetValue( AllTrim( (cAliasTMP)->VRK_OPCION ) ) //--Opcional
        oSection:Cell( "B1_GRUPO"    ):SetValue( AllTrim( (cAliasTMP)->B1_GRUPO ) ) //--Grupo\Linha
        oSection:Cell( "BM_DESC"     ):SetValue( AllTrim( Posicione("SBM",1,xFilial("SBM")+(cAliasTMP)->B1_GRUPO,"BM_DESC") ) ) //--Descrição do Grupo
        //oSection:Cell( "D2_TOTAL"    ):SetValue( (cAliasTMP)->D2_TOTAL ) //--Valor Total Item
        oSection:Cell( "D2_TOTAL"    ):SetValue( ((cAliasTMP)->D2_TOTAL )+(cAliasTMP)->D2_DESCON )  //--Valor Total Item
        oSection:Cell( "D2_CF"       ):SetValue( (cAliasTMP)->D2_CF ) //--Cfop
        oSection:Cell( "FT_VALCONT"  ):SetValue( (cAliasTMP)->FT_VALCONT ) //--Valor Contábil
        oSection:Cell( "FT_BASEICM"  ):SetValue( (cAliasTMP)->FT_BASEICM ) //--Base ICMS
        oSection:Cell( "FT_ALIQICM"  ):SetValue( (cAliasTMP)->FT_ALIQICM ) //--Aliq. ICMS
        oSection:Cell( "FT_VALICM"   ):SetValue( (cAliasTMP)->FT_VALICM ) //--Valor ICMS
        oSection:Cell( "C6_XVLCOM"   ):SetValue( (cAliasTMP)->C6_XVLCOM ) //--Comissão
        oSection:Cell( "FT_BASEIPI"  ):SetValue( (cAliasTMP)->FT_BASEIPI ) //--Base IPI
        oSection:Cell( "FT_ALIQIPI"  ):SetValue( (cAliasTMP)->FT_ALIQIPI ) //--Aliq. IPI
        oSection:Cell( "FT_VALIPI"   ):SetValue( (cAliasTMP)->FT_VALIPI ) //--Valor IPI
        oSection:Cell( "VlIPIRegi"   ):SetValue( nVlIPIRegi ) //--Credito_Regional IPI
        oSection:Cell( "VlIPIPres"   ):SetValue( nVlIPIPres ) //--Credito_Presumido IPI/Frete
        oSection:Cell( "FT_BASERET"  ):SetValue( (cAliasTMP)->FT_BASERET ) //--Base Subst
        oSection:Cell( "FT_ICMSRET"  ):SetValue( (cAliasTMP)->FT_ICMSRET ) //--Valor Subst
        oSection:Cell( "FT_BASEPIS"  ):SetValue( (cAliasTMP)->FT_BASEPIS ) //--Base Pis Apuração
        oSection:Cell( "FT_ALIQPIS"  ):SetValue( (cAliasTMP)->FT_ALIQPIS ) //--Aliq. Pis Apuração
        oSection:Cell( "FT_VALPIS"   ):SetValue( (cAliasTMP)->FT_VALPIS ) //--Valor Pis Apuração
        oSection:Cell( "FT_BASECOF"  ):SetValue( (cAliasTMP)->FT_BASECOF ) //--Base Cofins Apuração
        oSection:Cell( "FT_ALIQCOF"  ):SetValue( (cAliasTMP)->FT_ALIQCOF ) //--Aliq. Cofins Apuração
        oSection:Cell( "FT_VALCOF"   ):SetValue( (cAliasTMP)->FT_VALCOF ) //--Valor Cofins Apuração
        oSection:Cell( "FT_BASEPS3"  ):SetValue( (cAliasTMP)->FT_BASEPS3 ) //--Base Pis ST ZFM
        oSection:Cell( "FT_ALIQPS3"  ):SetValue( (cAliasTMP)->FT_ALIQPS3 ) //--Aliq. Pis ST ZFM
        oSection:Cell( "FT_VALPS3"   ):SetValue( (cAliasTMP)->FT_VALPS3 ) //--Vl. Pis ST ZFM
        oSection:Cell( "FT_BASECF3"  ):SetValue( (cAliasTMP)->FT_BASECF3 ) //--Base Cof ST ZFM
        oSection:Cell( "FT_ALIQCF3"  ):SetValue( (cAliasTMP)->FT_ALIQCF3 ) //--Aliq. Cof ST ZFM
        oSection:Cell( "FT_VALCF3"   ):SetValue( (cAliasTMP)->FT_VALCF3 ) //--Vl. Cof ST ZFM
        oSection:Cell( "FT_DIFAL"    ):SetValue( (cAliasTMP)->FT_DIFAL ) //--ICMS Difal
        oSection:Cell( "FT_CLASFIS"  ):SetValue( (cAliasTMP)->FT_CLASFIS ) //--CST ICMS
        oSection:Cell( "FT_CTIPI"    ):SetValue( (cAliasTMP)->FT_CTIPI ) //--CST IPI
        oSection:Cell( "FT_CSTPIS"   ):SetValue( (cAliasTMP)->FT_CSTPIS ) //--CST PIS
        oSection:Cell( "FT_CSTCOF"   ):SetValue( (cAliasTMP)->FT_CSTCOF ) //--CST COFINS
        oSection:Cell( "F4_ICM"      ):SetValue( (cAliasTMP)->F4_ICM ) //--Calcula ICMS
        oSection:Cell( "F4_CREDICM"  ):SetValue( (cAliasTMP)->F4_CREDICM ) //--Credita ICMS
        oSection:Cell( "F4_IPI"      ):SetValue( (cAliasTMP)->F4_IPI ) //--Calcula IPI
        oSection:Cell( "F4_CREDIPI"  ):SetValue( (cAliasTMP)->F4_CREDIPI ) //--Credita IPI
        oSection:Cell( "D2_DOC"      ):SetValue( (cAliasTMP)->D2_DOC ) //--Nota Fiscal
        oSection:Cell( "NfPref"      ):SetValue( IIF( AllTrim( (cAliasTMP)->F2_ESPECIE ) == 'NFS', (cAliasTMP)->D2_DOC, "" ) ) //--Nf. Prefeitura
        oSection:Cell( "D2_SERIE"    ):SetValue( (cAliasTMP)->D2_SERIE ) //--Série
        oSection:Cell( "F2_ESPECIE"  ):SetValue( (cAliasTMP)->F2_ESPECIE ) //--Espécie
        oSection:Cell( "ModNot"      ):SetValue( AModNot( (cAliasTMP)->F2_ESPECIE ) ) //--Modelo
        oSection:Cell( "D2_EMISSAO"  ):SetValue( IIF( Empty( SToD( (cAliasTMP)->D2_EMISSAO ) ), "", SToD( (cAliasTMP)->D2_EMISSAO ) ) ) //--Dt. de Emissão
        oSection:Cell( "D2_CLIENTE"  ):SetValue( (cAliasTMP)->D2_CLIENTE ) //--Cliente\Fornecedor
        oSection:Cell( "D2_LOJA"     ):SetValue( (cAliasTMP)->D2_LOJA ) //--Loja
        oSection:Cell( "CliFor"      ):SetValue( cCliFor ) //--Nome
        oSection:Cell( "C6_CHASSI"   ):SetValue( AllTrim( (cAliasTMP)->C6_CHASSI ) ) //--Chassi
        oSection:Cell( "D2_COD"      ):SetValue( (cAliasTMP)->D2_COD ) //--Cód.Produto
        oSection:Cell( "B1_DESC"     ):SetValue( Substr( (cAliasTMP)->B1_DESC,1,20 ) ) //--Descrição do Produto
        oSection:Cell( "B5_CEME"     ):SetValue( AllTrim( Posicione("SB5",1,xFilial("SB5")+(cAliasTMP)->D2_COD,"B5_CEME") ) ) //--Descrição Científico
        oSection:Cell( "B1_XDESCL1"  ):SetValue( AllTrim( (cAliasTMP)->B1_XDESCL1 ) ) //--Descrição Longa
        oSection:Cell( "D2_UM"       ):SetValue( (cAliasTMP)->D2_UM ) //--Un Medida
        oSection:Cell( "D2_QUANT"    ):SetValue( (cAliasTMP)->D2_QUANT ) //--Quant
        oSection:Cell( "D2_PRUNIT"   ):SetValue( (cAliasTMP)->D2_PRUNIT ) //--Valor Unit. Item
      //oSection:Cell( "D2_DESC"     ):SetValue( (cAliasTMP)->D2_DESC ) //--Desconto Item
        oSection:Cell( "D2_DESCON"   ):SetValue( (cAliasTMP)->D2_DESCON ) //--Desconto Item
        oSection:Cell( "VlrFrete"    ):SetValue( nVlrFrete ) //--Frete
        oSection:Cell( "VlrSeguro"   ):SetValue( nVlrSeguro ) //--Seguro
        oSection:Cell( "VlrDesp"     ):SetValue( nVlrDesp ) //--Despesas
        oSection:Cell( "D2_CUSTO1"   ):SetValue( (cAliasTMP)->D2_CUSTO1 ) //--Custo
        oSection:Cell( "D2_CONTA"    ):SetValue( (cAliasTMP)->D2_CONTA ) //--Conta Contábil
        oSection:Cell( "CT1_DESC01"  ):SetValue( AllTrim( Posicione("CT1",1,xFilial("CT1")+(cAliasTMP)->D2_CONTA,"CT1_DESC01" ) ) ) //--Desc.Conta Contábil
        oSection:Cell( "D2_FILIAL"   ):SetValue( AllTrim( (cAliasTMP)->D2_FILIAL ) ) //--Empresa
        oSection:Cell( "Situacao"    ):SetValue( cSituacao ) //--Situação
        oSection:Cell( "TpNF"        ):SetValue( cTpNF ) //--Tipo Nota Fiscal
        oSection:Cell( "FT_CHVNFE"   ):SetValue( (cAliasTMP)->FT_CHVNFE ) //--Chave Nota Fiscal
        oSection:Cell( "D2_NFORI"    ):SetValue( AllTrim( (cAliasTMP)->D2_NFORI ) + " - " + AllTrim( (cAliasTMP)->D2_SERIORI ) ) //--Nota Fiscal Origem
        oSection:Cell( "DescTipo"    ):SetValue( cDescTipo ) //--Tipo Cli\For
        oSection:Cell( "TpCliFor"    ):SetValue( cTpCliFor ) //--Cli\For
        oSection:Cell( "X5_DESCRI"   ):SetValue( AllTrim( Posicione("SX5" ,1 ,xFilial("SX5") + "12" + cEstCli,"X5_DESCRI") ) ) //--Estado
        oSection:Cell( "CC2_MUN"     ):SetValue( AllTrim( Posicione("CC2" ,1 ,xFilial("CC2") + cEstCli + PadR( cCodMun ,TamSx3("CC2_CODMUN")[1] ) , "CC2_MUN" ) ) ) //--Município
        oSection:Cell( "B1_CEST"     ):SetValue( AllTrim( (cAliasTMP)->B1_CEST ) ) //--CEST
        oSection:Cell( "DesMod"      ):SetValue( AllTrim( cDesMod ) ) //--Descr. Modelo Veículo
        oSection:Cell( "ComVei"      ):SetValue( AllTrim( cComVei ) ) //--Combustível Veículo
        oSection:Cell( "F4_TEXTO"    ):SetValue( AllTrim( (cAliasTMP)->F4_TEXTO ) ) //--Descrição CFOP
        oSection:Cell( "F2_CODNFE"   ):SetValue( (cAliasTMP)->F2_CODNFE ) //--Cód.Verificação
        oSection:Cell( "FT_BASEIRR"  ):SetValue( (cAliasTMP)->FT_BASEIRR ) //--Base Irrf Retenção
        oSection:Cell( "FT_ALIQIRR"  ):SetValue( (cAliasTMP)->FT_ALIQIRR ) //--Aliq. Irrf Retenção
        oSection:Cell( "FT_VALIRR"   ):SetValue( (cAliasTMP)->FT_VALIRR ) //--Irrf Retenção
        oSection:Cell( "FT_BASEINS"  ):SetValue( (cAliasTMP)->FT_BASEINS ) //--Base Inss
        oSection:Cell( "FT_ALIQINS"  ):SetValue( (cAliasTMP)->FT_ALIQINS ) //--Aliq. Inss
        oSection:Cell( "D2_ABATINS"  ):SetValue( (cAliasTMP)->D2_ABATINS ) //--Inss Recolhido
        oSection:Cell( "FT_VALINS"   ):SetValue( (cAliasTMP)->FT_VALINS ) //--Valor Inss
        oSection:Cell( "D2_BASEISS"  ):SetValue( (cAliasTMP)->D2_BASEISS ) //--Base Iss
        oSection:Cell( "D2_ALIQISS"  ):SetValue( (cAliasTMP)->D2_ALIQISS ) //--Aliq. Iss
        oSection:Cell( "D2_ABATISS"  ):SetValue( (cAliasTMP)->D2_ABATISS ) //--Iss Serviços
        oSection:Cell( "D2_ABATMAT"  ):SetValue( (cAliasTMP)->D2_ABATMAT ) //--Iss Materiais
        oSection:Cell( "D2_VALISS"   ):SetValue( (cAliasTMP)->D2_VALISS ) //--Valor Iss
        oSection:Cell( "FT_BASECSL"  ):SetValue( (cAliasTMP)->FT_BASECSL ) //--Base Csll
        oSection:Cell( "FT_ALIQCSL"  ):SetValue( IIF( (cAliasTMP)->FT_BASECSL > 0, (cAliasTMP)->FT_ALIQCSL, 0 ) ) //--Aliq. Csll
        oSection:Cell( "FT_VALCSL"   ):SetValue( (cAliasTMP)->FT_VALCSL ) //--Valor Csll
        oSection:Cell( "FT_BRETPIS"  ):SetValue( (cAliasTMP)->FT_BRETPIS ) //--Base Pis Retenção
        oSection:Cell( "FT_ARETPIS"  ):SetValue( IIF( (cAliasTMP)->FT_BRETPIS > 0, (cAliasTMP)->FT_ARETPIS, 0 ) ) //--Aliq. Pis Retenção
        oSection:Cell( "FT_VRETPIS"  ):SetValue( (cAliasTMP)->FT_VRETPIS ) //--Valor Pis Retenção
        oSection:Cell( "FT_BRETCOF"  ):SetValue( (cAliasTMP)->FT_BRETCOF ) //--Base Cofins Retenção
        oSection:Cell( "FT_ARETCOF"  ):SetValue( IIF( (cAliasTMP)->FT_BRETCOF > 0, (cAliasTMP)->FT_ARETCOF, 0 ) ) //--Aliq. Cofins Retenção
        oSection:Cell( "FT_VRETCOF"   ):SetValue( (cAliasTMP)->FT_VRETCOF ) //--Valor Cofins Retenção
        oSection:Cell( "LogInc"      ):SetValue( cLogInc ) //--Log. de Inclusão
        oSection:Cell( "LogAlt"      ):SetValue( cLogAlt ) //--Log. de Alteração
        oSection:Cell( "DtLogAlt"    ):SetValue( cDtLogAlt ) //--Dt. Log. de Alteração
        oSection:Cell( "VV3_TIPVEN"  ):SetValue( AllTrim( (cAliasTMP)->VV3_TIPVEN ) ) //--Tipo Venda
        oSection:Cell( "VV3_DESCRI"  ):SetValue( AllTrim( (cAliasTMP)->VV3_DESCRI ) ) //--Descr. Tipo Venda
        oSection:Cell( "NumPed"      ):SetValue( cNumPed ) //--Num. Pedido
        oSection:Cell( "Naturez"     ):SetValue( cNaturez ) //--Natureza Financeira
        oSection:Cell( "C6_TNATREC"  ):SetValue( AllTrim( (cAliasTMP)->C6_TNATREC ) ) //--Tab. Nat. Receita
        oSection:Cell( "D2_ITEMCC"   ):SetValue( AllTrim( (cAliasTMP)->D2_ITEMCC ) ) //--Item Contábil
        oSection:Cell( "F3_ISENICM"  ):SetValue( (cAliasTMP)->F3_ISENICM ) //--ICMS Isento
        oSection:Cell( "F3_OUTRICM"  ):SetValue( (cAliasTMP)->F3_OUTRICM ) //--ICMS Outros
        oSection:Cell( "F3_ISENIPI"  ):SetValue( (cAliasTMP)->F3_ISENIPI ) //--IPI Isento
        oSection:Cell( "F3_OUTRIPI"  ):SetValue( (cAliasTMP)->F3_OUTRIPI ) //--IPI Outros
        oSection:Cell( "Transp"      ):SetValue( cTransp ) //--Cód. Transportadora
        oSection:Cell( "VRJ_CLIRET"  ):SetValue( (cAliasTMP)->VRJ_CLIRET ) //--Cat. Local de Entrega
        oSection:Cell( "NomLocEnt"   ):SetValue( cNomLocEnt ) //--Nome Loc. Entr.
        oSection:Cell( "UFLocEnt"    ):SetValue( cUFLocEnt ) //--UF Loc. Entr.
        oSection:Cell( "F2_MENNOTA"  ):SetValue( (cAliasTMP)->F2_MENNOTA ) //--Msgn Nota Fiscal   
        oSection:Cell( "MenNota"     ):SetValue( cMenNota ) //--Mens.p/Nota
        oSection:Cell( "MenPad"      ):SetValue( cMenPad ) //--Mens. Padrão
        oSection:Cell( "MensNFS"     ):SetValue( cMensNFS ) //--Mensagem NFS	
        oSection:Cell( "VlrTrib"     ):SetValue( (cAliasTMP)->( F2_TOTFED + F2_TOTEST ) ) //--Vlr. Aprox. dos Tributos	
        oSection:Cell( "F4_DUPLIC"   ):SetValue( Alltrim( (cAliasTMP)->F4_DUPLIC ) ) //--Gera Duplicata   
        //oSection:Cell( "WRK_CHASSI"  ):SetValue( Alltrim( (cAliasTMP)->VRK_CHASSI ) ) //--Gera Duplicata   


        oSection:PrintLine()

        (cAliasTMP)->(DbSkip())

    EndDo
    oSection:Finish()	

Return

//----------------------------------------------------------
Static Function zTmpRadio3()
    Local cQuery    := ""
    
	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea()) 
	EndIf

    cQuery += " SELECT D2_FILIAL, D2_COD, D2_DOC,D2_SERIE, D2_TES, D2_CF,D2_CLIENTE,D2_LOJA,D2_EMISSAO, D2_ITEMPV, "		+ CRLF
	cQuery += " F4_FINALID, F4_TEXTO, FT_CTIPI, FT_CSTPIS, FT_CSTCOF, F4_ICM, F4_IPI, F4_CREDICM, F4_CREDIPI, F4_DUPLIC, "	+ CRLF
	cQuery += " B1_DESC, B1_XDESCL1, B1_GRUPO, B1_POSIPI, B1_CEST, B1_ORIGEM, B1_EX_NBM, D2_ITEM, "							+ CRLF
	cQuery += " F2_ESPECIE,F2_CODNFE,F2_MENNOTA,F2_USERLGI,F2_USERLGA,F2_TIPO, FT_CHVNFE,F2_DOC, F2_SERIE, F2_FIMP,  " 		+ CRLF
	cQuery += " FT_VALCONT, F2_FORMUL, D2_CONTA, D2_NFORI, D2_SERIORI, D2_PRUNIT,D2_TOTAL, "								+ CRLF
	cQuery += " D2_DESC, D2_DESCON, FT_CLASFIS, D2_DESCZFP, D2_DESCZFC, D2_TIPO, "											+ CRLF
	cQuery += " FT_BASEICM, FT_ALIQICM, FT_VALICM, C6_CHASSI, "																+ CRLF
	cQuery += " FT_BASEIPI, FT_ALIQIPI, FT_VALIPI, FT_BRETPIS, FT_ARETPIS, FT_VRETPIS, FT_BRETCOF, FT_ARETCOF, FT_VRETCOF, "+ CRLF
	cQuery += " FT_BASERET, FT_ICMSRET, FT_DIFAL, "																			+ CRLF
	cQuery += " D2_BASIMP6,D2_ALQIMP6,D2_VALIMP6,   " 																		+ CRLF
	cQuery += " D2_BASIMP5,D2_ALQIMP5,D2_VALIMP5, " 											                            + CRLF
	cQuery += " FT_BASEPIS,FT_ALIQPIS,FT_VALPIS, F2_TOTFED, F2_TOTEST, "													+ CRLF
	cQuery += " FT_BASECOF,FT_ALIQCOF,FT_VALCOF, FT_BASECF3, FT_ALIQCF3, FT_VALCF3, FT_BASEPS3, FT_ALIQPS3, FT_VALPS3, "	+ CRLF
	cQuery += " FT_BASEIRR,FT_ALIQIRR,FT_VALIRR, F3_OUTRIPI, F3_ISENIPI, F3_OUTRICM, F3_ISENICM,  "							+ CRLF
	cQuery += " FT_BASEINS,FT_ALIQINS,D2_ABATINS,FT_VALINS, D2_UM, D2_QUANT, "												+ CRLF
	cQuery += " D2_BASEISS,D2_ALIQISS,D2_ABATISS,D2_ABATMAT,D2_VALISS, D2_ITEMCC, "											+ CRLF
	cQuery += " FT_BASECSL,FT_ALIQCSL,FT_VALCSL, D2_CUSTO1, VRK_CHASSI, VRJ_CODCLI, VRJ_LOJA, C6_XVLCOM, "					+ CRLF
	cQuery += " C6_TNATREC, C6_NFORI, C6_FILIAL, C6_NUM, VV3_TIPVEN, VV3_DESCRI, VRJ_CLIRET, VRK_OPCION "		            + CRLF
	cQuery += " FROM   " + RetSQLName("SD2") + " SD2   " 																	+ CRLF
	
	cQuery += "	INNER JOIN " + RetSQLName("SF2") + " SF2 "																    + CRLF
	cQuery += "		ON SF2.F2_FILIAL = '" + FWxFilial('SF2') + "' "													        + CRLF
	cQuery += "		AND SD2.D2_DOC = SF2.F2_DOC   " 																	    + CRLF
	cQuery += "		AND SD2.D2_SERIE = SF2.F2_SERIE   " 																    + CRLF
	cQuery += "		AND SD2.D2_CLIENTE = SF2.F2_CLIENTE   " 															    + CRLF
	cQuery += "		AND SD2.D2_LOJA = SF2.F2_LOJA   " 																	    + CRLF
	cQuery += "		AND SD2.D2_EMISSAO = SF2.F2_EMISSAO   " 															    + CRLF
	cQuery += "		AND SF2.F2_ESPECIE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " 								    + CRLF
	cQuery += "		AND SF2.D_E_L_E_T_ = ' '   "	 																	    + CRLF

	If !Empty( MV_PAR17 )
		cQuery += " 	AND SF2.F2_EST = '" + MV_PAR17 + "' " 															    + CRLF
	EndIf
	
	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 " 												 				    + CRLF
	cQuery += "		ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "													        + CRLF
	cQuery += "		AND SB1.B1_COD = SD2.D2_COD   "	 																	    + CRLF
	cQuery += "		AND SB1.D_E_L_E_T_ = ' ' " 																			    + CRLF

	If !Empty( MV_PAR18 )
		cQuery += " 	AND SB1.B1_GRUPO = '" + MV_PAR18 + "' "															    + CRLF
	EndIf

	If !Empty( MV_PAR19 )
		cQuery += " 	AND SB1.B1_POSIPI = '" + MV_PAR19 + "' "														    + CRLF
	EndIf

	cQuery += " INNER JOIN " + RetSQLName("SF4") + " SF4 "																    + CRLF
	cQuery += "		ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "'  "												        + CRLF
	cQuery += "		AND SF4.F4_CODIGO = SD2.D2_TES  "	 																    + CRLF
	cQuery += "     AND SF4.D_E_L_E_T_ = ' '   " 																		    + CRLF
	
	cQuery += " LEFT JOIN " + RetSQLName("SC6") + " SC6 "																    + CRLF
	cQuery += "		ON SC6.C6_FILIAL = '" + FWxFilial('SC6') + "' "													        + CRLF
	cQuery += "		AND SC6.C6_NUM = SD2.D2_PEDIDO  "																	    + CRLF
	cQuery += "		AND SC6.C6_ITEM = SD2.D2_ITEMPV  "		 															    + CRLF
	cQuery += "		AND SC6.C6_PRODUTO = SD2.D2_COD "		 															    + CRLF
	cQuery += "     AND SC6.D_E_L_E_T_ = ' '   " 																		    + CRLF
	
	cQuery += " LEFT JOIN " + RetSQLName("VV0") + " VV0 "																    + CRLF
	cQuery += "		ON VV0.VV0_FILIAL = '" + FWxFilial('VV0') + "' "												        + CRLF
	cQuery += "		AND VV0.VV0_NUMNFI = SF2.F2_DOC  "	 																    + CRLF
	cQuery += "		AND VV0.VV0_SERNFI = SF2.F2_SERIE  "																    + CRLF
	cQuery += "     AND VV0.D_E_L_E_T_ = ' '   " 																		    + CRLF
	
	cQuery += " LEFT JOIN " + RetSQLName("VV3") + " VV3 "																    + CRLF
	cQuery += "		ON VV3.VV3_FILIAL = '" + FWxFilial('VV3') + "' " 												        + CRLF
	cQuery += " 	AND VV3.VV3_TIPVEN = VV0.VV0_TIPVEN  "			 													    + CRLF
	cQuery += "     AND VV3.D_E_L_E_T_ = ' '   " 																		    + CRLF

	cQuery += " LEFT JOIN " + RetSQLName("VRK") + " VRK "																    + CRLF
	cQuery += " 	ON VRK.VRK_FILIAL = '" + FWxFilial('VRK') + "' "  												        + CRLF
	cQuery += " 	AND VRK.VRK_NUMTRA = VV0.VV0_NUMTRA  "			 													    + CRLF
	cQuery += "     AND VRK.D_E_L_E_T_ = ' '   " 																		    + CRLF

	cQuery += " LEFT JOIN " + RetSQLName("VRJ") + " VRJ "																    + CRLF
	cQuery += " 	ON VRJ.VRJ_FILIAL = '" + FWxFilial('VRJ') + "' "  												        + CRLF
	cQuery += " 	AND VRJ.VRJ_PEDIDO = VRK.VRK_PEDIDO  "			 													    + CRLF
	cQuery += "     AND VRJ.D_E_L_E_T_ = ' '   " 																		    + CRLF

	cQuery += " INNER JOIN " + RetSQLName("SFT") + " SFT " 																    + CRLF
	cQuery += "		ON SFT.FT_FILIAL = '" + FWxFilial('SFT') + "' "													        + CRLF
	cQuery += "		AND SFT.FT_TIPOMOV = 'S' "																			    + CRLF
	cQuery += "		AND SFT.FT_SERIE = SD2.D2_SERIE "																	    + CRLF
	cQuery += " 	AND SFT.FT_NFISCAL = SD2.D2_DOC "																	    + CRLF
	cQuery += "		AND SFT.FT_CLIEFOR = SD2.D2_CLIENTE " 																    + CRLF
	cQuery += "		AND SFT.FT_LOJA = SD2.D2_LOJA " 																	    + CRLF
	cQuery += "		AND SFT.FT_ITEM = SD2.D2_ITEM " 																	    + CRLF
	cQuery += "		AND SFT.FT_PRODUTO = SD2.D2_COD " 																	    + CRLF	
	cQuery += "		AND SFT.D_E_L_E_T_ = ' ' "																			    + CRLF

	cQuery += " INNER JOIN " + RetSQLName("SF3") + " SF3 " 																    + CRLF
	cQuery += "		ON SF3.F3_FILIAL = '" + FWxFilial('SF3') + "' "	 												        + CRLF
	cQuery += "		AND SF3.F3_SERIE = SFT.FT_SERIE "																	    + CRLF
	cQuery += "		AND SF3.F3_NFISCAL = SFT.FT_NFISCAL "																    + CRLF
	cQuery += " 	AND SF3.F3_CLIEFOR = SFT.FT_CLIEFOR "																    + CRLF
	cQuery += "		AND SF3.F3_LOJA = SFT.FT_LOJA " 																	    + CRLF
	cQuery += "		AND SF3.F3_IDENTFT = SFT.FT_IDENTF3 " 																    + CRLF
	cQuery += "		AND SF3.D_E_L_E_T_ = ' ' "																			    + CRLF

	cQuery += " WHERE  SD2.D2_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "								    + CRLF
	cQuery += " 	AND SD2.D2_DOC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " 									    + CRLF
	cQuery += " 	AND SD2.D2_SERIE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " 								    + CRLF
	cQuery += " 	AND SD2.D2_CLIENTE BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " 								    + CRLF
	cQuery += " 	AND SD2.D2_EMISSAO BETWEEN '" + DToS(MV_PAR11) + "' AND '" + DToS(MV_PAR12) + "' " 					    + CRLF
	cQuery += " 	AND SD2.D2_COD BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' " 									    + CRLF
	cQuery += " 	AND SD2.D_E_L_E_T_ = ' ' " 																			    + CRLF

	If !Empty( MV_PAR15 )
		cQuery += " 	AND SD2.D2_TES = '" + MV_PAR15 + "' " 															    + CRLF
	EndIf

	If !Empty( MV_PAR16 )
		cQuery += " 	AND SD2.D2_CF = '" + MV_PAR16 + "' " 															    + CRLF
	EndIf  

    If !Empty( MV_PAR20 ) .OR. !Empty( MV_PAR21)
	   cQuery += " 	AND SC6.C6_CHASSI  BETWEEN '" + MV_PAR20 + "' AND '" + MV_PAR21 + "' " 															    + CRLF
    Endif

	cQuery += " GROUP BY D2_FILIAL, D2_COD, D2_DOC,D2_SERIE, D2_TES, D2_CF,D2_CLIENTE,D2_LOJA,D2_EMISSAO, D2_ITEMPV, "		+ CRLF
	cQuery += " F4_FINALID, F4_TEXTO, FT_CTIPI, FT_CSTPIS, FT_CSTCOF, F4_ICM, F4_IPI, F4_CREDICM, F4_CREDIPI, F4_DUPLIC, "	+ CRLF
	cQuery += " B1_DESC, B1_XDESCL1, B1_GRUPO, B1_POSIPI, B1_CEST, B1_ORIGEM, B1_EX_NBM, D2_ITEM, "							+ CRLF
	cQuery += " F2_ESPECIE,F2_CODNFE,F2_MENNOTA,F2_USERLGI,F2_USERLGA,F2_TIPO, FT_CHVNFE,F2_DOC, F2_SERIE, F2_FIMP,  " 		+ CRLF
	cQuery += " FT_VALCONT, F2_FORMUL, D2_CONTA, D2_NFORI, D2_SERIORI, D2_PRUNIT,D2_TOTAL, "								+ CRLF
	cQuery += " D2_DESC, D2_DESCON, FT_CLASFIS, D2_DESCZFP, D2_DESCZFC, D2_TIPO, "											+ CRLF
	cQuery += " FT_BASEICM, FT_ALIQICM, FT_VALICM, C6_CHASSI, "																+ CRLF
	cQuery += " FT_BASEIPI, FT_ALIQIPI, FT_VALIPI, FT_BRETPIS, FT_ARETPIS, FT_VRETPIS, FT_BRETCOF, FT_ARETCOF, FT_VRETCOF, "+ CRLF
	cQuery += " FT_BASERET, FT_ICMSRET, FT_DIFAL, "																			+ CRLF
	cQuery += " D2_BASIMP6,D2_ALQIMP6,D2_VALIMP6,   " 																		+ CRLF
	cQuery += " D2_BASIMP5,D2_ALQIMP5,D2_VALIMP5,   " 																		+ CRLF
	cQuery += " FT_BASEPIS,FT_ALIQPIS,FT_VALPIS, F2_TOTFED, F2_TOTEST, " 													+ CRLF
	cQuery += " FT_BASECOF,FT_ALIQCOF,FT_VALCOF, FT_BASECF3, FT_ALIQCF3, FT_VALCF3, FT_BASEPS3, FT_ALIQPS3, FT_VALPS3, "	+ CRLF
	cQuery += " FT_BASEIRR,FT_ALIQIRR,FT_VALIRR, F3_OUTRIPI, F3_ISENIPI, F3_OUTRICM, F3_ISENICM,  "							+ CRLF
	cQuery += " FT_BASEINS,FT_ALIQINS,D2_ABATINS,FT_VALINS, D2_UM, D2_QUANT, "												+ CRLF
	cQuery += " D2_BASEISS,D2_ALIQISS,D2_ABATISS,D2_ABATMAT,D2_VALISS, D2_ITEMCC, "											+ CRLF
	cQuery += " FT_BASECSL,FT_ALIQCSL,FT_VALCSL, D2_CUSTO1, VRK_CHASSI, VRJ_CODCLI, VRJ_LOJA, C6_XVLCOM,  "					+ CRLF
	cQuery += " C6_TNATREC, C6_NFORI, C6_FILIAL, C6_NUM, VV3_TIPVEN, VV3_DESCRI, VRJ_CLIRET, VRK_OPCION, F2_VALBRUT "		+ CRLF

	cQuery += " ORDER BY SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA " 						    + CRLF

	cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return

/*
=====================================================================================
Programa.:              zRel0003
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              26/02/20
Descricao / Objetivo:   Realiza consulta na tabela CDA e alimenta as variaveis de IPI
Doc. Origem:            
Solicitante:            
Uso......:              zRel0002
Obs......:
=====================================================================================
*/
Static Function zRel0003( nVlIPIRegi, nVlIPIPres, cEspecie, cDoc, cSerie, cCodCli, cCodLoja, cItem )
	Local aArea		:= GetArea() 
	Local cAliasTRB	:= GetNextAlias()
	Local cQry 		:= ""

	Default cEspecie	:= ""
	Default cDoc 		:= ""
	Default cSerie 		:= ""
	Default cCodCli		:= ""
	Default cCodLoja	:= ""
	Default cItem		:= ""

	If Select( cAliasTRB ) > 0
		( cAliasTRB )->( DbCloseArea() )
	EndIf

	cQry := " SELECT CDA_CODLAN, CDA_VALOR " 					+ CRLF
	cQry += " FROM " + RetSQLName( 'CDA' ) + ' CDA ' 			+ CRLF
	cQry += " WHERE CDA_FILIAL = '" + FWxFilial('SF2') + "' "	+ CRLF
	cQry += " 	AND CDA_ESPECI = '" + cEspecie + "' "			+ CRLF
	cQry += " 	AND CDA_NUMERO = '" + cDoc + "' "				+ CRLF
	cQry += " 	AND CDA_SERIE = '" + cSerie + "' "				+ CRLF
	cQry += " 	AND CDA_CLIFOR = '" + cCodCli + "' "			+ CRLF
	cQry += " 	AND CDA_LOJA = '" + cCodLoja + "' "				+ CRLF
	cQry += " 	AND CDA_NUMITE = '" + cItem + "' "				+ CRLF
	cQry += " 	AND D_E_L_E_T_ = ' ' "							+ CRLF

	cQry := ChangeQuery(cQry)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTRB, .T., .T. )

	DbSelectArea( cAliasTRB )
	( cAliasTRB )->( dbGoTop() )	
	While ( cAliasTRB )->( !Eof() )
		
		If AllTrim( ( cAliasTRB )->CDA_CODLAN ) == '012' //-- Credito Regional IPI, com base nos registros atuais, não há registro para este código na tabela CC6
			nVlIPIRegi := ( cAliasTRB )->CDA_VALOR
		ElseIf AllTrim( ( cAliasTRB )->CDA_CODLAN ) == '013' //-- Credito presumido IPI, com base nos registros atuais, não há registro para este código na tabela CC6
			nVlIPIPres := ( cAliasTRB )->CDA_VALOR
		EndIf

		( cAliasTRB )->( DbSkip() )
	EndDo
	
	( cAliasTRB )->( DbCloseArea() )
	RestArea( aArea )
Return
