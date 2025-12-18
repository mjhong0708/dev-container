alias bcpu := build-and-push-cpu

build-and-push-cpu:
    cd dev-container && \
    docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t mjhong0708/dev-container:latest --push .