--2.c Només he trobat un error en el desplaçament de la funció.

--2d. Quan les entrades fem que variin cada
--5ns, la funció 2 logica respon de manera correcta,
--d'acord amb la taula de la veritat. Ara be, la funcio
--estructural que te un endarreriment de 3ns en cada porta
--logica mante un retard de 6 ns respecte la funcio
--logica, pt com que les variables varien els seus valors
--cada 5 ns actualitzara el seu estat quan les variables ja
--estiguin actualitzant la seguent combinacio de valors.
--P.t mantindra un retras d'una combinacio respecte
--la funcio logica.


ENTITY funcio_2 IS
	PORT(a, b, c, d:IN BIT; f:OUT BIT);
END funcio_2;

ARCHITECTURE logica OF funcio_2 is
	BEGIN
	f <= ((a AND c) AND(a XOR d))OR((NOT b)AND c);
END logica;

--Comencem amb la def de l'arquitectura estructural de entitat funcio_logica

ARCHITECTURE estructural OF funcio_2 IS
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
COMPONENT portaxor2 IS
	PORT(a, b:IN BIT; z:OUT BIT);
END COMPONENT;
--SENYALS INTERNES PER A PODER FER CONNEXIONS ENTRE PORTES. SERAN LES ENTRADES
--I SORTIDES ENTRE COMPONENTS. LES SENYALS A, B, C I F ja les tenim deff
SIGNAL invb, alpha, beta, gamma, delta:BIT;

--DEFINIM QUANTS DISPOSITIUS UTILITZAREM--->5
FOR DUT1: portaand2 USE ENTITY WORK.and2(logicaretard);
FOR DUT2: portaxor2 USE ENTITY WORK.xor2(logicaretard);
FOR DUT3: portainv USE ENTITY WORK.inv(logicaretard);
FOR DUT4: portaand2 USE ENTITY WORK.and2(logicaretard);
FOR DUT5: portaand2 USE ENTITY WORK.and2(logicaretard);
FOR DUT6: portaor2 USE ENTITY WORK.or2(logicaretard);

BEGIN--i mapegem  inputs i outputs dels components interns que utilitzem
	DUT1: portaand2 PORT MAP(a,c, alpha);
	DUT2: portaxor2 PORT MAP(a,d, beta);
	DUT3: portainv PORT MAP(b,invb);
	DUT4: portaand2 PORT MAP(invb, c, gamma);
	DUT5: portaand2 PORT MAP(alpha,beta,delta);
	DUT6: portaor2 PORT MAP(delta,gamma,f);
END estructural;



ENTITY banc_de_proves IS
END banc_de_proves;

ARCHITECTURE test OF banc_de_proves IS
--definim el component que volem testejar, el sistema amb els components interns.
--OBS. no ens cal def altre cop els components interns ja que es troben dins l'arquitectura

COMPONENT bloc_que_simulem IS
	PORT(a, b, c, d:IN BIT; f:OUT BIT);
END COMPONENT;

--DEFINIM ENTRADES I SORTIDES DE LA FUNCIÓ
SIGNAL ent3, ent2, ent1, ent0, sort_logica, sort_estructural:BIT;
FOR DUT1:bloc_que_simulem USE ENTITY WORK.funcio_2(logica);--correspondrà a aplicar funció lògica directament sense utilitzar entitatsamb retard
FOR DUT2:bloc_que_simulem USE ENTITY WORK.funcio_2(estructural);--correspondrà a utilitzar les estructures def amb retard

BEGIN
	DUT1:bloc_que_simulem PORT MAP(ent3, ent2, ent1, ent0, sort_logica);
	DUT2:bloc_que_simulem PORT MAP(ent3, ent2, ent1, ent0, sort_estructural);

PROCESS(ent3, ent2, ent1, ent0)
	BEGIN
	ent3<= NOT ent3 AFTER 400 ns;
	ent2 <= NOT ent2 AFTER 200 ns;
	ent1 <= NOT ent1 AFTER 100 ns;
	ent0 <= NOT ent0 AFTER 50 ns;
END PROCESS;
END test;
