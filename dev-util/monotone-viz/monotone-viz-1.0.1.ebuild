# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Monotone-viz is a small GTK+ application that visualizes monotone ancestry graphs."
SRC_URI="http://oandrieu.nerim.net/${PN}/${P}-nolablgtk.tar.gz"
HOMEPAGE="http://oandrieu.nerim.net/monotone-viz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=dev-util/monotone-0.26
	>=dev-libs/openssl-0.9.8
	>=dev-db/sqlite-3.3.0
	>=dev-ml/lablgtk-2.6.0"

S="${WORKDIR}/${P}"

pkg_setup() {
	if ! built_with_use dev-ml/lablgtk gnomecanvas ; then
		eerror "You need to build lablgtk with gnomecanvas support"
		eerror "Please remerge dev-ml/lablgtk with USE=gnomecanvas"
		die "lablgtk without gnomecanvas detected"
	fi
}

src_compile() {
	econf \
		--with-shared-sqlite \
		--without-local-lablgtk \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc INSTALL NEWS README
}
