resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route_table" {
  name       = "nat-route-table"
  network_id = yandex_vpc_network.virtual_private_network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_subnet" "server_subnet" {
  name           = "server-subnet"
  network_id     = yandex_vpc_network.virtual_private_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  route_table_id = yandex_vpc_route_table.route_table.id
}

resource "yandex_compute_instance" "wg-server" {
  name        = "wg-server"
  platform_id = "standard-v2"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.wg_image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.server_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "admin:${file("~/.ssh/id_ed25519.pub")}"
    user-data = <<-EOF
    #cloud-config
    package_update: true
    ssh_pwauth: false
    users:
      - name: admin
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - "${file("~/.ssh/id_ed25519.pub")}"
    runcmd:
      - sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
      - sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
      - systemctl restart sshd
    EOF
  }
}

output "external_ip_address_service" {
  value = yandex_compute_instance.wg-server.network_interface.0.nat_ip_address
}