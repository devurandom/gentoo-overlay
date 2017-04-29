# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils versionator

MY_P="Field3D-${PV}"

DESCRIPTION="A library for storing voxel data on disk and in memory"
HOMEPAGE="http://sites.google.com/site/field3d/ https://github.com/imageworks/Field3D"
SRC_URI="https://github.com/imageworks/Field3D/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE=""
SLOT="0/$(get_version_component_range 1-2)"
KEYWORDS="~amd64 ~x86"
IUSE="doc mpi"

RESTRICT=""

RDEPEND="dev-libs/boost:=
	media-libs/ilmbase:=
	sci-libs/hdf5:=
	mpi? ( virtual/mpi )"
DEPEND="${RDEPEND}
	dev-util/cmake
	doc? ( app-doc/doxygen )"

S="${WORKDIR}/${MY_P}"

src_configure() {
	local mycmakeargs=(
		$(use doc && echo -DINSTALL_DOCS)
		)

	if ! use doc ; then
		sed -r '/FIND_PACKAGE\s*\(\s*Doxygen\s*\)/d' -i CMakeLists.txt || die
	fi
	if ! use mpi ; then
		sed -r '/FIND_PACKAGE\s*\(\s*MPI\s*\)/d' -i CMakeLists.txt || die
	fi

	cmake-utils_src_configure
}
