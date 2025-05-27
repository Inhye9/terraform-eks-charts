# terraform {
#   backend "s3" {
#     bucket         = "aim-terraform-state"
#     key            = "test/ec2/terraform.tfstate"
#     region         = "ap-northeast-2"
#     profile        = "2244615"
#     dynamodb_table = "terraform-lock"
#   }
# }