# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils qt4-r2

DESCRIPTION="Graphical user interface for the distributed version control system monotone"
HOMEPAGE="http://guitone.thomaskeller.biz/"
SRC_URI="http://guitone.thomaskeller.biz/releases/${PV}/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=x11-libs/qt-4.2
	>=dev-util/monotone-0.40"
RDEPEND="${DEPEND}"

src_compile() {
	lrelease ${PN}.pro || die "lrelease failed"
	emake || die "emake failed"
}

src_install() {
	dobin bin/${PN}
}
