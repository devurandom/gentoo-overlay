# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit sgml-catalog-r1

MY_PV=${PV/_beta/b}
MY_PV=${PV/_rc/CR}

DESCRIPTION="Docbook DTD for MathML"
HOMEPAGE="http://www.docbook.org/xml/mathml/"
SRC_URI="http://www.docbook.org/xml/mathml/${MY_PV}/dbmathml.dtd -> dbmathml-${PV}.dtd"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="app-text/mathml-xml-dtd"
RDEPEND="dev-libs/libxml2
	app-text/docbook-xml-dtd:4.3
	>=app-text/build-docbook-catalog-1.6
	${DEPEND}"

S=${WORKDIR}

src_unpack() {
	cp "${DISTDIR}"/dbmathml-${PV}.dtd "${S}" || die
}

src_prepare() {
	mv dbmathml-${PV}.dtd dbmathml.dtd || die
	cat <<- EOF > docbook.cat || die
		PUBLIC "-//OASIS//DTD DocBook MathML Module V${MY_PV}//EN" "dbmathml.dtd"
		SYSTEM "http://www.oasis-open.org/docbook/xml/mathml/1.1CR1/dbmathml.dtd" "dbmathml.dtd"
	EOF
	eapply_user
}

src_install() {
	insinto /etc/sgml
	newins - "mathml-docbook-${PV}.cat" <<-EOF
		CATALOG "${EPREFIX}/etc/sgml/sgml-docbook.cat"
		CATALOG "${EPREFIX}/usr/share/sgml/docbook/${P#docbook-}/docbook.cat"
	EOF

	insinto /usr/share/sgml/docbook/${P#docbook-}
	doins *.cat *.dtd
}

pkg_preinst() {
	# work-around old revision removing it
	cp "${ED}"/etc/sgml/mathml-docbook-${PV}.cat "${T}" || die
}

pkg_postinst() {
	local backup=${T}/mathml-docbook-${PV}.cat
	local real=${EROOT}/etc/sgml/mathml-docbook-${PV}.cat
	if ! cmp -s "${backup}" "${real}"; then
		cp "${backup}" "${real}" || die
	fi

	build-docbook-catalog
	sgml-catalog-r1_pkg_postinst

	xmlcatalog --noout \
		--add public "-//OASIS//DTD DocBook MathML Module V${MV_PV}//EN" "file:///usr/share/sgml/docbook/${P#docbook-}/dbmathml.dtd" \
		--add rewriteSystem "http://www.oasis-open.org/docbook/xml/mathml/1.1CR1" "file:///usr/share/sgml/docbook/${P#docbook-}" \
		"${EPREFIX}"/etc/xml/docbook \
	|| die
}

pkg_postrm() {
	build-docbook-catalog
	sgml-catalog-r1_pkg_postrm

	xmlcatalog --noout \
		--del "-//OASIS//DTD DocBook MathML Module V${MV_PV}//EN" \
		--del "http://www.oasis-open.org/docbook/xml/mathml/1.1CR1/dbmathml.dtd" \
		"${EPREFIX}"/etc/xml/docbook \
	|| die
}
