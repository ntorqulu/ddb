-- MULTIPLEXOR DE 2 VARIABLES:
ENTITY mux2 IS
PORT (a,b,control: IN BIT; z: OUT BIT);
END mux2;

ARCHITECTURE ifthen OF mux2 IS
BEGIN
PROCESS(control,a,b)
BEGIN 
	IF control = '0' THEN z <= a;
	ELSE z <= b;
	END IF;
END PROCESS;
END ifthen;




-- SUMADOR D'UN BIT PER A ALU:
ENTITY sumador_alu_1bit IS
PORT (a,b: IN BIT; 
f: IN BIT_VECTOR (2 DOWNTO 0); -- senyals de control
z, cout: OUT BIT);
END sumador_alu_1bit;

ARCHITECTURE mixta OF sumador_alu_1bit IS

COMPONENT comp_mux2 IS
PORT (a,b,control: IN BIT; z: OUT BIT);
END COMPONENT;

COMPONENT portaand2 IS
PORT(a,b: IN BIT; z: OUT BIT);
END COMPONENT;

COMPONENT portaor2 IS
PORT(a,b: IN BIT; z: OUT BIT);
END COMPONENT;

COMPONENT portaxor2 IS
PORT (a,b: IN BIT; z: OUT BIT);
END COMPONENT ;

FOR DUT1: portaxor2 USE ENTITY WORK.xor2(logica);
FOR DUT2: portaxor2 USE ENTITY WORK.xor2(logica);
FOR DUT3: portaand2 USE ENTITY WORK.and2(logica);
FOR DUT4: portaor2 USE ENTITY WORK.or2(logica);
FOR DUT5: portaand2 USE ENTITY WORK.and2(logica);
FOR DUT6: portaor2 USE ENTITY WORK.or2(logica);
FOR DUT7: comp_mux2 USE ENTITY WORK.mux2(ifthen);
FOR DUT8: comp_mux2 USE ENTITY WORK.mux2(ifthen);

SIGNAL sort_xor,sort_and2: BIT;
SIGNAL mod_a, mod_b, mod_cin: BIT;
SIGNAL SA, SL, FA, FB0, FB1: BIT;
SIGNAL suma_aritm, suma_log, prod_log: BIT;
SIGNAL sort_mux_L: BIT;


BEGIN
	mod_cin <= f(2) OR f(0);
	SA <= (NOT(f(1)) AND NOT(f(0))) OR NOT(f(2));
	SL <= f(1);
	FA <= NOT (f(2) AND NOT (f(1)) AND NOT(f(0)));
	mod_a <= a AND FA;
	FB0 <= (NOT(f(2)) AND f(1)) OR (f(1) AND f(0));
	FB1 <= (NOT(f(2)) AND f(0)) OR (f(2) AND NOT(f(1)) AND NOT(f(0)));
	mod_b <= (B OR FB0) XOR FB1;
	
	
	DUT1: portaxor2 PORT MAP (mod_a,mod_b,sort_xor);
	DUT2: portaxor2 PORT MAP( sort_xor,mod_cin,suma_aritm);
	DUT3: portaand2 PORT MAP (mod_a,mod_b,prod_log);
	DUT4: portaor2 PORT MAP( mod_a,mod_b,suma_log);
	DUT5: portaand2 PORT MAP (suma_log,mod_cin,sort_and2);
	DUT6: portaor2 PORT MAP (prod_log,sort_and2,cout);
	DUT7: comp_mux2 PORT MAP(suma_log,prod_log,SL,sort_mux_L);
	DUT8: comp_mux2 PORT MAP(sort_mux_L, suma_aritm, SA, z);

END mixta;



-- ALU:
ENTITY ALU IS
PORT (a,b,f: IN BIT_VECTOR (2 DOWNTO 0);
z: OUT BIT_VECTOR (2 DOWNTO 0);
cout: OUT BIT);
END ALU;

ARCHITECTURE mixta OF ALU IS
COMPONENT sumador1bit IS
PORT (a,b: IN BIT; 
f: IN BIT_VECTOR (2 DOWNTO 0); -- senyals de control
z, cout: OUT BIT);
END COMPONENT;


COMPONENT portaand2 IS
PORT(a,b: IN BIT; z: OUT BIT);
END COMPONENT;

COMPONENT portaor2 IS
PORT(a,b: IN BIT; z: OUT BIT);
END COMPONENT;

COMPONENT portaxor2 IS
PORT (a,b: IN BIT; z: OUT BIT);
END COMPONENT;

FOR DUT1: sumador1bit USE ENTITY work.sumador_alu_1bit(mixta);
FOR DUT2: sumador1bit USE ENTITY work.sumador_alu_1bit(mixta);
FOR DUT3: sumador1bit USE ENTITY work.sumador_alu_1bit(mixta);


SIGNAL cin2, cin3: BIT;

BEGIN
	DUT1: sumador1bit PORT MAP (a(0),b(0),f,--cin,
		z(0),cin2);
	DUT2: sumador1bit PORT MAP (a(1),b(1),f,--cin2,
		z(1),cin3);
	DUT3: sumador1bit PORT MAP (a(2),b(2),f,--cin3,
		z(2),cout);
END mixta;




-- BANC DE PROVES DE L'ALU:

ENTITY bdp_ALU IS
END bdp_ALU;

ARCHITECTURE test OF bdp_ALU IS

COMPONENT bloc IS
PORT (a,b,f: IN BIT_VECTOR (2 DOWNTO 0);
z: OUT BIT_VECTOR (2 DOWNTO 0);
cout: OUT BIT);
END COMPONENT;

SIGNAL f,A,B: BIT_VECTOR (2 DOWNTO 0);
SIGNAL Z: BIT_VECTOR (2 DOWNTO 0);
SIGNAL cout: BIT;

FOR DUT: bloc USE ENTITY WORK.ALU(mixta);

BEGIN
	DUT: bloc PORT MAP (A,B,f,Z,cout);

PROCESS (A,B,f)
BEGIN
B(0) <= NOT B(0) AFTER 5 ns;
A(0) <= NOT A(0) AFTER 10 ns;
B(1) <= NOT B(1) AFTER 20 ns;
A(1) <= NOT A(1) AFTER 40 ns;
B(2) <= NOT B(2) AFTER 80 ns;
A(2) <= NOT A(2) AFTER 160 ns;

f(0) <= NOT f(0) AFTER 640 ns;
f(1) <= NOT f(1) AFTER 1280 ns;
f(2) <= NOT f(2) AFTER 2560 ns;
END PROCESS;
END test;




-- BANC DE PROVES DEL SUMADOR D'1 BIT DE L'ALU:

ENTITY bdp_sumador_alu IS
END bdp_sumador_alu;

ARCHITECTURE test OF bdp_sumador_alu IS

COMPONENT bloc IS
PORT (a,b: IN BIT; 
f: IN BIT_VECTOR (2 DOWNTO 0); -- senyals de control
z, cout: OUT BIT);
END COMPONENT;

SIGNAL f: BIT_VECTOR (2 DOWNTO 0);
SIGNAL A,B, cin: BIT;
SIGNAL Z, cout: BIT;

FOR DUT: bloc USE ENTITY WORK.sumador_alu_1bit(mixta);

BEGIN
	DUT: bloc PORT MAP (A,B,f,Z,cout);

PROCESS (A,B,f,cin)
BEGIN
B <= NOT B AFTER 5 ns;
A <= NOT A AFTER 10 ns;
cin <= NOT cin AFTER 20 ns;
f(0) <= NOT f(0) AFTER 40 ns;
f(1) <= NOT f(1) AFTER 80 ns;
f(2) <= NOT f(2) AFTER 160 ns;
END PROCESS;
END test;
