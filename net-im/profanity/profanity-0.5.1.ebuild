# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{3,4,5,6,7} pypy pypy3 )

inherit python-single-r1

DESCRIPTION="A console based XMPP client inspired by Irssi"
HOMEPAGE="https://profanity-im.github.io/"
SRC_URI="https://profanity-im.github.io/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0/0.4"
KEYWORDS="~amd64"

IUSE="icons libnotify otr gpg +plugins python test +themes xscreensaver"

REQUIRED_USE="python? ( plugins ${PYTHON_REQUIRED_USE} )"

# tests also need "stabber" and "libexpect", which are not in portage
DEPEND="
	dev-libs/expat
	dev-libs/glib
	dev-libs/openssl:0=
	net-libs/libstrophe:=
	net-misc/curl
	sys-apps/util-linux
	sys-libs/ncurses:=[unicode]
	sys-libs/readline:=
	gpg? ( app-crypt/gpgme:= )
	icons? ( x11-libs/gtk+:2 )
	libnotify? ( x11-libs/libnotify )
	otr? ( net-libs/libotr )
	xscreensaver? (
		x11-libs/libXScrnSaver
		x11-libs/libX11 )
	python? ( ${PYTHON_DEPS} )"
RDEPEND="${DEPEND}"
DEPEND="${DEPEND}
	test? ( dev-util/cmocka )"

src_configure() {
	econf \
		$(use_enable libnotify notifications) \
		$(use_enable otr) \
		$(use_enable gpg pgp) \
		$(use_enable plugins c-plugins) \
		$(use_enable python python-plugins) \
		$(use_with xscreensaver) \
		$(use_with themes)
}
