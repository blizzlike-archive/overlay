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
#IUSE="mmaps"

DEPEND="
	games-server/cmangos-classic[extractors]
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
		install -d "${l}" "${l}/vmaps"

		einfo "Extracting dbc's and maps (${l})"
		ad -i "${S}/WoW-1.12-${l}" -o "${l}" || die

		einfo "Extracating vmaps (${l})"
		pushd "${WORKDIR}/${l}" || die
		vmap_extractor -d "${S}/WoW-1.12-${l}/Data" || die
		popd || die

		einfo "Assemble vmaps (${l})"
		vmap_assembler "${l}/Buildings" "${l}/vmaps" || die
		rm -rf "${l}/Buildings" || die
	done
}

src_install() {
	local lang="$(wow_get_l10n)"

	dodir "/usr/share/${P}"
	insinto "/usr/share/${P}"

	for l in ${lang}; do
		doins -r "${WORKDIR}/${l}"
	done
}
