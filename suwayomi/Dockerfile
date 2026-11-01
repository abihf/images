FROM dhi.io/eclipse-temurin:25-jdk-debian13-dev AS jlink
RUN jlink \
  --add-modules java.se,jdk.unsupported,jdk.zipfs,jdk.localedata,jdk.charsets,jdk.crypto.cryptoki,jdk.management.agent,jdk.jcmd \
  --strip-java-debug-attributes --no-header-files --no-man-pages --compress=zip-6 \
  --output /opt/java/runtime

FROM dhi.io/debian-base:trixie-debian13-dev
ENV SOURCE_DATE_EPOCH=0
RUN apt-get update && \
  apt-get install -y --no-install-recommends unzip fontconfig fonts-dejavu-core && \
  rm -rf /var/lib/apt/lists/* && \
  echo "suwayomi:x:1000:" >> /etc/group && \
  echo "suwayomi:x:1000:1000::/home/suwayomi:/usr/sbin/nologin" >> /etc/passwd && \
  mkdir -p /home/suwayomi/.local/share/Tachidesk && \
  chown -R suwayomi:suwayomi /home/suwayomi

COPY --link --from=jlink /opt/java/runtime /opt/java/openjdk

ARG SUWAYOMI_VERSION=2.4.2435
ADD --link --chown=1000:1000 https://github.com/Suwayomi/Suwayomi-Server-preview/releases/download/v${SUWAYOMI_VERSION}/Suwayomi-Server-v${SUWAYOMI_VERSION}.jar /home/suwayomi/startup/tachidesk_latest.jar

ENV JAVA_HOME=/opt/java/openjdk \
    PATH=/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    DBUS_SESSION_BUS_ADDRESS="disabled:"
USER 1000:1000
WORKDIR /home/suwayomi
VOLUME ["/home/suwayomi/.local/share/Tachidesk"]
EXPOSE 4567
CMD ["java", "-Duser.home=/home/suwayomi", "-jar", "/home/suwayomi/startup/tachidesk_latest.jar"]
