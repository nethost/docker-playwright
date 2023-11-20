#!/bin/sh
docker buildx bake --push --set "*.platform=linux/arm64/v8,linux/amd64" latest chromium firefox webkit chrome msedge browsers