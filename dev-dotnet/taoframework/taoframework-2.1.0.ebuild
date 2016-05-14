# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils mono

DESCRIPTION="Bindings to facilitate cross-platform game-related development utilizing the .NET platform"
HOMEPAGE="http://sourceforge.net/projects/taoframework/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+cg +devil doc +ffmpeg +freeglut +freetype +glfw +lua +ode +openal +opengl +physfs +sdl"

DEPEND=">=dev-lang/mono-2.0
	doc? ( >=virtual/monodoc-2.0 )"
RDEPEND="${DEPEND}
	cg? ( media-gfx/nvidia-cg-toolkit )
	devil? ( media-libs/devil )
	ffmpeg? ( media-video/ffmpeg )
	freeglut? ( media-libs/freeglut )
	freetype? ( media-libs/freetype )
	glfw? ( media-libs/glfw )
	lua? ( dev-lang/lua )
	ode? ( dev-games/ode )
	openal? (
		media-libs/freealut
		media-libs/openal
	)
	opengl? ( virtual/opengl )
	physfs? ( dev-games/physfs )
	sdl? (
		media-libs/libsdl
		media-libs/sdl-gfx
		media-libs/sdl-image
		media-libs/sdl-mixer
		media-libs/sdl-ttf
		media-libs/sdl-net
		media-libs/smpeg
	)"

S="${WORKDIR}/${P}/source"

GACPN="Tao"

DOCS=("AUTHORS" "ChangeLog" "NEWS" "README")

generate_pkgconfig() {
	local dll dlls="$@" pcname="${PN}" LSTRING="Libs:"
	#`echo "${GACPN}" | tr A-Z a-z`

	ebegin "Generating ${pcname}.pc file"
	dodir "/usr/$(get_libdir)/pkgconfig"
	cat <<- EOF -> "${D}/usr/$(get_libdir)/pkgconfig/${pcname}.pc"
		prefix=/usr
		exec_prefix=\${prefix}
		libdir=\${prefix}/$(get_libdir)
		Name: ${GACPN}
		Description: ${DESCRIPTION}
		Version: ${PV}
	EOF
	for dll in $dlls
	do
		LSTRING="${LSTRING} -r:"'${libdir}'"/mono/${GACPN}/${dll##*/}"
	done
	printf "${LSTRING}\n" >> "${D}/usr/$(get_libdir)/pkgconfig/${pcname}.pc"
	PKG_CONFIG_PATH="${D}/usr/$(get_libdir)/pkgconfig/" pkg-config "${pcname}"
	eend $?
}

src_prepare() {
	epatch "${FILESDIR}"/"${P}"-ode-libraries.patch
	epatch "${FILESDIR}"/"${P}"-ffmpeg-libraries.patch
	epatch "${FILESDIR}"/"${P}"-glfw-libraries.patch
}

src_compile() {
	if use doc ; then
		nant -t:mono-2.0 package
	else
		nant -t:mono-2.0 package-no-doc
	fi
}

src_install() {
	. "${FILESDIR}"/generate_pkgconfig.eblit

	#nant -t:mono-2.0 install
	mono_multilib_comply || die "Multilib compliance failed"

	generate_pkgconfig ../bin/*.dll || die "Generating pkgconfig file failed"

	dodoc $DOCS

	for file in ../bin/*.dll ; do
		egacinstall "$file" || die "Installing $file into GAC failed"
	done
}
