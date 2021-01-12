FROM ubuntu

LABEL maintainer="cooperised@gmail.com"
LABEL version="0.1"
LABEL description="This is a Docker image for EmonHub, part of the OpenEnergyMonitor project"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt full-upgrade -y
RUN apt install -y git gosu python3-serial python3-configobj python3-pip python3-pymodbus bluetooth libbluetooth-dev
RUN pip3 install paho-mqtt requests pybluez py-sds011 sdm_modbus
RUN mkdir -p /install && cd /install && git clone https://github.com/openenergymonitor/emonhub.git
RUN cd /install/emonhub && git checkout stable && git checkout dd8d1f7d8a1094505cf0711c817f7466460b5c72 -- src/emonhub_coder.py

COPY entrypoint.sh /install/entrypoint.sh
RUN chmod +x /install/entrypoint.sh

ENTRYPOINT ["/install/entrypoint.sh"]
CMD ["/install/emonhub/src/emonhub.py","--config-file=/config/emonhub.conf","--logfile=/log/emonhub.log"]

