variable "token" {
  description = "OAuth токен вашего аккаунта"
  type = string
}
variable "cloud_id" {
  description = "Айди облака, в котором будут создаваться ресурсы"
  type = string
}
variable "folder_id" {
  description = "Айди папки, в которой будут создаваться ресурсы"
  type = string
}

variable "wg_image_id" {
  description = "Айди образа для ВМ с впном"
  type = string
}

variable private_service_image {
  description = "Айди образа для ВМ с вашим сервисом"
  type = string
}

variable "path_to_ssh_key" {
  description = "Путь к ключу ssh, для доступа к серверу"
  type = string
}