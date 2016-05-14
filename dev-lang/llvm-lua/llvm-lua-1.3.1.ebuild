# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=4

inherit cmake-utils pax-utils

LLVM_VERSION="2.8"

MY_PN="${PN//-/_}"

DESCRIPTION="JIT and static Lua compiler that uses LLVM as the compiler backend"
HOMEPAGE="http://code.google.com/p/llvm-lua/"
SRC_URI="http://llvm-lua.googlecode.com/files/${MY_PN}-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="nojit static-libs"

DEPEND="~sys-devel/llvm-${LLVM_VERSION}
	~sys-devel/clang-${LLVM_VERSION}"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	epatch "${FILESDIR}/${P}-rename-nojit.patch"
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_want nojit NOJIT_LIBRARIES)
		$(cmake-utils_use_want static-libs STATIC_LIBRARY)
		-DWANT_SHARED_LIBRARY=ON
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	pax-mark m "${D}/usr/bin/llvm-lua"
	pax-mark m "${D}/usr/bin/llvm-luac"
}
