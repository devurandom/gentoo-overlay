# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

if [[ ${PV} = *9999* ]] ; then
	git_eclass="git-r3"
	EGIT_REPO_URI="git://swift.im/swift"
	KEYWORDS=""
else
	MY_PV="${PV/_/}"
	MY_P="${PN}-${MY_PV}"
	SRC_URI="http://swift.im/downloads/releases/${MY_P}/${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${MY_P}"
fi

inherit multilib toolchain-funcs scons-utils ${git_eclass}

DESCRIPTION="Your friendly chat client"
HOMEPAGE="http://swift.im/"

LICENSE="GPL-3"
SLOT="0"
IUSE="debug doc gconf examples +expat experimental experimental-filetransfer icu hunspell qt5 readline ssl static-libs unbound zeroconf"

# zeroconf: Swift would also support mDNSResponder, but Gentoo dropped that package
RDEPEND="
	expat? ( dev-libs/expat )
	!expat? ( dev-libs/libxml2 )
	experimental? (
		dev-db/sqlite:3
	)
	experimental-filetransfer? (
		net-libs/miniupnpc:=
		net-libs/libnatpmp
	)
	gconf? ( gnome-base/gconf:2 )
	icu? ( dev-libs/icu:= )
	!icu? ( net-dns/libidn )
	readline? ( dev-libs/libedit )
	unbound? (
		net-libs/ldns
		net-dns/unbound
	)
	zeroconf? ( net-dns/avahi )
	dev-lang/lua:=
	dev-libs/boost:=
	dev-libs/openssl:0=
	qt5? (
		hunspell? ( app-text/hunspell:= )
		dev-qt/qtgui:5=
		dev-qt/qtmultimedia:5=
		dev-qt/qtwebkit:5=
		dev-qt/qtx11extras:5=
		x11-libs/libXScrnSaver
	)
	sys-libs/zlib
"
DEPEND="${RDEPEND}
	dev-qt/linguist-tools:5
	doc? (
		>=app-text/docbook-xsl-stylesheets-1.75
		>=app-text/docbook-xml-dtd-4.5
		dev-libs/libxslt
	)
"

PATCHES=(
	"${FILESDIR}/${P}"-make-generated-files-handle-unicode-characters-39ff091cddf8fd5e01047d80c7ed60c150537705.patch
	"${FILESDIR}/${P}"-qt-5.11-compat-1d18148c86377787a8c77042b12ea66f20cb2ca9.patch
)

scons_vars=()
set_scons_vars() {
	scons_vars=(
		V=1
		allow_warnings=1
		cc="$(tc-getCC)"
		cxx="$(tc-getCXX)"
		ccflags="${CXXFLAGS} -std=c++11"
		linkflags="${LDFLAGS}"
		qt="${S}/system-qt"
		openssl="${EPREFIX}/usr"
		docbook_xsl="${EPREFIX}/usr/share/sgml/docbook/xsl-stylesheets"
		docbook_xml="${EPREFIX}/usr/share/sgml/docbook/xml-dtd-4.5"
		debug=$(usex debug)
		experimental=$(usex experimental)
		experimental_ft=$(usex experimental-filetransfer)
		hunspell_enable=$(usex hunspell)
		icu=$(usex icu)
		openssl=$(usex ssl)
		qt5=$(usex qt5)
		swiften_dll=$(usex !static-libs)
		try_expat=$(usex expat)
		try_gconf=$(usex gconf)
		try_libxml=$(usex !expat)
		unbound=$(usex unbound)
	)
}

src_prepare() {
	mkdir system-qt || die
	ln -s "${EPREFIX}"/usr/$(get_libdir)/qt5/bin system-qt/bin || die
	ln -s "${EPREFIX}"/usr/$(get_libdir)/qt5 system-qt/lib || die
	ln -s "${EPREFIX}"/usr/include/qt5 system-qt/include || die

	rm -r 3rdParty || die

	default
}

src_compile() {
	local scons_targets=( Swiften )
	use qt5 && scons_targets+=( Swift )
	use zeroconf && scons_targets+=( Slimber )
	use examples && scons_targets+=(
		Documentation/SwiftenDevelopersGuide/Examples
		Limber
		Sluift
		Swiften/Config
		Swiften/Examples
		Swiften/QA
		SwifTools
	)

	set_scons_vars

	escons "${scons_vars[@]}" "${scons_targets[@]}"
}

src_test() {
	set_scons_vars

	escons "${scons_vars[@]}" test=unit QA
}

src_install() {
	set_scons_vars

	escons "${scons_vars[@]}" SWIFT_INSTALLDIR="${D}/usr" SWIFTEN_INSTALLDIR="${D}/usr" SWIFTEN_LIBDIR="$(get_libdir)" "${D}"

	if use zeroconf ; then
		newbin Slimber/Qt/slimber slimber-qt
		newbin Slimber/CLI/slimber slimber-cli
	fi

	if use examples ; then
		for i in EchoBot{1,2,3,4,5,6} EchoComponent ; do
			newbin "Documentation/SwiftenDevelopersGuide/Examples/EchoBot/${i}" "${PN}-${i}"
		done

		dobin Limber/limber
		dobin Sluift/sluift
		dobin Swiften/Config/swiften-config

		for i in BenchTool ConnectivityTest LinkLocalTool ParserTester SendFile SendMessage ; do
			newbin "Swiften/Examples/${i}/${i}" "${PN}-${i}"
		done
		newbin Swiften/Examples/SendFile/ReceiveFile "${PN}-ReceiveFile"
		use zeroconf && dobin Swiften/Examples/LinkLocalTool/LinkLocalTool

		for i in ClientTest NetworkTest StorageTest TLSTest ; do
			newbin "Swiften/QA/${i}/${i}" "${PN}-${i}"
		done

		newbin SwifTools/Idle/IdleQuerierTest/IdleQuerierTest ${PN}-IdleQuerierTest
	fi

	use doc && dohtml "Documentation/SwiftenDevelopersGuide/Swiften Developers Guide.html"
}
