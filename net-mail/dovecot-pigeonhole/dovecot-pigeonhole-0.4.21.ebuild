# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

case "${PV}" in
	*9999*) EXTRA_ECLASS="${EXTRA_ECLASS} autotools git-r3" ;;
	*_pre*|*_rc*) EXTRA_ECLASS="${EXTRA_ECLASS} autotools" ;;
esac

inherit versionator ${EXTRA_ECLASS}

if version_is_at_least 0.4 ; then
	DOVECOT_MAJOR_MINOR_VERSION=2.2
else
	die "Unexpected pigeonhole version: ${PV}"
fi

if version_is_at_least 0.4.17 ; then
	DOVECOT_VERSION_ATLEAST=2.2.28
else
	DOVECOT_VERSION_ATLEAST="${DOVECOT_MAJOR_MINOR_VERSION}"
fi

MY_PN="${PN/dovecot/dovecot-${DOVECOT_MAJOR_MINOR_VERSION}}"
MY_PV="${PV/_/.}"
MY_P="${MY_PN}-${MY_PV}"

case "${PV}" in
	*9999*)
		EGIT_REPO_URI="https://github.com/dovecot/pigeonhole.git"
		KEYWORDS=""
		;;
	*_pre*|*_rc*)
		SRC_URI="mirror://github/dovecot/pigeonhole/${MY_P}.tar.gz"
		S="${WORKDIR}/pigeonhole-${MY_PV}"
		KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~sparc ~x86"
		;;
	*)
		SRC_URI="https://pigeonhole.dovecot.org/releases/${DOVECOT_MAJOR_MINOR_VERSION}/${MY_P}.tar.gz"
		S="${WORKDIR}/${MY_P}"
		KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~sparc ~x86"
		;;
esac

DESCRIPTION="Sieve support for the Dovecot Secure IMAP server"
HOMEPAGE="https://pigeonhole.dovecot.org/"

SLOT="0"
LICENSE="LGPL-2.1"

IUSE="doc +managesieve static-libs unfinished"

DEPEND=">=net-mail/dovecot-${DOVECOT_VERSION_ATLEAST}:="
RDEPEND="${DEPEND}"

if [[ "${PV}" == *9999* ]] || [[ "${PV}" == *_pre* ]] || [[ "${PV}" == *_rc* ]] ; then
src_prepare() {
	default
	eautoreconf
}
fi

src_configure() {
	econf \
		--localstatedir="${EPREFIX}/var" \
		--enable-shared \
		$( use_enable static-libs static ) \
		$( use_with doc docs ) \
		$( use_with managesieve ) \
		$( use_with unfinished unfinished-features )
}

src_install() {
	default

	insinto /etc/dovecot/conf.d
	for file in doc/example-config/conf.d/*.conf ; do
		doins "${file}" || die
	done

	# mailbase does not provide a sieve pam file
	if use managesieve ; then
		dosym imap /etc/pam.d/sieve || die
	fi

	use static-libs || find "${ED}"/usr/lib* -name '*.la' -delete

	if use doc ; then
		docinto sieve/rfc
		dodoc doc/rfc/*.txt

		docinto sieve/devel
		dodoc doc/devel/DESIGN

		docinto plugins
		dodoc doc/plugins/*.txt

		docinto extensions
		dodoc doc/extensions/*.txt

		docinto locations
		dodoc doc/locations/*.txt
		doman doc/man/*.{1,7}
	fi
}
