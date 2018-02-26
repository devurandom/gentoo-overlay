# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit ninja-utils eutils flag-o-matic versionator java-pkg-opt-2

MY_PV="$(replace_version_separator 2 r)"
MY_PV_SRC="$(get_version_component_range 1-2)"

DESCRIPTION="research tool for polyhedral geometry and combinatorics"
SRC_URI="https://polymake.org/lib/exe/fetch.php/download/polymake-${MY_PV}-minimal.tar.bz2"
HOMEPAGE="http://polymake.org"

IUSE="libcxx libnormaliz mongodb openmp ppl singular soplex svg system-permlib system-sympol"

REQUIRED_USE="!soplex !system-permlib !system-sympol system-sympol? ( system-permlib )"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"

# In theory, sci-libs/bliss, sci-libs/cddlib and sci-libs/lrslib are optional
# dependencies.  In practice, though, they are required by bundled libraries.
# e.g. --with-sympol=bundled requires --with-lrs=...
DEPEND="dev-util/ninja
	dev-lang/perl
	>=dev-libs/gmp-5.1:0=
	>=dev-libs/mpfr-3:0=
	dev-libs/libxml2:2
	dev-libs/libxslt
	dev-libs/boost:=
	sci-libs/bliss[gmp]
	sci-libs/cddlib
	>=sci-libs/lrslib-051[gmp]
	libcxx? ( sys-libs/libcxx:= )
	libnormaliz? ( sci-mathematics/normaliz:= )
	ppl? ( >=dev-libs/ppl-1.2:= )
	singular? ( >=sci-mathematics/singular-4.0.1 )"
RDEPEND="${DEPEND}
	dev-perl/XML-LibXML
	dev-perl/XML-LibXSLT
	dev-perl/XML-Writer
	dev-perl/Term-ReadLine-Gnu
	dev-perl/TermReadKey
	java? ( >=virtual/jre-1.6:* )
	svg? ( dev-perl/SVG )
	mongodb? ( dev-perl/MongoDB )"
DEPEND="java? ( >=virtual/jdk-1.6:* )"

S="${WORKDIR}/${PN}-${MY_PV_SRC}"

pkg_pretend() {
	einfo "During compile this package uses up to"
	einfo "750MB of RAM per process. Use MAKEOPTS=\"-j1\" if"
	einfo "you run into trouble."
}

use_with_bundled() {
	local flag="$1" name="$2" opt="$3"
	if use "${flag}" ; then
		use_with "${flag}" "${name}" "${opt}"
	else
		echo "--with-${name}=bundled"
	fi
}

src_configure() {
	export CXXOPT=$(get-flag -O)

	# We need to define BLISS_USE_GMP if bliss was built with gmp support.
	# Therefore we require gmp support on bliss, so that the package
	# manager can prevent rebuilds with changed gmp flag.
	append-cxxflags -DBLISS_USE_GMP

	local myconf=()

	# Configure does not accept --host, therefore econf cannot be used
	# And many other --with-arguments expect a path: --with-option=/path
	./configure \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--libexecdir="${EPREFIX}/usr/$(get_libdir)/polymake" \
		--with-bliss="${EPREFIX}/usr" \
		--with-cdd="${EPREFIX}/usr" \
		--with-lrs="${EPREFIX}/usr" \
		--without-native \
		--without-prereq \
		$(use_with openmp) \
		$(use_with ppl ppl "${EPREFIX}/usr") \
		$(use_with java java "${JAVA_HOME}") \
		$(use_with libnormaliz libnormaliz "${EPREFIX}/usr") \
		$(use_with singular singular "${EPREFIX}/usr") \
		$(use_with soplex soplex "${EPREFIX}/usr") \
		$(use_with_bundled system-permlib permlib "${EPREFIX}/usr") \
		$(use_with_bundled system-sympol sympol "${EPREFIX}/usr") \
		"${myconf[@]}" || die
}

src_compile() {
	eninja -C build/Opt || die
}

src_install() {
	export DESTDIR="${D}"
	eninja -C build/Opt install || die
}

pkg_postinst() {
	elog "Docs can be found on http://www.polymake.org/doku.php/documentation"
	elog " "
	elog "Support for jreality is missing, sorry (see bug #346073)."
	elog " "
	elog "Additional features for polymake are available through external"
	elog "software such as sci-mathematics/4ti2 and sci-mathematics/topcom."
	elog "After installing new external software run 'polymake --reconfigure'."
}
