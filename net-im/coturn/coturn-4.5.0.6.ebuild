# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

[[ "${PV}" = *9999* ]] && live=git-r3
inherit eutils user systemd tmpfiles ${live}

if [[ "${PV}" = *9999* ]] ; then
	EGIT_REPO_URI="https://github.com/${PN}/${PN}.git"
	KEYWORDS="-*"
else
	KEYWORDS="~x86 ~amd64"
	SRC_URI="mirror://github/${PN}/${PN}/${P}.tar.gz"
fi

DESCRIPTION="A VoIP media traffic NAT traversal server and gateway"
HOMEPAGE="https://github.com/${PN}/${PN}"

LICENSE="BSD"
SLOT="0"

IUSE_BACKENDS="mongodb mysql postgres redis sqlite"
IUSE="${IUSE_BACKENDS} +gcm +dtls +sctp +tls"

RDEPEND="dev-libs/libevent[ssl]
	>=dev-libs/openssl-1:=
	mongodb? ( dev-libs/mongo-c-driver )
	mysql? ( virtual/mysql )
	postgres? ( dev-db/posggresql:= )
	redis? ( dev-libs/hiredis:= )
	sqlite? ( dev-libs/sqlite )"
DEPEND="${RDEPEND}"

pkg_setup() {
	enewgroup turnserver
	enewuser turnserver -1 -1 /var/lib/turnserver turnserver
}

src_prepare() {
	default
	sed -i configure \
		-e 's/TMPDIR=.*$/:/' \
		|| die
	sed 's:#log-file=/var/tmp/turn.log:log-file=/var/log/turnserver.log:' \
	    -i "${S}/examples/etc/turnserver.conf"  || die "sed for logdir failed"
	sed 's:#simple-log:simple-log:' -i "${S}/examples/etc/turnserver.conf" \
	    || die "sed for simple-log failed"
}

src_configure() {
	for v in \
		MORECMD=cat \
		$(use mongodb || echo TURN_NO_MONGO=1) \
		$(use mysql || echo TURN_NO_MYSQL=1) \
		$(use postgres || echo TURN_NO_PQ=1) \
		$(use redis || echo TURN_NO_HIREDIS=1) \
		$(use sqlite || echo TURN_NO_SQLITE=1) \
		$(use gcm || echo TURN_NO_GCM=1) \
		$(use sctp || echo TURN_NO_SCTP=1) \
		$(use dtls || echo TURN_NO_DTLS=1) \
		$(use tls || echo TURN_NO_TLS=1) \
	; do
		export "${v}"
	done
	econf $(use_with sqlite)
}

src_install() {
	default
	newinitd "${FILESDIR}/turnserver.init" turnserver
	insinto /etc/logrotate.d
	newins "${FILESDIR}/logrotate.${PN}" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"
	dotmpfiles "${FILESDIR}/${PN}.conf"
}

pkg_postinst() {
	tmpfiles_process "${PN}.conf"
	elog "You need to copy /etc/turnserver.conf.default to"
	elog "/etc/turnserver.conf and do your settings there."
}
