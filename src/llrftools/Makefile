
#SUBDIRS :=	examples\
#		custom_logic
#%:
#	@for ii in $(SUBDIRS); do \
#		$(MAKE) $@ -C $$ii; \
#	done

include ${EPICS_ENV_PATH}/module.Makefile

EXCLUDE_ARCHS += eldk
SOURCES = -none-
EXECUTABLES = $(wildcard examples/build/*)
EXECUTABLES += $(wildcard custom_logic/build/*)
EXECUTABLES += $(wildcard matlabscripts/*)
EXECUTABLES += $(wildcard scripts/*)



