TARGETS_COMMON_DIR = $(OPENAIR_TARGETS)/COMMON

TARGETS_COMMON_OBJS = $(TARGETS_COMMON_DIR)/create_tasks.o

TARGETS_COMMON_incl = \
		      -I$(TARGETS_COMMON_DIR)