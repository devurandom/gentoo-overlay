# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=5

DESCRIPTION="CPU/GPU debugging and profiling suite by AMD"
HOMEPAGE="https://gpuopen.com/compute-product/codexl/"
SRC_URI="amd64? ( http://developer.amd.com/download/CodeXL-Linux-${PV}-x86_64-release.tar.gz )"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"

IUSE=""
RESTRICT="strip"

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}"/CodeXL-Linux-${PV}-x86_64-release/Output_x86_64/release/bin

src_install() {
	local LAUNCHER="CodeXL"

	for f in AMD_CodeXL_Release_Notes.pdf Readme.txt Help/CodeXL_Quick_Start_Guide.pdf ; do
		dodoc "${f}"
	done

	dodir /opt/amd/codexl
	cp -r . "${D}"/opt/amd/codexl || die

	dodir /opt/bin
	dosym ../amd/codexl/"${LAUNCHER}" /opt/bin/"${LAUNCHER}"
}
