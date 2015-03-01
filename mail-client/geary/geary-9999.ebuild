# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

VALA_MIN_API_VERSION=0.22

inherit eutils fdo-mime gnome2-utils vala cmake-utils git-r3

MY_P=${P/_pre/pr}
DESCRIPTION="A lightweight, easy-to-use, feature-rich email client"
HOMEPAGE="http://www.yorba.org/projects/geary/"
SRC_URI=""
EGIT_REPO_URI="git://git.gnome.org/geary"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE="nls"

DEPEND="
	>=app-crypt/gcr-3.10.1[gtk,introspection,vala]
	app-crypt/libsecret
	dev-db/sqlite:3
	>=dev-libs/glib-2.34:2
	>=dev-libs/libgee-0.8.5:0.8
	dev-libs/libxml2:2
	>=dev-libs/gmime-2.6.14:2.6
	media-libs/libcanberra
	>=net-libs/webkit-gtk-1.10.0:3[introspection]
	>=x11-libs/gtk+-3.10.0:3[introspection]
	x11-libs/libnotify"
RDEPEND="${DEPEND}
	gnome-base/gsettings-desktop-schemas
	nls? ( virtual/libintl )"
DEPEND="${DEPEND}
	app-text/gnome-doc-utils
	dev-util/desktop-file-utils
	nls? ( sys-devel/gettext )
	$(vala_depend)
	virtual/pkgconfig"

DOCS=( AUTHORS MAINTAINERS README NEWS THANKS )

S=${WORKDIR}/${MY_P}

my_vapigen_env() {
	mkdir "${T}"/vapigenbin || die
	ln -s "${VAPIGEN}" "${T}"/vapigenbin/vapigen || die
	export PATH="${T}/vapigenbin${PATH:+:}${PATH}"
}

src_prepare() {
	local i
	if use nls ; then
		if [[ -n "${LINGUAS+x}" ]] ; then
			for i in $(cd po ; echo *.po) ; do
				if ! has ${i%.po} ${LINGUAS} ; then
					sed -i -e "/^${i%.po}$/d" po/LINGUAS || die
				fi
			done
		fi
	else
		sed -i -e 's#add_subdirectory(po)##' CMakeLists.txt || die
	fi

	cmake-utils_src_prepare
	vala_src_prepare
	my_vapigen_env
}

src_configure() {
	local mycmakeargs=(
		-DDESKTOP_UPDATE=OFF
		-DGSETTINGS_COMPILE=OFF
		-DICON_UPDATE=OFF
		-DVALA_EXECUTABLE="${VALAC}"
		-DDESKTOP_VALIDATE=OFF
	)

	cmake-utils_src_configure
}

pkg_preinst() {
	gnome2_icon_savelist
	gnome2_schemas_savelist
}

pkg_postinst() {
	elog "For libnotify sounds you will need"
	elog "\"alsa\" or \"pulseaudio\" useflag of media-libs/libcanberra"
	elog "enabled."

	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
	gnome2_schemas_update
}