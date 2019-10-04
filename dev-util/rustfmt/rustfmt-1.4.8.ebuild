# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo

CRATES="
aho-corasick-0.7.6
annotate-snippets-0.6.1
ansi_term-0.11.0
arrayref-0.3.5
arrayvec-0.4.11
atty-0.2.13
autocfg-0.1.6
backtrace-0.3.37
backtrace-sys-0.1.31
base64-0.10.1
bitflags-1.1.0
blake2b_simd-0.5.8
bstr-0.2.8
bytecount-0.6.0
byteorder-1.3.2
cargo_metadata-0.8.2
cc-1.0.42
cfg-if-0.1.9
clap-2.33.0
cloudabi-0.0.3
constant_time_eq-0.1.4
crossbeam-channel-0.3.9
crossbeam-deque-0.2.0
crossbeam-epoch-0.3.1
crossbeam-utils-0.2.2
crossbeam-utils-0.6.6
derive-new-0.5.8
diff-0.1.11
dirs-2.0.2
dirs-sys-0.3.4
either-1.5.2
ena-0.13.0
env_logger-0.6.2
failure-0.1.5
failure_derive-0.1.5
fnv-1.0.6
fuchsia-cprng-0.1.1
getopts-0.2.21
getrandom-0.1.12
globset-0.4.4
heck-0.3.1
humantime-1.2.0
ignore-0.4.10
indexmap-1.1.0
itertools-0.8.0
itoa-0.4.4
jobserver-0.1.17
kernel32-sys-0.2.2
lazy_static-1.4.0
libc-0.2.62
lock_api-0.1.5
log-0.4.8
memchr-2.2.1
memoffset-0.2.1
nodrop-0.1.13
num_cpus-1.10.1
owning_ref-0.4.0
packed_simd-0.3.3
parking_lot-0.7.1
parking_lot_core-0.4.0
proc-macro-error-0.2.6
proc-macro2-0.4.30
proc-macro2-1.0.3
quick-error-1.2.2
quote-0.6.13
quote-1.0.2
rand-0.6.5
rand_chacha-0.1.1
rand_core-0.3.1
rand_core-0.4.2
rand_hc-0.1.0
rand_isaac-0.1.1
rand_jitter-0.1.4
rand_os-0.1.3
rand_pcg-0.1.2
rand_xorshift-0.1.1
rdrand-0.4.0
redox_syscall-0.1.56
redox_users-0.3.1
regex-1.3.1
regex-syntax-0.6.12
rust-argon2-0.5.1
rustc-ap-arena-583.0.0
rustc-ap-graphviz-583.0.0
rustc-ap-rustc_data_structures-583.0.0
rustc-ap-rustc_errors-583.0.0
rustc-ap-rustc_lexer-583.0.0
rustc-ap-rustc_macros-583.0.0
rustc-ap-rustc_target-583.0.0
rustc-ap-serialize-583.0.0
rustc-ap-syntax-583.0.0
rustc-ap-syntax_pos-583.0.0
rustc-demangle-0.1.16
rustc-hash-1.0.1
rustc-rayon-0.2.0
rustc-rayon-core-0.2.0
rustc-workspace-hack-1.0.0
rustc_version-0.2.3
ryu-1.0.0
same-file-1.0.5
scoped-tls-1.0.0
scopeguard-0.3.3
semver-0.9.0
semver-parser-0.7.0
serde-1.0.99
serde_derive-1.0.99
serde_json-1.0.40
smallvec-0.6.10
stable_deref_trait-1.1.1
strsim-0.8.0
structopt-0.3.1
structopt-derive-0.3.1
syn-0.15.44
syn-1.0.5
synstructure-0.10.2
term-0.6.1
term_size-0.3.1
termcolor-1.0.5
textwrap-0.11.0
thread_local-0.3.6
toml-0.5.3
unicode-segmentation-1.3.0
unicode-width-0.1.6
unicode-xid-0.1.0
unicode-xid-0.2.0
unicode_categories-0.1.1
vec_map-0.8.1
walkdir-2.2.9
wasi-0.7.0
winapi-0.2.8
winapi-0.3.8
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.2
winapi-x86_64-pc-windows-gnu-0.4.0
wincolor-1.0.2
"

DESCRIPTION="A tool for formatting Rust code according to style guidelines"
HOMEPAGE="https://github.com/rust-lang/rustfmt"
SRC_URI="https://github.com/rust-lang/rustfmt/archive/v${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})
"

RESTRICT="mirror"
LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="doc"

DEPEND=">=virtual/rust-1.24.0"
RDEPEND=""

src_configure() {
	:
}

src_compile() {
	# Building sources
	export CARGO_HOME="${ECARGO_HOME}"
	export RUST_BACKTRACE=1
	cargo build --release --verbose --verbose || die

	# Building HTML documentation
	if use doc ; then
		cargo doc --verbose --verbose || die
	fi
}

src_install() {
	export RUST_BACKTRACE=1
	cargo install --root="${ED}"/usr --verbose --verbose || die

	# Install HTML documentation
	use doc && HTML_DOCS=("target/doc")
	einstalldocs
}

src_test() {
	export RUST_BACKTRACE=1
	cargo test --release --verbose --verbose || die
}
