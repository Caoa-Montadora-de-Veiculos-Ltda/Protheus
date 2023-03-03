#Include 'Protheus.ch'

/*/{Protheus.doc} OX016GLB
Respons�vel por retornar status ap�s "0" a libera��o
@author 	DAC-Denilso
@since 		15/03/2022
@version 	undefined
@param 		 
@project    7.11.1 - SER� NECESS�RIO SEGUIR PARA O AVAN�O DE FASE CUSTOMIZADO
@type 		user function
@obs		fun��o para retornar status do or�amento 0 conforme Jose Carlos n�o pode avan�ar Fase deve retornar para o inicio para rodar na pr�xima onda
@menu       Nao Informado
@return		_lRet 		- Verdadeiro ou falso
@history    
/*/

User Function OX016GLB()
Local _cFaseOrc := AllTrim(GetNewPar("MV_FASEORC","0")) 
Local _cFaseAnt := VS1->VS1_NUMORC
Local _cFase 	

Begin Sequence
	_cFase 	:= SubsTr(_cFaseOrc,1,1)
	VS1->(RecLock("VS1",.f.))
	VS1->VS1_STATUS := _cFase
	VS1->(MsUnlock())
	MsgInfo("Fase do or�amento "+VS1->VS1_NUMORC+" passado para a Fase Inicial ","ATENCAO")
	If FindFunction("FM_GerLog")
		//grava log das alteracoes das fases do orcamento
		FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,_cFaseAnt)
	EndIF
End Sequence
Return Nil
