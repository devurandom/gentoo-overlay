# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=2

CMAKE_IN_SOURCE_BUILD=1
inherit cmake-utils mercurial

MY_PN="dynamic-playlist"
EHG_REPO_URI="http://bitbucket.org/misery/${MY_PN}"

DESCRIPTION="Dynamic-playlist will search for similar songs/artists with lastfm or the genre tag."
HOMEPAGE="http://gmpc.wikia.com/wiki/GMPC_PLUGIN_DYNAMIC_PLAYLIST"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~ppc-macos ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE=""

DEPEND=">=media-sound/gmpc-0.19.0"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}"
