# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: wow-1.eclass
# @MAINTAINER:
# crito
# @AUTHOR:
# crito
# @BLURB: 
# @DESCRIPTION:

#WOW_LANGS="deDE enUS esES frFR koKR ruRU zhCN"
WOW_LANGS="deDE enUS"
WOW_L10NS="de-DE en-US es-ES fr ko ru zh-CN"

EXPORT_FUNCTIONS src_configure

_wow_set_l10n() {
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
_wow_set_l10n

wow-1_src_configure() {
	: # not required
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
