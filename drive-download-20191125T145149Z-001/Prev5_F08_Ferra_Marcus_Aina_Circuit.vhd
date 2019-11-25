--I've changed variable's names following the logic
--uppercases for language syntax and lowercases for variable's names. 


-------------------------------Latch D positive level-triggered.

ENTITY Latch_D_PreClear IS
	PORT(d, clk, pre, clr: IN BIT; q, noq: OUT BIT);
END Latch_D_PreClear;

ARCHITECTURE ifthen OF Latch_D_PreClear IS
	SIGNAL qint: BIT;

	BEGIN
		PROCESS (d, clk, pre, clr)
			BEGIN

				--Preset has priority.
				--When preset is 0, output signal is set to 1.
				IF pre = '0' THEN qint<= '1' AFTER 2 ns;
				--Clear is second on the priority scale. 
				--When clear signal is 0, output signal is set to 0.
				ELSE
					IF clr = '0' THEN qint <='0' AFTER 2 ns;
					ELSE
						--END of asynchronous signals.
						--Starting with synchronous behaviour.
						--Latch is level triggered. When clk = '1', do...
						--Also, this is a D, so future Q = D.
						IF clk = '1' THEN qint <= d AFTER 6 ns;
						END IF;
					END IF;
				END IF;
		END PROCESS;
		q <=qint; noq <= NOT qint; 
END ifthen;


--------------------------------------Flip-Flop JK positive edge-triggered.

ENTITY FF_JK_PreClear IS
	PORT (j, k, clk, pre, clr: IN BIT; q, noq: OUT BIT);
END FF_JK_PreClear;

ARCHITECTURE ifthen of FF_JK_PreClear IS
	SIGNAL qint: BIT;
	BEGIN
		PROCESS (j, k, clk, pre, clr)
			BEGIN

				--Asynchronous calls.
				--Preset signal has priority. 
				IF pre = '0' THEN qint <= '1' AFTER 2 ns;
				ELSE

					--Clear is second on the priority scale.
					IF clr = '0' THEN qint <= '0' AFTER 2 ns;
					ELSE

						--Starting with synchronous behaviour.
						--Flip-flop means that this is edge triggered.
						--When clock changes from 0 to 1, it allows the change.
						-- future Q = (J AND (NOT Q)) OR ((NOT K) AND Q))
						IF clk'EVENT AND clk = '1' THEN 
							IF j='0' AND k='0' THEN qint<=qint AFTER 6 ns;
							ELSIF j='0' AND k='1' THEN qint<='0' AFTER 6 ns;
							ELSIF j='1' AND k='0' THEN qint<='1' AFTER 6 ns;
							ELSIF j='1' AND k='1' THEN qint<= NOT qint AFTER 6 ns;
							END IF;
						END IF;
					END IF;
				END IF; 
		END PROCESS;
	q <= qint; noq <= NOT qint; 
END ifthen;


-------------------------------------Circuit design.

ENTITY circuit IS
	PORT (x, ck: IN BIT; z: OUT BIT);
END circuit;

ARCHITECTURE estructural OF circuit IS
	--Components we will need:
		--1 inversor.
		--1 and2 port.
		--1 nor2 port.
		--1 latch D structure.
		--1 flip-flop JK structure.


	COMPONENT porta_inv IS
		PORT (a: IN BIT; z: OUT BIT);
	END COMPONENT;

	COMPONENT porta_and2 IS
		PORT (a, b: IN BIT; z: OUT BIT);
	END COMPONENT;

	COMPONENT porta_nor2 IS
		PORT (a, b: IN BIT; z: OUT BIT);
	END COMPONENT;

	COMPONENT latchD IS
		PORT (d, clk, pre, clr: IN BIT; q, noq: OUT BIT);
	END COMPONENT;

	COMPONENT flipflopJK IS
		PORT (j, k, clk, pre, clr: IN BIT; q, noq: OUT BIT);
	END COMPONENT;

	--Defining internal signals.
	SIGNAL nx, q_latch, noq_latch, xandnoq, nxnorq, nq_flipflop: BIT;

	--Pairing dispositives with its architectures.
	FOR DUT1: porta_inv USE ENTITY WORK.inv(logicaretard);
	FOR DUT2: latchD USE ENTITY WORK.Latch_D_PreClear(ifthen);
	FOR DUT3: porta_and2 USE ENTITY WORK.and2(logicaretard);
	FOR DUT4: porta_nor2 USE ENTITY WORK.nor2(logicaretard);
	FOR DUT5: flipflopJK USE ENTITY WORK.FF_JK_PreClear(ifthen); 

	BEGIN

		--First, we need a signal containing not x.
		DUT1: porta_inv PORT MAP(x, nx);
		--Our D signal is given by x signal, clock is also given.
		DUT2: latchD PORT MAP(x, ck, '1', '1', q_latch, noq_latch);
		--And port combines x and not q signal from our latchD.
		DUT3: porta_and2 PORT MAP(x, noq_latch, xandnoq);
		--Nor port combines not x and q signal from our latchD.
		DUT4: porta_nor2 PORT MAP(nx, q_latch, nxnorq);
		--J signal recieves result from and port, K signal recieves result from nor port, clock is given.
		DUT5: flipflopJK PORT MAP(xandnoq, nxnorq, ck, '1', '1', z, nq_flipflop);

END estructural;


--Let's test this out:

ENTITY bdp_circuit IS
END bdp_circuit;

ARCHITECTURE test of bdp_circuit IS

	COMPONENT simulating_circuit IS
		PORT (x, ck: IN BIT; z: OUT BIT);
	END COMPONENT; 

	SIGNAL in_x, in_ck, out_z: BIT;

	FOR DUT1: simulating_circuit USE ENTITY WORK.circuit(estructural);

	BEGIN
		DUT1: simulating_circuit PORT MAP(in_x, in_ck, out_z);

		PROCESS(in_x, in_ck)
			BEGIN

				in_x <= NOT in_x AFTER 173 ns;
				in_ck <= NOT in_ck AFTER 50 ns;
		END PROCESS;
END test;