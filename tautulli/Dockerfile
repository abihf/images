FROM dhi.io/python:3.14-alpine3.24

ARG TAUTULLI_VERSION=2.19.1
ADD --link https://github.com/Tautulli/Tautulli.git#v${TAUTULLI_VERSION} /app

ENV TAUTULLI_DOCKER=True \
    TZ=UTC \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
VOLUME ["/config"]
EXPOSE 8181

CMD ["python3", "Tautulli.py", "--nolaunch", "--datadir", "/config"]
