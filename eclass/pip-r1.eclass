# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: pip-r1.eclass
# @MAINTAINER:
# Gordon Yau <qunxyz@gmail.com>
# @AUTHOR:
# Gordon Yau <qunxyz@gmail.com>
# @BLURB: extend distutils-r1.eclass that situation python package installation via pip.
# @DESCRIPTION:
# override distutils-r1.eclass src_install, cause it can't install python package via pip

inherit distutils-r1
EXPORT_FUNCTIONS init_pkg_fetch pre_pkg_setup pkg_setup src_unpack src_prepare src_configure src_compile src_install

# if PY_PN or PY_PV not defined, assign default value to them
if [[ "${PY_PN}" == "" ]]; then PY_PN="${PN}"; fi
if [[ "${PY_PV}" == "" ]]; then PY_PV="${PV}"; fi

# we need to specify absolute path for normal system command 
# cause ebuild systemd deny calling these command in global scope
pip=/usr/bin/pip
pip_rm=/bin/rm
pip_wc=/bin/wc
pip_tr=/bin/tr
pip_cat=/bin/cat
pip_sed=/bin/sed
pip_grep=/bin/grep
pip_mkdir=/bin/mkdir
pip_sleep=/bin/sleep
pip_dirname=/bin/dirname
pip_basename=/bin/basename

# define a global associative array for storing download links
declare -gA PY_SRC_URI
SRC_URI="" # normally define SRC_URI as empty, since pip-r1.eclass would generated it automatically
S="${WORKDIR}" # a single source directory would be useless, 
			   # pip-r1.eclass would made a source directory target to per python 
			   # but if ${S} not exists, emerge would failed

DEPEND="dev-python/pip
	sys-apps/coreutils
	sys-apps/sed
	sys-apps/grep
"

# @FUNCTION: pip-r1_pre_pkg_setup
# @DESCRIPTION:
# download package if package not downloaded
# cause pkg_setup may have other purpose
# and downloading need sandbox disabled
# seems hooking pre_pkg_setup is a best choice
pip-r1_pre_pkg_setup() {
	local need_fetch=0
	for file_item in ${PY_SRC_URI[@]}; do
		if [[ ! -f "${PORTAGE_ACTUAL_DISTDIR}/${file_item}" ]]; then 
			need_fetch=1
			break
		fi
	done
	
	if [[ $need_fetch == 0 ]]; then return; fi
	
	${pip_mkdir} -p $(pip-r1_get_base)
	for py_item in ${PYTHON_COMPAT[@]}; do
		local py_ver=${py_item//python/}
		local file_path=${PORTAGE_ACTUAL_DISTDIR}/${PY_SRC_URI[${py_item}]}

		`pip-r1_build_command "${pip}${py_ver//_/.}" "" "${PORTAGE_ACTUAL_DISTDIR}"`

		if [[ ! -f "${file_path}" && ${PY_INDEX} != "" ]]; then
			`pip-r1_build_command "${pip}${py_ver//_/.}" "${PY_INDEX}" "${PORTAGE_ACTUAL_DISTDIR}"`
		fi	
	
		if [[ ! -f "${file_path}" ]]; then
			`pip-r1_build_command "${pip}${py_ver//_/.}" "${HOMEPAGE}" "${PORTAGE_ACTUAL_DISTDIR}"`
		fi

		if [[ ! -f "${file_path}" ]]; then die "Package not found!"; fi
	done
	${pip_rm} -rf $(pip-r1_get_base)
}

# @FUNCTION: pip-r1_build_command
# @DESCRIPTION:
# generate download command
# @RETURN: command string
pip-r1_build_command() {
	local pip_exec="$1"
	local pip_index=""
	local pip_destdir=""

	if [[ "$2" != "" ]]; then pip_index="-f $2"; fi
	if [[ "$3" == "" ]]; then pip_destdir="$(pip-r1_get_base)"; else pip_destdir="$3"; fi

	echo "${pip_exec} download ${PY_PN}==${PY_PV} ${pip_index} --no-deps --no-cache-dir --verbose -d ${pip_destdir}"
}

# @FUNCTION: pip-r1_get_base
# @DESCRIPTION:
# get base dir path for package downloading via pip
# @RETURN: path
pip-r1_get_base() {
	if [[ -w ${HOME} ]]; then 
		echo ${HOME}/${PY_PN}
	else
		echo "/tmp/${PY_PN}"
	fi
}

# @FUNCTION: pip-r1_get_url
# @DESCRIPTION:
# Only be called by repoman
# try to get package download link via pip
# @RETURN: ${url}
pip-r1_get_url() {
	local command="$1"
	local log="$2"
	local match_link="Downloading from URL"
	local match_not_found="DistributionNotFound"

	$command >> "$log" 2>&1 &
	local pid=$!
	local url=""

	while ${pip_sleep} 1
	do
		if ${pip_grep} --quiet "$match_link" "$log"; then
			local url_info=$(${pip_sed} -n 's/.*Downloading from URL\(.*\).*/\1/p' "$log")
			url_info=${url_info//#/ }
			local url_items=(`echo ${url_info}`)
			url=${url_items[0]}
		    kill $pid &> /dev/null
			break
		elif ${pip_grep} --quiet "$match_not_found" "$log"; then
		    kill $pid &> /dev/null
			break
		fi
	done
	if [[ ! "${url}" == "" ]]; then
		${pip_rm} "$(pip-r1_get_base)/$(${pip_basename} ${url})" &> /dev/null
	fi
	${pip_rm} "$log" &> /dev/null

	echo ${url}
}

# @FUNCTION: pip-r1_init_pkg_fetch
# @DESCRIPTION:
# if Manifest not exists, try to generate SRC_URI for repoman
# otherwise parse Manifest and generate SRC_URI for emerge
pip-r1_init_pkg_fetch() {
	local ebuild_path="$(${pip_dirname} ${EBUILD})"
	if [[ -f "${ebuild_path}/Manifest" ]]; then
		if [[ $(${pip_cat} "${ebuild_path}/Manifest" | ${pip_wc} -l) == 1 ]]; then
			items=(`${pip_cat} ${ebuild_path}/Manifest`)
			pip_filename=${items[1]}
			for py_item in ${PYTHON_COMPAT[@]}; do PY_SRC_URI[${py_item}]=${pip_filename}; done
		elif [[ $(${pip_cat} "${ebuild_path}/Manifest" | ${pip_wc} -l) == 2 ]]; then
			local i=0
			while read line; do
				items=(`echo ${line}`)
				pip_filename=${items[1]}
				for py_item in ${PYTHON_COMPAT[@]}; do
					py_ver=${py_item//python/}
					if [[ ${py_ver::1} == 2 && ${i} == 0 ]]; then
						PY_SRC_URI[${py_item}]=${pip_filename}
					elif [[ ${py_ver::1} == 3 && ${i} == 1 ]]; then
						PY_SRC_URI[${py_item}]=${pip_filename}
					fi
				done
				i=$((${i}+1))
			done <"${ebuild_path}/Manifest"
		else
			local i=0
			while read line; do
				items=(`echo ${line}`)
				pip_filename=${items[1]}
				py_item=${PYTHON_COMPAT[${i}]}
				PY_SRC_URI[${py_item}]=${pip_filename}
				i=$((${i}+1))
			done <"${ebuild_path}/Manifest"
		fi
		for pkg_file in ${PY_SRC_URI[@]}; do
			if [[ ! -f ${DISTDIR}/${pkg_file} ]]; then return; fi
		done

		SRC_URI=${PY_SRC_URI[@]}
	elif [[ ${SRC_URI} == "" ]]; then
		${pip_mkdir} -p $(pip-r1_get_base)
		for py_item in ${PYTHON_COMPAT[@]}; do
			local down_log="$(pip-r1_get_base)/down.log"
			local py_ver=${py_item//python/}
			local command=$(pip-r1_build_command "${pip}${py_ver//_/.}")
			local url_item=$(pip-r1_get_url "${command}" "${down_log}")
			if [[ ${url_item} == "" && ${PY_INDEX} != "" ]]; then
				command=$(pip-r1_build_command "${pip}${py_ver//_/.}" "${PY_INDEX}")
				url_item=$(pip-r1_get_url "${command}" "${down_log}")
			elif [[ ${url_item} == "" ]]; then
				command=$(pip-r1_build_command "${pip}${py_ver//_/.}" "${HOMEPAGE}")
				url_item=$(pip-r1_get_url "${command}" "${down_log}")
			fi
			if [[ ! ${url_item} == "" ]]; then
				PY_SRC_URI[${py_item}]=${url_item}; 
			else
				eerror "Package download link not found, please retry or check ebuild script"
				exit 0
			fi
		done
		${pip_rm} -rf $(pip-r1_get_base)
		SRC_URI=${PY_SRC_URI[@]}
	fi
}

# @FUNCTION: pip-r1_pkg_setup
# @DESCRIPTION:
# do nothing
pip-r1_pkg_setup() {
	return
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
		local prefix=$($(tc-getPKG_CONFIG) --variable=prefix ${EPYTHON//python/python-})
		PYTHONUSERBASE=${D}/${prefix} ${PYTHON} /usr/bin/pip install --no-cache-dir --user ${PORTAGE_ACTUAL_DISTDIR}/$(basename ${PY_SRC_URI[${EPYTHON//\./_}]})
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
