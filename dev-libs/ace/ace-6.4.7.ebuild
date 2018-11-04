# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit multilib

DESCRIPTION="The ADAPTIVE Communication Environment"
HOMEPAGE="https://www.dre.vanderbilt.edu/~schmidt/ACE.html"
SRC_URI="http://download.dre.vanderbilt.edu/previous_versions/ACE+TAO-${PV}.tar.bz2"

LICENSE="BSD as-is"
SLOT="0"
KEYWORDS="amd64 ~ppc ~x86"
IUSE="X +boost +bzip2 +fltk gtk +opengl openmp static-libs +ssl +stl +tao +threads valgrind +xerces-c +zlib"

DEPEND="virtual/pkgconfig
	boost? ( dev-libs/boost )
	fltk? ( x11-libs/fltk[opengl] )
	gtk? ( x11-libs/gtk+ )
	opengl? ( virtual/opengl )
	openmp? ( sys-cluster/openmpi )
	ssl? ( dev-libs/openssl )
	valgrind? ( dev-util/valgrind )
	X? (
		x11-libs/libX11
		x11-libs/libXt
	)
	xerces-c? ( dev-libs/xerces-c )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/ACE_wrappers"

src_configure() {
	echo '#include "ace/config-linux.h"' > "${S}"/ace/config.h
	echo 'INSTALL_PREFIX = /usr' > "${S}"/include/makeinclude/platform_macros.GNU
	echo 'TCPU=native' >> "${S}"/include/makeinclude/platform_macros.GNU
	echo 'archmodelflag=1 ' >> "${S}"/include/makeinclude/platform_macros.GNU
	echo 'stl=1 ' >> "${S}"/include/makeinclude/platform_macros.GNU
	export ACE_ROOT="${S}"
	export TAO_ROOT="${S}/TAO"
	local myparams
	if use bzip2; then
		myparams="${myparams},bzip2=1"
	fi
	if use zlib; then
		myparams="${myparams},zlib=1"
	fi
	if use boost; then
		myparams="${myparams},boost=1"
	fi

	if use fltk; then
		echo 'fl=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		echo 'gl=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		myparams="${myparams},fl=1,gl=1"
	else 
	    if use opengl; then
		echo 'gl=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		myparams="${myparams},gl=1"
	    fi
	fi

	if use ssl; then
		echo 'ssl=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		myparams="${myparams},ssl=1"
	else
		myparams="${myparams},ssl=0"
	fi

	if use xerces-c; then
		echo 'xerces=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		echo 'xerces3=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		myparams="${myparams},xerces=1"
	else
		myparams="${myparams},xerces=0"
	fi

	if use X; then
		echo 'xt=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		myparams="${myparams},xt=1"
	else
		myparams="${myparams},xt=0"
	fi
	echo 'include $(ACE_ROOT)/include/makeinclude/platform_linux.GNU' >> "${S}"/include/makeinclude/platform_macros.GNU

	if use fltk; then
		echo 'PLATFORM_FL_CPPFLAGS=-I/usr/include/fltk' >> "${S}"/include/makeinclude/platform_macros.GNU
		echo 'PLATFORM_FL_LIBS=-L/usr/lib64/fltk -lfltk -lfltk_forms -lfltk_gl' >> "${S}"/include/makeinclude/platform_macros.GNU
	fi

	if use tao; then 
	    cd ${TAO_ROOT} 
	    ../bin/mwc.pl -type gnuace -features ${myparams} TAO_ACE.mwc
	else
	    ./bin/mwc.pl -type gnuace -features ${myparams} ACE.mwc
	fi
}

src_compile() {
	export ACE_ROOT="${S}"
	export TAO_ROOT="${S}/TAO"
	export LD_LIBRARY_PATH="${ACE_ROOT}/lib:${LD_LIBRARY_PATH}"

	if use tao; then 
	    cd ${TAO_ROOT}
	    emake || die "emake failed"
	else
	    emake || die "emake failed"
	fi
}

src_install() {
	if use tao; then 
	    cd ${TAO_ROOT}
	fi
	default
}
