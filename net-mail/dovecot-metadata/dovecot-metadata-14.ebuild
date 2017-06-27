# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DOVECOT_VERSION=2.0

if [[ "${PV}" == *9999* ]]; then
	EHG_REPO_URI="http://hg.intevation.org/kolab/${MY_PN}/"
	EXTRA_ECLASS="${EXTRA_ECLASS} mercurial"
	KEYWORDS=""
	S="${WORKDIR}/${PN}"
else
	SRC_URI="http://hg.dovecot.org/${PN}-plugin/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~ia64 ~x86"
	S="${WORKDIR}/${PN}-plugin-v${PV}"
fi

inherit ${EXTRA_ECLASS}

DESCRIPTION="Metadata support for the Dovecot Secure IMAP server"
HOMEPAGE=""

LICENSE="LGPL-3+"
SLOT="0"

IUSE="static-libs"

DEPEND=">=net-mail/dovecot-${DOVECOT_VERSION}:="
RDEPEND="${DEPEND}"

DOCS="AUTHORS NEWS README"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		$( use_enable static-libs static )
}

src_install() {
	default

	use static-libs || find "${ED}"/usr/lib* -name '*.la' -delete
}
