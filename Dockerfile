FROM registry.access.redhat.com/ubi9/ubi:latest

RUN dnf install -y python3 python3-pip vim git wget && dnf clean all

# Generate random-sized image (300 MB - 1.5 GB)
# Size constrained by build pod memory to avoid OOM kills during commit
ARG IMAGE_SIZE_MB=900
RUN SIZE_MB=${IMAGE_SIZE_MB} && \
    echo "========================================" && \
    echo "Building large test image: ${SIZE_MB} MB" && \
    echo "========================================" && \
    dd if=/dev/urandom of=/opt/data.bin bs=1M count=${SIZE_MB} 2>/dev/null && \
    echo "Image size: ${SIZE_MB} MB" > /opt/size.txt

WORKDIR /app
COPY . /app/

LABEL test-type="large-snapshot" \
      size-range="300-1500MB"
LABEL konflux.additional-tags="stable"

CMD ["/bin/bash", "-c", "cat /opt/size.txt && tail -f /dev/null"]
