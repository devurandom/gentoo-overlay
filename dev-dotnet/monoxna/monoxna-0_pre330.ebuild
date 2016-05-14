# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

ESVN_REPO_URI="http://monoxna.googlecode.com/svn/trunk"
ESVN_REVISION="330"
inherit eutils subversion mono

DESCRIPTION="Cross platform implementation of the XNA gaming framework"
HOMEPAGE="http://www.monoxna.org/"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

RDEPEND=">=dev-lang/mono-2.0
	dev-dotnet/taoframework"
DEPEND="${DEPEND}
	dev-util/monodevelop"

CONFIG="Release"

src_prepare() {
	epatch "${FILESDIR}/${P}"-gdk-sharp-2.0.patch
}

src_compile() {
	mdtool build --configuration:"${CONFIG}" || die "Build failed"
}

src_install() {
	. "${FILESDIR}"/generate_pkgconfig.eblit

	# Something overrides the configuration during build phase
	CONFIG=Debug_Dotnet

	local dll dlllist
	for dll in bin/"${CONFIG}"/*.dll ; do
		# MonoDevelop.Xna has no strong name, hence cannot be installed into GAC
		[[ "${dll}" = "bin/${CONFIG}/MonoDevelop.Xna.dll" ]] && continue

		dlllist="${dlllist} ${dll}"

		egacinstall "${dll}" || die "Installing ${project} into GAC failed"
	done
    generate_pkgconfig ${dlllist} || die "Generating pkgconfig file failed"
}
