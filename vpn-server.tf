data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

data "yandex_vpc_address" "static_addr" {
  address_id = var.public_ip_address_id
}

resource "yandex_vpc_subnet" "server_subnet" {
  name           = "server-subnet"
  network_id     = yandex_vpc_network.virtual_private_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
}

resource "yandex_compute_instance" "wg-server" {
  name        = "wg-server"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.server_subnet.id
    ip_address     = "192.168.10.10"
    nat_ip_address = data.yandex_vpc_address.static_addr.external_ipv4_address[0].address
    nat            = true
  }

  metadata = {
    docker-compose = file("${path.module}/vpn-server-docker-compose.yml")
    ssh-keys       = "user:${file("~/.ssh/id_ed25519.pub")}"
  }
}
