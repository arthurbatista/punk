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
  bucket = "arthurbat-punk-bucket-raw"
  acl    = "private"
}

resource "aws_s3_bucket" "bucket_cleaned" {
  bucket = "arthurbat-punk-bucket-cleaned"
  acl    = "private"
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

resource "aws_glue_catalog_database" "glue_s3_db" {
  name = "s3_db"
}

resource "aws_glue_catalog_table" "glue_s3_table_punk" {
  name          = "s3_table_punk"
  database_name = aws_glue_catalog_database.glue_s3_db.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "CrawlerSchemaDeserializerVersion" = "1.0",
    "CrawlerSchemaSerializerVersion" = "1.0",
    "UPDATED_BY_CRAWLER" = "crawler_s3",
    "areColumnsQuoted" = "false",
    "averageRecordSize" = "43",
    "classification" = "csv",
    "columnsOrdered" = "true",
    "compressionType" = "none",
    "delimiter" = ",",
    "objectCount" = "3",
    "recordCount" = "9",
    "sizeKey" = "443",
    "typeOfData" = "file"
  }

  partition_keys {
      name = "partition_0"
      type = "string"
  }
  partition_keys {
    name = "partition_1"
    type = "string"
  }
  partition_keys {
    name = "partition_2"
    type = "string"
  }
  partition_keys {
    name = "partition_3"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://arthurbat-punk-bucket-cleaned/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    parameters = {
      "CrawlerSchemaDeserializerVersion" = "1.0",
      "CrawlerSchemaSerializerVersion" = "1.0",
      "UPDATED_BY_CRAWLER" = "crawler_s3",
      "areColumnsQuoted" = "false",
      "averageRecordSize" = "43",
      "classification" = "csv",
      "columnsOrdered" = "true",
      "compressionType" = "none",
      "delimiter" = ",",
      "objectCount" = "3",
      "recordCount" = "9",
      "sizeKey": "443",
      "typeOfData": "file"
    }

    ser_de_info {
      name                  = "arthurbat-glue-stream"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim" = ","
      }
    }

    columns {
      name = "col0"
      type = "string"
    }

    columns {
      name = "col1"
      type = "double"
    }

    columns {
      name = "col2"
      type = "double"
    }

    columns {
      name = "col3"
      type = "double"
    }

    columns {
      name = "col4"
      type = "double"
    }

    columns {
      name = "col5"
      type = "bigint"
    }

    columns {
      name = "col6"
      type = "double"
    }
    
    columns {
      name = "col7"
      type = "double"
    }
  }
}

resource "aws_glue_catalog_database" "glue_redshift_db" {
  name = "redshift_db"
}

resource "aws_glue_catalog_table" "glue_redshift_table_punk" {
  name          = "redshift_table_punk"
  database_name = aws_glue_catalog_database.glue_redshift_db.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "redshift"
    "connectionName" = "redshift_connection"
    "typeOfData"     = "table"
  }

  storage_descriptor {
    location      = "punk_db.public.tbl_punk"

    parameters = {
      "classification" = "redshift"
      "connectionName" = "redshift_connection"
      "typeOfData"     = "table"
    }

    columns {
      name = "name"
      type = "string"
    }

    columns {
      name = "abv"
      type = "decimal(8,2)"
    }

    columns {
      name = "ibu"
      type = "decimal(8,2)"
    }

    columns {
      name = "target_fg"
      type = "decimal(8,2)"
    }

    columns {
      name = "target_og"
      type = "decimal(8,2)"
    }

    columns {
      name = "ebc"
      type = "int"
    }

    columns {
      name = "srm"
      type = "decimal(8,2)"
    }
    
    columns {
      name = "ph"
      type = "decimal(8,2)"
    }
  }
}

resource "aws_redshift_cluster" "punk_redshift" {
  cluster_identifier = "punk-redshift-cluster"
  database_name      = "punk_db"
  master_username    = "punk_user"
  master_password    = "PunkRedShift94"
  node_type          = "dc2.large"
  cluster_type       = "single-node"
  skip_final_snapshot = "true"
}

# resource "aws_glue_connection" "redshift_connection" {
#   connection_properties = {
#     JDBC_CONNECTION_URL = "jdbc:redshift://punk-redshift-cluster.covc4dtrmdkh.sa-east-1.redshift.amazonaws.com:5439/punk_db"
#     # JDBC_CONNECTION_URL = "jdbc:redshift://${aws_redshift_cluster.punk_redshift.cluster_identifier}/punk_db"
#     PASSWORD            = "PunkRedShift94"
#     USERNAME            = "punk_user"
#   }

#   name = "redshift_connection"
# }


