resource "aws_s3_bucket" "eks-bucket" {
  bucket = "terraform-eks-state-bucket-roshan"  

  lifecycle {
    prevent_destroy = false
  }
}

# resource "aws_dynamodb_table" "eks-table" {
#   name = "terraform-eks-state-lock"
#   hash_key = "LockID"
#   billing_mode = "PAY_PER_REQUEST"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }