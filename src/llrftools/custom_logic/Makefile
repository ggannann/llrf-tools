
OBJDIR:=build
# compiler and linker flags
CCFLAGS := -std=gnu99 -Wall -I$(TOP)/include
#CCFLAGS := -std=c99 -Wall -I$(TOP)/include

EXT_LIB1=/opt/epics/modules/llrfutils/eit_ess/3.14.12.5/lib/centos7-x86_64/
EXT_LIB2=/opt/epics/modules/sis8300drv/1.5.1/3.14.12.5/lib/centos7-x86_64/
EXT_INC1=/opt/epics/modules/llrfutils/eit_ess/3.14.12.5/include/
EXT_INC2=/opt/epics/modules/sis8300drv/1.5.1/3.14.12.5/include/

LDFLAGS := -L$(EXT_LIB1) -L$(EXT_LIB2) -I$(EXT_INC1) -I$(EXT_INC2) -l sis8300drv -l llrfutils -lm -lrt -pthread

# files

#OBJS = $(addprefix $(OBJDIR)/, $(patsubst %.c, %, $(wildcard *.c)))
OBJS = $(patsubst %.c, %, $(wildcard *.c))


###############################################################################

all: $(OBJDIR) $(OBJS)

clean:
	rm -rf $(OBJDIR)

$(OBJDIR):
	mkdir $(OBJDIR)

$(OBJS): % : %.c
	gcc $(CCFLAGS) $(LDFLAGS) $< -o $(OBJDIR)/$@
