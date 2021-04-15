import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [TempDir, JOB_NAME]
args = getResolvedOptions(sys.argv, ['TempDir','JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
## @type: DataSource
## @args: [database = "s3_db", table_name = "glue_table_punk_s3", transformation_ctx = "datasource0"]
## @return: datasource0
## @inputs: []
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "s3_db", table_name = "glue_table_punk_s3", transformation_ctx = "datasource0")
## @type: ApplyMapping
## @args: [mapping = [("col6", "long", "ebc", "decimal(8,2)"), ("col1", "string", "name", "string"), ("col3", "long", "ibu", "decimal(8,2)"), ("col0", "long", "id", "int"), ("col2", "double", "abv", "decimal(8,2)"), ("col8", "double", "ph", "decimal(8,2)"), ("col7", "double", "srm", "decimal(8,2)"), ("col5", "long", "target_og", "decimal(8,2)"), ("col4", "long", "target_fg", "decimal(8,2)")], transformation_ctx = "applymapping1"]
## @return: applymapping1
## @inputs: [frame = datasource0]
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("col6", "long", "ebc", "decimal(8,2)"), ("col1", "string", "name", "string"), ("col3", "long", "ibu", "decimal(8,2)"), ("col0", "long", "id", "int"), ("col2", "double", "abv", "decimal(8,2)"), ("col8", "double", "ph", "decimal(8,2)"), ("col7", "double", "srm", "decimal(8,2)"), ("col5", "long", "target_og", "decimal(8,2)"), ("col4", "long", "target_fg", "decimal(8,2)")], transformation_ctx = "applymapping1")
## @type: SelectFields
## @args: [paths = ["id", "name", "abv", "ibu", "target_fg", "target_og", "ebc", "srm", "ph"], transformation_ctx = "selectfields2"]
## @return: selectfields2
## @inputs: [frame = applymapping1]
selectfields2 = SelectFields.apply(frame = applymapping1, paths = ["id", "name", "abv", "ibu", "target_fg", "target_og", "ebc", "srm", "ph"], transformation_ctx = "selectfields2")
## @type: ResolveChoice
## @args: [choice = "MATCH_CATALOG", database = "redshift_db", table_name = "glue_table_punk_redshift", transformation_ctx = "resolvechoice3"]
## @return: resolvechoice3
## @inputs: [frame = selectfields2]
resolvechoice3 = ResolveChoice.apply(frame = selectfields2, choice = "MATCH_CATALOG", database = "redshift_db", table_name = "glue_table_punk_redshift", transformation_ctx = "resolvechoice3")
## @type: ResolveChoice
## @args: [choice = "make_cols", transformation_ctx = "resolvechoice4"]
## @return: resolvechoice4
## @inputs: [frame = resolvechoice3]
resolvechoice4 = ResolveChoice.apply(frame = resolvechoice3, choice = "make_cols", transformation_ctx = "resolvechoice4")
## @type: DataSink
## @args: [database = "redshift_db", table_name = "glue_table_punk_redshift", redshift_tmp_dir = TempDir, transformation_ctx = "datasink5"]
## @return: datasink5
## @inputs: [frame = resolvechoice4]
#datasink5 = glueContext.write_dynamic_frame.from_catalog(frame = resolvechoice4, database = "redshift_db", table_name = "glue_table_punk_redshift", redshift_tmp_dir = args["TempDir"], transformation_ctx = "datasink5")
#TODO - s3://arthurbat-punk-bucket-redshift-tmp/
datasink5 = glueContext.write_dynamic_frame.from_catalog(frame = resolvechoice4, database = "redshift_db", table_name = "glue_table_punk_redshift", redshift_tmp_dir = "s3://arthurbat-punk-bucket-redshift-tmp/", transformation_ctx = "datasink5")
job.commit()