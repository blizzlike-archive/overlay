# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit user cmake-utils git-r3

DESCRIPTION="C(ontinued)-MaNGOS is about: -- Doing WoW-Emulation Right!"
HOMEPAGE="https://metagit.org/blizzlike/cmangos-tbc"
EGIT_REPO_URI="https://metagit.org/blizzlike/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pch debug playerbot extractors postgres +world +login +scriptdev"

RDEPEND="
	!postgres? ( virtual/mysql )
	postgres? (
		dev-libs/ace
		dev-db/postgresql
	)
	dev-libs/openssl
	sys-libs/zlib
	app-arch/bzip2
	dev-libs/boost[static-libs]
	!games-server/cmangos-classic
	"
DEPEND="${RDEPEND}"

pkg_setup() {
	enewgroup cmangos
	enewuser cmangos -1 -1 /var/lib/${PN} cmangos
}

src_configure() {
	local mycmakeargs=(
		-DPCH="$(usex pch)"
		-DDEBUG="$(usex debug)"
		-DPOSTGRESQL="$(usex postgres)"
		-DBUILD_PLAYERBOT="$(usex playerbot)"
		-DBUILD_EXTRACTORS="$(usex extractors)"
		-DBUILD_GAME_SERVER="$(usex world)"
		-DBUILD_LOGIN_SERVER="$(usex login)"
		-DBUILD_SCRIPTDEV="$(usex scriptdev)"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	if use extractors; then
		mv ${ED}/usr/bin/tools/* ${ED}/usr/bin || die
		rmdir ${ED}/usr/bin/tools || die
	fi

	if use world || use login; then
		mv ${ED}/usr/etc ${ED}/etc || die

		if use world; then
			mv ${ED}/etc/mangosd.conf.dist ${ED}/etc/mangosd.conf || die
		fi

		if use login; then
			mv ${ED}/etc/realmd.conf.dist ${ED}/etc/realmd.conf || die
		fi
	fi
}
