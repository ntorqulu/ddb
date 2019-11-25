ENTITY D_Latch_PreClr IS
PORT (D, Clk, Pre, Clr: IN BIT; Q, NO_Q: OUT BIT);
END D_Latch_PreClr;

ARCHITECTURE ifthen OF D_Latch_PreClr IS
SIGNAL qint: BIT; -- senyal interna a assignar al final de tot a la sortida Q

BEGIN
PROCESS (D, Clk, Pre, Clr)
 BEGIN 
  IF Pre = '0' THEN qint <= '1' AFTER 2 ns; -- aquí Preset i Clear funcionen si són 0 (active-low)
  ELSE  -- Preset té prioritat segons l'enunciat; només si Preset no és actiu considerem Clear
   IF Clr = '0' THEN qint <= '0' AFTER 2 ns;
   ELSE
    IF Clk = '1' THEN -- és un Latch: ens cal tenir el rellotge actiu
     IF D = '1' THEN qint <= '1' AFTER 6 ns;
     ELSE qint <= '0' AFTER 6 ns;
     END IF;
    END IF;
   END IF;
  END IF;
END PROCESS;

Q <= qint;
NO_Q <= NOT qint;

END ifthen;


ENTITY JK_Pujada_PreClr IS
PORT (J,K, Clk, Pre, Clr: IN BIT; Q, NO_Q: OUT BIT);
END JK_Pujada_PreClr;

ARCHITECTURE ifthen OF JK_Pujada_PreClr IS
SIGNAL qint: BIT;

BEGIN
PROCESS (J, K, Clk, Pre, Clr)
BEGIN
 IF Pre = '0' THEN qint <= '1' AFTER 2 ns;
 ELSE
  IF Clr = '0' THEN qint <= '0' AFTER 2 ns;
  ELSE -- si el rellotge té un flanc de pujada (canvia de valor i passa a 1) analitzem J i K
   IF Clk'EVENT AND Clk = '1' THEN -- se segueix la taula d'excitació pels JK (simplificada a 4 casos)
    IF J = '0' AND K = '1' THEN qint <= qint AFTER 6 ns;
    ELSIF J = '0' AND K = '1' THEN qint <= '0' AFTER 6 ns;
    ELSIF J = '1' AND K = '0' THEN qint <= '1' AFTER 6 ns;
    ELSIF J = '1' AND K = '1'  THEN qint <= NOT qint AFTER 6 ns;
    END IF;
   END IF;
  END IF;
 END IF;

END PROCESS; 
Q <= qint;
NO_Q <= NOT qint;
END ifthen;




ENTITY circuit IS -- Si bé el circuit només té una sortida, z,
-- tractem altres variables com a tals per poder-les mostrar
-- al cronograma en simular el banc de proves
PORT (x, Ck: IN BIT; z, cron_Q1, cron_NO_Q1, cron_J, cron_K: OUT BIT);
END circuit;

ARCHITECTURE estructural OF circuit IS

COMPONENT comp_D_Latch_PreClr IS
PORT(D,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END COMPONENT;
COMPONENT comp_JK_Pujada_PreClr IS
PORT(J,K,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END COMPONENT;

COMPONENT porta_inv IS
PORT (a: IN BIT; z: OUT BIT);
END COMPONENT;

COMPONENT porta_and2 IS
PORT (a, b: IN BIT; z: OUT BIT);
END COMPONENT;

COMPONENT porta_nor2 IS
PORT (a, b: IN BIT; z: OUT BIT);
END COMPONENT;

FOR DUT1: comp_D_Latch_PreClr USE ENTITY work.D_Latch_PreClr(ifthen);
FOR DUT2: porta_inv USE ENTITY work.inv(logicaretard);
FOR DUT3: porta_nor2 USE ENTITY work.nor2(logicaretard);
FOR DUT4: porta_and2 USE ENTITY work.and2(logicaretard);
FOR DUT5: comp_JK_Pujada_PreClr USE ENTITY work.JK_Pujada_PreClr(ifthen);

SIGNAL constPre, constClr: BIT;
SIGNAL Q1, NO_Q1, invx, result_and, result_nor: BIT;

BEGIN
-- com al circuit els biestables no es mostren amb Clear ni Preset i
-- l'enunciat no diu que el circuit tingui cap entrada d'aquesta mena,
-- assumim que Clear i Preset estan desactivats sempre, com si no hi fossin
	constPre <= '1';
	constClr <= '1';

	DUT1: comp_D_Latch_PreClr PORT MAP (x, Ck, constPre, constClr, Q1, NO_Q1);
	DUT2: porta_inv PORT MAP (x, invx);
	DUT3: porta_nor2 PORT MAP (Q1, invx, result_nor);
	DUT4: porta_and2 PORT MAP (x, NO_Q1, result_and);
	-- només ens interesa la sortida Q (Q2), assignada a z,
	-- podem ignorar la sortida NO_Q del biestable (hipotètica NO_Q2) 
	--- ja que no la utilitzarem
	DUT5: comp_JK_Pujada_PreClr PORT MAP (result_and, result_nor, Ck, constPre, constClr, z);
-- donem valor al que s'ens demana mostrar al cronograma:
cron_Q1 <= Q1;
cron_NO_Q1 <= NO_Q1;
cron_J <= result_and;
cron_K <= result_nor;
END estructural;



-- Banc de proves del circuit:
ENTITY bdp_circuit IS
END bdp_circuit;

ARCHITECTURE test OF bdp_circuit IS

COMPONENT comp_circuit IS
PORT (x, Ck: IN BIT; z, cron_Q1, cron_NO_Q1, cron_J, cron_K: OUT BIT);
END COMPONENT;

-- senyals que identifiquen el que mostrem al cronograma
SIGNAL Ck, x, Q1, NO_Q1, J, K, z: BIT;
FOR DUT1: comp_circuit USE ENTITY work.circuit(estructural);

BEGIN
	DUT1: comp_circuit PORT MAP (x,Ck,z,Q1,NO_Q1,J,K);

PROCESS (x, Ck)
BEGIN
Ck <= NOT Ck AFTER 50 ns;
x <= NOT x AFTER 100 ns;
END PROCESS;
END test;



-- Banc de proves dels dos biestables 
ENTITY bdp_biestables IS
END bdp_biestables;

ARCHITECTURE test OF bdp_biestables IS
COMPONENT mi_D_Latch_PreClr IS
PORT(D,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END COMPONENT;
COMPONENT mi_JK_Pujada_PreClr IS
PORT(J,K,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END COMPONENT;
SIGNAL entD_J,entK,clock,preset,clear,Dsort_Q,Dsort_noQ,JKsort_Q,JKsort_noQ: BIT;
FOR DUT1: mi_D_Latch_PreClr USE ENTITY WORK.D_Latch_PreClr(ifthen);
FOR DUT2: mi_JK_Pujada_PreClr USE ENTITY WORK.JK_Pujada_PreClr(ifthen);
BEGIN -- Emprem entD_J com entrada D al biestable D i com J al JK
DUT1: mi_D_Latch_PreClr PORT MAP (entD_J,clock,preset,clear,Dsort_Q,Dsort_noQ);
DUT2: mi_JK_Pujada_PreClr PORT MAP (entD_J,entK,clock,preset,clear,JKsort_Q,JKsort_noQ);
entD_J <= NOT entD_J AFTER 800 ns;
entK <= NOT entK AFTER 400 ns;
clock <= NOT clock AFTER 500 ns;
preset <= '0', '1' AFTER 600 ns;
clear <= '1','0' AFTER 200 ns, '1' AFTER 400 ns;
-- simular hasta 15000 ns
END test;