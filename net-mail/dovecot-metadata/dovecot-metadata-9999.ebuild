# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

if [[ "${PV}" == *9999* ]]; then
	EHG_REPO_URI="http://hg.intevation.org/kolab/${MY_PN}/"
	EXTRA_ECLASS="${EXTRA_ECLASS} mercurial"
	KEYWORDS=""
	S="${WORKDIR}/${PN}"
else
	SRC_URI="${P}.tar.gz"
	KEYWORDS="~x86 ~amd64 ~ia64"
fi

inherit ${EXTRA_ECLASS}

DESCRIPTION="Metadata support for the Dovecot Secure IMAP server"
HOMEPAGE=""

LICENSE="LGPL-3+"
SLOT="0"

IUSE="static-libs"

DEPEND=">=net-mail/dovecot-2.1:="
RDEPEND="${DEPEND}"

DOCS="AUTHORS NEWS README"

if [[ "${PV}" == *9999* ]]; then
src_prepare() {
	einfo "Running autogen ..."
	./autogen.sh || die "autogen.sh failed"
}
fi

src_configure() {
	econf \
		$( use_enable static-libs static )
}

src_install() {
	default

	use static-libs || find "${ED}"/usr/lib* -name '*.la' -delete
}
