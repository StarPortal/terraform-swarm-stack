output "driver_options" {
  value = {
    type   = "nfs"
    o      = "addr=${var.server},rw,async,vers=${var.nfs_version}"
    device = ":${var.directory}"
  }
  description = "The Docker Volume driver options for NFS"
}
