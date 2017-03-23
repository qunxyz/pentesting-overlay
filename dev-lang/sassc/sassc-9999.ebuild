# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-r3 autotools

DESCRIPTION="libsass command line driver"
HOMEPAGE="https://github.com/sass/sassc"
SRC_URI=""
EGIT_REPO_URI="https://github.com/sass/sassc.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="=dev-libs/libsass-9999"
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
}


