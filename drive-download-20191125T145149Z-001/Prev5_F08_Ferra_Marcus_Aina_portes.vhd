--------------------------------------------------------OR PORTS-------------------

--ENTITY OR2:
ENTITY or2 is
  PORT (a,b: IN BIT; z: OUT BIT);
END or2;

--ARCHITECTURE OF OR2:
--Without delay.
ARCHITECTURE logica OF or2 IS
BEGIN
	z <= a OR b;
END logica;

--With 3 ns of delay.
ARCHITECTURE logicaretard OF or2 IS
BEGIN
  z <= a OR b AFTER 3 ns; 
END logicaretard;

--ENTITY OR3:
ENTITY or3 IS
	PORT( a, b, c: IN BIT; z: OUT BIT);
END or3;

--ARCHITECTURES OF OR3:
--Without delay.
ARCHITECTURE logica OF or3 IS
BEGIN
 	z <= a OR b OR c;
END logica;
--With 3 ns of delay.
ARCHITECTURE logicaretard OF or3 IS
BEGIN
	z <= a OR b OR c after 2 ns;
END logicaretard;

--ENTITY OR4:
ENTITY or4 is
	PORT (a, b, c, d: IN BIT; z: OUT BIT);
END or4;

--ARCHITECTURES OF OR4:
--Without delay.
ARCHITECTURE logica of or4 IS
BEGIN
	z <= a OR b OR c OR d;
END logica;

--With 3 ns of delay.
ARCHITECTURE logicaretard OF or4 IS
BEGIN
	z <= a OR b OR c OR d AFTER 3 ns;
END logicaretard;



-------------------------------------------------------AND PORTS-------------------


--ENTITY AND2:
ENTITY and2 IS
  PORT (a,b: IN BIT; z: OUT BIT);
END and2;

--ARCHITECTURES OF AND2:
--Without delay.
ARCHITECTURE logica OF and2 IS
BEGIN
	z <= a AND b;
END logica;

--With 3 ns of delay.
ARCHITECTURE logicaretard OF and2 IS
BEGIN
  z <= a AND b AFTER 3 ns;
END logicaretard;

--ENTITY AND3:
ENTITY and3 IS
	PORT( a, b, c: IN BIT; z: OUT BIT);
END and3;

--ARCHITECTURES OF AND3:
--Without delay.
ARCHITECTURE logica of and3 IS
BEGIN
 	z <= a AND b AND c;
END logica;

--With 3 ns of delay.
ARCHITECTURE logicaretard of and3 IS
BEGIN
 	z <= a AND b AND c after 3 ns;
END logicaretard;

--ENTITY AND4:
ENTITY and4 IS
	PORT (a, b, c, d: IN BIT; z: OUT BIT);
END and4;

--ARCHITECTURE OF AND4:
--Without delay.
ARCHITECTURE logica OF and4 IS
BEGIN
	z <= a AND b AND c AND d;
END logica;

--With 3 ns of delay.
ARCHITECTURE logicaretard OF and4 IS
BEGIN
	z <= a AND b AND c AND d;
END logicaretard;


-------------------------------------------------------------XOR PORTS-------------------

--ENTITY XOR2:
ENTITY xor2 IS
	PORT (a, b: IN BIT; z: OUT BIT);
END xor2;

--ARCHITECTURE OF XOR2:
ARCHITECTURE logicaretard of xor2 IS
BEGIN
	z <= a XOR b after 2 ns;
END logicaretard;

-----------------------------------------------------------INVERSOR PORTS-------------------


--ENTITY INV:
ENTITY inv IS
  PORT (a: IN BIT; z: OUT BIT);
END inv;

--ARCHITECTURES OF INV:
--Without delay.
ARCHITECTURE logica OF inv IS
BEGIN
	z <= NOT a;
END logica;

--With 3 ns of delay.
ARCHITECTURE logicaretard OF inv IS
BEGIN
  z <= NOT a AFTER 3 ns;
END logicaretard;


-----------------------------------------------ALU COMPONENTS----------------------------------
ENTITY bloc_FA IS
	PORT(a, f: IN BIT_VECTOR(2 DOWNTO 0); ma: OUT BIT_VECTOR(2 DOWNTO 0));
END bloc_FA;

ARCHITECTURE ifthen OF bloc_FA IS
BEGIN
	PROCESS(a, f)
		BEGIN
			IF f = "100" THEN ma <= "000" AFTER 6 ns;
			ELSE
				ma <= a AFTER 6 ns;
			END IF;
	END PROCESS;
END ifthen;

ENTITY bloc_FB IS
	PORT(b, f: IN BIT_VECTOR(2 DOWNTO 0); mb: OUT BIT_VECTOR(2 DOWNTO 0));
END bloc_FB;

ARCHITECTURE ifthen OF bloc_FB IS
BEGIN
	PROCESS(b, f)
		BEGIN
			IF (f = "011") THEN  mb <= "000" AFTER 6 ns;
			ELSIF (f = "001" OR f = "100") THEN mb <= NOT b AFTER 6 ns;
			ELSIF (f = "010" OR f = "111") THEN mb <= "111" AFTER 6 ns;
			ELSE mb <= b AFTER 6 ns;
			END IF;
	END PROCESS;
END ifthen;

ENTITY bloc_FCin IS
	PORT(f: IN BIT_VECTOR(2 DOWNTO 0); cin: OUT BIT);
END bloc_FCin;

ARCHITECTURE ifthen OF bloc_FCin IS
BEGIN
	PROCESS(f)
		BEGIN
			IF (f = "000" OR f = "010") THEN cin <= '0' AFTER 6 ns;
			ELSE cin <= '1' AFTER 6 ns;
			END IF;
	END PROCESS;
END ifthen;

ENTITY bloc_SA IS
	PORT (f: IN BIT_VECTOR(2 DOWNTO 0); sa: OUT BIT);
END bloc_SA;

ARCHITECTURE ifthen OF bloc_SA IS
BEGIN
	PROCESS(f)
		BEGIN
			IF (f= "101" OR f= "110" OR f= "111") THEN sa <= '0' AFTER 6 ns;
			ELSE sa <='1' AFTER 6 ns;
			END IF;
	END PROCESS;
END ifthen;

ENTITY bloc_SL IS
	PORT(f: IN BIT_VECTOR(2 DOWNTO 0); sl: OUT BIT);
END bloc_SL;

ARCHITECTURE ifthen OF bloc_SL IS
BEGIN
	PROCESS(f)
		BEGIN
			IF f = "101" THEN sl <='0';
			ELSE sl <='1';
			END IF;
	END PROCESS;
END ifthen;

--This is a 2 entries (plus one signal control) multiplexor. 
ENTITY multiplexor2 IS
	PORT(a, b: IN BIT_VECTOR(2 DOWNTO 0); control: IN BIT; z: OUT BIT_VECTOR(2 DOWNTO 0));
END multiplexor2;

ARCHITECTURE ifthen OF multiplexor2 IS
BEGIN
	PROCESS(a, b, control)
		BEGIN
			IF control = '1' THEN z <= a;
			ELSE z<= b;
			END IF;
	END PROCESS;
END ifthen;

--This is a 2 entries, bit kind, plus one signal control multiplexor. 
ENTITY multiplexor_2bits IS
	PORT(a, b, control: IN BIT; z: OUT BIT);
END multiplexor_2bits;

ARCHITECTURE ifthen OF multiplexor_2bits IS
BEGIN
	PROCESS(a, b, control)
		BEGIN
			IF control = '1' THEN z <= a;
			ELSE z <= b;
			END IF;
	END PROCESS;
END ifthen;