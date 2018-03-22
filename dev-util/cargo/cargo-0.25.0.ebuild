# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo bash-completion-r1

CRATES="
advapi32-sys-0.2.0
aho-corasick-0.5.3
aho-corasick-0.6.4
atty-0.2.8
backtrace-0.3.5
backtrace-sys-0.1.16
bitflags-0.9.1
bitflags-1.0.1
bufstream-0.1.3
cc-1.0.6
cfg-if-0.1.2
cmake-0.1.29
commoncrypto-0.2.0
commoncrypto-sys-0.2.0
core-foundation-0.4.6
core-foundation-sys-0.4.6
crossbeam-0.2.12
crossbeam-0.3.2
crypto-hash-0.3.1
curl-0.4.11
curl-sys-0.4.1
docopt-0.8.3
dtoa-0.4.2
env_logger-0.4.3
failure-0.1.1
failure_derive-0.1.1
filetime-0.1.15
flate2-1.0.1
fnv-1.0.6
foreign-types-0.3.2
foreign-types-shared-0.1.1
fs2-0.4.3
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
git2-0.6.11
git2-curl-0.7.0
glob-0.2.11
globset-0.2.1
hamcrest-0.1.1
hex-0.2.0
hex-0.3.1
home-0.3.0
idna-0.1.4
ignore-0.2.2
itoa-0.3.4
jobserver-0.1.9
kernel32-sys-0.2.2
lazy_static-0.2.11
lazy_static-1.0.0
libc-0.2.39
libgit2-sys-0.6.19
libssh2-sys-0.2.6
libz-sys-1.0.18
log-0.3.9
log-0.4.1
matches-0.1.6
memchr-0.1.11
memchr-1.0.2
memchr-2.0.1
miniz-sys-0.1.10
miow-0.2.1
net2-0.2.32
num-0.1.42
num-bigint-0.1.43
num-complex-0.1.43
num_cpus-1.8.0
num-integer-0.1.36
num-iter-0.1.35
num-rational-0.1.42
num-traits-0.2.1
openssl-0.10.5
openssl-probe-0.1.2
openssl-sys-0.9.27
percent-encoding-1.0.1
pkg-config-0.3.9
proc-macro2-0.2.3
psapi-sys-0.1.1
quote-0.3.15
quote-0.4.2
rand-0.3.22
rand-0.4.2
redox_syscall-0.1.37
redox_termios-0.1.1
regex-0.1.80
regex-0.2.7
regex-syntax-0.3.9
regex-syntax-0.5.0
remove_dir_all-0.3.0
rustc-demangle-0.1.7
rustc-serialize-0.3.24
same-file-0.1.3
schannel-0.1.11
scoped-tls-0.1.1
scopeguard-0.1.2
semver-0.8.0
semver-parser-0.7.0
serde-1.0.29
serde_derive-1.0.29
serde_derive_internals-0.20.0
serde_ignored-0.0.4
serde_json-1.0.10
shell-escape-0.1.3
socket2-0.3.3
strsim-0.6.0
syn-0.11.11
syn-0.12.14
synom-0.11.3
synstructure-0.6.1
tar-0.4.14
tempdir-0.3.6
termcolor-0.3.5
termion-1.5.1
thread-id-2.0.0
thread_local-0.2.7
thread_local-0.3.5
toml-0.4.5
ucd-util-0.1.1
unicode-bidi-0.3.4
unicode-normalization-0.1.5
unicode-xid-0.0.4
unicode-xid-0.1.0
unreachable-1.0.0
url-1.7.0
userenv-sys-0.2.0
utf8-ranges-0.1.3
utf8-ranges-1.0.0
vcpkg-0.2.2
void-1.0.2
walkdir-1.0.7
winapi-0.2.8
winapi-0.3.4
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
wincolor-0.1.6
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
