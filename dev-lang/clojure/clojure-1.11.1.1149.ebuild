# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

TOOLS_BUILD_PV="0.8.1"
JAVA_PKG_IUSE="test"

inherit java-pkg-2

DESCRIPTION="General-purpose programming language with an emphasis on functional programming"
HOMEPAGE="https://clojure.org/"
SRC_URI="
	https://github.com/clojure/brew-install/archive/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/clojure/tools.build/archive/v${TOOLS_BUILD_PV}.tar.gz -> clojure-tools-build-${TOOLS_BUILD_PV}.tar.gz
"

LICENSE="EPL-1.0 Apache-2.0 BSD"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64 ~x86 ~x86-linux"

RDEPEND="
	!dev-lang/clojure:1.10
	>=virtual/jre-1.8"

DEPEND="
	>=dev-lang/clojure-1.10.3
	>=virtual/jdk-1.8"

S="${WORKDIR}/brew-install-${PV}"

DOCS=( CHANGELOG.md README.md )

PATCHES=(
	"${FILESDIR}/${P}"-use-tools-build-snapshot.patch
	"${FILESDIR}/${PN}"-1.10.3.1040-use-jvm-opts-when-make-classpath.patch
)

# Even though some of this stuff will not be used at runtime, it is all
# required in order to satisfy the maven build system.
# The syntax of each item follows what Maven uses in its error messages, which
# makes updating the list by trial-running the ebuild easier.
# Each item may optionally consist of two words (separated by one whitespace),
# where the first word would be the remote repository, defaulting to Maven
# Central if absent.
# The basic idea is borrowed from the net-p2p/bisq-0.6.3 ebuild.
EMAVEN_ARTIFACTS=(
	aopalliance:aopalliance:jar:1.0
	aopalliance:aopalliance:pom:1.0
	com.cognitect.aws:api:jar:0.8.539
	com.cognitect.aws:api:pom:0.8.539
	com.cognitect.aws:endpoints:jar:1.1.12.150
	com.cognitect.aws:endpoints:pom:1.1.12.150
	com.cognitect.aws:s3:jar:814.2.1053.0
	com.cognitect.aws:s3:pom:814.2.1053.0
	com.cognitect:http-client:jar:1.0.110
	com.cognitect:http-client:pom:1.0.110
	com.google.code.findbugs:jsr305:jar:3.0.2
	com.google.code.findbugs:jsr305:pom:3.0.2
	com.google.errorprone:error_prone_annotations:jar:2.7.1
	com.google.errorprone:error_prone_annotations:pom:2.7.1
	com.google.errorprone:error_prone_parent:pom:2.7.1
	com.google:google:pom:5
	com.google.guava:failureaccess:jar:1.0.1
	com.google.guava:failureaccess:pom:1.0.1
	com.google.guava:guava:jar:31.0.1-android
	com.google.guava:guava-parent:pom:26.0-android
	com.google.guava:guava-parent:pom:31.0.1-android
	com.google.guava:guava:pom:31.0.1-android
	com.google.guava:listenablefuture:jar:9999.0-empty-to-avoid-conflict-with-guava
	com.google.guava:listenablefuture:pom:9999.0-empty-to-avoid-conflict-with-guava
	com.google.inject:guice:jar:no_aop:4.2.2
	com.google.inject:guice-parent:pom:4.2.2
	com.google.inject:guice:pom:4.2.2
	com.google.j2objc:j2objc-annotations:jar:1.3
	com.google.j2objc:j2objc-annotations:pom:1.3
	commons-codec:commons-codec:jar:1.11
	commons-codec:commons-codec:pom:1.11
	commons-io:commons-io:jar:2.11.0
	commons-io:commons-io:pom:2.11.0
	commons-logging:commons-logging:jar:1.2
	commons-logging:commons-logging:pom:1.2
	javax.annotation:javax.annotation-api:jar:1.2
	javax.annotation:javax.annotation-api:pom:1.2
	javax.inject:javax.inject:jar:1
	javax.inject:javax.inject:pom:1
	net.java:jvnet-parent:pom:3
	org.apache:apache:pom:13
	org.apache:apache:pom:18
	org.apache:apache:pom:19
	org.apache:apache:pom:21
	org.apache:apache:pom:23
	org.apache.commons:commons-lang3:jar:3.8.1
	org.apache.commons:commons-lang3:pom:3.8.1
	org.apache.commons:commons-parent:pom:34
	org.apache.commons:commons-parent:pom:42
	org.apache.commons:commons-parent:pom:47
	org.apache.commons:commons-parent:pom:52
	org.apache.httpcomponents:httpclient:jar:4.5.13
	org.apache.httpcomponents:httpclient:pom:4.5.13
	org.apache.httpcomponents:httpcomponents-client:pom:4.5.13
	org.apache.httpcomponents:httpcomponents-core:pom:4.4.13
	org.apache.httpcomponents:httpcomponents-parent:pom:11
	org.apache.httpcomponents:httpcore:jar:4.4.13
	org.apache.httpcomponents:httpcore:pom:4.4.13
	org.apache.maven:maven-artifact:jar:3.8.4
	org.apache.maven:maven-artifact:pom:3.8.4
	org.apache.maven:maven-builder-support:jar:3.8.4
	org.apache.maven:maven-builder-support:pom:3.8.4
	org.apache.maven:maven-core:jar:3.8.4
	org.apache.maven:maven-core:pom:3.8.4
	org.apache.maven:maven-model-builder:jar:3.8.4
	org.apache.maven:maven-model-builder:pom:3.8.4
	org.apache.maven:maven-model:jar:3.8.4
	org.apache.maven:maven-model:pom:3.8.4
	org.apache.maven:maven-parent:pom:34
	org.apache.maven:maven-plugin-api:jar:3.8.4
	org.apache.maven:maven-plugin-api:pom:3.8.4
	org.apache.maven:maven:pom:3.8.4
	org.apache.maven:maven-repository-metadata:jar:3.8.4
	org.apache.maven:maven-repository-metadata:pom:3.8.4
	org.apache.maven:maven-resolver-provider:jar:3.8.4
	org.apache.maven:maven-resolver-provider:pom:3.8.4
	org.apache.maven:maven-settings-builder:jar:3.8.4
	org.apache.maven:maven-settings-builder:pom:3.8.4
	org.apache.maven:maven-settings:jar:3.8.4
	org.apache.maven:maven-settings:pom:3.8.4
	org.apache.maven.resolver:maven-resolver-api:jar:1.6.3
	org.apache.maven.resolver:maven-resolver-api:pom:1.6.3
	org.apache.maven.resolver:maven-resolver-connector-basic:jar:1.6.3
	org.apache.maven.resolver:maven-resolver-connector-basic:pom:1.6.3
	org.apache.maven.resolver:maven-resolver-impl:jar:1.6.3
	org.apache.maven.resolver:maven-resolver-impl:pom:1.6.3
	org.apache.maven.resolver:maven-resolver:pom:1.6.3
	org.apache.maven.resolver:maven-resolver-spi:jar:1.6.3
	org.apache.maven.resolver:maven-resolver-spi:pom:1.6.3
	org.apache.maven.resolver:maven-resolver-transport-file:jar:1.6.3
	org.apache.maven.resolver:maven-resolver-transport-file:pom:1.6.3
	org.apache.maven.resolver:maven-resolver-transport-http:jar:1.6.3
	org.apache.maven.resolver:maven-resolver-transport-http:pom:1.6.3
	org.apache.maven.resolver:maven-resolver-util:jar:1.6.3
	org.apache.maven.resolver:maven-resolver-util:pom:1.6.3
	org.apache.maven.shared:maven-shared-components:pom:34
	org.apache.maven.shared:maven-shared-utils:jar:3.3.4
	org.apache.maven.shared:maven-shared-utils:pom:3.3.4
	org.checkerframework:checker-compat-qual:jar:2.5.5
	org.checkerframework:checker-compat-qual:pom:2.5.5
	org.checkerframework:checker-qual:jar:3.12.0
	org.checkerframework:checker-qual:pom:3.12.0
	org.clojure:clojure:jar:1.11.0
	org.clojure:clojure:jar:1.11.1
	org.clojure:clojure:pom:1.11.0
	org.clojure:clojure:pom:1.11.1
	org.clojure:core.async:jar:1.5.644
	org.clojure:core.async:pom:1.5.644
	org.clojure:core.cache:jar:1.0.225
	org.clojure:core.cache:pom:1.0.225
	org.clojure:core.memoize:jar:1.0.253
	org.clojure:core.memoize:pom:1.0.253
	org.clojure:core.specs.alpha:jar:0.2.62
	org.clojure:core.specs.alpha:pom:0.2.62
	org.clojure:data.codec:jar:0.1.0
	org.clojure:data.codec:pom:0.1.0
	org.clojure:data.json:jar:2.4.0
	org.clojure:data.json:pom:2.4.0
	org.clojure:data.priority-map:jar:1.1.0
	org.clojure:data.priority-map:pom:1.1.0
	org.clojure:data.xml:jar:0.2.0-alpha6
	org.clojure:data.xml:pom:0.2.0-alpha6
	org.clojure:java.classpath:jar:1.0.0
	org.clojure:java.classpath:pom:1.0.0
	org.clojure:pom.contrib:pom:0.0.25
	org.clojure:pom.contrib:pom:0.2.2
	org.clojure:pom.contrib:pom:1.0.0
	org.clojure:pom.contrib:pom:1.1.0
	org.clojure:spec.alpha:jar:0.3.218
	org.clojure:spec.alpha:pom:0.3.218
	org.clojure:tools.analyzer:jar:1.1.0
	org.clojure:tools.analyzer.jvm:jar:1.2.1
	org.clojure:tools.analyzer.jvm:pom:1.2.1
	org.clojure:tools.analyzer:pom:1.1.0
	org.clojure:tools.cli:jar:1.0.206
	org.clojure:tools.cli:pom:1.0.206
	org.clojure:tools.deps.alpha:jar:0.12.1148
	org.clojure:tools.deps.alpha:jar:0.14.1212
	org.clojure:tools.deps.alpha:pom:0.12.1148
	org.clojure:tools.deps.alpha:pom:0.14.1212
	org.clojure:tools.gitlibs:jar:2.4.172
	org.clojure:tools.gitlibs:jar:2.4.181
	org.clojure:tools.gitlibs:pom:2.4.172
	org.clojure:tools.gitlibs:pom:2.4.181
	org.clojure:tools.logging:jar:1.2.1
	org.clojure:tools.logging:pom:1.2.1
	org.clojure:tools.namespace:jar:1.2.0
	org.clojure:tools.namespace:pom:1.2.0
	org.clojure:tools.reader:jar:1.3.6
	org.clojure:tools.reader:pom:1.3.6
	org.codehaus.plexus:plexus-cipher:jar:2.0
	org.codehaus.plexus:plexus-cipher:pom:2.0
	org.codehaus.plexus:plexus-classworlds:jar:2.6.0
	org.codehaus.plexus:plexus-classworlds:pom:2.6.0
	org.codehaus.plexus:plexus-component-annotations:jar:2.1.0
	org.codehaus.plexus:plexus-component-annotations:pom:2.1.0
	org.codehaus.plexus:plexus-containers:pom:2.1.0
	org.codehaus.plexus:plexus-interpolation:jar:1.26
	org.codehaus.plexus:plexus-interpolation:pom:1.26
	org.codehaus.plexus:plexus:pom:5.1
	org.codehaus.plexus:plexus:pom:8
	org.codehaus.plexus:plexus-sec-dispatcher:jar:2.0
	org.codehaus.plexus:plexus-sec-dispatcher:pom:2.0
	org.codehaus.plexus:plexus-utils:jar:3.4.1
	org.codehaus.plexus:plexus-utils:pom:3.3.0
	org.codehaus.plexus:plexus-utils:pom:3.4.1
	org.eclipse.jetty:jetty-client:jar:9.4.44.v20210927
	org.eclipse.jetty:jetty-client:pom:9.4.44.v20210927
	org.eclipse.jetty:jetty-http:jar:9.4.44.v20210927
	org.eclipse.jetty:jetty-http:pom:9.4.44.v20210927
	org.eclipse.jetty:jetty-io:jar:9.4.44.v20210927
	org.eclipse.jetty:jetty-io:pom:9.4.44.v20210927
	org.eclipse.jetty:jetty-project:pom:9.4.44.v20210927
	org.eclipse.jetty:jetty-util:jar:9.4.44.v20210927
	org.eclipse.jetty:jetty-util:pom:9.4.44.v20210927
	org.eclipse.sisu:org.eclipse.sisu.inject:jar:0.3.5
	org.eclipse.sisu:org.eclipse.sisu.inject:pom:0.3.5
	org.eclipse.sisu:org.eclipse.sisu.plexus:jar:0.3.5
	org.eclipse.sisu:org.eclipse.sisu.plexus:pom:0.3.5
	org.eclipse.sisu:sisu-inject:pom:0.3.5
	org.eclipse.sisu:sisu-plexus:pom:0.3.5
	org.junit:junit-bom:pom:5.7.2
	org.junit:junit-bom:pom:5.8.1
	org.ow2.asm:asm:jar:5.2
	org.ow2.asm:asm-parent:pom:5.2
	org.ow2.asm:asm:pom:5.2
	org.ow2:ow2:pom:1.3
	org.slf4j:jcl-over-slf4j:jar:1.7.30
	org.slf4j:jcl-over-slf4j:pom:1.7.30
	org.slf4j:slf4j-api:jar:1.7.32
	org.slf4j:slf4j-api:pom:1.7.32
	org.slf4j:slf4j-nop:jar:1.7.32
	org.slf4j:slf4j-nop:pom:1.7.32
	org.slf4j:slf4j-parent:pom:1.7.30
	org.slf4j:slf4j-parent:pom:1.7.32
	org.sonatype.oss:oss-parent:pom:5
	org.sonatype.oss:oss-parent:pom:7
	org.sonatype.oss:oss-parent:pom:9
)

__extract_info() {
	local f="$1" host="$2" artifact="$3"
	local rest="${artifact}" group name type version classifier
	group=${rest%%:*}
	rest=${rest#*:}
	name=${rest%%:*}
	rest=${rest#*:}
	type=${rest%%:*}
	rest=${rest#*:}
	version=${rest%%:*}

	if ! [[ "${rest}" = "${rest#*:}" ]] ; then
		classifier="${version}"
		rest=${rest#*:}
		version=${rest%%:*}
	fi

	${f} "${host}" "${group}" "${name}" "${type}" "${version}" "${classifier}" || die
}

__jar_and_pom() {
	local f="$1" host="$2" group="$3" name="$4" type="$5" version="$6" classifier="$7"
	${f} "${host}" "${group}" "${name}" "${type}" "${version}" "${classifier}" || die
	# For JARs we also always need POMs:
	if [[ "${type}" = jar ]] ; then
		${f} "${host}" "${group}" "${name}" pom "${version}" "${classifier}" || die
	fi
}

__add_to_src_uri() {
	local host="$1" group="$2" name="$3" type="$4" version="$5" classifier="$6"
	local path="${group//.//}"
	local directory="${path}/${name}/${version}" file="${name}-${version}.${type}"
	if [[ "${type}" != pom ]] && [[ -n "${classifier}" ]] ; then
		file="${name}-${version}-${classifier}.${type}"
	fi
	SRC_URI+=" ${host}/${directory}/${file} -> ${group}:${file}"
}

__set_vendor_uri() {
	local lib host artifact
	for lib in "${EMAVEN_ARTIFACTS[@]}"; do
		host=${lib%% *}
		[[ "${host}" = "${lib}" ]] && host="https://repo.maven.apache.org/maven2"
		artifact=${lib##* }
		__extract_info '__jar_and_pom __add_to_src_uri' "${host}" "${artifact}" || die
	done
}

__set_vendor_uri
unset -f __set_vendor_uri __src_uri __add_to_src_uri

pkg_setup() {
	java-pkg_init
}

__copy_to_maven_repository() {
	local host="$1" group="$2" name="$3" type="$4" version="$5" classifier="$6"
	local path="${group//.//}"
	local maven_repository="${HOME}/.m2/repository"
	local directory="${path}/${name}/${version}" file="${name}-${version}.${type}"
	if [[ "${type}" != pom ]] && [[ -n "${classifier}" ]] ; then
		file="${name}-${version}-${classifier}.${type}"
	fi
	mkdir -p "${maven_repository}/${directory}" || die
	cp "${DISTDIR}/${group}:${file}" "${maven_repository}/${directory}/${file}" || die
}

src_unpack() {
	unpack "${P}.tar.gz"
	unpack clojure-tools-build-"${TOOLS_BUILD_PV}".tar.gz
	local lib artifact
	for lib in "${EMAVEN_ARTIFACTS[@]}"; do
		artifact=${lib##* }
		__extract_info '__jar_and_pom __copy_to_maven_repository' '' "${artifact}" || die
	done
}

src_prepare() {
	java-pkg-2_src_prepare
	default
}

src_configure() {
	:
}

src_compile() {
	clojure -J-Duser.home="${HOME}" -X:build release || die

	# Our install_dir is JAVA_PKG_SHAREPATH, a variable we cannot access here:
	local install_dir=/usr/share/"${PN}-${SLOT%/*}"

	sed -i target/clojure-tools/clojure \
		-e "s,PREFIX,${install_dir}," \
		|| die
	sed -i target/clojure-tools/clj \
		-e "s,BINDIR,/usr/bin," \
		|| die
}

src_install() {
	# See script/release.sh for how to build a package.
	# Third-party Clojure tools expect to find JARs and deps.edn in certain
	# locations relative to `:install-dir` printed by `clj -Sdescribe`, with
	# their original names including a version number, which does not follow
	# Gentoo Java packaging standards.  We hence adhere to the Clojure way
	# of installing things, to make these tools work.

	einstalldocs

	# Our install_dir is JAVA_PKG_SHAREPATH, a variable we cannot access here:
	local install_dir=/usr/share/"${PN}-${SLOT%/*}"

	cd target/clojure-tools

	doman clojure.1 clj.1

	java-pkg_jarinto "${install_dir}"/libexec
	java-pkg_dojar clojure-tools-"${PV}".jar exec.jar

	insinto "${install_dir}"
	doins deps.edn example-deps.edn tools.edn

	dobin clojure clj
}
