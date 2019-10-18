# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A simple, lightweight C library for writing XMPP clients"
HOMEPAGE="http://strophe.im/libstrophe"
SRC_URI="https://github.com/strophe/${PN}/releases/download/${PV}/${P}.tar.gz"

LICENSE="|| ( MIT GPL-3 )"
SLOT="0/0.8"
KEYWORDS="~amd64"

IUSE="doc +expat libressl test"

RDEPEND="
	expat? ( dev-libs/expat )
	!expat? ( dev-libs/libxml2 )
	libressl? ( dev-libs/libressl:= )
	!libressl? ( dev-libs/openssl:0= )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	test? ( >=dev-libs/check-0.9.4 )"

DOCS=( ChangeLog )
PATCHES=( "${FILESDIR}/${PN}-0.9.2-libressl.patch" )

src_configure() {
	econf \
		--enable-tls \
		$(use_with !expat libxml2)
}

src_compile() {
	default
	if use doc; then
		doxygen || die
		HTML_DOCS=( docs/html/* )
	fi
}

src_install() {
	default
	use doc && dodoc -r examples
}
