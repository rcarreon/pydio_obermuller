resource "aws_security_group" "iac_obermuller" {
  description             =       "${var.org} ${var.project} ${var.tier_sg}"
  name                    =       "${var.org}_${var.project}_${var.tier_sg}"
  tags {
    Tier            =       "${var.tier_app}"
    Name            =       "${var.org}_${var.project}_${var.tier_sg}"
    Purpose         =       "web servers"
  }
  vpc_id                  =       "${var.vpc}"
  revoke_rules_on_delete  =       ""
}
