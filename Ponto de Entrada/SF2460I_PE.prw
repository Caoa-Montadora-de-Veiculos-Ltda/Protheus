#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SF2460I �Autor  �RAFAEL GARCIA   � Data �  25/02/2019   ���
�������������������������������������������������������������������������͹��
���Desc.     � O ponto de entrada SF2460I ap�s grava��o     ���
���          � da TudoOk na inclusao do contas a receber.                 ���
�������������������������������������������������������������������������͹��
���Uso       � Projeto Caoa                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SF2460I()

Local aArea := GetArea()

	If findfunction("U_CMVFAT01")
		U_CMVFAT01()
	Endif
		
RestArea(aArea)

Return() 	
	