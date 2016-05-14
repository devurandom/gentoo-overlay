# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils flag-o-matic toolchain-funcs

PATCH_VER="0.1"
EPATCH_SOURCE="${WORKDIR}/${P}-patches"
EPATCH_SUFFIX="patch"

SRCTYPE="opensource-src"
DESCRIPTION="The Qt toolkit is a comprehensive C++ application development framework."
HOMEPAGE="http://www.trolltech.com/"

SRC_URI="ftp://ftp.trolltech.com/pub/qt/source/qt-all-${SRCTYPE}-${PV}.tar.gz
	${P}-patches-${PATCH_VER}.tar.bz2"
S=${WORKDIR}/qt-all-${SRCTYPE}-${PV}

LICENSE="|| ( QPL-1.0 GPL-2 )"
SLOT="4"
KEYWORDS=""

IUSE="accessibility debug doc examples gif jpeg mng odbc pch png qt3support sqlite3 tiff zlib"

# cross-compiling need controlled strip
RESTRICT="mirror strip"

pkg_setup() {
	local mingw32_variants="mingw32 i686-mingw32 i586-mingw32 i486-mingw32 i386-mingw32"
	local i
	CTARGET=""
	for i in ${mingw32_variants} ; do
		if type -p ${i}-gcc >& /dev/null ; then
			CTARGET=${i}
			break;
		fi
	done

	if [ -z "$CTARGET" ] ; then
		eerror "Before you could emerge qt-windows, you need to install mingw32."
		eerror "Run the following command:"
		eerror "  emerge crossdev"
		eerror "then run _one_ of the following commands:"
		for i in ${mingw32_variants} ; do
			eerror "  crossdev ${i}"
		done
		die "mingw32 is needed"
	fi

	QTPREFIXDIR=/usr/${CTARGET}/usr
	QTBASEDIR=${QTPREFIXDIR}/lib/qt4
	QTBINDIR=${QTPREFIXDIR}/bin
	QTLIBDIR=${QTPREFIXDIR}/lib/qt4
	QTPCDIR=${QTPREFIXDIR}/lib/pkgconfig
	QTDATADIR=${QTPREFIXDIR}/share/qt4
	QTDOCDIR=${QTPREFIXDIR}/share/doc/${PF}
	QTHEADERDIR=${QTPREFIXDIR}/include/qt4
	QTPLUGINDIR=${QTDATADIR}/plugins
	QTSYSCONFDIR=/etc/qt4/${CTARGET}
	QTTRANSDIR=${QTDATADIR}/translations
	QTEXAMPLESDIR=${QTDATADIR}/examples
	QTDEMOSDIR=${QTDATADIR}/demos

	PLATFORM=$(qt_mkspecs_dir)
	XPLATFORM="win32-g++"
}

qt_use() {
	local flag="$1"
	local feature="$1"
	local enableval=

	[[ -n $2 ]] && feature=$2
	[[ -n $3 ]] && enableval="-$3"

	useq $flag && echo "${enableval}-${feature}" || echo "-no-${feature}"
	return 0
}

qt_mkspecs_dir() {
	 # Allows us to define which mkspecs dir we want to use.
	local spec

	case ${CHOST} in
		*-freebsd*|*-dragonfly*)
			spec="freebsd" ;;
		*-openbsd*)
			spec="openbsd" ;;
		*-netbsd*)
			spec="netbsd" ;;
		*-darwin*)
			spec="darwin" ;;
		*-linux-*|*-linux)
			spec="linux" ;;
		*)
			die "Unknown CHOST, no platform choosed."
	esac

	CXX=$(tc-getCXX)
	if [[ ${CXX/g++/} != ${CXX} ]]; then
		spec="${spec}-g++"
	elif [[ ${CXX/icpc/} != ${CXX} ]]; then
		spec="${spec}-icc"
	else
		die "Unknown compiler ${CXX}."
	fi

	echo "${spec}"
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch
	sed -i -e "s:MINGW32:${CTARGET}:" mkspecs/win32-g++/qmake.conf

	cd "${S}"/mkspecs/$(qt_mkspecs_dir)
	# set c/xxflags and ldflags

	# Don't let the user go too overboard with flags.  If you really want to, uncomment
	# out the line below and give 'er a whirl.
	strip-flags
	replace-flags -O3 -O2

	# strip march/mcpu/mtune flags for win32-g++
	filter-flags -march* -mcpu* -mtune*
	append-flags -fno-strict-aliasing

	if [[ $( gcc-fullversion ) == "3.4.6" && gcc-specs-ssp ]] ; then
		ewarn "Appending -fno-stack-protector to CFLAGS/CXXFLAGS"
		append-flags -fno-stack-protector
	fi

	sed -i -e "s:QMAKE_CFLAGS_RELEASE.*=.*:QMAKE_CFLAGS_RELEASE=${CFLAGS}:" \
		-e "s:QMAKE_CXXFLAGS_RELEASE.*=.*:QMAKE_CXXFLAGS_RELEASE=${CXXFLAGS}:" \
		-e "s:QMAKE_LFLAGS_RELEASE.*=.*:QMAKE_LFLAGS_RELEASE=${LDFLAGS}:" \
		-e "/CONFIG/s:$: nostrip:" \
		qmake.conf

	# Do not link with -rpath. See bug #75181.
	sed -i -e "s:QMAKE_RPATH.*=.*:QMAKE_RPATH=:" qmake.conf

	# Replace X11R6/ directories, so /usr/X11R6/lib -> /usr/lib
	sed -i -e "s:X11R6/::" qmake.conf

	# The trolls moved the definitions of the above stuff for g++, so we need to edit those files
	# separately as well.
	cd "${S}"/mkspecs/common

	sed -i -e "s:QMAKE_CFLAGS_RELEASE.*=.*:QMAKE_CFLAGS_RELEASE=${CPPFLAGS} ${CFLAGS} ${ASFLAGS}:" \
		-e "s:QMAKE_CXXFLAGS_RELEASE.*=.*:QMAKE_CXXFLAGS_RELEASE=${CPPFLAGS} ${CXXFLAGS} ${ASFLAGS}:" \
		-e "s:QMAKE_LFLAGS_RELEASE.*=.*:QMAKE_LFLAGS_RELEASE=${LDFLAGS}:" \
		-e "/CONFIG/s:$: nostrip:" \
		g++.conf

	# Do not link with -rpath. See bug #75181.
	sed -i -e "s:QMAKE_RPATH.*=.*:QMAKE_RPATH=:" g++.conf

	# Replace X11R6/ directories, so /usr/X11R6/lib -> /usr/lib
	sed -i -e "s:X11R6/::" linux.conf

	cd "${S}"/qmake

	sed -i -e "s:CXXFLAGS.*=:CXXFLAGS=${CPPFLAGS} ${CXXFLAGS} ${ASFLAGS} :" \
	-e "s:LFLAGS.*=:LFLAGS=${LDFLAGS} :" Makefile.unix

	cd "${S}"
}

src_compile() {
	export PATH="${S}/bin:${PATH}"
	export LD_LIBRARY_PATH="${S}/lib:${LD_LIBRARY_PATH}"

	myconf="${myconf} -no-mmx -no-3dnow -no-sse -no-sse2"
	myconf="${myconf} -rtti -qt-libpng -qt-libjpeg -qt-libmng -qt-zlib"
	myconf="${myconf} -no-sql-mysql -no-sql-psql -no-sql-ibase -no-sql-sqlite2"
	myconf="${myconf} $(qt_use qt3support) $(qt_use pch)"
	myconf="${myconf} $(qt_use accessibility)"
	myconf="${myconf} $(qt_use odbc sql-odbc plugin) $(qt_use sqlite3 sql-sqlite plugin)"
	myconf="${myconf} $(qt_use zlib zlib qt) $(qt_use gif gif qt)"
	myconf="${myconf} $(qt_use tiff libtiff qt) $(qt_use png libpng qt)"
	myconf="${myconf} $(qt_use mng libmng qt) $(qt_use jpeg libjpeg qt)"
	
	# Disable visibility explicitly if gcc version isn't 4
	if [[ "$(gcc-major-version)" != "4" ]]; then
		myconf="${myconf} -no-reduce-exports"
	fi

	# Add a switch that will attempt to use recent binutils to reduce relocations.  Should be harmless for other
	# cases.  From bug #178535
	myconf="${myconf} -reduce-relocations"

	use debug	&& myconf="${myconf} -debug -no-separate-debug-info" || myconf="${myconf} -release -no-separate-debug-info"

	if ! use examples; then
		myconf="${myconf} -nomake examples"
	fi

	myconf="-stl -verbose -largefile -confirm-license \
		-platform ${PLATFORM} -xplatform ${XPLATFORM} -no-rpath \
		-prefix ${QTPREFIXDIR} -bindir ${QTBINDIR} -libdir ${QTLIBDIR} -datadir ${QTDATADIR} \
		-docdir ${QTDOCDIR} -headerdir ${QTHEADERDIR} -plugindir ${QTPLUGINDIR} \
		-sysconfdir ${QTSYSCONFDIR} -translationdir ${QTTRANSDIR} \
		-examplesdir ${QTEXAMPLESDIR} -demosdir ${QTDEMOSDIR} ${myconf}"

	echo ./configure ${myconf}
	./configure ${myconf} || die

	emake all || die
}

src_install() {
	export PATH="${S}/bin:${PATH}"
	export LD_LIBRARY_PATH="${S}/lib:${LD_LIBRARY_PATH}"

	emake INSTALL_ROOT="${D}" install_subtargets || die
	emake INSTALL_ROOT="${D}" install_qmake || die
	emake INSTALL_ROOT="${D}" install_mkspecs || die

	# some *.dll are installed twice (in QTBINDIR and in QTLIBDIR)
	# we want them all in QTBINDIR
	mv -f ${D}/${QTLIBDIR}/*.dll ${D}/${QTBINDIR}

	# controlled strip
	env RESTRICT="" CHOST=${CHOST} prepstrip ${D}/${QTBINDIR}
	env RESTRICT="" CHOST=${CTARGET} prepstrip ${D}/${QTLIBDIR}
	# want to strip dlls too
	find ${D} -iname "*.dll" -exec $(tc-getSTRIP ${CTARGET}) --strip-unneeded '{}' \;

	if use doc; then
		emake INSTALL_ROOT="${D}" install_htmldocs || die
	fi

	# Install the translations.	 This may get use flagged later somehow
	emake INSTALL_ROOT="${D}" install_translations || die

	keepdir "${QTSYSCONFDIR}"

	sed -i -e "s:${S}/lib:${QTLIBDIR}:g" "${D}"/${QTLIBDIR}/*.la
	sed -i -e "s:${S}/lib:${QTLIBDIR}:g" "${D}"/${QTLIBDIR}/*.prl
	sed -i -e "s:${S}/lib:${QTLIBDIR}:g" "${D}"/${QTLIBDIR}/pkgconfig/*.pc

	# pkgconfig files refer to WORKDIR/bin as the moc and uic locations.  Fix:
	sed -i -e "s:${S}/bin:${QTBINDIR}:g" "${D}"/${QTLIBDIR}/pkgconfig/*.pc

	# Move .pc files into the pkgconfig directory
	dodir ${QTPCDIR}
	mv "${D}"/${QTLIBDIR}/pkgconfig/*.pc "${D}"/${QTPCDIR}

	cat > "${T}/44qt4-${CTARGET}" << EOF
XQMAKESPEC=${XPLATFORM}
EOF
	doenvd "${T}/44qt4-${CTARGET}"
	# create symlink to use CTARGET-qmake when cross-compiling
	dosym ${QTBINDIR}/qmake /usr/bin/${CTARGET}-qmake
}
