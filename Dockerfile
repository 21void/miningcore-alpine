FROM microsoft/dotnet-nightly:2.1-sdk-alpine as build-env

# install build-tools and build
RUN apk add --no-cache --virtual .build-deps git cmake build-base \
    openssl-dev pkgconfig boost-dev libsodium-dev && \
    cd /tmp && \
    git clone https://github.com/21void/miningcore && cd miningcore/src/MiningCore && \
    git checkout pak-coin && \
    sh linux-build.sh && \
    cd /tmp/miningcore/src/MiningCore && dotnet publish -c Release -o ../../linux -r linux-x64

FROM microsoft/dotnet-nightly:2.1-runtime-alpine as base
MAINTAINER 21void

WORKDIR /dotnetapp
COPY --from=build-env /tmp/miningcore/build .
COPY --from=build-env /tmp/miningcore/linux/libuv.so .

RUN apk add --no-cache boost-system libssl1.0 libuv duo_unix && \
    adduser -D -s /bin/sh -u 1000 user &&\
    sed -i -r 's/^user:!:/user:x:/' /etc/shadow && \
    sed -i -r '/^(user|root)/!d' /etc/group && \
    sed -i -r '/^(user|root)/!d' /etc/passwd && \
    chown -R user:user /dotnetapp && \
    find / -xdev -type f -a -perm +4000 -delete && \
    find / -xdev -name hexdump -o -name chgrp -o -name chmod -o -name chown -o -name ln -o -name od -o -name strings -o -name su -delete && \
    find / -xdev -type l -exec test ! -e {} \; -delete && \
    rm -rf /root && rm -rf /etc/fstab 

USER user

# API
EXPOSE 4000
# Stratum Ports
EXPOSE 3032-3199

ENTRYPOINT dotnet MiningCore.dll -c /config.json
