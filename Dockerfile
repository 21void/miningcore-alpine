FROM microsoft/dotnet:2.1-runtime-alpine
MAINTAINER 21void

RUN apk add --no-cache boost-system libssl1.0
COPY dotnetapp /dotnetapp

WORKDIR /dotnetapp

# API
EXPOSE 4000
# Stratum Ports
EXPOSE 3032-3199

ENTRYPOINT dotnet MiningCore.dll -c /config.json
