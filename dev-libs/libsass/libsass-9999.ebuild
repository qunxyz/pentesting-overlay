# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-r3 autotools

DESCRIPTION="A C/C++ implementation of a Sass compiler"
HOMEPAGE="http://libsass.org"
SRC_URI=""
EGIT_REPO_URI="https://github.com/sass/libsass.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
}


