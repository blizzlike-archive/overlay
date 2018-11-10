# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit wow-1

LICENSE="WoW-EULA-2008"
SLOT="2"
KEYWORDS="amd64 ~x86"

DEPEND="
	games-server/cmangos-wotlk[extractors]
	"
