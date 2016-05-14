# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="The littleutils are a collection of small and simple utilities"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.xz"
HOMEPAGE="http://sourceforge.net/projects/littleutils/"

KEYWORDS="~x86 ~amd64"
LICENSE="GPL-2"
SLOT="0"
IUSE="png"

DEPEND="
	png? ( media-gfx/pngcrush
		media-gfx/pngrewrite )"

src_install () {
	einstall

	# Following are colliding with app-admin/realpath:
	rm "${D}/usr/bin/realpath"
	rm "${D}/usr/share/man/man1/realpath.1"
}
