# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eapi7-ver ssl-cert systemd user

MY_P="${P/_/.}"
major_minor="$(ver_cut 1-2)"
prerelease="${PV/*_/}"
prerelease="${prerelease%%[[:digit:]]*}"

SRC_URI="http://dovecot.org/releases/${major_minor}/${prerelease}/${MY_P}.tar.gz"
DESCRIPTION="An IMAP and POP3 server written with security primarily in mind"
HOMEPAGE="https://www.dovecot.org/"

SLOT="0/${PV}"
LICENSE="LGPL-2.1 MIT"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sparc ~x86"

IUSE_DOVECOT_AUTH="bsdauth kerberos ldap lua nss pam +shadow sia vpopmail"
IUSE_DOVECOT_COMPRESS="bzip2 lzma lz4 zlib"
IUSE_DOVECOT_DB="mysql postgres sqlite"
IUSE_DOVECOT_SSL="gnutls libressl +openssl"
IUSE_DOVECOT_OTHER="boehm-gc caps debug doc hardened ipv6 lucene selinux sodium solr static-libs suid tcpd textcat"

IUSE="${IUSE_DOVECOT_AUTH} ${IUSE_DOVECOT_COMPRESS} ${IUSE_DOVECOT_DB} ${IUSE_DOVECOT_SSL} ${IUSE_DOVECOT_OTHER}"

REQUIRED_USE="^^ ( gnutls libressl openssl )"

DEPEND="boehm-gc? ( dev-libs/boehm-gc )
	bzip2? ( app-arch/bzip2 )
	caps? ( sys-libs/libcap )
	gnutls? ( net-libs/gnutls )
	kerberos? ( virtual/krb5 )
	ldap? ( net-nds/openldap )
	libressl? ( dev-libs/libressl )
	lua? ( dev-lang/lua:* )
	lucene? ( >=dev-cpp/clucene-2.3 )
	lzma? ( app-arch/xz-utils )
	lz4? ( app-arch/lz4 )
	mysql? ( virtual/mysql )
	nss? ( dev-libs/nss )
	openssl? ( dev-libs/openssl:0 )
	pam? ( sys-libs/pam )
	postgres? ( dev-db/postgresql:* !dev-db/postgresql[ldap,threads] )
	selinux? ( sec-policy/selinux-dovecot )
	sodium? ( dev-libs/sodium )
	solr? ( net-misc/curl dev-libs/expat )
	sqlite? ( dev-db/sqlite:* )
	tcpd? ( sys-apps/tcp-wrappers )
	textcat? ( app-text/libexttextcat )
	vpopmail? ( net-mail/vpopmail )
	zlib? ( sys-libs/zlib )
	virtual/libiconv
	dev-libs/icu:=
	dev-libs/libbsd"

RDEPEND="${DEPEND}
	net-mail/mailbase"

S=${WORKDIR}/${MY_P}

DOCS="AUTHORS NEWS README TODO"

pkg_setup() {
	# default internal user
	enewgroup dovecot 97
	enewuser dovecot 97 -1 /dev/null dovecot

	# default login user
	enewuser dovenull -1 -1 /dev/null

	# add "mail" group for suid'ing. Better security isolation.
	if use suid; then
		enewgroup mail
	fi
}

src_configure() {
	local conf=""

	if use postgres || use mysql || use sqlite; then
		conf="${conf} --with-sql"
	fi

	if use gnutls; then
		conf="${conf} --with-ssl=gnutls"
	else
		conf="${conf} --with-ssl=openssl"
	fi

	# turn valgrind tests off. Bug #340791
	# Enable all storages: https://www.mail-archive.com/dovecot@dovecot.org/msg69576.html
	VALGRIND=no econf \
		--localstatedir="${EPREFIX}/var" \
		--runstatedir="${EPREFIX}/run" \
		--with-icu \
		--with-libbsd \
		--with-moduledir="${EPREFIX}/usr/$(get_libdir)/dovecot" \
                --with-rundir="${EPREFIX}/run/dovecot" \
		--with-statedir="${EPREFIX}/var/lib/dovecot" \
		--without-stemmer \
		--with-storages="cydir imapc maildir mbox mdbox pop3c sdbox" \
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)" \
		--disable-rpath \
		$( use_with boehm-gc gc ) \
		$( use_with bsdauth ) \
		$( use_with bzip2 bzlib ) \
		$( use_with caps libcap ) \
		$( use_with doc docs ) \
		$( use_with hardened hardening ) \
		$( use_with kerberos gssapi ) \
		$( use_with ldap ) \
		$( use_with lua ) \
		$( use_with lucene ) \
		$( use_with lz4 ) \
		$( use_with lzma ) \
		$( use_with mysql ) \
		$( use_with nss ) \
		$( use_with pam ) \
		$( use_with postgres pgsql ) \
		$( use_with shadow ) \
		$( use_with sia ) \
		$( use_with sodium ) \
		$( use_with solr ) \
		$( use_with sqlite ) \
		$( use_with tcpd libwrap ) \
		$( use_with textcat ) \
		$( use_with vpopmail ) \
		$( use_with zlib ) \
		$( use_enable debug asserts ) \
		$( use_enable debug devel-checks ) \
		$( use_enable static-libs static ) \
		${conf}
}

src_install () {
	default

	# insecure:
	# use suid && fperms u+s /usr/libexec/dovecot/deliver
	# better:
	if use suid;then
		einfo "Changing perms to allow deliver to be suided"
		fowners root:mail "${EPREFIX}/usr/libexec/dovecot/dovecot-lda"
		fperms 4750 "${EPREFIX}/usr/libexec/dovecot/dovecot-lda"
	fi

	newinitd "${FILESDIR}"/dovecot.init-r4 dovecot

	rm -rf "${ED}"/usr/share/doc/dovecot

	dodoc doc/*.{txt,cnf,xml,sh}
	docinto example-config
	dodoc doc/example-config/*.{conf,ext}
	docinto example-config/conf.d
	dodoc doc/example-config/conf.d/*.{conf,ext}
	docinto wiki
	dodoc doc/wiki/*
	doman doc/man/*.{1,7}

	# Create the dovecot.conf file from the dovecot-example.conf file that
	# the dovecot folks nicely left for us....
	local conf="${ED}/etc/dovecot/dovecot.conf"
	local confd="${ED}/etc/dovecot/conf.d"

	insinto /etc/dovecot
	doins doc/example-config/*.{conf,ext}
	insinto /etc/dovecot/conf.d
	doins doc/example-config/conf.d/*.{conf,ext}
	fperms 0600 "${EPREFIX}"/etc/dovecot/dovecot-{ldap,sql}.conf.ext

	# Update ssl cert locations
	sed -i -e 's:^#ssl = yes:ssl = yes:' "${confd}/10-ssl.conf" \
		|| die "ssl conf failed"
	sed -i -e 's:^ssl_cert =.*:ssl_cert = </etc/ssl/dovecot/server.pem:' \
		-e 's:^ssl_key =.*:ssl_key = </etc/ssl/dovecot/server.key:' \
		"${confd}/10-ssl.conf" \
		|| die "failed to update SSL settings in 10-ssl.conf"

	# We're using pam files (imap and pop3) provided by mailbase
	if use pam; then
		sed -i -e '/driver = pam/,/^[ \t]*}/ s|#args = dovecot|args = "\*"|' \
			"${confd}/auth-system.conf.ext" \
			|| die "failed to update PAM settings in auth-system.conf.ext"
		sed -i -e 's/#!include auth-system.conf.ext/!include auth-system.conf.ext/' \
			"${confd}/10-auth.conf" \
			|| die "failed to update PAM settings in 10-auth.conf"
	fi

	# Disable ipv6 if necessary
	if ! use ipv6; then
		sed -i -e 's/^#listen = \*, ::/listen = \*/g' "${conf}" \
			|| die "failed to update listen settings in dovecot.conf"
	fi

	# Install SQL configuration
	if use mysql || use postgres; then
		sed -i -e 's/#!include auth-sql.conf.ext/!include auth-sql.conf.ext/' \
			"${confd}/10-auth.conf" \
			|| die "failed to update SQL settings in 10-auth.conf"
	fi

	# Install LDAP configuration
	if use ldap; then
		sed -i -e 's/#!include auth-ldap.conf.ext/!include auth-ldap.conf.ext/' \
			"${confd}/10-auth.conf" \
			|| die "failed to update ldap settings in 10-auth.conf"
	fi

	if use vpopmail; then
		sed -i -e 's/#!include auth-vpopmail.conf.ext/!include auth-vpopmail.conf.ext/' \
			"${confd}/10-auth.conf" \
			|| die "failed to update vpopmail settings in 10-auth.conf"
	fi

	use static-libs || find "${ED}"/usr/lib* -name '*.la' -delete
}

pkg_postinst() {
	# Let's not make a new certificate if we already have one
	if ! [[ -e "${ROOT}"/etc/ssl/dovecot/server.pem && \
		-e "${ROOT}"/etc/ssl/dovecot/server.key ]]; then
		einfo "Creating SSL certificate"
		SSL_ORGANIZATION="${SSL_ORGANIZATION:-Dovecot IMAP Server}"
		install_cert /etc/ssl/dovecot/server
	fi

	elog "Please read http://wiki2.dovecot.org/Upgrading/${major_minor} for upgrade notes."
}
