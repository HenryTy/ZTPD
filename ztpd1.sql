CREATE TYPE SAMOCHOD AS OBJECT (
    MARKA VARCHAR2(20),
    MODEL VARCHAR2(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10, 2)
);

CREATE TABLE SAMOCHODY OF SAMOCHOD;

INSERT INTO SAMOCHODY VALUES(SAMOCHOD('FIAT', 'BRAVA', 60000, DATE '1999-11-30', 25000));
INSERT INTO SAMOCHODY VALUES(SAMOCHOD('FORD', 'MONDEO', 80000, DATE '1997-05-30', 45000));
INSERT INTO SAMOCHODY VALUES(SAMOCHOD('MAZDA', '323', 12000, DATE '2000-09-30', 52000));

SELECT * FROM SAMOCHODY;

CREATE TABLE WLASCICIELE(IMIE VARCHAR2(100), NAZWISKO VARCHAR2(100), AUTO SAMOCHOD);

INSERT INTO WLASCICIELE VALUES('JAN', 'KOWALSKI', SAMOCHOD('FIAT', 'BRAVA', 60000, DATE '1999-11-30', 25000));
INSERT INTO WLASCICIELE VALUES('ADAM', 'NOWAK', SAMOCHOD('FORD', 'MONDEO', 80000, DATE '1997-05-30', 45000));

select w.auto.marka from wlasciciele w;

ALTER TYPE SAMOCHOD REPLACE AS OBJECT (
    MARKA VARCHAR2(20),
    MODEL VARCHAR2(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10, 2),
    MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY SAMOCHOD AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        BEGIN
            RETURN cena*power(0.9, EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_produkcji));
        END wartosc;
END;

SELECT s.marka, s.cena, s.wartosc() FROM SAMOCHODY s;

ALTER TYPE samochod ADD MAP MEMBER FUNCTION odwzoruj
RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY SAMOCHOD AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        BEGIN
            RETURN cena*power(0.9, EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_produkcji));
        END wartosc;
    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS
        BEGIN
            RETURN kilometry + 10000*(EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_produkcji));
        END odwzoruj;
END;

SELECT * FROM SAMOCHODY s ORDER BY VALUE(s);

CREATE TYPE WLASCICIEL AS OBJECT (
    IMIE VARCHAR2(20),
    NAZWISKO VARCHAR2(20)
);

ALTER TYPE SAMOCHOD ADD ATTRIBUTE (WLASC REF WLASCICIEL)
CASCADE INCLUDING TABLE DATA;

CREATE TABLE WlascicielObjTab OF WLASCICIEL;

INSERT INTO WlascicielObjTab VALUES(WLASCICIEL('Tony', 'Stark'));

---

UPDATE samochody s SET s.wlasc = (SELECT REF(w) FROM WlascicielObjTab w WHERE nazwisko = 'Stark');

SELECT marka, model, s.wlasc.nazwisko FROM samochody s;


DECLARE
    TYPE t_przedmioty IS
        VARRAY(10) OF VARCHAR2(20);
    moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
    moje_przedmioty(1) := 'MATEMATYKA';
    moje_przedmioty.extend(9);
    FOR i IN 2..10 LOOP moje_przedmioty(i) := 'PRZEDMIOT_' || i;
    END LOOP;

    FOR i IN moje_przedmioty.first()..moje_przedmioty.last() LOOP 
        dbms_output.put_line(moje_przedmioty(i));
    END LOOP;

    moje_przedmioty.trim(2);
    FOR i IN moje_przedmioty.first()..moje_przedmioty.last() LOOP
        dbms_output.put_line(moje_przedmioty(i));
    END LOOP;
    dbms_output.put_line('Limit: ' || moje_przedmioty.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_przedmioty.count());
    moje_przedmioty.extend();
    moje_przedmioty(9) := 9;
    dbms_output.put_line('Limit: ' || moje_przedmioty.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_przedmioty.count());
    moje_przedmioty.DELETE();
    dbms_output.put_line('Limit: ' || moje_przedmioty.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_przedmioty.count());
END;

SET SERVEROUTPUT ON;
DECLARE
    TYPE t_ksiazki IS
        VARRAY(10) OF VARCHAR2(20);
    moje_ksiazki t_ksiazki := t_ksiazki('');
BEGIN
    moje_ksiazki(1) := 'Jakis tytul';
    moje_ksiazki.extend(1);
    moje_ksiazki(2) := 'Jakis inny tytul';
    FOR i IN moje_ksiazki.first()..moje_ksiazki.last() LOOP 
        dbms_output.put_line(moje_ksiazki(i));
    END LOOP;
    moje_ksiazki.trim(1);
    FOR i IN moje_ksiazki.first()..moje_ksiazki.last() LOOP 
        dbms_output.put_line(moje_ksiazki(i));
    END LOOP;
END;

DECLARE
    TYPE t_wykladowcy IS
        TABLE OF VARCHAR2(20);
    moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
    moi_wykladowcy.extend(2);
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';
    moi_wykladowcy.extend(8);
    FOR i IN 3..10 LOOP moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
    END LOOP;

    FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP dbms_output.put_line(moi_wykladowcy(i));
    END LOOP;

    moi_wykladowcy.trim(2);
    FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP dbms_output.put_line(moi_wykladowcy(i));
    END LOOP;

    moi_wykladowcy.DELETE(5, 7);
    dbms_output.put_line('Limit: ' || moi_wykladowcy.limit());
    dbms_output.put_line('Liczba elementow: ' || moi_wykladowcy.count());
    FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP IF moi_wykladowcy.EXISTS(i) THEN
        dbms_output.put_line(moi_wykladowcy(i));
    END IF;
    END LOOP;

    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';
    FOR i IN moi_wykladowcy.first()..moi_wykladowcy.last() LOOP IF moi_wykladowcy.EXISTS(i) THEN
        dbms_output.put_line(moi_wykladowcy(i));
    END IF;
    END LOOP;

    dbms_output.put_line('Limit: ' || moi_wykladowcy.limit());
    dbms_output.put_line('Liczba elementow: ' || moi_wykladowcy.count());
END;

DECLARE
    TYPE t_miesiace IS
        TABLE OF VARCHAR2(20);
    miesiace t_miesiace := t_miesiace();
BEGIN
    miesiace.extend(12);
    FOR i IN 1..12 LOOP miesiace(i) := TO_CHAR(TO_DATE(i, 'MM'), 'MONTH');
    END LOOP;
    miesiace.delete(3, 5);
    FOR i IN miesiace.first()..miesiace.last() LOOP IF miesiace.EXISTS(i) THEN
        dbms_output.put_line(miesiace(i));
    END IF;
    END LOOP;
END;

CREATE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/
CREATE TYPE stypendium AS OBJECT (
nazwa VARCHAR2(50),
kraj VARCHAR2(30),
jezyki jezyki_obce );
/
CREATE TABLE stypendia OF stypendium;
INSERT INTO stypendia VALUES
('SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI'));
INSERT INTO stypendia VALUES
('ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI'));
SELECT * FROM stypendia;
SELECT s.jezyki FROM stypendia s;
UPDATE STYPENDIA
SET jezyki = jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE nazwa = 'ERASMUS';
CREATE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/
CREATE TYPE semestr AS OBJECT (
numer NUMBER,
egzaminy lista_egzaminow );
/
CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;
INSERT INTO semestry VALUES
(semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA')));
INSERT INTO semestry VALUES
(semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE')));
SELECT s.numer, e.*
FROM semestry s, TABLE(s.egzaminy) e;
SELECT e.*
FROM semestry s, TABLE ( s.egzaminy ) e;
SELECT * FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=1 );
INSERT INTO TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 )
VALUES ('METODY NUMERYCZNE');
UPDATE TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';
DELETE FROM TABLE ( SELECT s.egzaminy FROM semestry s WHERE numer=2 ) e
WHERE e.column_value = 'BAZY DANYCH';

CREATE TYPE produkty AS TABLE OF VARCHAR(20);
CREATE TABLE zakupy(id INTEGER, koszyk_produktow produkty)
NESTED TABLE koszyk_produktow STORE AS tab_produkty;
INSERT INTO zakupy VALUES(1, produkty('jajka', 'chleb', 'mleko'));
INSERT INTO zakupy VALUES(2, produkty('maslo', 'jajka'));
INSERT INTO zakupy VALUES(3, produkty('ser'));

SELECT * FROM zakupy;

DELETE FROM zakupy z WHERE EXISTS(SELECT * FROM TABLE(z.koszyk_produktow) k WHERE k.column_value='jajka');


CREATE TYPE instrument AS OBJECT (
nazwa VARCHAR2(20),
dzwiek VARCHAR2(20),
MEMBER FUNCTION graj RETURN VARCHAR2 ) NOT FINAL;
CREATE OR REPLACE TYPE BODY instrument AS
MEMBER FUNCTION graj RETURN VARCHAR2 IS
BEGIN
RETURN dzwiek;
END;
END;
/
CREATE TYPE instrument_dety UNDER instrument (
material VARCHAR2(20),
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_dety AS
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
BEGIN
RETURN 'dmucham: '||dzwiek;
END;
MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
BEGIN
RETURN glosnosc||':'||dzwiek;
END;
END;
/
CREATE TYPE instrument_klawiszowy UNDER instrument (
producent VARCHAR2(20),
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
BEGIN
RETURN 'stukam w klawisze: '||dzwiek;
END;
END;
/
DECLARE
tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','ping-ping','steinway');
BEGIN
dbms_output.put_line(tamburyn.graj);
dbms_output.put_line(trabka.graj);
dbms_output.put_line(trabka.graj('glosno'));
dbms_output.put_line(fortepian.graj);
END;


CREATE TYPE istota AS OBJECT (
nazwa VARCHAR2(20),
NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR )
NOT INSTANTIABLE NOT FINAL;
/
CREATE TYPE lew UNDER istota (
liczba_nog NUMBER,
OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR );
/
CREATE OR REPLACE TYPE BODY lew AS
OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
BEGIN
RETURN 'upolowana ofiara: '||ofiara;
END;
END;
/
DECLARE
KrolLew lew := lew('LEW',4);
InnaIstota istota := istota('JAKIES ZWIERZE');
BEGIN
DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;

DECLARE
tamburyn instrument;
cymbalki instrument;
trabka instrument_dety;
saksofon instrument_dety;
BEGIN
tamburyn := instrument('tamburyn','brzdek-brzdek');
cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
trabka
:= instrument_dety('trabka','tra-ta-ta','metalowa');
-- saksofon := instrument('saksofon','tra-taaaa');
-- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;


CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );
INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa'));
INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','ping-ping','steinway') );
SELECT i.nazwa, i.graj() FROM instrumenty i;

CREATE TABLE PRZEDMIOTY (
NAZWA VARCHAR2(50),
NAUCZYCIEL NUMBER REFERENCES PRACOWNICY(ID_PRAC)
);

INSERT INTO przedmioty VALUES (
    'BAZY DANYCH',
    100
);

INSERT INTO przedmioty VALUES (
    'SYSTEMY OPERACYJNE',
    100
);

INSERT INTO przedmioty VALUES (
    'PROGRAMOWANIE',
    110
);

INSERT INTO przedmioty VALUES (
    'SIECI KOMPUTEROWE',
    110
);

INSERT INTO przedmioty VALUES (
    'BADANIA OPERACYJNE',
    120
);

INSERT INTO przedmioty VALUES (
    'GRAFIKA KOMPUTEROWA',
    120
);

INSERT INTO przedmioty VALUES (
    'BAZY DANYCH',
    130
);

INSERT INTO przedmioty VALUES (
    'SYSTEMY OPERACYJNE',
    140
);

INSERT INTO przedmioty VALUES (
    'PROGRAMOWANIE',
    140
);

INSERT INTO przedmioty VALUES (
    'SIECI KOMPUTEROWE',
    140
);

INSERT INTO przedmioty VALUES (
    'BADANIA OPERACYJNE',
    150
);

INSERT INTO przedmioty VALUES (
    'GRAFIKA KOMPUTEROWA',
    150
);

INSERT INTO przedmioty VALUES (
    'BAZY DANYCH',
    160
);

INSERT INTO przedmioty VALUES (
    'SYSTEMY OPERACYJNE',
    160
);

INSERT INTO przedmioty VALUES (
    'PROGRAMOWANIE',
    170
);

INSERT INTO przedmioty VALUES (
    'SIECI KOMPUTEROWE',
    180
);

INSERT INTO przedmioty VALUES (
    'BADANIA OPERACYJNE',
    180
);

INSERT INTO przedmioty VALUES (
    'GRAFIKA KOMPUTEROWA',
    190
);

INSERT INTO przedmioty VALUES (
    'GRAFIKA KOMPUTEROWA',
    200
);

INSERT INTO przedmioty VALUES (
    'GRAFIKA KOMPUTEROWA',
    210
);

INSERT INTO przedmioty VALUES (
    'PROGRAMOWANIE',
    220
);

INSERT INTO przedmioty VALUES (
    'SIECI KOMPUTEROWE',
    220
);

CREATE TYPE ZESPOL AS OBJECT (
ID_ZESP NUMBER,
NAZWA VARCHAR2(50),
ADRES VARCHAR2(100)
);

CREATE OR REPLACE VIEW ZESPOLY_V OF ZESPOL
WITH OBJECT IDENTIFIER(ID_ZESP)
AS SELECT ID_ZESP, NAZWA, ADRES FROM ZESPOLY;

CREATE TYPE PRZEDMIOTY_TAB AS TABLE OF VARCHAR2(100);
/
CREATE TYPE PRACOWNIK AS OBJECT (
ID_PRAC NUMBER,
NAZWISKO VARCHAR2(30),
ETAT VARCHAR2(20),
ZATRUDNIONY DATE,
PLACA_POD NUMBER(10,2),
MIEJSCE_PRACY REF ZESPOL,
PRZEDMIOTY PRZEDMIOTY_TAB,
MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY PRACOWNIK AS
MEMBER FUNCTION ILE_PRZEDMIOTOW RETURN NUMBER IS
BEGIN
RETURN PRZEDMIOTY.COUNT();
END ILE_PRZEDMIOTOW;
END;

CREATE OR REPLACE VIEW PRACOWNICY_V OF PRACOWNIK
WITH OBJECT IDENTIFIER (ID_PRAC)
AS SELECT ID_PRAC, NAZWISKO, ETAT, ZATRUDNIONY, PLACA_POD,
MAKE_REF(ZESPOLY_V,ID_ZESP),
CAST(MULTISET( SELECT NAZWA FROM PRZEDMIOTY WHERE NAUCZYCIEL=P.ID_PRAC ) AS
PRZEDMIOTY_TAB )
FROM PRACOWNICY P;

SELECT *
FROM PRACOWNICY_V;
SELECT P.NAZWISKO, P.ETAT, P.MIEJSCE_PRACY.NAZWA
FROM PRACOWNICY_V P;
SELECT P.NAZWISKO, P.ILE_PRZEDMIOTOW()
FROM PRACOWNICY_V P;
SELECT *
FROM TABLE( SELECT PRZEDMIOTY FROM PRACOWNICY_V WHERE NAZWISKO='WEGLARZ' );
SELECT NAZWISKO, CURSOR( SELECT PRZEDMIOTY
FROM PRACOWNICY_V
WHERE ID_PRAC=P.ID_PRAC)
FROM PRACOWNICY_V P;

CREATE TABLE PISARZE (
ID_PISARZA NUMBER PRIMARY KEY,
NAZWISKO VARCHAR2(20),
DATA_UR DATE );
CREATE TABLE KSIAZKI (
ID_KSIAZKI NUMBER PRIMARY KEY,
ID_PISARZA NUMBER NOT NULL REFERENCES PISARZE,
TYTUL VARCHAR2(50),
DATA_WYDANIA DATE );
INSERT INTO PISARZE VALUES(10,'SIENKIEWICZ',DATE '1880-01-01');
INSERT INTO PISARZE VALUES(20,'PRUS',DATE '1890-04-12');
INSERT INTO PISARZE VALUES(30,'ZEROMSKI',DATE '1899-09-11');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(10,10,'OGNIEM I MIECZEM',DATE '1990-01-05');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA)
VALUES(20,10,'POTOP',DATE '1975-12-09');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA) VALUES(30,10,'PAN WOLODYJOWSKI',DATE '1987-02-15');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA)
VALUES(40,20,'FARAON',DATE '1948-01-21');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA)
VALUES(50,20,'LALKA',DATE '1994-08-01');
INSERT INTO KSIAZKI(ID_KSIAZKI,ID_PISARZA,TYTUL,DATA_WYDANIA)
VALUES(60,30,'PRZEDWIOSNIE',DATE '1938-02-02');

CREATE TYPE pisarz AS OBJECT(
ID_PISARZA NUMBER,
NAZWISKO VARCHAR2(20),
DATA_UR DATE
);

CREATE TYPE ksiazka AS OBJECT(
ID_KSIAZKI NUMBER,
AUTOR REF pisarz,
TYTUL VARCHAR2(50),
DATA_WYDANIA DATE
);

CREATE OR REPLACE VIEW pisarze_v OF pisarz
WITH OBJECT IDENTIFIER(ID_PISARZA)
AS SELECT ID_PISARZA, NAZWISKO, DATA_UR FROM pisarze;

CREATE OR REPLACE VIEW ksiazki_v OF ksiazka
WITH OBJECT IDENTIFIER(ID_KSIAZKI)
AS SELECT ID_KSIAZKI, MAKE_REF(pisarze_v, ID_PISARZA), TYTUL, DATA_WYDANIA FROM ksiazki;

ALTER TYPE pisarz ADD MEMBER FUNCTION ILE_KSIAZEK
RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY pisarz AS
MEMBER FUNCTION ILE_KSIAZEK RETURN NUMBER IS
    result NUMBER;
    v_id_pisarza NUMBER := id_pisarza;
BEGIN
    SELECT COUNT(ID_KSIAZKI) INTO result FROM ksiazki k WHERE v_id_pisarza=k.id_pisarza;
    RETURN result;
END ILE_KSIAZEK;
END;

select p.nazwisko, p.ile_ksiazek() from pisarze_v p;

ALTER TYPE ksiazka ADD MEMBER FUNCTION WIEK
RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY ksiazka AS
MEMBER FUNCTION WIEK RETURN NUMBER IS
BEGIN
    RETURN EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_wydania);
END WIEK;
END;

select k.tytul, k.wiek() from ksiazki_v k;


CREATE TYPE AUTO AS OBJECT (
 MARKA VARCHAR2(20),
 MODEL VARCHAR2(20),
 KILOMETRY NUMBER,
 DATA_PRODUKCJI DATE,
 CENA NUMBER(10,2),
 MEMBER FUNCTION WARTOSC RETURN NUMBER
);
CREATE OR REPLACE TYPE BODY AUTO AS
 MEMBER FUNCTION WARTOSC RETURN NUMBER IS
 WIEK NUMBER;
 WARTOSC NUMBER;
 BEGIN
 WIEK := ROUND(MONTHS_BETWEEN(SYSDATE,DATA_PRODUKCJI)/12);
 WARTOSC := CENA - (WIEK * 0.1 * CENA);
 IF (WARTOSC < 0) THEN
 WARTOSC := 0;
 END IF;
 RETURN WARTOSC;
 END WARTOSC;
END;
CREATE TABLE AUTA OF AUTO;
INSERT INTO AUTA VALUES (AUTO('FIAT','BRAVA',60000,DATE '2019-11-30',25000));
INSERT INTO AUTA VALUES (AUTO('FORD','MONDEO',80000,DATE '2020-05-10',45000));
INSERT INTO AUTA VALUES (AUTO('MAZDA','323',12000,DATE '2018-09-22',52000));

ALTER TYPE AUTO NOT FINAL CASCADE;

CREATE TYPE AUTO_OSOBOWE UNDER AUTO (
    LICZBA_MIEJSC NUMBER,
    KLIMATYZACJA VARCHAR2(3),
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
);

CREATE TYPE AUTO_CIEZAROWE UNDER AUTO (
    LADOWNOSC NUMBER,
    OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY AUTO_OSOBOWE AS
 OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
 WARTOSC NUMBER;
 BEGIN
 WARTOSC := (self as auto).wartosc();
 IF klimatyzacja = 'TAK' THEN
    WARTOSC := 1.5 * WARTOSC;
 END IF;
 RETURN WARTOSC;
 END WARTOSC;
END;

CREATE OR REPLACE TYPE BODY AUTO_CIEZAROWE AS
 OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS
 WARTOSC NUMBER;
 BEGIN
 WARTOSC := (self as auto).wartosc();
 IF ladownosc > 10 THEN
    WARTOSC := 2 * WARTOSC;
 END IF;
 RETURN WARTOSC;
 END WARTOSC;
END;

INSERT INTO AUTA VALUES (AUTO_OSOBOWE('FIAT','BRAVA',60000,DATE '2019-11-30',25000, 5, 'TAK'));
INSERT INTO AUTA VALUES (AUTO_OSOBOWE('FORD','MONDEO',80000,DATE '2020-05-10',45000, 6, 'NIE'));
INSERT INTO AUTA VALUES (AUTO_CIEZAROWE('MAZDA','323',12000,DATE '2018-09-22',52000, 8));
INSERT INTO AUTA VALUES (AUTO_CIEZAROWE('MAZDA','323',12000,DATE '2018-09-22',52000, 12));

select a.marka, a.wartosc() from auta a;