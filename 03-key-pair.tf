resource "aws_key_pair" "ssh" {
  public_key = file(var.key_public_file)
}

output "ssh_key_pair_name" {
  value = aws_key_pair.ssh.key_name
}
