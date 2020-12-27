# ..######..##........#######..##.....##.########........####.##....##.####.########
# .##....##.##.......##.....##.##.....##.##.....##........##..###...##..##.....##...
# .##.......##.......##.....##.##.....##.##.....##........##..####..##..##.....##...
# .##.......##.......##.....##.##.....##.##.....##........##..##.##.##..##.....##...
# .##.......##.......##.....##.##.....##.##.....##........##..##..####..##.....##...
# .##....##.##.......##.....##.##.....##.##.....##........##..##...###..##.....##...
# ..######..########..#######...#######..########........####.##....##.####....##...

data "template_file" "user_data" {
  template = file("${path.module}/init.tpl")
}

# .####.##....##..######..########....###....##....##..######..########
# ..##..###...##.##....##....##......##.##...###...##.##....##.##......
# ..##..####..##.##..........##.....##...##..####..##.##.......##......
# ..##..##.##.##..######.....##....##.....##.##.##.##.##.......######..
# ..##..##..####.......##....##....#########.##..####.##.......##......
# ..##..##...###.##....##....##....##.....##.##...###.##....##.##......
# .####.##....##..######.....##....##.....##.##....##..######..########

#
# If subnet_id is not specified, then the default vpc is used.
# Make sure the subnet is inside the selected availability_zone.
#
# Disk volumes are specified as separate terraform resources
# so they can be managed if needed.
#
resource "aws_instance" "worker" {
  ami                         = data.aws_ami.worker.id
  associate_public_ip_address = true
  availability_zone           = data.aws_availability_zones.available.names[0]
  depends_on                  = [
    aws_iam_instance_profile.s3fs_worker,
    aws_internet_gateway.ig,
    aws_security_group.ssh,
    aws_security_group.web,
    aws_subnet.public_subnet_a
  ]
  iam_instance_profile        = aws_iam_instance_profile.s3fs_worker.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet_a.id
  user_data                   = data.template_file.user_data.rendered
  vpc_security_group_ids      = [
    aws_security_group.ssh.id,
    aws_security_group.web.id
  ]
  tags                        = {
    Name = "${var.vpc_name}-worker"
  }
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.key_private_file)
    host        = self.public_ip
  }
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = "100"
    delete_on_termination = true
  }
  #
  # Get the remote server ready for ansible playbooks. This runs as the centos user on
  # the remote server.
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 2; done",
      "sudo yum update -y",
      "sudo yum install -y python3",
      "curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py",
      "sudo python3 get-pip.py",
      "sudo python3 -m pip install boto boto3"
    ]
  }
  # provisioner "local-exec" {
  #   command = "ansible-playbook -u ${var.ssh_user} -i '${self.public_ip},' --private-key ${var.key_private_file} playbook.worker.yml" 
  #   environment = {
  #     ANSIBLE_HOST_KEY_CHECKING = "False"
  #   }
  # }
}

#
# For C5 and M5 type instances, EBS volumes are exposed as NVMe block devices. 
# The device names are /dev/nvme0n1, /dev/nvme1n1, and so on. The device name 
# that you specify in a block device mapping are renamed using NVMe device 
# naming convention (/dev/nvme[0-26]n1).
#
# resource "aws_ebs_volume" "worker" {
#   availability_zone = data.aws_availability_zones.available.names[0]
#   size              = 100
#   type              = "gp2"
#   tags              = {
#     Name = "${var.vpc_name}-worker"
#   }
# }

# resource "aws_volume_attachment" "worker" {
#   device_name = "/dev/sdf"
#   instance_id = aws_instance.worker.id
#   volume_id   = aws_ebs_volume.worker.id
# }

# ..######...########.##....##.########.########.....###....########.########.########.
# .##....##..##.......###...##.##.......##.....##...##.##......##....##.......##.....##
# .##........##.......####..##.##.......##.....##..##...##.....##....##.......##.....##
# .##...####.######...##.##.##.######...########..##.....##....##....######...##.....##
# .##....##..##.......##..####.##.......##...##...#########....##....##.......##.....##
# .##....##..##.......##...###.##.......##....##..##.....##....##....##.......##.....##
# ..######...########.##....##.########.##.....##.##.....##....##....########.########.

# .########.####.##.......########..######.
# .##........##..##.......##.......##....##
# .##........##..##.......##.......##......
# .######....##..##.......######....######.
# .##........##..##.......##.............##
# .##........##..##.......##.......##....##
# .##.......####.########.########..######.

resource "local_file" "inventory" {
  content = "[all]\n${aws_instance.worker.public_ip}"
  filename = "inventory"
  file_permission = "0644"
}
