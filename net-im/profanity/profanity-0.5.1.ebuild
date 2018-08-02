# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{3,4,5,6,7} pypy pypy3 )

inherit python-single-r1

DESCRIPTION="A console based XMPP client"
HOMEPAGE="http://www.profanity.im/"
SRC_URI="http://www.profanity.im/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0/0.4"
KEYWORDS="~amd64"

IUSE="icons notifications otr pgp +plugins python test +themes xscreensaver"

REQUIRED_USE="python? ( plugins ${PYTHON_REQUIRED_USE} )"

# tests also need "stabber" and "libexpect", which are not in portage
DEPEND="net-libs/libstrophe:=
	net-misc/curl
	>=dev-libs/glib-2.26:2
	sys-libs/ncurses:=[unicode]
	dev-libs/openssl:=
	sys-apps/util-linux
	sys-libs/readline:=
	icons? ( >=x11-libs/gtk+-2.24.10:2 )
	notifications? ( x11-libs/libnotify )
	otr? ( net-libs/libotr )
	pgp? ( app-crypt/gpgme:= )
	xscreensaver? (
		x11-libs/libXScrnSaver
		x11-libs/libX11 )
	python? ( ${PYTHON_DEPS} )"
RDEPEND="${DEPEND}"
DEPEND="${DEPEND}
	test? ( dev-util/cmocka )"

src_configure() {
	econf \
		$(use_enable notifications) \
		$(use_enable otr) \
		$(use_enable pgp) \
		$(use_enable plugins c-plugins) \
		$(use_enable python python-plugins) \
		$(use_with xscreensaver) \
		$(use_with themes)
}
