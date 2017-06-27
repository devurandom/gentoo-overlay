# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit distutils

DESCRIPTION="A robust toolkit for Python milters that wraps the C libmilter library"
HOMEPAGE="http://www.bmsi.com/python/milter.html"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ia64"

IUSE="spf"

DEPEND="dev-lang/python[threads]
	mail-filter/libmilter"
RDEPEND="${DEPEND}"
