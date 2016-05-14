# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

MODULE_AUTHOR="BRONDSEM"
inherit perl-module

DESCRIPTION="SpamAssassin plugin to score mail based on OpenPGP signatures."

IUSE="test"

SLOT="0"
LICENSE="Apache-2.0"
KEYWORDS="~amd64 ~x86 ~ppc"
RDEPEND="dev-perl/Mail-GPG
		 mail-filter/spamassassin"
DEPEND="${RDEPEND}
		test? ( dev-perl/Test-Pod )"

SRC_TEST="do"

src_install() {
	perl-module_src_install
	insinto /etc/mail/spamassassin
	doins "${FILESDIR}"/init_openpgp.pre
	doins "${FILESDIR}"/openpgp.cf
}

pkg_postinst() {
	elog "To use this package:"
	elog "1. Add 'keyserver-options auto-key-retrieve timeout=5' and"
	elog "    'keyserver hkp://wwwkeys.eu.pgp.net' to"
	elog "    /var/lib/spamassassin/.gnupg/options"
	elog "2. Enable the plugin by uncommenting the loadplugin entry in"
	elog "    /etc/mail/spamassassin/init_openpgp.pre"
	elog "3. Restart spamd"
}
