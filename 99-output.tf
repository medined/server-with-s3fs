output "public_subnet_a" {
  value = aws_subnet.public_subnet_a.id
}
output "ssh_user" {
  value = var.ssh_user
}
output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "vpc_name" {
  value = var.vpc_name
}
output "worker_ami" {
  value = {
    "id": data.aws_ami.worker.id,
    "name": data.aws_ami.worker.name
  }
}
