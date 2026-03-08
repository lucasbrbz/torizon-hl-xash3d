# torizon-hl-xash3d

Container for running Half-Life with Xash3D engine on Torizon OS

## Supported platforms

<details>
<summary>i.MX 8M Plus</summary>
- ✅ 0058 - Verdin iMX8M Plus Quad 4GB WB IT
</details>

## Build and run

```
# docker build -t hl-xash3d:<tag> .
# docker save -o hl-xash3d-<platform>.tar hl-xash3d:<tag>
# scp hl-xash3d-<platform>.tar docker-compose.yml user@host:/tmp/
# ssh user@host
# docker load -i /tmp/hl-xash3d-<platform>.tar
# docker-compose -f /tmp/docker-compose.yml up -d
```

## Roadmap

- [ ] Address performance issues (e.g. frame rate)
- [ ] Clean up the Dockerfile and docker-compose.yml
- [ ] Add support for other Torizon-supported platforms
- [ ] Create GitHub Actions for building and pushing the image to a registry

