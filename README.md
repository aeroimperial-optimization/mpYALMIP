# mpYALMIP

An interface to the multiple-precision solver [SDPA-GMP](http://sdpa.sourceforge.net/download.html) 
for [YALMIP](http://users.isy.liu.se/johanl/yalmip/) in UNIX systems.

## Contents
- [Authors](#Authors)
- [Setup](#Setup)
- [Licence](#Licence)

## Authors<a name="Authors"></a>
- Giovanni Fantuzzi (Department of Aeronautics, Imperial College London, UK. Email: gf910[at]ic.ac.uk)

## Setup<a name="Setup"></a>

The following is a quick installation guide; for more details, see [INSTALL.txt](https://github.com/giofantuzzi/mpYALMIP/blob/master/INSTALL.txt).

#### Preliminary checks

Before you run the script `install_sdpa_gmp.m`, make sure you have installed

1. SDPA-GMP: download & install from the [SDPA website](http://sdpa.sourceforge.net/download.html)
2. SDPA MATLAB toolbox (SDPA-M): this should be installed with the standard version of SDPA (see [here](http://sdpa.sourceforge.net/download.html) for details).


In MATLAB, run 

    >> yalmiptest
 
to check if YALMIP finds SDPA - if so, you have SDPA-M installed.


#### Setup

The following instructions assume that the SDPA-GMP executable binary file 
(`sdpa_gmp`) is 
installed in `/usr/local/bin/`. This should be the case if you issued the command
`make install` after compiling SDPA-GMP. 
In this case, add SDPA-GMP to YALMIP by running

    >> install_sdpa_gmp 

If you have installed SDPA-GMP in another location, you should be able to add it
to YALMIP by running

    >> install_sdpa_gmp('path/to/sdpa/gmp')

where `'path/to/sdpa/gmp'` is the path to your SDPA-GMP installation.

**Note:** please ignore any compilation warnings that might be displayed.


## Licence<a name="Licence"></a>
mpYALMIP is free software: you can redistribute it and/or modify it 
under the terms of the GNU Lesser General Public License, version 3.0 
(LGPL-3.0) as published by the Free Software Foundation, or (at your option)
any later version.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License, version 3.0 for more details.

You should have received a copy of the GNU Lesser General Public License, 
version 3.0 along with this program.  If not, see <https://www.gnu.org/licenses/lgpl.html>.

