PRG = libdocklet-tea.so
CC = gcc
VALAC = valac
PKGCONFIG = $(shell which pkg-config)
PACKAGES = gtk+-3.0 plank libnotify
CFLAGS = `$(PKGCONFIG) --cflags $(PACKAGES)`
LIBS = `$(PKGCONFIG) --libs $(PACKAGES)`
VALAFLAGS = $(patsubst %, --pkg %, $(PACKAGES)) -X -fPIC -X -shared --library=$(PRG)

SOURCES = src/TeaDocklet.vala\
		src/TeaDockItem.vala\
		src/TeaPreferences.vala\
		src/Timer.vala

UIFILES =

#Disable implicit rules by empty target .SUFFIXES
.SUFFIXES:

.PHONY: all clean distclean

all: $(PRG)
$(PRG): $(SOURCES) $(UIFILES)
	glib-compile-resources capture.gresource.xml --target=resources.c --generate-source
	$(VALAC) -o $(PRG) $(SOURCES) resources.c $(VALAFLAGS)

install:
	cp $(PRG) /usr/lib/x86_64-linux-gnu/plank/docklets/
	# killall plank



clean:
	# rm -f $(OBJS)
	rm -f $(PRG)

distclean: clean
	rm -f *.vala.c

