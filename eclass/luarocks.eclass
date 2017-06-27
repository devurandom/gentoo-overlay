# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: luarocks.eclass
# @MAINTAINER:
# Dennis Schridde <devurandom@gmx.net>
# @AUTHOR:
# Dennis Schridde <devurandom@gmx.net>
# @BLURB: Eclass to build luarocks based software.
# @DESCRIPTION:
# Eclass to build luarocks based software.

EXPORT_FUNCTIONS src_configure src_compile src_install

DEPEND="dev-lua/luarocks"

LUAROCKS="luarocks --tree=${EPREFIX}/usr/lib64/lua/luarocks"
export LUAROCKS

luarocks_src_configure() {
}

luarocks_src_compile() {
	${LUAROCKS} build || die
}

luarocks_src_install() {
	${LUAROCKS} install || die
}
