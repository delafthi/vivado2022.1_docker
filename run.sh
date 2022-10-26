#!/bin/bash
PROJECT_PATH=${HOME}/projects
docker run -it --rm \
  --net host \
  -e LOCAL_UID=$(id -u ${USER}) \
  -e LOCAL_GID=$(id -g ${USER}) \
  -e USER=${USER} \
  -e UART_GROUP_ID=20 \
  -e DISPLAY=${DISPLAY} \
  -e "QT_X11_NO_MITSHM=1" \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v ${HOME}/.Xauthority:${HOME}/.Xauthority:rw \
  -v ${PROJECT_PATH}:${HOME}/projects:rw \
  -v /dev/bus/usb:/dev/bus/usb:rw \
  -v /sys:/sys:ro \
  --device /dev/dri \
  --privileged \
  -w ${HOME} \
  vivado:2022.1
