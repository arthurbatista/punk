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
    },
    {
      "Effect": "Allow",
      "Action": "lambda:*",
      "Resource" : "*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "bucket_raw" {
  bucket        = "arthurbat-punk-bucket-raw"
  acl           = "private"
  force_destroy = "true"
}

resource "aws_s3_bucket" "bucket_cleaned" {
  bucket        = "arthurbat-punk-bucket-cleaned"
  acl           = "private"
  force_destroy = "true"
}

resource "aws_kinesis_stream" "punk_stream" {
  name             = "punk-stream"
  shard_count      = 1
  retention_period = 24
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
  }
}

resource "aws_kinesis_firehose_delivery_stream" "cleaned_consumer" {
  name        = "terraform-kinesis-firehose-cleaned-consumer"
  destination = "extended_s3"

  kinesis_source_configuration {
    role_arn           = aws_iam_role.punk_role.arn
    kinesis_stream_arn = aws_kinesis_stream.punk_stream.arn
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.punk_role.arn
    bucket_arn = aws_s3_bucket.bucket_cleaned.arn
    buffer_size     = 5
    buffer_interval = 60

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
        }

        parameters {
          parameter_name  = "RoleArn"
          parameter_value = aws_iam_role.punk_role.arn
        }
      }
    }
  }
}

resource "aws_iam_role" "lambda_iam" {
  name = "lambda_iam"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "data_transformation.py"
  output_path = "data_transformation.zip"
}

resource "aws_lambda_function" "lambda_processor" {
  filename      = data.archive_file.zip.output_path
  function_name = "firehose_lambda_data_transformation"
  role          = aws_iam_role.lambda_iam.arn
  handler       = "data_transformation.handler"
  runtime       = "python3.7"
}
