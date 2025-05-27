variable "origin_domain_name" {
  description = "Domain name of the origin (ALB DNS name or S3 bucket website endpoint)"
  type        = string
}

variable "origin_id" {
  description = "Unique identifier for the origin"
  type        = string
  default     = "default-origin"
}

variable "origin_type" {
  description = "Type of origin (s3 or alb)"
  type        = string
  default     = "alb"
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront"
  type        = string
}

variable "domain_names" {
  description = "List of domain names for CloudFront distribution"
  type        = list(string)
}

variable "enable_https_only" {
  description = "Redirect HTTP to HTTPS"
  type        = bool
  default     = true
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}