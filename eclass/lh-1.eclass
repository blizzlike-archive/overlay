# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: lh-1.eclass
# @MAINTAINER:
# crito
# @AUTHOR:
# crito
# @BLURB: 
# @DESCRIPTION:

inherit user cmake-utils git-r3

EGIT_REPO_URI="https://metagit.org/blizzlike/${PN}.git"

LICENSE="GPL-2"
IUSE="anticheat curl debug extractors pch +scripts sql"

RDEPEND="
	virtual/mysql
	dev-libs/openssl
	sys-libs/zlib
	app-arch/bzip2
	dev-libs/ace
	dev-cpp/tbb
	dev-libs/utfcpp
	"
DEPEND="${RDEPEND}"
PDEPEND="=games-misc/wow-data-1.12"

EXPORT_FUNCTIONS pkg_setup src_configure src_install

lh-1_pkg_setup() {
	enewgroup lh
	enewuser lh -1 -1 /var/lib/lh lh
}

lh-1_src_configure() {
	local mycmakeargs=(
		-DPCH="$(usex pch)"
		-DDEBUG="$(usex debug)"
		-DUSE_ANTICHEAT="$(usex anticheat)"
		-DUSE_LIBCURL="$(usex curl)"
		-DUSE_EXTRACTORS="$(usex extractors)"
		-DSCRIPTS="$(usex scripts)"
		-DCMAKE_SKIP_INSTALL_RPATH=ON
		-DUSE_GENERIC_CXX_FLAGS=ON
	)

	cmake-utils_src_configure
}

lh-1_src_install() {
	cmake-utils_src_install

	if use extractors; then
		dodir "/usr/share/${PN}"
		insinto "/usr/share/${PN}"
		doins "${S}/contrib/mmap/offmesh.txt"

		mv "${ED}/usr/bin/MoveMapGen" "${ED}/usr/bin/MoveMapGen-${PN}" || die
		mv "${ED}/usr/bin/mapextractor" "${ED}/usr/bin/mapextractor-${PN}" || die
		mv "${ED}/usr/bin/vmap_assembler" "${ED}/usr/bin/vmap_assembler-${PN}" || die
		mv "${ED}/usr/bin/vmapextractor" "${ED}/usr/bin/vmapextractor-${PN}" || die
	fi

	dodir /etc
	mv "${ED}/usr/etc" "${ED}/etc/${PN}" || die

	if [ -f "${FILESDIR}/mangosd.initd" ]; then
		newinitd "${FILESDIR}/mangosd.initd" "mangosd-${PN}"
	fi
	mv "${ED}/etc/${PN}/mangosd.conf.dist" "${ED}/etc/${PN}/mangosd.conf" || die
	mv "${ED}/usr/bin/mangosd" "${ED}/usr/bin/mangosd-${PN}" || die
	rm "${ED}/usr/bin/run-mangosd" || die

	insinto "/etc/${PN}"
	newins "${S}/src/mangosd/mods.conf.dist.in" mods.conf

	local wdv="1.12"

	sed -i \
		-e "s_DataDir = \".\"_DataDir = \"/usr/share/wow-data-${wdv}\"_" \
		-e "s_LogsDir = \"\"_LogsDir = \"/var/log/${PN}\"_" \
		-e "s_PidFile = \"\"_PidFile = \"/run/${PN}/mangosd.pid\"_" \
		-e 's_Console.Enable = 1_Console.Enable = 0_' \
		"${ED}/etc/${PN}/mangosd.conf" || die

	if [ -f "${FILESDIR}/realmd.initd" ]; then
		newinitd "${FILESDIR}/realmd.initd" "realmd-${PN}"
	fi
	mv "${ED}/etc/${PN}/realmd.conf.dist" "${ED}/etc/${PN}/realmd.conf" || die
	mv "${ED}/usr/bin/realmd" "${ED}/usr/bin/realmd-${PN}" || die

	sed -i \
		-e "s_PidFile = \"\"_PidFile = \"/run/${PN}/realmd.pid\"_" \
		-e "s_LogsDir = \"\"_LogsDir = \"/var/log/${PN}\"_" \
		"${ED}/etc/${PN}/realmd.conf" || die

	if use sql; then
		dodir /usr/share/${PN}
		insinto /usr/share/${PN}
		doins -r ${S}/sql
	fi

	keepdir /var/lib/lh
	keepdir /var/log/${PN}
	fowners lh /var/log/${PN}
}
