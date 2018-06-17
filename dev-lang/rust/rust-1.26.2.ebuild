# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{5,6} pypy )

LLVM_MAX_SLOT=6

inherit multiprocessing multilib-build python-any-r1 versionator toolchain-funcs llvm

if [[ ${PV} = *beta* ]]; then
	betaver=${PV//*beta}
	BETA_SNAPSHOT="${betaver:0:4}-${betaver:4:2}-${betaver:6:2}"
	MY_P="rustc-beta"
	SLOT="beta/${PV}"
	SRC="${BETA_SNAPSHOT}/rustc-beta-src.tar.xz"
	KEYWORDS=""
else
	RUST_ABI="$(get_version_component_range 1-2)"
	SLOT="stable/${RUST_ABI}"
	MY_P="rustc-${PV}"
	SRC="${MY_P}-src.tar.xz"
	KEYWORDS="~amd64 ~arm64 ~x86"
fi

RUST_CHOST_amd64=x86_64-unknown-linux-gnu
RUST_CHOST_x86=i686-unknown-linux-gnu
RUST_CHOST_arm64=aarch64-unknown-linux-gnu

RUST_STAGE0_ABI="1.$(($(get_version_component_range 2) - 1))"
RUST_STAGE0_VERSION="${RUST_STAGE0_ABI}.0"
RUST_STAGE0_amd64="rust-${RUST_STAGE0_VERSION}-${RUST_CHOST_amd64}"
RUST_STAGE0_x86="rust-${RUST_STAGE0_VERSION}-${RUST_CHOST_x86}"
RUST_STAGE0_arm64="rust-${RUST_STAGE0_VERSION}-${RUST_CHOST_arm64}"

CARGO_DEPEND_VERSION="0.$(($(get_version_component_range 2) + 1))"

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="https://www.rust-lang.org/"

SRC_URI="https://static.rust-lang.org/dist/${SRC} -> rustc-${PV}-src.tar.xz
	!system-rust-bootstrap? (
		amd64? ( https://static.rust-lang.org/dist/${RUST_STAGE0_amd64}.tar.xz )
		x86? ( https://static.rust-lang.org/dist/${RUST_STAGE0_x86}.tar.xz )
		x86? ( https://static.rust-lang.org/dist/${RUST_STAGE0_x86}.tar.xz )
	)
"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"

ALL_LLVM_TARGETS=( AArch64 AMDGPU ARM BPF Hexagon Lanai Mips MSP430
	NVPTX PowerPC Sparc SystemZ X86 XCore )
ALL_LLVM_TARGETS=( "${ALL_LLVM_TARGETS[@]/#/llvm_targets_}" )
LLVM_TARGET_USEDEPS=""
for target in "${ALL_LLVM_TARGETS[@]/%/?}" ; do
	LLVM_TARGET_USEDEPS+=",${target}"
done
LLVM_TARGET_USEDEPS="${LLVM_TARGET_USEDEPS#,}"

IUSE="debug doc extended +jemalloc +ninja system-rust-bootstrap system-llvm ${ALL_LLVM_TARGETS[*]}"

RDEPEND=">=app-eselect/eselect-rust-0.3_pre20150425
	jemalloc? ( dev-libs/jemalloc )"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	system-rust-bootstrap? (
		|| (
			dev-lang/rust-bin:${RUST_ABI}
			dev-lang/rust-bin:${RUST_STAGE0_ABI}
			dev-lang/rust:${RUST_ABI}
			dev-lang/rust:${RUST_STAGE0_ABI}
		)
	)
	system-llvm? (
		<sys-devel/llvm-7_pre:=["${LLVM_TARGET_USEDEPS}"]
		|| (
			sys-devel/llvm:6
			sys-devel/llvm:5
			sys-devel/llvm:4
		)
	)
	!system-llvm? (
		ninja? ( dev-util/ninja )
	)
	|| (
		>=sys-devel/gcc-4.7
		>=sys-devel/clang-3.5
	)
	dev-util/cmake
"
PDEPEND="!extended? ( >=dev-util/cargo-${CARGO_DEPEND_VERSION} )"

S="${WORKDIR}/${MY_P}-src"

toml_usex() {
	usex "$1" true false
}

pkg_setup() {
	python-any-r1_pkg_setup
	use system-llvm && llvm_pkg_setup
}

src_prepare() {
	local rust_stage0_root="${WORKDIR}"/rust-stage0

	local rust_stage0_name="RUST_STAGE0_${ARCH}"
	local rust_stage0="${!rust_stage0_name}"

	if ! use system-rust-bootstrap ; then
		"${WORKDIR}/${rust_stage0}"/install.sh --disable-ldconfig --destdir="${rust_stage0_root}" --prefix=/ || die
	fi

	default
}

src_configure() {
	local rust_stage0_root
	if use system-rust-bootstrap ; then
		rust_stage0_root="${EPREFIX}"/usr
	else
		rust_stage0_root="${WORKDIR}"/rust-stage0
	fi

	local rust_target="" rust_targets="" rust_target_name arch_cflags

	# Collect rust target names to compile standard libs for all ABIs.
	for v in $(multilib_get_enabled_abi_pairs); do
		rust_target_name="RUST_CHOST_${v##*.}"
		rust_targets+=",\"${!rust_target_name}\""
	done
	rust_targets="${rust_targets#,}"

	rust_target_name="RUST_CHOST_${ARCH}"
	rust_target="${!rust_target_name}"

	cat <<- EOF > "${S}"/config.toml
		[llvm]
		optimize = $(toml_usex !debug)
		release-debuginfo = $(toml_usex debug)
		assertions = $(toml_usex debug)
		link-shared = $(toml_usex system-llvm)
		ninja = $(toml_usex ninja)
		targets = "${LLVM_TARGETS// /;}"
		[build]
		build = "${rust_target}"
		host = ["${rust_target}"]
		target = [${rust_targets}]
		cargo = "${rust_stage0_root}/bin/cargo"
		rustc = "${rust_stage0_root}/bin/rustc"
		docs = $(toml_usex doc)
		submodules = false
		python = "${EPYTHON}"
		locked-deps = true
		vendor = true
		verbose = 2
		extended = $(toml_usex extended)
		[install]
		prefix = "${EPREFIX}/usr"
		libdir = "$(get_libdir)"
		docdir = "share/doc/${P}"
		mandir = "share/${P}/man"
		[rust]
		debug = $(toml_usex debug)
		optimize = $(toml_usex !debug)
		debuginfo = $(toml_usex debug)
		debuginfo-lines = $(toml_usex debug)
		debug-assertions = $(toml_usex debug)
		use-jemalloc = $(toml_usex jemalloc)
		default-linker = "$(tc-getCC)"
		rpath = false
	EOF

	for v in $(multilib_get_enabled_abi_pairs); do
		rust_target="$(get_abi_var RUST_CHOST ${v##*.})"
		arch_cflags="$(get_abi_CFLAGS ${v##*.})"

		cat <<- EOF >> "${S}"/config.env
			CFLAGS_${rust_target}=${arch_cflags}
		EOF

		cat <<- EOF >> "${S}"/config.toml
			[target.${rust_target}]
			cc = "$(tc-getBUILD_CC)"
			cxx = "$(tc-getBUILD_CXX)"
			linker = "$(tc-getCC "${rust_target}")"
			ar = "$(tc-getAR "${rust_target}")"
		EOF

		if use system-llvm ; then
			local llvm_config="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/${CBUILD}-llvm-config"
			cat <<- EOF >> "${S}"/config.toml
				llvm-config = "${llvm_config}"
			EOF
		fi
	done
}

src_compile() {
	local llvm_config="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/${CBUILD}-llvm-config"
	export RUSTFLAGS=-Clink-arg="$(${llvm_config} --ldflags)"
	export RUST_BACKTRACE=1

	env $(cat "${S}"/config.env | xargs -d '\n') \
		./x.py build --verbose --config="${S}"/config.toml -j$(makeopts_jobs) || die
}

src_install() {
	local rust_target abi_libdir

	env DESTDIR="${D}" ./x.py install || die

	mv "${D}/usr/bin/rustc" "${D}/usr/bin/rustc-${PV}" || die
	mv "${D}/usr/bin/rustdoc" "${D}/usr/bin/rustdoc-${PV}" || die
	mv "${D}/usr/bin/rust-gdb" "${D}/usr/bin/rust-gdb-${PV}" || die
	mv "${D}/usr/bin/rust-lldb" "${D}/usr/bin/rust-lldb-${PV}" || die

	# Copy shared library versions of standard libraries for all targets
	# into the system's abi-dependent lib directories because the rust
	# installer only does so for the native ABI.
	for v in $(multilib_get_enabled_abi_pairs); do
		if [ ${v##*.} = ${DEFAULT_ABI} ]; then
			continue
		fi

		abi_libdir=$(get_abi_LIBDIR ${v##*.})
		rust_target=$(get_abi_CHOST ${v##*.})
		mkdir -p "${D}/usr/${abi_libdir}"
		cp "${D}/usr/$(get_libdir)/rustlib/${rust_target}/lib"/*.so \
			"${D}/usr/${abi_libdir}" || die
	done

	dodoc COPYRIGHT

	if use doc ; then
		dodir /usr/share/doc/rust-"${PV}"
		mv "${D}"/usr/share/doc/rust/* "${D}/usr/share/doc/rust-${PV}/" || die
		rmdir "${D}"/usr/share/doc/rust || die
	fi

	# FIXME:
	# Really not sure if that env is needed, specailly LDPATH
	cat <<-EOF > "${T}"/50${P}
		LDPATH="/usr/$(get_libdir)/${P}"
		MANPATH="/usr/share/${P}/man"
	EOF
	doenvd "${T}"/50${P}

	cat <<-EOF > "${T}/provider-${P}"
		/usr/bin/rustdoc
		/usr/bin/rust-gdb
		/usr/bin/rust-lldb
	EOF
	dodir /etc/env.d/rust
	insinto /etc/env.d/rust
	doins "${T}/provider-${P}"
}

pkg_postinst() {
	eselect rust update --if-unset

	elog "Rust installs a helper script for calling GDB and LLDB,"
	elog "for your convenience it is installed under /usr/bin/rust-{gdb,lldb}-${PV}."

	if has_version app-editors/emacs || has_version app-editors/emacs-vcs; then
		elog "install app-emacs/rust-mode to get emacs support for rust."
	fi

	if has_version app-editors/gvim || has_version app-editors/vim; then
		elog "install app-vim/rust-vim to get vim support for rust."
	fi

	if has_version 'app-shells/zsh'; then
		elog "install app-shells/rust-zshcomp to get zsh completion for rust."
	fi
}

pkg_postrm() {
	eselect rust unset --if-invalid
}
