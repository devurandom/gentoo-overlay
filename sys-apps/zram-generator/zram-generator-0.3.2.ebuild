# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cargo systemd

CRATES="
ahash-0.4.7
anyhow-1.0.40
bitflags-1.2.1
cfg-if-0.1.10
cfg-if-1.0.0
clap-2.33.3
dlv-list-0.2.2
fs_extra-1.2.0
getrandom-0.1.16
getrandom-0.2.2
hashbrown-0.9.1
libc-0.2.93
liboverdrop-0.0.2
log-0.4.14
ordered-multimap-0.3.1
ppv-lite86-0.2.10
rand-0.7.3
rand-0.8.3
rand_chacha-0.2.2
rand_chacha-0.3.0
rand_core-0.5.1
rand_core-0.6.2
rand_hc-0.2.0
rand_hc-0.3.0
redox_syscall-0.2.6
remove_dir_all-0.5.3
rust-ini-0.16.1
tempfile-3.2.0
textwrap-0.11.0
unicode-width-0.1.8
wasi-0.10.2+wasi-snapshot-preview1
wasi-0.9.0+wasi-snapshot-preview1
winapi-0.3.9
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0"

DESCRIPTION="Systemd unit generator for zram swap devices"
HOMEPAGE="https://github.com/systemd/zram-generator"
SRC_URI="https://github.com/systemd/zram-generator/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	  $(cargo_crate_uris ${CRATES})"

RESTRICT="mirror"

LICENSE="Apache-2.0 Apache-2.0 WITH LLVM-exception MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

RDEPEND="sys-apps/systemd"
BDEPEND="${RDEPEND}
	virtual/rust
	virtual/pkgconfig
	app-text/pandoc"

src_configure() {
	cargo_src_configure
	sed -e "s,@SYSTEMD_SYSTEM_GENERATOR_DIR@,$(systemd_get_systemgeneratordir)," \
		< units/systemd-zram-setup@.service.in \
		> units/systemd-zram-setup@.service
}

src_compile() {
	export SYSTEMD_UTIL_DIR="$(systemd_get_utildir)"
	cargo_src_compile
	pandoc --to=man --output=man/zram-generator.8 man/zram-generator.md || die
	pandoc --to=man --output=man/zram-generator.conf.5 man/zram-generator.conf.md || die
}

src_install() {
	# https://bugs.gentoo.org/715890
	mv man man.bkp || die
	cargo_src_install
	mv man.bkp man || die
	mkdir -p "${D}/$(systemd_get_systemgeneratordir)" || die
	mv "${D}"/usr/bin/zram-generator "${D}/$(systemd_get_systemgeneratordir)" || die
	systemd_dounit units/systemd-zram-setup@.service
	dodoc zram-generator.conf.example
	doman man/zram-generator.8 man/zram-generator.conf.5
}
