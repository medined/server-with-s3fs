output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "public_subnet_a" {
  value = "${aws_subnet.public_subnet_a.id}"
}
