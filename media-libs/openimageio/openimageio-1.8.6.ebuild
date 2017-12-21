# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_5,3_6} )

inherit cmake-utils python-single-r1 vcs-snapshot

DESCRIPTION="A library for reading and writing images"
HOMEPAGE="https://sites.google.com/site/openimageio/ https://github.com/OpenImageIO"
SRC_URI="https://github.com/OpenImageIO/oiio/archive/Release-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc64 ~x86"

X86_CPU_FEATURES=(
	sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4.1 sse4_2:sse4.2
	avx:avx avx2:avx2 avx512f:avx512f f16c:f16c
)
CPU_FEATURES=( ${X86_CPU_FEATURES[@]/#/cpu_flags_x86_} )
IUSE="colorio ffmpeg field3d gif jpeg2k jpegturbo opencv opengl ptex python qt5 raw ssl +truetype ${CPU_FEATURES[@]%:*}"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RESTRICT="test" #431412

RDEPEND="
	dev-libs/boost:=
	dev-libs/pugixml:=
	media-libs/ilmbase:=
	media-libs/libpng:0=
	>=media-libs/libwebp-0.2.1:=
	media-libs/openexr:=
	media-libs/tiff:0=
	sys-libs/zlib:=
	virtual/jpeg:0=
	colorio? ( >=media-libs/opencolorio-1.0.7:= )
	ffmpeg? ( media-video/ffmpeg:= )
	field3d? ( media-libs/field3d:= )
	gif? ( media-libs/giflib:0= )
	jpegturbo? ( media-libs/libjpeg-turbo )
	jpeg2k? ( >=media-libs/openjpeg-1.5:0= )
	opencv? (
		>=media-libs/opencv-2.3:=
		python? ( >=media-libs/opencv-2.4.8[python,${PYTHON_USEDEP}] )
	)
	opengl? (
		virtual/glu
		virtual/opengl
	)
	ptex? ( media-libs/ptex )
	python? (
		${PYTHON_DEPS}
		dev-libs/boost:=[python,${PYTHON_USEDEP}]
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtopengl:5
		media-libs/glew:=
	)
	raw? ( media-libs/libraw:= )
	ssl? ( dev-libs/openssl:0 )
	truetype? ( media-libs/freetype:2= )"
DEPEND="${RDEPEND}"

#S=${WORKDIR}/${P}/src

DOCS=( CHANGES.md CREDITS.md README.md src/doc/${PN}.pdf )

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	default

	cmake-utils_src_prepare

	use python && python_fix_shebang .
}

# Source: http://stackoverflow.com/questions/1527049/join-elements-of-an-array#17841619
join_by() {
	local IFS="$1"
	shift
	echo "$*"
}

src_configure() {
	# Build with SIMD support
	local cpufeature
	local mysimd=()
	for cpufeature in "${CPU_FEATURES[@]}"; do
		use "${cpufeature%:*}" && mysimd+=("${cpufeature#*:}")
	done

	# If no CPU SIMDs were used, completely disable them
	[[ -z "${mysimd}" ]] && mysimd=("OFF")

	local mycmakeargs=(
		-DLIB_INSTALL_DIR="/usr/$(get_libdir)"
		-DBUILDSTATIC=OFF
		-DLINKSTATIC=OFF
		-DINSTALL_DOCS=OFF
		-DOIIO_BUILD_TESTS=OFF # as they are RESTRICTed
		-DSTOP_ON_WARNING=OFF
		-DUSE_CPP14=ON
		-DUSE_EXTERNAL_PUGIXML=ON
		-DUSE_FFMPEG=$(usex ffmpeg)
		-DUSE_FIELD3D=$(usex field3d)
		-DUSE_FREETYPE=$(usex truetype)
		-DUSE_GIF=$(usex gif)
		-DUSE_JPEGTURBO=$(usex jpegturbo)
		-DUSE_NUKE=NO # Missing in Gentoo
		-DUSE_OCIO=$(usex colorio)
		-DUSE_OPENCV=$(usex opencv)
		-DUSE_OPENGL=$(usex opengl)
		-DUSE_OPENJPEG=$(usex jpeg2k)
		-DUSE_OPENSSL=$(usex ssl)
		-DUSE_PTEX=$(usex ptex)
		-DUSE_LIBRAW=$(usex raw)
		-DUSE_QT=$(usex qt5)
		-DUSE_SIMD=$(join_by , "${mysimd[@]}")
		-DVERBOSE=ON
	)

	if use python ; then
		mycmakeargs+=(
			-DPYLIB_INSTALL_DIR="$(python_get_sitedir)"
			-DPYTHON_VERSION="${EPYTHON#python}"
			-DUSE_PYTHON=ON
		)
	fi

	cmake-utils_src_configure
}
