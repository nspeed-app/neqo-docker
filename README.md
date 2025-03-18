# neqo-docker
build [Neqo](https://github.com/mozilla/neqo) with Docker.

    git clone https://github.com/nspeed-app/neqo-docker
    cd neqo-docker
    git clone https://github.com/mozilla/neqo neqo
    docker build --output type=local,dest=./out .

docker build arguments:

    CARGO_ARGS
    NEQO_DIR

how to use binaires exported in the out folder:

launch server:

    export LD_LIBRARY_PATH=$(pwd)/out/lib 
    RUST_BACKTRACE=1 ./out/bin/neqo-server -v -d neqo/test-fixture/db

test with nspeed:

    nspeed get -k http3 https://[::]:4433/1000000000

and watch Go crashes Rust (;))

This Dockerfile was adapted from `neqo/qns/Dockerfile` with `cargo-chef` removed.