# gentoo-overlay-builder
A reliable way to build vendored libraries for C/C++ projects using Gentoo Layman and Gentoo Ebuilds


## How to use it 

- in the root of your src tree, `mkdir -p gentoo/overlay`

The tree will look similar to this 
```
tree gentoo
gentoo
└── overlay
    ├── metadata
    │   └── layout.conf
    ├── net-irc
    │   └── clandestine
    │       ├── Manifest
    │       └── clandestine-9999.ebuild
    ├── profiles
    │   └── repo_name
    └── repositories.xml
```

### repositories.xml 
```
<repositories version="1.1" encoding="unicode">
  <repo quality="experimental" priority="50">
    <name>clandestine</name>
    <description />
    <owner>
      <email>no-reply@netcrave.io</email>
      <name>clandestine</name>
    </owner>
    <source type="git">https://github.com/paigeadelethompson</source>
  </repo>
</repositories>
```

### profiles/repo_name
```
clandestine
```

### metadata/layout.conf
```
masters = gentoo
```

### net-irc/clandestine/clandestine-9999.ebuild
```
EAPI=8

inherit cmake

KEYWORDS="alpha amd64 arm arm64 hppa ia64 m68k ppc ppc64 s390 sh sparc x86"

SLOT=0

DEPEND="
  >=dev-libs/utfcpp-3.2.1
  >=sys-libs/libxcrypt-4.4.28-r2
  >=dev-libs/libpcre-8.45-r1
  >=dev-libs/libpcre2-10.42-r1
  >=dev-libs/re2-0.2022.12.01
  >=app-crypt/argon2-3.0
  >=net-libs/http-parser-2.9.4-r2
  >=dev-libs/libmaxminddb-1.7.1
  >=dev-libs/openssl-1.1.1t
  >=media-gfx/qrencode-4.1.1
  >=net-libs/mbedtls-2.28.1
  >=net-libs/gnutls-3.7.8
  >=dev-db/sqlite-3.40.1
  >=net-nds/openldap-2.6.3-r7
  >=dev-db/postgresql-14.5
  >=dev-db/mysql-connector-c-8.0.31
"

CMAKE_MAKEFILE_GENERATOR=emake

src_unpack() {
        mkdir clandestine-9999/
	cp -rvp /mnt/. clandestine-9999/
}


src_configure() {
        cmake_src_configure
}
```

### Manifest checksums
```
docker run -it --rm -v /path/to/your/src/tree:/mnt --entrypoint ebuild paigeadele/gentoo-overlay-builder:latest /mnt/gentoo/overlay/net-irc/clandestine/clandestine-9999.ebuild manifest
```
### Building 
```
docker run -it --rm -v /path/to/your/src/tree:/mnt paigeadele/gentoo-overlay-builder:latest clandestine::clandestine
```

## Result 
Your source tree will have a `dist/` directory that contains your built project and it's dependencies, you should add this to your `.gitignore` 
```
tree dist
dist
├── Packages
├── acct-group
│   ├── ldap
│   │   └── ldap-0-1.xpak
│   └── postgres
│       └── postgres-0-r1-1.xpak
├── acct-user
│   ├── ldap
│   │   └── ldap-0-1.xpak
│   └── postgres
│       └── postgres-0-r1-1.xpak
├── app-arch
│   └── lz4
│       └── lz4-1.9.4-1.xpak
├── app-crypt
│   └── argon2
│       └── argon2-20190702-r1-1.xpak
├── app-eselect
│   └── eselect-postgresql
│       └── eselect-postgresql-2.4-r1-1.xpak
├── dev-db
│   ├── lmdb
│   │   └── lmdb-0.9.29-1.xpak
│   ├── mysql-connector-c
│   │   └── mysql-connector-c-8.0.31-1.xpak
│   └── postgresql
│       └── postgresql-14.5-1.xpak
├── dev-libs
│   ├── libmaxminddb
│   │   └── libmaxminddb-1.7.1-1.xpak
│   ├── libpcre
│   │   └── libpcre-8.45-r1-1.xpak
│   ├── re2
│   │   └── re2-0.2022.12.01-1.xpak
│   └── utfcpp
│       └── utfcpp-3.2.1-1.xpak
├── media-gfx
│   └── qrencode
│       └── qrencode-4.1.1-1.xpak
├── net-irc
│   └── clandestine
│       └── clandestine-9999-1.xpak
├── net-libs
│   ├── http-parser
│   │   └── http-parser-2.9.4-r2-1.xpak
│   └── mbedtls
│       └── mbedtls-2.28.1-1.xpak
└── net-nds
    └── openldap
        └── openldap-2.6.3-r7-1.xpak

```

and the files are in `.XZ` format 
```
file dist/net-irc/clandestine/clandestine-9999-1.xpak
dist/net-irc/clandestine/clandestine-9999-1.xpak: XZ compressed data, checksum CRC64
```

### More info 
https://wiki.gentoo.org/wiki/Binary_package_guide#Understanding_the_binary_package_format


## Converting xpaks to debs
- add `deb/` to root `.gitignore`
```
Package: hello
Version: 1.0
Architecture: arm64
Maintainer: Internal Pointers <info@internalpointers.com>
Description: A program that greets you.
 You can add a longer description here. Mind the space at the beginning of this paragraph.
```
- Run the step to build the xpaks 
- Split the xpacks into the deb directory 
```
docker run -it --rm -v /path/to/your/src/tree:/mnt --entrypoint /bin/bash --workdir /mnt/deb paigeadele/gentoo-overlay-builder:latest find /mnt/dist -type f -name "*.xpak" | xargs -i qtbz2 -s {} && rm *.xpak
```
- extract 
```
docker run -it --rm -v /path/to/your/src/tree:/mnt --entrypoint /bin/bash --workdir /mnt/deb paigeadele/gentoo-overlay-builder:latest ls -1 *.bz2 | xargs -i mkdir $(basename {} .xpak.tar.bz2)/debian
```
