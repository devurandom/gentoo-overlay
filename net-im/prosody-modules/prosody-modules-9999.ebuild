# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils mercurial multilib

EHG_REPO_URI="https://hg.prosody.im/prosody-modules/"

# Keep in sync with mod_admin_web/admin_web/get_deps.sh
JQUERY_VERSION="1.10.2"
STROPHE_VERSION="1.1.2"
BOOTSTRAP_VERSION="1.4.0"
ADHOC_COMMITISH="87bfedccdb91e2ff7cfb165e989e5259c155b513"

DESCRIPTION="non-core, unofficial and/or experimental plugins for Prosody"
HOMEPAGE="https://hg.prosody.im/prosody-modules/"
SRC_URI="admin_web? (
	http://code.jquery.com/jquery-${JQUERY_VERSION}.min.js
	https://raw.github.com/strophe/strophe.im/gh-pages/strophejs/downloads/strophejs-${STROPHE_VERSION}.tar.gz
	https://raw.github.com/twbs/bootstrap/v${BOOTSTRAP_VERSION}/bootstrap.min.css -> bootstrap-${BOOTSTRAP_VERSION}.min.css
	http://git.babelmonkeys.de/?p=adhocweb.git;a=blob_plain;f=js/adhoc.js;hb=${ADHOC_COMMITISH} -> adhoc-${ADHOC_COMMITISH}.js )"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~ia64"

IUSE="admin_web avatar ldap pam proctitle"
DEPEND="sys-apps/findutils"
RDEPEND="net-im/prosody
	avatar? ( virtual/imagemagick-tools[png] )
	ldap? ( dev-lua/lualdap )
	pam? (
		dev-lua/lua-pam
		dev-lua/luaposix
	)
	proctitle? ( dev-lua/lua-proctitle )"

src_unpack() {
	mercurial_src_unpack
	if use admin_web ; then
		local admin_web_www="${S}"/mod_admin_web/admin_web/www_files

		unpack "strophejs-${STROPHE_VERSION}.tar.gz"
		cp strophejs-"${STROPHE_VERSION}"/strophe.min.js "${admin_web_www}"/js || die
		cp "${DISTDIR}"/jquery-"${JQUERY_VERSION}".min.js "${admin_web_www}"/js || die
		cp "${DISTDIR}"/adhoc-"${ADHOC_COMMITISH}".js "${admin_web_www}"/js/adhoc.js || die
		cp "${DISTDIR}"/bootstrap-"${BOOTSTRAP_VERSION}".min.css "${admin_web_www}"/css || die
	fi
	rm -r "${S}"/mod_mam || die
}

src_prepare() {
	cp "${FILESDIR}"/mod_auth_pam.lua "${S}/mod_auth_pam/" || die
	mv mod_lib_ldap ldap || die
}

src_install() {
	insinto "${PREFIX}/usr/$(get_libdir)/prosody/modules"
	doins -r .
}
