resource "aws_sns_topic" "alarm" {
  name = "alarm-topic"
}
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "email"
  endpoint  = "victor.almeida@xxxx.com"
}

resource "aws_sns_topic" "lambda_update_instance" {
  name = "alarm-update-instance"
}

resource "aws_sns_topic_subscription" "lambda_update_instance" {
  topic_arn = aws_sns_topic.lambda_update_instance.arn
  protocol  = "lambda"
  endpoint  = "arn:aws:lambda:eu-west-2:xxxx:function:nbg"
}


resource "aws_sqs_queue" "my_queue" {
  name                      = "my-queue.fifo"
  fifo_queue                = true
  content_based_deduplication = true
  delay_seconds             = 0
  message_retention_seconds = 60000
  receive_wait_time_seconds = 0
}