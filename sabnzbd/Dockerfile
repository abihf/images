FROM alpine:latest AS par2
RUN apk add --no-cache make clang20 llvm20-dev lld automake autoconf

WORKDIR /app

ADD --link https://github.com/animetosho/par2cmdline-turbo.git par2cmdline-turbo
ENV CC=clang-20 \
    CXX=clang++-20 \
    AR=llvm20-ar \
    CFLAGS="-march=x86-64-v3 -pipe -fstack-clash-protection -fstack-protector-strong -fno-plt -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -D_GLIBCXX_ASSERTIONS -flto=thin" \
    CXXFLAGS="-march=x86-64-v3 -pipe -fstack-clash-protection -fstack-protector-strong -fno-plt -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -D_GLIBCXX_ASSERTIONS -flto=thin" \
    LDFLAGS="-gz -Wl,-O1,--as-needed,--sort-common,-z,now,-z,pack-relative-relocs,-z,relro,-fuse-ld=lld"

RUN sh -euxo pipefail <<EOF
  cd par2cmdline-turbo
  aclocal
  automake --add-missing
  autoconf
  ./configure --prefix=/usr
  make
  make install DESTDIR=/out/par2
EOF



FROM python:3.14-alpine
RUN apk add --no-cache ca-certificates libstdc++ libgcc libssl3 tini unzip 7zip
ADD --link https://github.com/sabnzbd/sabnzbd.git /app/sabnzbd
WORKDIR /app/sabnzbd
RUN pip3 install --upgrade -r requirements.txt

COPY --link --from=par2 /out/par2 /
ADD --link --chmod=755 https://github.com/EDM115/unrar-alpine/releases/download/7.1.10/unrar /usr/bin/unrar

VOLUME [ "/config" ]
CMD [ "tini", "--", "python3", "SABnzbd.py", "--config-file", "/config/sabnzbd.ini", "--server", "0.0.0.0:8080"]
