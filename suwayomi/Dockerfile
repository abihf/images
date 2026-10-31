FROM dhi.io/eclipse-temurin:25-jdk-debian13-dev AS jlink
RUN jlink \
  --add-modules java.se,jdk.unsupported,jdk.zipfs,jdk.localedata,jdk.charsets,jdk.crypto.cryptoki,jdk.management.agent,jdk.jcmd \
  --strip-java-debug-attributes --no-header-files --no-man-pages --compress=zip-6 \
  --output /opt/java/runtime

FROM dhi.io/debian-base:trixie-debian13-dev AS downloader
ARG SUWAYOMI_VERSION=2.4.2435
ARG SUWAYOMI_DOCKER_COMMIT=fd0d8bf31bc1c85d3c691bea27ccf6cbc169678a
ADD --link --chown=1000:1000 https://github.com/Suwayomi/Suwayomi-Server-preview/releases/download/v${SUWAYOMI_VERSION}/Suwayomi-Server-v${SUWAYOMI_VERSION}.jar /home/suwayomi/startup/tachidesk_latest.jar
ADD --link --chown=1000:1000 --chmod=755 https://raw.githubusercontent.com/Suwayomi/Suwayomi-Server-docker/${SUWAYOMI_DOCKER_COMMIT}/scripts/startup_script.sh /home/suwayomi/startup_script.sh
ADD --link --chown=1000:1000 --chmod=755 https://raw.githubusercontent.com/Suwayomi/Suwayomi-Server-docker/${SUWAYOMI_DOCKER_COMMIT}/scripts/create_server_conf.sh /home/suwayomi/create_server_conf.sh

# image for running (no Xvfb / KCEF / Chromium: sources that need a WebView will not work)
FROM dhi.io/debian-base:trixie-debian13-dev
ENV SOURCE_DATE_EPOCH=0
# unzip: create_server_conf.sh; fontconfig + fonts: headless AWT text rendering used by some extensions
RUN apt-get update && \
  apt-get install -y --no-install-recommends unzip fontconfig fonts-dejavu-core && \
  rm -rf /var/lib/apt/lists/* && \
  echo "suwayomi:x:1000:" >> /etc/group && \
  echo "suwayomi:x:1000:1000::/home/suwayomi:/usr/sbin/nologin" >> /etc/passwd && \
  mkdir -p /home/suwayomi/.local/share/Tachidesk && \
  chown -R suwayomi:suwayomi /home/suwayomi
COPY --link --from=jlink /opt/java/runtime /opt/java/openjdk
COPY --link --from=downloader /home/suwayomi /home/suwayomi
ENV JAVA_HOME=/opt/java/openjdk \
    PATH=/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    KCEF_ENABLED=false
USER 1000:1000
WORKDIR /home/suwayomi
VOLUME ["/home/suwayomi/.local/share/Tachidesk"]
EXPOSE 4567
CMD ["/home/suwayomi/startup_script.sh"]
