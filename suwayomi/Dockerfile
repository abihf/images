FROM dhi.io/eclipse-temurin:27-alpine

ARG SUWAYOMI_VERSION=2.4.2490
ADD --link --chmod=0755 https://github.com/Suwayomi/Suwayomi-Server-preview/releases/download/v${SUWAYOMI_VERSION}/Suwayomi-Server-v${SUWAYOMI_VERSION}.jar /home/suwayomi/startup/tachidesk_latest.jar

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DBUS_SESSION_BUS_ADDRESS="disabled:"

WORKDIR /home/suwayomi
EXPOSE 4567
CMD ["java", "-Duser.home=/home/suwayomi", "-Djava.util.prefs.userRoot=/home/suwayomi/.local/share/Tachidesk", "-Dfile.encoding=UTF-8", "-Dsun.jnu.encoding=UTF-8", "-jar", "/home/suwayomi/startup/tachidesk_latest.jar"]
