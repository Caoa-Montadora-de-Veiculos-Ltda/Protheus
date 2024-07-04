#Include "Protheus.ch"
#Include "Topconn.ch"

//---------------------------------------------------------------------------
User Function ZFISR003()
Local oReport,  oSection
Private cAliasTMP := GetNextAlias()
      
oReport:= TReport():New("ZFISR003",;
                        "Entradas",;
                        "ZFISR001R1",;
                        {|oReport|  ReportPrint(oReport)},;
                        "Este relatorio efetua a impressão das notas fiscais de entrada")
oReport:HideParamPage()   //--Desabilita a impressao da pagina de parametros.
oReport:HideHeader()      //--Define que não será impresso o cabeçalho padrão da página
oReport:HideFooter()      //--Define que não será impresso o rodapé padrão da página
oReport:SetDevice(4)      //--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
oReport:SetPreview(.T.)   //--Define se será apresentada a visualização do relatório antes da impressão física
oReport:SetEnvironment(2) //--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
	
//Verifica os parâmetros selecionados via Pergunte
Pergunte(oReport:GetParam(),.F.)
	
oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTMP}) 

    TRCell():New( oSection  ,"CgcCpf"       ,cAliasTMP  ,'Cnpj/Cpf'                    )
    TRCell():New( oSection  ,"IncEst"       ,cAliasTMP  ,'Insc.Estadual'               )
    TRCell():New( oSection  ,"TpPessoa"     ,cAliasTMP  ,'Pessoa Fisica/Juridica'      )
    TRCell():New( oSection  ,"EstCli"       ,cAliasTMP  ,'UF'                          )
    TRCell():New( oSection  ,"D1_TES"       ,cAliasTMP  ,'Tes'                         )
    TRCell():New( oSection  ,"F4_FINALID"   ,cAliasTMP  ,'Finalidade TES'              )
    TRCell():New( oSection  ,"B1_ORIGEM"    ,cAliasTMP  ,'Origem do Produto'           )
    TRCell():New( oSection  ,"B1_POSIPI"    ,cAliasTMP  ,'NCM'                      , "@!", TamSX3("B1_POSIPI")[1]                           )
    TRCell():New( oSection  ,"B1_EX_NCM"    ,cAliasTMP  ,'Ex-NCM'                      )
    TRCell():New( oSection  ,"ModVei"       ,cAliasTMP  ,'Modelo Veículo'              )
    TRCell():New( oSection  ,"VRK_OPCION"   ,cAliasTMP  ,'Opcional'                    )
    TRCell():New( oSection  ,"B1_GRUPO"     ,cAliasTMP  ,'Grupo\Linha'                 )
    TRCell():New( oSection  ,"BM_DESC"      ,cAliasTMP  ,'Descrição do Grupo'          )
    TRCell():New( oSection  ,"D1_TOTAL"     ,cAliasTMP  ,'Valor Total Item'            )
    TRCell():New( oSection  ,"D1_CF"        ,cAliasTMP  ,'Cfop'                        )       
    TRCell():New( oSection  ,"FT_VALCONT"   ,cAliasTMP  ,'Valor Contábil'              )
    TRCell():New( oSection  ,"FT_BASEICM"   ,cAliasTMP  ,'Base ICMS'                   )
    TRCell():New( oSection  ,"FT_ALIQICM"   ,cAliasTMP  ,'Aliq. ICMS'                  )
    TRCell():New( oSection  ,"FT_VALICM"    ,cAliasTMP  ,'Valor ICMS'                  )
    TRCell():New( oSection  ,"VlCom"        ,cAliasTMP  ,'Comissão'                    )
    TRCell():New( oSection  ,"FT_BASEIPI"   ,cAliasTMP  ,'Base IPI'                    )
    TRCell():New( oSection  ,"FT_ALIQIPI"   ,cAliasTMP  ,'Aliq. IPI'                   )
    TRCell():New( oSection  ,"FT_VALIPI"    ,cAliasTMP  ,'Valor IPI'                   )
    TRCell():New( oSection  ,"VlIPIPres"    ,cAliasTMP  ,'Credito_Presumido IPI/Frete' )
    TRCell():New( oSection  ,"VlIPIRegi"    ,cAliasTMP  ,'Credito_Regional IPI'        )
    TRCell():New( oSection  ,"FT_BASERET"   ,cAliasTMP  ,'Base Subst'                  )
    TRCell():New( oSection  ,"FT_ICMSRET"   ,cAliasTMP  ,'Valor Subst'                 )
    TRCell():New( oSection  ,"FT_BASEPIS"   ,cAliasTMP  ,'Base Pis Apuração'           )
    TRCell():New( oSection  ,"FT_ALIQPIS"   ,cAliasTMP  ,'Aliq. Pis Apuração'          )
    TRCell():New( oSection  ,"FT_VALPIS"    ,cAliasTMP  ,'Valor Pis Apuração'          )
    TRCell():New( oSection  ,"FT_BASECOF"   ,cAliasTMP  ,'Base Cofins Apuração'        )
    TRCell():New( oSection  ,"FT_ALIQCOF"   ,cAliasTMP  ,'Aliq. Cofins Apuração'       )
    TRCell():New( oSection  ,"FT_VALCOF"    ,cAliasTMP  ,'Valor Cofins Apuração'       )
    TRCell():New( oSection  ,"FT_BASEPS3"   ,cAliasTMP  ,'Base Pis ST ZFM'             )
    TRCell():New( oSection  ,"FT_ALIQPS3"   ,cAliasTMP  ,'Aliq. Pis ST ZFM'            )
    TRCell():New( oSection  ,"FT_VALPS3"    ,cAliasTMP  ,'Vl. Pis ST ZFM'              )
    TRCell():New( oSection  ,"FT_BASECF3"   ,cAliasTMP  ,'Base Cof ST ZFM'             )
    TRCell():New( oSection  ,"FT_ALIQCF3"   ,cAliasTMP  ,'Aliq. Cof ST ZFM'            )
    TRCell():New( oSection  ,"FT_VALCF3"    ,cAliasTMP  ,'Vl. Cof ST ZFM'              )
    TRCell():New( oSection  ,"FT_DIFAL"     ,cAliasTMP  ,'ICMS Difal'                  )
    TRCell():New( oSection  ,"FT_CLASFIS"   ,cAliasTMP  ,'CST ICMS'                    )
    TRCell():New( oSection  ,"FT_CTIPI"     ,cAliasTMP  ,'CST IPI'                     )
    TRCell():New( oSection  ,"FT_CSTPIS"    ,cAliasTMP  ,'CST PIS'                     )
    TRCell():New( oSection  ,"FT_CSTCOF"    ,cAliasTMP  ,'CST COFINS'                  )
    TRCell():New( oSection  ,"F4_ICM"       ,cAliasTMP  ,'Calcula ICMS'                )
    TRCell():New( oSection  ,"F4_CREDICM"   ,cAliasTMP  ,'Credita ICMS'                )
    TRCell():New( oSection  ,"F4_IPI"       ,cAliasTMP  ,'Calcula IPI'                 )
    TRCell():New( oSection  ,"F4_CREDIPI"   ,cAliasTMP  ,'Credita IPI'                 )
    TRCell():New( oSection  ,"D1_DOC"       ,cAliasTMP  ,'Nota Fiscal'                 )
    TRCell():New( oSection  ,"NfPref"       ,cAliasTMP  ,'Nf. Prefeitura'              )
    TRCell():New( oSection  ,"D1_SERIE"     ,cAliasTMP  ,'Série'                       )
    TRCell():New( oSection  ,"F1_ESPECIE"   ,cAliasTMP  ,'Espécie'                     )
    TRCell():New( oSection  ,"ModNot"       ,cAliasTMP  ,'Modelo'                      )
    TRCell():New( oSection  ,"D1_DTDIGIT"   ,cAliasTMP  ,'Dt. de Entrada'              )
    TRCell():New( oSection  ,"D1_EMISSAO"   ,cAliasTMP  ,'Dt. de Emissão'              )
    TRCell():New( oSection  ,"D1_FORNECE"   ,cAliasTMP  ,'Fornecedor\Cliente'          )
    TRCell():New( oSection  ,"D1_LOJA"      ,cAliasTMP  ,'Loja'                        )
    TRCell():New( oSection  ,"CliFor"       ,cAliasTMP  ,'Nome'                        )
    TRCell():New( oSection  ,"Chassi"       ,cAliasTMP  ,'Chassi'                      )
    TRCell():New( oSection  ,"D1_COD"       ,cAliasTMP  ,'Cód.Produto'                 )
    TRCell():New( oSection  ,"B1_DESC"      ,cAliasTMP  ,'Descrição do Produto'        )
    TRCell():New( oSection  ,"DescrCient"   ,cAliasTMP  ,'Descrição Científico'        )
    TRCell():New( oSection  ,"B1_XDESCL1"   ,cAliasTMP  ,'Descrição Longa'             )
    TRCell():New( oSection  ,"D1_UM"        ,cAliasTMP  ,'Un Medida'                   )
    TRCell():New( oSection  ,"D1_QUANT"     ,cAliasTMP  ,'Quant.'                      )
    TRCell():New( oSection  ,"D1_VUNIT"     ,cAliasTMP  ,'Valor Unit. Item'            )
    //TRCell():New( oSection  ,"F1_DESCONT"   ,cAliasTMP  ,'Desconto Item'               )
    TRCell():New( oSection  ,"FT_DESCONT"   ,cAliasTMP  ,'Desconto Item'               ) 
    TRCell():New( oSection  ,"D1_VALFRE"    ,cAliasTMP  ,'Frete'                       )
    TRCell():New( oSection  ,"D1_DESPESA"   ,cAliasTMP  ,'Despesas Acessorias'         )
    TRCell():New( oSection  ,"D1_SEGURO"    ,cAliasTMP  ,'Seguro'                      )
    TRCell():New( oSection  ,"D1_VALACRS"   ,cAliasTMP  ,'Acrescimo'                   )
    TRCell():New( oSection  ,"D1_CUSTO"     ,cAliasTMP  ,'Custo'                       )
    TRCell():New( oSection  ,"FT_ICMSCOM"   ,cAliasTMP  ,'Valor do Dif. de Aliq.'      )
    TRCell():New( oSection  ,"YD_PER_II"    ,cAliasTMP  ,'Aliq. II'                    )
    TRCell():New( oSection  ,"D1_II"        ,cAliasTMP  ,'Valor II'                    )
    TRCell():New( oSection  ,"D1_CONHEC"    ,cAliasTMP  ,'Num. Conhecimento'           )
    TRCell():New( oSection  ,"W6_DI_NUM"    ,cAliasTMP  ,'Num. DI'                     )
    TRCell():New( oSection  ,"W6_DTREG_D"   ,cAliasTMP  ,'Data DI'                     )
    TRCell():New( oSection  ,"D1_CONTA"     ,cAliasTMP  ,'Conta Contábil'              )
    TRCell():New( oSection  ,"CT1_DESC01"   ,cAliasTMP  ,'Desc.Conta Contábil'         )
    TRCell():New( oSection  ,"D1_FILIAL"    ,cAliasTMP  ,'Empresa'                     )
    TRCell():New( oSection  ,"Situacao"     ,cAliasTMP  ,'Situação'                    )
    TRCell():New( oSection  ,"TpNF"         ,cAliasTMP  ,'Tipo Nota Fiscal'            )
    TRCell():New( oSection  ,"FT_FORMUL"    ,cAliasTMP  ,'Formulario'                  )
    TRCell():New( oSection  ,"FT_CHVNFE"    ,cAliasTMP  ,'Chave Nota Fiscal'           )
    TRCell():New( oSection  ,"Protocolo"    ,cAliasTMP  ,'Protocolo'                   )
    TRCell():New( oSection  ,"D1_NFORI"     ,cAliasTMP  ,'Nota Fiscal Origem'          )
    TRCell():New( oSection  ,"DescTipo"     ,cAliasTMP  ,'Tipo Cli\For'                )
    TRCell():New( oSection  ,"TpCliFor"     ,cAliasTMP  ,'Cli\For'                     )
    TRCell():New( oSection  ,"X5_DESCRI"    ,cAliasTMP  ,'Estado'                      )
    TRCell():New( oSection  ,"CC2_MUN"      ,cAliasTMP  ,'Município'                   )
    TRCell():New( oSection  ,"B1_CEST"      ,cAliasTMP  ,'CEST'                        )
    TRCell():New( oSection  ,"DesMod"       ,cAliasTMP  ,'Descr. Modelo Veículo'       )
    TRCell():New( oSection  ,"ComVei"       ,cAliasTMP  ,'Combustível Veículo'         )
    TRCell():New( oSection  ,"F4_TEXTO"     ,cAliasTMP  ,'Descrição CFOP'              )
    TRCell():New( oSection  ,"F1_CODNFE"    ,cAliasTMP  ,'Cód.Verificação'             )
    TRCell():New( oSection  ,"Ambiente"     ,cAliasTMP  ,'Ambiente'                    )
    TRCell():New( oSection  ,"FT_BASEIRR"   ,cAliasTMP  ,'Base Irrf Retenção'          )
    TRCell():New( oSection  ,"FT_ALIQIRR"   ,cAliasTMP  ,'Aliq. Irrf Retenção'         )
    TRCell():New( oSection  ,"FT_VALIRR"    ,cAliasTMP  ,'Irrf Retenção'               )
    TRCell():New( oSection  ,"FT_BASEINS"   ,cAliasTMP  ,'Base Inss'                   )
    TRCell():New( oSection  ,"FT_ALIQINS"   ,cAliasTMP  ,'Aliq. Inss'                  )
    TRCell():New( oSection  ,"D1_ABATINS"   ,cAliasTMP  ,'Inss Recolhido'              )
    TRCell():New( oSection  ,"FT_VALINS"    ,cAliasTMP  ,'Valor Inss'                  )
    TRCell():New( oSection  ,"D1_BASEISS"   ,cAliasTMP  ,'Base Iss'                    )
    TRCell():New( oSection  ,"D1_ALIQISS"   ,cAliasTMP  ,'Aliq. Iss'                   )
    TRCell():New( oSection  ,"D1_ABATISS"   ,cAliasTMP  ,'Iss Serviços'                )
    TRCell():New( oSection  ,"D1_ABATMAT"   ,cAliasTMP  ,'Iss Materiais'               )
    TRCell():New( oSection  ,"D1_VALISS"    ,cAliasTMP  ,'Valor Iss'                   )
    TRCell():New( oSection  ,"D1_AVLINSS"   ,cAliasTMP  ,'Inss Serviços'               )
    TRCell():New( oSection  ,"FT_BASECSL"   ,cAliasTMP  ,'Base Csll'                   )
    TRCell():New( oSection  ,"FT_ALIQCSL"   ,cAliasTMP  ,'Aliq. Csll'                  )
    TRCell():New( oSection  ,"FT_VALCSL"    ,cAliasTMP  ,'Valor Csll'                  )
    TRCell():New( oSection  ,"FT_BRETPIS"   ,cAliasTMP  ,'Base Pis Retenção'           )
    TRCell():New( oSection  ,"FT_ARETPIS"   ,cAliasTMP  ,'Aliq. Pis Retenção'          )
    TRCell():New( oSection  ,"FT_VRETPIS"   ,cAliasTMP  ,'Valor Pis Retenção'          )
    TRCell():New( oSection  ,"FT_BRETCOF"   ,cAliasTMP  ,'Base Cofins Retenção'        )
    TRCell():New( oSection  ,"FT_ARETCOF"   ,cAliasTMP  ,'Aliq. Cofins Retenção'       )
    TRCell():New( oSection  ,"FT_VRETCOF"   ,cAliasTMP  ,'Valor Cofins Retenção'       )
    TRCell():New( oSection  ,"F1_MENNOTA"   ,cAliasTMP  ,'Msgn Nota Fiscal'            )
    TRCell():New( oSection  ,"LogInc"       ,cAliasTMP  ,'Log. de Inclusão'            )
    TRCell():New( oSection  ,"LogAlt"       ,cAliasTMP  ,'Log. de Alteração'           )
    TRCell():New( oSection  ,"DtLogAlt"     ,cAliasTMP  ,'Dt. Log. de Alteração'       )
    TRCell():New( oSection  ,"C7_NUM"       ,cAliasTMP  ,'Num. Pedido Compra'          )
    TRCell():New( oSection  ,"CodNatur"     ,cAliasTMP  ,'Natureza Financeira'         )
    TRCell():New( oSection  ,"D1_TNATREC"   ,cAliasTMP  ,'Tab. Nat. Receita'           )
    TRCell():New( oSection  ,"D1_ITEMCTA"   ,cAliasTMP  ,'Item Contábil'               )
    TRCell():New( oSection  ,"F3_ISENICM"   ,cAliasTMP  ,'ICMS Isento'                 )
    TRCell():New( oSection  ,"F3_OUTRICM"   ,cAliasTMP  ,'ICMS Outros'                 )
    TRCell():New( oSection  ,"F3_ISENIPI"   ,cAliasTMP  ,'IPI Isento'                  )
    TRCell():New( oSection  ,"F3_OUTRIPI"   ,cAliasTMP  ,'IPI Outros'                  )
    TRCell():New( oSection  ,"D1_PESO"      ,cAliasTMP  ,'Peso Total'                  )
    TRCell():New( oSection  ,"FT_CODBCC"    ,cAliasTMP  ,'Natureza Base de Calculo'    )
    TRCell():New( oSection  ,"FT_INDNTFR"   ,cAliasTMP  ,'Natureza Frete'              )
    TRCell():New( oSection  ,"F1_UFORITR"   ,cAliasTMP  ,'UF Origem do Transporte'     )
    TRCell():New( oSection  ,"F1_MUORITR"   ,cAliasTMP  ,'Mun. Orig. do Transporte'    )
    TRCell():New( oSection  ,"F1_UFDESTR"   ,cAliasTMP  ,'UF Destino do Transporte'    )
    TRCell():New( oSection  ,"F1_MUDESTR"   ,cAliasTMP  ,'Mun. Dest. do Transporte'    )
    TRCell():New( oSection  ,"MsgSefaz"     ,cAliasTMP  ,'Msgn Sefaz'                  )
    TRCell():New( oSection  ,"F4_DUPLIC"    ,cAliasTMP  ,'Gera Duplicata'              )
    TRCell():New( oSection  ,"W9_TX_FOB"    ,cAliasTMP  ,'Taxa Cambial'                )

    oReport:PrintDialog()

Return 

//-----------------------------------
Static Function  ReportPrint(oReport)

    Local oSection      := oReport:Section(1)
	Local cDescTipo		:= ""
	Local cLogInc		:= ""
	Local cLogAlt		:= ""
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
	Local nVlIPIRegi	:= 0
	Local nVlIPIPres	:= 0
	Local cCodNatur		:= ""
	Local cCodChassi	:= ""
	Local nVlCom		:= 0

    //Monta Tmp
    ZTmpRadio1()

	oReport:SetMeter( Contar(cAliasTMP,"!Eof()") )
	// Secção 1
	oSection:Init()

    SF1->( DbSetOrder(1) ) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
    VV2->( DbSetOrder(7) ) // VV2_FILIAL+VV2_PRODUT
    SA1->( DbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA
    SA2->( DbSetOrder(1) ) // A2_FILIAL+A2_COD+A2_LOJA
    CDA->( DbSetOrder(1) ) // CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+CDA_NUMITE
    SE1->( DbSetOrder(2) ) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
    SE2->( DbSetOrder(6) ) // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
    SC6->( DbSetOrder(4) ) // C6_FILIAL+C6_NOTA+C6_SERIE

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()

        // Incrementa a mensagem na régua.
        oReport:IncMeter()

        // TRATAMENTO PARA BUSCAR O LOG DO USUÁRIO.
        cLogInc 	:= ""
        cLogAlt		:= ""
        cDtLogAlt 	:= "" 
        /* teste de performace
        If SF1->(dbSeek( (cAliasTMP)->D1_FILIAL + (cAliasTMP)->D1_DOC + (cAliasTMP)->D1_SERIE + (cAliasTMP)->D1_FORNECE + (cAliasTMP)->D1_LOJA ))
            cLogInc		:= FWLeUserLg("F1_USERLGI")
            cLogAlt		:= FWLeUserLg("F1_USERLGA")
            cDtLogAlt	:= FWLeUserLg("F1_USERLGA", 2)
        EndIf
        */
        // Busca o Status da Nota Fiscal.
        cSituacao	:= ""
        Do Case
            Case Empty( (cAliasTMP)->F1_STATUS )
                cSituacao	:= "Docto. nao Classificado"
            Case (cAliasTMP)->F1_STATUS == "B"
                cSituacao	:= "Docto. Bloqueado"
            Case (cAliasTMP)->F1_STATUS == "C"
                cSituacao	:= "Doc. C/Bloq. de Mov."
            Case (cAliasTMP)->F1_TIPO == "N"
                cSituacao	:= "Docto. Normal"
            Case (cAliasTMP)->F1_TIPO == "P"
                cSituacao	:= "Docto. de Compl. IPI"
            Case (cAliasTMP)->F1_TIPO == "I"
                cSituacao	:= "Docto. de Compl. ICMS"
            Case (cAliasTMP)->F1_TIPO == "C"
                cSituacao	:= "Docto. de Compl. Preco/Frete/Desp. Imp."
            Case (cAliasTMP)->F1_TIPO == "B"
                cSituacao	:= "Docto. de Beneficiamento"
            Case (cAliasTMP)->F1_TIPO == "D"
                cSituacao	:= "Docto. de Devolucao"
            OtherWise
                cSituacao	:= ""
        EndCase

        // Busca o Modelo do Veiculo
        cModVei		:= ""
        cDesMod		:= ""
        cComVei 	:= ""
        If VV2->(DbSeek( xFilial("VV2") + (cAliasTMP)->D1_COD ))
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
        If (cAliasTMP)->F1_TIPO $ "B|D" // Benefeciamento ou devolução
            If SA1->(DbSeek( xFilial("SA1") + (cAliasTMP)->D1_FORNECE + (cAliasTMP)->D1_LOJA ))
                cCliFor		:= SA1->A1_NOME
                cIncEst 	:= SA1->A1_INSCR
                cCgcCpf 	:= IIF( Len( Alltrim( SA1->A1_CGC) )>11 ,Transform( SA1->A1_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA1->A1_CGC ,"@R 999.999.999-99" ) ) 
                cEstCli 	:= SA1->A1_EST
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

                //--Posiciono no titulo a receber para pegar a natureza financeira
                cCodNatur := ""
                If SE1->( DbSeek( FWxFilial('SE1') + (cAliasTMP)->( D1_FORNECE + D1_LOJA + D1_SERIE + D1_DOC  ) ) )
                    //--Posiciono no primeiro registro lógico porque mesmo que existam parcelas a natureza ira se repetir nos demais registros
                    //SE1->( DbGoTop() )
                    cCodNatur := SE1->E1_NATUREZ
                EndIf

                cCodChassi 	:= ""
                nVlCom		:= 0
                If SC6->( DbSeek(FWxFilial('SC6') + (cAliasTMP)->D1_NFORI + (cAliasTMP)->D1_SERIORI ) )
                    cCodChassi 	:= SC6->C6_CHASSI
                    nVlCom		:= SC6->C6_XVLCOM
                EndIf
            Else
                cCliFor		:= "CLIENTE NÃO ENCONTRADO NA BASE DE DADOS"
                cIncEst 	:= ""
                cCgcCpf 	:= ""
                cDescTipo	:= ""
                cEstCli		:= ""
                cCodMun		:= ""
                cTpCliFor	:= "Cliente"
                cTpPessoa	:= ""
            EndIf
        Else
            If SA2->(DbSeek( xFilial("SA2") + (cAliasTMP)->D1_FORNECE + (cAliasTMP)->D1_LOJA ))
                cCliFor		:= SA2->A2_NOME
                cIncEst 	:= SA2->A2_INSCR
                cCgcCpf 	:= IIF( Len( Alltrim( SA2->A2_CGC) )>11 ,Transform( SA2->A2_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA2->A2_CGC ,"@R 999.999.999-99" ) ) 
                cEstCli		:= SA2->A2_EST
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

                //--Posiciono no titulo a pagar para pegar a natureza financeira
                cCodNatur := ""
                If SE2->( DbSeek( FWxFilial('SE2') + (cAliasTMP)->( D1_FORNECE + D1_LOJA + D1_SERIE + D1_DOC  ) ) )
                    //--Posiciono no primeiro registro lógico porque mesmo que existam parcelas a natureza ira se repetir nos demais registros
                    //SE2->( DbGoTop() )
                    cCodNatur := SE2->E2_NATUREZ
                EndIf 
                
            Else
                cCliFor		:= "FORNECEDOR NÃO ENCONTRADO NA BASE DE DADOS"
                cIncEst 	:= ""
                cCgcCpf		:= ""
                cDescTipo	:= ""
                cEstCli		:= ""
                cCodMun		:= ""
                cTpCliFor	:= "Fornecedor"
                cTpPessoa	:= ""
            EndIf
        EndIf

        //Verifica o tipo da Nota Fiscal
        cTpNF := ""
        Do Case
            Case (cAliasTMP)->F1_TIPO == "N"
                cTpNF	:= "NF Normal"
            Case (cAliasTMP)->F1_TIPO == "P"
                cTpNF	:= "NF de Compl. IPI"
            Case (cAliasTMP)->F1_TIPO== "I"
                cTpNF	:= "NF de Compl. ICMS"
            Case (cAliasTMP)->F1_TIPO == "C"
                cTpNF	:= "NF de Compl. Preco/Frete"
            Case (cAliasTMP)->F1_TIPO == "B"
                cTpNF	:= "NF de Beneficiamento"
            Case (cAliasTMP)->F1_TIPO == "D"
                cTpNF	:= "NF de Devolucao"
            OtherWise
                cTpNF	:= "Tipo não encontrado"
        EndCase

        nVlIPIRegi := 0
        nVlIPIPres := 0
        //-- Retorna Valor de IPI regional e presumido
        zRel0003(@nVlIPIRegi, @nVlIPIPres, (cAliasTMP)->F1_ESPECIE, (cAliasTMP)->F1_DOC, (cAliasTMP)->F1_SERIE,;
                (cAliasTMP)->D1_FORNECE, (cAliasTMP)->D1_LOJA, (cAliasTMP)->D1_ITEM )

         oSection:Cell( "CgcCpf"    ):SetValue( cCgcCpf                                                                                                     ) //--Cnpj/Cpf 
         oSection:Cell( "IncEst"    ):SetValue( cIncEst                                                                                                     ) //--Insc.Estadual
         oSection:Cell( "TpPessoa"  ):SetValue( cTpPessoa                                                                                                   ) //--Pessoa Fisica/Juridica
         oSection:Cell( "EstCli"    ):SetValue( cEstCli                                                                                                     ) //--UF
         oSection:Cell( "D1_TES"    ):SetValue( (cAliasTMP)->D1_TES                                                                                         ) //--Tes
         oSection:Cell( "F4_FINALID"):SetValue( Alltrim( (cAliasTMP)->F4_FINALID )                                                                          ) //--Finalidade TES
         oSection:Cell( "B1_ORIGEM" ):SetValue( AllTrim( (cAliasTMP)->B1_ORIGEM )                                                                           ) //--Origem do Produto
         oSection:Cell( "B1_POSIPI" ):SetValue( AllTrim( (cAliasTMP)->B1_POSIPI )                                                                           ) //--NCM
         oSection:Cell( "B1_EX_NCM" ):SetValue( AllTrim( (cAliasTMP)->B1_EX_NCM )                                                                           ) //--Ex-NBM
         oSection:Cell( "ModVei"    ):SetValue( AllTrim( cModVei )                                                                                          ) //--Modelo Veículo
         oSection:Cell( "VRK_OPCION"):SetValue( AllTrim( (cAliasTMP)->VRK_OPCION )                                                                          ) //--Opcional
         oSection:Cell( "B1_GRUPO"  ):SetValue( AllTrim( (cAliasTMP)->B1_GRUPO )                                                                            ) //--Grupo\Linha
         oSection:Cell( "BM_DESC"   ):SetValue( AllTrim( Posicione("SBM",1,xFilial("SBM")+(cAliasTMP)->B1_GRUPO,"BM_DESC") )                                ) //--Descrição do Grupo
         oSection:Cell( "D1_TOTAL"  ):SetValue( (cAliasTMP)->D1_TOTAL                                                                                       ) //--Valor Total Item
         oSection:Cell( "D1_CF"     ):SetValue( (cAliasTMP)->D1_CF                                                                                          ) //--Cfop
         oSection:Cell( "FT_VALCONT"):SetValue( (cAliasTMP)->FT_VALCONT                                                                                     ) //--Valor Contábil
         oSection:Cell( "FT_BASEICM"):SetValue( iif( !Alltrim((cAliasTMP)->F1_ESPECIE) $ "RPS|NFS", (cAliasTMP)->FT_BASEICM , 0)                            ) //(cAliasTMP)->FT_BASEICM   ) //--Base ICMS
         oSection:Cell( "FT_ALIQICM"):SetValue( iif( !Alltrim((cAliasTMP)->F1_ESPECIE) $ "RPS|NFS", (cAliasTMP)->FT_ALIQICM , 0)                            ) //(cAliasTMP)->FT_ALIQICM   ) //--Aliq. ICMS
         oSection:Cell( "FT_VALICM" ):SetValue( iif( !Alltrim((cAliasTMP)->F1_ESPECIE) $ "RPS|NFS", (cAliasTMP)->FT_VALICM  , 0)                            )//(cAliasTMP)->FT_VALICM     ) //--Valor ICMS
         oSection:Cell( "VlCom"     ):SetValue( IIF( (cAliasTMP)->F1_TIPO $ "B|D" , nVlCom , 0 )                                                            ) //--Comissão
         oSection:Cell( "FT_BASEIPI"):SetValue( (cAliasTMP)->FT_BASEIPI                                                                                     ) //--Base IPI					
         oSection:Cell( "FT_ALIQIPI"):SetValue( (cAliasTMP)->FT_ALIQIPI                                                                                     ) //--Aliq. IPI			
         oSection:Cell( "FT_VALIPI" ):SetValue( (cAliasTMP)->FT_VALIPI                                                                                      ) //--Valor IPI
         oSection:Cell( "VlIPIPres" ):SetValue( nVlIPIPres                                                                                                  ) //--Credito_Presumido IPI/Frete
         oSection:Cell( "VlIPIRegi" ):SetValue( nVlIPIRegi                                                                                                  ) //--Credito_Regional IPI
         oSection:Cell( "FT_BASERET"):SetValue( (cAliasTMP)->FT_BASERET                                                                                     ) //--Base Subst
         oSection:Cell( "FT_ICMSRET"):SetValue( (cAliasTMP)->FT_ICMSRET                                                                                     ) //--Valor Subst
         oSection:Cell( "FT_BASEPIS"):SetValue( (cAliasTMP)->FT_BASEPIS                                                                                     ) //--Base Pis Apuração
         oSection:Cell( "FT_ALIQPIS"):SetValue( (cAliasTMP)->FT_ALIQPIS                                                                                     ) //--Aliq. Pis Apuração
         oSection:Cell( "FT_VALPIS" ):SetValue( (cAliasTMP)->FT_VALPIS                                                                                      ) //--Valor Pis Apuração
         oSection:Cell( "FT_BASECOF"):SetValue( (cAliasTMP)->FT_BASECOF                                                                                     ) //--Base Cofins Apuração
         oSection:Cell( "FT_ALIQCOF"):SetValue( (cAliasTMP)->FT_ALIQCOF                                                                                     ) //--Aliq. Cofins Apuração
         oSection:Cell( "FT_VALCOF" ):SetValue( (cAliasTMP)->FT_VALCOF                                                                                      ) //--Valor Cofins Apuração
         oSection:Cell( "FT_BASEPS3"):SetValue( (cAliasTMP)->FT_BASEPS3                                                                                     ) //--Base Pis ST ZFM
         oSection:Cell( "FT_ALIQPS3"):SetValue( (cAliasTMP)->FT_ALIQPS3                                                                                     ) //--Aliq. Pis ST ZFM
         oSection:Cell( "FT_VALPS3" ):SetValue( (cAliasTMP)->FT_VALPS3                                                                                      ) //--Vl. Pis ST ZFM
         oSection:Cell( "FT_BASECF3"):SetValue( (cAliasTMP)->FT_BASECF3                                                                                     ) //--Base Cof ST ZFM
         oSection:Cell( "FT_ALIQCF3"):SetValue( (cAliasTMP)->FT_ALIQCF3                                                                                     ) //--Aliq. Cof ST ZFM
         oSection:Cell( "FT_VALCF3" ):SetValue( (cAliasTMP)->FT_VALCF3                                                                                      ) //--Vl. Cof ST ZFM
         oSection:Cell( "FT_DIFAL"  ):SetValue( (cAliasTMP)->FT_DIFAL                                                                                       ) //--ICMS Difal
         oSection:Cell( "FT_CLASFIS"):SetValue( (cAliasTMP)->FT_CLASFIS                                                                                     ) //--CST ICMS
         oSection:Cell( "FT_CTIPI"  ):SetValue( (cAliasTMP)->FT_CTIPI                                                                                       ) //--CST IPI
         oSection:Cell( "FT_CSTPIS" ):SetValue( (cAliasTMP)->FT_CSTPIS                                                                                      ) //--CST PIS
         oSection:Cell( "FT_CSTCOF" ):SetValue( (cAliasTMP)->FT_CSTCOF                                                                                      ) //--CST COFINS
         oSection:Cell( "F4_ICM"    ):SetValue( (cAliasTMP)->F4_ICM                                                                                         ) //--Calcula ICMS
         oSection:Cell( "F4_CREDICM"):SetValue( (cAliasTMP)->F4_CREDICM                                                                                     ) //--Credita ICMS
         oSection:Cell( "F4_IPI"    ):SetValue( (cAliasTMP)->F4_IPI                                                                                         ) //--Calcula IPI
         oSection:Cell( "F4_CREDIPI"):SetValue( (cAliasTMP)->F4_CREDIPI                                                                                     ) //--Credita IPI
         oSection:Cell( "D1_DOC"    ):SetValue( (cAliasTMP)->D1_DOC                                                                                         ) //--Nota Fiscal
         oSection:Cell( "NfPref"    ):SetValue( IIF( !AllTrim( (cAliasTMP)->F1_ESPECIE ) $ "RPS|NFS", (cAliasTMP)->D1_DOC, "")                                  ) //--Nf. Prefeitura
         oSection:Cell( "D1_SERIE"  ):SetValue( (cAliasTMP)->D1_SERIE                                                                                       ) //--Série
         oSection:Cell( "F1_ESPECIE"):SetValue( (cAliasTMP)->F1_ESPECIE                                                                                     ) //--Espécie
         oSection:Cell( "ModNot"    ):SetValue( AModNot( (cAliasTMP)->F1_ESPECIE )                                                                          ) //--Modelo
         oSection:Cell( "D1_DTDIGIT"):SetValue( IIF( Empty( SToD( (cAliasTMP)->D1_DTDIGIT ) ), "", SToD( (cAliasTMP)->D1_DTDIGIT ) )                        ) //--Dt. de Entrada
         oSection:Cell( "D1_EMISSAO"):SetValue( IIF( Empty( SToD( (cAliasTMP)->D1_EMISSAO ) ), "", SToD( (cAliasTMP)->D1_EMISSAO ) )                        ) //--Dt. de Emissão
         oSection:Cell( "D1_FORNECE"):SetValue( (cAliasTMP)->D1_FORNECE                                                                                     ) //--Fornecedor\Cliente
         oSection:Cell( "D1_LOJA"   ):SetValue( (cAliasTMP)->D1_LOJA                                                                                        ) //--Loja
         oSection:Cell( "CliFor"    ):SetValue( cCliFor                                                                                                     ) //--Nome
         oSection:Cell( "Chassi"    ):SetValue( IIF( (cAliasTMP)->F1_TIPO $ "B|D" , cCodChassi ,AllTrim( (cAliasTMP)->D1_CHASSI ) )                         ) //--Chassi
         oSection:Cell( "D1_COD"    ):SetValue( (cAliasTMP)->D1_COD                                                                                         ) //--Cód.Produto
         oSection:Cell( "B1_DESC"   ):SetValue( Substr( (cAliasTMP)->B1_DESC ,01 ,15 )                                                                      ) //--Descrição do Produto
         oSection:Cell( "DescrCient"):SetValue( AllTrim( Posicione("SB5",1,xFilial("SB5")+(cAliasTMP)->D1_COD,"B5_CEME") )                                  ) //--Descrição Científico
         oSection:Cell( "B1_XDESCL1"):SetValue( AllTrim( (cAliasTMP)->B1_XDESCL1 )                                                                          ) //--Descrição Longa
         oSection:Cell( "D1_UM"     ):SetValue( AllTrim( (cAliasTMP)->D1_UM )                                                                               ) //--Un Medida
         oSection:Cell( "D1_QUANT"  ):SetValue( (cAliasTMP)->D1_QUANT                                                                                       ) //--Quant.
         oSection:Cell( "D1_VUNIT"  ):SetValue( (cAliasTMP)->D1_VUNIT                                                                                       ) //--Valor Unit. Item
         //oSection:Cell( "F1_DESCONT"):SetValue( (cAliasTMP)->F1_DESCONT                                                                                     ) //--Desconto Item
         oSection:Cell( "FT_DESCONT"):SetValue( (cAliasTMP)->FT_DESCONT                                                                                     ) //--Desconto Item
         oSection:Cell( "D1_VALFRE" ):SetValue( (cAliasTMP)->D1_VALFRE                                                                                      ) //--Frete
         oSection:Cell( "D1_DESPESA"):SetValue( (cAliasTMP)->D1_DESPESA                                                                                     ) //--Despesas Acessorias
         oSection:Cell( "D1_SEGURO" ):SetValue( (cAliasTMP)->D1_SEGURO                                                                                      ) //--Seguro
         oSection:Cell( "D1_VALACRS"):SetValue( (cAliasTMP)->D1_VALACRS                                                                                     ) //--Acrescimo
         oSection:Cell( "D1_CUSTO"  ):SetValue( (cAliasTMP)->D1_CUSTO                                                                                       ) //--Custo
         oSection:Cell( "FT_ICMSCOM"):SetValue( (cAliasTMP)->FT_ICMSCOM                                                                                     ) //--Valor do Dif. de Aliq.
         oSection:Cell( "YD_PER_II" ):SetValue( (cAliasTMP)->YD_PER_II                                                                                      ) //--Aliq. II
         oSection:Cell( "D1_II"     ):SetValue( (cAliasTMP)->D1_II                                                                                          ) //--Valor II
         oSection:Cell( "D1_CONHEC" ):SetValue( (cAliasTMP)->D1_CONHEC                                                                                      ) //--Num. Conhecimento
         oSection:Cell( "W6_DI_NUM" ):SetValue( (cAliasTMP)->W6_DI_NUM                                                                                      ) //--Num. DI
         oSection:Cell( "W6_DTREG_D"):SetValue( IIF( Empty( SToD( (cAliasTMP)->W6_DTREG_D ) ), "", SToD( (cAliasTMP)->W6_DTREG_D ) )                        ) //--Data DI
         oSection:Cell( "D1_CONTA"  ):SetValue( (cAliasTMP)->D1_CONTA                                                                                       ) //--Conta Contábil
         oSection:Cell( "CT1_DESC01"):SetValue( AllTrim( Posicione("CT1",1,xFilial("CT1")+(cAliasTMP)->D1_CONTA,"CT1_DESC01") )                             ) //--Desc.Conta Contábil
         oSection:Cell( "D1_FILIAL" ):SetValue( AllTrim( (cAliasTMP)->D1_FILIAL )                                                                           ) //--Empresa
         oSection:Cell( "Situacao"  ):SetValue( cSituacao                                                                                                   ) //--Situação
         oSection:Cell( "TpNF"      ):SetValue( cTpNF                                                                                                       ) //--Tipo Nota Fiscal
         oSection:Cell( "FT_FORMUL" ):SetValue( (cAliasTMP)->FT_FORMUL                                                                                      ) //--Formulario
         oSection:Cell( "FT_CHVNFE" ):SetValue( (cAliasTMP)->FT_CHVNFE                                                                                      ) //--Chave Nota Fiscal
         oSection:Cell( "D1_NFORI"  ):SetValue( AllTrim( (cAliasTMP)->D1_NFORI ) + " - " + AllTrim( (cAliasTMP)->D1_SERIORI )                               ) //--Nota Fiscal Origem
         oSection:Cell( "DescTipo"  ):SetValue( cDescTipo                                                                                                   ) //--Tipo Cli\For
         oSection:Cell( "TpCliFor"  ):SetValue( cTpCliFor                                                                                                   ) //--Cli\For
         oSection:Cell( "X5_DESCRI" ):SetValue( AllTrim(Posicione("SX5",1, xFilial("SX5")+"12"+ cEstCli ,"X5_DESCRI"))                                      ) //--Estado
         oSection:Cell( "CC2_MUN"   ):SetValue( AllTrim(Posicione("CC2",1, xFilial("CC2")+ cEstCli +PadR( cCodMun ,TamSx3("CC2_CODMUN")[1]) , "CC2_MUN"))   ) //--Município
         oSection:Cell( "B1_CEST"   ):SetValue( AllTrim( (cAliasTMP)->B1_CEST )                                                                             ) //--CEST
         oSection:Cell( "DesMod"    ):SetValue( AllTrim( cDesMod )                                                                                          ) //--Descr. Modelo Veículo
         oSection:Cell( "ComVei"    ):SetValue( AllTrim( cComVei )                                                                                          ) //--Combustível Veículo
         oSection:Cell( "F4_TEXTO"  ):SetValue( AllTrim( (cAliasTMP)->F4_TEXTO )                                                                            ) //--Descrição CFOP
         oSection:Cell( "F1_CODNFE" ):SetValue( (cAliasTMP)->F1_CODNFE                                                                                      ) //--Cód.Verificação
         oSection:Cell( "FT_BASEIRR"):SetValue( (cAliasTMP)->FT_BASEIRR                                                                                     ) //--Base Irrf Retenção
         oSection:Cell( "FT_ALIQIRR"):SetValue( (cAliasTMP)->FT_ALIQIRR                                                                                     ) //--Aliq. Irrf Retenção
         oSection:Cell( "FT_VALIRR" ):SetValue( (cAliasTMP)->FT_VALIRR                                                                                      ) //--Irrf Retenção
         oSection:Cell( "FT_BASEINS"):SetValue( (cAliasTMP)->FT_BASEINS                                                                                     ) //--Base Inss
         oSection:Cell( "FT_ALIQINS"):SetValue( (cAliasTMP)->FT_ALIQINS                                                                                     ) //--Aliq. Inss
         oSection:Cell( "D1_ABATINS"):SetValue( (cAliasTMP)->D1_ABATINS                                                                                     ) //--Inss Recolhido
         oSection:Cell( "FT_VALINS" ):SetValue( (cAliasTMP)->FT_VALINS                                                                                      ) //--Valor Inss
         oSection:Cell( "D1_BASEISS"):SetValue( (cAliasTMP)->D1_BASEISS                                                                                     ) //--Base Iss
         oSection:Cell( "D1_ALIQISS"):SetValue( (cAliasTMP)->D1_ALIQISS                                                                                     ) //--Aliq. Iss
         oSection:Cell( "D1_ABATISS"):SetValue( (cAliasTMP)->D1_ABATISS                                                                                     ) //--Iss Serviços
         oSection:Cell( "D1_ABATMAT"):SetValue( (cAliasTMP)->D1_ABATMAT                                                                                     ) //--Iss Materiais
         oSection:Cell( "D1_VALISS" ):SetValue( (cAliasTMP)->D1_VALISS                                                                                      ) //--Valor Iss
         oSection:Cell( "D1_AVLINSS"):SetValue( (cAliasTMP)->D1_AVLINSS                                                                                     ) //--Inss Serviços
         oSection:Cell( "FT_BASECSL"):SetValue( (cAliasTMP)->FT_BASECSL                                                                                     ) //--Base Csll
         oSection:Cell( "FT_ALIQCSL"):SetValue( (cAliasTMP)->FT_ALIQCSL                                                                                     ) //--Aliq. Csll
         oSection:Cell( "FT_VALCSL" ):SetValue( (cAliasTMP)->FT_VALCSL                                                                                      ) //--Valor Csll
         oSection:Cell( "FT_BRETPIS"):SetValue( (cAliasTMP)->FT_BRETPIS                                                                                     ) //--Base Pis Retenção
         oSection:Cell( "FT_ARETPIS"):SetValue( (cAliasTMP)->FT_ARETPIS                                                                                     ) //--Aliq. Pis Retenção
         oSection:Cell( "FT_VRETPIS"):SetValue( (cAliasTMP)->FT_VRETPIS                                                                                     ) //--Valor Pis Retenção
         oSection:Cell( "FT_BRETCOF"):SetValue( (cAliasTMP)->FT_BRETCOF                                                                                     ) //--Base Cofins Retenção
         oSection:Cell( "FT_ARETCOF"):SetValue( (cAliasTMP)->FT_ARETCOF                                                                                     ) //--Aliq. Cofins Retenção
         oSection:Cell( "FT_VRETCOF"):SetValue( (cAliasTMP)->FT_VRETCOF                                                                                     ) //--Valor Cofins Retenção
         oSection:Cell( "F1_MENNOTA"):SetValue( (cAliasTMP)->F1_MENNOTA                                                                                     ) //--Msgn Nota Fiscal
         oSection:Cell( "LogInc"    ):SetValue( cLogInc                                                                                                     ) //--Log. de Inclusão
         oSection:Cell( "LogAlt"    ):SetValue( cLogAlt                                                                                                     ) //--Log. de Alteração
         oSection:Cell( "DtLogAlt"  ):SetValue( cDtLogAlt                                                                                                   ) //--Dt. Log. de Alteração
         oSection:Cell( "C7_NUM"    ):SetValue( (cAliasTMP)->C7_NUM                                                                                         ) //--Num. Pedido Compra
         oSection:Cell( "CodNatur"  ):SetValue( cCodNatur                                                                                                   ) //--Natureza Financeira
         oSection:Cell( "D1_TNATREC"):SetValue( (cAliasTMP)->D1_TNATREC                                                                                     ) //--Tab. Nat. Receita
         oSection:Cell( "D1_ITEMCTA"):SetValue( (cAliasTMP)->D1_ITEMCTA                                                                                     ) //--Item Contábil
         oSection:Cell( "F3_ISENICM"):SetValue( (cAliasTMP)->F3_ISENICM                                                                                     ) //--ICMS Isento
         oSection:Cell( "F3_OUTRICM"):SetValue( (cAliasTMP)->F3_OUTRICM                                                                                     ) //--ICMS Outros
         oSection:Cell( "F3_ISENIPI"):SetValue( (cAliasTMP)->F3_ISENIPI                                                                                     ) //--IPI Isento
         oSection:Cell( "F3_OUTRIPI"):SetValue( (cAliasTMP)->F3_OUTRIPI                                                                                     ) //--IPI Outros
         oSection:Cell( "D1_PESO"   ):SetValue( (cAliasTMP)->D1_PESO                                                                                        ) //--Peso Total
         oSection:Cell( "FT_CODBCC" ):SetValue( (cAliasTMP)->FT_CODBCC                                                                                      ) //--Natureza Base de Calculo
         oSection:Cell( "FT_INDNTFR"):SetValue( (cAliasTMP)->FT_INDNTFR                                                                                     ) //--Natureza Frete
         oSection:Cell( "F1_UFORITR"):SetValue( (cAliasTMP)->F1_UFORITR                                                                                     ) //--UF Origem do Transporte
         oSection:Cell( "F1_MUORITR"):SetValue( (cAliasTMP)->F1_MUORITR                                                                                     ) //--Mun. Orig. do Transporte
         oSection:Cell( "F1_UFDESTR"):SetValue( (cAliasTMP)->F1_UFDESTR                                                                                     ) //--UF Destino do Transporte
         oSection:Cell( "F1_MUDESTR"):SetValue( (cAliasTMP)->F1_MUDESTR                                                                                     ) //--Mun. Dest. do Transporte	
         oSection:Cell( "F4_DUPLIC" ):SetValue( Alltrim( (cAliasTMP)->F4_DUPLIC )                                                                           ) //--Gera Duplicata
         oSection:Cell( "W9_TX_FOB" ):SetValue( (cAliasTMP)->W9_TX_FOB                                                                                      ) //-- Taxa Cambial'
         oSection:PrintLine()	

	    (cAliasTMP)->(dbSkip() )
	
	EndDo               
	oSection:Finish()	           

Return

//--------------------------
Static Function ZTmpRadio1()
//--------------------------

    Local cQuery    	:= ""
    
	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

	cQuery += " SELECT 	D1_FILIAL , D1_COD    , D1_DOC    , D1_SERIE  , D1_TES   , D1_CF     , D1_FORNECE, D1_LOJA  , D1_EMISSAO, D1_DTDIGIT, "	+ CRLF
	cQuery += "         D1_ITEM   , F4_FINALID, F4_TEXTO  , FT_CTIPI  , FT_CSTPIS, FT_CSTCOF , F4_ICM    , F4_IPI   , F4_CREDICM, F4_CREDIPI, F4_DUPLIC, " + CRLF
	cQuery += "	        B1_DESC   , B1_XDESCL1, B1_GRUPO  , B1_POSIPI , B1_CEST  , B1_ORIGEM , B1_EX_NCM , B1_EX_NBM, " + CRLF
	cQuery += "	        F1_ESPECIE, F1_CODNFE , F1_MENNOTA, F1_DOC    , F1_SERIE , F1_STATUS , F1_TIPO   , FT_CHVNFE, " + CRLF
	cQuery += "         FT_VALCONT, FT_DESCONT, D1_CONTA  , D1_ITEMCTA, D1_NFORI , D1_SERIORI, D1_VUNIT  , D1_TOTAL , " + CRLF
	cQuery += "         CASE " + CRLF
    cQuery += "             WHEN F1_DESCONT > 0 THEN " + CRLF
    cQuery += "                 ROUND(((D1_TOTAL / F1_DESCONT) * F1_DESCONT),2)" + CRLF
    cQuery += "             WHEN F1_DESCONT = 0 THEN " + CRLF
    cQuery += "                 F1_DESCONT " + CRLF
    cQuery += "         END AS F1_DESCONT, " + CRLF
    cQuery += "         FT_CLASFIS, FT_BASERET, FT_ICMSRET, D1_DESCZFP, D1_DESCZFC," + CRLF
    cQuery += "         F1_UFORITR, F1_MUORITR, F1_UFDESTR, F1_MUDESTR, " + CRLF
	cQuery += "         FT_BASEICM, FT_ALIQICM, FT_VALICM , FT_BRETPIS, FT_ARETPIS, FT_VRETPIS, FT_BRETCOF, FT_ARETCOF, FT_VRETCOF, " + CRLF
	cQuery += "         FT_BASEIPI, FT_ALIQIPI, FT_VALIPI , " + CRLF
	cQuery += "         D1_BASIMP6, D1_ALQIMP6, D1_VALIMP6, D1_BASIMP5, D1_ALQIMP5, D1_VALIMP5, " + CRLF
	cQuery += "         FT_BASEPIS, FT_ALIQPIS, FT_VALPIS , FT_ALIQPS3, FT_VALPS3 , " + CRLF
	cQuery += "         FT_BASECOF, FT_ALIQCOF, FT_VALCOF , FT_DIFAL  , FT_BASECF3, FT_ALIQCF3, FT_VALCF3 , FT_BASEPS3, " + CRLF
	cQuery += "         FT_BASEIRR, FT_ALIQIRR, FT_VALIRR , F3_OUTRIPI, F3_ISENIPI, F3_OUTRICM, F3_ISENICM, " + CRLF
	cQuery += "         FT_BASECSL, FT_ALIQCSL, FT_VALCSL , D1_UM     , D1_QUANT  , D1_CHASSI , " + CRLF
	cQuery += "         FT_BASEINS, FT_ALIQINS, D1_ABATINS, D1_AVLINSS, FT_VALINS , C7_NUM    , FT_FORMUL , " + CRLF
	cQuery += "         D1_BASEISS, D1_ALIQISS, D1_ABATISS, D1_ABATMAT, D1_VALISS , FT_CODBCC , FT_INDNTFR, " + CRLF
	cQuery += "         D1_VALFRE , D1_DESPESA, D1_CUSTO  , D1_SEGURO , D1_VALACRS, D1_II     , FT_ICMSCOM, D1_TNATREC, D1_CONHEC, " + CRLF
	cQuery += "         D1_PESO   , FT_MVALPIS, FT_MVALCOF, W6_DTREG_D, W6_DI_NUM , " + CRLF

	cQuery += "        ( Select SYD.YD_PER_II from " + RetSqlName("SYD") + " SYD " + CRLF
 	cQuery += "	          where SYD.YD_FILIAL  = '" +  FWxFilial('SYD') + "' " + CRLF
	cQuery += "	        	AND SYD.YD_TEC     = SB1.B1_POSIPI " + CRLF
	cQuery += "	        	AND SYD.YD_EX_NCM  = SB1.B1_EX_NCM " + CRLF
	cQuery += "	        	AND SYD.YD_EX_NBM  = SB1.B1_EX_NBM " + CRLF
    cQuery += "	        	AND SYD.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "	        	AND     ROWNUM     = 1 " + CRLF
    cQuery += "	        	) as YD_PER_II,  " + CRLF

    cQuery += "         VRK_OPCION, W9_TX_FOB " + CRLF

	cQuery += " FROM " + RetSQLName('SD1') + " SD1 "																				+ CRLF

	cQuery += " INNER JOIN " + RetSQLName('SF1') + " SF1 "			 																+ CRLF
	cQuery += " 	ON  SF1.F1_FILIAL  = '" + FWxFilial('SF1') + "' "																    + CRLF	
	cQuery += " 	AND SF1.F1_DOC     = SD1.D1_DOC " 																					+ CRLF
	cQuery += " 	AND SF1.F1_SERIE   = SD1.D1_SERIE " 																				+ CRLF
	cQuery += " 	AND SF1.F1_FORNECE = SD1.D1_FORNECE " 																			+ CRLF
	cQuery += " 	AND SF1.F1_LOJA    = SD1.D1_LOJA " 																				+ CRLF
	cQuery += " 	AND SF1.F1_ESPECIE BETWEEN '" +MV_PAR03+ "' AND '" +MV_PAR04+ "' " 												+ CRLF
	cQuery += " 	AND SF1.D_E_L_E_T_ = ' ' " 																						+ CRLF	

	If !Empty(MV_PAR19)
		cQuery += " 	AND SF1.F1_EST = '" + MV_PAR19 + "' "																		+ CRLF
	EndIf 

	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1  " 																		+ CRLF
	cQuery += " 	ON  SB1.B1_FILIAL  = '" + FWxFilial('SB1') + "'  "															    + CRLF
	cQuery += "		AND SB1.B1_COD     = SD1.D1_COD  "	 																				+ CRLF
	cQuery += "     AND SB1.D_E_L_E_T_ = ' '   " 																					+ CRLF
	
	If !Empty( MV_PAR20 )
		cQuery += " 	AND SB1.B1_GRUPO = '" + MV_PAR20 + "' "																		+ CRLF
	EndIf

	If !Empty( MV_PAR21 )
		cQuery += " 	AND SB1.B1_POSIPI = '" + MV_PAR21 + "' "																	+ CRLF
	EndIf

	cQuery += " INNER JOIN " + RetSQLName("SF4") + " SF4 " 																			+ CRLF
	cQuery += " 	ON  SF4.F4_FILIAL  = '" + FWxFilial('SF4') + "'  "															    + CRLF
	cQuery += "		AND SF4.F4_CODIGO  = SD1.D1_TES  "	 																			+ CRLF
	cQuery += "     AND SF4.D_E_L_E_T_ = ' '   " 																					+ CRLF

	cQuery += " LEFT JOIN " + RetSQLName("SW6") + " SW6  " 																			+ CRLF
	cQuery += " 	ON  SW6.W6_FILIAL  = '" + FWxFilial('SW6') + "' "																    + CRLF
	cQuery += "		AND SW6.W6_HAWB    = SD1.D1_CONHEC  "	 																			+ CRLF
	cQuery += "     AND SW6.D_E_L_E_T_ = ' '   " 																					+ CRLF

    cQuery += " LEFT JOIN " + RetSQLName("SW9") + " SW9  " 																			+ CRLF
	cQuery += " 	ON  SW9.W9_FILIAL  = '" + FWxFilial('SW9') + "' "																	+ CRLF
	cQuery += "		AND SW9.W9_HAWB    = SD1.D1_CONHEC  "	 																			+ CRLF
	cQuery += "     AND SW9.D_E_L_E_T_ = ' '   " 																					+ CRLF
/*
	cQuery += " LEFT JOIN " + RetSQLName("SYD") + " SYD  " 																			+ CRLF
	cQuery += " 	ON SYD.YD_FILIAL = '" + FWxFilial('SYD') + "' "																    + CRLF
    cQuery += "		AND SYD.YD_TEC = SB1.B1_POSIPI "	 																			+ CRLF
	cQuery += "		AND SYD.YD_EX_NCM = SB1.B1_EX_NCM  "	 																		+ CRLF
	cQuery += "		AND SYD.YD_EX_NBM = SB1.B1_EX_NBM  "	 																		+ CRLF
	cQuery += "     AND SYD.D_E_L_E_T_ = ' '   " 																					+ CRLF
*/
	cQuery += " LEFT JOIN " + RetSQLName("VVF") + " VVF "																			+ CRLF
	cQuery += "		ON  VVF.VVF_FILIAL = '" + FWxFilial('VVF') + "' "															    + CRLF
	cQuery += " 	AND VVF.VVF_NUMNFI = SF1.F1_DOC "																				+ CRLF
	cQuery += " 	AND VVF.VVF_SERNFI = SF1.F1_SERIE " 																			+ CRLF
	cQuery += " 	AND VVF.VVF_CODFOR = SF1.F1_FORNECE " 																			+ CRLF
	cQuery += " 	AND VVF.VVF_LOJA   = SF1.F1_LOJA " 																				+ CRLF
	cQuery += " 	AND VVF.D_E_L_E_T_ = ' ' "																	 					+ CRLF

	cQuery += " LEFT JOIN " + RetSQLName("SC7") + " SC7 "																			+ CRLF
	cQuery += " 	ON  SC7.C7_FILIAL  = '" + FWxFilial('SC7') + "' "																    + CRLF
	cQuery += "		AND SC7.C7_NUM     = SD1.D1_PEDIDO "																				+ CRLF
	cQuery += "		AND SC7.C7_ITEM    = SD1.D1_ITEMPC "												 								+ CRLF
	cQuery += "		AND SC7.D_E_L_E_T_ = ' ' "																						+ CRLF
	
	cQuery += " LEFT JOIN " + RetSQLName("VRK") + " VRK "																			+ CRLF
	cQuery += " 	ON  VRK.VRK_FILIAL = '" + FWxFilial('VRK') + "' "  															    + CRLF
	cQuery += "		AND VRK.VRK_PEDIDO = SD1.D1_PEDIDO	"																			+ CRLF
    cQuery += "     AND VRK.VRK_ITEPED = SD1.D1_ITEMPC	"																			+ CRLF
	cQuery += "     AND VRK.D_E_L_E_T_ = ' '   " 																					+ CRLF

	cQuery += " INNER JOIN " + RetSQLName("SFT") + " SFT " 																			+ CRLF
	cQuery += "		ON  SFT.FT_FILIAL  = '" + FWxFilial('SFT') + "' "																    + CRLF
	cQuery += "		AND SFT.FT_TIPOMOV = 'E' "																						+ CRLF
	cQuery += "		AND SFT.FT_SERIE   = SD1.D1_SERIE "																				+ CRLF
	cQuery += " 	AND SFT.FT_NFISCAL = SD1.D1_DOC "																				+ CRLF
	cQuery += "		AND SFT.FT_CLIEFOR = SD1.D1_FORNECE " 																			+ CRLF
	cQuery += "		AND SFT.FT_LOJA    = SD1.D1_LOJA " 																				+ CRLF
	cQuery += "		AND SFT.FT_ITEM    = SD1.D1_ITEM " 																				+ CRLF
	cQuery += "		AND SFT.FT_PRODUTO = SD1.D1_COD " 																				+ CRLF	
	cQuery += "		AND SFT.D_E_L_E_T_ = ' ' "																						+ CRLF

	cQuery += " INNER JOIN " + RetSQLName("SF3") + " SF3 " 																			+ CRLF
	cQuery += "		ON  SF3.F3_FILIAL  = '" + FWxFilial('SF3') + "' "																    + CRLF
	cQuery += "		AND SF3.F3_SERIE   = SFT.FT_SERIE "																				+ CRLF
	cQuery += "		AND SF3.F3_NFISCAL = SFT.FT_NFISCAL "																			+ CRLF
	cQuery += " 	AND SF3.F3_CLIEFOR = SFT.FT_CLIEFOR "																			+ CRLF
	cQuery += "		AND SF3.F3_LOJA    = SFT.FT_LOJA " 																				+ CRLF
	cQuery += "		AND SF3.F3_IDENTFT = SFT.FT_IDENTF3 " 																			+ CRLF
	cQuery += "		AND SF3.D_E_L_E_T_ = ' ' "																						+ CRLF

	cQuery += " WHERE   SD1.D1_FILIAL  BETWEEN '" +       MV_PAR01   + "' AND '" +       MV_PAR02   + "' " 											+ CRLF
	cQuery += " 	AND SD1.D1_DOC     BETWEEN '" +       MV_PAR05   + "' AND '" +       MV_PAR06   + "' " 												+ CRLF
	cQuery += " 	AND SD1.D1_SERIE   BETWEEN '" +       MV_PAR07   + "' AND '" +       MV_PAR08   + "' " 											+ CRLF
	cQuery += " 	AND SD1.D1_FORNECE BETWEEN '" +       MV_PAR09   + "' AND '" +       MV_PAR10   + "' " 											+ CRLF
	cQuery += " 	AND SD1.D1_DTDIGIT BETWEEN '" + DToS( MV_PAR11 ) + "' AND '" + DToS( MV_PAR12 ) + "' " 							+ CRLF
	cQuery += " 	AND SD1.D1_EMISSAO BETWEEN '" + DToS( MV_PAR13 ) + "' AND '" + DToS( MV_PAR14 ) + "' " 							+ CRLF
	cQuery += " 	AND SD1.D1_COD     BETWEEN '" +       MV_PAR15   + "' AND '" +       MV_PAR16   + "' " 												+ CRLF
	cQuery += " 	AND SD1.D_E_L_E_T_ = ' ' "	 																					+ CRLF

	If !Empty( MV_PAR17 )
		cQuery += " 	AND SD1.D1_TES = '" + MV_PAR17 + "' " 																		+ CRLF
	EndIf

	If !Empty( MV_PAR18 )
		cQuery += " 	AND SD1.D1_CF = '" + MV_PAR18 + "' " 																		+ CRLF
	EndIf  

    If !Empty( MV_PAR23) .OR. !Empty( MV_PAR24 )
       cQuery += " 	AND SD1.D1_CHASSI BETWEEN '" + MV_PAR23 + "' AND '" + MV_PAR24 + "' " 
    EndIf
    
	cQuery += " GROUP BY 	D1_FILIAL , D1_COD    , D1_DOC    , D1_SERIE  , D1_TES    , D1_CF     , D1_FORNECE, D1_LOJA   , " + CRLF
	cQuery += "             D1_EMISSAO, D1_DTDIGIT, D1_CONTA  , D1_ITEMCTA, D1_NFORI  , D1_SERIORI, D1_VUNIT  , D1_TOTAL  , " + CRLF
	cQuery += "             D1_BASIMP6, D1_ALQIMP6, D1_VALIMP6, D1_UM     , D1_QUANT  , D1_CHASSI , D1_DESCZFP, D1_DESCZFC, " + CRLF
	cQuery += "             D1_BASIMP5, D1_ALQIMP5, D1_VALIMP5, D1_PESO   , D1_ABATINS, D1_AVLINSS, D1_ITEM   , D1_SEGURO , " + CRLF
	cQuery += "             D1_BASEISS, D1_ALIQISS, D1_ABATISS, D1_ABATMAT, D1_VALISS , FT_CODBCC , FT_INDNTFR, D1_CONHEC , " + CRLF
	cQuery += "             D1_VALFRE , D1_DESPESA, D1_CUSTO  , D1_VALACRS, D1_II     , D1_TNATREC,  " + CRLF
	
    cQuery += "	            F1_ESPECIE, F1_CODNFE, F1_MENNOTA, F1_DOC, F1_SERIE, F1_STATUS, F1_TIPO," + CRLF
    cQuery += "             F1_UFORITR, F1_MUORITR, F1_UFDESTR, F1_MUDESTR,  " + CRLF
    cQuery += "             CASE "  + CRLF
    cQuery += "                 WHEN F1_DESCONT > 0 THEN "  + CRLF
    cQuery += "                     ROUND(((D1_TOTAL / F1_DESCONT) * F1_DESCONT),2)"  + CRLF
    cQuery += "                 WHEN F1_DESCONT = 0 THEN "  + CRLF
    cQuery += "                     F1_DESCONT "  + CRLF
    cQuery += "             END,  "  + CRLF
	
    cQuery += "             F3_OUTRIPI, F3_ISENIPI, F3_OUTRICM, F3_ISENICM, "
    cQuery += "             FT_CLASFIS, FT_BASERET, FT_ICMSRET, FT_VRETPIS, FT_BRETCOF, FT_CHVNFE , FT_FORMUL , FT_MVALPIS , " + CRLF
	cQuery += "             FT_BASEICM, FT_ALIQICM, FT_VALICM , FT_BRETPIS, FT_ARETPIS, FT_ARETCOF, FT_VRETCOF, FT_DESCONT , " + CRLF
	cQuery += "             FT_BASEIPI, FT_ALIQIPI, FT_VALIPI , FT_CTIPI  , FT_CSTPIS , FT_CSTCOF , FT_VALINS , FT_VALCONT , " + CRLF
	cQuery += "             FT_BASEPIS, FT_ALIQPIS, FT_VALPIS , FT_ALIQPS3, FT_VALPS3 , FT_ICMSCOM, FT_MVALCOF, FT_ALIQINS , " + CRLF
	cQuery += "             FT_BASECOF, FT_ALIQCOF, FT_VALCOF , FT_DIFAL  , FT_BASECF3, FT_ALIQCF3, FT_VALCF3 , FT_BASEPS3 , " + CRLF
	cQuery += "             FT_BASEIRR, FT_ALIQIRR, FT_VALIRR , FT_BASECSL, FT_ALIQCSL, FT_VALCSL , FT_BASEINS, " + CRLF
	cQuery += "             F4_FINALID, F4_TEXTO  , F4_ICM    , F4_IPI    , F4_CREDICM, F4_CREDIPI, F4_DUPLIC , " + CRLF
    cQuery += "             W6_DTREG_D, W6_DI_NUM , VRK_OPCION, W9_TX_FOB , C7_NUM, " + CRLF
	cQuery += "             B1_DESC   , B1_XDESCL1, B1_GRUPO, B1_POSIPI   , B1_CEST   , B1_ORIGEM , B1_EX_NCM , B1_EX_NBM " + CRLF

	cQuery += " ORDER BY SD1.D1_FILIAL, SD1.D1_EMISSAO, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_ITEM, SD1.D1_FORNECE, SD1.D1_LOJA "		+ CRLF

	cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return

/*
=====================================================================================
Programa.:              ZRel0003
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              26/02/20
Descricao / Objetivo:   Realiza consulta na tabela CDA e alimenta as variaveis de IPI
Doc. Origem:            
Solicitante:            
Uso......:              zRel0002
Obs......:
=====================================================================================
*/
Static Function ZRel0003( nVlIPIRegi, nVlIPIPres, cEspecie, cDoc, cSerie, cCodCli, cCodLoja, cItem )

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
