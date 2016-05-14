# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit flag-o-matic cmake-utils git-2

EGIT_REPO_URI="git://git.process-one.net/${PN}/${PN}.git"
EGIT_COMMIT="v${PV}"

DESCRIPTION="Enterprise multi-network instant messaging client"
HOMEPAGE="http://oneteam.im/"

LICENSE="|| ( GPL-2 MPL-1.1 )"

SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="net-libs/xulrunner
	dev-libs/nspr
	dev-libs/glib:2
	x11-libs/gtk+:2
	media-sound/pulseaudio
	x11-libs/libXScrnSaver
	x11-libs/libX11
	net-libs/libsrtp"
DEPEND="${DEPEND}
	dev-perl/Sub-Name
	dev-util/pkgconfig"

src_prepare() {
	einfo "Removing precompiled binaries"
	rm components/oneteam.xpt && \
	rm -r platform/* \
	|| die
	eend $?

	cd src/components

	einfo "Patching FindXPCOM for Gentoo"
	sed -i cmake/FindXPCOM.cmake \
		-e 's:${XPCOM_GECKO_SDK}/host/bin:${XPCOM_GECKO_SDK}/bin:' \
	|| die
	eend $?

	einfo "Patching CMakeLists.txt for inclusion of NSPR and SRTP"
	sed -i CMakeLists.txt \
		-e "/^INCLUDE_DIRECTORIES(/a \
			`pkg-config --variable=includedir nspr`" \
		-e 's:libs/libsrtp/include:/usr/include/srtp:' \
		-e 's:libs/libsrtp/crypto/include::' \
	|| die
	eend $?
}

src_configure() {
	export GECKO_SDK=`pkg-config --variable=sdkdir libxul`
	CMAKE_USE_DIR="${S}/src/components"

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	case $ARCH in
		amd64) arch=x86_64 ;;
		*) die "Your ARCH is not supported by this ebuild" ;;
	esac

	mkdir platform/Linux-$arch-gcc3/ || die

	cp ${CMAKE_BUILD_DIR}/oneteam.xpt components/ || die
	cp ${CMAKE_BUILD_DIR}/liboneteam.so platform/Linux-$arch-gcc3/ || die

	emake xulapp || die
	#perl build.pl XULAPP 1 NOJAR 1 || die
}

src_install() {
	# Variant for make xulapp, using xulrunner
	dodir /opt/${PN}
	xulrunner-2.0 --install-app ${S}/oneteam.xulapp ${D}/opt || die

	# Variant for make xulapp, using unzip
	#dodir /opt/${PN}
	#unzip -q -d ${D}/opt/${PN} ${S}/oneteam.xulapp || die

	# Variant for build.pl NOJAR=1, does not work
	#insinto /opt/${PN}
	#doins -r app/*

	cat <<-EOF > ${PN}
		#!/bin/sh
		exec xulrunner-2.0 /opt/${PN}/application.ini
	EOF
	exeinto /usr/bin
	doexe ${PN}
}
