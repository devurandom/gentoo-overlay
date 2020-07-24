# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/ROCm-Developer-Tools/HIP.git"
	inherit git-r3
else
	SRC_URI="https://github.com/ROCm-Developer-Tools/HIP/archive/rocm-${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/HIP-rocm-${PV}"
fi

DESCRIPTION="C++ Heterogeneous-Compute Interface for Portability "
HOMEPAGE="https://github.com/ROCm-Developer-Tools/HIP"
LICENSE="MIT"
SLOT="0"

RDEPEND="
	>=dev-libs/rocm-device-libs-3.5
	>=sys-devel/llvm-roc-3.5
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${P}"-remove-test-target.patch
	"${FILESDIR}/${P}"-change-install-location.patch
)

src_configure() {
	local mycmakeargs=(
		-DINSTALL_SOURCE=0
		-DHIP_COMPILER=clang
		-DHIP_PLATFORM=rocclr
    -DROCclr_DIR="${ESYSROOT}"/usr/include/rocclr
    -DLIBROCclr_STATIC_DIR="${ESYSROOT}"/usr/"$(get_libdir)"/cmake/rocclr
		-DHSA_PATH="${ESYSROOT}/usr"
		-DROCM_PATH="${ESYSROOT}/usr"
		-DROCM_PATCH_VERSION="$(ver_cut 3)"
	)
	cmake_src_configure
}
