##dealline JSON FUNCTION
##case1::Full-text search functions
#CREATE TABLE articles (id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEYtitle VARCHAR(200) body TEXTFULLTEXT (title,body)) ENGINE=InnoDB
#!multiline
#INSERT INTO articles (titlebody) VALUES
#    ('MySQL Tutorial''DBMS stands for DataBase ...')
#    ('How To Use MySQL Well''After you went through a ...')
#    ('Optimizing MySQL''In this tutorial we will show ...')
#    ('1001 MySQL Tricks''1. Never run mysqld as root. 2. ...')
#    ('MySQL vs. YourSQL''In the following database comparison ...')
#    ('MySQL Security''When configured properly MySQL ...')
#end multiline
#SELECT * FROM articles WHERE MATCH (titlebody) AGAINST ('database' IN NATURAL LANGUAGE MODE)
#SELECT COUNT(IF(MATCH (titlebody) AGAINST ('database' IN NATURAL LANGUAGE MODE) 1 NULL)) AS count FROM articles
#SELECT id MATCH (titlebody) AGAINST ('Tutorial' IN NATURAL LANGUAGE MODE) AS score FROM articles
#!multiline
#SELECT id body MATCH (titlebody) AGAINST
#    ('Security implications of running MySQL as root'
#    IN NATURAL LANGUAGE MODE) AS score
#    FROM articles WHERE MATCH (titlebody) AGAINST
#    ('Security implications of running MySQL as root'
#    IN NATURAL LANGUAGE MODE) order by score desc id
#end multiline
#SELECT * FROM articles WHERE MATCH (titlebody) AGAINST ('+MySQL -YourSQL' IN BOOLEAN MODE)
#SELECT id title body MATCH (titlebody)  AGAINST ('database' IN BOOLEAN MODE) AS score FROM articles ORDER BY score DESC id
#SELECT * FROM articles WHERE MATCH (titlebody) AGAINST ('database' WITH QUERY EXPANSION)
##case2::cast functions and operators
SELECT BINARY 'a' = 'A'
select cast('a'='A' as binary)
SELECT CONCAT('hello you ',2)
SELECT _binary 'a' = 'A'
#CREATE TABLE new_table SELECT CAST('2000-01-01' AS DATE)
##case3::XML Functions
#!share_conn
SET @xml = '<a><b>X</b><b>Y</b></a>'
SET @i =1, @j = 2
SELECT @i, ExtractValue(@xml, '//b[$@i]')
SELECT @j, ExtractValue(@xml, '//b[$@j]')
SELECT @k, ExtractValue(@xml, '//b[$@k]')
SELECT ExtractValue('<a><b/></a>', 'count(/a/b)')
SELECT UpdateXML('<a><b>ccc</b><d></d></a>', '/a', '<e>fff</e>') AS val1, UpdateXML('<a><b>ccc</b><d></d></a>', '/b', '<e>fff</e>') AS val2,UpdateXML('<a><b>ccc</b><d></d></a>', '//b', '<e>fff</e>') AS val3, UpdateXML('<a><b>ccc</b><d></d></a>', '/a/d', '<e>fff</e>') AS val4,UpdateXML('<a><d></d><b>ccc</b><d></d></a>', '/a/d', '<e>fff</e>') AS val5
SELECT ExtractValue('<a><b c="1"><d>X</d></b><b c="2"><d>X</d></b></a>','a/b/d[../@c="1"]') AS result
SELECT @id = ExtractValue(LOAD_FILE('users.xml'),'//user[login/text()="" or 1=1 and password/text()="" or 1=1]/attribute::id' )
##case4::Bit Functions and Operators
#!diff_conn
SELECT BIT_COUNT(29), BIT_COUNT(b'101010')
SELECT 29 & 15
SELECT 5 & ~1
SELECT 29 | 15
SELECT 1 ^ 0
SELECT 1 << 2
SELECT 4 >> 2
##case5::Encryption and Compression Functions
#SET block_encryption_mode = 'aes-256-cbc'
#SET @key_str = SHA2('My secret passphrase',512)
#SET @init_vector = RANDOM_BYTES(16)
#SET @crypt_str = AES_ENCRYPT('text'@key_str@init_vector)
SELECT AES_DECRYPT('text',UNHEX('F3229A0B371ED2D9441B830D21A390C3'))
SELECT LENGTH(COMPRESS(REPEAT('a',1000)))
select decode(ENCODE('cleartext', CONCAT('my_random_salt','my_secret_password')), 'abc')
SELECT ENCRYPT('hello')/*allow_diff*/
SELECT ENCRYPT('hello','abc')
SELECT MD5('testing')
SELECT PASSWORD('mypass')
#SELECT PASSWORD('mypass'), OLD_PASSWORD('mypass')
SELECT SHA('abc')
SELECT SHA1('abc')
SELECT SHA2('abc', 224)
SELECT UNCOMPRESS(COMPRESS('any string'))
SELECT UNCOMPRESSED_LENGTH(COMPRESS(REPEAT('a',30)))
##case6::Information Functions
#SELECT BENCHMARK(1000000ENCODE('hello','goodbye'))
SELECT CHARSET('abc')
#SELECT COERCIBILITY('abc' COLLATE utf8_general_ci)
SELECT COLLATION('abc')
SELECT CONNECTION_ID()
SELECT CURRENT_USER()
SELECT CURRENT_USER
SELECT DATABASE()
select schema()
SELECT SESSION_USER()
SELECT USER()
SELECT LAST_INSERT_ID()
SELECT VERSION()
##case7::Spatial Analysis Functions
#SELECT ST_X(Point(15, 20))
#SELECT ST_X(ST_GeomFromText('POINT(15, 20)'))
#SET @poly = 'Polygon((0 00 33 00 0)(1 11 22 11 1))' ;
#SELECT AREA(ST_GeomFromText(@poly));
#SELECT ST_Area(ST_GeomFromText(@poly)) ;
#SET @mpoly ='MultiPolygon(((0 00 33 33 00 0)(1 11 22 22 11 1)))' ;
#SELECT ST_Area(ST_GeomFromText(@mpoly)) ;
#SET @poly =ST_GeomFromText('POLYGON((0 010 010 100 100 0)(5 57 57 75 75 5))') ;
#SELECT ST_GeometryType(@poly)ST_AsText(ST_Centroid(@poly)) ;
#SELECT ST_GeometryType(@poly)ST_AsText(Centroid(@poly));
#drop table if exists normal_table1
#CREATE TABLE normal_table1 (g GEOMETRY NOT NULL)
#INSERT INTO normal_table1 (g) VALUES(Point(1,2))
#SELECT ST_AsBinary(g) FROM normal_table1
#SELECT ST_AsWKB(g) FROM normal_table1
#SELECT AsBinary(g) FROM normal_table1
#SELECT AsWKB(g) FROM normal_table1
#SET @g = 'LineString(1 12 23 3)' ;
#SELECT ST_AsText(ST_GeomFromText(@g)) ;
#SET @mp = 'MULTIPOINT(1 1 2 2 3 3)' ;
#SELECT AsText(ST_GeomFromText(@mp));
#SELECT AsWKT(ST_GeomFromText(@mp));
#SET @pt = ST_GeomFromText('POINT(0 0)') ;
#SELECT ST_AsText(ST_Buffer(@pt 0)) ;
#SELECT ST_AsText(Buffer(@pt 0));
#SET @ls = ST_GeomFromText('LINESTRING(0 00 55 5)') ;
#SET @end_strategy = ST_Buffer_Strategy('end_flat') ;
#SET @join_strategy = ST_Buffer_Strategy('join_round' 10) ;
#SELECT ST_AsText(ST_Buffer(@ls 5 @end_strategy @join_strategy))
#SELECT ST_AsText(Buffer(@ls 5 @end_strategy @join_strategy))
#SET @g1 = ST_GeomFromText('Polygon((0 00 33 33 00 0))') ;
#SET @g2 = ST_GeomFromText('Point(1 1)') ;
#SELECT MBRContains(@g1@g2) MBRWithin(@g2@g1) ;
#SET @g = 'MULTIPOINT(5 025 015 1015 25)' ;
#SELECT ST_AsText(ST_ConvexHull(ST_GeomFromText(@g))) ;
#SELECT ST_AsText(ConvexHull(ST_GeomFromText(@g)));
#SET @g1 = ST_GeomFromText('LINESTRING(0 00 55 5)') ;
#SET @g2 = ST_GeomFromText('Point(1 1)') ;
#SELECT ST_Crosses(@g1 @g2) ;
#SELECT Crosses(@g1 @g2);
#SELECT ST_Contains(@g1@g2) ;
##
#SELECT ST_Dimension(ST_GeomFromText('LineString(1 1,2 2)'))
#SELECT Dimension(ST_GeomFromText('LineString(1 1,2 2)'));
#SELECT ST_AsText(ST_Envelope(ST_GeomFromText('LineString(1 1,2 2)')))
#SELECT ST_AsText(ST_Envelope(ST_GeomFromText('LineString(1 1,1 2)')))
#SELECT ST_GeometryType(ST_GeomFromText('POINT(1 ,1)'))
#SELECT ST_SRID(ST_GeomFromText('LineString(1 1,2 2)',101))
#SELECT ST_X(Point(56.7, 53.34))
#SELECT X(Point(56.7, 53.34))
#SELECT ST_Y(Point(56.7, 53.34))
#SELECT Y(Point(56.7, 53.34))
#Spatial Relation Functions That Use Object Shapes
#SELECT Crosses(point(1,1), point(2,2))
#SELECT ST_Crosses(point(1,1), point(2,2))
#SELECT ST_Distance(point(1,1), point(2,2))
#SELECT Distance(point(1,1), point(2,2))
#SELECT ST_Equals(point(1,1), point(2,2)),ST_Equals(point(1,1),point(1,1))
#SELECT ST_Intersects(point(1,1), point(2,2))
#SELECT ST_Overlaps(point(1,1), point(2,2))
#SELECT ST_Touches(point(1,1), point(2,2))
#SELECT Touches(point(1,1), point(2,2))
#SELECT ST_Within(point(1,1), point(2,2))
#SELECT Within(point(1,1), point(2,2))
#MySQL-Specific Spatial Relation Functions That Use Minimum Bounding Rectangles (MBRs)
#SELECT MBRContains(ST_GeomFromText('Polygon((0 0,0 3,3 3,3 0,0 0))'),ST_GeomFromText('Point(1 1)'))
#SELECT MBRWithin(ST_GeomFromText(ST_GeomFromText('Point(1 1)'),'Polygon((0 0,0 3,3 3,3 0,0 0))'))
#SELECT MBRCovers(ST_GeomFromText('Polygon((0 0,0 3,3 3,3 0,0 0))'),ST_GeomFromText('Point(1 1)'))
#SELECT MBRCoveredby(ST_GeomFromText('Polygon((0 0,0 3,3 3,3 0,0 0))'),ST_GeomFromText('Point(1 1)'))
#Spatial Geohash Functions
#SELECT ST_GeoHash(180,0,10), ST_GeoHash(-180,-90,15)
#SELECT ST_LatFromGeoHash(ST_GeoHash(45,-20,10))
#SELECT ST_LongFromGeoHash(ST_GeoHash(45,-20,10))
#SELECT ST_AsText(ST_PointFromGeoHash(ST_GeoHash(45,-20,10),0))
#Spatial GeoJSON Functions
#SELECT ST_AsGeoJSON(ST_GeomFromText('POINT(11.11111 12.22222)'),2)
#SELECT ST_AsText(ST_GeomFromGeoJSON('{ "type": "Point", "coordinates": [102.0, 0.0]}'))
#Spatial Convenience Functions
#SELECT ST_Distance_Sphere(ST_GeomFromText('POINT(0,0)'), ST_GeomFromText('POINT(180,0)'))
#SELECT ST_IsValid(ST_GeomFromText('POINT(0 ,0)'))
#SELECT ST_AsText(ST_MakeEnvelope(ST_GeomFromText('POINT(0 0)'), ST_GeomFromText('POINT(1 1)')))
#SELECT ST_AsText(ST_Simplify(ST_GeomFromText('LINESTRING(0 0,0 1,1 1,1 2,2 2,2 3,3 3)'), 0.5))
#SELECT ST_AsText(ST_Validate(ST_GeomFromText('POINT(0, 0)')))
#SET @g1 = ST_GeomFromText('Polygon((0 00 33 33 00 0))') ;
#SET @g2 = ST_GeomFromText('LINESTRING(0 00 55 5)') ;
#SELECT MBRDisjoint(@g1@g2) ;
#SELECT Disjoint(@g1@g2);
#SELECT Equals(@g1 @g2);
#SELECT MBREquals(@g1@g2) ;
#SELECT MBRIntersects(@g1@g2) ;
#SELECT ST_Disjoint(@g1@g2) ;
#SET @g1 = POINT(11) @g2 = POINT(22) ;
#SELECT ST_Distance(@g1 @g2) ;
#SELECT Distance(@g1 @g2);
#SET @ls = 'LineString(1 12 23 3)' ;
#SELECT ST_AsText(ST_EndPoint(ST_GeomFromText(@ls))) ;
#SELECT ST_AsText(EndPoint(ST_GeomFromText(@ls)));
##
#SELECT ST_AsText(ST_Envelope(ST_GeomFromText('LineString(1 1,2 2)'))) ;
#SELECT ST_AsText(Envelope(ST_GeomFromText('LineString(1 1,2 2)')));
#SET @poly ='Polygon((0 00 33 33 00 0)(1 11 22 22 11 1))' ;
#SELECT ST_AsText(ST_ExteriorRing(ST_GeomFromText(@poly))) ;
#SELECT ST_AsText(ExteriorRing(ST_GeomFromText(@poly)));
#SET @g = 'MultiLineString((1 12 23 3)(1 02 03 0)(0 10 20 3))' ;
#SET @g1 = ST_GeomFromText('Polygon((0 00 33 33 00 0))') ;
#SET @g2 = ST_GeomFromText('Point(1 1)') ;
#SELECT MBRCovers(@g1@g2) MBRCoveredby(@g1@g2) ;
#SELECT MBROverlaps(@g1@g2) ;
#SELECT MBRTouches(@g1@g2) ;
#SELECT MBRWithin(@g1@g2) MBRWithin(@g2@g1) ;
#select ST_Overlaps(@g1 @g2) ;
##
#SELECT ST_AsGeoJSON(ST_GeomFromText('POINT(11.11111, 12.22222)')2) ;
#SELECT ST_GeoHash(180,0,10) ST_GeoHash(-180,-90,15) ;
#SET @g1 = POINT(11) @g2 = POINT(22) ;
#SELECT ST_AsText(ST_Difference(@g1 @g2)) ;
#SET @pt1 = ST_GeomFromText('POINT(0 0)') ;
#SET @pt2 = ST_GeomFromText('POINT(180 0)') ;
#SELECT ST_Distance_Sphere(@pt1 @pt2) ;
#SELECT ST_Equals(@g1 @g1) ST_Equals(@g1 @g2) ;
#SET @g = "MULTILINESTRING((10 10 11 11) (9 9 10 10))" ;
#SELECT ST_AsText(ST_GeomCollFromText(@g)) ;
#SELECT ST_AsText(ST_GeomCollFromTxt(@g)) ;
#SELECT ST_AsText(ST_GeometryCollectionFromText(@g)) ;
#SET @gc = 'GeometryCollection(Point(1 1)LineString(2 2 3 3))' ;
#SELECT ST_AsText(ST_GeometryN(ST_GeomFromText(@gc)1)) ;
##
#SELECT ST_GeometryType(ST_GeomFromText('POINT(1, 1)')) ;
#SET @json = '{ "type": "Point" "coordinates": [102.0 0.0]}' ;
#SELECT ST_AsText(ST_GeomFromGeoJSON(@json)) ;
#SET @pt = ST_GeometryFromText('POINT(0 0)') ;
#SET @pt = GeomFromText('POINT(0 0)');
#SET @pt = GeometryFromText('POINT(0 0)');
#SET @pt = GeometryFromWKB('POINT(0 0)');
#SET @pt = GeomFromWKB('POINT(0 0)');
##
#select ST_GeomCollFromWKB(st_aswkb(point(1,2)));
#select ST_GeomFromWKB(ST_AsWKB(point(1,2))) ;
#select ST_GeometryFromWKB(ST_AsWKB(point(1,2))) ;
#SET @poly ='Polygon((0 00 33 33 00 0)(1 11 22 22 11 1))' ;
#SELECT ST_AsText(ST_InteriorRingN(ST_GeomFromText(@poly)1)) ;
#SET @g1 = ST_GeomFromText('LineString(1 1 3 3)') ;
#SET @g2 = ST_GeomFromText('LineString(1 3 3 1)') ;
#SELECT ST_AsText(ST_Intersection(@g1 @g2)) ;
#SET @ls1 = 'LineString(1 12 23 32 2)' ;
#SET @ls2 = 'LineString(1 12 23 31 1)' ;
#SELECT ST_IsClosed(ST_GeomFromText(@ls1)) ;
##case8::JSON Function
#SELECT JSON_APPEND('["a", ["b", "c"], "d"]', '$[1]', 1)
SELECT JSON_ARRAY_APPEND('["a", ["b", "c"], "d"]', '$[1]', 1)
SELECT JSON_ARRAY(1, "abc", NULL, TRUE, CURTIME())/*allow_10%_diff*/
SELECT JSON_ARRAY_INSERT('["a", ["b", "c"], "d"]', '$[100]', 'x')
SELECT JSON_INSERT('{ "a": 1, "b": [2, 3]}', '$.a', 10, '$.c', '[true, false]')
SELECT JSON_MERGE('[1 ,2]', '[true ,false]')
SELECT JSON_MERGE('{"name": "x"}', '{"id": 47}')
SELECT JSON_MERGE('1' ,'true')
SELECT JSON_REMOVE('["a", ["b", "c"], "d"]', '$[1]')
SELECT JSON_REPLACE('{ "a": 1, "b": [2, 3]}', '$.a', 10, '$.c', '[true, false]')
SELECT JSON_SET('{ "a": 1, "b": [2, 3]}', '$.a', 10, '$.c', '[true, false]')
SELECT JSON_UNQUOTE('"abc"')
SELECT JSON_UNQUOTE('"\\t\\u0032"')
SELECT JSON_DEPTH('{}'), JSON_DEPTH('[]'), JSON_DEPTH('true')
SELECT JSON_DEPTH('[10, 20]'), JSON_DEPTH('[[] ,{}]')
SELECT JSON_DEPTH('[10, {"a": 20}]')
SELECT JSON_EXTRACT('[10 ,20, [30, 40]]', '$[1]')
#SELECT JSON_TYPE(JSON_EXTRACT'{"a": [10, true]}', '$.a'))
SELECT JSON_VALID('hello'), JSON_VALID('"hello"')
SELECT JSON_EXTRACT('[10, 20, [30, 40]]', '$[1]', '$[0]')
SELECT JSON_EXTRACT('[10, 20, [30, 40]]', '$[2][*]')
SELECT JSON_OBJECT('id', 87, 'name', 'carrot')
SELECT JSON_QUOTE('null'), JSON_QUOTE('"null"')
SELECT JSON_QUOTE('[1, 2, 3]')
SELECT JSON_KEYS('{"a": 1, "b": {"c": 30}}')
SELECT JSON_KEYS('{"a": 1, "b": {"c": 30}}', '$.b')
SELECT JSON_LENGTH('[1, 2, {"a": 3}]')
SELECT JSON_LENGTH('{"a": 1, "b": {"c": 30}}')
SELECT JSON_LENGTH('{"a": 1, "b": {"c": 30}}', '$.b')
SELECT JSON_MERGE('[1, 2]', '[true, false]')
SELECT JSON_MERGE('{"name": "x"}', '{"id": 47}')
SELECT JSON_MERGE('1', 'true')
SELECT JSON_OBJECT('id', 87, 'name', 'carrot')
SELECT JSON_QUOTE('null'), JSON_QUOTE('"null"')
SELECT JSON_VALID('hello'), JSON_VALID('"hello"')
#
#clear tables
#
drop table if exists aly_test
drop table if exists global_table1
drop table if exists normal_table1