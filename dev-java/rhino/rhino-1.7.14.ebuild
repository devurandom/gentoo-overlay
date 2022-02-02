# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
JAVA_PKG_IUSE="doc examples source test"
MAVEN_ID="org.mozilla:rhino:1.7.14"

inherit java-pkg-2 versionator

# rhino -> Rhino
MY_PN="${PN^}"

# 1.7.7 -> 1_7_7
MY_PV="$(replace_all_version_separators _ ${PV})"

# rhino1.7.7
MY_P="${PN}${PV}"

# Rhino1_7_7_Release
MY_RELEASE="${MY_PN}${MY_PV}_Release"

DESCRIPTION="An open-source implementation of JavaScript written in Java"
SRC_URI="https://github.com/mozilla/${PN}/archive/${MY_RELEASE}.zip"
HOMEPAGE="https://mozilla.github.io/rhino/"

LICENSE="MPL-1.1 GPL-2"
SLOT="1.6"
KEYWORDS="amd64 ~arm arm64 ppc64 x86"
IUSE=""

# ../rhino-Rhino1_7_7_RELEASE
S="${WORKDIR}/${PN}-${MY_RELEASE}"

CDEPEND=""
RDEPEND=">=virtual/jre-1.8
	${CDEPEND}"
DEPEND=">=virtual/jdk-1.8
	dev-java/gradle-bin:7.2
	test? (
		dev-java/emma:0
		dev-java/junit:4
		dev-java/ant-junit:0
		dev-java/hamcrest-core:1.3
	)
	${CDEPEND}"

# StackOverFlow errors arise on some tests.
# Further, the test suite takes way too much time (> 5 min).
# Maybe reduce the numbers of tests?
RESTRICT="test"

egradle() {
	local gradle="/usr/bin/gradle-bin-7.2"
	local gradle_args=(
		--info
		--stacktrace
		--no-build-cache
		--no-daemon
		--offline
		--gradle-user-home "${T}/gradle_user_home"
		--project-cache-dir "${T}/gradle_project_cache"
	)

	einfo "gradle "${gradle_args[@]}" ${@}"
	# TERM needed, otherwise gradle may fail on terms it does not know about
	TERM="xterm" "${gradle}" "${gradle_args[@]}" ${@} || die "gradle failed"
}

src_compile() {
	egradle jar
}

src_install() {
	java-pkg_dojar build/${MY_P}/js.jar

	java-pkg_dolauncher jsscript-${SLOT} \
		--main org.mozilla.javascript.tools.shell.Main
}
