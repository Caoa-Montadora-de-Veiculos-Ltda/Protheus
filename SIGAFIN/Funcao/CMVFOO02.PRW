#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FWBROWSE.CH" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FILEIO.CH" 

*/
* Programa..............: CMVFOO02
* Author................: Edson Deluca
* Data..................: 24/09/2018
* Descrição / Objetivo..: FWmBrowse de Tabela de limite de crédito
* Doc. Origem...........: Contrato - GAP FIS46
* Solicitante...........: CAOA             
* USO...................:
* Observação............: Criado tabela ZZ7  
*/

**********************
User Function CMVLIM()
********************** 

Local abkRotina    := aRotina
Private aCores    := { {"ZZ7_SINALT=='-'",'BR_VERMELHO' },; 
					   {"ZZ7_SINALT==' '",'BR_VERDE' }} 

Private cCadastro   := 'Limite de Crédito' 
Private aRotina     := {}

//AADD(aRotina, { 'Pesquisar'   , 'AxPesqui'    , 0, 1 })
AADD(aRotina, { 'Visualizar'  , 'AxVisual'    , 0, 2 })
AADD(aRotina, {'Pesquisar'    , 'AxPesqui'    , 0, 1 })
AADD(aRotina, {"Importar"     , "U_LIMIMP()"  , 0, 3, 0, Nil })
AADD(aRotina, {"Legenda"      , "U_LIMLEG()"  , 0, 6, 0, Nil })


ChkFile('ZZ7')
dbSelectArea('ZZ7')
ZZ7->(dbSetOrder(1))

mBrowse(6, 1, 22, 75, 'ZZ7',,,,,,aCores)

aRotina    := abkRotina   


Return NIL

************************
User Function LIMLEG()
************************
Local aLegenda:= {}             
                                      
AADD(aLegenda, {"BR_VERMELHO"	 ,'Negativo'})
AADD(aLegenda, {"BR_VERDE" ,'Positivo'})

BrwLegenda('Limite de Credito','Taura',aLegenda)

Return( Nil )

********************
User Function LIMIMP
********************
 
PRIVATE aArq := {}

fx02LerArq()           

MsAguarde({|| fProcessaArq(@aArq)})  

Return

******************************
Static Function fProcessaArq()
******************************     

Local I             := 1
Private cZZ7_CNPJ   := ""
Private nZZ7_VALLIM := 0
Private nZZ7_VALGAT := 0
Private cZZ7_SINAL  := ""
Private nZZ7_VALDIS := 0
Private cZZ7_SINALT := ""
Private nZZ7_VALTOT := 0
Private cZZ7_INDBLQ := ""
Private cZZ7_BLOQUE := ""
Private dZZ7_DATA   := CtoD("  /  /  ")
Private cZZ7_HORA   := ""
          
For I:=1 to Len(aArq)               
                                 
    cZZ7_CNPJ   := Substr(aArq[I],1,15)
    nZZ7_VALLIM := Val(Substr(aArq[I],16,17))/100
    nZZ7_VALGAT := Val(Substr(aArq[I],33,17))/100
    cZZ7_SINAL  := Substr(aArq[I],50,1)
    nZZ7_VALDIS := Val(Substr(aArq[I],51,17))/100
    cZZ7_SINALT := Substr(aArq[I],68,1)
    nZZ7_VALTOT := Val(Substr(aArq[I],69,17))/100
    cZZ7_INDBLQ := Substr(aArq[I],86,1)  
    cZZ7_BLOQUE := Substr(aArq[I],87,7)
    dZZ7_DATA   := dDataBase
    cZZ7_HORA   := Time()
    
	MsProcTxt('Lendo Limites '+cZZ7_CNPJ)
                                   
    U_UPDZZ7()    
    
Next I

msgstop("Fim de Processamento")

Return   

****************************
Static Function fx02LerArq()
****************************

Local cArq  := ""
	
	//Pede pra escolher o arquivo
	cArq := cGetFile("*.txt |*.TXT  |","Selecione o Caminho....",0,,.F.,GETF_LOCALHARD+GETF_OVERWRITEPROMPT)
    cNomeArq := cArq
    
	//Valida arquivo
	If !file(cArq)
		Aviso("Arquivo","Arquivo não selecionado ou invalido.",{"Sair"},1)
		Return
    EndIf
		
	If (nHandle := FT_FUse(cArq))== -1
		Help(" ",1,"NOFILEIMPOR")
		Return
	EndIf

	MsAguarde({|| fLerArq(@aArq)})  

	If Aviso('Confirmacao','Foram lidas '+Alltrim(Str(Len(aArq)))	+" linhas."+CRLF+'Confirma importacao?.',{'Importar','Cancelar'}) == 1
		Return(aArq)
	Endif

Return(aArq)    
       
*****************************
Static Function fLerArq(aArq)
*****************************

Local cLinha	:=	""
Local nCampo	:=	1
Local aArqTmp	:=	{}
Local nCnt		:=	0 
aArq			:=	{}

	FT_FGOTOP()
	
	While !FT_FEOF()
		
		nCnt++
		If Mod(nCnt,10) == 0
			MsProcTxt('Lendo linha '+StrZero(nCnt,6))
		Endif
		
		cLinha  := FT_FREADLN()
		
		AADD(aArq,cLinha)
		
		FT_FSKIP()
	
	Enddo
	
	FT_FUSE()
	
Return  

**********************
User Function UPDZZ7()
**********************

Local xStatus := ""

dbSelectArea("ZZ7")
dbSetOrder(1)
If !dbSeek(xFilial("ZZ7")+cZZ7_CNPJ,.F.)
   If RecLock("ZZ7",.T.)
      ZZ7->ZZ7_FILIAL := xFilial("ZZ7")
      ZZ7->ZZ7_CNPJ   := cZZ7_CNPJ
      ZZ7->ZZ7_VALLIM := nZZ7_VALLIM
      ZZ7->ZZ7_VALGAT := nZZ7_VALGAT
      ZZ7->ZZ7_SINAL  := cZZ7_SINAL
      ZZ7->ZZ7_VALDIS := nZZ7_VALDIS
      ZZ7->ZZ7_SINALT := cZZ7_SINALT
      ZZ7->ZZ7_VALTOT := nZZ7_VALTOT
      ZZ7->ZZ7_INDBLQ := cZZ7_INDBLQ
      ZZ7->ZZ7_BLOQUE := cZZ7_BLOQUE
      ZZ7->ZZ7_DATA   := dZZ7_DATA
      ZZ7->ZZ7_HORA   := cZZ7_HORA
      MsUnLock("ZZ7")
   EndIf
Else
   If RecLock("ZZ7",.F.)
      ZZ7->ZZ7_VALLIM := nZZ7_VALLIM
      ZZ7->ZZ7_VALGAT := nZZ7_VALGAT
      ZZ7->ZZ7_SINAL  := cZZ7_SINAL
      ZZ7->ZZ7_VALDIS := nZZ7_VALDIS
      ZZ7->ZZ7_SINALT := cZZ7_SINALT
      ZZ7->ZZ7_VALTOT := nZZ7_VALTOT
      ZZ7->ZZ7_INDBLQ := cZZ7_INDBLQ
      ZZ7->ZZ7_BLOQUE := cZZ7_BLOQUE
      ZZ7->ZZ7_DATA   := dZZ7_DATA
      ZZ7->ZZ7_HORA   := cZZ7_HORA
      MsUnLock("ZZ7")
   EndIf
EndIf

Return
