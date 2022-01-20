// variable "AWS_ACCESS_KEY" {
//   type = string
//   description = "AWS Access Key credential"
// }

// variable "AWS_SECRET_KEY" {
//   type = string
//   description = "AWS Secret Key credential"
// }

variable "AWS" {
  type = object({
    ACCESS_KEY = string
    SECRET_KEY = string
  })
  description = "AWS credentials"
}
