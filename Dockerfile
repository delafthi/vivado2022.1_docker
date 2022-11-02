FROM ubuntu:20.04

LABEL maintainer "Thierry Delafontaine <delafontaineth@pm.me>"

ARG XLNX_VIVADO_VERSION=2022.1
ARG XLNX_VIVADO_INSTALLER=Xilinx_Unified_2022.1_0420_0327_Lin64.bin
ARG XLNX_VIVADO_AUTH_FILE=wi_authentication_key
ARG XLNX_VIVADO_BATCH_CONFIG_FILE=install_config.txt

ENV XLNX_VIVADO_VERSION=${XLNX_VIVADO_VERSION}
ENV XLNX_INSTALL_LOCATION=/tools/Xilinx

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get upgrade -y

RUN apt-get install -y -qq apt-utils
RUN apt-get install -y -qq locales && \
  locale-gen en_US.UTF-8

# Install base requirements
RUN apt-get install -y -qq \
  sudo \
  gosu \
  vim \
  tmux

# Requirements for Vivado SDK
RUN apt-get install -y -qq \
  libtinfo5 \
  default-jre

# Requirements for DocNav
RUN apt-get install -y -qq \
  libnss3

# Requirements for Vitis HLS
RUN apt-get install -y -qq \
  libgtk2.0-0

# Requirements for PetaLinux (Listed here just as a reference, since PetaLinux is not installed)
# RUN apt-get install -y -qq \
#   iproute2 \
#   gcc \
#   g++ \
#   net-tools \
#   libncurses5-dev \
#   zlib1g:i386 \
#   libssl-dev \
#   flex \
#   bison \
#   libselinux1 \
#   xterm \
#   autoconf \
#   libtool \
#   texinfo \
#   zlib1g-dev \
#   gcc-multilib \
#   build-essential \
#   screen \
#   pax \
#   gawk \
#   python3 \
#   python3-pexpect \
#   python3-pip \
#   python3-git \
#   python3-jinja2 \
#   xz-utils \
#   debianutils \
#   iputils-ping \
#   libegl1-mesa \
#   libsdl1.2-dev \
#   pylint3 \
#   cpio

RUN apt-get autoclean && \
  apt-get autoremove

# Copy the vivado installation files
COPY ${XLNX_VIVADO_INSTALLER} ${XLNX_INSTALL_LOCATION}/tmp/${XLNX_VIVADO_INSTALLER}
COPY ${XLNX_VIVADO_BATCH_CONFIG_FILE} ${XLNX_INSTALL_LOCATION}/tmp/${XLNX_VIVADO_BATCH_CONFIG_FILE}
COPY ${XLNX_VIVADO_AUTH_FILE} /root/.Xilinx/wi_authentication_key

# Install Vivado
RUN cd ${XLNX_INSTALL_LOCATION}/tmp/ && \
  chmod +x ${XLNX_VIVADO_INSTALLER} && \
 ./${XLNX_VIVADO_INSTALLER} -- \
    --agree XilinxEULA,3rdPartyEULA \
    --batch Install \
    --config ${XLNX_INSTALL_LOCATION}/tmp/${XLNX_VIVADO_BATCH_CONFIG_FILE} && \
  rm -rf ${XLNX_INSTALL_LOCATION}/tmp && \
  rm -rf /root/.Xilinx/wi_authentication_key

# Set up the work environment
RUN mkdir ${HOME}/projects

# Set up the entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash", "-c", "source ${XLNX_INSTALL_LOCATION}/Vivado/${XLNX_VIVADO_VERSION}/settings64.sh;source ${XLNX_INSTALL_LOCATION}/SDK/${XLNX_VIVADO_VERSION}/settings64.sh;export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${XLNX_INSTALL_LOCATION}/Vivado/${XLNX_VIVADO_VERSION}/lib/lnx64.o/;/bin/bash"]

# vim: ft=dockerfile tw=0 ts=2
