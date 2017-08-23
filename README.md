# mpYALMIP

An interface to the multiple-precision solver [SDPA-GMP](http://sdpa.sourceforge.net/download.html) 
for [YALMIP](http://users.isy.liu.se/johanl/yalmip/) in UNIX-based and Windows systems.

**Windows users:** you can also use SDPA-GMP remotely on the [NEOS server](https://neos-server.org/neos/); check out [mpYALIMP-neos](https://github.com/htadashi/mpYALMIP-neos)!

**Bug report:** a bug in the installer/uninstaller functions in version 1.1 prevents successful installation. If you are using mpYALMIP v1.1, please update to v1.1.1 or later.

## Contents
- [Authors](#Authors)
- [Setup](#Setup)
- [Licence](#Licence)

## Authors<a name="Authors"></a>
- Giovanni Fantuzzi (Department of Aeronautics, Imperial College London, UK. Email: gf910[at]ic.ac.uk)

## Setup<a name="Setup"></a>

The following is a quick installation guide; for more details, see [INSTALL.txt](https://github.com/giofantuzzi/mpYALMIP/blob/master/INSTALL.txt).

#### Preliminary checks

Before you run the script `install_sdpa_gmp.m`, make sure you have installed SDPA-GMP (download & install from the [SDPA website](http://sdpa.sourceforge.net/download.html)).

For detailed instructions to install the required software (for Windows but also valid in UNIX-based systems) see [InstallWindowsReqs.txt](https://github.com/giofantuzzi/mpYALMIP/blob/master/InstallWindowsReqs.txt).


#### Setup

The following instructions assume that the SDPA-GMP executable binary file 
(`sdpa_gmp`) is installed in `/usr/local/bin/`. 
In this case, add SDPA-GMP to YALMIP by running

    >> install_sdpa_gmp 

If you have installed SDPA-GMP in another location, you should be able to add it
to YALMIP by running

    >> install_sdpa_gmp('path/to/sdpa/gmp/')

where `'path/to/sdpa/gmp/'` is the path to your SDPA-GMP installation. The path should be to the `sdpa_gmp` executable itself or to the
directory, ending with `/`, where the `sdpa_gmp` executable lies.

**Note:** please ignore any compilation warnings that might be displayed.


## Licence<a name="Licence"></a>
mpYALMIP is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

