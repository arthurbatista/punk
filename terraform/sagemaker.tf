resource "aws_iam_role" "sm_notebook_instance_role" {
  name = "sm-notebook-instance-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "sagemaker.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_sagemaker_code_repository" "punk_ml_repo" {
  code_repository_name = "punk-ml-repo"

  git_config {
    repository_url = "https://github.com/arthurbatista/punk_ml.git"
  }
}

resource "aws_sagemaker_notebook_instance" "punk_ml" {
  name                    = "punk-ml-notebook"
  role_arn                = aws_iam_role.sm_notebook_instance_role.arn
  instance_type           = "ml.t2.medium"
  default_code_repository = aws_sagemaker_code_repository.punk_ml_repo.code_repository_name

  tags = {
    Name = "foo"
  }
}


