# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GOLANG_PKG_IMPORTPATH="github.com/rogpeppe"
GOLANG_PKG_VERSION="b692db1de5229d4248e23c41736b431eb665615d"
GOLANG_PKG_HAVE_TEST=1

GOLANG_PKG_DEPENDENCIES=(
	"github.com/9fans/go:f3da003 -> 9fans.net"
)

inherit golang-single

DESCRIPTION="Godef prints where symbols are defined in Go source code"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
