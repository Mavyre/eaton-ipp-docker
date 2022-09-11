FROM debian
LABEL maintainer="Bastien Vidé"

# Labels
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="Mavyre/eaton-ipp"
LABEL org.label-schema.description="Eaton IPP container"
LABEL org.label-schema.version=1.69.167-1
LABEL org.label-schema.docker.cmd="docker run -v ~/ipp/db:/usr/local/Eaton/IntelligentPowerProtector/db -v ~/ipp/configs:/usr/local/Eaton/IntelligentPowerProtector/configs -v /bin/systemctl:/bin/systemctl -v /run/systemd:/run/systemd -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket -v /sys/fs/cgroup:/sys/fs/cgroup --net host --privileged eaton-ipp"

RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y curl openssh-client sshpass; \
    curl http://powerquality.eaton.fr/Support/Software-Drivers/Downloads/IPS/ipp-linux_1.69.167-1_amd64.deb -o ipp.deb; \
    dpkg -i ipp.deb; \
    rm ipp.deb;

WORKDIR /usr/local/Eaton/IntelligentPowerProtector
EXPOSE 4679 4680
VOLUME ["/usr/local/Eaton/IntelligentPowerProtector/db"]
VOLUME ["/usr/local/Eaton/IntelligentPowerProtector/configs"]

CMD ["./mc2", "-start"]
HEALTHCHECK --interval=1m --timeout=10s \
  CMD curl -f http://localhost:4679 || exit 1