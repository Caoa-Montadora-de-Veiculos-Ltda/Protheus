#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MTCHKNFE � Autor � Deivys Joenck       � Data � 01/01/2019 ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MTCHKNFE()
Local aDados := PARAMIXB[1]
Local lRet   := .T.


If(Type("cEspecie")<>"U" .And. cEspecie<>Nil)

	If AllTrim(cEspecie)=='NFS'
		If Empty(aDados[2]) 
			Aviso("Aten��o: Campo obrigat�rio!", "Para a inclus�o de Notas Fiscais de Servi�o, o C�digo de Verifica��o da Nota Fiscal Eletr�nica � obrigat�rio!", {"Ok"})
			lRet := .F.
		Endif
	Endif
EndIf


Return lRet

