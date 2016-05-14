# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils scons-utils toolchain-funcs linux-info

DESCRIPTION="distributed file system built for offline operation"
HOMEPAGE="http://ori.scs.stanford.edu/"
SRC_URI="https://bitbucket.org/orifs/ori/downloads/${P}.tar.xz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+fuse httpd local lzma s3 zeroconf"

COMMON_DEPEND="
	>=dev-libs/openssl-1.0.1
	dev-libs/libevent
	fuse? ( sys-fs/fuse )
	lzma? ( app-arch/xz-utils )
	s3? ( dev-libs/libxml2 )
	zeroconf? ( net-dns/avahi[mdnsresponder-compat] )
"

DEPEND="
	>=dev-util/scons-2
	dev-libs/boost
	${COMMON_DEPEND}
"
RDEPEND="${COMMON_DEPEND}"

pkg_setup() {
    if use kernel_linux ; then
        if kernel_is lt 3 0 ; then
            die "Your kernel is too old."
        fi
        CONFIG_CHECK="~FUSE_FS"
        FUSE_FS_WARNING="You need to have FUSE module built to use ori"
        linux-info_pkg_setup
    fi
}

src_configure() {
	local compression_algo
	use lzma && compression_algo=lzma

	cat <<- EOF > Local.sc
		CC="$(tc-getCC)"
		CXX="$(tc-getCXX)"
		PREFIX="/usr"
		DESTDIR="${D}"
		$(use_scons fuse WITH_FUSE)
		$(use_scons httpd WITH_HTTPD)
		$(use_scons local WITH_ORILOCAL)
		$(use_scons zeroconf WITH_MDNS)
		$(use_scons s3 WITH_LIBS3)
		${compression_algo:+COMPRESSION_ALGO=${compression_algo}}
	EOF
}

src_compile() {
	escons
}

src_install() {
	escons install
}
