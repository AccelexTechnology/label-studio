# syntax=docker/dockerfile:1.3
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_CACHE_DIR=/.cache

RUN set -eux; \
    apt-get update && apt-get install --no-install-recommends --no-install-suggests -y \
    build-essential postgresql-client libmysqlclient-dev mysql-client python3.8 python3-pip python3.8-dev \
    uwsgi git libxml2-dev libxslt-dev zlib1g-dev

RUN python3.8 -m pip install --upgrade pip
RUN pip3 install uwsgi

ARG app_name=label_studio
ARG app_version=1.4

ENV app_name=$app_name
ENV app_version=$app_version

COPY . /label-studio
RUN python3.8 -m pip install /label-studio/dist/${app_name}-${app_version}-py3-none-any.whl

WORKDIR /label-studio

EXPOSE 8080
RUN ./deploy/prebuild_wo_frontend.sh

ENTRYPOINT ["./deploy/docker-entrypoint.sh"]
CMD ["label-studio"]
