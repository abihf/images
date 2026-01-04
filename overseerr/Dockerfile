FROM dhi.io/node:24-alpine3.22-dev AS builder
WORKDIR /app
ARG OVERSEERR_COMMIT=5ef098f6d844dde6d5d9076c8814e9a34bd73451
ADD --link https://github.com/sct/overseerr.git#${OVERSEERR_COMMIT} /app
RUN --mount=type=cache,target=/root/.cache/yarn \
    yarn install --frozen-lockfile

RUN --mount=type=cache,target=/app/.next/cache yarn build

RUN --mount=type=cache,target=/root/.cache/yarn \
    yarn install --frozen-lockfile --production

# ------------------
# image for running

FROM dhi.io/node:24-alpine3.22
WORKDIR /app
COPY --link --from=builder /app/package.json /app/next.config.js /app/overseerr-api.yml ./
COPY --link --from=builder /app/node_modules ./node_modules
COPY --link --from=builder /app/public ./public
COPY --link --from=builder /app/dist ./dist
COPY --link --from=builder /app/.next ./.next
VOLUME [ "/app/config/" ]
ENV NODE_ENV=production
CMD [ "node", "./dist/index.js" ]