FROM microsoft/dotnet:2.1-sdk-alpine
MAINTAINER 21void

# install build-tools
RUN apk add --no-cache --virtual .build-deps git cmake build-base \
    openssl-dev pkgconfig boost-dev libsodium-dev && \
# build
    cd /tmp && git clone https://github.com/coinfoundry/miningcore && cd miningcore/src/MiningCore && \
    sh ./linux-build.sh && mkdir /dotnetapp && cp -r ../../build/* /dotnetapp && \
# cleanup build artifacts
    apk del .build-deps && \
    apk add --no-cache boost-system libssl1.0 && \
    rm -rf /tmp/miningcore

WORKDIR /dotnetapp

# API
EXPOSE 4000
# Stratum Ports
EXPOSE 3032-3199

ENTRYPOINT dotnet MiningCore.dll -c /config.json
