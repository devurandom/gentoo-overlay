# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=3

inherit qt4-r2

DESCRIPTION="Off-the-Record Messaging plugin for Psi"
HOMEPAGE="http://public.tfh-berlin.de/~s30935/"
SRC_URI="http://public.tfh-berlin.de/~s30935/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-*"

IUSE=""

DEPEND=">=net-im/psi-9999[extras]
	>=net-libs/libotr-3.2.0
	app-text/htmltidy"
RDEPEND="${DEPEND}"
