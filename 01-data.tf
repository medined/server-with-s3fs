data "aws_ami" "worker" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
      name   = "name"
      values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
      name   = "architecture"
      values = ["x86_64"]
  }

  filter {
      name   = "root-device-type"
      values = ["ebs"]
  }
}

data "aws_availability_zones" "available" {
    state = "available"
}

output "worker_ami" {
  value = {
    "id": data.aws_ami.worker.id,
    "name": data.aws_ami.worker.name
  }
}
