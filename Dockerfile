# syntax=docker/dockerfile:1.3
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_CACHE_DIR=/.cache

WORKDIR /label-studio

# install packages
RUN set -eux; \
    apt-get update && apt-get install --no-install-recommends --no-install-suggests -y \
    build-essential postgresql-client libmysqlclient-dev mysql-client python3.8 python3-pip python3.8-dev \
    uwsgi git libxml2-dev libxslt-dev zlib1g-dev

RUN python3.8 -m pip install --upgrade pip
RUN pip3 install uwsgi

# Copy and install requirements.txt first for caching
COPY deploy/requirements.txt /label-studio
RUN pip3 install -r /label-studio/requirements.txt

# Build python wheel for label-studio
ARG app_name=label_studio
ARG app_version=1.4

ENV app_name=$app_name
ENV app_version=$app_version

COPY dist/ /label-studio/dist/

WORKDIR /label-studio/dist/
RUN python3.8 -m pip install ${app_name}-${app_version}-py3-none-any.whl

# Deploy label-studio
WORKDIR /label-studio
COPY . /label-studio

EXPOSE 8080
RUN ./deploy/prebuild_wo_frontend.sh

ENTRYPOINT ["./deploy/docker-entrypoint.sh"]
CMD ["label-studio"]