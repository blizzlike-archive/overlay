# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit wow-1

DESCRIPTION="World of Warcraft ${PV} client data"
HOMEPAGE="https://worldofwarcraft.com"
RESTRICT="fetch"

LICENSE="WoW-EULA-2006-JUNE"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="mmaps"

DEPEND="
	games-server/cmangos-vanilla[extractors]
	"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "You have to own a copy of the WoW client."
	einfo "  copy the client to /usr/portage/distfiles/WoW-1.12-<lang>.zip"
	einfo "  the archive has to have a parent directory named WoW-1.12-<lang>"
}

src_configure() {
	: # not required
}

src_compile() {
	local lang="$(wow_get_l10n)"

	for l in ${lang}; do
		einfo "Extracting dbc's (${l})"
		ad -i "${S}/WoW-1.12-${l}" -e 2 || die
		mv dbc "${l}" || die
	done

	einfo "Extracting vmaps"
	local l="enUS"
	if ! use l10n_en-US; then
		l="$(echo ${lang} | awk '{ print $1 }')"
	fi

	install -d vmaps
	ad -i "${S}/WoW-1.12-${l}" -e 1 || die
	vmap_extractor -d "${S}/WoW-1.12-${l}/Data" || die
	vmap_assembler Buildings vmaps || die

	if use mmaps; then
		einfo "Generating mmaps"
		install -d mmaps
		MoveMapGen --offMeshInput /usr/share/cmangos-vanilla/offmesh.txt
	fi
}

src_install() {
	local lang="$(wow_get_l10n)"

	dodir "/usr/share/${P}"
	insinto "/usr/share/${P}"

	doins -r "${WORKDIR}/maps"
	doins -r "${WORKDIR}/vmaps"

	if use mmaps; then
		doins -r "${WORKDIR}/mmaps"
	fi

	for l in ${lang}; do
		einfo "Installing dbc's (${l})"
		dodir "/usr/share/${P}/dbc"
		insinto "/usr/share/${P}/dbc"
		doins -r "${WORKDIR}/${l}"
	done
}
