--1
--A
INSERT INTO USER_SDO_GEOM_METADATA VALUES (
    'FIGURY',
    'KSZTALT',
    MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', 0, 10, 0.01),
        MDSYS.SDO_DIM_ELEMENT('Y', 0, 8, 0.01)),
    NULL);
    
--B
SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000, 8192, 10, 2, 0) FROM DUAL;

--C
create index KSZTALT_IDX
on FIGURY(KSZTALT)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

--D
select ID
from FIGURY
where SDO_FILTER(KSZTALT,
SDO_GEOMETRY(2001,null,
SDO_POINT_TYPE(3,3,null),
null,null)) = 'TRUE';

--E
select ID
from FIGURY
where SDO_RELATE(KSZTALT,
SDO_GEOMETRY(2001,null,
SDO_POINT_TYPE(3,3,null),
null,null),
'mask=ANYINTERACT') = 'TRUE';

--2
--A
SELECT CITY_NAME, t.x, t.y 
FROM MAJOR_CITIES c, TABLE(SDO_UTIL.GETVERTICES(c.geom)) t
WHERE CITY_NAME = 'Warsaw';

SELECT
    city_name,
    sdo_nn_distance(1) distance
FROM
    major_cities
WHERE
    sdo_nn(geom, mdsys.sdo_geometry(2001, 8307, NULL, mdsys.sdo_elem_info_array(1, 1, 1),
    mdsys.sdo_ordinate_array(21.0118794, 52.2449452)), 'sdo_num_res=10 unit=km', 1) = 'TRUE'
    AND city_name != 'Warsaw';

--B
SELECT
    c.city_name
FROM
    major_cities c
WHERE
    sdo_within_distance(c.geom, 
    sdo_geometry(2001, 8307, NULL, mdsys.sdo_elem_info_array(1, 1, 1),
    mdsys.sdo_ordinate_array(21.0118794, 52.2449452)),'distance=100 unit=km') = 'TRUE';
    
--C
select CITY_NAME
from MAJOR_CITIES
where SDO_RELATE(GEOM,
(SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME='Slovakia'),
'mask=ANYINTERACT') = 'TRUE';

--D
select CNTRY_NAME, 
SDO_GEOM.SDO_DISTANCE(GEOM, (SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME='Poland'), 1, 'unit=km')
from COUNTRY_BOUNDARIES
where SDO_RELATE(GEOM,
(SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME='Poland'),
'mask=TOUCH') != 'TRUE';

--3
--A
select CNTRY_NAME, 
SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(GEOM, (SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME='Poland'), 1), 1, 'unit=km')
from COUNTRY_BOUNDARIES
where SDO_RELATE(GEOM,
(SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME='Poland'),
'mask=TOUCH') = 'TRUE';

--B
select A.CNTRY_NAME, ROUND(SDO_GEOM.sdo_area(A.GEOM, 1, 'unit=SQ_KM')) POWIERZCHNIA
from COUNTRY_BOUNDARIES A
order by 2 desc
fetch first 1 row only;

--C
select SDO_GEOM.sdo_area(SDO_GEOM.SDO_MBR(SDO_AGGR_UNION(MDSYS.SDOAGGRTYPE(GEOM,1))), 1, 'unit=SQ_KM') 
from major_cities 
where city_name in ('Warsaw', 'Lodz');

--D
select t.GEOM.GET_DIMS(), t.GEOM.GET_LRS_DIM(), t.GEOM.GET_GTYPE()
from
(select SDO_AGGR_UNION(MDSYS.SDOAGGRTYPE(g.GEOM,1)) GEOM
from (select geom from country_boundaries where cntry_name='Poland'
union all
select geom from major_cities where city_name='Prague') g) t;

--E
select mc.city_name, cntry_name, SDO_GEOM.SDO_DISTANCE(mc.geom, SDO_GEOM.SDO_CENTROID(cb.GEOM,1), 1) distance
from major_cities mc join country_boundaries cb using(cntry_name)
order by distance
fetch first 1 row only;

--F
select name, 
sum(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(GEOM, (SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME='Poland'), 1), 1, 'unit=km'))
dlugosc
from rivers
where SDO_RELATE(GEOM,
(SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME='Poland'),
'mask=ANYINTERACT') = 'TRUE'
group by name;
