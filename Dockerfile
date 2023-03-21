FROM gentoo/stage3

ENV FEATURES "-ipc-sandbox -pid-sandbox -network-sandbox"

RUN emerge-webrsync

ENV DISTDIR /tmp/distdir

RUN emerge --newuse -uv layman cmake

ENV PORTDIR_OVERLAY /mnt/gentoo/overlay

ENV CFLAGS "-O3 -fstack-protector-all"

ENV CXXFLAGS "-O3 -fstack-protector-all"

ENV PKGDIR /mnt/dist

VOLUME /var/db/repos/gentoo/

ENV FEATURES "-ipc-sandbox -pid-sandbox -network-sandbox buildpkg"

ENV BINPKG_COMPRESS "xz"

ADD to_deb_pkg /usr/bin/to_deb_pkg

RUN chmod +x /usr/bin/to_deb_pkg

ENTRYPOINT ["emerge"]
