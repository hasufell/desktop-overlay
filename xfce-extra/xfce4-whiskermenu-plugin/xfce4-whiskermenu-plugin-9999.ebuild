# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit gnome2-utils cmake-utils git-2

DESCRIPTION="Alternate application launcher for Xfce"
HOMEPAGE="http://gottcode.org/xfce4-whiskermenu-plugin/"
SRC_URI=""
EGIT_REPO_URI="https://github.com/gottcode/xfce4-whiskermenu-plugin.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	dev-libs/glib:2
	x11-libs/gtk+:2
	xfce-base/exo
	xfce-base/garcon
	xfce-base/libxfce4ui
	xfce-base/libxfce4util
	xfce-base/xfce4-panel
	virtual/libintl"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	sys-devel/gettext"

src_prepare() {
	local i
	cd po || die
	if [[ -n "${LINGUAS+x}" ]] ; then
		for i in *.po ; do
			einfo "removing ${i%.po} linguas"
			has ${i%.po} ${LINGUAS} || { rm ${i} || die ; }
		done
	fi
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_AS_NEEDED=OFF
		-DENABLE_LINKER_OPTIMIZED_HASH_TABLES=OFF
		-DENABLE_DEVELOPER_MODE=OFF
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	nonfatal dodoc NEWS README
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
