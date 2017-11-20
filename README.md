# pg_intpair

This PostgreSQL extensions provides a single datatype named `int64pair`. It is simply a pair of 64-bit integers packed.
In the absence of this extension, one could use PostgreSQL's [composite types](https://www.postgresql.org/docs/10/static/rowtypes.html),
[arrays](https://www.postgresql.org/docs/10/static/arrays.html) for the same purpose. The advantages of using `int64pair`
are more performance and better storage density.


