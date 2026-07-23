FROM dhi.io/alpine-base:3.24-dev AS par2
RUN apk add --no-cache make clang22 llvm22-dev lld22 automake autoconf python3

WORKDIR /app

ARG PAR2_COMMIT=033424e74bdb27a053a088e8e58fb380d8ed1498
ADD --link https://github.com/animetosho/par2cmdline-turbo.git#${PAR2_COMMIT} par2cmdline-turbo
ENV CC=clang-22 \
    CXX=clang++-22 \
    AR=llvm22-ar \
    RANLIB=llvm22-ranlib \
    CFLAGS="-march=x86-64-v3 -pipe -fstack-clash-protection -fstack-protector-strong -fno-plt -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -D_GLIBCXX_ASSERTIONS -flto=thin -fuse-ld=lld" \
    CXXFLAGS="-march=x86-64-v3 -pipe -fstack-clash-protection -fstack-protector-strong -fno-plt -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -D_GLIBCXX_ASSERTIONS -flto=thin -fuse-ld=lld" \
    LDFLAGS="-gz -Wl,-O1,--as-needed,--sort-common,-z,now,-z,pack-relative-relocs,-z,relro"

RUN --mount=type=cache,target=/app/par2cmdline-turbo/build sh -euxo pipefail <<EOF
  mkdir -p /tmp
  cd par2cmdline-turbo
  aclocal
  automake --add-missing
  autoconf
  cd build
  ../configure --prefix=/usr || (cat config.log && false)
  make -j$(nproc)
  make install DESTDIR=/out/par2
EOF



FROM dhi.io/python:3.14-alpine3.24-dev
RUN apk add --no-cache ca-certificates libstdc++ libgcc libssl3 tini unzip 7zip libbz2
ARG SABNZBD_COMMIT=3ab1782dc227cb7125d6ef538ace57d79033a39f
ADD --link https://github.com/sabnzbd/sabnzbd.git#${SABNZBD_COMMIT} /app/sabnzbd
WORKDIR /app/sabnzbd
RUN --mount=type=cache,target=/root/.cache/pip pip3 install -r requirements.txt

COPY --link --from=par2 /out/par2 /
ARG UNRAR_VERSION=7.2.7
ADD --link --chmod=755 https://github.com/EDM115/unrar-alpine/releases/download/${UNRAR_VERSION}/unrar /usr/bin/unrar

VOLUME [ "/config" ]
CMD [ "tini", "--", "python3", "SABnzbd.py", "--config-file", "/config/sabnzbd.ini", "--server", "0.0.0.0:8080"]
