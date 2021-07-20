# syntax=docker/dockerfile:1

FROM golang:1.16.6-alpine3.13

LABEL maintainer="Sarah Blazic <sblazic@paloaltonetworks.com>"
LABEL org.opencontainers.image.source="https://github.com/sarah-blazic/terraform-panos-policy"

WORKDIR /workspace/source
ENV MY_DIR /workspace/source

# The Go binary distributions assume they will be installed in /usr/local/go
ENV GOROOT /usr/local/go
ENV GOPATH /usr/local/go

RUN apk add --virtual --no-cache \
  wget \
  unzip \
  bash \
  git \
  ca-certificates \
  openssh \
  && rm -rf /var/cache/apk/*

# Tell us wihch version of Terraform to use
ARG TF_VERSION=0.14.10
ENV TF_VERSION ${TF_VERSION}
RUN \
  wget -q -O /workspace/source/terraform.zip \
    "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" && \
  unzip /workspace/source/terraform.zip -d /bin; \
  rm /workspace/source/terraform ; \
  go get -u github.com/PaloAltoNetworks/terraform-panos-modules; \
  go get -u github.com/sarah-blazic/terraform-panos-policy; \
  echo "Ready to rock."

