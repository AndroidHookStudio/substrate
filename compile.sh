#!/bin/bash

# Cydia Substrate - Powerful Code Insertion Platform
# Copyright (C) 2008-2010  Jay Freeman (saurik)

# GNU Lesser General Public License, Version 3 {{{
#
# Substrate is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# Substrate is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
# License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Substrate.  If not, see <http://www.gnu.org/licenses/>.
# }}}

set -e

ios=-i3.2
mac=-m10.5

flags=(-O2 -g0 -isystem extra -fno-exceptions)

./cyc "${ios}" "${mac}" -olibsubstrate.dylib -- "${flags[@]}" -dynamiclib MachMemory.cpp Hooker.cpp ObjectiveC.mm nlist.cpp hde64c/src/hde64.c Debug.cpp \
    -framework CoreFoundation \
    -install_name /Library/Frameworks/CydiaSubstrate.framework/Versions/A/CydiaSubstrate \
    -undefined dynamic_lookup \
    -Ihde64c/include

./cyc "${ios}" "${mac}" -oMobileSubstrate.dylib -- "${flags[@]}" -dynamiclib Bootstrap.cpp

./cyc "${ios}" "${mac}" -oMobileLoader.dylib -- "${flags[@]}" -dynamiclib Loader.mm \
    -framework CoreFoundation

./cyc "${ios}" -oMobileSafety.dylib -- "${flags[@]}" -dynamiclib MobileSafety.mm \
    -framework CoreFoundation -framework Foundation -framework UIKit \
    -L. -lsubstrate -lobjc

for name in extrainst_ postrm; do
    ./cyc "${ios}" -o"${name}" -- "${name}".m "${flags[@]}" \
        -framework CoreFoundation -framework Foundation
done

for arch in ppc i386 arm; do
    sudo ./package.sh "${arch}"
done

sudo dpkg -i *"_$(grep ^Version: control | cut -d ' ' -f 2)_$(dpkg-architecture -qDEB_HOST_ARCH 2>/dev/null).deb"
