
CREATE FUNCTION int64pair_send(int64pair)
RETURNS bytea
AS 'MODULE_PATHNAME', 'int64pair_send'
LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION int64pair_recv(internal)
RETURNS int64pair
AS 'MODULE_PATHNAME', 'int64pair_recv'
LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;

UPDATE pg_type SET typsend='int64pair_send', typreceive='int64pair_recv' WHERE typname='int64pair';
