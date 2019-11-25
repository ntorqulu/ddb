--ENTITY OF SUMADOR MODIFICAT 1 BIT:
--We will use this to build a 3-bit adder.
--Also, ths code is given. We won't modify anything of this, but build based on this.
ENTITY sumador_modificat_1bit IS
	PORT (a,b,cin: IN BIT; suma_smod_1bit,cout_smod_1bit,aib_smod_1bit,aob_smod_1bit: OUT BIT);
END sumador_modificat_1bit;

-- Aquesta és la definició del sumador modificat de forma estructural
ARCHITECTURE estructural OF sumador_modificat_1bit IS

COMPONENT portaand2 IS
	PORT(a,b: IN BIT; z: OUT BIT);
END COMPONENT;

COMPONENT portaor2 IS
	PORT(a,b: IN BIT; z: OUT BIT);
END COMPONENT;

COMPONENT portaxor2 IS
	PORT (a,b: IN BIT; z: OUT BIT);
END COMPONENT ;	

--Ens calen 6 DUTs.
	FOR DUT1: portaxor2 USE ENTITY WORK.xor2(logica);
	FOR DUT2: portaxor2 USE ENTITY WORK.xor2(logica);
	FOR DUT3: portaand2 USE ENTITY WORK.and2(logica);
	FOR DUT4: portaor2 USE ENTITY WORK.or2(logica);
	FOR DUT5: portaand2 USE ENTITY WORK.and2(logica);
	FOR DUT6: portaor2 USE ENTITY WORK.or2(logica);

	-- Calen 4 senyals interns
	SIGNAL sort_xor,sort_or,sort_and1,sort_and2: BIT;

	-- Un cop introduïts tots els blocs i senyals, passem a realitzar les connexions
	-- i, d'aquesta forma,
	-- fer la definició de la funció lògica en funció de les variables a, b i cin.

	BEGIN

		DUT1: portaxor2 PORT MAP (a,b,sort_xor);
		DUT2: portaxor2 PORT MAP( sort_xor,cin,suma_smod_1bit);
		DUT3: portaand2 PORT MAP (a,b,sort_and1);
		DUT4: portaor2 PORT MAP( a,b,sort_or);
		DUT5: portaand2 PORT MAP (sort_or,cin,sort_and2);
		DUT6: portaor2 PORT MAP (sort_and1,sort_and2,cout_smod_1bit);

	-- ara introduïm quins senyals interns s?utilitzen, també, com externs
	aib_smod_1bit <= sort_and1;
	aob_smod_1bit <= sort_or;

END estructural;


--------------------------------------------------
--El sumador de 3 bits suma a partir de sumadors modificats d'1 bit.
--Per aixo, tambe tenim les opcions de guardar les operacions AiB i AoB.


--Building our 3-bits adder:
--It will take 2 vectors of 3 bits, a simple bit (carry in) and it will take out one solution vector (3 bits) and one simple bit called carry out.
ENTITY sumador3bits IS
	PORT (a, b: IN BIT_VECTOR(2 DOWNTO 0); cin: IN  BIT; z, aib_smod_3bits, aob_smod_3bits: OUT BIT_VECTOR(2 DOWNTO 0); cout: OUT BIT);
END sumador3bits;
--We will use here our 1-bit adder:
ARCHITECTURE estructural OF sumador3bits IS
	COMPONENT sumador_modificat_1bit IS
		PORT (a,b,cin: IN BIT; suma_smod_1bit, cout_smod_1bit, aib_smod_1bit, aob_smod_1bit: OUT BIT);
	END COMPONENT;
--We will only need to internal signals, carry out of the first adder and carry out of the second adder.
--We can use all previously defined signals for everything else.
--These are simple bits since we are defining carries.
SIGNAL cout0, cout1: BIT;

	FOR DUT1: sumador_modificat_1bit USE ENTITY WORK.sumador_modificat_1bit(estructural);
	FOR DUT2: sumador_modificat_1bit USE ENTITY WORK.sumador_modificat_1bit(estructural);
	FOR DUT3: sumador_modificat_1bit USE ENTITY WORK.sumador_modificat_1bit(estructural);

	BEGIN
		--So, basically, we are connecting the adders by their carries.
		--First carry out goes to second carry in, second carry out goes to third carry in.
		--Firs carry in will be a 0 and last carry out depends on the adding result.
		--First adder recieve the most significant bits, and so goes on.
		DUT1: sumador_modificat_1bit PORT MAP(a(0), b(0), cin, z(0), cout0, aib_smod_3bits(0), aob_smod_3bits(0));
		DUT2: sumador_modificat_1bit PORT MAP(a(1), b(1), cout0, z(1), cout1, aib_smod_3bits(1),aob_smod_3bits(1));
		DUT3: sumador_modificat_1bit PORT MAP(a(2), b(2), cout1, z(2), cout, aib_smod_3bits(2),aob_smod_3bits(2));

	END estructural;


-------------------------------------------------------------
--Working code for our ALU.
-------------------------------------------------------------
--Wanted operations:
	-- 000 -> A + B
	-- 001 -> A - B
	-- 010 -> A - 1
	-- 011 -> A + 1
	-- 100 -> Ca2 B
	-- 101 -> A or B
	-- 110 -> A and B
	-- 111 -> Transfer A
--------------------------------------------------------------

--Defining all needed blocks.
--All of these are based on the ifthen logic as described in our notes. 

---------------------------------------------------------------
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


----------------------------------------------------------------------
--Needed dispositives for register.


--This is a 2 entries, bit kind, plus one signal control multiplexor. 
ENTITY multiplexor_2bits IS
	PORT(a, b, control: IN BIT; z: OUT BIT);
END multiplexor_2bits;


ARCHITECTURE ifthen OF multiplexor_2bits IS
BEGIN
	PROCESS(a, b, control)
		BEGIN
			IF control = '1' THEN z<= a;
			ELSE z<= b;
			END IF;
	END PROCESS;
END ifthen;

-----FlipFlop D
ENTITY FF_D_PreClear IS
	PORT(d, clk, pre, clr: IN BIT; q, noq: OUT BIT);
END FF_D_PreClear;

ARCHITECTURE ifthen OF FF_D_PreClear IS
	SIGNAL qint: BIT;

	BEGIN
		PROCESS (d, clk, pre, clr)
			BEGIN

				--Clear has priority.
				IF clr = '0' THEN qint<= '0' AFTER 2 ns;
				--Preset is second on the priority scale. 
				ELSE
					IF pre = '0' THEN qint <='1' AFTER 2 ns;
					ELSE
						IF (clk'EVENT AND clk = '0') THEN qint <= d AFTER 6 ns;
						END IF;
					END IF;
				END IF;
		END PROCESS;
		q <=qint; noq <= NOT qint; 
END ifthen;




--Entity register.
ENTITY registre1bit IS
	PORT(ent, we, clk, clr: IN BIT; z: OUT BIT);
END registre1bit;

ARCHITECTURE estructural OF registre1bit IS

	COMPONENT multiplexor2bits IS
		PORT(a, b, control: IN BIT; z: OUT BIT);
	END COMPONENT;

	COMPONENT FFDpreclear IS
		PORT(d, clk, pre, clr: IN BIT; q, noq: OUT BIT);
	END COMPONENT; 

	SIGNAL int_mux, int_o, int_ffd: BIT;

	FOR DUT1: multiplexor2bits USE ENTITY WORK.multiplexor_2bits(ifthen);
	FOR DUT2: FFDpreclear USE ENTITY WORK.FF_D_PreClear(ifthen);

	BEGIN

		DUT1: multiplexor2bits PORT MAP(ent, int_o, we, int_mux);
		DUT2: FFdpreclear PORT MAP(int_mux, clk, '1', clr, z, int_ffd);

END estructural; 
------------------------------------------------
--Starting with 3 bits registre.
------------------------------------------------

ENTITY registre3bits IS
	PORT(ent_vect: IN BIT_VECTOR(2 DOWNTO 0); we, clk, clr: IN BIT; z: OUT BIT_VECTOR(2 DOWNTO 0));
END registre3bits;

ARCHITECTURE estructural OF registre3bits IS

	COMPONENT registre_1bit IS
		PORT(ent, we, clk, clr: IN BIT; z: OUT BIT);
	END COMPONENT;

	FOR DUT1: registre_1bit USE ENTITY WORK.registre1bit(estructural);
	FOR DUT2: registre_1bit USE ENTITY WORK.registre1bit(estructural);
	FOR DUT3: registre_1bit USE ENTITY WORK.registre1bit(estructural);

	BEGIN

		DUT1: registre_1bit PORT MAP(ent_vect(0), we, clk, clr, z(0));
		DUT2: registre_1bit PORT MAP(ent_vect(1), we, clk, clr, z(1));
		DUT3: registre_1bit PORT MAP(ent_vect(2), we, clk, clr, z(2));

END estructural; 

-------------------------------------------------------------------------------------------------
--Starting with ALU component:
-------------------------------------------------------------------------------------------------


ENTITY alu IS
	PORT(a, b, f: IN BIT_VECTOR(2 DOWNTO 0); cout: OUT BIT; sort_out: OUT BIT_VECTOR(2 DOWNTO 0));
END alu;

ARCHITECTURE estructural OF alu IS

	COMPONENT blocFA IS
		PORT(a, f: IN BIT_VECTOR(2 DOWNTO 0); ma: OUT BIT_VECTOR(2 DOWNTO 0));
	END COMPONENT;

	COMPONENT blocFB IS
		PORT(b, f: IN BIT_VECTOR(2 DOWNTO 0); mb: OUT BIT_VECTOR(2 DOWNTO 0));
	END COMPONENT;

	COMPONENT sum3bits IS
		PORT (a, b: IN BIT_VECTOR(2 DOWNTO 0); cin: IN  BIT; z, aib_smod_3bits, aob_smod_3bits: OUT BIT_VECTOR(2 DOWNTO 0); cout: OUT BIT);
	END COMPONENT;

	COMPONENT blocCin IS
		PORT(f: IN BIT_VECTOR(2 DOWNTO 0); cin: OUT BIT);
	END COMPONENT blocCin;

	COMPONENT blocSA IS
		PORT (f: IN BIT_VECTOR(2 DOWNTO 0); sa: OUT BIT);
	END COMPONENT;

	COMPONENT blocSL IS
		PORT(f: IN BIT_VECTOR(2 DOWNTO 0); sl: OUT BIT);
	END COMPONENT;

	COMPONENT multiplex2 IS
		PORT(a, b: IN BIT_VECTOR(2 DOWNTO 0); control: IN BIT; z: OUT BIT_VECTOR(2 DOWNTO 0));
	END COMPONENT; 

	SIGNAL int_ma, int_mb, int_s, int_aib, int_aob, int_mux: BIT_VECTOR(2 DOWNTO 0);
	SIGNAL int_fcin, int_sl, int_sa: BIT;

	FOR DUT1: blocFA USE ENTITY WORK.bloc_FA(ifthen);
	FOR DUT2: blocFB USE ENTITY WORK.bloc_FB(ifthen);
	FOR DUT3: blocCin USE ENTITY WORK.bloc_FCin(ifthen);
	FOR DUT4: sum3bits USE ENTITY WORK.sumador3bits(estructural);
	FOR DUT5: blocSL USE ENTITY WORK.bloc_SL(ifthen);
	FOR DUT6: multiplex2 USE ENTITY WORK.multiplexor2(ifthen);
	FOR DUT7: blocSA USE ENTITY WORK.bloc_SA(ifthen);
	FOR DUT8: multiplex2 USE ENTITY WORK.multiplexor2(ifthen);


	BEGIN

		DUT1: blocFA PORT MAP(a, f, int_ma);
		DUT2: blocFB PORT MAP(b, f, int_mb);
		DUT3: blocCin PORT MAP(f, int_fcin);
		DUT4: sum3bits PORT MAP(int_ma, int_mb, int_fcin, int_s, int_aib, int_aob, cout);
		DUT5: blocSL PORT MAP(f, int_sl);
		DUT6: multiplex2 PORT MAP(int_aib, int_aob, int_sl, int_mux);
		DUT7: blocSA PORT MAP(f, int_sa);
		DUT8: multiplex2 PORT MAP(int_s, int_mux, int_sa, sort_out);

END estructural; 

-------------------------------------------------------------------------------------------------------
ENTITY alu_registre IS
	PORT(a, b, f: IN BIT_VECTOR(2 DOWNTO 0); we, clk, clr: IN BIT; z: OUT BIT_VECTOR(2 DOWNTO 0));
END alu_registre;

ARCHITECTURE estructural OF alu_registre IS

	COMPONENT alu IS
		PORT (a, b, f: IN BIT_VECTOR(2 DOWNTO 0); cout: OUT BIT; sort_out: OUT BIT_VECTOR(2 DOWNTO 0));
	END COMPONENT;

	COMPONENT registre_3bits IS
		PORT(ent_vect: IN BIT_VECTOR(2 DOWNTO 0); we, clk, clr: IN BIT; z: OUT BIT_VECTOR(2 DOWNTO 0));
	END COMPONENT;

	SIGNAL int_alu: BIT_VECTOR(2 DOWNTO 0);
	SIGNAL int_cout: BIT;

	FOR DUT1: alu USE ENTITY WORK.alu(estructural);
	FOR DUT2: registre_3bits USE ENTITY WORK.registre3bits(estructural);

	BEGIN

		DUT1: alu PORT MAP(a, b, f, int_cout, int_alu);
		DUT2: registre_3bits PORT MAP(int_alu, we, clk, clr, z);

END estructural;


----------------------------------------------------Test bench

ENTITY bancdeproves_alu IS
END bancdeproves_alu;

ARCHITECTURE test OF bancdeproves_alu IS

	COMPONENT bloc_alu IS
		PORT (a, b, f: IN BIT_VECTOR(2 DOWNTO 0); cout: OUT BIT; sort_out: OUT BIT_VECTOR(2 DOWNTO 0));
	END COMPONENT; 


	SIGNAL ent_a, ent_b, ent_f, out_out: BIT_VECTOR(2 DOWNTO 0);
	SIGNAL out_cout: BIT;

	FOR DUT1:  bloc_alu USE ENTITY WORK.alu(estructural);

	BEGIN

		DUT1: bloc_alu PORT MAP(ent_a, ent_b, ent_f, out_cout, out_out);

		PROCESS(ent_a, ent_b, ent_f)
			BEGIN 
				ent_f<="000";
				ent_a<="110";
				ent_b<="010";
				ent_f<="001" AFTER 125 ns;
				ent_f<="101" AFTER 250 ns;
				ent_f<="111" AFTER 375 ns;
		END PROCESS;
END test;

------------------------------------------------------Second test bench

ENTITY bancdeproves_aluregistre IS
END bancdeproves_aluregistre;

ARCHITECTURE test OF bancdeproves_aluregistre IS

	COMPONENT alu_registrada IS
		PORT(a, b, f: IN BIT_VECTOR(2 DOWNTO 0); we, clk, clr: IN BIT; z: OUT BIT_VECTOR(2 DOWNTO 0));
	END COMPONENT;

	SIGNAL ent_a, ent_b, ent_f, sort_out: BIT_VECTOR(2 DOWNTO 0);
	SIGNAL ent_we, ent_clk, ent_clr: BIT;

	FOR DUT1: alu_registrada USE ENTITY WORK.alu_registre(estructural);

	BEGIN

		DUT1: alu_registrada PORT MAP(ent_a, ent_b, ent_f, ent_we, ent_clk, ent_clr, sort_out);

		PROCESS(ent_a, ent_b, ent_f, ent_we, ent_clk, ent_clr)
			BEGIN

				ent_f(2) <= NOT ent_f(2) AFTER 300 ns;
				ent_f(1) <= NOT ent_f(1) AFTER 200 ns;
				ent_f(0) <= NOT ent_f(0) AFTER 100 ns;

				ent_a(2) <= NOT ent_a(2) AFTER 300 ns;
				ent_a(1) <= NOT ent_a(1) AFTER 200 ns;
				ent_a(0) <= NOT ent_a(0) AFTER 100 ns;

				ent_b(2) <= NOT ent_b(2) AFTER 300 ns;
				ent_b(1) <= NOT ent_b(1) AFTER 200 ns;
				ent_b(0) <= NOT ent_b(0) AFTER 100 ns;

				ent_we <= NOT ent_we AFTER 350 ns;
				ent_clk <= NOT ent_clk AFTER 20 ns;
				ent_clr <= NOT ent_clr AFTER 500 ns ;
		END PROCESS;
END test;