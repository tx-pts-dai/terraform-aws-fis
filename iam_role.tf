
resource "aws_iam_role" "experiment_runner" {
  name = "FIS-runner"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "fis.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEC2Access",
    "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorRDSAccess"
  ]
}

resource "aws_iam_role_policy_attachment" "s3_logging" {
  role       = aws_iam_role.experiment_runner.name
  policy_arn = aws_iam_policy.fis_logging.arn
}

resource "aws_iam_policy" "fis_logging" {
  name        = "fault_injection_logging"
  description = "IAM policy for fault injection experiments logging"
  policy      = data.aws_iam_policy_document.fis_logging.json
}

data "aws_iam_policy_document" "fis_logging" {
  statement {
    actions   = ["logs:*"]
    resources = ["*"]
  }
  statement {
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.logs.arn,
      "${aws_s3_bucket.logs.arn}/*"
    ]
  }
}
