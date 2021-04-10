provider "aws" {
  region = "sa-east-1"
}


resource "aws_iam_role" "punk_role" {
  name = "punk_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "punk_policy" {
  name = "punk_policy"

  role = aws_iam_role.punk_role.id

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*" 
    },
    {
      "Effect": "Allow",
      "Action": "kinesis:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "firehose:*",
      "Resource" : "*"
    }
  ]
}
EOF
}

resource "aws_kinesis_stream" "punk_stream" {
  name             = "punk-stream"
  shard_count      = 1
  retention_period = 24
}

resource "aws_s3_bucket" "bucket_raw" {
  bucket = "arthurbat-punk-bucket-raw"
  acl    = "private"
}

resource "aws_kinesis_firehose_delivery_stream" "raw_consumer" {
  name        = "terraform-kinesis-firehose-raw-consumer"
  destination = "s3"

  kinesis_source_configuration {
    role_arn           = aws_iam_role.punk_role.arn
    kinesis_stream_arn = aws_kinesis_stream.punk_stream.arn
  }

  s3_configuration {
    role_arn        = aws_iam_role.punk_role.arn
    bucket_arn      = aws_s3_bucket.bucket_raw.arn
    buffer_size     = 5
    buffer_interval = 60
    # compression_format = "GZIP"
  }
}