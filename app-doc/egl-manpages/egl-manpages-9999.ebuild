# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

ESVN_REPO_URI="https://cvs.khronos.org/svn/repos/registry/trunk/public/egl/sdk/docs/man/"
EGIT_REPO_URI="https://github.com/KhronosGroup/EGL-Registry.git"

DESCRIPTION="OpenGL man pages"
HOMEPAGE="http://www.opengl.org/wiki/Getting_started/XML_Toolchain_and_Man_Pages"

LICENSE="SGI-B-2.0"
SLOT="0"
KEYWORDS=""
IUSE="+man html"

DEPEND="dev-libs/libxslt
	app-text/docbook-mathml-dtd
	html? ( dev-lang/python )
	man? ( app-text/docbook-xsl-stylesheets )"
RDEPEND="man? ( virtual/man )"

S="${WORKDIR}/${P}/sdk/docs/man"

src_prepare() {
	if use man ; then
		einfo "Fixing author ..."

		for f in egl*.xml; do
			xsltproc --nonet -o fixed-"${f}" \
				"${FILESDIR}"/fix-author-manual.xsl \
				"${f}" || die
			mv fixed-"${f}" "${f}" || die
		done
	fi

	eapply_user
}

src_compile() {
	if use man ; then
		einfo "Compiling manual ..."

		for f in egl*.xml; do
			xsltproc --nonet --noout \
				/usr/share/sgml/docbook/xsl-stylesheets/manpages/docbook.xsl \
				"${f}" || die
		done
	fi

	if use html ; then
		einfo "Compiling HTML manual ..."

		cd xhtml
		emake ROOT="${S}" || die "Failed creating HTML manual"
	fi
}

src_install() {
	if use man ; then
		doman *.3G || die
	fi

	if use html ; then
		dohtml -a xml,html "${S}"/xhtml/* || die
	fi
}
