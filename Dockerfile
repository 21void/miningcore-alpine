FROM microsoft/dotnet-nightly:2.1-sdk-alpine as build-env


COPY NuGet.config /tmp/
COPY alpine-build.sh /tmp/

# install build-tools and build
RUN apk add --no-cache --virtual .build-deps git cmake build-base \
    openssl-dev pkgconfig boost-dev libsodium-dev && \
    cd /tmp && \
    git clone https://github.com/21void/miningcore && cd miningcore/src/MiningCore && \
    git checkout pak-coin && \
    sed -i 's|<TargetFramework>.*</TargetFramework>|<TargetFramework>netcoreapp2.1</TargetFramework>|' MiningCore.csproj && \
    cp /tmp/NuGet.config . && \
    cp /tmp/alpine-build.sh . && \
    sh alpine-build.sh /dotnetapp && \
    adduser -D -s /bin/sh -u 1000 user && chown -R user:user /dotnetapp

FROM microsoft/dotnet-nightly:2.1-runtime-deps-alpine

RUN apk add --no-cache boost-system libssl1.0 libuv libsodium icu-libs && \
    adduser -D -s /bin/sh -u 1000 user &&\
    sed -i -r 's/^user:!:/user:x:/' /etc/shadow && \
    sed -i -r '/^(user|root)/!d' /etc/group && \
    sed -i -r '/^(user|root)/!d' /etc/passwd && \
    find / -xdev -type f -a -perm +4000 -delete && \
    find / -xdev -name hexdump -o -name chgrp -o -name chmod -o -name chown -o -name ln -o -name od -o -name strings -o -name su -delete && \
    find / -xdev -type l -exec test ! -e {} \; -delete && \
    rm -rf /root && rm -rf /etc/fstab

WORKDIR /dotnetapp

COPY --from=build-env /dotnetapp .
COPY --from=build-env /dotnetapp_linux/libuv.so .

USER user

# API
EXPOSE 4000
# Stratum Ports
EXPOSE 3032-3199

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT false

ENTRYPOINT /dotnetapp/MiningCore -c /config.json

