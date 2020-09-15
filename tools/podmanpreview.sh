
#!/usr/bin/env sh
podman run --rm -ti \
  --name che-docs \
  -v $PWD:/projects:Z -w /projects \
  --entrypoint="./tools/preview.sh" \
  -p 4000:4000 -p 35729:35729 \
  docker.io/antora/antora
