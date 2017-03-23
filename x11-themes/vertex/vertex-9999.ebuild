# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-r3 autotools

DESCRIPTION="Vertex is a theme for GTK 3, GTK 2, Gnome-Shell and Cinnamon."
HOMEPAGE="https://github.com/horst3180/Vertex-theme"
SRC_URI=""
EGIT_REPO_URI="https://github.com/horst3180/Vertex-theme.git"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+gtk2 +gtk3 +dark +light -cinnamon -metacity -unity -xfwm -gnome-shell"

DEPEND="x11-themes/gnome-themes-standard
x11-themes/gtk-engines-murrine"
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable gtk2) \
		$(use_enable gtk3) \
		$(use_enable dark) \
		$(use_enable light) \
		$(use_enable cinnamon) \
		$(use_enable metacity) \
		$(use_enable unity) \
		$(use_enable xfwm) \
		$(use_enable gnome-shell)
}
