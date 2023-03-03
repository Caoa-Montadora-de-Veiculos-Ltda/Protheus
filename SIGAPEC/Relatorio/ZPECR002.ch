#ifdef SPANISH
	#define STR0001 "Saldos en Stock"
	#define STR0002 "Este programa emitira un resumen de los saldos, en cantidad,"
	#define STR0003 "de los productos en stock."
	#define STR0004 " Por Codigo         "
	#define STR0005 " Por Tipo           "
	#define STR0006 " Por Descripcion  "
	#define STR0007 " Por Grupo        "
	#define STR0008 "A Rayas"
	#define STR0009 "Administracion"
	#define STR0010 "GRUP CODIGO ITEM                 CODIGO          TP DESCRIPCION         UM FL          AMZ     CANTIDAD"
	#define STR0011 "Tipo.........."
	#define STR0012 "Grupo........."
	#define STR0013 "ANULADO POR EL OPERADOR"
	#define STR0014 "Total del Producto"
	#define STR0015 "Saldos en Stock"
	#define STR0016 "Seccion 1"
	#define STR0017 "Selecionando Archivos..."
	#define STR0018 "Total del "
	#define STR0019 "Item"
#else
	#ifdef ENGLISH
		#define STR0001 "Balance on Inventory"
		#define STR0002 "This program will print a summary of balances, by quantity, "
		#define STR0003 "referring to products on Inventory."
		#define STR0004 " By Code            "
		#define STR0005 " By Type            "
		#define STR0006 " By Description   "
		#define STR0007 " By Group         "
		#define STR0008 "Z.Form"
		#define STR0009 "Management"
		#define STR0010 "GROUP CODE ITEM                  CODE            TYPE DESCRIPTION     UM BR        WAREH     AMOUNT    "
		#define STR0011 "Type.........."
		#define STR0012 "Group........."
		#define STR0013 "CANCELLED BY THE OPERATOR"
		#define STR0014 "Total of Product"
		#define STR0015 "Stock Balance"
		#define STR0016 "Section 1"
		#define STR0017 "Selecting Files..."
		#define STR0018 "Total "
		#define STR0019 "Item"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Saldos Em Stock", "Saldos em Estoque" )
		#define STR0002 "Este programa ira' emitir um resumo dos saldos ,em quantidade,"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Dos produtos em stock.", "dos produtos em estoque." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", " por código         ", " Por Codigo         " )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", " por tipo           ", " Por Tipo           " )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", " por descrição    ", " Por Descricao    " )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", " por grupo        ", " Por Grupo        " )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Administração", "Administracao" )
		#define STR0010 "GRUP CÓDIGO ITEM                 CÓDIGO          TP DESCRIÇÃO         UM FL           AMZ     QUANTIDADE     MARCA      LINHA      FAMÍLIA"
		#define STR0011 "Tipo.........."
		#define STR0012 "Grupo........."
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Cancelado Pelo Operador", "CANCELADO PELO OPERADOR" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Total Do Artigo", "Total do Produto" )
		#define STR0015 "Saldos em Estoques"
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Seção 1", "Secao 1" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "A seleccionar registos ...", "Selecionando Registros..." )
		#define STR0018 "Total do "
		#define STR0019 "Item"
		#define STR0020 " (por MLF) "
		#define STR0021 "Grupo/Tipo/Marca/Linha/Família"
	#endif
#endif
