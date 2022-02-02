# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

JAVA_PKG_IUSE="doc examples source test"
MAVEN_ID="org.mozilla:rhino:1.7.7"
JAVA_TESTING_FRAMEWORKS="junit-4"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="An open-source implementation of JavaScript written in Java"
HOMEPAGE="https://mozilla.github.io/rhino/"
SRC_URI="https://github.com/mozilla/rhino/archive/refs/tags/Rhino${PV//./_}_Release.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-1.1 GPL-2"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
SLOT="1.6"

# StackOverFlow errors arise on some tests.
# Further, the test suite takes way too much time (> 5 min).
# Maybe reduce the numbers of tests?
RESTRICT="test"

DOCS=( {CODE_OF_CONDUCT,README,RELEASE-NOTES,RELEASE-STEPS}.md {LICENSE,NOTICE-tools,NOTICE}.txt )

S="${WORKDIR}/rhino-Rhino${PV//./_}_Release"

CDEPEND=""
RDEPEND=">=virtual/jre-1.8:*
    ${CDEPEND}"

DEPEND=">=virtual/jdk-1.8:*
    test? (
        dev-java/junit:4
        dev-java/ant-junit:0
        dev-java/emma:0
        dev-java/hamcrest-core:1.3
    )
    ${CDEPEND}"

JAVA_SRC_DIR="src"
JAVA_TEST_GENTOO_CLASSPATH="junit-4"

src_prepare() {
    default
    java-pkg_clean
}

src_install() {
    default # https://bugs.gentoo.org/789582
    java-pkg-simple_src_install
}
