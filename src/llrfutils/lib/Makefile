# shared lib name
NAME := sis8300_llrf_utils

# output destinations
TARGETSO := lib$(NAME).so
TARGETA := lib$(NAME).a
OBJDIR := obj

# additional flags, besides linking to sis8300drv
CCFLAGS := -std=c99 -fPIC -Wall -g -I$(TOP)/include
LDFLAGS := -Wall -lsis8300drv													

# files
OBJS := sis8300_llrf_utils 
#OBJS := sis8300_select_rtm_clk01

# includes
INCLUDES := $(TOP)/include
	
###############################################################################

all: $(TARGETSO) $(TARGETA)

clean:
	rm -rf *~ $(TARGETA) $(TARGETSO) $(OBJDIR)

$(TARGETSO): $(OBJS:%=$(OBJDIR)/%.o) 
	gcc -shared $(LDFLAGS) $(LIBS:%=-l%) -o  $@ $^

$(OBJDIR)/%.o: %.c
	mkdir -p $(OBJDIR)
	gcc -c $(CCFLAGS) $(INCLUDES:%=-I%) -o $@ $<

$(TARGETA): $(OBJS:%=$(OBJDIR)/%.o) 
	/usr/bin/ar -rcs		$@		$^ 


