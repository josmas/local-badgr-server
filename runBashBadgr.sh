#!/usr/bin/env bash
docker run -ti --rm \
  --name local-badgr-server \
  -p 8000:8000 \
  #<your_name>/local-badgr-server /bin/bash # The name you used to build the Docker image.
  josmas/local-badgr-server /bin/bash
