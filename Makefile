# contrib/intpair/Makefile

MODULE_big = intpair
OBJS = intpair.o

EXTENSION = intpair
DATA = intpair--0.1.sql

REGRESS = intpair

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
