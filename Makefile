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
		src/TimerWindow.vala\
		src/Timer.vala

UIFILES =

#Disable implicit rules by empty target .SUFFIXES
.SUFFIXES:

.PHONY: all clean distclean

all: $(PRG)
$(PRG): $(SOURCES) $(UIFILES)
	glib-compile-resources tea.gresource.xml --target=resources.c --generate-source
	$(VALAC) -o $(PRG) $(SOURCES) resources.c $(VALAFLAGS)

schema: de.hannenz.tea.gschema.xml
	cp de.hannenz.tea.gschema.xml /usr/share/glib-2.0/schemas/ && glib-compile-schemas /usr/share/glib-2.0/schemas/

install:
	cp $(PRG) /usr/lib/x86_64-linux-gnu/plank/docklets/
	

noautoplank:
	gsettings set org.pantheon.desktop.cerbere monitored-processes "['wingpanel']"

autoplank:
	gsettings set org.pantheon.desktop.cerbere monitored-processes "['wingpanel', 'plank']"


clean:
	# rm -f $(OBJS)
	rm -f $(PRG)

distclean: clean
	rm -f *.vala.c

