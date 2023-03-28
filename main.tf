variable "aws_region" {
  default     = "us-east-1"
}

#variable "aws_access_key" {}

#variable "aws_secret_key" {}

variable "domain" {
  default = "daniel-barak-hill.io"
}

provider "aws" {
  region = var.aws_region       # default us-east-1
  # access_key=var.aws_access_key
  # secret_key=var.aws_secret_key
}

# Note: The bucket name needs to carry the same name as the domain!
# http://stackoverflow.com/a/5048129/2966951
resource "aws_s3_bucket" "site" {
  bucket = "${var.domain}"
  acl = "public-read"

  policy = <<EOF
    {
      "Version":"2008-10-17",
      "Statement":[{
        "Sid":"AllowPublicRead",
        "Effect":"Allow",
        "Principal": {"AWS": "*"},
        "Action":["s3:GetObject"],
        "Resource":["arn:aws:s3:::${var.domain}/*"]
      }]
    }
  EOF

  website {
      index_document = "index.html"
  }
}

# Note: Creating this route53 zone is not enough. The domain's name servers need to point to the NS
# servers of the route53 zone. Otherwise the DNS lookup will fail.
# To verify that the dns lookup succeeds: `dig site @nameserver`
resource "aws_route53_zone" "main" {
  name = "${var.domain}"
}

resource "aws_route53_record" "root_domain" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "${var.domain}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.cdn.domain_name}"
    zone_id = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    origin_id   = "${var.domain}"
    domain_name = "${var.domain}.s3.amazonaws.com"
  }

  # If using route53 aliases for DNS we need to declare it here too, otherwise we'll get 403s.
  # aliases = ["${var.domain}"]

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.domain}"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # The cheapest priceclass
  price_class = "PriceClass_100"

  # This is required to be specified even if it's not used.
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "s3_website_endpoint" {
  value = "${aws_s3_bucket.site.website_endpoint}"
}

output "route53_domain" {
  value = "${aws_route53_record.root_domain.fqdn}"
}

output "cdn_domain" {
  value = "${aws_cloudfront_distribution.cdn.domain_name}"
}

resource "aws_iam_role" "lambda_role" {
name   = "Lambda_Function_Role"
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

resource "aws_iam_policy" "iam_policy_for_lambda" {
 
 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "dynamodb:*"
     ],
     "Resource": "*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "${path.module}/lambda/"
output_path = "${path.module}/lambda/lambda_function.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
filename                       = "${path.module}/lambda/lambda_function.zip"
function_name                  = "Lambda_Function"
role                           = aws_iam_role.lambda_role.arn
handler                        = "index.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}