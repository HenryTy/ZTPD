--1
--A
CREATE TABLE FIGURY(ID number(1) PRIMARY KEY, KSZTALT MDSYS.SDO_GEOMETRY);

--B
INSERT INTO FIGURY VALUES(1, MDSYS.SDO_GEOMETRY(2003, NULL, NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 4),
    MDSYS.SDO_ORDINATE_ARRAY(5,7, 7,5, 5,3)));

INSERT INTO FIGURY VALUES(2, MDSYS.SDO_GEOMETRY(2003, NULL, NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 3),
    MDSYS.SDO_ORDINATE_ARRAY(1,1, 5,5)));
    
INSERT INTO FIGURY VALUES(3, MDSYS.SDO_GEOMETRY(2002, NULL, NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,4,2, 1,2,1, 5,2,2),
    MDSYS.SDO_ORDINATE_ARRAY(3,2, 6,2, 7,3, 8,2, 7,1)));
    
--C
INSERT INTO FIGURY VALUES(5, MDSYS.SDO_GEOMETRY(2003, NULL, NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1, 1003, 4),
    MDSYS.SDO_ORDINATE_ARRAY(1,1, 2,2, 3,3)));
    
--D
select ID, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(KSZTALT, 0.01) VALID FROM FIGURY;

--E
DELETE FROM FIGURY WHERE SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(KSZTALT, 0.01) != 'TRUE';

--F
COMMIT;