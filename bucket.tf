resource "aws_s3_bucket" "site_bucket" {
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
        "Resource":[
            "arn:aws:s3:::${var.domain}/*",
            "arn:aws:s3:::${var.domain}"
            ]
      }]
    }
  EOF

#    website {
#       index_document = "index.html"
#   }
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site_bucket.id

  index_document {
    suffix = "index.html"
  }

#   depends_on = [
#     aws_s3_bucket_object.object
#   ]
}

#   # website {
#   #     index_document = "index.html"
#   # }
# }

# resource "aws_s3_bucket_object" "object" {
#   bucket = aws_s3_bucket.site_bucket.id
#   key    = "index.html"
#   source = "index.html"
#   etag = filemd5("./index.html")

#   content_type = "text/html"

#   depends_on = [
#     aws_s3_bucket.site_bucket
#   ]
# }

module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/web"
}

resource "aws_s3_bucket_object" "static_files" {
  for_each = module.template_files.files

  bucket       = "${var.domain}"
  key          = each.key
  content_type = each.value.content_type

  # The template_files module guarantees that only one of these two attributes
  # will be set for each file, depending on whether it is an in-memory template
  # rendering result or a static file on disk.
  source  = each.value.source_path
  content = each.value.content

  # Unless the bucket has encryption enabled, the ETag of each object is an
  # MD5 hash of that object.
  etag = each.value.digests.md5
}

# resource "aws_s3_bucket_object" "css" {
#   for_each = fileset("./css/", "*")
#   bucket = aws_s3_bucket.site_bucket.id
#   key = "./css/${each.value}"
#   source = "./css/${each.value}"
#   etag = filemd5("./css/${each.value}")

#   depends_on = [
#     aws_s3_bucket.site_bucket
#   ]

# }

# resource "aws_s3_bucket_object" "css-awesome-c" {
#   for_each = fileset("./css/font-awesome/css/", "*")
#   bucket = aws_s3_bucket.site_bucket.id
#   key = "./css/font-awesome/css/${each.value}"
#   source = "./css/font-awesome/css/${each.value}"
#   etag = filemd5("./css/font-awesome/css/${each.value}")

#   depends_on = [
#     aws_s3_bucket.site_bucket
#   ]

# }

# resource "aws_s3_bucket_object" "css-awesome-f" {
#   for_each = fileset("./css/font-awesome/fonts/", "*")
#   bucket = aws_s3_bucket.site_bucket.id
#   key = "./css/font-awesome/fonts/${each.value}"
#   source = "./css/font-awesome/fonts/${each.value}"
#   etag = filemd5("./css/font-awesome/fonts/${each.value}")

#   depends_on = [
#     aws_s3_bucket.site_bucket
#   ]

# }

# resource "aws_s3_bucket_object" "css-awesome-l" {
#   for_each = fileset("./css/font-awesome/less/", "*")
#   bucket = aws_s3_bucket.site_bucket.id
#   key = "./css/font-awesome/less/${each.value}"
#   source = "./css/font-awesome/less/${each.value}"
#   etag = filemd5("./css/font-awesome/less/${each.value}")

#   depends_on = [
#     aws_s3_bucket.site_bucket
#   ]

# }

# resource "aws_s3_bucket_object" "css-awesome-s" {
#   for_each = fileset("./css/font-awesome/scss/", "*")
#   bucket = aws_s3_bucket.site_bucket.id
#   key = "./css/font-awesome/scss/${each.value}"
#   source = "./css/font-awesome/scss/${each.value}"
#   etag = filemd5("./css/font-awesome/scss/${each.value}")

#   depends_on = [
#     aws_s3_bucket.site_bucket
#   ]

# }

# resource "aws_s3_bucket_object" "css-fontello-c" {
#   for_each = fileset("./css/fontello/css/", "*")
#   bucket = aws_s3_bucket.site_bucket.id
#   key = "./css/fontello/css/${each.value}"
#   source = "./css/fontello/css/${each.value}"
#   etag = filemd5("./css/fontello/css/${each.value}")

#   depends_on = [
#     aws_s3_bucket.site_bucket
#   ]

# }

# resource "aws_s3_bucket_object" "css-fontello-f" {
#   for_each = fileset("./css/fontello/font/", "*")
#   bucket = aws_s3_bucket.site_bucket.id
#   key = "./css/fontello/font/${each.value}"
#   source = "./css/fontello/font/${each.value}"
#   etag = filemd5("./css/fontello/font/${each.value}")

#   depends_on = [
#     aws_s3_bucket.site_bucket
#   ]

# }

# resource "aws_s3_bucket_object" "css-fonts-libre" {
#   for_each = fileset("./css/fonts/librebaskerville/", "*")
#   bucket = aws_s3_bucket.site_bucket.id
#   key = "./css/fonts/librebaskerville/${each.value}"
#   source = "./css/fonts/librebaskerville/${each.value}"
#   etag = filemd5("./css/fonts/librebaskerville/${each.value}")

#   depends_on = [
#     aws_s3_bucket.site_bucket
#   ]

# }

# resource "aws_s3_bucket_object" "css-fonts-open" {
#   for_each = fileset("./css/fonts/opensans/", "*")
#   bucket = aws_s3_bucket.site_bucket.id
#   key = "./css/fonts/opensans/${each.value}"
#   source = "./css/fonts/opensans/${each.value}"
#   etag = filemd5("./css/fonts/opensans/${each.value}")

#   depends_on = [
#     aws_s3_bucket.site_bucket
#   ]

# }

# resource "aws_s3_bucket_object" "images" {
#   for_each = fileset("./images/", "*")
#   bucket = aws_s3_bucket.site_bucket.id
#   key = "./images/${each.value}"
#   source = "./images/${each.value}"
#   etag = filemd5("./images/${each.value}")

#   depends_on = [
#     aws_s3_bucket.site_bucket
#   ]

# }
# resource "aws_s3_bucket_object" "js" {
#   for_each = fileset("./js/", "*")
#   bucket = aws_s3_bucket.site_bucket.id
#   key = "./js/${each.value}"
#   source = "./js/${each.value}"
#   etag = filemd5("./js/${each.value}")

#   depends_on = [
#     aws_s3_bucket.site_bucket
#   ]

# }

# resource "aws_s3_bucket_object" "favicon" {
#   bucket = aws_s3_bucket.site_bucket.id
#   key    = "favicon.png"
#   source = "./favicon.png"
#   etag = filemd5("./favicon.png")

#   depends_on = [
#     aws_s3_bucket.site_bucket
#   ]

# }