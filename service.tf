resource "yandex_vpc_route_table" "wg_host_rt" {
  name       = "wg-host-rt"
  network_id = yandex_vpc_network.virtual_private_network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.10"
  }
}

resource "yandex_vpc_subnet" "private_subnet" {
  name           = "private-subnet"
  network_id     = yandex_vpc_network.virtual_private_network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.wg_host_rt.id
  zone           = "ru-central1-b"
}

resource "yandex_compute_instance" "private_service" {
  name        = "private-service"
  platform_id = "standard-v2"
  zone        = "ru-central1-b"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = var.private_service_image
      size     = 100
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.private_subnet.id
    ip_address = "192.168.20.10"
  }

  metadata = {
    user-data = <<-EOF
#cloud-config
users:
  - name: user
    groups: sudo
    shell: /bin/bash
    sudo: 'ALL=(ALL) NOPASSWD:ALL'
    ssh_authorized_keys:
      - ${file("~/.ssh/id_ed25519.pub")}
EOF 
  }
}
