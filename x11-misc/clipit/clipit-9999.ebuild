# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools gnome2-utils xdg-utils

DESCRIPTION="Lightweight GTK+ clipboard manager. Fork of Parcellite."
HOMEPAGE="http://gtkclipit.sourceforge.net https://github.com/CristianHenzel/ClipIt"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/CristianHenzel/ClipIt.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/CristianHenzel/ClipIt/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~x86 ~amd64"
	S="${WORKDIR}/ClipIt-${PV}"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="nls gtk3 appindicator"

DEPEND="
	!gtk3? (
		>=x11-libs/gtk+-2.10:2
		appindicator? ( dev-libs/libappindicator:2 )
	)
	gtk3? (
		x11-libs/gtk+:3
		appindicator? ( dev-libs/libappindicator:3 )
	)
	>=dev-libs/glib-2.14
	nls? (
		dev-util/intltool
		sys-devel/gettext
		)
"
RDEPEND="${DEPEND}
	x11-misc/xdotool
"

src_prepare(){
	sed -i -e "s/1\.4\.3/${PV}/" configure.ac
	default_src_prepare
	eautoreconf
}


src_configure(){
	econf \
		$(use_enable nls) \
		$(use_enable appindicator) \
		$(use_with gtk3)
}

pkg_preinst(){
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
