variable "server" {
  type        = string
  description = "The NFS server to mount as volumn"
  nullable    = false
}

variable "directory" {
  type        = string
  description = "The directory to mount as volumn"
  nullable    = false
}

variable "nfs_version" {
  type        = string
  description = "The NFS server version"
  default     = "4.1"
}
