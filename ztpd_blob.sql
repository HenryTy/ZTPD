--1
CREATE TABLE MOVIES(
ID NUMBER(12) PRIMARY KEY,
TITLE VARCHAR2(400) NOT NULL,
CATEGORY VARCHAR2(50),
YEAR CHAR(12),
CAST VARCHAR2(4000),
DIRECTOR VARCHAR2(4000),
STORY VARCHAR2(4000),
PRICE NUMBER(5,2),
COVER BLOB,
MIME_TYPE VARCHAR2(50)
);

--2
INSERT INTO MOVIES
SELECT d.id, d.title, d.category, d.year, d.cast, d.director, d.story, d.price, c.image, c.mime_type
FROM DESCRIPTIONS d LEFT OUTER JOIN COVERS c ON d.ID = c.movie_id;

--3
select * from movies where cover is null;

--4
select id, title, dbms_lob.getlength(cover) as filesize from movies where cover is not null;

--5
select id, title, dbms_lob.getlength(cover) as filesize from movies where cover is null;

--6
select * from ALL_DIRECTORIES;

--7
update movies set cover=EMPTY_BLOB() where id=66;
update movies set mime_type='image/jpeg' where id=66;

--8
select id, title, dbms_lob.getlength(cover) as filesize from movies where id in (65, 66);

--9
DECLARE
    fil BFILE := BFILENAME('ZSBD_DIR', 'escape.jpg');
    v_cover BLOB;
BEGIN
    SELECT cover
    INTO v_cover
    FROM movies
    WHERE id = 66
    FOR UPDATE;
    dbms_lob.fileopen(fil);
    DBMS_LOB.LOADFROMFILE(v_cover,fil,DBMS_LOB.GETLENGTH(fil));
    dbms_lob.fileclose(fil);
END;

--10
CREATE TABLE TEMP_COVERS(
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50)
);

--11
INSERT INTO TEMP_COVERS VALUES(65, BFILENAME('ZSBD_DIR', 'eagles.jpg'), 'image/jpeg');

--12
select movie_id, dbms_lob.getlength(image) as filesize from temp_covers;

--13
DECLARE
    v_image BFILE;
    v_mime_type VARCHAR2(50);
    v_blob BLOB;
BEGIN
    SELECT image, mime_type
    INTO v_image, v_mime_type
    FROM temp_covers
    WHERE movie_id=65;
    
    dbms_lob.createtemporary(v_blob,TRUE);
    
    dbms_lob.fileopen(v_image);
    DBMS_LOB.LOADFROMFILE(v_blob,v_image,DBMS_LOB.GETLENGTH(v_image));
    dbms_lob.fileclose(v_image);
    
    UPDATE movies SET cover=v_blob, mime_type=v_mime_type WHERE id=65;
    
    dbms_lob.freetemporary(v_blob);
END;

--14
select id, title, dbms_lob.getlength(cover) as filesize from movies where id in (65, 66);

--15
DROP TABLE MOVIES;
DROP TABLE TEMP_COVERS;