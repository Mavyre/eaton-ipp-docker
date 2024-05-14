FROM debian:12
LABEL maintainer="Bastien Vidé"
ENV INSTALLER_URL=https://www.eaton.com/content/dam/eaton/products/backup-power-ups-surge-it-power-distribution/power-management-software-connectivity/eaton-intelligent-power-protector/software/ippv1-73/ipp-linux_1.73.175-1_amd64.deb

# Labels
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="Mavyre/eaton-ipp"
LABEL org.label-schema.description="Eaton IPP container"
LABEL org.label-schema.version=1.73.175-1
LABEL org.label-schema.docker.cmd="docker run -v ~/ipp/db:/usr/local/eaton/IntelligentPowerProtector/db -v ~/ipp/configs:/usr/local/eaton/IntelligentPowerProtector/configs -v /bin/systemctl:/bin/systemctl -v /run/systemd:/run/systemd -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket -v /sys/fs/cgroup:/sys/fs/cgroup --net host --privileged eaton-ipp"

RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y curl openssh-client sshpass; \
    curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:125.0) Gecko/20100101 Firefox/125.0" ${INSTALLER_URL} -o ipp.deb; \
    dpkg -i ipp.deb; \
    rm ipp.deb;

WORKDIR /usr/local/eaton/IntelligentPowerProtector
EXPOSE 4679 4680
VOLUME ["/usr/local/eaton/IntelligentPowerProtector/db"]
VOLUME ["/usr/local/eaton/IntelligentPowerProtector/configs"]

CMD ["./mc2", "-start"]
HEALTHCHECK --interval=1m --timeout=10s \
  CMD curl -f http://localhost:4679 || exit 1