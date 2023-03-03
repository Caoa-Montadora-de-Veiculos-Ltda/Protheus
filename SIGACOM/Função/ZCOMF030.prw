#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} ZCOMF030
P.E. - Incluir Observação na cotação
@author
@since 21/10/2020

@version 1.0
@type function
/*/
User Function ZCOMF030()
Local _oObscmp
Public cC8_SCOT := space(10)

    IF _NumCot <> SC8->C8_NUM

        Define Font oFont Name 'Mono AS' Size 7, 15

        Define MsDialog oDlg Title 'Observação para a Cotação' From 3, 0 to 340, 417 Pixel
        @ 5, 5 Get _oObscmp Var cC8_SCOT Memo Size 200, 145 Of oDlg Pixel
        _oObscmp:oFont := oFont
        Define SButton From 153, 177 Type 1 Action oDlg:End() Enable Of oDlg Pixel
        Activate MsDialog oDlg Center

        _NumCot  :=  SC8->C8_NUM

    ENDIF

Return()
