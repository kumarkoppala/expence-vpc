locals {
    common_tags = {
        Project = "var.project"
        Env = "var.env"
        Name = "${var.project}-${var.env}"
    }
}