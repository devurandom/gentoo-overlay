# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo bash-completion-r1

CRATES="
advapi32-sys-0.2.0
aho-corasick-0.5.3
aho-corasick-0.6.3
atty-0.2.2
backtrace-0.3.2
backtrace-sys-0.1.11
bitflags-0.9.1
bufstream-0.1.3
cfg-if-0.1.2
cmake-0.1.24
crossbeam-0.2.10
curl-0.4.7
curl-sys-0.3.14
dbghelp-sys-0.2.0
docopt-0.8.1
dtoa-0.4.1
env_logger-0.4.3
error-chain-0.11.0-rc.2
filetime-0.1.10
flate2-0.2.19
foreign-types-0.2.0
fs2-0.4.2
gcc-0.3.51
git2-0.6.6
git2-curl-0.7.0
glob-0.2.11
hamcrest-0.1.1
hex-0.2.0
idna-0.1.2
itoa-0.3.1
jobserver-0.1.6
kernel32-sys-0.2.2
lazy_static-0.2.8
libc-0.2.25
libgit2-sys-0.6.12
libssh2-sys-0.2.6
libz-sys-1.0.16
log-0.3.8
matches-0.1.6
memchr-0.1.11
memchr-1.0.1
miniz-sys-0.1.9
miow-0.2.1
net2-0.2.29
num-0.1.39
num-bigint-0.1.39
num-complex-0.1.38
num_cpus-1.6.2
num-integer-0.1.34
num-iter-0.1.33
num-rational-0.1.38
num-traits-0.1.39
openssl-0.9.14
openssl-probe-0.1.1
openssl-sys-0.9.14
percent-encoding-1.0.0
pkg-config-0.3.9
psapi-sys-0.1.0
quote-0.3.15
rand-0.3.15
regex-0.1.80
regex-0.2.2
regex-syntax-0.3.9
regex-syntax-0.4.1
rustc-demangle-0.1.4
rustc-serialize-0.3.24
scoped-tls-0.1.0
semver-0.7.0
semver-parser-0.7.0
serde-1.0.9
serde_derive-1.0.9
serde_derive_internals-0.15.1
serde_ignored-0.0.3
serde_json-1.0.2
shell-escape-0.1.3
socket2-0.2.1
strsim-0.6.0
syn-0.11.11
synom-0.11.3
tar-0.4.13
tempdir-0.3.5
termcolor-0.3.2
thread-id-2.0.0
thread_local-0.2.7
thread_local-0.3.4
toml-0.4.2
unicode-bidi-0.3.4
unicode-normalization-0.1.5
unicode-xid-0.0.4
unreachable-1.0.0
url-1.5.1
utf8-ranges-0.1.3
utf8-ranges-1.0.0
vcpkg-0.2.2
void-1.0.2
winapi-0.2.8
winapi-build-0.1.1
wincolor-0.1.4
ws2_32-sys-0.2.1
"

CHOST_amd64=x86_64-unknown-linux-gnu
CHOST_x86=i686-unknown-linux-gnu

CARGO_STAGE0_VERSION="${PV}"
CARGO_STAGE0_amd64="cargo-${CARGO_STAGE0_VERSION}-${CHOST_amd64}"
CARGO_STAGE0_x86="cargo-${CARGO_STAGE0_VERSION}-${CHOST_x86}"

DESCRIPTION="The Rust's package manager"
HOMEPAGE="http://crates.io"
SRC_URI="https://github.com/rust-lang/cargo/archive/${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})
	amd64? ( https://static.rust-lang.org/dist/${CARGO_STAGE0_amd64}.tar.gz )
	x86? ( https://static.rust-lang.org/dist/${CARGO_STAGE0_x86}.tar.gz )
"

RESTRICT="mirror"
LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="doc libressl"

COMMON_DEPEND="sys-libs/zlib
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	net-libs/libssh2
	net-libs/http-parser"
RDEPEND="${COMMON_DEPEND}
	!dev-util/cargo-bin
	net-misc/curl[ssl]"
DEPEND="${COMMON_DEPEND}
	>=dev-lang/rust-1.9.0:stable
	dev-lang/python
	dev-util/cmake
	sys-apps/coreutils
	sys-apps/diffutils
	sys-apps/findutils
	sys-apps/sed"

src_configure() {
	:
}

src_compile() {
	local cargo_stagename="CARGO_STAGE0_${ARCH}"
	local cargo_stage0="${!cargo_stagename}"
	local cargo="${WORKDIR}/${cargo_stage0}"/cargo/bin/cargo

	# Cargo only supports these GNU triples:
	# - Linux: <arch>-unknown-linux-gnu
	# - MacOS: <arch>-apple-darwin
	# - Windows: <arch>-pc-windows-gnu
	# where <arch> could be 'x86_64' (amd64) or 'i686' (x86)
	use amd64 && CTARGET="x86_64-unknown-linux-gnu"
	use x86 && CTARGET="i686-unknown-linux-gnu"

	# Building sources
	export CARGO_HOME="${ECARGO_HOME}"
	export RUST_BACKTRACE=1
	${cargo} build --release --verbose --verbose

	# Building HTML documentation
	use doc && ${cargo} doc --verbose --verbose
}

src_install() {
	local cargo_stagename="CARGO_STAGE0_${ARCH}"
	local cargo_stage0="${!cargo_stagename}"
	local cargo="${WORKDIR}/${cargo_stage0}"/cargo/bin/cargo

	export RUST_BACKTRACE=1
	${cargo} install --root="${ED}"/usr --verbose --verbose
	rm "${ED}"/usr/.cargo.toml

	# Install HTML documentation
	use doc && HTML_DOCS=("target/doc")
	einstalldocs

	newbashcomp src/etc/cargo.bashcomp.sh cargo
	insinto /usr/share/zsh/site-functions
	doins src/etc/_cargo
	doman src/etc/man/*
}

src_test() {
	local cargo_stagename="CARGO_STAGE0_${ARCH}"
	local cargo_stage0="${!cargo_stagename}"
	local cargo="${WORKDIR}/${cargo_stage0}"/cargo/bin/cargo

	export RUST_BACKTRACE=1
	${cargo} test --release --verbose --verbose
}
