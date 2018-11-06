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
PDEPEND="=games-misc/wow-data-1.12"

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
		dodir "/usr/share/${PN}"
		insinto "/usr/share/${PN}"
		doins "${S}/contrib/extractor_scripts/offmesh.txt"

		mv "${ED}"/usr/bin/tools/* "${ED}/usr/bin" || die
		rmdir "${ED}/usr/bin/tools" || die
	fi

	if use world || use login || use playerbot; then
		dodir /etc
		mv "${ED}/usr/etc" "${ED}/etc/${PN}" || die

		if use playerbot; then
			mv "${ED}/etc/${PN}/playerbot.conf.dist" "${ED}/etc/${PN}/playerbot.conf" || die
		fi

		if use world; then
			newinitd "${FILESDIR}/mangosd.initd" "mangosd-${PN}"
			mv "${ED}/etc/${PN}/mangosd.conf.dist" "${ED}/etc/${PN}/mangosd.conf" || die
			mv "${ED}/usr/bin/mangosd" "${ED}/usr/bin/mangosd-${PN}" || die
			rm "${ED}/usr/bin/run-mangosd" || die

			insinto "/etc/${PN}"
			newins "${S}/src/game/AuctionHouseBot/ahbot.conf.dist.in" ahbot.conf

			sed -i \
				-e 's_DataDir = "."_DataDir = "/usr/share/wow-data-1.12"_' \
				-e "s_LogsDir = \"\"_LogsDir = \"/var/log/${PN}\"_" \
				-e "s_PidFile = \"\"_PidFile = \"/run/${PN}/realmd.pid\"_" \
				-e 's_Console.Enable = 1_Console.Enable = 0_' \
				"${ED}/etc/${PN}/mangosd.conf" || die
		fi

		if use login; then
			newinitd "${FILESDIR}/realmd.initd" "realmd-${PN}"
			mv "${ED}/etc/${PN}/realmd.conf.dist" "${ED}/etc/${PN}/realmd.conf" || die
			mv "${ED}/usr/bin/realmd" "${ED}/usr/bin/realmd-${PN}" || die

			sed -i \
				-e "s_PidFile = \"\"_PidFile = \"/run/${PN}/realmd.pid\"_" \
				-e "s_LogsDir = \"\"_LogsDir = \"/var/log/${PN}\"_" \
				"${ED}/etc/${PN}/realmd.conf" || die
		fi
	fi

	keepdir /var/lib/cmangos
	keepdir /var/log/${PN}
}
