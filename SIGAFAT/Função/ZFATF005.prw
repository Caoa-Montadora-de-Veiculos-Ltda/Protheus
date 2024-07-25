#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'parmtype.ch'
/*/                                                                                                                                  {Protheus.doc} U_ZFATF005
@param
@author Antonio Oliveira
@version P12.1.23
@since 20/03/20
@return SX1 pergunta "ZFATF005 "
@obs
@project
@history carrega dados padrões para o acols do PV
         Criado pesquisa no campo Tipo de Operação (L. 49) 31/03/23 - A.Carlos
/*/
User Function ZFATF005()

//Local _nPosPU  := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_PRCVEN'}) 
Local _aArea         := GetArea()
Local _cGrupo        := Space(4)
Local _cPC           := Space(6)
Local _cTipo         := Space(2)
Local _nLaco         := 0
Local aPergs         := {}
Local lEnder         := .T.
Local _lWLocaliz     := IIf(AllTrim(FWCodEmp())=='2010','.T.','.F.')
Local _lOLocaliz     := IIf(AllTrim(FWCodEmp())=='2010',.T.,.F.)
Local _lOTpOper      := IIf(AllTrim(FWCodEmp())=='2010',.F.,.T.)

Private _cCLVL    := space(11)
Private _cCusto   := space(11)
Private _cLocal   := space(03)
Private _cLocliz  := space(15)
Private _cOperac  := space(02)
Private _cPerg    := "ZFATF005  "
Private _cTes     := space(03)
Private _nPosCC   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_CC' })
Private _nPosCL   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_CLVL' })
Private _nPosLiz  := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_LOCALIZ' })
Private _nPosLoc  := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_LOCAL' })
Private _nPosOper := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_OPER' })
Private _nPosTes  := Ascan(aHeader,{|x| Alltrim(x[2]) == 'C6_TES' })
Private aRetP     := {}

aadd(aPergs, {1, "TES "            , _cTes   , "@!", '.T.', "SF4", '.T.'      , 25, .F.         })
aadd(aPergs, {1, "Armazém "        , _cLocal , "@!", '.T.', " "  , '.T.'      , 25, .T.         })
aAdd(aPergs, {1 ,"Tipo Operação "  , Space(5), ""  , ""   , "DJ" ,  ""        , 10, _lOTpOper   })
aadd(aPergs, {1, "Centro de Custo ", _cCusto , "@!", '.T.', "CTT", '.T.'      , 80, .T.         })
aadd(aPergs, {1, "Endereço "       , _cLocliz, "@!", '.T.', "SBE", _lWLocaliz , 50, _lOLocaliz  })


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe  Pedido de Vendas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cPC    := M->C5_NUM
_cTipo  := SB1->B1_TIPO
_cGrupo := SB1->B1_GRUPO

IF _cTipo <> 'SV' .AND. _cGrupo <> 'VEIA'

   If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , ,.F.,.F.)

      DEFINE MSDIALOG oDlg FROM 96,9 TO 310,592 TITLE OemToAnsi("inclusão dados padrões no PV") PIXEL
      @ 18, 6 TO 66, 287 LABEL "" OF oDlg PIXEL
      @ 29, 15 SAY OemToAnsi("Esta rotina realiza a inclusão de dados padrões no PV") SIZE 268, 8 OF oDlg PIXEL
      @ 38, 15 SAY OemToAnsi("Da Caoa Montadora.") SIZE 268, 8 OF oDlg PIXEL
      @ 48, 15 SAY OemToAnsi("Confirma Geração do Documento ? ") SIZE 268, 8 OF oDlg PIXEL
      DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
      DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
      ACTIVATE MSDIALOG oDlg CENTER

      //Validar o armazém com o endereço p/ dar continuidade
      If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
         lEnder   := VerArm()
      EndIf

      If nOpca == 0 .Or. lEnder = .F.
         Return()
      Endif

      _cCusto  := PadR( AllTrim( aRetP[4] ) , TamSX3( "C6_CC" )[1]," ")
      _cLocal  := PadL( AllTrim( aRetP[2] ) , TamSX3( "C6_LOCAL" )[1]," ")
      _cLocliz := PadR( AllTrim( aRetP[5] ) , TamSX3( "C6_LOCALIZ" )[1]," ")
      _cOperac := PadL( AllTrim( aRetP[3] ) , TamSX3( "C6_OPER" )[1]," ")
      _cTes    := PadL( AllTrim( aRetP[1] ) , TamSX3( "C6_TES" )[1]," ")
   EndIf

   dbSelectArea( "SX1" )
   dbSetOrder( 1 )

   If !( DbSeek( _cPerg + '01' ))
      //RecLock("SX1",.T.)
      //SX1->X1_TES   := _cTes   
      //SX1->X1_LOCAL := _cLocal
      //SX1->X1_OPER  := _cOperac
      //SX1->X1_CCUS  := _cCusto
      //MsUnlock()	
   Else
      For _nLaco    := 1 to 05 //Numero de perguntas no SX1
         DO CASE
         CASE _nLaco = 1
            DbSeek( _cPerg + '01' )
            RecLock("SX1",.F.)
            SX1->X1_CNT01 := _cTes
            MsUnlock()
         CASE _nLaco = 2
            DbSeek( _cPerg + '02' )
            RecLock("SX1",.F.)
            SX1->X1_CNT01 := _cLocal
            MsUnlock()
         CASE _nLaco = 3
            DbSeek( _cPerg + '03' )
            RecLock("SX1",.F.)
            SX1->X1_CNT01 := _cOperac
            MsUnlock()
         CASE _nLaco = 4
            DbSeek( _cPerg + '04' )
            RecLock("SX1",.F.)
            SX1->X1_CNT01 := _cCusto
            MsUnlock()
         CASE _nLaco = 5
            DbSeek( _cPerg + '05' )
            RecLock("SX1",.F.)
            SX1->X1_CNT01 := _cLocliz
            MsUnlock()
         ENDCASE
      Next

   EndIF

ENDIF

RestArea(_aArea)
Return()

/*/                                                                                                                                  {Protheus.doc} U_ZFATF005
@param
@author Antonio Oliveira
@version P12.1.23
@since 11/09/20
@return
@obs indice (1) Filial + Local + Localiz (aRetP[2]+aRetP[5])
@project
@history Validar o armazém com o endereço
/*/
Static Function VerArm()
	Local cQry   := " "
	Local cAlias :=  GetNextAlias()
   Local lRet   := .T.

   If Select( (cAlias) ) > 0
	   (cAlias)->(DbCloseArea())
	EndIf

	cQry := " SELECT BE_LOCALIZ " + CRLF
	cQry += " FROM " + RetSQLName("SBE") + CRLF
	cQry += " WHERE BE_FILIAL = '" + FWxFilial("SBE") + "' " + CRLF
	cQry += " AND BE_LOCAL = '" + aRetP[2] + "' " + CRLF
 	cQry += " AND BE_LOCALIZ = '" + aRetP[5] + "' " + CRLF
   cQry += " AND D_E_L_E_T_ <> '*' " + CRLF

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ), cAlias, .F., .T. )

   IF !(cAlias)->(EOF())
      _cLocliz := (cAlias)->BE_LOCALIZ
      lRet     := .T.
   ELSE
      MsgInfo("Local incompatível com Endereço. " + aRetP[2] + " X " + aRetP[5] , " [ZFATF005]")
      lRet     := .F.
   ENDIF

	(cAlias)->(DbCloseArea())

Return(lRet)


