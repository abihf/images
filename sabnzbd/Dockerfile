FROM dhi.io/alpine-base:3.23-dev AS par2
RUN apk add --no-cache make clang21 llvm21-dev lld automake autoconf

WORKDIR /app

ARG PAR2_COMMIT=4db49ca45ab258c230061fb3f0d29273f7c524ea
ADD --link https://github.com/animetosho/par2cmdline-turbo.git#${PAR2_COMMIT} par2cmdline-turbo
ENV CC=clang-21 \
    CXX=clang++-21 \
    AR=llvm21-ar \
    RANLIB=llvm21-ranlib \
    CFLAGS="-march=x86-64-v3 -pipe -fstack-clash-protection -fstack-protector-strong -fno-plt -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -D_GLIBCXX_ASSERTIONS -flto=thin" \
    CXXFLAGS="-march=x86-64-v3 -pipe -fstack-clash-protection -fstack-protector-strong -fno-plt -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -D_GLIBCXX_ASSERTIONS -flto=thin" \
    LDFLAGS="-gz -Wl,-O1,--as-needed,--sort-common,-z,now,-z,pack-relative-relocs,-z,relro,-fuse-ld=lld"

RUN sh -euxo pipefail <<EOF
  mkdir -p /tmp
  cd par2cmdline-turbo
  aclocal
  automake --add-missing
  autoconf
  ./configure --prefix=/usr || (cat config.log && false)
  make
  make install DESTDIR=/out/par2
EOF



FROM dhi.io/python:3.14-alpine3.23-dev
RUN apk add --no-cache ca-certificates libstdc++ libgcc libssl3 tini unzip 7zip libbz2
ARG SABNZBD_COMMIT=33072154d215cc7b4de6c500b9102a88d9640eb1
ADD --link https://github.com/sabnzbd/sabnzbd.git#${SABNZBD_COMMIT} /app/sabnzbd
WORKDIR /app/sabnzbd
RUN --mount=type=cache,target=/root/.cache/pip pip3 install -r requirements.txt

COPY --link --from=par2 /out/par2 /
ADD --link --chmod=755 https://github.com/EDM115/unrar-alpine/releases/download/7.2.2/unrar /usr/bin/unrar

VOLUME [ "/config" ]
CMD [ "tini", "--", "python3", "SABnzbd.py", "--config-file", "/config/sabnzbd.ini", "--server", "0.0.0.0:8080"]
