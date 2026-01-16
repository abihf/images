FROM dhi.io/rust:1-alpine3.22-dev AS base
WORKDIR /app

FROM base AS builder
ARG SPEEDTEST_COMMIT=6f8a0007157d34686d9f33988d08438fd927da2a
ADD --link https://github.com/librespeed/speedtest-rust.git#${SPEEDTEST_COMMIT} /app
ENV RUSTFLAGS="" \
  CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-C target-feature=+crt-static" \
  CARGO_HOME=/usr/local/cargo
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/app/target \
    cargo build --release --no-default-features --features sqlite && \
    mv target/release/librespeed-rs .

FROM scratch
COPY --link --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --link --from=builder /app/librespeed-rs /usr/bin/librespeed-rs
COPY --link assets /app/assets
ENTRYPOINT [ "/usr/bin/librespeed-rs" ]