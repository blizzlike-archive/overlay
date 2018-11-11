# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmangos-1

DESCRIPTION="MMORPG server for WoW classic"
HOMEPAGE="https://metagit.org/blizzlike/lh-core"

SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND+="
	dev-cpp/tbb
	dev-libs/utfcpp
	"
PDEPEND="world? ( =games-misc/wow-data-1.12 )"
