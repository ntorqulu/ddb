--NOT XOR2 PORT HERE:
ENTITY notxor2 IS
  PORT(a, b: IN BIT; z: OUT BIT);
END notxor2;

ARCHITECTURE logicaretard OF notxor2 IS
  BEGIN
    z <= NOT (a XOR b) AFTER 2 ns;
END logicaretard;

--AND2 PORT HERE:
ENTITY and2 IS
  PORT (a,b: IN BIT; z: OUT BIT);
END and2;

--With 3 ns of delay.
ARCHITECTURE logicaretard OF and2 IS
BEGIN
  z <= a AND b AFTER 3 ns;
END logicaretard;


--Needed FFJK:
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



ENTITY circuit_maquina IS
  PORT(clk, x: IN BIT; z: OUT BIT_VECTOR(2 DOWNTO 0));
END circuit_maquina;

ARCHITECTURE estructural OF circuit_maquina IS
  
  --Let's see what do we need here.
  --We need a NOT XOR2 port.
  --Also an AND2 port.
  --Then, we need 2 positive edge-triggered FF JK.
  
  COMPONENT porta_notxor2 IS
    PORT(a, b: IN BIT; z: OUT BIT);
  END COMPONENT;

  COMPONENT porta_and2 IS
    PORT(a, b: IN BIT; z: OUT BIT);
  END COMPONENT;
  
  COMPONENT FFJK IS
    PORT(j, k, clk, pre, clr: IN BIT; q, noq: OUT BIT);
  END COMPONENT;
  
  SIGNAL q1, q0, q2: BIT :='0';
  SIGNAL xnxorq0, int_and, nq2, nq1, nq0: BIT;
  
  FOR DUT1: porta_notxor2 USE ENTITY WORK.notxor2(logicaretard);
  FOR DUT2: porta_and2 USE ENTITY WORK.and2(logicaretard);
  FOR DUT3: FFJK USE ENTITY WORK.FF_JK_PreClear(ifthen);
  FOR DUT4: FFJK USE ENTITY WORK.FF_JK_PreClear(ifthen);
  FOR DUT5: FFJK USE ENTITY WORK.FF_JK_PreClear(ifthen);
  
  BEGIN
    
    DUT1: porta_notxor2 PORT MAP (x, q0, xnxorq0);
    DUT2: porta_and2 PORT MAP (xnxorq0, q1, int_and);
    DUT3: FFJK PORT MAP (x, '1', clk, '1', '1',q0, nq0);
    DUT4: FFJK PORT MAP (xnxorq0, xnxorq0, clk, '1', '1', q1, nq1);
    DUT5: FFJK PORT MAP (int_and, int_and, clk, '1', '1', q2, nq2);
    
    
    z(2) <= q2;
    z(1) <= q1;
    z(0) <= q0;


END estructural;



ENTITY bancdeproves_maquina IS
END bancdeproves_maquina;

ARCHITECTURE test OF bancdeproves_maquina IS
  
  COMPONENT maquina IS
    PORT(clk, x: IN BIT; z: OUT BIT_VECTOR(2 DOWNTO 0));
  END COMPONENT;
  
  SIGNAL ent_clk, ent_x: BIT;
  SIGNAL out_z: BIT_VECTOR(2 DOWNTO 0);
  
  FOR DUT1: maquina USE ENTITY WORK.circuit_maquina(estructural);
  
  BEGIN
    
    DUT1: maquina PORT MAP(ent_clk, ent_x, out_z);
      
      PROCESS(ent_clk, ent_x)
        BEGIN
          
          ent_clk <= NOT ent_clk AFTER 15 ns;
          ent_x <= NOT ent_x AFTER 50 ns;
          
    END PROCESS;
    
END test;
    