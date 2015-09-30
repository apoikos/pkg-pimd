# -*-Makefile-*-
#
# Protocol Independent Multicast, Sparse-Mode version 2.0
#
# 2010-08-21  Joachim Nilsson <jocke@vmlinux.org>
#       * Cleanup unportable rules.mk and simplify for build
#         using BSD make, and similar.
#
# 2010-01-16  Joachim Nilsson <jocke@vmlinux.org>
#       * Cleanup and refactoring for cross building.
#
# 2003-03-27  Antonin Kral <A.Kral@sh.cvut.cz>
# 	* Modified for Debian
#
# 2001-11-13  Pavlin Ivanov Radoslavov (pavlin@catarina.usc.edu)
#       * Original Makefile
#

# VERSION      ?= $(shell git tag -l | tail -1)
VERSION      ?= 2.1.8
EXEC          = pimd
CONFIG        = $(EXEC).conf
PKG           = $(EXEC)-$(VERSION)
ARCHIVE       = $(PKG).tar.bz2

ROOTDIR      ?= $(dir $(shell pwd))
RM           ?= rm -f
CC           ?= $(CROSS)gcc

prefix       ?= /usr/local
sysconfdir   ?= /etc
datadir       = $(prefix)/share/doc/pimd
mandir        = $(prefix)/share/man/man8


# Uncomment the following line if you want to use RSRR (Routing
# Support for Resource Reservations), currently used by RSVP.
#RSRRDEF       = -DRSRR
RSRR_OBJS     = rsrr.o

IGMP_OBJS     = igmp.o igmp_proto.o trace.o
ROUTER_OBJS   = inet.o kern.o main.o config.o debug.o netlink.o routesock.o \
		vers.o callout.o
PIM_OBJS      = route.o vif.o timer.o mrt.o pim.o pim_proto.o rp.o
DVMRP_OBJS    = dvmrp_proto.o

# This magic trick looks like a comment, but works on BSD PMake
#include <config.mk>
include config.mk
#include <snmp.mk>
include snmp.mk

## Common
CFLAGS       += $(MCAST_INCLUDE) $(SNMPDEF) $(RSRRDEF) $(INCLUDES) $(DEFS) $(USERCOMPILE)
CFLAGS       += -O2 -W -Wall -Werror -fno-strict-aliasing
#CFLAGS       += -O -g
LDLIBS        = $(SNMPLIBDIR) $(SNMPLIBS) $(EXTRA_LIBS)
OBJS          = $(IGMP_OBJS) $(ROUTER_OBJS) $(PIM_OBJS) $(DVMRP_OBJS) \
		$(SNMP_OBJS) $(RSRR_OBJS) $(EXTRA_OBJS)
SRCS          = $(OBJS:.o=.c)
DEPS          = $(addprefix .,$(SRCS:.c=.d))
MANS          = $(addsuffix .8,$(EXEC))
DISTFILES     = README README.config README.config.jp README.debug \
		ChangeLog INSTALL LICENSE LICENSE.mrouted \
		TODO CREDITS FAQ AUTHORS

LINT          = splint
LINTFLAGS     = $(MCAST_INCLUDE) $(filter-out -W -Wall -Werror, $(CFLAGS)) -posix-lib -weak -skipposixheaders

PURIFY        = purify
PURIFYFLAGS   = -cache-dir=/tmp -collector=/import/pkgs/gcc/lib/gcc-lib/sparc-sun-sunos4.1.3_U1/2.7.2.2/ld

all: $(EXEC)

.c.o:
	@printf "  CC      $@\n"
	@$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

$(EXEC): $(OBJS)
	@printf "  LINK    $@\n"
	@$(CC) $(CFLAGS) $(LDFLAGS) -Wl,-Map,$@.map -o $@ $(OBJS) $(LDLIBS)

purify: $(OBJS)
	@$(PURIFY) $(PURIFYFLAGS) $(CC) $(LDFLAGS) -o $(EXEC) $(CFLAGS) $(OBJS) $(LDLIBS)

vers.c:
	@echo $(VERSION) | sed -e 's/.*/char todaysversion[]="&";/' > vers.c

install: $(EXEC)
	@install -d $(DESTDIR)$(prefix)/sbin
	@install -d $(DESTDIR)$(sysconfdir)
	@install -d $(DESTDIR)$(datadir)
	@install -d $(DESTDIR)$(mandir)
	@install -m 0755 $(EXEC) $(DESTDIR)$(prefix)/sbin/$(EXEC)
	@install -b -m 0644 $(CONFIG) $(DESTDIR)$(sysconfdir)/$(CONFIG)
	@for file in $(DISTFILES); do \
		install -m 0644 $$file $(DESTDIR)$(datadir)/$$file; \
	done
	@for file in $(MANS); do \
		install -m 0644 $$file $(DESTDIR)$(mandir)/$$file; \
	done

uninstall:
	-@$(RM) $(DESTDIR)$(prefix)/sbin/$(EXEC)
	-@$(RM) $(DESTDIR)$(sysconfdir)/$(CONFIG)
	-@$(RM) -r $(DESTDIR)$(datadir)
	-@for file in $(MANS); do \
		$(RM) $(DESTDIR)$(mandir)/$$file; \
	done

clean: $(SNMPCLEAN)
	-@$(RM) $(OBJS) $(EXEC)

distclean:
	-@$(RM) $(OBJS) core $(EXEC) vers.c tags TAGS *.o *.map .*.d *.out tags TAGS

dist:
	@echo "Building bzip2 tarball of $(PKG) in parent dir..."
	git archive --format=tar --prefix=$(PKG)/ $(VERSION) | bzip2 >../$(ARCHIVE)
	@(cd ..; md5sum $(ARCHIVE) | tee $(ARCHIVE).md5)

build-deb:
	@echo "Building .deb if $(PKG)..."
	git-buildpackage --git-ignore-new --git-upstream-branch=master

lint:
	@$(LINT) $(LINTFLAGS) $(SRCS)

tags: $(SRCS)
	@ctags $(SRCS)

cflow:
	@cflow $(MCAST_INCLUDE) $(SRCS) > cflow.out

cflow2:
	@cflow -ix $(MCAST_INCLUDE) $(SRCS) > cflow2.out

rcflow:
	@cflow -r $(MCAST_INCLUDE) $(SRCS) > rcflow.out

rcflow2:
	@cflow -r -ix $(MCAST_INCLUDE) $(SRCS) > rcflow2.out

TAGS:
	@etags $(SRCS)

snmpd/libsnmpd.a:
	@make -C snmpd

snmplib/libsnmp.a:
	@make -C snmplib

snmpclean:
	@for dir in snmpd snmplib; do \
		make -C $$dir clean;  \
	done
