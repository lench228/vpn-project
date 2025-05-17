resource "yandex_compute_instance" "private_service" {
  name = "private_service"
  platform_id = "standard-v2"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.private_service_image
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnet.id
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

resource "yandex_vpc_subnet" "private_subnet" {
  name           = "private_subnet"
  network_id     = yandex_vpc_network.virtual_private_network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_vpc_route_table" "wg-host-rt" {
  network_id = yandex_vpc_network.virtual_private_network.id
  name = "wg-host-rt"

  static_route {
    gateway_id = yandex_vpc_gateway.wg_nat.id
    destination_prefix = "0.0.0.0/0"
  }
}

resource "yandex_vpc_gateway" "wg_nat" {
  name = "wg-nat"
  shared_egress_gateway {}
}

output "internal_ip_address_service" {
  value = yandex_compute_instance.private_service.network_interface.0.ip_address
}