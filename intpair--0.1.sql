
CREATE FUNCTION int64pair_in(cstring)
RETURNS int64pair
AS 'MODULE_PATHNAME', 'int64pair_in'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION int64pair_out(int64pair)
RETURNS cstring
AS 'MODULE_PATHNAME', 'int64pair_out'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION int64pair(BIGINT, BIGINT)
RETURNS int64pair
AS 'MODULE_PATHNAME', 'int64pair_make'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION int64pair_lt(int64pair, int64pair)
RETURNS BOOLEAN
AS 'MODULE_PATHNAME', 'int64pair_lt'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION int64pair_lte(int64pair, int64pair)
RETURNS BOOLEAN
AS 'MODULE_PATHNAME', 'int64pair_lte'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION int64pair_eq(int64pair, int64pair)
RETURNS BOOLEAN
AS 'MODULE_PATHNAME', 'int64pair_eq'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION int64pair_neq(int64pair, int64pair)
RETURNS BOOLEAN
AS 'MODULE_PATHNAME', 'int64pair_neq'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION int64pair_gt(int64pair, int64pair)
RETURNS BOOLEAN
AS 'MODULE_PATHNAME', 'int64pair_gt'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION int64pair_gte(int64pair, int64pair)
RETURNS BOOLEAN
AS 'MODULE_PATHNAME', 'int64pair_gte'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION int64pair_cmp(int64pair, int64pair)
RETURNS INTEGER
AS 'MODULE_PATHNAME', 'int64pair_cmp'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION int64pair_hash(int64pair)
RETURNS INTEGER
AS 'MODULE_PATHNAME', 'int64pair_hash'
LANGUAGE C STRICT IMMUTABLE;

CREATE TYPE int64pair (
    INPUT = int64pair_in,
    OUTPUT = int64pair_out,
    INTERNALLENGTH = 16,
    ELEMENT = int8,
    STORAGE = plain,
    DELIMITER = ','
);

CREATE OPERATOR < (
    PROCEDURE = int64pair_lt,
    LEFTARG = int64pair, 
    RIGHTARG = int64pair,
    COMMUTATOR = >,
    NEGATOR = >=,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel);

CREATE OPERATOR <= (
    PROCEDURE = int64pair_lte,
    LEFTARG = int64pair, 
    RIGHTARG = int64pair,
    COMMUTATOR = >=,
    NEGATOR = >,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel);

CREATE OPERATOR = (
    PROCEDURE = int64pair_eq,
    LEFTARG = int64pair, 
    RIGHTARG = int64pair,
    COMMUTATOR = =,
    NEGATOR = <>,
    RESTRICT = eqsel,
    JOIN = eqjoinsel,
    HASHES, MERGES);

CREATE OPERATOR <> (
    PROCEDURE = int64pair_neq,
    LEFTARG = int64pair, 
    RIGHTARG = int64pair,
    COMMUTATOR = <>,
    NEGATOR = =,
    RESTRICT = neqsel,
    JOIN = neqjoinsel);

CREATE OPERATOR >= (
    PROCEDURE = int64pair_gte, 
    LEFTARG = int64pair, 
    RIGHTARG = int64pair,
    COMMUTATOR = <=,
    NEGATOR = <,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel);

CREATE OPERATOR > (
    PROCEDURE = int64pair_gt, 
    LEFTARG = int64pair, 
    RIGHTARG = int64pair,
    COMMUTATOR = <,
    NEGATOR = <=,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel);

CREATE OPERATOR CLASS btree_int64pair_ops
    DEFAULT FOR TYPE int64pair USING btree AS
        OPERATOR    1   <,
        OPERATOR    2   <=,
        OPERATOR    3   =,
        OPERATOR    4   >=,
        OPERATOR    5   >,
        FUNCTION    1   int64pair_cmp (int64pair, int64pair);

CREATE OPERATOR CLASS hash_int64pair_ops
    DEFAULT FOR TYPE int64pair USING hash AS
        OPERATOR    1   =,
        FUNCTION    1   int64pair_hash (int64pair);
