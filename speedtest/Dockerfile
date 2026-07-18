FROM dhi.io/rust:1-alpine3.24-dev AS base
WORKDIR /app

FROM base AS builder
ARG SPEEDTEST_COMMIT=6e13ea8a5c7a284710a944f7be237eaf2fe7fbf7
ADD --link https://github.com/librespeed/speedtest-rust.git#${SPEEDTEST_COMMIT} /app
ENV RUSTFLAGS="-C target-feature=+crt-static" \
  PKG_CONFIG_ALL_STATIC=1 \
  LIBSQLITE3_SYS_STATIC=1 \
  CARGO_HOME=/usr/local/cargo

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/app/target \
    cargo build --release --target x86_64-alpine-linux-musl --no-default-features --features sqlite && \
    mv target/x86_64-alpine-linux-musl/release/librespeed-rs .

FROM scratch
COPY --link --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --link --from=builder /app/librespeed-rs /usr/bin/librespeed-rs
COPY --link assets /app/assets
ENTRYPOINT [ "/usr/bin/librespeed-rs" ]
