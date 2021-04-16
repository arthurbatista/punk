resource "aws_iam_role" "iam_producer" {
  name = "iam_producer"
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

resource "aws_iam_role_policy" "policy_producer" {
  name = "policy_producer"
  role = aws_iam_role.iam_producer.id
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect": "Allow",
      "Action": "kinesis:*",
      "Resource": "*"
    }
  ]
}
EOF
}

data "archive_file" "zip_producer" {
  type        = "zip"
  source_file = "lambda_punk_producer.py"
  output_path = "lambda_punk_producer.zip"
}

resource "aws_lambda_function" "lambda_producer" {
    filename      = "lambda_punk_producer.zip"
    function_name = "lambda_producer"
    role          = aws_iam_role.iam_producer.arn
    handler       = "lambda_punk_producer.run"
    runtime       = "python3.7"
}

resource "aws_cloudwatch_event_rule" "every_five_minutes" {
    name = "every-five-minutes"
    description = "Fires every five minutes"
    schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_five_minutes" {
    rule = aws_cloudwatch_event_rule.every_five_minutes.name
    target_id = "lambda_producer"
    arn = aws_lambda_function.lambda_producer.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_lambda_producer" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_producer.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_five_minutes.arn
}
