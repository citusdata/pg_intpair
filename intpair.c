/*-------------------------------------------------------------------------
 *
 * intpair.c
 *
 * Function definitions for the intpair extension.
 *
 * Copyright (c) 2017, Citus Data, Inc.
 *
 *-------------------------------------------------------------------------
 */

#include "postgres.h"

#include "access/hash.h"
#include "fmgr.h"
#include "funcapi.h"
#include "libpq/pqformat.h"

/* declarations for dynamic loading */
PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(int64pair_in);
PG_FUNCTION_INFO_V1(int64pair_out);
PG_FUNCTION_INFO_V1(int64pair_make);
PG_FUNCTION_INFO_V1(int64pair_lt);
PG_FUNCTION_INFO_V1(int64pair_lte);
PG_FUNCTION_INFO_V1(int64pair_neq);
PG_FUNCTION_INFO_V1(int64pair_eq);
PG_FUNCTION_INFO_V1(int64pair_gt);
PG_FUNCTION_INFO_V1(int64pair_gte);
PG_FUNCTION_INFO_V1(int64pair_cmp);
PG_FUNCTION_INFO_V1(int64pair_hash);
PG_FUNCTION_INFO_V1(int64pair_send);
PG_FUNCTION_INFO_V1(int64pair_recv);

typedef struct
{
	int64 first;
	int64 second;
} Int64Pair;


#define DatumGetInt64Pair(X)	 ((Int64Pair *) DatumGetPointer(X))
#define Int64PairGetDatum(X)	 PointerGetDatum(X)
#define PG_GETARG_INT64PAIR(n)	 DatumGetInt64Pair(PG_GETARG_DATUM(n))
#define PG_RETURN_INT64PAIR(x)	 return Int64PairGetDatum(x)

Datum
int64pair_in(PG_FUNCTION_ARGS)
{
	char *str = PG_GETARG_CSTRING(0);
	Int64Pair *result = palloc0(sizeof(Int64Pair));
	char *endptr = NULL;
	char *cur = str;
	if (cur[0] != '(')
		elog(ERROR, "expected '(' at position 0");
	cur++;
	result->first = strtoll(cur, &endptr, 10);
	if (cur == endptr)
		elog(ERROR, "expected number at position 1");
	if (endptr[0] != ',')
		elog(ERROR, "expected ',' at position " INT64_FORMAT, endptr - str);
	cur = endptr + 1;
	result->second = strtoll(cur, &endptr, 10);
	if (cur == endptr)
		elog(ERROR, "expected number at position " INT64_FORMAT, endptr - str);
	if (endptr[0] != ')')
		elog(ERROR, "expected ')' at position " INT64_FORMAT, endptr - str);
	if (endptr[1] != '\0')
		elog(ERROR, "unexpected character at position " INT64_FORMAT, 1 + (endptr - str));

	PG_RETURN_INT64PAIR(result);
}

Datum
int64pair_out(PG_FUNCTION_ARGS)
{
	Int64Pair *p = PG_GETARG_INT64PAIR(0);
	StringInfo result = makeStringInfo();
	appendStringInfo(result, "(" INT64_FORMAT "," INT64_FORMAT ")",
					 p->first, p->second);
	PG_RETURN_CSTRING(result->data);
}

Datum
int64pair_make(PG_FUNCTION_ARGS)
{
	Int64Pair *result = palloc0(sizeof(Int64Pair));
	result->first = PG_GETARG_INT64(0);
	result->second = PG_GETARG_INT64(1);
	PG_RETURN_INT64PAIR(result);
}

Datum
int64pair_lt(PG_FUNCTION_ARGS)
{
	Int64Pair *a = PG_GETARG_INT64PAIR(0);
	Int64Pair *b = PG_GETARG_INT64PAIR(1);

	PG_RETURN_BOOL((a->first < b->first) || 
				   (a->first == b->first && a->second < b->second));
}

Datum
int64pair_lte(PG_FUNCTION_ARGS)
{
	Int64Pair *a = PG_GETARG_INT64PAIR(0);
	Int64Pair *b = PG_GETARG_INT64PAIR(1);

	PG_RETURN_BOOL((a->first < b->first) || 
				   (a->first == b->first && a->second <= b->second));
}

Datum
int64pair_eq(PG_FUNCTION_ARGS)
{
	Int64Pair *a = PG_GETARG_INT64PAIR(0);
	Int64Pair *b = PG_GETARG_INT64PAIR(1);

	PG_RETURN_BOOL(a->first == b->first && a->second == b->second);
}

Datum
int64pair_neq(PG_FUNCTION_ARGS)
{
	Int64Pair *a = PG_GETARG_INT64PAIR(0);
	Int64Pair *b = PG_GETARG_INT64PAIR(1);

	PG_RETURN_BOOL(a->first != b->first || a->second != b->second);
}

Datum
int64pair_gt(PG_FUNCTION_ARGS)
{
	Int64Pair *a = PG_GETARG_INT64PAIR(0);
	Int64Pair *b = PG_GETARG_INT64PAIR(1);

	PG_RETURN_BOOL((a->first > b->first) || 
				   (a->first == b->first && a->second > b->second));
}

Datum
int64pair_gte(PG_FUNCTION_ARGS)
{
	Int64Pair *a = PG_GETARG_INT64PAIR(0);
	Int64Pair *b = PG_GETARG_INT64PAIR(1);

	PG_RETURN_BOOL((a->first > b->first) || 
				   (a->first == b->first && a->second >= b->second));
}

Datum
int64pair_cmp(PG_FUNCTION_ARGS)
{
	Int64Pair *a = PG_GETARG_INT64PAIR(0);
	Int64Pair *b = PG_GETARG_INT64PAIR(1);

	PG_RETURN_INT32(a->first < b->first ? -1 :
					a->first > b->first ? 1 :
					a->second < b->second ? -1 :
					a->second > b->second ? 1 :
					0);
}

Datum
int64pair_hash(PG_FUNCTION_ARGS)
{
	Int64Pair *a = PG_GETARG_INT64PAIR(0);

	PG_RETURN_DATUM(hash_any((unsigned char *) a, sizeof(Int64Pair)));
}

Datum
int64pair_send(PG_FUNCTION_ARGS)
{
	Int64Pair *a = PG_GETARG_INT64PAIR(0);
	StringInfoData buf;

	pq_begintypsend(&buf);

	pq_sendint64(&buf, a->first);
	pq_sendint64(&buf, a->second);

	PG_RETURN_BYTEA_P(pq_endtypsend(&buf));
}

Datum
int64pair_recv(PG_FUNCTION_ARGS)
{
	StringInfo	buf = (StringInfo) PG_GETARG_POINTER(0);
	
	Int64Pair *result = palloc0(sizeof(Int64Pair));
	result->first = pq_getmsgint64(buf);
	result->second = pq_getmsgint64(buf);

	PG_RETURN_INT64PAIR(result);
}
