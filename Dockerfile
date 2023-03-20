FROM gentoo/stage3

ENV FEATURES "-ipc-sandbox -pid-sandbox -network-sandbox"

ENV PORTDIR_OVERLAY /mnt/gentoo/overlay

RUN emerge-webrsync

RUN emerge layman cmake

VOLUME /var/db/repos/gentoo/

CMD emerge
