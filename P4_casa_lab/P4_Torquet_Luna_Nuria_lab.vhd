ENTITY and2 IS
	PORT(a, b:IN BIT; z:OUT BIT);
END and2;

ENTITY nand3 IS
	PORT(a, b, c:IN BIT; z:OUT BIT);
END nand3;


ENTITY or2 IS
	PORT(a, b:IN BIT; z:OUT BIT);
END or2;

ENTITY inv IS
	PORT(a:IN BIT; z:OUT BIT);
END inv;

ARCHITECTURE logica_retard OF and2 IS
	BEGIN
	z <= a AND b AFTER 2 ns;
END logica_retard;

ARCHITECTURE logica_retard OF nand3 IS
	BEGIN
	z <= NOT(a AND b AND c) AFTER 2 ns;
END logica_retard;

ARCHITECTURE logica_retard OF or2 IS
	BEGIN
	z <= a OR b AFTER 2 ns;
END logica_retard;

ARCHITECTURE logica_retard OF inv IS
	BEGIN
	z <= NOT a AFTER 2 ns;
END logica_retard;


--definir entitat mux4a1, multiplexor de 4 entrades 2 canals seleccio i una sortida
ENTITY mux2a1 IS
	PORT(
	a, b:IN BIT;
	sel:IN BIT;
	f:OUT BIT);
END mux2a1;
--Implentem les arquitectures ifthen i logicaretard del multiplexor


ARCHITECTURE ifthen OF mux2a1 IS
BEGIN
PROCESS(a, b, sel) IS
BEGIN
	IF (sel = '0') THEN f <= a;
	ELSE f <= b;
	END IF;
END PROCESS;
END ifthen;


ARCHITECTURE logica_retard OF mux2a1 IS
BEGIN--No ens indica quant retard ha de tindre arquitectura, l'he estipulat a 5 ns
	f <=  ((b AND sel) OR ((NOT sel) AND a)) AFTER 2 ns;
END logica_retard;


ARCHITECTURE estructural OF mux2a1 IS
--COMPONENTS INTERNS QUE S'ANIRAN UNINT
COMPONENT portaand2 IS
	PORT(a, b: IN BIT; z:OUT BIT);
END COMPONENT;

COMPONENT portaor2 IS
	PORT(a, b: IN BIT; z:OUT BIT);
END COMPONENT;

COMPONENT portainv IS
	PORT(a: IN BIT; z:OUT BIT);
END COMPONENT;

SIGNAL exitand1, exitand2, exitinv, exitor:BIT;
--DEFINIM QUANTS DISPOSITIUS UTILITZAREM--->5
FOR DUT1: portaand2 USE ENTITY WORK.and2(logica_retard);
FOR DUT2: portaand2 USE ENTITY WORK.and2(logica_retard);
FOR DUT3: portainv USE ENTITY WORK.inv(logica_retard);
FOR DUT4: portaor2 USE ENTITY WORK.or2(logica_retard);

BEGIN--i mapegem  inputs i outputs dels components interns que utilitzem
	DUT1: portaand2 PORT MAP(b,sel, exitand1);
	DUT2: portaand2 PORT MAP(a,exitinv, exitand2);
	DUT3: portainv PORT MAP(sel,exitinv);
	DUT4: portaor2 PORT MAP(exitand1,exitand2,f);
	
END estructural;


---entity FF_T
ENTITY FF_T IS
PORT(T,Clk,Clr: IN BIT; Q,NO_Q: OUT BIT);
END FF_T;


ARCHITECTURE ifthen OF FF_T IS
SIGNAL qint: BIT;
BEGIN
PROCESS (T,Clk,Clr,qint)
BEGIN
IF Clr='0' THEN qint<='0' AFTER 2 ns;--ho implementem per flanc de baixada
ELSE
	IF Clk='0' AND Clk'EVENT THEN
		IF T='0' THEN qint<=qint AFTER 2 ns;
		ELSIF T='1' THEN qint<= NOT qint AFTER 2 ns;
		END IF;

	END IF;
END IF;

END PROCESS;
Q<=qint; NO_Q<=NOT qint;
END ifthen;


-- definim entitat registre amb la seva arquitectura estructural
ENTITY circuit IS
	PORT(
	sel, clock:IN BIT;
	Q2, Q1, Q0:OUT BIT);
END circuit;

ARCHITECTURE estructural OF circuit IS

COMPONENT comp_mux2a1 IS
	PORT(
	a, b:IN BIT;
	sel:IN BIT;
	f:OUT BIT);
END COMPONENT;

COMPONENT comp_FF_T IS
	PORT(
	T, Clk, Clr:IN BIT;
	Q,NO_Q:OUT BIT);
END COMPONENT;

COMPONENT porta_nand3 IS
	PORT(
	a, b, c:IN BIT;
	z:OUT BIT);
END COMPONENT;

FOR DUT1: comp_mux2a1 USE ENTITY WORK.mux2a1(ifthen);
FOR DUT2: comp_mux2a1 USE ENTITY WORK.mux2a1(logica_retard);
FOR DUT3: comp_mux2a1 USE ENTITY WORK.mux2a1(estructural);
FOR DUT4: comp_FF_T USE ENTITY WORK.FF_T(ifthen);
FOR DUT5: comp_FF_T USE ENTITY WORK.FF_T(ifthen);
FOR DUT6: comp_FF_T USE ENTITY WORK.FF_T(ifthen);
FOR DUT7: porta_nand3 USE ENTITY WORK.nand3(logica_retard);

SIGNAL muxout0, muxout1, muxout2, tffout0, NOT_tffout0, tffout1, NOT_tffout1, NOT_tffout2,tffout2, constA, constB, Clr:BIT;

BEGIN
	constA <= '1';
	constB <= '0';
	DUT1: comp_mux2a1 PORT MAP(constA, constB, sel, muxout0);
	DUT2: comp_mux2a1 PORT MAP(constA, constB, sel, muxout1);
	DUT3: comp_mux2a1 PORT MAP(constA, constB, sel, muxout2);
	DUT4: comp_FF_T PORT MAP(muxout0, clock, Clr, tffout0, NOT_tffout0);
	DUT5: comp_FF_T PORT MAP(muxout1, NOT_tffout0, Clr, tffout1, NOT_tffout1);
	DUT6: comp_FF_T PORT MAP(muxout2, NOT_tffout1, Clr, tffout2, NOT_tffout2);
	DUT7: porta_nand3 PORT MAP(tffout0, NOT_tffout1, NOT_tffout2, Clr);
	Q0<=tffout0;
	Q1<=tffout1;
	Q2<=tffout2;
	
	
END estructural;

ENTITY bdp IS
END bdp;

ARCHITECTURE test OF bdp IS

COMPONENT circuit IS
PORT(
	sel, clock:IN BIT;
	Q2, Q1, Q0:OUT BIT);
END COMPONENT;

SIGNAL sel, clock, Q2, Q1, Q0:BIT;
FOR DUT1:circuit USE ENTITY WORK.circuit(estructural);
BEGIN
DUT1:circuit PORT MAP(sel, clock, Q2, Q1, Q0);
sel <= NOT sel AFTER 100 ns;
clock <= NOT clock AFTER 50 ns;
END test;
