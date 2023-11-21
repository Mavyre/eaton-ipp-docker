<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/Mavyre/eaton-ipp-docker">
    <img src="images/Eaton_Corporation_logo.png" alt="Logo" width="250" height="87">
  </a>

<h3 align="center">Dockerised Eaton® IPP</h3>

  <p align="center">
    Install and run Eaton® Intelligent Power® Protector onto a Debian docker container!
    <br />
    <a href="https://github.com/Mavyre/eaton-ipp-docker"><strong>Explore the official Eaton® IPP documentation »</strong></a>
    <br />
    <br />
    <!--<a href="https://github.com/Mavyre/eaton-ipp-docker">View Demo</a>
    ·-->
    <a href="https://github.com/Mavyre/eaton-ipp-docker/issues">Report Bug</a>
    ·
    <a href="https://github.com/Mavyre/eaton-ipp-docker/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#build-the-docker-image">Build the image</a></li>
      </ul>
    </li>
    <li><a href="#upgrade-considerations">Upgrade Considerations</a></li>
    <li>
      <a href="#usage">Usage</a>
      <ul>
        <li><a href="#shutdown-host-from-ipp">Shutdown host</a></li>
        <li><a href="#Launch-ipp-on-an-arm-machine">IPP on ARM</a></li>
      </ul>
    </li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://example.com)

"Eaton® Intelligent Power® Protector (IPP) is protection software that gracefully shuts down local computers and servers powered by a UPS in the event of a power outage."

Eaton® IPP is distributed on their [download page](http://powerquality.eaton.fr/Support/Software-Drivers/Downloads/Intelligent-Power-Protector.asp) for multiple platforms.
However, a dockerised instance of IPP may be necessary if:
 * You want to run IPP on an unsupported CPU architecture (arm/aarch64 for instance).
 * You don't want, or can't install IPP directly on the target host, and prefer to offload it on a Docker node.

This repository contains a Dockerfile which installs and runs Eaton® IPP on the latest Debian container using their official deb installer package, as well as some utilities.
<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

* [![Docker][Docker.com]][Docker-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

### Prerequisites

* AMD64 platform architecture, or [emulate it](https://hub.docker.com/r/tonistiigi/binfmt)
* git
* [Docker](https://www.docker.com/)
 ```sh
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  ```

### Build the Docker image
   ```sh
   docker build https://github.com/Mavyre/eaton-ipp-docker.git
   ```
OR
   ```sh
   git clone https://github.com/Mavyre/eaton-ipp-docker.git
   cd eaton-ipp-docker
   docker build -t eaton-ipp .
   ```
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- UPGRADE CONSIDERATIONS -->
## Upgrade Considerations

When upgrading from app version prior to 1.72, the mount path inside the container changed.
Eaton IPP not resides in `/usr/local/eaton/IntelligentPowerProtector` instead of `/usr/local/Eaton/IntelligentPowerProtector` (notice the lower-case `eaton` folder).  

All mounted volume paths need to be adjusted.

Depending on the location of your shutdown script, you might need to update the path to it in Eaton IPP shutdown action as well.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

```sh
docker run -d --net host -v ~/ipp/db:/usr/local/eaton/IntelligentPowerProtector/db -v ~/ipp/configs:/usr/local/eaton/IntelligentPowerProtector/configs --name eaton-ipp Mavyre/eaton-ipp
```
Launching the docker within the host namespace allows IPP to easily scan the network for UPSes, receive the shutdown signals and connect to the host to shut it down.
If the shutdown target is not the host, you can run the docker with `-p 4679:4679 -p 4680:4680 -p 4679:4679/udp -p 4680:4680/udp` instead of `--net host`.

The two folders `db` and `configs` are mapped on host to retain IPP configurations and database.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Shutdown host from IPP

The easiest way with `--net host` is to use a shutdown script and SSH:

* Prepare a shutdown script that connects to localhost. `shutdown.example.sh` can be used as a template.
  * The user must have sudo access to the `poweroff` command without password in `/etc/sudoers`:
  ```
  username ALL = (root) NOPASSWD: /usr/sbin/poweroff
  ```
* Eaton IPP enforces shutdown scripts to be located in its `/usr/local/eaton/IntelligentPowerProtector/configs/actions` folder, so put the script in `~/ipp/configs/actions`
* Allow the script to be executed in the container: `docker exec eaton-ipp chmod u+x /usr/local/eaton/IntelligentPowerProtector/configs/actions/shutdown.sh`
* In IPP, under *Settings*, *Shutdown*, *Edit shutdown configuration*:
  * Shutdown type: *Script*
  * Shutdown script: `/usr/local/eaton/IntelligentPowerProtector/configs/actions/shutdown.sh`

Each time a shutdown will be triggered by the UPS, the `shutdown.sh` script will be executed by IPP and shut down the host using SSH.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Launch IPP on an ARM machine (e.g. Raspberry Pi)

IPP is not natively compatible with arm/aarch computers.
If you want to run it anyway, you need to emulate the AMD64 architecture.

> :warning: **Disclaimer**: When emulating, IPP might be slow and eat a lot of resources even when idle.

You can enable the AMD64 emulation using the [awesome helper](https://github.com/tonistiigi/binfmt) by [tonistiigi](https://github.com/tonistiigi):
```sh
sudo docker run --privileged --rm tonistiigi/binfmt --install amd64
```

Next, run the docker using AMD64:
```sh
docker run -d --platform linux/amd64 --net host -v ~/ipp/db:/usr/local/eaton/IntelligentPowerProtector/db -v ~/ipp/configs:/usr/local/eaton/IntelligentPowerProtector/configs  --name eaton-ipp Mavyre/eaton-ipp
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

#### Automatically start IPP after a reboot on an ARM machine

Even if the container is run with the `--restart` flag, it will not restart after a reboot.
The AMD64 emulation must be re-enabled before starting the IPP container.
In a Debian environment, the simple solution is to create a `systemd` service.

First, stop the docker container:
```ssh
docker stop eaton-ipp
```

Copy `ipp.service` into `/etc/systemd/system`. Then, enable the service on boot, and start IPP:
```ssh
systemctl enable ipp
systemctl start ipp
```

The service will re-enable the AMD64 emulation before starting the IPP container at each reboot.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

The docker is distributed under the MIT License. See `LICENSE.txt` for more information.

Eaton® Intelligent Power® Protector is distributed under its own EULA that you must read and accept prior using it.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* Thanks to both [dersimn](https://github.com/dersimn/docker_eaton_ipp) and [ytzelf](https://github.com/ytzelf/docker-eaton-ipp) for their Eaton IPP containers that helped a lot to create this one
* [othneildrew](https://github.com/othneildrew) for their awesome [Best README template](https://github.com/othneildrew/Best-README-Template) which I recommended to kickstart any Readme file!

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/Mavyre/eaton-ipp-docker.svg?style=for-the-badge
[contributors-url]: https://github.com/Mavyre/eaton-ipp-docker/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/Mavyre/eaton-ipp-docker.svg?style=for-the-badge
[forks-url]: https://github.com/Mavyre/eaton-ipp-docker/network/members
[stars-shield]: https://img.shields.io/github/stars/Mavyre/eaton-ipp-docker.svg?style=for-the-badge
[stars-url]: https://github.com/Mavyre/eaton-ipp-docker/stargazers
[issues-shield]: https://img.shields.io/github/issues/Mavyre/eaton-ipp-docker.svg?style=for-the-badge
[issues-url]: https://github.com/Mavyre/eaton-ipp-docker/issues
[license-shield]: https://img.shields.io/github/license/Mavyre/eaton-ipp-docker.svg?style=for-the-badge
[license-url]: https://github.com/Mavyre/eaton-ipp-docker/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/bastien-vide
[product-screenshot]: https://windows-cdn.softpedia.com/screenshots/Eaton-Intelligent-Power-Protector_4.png
[Docker.com]: https://img.shields.io/badge/Docker-384d54?style=for-the-badge&logo=docker&logoColor=white
[Docker-url]: https://www.docker.com/