# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cmangos-1.eclass
# @MAINTAINER:
# crito
# @AUTHOR:
# crito
# @BLURB: 
# @DESCRIPTION:

inherit user cmake-utils git-r3

EGIT_REPO_URI="https://metagit.org/blizzlike/${PN}.git"

LICENSE="GPL-2"
IUSE="debug extractors +login pch playerbot postgres +scriptdev2 sql +world"
REQUIRED_USE="
	playerbot? ( world )
	scriptdev2? ( world )
	postgres? ( || ( login world ) )
	|| ( extractors login world )
	"

RDEPEND="
	!postgres? ( virtual/mysql )
	postgres? ( dev-db/postgresql )
	dev-libs/openssl
	sys-libs/zlib
	app-arch/bzip2
	dev-libs/boost[static-libs]
	"
DEPEND="${RDEPEND}"

EXPORT_FUNCTIONS pkg_setup src_configure src_install

cmangos-1_pkg_setup() {
	enewgroup cmangos
	enewuser cmangos -1 -1 /var/lib/cmangos cmangos
}

cmangos-1_src_configure() {
	local mycmakeargs=(
		-DPCH="$(usex pch)"
		-DDEBUG="$(usex debug)"
		-DPOSTGRESQL="$(usex postgres)"
		-DBUILD_PLAYERBOT="$(usex playerbot)"
		-DBUILD_EXTRACTORS="$(usex extractors)"
		-DBUILD_GAME_SERVER="$(usex world)"
		-DBUILD_LOGIN_SERVER="$(usex login)"
		-DBUILD_SCRIPTDEV="$(usex scriptdev2)"
		-DCMAKE_SKIP_INSTALL_RPATH=ON
	)

	cmake-utils_src_configure
}

cmangos-1_src_install() {
	cmake-utils_src_install

	if use extractors; then
		dodir "/usr/share/${PN}"
		insinto "/usr/share/${PN}"
		doins "${S}/contrib/extractor_scripts/offmesh.txt"

		mv "${ED}/usr/bin/tools/MoveMapGen" "${ED}/usr/bin/MoveMapGen-${PN}" || die
		mv "${ED}/usr/bin/tools/ad" "${ED}/usr/bin/ad-${PN}" || die
		mv "${ED}/usr/bin/tools/vmap_assembler" "${ED}/usr/bin/vmap_assembler-${PN}" || die
		mv "${ED}/usr/bin/tools/vmap_extractor" "${ED}/usr/bin/vmap_extractor-${PN}" || die
		rmdir "${ED}/usr/bin/tools" || die
	fi

	if use world || use login || use playerbot; then
		dodir /etc
		mv "${ED}/usr/etc" "${ED}/etc/${PN}" || die

		if use playerbot; then
			mv "${ED}/etc/${PN}/playerbot.conf.dist" "${ED}/etc/${PN}/playerbot.conf" || die
		fi

		if use world; then
			if [ -f "${FILESDIR}/mangosd.initd" ]; then
				newinitd "${FILESDIR}/mangosd.initd" "mangosd-${PN}"
			fi
			mv "${ED}/etc/${PN}/mangosd.conf.dist" "${ED}/etc/${PN}/mangosd.conf" || die
			mv "${ED}/usr/bin/mangosd" "${ED}/usr/bin/mangosd-${PN}" || die
			rm "${ED}/usr/bin/run-mangosd" || die

			insinto "/etc/${PN}"
			newins "${S}/src/game/AuctionHouseBot/ahbot.conf.dist.in" ahbot.conf

			sed -i \
				-e 's_DataDir = "."_DataDir = "/usr/share/wow-data-1.12"_' \
				-e "s_LogsDir = \"\"_LogsDir = \"/var/log/${PN}\"_" \
				-e "s_PidFile = \"\"_PidFile = \"/run/${PN}/mangosd.pid\"_" \
				-e 's_Console.Enable = 1_Console.Enable = 0_' \
				"${ED}/etc/${PN}/mangosd.conf" || die
		fi

		if use login; then
			if [ -f "${FILESDIR}/realmd.initd" ]; then
				newinitd "${FILESDIR}/realmd.initd" "realmd-${PN}"
			fi
			mv "${ED}/etc/${PN}/realmd.conf.dist" "${ED}/etc/${PN}/realmd.conf" || die
			mv "${ED}/usr/bin/realmd" "${ED}/usr/bin/realmd-${PN}" || die

			sed -i \
				-e "s_PidFile = \"\"_PidFile = \"/run/${PN}/realmd.pid\"_" \
				-e "s_LogsDir = \"\"_LogsDir = \"/var/log/${PN}\"_" \
				"${ED}/etc/${PN}/realmd.conf" || die
		fi
	fi

	if use sql; then
		dodir /usr/share/${PN}
		insinto /usr/share/${PN}
		doins -r ${S}/sql
	fi

	keepdir /var/lib/cmangos
	keepdir /var/log/${PN}
	fowners cmangos /var/log/${PN}
}
