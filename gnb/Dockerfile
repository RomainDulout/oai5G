FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=Europe

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade --yes \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes \
    software-properties-common procps libsctp1 tzdata libnettle6 \
    libblas3 libatlas3-base libconfig9  openssl net-tools iproute2 \
    iputils-ping python python3 xxd python3-six python3-requests libusb-1.0-0 \       
    libyaml-0-2 && rm -rf /var/lib/apt/lists/*



SHELL ["/bin/bash", "-c"]

COPY ./oai_lib /lib_install

WORKDIR /lib_install/cmake_targets/

RUN source ../oaienv

RUN ./cmd_build.sh




COPY ./openairinterface5g /oai

WORKDIR /oai/cmake_targets/

RUN source ../oaienv

RUN ./cmd_build.sh



WORKDIR /oai/cmake_targets/ran_build/build

COPY ./run_nrsoftmodem.sh /oai/cmake_targets/ran_build/build/

ENTRYPOINT ["./run_nrsoftmodem.sh"]