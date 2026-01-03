FROM dhi.io/rust:1-alpine3.22-dev AS base
WORKDIR /app

FROM base AS builder
ADD --link https://github.com/librespeed/speedtest-rust.git /app
ENV RUSTFLAGS=""
ENV CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-C target-feature=+crt-static"
ENV CARGO_HOME=/usr/local/cargo
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/app/target \
    cargo build --release --no-default-features --features sqlite && \
    mv target/release/librespeed-rs .

FROM scratch
COPY --link --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --link --from=builder /app/librespeed-rs /usr/bin/librespeed-rs
COPY --link --from=builder /app/assets /app/assets
ENTRYPOINT [ "/usr/bin/librespeed-rs" ]