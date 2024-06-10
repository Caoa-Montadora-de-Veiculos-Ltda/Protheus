/*/{Protheus.doc} ZREMXML
@author 	  A.Carlos
@since 		  21/12/2023
@version 	  undefined
@param		  _lJob
@type 		  User Function
@client   	CAOA 
@return   	cRet com o texto de XML efetuado correções
@project 	  Usado no Projeto de integração da ASIA Shipping
/*/

#define CRLF Chr(13) + Chr(10)
 
User Function ZREMXML(cTexto)
  Local cEncodeUTF8 := ""
  Local cDecodeUTF8 := ""
  //Local cMensagem   := ""
   
  cEncodeUTF8 := EncodeUTF8(cTexto, "cp1252")
  cDecodeUTF8 := DecodeUTF8(cEncodeUTF8, "cp1252")
  //cMensagem += CRLF + "Texto -> UTF8: [" + cEncodeUTF8 + "]"
  //cMensagem += CRLF + "UTF8 -> Texto: [" + cDecodeUTF8 + "]"
  //MsgInfo(cMensagem, "Exemplo")

    
    //--Substituindo caracteres
    cRet := strtran (cTexto, "\'e3o", "são")
    cRet := strtran (cRet, "\'e1" , "má" )    
    cRet := strtran (cRet, "\'e7" , "" ) 
    cRet := strtran (cRet, "\'f5" , "çõ" ) 
    cRet := strtran (cRet, "\'fa" , "ú" ) 
    cRet := strtran (cRet, "\'ea" , "ê" )   
    cRet := strtran (cRet, "\'e0" , "a" )  
    cRet := strtran (cRet, "\'e9s" , "és" )  

 Return(cRet)
