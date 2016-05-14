# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="A minimal XMPP library written in C"
HOMEPAGE="http://strophe.im/libstrophe"
SRC_URI="https://github.com/strophe/libstrophe/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="|| ( MIT GPL-3 )"
SLOT="0/0.8"
KEYWORDS="~amd64"

IUSE="+expat test"

DEPEND="dev-libs/openssl
	expat? ( >=dev-libs/expat-2.0.0 )
	!expat? ( >=dev-libs/libxml2-2.7.0 )"
RDEPEND="${DEPEND}"
DEPEND="${DEPEND}
	test? ( >=dev-libs/check-0.9.4 )"

src_prepare() {
	epatch "${FILESDIR}/${P}"-fix-autoconf-libxml2.patch
	./bootstrap.sh || die
}

src_configure() {
	econf \
		$(use_with !expat libxml2)
}
