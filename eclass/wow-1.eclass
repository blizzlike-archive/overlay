# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: wow-1.eclass
# @MAINTAINER:
# crito
# @AUTHOR:
# crito
# @BLURB: 
# @DESCRIPTION:

DESCRIPTION="World of Warcraft ${PV} client data"
HOMEPAGE="https://worldofwarcraft.com"
RESTRICT="fetch"
IUSE="mmaps"
S="${WORKDIR}"

#WOW_LANGS="deDE enUS esES frFR koKR ruRU zhCN"
WOW_LANGS="deDE enUS"
WOW_L10NS="de-DE en-US es-ES fr ko ru zh-CN"

EXPORT_FUNCTIONS pkg_nofetch src_configure src_compile src_install

_wow-1_get_cmangos_flavor() {
	if [ "${PV}" = "1.12" ]; then echo "cmangos-vanilla"; fi
	if [ "${PV}" = "2.4.3" ]; then echo "cmangos-tbc"; fi
	if [ "${PV}" = "3.3.5a" ]; then echo "cmangos-wotlk"; fi
}

_wow-1_set_l10n() {
	local lang
	for lang in ${WOW_L10NS}; do
		IUSE_L10N+=" l10n_${lang}"
	done

	REQUIRED_USE="|| ( ${IUSE_L10N} )"
	IUSE+="${IUSE_L10N}"

	local l
	for lang in ${WOW_LANGS}; do
		if [ "${lang}" = "deDE" ]; then l="de-DE"; fi
		if [ "${lang}" = "enUS" ]; then l="en-US"; fi
		if [ "${lang}" = "esES" ]; then l="es-ES"; fi
		if [ "${lang}" = "frFR" ]; then l="fr"; fi
		if [ "${lang}" = "koKR" ]; then l="ko"; fi
		if [ "${lang}" = "ruRU" ]; then l="ru"; fi
		if [ "${lang}" = "zhCN" ]; then l="zh-CN"; fi
		SRC_URI+=" l10n_${l}? ( WoW-${PV}-${lang}.zip )"
	done
}
_wow-1_set_l10n

wow-1_pkg_nofetch() {
	einfo "You have to own a copy of the WoW client."
	einfo "  copy the client to /usr/portage/distfiles/WoW-${PV}-<lang>.zip"
	einfo "  the archive has to have a parent directory named WoW-${PV}-<lang>"
}

wow-1_src_configure() {
	: # not required
}

wow-1_src_compile() {
	local lang="$(wow-1_get_l10n)"
	local cmangos="$(_wow-1_get_cmangos_flavor)"

	for l in ${lang}; do
		einfo "Extracting dbc's (${l})"
		ad-${cmangos} -i "${S}/WoW-${PV}-${l}" -e 2 || die
		mv dbc "${l}" || die
	done

	einfo "Extracting vmaps"
	local l="$(wow-1_get_default_l10n)"

	install -d vmaps
	ad-${cmangos} -i "${S}/WoW-${PV}-${l}" -e 1 || die
	vmap_extractor-${cmangos} -d "${S}/WoW-${PV}-${l}/Data" || die
	vmap_assembler-${cmangos} Buildings vmaps || die

	if use mmaps; then
		einfo "Generating mmaps"
		install -d mmaps
		MoveMapGen-${cmangos} --offMeshInput "/usr/share/${cmangos}/offmesh.txt"
	fi
}

wow-1_src_install() {
	local lang="$(wow-1_get_l10n)"

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

	local l="$(wow-1_get_default_l10n)"
	for f in $(find "${ED}/usr/share/${P}/dbc/${l}" -type f -name "*.dbc"); do
		local dbc="$(basename ${f})"
		dosym "${l}/${dbc}" "/usr/share/${P}/dbc/${dbc}"
	done
}

wow-1_get_l10n() {
	local lang
	lang=" $(usex l10n_de-DE deDE "")"
	lang+=" $(usex l10n_en-US enUS "")"
	lang+=" $(usex l10n_es-ES esES "")"
	lang+=" $(usex l10n_fr frFR "")"
	lang+=" $(usex l10n_ko koKR "")"
	lang+=" $(usex l10n_ru ruRU "")"
	lang+=" $(usex l10n_zh-CN zhCN "")"
	echo "${lang}"
}

wow-1_get_default_l10n() {
	local lang="enUS"
	if ! use l10n_en-US; then
		lang="$(wow-1_get_l10n | awk '{ print $1 }')"
	fi
	echo "${lang}"
}
