# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 eutils

DESCRIPTION="Commandline tool for popular vector formats convertion"
HOMEPAGE="http://sk1project.org/modules.php?name=Products&product=uniconvertor https://code.google.com/p/uniconvertor/"
SRC_URI="https://dev.gentoo.org/~jlec/distfiles/${P}.tar.xz"

KEYWORDS="~amd64 ~arm ~hppa ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux ~x64-macos ~sparc-solaris ~x86-solaris"
SLOT="0"
LICENSE="GPL-2 LGPL-2"
IUSE="graphicsmagick"

RDEPEND="
	dev-python/pycairo[${PYTHON_USEDEP}]
	!graphicsmagick? ( media-gfx/imagemagick:= )
	graphicsmagick? ( media-gfx/graphicsmagick:= )
	media-libs/lcms:2
	dev-python/pillow[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	app-text/ghostscript-gpl"

PATCHES=(
	"${FILESDIR}"/${P}-import.patch
	"${FILESDIR}"/${P}-libimg.patch
	"${FILESDIR}"/${P}-test.patch
	)

python_prepare_all() {
	local wand
	if use graphicsmagick ; then
		wand=$(pkg-config --libs GraphicsMagickWand)
	else
		wand=$(pkg-config --libs MagickWand)
	fi
	wand=$(echo "${wand}" | sed -e "s:^ *::g" -e "s: *$::g" -e "s:-l:\':g" -e "s: :',:g" -e "s:$:':g" -e "s:,'$::g")

	distutils-r1_python_prepare_all

	sed \
		-e "s@/usr/include@${EPREFIX}/usr/include@" \
		-e "s@/usr/share@${EPREFIX}/usr/share@" \
		-e "/libraries/s:'MagickWand':${wand}:g" \
		-i setup.py || die

	if use graphicsmagick ; then
		sed  -e "s:ImageMagick-6:GraphicsMagick:" -i setup.py || die
		eapply "${FILESDIR}"/${P}-graphicsmagick.patch
	elif has_version ">=media-gfx/imagemagick-7.0" ; then
		# https://bugs.gentoo.org/581816
		sed  -e "s:ImageMagick-6:ImageMagick-7:" -i setup.py || die
		eapply "${FILESDIR}"/${P}-ImageMagick7.patch
	fi

	ln -sf \
		"${EPREFIX}"/usr/share/imagemagick/sRGB.icm \
		src/unittests/cms_tests/cms_data/sRGB.icm || die
}

python_test() {
	einfo ${PYTHONPATH}
	#distutils_install_for_testing
	cd src/unittests || die
	${EPYTHON} all_tests.py || die
}
