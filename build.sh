#!/bin/bash
. app_data.sh

TEST_COMMAND="cjpeg data/test.jpg"

# Build image
docker build --no-cache \
    --build-arg "APP_VERSION=${APP_VERSION}" \
    -t "${REPOSITORY}/${APP_NAME}:${APP_VERSION}" \
    -t "${REPOSITORY}/${APP_NAME}:latest" \
    . &&\
docker run --rm -it \
    -v ./data:/app/data \
    "${REPOSITORY}/${APP_NAME}:${APP_VERSION}" \
    $TEST_COMMAND > /dev/null &&\
docker push --all-tags "${REPOSITORY}/${APP_NAME}"

EXIT_CODE=$?
echo "Exit code: ${EXIT_CODE}"
exit $EXIT_CODE