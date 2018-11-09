# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmangos-1

DESCRIPTION="C(ontinued)-MaNGOS is about: -- Doing WoW-Emulation Right!"
HOMEPAGE="https://metagit.org/blizzlike/cmangos-tbc"

SLOT="0"
KEYWORDS="~amd64 ~x86"

PDEPEND="world? ( =games-misc/wow-data-2.4.3 )"
