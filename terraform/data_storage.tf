resource "aws_glue_catalog_database" "glue_s3_db" {
  name = "s3_db"
}

resource "aws_glue_catalog_table" "glue_s3_table_punk" {
  name          = "s3_table_punk"
  database_name = aws_glue_catalog_database.glue_s3_db.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    # "CrawlerSchemaDeserializerVersion" = "1.0",
    # "CrawlerSchemaSerializerVersion" = "1.0",
    # "UPDATED_BY_CRAWLER" = "crawler_s3",
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
      # "CrawlerSchemaDeserializerVersion" = "1.0",
      # "CrawlerSchemaSerializerVersion" = "1.0",
      # "UPDATED_BY_CRAWLER" = "crawler_s3",
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
      type = "double"
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
