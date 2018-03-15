## MiningCore-Alpine

Unofficial MiningCore docker-image using Alpine as base image

### Usage

The image expects a valid pool configuration file as volume argument:

```bash
$ docker run -d -p 3032:3032 -v /path/to/config.json:/config.json:ro 21void/miningcore-alpine
```

As shown in the example above you also need to expose all the stratum ports you've specified in config.json.
