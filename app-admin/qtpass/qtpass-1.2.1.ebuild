# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_P="QtPass-${PV}"

inherit qmake-utils desktop

DESCRIPTION="multi-platform GUI for pass, the standard unix password manager"
HOMEPAGE="https://qtpass.org/"
SRC_URI="https://github.com/IJHack/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
DOCS=( FAQ.md README.md CONTRIBUTING.md )
S="${WORKDIR}/${MY_P}"

RDEPEND="app-admin/pass
	dev-qt/qtcore:5
	dev-qt/qtgui:5[xcb]
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
	net-misc/x11-ssh-askpass"
DEPEND="${RDEPEND}
	dev-qt/linguist-tools:5"

PATCHES=(
	"${FILESDIR}/${P}"-2c7fccaf99a6c1e70944f058060ac5bd29e2680e.patch
)

src_configure() {
	eqmake5 PREFIX="${D}"/usr
}

src_compile() {
	emake sub-main
}

src_install() {
	emake DESTDIR="${D}" sub-main-install_subtargets

	doman ${PN}.1

	insinto /usr/share/applications
	doins "${PN}.desktop"

	newicon artwork/icon.svg "${PN}-icon.svg"
}
