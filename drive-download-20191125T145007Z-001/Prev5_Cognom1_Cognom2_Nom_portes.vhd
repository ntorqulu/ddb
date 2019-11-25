-- INVERSOR:
ENTITY inv IS 
	PORT(a:IN BIT; z:OUT BIT);
END inv;

ARCHITECTURE logicaretard OF inv IS
BEGIN 
  z <= NOT a AFTER 5 ns;
END logicaretard;


-- AND2:
ENTITY and2 IS
PORT(a, b: IN BIT; z: OUT BIT);
END and2;

ARCHITECTURE logica OF and2 IS
BEGIN
z <= a AND b;
END logica;

ARCHITECTURE logicaretard OF and2 IS
BEGIN
z <= a AND b AFTER 5 ns;
END logicaretard;


-- OR2:

ENTITY or2 IS
PORT (a, b: IN BIT; z: OUT BIT);
END or2;

ARCHITECTURE logica OF or2 IS
BEGIN
z <= a OR b;
END logica;


-- NOR2:
ENTITY nor2 IS
PORT(a, b: IN BIT; z: OUT BIT);
END nor2;

ARCHITECTURE logicaretard OF nor2 IS
BEGIN
z <= a NOR b AFTER 5 ns;
END logicaretard;


-- XOR 2:

ENTITY xor2 IS
PORT (a, b: IN BIT; z: OUT BIT);
END xor2;

ARCHITECTURE logica OF xor2 IS
BEGIN
z <= a XOR b;
END logica;
