#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} CMVEST05
//TODO Descrição Contabilização da baixa/estorno da Requisição de Almoxarifado
@author marcelo.moraes
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param cLancPadrao, characters, descricao
@type function
/*/
user function CMVEST05(cLancPadrao)	

local aArea        := GetArea()
local aAreaSGS     := SGS->(GetArea())
local nHdlPrv      := 0
local lHead        := .T.
local cLote        := "008840"
local cArquivo     := " "
local nTotal	   := 0
local lDigita      
local lAglut       

Pergunte("MTA240",.F.)
lDigita := IIF(MV_PAR01==1,.T.,.F.)
lAglut := IIF(MV_PAR02==1,.T.,.F.)

SGS->(dbSetOrder(1))
SGS->(DbSeek(SCP->(CP_FILIAL + CP_NUM + CP_ITEM),.F.))

While !SGS->(EOF()) .AND. SGS->GS_FILIAL == SCP->CP_FILIAL .and. SGS->GS_SOLICIT == SCP->CP_NUM .and.;
                      SGS->GS_ITEMSOL == SCP->CP_ITEM
    if lHead
    	nHdlPrv:=HeadProva(cLote,"MATA185",Substr(cUsuario,7,6),@cArquivo)
    	lHead := .F.
    endif
    
    nTotal  += DetProva(nHdlPrv,cLancPadrao,"MATA185",cLote)
    
    SGS->(DbSkip())

EndDo

if nTotal>0

	RodaProva(nHdlPrv,nTotal)

	cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)
	
Endif

RestArea(aAreaSGS)
RestArea(aArea)

return

/*/{Protheus.doc} TemRatCC
//TODO Descrição Verifica se a Solicitação da Requisição possui rateio por Centro de Custo  
@author marcelo.moraes
@since 04/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function TemRatCC(lPosSCP)

local lRet 
local aArea     	:= GetArea()
local aAreaSCP      := SCP->(GetArea())
local cAliasSCP 	:= GetNextAlias()

DEFAULT lPosSCP := .F.

if lPosSCP //.T. - Sera necessario posicionar na tabela SCP, .F. - Tabela SCP já esta posicionada

	SCP->(dbSetOrder(1))
	If !SCP->(dbSeek(SD3->(D3_FILIAL+D3_NUMSA+D3_ITEMSA)))
	
		RestArea(aAreaSCP)
		RestArea(aArea)
		
		return(.F.)
		
	Endif

endif

BeginSQL Alias cAliasSCP
	
	SELECT 
		CP_FILIAL, CP_NUM, CP_ITEM, GS_ITEM 
	 FROM 
	 	%table:SCP% SCP
	 	INNER JOIN %table:SGS% SGS ON GS_FILIAL=CP_FILIAL AND GS_SOLICIT=CP_NUM AND GS_ITEMSOL = CP_ITEM
	WHERE 
		SCP.%NotDel% AND
		SGS.%NotDel% AND
		CP_FILIAL=%Exp:SCP->CP_FILIAL% AND
		CP_NUM=%Exp:SCP->CP_NUM% 
		
EndSQL

If (cAliasSCP)->(Eof())
	lRet := .F.
else
	lRet := .T.
endif

(cAliasSCP)->(DbCloseArea())

RestArea(aAreaSCP)
RestArea(aArea)

return(lRet)

