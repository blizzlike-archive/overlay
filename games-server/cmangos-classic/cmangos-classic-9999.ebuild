# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit user cmake-utils git-r3

DESCRIPTION="C(ontinued)-MaNGOS (Classic fork) is about: -- Doing WoW-Emulation Right!"
HOMEPAGE="https://metagit.org/blizzlike/cmangos-classic"
EGIT_REPO_URI="https://metagit.org/blizzlike/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pch debug playerbot extractors postgres +world +login +scriptdev"

RDEPEND="
	!postgres? ( virtual/mysql )
	postgres? ( dev-db/postgresql )
	dev-libs/openssl
	sys-libs/zlib
	app-arch/bzip2
	dev-libs/boost[static-libs]
	"
DEPEND="${RDEPEND}"

pkg_setup() {
	enewgroup cmangos
	enewuser cmangos -1 -1 /var/lib/cmangos cmangos
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
		-DCMAKE_SKIP_INSTALL_RPATH=ON
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	if use extractors; then
		mv ${ED}/usr/bin/tools/* ${ED}/usr/bin || die
		rmdir ${ED}/usr/bin/tools || die
	fi

	if use world || use login || use playerbot; then
		install -d ${ED}/etc
		mv ${ED}/usr/etc ${ED}/etc/cmangos || die

		if use playerbot; then
			mv ${ED}/etc/cmangos/playerbot.conf.dist ${ED}/etc/cmangos/playerbot-classic.conf || die
		fi

		if use world; then
			newinitd "${FILESDIR}"/mangosd.initd mangosd-${PN}
			mv ${ED}/etc/cmangos/mangosd.conf.dist ${ED}/etc/cmangos/mangosd-classic.conf || die
			mv ${ED}/usr/bin/mangosd ${ED}/usr/bin/mangosd-${PN} || die
			rm ${ED}/usr/bin/run-mangosd || die

			insinto /etc/cmangos
			newins ${S}/src/game/AuctionHouseBot/ahbot.conf.dist.in ahbot-classic.conf

			sed -i \
				-e 's_DataDir = "."_DataDir = "/var/lib/cmangos/classic"_' \
				-e 's_LogsDir = ""_LogsDir = "/var/log/cmangos-classic"_' \
				-e 's_PidFile = ""_PidFile = "/run/cmangos/realmd-classic.pid"_' \
				-e 's_Console.Enable = 1_Console.Enable = 0_' \
				${ED}/etc/cmangos/mangosd-classic.conf || die
		fi

		if use login; then
			newinitd "${FILESDIR}"/realmd.initd realmd-${PN}
			mv ${ED}/etc/cmangos/realmd.conf.dist ${ED}/etc/cmangos/realmd-classic.conf || die
			mv ${ED}/usr/bin/realmd ${ED}/usr/bin/realmd-${PN} || die

			sed -i \
				-e 's_PidFile = ""_PidFile = "/run/cmangos/realmd-classic.pid"_' \
				-e 's_LogsDir = ""_LogsDir = "/var/log/cmangos-classic"_' \
				${ED}/etc/cmangos/realmd-classic.conf || die
		fi
	fi

	keepdir /var/lib/cmangos/classic
	keepdir /var/log/${PN}
}
