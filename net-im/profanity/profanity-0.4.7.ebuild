# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="A console based XMPP client"
HOMEPAGE="http://www.profanity.im/"
SRC_URI="http://www.profanity.im/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0/0.4"
KEYWORDS="~amd64"

IUSE="+expat notifications otr pgp test +themes xscreensaver"

# tests also need "stabber" and "libexpect", which are not in portage
DEPEND="net-libs/libstrophe:=
	net-misc/curl
	>=dev-libs/glib-2.26:2
	sys-libs/ncurses:=[unicode]
	dev-libs/openssl
	sys-apps/util-linux
	notifications? ( x11-libs/libnotify )
	otr? ( net-libs/libotr )
	pgp? ( app-crypt/gpgme:= )
	xscreensaver? (
		x11-libs/libXScrnSaver
		x11-libs/libX11 )
	expat? ( dev-libs/expat )
	!expat? ( dev-libs/libxml2 )"
RDEPEND="${DEPEND}"
DEPEND="${DEPEND}
	test? ( dev-util/cmocka )"

src_configure() {
	econf \
		$(use_enable notifications) \
		$(use_enable otr) \
		$(use_enable pgp) \
		$(use_with !expat libxml2) \
		$(use_with xscreensaver) \
		$(use_with themes)
}
