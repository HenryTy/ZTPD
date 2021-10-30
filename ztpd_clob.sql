--1
CREATE TABLE DOKUMENTY(
    ID NUMBER(12) PRIMARY KEY,
    DOKUMENT CLOB
);

--2
DECLARE
    v_clob CLOB := EMPTY_CLOB();
BEGIN
    FOR i in 1..10000 LOOP
        v_clob := v_clob || 'Oto tekst.';
    END LOOP;
    INSERT INTO DOKUMENTY VALUES(1, v_clob);
END;

--3
SELECT * FROM DOKUMENTY;
SELECT UPPER(DOKUMENT) FROM DOKUMENTY;
SELECT LENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT DBMS_LOB.GETLENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT SUBSTR(DOKUMENT, 5, 1000) FROM DOKUMENTY;
SELECT DBMS_LOB.SUBSTR(DOKUMENT, 1000, 5) FROM DOKUMENTY;

--4
INSERT INTO DOKUMENTY VALUES(2, EMPTY_CLOB());

--5
INSERT INTO DOKUMENTY VALUES(3, NULL);

--7
SELECT * FROM ALL_DIRECTORIES;

--8
SET SERVEROUTPUT ON;
DECLARE
    fil BFILE := BFILENAME('ZSBD_DIR', 'dokument.txt');
    v_clob CLOB;
    doffset integer := 1;
    soffset integer := 1;
    langctx integer := 0;
    warn integer := null;
BEGIN
    SELECT dokument
    INTO v_clob
    FROM dokumenty
    WHERE id = 2
    FOR UPDATE;
    dbms_lob.fileopen(fil);
    DBMS_LOB.LOADCLOBFROMFILE(v_clob, fil , DBMS_LOB.LOBMAXSIZE, doffset, soffset, 0, langctx, warn);
    dbms_lob.fileclose(fil);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Status operacji: ' || warn);
END;

--9
UPDATE DOKUMENTY SET dokument = TO_CLOB(BFILENAME('ZSBD_DIR', 'dokument.txt')) WHERE id=3;

--10
SELECT * FROM DOKUMENTY;

--11
SELECT LENGTH(DOKUMENT) FROM DOKUMENTY;

--12
DROP TABLE DOKUMENTY;

--13
CREATE OR REPLACE PROCEDURE CLOB_CENSOR(
    IN_CLOB IN OUT CLOB,
    IN_TEXT VARCHAR2
)
IS
    idx INTEGER := 1;
    dots VARCHAR2(50) := LPAD('.', LENGTH(IN_TEXT), '.');
BEGIN
    LOOP
        idx := DBMS_LOB.INSTR(IN_CLOB, IN_TEXT, idx);
        IF idx = 0 THEN
            EXIT;
        END IF;
        DBMS_LOB.WRITE(IN_CLOB, LENGTH(IN_TEXT), idx, dots);
        idx := idx + 1;
    END LOOP;
END;

--14
CREATE TABLE BIOGRAPHIES
AS
SELECT *
FROM ZSBD_TOOLS.BIOGRAPHIES;

DECLARE
    v_clob CLOB;
BEGIN
    SELECT BIO
    INTO v_clob
    FROM BIOGRAPHIES
    WHERE ID = 1
    FOR UPDATE;
    CLOB_CENSOR(v_clob, 'Cimrman');
END;

SELECT * FROM BIOGRAPHIES;

--15
DROP TABLE BIOGRAPHIES;