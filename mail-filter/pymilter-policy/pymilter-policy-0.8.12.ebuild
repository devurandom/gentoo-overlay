# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils

MY_PN="milter"

DESCRIPTION="Flexible milter built using pymilter that emphasizes authentication"
HOMEPAGE="http://www.bmsi.com/python/policy.html"
SRC_URI="mirror://sourceforge/pymilter/${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ia64"

IUSE="spf srs"

DEPEND="dev-python/pymilter
	spf? ( dev-python/pyspf )
	srs? ( dev-python/pysrs )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}"

pkg_setup() {
    enewgroup milter
    # mail-milter/spamass-milter creates milter user with this home directory
    # For consistency reasons, milter user must be created here with this home directory
    # even though this package doesn't need a home directory for this user (#280571)
    enewuser milter -1 -1 /var/lib/milter milter
}

src_prepare() {
	einfo "Adjusting default config ..."
	sed -i \
		-e 's/^[[:space:]]*name[[:space:]]*=.*$/name = spfmilter/' \
		-e 's/^[[:space:]]*socketname[[:space:]]*=.*$/socketname = \/var\/run\/milter\/spfmilter.sock/' \
		spfmilter.cfg || die
	eend $?
	einfo "Adjusting config directories ..."
	sed -i \
		-e "s:/etc/mail/pymilter.cfg:/etc/mail/${PN}/milter.cfg:" \
		-e "s:/etc/mail/spfmilter.cfg:/etc/mail/${PN}/spfmilter.cfg:" \
		bms.py spfmilter.py || die
	eend $?
	einfo "Fixing script interpreters ..."
	sed -i \
		-e '1i\#!/usr/bin/python' \
		bms.py spfmilter.py rejects.py report.py || die
	eend $?
}

src_compile() {
	einfo "Nothing to compile"
}

src_install() {
	dodoc HOWTO

	insinto "/etc/mail/${PN}"
	doins milter.cfg spfmilter.cfg

	insinto "/var/lib/milter/${PN}"
	doins fail.txt neutral.txt permerror.txt quarantine.txt softfail.txt strike3.txt temperror.txt

	keepdir /var/log/milter
	fowners milter:milter /var/log/milter

	keepdir /var/run/milter
	fowners milter:milter /var/run/milter

	exeinto /usr/bin
	newexe bms.py pymilter-policy-milter
	newexe spfmilter.py pymilter-policy-spfmilter
	newexe rejects.py pymilter-policy-rejects
	newexe report.py pymilter-policy-report

	newinitd "${FILESDIR}/spfmilter.initd" spfmilter
}
