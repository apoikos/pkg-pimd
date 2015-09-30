# libite -- Light-weight utility functions and C-library extensions
# 
# Copyright (c) 2008-2015  Joachim Nilsson <troglobit@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
.PHONY: all install clean

# Figure out root of library, unless used as submodule
ROOTDIR    ?= $(shell pwd)

#VERSION    = $(shell git tag -l | tail -1)
VERSION    ?= 1.0.0
NAME        = libite
PKG         = $(NAME)-$(VERSION)
ARCHIVE     = $(PKG).tar.xz

CC         ?= $(CROSS)gcc
AR         ?= $(CROSS)ar
STRIP      ?= $(CROSS)strip
INSTALL    := install --backup=off
STRIPINST  := $(INSTALL) -s --strip-program=$(CROSS)strip -m 0755

CFLAGS     += -fPIC
CFLAGS     += -Os
CPPFLAGS   += -D_GNU_SOURCE
CPPFLAGS   += -W -Wall
ARFLAGS     = crus

# Default to silent build, use V=1 to get verbose mode.
ifeq ($V,1)
Q           =
PRINT       = @true
MAKEFLAGS   =
else
Q           = @
PRINT       = @printf
MAKEFLAGS   = --no-print-directory --silent
endif

DISTFILES   = README LICENSE
HEADERS     = lite.h
OBJS       := chomp.o copyfile.o dir.o fexist.o fisdir.o fmode.o fsendfile.o
OBJS       += ifconfig.o makepath.o pidfile.o pidfilefn.o rsync.o
OBJS       += strlcpy.o strlcat.o strtonum.o tempfile.o
DEPS       := $(OBJS:.o=.d)
JUNK        = *~ *.bak *.map .*.d *.d DEADJOE semantic.cache *.gdb *.elf core core.*

VER         = 1
LIBNAME     = $(NAME)
SOLIB       = $(LIBNAME).so.$(VER)
SYMLIB      = $(LIBNAME).so
STATICLIB   = $(LIBNAME).a
TARGET      = $(STATICLIB) $(SOLIB)

# Default install paths
prefix     ?= /usr/local
libdir     ?= $(prefix)/lib
datadir    ?= $(prefix)/share/doc/$(LIBNAME)
incdir     ?= $(prefix)/include

# This magic trick looks like a comment, but works on BSD PMake
#include <rules.mk>
include rules.mk

# Build rules
all: $(TARGET)

$(OBJS): Makefile

$(SOLIB): Makefile $(OBJS)
	$(PRINT) "  LINK    %s\n" $@
	$(Q)$(CC) $(LDFLAGS) -shared -Wl,-soname,$@ -o $@ $(OBJS)

$(STATICLIB): Makefile $(OBJS)
	$(Q)$(PRINT) "  ARCHIVE $@\n"
	$(Q)$(AR) $(ARFLAGS) $@ $(OBJS)

install-exec: all
	$(PRINT) "  INSTALL $(DESTDIR)$(libdir)/$(SOLIB)\n"
	$(Q)install -d $(DESTDIR)$(libdir)
	$(Q)$(STRIPINST) $(SOLIB) $(DESTDIR)$(libdir)/$(SOLIB)
	$(Q)ln -sf $(SOLIB) $(DESTDIR)$(libdir)/$(SYMLIB)

install-dev:
	$(Q)install -d $(DESTDIR)$(incdir)/$(LIBNAME)
	$(Q)for file in $(HEADERS); do	                                		\
		printf "  INSTALL $(DESTDIR)$(incdir)/$(LIBNAME)/$$file\n";		\
		$(INSTALL) -m 0644 $$file $(DESTDIR)$(incdir)/$(LIBNAME)/$$file;	\
	done
	$(PRINT) "  INSTALL $(DESTDIR)$(libdir)/$(STATICLIB)\n"
	$(Q)install -d $(DESTDIR)$(libdir)
	$(Q)$(INSTALL) $(STATICLIB) $(DESTDIR)$(libdir)/$(STATICLIB)
	$(Q)install -d $(DESTDIR)$(datadir)
	$(Q)for file in $(DISTFILES); do					\
		printf "  INSTALL $(DESTDIR)$(datadir)/$$file\n";	\
		install -m 0644 $$file $(DESTDIR)$(datadir)/$$file;	\
	done

install: install-exec install-dev

uninstall:
	-$(Q)$(RM) -r $(DESTDIR)$(datadir)
	-$(Q)$(RM) -r $(DESTDIR)$(incdir)/$(LIBNAME)
	-$(Q)$(RM) $(DESTDIR)$(libdir)/$(SOLIB)
	-$(Q)$(RM) $(DESTDIR)$(libdir)/$(SYMLIB)
	-$(Q)$(RM) $(DESTDIR)$(libdir)/$(STATICLIB)

strip: $(TARGET)
	$(Q)$(PRINT) "  STRIP   %s\n" $(TARGET)
	$(Q)$(STRIP) --strip-unneeded $(TARGET)
	$(Q)size $(TARGET)

# Runs Clang scan-build on the whole tree
check: clean
	$(Q)scan-build $(MAKE) all

clean:
	-$(Q)$(RM) $(OBJS) $(DEPS) $(TARGET) $(SOLIB) $(STATICLIB)

distclean:
	-$(Q)$(RM) $(JUNK) unittest *.o *.a *.so* *.unittest

# When called from GNU configure and build system
distdir:
	@git archive --format=tar HEAD | (cd $(distdir); tar xf -)

dist:
	$(Q)echo "Building .xz tarball of $(PKG) in parent dir..."
	git archive --format=tar --prefix=$(PKG)/ v$(VERSION) | xz >../$(ARCHIVE)
	$(Q)(cd ..; md5sum $(ARCHIVE) | tee $(ARCHIVE).md5)

# Include automatically generated rules
-include $(DEPS)
