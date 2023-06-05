# GENERAL
variable "access_key" {
  type        = string
  description = "aws region"
  default     = ""
}

variable "secret_key" {
  type        = string
  description = "aws region"
  default     = ""
}

variable "region" {
  type        = string
  description = "aws region"
  default     = ""
}

# Application definition
variable "app_name" {
  type        = string
  description = "Application name"
  default     = ""
}

# Application environment
variable "app_environment" {
  type        = string
  description = "Application environment"
  default     = ""
}

variable "db_username" {
  type        = string
  description = "value"
  default     = "temporal"
}

variable "db_password" {
  type        = string
  description = "value"
  default     = "temporal"
}

# This variable contains the configuration
# settings for the EC2 and RDS instances
variable "settings" {
  description = "Configuration settings"
  type        = map(any)
  default = {
    "database" = {
      allocated_storage = 10            // storage in gigabytes
      engine            = "postgres"    // engine type
      engine_version    = "14"          // engine version
      instance_class    = "db.t3.micro" // rds instance type
      # family               = "postgres14" # DB parameter group
      # major_engine_version = "14"         # DB option group
      db_name             = "db_wordpress" // database name
      skip_final_snapshot = true
    },
    "web_app" = {
      count         = 1          // the number of EC2 instances
      instance_type = "t1.micro" // the EC2 instance
    }
  }
}
