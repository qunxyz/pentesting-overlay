# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: pip-r1.eclass
# @MAINTAINER:
# Gordon Yau <qunxyz@gmail.com>
# @AUTHOR:
# Gordon Yau <qunxyz@gmail.com>
# @BLURB: extend distutils-r1.eclass that situation need to specify setup.py path.
# @DESCRIPTION:
# override distutils-r1.eclass src_compile and src_install, cause these functions
# can't custom setup.py that needed by bazel projects.

inherit distutils-r1

EXPORT_FUNCTIONS pkg_setup src_unpack src_prepare src_configure src_compile src_install

if [[ "${PY_PN}" == "" ]]; then PY_PN="${PN}"; fi
if [[ "${PY_PV}" == "" ]]; then PY_PV="${PV}"; fi

SRC_URI=""
RESTRICT="fetch"
S="${WORKDIR}"

DEPEND="dev-python/pip
"

# @FUNCTION: pip-r1_pkg_setup
# @DESCRIPTION:
# Calls pip to fetch python package.
pip-r1_pkg_setup() {
	fetch_pkg() {
		${PYTHON} /usr/bin/pip download ${PY_PN}==${PY_PV} --no-deps --no-cache-dir
	}
	python_foreach_impl run_in_build_dir fetch_pkg
}

# @FUNCTION: pip-r1_src_unpack
# @DESCRIPTION:
# do nothing.
pip-r1_src_unpack() {
	return
}

# @FUNCTION: pip-r1_src_prepare
# @DESCRIPTION:
# do nothing.
pip-r1_src_prepare() {
	return
}

# @FUNCTION: pip-r1_src_configure
# @DESCRIPTION:
# do nothing.
pip-r1_src_configure() {
	return
}

# @FUNCTION: pip-r1_src_compile
# @DESCRIPTION:
# do nothing.
pip-r1_src_compile() {
	return
}

# @FUNCTION: pip-r1_src_install
# @DESCRIPTION:
# install python package.
pip-r1_src_install() {
	install_pkg() {
		echo ${ED}
		 find . -type f -print0 | PYTHONUSERBASE=${D} xargs -0 ${PYTHON} /usr/bin/pip install --no-cache-dir --user
	}
	python_foreach_impl run_in_build_dir install_pkg
}

# -- distutils.eclass functions --

distutils_pkg_setup() {
	die "${FUNCNAME}() is invalid for pip-r1, you probably want: ${FUNCNAME/_/-r1_}"
}

distutils_src_unpack() {
	die "${FUNCNAME}() is invalid for pip-r1, you probably want: ${FUNCNAME/_/-r1_}"
}

distutils_src_prepare() {
	die "${FUNCNAME}() is invalid for pip-r1, you probably want: ${FUNCNAME/_/-r1_}"
}

distutils_src_configure() {
	die "${FUNCNAME}() is invalid for pip-r1, you probably want: ${FUNCNAME/_/-r1_}"
}

distutils_src_compile() {
	die "${FUNCNAME}() is invalid for pip-r1, you probably want: ${FUNCNAME/_/-r1_}"
}

distutils_src_install() {
	die "${FUNCNAME}() is invalid for pip-r1, you probably want: ${FUNCNAME/_/-r1_}"
}
