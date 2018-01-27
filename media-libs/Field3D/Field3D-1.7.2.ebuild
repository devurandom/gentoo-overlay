# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils versionator

DESCRIPTION="A library for storing voxel data on disk and in memory"
HOMEPAGE="http://opensource.imageworks.com/?p=field3d"
SRC_URI="https://github.com/imageworks/Field3D/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0/$(get_version_component_range 1-2)"
KEYWORDS="~amd64 ~x86"
IUSE="doc mpi"

RDEPEND="
	>=dev-libs/boost-1.62:=
	>=media-libs/ilmbase-2.2.0:=
	sci-libs/hdf5:=
	mpi? ( virtual/mpi )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( app-doc/doxygen )"

PATCHES=( "${FILESDIR}/${P}-Use-PkgConfig-for-IlmBase.patch" )

src_configure() {
	local mycmakeargs=(
		-DINSTALL_DOCS=$(usex doc)
	)

	if ! use doc ; then
		sed -r '/FIND_PACKAGE\s*\(\s*Doxygen\s*\)/d' -i CMakeLists.txt || die
	fi
	if ! use mpi ; then
		sed -r '/FIND_PACKAGE\s*\(\s*MPI\s*\)/d' -i CMakeLists.txt || die
	fi

	cmake-utils_src_configure
}
