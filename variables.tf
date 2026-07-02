variable "project" {
    type = string
}

variable "env" {
    type = string
}

variable "public_cidrs" {
    type = list
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_cidrs" {
    type = list
    default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_cidrs" {
    type = list
    default = ["10.0.13.0/24", "10.0.14.0/24"]
}



