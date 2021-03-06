# Copyright 2019 Jacob Hrbek, Kreyren
# Distributed under the terms of the Krey's Anti-Harrasment Licence based on GNU GENERAL PUBLIC LICENSE v2
# Based on master index https://devmanual.gentoo.org/

# @ECLASS: kreyrenized.eclass
# @MAINTAINER: Jacob Hrbek <kreyren@rixotstudio.cz>
# @SUPPORTED_EAPIS: 0
# @AUTHOR: Jacob Hrbek <kreyren@rixotstudio.cz>
# @BLURB: Improved variable definitions for enoch builds

EAPI="0"

# AUTOMIZATION
AUTOMATIZATION() {
	PUS=${UPSTREAM} # Package UpStream
	LINK_ON_REPOSITORY="github.com/Kreyren/KreyOverlay"

	# Greb correct source automatically
	if [[ $SOURCE == "GitHub" ]]; then

		if use gitted || $PV="9999"; then
			inherit git-r3
			EGIT_REPO_URI="git@github.com:${PUS}/${PN}.git"

			[ $PV == 9999 ] && EGIT_BRANCH="master"

			else
				SRC_URI="https://github.com/${PUS}/${PN}/archive/v${PV}.tar.gz"

				if [[ $PV =~ _(TEST) ]]; then
					KEYWORDS="~amd64 ~x86"
					else
						KEYWORDS="amd64 x86"
				fi

			MPV=${PV}
			SLOT="${PV}" # Sane?

		fi

		else
			die "This SOURCE variable is not supported, file issue on $LINK_ON_REPOSITORY with:
- SOURCE == ${SOURCE}"
	fi

}; AUTOMATIZATION

# @FUNCTION: jazzhands
# @DESCRIPTION: Improve Gentoo's shorthands
jazzhands() {
	PC="${CATEGORY}" # Package Category
	PN=$PN # Package Name
	PV=$PV # Package Version
	PR=$PR # Package Revision
	PVAR=${PVR} # Package Version And Revision
	PFN=${PN} # Package Full Name
	ROOT="/" # I AM ROOT
	MPFN="$PN-$MPV" # My/Modified Package Full Name
	PFN="$PN-$MPV-${PR:+-$PR}" # Package Full Name (Package, Version, Revision (if any)
	PORTDIR="/var/tmp/portage" # PORTage DIRectory
	PACKDIR="${PORTDIR}/${PC}/${PNAV}" # PACKage DIRectory
	BUILDDIR="${PACKDIR}/build" # Package Build Directory
		PBD=${BUILDDIR}
	FILESDIR="${PACKDIR}/files" # Package Files Directory
		PFD=${FILESDIR}
	WORKDIR="${PACKDIR}/work" # Package Work Directory
		PWD=${WORKDIR}
	HOMEDIR="${PACKDIR}/homedir" # Package Home Directory
		PHD=${HOMEDIR}
	DISTDIR="${PACKDIR}/distdir" # Package Dist Directory
		PDD=${DISTDIR}
	IMAGEDIR="${PACKDIR}/image" # Package Image Directory
		PID=${IMAGEDIR}
	SOURCEDIR="${PACKDIR}/${PNAV}" # Package Source Directory
		PSD=${SOURCEDIR}
}; jazzhands

# @NAME: Handling of errors
eerror() { echo "$0:" "$@" >&2 } # temporary
warn() { echo "WARNING: $*" 1>&2 }
die() {	echo "FATAL: $*" 1>&2 ; exit 1 }

# $FUNCTION: kernel_check
# @DESCRIPTION: Function used to check kernel version
kernel_check() {
	if [[ $(uname -o) == "GNU/Linux" ]]; then
		version=$(uname -r); major=${version%%.*}; minor=${version#*.}; minor=${minor%%.*} # Export variables

	else
		 echo "FATAL: This kernel is not supported by jazzhands.eclass, file an issue to github.com/Kreyren/KreyOverlay with:

- uname -a == ${uname -a}
- uname -s == ${uname -s}
- uname -o == ${uname -o}

"
	fi
}; kernel_check

## TEMPORARY!!
# @FUNCTION: einstalldocs
# @DESCRIPTION:
# Install documentation using DOCS and HTML_DOCS, in EAPIs that do not
# provide this function.  When available (i.e., in EAPI 6 or later),
# the package manager implementation should be used instead.
#
# If DOCS is declared and non-empty, all files listed in it are
# installed.  The files must exist, otherwise the function will fail.
# In EAPI 4 and 5, DOCS may specify directories as well; in earlier
# EAPIs using directories is unsupported.
#
# If DOCS is not declared, the files matching patterns given
# in the default EAPI implementation of src_install will be installed.
# If this is undesired, DOCS can be set to empty value to prevent any
# documentation from being installed.
#
# If HTML_DOCS is declared and non-empty, all files and/or directories
# listed in it are installed as HTML docs (using dohtml).
#
# Both DOCS and HTML_DOCS can either be an array or a whitespace-
# separated list. Whenever directories are allowed, '<directory>/.' may
# be specified in order to install all files within the directory
# without creating a sub-directory in docdir.
#
# Passing additional options to dodoc and dohtml is not supported.
# If you needed such a thing, you need to call those helpers explicitly.
einstalldocs() {
	debug-print-function ${FUNCNAME} "${@}"

	local dodoc_opts=-r
	has ${EAPI} 0 1 2 3 && dodoc_opts=

	if ! declare -p DOCS &>/dev/null ; then
		local d
		for d in README* ChangeLog AUTHORS NEWS TODO CHANGES \
				THANKS BUGS FAQ CREDITS CHANGELOG ; do
			if [[ -s ${d} ]] ; then
				dodoc "${d}" || die
			fi
		done
	elif [[ $(declare -p DOCS) == "declare -a"* ]] ; then
		if [[ ${DOCS[@]} ]] ; then
			dodoc ${dodoc_opts} "${DOCS[@]}" || die
		fi
	else
		if [[ ${DOCS} ]] ; then
			dodoc ${dodoc_opts} ${DOCS} || die
		fi
	fi

	if [[ $(declare -p HTML_DOCS 2>/dev/null) == "declare -a"* ]] ; then
		if [[ ${HTML_DOCS[@]} ]] ; then
			dohtml -r "${HTML_DOCS[@]}" || die
		fi
	else
		if [[ ${HTML_DOCS} ]] ; then
			dohtml -r ${HTML_DOCS} || die
		fi
	fi

	return 0
}
