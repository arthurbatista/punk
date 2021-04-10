provider "aws" {
  region = "sa-east-1"
}

resource "aws_kinesis_stream" "punk_stream" {
  name             = "punk-stream"
  shard_count      = 1
  retention_period = 24
}