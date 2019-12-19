ENTITY bdp_portes IS
END bdp_portes;

ARCHITECTURE test OF bdp_portes IS

COMPONENT la_porta_and2
	PORT(a, b:IN BIT; z:OUT BIT);
END COMPONENT;

COMPONENT la_porta_and3
	PORT(a, b, c:IN BIT; z:OUT BIT);
END COMPONENT;

COMPONENT la_porta_and4
	PORT(a, b, c, d:IN BIT; z:OUT BIT);
END COMPONENT;

COMPONENT la_porta_or2
	PORT(a, b:IN BIT; z:OUT BIT);
END COMPONENT;

COMPONENT la_porta_or3
	PORT(a, b, c:IN BIT; z:OUT BIT);
END COMPONENT;

COMPONENT la_porta_or4
	PORT(a, b, c, d:IN BIT; z:OUT BIT);
END COMPONENT;

COMPONENT la_porta_inversor
	PORT(a:IN BIT; z:OUT BIT);
END COMPONENT;

SIGNAL ent1, ent2, ent3, ent4, sort_and2_logica, sort_and2_retard, sort_and3_logica, sort_and3_retard, sort_and4_logica, sort_and4_retard, sort_or2_logica, sort_or2_retard, sort_or3_logica, sort_or3_retard, sort_or4_logica, sort_or4_retard, sort_inversor_logica, sort_inversor_retard:BIT;

for DUT1: la_porta_and2 USE ENTITY WORK.and2(logica);
for DUT2: la_porta_and3 USE ENTITY WORK.and3(logica);
for DUT3: la_porta_and4 USE ENTITY WORK.and4(logica);
for DUT4: la_porta_or2 USE ENTITY WORK.or2(logica);
for DUT5: la_porta_or3 USE ENTITY WORK.or3(logica);
for DUT6: la_porta_or4 USE ENTITY WORK.or4(logica);
for DUT7: la_porta_inversor USE ENTITY WORK.inversor(logica);

---implementem les logicaretard, unim amb entity
for DUT8: la_porta_and2 USE ENTITY WORK.and2(logicaretard);
for DUT9: la_porta_and3 USE ENTITY WORK.and3(logicaretard);
for DUT10: la_porta_and4 USE ENTITY WORK.and4(logicaretard);
for DUT11: la_porta_or2 USE ENTITY WORK.or2(logicaretard);
for DUT12: la_porta_and2 USE ENTITY WORK.or3(logicaretard);
for DUT13: la_porta_and2 USE ENTITY WORK.or4(logicaretard);
for DUT14: la_porta_and2 USE ENTITY WORK.inversor(logicaretard);




BEGIN
DUT1: la_porta_and2 PORT MAP(ent1, ent2, sort_and2_logica);
DUT2: la_porta_and3 PORT MAP(ent1, ent2,ent3, sort_and3_logica);
DUT3: la_porta_and4 PORT MAP(ent1, ent2,ent3, ent4, sort_and4_logica);
DUT4: la_porta_or2 PORT MAP(ent1, ent2, sort_or2_logica);
DUT5: la_porta_or3 PORT MAP(ent1, ent2,ent3, sort_or3_logica);
DUT6: la_porta_or4 PORT MAP(ent1, ent2, ent3, ent4, sort_or4_logica);
DUT7: la_porta_inversor PORT MAP(ent1, sort_inversor_logica);

DUT8: la_porta_and2 PORT MAP(ent1, ent2, sort_and2_retard);
DUT9: la_porta_and3 PORT MAP(ent1, ent2,ent3, sort_and3_retard);
DUT10: la_porta_and4 PORT MAP(ent1, ent2,ent3, ent4, sort_and4_retard);
DUT11: la_porta_or2 PORT MAP(ent1, ent2, sort_or2_retard);
DUT12: la_porta_or3 PORT MAP(ent1, ent2,ent3, sort_or3_retard);
DUT13: la_porta_or4 PORT MAP(ent1, ent2, ent3, ent4, sort_or4_retard);
DUT14: la_porta_inversor PORT MAP(ent1, sort_inversor_retard);





PROCESS(ent1, ent2, ent3, ent4)
BEGIN
ent1<=NOT ent1 AFTER 50 ns;
ent2 <= NOT ent2 AFTER 100 ns;
ent3 <= NOT ent3 AFTER 200 ns;
ent4 <= NOT ent4 AFTER 400 ns;
END PROCESS;
END test;
