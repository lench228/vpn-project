variable "token" {
  description = "OAuth токен вашего аккаунта"
  type        = string
}
variable "cloud_id" {
  description = "Айди облака, в котором будут создаваться ресурсы"
  type        = string
}
variable "folder_id" {
  description = "Айди папки, в которой будут создаваться ресурсы"
  type        = string
}

variable "private_service_image" {
  description = "Айди образа для ВМ с вашим сервисом"
  type        = string
}

variable "public_ip_address_id" {
  description = "Айди статического ip-адреса для сервера vpn"
  type        = string
}
