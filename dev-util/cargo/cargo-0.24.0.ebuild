# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo bash-completion-r1

CRATES="
advapi32-sys-0.2.0
aho-corasick-0.5.3
aho-corasick-0.6.4
atty-0.2.3
backtrace-0.3.4
backtrace-sys-0.1.16
bitflags-0.7.0
bitflags-0.9.1
bitflags-1.0.1
bufstream-0.1.3
cargotest-0.1.0
cc-1.0.4
cfg-if-0.1.2
cmake-0.1.29
commoncrypto-0.2.0
commoncrypto-sys-0.2.0
core-foundation-0.4.4
core-foundation-sys-0.4.4
crates-io-0.13.0
crossbeam-0.2.10
crossbeam-0.3.0
crypto-hash-0.3.0
curl-0.4.8
curl-sys-0.3.15
dbghelp-sys-0.2.0
docopt-0.8.1
dtoa-0.4.2
env_logger-0.4.3
error-chain-0.11.0
filetime-0.1.15
flate2-0.2.20
fnv-1.0.6
foreign-types-0.2.0
fs2-0.4.2
fuchsia-zircon-0.2.1
fuchsia-zircon-sys-0.2.0
git2-0.6.8
git2-curl-0.7.0
glob-0.2.11
globset-0.2.1
hamcrest-0.1.1
hex-0.2.0
home-0.3.0
idna-0.1.4
ignore-0.2.2
itoa-0.3.4
jobserver-0.1.9
kernel32-sys-0.2.2
lazy_static-0.2.11
libc-0.2.36
libgit2-sys-0.6.16
libssh2-sys-0.2.6
libz-sys-1.0.18
log-0.3.8
matches-0.1.6
memchr-0.1.11
memchr-1.0.2
memchr-2.0.0
miniz-sys-0.1.10
miow-0.2.1
net2-0.2.31
num-0.1.41
num-bigint-0.1.41
num-complex-0.1.41
num-integer-0.1.35
num-iter-0.1.34
num-rational-0.1.40
num-traits-0.1.41
num_cpus-1.8.0
openssl-0.9.21
openssl-probe-0.1.1
openssl-sys-0.9.21
percent-encoding-1.0.1
pkg-config-0.3.9
psapi-sys-0.1.0
quote-0.3.15
rand-0.3.18
redox_syscall-0.1.31
redox_termios-0.1.1
regex-0.1.80
regex-0.2.5
regex-syntax-0.3.9
regex-syntax-0.4.2
rustc-demangle-0.1.5
rustc-serialize-0.3.24
same-file-0.1.3
scopeguard-0.1.2
scoped-tls-0.1.0
semver-0.8.0
semver-parser-0.7.0
serde-1.0.27
serde_derive-1.0.27
serde_derive_internals-0.19.0
serde_ignored-0.0.4
serde_json-1.0.9
shell-escape-0.1.3
socket2-0.2.4
strsim-0.6.0
syn-0.11.11
synom-0.11.3
tar-0.4.14
tempdir-0.3.5
termcolor-0.3.3
termion-1.5.1
thread-id-2.0.0
thread_local-0.2.7
thread_local-0.3.4
toml-0.4.5
unicode-bidi-0.3.4
unicode-normalization-0.1.5
unicode-xid-0.0.4
unreachable-1.0.0
url-1.6.0
userenv-sys-0.2.0
utf8-ranges-0.1.3
utf8-ranges-1.0.0
vcpkg-0.2.2
void-1.0.2
walkdir-1.0.7
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
	>=virtual/rust-1.19.0
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
	use amd64 && CTARGET="${CHOST_amd64}"
	use x86 && CTARGET="${CHOST_x86}"

	# Building sources
	export CARGO_HOME="${ECARGO_HOME}"
	export RUST_BACKTRACE=1
	${cargo} build --release --verbose --verbose || die

	# Building HTML documentation
	if use doc ; then
		${cargo} doc --verbose --verbose || die
	fi
}

src_install() {
	local cargo_stagename="CARGO_STAGE0_${ARCH}"
	local cargo_stage0="${!cargo_stagename}"
	local cargo="${WORKDIR}/${cargo_stage0}"/cargo/bin/cargo

	export RUST_BACKTRACE=1
	${cargo} install --root="${ED}"/usr --verbose --verbose || die
	rm "${ED}"/usr/.cargo.toml

	# Install HTML documentation
	use doc && HTML_DOCS=("target/doc")
	einstalldocs

	newbashcomp src/etc/cargo.bashcomp.sh cargo
	insinto /usr/share/zsh/site-functions
	doins src/etc/_cargo
	doman src/etc/man/*

	dobin "${FILESDIR}"/cargo-extract-locked-dependencies.sh
}

src_test() {
	local cargo_stagename="CARGO_STAGE0_${ARCH}"
	local cargo_stage0="${!cargo_stagename}"
	local cargo="${WORKDIR}/${cargo_stage0}"/cargo/bin/cargo

	export RUST_BACKTRACE=1
	${cargo} test --release --verbose --verbose || die
}
