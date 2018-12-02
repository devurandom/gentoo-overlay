# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6,7} )
DISTUTILS_SINGLE_IMPL=1
inherit xdg distutils-r1 eutils flag-o-matic user tmpfiles prefix

DESCRIPTION="X Persistent Remote Apps (xpra) and Partitioning WM (parti) based on wimpiggy"
HOMEPAGE="http://xpra.org/ http://xpra.org/src/"
SRC_URI="http://xpra.org/src/${P}.tar.xz"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="+client cups dbus debug examples ffmpeg gtk2 gtk3 gzip html5 html5_brotli html5_gzip html5_minify jpeg libav lz4 lzo opengl pam +pillow pulseaudio server systemd test v4l2 vpx webcam webp x264 x265 zeroconf"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	|| ( client server )
	cups? ( dbus )
	client? ( ^^ ( gtk2 gtk3 ) )
	gtk2? ( python_single_target_python2_7 )
	gtk3? ( || (
		python_single_target_python3_4
		python_single_target_python3_5
		python_single_target_python3_6
		python_single_target_python3_7
	) )
	html5_brotli? ( html5 )
	html5_gzip? ( html5 )
	html5_minify? ( html5 )
	opengl? ( client )
	python_single_target_python2_7? ( gtk2 )
	python_single_target_python3_4? ( gtk3 )
	python_single_target_python3_5? ( gtk3 )
	python_single_target_python3_6? ( gtk3 )
	python_single_target_python3_7? ( gtk3 )
	v4l2? ( kernel_linux )"

COMMON_DEPEND="${PYTHON_DEPS}
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-libs/libxkbfile
	gtk2? (
		dev-python/pygobject:2[${PYTHON_USEDEP}]
		dev-python/pygtk:2[${PYTHON_USEDEP}]
		x11-libs/gtk+:2
	)
	gtk3? (
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
		x11-libs/gtk+:3
	)
	ffmpeg? (
		!libav? ( media-video/ffmpeg:= )
		libav? ( media-video/libav:= )
		client? (
			!libav? ( >=media-video/ffmpeg-2[x264?,x265?] )
			libav? ( media-video/libav[x264?,x265?] )
		)
		server? (
			!libav? ( >=media-video/ffmpeg-3.2.2 )
		)
	)
	x264? (
		server? (
			media-libs/x264:=
		)
	)
	x265? (
		server? (
			media-libs/x265:=
		)
	)
	jpeg? ( media-libs/libjpeg-turbo )
	html5_brotli? ( app-arch/brotli )
	html5_gzip? ( app-arch/gzip )
	html5_minify? ( dev-util/yuicompressor )
	opengl? ( dev-python/pygtkglext )
	pam? ( virtual/pam )
	pulseaudio? (
		media-sound/pulseaudio
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
		dev-python/gst-python:1.0
	)
	systemd? ( sys-apps/systemd:= )
	vpx? (
		media-libs/libvpx:=
		virtual/ffmpeg:=
	)
	webp? ( media-libs/libwebp:= )"

RDEPEND="${COMMON_DEPEND}
	dev-python/ipython[${PYTHON_USEDEP}]
	dev-python/netifaces[${PYTHON_USEDEP}]
	dev-python/rencode[${PYTHON_USEDEP}]
	virtual/ssh
	x11-apps/xmodmap
	cups? ( dev-python/pycups[${PYTHON_USEDEP}] )
	dbus? ( dev-python/dbus-python[${PYTHON_USEDEP}] )
	lz4? ( dev-python/lz4[${PYTHON_USEDEP}] )
	lzo? ( >=dev-python/python-lzo-0.7.0[${PYTHON_USEDEP}] )
	opengl? ( dev-python/pyopengl_accelerate[${PYTHON_USEDEP}] )
	pillow? ( dev-python/pillow[${PYTHON_USEDEP}] )
	server? (
		x11-base/xorg-server[-minimal,xvfb]
		x11-drivers/xf86-input-void
	)
	webcam? (
		dev-python/numpy[${PYTHON_USEDEP}]
		media-libs/opencv[python]
		dev-python/pyinotify[${PYTHON_USEDEP}]
	)"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	>=dev-python/cython-0.16[${PYTHON_USEDEP}]"

PATCHES=( "${FILESDIR}"/${PN}-0.13.1-ignore-gentoo-no-compile.patch
	"${FILESDIR}"/${PN}-2.0-suid-warning.patch )

pkg_postinst() {
	enewgroup ${PN}
	tmpfiles_process /usr/lib/tmpfiles.d/xpra.conf

	xdg_pkg_postinst
}

python_prepare_all() {
	hprefixify -w '/os.path/' setup.py
	hprefixify tmpfiles.d/xpra.conf xpra/server/{server,socket}_util.py \
		xpra/platform{/xposix,}/paths.py xpra/scripts/server.py

	distutils-r1_python_prepare_all
}

python_configure_all() {
	sed -e "/'pulseaudio'/s:DEFAULT_PULSEAUDIO:$(usex pulseaudio True False):" \
		-i setup.py || die

	mydistutilsargs=(
		# No idea what this does
		--with-annotate
		# Has no dependencies
		--with-bencode
		# Don't install tests
		--without-bundle_tests
		$(use_with client)
		# Has no dependencies
		--with-clipboard
		# Nvidia support untested:
		--without-cuda_kernels
		--without-cuda_rebuild
		$(use_with ffmpeg csc_swscale)
		# No libyuv in Gentoo
		--without-csc_libyuv
		# Has no dependencies
		--with-cython_bencode
		$(use_with dbus)
		$(use_with debug)
		$(use_with ffmpeg dec_avcodec2)
		$(use_with ffmpeg enc_ffmpeg)
		$(use_with x264 enc_x264)
		$(use_with x265 enc_x265)
		$(use_with examples example)
		$(use_with client gtk_x11)
		$(use_with gtk2)
		$(use_with gtk3)
		$(use_with html5)
		$(use_with html5_brotli)
		$(use_with html5_gzip)
		$(use_with jpeg)
		# No idea what this does
		--with-keyboard
		$(use_with zeroconf mdns)
		$(use_with html5_minify minify)
		# No idea what this does
		--with-netdev
		$(use_with dbus notifications)
		# Nvidia support untested:
		--without-nvenc
		--without-nvfbc
		$(use_with pam)
		$(use_with opengl)
		--with-PIC
		$(use_with pillow)
		$(use_with cups printing)
		# Has no dependencies
		--with-proxy
		--with-rebuild
		# Has no dependencies
		--with-rfb
		# No idea what this does
		--with-scripts
		$(use_with systemd sd_listen)
		$(use_with server)
		# No idea what this does
		--with-service
		$(use_with server shadow)
		$(use_with pulseaudio sound)
		--with-strict
		$(use_with test tests)
		# No idea what this does
		--with-uinput
		$(use_with v4l2)
		--with-verbose
		$(use_with vpx)
		# Has no dependencies
		--with-vsock
		--with-warn
		$(use_with webcam)
		$(use_with webp)
		--with-Xdummy
		--with-Xdummy_wrapper
		--with-x11
		--with-xdg_open
		--with-xinput
	)

	# see https://www.xpra.org/trac/ticket/1080
	# and http://trac.cython.org/ticket/395
	append-cflags -fno-strict-aliasing

	export XPRA_SOCKET_DIRS="${EPREFIX}/run/xpra"
}
