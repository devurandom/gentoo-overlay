# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

if [[ "${PV}" == *9999* ]] ; then
	live=mercurial
fi

inherit flag-o-matic multilib systemd versionator ${live}

if [[ "${PV}" == *9999* ]] ; then
	MY_PV="$(get_version_component_range 1-2)"
	[[ "${MY_PV}" == *9999* ]] && MY_PV=trunk
	EHG_REPO_URI=http://hg.prosody.im/"${MY_PV}"
	KEYWORDS=""
else
	MY_PV=$(replace_version_separator 3 '')
	MY_P="${PN}-${MY_PV}"
	SRC_URI="http://prosody.im/tmp/${MY_PV}/${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~x86"
	S=${WORKDIR}/${MY_P}
fi

DESCRIPTION="Prosody is a flexible communications server for Jabber/XMPP written in Lua"
HOMEPAGE="http://prosody.im/"

LICENSE="MIT"
SLOT="0"
IUSE="ipv6 luajit libevent libressl migrator mysql postgres sqlite ssl zlib"

DEPEND="net-im/jabber-base
		dev-lua/LuaBitOp
		!luajit? ( || ( dev-lang/lua:5.1 >=dev-lang/lua-5.1:0 ) )
		luajit? ( dev-lang/luajit:2 )
		>=net-dns/libidn-1.1
		!libressl? ( dev-libs/openssl:0 )
		libressl? ( dev-libs/libressl:= )"
RDEPEND="${DEPEND}
		>=dev-lua/luaexpat-1.3.0
		dev-lua/luafilesystem
		ipv6? ( >=dev-lua/luasocket-3 )
		!ipv6? ( dev-lua/luasocket )
		libevent? ( >=dev-lua/luaevent-0.4.3 )
		mysql? ( dev-lua/luadbi[mysql] )
		postgres? ( dev-lua/luadbi[postgres] )
		sqlite? ( dev-lua/luadbi[sqlite] )
		ssl? ( dev-lua/luasec )
		zlib? ( dev-lua/lua-zlib )"

JABBER_ETC="/etc/jabber"
JABBER_SPOOL="/var/spool/jabber"

src_prepare() {
	default
	epatch "${FILESDIR}/${PN}-0.10.0-cfg.lua.patch"
	sed -i -e "s!MODULES = \$(DESTDIR)\$(PREFIX)/lib/!MODULES = \$(DESTDIR)\$(PREFIX)/$(get_libdir)/!" \
		-e "s!SOURCE = \$(DESTDIR)\$(PREFIX)/lib/!SOURCE = \$(DESTDIR)\$(PREFIX)/$(get_libdir)/!" \
		-e "s!INSTALLEDSOURCE = \$(PREFIX)/lib/!INSTALLEDSOURCE = \$(PREFIX)/$(get_libdir)/!" \
		-e "s!INSTALLEDMODULES = \$(PREFIX)/lib/!INSTALLEDMODULES = \$(PREFIX)/$(get_libdir)/!" \
		GNUmakefile || die
}

src_configure() {
	# the configure script is handcrafted (and yells at unknown options)
	# hence do not use 'econf'
	luajit=""
	if use luajit; then
		luajit="--runwith=luajit"
	fi
	./configure \
		--ostype=linux \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--sysconfdir="${JABBER_ETC}" \
		--datadir="${JABBER_SPOOL}" \
		--with-lua-include=/usr/include \
		--with-lua-lib=/usr/$(get_libdir)/lua \
		--add-cflags="${CFLAGS}" \
		--add-ldflags="${LDFLAGS}" \
		--c-compiler="$(tc-getCC)" \
		--linker="$(tc-getCC)" \
		${luajit} \
		|| die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install

	emake DESTDIR="${D}" -C tools/migration install

	systemd_dounit "${FILESDIR}/${PN}".service
	systemd_newtmpfilesd "${FILESDIR}/${PN}".tmpfilesd "${PN}".conf
	newinitd "${FILESDIR}/${PN}".initd-r2 ${PN}

	keepdir "${JABBER_SPOOL}"/http_upload
	fowners jabber:jabber "${JABBER_SPOOL}"
	fperms 0700 "${JABBER_SPOOL}"
}

src_test() {
	cd tests || die
	./run_tests.sh || die
}
