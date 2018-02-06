# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cargo

CRATES="
aho-corasick-0.6.4
backtrace-0.3.5
backtrace-sys-0.1.16
bitflags-1.0.1
cargo_metadata-0.4.1
cc-1.0.4
cfg-if-0.1.2
derive-new-0.5.0
diff-0.1.11
dtoa-0.4.2
env_logger-0.4.3
error-chain-0.11.0
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
getopts-0.2.17
itoa-0.3.4
kernel32-sys-0.2.2
lazy_static-1.0.0
libc-0.2.36
log-0.3.9
log-0.4.1
memchr-2.0.1
num-traits-0.1.42
owning_ref-0.3.3
parking_lot-0.5.3
parking_lot_core-0.2.10
quote-0.3.15
rand-0.3.20
regex-0.2.5
regex-syntax-0.4.2
rustc-ap-rustc_cratesio_shim-26.0.0
rustc-ap-rustc_data_structures-26.0.0
rustc-ap-rustc_errors-26.0.0
rustc-ap-serialize-26.0.0
rustc-ap-syntax-26.0.0
rustc-ap-syntax_pos-26.0.0
rustc-demangle-0.1.5
semver-0.8.0
semver-parser-0.7.0
serde-1.0.27
serde_derive-1.0.27
serde_derive_internals-0.19.0
serde_json-1.0.9
smallvec-0.6.0
stable_deref_trait-1.0.0
syn-0.11.11
synom-0.11.3
term-0.4.6
thread_local-0.3.5
toml-0.4.5
unicode-segmentation-1.2.0
unicode-width-0.1.4
unicode-xid-0.0.4
unreachable-1.0.0
utf8-ranges-1.0.0
void-1.0.2
winapi-0.2.8
winapi-0.3.4
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
"

DESCRIPTION="A tool for formatting Rust code according to style guidelines"
HOMEPAGE="https://github.com/rust-lang-nursery/rustfmt"
SRC_URI="https://github.com/rust-lang-nursery/rustfmt/archive/${PV}.tar.gz -> ${P}.tar.gz
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
