resource "aws_glue_catalog_database" "glue_s3_db" {
  name = "s3_db"
}

resource "aws_glue_catalog_table" "glue_table_punk_s3" {
  name          = "glue_table_punk_s3"
  database_name = aws_glue_catalog_database.glue_s3_db.name
  table_type    = "EXTERNAL_TABLE"
  retention     = 0

  parameters = {
    "CrawlerSchemaDeserializerVersion" = "1.0",
    "CrawlerSchemaSerializerVersion"   = "1.0",
    "UPDATED_BY_CRAWLER"               = "glue_crawler_s3",
    "areColumnsQuoted"  = "false",
    "averageRecordSize" = "58",
    "classification"    = "csv",
    "columnsOrdered"    = "true",
    "compressionType"   = "none",
    "delimiter"         = ",",
    "objectCount"       = "1",
    "recordCount"       = "4",
    "sizeKey"           = "276",
    "typeOfData"        = "file"
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
    number_of_buckets = -1
    compressed = "false"

    parameters = {
      "CrawlerSchemaDeserializerVersion" = "1.0",
      "CrawlerSchemaSerializerVersion"   = "1.0",
      "UPDATED_BY_CRAWLER"               = "glue_crawler_s3",
      "areColumnsQuoted"  = "false",
      "averageRecordSize" = "58",
      "classification"    = "csv",
      "columnsOrdered"    = "true",
      "compressionType"   = "none",
      "delimiter"         = ",",
      "objectCount"       = "1",
      "recordCount"       = "4",
      "sizeKey"           = "276",
      "typeOfData"        = "file"
    }

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"

      parameters = {
        "field.delim" = ","
      }
    }

    columns {
      name = "id"
      type = "bigint"
    }

    columns {
      name = "name"
      type = "string"
    }

    columns {
      name = "abv"
      type = "double"
    }

    columns {
      name = "ibu"
      type = "double"
    }

    columns {
      name = "target_fg"
      type = "double"
    }

    columns {
      name = "target_og"
      type = "double"
    }

    columns {
      name = "ebc"
      type = "double"
    }

    columns {
      name = "srm"
      type = "double"
    }

    columns {
      name = "ph"
      type = "double"
    }
  }
}

resource "aws_glue_classifier" "glue_csv_classifier" {
  name = "glue_csv_classifier"

  csv_classifier {
    allow_single_column    = false
    contains_header        = "ABSENT"
    delimiter              = ","
    disable_value_trimming = false
    header                 = ["id", "name", "abv", "ibu", "target_fg", "target_og", "ebc", "srm","ph"]
    quote_symbol           = "\""
  }
}

resource "aws_glue_crawler" "glue_crawler_s3" {
  name          = "glue_crawler_s3"
  database_name = aws_glue_catalog_database.glue_s3_db.name
  role          = "service-role/AWSGlueServiceRole-ImportRole2" #TODO
  # schedule      = "cron(0 1 * * ? *)"

  catalog_target {
    database_name = aws_glue_catalog_database.glue_s3_db.name
    tables        = [aws_glue_catalog_table.glue_table_punk_s3.name]
  }

  schema_change_policy {
    delete_behavior = "LOG"
  }

  classifiers = [aws_glue_classifier.glue_csv_classifier.name]

  configuration = <<EOF
{
  "Version":1.0,
  "Grouping": {
    "TableGroupingPolicy": "CombineCompatibleSchemas"
  }
}
EOF
}

resource "aws_glue_catalog_database" "glue_redshift_db" {
  name = "redshift_db"
}

resource "aws_glue_catalog_table" "glue_table_punk_redshift" {
  name          = "glue_table_punk_redshift"
  database_name = aws_glue_catalog_database.glue_redshift_db.name
  table_type    = "EXTERNAL_TABLE"
  retention     = 0

  parameters = {
    "classification" = "redshift"
    "connectionName" = "redshift_connection"
    "typeOfData"     = "table"
  }

  storage_descriptor {
    compressed        = "false"
    location          = "punk_db.public.tbl_punk"
    number_of_buckets = -1

    parameters = {
      "classification" = "redshift"
      "connectionName" = "redshift_connection"
      "typeOfData"     = "table"
    }

    columns {
      name = "id"
      type = "int"
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
      type = "decimal(8,2)"
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

resource "aws_s3_bucket" "bucket_etl_job" {
  bucket        = "arthurbat-punk-bucket-etl-job"
  acl           = "private"
  force_destroy = "true"
}

resource "aws_s3_bucket" "bucket_etl_job_temp" {
  bucket        = "arthurbat-punk-bucket-etl-job-temp"
  acl           = "private"
  force_destroy = "true"
}

resource "aws_s3_bucket" "bucket_redshift_tmp" {
  bucket        = "arthurbat-punk-bucket-redshift-tmp"
  acl           = "private"
  force_destroy = "true"
}

resource "aws_s3_bucket_object" "glue_etl_job" {
  bucket = aws_s3_bucket.bucket_etl_job.id
  key    = "glue_etl_job"
  source = "glue_job_etl.py"
}

resource "aws_glue_job" "glue_job_s3_redshift" {
  name     = "glue_job_s3_redshift"
  role_arn = "arn:aws:iam::409915168629:role/service-role/AWSGlueServiceRole-ImportRole2" #TODO

  command {
    python_version  = "3"
    script_location = "s3://arthurbat-punk-bucket-etl-job/glue_etl_job" #TODO
  }

  connections = [aws_glue_connection.redshift_connection.name]

  default_arguments = {
    "--TempDir"             = aws_s3_bucket.bucket_etl_job_temp.id,
    "--job-bookmark-option" = "job-bookmark-enable",
    "--job-language"        = "python"
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

resource "aws_glue_connection" "redshift_connection" {
  name = "redshift_connection"
  connection_type = "JDBC"
  
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://punk-redshift-cluster.covc4dtrmdkh.sa-east-1.redshift.amazonaws.com:5439/punk_db"
    PASSWORD = "PunkRedShift94"
    USERNAME = "punk_user"
  }

  physical_connection_requirements {
    availability_zone      = "sa-east-1a"
    security_group_id_list = ["sg-3c86c048"]
    subnet_id              = "subnet-d2a2ccb4"
  }
}
