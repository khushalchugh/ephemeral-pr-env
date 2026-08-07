resource "aws_iam_role" "lambda_ec2_cleanup_role" {
  name = "lambda_ec2_cleanup_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_ec2_policy" {
  name = "lambda_ec2_policy"
  role = aws_iam_role.lambda_ec2_cleanup_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:TerminateInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "cleanup.py"
  output_path = "cleanup.zip"
}

resource "aws_lambda_function" "ec2_cleanup" {
  filename         = "cleanup.zip"
  function_name    = "ephemeral_ec2_cleanup"
  role             = aws_iam_role.lambda_ec2_cleanup_role.arn
  handler          = "cleanup.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.10"
  timeout          = 15
}

# Create the Cron Job (Runs every day at midnight UTC)
resource "aws_cloudwatch_event_rule" "daily_cleanup" {
  name                = "daily_ec2_cleanup"
  schedule_expression = "cron(0 0 * * ? *)"
}

# Link the Cron Job to your Lambda
resource "aws_cloudwatch_event_target" "trigger_lambde" {
  rule      = aws_cloudwatch_event_rule.daily_cleanup.name
  target_id = "TriggerLambda"
  arn       = aws_lambda_function.ec2_cleanup.arn
}

# Give EventBridge permission to "press the Start button" on your Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_cleanup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_cleanup.arn
}