FROM ubuntu:26.10

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_MIRROR=http://azure.archive.ubuntu.com/ubuntu

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=Etc/UTC \
    GIT_TERMINAL_PROMPT=0 \
    GIT_EDITOR=true \
    GIT_PAGER=cat \
    PAGER=cat \
    EDITOR=vim \
    MISE_YES=1 \
    MISE_DATA_DIR=/home/ubuntu/.local/share/mise \
    PATH=/home/ubuntu/.local/share/mise/shims:/home/ubuntu/.local/bin:$PATH \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache && \
    echo 'APT::Architecture-Variants "amd64v3";' > /etc/apt/apt.conf.d/99enable-amd64v3 && \
    if [ -n "$APT_MIRROR" ]; then \
        sed -i -E "s#https?://(archive|security)\.ubuntu\.com/ubuntu/?#${APT_MIRROR%/}/#g" /etc/apt/sources.list.d/ubuntu.sources; \
    fi

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl git openssh-client gnupg locales tzdata \
        build-essential pkg-config cmake unzip xz-utils zstd bzip2 \
        libssl-dev zlib1g-dev libffi-dev libreadline-dev libsqlite3-dev \
        libyaml-dev libbz2-dev liblzma-dev libncurses-dev libpq-dev \
        ripgrep fd-find jq file procps lsof psmisc git-lfs rsync \
        iputils-ping dnsutils netcat-openbsd iproute2 strace vim && \
    ln -s /usr/bin/fdfind /usr/local/bin/fd && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

USER ubuntu
WORKDIR /home/ubuntu
