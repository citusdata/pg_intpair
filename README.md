# pg_intpair

This PostgreSQL extensions provides a single datatype named `int64pair`. It is simply a pair of 64-bit integers packed.
In the absence of this extension, one could use PostgreSQL's [composite types](https://www.postgresql.org/docs/10/static/rowtypes.html) or
[arrays](https://www.postgresql.org/docs/10/static/arrays.html) for the same purpose. The advantages of using `int64pair`
are more performance and better storage density.

## Usage
* To create an instance, you can use the `int64pair(a, b)` function. For example, `int64pair(-1, 1)` will create a pair
  with first component equal to `-1` and second component equal to `1`.
* To access the first component you can use `p[0]`, and to access the second component you can use `p[1]`.
* You can create b-tree or hash indexes on `int64pair` columns.

## Migrating from a matching composite type
Suppose you already have a composite type with the following definition:

```sql
CREATE TYPE my_composite_type AS (first BIGINT, second BIGINT);
```

You can use the following ```ALTER TABLE``` command to convert a column with the composite type to ```int64pair```:

```sql
ALTER TABLE t ALTER COLUMN col TYPE int64pair USING a::text::int64pair;
```

You can enable implicit casting by defining following casts:

```sql
CREATE CAST (my_composite_type AS int64pair) WITH INOUT AS IMPLICIT;
CREATE CAST (int64pair AS my_composite_type) WITH INOUT AS IMPLICIT;
```

Then, you can do the previous ```ALTER TABLE``` column without the ```USING``` clause:

```sql
ALTER TABLE t ALTER COLUMN col TYPE int64pair;
```

To be able to use the same ```(col).first``` and ```(col).second``` syntax for ```int64pair``` columns, you can create
couple of simple functions:

```sql
CREATE FUNCTION first(p int64pair) RETURNS BIGINT
    AS 'select p[0];'
    LANGUAGE SQL IMMUTABLE
    RETURNS NULL ON NULL INPUT;

CREATE FUNCTION second(p int64pair) RETURNS BIGINT
    AS 'select p[1];'
    LANGUAGE SQL IMMUTABLE
    RETURNS NULL ON NULL INPUT;
```
