#ifdef SPANISH
	#define STR0001 "Estado: Metas de ventas"
	#define STR0002 "A Rayas"
	#define STR0003 "Administración"
	#define STR0004 "VEI - Vehículos (VEN+VEU)"
	#define STR0005 "OFI - Taller (PCO+SRV)"
	#define STR0006 "BAL - Mostrador (PCA+PCV)"
	#define STR0007 "PEC - Piezas (BAL+PCO)"
	#define STR0008 "PCA - Piezas al por mayor"
	#define STR0009 "PCV - Piezas al por menor"
	#define STR0010 "PCO - Piezas Taller"
	#define STR0011 "SRV - Servicios"
	#define STR0012 "VEN - Vehículos nuevos"
	#define STR0013 "VEU - Vehículos usados"
	#define STR0014 "EMP - Empresa (BAL+OFI+VEI)"
	#define STR0015 "Mensual"
	#define STR0016 "Anual"
	#define STR0017 "1-Considerar de Lunes a Viernes"
	#define STR0018 "2-Considerar de Lunes a Sabado"
	#define STR0019 "3-Considerar de Lunes a Domingo"
	#define STR0020 "Metas de ventas"
	#define STR0021 "Prefijo"
	#define STR0022 "Tipo"
	#define STR0023 "Mes"
	#define STR0024 "Año"
	#define STR0025 "Día hábil"
	#define STR0026 "Mes     Meta mensual     Realizado  Meta Veh  Ctd Realiz    %Mes    %Año   Punto Equil  %PEMes  %PEAño"
	#define STR0027 "Mes     Meta mensual     Realizado     %Mes    %Año   Punto Equil  %PEMes  %PEAño"
	#define STR0028 "Día     Meta diaria      Realizado  Meta Veh  Ctd Realiz    %Día    %Mes   Punto Equil  %PEDía  %PEMes"
	#define STR0029 "Día     Meta diaria      Realizado     %Día    %Mes   Punto Equil  %PEDía  %PEMes"
	#define STR0030 "Metas de ventas"
#else
	#ifdef ENGLISH
		#define STR0001 "Statement: Sales Target       "
		#define STR0002 "Z. form"
		#define STR0003 "Management   "
		#define STR0004 "VEI - Vehicles (VEN+VEU)"
		#define STR0005 "OFI -Workshop (PCO+SRV)"
		#define STR0006 "BAL - Counter(PCA+PCV)"
		#define STR0007 "PEC - Parts (BAL+PCO)"
		#define STR0008 "PCA-Wholesale Parts"
		#define STR0009 "PCV - Retail Parts"
		#define STR0010 "PCO -Workshop Parts"
		#define STR0011 "SRV - Services"
		#define STR0012 "VEN-Brand New Vehicl"
		#define STR0013 "VEU - Used Vehicles  "
		#define STR0014 "EMP - Company (BAL+OFI+VEI)"
		#define STR0015 "Month."
		#define STR0016 "Yearl"
		#define STR0017 "1-Consider from Monday toFriday"
		#define STR0018 "2-Consider from Monday to Saturd"
		#define STR0019 "3-Consider from Monday to Sunday "
		#define STR0020 "Sales Target   "
		#define STR0021 "Prefix "
		#define STR0022 "Type"
		#define STR0023 "Mo."
		#define STR0024 "Yr."
		#define STR0025 "Week day"
		#define STR0026 "Mth     Mthly Goal      Executed  Goal Veh Qty Exec    %Mth    %Year   Balance Point  %BPMth  %BPYear"
		#define STR0027 "Mth     Mthly Goal      Executed     %Mth    %Year   Balance Point  %BPMth  %BPYear"
		#define STR0028 "Day     Daily Goal      Executed  Goal Veh Qty Exec    %Day    %Mth   Balance Point  %BPDay  %BPMth"
		#define STR0029 "Day     Daily Goal      Executed    %Day    %Mth   Balance Point  %BPDay  %BPMth"
		#define STR0030 "Sales Goal"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Demonstrativo: Metas De Vendas", "Demonstrativo: Metas de Vendas" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Administração", "Administracao" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Vei - veiculos (ven+veu)", "VEI - Veiculos (VEN+VEU)" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Ofi - oficina (pco+srv)", "OFI - Oficina (PCO+SRV)" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Bal - balção (pca+pcv)", "BAL - Balcao (PCA+PCV)" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Pec - pecas (bal+pco)", "PEC - Pecas (BAL+PCO)" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Pca - Peças Atacado", "PCA - Pecas Atacado" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Pcv - Peças Retalho", "PCV - Pecas Varejo" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Pco - Peças Oficina", "PCO - Pecas Oficina" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Srv - Serviços", "SRV - Servicos" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Ven - Veículos Novos", "VEN - Veiculos Novos" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Veu - Veículos Usados", "VEU - Veiculos Usados" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Emp - empresa (bal+ofi+veí)", "EMP - Empresa (BAL+OFI+VEI)" )
		#define STR0015 "Mensal"
		#define STR0016 "Anual"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "1-considerar De Segunda A Sexta", "1-Considerar de Segunda a Sexta" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "2-considerar De Segunda A Sábado", "2-Considerar de Segunda a Sabado" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "3-considerar De Segunda A Domingo", "3-Considerar de Segunda a Domingo" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Metas De Vendas", "Metas de Vendas" )
		#define STR0021 "Prefixo"
		#define STR0022 "Tipo"
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Mês", "Mes" )
		#define STR0024 "Ano"
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Dia útil", "Dia Util" )
		#define STR0026 "Mês     Meta Mensal      Realizado  Meta Veíc Qtd Realiz    %Mes    %Ano   Ponto Equil  %PEMes  %PEAno"
		#define STR0027 "Mês     Meta Mensal      Realizado     %Mês    %Ano   Ponto Equil  %PEMês  %PEAno"
		#define STR0028 "Dia     Meta Diaria      Realizado  Meta Veíc Qtd Realiz    %Dia    %Mês   Ponto Equil  %PEDia  %PEMês"
		#define STR0029 "Dia     Meta Diaria      Realizado     %Dia    %Mes   Ponto Equil  %PEDia  %PEMes"
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Meta de Vendas", "Metas de Vendas" )
	#endif
#endif
