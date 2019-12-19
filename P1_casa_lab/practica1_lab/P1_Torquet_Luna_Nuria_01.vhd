--Primer declarem l'objecte
ENTITY and2 IS
	PORT(a, b:IN BIT; z:OUT BIT);
END and2;

ENTITY and3 IS
	PORT(a, b, c:IN BIT; z:OUT BIT);
END and3;


ENTITY and4 IS
	PORT(a, b, c, d:IN BIT; z:OUT BIT);
END and4;


ENTITY or2 IS
	PORT(a, b:IN BIT; z:OUT BIT);
END or2;

ENTITY or3 IS
	PORT(a, b, c:IN BIT; z:OUT BIT);
END or3;

ENTITY or4 IS
	PORT(a, b, c, d:IN BIT; z:OUT BIT);
END or4;

ENTITY inversor IS
	PORT(a:IN BIT; z:OUT BIT);
END inversor;




ARCHITECTURE logica OF and2 IS
	BEGIN
	z <= a AND b;
END logica;


---Pràctica 1, afegim logicaretard

ARCHITECTURE logicaretard OF and2 IS
	BEGIN
	z<= a AND b AFTER 3 ns;
END logicaretard;



ARCHITECTURE logica OF and3 IS
	BEGIN
	z <= a AND b AND c;
END logica;

ARCHITECTURE logicaretard OF and3 IS
	BEGIN
	z <= a AND b AND c AFTER 3 ns;
END logicaretard;



ARCHITECTURE logica OF and4 IS
	BEGIN
	z <= a AND b AND c AND d;
END logica;

ARCHITECTURE logicaretard OF and4 IS
	BEGIN
	z <= a AND b AND c AND d AFTER 3 ns;
END logicaretard;



ARCHITECTURE logica OF or2 IS
	BEGIN
	z <= a OR b;
END logica;

ARCHITECTURE logicaretard OF or2 IS
	BEGIN
	z <= a OR b AFTER 3 ns;
END logicaretard;

ARCHITECTURE logica OF or3 IS
	BEGIN
	z <= a OR b OR c;
END logica;

ARCHITECTURE logicaretard OF or3 IS
	BEGIN
	z <= a OR b OR c AFTER 3 ns;
END logicaretard;


ARCHITECTURE logica OF or4 IS
	BEGIN
	z <= a OR b OR c OR d;
END logica;

ARCHITECTURE logicaretard OF or4 IS
	BEGIN
	z <= a OR b OR c OR d AFTER 3 ns;
END logicaretard;

ARCHITECTURE logica OF inversor IS
	BEGIN
	z <= NOT a;
END logica;

ARCHITECTURE logicaretard OF inversor IS
	BEGIN
	z <= NOT a AFTER 3 ns;
END logicaretard;