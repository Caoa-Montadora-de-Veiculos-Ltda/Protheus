#INCLUDE "rwmake.ch"

/*/{Protheus.doc} AJUSTSE1
//TODO Descrição auto-gerada.
@author marcelo.moraes
@since 06/01/2018
@version undefined
@type function
/*/
User Function AJUSTVV1()  

local cCaminho  := cGetFile( '*.CSV' , 'Textos (CSV)',,,.T.,,,) 
private cDrive, cDir, cNome, cExt

SplitPath( cCaminho, @cDrive, @cDir, @cNome, @cExt )

If Upper(cExt) <> ".CSV"
	MsgStop("Informe arquivo com extensão CSV")
	return
Endif

Processa({|| AtuArquivo(cCaminho) },"Processando...")

Return 

/*/{Protheus.doc} AtuArquivo
//TODO Descrição auto-gerada.
@author marcelo.moraes
@since 06/01/2018
@version undefined
@param cCaminho, characters, descricao
@type function
/*/
Static Function AtuArquivo(cCaminho)

local nRegAtu   := 0
local nRegLidos := 0
local aLinha    := {}
Local cBuffer   := ""
Local nHandle   := 0
Local cChassi   := ""
//Local cParcela  := ""
//Local cTipo     := ""

nHandle := FT_FUSE(cCaminho)

IF nHandle == -1
   MsgStop("Não foi possível abrir o arquivo: "+cCaminho)
   Return
ENDIF

FT_FGOTOP()

procregua(3562) //11777

While !FT_FEOF() 

   IncProc()
   cBuffer := FT_FREADLN()
   aLinha := Separa( AllTrim(cBuffer) ,";",.T.) 
   
   cChassi := PadR(aLinha[1],TAMSX3("VV1_CHASSI")[1])

 	DbSelectArea("VV1")  
	VV1->(DbSetOrder(2))
	VV1->(DbSeek(xFilial("VV1")+cChassi)) 
	if VV1->(Found())
		RecLock("VV1",.F.)
		VV1->VV1_DI 	:= aLinha[2] //DI
		VV1->VV1_DTDI	:= Ctod(aLinha[3]) //DTDI	
		VV1->(MsUnLock())
		nRegAtu++
	endif

    nRegLidos++
    
    FT_FSKIP()

EndDo

If !FCLOSE(nHandle)	
      MsgStop("Erro ao fechar arquivo, erro numero: ",FERROR() )
EndIf

FT_FUSE()

msginfo(alltrim(str(nRegLidos))+" Regs lidos " + " - " + alltrim(str(nRegAtu))+" CHASSIS atualizados ","")

return
