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

To deploy all services, run the following commands

    cd terraform/
    terraform init
    terraform plan   # Not necessary, but it is good practice to run this to see what changes will be made before you deploy anything
    terraform apply  # This will prompt you to enter 'yes' to actually deploy things.

It will take a while the first time due to one-time actions like downloading images.
