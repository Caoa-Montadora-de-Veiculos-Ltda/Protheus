#Include "Protheus.Ch"
#Include "TopConn.Ch"
/*
=====================================================================================
Programa.:              ZGENF053.PRW
Autor....:              CAOA - Sandro Ferreira 
Data.....:              18/09/2023
Descricao / Objetivo:   Funcao generica para pesquisar usuarios cadastrados na SX5
Doc. Origem:            
Solicitante:            
Uso......:              CAOA Montadora de Veiculos.
Obs......:
=====================================================================================
*/
User Function ZCOMF053( cParam01, cParam02 )

Local cUser     := cParam01
Local cDepto    := cParam02
Local lRet      := .F.
Local _cEmp  	:= FWCodEmp()

IF _cEmp <> "2010" 
   DbSelectArea("SX5")
   SX5->(DbSetOrder(1)) 

   //Verifica se usuário é de compras ou fiscal
   If SX5->( dbSeek( xFilial("SX5") + cDepto + cUser ) )
      lRet := .T.
   ENDIF
ELSE
   lRet    := .T.
ENDIF

Return(lRet)
