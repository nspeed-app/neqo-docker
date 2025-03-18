# syntax=docker/dockerfile:1
FROM rust AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    libclang-dev gyp ninja-build python-is-python3 \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# We unfortunately need to build NSS from source, because the Debian package is
# not compiled with support for SSLKEYLOGFILE.
# See https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=842292
ENV NSS_DIR=/nss \
    NSS_TARGET=Release \
    NSS_PREBUILT=1 \
    NSPR_DIR=/nspr \
    LD_LIBRARY_PATH=/dist/Release/lib

RUN set -eux; \
    git clone --depth=1 https://github.com/nss-dev/nspr "$NSPR_DIR"; \
    git clone --depth=1 https://github.com/nss-dev/nss "$NSS_DIR"

RUN "$NSS_DIR"/build.sh --static -Ddisable_tests=1 -o

# Build application
# RUN git clone https://github.com/mozilla/neqo /neqo
ARG CARGO_ARGS="--locked --release --bins"
ARG NEQO_DIR="neqo"
ADD ${NEQO_DIR} /neqo
RUN set -eux; \
    cd /neqo; \
    cargo build ${CARGO_ARGS} #--locked --release 

# Copy only binaries to the final image to keep it small. use --output (docker build)
FROM scratch
COPY --from=builder /neqo/target/release/neqo-client /neqo/target/release/neqo-server /bin/
COPY --from=builder /dist/Release/lib/*.so /lib/
COPY --from=builder /dist/Release/bin/certutil /dist/Release/bin/pk12util /bin/

