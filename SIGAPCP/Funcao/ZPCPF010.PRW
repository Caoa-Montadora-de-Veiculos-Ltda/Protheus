#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

#include "Totvs.ch"
#include "Topconn.ch"
#Include "Rwmake.ch"
/*---------------------------------------------------------------------------------------
{Protheus.doc} ZPCPF010
Rdmake 	Visualização Importação recebida do MES 
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC - Denilso 
@single		14/10/2020
@version    Nao Informado
@since      Nao Informado  
@return    	Nil
@sample     Nao Informado
@obs        Recebe dados PCP do MES grava em tabela customizada e fica aguardando processamento arupado 
@project    CAOA - Processo Backflush 3_0 DEV01 - Especificação Funcional Correto_V2
@menu       Nao Informado
@history    

/*/

Static _oBrw

User Function ZPCPF010()
Local _cFunNameBkp 	:= SetFunName()
Local _aArea 	    := GetArea()
Local _cCab			:= "Backflush CAOA"

Begin Sequence
	If !U_ZGENUSER( RetCodUsr() ,"ZPCPF010" ,.T.)
		Break
	Endif 
	SetFunName('ZPCPF010')
	_oBrw := FWMBrowse():New()
    _oBrw:SetAlias("SZZ")
  	_oBrw:SetMenuDef('ZPCPF010') 
	_oBrw:SetUseFilter(.T.)
	_oBrw:DisableDetails() 
	_oBrw:AddLegend("ZZ_STATUS ==' '"	,"BLUE"  	,"Pendente"	 					,/*ID*/, /*Utiliza filtro*/) 
	_oBrw:AddLegend("ZZ_STATUS =='A'"	,"GREEN"   	,"Apontado"	 					,/*ID*/, /*Utiliza filtro*/) 
	_oBrw:AddLegend("ZZ_STATUS =='I'"   ,"BROWN"   	,"Informacoes"					,/*ID*/, /*Utiliza filtro*/) 
	_oBrw:AddLegend("ZZ_STATUS =='E'"   ,"RED"    	,"Possui Erros"					,/*ID*/, /*Utiliza filtro*/) 
	_oBrw:AddLegend("ZZ_STATUS =='D'"   ,"BLACK"   	,"Deletado"						,/*ID*/, /*Utiliza filtro*/) 
	_oBrw:AddLegend("ZZ_STATUS =='V'"   ,"YELLOW"  	,"Veiculo Existente (VV1)"		,/*ID*/, /*Utiliza filtro*/) 
	_oBrw:AddLegend("ZZ_STATUS =='C'"   ,"WHITE"  	,"Apontamento Cancelado"		,/*ID*/, /*Utiliza filtro*/) 
	_oBrw:AddLegend("ZZ_STATUS =='L'"   ,"PINK"  	,"Empréstimo Produção"			,/*ID*/, /*Utiliza filtro*/) 
	_oBrw:AddLegend("ZZ_STATUS =='F'"   ,"ORANGE"  	,"Empréstimo Ant.ao Fechamento"	,/*ID*/, /*Utiliza filtro*/) 
	_oBrw:AddLegend("ZZ_STATUS =='G'"   ,"GRAY"  	,"Erro Estorno do Empréstimo"	,	/*ID*/, /*Utiliza filtro*/) 
	_oBrw:AddLegend("ZZ_STATUS =='B'"   ,"BR_CANCEL","Bloqueio de Estoque - MV_DBLQMOV"	,/*ID*/, /*Utiliza filtro*/) 

	//AVALIAR QUANDO EXCLUSÃO SE COLOCA STATUS DIFERENCIADO
	_oBrw:SetDescription(_cCab) // Trilha de Segurança
	//_oBrw:SetFilterDefault( "@ ZZ_STATUS == "+_cStatus ) 
   	_oBrw:Activate()
End Sequence
SetFunName(_cFunNameBkp)
RestArea(_aArea)

Return Nil


//-------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef
@author DAC - Denilso
@since 01/09/2020
@version 1.0
/*/
//-------------------------------------
Static Function MenuDef()
Local _aRotina 	:= {}
Local _lZPCPF010PRC    	:= SuperGetMV( "CMV_PCP006"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade ZPCPF010

Begin Sequence	
		ADD OPTION _aRotina TITLE "Visualizar"	ACTION "U_Z1PCPF010VI()"  OPERATION 2 ACCESS 0
	If _lZPCPF010PRC
		ADD OPTION _aRotina TITLE "Processar"	ACTION "U_ZPCPJ002()"	  OPERATION 8 ACCESS 0
		ADD OPTION _aRotina TITLE "Excluir"		ACTION "U_Z2PCPF010DE()"  OPERATION 1 ACCESS 0
	Endif
	ADD OPTION _aRotina TITLE "Pesquisar"  		ACTION 'PesqBrw' 		  OPERATION 1 ACCESS 0
End Sequence
Return _aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author DAC- Denilso
@since 01/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
//bAvalCampo Bloco de Código de avaliação do dicionário de dados. O bloco recebe como parâmetro o ID do campo e deve retornar um lógico. Se retornar verdadeiro o campo é incluído na estrutura.
//lViewUsado indica que deverá considerar os campos que não estão marcados como usado no dicionário de dados. Utilizado somente para o tipo 2-Browse.
//lVirtual Indica que deverá considerar os campos virtuais no dicionário de dados. Utilizado somente para o tipo 2-Browse.
//lFilOnView Indica que deverá considerar o campo de filial na view.
//cProgram Nome do programa executado, quando for para abrir um browse, determina se deveremos considerar os campos localizados.

Local oStr1 := FWFormStruct( 1, 'SZZ', /*bAvalCampo*/, /*lViewUsado*/,  /*lVirtual*/ , /*lFilOnView*/,/*cProgram*/) // Construção de uma estrutura de dados
Begin Sequence	
	//Cria o objeto do Modelo de Dados
    //Irie usar uma função QCP1VLD que será acionada quando eu clicar no botão "Confirmar"
	oModel := MPFormModel():New('ZPCPF010MOD', /*bPreValidacao*/ , /*{ | oModel | QCP1VLD( oModel ) } */, /*{ | oMdl | MVC001C( oMdl ) }*/ ,, /*bCancel*/ )
	oModel:SetDescription('Backflush CAOA')
	
	//oStr1:setProperty("ZZ_STATUS",MODEL_FIELD_WHEN,{||ALTERA})		

	oModel:addFields('SZZMASTER',,oStr1)
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:addFields('SZZMASTER',,oStr1,/*{|oModel|MntModel(oModel)}*/,,)
	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'ZZ_FILIAL', 'ZZ_CHASSI', "ZZ_STATUS" })
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('SZZMASTER'):SetDescription('Backflush CAOA')
End Begin	
Return oModel


//-------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		
/*/
//-------------------------------------
Static Function ViewDef()
// Inicia a View com uma View ja existente
//Local oStr1		:= FWFormStruct(2, 'SZW')
Local oModel 	:= ModelDef()
//Local oStr1		:= FWFormStruct(2,'SZZ',{|cCampo| AllTrim(cCampo) $ "ZW_FILIAL|ZW_CHASSI|ZW_CODPROD|ZW_DESCPRD|ZW_STATUS|ZW_MOMUSU|ZW_CODUSU|ZW_DATALEI|ZW_HORALEI|ZW_DTMOVIM|ZW_HRMOVIM"})
Local oStr1		:= FWFormStruct(2,'SZZ')

Local oView 	

Begin Sequence
	oView 	:= FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_SZZ" , oStr1,"SZZMASTER" )
	oView:CreateHorizontalBox( "BOXFORM1", 100)
	oView:SetOwnerView("VIEW_SZZ","BOXFORM1")
	oView:SetDescription('Backflush CAOA')
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
End Sequence
Return oView

//-------------------------------------
/*/{Protheus.doc} Z1PCPF010VI
Dados de importação do MES para Protheus
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		
/*/
//-------------------------------------
User Function Z1PCPF010VI()
Private  cCadastro := "Backflush CAOA"
AxVisual("SZZ",SZZ->( RecNo() ),2)
Return Nil

//Marcar rgistros como deletados
User Function Z2PCPF010DE()
Local _cStatus		:= " ' ','E','I' "
//Verificar processado não deixar apagar
Begin Sequence
	//Verifica se esta marcado como deletado
	If !_cStatus $ SZZ->ZZ_STATUS
		MSGInfo( "Status do apontamento"+SZZ->ZZ_STATUS+", não permite atualização !","ATENCAO")
		Break
	Endif 
	If SZZ->ZZ_STATUS == "D" .and. !MsgYesNo( "Registro ja marcado como deletado deseja recuperar ? " )
		Break
	//Confirma deleção	
	ElseIf SZZ->ZZ_STATUS <> "D" .and. !MsgYesNo( "Deseja marcar registro como deletado ? " )
		Break
	Endif
	RecLock('SZZ', .F. )
	SZZ->ZZ_STATUS	:= If(SZZ->ZZ_STATUS == "D","","D")
	SZZ->ZZ_DTAPONT	:=  Date()
	SZZ->ZZ_HRAPONT	:= Time()
	SZZ->ZZ_USUAPON	:= RetCodUsr()	
	SZZ->(MsUnlock())
End Sequende
Return Nil


//-------------------------------------
/*/{Protheus.doc} ZPCP10PBF
//Pausar Backflush com paramentro no JOB fazer a verificação
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		
/*/
//-------------------------------------
Static Function ZPCP10PBF()
Local _lZPCPJ001    	:= SuperGetMV( "CMV_PCP007"  ,,.F.)  //parametro para habilitar/desabilitar funcionalidade ZPCPF010
Local _cMsg
Begin Sequence
	If !U_ZGENUSER( RetCodUsr() ,"ZPCP10PBF" ,.T.)
		Break
	Endif 
	_cMsg := "Deseja "+If(_lZPCPJ001,"Pausar","Liberar")+" BackFlush 3.0 ?"
	If MsgYesNo( _cMsg )
		PUTMV("CMV_PCP007",If( _lZPCPJ001,.F.,.T.))
		_oBrw:Refresh(.T.)
	EndIf	
End Sequence
Return Nil
