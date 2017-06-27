# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="3"

PYTHON_DEPEND="2"
#SUPPORT_PYTHON_ABIS="0"
#RESTRICT_PYTHON_ABIS="3.*"

inherit eutils python

MY_PN="pymsnt"
MY_PV="${PV/_p*/}"
MY_PATCHV="${PV/*_p/}"

DESCRIPTION="Python based jabber transport for MSN"
HOMEPAGE="http://pymsnt.sharesource.org/"
SRC_URI="http://msn-transport.jabberstudio.org/tarballs/${MY_PN}-${MY_PV}.tar.gz
	${PN}-${MY_PV}-patches-${MY_PATCHV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc x86 ~ia64"
IUSE=""

DEPEND="net-im/jabber-base"
RDEPEND="${DEPEND}
	>=dev-python/twisted-2.5.0
	>=dev-python/twisted-words-0.5.0
	>=dev-python/twisted-web-0.7.0
	>=dev-python/imaging-1.1"

S=${WORKDIR}/${MY_PN}-${MY_PV}

pkg_setup() {
	python_set_active_version 2
}

src_prepare() {
	cd "${S}"
	EPATCH_SOURCE="${WORKDIR}/${PN}-${MY_PV}-patches-${MY_PATCHV}/" \
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch

	python_convert_shebangs --recursive 2 .
}

src_install() {
	local inspath=$(python_get_sitedir)/${PN}

	insinto ${inspath}
	doins -r data src
	newins PyMSNt.py ${PN}.py

	insinto /etc/jabber
	newins config-example.xml ${PN}.xml
	fperms 600 /etc/jabber/${PN}.xml
	fowners jabber:jabber /etc/jabber/${PN}.xml
	dosed \
		"s:<!-- <spooldir>[^\<]*</spooldir> -->:<spooldir>/var/spool/jabber</spooldir>:" \
		/etc/jabber/${PN}.xml
	dosed \
		"s:<pid>[^\<]*</pid>:<pid>/var/run/jabber/${PN}.pid</pid>:" \
		/etc/jabber/${PN}.xml
	dosed \
		"s:<host>[^\<]*</host>:<host>example.org</host>:" \
		/etc/jabber/${PN}.xml
	dosed \
		"s:<jid>msn</jid>:<jid>msn.example.org</jid>:" \
		/etc/jabber/${PN}.xml

	newinitd "${FILESDIR}/${PN}-0.11.2-initd" ${PN}
	dosed "s:PYTHON:$(PYTHON --absolute-path):" /etc/init.d/${PN}
	dosed "s:INSPATH:${inspath}:" /etc/init.d/${PN}
}

pkg_postinst() {
	python_mod_optimize ${PN}

	elog "A sample configuration file has been installed in /etc/jabber/${PN}.xml."
	elog "Please edit it and the configuration of your Jabber server to match."
}

pkg_postrm() {
	python_mod_cleanup ${PN}
}
