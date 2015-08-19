export TOP := $(shell pwd)

SUBDIRS :=	executables
%:
	@for ii in $(SUBDIRS); do \
		$(MAKE) $@ -C $$ii; \
	done


PROJECT = sis8300llrfcustomlogic

include ${EPICS_ENV_PATH}/module.Makefile

EXCLUDE_ARCHS += eldk

EXECUTABLES = $(wildcard custom_logic/*)
EXECUTABLES = $(wildcard examples/*)
EXECUTABLES = $(wildcard matlab_scripts/*)
EXECUTABLES = $(wildcard scripts/*)

