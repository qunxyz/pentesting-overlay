# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit scons-utils eutils
CMAKE_BUILD_TYPE="Release"

DESCRIPTION="A joystick testing and configuration tool for Linux"
HOMEPAGE="http://http://pingus.seul.org/~grumbel/jstest-gtk/"

LICENSE="GPLv3"
SLOT="0"

KEYWORDS="~amd64"
SRC_URI="https://github.com/Grumbel/jstest-gtk/archive/v${PV}.tar.gz -> ${P}.tar.bz2"

RDEPEND="dev-libs/libsigc++
	dev-cpp/gtkmm"
HDEPEND="${RDEPEND}
	dev-util/sconf"

src_prepare(){
	epatch "${FILESDIR}/sconstruct_cxx11.patch"
	epatch "${FILESDIR}/sconstruct_unistd.patch"
	sed -i 's/gtkglextmm/gtkglext/' SConstruct || die "sed gtkglext failed"
	sed -i 's/gtkglext-1.2/gtkglext-1.0/' SConstruct || die "sed gtkglext version failed"
	sed -i "s/CXXFLAGS=[/CXXFLAGS=[${CXXFLAGS},\ /" SConstruct || die "sed cxx flags failed"
	default
}
src_compile() {
	escons
}
src_install() {
	dobin "${CMAKE_BUILD_DIR}/${PN}"
	insinto "/usr/share/${PN}"
	doins -r "${S}"/data

	doicon ${S}/data/generic.png

	make_desktop_entry "${PN}" "${PN}" "generic" "Utility" "Path=/usr/share/${PN}"

}
