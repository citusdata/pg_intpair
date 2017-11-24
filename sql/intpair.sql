
CREATE EXTENSION intpair;

-- input and output
SELECT '1,2'::int64pair;
SELECT '(1:2)'::int64pair;
SELECT '(,2)'::int64pair;
SELECT '(1,)'::int64pair;
SELECT '(1,2;'::int64pair;
SELECT '(1,2'::int64pair;
SELECT '(a,2)'::int64pair;
SELECT '(-2,b)'::int64pair;
SELECT ''::int64pair;
SELECT '(1,2)a'::int64pair;
SELECT '(1,2)'::int64pair;
SELECT '(-1,-2)'::int64pair;
SELECT '(1, 12393939)'::int64pair;
SELECT '(-9223372036854775808, 9223372036854775807)'::int64pair;

-- accessors
CREATE FUNCTION first(p int64pair) RETURNS BIGINT
    AS 'select p[0];'
    LANGUAGE SQL IMMUTABLE
    RETURNS NULL ON NULL INPUT;

CREATE FUNCTION second(p int64pair) RETURNS BIGINT
    AS 'select p[1];'
    LANGUAGE SQL IMMUTABLE
    RETURNS NULL ON NULL INPUT;

SELECT ('(1,2)'::int64pair).first, ('(1,2)'::int64pair).second;

-- operators
CREATE TABLE t1(a int64pair);
INSERT INTO t1 VALUES ('(1,2)'), ('(1,3)'), ('(2,1)'), ('(2,4)');
SELECT t1a.a, t1b.a, t1a.a < t1b.a AS lt, t1a.a <= t1b.a AS lte,
       t1a.a = t1b.a AS eq, t1a.a <> t1b.a AS neq,
	   t1a.a >= t1b.a AS gte, t1a.a > t1b.a AS gt
FROM t1 t1a, t1 t1b
ORDER BY t1a.a, t1b.a;

-- indexes
CREATE TABLE t2(a int64pair);
INSERT INTO t2 SELECT int64pair(a, a+1) FROM generate_series(1,1000) a;
CREATE INDEX ON t2(a);
ANALYZE t2;
EXPLAIN (COSTS OFF) SELECT count(*) FROM t2 WHERE a='(50,51)';
SELECT count(*) FROM t2 WHERE a='(50,51)';
EXPLAIN (COSTS OFF) SELECT count(*) FROM t2 WHERE a='(431,50)';
SELECT count(*) FROM t2 WHERE a='(431,50)';
EXPLAIN (COSTS OFF) SELECT count(*) FROM t2 WHERE a='(611,612)';
SELECT count(*) FROM t2 WHERE a='(611,612)';
EXPLAIN (COSTS OFF) SELECT count(*) FROM t2 WHERE a='(931,932)';
SELECT count(*) FROM t2 WHERE a='(931,932)';
EXPLAIN (COSTS OFF) SELECT count(*) FROM t2 WHERE a='(931,931)';
SELECT count(*) FROM t2 WHERE a='(931,931)';

-- conversion to and from matching composite type
CREATE TYPE composite_int64pair AS (first BIGINT, second BIGINT);
CREATE TABLE t3(a composite_int64pair);
INSERT INTO t3 VALUES ((1,2)), ((-1,0)), ((4, 3));
ALTER TABLE t3 ALTER COLUMN a TYPE int64pair USING a::text::int64pair;
SELECT * FROM t3 ORDER BY a;
ALTER TABLE t3 ALTER COLUMN a TYPE composite_int64pair USING a::text::composite_int64pair;
SELECT * FROM t3 ORDER BY a;

-- implicit cast from matching composite type
CREATE CAST (composite_int64pair AS int64pair) WITH INOUT AS IMPLICIT;
CREATE CAST (int64pair AS composite_int64pair) WITH INOUT AS IMPLICIT;
ALTER TABLE t3 ALTER COLUMN a TYPE int64pair;
SELECT * FROM t3 ORDER BY a;
ALTER TABLE t3 ALTER COLUMN a TYPE composite_int64pair;
SELECT * FROM t3 ORDER BY a;
