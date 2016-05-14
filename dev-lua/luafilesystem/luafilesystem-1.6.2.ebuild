# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit multilib toolchain-funcs

DESCRIPTION="File System Library for the Lua Programming Language"
HOMEPAGE="https://keplerproject.github.com/luafilesystem/"
SRC_URI="mirror://github/keplerproject/luafilesystem/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~mips ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE_LUA_TARGET="lua_target_lua5-1 lua_target_lua5-2"
IUSE="${IUSE_LUA_TARGET}"

REQUIRED_USE="|| ( ${IUSE_LUA_TARGET} )"

DEPEND="lua_target_lua5-1? ( dev-lang/lua:5.1 )
	lua_target_lua5-2? ( dev-lang/lua:5.2 )"
RDEPEND="${DEPEND}"

get_lua_variant() {
	local lua_target="$1" lua_variant
	lua_variant="${lua_target##lua_target_}"
	lua_variant="${lua_variant/-/.}"
	echo "${lua_variant}"
}

src_prepare() {
	local lua_target lua_variant S_variant
	local pkg_config="$(tc-getPKG_CONFIG)" lua_inc lua_cmod
	sed -i \
		-e "s|gcc|$(tc-getCC)|" \
		-e "s|/usr/local|/usr|" \
		-e "s|/lib|/$(get_libdir)|" \
		-e "s|-O2|${CFLAGS}|" \
		-e "/^LIB_OPTION/s|= |= ${LDFLAGS} |" \
		config || die
	for lua_target in ${IUSE_LUA_TARGET} ; do
		use "${lua_target}" || continue
		lua_variant="$(get_lua_variant ${lua_target})"
		S_variant="${S}-${lua_variant}"
		einfo "Preparing for ${lua_variant}"
		cp -ar "${S}" "${S_variant}" || die
		cd "${S_variant}" || die
		lua_inc="$(${pkg_config} --variable INSTALL_INC ${lua_variant})" lua_cmod="$(${pkg_config} --variable INSTALL_CMOD ${lua_variant})"
		sed -i \
			-e "/^LUA_INC/s|=.*|= ${lua_inc}|" \
			-e "/^LUA_LIBDIR/s|=.*|= \${DESTDIR}${lua_cmod}|" \
			config || die
	done
}

src_compile() {
	local lua_target lua_variant S_variant
	for lua_target in ${IUSE_LUA_TARGET} ; do
		use "${lua_target}" || continue
		lua_variant="$(get_lua_variant ${lua_target})"
		S_variant="${S}-${lua_variant}"
		cd "${S_variant}" || die
		einfo "Compiling for ${lua_variant}"
		default
	done
}

src_install() {
	local lua_target lua_variant S_variant
	for lua_target in ${IUSE_LUA_TARGET} ; do
		use "${lua_target}" || continue
		lua_variant="$(get_lua_variant ${lua_target})"
		S_variant="${S}-${lua_variant}"
		cd "${S_variant}" || die
		einfo "Installing for ${lua_variant}"
		emake DESTDIR="${D}" install
	done
	dodoc README
	dohtml doc/us/*
}
