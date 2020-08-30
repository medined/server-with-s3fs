resource "aws_iam_role" "s3fs_worker" {
  name = "s3fs_worker"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ])

  role       = aws_iam_role.s3fs_worker.id
  policy_arn = each.value
}
