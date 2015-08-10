# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils toolchain-funcs flag-o-matic virtualx git-2

DESCRIPTION="An improved dynamic tiling window manager"
HOMEPAGE="http://i3wm.org/"
SRC_URI=""
EGIT_REPO_URI="https://github.com/hasufell/i3wm.git"
EGIT_BRANCH="next"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE="+icons +pango test"

CDEPEND="dev-lang/perl
	dev-libs/libev
	dev-libs/libpcre
	>=dev-libs/yajl-2.0.3
	x11-libs/libxcb
	x11-libs/libX11
	x11-libs/startup-notification
	x11-libs/xcb-util
	x11-libs/xcb-util-cursor
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-wm
	icons? ( x11-libs/xcb-util-image )
	pango? (
		>=x11-libs/pango-1.30.0[X]
		>=x11-libs/cairo-1.12.2[X,xcb]
	)"
DEPEND="${CDEPEND}
	app-text/asciidoc
	virtual/pkgconfig
	test? (
		dev-perl/AnyEvent
		dev-perl/AnyEvent-I3
		dev-perl/extutils-pkgconfig
		dev-perl/Inline
		dev-perl/IPC-Run
		dev-perl/JSON-XS
		dev-perl/X11-XCB
		virtual/perl-Data-Dumper
		virtual/perl-ExtUtils-MakeMaker
		virtual/perl-File-Temp
		virtual/perl-Getopt-Long
		virtual/perl-IO
		virtual/perl-Test
		virtual/perl-Test-Harness
		virtual/perl-Time-HiRes
		x11-drivers/xf86-video-dummy
	)"
RDEPEND="${CDEPEND}"

src_prepare() {
	if ! use pango; then
		sed -i common.mk -e '/PANGO/d' || die
	fi

	cat <<- EOF > "${T}"/i3wm
		#!/bin/sh
		exec /usr/bin/i3
	EOF

	epatch_user #471716
}

src_compile() {
	emake V=1 CC="$(tc-getCC)" AR="$(tc-getAR)" USE_ICONS="$(usex icons 1 0)" VERSION=4
	emake mans
}

src_test() {
	if has userpriv ${FEATURES} ; then
		# need to copy /usr/bin/Xorg for Xdummy to work
		ewarn "Skipping tests: root privileges are required,"
		ewarn "so userpriv must be disabled."
	else
		# Xdummy fails to start properly
		# with sandbox enabled.
		# Also needs access to /var/log.
		local _OLD_SANDBOX_ON=${SANDBOX_ON}
		export SANDBOX_ON="0"

		# optimization breaks Xdummy
		strip-flags
		CFLAGS="${CFLAGS} -O0"

		cd testcases || die
		cat /usr/bin/Xorg > /tmp/Xorg.root.bin || die
		VIRTUALX_COMMAND="./complete-run.pl --parallel 1 --keep-xdummy-output" \
			virtualmake

		export SANDBOX_ON=${_OLD_SANDBOX_ON}

		# no retval from complete-run.pl, grep for errors
		grep "^not ok " latest/complete-run.log && die "some tests failed!"
	fi
}

src_install() {
	default
	dohtml -r docs/*
	doman man/*.1
	exeinto /etc/X11/Sessions
	doexe "${T}"/i3wm
}

pkg_postinst() {
	einfo "There are several packages that you may find useful with ${PN} and"
	einfo "their usage is suggested by the upstream maintainers, namely:"
	einfo "  x11-misc/dmenu"
	einfo "  x11-misc/i3status"
	einfo "  x11-misc/i3lock"
	einfo "Please refer to their description for additional info."
}
