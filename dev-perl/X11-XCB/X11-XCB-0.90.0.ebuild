# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

MODULE_AUTHOR="MSTPLBG"
MODULE_VERSION="0.09"
inherit perl-module

DESCRIPTION="Perl bindings for libxcb"

LICENSE="|| ( Artistic GPL-1 GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND="dev-perl/Mouse
	dev-perl/MouseX-NativeTraits
	dev-perl/Try-Tiny
	virtual/perl-XSLoader"
DEPEND="dev-perl/extutils-depends
	dev-perl/XS-Object-Magic
	virtual/perl-Devel-PPPort
	virtual/perl-ExtUtils-MakeMaker
	virtual/perl-ExtUtils-ParseXS
	test? (
		dev-perl/Test-Deep
		dev-perl/Test-Exception
	)"

SRC_TEST="skip" # FIXME: portage/virtualx messes up

MAKEOPTS+=" -j1"
