# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

MODULE_AUTHOR=JRED
inherit perl-module

DESCRIPTION="GnuPG::GPG handles all the details of encrypting and signing Mails using GnuPG"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND="dev-perl/GnuPG-Interface
	dev-perl/MIME-tools"
