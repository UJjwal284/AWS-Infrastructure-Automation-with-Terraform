variable "username" {
  type    = string
}

variable "age" {
  type    = number
}

variable "language" {
  type    = list
  default = ["English", "Hindi"]
}

variable "member" {
  type    = map
  default = {
    Person1 = 31
    Person2 = 33
  }
}