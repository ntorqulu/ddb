--definir entitat mux4a1, multiplexor de 4 entrades 2 canals seleccio i una sortida
ENTITY mux4a1 IS
	PORT(
	a, b, c, d:IN BIT;
	sel1, sel0:IN BIT;
	f:OUT BIT);
END mux4a1;
--Implentem les arquitectures ifthen i logicaretard del multiplexor
ARCHITECTURE ifthen OF mux4a1 IS
BEGIN
PROCESS(a, b, c, d, sel1, sel0) IS
BEGIN
	IF (sel1 = '0' AND sel0 = '0') THEN f <= a;
	ELSIF(sel1 = '1' AND sel0 = '0') THEN f <= b;
	ELSIF(sel1 = '0' AND sel0 = '1') THEN f <= c;
	ELSE f <= d;
	END IF;
END PROCESS;
END ifthen;

ARCHITECTURE logica_retard OF mux4a1 IS
BEGIN--No ens indica quant retard ha de tindre arquitectura, l'he estipulat a 5 ns
	f <= (((NOT sel1) AND (NOT sel0) AND a) OR ((NOT sel1) AND sel0 AND b) OR (sel1 AND (NOT sel0) AND c) OR (sel1 ANd sel0 AND d)) AFTER 2 ns;)
END logica_retard;


-- definim entitat flip-flop D(no especifica com ha de ser, suposarem positive edge triggered)
ENTITY FF_D IS
	PORT(
	D, clock, Pre:IN BIT;
	Q:OUT BIT);
END FF_D;

ARCHITECTURE ifthen OF FF_D IS
BEGIN
PROCESS(clock, Pre)--tant un canvi en el clock com en el preset disparen el proces
BEGIN
	IF(Pre = '1') THEN Q<='0';--el preset te prioritat al ser asincron
	ELSIF(clock'EVENT AND clock='1') THEN Q<=D;--si no exiteix preset i hi ha hagut flanc pujada clock
	END IF;
END PROCESS;
END ifthen;

-- definim entitat registre amb la seva arquitectura estructural
ENTITY registre IS
	PORT(
	a2, a1, a0, sel1, sel0, E, clock:IN BIT;
	Q2, Q1, Q0:OUT BIT);
END registre;

ARCHITECTURE estructural OF registre IS

COMPONENT comp_mux4a1 IS
	PORT(
	a, b, c, d:IN BIT;
	sel1, sel0:IN BIT;
	f:OUT BIT);
END COMPONENT;

COMPONENT comp_FF_D IS
	PORT(
	D, clock, Pre:IN BIT;
	Q:OUT BIT);
END COMPONENT;

FOR DUT1: comp_mux4a1 USE ENTITY WORK.mux4a1(logica_retard);
FOR DUT2: comp_mux4a1 USE ENTITY WORK.mux4a1(logica_retard);
FOR DUT3: comp_mux4a1 USE ENTITY WORK.mux4a1(logica_retard);
FOR DUT4: comp_FF_D USE ENTITY WORK.FF_D(ifthen);
FOR DUT5: comp_FF_D USE ENTITY WORK.FF_D(ifthen);
FOR DUT6: comp_FF_D USE ENTITY WORK.FF_D(ifthen);

SIGNAL muxout0, muxout1, muxout2, dffout0, dffout1, dffout2, constA, constPre:BIT;

BEGIN
	constPre <= '0';
	constA <= '1';
	DUT1: comp_mux4a1 PORT MAP(constA, dffout0, a0, dffout1, sel1, sel0,muxout0);
	DUT2: comp_mux4a1 PORT MAP(constA, dffout1, a1, dffout2, sel1, sel0,muxout1);
	DUT3: comp_mux4a1 PORT MAP(constA, dffout2, a2, E, sel1, sel0,muxout2);
	DUT4: comp_FF_D PORT MAP(muxout2, clock, constPre, dffout2);
	DUT5: comp_FF_D PORT MAP(muxout1, clock, constPre, dffout1);
	DUT6: comp_FF_D PORT MAP(muxout0, clock, constPre, dffout0);
	Q2<=dffout2;
	Q1<=dffout1;
	Q0<=dffout0;
END estructural;

ENTITY bdp IS
END bdp;

ARCHITECTURE test OF bdp IS

COMPONENT registre IS
PORT(
	a2, a1, a0, sel1, sel0, E, clock:IN BIT;
	Q2, Q1, Q0:OUT BIT);
END COMPONENT;

SIGNAL ent2, ent1, ent0, sel1, sel0, E, clock, Q2, Q1, Q0:BIT;
FOR DUT1:registre USE ENTITY WORK.registre(estructural);
BEGIN
DUT1:registre PORT MAP(ent2, ent1, ent0, sel1, sel0, E, clock, Q2, Q1, Q0);
ent2 <= NOT ent2 AFTER 2000 ns;
ent1 <= NOT ent1 AFTER 1000 ns;
ent0 <= NOT ent0 AFTER 800 ns;
sel1 <= NOT sel1 AFTER 400 ns;
sel0 <= NOT sel0 AFTER 200 ns;
clock <= NOT clock AFTER 100 ns;
E <= NOT E AFTER 50 ns;
END test;
