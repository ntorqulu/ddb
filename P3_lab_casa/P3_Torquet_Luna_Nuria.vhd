---Diferencia entre Latch i FF:
---Els latch son vibradors biestables asincrons.
---La sortida Q pot variar en qualsevol instant en que
---el clock es trobi en estat alt.
---En canvi, els flip-flops son vibradors biestables
---sincrons tq la sortida Q pot variar nomes quan la senyal
---de rellotge passa d'alt a baix o de baix a alt.




---Comencem definint les entitats i arquitectures

---LATCH D
ENTITY Latch_D IS
PORT(D,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END Latch_D;

ARCHITECTURE ifthen OF Latch_D IS
SIGNAL qint: BIT;

BEGIN

PROCESS (D,Clk,Pre,Clr)

BEGIN
IF Clr='0' THEN qint<='0' AFTER 2 ns;
ELSIF Pre='0' THEN qint<='1' AFTER 2 ns;
ELSIF Clk='1' THEN qint <= D AFTER 2 ns;
ELSE qint <= qint after 2ns;

END IF;

END PROCESS;

Q<=qint; NO_Q<=NOT qint;

END ifthen;

---FF D
ENTITY FF_D IS
PORT(D,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END FF_D;

ARCHITECTURE ifthen OF FF_D IS
SIGNAL qint: BIT;

BEGIN

PROCESS(D,Clk,Pre,Clr)
BEGIN
IF Clr='0' THEN qint<='0' AFTER 2 ns;

      ELSIF Pre='0' THEN qint<='1' AFTER 2 ns;

      ELSIF Clk'EVENT AND Clk='0' THEN
-- Clk?EVENT és una instrucció que dóna una sortida veritat, és a dir, un 1
-- quan es produeix un canvi en el valor de la variable Clk.
-- La instrucció, tal com està aquí, indica que si es produeix un canvi en
-- el senyal Clk i, a més, el valor posterior és 0 (baixada), llavors ?
      qint <= D AFTER 2 ns;
END IF;
END PROCESS;
Q<=qint; NO_Q<=NOT qint;

END ifthen;

---LATCH JK
ENTITY Latch_JK IS
PORT(J,K,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END Latch_JK;

ARCHITECTURE ifthen OF Latch_JK IS
SIGNAL qint: BIT;
BEGIN
PROCESS (J,K,Clk,Pre,Clr,qint)
BEGIN
IF Clr='0' THEN qint<='0' AFTER 2 ns;
ELSE
IF Pre='0' THEN qint<='1' AFTER 2 ns;
ELSE
		IF Clk='1' THEN
			IF J='0' AND K='0' THEN qint<=qint AFTER 2 ns;
			ELSIF J='0' AND K='1' THEN qint<='0' AFTER 2 ns;
			ELSIF J='1' AND K='0' THEN qint<='1' AFTER 2 ns;
			ELSIF J='1' AND K='1' THEN qint<= NOT qint AFTER 2 ns;
			END IF;

		END IF;
	END IF;
END IF;

END PROCESS;
Q<=qint; NO_Q<=NOT qint;
END ifthen;

---ENTITY FF_JK
ENTITY FF_JK IS
PORT(J,K,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END FF_JK;



ARCHITECTURE ifthen OF FF_JK IS
SIGNAL qint: BIT;
BEGIN
PROCESS (J,K,Clk,Pre,Clr,qint)
BEGIN
IF Clr='0' THEN qint<='0' AFTER 2 ns;
ELSE
IF Pre='0' THEN qint<='1' AFTER 2 ns;
ELSE
		IF Clk='1' AND Clk'EVENT THEN
			IF J='0' AND K='0' THEN qint<=qint AFTER 2 ns;
			ELSIF J='0' AND K='1' THEN qint<='0' AFTER 2 ns;
			ELSIF J='1' AND K='0' THEN qint<='1' AFTER 2 ns;
			ELSIF J='1' AND K='1' THEN qint<= NOT qint AFTER 2 ns;
			END IF;

		END IF;
	END IF;
END IF;

END PROCESS;
Q<=qint; NO_Q<=NOT qint;
END ifthen;

---entity Latch_t
ENTITY Latch_T IS
PORT(T,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END Latch_T;



ARCHITECTURE ifthen OF Latch_T IS
SIGNAL qint: BIT;
BEGIN
PROCESS (T,Clk,Pre,Clr,qint)
BEGIN
IF Clr='0' THEN qint<='0' AFTER 2 ns;
ELSE
IF Pre='0' THEN qint<='1' AFTER 2 ns;
ELSE
		IF Clk='1' THEN
			IF T='0' THEN qint<=qint AFTER 2 ns;
			ELSIF T='1' THEN qint<= NOT qint AFTER 2 ns;
			END IF;

		END IF;
	END IF;
END IF;

END PROCESS;
Q<=qint; NO_Q<=NOT qint;
END ifthen;


---entity FF_T
ENTITY FF_T IS
PORT(T,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END FF_T;



ARCHITECTURE ifthen OF FF_T IS
SIGNAL qint: BIT;
BEGIN
PROCESS (T,Clk,Pre,Clr,qint)
BEGIN
IF Clr='0' THEN qint<='0' AFTER 2 ns;
ELSE
IF Pre='0' THEN qint<='1' AFTER 2 ns;
ELSE
		IF Clk='1' AND Clk'EVENT THEN
			IF T='0' THEN qint<=qint AFTER 2 ns;
			ELSIF T='1' THEN qint<= NOT qint AFTER 2 ns;
			END IF;

		END IF;
	END IF;
END IF;

END PROCESS;
Q<=qint; NO_Q<=NOT qint;
END ifthen;



-- Banc de Proves d?ambos
ENTITY banc_proves IS
END banc_proves;

ARCHITECTURE test OF banc_proves IS

COMPONENT Latch_D IS
PORT(D,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END COMPONENT;

COMPONENT FF_D IS
PORT(D,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END COMPONENT;

COMPONENT Latch_JK IS
PORT(J,K,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END COMPONENT;

COMPONENT FF_JK IS
PORT(J,K,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END COMPONENT;

COMPONENT Latch_T IS
PORT(T,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END COMPONENT;

COMPONENT FF_T IS
PORT(T,Clk,Pre,Clr: IN BIT; Q,NO_Q: OUT BIT);
END COMPONENT;



SIGNAL ent1,ent2,clock,preset,clear,latch_Dsort_Q,latch_Dsort_noQ,FF_Dsort_Q,FF_Dsort_noQ, latch_JKsort_Q,latch_JKsort_noQ,FF_JKsort_Q,FF_JKsort_noQ, latch_Tsort_Q,latch_Tsort_noQ,FF_Tsort_Q,FF_Tsort_noQ: BIT;
FOR DUT1: Latch_D USE ENTITY WORK.Latch_D(ifthen);
FOR DUT2: FF_D USE ENTITY WORK.FF_D(ifthen);
FOR DUT3: Latch_JK USE ENTITY WORK.Latch_JK(ifthen);
FOR DUT4: FF_JK USE ENTITY WORK.FF_JK(ifthen);
FOR DUT5: Latch_T USE ENTITY WORK.Latch_T(ifthen);
FOR DUT6: FF_T USE ENTITY WORK.FF_T(ifthen);

BEGIN
DUT1: Latch_D PORT MAP (ent1,clock,preset,clear,latch_Dsort_Q,latch_Dsort_noQ);
DUT2: FF_D PORT MAP (ent1,clock,preset,clear,FF_Dsort_Q,FF_Dsort_noQ);
DUT3: Latch_JK PORT MAP (ent1, ent2,clock,preset,clear,latch_JKsort_Q,latch_JKsort_noQ);
DUT4: FF_JK PORT MAP (ent1,ent2,clock,preset,clear,FF_JKsort_Q,FF_JKsort_noQ);
DUT5: Latch_T PORT MAP (ent1,clock,preset,clear,latch_Tsort_Q,latch_Tsort_noQ);
DUT6: FF_T PORT MAP (ent1,clock,preset,clear,FF_Tsort_Q,FF_Tsort_noQ);

ent1 <= NOT ent1 AFTER 800 ns;
ent2 <= NOT ent2 AFTER 400 ns;
clock <= NOT clock AFTER 500 ns;
preset <= '0', '1' AFTER 600 ns;
clear <= '1','0' AFTER 200 ns, '1' AFTER 400 ns;
-- simuleu fins a 15000 ns
END test;


