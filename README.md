# Homelab

## Dependencies

### Docker

    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install the latest version
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

Follow the [Linux post-install steps](https://docs.docker.com/engine/install/linux-postinstall/) to allow non-root users
to run docker.

To verify, run `docker run hello-world`. Sample output:

    $ docker run hello-world

    Hello from Docker!
    This message shows that your installation appears to be working correctly.
    ...

[Reference](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)

### k3s

    curl -sfL https://get.k3s.io | sh -

To verify, run `k3s --version`. Sample output:

    $ k3s --version
    k3s version v1.32.5+k3s1 (8e8f2a47)
    go version go1.23.8

[Reference](https://docs.k3s.io/quick-start)

### Terraform

    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform

To verify, run `terraform --version`. Sample output:

    $ terraform --version
    Terraform v1.12.2
    on linux_amd64

[Reference](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)

## Media server

The media server is a collection of services built around [jellyfin](https://jellyfin.org/) to manage movies/tv shows
and serve them to devices on the local network, e.g. smart(-ish) tvs, laptops, and phones. The other services are from
the [Servarr](https://wiki.servarr.com/) stack. Currently, the following services have been integrated into this repo:

- Jellyfin ([terraform/resources/jellyfin/](terraform/resources/jellyfin/))
    - Serves media. What other devices on the network will actually talk to to stream content.
    - Uses port 8096: <http://localhost:8096>
    - Documentation: <https://jellyfin.org/docs/>
- Jellyseerrr ([terraform/resources/jellyseerr/](terraform/resources/jellyseerr/))
    - Nice browsable interface to search for new movies and shows. Sends requests to Radarr.
    - Uses port 5055: <http://localhost:5055>
    - Documentation: <https://docs.jellyseerr.dev/>
- Radarr ([terraform/resources/radarr/](terraform/resources/radarr/))
    - Talks to the download client to manage downloads. Handles moving/linking downloaded files to where Jellyfin can
    find them.
    - Uses port 7878: <http://localhost:7878>
    - Documentation: <https://wiki.servarr.com/radarr> (Radarr's [website](https://radarr.video) kinda sucks for
    actually figuring out how to set it up.)
- Prowlarr ([terraform/resources/prowlarr/](terraform/resources/prowlarr/))
    - Manages torrent indexes that will be sent to the download client. Integrates with Radarr.
    - Uses port 9696: <http://localhost:9696>
    - Documentation: <https://wiki.servarr.com/en/prowlarr> (Same deal as Radarr with the docs).
- Flaresolverr ([terraform/resources/flaresolverr/](terraform/resources/flaresolverr/))
    - Only purpose is to automate the CloudFlare 'Are you a human?' checks that Prowlarr has to deal with when talking
    to torrent indexes.
    - Uses port 8191: <http://localhost:8191> (not really useful to visit in the browser though).
    - Documentation: <https://github.com/FlareSolverr/FlareSolverr>
- qBittorrent
    - The download client.
    - Uses port 8080: <http://localhost:8080>
    - Deployed independently of the above services since it's easier to force it to use a VPN using docker compose.

### Deployment

To deploy all services except the download client, run the following commands

    cd terraform/
    terraform init
    terraform plan   # Not necessary, but it is good practice to run this to see what changes will be made before you deploy anything
    terraform apply  # This will prompt you to enter 'yes' to actually deploy things.

It will take a while the first time due to one-time actions like downloading images. After the command finishes you
should see 5 pods running in k3s. For example (times will be different, but you should see status is Running):

    $ kubectl -n homelab get pods
    NAME                            READY   STATUS    RESTARTS      AGE
    flaresolverr-6f9f4cc568-lf9dm   1/1     Running   6 (60m ago)   2d12h
    jellyfin-75447bf99f-6jlj4       1/1     Running   6 (60m ago)   2d12h
    jellyseerr-79bc987857-f87qq     1/1     Running   6 (60m ago)   2d12h
    prowlarr-57fddd56f7-fjlb6       1/1     Running   6 (60m ago)   2d12h
    radarr-74d567bfcc-d6snv         1/1     Running   6 (60m ago)   2d12h

At this point you should be able to open your browser and go to each of these services (see localhost addresses above).

To deploy qBittorrent as the download client, first you need to set up your VPN. Docker compose is used with
[gluetun](https://github.com/qdm12/gluetun) to ensure that the only network qBittorrent can use is the VPN. The file
`compose.yaml` is set up specifically to use NordVPN, but can be easily modified to support other VPN providers. See the
[gluetun documentation](https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers) for details. Whatever VPN
provider you are using, you will need to get your OpenVPN username and password from your account. This is not the same
thing as your account login, and you will probably have to go through the web portal to find it. Once you have the
username and password, create a file `.env` in the same directory as `compose.yaml`, open it in a text editor and write
(obviously using your username/password instead)

    OPENVPN_USER=asdfasdfasdf
    OPENVPN_PASSWORD=qwerqwerqwer

Then

    cd ..  # necessary if you just did a terraform apply
    docker compose up -d

This will also take a minute to download images. Check that things are running:

    $ docker compose ps
    NAME          IMAGE                                    COMMAND                 SERVICE       CREATED      STATUS                       PORTS
    gluetun       qmcgaw/gluetun                           "/gluetun-entrypoint"   gluetun       2 days ago   Up About an hour (healthy)   0.0.0.0:6881->6881/tcp, [::]:6881->6881/tcp, 0.0.0.0:8080->8080/tcp, 0.0.0.0:6881->6881/udp, [::]:8080->8080/tcp, [::]:6881->6881/udp, 0.0.0.0:8388->8388/tcp, [::]:8388->8388/tcp, 0.0.0.0:8888->8888/tcp, 0.0.0.0:8388->8388/udp, [::]:8888->8888/tcp, [::]:8388->8388/udp, 8000/tcp
    qbittorrent   lscr.io/linuxserver/qbittorrent:latest   "/init"                 qbittorrent   2 days ago   Up About an hour

You should see two containers, one for qbittorrent and one for gluetun. Check the logs of the containers to make sure
things look happy. For example for gluetun:

    docker logs gluetun
    ...
    2025-07-13T23:50:35-07:00 INFO [firewall] allowing VPN connection...
    2025-07-13T23:50:35-07:00 INFO [openvpn] OpenVPN 2.6.11 x86_64-alpine-linux-musl [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [MH/PKTINFO] [AEAD]
    2025-07-13T23:50:35-07:00 INFO [openvpn] library versions: OpenSSL 3.3.2 3 Sep 2024, LZO 2.10
    2025-07-13T23:50:35-07:00 INFO [openvpn] TCP/UDP: Preserving recently used remote address: [AF_INET]212.102.44.56:1194
    2025-07-13T23:50:35-07:00 INFO [openvpn] UDPv4 link local: (not bound)
    2025-07-13T23:50:35-07:00 INFO [openvpn] UDPv4 link remote: [AF_INET]212.102.44.56:1194
    2025-07-13T23:50:36-07:00 INFO [openvpn] [us8283.nordvpn.com] Peer Connection Initiated with [AF_INET]212.102.44.56:1194
    2025-07-13T23:50:36-07:00 INFO [openvpn] TUN/TAP device tun0 opened
    2025-07-13T23:50:36-07:00 INFO [openvpn] /sbin/ip link set dev tun0 up mtu 1500
    2025-07-13T23:50:36-07:00 INFO [openvpn] /sbin/ip link set dev tun0 up
    2025-07-13T23:50:36-07:00 INFO [openvpn] /sbin/ip addr add dev tun0 10.100.0.2/16
    2025-07-13T23:50:36-07:00 INFO [openvpn] UID set to nonrootuser
    2025-07-13T23:50:36-07:00 INFO [openvpn] Initialization Sequence Completed
    2025-07-13T23:50:36-07:00 INFO [dns] downloading hostnames and IP block lists
    2025-07-13T23:50:36-07:00 INFO [healthcheck] healthy!
    2025-07-13T23:50:37-07:00 INFO [dns] DNS server listening on [::]:53
    2025-07-13T23:50:37-07:00 INFO [dns] ready
    2025-07-13T23:50:38-07:00 INFO [ip getter] Public IP address is [redacted] (United States, Colorado, Denver - source: ipinfo)
    2025-07-13T23:50:38-07:00 INFO [vpn] You are running 1 commit behind the most recent latest

And for qBittorrent:

    [custom-init] No custom files found, skipping...
    WebUI will be started shortly after internal preparations. Please wait...

    ******** Information ********
    To control qBittorrent, access the WebUI at: http://localhost:8080
    Connection to localhost (::1) 8080 port [tcp/http-alt] succeeded!
    [ls.io-init] done.

### Configuration

TODO
